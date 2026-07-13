# 600433_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-13

## 0. Scope Source

This TestPlan is a formatting/verification plan for the already-confirmed design in:

- `600431_Overview.md`
- `600432_Logic.md`

No new design decision is introduced here. The confirmed scope remains:

- 10 files
- 30 grep-matched occurrences
- three replacement families:
  - `request_memo` -> `memo`
  - `case_severity` -> `severity`
  - `'INVESTIGATING'` -> `'UNDER_INVESTIGATION'`
- `0133_create_final_validation_package.sql` is included as a source-text correction only because its `CREATE TABLE IF NOT EXISTS catchmenu_payment.reconciliation_cases (...)` block is phantom/no-op after `0015_create_payment_reconciliation.sql`.

## 1. Confirmed File / Occurrence Matrix

### 1.1 `request_memo` -> `memo`

| File | Logic reference | Function / context | Before | After / expected handling |
|---|---:|---|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | L508 | `catchmenu_store.place_takeout_order(...)`, parameter declaration | `p_request_memo text default null,` | `p_memo text default null,` — parameter name change, confirmed 2026-07-11 (Human decision, Gemini input incorporated) |
| `sql/migrations/0081_create_customer_app_rpc.sql` | L796 | `catchmenu_store.place_takeout_order(...)`, INSERT column | `request_memo,` | `memo,` |
| `sql/migrations/0081_create_customer_app_rpc.sql` | L805 | `catchmenu_store.place_takeout_order(...)`, VALUES clause parameter passthrough | `p_request_memo,` | `p_memo,` — must match the L508 parameter rename |
| `sql/migrations/0081_create_customer_app_rpc.sql` | L1007 | `catchmenu_store.track_takeout_order(...)`, SELECT | `o.request_memo,` | `o.memo,` |
| `sql/migrations/0081_create_customer_app_rpc.sql` | L1142 | `catchmenu_store.track_takeout_order(...)`, JSON response | `'request_memo', v_order.request_memo,` | `'memo', v_order.memo,` — output JSON key also changes (A안, Human decision 2026-07-11): repo-wide search found no consumer of this key (see `600432_Logic.md` §2.1 rationale); this reverses the earlier "keep the output key" decision for this specific function |
| `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` | L380 | Dart example text | `'p_request_memo': requestMemo,` | `'p_memo': requestMemo,` — included as of 2026-07-11 (Human decision): the RPC parameter key in this example must stay in sync with `0081`'s renamed `p_memo` parameter. No live SQL execution test (still client-side example text); verify by static text match only. The Dart local variable name `requestMemo` is unchanged. |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | L448 | `catchmenu_kds.get_kds_realtime_state(...)` | `'request_memo', o.request_memo` | `'request_memo', o.memo` |
| `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql` | L667 | `catchmenu_integrations.send_order_to_okpos(...)`, SELECT | `o.request_memo, o.session_id,` | `o.memo, o.session_id,` |
| `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql` | L728 | `catchmenu_integrations.send_order_to_okpos(...)`, JSON payload | `'memo', coalesce(v_order.request_memo, ''),` | `'memo', coalesce(v_order.memo, ''),` |
| `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql` | L601 | `catchmenu_integrations.send_order_to_toss_pos(...)`, SELECT | `o.final_amount, o.request_memo,` | `o.final_amount, o.memo,` |
| `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql` | L661 | `catchmenu_integrations.send_order_to_toss_pos(...)`, payload | `v_order.request_memo, ''` | `v_order.memo, ''` |
| `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` | L860 | `catchmenu_common.flush_offline_queue(...)`, INSERT column | `request_memo,` | `memo,` |
| `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` | L878 | offline action payload extraction | `->>'request_memo'` | No change in this batch; this is client/offline payload contract, kept as Open Item |

### 1.2 `case_severity` -> `severity`

