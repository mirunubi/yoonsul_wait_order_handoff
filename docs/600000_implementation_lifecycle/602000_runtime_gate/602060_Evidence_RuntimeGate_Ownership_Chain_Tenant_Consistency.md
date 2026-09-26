# 602060_Evidence_RuntimeGate_Ownership_Chain_Tenant_Consistency.md

Status: Active
Lifecycle: RuntimeGate
DocumentType: Evidence
Last Updated: 2026-09-21

## §0 성격 · PRE-FLIGHT

`RG-06` gate 문서다. `600023` §3 의 형식을 따른다.

> ⛔ **이 판본은 미완성이다.**
>
> ```text
> §1 ~ §4 · §8 ~ §10   작성됨
> §5 migration          미착수 — 승인 전
> §6 재실행 로그        미착수 — 승인 전
> §7 회귀               미착수 — 승인 전
> ```
>
> **`600023` §3.1 의 PASS 조건은 아직 평가되지 않았다.**
> **이 문서를 `RG-06` PASS 의 근거로 인용하지 않는다.**

**번호 근거** — `600023` §6 이 `RG-N` 을 `602010` 부터 10단위로 배정한다. `RG-06` 의 앵커가 `602060` 이다. 파일명 · frontmatter 는 선례 5건(`602010`~`602050`)을 실측해 맞췄다.

```text
선례 패턴   602NN0_Evidence_RuntimeGate_<Name>.md
            Lifecycle: RuntimeGate
            DocumentType: Evidence
이 문서     602060_Evidence_RuntimeGate_Ownership_Chain_Tenant_Consistency.md
            동일
```

**PRE-FLIGHT 실측**

```text
측정 시각                    2026-09-21 KST
DB                           postgres
PostgreSQL                   17.6
container                    supabase_db_yoonsul_wait_order_handoff
container id                 b67400e8c73e...35ec
환경                         local/dev          ← HD-4
transaction_read_only        on — 전 세션. 쓰기 0건
Git HEAD                     8c86a4d
작업 전 working tree         clean
latest successful migration  0178_order_request_identity_and_numbering.sql
0179 이후                    없음
602061 Impact Scope          COMMITTED (8c86a4d)
```

> ⚠️ **`HD-4` 에 따라 local/dev 로 닫는다.**
> **cloud DB(`upzthfwhtvazfftxnyfu`)는 접속하지 않았다.**
> **local/dev 결과를 cloud 결과라고 표현하지 않는다.**

## §1 공격

`601919` `H-03` — ownership chain 에서 서로 다른 tenant 의 객체를 연결할 수 있는가.

**증명된 공격 둘.**

```text
공격 1   authenticated JWT 하나로 임의 tenant 의 lifecycle 을 바꾼다
         catchmenu_common.isolate_tenant(target_tenant, reason, false, ...)
         p_isolate=false 는 tenant_status 를 'ACTIVE' 로 덮는다
         TERMINATED · CANCELLED · SUSPENDED tenant 가 되살아난다

공격 2   authenticated JWT 하나로 타 tenant × 타 store 쌍의
         설정 행을 만든다
         entry point 3개가 같은 write primitive 에 닿는다
           update_business_hours
           toggle_store_mode
           update_kds_capacity_threshold
         공통 지점   catchmenu_store.ensure_store_settings
```

**공격이 성립하는 이유 — 실측**

```text
ownership chain writer 6개 중
  assert_caller_tenant_scope 호출          0개
  current_tenant_id 사용                   0개
  tenant_status · isolation_state 읽기     0개 (isolate_tenant 자신은 제외)

체인 7개 테이블의 trigger   전부 set_updated_at() — 정합 검사 0건
tenant consistency 를 보장하는 FK · CHECK   0건
```

> ⚠️ **FK 는 전부 있다. object existence 는 보장된다.**
> **어느 FK 도 두 객체의 tenant 가 같은지 보지 않는다** — `H-03-2`.

## §2 재현 로그

**전문은 `602061` §3 에 있다. 여기서는 도달 지점만 옮긴다.**

```text
재현 방식   default_transaction_read_only = on
            set local role authenticated
            set local "request.jwt.claims" = 타 tenant claims
            함수 본문 안쪽 write 문에서 25006 으로 멈추면
            권한·검사를 전부 통과해 쓰기 직전까지 도달한 것이다
            쓰기 0건
```

