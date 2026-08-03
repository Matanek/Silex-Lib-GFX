# Display HTML interfaces with GFX.WebView

`GFX.WebView` displays embedded HTML, CSS, and JavaScript in the WebView
supplied by the operating system. It does not embed Chromium or add a browser
library to GFX.

```sx
use GFX.WebView

var site = WebView.Site(
    WebView.Asset.html(embed_text("Web/index.html"))
)
site.add(WebView.Asset.css(embed_text("Web/app.css"), path:"/app.css"))
site.add(WebView.Asset.javascript(embed_text("Web/app.js")))
var view = WebView.View(
    window,
    site,
    WebView.Settings(background:Color.white())
)
```

Applications that may run on a target whose system adapter is optional can
inspect it before creating a view:

```sx
let web_view = WebView.availability()
if !web_view.is_available() {
    if let reason = web_view.reason() { print(reason) }
    return
}
```

The path passed to `embed_text` is relative to the `.sx` source containing the
call and must be known at compile time. Silex stores the UTF-8 text directly in
the executable and records the source file as a compilation-cache dependency.
`Asset.html`, `Asset.css`, and `Asset.javascript` are ordinary GFX constructors;
they associate that text with a logical path and media type.

Logical paths begin with `/` and identify assets inside the embedded site. The
general `Asset(text, path, media_type)` initializer accepts a `WebView.MediaType`
for JSON, SVG, or another textual media type:

```sx
let manifest = WebView.Asset(
    content:embed_text("Web/manifest.json"),
    path:"/manifest.json",
    media_type:WebView.MediaType.json,
)
```

`MediaType` names common web formats independently of their file extension.
For example, `.jpg` and `.jpeg` both use `MediaType.jpeg`. Use
`MediaType.custom("model/gltf-binary")` for a registered or application-specific
type absent from the enum. `media_type_text` returns its standardized HTTP
representation, and `Asset.media_type_text()` does the same for an asset.

Text and binary resources use the same generic `Asset` through overloaded
`content` constructors:

```sx
site.add(WebView.Asset(
    content:embed_bytes("Web/icon.png"),
    path:"/icon.png",
    media_type:WebView.MediaType.png,
))
```

References such as `<img src="/icon.png">` and `url("/icon.png")` are replaced
with self-contained data URLs when the document is assembled. SVG may use
either `embed_text` or `embed_bytes`; raster images and fonts use `embed_bytes`.

The current macOS implementation assembles the entry HTML and its embedded
resources into one self-contained document before loading it through WKWebView.
The source directory is not distributed beside the executable.

`View` has no per-frame `update()` operation. WebKit owns layout, JavaScript,
painting, and invalidation. The application only processes its ordinary GFX
event loop.

## Exchange application messages

JavaScript sends named string messages through the injected `window.silex`
object:

```js
window.silex.send("action", "save")

window.silex.on("status", payload => {
    document.querySelector("#status").textContent = payload
})
```

Silex receives messages without invoking JavaScript and queues responses until
the application chooses to flush them:

```sx
for message in view.receive() {
    if message.name == "action" {
        view.send("status", "Saved " + message.payload)
    }
}
view.flush()
```

`send` only appends to a Silex queue. `flush` performs no WebKit call when that
queue is empty and otherwise sends the complete queue in one JavaScript
evaluation. In the opposite direction, JavaScript groups all `silex.send`
calls made during one microtask and crosses into Silex once for the complete
batch. Message order is preserved in both directions.

Names and payloads are strings. An application may use `STD.JSON` inside the
payload when it needs structured data. Dispatch stays asynchronous: neither
side waits synchronously for the other, and the bridge does not participate in
rendering frames.

The functional smoke sends 256 round trips while asserting one native bridge
crossing per direction. `Benchmarks/WebViewBridge.sx` runs the same path with
1,000 messages so an external profiler or command timer can measure it without
embedding a machine-dependent timing threshold in the package.

Without `GFX.Application`, handle the close request belonging to the window:

```sx
input.wait(16)
input.update()
for event in input.events() {
    match event {
        window_close_requested(request) => {
            if request.window == window.id() { running = false }
        }
        else => {}
    }
}
```

`Settings.background` and `set_background(Color)` control the native window
and WebView background. An opaque CSS background still takes precedence.

The browser context menu is disabled by default, so embedded application
interfaces do not expose native browser actions such as Reload. The HTML page
may still handle the `contextmenu` event to present its own application menu.
Enable the system browser menu explicitly when building a navigation or
debugging surface:

```sx
let settings = WebView.Settings(context_menu:true)
```

Create, use, and destroy the window and its view on the main thread. `View`
retains its `GFX.Window`, fills its content area, and follows resizing through
native constraints.

## Platform status

- `macos-arm64` is available. Its `Platform/MacOS` fragment calls the
  Objective-C runtime and the Cocoa/WebKit frameworks exposed by
  `Interop.MacOS`.
- Linux X64 has a complete selected-fragment contract and compiles with the
  portable API, but reports itself unavailable. GTK 4 no longer supports
  embedding a foreign native window, so the executable implementation must use
  an embeddable WPE WebKit surface rather than opening a second GTK window.
- Windows X64 and ARM64 have the same complete selected-fragment contract and
  compile with the portable API, but report themselves unavailable. WebView2
  requires the architecture-specific WebView2 loader in addition to the
  installed runtime. The remaining implementation must resolve a
  user-installed loader and provide asynchronous COM callbacks without placing
  `WebView2Loader.dll` in this package.

`GFX.WebView` itself contains no Objective-C, C or C++ source, native archive,
linker path, or package Boundary on any target. The unavailable fragments
deliberately fail before creating a second window or silently requiring an
undeclared binary.
