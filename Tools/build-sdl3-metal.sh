#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <clean-SDL-source-directory> <macos-arm64|macos-x64> <output-directory>" >&2
    exit 1
fi
source_dir="$(cd -- "$1" && pwd)"
target="$2"
mkdir -p -- "$3"
output_dir="$(cd -- "$3" && pwd)"
tools_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
expected_revision="8e37db5e797b6167f3a00d697d816a684bd259c7"
case "$target" in
    macos-arm64|macos-x64) ;;
    *) echo "transaction presentation is a macOS-only provider variant" >&2; exit 1 ;;
esac
[[ "$(git -C "$source_dir" rev-parse HEAD)" == "$expected_revision" ]] || {
    echo "expected clean SDL revision $expected_revision" >&2; exit 1;
}
[[ -z "$(git -C "$source_dir" status --porcelain)" ]] || {
    echo "SDL source must be clean; the patch is applied to a disposable clone" >&2; exit 1;
}

# Do not patch the caller's checkout or overwrite a shared SDL build directory.
workspace_dir="$(mktemp -d "${TMPDIR:-/tmp}/silex-sdl3-metal.XXXXXX")"
trap 'rm -rf -- "$workspace_dir"' EXIT
git clone --quiet --no-hardlinks --no-checkout "$source_dir" "$workspace_dir/SDL"
git -C "$workspace_dir/SDL" checkout --quiet --detach "$expected_revision"
git -C "$workspace_dir/SDL" apply --check "$tools_dir/Patches/SDL3-MetalTransaction.patch"
git -C "$workspace_dir/SDL" apply "$tools_dir/Patches/SDL3-MetalTransaction.patch"
RUNNER_TEMP="$workspace_dir" bash "$tools_dir/build-sdl3.sh" \
    "$workspace_dir/SDL" "$target" "$output_dir"
