# 604301_Overview_Scope_D_Server_Runtime_Guard.md

Status: Draft  
Lifecycle: Overview  
Gate Classification: Scope D Master Design Draft  
Runtime Implementation Authorization: Not Granted  
Owner: TBD  
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned **before Human Approval**. No Scope D implementation slice may proceed while Owner remains TBD.

---

## 0. Purpose

Scope D **Server Runtime Guard**는 Flutter UI가 아니라 **서버 런타임**이 결제 승인, KDS release, ledger truth, audit evidence, unknown-state 처리, RLS/권한 경계를 강제하는 MVP 구현 단계의 **선행 게이트**다.

핵심 목적:

```text
1. APPROVED 결제 없이는 KDS release 불가
2. 클라이언트는 KDS release 권한 없음
3. confirm_payment는 idempotent해야 함
4. release_kds_after_payment는 idempotent해야 함
5. 중복 결제 / 중복 release / 중복 callback 방지
6. unknown provider/payment state를 success 또는 failure로 단정하지 않음
7. ledger / audit / evidence / correlation_id를 남김
8. RLS / 권한 / tenant boundary를 우회하지 않음
```

Scope D가 통과되기 전에는 Scope C/A/B/E Flutter UI가 결제 완료, KDS release, 착석/호출 상태를 **최종 truth**처럼 표시하면 안 된다.

This overview does not authorize implementation.  
Codex must not implement the entire Scope D from this document.  
Each Scope D sub-workpacket requires its own impact_scope, change_contract, implementation approval, verification, and audit.

---

## 1. Scope D Position In MVP Sequence

Catch Menu MVP 구현 순서는 `900102` ChangeContract와 `catchmenu_app/impact_scope.md`가 정의한다.

```text
1순위  Scope D  Server Runtime Guard     ← 본 문서
2순위  Scope C  KDS HOLD/COMMITTED UI
3순위  Scope A  고객 대기/선주문/결제 handoff
4순위  Scope B  직원 대기/호출/착석
5순위  Scope E  DID 투영
```

**D가 먼저인 이유:**

| 이유 | 설명 |
| --- | --- |
| Authority | UI는 표시만 한다. 결제/KDS release truth는 서버만 소유 |
| Safety | UI를 아무리 잘 만들어도 서버 guard 없으면 HOLD→COOKING 우회 가능 |
| Invariants | INV-001~006은 **서버에서** 강제되어야 Flutter가 안전하게 동작 |
| Test gate | 900103 invariant / duplicate / forbidden-release 테스트는 Scope D 이후 의미 있음 |
| Flutter dependency | `604101`/`604102`는 RpcCaller·세션 방어를 정의하지만 release authority는 서버 |

Scope D 미통과 상태에서 Scope C/A를 “완료”로 표시하는 것은 **허용되지 않는다**.

---

## 2. Business Authority Rule

```text
Server owns payment truth.
Server owns KDS release authority.
Client UI success is not payment truth.
Provider callback alone is not payment truth.
Seating and calling are not payment.
```

### 2.1 Source of Truth (900102 §2)

| Domain | Table / Function | Client role |
| --- | --- | --- |
| Handoff session | `catchmenu_pos.order_sessions` | Read + submit intent |
| Order | `catchmenu_pos.orders` | Read + create preorder |
| Payment | `catchmenu_payment.payment_ledger` | Trigger confirm path only |
| KDS | `catchmenu_kds.kds_tickets` | Read; staff transition only where allowed |
| Evidence | `catchmenu_ledger.events`, `catchmenu_audit.*` | Never write directly |

### 2.2 Protected Business Claim

```text
KDS visibility before payment:  ALLOWED (HOLD)
KDS execution before payment:   FORBIDDEN (no HOLD → COMMITTED without APPROVED)
```

---

## 3. Invariants Covered

Scope D에서 **서버가 강제해야 하는** 불변식:

| INV | Scope D 서버 의무 | 현재 repo 기준 메모 |
| --- | --- | --- |
| **INV-001** | `payment_ledger.status = APPROVED` 후에만 `HOLD → COMMITTED` | `0098` `confirm_payment` → `release_kds_after_payment` 내부 호출 존재. guard 강화·검증 필요 |
| **INV-002** | `SEATED` ≠ release trigger | `seat_*` RPC에서 release 호출 금지 (900102 Scope D 금지 목록) |
| **INV-003** | `ARRIVAL_PENDING` / call ≠ release trigger | `call_waiting_*` RPC에서 release 금지 |
| **INV-004** | Client/KDS UI/DID가 release RPC 직접 호출 불가 | Flutter `rpc_caller` 차단 있음. **DB GRANT는 `authenticated`에 release 허용** — Scope D gap |
| **INV-005** | Duplicate confirm/callback → release 1회 | `release`는 `WHERE kds_status = 'HOLD'`. confirm idempotency는 **강화 대상** |
| **INV-006** | 상태 전이마다 ledger/audit evidence | `append_audit_record`, ledger events — **누락·correlation 표준화 검증 필요** |

