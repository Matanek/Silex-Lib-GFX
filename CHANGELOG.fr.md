# Historique

## [Unreleased]

- Premier adaptateur AppKit privé : Window accepte une Source accessible, synchronise les changements et détache ses pairs avant destruction ; enfants natifs paresseux. Inspection/VoiceOver à qualifier, ponts Linux/Windows à venir.

- Accessibility fournit le contrat indépendant des interfaces pour décrire et actionner une source sémantique à la demande, sans dépendance à Canvas ou UI. Le premier raccordement AppKit est en qualification.

- Les identifiants MouseId.is_touch() et TouchId.is_mouse() signalent les événements de pointeur émulés ; les hôtes peuvent traiter une seule fois une entrée tactile/souris.

- Adopte la déclaration `Result` unique : l’appel ordinaire rend la valeur
  ou arrête le programme sur erreur ; `try appel()` conserve le `Result`. Les
  anciens appels stockant un résultat et propagations deviennent explicites.
  Cette révision requiert la toolchain de développement avec cette sémantique
  de `try` ; sa publication doit coordonner les versions du compilateur et des
  packages.
  Les variantes récupérables `try_*` et wrappers directs de même signature
  sont réunis sous le nom ordinaire. Les variantes booléennes, optionnelles ou
  natives gardent leur contrat.

- MenuBar ajoute une barre système macOS optionnelle, des commandes différées à l’hôte, sous-menus, disponibilité et raccourcis ; les menus système préexistants sont conservés. Linux/Windows refusent l’installation, sans effet graphique.

- Le provider Metal local macOS ARM64 synchronise la présentation avec la transaction Core Animation de la fenêtre, ce qui évite l’étirement de la dernière image pendant le redimensionnement. La recette SDL corrigée et son empreinte sont conservées ; sa publication et la qualification macOS Intel restent à effectuer. Les archives Linux/Windows sont inchangées.

- Pendant le pompage natif, le runner Application redessine dès que la taille en pixels de la surface change, après les observateurs natifs précoces. Il n’attend plus le prochain expose périodique pour adapter une frame ; les gardes de thread principal, réentrée et arrêt restent actives.

- Le runner Application par défaut recalcule et dessine pendant le redimensionnement natif continu, sur le thread principal, au lieu de laisser étirer la dernière frame. Le pompage des événements précède les étapes des systèmes et est partagé avec les fenêtres des Bundles ; les redessins récursifs sont évités. Les runners personnalisés conservent leur responsabilité de pompage.

- Les plugins peuvent demander une dépendance pendant l’exécution avec `Application.require_plugin`. Son démarrage est différé à la fin de l’étape courante ; les services existants et les réglages explicites sont conservés, et l’arrêt respecte les dépendances.
