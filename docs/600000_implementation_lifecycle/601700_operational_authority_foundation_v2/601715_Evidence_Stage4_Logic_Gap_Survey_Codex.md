# 601715_Evidence_Stage4_Logic_Gap_Survey_Codex.md

> ⚠️ **Logic §6 미해결 항목 조사 · 사실 조사이며 판정이 아니다**
>
> `601713` Logic §6이 기록한 미해결 9건 중,
> **추가 조사로 답할 수 있는 5건**(Q-2/Q-3/Q-4/Q-5/Q-8)을 확인한 것이다.
>
> 나머지 4건(Q-1/Q-6/Q-7/Q-9)은 **Human 선언 사항**이며 조사 대상이 아니다.
>
> **교정 방법을 제안하지 않는다.** 판정은 ChangeContract(`601717`)가 한다.
>
> **같은 작업을 Cursor 도 독립 수행했다 —&#x20;****`601714`**(`000701` §35).
>
> ⚠️ **조사 환경**: `postgres:17.6.1.156`.
> `601701`/`601711`/`601712` 등 기존 조사가 수행된 PC 환경(`postgres:17.6.1.140`)과
> **다른 컨테이너**다. 적용된 최신 migration 은 양쪽 모두 `0169` 로 확인되었다.
>
> 수행: Codex, 2026-08-21.

## 환경 기록

| 항목 | 조회 결과 |
|---|---|
| 컨테이너 ID | `b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec` |
| 이미지 | `public.ecr.aws/supabase/postgres:17.6.1.156` |
| 컨테이너 상태 | `running` |
| PostgreSQL 서버 | `PostgreSQL 17.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 15.2.0, 64-bit` |
| 조회 일시 | `2026-08-21 07:31:07.05013+00` (`2026-08-21 16:31:07.05013+09`, Asia/Seoul) |
| 최신 migration_history | `0169_authority_owner_role_and_sole_representative_uniqueness.sql`; checksum `eb9b118899fb42fee264b25fe3f4499def06013730a57a7320a0275dd86c564e`; applied_at `2026-08-13 18:15:41.405072+00`; applied_by `postgres`; success `true`; error_message `NULL` |
| 전체 BASE TABLE 수 | 247 (아래 스키마별 집계의 합계) |

이 컨테이너 이미지 태그는 `17.6.1.156`이다. 제시된 기존 조사 환경의 이미지 태그는 `17.6.1.140`이다.

### 실행 쿼리

```sql
SELECT clock_timestamp() AS queried_at;
SELECT filename, checksum, applied_at, applied_by, success, error_message
FROM catchmenu_meta.migration_history
ORDER BY applied_at DESC NULLS LAST, filename DESC LIMIT 1;
SELECT table_schema, count(*) AS table_count
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
GROUP BY table_schema ORDER BY table_schema;
```

### 전체 테이블 수 (스키마별)

| 스키마 | BASE TABLE 수 |
|---|---:|
| `_realtime` | 4 |
| `auth` | 23 |
| `catchmenu_agent` | 4 |
| `catchmenu_ai` | 2 |
| `catchmenu_audit` | 1 |
| `catchmenu_common` | 41 |
| `catchmenu_dev` | 2 |
| `catchmenu_gateway` | 2 |
| `catchmenu_hq` | 20 |
| `catchmenu_integrations` | 19 |
| `catchmenu_kds` | 2 |
| `catchmenu_knowledge` | 14 |
| `catchmenu_ledger` | 6 |
| `catchmenu_meta` | 1 |
| `catchmenu_payment` | 11 |
| `catchmenu_pos` | 16 |
| `catchmenu_store` | 50 |
| `cron` | 2 |
| `information_schema` | 4 |
| `net` | 2 |
| `pg_catalog` | 64 |
| `realtime` | 8 |
| `storage` | 10 |
| `supabase_functions` | 2 |
| `vault` | 1 |

