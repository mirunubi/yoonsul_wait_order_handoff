#!/usr/bin/env python3
"""Batch 7 expansion wave rescan — mechanical Eyes Only."""
from __future__ import annotations

import hashlib
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"

ALREADY_HANDLED = {
    "docs/011500_pos_gateway_runtime_flow_implementation_package",
    "docs/016000_admin_console_saas_operations_control",
    "docs/018000_ai_customer_center_sop_knowledge_automation",
    "docs/019000_data_model_state_machine_runtime_event_contract",
    "docs/023000_implementation_planning",
    "docs/025000_security_audit_evidence_financial_grade_control",
    "docs/027000_deployment_operations_release_runtime_control",
    "docs/029000_operations_sop_store_runbook_support_closure",
    "docs/700000_runtime_flow_bundle",
}

BATCH7_RE = re.compile(r"Batch\s+7([A-Z0-9]+)", re.I)
PREFIX_RE = re.compile(r"^(\d{5,6})_")
TABLE_RE = re.compile(r"^\|.+\|.+\|", re.M)


def strip_h1_purpose(text: str) -> str:
    lines = text.splitlines()
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("# "):
            i += 1
            continue
        if line.strip() == "## Purpose":
            i += 1
            while i < len(lines) and not (lines[i].startswith("## ") and lines[i].strip() != "## Purpose"):
                i += 1
            continue
        out.append(line)
        i += 1
    body = re.sub(r"\s+", " ", "\n".join(out).strip())
    return body


def scan_batch7_mentions() -> dict:
    by_file: list[dict] = []
    by_folder: dict[str, set[str]] = defaultdict(set)
    all_labels: Counter[str] = Counter()

    for p in sorted(DOCS.rglob("*.md")):
        try:
            text = p.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        labels = sorted({f"7{m.group(1).upper()}" for m in BATCH7_RE.finditer(text)})
        if not labels:
            continue
        rel = str(p.relative_to(ROOT)).replace("\\", "/")
        folder = rel.rsplit("/", 1)[0] if "/" in rel else "docs"
        for lb in labels:
            all_labels[lb] += 1
            by_folder[folder].add(lb)
        by_file.append({"path": rel, "folder": folder, "labels": labels})

    return {
        "file_count": len(by_file),
        "label_counts": dict(sorted(all_labels.items())),
        "by_folder": {k: sorted(v) for k, v in sorted(by_folder.items())},
        "files": by_file,
    }


