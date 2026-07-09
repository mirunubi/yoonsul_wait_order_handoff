# 604405_ImpactScope_Scope_D_01_Payment_Confirm_Idempotency.md

Status: Draft
Lifecycle: ImpactScope
Gate Classification: Scope D Sub-Workpacket 01 — Stage 1 Boundary Scan
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation slice may proceed while Owner remains TBD.

This ImpactScope does not authorize implementation.
It only records discovered files, functions, risks, and candidate future change boundaries.
Codex must not implement from this ImpactScope.
A slice-specific Overview, Logic, TestPlan, ChangeContract, and Human Approval are required before implementation.

Upstream master pack: `604300_Index_Scope_D_Server_Runtime_Guard.md`, `604301_Overview_…`, `604302_Logic_…`, `604303_TestPlan_…`, `604304_ChangeContract_…`
Pipeline: `000701_Guide_Controlled_AI_Development_Pipeline.md`

---

## 0. Purpose

Scope D sub-workpacket **604404** (`payment_confirm_idempotency` / amount verification)의 **영향 범위 조사**만 수행한다.

본 문서는 `confirm_payment` 및 그 진입 경로(Toss pipeline, webhook)에서 다음을 **발견·기록**한다.

- 중복 confirm / callback idempotency 현재 동작
- `p_approved_amount` vs 주문 기대 금액 검증(TC-110) 관련 코드 위치
- `payment_ledger` SoT, `catchmenu_ledger.events`, audit 기록 위치
- `idempotency_key`, `correlation_id` 존재 여부
- 향후 patch migration 후보 번호 및 금지 파일

**구현·설계 확정·ChangeContract·TestPlan·Codex 지시는 본 단계 범위 밖.**

---

## 1. Scope Boundary

### 1.1 In scope (investigation + future slice intent)

| Area | Boundary |
| --- | --- |
| Primary RPC | `catchmenu_payment.confirm_payment` |
| Webhook entry | `catchmenu_payment.confirm_payment_webhook` |
| Toss integration callers | `catchmenu_integrations.confirm_toss_payment`, `initiate_toss_payment` |
| Amount fields | `p_approved_amount`, `catchmenu_pos.orders.final_amount` (expected), `payment_intents.requested_amount`, `toss_payment_requests.amount` |
| Idempotency | `provider_tx_id`, `order_id` + `ledger_status = APPROVED`, `payment_intents.idempotency_key`, `toss_payment_requests.idempotency_key` |
| Evidence | `catchmenu_payment.payment_ledger`, `catchmenu_ledger.events`, `catchmenu_audit.append_audit_record`, `catchmenu_common.log_diagnostic` |
| Tests (reference only) | `900103` TC-102, TC-110; `604303` §2–§3 ownership for 604404 |

### 1.2 Out of scope (other sub-workpackets)

| Area | Owner slice |
| --- | --- |
| `release_kds_after_payment` guard / HOLD→COMMITTED idempotency | `604320` |
| confirm→release transaction boundary / split-brain | `604330` (overlaps function file with 604404 — see §1.3) |
| Proposed ledger event name contract (`PAYMENT_DUPLICATE_IGNORED`, etc.) | `604340` |
| REVOKE `authenticated` on `release_kds_after_payment` | `604350` |
| Edge Function source (`supabase/functions/`) | `604360` (not present in repo) |
| Integration re-verification pass | `604370` |
| Scope D closeout | `604380` |

### 1.3 Overlap risk with 604320 / 604330

`confirm_payment` (604404) **내부에서** `release_kds_after_payment`를 호출한다 (`0098` L348–356).
동일 migration 파일 `0098_create_payment_confirm_pipeline_rpc.sql`을 604404·604320·604330이 공유할 수 있어 **duplicate boundary risk**가 있다 (`604301` §6.1).
향후 slice별 `impact_scope.md`는 **non-overlapping file/function allow list**를 Human Approval 전에 확정해야 한다.

