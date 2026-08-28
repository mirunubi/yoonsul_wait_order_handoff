# 601804_Audit_Stage3_Adjacent_Domain_Codex.md

Status: Complete
Lifecycle: Audit
DocumentType: Audit
Last Updated: 2026-08-28

## 판본 확인

`git ls-files --eol` 실측에서 세 파일 모두 `i/lf w/lf` 였다. 실측 커밋은 `5b05feb43f1b1e3415ed84fe1817675178f595d0`으로 지시서와 일치했다. 아래 해시는 읽기 전에 측정했다(Q-VERSION).

| 문서 | 지시서 SHA-256 | 실측 | 일치 |
|---|---|---|---|
| `601801_Register_Stage1_Business_Rules.md` | `562E7DF0C508E1AC4FD7D74018D9EB29666EE0890DABF673134CAD325C84D048` | `562E7DF0C508E1AC4FD7D74018D9EB29666EE0890DABF673134CAD325C84D048` | 예 |
| `601802_Register_Stage0_Evidence_Collection.md` | `7F4986CFFE47EAD906706CD058F6A4E1263F69FFAB0D0A3D59E0C91D3409859D` | `7F4986CFFE47EAD906706CD058F6A4E1263F69FFAB0D0A3D59E0C91D3409859D` | 예 |
| `601803_Diagram_Tenant_Lifecycle_State_Machine.md` | `DEF851BEB72FF532A6B9E2D30D523932A40505F525984A56DAFE6E5826D87561` | `DEF851BEB72FF532A6B9E2D30D523932A40505F525984A56DAFE6E5826D87561` | 예 |

DB 실측에서 `SHOW default_transaction_read_only;` 결과는 `on`이었다(Q-DB1, Q-DB2). `601802` 의 이전 실측도 `on`을 기록한다(`601802` §3, L45-L56).

## 종합

| 관점 | 발견 | Blocker | informational |
|---|---|---:|---:|
| A1. 모델 대 라이브 스키마 | 2 | 1 | 1 |
| A2. 인접 도메인 FK · 어휘 충돌 | 2 | 0 | 2 |
| A3. `601802` 실측 대 `601803` 서술 | 1 | 0 | 1 |
| A4. `HG-A-*` 대 모델 | 2 | 2 | 0 |
| A5. 미정 항목의 타당성 | 1 | 0 | 1 |
| A6. 물리 확정 침범 | 1 | 0 | 1 |
| **합계** | **9** | **3** | **6** |

## Findings

