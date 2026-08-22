# 601714_Evidence_Stage4_Logic_Gap_Survey_Cursor.md

> ⚠️ **Logic §6 미해결 항목 조사 · 사실 조사이며 판정이 아니다**
>
> `601713` Logic §6이 기록한 미해결 9건 중,
> **추가 조사로 답할 수 있는 5건**(Q-2/Q-3/Q-4/Q-5/Q-8)을 확인한 것이다.
>
> 나머지 4건(Q-1/Q-6/Q-7/Q-9)은 **Human 선언 사항**이며 조사 대상이 아니다.
>
> **교정 방법을 제안하지 않는다.** 판정은 ChangeContract(`601717`)가 한다.
>
> **같은 작업을 Codex 도 독립 수행했다 —&#x20;****`601715`**(`000701` §35).
>
> ⚠️ **조사 환경**: `postgres:17.6.1.156`.
> `601701`/`601711`/`601712` 등 기존 조사가 수행된 PC 환경(`postgres:17.6.1.140`)과
> **다른 컨테이너**다. 적용된 최신 migration 은 양쪽 모두 `0169` 로 확인되었다.
>
> 수행: Cursor, 2026-08-21~22.

Agent: Cursor  
Role: investigation only (facts)  
Codex peer file: not read / not referenced  
Wrote: `tools/_wp601700_s4_logic_gap_cursor.md`

---

## Environment

| Item | Value |
|---|---|
| Container name | `supabase_db_yoonsul_wait_order_handoff` |
| Container ID | `b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec` |
| Image | `public.ecr.aws/supabase/postgres:17.6.1.156` |
| `SELECT version()` | `PostgreSQL 17.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 15.2.0, 64-bit` |
| First successful query time (UTC) | `2026-08-21 07:20:04.521674+00` |
| Final query time (UTC) | `2026-08-22 06:03:45.868461+00` (container recheck) / Q-8 exact-field pass `2026-08-22` session |
| Note vs prior PC image | This environment reports `postgres:17.6.1.156`. Prior investigations cited `postgres:17.6.1.140`. Image tag differs. |
| Mid-run event | Container exited with code `137` during the session; later restarted with `docker start`; subsequent reads succeeded against the same container ID and image `17.6.1.156`. |

### Latest `catchmenu_meta.migration_history` (top by `applied_at`)

| filename | checksum (sha256) | success | applied_at |
|---|---|---|---|
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | `eb9b118899fb42fee264b25fe3f4499def06013730a57a7320a0275dd86c564e` | true | `2026-08-13 18:15:41.405072+00` |
| `0168_create_operational_authority_foundation.sql` | `263615fdb552d9297456799986962e78c2fd13ef845c50449e65298c8031f194` | true | `2026-08-13 18:15:40.989263+00` |
| `0135_create_flutter_mvp_start_package.sql` | `26b08ad7a3b1b06c3f59afe57dabb3dc940edd54f1c39ebce3bd6fe5d9244e51` | true | `2026-08-07 04:55:01.375815+00` |
| `0134_create_technology_credit_package.sql` | `72b1a166a38ace618ca4dee1eb9bb006c161b7a96457e3b7076ccb583c7a8bd9` | true | `2026-08-07 04:55:00.809168+00` |
| `0133_create_final_validation_package.sql` | `9cb185b1bfeadd507aa183865a86afe2756e3cb32c76f768101cdc625bc3627b` | true | `2026-08-07 04:55:00.245619+00` |

Latest single row recheck: `0169_...|true|2026-08-13 18:15:41.405072+00`

### Base table counts by schema (`information_schema.tables`, exclude `pg_catalog` / `information_schema`)

| schema | count |
|---|---|
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
| `net` | 2 |
| `realtime` | 8 |
| `storage` | 10 |
| `supabase_functions` | 2 |
| `vault` | 1 |
| **TOTAL** | **243** |

### Environment queries executed

