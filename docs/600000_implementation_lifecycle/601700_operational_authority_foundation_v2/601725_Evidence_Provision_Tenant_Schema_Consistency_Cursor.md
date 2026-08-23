# 601725_Evidence_Provision_Tenant_Schema_Consistency_Cursor.md

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
> **같은 작업을 Codex 도 독립 수행했다 — `601726`**(`000701` §35).
> **두 조사가 상대 결과를 참조하지 않고 동일 결론에 도달했다.**
>
> 수행: Cursor, 2026-08-23.

**수행 주체**: Cursor — Eyes-Only 독립 사실 조사  
**조사 일시 (UTC)**: 2026-08-23 04:35:52  
**함수 실행**: **없음** (SELECT / catalog only)  
**DML**: **없음**

## Environment

| 항목 | 값 |
|---|---|
| Container ID | `fb5b03ea152e…11499857` |
| Postgres image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| Server | PostgreSQL 17.6 |
| Latest migration (`catchmenu_meta.migration_history`) | `0169_authority_owner_role_and_sole_representative_uniqueness.sql` (applied 2026-08-09, success=t) |
| `catchmenu_hq.tenants` row count | 1 |

---

## Executed SQL (read-only)

### E-1. `tenants` column census

```sql
SELECT ordinal_position, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq' AND table_name = 'tenants'
ORDER BY ordinal_position;
```

### E-2. `owner_name` on owners/persons vs tenants

```sql
SELECT table_schema, table_name, column_name
FROM information_schema.columns
WHERE column_name = 'owner_name'
  AND table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY 1, 2;

SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq' AND table_name = 'tenants'
  AND column_name LIKE 'owner%';
```

### E-3. `provision_tenant` overload / hash / definition

```sql
SELECT p.oid, n.nspname, p.proname,
       pg_get_function_identity_arguments(p.oid) AS identity_args,
       pg_get_function_result(p.oid) AS result_type,
       p.prosecdef AS security_definer,
       md5(p.prosrc) AS prosrc_md5,
       length(p.prosrc) AS prosrc_len
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'catchmenu_common' AND p.proname = 'provision_tenant'
ORDER BY identity_args;

SELECT pg_get_functiondef(p.oid)
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'catchmenu_common' AND p.proname = 'provision_tenant';
```

### E-4. Caller search

```sql
SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ILIKE '%provision_tenant%'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND NOT (n.nspname = 'catchmenu_common' AND p.proname = 'provision_tenant')
ORDER BY 1, 2;
```

### E-5. `onboard_tenant` cross-reference

```sql
SELECT pg_get_functiondef(p.oid)
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'catchmenu_common' AND p.proname = 'onboard_tenant';
```

---

## 1. Live `catchmenu_hq.tenants` columns (E-1 result)

| ordinal_position | column_name | data_type | is_nullable | column_default |
|---:|---|---|---|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | tenant_code | text | NO | |
| 3 | tenant_name | text | NO | |
| 4 | tenant_type | text | NO | 'BRAND'::text |
| 5 | plan_tier | text | NO | 'STANDARD'::text |
| 6 | is_active | boolean | NO | true |
| 7 | created_at | timestamptz | NO | now() |
| 8 | updated_at | timestamptz | NO | now() |
| 9 | tenant_status | text | NO | 'TRIAL'::text |
| 10 | isolation_state | text | NO | 'NONE'::text |

**Column count: 10**

---

## 2. `catchmenu_common.provision_tenant`

| 항목 | 값 |
|---|---|
| Overload count | **1** |
| Signature | `provision_tenant(p_tenant_code text, p_tenant_name text, p_owner_name text, p_owner_email text, p_owner_phone text, p_plan_code text, p_store_name text, p_store_timezone text DEFAULT 'Asia/Seoul', p_sales_channel text DEFAULT 'DIRECT', p_white_label_partner_code text DEFAULT NULL, p_correlation_id text DEFAULT NULL)` |
| Returns | jsonb |
| SECURITY DEFINER | true |
| search_path | `catchmenu_common`, `catchmenu_hq`, `catchmenu_store`, `catchmenu_ledger` |
| prosrc md5 | `f84ac1a81da4ccba87930bf020a3e974` |
| prosrc length | 4758 |

### tenants INSERT (prosrc excerpt — live `pg_get_functiondef`)

```sql
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
```

### stores INSERT (prosrc excerpt — same function)

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

---

## 3. tenants INSERT column list vs live columns (1:1)

| INSERT column | In live `tenants`? | ordinal_position |
|---|---|---|
| tenant_code | YES | 2 |
| tenant_name | YES | 3 |
| owner_name | **NO** | — |
| owner_email | **NO** | — |
| owner_phone | **NO** | — |
| tenant_status | YES | 9 |

**Not listed in INSERT (filled by default / generated):** id, tenant_type, plan_tier, is_active, created_at, updated_at, isolation_state

---

## Token table (required format)

