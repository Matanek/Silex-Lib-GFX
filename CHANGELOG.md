# Changelog

## [Unreleased]

- During native event pumping, the Application runner redraws when the drawable's pixel size changes, after the early native watchers. It no longer waits for the next periodic expose to adapt a frame; main-thread, reentrancy, and shutdown guards remain active.

- The default Application runner updates and renders during native live resizing on the main thread, instead of stretching the last frame. Event pumping precedes scheduled systems and is shared with Bundle windows; recursive redraws are prevented. Custom runners retain responsibility for event pumping.

- Plugins can request dependencies during execution with `Application.require_plugin`. New services start at the end of the current stage, preserving existing services and explicit settings; shutdown respects dependency order.
