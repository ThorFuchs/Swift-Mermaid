#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Build and validate the public documentation without external dependencies.
# Usage: Scripts/build-docc.sh [scratch-directory] [output-archive]
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
scratch=${1:-"$root/.build/docc-build"}
output=${2:-"$root/.build/Mermaid.doccarchive"}
mkdir -p "$scratch" "$(dirname -- "$output")"
scratch=$(CDPATH= cd -- "$scratch" && pwd)
output="$(CDPATH= cd -- "$(dirname -- "$output")" && pwd)/$(basename -- "$output")"
cd "$root"
swift package --scratch-path "$scratch" dump-symbol-graph --skip-synthesized-members
symbol=$(find "$scratch" -type f -name Mermaid.symbols.json -print -quit)
test -n "$symbol"
python3 Scripts/check-symbol-documentation.py "$symbol"
module_dir=$(swift build --scratch-path "$scratch" --show-bin-path)
python3 Scripts/check-docc-examples.py "$module_dir"
temp=$(mktemp -d "${TMPDIR:-/tmp}/swift-mermaid-docc.XXXXXXXX")
trap 'rm -rf "$temp"' EXIT HUP INT TERM
cp "$symbol" "$temp/Mermaid.symbols.json"
xcrun docc convert Sources/Mermaid/Mermaid.docc --additional-symbol-graph-dir "$temp" \
  --fallback-display-name Mermaid --fallback-bundle-identifier io.github.thorfuchs.swift-mermaid \
  --fallback-bundle-version 1.0.0 --output-path "$output" --warnings-as-errors \
  --experimental-documentation-coverage --coverage-summary-level detailed
printf 'Documentation archive: %s\n' "$output"
