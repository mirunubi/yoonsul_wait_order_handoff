# 601504_TestPlan_Operational_Authority_Foundation_Ddl.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Contract Drafting — Claude Code, `000701` §3 L253)
Domain: Operational Authority Foundation (0단계 / 하위 나선 0-A)
Last Updated: 2026-08-09

## Change ID

`operational_authority_foundation_ddl`

## §0 범위 및 전제

### §0.1 검증 대상 (DDL 전용 — A-7 절단 유지)

**신규 테이블 4개**: `catchmenu_hq.owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives`
**신규 컬럼 3개**: `tenants.tenant_status` / `tenants.isolation_state` / `stores.legal_entity_id`

**검증 대상이 아닌 것**: 0082/0090/0112/0120/0123/0129의 RPC·배치 동작(0-A-2/0-A-3 소관),
`pg_cron_jobs.is_registered` 역논리 결함 수정(0-A-2 승계, `601503` §5.3).

### §0.2 이 TestPlan이 답해야 하는 질문

DDL 워크패킷이므로 "함수가 옳은 값을 돌려주는가"가 아니라 **"제약이 실제로 막아야 할 것을 막고,
허용해야 할 것을 허용하는가"** 가 검증의 핵심이다. 설계 문서에 적힌 각 판단(부분 UNIQUE, 정규화,
직교 상태축, deny-by-default)이 **글이 아니라 DB 동작으로 성립하는지** 확인한다.

§48의 원칙 그대로 — "제약이 정의돼 있다"와 "제약이 실제로 작동한다"는 다른 사실이다.
따라서 모든 제약 테스트는 **성공 케이스와 위반 케이스를 쌍으로** 실행한다.

### §0.3 실행 환경

- 로컬 PostgreSQL **17.6**(`601503` §6.3에서 확인). 클라우드 버전은 미확인 — Open Item (m).
- 모든 테스트는 **트랜잭션 안에서 실행하고 `rollback`으로 종료**한다(§7 예외 제외).
  실데이터를 남기지 않는다.

---

## §1 Pre-flight — 라이브 스키마가 설계 서술과 일치하는가

DDL 적용 **전에** 실행한다. 하나라도 어긋나면 **즉시 중단**하고 `601505` §6 Stop Condition을 발동한다.

### §1.1 신규 대상이 아직 없음을 확인

```sql
select to_regclass('catchmenu_hq.owners')                    as owners,
       to_regclass('catchmenu_hq.legal_entities')            as legal_entities,
       to_regclass('catchmenu_hq.legal_entity_person_roles') as roles,
       to_regclass('catchmenu_hq.legal_entity_representatives') as reps;
```
**기대**: 4개 전부 `NULL`.

```sql
select column_name from information_schema.columns
where table_schema = 'catchmenu_hq'
  and (
    (table_name = 'tenants' and column_name in ('tenant_status','isolation_state'))
    or (table_name = 'stores' and column_name = 'legal_entity_id')
  );
```
**기대**: **0행**. (1행이라도 나오면 설계 전제가 깨진 것 — 중단)

### §1.2 기존 스키마가 설계 서술과 일치

| 확인 | 기대 | 근거 |
|---|---|---|
| `tenants` 컬럼 수 | **8개** | `601501` §8 / 0002 L8–24 |
| `stores` 컬럼 수 | **15개** | 0002 L43–76 |
| `uq_stores_tenant_code` 존재 및 컬럼 = `(tenant_id, store_code)` | 존재 | `601503` §2.7 |
| `catchmenu_hq` 테이블 수 | **16개** | `601501` §2.7.1 |

```sql
select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'catchmenu_hq.stores'::regclass and conname = 'uq_stores_tenant_code';
```

### §1.3 접근제어 baseline — 지금도 이미 닫혀 있는가

`601501` §2.7.1의 "실제 차단자는 GRANT + PostgREST"라는 주장을 **DDL 적용 전에** 확인한다.

```sql
-- (a) catchmenu_hq 테이블에 대한 테이블 권한이 정말 0건인가
select count(*) from information_schema.role_table_grants
where table_schema = 'catchmenu_hq';

-- (b) 스키마 USAGE 분포
select r.rolname, has_schema_privilege(r.rolname, 'catchmenu_hq', 'USAGE') as usage
from pg_roles r where r.rolname in ('authenticated','service_role','anon');

-- (c) service_role의 BYPASSRLS
select rolname, rolbypassrls from pg_roles where rolname = 'service_role';
```

**기대**: (a) `0`. (b) `authenticated`=`true`, `service_role`=`false`. (c) `rolbypassrls`=`true`.

> (b)가 예상과 다르면 — 특히 `service_role`이 `true`로 나오면 — `601501` §2.7.1의 서술이 라이브와
> 어긋나는 것이므로 **Stop Condition**이다. 설계를 고치고 재승인받아야 한다.

### §1.4 cron baseline

