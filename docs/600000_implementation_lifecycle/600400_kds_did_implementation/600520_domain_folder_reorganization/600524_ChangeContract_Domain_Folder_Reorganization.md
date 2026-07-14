# 600524_ChangeContract_Domain_Folder_Reorganization.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-14

## §0 Authority

Based on `600521_Overview_...md`, `600522_Logic_...md` (finalized — all 3 Human decisions confirmed, 2026-07-14, not re-litigated here), `600523_TestPlan_...md`.

The accepted design is not reopened here:

- 8 workpacket folders (+ `600330`, empty) move from `600400_kds_did_implementation/` into 5 new domain folders (`600500`/`600600`/`600700`/`600800`/`600900`), workpacket numbers unchanged.
- `600402_NavigationMap.md` splits: reduced to 3 rows (`600410`/`600420`/`600440`), 5 new domain `NavigationMap.md` files created, including a newly-authored `600450` row that never previously existed.
- `000005_Index_Document_Number.md`/`000007_Map_Full_Directory.md` fully backfilled — 47 file-level entries (`600510` explicitly excluded, `600522_Logic.md` §1.1.1).
- `600400_Readme_KDS_DID_Implementation.md` renamed to `600400_Readme_KDS_Implementation.md`, body corrected to remove now-inaccurate DID scope language.

## §1 Allowed Files And Operations

