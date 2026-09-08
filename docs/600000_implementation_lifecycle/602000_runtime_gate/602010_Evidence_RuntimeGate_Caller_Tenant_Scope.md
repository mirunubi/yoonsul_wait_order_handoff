# 602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md

Status: Active
Lifecycle: RuntimeGate
DocumentType: Evidence
Last Updated: 2026-09-08

## §0 성격 · PRE-FLIGHT

`600023` §3의 Runtime Gate 형식으로 `catchmenu_common.get_tenant_health(uuid, text)` 1개를 측정한다.

```text
증명하는 것      JWT tenant ≠ parameter tenant → 차단
증명하지 않는 것 actor가 실제 직원인지, role이 업무에 맞는지, 업무 authority
```

### §0.1 PRE-FLIGHT 실행과 실측

```text
> git rev-parse HEAD
57dd996c96c5fc572a1e942f697da76006e808e9

> git status --short
(출력 없음)

> docker inspect supabase_db_yoonsul_wait_order_handoff --format '{{.Id}} {{.Config.Image}} {{json .Config.Labels}}'
b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec public.ecr.aws/supabase/postgres:17.6.1.156 {"com.docker.compose.project":"yoonsul_wait_order_handoff","com.supabase.cli.project":"yoonsul_wait_order_handoff","com.supabase.cli.workdir":"D:\\Workspace\\Yoonsul_Wait_Order_Handoff"}

> SELECT current_database(), version();
postgres | PostgreSQL 17.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 15.2.0, 64-bit

> SELECT filename, checksum, applied_at, applied_by, success, error_message
  FROM catchmenu_meta.migration_history
  WHERE success ORDER BY filename DESC LIMIT 1;
0171_merchant_account_foundation.sql | 5bbfa1fe9385f65afbfd5cdea0759e9902a59119b1588487a737e1f7571a1eea | 2026-08-30 11:46:47.552241+00 | postgres | t |

> SELECT * FROM catchmenu_meta.migration_history WHERE filename LIKE '0172%';
(0 rows)

> Test-Path sql/migrations/0172_caller_tenant_scope_gate.sql
False

> Test-Path docs/600000_implementation_lifecycle/602000_runtime_gate/602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md
False
```

`supabase/config.toml`의 `project_id`와 container의 `com.supabase.cli.project`·`com.supabase.cli.workdir`가 현재 저장소와 일치했다. 대상은 local dev DB다.

### §0.2 진행 중 Git HEAD 변경 실측

PRE-FLIGHT 뒤 종료 확인 전에 Git HEAD가 외부에서 변경됐다. 이 실행에서는 `git add`·`git commit`·`git push`를 호출하지 않았다.

```text
PRE-FLIGHT HEAD  57dd996c96c5fc572a1e942f697da76006e808e9
종료 시 HEAD     0bfed87a8f7ba1a1238a11bc613b6ddb209ea467

c6e522cfaee23d6f0cc97578d1faf9e0b56e311c
docs: 601900 readme records where the spiral ended

0bfed87a8f7ba1a1238a11bc613b6ddb209ea467
sql: caller tenant scope gate on tenant health
sql/migrations/0172_caller_tenant_scope_gate.sql | 184 insertions
```

종료 시 `HEAD`·`origin/main`·`origin/HEAD`는 모두 `0bfed87`을 가리켰다. 적용한 `0172`의 파일 SHA-256과 migration history checksum은 `194aa3b333c43efd3eff08e7df571437b112fca2a8f2cad91c56a8366ff4c620`으로 일치한다.

### §0.3 Korean / encoding safety

```text
KOREAN / ENCODING SAFETY:
- Preserve UTF-8.
- Do not normalize encoding.
- Do not run formatters.
- Do not use PowerShell Set-Content.
- Do not rewrite full markdown files.
- Do not perform broad search-and-replace over Korean text.
- Do not modify Korean prose, Korean brand wording, menu names, membership names, customer-facing wording, or philosophy text unless explicitly instructed.
- If you are Cursor, do not edit Korean body text. Only report the required change.
- If a file contains Korean body text and the requested change requires semantic editing, STOP and report: "Requires Codex or manual Korean document editing."
- Path/reference/index/map updates are allowed only when they do not rewrite Korean prose.
```

