# TestPlan.md — CTN-1a

## Change ID

`ctn1a_isolate_tenant_execute_containment`

Workpacket: 603010 (Stage 3 결정 · `603000` · `603010` 폴더 생성은 **Stage 10** — Stage 6 처분 F-13)
Status: Draft
Draft Status: Draft (Claude Code)
Stage: 000701 Stage 5 Contract Drafting
Lifecycle: TestPlan
Gate Classification: CTN-1a Containment Test Plan Draft
Runtime Implementation Authorization: Not Granted
Owner: 정영석
Last Updated: 2026-09-25

> 이 문서는 구현을 승인하지 않는다 (`000001` §5.4.4). Stage 6 이 검증하고 Stage 7 에서 Human 이 승인한다.
> 근거 설계는 01_ImpactScope · 02_Overview · 03_Logic (Stage 4 반영본)이다. prototype `0179` · `601513` 은 쓰지 않는다.

## Purpose

`catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` 와 `catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)` 의 EXECUTE 를 `PUBLIC` · `anon` · `authenticated` 에서 회수하는 변경이, **그것만** 바꿨다는 것을 clean baseline 위에서 증명한다.

## Test Scope

| 포함 | 제외 |
|---|---|
| 두 함수의 EXECUTE ACL (역할별 행렬) | 두 함수의 본문 · signature · `p_reason` |
| 불변 조건 I-1 ~ I-11 (03_Logic) | 간접 경로 차단 (CTN-1b) |
| migration 파일 형식 · checksum · history 행 | cloud (`upzthfwhtvazfftxnyfu`) |
| 허용 파일 밖 변경 0건 | RLS 정책 |
| Rollback 의 의미 (문서로만) | 실제 rollback 실행 |

## Preconditions

| # | 조건 | 확인 방법 |
|---|---|---|
| P-1 | Stage 7 Human Approval 완료 | 05_ChangeContract 의 Human Boundary Approval 절 |
| P-2 | 대상 환경은 B5 disposable 환경 (03_Logic). **현재 local DB 에 적용하지 않는다** | 아래 §실행 절차 1 |
| P-3 | 파일 원천은 `git archive HEAD sql/migrations` (tracked 만) | 절차 2 · manifest 대조 |
| P-4 | `0180` 파일은 UTF-8 · BOM 없음 · LF · `BEGIN … COMMIT` · 머리 5행 안에 `-- Workpacket: 603010` | 아래 Migration / Schema Tests |
| P-5 | `catchmenu_*` 함수 호출 금지 (`601505` §4.1.1 L311~314) — 검증은 카탈로그 · 권한 함수로만 | 본 문서 전체 |

## B5 환경 실행 절차 (F-2 해소 · Stage 8 · Stage 9 공통)

기준 사실:

- `tools/apply_migrations.py` 는 컨테이너 · user · DB 가 상수로 고정돼 있다 — `DB_CONTAINER = "supabase_db_yoonsul_wait_order_handoff"` (L20) · `DB_USER = "postgres"` (L21) · `DB_NAME = "postgres"` (L22) · `MIGRATIONS_DIR = ROOT / "sql" / "migrations"` (L19). CLI 옵션이 없으므로 **B5 환경을 대상으로 지정할 수 없다.** 따라서 아래 절차는 psql 을 직접 쓴다.
- 현재 컨테이너 이미지 (read-only 조회):

```text
docker inspect --format '{{.Config.Image}} | {{.Image}}' supabase_db_yoonsul_wait_order_handoff
public.ecr.aws/supabase/postgres:17.6.1.156 | sha256:ca7871b587ca2c401ac0f325df6249c9aa0d25647ded34631158efc51176767f
```

### 1. disposable 컨테이너 생성 — Stage 8 (Codex) · Stage 9 는 자기 환경을 새로 만든다

```bash
docker run -d \
  --name ctn1a_stage<N>_<YYYYMMDD> \
  --label ctn1a_disposable=true \
  --label change_id=ctn1a_isolate_tenant_execute_containment \
  -e POSTGRES_PASSWORD=<임시값> \
  public.ecr.aws/supabase/postgres@sha256:ca7871b587ca2c401ac0f325df6249c9aa0d25647ded34631158efc51176767f
```

- 포트를 바인딩하지 않는다 (`-p` 없음). network 를 지정하지 않는다 (`--network` 없음).
- 이름은 현재 컨테이너(`supabase_db_yoonsul_wait_order_handoff`)와 달라야 한다.

**health 대기와 판정 (Stage 6 처분 F-2)** — 준비되기 전에 psql 을 쏘면 `replay` 가 엉뚱한 지점에서 실패한다.

```bash
# 1) health 상태를 최대 120초까지 기다린다
s=""
for i in $(seq 1 60); do
  s=$(docker inspect --format '{{.State.Health.Status}}' ctn1a_stage<N>_<YYYYMMDD> 2>/dev/null)
  [ "$s" = "healthy" ] && break
  sleep 2
done
docker inspect --format '{{.State.Status}} {{.State.Health.Status}}' ctn1a_stage<N>_<YYYYMMDD>

# fail-closed: 120초 안에 healthy 가 아니면 여기서 멈춘다 (Stage 6 재검증 N-2)
[ "$s" = "healthy" ] || { echo "HEALTH_TIMEOUT"; exit 1; }

# 2) 서버가 실제로 접속을 받는지 판정한다 (health 가 없는 이미지 대비)
docker exec -i ctn1a_stage<N>_<YYYYMMDD> pg_isready -U postgres -d postgres
docker exec -i ctn1a_stage<N>_<YYYYMMDD> psql -X -At -U postgres -d postgres -c "select 1"
```

