#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build 6-slice Fable delivery packages for Customer Handoff (601400 domain 01)."""
from __future__ import annotations

import json
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INV = (
    ROOT
    / "docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/domain_01_customer_handoff/601411_Inventory_Customer_Handoff.ndjson"
)
STRUCT = (
    ROOT
    / "docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/domain_01_customer_handoff/601412_Register_Stage1_Structural_Issues_Customer_Handoff.md"
)
STAGE2 = (
    ROOT
    / "docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/domain_01_customer_handoff/601413_Register_Stage2_Domain_Classification_Customer_Handoff.md"
)
OUT = (
    ROOT
    / "docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/domain_01_customer_handoff/slices"
)

SLICES = [
    {
        "id": "slice_01_waiting",
        "num": "601421",
        "title": "slice_01 — Waiting (600600 + waiting SQL)",
        "doc_patterns": [
            r"600600_waiting_order_session",
            r"601330_domain_02_waiting",
            r"601335_PassA.*Waiting",
            r"601331_PassA.*Waiting",
            r"601332_PassA.*Waiting",
            r"601333_PassA.*Waiting",
            r"601334_PassA.*Waiting",
            r"fable_pass_a/03_waiting",
            r"fable_pass_a/600600_slices",
            r"600600_slices",
        ],
        "migration_patterns": [
            r"waiting",
            r"register_waiting",
            r"call_waiting",
            r"call_next",
            r"seat_waiting",
            r"cancel_waiting",
            r"no_show",
            r"pre_order",
            r"order_session",
            r"bind_table",
            r"0012_create_pos_order_sessions",
            r"0013_create_pos_orders",
            r"0025_create_session",
            r"0026_create_order",
            r"0049_",
            r"0050_create_waiting",
            r"0051_create_pre_order",
            r"0115_create_waiting",
            r"0149_create_guest",
            r"0160_call_waiting",
            r"0161_mark_no_show",
            r"0163_seat_waiting",
            r"0164_waiting_pipeline",
            r"0167_record_waiting",
        ],
    },
    {
        "id": "slice_02_payment",
        "num": "601422",
        "title": "slice_02 — Payment (600500 + payment SQL)",
        "doc_patterns": [
            r"600500_payment_confirmation",
            r"601320_domain_01_payment",
            r"601321_PassA.*Payment",
            r"fable_pass_a/02_payment",
        ],
        "migration_patterns": [
            r"payment",
            r"toss",
            r"ledger",
            r"confirm_payment",
            r"mark_payment",
            r"authorize_kds_release",
            r"0098_create_payment",
            r"0103_create_toss",
            r"0143_",
            r"0014_create_payment",
            r"0015_",
            r"0017_",
            r"0166_canonical_kds_release",
        ],
    },
    {
        "id": "slice_03_kds_did",
        "num": "601423",
        "title": "slice_03 — KDS/DID (600400 + 600800 + kds/did SQL)",
        "doc_patterns": [
            r"600400_kds_did",
            r"600800_did_implementation",
            r"601350_domain_04_kds",
            r"601020_authorize_kds",
            r"fable_pass_a/05_kds_did",
        ],
        "migration_patterns": [
            r"kds",
            r"did",
            r"release_kds",
            r"bootstrap_kds",
            r"check_kds_capacity",
            r"0016_create_kds",
            r"0151_create_check_kds",
            r"0166_canonical_kds",
            r"0070_",
            r"0080_create_cms",
            r"0107_create_mini_cms",
        ],
    },
    {
        "id": "slice_04_customer_handoff_policy",
        "num": "601424",
        "title": "slice_04 — Customer Handoff Policy + Patent (005000 + 900000)",
        "doc_patterns": [
            r"^docs/005000",
            r"^docs/900000",
            r"005000_customer_handoff",
        ],
        "migration_patterns": [
            r"handoff",
            r"0109_create_network_handoff",
            r"0081_create_customer_app",
            r"0116_create_customer_app",
        ],
    },
    {
        "id": "slice_05_runtime_flow",
        "num": "601425",
        "title": "slice_05 — Runtime Flow (700000_runtime_flow_bundle)",
        "doc_patterns": [
            r"700000_runtime_flow",
        ],
        "migration_patterns": [
            r"runtime",
            r"gateway",
            r"pos_gateway",
            r"011500_pos_gateway",
        ],
    },
    {
        "id": "slice_06_app_layer",
        "num": "601426",
        "title": "slice_06 — App Layer (600200 Flutter + catchmenu_app)",
        "doc_patterns": [
            r"600200_flutter_waiting",
            r"^catchmenu_app/",
        ],
        "migration_patterns": [
            r"0116_create_customer_app",
            r"0081_create_customer_app",
            r"0149_create_guest",
        ],
    },
]

