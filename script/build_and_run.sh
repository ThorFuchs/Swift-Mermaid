#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Build the example as a real macOS app bundle and open it.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
package="$root/Examples/MermaidGallery"
app="$package/.build/Mermaid Gallery.app"
swift build --package-path "$package" --product MermaidGallery
bin=$(swift build --package-path "$package" --show-bin-path)
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin/MermaidGallery" "$app/Contents/MacOS/MermaidGallery"
for bundle in "$bin"/*.bundle; do
  [ -d "$bundle" ] || continue
  cp -R "$bundle" "$app/Contents/Resources/"
done
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleExecutable</key><string>MermaidGallery</string>
<key>CFBundleIdentifier</key><string>com.thorfuchs.swift-mermaid.gallery</string>
<key>CFBundleName</key><string>Mermaid Gallery</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
PLIST
/usr/bin/open -n "$app"