- 판정: `pg_isready` 가 `accepting connections` · `select 1` 이 `1` 을 돌려주면 다음 단계로 간다.
- **실패 조건**: 이름 충돌 · 이미지 digest 불일치 · 120초 안에 `healthy` 가 되지 않음 · `pg_isready` 실패 → 멈추고 보고.
- **기준 기록 (앵커 처분 TP-1 · 2026-09-25)**: HD-CTN-05 · 06 실측은 조사용이라 raw log 를 저장소에 남기지 않았다. Stage 8 의 이 실행이 최초 기준 기록이며, 명령과 출력을 `raw_logs/stage8/01_container_create.log` 에 그대로 남긴다 (Stage 9 는 `raw_logs/stage9/01_container_create.log`).

### 2. 파일 원천과 manifest — Stage 8 · Stage 9

```bash
git archive HEAD sql/migrations | tar -x -C <임시폴더 · 저장소 밖>
```

- 대상 파일: `^\d{4}_.+\.sql$` (`CHANGELOG.md` · `seed_yoonsul_menu.sql` 제외)
- 기대 파일 수 **177** (`0000`~`0178` 중 `0073` 없음 · `0128` 번호 공백 · untracked `0179` 는 tracked 가 아니므로 포함되지 않는다)

**manifest 산출과 검산 (Stage 6 F-1 · 조사 2026-09-25 로 확정 · 산출 방식 원본은 03_Logic B5 절)**

| 기대값 | 값 |
|---|---|
| manifest SHA-256 | `8958ad051cfdff3f7b030e14b504e28b5c0dbf8fe8317d5250007d7bb3a6e389` |
| manifest 바이트 수 | **18321** |
| 파일 수 | **177** |

산출 규칙: basename 오름차순 정렬 → 각 파일 바이트의 CRLF 를 LF 로 바꾼 뒤 SHA-256 lowercase hex → 줄마다 `<basename>` + SPACE(`0x20`) + `<hex>` → 177줄을 LF(`0x0A`)로 연결하되 **마지막 줄 뒤에는 LF 를 붙이지 않는다** → 그 바이트 전체의 SHA-256.

Stage 8 이 그대로 실행할 검산 (POSIX 셸 — 이 저장소 환경에서는 Git Bash. 2026-09-25 에 이 블록 그대로 실행해 아래 다섯 값이 재현됨을 확인했다):

```bash
cd <임시폴더>/sql/migrations
# 1) manifest 를 만든다 (저장소 밖에서)
for f in $(ls | grep -E '^[0-9]{4}_.+\.sql$' | LC_ALL=C sort); do
  h=$(sed 's/\r$//' "$f" | sha256sum | cut -d' ' -f1)
  printf '%s %s\n' "$f" "$h"
done | head -c -1 > ../../manifest.txt      # 마지막 LF 를 뺀다

# 2) 세 값을 확인한다
ls | grep -cE '^[0-9]{4}_.+\.sql$'          # 177
wc -c < ../../manifest.txt                  # 18321
sha256sum ../../manifest.txt                # 8958ad05…a6e389
head -1 ../../manifest.txt                  # 0000_create_migration_history_table.sql 9129ec09…40fd28
tail -1 ../../manifest.txt                  # 0178_order_request_identity_and_numbering.sql aeb82b55…3c609d
```

- **실패 조건**: manifest SHA-256 불일치 · 바이트 수 ≠ 18321 · 파일 수 ≠ 177 · `0179` 가 섞임 → **멈춘다** (HEAD 가 바뀌었거나 원천이 오염됐다)
- 참고: 파일명을 manifest 내용에 넣지 않고 hex 만 이어 붙이면 `d85cff6d…c60c68` 이 나온다. 이 값이 나오면 **산출 방식을 잘못 쓴 것**이지 원천 오염이 아니다 (Stage 6 F-1).

```bash
docker cp <임시폴더>/sql/migrations/. ctn1a_stage<N>_<YYYYMMDD>:/tmp/ctn1a_migrations/
```

### 3. B5 2단계 replay — Stage 8 · Stage 9

`CHANGELOG.md` L177 이 기록한 순서다. `0073` 은 영구 제외(`sql/_excluded_from_local_replay/` · `CHANGELOG` L167~181).

| 단계 | 대상 | 순서 |
|---|---|---|
| 1차 | 158개 — 아래 19개를 뺀 나머지 | 파일명 번호순 |
| 2차 | 19개 — `0093` · `0100` · `0107` · `0108` · `0110` · `0113` · `0114` · `0118` · `0119` · `0121` · `0122` · `0123` · `0126` · `0127` · `0131` · `0132` · `0133` · `0134` · `0135` | `CHANGELOG` L177 열거 순서 |

```bash
docker exec -i ctn1a_stage<N>_<YYYYMMDD> \
  psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres -f /tmp/ctn1a_migrations/<file>
```

- 순수 번호순 재생은 `0093` 에서 `23514` 로 실패한다 (2026-09-23 실측 · `F-REPLAY`). 2단계 절차가 필요한 이유다.
- 기대: **177/177 성공**
- **실패 조건**: 한 파일이라도 실패 → 멈추고 그 파일명 · 오류 원문 전체를 보고. 파일을 고치거나 건너뛰지 않는다.

### 4. 적용 직전 기준값 채집 (S0 · V-4 · V-6 · I-6 · I-8 · I-10 · I-11) — Stage 8 이 채집, Stage 9 가 독립 재채집

`0180` 을 적용하기 **전에** 아래를 뜨고 raw log 에 남긴다. 모두 read-only 조회다.

