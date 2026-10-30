# Changelog

## [Unreleased]

- Experimental Linux AT-SPI bridge: optional D-Bus loading, UI-thread queries, Unicode text, indexed collections and notifications. Cross-builds and headless tests do not replace native Linux/Orca qualification, which remains open.

- The macOS bridge accepts native decimal values and positions by explicitly rounding to UI precision. Non-finite or overflowing numbers are rejected before callbacks; control policy remains in Source.

- Accessibility sources can query an element at coordinates and describe multiple-selection support, with compatible defaults for existing producers.

- The macOS bridge adds columns/headers/sorting, collection selection/disclosure, remaining control roles and on-demand text geometry. Source keeps compatible defaults; rectangle forwarding follows ARM64 and Intel ABIs.

- Accessible sources can supply a live indexed Rows view, optional for existing sources. AppKit exposes rows and direct cell lookup without global enumeration; identities, mutations and detachment are tested without a window. Complete screen-reader navigation still needs qualification.

- AppKit exposes collection dimensions, row indices, outline levels and cell ranges on demand without scanning children. Headless native tests cover these properties; complete screen-reader collection navigation remains to be qualified.

- Custom presenters can specify their accessibility source’s logical origin. AppKit updates the root frame when the host moves or resizes, without translating descendants twice or traversing the collection. Native headless tests cover the exchange; placement in a real window remains to be qualified.

- AppKit connects contiguous text selection in single-line and multiline fields: UTF-16/grapheme conversion, read-only selected text and length, invalid-range rejection and reversed-anchor preservation. Native exchanges are tested without a window; screen reader paths and text geometry remain under qualification.

- AppKit exposes visible label relationships and routes selection/expansion setters to the source's advertised actions. Repeated, disabled, unsupported and detached calls leave the application unchanged. Headless native coverage does not qualify collection navigation with a screen reader.

- AppKit exposes radio groups, slider bounds and orientation; checkboxes/radios reuse source state and actions. Callbacks also reject disabled or unadvertised actions. The initial button/text-field path is confirmed with the inspector and VoiceOver; new controls remain under qualification.

- Initial private AppKit adapter: Window accepts an accessibility Source, synchronizes changes and detaches peers before destruction; native children stay lazy. The button/text-field path is qualified; remaining controls and Linux/Windows bridges are pending.

- Accessibility provides a UI-independent contract for describing and acting on a semantic source on demand, without Canvas or UI dependencies. Initial AppKit integration is undergoing qualification.

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