| File | Logic reference | Function / context | Before | After / expected handling |
|---|---:|---|---|---|
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | L547 | `catchmenu_payment.run_layer2_reconciliation(...)`, INSERT column | `case_severity,` | `severity,` |
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | L993 | `catchmenu_payment.run_layer3_reconciliation(...)`, INSERT column | `case_type, case_status, case_severity,` | `case_type, case_status, severity,` |
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | L1182 | `catchmenu_payment.get_reconciliation_report(...)`, JSON output | `'case_severity', case_severity,` | `'case_severity', severity,` — keep output JSON key |
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | L1189 | `catchmenu_payment.get_reconciliation_report(...)`, CASE expression | `case case_severity` | `case severity` |
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | L1214 | JSON filter over locally built output | `where c->>'case_severity' = 'CRITICAL'` | No change; this reads the retained JSON key, not the table column |
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | L1285 | `catchmenu_payment.resolve_reconciliation_gap(...)`, SELECT | `case_severity, layer_number,` | `severity, layer_number,` |
| `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` | L1193 | `catchmenu_common.health_check(...)` | `and case_severity = 'CRITICAL';` | `and severity = 'CRITICAL';` |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | confirmed by `600420` | `catchmenu_common.get_staff_alert_feed(...)` | `case_severity` | `severity` |
| `sql/migrations/0111_create_franchise_admin_rpc.sql` | L1119 | `catchmenu_hq.get_franchise_settlement_report(...)`, JSON output | `'case_severity', rc.case_severity,` | `'case_severity', rc.severity,` — keep output JSON key |
| `sql/migrations/0111_create_franchise_admin_rpc.sql` | L1124 | `catchmenu_hq.get_franchise_settlement_report(...)`, ORDER BY | `order by rc.case_severity desc,` | `order by rc.severity desc,` |
| `sql/migrations/0120_create_reconciliation_pipeline.sql` | L815 | `catchmenu_payment.get_reconciliation_report(...)`, JSON output | `'case_severity', rc.case_severity,` | `'case_severity', rc.severity,` |
| `sql/migrations/0120_create_reconciliation_pipeline.sql` | L820 | `catchmenu_payment.get_reconciliation_report(...)`, ORDER BY | `order by rc.case_severity desc,` | `order by rc.severity desc,` |
| `sql/migrations/0133_create_final_validation_package.sql` | L281 | phantom DDL | `case_severity text not null default 'WARNING',` | `severity text not null default 'WARNING',` — source-text correction only |

### 1.3 `'INVESTIGATING'` -> `'UNDER_INVESTIGATION'`

| File | Logic reference | Function / context | Before | After / expected handling |
|---|---:|---|---|---|
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | L1202 | `catchmenu_payment.get_reconciliation_report(...)` | `case_status in ('OPEN', 'INVESTIGATING')` | `case_status in ('OPEN', 'UNDER_INVESTIGATION')` |
| `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` | L1191 | `catchmenu_common.health_check(...)` | `'OPEN', 'INVESTIGATING'` | `'OPEN', 'UNDER_INVESTIGATION'` |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | confirmed by `600420` | `catchmenu_common.get_staff_alert_feed(...)` | `'OPEN', 'INVESTIGATING'` | `'OPEN', 'UNDER_INVESTIGATION'` |
| `sql/migrations/0133_create_final_validation_package.sql` | L290 | phantom `chk_case_status` DDL | `'OPEN', 'INVESTIGATING',` | `'OPEN', 'UNDER_INVESTIGATION',` — source-text correction only |

## 2. Hard Error Test Cases — `case_severity`

Purpose: confirm that previously hard-failing SQL no longer raises `column ... case_severity ... does not exist`.

### 2.1 Source checks

Run static checks after implementation:

```powershell
Select-String -Path "sql\migrations\0084_create_reconciliation_advanced_rpc.sql","sql\migrations\0092_create_flutter_edge_function_guide_rpc.sql","sql\migrations\0099_create_realtime_pipeline_rpc.sql","sql\migrations\0111_create_franchise_admin_rpc.sql","sql\migrations\0120_create_reconciliation_pipeline.sql","sql\migrations\0133_create_final_validation_package.sql" -Pattern "case_severity"
```

