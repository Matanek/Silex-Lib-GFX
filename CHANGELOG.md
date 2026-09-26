# Changelog

## [Unreleased]

- Plugins can request dependencies during execution with `Application.require_plugin`. New services start at the end of the current stage, preserving existing services and explicit settings; shutdown respects dependency order.
