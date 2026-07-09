# 604500_Analysis_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Wait-Order → Order Confirm → KDS Ticket → Kitchen Progress (No-Payment Pilot Path)
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is a **read-only Analysis** document. It verifies whether the MVP-1 pilot store
can progress from wait-order through order confirmation to KDS ticket creation and
kitchen status transitions **without payment**.

It performs no SQL edit, migration edit, function/trigger edit, runtime code edit,
Flutter/UI edit, test-data insert, DB write, staging, or commit. It does not create
0069 Analysis, does not resume Scope D mainline, and does not mix with the 604392–604395
Group A SQL residue track (604391 scope).

See `docs/000015_Korean_Document_And_Encoding_Safety_Rules.md` for encoding rules.

---

## 1. Analysis Objective

Verify read-only whether this path works **without payment** for MVP-1 pilot stores:

```text
대기열 → 주문 생성/확정 → KDS 티켓 생성 → KDS 진행 상태 전환 → 주방 처리
```

Operational context (from `014280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md`):

```text
MVP-1 may use manual POS entry and manual kitchen note when provider APIs are absent.
Question: does the **implemented SQL/runtime path** support no-payment kitchen
progression, or only operational SOP bypass outside the system?
```

---

## 2. Investigation Scope (Migration Targets)

| Lane | Migration | Primary artifacts inspected |
|---|---|---|
| Waiting queue | 0012, 0025, 0050 | `order_sessions`, session RPCs, queue RPCs |
| Order create/confirm | 0013, 0026 | `orders`, `confirm_order`, KDS insert |
| KDS ticket / commit / cook | 0016, 0028, 0029 | `kds_tickets`, `commit_kds_ticket`, `start_cooking` |
| Pre-order while waiting | 0051 (+ 0115 cross-ref) | pre-order + arrival condition updates |
| DID / kiosk display | 0043, 0114 | display state RPCs (read-side only) |
| POS integration | 0102, 0104 | OKpos/Toss POS payment confirm pipelines |

Additional read-only cross-references (not in numbered target list but required for path truth):

```text
0027_create_payment_intent_rpc.sql
0030_create_manual_fallback_rpc.sql
0098_create_payment_confirm_pipeline_rpc.sql
0099_create_realtime_pipeline_rpc.sql
0070_create_flutter_bootstrap_rpc.sql
0068_create_realtime_edge_rpc.sql (notify_channel)
catchmenu_app/lib/features/kds/README.md
014280 manual fallback work package (policy)
```

---

## 3. Boundary And Exclusions

```text
604392–604395 Group A SQL residue track : NOT mixed into this Analysis
604391 Group A replay-blocker disposition : separate track; not reopened here
0069 Analysis                              : NOT created (deferred)
Scope D mainline                           : NOT resumed (blocked)
Runtime test / DB write                    : NOT performed
```

Git gate (read-only, 2026-07-05):

```text
git diff --check                 : exit 0 (PASS)
git diff --cached --name-only    : empty
No SQL/migration/runtime staging : confirmed
```

Only this Markdown Analysis artifact is created by this workpacket step.

---

## 4. Inventories

### 4.1 Files inspected (representative)

**SQL migrations**

```text
sql/migrations/0012_create_pos_order_sessions.sql
sql/migrations/0013_create_pos_orders.sql
sql/migrations/0016_create_kds_tickets.sql
sql/migrations/0025_create_session_rpc.sql
sql/migrations/0026_create_order_rpc.sql
sql/migrations/0028_create_kds_capacity_commit_rpc.sql
sql/migrations/0029_create_kds_cooking_rpc.sql
sql/migrations/0030_create_manual_fallback_rpc.sql
sql/migrations/0043_create_did_display_rpc.sql
sql/migrations/0050_create_waiting_queue_rpc.sql
sql/migrations/0051_create_pre_order_rpc.sql
sql/migrations/0053_create_staff_management_rpc.sql (can_override_kds field)
sql/migrations/0070_create_flutter_bootstrap_rpc.sql
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
sql/migrations/0099_create_realtime_pipeline_rpc.sql
sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql
sql/migrations/0104_create_toss_pos_pipeline_rpc.sql
sql/migrations/0114_create_mini_kiosk_pipeline_rpc.sql
sql/migrations/0115_create_waiting_pipeline_rpc.sql (pre_order_while_waiting)
```

