# 601711_Evidence_Person_Physical_Impact_Scan_Cursor.md

> ⚠️ **Person physical impact scan · 사실 조사이며 판정이 아니다**
>
> `owners` → canonical `Person` 교정의 물리 영향 조사다.
> Logic(`601713`) 작성의 입력 자료이며, **조사자와 설계자를 분리**하기 위한 것이다
> (`000001` §5.4.2 저자 분리 원칙 — Overview/Logic 은 Claude Code, TestPlan/ChangeContract 는 별도 행위자가 작성한다).
>
> **교정 방법을 제안하지 않는다.** rename 인지 신규 생성인지는
> ChangeContract(`601715`)가 판정한다.
>
> **같은 작업을 Codex 도 독립 수행했다 — `601712`**(`000701` §35).
>
> P-1 / P-3 는 2026-08-13 라이브 실측이다.
> 최초 조사 시 Docker daemon 미실행으로 문서 인용으로 대체되었던 것을
> 라이브 결과로 교체했다.
> P-2 / P-4 / P-5 / P-6 은 최초 조사 결과를 유지한다.
>
> 수행: Cursor, 2026-08-13.

**Performing agent:** Cursor  
**Basis:** `000701` §34.1 — large-scale scan / evidence supplier  
**Scope:** Investigation only. No remediation proposals. No rename-vs-create judgments.  
**Target:** `catchmenu_hq.owners` and all physical / documentary dependencies (12 survey items).  
**Excluded paths:** `docs/990000_legacy_quarantine/**`, `docs/_migration_history/**`, `**/archive_duplicate_review/**`, `**/*_duplicate_review/**`, `*_KO.md`

---

## Environment note

| Item | Status |
|---|---|
| Live DB | `docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres` |
| P-1 / P-3 live re-query | **2026-08-13** — succeeded (`SELECT 1` OK) |
| P-2 / P-4 / P-5 / P-6 | Prior scan retained (not re-run) |
| Write SQL / forbidden RPCs | **Not executed** (`601505` §4) |

---

## P-1. Live DB dependencies (2026-08-13 live)

Target: `catchmenu_hq.owners` and all objects depending on it. Source: live `pg_catalog` / `information_schema` queries (see **Executed queries** below).

### COLUMN (7건)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| 1 | COLUMN | `catchmenu_hq` | `owners.id` | Column | `uuid NOT NULL`, default `gen_random_uuid()` |
| 2 | COLUMN | `catchmenu_hq` | `owners.owner_name` | Column | `text NOT NULL` |
| 3 | COLUMN | `catchmenu_hq` | `owners.contact_phone_hash` | Column | `text NULL` |
| 4 | COLUMN | `catchmenu_hq` | `owners.contact_email` | Column | `text NULL` |
| 5 | COLUMN | `catchmenu_hq` | `owners.is_active` | Column | `boolean NOT NULL`, default `true` |
| 6 | COLUMN | `catchmenu_hq` | `owners.created_at` | Column | `timestamptz NOT NULL`, default `now()` |
| 7 | COLUMN | `catchmenu_hq` | `owners.updated_at` | Column | `timestamptz NOT NULL`, default `now()` |

Table comment (live): `People who hold operational or legal authority for legal entities.`

### FK (2건 — `confrelid = catchmenu_hq.owners`)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| 8 | FK | `catchmenu_hq` | `legal_entity_person_roles_owner_id_fkey` | `legal_entity_person_roles.owner_id` → `owners.id` | ON DELETE **NO ACTION**; ON UPDATE **NO ACTION** |
| 9 | FK | `catchmenu_hq` | `legal_entity_representatives_owner_id_fkey` | `legal_entity_representatives.owner_id` → `owners.id` | ON DELETE **NO ACTION**; ON UPDATE **NO ACTION** |

### VIEW (0건)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| — | VIEW | — | **0건** | — | `pg_views` + `pg_matviews` where `definition ILIKE '%owners%'` → **0 rows** |

