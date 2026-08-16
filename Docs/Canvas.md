# GFX.Canvas

`GFX.Canvas` describes 2D drawing without imposing a renderer. A `Canvas`
records drawing intentions and exposes `paint`, `clear`, `rasterize`, and
inspection APIs directly. The same content can also be converted into geometry
by an alternative renderer.

```silex
use GFX.Color
use GFX.Canvas
use STD.Math

var canvas = Canvas()
canvas.paint(func(painter:&Canvas.Painter) {
    painter.fill(
        Canvas.Rect(Math.Vec2(), Math.Vec2(128.0, 48.0), 8.0),
        Canvas.Fill.solid(Color.indigo_600())
    )
    painter.text(
        "Silex",
        Math.Vec2(12.0, 10.0),
        Canvas.TextStyle(size:18.0, color:Color.white())
    )
})

let image = canvas.rasterize(128, 48)
```

Text uses `SDL3_ttf` behind the `Canvas.Font` API. GFX embeds a default font;
an application may also supply a path or encoded bytes. No SDL handle is
public.

## Reuse drawing intentions

`Canvas.commands()` exposes a copy of the public commands, `Path.steps()`
exposes the geometric segments, and `Canvas.vector_geometry()` produces a
GPU-independent mesh. These three levels let an extension interpret drawing
intentions, tessellate paths itself, or reuse the supplied tessellation.

```silex
for command in canvas.commands() {
    match command {
        fill_rect(value) => { print("rectangle") }
        text(value) => { print(value.value) }
        else => {}
    }
}
```

`Canvas.snapshot(width, height)` preserves geometry and caches the text layer
at the requested density. It is an optional optimization, not a required
representation for third-party renderers.

## Surface

`Canvas.Surface` is a mutable RGBA pixel surface. It accepts the same painting
commands, can compose images, and returns an `Assets.Image`. The
`CreateImage.sx`, `PaintLinearGradient.sx`, `RasterizeSurface.sx`, and
`RenderVectorText.sx` examples display their result through
`GFX.Viewer.show(image)`. Canvas remains independent from presentation: the
examples opt into the viewer after rasterization.

`ShapeGallery2D.sx` exercises the retained vector path instead. It places one
`Canvas` in a `GFX.Scene2D.Overlay`, so it exposes differences between CPU
rasterization and the built-in GPU renderer across lines, caps, joins, paths,
curves, analytic shapes, gradients, transparency, layering, and text.