## Q-2. `chk_lepr_role_type` 허용값

### 실행 쿼리

```sql
SELECT c.conrelid::regclass AS table_name,
       c.conname,
       pg_get_constraintdef(c.oid) AS definition
FROM pg_constraint c
WHERE c.conrelid IN (
  'catchmenu_hq.legal_entity_person_roles'::regclass,
  'catchmenu_hq.legal_entity_representatives'::regclass,
  'catchmenu_hq.legal_entities'::regclass,
  'catchmenu_hq.owners'::regclass
)
AND c.contype = 'c'
ORDER BY 1::text, c.conname;
```

### 결과

| 테이블 | CHECK 제약 | 정의문 전문 |
|---|---|---|
| `catchmenu_hq.legal_entities` | `chk_legal_entities_crn_not_for_sole` | `CHECK (((entity_type <> 'SOLE_PROPRIETOR'::text) OR (corporate_registration_number IS NULL)))` |
| `catchmenu_hq.legal_entities` | `chk_legal_entities_entity_type` | `CHECK ((entity_type = ANY (ARRAY['SOLE_PROPRIETOR'::text, 'CORPORATION'::text, 'PARTNERSHIP'::text, 'NON_PROFIT'::text])))` |
| `catchmenu_hq.legal_entities` | `chk_legal_entities_status` | `CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'SUSPENDED'::text, 'CLOSED'::text])))` |
| `catchmenu_hq.legal_entity_person_roles` | `chk_lepr_effective_range` | `CHECK (((effective_to IS NULL) OR (effective_to >= effective_from)))` |
| `catchmenu_hq.legal_entity_person_roles` | `chk_lepr_ownership_percent` | `CHECK (((ownership_percent IS NULL) OR ((ownership_percent >= (0)::numeric) AND (ownership_percent <= (100)::numeric))))` |
| `catchmenu_hq.legal_entity_person_roles` | `chk_lepr_role_type` | `CHECK ((role_type = ANY (ARRAY['OWNER'::text, 'REPRESENTATIVE'::text, 'DIRECTOR'::text, 'EXECUTIVE'::text, 'INVESTOR'::text])))` |
| `catchmenu_hq.legal_entity_representatives` | `chk_ler_effective_range` | `CHECK (((effective_to IS NULL) OR (effective_to >= effective_from)))` |
| `catchmenu_hq.legal_entity_representatives` | `chk_ler_representation_mode` | `CHECK ((representation_mode = ANY (ARRAY['SOLE'::text, 'JOINT'::text, 'INDIVIDUAL'::text])))` |
| `catchmenu_hq.owners` | — | 0건 |

### 사실 요약

- `chk_lepr_role_type`에 기록된 값은 `OWNER`, `REPRESENTATIVE`, `DIRECTOR`, `EXECUTIVE`, `INVESTOR`이다.
- CHECK 제약 수는 `legal_entities` 3건, `legal_entity_person_roles` 3건, `legal_entity_representatives` 2건, `owners` 0건이다.

## Q-3. `set_updated_at()` 정의

### 실행 쿼리

```sql
SELECT n.nspname, p.proname, p.oid::regprocedure AS signature,
       p.prosecdef, p.proconfig, p.prosrc,
       pg_get_functiondef(p.oid) AS full_definition
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = 'set_updated_at'
ORDER BY n.nspname, p.oid;

SELECT tn.nspname AS table_schema, c.relname AS table_name, t.tgname,
       pn.nspname AS function_schema, p.proname,
       pg_get_triggerdef(t.oid, true) AS trigger_definition
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace tn ON tn.oid = c.relnamespace
JOIN pg_proc p ON p.oid = t.tgfoid
JOIN pg_namespace pn ON pn.oid = p.pronamespace
WHERE NOT t.tgisinternal AND p.proname = 'set_updated_at'
ORDER BY 1, 2, 3;
```

### 결과

