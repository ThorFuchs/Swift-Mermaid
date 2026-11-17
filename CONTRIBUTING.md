# Contributing

Open an issue for a reproducible bug or focused proposal, or submit a pull
request against `main`. Use Swift 6.4 and Xcode 27.2 or newer. The package has
no external Swift dependencies; rendering tests require a working WebKit
content process.

Add a regression test for a behavioral fix and document public API changes.
Run `swift test` and `swift test -c release` on macOS. For platform changes,
run the simulator checks in [CI](.github/workflows/ci.yml), where available.
Describe the change, results and any checks you could not run in the pull request.
See [testing](Documentation/TESTING.md) for visual and upstream checks.

Do not hand-edit the vendored Mermaid distribution. Follow the update process
in [RELEASING.md](RELEASING.md). Contributions are licensed under the
[Apache License 2.0](LICENSE), section 5. Follow the
[community standards](CODE_OF_CONDUCT.md) and report vulnerabilities privately
as described in [SECURITY.md](SECURITY.md).
