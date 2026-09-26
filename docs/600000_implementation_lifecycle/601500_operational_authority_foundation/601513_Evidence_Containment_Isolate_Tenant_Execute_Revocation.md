# 601513_Evidence_Containment_Isolate_Tenant_Execute_Revocation.md

Status: Active (local)
Lifecycle: Evidence
DocumentType: Evidence
Last Updated: 2026-09-21

## §0 상태

```text
local 적용       완료 — 0179_ctn1a_revoke_isolate_tenant_execute.sql
                 migration_history success = t · 2026-09-21 11:15:56 UTC
cloud 적용       미적용
cloud Exposed schemas   미확인
```

> ⚠️ **이 문서는 local/dev 컨테이너 `supabase_db_yoonsul_wait_order_handoff` 기준이다.**
> **cloud 결과라고 표현하지 않는다.**

## §1 결정 — 2026-09-21, Human 확정

### CTN-1a — `601505` §4.1.1 호출 금지의 기술적 집행 — 직접 경로 봉쇄

```text
대상   catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)
       catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)
조치   두 함수의 EXECUTE 를 PUBLIC · anon · authenticated 에서 회수
불변   함수 본문 · signature · 소유자 · proconfig · 다른 함수의 권한
성격   601505 §4.1.1 을 바꾸는 것이 아니라 집행한다
       601902 §5 "EXECUTE ACL 은 정하지 않는다" 의 명시적 예외
```

### CTN-1b — 고치지 않는 것

```text
p_reason(42883) 방벽은 고치지 않는다. 간접 경로는 이번에 닫지 않는다
```

## §1.1 배경 원칙 — Human 결정 아님

> 앵커 판단이다. Human 이 결정으로 승인한 문장이 아니다.
> 정식 기록 위치는 600023 개정 후보이며 미결정이다.

> ⚠️ **Runtime Gate 에서 취약점을 발견했다고 해서 그 Gate 가 함수의 소유권을 얻지 않는다.**
> **`isolate_tenant` 본문 수정은 `601505` §4.1 이 `0-A-2` 소관으로 정했고, 이 조치는 본문을 건드리지 않는다.**

## §2 근거 실측

근거 유형 — 카탈로그 실측 · 정적 분석. **runtime 호출 0건.**

### §2.1 7함수 도출

`601505` §4 는 개별 함수 3곳(`isolate_tenant` · `manage_subscription` 2분기 · `detect_threat`)을 표로 적고 이름 목록을 열거하지 않는다. 「7」은 `601500_Readme` 142행이 정의한다.

```text
| `sql/migrations/0090`/`0112`/`0121`/`0130`/`0131` | `isolate_tenant()` 도달 경로 7개 함수 — §4.1 금지 조항의 대상 |
```

live 카탈로그에서 `isolate_tenant` 를 뿌리로 한 전이 폐포가 정확히 7개다.

| depth | 함수 | secdef | 호출 대상 |
|---|---|---|---|
| 0 | `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` | DEFINER | — |
| 1 | `catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)` | DEFINER | `isolate_tenant` |
| 1 | `catchmenu_common.manage_subscription(uuid,text,text,text,uuid,text)` | DEFINER | `isolate_tenant` |
| 2 | `catchmenu_common.gateway_audit_entry(...)` | DEFINER | `detect_threat` |
| 2 | `catchmenu_common.verify_security_token(text,text,text,boolean)` | DEFINER | `detect_threat` |
| 2 | `catchmenu_payment.record_van_transaction(...)` | DEFINER | `detect_threat` |
| 2 | `catchmenu_store.check_staff_permission(uuid,uuid,uuid,text,integer,text)` | DEFINER | `detect_threat` |

```text
depth 3 호출자          0건
tgfoid 가 7함수인 트리거   0건
cron.job                 0행 (cron 스키마 · job 테이블은 존재)
```

### §2.2 적용 전 권한