FABLE_SINGLE_PASS_SOFT_LIMIT = 1_500_000  # ~1.5 MiB guidance


def load_records() -> list[dict]:
    return [
        json.loads(line)
        for line in INV.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def matches_any(text: str, patterns: list[str]) -> bool:
    return any(re.search(p, text, re.I) for p in patterns)


def assign_primary_slice(path: str) -> str | None:
    for sl in SLICES:
        if matches_any(path, sl["doc_patterns"]):
            return sl["id"]
    return None


def migration_slices(filename: str) -> list[str]:
    hits = []
    for sl in SLICES:
        if matches_any(filename, sl["migration_patterns"]):
            hits.append(sl["id"])
    return hits


def extract_struct_excerpt(slice_id: str, struct_text: str) -> str:
    lines = struct_text.splitlines()
    out = [
        f"## Structural issues excerpt — {slice_id}",
        "",
        "(From 601412_Register_Stage1_Structural_Issues_Customer_Handoff.md — slice-relevant rows only)",
        "",
    ]
    keywords = {
        "slice_01_waiting": ["600600", "waiting", "601330", "60133"],
        "slice_02_payment": ["600500", "payment", "601320"],
        "slice_03_kds_did": ["600400", "600800", "kds", "601350"],
        "slice_04_customer_handoff_policy": ["005000", "900000", "604000"],
        "slice_05_runtime_flow": ["700000", "runtime"],
        "slice_06_app_layer": ["600200", "catchmenu_app", "flutter"],
    }
    kws = keywords.get(slice_id, [])
    for line in lines:
        if any(k.lower() in line.lower() for k in kws):
            out.append(line)
    if len(out) <= 4:
        out.append("- (No slice-specific rows matched by keyword filter in 601412.)")
    return "\n".join(out)


def extract_stage2_excerpt(slice_id: str, stage2_text: str) -> str:
    keywords = {
        "slice_01_waiting": ["600600", "waiting", "601300"],
        "slice_02_payment": ["600500", "payment"],
        "slice_03_kds_did": ["600400", "600800", "kds", "did"],
        "slice_04_customer_handoff_policy": ["005000", "900000"],
        "slice_05_runtime_flow": ["700000", "runtime"],
        "slice_06_app_layer": ["600200", "catchmenu_app", "flutter"],
    }
    kws = keywords.get(slice_id, [])
    out = [
        f"## Stage 2 classification excerpt — {slice_id}",
        "",
        "(From 601413 — lines mentioning slice scope paths only)",
        "",
    ]
    for line in stage2_text.splitlines():
        if line.startswith("- `") and any(k.lower() in line.lower() for k in kws):
            out.append(line)
    if len(out) <= 4:
        out.append("- (No matching classification lines by keyword filter.)")
    return "\n".join(out)


def build_slice_package(
    sl: dict,
    md_files: list[dict],
    sql_files: list[dict],
    struct_text: str,
    stage2_text: str,
) -> None:
    slice_dir = OUT / sl["id"]
    slice_dir.mkdir(parents=True, exist_ok=True)

    all_files = md_files + sql_files
    total_bytes = sum(f["size_bytes"] for f in all_files)

    # SQL concat
    concat_path = slice_dir / f"{sl['id']}_migrations_concat.sql"
    concat_parts = [
        f"-- {sl['title']}",
        f"-- Files: {len(sql_files)}",
        "",
    ]
    for sf in sorted(sql_files, key=lambda x: x["path"]):
        fp = ROOT / sf["path"]
        concat_parts.append(f"\n-- ===== BEGIN {sf['path']} =====\n")
        concat_parts.append(fp.read_text(encoding="utf-8", errors="replace"))
        concat_parts.append(f"\n-- ===== END {sf['path']} =====\n")
    concat_path.write_text("\n".join(concat_parts), encoding="utf-8")
    concat_bytes = concat_path.stat().st_size

    # MD bodies section (embed if slice md <= 800KB else path-only)
    md_bytes = sum(f["size_bytes"] for f in md_files)
    embed_md = md_bytes <= 800_000

    pkg_lines = [
        f"# {sl['num']} Input Package — {sl['title']}",
        "",
        f"- Program: `601400_fable_design_integrity_inspection`",
        f"- Domain: `domain_01_customer_handoff` / `{sl['id']}`",
        f"- Method: Eyes Only — Fable single-pass delivery slice",
        f"- Created: 2026-07-19",
        "",
        "## Slice size summary",
        "",
        f"| Metric | Value |",
        f"|---|---|",
        f"| Markdown files | {len(md_files)} |",
        f"| SQL migration files | {len(sql_files)} |",
        f"| MD bytes (source) | {md_bytes:,} |",
        f"| SQL concat bytes | {concat_bytes:,} |",
        f"| **Estimated Fable payload** | **{md_bytes + concat_bytes:,}** (~{(md_bytes + concat_bytes)/1024/1024:.2f} MiB) |",
        f"| Single-pass feasible? | {'YES (soft limit <=1.5 MiB)' if md_bytes + concat_bytes <= FABLE_SINGLE_PASS_SOFT_LIMIT else 'BORDERLINE/OVER — consider sub-split'} |",
        "",
        extract_struct_excerpt(sl["id"], struct_text),
        "",
        extract_stage2_excerpt(sl["id"], stage2_text),
        "",
        "## §A — File inventory (this slice)",
        "",
        "| Path | Bytes | Doc# | Type | Status |",
        "|---|---:|---|---|---|",
    ]
    for f in sorted(all_files, key=lambda x: x["path"]):
        pkg_lines.append(
            f"| `{f['path']}` | {f['size_bytes']} | {f.get('doc_number') or '—'} | {f.get('doc_type_guess') or f['ext']} | current |"
        )

    pkg_lines += [
        "",
        "## §B — SQL migrations (concat)",
        "",
        f"Full text: [`{sl['id']}_migrations_concat.sql`]({sl['id']}_migrations_concat.sql)",
        "",
        "## §C — Markdown sources",
        "",
    ]
    if embed_md:
        for mf in sorted(md_files, key=lambda x: x["path"]):
            fp = ROOT / mf["path"]
            pkg_lines += [
                f"### `{mf['path']}`",
                "",
                fp.read_text(encoding="utf-8", errors="replace"),
                "",
                "---",
                "",
            ]
    else:
        pkg_lines.append(
            "MD total exceeds 800 KiB embed threshold — full paths listed in §A; read from repo paths."
        )

    pkg_name = f"{sl['num']}_Slice_Input_Package_{sl['id']}.md"
    (slice_dir / pkg_name).write_text("\n".join(pkg_lines), encoding="utf-8")


def main() -> None:
    records = load_records()
    struct_text = STRUCT.read_text(encoding="utf-8")
    stage2_text = STAGE2.read_text(encoding="utf-8")

    slice_md: dict[str, list[dict]] = defaultdict(list)
    slice_sql: dict[str, list[dict]] = defaultdict(list)
    unassigned: list[dict] = []

    migrations = [r for r in records if r["path"].startswith("sql/migrations/")]
    non_migrations = [r for r in records if not r["path"].startswith("sql/migrations/")]

    for r in non_migrations:
        sid = assign_primary_slice(r["path"])
        if sid:
            slice_md[sid].append(r)
        else:
            unassigned.append(r)

    # Assign unassigned scratch/601300 by secondary rules
    for r in unassigned[:]:
        p = r["path"]
        if "verify" in p and "waiting" in p:
            slice_md["slice_01_waiting"].append(r)
            unassigned.remove(r)
        elif "payment" in p.lower():
            slice_md["slice_02_payment"].append(r)
            unassigned.remove(r)
        elif "kds" in p.lower():
            slice_md["slice_03_kds_did"].append(r)
            unassigned.remove(r)
        elif "build_waiting_slices" in p or "build_input_packages" in p:
            slice_md["slice_01_waiting"].append(r)
            unassigned.remove(r)

    for r in migrations:
        fname = Path(r["path"]).name
        hits = migration_slices(fname)
        if not hits:
            continue
        for sid in hits:
            slice_sql[sid].append(r)

    OUT.mkdir(parents=True, exist_ok=True)
    manifest_lines = [
        "# 601420 Register — Customer Handoff Fable Delivery Slices",
        "",
        "- Program: `601400_fable_design_integrity_inspection`",
        "- Domain: `domain_01_customer_handoff`",
        "- Method: 6-slice split (601300 waiting 5-slice pattern)",
        "- Regenerate: `python tools/build_601400_customer_handoff_slices.py`",
        "- Created: 2026-07-19",
        "",
        "## Slice summary",
        "",
        "| Slice | Package | MD files | SQL files | MD bytes | SQL concat | Est. payload | Fable 1-pass? | Core payload (excl scratch/601300) | Core 1-pass? |",
        "|---|---|---:|---:|---:|---:|---:|---|---:|---|",
    ]

    summary = []
    for sl in SLICES:
        sid = sl["id"]
        build_slice_package(sl, slice_md[sid], slice_sql[sid], struct_text, stage2_text)
        md_b = sum(f["size_bytes"] for f in slice_md[sid])
        sql_n = len(slice_sql[sid])
        concat = (OUT / sid / f"{sid}_migrations_concat.sql").stat().st_size
        payload = md_b + concat
        core_md = sum(
            f["size_bytes"]
            for f in slice_md[sid]
            if "sql/scratch/" not in f["path"] and "601300_fable" not in f["path"]
        )
        core_payload = core_md + concat
        ok = "YES" if payload <= FABLE_SINGLE_PASS_SOFT_LIMIT else "NO/OVER"
        core_ok = "YES" if core_payload <= FABLE_SINGLE_PASS_SOFT_LIMIT else "NO/OVER"
        manifest_lines.append(
            f"| `{sid}` | `{sl['num']}` | {len(slice_md[sid])} | {sql_n} | {md_b:,} | {concat:,} | {payload:,} | {ok} | {core_payload:,} | {core_ok} |"
        )
        summary.append(
            {
                "slice": sid,
                "md_count": len(slice_md[sid]),
                "sql_count": sql_n,
                "md_bytes": md_b,
                "sql_concat_bytes": concat,
                "payload_bytes": payload,
                "core_payload_bytes": core_payload,
                "fable_single_pass": ok,
                "fable_single_pass_core": core_ok,
            }
        )

    if unassigned:
        manifest_lines += ["", "## Unassigned non-migration files (fact)", ""]
        for r in unassigned:
            manifest_lines.append(f"- `{r['path']}` ({r['size_bytes']} bytes)")

    manifest_lines += [
        "",
        "## Duplicate SQL note",
        "",
        "Migrations may appear in multiple slices (601300 pattern). Counts above are per-slice membership, not globally unique.",
        "",
        "## slice_01_waiting delivery note",
        "",
        "Full payload exceeds 1.5 MiB because `sql/scratch/fable_pass_a/` concat duplicates are included in inventory scope.",
        "For Fable single-pass delivery, use **Core payload** (600600 lifecycle docs + `slice_01_migrations_concat.sql` only; exclude scratch/601300 duplicates).",
        "",
    ]

    (OUT / "601420_Register_Slice_Manifest_Customer_Handoff.md").write_text(
        "\n".join(manifest_lines), encoding="utf-8"
    )

    print(json.dumps(summary, indent=2))
    if unassigned:
        print("UNASSIGNED", len(unassigned))


if __name__ == "__main__":
    main()