| 항목 | 결과 |
|---|---|
| 스키마·시그니처 | `catchmenu_common.set_updated_at()` |
| `prosecdef` | `true` |
| SECURITY | `SECURITY DEFINER` |
| `proconfig` | `{search_path=pg_catalog}` |
| search_path | `pg_catalog` |
| 호출 트리거 수 | 114건 |

```sql
CREATE OR REPLACE FUNCTION catchmenu_common.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
begin
  new.updated_at := now();
  return new;
end;
$function$
```

트리거 전수(형식: `테이블.트리거`, 스키마별 건수):

| 스키마 | 건수 | 테이블.트리거 |
|---|---:|---|
| `catchmenu_agent` | 4 | `agent_actions.trg_agent_actions_updated_at`<br>`agent_approvals.trg_agent_approvals_updated_at`<br>`evidence_packets.trg_evidence_packets_updated_at`<br>`manual_fallback_log.trg_fallback_log_updated_at` |
| `catchmenu_common` | 22 | `auth_sessions.trg_auth_sessions_updated`<br>`edge_function_registry.trg_edge_function_updated`<br>`edge_function_templates.trg_edge_templates_updated`<br>`fallback_configs.trg_fallback_config_updated`<br>`feature_flags.trg_feature_flags_updated`<br>`firebase_migration_boundary.trg_firebase_boundary_updated`<br>`flutter_sdk_patterns.trg_flutter_patterns_updated`<br>`message_catalog.trg_message_catalog_updated_at`<br>`online_order_configs.trg_online_order_config_updated`<br>`operation_alerts.trg_alerts_updated`<br>`pg_cron_jobs.trg_pg_cron_jobs_updated`<br>`realtime_channels.trg_realtime_channels_updated`<br>`saas_launch_checklist.trg_launch_checklist_updated`<br>`sop_runbooks.trg_runbooks_updated`<br>`subscription_invoices.trg_invoices_updated`<br>`subscription_plans.trg_subscription_plans_updated`<br>`tenant_onboarding_log.trg_onboarding_updated`<br>`tenant_plan_configs.trg_tenant_plan_updated`<br>`tenant_quotas.trg_quotas_updated`<br>`tenant_rate_limits.trg_rate_limits_updated`<br>`usage_records.trg_usage_records_updated`<br>`white_label_configs.trg_white_label_updated` |
| `catchmenu_gateway` | 1 | `gateway_sessions.trg_gateway_sessions_updated_at` |
| `catchmenu_hq` | 18 | `escalation_log.trg_escalation_updated`<br>`franchise_approval_requests.trg_approval_requests_updated`<br>`franchise_brands.trg_franchise_brands_updated`<br>`franchise_kpi_targets.trg_kpi_targets_updated`<br>`franchise_menu_templates.trg_menu_template_updated`<br>`franchise_policies.trg_franchise_policies_updated`<br>`franchise_policy_assignments.trg_policy_assign_updated`<br>`hq_notices.trg_hq_notices_updated_at`<br>`legal_entities.trg_legal_entities_updated_at`<br>`legal_entity_person_roles.trg_lepr_updated_at`<br>`legal_entity_representatives.trg_ler_updated_at`<br>`menu_templates.trg_menu_templates_updated_at`<br>`owners.trg_owners_updated_at`<br>`policy_violations.trg_violations_updated`<br>`store_group_members.trg_group_members_updated`<br>`store_groups.trg_store_groups_updated`<br>`stores.trg_stores_updated_at`<br>`tenants.trg_tenants_updated_at` |
| `catchmenu_integrations` | 12 | `cash_receipt_log.trg_cash_receipt_updated`<br>`delivery_intake_log.trg_delivery_intake_updated`<br>`delivery_platform_configs.trg_delivery_config_updated_at`<br>`delivery_platform_rules.trg_delivery_rules_updated`<br>`okpos_transactions.trg_okpos_tx_updated`<br>`pos_provider_registry.trg_pos_registry_updated`<br>`pos_store_configs.trg_pos_store_configs_updated`<br>`toss_payment_requests.trg_toss_requests_updated`<br>`toss_payments.trg_toss_payments_updated_at`<br>`toss_pos_transactions.trg_toss_pos_tx_updated`<br>`van_settlements.trg_van_settlement_updated_at`<br>`van_transactions.trg_van_tx_updated_at` |
| `catchmenu_kds` | 1 | `kds_tickets.trg_kds_tickets_updated_at` |
| `catchmenu_knowledge` | 7 | `customer_inquiries.trg_inquiries_updated`<br>`document_versions.trg_doc_versions_updated_at`<br>`embedding_models.trg_embedding_models_updated`<br>`inquiry_categories.trg_inquiry_cat_updated`<br>`knowledge_gaps.trg_knowledge_gaps_updated_at`<br>`menu_embeddings.trg_menu_emb_updated`<br>`sop_candidates.trg_sop_candidates_updated` |
| `catchmenu_ledger` | 1 | `exceptions.trg_exceptions_updated_at` |
| `catchmenu_payment` | 3 | `payment_intents.trg_payment_intents_updated_at`<br>`reconciliation_cases.trg_recon_cases_updated_at`<br>`reconciliation_daily_summary.trg_recon_summary_updated` |
| `catchmenu_pos` | 9 | `menu_allergen_links.trg_menu_allergen_updated_at`<br>`menu_categories.trg_menu_categories_updated_at`<br>`menu_i18n.trg_menu_i18n_updated_at`<br>`menu_option_groups.trg_option_groups_updated_at`<br>`menu_option_items.trg_option_items_updated_at`<br>`menus.trg_menus_updated_at`<br>`order_items.trg_order_items_updated_at`<br>`order_sessions.trg_order_sessions_updated_at`<br>`orders.trg_orders_updated_at` |
| `catchmenu_store` | 36 | `agent_registry.trg_agent_registry_updated_at`<br>`cms_banners.trg_cms_banners_updated`<br>`cms_content_versions.trg_cms_versions_updated`<br>`cms_contents.trg_cms_contents_updated`<br>`cms_events.trg_cms_events_updated`<br>`cms_popups.trg_cms_popups_updated`<br>`coupon_issues.trg_coupon_issues_updated_at`<br>`coupons.trg_coupons_updated_at`<br>`customer_app_sessions.trg_customer_sessions_updated`<br>`customers.trg_customers_updated_at`<br>`device_registry.trg_device_registry_updated_at`<br>`did_content_schedule.trg_did_content_updated`<br>`did_devices.trg_did_devices_updated`<br>`did_display_queue.trg_did_queue_updated`<br>`dining_tables.trg_dining_tables_updated_at`<br>`ingredients.trg_ingredients_updated_at`<br>`inventory_items.trg_inventory_updated`<br>`kiosk_configs.trg_kiosk_configs_updated`<br>`membership_configs.trg_membership_config_updated`<br>`pay_basis_records.trg_pay_basis_updated`<br>`point_rules.trg_point_rules_updated_at`<br>`promotions.trg_promotions_updated`<br>`push_notification_log.trg_push_log_updated`<br>`push_notification_templates.trg_push_templates_updated`<br>`staff.trg_staff_updated_at`<br>`staff_attendance.trg_attendance_updated_at`<br>`staff_permission_matrix.trg_permission_matrix_updated`<br>`staff_schedules.trg_staff_schedules_updated`<br>`staff_shifts.trg_staff_shifts_updated`<br>`staff_tasks.trg_staff_tasks_updated`<br>`stamp_cards.trg_stamp_cards_updated`<br>`stock_transfer_items.trg_transfer_items_updated`<br>`stock_transfer_requests.trg_transfer_requests_updated`<br>`store_business_hours.trg_store_hours_updated`<br>`store_notices.trg_store_notices_updated`<br>`store_settings.trg_store_settings_updated_at` |

