#!/usr/bin/env python3
"""Write SVG/XML/HTML text as UTF-8 and validate CJK text did not become mojibake."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

CJK_RE = re.compile(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF\u3040-\u30FF\uAC00-\uD7AF]")
TEXT_RE = re.compile(r"<text\b[^>]*>(.*?)</text>", re.S | re.I)


def decode_unicode_escapes(text: str) -> str:
    """Decode literal backslash-u escapes without relying on shell CJK transport."""
    return text.encode("utf-8").decode("unicode_escape")


def validate(text: str, require_cjk: bool = True) -> list[str]:
    issues: list[str] = []
    if "\ufffd" in text:
        issues.append("contains Unicode replacement character U+FFFD")
    text_nodes = "\n".join(m.group(1) for m in TEXT_RE.finditer(text))
    visible = text_nodes or text
    if re.search(r"\?{3,}", visible):
        issues.append("contains runs of ??? in visible text, likely mojibake")
    if require_cjk and not CJK_RE.search(text):
        issues.append("no CJK characters detected; expected readable CJK text")
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description="Write UTF-8 SVG/XML/HTML and catch common CJK mojibake.")
    parser.add_argument("--input", required=True, help="Input text/SVG file, read as UTF-8")
    parser.add_argument("--out", required=True, help="Output file path")
    parser.add_argument("--decode-unicode-escapes", action="store_true", help="Decode literal \\uXXXX escapes before writing")
    parser.add_argument("--no-require-cjk", action="store_true", help="Do not require CJK characters in validation")
    args = parser.parse_args()

    source = Path(args.input)
    out = Path(args.out)
    text = source.read_text(encoding="utf-8")
    if args.decode_unicode_escapes:
        text = decode_unicode_escapes(text)

    issues = validate(text, require_cjk=not args.no_require_cjk)
    if issues:
        for issue in issues:
            print(f"ERROR: {issue}", file=sys.stderr)
        return 2

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8", newline="\n")
    print(f"wrote UTF-8: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
