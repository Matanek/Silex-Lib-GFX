# Read input by frame

`GFX.Input` owns one input stream and keeps its platform `Session` alive. Call
`update()` once at the beginning of each frame in a direct application:

```sx
use GFX.Session
use GFX.Input

func main() {
    var session = Session()
    var input = Input(session)
    var running = true

    while running {
        input.update()

        for event in input.events() {
            match event {
                quit => { running = false }
                window_close_requested(window) => { running = false }
                else => {}
            }
        }

        if input.is_pressed(Input.Key.space) {
            print("space pressed")
        }
    }
}
```

`is_down(value)` describes continuous state. `is_pressed(value)` and
`is_released(value)` describe transitions observed during the latest
`update()`. Each operation is overloaded for `Input.Key` and
`Input.MouseButton`, so keyboard and mouse share the same vocabulary.
`is_quit_requested()` becomes true after a quit or window-close request and
remains true for the lifetime of `Input`.

Repeated key-down events do not create another entered transition, but remain
available as `key_pressed` events whose `KeyEvent.repeated` field is true.

`events()` returns a shared view valid until the next `update()`. Reading it is
not destructive, so several systems can observe the same frame. Only one
`Input` may be active because the platform event queue belongs to the process.
Create and update it on the main thread.

## Use InputPlugin

`GFX.Plugins.InputPlugin` owns and updates the same direct `Input` class, but
publishes only its read-only `GFX.Input.State` as a resource. It installs
`SessionPlugin`, creates `Input` at startup, updates it after ordinary
`Schedule.pre_update` systems and removes its state and private driver before
the session at shutdown:

```sx
use GFX.Bootstrap.Application
use GFX.Bootstrap.Schedule
use GFX.Input
use GFX.Input.State as InputState
use GFX.Plugins.InputPlugin

func controls(input:@InputState) {
    if input.is_down(Input.Key.left) {
        print("move left")
    }
}

func main() {
    var application = Application()
        ..install(InputPlugin())
        ..add_system(Schedule.update, controls)
        ..run()
}
```

Without the local alias, the same parameter can be written
`input:@Input.State`. `State` exposes the observation methods and `events()`,
but no `update()`: only the plugin's private driver may consume the platform
event queue.

`InputPlugin` alone does not stop the application on `quit` or
`window_close_requested`; it remains a neutral state producer. `WindowPlugin`
installs it as a dependency and applies automatic closing by default. Select
`WindowPlugin.CloseBehavior.manual` when application systems must decide what
to do with the close request.
