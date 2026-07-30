# Own a GFX window

`GFX.Window` is the direct lifetime boundary for one platform window. It keeps
the private platform runtime alive and does not depend on `GFX.Bootstrap`:

```sx
use GFX.Window

func main() {
    var settings = Window.Settings()
    settings.title = "Silex"
    settings.width = 1280
    settings.height = 720
    var window = Window(settings)
    window.show()
}
```

`Window.Settings` is deliberately mutable: completing after `settings.` exposes
all available options before the window is created. A cascade offers the same
discoverable configuration inline:

```sx
var window = Window(Window.Settings()
    ..title = "Silex"
    ..width = 1280
    ..height = 720
)
```

Create and use windows on the main thread. Invalid dimensions and platform
failures produce a targeted GFX panic. The last reference destroys the private
platform window automatically; there is no `close()` and no native handle in
the public API.

`Window.Id` is a comparable GFX value intended to associate future events with
their window. Its numeric `value` is suitable for logs but is not a native
address.

## Use WindowPlugin

`GFX.Plugins.WindowPlugin` creates the same direct `Window` at startup and
removes it at shutdown:

```sx
use GFX.Bootstrap.Application
use GFX.Plugins.WindowPlugin

func main() {
    var application = Application()
        ..install(WindowPlugin(WindowPlugin.Settings()
            ..title = "Silex"
        ))
        ..run()
}
```

The plugin pumps platform events during `Schedule.pre_update` so the window
remains responsive and installs `InputPlugin` as a dependency. By default, a
global quit request or a close request targeting its window stops the
application. No application-specific closing system is required.

Choose manual handling when the application needs to confirm the request or
apply a different lifecycle policy:

```sx
var settings = WindowPlugin.Settings()
    ..title = "Editor"

var application = Application()
    ..install(WindowPlugin(
        settings,
        WindowPlugin.CloseBehavior.manual
    ))
    ..run()
```

Manual handling leaves every event observable through `GFX.Input.State` and
does not stop the application. Unless `WindowPlugin.Settings.hidden` is true, the
plugin explicitly shows, raises and synchronizes the window at startup instead
of relying on the platform's implicit creation behavior.
