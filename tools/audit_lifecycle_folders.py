#!/usr/bin/env python3
"""Audit docs folders for Implementation Lifecycle pack completeness per 000001_Md_Rules."""
from __future__ import annotations

from pathlib import Path

DOCS = Path(__file__).resolve().parents[1] / "docs"
SKIP = {"_migration_history"}

TYPES = [
    "Readme",
    "Index",
    "ImpactScope",
    "Overview",
    "Logic",
    "TestPlan",
    "ChangeContract",
    "Approval",
    "Module",
    "Verification",
    "Audit",
    "NavigationMap",
    "Analysis",
    "Implementation",
    "WorkPackage",
]

PRE_PACK = ["Overview", "Logic", "TestPlan", "ChangeContract", "NavigationMap"]
ENTRY = ["Index", "Readme"]


def detect_types(files: list[Path]) -> set[str]:
    found: set[str] = set()
    for f in files:
        name = f.name
        for t in TYPES:
            if f"_{t}_" in name:
                found.add(t)
        if "_Approval_Gate_" in name or "_ApprovalGate_" in name:
            found.add("Approval")
    return found


def is_lifecycle_folder(types: set[str]) -> bool:
    lifecycle = {
        "Overview",
        "Logic",
        "TestPlan",
        "ChangeContract",
        "ImpactScope",
        "NavigationMap",
        "Module",
        "Verification",
        "Audit",
        "Approval",
        "WorkPackage",
    }
    return bool(types & lifecycle)


def classify(types: set[str]) -> str:
    has_entry = any(t in types for t in ENTRY)
    has_olt = all(t in types for t in ["Overview", "Logic", "TestPlan"])
    has_cc = "ChangeContract" in types
    has_nav = "NavigationMap" in types
    if has_entry and has_olt and has_cc and has_nav:
        return "FULL_PRE_PACK"
    if has_olt and has_nav:
        return "PARTIAL_MISSING_PRE_ITEM"
    if has_olt and not has_nav:
        return "MISSING_NAVIGATIONMAP"
    if types & {"Overview", "Logic", "TestPlan", "ChangeContract", "NavigationMap", "ImpactScope"}:
        return "INCOMPLETE_LIFECYCLE"
    return "OTHER"


def main() -> None:
    rows: list[tuple[str, set[str], str, int]] = []
    for folder in sorted(DOCS.rglob("*")):
        if not folder.is_dir():
            continue
        if any(p in SKIP for p in folder.parts):
            continue
        md_files = [f for f in folder.iterdir() if f.is_file() and f.suffix.lower() == ".md"]
        if not md_files:
            continue
        types = detect_types(md_files)
        if not is_lifecycle_folder(types):
            continue
        rel = folder.relative_to(DOCS).as_posix()
        cat = classify(types)
        rows.append((rel, types, cat, len(md_files)))

    by_cat: dict[str, list] = {}
    for r in rows:
        by_cat.setdefault(r[2], []).append(r)

    print("=" * 72)
    print("Implementation Lifecycle Folder Audit (000001 Md_Rules §5.4.3 / §5.4.11)")
    print("=" * 72)
    print()
    print("FULL pre-pack = Index/Readme + Overview + Logic + TestPlan + ChangeContract + NavigationMap")
    print()
    print(f"Total lifecycle-intent folders scanned: {len(rows)}")
    for cat in [
        "FULL_PRE_PACK",
        "PARTIAL_MISSING_PRE_ITEM",
        "MISSING_NAVIGATIONMAP",
        "INCOMPLETE_LIFECYCLE",
    ]:
        print(f"  {cat}: {len(by_cat.get(cat, []))}")
    print()

    def miss_list(types: set[str]) -> list[str]:
        miss = []
        if not any(t in types for t in ENTRY):
            miss.append("Index/Readme")
        for t in PRE_PACK:
            if t not in types:
                miss.append(t)
        return miss

    print("-" * 72)
    print("OK - FULL pre-pack folders")
    print("-" * 72)
    for rel, types, _, n in sorted(by_cat.get("FULL_PRE_PACK", [])):
        print(f"  [OK] {rel}  ({n} files)")

    print()
    print("-" * 72)
    print("MISSING NavigationMap (has Overview+Logic+TestPlan but no NavigationMap)")
    print("-" * 72)
    for rel, types, _, n in sorted(by_cat.get("MISSING_NAVIGATIONMAP", [])):
        print(f"  [NAV] {rel}")
        print(f"        missing: {', '.join(miss_list(types))}")

    print()
    print("-" * 72)
    print("PARTIAL — has OLT+NavigationMap but missing other pre-pack item")
    print("-" * 72)
    for rel, types, _, n in sorted(by_cat.get("PARTIAL_MISSING_PRE_ITEM", [])):
        print(f"  [PARTIAL] {rel}")
        print(f"            missing: {', '.join(miss_list(types))}")

    print()
    print("-" * 72)
    print("INCOMPLETE — lifecycle docs present but missing Overview/Logic/TestPlan trio")
    print("-" * 72)
    for rel, types, _, n in sorted(by_cat.get("INCOMPLETE_LIFECYCLE", [])):
        print(f"  [INCOMPLETE] {rel}  ({n} files)")
        print(f"               have: {sorted(types)}")
        print(f"               missing: {', '.join(miss_list(types))}")

    # Top-level domain folders: Readme without lifecycle
    print()
    print("-" * 72)
    print("Top-level domain folders (direct under docs/) — Readme / NavigationMap check")
    print("-" * 72)
    for folder in sorted(DOCS.iterdir()):
        if not folder.is_dir() or folder.name in SKIP:
            continue
        md_files = [f for f in folder.iterdir() if f.is_file() and f.suffix.lower() == ".md"]
        types = detect_types(md_files)
        has_readme = "Readme" in types
        has_nav = "NavigationMap" in types
        subdirs = [d for d in folder.iterdir() if d.is_dir()]
        status = "OK" if has_readme else "NO_README"
        nav_note = " + NavigationMap" if has_nav else ""
        print(f"  [{status}] {folder.name}/  ({len(subdirs)} subdirs, {len(md_files)} root md){nav_note}")


if __name__ == "__main__":
    main()
