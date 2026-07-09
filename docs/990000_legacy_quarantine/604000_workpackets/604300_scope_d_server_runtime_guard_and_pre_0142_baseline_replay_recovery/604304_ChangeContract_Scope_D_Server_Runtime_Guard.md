# 604304_ChangeContract_Scope_D_Server_Runtime_Guard.md

Change ID: SCOPE_D_MASTER
Status: Draft
Lifecycle: ChangeContract (Stage 2, master level)
Gate Classification: Scope D Master Change Contract — Non-Implementation
Runtime Implementation Authorization: **Not Granted — this contract cannot grant it**
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No Scope D implementation slice may proceed while Owner remains TBD.

---

## 0. Purpose And Scope Of This Contract

This is the **master** change contract for the Scope D Server Runtime Guard workpacket (`604300`). Its only job is to:

1. Lock in that `604301` (Overview) and `604302` (Logic) are design drafts, not implementation authorization.
2. Define, at the **name-and-boundary level only**, the eight planned sub-workpackets `604310`–`604380`.
3. Explicitly forbid any SQL, migration, Edge Function, Flutter, Python tooling, or config implementation under this contract.
4. State that each of `604310`–`604380` requires its **own separate** `impact_scope.md`, `change_contract.md`, and Human Approval (Stage 3) record before Codex may touch any runtime file.

This contract does **not** approve implementation of any kind. A human approving this document approves only the creation of `604303`/`604304` themselves and the boundary definitions in Section 4 — nothing else.

### 0-bis. Schema Drift Precondition (Policy Update, 2026-07-01)

```text
604310 implementation is blocked until Schema Drift Alignment verification/closure
  is complete (604301 §7.6, 604303 §5.1). This is in addition to, not a replacement
  for, the eight Required Human Decisions already recorded in 604315 §5.
604316 Human Approval for 604310 remains deferred until both:
  (a) Schema Drift Alignment closes, and
  (b) every Required Human Decision in 604315 §5 is resolved and Owner is assigned.
0014_create_payment_ledger.sql, 0098_create_payment_confirm_pipeline_rpc.sql, and
  0027_create_payment_intent_rpc.sql are historical migration files — direct
  in-place edit of any of them is forbidden under this contract and under every
  Scope D sub-workpacket's own future contract.
0098 confirm_payment is the only current target for 604310.
0027 confirm_payment_from_provider, provider webhook callback redesign, Edge
  Function webhook integration, provider-specific callback routing, and full
  provider pipeline consolidation are explicitly out of scope for 604310.
```

---

## 1. Allowed Files

```text
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604303_TestPlan_Scope_D_Server_Runtime_Guard.md
docs/600000_implementation_lifecycle/604000_workpackets/604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/604304_ChangeContract_Scope_D_Server_Runtime_Guard.md
```

**Precise scope statement:** this contract's Allowed Files are exactly the two documents above — nothing else. Separately, it also permits creating up to eight **empty directories** (not files) named per Section 4, purely as folder scaffolding for future sub-workpacket documents. An empty directory has no runtime content and is not itself a "file" under this contract; no file of any kind (including `impact_scope.md`) may be placed inside those directories yet.

No other file may be created or modified under this contract.

---

## 2. Forbidden Files

```text
sql/migrations/**                          (including any new patch file, at any future number)
supabase/**                                (Edge Functions, config, or any other path)
catchmenu_app/**/*.dart
**/*.py                                    (any Python tooling anywhere in the repo)
**/*.json, **/*.yaml, **/*.yml, **/*.toml   (any config/seed file)
Any existing migration file (0098, 0014, 0119, 0136_create_dev_audit_log.sql, 0137, 0138, 0139, etc.) — read-only reference, no edits
```

This list is intentionally broad. If a future need arises to touch any of these paths, it must go through a sub-workpacket's own `change_contract.md` and Human Approval — never through this master contract.

---

## 3. Allowed Operations

```text
- Write 604303_TestPlan_Scope_D_Server_Runtime_Guard.md (test obligation mapping only).
- Write 604304_ChangeContract_Scope_D_Server_Runtime_Guard.md (this file).
- Create empty sub-workpacket folders named exactly as listed in Section 4, with no file content beyond a future impact_scope.md placeholder.
```

## Forbidden Operations

Default forbidden (per `600179` Core Rule), plus Scope-D-specific:

