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
