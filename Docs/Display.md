# Inspect displays

`GFX.Display.Displays` owns the platform session needed to keep display
identifiers meaningful while they are used.

```sx
use GFX.Display

var displays = Display.Displays()
let primary = displays.primary()
let info = displays.info(primary)
print(info.name)
```

`all()` and `primary()` return comparable copied `Display.Id` values. `info`
copies the name, logical bounds, usable bounds, natural and current
orientation, content scale and HDR state. `modes`, `desktop_mode` and
`current_mode` return owned `Display.Mode` values containing logical size,
pixel density and exact refresh-rate information.

Display and window rectangles are expressed in logical desktop coordinates.
Display bounds use `Math.Rect` and mode sizes use `Math.Vec2`, so they compose
directly with window, input and rendering calculations. Pixel dimensions are
obtained from `Window.pixel_size()`; do not multiply desktop coordinates by
density yourself. If a display disappears, its removal event remains
observable and a later operation using that stale identifier fails with a GFX
diagnostic.