| # | 호출 | 도달 지점 | 출처 |
|---|---|---|---|
| `A-1` | `isolate_tenant(타 tenant, 'probe', false, null, 'ko')` | `update catchmenu_hq.tenants ... where id = p_tenant_id` — 본문 22행 | `602061` §3.1 |
| `A-2` | `update_business_hours(타 tenant, 남의 store, ...)` | `insert into catchmenu_store.store_settings (tenant_id, store_id)` — `ensure_store_settings` 11행 | `602061` §3.2 |
| `A-3` | `toggle_store_mode(타 tenant, 남의 store, 'PEAK', ...)` | 동일 지점 · `toggle_store_mode` 35행 경유 | `602061` §3.5 |
| `A-4` | `update_kds_capacity_threshold(타 tenant, 남의 store, ...)` | 동일 지점 · `update_kds_capacity_threshold` 49행 경유 | `602061` §3.5 |

**현재 상태에서 성공한다** — 네 호출 모두 `42501` 이 아니라 `25006` 으로 멈췄다. 거부가 아니라 read-only 차단이었다.

> ⚠️ **`get_store_settings` 는 `store_not_found` 로 먼저 반환한다 — GUARDED.**
> **같은 helper 를 쓰는 네 caller 중 하나만 검사를 갖고 있었다.**

## §3 invariant

⚠️ 아래는 Human 이 확정한 `H-03-1` ~ `H-03-5` · `HD-1` ~ `HD-5` 에서 도출한 것이다. 이 문서가 새로 만들지 않는다 — `600023` §3.2 · §3.4.

### §3.1 `I-1a` Tenant-scoped caller authority

```text
일반 tenant-scoped writer 는
caller authority 와 target tenant 를 분리한다

target tenant parameter 는 authority 의 근거가 아니다
```

**근거** — `H-03-3` · `010004` §7 `DENY_UNLESS_CONTEXT_MATCHES` · `010630` §28 `DENY_UNLESS_EXPLICITLY_ALLOWED`.

### §3.2 `I-1b` Platform-security authority

```text
tenant-wide isolation 은 601902 TI-3 의 두 주체만 발동 가능하다

  ①  Automatic platform / security system
  ②  Authorized platform-security Human

일반 authenticated tenant caller 는
자기 tenant 라도 발동할 수 없다

RG-01 · 0173 이 제거한 claim 기반 service_role exemption 을
되살리지 않는다
```

**근거** — `HD-1` · `601902` §1.3 `TI-3` · `010004` §10 「cross-tenant visibility is explicitly blocked unless platform-level authority exists」 · `602010` §10.1 `RG-F3`.

> ⚠️ **`I-1a` 와 `I-1b` 는 다른 판정식이다.**
>
> ```text
> I-1a   caller tenant == target tenant
>        assert_caller_tenant_scope 가 그 판정식이다
>
> I-1b   platform-security authority
>        caller tenant 일치는 판정식이 아니다
>        TI-3 의 두 주체는 caller tenant 가 target 과 다르다
> ```
>
> **`isolate_tenant` 에 `assert_caller_tenant_scope` 를 그대로 걸면**
> **`TI-3` 의 적법 주체 둘을 모두 차단하고 `TI-3` 이 금지한 주체만 통과시킨다.**

### §3.3 `I-2` Tenant × Store Pair Integrity

```text
catchmenu_store.ensure_store_settings 는 mutation 전에 검증한다

  stores.id        = p_store_id
  AND
  stores.tenant_id = p_tenant_id

불일치 · 존재하지 않는 store 는 fail closed 한다
```

**근거** — `HD-2` · `H-03-2` · `010640` §6 `SCOPE_STORE_MISMATCH` · `010640` §8 Store Isolation Boundary.

> ⚠️ **`HD-5` — 두 책임을 섞지 않는다.**
>
> ```text
> entry point     caller authority 를 검증한다      I-1a
> shared helper   tenant × store pair 를 검증한다   I-2
> ```
>
> **helper 의 pair guard 가 entry point 의 caller authority 검사를 대체하지 않는다.**

