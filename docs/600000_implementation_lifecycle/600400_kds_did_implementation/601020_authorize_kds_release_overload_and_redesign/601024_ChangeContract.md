# 601024_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: TBD
Last Updated: 2026-07-15
Revision: 1

## Change ID

`authorize_kds_release_overload_and_redesign`

## Authority

- `601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md`
- `601022_Logic_Authorize_Kds_Release_Overload_And_Redesign.md`
- `601023_TestPlan.md`

This ChangeContract captures the Revision 3 final design:

1. Slice 1: add `payment_ledger.kds_release_authorized = true` update inside `release_kds_after_payment()` before the `kds_tickets` update.
2. Slice 2: keep `bulk_commit_kds_tickets()` unchanged and verify natural pass; convert `start_cooking()` from fail-open to fail-closed for missing `payment_ledger_id`.
3. Slice 3: drop both `authorize_kds_release()` overloads.

## 1. Allowed Files

### 1.1 SQL Source Files

Only the following existing SQL migration files may be edited:

| File | Allowed scope |
|---|---|
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | `catchmenu_payment.release_kds_after_payment(...)` function body only. |
| `sql/migrations/0029_create_kds_cooking_rpc.sql` | `catchmenu_kds.start_cooking(...)` function body only. |

### 1.2 New Forward Migration

One new SQL migration may be created using the next unused migration number.

Required content:

- Re-declare `release_kds_after_payment()` with the Slice 1 ledger update.
- Re-declare `start_cooking()` with the Slice 2 fail-closed guard.
- Drop both `authorize_kds_release()` overloads:

```sql
drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
);

drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text, text, text
);
```

If the project implementation convention requires source file in-place alignment plus forward migration, the existing source files listed in §1.1 and the new migration must remain semantically identical for the affected function bodies.

### 1.3 Changelog

`sql/migrations/CHANGELOG.md` may be appended only if the project migration convention requires recording the new migration.

No existing changelog entries may be rewritten.

## 2. Required Implementation Details

### 2.1 Slice 1: `release_kds_after_payment()`

Inside `catchmenu_payment.release_kds_after_payment(...)`, add this ledger update after the capacity check and before the `with released as (...) update catchmenu_kds.kds_tickets` block:

```sql
update catchmenu_payment.payment_ledger
set
  kds_release_authorized = true,
  kds_release_authorized_at = now(),
  kds_release_authorized_by = 'SYSTEM'
where id = p_ledger_id
  and tenant_id = p_tenant_id
  and store_id = p_store_id;
```

Required invariants:

- The update must be inside `release_kds_after_payment()`.
- It must execute before the `kds_tickets` `HOLD -> COMMITTED` update.
- `confirm_payment()` itself must not be edited.
- The function signature must not change.

### 2.2 Slice 2: `bulk_commit_kds_tickets()`

`catchmenu_kds.bulk_commit_kds_tickets(...)` must not be edited.

The existing gate remains the intended gate:

```sql
select coalesce(bool_or(kds_release_authorized), false)
from catchmenu_payment.payment_ledger
where order_id = p_order_id
  and store_id = p_store_id
  and tenant_id = p_tenant_id
  and ledger_status = 'APPROVED';
```

Slice 1 is expected to make this existing gate pass naturally for the `confirm_payment()` path.

### 2.3 Slice 2: `start_cooking()`

Inside `catchmenu_kds.start_cooking(...)`, replace the current fail-open structure:

```sql
if v_ticket.payment_ledger_id is not null then
  ...
end if;
```

with a fail-closed structure:

```sql
if v_ticket.payment_ledger_id is null then
  return jsonb_build_object(
    'success', false,
    'error_key', 'kds_release_ledger_missing',
    'message', 'payment_ledger_id is null; ticket has no linked payment record'
  );
end if;

if not exists (
  select 1
  from catchmenu_payment.payment_ledger
  where id = v_ticket.payment_ledger_id
    and kds_release_authorized = true
) then
  return jsonb_build_object(
    'success', false,
    'error_key', 'kds_release_not_authorized',
    'message', 'payment_ledger.kds_release_authorized must be true'
  );
end if;
```

Required invariants:

- Existing authorized-ledger success behavior must remain.
- Existing unauthorized-ledger failure behavior must remain.
- Missing-ledger behavior must change from implicit pass to explicit `kds_release_ledger_missing`.
- No cash/no-payment replacement path may be invented in this workpacket.

### 2.4 Slice 3: Drop `authorize_kds_release()`

The new migration must drop both overloads:

- 6-param overload from `0028`
- 8-param overload from `0063`

No source edit to `0028` or `0063` is allowed.

