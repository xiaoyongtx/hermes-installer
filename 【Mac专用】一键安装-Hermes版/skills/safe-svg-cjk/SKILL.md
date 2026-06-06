---
name: safe-svg-cjk
description: Create and repair SVG/HTML/XML assets containing Chinese, Japanese, Korean, or other non-ASCII text without mojibake. Use when generating SVG diagrams, hand-drawn SVG illustrations, Obsidian embeds, or any asset with CJK text on Windows/PowerShell or uncertain shell encoding; also use when the user reports SVG text is garbled, appears as question marks, or needs Unicode-escape/UTF-8-safe writing.
---

# Safe SVG CJK

Use this skill whenever producing SVG, HTML, or XML assets containing CJK or other non-ASCII visible text.

## Core rule

Do not pipe raw CJK text through shell here-strings or console paths and assume it will survive. Write through a UTF-8-aware script, or store non-ASCII text as Unicode escapes and decode inside Python before writing.

## Workflow

1. Draft the SVG normally.
2. For all visible CJK text, prefer one of these safe patterns:
   - Store text as literal Unicode escapes, e.g. `"\\u771f\\u6b63\\u8981\\u5efa\\u7acb"`, then decode in Python.
   - Put the SVG in a UTF-8 file and write it using Python `Path.write_text(..., encoding="utf-8")`.
3. Write the final asset with `scripts/write_svg_utf8.py` or an equivalent Python UTF-8 write.
4. Validate before responding:
   - Real CJK characters appear in `<text>` nodes.
   - No visible `????` runs.
   - No replacement character `?`.
5. If validation fails, reconstruct from the intended text; do not preserve already-garbled text.

## Helper script

Use the bundled helper when possible:

```powershell
python C:\Users\sun\.agents\skills\safe-svg-cjk\scripts\write_svg_utf8.py --input tmp.svg.txt --out attachments/example.svg --decode-unicode-escapes
```

Without escape decoding:

```powershell
python C:\Users\sun\.agents\skills\safe-svg-cjk\scripts\write_svg_utf8.py --input tmp.svg --out attachments/example.svg
```

## Quick validation commands

PowerShell inspection:

```powershell
Select-String -LiteralPath 'attachments/example.svg' -Pattern '<text' | Select-Object -First 8
```

Python inspection:

```powershell
python C:\Users\sun\.agents\skills\safe-svg-cjk\scripts\write_svg_utf8.py --input attachments/example.svg --out tmp/validated.svg
```

## Obsidian output

When the SVG is for an Obsidian vault, save under a vault-relative path such as `attachments/name.svg`, then embed it as:

```markdown
![[attachments/name.svg]]
```