```sql
select count(*) as total,
       count(*) filter (where is_registered)                          as registered_true,
       count(*) filter (where is_registered and pg_cron_job_id is null) as true_but_no_job_id
from catchmenu_common.pg_cron_jobs;

select count(*) as cron_job_rows from cron.job;
```
**기대(로컬)**: `47 / 38 / 38`, `cron.job` = **0**. (`601503` §5.2 실측값)
이 값은 §8에서 사후 대조용 baseline으로 쓴다. **값이 달라도 중단 사유는 아니나 기록**한다.

---

## §2 Test A — 신규 테이블 4개 생성 검증

### §2.1 테이블·컬럼 존재

```sql
select table_name, column_name, data_type, is_nullable, column_default,
       is_generated, generation_expression
from information_schema.columns
where table_schema = 'catchmenu_hq'
  and table_name in ('owners','legal_entities',
                     'legal_entity_person_roles','legal_entity_representatives')
order by table_name, ordinal_position;
```

**기대**: `601503` §2.1/§2.3/§2.4/§2.5의 의사 DDL과 **컬럼명·타입·nullable·default가 정확히 일치**.
특히 `brn_normalized`/`crn_normalized`는 `is_generated = 'ALWAYS'`이고 `generation_expression`에
`nullif`와 `regexp_replace`가 모두 포함돼야 한다.

> **`nullif` 누락은 치명적 결함이다**(`601503` §2.2) — 없으면 번호 미확정 행들이 전부 `''`로 정규화돼
> 서로 충돌한다. 표현식 문자열에 `nullif`가 없으면 **FAIL**.

### §2.2 제약·인덱스 목록

```sql
select conrelid::regclass as tbl, conname, contype, pg_get_constraintdef(oid)
from pg_constraint
where connamespace = 'catchmenu_hq'::regnamespace
  and conrelid::regclass::text like 'catchmenu_hq.%legal%'
   or conrelid = 'catchmenu_hq.owners'::regclass
order by tbl, conname;

select tablename, indexname, indexdef
from pg_indexes
where schemaname = 'catchmenu_hq'
  and tablename in ('owners','legal_entities',
                    'legal_entity_person_roles','legal_entity_representatives')
order by tablename, indexname;
```

**기대 — 부분 인덱스 3개의 `WHERE` 절이 정확할 것**:

| 인덱스 | 기대 술어 |
|---|---|
| `uq_legal_entities_brn_normalized` | `WHERE (brn_normalized IS NOT NULL)` |
| `uq_legal_entities_crn_normalized` | `WHERE (crn_normalized IS NOT NULL)` |
| `uq_lepr_active` | `WHERE (is_active = true)` |
| `uq_ler_active` | `WHERE (is_active = true)` |

### §2.3 `owners`에 유니크가 **없음** 확인 (D-2 판정)

```sql
select count(*) from pg_indexes
where schemaname='catchmenu_hq' and tablename='owners' and indexdef ilike '%unique%'
  and indexdef ilike '%contact_phone_hash%';
```
**기대**: `0`. (있으면 §2.3.1 판정 위반 — FAIL)

---

## §3 Test B — deny-by-default가 **실제로** 작동하는가

`601501` §2.7의 핵심 주장을 동작으로 확인한다. **성공 케이스와 거부 케이스를 모두 실행한다.**

### §3.1 신규 4테이블에 GRANT가 없는가 (설계결정 §2.7.3)

```sql
select table_name, grantee, privilege_type
from information_schema.role_table_grants
where table_schema = 'catchmenu_hq'
  and table_name in ('owners','legal_entities',
                     'legal_entity_person_roles','legal_entity_representatives');
```
**기대**: **0행**. 1행이라도 있으면 **FAIL**(설계결정 위반 — `601505` §4 Forbidden).

### §3.2 `authenticated` 직접 SELECT 거부

```sql
begin;
set local role authenticated;
select * from catchmenu_hq.legal_entities limit 1;   -- 기대: 권한 오류
rollback;
```
**기대**: `42501 permission denied for table legal_entities`.
4개 테이블 각각 반복한다.

> **판정 주의**: 오류코드가 `42501`(permission denied)이어야 한다. 만약 **0행이 조용히 반환**되면
> 그것은 GRANT가 존재하고 RLS가 막고 있다는 뜻이며, `601501` §2.7.1의 "차단자는 GRANT"라는 서술과
> **다른 결과**다 → 결과를 그대로 기록하고 설계 서술을 정정해야 한다(§9 참조).

### §3.3 `service_role` 직접 SELECT 거부 (BYPASSRLS를 가짐에도)

```sql
begin;
set local role service_role;
select * from catchmenu_hq.legal_entities limit 1;   -- 기대: 오류
rollback;
```
**기대**: 스키마 USAGE가 없으므로 `42501 permission denied for schema catchmenu_hq`
(테이블 권한 오류가 아니라 **스키마 단계에서** 막히는 것이 §2.7.1 서술과 일치하는 결과다).