| Operation | Scope |
|---|---|
| `git mv` (folder) ×8 | `600330`, `600430`, `600450`, `600460`, `600470`, `600480`, `600490`, `600510` — each moved intact (no file inside renamed or edited during the move itself) to its assigned new domain folder per `600522_Logic.md` §1.1's table. |
| `git mv` (file) ×1 | `600400_Readme_KDS_DID_Implementation.md` → `600400_Readme_KDS_Implementation.md`. |
| `Write` (new file) ×5 | New Readme, one per new domain folder: `600500_Readme_Payment_Confirmation.md`, `600600_Readme_Waiting_Order_Session.md`, `600700_Readme_Takeout_Pickup_Order.md`, `600800_Readme_Did_Implementation.md`, `600900_Readme_Cross_Domain_Reconciliation.md`. |
| `Write` (new file) ×5 | New NavigationMap, one per new domain folder: `600502_NavigationMap_Payment_Confirmation.md`, `600602_NavigationMap_Waiting_Order_Session.md`, `600702_NavigationMap_Takeout_Pickup_Order.md`, `600802_NavigationMap_Did_Implementation.md`, `600902_NavigationMap_Cross_Domain_Reconciliation.md`. Row content per `600522_Logic.md` §1.1, including the newly-authored `600450` row in `600702`. **`600802_NavigationMap_Did_Implementation.md` is created with 0 rows** (empty-shell skeleton only) — `600510`'s row is explicitly deferred until that workpacket reaches Stage 6 ACCEPT (`600522_Logic.md` §1.1.1); do not add a `600510` row now. |
| `Edit` | `600402_NavigationMap.md` — remove the 5 rows that moved (`600430`/`600460`/`600470`/`600480`/`600490`), leaving exactly 3 (`600410`/`600420`/`600440`). No other content in this file may change. |
| `Edit` | `000005_Index_Document_Number.md` — add the 47 backfilled entries per `600522_Logic.md` §1.2 (**not** 51 — `600510`'s 4 files are explicitly excluded, §1.1.1). No existing entry unrelated to this backfill may be altered or removed. |
| `Edit` | `000007_Map_Full_Directory.md` — add the equivalent 47 entries as tree nodes per `600522_Logic.md` §1.3. Same non-alteration constraint, same `600510` exclusion. |
| `Edit` | `600400_Readme_KDS_Implementation.md`(post-rename) — exactly the 4 Before/After corrections in `600522_Logic.md` §1.5 (Purpose paragraph, In Scope line, Out of Scope line, Subfolder Map table). No other content in this file may change. |

## §2 Forbidden Files And Operations

| Forbidden item | Reason |
|---|---|
| `000053_Matrix_Domain_To_Artifact_Traceability.md` | Bare-name references only — confirmed no edit needed (`600522_Logic.md` §1.4). |
| `600417_Audit.md`, `600441_Overview.md`, `600442_Logic.md` | Same — bare-name references, `600410`/`600440` content, no edit needed. |
| `600404_PlaceTakeoutOrder_Defect_Roadmap.md` | Bare-name references only, stays physically in `600400` (not in the move list) — no edit needed for this workpacket. |
| `600484_ChangeContract.md`, `600491_Overview.md`, `600495_Module.md`, `600511_Overview_...md` (post-move, at their new paths) | Bare-name references only — no edit needed. |
| Any workpacket's own `Overview`/`Logic`/`TestPlan`/`ChangeContract`/`Module`/`Verification`/`Audit` file content (the 46 moved files themselves) | This is a pure `git mv` — file **content** is never opened or edited, only its path changes. |
| Workpacket numbers (`600430`, `600450`, `600460`, `600470`, `600480`, `600490`, `600510`, `600330`) | Explicitly confirmed unchanged — only the parent domain folder moves. |
| Any `600501`/`600503`/`600601`/`600603`/etc. (`ChangeHistory`/`DecisionLog` for new domain folders) | Not decided — only Readme + NavigationMap were approved per Human decision (a). Creating additional per-domain files is out of scope. |
| Any other file under `docs/` not explicitly listed in §1 | Out of scope. |
| Any `sql/migrations/*.sql` file | Out of scope — this is a pure documentation/file-organization change. |
| Flutter/runtime code, tools scripts | Out of scope. |

Implementation must not:

- Edit the content of any file inside a moved folder as part of the `git mv` (rename/move only — if a moved file's content needs correcting later, that is a separate, future change).
- Invent new `NavigationMap`/`Readme` row content beyond what `600522_Logic.md` §1.1 specifies — in particular, the newly-authored `600450` row must be sourced from `600455_Module.md`/`600456_Verification.md`/`600457_Audit.md`'s actual recorded facts, not invented.
- Rename any of the 42 moved-and-indexed files themselves (their titles remain in the pre-`000002`-clarification, title-less form per that clarification's "not retroactively renamed" rule).
- **Add a `600510` row to `600802_NavigationMap_Did_Implementation.md`, or a `600510`-related entry to `000005`/`000007`, under any circumstance in this contract** — `600510` is still Stage 2 (Human Approval pending, not yet implemented), and indexing it now would misrepresent an unfinished workpacket as complete (`600522_Logic.md` §1.1.1). This applies even though `600510`'s 4 files physically move to `600800_did_implementation/` as part of the approved `git mv`.

## §3 Required Behavior Preservation

- Every moved file's content is byte-identical before and after `git mv` (Git tracks renames; content must not change).
- `600402_NavigationMap.md`'s 3 remaining rows (`600410`/`600420`/`600440`) keep their exact existing content — only the 5 other rows are removed, nothing about the kept rows changes.
- `000005`/`000007`'s existing entries (everything outside this backfill's 51 new items) remain untouched.

## §4 Required New Behavior

- 5 new domain folders exist, each with exactly 1 Readme + 1 NavigationMap + its moved workpacket(s).
- `600402_NavigationMap.md` contains exactly 3 rows.
- `000005`/`000007` contain all 51 backfilled entries, verifiable 1:1 against the filesystem.
- `600400_Readme_KDS_Implementation.md` exists (renamed), old name gone, DID language corrected to a single intentional cross-reference.

## §5 Verification Requirements

Per `600523_TestPlan_...md` Test A-F, all must PASS before this ChangeContract's implementation is considered complete.

## §6 Open Items Not Approved In This Contract

### §6.1 Per-Domain `ChangeHistory`/`DecisionLog`

Only Readme + NavigationMap were approved for the 5 new domain folders (Human decision (a)). Whether each domain also needs its own `ChangeHistory.md`/`DecisionLog.md` (mirroring `600400`'s full flat-file set) is not decided.

### §6.2 `600404_PlaceTakeoutOrder_Defect_Roadmap.md`'s Domain Fit

This file stays physically in `600400_kds_did_implementation/` (not in the move list) but its content (`place_takeout_order()` defects) now spans multiple post-split domains (`600700` Takeout, `600500` Payment via `point_ledger`/`discount_pct`, `600400` KDS via `order_items`/`kds_tickets`). Whether it should itself move, split, or stay as a cross-domain exception is not decided.

### §6.3 Bare-Name References Losing Navigational Precision

`600522_Logic.md` §1.4 confirmed bare-name references remain textually accurate after the move but lose "where to find it" precision. Whether a future pass should add explicit path annotations to these is not decided — out of scope for this ChangeContract.

### §6.4 `600510` Deferred Backfill (New, Human Decision 2026-07-14)

`600510_did_display_state_overload_and_legacy_defect`'s `NavigationMap` row and `000005`/`000007` index entries are explicitly deferred until that workpacket reaches Stage 6 ACCEPT (`600522_Logic.md` §1.1.1/§4(e)). This contract approves only the physical `git mv` of `600510`'s 4 files to `600800_did_implementation/` — it does not approve indexing them. A separate, future workpacket (not this one) will add the deferred entries once `600510` completes.

## §7 Risk

Risk level: LOW.

Reasons:

- Pure documentation/file-organization change — no runtime code, no database, no `.sql`.
- `git mv` preserves file history and content; the operation itself is low-risk and easily auditable via `git status`/`git log --follow`.
- The one area of real risk (silently losing or duplicating a file-level index entry during the 51-item backfill) is directly addressed by Test D's 1:1 filesystem cross-check.

Risk controls:

- 4-stage sequencing (§2 of `600522_Logic.md`) with a verification checkpoint after each stage.
- Explicit rollback plan per stage (`600522_Logic.md` §3).
- Negative test (Test F) confirming the 8 files that should NOT change were in fact not touched.

## §8 Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve the 8 git mv folder operations plus the 600400_Readme rename, exactly as specified in §1 and 600521_Overview.md §4/600522_Logic.md §1.5.
☑ I approve creating 5 new Readme + 5 new NavigationMap files (10 total), with row content sourced exactly as specified in 600522_Logic.md §1.1, including the newly-authored 600450 row (and 600802 with 0 rows, 600510 deferred).
☑ I approve the 000005/000007 full backfill (47 entries) and the 600402/600400_Readme content edits, exactly as specified in §1.
☑ I acknowledge that §6.1/§6.2/§6.3/§6.4 remain open and are not authorized by this contract.

## §9 Stage 4 Instruction If Approved

If all four Human approval boxes in §8 are checked, Stage 4 may proceed to implement exactly this contract, following the 4-stage sequence in `600522_Logic.md` §2.1.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.
