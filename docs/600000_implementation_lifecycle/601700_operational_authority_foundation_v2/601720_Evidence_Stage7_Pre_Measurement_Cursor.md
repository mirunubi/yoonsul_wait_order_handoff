# 601720_Evidence_Stage7_Pre_Measurement_Cursor.md

> ⚠️ **Stage 7 사전 측정 · 판정이 아니다**
>
> `601716` 5판이 지정한 PRE-5 / PRE-6 / PRE-7 의 실측이다.
>
> ```text
> PRE-5   tenants 행 수 — backfill 기대값의 근거
> PRE-6   stores 실제 컬럼 — N-2″ 판정 근거
> PRE-7   두 RPC prosrc 해시 — "수정되지 않았음" 의 대조 기준
> ```
>
> **PRE-7 해시는 구현 후 대조에 사용된다.**
> 이 값이 확보되기 전에는 "두 RPC 를 수정하지 않았음"을 증명할 수 없다.
>
> **같은 작업을 Codex 도 독립 수행했다 — `601721`**(`000701` §35).
> **두 조사가 상대 결과를 참조하지 않고 md5 까지 동일한 값에 도달했다.**
>
> 수행: Cursor, 2026-08-23. 환경 `postgres:17.6.1.140`, migration `0169`.

**Performing agent:** Cursor  
**Basis:** `601716` 5판 Stage 7 pre-measures / `000701` §34.1 / §35  
**Scope:** Investigation only. Facts only. No N-2″ judgment.

---

## Environment (live)

| Item | Value |
|---|---|
| Container ID | `fb5b03ea152e` |
| Postgres image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| PostgreSQL version | `PostgreSQL 17.6 on x86_64-pc-linux-gnu` |
| Query timestamp (KST) | `2026-08-23 10:00:02.027263` |
| Latest `catchmenu_meta.migration_history` | `0169_authority_owner_role_and_sole_representative_uniqueness.sql` — applied `2026-08-09 17:26:43.129498+00`, success `t` |
| Connection | `docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres` |

---

## PRE-5. `tenants` row count

### Query

```sql
SELECT count(*) FROM catchmenu_hq.tenants;
SELECT tenant_status, isolation_state, count(*)
FROM catchmenu_hq.tenants GROUP BY 1,2;
```

### Result

| `catchmenu_hq.tenants` row count | **1** |

| `tenant_status` | `isolation_state` | count |
|---|---|---:|
| TRIAL | NONE | 1 |

**Backfill expected row count (per task):** **1**

---

## PRE-6. `stores` column census — N-2″ input

### Query

```sql
SELECT ordinal_position, column_name, data_type,
       is_nullable, column_default
FROM information_schema.columns
WHERE table_schema='catchmenu_hq' AND table_name='stores'
ORDER BY ordinal_position;

SELECT column_name FROM information_schema.columns
WHERE table_schema='catchmenu_hq' AND table_name='stores'
  AND column_name IN ('brand_id','extra_metadata');
```

### Result — column list

| ordinal | column_name | data_type | is_nullable | column_default |
|---:|---|---|---|---|
| 1 | `id` | uuid | NO | gen_random_uuid() |
| 2 | `tenant_id` | uuid | NO |  |
| 3 | `store_code` | text | NO |  |
| 4 | `store_name` | text | NO |  |
| 5 | `store_type` | text | NO | 'DINE_IN'::text |
| 6 | `store_status` | text | NO | 'PREPARING'::text |
| 7 | `address` | text | YES |  |
| 8 | `phone` | text | YES |  |
| 9 | `timezone` | text | NO | 'Asia/Seoul'::text |
| 10 | `business_hours` | jsonb | YES |  |
| 11 | `is_active` | boolean | NO | true |
| 12 | `opened_on` | date | YES |  |
| 13 | `closed_on` | date | YES |  |
| 14 | `created_at` | timestamp with time zone | NO | now() |
| 15 | `updated_at` | timestamp with time zone | NO | now() |
| 16 | `legal_entity_id` | uuid | YES |  |

### Column count cross-check

| Source | Column count |
|---|---:|
| Live `information_schema.columns` (`catchmenu_hq.stores`) | **16** |
| `601701` §4.5 B-1 (`stores` table row) | **16** |
| Difference (live − `601701`) | **+0** |

### Target columns — existence on `catchmenu_hq.stores`

| Column | Live table column exists? |
|---|---|
| `stores.brand_id` | **No** |
| `stores.extra_metadata` | **No** |

### `601701` §4.5 B-1 recorded columns (does not list `brand_id` / `extra_metadata`)

| # | Column(s) in `601701` |
|---:|---|
| 1 | `id` |
| 2 | `tenant_id` |
| 3 | `store_code` |
| 4 | `store_name` |
| 5 | `store_type` |
| 6 | `store_status` |
| 7 | `address` / `phone` |
| 8 | `timezone` |
| 9 | `business_hours` |
| 10 | `is_active` |
| 11 | `opened_on` / `closed_on` |
| 12 | `created_at` / `updated_at` |
| 13 | `legal_entity_id` |

