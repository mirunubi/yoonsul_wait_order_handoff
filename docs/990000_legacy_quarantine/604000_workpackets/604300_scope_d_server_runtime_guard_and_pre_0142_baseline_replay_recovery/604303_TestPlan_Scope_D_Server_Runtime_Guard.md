# 604303_TestPlan_Scope_D_Server_Runtime_Guard.md

Change ID: SCOPE_D_MASTER
Status: Draft
Lifecycle: TestPlan (Stage 2, master level)
Gate Classification: Scope D Master Test Plan Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No Scope D implementation slice may proceed while Owner remains TBD.

---

## 0. Purpose

This is the **master** test plan for Scope D Server Runtime Guard. It maps the test obligations already defined in `900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` and `604302_Logic_Scope_D_Server_Runtime_Guard.md` §9 onto the eight planned sub-workpackets (`604310`–`604380`).

This document does **not** authorize writing any test file, SQL test migration, Edge Function test, Flutter test, or Python tooling. It exists so that:

1. Each sub-workpacket's own `test_plan.md` can be scoped from a single, non-duplicated source instead of re-deriving requirements from `900103` independently.
2. Human Approval (Stage 3) for each sub-workpacket can verify its narrow test scope against the master obligation list here.

Per `604301`/`604302`, actual test authoring, SQL/migration/Edge/Flutter/Python file creation, and Codex implementation remain **forbidden** until each sub-workpacket has its own approved `impact_scope.md`, `change_contract.md`, and Human Approval record.

Companion documents: `604301_Overview_Scope_D_Server_Runtime_Guard.md`, `604302_Logic_Scope_D_Server_Runtime_Guard.md`, `604304_ChangeContract_Scope_D_Server_Runtime_Guard.md`.

---

## 1. Test Case Source Mapping

| Source | Relevant IDs | Role |
| --- | --- | --- |
| `900103` §4 Normal Path | TC-006, TC-007, TC-008 | Payment approval → KDS COMMITTED → kitchen flow → ledger evidence chain |
| `900103` §5 Failure/Edge | TC-101, TC-102, TC-103, TC-109, TC-110 | Payment failure, duplicate confirm, client-forbidden release, HOLD-ticket-start block, partial payment |
| `900103` §7 Security/Permission | SEC-002, SEC-003, SEC-006 | Client direct KDS release, staff release without payment, payment-approved flag forgery |
| `900103` §8 Audit Evidence | (unnamed, event field contract) | Evidence field contract, event ordering, no `KDS_RELEASED_AFTER_PAYMENT` without `PAYMENT_APPROVED` |
| `900103` §11 Phase 1 (Scope D) 통과 기준 | TC-001–TC-008, TC-101–TC-103, TC-109 | Scope D closeout checklist Claude/Human must confirm |
| `604302` §9 Required Tests | 12-row table | Scope D specific idempotency/duplicate/rollback/correlation tests not itemized in 900103 |

This master plan does not restate every `900103` test case body — it only maps which sub-workpacket owns which case. Each sub-workpacket's own `test_plan.md` must quote the relevant `900103` TC/SEC bodies it targets.

---

## 2. Sub-Workpacket Test Ownership Map

| Sub-workpacket | Owns (from 900103 / 604302 §9) | Focus |
| --- | --- | --- |
| `604400_scope_d_01_payment_confirm_idempotency` | TC-102, TC-110, 604302 §9 rows: duplicate confirm, already approved payment | `confirm_payment` same-result idempotency; `p_approved_amount` verification |
| `604320_scope_d_02_kds_release_guard` | TC-101, TC-109, 604302 §9 rows: pending/unknown no release, release already committed | `release_kds_after_payment` HOLD-only, idempotent COMMITTED |
| `604330_scope_d_03_payment_to_kds_transaction_boundary` | TC-006, 604302 §9 rows: rollback/retry, payment approved but release retry | confirm→release coupling, partial failure / split-brain |
| `604340_scope_d_04_ledger_evidence_correlation` | TC-008, 900103 §8 Audit Evidence, 604302 §9 rows: ledger event exists, correlation_id exists | INV-006 event contract, correlation_id propagation |
| `604350_scope_d_05_rls_security_dry_run` | TC-103, SEC-002, SEC-003, SEC-006 | REVOKE `authenticated` from `release_kds_after_payment`; dry-run block test |
| `604360_scope_d_06_edge_function_toss_confirm_boundary` | 900103 §13 grep commands (`supabase/functions/` expectation), 604302 §7 | Toss verify → confirm; webhook dedupe |
| `604370_scope_d_07_integration_test_and_unknown_state` | TC-101, TC-102, TC-110 (integration-level re-verification only — see note below), remaining 604302 §9 rows not claimed above | Full invariant/duplicate/unknown-state integration pass |
| `604380_scope_d_08_scope_d_closeout_audit` | 900103 §11 Phase 1 checklist, §12 Claude 감리 제출 항목, §13 verification commands | Full Scope D gate — grep/GRANT/ledger checklist, Scope C/A unlock decision |

