# Historique

## [Unreleased]

- Le provider Metal local macOS ARM64 synchronise la présentation avec la transaction Core Animation de la fenêtre, ce qui évite l’étirement de la dernière image pendant le redimensionnement. La recette SDL corrigée et son empreinte sont conservées ; sa publication et la qualification macOS Intel restent à effectuer. Les archives Linux/Windows sont inchangées.

- Pendant le pompage natif, le runner Application redessine dès que la taille en pixels de la surface change, après les observateurs natifs précoces. Il n’attend plus le prochain expose périodique pour adapter une frame ; les gardes de thread principal, réentrée et arrêt restent actives.

- Le runner Application par défaut recalcule et dessine pendant le redimensionnement natif continu, sur le thread principal, au lieu de laisser étirer la dernière frame. Le pompage des événements précède les étapes des systèmes et est partagé avec les fenêtres des Bundles ; les redessins récursifs sont évités. Les runners personnalisés conservent leur responsabilité de pompage.

- Les plugins peuvent demander une dépendance pendant l’exécution avec `Application.require_plugin`. Son démarrage est différé à la fin de l’étape courante ; les services existants et les réglages explicites sont conservés, et l’arrêt respecte les dépendances.
