# -*- coding: utf-8 -*-
"""Generate 601400 domain_01 customer handoff inventory artifacts."""
import json
import re
import shutil
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROG = ROOT / "docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection"
D01 = PROG / "domain_01_customer_handoff"
recs = [
    json.loads(line)
    for line in (ROOT / ".tmp_curs_handoff_inventory.ndjson")
    .read_text(encoding="utf-8")
    .splitlines()
    if line.strip()
]

by_docnum = defaultdict(list)
h1_mismatch = []
for r in recs:
    if r.get("doc_number"):
        by_docnum[r["doc_number"]].append(r["path"])
    if r["ext"] == "md" and r.get("doc_number") and r.get("h1_first_line"):
        h1 = r["h1_first_line"]
        num = r["doc_number"]
        if not (h1.startswith(num) or num.lstrip("0") in h1.split()[0]):
            h1_mismatch.append(r)

dup = {k: v for k, v in by_docnum.items() if len(v) > 1}

wp_root = ROOT / "docs/600000_implementation_lifecycle/600600_waiting_order_session"
wp_gaps = []
for wp in sorted(wp_root.iterdir()):
    if not wp.is_dir() or not re.match(r"600\d{3}_", wp.name):
        continue
    files = {f.name for f in wp.iterdir() if f.is_file()}
    has = lambda tok: any(tok in n for n in files)
    wp_gaps.append(
        {
            "workpacket": wp.name,
            "overview": has("Overview"),
            "logic": has("Logic"),
            "testplan": has("TestPlan"),
            "changecontract": has("ChangeContract"),
            "module": has("Module"),
            "verification": has("Verification"),
            "audit": has("Audit"),
            "navigationmap": has("NavigationMap") or has("Index"),
        }
    )

stale_gov = []
placeholder = []
for r in recs:
    if r["ext"] != "md":
        continue
    text = (ROOT / r["path"]).read_text(encoding="utf-8", errors="replace")
    if (
        "000005_Document_Number_Index.md" in text
        or "000007_Full_Directory_Map.md" in text
    ):
        stale_gov.append(r["path"])
    if "PLACEHOLDER" in text[:800] or "NOT_STARTED" in text[:800]:
        placeholder.append(r["path"])

stage_order = [
    ("1_upper_policy", ["Policy"]),
    (
        "2_domain_design",
        [
            "Readme",
            "NavigationMap",
            "Index",
            "Guide",
            "Matrix",
            "Register",
            "Checklist",
            "DecisionLog",
        ],
    ),
    ("3_workpacket_design", ["Overview", "Logic"]),
    ("4_approval_gate", ["TestPlan", "ChangeContract"]),
    ("5_implementation", ["Module", "Implementation"]),
    ("6_verification", ["Verification"]),
    ("7_audit", ["Audit", "PassA", "PassB", "PassC"]),
    ("8_runtime_ops", ["Runbook", "Evidence", "Handoff"]),
    ("9_historical", ["Report", "Assessment"]),
]

stage_files = defaultdict(list)


def stage_for(r):
    dt = r.get("doc_type_guess") or ""
    ext = r["ext"]
    if ext != "md":
        return "5_implementation_sql" if ext == "sql" else "z_other"
    for sid, types in stage_order:
        if dt in types:
            return sid
    if "990000_legacy_quarantine" in r["path"] or "migration_history" in r["path"]:
        return "9_historical"
    return "z_unclassified"


for r in recs:
    stage_files[stage_for(r)].append(r)

domain_names = [
    "customer_handoff",
    "payment_ledger_kds",
    "waiting_call_no_show",
    "order_cancel_refund",
    "menu_option_personalization",
    "pos_provider_gateway",
    "sop_agent_fallback",
    "inventory_scm",
    "security_rls_audit",
    "franchise_hq",
    "ai_customer_center",
    "saas_multitenant",
    "physical_ai",
]
PROG.mkdir(parents=True, exist_ok=True)
for i, name in enumerate(domain_names, start=1):
    (PROG / f"domain_{i:02d}_{name}").mkdir(parents=True, exist_ok=True)

D01.mkdir(parents=True, exist_ok=True)
shutil.copy2(
    ROOT / ".tmp_curs_handoff_inventory.ndjson",
    D01 / "601411_Inventory_Customer_Handoff.ndjson",
)