**Ownership is provisional.** Each sub-workpacket's own `test_plan.md`, written after its own `impact_scope.md`, is the binding scope — this table only prevents two slices from silently claiming the same test case with no owner.

**Single-owner rule for §2:** each TC/SEC ID has exactly one **primary** owning slice in this table (the slice that must implement the guarantee). Where `604370` also lists a TC ID already owned elsewhere (TC-101, TC-102, TC-110), that is **integration-level re-verification** of a guarantee built by the primary owner — not a second, competing implementation owner. `604370` does not re-implement `confirm_payment` or `release_kds_after_payment` logic.

---

## 3. Required Unit Tests

| Area | Requirement | Owning slice |
| --- | --- | --- |
| `confirm_payment` branch coverage | Approved-lookup, provider_tx_id-lookup, pending/processing-lookup, insert-path | 604310 |
| `confirm_payment` amount verification (TC-110, 900103) — **hard block (policy update 2026-07-01)** | Amount mismatch is a hard payment integrity failure, not warning-only: it must block APPROVED ledger insert, block the `payment_confirmed` event, and block KDS release, triggering `cancel_required`/`reconciliation_required` evidence where applicable. Default MVP tolerance = 0 KRW; provider-specific tolerance is not introduced without separate approval. This is a validation-gate concern, not a transaction-boundary/split-brain concern | 604310 |
| `release_kds_after_payment` branch coverage | Precondition check, HOLD-only UPDATE, no-op-when-already-COMMITTED | 604320 |

No unit test file is authorized to be written under this master plan. Slice `test_plan.md` documents name the exact test file paths.

---

## 4. Required Integration Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| TC-006 (900103) | `confirm_payment` APPROVED → `release_kds_after_payment` auto-invoked → `kds_status: HOLD → COMMITTED` | 604330 |
| TC-007 (900103) | COMMITTED → COOKING → READY → SERVED kitchen flow unaffected by Scope D changes | 604370 |
| TC-008 (900103) | Full evidence chain present through `ORDER_COMPLETED` | 604340 |

---

## 5. Required SQL / Migration Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| New patch migration dry-run | `supabase db push --dry-run` (or project equivalent) passes with **no edits to existing migration files**, per 604302 §10 prohibited behavior | 604310, 604320, 604350 (each new patch file tested independently) |
| `release_kds_after_payment` GRANT check | Post-patch, `authenticated` must **not** appear in `EXECUTE` grantees | 604350 |

This master plan does not authorize creating any migration file. That happens only inside an approved slice.

**Filename/number is stale — verified against repo:** `900102` names the planned patch `supabase/migrations/0136_patch_release_kds_idempotency.sql`, but this repo has no `supabase/` directory (migrations live under `sql/migrations/`) and `0136` is already used by `0136_create_dev_audit_log.sql`; `0137`, `0138` (×2), and `0139` are also already taken (checked 2026-07-01). Whichever slice creates the patch (604310, 604320, and/or 604350) must pick the next free number (`0140` or higher at the time of implementation, re-checked then) under `sql/migrations/`, not `0136` under `supabase/migrations/`. This is a naming correction only — it does not change the patch's required content.

### 5.1 Schema Drift Precondition Tests (Policy Update, 2026-07-01)

Required **before** any `604310` implementation, per the schema-drift-alignment precondition (`604300_Index`, `604301` §7.6):

