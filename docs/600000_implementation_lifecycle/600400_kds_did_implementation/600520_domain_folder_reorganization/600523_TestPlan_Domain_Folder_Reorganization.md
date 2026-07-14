# 600523_TestPlan_Domain_Folder_Reorganization.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`domain_folder_reorganization`

## 0. Authority And Scope

Derived from `600521_Overview_...md`/`600522_Logic_...md` (finalized, all 3 Human decisions confirmed — NavigationMap domain split, `000005`/`000007` full backfill, `600400_Readme` rename). This is a documentation/file-organization change — no `.sql`, no runtime code, no database. "Test" here means verifying file-system state and cross-reference integrity, not executing application code.

## 1. Verification Environment

- Local filesystem/Git only — no Docker, no database.
- All checks are read-only (`ls`, `find`, `grep`, `git status`, `git diff`) unless explicitly noted as a Stage 4 post-implementation check.

## 2. Test A — Post-`git mv` File Count Per New Domain Folder

Purpose: confirm every file moved, none lost, none duplicated.

Execution:

```powershell
Get-ChildItem -Recurse "docs/600000_implementation_lifecycle/600500_payment_confirmation" -File | Measure-Object
Get-ChildItem -Recurse "docs/600000_implementation_lifecycle/600600_waiting_order_session" -File | Measure-Object
Get-ChildItem -Recurse "docs/600000_implementation_lifecycle/600700_takeout_pickup_order" -File | Measure-Object
Get-ChildItem -Recurse "docs/600000_implementation_lifecycle/600800_did_implementation" -File | Measure-Object
Get-ChildItem -Recurse "docs/600000_implementation_lifecycle/600900_cross_domain_reconciliation" -File | Measure-Object
```

Expected counts (per `600522_Logic.md` §1.2 table, plus new Readme+NavigationMap):

| Folder | Moved workpacket files | + new Readme/NavigationMap | Expected total |
|---|---|---|---|
| `600500_payment_confirmation/` | 7 (`600510/`) | 2 | 9 |
| `600600_waiting_order_session/` | 14 (`600610/`=7, `600620/`=7) | 2 | 16 |
| `600700_takeout_pickup_order/` | 14 (`600710/`=7, `600720/`=7) | 2 | 16 |
| `600800_did_implementation/` | 4 (`600820/`=4, `600810/`=0 + `.gitkeep`) | 2 | 7 |
| `600900_cross_domain_reconciliation/` | 7 (`600910/`) | 2 | 9 |

PASS condition: every folder's actual file count matches the expected total exactly.
FAIL condition: any mismatch — investigate before proceeding (a missing file is more likely than a duplicate, given `git mv` semantics, but both must be checked).

## 3. Test B — `600400_kds_did_implementation/` Post-Move State

Purpose: confirm the folder left behind contains exactly what should remain.

Execution:

```powershell
Get-ChildItem "docs/600000_implementation_lifecycle/600400_kds_did_implementation" -Directory
```

Expected: exactly 3 workpacket subfolders (`600410_...`, `600420_...`, `600440_...`) plus the flat files `600400_Readme_KDS_Implementation.md`(renamed), `600401_ChangeHistory.md`, `600402_NavigationMap.md`(reduced to 3 rows), `600403_DecisionLog.md`, `600404_PlaceTakeoutOrder_Defect_Roadmap.md`, and this workpacket's own `600520_domain_folder_reorganization/`. `600810`, `600910`, `600710`, `600610`, `600720`, `600510`, `600620`, `600820` must **not** appear here anymore.

PASS condition: exact match, no leftover moved folders.

## 4. Test C — 5 New `NavigationMap.md` + Reduced `600402` Consistency

Purpose: confirm every row from the original `600402` landed in exactly one place (no row lost, no row duplicated across old and new files).

Execution: for each of the 5 new `NavigationMap` files plus the reduced `600402`, count rows and cross-check against `600522_Logic.md` §1.1's assignment table.

| File | Expected rows |
|---|---|
| `600402_NavigationMap.md` (reduced) | 3 (`600410`, `600420`, `600440`) |
| `600502_NavigationMap_Payment_Confirmation.md` | 1 (`600510`) |
| `600602_NavigationMap_Waiting_Order_Session.md` | 2 (`600610`, `600620`) |
| `600702_NavigationMap_Takeout_Pickup_Order.md` | 2 (`600710`[newly authored, previously missing], `600720`) |
| `600802_NavigationMap_Did_Implementation.md` | **0** — `600820` deferred (Human decision, `600522_Logic.md` §1.1.1: still Stage 2, not yet Stage 6 ACCEPT, backfilled separately once it is); `600810` has no row, it's empty. File exists as an empty-shell skeleton. |
| `600902_NavigationMap_Cross_Domain_Reconciliation.md` | 1 (`600910`) |

Total rows across all 6 files: 3+1+2+2+0+1 = **9** (revised — `600522_Logic.md` §1.1.1 corrected this from an earlier "10" that mistakenly included a `600820` row that never existed in the original `600402` either), matching "8 original rows + 1 newly-authored `600710` row."

PASS condition: row counts match exactly; each `Links` column entry resolves to an actually-existing file path (spot-check at least one file per row).

## 5. Test D — `000005`/`000007` Full Backfill, 1:1 Filesystem Cross-Check

Purpose: the highest-value check in this TestPlan — confirm the 47-item backfill (`600522_Logic.md` §1.2, revised down from an earlier 51-item draft that mistakenly included `600820`) is complete and accurate, not just "looks plausible."

Execution:

