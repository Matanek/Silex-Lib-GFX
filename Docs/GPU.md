# Draw with the GPU

`GFX.GPU` presents GPU work as a short story: create a device, attach the
window, record a frame, describe its rendering, then submit it. SDL and its
native handles remain behind the package boundary.

## Start with a clear color

The device owns GPU execution and a surface attaches it to a window:

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

`clear` records a render pass; `submit` presents it. `clear` returns `false` when the window has
temporarily no drawable image, for example while minimized; that is a normal
presentation state rather than an error.

## Open the frame when more control is needed

The same objects open a render pass when more control is needed:

```sx
var commands = device.commands()
if let pass = commands.render(surface, Color.black()) {
    // Future pipeline, binding, viewport, and draw operations live here.
    pass.finish()
}
commands.submit()
```

A render pass must finish before its commands are submitted. Dropping the pass
finishes it; an explicit `finish()` keeps the order visible in code. Dropping
unsubmitted commands cancels them. A surface and every command buffer retain
their device, so the device cannot disappear while GPU work still refers to
it.

The lower-level construction remains available when an application wants to
own each lifetime explicitly:

```sx
var device = GPU.Device(GPU.DeviceSettings(debug:true))
var surface = device.present(
    window,
    GPU.SurfaceSettings(present_mode:GPU.PresentMode.mailbox)
)
var commands = device.commands()
commands.clear(surface, Color.blue_950())
commands.submit()
```

The synchronized presentation mode and standard color space are the portable
defaults. Immediate, mailbox, linear, extended-HDR, and HDR10 modes remain
explicit choices because support depends on the window, device, and platform.

## Use the Bootstrap plugin

`GPUPlugin` installs `WindowPlugin`, creates one `GPU.Device` and one
`GPU.Surface` after the window exists, presents an initial black frame by
default, and removes them before the window is destroyed. Until a renderer
provides natural GPU pacing, the Plugin also limits the Bootstrap loop to about
60 iterations per second:

```sx
use GFX.Bootstrap
use GFX.Color
use GFX.GPU
use GFX.Window
use GFX.Plugins.GPUPlugin

func render(device:@GPU.Device, surface:@GPU.Surface) {
    var commands = device.commands()
    commands.clear(surface, Color.indigo_900())
    commands.submit()
}

Bootstrap.Application()
    ..install(GPUPlugin(GPUPlugin.Settings(
        window:Window.Settings(title:"GPU application")
    )))
    ..add_system(Bootstrap.Schedule.render, render)
    ..run()
```

Applications that already install `WindowPlugin` should do so before
`GPUPlugin`; plugin identity keeps the existing window configuration.

An application that wants to own even the first presentation can set
`present_on_start:false` while preserving device, surface, window, and shutdown
management. A renderer already paced by presentation can also set
`frame_interval_ms:0`; the default is 16 milliseconds.

This first vertical slice deliberately establishes presentation and render-pass
lifetime before adding shaders, pipelines, buffers, textures, samplers, copy
passes, compute passes, fences, and readback. Those capabilities will extend
the same command story rather than introduce a parallel API.
