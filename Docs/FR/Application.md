# GFX.Application

`GFX.Application` compose des ressources typées, des systèmes ordonnancés et
des plugins ordinaires. Il ne choisit ni fenêtre, ni renderer, ni modèle de
scène.

```silex
use GFX.Application

func update(controller:&Application.Controller) {
    controller.stop()
}

Application()
    ..add_plugin(Application.Time())
    ..add_plugin(Application.FramePacing(60))
    ..add_system(Application.Schedule.update, update)
    ..run()
```

Un plugin implémente `Application.Plugin`, possède un identifiant stable et
enregistre explicitement ses ressources ou systèmes. Les étapes vont de
`initialize` à `finalize` ; `startup`, `update`, `render` et `shutdown`
décrivent le cycle récurrent. Les paramètres injectés déclarent les accès des
systèmes afin d’ordonner ou paralléliser les travaux compatibles.

`add_plugin` enregistre les instances jusqu’à `run`. Les dépendances ajoutées
pendant `build` sont résolues récursivement et une instance explicite remplace
toujours l’instance de repli, indépendamment de l’ordre des appels. Chaque
identifiant n’est construit qu’une fois.

`run` prépare automatiquement l’application. Appelez `prepare()` avant
`resources()` si une ressource est nécessaire plus tôt ; `add_plugin` ne peut
plus modifier la configuration après cette frontière. `Application.Time` fournit
`FrameTime` et `Application.FramePacing` limite une boucle sans mécanisme de
présentation.

Un plugin dont les besoins évoluent pendant l’exécution peut appeler
`application.require_plugin(plugin)` depuis un callback Application. La demande
est résolue à la fin de l’étape courante, après la fin de tous ses systèmes.
Seuls les nouveaux callbacks `initialize` et `startup` déjà dus sont exécutés ;
les services existants conservent leur état. Le plan des systèmes est recalculé
uniquement quand les dépendances changent. À l’arrêt, le plugin demandeur est
arrêté avant ses dépendances. Les demandes sont refusées pendant l’arrêt.
Une instance explicitement configurée avant la préparation reste prioritaire.
Hors d’un callback, `prepare()` ou l’étape suivante traite la demande.

`Resources.scope()` crée un magasin enfant vide. Une ressource locale masque
la ressource parente de même type ; une lecture absente localement consulte le
parent sans copier sa valeur. `remove` et `clear` ne retirent que les valeurs
locales. Cette primitive sert aux contextes de durée de vie plus courte, dont
les scènes fournies par le package `GFX.Application`.

Les panneaux de développement appartiennent à `GFX.Stats`, pas au socle
Application.

Le runner par défaut pompe les événements natifs avant `pre_update`. Pendant
un redimensionnement continu, les demandes natives de rafraîchissement sur le
thread principal peuvent exécuter `pre_update`, `update`, `post_update` et
`render` avant que le pompage ne retourne. Le layout et le rendu suivent ainsi
la taille courante pendant le glissement. Les fenêtres des Bundles partagent
ce pompage ; les systèmes et leurs jobs sont terminés avant son entrée.
Un événement provoqué par le rendu ne relance pas récursivement une frame.
Un changement de taille en pixels redessine dès que la surface native est prête,
sans attendre la prochaine demande périodique de rafraîchissement. Le changement
de taille logique seul ne déclenche pas ce redessin anticipé.
Cette intégration appartient au runner par défaut : `with_runner` conserve
son contrat et la responsabilité de piloter les événements dans une boucle
personnalisée. `Input.update()` employé directement continue à pomper lui-même.

## Mettre le jeu en pause

Chaque Application possède une ressource `Application.Simulation`. Ses méthodes
`pause()`, `resume()` et `is_paused()` contrôlent les mises à jour du jeu tout en
laissant tourner la boucle. `Application.Controller.stop()` conserve son rôle :
quitter cette boucle et exécuter les étapes de fermeture.

Ce programme utilise Échap pour alterner pause et reprise :

```silex
use GFX.Application
use GFX.Input
use GFX.Plugins

func pause_menu(input:@Input.State, simulation:&Application.Simulation) {
    if input.is_pressed(Input.Key.escape) {
        if simulation.is_paused() { simulation.resume() }
        else { simulation.pause() }
    }
}

func main() {
    Application()
        ..add_plugin(Plugins.Window())
        ..add_system(Application.Schedule.update, pause_menu,
            process_mode:Application.ProcessMode.always)
        ..run()
}
```

`add_system` et `add_after_system` acceptent un troisième argument optionnel
`process_mode`, pour les callbacks recevant l’Application comme pour les systèmes
à paramètres injectés :

| Mode | Exécution |
| --- | --- |
| `inherit` (par défaut) | Mises à jour suspendues pendant la pause ; rendu maintenu. |
| `pausable` | Uniquement lorsque la simulation est active. |
| `always` | Avec ou sans pause, par exemple pour écouter Échap. |
| `when_paused` | Uniquement pendant la pause, par exemple pour le menu. |
| `disabled` | Aucune exécution aux étapes récurrentes. |

La règle concerne `pre_update`, `update`, `post_update` et `render`. Les étapes
`initialize`, `startup`, `shutdown` et `finalize` s’exécutent toujours. Les
services intégrés continuent à traiter les entrées, la fermeture de fenêtre, le
rendu, l’UI hébergée par Viewer et les messages WebView. Les commandes ECS déjà
émises sont encore appliquées. La pause ne verrouille pas le World : les systèmes
`always` peuvent continuer à le modifier. L’audio déjà lancé continue aussi.

La décision est prise avant chaque groupe de systèmes pouvant s’exécuter
ensemble. Une demande ne coupe pas les travaux déjà lancés ; le groupe suivant
observe le nouvel état. `Application.should_process(mode, paused)` permet à un
plugin d’appliquer les mêmes règles à ses propres objets ; hors contexte de
hiérarchie ou de rendu, `inherit` y équivaut à `pausable`.

Avec `Application.Time`, `Simulation.delta()` vaut zéro pendant la pause et
`Simulation.elapsed()` reste figé. L’horloge avance une fois en `pre_update` ;
la reprise utilise le delta courant, sans accumuler la durée de la pause.
`FrameTime` reste le temps réel de l’application pour l’UI et les services.
Un plugin doit soit laisser ses systèmes suspendus par défaut, soit les déclarer
`always` et filtrer ses objets, comme le font Nodes et Animation.
