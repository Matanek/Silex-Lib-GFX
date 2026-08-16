# GFX.GPU

`GFX.GPU` directly exposes the device, resources, pipelines, commands, and
presentation. SDL_GPU handles and native structures remain private.

```silex
use GFX.GPU

var device = GPU.Device(GPU.DeviceSettings(debug:true))
var buffer = device.buffer(GPU.BufferSettings(
    size:256,
    usage:GPU.BufferUsage.vertex()
))
```

A user can provide custom HLSL from a file or source text:

```silex
let graphics = GPU.ShaderProgram.hlsl(file:"Shaders/Alternative.hlsl")
let compute = GPU.ComputeProgram.hlsl(source:"...", entry:"compute_main")
```

Silex compiles these programs for the target; GFX does not impose scene
shaders. `GPU.Plugin` integrates a surface and the presentation lifecycle with
`Application`, while the direct API remains available without a plugin.