```sql
SELECT version();
SELECT now() AS queried_at;

SELECT filename || '|' || checksum || '|' || success::text || '|' || applied_at::text AS row
FROM catchmenu_meta.migration_history
ORDER BY applied_at DESC NULLS LAST, filename DESC
LIMIT 5;

SELECT table_schema || '|' || count(*)::text
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN ('pg_catalog','information_schema')
GROUP BY table_schema
ORDER BY table_schema;

SELECT count(*)
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN ('pg_catalog','information_schema');
```

---

## Q-2. `chk_lepr_role_type` allowed values (+ related CHECK)

### 실행 쿼리

```sql
SELECT 'LEPR' AS tbl, conname, pg_get_constraintdef(oid) AS def
FROM pg_constraint
WHERE conrelid = 'catchmenu_hq.legal_entity_person_roles'::regclass AND contype = 'c'
UNION ALL
SELECT 'REPS', conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'catchmenu_hq.legal_entity_representatives'::regclass AND contype = 'c'
UNION ALL
SELECT 'ENTITIES', conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'catchmenu_hq.legal_entities'::regclass AND contype = 'c'
UNION ALL
SELECT 'OWNERS', conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'catchmenu_hq.owners'::regclass AND contype = 'c'
ORDER BY 1, 2;

SELECT count(*) AS owners_check_count
FROM pg_constraint
WHERE conrelid = 'catchmenu_hq.owners'::regclass AND contype = 'c';
```

### 결과

| tbl | conname | def |
|---|---|---|
| ENTITIES | `chk_legal_entities_crn_not_for_sole` | `CHECK (((entity_type <> 'SOLE_PROPRIETOR'::text) OR (corporate_registration_number IS NULL)))` |
| ENTITIES | `chk_legal_entities_entity_type` | `CHECK ((entity_type = ANY (ARRAY['SOLE_PROPRIETOR'::text, 'CORPORATION'::text, 'PARTNERSHIP'::text, 'NON_PROFIT'::text])))` |
| ENTITIES | `chk_legal_entities_status` | `CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'SUSPENDED'::text, 'CLOSED'::text])))` |
| LEPR | `chk_lepr_effective_range` | `CHECK (((effective_to IS NULL) OR (effective_to >= effective_from)))` |
| LEPR | `chk_lepr_ownership_percent` | `CHECK (((ownership_percent IS NULL) OR ((ownership_percent >= (0)::numeric) AND (ownership_percent <= (100)::numeric))))` |
| LEPR | `chk_lepr_role_type` | `CHECK ((role_type = ANY (ARRAY['OWNER'::text, 'REPRESENTATIVE'::text, 'DIRECTOR'::text, 'EXECUTIVE'::text, 'INVESTOR'::text])))` |
| REPS | `chk_ler_effective_range` | `CHECK (((effective_to IS NULL) OR (effective_to >= effective_from)))` |
| REPS | `chk_ler_representation_mode` | `CHECK ((representation_mode = ANY (ARRAY['SOLE'::text, 'JOINT'::text, 'INDIVIDUAL'::text])))` |
| OWNERS | (none) | owners CHECK count = **0건** |

### 사실 요약

- `chk_lepr_role_type` 허용값: `OWNER`, `REPRESENTATIVE`, `DIRECTOR`, `EXECUTIVE`, `INVESTOR`.
- `legal_entity_representatives` CHECK 2건; `legal_entities` CHECK 3건; `owners` CHECK **0건**.

---

## Q-3. `set_updated_at()` definition and triggers

### 실행 쿼리

```sql
SELECT n.nspname, p.proname, p.prosecdef,
       COALESCE(array_to_string(p.proconfig, '; '), '<null>') AS proconfig,
       p.prosrc
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname = 'set_updated_at'
ORDER BY n.nspname, p.proname;

SELECT n.nspname AS schema_name,
       c.relname AS table_name,
       t.tgname AS trigger_name,
       pg_get_triggerdef(t.oid) AS trigger_def
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_proc p ON p.oid = t.tgfoid
WHERE NOT t.tgisinternal
  AND p.proname = 'set_updated_at'
ORDER BY n.nspname, c.relname, t.tgname;

SELECT count(*) AS trigger_count
FROM pg_trigger t
JOIN pg_proc p ON p.oid = t.tgfoid
WHERE NOT t.tgisinternal AND p.proname = 'set_updated_at';

SELECT n.nspname AS schema_name, count(*) AS trg_count
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_proc p ON p.oid = t.tgfoid
WHERE NOT t.tgisinternal AND p.proname = 'set_updated_at'
GROUP BY n.nspname
ORDER BY 1;
```

