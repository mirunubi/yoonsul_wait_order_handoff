# 601719_Evidence_Stores_Write_Path_Scan_Codex.md

> ⚠️ **`stores` write-path 실측 · 판정이 아니다**
>
> `601717` 3판이 남긴 blocker **C-1**(`stores.merchant_account_id` NOT NULL 승격 가부)의
> **직접 근거**다.
>
> NOT NULL 은 값을 공급하지 않는 INSERT 를 전부 깨뜨린다.
> `601701` §4.5 D-3 이 `stores` 참조 함수 개수만 기록했고
> **write path 의 형태는 측정되지 않았다.**
>
> **이 문서는 NOT NULL 승격 가부를 판정하지 않는다.** 사실만 제공한다.
>
> **같은 작업을 Cursor 도 독립 수행했다 — `601718`**(`000701` §35).
> **두 조사가 상대 결과를 참조하지 않고 동일한 수치에 도달했다.**
>
> 수행: Codex, 2026-08-22. 환경 `postgres:17.6.1.140`, migration `0169`.

This report records observed facts only. It does not decide whether `stores.merchant_account_id` may be promoted to `NOT NULL` and does not propose a change method.

## Environment

| Item | Observed value |
|---|---|
| Query timestamp | `2026-08-22 10:56:54.793902+00` (`2026-08-22 19:56:54.793902 KST`) |
| Container ID | `fb5b03ea152e5dc51e5093ea315e6698724a0a47ecc19c1c126dac1f11499857` |
| Container image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| Image ID | `sha256:6501843661b1f8ff97e85c02de33edc0ee2e2693888ad596ee86222f02dc8ecc` |
| PostgreSQL | `17.6` |
| Latest migration | `0169_authority_owner_role_and_sole_representative_uniqueness.sql` |
| Latest migration checksum | `eb9b118899fb42fee264b25fe3f4499def06013730a57a7320a0275dd86c564e` |
| Latest migration applied at/by/result | `2026-08-09 17:26:43.129498+00` / `postgres` / `success=true` |
| `catchmenu_hq.stores` rows | 1 |
| `catchmenu_hq.tenants` rows | 1 |

Only catalog/data `SELECT` queries and read-only source searches were executed. None of the seven prohibited functions was called.

## S-1. All functions whose source references `stores`

### Executed query

```sql
SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ILIKE '%stores%'
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY 1,2;
```

Observed total: **158**. This differs from the `601701` D-3 value of 151 by **7**.