**Flutter / KDS client**

```text
catchmenu_app/lib/features/kds/README.md  (placeholder only; Scope C deferred)
```

No other Dart files reference `kds_ticket`, `start_cooking`, or `commit_kds_ticket`.

**Policy / ops bridge**

```text
docs/014000_pos_provider_integration_strategy/014280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md
docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004260_Policy_POS_Payment_Webhook_And_Kitchen_Release_Boundary.md
```

### 4.2 Tables

```text
catchmenu_pos.order_sessions
catchmenu_pos.orders
catchmenu_pos.order_items
catchmenu_pos.order_events
catchmenu_kds.kds_tickets
catchmenu_kds.kds_events
catchmenu_payment.payment_ledger
catchmenu_payment.payment_intents
catchmenu_agent.manual_fallback_log
catchmenu_agent.evidence_packets
catchmenu_store.device_registry (target_device_id FK)
catchmenu_integrations.okpos_order_send_log
catchmenu_integrations.toss_pos_order_log
```

### 4.3 RPCs / functions (path-relevant)

```text
-- Waiting / session
catchmenu_pos.create_order_session
catchmenu_pos.bind_table_to_session
catchmenu_pos.mark_session_arrived
catchmenu_pos.get_waiting_queue
catchmenu_pos.call_next_waiting

-- Order
catchmenu_pos.create_order
catchmenu_pos.confirm_order          ← KDS ticket INSERT
catchmenu_pos.cancel_order

-- Pre-order
catchmenu_pos.create_pre_order
catchmenu_pos.confirm_pre_order_arrival
catchmenu_pos.get_pre_order_status
catchmenu_pos.pre_order_while_waiting   (0115)

-- KDS lifecycle
catchmenu_kds.evaluate_kds_capacity
catchmenu_kds.commit_kds_ticket       ← HOLD release gate (7 conditions)
catchmenu_kds.authorize_kds_release
catchmenu_kds.start_cooking           ← READY_TO_COMMIT → COOKING
catchmenu_kds.complete_cooking
catchmenu_kds.serve_ticket
catchmenu_kds.complete_order_kds
catchmenu_kds.get_kds_realtime_state  ← pull/read model

-- Payment → KDS coupling
catchmenu_payment.confirm_payment_intent   (0027)
catchmenu_payment.confirm_payment            (0098)
catchmenu_payment.release_kds_after_payment  (0098)

-- Manual fallback
catchmenu_agent.activate_manual_fallback
catchmenu_agent.resolve_manual_fallback

-- Display
catchmenu_store.get_did_display_state
catchmenu_store.bootstrap_kds_app            (0070)
catchmenu_common.notify_channel              (0068)

-- POS integration (payment-coupled)
catchmenu_integrations.confirm_okpos_payment   (0102)
catchmenu_integrations.confirm_toss_pos_payment  (0104)
```

### 4.4 Triggers

```text
catchmenu_kds.kds_tickets : trg_kds_tickets_updated_at only
No trigger auto-creates kds_tickets on order confirm.
KDS ticket creation is explicit inside catchmenu_pos.confirm_order (0026).
```

### 4.5 Flutter / KDS screens / providers

```text
Implemented : none (README placeholder only)
Planned     : kds_screen.dart, kds_ticket_card.dart, kds_state_notifier.dart,
              kds_repository.dart — marked "Scope D 통과 후 구현"
Documented INV rules:
  - HOLD → COOKING direct transition forbidden
  - release_kds_after_payment() call forbidden from KDS UI
  - No force-release button on HOLD tickets
```

---

## 5. Core Path Diagram (Read-Only Model)