```text
- Any SQL DDL/DML, migration file creation or edit.
- Any Edge Function source file creation (supabase/functions/**).
- Any Flutter source or test file creation or edit (catchmenu_app/lib/**).
- Any Python tooling file creation or edit.
- Any config or seed file creation or edit (edge_function_configs, message_catalog, etc.).
- REVOKE/GRANT statements of any kind (even as a documented "example" inside a file this contract allows — 604302's GRANT/REVOKE text remains prose, not executable SQL).
- Approving, on behalf of a sub-workpacket, its own change_contract or Human Approval — this master contract cannot substitute for a slice-level approval.
- Resolving `Owner: TBD` — owner assignment is a human/project decision outside this contract's scope.
- Broad refactor, new architecture layer, new generic helper framework, unrequested renaming, formatting-only diff, encoding normalization, Korean Markdown rewrite of unrelated files.
```

## Operation Granularity Rule

```text
Bad:
  Allowed Operations: Prepare Scope D for implementation.

Good:
  Allowed Operations:
  - Write 604303_TestPlan_Scope_D_Server_Runtime_Guard.md.
  - Write 604304_ChangeContract_Scope_D_Server_Runtime_Guard.md.
  - Create 8 empty sub-workpacket folder names (Section 4), no content inside beyond a future placeholder.
```

---

## 4. Sub-Workpacket Boundary Definition (Names And Scope Only — No Implementation Authorized)

The following defines **name and non-overlapping boundary only**. None of these are approved for implementation by this contract. Each row requires its own future `impact_scope.md`, `logic.md` (or shared reference to `604302`), `test_plan.md` (scoped from `604303` §2), `change_contract.md`, and Human Approval before any Codex work begins.

**Read this table as reference only — every cell below is non-binding until that specific slice has its own approved `change_contract.md` and Human Approval.** Do not treat any "may eventually touch" cell as a green light to edit that file now.

| # | Sub-workpacket (folder name) | Boundary (what it may eventually touch — not yet approved) | Boundary (what it must NOT touch) |
| --- | --- | --- | --- |
| 1 | `604400_scope_d_01_payment_confirm_idempotency` | `confirm_payment` (`0098`) function body only; idempotency detection order per 604302 §2, §2.7–§2.10. **Target is `0098` `confirm_payment` only.** **Blocked** until Schema Drift Alignment precondition closes (§0-bis below) | `release_kds_after_payment` body; RLS/GRANT statements; Edge Function files; **`0027_create_payment_intent_rpc.sql` (`confirm_payment_from_provider`) — explicitly excluded, recorded only as a future split-brain consolidation concern** |
| 2 | `604320_scope_d_02_kds_release_guard` | `release_kds_after_payment` function body only; HOLD-only transition per 604302 §3 | `confirm_payment` body; GRANT/REVOKE (owned by 604350); Edge Function files |
| 3 | `604330_scope_d_03_payment_to_kds_transaction_boundary` | The call-site coupling between `confirm_payment` and `release_kds_after_payment` (transaction boundary, partial-failure handling per 604302 §4) — must not re-implement either function's internal logic already owned by 604310/604320 | Idempotency detection logic (604310); HOLD-only guard logic (604320); GRANT/REVOKE |
| 4 | `604340_scope_d_04_ledger_evidence_correlation` | New/updated ledger and audit event emission, correlation_id propagation per 604302 §5 | Payment/release business logic itself; RLS/GRANT |
| 5 | `604350_scope_d_05_rls_security_dry_run` | `REVOKE`/`GRANT` statements on `release_kds_after_payment`; RLS dry-run tests per 604302 §6 | Function body logic of `confirm_payment`/`release_kds_after_payment` |
| 6 | `604360_scope_d_06_edge_function_toss_confirm_boundary` | New Edge Function source (`toss-payments-confirm`, `toss-payments-webhook`) per 604302 §7 | Any SQL/migration file; Flutter source |
| 7 | `604370_scope_d_07_integration_test_and_unknown_state` | Integration/unknown-state test authoring per 900103 and 604302 §8–§9 | Production function bodies (test-only slice) |
| 8 | `604380_scope_d_08_scope_d_closeout_audit` | Closeout checklist execution (grep/GRANT/ledger verification), Scope C/A unlock decision | Any new implementation — audit/closeout only |

**Overlap risk carried forward from `604301` §6.1:** `604330` shares function boundaries with `604310` and `604320`. Each of the three slices' own `impact_scope.md` must declare an explicit, non-overlapping allow/deny file and function list before any of the three receives Human Approval. If two slices claim the same function body, Stage 3 Human Approval must resolve the conflict before either proceeds.

**Mandatory statement (per governing instruction for this document):**

