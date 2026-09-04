#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 7 ]]; then
    echo "usage: $0 <silex> <target> <STD> <JSON> <GFX.Assets> <GFX.GPU> <temporary-directory>" >&2
    exit 2
fi

silex="$1"
target="$2"
std_dir="$(cd -- "$3" && pwd)"
json_dir="$(cd -- "$4" && pwd)"
assets_dir="$(cd -- "$5" && pwd)"
gpu_dir="$(cd -- "$6" && pwd)"
temporary_dir="$7"
script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
gfx_dir="$(cd -- "$script_dir/.." && pwd)"
workspace_dir="$(pwd)"

if [[ ! -f "$workspace_dir/Package.json" ]]; then
    echo "portability smoke requires Package.json at $workspace_dir" >&2
    exit 1
fi

mkdir -p "$temporary_dir"

"$silex" setup
"$silex" link "$std_dir" --workspace "$workspace_dir" --target "$target"
"$silex" link "$json_dir" --workspace "$workspace_dir" --target "$target"
"$silex" link "$gfx_dir" --workspace "$workspace_dir" --target "$target"
"$silex" link "$assets_dir" --workspace "$workspace_dir" --target "$target"
"$silex" link "$gpu_dir" --workspace "$workspace_dir" --target "$target"
"$silex" packages resolve "$workspace_dir"

gfx_consumer="$gfx_dir/Tests/Consumer"
assets_consumer="$assets_dir/Tests/Consumer"
gpu_consumer="$gpu_dir/Tests/Consumer"

"$silex" link "$std_dir" --workspace "$gfx_consumer" --target "$target"
"$silex" link "$gfx_dir" --workspace "$gfx_consumer" --target "$target"

"$silex" link "$std_dir" --workspace "$assets_consumer" --target "$target"
"$silex" link "$json_dir" --workspace "$assets_consumer" --target "$target"
"$silex" link "$gfx_dir" --workspace "$assets_consumer" --target "$target"
"$silex" link "$assets_dir" --workspace "$assets_consumer" --target "$target"

"$silex" link "$std_dir" --workspace "$gpu_consumer" --target "$target"
"$silex" link "$gfx_dir" --workspace "$gpu_consumer" --target "$target"
"$silex" link "$gpu_dir" --workspace "$gpu_consumer" --target "$target"

for consumer in "$gfx_consumer" "$assets_consumer" "$gpu_consumer"; do
    "$silex" packages resolve "$consumer"
    output="$("$silex" test "$consumer/Tests" --nocache)"
    printf '%s\n' "$output"
    grep -Eq '[1-9][0-9]* passed; 0 failed in [1-9][0-9]* files' <<< "$output"
done

"$silex" link "$std_dir" --workspace "$gpu_dir" --target "$target"
"$silex" link "$gfx_dir" --workspace "$gpu_dir" --target "$target"

extension=""
case "$target" in
    windows-*) extension=".exe" ;;
esac

compile_and_run() {
    local name="$1"
    local source="$2"
    local executable="$temporary_dir/$name$extension"

    "$silex" compile "$source" \
        --target "$target" --release --nocache -o "$executable"
    "$executable"
    echo "PASS $target $name"
}

compile_and_run boundary "$gpu_dir/Smokes/Boundary.sx"
compile_and_run shader "$gpu_dir/Smokes/Shader.sx"
compile_and_run surface "$gpu_dir/Smokes/Surface.sx"
