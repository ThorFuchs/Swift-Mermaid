# Testing

Run `swift test`, `swift test -c release`, and `Scripts/build-docc.sh` on macOS
with Swift 6.4. The DocC check requires documentation on every source-declared
public symbol, type-checks the complete guide examples, and treats DocC
warnings as errors. It produces an
archive at `.build/Mermaid.doccarchive` by default. The suite
checks common diagram types, error handling, caching, queue and WebKit timeouts,
and the SHA-256 of the bundled Mermaid distribution against `Upstream.json`.
The checksum check runs on macOS because it reads the source checkout.
On macOS the suite also renders every Mermaid code block in the DocC diagram
syntax guides using the bundled engine; it reads those guides from the checkout.

CI also runs tests on an iOS simulator and builds for the visionOS simulator;
a build alone is not a runtime test. Check CI results for the commit under
review. On a local Xcode installation, use the commands in
[the workflow](../.github/workflows/ci.yml) with an installed simulator.

To review rendered output, create an empty directory and run
`SWIFT_MERMAID_SAMPLES=/absolute/path/to/directory swift test`. Inspect all
sample PDFs in both appearances for clipping, missing labels and incorrect
layout. Automated PDF header and size checks do not replace visual inspection.
