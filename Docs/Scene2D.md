# GFX.Scene2D

`GFX.Scene2D` owns the data that a user or alternative renderer must name to
describe a 2D scene: `Transform`, `Camera`, `Drawing`, `Sprite`, `Overlay`,
`Grid`, and `Sampling`. The domain already carries the dimension, so
declarations remain unsuffixed.

```silex
use GFX.Scene2D.Camera as Camera2D
use GFX.Scene2D.Drawing as Drawing2D
use GFX.Scene2D.Sprite as Sprite2D
use GFX.Scene2D.Transform as Transform2D
```

`Drawing` places a retained `GFX.Canvas` in the 2D world through a
`Transform`. Drawings that share one authored value also share their cached
geometry and are rendered as instances. `Overlay` presents the same kind of
content in logical window coordinates instead. `Scene2D.Plugin` installs its
ECS, asset, and rendering dependencies and registers the Scene2D pass in the
public `GFX.Rendering.Renderer` frame graph. An alternative renderer can read
`snapshot()` and `revision()` from either placement component instead of
depending on the built-in GPU cache.

```silex
use GFX.Canvas
use GFX.ECS
use GFX.Scene2D
use STD.Math

var canvas = Canvas()
world.spawn(ECS.EntityRecipe()
    ..with(Scene2D.Transform(position:Math.Vec2(40.0, 20.0)))
    ..with(Scene2D.Drawing(canvas, 320, 180))
)
world.spawn(ECS.EntityRecipe()
    ..with(Scene2D.Overlay(canvas, 320, 180)
        ..anchor = Math.Vec2(0.5)
        ..pivot = Math.Vec2(0.5)
    )
)
```

Its built-in shaders live under `Shaders/Scene2D/`: `Drawing.hlsl`,
`Grid.hlsl`, and `Sprite.hlsl`. They are neither moved into `GFX.Rendering` nor
treated as a mandatory API. An extension can read the public scene data and
provide its own shader with `GFX.GPU.ShaderProgram.hlsl`.
