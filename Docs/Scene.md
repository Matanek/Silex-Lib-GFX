# Build a scene with entities, transforms, and cameras

The retained renderer represents scene objects as stable `ECS.Entity` values.
Components remain typed: an entity becomes a 2D or 3D camera by receiving the
matching transform and camera components.

```sx
use GFX.Bootstrap.Application
use GFX.Bootstrap.Schedule
use GFX.Camera
use GFX.ECS
use GFX.Transform
use GFX.Plugins.Rendering3D as Rendering3DPlugin
use GFX.Plugins.Window as WindowPlugin
use STD.Math

func create_scene(world:&ECS.World) {
    var camera = ECS.EntityRecipe()
        ..with(Transform.Transform3D(
            Math.Vec3(0.0, 2.0, 5.0)
        ))
        ..with(Camera.Camera3D())
    world.spawn(camera)
}

Application()
    ..install(WindowPlugin())
    ..install(Rendering3DPlugin())
    ..add_system(Schedule.startup, create_scene)
    ..run()
```

`Camera2D` uses an orthographic projection. Its optional viewport size falls
back to the window size, and `zoom` controls the visible extent. `Camera3D`
uses a perspective projection configured by its vertical field of view, near
plane, and far plane. Both camera kinds have an `active` flag and an `order`;
inactive cameras do not participate in rendering and lower order values render
first within their camera kind.

An `EntityRecipe` collects every initial component before the entity becomes
visible in the world. A recipe is consumed by one `World.spawn` call. This
atomic boundary is shared by deferred commands and archetype-aware storage
without changing scene construction code.

Use `World.insert(entity, component)` only to add or replace a component on an
already living entity. `World.update<T>(entity, callback)` mutates a typed
component, `World.remove<T>` detaches one, and `World.destroy` invalidates the
entity and removes all of its components.

## Query components from a system

A typed query makes its filter and access intent part of the system signature:

```sx
use GFX.ECS
use GFX.Transform

struct Rotator {
    let radians_per_second:float
}

func rotate(
    time:@GFX.Time,
    query:ECS.Query<(@Rotator, &Transform.Transform3D)>
) {
    for (rotator, transform) in query {
        let yaw = Math.Quat.angle_axis(
            rotator.radians_per_second * time.delta_seconds,
            Math.Vec3.up()
        )
        transform.rotation = yaw.multiply(copy transform.rotation).normalized()
    }
}
```

Only living entities containing every requested component enter the loop. `@T`
borrows a component for reading and `&T` borrows it for mutation. Adding
`ECS.Entity` to the tuple exposes the stable entity identity without treating it
as a stored component:

```sx
func expire(
    commands:&ECS.Commands,
    query:ECS.Query<(ECS.Entity, @Lifetime)>
) {
    for (entity, lifetime) in query {
        if lifetime.finished { commands.destroy(entity) }
    }
}
```

`Commands.spawn(recipe)`, `Commands.destroy(entity)`,
`Commands.insert(entity, component)`, and `Commands.remove<T>(entity)` preserve
submission order and are applied in `post_update`. Structural changes therefore
never invalidate an active query. A command targeting an entity destroyed by an
earlier command is ignored.

The compiler may split a sufficiently large query loop into disjoint row
intervals when each iteration only reads `@T`, mutates the current entity's
`&T`, or records deferred commands. `continue` keeps that optimization
available. A `break`, a return from the loop, an outer accumulation, or an
effect whose ordering matters keeps the loop sequential and preserves its
ordinary result. Command order is identical in both modes; worker completion
order is not observable.

This scheduling remains internal: application code never names a chunk,
worker, range, or command writer. The query is specialized by the compiler and
walks matching archetypes directly; it allocates no entity list and performs no
string, hash, or reflective component lookup in the entity loop.

## Storage and identity guarantees

`World` keeps a generational entity table, an archetype index, and one dense
component column per concrete component type. A sparse entity-index table gives
constant-time access to a component; removal fills the hole with the last dense
value. Adding or removing a component only moves the entity between archetype
membership lists—the component columns stay dense.

