# 601013_TestPlan_Cms_Device_Registry_Edid_Mapping.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude chat role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`cms_device_registry_edid_mapping`

## Authority

- `601011_Overview_Cms_Device_Content_Routing_Architecture.md`
- `601012_Logic_Cms_Device_Registry_Edid_Mapping.md`(최종 확정 — 옵션 3, §1/§3 설계 채택)

## 0. Test Scope

Confirmed implementation direction (`601012_Logic.md` §1/§2/§3):

- Add 4 columns to `catchmenu_store.did_devices`: `edid_serial text`, `last_detected_edid text`, `last_edid_check_at timestamptz`, `physical_position_label text`.
- Create 2 new functions: `catchmenu_store.get_did_device_by_edid(p_tenant_id, p_store_id, p_edid_serial, p_locale default 'ko')` and `catchmenu_store.report_did_device_edid_scan(p_tenant_id, p_store_id, p_device_id, p_detected_edid, p_correlation_id default null)`.
- **Do not edit `0043_create_did_display_rpc.sql`** — Option 3 confirmed, `update_did_display()` stays untouched, its correction (Option 1) is deferred to a separate future workpacket.
- Do not edit `0117_create_did_pipeline_rpc.sql`, `device_registry` schema, or any content-delivery-engine (Stage C) logic.
- Implement by a new forward migration only.

## 1. Pre-Implementation Baseline Verification

### 1.1 Confirm the 4 columns do not yet exist

```sql
select column_name from information_schema.columns
where table_schema = 'catchmenu_store' and table_name = 'did_devices'
  and column_name in ('edid_serial', 'last_detected_edid', 'last_edid_check_at', 'physical_position_label');
```

Expected before implementation: 0 rows.

### 1.2 Confirm the 2 functions do not yet exist

```sql
select proname from pg_proc
where pronamespace = 'catchmenu_store'::regnamespace
  and proname in ('get_did_device_by_edid', 'report_did_device_edid_scan');
```

Expected before implementation: 0 rows.

## 2. Post-Migration Schema Verification

After applying the new forward migration:

```sql
select column_name, data_type, is_nullable from information_schema.columns
where table_schema = 'catchmenu_store' and table_name = 'did_devices'
  and column_name in ('edid_serial', 'last_detected_edid', 'last_edid_check_at', 'physical_position_label')
order by column_name;
```

Expected: 4 rows — `edid_serial text`, `last_detected_edid text`, `last_edid_check_at timestamptz`, `physical_position_label text`, all nullable (existing rows have no EDID data yet, so `NOT NULL` would break them; nullability is a required design constraint, not merely convenient).

```sql
select proname, pg_get_function_identity_arguments(oid) from pg_proc
where pronamespace = 'catchmenu_store'::regnamespace
  and proname in ('get_did_device_by_edid', 'report_did_device_edid_scan')
order by proname;
```

Expected: exactly 2 rows, matching `601012_Logic.md` §3.1/§3.2 signatures.

## 3. Functional Test — `get_did_device_by_edid()`

All tests in this section run inside `BEGIN ... ROLLBACK` with dummy fixture data; nothing is permanently written.

### 3.1 Setup

```sql
begin;

insert into catchmenu_store.did_devices (
  tenant_id, store_id, did_code, did_name, zone, display_mode, edid_serial, physical_position_label
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'TEST-EDID-001', 'Test EDID Device', 'WAITING_AREA', 'WAITING',
  'MFG001:PROD042:SERIAL9001', '홀 입구 좌측 사이니지'
) returning id \gset fixture_
```

### 3.2 Registered EDID lookup — expect success

```sql
select catchmenu_store.get_did_device_by_edid(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_edid_serial := 'MFG001:PROD042:SERIAL9001'
);
```

Expected:

- `success: true`.
- Returned `device_id` matches the fixture's `id`.
- `physical_position_label` in the response equals `'홀 입구 좌측 사이니지'`.
- `display_mode`/`zone` present and match the fixture.

### 3.3 Unregistered EDID lookup — expect `edid_not_registered`

```sql
select catchmenu_store.get_did_device_by_edid(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_edid_serial := 'MFG999:PROD999:SERIAL0000'
);
```

Expected: `success: false`, `error_key: 'edid_not_registered'` (or the exact key name chosen at implementation time — TestPlan requires *a* stable, documented error key, not this literal string if the implementer picks a different but equally clear one; any deviation must be reflected back into `601012_Logic.md` §3.1).

