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
`resources()` si une ressource est nécessaire plus tôt ; aucun plugin ne peut
être ajouté après cette frontière. `Application.Time` fournit `FrameTime` et
`Application.FramePacing` limite une boucle sans mécanisme de présentation.

Les panneaux de développement appartiennent à `GFX.Stats`, pas au socle
Application.
