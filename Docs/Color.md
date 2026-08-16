# GFX.Color

`GFX.Color` represents a portable RGBA color with four `float` components. It
is neither a texture format nor an SDL color.

```silex
use GFX.Color

let sky = Color.rgb(0.2, 0.4, 0.8)
let encoded = Color.bytes(51, 102, 204)
let faded = sky.with_alpha(0.5)
let middle = Color.red_500().lerp(Color.blue_500(), 0.5)
```

Named palettes preserve their historical values. Components are not clamped to
`[0, 1]`, allowing HDR values and explicit extrapolation.