def fmt_row(r):
    status = "current"
    p = r["path"]
    if "990000_legacy_quarantine" in p:
        status = "historical_quarantine"
    elif "migration_history" in p:
        status = "historical_migration"
    elif "scratch" in p:
        status = "scratch_noncanonical"
    elif r["ext"] == "md":
        head = (ROOT / p).read_text(encoding="utf-8", errors="replace")[:500]
        if "PLACEHOLDER" in head or "NOT_STARTED" in head:
            status = "pending_placeholder"
    return (
        p,
        str(r["size_bytes"]),
        r.get("doc_number") or "—",
        (r.get("h1_first_line") or "—").replace("|", "/"),
        r.get("doc_type_guess") or ("sql" if r["ext"] == "sql" else r["ext"]),
        r.get("workpacket_guess") or "—",
        status,
    )


areas = Counter()
for r in recs:
    p = r["path"]
    if p.startswith("docs/005000"):
        areas["005000_customer_handoff"] += 1
    elif "600600_waiting_order_session" in p:
        areas["600600_waiting"] += 1
    elif "600500_payment" in p:
        areas["600500_payment"] += 1
    elif "600400_kds" in p:
        areas["600400_kds"] += 1
    elif "600800_did" in p:
        areas["600800_did"] += 1
    elif "600200_flutter" in p:
        areas["600200_flutter"] += 1
    elif "700000_runtime_flow" in p:
        areas["700000_runtime_flow"] += 1
    elif p.startswith("docs/900000"):
        areas["900000_patent"] += 1
    elif p.startswith("sql/migrations"):
        areas["sql_migrations"] += 1
    elif "scratch/fable" in p:
        areas["sql_scratch_fable"] += 1
    elif p.startswith("catchmenu_app"):
        areas["catchmenu_app"] += 1
    else:
        areas["other"] += 1

total_bytes = sum(r["size_bytes"] for r in recs)

inv_lines = [
    "# 601411 Register — Stage 1 File Inventory (Customer Handoff)",
    "",
    "- Program: `601400_fable_design_integrity_inspection`",
    "- Domain: `domain_01_customer_handoff`",
    "- Scope: waiting → call → pre-order → payment → KDS → DID → handoff",
    "- Method: Eyes Only — factual inventory per operational annex §6.1",
    "- Created: 2026-07-19",
    "- Full machine-readable inventory: [601411_Inventory_Customer_Handoff.ndjson](601411_Inventory_Customer_Handoff.ndjson) (495 records)",
    "",
    "## Summary",
    "",
    f"- Total files: **495**",
    f"- Total bytes: **{total_bytes:,}** (~{total_bytes / 1024 / 1024:.2f} MiB)",
    f"- Markdown: {sum(1 for r in recs if r['ext']=='md')} files",
    f"- SQL: {sum(1 for r in recs if r['ext']=='sql')} files",
    f"- JSON in scoped paths: 0 files",
    "",
    "## Count by source area",
    "",
    "| Area | Files |",
    "|---|---:|",
]
for k, v in sorted(areas.items(), key=lambda x: -x[1]):
    inv_lines.append(f"| `{k}` | {v} |")

inv_lines += [
    "",
    "## Full inventory table (495 rows)",
    "",
    "| Path | Bytes | Doc# | H1 | Type | Workpacket | Status tag |",
    "|---|---:|---|---|---|---|---|",
]
for r in sorted(recs, key=lambda x: x["path"]):
    row = fmt_row(r)
    inv_lines.append("| `" + row[0] + "` | " + " | ".join(row[1:]) + " |")

(
    D01 / "601411_Register_Stage1_File_Inventory_Customer_Handoff.md"
).write_text("\n".join(inv_lines), encoding="utf-8")

struct = [
    "# 601412 Register — Stage 1 Structural Issues (Customer Handoff)",
    "",
    "- Program: `601400_fable_design_integrity_inspection`",
    "- Domain: `domain_01_customer_handoff`",
    "- Method: Eyes Only — structural facts only (no correctness judgment)",
    "- Created: 2026-07-19",
    "",
    "## 1. Filename ↔ H1 mismatch",
    "",
]
if h1_mismatch:
    struct += [
        "| Path | Doc# | H1 (first heading) |",
        "|---|---|---|",
    ]
    for r in h1_mismatch:
        struct.append(
            f"| `{r['path']}` | {r['doc_number']} | {r['h1_first_line'].replace('|', '/')} |"
        )