### 사실 요약

- 함수는 1건이며 `SECURITY DEFINER`, `search_path=pg_catalog`이다.
- `owners`를 포함하여 11개 스키마, 114개 트리거가 이 함수를 호출한다.

## Q-4. 신규 4테이블의 현재 접근 주체

### 실행 쿼리

```sql
SELECT parent.rolname AS granted_role, member.rolname AS member_name,
       member.rolcanlogin, member.rolbypassrls, am.admin_option,
       grantor.rolname AS grantor
FROM pg_auth_members am
JOIN pg_roles parent ON parent.oid = am.roleid
JOIN pg_roles member ON member.oid = am.member
JOIN pg_roles grantor ON grantor.oid = am.grantor
WHERE parent.rolname = 'catchmenu_authority_owner'
ORDER BY member.rolname;

SELECT n.nspname AS function_schema, p.proname,
       p.oid::regprocedure AS signature, x.table_name,
       strpos(lower(p.prosrc), lower(x.table_name)) AS match_position
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
CROSS JOIN (VALUES ('legal_entities'), ('legal_entity_representatives'),
                   ('legal_entity_person_roles'), ('owners')) x(table_name)
WHERE strpos(lower(p.prosrc), lower(x.table_name)) > 0
ORDER BY 1, 2, 4;

SELECT pn.nspname AS function_schema, p.proname,
       p.oid::regprocedure AS signature,
       tn.nspname AS referenced_schema, c.relname AS referenced_table,
       d.deptype
FROM pg_depend d
JOIN pg_proc p ON p.oid = d.objid AND d.classid = 'pg_proc'::regclass
JOIN pg_namespace pn ON pn.oid = p.pronamespace
JOIN pg_class c ON c.oid = d.refobjid AND d.refclassid = 'pg_class'::regclass
JOIN pg_namespace tn ON tn.oid = c.relnamespace
WHERE c.oid IN (
  'catchmenu_hq.legal_entities'::regclass,
  'catchmenu_hq.legal_entity_representatives'::regclass,
  'catchmenu_hq.legal_entity_person_roles'::regclass,
  'catchmenu_hq.owners'::regclass
)
ORDER BY 1, 2, 4, 5;

SELECT src_ns.nspname AS source_schema, src.relname AS source_table,
       con.conname, pg_get_constraintdef(con.oid) AS definition,
       tgt_ns.nspname AS target_schema, tgt.relname AS target_table
FROM pg_constraint con
JOIN pg_class src ON src.oid = con.conrelid
JOIN pg_namespace src_ns ON src_ns.oid = src.relnamespace
JOIN pg_class tgt ON tgt.oid = con.confrelid
JOIN pg_namespace tgt_ns ON tgt_ns.oid = tgt.relnamespace
WHERE con.contype = 'f'
AND con.confrelid IN (
  'catchmenu_hq.legal_entities'::regclass,
  'catchmenu_hq.legal_entity_representatives'::regclass,
  'catchmenu_hq.legal_entity_person_roles'::regclass,
  'catchmenu_hq.owners'::regclass
)
AND src_ns.nspname <> 'catchmenu_hq'
ORDER BY 1, 2, 3;
```

