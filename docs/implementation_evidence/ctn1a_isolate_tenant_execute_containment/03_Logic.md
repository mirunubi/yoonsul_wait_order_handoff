# Logic.md — CTN-1a

Change ID: ctn1a_isolate_tenant_execute_containment (Stage 3 확정 — 2026-09-22)
Status: Draft
Draft Status: Verified (Claude) — Stage 6 Contract Review 반영 2026-09-25
Stage: 000701 Stage 2 Design Draft
Written: 2026-09-22

> 구속력 없음. SQL 본문은 쓰지 않는다 (Stage 2 지시). 동작과 기대값만 적는다.
> 적용 전 상태는 prototype 이나 prototype 작업 중 뜬 스냅샷이 아니라 migration 원문에서 도출했다.

## State Model

### S0 — 적용 전 (clean 0178 baseline 에서 기대하는 상태 · migration 원문 도출)

도출 근거:

- `isolate_tenant`: `0090` L1256 생성 → L1448~1451 `revoke all … from public` → L1452~1455 `grant execute … to authenticated`
- `detect_threat`: `0121` L762 생성 → L1545~1549 `grant execute … to authenticated` · PUBLIC revoke 없음
- 이후 두 함수의 ACL · 정의를 바꾸는 migration 없음 (01_ImpactScope 검증 a3)
- `catchmenu_*` schema 에는 default privileges 가 없다 → 생성 시 ACL 은 PostgreSQL 기본값(owner + PUBLIC EXECUTE)

```text
SQL: select pg_get_userbyid(d.defaclrole), n.nspname, d.defaclobjtype, d.defaclacl from pg_default_acl d ...
→ 30 rows. nspname 은 public · storage · cron · extensions · graphql · graphql_public · realtime · supabase_functions · auth 뿐. catchmenu_* 0행
grep -rn -i "alter default privileges" sql/migrations/*.sql → 출력 없음
```

기대 `proacl` (도출값 — **2026-09-23 clean baseline 실측으로 확인**. 도출값과 실측값 일치):

| 함수 | 기대 proacl 구성 | 2026-09-23 clean 실측 |
|---|---|---|
| `isolate_tenant` | `postgres=X/postgres` · `authenticated=X/postgres` | 일치 (postgres · authenticated) |
| `detect_threat` | `=X/postgres`(PUBLIC) · `postgres=X/postgres` · `authenticated=X/postgres` | 일치 (PUBLIC · postgres · authenticated) |

두 함수의 `md5(prosrc)` 도 clean baseline 값과 현재 DB 값이 같다 (HD-CTN-06 실측).

역할별 EXECUTE (S0):

| 역할 | `isolate_tenant` | `detect_threat` | 이유 |
|---|---|---|---|
| PUBLIC | 없음 | **있음** | 0090 L1448 revoke / 0121 revoke 없음 |
| `anon` | f | **t** (PUBLIC 경유) | |
| `authenticated` | **t** | **t** | 명시 grant |
| `service_role` | f | **t** (PUBLIC 경유) | |
| `postgres` (owner) | t | t | owner |
| `authenticator` | f | **t** | clean baseline 실측 (SP-4 · 2026-09-23). `rolinherit=f` |
| `supabase_realtime_admin` | — | — | clean baseline 에 role 부재 — 판정 대상 아님 |

schema USAGE(`catchmenu_common`)는 `authenticated` 만 t 이므로(01_ImpactScope), 실제 이름 해석까지 닿는 client 역할은 S0 에서 `authenticated` 하나다. `anon` · `service_role` 의 `detect_threat` EXECUTE 는 권한상 존재하지만 USAGE 에서 막힌다.

`authenticator` · `supabase_realtime_admin` 는 세 역할의 member 이지만 `rolinherit=f` 다. 이들의 유효 권한은 도출하지 않고 Stage 9 에서 `has_function_privilege` 로 실측한다. 행렬에는 포함한다 (OQ-LG-6 결정).

**Stage 3 정정 (SP-4 실측 · 2026-09-23)**:

- clean baseline 에 없는 role 은 `supabase_functions_admin` · `supabase_realtime_admin` 둘이다. tracked migration 이 만들지 않는다 (`CREATE ROLE` 전수 검색 결과는 `0169` 의 1건뿐). 따라서 replay fidelity 결함이 아니라 **환경 차이**이며, 생성 주체는 미확정이다 → Stage 9 권한 행렬에서 **판정 대상이 아니다**.
- `authenticator` 는 clean baseline 에 존재한다. 실측값: `isolate_tenant` f · `detect_threat` t.
- 앵커가 앞서 "현재 DB 에만 있는 role" 로 적은 추론은 이 실측으로 철회됐다.

### S1 — 적용 후 기대 상태

| 역할 | `isolate_tenant` | `detect_threat` |
|---|---|---|
| PUBLIC | 없음 | 없음 |
| `anon` | f | f |
| `authenticated` | f | f |
| `service_role` | f | f |
| `postgres` (owner) | t | t |
| `authenticator` | f | f (현재 local DB S1 실측) |
| `supabase_realtime_admin` | — | — (clean baseline 에 role 부재 — 판정 대상 아님) |

기대 `proacl`: 두 함수 모두 owner 항목만 남는다.

### 불변 조건 (S0 → S1 에서 바뀌면 안 되는 것)

