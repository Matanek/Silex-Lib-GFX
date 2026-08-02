# Compose rendering capabilities

GFX uses one retained renderer for every visual capability. Install the 2D or
3D rendering plugin according to the application's intent; both compose into
the same renderer and presentation frame.

```sx
use GFX.Bootstrap.Application
use GFX.Plugins.Rendering2DPlugin
use GFX.Plugins.Rendering3DPlugin
use GFX.Plugins.WindowPlugin

Application()
    ..install(WindowPlugin(WindowPlugin.Settings(title:"Renderer")))
    ..install(Rendering3DPlugin())
    ..install(Rendering2DPlugin())
    ..run()
```

The renderer compiles its installed capabilities into this execution order:

1. 3D scene;
2. post-processing;
3. 2D scene and overlays.

This order is derived by the internal FrameGraph and does not depend on the
order in which the plugins are installed. `Rendering2DPlugin` and
`Rendering3DPlugin` both install the common
`RenderingPlugin`, which provides the GPU device, presentation surface,
renderer, and frame submission. `WindowPlugin` is installed explicitly before
the rendering capability and provides the window and input. Installing both
rendering capabilities still creates one presentation frame.

The public `Rendering.Renderer` resource exposes completed-frame statistics.
FrameGraph resources, passes, GPU command ownership, and pass registration
remain internal to GFX. Applications express rendering intentions by installing
capability plugins; they do not assemble the graph. Applications that
intentionally need explicit GPU control can continue to use `GFX.GPU` directly
without installing the retained renderer.

Each graph pass declares the textures it reads, writes, or updates. Compilation
orders producers before consumers and rejects dependency cycles, unused created
resources, and reads of created textures without a writer. The graph tracks the
first and last use of created textures. Compatible transient textures whose
lifetimes do not overlap share one physical GPU slot.

The swapchain color is imported into the graph. The shared depth texture is a
transient graph resource allocated only when 3D rendering is installed. A 2D
application therefore creates no depth texture. The graph recreates its
physical textures when the viewport changes.

Before each retained frame, the renderer collects active `Camera2D` and
`Camera3D` components from the ECS world, orders each kind by `order`, and
derives its view and projection matrices from the matching transform. The
resulting camera frame is shared with the 3D, post-processing, and 2D passes.
`Renderer.stats()` reports how many 2D and 3D cameras were retained for the
completed frame.

The 3D pass draws `Mesh3D` and `Sprite3D` components with a depth buffer. Opaque
meshes write depth; 3D sprites test depth without writing it. The final 2D pass
draws `Sprite2D` components by ascending `layer`, then by `depth`, without depth
testing. Sprite pixels use alpha blending.

Mesh and image assets are uploaded lazily. Their handles carry a generation so
removed assets cannot silently resolve to a newer resource. Replacing an asset
increments its revision; the GPU cache uploads that resource again on the next
frame. Unchanged assets reuse their buffers or texture. `Renderer.stats()`
exposes `meshes_3d()`, `sprites_2d()`, `sprites_3d()`, and `gpu_uploads()` so an
application can observe this work without manipulating GPU resources directly.
`frame_graph_passes()`, `frame_graph_resources()`, and
`frame_graph_transient_slots()` expose the compiled graph's cost without
exposing its implementation types.

This retained-rendering contract establishes the same composition model as
Foundation. Lights, shadows, scene targets, and post-processing effects can
extend this graph without changing how an application selects 2D and 3D
capabilities.
