# Draw with the GPU

`GFX.GPU` presents GPU work as a story:

1. a `Device` creates resources;
2. `commands()` starts recording work;
3. `render`, `copy`, or `compute` opens one kind of pass;
4. the pass binds what it needs and performs its work;
5. `submit()` sends the complete story to the GPU.

SDL_GPU handles and native layouts stay inside GFX. The direct API remains
available when an application needs explicit formats, resource usages,
synchronization, load/store operations, or pipeline state.

After obtaining the GFX package, install SDL3 for the host once:

~~~sh
silex install path/to/GFX
~~~

Use `--target linux-x64`, `--target windows-x64`, or
`--target windows-arm64` to prepare another target. Silex verifies the
published SHA-256 checksum before making the archive available. Builds then
remain offline and applications do not manipulate these native artifacts.

GFX provides target-matched SDL3 3.4.10 static boundaries for `macos-arm64`,
`linux-x64`, `windows-x64`, and `windows-arm64`. Applications name only GFX;
the package manifest owns the archives, Apple frameworks, and Linux or Windows
system libraries. The Linux archive is a hermetic X11 and Vulkan build; Wayland,
OpenGL, D-Bus IME, udev, and optional host audio/camera backends are disabled
in that profile.

## Present the first frame

```sx
use GFX.Window
use GFX.Color
use GFX.GPU

var window = Window(Window.Settings(title:"First GPU frame"))
var device = GPU.Device()
var surface = device.present(window)
var commands = device.commands()
commands.clear(surface, Color.indigo_900())
commands.submit()
```

`render(surface)` waits for the next drawable image. `try_render(surface)`
uses the non-blocking acquisition path and returns `null` when no image is
currently available. That state is normal while a window is minimized or its
swapchain is being recreated.

```sx
var commands = device.commands()
if var pass = commands.try_render(surface, Color.black()) {
    // bind a pipeline, bind resources, then draw
    pass.finish()
}
commands.submit()
```

The device can report its selected driver and shader formats. A surface can
query support for presentation modes and color spaces before `configure()` is
called. `allows_frames_in_flight()` exposes explicit pacing control.

Device creation keeps SDL's portable defaults visible while exposing the
backend choices that can materially change compatibility:

```sx
let settings = GPU.DeviceSettings(
    debug:true,
    prefer_low_power:true,
    features:GPU.DeviceFeatures(
        clip_distance:true,
        depth_clamping:true,
        indirect_first_instance:true,
        anisotropy:true
    )
)

if GPU.Device.is_supported(settings) {
    var device = GPU.Device(settings)
    let information = device.info()
}
```

`D3D12DeviceSettings`, `VulkanDeviceSettings`, and `MetalDeviceSettings`
contain the backend-specific compatibility switches accepted by SDL. Vulkan
extension lists and feature-chain addresses belong to the advanced path; the
pointed storage must remain alive during device creation. Each Vulkan extension
list accepts at most 64 names. `suspend()` and `resume()` expose the GDK
lifecycle hooks and should only be used by an Xbox platform integration.

## Create only the resources the intent requires

Usage descriptions are combinable structures rather than opaque bitmasks:

```sx
var vertices = device.buffer(GPU.BufferSettings(
    size:4096,
    usage:GPU.BufferUsage(vertices:true, compute_read:true),
    name:"Scene vertices"
))

var color = device.texture(GPU.TextureSettings(
    format:GPU.TextureFormat.rgba16_float,
    width:1280,
    height:720,
    usage:GPU.TextureUsage(sampled:true, color_target:true),
    name:"HDR scene color"
))

var sampler = device.sampler(GPU.SamplerSettings(
    anisotropic:true,
    max_anisotropy:8.0,
    name:"World textures"
))
```

The short forms cover the common single-purpose cases:
`BufferUsage.vertex()`, `BufferUsage.index()`,
`TextureUsage.for_sampling()`, `TextureUsage.as_color_target()`, and
`TextureUsage.as_depth_target()`.

Device-local buffers and textures are filled through a copy pass. Upload and
download buffers make the direction visible in the code:

```sx
var upload = device.upload_buffer(bytes.count())
upload.write(@bytes[0:bytes.count()])

var commands = device.commands()
var transfer = commands.copy()
transfer.upload(upload, vertices, bytes.count())
transfer.finish()
commands.submit()
```

The same pass uploads and downloads texture regions, copies buffers, and
copies textures. A tracked submission returns a `Fence`; use `is_ready()` for
polling or `wait()` for an explicit synchronization point. A device can wait
for a group of at most 64 fences with `wait_until_any()` or
`wait_until_all()`.

`texel_block_size()` and `texture_byte_count()` calculate transfer storage for
compressed and uncompressed formats. `pixel_format()` and `texture_format()`
translate the host pixel formats that SDL can represent directly as GPU
textures.

## Describe a pipeline, then draw

Shaders accept either a byte view for compiled SPIR-V, DXBC, DXIL, or Metal
libraries, or a string for textual MSL. Resource counts remain explicit
because they are part of the shader contract.