```text
[Waiting] create_order_session / get_waiting_queue (0050)
    ↓
[Cart] create_order (0026) → order_status PENDING
    ↓
[Confirm] confirm_order (0026)
    → order_status CONFIRMED
    → INSERT kds_tickets (kds_status=HOLD, payment_confirmed=false)
    → NO POS call required at this step
    ↓
[HOLD gate] commit_kds_ticket (0028) OR release_kds_after_payment (0098)
    → requires payment_confirmed=true (and other conditions)
    ↓
[Cook] start_cooking (0029) → COOKING → complete_cooking → READY → SERVED
```

---

## 6. Verification Questions

### A. Does order confirmation create KDS tickets?

**Answer: YES — without POS or payment.**

| Item | Finding |
|---|---|
| Responsible mechanism | `catchmenu_pos.confirm_order` in `0026_create_order_rpc.sql` |
| Trigger? | No DB trigger; explicit `INSERT INTO catchmenu_kds.kds_tickets` loop over `order_items` where `is_kds_required_snapshot = true` |
| Initial status | `kds_status = 'HOLD'`, `hold_reason = 'AWAITING_CONDITIONS'` |
| Initial conditions | `payment_confirmed: false`; `arrived` / `table_confirmed` set from session/table presence |
| POS required? | No — confirm_order has no OKpos/Toss POS dependency |
| POS order id / payment intent required? | No at ticket creation time |

Ledger payload on confirm explicitly records `'payment_required': true`.

### B. What releases KDS tickets from HOLD?

**Answer: Seven-condition Late Binding gate; `payment_confirmed = true` is mandatory.**

`catchmenu_kds.commit_kds_ticket` (0028) merges conditions and requires ALL of:

```text
arrived, table_confirmed, payment_confirmed, kds_capacity_ok,
menu_available, peak_time_ok, no_show_risk_ok
```

Only when all are true → `kds_status = 'READY_TO_COMMIT'`.

`conditions_met` schema comment (0016) states:

```text
payment_confirmed: payment_ledger.kds_release_authorized = true
```

`manual_fallback_activated` column on `kds_tickets` is **NOT** read by
`commit_kds_ticket`, `start_cooking`, or `release_kds_after_payment`.

**Can tickets reach COOKING / READY / COMPLETED without payment?**

```text
Via commit_kds_ticket path : NO (payment_confirmed must be true)
Via start_cooking          : Requires READY_TO_COMMIT; if payment_ledger_id
                             is set, also requires ledger.kds_release_authorized
Via release_kds_after_payment (0098): Requires payment ledger; sets
                             payment_confirmed=true — payment-coupled by design
```

Pre-order arrival (`0051 confirm_pre_order_arrival`) sets
`arrived=true` and `table_confirmed=true` but **does not** set
`payment_confirmed=true`. Comment in 0051: payment still required before queue commit.

### C. Is `manual_fallback_activated` actually wired?

**Answer: NO — field and store-level log exist; ticket release path is not connected.**

| Artifact | Role | Wired to KDS release? |
|---|---|---|
| `kds_tickets.manual_fallback_activated` column | Per-ticket flag | Never SET true in any migration SQL |
| `kds_status = 'MANUAL_FALLBACK'` | Allowed enum value | No RPC transitions tickets into this status |
| `catchmenu_agent.activate_manual_fallback` (0030) | Store-level fallback log + evidence | Writes `manual_fallback_log`; does NOT update `kds_tickets` |
| `can_override_kds` on staff (0053) | Permission flag | Exposed in bootstrap JSON only; no override RPC found |
| `kds_hold_overridden` audit type (0008) | Documented audit category | No implementing RPC found |

**Staff manual processing via system RPC:** No tested path releases HOLD tickets
without payment. Operational manual kitchen note (014280) is **outside** the KDS RPC chain.

**Test path without payment_confirmed:** None found in SQL. Theoretically a caller
could pass `payment_confirmed: true` into `commit_kds_ticket(p_conditions)` without
ledger validation — this is an **authorization gap**, not an approved pilot path,
and is not documented as MVP-1 behavior.

### D. POS manual-entry premise vs KDS auto-create — conflict?

**Answer: PARTIAL conflict — creation is decoupled; progression is payment-coupled.**