### 결과 — function

| nspname | proname | prosecdef (SECURITY DEFINER) | proconfig | prosrc |
|---|---|---|---|---|
| `catchmenu_common` | `set_updated_at` | `t` (true) | `search_path=pg_catalog` | `begin new.updated_at := now(); return new; end;` |

Function row count for name `set_updated_at`: **1건** (schema `catchmenu_common` only).

### 결과 — trigger counts

| schema_name | trg_count |
|---|---|
| catchmenu_agent | 4 |
| catchmenu_common | 22 |
| catchmenu_gateway | 1 |
| catchmenu_hq | 18 |
| catchmenu_integrations | 12 |
| catchmenu_kds | 1 |
| catchmenu_knowledge | 7 |
| catchmenu_ledger | 1 |
| catchmenu_payment | 3 |
| catchmenu_pos | 9 |
| catchmenu_store | 36 |
| **TOTAL** | **114** |

`catchmenu_hq` triggers include (among others):  
`legal_entities` → `trg_legal_entities_updated_at`;  
`legal_entity_person_roles` → `trg_lepr_updated_at`;  
`legal_entity_representatives` → `trg_ler_updated_at`;  
`owners` → `trg_owners_updated_at`.

Full per-table trigger list was returned by the ordered SELECT (114 rows). Pattern for each:  
`CREATE TRIGGER ... BEFORE UPDATE ON <schema>.<table> FOR EACH ROW EXECUTE FUNCTION catchmenu_common.set_updated_at()`.

### 사실 요약

- `set_updated_at` is SECURITY DEFINER (`prosecdef = t`) with `search_path=pg_catalog`.
- Body sets `new.updated_at := now()` and returns `new`.
- Non-internal triggers calling it: **114건** across 11 catchmenu schemas, including `owners` and the other three authority tables.

---

## Q-4. Access subjects for the new 4 tables

Tables in scope: `catchmenu_hq.owners`, `legal_entities`, `legal_entity_representatives`, `legal_entity_person_roles`.

### 실행 쿼리

