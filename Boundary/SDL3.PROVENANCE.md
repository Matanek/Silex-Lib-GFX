# SDL3 boundary provenance

GFX owns the private SDL3 boundary used by its window, input, clipboard, and
GPU infrastructure. All six desktop targets use SDL 3.4.10 from the upstream
tag `release-3.4.10`, commit
`8e37db5e797b6167f3a00d697d816a684bd259c7`.

The three unaffected established archives remain immutable assets from
`sdl3-3.4.10-silex.1`. The `macos-arm64`, `macos-x64` and `linux-arm64`
candidates are built natively by `Tools/build-sdl3.sh`. The `macos-x64` and
`linux-arm64` candidates are also verified by `.github/workflows/build-sdl3.yml`.
The script refuses a different source
revision or host architecture, builds only the static release library,
normalizes archive timestamps, checks the architecture and the SDL window,
clipboard, and GPU symbols, rejects UBSan references and macOS definitions of
system math symbols, then prints its SHA-256 checksum.

The three historical unpatched native candidates were:

| Target | Native runner | Archive SHA-256 |
|---|---|---|
| `macos-arm64` | Apple Silicon, Xcode 26.6 | `6baa6830c8a52dba6c86aff5992066fd67c7625369356531f4517b1bfc55150f` |
| `macos-x64` | `macos-15-intel`, Xcode 16.4 | `2d61a1c57af4828e5563bbf1cc17df7335f2e5f291c1dea3d1e0b46d97050ae0` |
| `linux-arm64` | native `ubuntu-24.04-arm`, Ubuntu 22.04 userspace | `937ac55efcc9a78afddd17320ada9e03704a8a470ff8e74990743ad73762f436` |

GitHub Actions run 33891534080 produced and inspected the `macos-x64` and
`linux-arm64` archives.

The macOS ARM64 archive was reproduced twice byte for byte on the local Apple
Silicon reference host. Its predecessor referenced UBSan and caused Zig's
monolithic compiler-rt runtime to interpose `sinf`; the replacement is built
with Apple Clang and explicitly disables sanitizers. Both its undefined and
defined global symbols are checked before the asset is accepted.

The Linux archive uses the pinned Ubuntu 22.04 image
`sha256:2edbbc5dc405e9612ba3584ce95480277e3eb374407b5505fe26f17df77c7dbc`
on the native ARM64 runner. This avoids the glibc 2.38-only C23 redirects from
the runner host. `-mno-outline-atomics` also keeps compiler helper symbols out
of the static boundary. The macOS archive reproduced the same checksum in runs
33891534080 and 33891915253. `Boundary/SDL3.SHA256SUMS.txt` records the complete
six-target set; the workflow requires the recorded checksum before preserving
either candidate.

No package release is created by the portability Spec. Until the prepared
`sdl3-3.4.10-silex.2` assets are deliberately published, the portability
workflow regenerates the `macos-x64` and `linux-arm64` candidates before
linking them. The `macos-arm64` candidate is supplied from the local native
build recorded above. The public GFX API and SDL provider name remain
unchanged.

## Local Metal transaction provider

The macOS ARM64 local candidate now uses `ad562386909a16ba586e2026c8861b5a2ab4bf569a03776694772b0119959390`. It is built by
`Tools/build-sdl3-metal.sh` from the same pinned SDL commit with
`Tools/Patches/SDL3-MetalTransaction.patch`. This is explicitly an altered
upstream source; SDL's license and attribution are retained. The earlier table
records historical unpatched assets and their hosted qualification, not this
new candidate. The ARM64 manifest has no download URL until a new immutable
asset is deliberately published; the installer checks the local checksum.

The patch sets `presentsWithTransaction`, commits and waits until the command
buffer is scheduled before presenting each window drawable. It removes the
command-buffer present call on macOS only, preserves fences/frame counters,
and adds no wait for offscreen-only submissions. It preserves SDL's thread
contract: acquire/submit a command buffer on its acquiring thread, and acquire
window drawables on the window-creating thread. The manually accepted ARM64
comparison used the same presentation sequence with an additional diagnostic
log; the production patch removes that log and changes comments only.

macOS Intel has not been natively qualified for this patch and retains its
previous manifest/archive. Linux and Windows are unchanged. The upstream
`build-sdl3.sh` and its checksum workflow remain historical baseline builders;
they do not install this variant. See the reconstruction guide in
`Docs/EN/NativeProvider.md`. No remote publication or package version change
is part of this local correction.

The corrected ARM64 archive was reproduced byte for byte twice on the local
reference toolchain: Xcode 27.0 (27A266a), Apple Clang 21.0.0
(clang-2100.3.34.2), CMake 3.31.2. The builder uses the baseline static Release
options, macOS deployment target 11.0, disables sanitizers, and normalizes
archive timestamps. A different toolchain may produce different bytes; do not
install a non-matching archive without separately qualifying its provenance.
