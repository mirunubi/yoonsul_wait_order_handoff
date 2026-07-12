#!/usr/bin/env python3
"""Sync 000005_Index_Document_Number.md and 000007_Map_Full_Directory.md from docs filesystem.

CAUTION: this script rewrites both target files COMPLETELY (full overwrite, not a patch) each
run. Always inspect the result with `git diff` before it is ever committed -- never trust an
automated re-run blindly. In particular, `purpose_from_filename()`'s leading-zero-stripping
condition (`if len(num) == 6 and num.startswith("0") and not num.startswith("00", 1) is False:`)
is written as a double negative and is easy to misjudge; treat any output it produces for a
six-digit filename's "purpose" text with extra scrutiny. Not refactored here -- comment only.
"""
from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
INDEX005 = DOCS / "000005_Index_Document_Number.md"
INDEX007 = DOCS / "000007_Map_Full_Directory.md"

SKIP_DIRS = {"_migration_history"}


def purpose_from_filename(name: str) -> str:
    stem = name[:-3] if name.endswith(".md") else name
    m = re.match(r"^(\d+)(_.+)$", stem)
    if not m:
        return stem + "."
    num, rest = m.group(1), m.group(2)
    # 6-digit governance-style: drop one leading zero (000100 -> 00100)
    if len(num) == 6 and num.startswith("0") and not num.startswith("00", 1) is False:
        if num.startswith("000") and len(num) == 6:
            num = num[1:]
    elif len(num) == 6 and num.startswith("0"):
        num = num[1:]
    return f"{num}{rest}."


def default_status(rel: str, name: str) -> str:
    lower = rel.lower()
    if "archive" in lower or "609000" in lower:
        return "archived"
    if name.endswith("_Readme_") or "_Readme_" in name:
        return "initial"
    if name.startswith("000005_Document_Number") or name.startswith("000007_Full_Directory"):
        return "deprecated"
    if "_Index_" in name and name.count("_") <= 3:
        return "initial"
    return "active"


def collect_md_files() -> list[str]:
    files: list[str] = []
    for p in sorted(DOCS.rglob("*.md")):
        if any(part in SKIP_DIRS for part in p.parts):
            continue
        rel = p.relative_to(DOCS).as_posix().replace("/", "\\")
        files.append(rel)
    return files


def parse_existing_005() -> dict[str, tuple[str, str]]:
    text = INDEX005.read_text(encoding="utf-8", errors="replace")
    entries: dict[str, tuple[str, str]] = {}
    for m in re.finditer(
        r"\|\s*(docs\\[^|]+\.md)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|", text
    ):
        path = m.group(1).replace("/", "\\")
        rel = path.replace("docs\\", "")
        purpose = m.group(2).strip()
        status = m.group(3).strip()
        entries[rel] = (purpose, status)
    return entries


def parent_section_key(rel: str) -> str:
    parts = rel.split("\\")
    if len(parts) == 1:
        return "docs root"
    # section = immediate parent dir path from docs/
    return "/".join(["docs"] + parts[:-1])


def build_005(existing: dict[str, tuple[str, str]], files: list[str]) -> str:
    header = INDEX005.read_text(encoding="utf-8", errors="replace").split("## 2 docs root")[0]

    file_set = set(files)
    merged: dict[str, tuple[str, str]] = {}
    for rel in files:
        name = Path(rel).name
        if rel in existing:
            merged[rel] = existing[rel]
        else:
            merged[rel] = (purpose_from_filename(name), default_status(rel, name))

    # group by section key
    groups: dict[str, list[str]] = defaultdict(list)
    for rel in sorted(merged.keys()):
        groups[parent_section_key(rel)].append(rel)

    # section order: root first, then sorted by path
    def section_sort(key: str) -> tuple:
        if key == "docs root":
            return (0, "")
        return (1, key)

    lines: list[str] = [header.rstrip(), ""]

    sec_num = 2
    for key in sorted(groups.keys(), key=section_sort):
        if key == "docs root":
            lines.append("## 2 docs root")
        else:
            lines.append(f"## {sec_num} {key}")
            sec_num += 1
        lines.append("")
        lines.append("| file path | purpose | current status |")
        lines.append("| --- | --- | --- |")
        for rel in sorted(groups[key]):
            purpose, status = merged[rel]
            lines.append(f"| docs\\{rel} | {purpose} | {status} |")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def build_tree_lines(dir_path: Path, prefix: str = "") -> list[str]:
    """Build tree lines for 000007 under docs/."""
    lines: list[str] = []
    entries = sorted(
        [p for p in dir_path.iterdir() if p.name not in SKIP_DIRS],
        key=lambda p: (0 if p.is_file() else 1, p.name.lower()),
    )
    for i, entry in enumerate(entries):
        is_last = i == len(entries) - 1
        connector = "\\--- " if is_last else "+--- "
        if entry.is_dir():
            lines.append(f"{prefix}{connector}{entry.name}/")
            extension = "    " if is_last else "|   "
            lines.extend(build_tree_lines(entry, prefix + extension))
        else:
            if entry.suffix.lower() == ".md":
                lines.append(f"{prefix}{connector}{entry.name}")
    return lines


def build_007() -> str:
    preamble = """# 000007_Map_Full_Directory

## 1 Purpose

This document maps paths inside `yoonsul_wait_order_handoff`.

Documentation paths use five-digit prefixes and approximately 2,000-slot domain bands.

## 2 Root Files

```text
yoonsul_wait_order_handoff/
  README.md
  .gitignore
  apps/
  data/
  docs/
  packages/
  tests/
```

Governance markdown files live under `docs/`, not at the project root.

## 3 Docs Directory Tree

```text
docs/
"""
    tree_body = build_tree_lines(DOCS, "")
    # indent one level under docs/
    indented = []
    for line in tree_body:
        indented.append("  " + line)
    return preamble + "\n".join(indented) + "\n```\n"


def main():
    files = collect_md_files()
    existing = parse_existing_005()
    missing = [f for f in files if f not in existing]
    print(f"Total md files: {len(files)}")
    print(f"Existing indexed: {len(existing)}")
    print(f"New to add: {len(missing)}")

    new_005 = build_005(existing, files)
    INDEX005.write_text(new_005, encoding="utf-8", newline="\n")
    print(f"Updated {INDEX005}")

    new_007 = build_007()
    INDEX007.write_text(new_007, encoding="utf-8", newline="\n")
    print(f"Updated {INDEX007} ({len(new_007.splitlines())} lines)")


if __name__ == "__main__":
    main()