### TRIGGER (5건 on `catchmenu_hq.owners`)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| 10 | TRIGGER | `catchmenu_hq` | `trg_owners_updated_at` | User trigger on `owners` | `tgisinternal = false`; `BEFORE UPDATE` → `catchmenu_common.set_updated_at()` |
| 11 | TRIGGER | `catchmenu_hq` | `RI_ConstraintTrigger_a_49570` | Internal FK enforcement | `tgisinternal = true`; AFTER DELETE → `RI_FKey_noaction_del()`; from `legal_entity_person_roles` FK |
| 12 | TRIGGER | `catchmenu_hq` | `RI_ConstraintTrigger_a_49571` | Internal FK enforcement | `tgisinternal = true`; AFTER UPDATE → `RI_FKey_noaction_upd()`; from `legal_entity_person_roles` FK |
| 13 | TRIGGER | `catchmenu_hq` | `RI_ConstraintTrigger_a_49597` | Internal FK enforcement | `tgisinternal = true`; AFTER DELETE → `RI_FKey_noaction_del()`; from `legal_entity_representatives` FK |
| 14 | TRIGGER | `catchmenu_hq` | `RI_ConstraintTrigger_a_49598` | Internal FK enforcement | `tgisinternal = true`; AFTER UPDATE → `RI_FKey_noaction_upd()`; from `legal_entity_representatives` FK |

### FUNCTION (0건)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| — | FUNCTION | — | **0건** | — | `pg_proc.prosrc ILIKE '%owners%'` (excluding `pg_catalog`, `information_schema`) → **0 rows** |

### POLICY (0건)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| — | POLICY | `catchmenu_hq` | **0건** | RLS on `owners` | `pg_policies` for `tablename = 'owners'` → **0 rows**; live RLS flags: `relrowsecurity = true`, `relforcerowsecurity = true` |

### GRANT (4건 — `grantee <> 'postgres'`)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| 15 | GRANT | `catchmenu_hq` | `catchmenu_authority_owner` → `owners` | SELECT | `is_grantable = NO` |
| 16 | GRANT | `catchmenu_hq` | `catchmenu_authority_owner` → `owners` | INSERT | `is_grantable = NO` |
| 17 | GRANT | `catchmenu_hq` | `catchmenu_authority_owner` → `owners` | UPDATE | `is_grantable = NO` |
| 18 | GRANT | `catchmenu_hq` | `catchmenu_authority_owner` → `owners` | DELETE | `is_grantable = NO` |

### INDEX on `owners` (1건)

| # | Kind | Schema | Real name | Relationship to `owners` | Notes |
|---:|---|---|---|---|---|
| 19 | INDEX | `catchmenu_hq` | `owners_pkey` | PK on `owners.id` | `CREATE UNIQUE INDEX owners_pkey ON catchmenu_hq.owners USING btree (id)` |

### Junction tables — `owners` dependency (item 9)

| Junction table | FK constraint name | FK column | Referenced column |
|---|---|---|---|
| `catchmenu_hq.legal_entity_person_roles` | `legal_entity_person_roles_owner_id_fkey` | `owner_id` | `owners.id` |
| `catchmenu_hq.legal_entity_representatives` | `legal_entity_representatives_owner_id_fkey` | `owner_id` | `owners.id` |

---

## P-2. Migration lineage

Only migrations referencing `catchmenu_hq.owners` / `owner_id` FK to `owners`: **`0168`**, **`0169`**. No hits in `017*.sql` or other migration files.

