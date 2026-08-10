# 601500_Baseline_Summary.md — 0-A 현재 기준선 (Current Baseline)

> **용도**: 며칠 공백 후 이 워크패킷을 다시 이어갈 때 **이 문서만 읽고 복구**하기 위한 1페이지 요약.
> 상세는 각 항목의 참조 문서로 간다. **이 문서와 `601501`(ERD v4)이 충돌하면 `601501`이 우선한다.**
>
> **이 문서가 601500 폴더의 Readme 역할을 겸한다** (2026-08-10 확정) — 폴더번호 슬롯(`601500`)을 사용하며
> 폴더 개요·문서 지도(§7)를 담으므로, `601500_Readme_…`를 **별도로 생성하지 않는다.**
> 워크패킷 진행 상태는 상위 트래커 `600010_Tracker_Spiral_Workpacket_Progress.md`에서 함께 추적된다.

- **워크패킷**: 601500 / 0단계(운영 권위 기반) 하위 나선 **0-A** — Tenant / LegalEntity / HQ / Store
- **Last Updated**: 2026-08-10

---

## 1. 지금 어디까지 왔나

| 항목 | 상태 |
|---|---|
| **현재 Stage** | 13단계 파이프라인 **Stage 8 (Implementation) 완료 → Stage 9 (Independent Verification) 대기** |
| **마이그레이션 파일** | `sql/migrations/0168_create_operational_authority_foundation.sql` — **2026-08-10 로컬 적용 완료, TestPlan §1–§9 전체 PASS** |
| 설계 문서 | `601501`(ERD **v4**) / `601502`(Overview v4) / `601503`(Logic v4) — 3단계 대조 2회 통과 |
| 계약·검증 | `601505`(ChangeContract) — Stage 5 완료 / `601504`(TestPlan) — 2026-08-10 로컬 실행 §1–§9 전체 PASS |

### 다음 즉시 할 일

1. **Stage 9 독립 검증 착수** — 구현과 검증 결과를 독립 검증자에게 인계
2. **Stage 9 독립 검증** — `0168` 구현과 `601504` TestPlan 실행 결과 재검증
3. 0-A 완료 후 `601505` §8A에 따라 **0-A-2를 다음 필수 워크패킷으로 착수**

---

## 2. 확정된 것 (재논의 금지)

### 2.1 데이터 모델

- **Owner(사람)와 LegalEntity(법적 사업주체)를 분리**한다. 둘은 **N:M** (`legal_entity_person_roles` 경유).
- **법적 대표권**은 별도 테이블 `legal_entity_representatives`의 **활성 행 존재 여부**로만 판정한다.
- **`Store → LegalEntity` 단일 경로.** `stores.legal_entity_id` FK **하나**뿐이다.

> ### ⚠️ 흔한 착오 — "Store → Company → LegalEntity 간접 경로"는 **존재하지 않는다**
>
> `companies` 테이블은 **v3에서 폐기**되어 `legal_entities`로 대체됐다. `stores.company_id`도 **없다**
> (`0168` 확인: `legal_entity_id`만 추가됨 — L158, FK L199–200).
>
> **"법인(Company)"은 테이블이 아니라 `legal_entities.entity_type = 'CORPORATION'`이라는 하나의 값**이다.
> 개인사업자·법인·조합·비영리가 전부 같은 테이블의 서로 다른 `entity_type`이다.
>
> Store의 법적 주체 경로를 **직접/간접 두 갈래로 적는 순간 v3/v4가 제거한 결함이 되살아난다** —
> `601501` §0.1 원칙 2는 **"두 갈래 FK 분기 금지"** 를 명시한다. 하나의 사실이 두 곳에 있으면 반드시 갈라진다.

### 2.2 상태 축

- **`tenants.tenant_status`(구독 생명주기)와 `tenants.isolation_state`(보안 격리)는 직교**하며 상호 독립이다.
  `TRIAL`+`ISOLATED` 같은 동시 상태가 표현 가능하다 — 1컬럼 구조에서는 원리적으로 불가능했다.

### 2.3 접근제어

- **신규 4테이블에 GRANT를 부여하지 않는다.** 접근은 **`postgres` 소유 `SECURITY DEFINER` 함수 경유만**.
- 실제 차단자는 RLS가 아니라 **GRANT 부재 + PostgREST 노출 스키마 제한**(`config.toml`에 `catchmenu_hq` 미노출).

### 2.4 범위

- **0-A는 DDL 전용**이다. 신규 테이블 4개 + 신규 컬럼 3개만.
- **RPC 수정(`isolate_tenant`/`manage_subscription`/`detect_threat` 등)은 전부 0-A-2로 이월**한다.

### 2.5 이번에 만드는 것

| 신규 테이블 4개 (`catchmenu_hq`) | 신규 컬럼 3개 |
|---|---|
| `owners` | `tenants.tenant_status` (`NOT NULL default 'TRIAL'`) |
| `legal_entities` | `tenants.isolation_state` (`NOT NULL default 'NONE'`) |
| `legal_entity_person_roles` | `stores.legal_entity_id` (nullable FK) |
| `legal_entity_representatives` | |