## §1 공격

`601919` T01 재현 스크립트 전문:

```sql
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO catchmenu_hq.tenants (id,tenant_code,tenant_name,tenant_type)
VALUES ('eeeeeeee-0000-4000-8000-000000000001','RG01_B','RG01 synthetic B','TEST'),
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','RG01_A','RG01 synthetic A','TEST');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{"tenant_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","store_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","actor_type":"STAFF"}}';
SELECT catchmenu_common.get_tenant_health('eeeeeeee-0000-4000-8000-000000000001','ko')->>'success' AS success;
ROLLBACK;
```

## §2 재현 로그

현재 상태에서 동일 공격이 성공했다.

```text
BEGIN
INSERT 0 2
SET
SET
 success 
---------
 true
(1 row)

ROLLBACK
```

`success=true`를 실측했다. 합성 tenant 2행은 `ROLLBACK`으로 제거됐다.

## §3 invariant

아래 invariant는 Human이 확정한 문구를 그대로 인용한다.

```text
업무 RPC 는 caller 의 tenant 를 세션 claim 에서 도출한다
파라미터 tenant 는 처리 대상이지 권한의 근거가 아니다
둘이 다르면 거부한다
service_role 은 이 대조를 면제받는다
claims 가 없으면 거부한다 — fail closed
```

## §4 근거

| 구분 | 근거 |
|---|---|
| Doctrine | `010004` §7 Deny-By-Default — resolved tenant context가 없거나 일치하지 않으면 fail closed |
| Human invariant | 이 문서 §3 |
| Runtime evidence | `601919` C-01 · T01 |
| Supporting inventory | `601920` |
| Current mechanism | `catchmenu_common.current_tenant_id()` · `catchmenu_common.is_service_role()` |
| Implementation precedent only | `0143_add_no_payment_kds_release_policy.sql`의 caller context 비교. Doctrine이 아닌 구현 선례 |

## §5 migration

파일: `sql/migrations/0172_caller_tenant_scope_gate.sql`