Expected:

- Remaining `case_severity` occurrences are only retained JSON output keys or explicitly documented phantom/source-text contexts.
- Table-column references in executable SQL are replaced with `severity`.

### 2.2 Runtime checks

Execute the affected live functions after migration application/replay:

| Function | File | Expected result |
|---|---|---|
| `catchmenu_payment.run_layer2_reconciliation(...)` | `0084` | When a reconciliation gap path is triggered, no `case_severity` column error occurs |
| `catchmenu_payment.run_layer3_reconciliation(...)` | `0084` | No `case_severity` column error occurs |
| `catchmenu_payment.get_reconciliation_report(...)` 4-parameter overload | `0084` | JSON/report generation succeeds without `case_severity` column error |
| `catchmenu_payment.resolve_reconciliation_gap(...)` | `0084` | SELECT path no longer references missing `case_severity` column |
| `catchmenu_common.health_check(...)` | `0092` | Health check succeeds without `case_severity` column error |
| `catchmenu_common.get_staff_alert_feed(...)` | `0099` | Alert feed succeeds without `case_severity` column error |
| `catchmenu_hq.get_franchise_settlement_report(...)` | `0111` | Settlement report succeeds without `rc.case_severity` column error |
| `catchmenu_payment.get_reconciliation_report(...)` 5-parameter overload | `0120` | Report succeeds without `rc.case_severity` column error |

`0133_create_final_validation_package.sql` is excluded from runtime execution validation because the corrected block is phantom/no-op DDL.

## 3. Silent Undercount Test Cases — `'INVESTIGATING'`

Purpose: confirm that `UNDER_INVESTIGATION` reconciliation cases are no longer silently omitted by filters that previously used `'INVESTIGATING'`.

This is not a hard-error class. A passing function call is insufficient; tests must compare Before/After counts.

### 3.1 Required Before/After count comparison

For each executable function below, create or identify a reconciliation case with:

- `case_status = 'UNDER_INVESTIGATION'`
- severity/context sufficient for the target function's filter
- tenant/store scoped to the function invocation

Then compare the same scenario:

1. Before source correction/live replay: the row is omitted.
2. After source correction/live replay: the row is included.

| Function | File / Logic line | Before filter | After filter | Expected verification |
|---|---:|---|---|---|
| `catchmenu_payment.get_reconciliation_report(...)` 4-param | `0084` L1202 | `case_status in ('OPEN', 'INVESTIGATING')` | `case_status in ('OPEN', 'UNDER_INVESTIGATION')` | report count/list includes `UNDER_INVESTIGATION` case after fix |
| `catchmenu_common.health_check(...)` | `0092` L1191 | `'OPEN', 'INVESTIGATING'` | `'OPEN', 'UNDER_INVESTIGATION'` | health/reconciliation count reflects the inserted `UNDER_INVESTIGATION` row |
| `catchmenu_common.get_staff_alert_feed(...)` | `0099`, confirmed by `600420` | `'OPEN', 'INVESTIGATING'` | `'OPEN', 'UNDER_INVESTIGATION'` | staff alert feed includes/counts the critical `UNDER_INVESTIGATION` case |

### 3.2 Example verification pattern

```sql
BEGIN;

-- Prepare a tenant/store-scoped UNDER_INVESTIGATION reconciliation case.
-- Exact required columns must follow the live 0015 schema.
INSERT INTO catchmenu_payment.reconciliation_cases (
  tenant_id,
  store_id,
  case_type,
  case_status,
  severity,
  reconciliation_layer
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'AMOUNT_MISMATCH',
  'UNDER_INVESTIGATION',
  'CRITICAL',
  'LAYER1'
);

-- Invoke each affected function and record the count/list behavior.
-- Before: the row is omitted.
-- After: the row is included.

ROLLBACK;
```