| # | 관점 | 지점 | 내용 | Blocker | rule 근거 |
|---|---|---|---|---|---|
| F-1 | A4 | `601803` §1 T-2~T-8, L64-L94 | `TRIAL→ACTIVE`, `TRIAL→CANCELLED`, `ACTIVE→SUSPENDED`, `SUSPENDED→ACTIVE`, `ACTIVE/SUSPENDED→CANCELLED`, `CANCELLED→TERMINATED`를 “허용”으로, T-2~T-7의 변경 주체를 `manage_subscription`으로 확정했다. 그러나 `HG-A-6`은 `manage_subscription`이 `isolation_state`를 변경하지 않는다는 경계만 선언하고(`601801` §1.6, L163-L171), `HG-A-9`도 10개 조합의 표현 가능성과 합성 규칙만 선언하며 전이 그래프를 정하지 않는다(`601801` §1.9, L215-L280). `601803` 스스로도 조합 유효성이 전이 허용을 뜻하지 않는다고 기록했다(`601803` §1, L99-L101). 1단계에 없는 선언을 2단계가 생성한 것이다. | **예** | **rule 3** |
| F-2 | A1 | `601803` §1 T-2~T-7, L82-L97; §4, L203-L211 | 라이브 `manage_subscription` 본문은 현재 `tenant_status`에 대한 source-state guard 없이 `SUSPEND`는 `SUSPENDED`, `ACTIVATE`는 `ACTIVE`, `CANCEL`은 `CANCELLED`를 쓴다(Q-DB2). 따라서 `601803` 의 제한된 source→target 전이를 보장하는 제약이나 guard는 라이브에 없다. `601802`는 함수가 `tenant_status` 를 READ/WRITE한다고만 기록했고(`601802` §5.2, L77-L82), 이 전이 제약을 실측하지 않았다. 라이브와 다른 전이 그래프를 스키마가 보장한다고 전제할 수 없다. | **예** | **rule 2** |
| F-3 | A4 | `601803` §6, L271-L286, 특히 L277 | review 대상 판정에서 “그 외→생성하지 않음”을 정책으로 추가했다. `HG-A-5`는 플랫폼 귀책 또는 장기 격리에서 review task를 생성하라고 정하지만, 나머지 원인에서 생성을 금지하지는 않는다(`601801` §1.5, L137-L161). 이 음의 정책은 1단계 선언에 없다. | **예** | **rule 3** |
| F-4 | A1 | `601803` §0.1, L30-L47; §4, L203-L211 | 컬럼 타입·nullable·DEFAULT와 CHECK 허용값은 라이브와 일치했다. `tenant_status`/`isolation_state`는 모두 `text NOT NULL`, 기본값은 각각 `TRIAL`/`NONE`, CHECK는 5값/2값이다(Q-DB1; `601802` §6.1, L98-L105). tenants에는 추가로 PK, tenant_code UNIQUE, `plan_tier`, `tenant_type` CHECK가 있으나 두 축 조합을 제한하는 제약은 없다(Q-DB1). | 아니오 | informational |
| F-5 | A2 | `601803` §7 U-14, L323 | `tenant_plan_configs.plan_status`는 `text NOT NULL DEFAULT 'TRIAL'`이며 `{TRIAL, ACTIVE, SUSPENDED, CANCELLED, EXPIRED}` CHECK를 갖는다(Q-DB1; `601802` §7.1-L149, §7.2-L161). `tenant_status`의 `{..., TERMINATED}`와 `plan_status`의 `{..., EXPIRED}`가 다르고, `plan_status` 참조 함수는 13개이며 `tenant_status` 참조 함수는 7개이다(Q-DB2). `601803`은 둘의 관계를 U-14로 미정 보류했으므로, 현재 모델이 어휘 충돌을 확정했다고 볼 수는 없다. | 아니오 | informational |
| F-6 | A2 | `601803` §3-§7, L144-L326 | `catchmenu_hq.tenants(id)`를 참조하는 FK는 11개 스키마, 157개이다(Q-DB1, Q-DB2). 유사 상태 어휘로 tenants 자체의 `is_active`, `tenant_plan_configs.plan_status`, `subscription_plans.is_active`, `tenant_quotas.is_active`, `pg_cron_jobs.is_registered` 등이 실재한다(Q-DB1; `601802` §6.3, L122-L137, §7.1, L139-L154). 다만 FK 자체는 tenant 식별자 참조이고 상태 컬럼 참조가 아니며, 실측 행은 `TRIAL/NONE/is_active=true/plan_status=TRIAL` 1건만 있어 어휘 간 일반 불변식을 확정할 수 없다(Q-DB2). | 아니오 | informational |
| F-7 | A3 | `601803` §0.1, §4, §5, L30-L47, L203-L263 | `601803`이 인용한 5값/2값 CHECK, `isolation_state` 참조 함수 0개, `tenant_status` 참조 함수 7개, `isolate_tenant`의 CHECK 밖 `ISOLATED` 기록, `manage_subscription`의 phantom `company_name` 1건과 named argument 불일치 2곳, `offline_queue` 24시간/격리 표식 0건은 `601802` 원문과 일치한다(`601802` §5.2 L77-L82, §6.1-L104-L105, §6.2-L107-L120, §8.3-L207-L217; Q-DB1, Q-DB2). 다만 `601802` §7의 `plan_status` 5값과 구독 도메인 소비자 상세는 §7 U-14 한 행으로만 압축됐다(`601803` L323). | 아니오 | informational |
| F-8 | A5 | `601803` §7 U-3, L312 | U-3은 `TERMINATED`를 벗어나는 lifecycle 전이를 미정으로 두었다. `HG-A-9-7`은 `TERMINATED + ISOLATED`를 terminal containment로 정하고 일반 격리 복구 대상이 아니라고 하며(`601801` §1.9, L259-L266), 조합표는 `TERMINATED + NONE`을 “영구 종료”로 표현한다(`601801` L269-L283). 그러나 이 문구가 lifecycle 전이 전건을 명시적으로 금지한다고 단정하기에는 범위가 격리 복구에 집중되어 있으므로, 미정 보류는 Blocker acceptance rule에 해당하지 않는 informational이다. | 아니오 | informational |
| F-9 | A6 | `601803` §0.2, §5-§7, L49-L56, L216-L326 | 신규 테이블·컬럼·제약명은 확정하지 않았고, Q-1~Q-10·B-1~B-8은 개념 정보 요소로 표시됐다(`601803` L216-L252, L265-L300). `offline_queue` 재사용 가부도 판정하지 않고 U-8로 보류했다(`601803` L220-L221, L317). 물리 확정 선점은 발견하지 않았다. | 아니오 | informational |