| # | 대상 | 측정 | 기대 |
|---|---|---|---|
| I-1 | 두 함수 본문 | `md5(prosrc)` 적용 전 · 후 | 같음. 참고로 현재 local DB 값은 `isolate_tenant` `f53ea7f556e89cec883b9ca6b482ca3e` · `detect_threat` `992c78c881be2f23bcac8050b60ad2b7` — clean DB 에서 다시 잰다 |
| I-2 | signature | `oid::regprocedure` | `isolate_tenant(uuid,text,boolean,uuid,text)` · `detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)` |
| I-3 | owner | `pg_get_userbyid(proowner)` | `postgres` |
| I-4 | `prosecdef` | | t |
| I-5 | `proconfig` | | `isolate_tenant` `search_path=catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit` · `detect_threat` `search_path=catchmenu_common` |
| I-6 | 다른 함수 ACL | 아래 측정식 (두 함수 제외 전 함수 ACL 스냅샷) | 함수 수 · md5 모두 같음 |
| I-7 | 상위 호출자 5개 | `proacl` · `md5(prosrc)` · `prosecdef` | 같음 (간접 경로를 건드리지 않았다는 증거). 기준값은 아래 표 |
| I-8 | schema USAGE · role membership | 아래 측정식 | 같음 |
| I-9 | 두 함수 수 | 같은 이름 overload 수 | 각 1 |
| I-10 (신규) | `pg_default_acl` | `catchmenu_*` 스키마에 대한 행 수 | 0 — S0 도출이 default ACL 부재에 기댄다 |
| I-11 (신규) | 관련 role 속성 | I-8 과 같은 role 목록의 `rolsuper` · `rolbypassrls` · `rolinherit` · `rolcanlogin` · `rolcreaterole` · `rolcreatedb` | 같음 |

**Stage 4 정정 (F-3) — I-6 측정식**

| 항목 | 규정 |
|---|---|
| 대상 | `pg_proc` 전체에서 대상 두 함수를 뺀 것 |
| 정렬 | `oid::regprocedure` 텍스트 오름차순 |
| NULL `proacl` | 빈 문자열로 직렬화 |
| 값 | 함수 수 + 직렬화 문자열의 `md5` |

**I-6 의 기준 정의는 04_TestPlan 절차 4 의 쿼리다** (Stage 6 마무리 · 2026-09-25).

- Stage 4 가 참고로 적은 `acl_snapshot_md5=9362a19552986db3d549bf93de87b18e` 는 **다른 직렬화 형식의 값이며 기준값이 아니다.** 함수 수(4039)는 같고 정렬 tiebreaker 때문도 아니다 — 직렬화 문자열 형식이 다르다 (2026-09-25 확인).
- 같은 쿼리로 2026-09-25 현재 DB 를 측정하면 `a92b4a1ac6d1dc790c0a09d304fc0958` 이 나온다 (`function_count=4039`).
- **B5 환경의 기준값은 Stage 8 이 적용 직전에 같은 쿼리로 새로 뜬다.** 위 두 값은 어느 쪽도 B5 기준값이 아니다.

**Stage 4 정정 (F-3) — I-8 측정식**

| 항목 | 규정 |
|---|---|
| 대상 schema | `catchmenu_*` 전체 |
| 대상 role | `anon` · `authenticated` · `service_role` · `postgres` · `authenticator` · `catchmenu_authority_owner` |
| 측정 | `has_schema_privilege(role, schema, 'USAGE')` 행렬 + `pg_auth_members` 양방향 행 (`admin_option` · `inherit_option` · `set_option` · `grantor` 포함) |
| 정렬 · 직렬화 | 아래 실행 기준 참조 |

**I-8 의 실행 기준은 04_TestPlan 절차 4 의 쿼리다** (Stage 6 재재검증 NC-2 · I-6 과 같은 방식).

- USAGE 행렬: `role` · `schema` 오름차순으로 정렬한다.
- membership: `member` · `role` · `admin_option` · `inherit_option` · `set_option` · `grantor` **전 컬럼 오름차순**으로 정렬한다 (같은 `member`/`role` 쌍이 둘 이상 나올 수 있다 — 2026-09-25 현재 DB 에서 `postgres` → `catchmenu_authority_owner` 2행 확인).
- 두 묶음을 각각 직렬화해 이어 붙인 뒤 `md5` 를 뜬다. 정확한 문자열 형식과 구분자는 04_TestPlan 절차 4 의 쿼리가 정의한다.

I-11 의 role 목록도 위와 같다.

I-7 기준값 — clean baseline 실측 (2026-09-23 · HD-CTN-06). 다섯 함수 모두 owner `postgres` · `SECURITY DEFINER`:

| 상위 호출자 | clean ACL | `md5(prosrc)` |
|---|---|---|
| `manage_subscription` | postgres · service_role | `3ceb5089e1c2305628db36e485be9bcd` |
| `verify_security_token` | PUBLIC · postgres · authenticated | `b5c978db183d70e025ff97cc2bd1785f` |
| `gateway_audit_entry` | PUBLIC · postgres · authenticated | `bbfac99ac170a83d988c610435a00732` |
| `record_van_transaction` | PUBLIC · postgres · authenticated | `16aed7926150f2729d578194a3c4412b` |
| `check_staff_permission` | PUBLIC · postgres · authenticated | `297947c8bca176dab515b1f22353cb5b` |

## Input Conditions

- 대상 DB 의 `migration_history` 에 prototype 행이 없다 (아래 "Stage 9 prototype-free 증명")
- 대상 DB 가 S0 와 같다 (proacl 실측이 위 기대 구성과 일치)
- 정규 migration 파일: UTF-8 · BOM 없음 · LF. 이유: `tools/apply_migrations.py` L220 `path.read_text(encoding="utf-8")` 는 BOM 을 벗기지 않고 psql 로 보낸다 · `.gitattributes` L1 `*.sql text eol=lf` · checksum 은 L101 에서 CRLF→LF 정규화
- migration 첫 5줄에 `Workpacket: 603010` (G15 L971 · L979 · Stage 3 IS-2 결정)
- 정규 migration 파일은 `BEGIN … COMMIT` 로 감싼다 (Stage 3 OQ-LG-7 결정 · `0175` · `0178` 선례)

## Output Conditions

- S1 역할 행렬 · 불변 조건 I-1 ~ I-11 충족
- `migration_history` 에 정규 파일 1행 `success=t` · checksum = 파일 SHA-256(LF 정규화). **Stage 4 정정 (F-2)**: B5 환경에서는 이 행을 도구가 아니라 Stage 8 이 별도 `INSERT` 로 남기고, 그 SQL 을 raw log 에 보존한다
- Check-Governance G15: 정규 migration 이 APPROVED ChangeContract 에 연결 (L1004)

## Success Path