```sql
rollback;
```

## 4. Functional Test — `report_did_device_edid_scan()`

### 4.1 Setup (fresh transaction)

```sql
begin;

insert into catchmenu_store.did_devices (
  tenant_id, store_id, did_code, did_name, zone, display_mode, edid_serial
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'TEST-EDID-002', 'Test EDID Device 2', 'WAITING_AREA', 'WAITING',
  'MFG001:PROD042:SERIAL9002'
) returning id \gset fixture2_
```

### 4.2 Matching scan — expect `is_mismatch: false`, `last_detected_edid` updated

```sql
select catchmenu_store.report_did_device_edid_scan(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_device_id := :'fixture2_id'::uuid,
  p_detected_edid := 'MFG001:PROD042:SERIAL9002'
);

select last_detected_edid, last_edid_check_at from catchmenu_store.did_devices
where id = :'fixture2_id'::uuid;
```

Expected:

- Function response: `success: true`, `is_mismatch: false`.
- `last_detected_edid` column now equals `'MFG001:PROD042:SERIAL9002'`.
- `last_edid_check_at` is non-null and recent (`now()`-scale).

### 4.3 Mismatched scan — expect `is_mismatch: true`

```sql
select catchmenu_store.report_did_device_edid_scan(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_device_id := :'fixture2_id'::uuid,
  p_detected_edid := 'MFG999:DIFFERENT:SERIAL0000'
);
```

Expected:

- Function response: `success: true` (the *call* succeeds — a mismatch is a reportable state, not an error), `is_mismatch: true`.
- `last_detected_edid` column updates to the newly-reported (mismatched) value — the column always reflects "what was most recently seen," regardless of match/mismatch, per `601012_Logic.md` §1's design (the comparison against `edid_serial`, which stays unchanged, is what signals drift).

```sql
rollback;
```

## 5. Boundary Verification

```powershell
git diff -- sql/migrations/0043_create_did_display_rpc.sql
git diff -- sql/migrations/0117_create_did_pipeline_rpc.sql
git diff --name-only -- sql/migrations
```

Expected:

- `0043_create_did_display_rpc.sql`: **no diff, under any circumstance** — this is the single most important boundary check for this workpacket, since Option 3 was chosen specifically to defer `0043`'s correction. Any diff here is an automatic FAIL regardless of what else passes.
- `0117_create_did_pipeline_rpc.sql`: no diff.
- Only the new forward migration appears in `git diff --name-only -- sql/migrations`.

Also verify `device_registry` schema is untouched:

```sql
select count(*) from information_schema.columns
where table_schema = 'catchmenu_store' and table_name = 'device_registry';
```

Expected: unchanged column count from the pre-implementation baseline — **20 columns**, directly re-confirmed live this turn (`information_schema.columns` query). Do not confuse this with `did_devices`'s own column count (23 base + 4 new = 27 after this migration) — the two tables' counts are unrelated and must not be cross-checked against each other.

## 6. Approval Criteria

This workpacket passes verification only if all of the following hold:

1. The 4 `did_devices` columns exist with the correct types and nullability.
2. The 2 new functions exist with the approved signatures.
3. `get_did_device_by_edid()` succeeds for a registered EDID and returns `edid_not_registered` (or equivalent, documented) for an unregistered one.
4. `report_did_device_edid_scan()` correctly updates `last_detected_edid`/`last_edid_check_at` and correctly reports `is_mismatch` in both the matching and mismatching cases.
5. `0043_create_did_display_rpc.sql` has zero diff — no exceptions.
6. `0117_create_did_pipeline_rpc.sql` and `device_registry`'s schema are untouched.
7. The implementation is a forward migration only; no other `.sql` file is touched.

## 7. Known Out-of-Scope Items

- Correcting `update_did_display()` to validate against `did_devices` instead of `device_registry` (Option 1) — explicitly deferred to a separate future workpacket per `601012_Logic.md` §2's Human decision.
- Windows EDID-reading technical feasibility (WMI/SetupAPI/DXGI, multi-GPU-vendor behavior) — separate research task, not a software deliverable of this workpacket.
- Admin-facing mismatch notification/alerting mechanism.
- Final EDID normalization string format decision (this TestPlan's fixtures use an illustrative `MFG:PROD:SERIAL` format pending that decision — implementation must not treat this fixture format as the confirmed final format).
- Content-delivery-engine (Stage C) integration — this workpacket only covers Stage A (device registry).