### §3.4 `I-3` Path Scope

```text
이번 RG-06 은 아래 두 결함만 닫는다

  H03-F1   catchmenu_common.isolate_tenant
           platform-security authority failure

  H03-F2   catchmenu_store.ensure_store_settings
           tenant × store pair integrity failure
           증명된 entry point 3개를 이 결함 하나로 묶는다
```

```text
이번 Gate 밖

  H03-F3                  latent · schema drift (stores.extra_metadata)
  OQ-4                    isolation_state · tenant_status 축 불일치 — 별도 finding
  OQ-7                    merchant_account — executable path 0 · 구조 관측
  138개 tenant · store pair table   schema-level consistency — HD-3
  cloud parity            HD-4
```

**근거** — `HD-2` · `HD-3` · `HD-4` · `H-03-4` · `H-03-5`.

> ⚠️ **`600023` §3.5 와의 관계.**
> **`I-2` 는 결과형이 아니라 writer 지정형이다.**
> **경로 전수 열거는 `602061` §3.5 가 `ensure_store_settings` caller 5개로 이미 수행했고,**
> **그중 도달 가능한 3개를 `I-3` 이 명시한다.**

## §4 근거

| 원천 | 절 | 이 gate 가 인용하는 내용 |
|---|---|---|
| `601902` | §1.3 `TI-3` | tenant-wide isolation 발동 주체 둘 · 일반 tenant user 권한 없음 · `AUTHORITY_ALLOWED` 만 실행 |
| `601902` | §1.2 `TI-2` | `isolation_state` 는 tenant-wide isolation 만 표현한다 |
| `010004` | §7 | `DENY_UNLESS_CONTEXT_MATCHES` · fail closed is mandatory |
| `010004` | §10 | cross-tenant 는 platform-level authority 가 있을 때만 |
| `010630` | §28 | `DENY_UNLESS_EXPLICITLY_ALLOWED` |
| `010640` | §6 | `SCOPE_STORE_MISMATCH` · `SCOPE_AUTHORITY_DENIED` |
| `010640` | §8 | Store Isolation Boundary — 예외는 명시적 multi-store authority 와 evidence 를 요구한다 |
| `600023` | §3.2 · §3.4 · §3.5 | Human 이 invariant 를 정한다 · 기존 선언 인용 가능 · 경로 전수 열거 |
| `602010` | §10.1 | `RG-F3` — claim 기반 `is_service_role()` 면제를 `0173` 이 제거했다 |
| `602040` | §3 | `RG-04` 가 `TI-13` · `TI-2` · `TI-12` 를 인용해 닫은 선례 |
| `602061` | 전체 | Impact Scope · verified findings · `H-03` · `HD` |

> ⚠️ **`600023` §3.3 — 원천 근거는 절 하나면 된다.**
> **이 표는 그 최소를 넘어 적었다. `I-1b` 의 핵심 근거 1개는 `601902` §1.3 `TI-3` 이다.**

## §5 migration — 미착수

> ⛔ **승인 전이다. 작성하지 않았다.**
>
> ```text
> 승인 필요   §8 OQ-1 runtime representation
>             그 선택이 정해지기 전에는 I-1b 를 코드로 쓸 수 없다
>
> 미착수      migration 파일 · 번호 · 본문 전부 없음
>             0178 이 최신이며 0179 이후는 존재하지 않는다 (실측)
> ```
>
> **`I-2` 만 먼저 쓸 수 있는가 — 가능하다.**
> **`I-2` 는 `HD-2` 로 위치가 확정됐고 `OQ-1` 에 의존하지 않는다.**
> **그러나 한 `RG` 를 부분 적용하는 것은 `600023` §3.1 의 PASS 조건을 쪼개는 것이므로**
> **그 여부 또한 Human 승인 항목이다** — §9.

## §6 재실행 로그 — 미착수

> ⛔ **§5 가 없으므로 실행할 것이 없다.**
> **`600023` §3.1 조건 1「§2 의 공격이 §6 에서 실패한다」는 아직 평가되지 않았다.**

## §7 회귀 — 미착수

> ⛔ **미착수.** 수행할 목록은 `602061` §8 · §8.5 에 확정돼 있다.

