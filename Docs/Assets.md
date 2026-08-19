# GFX.Assets

`GFX.Assets` owns images, image regions, sprite sheets, models, and their
stable identities. Asset formats live here rather than in a scene domain:
they produce values that a scene may instantiate, but they are not themselves
scene content.

```silex
use GFX.Assets
use GFX.Color

var images = Assets.Images()
let white = images.add(Assets.Image.solid(Color.white()))
let region = Assets.ImageRegion(x:0, y:0, width:16, height:16)
```

`Assets.Plugin` installs the catalogs into `Application`. Handles separate
public identity from the module-private organization of collections; they contain no
SDL or GPU pointer.

## glTF and GLB models

`GFX.Assets.GLTF` imports and exports glTF 2.x models. The ordinary API stops
on malformed input or an I/O failure, like the direct JSON and YAML APIs:

```silex
use GFX.Assets.GLTF

let model = GLTF.load("Assets/Models/Robot.glb")
GLTF.save("Build/Robot.gltf", model)
```

The `try_*` forms expose structured errors when an application wants to
recover or report the failure itself:

```silex
match GLTF.try_load("Assets/Models/Robot.glb") {
    success(model) => { print("$(model.mesh_count()) meshes") }
    failure(error) => { print(error.detail) }
}
```

The same distinction applies to in-memory conversion through `decode`,
`try_decode`, `encode`, and `try_encode`. `Format.glb` produces a binary GLB;
`Format.gltf` produces a self-contained JSON document whose binary buffer is a
base64 data URI. `save` and `try_save` infer the format from `.glb` or `.gltf`.
`Assets.Model.from_mesh` creates an exportable model directly from Scene3D
geometry when no imported model is involved.

An imported `Assets.Model` retains its meshes, nodes, selected scene roots,
images, PBR factors, texture references, texture-coordinate transforms, alpha
mode, and double-sided state. It is independent from ECS storage. Instantiation
is an explicit bridge:

```silex
func create_scene(
    world:&Resources.World,
    meshes:&Resources.Meshes3D,
    images:&Resources.Images
) {
    let model = GLTF.load("Assets/Models/Robot.glb")
    let instance = model.instantiate(world, meshes, images)
    print("$(instance.entities.count()) primitives")
}
```

Instantiation registers decoded images in the supplied catalog and produces
`Scene3D.Material` plus `Scene3D.MaterialSettings` components. The built-in
renderer consumes base-color, normal, metallic-roughness, occlusion, and
emissive maps, including `KHR_texture_transform`. It also honors opaque, mask,
and blended alpha modes, alpha cutoff, double-sided materials, vertex colors,
and `KHR_materials_unlit`. Color and emissive maps use sRGB sampling; data and
normal maps remain linear.

The current codec accepts triangle primitives, indexed or non-indexed geometry,
TRS node hierarchies, PNG images, embedded GLB buffers, external `.gltf`
buffers, and base64 data URIs. Sparse accessors, node matrices, animation,
skinning, morph targets, Draco/Meshopt compression, and JPEG images return an
`unsupported_feature` error rather than being silently discarded.