Blocker 3건이 있으므로 `NO CONCERNS FOUND`는 해당하지 않는다.

## 실행 쿼리 전문

### Q-VERSION — 판본·EOL·커밋

```powershell
$files = @(
'docs/600000_implementation_lifecycle/601800_tenant_lifecycle_rpc_alignment/601801_Register_Stage1_Business_Rules.md',
'docs/600000_implementation_lifecycle/601800_tenant_lifecycle_rpc_alignment/601802_Register_Stage0_Evidence_Collection.md',
'docs/600000_implementation_lifecycle/601800_tenant_lifecycle_rpc_alignment/601803_Diagram_Tenant_Lifecycle_State_Machine.md'
)
git rev-parse HEAD
git ls-files --eol -- $files
foreach ($file in $files) {
  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash
  Write-Output "$file`t$hash"
}
```

### Q-DB1 — 컬럼·제약·인덱스·FK·소비자·유사 어휘

```sql
\pset pager off
SHOW default_transaction_read_only;
SELECT current_database(), current_setting('server_version'), clock_timestamp();

SELECT table_schema, table_name, column_name, data_type, udt_name,
       is_nullable, column_default
FROM information_schema.columns
WHERE (table_schema, table_name, column_name) IN (
 ('catchmenu_hq','tenants','tenant_status'),
 ('catchmenu_hq','tenants','isolation_state'),
 ('catchmenu_common','tenant_plan_configs','plan_status'))
ORDER BY 1,2,3;

SELECT n.nspname AS schema_name, c.relname AS table_name, con.conname,
       con.contype, pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
JOIN pg_class c ON c.oid=con.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE (n.nspname='catchmenu_hq' AND c.relname='tenants')
   OR (n.nspname='catchmenu_common' AND c.relname='tenant_plan_configs')
ORDER BY 1,2,3;

SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE (schemaname='catchmenu_hq' AND tablename='tenants')
   OR (schemaname='catchmenu_common' AND tablename='tenant_plan_configs')
ORDER BY 1,2,3;

SELECT pn.nspname AS fk_schema, pc.relname AS fk_table, con.conname,
       pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
JOIN pg_class pc ON pc.oid=con.conrelid
JOIN pg_namespace pn ON pn.oid=pc.relnamespace
WHERE con.contype='f'
  AND con.confrelid='catchmenu_hq.tenants'::regclass
ORDER BY 1,2,3;

SELECT n.nspname AS schema_name, p.proname,
       p.oid::regprocedure AS signature,
       p.prosrc ILIKE '%tenant_status%' AS tenant_status_ref,
       p.prosrc ILIKE '%isolation_state%' AS isolation_state_ref,
       p.prosrc ILIKE '%plan_status%' AS plan_status_ref,
       p.prosrc ILIKE '%subscription_status%' AS subscription_status_ref,
       p.prosrc ILIKE '%is_active%' AS is_active_ref,
       p.prosrc ILIKE '%is_registered%' AS is_registered_ref
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ~* '(tenant_status|isolation_state|plan_status|subscription_status|is_active|is_registered)'
ORDER BY 1,2,3;

