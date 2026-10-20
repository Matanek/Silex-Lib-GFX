# Fournir ou inspecter une source sémantique

`GFX.Accessibility` décrit le sens d’une interface sans dépendre de Canvas ou
de GFX.UI. Un hôte peut inspecter la source fournie par une interface existante,
ou implémenter `Source` pour ses propres contrôles. Le premier adaptateur macOS
présente les éléments à AppKit ; sa qualification avec VoiceOver reste en cours.
Les adaptateurs Linux et Windows ne sont pas encore fournis.

## Lire et actionner la même interface

Conservez une `Source` pendant son utilisation, sur le thread propriétaire de
l’interface. `root()` donne sa racine active, `focused()` son focus et
`read(id)` les propriétés d’un élément. Demandez ses enfants par
`child(id, index)` : une grande collection ne doit pas devenir un tableau de
vues construit à l’avance. Chaque `Element` porte son rôle, son nom, ses
valeurs et états, ses relations et sa géométrie logique.

Les IDs sont opaques et propres à cette source. Un élément inaccessible retourne
`null`. `perform(id, Request(...))` invoque une des actions annoncées par
l’élément et retourne si elle a eu un effet. `changes()` consomme les
notifications ; une lecture ordinaire ne doit pas les effacer.

`Request` transporte selon l’action un texte, un nombre ou les extrémités d’une
sélection. Les positions de texte comptent les graphèmes Unicode. Un adaptateur
système doit convertir les unités de son API. Les bornes sont des coordonnées
logiques de dessin ; le présentateur possède leur conversion vers l’écran.

Le [consommateur indépendant](../../Tests/Consumer/Tests/Accessibility.sx)
implémente un réglage de volume, le lit via le protocole et modifie sa valeur.
Il n’importe que `GFX.Accessibility`. Les applications GFX.UI utilisent
`Label` et `Accessible`, puis `Session.accessibility()` ou
`Runtime.accessibility()` pour obtenir cette source.

## Présenter une source dans une fenêtre

`Window.set_accessibility_source(source)` associe une source à la fenêtre ;
`null` détache la précédente. Un présentateur personnalisé appelle ensuite
`Window.update_accessibility()` après ses mises à jour sur le thread UI. Cette
méthode émet les notifications de changement et retourne `true` lorsqu’une
action native a changé la source depuis l’appel précédent : le présentateur
doit alors rafraîchir son dessin et sa cible de saisie. La fenêtre conserve un
lecteur, puis détache ses pairs avant sa destruction.

`GFX.Viewer` réalise automatiquement ces étapes pour une `Canvas.Session`
fournissant `accessibility_source()`. Les sessions GFX.UI la fournissent déjà.
Aucun réglage ou handle natif n’est nécessaire dans l’application.

Sur macOS, le premier parcours couvre rôles/noms/valeurs, focus, activation et
modification du champ, géométrie et invalidation des pairs détachés. Les enfants
sont demandés à la source par index. Leurs tableaux AppKit restent paresseux :
leur taille ou leur copie ne matérialise pas toutes les lignes. Cette première
intégration ne constitue pas encore une qualification de tous les contrôles,
de la sélection de texte native ou du lecteur d’écran.
