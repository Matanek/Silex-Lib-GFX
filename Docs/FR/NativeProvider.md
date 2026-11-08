# Reconstruire le provider SDL local

Le candidat macOS ARM64 présente les images Metal dans la transaction Core
Animation qui actualise la géométrie de la fenêtre. La dernière image conserve
ses proportions pendant le redimensionnement. La synchronisation s’applique
à chaque présentation de fenêtre ; les soumissions hors écran restent asynchrones.

GFX 0.41.0 distribue cette archive dans son instantané immuable du registre.
Le manifeste conserve son empreinte sans URL GitHub héritée pour empêcher son
remplacement par l’ancienne archive. Pour un checkout source, la reconstruire
depuis la racine du workspace, avec CMake et Apple Clang :

```sh
git clone --depth 1 --branch release-3.4.10 https://github.com/libsdl-org/SDL.git /tmp/silex-sdl3
Packages/GFX/Tools/build-sdl3-metal.sh /tmp/silex-sdl3 macos-arm64 /tmp/silex-sdl3-output
shasum -a 256 /tmp/silex-sdl3-output/SDL3-3.4.10-macos-arm64.a
```

Comparer cette empreinte à `artifacts.macos-arm64.SDL3.sha256` dans
`Packages/GFX/Package.json`, puis installer l’archive concordante :

```sh
cp /tmp/silex-sdl3-output/SDL3-3.4.10-macos-arm64.a Packages/GFX/Boundary/macos-arm64/libSDL3.a
```

La recette vérifie la révision exacte, exige un checkout SDL propre, applique
le patch dans un clone temporaire et supprime ses sources/build à la sortie.
Elle ne démarre aucune fenêtre ni device GPU. Elle conserve le nom du provider
et son ABI SDL. Chaque command buffer présentant une fenêtre attend son scheduling
après commit, puis présente chaque drawable ; les fences et compteurs en vol
restent ceux de SDL. La soumission conserve les contraintes de thread de SDL.
Aucun gain de performance n’est revendiqué.

`macos-x64` accepte cette recette sur un hôte Intel natif pour préparer sa
qualification, mais le manifeste Intel sélectionne encore l’archive antérieure.
Cette correction est limitée à macOS ARM64 ; les autres plateformes conservent
leurs archives. Une adoption ultérieure sur Intel exige sa qualification native
et un nouvel artefact immuable. Ne pas réutiliser une URL déjà publiée.

La [provenance native](../../Boundary/SDL3.PROVENANCE.md) conserve la révision
SDL, le patch et les limites de qualification.