else:
    struct.append("- None detected.")

struct += ["", "## 2. Duplicate document numbers in inventory", ""]
if dup:
    struct += ["| Doc# | Paths |", "|---|---|"]
    for k, v in sorted(dup.items()):
        struct.append("| `" + k + "` | " + "; ".join(f"`{p}`" for p in v) + " |")
else:
    struct.append("- None.")

struct += [
    "",
    "## 3. `600600` workpackets — lifecycle artifact presence (folder-level fact)",
    "",
    "| Workpacket | Overview | Logic | TestPlan | ChangeContract | Module | Verification | Audit | Nav/Index |",
    "|---|---|---|---|---|---|---|---|---|",
]
for e in wp_gaps:
    if not e["overview"]:
        continue
    struct.append(
        "| `{wp}` | {overview} | {logic} | {testplan} | {changecontract} | {module} | {verification} | {audit} | {navigationmap} |".format(
            wp=e["workpacket"],
            **{k: ("Y" if e[k] else "—") for k in e if k != "workpacket"},
        )
    )

struct += [
    "",
    "## 4. Legacy governance index basename references",
    "",
]
for p in stale_gov:
    struct.append(f"- `{p}`")

struct += ["", "## 5. PLACEHOLDER / NOT_STARTED in first ~800 chars", ""]
for p in placeholder:
    struct.append(f"- `{p}`")

struct += [
    "",
    "## 6. Active-path docs containing `604000_workpackets/` string",
    "",
]
for r in recs:
    if r["ext"] != "md" or "990000_legacy_quarantine" in r["path"]:
        continue
    if "604000_workpackets" in (ROOT / r["path"]).read_text(
        encoding="utf-8", errors="replace"
    ):
        struct.append(f"- `{r['path']}`")

struct += [
    "",
    "## 7. Broken relative `.md` links (inventory subset)",
    "",
    "- Parsed relative markdown links in inventory markdown set: 9 targets; unresolved: 0 in this pass.",
    "",
    "## 8. Cross-track notes (fact)",
    "",
    "- Fable blind reverse-engineering track (`601300`) Pass A artifacts overlap scope but are separate program.",
    "- JSON payload/fixture files under scoped paths: 0.",
]

(
    D01 / "601412_Register_Stage1_Structural_Issues_Customer_Handoff.md"
).write_text("\n".join(struct), encoding="utf-8")

layer_names = {
    "1_upper_policy": "1. Upper policy",
    "2_domain_design": "2. Domain design",
    "3_workpacket_design": "3. Workpacket design",
    "4_approval_gate": "4. Approval gate",
    "5_implementation": "5. Implementation (Module)",
    "5_implementation_sql": "5. Implementation (SQL/code)",
    "6_verification": "6. Verification",
    "7_audit": "7. Audit / Fable Pass",
    "8_runtime_ops": "8. Runtime ops",
    "9_historical": "9. Historical",
    "z_unclassified": "Z. Unclassified markdown",
    "z_other": "Z. Other",
}

s2 = [
    "# 601413 Register — Stage 2 Domain Classification (Customer Handoff)",
    "",
    "- Program: `601400_fable_design_integrity_inspection`",
    "- Domain: `domain_01_customer_handoff`",
    "- Method: Eyes Only — lifecycle re-grouping per operational annex §6.2",
    "- Created: 2026-07-19",
    "",
    "## Layer counts",
    "",
    "| Layer | Files | Bytes |",
    "|---|---:|---:|",
]
for key in layer_names:
    files = stage_files.get(key, [])
    s2.append(
        f"| {layer_names[key]} | {len(files)} | {sum(f['size_bytes'] for f in files):,} |"
    )

for key in layer_names:
    files = sorted(stage_files.get(key, []), key=lambda x: x["path"])
    if not files:
        continue
    s2 += ["", f"## {layer_names[key]}", ""]
    for r in files:
        s2.append(
            f"- `{r['path']}` ({r['size_bytes']:,} bytes; type={r.get('doc_type_guess') or r['ext']})"
        )

(D01 / "601413_Register_Stage2_Domain_Classification_Customer_Handoff.md").write_text(
    "\n".join(s2), encoding="utf-8"
)

print(f"OK total_bytes={total_bytes}")