| 함수 | owner | proacl | proconfig | md5(prosrc) |
|---|---|---|---|---|
| `detect_threat` | postgres | `=X/postgres \| postgres=X/postgres \| authenticated=X/postgres` | `search_path=catchmenu_common` | `992c78c881be2f23bcac8050b60ad2b7` |
| `isolate_tenant` | postgres | `postgres=X/postgres \| authenticated=X/postgres` | `search_path=catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit` | `f53ea7f556e89cec883b9ca6b482ca3e` |

```text
has_function_privilege    anon  authenticated  service_role  postgres
detect_threat              t        t              t            t
isolate_tenant             f        t              f            t
```

> `detect_threat` 의 `anon` · `service_role` 은 명시 grant 가 아니라 PUBLIC(`=X`) 경유였다.

**상위 5함수 — 적용 전**

| 함수 | proacl | md5(prosrc) |
|---|---|---|
| `catchmenu_common.gateway_audit_entry` | `=X \| postgres=X \| authenticated=X` | `bbfac99ac170a83d988c610435a00732` |
| `catchmenu_common.manage_subscription` | `postgres=X \| service_role=X` | `3ceb5089e1c2305628db36e485be9bcd` |
| `catchmenu_common.verify_security_token` | `=X \| postgres=X \| authenticated=X` | `b5c978db183d70e025ff97cc2bd1785f` |
| `catchmenu_payment.record_van_transaction` | `=X \| postgres=X \| authenticated=X` | `16aed7926150f2729d578194a3c4412b` |
| `catchmenu_store.check_staff_permission` | `=X \| postgres=X \| authenticated=X` | `297947c8bca176dab515b1f22353cb5b` |

```text
catchmenu_* 함수 475개 proacl 스냅샷 md5   ea4fd338a40aaa71ef2133bbbd0b86ea
```

### §2.3 접속 경로

```text
anon · authenticated · service_role   rolcanlogin = f  (NOLOGIN)
authenticator                          rolcanlogin = t · rolinherit = f
                                       anon · authenticated · service_role 의 member
postgres                               세 role 의 member (admin_option t)
supabase_realtime_admin                세 role 의 member

→ authenticated 로 전환할 수 있는 role 은 authenticator · postgres ·
  supabase_realtime_admin 3개다. 이 중 일반 사용자 요청이 지나는 경로는
  authenticator(PostgREST) 뿐이다.
```

### §2.4 앱 · API

```text
앱 소스 (catchmenu_app/lib)   isolate_tenant · detect_threat 문자열 0건
앱 스키마 상수                 catchmenu_pos · store · payment · common · kds · dev
                               "Exposed schemas 에 등록되어 있어야 rpc 호출이 가능하다" (주석)
local API 노출                 supabase/config.toml  schemas = ["public", "graphql_public"]
public 스키마 wrapper          0건
```

## §3 migration · 적용

### §3.1 `0179` 전문

```sql
-- Migration: 0179_ctn1a_revoke_isolate_tenant_execute.sql
-- Workpacket: 601513
-- Containment CTN-1a: enforce 601505 §4.1.1 (no call path) by revoking
-- EXECUTE on isolate_tenant and detect_threat from PUBLIC, anon, authenticated.
-- Explicit exception to 601902 §5 (EXECUTE ACL). Human approved 2026-09-21.
-- Function bodies, signatures, owners, and proconfig are unchanged.
-- Not closed: indirect path via SECURITY DEFINER callers (CTN-1b).
-- Idempotent: REVOKE of a privilege that is not granted is a no-op without error.

BEGIN;

REVOKE EXECUTE ON FUNCTION catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)
  FROM PUBLIC, anon, authenticated;

REVOKE EXECUTE ON FUNCTION catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)
  FROM PUBLIC, anon, authenticated;

COMMIT;
```

```text
18행 · UTF-8 · BOM 없음 · CR 0 · EOF 0a
문장   REVOKE 2 · CREATE 0 · ALTER 0 · DROP 0 · GRANT 0
checksum (CRLF→LF 정규화 SHA-256)   73c2e6b1ea5a2bfaa79b5a6929bff3ae345706c2a579b076102edee44a99a39c
```

