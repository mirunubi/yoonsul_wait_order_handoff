# 601726_Evidence_Provision_Tenant_Schema_Consistency_Codex.md

> ⚠️ **보충 실측 · 판정이 아니다**
>
> Stage 6 통합 중 Claude 의 §9.20 원문 직접 재검토에서
> **`provision_tenant` 의 `tenants` INSERT 가 실측되지 않았다**는 사실이 드러나 수행한 조사다.
>
> `601720`/`601721` PRE-6 은 `stores` 컬럼과 `brand_id`/`extra_metadata` 토큰만 대상으로 했고,
> **`tenants` 컬럼 대 `provision_tenant` 참조는 검사 범위 밖**이었다.
>
> **이 조사는 `provision_tenant` 의 현재 live-schema 정합성만 확인한다.**
> C-1 의 ELIGIBLE / INELIGIBLE 여부, 후속 RPC 설계, handoff 순서를 판정하지 않는다.
>
> **같은 작업을 Cursor 도 독립 수행했다 — `601725`**(`000701` §35).
> **두 조사가 상대 결과를 참조하지 않고 동일 결론에 도달했다.**
>
> ⚠️ 이 보고서 §10 에 조사자 자신이 기록한 독립성 관련 고지가 있다.
> 삭제하지 않고 그대로 보존한다.
>
> 수행: Codex, 2026-08-23.

> **Eyes-Only 독립 DB 사실 검증**
>
> 함수 실행, 쓰기 SQL, migration 적용, 계약 수정, 설계 판정을 수행하지 않았다.
> Live PostgreSQL catalog와 함수 정의를 우선하고 migration 및 caller를 정적 검색했다.

## 0. 환경 식별

| 항목 | 실측 |
|---|---|
| Container ID | `fb5b03ea152e5dc51e5093ea315e6698724a0a47ecc19c1c126dac1f11499857` |
| PostgreSQL image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| Image ID | `sha256:6501843661b1f8ff97e85c02de33edc0ee2e2693888ad596ee86222f02dc8ecc` |
| PostgreSQL version | `PostgreSQL 17.6` |
| Database | `postgres` |
| Query timestamp | `2026-08-23 13:35:51.309047 KST` (`2026-08-23 04:35:51.309047+00`) |
| Latest migration | `0169_authority_owner_role_and_sole_representative_uniqueness.sql` |
| Latest migration checksum | `eb9b118899fb42fee264b25fe3f4499def06013730a57a7320a0275dd86c564e` |
| Latest migration applied_at | `2026-08-09 17:26:43.129498+00` |
| `catchmenu_hq.tenants` rows | `1` |
| `catchmenu_hq.stores` rows | `1` |

모든 DB 조회는 `BEGIN READ ONLY`와 `ROLLBACK` 사이에서 실행했다.

## 1. Live `catchmenu_hq.tenants` schema

```sql
SELECT ordinal_position, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq' AND table_name = 'tenants'
ORDER BY ordinal_position;
```

| ordinal | column | data type | nullable | default |
|---:|---|---|---|---|
| 1 | `id` | `uuid` | NO | `gen_random_uuid()` |
| 2 | `tenant_code` | `text` | NO | |
| 3 | `tenant_name` | `text` | NO | |
| 4 | `tenant_type` | `text` | NO | `'BRAND'::text` |
| 5 | `plan_tier` | `text` | NO | `'STANDARD'::text` |
| 6 | `is_active` | `boolean` | NO | `true` |
| 7 | `created_at` | `timestamp with time zone` | NO | `now()` |
| 8 | `updated_at` | `timestamp with time zone` | NO | `now()` |
| 9 | `tenant_status` | `text` | NO | `'TRIAL'::text` |
| 10 | `isolation_state` | `text` | NO | `'NONE'::text` |

**Live column count: 10.**

## 2. Live `catchmenu_common.provision_tenant`

```sql
SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS args,
       pg_get_functiondef(p.oid) AS definition,
       md5(p.prosrc) AS prosrc_md5,
       length(p.prosrc) AS prosrc_len
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'catchmenu_common'
  AND p.proname = 'provision_tenant'
ORDER BY 1, 2, 3;
```

