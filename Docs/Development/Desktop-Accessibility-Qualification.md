# Desktop accessibility qualification

This record separates implemented behavior, current automated evidence and native
qualification still outstanding. The combined development sources were qualified
on 4 November 2026. The [machine-readable record](Desktop-Accessibility-Qualification.json)
pins source identities, compiler hashes, commands, targets and binary identities.

## Scope

Window connects the semantic Source to AppKit on macOS, AT-SPI on Linux and
UI Automation on Windows. UI supplies controls, collections and text geometry;
Canvas and Viewer forward the optional Source. GFX owns the system adapters.

Ordinary macOS use has been accepted. The initial button/text-field path has
inspector and VoiceOver evidence. Additional reader paths for controls,
collections and text geometry remain unqualified. Linux and Windows adapters
are experimental: model tests and ARM64/X64 cross-linking do not establish
native execution or Orca/Narrator behavior.

The [public accessibility guide](../EN/Accessibility.md) describes capabilities
and limits. The [UIAccessibility example](https://github.com/Matanek/Silex-Examples/blob/main/Sources/UIAccessibility/README.md)
preserves future native paths and reporting fields, including eight Windows
scenarios. No new reader acceptance follows from these CPU or linker checks.

## Current evidence

The combined compiler passes `zig build check` (50/50 steps, 1,764 internal
tests) and `zig build test` (42/42 steps, 1,229 internal tests), with 293 Silex
scenarios in 115 files at each gate. These totals overlap. The CLI is built in
ReleaseFast; internal tests use Debug.

The GFX campaign contains 208 CPU tests across 34 file passages, representing
33 distinct sources: UIA/AT-SPI models, public UI families, accessibility,
Canvas, Viewer and Terminal. The 32 earlier passages retain their actual
compiler identity; Menus and accessible text geometry were rerun on the final
compiler. Source comparisons and the compiler regression gates support their
explicit reassessment. The native test runner, transformation passes, lowering
and encoders keep their behavior; verification borrows the same IR and uses
bounded temporary storage.

Four AppKit checks compile without cache and execute without a window: ARM64
and X64, Debug and Release. X64 executes through Rosetta on the ARM64 host.
Both Debug and Release UIAccessibility binaries pass the exact headless CPU
check. Six foreign binaries are built: Windows fixture and demo on ARM64/X64,
and Linux demo on ARM64/X64. PE32+/ELF64 machine identifiers, loaders/imports
and hashes are checked without foreign OS execution. Linux has no mandatory
linked dbus/GTK/GLib dependency; desktop D-Bus loading remains optional.

Earlier green evidence covers thirty-nine UI sources, with the compiler that
actually ran each source; overlap is recorded. Interrupted
attempts are preserved separately. This is not a claim of a complete green
103-source UI suite.

## Reproduce within the resource qualification

Run Silex source commands from the SilexProject root with explicit entries. Use
the matching development compiler and development packages: these sources need
protocol default bodies and native C callback support. Check package origins.

The final builds explicitly use one compilation worker. On macOS 26.6.2 ARM64,
maximum observed group RSS is 2,760 MiB for the Debug demo and 2,883 MiB for
Release. All current construction runs remain under the 4 GiB guard, at nice 10,
starting at at least 45% system-free memory and stopping below 35%. Runs without
a worker override reached the RSS guard and are not successful evidence. These
observations do not promise a global memory bound or a speedup.

```sh
export SILEX_COMPILATION_WORKERS=1
silex test Packages/GFX/Tests/Accessibility/UIAModel.sx
silex test Packages/GFX/Tests/Accessibility/ATSPICollections.sx
silex test Packages/GFX.UI/Tests/Consumer/Tests/AccessibilityTextGeometry.sx
silex test Packages/GFX.UI.Terminal/Tests/Consumer/Tests/PublicAPI.sx
silex compile Silex-Examples/Sources/UIAccessibility/Main.sx --debug --output /tmp/ui-accessibility-debug
/tmp/ui-accessibility-debug --cpu-check
```

The last command returns before Viewer opens a window: two lines of
`UIAccessibility CPU : OK`, exit code 0 and empty stderr. Replace `--debug` with
`--release` for the Release check.

```sh
silex compile Packages/GFX/Tests/Accessibility/MacOS.sx --target macos-arm64 --debug --nocache --output /tmp/gfx-appkit-arm64-debug
/usr/bin/arch -arm64 /tmp/gfx-appkit-arm64-debug
```

Use `macos-x64` and `arch -x86_64` for X64, and `--release` for Release. Expected
stdout is `AppKit accessibility : OK (sans fenêtre)`, exit code 0 and empty
stderr. This exercises native exchanges and does not qualify a reader.

Linux cross-builds use UIAccessibility for `linux-arm64` and `linux-x64`.
Windows uses that entry and [the headless fixture](../../Tests/Accessibility/Windows.sx)
for `windows-arm64` and `windows-x64`. Their native test paths are documented in
the example rather than inferred from a successful link.

## Compiler ownership and retained limits

The compiler documents [test execution scratch](https://github.com/Matanek/Silex/blob/main/Docs/Native-test-runner.md)
and [IR verification storage](https://github.com/Matanek/Silex/blob/main/Docs/IR-verification-memory.md),
including independent correctness/resource regressions and measured limits.
Verification retains every check and shares the existing textual helpers.
Compiler gates isolate user package discovery to STD; workspace links still
take precedence for loose sources. Establish the minimal gate link set, then
restore workspace-owned links before consumer checks. See
[package discovery](https://github.com/Matanek/Silex/blob/main/Docs/Modules-and-packages.md).

Historical frame traces, checksums, analyses and bounded slider acceptance are
preserved in [GFX.Viewer's interaction measurements](https://github.com/Matanek/Silex-Lib-GFX.Viewer/blob/main/Docs/Development/Interaction-Measurements/README.md).
They include intermediate and rejected stages, and establish no current FPS,
GPU timing or loaded IDE/game certification. Earlier libdbus codec and native C
ABI evidence retain their original scope; matching source hashes do not turn
those runs into foreign OS execution.

Terminal's public targeted checks pass. The historical asynchronous shell-exit
observation remains a separate reserve; no fix is claimed here. Hardware touch,
foreign IME, foreign windows and additional reader behavior are not inferred
from simulated input. Remote publication remains a separate operation.
