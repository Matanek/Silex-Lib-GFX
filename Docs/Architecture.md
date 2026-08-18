# GFX architecture

`GFX` is a single package and a root namespace for its domains. There are no
official `GFX.*` packages to install separately:

```text
silex install GFX
```

This command installs the complete API, its shaders, examples, and required
native artifacts. In source code, `GFX` is the namespace parent and
`GFX.Application`, `GFX.Scene2D`, and `GFX.Audio` are child modules.

## Modular monolith

```text
GFX
├── Application     loop, resources, systems, plugins, time, and pacing
├── Assets          images, image regions, atlases, and asset identities
├── Audio           sound loading, playback, and spatialization
├── Canvas          vector drawing intentions, rasterization, and 2D geometry
├── ECS             world, entities, components, queries, and commands
├── FrameGraph      logical resources, passes, ordering, and aliasing
├── GPU             device, resources, pipelines, commands, and shaders
├── Input           events, keyboard, and pointer
├── Rendering       generic rendering host and orchestration
├── Scene2D         camera, transform, sprite, grid, and 2D shaders
├── Scene3D         camera, mesh, material, light, selection, and 3D gizmos
├── Viewer          focused presentation of images and Canvas drawings
├── WebView         embedded Web content and message bridge
└── Window          windows, displays, and system presentation
```

The package is monolithic for distribution, while its modules remain organized
by capability. A cross-cutting capability may depend on a more fundamental
one, but it does not become the owner of its consumers' concepts. `Rendering`
may orchestrate a `FrameGraph`, while a 2D grid, a 3D material, and their
shaders remain in their scene domains.

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

```silex
use GFX.Components
use GFX.ECS
use GFX.Plugins
use GFX.Resources

func move_camera(time:@Resources.FrameTime, camera:&Resources.ViewportCamera3D) {
    camera.set_distance(camera.distance() + time.delta)
}

application.add_plugin(Plugins.Window(Plugins.WindowSettings()
    ..title = "GFX"
))
application.add_plugin(Plugins.ViewportCamera3D(
    Plugins.ViewportCamera3DSettings()..distance = 12.0
))

world.spawn(ECS.EntityRecipe()
    ..with(Components.Transform3D())
    ..with(Components.Camera3D())
)
```

## Native infrastructure

SDL is not a domain that users need to learn. The `SDL3`, `SDL3_ttf`, and
`SDL3_mixer` providers, their archives, and their system dependencies are
declared in the GFX manifest. WebView also uses the platform's system
frameworks when an adapter is available.

```text
Package.json
Boundary/<target>/
├── SDL3
├── SDL3_ttf
└── SDL3_mixer
```

There is deliberately no public `GFX.SDL` module and no SDL version number in
the API. A future SDL migration changes GFX's implementation and version
without creating a new family of packages.

## Artifact ownership

Each domain keeps everything needed to understand, use, and replace it:

```text
Module/Scene3D/       domain API and implementation
Shaders/Scene3D/      shaders supplied by the domain
Examples/Scene3D/     executable usages
Tests/Scene3D/        verified contract
Docs/Scene3D.md       domain documentation
```

The same rule applies to `Scene2D`, `Audio`, `Viewer`, `WebView`, and every other
capability. A 2D grid shader belongs in `Shaders/Scene2D/Grid.hlsl`; a shadow
shader belongs in `Shaders/Scene3D/Shadow.hlsl`. Documentation stays flat as
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
- build, inspect, and compile a public `FrameGraph`;
- register custom passes with `Rendering`;
- consume `Scene2D` or `Scene3D` data with an alternative renderer;
- replace an orchestration plugin without replacing domain values.

These paths rely on public APIs. A third-party extension must never depend on
a non-public declaration, a shader-packing payload, or an SDL handle. The
monolith lets official domains share implementation details when useful, but
those details are not extension points.

## Invariants

1. `GFX` is the only official package and the only distribution manifest.
2. A domain expresses a user capability, never a technical layer.
3. Every shader, asset, example, test, and document belongs to its domain.
4. `Rendering` remains generic: scene geometry, materials, and shaders do not
   live there.
5. Native providers are private infrastructure, not an SDL API.
6. Extension points are public and validated from consumer code.
7. A new domain can be added without renaming existing domains or creating a
   new repository.