> 이 테스트가 이번 검증의 **가장 중요한 항목**이다. `service_role`은 `rolbypassrls = true`이므로
> **RLS만으로는 절대 막히지 않는다.** 그럼에도 접근이 거부된다면, 차단자가 RLS가 아니라
> GRANT/USAGE 계층이라는 `601501` §2.7.1의 주장이 **실증**된다.
> 반대로 접근이 **성공**하면 설계 서술이 틀린 것이므로 즉시 Stop Condition이다.

### §3.4 RLS 상태 확인 (3차 방어선)

```sql
select relname, relrowsecurity, relforcerowsecurity,
       (select count(*) from pg_policies p
        where p.schemaname='catchmenu_hq' and p.tablename = c.relname) as policy_count
from pg_class c
join pg_namespace n on n.oid = c.relnamespace and n.nspname = 'catchmenu_hq'
where c.relname in ('owners','legal_entities',
                    'legal_entity_person_roles','legal_entity_representatives');
```
**기대**: 4개 전부 `relrowsecurity = true`, `relforcerowsecurity = true`, **`policy_count = 0`**.

---

## §4 Test C — `SECURITY DEFINER` 경유 접근 (Open Item (o) 검증)

`601503` §2.8.4의 **조건부** 해소를 실증한다. GRANT를 주지 않는 설계를 택한 이상,
이 경로가 **유일한 접근 경로**이므로 반드시 확인한다.

### §4.1 함수 소유자 확인 — 배포 전제 조건

```sql
select p.proname, p.prosecdef, pg_get_userbyid(p.proowner) as owner
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname in ('catchmenu_common','catchmenu_hq')
  and p.prosecdef = true
order by owner, p.proname
limit 20;

-- 소유자 분포 집계
select pg_get_userbyid(p.proowner) as owner, count(*)
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname like 'catchmenu%' and p.prosecdef = true
group by 1;
```
**기대**: `SECURITY DEFINER` 함수의 소유자가 **전부 `postgres`**.

> **`postgres` 아닌 소유자가 1건이라도 나오면 기록하고 보고한다.** 마이그레이션에는 소유자를 고정하는
> 선언이 **0건**이므로(`601503` §2.8.4), 소유권은 "누가 마이그레이션을 실행했는가"의 결과일 뿐이다.
> 이 테스트는 Open Item (o)의 배포 계약이 현재 성립하는지를 확인하는 것이지, 성립을 보장하지 않는다.

### §4.2 임시 `SECURITY DEFINER` 함수로 실제 접근 확인

> 이 테스트는 **임시 함수를 만들었다가 반드시 DROP**한다. 영구 객체를 남기지 않는다.
> `601505` §3의 허용 범위를 벗어나지 않도록, 검증 전용 임시 함수임을 명시한다.

```sql
begin;
create function pg_temp.t_secdef_probe() returns bigint
language sql security definer
as $$ select count(*) from catchmenu_hq.legal_entities $$;

set local role authenticated;
select pg_temp.t_secdef_probe();   -- 기대: 오류 없이 숫자 반환
rollback;
```
**기대**: `authenticated`로 전환한 상태에서도 함수는 **정상 실행되어 건수를 반환**한다
(함수가 소유자 권한으로 돌기 때문). §3.2에서 같은 역할의 직접 SELECT가 거부됐던 것과 **대비**되어야 한다.

**FAIL 시 처분**: 함수 경유도 막히면 이 테이블들은 "아무도 못 쓰는 테이블"이다
(`601503` §2.8.4가 경고한 상태). 즉시 보고하고 GRANT 또는 정책 설계를 재검토한다.

---

## §5 Test D — 제약이 막아야 할 것을 막는가

각 항목은 **허용 케이스 → 위반 케이스** 순으로 실행한다. 위반 케이스가 통과하면 FAIL이다.

### §5.1 등록번호 정규화 UNIQUE — BRN

```sql
begin;
-- (1) 표기가 다른 같은 번호 2건 → 두 번째가 거부돼야 함
insert into catchmenu_hq.legal_entities (entity_type, legal_name, business_registration_number)
values ('SOLE_PROPRIETOR', 'A', '123-45-67890');

insert into catchmenu_hq.legal_entities (entity_type, legal_name, business_registration_number)
values ('SOLE_PROPRIETOR', 'B', '1234567890');       -- 기대: 23505 unique_violation

rollback;
```

```sql
begin;
-- (2) 공백 표기도 동일하게 충돌해야 함
insert into catchmenu_hq.legal_entities (entity_type, legal_name, business_registration_number)
values ('SOLE_PROPRIETOR', 'A', '123-45-67890');
insert into catchmenu_hq.legal_entities (entity_type, legal_name, business_registration_number)
values ('SOLE_PROPRIETOR', 'C', '123 45 67890');     -- 기대: 23505
rollback;
```

```sql
begin;
-- (3) ⭐ NULL 다건 허용 — nullif 설계의 핵심 검증
insert into catchmenu_hq.legal_entities (entity_type, legal_name, business_registration_number)
values ('SOLE_PROPRIETOR', 'X', null),
       ('SOLE_PROPRIETOR', 'Y', null),
       ('CORPORATION',     'Z', null);                -- 기대: 3건 전부 성공
select count(*) from catchmenu_hq.legal_entities where brn_normalized is null;  -- 기대: 3
rollback;
```

