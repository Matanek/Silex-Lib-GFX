# GFX.Scene3D

`GFX.Scene3D` owns 3D scene data, its geometry, and the tools that genuinely
act on this domain: materials, lights, shadows, selection, and transform
gizmos. None of these concepts belongs to `GFX.Rendering` or a supposed
`Editor3D` domain.

```silex
use GFX.Scene3D.Material as Material3D
use GFX.Scene3D.Rotator as Rotator3D
use GFX.Scene3D.Transform as Transform3D
```

Mesh, grid, sprite, lighting, shadow, selection, and outline shaders live under
`Shaders/Scene3D/`. An alternative renderer can consume the public components,
use these assets as references, or provide its own shaders through `GFX.GPU`.
`Selection` and `TransformGizmo` remain explicit subdomains of `Scene3D`.

`Scene3D.Plugin` installs the ECS and generic rendering dependencies, owns the
built-in mesh cache, and registers a depth-aware Scene3D pass. Applications
remain free to omit it and consume `World`, `Meshes`, camera, material, and
light values from an alternative renderer.

```silex
application.add_plugin(Scene3D.Plugin())
```

## PBR materials

`Material` describes scalar surface properties. Optional image maps and raster
state live in the `MaterialSettings` ECS component; `MaterialTextures` groups
its texture inputs without becoming another component:

```silex
use GFX.Assets
use GFX.Color
use GFX.ECS
use GFX.Scene3D

let albedo = images.add(Assets.Image.solid(Color.white()))
world.spawn(ECS.EntityRecipe()
    ..with(Scene3D.Transform())
    ..with(Scene3D.Mesh(mesh))
    ..with(Scene3D.Material(
        metallic:0.2,
        roughness:0.6
    ))
    ..with(Scene3D.MaterialSettings(
        textures:Scene3D.MaterialTextures(
            albedo:Scene3D.MaterialTexture(image:albedo)
        ),
        alpha:Scene3D.AlphaMode.blend,
        double_sided:true
    ))
)
```

The forward renderer supports base-color, normal, metallic-roughness,
occlusion, and emission textures. Alpha masks discard below `alpha_cutoff`;
blended surfaces render after opaque surfaces, from far to near, without depth
writes. Texture transforms carry offset, scale, and rotation. The default
sampler repeats, filters linearly, generates mipmaps, and uses anisotropic
filtering.

## Automatic batching

The built-in renderer automatically instances compatible opaque and alpha-mask
entities that share their mesh, material values, textures, and raster state.
The same persistent instance buffers feed the forward and shadow passes, while
their matrix contents are refreshed every frame. Blended entities remain
individual draws so their far-to-near ordering stays correct.

This optimization does not add a batching component or change normal ECS
usage: applications keep spawning `Transform`, `Mesh`, `Material`, and optional
`MaterialSettings` components. `Rendering.Stats` exposes the resulting draw,
instance, triangle, pipeline, pass, uniform, and texture work for profiling.

## Procedural scatter

`Scatter` deterministically generates ordinary `Transform` values from a seed.
Its horizontal spawn area can be a box or a circle; additional areas can be
excluded. Position, Euler rotation, uniform or per-axis scale, soft edges, and
center-to-edge scale variation can be configured independently:

```silex
var rocks = Scene3D.Scatter(
    count:200,
    area:Scene3D.ScatterArea.box(Math.Vec2(80.0)),
    seed:42
)
rocks.exclude(Scene3D.ScatterArea.circle(5.0))
rocks.vary_rotation(Math.Vec3(), Math.Vec3(0.2, Math.two_pi(), 0.2))
rocks.vary_scale(Math.Vec3(0.3), Math.Vec3(1.8))
rocks.soften_edges(0.2)

for transform in rocks.generate() {
    world.spawn(ECS.EntityRecipe()
        ..with(transform)
        ..with(Scene3D.Mesh(rock_mesh))
        ..with(rock_material)
    )
}
```

Scatter stays independent from assets and ECS recipes: the same placements can
instantiate a mesh, several entities forming one object, or another consumer's
components. Compatible generated entities are picked up by automatic batching
without another public rendering concept. A seed always reproduces the same
placements and variations. An impossible exclusion can yield fewer transforms
than requested after bounded placement attempts.

## Tone mapping

Tone mapping is part of the Scene3D mesh shading contract rather than a
generic rendering concern. `Shaders/Scene3D/Mesh.hlsl` contains the Reinhard,
ACES, Khronos PBR Neutral, Filmic, and AgX operators. Filmic and AgX use the
RGBA16F lookup tables under `Assets/Scene3D/ToneMapping/`.

```silex
use GFX.Scene3D.ToneMapping as ToneMapping3D
use GFX.Scene3D.ToneMapping.Tables

let settings = ToneMapping3D.agx(exposure:0.5)
let tables = Tables.bundled()
```

`Tables` is public so an alternative renderer can reuse the same validated
transforms instead of depending on a private shader payload. The generation
script lives at `Tools/Scene3D/GenerateToneMappingLUTs.py`.