### 결과

| 부여 역할 | 멤버 | rolcanlogin | rolbypassrls | admin_option | grantor |
|---|---|---|---|---|---|
| `catchmenu_authority_owner` | `postgres` | `true` | `true` | `true` | `supabase_admin` |
| `catchmenu_authority_owner` | `postgres` | `true` | `true` | `false` | `postgres` |

| 확인 항목 | 결과 |
|---|---:|
| 고유 멤버 | 1명 (`postgres`) |
| `prosrc` 문자열 검색 | 0건 |
| `pg_depend` 함수→테이블 의존 검색 | 0건 |
| 다른 스키마에서 신규 4테이블을 참조하는 FK | 0건 |

### 사실 요약

- `pg_auth_members`에는 `postgres`에 대한 grantor별 행이 2건 있다.
- `postgres`는 LOGIN 가능, BYPASSRLS이며, `supabase_admin`이 grantor인 행의 `admin_option`은 true이고 `postgres`가 grantor인 행은 false이다.
- 지정한 두 방식의 함수 참조 검색 결과는 각각 0건이다.
- 다른 스키마의 FK 참조 검색 결과는 0건이다.

## Q-5. `merchant_accounts` 물리 존재

### 실행 쿼리

```sql
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_name ILIKE '%merchant%'
ORDER BY 1, 2;

SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_name IN ('accounts', 'tenants')
ORDER BY 1, 2;

SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_name ILIKE ANY (ARRAY['%account%', '%tenant%', '%company%'])
  AND table_name NOT ILIKE '%merchant%'
ORDER BY 1, 2;

SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE column_name ILIKE '%merchant%'
ORDER BY 1, 2, ordinal_position;
```

