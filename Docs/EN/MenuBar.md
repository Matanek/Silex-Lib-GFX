# System menu bar

`GFX.MenuBar.MenuBar` owns menus added to the macOS application bar.
`Item.command(label, action, shortcut:null, enabled:true)`, `Item.submenu(label, children)`
and `Item.separator()` describe entries; `Shortcut(key, primary:true, shift:false, alt:false)`
describes an AppKit key equivalent. The primary modifier is Command. Action IDs
are nonnegative integers chosen by the host.

`available()` is true on macOS and false on Linux/Windows. `install()` returns
false before SDL video startup, off the main thread, or when another bar is
installed. It starts no graphics service and is idempotent for its owner.
`installed()` reports its state.

AppKit queues action IDs; `take_actions()` drains them in order. User callbacks
do not execute inside the native event loop. Keyboard repeats are ignored and
an activation wakes an event-driven presenter. The host controls availability
with `set_enabled(action, bool)` and editing priority with
`set_shortcut_enabled(action, bool)`. Only changes are sent to AppKit. Entries
sharing an ID follow the same state.

`remove()` and destruction remove only owned menus, preserving the existing
bar and Application/Services/Window menus. Use the owner on the main thread,
keep it alive during presentation and remove menus when presentation ends.
Objective-C classes, handles and selectors remain private. GFX.UI.SystemMenu
adapts UI commands directly to this primitive.

The [MenuBar consumer](../../Tests/Consumer/Fixtures/MenuBar.sx) checks refusal
before graphics startup without a window. The adapter uses Cocoa and libobjc
on both macOS targets and adds no third-party archive. Intel linking and
Linux/Windows outputs are structural evidence; execution and interactive
checks are reported separately.
