# Provide or inspect a semantic source

`GFX.Accessibility` describes the meaning of an interface without depending on
Canvas or GFX.UI. A host can inspect a source supplied by an existing interface,
or implement `Source` for its own controls. The first macOS adapter presents
elements to AppKit; the initial button/text-field path has been checked with
the inspector and VoiceOver. Qualification of other controls continues. Linux and Windows
adapters are not yet provided.

## Read and act on the same interface

Retain a `Source` while using it, on the interface’s owner thread. `root()`
returns its active root, `focused()` its focus and `read(id)` an element’s
properties. Request children through `child(id, index)`: a large collection
must not become an eagerly constructed array of views. Each `Element` carries
its role, name, values and states, relationships and logical geometry.

IDs are opaque and scoped to the source. An inaccessible element returns
`null`. `perform(id, Request(...))` invokes an action advertised by the element
and reports whether it had an effect. `changes()` consumes notifications;
an ordinary read must not clear them.

Depending on the action, `Request` carries text, a number or selection endpoints.
Text positions count Unicode graphemes. A system adapter must convert its API’s
index units. Bounds use logical drawing coordinates; the presenter owns their
conversion to screen coordinates.

The [independent consumer](../../Tests/Consumer/Tests/Accessibility.sx)
implements a volume control, reads it through the protocol and changes its value.
It imports only `GFX.Accessibility`. GFX.UI applications use `Label` and
`Accessible`, then `Session.accessibility()` or `Runtime.accessibility()`
to obtain this source.

## Present a source in a window

`Window.set_accessibility_source(source)` associates a source with the window;
`null` detaches the previous one. A custom presenter then calls
`Window.update_accessibility()` after updating its content on the UI thread.
This method posts change notifications and returns `true` when a native action
has changed the source since the previous call: refresh the drawing and text
input target in that case. The window retains one reader and detaches its peers
before destruction.

`GFX.Viewer` performs these steps automatically for a `Canvas.Session` providing
`accessibility_source()`. GFX.UI sessions already supply it. Applications need
no additional setting or native handle.

On macOS, the first path covers roles/names/values, focus, button activation,
field editing, geometry and invalidation of detached peers. Children are queried
by index. Their AppKit arrays remain lazy: counting or copying them does not
materialize every row. This first integration does not yet qualify every
control, text-selection paths or collections with a screen reader.

Checkboxes and radio buttons expose their state through their native value;
activation reuses the source action. Radio groups use the corresponding AppKit
role. Sliders expose their numeric value, bounds and orientation, and accept
the increment, decrement and value-setting actions advertised by the source.
Disabled controls and unadvertised actions are rejected even when a client
invokes the callback directly. Native tests cover these exchanges; their
VoiceOver path still needs qualification.

Label relationships are also presented to AppKit: a control references its
visible title, and that title references the control it names. Reading a
relationship requests only its target; an inaccessible ID does not create
a native peer.

Native selection and expansion setters use the `select`/`deselect` and
`expand`/`collapse` actions respectively. They are available only when the
source announces a corresponding action and state. Each call checks its
direction, control availability and requested state transition. It does not
change a separate copy of state in AppKit. Headless native tests cover these
exchanges; they do not by themselves qualify collection navigation with a
screen reader.

## Select text from macOS

Single-line and multiline fields expose their contiguous selection, selected
text and content length. Native positions count UTF-16 units; `Source` keeps
Unicode grapheme indices. A request cutting through a grapheme selects that
whole grapheme. A caret requested inside a grapheme moves to its start. Ranges
outside the text or marked `NSNotFound` are ignored without arithmetic overflow.

Reading does not change the application's selection direction. Repeating the
same native span also preserves a reversed anchor. Disabled controls and those
without the `set_text_selection` action reject changes. Selected text and
content length are read-only; content edits continue to use the field's value.
Multiple selections are not exposed: the `Source` contract describes one span.

Headless native tests verify these exchanges on macOS ARM64 and Intel. Screen
reader paths and text geometry still need qualification.
