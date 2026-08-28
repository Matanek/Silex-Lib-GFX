# Architecture de GFX

`GFX` est le package socle et l’espace de noms racine. Ses capacités
fondamentales sont distribuées ensemble, tandis que les packages enfants
autorisés gardent leur propre cycle de publication.

```text
silex install GFX
```

Le manifeste d’une application déclare chaque package qu’elle importe.
Animation, Assets, Audio, Canvas, ECS, GPU, Rendering, Scene2D, Scene3D, Stats,
UI, Viewer et WebView sont membres de la suite. Physics évolue séparément et
UI.Terminal est autorisé par UI.

L’autorisation délègue un espace de noms sans en transférer la propriété. Une
fusion exacte n’est possible qu’avec `merge: true`, reste additive et refuse
les collisions de noms publics.

## Socle modulaire

```text
GFX
├── Application     loop, resources, systems, plugins, time, and pacing
├── Clipboard       operating-system UTF-8 text clipboard
├── Input           events, keyboard, and pointer
└── Window          windows, displays, and system presentation

GFX.Assets
└── Assets          portable images, models, sprite sheets, stores, and format adapters

GFX.GPU
└── GPU             devices, resources, pipelines, commands, compute, and presentation

GFX.ECS
└── ECS             world, entities, components, queries, and commands

GFX.Rendering
├── Renderer        generic rendering host and orchestration
└── FrameGraph      logical resources, passes, ordering, and aliasing

GFX.Scene2D
└── Scene2D         camera, transform, Canvas placement, sprite, grid, and 2D shaders

GFX.Scene3D
└── Scene3D         camera, viewport axis, mesh, material, light, selection, and 3D gizmos

GFX.Canvas
└── Canvas          vector drawing intentions, rasterization, surfaces, and text

GFX.UI
└── UI              declarative descriptions, controls, constraint layout, and retained Canvas rendering

GFX.UI.Terminal
└── UI.Terminal     application-console and PTY/ConPTY controls for UI trees
```

Chaque domaine possède ses valeurs, implémentations, ressources et points
d’extension. Rendering orchestre le FrameGraph générique, tandis que géométrie,
matériaux et shaders restent dans les scènes. Les packages officiels dépendent
seulement des capacités publiques du socle et contribuent leurs propres
déclarations aux catalogues ouverts.

## Vues parapluies

`GFX.Components`, `GFX.Resources` et `GFX.Plugins` regroupent les déclarations
souvent utilisées ensemble. Ce sont des vues de réexport, pas de nouveaux
propriétaires. Les suffixes dimensionnels y distinguent les vocabulaires 2D et
3D placés côte à côte.

```silex
use GFX.Components
use GFX.ECS
use GFX.Plugins
use GFX.Resources

func move_camera(time:@Resources.FrameTime, camera:&Resources.ViewportCamera3D) {
    camera.set_distance(camera.distance() + time.delta)
}

application.add_plugin(Plugins.Window(Plugins.Window.Settings()
    ..title = "GFX"
))
application.add_plugin(Plugins.ViewportCamera3D(
    Plugins.ViewportCamera3D.Settings()..distance = 12.0
))

world.spawn(ECS.EntityRecipe()
    ..with(Components.Transform3D())
    ..with(Components.Camera3D())
)
```

Le compilateur refuse les déclarations exécutables, les propriétés étrangères
et les collisions dans ces catalogues.

## Infrastructure native

SDL est privé. GFX possède SDL3 pour fenêtres, entrées et presse-papiers.
Canvas possède SDL3_ttf, Audio SDL3_mixer, GPU un alias privé de SDL3 et WebView
ses frameworks système.

```text
Package.json
Boundary/<target>/
└── SDL3

GFX.Canvas/Boundary/<target>/
└── SDL3_ttf -> GFX.SDL3

GFX.Audio/Boundary/<target>/
└── SDL3_mixer -> GFX.SDL3

GFX.GPU/Boundary/<target>/
└── SDL3 -> GFX.SDL3

GFX.Assets
└── SDL3 -> GFX.SDL3
```

Il n’existe volontairement aucun module public `GFX.SDL`. Une migration de SDL
reste un changement d’implémentation.

## Propriété des artefacts

Chaque domaine conserve tout ce qui permet de le comprendre, l’utiliser et le
remplacer.

```text
GFX.Scene3D/
├── Module/           domain API and implementation
├── Shaders/          shaders supplied by the domain
├── Assets/           distributed tone-mapping tables and models
├── Tests/            verified contract and isolated consumer
└── Docs/README.md    domain documentation
```

Cette règle couvre modules, shaders, assets, tests et documentation. Un
répertoire d’exemples restant dans un package est un reliquat de migration ;
les démonstrations promues appartiennent à Silex-Examples.

## Noms et extensions

Le domaine porte déjà sa dimension : les déclarations ne la répètent pas.

```silex
use GFX.Scene2D.Transform as Transform2D
use GFX.Scene3D.Transform as Transform3D
use GFX.Scene3D.Rotator as Rotator3D
```

Les extensions publiques peuvent fournir des shaders GPU, compiler un
FrameGraph, enregistrer des passes ou remplacer un renderer. Elles ne doivent
jamais dépendre d’une déclaration privée, d’un payload de packing ou d’un
handle SDL.

## Invariants

1. GFX reste le socle stable et autorise explicitement ses packages enfants.
2. Un domaine exprime une capacité utilisateur, pas une couche technique.
3. Chaque artefact appartient à son domaine.
4. Rendering reste générique.
5. Les fournisseurs natifs restent privés.
6. Les points d’extension sont publics et validés par des consommateurs.
7. Un domaine peut être extrait sans changer son chemin de module public.
