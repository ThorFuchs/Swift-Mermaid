#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Require documentation on public, source-declared Mermaid symbols."""
import json
import pathlib
import sys


def main():
    if len(sys.argv) != 2:
        raise SystemExit("usage: check_symbol_documentation.py Mermaid.symbols.json")
    graph = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    symbols = graph["symbols"]
    if isinstance(symbols, dict):
        symbols = symbols.values()
    declared = [s for s in symbols if s.get("accessLevel") == "public" and s.get("location")]
    missing = [s for s in declared if not s.get("docComment", {}).get("lines")]
    if not declared:
        raise SystemExit("No source-declared public symbols found")
    for symbol in missing:
        print("Undocumented public symbol:", ".".join(symbol["pathComponents"]))
    print(f"Documented public source symbols: {len(declared) - len(missing)}/{len(declared)}")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