### 결과

| 검색 | 결과 |
|---|---|
| 테이블명 `%merchant%` | 0건 |
| `merchant_accounts` | 0건 |
| `merchant_companies` | 0건 |
| `merchant_stores` | 0건 |
| 정확한 테이블명 `accounts` | 0건 |
| 정확한 테이블명 `tenants` | 2건: `_realtime.tenants`, `catchmenu_hq.tenants` |

유사 이름 테이블 검색 결과:

| 스키마 | 테이블 |
|---|---|
| `_realtime` | `tenants` |
| `catchmenu_common` | `tenant_onboarding_log` |
| `catchmenu_common` | `tenant_plan_configs` |
| `catchmenu_common` | `tenant_quotas` |
| `catchmenu_common` | `tenant_rate_limits` |
| `catchmenu_hq` | `tenants` |

`merchant` 포함 컬럼 전수:

| 스키마.테이블 | 컬럼 | 타입 |
|---|---|---|
| `catchmenu_integrations.pos_store_configs` | `merchant_id` | `text` |
| `catchmenu_integrations.toss_pos_transactions` | `toss_pos_merchant_id` | `text` |
| `catchmenu_integrations.van_settlements` | `van_merchant_id` | `text` |
| `catchmenu_integrations.van_transactions` | `van_merchant_id` | `text` |
| `catchmenu_payment.van_transactions` | `van_merchant_id` | `text` |

### 사실 요약

- 이름에 `merchant`가 들어간 테이블은 0건이다.
- 이름에 `merchant`가 들어간 컬럼은 5건이다.

## Q-8. onboarding evidence

### 실행 쿼리

```sql
WITH wanted(column_name) AS (
  VALUES ('business_registration_number'), ('legal_entity_name'),
         ('representative_name'), ('business_address'),
         ('business_category'), ('tax_invoice_email'),
         ('settlement_owner'), ('contract_signer'),
         ('verification_state')
)
SELECT w.column_name AS requested_name, c.table_schema, c.table_name,
       c.column_name AS existing_column, c.data_type
FROM wanted w
LEFT JOIN information_schema.columns c ON c.column_name = w.column_name
ORDER BY 1, 2, 3;

SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE column_name ~* '(business.*(registration|number|name|address|category)|legal.*entity|representative|tax.*invoice|invoice.*email|settlement.*owner|owner.*settlement|contract.*sign|sign.*contract|verification.*state|state.*verification)'
ORDER BY 1, 2, ordinal_position;

SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_name ILIKE ANY (ARRAY['%sales_lead%', '%tenant_candidate%',
                                  '%onboarding%', '%intake%'])
ORDER BY 1, 2;

SELECT ordinal_position, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq' AND table_name = 'legal_entities'
ORDER BY ordinal_position;
```

### 결과

정확한 컬럼명 검색:

| 요청 컬럼명 | 결과 |
|---|---|
| `business_registration_number` | `catchmenu_hq.legal_entities.business_registration_number` (`text`) 1건 |
| `legal_entity_name` | 0건 |
| `representative_name` | 0건 |
| `business_address` | 0건 |
| `business_category` | 0건 |
| `tax_invoice_email` | 0건 |
| `settlement_owner` | 0건 |
| `contract_signer` | 0건 |
| `verification_state` | 0건 |

유사 이름 정규식 검색 결과:

| 스키마.테이블 | 컬럼 | 타입 |
|---|---|---|
| `catchmenu_hq.legal_entities` | `business_registration_number` | `text` |
| `catchmenu_hq.legal_entity_person_roles` | `legal_entity_id` | `uuid` |
| `catchmenu_hq.legal_entity_representatives` | `legal_entity_id` | `uuid` |
| `catchmenu_hq.stores` | `legal_entity_id` | `uuid` |

관련 테이블명 검색:

| 검색어 | 결과 |
|---|---|
| `sales_lead` | 0건 |
| `tenant_candidate` | 0건 |
| `onboarding` | `catchmenu_common.tenant_onboarding_log` 1건 |
| `intake` | `catchmenu_integrations.delivery_intake_log` 1건 |

`catchmenu_hq.legal_entities` 컬럼 전수:

| # | 컬럼 | 타입 | nullable | default |
|---:|---|---|---|---|
| 1 | `id` | `uuid` | NO | `gen_random_uuid()` |
| 2 | `entity_type` | `text` | NO | — |
| 3 | `legal_name` | `text` | NO | — |
| 4 | `business_registration_number` | `text` | YES | — |
| 5 | `brn_normalized` | `text` | YES | — |
| 6 | `corporate_registration_number` | `text` | YES | — |
| 7 | `crn_normalized` | `text` | YES | — |
| 8 | `tax_id` | `text` | YES | — |
| 9 | `status` | `text` | NO | `'ACTIVE'::text` |
| 10 | `created_at` | `timestamp with time zone` | NO | `now()` |
| 11 | `updated_at` | `timestamp with time zone` | NO | `now()` |

추가로 신규 4테이블 전체 컬럼 조회에서 `catchmenu_hq.owners.owner_name` (`text`, NOT NULL)이 존재했다. `legal_entity_representatives`에는 이름 컬럼이 없고 `owner_id`가 존재한다.

### 사실 요약

- 제시된 9개 정확한 컬럼명 중 1개가 1건 검색되었고, 나머지 8개는 0건이다.
- `legal_entities`에는 `legal_name` 컬럼이 존재한다.
- `owners`에는 `owner_name` 컬럼이 존재한다.
- 관련 테이블명 검색은 `onboarding` 1건, `intake` 1건, `sales_lead` 0건, `tenant_candidate` 0건이다.

## 종합

| # | 질문 | 답변 가능 여부 | 비고 |
|---|---|---|---|
| Q-2 | `chk_lepr_role_type` 허용값 | 확인됨 | 4개 테이블의 CHECK 제약 전수와 0건 테이블 기록 |
| Q-3 | `set_updated_at()` 정의 | 확인됨 | 정의 전문, SECURITY DEFINER, search_path, 트리거 114건 기록 |
| Q-4 | 신규 4테이블의 현재 접근 주체 | 확인됨 | 멤버·속성·admin_option, 함수 참조 2방식, 외부 스키마 FK 조회 |
| Q-5 | `merchant_accounts` 물리 존재 | 확인됨 | 대상·유사 테이블 및 merchant 컬럼 조회 |
| Q-8 | onboarding evidence | 확인됨 | 정확·유사 컬럼, 관련 테이블, `legal_entities` 컬럼 전수 조회 |

모든 SQL은 `BEGIN READ ONLY`와 `COMMIT` 사이에서 실행했다. 금지된 7개 함수는 호출하지 않았다.
