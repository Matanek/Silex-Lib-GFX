# Color

Import `GFX.Color` to represent a portable RGBA color:

```sx
use GFX.Color

let sky = Color.rgb(0.2, 0.4, 0.8)
let encoded = Color.bytes(51, 102, 204)
let translucent = sky.with_alpha(0.5)
```

`Color` stores the public `float` components `r`, `g`, `b`, and `a`.
They are values, not an SDL or GPU format. `Color()` is opaque white, and a
named field initializer may override any component. `Color.rgb` uses an alpha
of `1.0`; `Color.rgba` accepts all four components.

`Color.bytes` accepts `uint8` components and divides each by `255.0`.
Its alpha defaults to `255`. This conversion does not change color space or
premultiply alpha.

## Transform colors

```sx
let faded = Color.blue_500().with_alpha(0.5)
let middle = Color.red_500().lerp(Color.blue_500(), 0.5)
let same = Color.red_500().mix(Color.blue_500(), 0.5)
```

`with_alpha` returns a copy with a new alpha. `lerp` interpolates every
component, and `mix` is its synonym. Floating components and interpolation
amounts are not clamped, so colors may carry HDR values and interpolation may
extrapolate.

## Named colors

The module provides `white()`, `black()`, `gray()`, `transparent()`, and the
rendering-tool accent `gizmos()`.
It also provides the shades `50`, `100`, `200`, `300`, `400`, `500`,
`600`, `700`, `800`, `900`, and `950` for these families:

- `red`, `orange`, `amber`, `yellow`, `lime`, `green`, `emerald`
- `teal`, `cyan`, `sky`, `blue`, `indigo`, `violet`, `purple`
- `fuchsia`, `pink`, `rose`
- `slate`, `gray`, `zinc`, `neutral`, `stone`, `taupe`, `mauve`,
  `mist`, and `olive`

Names combine the family and shade in snake case, for example
`Color.amber_300()` or `Color.slate_950()`. These factories preserve the
byte values of the historical GFX palette.
