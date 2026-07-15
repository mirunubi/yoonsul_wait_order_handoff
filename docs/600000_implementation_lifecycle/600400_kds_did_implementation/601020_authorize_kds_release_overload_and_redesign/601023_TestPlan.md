# 601023_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: TBD
Last Updated: 2026-07-15
Revision: 1

## Change ID

`authorize_kds_release_overload_and_redesign`

## 0. Verification Scope

This TestPlan verifies the Revision 3 design fixed in `601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md` and `601022_Logic_Authorize_Kds_Release_Overload_And_Redesign.md`.

The implementation is split into three slices:

| Slice | Verification target |
|---|---|
| Slice 1 | `release_kds_after_payment()` updates `payment_ledger.kds_release_authorized = true` before the `kds_tickets` `HOLD -> COMMITTED` update. |
| Slice 2 | `bulk_commit_kds_tickets()` remains unchanged and passes naturally after Slice 1; `start_cooking()` changes from fail-open to fail-closed when `payment_ledger_id` is missing. |
| Slice 3 | Both `authorize_kds_release()` overloads are dropped after their final caller count is confirmed as zero. |

This TestPlan does not authorize implementation by itself. Stage 4 may proceed only after `601024_ChangeContract.md` receives Human Boundary Approval.

## 1. Pre-Implementation Checks

### 1.1 Confirm Migration Number

Before implementation, confirm the next unused SQL migration number under `sql/migrations/`.

Expected:

- A new forward migration is used.
- No existing migration file is overwritten.

### 1.2 Confirm Approved Source Boundaries

Run:

```powershell
git status --short -- sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql sql/migrations/0029_create_kds_cooking_rpc.sql sql/migrations/0039_create_kds_bulk_commit_rpc.sql sql/migrations/0027_create_payment_intent_rpc.sql sql/migrations/0038_create_toss_webhook_processor_rpc.sql sql/migrations/0056_create_van_terminal_integration_rpc.sql
```

Expected:

- Stage 4 starts from the known approved working tree.
- `0039`, `0027`, `0038`, and `0056` are not modified by this workpacket.

### 1.3 Confirm `authorize_kds_release()` Final Caller Count Is Zero

Before Slice 3 DROP, run a final caller scan:

```powershell
rg -n "authorize_kds_release\s*\(" sql catchmenu_app -g "*.sql" -g "*.dart"
```

Expected:

- Hits are definitions, grants, comments, or this workpacket documentation only.
- No runtime SQL/Flutter caller is found.

Also confirm live overload count:

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'catchmenu_kds' AND p.proname = 'authorize_kds_release' ORDER BY args;"
```

Expected before DROP:

- Two overloads may exist:
  - 6-param version from `0028`
  - 8-param version from `0063`

## 2. Slice 1 Test: Payment Confirmation Sets Ledger Release Authorization

### 2.1 OKPOS Path

Create isolated test data in a transaction and exercise the OKPOS path through `0102`.

Required observation:

1. `0102` calls `catchmenu_payment.confirm_payment(...)`.
2. `confirm_payment()` calls `catchmenu_payment.release_kds_after_payment(...)`.
3. After that call, the corresponding `catchmenu_payment.payment_ledger` row has:

```sql
kds_release_authorized = true
kds_release_authorized_at is not null
kds_release_authorized_by = 'SYSTEM'
```

Verification query template:

```sql
select
  id,
  order_id,
  ledger_status,
  kds_release_authorized,
  kds_release_authorized_at,
  kds_release_authorized_by
