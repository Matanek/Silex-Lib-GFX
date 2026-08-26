# GFX.Application

`GFX.Application` composes typed resources, scheduled systems, and ordinary
plugins. It does not select a window, renderer, or scene model.

```silex
use GFX.Application

func update(controller:&Application.Controller) {
    controller.stop()
}

Application()
    ..add_plugin(Application.Time())
    ..add_plugin(Application.FramePacing(60))
    ..add_system(Application.Schedule.update, update)
    ..run()
```

A plugin implements `Application.Plugin`, has a stable identifier, and
explicitly registers the resources or systems it provides. Stages run from
`initialize` to `finalize`; `startup`, `update`, `render`, and `shutdown`
describe the recurring lifecycle. Systems declare their access through
injected parameters so the application can order or parallelize compatible
work.

`add_plugin` records explicit plugin instances until `run`. During resolution,
calls to `add_plugin` from a plugin's `build` install its dependencies
recursively. An explicit instance always replaces the dependency's fallback
instance, even when it was added later, so plugin configuration does not depend
on call order. Each plugin identifier is built only once.

`run` performs this preparation automatically. Code that needs a plugin-owned
resource before starting the application can call `prepare()` explicitly after
adding every plugin, then access `resources()`. No plugin can be added after
that preparation boundary.

`Application.Time` provides `FrameTime`. `Application.FramePacing` limits a
loop that does not already have its own presentation mechanism.

[ApplicationWindow.sx](../Examples/ApplicationWindow.sx) is the smallest
complete windowed application. It adds frame pacing because an otherwise empty
application has no renderer or presentation step to regulate its loop.

Development overlays such as the FPS and performance panels belong to the
official `GFX.Stats` suite package. Application remains responsible only for
plugin composition and scheduling.