### §3.2 적용 대상 사전 증명

`tools/apply_migrations.py` 는 인자 · 옵션이 없다. 대상 선정은 코드로 확인했다.

```text
discover_migrations()   sql/migrations/*.sql 중 ^(\d{4})_.+\.sql$ 만 순서대로
load_history()          WHERE success = true 인 행만 적재
main()                  history 에 없는 파일만 APPLY · checksum 불일치면 정지
```

동일 판정식으로 read-only 대조한 결과

```text
NNNN 파일          178 (0179 포함)
history success    177
중복 시퀀스        0
checksum 불일치    0
적용 대상          ['0179_ctn1a_revoke_isolate_tenant_execute.sql']
```

> `0073_final_verification.sql` 은 history 에 `success = f` 1행이 있으나 `sql/_excluded_from_local_replay/` 로 이동돼(`525c3ac`) `sql/migrations/` 에 없으므로 순회 대상이 아니다.

### §3.3 적용 명령과 출력

```bash
python tools/apply_migrations.py
```

```text
SKIP  seed_yoonsul_menu.sql  (does not match NNNN_name.sql sequence pattern; not part of tracked order. Local-target check passed -- this file is not auto-executed by this script, but is protected the same way if it ever is.)
APPLY 0179_ctn1a_revoke_isolate_tenant_execute.sql ...
OK    0179_ctn1a_revoke_isolate_tenant_execute.sql  (applied)
All sequence-numbered migrations applied or already up to date.
exit=0
```

기존 177개 파일은 전부 `OK … (already applied, checksum matches)` 였다. 확인용 재실행 1회에서 178개 전부 `already applied` 이며 APPLY 0건이다 — 그 실행의 DB 동작은 SELECT 뿐이다.

### §3.4 `migration_history` 행

```text
filename       0179_ctn1a_revoke_isolate_tenant_execute.sql
checksum       73c2e6b1ea5a2bfaa79b5a6929bff3ae345706c2a579b076102edee44a99a39c
success        t
applied_at     2026-09-21 11:15:56.588353+00
error_message  (없음)
```

## §4 검증

모든 검증은 `default_transaction_read_only=on` 세션이다. **7함수 호출 0건 · `set role` 0회.**

### V1 — EXECUTE grantee = {postgres} 뿐 · PASS

```text
detect_threat   postgres  is_grantable f
isolate_tenant  postgres  is_grantable f
```

### V2 — 권한 행렬 · PASS

```text
                anon  authenticated  service_role  postgres
detect_threat    f        f              f            t
isolate_tenant   f        f              f            t
```

### V3 — 두 함수 본문 · 소유자 · proconfig 불변 · PASS

| 함수 | owner | proconfig | md5(prosrc) | proacl |
|---|---|---|---|---|
| `detect_threat` | postgres | 적용 전과 동일 | `992c78c881be2f23bcac8050b60ad2b7` = 적용 전 | `postgres=X/postgres` |
| `isolate_tenant` | postgres | 적용 전과 동일 | `f53ea7f556e89cec883b9ca6b482ca3e` = 적용 전 | `postgres=X/postgres` |

### V4 — 상위 5함수 불변 · PASS

5함수 모두 proacl · md5(prosrc) 가 §2.2 적용 전 값과 동일하다.

### V5 — 변화한 함수가 정확히 두 개 · PASS

```text
fn_count                  475  (적용 전과 동일)
current_md5               c7b839149cce41f41523ff61583871c3
reconstructed_pre_md5     ea4fd338a40aaa71ef2133bbbd0b86ea
recorded_pre_md5          ea4fd338a40aaa71ef2133bbbd0b86ea
```

현재 스냅샷에서 **두 대상 함수의 proacl 만** §2.2 의 적용 전 값으로 되돌려 해시하면 적용 전 해시와 정확히 일치한다. 나머지 473개의 proacl 은 변하지 않았다.

