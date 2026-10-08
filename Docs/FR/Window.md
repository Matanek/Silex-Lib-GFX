# GFX.Window

`GFX.Window` possède une fenêtre système et expose des intentions portables :
taille logique, densité, plein écran, hiérarchie, saisie de texte, attention et
progression système. Aucun handle SDL n’est public.

```silex
use GFX.Window

var window = Window(Window.Settings(
    title:"Silex",
    width:1280,
    height:720
))
```

`Window.Plugin` gère la même capacité dans `Application` et installe
`Input.Plugin`. Par défaut, une demande de fermeture arrête l’application ; le
mode manuel conserve la demande dans `GFX.Input.State`.

Plusieurs fenêtres peuvent appartenir à des Bundles distincts dans la même
boucle. L’exemple [Bundle/MultipleWindows](https://github.com/Matanek/Silex-Examples/blob/main/Sources/Bundle/MultipleWindows.sx)
montre leur fermeture indépendante.

`presentation_handle()` est une échappatoire explicite pour une extension qui
attache une surface système, comme `GFX.WebView`. La fenêtre reste propriétaire
et le handle n’est valide que pendant sa durée de vie. Les écrans sont exposés
par `GFX.Window.Display`. Le rythme de boucle appartient à `GFX.Application`.

## Curseur du pointeur

`window.set_cursor(Window.Cursor.standard)`, `resize_horizontal` et
`resize_vertical` choisissent la forme système. Appelez cette méthode sur le
thread applicatif après le traitement des événements, y compris lorsque le
pointeur entre à nouveau dans la fenêtre. `window.cursor()` lit la préférence.
Seule la fenêtre sous le pointeur applique sa préférence : les autres fenêtres
et applications gardent leur curseur. Une forme est créée à la première
utilisation puis réutilisée ; la fenêtre la libère à sa destruction. Aucun
handle natif n’est exposé.