Destroyed entity slots are reused, but their generation changes. A stale
`Entity` consequently never becomes alive again and cannot address the
components of its replacement. Spawning a recipe containing the same component
type more than once keeps the latest value and still creates a single archetype
membership.

These details are internal. The stable surface remains `Entity`, `World`,
`EntityRecipe`, `Query`, and `Commands`, so the storage strategy and future
query caching can evolve without changing scene or system code.

`Plugins.ECS` installs both `World` and `Commands`. `Plugins.Rendering` also
installs `GFX.Time`; its `delta_seconds` value is advanced once in `pre_update`,
so every update system observes the same frame duration.

`Plugins.Rendering` installs the camera, transform, and ECS capabilities through
their plugins. Applications may also install `Plugins.ECS`, `Plugins.Transform`, or
`Plugins.Camera` directly when they need these scene capabilities without the
retained renderer.

## Orbital camera

`Plugins.OrbitalCamera3D` creates and controls a perspective camera around a
target. Right-drag orbits, middle-drag pans, and the mouse wheel zooms.
`PageUp` and `PageDown` provide continuous keyboard zoom.

```sx
use GFX.Plugins.OrbitalCamera3D as OrbitalCamera3DPlugin
use STD.Math

application.install(OrbitalCamera3DPlugin(OrbitalCamera3DPlugin.Settings()
    ..target = Math.Vec3(0.0, 0.55, 0.0)
    ..distance = 5.0
    ..min_distance = 2.0
    ..max_distance = 12.0
    ..pitch = Math.radians(-18.0)
    ..vertical_fov_radians = Math.radians(42.0)
    ..near_plane = 0.05
    ..far_plane = 80.0
))
```

The plugin installs its rendering and input dependencies. Its
`Camera.OrbitalCamera3D` resource exposes the camera entity, target, and
distance, and allows applications to replace the target or distance without
managing the camera transform directly.

## Meshes and materials

Geometry is CPU-side data made of `Geometry.Vertex` values and triangle
indices. GFX provides `Geometry.Cube.make()` and `Geometry.Plane.make()` and
accepts custom `Geometry.Mesh` values. Store geometry in the `Assets.Meshes`
resource, then attach its stable handle and a simple material to an entity:

```sx
use GFX.Assets
use GFX.Color
use GFX.ECS
use GFX.Geometry
use GFX.Material
use GFX.Mesh
use GFX.Transform

func create_mesh(world:&ECS.World, meshes:&Assets.Meshes) {
    let cube = meshes.add(Geometry.Cube.make())
    var entity = ECS.EntityRecipe()
        ..with(Transform.Transform3D())
        ..with(Mesh.Mesh3D(cube))
        ..with(Mesh.Material3D(Material.Simple(Color.indigo_500())))
    world.spawn(entity)
}
```

`Geometry.Mesh.translated(offset)` illustrates direct nested mutation in
Silex: `vertices[index].position = ...` is supported for mutable collections.

## 2D and 3D sprites

Images currently contain RGBA8 pixels. Add one to `Assets.Images`, then reuse
the same handle in either sprite component:

```sx
use GFX.Assets
use GFX.Color
use GFX.ECS
use GFX.Sprite
use GFX.Transform
use STD.Math

func create_sprites(world:&ECS.World, images:&Assets.Images) {
    let image = images.add(Assets.Image.solid(Color.white()))

    var overlay = ECS.EntityRecipe()
        ..with(Transform.Transform2D())
        ..with(Sprite.Sprite2D(image, Math.Vec2(32.0), layer:10))
    world.spawn(overlay)

    var marker = ECS.EntityRecipe()
        ..with(Transform.Transform3D(Math.Vec3(0.0, 1.0, 0.0)))
        ..with(Sprite.Sprite3D(
            image,
            Math.Vec2(0.5),
            billboard:Sprite.Billboard.face_camera
        ))
    world.spawn(marker)
}
```

`Sprite3D` supports fixed orientation, full camera-facing billboarding, and
Y-axis camera-facing billboarding. Both sprite kinds expose size, pivot, tint,
and visibility; `Sprite2D` additionally exposes layer and depth ordering.
