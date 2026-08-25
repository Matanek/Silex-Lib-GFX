# GFX architecture

`GFX` is the stable core package and root namespace for its domains. Its
fundamental application and graphics capabilities are distributed together,
while authorized child packages can keep an independent release cycle:

```text
silex install GFX
```

This command installs the core API and exact extensions selected for the GFX
suite. In source code, `GFX` remains the namespace parent. Applications with a
manifest still declare every package whose modules they import directly.

Capabilities may be distributed as explicitly authorized child packages.
`GFX.Animation`, `GFX.Assets`, `GFX.Audio`, `GFX.Canvas`, `GFX.ECS`, `GFX.GPU`,
`GFX.Rendering`, `GFX.Scene2D`, `GFX.Scene3D`, `GFX.Stats`, `GFX.Terminal`,
`GFX.UI`, `GFX.Viewer`, and `GFX.WebView` are
official suite members; `GFX.Physics` evolves independently and remains
installed separately while it is under development.

Authorization is a delegation from GFX, not a permanent transfer of its
namespace. If GFX later supplies `GFX.Physics` itself, its module is canonical.
The separately released package can share that exact public façade only when
GFX grants it exact `merge: true` permission; otherwise the compiler reports
the incompatible providers. A merge is additive, preserves declaration
ownership and rejects public name collisions.

## Modular core

```text
GFX
├── Application     loop, resources, systems, plugins, time, and pacing
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
└── UI              declarative descriptions, constraint layout, image fitting, and raster rendering
```

The modules remain organized by capability. A cross-cutting capability may
depend on a more fundamental one, but it does not become the owner of its
consumers' concepts. Rendering owns and orchestrates its FrameGraph under
`GFX.Rendering.FrameGraph`, while a 2D grid, a 3D material, and their shaders
remain in their scene domains.

`GFX.Animation` owns its timelines, easing vocabulary, playback component and
application plugin. `GFX.Assets` owns portable image, model and sprite-sheet
domains and contributes their runtime stores; PNG and glTF are isolated
adapters that can move later without moving those values. `GFX.Audio` owns its portable API, application plugin and
complete SDL3_mixer boundary. `GFX.Canvas` owns vector drawing, rasterization,
surfaces, its default font and the complete SDL3_ttf boundary. `GFX.ECS` owns
stable entities, typed components, queries, deferred commands and Application
integration without owning any concrete scene component. `GFX.GPU` owns direct
GPU access, compute, offscreen rendering, presentation and its Application
plugin while reusing the SDL3 provider from GFX. `GFX.Rendering`
owns generic pass orchestration, FrameGraph, multisampling and frame statistics.
`GFX.Scene2D` owns retained 2D scenes and their renderer. `GFX.Scene3D` owns
retained 3D scenes, geometry, imported-model
instantiation, shaders, tone-mapping tables and its renderer. `GFX.Stats` owns
its FPS and rendering-statistics panels. `GFX.Terminal` owns ANSI/VT screen
emulation, PTY/ConPTY session orchestration through STD, terminal themes and
Canvas presentation. `GFX.Viewer` owns direct visual-value
presentation through `show`, its
viewer-specific settings, shader, examples, and private application plumbing.
`GFX.UI` owns declarative interface descriptions, their private retained
identity, constraint layout, image fitting and its initial Canvas-backed raster
renderer independently from an application's game ECS world. Interactive
input, reconciliation and scheduling integration remain inside the UI domain.
`GFX.WebView` owns its portable API, application plugin, platform
adapters and system-framework boundary. These packages own
their examples, tests and documentation, depend only on public GFX capabilities,
and contribute their declarations to the parent's open catalogs.

## Umbrella views

Three optional modules gather the declarations most often used together:

- `GFX.Components` exposes values placed in ECS entity recipes.
- `GFX.Resources` exposes application-owned values intended for system
  injection and runtime control.
- `GFX.Plugins` exposes installable capabilities and their configuration.

They are views over the domain API, not new owners and not separate packages.
Domain modules remain available when an application wants a focused import.
Dimensional suffixes appear in `Components` and `Plugins` because those two
umbrellas deliberately place the 2D and 3D vocabularies side by side.

The GFX manifest opens exactly these three modules as reexport-only catalogs.
An authorized child package may contribute declarations that it owns from its
portable principal module. The compiler rejects executable declarations,
foreign ownership and every alias collision, so the umbrellas remain views
rather than cross-package implementation modules.

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

## Native infrastructure

SDL is not a domain that users need to learn. GFX owns the `SDL3` provider.
GFX.GPU privately aliases that provider for direct SDL GPU calls. GFX.Canvas
owns `SDL3_ttf` and GFX.Audio owns `SDL3_mixer`; both providers privately
require `GFX.SDL3`. GFX.WebView owns its operating-system framework boundary.

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

There is deliberately no public `GFX.SDL` module and no SDL version number in
the API. A future SDL migration changes GFX's implementation and version
without creating a new family of packages.

## Artifact ownership

Each domain keeps everything needed to understand, use, and replace it:

```text
GFX.Scene3D/
├── Module/           domain API and implementation
├── Shaders/          shaders supplied by the domain
├── Assets/           tone-mapping tables and example models
├── Examples/         executable usages
├── Tests/            verified contract and isolated consumer
└── Docs/README.md    domain documentation
```

The same rule applies to every capability. An extracted package such as
GFX.Scene2D or GFX.Canvas becomes the root of those same owned artifacts.
Canvas additionally owns its font, native boundary and third-party notices;
Scene2D's 2D grid shader
belongs in `GFX.Scene2D/Shaders/Grid.hlsl`; the Scene3D shadow shader belongs
in `GFX.Scene3D/Shaders/Shadow.hlsl`. Documentation stays flat as
long as a domain needs only one file; a domain directory is introduced only
when several cohesive documents justify it.

## Names within a domain

The domain already carries the dimension, so declarations do not repeat it:

```silex
use GFX.Scene2D.Transform as Transform2D
use GFX.Scene3D.Transform as Transform3D
use GFX.Scene3D.Rotator as Rotator3D
```

Write `GFX.Scene3D.Rotator`, not `GFX.Scene3D.Rotator3D`. A `2D` or `3D`
suffix is useful only in a cross-domain API that deliberately exposes both
variants.

## Extension and replacement

One package does not mean one renderer. A user can:

- provide a `GPU.ShaderProgram` or `GPU.ComputeProgram` from a custom HLSL
  file;
- build, inspect, and compile a public `GFX.Rendering.FrameGraph`;
- register custom passes with `Rendering`;
- consume `Scene2D` or `Scene3D` data with an alternative renderer;
- replace an orchestration plugin without replacing domain values.

These paths rely on public APIs. A third-party extension must never depend on
a non-public declaration, a shader-packing payload, or an SDL handle. The
monolith lets official domains share implementation details when useful, but
those details are not extension points.

## Invariants

1. `GFX` is the stable graphics and application core; every official
   `GFX.*` package requires exact namespace authorization and an explicit
   decision about privileged access and suite installation.
2. A domain expresses a user capability, never a technical layer.
3. Every shader, asset, example, test, and document belongs to its domain.
4. `Rendering` remains generic: scene geometry, materials, and shaders do not
   live there.
5. Native providers are private infrastructure, not an SDL API.
6. Extension points are public and validated from consumer code.
7. A domain can move to an authorized child package without changing its
   public module path.