```sql
-- Workpacket: 602010
-- Runtime Gate RG-01; Human invariant: 602010 section 3.
-- Scope: one internal helper and get_tenant_health entry point only.

BEGIN;

CREATE FUNCTION catchmenu_common.assert_caller_tenant_scope(p_tenant_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO pg_catalog
AS $gate$
DECLARE
  v_caller_tenant_id uuid;
BEGIN
  IF catchmenu_common.is_service_role() THEN
    RETURN;
  END IF;

  v_caller_tenant_id := catchmenu_common.current_tenant_id();
  IF v_caller_tenant_id IS NULL
     OR v_caller_tenant_id IS DISTINCT FROM p_tenant_id THEN
    RAISE EXCEPTION USING
      ERRCODE = '42501',
      MESSAGE = 'caller tenant scope denied';
  END IF;
END;
$gate$;

REVOKE ALL ON FUNCTION catchmenu_common.assert_caller_tenant_scope(uuid) FROM PUBLIC;

CREATE OR REPLACE FUNCTION catchmenu_common.get_tenant_health(p_tenant_id uuid, p_locale text DEFAULT 'ko'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'catchmenu_common', 'catchmenu_hq', 'catchmenu_pos', 'catchmenu_payment'
AS $function$
declare
  v_plan record;
  v_quota_summary jsonb;
  v_rate_limit_summary jsonb;
  v_security_summary jsonb;
  v_business_day date;
  v_store_count int;
  v_overall_health text;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 플랜 정보
  select plan_tier, plan_status,
         monthly_fee, trial_ends_at,
         subscription_starts_at
  into v_plan
  from catchmenu_common.tenant_plan_configs
  where tenant_id = p_tenant_id;

  -- 매장 수
  select count(*) into v_store_count
  from catchmenu_hq.stores
  where tenant_id = p_tenant_id
    and is_active = true;

  -- 쿼터 요약
  select jsonb_build_object(
    'total_quotas', count(*),
    'exceeded', count(*) filter (
      where current_usage > quota_limit
    ),
    'warning_level', count(*) filter (
      where current_usage::numeric
        / nullif(quota_limit, 0) * 100
        >= warning_threshold_pct
    ),
    'usage_by_resource', coalesce(
      jsonb_object_agg(
        resource_type,
        jsonb_build_object(
          'limit', quota_limit,
          'usage', current_usage,
          'pct', case quota_limit
            when 0 then 0
            else (
              current_usage::numeric
              / quota_limit * 100
            )::int
          end
        )
      ),
      '{}'::jsonb
    )
  )
  into v_quota_summary
  from catchmenu_common.tenant_quotas
  where tenant_id = p_tenant_id
    and is_active = true;

  -- Rate limit 요약
  select jsonb_build_object(
    'total_limits', count(*),
    'blocked', count(*) filter (
      where is_blocked = true
        and blocked_until > now()
    ),
    'violations_today', coalesce(
      sum(violation_count)
        filter (
          where last_violation_at::date
            = v_business_day
        ), 0
    )
  )
  into v_rate_limit_summary
  from catchmenu_common.tenant_rate_limits
  where tenant_id = p_tenant_id;

  -- 보안 요약
  select jsonb_build_object(
    'violations_24h', count(*) filter (
      where is_violation = true
        and created_at >
          now() - interval '24 hours'
    ),
    'critical_24h', count(*) filter (
      where event_severity = 'CRITICAL'
        and created_at >
          now() - interval '24 hours'
    ),
    'last_audit_at', max(created_at) filter (
      where audit_event
        = 'security_audit_completed'
    )
  )
  into v_security_summary
  from catchmenu_common.security_audit_log
  where tenant_id = p_tenant_id;

  -- 전체 건강 상태
  v_overall_health := case
    when (
      v_plan.plan_status not in (
        'ACTIVE', 'TRIAL'
      )
      or (
        v_plan.plan_status = 'TRIAL'
        and v_plan.trial_ends_at < now()
      )
    ) then 'CRITICAL'
    when (
      (v_security_summary->>'critical_24h')::int > 0
      or (v_quota_summary->>'exceeded')::int > 0
    ) then 'WARNING'
    else 'HEALTHY'
  end;

  return catchmenu_common.build_success_response(
    p_message_key := 'tenant_health_loaded',
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'overall_health', v_overall_health,
      'plan', jsonb_build_object(
        'tier', v_plan.plan_tier,
        'status', v_plan.plan_status,
        'monthly_fee', v_plan.monthly_fee,
        'trial_ends_at', v_plan.trial_ends_at,
        'subscription_starts_at',
          v_plan.subscription_starts_at
      ),
      'stores', jsonb_build_object(
        'active_count', v_store_count
      ),
      'quotas', v_quota_summary,
      'rate_limits', v_rate_limit_summary,
      'security', v_security_summary,
      'checked_at', now()
    ),
    p_locale := p_locale
  );
end;
$function$;

COMMIT;
```

### §5.1 적용 로그

첫 적용은 마지막 함수 정의의 세미콜론 누락으로 실패했고 migration transaction 전체가 롤백됐다.

```text
APPLY 0172_caller_tenant_scope_gate.sql ...
FAIL  0172_caller_tenant_scope_gate.sql
      --- psql output ---
BEGIN
CREATE FUNCTION
REVOKE
ERROR:  syntax error at or near "COMMIT"
LINE 152: COMMIT;
          ^
      -------------------
      Stopping at first failure. No further migrations were attempted.
```

실패 직후 실측:

```text
SELECT to_regprocedure('catchmenu_common.assert_caller_tenant_scope(uuid)');
(null)

SELECT filename, success FROM catchmenu_meta.migration_history
WHERE filename = '0172_caller_tenant_scope_gate.sql';
0172_caller_tenant_scope_gate.sql | f
```

같은 `0172`의 세미콜론을 수정하고 재적용했다.