from catchmenu_payment.payment_ledger
where order_id = '<test_order_id>'::uuid
order by approved_at desc nulls last, created_at desc nulls last;
```

Expected:

- At least one approved ledger row exists for the test order.
- `kds_release_authorized = true`.
- The update occurs before the associated `kds_tickets` release evidence is accepted as complete.

Rollback:

```sql
ROLLBACK;
```

### 2.2 Toss Payments Path

Repeat the same transaction-isolated test for the `0103` Toss Payments integration path.

Expected:

- The Toss Payments path reaches `confirm_payment()`.
- The created/updated ledger row has `kds_release_authorized = true`.
- KDS release behavior is not implemented separately in `0103`; it is inherited through `confirm_payment()` and `release_kds_after_payment()`.

Rollback:

```sql
ROLLBACK;
```

### 2.3 Toss POS Path

Repeat the same transaction-isolated test for the `0104` Toss POS integration path.

Expected:

- The Toss POS path reaches `confirm_payment()`.
- The created/updated ledger row has `kds_release_authorized = true`.
- KDS release behavior is not implemented separately in `0104`; it is inherited through `confirm_payment()` and `release_kds_after_payment()`.

Rollback:

```sql
ROLLBACK;
```

### 2.4 Static Confirmation for the Three Callers

Run:

```powershell
rg -n -C 5 "catchmenu_payment\.confirm_payment\(" sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql sql/migrations/0103_create_toss_payments_pipeline_rpc.sql sql/migrations/0104_create_toss_pos_pipeline_rpc.sql
```

Expected:

- Exactly the three intended integration paths call `confirm_payment()`.
- None of these three files needs direct KDS release code changes.

## 3. Slice 2 Defect 2 Test: `bulk_commit_kds_tickets()` Natural Pass

### 3.1 Gate Code Remains Unchanged

Run:

```powershell
git diff -- sql/migrations/0039_create_kds_bulk_commit_rpc.sql
```

Expected:

- No diff.

Also inspect the gate:

```powershell
Select-String -Path "sql\migrations\0039_create_kds_bulk_commit_rpc.sql" -Pattern "kds_release_authorized|kds_release_not_authorized" -Context 5,5
```

Expected gate remains:

```sql
select coalesce(bool_or(kds_release_authorized), false)
into v_payment_authorized
from catchmenu_payment.payment_ledger
where order_id = p_order_id
  and store_id = p_store_id
  and tenant_id = p_tenant_id
  and ledger_status = 'APPROVED';
```

### 3.2 Post-Slice-1 Functional Check

Immediately after each Slice 1 payment path test, call:

```sql
select catchmenu_kds.bulk_commit_kds_tickets(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_order_id := '<order_id>'::uuid,
  p_force_conditions := '{}'::jsonb,
  p_correlation_id := 'verify-601023-bulk-commit'
);
```

Expected:

- The previous `kds_release_not_authorized` failure no longer occurs for the Slice 1-confirmed payment path.
- The response reaches `success: true` or the next legitimate ticket-level condition result.
- If failure occurs, it must not be caused by `payment_ledger.kds_release_authorized = false`.

Rollback:

```sql
ROLLBACK;
```

## 4. Slice 2 Defect 3 Test: `start_cooking()` Fail-Closed

These are the four required cases from `601022_Logic.md` §2.3.

### 4.1 Case A: Normal Ledger Present And Authorized

Setup:

- Create or reuse an isolated `kds_tickets` row with:
  - `kds_status = 'COMMITTED'`
  - `payment_ledger_id` pointing to an approved `payment_ledger` row
  - `payment_ledger.kds_release_authorized = true`

Call:

```sql
select catchmenu_kds.start_cooking(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_ticket_id := '<ticket_id>'::uuid,
  p_actor_type := 'STAFF',
  p_actor_id := '<actor_id>'::uuid,
  p_correlation_id := 'verify-601023-start-cooking-authorized'
);
```

Expected:

- Existing normal behavior is preserved.
- Response succeeds.
- Ticket transitions `COMMITTED -> COOKING`.

Rollback:

```sql
ROLLBACK;
```

### 4.2 Case B: Ledger Present But Not Authorized

Setup:

- `kds_status = 'COMMITTED'`
- `payment_ledger_id is not null`
- linked `payment_ledger.kds_release_authorized = false`

Expected:

```json
{
  "success": false,
  "error_key": "kds_release_not_authorized"
}
```

This confirms the existing denial behavior is preserved.

Rollback:

```sql
ROLLBACK;
```

### 4.3 Case C: Missing Ledger ID

Setup:

- `kds_status = 'COMMITTED'`
- `payment_ledger_id is null`

Expected after Slice 2:

```json
{
  "success": false,
  "error_key": "kds_release_ledger_missing"
}
```

This is the intentional behavior change. Before Slice 2, this case would have skipped the ledger gate and proceeded toward `COOKING`.

Rollback:

```sql
ROLLBACK;
```

### 4.4 Case D: 0143 No-Payment Committed Ticket

Setup:

- Use or simulate the `release_kds_ticket_no_payment()` path:
  - `kds_status = 'COMMITTED'`
  - `conditions_met.no_payment_policy_released = true`
  - `payment_ledger_id` remains untouched by 0143 and may be null

Expected:

- If `payment_ledger_id is null`, `start_cooking()` returns:

```json
{
  "success": false,
  "error_key": "kds_release_ledger_missing"
}
```

This is an intended block under Revision 3. Cash/no-payment continuation is explicitly an Open Item, not silently allowed through `start_cooking()`.

Rollback:

```sql
ROLLBACK;
```

## 5. Slice 3 Test: Drop `authorize_kds_release()` Overloads

### 5.1 Pre-DROP Caller Count

Repeat the final caller scan immediately before applying the DROP migration:

```powershell
rg -n "authorize_kds_release\s*\(" sql catchmenu_app -g "*.sql" -g "*.dart"
```

Expected:

- Runtime callers: 0.
- Definitions/grants/comments may still exist in historical source migrations.

### 5.2 Post-DROP Live Count

After applying the new DROP migration, run:

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'catchmenu_kds' AND p.proname = 'authorize_kds_release';"
```

