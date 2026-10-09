# Barre de menus système

`GFX.MenuBar.MenuBar` possède les menus ajoutés à la barre d’application macOS.
`Item.command(label, action, shortcut:null, enabled:true)`, `Item.submenu(label, children)`
et `Item.separator()` décrivent les entrées ; `Shortcut(key, primary:true, shift:false, alt:false)`
décrit un équivalent clavier AppKit. Le modificateur principal est Command.
Les identifiants d’action sont des entiers positifs ou nuls choisis par l’hôte.

`available()` vaut true sur macOS, false sur Linux/Windows. `install()` retourne
false si SDL vidéo n’a pas été démarré, si l’appel n’est pas sur le thread
principal ou si une autre barre est installée. Il ne démarre aucun service
graphique et est idempotent pour son propriétaire. `installed()` décrit son état.

AppKit enregistre les actions dans une file ; `take_actions()` la vide et renvoie
les identifiants dans leur ordre. Aucun callback utilisateur n’est exécuté dans
la boucle native. La répétition clavier est ignorée et une activation réveille
un hôte événementiel. L’hôte contrôle la disponibilité avec `set_enabled(action, bool)`
et la priorité d’édition avec `set_shortcut_enabled(action, bool)`. Seuls les
changements sont transmis à AppKit. Les entrées partageant un identifiant suivent
le même état.

`remove()` et la destruction retirent uniquement les menus possédés, sans remplacer
la barre ni ses menus Application/Services/Fenêtre. Utiliser l’objet sur le thread
principal, le conserver pendant la présentation et retirer les menus à sa fin.
Les classes, handles et sélecteurs Objective-C restent privés. GFX.UI.SystemMenu
adapte directement les commandes UI à cette primitive.

Le consommateur [MenuBar](../../Tests/Consumer/Fixtures/MenuBar.sx) vérifie le refus
d’installation avant le démarrage graphique, sans fenêtre. L’adaptateur utilise
Cocoa et libobjc sur les deux cibles macOS, sans nouvelle archive tierce.
La liaison Intel et les sorties Linux/Windows sont des preuves structurelles ;
l’exécution et l’essai visuel sont rapportés séparément.