### 1.4 Alternate confirm path (reference — not primary 604404 target unless mapped)

`catchmenu_payment.confirm_payment_from_provider` (`0027` L202+) — intent 기반 레거시 경로.
Amount mismatch 시 **차단 반환** (`error_key: amount_mismatch`, L244–251). KDS auto-release 없음 (`kds_release_authorized = false`).
Handoff MVP 경로는 `0098` `confirm_payment`가 주 경로 (`900102`, `604302`).

---

## 2. Source Files Found

Repo 검색 기준 (2026-07-01). 경로는 `sql/migrations/` unless noted.

| Category | Path | Relevance |
| --- | --- | --- |
| **Primary confirm pipeline** | `0098_create_payment_confirm_pipeline_rpc.sql` | `confirm_payment`, `confirm_payment_webhook`, `release_kds_after_payment`, grants |
| Payment SoT DDL | `0014_create_payment_ledger.sql` | `payment_ledger`, `payment_intents`, `payment_events` |
| Payment intent RPC | `0027_create_payment_intent_rpc.sql` | `confirm_payment_from_provider`, intent `idempotency_key` |
| Toss payments | `0103_create_toss_payments_pipeline_rpc.sql` | `initiate_toss_payment`, `confirm_toss_payment` → calls `confirm_payment` |
| Toss webhook (legacy) | `0038_create_toss_webhook_processor_rpc.sql` | `confirm_payment_from_provider` path |
| Orders (expected amount) | `0013_create_pos_orders.sql` | `final_amount`, `total_amount`, `discount_amount` |
| Audit RPC | `0023_create_append_audit_rpc.sql` | `append_audit_record` |
| Ledger events DDL | `0006_create_ledger_event.sql` | `catchmenu_ledger.events` |
| RLS | `0021_enable_rls.sql`, `0022_create_rls_policies.sql` | `payment_ledger` policies |
| Edge config seed | `0119_create_edge_function_integration.sql` | `toss-payments-confirm`, `toss-payments-webhook` config |
| API spec | `0113_create_api_spec_docs.sql` | confirm/release RPC documentation |
| Dev audit | `0136_create_dev_audit_log.sql` | `catchmenu_dev.write_audit_log` (Flutter trace only) |
| Diagnostics | `0062_create_i18n_error_diagnostics.sql`, `0063_patch_core_rpc_i18n_diagnostics.sql` | `log_diagnostic`, error keys |
| Governance docs | `900102`, `900103`, `604301`–`604304`, `604302` | TC-102, TC-110, INV-005 |
| Flutter (reference) | `catchmenu_app/lib/features/payment/README.md`, `app_constants.dart` | No `confirm_payment` client impl yet |
| **Missing** | `supabase/functions/toss-payments-*` | Directory absent |
| **Missing** | `supabase/migrations/0136_patch_release_kds_idempotency.sql` | Planned in `900102`; not in repo |

---

## 3. SQL / Migration References

| Migration | Functions / objects | 604404 relevance |
| --- | --- | --- |
| `0098_create_payment_confirm_pipeline_rpc.sql` | `confirm_payment` (L145+), `confirm_payment_webhook` (L591+), error keys `payment_already_confirmed` (L99–101, L125–126), `payment_idempotency_violation` (L132–134) | **Primary patch target candidate** |
| `0014_create_payment_ledger.sql` | `payment_ledger`, `payment_intents.idempotency_key` (L40) | SoT schema; **column mismatch vs `0098` INSERT** (see §9) |
| `0103_create_toss_payments_pipeline_rpc.sql` | `initiate_toss_payment` (L315+), `confirm_toss_payment` (L522+), `toss_payment_requests.idempotency_key` (L419–427, L445) | Toss confirm caller; `payment_already_confirmed` at L403 |
| `0038_create_toss_webhook_processor_rpc.sql` | Webhook → `confirm_payment_from_provider` (L294) | Parallel legacy path |
| `0119_create_edge_function_integration.sql` | Edge function name seeds | Future `604360` boundary |
| `0027_create_payment_intent_rpc.sql` | `confirm_payment_from_provider` | Amount mismatch blocks (contrast with `0098`) |
| `0136`–`0139` | Dev audit, patches, AI log | Numbering occupied (§12) |

