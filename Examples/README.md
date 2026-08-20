# GFX examples

Examples are grouped by the capability they demonstrate. Every `.sx` file is
an executable consumer of the public GFX API.

## Animation

- `Animation/Timeline2D.sx` composes movement, rotation, scale, and color in a
  looping ping-pong timeline.
- `Animation/Timeline3D.sx` moves a hovering cyan cube and its cyan point light
  around four inset corners while a tilted pink cube rotates at the center.
- `Animation/EasingGallery.sx` compares every easing on synchronized tracks
  inside a pannable and zoomable Scene2D viewport.

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
- `Scene3D/World.sx` provides a reusable 100 m × 100 m textured world with a
  first-person camera, deterministic scatters for rocks, pebbles, trees, and
  grass, and a live GPU performance panel demonstrating automatic instance
  batching. Pass `--benchmark` to report a five-second FPS sample with separate
  color and shadow work, or `--benchmark-moving` to measure along a wide path
  that crosses the map while continuously varying the camera orientation.
  `--benchmark-soak` runs that path for 60 seconds and reports five-second
  samples. Benchmarks use a non-focusable 1280 x 720 window and exit
  automatically. Add `--benchmark-focused` when an absolute FPS comparison
  needs the window to remain active, or `--benchmark-panel` to include the live
  performance overlay. The example renders at logical window density so Retina
  and standard-density displays submit the same pixel load. Benchmark modes
  select immediate presentation so display refresh does not cap measured
  throughput; `--benchmark-synchronized` and `--benchmark-mailbox` select the
  corresponding presentation modes for sustained-frame comparisons.
  `--benchmark-large` selects 2560 x 1440 for GPU stress comparisons;
  `--benchmark-retina` enables the display's high-density drawable;
  `--benchmark-heavy` increases the deterministic grass field to 50,000
  instances;
  `--benchmark-no-msaa`, `--benchmark-hard-shadows`, and
  `--benchmark-no-shadows` provide targeted rendering ablations.

## WebView

- `WebView/BridgeWebPage.sx` exchanges named messages with embedded content.
- `WebView/EmbeddedFiles.sx` serves HTML, CSS, and JavaScript from the
  executable.
