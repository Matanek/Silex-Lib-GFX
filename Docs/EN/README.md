# GFX

GFX is Silex's modular graphics and application library. Its stable core
provides the application runtime, windows, input, the system clipboard, shared
values, and the private SDL3 platform boundary.

```silex
use GFX.Application
use GFX.Window

func main() {
    Application()
        ..add_plugin(Window.Plugin())
        ..run()
}
```

Domains remain independent in the public API. Official extensions include
Animation, Assets, Audio, Canvas, ECS, GPU, Rendering, Scene2D, Scene3D, Stats,
UI, Viewer, and WebView. Installing the GFX suite installs its direct
extensions, while an application manifest still declares every package whose
modules it imports. Physics is installed separately. `GFX.UI.Terminal` is a
nested UI extension.

SDL is private infrastructure and never appears as a public module. Extension
packages contribute only their owned declarations to the open `Components`,
`Resources`, and `Plugins` catalogs.

## Guides

- [Application](Application.md)
- [Architecture and extension model](Architecture.md)
- [Clipboard](Clipboard.md)
- [Color](Color.md)
- [Input](Input.md)
- [Window](Window.md)

Complete application-window and direct-input demonstrations live in
[Silex-Examples](https://github.com/Matanek/Silex-Examples).