| Schema | Count | Function names (all rows; overloads noted) |
|---|---:|---|
| `catchmenu_agent` | 3 | `activate_manual_fallback`, `create_agent_action`, `request_approval` |
| `catchmenu_audit` | 2 | `run_isolation_audit`, `scan_cross_tenant_risk` |
| `catchmenu_common` | 21 | `activate_subscription`, `bootstrap_app`, `bootstrap_kds_app`, `bootstrap_staff_app`, `check_saas_readiness`, `get_auth_context`, `get_daily_report`, `get_realtime_config`, `get_saas_dashboard`, `get_store_bootstrap`, `get_tenant_health`, `get_tenant_list`, `get_tenant_plan`, `heartbeat`, `onboard_tenant`, `provision_tenant`, `run_daily_close_batch`, `run_integration_test`, `run_opening_checklist`, `run_security_audit`, `seed_tenant_quotas` |
| `catchmenu_hq` | 25 | `apply_policy_to_stores`, `broadcast_brand_cms`, `broadcast_hq_notice`, `bulk_policy_distribution`, `compare_store_performance`, `compare_store_revenue`, `create_franchise_store`, `detect_policy_violations`, `distribute_menu_template`, `distribute_menu_to_stores`, `get_brand_store_overview`, `get_franchise_admin_dashboard`, `get_franchise_compliance_report`, `get_franchise_dashboard` (2 overloads), `get_franchise_os_dashboard`, `get_franchise_settlement_report`, `get_menu_compliance_report`, `get_policy_compliance_summary`, `get_store_group_dashboard`, `process_hq_approval`, `rollback_policy`, `run_compliance_check`, `send_hq_notice`, `sync_hq_menu_template` |
| `catchmenu_integrations` | 20 | `accept_delivery_order`, `auto_reject_overloaded`, `cancel_cash_receipt`, `confirm_cash_receipt`, `initiate_toss_payment_legacy_604260`, `intake_delivery_order`, `issue_cash_receipt`, `poll_pending_delivery_orders`, `process_okpos_order`, `process_toss_pos_order`, `process_toss_webhook`, `process_van_approval`, `process_van_cancel`, `receive_delivery_order`, `register_pos_provider`, `reject_delivery_order`, `sync_delivery_order_status`, `sync_pos_menu_item`, `sync_van_settlement`, `update_delivery_status` |
| `catchmenu_kds` | 2 | `get_kds_performance`, `get_kds_realtime_state` |
| `catchmenu_knowledge` | 4 | `build_operational_context`, `build_sop_recommendation_context`, `detect_knowledge_gap`, `record_ai_resolution_outcome` |
| `catchmenu_ledger` | 7 | `create_exception`, `reconcile_ledger_gaps`, `replay_local_ledger`, `resolve_replay_conflict`, `run_state_projection_check`, `verify_audit_chain`, `verify_event_ledger_integrity` |
| `catchmenu_payment` | 9 | `confirm_payment`, `confirm_refund`, `create_payment_intent`, `create_reconciliation_case`, `get_payment_summary`, `request_refund`, `resolve_or_create_payment_intent`, `run_layer2_reconciliation`, `run_layer3_reconciliation` |
| `catchmenu_pos` | 19 | `create_kiosk_session`, `create_order`, `create_order_session` (2 overloads), `create_pre_order`, `estimate_wait_time`, `get_daily_summary`, `get_kiosk_state`, `get_menu_catalog`, `get_menu_catalog_i18n`, `get_menu_performance`, `get_sales_report`, `get_waiting_queue`, `get_waiting_realtime_state`, `pre_order_while_waiting`, `record_allergen_display_evidence`, `register_waiting`, `update_menu_status`, `update_queue_position` |
| `catchmenu_store` | 46 | `approve_stock_transfer`, `bootstrap_customer_app`, `bootstrap_customer_app_v2`, `bootstrap_did_app`, `bootstrap_kiosk`, `calculate_work_hours`, `call_customer_pickup`, `change_store_mode`, `close_shift`, `close_store`, `create_staff_schedule`, `deduct_points`, `earn_points`, `get_did_waiting_display`, `get_food_cost_report`, `get_multistore_inventory`, `get_staff_schedule`, `get_store_admin_dashboard`, `get_store_cms_bundle`, `get_store_dashboard`, `get_store_devices`, `get_store_settings`, `get_table_floor_map`, `notify_customer_ready`, `open_shift`, `open_store`, `place_kiosk_order`, `place_takeout_order`, `record_inventory_movement`, `record_staff_attendance`, `redeem_coupon`, `register_customer`, `register_device`, `register_ingredient`, `register_staff`, `register_table_qr`, `release_table`, `request_stock_transfer`, `toggle_store_mode`, `trust_device`, `update_business_hours`, `update_device_status`, `update_did_display`, `update_kds_capacity_threshold`, `update_staff_role`, `update_table_status` |

## S-2. Functions that INSERT into `stores`

### Executed query

```sql
SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS args,
       p.prosrc
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ~* 'insert[[:space:]]+into[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*[.])?stores([[:space:]<(]|$)'
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY 1,2,3;
```

| # | Schema | Function | INSERT form | Explicit column list |
|---:|---|---|---|---|
| 1 | `catchmenu_common` | `provision_tenant(...)` | `COLUMN_LIST` | Yes: `tenant_id, store_code, store_name, store_type, store_status, timezone` |
| 2 | `catchmenu_hq` | `create_franchise_store(...)` | `COLUMN_LIST` | Yes: `tenant_id, store_code, store_name, store_type, store_status, address, phone, timezone, business_hours, opened_on, is_active, extra_metadata` |

`merchant_account_id` occurs in neither observed INSERT column list.

Counts: `COLUMN_LIST=2`, `NO_COLUMN_LIST=0`, `ROW_TYPE=0`, `UNKNOWN=0`.

### Complete INSERT statement: `catchmenu_common.provision_tenant(...)`

```sql
insert into catchmenu_hq.stores (
  tenant_id,
  store_code, store_name,
  store_type, store_status,
  timezone
) values (
  v_tenant_id,
  p_tenant_code || '_S01',
  p_store_name,
  'RESTAURANT', 'ACTIVE',
  p_store_timezone
)
returning id into v_store_id;
```

### Complete INSERT statement: `catchmenu_hq.create_franchise_store(...)`

```sql
INSERT INTO catchmenu_hq.stores (
    tenant_id, store_code, store_name, store_type, store_status,
    address, phone, timezone, business_hours, opened_on,
    is_active, extra_metadata
) VALUES (
    v_tenant_id, p_store_code, p_store_name, 'RESTAURANT', 'ACTIVE',
    p_address, p_phone, p_timezone, p_business_hours, p_opened_on,
    true, jsonb_build_object(
        'brand_id', p_brand_id,
        'created_by_franchise', true,
        'created_at', now()
    )
)
RETURNING id INTO v_store_id;
```

