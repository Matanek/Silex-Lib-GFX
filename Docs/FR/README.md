# GFX

GFX est la bibliothèque modulaire d’applications et de graphisme de Silex. Son
socle stable fournit la boucle d’application, les fenêtres, les entrées, le
presse-papiers, des valeurs communes et la frontière SDL3 privée.

```silex
use GFX.Application
use GFX.Window

func main() {
    Application()
        ..add_plugin(Window.Plugin())
        ..run()
}
```

Les domaines restent indépendants dans l’API publique. Les extensions
officielles comprennent Animation, Assets, Audio, Canvas, ECS, GPU, Rendering,
Scene2D, Scene3D, Stats, UI, Viewer et WebView. Installer la suite GFX installe
ses extensions directes, mais le manifeste d’une application déclare toujours
chaque package dont elle importe les modules. Physics s’installe séparément.
`GFX.UI.Terminal` est une extension imbriquée de UI.

SDL est une infrastructure privée et n’apparaît jamais comme module public.
Les extensions ne contribuent que leurs propres déclarations aux catalogues
ouverts `Components`, `Resources` et `Plugins`.

## Guides

- [Application](Application.md)
- [Architecture et modèle d’extension](Architecture.md)
- [Presse-papiers](Clipboard.md)
- [Couleur](Color.md)
- [Entrées](Input.md)
- [Fenêtre](Window.md)

Les démonstrations complètes de fenêtre et d’entrées directes vivent dans
[Silex-Examples](https://github.com/Matanek/Silex-Examples).