`0133_create_final_validation_package.sql` L290 is not runtime-tested; it is phantom DDL and is source-corrected only.

## 4. `request_memo` Test Cases

Purpose: confirm that values stored in the actual `catchmenu_pos.orders.memo` column are returned or propagated correctly by functions that previously read/wrote `request_memo`.

`0092_create_flutter_edge_function_guide_rpc.sql` L380 is excluded from *runtime* verification because it is Dart/example text, not executable SQL column access. As of 2026-07-11 (Human decision) it is no longer excluded from this TestPlan entirely: a static text-match check (§4.1) confirms the example's RPC parameter key stays in sync with `0081`'s renamed `p_memo` parameter.

### 4.1 Source checks

```powershell
Select-String -Path "sql\migrations\0081_create_customer_app_rpc.sql","sql\migrations\0099_create_realtime_pipeline_rpc.sql","sql\migrations\0102_create_okpos_integration_pipeline_rpc.sql","sql\migrations\0104_create_toss_pos_pipeline_rpc.sql","sql\migrations\0109_create_network_handoff_fallback_rpc.sql" -Pattern "request_memo|\.memo\b"
```

```powershell
Select-String -Path "sql\migrations\0081_create_customer_app_rpc.sql","sql\migrations\0092_create_flutter_edge_function_guide_rpc.sql" -Pattern "p_request_memo|p_memo"
```

Expected:

- SQL table-column reads/writes use `memo`.
- Backward-compatible output JSON keys may remain `request_memo` only where `600432_Logic.md` explicitly says to preserve the response contract (currently only `0099`'s `get_kds_realtime_state()` L448 — see Open Item 8 in §7 for the resulting inconsistency).
- `0081` L1142 (`track_takeout_order(...)`) no longer retains `request_memo` as an output key; it must be `'memo'` (A안, Human decision 2026-07-11).
- `0109` L878 `->>'request_memo'` remains unchanged pending the offline payload Open Item.
- `0081` L508/L805 use the renamed parameter `p_memo`; no remaining `p_request_memo` in `place_takeout_order(...)`.
- `0092` L380's Dart example key matches `'p_memo'`, in sync with `0081`.

### 4.2 Runtime checks

| Function | File | Test data | Expected result |
|---|---|---|---|
| `catchmenu_store.place_takeout_order(...)` | `0081` | call using the renamed `p_memo` parameter (not `p_request_memo`) | row is inserted into `catchmenu_pos.orders.memo`; no `p_request_memo`/`request_memo` parameter or column error |
| `catchmenu_store.track_takeout_order(...)` | `0081` | order row with `memo = '<known value>'` | response JSON exposes the value under the key `memo` (not `request_memo` — A안, Human decision 2026-07-11); no `o.request_memo`/`v_order.request_memo` column error |
| `catchmenu_kds.get_kds_realtime_state(...)` | `0099` | order/ticket row with `orders.memo = '<known value>'` | realtime payload reads memo from `o.memo`; no `o.request_memo` column error |
| `catchmenu_integrations.send_order_to_okpos(...)` | `0102` | order row with `orders.memo = '<known value>'` | outbound OKPOS payload includes the memo value |
| `catchmenu_integrations.send_order_to_toss_pos(...)` | `0104` | order row with `orders.memo = '<known value>'` | outbound Toss POS payload includes the memo value |
| `catchmenu_common.flush_offline_queue(...)` | `0109` | offline action path that inserts an order | inserted order uses `memo` column; no `request_memo` column error |

`0092_create_flutter_edge_function_guide_rpc.sql` L380 has no corresponding runtime row: it is client-side example text with no live function to invoke. Verification is limited to the static text-match check in §4.1.

## 5. Application / Replay Procedure

### 5.1 `0099_create_realtime_pipeline_rpc.sql`

`0099` requires special handling because it already went through a prior §24 repair track in `600420`.

Required verification:

1. Confirm the new edits do not regress the previous `0099` corrections for:
   - `is_late`
   - `priority`
   - `kds_capacity_threshold_per_zone`
2. Recalculate and update the `0099` checksum after the source correction.
3. Directly re-execute the live functions using `psql`; checksum update alone is not enough.
4. Verify live definitions with `pg_get_functiondef()` for:
   - `catchmenu_kds.get_kds_realtime_state(...)`
   - `catchmenu_common.get_staff_alert_feed(...)`
5. Confirm the live definitions contain both:
   - previous `600420` repairs
   - current `600430` repairs (`memo`, `severity`, `UNDER_INVESTIGATION`)

### 5.2 Remaining 8 executable SQL files

For these eight files, use the normal `tools/apply_migrations.py` flow after source correction:

- `sql/migrations/0081_create_customer_app_rpc.sql`
- `sql/migrations/0084_create_reconciliation_advanced_rpc.sql`
- `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql`
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`
- `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql`
- `sql/migrations/0109_create_network_handoff_fallback_rpc.sql`
- `sql/migrations/0111_create_franchise_admin_rpc.sql`
- `sql/migrations/0120_create_reconciliation_pipeline.sql`

After application, run the hard-error, undercount, and request-memo checks above as applicable.

### 5.3 `0133_create_final_validation_package.sql`

`0133` is a phantom/no-op DDL case:

- update source text only;
- do not attempt to make the phantom DDL execute;
- do not drop/recreate `catchmenu_payment.reconciliation_cases`;
- skip live runtime execution validation for this file;
- verify only that the source text and checksum state reflect the approved correction.

## 6. Post-Implementation Checks

Run:

```powershell
git diff --check
git status --short
```

Expected:

- only the 10 allowed SQL files are modified;
- no forbidden SQL files are modified;
- no runtime/application code is modified;
- `0133` is changed only as source text;
- `0099` live function definitions are directly re-executed and verified, not merely checksum-updated.

## 7. Open Items Carried Forward

These are copied from `600432_Logic.md` §5 and must not be solved inside this batch unless a later approval explicitly expands the boundary:

1. `0133` phantom DDL handling is resolved by Human decision: include it in this source-correction batch, but treat it as no-op at runtime.
2. `0109` L878 offline action payload extraction `->>'request_memo'` depends on the client/offline payload contract and remains unchanged pending separate confirmation.
3. `0084` L1285 was directly confirmed as `case_severity, layer_number,`; only `case_severity` is in this batch.
4. `gap_amount`, `layer_number`, `amount_difference`, and `case_description` stale references are out of this batch and require a separate follow-up workpacket.
5. `0121_create_security_pipeline.sql` / `security_threats.threat_status = 'INVESTIGATING'` is a separate table/domain and is not part of this reconciliation-case correction batch.
6. `0081`'s `place_takeout_order(...)` RPC parameter name (`p_request_memo`) is resolved by Human decision (2026-07-11, Gemini input incorporated): rename to `p_memo` at L508/L805, in addition to the `request_memo` -> `memo` column change already in scope. `0092` L380's Dart example is synchronized accordingly. This does not add new occurrences beyond the already-counted 5 for `0081`; it corrects an earlier table omission that had itemized only 3 of the 5 `0081` locations.
7. A안 confirmed (2026-07-13): `track_takeout_order(...)` L1142's response JSON output key `request_memo` -> `memo` (Human decision, 2026-07-11). A repo-wide search (`catchmenu_app/lib`, `sql/`, `supabase/`) found no consumer of this key, so the earlier "preserve the output key" decision is reversed for this specific function. This search was scoped to this repository only; a client repo outside this workspace was not checked.
8. `0099`'s `get_kds_realtime_state()` L448 still retains the `request_memo` output key, per the original design. This task's A안 explicitly named only `0081`'s `track_takeout_order(...)`, so `0099`'s output key is left unchanged in this batch — the resulting inconsistency with A안's "unify system-wide terminology" intent is flagged for a future Human decision, not resolved here.
