# Read input and events by frame

`GFX.Input` owns the platform event pump. Call `update()` once at the beginning
of each frame; every observer can then read the same ordered snapshot without
consuming it.

```sx
use GFX.Input

var input = Input()
var running = true
while running {
    input.update()
    for event in input.events() {
        match event {
            quit(meta) => { running = false }
            window_close_requested(value) => { print(value.window.value) }
            file_dropped(value) => { print(value.data) }
            else => {}
        }
    }
}
```

`events()` remains valid until the next `update()`. Strings, MIME lists,
candidate lists and sensor samples are copied out of SDL before the snapshot is
published. `custom` retains only its safe kind, optional window and integer
code; `unknown` preserves the order of a future SDL event without exposing its
native union. Internal markers and private SDL ranges are not published.
Every payload uses `Input.Timestamp`, a monotonic nanosecond value rather than
an untyped platform integer.

The event enum classifies all 111 public built-in event constants in SDL
3.4.10: application lifecycle, displays, windows, keyboard and IME, mouse,
joysticks, gamepads, touch and pinch, pens, sensors, clipboard, drag-and-drop,
audio, camera and renderer recovery. Lifecycle notifications that SDL may send
only to watchers are copied through a private locked queue and deduplicated
against the ordinary event queue.

## Read continuous and transitional state

`is_down` is continuous. `is_pressed` and `is_released` cover only the latest
frame and are overloaded for `Input.Key` and `Input.MouseButton`. Every SDL
3.4.10 physical scancode has a named `Key` variant; `Key.unknown(code)` remains
observable and interrogeable for future scancodes. A logical keycode and UTF-8
text remain distinct from that physical position.

The state also exposes:

- current modifiers and keyboard/mouse focus;
- local and global mouse positions, accumulated motion and high-precision wheel;
- concatenated text input, current composition and copied IME candidates;
- keyboard and mouse identifiers and names;
- joystick axes, hats, trackballs, buttons, transitions and battery state;
- semantic gamepad axes/buttons, touchpads and latest sensor samples;
- active 64-bit touch contacts, complete pen state and autonomous sensors.

Input positions, deltas and precise wheel values use `Math.Vec2`, so they can
be transformed directly with the standard vector operations.

Continuous state survives `update()`. Transitions, motion, wheel and committed
text reset at the start of the next frame. A canceled touch is removed like a
released touch while remaining distinguishable in the event stream. Joystick
axis normalization maps `-32768` to `-1.0` and `32767` to `1.0`.

`is_quit_requested()` becomes true only for the global `quit` event. A window
close request remains targeted and never requests global shutdown by itself.

## Use InputPlugin

`GFX.Plugins.InputPlugin` owns and updates the same direct `Input`, but publishes
only `GFX.Input.State` as a read-only resource. Systems may all inspect the
snapshot; only the private driver pumps SDL.

```sx
use GFX.Bootstrap.Schedule
use GFX.Input
use GFX.Input.State as InputState

func controls(input:@InputState) {
    if input.is_down(Input.Key.left) { print("move left") }
}
```

`WindowPlugin` installs `InputPlugin`. Its automatic policy stops only for a
global quit or for a close request targeting its own window; manual mode leaves
both events and policy to the application.
