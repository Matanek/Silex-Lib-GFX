# GFX.Input

`GFX.Input` converts the SDL event pump into copied GFX values and reusable
frame state. Events expose neither native unions nor temporary pointers.

```silex
use GFX.Input

if input.is_down(Input.Key.left) { print("left") }
for event in input.events() {
    match event {
        window_close_requested(value) => { print(value.window.value) }
        else => {}
    }
}
```

`Input.Plugin` publishes the state in `Application` and remains installable on
its own. `Window.Plugin` installs it automatically because window lifecycle
events use the same portable event stream. Transitions, motion, scrolling, and
text belong to one frame; continuous key, button, and device state survives the
next update.

Several `Input` contexts may coexist in one process. Each receives a copy of
the same platform event stream and keeps its own frame state, so windows owned
by separate Bundles never compete for the SDL queue.

Outside `Application`, create one `Input`, call `wait()` when the program may
sleep, then call `update()` exactly once before reading that turn's state and
events. The [direct window/input demonstration](https://github.com/Matanek/Silex-Examples/blob/main/Sources/DirectWindowInputLoop.sx)
shows this manual event loop, including window-close and Escape handling.
