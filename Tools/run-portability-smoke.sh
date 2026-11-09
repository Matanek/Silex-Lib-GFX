#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 9 ]]; then
    echo "usage: $0 <silex> <target> <STD> <JSON> <GFX.Assets> <GFX.GPU> <GFX.Application> <GFX.ECS> <temporary-directory>" >&2
    exit 2
fi

silex="$1"
target="$2"
std_dir="$(cd -- "$3" && pwd)"
json_dir="$(cd -- "$4" && pwd)"
assets_dir="$(cd -- "$5" && pwd)"
gpu_dir="$(cd -- "$6" && pwd)"
application_dir="$(cd -- "$7" && pwd)"
ecs_dir="$(cd -- "$8" && pwd)"
temporary_dir="$9"
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
"$silex" link "$ecs_dir" --workspace "$workspace_dir" --target "$target"
"$silex" link "$application_dir" --workspace "$workspace_dir" --target "$target"
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
"$silex" link "$ecs_dir" --workspace "$assets_consumer" --target "$target"
"$silex" link "$application_dir" --workspace "$assets_consumer" --target "$target"

"$silex" link "$std_dir" --workspace "$gpu_consumer" --target "$target"
"$silex" link "$gfx_dir" --workspace "$gpu_consumer" --target "$target"
"$silex" link "$gpu_dir" --workspace "$gpu_consumer" --target "$target"

for consumer in "$gfx_consumer" "$assets_consumer" "$gpu_consumer"; do
    "$silex" packages resolve "$consumer"
    output_file="$temporary_dir/$(basename "$(dirname "$(dirname "$consumer")")")-consumer.log"
    if "$silex" test "$consumer/Tests" --nocache >"$output_file" 2>&1; then
        cat "$output_file"
        grep -Eq '[1-9][0-9]* passed; 0 failed in [1-9][0-9]* files' "$output_file"
    else
        status=$?
        cat "$output_file" >&2
        # GFX and Assets still execute fully. The portable GPU package already
        # executes on macOS ARM64; hosted Intel Macs may expose no Metal GPU.
        # Accept only the two known device-creation failures, with the catalog
        # test passing and every consumer source successfully compiled.
        if [[ "$target" == "macos-x64" && "$consumer" == "$gpu_consumer" ]] &&
            [[ "$(grep -c 'runtime error:' "$output_file")" == 2 ]] &&
            [[ "$(grep -c 'Device does not meet the hardware requirements for SDL_GPU Metal' "$output_file")" == 2 ]] &&
            grep -Eq '^1 passed; 2 failed in 2 files$' "$output_file"; then
            echo "SKIP $target GPU transfers/readback runtime: GitHub runner exposes no compatible Metal device"
        else
            exit "$status"
        fi
    fi
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

compile_and_run_surface() {
    local executable="$temporary_dir/surface$extension"
    local output="$temporary_dir/surface.log"

    "$silex" compile "$gpu_dir/Smokes/Surface.sx" \
        --target "$target" --release --nocache -o "$executable"
    if "$executable" >"$output" 2>&1; then
        cat "$output"
        echo "PASS $target surface"
        return
    else
        local status=$?
        cat "$output" >&2
        if [[ "$target" == "macos-x64" ]] && \
            grep -Fq "Device does not meet the hardware requirements for SDL_GPU Metal" "$output"; then
            echo "SKIP $target surface runtime: GitHub runner exposes no compatible Metal device"
            return
        fi
        return "$status"
    fi
}

compile_and_run boundary "$gpu_dir/Smokes/Boundary.sx"
compile_and_run shader "$gpu_dir/Smokes/Shader.sx"
compile_and_run_surface