```powershell
# Count actual files across 7 of the 8 moved-workpacket folders (600820 excluded, §1.1.1) + 600410
$paths = @(
  "600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity",
  "600600_waiting_order_session/600610_takeout_session_type_fix",
  "600600_waiting_order_session/600620_customer_handoff_contract_reconciliation",
  "600700_takeout_pickup_order/600710_place_takeout_order_unassigned_record_fix",
  "600700_takeout_pickup_order/600720_orders_pickup_ready_timing_columns_migration",
  "600900_cross_domain_reconciliation/600910_stale_column_reconciliation_batch",
  "600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation"
)
# 600800_did_implementation/600820_did_display_state_overload_and_legacy_defect is
# deliberately NOT in this list — its 4 files physically exist post-move (Test A/B still
# count them in the folder) but must NOT appear in 000005/000007 yet (§1.1.1).
foreach ($p in $paths) {
  $full = "docs/600000_implementation_lifecycle/$p"
  Get-ChildItem $full -File | ForEach-Object { $_.FullName }
}
```

Then, for each actual file found, `grep`/search for its exact filename in both `000005_Index_Document_Number.md` and `000007_Map_Full_Directory.md` — every single one must appear exactly once in each.

**Negative sub-check (required)**: also `grep` both index files for `600821_Overview_Did_Display_State_Overload`, `600822_Logic_...`, `600823_TestPlan_...`, `600824_ChangeContract_...` — none of these 4 filenames must appear anywhere in `000005`/`000007` yet.

PASS condition: all 47 expected files (42 moved + 5 newly-backfilled `600410` entries) appear in both index files, zero missing, zero duplicated, path strings in `000005` match the actual post-move filesystem paths exactly (case-sensitive, correct domain folder name); **and** the negative sub-check confirms zero `600820`-related entries.
FAIL condition: any file present on disk but absent from either index (silent gap, the exact failure mode `600521_Overview.md` §3.2 already found once) — any index entry pointing to a path that doesn't exist on disk (stale/wrong path) — or any `600820` file appearing in either index (scope violation of §1.1.1's deferral).

## 6. Test E — `600400_Readme` Rename And Content Correction

Purpose: confirm both the rename and the body-text corrections (`600522_Logic.md` §1.5) landed correctly.

Execution:

```powershell
Test-Path "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600400_Readme_KDS_Implementation.md"
Test-Path "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600400_Readme_KDS_DID_Implementation.md"
Select-String -Path "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600400_Readme_KDS_Implementation.md" -Pattern "DID"
```

Expected: first `Test-Path` → `True`; second → `False` (old name gone); the `Select-String` for "DID" should return **at most one match** — the single intentional cross-reference sentence pointing to `600800_did_implementation/` (`600522_Logic.md` §1.5's Purpose-paragraph After text) — not the original multi-place DID language (Purpose, In Scope, Subfolder Map all should no longer independently mention DID as in-scope).

PASS condition: exactly as above.

## 7. Test F — Bare-Name Reference Files Unchanged (Negative Test)

Purpose: confirm the 8 files identified in `600521_Overview.md` §3.3/`600522_Logic.md` §1.4 as needing **no** text changes were in fact **not** touched — this is a boundary-compliance check, not a functional one.

Execution:

```powershell
git diff --stat -- `
  "docs/000053_Matrix_Domain_To_Artifact_Traceability.md" `
  "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600417_Audit.md" `
  "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600441_Overview.md" `
  "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600442_Logic.md" `
  "docs/600000_implementation_lifecycle/600400_kds_did_implementation/600404_PlaceTakeoutOrder_Defect_Roadmap.md"
```

(Post-move, the remaining 4 — `600514_ChangeContract.md`, `600621_Overview.md`, `600625_Module.md`, `600821_Overview_...md` — will have moved to their new domain folders; re-run the equivalent `git diff --stat` against their new paths.)

PASS condition: zero diff on all 8 — confirms these files were correctly left untouched, matching `600522_Logic.md` §1.4's conclusion that bare-name prose references remain accurate after a folder move and need no edit.
FAIL condition: any diff on these 8 files would mean scope crept beyond what was approved (`600524_ChangeContract.md` §2 forbids editing them).

## 8. Static Boundary Verification

```powershell
git status --short
```

Expected changes, and only these: 8 `renamed:` folder entries (with their contents), 1 `renamed:` file (`600400_Readme`), up to 10 new files (5 Readme + 5 NavigationMap) under `??` or `A` status, 3 modified files (`600402_NavigationMap.md`, `000005_Index_Document_Number.md`, `000007_Map_Full_Directory.md`), 1 modified file (`600400_Readme_KDS_Implementation.md`, for the body-text correction — note this shows as the renamed file's own diff, not a separate entry). No `.sql` file. No file outside `docs/`.

## 9. Acceptance Criteria

1. Test A — all 5 new domain folders have the exact expected file count.
2. Test B — `600400_kds_did_implementation/` contains only the 3 KDS workpackets + expected flat files.
3. Test C — all 6 `NavigationMap` files (1 reduced + 5 new, including the intentionally-empty `600802`) together account for exactly 9 rows, matching the assignment table.
4. Test D — `000005`/`000007` 1:1 match against actual filesystem for all 47 backfilled items, zero gaps, zero stale paths, and zero `600820`-related entries (deferred per §1.1.1).
5. Test E — `600400_Readme` renamed and DID language corrected to a single intentional cross-reference.
6. Test F — the 8 bare-name-reference files show zero diff (boundary respected).
7. Static boundary (§8) — no unexpected file touched, no `.sql` file touched.