```sql
SELECT r.rolname AS member,
       r.rolcanlogin,
       r.rolbypassrls,
       m.admin_option,
       g.rolname AS role_name
FROM pg_auth_members m
JOIN pg_roles g ON g.oid = m.roleid
JOIN pg_roles r ON r.oid = m.member
WHERE g.rolname = 'catchmenu_authority_owner'
ORDER BY r.rolname;

SELECT rolname, rolcanlogin, rolbypassrls, rolsuper
FROM pg_roles
WHERE rolname = 'catchmenu_authority_owner';

SELECT m.oid, r.rolname AS member, m.admin_option
FROM pg_auth_members m
JOIN pg_roles g ON g.oid = m.roleid
JOIN pg_roles r ON r.oid = m.member
WHERE g.rolname = 'catchmenu_authority_owner';

SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ILIKE '%legal_entity_person_roles%'
   OR p.prosrc ILIKE '%legal_entity_representatives%'
   OR p.prosrc ILIKE '%legal_entities%'
   OR p.prosrc ILIKE '%owners%'
ORDER BY 1,2;

SELECT n.nspname, p.proname
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ILIKE '%legal_entity_person_roles%'
   OR p.prosrc ILIKE '%legal_entity_representatives%'
   OR p.prosrc ILIKE '%catchmenu_hq.legal_entities%'
   OR p.prosrc ILIKE '%catchmenu_hq.owners%'
ORDER BY 1,2;

SELECT count(*) AS pg_proc_depend_count
FROM pg_depend d
JOIN pg_class src ON src.oid = d.refobjid
JOIN pg_namespace nsrc ON nsrc.oid = src.relnamespace
WHERE nsrc.nspname = 'catchmenu_hq'
  AND src.relname IN ('owners','legal_entities','legal_entity_representatives','legal_entity_person_roles')
  AND d.classid = 'pg_proc'::regclass;

SELECT
  nfk.nspname AS fk_schema,
  cfk.relname AS fk_table,
  con.conname,
  nref.nspname AS ref_schema,
  cref.relname AS ref_table,
  pg_get_constraintdef(con.oid) AS def
FROM pg_constraint con
JOIN pg_class cfk ON cfk.oid = con.conrelid
JOIN pg_namespace nfk ON nfk.oid = cfk.relnamespace
JOIN pg_class cref ON cref.oid = con.confrelid
JOIN pg_namespace nref ON nref.oid = cref.relnamespace
WHERE con.contype = 'f'
  AND nref.nspname = 'catchmenu_hq'
  AND cref.relname IN ('owners','legal_entities','legal_entity_representatives','legal_entity_person_roles')
ORDER BY 1,2,3;

SELECT
  CASE WHEN nfk.nspname = 'catchmenu_hq' THEN 'same_schema' ELSE 'other_schema' END AS scope,
  count(*) AS fk_count
FROM pg_constraint con
JOIN pg_class cfk ON cfk.oid = con.conrelid
JOIN pg_namespace nfk ON nfk.oid = cfk.relnamespace
JOIN pg_class cref ON cref.oid = con.confrelid
JOIN pg_namespace nref ON nref.oid = cref.relnamespace
WHERE con.contype = 'f'
  AND nref.nspname = 'catchmenu_hq'
  AND cref.relname IN ('owners','legal_entities','legal_entity_representatives','legal_entity_person_roles')
GROUP BY 1;
```

### 결과 — role / members

| rolname | rolcanlogin | rolbypassrls | rolsuper |
|---|---|---|---|
| `catchmenu_authority_owner` | `f` | `t` | `f` |

| pg_auth_members.oid | member | admin_option |
|---|---|---|
| 27328 | `postgres` | `t` |
| 27329 | `postgres` | `f` |

Member list size: **2 rows**, both `member = postgres` (two distinct `pg_auth_members` oids; one with `admin_option=true`, one with `admin_option=false`).  
`postgres`: `rolcanlogin=t`, `rolbypassrls=t`.

### 결과 — functions referencing tables

| search | result |
|---|---|
| `prosrc` ILIKE any of the four table name patterns (including bare `%owners%` / `%legal_entities%`) | **0건** |
| `prosrc` ILIKE `legal_entity_person_roles` / `legal_entity_representatives` / `catchmenu_hq.legal_entities` / `catchmenu_hq.owners` | **0건** |
| `pg_depend` → `pg_proc` dependents on the 4 tables | **0건** |

### 결과 — FK referencing the 4 tables

| fk_schema | fk_table | conname | ref_table | def |
|---|---|---|---|---|
| catchmenu_hq | legal_entity_person_roles | legal_entity_person_roles_legal_entity_id_fkey | legal_entities | FOREIGN KEY (legal_entity_id) REFERENCES catchmenu_hq.legal_entities(id) |
| catchmenu_hq | legal_entity_person_roles | legal_entity_person_roles_owner_id_fkey | owners | FOREIGN KEY (owner_id) REFERENCES catchmenu_hq.owners(id) |
| catchmenu_hq | legal_entity_representatives | legal_entity_representatives_legal_entity_id_fkey | legal_entities | FOREIGN KEY (legal_entity_id) REFERENCES catchmenu_hq.legal_entities(id) |
| catchmenu_hq | legal_entity_representatives | legal_entity_representatives_owner_id_fkey | owners | FOREIGN KEY (owner_id) REFERENCES catchmenu_hq.owners(id) |
| catchmenu_hq | stores | fk_stores_legal_entity_id | legal_entities | FOREIGN KEY (legal_entity_id) REFERENCES catchmenu_hq.legal_entities(id) |

| scope | fk_count |
|---|---|
| same_schema | 5 |
| other_schema | **0건** |

### 사실 요약

