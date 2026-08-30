# GFX.Input

`GFX.Input` transforme les événements SDL en valeurs GFX copiées et en état de
frame réutilisable. Aucun union natif ni pointeur temporaire n’est exposé.

```silex
use GFX.Input

if input.is_down(Input.Key.left) { print("left") }
for event in input.events() {
    match event {
        window_close_requested(value) => { print(value.window.value) }
        else => {}
    }
}
```

`Input.Plugin` publie l’état dans `Application`. `Window.Plugin` l’installe
automatiquement. Transitions, mouvements, défilement et texte appartiennent à
une frame ; l’état continu des touches, boutons et appareils survit à la mise à
jour suivante.

Plusieurs contextes `Input` peuvent coexister dans le même processus. Chacun
reçoit une copie du même flux d’événements de plateforme et conserve son propre
état de frame. Deux fenêtres appartenant à deux Bundles ne se disputent donc
pas la file SDL.

Hors d’`Application`, créez un `Input`, appelez `wait()` lorsque le programme
peut dormir, puis `update()` exactement une fois avant de lire l’état et les
événements de ce tour.