```sql
-- S0 ACL (V-4 · V-6)
SELECT p.oid::regprocedure::text AS f, pg_get_userbyid(p.proowner) AS owner,
       p.prosecdef, p.proconfig, md5(p.prosrc) AS src_md5, p.proacl::text
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'catchmenu_common' AND p.proname IN ('isolate_tenant','detect_threat')
ORDER BY 1;

-- 역할별 EXECUTE 행렬
SELECT r.rolname, has_function_privilege(r.rolname, p.oid, 'EXECUTE') AS can_execute,
       p.oid::regprocedure::text AS f
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
CROSS JOIN (SELECT rolname FROM pg_roles
            WHERE rolname IN ('anon','authenticated','service_role','postgres',
                              'authenticator','catchmenu_authority_owner')) r
WHERE n.nspname = 'catchmenu_common' AND p.proname IN ('isolate_tenant','detect_threat')
ORDER BY 3, 1;

-- I-6 (대상 두 함수 제외 전 함수 ACL 스냅샷)
-- 정렬키 보강 (Stage 6 재검증 N-1): 직렬화 내용은 그대로 두고, 동률 시 순서가 흔들리지 않도록
-- schema · 함수명 · identity arguments 를 tiebreaker 로 더한다.
SELECT count(*) AS function_count,
       md5(string_agg(p.oid::regprocedure::text || '|' || coalesce(p.proacl::text,''),
                      E'\n' ORDER BY p.oid::regprocedure::text, n.nspname, p.proname,
                                     pg_get_function_identity_arguments(p.oid))) AS acl_snapshot_md5
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE NOT (n.nspname = 'catchmenu_common' AND p.proname IN ('isolate_tenant','detect_threat'));
-- 주의: `oid::regprocedure` 표기는 search_path 에 따라 schema 한정 여부가 달라질 수 있다.
--       적용 전 · 후 두 측정은 같은 접속 설정(같은 psql 호출 형태)에서 실행한다.

-- I-8 (schema USAGE 행렬 + role membership)
SELECT r.rolname, n.nspname, has_schema_privilege(r.rolname, n.nspname, 'USAGE') AS usage
FROM pg_namespace n
CROSS JOIN (SELECT rolname FROM pg_roles
            WHERE rolname IN ('anon','authenticated','service_role','postgres',
                              'authenticator','catchmenu_authority_owner')) r
WHERE n.nspname LIKE 'catchmenu\_%' ORDER BY 1, 2;

-- I-8 membership (Stage 6 처분 F-8 — 부여 옵션까지 측정하고 직렬화에 포함한다)
SELECT m.rolname AS member, ro.rolname AS role,
       am.admin_option, am.inherit_option, am.set_option,
       pg_get_userbyid(am.grantor) AS grantor
FROM pg_auth_members am JOIN pg_roles ro ON ro.oid = am.roleid
JOIN pg_roles m ON m.oid = am.member
WHERE ro.rolname IN ('anon','authenticated','service_role','postgres',
                     'authenticator','catchmenu_authority_owner')
   OR m.rolname IN ('anon','authenticated','service_role','postgres',
                    'authenticator','catchmenu_authority_owner')
ORDER BY 1, 2;

-- I-8 직렬화 (USAGE 행렬 + membership 을 한 md5 로)
SELECT md5(
  (SELECT coalesce(string_agg(r.rolname || '|' || n.nspname || '|' ||
                              has_schema_privilege(r.rolname, n.nspname, 'USAGE')::text,
                              E'\n' ORDER BY r.rolname, n.nspname), '')
     FROM pg_namespace n
     CROSS JOIN (SELECT rolname FROM pg_roles
                 WHERE rolname IN ('anon','authenticated','service_role','postgres',
                                   'authenticator','catchmenu_authority_owner')) r
    WHERE n.nspname LIKE 'catchmenu\_%')
  || E'\n--\n' ||
  (SELECT coalesce(string_agg(m.rolname || '|' || ro.rolname || '|' ||
                              am.admin_option::text || '|' || am.inherit_option::text || '|' ||
                              am.set_option::text || '|' || pg_get_userbyid(am.grantor),
                              E'\n' ORDER BY m.rolname, ro.rolname, am.admin_option,
                                             am.inherit_option, am.set_option,
                                             pg_get_userbyid(am.grantor)), '')
     FROM pg_auth_members am JOIN pg_roles ro ON ro.oid = am.roleid
     JOIN pg_roles m ON m.oid = am.member
    WHERE ro.rolname IN ('anon','authenticated','service_role','postgres',
                         'authenticator','catchmenu_authority_owner')
       OR m.rolname IN ('anon','authenticated','service_role','postgres',
                        'authenticator','catchmenu_authority_owner'))
) AS i8_snapshot_md5;

-- I-9 (overload 수 — Stage 6 처분 F-6)
SELECT n.nspname, p.proname, count(*) AS overload_count
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'catchmenu_common' AND p.proname IN ('isolate_tenant','detect_threat')
GROUP BY 1, 2 ORDER BY 1, 2;   -- 각 1 이어야 한다

-- I-10 (default ACL 부재)
SELECT count(*) AS catchmenu_default_acl_rows
FROM pg_default_acl d LEFT JOIN pg_namespace n ON n.oid = d.defaclnamespace
WHERE n.nspname LIKE 'catchmenu\_%';

-- I-11 (role 속성)
SELECT rolname, rolsuper, rolbypassrls, rolinherit, rolcanlogin, rolcreaterole, rolcreatedb
FROM pg_roles
WHERE rolname IN ('anon','authenticated','service_role','postgres',
                  'authenticator','catchmenu_authority_owner')
ORDER BY 1;

-- I-7 (상위 호출자 5개)
SELECT p.oid::regprocedure::text AS f, pg_get_userbyid(p.proowner) AS owner,
       p.prosecdef, md5(p.prosrc) AS src_md5, p.proacl::text
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname IN ('manage_subscription','verify_security_token','gateway_audit_entry',
                    'record_van_transaction','check_staff_permission')
  AND n.nspname LIKE 'catchmenu\_%' ORDER BY 1;
```

기대 (03_Logic S0):

| 항목 | 기대 |
|---|---|
| `isolate_tenant` proacl | `postgres` · `authenticated` |
| `detect_threat` proacl | PUBLIC · `postgres` · `authenticated` |
| `anon` | `isolate_tenant` f · `detect_threat` t |
| `authenticated` | t · t |
| `service_role` | f · t |
| `postgres` | t · t |
| `authenticator` | f · t (2026-09-23 clean 실측) |
| `catchmenu_authority_owner` | `isolate_tenant` **f** · `detect_threat` **t** (S1 에서는 **f · f**) — 아래 주 참조 |
| I-9 | `isolate_tenant` 1 · `detect_threat` 1 (overload 수) |
| I-10 | 0행 |
| I-7 md5 | 03_Logic I-7 기준값 표와 일치 |