---

## 3. 금지된 것 (`601505` §4)

| # | 금지 | 근거 |
|---|---|---|
| 1 | **기존 RPC 본문 수정** (0082/0090/0112/0120/0121/0123/0129/0130/0131) | §4.1 — 0-A-2/0-A-3 소관 |
| 2 | **`franchise_brands` 수정** | §4.2 — 브랜드 축은 미래 나선 |
| 3 | **tenant를 `ACTIVE`로 승격** | §4.3 — 배치가 실제 대상을 갖게 됨 |
| 4 | **아래 7개 함수 호출** (§3.1) | §4.1.1 / §4.5 |
| 5 | **`supabase/config.toml` 수정** | §5 — 접근 경계가 한 줄로 무너짐 |
| 6 | 신규 4테이블에 GRANT 부여 / RLS 정책 생성 | §2.1 / §2.2 |

### 3.1 호출 금지 함수 7개 — `isolate_tenant()` 도달 경로 전체

`isolate_tenant()`는 `tenant_status`에 `'ISOLATED'`를 쓰므로 DDL 적용 후 **23514(CHECK 위반)** 로 실패한다.
직접 호출뿐 아니라 **전이적으로 도달하는 경로 전부**를 막는다.

```text
[1단계 직접]   isolate_tenant()                       0090

[2단계 간접]   manage_subscription()                  0112 L600-606(SUSPEND), L616-620(ACTIVATE)
               detect_threat()                        0121 L876-882 (FATAL 시 자동 격리)

[3단계 전이]   verify_security_token()                0121 L628/662/700  ──┐
               gateway_audit_entry()                  0121 L971/989      ──┤→ detect_threat()
               record_van_transaction()  (payment)    0130 L335          ──┤
               check_staff_permission()  (store)      0131 L462          ──┘
```

> **3단계 전이 경로가 위험한 이유**: `check_staff_permission()`은 **일상적인 권한 검사 함수**다.
> 이런 함수가 `detect_threat()` → `isolate_tenant()`로 이어진다는 것은,
> **평범한 호출이 테넌트 격리를 자동 트리거할 수 있다**는 뜻이다.
> 현재는 전부 dormant(실호출자 0건)이나 그것은 **관측이지 보장이 아니다**.

**현재 모두 도달 불가 — 단 이는 "우연한 방벽" 때문이다** (`601505` §4.5.1):

| 방벽 | 내용 | 오류 |
|---|---|---|
| ① | `manage_subscription()`이 phantom 컬럼 `tenants.company_name` 참조 (0112 L533, 분기 도달 전) | 42703 |
| ② | 호출부 3곳 전부 `p_reason` 사용 — 실제 인자명은 `p_isolation_reason` (0090 L1259) | 42883 |

두 방벽 모두 **고쳐야 마땅한 별개 결함**이므로 언젠가 제거된다.
**제거하는 작업은 반드시 같은 변경에서 `tenant_status`/`isolation_state` 문제를 함께 해결**해야 한다
(`601505` §8A.1 / §8A.2 — 워크패킷 이름이 아니라 **행위**로 규정됨).

---

## 4. Stop 이력 (분류 포함)

| # | 사건 | 분류 | 상태 |
|---|---|---|---|
| 1 | `detect_threat()` — 계약이 놓친 `isolate_tenant()` 호출 경로 발견 → 완전 추적 결과 전이 경로 4개 추가 확인, **전부 dormant** | **`EVIDENCE_GAP`** | **해소** — `601505` §4.1.1에 등재 |
| 2 | `catchmenu_hq` GRANT **112건** 검출 → `grantee <> 'postgres'` 필터 시 **0건** 확인. 112건은 소유자 권한의 카탈로그 자동 노출이었고 설계(`601501` §2.7.1)는 정확했음 | **`TEST_SCOPE_ERROR`** | **해소** — `601504` §1.3(a)/§3.1 쿼리 수정 완료(2026-08-10) |

> **두 사건의 공통 교훈**: 둘 다 **설계 결함이 아니라 "검증 범위" 결함**이었다.
> ①은 금지 목록이 실제보다 좁았고, ②는 체크쿼리가 실제보다 넓었다.
> 그래서 `601505` §7.1은 **"알려진 경로 표를 근거로 grep을 생략하지 말 것"** 을,
> `601504` §1.3.1은 **"소유자 권한을 부여된 GRANT로 오해하지 말 것"** 을 각각 명문화했다.

---

## 5. 미해결 (5단계 착수 전/중 확인 필요)

| # | 항목 | 시점 |
|---|---|---|
| (m) | **클라우드** `pg_cron` 등록 상태 / `pg_cron_jobs` 카탈로그 값 / PostgreSQL 버전 — 로컬만 실측됨 | 5단계 착수 전 |
| (h) | `stores.legal_entity_id` `NOT NULL` 승격 판정 + `stores` INSERT 경로 전수조사 | 5단계 말미 |
| (o) | `SECURITY DEFINER` 소유자 — `0169`가 **`catchmenu_authority_owner`** 신설로 대체. `BYPASSRLS` 회수는 0-C 정책 생성 후 | 0-C |
| (p) | `isolate_tenant()` 호출부 3곳의 파라미터명 불일치 | 0-A-2 / 0121 연동 작업 |
| (n) | `pg_cron_jobs.is_registered` 역논리 결함 | 0-A-2 |