1. clean baseline 준비 (Stage 7 확정안 · 앵커 권고는 B5)
2. S0 실측 → 기대 구성과 비교
3. 정규 migration 적용 (Codex, Stage 8)
4. S1 실측 · I-1 ~ I-11 비교
5. raw log 보존 (Evidence Rule)

**Stage 4 정정 (F-2) — B5 환경의 적용 경로**

- `tools/apply_migrations.py` 는 컨테이너 `supabase_db_yoonsul_wait_order_handoff` 로 고정돼 있어(L18~22) B5 disposable 환경을 대상으로 지정할 수 없다.
- 따라서 B5 환경의 `0180` 적용은 B5 replay 와 같은 방식으로 **psql 직접 실행**한다.
- `migration_history` 성공행은 Stage 8 이 별도 `INSERT` 로 남기고, 그 SQL 을 raw log 에 보존한다.
- 도구 수정은 이번 범위 밖이다 (별도 후보).
- 구체 절차 · 명령 · history `INSERT` 문면은 **Stage 5 TestPlan 이 정한다.**

## Failure Path

- `tools/apply_migrations.py` 는 psql `-v ON_ERROR_STOP=1`(L110)로 실행하고, 실패하면 `success=false` 행을 남기고 멈춘다(L226~233).
- `--single-transaction` 은 쓰지 않는다(L106~111). 원자성은 migration 파일 자신의 트랜잭션 경계에 달렸다 → **결정: 정규 migration 파일에 `BEGIN … COMMIT` 필수 (Stage 3 · OQ-LG-7)**.
- S0 실측이 기대와 다르면 적용하지 않고 멈춘다 (baseline 이 clean 이 아니다).

## Timeout Path

해당 동작 없음 (외부 호출 · 비동기 없음). psql 이 끊기면 Unknown State Path.

## Unknown State Path

SQL 실행(L221 `run_psql`)과 history 기록(L224 `record_result`)은 별도 psql 호출이다. SQL 이 성공하고 history 기록이 실패하면 "적용됐으나 기록 없음" 상태가 된다. 이때는 재적용 전에 proacl 을 실측해서 S0 · S1 중 어디인지 판정한다.

## Idempotency Rule

같은 회수를 다시 적용해도 S1 은 그대로여야 한다. 재적용 여부는 도구가 history 로 막는다(L203~206 checksum 일치 시 skip). Stage 5 TestPlan 에서 두 번째 적용 후 행렬이 같음을 확인하는 항목 후보.

## Duplicate Prevention Rule

- 같은 효과의 migration 이 둘이 되지 않게 한다: prototype 은 정규 Stage 9 DB 에 없어야 한다.
- 파일명 번호 충돌: 01_ImpactScope P-3 (M1 · M2). M3(prototype 재사용)는 HD-CTN-03 과 충돌. **결정: M1 — 정규 migration 은 `0180_ctn1a_isolate_tenant_execute_containment.sql` (Stage 3).** `0179` 는 영구히 prototype(철회)으로 남는다.

## Retry Rule

실패 시 원인 확인 후 재시도. checksum 이 이미 기록된 파일을 고치는 경우는 000701 §14.5 Draft 조건 안에서만 · 이전 상태로 DB 를 되돌린 뒤 (L2354 「체크섬만 덮어쓰는 것은 허용되지 않는다」).

## Audit Ledger Rule

두 함수의 audit · ledger 쓰기(`security_audit_log` · `append_audit_record` · `catchmenu_ledger.events`)는 바꾸지 않는다. 이 변경 자체의 감사 흔적은 `catchmenu_meta.migration_history` 한 행이다.

## Evidence Rule

Stage 9 raw log 요구 (Stage 5 에서 확정):

1. baseline 준비 명령과 원출력 (DB 이름 · 생성 시각 · 적용 파일 목록 · 각 파일 SHA-256)
2. prototype-free 증명 출력 (아래)
3. S0 실측 원출력 (`proacl` · `aclexplode` · `has_function_privilege` 행렬)
4. apply 원출력 (`APPLY … OK`)
5. S1 실측 원출력 · I-1 ~ I-9 비교
6. `migration_history` 해당 행 원출력

선례 위치: `docs/implementation_evidence/601700/raw_logs/` (번호 파일 보관).

## RLS / Permission Rule

- 바꾸는 것: 두 함수 EXECUTE 의 PUBLIC · `anon` · `authenticated` 항목만 (HD-CTN-02).
- `service_role` 에 grant 하지 않는다 (HD-CTN-02).
- RLS 는 바꾸지 않는다. owner `postgres` 는 `rolbypassrls=t` 이므로 함수 안에서 RLS 는 원래 작동하지 않았다.

### 간접 경로 — ACL 회수 후에도 남는 것

| 상위 호출자 (DEFINER · owner postgres) | 부르는 대상 | 회수 후 |
|---|---|---|
| `catchmenu_common.manage_subscription` | `isolate_tenant` (`0112` L600 · L616) | 호출은 owner 권한으로 계속 가능. 현재 `p_reason` 때문에 `42883` |
| `catchmenu_common.verify_security_token` | `detect_threat` (`0121` L628 · L662 · L700) | owner 권한으로 계속 호출 |
| `catchmenu_common.gateway_audit_entry` | `detect_threat` (`0121` L971 · L989) | 같음 |
| `catchmenu_payment.record_van_transaction` | `detect_threat` (`0130` L335) | 같음 |
| `catchmenu_store.check_staff_permission` | `detect_threat` (`0131` L462) | 같음 |
| (`detect_threat` 자신) | `isolate_tenant` (`0121` L876) | owner 권한 · 현재 `p_reason` 때문에 `42883` |

DEFINER 함수는 owner 권한으로 실행하므로, 호출자의 EXECUTE 회수는 그 안에서 부르는 함수에 영향을 주지 않는다. 즉 이 변경은 **직접 진입만** 닫는다.