| Case | Expectation | Owning slice / precondition |
| --- | --- | --- |
| `intent_id` binding | `payment_ledger.intent_id` is `NOT NULL` (`0014` L160) — confirm whether `confirm_payment`'s eventual patch must populate it, whether a default/backfill exists, or whether the column needs reconciliation before any patch touches the `INSERT` | Schema Drift Alignment precondition, not 604310 alone |
| `provider_payment_key` vs `provider_tx_id` naming alignment | `0014`'s DDL column is `provider_payment_key` (L174); `0098`'s `INSERT` uses `provider_tx_id` (not a DDL column name) — confirm which name is authoritative before any patch migration is written | Schema Drift Alignment precondition |
| Undefined `fee_amount` reference risk | Confirm `fee_amount`/`net_amount` computed in `0098` (L292–303) map cleanly onto whatever columns a reconciled schema defines; do not assume the current compute block is safe against a schema fix | Schema Drift Alignment precondition |
| `confirm_payment` compile / dry-run verification | A dry-run or equivalent static check that `confirm_payment` as currently defined actually executes against the current live schema (not just parses) — needed to know whether the drift is theoretical or already causing failures | Schema Drift Alignment precondition |

This master plan does not authorize running any of these checks against a live database; it records that they are required before `604310`'s own test suite can be trusted.

---

## 6. Required RLS Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| SEC-002 (900103) | Customer role direct KDS release attempt → rejected | 604350 |
| SEC-003 (900103) | Staff role release without payment approval → rejected | 604350 |
| SEC-006 (900103) | Client app forges a "payment-approved" flag (e.g. direct table write instead of going through `confirm_payment`) → rejected; RLS prevents direct client `UPDATE` of `payment_ledger`/`kds_tickets` to a committed/approved state | 604350, 604310 (confirm_payment remains sole write path) |
| Tenant/store boundary | `p_tenant_id`/`p_store_id` mismatch on `confirm_payment`/`release_kds_after_payment` → rejected, per 604302 §6.3 | 604350, 604370 |

---

## 7. Required Provider Mock Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| Toss verify success | Edge → `confirm_payment` → APPROVED | 604360 |
| Toss verify failure | FAILED ledger row, no release | 604360 |
| Toss verify timeout | UNKNOWN / `reconciliation_required`, no APPROVED | 604360, 604370 |
| Duplicate webhook (same `provider_tx_id`) | Idempotent confirm path, no second APPROVED | 604360 |

No Edge Function source file (`supabase/functions/toss-payments-confirm/index.ts`, `supabase/functions/toss-payments-webhook/index.ts`) exists in the repo today (verified — `supabase/` directory absent) and none is authorized to be created by this test plan.

---

## 8. Required Idempotency Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| TC-102 (900103) | Duplicate confirm callback/webhook → one APPROVED, one release, duplicate logged as audit event | 604310 |
| 604302 §9 "already approved payment" | Second `confirm_payment` call on an APPROVED order returns **same success payload**, not `payment_already_confirmed` error (current `0098` behavior — verified error path exists at lines ~221–227 and ~258–260) | 604310 |
| 604302 §9 "release already committed" | Second `release_kds_after_payment` call is a no-op, logged INFO | 604320 |

### 8.1 Effective Idempotency Key / Request Fingerprint Tests (Policy Update, 2026-07-01)

Per `604302` §2.7–§2.10:

| Case | Expectation | Owning slice |
| --- | --- | --- |
| `effective_idempotency_key` resolution | For each key-source priority tier (internal `payment_intent_id`, provider payment key, provider request row, VAN TID + approval number, adapter-derived key, server-derived transitional key), a deterministic, namespaced, tenant/store-scoped, non-null key is resolved | 604310 |
| `request_fingerprint` excludes amount from the key itself | `effective_idempotency_key` does not vary with amount; `request_fingerprint` is a separate comparison surface that does include amount | 604310 |
| Same key + same fingerprint | Same-success replay (see §13 duplicate confirm row) | 604310 |
| Same key + different fingerprint | Hard conflict (not a silent replay, not a silent overwrite) | 604310 |
| Same key + different amount | Hard reject (distinct from the general fingerprint-mismatch conflict case — amount specifically must reject) | 604310 |
| `p_correlation_id` null but strong identity resolvable | A call with `p_correlation_id` null but a resolvable high-priority `effective_idempotency_key` (e.g. `payment_intent_id` or provider payment key present) must not be rejected solely for correlation_id being null | 604310 |
| Weak identity reconciliation | When no `effective_idempotency_key` can be resolved with sufficient confidence, route to `reconciliation_required` or `pending_confirm` — never a blind proceed, never a blind reject | 604310 |