**Policy:** `900102` / `604302` §10 — **기존 migration 파일 in-place 수정 금지**. 향후 변경은 **신규 patch migration**만 후보.

---

## 4. Function / RPC References

### 4.1 `catchmenu_payment.confirm_payment`

| Item | Location |
| --- | --- |
| Definition | `0098` L145–159 (signature), L172–~460 (body) |
| Parameters | `p_approved_amount int` (L152), `p_correlation_id text default null` (L158), `p_provider_tx_id text` (L151) |
| Duplicate — provider_tx | L190–228: runs **only if** `p_correlation_id is not null`; existing APPROVED → `payment_already_confirmed` **error** (L221–227) |
| Duplicate — order APPROVED | L252–264: `payment_already_confirmed` **error** (no same-success return) |
| Amount check (TC-110) | L267–290: `abs(p_approved_amount - v_order.final_amount) > 10` → `log_diagnostic` event `payment_amount_mismatch` — **does not RETURN; flow continues** |
| Expected amount source | `v_order.final_amount` from `catchmenu_pos.orders` (L232–234, L268) |
| Ledger insert | L306–331 `ledger_status = 'APPROVED'` |
| Internal release call | L348–356 `release_kds_after_payment(...)` |
| Grants | L1293–1297 `GRANT EXECUTE … TO authenticated` |

### 4.2 `catchmenu_payment.confirm_payment_webhook`

| Item | Location |
| --- | --- |
| Definition | `0098` L591+ |
| Behavior | Parses webhook payload → builds `v_correlation_id` (`WH-` prefix, L691+) → calls `confirm_payment` (L697+) |

### 4.3 `catchmenu_integrations.confirm_toss_payment`

| Item | Location |
| --- | --- |
| Definition | `0103` L522+ |
| Caller | L695–710 → `catchmenu_payment.confirm_payment(...)` with `p_correlation_id` |
| Prior duplicate check | `initiate_toss_payment` L395–408 `payment_already_confirmed` on `toss_payment_requests.request_status = 'DONE'` |

### 4.4 Related (out of slice primary edit, referenced)

| Function | File | Note |
| --- | --- | --- |
| `release_kds_after_payment` | `0098` L467+ | Called from `confirm_payment`; owned by 604320/604330 |
| `get_payment_status` | `0098` L1180+ | Read path; returns `final_amount` in order_amount |
| `confirm_payment_from_provider` | `0027` L202+ | Different idempotency / amount rules |

---

## 5. Ledger / Audit / Evidence References

### 5.1 Payment ledger (SoT)

| Item | Location |
| --- | --- |
| Table DDL | `0014` L154+ `catchmenu_payment.payment_ledger` |
| Design intent | `0014` L1–6: payment_ledger = **ONLY** source of truth |
| `0098` insert columns | L306–317: `provider_tx_id`, `approved_amount`, `fee_amount`, `net_amount`, `ledger_status`, `provider_response`, etc. |
| Intent idempotency | `0014` L39–40 `payment_intents.idempotency_key text not null` |
| Toss request idempotency | `0103` `toss_payment_requests.idempotency_key` (generated L419–427) |

**Note:** `confirm_payment` does **not** read or write `payment_intents.idempotency_key` directly in `0098`.

### 5.2 `catchmenu_ledger.events`

| Item | Location |
| --- | --- |
| Table DDL | `0006_create_ledger_event.sql` |
| `confirm_payment` insert | `0098` L386–415: `event_domain = 'payment'`, `event_type = 'payment_confirmed'`, `from_state = 'PENDING'`, `to_state = 'APPROVED'`, `correlation_id = p_correlation_id` |