| token | provision_tenant에서 사용 | tenants 실제 컬럼 | 판정 |
|---|---|---|---|
| owner_name | YES — INSERT column list + `p_owner_name` value | **NO** — `tenants` 에 해당 컬럼 0건 (E-2) | **INSERT 대상 컬럼 부재** |
| owner_email | YES — INSERT column list + `p_owner_email` value | **NO** | **INSERT 대상 컬럼 부재** |
| owner_phone | YES — INSERT column list + `p_owner_phone` value | **NO** | **INSERT 대상 컬럼 부재** |
| tenant_status | YES — INSERT column list, literal `'ACTIVE'` | YES — col 9, default `'TRIAL'` | **컬럼 실재** (값은 INSERT 에서 `'ACTIVE'` 공급) |

---

## 4. `owner_name` 이름 충돌 구분 (E-2)

| 객체 | `owner_name` 실재 |
|---|---|
| `catchmenu_hq.owners` | **YES** — `owner_name text` (E-2: 1 row) |
| `catchmenu_hq.tenants` | **NO** — `owner%` 컬럼 0건 (E-2) |
| `catchmenu_hq.persons` | **NO** — table `persons` 미존재 (live schema 는 아직 `owners`) |

**`owners.owner_name` 과 `tenants.owner_name` 은 별 객체.** `provision_tenant` tenants INSERT 는 **`tenants` 쪽** 을 참조한다.

---

## 5. Historical migration evidence — `owner_*` on `tenants`

| migration | line(s) | evidence |
|---|---|---|
| `0002_create_hq_tenant_store.sql` | L8–24 | `create table catchmenu_hq.tenants` — columns: id, tenant_code, tenant_name, tenant_type, plan_tier, is_active, created_at, updated_at. **No owner_name / owner_email / owner_phone** |
| `0082_create_saas_billing_rpc.sql` | L477–485 | `provision_tenant` **first created** with `insert into catchmenu_hq.tenants (… owner_name, owner_email, owner_phone, tenant_status …)` |
| `0168_create_operational_authority_foundation.sql` | L64 | `owner_name` on **`catchmenu_hq.owners`** (not tenants) |
| `0168_create_operational_authority_foundation.sql` | L151–152 | `alter table catchmenu_hq.tenants add column tenant_status …` |

**Repo-wide migration grep** for `tenants` + `owner_name|owner_email|owner_phone` DDL (add/rename/drop): **0 matches**

| verdict | evidence |
|---|---|
| tenants 에 생성된 적 있음 | **없음** — `0002` 에 없고 이후 ADD COLUMN 없음 |
| rename 됨 | **없음** |
| drop 됨 | **없음** |
| **처음부터 tenants 테이블에 없음** | **YES** — table DDL never included these columns; RPC in `0082` references them anyway |

---

## 6. `tenant_status='ACTIVE'`

| question | fact |
|---|---|
| provision_tenant 가 직접 ACTIVE 를 넣는가 | **YES** — VALUES 절 literal `'ACTIVE'` (prosrc above) |
| default 에 맡기는가 | **NO** — INSERT 가 `tenant_status` 를 명시; column default `'TRIAL'` (`0168` L152) 은 **사용되지 않음** |
| 후속 UPDATE 인가 | **NO** — 같은 tenants INSERT 내에서 설정; 이후 tenants UPDATE 없음 (prosrc 순서상) |

`0168` CHECK `chk_tenants_status` allows `'ACTIVE'` (L170–175).

---

## 7. Caller inventory

### 7.1 DB functions referencing `provision_tenant` in `prosrc` (E-4)

| # | schema | function | notes |
|---:|---|---|---|
| 1 | `catchmenu_common` | `onboard_tenant(...)` | **Direct call** in prosrc L44–55 (live def) |

`pg_depend` (refobjid = provision_tenant, deptype='n'): **0 rows**

### 7.2 `onboard_tenant` → `provision_tenant` (E-5)

- **Calls `provision_tenant`:** YES (`prosrc` contains `v_result := catchmenu_common.provision_tenant(`)
- **Pre-check before call:** `select 1 from catchmenu_hq.tenants where business_number = p_business_number` — **`business_number` column not in live tenants** (E-4 supplemental query: 0 rows)
- **Named arguments passed to `provision_tenant`:** `p_company_name`, `p_business_number`, `p_ceo_name`, `p_ceo_phone_hash`, `p_plan_tier`, `p_store_name`, `p_store_timezone`, `p_locale` — **none of these names appear on live `provision_tenant` signature** (which uses `p_tenant_code`, `p_tenant_name`, `p_owner_name`, …)

### 7.3 Migration / grant references (not live callers)

| location | role |
|---|---|
| `0082_create_saas_billing_rpc.sql` L1456–1464 | GRANT EXECUTE to `authenticated` |
| `0096_schema_final_validation.sql` L211 | function name in validation list |
| `0091_create_saas_readiness_final_rpc.sql` L1846 | comment reference only |
| `0112_create_hq_admin_rpc.sql` L413–425 | source of live `onboard_tenant` body |