```sx
var vertex = device.shader(
    GPU.ShaderStage.vertex,
    GPU.ShaderFormat.msl,
    vertex_source,
    GPU.ShaderSettings(entry:"vertex_main")
)
var fragment = device.shader(
    GPU.ShaderStage.fragment,
    GPU.ShaderFormat.msl,
    fragment_source,
    GPU.ShaderSettings(entry:"fragment_main")
)

var targets:GPU.ColorTargetFormat[] = []
targets.append(GPU.ColorTargetFormat(format:surface.format()))
var pipeline = device.graphics_pipeline(
    vertex,
    fragment,
    GPU.GraphicsPipelineSettings(color_targets:targets)
)

var commands = device.commands()
if var pass = commands.render(surface) {
    pass.bind(pipeline)
    pass.vertex_buffer(0, vertices)
    pass.draw(3)
    pass.finish()
}
commands.submit()
```

`GraphicsPipelineSettings` exposes vertex layouts and attributes, primitive
topology, rasterization, multisampling, depth/stencil state, blending, and up
to eight color-target formats. A render pass can bind vertex and index
buffers, samplers, storage resources, viewport and scissor state, then issue
direct, indexed, instanced, or indirect draws.

Uniform bytes are pushed on the command buffer before the draw that consumes
them with `vertex_uniform()` or `fragment_uniform()`.

## Render offscreen and compose

`ColorTarget` and `DepthTarget` make load/store intent explicit. Unspecified
color targets clear then preserve; unspecified depth/stencil operations clear
depth and discard depth/stencil afterward.

```sx
var commands = device.commands()
var pass = commands.render(GPU.ColorTarget(
    texture:color,
    clear:Color.black(),
    store:GPU.Store.preserve
))
pass.bind(pipeline)
pass.draw(3)
pass.finish()

commands.generate_mipmaps(color)
commands.blit(
    GPU.BlitRegion(texture:color, width:1280, height:720),
    GPU.BlitRegion(texture:output, width:1280, height:720)
)
commands.submit()
```

Resolve textures, mip levels, array layers, cycling, filter choice, flipping,
and clear/load policy remain available when composition needs finer control.

## Dispatch compute work

A compute pipeline declares its resource counts and thread-group size.
Writable resources are named when the pass begins; read-only samplers,
textures, and buffers are bound inside it.

```sx
var pipeline = device.compute_pipeline(
    GPU.ShaderFormat.msl,
    compute_source,
    GPU.ComputePipelineSettings(
        entry:"compute_main",
        read_write_storage_buffers:1,
        threads_x:64
    )
)

var buffers:GPU.WritableBuffer[] = []
buffers.append(GPU.WritableBuffer(buffer:particles))
var textures:GPU.WritableTexture[] = []

var commands = device.commands()
var pass = commands.compute(textures, buffers)
pass.bind(pipeline)
pass.dispatch(group_count, 1, 1)
pass.finish()
commands.submit()
```

Writable resources do not cycle by default, so a read-modify-write dispatch
sees their current contents. Set `cycle:true` only when the dispatch replaces
the resource and preserving its previous storage is unnecessary.

## Use the Bootstrap plugin

`GPUPlugin` installs `WindowPlugin`, creates one `GPU.Device` and one
`GPU.Surface` after the window exists, and removes them before the window is
destroyed:

```sx
use GFX.Bootstrap
use GFX.GPU
use GFX.Plugins.GPUPlugin

func render(device:@GPU.Device, surface:@GPU.Surface) {
    var commands = device.commands()
    commands.clear(surface)
    commands.submit()
}

Bootstrap.Application()
    ..install(GPUPlugin())
    ..add_system(Bootstrap.Schedule.render, render)
    ..run()
```

Plugin identity reuses an explicitly installed `WindowPlugin`; it does not
create a second window. `present_on_start:false` leaves the first frame to the
application. `frame_interval_ms:0` disables the temporary plugin pacing when
presentation or another renderer already paces the loop.

## Coverage contract

GFX targets the complete public surface of `SDL_gpu.h` from the SDL version
recorded by the package boundary. For SDL 3.4.10 this includes all 97 entry
points: device properties and inspection, resources, graphics and compute
pipelines, render/copy/compute commands, presentation, synchronization,
format queries and conversions, debug labels, and the GDK lifecycle hooks.

The `SDL_CreateGPURenderer` and `SDL_GPURenderState` family belongs to
`SDL_render.h`. It is a bridge to SDL's separate high-level 2D Render API and
is intentionally not part of `GFX.GPU`; a Silex renderer builds directly on
the GPU passes described here. Likewise, shader cross-compilation belongs to
the shader toolchain rather than SDL_GPU itself.

The current GFX boundary ships and executes Metal on `macos-arm64`. D3D12,
Vulkan, and GDK settings are represented so the public contract does not need
to change when their target boundaries are added, but backend execution must
still be validated on those platforms.

## Lifetime and validation rules

- A surface, resource, command buffer, pass, and fence retain the device they
  depend on.
- Resources from different devices cannot be mixed in one command stream.
- Only one render, copy, or compute pass can be active on a command buffer.
- Dropping a pass finishes it; explicit `finish()` keeps control flow visible.
- Dropping unsubmitted commands cancels them.
- Debug labels and groups can delimit GPU work without changing execution.
- `wait_until_idle()` is available for shutdown and diagnostics; fences are
  preferable for ordinary synchronization.