```text
BEGIN
CREATE FUNCTION
REVOKE
CREATE FUNCTION
COMMIT
```

적용 후 같은 migration runner를 다시 실행했다.

```text
OK    0168_create_operational_authority_foundation.sql  (already applied, checksum matches)
OK    0169_authority_owner_role_and_sole_representative_uniqueness.sql  (already applied, checksum matches)
OK    0170_person_vocabulary_normalization.sql  (already applied, checksum matches)
OK    0171_merchant_account_foundation.sql  (already applied, checksum matches)
OK    0172_caller_tenant_scope_gate.sql  (already applied, checksum matches)
All sequence-numbered migrations applied or already up to date.
```

## §6 재실행 로그 — 4건 전부

### §6.1 T1 — authenticated + tenant A claim → target B

```sql
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO catchmenu_hq.tenants (id,tenant_code,tenant_name,tenant_type)
VALUES ('eeeeeeee-0000-4000-8000-000000000001','RG01_B','RG01 synthetic B','TEST'),
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','RG01_A','RG01 synthetic A','TEST');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{"tenant_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","store_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","actor_type":"STAFF"}}';
\set ON_ERROR_STOP off
\set VERBOSITY verbose
SELECT catchmenu_common.get_tenant_health('eeeeeeee-0000-4000-8000-000000000001','ko')->>'success' AS success;
ROLLBACK;
```

```text
BEGIN
INSERT 0 2
SET
SET
ROLLBACK
ERROR:  42501: caller tenant scope denied
CONTEXT:  PL/pgSQL function catchmenu_common.assert_caller_tenant_scope(uuid) line 12 at RAISE
SQL statement "SELECT catchmenu_common.assert_caller_tenant_scope(p_tenant_id)"
PL/pgSQL function get_tenant_health(uuid,text) line 11 at PERFORM
LOCATION:  exec_stmt_raise, pl_exec.c:3911
```

판정: DENY. SQLSTATE `42501`.

### §6.2 T2 — authenticated + tenant A claim → target A

```sql
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO catchmenu_hq.tenants (id,tenant_code,tenant_name,tenant_type)
VALUES ('eeeeeeee-0000-4000-8000-000000000001','RG01_B','RG01 synthetic B','TEST'),
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','RG01_A','RG01 synthetic A','TEST');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","role":"authenticated","app_metadata":{"tenant_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","store_id":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa","actor_type":"STAFF"}}';
\set ON_ERROR_STOP off
\set VERBOSITY verbose
SELECT catchmenu_common.get_tenant_health('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','ko')->>'success' AS success;
ROLLBACK;
```

```text
BEGIN
INSERT 0 2
SET
SET
 success 
---------
 true
(1 row)

ROLLBACK
```

판정: SUCCESS.

### §6.3 T3 — authenticated + claims 없음 → target A

```sql
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO catchmenu_hq.tenants (id,tenant_code,tenant_name,tenant_type)
VALUES ('eeeeeeee-0000-4000-8000-000000000001','RG01_B','RG01 synthetic B','TEST'),
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','RG01_A','RG01 synthetic A','TEST');
SET LOCAL ROLE authenticated;
SELECT current_setting('request.jwt.claims',true) IS NULL AS claims_absent;
\set ON_ERROR_STOP off
\set VERBOSITY verbose
SELECT catchmenu_common.get_tenant_health('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','ko')->>'success' AS success;
ROLLBACK;
```

```text
BEGIN
INSERT 0 2
SET
 claims_absent 
---------------
 t
(1 row)

ERROR:  42501: caller tenant scope denied
CONTEXT:  PL/pgSQL function catchmenu_common.assert_caller_tenant_scope(uuid) line 12 at RAISE
SQL statement "SELECT catchmenu_common.assert_caller_tenant_scope(p_tenant_id)"
PL/pgSQL function get_tenant_health(uuid,text) line 11 at PERFORM
LOCATION:  exec_stmt_raise, pl_exec.c:3911
ROLLBACK
```

