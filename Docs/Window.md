# GFX.Window

`GFX.Window` owns a system window and exposes portable intentions: logical
size, density, fullscreen mode, hierarchy, text input, attention, and system
progress. No SDL handle is public.

```silex
use GFX.Window

var window = Window(Window.Settings(
    title:"Silex",
    width:1280,
    height:720
))
```

`Window.Plugin` manages the same capability within `Application`. The
`presentation_handle()` is a deliberate escape hatch for an extension that
must attach a system surface, such as `GFX.WebView`; the window retains
ownership and the handle is valid only during its lifetime.

Displays are available through `GFX.Window.Display`. `GFX.Application` owns
loop pacing: that setting is not part of the Window domain.