| 항목 | 실측 |
|---|---|
| Overload count | `1` |
| Identity arguments | `p_tenant_code text, p_tenant_name text, p_owner_name text, p_owner_email text, p_owner_phone text, p_plan_code text, p_store_name text, p_store_timezone text, p_sales_channel text, p_white_label_partner_code text, p_correlation_id text` |
| Return type | `jsonb` |
| Language | `plpgsql` |
| SECURITY DEFINER | `true` |
| search_path | `catchmenu_common, catchmenu_hq, catchmenu_store, catchmenu_ledger` |
| `prosrc` MD5 | `f84ac1a81da4ccba87930bf020a3e974` |
| `prosrc` length | `4758` |

### 2.1 `pg_get_functiondef` 전문

```sql
CREATE OR REPLACE FUNCTION catchmenu_common.provision_tenant(p_tenant_code text, p_tenant_name text, p_owner_name text, p_owner_email text, p_owner_phone text, p_plan_code text, p_store_name text, p_store_timezone text DEFAULT 'Asia/Seoul'::text, p_sales_channel text DEFAULT 'DIRECT'::text, p_white_label_partner_code text DEFAULT NULL::text, p_correlation_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_common', 'catchmenu_hq', 'catchmenu_store', 'catchmenu_ledger'
AS $function$
declare
  v_tenant_id uuid;
  v_store_id uuid;
  v_plan record;
  v_settings_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 플랜 조회
  select id, plan_code, plan_tier,
         monthly_fee, included_features,
         max_stores, max_devices_per_store
  into v_plan
  from catchmenu_common.subscription_plans
  where plan_code = p_plan_code
    and is_active = true;

  if v_plan.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'plan_not_found',
      'plan_code', p_plan_code
    );
  end if;

  -- 테넌트 생성
  insert into catchmenu_hq.tenants (
    tenant_code, tenant_name,
    owner_name, owner_email, owner_phone,
    tenant_status
  ) values (
    p_tenant_code, p_tenant_name,
    p_owner_name, p_owner_email, p_owner_phone,
    'ACTIVE'
  )
  returning id into v_tenant_id;

  -- 테넌트 플랜 설정
  insert into catchmenu_common.tenant_plan_configs (
    tenant_id, plan_tier, plan_status,
    monthly_fee,
    trial_ends_at,
    enabled_features,
    max_stores,
    is_white_label,
    white_label_partner_code,
    sales_channel
  ) values (
    v_tenant_id,
    v_plan.plan_tier,
    case v_plan.plan_code
      when 'TRIAL_30' then 'TRIAL'
      else 'ACTIVE'
    end,
    v_plan.monthly_fee,
    case v_plan.plan_code
      when 'TRIAL_30'
        then now() + interval '30 days'
      else null
    end,
    v_plan.included_features,
    v_plan.max_stores,
    p_white_label_partner_code is not null,
    p_white_label_partner_code,
    p_sales_channel
  );

  -- 1호 매장 생성
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

  -- 매장 기본 설정
  insert into catchmenu_store.store_settings (
    tenant_id, store_id,
    store_mode, waiting_enabled,
    pre_order_enabled,
    kds_capacity_threshold_total,
    did_refresh_interval_seconds
  ) values (
    v_tenant_id, v_store_id,
    'NORMAL', true, true,
    30, 10
  )
  returning id into v_settings_id;

  -- 온보딩 단계 초기화
  insert into
    catchmenu_common.tenant_onboarding_log (
    tenant_id, onboarding_step,
    step_status, step_order
  )
  select
    v_tenant_id,
    step_name, 'COMPLETED', step_order
  from (
    values
    ('TENANT_CREATED', 1),
    ('STORE_CREATED', 2)
  ) as steps(step_name, step_order)
  union all
  select
    v_tenant_id,
    step_name, 'PENDING', step_order
  from (
    values
    ('MENU_UPLOADED', 3),
    ('DEVICE_REGISTERED', 4),
    ('STAFF_REGISTERED', 5),
    ('POS_CONNECTED', 6),
    ('TEST_ORDER_PLACED', 7),
    ('PAYMENT_TESTED', 8),
    ('KDS_VERIFIED', 9),
    ('GO_LIVE', 10)
  ) as steps(step_name, step_order);

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    v_tenant_id, v_store_id,
    'system', 'tenant_provisioned', 1,
    'tenant', v_tenant_id,
    null, 'ACTIVE',
    'SYSTEM',
    jsonb_build_object(
      'tenant_code', p_tenant_code,
      'plan_code', p_plan_code,
      'plan_tier', v_plan.plan_tier,
      'sales_channel', p_sales_channel,
      'white_label',
        p_white_label_partner_code is not null
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := v_tenant_id,
    p_store_id := v_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'tenant_provisioned',
    p_message :=
      '테넌트 프로비저닝 완료: '
      || p_tenant_name
      || ' | 플랜: ' || p_plan_code
      || ' | 채널: ' || p_sales_channel,
    p_rpc_name := 'provision_tenant',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'tenant_id', v_tenant_id,
      'store_id', v_store_id,
      'plan_code', p_plan_code
    )
  );

  return jsonb_build_object(
    'success', true,
    'tenant_id', v_tenant_id,
    'store_id', v_store_id,
    'tenant_code', p_tenant_code,
    'plan_tier', v_plan.plan_tier,
    'plan_status', case v_plan.plan_code
      when 'TRIAL_30' then 'TRIAL'
      else 'ACTIVE'
    end,
    'trial_ends_at', case v_plan.plan_code
      when 'TRIAL_30'
        then (now() + interval '30 days')
      else null
    end,
    'onboarding_steps', jsonb_build_object(
      'completed', 2,
      'total', 10,
      'next_step', 'MENU_UPLOADED'
    ),
    'message_code', 'tenant_provisioned'
  );
end;
$function$
```