def scan_relaxed_folders() -> list[dict]:
    folder_files: dict[Path, list[Path]] = defaultdict(list)
    for p in DOCS.rglob("*.md"):
        folder_files[p.parent].append(p)

    suspects = []
    for folder, files in sorted(folder_files.items(), key=lambda x: str(x[0])):
        if len(files) < 3:
            continue
        rel_folder = str(folder.relative_to(ROOT)).replace("\\", "/")
        sizes = [f.stat().st_size for f in files]
        median = sorted(sizes)[len(sizes) // 2]
        if median == 0:
            continue
        within10 = sum(1 for s in sizes if abs(s - median) / median <= 0.10)
        ratio10 = within10 / len(sizes)

        body_hashes = Counter()
        for f in files:
            try:
                h = hashlib.sha256(strip_h1_purpose(f.read_text(encoding="utf-8")).encode()).hexdigest()[:16]
                body_hashes[h] += 1
            except OSError:
                pass
        dom_hash, dom_count = body_hashes.most_common(1)[0] if body_hashes else ("", 0)
        dom_ratio = dom_count / len(files)

        matrix_files = [f for f in files if "_Matrix_" in f.name]
        matrix_with_table = 0
        for f in matrix_files[:5]:
            try:
                if TABLE_RE.search(f.read_text(encoding="utf-8")):
                    matrix_with_table += 1
            except OSError:
                pass

        flagged = (
            ratio10 >= 0.75
            or dom_ratio >= 0.70
            or (dom_ratio >= 0.50 and len(files) >= 10)
        )
        if not flagged:
            continue

        suspects.append(
            {
                "folder": rel_folder,
                "file_count": len(files),
                "median_bytes": median,
                "within_10pct_ratio": round(ratio10, 3),
                "dominant_body_ratio": round(dom_ratio, 3),
                "unique_body_hashes": len(body_hashes),
                "matrix_count": len(matrix_files),
                "matrix_sample_with_table": matrix_with_table,
                "already_handled": rel_folder in ALREADY_HANDLED
                or rel_folder.startswith("docs/015000_membership_loyalty"),
            }
        )
    return suspects


def scan_global_duplicate_bodies(min_files: int = 5) -> list[dict]:
    hash_to_files: dict[str, list[str]] = defaultdict(list)
    for p in DOCS.rglob("*.md"):
        try:
            body = strip_h1_purpose(p.read_text(encoding="utf-8"))
            if len(body) < 200:
                continue
            h = hashlib.sha256(body.encode()).hexdigest()[:16]
            hash_to_files[h].append(str(p.relative_to(ROOT)).replace("\\", "/"))
        except (UnicodeDecodeError, OSError):
            continue

    clusters = []
    for h, paths in sorted(hash_to_files.items(), key=lambda x: -len(x[1])):
        if len(paths) < min_files:
            continue
        folders = sorted({p.rsplit("/", 1)[0] for p in paths})
        clusters.append(
            {
                "body_hash": h,
                "file_count": len(paths),
                "folder_count": len(folders),
                "folders": folders[:20],
                "sample_files": paths[:5],
            }
        )
    return clusters[:30]


def scan_planning_docs() -> list[dict]:
    patterns = [
        re.compile(r"Batch\s+7[A-Z0-9]+", re.I),
        re.compile(r"7[A-Z0-9]+\s+(density|expansion|wave|roadmap|gap|closeout|staging|recount)", re.I),
    ]
    hits = []
    for p in sorted(DOCS.rglob("*.md")):
        name = p.name
        if not (name.startswith("0000") or "Batch_7" in name or "batch_7" in name.lower()):
            continue
        try:
            text = p.read_text(encoding="utf-8")
        except OSError:
            continue
        if not any(pat.search(text) or pat.search(name) for pat in patterns):
            continue
        labels = sorted({f"7{m.group(1).upper()}" for m in BATCH7_RE.finditer(text + " " + name)})
        wave_lines = [
            ln.strip()
            for ln in text.splitlines()
            if re.search(r"Batch\s+7|Wave\s*1|Expansion\s*Wave|7[A-Z]\b", ln, re.I)
        ][:15]
        hits.append(
            {
                "path": str(p.relative_to(ROOT)).replace("\\", "/"),
                "labels_mentioned": labels,
                "wave_lines_sample": wave_lines,
            }
        )
    return hits


def main() -> None:
    batch7 = scan_batch7_mentions()
    relaxed = scan_relaxed_folders()
    clusters = scan_global_duplicate_bodies()
    planning = scan_planning_docs()

    handled_folders = set(ALREADY_HANDLED) | {"docs/015000_membership_loyalty"}
    batch7_folders_new = {
        k: v for k, v in batch7["by_folder"].items() if k not in handled_folders
    }
    batch7_folders_handled = {
        k: v for k, v in batch7["by_folder"].items() if k in handled_folders
    }

    new_suspects = [s for s in relaxed if not s["already_handled"]]

    out = {
        "batch7_mentions": batch7,
        "batch7_folders_already_handled": batch7_folders_handled,
        "batch7_folders_new_or_other": batch7_folders_new,
        "relaxed_suspects_all": relaxed,
        "relaxed_suspects_new": new_suspects,
        "global_duplicate_body_clusters": clusters,
        "planning_docs": planning,
    }
    path = ROOT / "tools" / "_batch7_rescan.json"
    path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print("written", path)
    print("batch7_files", batch7["file_count"])
    print("batch7_folders", len(batch7["by_folder"]))
    print("new_folders_with_batch7", len(batch7_folders_new))
    print("new_relaxed_suspects", len(new_suspects))
    print("planning_docs", len(planning))


if __name__ == "__main__":
    main()