| Migration | Line | What it did |
|---|---:|---|
| `0168_create_operational_authority_foundation.sql` | 62–70 | `CREATE TABLE catchmenu_hq.owners` (7 columns) |
| `0168_create_operational_authority_foundation.sql` | 72–101 | `CREATE TABLE catchmenu_hq.legal_entity_person_roles` with `owner_id` FK → `owners(id)` |
| `0168_create_operational_authority_foundation.sql` | 79 | Column `ownership_percent numeric(5,2)` on `legal_entity_person_roles` |
| `0168_create_operational_authority_foundation.sql` | 94–97 | `chk_lepr_ownership_percent` (NULL or 0–100) |
| `0168_create_operational_authority_foundation.sql` | 103–109 | Partial UNIQUE `uq_lepr_active` including `owner_id` |
| `0168_create_operational_authority_foundation.sql` | 111–113 | Index `idx_lepr_owner` on `owner_id` |
| `0168_create_operational_authority_foundation.sql` | 119–137 | `CREATE TABLE catchmenu_hq.legal_entity_representatives` with `owner_id` FK → `owners(id)` |
| `0168_create_operational_authority_foundation.sql` | 139–144 | Partial UNIQUE `uq_ler_active` including `owner_id` |
| `0168_create_operational_authority_foundation.sql` | 210–213 | `ALTER TABLE catchmenu_hq.owners` — `ENABLE ROW LEVEL SECURITY` + `FORCE ROW LEVEL SECURITY` |
| `0168_create_operational_authority_foundation.sql` | 227–231 | Trigger `trg_owners_updated_at` on `owners` |
| `0168_create_operational_authority_foundation.sql` | 251–252 | `COMMENT ON TABLE catchmenu_hq.owners` |
| `0168_create_operational_authority_foundation.sql` | 255–258 | Comments on junction tables (reference “owners” in text) |
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 5–8 | `uq_ler_sole_active` on `legal_entity_representatives` (SOLE representative uniqueness per legal entity) |
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 10–22 | Create role `catchmenu_authority_owner` (`nologin`, `bypassrls`) if absent |
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 24–25 | `GRANT USAGE ON SCHEMA catchmenu_hq` to `catchmenu_authority_owner` |
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 27–33 | `GRANT SELECT, INSERT, UPDATE, DELETE` on `owners`, `legal_entities`, `legal_entity_person_roles`, `legal_entity_representatives` |
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 35 | `GRANT catchmenu_authority_owner TO postgres` |

**Header scope notes:** `0168` L3 states additive DDL only — no RPC rewrites, data promotion, grants, or RLS policies in that file; `0169` adds role + GRANTs separately.

---

## P-3. Data state (2026-08-13 live)

| Item | Measured value |
|---|---|
| `catchmenu_hq.owners` row count | **0** |
| `catchmenu_hq.legal_entity_person_roles` row count | **0** |
| `catchmenu_hq.legal_entity_representatives` row count | **0** |
| `catchmenu_hq.legal_entities` row count | **0** |
| `ownership_percent IS NOT NULL` row count (in `legal_entity_person_roles`) | **0** |
| `role_type` value distribution (in `legal_entity_person_roles`) | **0 rows** (empty table; `GROUP BY role_type` → no rows) |

---

## Executed queries (2026-08-13 live — P-1 / P-3)