---

## 9. Required Duplicate Request Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| Confirm + webhook race | Only one APPROVED row created under concurrent calls | 604310, 604330 |
| Duplicate `provider_tx_id`, conflicting `order_id` | CRITICAL diagnostic + human-review state, no second APPROVED (604302 §2.3 step 5) | 604310 |

---

## 10. Required Timeout Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| Provider timeout | No APPROVED row inserted; UNKNOWN/`reconciliation_required` state, per 604302 §2.5 and §8 | 604360, 604370 |

---

## 11. Required Unknown State Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| Ambiguous provider status | Not collapsed into SUCCESS or FAILED (604302 §8.3 prohibited list) | 604370 |
| Payment approved, release failed (split-brain) | `payment_release_split_brain` / recovery_required flag, no silent rollback of APPROVED (604302 §4.4) | 604330 |

---

## 12. Required Rollback Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| New patch migration rollback | Reversible without touching existing migration files (604302 §10) | 604310, 604320, 604350 (per new patch file) |
| Split-brain recovery path | Manual kitchen path per runbook does not require destructive data changes | 604330 |

---

## 13. Required Audit Ledger Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| TC-008 evidence chain (900103) | `PAYMENT_APPROVED` precedes `KDS_RELEASED_AFTER_PAYMENT`; no `KDS_RELEASED_AFTER_PAYMENT` without `PAYMENT_APPROVED` (900103 §8 audit rule) | 604340 |
| New event types (604302 §5.2) | `PAYMENT_DUPLICATE_IGNORED`, `PAYMENT_UNKNOWN`, `KDS_RELEASE_SKIPPED_IDEMPOTENT`, `KDS_RELEASE_FAILED`, `PAYMENT_RELEASE_SPLIT_BRAIN` — each mapped to the existing event contract or introduced only via 604340's own approved change_contract | 604340 |
| correlation_id propagation | Same `correlation_id` across confirm → release → ledger/audit records | 604340 |

---

## 14. Required Evidence Packet Tests

| Case | Expectation | Owning slice |
| --- | --- | --- |
| Blocked transition attempts | Recorded per 900103 §8 ("blocked transition attempt는 반드시 기록됨") | 604350, 604370 |
| Ledger append-only / approved audit policy | No unauthorized ledger mutation path introduced by any Scope D slice | 604340, 604380 |

---

## 15. Manual Verification Checklist

Reused verbatim from `900103` §13 and `604302` §9 — **read-only commands, informational at this master-plan stage**:

```text
grep -r "release_kds_after_payment" lib/
  expected: 0 matches (Flutter must never call it directly)

grep -r "release_kds_after_payment" supabase/functions/
  expected: only toss-payments-confirm and toss-payments-webhook (once 604360 creates them)

git diff --check
  expected: clean, no unauthorized files touched
```

`900103` §11 Phase 1 (Scope D) 통과 기준 checklist (TC-001–TC-008, TC-101–TC-103, TC-109) is the closeout gate owned by `604380`.

---

## 16. Test Plan Authorization Boundary

```text
This document maps test obligations. It does not:
  - create test files
  - create SQL/migration files
  - create Edge Function files
  - create Flutter test or source files
  - create Python tooling files
  - run any test or verification command

Each sub-workpacket (604310–604380) must author its own test_plan.md,
scoped only to the rows it owns in Section 2 above, before any Codex
implementation may begin for that slice.
```

---

## 17. Source References

| Category | Path |
| --- | --- |
| Test case source | `docs/900000_patent_and_handoff_package/900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` |
| Change contract source | `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` |
| Scope D overview | `604301_Overview_Scope_D_Server_Runtime_Guard.md` |
| Scope D logic | `604302_Logic_Scope_D_Server_Runtime_Guard.md` |
| Pipeline governance | `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` |

---

## 18. Final Rule

```text
No sub-workpacket test file may be written from this document alone.
This master test plan exists to prevent duplicate or missing test ownership
across 604310–604380 — each slice still owns and authors its own test_plan.md.
```
