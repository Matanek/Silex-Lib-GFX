# Clipboard

`GFX.Clipboard` reads and writes the operating system's UTF-8 text clipboard.
`has_text()` reports whether a text value is currently advertised.

```sx
use GFX.Clipboard

match Clipboard.try_read_text() {
    failure(error) => { print(error.detail) }
    success(value) => { print(value) }
}
```

`read_text()` and `write_text()` are convenience forms that stop on a platform
failure. An empty string is a valid clipboard value. The implementation reuses
GFX's private SDL3 provider on macOS, Linux, and Windows.
