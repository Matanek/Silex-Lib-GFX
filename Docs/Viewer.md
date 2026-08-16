# Display images with GFX.Viewer

`GFX.Viewer` presents a `GFX.Assets.Image` in a native window. It is a small
inspection and example utility, not a scene renderer and not an image asset
store.

```sx
use GFX.Viewer

Viewer.show(image, "Generated image")
```

`Viewer.show` blocks until the window closes. It installs the window, input,
and GPU capabilities internally, uploads the RGBA8 image, preserves its aspect
ratio, and uses `Shaders/Viewer/Image.hlsl` to display it.

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

The viewer is deliberately separate from `GFX.Canvas`: drawing creates or
rasterizes images, while the viewer only presents an image it receives.
