# Changelog

## [Unreleased]

- The default Application runner updates and renders during native live resizing on the main thread, instead of stretching the last frame. Event pumping precedes scheduled systems and is shared with Bundle windows; recursive redraws are prevented. Custom runners retain responsibility for event pumping.

- Plugins can request dependencies during execution with `Application.require_plugin`. New services start at the end of the current stage, preserving existing services and explicit settings; shutdown respects dependency order.