```text
R-1 · R-2    기대값 반전 — HD-1 이 자기 tenant 격리·해제를 권한 없음으로 판정했다
R-3 ~ R-8    isolate_tenant 거부 · fail closed · 내부 호출자
R-9 ~ R-16   pair integrity 정상 · 거부 · fail closed
R-17 ~ R-21  entry point 3개 정상 · 불일치 거부 · get_store_settings 이중검사
catalog delta   constraint · index · trigger 0 / signature 변경 0  — HD-3
```

> ⚠️ **`600023` §3.5 — 「미검증 경로 0건」을 §7 에 포함한다.**
> **`ensure_store_settings` caller 5개 전부가 회귀 대상이다.**

## §8 `OQ-1` — platform-security authority 의 runtime 표현

### §8.1 질문

```text
601902 TI-3 의 두 platform-level authority 를
DB runtime 에서 무엇으로 신뢰할 것인가

  ①  Automatic platform / security system
  ②  Authorized platform-security Human
```

**`HD-1` 이 정책을 닫았다. 물리 표현은 열려 있다.**

### §8.2 실측 — 후보의 재료가 실제로 존재하는가

```text
DB role 전수 (pg_ 제외)            17개
  catchmenu_authority_owner        실재 · NOLOGIN · BYPASSRLS
                                   member = postgres 뿐
                                   소유 테이블 0 · 소유 함수 0
                                   schema USAGE = catchmenu_hq 만
                                   생성 migration = 0169
  service_role                     실재 · BYPASSRLS
                                   catchmenu_* 15 schema 중 USAGE 2개뿐 — RG-F1
  supabase_privileged_role         실재 · member = postgres · supabase_etl_admin

catchmenu_* 함수 475개의 소유자    전부 postgres
                                   catchmenu_authority_owner 소유 0
  → 601503 §9 의 전용 owner role 규칙은 아직 미이행 상태다

current_user · session_user · pg_has_role 를 쓰는 catchmenu 함수   0개
  → role 기반 판정 선례가 저장소에 없다

postgres 전용 EXECUTE 함수 (내부 전용 패턴)   7개
  → assert_caller_tenant_scope 가 그 하나다. 선례 있음

authority_scope 컬럼 · 테이블                 0건
  010640 §5 가 요구하는 envelope 필드는 물리적으로 없다
authority_level 컬럼                          catchmenu_store.staff 1건
권한 성격 테이블                              staff_permission_matrix ·
                                              staff_permission_logs ·
                                              security_tokens · security_threats ·
                                              security_audit_log · security_scan_results

is_service_role()                             실재 · DEFINER · ACL 기본값(PUBLIC)
  본문 = request.jwt.claims ->> 'role' = 'service_role'
  이 함수를 쓰는 함수   0개 (0173 이 helper 에서 제거)
  이 함수를 쓰는 RLS policy   3개 — RG-F4
```

### §8.3 후보 비교 — 사실만