제약: `42883` 방벽(「우연한 방벽」 — `601505` §4.1.1 L331. `p_reason` · `42883` 사실은 §4.1.2 L351~358)은 고치지 않는다. 방벽을 고치면 `isolate_tenant` 간접 호출 3개가 살아난다(`601505` §8A.2 · HD-CTN-02 「간접 경로 복구」 금지). 간접 경로를 닫는 일은 CTN-1b 후보로 남긴다.

## Rollback Rule

- 되돌리기는 회수한 EXECUTE 를 다시 주는 것이다. 되돌리면 S0 로 돌아간다 — `authenticated` 가 두 함수를 직접 부를 수 있고, `detect_threat` 는 PUBLIC EXECUTE 로 돌아간다. 즉 **H03-F1 이 다시 열린다**(`602061` §3.1 사실).
- 불변 경계를 넘은 뒤라면 되돌리기도 새 forward migration 으로만 한다 (000701 §14.5 L2363).
- 되돌리기는 Human 결정 없이 하지 않는다 (OQ-LG-8).

## Edge Cases

| # | 경우 | 처리 |
|---|---|---|
| E-1 | S0 실측이 기대와 다름 (예: `authenticated` 항목 없음) | baseline 오염 의심 → 멈춤 |
| E-2 | 같은 이름 overload 가 생김 | I-9 위반 → 멈춤 |
| E-3 | 현재 local DB(prototype 적용됨)에 정규 migration 을 적용 | REVOKE 는 이미 S1 이라 효과 없음 → **정규 증거가 되지 못한다** (HD-CTN-03) |
| E-4 | untracked prototype 이 `sql/migrations` 에 남은 채 clean DB 에 도구 실행 | L91 이 prototype 을 집어 먼저 적용 → baseline 오염 |
| E-5 | cloud 에 적용 | 이번 범위 밖 — 별도 도구 · 별도 결정 |
| E-6 | 새 파일이 BOM · CRLF | E-4 와 별개로 L220 에서 BOM 이 psql 에 넘어간다 · checksum 은 L101 이 CRLF 만 정규화 |

## Prohibited Behavior

- `catchmenu_*` 함수 호출 (정규 Stage 8 · 9 포함). 권한 확인은 `has_function_privilege` · `aclexplode` 로만
- 두 함수 본문 · signature · `p_reason` · wrapper · 새 authority model · `service_role` grant · 간접 경로 복구 · 0-A-2 / 0-C 재개방 (HD-CTN-02)
- 기존 migration(`0000`~`0178`) 수정
- prototype 을 정규 Stage 8 · 9 증거로 쓰기 (HD-CTN-03)
- 현재 local DB 결과를 clean baseline 결과로 표현하기

## Clean Baseline 선택지 (Stage 7 확정 — HD-CTN-03)

**앵커는 B5 를 권고한다. 확정은 Stage 7 (HD-CTN-03).** 아래 B1 ~ B4 는 판단 경위로 남긴다.

**공통 — 파일 원천**: `git archive HEAD sql/migrations` 로 뽑은 tracked 파일만 쓴다. 저장소에 쓰지 않고, untracked prototype `0179` 는 원천에서 자동으로 빠진다 (OQ-LG-4 결정).

**B1 ~ B4 작성 시점의 공통 전제: 어떤 선택지에서도 `0000`~`0178` replay 가 끝까지 성공하는지는 미검증이었다.** 이 전제는 아래 B5 의 2026-09-23 실측으로 해소됐다. 당시 알려진 사실:

- `604278` §5 L71: 같은 컨테이너 별도 DB replay 가 `0042` 에서 실패
- `CHANGELOG.md` L177: local replay 에서 forward-reference 파일 19개를 임시로 폴더 밖에 옮겨 먼저 나머지를 적용한 뒤 되돌려 재실행해 통과 (Stage 4 정정 F-5 — 아래 B5 표의 19개와 같은 목록)
- `tools/apply_migrations.py` L18~22: container · user · DB 고정 · 옵션 없음 → 다른 DB · 상한 번호를 지정할 수 없다. 도구 수정은 이번 범위 밖 (OQ-LG-3)

| | B1 같은 컨테이너 별도 DB | B2 현재 `postgres` DB 백업 후 재구축 | B3 별도 컨테이너 · stack |
|---|---|---|---|
| 절차 개요 | `sql/migrations` 사본(0179 제외)을 컨테이너에 복사 → `createdb` 새 DB → 파일명 순서로 `0000`~`0178` 적용 | 현재 DB 전체 백업 → DB 초기화 → `0000`~`0178` 적용 | 다른 이름 · 다른 포트의 DB 컨테이너(또는 Supabase stack) → `0000`~`0178` 적용 |
| 선례 | `604278` §4 L57 (단, §5 L71 실패) | 없음 (검색 결과 없음) | 없음 (Stage 1 NOT_FOUND) |
| 위험 | ① `cron.database_name = postgres` (실측) — `0072` L14 · `0135` L228 의 `create extension if not exists pg_cron` 이 다른 DB 에서 실패할 후보(미검증) ② Supabase 전용 schema(`auth` · `storage` 등)가 새 DB 에 없음 — 의존 migration 실패 후보 ③ 도구가 DB 를 못 바꿔 수동 psql 루프 필요 | ① 현재 DB 의 증거 상태(prototype 효과 · 이전 RG 검증 대상)를 잃음 ② 백업 · 복원 실패 시 local 개발 환경 전체 손상 ③ 초기화 방법(Supabase CLI reset 등)은 `sql/migrations` 가 아니라 `supabase/` 기준 — `supabase/` 에는 `config.toml` · `snippets` 만 있음 | ① `supabase/config.toml` L5 `project_id` 와 포트 54321~54329 고정 — host `54321` 은 이미 `supabase_kong_ajumsocks` 가 점유(실측) ② 순수 PostgreSQL 이미지면 Supabase role · schema · extension 부재 ③ 서버 버전 일치 필요 (현재 17.6) |
| prototype 영향 | 새 DB 이므로 history 없음 | 초기화로 history 사라짐 | 새 컨테이너이므로 history 없음 |
| 파일 집합에서 prototype 제외 방법 | 사본에서 제외 또는 tracked 파일만(`git ls-files`) 사용 | 같음 | 같음 |
| 파일 원천 (Stage 3) | `git archive HEAD sql/migrations` (tracked 만 · 저장소 쓰기 없음) | 같음 | 같음 |