> **주 (TP-2 — 앵커 확정 2026-09-25)**: 앵커의 최초 처분(S0 · S1 모두 **f**)은 명시적 grant 만 따진 것이었다. S0 의 `detect_threat` 는 PUBLIC EXECUTE 를 가지므로 모든 role 에 **t** 다. 정정 결과 이 role 은 **S0 `f · t` → S1 `f · f`** 로 바뀌며, `detect_threat` 쪽의 t → f 가 **회수가 실제로 일어났다는 증거**가 된다.
>
> 처분 근거(`0090` · `0121` 에 이 role 에 대한 `GRANT` 없음 · `0169` 가 만든 NOLOGIN role)는 **명시적 grant** 에 대해서는 맞고, **S1 (적용 후)** 에서도 맞다. 다만 S0 의 `detect_threat` 는 PUBLIC EXECUTE 를 가진다(`0121` 에 PUBLIC revoke 없음 — 03_Logic S0). 같은 이유로 `authenticator` 도 clean baseline 실측에서 `detect_threat` t 였다 (SP-4 · 2026-09-23).
>
> 확인 실측 (현재 DB · read-only · 대상 함수가 아닌 `proacl IS NULL` 함수로 PUBLIC 의미만 확인):
>
> ```text
> SQL: select p.oid::regprocedure::text, p.proacl::text,
>             has_function_privilege('catchmenu_authority_owner', p.oid, 'EXECUTE')
>      from pg_proc p join pg_namespace n on n.oid=p.pronamespace
>      where n.nspname='catchmenu_common' and p.proacl is null limit 3;
>  catchmenu_common.assert_true(text,boolean,text)   |  | t
>  catchmenu_common.current_store_id()               |  | t
> SQL: select rolname, rolcanlogin, rolinherit from pg_roles where rolname='catchmenu_authority_owner';
>  catchmenu_authority_owner | f | t
> ```

- I-6 · I-8 · I-11 은 **이 시점 값이 기준값**이다. 적용 후 값은 **여기서 뜬 값과만** 비교한다.
- **I-6 의 기준 정의는 위 절차 4 의 쿼리 하나다** (Stage 6 마무리 · 2026-09-25). 03_Logic 이 인용한 Stage 4 참고값 `9362a195…` 는 다른 직렬화 형식의 값이라 비교 대상이 아니다. 같은 쿼리로 2026-09-25 현재 DB 를 재면 `a92b4a1a…` 가 나오지만, 그것도 현재 DB 값일 뿐 B5 기준값이 아니다.
- **실패 조건**: S0 가 기대와 다르면 `0180` 을 적용하지 않고 멈춘다 (baseline 이 clean 이 아니다).

### 5. `0180` 적용 — Stage 8 (Codex)

```bash
docker cp sql/migrations/0180_ctn1a_isolate_tenant_execute_containment.sql \
  ctn1a_stage8_<YYYYMMDD>:/tmp/ctn1a_migrations/
docker exec -i ctn1a_stage8_<YYYYMMDD> \
  psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres \
  -f /tmp/ctn1a_migrations/0180_ctn1a_isolate_tenant_execute_containment.sql
```

- 도구를 쓰지 않는 근거: `tools/apply_migrations.py` L19~22 의 고정 상수.
- **실패 조건**: 종료코드 ≠ 0 → 멈추고 psql 출력 전체를 보고. 재시도 전에 S0 · S1 중 어느 상태인지 실측으로 판정한다 (03_Logic Unknown State Path).

### 6. `migration_history` 성공행 기록 — Stage 8 (Codex)

`catchmenu_meta.migration_history` 스키마 (read-only 조회 원출력):

```text
 ordinal_position |  column_name  |        data_type         | is_nullable | column_default
------------------+---------------+--------------------------+-------------+----------------
                1 | filename      | text                     | NO          |
                2 | checksum      | text                     | NO          |
                3 | applied_at    | timestamp with time zone | NO          | now()
                4 | applied_by    | text                     | YES         | CURRENT_USER
                5 | success       | boolean                  | NO          | true
                6 | error_message | text                     | YES         |
```

기록 형식은 `tools/apply_migrations.py` L160~169(`record_result`)와 같게 한다.

```sql
INSERT INTO catchmenu_meta.migration_history
  (filename, checksum, success, error_message)
VALUES ('0180_ctn1a_isolate_tenant_execute_containment.sql', '<checksum>', true, NULL)
ON CONFLICT (filename) DO UPDATE SET
  checksum = EXCLUDED.checksum, success = EXCLUDED.success,
  error_message = EXCLUDED.error_message, applied_at = now();
```

- `applied_at` · `applied_by` 는 기본값(`now()` · `CURRENT_USER`)에 맡긴다.
- `<checksum>` 계산: 파일 바이트에서 `\r\n` → `\n` 치환 후 SHA-256 (`tools/apply_migrations.py` L100~102). 이 값은 파일이 확정된 뒤 Stage 8 이 계산해 raw log 에 남긴다.
- 이 `INSERT` 문 원문과 실행 출력을 raw log 에 보존한다.
- **실패 조건**: `INSERT` 실패 → SQL 은 이미 적용됐으므로 "적용됐으나 기록 없음" 상태다. 멈추고 보고한다.

### 7. S1 실측 · 대조 — Stage 8 이 1차, Stage 9 (Claude Code + Cursor) 가 독립 재실행

절차 4의 쿼리를 그대로 다시 실행하고 I-1 ~ I-11 을 대조한다. 기대는 아래 Positive · Negative · Regression 항목.

### 8. raw log 보존 — Stage 8 · Stage 9 각각

선례 형식: `docs/implementation_evidence/601700/raw_logs/` 의 두 자리 번호 파일 (`01_git_diff_stat.txt` … `15_rollback.log`).

