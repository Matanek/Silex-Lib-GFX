# Fournir ou inspecter une source sémantique

`GFX.Accessibility` décrit le sens d’une interface sans dépendre de Canvas ou
de GFX.UI. Un hôte peut inspecter la source fournie par une interface existante,
ou implémenter `Source` pour ses propres contrôles. Le premier adaptateur macOS
présente les éléments à AppKit ; le premier parcours bouton/champ a été vérifié
avec l’inspecteur et VoiceOver. La qualification des autres contrôles continue.
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

Si le dessin est décalé, passez `origin:Math.Vec2(x, y)` à
`set_accessibility_source` : il désigne son origine dans la fenêtre, en unités
logiques, avec Y vers le bas. Passez une nouvelle origine à
`update_accessibility(origin:...)` lorsqu’elle change ; sans cet argument,
l’origine précédente est conservée. Le redimensionnement actualise les bornes
natives même si la source ne signale aucun changement. Les descendants restent
relatifs à leurs parents ; déplacer la présentation ne parcourt pas la collection.

`GFX.Viewer` réalise automatiquement ces étapes pour une `Canvas.Session`
fournissant `accessibility_source()`. Les sessions GFX.UI la fournissent déjà.
Aucun réglage ou handle natif n’est nécessaire dans l’application.

Sur macOS, le premier parcours couvre rôles/noms/valeurs, focus, activation et
modification du champ, géométrie et invalidation des pairs détachés. Les enfants
sont demandés à la source par index. Leurs tableaux AppKit restent paresseux :
leur taille ou leur copie ne matérialise pas toutes les lignes. Cette première
intégration ne constitue pas encore une qualification de tous les contrôles,
du parcours de sélection textuelle ou des collections avec lecteur d’écran.

Les cases à cocher et boutons radio exposent leur état par leur valeur native ;
l’activation réutilise l’action de la source. Les groupes radio portent le rôle
AppKit correspondant. Les curseurs exposent leur valeur numérique, leurs bornes
et leur orientation, et acceptent les actions d’incrément, de décrément et de
modification annoncées par la source. Un contrôle désactivé ou une action non
annoncée n’est pas actionné, même si un client invoque directement le callback.
Le test natif couvre ces échanges ; leur parcours VoiceOver reste à qualifier.

Les relations de libellés sont également présentées à AppKit : un contrôle
référence son titre visible, et ce titre référence le contrôle qu’il nomme.
Lire une relation ne demande que son destinataire ; un ID devenu inaccessible
ne crée pas de pair natif.

Les setters natifs de sélection et de dépliage utilisent respectivement les
actions `select`/`deselect` et `expand`/`collapse`. Ils restent disponibles
seulement lorsque la source annonce une action correspondante et un état.
Chaque appel vérifie sa direction, la disponibilité du contrôle et le changement
d’état demandé. Il ne modifie pas une copie d’état dans AppKit. Les tests natifs
couvrent ces échanges sans fenêtre ; ils ne qualifient pas à eux seuls la
navigation d’une collection dans un lecteur d’écran.

## Sélectionner du texte depuis macOS

Les champs simples et multilignes exposent leur sélection contiguë, le texte
sélectionné et la longueur du contenu. Les positions natives comptent des
unités UTF-16 ; `Source` conserve ses index en graphèmes Unicode. Une demande
qui coupe un graphème sélectionne celui-ci en entier. Un caret demandé dans
un graphème se place à son début. Les plages hors du texte ou marquées
`NSNotFound` sont ignorées, sans dépassement arithmétique.

Une lecture ne change pas le sens de la sélection de l’application. Répéter
la même plage native conserve aussi une ancre inversée. Les contrôles
désactivés ou sans action `set_text_selection` refusent les changements.
Le texte sélectionné et la longueur sont en lecture seule ; la modification
du contenu continue d’utiliser la valeur du champ. Les sélections multiples
ne sont pas exposées : le contrat de `Source` décrit une seule plage.

Les tests natifs vérifient ces échanges sans fenêtre sur macOS ARM64 et Intel.
Le parcours avec lecteur d’écran et la géométrie du texte restent à qualifier.