**604302 proposed event names** (`PAYMENT_DUPLICATE_IGNORED`, `PAYMENT_UNKNOWN`, etc.) are **not** emitted by current `0098`; mapping is `604340` / future ChangeContract.

### 5.3 Audit / diagnostics

| Item | Location |
| --- | --- |
| `catchmenu_audit.append_audit_record` | `0098` L359–383; `audit_type = 'payment_confirmed'` |
| `catchmenu_common.log_diagnostic` | Duplicate attempt L202–218 (`payment_idempotency_violation`); amount mismatch L271–289 (`payment_amount_mismatch`) |
| Dev-only Flutter trace | `0136_create_dev_audit_log.sql` — not financial SoT |

### 5.4 `correlation_id`

| Location | Usage |
| --- | --- |
| `confirm_payment` param | `0098` L158, passed to release/audit/ledger |
| Webhook synthetic id | `0098` L691–693 `WH-` + provider + tx |
| Toss confirm | `0103` L709 `p_correlation_id := p_correlation_id` |
| Duplicate guard coupling | Idempotency branch L191: **requires** `p_correlation_id is not null` |

---

## 6. Permission / GRANT / RLS References

### 6.1 EXECUTE grants (`0098` L1285–1345)

| Function | Grantee |
| --- | --- |
| `confirm_payment` | `authenticated` (L1293–1297) |
| `confirm_payment_webhook` | `authenticated` (L1312–1315) |
| `release_kds_after_payment` | `authenticated` (L1303–1306) — **604350** |
| `get_payment_status` | `authenticated` (L1341–1344) |

`service_role` is not explicitly granted in this block; Edge paths typically use service role at runtime (to be confirmed in `604360`).

### 6.2 RLS (`0022` L425–436)

- `payment_ledger_select`: `authenticated` may **SELECT** own tenant/store rows only.
- **No** `INSERT`/`UPDATE` policy for `authenticated` on `payment_ledger` — writes expected via `SECURITY DEFINER` RPCs.

### 6.3 Flutter client guard

- `catchmenu_app` has no `.rpc('confirm_payment')` implementation found.
- `rpc_caller.dart` blocks `release_kds_after_payment` (INV-004 client) — outside 604404 primary scope.

---

## 7. Test References

| Source | Test IDs | Expectation for 604404 |
| --- | --- | --- |
| `900103_TestPlan_…` | **TC-102** (L257–268) | Duplicate confirm → one approval, one release, idempotent audit |
| `900103_TestPlan_…` | **TC-110** (L364–371) | Amount mismatch → **no KDS release**, event flagged / rejected |
| `604303_TestPlan_…` | §2 row 604404 | Owns TC-102, TC-110; unit branch coverage for `confirm_payment` |
| `604303_TestPlan_…` | §3 | Amount verification = validation gate, not split-brain (604330) |
| `604303_TestPlan_…` | §5 | New patch dry-run; **no** migration file authorized here |

**Repo test gap:** `tests/` — no matches for `confirm_payment`, `payment_already_confirmed`, `TC-110`.
`0073_final_verification.sql` asserts `confirm_payment_from_provider` exists (L566–569), not `confirm_payment`.
`0098` file contains inline SQL examples at L1289+ (commented usage patterns) — not automated TC-102/110 tests.

---

## 8. Current Behavior Summary

### 8.1 Duplicate confirm (`TC-102` gap vs target)

| Trigger | Current behavior |
| --- | --- |
| Same `provider_tx_id` + APPROVED, `p_correlation_id` set | `build_error_response('payment_already_confirmed')` — **not** same-success return |
| Same `order_id` already APPROVED | `payment_already_confirmed` error (L252–264) |
| `p_correlation_id` is null | Provider_tx idempotency block **skipped** (L191) |
| After success | `release_kds_after_payment` invoked once per successful insert path |

`604302` / `900103` target: **same result return** on safe duplicate — **not implemented** in `0098`.

### 8.2 Amount verification (`TC-110` gap)

