#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <SDL-source-directory> <target> <output-directory>" >&2
    exit 1
fi

source_dir="$(cd -- "$1" && pwd)"
target="$2"
output_dir="$3"
expected_revision="8e37db5e797b6167f3a00d697d816a684bd259c7"

actual_revision="$(git -C "$source_dir" rev-parse HEAD)"
if [[ "$actual_revision" != "$expected_revision" ]]; then
    echo "expected SDL revision $expected_revision, got $actual_revision" >&2
    exit 1
fi

case "$target" in
    macos-x64)
        [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "x86_64" ]] || {
            echo "macos-x64 must be built on a native macOS X64 host" >&2
            exit 1
        }
        archive_name="SDL3-3.4.10-macos-x64.a"
        cmake_target_arguments=(
            -DCMAKE_OSX_ARCHITECTURES=x86_64
            -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
        )
        ;;
    linux-arm64)
        [[ "$(uname -s)" == "Linux" ]] || {
            echo "linux-arm64 must be built on Linux" >&2
            exit 1
        }
        case "$(uname -m)" in
            aarch64|arm64) ;;
            *) echo "linux-arm64 must be built on a native ARM64 host" >&2; exit 1 ;;
        esac
        archive_name="SDL3-3.4.10-linux-arm64.a"
        cmake_target_arguments=(
            -DCMAKE_C_FLAGS=-mno-outline-atomics
        )
        ;;
    *)
        echo "unsupported SDL target: $target" >&2
        exit 1
        ;;
esac

build_dir="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/silex-sdl3-$target"
rm -rf -- "$build_dir"

cmake -S "$source_dir" -B "$build_dir" -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DSDL_EXAMPLES=OFF \
    -DSDL_INSTALL=OFF \
    -DSDL_INSTALL_DOCS=OFF \
    -DSDL_SHARED=OFF \
    -DSDL_STATIC=ON \
    -DSDL_TESTS=OFF \
    -DSDL_TEST_LIBRARY=OFF \
    "${cmake_target_arguments[@]}"
cmake --build "$build_dir" --config Release --parallel 4 --target SDL3-static

archive="$(find "$build_dir" -type f -name 'libSDL3.a' -print -quit)"
if [[ -z "$archive" ]]; then
    echo "SDL static archive was not produced" >&2
    exit 1
fi

mkdir -p "$output_dir"
output="$output_dir/$archive_name"
cp "$archive" "$output"

if [[ "$target" == "macos-x64" ]]; then
    lipo -info "$output" | grep -Fq 'architecture: x86_64'
else
    readelf -h "$output" | grep -Fq 'Machine:                           AArch64'
fi

symbols="$build_dir/exported-symbols.txt"
nm -g "$output" > "$symbols"
for symbol in SDL_Init SDL_CreateWindow SDL_GetClipboardText SDL_CreateGPUDevice; do
    grep -Eq "(^|[[:space:]_])${symbol}$" "$symbols" || {
        echo "missing required SDL symbol: $symbol" >&2
        exit 1
    }
done

file "$output"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$output"
else
    shasum -a 256 "$output"
fi
