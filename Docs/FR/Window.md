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

`presentation_handle()` est une échappatoire explicite pour une extension qui
attache une surface système, comme `GFX.WebView`. La fenêtre reste propriétaire
et le handle n’est valide que pendant sa durée de vie. Les écrans sont exposés
par `GFX.Window.Display`. Le rythme de boucle appartient à `GFX.Application`.
