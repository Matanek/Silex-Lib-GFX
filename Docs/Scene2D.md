# GFX.Scene2D

`GFX.Scene2D` owns the data that a user or alternative renderer must name to
describe a 2D scene: `Transform`, `Camera`, `Canvas`, `Sprite`,
`Grid`, and `Sampling`. The domain already carries the dimension, so
declarations remain unsuffixed.

```silex
use GFX.Canvas
use GFX.Components
```

`Components.Canvas` places retained `GFX.Canvas` content through a
`Components.Transform2D`. World coordinates are the default and use a centered
camera supplied by Scene2D when the application does not create one. An
explicit `Components.Camera2D` replaces that default when the scene needs to
move, zoom, or select a camera.

The same component can use logical window coordinates through
`Components.CanvasSpace.viewport`. Its `anchor` selects a point in the
viewport, while `Transform2D.position` remains the offset that animation and
other systems modify. Canvases that share one authored value also share their
cached geometry and are rendered as instances.

```silex
use GFX.Canvas
use GFX.Components
use GFX.ECS
use STD.Math

var drawing = Canvas()
world.spawn(ECS.EntityRecipe()
    ..with(Components.Transform2D(position:Math.Vec2(40.0, 20.0)))
    ..with(Components.Canvas(drawing, 320, 180))
)
world.spawn(ECS.EntityRecipe()
    ..with(Components.Transform2D())
    ..with(Components.Canvas(drawing, 320, 180)
        ..space = Components.CanvasSpace.viewport
        ..anchor = Math.Vec2(0.5)
        ..pivot = Math.Vec2(0.5)
    )
)
```

`Drawing` and `Overlay` remain available for compatibility while
`Components.Canvas` is evaluated as the primary API. `Scene2D.Plugin` installs
its ECS, asset, and rendering dependencies and registers the Scene2D pass in
the public `GFX.Rendering.Renderer` frame graph. An alternative renderer can
read `snapshot()` and `revision()` from the placement component instead of
depending on the built-in GPU cache.

Its built-in shaders live under `Shaders/Scene2D/`: `Drawing.hlsl`,
`Grid.hlsl`, and `Sprite.hlsl`. They are neither moved into `GFX.Rendering` nor
treated as a mandatory API. An extension can read the public scene data and
provide its own shader with `GFX.GPU.ShaderProgram.hlsl`.