### 7.4 App / test repo search

| path | `provision_tenant` matches |
|---|---|
| `apps/` | **0** |
| `packages/` | **0** |
| `catchmenu_app/` | **0** |
| `tests/` | **0** |
| `supabase/` | **0** |

**External caller via GRANT:** `authenticated` role has EXECUTE (`0082` L1460–1464) — no in-repo client call found.

---

## 8. PL/pgSQL statement order — stores reachable if tenants INSERT fails?

**Function body order (live prosrc, after successful plan lookup):**

| step | statement |
|---:|---|
| 1 | `insert into catchmenu_hq.tenants (…)` |
| 2 | `insert into catchmenu_common.tenant_plan_configs (…)` |
| 3 | `insert into catchmenu_hq.stores (…)` |
| 4 | `insert into catchmenu_store.store_settings (…)` |
| 5 | `insert into catchmenu_common.tenant_onboarding_log (…)` |
| 6 | `insert into catchmenu_ledger.events (…)` |
| 7 | `perform catchmenu_common.log_diagnostic(…)` |
| 8 | `return jsonb_build_object(…)` |

**Early exit before tenants INSERT:** if `v_plan.id is null` → `return jsonb_build_object('success', false, …)` (plan_not_found).

**Exception handler:** none in function body.

---

## Required conclusions

### A. tenants actual columns

10 columns — see §1 table (id, tenant_code, tenant_name, tenant_type, plan_tier, is_active, created_at, updated_at, tenant_status, isolation_state).

### B. provision_tenant tenants INSERT exact columns

`(tenant_code, tenant_name, owner_name, owner_email, owner_phone, tenant_status)` — 6 columns, COLUMN_LIST INSERT.

### C. phantom columns

**`[owner_name, owner_email, owner_phone]`**

(`tenant_status` is **not** phantom — column exists.)

### D. tenant_status value supplied

**Direct literal `'ACTIVE'` in INSERT VALUES** — not column default, not post-INSERT UPDATE.

### E. stores INSERT reachable before tenants INSERT success?

**NO**

**근거:** Sequential PL/pgSQL in single `BEGIN` block without exception handler. `stores` INSERT (step 3) follows `tenants` INSERT (step 1). If step 1 raises (e.g. undefined column), execution aborts before step 3. Early return only occurs on plan-not-found **before** tenants INSERT.

### F. caller inventory

| kind | count | detail |
|---|---|---|
| In-DB direct caller (prosrc) | 1 | `catchmenu_common.onboard_tenant` |
| App code | 0 | repo search |
| Tests | 0 | repo search |
| Grant-only external | 1 role | `authenticated` EXECUTE on `provision_tenant` |
| onboard_tenant overloads | 1 | same signature as `0112` migration |

### G. historical migration evidence

**`owner_name` / `owner_email` / `owner_phone` on `catchmenu_hq.tenants`:** **처음부터 없음** — never in `0002` CREATE; never ADD COLUMN in any migration; RPC `0082` INSERT predates/alongside schema without matching DDL.

**`tenant_status` on tenants:** added **`0168` L151–152** (default `'TRIAL'`).

**`owner_name` on `owners`:** **`0168` L64** (separate table).

### H. unresolved facts

| # | fact |
|---:|---|
| 1 | **Runtime call frequency** — no EXECUTE performed; whether any session invokes `provision_tenant` outside repo is unknown |
| 2 | **`onboard_tenant` ↔ `provision_tenant` signature mismatch** — live `onboard_tenant` passes named args (`p_company_name`, …) not present on `provision_tenant` signature; both functions exist in catalog; runtime resolution not tested |
| 3 | **`onboard_tenant` pre-check** — references `tenants.business_number` (column absent in live schema) before calling `provision_tenant` |
| 4 | **stores INSERT (out of tenants scope but same function)** — uses `store_type = 'RESTAURANT'`; live `0002` `chk_stores_type` allows `DINE_IN`, `TAKEOUT`, `HYBRID`, `DELIVERY_ONLY` only — not verified whether constraint unchanged at runtime |
| 5 | **Prior docs claiming `provision_tenant` “정상”** — e.g. contract text referencing stores-only phantom check; **this scan did not read Codex/other verifier outputs**; live prosrc shows **tenants** phantom columns independent of stores path |

---

## Summary table

| item | value |
|---|---|
| Function exists in catalog | YES (1 overload) |
| tenants INSERT phantom columns | **3** (`owner_name`, `owner_email`, `owner_phone`) |
| tenants INSERT non-phantom explicit columns | 3 (`tenant_code`, `tenant_name`, `tenant_status`) |
| `tenant_status` supplied value | `'ACTIVE'` (explicit) |
| stores INSERT before tenants success | **NO** (sequential order) |
| Direct DB caller | `onboard_tenant` only (prosrc) |
| In-repo app caller | **0** |