```text
604310 through 604380 are NAMES AND BOUNDARIES ONLY at this stage.
No SQL, migration, Edge Function, Flutter, Python, or config implementation
is authorized for any of them by this master change_contract.

Each of 604310–604380 individually requires, before Codex may touch any
runtime file for that slice:
  1. Its own impact_scope.md (Cursor, Stage 1)
  2. Its own change_contract.md (Claude-drafted, Stage 2)
  3. Its own Human Approval record (implementation_approval.md or the
     Human Boundary Approval section of its own change_contract.md, Stage 3)

A slice's change_contract.md may reference 604302 for shared logic context,
but the Allowed Files / Allowed Operations / Human Boundary Approval sections
must be authored and approved per slice, not inherited from this document.
```

---

## 5. Required Business Rules

Reference only — not re-approved here, already established in `604301`/`604302`:

```text
Server owns payment truth and KDS release authority (604301 §2).
INV-001 through INV-006 (604301 §3) must be enforced server-side.
Scope D must close before Scope C/A/B/E may treat payment/KDS state as final (604301 §1).
```

## 6. Required State Rules

Reference only — see `604302` §8 (Unknown-State Handling): `PENDING`, `UNKNOWN`, `APPROVED`, `FAILED`, `reconciliation_required` must remain distinct; no collapsing UNKNOWN into SUCCESS or FAILED without evidence.

## 7. Required Idempotency Rules

Reference only — see `604302` §2 (confirm) and §3 (release). Binding idempotency rules are authored per-slice in `604310`/`604320`'s own `change_contract.md`.

## 8. Required Audit Rules

Reference only — see `604302` §5 and `900103` §8. New event types (`PAYMENT_DUPLICATE_IGNORED`, etc.) are not authorized to be introduced by this contract; that happens only in `604340`'s own approved contract.

## 9. Required Tests

See `604303_TestPlan_Scope_D_Server_Runtime_Guard.md` in full. No test file creation is authorized here.

## 10. Required Verification Commands

Since this contract authorizes documentation only, verification is limited to confirming no runtime file was touched:

```bash
git diff --check
git diff --name-only
# Expected: only 604303_*.md and 604304_*.md (and, if created, empty sub-workpacket
# folder placeholders with no file content) appear in the diff.
```

If `git diff --name-only` shows any `.sql`, `.ts`, `.dart`, `.py`, `.json`, `.yaml`, or `.yml` file, this contract has been violated.

## 11. Rollback Requirements

```text
Rollback is trivial: revert or delete 604303_*.md / 604304_*.md.
No runtime state, migration, or deployed code is affected by this contract,
because none is authorized to be created under it.
```

## 12. Expected Final Deliverables

```text
604303_TestPlan_Scope_D_Server_Runtime_Guard.md
604304_ChangeContract_Scope_D_Server_Runtime_Guard.md (this file)
Optionally: 8 empty, name-only sub-workpacket folders per Section 4 (no file content)
```

## 13. Human Boundary Approval

```text
Approved for documentation authoring only — NOT for Scope D implementation.

Allowed files:
- 604303_TestPlan_Scope_D_Server_Runtime_Guard.md
- 604304_ChangeContract_Scope_D_Server_Runtime_Guard.md

Allowed Operations:
- Write the two files above.
- Create empty, name-only sub-workpacket folders per Section 4.

Forbidden:
- All SQL, migration, Edge Function, Flutter, Python, and config files.
- Any implementation for 604310–604380.
- Resolving Owner: TBD (must be assigned by the human/project owner, not by this contract).

This approval does NOT authorize any Scope D implementation. Each of
604310–604380 requires its own separate impact_scope.md, change_contract.md,
and Human Approval record before Codex may touch any runtime file.

Approver:
Timestamp:
Approval Notes:
```

---

## 14. Source References

| Category | Path |
| --- | --- |
| Overview | `604301_Overview_Scope_D_Server_Runtime_Guard.md` |
| Logic | `604302_Logic_Scope_D_Server_Runtime_Guard.md` |
| Test plan | `604303_TestPlan_Scope_D_Server_Runtime_Guard.md` |
| 900102 Change Contract (source) | `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` |
| 900103 Test Plan (source) | `docs/900000_patent_and_handoff_package/900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` |
| Pipeline governance | `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` |

---

## 15. Final Rule

```text
This contract's only authority is over its own two documents.
It cannot pre-approve, bundle-approve, or fast-track any of 604310–604380.
Every sub-workpacket earns its own implementation approval, one slice at a time.
```