SELECT schemaname, viewname, definition
FROM pg_views
WHERE definition ~* '(tenant_status|isolation_state|plan_status|subscription_status|is_active|is_registered)'
ORDER BY 1,2;

SELECT schemaname, matviewname, definition
FROM pg_matviews
WHERE definition ~* '(tenant_status|isolation_state|plan_status|subscription_status|is_active|is_registered)'
ORDER BY 1,2;

SELECT n.nspname AS schema_name, c.relname AS table_name, t.tgname,
       pg_get_triggerdef(t.oid, true) AS definition
FROM pg_trigger t
JOIN pg_class c ON c.oid=t.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE NOT t.tgisinternal
  AND pg_get_triggerdef(t.oid) ~* '(tenant_status|isolation_state|plan_status|subscription_status|is_active|is_registered)'
ORDER BY 1,2,3;

SELECT table_schema, table_name, column_name, data_type,
       is_nullable, column_default
FROM information_schema.columns
WHERE column_name ~* '(^|_)(tenant_status|isolation_state|plan_status|subscription_status|is_active|is_registered)($|_)'
ORDER BY 1,2,3;
```

### Q-DB2 — 집계·함수 본문·현재 행 조합

```sql
\pset pager off
SHOW default_transaction_read_only;

SELECT pn.nspname AS fk_schema, count(*) AS fk_count
FROM pg_constraint con
JOIN pg_class pc ON pc.oid=con.conrelid
JOIN pg_namespace pn ON pn.oid=pc.relnamespace
WHERE con.contype='f'
  AND con.confrelid='catchmenu_hq.tenants'::regclass
GROUP BY 1 ORDER BY 1;

SELECT count(*) AS tenant_fk_total
FROM pg_constraint
WHERE contype='f'
  AND confrelid='catchmenu_hq.tenants'::regclass;

SELECT n.nspname AS schema_name, p.proname,
       p.oid::regprocedure AS signature,
       p.prosrc ILIKE '%tenant_status%' AS tenant_status_ref,
       p.prosrc ILIKE '%isolation_state%' AS isolation_state_ref,
       p.prosrc ILIKE '%plan_status%' AS plan_status_ref
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ILIKE '%tenant_status%'
   OR p.prosrc ILIKE '%isolation_state%'
   OR p.prosrc ILIKE '%plan_status%'
ORDER BY 1,2,3;

SELECT count(*) FILTER (WHERE p.prosrc ILIKE '%tenant_status%')
         AS tenant_status_functions,
       count(*) FILTER (WHERE p.prosrc ILIKE '%isolation_state%')
         AS isolation_state_functions,
       count(*) FILTER (WHERE p.prosrc ILIKE '%plan_status%')
         AS plan_status_functions
FROM pg_proc p;

SELECT n.nspname AS schema_name, p.proname,
       p.oid::regprocedure AS signature,
       regexp_replace(p.prosrc, E'[\n\r]+', ' ', 'g') AS source_flat
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.proname IN ('manage_subscription','isolate_tenant')
ORDER BY 1,2,3;

SELECT tenant_status, isolation_state, is_active, count(*)
FROM catchmenu_hq.tenants
GROUP BY 1,2,3 ORDER BY 1,2,3;

SELECT plan_status, count(*)
FROM catchmenu_common.tenant_plan_configs
GROUP BY 1 ORDER BY 1;

SELECT t.tenant_status, t.isolation_state, t.is_active,
       pc.plan_status, count(*)
FROM catchmenu_hq.tenants t
LEFT JOIN catchmenu_common.tenant_plan_configs pc ON pc.tenant_id=t.id
GROUP BY 1,2,3,4 ORDER BY 1,2,3,4;
```

Q-DB1·Q-DB2는 아래 접속 명령으로 실행했다. 금지 함수는 호출하지 않았다(`601802` §2, L26-L43).

```powershell
$sql | docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres
```