> **(3)이 이 테스트의 핵심이다.** 실패하면 `nullif(..., '')`가 빠졌다는 뜻이고,
> **1호점 시드(번호 미확정)를 만들 수 없게 된다**(`601503` §4.1).

```sql
begin;
-- (4) 정규화 값 자체 확인
insert into catchmenu_hq.legal_entities (entity_type, legal_name, business_registration_number)
values ('SOLE_PROPRIETOR', 'D', ' 123-45-67890 ');
select business_registration_number, brn_normalized from catchmenu_hq.legal_entities where legal_name='D';
-- 기대: raw는 표기 그대로 보존(' 123-45-67890 '), brn_normalized = '1234567890'
rollback;
```

### §5.2 등록번호 정규화 UNIQUE — CRN (A-6, BRN과 동일 방식)

```sql
begin;
insert into catchmenu_hq.legal_entities
  (entity_type, legal_name, corporate_registration_number)
values ('CORPORATION', 'CorpA', '110111-1234567');
insert into catchmenu_hq.legal_entities
  (entity_type, legal_name, corporate_registration_number)
values ('CORPORATION', 'CorpB', '1101111234567');    -- 기대: 23505
rollback;
```

```sql
begin;
-- CRN도 NULL 다건 허용
insert into catchmenu_hq.legal_entities (entity_type, legal_name, corporate_registration_number)
values ('CORPORATION', 'CorpX', null), ('CORPORATION', 'CorpY', null);  -- 기대: 성공
rollback;
```

### §5.3 개인사업자의 CRN 금지 / CORPORATION의 CRN 미요구 (A-7)

```sql
begin;
-- (1) 개인사업자 + CRN → 거부
insert into catchmenu_hq.legal_entities
  (entity_type, legal_name, corporate_registration_number)
values ('SOLE_PROPRIETOR', 'Bad', '110111-1234567');  -- 기대: 23514 check_violation
rollback;

begin;
-- (2) CORPORATION + CRN NULL → 허용 (A-7 판단)
insert into catchmenu_hq.legal_entities (entity_type, legal_name, corporate_registration_number)
values ('CORPORATION', 'NoCrnYet', null);             -- 기대: 성공
rollback;
```

### §5.4 `legal_entity_person_roles` 재가입 (soft-delete 후 재연결)

```sql
begin;
insert into catchmenu_hq.owners (owner_name) values ('P1');
insert into catchmenu_hq.legal_entities (entity_type, legal_name) values ('SOLE_PROPRIETOR','E1');

-- (1) 최초 역할 부여
insert into catchmenu_hq.legal_entity_person_roles (legal_entity_id, owner_id, role_type)
select e.id, o.id, 'OWNER'
from catchmenu_hq.legal_entities e, catchmenu_hq.owners o
where e.legal_name='E1' and o.owner_name='P1';       -- 기대: 성공

-- (2) 활성 중복 → 거부
insert into catchmenu_hq.legal_entity_person_roles (legal_entity_id, owner_id, role_type)
select e.id, o.id, 'OWNER' from catchmenu_hq.legal_entities e, catchmenu_hq.owners o
where e.legal_name='E1' and o.owner_name='P1';       -- 기대: 23505

-- (3) soft-delete 후 재부여 → ⭐ 성공해야 함 (D-3)
update catchmenu_hq.legal_entity_person_roles set is_active = false;
insert into catchmenu_hq.legal_entity_person_roles (legal_entity_id, owner_id, role_type)
select e.id, o.id, 'OWNER' from catchmenu_hq.legal_entities e, catchmenu_hq.owners o
where e.legal_name='E1' and o.owner_name='P1';       -- 기대: 성공

select count(*) from catchmenu_hq.legal_entity_person_roles;   -- 기대: 2 (이력 보존)
rollback;
```

```sql
begin;
-- (4) 같은 사람이 같은 법인에서 서로 다른 role_type 동시 보유 → 허용
--     (role_type이 유니크 키에 포함되므로 정상)
--   OWNER + DIRECTOR 2건 insert → 기대: 둘 다 성공
rollback;
```

### §5.5 `legal_entity_representatives` 부분 UNIQUE (B-2)

```sql
begin;
-- 준비: owner 1, legal_entity 1
-- (1) 대표 지정 → 성공
insert into catchmenu_hq.legal_entity_representatives
  (legal_entity_id, owner_id, representation_mode) values (:e1, :o1, 'SOLE');

-- (2) 같은 (법인, 사람) 활성 중복 → 거부
insert into catchmenu_hq.legal_entity_representatives
  (legal_entity_id, owner_id, representation_mode) values (:e1, :o1, 'JOINT');  -- 기대: 23505

-- (3) 종료 후 재지정 → 성공
update catchmenu_hq.legal_entity_representatives set is_active = false;
insert into catchmenu_hq.legal_entity_representatives
  (legal_entity_id, owner_id, representation_mode) values (:e1, :o1, 'SOLE');   -- 기대: 성공

-- (4) 'NONE' 값 거부 (v4에서 도메인에서 제거됨)
insert into catchmenu_hq.legal_entity_representatives
  (legal_entity_id, owner_id, representation_mode) values (:e1, :o2, 'NONE');   -- 기대: 23514
rollback;
```

