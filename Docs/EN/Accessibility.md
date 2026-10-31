# Provide or inspect a semantic source

`GFX.Accessibility` describes the meaning of an interface without depending on
Canvas or GFX.UI. A host can inspect a source supplied by an existing interface,
or implement `Source` for its own controls. The first macOS adapter presents
elements to AppKit; the initial button/text-field path has been checked with
the inspector and VoiceOver. Qualification of other controls continues. A Linux AT-SPI adapter is experimental and still requires qualification on
Linux. A Windows UI Automation adapter is also experimental, with native
qualification still open.

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

Headless native tests cover these exchanges on macOS ARM64 and Intel. Column
relations and sorting are described below; complete screen-reader collection
navigation still needs qualification.


## Columns, headers and selection

`Source.columns(id)` optionally supplies a live `Columns` view: `count()` reads
its size and `column(index)` returns an opaque model identity without scanning
rows. A column has role `column`, its table `parent`, `column_index` and the
`header` relation. The header keeps its identity and actions;
`sorted_descending` describes current sorting, or `null` when unsorted.
Existing sources return `null` unless they implement this capability.

AppKit projects these relations into native columns. Their cells are requested
through the table’s indexed rows; a query never constructs every cell.
`Rows.selected()` returns only selected identities, with a compatible empty
default. A tree row’s row view describes its disclosed children and follows
collapse. Retained native arrays become inert when detached, like row arrays.

## Text geometry

`Source.text_geometry(id)` optionally supplies `TextGeometry`, queried only on
demand. `TextRange(start,length)` counts whole graphemes, like selection
requests. `bounds(selection)` returns the visible enclosing rectangle, or
`null` outside the viewport; an empty span describes the caret.
`range_at(x,y)` describes the grapheme at a position, while
`line_for_index(index)` and `range_for_line(line)` connect indices and lines.
A line span includes its newline. `visible_range()` describes visible text.
Coordinates share the top-left origin of `Element.bounds`; the contract
contains no AppKit coordinates.

UI supplies this capability for single-line and multiline editors from their
current layout and scrolling. A retained provider does not expose a removed
editor or one outside a new modal scope. AppKit converts UTF-16 indices
and screen coordinates at its boundary. Span, line and position queries do
not edit the application’s selection.

`Source.reveal_text(id,span,align_to_start)` asks to reveal text without moving
focus, caret, or selection. `span` is a grapheme-based `TextRange`. `true`
aligns its first line with the top of the viewport; `false` aligns its last
line with the bottom, within the available scroll extent. It returns `true`
for an accepted request, including a range that was already visible. The
default implementation returns `false`. UI sources provide it for single-line
and multiline fields, including disabled ones.

## Other macOS controls

The bridge distinguishes tabs, scrollbars, splitters, help tags and headers.
Dialogs expose modality and cancellation. Tabs expose their titles and
selection, and radio groups expose their selected choice. Choice opening and
scrolling use actions announced by the source, rejecting disabled actions.
Declared shortcuts supplement accessible command help.

Native tests exercise queries and detachment without a window on macOS ARM64
and Intel, in Debug and Release. A real-window inspector and VoiceOver run is
a separate qualification. These tests make no Linux or Windows native claim.

Row selection changes notify the presented collection.
Disclosure transitions use native row-expanded/row-collapsed notifications,
without announcing another disclosure for unrelated state changes.

When `Rows.selected()` changes, the source notifies the collection with
`ChangeKind.selection`. UI retains a selection observation per container,
refreshed by model or location revision even when children have not been read.
A live read does not consume that event.

## Locate an element and describe selection

`Source.element_at(x,y)` returns the identity of the accessible element at
those coordinates, in the same coordinate system as `Element.bounds`. This
semantic query includes static and disabled elements; it changes neither focus
nor selection. Its `null` default preserves existing sources that do not supply
this capability. A large-collection producer should use its visible layout
without scanning or constructing logical rows outside the viewport.

`Element.multiple_selection` reports whether the collection accepts multiple
selections, independently of its current selected count. It defaults to `false`.
A change to this capability is a state change.

## Native decimal values

The macOS bridge rounds native values and positions to the source's floating
precision. It rejects non-finite or overflowing numbers before calling the
source. Range validation and clamping remain defined by `Source.perform`,
consistently with the control's other inputs.

## Experimental Linux bridge

`Window.set_accessibility_source` also connects the source to the AT-SPI bus
when available. The adapter loads `libdbus-1.so.3` on demand and obtains the
address from `org.a11y.Bus` on the session bus. A system without this service
or library keeps the ordinary interface. GTK and GLib do not become application
dependencies.

Queries and actions stay on the UI thread. The I/O thread only handles
transport and wakes the host. Registry embedding is asynchronous; detachment
stops this thread before closing the connection. A system tool may retain an
old path: it becomes unavailable and never identifies a new control reusing
the same source ID.

The bridge exposes application, window, roles, names, relations, states,
actions, values and coordinates. Tables provide headers followed by indexed
cells without realizing offscreen rows. Selection queries use `Rows.selected()`;
selecting every row and selecting columns are not simulated by thousands of
individual actions. Cache and notifications remain limited to exposed objects;
virtual collections advertise that they manage their descendants.

AT-SPI counts text positions in Unicode scalars, while `Source` counts
graphemes. The bridge converts these units for reading, caret, selection,
editing, clipboard and geometry supplied by `TextGeometry`. Mutations preserve
whole graphemes. Word navigation follows the editor's Unicode classes;
sentences use paragraphs without claiming grammatical segmentation. Text
attributes describe plain text. Complex bounded ranges and scrolling to a
text subrange are unsupported.

On X11, screen coordinates use the window position. On Wayland, an unavailable
global position is reported as unavailable; relative coordinates remain usable.
The adapter does not invent a screen position from the local origin.

Model tests, native codec tests and cross-builds do not constitute execution on
Linux. Bus operation, Orca, desktop interactions and coordinate conventions at
different scale factors still require qualification on the target systems.
This experimental status does not change ordinary-use acceptance of macOS
controls.


## Experimental Windows bridge

`Window` connects the same `Source` to UI Automation on the UI thread. Roles,
names, values, states, relations, and actions supply Invoke, Value, RangeValue,
Toggle, Selection/SelectionItem, ExpandCollapse, Grid/GridItem, Table/TableItem,
ScrollItem, and Text/TextRange patterns according to the described capabilities.
Indexed tables realize only requested rows and cells; headers retain their
identity after reparenting.

Text ranges keep grapheme endpoints. Native strings use UTF-16, including
embedded zeros in BSTRs; reading, Unicode search, selection, and geometry are
translated at the boundary. `ScrollIntoView` uses `reveal_text` without changing
selection. Custom producers supply `text_geometry` and `reveal_text` for these
queries; missing capabilities remain unavailable. Retained ranges are clamped
to current content after editing and do not yet track text moves through edit
anchors. Exposed attributes describe plain text.

Logical dialogs offer the close action described by their source without adding
native maximize or minimize behavior. The HWND retains its system window
behavior. Notifications do not realize unknown elements. Interfaces retained
after detachment become unavailable and cannot revive an old identity.

CPU tests and ARM64/X64 builds from macOS prove the model, exercised calling
conventions, and linkage. They do not prove Windows execution: Inspect/Narrator,
actual focus, coordinates at different scales, idle-loop wakeup, and callbacks
during closure still require native qualification. The [Windows fixture](../../Tests/Accessibility/Windows.sx)
checks COM references, native arrays, strings, and detached requests without a
window on the target OS. The public UIAccessibility demo then provides the
interactive path. These tests require a compiler including this candidate's
native C entries and records.
