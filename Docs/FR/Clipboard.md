# Presse-papiers

`GFX.Clipboard` lit et écrit le texte UTF-8 du presse-papiers système.
`has_text()` indique si une valeur texte est annoncée.

```sx
use GFX.Clipboard

match Clipboard.try_read_text() {
    failure(error) => { print(error.detail) }
    success(value) => { print(value) }
}
```

`read_text()` et `write_text()` sont des formes pratiques qui s’arrêtent sur
une erreur de plateforme. Une chaîne vide est une valeur valide. L’implémentation
réutilise le fournisseur SDL3 privé de GFX sur macOS, Linux et Windows.