보조 선택지 B4: 별도 checkout(git worktree) 을 파일 원천으로 쓰면 untracked prototype 이 자동으로 빠진다. 단 `git worktree add` 는 git write 에 해당할 수 있고 선례가 없다. → **사용 안 함 (Stage 3).** 파일 원천은 `git archive HEAD sql/migrations` 로 한다.

### B5 (Stage 7 승인 대상 · 앵커 권고) — disposable 컨테이너 + CHANGELOG L177 2단계 절차

| 항목 | 내용 |
|---|---|
| 절차 | 1차: 158개(번호순 · `CHANGELOG` L177 이 열거한 19개 제외) → 2차: 그 19개를 L177 열거 순서로. `0073` 은 영구 제외 |
| 파일 원천 | `git archive HEAD sql/migrations` (tracked 만) |
| 실측 | 2026-09-23 두 차례 실행 모두 **177/177 성공 · `0178` 도달** — 절차의 재현성 확인 (HD-CTN-06) |
| 반례 | 순수 번호순 재생은 `0093` 에서 `23514` 로 실패한다. `0093` 이 뒤 번호 `0140` 의 제약 확장을 전제하기 때문이다 |
| role parity | 적용 후 role 30개. `catchmenu_authority_owner` 는 `0169`(17행)가 생성한다. 현재 DB 와 속성 6개 · 멤버십 양방향 2행 모두 일치 (SP-4 · 2026-09-23) |
| prototype | 새로 만든 DB 이므로 `migration_history` 에 prototype 행이 없다 |
| manifest (Stage 4 · F-6) | `8958ad051cfdff3f7b030e14b504e28b5c0dbf8fe8317d5250007d7bb3a6e389` |

**manifest 산출 방식 (Stage 6 F-1 · 조사 2026-09-25 로 확정)**

```text
manifest SHA-256 = 8958ad051cfdff3f7b030e14b504e28b5c0dbf8fe8317d5250007d7bb3a6e389
manifest 바이트 수 = 18321
```

1. `git archive HEAD sql/migrations` 에서 `^\d{4}_.+\.sql$` 에 맞는 **177개**를 basename 오름차순으로 정렬한다.
2. 각 파일의 바이트에서 CRLF 를 LF 로 바꾼 뒤 SHA-256 을 lowercase hex 로 계산한다 (`tools/apply_migrations.py` L100~102 와 같은 정규화).
3. 파일마다 한 줄을 만든다: `<basename>` + ASCII SPACE(`0x20`) + `<lowercase hex>`.
4. 177개 줄을 LF(`0x0A`) 하나로 연결한다. **마지막 줄 뒤에는 LF 를 붙이지 않는다.**
5. 그 manifest 바이트 전체의 SHA-256 이 위 값이다.

예 (첫 줄 · 마지막 줄):

```text
0000_create_migration_history_table.sql 9129ec09b3ce8b8ab37510f6ea540f07cf70f47791ca73917e6af32bca40fd28
0178_order_request_identity_and_numbering.sql aeb82b5550b7d88c4d4a01195d2d2fe192df8c8b0044ffb95335478a173c609d
```

> **Stage 6 정정 (F-1)**: 이전 문면은 파일명을 정렬 기준으로만 적고 manifest **내용**에 포함한다고 적지 않았다. 그 문면대로 계산하면 `d85cff6d7543092c69f81b66c2fba1f84bdb5d49300af94861eee75091c60c68` 이 나온다. 기대값 자체는 맞았고 설명이 부족했다 (조사 2026-09-25).

앵커는 Stage 9 환경을 이 B5 절차로 만들 것을 권고한다. 확정은 Stage 7 (HD-CTN-03). prototype-free 증명은 아래 V-1 ~ V-6 을 따른다.

## Prototype 처분 선택지 (Stage 7 확정 — HD-CTN-03)

처분 대상: `0179_ctn1a_revoke_isolate_tenant_execute.sql` · `601513_…Revocation.md` · `000005` 601513 행 · `601500_Readme` L104 601513 행.

| | D1 `sql/_excluded_from_local_replay/` 로 이동 | D2 문서 폴더에 보존 (예: 이 `implementation_evidence/<id>/` 아래) | D3 삭제 |
|---|---|---|---|
| 선례 | `0073` (`CHANGELOG.md` L167~181 · commit `525c3ac`) | 없음 | 없음 |
| CHANGELOG | 기록 필요 (0073 선례 형식) | 기록 권고 (history 행 설명) | 기록 필요 (history 행이 가리키는 파일이 사라짐) |
| migration_history | 현재 local DB 에 `success=t` 행이 남는다 — 0073(`success=f`)과 달리 **성공 행**. clean DB 에는 없음 | 같음 | 같음 |
| G15 | `sql/migrations` 밖 → 검사 대상에서 빠짐. 현재 0179 의 G15 WARN(`CONTRACT_NOT_FOUND`, Workpacket 601513) 해소 | 같음 | 같음 |
| `apply_migrations.py` | 대상에서 빠짐 (L91) | 같음 | 같음 |
| 기타 | 폴더 이름이 "local replay 제외" 뜻 — prototype 성격과 맞는지 | `.sql` 이 docs 에 들어감 | untracked 파일이라 git 에 원문이 없다 → 영구 삭제 · 복구 불가 |

현재 local DB 의 prototype 효과 · history 행 처분은 별도 결정이다: 그대로 둠 / 601034 선례(L29)처럼 이전 상태로 되돌리고 history 행 제거. 어느 쪽이든 현재 local DB 는 정규 Stage 9 에 쓰지 않는다.

`601513` · 색인 2행: 정규 문서로 승격하지 않는다(HD-CTN-03). 보존 · 색인 행 제거 · 이동 중 하나를 Stage 7 에서 정한다 (OQ-LG-9).

## Prototype `0179` 의 Draft 여부 — 000701 §14.5 네 조건 (L2349~2352)

