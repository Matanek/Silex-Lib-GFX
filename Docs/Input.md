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

`Input.Plugin` publishes the state in `Application`. Transitions, motion,
scrolling, and text belong to one frame; continuous key, button, and device
state survives the next update.