## 3. `tenants` INSERT target-column mechanical comparison

함수의 target list를 추출해 `information_schema.columns`의 live column name과 정확히 비교했다.

| referenced_by_function | exists_in_live_table | result |
|---|---|---|
| `tenant_code` | YES | MATCH |
| `tenant_name` | YES | MATCH |
| `owner_name` | NO | PHANTOM |
| `owner_email` | NO | PHANTOM |
| `owner_phone` | NO | PHANTOM |
| `tenant_status` | YES | MATCH |

## 4. Namespace 분리 확인

```sql
SELECT table_schema, table_name, column_name, ordinal_position
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq'
  AND ((table_name = 'owners' AND column_name = 'owner_name')
    OR (table_name = 'persons' AND column_name = 'person_name')
    OR (table_name = 'tenants' AND column_name IN
        ('owner_name','owner_email','owner_phone','tenant_status')))
ORDER BY table_name, ordinal_position;
```

| Namespace-qualified name | 실재 | 비고 |
|---|---|---|
| `catchmenu_hq.owners.owner_name` | YES | `owners` ordinal 2 |
| `catchmenu_hq.persons.person_name` | NO | live `catchmenu_hq.persons` table 자체가 없음 |
| `catchmenu_hq.tenants.owner_name` | NO | 별도 namespace; `owners.owner_name`의 존재로 충족되지 않음 |
| `catchmenu_hq.tenants.owner_email` | NO | |
| `catchmenu_hq.tenants.owner_phone` | NO | |
| `catchmenu_hq.tenants.tenant_status` | YES | `tenants` ordinal 9 |

## 5. `tenant_status` 처리와 statement 순서

| 확인 항목 | Live function definition의 사실 |
|---|---|
| 신규 tenant의 `tenant_status` 표현 | literal `'ACTIVE'` |
| 첫 상태성 INSERT | `catchmenu_hq.tenants` INSERT |
| 다음 statement | `catchmenu_common.tenant_plan_configs` INSERT |
| `stores` INSERT 순서 | tenant 및 tenant-plan INSERT 뒤 |

PL/pgSQL 함수 생성 시 embedded SQL의 모든 relation column을 함수 생성 시점에 완전 검증하지 않으며, 실행 경로가 해당 statement에 도달하면 statement가 parse/plan된다. 이 함수는 유효 plan을 찾은 경로에서 `catchmenu_hq.tenants` INSERT의 target column을 해석할 때 존재하지 않는 `owner_name`(이어 `owner_email`, `owner_phone`)을 만난다. PostgreSQL의 해당 정적 실패 종류는 `undefined_column` (`SQLSTATE 42703`)이다. 함수에는 이 오류를 잡는 `EXCEPTION` block이 없다.