**경로 분리 (Stage 6 처분 F-5)**: Stage 8 과 Stage 9 는 각자 자기 환경을 만들고 같은 이름의 로그를 남기므로, 서로 덮어쓰지 않도록 하위 폴더를 나눈다.

`raw_logs/stage8/` — **9개** (Stage 6 처분 F-4 · 개수 확정)

| # | 파일 | 내용 |
|---|---|---|
| 1 | `01_container_create.log` | 절차 1 명령 · health 판정 출력 |
| 2 | `02_archive_manifest.log` | 파일 목록 · 각 SHA-256 · manifest SHA-256 |
| 3 | `03_replay_pass1.log` | 절차 3 1차 158개 |
| 4 | `04_replay_pass2.log` | 절차 3 2차 19개 |
| 5 | `05_s0_baseline.log` | 절차 4 전량 (I-6 · I-8 · I-9 · I-10 · I-11 기준값 포함) |
| 6 | `06_apply_0180.log` | 절차 5 |
| 7 | `07_history_insert.log` | 절차 6 (INSERT 원문 포함) |
| 8 | `08_s1_verify.log` | 절차 7 (Stage 8 1차 대조) |
| 9 | `09_teardown.log` | 절차 9 |

`raw_logs/stage9/` — **10개**

| # | 파일 | 내용 |
|---|---|---|
| 1 | `01_container_create.log` | Stage 9 자기 환경 (절차 1) |
| 2 | `02_archive_manifest.log` | 절차 2 |
| 3 | `03_replay_pass1.log` | 절차 3 1차 |
| 4 | `04_replay_pass2.log` | 절차 3 2차 |
| 5 | `05_s0_baseline.log` | 절차 4 |
| 6 | `06_apply_0180.log` | 절차 5 (Stage 9 재현) |
| 7 | `07_s1_verify.log` | 절차 7 |
| 8 | `08_invariants.log` | I-1 ~ I-11 대조표 |
| 9 | `09_forbidden_and_git.log` | FB-1 ~ FB-5 (`git status --porcelain` · `git diff --name-only` · Check-Governance 출력) |
| 10 | `10_teardown.log` | 절차 9 (현재 DB 무변경 2시점 비교 포함) |

**보존 위치 (앵커 처분 TP-3 · 2026-09-25 · Stage 6 처분 F-5 로 하위 폴더 분리)**: `docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/raw_logs/stage8/` 와 `…/raw_logs/stage9/`. 근거는 `000701` §7.4 L639~654 의 권장 폴더 형태(`docs/implementation_evidence/<change_id>/raw_logs/` + 두 자리 번호 파일명)이며, §15 L2369~2400 도 같은 구조를 적는다. **이 폴더들은 각 단계가 직접 만든다 — 지금 만들지 않는다.** Stage 10 에서 패킷과 함께 `603010` 폴더로 옮긴다.

### 9. 정리와 현재 DB 무변경 증명 — Stage 8 · Stage 9

```bash
# 컨테이너와 그 anonymous volume 까지 지운다 (Stage 6 처분 F-9)
docker rm -f -v ctn1a_stage<N>_<YYYYMMDD>
docker ps -a --filter label=ctn1a_disposable=true      # 0건이어야 한다
docker volume ls -qf dangling=true                     # 남은 anonymous volume 확인
```

임시 폴더 삭제 (절차 2 에서 만든 저장소 밖 폴더):

```bash
rm -rf <임시폴더>        # 저장소 밖 경로임을 지우기 전에 확인한다
ls <임시폴더> 2>&1       # "No such file or directory" 여야 한다
```

작업 트리 비교 (절차 시작 전과 끝난 뒤 두 번 · 저장소에 흔적이 남지 않았는지):

```bash
git status --porcelain
git diff --name-only
```

- 기대: Stage 8 은 Allowed Files A 에 해당하는 변경만, Stage 9 는 `raw_logs/stage9/` 만.

현재 DB 무변경 증명 (read-only · 시작 전과 끝난 뒤 두 번):

```sql
SELECT success, count(*), max(filename), max(applied_at)
FROM catchmenu_meta.migration_history GROUP BY success ORDER BY 1;

SELECT p.oid::regprocedure::text, p.proacl::text
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'catchmenu_common' AND p.proname IN ('isolate_tenant','detect_threat')
ORDER BY 1;

SELECT datname FROM pg_database ORDER BY 1;
```

- 두 시점 값이 같아야 한다.
- **실패 조건**: 다르면 즉시 멈추고 보고한다.

## Required Unit Tests

없음. 이 변경은 애플리케이션 코드를 건드리지 않는다 (앱 직접 참조 0 — 01_ImpactScope "Tests Found").

## Required Integration Tests

없음. 대상 두 함수는 `601505` §4.1.1 L311~314 로 모든 호출 경로가 금지돼 있어, 호출로 검증하지 않는다.

## Required SQL / Migration Tests

| # | 항목 | 측정 | 기대 | 수행 |
|---|---|---|---|---|
| M-1 | 파일 머리 | 첫 5행에 `-- Workpacket: 603010` (`000701` §6.11.1 · `Check-Governance.ps1` L971 정규식 · **L977 첫 5행 읽기** · L979 는 헤더 없음 분기) | 일치 | Stage 8 · Stage 9 |
| M-2 | 트랜잭션 경계 | 파일에 `BEGIN;` · `COMMIT;` 각 1 (`0175` · `0178` 선례) | 각 1 | Stage 8 · Stage 9 |
| M-3 | 인코딩 | 첫 3바이트가 BOM 이 아님 · `\r` 0 · UTF-8 디코드 성공 (`.gitattributes` L1 `*.sql text eol=lf`) | 통과 | Stage 8 · Stage 9 |
| M-4 | 문장 범위 | 파일 안 실행문은 `BEGIN` · 두 `REVOKE` · `COMMIT` 뿐 (05_ChangeContract Allowed Operations) | 일치 | Stage 9 |
| M-5 | checksum | 파일 SHA-256(CRLF→LF) = `migration_history.checksum` | 일치 | Stage 8 · Stage 9 |
| M-6 | history 행 | `filename` 1행 · `success = true` · `error_message IS NULL` | 1행 | Stage 9 |
| M-7 | prototype 부재 | `migration_history` 에 `0179_ctn1a_revoke_isolate_tenant_execute.sql` 행 0건 · checksum `73c2e6b1ea5a2bfaa79b5a6929bff3ae345706c2a579b076102edee44a99a39c` 0건 (V-1 · V-2 · V-3) | 0 | Stage 9 |

