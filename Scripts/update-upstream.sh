#!/usr/bin/env bash
# Replaces the bundled mermaid with an exact npm version after checking the registry integrity.
# Policy (chat-library ADR-0016): adopt a version only after it has been public for two weeks.
#   Scripts/update-upstream.sh <version>
set -euo pipefail
VERSION="${1:?usage: Scripts/update-upstream.sh <version>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$(echo "$ROOT"/Sources/*/Resources/mermaid)"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
INTEGRITY="$(npm view "mermaid@$VERSION" dist.integrity)"
TARBALL="$(npm view "mermaid@$VERSION" dist.tarball)"
PUBLISHED="$(npm view "mermaid" time --json | python3 -I -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]][:10])' "$VERSION")"
echo "mermaid $VERSION published $PUBLISHED"
curl -sSfL -o "$WORK/pkg.tgz" "$TARBALL"
ACTUAL="sha512-$(openssl dgst -sha512 -binary "$WORK/pkg.tgz" | base64)"
[[ "$ACTUAL" == "$INTEGRITY" ]] || { echo "integrity mismatch: $ACTUAL != $INTEGRITY" >&2; exit 1; }
mkdir -p "$WORK/x" && tar -xzf "$WORK/pkg.tgz" -C "$WORK/x"
rm -rf "$DEST" && mkdir -p "$DEST"
cp "$WORK/x/package/dist/mermaid.min.js" "$DEST/"
cp "$WORK/x/package/LICENSE" "$ROOT/Licenses/$(ls "$ROOT/Licenses")"
(cd "$DEST" && python3 -I - "mermaid" "$VERSION" "$INTEGRITY" > "$ROOT/Upstream.json" <<'PY'
import hashlib, json, os, sys
files = {}
for root, _, names in os.walk('.'):
    for n in sorted(names):
        p = os.path.join(root, n)[2:]
        files[p] = hashlib.sha256(open(p, 'rb').read()).hexdigest()
print(json.dumps({"package": sys.argv[1], "version": sys.argv[2], "npmIntegrity": sys.argv[3], "files": dict(sorted(files.items()))}, indent=2))
PY
)
echo "Updated to $VERSION. Now: set the version constant in Sources, add a CHANGELOG entry, run swift test and review the visual samples."