따라서 유효 plan 경로에서는 `stores` INSERT보다 앞선 `tenants` INSERT에서 실패하며 `stores` INSERT에 도달하지 않는다. 반대로 plan을 찾지 못한 경로는 line 27~33의 JSON return으로 INSERT 전에 종료한다. 실제 함수 호출은 수행하지 않았다.

## 6. Historical migration scan

| migration | line | 확인된 사실 |
|---|---:|---|
| `0002_create_hq_tenant_store.sql` | 8–24 | `tenants` 최초 생성. 컬럼은 `id`, `tenant_code`, `tenant_name`, `tenant_type`, `plan_tier`, `is_active`, `created_at`, `updated_at`; `owner_*` 및 `tenant_status` 없음 |
| `0034_seed_data.sql` | 15–30 | tenant seed도 최초 스키마의 컬럼만 명시; `owner_*`, `tenant_status` 없음 |
| `0082_create_saas_billing_rpc.sql` | 425–486 | `provision_tenant` 최초 정의. `tenants` INSERT에서 `owner_name`, `owner_email`, `owner_phone`, `tenant_status`를 처음부터 참조 |
| `0112_create_hq_admin_rpc.sql` | 413–425 | `onboard_tenant` 본문에서 `provision_tenant` 호출문 존재 |
| `0168_create_operational_authority_foundation.sql` | 150–155 | `tenants.tenant_status` 및 `tenants.isolation_state`를 후속 추가 |
| `0168_create_operational_authority_foundation.sql` | 64 | `owner_name`은 새 `catchmenu_hq.owners` 테이블의 컬럼이며 `tenants` 컬럼이 아님 |

`sql/migrations/*.sql` 전체에서 `tenants`에 `owner_name`, `owner_email`, `owner_phone`을 ADD/DROP/RENAME한 migration은 발견되지 않았다. `0082` 함수 생성 당시 네 target(`owner_name`, `owner_email`, `owner_phone`, `tenant_status`) 모두 `tenants`에 없었고, `0168`이 그중 `tenant_status`만 나중에 추가했다.

**Historical classification:** `owner_name` / `owner_email` / `owner_phone`은 과거 실재했다가 제거된 컬럼이 아니라, `provision_tenant` 최초 정의 시점부터 `tenants`에 없던 참조다. `tenant_status`도 함수 최초 정의 시점에는 없었으나 `0168`에서 후속 생성되어 현재는 실재한다.

## 7. Caller inventory

### 7.1 DB function bodies

```sql
SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE lower(p.prosrc) LIKE '%provision_tenant%'
  AND NOT (n.nspname = 'catchmenu_common' AND p.proname = 'provision_tenant')
ORDER BY 1,2,3;
```

| 종류 | caller | 개수 | 사실 |
|---|---|---:|---|
| Direct DB callsite | `catchmenu_common.onboard_tenant(...)` | 1 | 본문에 `v_result := catchmenu_common.provision_tenant(...)` 존재 |

Migration source의 callsite는 `0112_create_hq_admin_rpc.sql` L414–425다. 그 호출은 live `provision_tenant` identity argument names와 다른 named arguments(`p_company_name`, `p_business_number`, `p_ceo_name`, `p_ceo_phone_hash`, `p_plan_tier`, `p_locale`)를 사용한다는 사실도 함께 확인됐다.

`onboard_tenant` token을 가진 다른 DB 함수 두 개도 전문 주변 문맥을 확인했다.

| 함수 | token 형태 | 실행 호출로 계수 |
|---|---|---|
| `catchmenu_common.get_hq_dashboard(p_locale text)` | JSON의 `'action'`, `'rpc'` 문자열 값 `onboard_tenant` | NO |
| `catchmenu_common.run_opening_checklist(p_tenant_id uuid, p_store_id uuid, p_locale text)` | 안내 문자열 `'Run onboard_tenant()'` | NO |

### 7.2 Application/code search

검색한 runtime 후보 경로: `apps/`, `packages/`, `catchmenu_app/`, `supabase/`, `tests/` (모두 존재).

```text
rg -n --glob '!**/*.md' --glob '!**/sql/migrations/**' \
  'provision_tenant|onboard_tenant' \
  apps packages catchmenu_app supabase tests
```

결과: **0건**.

### 7.3 Caller count 정의

| 분류 | 수 |
|---|---:|
| Direct executable DB callsite to `provision_tenant` | 1 |
| Application/code direct callsite | 0 |
| `onboard_tenant` textual/action references (실행 호출 제외) | 2 |