| 항목 | A. 전용 DB role 판정 | B. 별도 trusted context (GUC) | C. 내부 전용 entry point · wrapper 분리 | D. `authority_scope` 권한 모델 | E. 기존 저장소 패턴 |
|---|---|---|---|---|---|
| **형태** | `current_user` · `pg_has_role` 로 지정 role 을 확인 | 신뢰 연결만 설정하는 별도 GUC 를 읽는다 | `isolate_tenant` 를 postgres 전용으로 회수하고, 호출은 별도 wrapper 가 맡는다 | `010640` §5 `authority_scope` 를 물리화해 판정한다 | `staff_permission_matrix` · `security_tokens` 등 기존 권한 표를 재사용 |
| **caller 가 조작 가능한가** | **아니다** — role 은 연결 시점에 정해진다 | **`request.*` GUC 라면 가능하다.** PostgREST 가 JWT 로 채우는 GUC 는 caller 통제 아래 있다. 별도 이름의 GUC 는 누가 설정하느냐에 달렸다 | **아니다** — EXECUTE 권한이 경계다 | 표의 쓰기 경로에 달렸다. 그 경로가 또 `I-1` 대상이 된다 | 표의 쓰기 경로에 달렸다 |
| **JWT claim 만으로 위조 가능한가** | 불가 | **GUC 를 `request.jwt.claims` 파생으로 잡으면 가능** | 불가 | claim 을 입력으로 쓰면 가능 | claim 을 입력으로 쓰면 가능 |
| **`RG-01` · `0173` 과 충돌** | 없음 | **claim 파생이면 정면 충돌 — `RG-F3` 재도입** | 없음 | claim 파생이면 충돌 | claim 파생이면 충돌 |
| **`service_role` schema USAGE 부재와의 관계** | `service_role` 을 판정 role 로 쓰면 **`RG-F1` 때문에 진입 자체가 불가.** 다른 role 을 쓰면 무관 | 무관 | 무관 — wrapper 의 ACL 을 누구에게 줄지가 곧 `RG-F1` 문제로 되돌아온다 | 무관 | 무관 |
| **`detect_threat` 경로 적용** | `detect_threat` 가 DEFINER(owner=postgres)이므로 본문 안 `current_user` 는 postgres 다 — **자동 통과.** 그 자체가 판정을 무력화할 수 있다 | 가능 — 자동 경로가 GUC 를 설정해야 한다 | 가능 — `detect_threat` 를 내부 호출자로 인정한다 | 가능 — 자동 주체에 scope 행을 준다 | 가능 |
| **`manage_subscription` 경로 적용** | 동일 (DEFINER) | 가능 | 가능 | 가능 | 가능 |
| **Authorized Human 표현** | 가능하나 **개인을 구분하지 못한다** — role 은 집합이다 | 가능 | wrapper 가 무엇을 근거로 삼느냐에 위임된다 | **가능 — 주체별 행을 갖는다** | **가능 — 기존 표가 주체별이다** |
| **Automatic platform 표현** | 가능 | 가능 | 가능 | 가능 | 가능 |
| **두 주체를 서로 구분 가능한가** | role 을 2개 두면 가능 | GUC 값으로 가능 | entry point 를 2개 두면 가능 | **가능** | 가능 |
| **ACL 변경 필요** | **필요** — 판정 role 에 EXECUTE · schema USAGE 부여 | 불필요 | **필요** — `isolate_tenant` EXECUTE 회수 + wrapper 부여 | wrapper 를 두면 필요 | 필요할 수 있다 |
| **signature 변경 필요** | 불필요 | 불필요 | **wrapper 신설 시 새 signature 1개** | 판정 인자를 받으면 필요 | 판정 인자를 받으면 필요 |
| **신규 table · column 필요** | 불필요 (role 은 실재) | 불필요 | 불필요 | **필요 — `authority_scope` 물리화 0건** | 불필요 — 표는 실재. 단 의미 재정의 필요 |
| **저장소 선례** | **role 기반 판정 함수 0건.** 단 `catchmenu_authority_owner` role 은 실재 | 없음 | **postgres 전용 EXECUTE 함수 7건 — 선례 있음** | `authority_scope` 0건 | 표는 실재하나 tenant-wide isolation 에 쓰인 적 없음 |
| **`HD-1` 「claim 을 되살리지 않는다」 충족** | 충족 | **claim 파생이면 불충족** | 충족 | claim 을 입력으로 쓰지 않으면 충족 | claim 을 입력으로 쓰지 않으면 충족 |

### §8.4 기존 정책이 배제하는 것

**배제 1 — caller 가 통제하는 값만으로 platform authority 를 인정하는 안**

```text
role = service_role
authority = ...
app_metadata = ...
```

| 근거 | 내용 |
|---|---|
| `602010` §10.1 | `is_service_role()` 은 `request.jwt.claims ->> 'role'` 문자열만 본다. `authenticated` 가 그 값을 세팅하면 tenant 대조가 면제됐다 — `RG-F3` |
| `0173` | 그 면제를 `assert_caller_tenant_scope` 에서 **제거**했다. `602010` §10 이 그것으로 `FAIL` 을 닫았다 |
| `HD-1` | 「`RG-01` · `0173` 이 제거한 claim 기반 service_role exemption 을 되살리지 않는다」 |
| `010004` §7 | 「If context cannot be resolved, access must fail closed」 — caller 가 만든 context 는 resolve 가 아니다 |