| Concern | Finding |
|---|---|
| MVP-1 manual POS entry | Supported at **policy** level (014280); not blocking ticket INSERT |
| KDS auto-create on confirm | Yes — `confirm_order` always creates HOLD tickets for KDS-required items |
| POS order id / provider id at create | Not required for ticket creation |
| POS sync pending blocks KDS INSERT? | No evidence in 0026/0013 |
| POS sync pending blocks KDS RELEASE? | Indirectly yes — release paths require payment confirmation RPCs (0098/0102/0104) that assume provider payment evidence |

POS pipelines (0102/0104) call `catchmenu_payment.confirm_payment` →
`release_kds_after_payment`. They are **payment confirm adapters**, not order-create
dependencies. Manual POS entry without payment confirmation leaves tickets in HOLD indefinitely.

### E. KDS physical delivery protocol

**Classification: DB-backed KDS pull model + optional Postgres NOTIFY; no device push layer.**

| Layer | Present? | Evidence |
|---|---|---|
| Table polling / RPC pull | YES | `get_kds_realtime_state` (0099), `bootstrap_kds_app` (0070) read `kds_tickets` |
| Supabase Realtime subscription (client) | NO client impl | Flutter KDS not built |
| HTTP push / websocket to device | NO | No edge push handler for KDS tickets found |
| Local agent / device routing | NO | `target_device_id` column exists with index; **never assigned** in inspected INSERT paths |
| `kitchen_zone` routing | Partial | Stored on ticket; read RPCs can filter; no zone→device router |
| NOTIFY broadcast | YES (DB) | `release_kds_after_payment` calls `notify_channel(..., 'KDS_TICKETS', 'kds_tickets_released', ...)` |
| `transition_kds_ticket` RPC | **MISSING** | Referenced in 0092/0113/0119 docs and 0096 validation list; **no CREATE FUNCTION** in migrations |

**Delivery verdict:** `DB-backed KDS pull model only` (+ NOTIFY hook with no consumer app).

### F. Pilot blocker classification

**Primary verdict:**

```text
FAIL_PAYMENT_COUPLED_KDS_BLOCKER
```

Rationale: MVP-1 no-payment pilot cannot reach COOKING/READY/COMPLETED through
implemented RPCs. Tickets are created on confirm but remain HOLD without payment.

**Secondary finding (independent blocker even after payment fix):**

```text
FAIL_KDS_DELIVERY_PROTOCOL_MISSING
```

Rationale: No Flutter KDS UI, missing `transition_kds_ticket`, schema drift
(`COMMITTED` used in 0098+ vs `READY_TO_COMMIT` in 0016 constraint and 0029
`start_cooking` gate), `target_device_id` unused.

**Not selected:**

```text
PASS_NO_PAYMENT_KDS_PATH_CONFIRMED        — rejected (payment blocks release)
UNKNOWN_REQUIRES_RUNTIME_TEST             — rejected (static path is conclusive;
                                              runtime test would not change SQL gate logic)
PARTIAL_PASS alone                        — insufficient; release path is confirmed blocked,
                                              not merely unconfirmed
```

---

## 7. Schema / Pipeline Drift (Read-Only Finding)

Two parallel payment→KDS pipelines coexist:

```text
Pipeline A (0027/0028/0029):
  confirm_payment_intent → conditions_met.payment_confirmed=true
  → commit_kds_ticket → READY_TO_COMMIT
  → authorize_kds_release (ledger)
  → start_cooking → COOKING

Pipeline B (0098 POS/kiosk):
  confirm_payment → release_kds_after_payment
  → kds_status='COMMITTED'   ← NOT in 0016 chk_kds_status enum
  → start_cooking expects READY_TO_COMMIT (0029)
```

`0016_create_kds_tickets.sql` `chk_kds_status` allows:
`HOLD, CAPACITY_CHECKING, READY_TO_COMMIT, COOKING, READY, SERVED, COMPLETED, CANCELLED, MANUAL_FALLBACK`
— **`COMMITTED` is absent.**

This drift is a separate implementation blocker for **any** payment path, not only
no-payment. Not fixed in this Analysis.

---

## 8. Summary Tables

### 8.1 Question → answer matrix