- `catchmenu_authority_owner`: NOLOGIN (`rolcanlogin=f`), BYPASSRLS (`rolbypassrls=t`), not superuser.
- Only member observed: `postgres`, appearing twice in `pg_auth_members` with both `admin_option` true and false.
- Function body (`prosrc`) and `pg_depend`/`pg_proc` references to the 4 tables: **0건**.
- FK from other schemas to the 4 tables: **0건**. Same-schema FK: **5건** (including `catchmenu_hq.stores` → `legal_entities`).

---

## Q-5. `merchant_accounts` physical existence

### 실행 쿼리

```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name ILIKE '%merchant%'
ORDER BY 1,2;

SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE column_name ILIKE '%merchant%'
ORDER BY 1,2,3;

SELECT t AS name,
  EXISTS (
    SELECT 1 FROM information_schema.tables x
    WHERE x.table_name = t
  ) AS any_schema_exists
FROM (VALUES
  ('merchant_accounts'),
  ('merchant_companies'),
  ('merchant_stores')
) v(t);
```

### 결과

| check | result |
|---|---|
| tables with name ILIKE `%merchant%` | **0건** |
| `merchant_accounts` exists | `f` |
| `merchant_companies` exists | `f` |
| `merchant_stores` exists | `f` |

Columns with name ILIKE `%merchant%`:

| table_schema | table_name | column_name | data_type |
|---|---|---|---|
| catchmenu_integrations | pos_store_configs | merchant_id | text |
| catchmenu_integrations | toss_pos_transactions | toss_pos_merchant_id | text |
| catchmenu_integrations | van_settlements | van_merchant_id | text |
| catchmenu_integrations | van_transactions | van_merchant_id | text |
| catchmenu_payment | van_transactions | van_merchant_id | text |

### 사실 요약

- `merchant_accounts` / `merchant_companies` / `merchant_stores` tables: **없음 (0건)**.
- Similar table names containing `merchant`: **0건**.
- Columns containing `merchant`: **5건** (integration/payment merchant id fields only).

---

## Q-8. Onboarding evidence fields vs live schema

### 실행 쿼리

```sql
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema LIKE 'catchmenu%'
  AND (
    column_name ILIKE '%business_registration%'
    OR column_name ILIKE '%legal_entity_name%'
    OR column_name ILIKE '%representative_name%'
    OR column_name ILIKE '%business_address%'
    OR column_name ILIKE '%business_category%'
    OR column_name ILIKE '%tax_invoice%'
    OR column_name ILIKE '%settlement_owner%'
    OR column_name ILIKE '%contract_signer%'
    OR column_name ILIKE '%verification_state%'
    OR column_name ILIKE '%registration_number%'
    OR column_name ILIKE '%representative%'
    OR column_name ILIKE '%tax_invoice_email%'
    OR column_name ILIKE '%legal_name%'
  )
ORDER BY 1,2,3;

SELECT field,
       EXISTS (
         SELECT 1 FROM information_schema.columns c
         WHERE c.column_name = field
       ) AS exact_col_exists
FROM (VALUES
  ('business_registration_number'),
  ('legal_entity_name'),
  ('representative_name'),
  ('business_address'),
  ('business_category'),
  ('tax_invoice_email'),
  ('settlement_owner'),
  ('contract_signer'),
  ('verification_state')
) v(field)
ORDER BY 1;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND (
    table_name ILIKE '%sales_lead%'
    OR table_name ILIKE '%tenant_candidate%'
    OR table_name ILIKE '%onboarding%'
    OR table_name ILIKE '%intake%'
  )
ORDER BY 1,2;

SELECT ordinal_position, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq' AND table_name = 'legal_entities'
ORDER BY ordinal_position;

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq'
  AND table_name IN ('owners','legal_entity_representatives','legal_entity_person_roles')
ORDER BY table_name, ordinal_position;
```

### 결과 — exact name existence (any schema)

| field (010901 list) | exact_col_exists |
|---|---|
| business_registration_number | `t` |
| legal_entity_name | `f` |
| representative_name | `f` |
| business_address | `f` |
| business_category | `f` |
| tax_invoice_email | `f` |
| settlement_owner | `f` |
| contract_signer | `f` |
| verification_state | `f` |

