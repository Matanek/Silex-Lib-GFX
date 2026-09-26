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
that preparation boundary with `add_plugin`.

A plugin whose needs change during execution can call
`application.require_plugin(plugin)` from an Application callback. The request
is resolved at the end of the current stage, after all its systems finish.
Only newly introduced `initialize` and `startup` callbacks that are already due
are executed; existing services keep their state. The system plan is rebuilt
only when dependencies change. During shutdown, the requesting plugin stops
before its dependencies. Requests during shutdown are rejected. An instance
explicitly configured before preparation remains authoritative. Outside a
callback, `prepare()` or the next stage processes the request.

`Resources.scope()` creates an empty child store. A local resource shadows a
parent resource of the same type; a locally missing read consults the parent
without copying its value. `remove` and `clear` affect local values only. This
primitive supports shorter-lived execution contexts, including scenes from the
`GFX.Application` package.

`Application.Time` provides `FrameTime`. `Application.FramePacing` limits a
loop that does not already have its own presentation mechanism.

The [application-window demonstration](https://github.com/Matanek/Silex-Examples/blob/main/Sources/ApplicationWindow.sx)
is the smallest complete windowed application. It adds frame pacing because an
otherwise empty application has no renderer or presentation step to regulate
its loop.

Development overlays such as the FPS and performance panels belong to the
official `GFX.Stats` suite package. Application remains responsible only for
plugin composition and scheduling.

## Pause the game

Every Application owns an `Application.Simulation` resource. Its `pause()`,
`resume()` and `is_paused()` methods control game updates while the loop keeps
running. `Application.Controller.stop()` still exits that loop and runs the
shutdown stages.

This program toggles pause and resume with Escape:

```silex
use GFX.Application
use GFX.Input
use GFX.Plugins

func pause_menu(input:@Input.State, simulation:&Application.Simulation) {
    if input.is_pressed(Input.Key.escape) {
        if simulation.is_paused() { simulation.resume() }
        else { simulation.pause() }
    }
}

func main() {
    Application()
        ..add_plugin(Plugins.Window())
        ..add_system(Application.Schedule.update, pause_menu,
            process_mode:Application.ProcessMode.always)
        ..run()
}
```

`add_system` and `add_after_system` accept an optional third `process_mode`
argument, both for callbacks receiving the Application and for systems with
injected parameters:

| Mode | Execution |
| --- | --- |
| `inherit` (default) | Updates pause; rendering continues. |
| `pausable` | Only while the simulation is active. |
| `always` | With or without a pause, for example to listen for Escape. |
| `when_paused` | Only during a pause, for example for the menu. |
| `disabled` | No execution in recurring stages. |

This rule covers `pre_update`, `update`, `post_update` and `render`.
`initialize`, `startup`, `shutdown` and `finalize` always execute. Built-in
services keep processing input, window closure, rendering, UI hosted by Viewer
and WebView messages. Already issued ECS commands still flush. Pausing does not
lock the World: `always` systems can still modify it. Audio already playing
also continues.

The decision is taken before each group of systems that can execute together.
A request does not interrupt work already dispatched; the next group observes
the new state. `Application.should_process(mode, paused)` lets a plugin apply
the same rules to its own objects; outside a hierarchy or rendering context,
`inherit` is equivalent to `pausable` in this helper.

With `Application.Time`, `Simulation.delta()` is zero while paused and
`Simulation.elapsed()` stays frozen. The clock advances once in `pre_update`;
resuming uses the current delta without accumulating the pause duration.
`FrameTime` remains the application's real time for UI and services. A plugin
can either leave its systems paused by default or declare them `always` and
filter its objects, as Nodes and Animation do.
