# Historique

## [Unreleased]

- Pendant le pompage natif, le runner Application redessine dès que la taille en pixels de la surface change, après les observateurs natifs précoces. Il n’attend plus le prochain expose périodique pour adapter une frame ; les gardes de thread principal, réentrée et arrêt restent actives.

- Le runner Application par défaut recalcule et dessine pendant le redimensionnement natif continu, sur le thread principal, au lieu de laisser étirer la dernière frame. Le pompage des événements précède les étapes des systèmes et est partagé avec les fenêtres des Bundles ; les redessins récursifs sont évités. Les runners personnalisés conservent leur responsabilité de pompage.

- Les plugins peuvent demander une dépendance pendant l’exécution avec `Application.require_plugin`. Son démarrage est différé à la fin de l’étape courante ; les services existants et les réglages explicites sont conservés, et l’arrêt respecte les dépendances.