## S-3. Functions reading `stores` through `SELECT *` or row types

### Executed queries

```sql
SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname NOT IN ('pg_catalog','information_schema')
  AND (
    p.prosrc ~* 'select[[:space:]]+[*][[:space:]]+from[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*[.])?stores([[:space:];]|$)'
    OR p.prosrc ~* 'stores[[:space:]]*%rowtype'
    OR pg_get_function_result(p.oid) ~* 'setof[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*[.])?stores'
  )
ORDER BY 1,2,3;

SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname NOT IN ('pg_catalog','information_schema')
  AND p.prosrc ~* 'select[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[.][*][[:space:]]+from[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*[.])?stores';

SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname NOT IN ('pg_catalog','information_schema')
  AND p.prosrc ~* 'insert[[:space:]]+into[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*[.])?stores'
  AND p.prosrc ~* 'returning[[:space:]]+[*]';
```

| Pattern | Count |
|---|---:|
| `SELECT * FROM ... stores` | 0 |
| `SELECT alias.* FROM ... stores alias` | 0 |
| `stores%ROWTYPE` | 0 |
| `RETURNS SETOF ... stores` | 0 |
| `INSERT INTO ... stores ... RETURNING *` | 0 |

## S-4. Functions that UPDATE `stores`

### Executed query

```sql
SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS args,
       p.prosrc
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ~* 'update[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*[.])?stores[[:space:]]+set'
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY 1,2,3;
```

| # | Schema | Function | Updated columns |
|---:|---|---|---|
| 1 | `catchmenu_common` | `onboard_tenant(...)` | `brand_id` |
| 2 | `catchmenu_store` | `update_business_hours(...)` | `business_hours`, `updated_at` |

```sql
update catchmenu_hq.stores
set brand_id = v_brand_id
where id = v_store_id;

UPDATE catchmenu_hq.stores
SET business_hours = p_business_hours,
    updated_at = now()
WHERE id = p_store_id
  AND tenant_id = p_tenant_id;
```

## S-5. Application-code INSERT sites

### Search roots checked

| Path | Exists |
|---|---|
| `apps/` | Yes |
| `catchmenu_app/lib/` | Yes |
| `catchmenu_app/test/` | Yes |
| `packages/` | Yes |
| `supabase/` | Yes |
| `tests/` | Yes |

### Executed searches

```text
rg -n --hidden --glob '!docs/**' --glob '!sql/migrations/**' --glob '!build/**' --glob '!.dart_tool/**' "\.from\(['\"]stores['\"]\)\s*\.insert" apps catchmenu_app/lib catchmenu_app/test packages supabase tests
rg -n -i --hidden --glob '!docs/**' --glob '!sql/migrations/**' --glob '!build/**' --glob '!.dart_tool/**' "insert\s+into\s+(catchmenu_hq\.)?stores\b" apps catchmenu_app/lib catchmenu_app/test packages supabase tests
```

| Pattern | Count |
|---|---:|
| `.from('stores').insert` / double-quoted equivalent | 0 |
| SQL `INSERT INTO [catchmenu_hq.]stores` | 0 |

## S-6. Trigger and view dependencies

### Executed queries

```sql
SELECT n.nspname, c.relname, t.tgname, pg_get_triggerdef(t.oid)
FROM pg_trigger t
JOIN pg_class c ON c.oid=t.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE NOT t.tgisinternal
  AND n.nspname='catchmenu_hq'
  AND c.relname='stores'
ORDER BY t.tgname;

SELECT 'VIEW' AS kind, schemaname, viewname AS name, definition
FROM pg_views WHERE definition ILIKE '%stores%'
UNION ALL
SELECT 'MATVIEW', schemaname, matviewname, definition
FROM pg_matviews WHERE definition ILIKE '%stores%'
ORDER BY 1,2,3;
```

| Kind | Name | Definition/fact | Count |
|---|---|---|---:|
| TRIGGER | `catchmenu_hq.stores.trg_stores_updated_at` | `BEFORE UPDATE ... EXECUTE FUNCTION catchmenu_common.set_updated_at()` | 1 |
| VIEW | None | View definitions containing `stores` | 0 |
| MATVIEW | None | Materialized-view definitions containing `stores` | 0 |

## Summary

| Item | Count |
|---|---:|
| S-1 functions referencing `stores` | 158 |
| S-2 INSERT functions | 2 |
| S-2 `NO_COLUMN_LIST` | 0 |
| S-2 `ROW_TYPE` | 0 |
| S-3 `SELECT *` / row type | 0 |
| S-4 UPDATE functions | 2 |
| S-5 application-code INSERT sites | 0 |
| S-6 triggers / views | 1 / 0 |