## Required RLS Tests

RLS 는 바꾸지 않는다. 확인만 한다.

| # | 항목 | 측정 | 기대 | 수행 |
|---|---|---|---|---|
| R-1 | 아래 6개 테이블의 `relrowsecurity` · `relforcerowsecurity` · policy 수 | 아래 SQL 을 적용 전 · 후 비교 | 같음 | Stage 9 |
| R-2 | owner 의 BYPASSRLS | I-11 의 `rolbypassrls` | `postgres` t (변화 없음) | Stage 9 |

**R-1 대상 테이블 (Stage 6 처분 F-7 — 실제 이름 확정)**: 두 함수가 쓰는 테이블이다 (01_ImpactScope "Database Tables" · 00_CodexScan "RLS Policies" L292~299).

```sql
SELECT n.nspname, c.relname, c.relrowsecurity, c.relforcerowsecurity,
       (SELECT count(*) FROM pg_policy pol WHERE pol.polrelid = c.oid) AS policy_count
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE (n.nspname, c.relname) IN (
        ('catchmenu_common','operation_alerts'),
        ('catchmenu_common','sandbox_violations'),
        ('catchmenu_common','security_audit_log'),
        ('catchmenu_common','security_threats'),
        ('catchmenu_hq','tenants'),
        ('catchmenu_ledger','events'))
ORDER BY 1, 2;
```

기대: 6행 · `relrowsecurity` · `relforcerowsecurity` 모두 t · `policy_count` 가 적용 전과 같음 (현재 DB read-only 실측에서도 6행 모두 t · t).

## Required Provider Mock Tests

없음. Provider 인터페이스를 건드리지 않는다. `catchmenu_payment.record_van_transaction` 은 I-7 로 불변을 확인한다.

## Required Idempotency Tests

| # | 항목 | 측정 | 기대 | 수행 |
|---|---|---|---|---|
| ID-1 | `0180` 을 같은 환경에 두 번째 적용 | 절차 5 를 한 번 더 실행한 뒤 절차 4 쿼리 재실행 | S1 행렬 · I-1 ~ I-11 이 1회 적용 후와 같음 · 오류 없음 | Stage 9 |
| ID-2 | history 행 수 | `migration_history` 의 `0180` 행 수 | 1 (`ON CONFLICT (filename) DO UPDATE`) | Stage 9 |

## Required Duplicate Request Tests

해당 없음 (요청 · 이벤트 경로가 없는 DDL/ACL 변경).

## Required Timeout Tests

해당 없음 (외부 호출 · 비동기 없음 — 03_Logic Timeout Path).

## Required Unknown State Tests

| # | 항목 | 측정 | 기대 | 수행 |
|---|---|---|---|---|
| U-1 | "적용됐으나 기록 없음" 판별 절차 | 절차 4 쿼리로 ACL 을 실측해 S0 · S1 중 어디인지 판정 | 판정 절차가 문서대로 동작 | Stage 9 (문서 검토) |

## Required Rollback Tests

**실행하지 않는다.** 문서로만 확인한다.

| # | 항목 | 내용 | 수행 |
|---|---|---|---|
| RB-1 | rollback 의 의미 | 회수한 EXECUTE 를 다시 주면 S0 로 돌아간다 — `authenticated` 가 두 함수를 직접 호출할 수 있고 `detect_threat` 는 PUBLIC EXECUTE 로 돌아간다. 즉 **H03-F1 이 다시 열린다** (`602061` §3.1 L243~256) | Stage 9 (문서 검토) |
| RB-2 | rollback 방법 | 불변 경계를 넘은 뒤에는 새 forward migration 으로만 (`000701` §14.5 L2363) | Stage 9 |
| RB-3 | rollback 권한 | Human 결정 없이 하지 않는다 (03_Logic Rollback Rule) | Stage 9 |

## Required Audit Ledger Tests

| # | 항목 | 측정 | 기대 | 수행 |
|---|---|---|---|---|
| A-1 | 두 함수의 audit · ledger 쓰기 경로 불변 | I-1 (`md5(prosrc)`) | 같음 | Stage 9 |
| A-2 | 이 변경의 감사 흔적 | `migration_history` 의 `0180` 행 | 1행 · `success = true` | Stage 9 |

## Required Evidence Packet Tests

| # | 항목 | 기대 | 수행 |
|---|---|---|---|
| E-1 | raw log 이 모두 있다 (절차 8) — `raw_logs/stage8/` **9개** · `raw_logs/stage9/` **10개** | 존재 | Stage 9 |
| E-2 | manifest SHA-256 이 raw log 에 있고 기대값과 같다 | `8958ad05…a6e389` | Stage 9 |
| E-3 | 모든 산출물이 `Change ID: ctn1a_isolate_tenant_execute_containment` 를 갖는다 (`000701` §6.11) | 일치 | Stage 9 |

## 검증 항목 — Positive / Negative / Regression / Forbidden

### Positive — S1 역할 행렬

절차 4의 EXECUTE 행렬 쿼리를 `0180` 적용 후 실행한다.

| 역할 | `isolate_tenant` | `detect_threat` | 수행 |
|---|---|---|---|
| `anon` | f | f | Stage 8 · Stage 9 |
| `authenticated` | f | f | Stage 8 · Stage 9 |
| `service_role` | f | f | Stage 8 · Stage 9 |
| `postgres` (owner) | t | t | Stage 8 · Stage 9 |
| `authenticator` | f | f | Stage 8 · Stage 9 |
| `catchmenu_authority_owner` | S0 **f** → S1 **f** — S1 이 f 가 아니면 FAIL (앵커 확정 TP-2) | S0 **t** → S1 **f** — 회수가 일어났다는 증거. S1 이 f 가 아니면 FAIL | Stage 8 · Stage 9 |
| PUBLIC | `proacl` 에 PUBLIC 항목 없음 | 없음 | Stage 8 · Stage 9 |