### §5.6 알려진 한계 확인 — 막히지 **않아야** 하는 것 (A-4)

`601503` §2.5.2가 "행 CHECK로 막을 수 없다"고 기록한 항목이 **실제로 막히지 않는지** 확인한다.
이는 결함 검출이 아니라 **문서 서술의 정확성 검증**이다.

```sql
begin;
-- 같은 법인에 SOLE 대표 2명 → 현재 설계상 통과해야 함 (막히면 문서가 틀린 것)
insert into catchmenu_hq.legal_entity_representatives
  (legal_entity_id, owner_id, representation_mode)
values (:e1, :o1, 'SOLE'), (:e1, :o2, 'SOLE');       -- 기대: 성공(= 한계 실재 확인)
rollback;
```
**판정**: 성공하면 PASS(문서 서술 정확). 거부되면 문서가 실제보다 비관적인 것이므로 `601503` §2.5.2를 정정한다.
어느 쪽이든 **Open Item (c)의 존재 근거로 기록**한다.

### §5.7 `ownership_percent` 범위

```sql
begin;
-- 0/100/NULL 허용, -1/101 거부
--   기대: 앞 3건 성공, 뒤 2건 각각 23514
rollback;
```

### §5.8 `effective_to >= effective_from`

```sql
begin;
-- effective_to < effective_from → 23514, effective_to IS NULL → 성공
-- roles / representatives 양쪽 모두 확인
rollback;
```

---

## §6 Test E — `tenants` 상태 2컬럼 직교성 (B-1)

### §6.1 기존 행이 default를 얻는가

```sql
select id, tenant_code, tenant_status, isolation_state from catchmenu_hq.tenants;
```
**기대**: 기존 전 행이 `tenant_status='TRIAL'`, `isolation_state='NONE'`.
**특히 `'ACTIVE'`인 행이 0건**이어야 한다(§8과 연결 — 배치 조용한 활성화 방지).

### §6.2 ⭐ 직교 조합 — 4개 상태 동시 표현

`601501` §3의 핵심 주장(1컬럼으로는 원리적으로 표현 불가했던 조합)을 실증한다.

```sql
begin;
update catchmenu_hq.tenants
set tenant_status = 'TRIAL', isolation_state = 'ISOLATED'
where tenant_code = 'YOONSUL_TEST';
select tenant_status, isolation_state from catchmenu_hq.tenants where tenant_code='YOONSUL_TEST';
-- 기대: ('TRIAL','ISOLATED') — 두 값이 서로를 덮어쓰지 않고 동시 존재
rollback;
```

동일하게 반복 확인할 조합:

| # | `tenant_status` | `isolation_state` | 기대 |
|---|---|---|---|
| 1 | `TRIAL` | `ISOLATED` | 성공 (v3 이전 구조에서 표현 불가했던 조합) |
| 2 | `ACTIVE` | `ISOLATED` | 성공 |
| 3 | `SUSPENDED` | `ISOLATED` | 성공 |
| 4 | `CANCELLED` | `NONE` | 성공 |
| 5 | `TERMINATED` | `NONE` | 성공 (기존 사용처 없는 전방호환 값 — `601503` §2.6) |

### §6.2A ⚠️ ACTIVATE 경로 정적 검증 (실행 금지 — 원문 읽기만)

**이 항목은 RPC를 호출하지 않는다.** `manage_subscription()`/`isolate_tenant()` 호출은
`601505` §4.1.1(호출 금지)에 저촉되므로, **0112 원문을 읽는 정적 검증**으로 수행한다.

#### §6.2A.1 확인 절차

```sql
-- 함수 원문을 DB에서 직접 읽는다 (실행하지 않는다)
select pg_get_functiondef(p.oid)
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_common' and p.proname = 'manage_subscription';
```

또는 파일 원문 확인:

```bash
sed -n '532,536p;548p;592,619p' sql/migrations/0112_create_hq_admin_rpc.sql
```

#### §6.2A.2 확인해야 할 4가지 사실

| # | 확인 대상 | 기대 | 근거 라인 |
|---|---|---|---|
| 1 | 테넌트 조회 SELECT가 `case p_action`보다 **앞**에 있는가 | L533 SELECT < L548 CASE | 0112 L533 / L548 |
| 2 | 그 SELECT가 `tenants.company_name`(phantom)을 참조하는가 | `select id, company_name, tenant_status` | 0112 **L533** |
| 3 | ACTIVATE 분기가 `tenant_status='ACTIVE'`를 **직접 UPDATE**하는가 | 존재 | 0112 L608–613 |
| 4 | ACTIVATE 분기가 `isolate_tenant(p_isolate := false)`를 호출하는가 | 존재 (→ `v_new_status='ACTIVE'`) | 0112 L615–619 / 0090 L1283–1286 |

