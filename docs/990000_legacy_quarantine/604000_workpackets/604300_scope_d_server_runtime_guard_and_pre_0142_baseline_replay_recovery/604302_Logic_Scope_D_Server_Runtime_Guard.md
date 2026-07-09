# 604302_Logic_Scope_D_Server_Runtime_Guard.md

Status: Draft  
Lifecycle: Logic  
Gate Classification: Scope D Master Logic Draft  
Runtime Implementation Authorization: Not Granted  
Owner: TBD  
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned **before Human Approval**. No Scope D implementation slice may proceed while Owner remains TBD.

---

## 0. Purpose

Scope D **Server Runtime Guard**의 서버 런타임 로직을 **구현 전** 설계한다.

대상:

* `confirm_payment` idempotency
* `release_kds_after_payment` guard
* payment → KDS transaction boundary
* ledger / audit / correlation evidence
* RLS / EXECUTE permission
* Toss Edge Function confirm boundary
* unknown-state handling

This logic document is not a change_contract.  
It does not authorize SQL, Edge Function, Flutter, or migration edits.  
Each implementation slice must be separately approved.

**Pseudocode policy:** All pseudocode blocks in this document are **design-only pseudocode**. Copying them into SQL, Edge Function, or migration implementation is **forbidden** without a slice-specific approved `change_contract`.

Logic companion overview: `604301_Overview_Scope_D_Server_Runtime_Guard.md`

---

## 1. Core Rule

```text
Server APPROVED payment evidence is required before KDS release.
Client UI success is not payment truth.
Client is not release authority.
Provider callback alone is not payment truth.
Unknown provider or ledger state must not be collapsed into success or failure.
```

---

## 2. Payment Confirm Idempotency Logic

### 2.1 Purpose

`confirm_payment`는 중복 호출·중복 webhook·중복 Edge callback에도 **하나의 APPROVED ledger**와 **하나의 release effect**만 남겨야 한다.

### 2.2 Inputs (logical)

| Field | Role |
| --- | --- |
| `p_tenant_id`, `p_store_id` | Tenant boundary |
| `p_order_id` | Order anchor |
| `p_provider_type` | e.g. `TOSS_PAYMENTS` |
| `p_provider_tx_id` | Provider payment key |
| `p_provider_approval_number` | Approval reference |
| `p_approved_amount` | Amount verification |
| `p_correlation_id` | Trace across confirm → release → ledger |
| `p_idempotency_key` | Optional explicit key (payment_intents.idempotency_key alignment) |

### 2.3 Idempotency Detection Order (design)

```text
1. Lookup existing payment_ledger for order_id + ledger_status = APPROVED
2. If found → return SAME success payload (not error) + kds state summary
3. Lookup existing ledger for provider_tx_id + provider_type + APPROVED
4. If found and order_id matches → same result return
5. If found and order_id conflicts → CRITICAL diagnostic + human review state (no second APPROVED)
6. If PENDING/PROCESSING exists → do not create second APPROVED; return pending/unknown
7. Only if no approved ledger → proceed insert APPROVED + release path
```

**Current repo note (`0098`):** duplicate `provider_tx_id` path returns `payment_already_confirmed` **error** in some branches. Scope D slice `604310` should align with 900102 **same result return** for idempotent success.

### 2.4 Duplicate Callback Handling

```text
Toss confirm Edge Function calls confirm_payment
Toss webhook may also arrive
Customer app may retry check_payment_status

Rules:
- Second APPROVED insert forbidden
- release_kds_after_payment must not double-commit tickets
- Return 200 with existing ledger_id + kds summary when already approved
- Log PAYMENT_DUPLICATE_IGNORED or equivalent ledger event (not silent)
```

**Same-success replay policy (strengthened, policy update 2026-07-01):**

```text
Duplicate confirm with the same effective_idempotency_key and same request_fingerprint
  must return the original terminal success payload.
It must not create duplicate payment_ledger rows.
It must not trigger duplicate KDS release.
It must not duplicate inventory, point, notification, printer, POS sync, or outbox
  side effects.
```

### 2.5 Unknown Provider Status

```text
If Toss/server verification returns:
  timeout        → do NOT insert APPROVED; mark UNKNOWN / reconciliation_required
  ambiguous      → do NOT insert APPROVED
  provider error → FAILED ledger if evidence exists; else UNKNOWN

Never:
  map timeout to FAILED without evidence
  map Toss client success to APPROVED without server verify
```

### 2.6 Pseudocode (design only — not implementation)

> **Design-only pseudocode — slice-specific approved `change_contract` 없이 구현에 전사 금지.**  
> This block is illustrative logic only. Do not copy into SQL, Edge Function, or migration without an approved slice contract.

