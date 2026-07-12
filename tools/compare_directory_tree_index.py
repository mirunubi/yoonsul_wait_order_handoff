#!/usr/bin/env python3
"""Compare docs/directory_tree.txt with 000005 and 000007 index files."""
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
TREE = DOCS / "directory_tree.txt"
INDEX005 = DOCS / "000005_Index_Document_Number.md"
INDEX007 = DOCS / "000007_Map_Full_Directory.md"


def fs_md_files() -> set[str]:
    out = set()
    for p in DOCS.rglob("*.md"):
        if "_migration_history" in p.as_posix():
            continue
        rel = p.relative_to(DOCS).as_posix().replace("/", "\\")
        out.add(rel)
    return out


def indexed_005() -> set[str]:
    text = INDEX005.read_text(encoding="utf-8", errors="replace")
    return set(m.group(1).replace("/", "\\") for m in re.finditer(r"\|\s*(docs\\[^|]+\.md)\s*\|", text))


def indexed_007_basenames() -> set[str]:
    text = INDEX007.read_text(encoding="utf-8", errors="replace")
    # lines inside tree block with .md
    names = set(re.findall(r"^\s{4,}([\w\d_\-]+\.md)\s*$", text, re.M))
    return names


def main():
    fs = fs_md_files()
    idx005 = indexed_005()
    idx005_rel = {p.replace("docs\\", "") for p in idx005}

    missing005 = sorted(fs - idx005_rel)
    extra005 = sorted(idx005_rel - fs)

    print(f"FS md files: {len(fs)}")
    print(f"000005 indexed: {len(idx005_rel)}")
    print(f"Missing from 000005: {len(missing005)}")
    print(f"Extra in 000005 (not on disk): {len(extra005)}")

    by_top = defaultdict(list)
    for p in missing005:
        by_top[p.split("\\")[0]].append(p)

    print("\n=== Missing from 000005 by top folder ===")
    for k in sorted(by_top.keys()):
        print(f"  {k}: {len(by_top[k])}")

    print("\n=== First 100 missing ===")
    for p in missing005[:100]:
        print(f"  docs\\{p}")

    # 000007: compare basenames present in fs vs 007 tree
    idx007 = indexed_007_basenames()
    fs_names = {Path(p).name for p in fs}
    missing007_names = sorted(fs_names - idx007)
    print(f"\n000007 tree basenames: {len(idx007)}")
    print(f"Missing basenames from 000007 (may include duplicates across folders): {len(missing007_names)}")
    for n in missing007_names[:50]:
        print(f"  {n}")

    # Write full missing list to temp file
    out = ROOT / "tools" / "missing_from_000005.txt"
    out.write_text("\n".join(f"docs\\{p}" for p in missing005), encoding="utf-8")
    print(f"\nFull list written to {out}")


if __name__ == "__main__":
    main()