판정: DENY. `claims_absent=t`, SQLSTATE `42501`.

### §6.4 T4 — service_role → target

실제 `service_role` DB 역할과 `request.jwt.claims.role=service_role`을 함께 설정했다.

```sql
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO catchmenu_hq.tenants (id,tenant_code,tenant_name,tenant_type)
VALUES ('eeeeeeee-0000-4000-8000-000000000001','RG01_B','RG01 synthetic B','TEST'),
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','RG01_A','RG01 synthetic A','TEST');
SET LOCAL ROLE service_role;
SET LOCAL request.jwt.claims = '{"role":"service_role"}';
\set ON_ERROR_STOP off
\set VERBOSITY verbose
SELECT catchmenu_common.get_tenant_health('eeeeeeee-0000-4000-8000-000000000001','ko')->>'success' AS success;
ROLLBACK;
```

```text
BEGIN
INSERT 0 2
SET
SET
ERROR:  42501: permission denied for schema catchmenu_common
LINE 1: SELECT catchmenu_common.get_tenant_health('eeeeeeee-0000-400...
               ^
LOCATION:  aclcheck_error, aclchk.c:2843
ROLLBACK
```

판정: FAIL. `service_role`은 `catchmenu_common` schema `USAGE`가 없어 helper에 진입하기 전에 SQLSTATE `42501`로 실패했다.

helper의 service-role 면제 분기만 분리해 확인하기 위해, 기존 `get_tenant_health` EXECUTE ACL을 가진 `authenticated` DB 역할에 `request.jwt.claims.role=service_role`을 설정한 진단 실행은 성공했다.

```sql
\set ON_ERROR_STOP on
BEGIN;
INSERT INTO catchmenu_hq.tenants (id,tenant_code,tenant_name,tenant_type)
VALUES ('eeeeeeee-0000-4000-8000-000000000001','RG01_B','RG01 synthetic B','TEST'),
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','RG01_A','RG01 synthetic A','TEST');
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"role":"service_role"}';
\set ON_ERROR_STOP off
\set VERBOSITY verbose
SELECT catchmenu_common.get_tenant_health('eeeeeeee-0000-4000-8000-000000000001','ko')->>'success' AS success;
ROLLBACK;
```

```text
BEGIN
INSERT 0 2
SET
SET
 success 
---------
 true
(1 row)

ROLLBACK
```

이 진단 성공은 요구된 T4의 대체 판정이 아니다.

Primary exploit closure: T1에서 §2와 동일한 공격이 실패했다. T4가 실패했으므로 §6 전건 PASS 조건은 충족되지 않았다.

> ⚠️ **재판정 (2026-09-08) — `UNVERIFIABLE`**
>
> **`service_role` 이 `catchmenu_common` 을 포함한 13개 스키마에 `USAGE` 가 없다.**
>
> ```text
> service_role USAGE 있음   catchmenu_ai · catchmenu_dev   2 / 15
> authenticated USAGE 있음  11 / 15
> ```
>
> **`T4` 는 gate 가 만든 실패가 아니다.**
> **`0172` 이전부터 `service_role` 은 어떤 catchmenu 함수도 호출할 수 없었다.**
>
> **helper 의 면제 분기 자체는 작동한다** — §6.4 진단 실행이 그것을 증명했다.
>
> **`T4` 를 `UNVERIFIABLE` 로 판정하고 도달 불가는 `RG-F1` 로 분리한다.**

## §7 회귀 — 예상 delta 대조

### §7.1 catalog delta

| 지표 | 예상 | 적용 전 | 적용 후 | delta | 일치 |
|---|---:|---:|---:|---:|---|
| migration_history success | +1 | 170 | 171 | +1 | 예 |
| 총 함수 수 | +1 | 4040 | 4041 | +1 | 예 |
| SECURITY DEFINER 총수 | 0 | 471 | 471 | 0 | 예 |
| policy 수 | 0 | 183 | 183 | 0 | 예 |
| RLS enabled 수 | 0 | 202 | 202 | 0 | 예 |
| FORCE RLS 수 | 0 | 173 | 173 | 0 | 예 |

