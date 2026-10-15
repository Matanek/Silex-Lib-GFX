# Provide or inspect a semantic source

`GFX.Accessibility` describes the meaning of an interface without depending on
Canvas or GFX.UI. A host can inspect a source supplied by an existing interface,
or implement `Source` for its own controls. Desktop system bridges are not yet
provided.

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