## 8. Static consistency result

| 항목 | 결과 |
|---|---|
| Function target columns | 6 |
| Live-matching target columns | 3 |
| Phantom target columns | 3 (`owner_name`, `owner_email`, `owner_phone`) |
| Static executability of a path reaching tenant INSERT | **INCONSISTENT** |

이 결과는 C-1, ChangeContract, 교정 방법에 대한 판정이 아니다. 현재 live catalog와 live function definition 사이의 정적 일치 여부만 나타낸다.

## 9. Reproduction queries and searches

```sql
BEGIN READ ONLY;

SELECT current_database(), clock_timestamp(), version();

SELECT filename, checksum, applied_at, applied_by, success
FROM catchmenu_meta.migration_history
ORDER BY applied_at DESC
LIMIT 1;

SELECT (SELECT count(*) FROM catchmenu_hq.tenants) AS tenants_rows,
       (SELECT count(*) FROM catchmenu_hq.stores) AS stores_rows;

SELECT ordinal_position, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema='catchmenu_hq' AND table_name='tenants'
ORDER BY ordinal_position;

SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid),
       pg_get_functiondef(p.oid),
       md5(p.prosrc), length(p.prosrc), p.prosecdef, p.proconfig
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='catchmenu_common' AND p.proname='provision_tenant'
ORDER BY 1,2,3;

SELECT table_schema, table_name, column_name, ordinal_position
FROM information_schema.columns
WHERE table_schema='catchmenu_hq'
  AND ((table_name='owners' AND column_name='owner_name')
    OR (table_name='persons' AND column_name='person_name')
    OR (table_name='tenants' AND column_name IN
       ('owner_name','owner_email','owner_phone','tenant_status')))
ORDER BY table_name, ordinal_position;

SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid)
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE lower(p.prosrc) LIKE '%provision_tenant%'
  AND NOT (n.nspname='catchmenu_common' AND p.proname='provision_tenant')
ORDER BY 1,2,3;

SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid),
       substring(p.prosrc from greatest(strpos(lower(p.prosrc),'onboard_tenant')-180,1) for 520)
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE lower(p.prosrc) LIKE '%onboard_tenant%'
  AND p.proname <> 'onboard_tenant'
ORDER BY 1,2;

ROLLBACK;
```

```text
rg -n --glob '*.sql'
  'CREATE TABLE.*catchmenu_hq\.tenants|owner_name|owner_email|owner_phone|tenant_status|provision_tenant\('
  sql/migrations

rg -n --glob '!**/*.md' --glob '!**/sql/migrations/**'
  'provision_tenant|onboard_tenant'
  apps packages catchmenu_app supabase tests
```

## 10. Independence disclosure

조사 중 repository-wide token 검색 범위를 좁히기 전 `tools/`가 포함되어, 기존 Cursor Stage 6 보고서의 검색 결과 두 줄이 터미널에 우발적으로 노출됐다. 해당 파일을 열거나 그 내용을 근거로 사용하지 않았으며 Cursor supplemental 결과는 읽지 않았다. 본문의 schema, function definition, migration lineage, caller 수 및 최종 정적 일치 결과는 live catalog와 migration 원문에서 재도출했다.

## Final Summary

- provision_tenant overload count: **1**
- tenants actual column count: **10**
- tenants INSERT referenced columns: **`tenant_code`, `tenant_name`, `owner_name`, `owner_email`, `owner_phone`, `tenant_status`**
- phantom columns: **`owner_name`, `owner_email`, `owner_phone`**
- tenant_status inserted value: **literal `'ACTIVE'`**
- tenants INSERT order relative to stores INSERT: **tenants INSERT first; tenant-plan INSERT next; stores INSERT after both**
- provision_tenant current static executability: **INCONSISTENT**
- reason: **a path reaching the tenants INSERT targets three columns absent from the live `catchmenu_hq.tenants` catalog; it fails before the later stores INSERT**
- historical cause: **the three `owner_*` targets were absent when `provision_tenant` was first created in 0082 and were never added; `tenant_status` was also initially absent but was added later by 0168**
- caller count: **1 direct executable DB callsite (`onboard_tenant`), 0 application/code callsites; 2 additional `onboard_tenant` token occurrences are non-call text/action metadata**
