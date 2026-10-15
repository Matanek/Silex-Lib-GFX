# Fournir ou inspecter une source sémantique

`GFX.Accessibility` décrit le sens d’une interface sans dépendre de Canvas ou
de GFX.UI. Un hôte peut inspecter la source fournie par une interface existante,
ou implémenter `Source` pour ses propres contrôles. Les ponts vers les systèmes
desktop ne sont pas encore fournis.

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