---

## 5A. ⚠️ 다음 나선(0-C) 착수 전 필독 — `601503` §9 게이트

> **Stage 11B(`601510`) 4개 조건 중 ②는 아직 미충족이다.**
> 0-A에는 함수가 하나도 없어 **적용 대상 자체가 없었기 때문**이며,
> **0-C가 이행하지 않으면 영구히 미충족으로 남는다.** 조건 ①③은 `0169`로 충족됐다.

**이 4개 테이블에 접근하는 `SECURITY DEFINER` 함수를 만드는 어떤 작업이든**
— **워크패킷 이름이 "0-C"인지와 무관하게** — `601503` §9의 **필수 6규칙**을 지켜야 한다:

`owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives`

| # | 규칙 |
|---|---|
| 1 | 함수 소유자를 **`catchmenu_authority_owner`** 로 지정 |
| 2 | migration에 **`alter function … owner to catchmenu_authority_owner;`** 명시 |
| 3 | **`revoke all on function … from public;`** 후 필요 role에만 `grant execute` |
| 4 | **`set search_path = catchmenu_hq, pg_catalog`** 고정 (**`public` 제외**) |
| 5 | 모든 테이블·함수 참조를 **schema-qualified** 로 작성 |
| 6 | 함수 내부에서 **호출자 tenant 권한을 명시적으로 검증**(confused deputy 방지) |

### ⚠️ `search_path` 위반이 소유자 위반보다 위험하다

| 위반 | 최악의 결과 |
|---|---|
| 1번(소유자) | 함수가 **동작하지 않음** |
| **4·5번(`search_path`)** | **공격자가 함수 소유자 권한으로 임의 코드 실행**(권한상승 취약점) |

호출자가 자기 `search_path` 앞쪽 스키마에 **동명 가짜 테이블**을 만들면 함수가 그것을 참조한다
(`601510` §3, `601503` §9.2). 따라서 **4·5번을 1번보다 먼저 챙긴다.**

### 함수 생성 후 필수 실행 — `601503` §9.4 CI 검증 쿼리 3종

| # | 검사 | 기대 |
|---|---|---|
| 1 | `SECURITY DEFINER` 함수의 `proowner` / `proconfig` | owner=`catchmenu_authority_owner`, `search_path` 존재·`public` 미포함 |
| 2 | `PUBLIC` EXECUTE 잔존 함수 | **0건** (`proacl`이 `NULL`이면 **기본 PUBLIC 부여** — 위반) |
| 3 | `search_path` 미설정 함수 | **0건** |

> **추가 권고**(0169 Stage 9 검증에서 발견): CI 항목에
> **"`catchmenu_authority_owner`의 멤버가 `postgres` 하나뿐인지"** 를 더할 것.
> `postgres`는 이 role에 `admin_option`을 갖고 있어 다른 role에 부여할 수 있고,
> `authenticated`에 부여되는 순간 §2.3의 접근 경계가 무너진다.

**부수 의존**: 6번의 tenant 검증은 `stores.legal_entity_id`를 경유한다.
**백필 전에는 이 검증이 모든 요청을 거부**하므로 백필(Open Item (h))과의 순서를 확인할 것(`601503` §7 (y)).

---

## 6. 다음 워크패킷

**0-A-2가 다음 필수 착수 워크패킷이다**(`601505` §8A). 다른 도메인(0-B 이후, 1-1 등)보다 먼저다.

이유: 0-A는 `isolate_tenant()`를 **의도적 장애 상태**로 남긴 채 병합된다. 그 상태는 §4의 금지 조항으로
봉인돼 있으나 **봉인은 시간이 갈수록 약해진다** — 사람은 잊고, 새 코드는 계속 들어온다.

---

## 7. 문서 지도

| 무엇을 알고 싶은가 | 어디를 볼 것인가 |
|---|---|
| **0-C에서 `SECURITY DEFINER` 함수를 만들 때 지킬 규칙** | **§5A** → `601503` **§9**(필수 6규칙·표준 골격·CI 쿼리 3종) |
| 테이블 구조·제약·ERD | `601501_ERD_Tenant_Company_HQ_Store.md` (**v5, 설계 원본**) |
| 왜 이 워크패킷이 있는가·범위 절단 | `601502_Overview_...Ddl.md` (v5) |
| 의사 DDL·적용 순서·멱등성·**§9 보안규칙** | `601503_Logic_...Ddl.md` (v5) |
| 무엇을 어떻게 검증하는가 | `601504_TestPlan_...Ddl.md` |
| 무엇이 허용/금지인가·Stop Condition | `601505_ChangeContract_...Ddl.md` |
| 실제 DDL | `sql/migrations/0168_create_operational_authority_foundation.sql` |
| 나선 방법론(§47)·증거수집(§48) | `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` |
