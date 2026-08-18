# Present visual content with GFX.Viewer

`GFX.Viewer` presents visual content in a native window. Images retain their
pixel representation, while a `GFX.Canvas` is retained and rendered directly
as Scene2D vector geometry. Viewer is a small inspection and example utility,
not an image asset store.

```sx
use GFX.Viewer

Viewer.show(image, "Generated image")
```

Present an authored canvas without rasterizing it first:

```sx
use GFX.Canvas
use GFX.Viewer

var drawing = Canvas()
drawing.paint(func(painter:&Canvas.Painter) {
    // Paint vector shapes and text.
})

Viewer.show(drawing, 960, 640, "Generated chart")
```

The drawing fills the viewport and follows the window continuously while it is
resized. Scene2D retains its vector geometry; text is prepared at the current
window density.

`Viewer.show` blocks until the window closes and installs the required window,
input, and GPU capabilities internally. For an image it uploads RGBA8 pixels,
preserves their aspect ratio, and uses `Shaders/Viewer/Image.hlsl`. For a
Canvas it installs the retained Scene2D path and sizes its overlay from the
current viewport.

`Settings.smooth` applies only to image sampling. Canvas presentation keeps the
retained vector path regardless of that setting.

Small images are centered at their native resolution; Viewer scales down when
necessary but does not enlarge pixels implicitly. A caller that wants an
enlarged image remains in control of that resampling decision.

Applications that update an image over time can compose `Viewer.Plugin` and
replace the public `Viewer.View` resource from a system:

```sx
use GFX.Application
use GFX.Viewer

func update(view:&Viewer.View) {
    view.replace(next_image())
}

Application()
    ..add_plugin(Viewer.Plugin(initial_image))
    ..add_system(Application.Schedule.update, update)
    ..run()
```

The viewer remains separate from `GFX.Canvas`: Canvas authors drawing
intentions, while Viewer only chooses how received content is presented. An
image uses the image presentation path; a Canvas uses the retained Scene2D
path.