`proacl` 기대: 두 함수 모두 owner 항목만 남는다.

### Negative — 회수 대상이 아닌 것이 바뀌지 않았다

| # | 항목 | 측정 | 기대 | 수행 |
|---|---|---|---|---|
| N-1 | 다른 모든 함수의 ACL | I-6 쿼리 (적용 전 기준값과 비교) | `function_count` · `acl_snapshot_md5` 둘 다 같음 | Stage 9 |
| N-2 | 상위 호출자 5개 | I-7 쿼리 | `proacl` · `md5(prosrc)` · `prosecdef` 같음 | Stage 9 |
| N-3 | `service_role` 에 grant 되지 않았다 | EXECUTE 행렬 | f · f | Stage 9 |
| N-4 | schema USAGE 변화 없음 | I-8 | 같음 | Stage 9 |

### Regression — I-1 ~ I-11 전건

| 불변 | 측정 | 기대 | 수행 |
|---|---|---|---|
| I-1 | `md5(prosrc)` 두 함수 | 적용 전과 같음 | Stage 8 · Stage 9 |
| I-2 | `oid::regprocedure` | signature 문자열 같음 | Stage 9 |
| I-3 | `pg_get_userbyid(proowner)` | `postgres` | Stage 9 |
| I-4 | `prosecdef` | t | Stage 9 |
| I-5 | `proconfig` | 03_Logic I-5 값 | Stage 9 |
| I-6 | 위 스냅샷 쿼리 | 같음 | Stage 9 |
| I-7 | 상위 호출자 5개 | 같음 | Stage 9 |
| I-8 | USAGE 행렬 + membership | 같음 | Stage 9 |
| I-9 | 같은 이름 overload 수 | 각 1 | Stage 9 |
| I-10 | `pg_default_acl` catchmenu_* 행 | 0 | Stage 9 |
| I-11 | role 속성 6개 | 같음 | Stage 9 |

### Boundary / Forbidden File Tests

| # | 항목 | 측정 | 기대 | 수행 |
|---|---|---|---|---|
| FB-1 | 허용 파일 밖 변경 0건 | `git status --porcelain` · `git diff --name-only` | 05_ChangeContract Allowed Files 에 있는 것만 | Stage 9 |
| FB-2 | 기존 migration 무수정 | `git diff --name-only -- sql/migrations/` | `0180` 신규 1건 외 0 | Stage 9 |
| FB-3 | prototype 무수정 | `0179` 파일의 SHA-256 이 `73c2e6b1…a99a39c` 그대로 | 같음 | Stage 9 |
| FB-4 | 현재 local DB 무변경 | 절차 9 의 두 시점 비교 | 같음 | Stage 8 · Stage 9 |
| FB-5 | 거버넌스 검사 | `tools\Check-Governance.ps1 -Top 0` 합계 | **Stage 8 착수 직전에 다시 측정한 값을 기준선으로 삼는다** (현재 511 은 2026-09-25 값 · 앵커 처분 TP-4). 그 기준선 대비 증가 0 (신규 `0180` 의 G15 판정 제외 — 아래 M-8) | Stage 9 |
| M-8 | G15 | `0180` 이 `Workpacket: 603010` → `603010*` 폴더의 ChangeContract 를 찾고 Stage 7 이 APPROVED 로 읽힌다 (`Check-Governance.ps1` L951~967 · L1004) | `CONTRACT_NOT_FOUND` 아님 · `MIGRATION_WITHOUT_APPROVAL` 아님 | **Stage 10 폴더 이동 후** (Stage 6 재검증 N-4 — Stage 9 시점에는 `603010` 폴더가 없어 판정할 수 없다) |

## Manual Verification Checklist

- [ ] Stage 7 승인 문구가 `05_ChangeContract.md` 에 채워졌다
- [ ] B5 환경이 새로 만들어졌고 현재 DB 가 아니다
- [ ] manifest SHA-256 이 기대값과 같다
- [ ] 177/177 replay 성공
- [ ] 적용 직전 S0 실측이 기대와 같다 (V-4 · V-6)
- [ ] `0180` 적용 성공 · history 행 1건
- [ ] S1 역할 행렬 일치
- [ ] I-1 ~ I-11 전건 일치
- [ ] raw log 보존 — `raw_logs/stage8/` 9개 · `raw_logs/stage9/` 10개
- [ ] disposable 환경 삭제 · 현재 DB 무변경 확인 (해당 Stage 시작 · 종료 두 시점)
- [ ] `catchmenu_*` 함수 호출 0건

## Acceptance Criteria

1. 위 Positive · Negative · Regression · Migration · Idempotency · Forbidden 항목이 전건 통과
2. Stage 9 가 Stage 8 과 **독립된 환경**에서 같은 결과를 재현
3. raw log 가 모두 보존되고 `Change ID` 가 일치
4. **Stage 8 · Stage 9 구간에서** 현재 local DB 가 바뀌지 않았음이 각 Stage 시작 · 종료 두 시점 비교로 증명됨. Stage 10 에서 Stage 7 ④ "되돌린다" 를 집행하는 경우의 변경은 이 요건의 대상이 아니다 (Stage 10 이 별도로 절차와 증거를 남긴다).

## Out Of Scope

- 간접 경로 차단 (CTN-1b) · `42883` 수정
- cloud 적용
- `tools/apply_migrations.py` 수정
- prototype `0179` 처분 실행 (Stage 7 결정 사항)

## Stage 8 이 지켜야 할 제약