#### §6.2A.3 판정

**PASS 조건**: 위 4가지가 전부 사실로 확인되고, 다음 결론이 성립한다:

> **현재**: 1·2에 의해 `manage_subscription()`의 **모든 분기가 42703으로 도달 불가**하다 →
> ACTIVATE의 실질 위험은 **낮다**.
> **잠재**: 3·4에 의해 ACTIVATE 경로에는 **CHECK라는 안전망이 없다**(`'ACTIVE'`는 허용값) →
> L533의 phantom 참조가 해소되는 순간 **조용히 §4.3을 위반**한다.

**어긋날 경우**:

| 발견 | 처분 |
|---|---|
| SELECT가 CASE **뒤에** 있음 | `601505` §4.5.1의 전제가 틀림 → 설계 서술 정정 후 재승인 |
| `company_name` 참조가 **이미 제거됨** | **방벽이 없다** → ACTIVATE가 즉시 위험. **Stop Condition**(§9.3) |
| ACTIVATE 분기에 `tenant_status` 기록이 없음 | 위험 서술이 과대 → `601505` §4.5.1/§8A.1 정정 |

#### §6.2A.4 이 검증이 산출하는 것

`601505` §8A.1(0-A-2/0-A-3 공통 완료조건)의 **근거 문서**가 된다 —
"phantom 해소와 ACTIVATE 수정을 분리 배포하지 않는다"는 요구가 추측이 아니라
**원문 확인에 기반한다**는 것을 Stage 9 재검증자가 확인할 수 있어야 한다.

### §6.3 CHECK 위반

```sql
begin;
update catchmenu_hq.tenants set tenant_status = 'ISOLATED';   -- 기대: 23514
rollback;
begin;
update catchmenu_hq.tenants set isolation_state = 'SUSPENDED'; -- 기대: 23514
rollback;
```
**의미**: `'ISOLATED'`가 `tenant_status`에 들어갈 수 없다는 것이 곧
**0090 `isolate_tenant()`의 현재 동작이 DB 레벨에서 차단됨**을 뜻한다.
0-A-2가 그 RPC를 고치기 전까지 해당 함수는 실패하며, 이는 **의도된 결과**다(§9.2 참조).

---

## §7 Test F — `stores.legal_entity_id` 가법성

### §7.1 기존 행 무손상

```sql
-- DDL 적용 전 스냅샷과 대조
select id, tenant_id, store_code, store_name, store_status, legal_entity_id
from catchmenu_hq.stores;
```
**기대**: 기존 행(`윤슬 울산 1호점` 포함)이 **전부 그대로 존재**하고 `legal_entity_id`만 `NULL`로 추가됨.
행 수·기존 컬럼 값이 DDL 전과 **완전히 동일**해야 한다.

### §7.2 기존 INSERT 경로 무손상

```sql
begin;
-- legal_entity_id를 지정하지 않는 기존 형태의 INSERT
insert into catchmenu_hq.stores (tenant_id, store_code, store_name)
select id, 'TEST_STORE_TP', '테스트매장' from catchmenu_hq.tenants where tenant_code='YOONSUL_TEST';
-- 기대: 성공 (nullable이므로)
rollback;
```
**의미**: 이것이 성공해야 `NOT NULL` 승격을 **아직 하지 않았다**는 것이 확인된다(§4.3, Open Item (h)).

### §7.3 FK 작동 + RLS 비적용 확인 (A-8)

```sql
begin;
-- 존재하지 않는 legal_entity_id → FK 위반
insert into catchmenu_hq.stores (tenant_id, store_code, store_name, legal_entity_id)
select id, 'TEST_FK', 'FK테스트', gen_random_uuid() from catchmenu_hq.tenants limit 1;
-- 기대: 23503 foreign_key_violation
rollback;
```
**의미**: `legal_entities`가 deny-by-default 상태임에도 **FK 검사는 정상 작동**한다는 `601503` §4.3의
서술을 확인한다. 동시에 이 오류 메시지가 **존재탐지 경로**가 될 수 있음을 기록한다(Open Item (f)).

### §7.4 `uq_stores_tenant_code` 불변

```sql
begin;
-- 같은 tenant + 같은 store_code, 다른 legal_entity_id → 여전히 거부돼야 함
-- 기대: 23505 (legal_entity_id는 유일성 키에 포함되지 않음)
rollback;
```

---

## §8 Test G — 멱등성 및 부작용 없음

### §8.1 DDL 재실행 (AV-7 / `601503` §6)

**같은 마이그레이션을 두 번 연속 실행**한다.

**기대**: 두 번째 실행이 **오류 없이 완료**된다. 특히:

| 대상 | 재실행 시 |
|---|---|
| `create table if not exists` ×4 | 무시됨 |
| `add column if not exists` ×3 | 무시됨 |
| `create (unique) index if not exists` | 무시됨 |
| **`add constraint` (CHECK ×2, FK ×1)** | **`pg_constraint` 가드에 의해 건너뜀** — 가드가 없으면 `42710 duplicate_object` |

```sql
-- 재실행 후 제약이 중복 생성되지 않았는지
select conname, count(*) from pg_constraint
where conrelid in ('catchmenu_hq.tenants'::regclass, 'catchmenu_hq.stores'::regclass)
  and conname in ('chk_tenants_status','chk_tenants_isolation_state','fk_stores_legal_entity_id')
group by conname;
```
**기대**: 각 1건.

### §8.2 cron 무영향 확인 (범위 밖이나 사후 확인)

`is_registered` 역논리 결함 자체는 **이번 범위 밖**(0-A-2 승계)이므로 수정도 테스트도 하지 않는다.
다만 `tenant_status` 컬럼 추가가 **cron에 아무 영향을 주지 않는지**만 확인한다.

```sql
select count(*) as cron_job_rows from cron.job;
select count(*) as total,
       count(*) filter (where is_registered) as registered_true
from catchmenu_common.pg_cron_jobs;
```
**기대**: §1.4 baseline과 **완전히 동일** — `cron.job` = **0행**, `47/38`.

> **왜 0행이 기대값인가**: 컬럼이 추가되면 `WHERE tenant_status='ACTIVE'` 쿼리가 이제 문법적으로
> 유효해지지만, `cron.job`이 0행이므로 **실행 자체가 일어나지 않는다**. 또한 §6.1에 의해
> `ACTIVE`인 tenant도 0건이다 — **두 겹으로 막혀 있다.**
> 만약 `cron.job`이 0행이 아니게 되면 이번 DDL이 예상치 못한 부작용을 일으킨 것이므로 **FAIL**.

### §8.3 기존 객체 무변경

```sql
-- DDL 전후로 함수 정의가 바뀌지 않았는지 (본 워크패킷은 함수를 만들지 않는다)
select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname like 'catchmenu%';
```
**기대**: DDL 전과 **동일한 수**. 증가하면 `601505` §4 Forbidden 위반이다.

---

## §9 판정 기준

### §9.1 PASS 조건

§1~§8의 모든 "기대"가 충족되고, 특히 다음 5개 **핵심 항목**이 전부 PASS:

1. **§3.3** — `service_role`(BYPASSRLS 보유)조차 접근 거부 → 차단자가 RLS가 아님을 실증
2. **§4.2** — `SECURITY DEFINER` 경유는 접근 성공 → 유일한 접근 경로 확보
3. **§5.1(3)** — `business_registration_number` NULL 다건 허용 → `nullif` 설계 성립
4. **§6.2** — `TRIAL`+`ISOLATED` 동시 표현 → 2컬럼 직교 성립
5. **§8.1** — DDL 재실행 무오류 → 멱등성 성립

### §9.1A ⚠️ 계약 위반으로 즉시 FAIL 처리하는 것

다음은 **DDL의 기술적 결함이 아니더라도 즉시 FAIL**이다 — `601505`의 계약 조항 위반이기 때문이다.

| # | 발견 | 위반 조항 | 확인 방법 |
|---|---|---|---|
| 1 | **`manage_subscription('ACTIVATE')`의 실제 실행 흔적** | §4.1.1(호출 금지) + §4.3(ACTIVE 승격 금지) | `tenant_status='ACTIVE'`인 행 존재(§6.1), 감사로그·`pg_stat_statements` |
| 2 | **`isolate_tenant()`/`manage_subscription()`의 신규 호출자 발견** | §4.5(신규 호출자 배포 금지) | `601505` §7.1의 (a)(b)(c) 명령 |
| 3 | `tenant_status='ACTIVE'`인 tenant가 1건이라도 존재 | §4.3 | §6.1 |
| 4 | 신규 4테이블에 GRANT 존재 | §2.1 | §3.1 |
| 5 | `git diff`에 기존 `.sql` 수정이 포함됨 | §4.1 / §5 | §7.2-3 |
| 6 | `catchmenu%` 스키마의 함수 수 증가 | §4.4(`CREATE OR REPLACE FUNCTION` 금지) | §8.3 |

> **1번의 판정 주의**: §6.2A에 따라 현재 ACTIVATE는 42703으로 도달 불가하므로 **정상적으로는 실행 흔적이
> 있을 수 없다.** 흔적이 있다는 것은 (a) 누군가 phantom 컬럼 문제를 우회했거나, (b) 계약 밖 수정이
> 있었다는 뜻이다 — 어느 쪽이든 **그 자체가 계약 위반이며 Stop Condition**이다(§9.3).
> "결과적으로 아무 문제 없었다"는 면책 사유가 되지 않는다. 계약은 결과가 아니라 **행위**를 규율한다.

### §9.2 FAIL이 아닌 것 (오인 방지)