| Field | Role |
| --- | --- |
| Expected | `catchmenu_pos.orders.final_amount` (`0098` L268) |
| Approved input | `p_approved_amount` parameter |
| Tolerance | ±10 KRW (`0098` L268–269) |
| On mismatch | Diagnostic log only (`payment_amount_mismatch`); **APPROVED insert and KDS release still proceed** (L305–356) |

Contrast: `confirm_payment_from_provider` (`0027` L244–251) **returns** `amount_mismatch` and does not insert APPROVED.

### 8.3 Toss path

`confirm_toss_payment` (`0103`) updates `toss_payment_requests` then calls `confirm_payment` with Toss `payment_key` as `p_provider_tx_id` and webhook/caller `p_correlation_id`.

---

## 9. Known Gaps

1. **TC-102:** Duplicate paths return **error**, not idempotent success payload (`0098` L221–227, L258–264).
2. **TC-110:** Amount mismatch **does not block** APPROVED or release (`0098` L267–290 vs L305–356).
3. **Idempotency guard** tied to `p_correlation_id is not null` — calls without correlation skip provider_tx duplicate check.
4. **Schema drift:** `0014` `payment_ledger` requires `intent_id`, uses `provider_payment_key`; `0098` INSERT uses `provider_tx_id`, `fee_amount`, `payment_method` without `intent_id` — **DDL vs RPC mismatch** (migration apply order / patch reconciliation needed before implementation).
5. **Dual confirm APIs:** `confirm_payment` vs `confirm_payment_from_provider` with different amount and release semantics.
6. **Proposed ledger events** in `604302` §5.2 not in `0098` (actual: `payment_confirmed` only).
7. **No automated tests** in `tests/` for this slice.
8. **Edge Function source** missing; Toss verify boundary undocumented in runtime code.
9. **604330 overlap:** editing `confirm_payment` may touch release coupling owned by another slice.

---

## 10. Candidate Files For Future Change

**Candidate only — not authorized by this document.**

| Priority | Path | Likely change type |
| --- | --- | --- |
| P0 | **New** `sql/migrations/0140_patch_confirm_payment_idempotency.sql` (or next free number at implementation time) | Patch `confirm_payment` idempotency + TC-110 gate |
| P1 | `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | **Read/reference only** per policy; in-place edit forbidden |
| P2 | `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | Toss caller correlation / duplicate handling alignment |
| P3 | `sql/migrations/0014_create_payment_ledger.sql` | Schema reconciliation if patch requires column alignment |
| P4 | `sql/migrations/0062_create_i18n_error_diagnostics.sql` / message catalog in `0098` | New error keys / messages for mismatch rejection |
| Reference | `docs/900000_patent_and_handoff_package/900103_…` | Slice `test_plan.md` must quote TC-102, TC-110 |
| Reference | `604302_Logic_…` §2 | Design intent for same-result return |

**Explicitly not candidate in 604404 slice (unless ChangeContract expands):**

- `release_kds_after_payment` body changes → prefer `604320`
- GRANT REVOKE on release → `604350`
- `supabase/functions/*` → `604360`
- Flutter `catchmenu_app/**` → Scope A / client slices

---

## 11. Forbidden Files

Unless a **future approved** `change_contract` explicitly allows:

```text
All files not listed in §10 Candidate Files For Future Change
catchmenu_app/** (Flutter/Dart)
supabase/functions/** (create/modify — directory absent)
python/** / tooling scripts
package.json, pubspec.yaml, lockfiles
config seeds unrelated to payment confirm (e.g. 0119 unless 604360 contract)
Existing migration in-place edits (0098, 0014, 0103, …)
tests/** (create/modify)
604303, 604304 master docs (modify without separate governance task)
604320–604380 sub-workpacket folders (except this 604405)
implementation_module, verification_result, audit artifacts
```

---

## 12. Migration Numbering Status

Verified against `sql/migrations/` (2026-07-01):