1. prototype `0179` · `601513` 을 **보지 않고**, 승인된 계약(`05_ChangeContract.md`)만으로 구현한다.
2. **B5 환경에서만** 적용한다. 현재 local DB(`supabase_db_yoonsul_wait_order_handoff`)에 적용하지 않는다.
3. `catchmenu_*` 함수를 호출하지 않는다 (`601505` §4.1.1 L311~314). 검증은 카탈로그 · 권한 함수로만.
4. 허용 파일 밖을 건드리지 않는다.
5. 실패하면 멈추고 보고한다. 파일을 고치거나 순서를 바꾸지 않는다.

## Open Questions For Claude

- **OQ-TP-1** 절차 1의 컨테이너 기동 옵션(환경변수 · healthcheck 대기 방식)은 HD-CTN-06 실측이 쓴 것과 같아야 한다. 그 raw log 의 보존 위치가 이 저장소에 없다 — 어디서 참조하는가. — **결정: HD-CTN-05 · 06 실측은 조사용이라 raw log 를 남기지 않았다. Stage 8 의 실행이 최초 기준 기록이다 (앵커, 2026-09-25)** → 절차 1
- **OQ-TP-2** `catchmenu_authority_owner` 의 두 함수 EXECUTE 기대값을 정하지 않았다 (`0169` 가 만든 NOLOGIN role · `601505` §4.4 L398 은 신규 4테이블 GRANT 만 다룬다). 실측 기록만 할지, 기대값을 정할지. — **결정: 기대값 f (앵커, 2026-09-25).** S1 · Positive 항목에 `f — 다르면 FAIL` 로 반영했다. **앵커 확정 (2026-09-25)**: 이 role 의 기대값은 **S0 `isolate_tenant` f · `detect_threat` t → S1 `f · f`** 다. S0 의 `detect_threat` 가 t 인 것은 PUBLIC EXECUTE 때문이며, 그 t → f 가 회수의 증거가 된다 — 절차 4 표의 주 참조
- **OQ-TP-3** raw log 를 Stage 10 전까지 어디에 두는가 (`docs/implementation_evidence/<change_id>/raw_logs/` 제안 — `601700/raw_logs` 선례는 워크패킷 번호 폴더). — **결정: `docs/implementation_evidence/ctn1a_isolate_tenant_execute_containment/raw_logs/stage8/` (Stage 8) · 같은 경로의 `raw_logs/stage9/` (Stage 9) · `000701` §7.4 (앵커, 2026-09-25 · 하위 폴더 분리는 Stage 6 처분 F-5)** → 절차 8
- **OQ-TP-4** FB-5 의 기준선: Stage 8 시작 시점 합계를 무엇으로 고정하는가 (현재 511, 단 prototype 처분 결과에 따라 달라진다). — **결정: Stage 8 착수 직전 재측정값을 기준선으로 삼는다 (앵커, 2026-09-25)** → FB-5
- **OQ-S6-1** (Stage 4 → Stage 6) `600020` §4 네 요건이 새 워크패킷 CTN-1a 에도 적용되는가 (§1.3 L44~45 문면은 「기존 구현 Lifecycle 산출물」을 대상으로 한다).
- **OQ-S6-2** (Stage 4 → Stage 6) `603000` 이 `000002` §2.1 L322 의 폴더 번호 대역 소유와 충돌하는가. 대안(`604000` 이후 대역) 포함. — **종결 — 충돌 없음 (Stage 6).** 근거: `600023` §6 L264~270 이 Runtime Gate 를 `602000 ~ 602999` 로 한정한다.

## Final Rule

이 TestPlan 은 구현을 승인하지 않는다. Stage 7 Human Approval 이 허용 파일을 명시한 뒤에만 Stage 8 이 구현한다.

## Stage 6 Contract Review 반영 (2026-09-25)

Stage 6 계약 검증(Codex F-1 ~ F-14 · Cursor 1 ~ 7)의 처분을 Stage 5 로 loopback 해 반영했다 (`000701` §18). 앵커 판단이며 Human 결정이 아니다.

| 발견 | 처분 | 이 문서에서 바뀐 곳 |
|---|---|---|
| F-1 manifest 기대값 검증 | **해소 (2026-09-25)** | 절차 2 에 산출 규칙 · 바이트 수 18321 · 셸 검산 블록 · 오산출 시 나오는 `d85cff6d…` 안내 추가 |
| F-2 health 대기 절차 없음 | 수용 | 절차 1 — health 대기 루프 · `pg_isready` · `select 1` 판정 |
| F-3 Allowed Files 확장 | 수용 (05 소관) | — |
| F-4 raw log 개수 불일치 | 수용 | 절차 8 · E-1 · 체크리스트를 stage8 9개 · stage9 10개로 통일 |
| F-5 raw log 경로 충돌 | 수용 | `raw_logs/stage8/` · `raw_logs/stage9/` 분리 |
| F-6 I-9 측정 SQL 없음 | 수용 | 절차 4 에 overload 수 쿼리 · S0 기대표에 행 추가 |
| F-7 R-1 대상 테이블 미확정 | 수용 | 6개 테이블 실제 이름 + 측정 SQL |
| F-8 I-8 membership 측정 부족 | 수용 | `admin_option` · `inherit_option` · `set_option` · `grantor` 측정 + 직렬화 md5 |
| F-9 정리 절차 부족 | 수용 | `docker rm -f -v` · dangling volume 확인 · 임시 폴더 삭제 · `git status` 비교 |
| F-13 폴더 생성 시점 | 수용 | 머리 표기를 **Stage 10** 으로 |
| Cursor 3 인용 줄 | 수용 | `L979` → L971 정규식 · **L977** 첫 5행 읽기 · L979 는 헤더 없음 분기 |
| F-11 (05 소관) | 수용 | Stage 7 ① 선택지를 "B5 승인 / 보류"로 (05) |
| 표현 정리 | 수용 | S0 기대표의 중복 구절 제거 · `catchmenu_authority_owner` 를 `S0 f · t / S1 f · f` 로 정확히 |

## Draft Status

Draft (Claude Code) — Stage 6 Contract Review 반영 2026-09-25 · Stage 6 재검증 대기
