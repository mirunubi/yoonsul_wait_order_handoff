#!/usr/bin/env python3
"""Mechanical empty-shell probe for 9 template-clone suspect doc folders."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FOLDERS = [
    "docs/011500_pos_gateway_runtime_flow_implementation_package",
    "docs/015000_membership_loyalty",
    "docs/016000_admin_console_saas_operations_control",
    "docs/018000_ai_customer_center_sop_knowledge_automation",
    "docs/019000_data_model_state_machine_runtime_event_contract",
    "docs/023000_implementation_planning",
    "docs/025000_security_audit_evidence_financial_grade_control",
    "docs/027000_deployment_operations_release_runtime_control",
    "docs/029000_operations_sop_store_runbook_support_closure",
]

TYPE_PATTERNS = [
    ("Overview", re.compile(r"_Overview_", re.I)),
    ("Matrix", re.compile(r"_Matrix_", re.I)),
    ("Checklist", re.compile(r"_Checklist_", re.I)),
    ("Evidence", re.compile(r"_Evidence_", re.I)),
    ("Governance", re.compile(r"_Governance_", re.I)),
    ("Boundary", re.compile(r"_Boundary_", re.I)),
    ("Register", re.compile(r"_Register_", re.I)),
    ("Runbook", re.compile(r"_Runbook_", re.I)),
    ("Logic", re.compile(r"_Logic_", re.I)),
    ("Spec", re.compile(r"_Spec_", re.I)),
]

H1_RE = re.compile(r"^#\s+(.+)$", re.M)
TABLE_ROW_RE = re.compile(r"^\|.+\|.+\|", re.M)


def classify(name: str) -> str | None:
    for label, pat in TYPE_PATTERNS:
        if pat.search(name):
            return label
    return None


def normalize_body(text: str) -> str:
    """Strip H1 and common per-file title lines for body comparison."""
    lines = text.splitlines()
    out: list[str] = []
    skip_meta = True
    for line in lines:
        if skip_meta:
            if line.startswith("# "):
                continue
            if line.strip() == "":
                continue
            if re.match(r"^-\s+(Document|Doc|Band|Folder|Package|Domain|Wave|Status|Owner|Scope)\b", line, re.I):
                continue
            if re.match(r"^>\s+", line):
                continue
            skip_meta = False
        out.append(line)
    body = "\n".join(out).strip()
    body = re.sub(r"\b\d{5,6}\b", "NUM", body)
    body = re.sub(r"\s+", " ", body)
    return body


def pick_samples(files: list[Path]) -> list[tuple[str, Path]]:
    by_type: dict[str, Path] = {}
    for f in files:
        t = classify(f.name)
        if t and t not in by_type:
            by_type[t] = f
    order = ["Overview", "Matrix", "Checklist", "Evidence", "Governance", "Boundary", "Register", "Runbook", "Logic", "Spec"]
    picked: list[tuple[str, Path]] = []
    for t in order:
        if t in by_type:
            picked.append((t, by_type[t]))
        if len(picked) >= 3:
            break
    if len(picked) < 2:
        for f in files[:3]:
            picked.append((classify(f.name) or "Other", f))
    return picked[:3]


def has_md_table(text: str) -> bool:
    return bool(TABLE_ROW_RE.search(text))


def find_readme(folder: Path) -> Path | None:
    for f in folder.glob("*Readme*.md"):
        return f
    return None


def readme_self_desc(text: str) -> str:
    snippets: list[str] = []
    for line in text.splitlines()[:40]:
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if len(s) > 20:
            snippets.append(s[:200])
        if len(snippets) >= 2:
            break
    return " | ".join(snippets) if snippets else "(no prose in first 40 lines)"


def grep_impl_hints(folder: Path, readme_text: str) -> dict:
    """Mechanical grep for schema/function hints in folder + sql/migrations."""
    hints: set[str] = set()
    kw_re = re.compile(
        r"\b(catchmenu_[a-z0-9_]+|[a-z_]+\(\)|sql/migrations/\d{4}_[a-z0-9_]+\.sql)\b",
        re.I,
    )
    sample_text = readme_text
    for f in list(folder.glob("*.md"))[:5]:
        try:
            sample_text += "\n" + f.read_text(encoding="utf-8")[:3000]
        except OSError:
            pass
    for m in kw_re.finditer(sample_text):
        hints.add(m.group(1).lower())

    mig_dir = ROOT / "sql" / "migrations"
    found_mig: list[str] = []
    found_in_sql = False
    if mig_dir.is_dir():
        for h in sorted(hints):
            if h.endswith("()"):
                fn = h[:-2]
                for sql in mig_dir.glob("*.sql"):
                    try:
                        if fn in sql.read_text(encoding="utf-8", errors="ignore").lower():
                            found_mig.append(sql.name)
                            found_in_sql = True
                            break
                    except OSError:
                        pass
            elif h.startswith("catchmenu_"):
                for sql in mig_dir.glob("*.sql"):
                    try:
                        if h in sql.read_text(encoding="utf-8", errors="ignore").lower():
                            found_mig.append(sql.name)
                            found_in_sql = True
                            break
                    except OSError:
                        pass

    return {
        "hints_sampled": sorted(hints)[:8],
        "migration_hits": found_mig[:5],
        "any_migration_hit": found_in_sql,
    }


def bodies_identical(paths: list[Path]) -> tuple[bool, float, list[str]]:
    bodies = []
    names = []
    for p in paths:
        text = p.read_text(encoding="utf-8")
        bodies.append(normalize_body(text))
        names.append(p.name)
    if len(bodies) < 2:
        return False, 0.0, names
    ref = bodies[0]
    same = all(b == ref for b in bodies[1:])
    # similarity ratio
    lens = [len(b) for b in bodies]
    min_len = min(lens) or 1
    ratios = []
    for b in bodies[1:]:
        common = sum(1 for a, c in zip(ref, b) if a == c)
        ratios.append(common / max(len(ref), len(b), 1))
    avg_ratio = sum(ratios) / len(ratios) if ratios else 0.0
    return same, avg_ratio, names


def classify_folder(folder_rel: str) -> dict:
    folder = ROOT / folder_rel.replace("/", "\\")
    files = sorted(folder.glob("*.md"))
    samples = pick_samples(files)
    sample_paths = [p for _, p in samples]
    identical, sim_ratio, sample_names = bodies_identical(sample_paths)

    matrix_files = [f for f in files if "_Matrix_" in f.name]
    matrix_table_flags = {f.name: has_md_table(f.read_text(encoding="utf-8")) for f in matrix_files[:3]}

    readme = find_readme(folder)
    readme_text = readme.read_text(encoding="utf-8") if readme else ""
    readme_desc = readme_self_desc(readme_text) if readme else "(no Readme)"

    impl = grep_impl_hints(folder, readme_text)

    # verdict rules (mechanical)
    matrix_any_table = any(matrix_table_flags.values()) if matrix_table_flags else None
    wave_batch_markers = bool(
        re.search(r"batch\s*7|wave\s*1|expansion\s*wave|placeholder|scaffold|skeleton|density", readme_text, re.I)
    )

    if identical or sim_ratio >= 0.95:
        verdict = "빈껍데기 확인"
    elif sim_ratio >= 0.75 and not matrix_any_table:
        verdict = "빈껍데기 확인"
    elif impl["any_migration_hit"] and sim_ratio < 0.85:
        verdict = "실제내용 있음"
    elif not identical and sim_ratio < 0.85:
        verdict = "실제내용 있음"
    else:
        verdict = "불확실"

    return {
        "folder": folder_rel,
        "file_count": len(files),
        "samples": [{"type": t, "file": p.name} for t, p in samples],
        "body_identical_after_strip": identical,
        "body_similarity_ratio": round(sim_ratio, 3),
        "matrix_files_checked": matrix_table_flags,
        "readme": readme.name if readme else None,
        "readme_self_desc_excerpt": readme_desc[:300],
        "wave_batch_marker_in_readme": wave_batch_markers,
        "impl_grep": impl,
        "verdict": verdict,
    }


def main() -> None:
    results = [classify_folder(f) for f in FOLDERS]
    out = ROOT / "tools" / "_probe_9folders.json"
    out.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    print("written", out)


if __name__ == "__main__":
    main()
