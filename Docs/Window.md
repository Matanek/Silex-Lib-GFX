# Own and control a GFX window

`GFX.Window` owns one platform window and keeps the private platform session
alive. The public surface contains GFX values and intentions, never an SDL
handle, flag, property name or encoded position.

```sx
use STD.Math
use GFX.Window

var window = Window(Window.Settings()
    ..title = "Silex"
    ..width = 1280
    ..height = 720
    ..resizable = true
    ..hidden = false
)
```

Creation settings also cover minimized/maximized startup, always-on-top,
transparency, focusability and utility windows. Contradictory startup states
are rejected before SDL is called. Create and use windows on the main thread;
the last reference destroys the native window automatically.

## Placement, dimensions and fullscreen

Positions and logical sizes use `Math.Vec2`; rectangles use `Math.Rect` with
`x`, `y`, `w` and `h`. `pixel_size()` is the drawable pixel size;
`pixel_density()` is the ratio between pixels and logical coordinates.
`display_scale()` is the UI content scale of the current display. Values sent
to integer platform operations are truncated with `Math.trunc`; invalid,
non-finite or out-of-range dimensions are rejected.

`position`, `set_position`, `center`, `display`, `safe_area` and `borders`
cover placement. Minimum and maximum sizes and the aspect-ratio interval are
optional constraints: `null` means absent, never a sentinel size. Fullscreen
separates desktop fullscreen from an optional copied `Display.Mode` selected
with `set_fullscreen_mode`.

`borders()` returns `(top:int, left:int, bottom:int, right:int)`, while
`aspect_ratio()` returns `(minimum:float, maximum:float)?`. Their named tuple
members remain directly available to completion without introducing nominal
geometry types local to Window.

## Presentation and interaction

`state()` reads visible, fullscreen, minimized, maximized, occluded, bordered,
resizable, always-on-top, transparent, focusable and focus/grab/modal facts in
one operation. Setters request bordered, resizable, always-on-top, focusable,
opacity, mouse grab, keyboard grab and relative mouse mode independently.
Opacity and progress values outside `[0.0, 1.0]` are rejected.

Mouse confinement uses an optional local logical rectangle; `warp_mouse`
places the pointer in local coordinates. Text input is explicitly started and
stopped on a window. `TextInputSettings` describes content kind,
capitalization, autocorrection and multiline input. The editing rectangle and
cursor are readable, composition can be cleared, and virtual-keyboard
visibility is observable. Committed text and IME composition arrive through
the single `Input` stream.

## Hierarchy, modal windows and system attention

`set_parent`, `clear_parent` and `parent` retain a safe GFX relationship. A
cycle, self-parenting or modal state without a parent is rejected. The child
retains its parent; detaching or destroying it does not destroy the parent.

Popups use a distinct factory and require a parent, a relative rectangle and a
`menu` or `tooltip` intention:

```sx
var popup = Window.popup(
    parent,
    Math.Rect(8.0, 24.0, 240.0, 180.0),
    Window.PopupKind.menu
)
```

`request_attention` distinguishes brief attention, attention until focus, and
canceling attention. System progress distinguishes none, indeterminate,
normal, paused and error. `show_system_menu` takes an explicit local position.
Unsupported platform operations fail with a targeted GFX panic rather than
silently pretending success.

`Plugins.Window` creates this same `Window`, installs `Plugins.Input`, and applies
automatic or manual close policy. A close request for another window never
stops the application.

```sx
use GFX.Plugins
use GFX.Window

application.install(Plugins.Window(Plugins.Window.Settings()
    ..title = "Viewer"
    ..close_behavior = Window.PluginCloseBehavior.manual
))
```
