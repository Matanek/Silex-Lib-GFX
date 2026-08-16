# GFX

GFX is Silex's modular graphics and application library. A single package
provides the application runtime, windows, input, GPU access, the frame graph,
rendering, 2D and 3D scenes, drawing, assets, ECS, audio, and WebView support.
`GFX.Viewer` provides a small image presentation utility for generated assets
and examples.

```text
silex install GFX
```

```silex
use GFX.Application
use GFX.Window

func main() {
    Application()
        ..add_plugin(Window.Plugin())
        ..run()
}
```

The domains remain independent in the API (`GFX.Scene2D`, `GFX.Scene3D`,
`GFX.GPU`, and so on), but they are distributed together with their shaders,
examples, documentation, and native artifacts. SDL is private infrastructure
and does not appear as a public module.

See [Docs/Architecture.md](Docs/Architecture.md) for domain ownership and
extension points.