```sql
-- Q1 FK referencing owners (pg_constraint, contype='f', confrelid = owners)
SELECT c.conname,
       nsp.nspname AS referencing_schema,
       rel.relname AS referencing_table,
       att.attname AS referencing_column,
       CASE c.confdeltype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT' WHEN 'c' THEN 'CASCADE' WHEN 'n' THEN 'SET NULL' WHEN 'd' THEN 'SET DEFAULT' END AS on_delete,
       CASE c.confupdtype WHEN 'a' THEN 'NO ACTION' WHEN 'r' THEN 'RESTRICT' WHEN 'c' THEN 'CASCADE' WHEN 'n' THEN 'SET NULL' WHEN 'd' THEN 'SET DEFAULT' END AS on_update
FROM pg_constraint c
JOIN pg_class rel ON rel.oid = c.conrelid
JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
JOIN pg_attribute att ON att.attrelid = c.conrelid AND att.attnum = ANY(c.conkey) AND NOT att.attisdropped
WHERE c.contype = 'f'
  AND c.confrelid = 'catchmenu_hq.owners'::regclass
ORDER BY c.conname;

-- Q2a views
SELECT schemaname, viewname FROM pg_views WHERE definition ILIKE '%owners%' ORDER BY 1,2;

-- Q2b matviews
SELECT schemaname, matviewname FROM pg_matviews WHERE definition ILIKE '%owners%' ORDER BY 1,2;

-- Q3 triggers on owners (includes tgisinternal)
SELECT t.tgname, t.tgisinternal, pg_get_triggerdef(t.oid) AS trigger_def
FROM pg_trigger t
WHERE t.tgrelid = 'catchmenu_hq.owners'::regclass
ORDER BY t.tgname;

-- Q4 functions with owners in prosrc
SELECT n.nspname AS schema_name, p.proname AS function_name, p.prosecdef AS security_definer,
       pg_get_function_identity_arguments(p.oid) AS arguments,
       COALESCE((SELECT setting FROM unnest(COALESCE(p.proconfig, ARRAY[]::text[])) AS setting WHERE setting LIKE 'search_path=%' LIMIT 1), '(default)') AS search_path_setting
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prosrc ILIKE '%owners%'
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 1, 2;

-- Q5 RLS policies on owners
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'catchmenu_hq' AND tablename = 'owners'
ORDER BY policyname;

-- Q6 grants on owners (grantee <> postgres)
SELECT grantee, privilege_type, is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'catchmenu_hq' AND table_name = 'owners' AND grantee <> 'postgres'
ORDER BY grantee, privilege_type;

-- Q7 indexes on owners
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'catchmenu_hq' AND tablename = 'owners'
ORDER BY indexname;

-- Q8 columns on owners
SELECT column_name, data_type, udt_name, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'catchmenu_hq' AND table_name = 'owners'
ORDER BY ordinal_position;

-- Q9 RLS flags
SELECT c.relname, c.relrowsecurity, c.relforcerowsecurity
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'catchmenu_hq' AND c.relname = 'owners';

-- Q10 table comment
SELECT obj_description('catchmenu_hq.owners'::regclass) AS table_comment;

-- P-3 row counts
SELECT 'owners' AS table_name, count(*)::bigint AS row_count FROM catchmenu_hq.owners
UNION ALL SELECT 'legal_entity_person_roles', count(*)::bigint FROM catchmenu_hq.legal_entity_person_roles
UNION ALL SELECT 'legal_entity_representatives', count(*)::bigint FROM catchmenu_hq.legal_entity_representatives
UNION ALL SELECT 'legal_entities', count(*)::bigint FROM catchmenu_hq.legal_entities
ORDER BY table_name;

-- P-3 ownership_percent NOT NULL
SELECT count(*)::bigint AS ownership_percent_not_null_count
FROM catchmenu_hq.legal_entity_person_roles
WHERE ownership_percent IS NOT NULL;

-- P-3 role_type distribution
SELECT role_type, count(*)::bigint AS cnt
FROM catchmenu_hq.legal_entity_person_roles
GROUP BY role_type
ORDER BY role_type;
```

---

## P-4. Document dependencies

Survey method: ripgrep `catchmenu_hq.owners`, `legal_entity_person_roles`, `legal_entity_representatives`, junction `owner_id` FK context, and `ownership_percent` across `docs/**` with excluded paths omitted. Incidental English “owner” (document owner, workpackage owner, copyright, POS case metadata `owner_id`) **excluded** unless tied to `catchmenu_hq.owners` or junction FK.

