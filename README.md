# GFX

`GFX` is the modular foundation for Silex graphics applications: application
loop, windows, input, clipboard, and shared values.

```text
silex install GFX
```

## Documentation

- [French documentation](Docs/FR/README.md)
- [English documentation](Docs/EN/README.md)
- [Desktop accessibility qualification](Docs/Development/Desktop-Accessibility-Qualification.md): current evidence and remaining native checks.

This release requires Silex 0.48.0 or newer, including protocol default bodies
and native C callback support used by the desktop accessibility adapters.

Native archives are included in the registry snapshot. A source checkout needs
the checksum-matched local SDL archive; see [reconstruction](Docs/EN/NativeProvider.md).