| # | 조건 | 사실 | 근거 | 판정 |
|---|---|---|---|---|
| 1 | 워크패킷이 Stage 12 를 통과하지 않았다 | CTN-1a 는 Stage 2. prototype 이 머리에 적은 `Workpacket: 601513` 은 ChangeContract 가 없다 | 이 문서 · G15 `CONTRACT_NOT_FOUND` (Check-Governance 출력 `[WARN] sql/migrations/0179_…`) | 충족 |
| 2 | 보호 브랜치(`main`)에 없다 | untracked (`?? sql/migrations/0179_…`) | `git status --short` | 충족 |
| 3 | 어떤 공유 환경에도 적용된 적이 없다 | local 컨테이너에 적용됨. 사실은 아래 표 | 아래 · `601034` L29 선례 | **충족 (Stage 3 결정: 공유 환경 아님)** |
| 4 | 다른 워크패킷이 현재 체크섬 · 동작에 의존하지 않는다 | prototype 을 이름으로 참조하는 파일은 `000005` · `601500_Readme` · `601513` · prototype 자신 · 이 폴더뿐. 참조하는 migration 없음. 별개 사실: RG-06 `602061` L577 은 「새 migration 1개 … 다음 순번은 `0179` 이나 이 문서에서 확정하지 않는다」, `602060` L444 는 「`0179` 이후 없음 (실측)」이라고 적었다 — prototype 에 대한 의존이 아니라 **번호 배정이 겹칠 후보** | `grep -rln -i "0179_ctn1a\|ctn1a\|601513\|CTN-1a\|CTN-1b" docs sql tools` · `602061` L577 · `602060` L444 | 충족 (번호 겹침은 OQ-LG-11) |

### 조건 3 — 사실만

**Stage 4 정정 (Cursor 5)**: 이전 초안은 이 판정의 근거에 `602061` HD-4(비권위 자료)를 인용했다. 뺐다. 근거는 아래 실측 사실과 `601034` L29 선례뿐이다.

| 항목 | 사실 | 근거 |
|---|---|---|
| 컨테이너 | `supabase_db_yoonsul_wait_order_handoff` · `Up 3 days` · 포트 `0.0.0.0:54322->5432` (모든 인터페이스에 바인딩) | `docker ps` 원출력 |
| 같은 호스트의 다른 컨테이너 | `supabase_*_ajumsocks` stack 13개 · `bjstock-postgres` — 다른 프로젝트, 별도 컨테이너 | `docker ps` 원출력 |
| 이 프로젝트의 API stack | 떠 있지 않음 (DB 컨테이너만) | `docker ps` |
| 누가 접속했나 (기록상) | 이 Claude Code 세션 (prototype 적용 · read-only 조회) · Stage 1 Codex (read-only, `transaction_read_only=on` — `00_CodexScan.md`) · `migration_history.applied_by` 는 전 행 `postgres` | 00_CodexScan "DB 환경" · history 원출력 |
| 조회 시점 접속 | client backend 1개 (이 조회 자신) | `pg_stat_activity` 원출력 |
| 포트 노출 | 이 프로젝트의 API stack 은 떠 있지 않고, host `54321` 은 다른 프로젝트가 점유한다 (위 행) | `docker ps` 원출력 |
| cloud 와의 관계 | cloud `upzthfwhtvazfftxnyfu` 는 별도 DB · 별도 도구(`tools/apply_migrations_cloud.py`)로 적용. 이 세션은 cloud 도구를 실행하지 않았다(세션 기록 — 저장소 증거 아님). cloud `migration_history` 는 조회하지 않았다 | `000000` L16 · `600301` L7 |
| DB 안 데이터베이스 | `_supabase` · `postgres` · `storage_vectors` · `template0` · `template1` — 별도 검증 DB 없음 | `pg_database` 원출력 |
| 선례 | `601034` L29: `0166` 을 local DB 에 적용한 뒤 「has not been propagated to a shared environment」로 적고 Draft 로 취급 → local DB 를 이전 상태로 되돌리고 history 행을 지운 뒤 재적용 | `601034` L29 |

### 판정 결과에 따라 달라지는 것

**Stage 3 결정: 공유 환경이 아니다 → prototype `0179` 는 `000701` §14.5 의 Draft 다** (`601034` L29 선례). 따라서 아래 표의 첫 행이 적용된다. 둘째 행은 판단 경위로 남긴다.

**Stage 4 명시 (Cursor 3 · 앵커 판단)**: §14.5 네 조건 판정(Draft 여부)과 처분(이동 · 보존 · 삭제)은 다른 결정이다. Draft 판정은 Stage 3, 처분은 Stage 7 (HD-CTN-03).

| 조건 3 결과 | prototype 파일 | 현재 local DB | clean baseline |
|---|---|---|---|
| 공유 환경 **아님** → 네 조건 충족 → Draft | 수정 · 이동 · 삭제 가능 (D1 · D2 · D3 모두 열림). 601034 선례처럼 local DB 를 이전 상태로 되돌리는 것도 열림 | 되돌려서 B2 형태로 쓸 수도 있음 (단 HD-CTN-03 은 "clean baseline(0178 까지)"를 요구) | B1 · B2 · B3 모두 가능 |
| 공유 환경 **맞음** → 불변 경계(L2360) → 영구 불변 | 파일 수정 · 삭제 불가 (L2356~2363). `601500_Readme` L33 「파일 직접 수정·삭제 금지」는 그 행의 주어가 `0168`/`0169` 이므로 일반 불변 선례로 쓰지 않는다 (Stage 4 정정 · Cursor 5). D1 이동도 "수정"에 해당하는지 판단 필요. 정정은 새 forward migration 으로만 | 되돌리기 불가 → 현재 DB 는 prototype 을 계속 품음 | prototype 파일이 `sql/migrations` 에 남으면 도구가 매번 집는다 → clean 0178 을 만들려면 파일 집합에서 빼야 하는데, 이것이 불변 규칙과 부딪힌다 (OQ-LG-2) · 정규 migration 번호는 M1(`0180`) 쪽으로 기움 |