```text
function confirm_payment(...):
  assert tenant/store/order boundary
  existing = find_approved_ledger(order_id)
  if existing:
    return build_same_success(existing, idempotent=true)

  if provider_status_unknown:
    write diagnostic + optional UNKNOWN ledger row
    return reconciliation_required

  insert payment_ledger APPROVED
  audit PAYMENT_APPROVED
  ledger_event PAYMENT_APPROVED (correlation_id)

  release_result = release_kds_after_payment(...)  // internal only
  if release_result.failed:
    mark payment_release_split_brain / recovery_required
    do NOT rollback APPROVED silently without policy

  return success with ledger_id + kds summary
```

### 2.7 Effective Idempotency Key And Request Fingerprint (Policy Update, 2026-07-01)

A design policy consolidation on `confirm_payment` integrity/idempotency/schema-drift established a stricter identity model than "provider_tx_id + correlation_id" alone:

```text
raw idempotency_key is evidence, not final authority.
effective_idempotency_key is the final duplicate-defense key.
effective_idempotency_key must be deterministic, namespaced, source-verified,
  tenant/store scoped, and non-null.
```

Recommended key source priority (highest confidence first):

```text
1. internal payment_intent_id
2. provider payment key
3. provider request row
4. VAN TID + approval number
5. adapter-derived deterministic key
6. server-derived transitional key
7. unresolved identity → reject / reconciliation_required
```

`request_fingerprint` is a separate concept from `effective_idempotency_key`:

```text
amount must not be part of effective_idempotency_key.
amount belongs to request_fingerprint.
request_fingerprint compares request content.
same effective_idempotency_key + same request_fingerprint  = same-success replay.
same effective_idempotency_key + different request_fingerprint = hard conflict.
same effective_idempotency_key + different amount           = hard reject.
```

