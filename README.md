# GFX

GFX is Silex's modular graphics and application library. Its stable core
provides the application runtime, windows, input, shared values, and the SDL3
platform boundary.

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
`GFX.GPU`, and so on), whether they live in the core or in an authorized child
package. SDL is private infrastructure and does not appear as a public module.

`GFX.Animation`, `GFX.Assets`, `GFX.Audio`, `GFX.Canvas`, `GFX.ECS`, `GFX.GPU`,
`GFX.Rendering`, `GFX.Scene2D`, `GFX.Scene3D`, `GFX.Stats`, `GFX.Terminal`,
`GFX.UI`, `GFX.Viewer`, and `GFX.WebView` are
official suite extensions with their own packages and release cycles. Assets
owns portable images, models, sprite sheets, their stores, and the current PNG
and glTF adapters. ECS owns
typed entities, queries, commands, and Application integration. Rendering owns
the generic renderer and its frame graph. GPU owns devices, resources,
pipelines, commands, compute, and window presentation. Viewer opens generated
images, Canvas drawings and interactive Canvas sessions through a direct
`show` API. GFX.UI provides declarative, type-oriented interface descriptions,
controls, constraint layout, retained Canvas commands and an input-driven
runtime independent from an application's ECS World. An
explicit `silex install GFX` installs them with the suite, while an application
manifest declares directly every package whose modules it imports. Extensions
contribute only the declarations intended for the open GFX catalogs; Viewer
keeps its direct API without adding plugin or resource aliases.

Physics remains an optional official extension. Applications that need it
install `GFX.Physics` separately; its declarations contribute to the open
components and resources catalogs in the same ownership-preserving way.

See [Docs/Architecture.md](Docs/Architecture.md) for domain ownership and
extension points.
