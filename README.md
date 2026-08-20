# GFX

GFX is Silex's modular graphics and application library. Its stable core
provides the application runtime, windows, input, GPU access, the frame graph,
rendering, 2D and 3D scenes, drawing, assets and ECS.
`GFX.Viewer` presents generated images or retained Canvas drawings in a native
window for inspection and examples.

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

`GFX.Animation`, `GFX.Audio` and `GFX.WebView` are official suite extensions
with their own packages and release cycles. An explicit `silex install GFX`
installs them with the suite, while an application manifest declares directly
every package whose modules it imports. Their declarations appear in the open
GFX catalogs without moving ownership into the parent package.

Physics remains an optional official extension. Applications that need it
install `GFX.Physics` separately; its declarations contribute to the open
components and resources catalogs in the same ownership-preserving way.

See [Docs/Architecture.md](Docs/Architecture.md) for domain ownership and
extension points.