INV-001~006의 **최종 강제**는 서버 Scope D sub-workpacket 완료 후 human closeout으로 확인한다.

---

## 4. Non-Goals

Scope D **가 아닌** 것:

| 항목 | 해당 Scope / 문서 |
| --- | --- |
| Flutter UI (대기, 결제, KDS 화면) | Scope A / C |
| KDS ticket card UI, disabled cook button | Scope C |
| Staff waiting admin UI | Scope B |
| DID display UI | Scope E |
| POS Gateway / OKPOS / Toss POS adapter | `docs/000800_*`, POS lifecycle |
| Broad SQL refactor | 금지 |
| RLS 전역 재설계 (Scope D 범위 외) | 별도 security workpacket |
| Production release / commercial launch | 별도 release gate |
| Customer marketing / support wording | 별도 policy |

---

## 5. Runtime Domains

Scope D가 다루는 런타임 영역:

```text
payment          confirm_payment, confirm_payment_webhook, get_payment_status
KDS              release_kds_after_payment, kds_tickets HOLD/COMMITTED guard
ledger           payment_ledger, catchmenu_ledger.events
audit            catchmenu_audit.append_audit_record, catchmenu_dev.write_audit_log (dev)
RLS / GRANT      who may EXECUTE release; tenant/store boundary
Edge Function    toss-payments-confirm, toss-payments-webhook (planned / documented)
unknown-state    pending, timeout, partial failure, reconciliation_required
correlation      correlation_id across confirm → release → ledger
idempotency      provider_tx_id, order_id, webhook replay
```

### 5.1 Primary Postgres Schemas

```text
catchmenu_payment   payment_ledger, confirm/release RPC
catchmenu_kds         kds_tickets
catchmenu_pos         orders, order_sessions
catchmenu_ledger      events (evidence)
catchmenu_audit       audit records
catchmenu_common      message_catalog, edge_function_configs, diagnostics
catchmenu_dev         dev_audit_log (dev only, 0136)
```

---

## 6. Expected Workpacket Split

Scope D 전체를 **한 번에 구현하지 않는다**. 아래 sub-workpacket 단위로 분리한다.

| # | Workpacket folder (planned) | Intent |
| --- | --- | --- |
| 1 | `604400_scope_d_01_payment_confirm_idempotency` | `confirm_payment` duplicate-safe; same-result return; unknown provider handling |
| 2 | `604320_scope_d_02_kds_release_guard` | `release_kds_after_payment` SYSTEM-only; HOLD-only update; idempotent COMMITTED |
| 3 | `604330_scope_d_03_payment_to_kds_transaction_boundary` | confirm 내부 release only; partial failure / unknown split-brain |
| 4 | `604340_scope_d_04_ledger_evidence_correlation` | INV-006 events; correlation_id; before/after state |
| 5 | `604350_scope_d_05_rls_security_dry_run` | REVOKE client release; GRANT service path; tenant boundary dry-run |
| 6 | `604360_scope_d_06_edge_function_toss_confirm_boundary` | Toss verify → confirm; webhook dedupe; no UI-trust |
| 7 | `604370_scope_d_07_integration_test_and_unknown_state` | 900103 invariant tests; unknown/retry/reconciliation cases |
| 8 | `604380_scope_d_08_scope_d_closeout_audit` | grep/GRANT/ledger checklist; Scope C/A gate unlock decision |

### 6.1 Sub-Workpacket Boundary Overlap Risk

`604330_scope_d_03_payment_to_kds_transaction_boundary` may **overlap** with `604310` and `604320` on function and file boundaries:

```text
604310  confirm_payment idempotency     → touches confirm_payment, payment_ledger paths
604320  kds_release_guard               → touches release_kds_after_payment, kds_tickets
604330  payment_to_kds boundary         → confirm → release coupling, partial failure, same RPC/migration files
```

**Duplicate boundary risk:** if `604310`, `604320`, and `604330` each claim the same SQL file or function without a narrow, non-overlapping change_contract, edits may conflict or double-apply. Each slice must declare **explicit allow/deny file lists** in its own `impact_scope.md` and resolve overlap at Human Approval before Codex implementation.

각 sub-workpacket는 독립적으로:

