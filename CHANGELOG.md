# Changelog

## [Unreleased]

- Accessibility provides a UI-independent contract for describing and acting on a semantic source on demand, without Canvas or UI dependencies. No system bridge is provided yet.

- MouseId.is_touch() and TouchId.is_mouse() identify emulated pointer events so hosts can process each touch/mouse input once.

- Adopts one `Result` declaration: an ordinary call returns the value or
  stops the program on failure; `try call()` keeps the `Result`. Existing calls
  storing results and propagating failures are made explicit. This revision
  requires the development toolchain with these `try` semantics; publication
  must coordinate compiler and package versions.
  Recoverable `try_*` variants and direct wrappers with the same signature
  converge under the ordinary name. Boolean, optional, and native variants
  retain their contracts.

- MenuBar adds an optional macOS system bar with host-dispatched actions, submenus, availability and shortcuts while preserving existing system menus. Linux/Windows decline installation without graphics effects.

- Add window-owned system resize cursors with lazy allocation, reuse and cleanup; only the mouse-focused window applies its preference.

- The local macOS ARM64 Metal provider synchronizes presentation with the window’s Core Animation transaction, preventing the previous image from stretching during resize. The patched SDL build recipe and checksum are recorded; publication and macOS Intel qualification remain pending. Linux/Windows archives are unchanged.

- During native event pumping, the Application runner redraws when the drawable's pixel size changes, after the early native watchers. It no longer waits for the next periodic expose to adapt a frame; main-thread, reentrancy, and shutdown guards remain active.

- The default Application runner updates and renders during native live resizing on the main thread, instead of stretching the last frame. Event pumping precedes scheduled systems and is shared with Bundle windows; recursive redraws are prevented. Custom runners retain responsibility for event pumping.

- Plugins can request dependencies during execution with `Application.require_plugin`. New services start at the end of the current stage, preserving existing services and explicit settings; shutdown respects dependency order.
