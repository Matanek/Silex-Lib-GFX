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

## Demander les lignes d’une collection

`Source.rows(id)` retourne une vue `Rows` optionnelle, dont `count()` donne le
nombre courant de lignes et `row(index)` leur ID opaque. Les sources existantes
conservent le défaut `null` : exposer des dimensions seules n’active pas cette
relation. Une source personnalisée fournit cette vue lorsqu’elle propose un
accès direct à ses lignes, sans énumérer ses enfants ni construire leurs vues.

Cette relation suit l’ordre courant du modèle. Pour un arbre, elle comprend
les lignes des branches dépliées dans l’ordre affiché, tandis que `child`
conserve la vraie hiérarchie. Pour un tableau, elle exclut les en-têtes et les
conteneurs de défilement ; les enfants d’une ligne sont ses cellules, dans
l’ordre des colonnes. Un tri peut changer l’index d’un ID sans changer cet ID.

La vue est vivante, utilisable sur le même thread que la source : les mutations,
le repli et les restrictions d’un dialogue modal s’appliquent aussi à une vue
déjà conservée. Une collection vide ou devenue inaccessible a une taille nulle.
Un index négatif, hors de la taille courante ou devenu inaccessible retourne
`null`. Les nombres de lignes et colonnes de `Element` doivent rester cohérents
avec ce modèle. GFX.UI fournit automatiquement ces vues pour ses listes,
arbres et tableaux ; l’application ne configure rien de plus.

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

## Situer les lignes et cellules sur macOS

AppKit lit les nombres de lignes et de colonnes déclarés par la source sans
demander ses enfants. Les lignes de tableau et d’arbre portent leurs sous-rôles
natifs. L’index d’une ligne utilise `row_index` lorsqu’il est fourni, sinon
`index` ; l’ordre des frères d’un arbre ne remplace donc pas sa position dans
le modèle. Le niveau d’arbre, compté depuis 1 dans la source, devient une
indentation native comptée depuis 0.

Chaque cellule expose séparément sa plage de ligne et sa plage de colonne,
avec une longueur de 1. Ces propriétés sont en lecture seule ; les valeurs
absentes ou négatives ne sont pas annoncées. Les lectures suivent les valeurs
courantes de la source et ne parcourent pas les lignes. Un pair détaché ne
conserve pas une ancienne position.

AppKit expose aussi `accessibilityRows` depuis cette vue indexée. Lire sa taille
ou copier son tableau ne crée pas de pairs pour toutes les lignes ; demander
un index ne crée que le pair demandé. La même identité native reste utilisée
par la hiérarchie des enfants. Le tableau suit les mutations et devient inerte
lorsque sa présentation est détachée ou détruite, même si AppKit le conserve.

Pour les tableaux, `accessibilityCellForColumn:row:` demande directement la
ligne puis sa cellule. Les coordonnées négatives, hors limites et les cellules
dont les métadonnées ne correspondent pas sont refusées. Les sources sans vue
`Rows` ne l’annoncent pas. Ces requêtes ne modifient ni sélection ni défilement.

Les tests natifs sans fenêtre couvrent ces échanges sur macOS ARM64 et Intel.
Les relations de colonnes et de tri sont décrites ci-dessous ; la navigation
complète des collections avec un lecteur d’écran reste à qualifier.


## Colonnes, en-têtes et sélection

`Source.columns(id)` fournit une vue `Columns` facultative : `count()` lit la
taille, `column(index)` retourne une identité opaque du modèle sans parcourir
ses lignes. Une colonne porte le rôle `column`, son `parent` tableau,
`column_index` et la relation `header`. Son en-tête conserve son identité et
ses actions ; `sorted_descending` décrit le tri courant, ou `null` sans tri.
Les sources existantes qui n’implémentent pas cette capacité retournent `null`.

AppKit projette ces relations en colonnes natives. Leurs cellules sont demandées
par les lignes indexées du tableau ; une requête ne construit pas toutes les
cellules. `Rows.selected()` retourne les seules identités sélectionnées, avec
un défaut vide compatible. Les vues de lignes d’un nœud d’arbre décrivent ses
enfants dépliés et suivent le repli. Les tableaux natifs conservés deviennent
inertes au détachement, comme les lignes déjà exposées.

## Géométrie du texte

`Source.text_geometry(id)` fournit une capacité `TextGeometry` facultative,
consultée uniquement à la demande. `TextRange(start,length)` compte des
graphèmes complets, comme les requêtes de sélection. `bounds(selection)`
retourne le rectangle visible englobant la plage, ou `null` hors du viewport ;
une plage vide décrit le caret. `range_at(x,y)` décrit le graphème à une
position, `line_for_index(index)` et `range_for_line(line)` relient indices et
lignes. Une plage de ligne inclut son saut de ligne. `visible_range()` décrit
la plage visible. Les coordonnées utilisent la même origine en haut à gauche
que `Element.bounds` ; aucune coordonnée AppKit n’entre dans ce contrat.

UI fournit cette capacité pour ses champs simples et multilignes à partir de
leur layout et de leur défilement actuels. Un fournisseur conservé ne réexpose
pas un champ retiré ou caché par une nouvelle portée modale. AppKit traduit les
indices UTF-16 et les coordonnées écran à la frontière ; les lectures de
plages, lignes et positions n’éditent pas la sélection applicative.

## Autres contrôles macOS

Le pont distingue onglets, barres de défilement, séparateurs, infobulles et
en-têtes. Les dialogues exposent leur caractère modal et l’action d’annulation.
Les onglets exposent leurs titres et leur sélection ; les groupes radio leur
choix sélectionné. L’ouverture des choix et le défilement utilisent les actions
annoncées par la source, avec le même refus des actions désactivées. Les
raccourcis déclarés complètent l’aide accessible des commandes.

Les tests natifs exercent les requêtes et le détachement sans fenêtre, sur
macOS ARM64 et Intel, en Debug et Release. Le parcours dans une fenêtre réelle
avec l’inspecteur et VoiceOver reste une qualification distincte ; aucune
prise en charge native Linux ou Windows n’est déduite de ces tests.

Les changements de sélection de lignes notifient la collection présentée ; les transitions de dépliage utilisent les notifications
natives de ligne dépliée/repliée, sans annoncer un nouveau dépliage pour un
autre changement d’état.

Quand `Rows.selected()` change, la source notifie la collection avec
`ChangeKind.selection`. UI conserve une observation de sélection par conteneur,
réévaluée à la révision du modèle ou de ses emplacements, même sans lecture
préalable des enfants. Une lecture courante ne consomme pas cet événement.
