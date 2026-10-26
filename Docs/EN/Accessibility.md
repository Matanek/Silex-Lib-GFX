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

## Request a collection’s rows

`Source.rows(id)` returns an optional `Rows` view, whose `count()` gives the
current row count and `row(index)` gives an opaque row ID. Existing sources
keep the `null` default: exposing dimensions alone does not enable this
relationship. A custom source supplies this view when it provides direct row
access without enumerating children or constructing their views.

This relationship follows current model order. For a tree, it includes rows
of expanded branches in display order, while `child` keeps the real hierarchy.
For a table, it excludes headers and scroll wrappers; a row’s children are its
cells in column order. Sorting can change an ID’s index without changing the ID.

The view is live and used on the source’s owning thread: mutations, collapse
and modal dialog restrictions also affect a retained view. An empty or no longer
accessible collection has zero size. Negative, out-of-range or inaccessible
indices return `null`. The row and column counts in `Element` must remain
consistent with this model. GFX.UI supplies these views automatically for lists,
trees and tables; applications need no additional configuration.

## Present a source in a window

`Window.set_accessibility_source(source)` associates a source with the window;
`null` detaches the previous one. A custom presenter then calls
`Window.update_accessibility()` after updating its content on the UI thread.
This method posts change notifications and returns `true` when a native action
has changed the source since the previous call: refresh the drawing and text
input target in that case. The window retains one reader and detaches its peers
before destruction.

For an offset drawing, pass `origin:Math.Vec2(x, y)` to
`set_accessibility_source`: this is its origin in logical window coordinates,
with Y pointing down. Pass a new origin to `update_accessibility(origin:...)`
when it moves; omitting this argument preserves the previous origin. Resizing
updates native bounds even when the source reports no change. Descendants stay
relative to their parents; moving the presentation does not traverse the collection.

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

## Locate rows and cells on macOS

AppKit reads the row and column counts declared by the source without
requesting its children. Table and outline rows carry their native subroles.
A row’s index uses `row_index` when supplied, otherwise `index`; a tree’s
sibling order therefore does not replace its position in the model. Tree
levels, counted from 1 in the source, become native indentation counted
from 0.

Each cell separately exposes its row range and column range, both with a
length of 1. These properties are read-only; absent or negative values are
not advertised. Queries follow the current source values without scanning
rows. Detached peers do not retain an old position.

AppKit also exposes `accessibilityRows` from this indexed view. Reading its
size or copying its array does not create peers for every row; requesting an
index creates only the requested peer. The child hierarchy uses the same native
identity. The array follows mutations and becomes inert when its presentation
is detached or destroyed, even if AppKit retains it.

For tables, `accessibilityCellForColumn:row:` directly requests a row and its
cell. Negative or out-of-range coordinates and cells with mismatched metadata
are rejected. Sources without a `Rows` view do not advertise it. These queries
change neither selection nor scroll position.

Headless native tests cover these exchanges on macOS ARM64 and Intel. Native
column arrays, sort properties and complete screen-reader navigation of
collections still need to be connected and qualified.
