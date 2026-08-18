# GFX examples

Examples are grouped by the capability they demonstrate. Every `.sx` file is
an executable consumer of the public GFX API.

## Audio

- `Audio/PlaySound.sx` loads and plays one sound.
- `Audio/PlaySpatialSound.sx` controls spatial playback.

## Canvas

- `Canvas/CreateImage.sx` paints and displays a generated chart.
- `Canvas/PaintLinearGradient.sx` displays gradient fills and strokes.
- `Canvas/PresentDrawing.sx` presents a retained vector Canvas that follows
  its window without an intermediate image.
- `Canvas/RasterizeSurface.sx` composes canvas content and image pixels on a surface.
- `Canvas/RenderVectorText.sx` rasterizes and displays shaped text.
- `Canvas/ShapeGallery2D.sx` renders the complete historical shape gallery
  through retained `Scene2D` vector geometry and its text layer.

Canvas examples may present either an `Assets.Image` or a retained drawing
through `GFX.Viewer`; `GFX.Canvas` itself remains independent from windows and
the GPU.

## Rendering

- `Rendering/AlternativePass.sx` registers passes in the public frame graph.

## Scene2D

- `Scene2D/Clock.sx` draws a live clock as two retained vector overlays.
- `Scene2D/Boids.sx` renders 2,000 ECS boids from one shared retained
  `Scene2D.Drawing`, exercising vector instancing without rerasterizing the
  window each frame.

## Scene3D

- `Scene3D/Cube.sx` renders and animates a lit PBR cube.
- `Scene3D/CornellBox.sx` composes geometry, materials, emission, a point
  light, and tone mapping into a complete room.
- `Scene3D/Lighting.sx` switches between sun, spot, cube, tube, and point
  lights with the number keys 1–5.

## WebView

- `WebView/BridgeWebPage.sx` exchanges named messages with embedded content.
- `WebView/EmbeddedFiles.sx` serves HTML, CSS, and JavaScript from the
  executable.