### Factual `prosrc` token presence (RPC bodies, not table DDL)

| Function | `brand_id` in `prosrc` | `extra_metadata` in `prosrc` |
|---|---|---|
| `catchmenu_common.provision_tenant` | no | no |
| `catchmenu_hq.create_franchise_store` | no | yes |

---

## PRE-7. Two RPC `prosrc` hash baseline

### Query

```sql
SELECT n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS args,
       md5(p.prosrc) AS prosrc_md5,
       length(p.prosrc) AS prosrc_len
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname IN ('provision_tenant','create_franchise_store')
ORDER BY 1,2;
```

### Result

| # | Schema | Function | Args | `prosrc_md5` | `prosrc_len` | Overloads |
|---:|---|---|---|---|---:|---:|
| 1 | `catchmenu_common` | `provision_tenant` | `p_tenant_code text, p_tenant_name text, p_owner_name text, p_owner_email text, p_owner_phone text, p_plan_code text, p_store_name text, p_store_timezone text, p_sales_channel text, p_white_label_partner_code text, p_correlation_id text` | `f84ac1a81da4ccba87930bf020a3e974` | 4758 | 1 |
| 2 | `catchmenu_hq` | `create_franchise_store` | `p_tenant_id uuid, p_store_code text, p_store_name text, p_store_type text, p_address text, p_phone text, p_timezone text, p_opened_on date, p_franchisee_name text, p_franchisee_phone text, p_business_hours jsonb, p_actor_type text, p_actor_id uuid, p_correlation_id text` | `87511a95676a41d2c95866e0c2da8b7f` | 3460 | 1 |

**Overload count:** **2** (all recorded above)

### `prosrc` full text

#### `catchmenu_common.provision_tenant`

```sql

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
```

#### `catchmenu_hq.create_franchise_store`

```sql

declare
  v_store_id uuid;
  v_audit_id uuid;
  v_business_day date;
begin
  if trim(coalesce(p_store_code, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_code_required'
    );
  end if;

  if p_store_type not in (
    'DINE_IN', 'TAKEOUT', 'DELIVERY_ONLY', 'HYBRID'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_store_type'
    );
  end if;

  -- duplicate check
  if exists (
    select 1
    from catchmenu_hq.stores
    where tenant_id = p_tenant_id
      and store_code = p_store_code
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_code_already_exists',
      'store_code', p_store_code
    );
  end if;

  v_business_day := (timezone(
    coalesce(p_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- provision store
  insert into catchmenu_hq.stores (
    tenant_id,
    store_code, store_name, store_type,
    store_status, address, phone, timezone,
    business_hours, opened_on, is_active,
    extra_metadata
  ) values (
    p_tenant_id,
    p_store_code, p_store_name, p_store_type,
    'ACTIVE', p_address, p_phone,
    coalesce(p_timezone, 'Asia/Seoul'),
    p_business_hours,
    coalesce(p_opened_on, current_date),
    true,
    jsonb_build_object(
      'franchisee_name', p_franchisee_name,
      'franchisee_phone', p_franchisee_phone
    )
  )
  returning id into v_store_id;

  -- auto-initialize store settings
  perform catchmenu_store.ensure_store_settings(
    p_tenant_id, v_store_id
  );

  -- auto-initialize point rules
  perform catchmenu_store.ensure_point_rules(p_tenant_id);

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, v_store_id,
    'system', 'franchise_store_created', 1,
    'store', v_store_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'store_code', p_store_code,
      'store_name', p_store_name,
      'store_type', p_store_type,
      'franchisee_name', p_franchisee_name
    ),
    p_correlation_id,
    v_business_day,
    coalesce(p_timezone, 'Asia/Seoul'),
    now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := v_store_id,
    p_audit_domain := 'system',
    p_audit_type := 'franchise_store_created',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store',
    p_subject_id := v_store_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'store_code', p_store_code,
      'store_name', p_store_name,
      'store_type', p_store_type,
      'franchisee_name', p_franchisee_name
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone :=
      coalesce(p_timezone, 'Asia/Seoul')
  );

  return jsonb_build_object(
    'success', true,
    'store_id', v_store_id,
    'store_code', p_store_code,
    'store_name', p_store_name,
    'store_type', p_store_type,
    'store_status', 'ACTIVE',
    'settings_initialized', true,
    'audit_id', v_audit_id,
    'message_code', 'franchise_store_created'
  );
end;
```

---

## Summary

| Item | Value |
|---|---|
| PRE-5 `tenants` row count | **1** |
| PRE-6 `stores` column count | **16** |
| PRE-6 `brand_id` exists on `stores` | **No** |
| PRE-6 `extra_metadata` exists on `stores` | **No** |
| PRE-7 `provision_tenant` md5 | `f84ac1a81da4ccba87930bf020a3e974` |
| PRE-7 `create_franchise_store` md5 | `87511a95676a41d2c95866e0c2da8b7f` |

---

*Generated by Cursor live pre-measure for Stage 7. No N-2″ judgment.*
