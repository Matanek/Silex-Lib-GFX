# GFX.Color

`GFX.Color` représente une couleur RGBA portable avec quatre composantes
`float`. Ce n’est ni un format de texture, ni une couleur SDL.

```silex
use GFX.Color

let sky = Color.rgb(0.2, 0.4, 0.8)
let encoded = Color.bytes(51, 102, 204)
let faded = sky.with_alpha(0.5)
let middle = Color.red_500().lerp(Color.blue_500(), 0.5)
```

Les palettes nommées conservent leurs valeurs historiques. Les composantes ne
sont pas limitées à `[0, 1]`, ce qui autorise les valeurs HDR et
l’extrapolation explicite.