### §7.2 get_tenant_health 전후 exact compare

| 항목 | before | after | change |
|---|---|---|---|
| signature | `p_tenant_id uuid, p_locale text` | 동일 | 0 |
| argument defaults | `'ko'::text` | 동일 | 0 |
| return type | `jsonb` | 동일 | 0 |
| language | `plpgsql` | 동일 | 0 |
| volatility | `STABLE` | 동일 | 0 |
| security | `SECURITY DEFINER` | 동일 | 0 |
| owner | `postgres` | 동일 | 0 |
| search_path | `catchmenu_common, catchmenu_hq, catchmenu_pos, catchmenu_payment` | 동일 | 0 |
| EXECUTE ACL | `postgres, authenticated` | 동일 | 0 |

함수 본문은 진입점의 아래 1행을 제외하고 before와 after가 exact match다.

```sql
perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);
```

### §7.3 새 helper 실측

| 항목 | 실측 |
|---|---|
| signature | `catchmenu_common.assert_caller_tenant_scope(uuid)` |
| return type | `void` |
| owner | `postgres` |
| security | `SECURITY INVOKER` |
| language · volatility | `plpgsql` · `VOLATILE` |
| search_path | `pg_catalog` |
| ACL | `{postgres=X/postgres}` |
| PUBLIC EXECUTE | false |
| authenticated EXECUTE | false |
| privileged table read | 없음. `current_tenant_id()` · `is_service_role()` · UUID 비교만 수행 |

### §7.4 기존 테스트

```text
PASS hydration registry validation
  schema:  packages\hydration_registry\hydration_registry.schema.json
  example: packages\hydration_registry\hydration_registry.example.json

PASS source module map validation
  schema:  packages\source_module_map\source_module_map.schema.json
  example: packages\source_module_map\source_module_map.example.json
```

`flutter` 명령은 이 호스트의 PATH에 없어 Flutter widget test는 실행되지 않았다.

### §7.5 Check-Governance

```text
> tools/Check-Governance.ps1 -Top 0

작업 전
ERROR 329 · WARN 26 · REVIEW 153 · TOTAL 508

작업 후
ERROR 330 · WARN 28 · REVIEW 153 · TOTAL 511

[ERROR] G11
600000_implementation_lifecycle/602000_runtime_gate/602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md
file exists but is not registered in 000005

[WARN] G12
600000_implementation_lifecycle/602000_runtime_gate
folder exists but is not listed in 000007

[WARN] G15
sql/migrations/0172_caller_tenant_scope_gate.sql
workpacket 602010 -> no ChangeContract document found
CONTRACT_NOT_FOUND
```

예상 finding은 `602010` 미색인 G11 1건이었다. G12와 G15가 추가로 발생했으므로 §7 회귀는 FAIL이다.

### §7.6 Gate 판정

```text
§2 동일 공격 재현     SUCCESS
§6 동일 공격 차단     SUCCESS
§6 T1~T4             FAIL — T4 service_role 호출 실패
§7 catalog delta      PASS
§7 기존 실행 가능 검사 PASS
§7 governance         FAIL — 신규 G12 · G15

FINAL                 FAIL
```

요구된 §6 T4 성공 조건과 `600023` §3.1의 §7 PASS 조건이 모두 충족되지 않았다. 진행 중 Git HEAD 외부 변경도 실측됐다. 추가 migration 생성, 범위 확대, 다른 함수 수정, ad-hoc DB patch는 수행하지 않았다.