Duplicate-confirm handling (§2.3 above) is superseded in spirit by this model: the detection order should resolve an `effective_idempotency_key` first, then compare `request_fingerprint`, rather than branching directly on `provider_tx_id` presence. Exact SQL/implementation shape is a slice-level decision (`604310`'s own Logic document), not decided here.

### 2.8 Correlation ID Is Trace, Not Identity (Policy Update, 2026-07-01)

```text
p_correlation_id is a trace value.
p_correlation_id is not the final idempotency key.
p_correlation_id null must not be rejected solely for that reason.
The system must resolve a non-null effective_idempotency_key from stronger identity
  evidence when available (see §2.7 priority list).
If identity cannot be resolved or is weak, route to reconciliation_required or
  pending_confirm — not to a hard reject purely because correlation_id was absent.
```

This replaces any prior framing (in this document or any slice document) that treated `p_correlation_id is null` as sufficient grounds by itself to reject a `confirm_payment` call.

### 2.9 Amount Mismatch Is A Hard Integrity Failure (Policy Update, 2026-07-01)

```text
Amount mismatch is a hard payment integrity failure.
It must not be warning-only.
It must block APPROVED ledger insert.
It must block the payment_confirmed event.
It must block KDS release.
It must trigger cancel_required or reconciliation_required evidence where applicable.
```

MVP default tolerance:

```text
Default MVP tolerance = 0 KRW.
Provider-specific tolerance is not introduced without separate approval.
```

This supersedes the current repo's ±10 KRW tolerance (`0098` L268–269) as the **design target**. The current repo behavior remains unchanged until a slice-level implementation is approved; this section states the policy target, not an executed change.

### 2.10 Weak Identity Reconciliation (Policy Update, 2026-07-01)

```text
When effective_idempotency_key cannot be resolved with sufficient confidence
  (§2.7 priority tiers 6–7), the system must not guess.
Route to reconciliation_required or pending_confirm instead of proceeding to APPROVED
  or instead of a hard reject that could discard a legitimate payment.
This applies symmetrically to duplicate detection (§2.3/§2.7) and to correlation_id
  absence (§2.8) — both are "weak identity" cases handled the same way.
```

---

## 3. KDS Release Guard Logic

### 3.1 Purpose

`release_kds_after_payment`는 **SYSTEM-only** 내부 함수로, APPROVED payment evidence가 있을 때만 `HOLD → COMMITTED`를 수행한다.

### 3.2 Preconditions

```text
REQUIRED:
  payment_ledger.id = p_ledger_id exists
  payment_ledger.ledger_status = APPROVED
  payment_ledger.order_id = p_order_id
  tenant_id / store_id match

FORBIDDEN:
  ledger_status = PENDING | FAILED | UNKNOWN
  no ledger row
  client role direct call (after 604350)
```

### 3.3 Transition Rule

```text
UPDATE kds_tickets
SET kds_status = 'COMMITTED', ...
WHERE order_id = p_order_id
  AND kds_status = 'HOLD'
```

| Outcome | Meaning |
| --- | --- |
| `released_count > 0` | Normal release |
| `released_count = 0` and tickets already COMMITTED | **Idempotent no-op** (success, log INFO) |
| `released_count = 0` and no tickets | WARNING diagnostic; may be valid if no preorder KDS |
| HOLD exists but update blocked | ERROR / recovery_required |

### 3.4 Forbidden Paths

```text
- Flutter / authenticated client direct EXECUTE (target state after 604350)
- KDS UI calling release
- seat_waiting_customer() internal release
- call_waiting_customer() internal release
- HOLD → COOKING direct skip
```

### 3.5 Current Repo Baseline

`sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`:

* `release_kds_after_payment` uses `WHERE kds_status = 'HOLD'` — INV-005 aligned for release side
* **GRANT EXECUTE TO authenticated** — must be removed/restricted in Scope D `604350`

---

## 4. Payment To KDS Transaction Boundary

### 4.1 Allowed Connection Path

```text
[Edge / Webhook / Staff-approved server path]
        ↓
confirm_payment()          -- only entry that may trigger release
        ↓ (internal PL/pgSQL call, same transaction preferred)
release_kds_after_payment()
        ↓
kds_tickets HOLD → COMMITTED
        ↓
ledger / audit events
```

### 4.2 Forbidden Connection Paths

```text
Flutter → release_kds_after_payment()     FORBIDDEN
Flutter → confirm_payment() without verify FORBIDDEN (except approved staff/server actor)
KDS UI  → release                         FORBIDDEN
Seat/Call RPC → release                   FORBIDDEN
```

### 4.3 Ordering

```text
1. Verify payment with provider (Edge) OR trusted staff capture path
2. Insert/confirm APPROVED in payment_ledger
3. Release KDS (internal)
4. Emit audit + ledger events
5. Return unified response to caller
```

Payment approval **precedes** KDS release. Never reverse.

### 4.4 Partial Failure Handling

| Scenario | Server state | Client/UI hint |
| --- | --- | --- |
| APPROVED written, release failed | `payment_release_split_brain` / recovery_required | “Payment confirmed; kitchen sync pending” |
| Release ok, audit write failed | CRITICAL; do not hide | reconciliation + alert |
| Confirm unknown, release not attempted | UNKNOWN payment | No complete UI |
| Duplicate confirm | Same APPROVED result | Idempotent UI |

### 4.5 Transaction Boundary (design intent)

```text
Prefer single DB transaction for:
  APPROVED insert + release update + critical audit

If release must be async (future):
  APPROVED remains truth
  release job idempotent with ledger_id key
  unknown until release confirms
```

### 4.6 Transactional Outbox / Side-Effect Separation (Direction, Policy Update 2026-07-01 — Not Authorized For Implementation)

```text
Durable decision is synchronous: the APPROVED payment_ledger write is the one thing
  that must commit transactionally before anything else is considered true.
KDS release, inventory, point, notification, printer, POS sync, and cancel API should,
  as a future direction, become post-commit idempotent consumers rather than being
  invoked synchronously inside confirm_payment's own transaction.
```

This is a design direction, not a decision executed by this document or authorized for any Scope D sub-workpacket today. The current repo behavior — `confirm_payment` calling `release_kds_after_payment` synchronously in the same call (`0098` L348–356) — remains the as-built baseline described elsewhere in this document (§4.1, §4.3) and is not changed by this note. No sub-workpacket may implement an outbox pattern under this Logic document; that would require its own future change_contract and Human Approval.

---

## 5. Ledger / Audit / Evidence Logic

### 5.1 INV-006 Requirements

Every handoff-related transition should produce evidence with:

```text
event_id / correlation_id
tenant_id, store_id
order_id, session_id (nullable)
kds_ticket_id (nullable)
actor_type, actor_id
device_surface / pipeline
event_type
before_state, after_state
result, failure_reason (nullable)
idempotency_key (nullable)
created_at
```

### 5.2 Event Types (Scope D minimum)

The event types below are **proposed design names** for Scope D. They are **not present** in `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` or the current ledger event contract as shipped.

| Event | When |
| --- | --- |
| `PAYMENT_APPROVED` | APPROVED ledger committed |
| `PAYMENT_DUPLICATE_IGNORED` | Duplicate confirm safely ignored |
| `PAYMENT_UNKNOWN` | Provider/ledger uncertain |
| `KDS_RELEASED_AFTER_PAYMENT` | HOLD → COMMITTED |
| `KDS_RELEASE_SKIPPED_IDEMPOTENT` | Already COMMITTED |
| `KDS_RELEASE_FAILED` | APPROVED but release error |
| `PAYMENT_RELEASE_SPLIT_BRAIN` | Mismatch needing recovery |

**Introduction rule:** before implementation, each proposed event must be **mapped to the existing event contract** in the relevant `test_plan` and `change_contract`, or introduced only through a **separately approved sub-workpacket** (typically `604340_scope_d_04_ledger_evidence_correlation`). Do not assume these names exist in production schema or `0098` until mapping is approved.

### 5.3 Correlation Strategy

```text
correlation_id generated at Edge or first server entry
passed to confirm_payment(p_correlation_id)
passed to release_kds_after_payment(p_correlation_id)
stored in catchmenu_ledger.events and catchmenu_audit records
Flutter RpcCaller correlation_id is separate dev trace; server correlation is authoritative for financial audit
```

### 5.4 Dev vs Prod Evidence

| Layer | Prod | Dev |
| --- | --- | --- |
| Financial truth | `catchmenu_ledger.events` | same |
| Audit | `catchmenu_audit.append_audit_record` | same |
| Flutter RPC trace | N/A | `catchmenu_dev.write_audit_log` (0136) |

---

## 6. RLS / Permission Logic

### 6.1 Design Intent

```text
authenticated role:
  MAY: register_waiting, get_payment_status, customer-safe reads
  MAY NOT: release_kds_after_payment
  MAY NOT: direct UPDATE payment_ledger
  MAY NOT: direct UPDATE kds_tickets to COMMITTED

service_role / security definer internal:
  confirm_payment, release (internal), webhook processors
```

### 6.2 Current Gap

`0098` end-of-file grants:

```text
GRANT EXECUTE ON release_kds_after_payment TO authenticated;
```

Scope D **604350** must:

```text
REVOKE EXECUTE ON release_kds_after_payment FROM authenticated;
RETAIN internal definer call from confirm_payment only;
Document service_role path for Edge Functions;
Add dry-run test: authenticated direct call fails
```

### 6.3 Tenant / Store Boundary

All RPCs must validate:

```text
p_tenant_id matches order / ledger / ticket rows
p_store_id matches order / ledger / ticket rows
RLS policies on payment_ledger, kds_tickets, order_sessions remain enforced for direct table access
```

---

## 7. Edge Function / Toss Confirm Boundary

### 7.1 Planned Functions (900102 / 0119)

| Function | Role |
| --- | --- |
| `toss-payments-confirm` | Client payment success → **server verify Toss** → `confirm_payment` |
| `toss-payments-webhook` | Signed webhook → dedupe → `confirm_payment` / webhook RPC |

**Repo status:** Edge Function **source not present** under `supabase/functions/`. Config seeds exist in `0119`.

### 7.2 Edge Logic Rules

```text
1. Toss Payments server API verification required
2. On verify success → confirm_payment(...)
3. On verify fail → record FAILED, never release
4. On timeout → UNKNOWN, no APPROVED
5. Duplicate webhook orderId → idempotent confirm path
6. Never call release_kds_after_payment directly from Edge (only via confirm_payment)
```

### 7.3 Toss UI vs Server

```text
Toss widget onSuccess     → Edge confirm request (pending)
Edge verify + confirm     → APPROVED truth
Flutter complete screen   → only after server APPROVED response
```

Aligns with DROP-E (`900121`) and Scope A prohibitions (`900102`).

---

## 8. Unknown-State Handling

### 8.1 States (server-side)

| State | Meaning | UI (Scope A later) |
| --- | --- | --- |
| `PENDING` | Awaiting provider | “Confirming payment…” |
| `UNKNOWN` | Cannot determine | “Checking payment status…” |
| `APPROVED` | Ledger truth | Safe complete path |
| `FAILED` | Evidence-backed fail | Retry / support |
| `reconciliation_required` | Human/system reconcile | No finality |

### 8.2 Scenarios

| Scenario | Handling |
| --- | --- |
| Provider timeout | No APPROVED; UNKNOWN event; poll/reconcile |
| Toss success, server pending | Poll; DROP-E recovery |
| Ledger write uncertain | Do not send success to client; reconciliation |
| Release retry | Idempotent release; log skipped if COMMITTED |
| Payment approved, release failed | Split-brain flag; manual kitchen path per runbook |
| Webhook late after timeout | Reconcile; idempotent confirm |

### 8.3 Prohibited

```text
Collapse UNKNOWN → SUCCESS for customer promise
Collapse UNKNOWN → FAILED without evidence
Silent retry release without idempotency check
```

---

## 9. Required Tests

Scope D closeout must map to `900103` and sub-workpacket test plans.

| Test | Intent |
| --- | --- |
| duplicate confirm | Second confirm returns same result; one APPROVED |
| duplicate callback | Webhook + confirm race → one release |
| already approved payment | Idempotent success path |
| pending payment no release | No COMMITTED without APPROVED |
| unknown payment no release | UNKNOWN blocks release |
| release already committed | Second release no-op |
| client forbidden release | authenticated EXECUTE denied (post-604350) |
| RLS direct-call block | Client cannot UPDATE ledger/kds to cheat state |
| ledger event exists | INV-006 PAYMENT_APPROVED + KDS_RELEASED |
| correlation_id exists | Same id across confirm/release events |
| rollback/retry behavior | Defined for split-brain, not silent data loss |
| payment approved but release retry | Idempotent; eventual COMMITTED or explicit failure |

Verification commands (from 900103):

```text
grep -r "release_kds_after_payment" lib/           → client .rpc() call 0
grep -r "release_kds_after_payment" supabase/functions/ → Edge only (when added)
SQL integration tests in 0098 / dedicated test migration (604370)
```

---

## 10. Prohibited Behavior

```text
- Flutter calling release_kds_after_payment
- Toss success UI alone → payment complete
- KDS release on PENDING / UNKNOWN payment
- Duplicate callback creating duplicate APPROVED ledger
- Unknown state forced to success or failure
- State transition without audit/ledger evidence
- RLS / GRANT bypass for convenience
- Broad refactor of unrelated migrations
- Implementing entire Scope D in one Codex pass
- Modifying existing migration files in place (900102: new patch files only)
- seat/call RPC triggering release
- HOLD → COOKING without COMMITTED
```

---

## 11. Sub-Workpacket Logic Split

구현 로직은 아래 순서로 **분리 승인**한다.

| Order | Workpacket | Logic focus |
| --- | --- | --- |
| 1 | `604400_scope_d_01_payment_confirm_idempotency` | §2 confirm idempotency |
| 2 | `604320_scope_d_02_kds_release_guard` | §3 release guard, HOLD-only |
| 3 | `604330_scope_d_03_payment_to_kds_transaction_boundary` | §4 confirm→release coupling |
| 4 | `604340_scope_d_04_ledger_evidence_correlation` | §5 INV-006 events |
| 5 | `604350_scope_d_05_rls_security_dry_run` | §6 REVOKE/GRANT |
| 6 | `604360_scope_d_06_edge_function_toss_confirm_boundary` | §7 Edge verify |
| 7 | `604370_scope_d_07_integration_test_and_unknown_state` | §8–§9 tests |
| 8 | `604380_scope_d_08_scope_d_closeout_audit` | Full Scope D gate checklist |

**604330 boundary overlap note:** `604330` shares function/file boundaries with `604310` (`confirm_payment`) and `604320` (`release_kds_after_payment`). Slice `impact_scope.md` and Human Approval must define non-overlapping file ownership before implementation to avoid duplicate or conflicting edits.

Each slice produces its own:

```text
owner (required before Human Approval; TBD blocks slice start)
impact_scope.md
change_contract (D-xx)
test_plan excerpt
implementation_approval
verification log
audit packet
```

---

## 12. Source References

| Category | Path |
| --- | --- |
| Change contract | `docs/900000_patent_and_handoff_package/900102_…` |
| Test plan | `docs/900000_patent_and_handoff_package/900103_…` |
| Handoff logic | `docs/900000_patent_and_handoff_package/900101_…` |
| Ch2 session | `docs/900000_patent_and_handoff_package/900121_…` |
| Payment confirm RPC | `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` |
| Payment ledger DDL | `sql/migrations/0014_create_payment_ledger.sql` |
| Edge config | `sql/migrations/0119_create_edge_function_integration.sql` |
| Dev audit | `sql/migrations/0136_create_dev_audit_log.sql` |
| Flutter guard | `catchmenu_app/lib/core/supabase/rpc_caller.dart` |
| AI pipeline | `docs/600000_implementation_lifecycle/600100_readme_governance/600179_…` |
| Flutter MVP logic | `604102_Logic_Flutter_MVP_Core_Implementation.md` |

---

## 13. Final Rule

```text
Scope D logic is correct when the server alone can prove:
  APPROVED payment existed before KDS COMMITTED,
  duplicate paths return safe idempotent results,
  unknown states remain visible,
  evidence and correlation_id reconstruct the handoff,
  and no client or UI shortcut can become release authority.
```