| Number | File | Status |
| --- | --- | --- |
| 0136 | `0136_create_dev_audit_log.sql` | **Taken** |
| 0137 | `0137_patch_missing_functions.sql` | **Taken** |
| 0138 | `0138_patch_integration_functions.sql` | **Taken** (single file on disk) |
| 0139 | `0139_create_ai_inference_log.sql` | **Taken** |

### 0138 duplication check

- **On disk:** only `0138_patch_integration_functions.sql` exists (22,437 bytes).
- **Glob/index anomaly:** some indexes once listed `0138_patch_integration_functions_4.sql` — **file not present** on filesystem scan; treat as stale reference, not an active duplicate migration.
- **`900102` planned name** `supabase/migrations/0136_patch_release_kds_idempotency.sql` — **invalid** (wrong directory; `0136` taken).

**Next migration number candidate:** `0140` or next integer **not** present under `sql/migrations/` — **re-verify at Human Approval** (`604303` §5).

---

## 13. Open Questions

1. **Same-result idempotency:** Should duplicate `confirm_payment` return success payload mirroring first approval (per `604302` §2) or retain `409 payment_already_confirmed` for some actors?
2. **TC-110 enforcement:** Block at ±10 KRW tolerance, zero tolerance, or reconciliation state without hard fail?
3. **Schema reconciliation:** Must `confirm_payment` align with `0014` `intent_id` / `provider_payment_key` before patch, or extend DDL in same slice?
4. **`p_correlation_id` null:** Should idempotency run without correlation_id (always check `provider_tx_id` + `order_id`)?
5. **`confirm_payment_from_provider`:** Deprecate, redirect, or keep parallel for VAN/webhook legacy (`0038`)?
6. **604404 vs 604330 file ownership:** Can 604404 patch `confirm_payment` without editing release call block, or is coordinated dual contract required?
7. **Owner assignment:** Who owns financial RPC approval for this slice?

---

## 14. Non-Implementation Statement

This document is **Stage 1 ImpactScope only**.

```text
- No SQL, migration, Edge Function, Flutter, Python, or config changes were made.
- No Overview/Logic/TestPlan/ChangeContract for 604404 was created in this step.
- No Codex implementation was instructed.
- No verification or audit artifacts were produced.
```

Next allowed steps per `604300_Index` and `600179`: slice-specific Overview → Logic → TestPlan → ChangeContract → Human Approval (with **Owner assigned**) → Codex implementation.

---

## 15. Post-Policy Reconciliation Note (Added 2026-07-01 — Facts Above Unchanged)

A later design policy consolidation (`confirm_payment` / Scope D integrity, idempotency, schema drift, legacy POS ACL) changes the recommended policy from simple `p_correlation_id` rejection to `effective_idempotency_key` resolution, and converts amount-mismatch handling from a logged warning to a hard block with a 0 KRW default MVP tolerance. It also establishes Schema Drift Alignment (§9 Known Gap #4 above) as a required precondition before `604404` implementation, not merely a recorded open question.

**This does not alter the factual ImpactScope findings above.** Every line reference, current-behavior description, and gap listed in §1–§14 remains an accurate record of the repo state as investigated on 2026-07-01. The policy consolidation changes what `604406`–`604409` recommend building toward; it does not change what `0098`, `0014`, `0027`, or `0103` currently do.

---

## Appendix — Quick Reference Lines

| Finding | File | Lines (approx.) |
| --- | --- | --- |
| `confirm_payment` definition | `0098` | 145–159, 172–460 |
| `payment_already_confirmed` return | `0098` | 221–227, 258–264 |
| Amount mismatch log (no block) | `0098` | 267–290 |
| Ledger event `payment_confirmed` | `0098` | 386–415 |
| `confirm_payment` GRANT authenticated | `0098` | 1293–1297 |
| `payment_intents.idempotency_key` | `0014` | 40 |
| Toss → `confirm_payment` | `0103` | 695–710 |
| TC-102 / TC-110 spec | `900103` | 257–268, 364–371 |