```text
impact_scope → logic → test_plan → change_contract
→ human approval → Codex slice → verification → Claude audit
```

---

## 7. Known References

Repo 검색 결과 (2026-07-01 기준). **구현 승인 아님 — 현재 상태 조사**.

### 7.1 Governance / Change Contract / Test

| Path | Role |
| --- | --- |
| `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | Scope D 정의, INV-001~006, 허용/금지 파일, Scope D 구현 범위 |
| `docs/900000_patent_and_handoff_package/900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | TC, invariant grep checks, duplicate/release tests |
| `docs/900000_patent_and_handoff_package/900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` | Handoff pipeline, release authority narrative |
| `docs/900000_patent_and_handoff_package/900121_Logic_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session.md` | DROP-A~E (client); server truth separation |
| `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` | Cursor→Claude→Codex→Human pipeline |
| `docs/600000_implementation_lifecycle/604000_workpackets/604100_flutter_mvp_foundation/604101_Overview_Flutter_MVP_Project_Structure.md` | Flutter structure; Scope D gate reference |
| `docs/600000_implementation_lifecycle/604000_workpackets/604100_flutter_mvp_foundation/604102_Logic_Flutter_MVP_Core_Implementation.md` | RpcCaller, INV client mapping |
| `docs/600000_implementation_lifecycle/604000_workpackets/604100_flutter_mvp_foundation/604103_Module_Flutter_MVP_Foundation_Scaffold_Implementation.md` | Foundation scaffold record |
| `catchmenu_app/impact_scope.md` | Per-scope allow/deny; Scope D = server first |

### 7.2 SQL — Core Payment / KDS / Ledger

| Path | Role |
| --- | --- |
| `sql/migrations/0014_create_payment_ledger.sql` | `payment_ledger` = payment SoT; idempotency_key on intents |
| `sql/migrations/0012_create_pos_order_sessions.sql` | `order_sessions` handoff |
| `sql/migrations/0013_create_pos_orders.sql` | `orders` |
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | **`confirm_payment`, `release_kds_after_payment`, webhook, grants** |
| `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` | Toss webhook processing |
| `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | Toss payments pipeline integration |
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | Waiting/preorder; references release path |
| `sql/migrations/0119_create_edge_function_integration.sql` | Edge function config seeds (`toss-payments-confirm`, `toss-payments-webhook`) |
| `sql/migrations/0113_create_api_spec_docs.sql` | API spec for confirm/release RPC |
| `sql/migrations/0121_create_security_pipeline.sql` | Security notes on confirm/release flow |
| `sql/migrations/0136_create_dev_audit_log.sql` | `catchmenu_dev.write_audit_log` |
| `sql/migrations/0021_enable_rls.sql`, `0022_create_rls_policies.sql` | RLS baseline |
| `sql/migrations/0066_create_ledger_integrity_rpc.sql` | Ledger integrity |

### 7.3 SQL — Referenced but NOT present (900102 plan)

| Path | Status |
| --- | --- |
| `supabase/migrations/0136_patch_release_kds_idempotency.sql` | **Not found in repo, and the name is stale.** 900102 planned this path/number, but this repo has no `supabase/` directory (migrations live under `sql/migrations/`) and `0136` is already used by `0136_create_dev_audit_log.sql`; `0137`, `0138` (×2), `0139` are also taken (checked 2026-07-01). The implementing slice must pick the next free number under `sql/migrations/` at implementation time, not `0136`. |
| `supabase/functions/toss-payments-confirm/index.ts` | **Not found** — `supabase/` directory empty/absent |
| `supabase/functions/toss-payments-webhook/index.ts` | **Not found** |

### 7.4 Flutter (client guard only — Scope D validates server side)

| Path | Role |
| --- | --- |
| `catchmenu_app/lib/core/supabase/rpc_caller.dart` | Blocks `release_kds_after_payment` (INV-004 client) |
| `catchmenu_app/lib/core/constants/app_constants.dart` | `forbiddenClientRpcs` |
| `catchmenu_app/lib/core/errors/app_error.dart` | `FORBIDDEN_CLIENT_CALL` |
| `catchmenu_app/lib/features/payment/README.md` | Payment ≠ UI success |
| `catchmenu_app/lib/features/kds/README.md` | No release from KDS UI |

### 7.5 Known Gap (Scope D must address)

```text
0098 grants EXECUTE on release_kds_after_payment TO authenticated.
900102 / INV-004 require client must NOT call release.
Flutter rpc_caller blocks client-side, but DB GRANT still allows direct RPC.
Scope D sub-workpacket 604350 must close this gap.
```

### 7.6 Schema Drift Blocker (Policy Update, 2026-07-01)

A design policy consolidation covering `confirm_payment` integrity, idempotency, schema drift, and legacy POS ACL identified a **physical schema mismatch** that blocks safe implementation of `604310`:

```text
payment_ledger (0014 DDL) requires intent_id NOT NULL and defines column provider_payment_key.
confirm_payment's INSERT (0098) omits intent_id entirely and writes provider_tx_id instead.
No reconciling ALTER TABLE exists anywhere in sql/migrations/.
```

**Policy:** Do not implement `604310` idempotency on top of a physically broken ledger insert path. Schema Drift Alignment (a `604305`-style precondition — no such numbered document exists yet, and this update does not create one) must verify or close this mismatch before any `604310` implementation is authorized. This includes:

```text
- payment_ledger / confirm_payment physical schema contract alignment
- intent_id binding
- provider_payment_key vs provider_tx_id naming mismatch
- undefined fee_amount reference risk
- confirm_payment compile / dry-run verification
```

### 7.7 Current Target / Explicitly Excluded (Policy Update)

```text
Current target:
  0098 confirm_payment main pipeline — this is the only confirm entry point Scope D
  sub-workpacket 604310 designs against.