> ⛔ **JWT claim 문자열만으로 platform authority 를 인정하는 안은 `RG-01` · `0173` 과 정면 충돌한다.**
> **후보 B 를 `request.jwt.claims` 파생 GUC 로 구현하는 변형이 여기에 해당한다.**
> **후보 D · E 도 판정 입력을 claim 으로 잡으면 같은 충돌에 걸린다.**

**배제 2 — `service_role` 을 판정 주체로 삼는 안 (현 상태 한정)**

```text
RG-F1 실측   service_role 은 catchmenu_* 15 schema 중 2개만 USAGE 가 있다
             catchmenu_common · catchmenu_hq · catchmenu_store 전부 USAGE 없음
             → isolate_tenant 에 진입 자체가 불가능하다
```

배제라기보다 **물리적 도달 불가**다. `RG-F1` 을 먼저 처분하지 않으면 이 안은 실행되지 않는다.

**배제 3 — `assert_caller_tenant_scope` 를 그대로 거는 안**

```text
근거   601902 §1.3 TI-3
       두 적법 주체는 platform-level 이며 caller tenant 가 target 과 다르다
       helper 의 판정식은 caller tenant == target tenant 다
       → TI-3 의 적법 주체 둘을 모두 차단하고
         TI-3 이 금지한 「일반 tenant user」만 통과시킨다
```

`602061` §7 18번 · `HD-1` 이 이미 제외로 기록했다.

### §8.5 기존 정책이 하나를 강제하는가 — 아니다

**검토 결과 단일 후보를 강제하는 조항을 찾지 못했다.**

```text
010004 §10      「platform-level authority exists」 — 존재를 요구하고 표현을 지정하지 않는다
010630 §6 · §28 15 상태와 default 를 정한다. 물리 표현을 지정하지 않는다
010640 §5       authority_scope 필드를 열거한다. 타입·저장 위치·판정식을 지정하지 않는다
601902 TI-3     주체 둘을 정한다. 런타임 식별 수단을 정하지 않는다
601902 TI-6     「이 선언은 기존 isolate_tenant 시그니처 변경 가능성을 받아들인다 /
                 파라미터명·타입·기존 함수 유지 여부는 Stage 4 가 정한다」
600023 §3.2     Human 이 invariant 를 정한다
```

> ⚠️ **`601902` `TI-6` 이 `isolate_tenant` 를 직접 지목해 「Stage 4 가 정한다」로 미뤘다.**
> **그 Stage 4 에 해당하는 결정이 지금 이 `OQ-1` 이다.**

**정책을 통과하는 후보 — 최소 셋**

```text
A   전용 DB role 판정        claim 미사용 · 선례 0 · ACL 변경 필요
                             ⚠️ DEFINER 안에서 current_user 가 postgres 가 되는 문제를
                                어떻게 다루는지가 설계 과제로 남는다
C   내부 전용 entry point     claim 미사용 · 선례 7건 · ACL 변경 + wrapper 1개
D   authority_scope 물리화    claim 미사용 구성 가능 · 신규 table/column 필요
E   기존 권한 표 재사용        claim 미사용 구성 가능 · 표는 실재하나 용도 재정의 필요
```

**둘 이상이 합법적으로 남는다. Human Approval 항목으로 올린다** — §9.

## §9 Approval Boundary

### §9.1 Already decided

```text
H-03-1 ~ H-03-5      602061 §2.1 ~ §2.5
HD-1 ~ HD-5          602061 §2.6
                       HD-1  isolate_tenant 는 platform-security authority 를 요구한다
                             policy CLOSED · runtime representation OPEN
                       HD-2  pair guard 위치 = ensure_store_settings
                       HD-3  이번 Gate 는 function-level guard 로 닫는다
                       HD-4  local/dev 로 PASS 를 닫는다
                       HD-5  entry point authority 와 helper pair 책임을 분리한다

blocker status       H03-F1 · H03-F2 두 건
                     H03-F3 latent · OQ-4 별도 finding · OQ-7 구조 관측
function-level pair guard   채택 — HD-3
local/dev verification      채택 — HD-4
```

### §9.2 Human approval required

