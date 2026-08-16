# GFX.Assets

`GFX.Assets` owns images, image regions, sprite sheets, and their stable
identities. The domain does not select a decoder or upload to the GPU: an
application or extension supplies pixels and chooses their destination.

```silex
use GFX.Assets
use GFX.Color

var images = Assets.Images()
let white = images.add(Assets.Image.solid(Color.white()))
let region = Assets.ImageRegion(x:0, y:0, width:16, height:16)
```

`Assets.Plugin` installs the catalogs into `Application`. Handles separate
public identity from the internal organization of collections; they contain no
SDL or GPU pointer.
