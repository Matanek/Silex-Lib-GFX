# Compose a GFX application

`GFX.Bootstrap` orchestrates optional plugins and scheduled systems. Direct GFX
modules do not depend on it. `GFX.Plugins` will contain the integrations that
connect future window, event, audio, and rendering APIs to this bootstrap.

## Define and install a plugin

A plugin is an ordinary configured value conforming to `Bootstrap.Plugin`:

```sx
use GFX.Bootstrap.Plugin
use GFX.Bootstrap.Application
use GFX.Bootstrap.Schedule

struct WindowPlugin:Plugin {
    let title:str

    func id() str {
        return "GFX.Window"
    }

    func build(application:Application) {
        application.add_system(Schedule.startup, create_window)
        application.add_system(Schedule.shutdown, destroy_window)
    }
}

func create_window() {}
func destroy_window() {}

Application()
    ..install(WindowPlugin(title:"Viewer"))
    ..run()
```

The plugin ID is its application-wide identity. Reinstalling the same ID does
nothing. A plugin installs its dependencies before registering its own systems;
a recursive installation reports a dependency-cycle panic. Installation and
system registration are locked when `run()` begins.

## Schedule systems

A system is a named function or captureless anonymous function. It may receive
the application directly:

```sx
func update(application:Bootstrap.Application) {
    if finished() {
        application.stop()
    }
}

application.add_system(Bootstrap.Schedule.update, update)
```

More commonly, its borrowed parameters declare resource dependencies:

```sx
func update(time:@Time, world:&World) {
    world.advance(time.delta)
}

application.add_system(Bootstrap.Schedule.update, update)
```

`@T` requests shared read access and `&T` requests exclusive mutable access.
The registration creates a private `func(Application)` adapter; schedules and
stored callbacks keep their existing representation. A missing dependency
panics before the call and names both the system and resource type. Repeated
reads of one type are valid, while a repeated access involving `&T` is rejected
at compile time.

`func()` and `func(Application)` remain valid. `Application` must be the sole
parameter because it represents unrestricted access. Systems return `void`;
optional injection and derived ECS query parameters are not part of this first
contract.

## Control the application from a system

Every application provides a `Controller` resource. Inject it mutably when a
system needs to send application-level commands without gaining unrestricted
access to `Application` or its resource registry:

```sx
use GFX.Bootstrap.Controller
use GFX.Input
use GFX.Input.State as InputState

func react(input:@InputState, controller:&Controller) {
    if input.is_quit_requested() {
        controller.stop()
    }
}
```

`stop()` requests termination at the next loop condition. Shutdown and
finalize schedules still run normally. `&Controller` makes the command an
explicit write dependency for the scheduler. The application creates this
resource automatically; plugins and application startup code do not install
it.

## Share typed resources

Every application owns an isolated `Bootstrap.Resources` registry. A resource
is addressed by its canonical concrete type, including all generic arguments:

```sx
var resources = application.resources()
resources.insert(Time())

if true {
    let time:@Time = resources.get<Time>()
    print(time.delta)
}

if true {
    var world:&World = resources.get_mut<World>()
    world.advance()
}
```

`insert` replaces and destroys an existing value of the same type. `has`
checks presence; `get` and `get_mut` panic with the missing type when absent;
`try_get` and `try_get_mut` borrow the optional slot; `remove` transfers its
value as `T?`; and `clear` destroys remaining values in reverse insertion
order. An alias or reexport denotes the same slot, while `Cache<int>` and
`Cache<str>` denote different slots.

The registry has no string keys, public type IDs, casts, global storage, or
reflection API. The compiler specializes private typed slots for the closed
program, while each `Application` keeps its own runtime presence and insertion
order. Ordinary borrow rules prevent replacement, removal, or clearing while
a resource alias is alive.

The default runner executes:

```text
initialize -> startup
while running:
    pre_update -> update -> post_update -> render
shutdown -> finalize
```

Systems keep registration order. `shutdown` and `finalize` reverse that order,
so a dependent plugin is dismantled before the dependency it installed.
`add_after_system` creates a second group that runs after the ordinary systems
of the same schedule. A custom runner may invoke `run_schedule` directly.

The generated access list remains internal, so a future parallel scheduler can
reason about read/write conflicts without changing system signatures.
