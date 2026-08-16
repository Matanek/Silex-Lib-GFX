# Extend rendering

`GFX.Rendering` is a composition host, not the owner of scenes. Its `Renderer`
exposes the `FrameGraph`, output texture, and pass registration. A third-party
extension can register a pass, declare its dependencies, and retrieve its own
resources from `Application`.

```silex
use GFX.Application
use GFX.GPU
use GFX.Rendering.Renderer

func draw(pass:@GPU.RenderPass, application:@Application) {
    // The pass retrieves its extension's private resources here.
}

var renderer = Renderer()
let scene = renderer.add_pass("Alternative.Scene", draw)
let overlay = renderer.add_pass("Alternative.Overlay", draw)
renderer.graph().depends(overlay, scene)
renderer.graph().require_compiled()
```

Custom shaders belong to the extension that defines the pass:

```silex
let program = GPU.ShaderProgram.hlsl(file:"Shaders/Scene.hlsl")
```

This extension requires no `internal` access to `GFX.Rendering`.

A pass that performs depth testing requests the shared frame depth target when
it is registered:

```silex
renderer.add_pass("Alternative.Scene3D", draw, depth:true)
```

The depth texture is also exposed by `depth_texture()` for frame-graph
dependencies. Camera, mesh, material, and lighting policy still belong to the
scene domain or to the extension, never to `GFX.Rendering`.