| # | 승인 항목 | 왜 필요한가 |
|---|---|---|
| `AP-1` | **`OQ-1` runtime representation** — 후보 A · C · D · E 중 택일 (또는 조합) | §8.5. 정책이 단일 후보를 강제하지 않는다. 이것이 정해지기 전에는 `I-1b` 를 코드로 쓸 수 없다 |
| `AP-2` | `AP-1` 선택에서 파생되는 **ACL · wrapper · role 범위** | A → 판정 role 의 EXECUTE · schema USAGE. C → `isolate_tenant` EXECUTE 회수 + wrapper 신설. D → 신규 table/column. E → 기존 표의 용도 재정의 |
| `AP-3` | **`I-1a` 를 어느 entry point 에 거는가** | `HD-5` 가 책임을 분리했으므로 helper pair guard 와 별개 결정이다. 대상 후보는 `update_business_hours` · `toggle_store_mode` · `update_kds_capacity_threshold` 세 entry point |
| `AP-4` | **`R-1` · `R-2` 기대값 반전 수용 여부** | `HD-1` 이 자기 tenant 격리·해제도 권한 없음으로 판정했다. `detect_threat` · `manage_subscription` 이 `42883` 이므로 그 시점에 tenant-wide isolation 발동 경로가 **0이 된다** |
| `AP-5` | **`I-2` 만 먼저 적용할지, `I-1b` 와 함께 갈지** | `I-2` 는 `OQ-1` 에 의존하지 않는다. 쪼개면 `600023` §3.1 PASS 조건을 부분 평가하게 된다 |
| `AP-6` | **migration 번호 배정** | `0178` 이 최신. `0179` 이후 없음 (실측) |

### §9.3 Not authorized yet

```text
migration 생성            없음 — §5
SQL 수정                  없음
함수 수정                  없음
ACL 변경                  없음
wrapper 생성              없음
role 생성                  없음
constraint · trigger 생성  없음 — HD-3 이 이번 Gate 에서 기각
detect_threat 수정         없음 — 별건. 42883 인자명 drift 포함
manage_subscription 수정   없음 — 별건
H03-F3 fix                없음 — latent
OQ-4 fix                  없음 — 별도 finding
merchant_account          없음 — 구조 관측
implementation            없음
```

> ⚠️ **이 문서는 `RG-06` 을 닫지 않았다.**
> **`600023` §3.1 의 두 PASS 조건 중 어느 것도 평가되지 않았다.**
> **`§5` · `§6` · `§7` 이 채워질 때까지 `RG-06` 은 진행 중이다.**

## §10 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `602061_Report_RuntimeGate_Ownership_Chain_Impact_Scope.md` | 전체 — `H-03` · `HD` · verified findings · regression surface | ACTIVE |
| `600023_Governance_Runtime_Gate_Spiral.md` | §3 · §3.1 · §3.2 · §3.3 · §3.4 · §3.5 · §6 | ACTIVE |
| `601902_Register_Stage1_Business_Rules.md` | §1.2 `TI-2` · §1.3 `TI-3` · §1.6 `TI-6` | ACTIVE — CONTRACT FROZEN |
| `601919_Audit_Independent_Foundation_Audit.md` | `H-03` | ACTIVE |
| `602010_Evidence_RuntimeGate_Caller_Tenant_Scope.md` | §9 `RG-F1` · §10.1 `RG-F3` | ACTIVE |
| `602040_Evidence_RuntimeGate_Tenant_Lifecycle_Order_Gate.md` | §3 invariant 인용 선례 | ACTIVE |
| `010004_Policy_SaaS_Tenant_Isolation_...Beam.md` | §7 · §10 · §4.1 | ACTIVE |
| `010630_Policy_Authority_Capability_Gate.md` | §6 · §28 | ACTIVE |
| `010640_Policy_Tenant_Scope_Envelope.md` | §5 · §6 · §8 | ACTIVE |
| `601503_Logic_Operational_Authority_Foundation_Ddl.md` | §9 — 전용 owner role 규칙 (`catchmenu_authority_owner` 실측 근거) | ACTIVE |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §14.5 · §46 | ACTIVE |
| `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql` | `catchmenu_authority_owner` 생성 구문 | 적용됨 |
| `sql/migrations/0173_caller_tenant_scope_remove_claim_exemption.sql` | claim 면제 제거 | 적용됨 |
