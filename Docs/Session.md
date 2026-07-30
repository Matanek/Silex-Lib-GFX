# Own the GFX platform session

`GFX.Session` is the direct lifetime boundary for window and input services.
It does not depend on `GFX.Bootstrap`:

```sx
use GFX.Session

func main() {
    var session = Session()
    run(session)
}
```

Construct `Session` on the main thread. Construction initializes the private
platform runtime and panics with a GFX diagnostic if initialization fails. One
session may be active in a process. Passing or storing the class shares that
session; it does not initialize another one.

When its last reference disappears, `drop` closes the runtime. Objects that
will depend on the session, such as windows, retain it so the runtime cannot be
closed before them. There is no manual `close()` and no SDL subsystem, flag or
handle in the public API.

## Use the same session from Bootstrap

A plugin can own the direct class through the typed resource registry:

```sx
use GFX.Bootstrap
use GFX.Session

func startup(application:Bootstrap.Application) {
    application.resources().insert(Session())
}

func update(session:@Session) {
    // The session is alive for this system.
}

func shutdown(application:Bootstrap.Application) {
    var removed = application.resources().remove<Session>()
    assert(removed != null)
}
```

Removing the resource transfers it into `removed`. Its end of scope releases
the plugin's root and closes the runtime when no dependent GFX object remains.