## Stage 9 환경이 prototype history 없는 DB 임을 증명하는 방법 (후보)

Stage 9 환경은 앵커가 권고하는 **B5 절차**로 만든다 (확정은 Stage 7 · HD-CTN-03).

**Stage 4 정정 (F-1)**: 이전 초안의 V-3(`max(filename)`) · V-6(`min(applied_at)`)은 B5 환경에서 `migration_history` 가 비어 있어 NULL 이 되므로 성립하지 않는다. 아래로 대체한다.

| # | 증거 | 기대 |
|---|---|---|
| V-1 | `migration_history` 에서 prototype 파일명 행 수 | 0 |
| V-2 | `migration_history` 에서 checksum `73c2e6b1ea5a2bfaa79b5a6929bff3ae345706c2a579b076102edee44a99a39c` 행 수 | 0 |
| V-3 (대체) | `migration_history` 에서 prototype 파일명 행 0건 — V-1 과 함께 본다. history 가 비어 있어도 참이다 | 0 |
| V-4 | `0180` 적용 직전 S0 proacl 실측 | S0 기대 구성과 일치 (`authenticated` 항목 존재 · `detect_threat` PUBLIC 항목 존재) — **가장 강한 증거** (회수가 아직 없었다) |
| V-5 | baseline 에 쓴 파일 목록과 SHA-256 · manifest | prototype checksum 없음 · 목록 = tracked `0000`~`0178` |
| V-6 (대체) | `0180` 적용 **직전** S0 ACL 실측이 S0 기대 구성과 일치 | prototype 회수가 아직 없었다는 직접 증거 |

B5 환경은 새 DB 이므로 V-1 · V-2 · V-3 이 참이다. V-4 · V-6 은 적용 직전 실측으로 확인한다. V-5 는 파일 목록과 manifest 로 확인한다.

## Open Questions For Claude

- OQ-LG-1 local dev 컨테이너(`supabase_db_yoonsul_wait_order_handoff`)가 000701 §14.5 의 "공유 환경"인가. 사실은 위 표. `601034` L29 선례를 이번에도 적용할 수 있는가. — **결정: 공유 환경 아님 → prototype `0179` 는 §14.5 Draft (Stage 3 · `601034` L29 선례).** 해소 (HD-CTN-06 · 2026-09-23 실측)
- OQ-LG-2 조건 3 이 "공유 환경"으로 판정되면, 불변 파일을 `sql/migrations` 밖으로 옮기는 것이 허용되는가 (0073 은 실패 파일 · 이번은 성공 적용 파일). — **결정: 해당 없음 (Stage 3 · OQ-LG-1 결과)**
- OQ-LG-3 `tools/apply_migrations.py` 에 DB · 상한 지정이 없다. clean baseline 에 수동 psql 루프를 쓸 것인가, 도구 수정을 별도 변경으로 둘 것인가. — **결정: 도구 수정은 범위 밖. baseline 은 수동 psql (Stage 3)**
- OQ-LG-4 B4(별도 checkout)가 git write 제약 · 선례 없음과 어떻게 맞는가. — **결정: worktree 사용 안 함. tracked 파일 원천은 `git archive HEAD sql/migrations` (Stage 3)**
- OQ-LG-5 B1 에서 `pg_cron`(`cron.database_name = postgres`) · Supabase 전용 schema 의존 migration 이 실제로 실패하는지 — Stage 4 이전에 read-only 로 확인할 수 없는 항목. 시험 replay 를 누가 · 언제 할 것인가. — **해소 (HD-CTN-06 · 2026-09-23 실측).** B5 절차로 두 차례 177/177 성공
- OQ-LG-6 `authenticator` · `supabase_realtime_admin` (member · `rolinherit=f`) 의 유효 권한을 S0 · S1 행렬에 넣을 것인가. — **결정: 행렬에 포함하고 Stage 9 에서 실측 (Stage 3).** 단 `supabase_realtime_admin` 은 clean baseline 에 없다 (SP-4 정정) → 판정 대상이 아니다
- OQ-LG-7 정규 migration 의 트랜잭션 경계 요구 (도구는 `--single-transaction` 을 쓰지 않음). — **결정: `BEGIN … COMMIT` 필수 (Stage 3 · `0175` · `0178` 선례)**
- OQ-LG-8 Rollback 을 Human 결정 없이 금지로 적는 것이 맞는가. — **결정: 유지 — Human 결정 없는 rollback 금지 (Stage 3)**
- OQ-LG-9 `601513` · 색인 2행의 처분. — **결정: Stage 7 에서 baseline 방식과 함께 확정 (Stage 3)**
- OQ-LG-10 현재 local DB 의 prototype 효과를 되돌릴 것인가 (되돌리면 H03-F1 직접 경로가 local 에서 다시 열린다). — **결정: Stage 7 에서 baseline 방식과 함께 확정 (Stage 3)**
- OQ-LG-11 RG-06(H03-F2) 도 새 migration 을 낼 수 있다 (`602061` L577 은 H03-F1 용 「다음 순번은 `0179`」를 미확정으로 적음). CTN-1a 와 RG-06 의 번호 배정 순서를 누가 정하는가. — **결정: IS-3 으로 정리 (Stage 3).** CTN-1a 는 `0180`, RG-06 은 Stage 7 승인 순서에 따라 그 다음 번호. 해소 (HD-CTN-06 · 2026-09-23 실측 포함)

## Draft Status

Verified (Claude) — Stage 6 Contract Review 반영 2026-09-25

## Stage 3 Review (Claude 앵커)

Stage 3 검토 · 결정은 2026-09-22. 본문에 반영된 HD-CTN-06 · SP-4 실측은 그 결정에서 지시한 후속 실측이며 2026-09-23 에 수행됐다.

이 절은 **앵커 판단**이다. Human 결정이 아니다 (Human 결정은 02_Overview "Human Decision" 절).

