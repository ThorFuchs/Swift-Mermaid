#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Type-check the complete Swift examples in the DocC guides."""
import pathlib
import re
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parent.parent
CATALOG = ROOT / "Sources/Mermaid/Mermaid.docc"
GUIDES = ("GettingStarted", "DisplayingDiagrams", "RenderingAndExport", "ErrorsAndCaching", "DiagramSyntax")


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: check-docc-examples.py <swift-module-directory>")
    with tempfile.TemporaryDirectory(prefix="swift-mermaid-examples-") as directory:
        for guide in GUIDES:
            text = (CATALOG / f"{guide}.md").read_text(encoding="utf-8")
            examples = re.findall(r"```swift\n(.*?)\n```", text, re.DOTALL)
            complete = [example for example in examples if "import Mermaid" in example]
            if len(complete) != 1:
                raise SystemExit(f"Expected one complete Mermaid example in {guide}.md")
            source = pathlib.Path(directory) / f"{guide}.swift"
            source.write_text(complete[0] + "\n", encoding="utf-8")
            subprocess.run(
                ["xcrun", "swiftc", "-typecheck", "-module-cache-path", directory,
                 "-I", sys.argv[1], str(source)],
                check=True,
            )
            print(f"Type-checked {guide}.md", flush=True)


if __name__ == "__main__":
    main()
