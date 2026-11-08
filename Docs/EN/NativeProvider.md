# Rebuild the local SDL provider

The macOS ARM64 candidate presents Metal images in the Core Animation transaction
that updates window geometry. The previous image keeps its proportions during
resize. Synchronization applies to every window presentation; offscreen
submissions remain asynchronous.

GFX 0.41.0 distributes this archive in its immutable registry snapshot. The
manifest records its checksum without a legacy GitHub URL to prevent replacement
by the previous archive. For a source checkout, rebuild it from the workspace
root with CMake and Apple Clang installed:

```sh
git clone --depth 1 --branch release-3.4.10 https://github.com/libsdl-org/SDL.git /tmp/silex-sdl3
Packages/GFX/Tools/build-sdl3-metal.sh /tmp/silex-sdl3 macos-arm64 /tmp/silex-sdl3-output
shasum -a 256 /tmp/silex-sdl3-output/SDL3-3.4.10-macos-arm64.a
```

Compare this checksum with `artifacts.macos-arm64.SDL3.sha256` in
`Packages/GFX/Package.json`, then install the matching archive:

```sh
cp /tmp/silex-sdl3-output/SDL3-3.4.10-macos-arm64.a Packages/GFX/Boundary/macos-arm64/libSDL3.a
```

The recipe verifies the exact revision, requires a clean SDL checkout, applies
the patch in a disposable clone, and removes its sources/build on exit. It starts
no window or GPU device. The SDL provider name and ABI remain unchanged. Each
command buffer presenting a window waits for scheduling after commit, then
presents each drawable; SDL fences and in-flight counters are preserved.
Submission retains SDL thread constraints. No performance improvement is claimed.

`macos-x64` accepts this recipe on a native Intel host to prepare qualification,
but the Intel manifest still selects the previous archive. Other platforms retain
their archives. This fix is limited to macOS ARM64. Adopting it on Intel later
requires native qualification and a new immutable artifact. Never reuse an
already published archive URL.

[Native provenance](../../Boundary/SDL3.PROVENANCE.md) records the SDL revision,
patch, and qualification limits.
