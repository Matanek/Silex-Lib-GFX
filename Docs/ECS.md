# GFX.ECS

`GFX.ECS` provides stable entities, typed components, spawn recipes, queries,
and deferred commands. No concrete scene component belongs to the ECS domain.

```silex
use GFX.ECS

struct Health { var value:int }

var world = ECS.World()
let entity = world.spawn(ECS.EntityRecipe()..with(Health(value:100)))
world.update<Health>(entity, func(health:&Health) { health.value -= 10 })
```

An `ECS.Query` makes the components it reads and mutates visible in its
signature. `ECS.Commands` defers structural changes so an active iteration
remains stable. `ECS.Plugin` installs the world and system integration into
`Application`.