| 항목 | 결정 | 근거 | 반영 위치 |
|---|---|---|---|
| OQ-LG-1 | 공유 환경 아님 → prototype `0179` 는 §14.5 Draft | `601034` L29 선례 | §14.5 네 조건 표 · 「판정 결과에 따라 달라지는 것」 |
| OQ-LG-2 | 해당 없음 | OQ-LG-1 결과 | OQ 목록 |
| OQ-LG-3 | 도구 수정 범위 밖 · baseline 은 수동 psql | `apply_migrations.py` L18~22 | Clean Baseline 절 · OQ 목록 |
| OQ-LG-4 | worktree 사용 안 함 · 원천은 `git archive HEAD sql/migrations` | 저장소 쓰기 없음 | Clean Baseline 공통 행 · B4 |
| OQ-LG-5 | 해소 — B5 실측 (B5 자체의 확정은 Stage 7) | HD-CTN-06 (2026-09-23) | B5 절 |
| OQ-LG-6 | 행렬에 포함 · Stage 9 실측 (SP-4 정정 반영) | SP-4 (2026-09-23) | S0 절 주석 |
| OQ-LG-7 | `BEGIN … COMMIT` 필수 | `0175` · `0178` 선례 | Input Conditions · Failure Path |
| OQ-LG-8 | Human 결정 없는 rollback 금지 — 유지 | — | Rollback Rule |
| OQ-LG-9 · LG-10 | Stage 7 에서 baseline 방식과 함께 확정 | HD-CTN-03 | Prototype 처분 절 |
| OQ-LG-11 | IS-3 으로 정리 — CTN-1a 는 `0180` | 01_ImpactScope P-3 | Duplicate Prevention Rule |
| clean baseline | **앵커는 B5 를 권고한다. 확정은 Stage 7 (HD-CTN-03)** — disposable 컨테이너 + `CHANGELOG` L177 2단계 절차 | 2026-09-23 두 차례 177/177 | Clean Baseline B5 절 |
| SP-4 정정 | 앵커가 앞서 "현재 DB 에만 있는 role" 로 적은 추론은 실측(SP-4, 2026-09-23)으로 철회됐다 | SP-4 실측 | S0 절 「Stage 3 정정」 |

### 2026-09-23 실측으로 PASS 한 것

```text
committed migration 0000 ~ 0178 의 replay 재현성
  (disposable 컨테이너 + CHANGELOG L177 2단계 절차 · 두 차례 177/177)
clean baseline 의 S0 ACL 이 03_Logic 도출값과 일치
clean baseline 의 role parity (catchmenu_authority_owner 는 0169 가 생성)
```

### 아직 PASS 하지 않은 것

```text
CTN-1a 최종 설계 (Stage 4 · 6 검증 전)
TestPlan · ChangeContract (Stage 5)
Human Boundary Approval (Stage 7)
정규 migration 0180 (Stage 8)
Stage 9 독립 검증 · Stage 11 감사
```

"clean baseline PASS" 를 "CTN-1a 가 PASS 했다" 로 읽지 않는다.

## Stage 4 Architecture Review 반영 (2026-09-25)

이 절은 **앵커 판단**이다. Human 결정이 아니다. Stage 4 검증은 Codex(문서↔실제) F-1 ~ F-7 · Cursor(문서↔문서 · 정책) 1 ~ 6 이며, 앵커가 전건 수용했다. 전체 목록은 01_ImpactScope "Stage 4 Architecture Review (2026-09-25)" 절에 있다.

이 문서에서 바뀐 것:

| 발견 | 바뀐 곳 |
|---|---|
| F-1 | prototype-free 증명 V-3 · V-6 을 대체했다 (B5 환경은 history 가 비어 NULL 이 되므로 이전 식이 성립하지 않는다). V-4 를 "가장 강한 증거"로 표시하고, "V-1 ~ V-6 자동 성립" 문장을 항목별 확인 방식으로 바꿨다 |
| F-2 | B5 환경의 `0180` 적용 경로를 명시했다 — 도구는 컨테이너 고정(L18~22)이라 쓸 수 없고, psql 직접 실행 · history 행은 Stage 8 이 별도 `INSERT` · 구체 절차는 Stage 5 TestPlan |
| F-3 | I-6 · I-8 측정식을 못박고 I-10(`pg_default_acl` 0건) · I-11(role 속성 보존)을 추가했다. I-6 참고값은 현재 DB 기준이며 B5 기준값은 Stage 8 직전에 새로 뜬다 |
| F-4 | S0 · S1 역할 행렬에 `authenticator` 행을 넣었다 (`supabase_realtime_admin` 은 clean 부재 — 판정 대상 아님 유지) |
| F-5 | `CHANGELOG` L177 목록 수를 18개 → 19개로 정정했다 |
| F-6 | B5 절에 manifest SHA-256 과 산출 방식을 보존했다 |
| Cursor 1 | 「우연한 방벽」 출처를 §4.1.2 L351~367 → §4.1.1 L331 로 정정했다 (`p_reason` · `42883` 사실은 §4.1.2 L351~358) |
| Cursor 2 | B5 의 지위를 "확정" → "Stage 7 승인 대상 · 앵커 권고"로 낮췄다 |
| Cursor 3 | Draft 판정(Stage 3)과 처분(Stage 7)이 다른 결정임을 명시했다 |
| Cursor 5 | §14.5 조건 3 근거에서 `602061` HD-4(비권위) 인용을 뺐다. `601500_Readme` L33 은 주어가 `0168`/`0169` 이므로 일반 불변 선례로 쓰지 않는다고 적었다 |

## Stage 6 Contract Review 반영 (2026-09-25)

이 절은 **앵커 판단**이다. Human 결정이 아니다.

| 발견 | 처분 | 이 문서에서 바뀐 곳 |
|---|---|---|
| F-1 manifest 산출 방식 | **해소 (2026-09-25)** | B5 절의 manifest 문단을 5단계 산출 방식 · 바이트 수 18321 · 첫/마지막 줄 예시 · 오산출 값(`d85cff6d…`) 정정 주로 대체 |
| Cursor 2 (F-11 과 함께) | 이미 반영 | B5 는 "Stage 7 승인 대상 · 앵커 권고" — 확정은 Stage 7 |