다음은 **이번 워크패킷의 결함이 아니다**. 검증자가 결함으로 보고하지 않도록 명시한다:

| 현상 | 이유 |
|---|---|
| `isolate_tenant()` **직접 호출** 시 23514 CHECK 위반 | 0090은 `tenant_status`에 `'ISOLATED'`를 쓴다. 그 RPC 수정은 **0-A-2 소관**이며, DB가 막는 것은 **의도된 동작**(§6.3). 단 이 확인을 위해 **실제 호출하지 말 것**(§4.1.1) — 정적 확인으로 충분 |
| `manage_subscription()` 어떤 액션이든 **42703**(`tenants.company_name`) 실패 | `company_name` phantom은 **별개의 기존 결함**이며 이번 범위 밖(`601505` §4.5.1). `tenant_status`와 무관하다 |
| ACTIVATE 분기가 CHECK로 보호되지 않음 | **알려진 잠재 위험**(§6.2A). 0-A-2/0-A-3 공통 완료조건으로 이관됨(`601505` §8A.1). 이번 DDL이 만든 문제가 아니다 |
| `onboard_tenant()` 여전히 실패 | 4개 독립 결함, 실호출자 0건 — **0-A-3 소관**(`601501` §6.2) |
| `pg_cron_jobs`에 `is_registered=true`인데 `pg_cron_job_id IS NULL`인 38행 | **0-A-2 승계 항목**(`601503` §5.3). 이번 범위 밖 |
| `stores.legal_entity_id`가 전 행 NULL | 백필은 시드 생성 시점에 수행(§4.2). NOT NULL 승격 판정은 5단계 말미(Open Item (h)) |
| 같은 법인에 SOLE 대표 2명이 INSERT됨 | **알려진 한계**(§5.6, Open Item (c)). 행 CHECK로 막을 수 없음 |
| `'TERMINATED'` 값의 사용처가 없음 | 전방호환용 신규 값(`601503` §2.6) |

### §9.3 Stop Condition 발동 (즉시 중단 + 재승인)

- §1의 pre-flight 중 하나라도 불일치
- §3.3에서 `service_role` 접근이 **성공**
- §4.1에서 `postgres` 아닌 소유자의 `SECURITY DEFINER` 함수 발견
- §4.2에서 함수 경유 접근도 **실패**
- §8.2에서 `cron.job`이 0행이 아니게 됨
- §6.2A에서 `manage_subscription()`의 `company_name` 참조가 **이미 제거돼 있음**(ACTIVATE 방벽 부재)
- §9.1A의 계약 위반 6가지 중 하나라도 발견

## §10 증거 수집 (§48 D단계)

모든 테스트는 **실행 결과 원문**을 캡처한다 — 오류코드(`42501`/`23505`/`23514`/`23503`/`42710`)와
반환 행 수를 그대로 기록한다. "예상대로 실패했다"는 서술만으로는 증거가 되지 않는다.
Stage 9 재검증자가 같은 명령으로 재현할 수 있도록 **실행한 SQL 전문과 출력**을 함께 남긴다.

## §11 근거 문서 목록 (§46)

| 문서 | 인용 | 용도 |
|---|---|---|
| `601501_ERD...md` (v4) | §2.1–§2.7, §3, §7 | 검증 대상 설계 |
| `601502_Overview...md` (v4) | §3, §4, §5 | 범위 절단·완료 정의 |
| `601503_Logic...md` (v4) | §2.1–§2.8, §4, §5, §6 | 의사 DDL·제약 상세 |
| `601505_ChangeContract...md` | §3, §4, §6 | 허용/금지/Stop Condition |
| `000701` §3(L253 Stage 5), §46, §48 | — | 단계 소유자, 근거목록, D단계 증거 |
| `000001_Md_Rules.md` §5.4.2, §5.4.3 | — | TestPlan 문서 규격 |
| `0002_create_hq_tenant_store.sql` | L8–24, L43–76, L60 | §1.2 baseline |
| `0022_create_rls_policies.sql` | L614–623 | §1.3 스키마 USAGE baseline |
| `0034_seed_data.sql` | L24–25, L52–55 | §6.1/§7.1 시드 대상 |
| `0072_create_pg_cron_schedules.sql` | L201–206, L219–230 | §1.4/§8.2 cron baseline |
| `0090_create_multitenant_isolation_rpc.sql` | L1283–1286(`v_new_status` 계산), L1293–1295(UPDATE) | §6.3/§9.2 의도된 실패 근거, §6.2A.2-4 `'ACTIVE'` 허용값 근거 |
| `0112_create_hq_admin_rpc.sql` | **L533**(`company_name` phantom SELECT), **L548**(`case p_action`), **L592–606**(SUSPEND), **L608–619**(ACTIVATE), L622–634(CANCEL) | **§6.2A 정적 검증 대상** — 분기 도달 불가 및 잠재 위험 근거 |

## Module Domain Tags

`hq`, `tenant`, `store`, `legal_entity`, `owner`, `representative`, `rls`, `grant`, `ddl`, `testplan`