| Question | Answer |
|---|---|
| KDS ticket created on order confirm? | YES (confirm_order, no POS) |
| POS blocks ticket creation? | NO |
| payment_confirmed required for HOLD release? | YES |
| manual_fallback substitutes payment? | NO (not wired) |
| No-payment path to COOKING? | NO |
| KDS delivery model | DB pull + NOTIFY; no Flutter KDS |
| MVP-1 pilot blocker (no-payment kitchen)? | YES — payment-coupled |

### 8.2 End-state reachability without payment

| State | Reachable without payment? | Mechanism |
|---|---|---|
| HOLD | YES | confirm_order |
| CAPACITY_CHECKING | YES | commit_kds_ticket with partial conditions |
| READY_TO_COMMIT | NO | payment_confirmed required |
| COMMITTED (0098) | NO | release_kds_after_payment requires payment |
| COOKING / READY / COMPLETED | NO | Requires prior release + start_cooking |

---

## 9. Policy vs Implementation Gap

`014280` explicitly allows **Manual KDS / Kitchen Note** for MVP-1 when integration
is absent. That is an **operational SOP bypass**, not an automated runtime path.

Current SQL implements:

```text
Automated ticket CREATE on confirm  ✓
Automated ticket RELEASE without payment  ✗
Automated manual-fallback ticket RELEASE  ✗
KDS display client  ✗
```

Closing this gap requires a new Approval Gate and implementation track — not Scope D
mainline resume and not 604392 Group A SQL residue.

---

## 10. Approval Gate Requirement

**Finding: YES — Approval Gate required before any no-payment / manual-fallback KDS implementation.**

Recommended next document:

```text
604501_Approval_Gate_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md
```

604501 must decide (Human):

```text
1. Approve new RPC/policy for no-payment KDS release (postpaid / staff override)?
2. Wire activate_manual_fallback → kds_tickets release / MANUAL_FALLBACK status?
3. Resolve COMMITTED vs READY_TO_COMMIT schema drift before any pilot?
4. Authorize Flutter KDS client + transition_kds_ticket implementation?
5. Explicitly scope MVP-1 to manual kitchen note SOP only (no automated KDS)?
```

604501 must **not**:

```text
- Resume Scope D mainline
- Open 0069 Analysis
- Mix with 604392–604395 Group A SQL residue commits
- Authorize SQL/runtime edits without separate Implementation workpacket
```

---

## 11. Boundary Confirmation

Confirmed not performed:

```text
SQL / migration / function / trigger modification     : NO
Flutter / runtime code modification                   : NO
Test data insert / DB write                           : NO
0069 Analysis creation                                : NO
Scope D mainline resume                               : NO
604392–604395 Group A SQL residue track mixing        : NO
staging                                               : NO
commit                                                : NO
```

---

## 12. Final Analysis Result

```text
WAIT_ORDER_POS_KDS_NO_PAYMENT_PATH_REQUIRES_APPROVAL_GATE_BEFORE_IMPLEMENTATION
```

```text
Pilot blocker (no-payment kitchen progression):
  FAIL_PAYMENT_COUPLED_KDS_BLOCKER

Supplementary delivery blocker (even with payment):
  FAIL_KDS_DELIVERY_PROTOCOL_MISSING

Summary:
  - Order confirm DOES create KDS tickets in HOLD without POS/payment (A: YES).
  - HOLD release REQUIRES payment_confirmed=true; manual_fallback NOT wired (B/C: blocked).
  - POS manual entry does not block creation but does not enable release (D: conflict).
  - KDS delivery = DB pull + NOTIFY only; no Flutter KDS; transition RPC missing (E).
  - MVP-1 automated no-payment kitchen path is NOT confirmed; SOP manual note only.
  - 604501 Approval Gate required before implementation.
  - Scope D mainline and 0069 remain blocked/deferred.
```

---

## 13. Required Next Step

```text
604501_Approval_Gate_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md
```

---

## 14. Final Rule

This Analysis does not authorize runtime or SQL remediation.

If this Analysis conflicts with an approved ChangeContract or Approval, the
stricter boundary wins.

Scope D mainline and 0069 Analysis must not resume automatically from this
Analysis.