> ⚠️ **재판정 (2026-09-08) — `CONDITIONAL PASS`**
>
> ```text
> §6 T1   PASS   타 tenant 접근이 42501 로 거부됐다
> §6 T2   PASS   동일 tenant 는 성공한다
> §6 T3   PASS   claims 없으면 42501 — fail closed
> §6 T4   UNVERIFIABLE   service_role 도달 불가 — RG-F1
>
> §7 catalog delta   PASS   예상과 실측이 전부 일치
> §7 governance      G11 · G12 예상 · G15 별건 — RG-F2
> ```
>
> **`600023` §3.1 의 두 PASS 조건**
>
> ```text
> 1  §2 의 공격이 §6 에서 실패한다        충족 — T1
> 2  §7 회귀 검증이 통과한다              catalog delta 충족
>                                        governance 는 별건 분리 후 충족
> ```
>
> **Primary exploit closure 가 성립한다.**
>
> ⚠️ **초판 `FAIL` 판정은 지시서 문면대로 정확했다.**
> **지시서가 예상 목록을 좁게 잡았고 `T4` 의 전제를 확인하지 않았다.**
> **판정을 뒤집는 것이 아니라 지시서 오류를 정정한 뒤 다시 판정한 것이다.**

### §7.7 governance finding 재판정 — 2026-09-08

| # | 초판 | 재판정 | 사유 |
|---|---|---|---|
| G11 | 예상 | 예상 | `602010` 미색인 |
| G12 | **예상 밖 → FAIL** | **예상** | `G11` 의 폴더판이며 지시서 예상 목록이 누락했다 |
| G15 | **예상 밖 → FAIL** | **별건** | 체커가 migration 마다 ChangeContract 를 요구한다. Runtime Gate 는 ChangeContract 를 만들지 않는다 |

> ⚠️ **`G15` 는 `600023` 이 만든 규칙 충돌이다.**
>
> ```text
> 600023 §3 이 정한 산출물   RG 문서 1 + migration
> 체커 G15 가 요구하는 것    migration 마다 ChangeContract
> ```
>
> **`600023` 채택 시 그 충돌을 확인하지 않았다.**
> **별건으로 처분한다** — `RG-F2`.

## §8 근거 문서 목록 (000701 §46)

| 문서 | 인용 |
|---|---|
| `000001_Md_Rules.md` | §1 |
| `000015_Korean_Document_And_Encoding_Safety_Rules.md` | §7 · §9 |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §7 |
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §5 |
| `601919_Audit_Independent_Foundation_Audit.md` | C-01 · T01 |
| `601920_Evidence_Security_Definer_Inventory.md` | supporting inventory |
| `0090_create_multitenant_isolation_rpc.sql` | 기존 `get_tenant_health` |
| `0143_add_no_payment_kds_release_policy.sql` | implementation precedent only |
| `0172_caller_tenant_scope_gate.sql` | 적용 migration |

## §9 이 gate 가 발견한 것

| # | 내용 | 상태 |
|---|---|---|
| **RG-F1** | **`service_role` 이 13 / 15 스키마에 `USAGE` 가 없다.** `manage_subscription` · `onboard_tenant` 의 `service_role` EXECUTE GRANT 가 도달 불가다. `is_service_role()` 면제 분기가 죽은 코드다. `0143` 의 3단계 패턴에도 `service_role` 경로가 없다 | 신규 |
| **RG-F2** | 체커 `G15` 가 migration 마다 ChangeContract 를 요구한다. `600023` Runtime Gate 는 ChangeContract 를 만들지 않는다 | 신규 |

> ⚠️ **`RG-F1` 은 `601919` · `601920` 이 기록하지 않았다.**
>
> ```text
> 601920   함수별 EXECUTE ACL 만 인벤토리했다
> 601919   service_role 언급 0건
> ```
>
> **「EXECUTE 를 줬다」와 「호출 가능하다」가 다르다.**
> **schema `USAGE` 를 보지 않으면 GRANT 가 도달 불가인 것이 안 보인다.**

**실측**

```text
service_role USAGE 있음   catchmenu_ai · catchmenu_dev
service_role USAGE 없음   agent · audit · common · gateway · hq ·
                          integrations · kds · knowledge · ledger ·
                          meta · payment · pos · store
authenticated USAGE 있음  11 / 15
```

> ⚠️ **`TI-3` 이 발동 주체로 상정한 automated security path 와
> `TI-14` 가 전제한 service_role 경로가 물리적으로 막혀 있다.**
> **`0-B` · `0-C` 가 그것을 열지 여부는 미정이다.**