> ⚠️ **본문(prosrc) 전체 스냅샷은 적용 전에 확보하지 못했다.** 적용 직전 채집 SQL 이 `provolatile`(`"char"`) 캐스트 누락으로 실패했고 같은 명령 안의 적용은 진행됐다. 475개 전체 본문 불변은 **정적 근거**로만 주장한다 — `0179` 에는 `CREATE` · `ALTER` · `DROP` 이 0건이고 `REVOKE` 는 prosrc 를 바꾸지 않는다. 대상 · 상위 7함수의 본문 불변은 V3 · V4 가 해시로 확인했다.

### V6a — 구조 증명 · PASS

```text
isolate_tenant · detect_threat 를 호출하는 함수 (두 대상 자신 제외)
  catchmenu_common.gateway_audit_entry        DEFINER  postgres  → detect_threat
  catchmenu_common.manage_subscription        DEFINER  postgres  → isolate_tenant
  catchmenu_common.verify_security_token      DEFINER  postgres  → detect_threat
  catchmenu_payment.record_van_transaction    DEFINER  postgres  → detect_threat
  catchmenu_store.check_staff_permission      DEFINER  postgres  → detect_threat
  (detect_threat 자신 → isolate_tenant · DEFINER · postgres — V3)

INVOKER 호출자                0건
catchmenu 밖 호출자           0건
트리거                         0건
cron.job                       0행
```

모든 호출자가 `SECURITY DEFINER` · owner `postgres` 이고 `postgres` 는 두 함수의 EXECUTE 를 유지한다(V2). **따라서 기존 DEFINER 경유 호출은 이 회수로 끊기지 않는다.** 같은 이유로 간접 경로는 닫히지 않는다 — §5.

### V6b — 회귀

**실행 범위 결정**

| RG | 증거 문서 | §6 재현 절차 | §7 회귀 | 7함수 호출 | 이번 실행 |
|---|---|---|---|---|---|
| `RG-01` | `602010` | fixture `INSERT` 13 · `SET LOCAL ROLE` 13 · `ROLLBACK` 26 | catalog 대조 · 정적 검증 2개 | 0 | 정적 검증 2개 · read-only catalog |
| `RG-02` | `602020` | `INSERT` 5 · `SET LOCAL ROLE` 1 | catalog 대조 | 0 | read-only catalog |
| `RG-03` | `602030` | `INSERT` 4 · `SET LOCAL ROLE` 1 | catalog 대조 | 0 | read-only catalog |
| `RG-04` | `602040` | `INSERT` 4 · `SET LOCAL ROLE` 1 | catalog 대조 | 0 | read-only catalog |
| `RG-05` | `602050` | `INSERT` 2 · `SET LOCAL ROLE` 1 | catalog 대조 | 0 | read-only catalog |

§6 재현은 전부 fixture `INSERT` 와 `SET LOCAL ROLE` 을 쓴다. `ROLLBACK` 되더라도 DB 쓰기이므로 「이 작업의 DB 쓰기는 `0179` 적용 1회뿐」 조건에 따라 **실행하지 않았다 — UNVERIFIABLE.** 대체 근거는 V5(475개 중 두 함수만 ACL 변경) · V6a(호출 구조) 다. 회귀를 새로 만들지 않았다.

**정적 검증 — `602010` §7.4 에 기록된 기존 테스트**

```text
python tools/static_validation/validate_hydration_registry.py
PASS hydration registry validation
  schema:  packages\hydration_registry\hydration_registry.schema.json
  example: packages\hydration_registry\hydration_registry.example.json
exit=0

python tools/static_validation/validate_source_module_map.py
PASS source module map validation
  schema:  packages\source_module_map\source_module_map.schema.json
  example: packages\source_module_map\source_module_map.example.json
exit=0
```

`602010` §7.4 기록과 동일 — delta 0.

**RG gate 구조 read-only 재확인**

