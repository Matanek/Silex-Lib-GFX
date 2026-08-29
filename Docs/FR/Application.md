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

`Resources.scope()` crée un magasin enfant vide. Une ressource locale masque
la ressource parente de même type ; une lecture absente localement consulte le
parent sans copier sa valeur. `remove` et `clear` ne retirent que les valeurs
locales. Cette primitive sert aux contextes de durée de vie plus courte, dont
les scènes fournies par le package `GFX.Application`.

Les panneaux de développement appartiennent à `GFX.Stats`, pas au socle
Application.