| # | Document path | How it references `owners` | Authority |
|---:|---|---|---|
| 1 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | Maps natural person → `catchmenu_hq.owners`; lists junction tables; `ownership_percent` do-not-use warning | ACTIVE |
| 2 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Anti-pattern: no dual `company_id`/`owner_id` store FKs (design principle; not direct `owners` table API) | ACTIVE |
| 3 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | Registers `catchmenu_hq.owners` as natural person; naming warning; junction tables | ACTIVE |
| 4 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §4.1 lists four global tables including `catchmenu_hq.owners` (no `tenant_id`) | ACTIVE (§4.1 example block flagged 권위 없음 in `601701` A-1 #10) |
| 5 | `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | Lists `owners` / junction tables as 0-A deliverables | ACTIVE |
| 6 | `docs/600000_implementation_lifecycle/601200_caller_authorization_foundation/601200_Readme_Caller_Authorization_Foundation.md` | Points to `601503` §9 gate: SECURITY DEFINER rules for tables including `owners` | ACTIVE |
| 7 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | Migration `0168` creates `owners` + 3 sibling tables | 권위보류 |
| 8 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | Full ERD: `owners` §2.4; `owner_id` FK on junction tables; Person/natural-person semantics; `ownership_percent` §2.3.1 | 권위보류 |
| 9 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | Lists `catchmenu_hq.owners`; single `legal_entity_id` vs dual FK principle | 권위보류 |
| 10 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | Authoritative DDL text for `owners`, junction FKs, RLS, GRANT plan, §9 SECURITY DEFINER scope | 권위보류 |
| 11 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | Verification SQL + manual INSERT examples touching `owners` / `owner_id` | 권위보류 |
| 12 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | Change scope lists `owners`; rollback ordering; constraint inventory | 권위보류 |
| 13 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601506_Verification_Operational_Authority_Foundation_Ddl.md` | Confirms four tables exist including `owners` | 권위보류 |
| 14 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601507_Verification_Operational_Authority_Foundation_Ddl.md` | Post-apply `catchmenu_hq` schema / GRANT verification (indirect; no `owners` symbol in body) | 권위보류 |
| 15 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601510_AuditReview_Stage11B_Blind_Audit.md` | Conceptual Person / ownership / representation separation (not table DDL) | 권위보류 |
| 16 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md` | SQL baseline row lists `owners` among 0-A tables | 권위보류 |
| 17 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | Backprop block: `catchmenu_hq.owners`, junction tables, naming warning | 권위보류 |
| 18 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | §4.2 full B/C/D evidence: live catalog, row counts, RLS/GRANT, doc-SQL mapping for `owners` | 본 워크패킷 |
| 19 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | §1.1 Person vs `catchmenu_hq.owners` name; §1.3 `ownership_percent` mixed concept | 본 워크패킷 |
| 20 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | Cross-cites `601701` owners evidence; staff vs owners vocabulary hits | 본 워크패킷 |
| 21 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601704_Register_Stage2_ERD_Relationship_Survey.md` | Physical survey: `owners` as Person candidate; `owner_id` N:M; `ownership_percent` | 본 워크패킷 |
| 22 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601705_Diagram_Operational_Authority_Core_ERD.md` | `PERSON` concept ≠ `owners` table (§3, §4.1) | 본 워크패킷 |
| 23 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | Adjacent-doc matrix: `owners` vs `Person` naming | 본 워크패킷 |
| 24 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601707_Audit_Stage3_Adjacent_Domain_Codex.md` | Same axis; `ownership_percent` usage prohibition cross-ref | 본 워크패킷 |
| 25 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601708_Evidence_Stage4_Overview_Evidence_Pack_Cursor.md` | Keyword inventory includes `owners`, `catchmenu_hq.owners`, junction tables | 본 워크패킷 |
| 26 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601709_Evidence_Stage4_Overview_Evidence_Pack_Codex.md` | Person / `owner_id` search-term pack | 본 워크패킷 |
| 27 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601710_Overview_Operational_Authority_Foundation_V2.md` | §2.1 canonical `Person` vs legacy `owners`; `ownership_percent` 혼재 cited | 본 워크패킷 |

**Not listed (excluded or non-runtime):** `docs/990000_legacy_quarantine/**`, `docs/_migration_history/**`, `**/archive_duplicate_review/**`, `**/*_duplicate_review/**`, `*_KO.md`; POS Gateway docs with metadata field `owner_id` (dispute/case ownership, not `catchmenu_hq.owners` FK).

---

## P-5. Code dependencies

### Search paths executed

| Path / glob | Terms |
|---|---|
| `catchmenu_app/**` | `owners`, `owner_id`, `catchmenu_hq.owners`, `legal_entity_person_roles`, `legal_entity_representatives`, `catchmenu_hq`, `legal_entity` |
| Repo `*.{ts,tsx,dart,py,js,go,json,yml,yaml}` | `catchmenu_hq.owners`, `legal_entity_person_roles`, `legal_entity_representatives` |
| `sql/**` | `catchmenu_hq.owners`, junction table names |
| `tools/**` | same table names |

### Result

**없음** — no application runtime code references `catchmenu_hq.owners`, `legal_entity_person_roles`, or `legal_entity_representatives`.

| Location | Finding |
|---|---|
| `catchmenu_app/lib/**` | 0 matches (`supabase_client.dart`, `rpc_caller.dart`, waiting screens checked via grep) |
| Other `*.{dart,ts,tsx,py,js}` under repo root | 0 matches for the three table names |
| `sql/migrations/` | **Only** `0168`, `0169` (documented in P-2) |
| `sql/migrations/seed_yoonsul_menu.sql` | 0 matches for `owners` / junction tables |
| `tools/**` | 0 matches for the three table names (incidental word `ownership` in unrelated validator only) |

`601701` §4.2 E-1 corroborates: app `.from()` / table-name references **0건** for all four 0-A global tables.

---

## P-6. `ownership_percent` state

| Item | Measured / observed |
|---|---|
| Column exists | **Yes** — `catchmenu_hq.legal_entity_person_roles.ownership_percent numeric(5,2)` (`0168` L79) |
| CHECK constraint | **Yes** — `chk_lepr_ownership_percent`: NULL or `0 ≤ ownership_percent ≤ 100` (`0168` L94–97) |
| Data | **0 rows** in `legal_entity_person_roles`; **0** rows with `ownership_percent IS NOT NULL` (`601701` D-3, D-1 #3) |
| Referencing functions | **0** (`601701` §4.2 B-1) |
| Document usage-prohibition locations | `601501` §2.3.1; `601502` (via ERD lineage); `601503` §2.4 + open items; `601504` §5.7 (range test only); `000150` warning block; `601601` backprop warning; `601702` §1.3; `601701` C-2 #2; `601704` physical-only note; `601710` §2.1 evidence note |

**Mixed-concept facts (no judgment):** column + CHECK exist in SQL; multiple Human-rule docs declare **do not use as ownership model**; `role_type='OWNER'` CHECK coexists on same junction table (`0168` L85–92).

---

## Summary

| Item | Count |
|---|---:|
| P-1 COLUMN on `owners` | 7 |
| P-1 FK → `owners.id` | 2 |
| P-1 VIEW (definition contains `owners`) | 0 |
| P-1 TRIGGER on `owners` (user-visible) | 1 |
| P-1 TRIGGER on `owners` (internal RI) | 4 |
| P-1 FUNCTION (`prosrc` contains `owners`) | 0 |
| P-1 POLICY on `owners` | 0 (RLS ENABLE+FORCE: yes) |
| P-1 GRANT on `owners` (non-postgres) | 4 |
| P-1 INDEX on `owners` | 1 |
| Migrations touching `owners` | 2 files (`0168`, `0169`); 17 logged line actions |
| `owners` table rows (live 2026-08-13) | 0 |
| `legal_entity_person_roles` rows (live) | 0 |
| `legal_entity_representatives` rows (live) | 0 |
| `legal_entities` rows (live) | 0 |
| `ownership_percent NOT NULL` rows (live) | 0 |
| `role_type` distinct values (live) | 0 (empty table) |
| P-4 material documents | 27 |
| P-5 app code reference sites | 0 |
| Seed SQL files referencing `owners` | 0 |

---

## 12-item survey checklist

| # | Survey item | Result location |
|---:|---|---|
| 1 | `catchmenu_hq.owners` full references (SQL·docs·code) | P-1, P-2, P-4, P-5 |
| 2 | `owner_id` / `owners.id` FK | P-1 #9–10, P-2 |
| 3 | Views referencing `owners` | P-1 VIEW — 0건 (live) |
| 4 | Triggers on `owners` | P-1 TRIGGER — 5건 (1 user + 4 internal RI; live) |
| 5 | Functions / RPC referencing `owners` | P-1 FUNCTION — 0건 (live) |
| 6 | RLS policy / GRANT on `owners` | P-1 POLICY 0건 + GRANT 4건 (live) |
| 7 | Seed / test data | P-3, P-5 — seed 0; test SQL in `601504` (doc only) |
| 8 | Docs active runtime dependency | P-4 (ACTIVE + 본 워크패킷 + 권위보류 labeled) |
| 9 | `0168` / `0169` migration lineage | P-2 |
| 10 | `legal_entity_person_roles` → `owners` dependency | P-1 junction table + P-2 L72–113 |
| 11 | `legal_entity_representatives` → `owners` dependency | P-1 junction table + P-2 L119–144, `0169` L5–8 |
| 12 | `ownership_percent` mixed state (`601702` §1.3) | P-6 |

---

*Generated by Cursor evidence scan for Logic `601711` input. P-1 / P-3 live-verified 2026-08-13.*