Explicitly out of scope for 604310 (and for Scope D generally unless a future
sub-workpacket's own change_contract expands it):
  0027 confirm_payment_from_provider — recorded as a future split-brain consolidation
    concern (dual confirm APIs, §7.5 604311 Known Gap #5), not a 604310 edit target.
  provider webhook callback redesign
  Edge Function webhook integration (604360's boundary)
  provider-specific callback routing
  full provider pipeline consolidation
```

---

## 8. Risk Summary

| Risk | Impact | Scope D mitigation direction |
| --- | --- | --- |
| **Duplicate payment** | Double charge, double ledger | Idempotent confirm; same-result return; provider_tx_id uniqueness |
| **Duplicate KDS release** | Double kitchen start | `WHERE kds_status = 'HOLD'` (exists); verify COMMITTED idempotency |
| **Client release call** | INV-004 violation | REVOKE authenticated; service role / internal only |
| **Toss UI success only** | False payment complete | Edge verify before confirm; pending/unknown UI |
| **Provider unknown** | Wrong success/failure | reconciliation_required; no blind retry |
| **Payment approved, release failed** | Split-brain | Unknown state + manual recovery path |
| **Audit gap** | INV-006 / patent audit fail | Mandatory ledger events with correlation_id |
| **RLS bypass** | Cross-tenant leak | security definer review + dry-run tests |
| **Broad refactor** | Regression | One sub-workpacket at a time; no unrelated migration edits |

---

## 9. Required Gates Before Implementation

Scope D **어떤 sub-workpacket**도 아래 없이 Codex 구현 시작 금지:

```text
0. Owner assigned (TBD forbidden at Human Approval and implementation start)
1. impact_scope.md (해당 sub-workpacket, 허용/금지 파일 명시)
2. Logic document (604302 또는 sub-workpacket logic)
3. test_plan (900103 케이스 매핑)
4. change_contract (900102 형식, 승인 Scope = D slice)
5. Human approval (implementation_approval / gate record)
6. Codex implementation (narrow file list only)
7. Verification (SQL test, grep, integration test per 900103)
8. Claude audit (raw logs + diff, 600179 pipeline)
```

Controlled pipeline reference: `000701_Guide_Controlled_AI_Development_Pipeline.md`

**Append-only migration rule (strengthened, policy update 2026-07-01):** `0014_create_payment_ledger.sql`, `0098_create_payment_confirm_pipeline_rpc.sql`, and `0027_create_payment_intent_rpc.sql` are historical migration files and must never be edited in place, by any Scope D sub-workpacket, under any circumstance. The only permitted implementation shapes are: a new append-only patch migration; `CREATE OR REPLACE FUNCTION` for `confirm_payment` inside that new patch file; and `ALTER TABLE` only inside a new patch migration, and only if schema alignment (§7.6) has been explicitly approved.

---

## 10. Final Rule

```text
Scope D exists so the server owns payment approval and KDS release truth.
No Flutter screen, Toss widget success, seating action, or provider callback
may substitute for APPROVED ledger evidence and guarded HOLD → COMMITTED release.
Scope D closeout unlocks Scope C/A/B/E UI work — it does not replace them.
```

---

## Appendix — Document Map

| Document | Relationship |
| --- | --- |
| `604302_Logic_Scope_D_Server_Runtime_Guard.md` | Master logic draft for Scope D |
| `604301` (this file) | Master overview draft |
| Sub-workpackets `604310`–`604380` | To be created per slice |