```text
assert_caller_tenant_scope 호출 함수              15   (기존 15)
tenant_order_creation_blocked 함수                8   (RG-04 기존 8)
order_number_allocators 사용 함수                 8   (RG-05 기존 8)
uq_orders_store_business_day_number               1   (RG-05)
uq_payment_ledger_provider_approval_identity      1   (RG-02)
assert_caller_tenant_scope proacl                 postgres=X/postgres
```

delta 0.

## §5 닫지 않은 것

```text
간접 경로
  gateway_audit_entry · verify_security_token · record_van_transaction ·
  check_staff_permission → detect_threat → isolate_tenant
  manage_subscription → isolate_tenant
  모든 호출자가 SECURITY DEFINER · owner postgres 이므로 caller 의 EXECUTE 회수는
  이 경로를 끊지 않는다 (V6a)
  현재 막고 있는 것은 p_reason 인자명 불일치 42883 — 601505 §4.1.2 의 "우연한 방벽"
  → CTN-1b · 고치지 않는다

상위 4함수의 PUBLIC · anon · authenticated EXECUTE
  gateway_audit_entry · verify_security_token · record_van_transaction ·
  check_staff_permission 은 여전히 =X 와 authenticated=X 를 가진다 (V4)

isolate_tenant 본문의 caller tenant 검사 부재
  601505 §4.1 — 0090 수정은 0-A-2 소관
  601902 §0.3 — CONTRACT FROZEN · IMPLEMENTATION DEFERRED TO 0-C

cloud 적용 · cloud Exposed schemas 확인
```

## §6 근거 유형

```text
카탈로그 실측   has_function_privilege · aclexplode · pg_proc · pg_auth_members ·
               pg_trigger · cron.job · migration_history
정적 분석       prosrc 문자열 · apply_migrations.py 코드 · 0179 문장 수
runtime 호출   이 문서의 CTN-1a 작업(조사 · 적용 · 검증)에서 7함수 호출은 0회다.
               별도로 602061 250 · 383행에는 isolate_tenant 직접 호출 기록이 있으며,
               절차 위반 finding 으로 등재할 예정이다.
```

## §7 체커 상태

```text
G15   0179 → CONTRACT_NOT_FOUND 예상
      Workpacket: 601513 · 601513* 폴더 없음 · 파일명에 601513 을 가진 ChangeContract 없음
```

Human 승인은 이 문서 §1 에 있고 ChangeContract 는 없다. `0172` ~ `0178` 과 같은 구조적 공백이다(`RG-F2` · `600023` §4). `Workpacket: 601500` 으로 `601505` 를 가리키는 방식은 쓰지 않았다 — `601505` §4.4 가 그 워크패킷 안의 `REVOKE … FROM PUBLIC / GRANT EXECUTE` 를 금지했고 그 Stage 7 은 `대기` 다.

체커가 Runtime Gate · 봉쇄 조치의 Evidence 를 승인 근거로 인식하도록 개선하는 것은 후보로 남긴다.

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | §4.1 · §4.1.1 · §4.1.2 · §4.3 · §4.4 · §4.5 | ACTIVE |
| `601500_Readme_Operational_Authority_Foundation.md` | 142행 — 7함수 정의 | ACTIVE |
| `601902_Register_Stage1_Business_Rules.md` | §0.3 · §5 | ACTIVE — CONTRACT FROZEN |
| `600023_Governance_Runtime_Gate_Spiral.md` | §2 · §4 | ACTIVE |
| `602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md` | §7.4 정적 검증 | ACTIVE |
| `602020` · `602030` · `602040` · `602050` | §6 · §7 절차 조사 | ACTIVE |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §6.11.1 · §14.5 · §46 | ACTIVE |
| `sql/migrations/0179_ctn1a_revoke_isolate_tenant_execute.sql` | 전문 | 적용됨 (local) |
| `tools/apply_migrations.py` | 적용 도구 | — |
| `tools/Check-Governance.ps1` | G15 951~1019행 | — |
