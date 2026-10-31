# Historique

## [Unreleased]

- Pont Windows UI Automation expérimental : contrôles, texte Unicode et plages, collections paresseuses, requêtes sur le thread UI et détachement des interfaces conservées. La qualification Windows/Inspect/Narrator reste ouverte ; une liaison croisée ne vaut pas exécution native.

- Source peut révéler une plage textuelle sans modifier focus, caret ou sélection, avec alignement au début ou à la fin du viewport.

- Pont Linux AT-SPI expérimental : chargement D-Bus optionnel, requêtes sur le thread UI, texte Unicode, collections indexées et notifications. Les constructions croisées et tests sans fenêtre ne remplacent pas la qualification native Linux/Orca, qui reste ouverte.

- Le pont macOS accepte les valeurs et positions décimales natives en les arrondissant explicitement vers la précision UI. Les nombres non finis ou hors de cette précision sont refusés avant les callbacks ; la politique des contrôles reste dans Source.

- Les sources accessibles peuvent rechercher un élément par coordonnées et annoncer la sélection multiple, avec des défauts compatibles pour les producteurs existants.

- Le pont macOS complète colonnes/en-têtes/tri, sélection et dépliage des collections, rôles des contrôles et géométrie textuelle à la demande. Source conserve des défauts compatibles ; les retours de rectangles respectent les ABI ARM64/Intel.

- Les sources accessibles peuvent fournir une vue Rows vivante et indexée, facultative pour les sources existantes. AppKit expose les lignes et l’accès direct aux cellules sans énumération globale ; identités, mutations et détachement sont éprouvés sans fenêtre. La navigation complète avec lecteur d’écran reste à qualifier.

- AppKit expose les dimensions des collections, les indices de lignes, les niveaux d’arbre et les plages de cellules à la demande, sans parcourir les enfants. Tests natifs sans fenêtre ; navigation complète des collections avec un lecteur d’écran à qualifier.

- Les présentateurs personnalisés peuvent préciser l’origine logique de leur source accessible. AppKit actualise le rectangle racine au déplacement ou redimensionnement de l’hôte, sans décaler deux fois les descendants ni parcourir la collection. Tests natifs sans fenêtre ; placement dans une vraie fenêtre à qualifier.

- AppKit raccorde la sélection textuelle contiguë des champs simples et multilignes : conversion UTF-16/graphèmes, texte sélectionné et longueur en lecture seule, plages invalides refusées et ancre inversée conservée. Échanges natifs éprouvés sans fenêtre ; parcours lecteur d’écran et géométrie textuelle à qualifier.

- AppKit expose les relations des libellés visibles et transmet les setters de sélection/dépliage aux actions annoncées par la source. Les appels répétés, désactivés, non pris en charge ou détachés ne modifient pas l’application. Les tests natifs sans fenêtre ne qualifient pas la navigation des collections avec un lecteur d’écran.

- AppKit expose les groupes radio, les bornes et l’orientation des curseurs ; cases/radios réutilisent leur état et leurs actions. Les callbacks refusent aussi les actions non annoncées ou désactivées. Le premier parcours bouton/champ est confirmé dans l’inspecteur et VoiceOver ; nouveaux contrôles en qualification.

- Premier adaptateur AppKit privé : Window accepte une Source accessible, synchronise les changements et détache ses pairs avant destruction ; enfants natifs paresseux. Parcours bouton/champ qualifié, autres contrôles et ponts Linux/Windows à venir.

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
