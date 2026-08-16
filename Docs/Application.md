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

`Application.Time` provides `FrameTime`. `Application.FramePacing` limits a
loop that does not already have its own presentation mechanism.

## Frame-rate overlay

`Plugins.FPSCounter` displays the measured rendering rate without requiring the
application to manage text, timing, or a Scene2D overlay itself. It composes the
required rendering capabilities and can be positioned at any viewport anchor.

```silex
use GFX.Application
use GFX.Plugins

Application()
    ..add_plugin(Plugins.Window())
    ..add_plugin(Plugins.FPSCounter(Plugins.FPSCounterSettings()
        ..anchor = Plugins.FPSCounterAnchor.bottom_right
    ))
    ..run()
```