### 결과 — similar / related columns found under catchmenu%

| table_schema | table_name | column_name | data_type |
|---|---|---|---|
| catchmenu_hq | legal_entities | business_registration_number | text |
| catchmenu_hq | legal_entities | corporate_registration_number | text |
| catchmenu_hq | legal_entities | legal_name | text |
| catchmenu_store | staff | legal_name | text |

(ILIKE patterns for representative_name / business_address / business_category / tax_invoice / settlement_owner / contract_signer / verification_state / representative: no additional catchmenu rows beyond the four above for the registration/legal_name group.)

### 결과 — related tables

| table_schema | table_name |
|---|---|
| catchmenu_common | tenant_onboarding_log |
| catchmenu_integrations | delivery_intake_log |

| name pattern | count |
|---|---|
| `%sales_lead%` | **0건** |
| `%tenant_candidate%` | **0건** |
| `%onboarding%` | 1건 (`tenant_onboarding_log`) |
| `%intake%` | 1건 (`delivery_intake_log`) |

### 결과 — `catchmenu_hq.legal_entities` columns (full)

| ordinal_position | column_name | data_type | is_nullable | column_default |
|---|---|---|---|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | entity_type | text | NO | |
| 3 | legal_name | text | NO | |
| 4 | business_registration_number | text | YES | |
| 5 | brn_normalized | text | YES | |
| 6 | corporate_registration_number | text | YES | |
| 7 | crn_normalized | text | YES | |
| 8 | tax_id | text | YES | |
| 9 | status | text | NO | 'ACTIVE'::text |
| 10 | created_at | timestamptz | NO | now() |
| 11 | updated_at | timestamptz | NO | now() |

### 결과 — sibling table columns (owners / reps / roles)

| table_name | column_name | data_type |
|---|---|---|
| legal_entity_person_roles | id, legal_entity_id, owner_id, role_type, ownership_percent, effective_from, effective_to, is_active, created_at, updated_at | (see live types above) |
| legal_entity_representatives | id, legal_entity_id, owner_id, representation_mode, effective_from, effective_to, is_active, created_at, updated_at | |
| owners | id, owner_name, contact_phone_hash, contact_email, is_active, created_at, updated_at | |

### 사실 요약

- Exact match among the nine 010901 field names: **1건** (`business_registration_number`).
- Exact miss: **8건** (`legal_entity_name`, `representative_name`, `business_address`, `business_category`, `tax_invoice_email`, `settlement_owner`, `contract_signer`, `verification_state`).
- Near-name present: `legal_entities.legal_name`, `legal_entities.corporate_registration_number`, `owners.owner_name`.
- `sales_lead` / `tenant_candidate` tables: **0건**. Onboarding/intake-named tables: 2건 as listed.

---

## 종합

| # | 질문 | 답변 가능 여부 | 비고 |
|---|---|---|---|
| Q-2 | `chk_lepr_role_type` 허용값 | 확인됨 | LEPR/REPS/ENTITIES CHECK 전문 확보; OWNERS CHECK 0건 |
| Q-3 | `set_updated_at()` 정의 | 확인됨 | SECURITY DEFINER + `search_path=pg_catalog`; triggers 114건 |
| Q-4 | 신규 4테이블 접근 주체 | 확인됨 | members/`prosrc`/`pg_depend`/FK 조회 완료; other_schema FK 0건 |
| Q-5 | `merchant_accounts` 물리 존재 | 확인됨 | 해당 3테이블 없음; merchant 컬럼 5건 |
| Q-8 | onboarding evidence 필드 | 확인됨 | exact 1/9 존재; legal_entities 컬럼 전수 기록 |

### Session notes (facts only)

- Forbidden write RPCs were not called.
- No INSERT/UPDATE/DELETE/DDL executed.
- `tools/_wp601700_s4_logic_gap_codex.md` was not read.
- Prior interrupted shell batch did not prevent re-query; final artifact written after recheck on `2026-08-22`.