Expected:

```text
count = 0
```

### 5.3 Confirm Dropped Signatures

Run:

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'catchmenu_kds' AND p.proname = 'authorize_kds_release' ORDER BY args;"
```

Expected:

- No rows.

## 6. Boundary Verification

### 6.1 `confirm_payment()` Body Boundary

Run:

```powershell
git diff -- sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
```

Expected:

- Changes are limited to the `release_kds_after_payment()` function body.
- `confirm_payment()` body remains unchanged.

### 6.2 `bulk_commit_kds_tickets()` Boundary

Run:

```powershell
git diff -- sql/migrations/0039_create_kds_bulk_commit_rpc.sql
```

Expected:

- No diff.

### 6.3 Integration File Boundary

Run:

```powershell
git diff -- sql/migrations/0027_create_payment_intent_rpc.sql sql/migrations/0038_create_toss_webhook_processor_rpc.sql sql/migrations/0056_create_van_terminal_integration_rpc.sql
```

Expected:

- No diff.

### 6.4 Runtime Boundary

Run:

```powershell
git diff -- catchmenu_app
```

Expected:

- No Flutter/runtime diff from this workpacket.

### 6.5 Migration Check

Run:

```powershell
git diff --check
```

Expected:

- PASS.

## 7. Acceptance Criteria

The workpacket passes verification only if all of the following are true:

1. Slice 1: OKPOS, Toss Payments, and Toss POS paths each reach `confirm_payment()` and result in `payment_ledger.kds_release_authorized = true`.
2. Slice 2 / Defect 2: `bulk_commit_kds_tickets()` gate code is unchanged and no longer fails because of missing ledger authorization after Slice 1.
3. Slice 2 / Defect 3: `start_cooking()` rejects `payment_ledger_id is null` with `kds_release_ledger_missing`.
4. Slice 2 regression: `start_cooking()` still succeeds when the ledger exists and is authorized.
5. Slice 2 regression: `start_cooking()` still rejects a present but unauthorized ledger with `kds_release_not_authorized`.
6. Slice 3: live `authorize_kds_release()` overload count is 0.
7. Boundary: `confirm_payment()` body, `bulk_commit_kds_tickets()`, `0027`, `0038`, `0056`, Flutter/runtime code, cash/no-payment redesign, retry-function design, inventory, and membership remain untouched.

## 8. Open Items Carried Forward

The following items remain explicitly outside this TestPlan:

- `confirm_payment_from_provider()` / PG-VAN audit and KDS release behavior as a separate workpacket candidate.
- Cash/no-payment continuation path after `start_cooking()` becomes fail-closed.
- Dedicated retry/reconciliation function design.
- `COMMITTED -> COOKING` live caller gap.