## 3. Forbidden Files And Operations

### 3.1 Forbidden SQL Files

Do not edit:

- `sql/migrations/0039_create_kds_bulk_commit_rpc.sql`
- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`
- `sql/migrations/0056_create_van_terminal_integration_rpc.sql`
- `sql/migrations/0028_create_kds_capacity_commit_rpc.sql`
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
- Any inventory, membership, CMS, DID, or unrelated migration file.

### 3.2 Forbidden Function Bodies

Do not edit:

- `confirm_payment()` body in `0098`
- `bulk_commit_kds_tickets()` gate code in `0039`
- `confirm_payment_from_provider()` in `0027`
- Toss webhook / VAN caller logic in `0038` or `0056`
- `release_kds_ticket_no_payment()` in `0143`

### 3.3 Forbidden Design Expansions

Do not implement:

- Cash payment path.
- No-payment continuation path after fail-closed `start_cooking()`.
- Retry/reconciliation function.
- PG/VAN audit hardening.
- `confirm_payment_from_provider()` redesign.
- New status values or schema changes outside the approved ledger fields already present.
- Flutter/runtime changes.

## 4. Required Verification

Stage 4 must run `601023_TestPlan.md` in full.

Minimum required verification:

1. Slice 1: OKPOS, Toss Payments, and Toss POS paths each confirm `payment_ledger.kds_release_authorized = true`.
2. Slice 2: `bulk_commit_kds_tickets()` remains unchanged and passes naturally after Slice 1.
3. Slice 2: `start_cooking()` passes with authorized ledger.
4. Slice 2: `start_cooking()` rejects unauthorized ledger with `kds_release_not_authorized`.
5. Slice 2: `start_cooking()` rejects missing ledger with `kds_release_ledger_missing`.
6. Slice 2: 0143-created/no-payment committed ticket is intentionally blocked if it lacks a ledger.
7. Slice 3: live `authorize_kds_release()` count is 0 after DROP.
8. Boundary: forbidden files and domains remain untouched.

## 5. Open Items Carried Forward

The following Open Items from `601022_Logic.md` §5 remain outside this ChangeContract:

### 5.1 `confirm_payment_from_provider()` / PG-VAN Audit Requirements

`confirm_payment_from_provider()` (`0027`) and the Toss/VAN integration paths are a separate pipeline from `confirm_payment()` / `release_kds_after_payment()`.

The following must be handled in a separate workpacket if needed:

- PG/VAN append-only audit requirements.
- Provider payload preservation.
- Provider reference number, amount, and timestamp traceability.
- KDS release behavior for the `0027` path.

### 5.2 Cash / No-Payment Path

Cash payment and no-payment continuation after `start_cooking()` becomes fail-closed remain unresolved.

This ChangeContract does not define a cash ledger path, a `CASH_CONFIRMED` path, or an alternate no-payment cooking release path.

### 5.3 Retry / Reconciliation Function

The concrete retry/reconciliation function signature and SQL body are not defined here.

The eight retry-condition checklist remains design input for a future workpacket only.

### 5.4 `COMMITTED -> COOKING` Caller Gap

The fact that `start_cooking()` currently has no live caller remains an Open Item.

This ChangeContract changes the gate behavior inside `start_cooking()` but does not create or wire a caller.

## 6. Human Boundary Approval

Implementation must not begin until all three Slice approvals are checked by the Human owner.

☑ Slice 1 approved: release_kds_after_payment()가 KDS 티켓 릴리즈 이전에 payment_ledger.kds_release_authorized = true를 갱신할 수 있다.
☑ Slice 2 approved: bulk_commit_kds_tickets()는 변경하지 않고, start_cooking()은 fail-open에서 fail-closed(kds_release_ledger_missing)로 전환할 수 있다.
☑ Slice 3 approved: authorize_kds_release()의 두 오버로드를 새 forward migration에서 DROP할 수 있다. (승인날짜 : 2026 - 07 - 15)

## 7. Expected Implementation Result

Expected result after approved Stage 4 implementation and Stage 5 verification:

```text
PAYMENT_LEDGER_KDS_RELEASE_AUTHORIZATION_RESTORED_FOR_CONFIRM_PAYMENT_PATH
BULK_COMMIT_GATE_NATURALLY_PASSES_WITHOUT_GATE_REWRITE
START_COOKING_FAIL_CLOSED_ON_MISSING_LEDGER
AUTHORIZE_KDS_RELEASE_LEGACY_OVERLOADS_DROPPED
```

## 8. Non-Approval Statement

This draft does not itself approve implementation.

Until the Human Boundary Approval checkboxes in §6 are checked, Stage 4 must stop.

