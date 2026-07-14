# 600823_TestPlan_Did_Display_State_Overload.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude chat role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`did_display_state_overload_and_legacy_defect`

## 0. Test Scope

This TestPlan verifies the approved Stage 1.5 design from:

- `600821_Overview_Did_Display_State_Overload.md`
- `600822_Logic_Did_Display_State_Overload.md`

Confirmed implementation direction:

- Drop the legacy 0043 3-param overload:
  `catchmenu_store.get_did_display_state(uuid, uuid, uuid)`
- Preserve the 0117 4-param canonical overload:
  `catchmenu_store.get_did_display_state(uuid, uuid, uuid, text)`
- Do not edit `0043_create_did_display_rpc.sql`.
- Do not edit `0117_create_did_pipeline_rpc.sql`.
- Implement by a new forward migration only.

## 1. Pre-Implementation Baseline Verification

### 1.1 Confirm current overload count is 2

Run before the DROP migration:

```sql
select
  count(*) as overload_count
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname = 'get_did_display_state';
```

Expected before implementation:

```text
overload_count = 2
```

### 1.2 Confirm current signatures

```sql
select
  pg_get_function_identity_arguments(p.oid) as identity_args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname = 'get_did_display_state'
order by p.pronargs, identity_args;
```

Expected before implementation:

```text
p_tenant_id uuid, p_store_id uuid, p_device_id uuid
p_tenant_id uuid, p_store_id uuid, p_did_id uuid, p_locale text
```

## 2. Post-DROP Overload Verification

After applying the new forward migration, run:

```sql
select
  count(*) as overload_count
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname = 'get_did_display_state';
```

Expected:

```text
overload_count = 1
```

Then verify the remaining signature:

```sql
select
  pg_get_function_identity_arguments(p.oid) as identity_args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname = 'get_did_display_state';
```

Expected remaining canonical signature:

```text
p_tenant_id uuid, p_store_id uuid, p_did_id uuid, p_locale text
```

PASS condition:

- Exactly one overload remains.
- The remaining overload is the 0117 4-param `p_did_id` + `p_locale` function.
- The legacy 0043 3-param `p_device_id` overload no longer exists.

## 3. Canonical Named-Argument Call Test

Reproduce the same call shape used by `bootstrap_did_app()` in `0117_create_did_pipeline_rpc.sql`:

```sql
begin;

select catchmenu_store.get_did_display_state(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_did_id := '66666666-6666-6666-6666-666666666666'::uuid,
  p_locale := 'ko'
);

rollback;
```

Expected:

- No `is not unique` overload ambiguity.
- No call into the legacy 0043 3-param function.
- Function resolves to the 0117 4-param canonical implementation.
- A normal JSON response is returned. With nonexistent dummy data, an empty/default state response is acceptable if the function itself completes.

PASS condition:

- The function call completes without overload ambiguity.
- The returned JSON follows the 0117 canonical response shape.

## 4. Positional 3-Argument Call Rejection Test

Run after the DROP migration:

```sql
select catchmenu_store.get_did_display_state(
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  null::uuid
);
```

Expected:

- The previous `"is not unique"` ambiguity error must disappear.
- Because the 3-param function has been dropped, a 3-argument positional call must no longer resolve to a legacy implementation.
- Acceptable expected failure class:
  `function catchmenu_store.get_did_display_state(uuid, uuid, uuid) does not exist`
  or equivalent parameter-count mismatch resolution failure.

PASS condition:

- No `"is not unique"` error.
- No 0043 nested aggregate error.
- The call fails because no 3-param function exists.

## 5. `bootstrap_did_app()` E2E Test

Run an E2E test through the actual caller path in `0117_create_did_pipeline_rpc.sql`.

### 5.1 Test setup

Use a transaction and roll back all test data:

```sql
begin;

-- Create or reuse a dummy tenant/store/device fixture only inside this transaction.
-- Insert the minimum required rows for bootstrap_did_app() to locate a DID device.
-- Exact fixture columns must be based on the live table definitions.

select catchmenu_store.bootstrap_did_app(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_device_code := '<test_device_code>',
  p_locale := 'ko'
);

rollback;
```

Expected:

- `bootstrap_did_app()` calls `get_did_display_state()` with named arguments:
  `p_tenant_id`, `p_store_id`, `p_did_id`, `p_locale`.
- The call resolves to the remaining 0117 4-param canonical overload.
- No overload ambiguity occurs.
- No legacy 0043 nested aggregate error occurs.

PASS condition:

- The E2E bootstrap path succeeds to the extent allowed by the dummy fixture.
- If the fixture is incomplete, the failure must be a normal business/fixture error, not overload ambiguity and not 0043 nested aggregate failure.

## 6. Static Boundary Verification

After implementation, run:

```powershell
git diff -- sql/migrations/0043_create_did_display_rpc.sql
git diff -- sql/migrations/0117_create_did_pipeline_rpc.sql
git diff -- sql/migrations/0154_drop_get_did_display_state_legacy_overload.sql
```

Expected:

- `0043_create_did_display_rpc.sql`: no diff.
- `0117_create_did_pipeline_rpc.sql`: no diff.
- New migration file only contains the approved `drop function if exists` statement for the 3-param signature, plus header comments.

Also verify no unrelated SQL files changed:

```powershell
git diff --name-only -- sql/migrations
```

Expected:

- Only the new forward migration appears for this workpacket.

## 7. Approval Criteria

This workpacket passes verification only if all of the following hold:

1. Legacy 0043 3-param overload is removed from the live DB.
2. Exactly one `get_did_display_state()` overload remains.
3. Remaining overload is the 0117 4-param canonical function.
4. `bootstrap_did_app()`-style named call works without ambiguity.
5. Positional 3-arg call no longer produces `"is not unique"` and no longer reaches the 0043 nested aggregate defect.
6. `0043` and `0117` source files are untouched.
7. The implementation is a forward migration only.

## 8. Known Out-of-Scope Items

- `mark_payment_uncertain()` overload cleanup.
- `authorize_kds_release()` overload cleanup.
- `mark_no_show()` overload cleanup.
- Redesigning or repairing the old 0043 store-level operational summary concept.
- Adding a replacement function for 0043 under a new name.
- Editing `bootstrap_did_app()`.
- Editing DID display queue schema.
