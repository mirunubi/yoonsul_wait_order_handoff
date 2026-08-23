# 601716_TestPlan_Operational_Authority_Foundation_V2.md

Status: Draft
Lifecycle: TestPlan
Gate Classification: 0-A v2 Operational Authority Foundation Test Plan Draft
Runtime Implementation Authorization: Not Granted
Owner: Stage 5 (Claude Code) — 2026-08-23 재도출. 종전 판(Claude 작성)은 candidate reference
Last Updated: 2026-08-22

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-22 | 초안 — 4단계 TestPlan |
| 2026-08-22 | 2판 — B-1 · B-7 해소. 대상 2·3·4 BLOCKED 해제 |
| 2026-08-22 | 3판 — §1.37 보강·§1.45 반영. backfill 이 검증 대상에 편입 |
| 2026-08-22 | **4판** — `601718`/`601719` write-path 실측 반영. **N-5 해소**, C-1 이 `DEFERRED — INELIGIBLE` 로 확정됨에 따라 **두 INSERT RPC 무변경 검사(TP-N-50~53) 신설**. 신규 blocker 2건 |
| 2026-08-23 | **8판** — **Stage 7 Human Approval 반영**(정영석, 2026-08-23). **TP-M-08 을 clean baseline replay 로 축소**(B-7 CLOSED). 검증 환경을 `postgres:17.6.1.140` 으로 고정(B-8 CLOSED). B-9 DEFERRED. A-3 Module 파일명 `601722` 확정 반영 |
| 2026-08-23 | **7판** — **Stage 7 승인 항목 4번(컬럼명·타입) Human 확정** 반영. `merchant_account_name` 확정, 컬럼 5개·타입·제약이 기대값이 됨(§4.3 종속 해제). **N-3′ CLOSED**. TP-N-60·TP-D-09 신설, H-5(name synchronization) 이월 기록 |
| 2026-08-23 | **6판** — Stage 7 사전 측정(`601720`/`601721`) 반영. **PRE-5·6·7 값을 기대값으로 확정**(tenants 1행 / stores 16컬럼 / 두 RPC md5). **N-2″ 확정** — 기준선 기록이 정확했고 RPC 가 phantom 참조. TP-RT-03 정정 — `create_franchise_store` 는 이미 실패 상태. 신규 blocker 2건 |
| 2026-08-22 | **5판** — **N-5′ 해소**(`601713` I-43~I-51·§1.5·Q-10 / `601710` §2.3·§2.4 / `601705` §4.1·§4.4·§8·O20). 기대값 근거를 선언 단독에서 **Logic 불변조건**으로 전환. I-47 검사(TP-D-08) 신설. 신규 blocker 1건 |
| 2026-08-23 | **9판 — Stage 5 재도출 (Claude Code).** verified design(`601702`/`601705`/`601710`/`601713`) 및 증거 문서에서 TestPlan 을 다시 도출. **substantive change 없음**, governance correction 2건 — §0.3 |
| 2026-08-23 | **10판 — Stage 6 findings 반영.** Codex F-1~F-7 처분(`601724`), Cursor informational 3건 처분(`601723`), **TP-RT-03 폐기 → TP-N-62~64 negative 대체**(F-5), COMMENT 검사 TP-P-38 신설(F-2), B-8 문면 정정(F-4), N-2″ 미판정 서술 철회(F-3), 신규 blocker N-6″~N-8″. **Stage 6 재검증 필요** |
| 2026-08-23 | **11판 — Stage 6 Round 2 findings 반영.** R2-F1(`CREATE UNIQUE INDEX` 잔존 제거) · R2-F2(COMMENT exact literal) · R2-F3(TP-N-63 정적 증거로 재정의) · R2-F5(AC 보강) · R2-F6(Test ID 범위 갱신). **Round 3 재검증 필요** |

**Stage 5 Provenance**

| 구분 | 일자 | 내용 |
|---|---|---|
| Stage 5 재도출 | 2026-08-23 | Claude Code. 종전 판(Claude 작성)은 candidate reference |

## §0 성격과 저자

`000001` §5.4.4 TestPlan 이다. **구현을 승인하지 않는다.**

**저자 분리**(`000001` §5.4.2)

| 산출물 | 저자 |
|---|---|
| ERD `601705` / Overview `601710` / Logic `601713` | Claude Code |
| 선언 `601702` | Human |
| **TestPlan `601716` / ChangeContract `601717`** | **Claude Code (2026-08-23 재도출).** 종전 판은 Claude 작성 — candidate reference |

### §0.1 3판 → 4판 — 측정이 들어왔다

**측정이 하나 들어왔다.** `601718`(Cursor) / `601719`(Codex)가
**상대 결과를 참조하지 않고 동일 수치에 도달**했다(`000701` §35).

```text
stores 참조 함수         158        (601701 D-3 은 151 — 601702 §2.2 에 기록됨)
INSERT 경로               2         provision_tenant / create_franchise_store
  둘 다 COLUMN_LIST
  둘 다 merchant_account_id 를 공급하지 않는다
NO_COLUMN_LIST            0
ROW_TYPE                  0
SELECT * · 행 타입 의존    0
앱 코드 직접 INSERT        0
UPDATE 경로               2         onboard_tenant(brand_id) / update_business_hours
stores 트리거            241        internal 240 + user 1
stores 참조 view/matview   0 / 0
```

| 3판 blocker | 판정 |
|---|---|
| **N-5** `stores` 참조 함수 형태 미측정 | **해소** — `SELECT *`·`ROW_TYPE`·`NO_COLUMN_LIST` 전부 0건 |
| **N-1′** C-1 승격 가부 미판정 | **판정 가능해졌고, 결과는 부적격이다** — `601717` §4.4 |

### §0.1.1 4판 → 5판 — 설계 문서가 선언을 따라잡았다

**4판이 기록한 N-5′ 가 해소됐다.**

| 문서 | 반영 내용 |
|---|---|
| `601713` Logic | **I-43~I-46**(트리거명 · `person_name` · `set_updated_at()` 유지 · role 명 유지) · **I-47~I-51**(존재 조건 · backfill · 1:1 강제 방향 · 배치 · fail-closed) · §1.1 `owner_` 검증 범위 주석 · **§1.5 write-path 실측 승계** · §6 **Q-10**(합계 10건) |
| `601710` Overview | §2.3 에 §1.37 보강 · §1.45 행 · **§2.4 신설** — write-path 실측을 기록하되 **「구현 대상을 바꾸지 않는다」** 를 명시 |
| `601705` ERD | §4.1 PERSON · §4.4 MERCHANT_ACCOUNT · §8 Physical Drift · **O20**(`stores.merchant_account_id` NOT NULL → 후속 RPC alignment 나선) |

**이 TestPlan 의 기대값 근거가 바뀌었다.**

```text
4판까지   TP-P-25 ~ 37 · TP-D-01 ~ 07 의 근거 = 선언(§1.44 · §1.45)
5판       근거 = 선언 + Logic 불변조건(I-43 ~ I-51)
```

**기대값 자체는 하나도 바뀌지 않았다.** 같은 값이 이제 Logic 을 경유해 지지된다.

> ⚠️ **I-47 만은 검사 방식에 주의가 필요하다.**
> 「Tenant 만 존재하고 MerchantAccount 가 없는 상태를 정상 운영 상태로 허용하지 않는다」는
> **검증 시점 상태로는 만족되지만**(backfill 이 기존 Tenant 전부를 덮으므로)
> **강제 장치가 없다.** TP-D-08 이 상태를 검사하고, 강제 부재는 §12.3 N-1″ 다.
> **I-47 을 「강제되어야 한다」로 읽고 FAIL 판정하면 `601717` §1.5 이월을 뒤집는 것이 된다.**

### §0.1.2 5판 → 6판 — 사전 측정이 기대값을 상수로 만들었다

`601720`(Cursor) / `601721`(Codex)가 **동일 수치에 도달**했다(`000701` §35).

| 항목 | 실측 | 이 TestPlan 에의 반영 |
|---|---|---|
| PRE-5 `tenants` 행 수 | **1** | BL-24 after = **1** |
| PRE-6 `stores` 컬럼 수 | **16** (`601701` 기록과 차이 0) | BL-21 before = **16**, after = **17** |
| PRE-6 `stores.brand_id` / `extra_metadata` | **둘 다 부재** | N-2″ 확정 — §12.1 |
| PRE-7 `provision_tenant` md5 | `f84ac1a81da4ccba87930bf020a3e974` | TP-N-50 기대값 |
| PRE-7 `create_franchise_store` md5 | `87511a95676a41d2c95866e0c2da8b7f` | TP-N-51 기대값 |

**N-2″ 확정 — 5판이 남긴 두 가능성 중 두 번째다.**

```text
컬럼이 실재한다   →  601701 기록이 불완전하다     ❌ 아니다 (차이 0)
컬럼이 없다       →  RPC 가 phantom 을 참조한다   ⭕ 이것이다
```

| 함수 | phantom 참조 | 현재 호출 |
|---|---|---|
| `catchmenu_common.provision_tenant` | 없음 | **정상** |
| `catchmenu_hq.create_franchise_store` | `extra_metadata` (INSERT 주 경로) | **실패** |

> ⚠️ **TP-RT-03 을 정정했다.**
> 5판까지 「두 INSERT RPC 가 여전히 성공적으로 실행 가능」을 기대값으로 두었는데,
> **`create_franchise_store` 는 이 구현 이전부터 실패한다.**
> 그대로 두면 이 항목은 구현과 무관하게 항상 FAIL 한다 — §10 참조.

> ⚠️ **`brand_id` 는 이 측정이 답하지 않았다.**
> `601718` S-4 / `601719` S-4 가 `catchmenu_common.onboard_tenant` 의
> `update catchmenu_hq.stores set brand_id = …` 를 전문과 함께 기록했으나,
> `601720`/`601721` 의 `prosrc` 토큰 검사는 **두 INSERT RPC 만** 대상으로 했다.
> **`onboard_tenant` 는 재측정되지 않았다** — §12.3 N-5″.

### §0.2 이 TestPlan 이 검사하는 것은 **현재 계약**이다

> ⚠️ **미래 목표를 검사하지 않는다.**
>
> `stores.merchant_account_id` `NOT NULL` 은 **살아 있는 장기 invariant** 이며
> (`601702` §1.26·§1.45 / `601713` I-27),
> `601717` §1.5 가 이를 **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** 로 확정했다.
>
> ```text
> 검사한다        NOT NULL 을 선행 강제하지 않았는가          (negative)
> 검사한다        두 INSERT RPC 를 임의 수정하지 않았는가      (negative)
> 검사한다        backfill 이 원천 행 수와 일치하는가          (data)
>
> 검사하지 않는다  NOT NULL 이 걸려 있는가                    ← 후속 나선의 목표
> 검사하지 않는다  두 RPC 가 merchant_account_id 를 공급하는가  ← 후속 나선의 목표
> ```
>
> **이 TestPlan 이 미래 목표를 검사하면, 이번 구현은 통과할 수 없는 시험을 받게 된다.**
> 반대로 미래 목표를 지워버리면 요구 자체가 사라진 것으로 읽힌다 —
> 그래서 **금지(negative)로 검사하고 §12.4 에 이월로 남긴다.**

**이 TestPlan 이 하지 않는 것**

| # | 하지 않는 것 | 소관 |
|---|---|---|
| 1 | 새 정책 결정 | Human (`601702`) |
| 2 | 물리 변경 방법·필드명·타입 판정 | ChangeContract `601717` |
| 3 | 허용·금지 파일 확정 | `601717` §1·§5 |
| 4 | 남은 모순의 해소 | §12 에 기록만 |
| 5 | DB 재조회 | `601701`/`601711`/`601712`/`601714`/`601715`/`601718`/`601719`/**`601720`**/**`601721`** 이 이미 수행 |

### §0.3 8판 → 9판 — Stage 5 재도출 대조 (2026-08-23, Claude Code)

**이 판은 후보본을 승인한 것이 아니라 다시 도출한 것이다.**

`000701` Stage 5 는 Contract Drafting 을 **Claude Code** 에 지정한다.
종전 판은 Claude 가 작성했고 근거로 삼은 `000001` §5.4.2 는
**2026-07-16 이전 번호 체계**다(`000701` 1096행). 그 결과 Claude 가 원작자가 되어
`000701` §37 상 **Stage 6 통합자 역할을 수행할 수 없는 상태**였다
— `601717` §10 무효화 배너 사유 4.

**재도출 근거 (authority)**

```text
선언      601702 §1.22~§1.27 · §1.31 · §1.34 · §1.37(보강) · §1.38 · §1.39
                 §1.43 · §1.44 · §1.45 · §2.1 · §2.2 · §5
설계      601705 §4.1 · §4.4 · §4.6 · §5.2 · §8 · §10(O18~O20)
          601710 §2 · §2.1~§2.4 · §3 · §3.1 · §4 · §5 · §7
          601713 I-1~I-51 · E-1~E-4 · X-1~X-11 · §6(Q-1~Q-10)
증거      601711 · 601712    Person 물리 기준선 (이중)
          601714 · 601715    갭 해소 실측 (이중)
          601718 · 601719    stores write-path (이중)
          601720 · 601721    Stage 7 사전 측정 (이중)
계약      601717 §1 · §4 · §5 · §6 · §7 (9판, 동일 재도출)
Human     601717 §10.1 pre-decision 9건
```

**대조 결과 — substantive change 없음**

| 대상 | 재도출 결과 |
|---|---|
| §1 Test Scope | 동일 — Overview §2 대상 5건 그대로 |
| §2.1 기준선 BL-1~BL-38 | 동일 — 증거 문서 재대조 결과 값 변동 0 |
| §4 Positive TP-P-01~TP-P-38 | 동일 — **TP-P-38 은 10판 신설(F-2), R2-F2 로 literal 확정** |
| §4.4 backfill TP-D-01~TP-D-09 | 동일 |
| §5 Negative TP-N-01~TP-N-64 | 동일 — **TP-N-62~64 는 10판 신설(F-5), TP-N-63 은 11판 재정의(R2-F3)** |
| §6 Regression TP-R-01~TP-R-20 | 동일 |
| §7 External TP-X-01~TP-X-13 | 동일 |
| §8·§9·§10·§11 | 동일 |
| §12 blocker · 이월 | 동일 — **C-1·C-2 를 `RESOLVED` 로 바꾸지 않았다** |
| §13 Acceptance Criteria | 동일 |

**재대조한 실측값** — 두 조사가 독립적으로 같은 값을 기록함을 확인했다(`000701` §35).

```text
stores 참조 함수        158     601718 L55 / 601719 L51
INSERT 경로              2      둘 다 COLUMN_LIST, merchant_account_id 미공급
NO_COLUMN_LIST / ROW_TYPE 0/0   601718 S-2 / 601719 S-2
stores 트리거          241      601718 S-6
tenants 행 수            1      601720 PRE-5 / 601721
stores 컬럼 수          16      601720 PRE-6 (brand_id · extra_metadata 부재)
provision_tenant md5    f84ac1a81da4ccba87930bf020a3e974 (4758)
create_franchise_store  87511a95676a41d2c95866e0c2da8b7f (3460)
```

**governance correction 2건** — 정책 결정이 아니라 문서 상태 정합화다.

| # | 지점 | 종전 | 재도출 | 근거 |
|---|---|---|---|---|
| G-1 | 헤더 `Owner` · §0 저자 분리 표 | Claude (본 문서 저자) | Claude Code 재도출 | `000701` Stage 5 |
| G-3 | §2 PRE-1 | Stage 7 = `APPROVED_FOR_IMPLEMENTATION` 을 전제값으로 서술 | 현재 Stage 7 = **대기** 를 반영 | `601717` §10 무효화 배너 — Stage 8 `MUST NOT START` |

> ⚠️ **G-3 은 기대값이 아니라 사실 서술의 정정이다.**
> PRE-1 은 원래도 「Stage 7 승인이 없으면 착수 금지」 게이트였고 그 동작은 바뀌지 않는다.
> 다만 종전 문면이 **승인이 이미 존재한다**고 단정해
> `601717` §10 무효화 배너와 어긋났다.

> **§12.1 의 「CLOSED by Stage 7 Decision」 · §12.4 의 「Stage 7 APPROVED」 표기는 그대로 둔다.**
> 그 내용은 `601717` §10.1 Human pre-decision 이며,
> 배너가 **재승인 시 그대로 승계**한다고 명시했다. 표기를 지우면 다시 논쟁 대상이 된다.

**이 재도출이 하지 않은 것**

```text
새 정책 결정                  없음
기대값 변경                   없음
C-1 · C-2 의 RESOLVED 전환    없음
601717 §10.1 9건 변경         없음
601717 §10 무효화 배너 변경    없음
Stage 6 상태 변경             없음 — 대기 유지
```

## §1 Test Scope

| Overview §2 대상 | 취급 | 3판 대비 |
|---|---|---|
| 1. canonical `Person` 물리 표현 | **전면 검증** (§4.1) | 변동 없음 |
| 2. persistent `MerchantAccount` | **전면 검증 + backfill 검증** (§4.2·§4.4) | 변동 없음 |
| 3. Tenant ↔ MerchantAccount (1:1) | **전면 검증** (§4.2) | 변동 없음 |
| 4. MerchantAccount → Store (1:N) | **구조 + backfill 검증. enforcement 는 negative** (§4.2·§4.4·§5.6) | **C-1 이 이월로 확정** — negative 가 잠정이 아니라 계약 조항이 됐다 |
| 5. Store–LegalEntity target invariant | **negative 검증만** (§5.4) | 변동 없음 |

## §2 Preconditions

| # | 전제 | 확인 방법 | 미충족 시 |
|---|---|---|---|
| PRE-1 | `601717` §10 Stage 7 이 승인 상태 — **2026-08-23 현재 「대기」이며 착수 조건 미충족**(§10 무효화 배너) | 문서 확인 + G15 | 착수 금지 |
| PRE-2 | §12 blocker 중 착수 범위에 걸린 것이 해소 또는 명시적 제외됨 | Approval | 해당 범위 제외 |
| PRE-3 | **환경이 `postgres:17.6.1.140` 이고 최신 migration 이 `0169`** | 이미지 태그 + `migration_history` 상위 1행 | **environment drift — 구현하지 않고 중단**(`601717` §10.3) |
| PRE-4 | 기준선 재측정 완료 (§2.1) | 아래 표 | 사후 비교 불가 |
| PRE-5 | **`tenants` 행 수 = 1 확인** (`601720`/`601721`) | `select count(*) from catchmenu_hq.tenants` | **environment drift — 구현하지 않고 중단** |
| PRE-6 | **`stores` 컬럼 수 = 16 확인** (`601720`/`601721`) | `information_schema.columns` | **environment drift — 구현하지 않고 중단** |
| PRE-7 | **두 INSERT RPC 의 `prosrc` md5 가 `601720`/`601721` 기록값과 동일** | `md5(prosrc)` 대조 | **environment drift — 구현하지 않고 중단** |
| PRE-8 | 검증자가 원작자가 아님 (`000701` §37) | 지시문 서두에 원작자 명시 | 검증 무효 |

> **PRE-3·PRE-5~PRE-7 은 Stage 7 승인 항목 8 이 확정한 environment drift 게이트다.**
>
> ```text
> 기준 환경   postgres:17.6.1.140 / migration 0169 / tenants = 1 / stores = 1
> 불일치 시   구현하지 않고 중단한다
> ```
>
> **`601714`/`601715`(`.156`)의 증거를 폐기하는 것이 아니다.**
> 그 조사가 답한 Q-2~Q-5·Q-8 은 유효하며, **PASS/FAIL 기준 환경이 `.140` 이라는 뜻**이다.

### §2.1 기준선 — 사후 비교용 실측값

| # | 항목 | before | after | 출처 |
|---|---|---|---:|---|
| BL-1 | `owners` 행 수 | 0 | 0 | `601711`/`601712` P-3 |
| BL-2~4 | `legal_entity_person_roles` / `legal_entity_representatives` / `legal_entities` 행 수 | 0 | 0 | 동일 |
| BL-5 | `stores` 행 수 | 1 | 1 | `601701` D-3 / **`601718`·`601719` 재확인** |
| BL-6 | `stores.legal_entity_id` NOT NULL 행 수 | 0 | 0 | `601701` D-3 |
| BL-7 | `catchmenu_hq` BASE TABLE 수 | 20 | **21** | `601714`/`601715` |
| BL-8 | `owners` 참조 FUNCTION | 0 | 0 | `601711` P-1 / `601714` Q-4 |
| BL-9 | `owners` 참조 VIEW / MATVIEW | 0 | 0 | `601711` P-1 |
| BL-10 | `owners` RLS 플래그 | `ENABLE`+`FORCE` | 동일(대상 `persons`) | `601711` P-1 |
| BL-11 | `owners` GRANT (grantee ≠ postgres) | 4, `is_grantable=NO` | 4 | `601711` P-1 |
| BL-12 | `set_updated_at()` 호출 non-internal 트리거 | 114 | **115** | `601714`/`601715` Q-3 |
| BL-13 | Person 계열 참조 **타 스키마** FK | 0 | 0 | `601714`/`601715` Q-4 |
| BL-14 | Person 계열 참조 동일 스키마 FK | 5 | 5 | `601714` Q-4 |
| BL-15 | 이름에 `merchant` 가 든 **테이블** | 0 | **1** | `601714`/`601715` Q-5 |
| BL-16 | 이름에 `merchant` 가 든 **컬럼** | 5 | 선언된 증가분만 | 동일 |
| BL-17 | 앱·패키지·테스트·seed 의 `owners` 참조 | 0 | 0 | `601711`/`601712` P-5 |
| BL-18 | `chk_lepr_role_type` 허용값 | 5개 | 동일 | `601714`/`601715` Q-2 |
| BL-19 | `owners` CHECK 제약 | 0 | 0 | 동일 |
| BL-20 | `catchmenu_hq.tenants` | 10컬럼, **1행**, RLS ENABLE+FORCE | 무변경 | `601701` E단계 / **`601718`·`601719` 행수 재확인** |
| BL-21 | **`catchmenu_hq.stores` 컬럼 수** | **16** (`601701` 기록과 차이 0) | **17** | `601701` E단계 / **`601720`·`601721` PRE-6** |
| BL-22 | **`stores` 를 직접 참조하는 FUNCTION** | **158** (`601701` 기록은 151 — `601702` §2.2) | **158** | **`601718` S-1 / `601719` S-1** |
| BL-23 | `tenants` 를 직접 참조하는 FUNCTION | 10 | 10 | `601701` E단계 |
| BL-24 | `merchant_accounts` 행 수 | (테이블 없음) | **1** (= `tenants` 행 수) | §1.45 / **`601720`·`601721` PRE-5** |
| BL-25 | `stores.merchant_account_id` NOT NULL 행 수 | (컬럼 없음) | **1** (= `stores` 행 수) | §1.45 파생 — N-2′ |
| BL-26 | `stores.updated_at` | 기존 값 | **변경됨** (M-2 가 `trg_stores_updated_at` 발동) | N-4′ |
| BL-27 | `tenants.tenant_status` / `isolation_state` | `TRIAL` / `NONE` | 무변경 | `601701` / `601505` §4 |
| **BL-28** | **`stores` 에 INSERT 하는 FUNCTION** | **2** — `catchmenu_common.provision_tenant` / `catchmenu_hq.create_franchise_store` | **2, 본문 불변** | **`601718` S-2 / `601719` S-2** |
| **BL-29** | **`NO_COLUMN_LIST` / `ROW_TYPE` INSERT** | **0 / 0** | 0 / 0 | 동일 |
| **BL-30** | **`SELECT *` · 행 타입 의존 함수** | **0** | 0 | **`601718` S-3 / `601719` S-3** |
| **BL-31** | **`stores` 를 UPDATE 하는 FUNCTION** | **2** — `catchmenu_common.onboard_tenant`(`brand_id`) / `catchmenu_store.update_business_hours` | **2, 본문 불변** | **`601718` S-4 / `601719` S-4** |
| **BL-32** | **앱 코드 `stores` INSERT** | **0** | 0 | **`601718` S-5 / `601719` S-5** |
| **BL-33** | **`stores` 트리거** | **241** (internal 240 / user 1 `trg_stores_updated_at`) | **241** | **`601718` S-6** |
| **BL-34** | **`stores` 참조 VIEW / MATVIEW** | **0 / 0** | 0 / 0 | **`601718` S-6 / `601719` S-6** |
| **BL-35** | **`provision_tenant` `prosrc` md5 / len** | **`f84ac1a81da4ccba87930bf020a3e974` / 4758** | **동일** | **`601720`·`601721` PRE-7** |
| **BL-36** | **`create_franchise_store` `prosrc` md5 / len** | **`87511a95676a41d2c95866e0c2da8b7f` / 3460** | **동일** | 동일 |
| **BL-37** | **`stores.brand_id` · `stores.extra_metadata` 컬럼** | **둘 다 부재** | **둘 다 부재** | **`601720`·`601721` PRE-6** |
| **BL-38** | **`catchmenu_hq.tenants.tenant_name`** | `text NOT NULL`, 1행 | **무변경** | `601701` E단계 — TP-D-04 의 원천 |

> **BL-21·BL-24 는 6판에서 상수가 됐다.**
> `601720`/`601721` 이 `tenants` 1행 · `stores` 16컬럼을 확정했으므로 기대값은 1 과 17 이다.
> **다만 PRE-5·PRE-6 을 전제로 남긴다** — 다른 환경이면 이 상수가 틀리기 때문이다(§12.2 B-8).

> ⚠️ **BL-22 의 두 숫자를 함께 남긴다.**
> `601701` D-3 = 151, `601718`/`601719` = 158, 차이 +7.
> `601702` §2.2 가 이를 **미결 항목으로 기록하되 C-1 판정에는 영향 없음**으로 판정했다
> (INSERT 2건은 두 조사가 일치). **이 TestPlan 은 live 값 158 을 기준선으로 쓴다.**

### §2.2 조사 환경

| 조사 | 이미지 | 최신 migration | `stores` / `tenants` 행 수 |
|---|---|---|---|
| `601701` / `601711` / `601712` | `postgres:17.6.1.140` | `0169` | 1 / 1 |
| `601714` / `601715` | `postgres:17.6.1.156` | `0169` | — |
| **`601718` / `601719`** | **`postgres:17.6.1.140`** | **`0169`** | **1 / 1** |

> **write-path 조사가 `.140` 에서 수행되어 `601701` 과 같은 환경이다.**
> 두 환경이 존재한다는 사실은 기록으로 남긴다. **B-8 자체는 CLOSED 다**(F-4 처분) —
> Stage 7 승인 항목 8 이 기준 환경을 `postgres:17.6.1.140` / `0169` / `tenants`=1 · `stores`=1 로
> 확정했고 PRE-3·PRE-5~7 이 그 게이트다(§12.1). **「여전히 미해소」 서술은 철회한다.**

## §3 Test ID 체계

```text
TP-P-nn   Positive        목표 상태가 실제로 만들어졌는가
TP-N-nn   Negative        만들지 않기로 한 것이 만들어지지 않았는가
TP-D-nn   Data            backfill 이 선언된 파생인가
TP-R-nn   Regression      건드리지 않기로 한 것이 그대로인가
TP-B-nn   Boundary        허용·금지 파일 경계
TP-M-nn   Migration       migration 파일 규격
TP-X-nn   External        External Provider Mapping negative (§7)
TP-RB-nn  Rollback        되돌릴 수 있는가
```

**판정값은 PASS / FAIL / BLOCKED 셋뿐이다.** `BLOCKED` 는 PASS 가 아니다.

## §4 Positive Tests

### §4.1 대상 1 — canonical `Person`

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-P-01 | `catchmenu_hq.persons` 가 BASE TABLE 로 존재 | 1건 | §1.1·§1.37 |
| TP-P-02 | `persons` PK 가 `id uuid` 단일 컬럼 | 1건 | I-9 |
| TP-P-03 | `legal_entity_person_roles.person_id` 존재 | 1건 | I-34 |
| TP-P-04 | `legal_entity_representatives.person_id` 존재 | 1건 | 동일 |
| TP-P-05 | 두 FK 가 **동시에** `persons.id` 를 참조 | 2건 | I-1·I-2, X-1 |
| TP-P-06 | 두 FK 의 `ON DELETE`/`ON UPDATE` 가 `NO ACTION` | 2건 모두 | I-3, X-2 |
| TP-P-07 | FK 제약명이 `..._person_id_fkey` | 2건 | §1.37 |
| TP-P-08 | 트리거명이 `trg_persons_updated_at` 이고 `set_updated_at()` 호출 | 1건 | §1.37 보강 / **I-43** |
| TP-P-09 | `uq_lepr_active` 정의가 `(legal_entity_id, person_id, role_type)` active 부분 unique | 1건 | I-5, X-4 |
| TP-P-10 | `uq_ler_active` 정의가 `(legal_entity_id, person_id)` active 부분 unique | 1건 | I-6, X-4 |
| TP-P-11 | `uq_ler_sole_active` 존재·정의 불변 | 1건 | I-7, X-4 |
| TP-P-12 | Person 기준 역할 조회 인덱스 존재, 이름이 `person` 기준 | 1건 | I-8, §1.37 |
| TP-P-13 | `persons` PK 인덱스명이 `person` 기준 | 1건 | §1.37 |
| TP-P-14 | `persons` RLS 가 `ENABLE` **그리고** `FORCE` | 둘 다 true | I-10, X-6 |
| TP-P-15 | `catchmenu_authority_owner` → `persons` GRANT 4건, `is_grantable=NO` | 4건 | I-12, X-7 |
| TP-P-16 | 소유자(`postgres`) 기본 privilege 구성 불변 | BL-11 대비 동일 | I-13 |
| TP-P-17 | `persons.is_active` 가 존재하지 않는다 | 0건 | I-36 / §1.38 |
| TP-P-18 | `persons.person_name` 이 존재하고 `NOT NULL` | 1건 | §1.37 보강 / **I-44** |
| TP-P-19 | `persons` 가 **6컬럼** | 6컬럼 | I-14(I-36 으로 대체) ∩ §1.37 보강 |
| TP-P-20 | `legal_entity_person_roles.ownership_percent` 가 존재하지 않는다 | 0건 | I-37 / §1.39 |
| TP-P-21 | `chk_lepr_ownership_percent` 가 존재하지 않는다 | 0건 | I-37 |
| TP-P-22 | `legal_entity_representatives` 테이블명 유지 | 유지 | I-35 |
| TP-P-23 | `persons` 테이블 코멘트가 **`Canonical natural persons who hold operational or legal authority for legal entities.` 와 문자열 동일** | 완전 일치 | I-15 / **`601717` D-13 · §4.2.1 (F-2 · R2-F2 처분)** |
| TP-P-24 | canonical schema 에 `owner_` 로 시작하는 식별자 0건 | 0건 | §1.37 「검증 범위」 / **`601713` §1.1 주석** |

> ⚠️ **TP-P-24 의 범위는 §1.37 이 명시적으로 좁혔다.**
> 검사 대상은 **0-A 이후 canonical physical object** 뿐이며,
> **역사 문서·과거 migration 파일은 제외**한다.
> `catchmenu_authority_owner` role 과 `catchmenu_common.set_updated_at()` 도 제외 대상이다.

### §4.2 대상 2·3·4 — `MerchantAccount` 구조

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-P-25 | `catchmenu_hq.merchant_accounts` 가 BASE TABLE 로 존재 | 1건 | §1.45 「배치」 / **I-50** |
| TP-P-26 | **`merchant_accounts.id`** 가 `uuid` PK, `NOT NULL`, `DEFAULT gen_random_uuid()` | 일치 | **`601717` §4.1 Stage 7 확정** |
| TP-P-27 | `merchant_accounts.tenant_id` 가 `uuid` 이며 `catchmenu_hq.tenants(id)` 를 FK 참조, **`ON DELETE NO ACTION` / `ON UPDATE NO ACTION`** | 일치 | §1.45 / **§4.1 확정** |
| TP-P-28 | `merchant_accounts.tenant_id` 가 `NOT NULL` | 참 | 동일 |
| TP-P-29 | `merchant_accounts.tenant_id` 에 **`UNIQUE` 제약**(제약명 `uq_merchant_accounts_tenant`) 존재 — **unique index 단독 형태는 FAIL** | 1건 | 동일 — 1:1 강제 / **I-49** / **`601717` D-15 (F-1 처분)** — 계약이 허용 형태를 제약 하나로 좁혔다 |
| TP-P-30 | **컬럼명이 정확히 `merchant_account_name`** 이고 `text NOT NULL` | 일치 | **§4.1 확정** — `<entity>_name` 관례 |
| TP-P-31 | `created_at` / `updated_at` 이 `timestamptz NOT NULL DEFAULT now()` | 2건 일치 | **§4.1 확정** |
| TP-P-32 | `merchant_accounts` 에 `BEFORE UPDATE` 트리거 존재, `set_updated_at()` 호출 | 1건 | §1.44 |
| TP-P-33 | `merchant_accounts` RLS 가 `ENABLE` **그리고** `FORCE` | 둘 다 true | §1.45 fail-closed / **I-51** |
| TP-P-34 | `stores.merchant_account_id` 가 존재하고 `merchant_accounts` 를 FK 참조 | 1건 | §1.26·§1.43 |
| TP-P-35 | 그 FK 의 `ON DELETE`/`ON UPDATE` 가 `NO ACTION` | 참 | `fk_stores_legal_entity_id` 관행 |
| TP-P-36 | `stores.merchant_account_id` 조회 인덱스 존재 | 1건 | `idx_stores_legal_entity_id` 관행 |
| TP-P-37 | `merchant_accounts` 와 `tenants` 가 별도 테이블로 유지 | 2건 | I-23 |
| **TP-P-38** | **아래 3건의 COMMENT 가 `601717` §4.2.1 확정 literal 과 문자열 동일** — `merchant_accounts` = `CatchMenu SaaS contract and management account. One-to-one with tenant.` / `merchant_accounts.tenant_id` = `Owning tenant. NOT NULL and UNIQUE; this column alone enforces the 1:1 relationship.` / `stores.merchant_account_id` = `Structural parent merchant account. Nullable in this contract; NOT NULL is deferred (C-1).` | 3건 모두 완전 일치 | **`601717` D-21 · §4.2.1 (F-2 · R2-F2 처분)** — 종전에는 literal 이 확정되지 않아 문자열 동일 검사가 성립하지 않았다 |

### §4.3 판정값이 ChangeContract 에 종속되는 항목

**6판까지 이 절은 「기대값을 나중에 확정하라」였다. 7판에서 해소됐다.**

Stage 7 승인 항목 4번이 처리되어 `601717` §4.1 이 **Human 확정값**이 됐다.
TP-P-26~TP-P-31 은 이제 **확정 기대값**이며, 실행 전에 별도로 확정할 것이 없다.

| 컬럼 | 확정 기대값 |
|---|---|
| `id` | `uuid NOT NULL DEFAULT gen_random_uuid()` PRIMARY KEY |
| `tenant_id` | `uuid NOT NULL UNIQUE`, FK → `catchmenu_hq.tenants(id)`, `NO ACTION`/`NO ACTION` |
| `merchant_account_name` | `text NOT NULL` |
| `created_at` | `timestamptz NOT NULL DEFAULT now()` |
| `updated_at` | `timestamptz NOT NULL DEFAULT now()` |

**`stores.merchant_account_id`(TP-P-34)의 타입은 `merchant_accounts.id` 를 따라 `uuid` 다.**

### §4.4 backfill — 선언된 파생인가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-D-01 | `merchant_accounts` 행 수 = **`tenants` 행 수** | 일치 (PRE-5 재측정값) | §1.45 / **I-48** |
| TP-D-02 | 모든 `tenants.id` 가 정확히 1개의 `merchant_accounts` 행과 대응 | 누락 0 · 중복 0 | §1.45 — 1:1 / **I-47 · I-49** |
| TP-D-03 | 대응 `tenants` 행이 없는 고아 `merchant_accounts` 행 0건 | 0건 | §1.45 |
| TP-D-04 | **모든 `merchant_accounts.merchant_account_name` 이 대응 `tenants.tenant_name` 과 문자열 동일** | 전 행 일치 | **`601717` §4.5.1 확정 구문** — N-3′ CLOSED |
| **TP-D-09** | **backfill 구문이 `601717` §4.5.1 과 동일** — `SELECT id, tenant_name FROM catchmenu_hq.tenants` | 일치 | 값 출처 고정 |
| TP-D-05 | `stores.merchant_account_id` 가 `stores.tenant_id` 를 통해 결정된 값과 일치 | 전 행 일치 | §1.26. §12.2 N-2′ |
| TP-D-06 | `stores` 중 `merchant_account_id` 가 NULL 인 행 0건 | 0건 | 동일 |
| TP-D-07 | backfill 이 기존 행을 추가·삭제하지 않았다 — `tenants`·`stores` 행 수 불변 | BL-5·BL-20 유지 | §1.45 / **I-48** |
| **TP-D-08** | **MerchantAccount 없는 `tenants` 행 0건** — 검증 시점 상태 검사 | **0건** | **`601713` I-47.** 강제 장치 부재는 §12.3 N-1″ |

> **TP-D-01 이 seed 와 backfill 을 가르는 단 하나의 검사다.**
> 행이 존재하는지가 아니라 **원천 행 수와 정확히 일치하는지**를 본다.

## §5 Negative Tests

### §5.1 legacy 어휘가 authoritative 로 남지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-01 | `catchmenu_hq.owners` 가 relation 으로 존재하지 않음 | 0건 | `601710` §2.1 |
| TP-N-02 | `owners` 이름의 호환 VIEW / MATVIEW 미생성 | 0건 | 동일 |
| TP-N-03 | `owner_id` / `owner_name` 이 canonical schema 에 남지 않음 | 0건 | §1.37 보강 |
| TP-N-04 | `owners` 를 참조하는 FUNCTION 이 새로 생기지 않음 | 0건 (BL-8) | `601711` P-1 |
| TP-N-05 | `is_active` 가 `persons` 에 다른 이름으로 되살아나지 않음 | 0건 | I-36 |
| TP-N-06 | `ownership_percent` 가 다른 테이블·이름으로 옮겨지지 않음 | 0건 | I-37 |
| TP-N-07 | `catchmenu_common.set_updated_at()` 함수명 불변 | 불변 | §1.37 — generic identifier 유지 / **I-45** |
| TP-N-08 | `catchmenu_authority_owner` role 명 불변 | 불변 | 동일 / **I-46** |

### §5.2 RLS / 권한 조합이 조용히 뒤바뀌지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-09 | `persons` 의 RLS POLICY 0건 | 0건 | I-11, X-8 |
| TP-N-10 | 나머지 3테이블의 RLS POLICY 0건 유지 | 0건 | 동일 |
| TP-N-11 | `merchant_accounts` 의 RLS POLICY 0건 | 0건 | §1.45 / **I-51** |
| TP-N-12 | `catchmenu_authority_owner` 의 `rolbypassrls=true`, `rolcanlogin=false` 유지 | 유지 | `601714`/`601715` Q-4 |
| TP-N-13 | 클라이언트 도달 가능 role 에 `merchant_accounts` GRANT 0건 | 0건 | §1.45 / **I-51** |
| TP-N-14 | `catchmenu_authority_owner` privilege 가 4건에서 축소되지도 않음 | 정확히 4건 | I-12 |
| TP-N-15 | `tenants` / `stores` 의 기존 RLS 플래그·정책 불변 | 불변 | I-17 |

### §5.3 `merchant_accounts` 가 선언 범위를 넘지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-16 | LegalEntity 참조 컬럼·FK 없음 | 0건 | I-38 / §1.44·§1.23 |
| TP-N-17 | `primary_owner_user_id` 또는 대체 컬럼 없음 | 0건 | I-39 |
| TP-N-18 | 서비스 상태 / 체험 상태 컬럼 없음 | 0건 | I-39 |
| TP-N-19 | 청구·계약 연락처 컬럼 없음 | 0건 | I-39 |
| TP-N-20 | `000170` §4 그 외 권장 필드 없음 | 0건 | I-39 |
| TP-N-21 | **컬럼 수가 정확히 5** | **5** | I-39 / **`601717` §4.1 확정** |
| TP-N-22 | `tenants.merchant_account_id` 미생성 — 순환 참조 없음 | 0건 | §1.45 / **I-49** |
| TP-N-23 | `merchant_companies` / `merchant_stores` 등 3층 구조 테이블 미생성 | 0건 | §1.25 / `601705` §4.6 |
| TP-N-24 | `merchant_accounts` 가 `catchmenu_hq` 외 schema 에 생성되지 않음 | 0건 | §1.45 「배치」 / **I-50** |

### §5.4 Store–LegalEntity — enforcement 를 걸지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-25 | **`stores.legal_entity_id` 가 여전히 NULL 허용** | `is_nullable = YES` | **`601717` §1.5 C-2 — `DEFERRED — INELIGIBLE`** |
| TP-N-26 | `legal_entities` 행 수가 여전히 0 | 0행 | I-28 |
| TP-N-27 | `stores.legal_entity_id` 백필 0행 유지 | 0행 | I-28 |
| TP-N-28 | `store_operator_type` 근거 LegalEntity 배정 로직 미생성 | 0건 | I-30 |
| TP-N-29 | Store–LegalEntity 시점 이력 테이블 미생성 | 0건 | §12.2 B-5 |
| TP-N-30 | `stores.legal_entity_id` 에 대한 DDL·DML 0건 | 0건 | `601717` §3 |

### §5.5 선언되지 않은 것을 만들지 않았는가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-31 | economic ownership 모델 미생성 | 0건 | §1.39 |
| TP-N-32 | Store 상태 3축 enum / 상태 컬럼 미생성 | 0건 | `601710` §3 |
| TP-N-33 | `OperatingGroup` / `company` / `business_unit` 미생성 | 0건 | 동일 |
| TP-N-34 | `cross_business_link` 물리 구조 미생성 | 0건 | 동일 |
| TP-N-35 | 감사 이력 테이블 / 감사 트리거 미생성 | 0건 | `601713` §5 |
| TP-N-36 | Staff / User / Session / Role / Permission 객체 미변경 | 0건 | §1.18·§1.19 |
| TP-N-37 | 금전 객체 LegalEntity snapshot 컬럼 미생성 | 0건 | `601710` §2.3 |
| TP-N-38 | Tenant 이전 절차·데이터 처리 객체 미생성 | 0건 | 동일 |
| TP-N-39 | Tenant provisioning 경로가 **신규 생성되지 않음** | 0건 | §1.45 / `601717` FO-E |

### §5.6 MerchantAccount → Store — enforcement 를 선행 강제하지 않았는가

> **`601717` §1.5 C-1 이 `DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT` 로 확정됐다.**
> 이 절은 **그 이월이 지켜졌는지**를 검사한다.

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-40 | **`stores.merchant_account_id` 가 NULL 허용** | `is_nullable = YES` | **`601717` §1.5 C-1 · FO-13** |
| TP-N-41 | `merchant_accounts.tenant_id` 는 `NOT NULL` (반대 방향은 강제됨) | `is_nullable = NO` | §1.45 |
| TP-N-42 | migration 본문에 `SET NOT NULL` 구문 0건 | 0건 | `601717` FO-13 |
| TP-N-43 | `stores.merchant_account_id` 를 강제하는 CHECK 제약·트리거 미생성 | 0건 | `NOT NULL` 우회 금지 |

> ⚠️ **TP-N-40 과 TP-D-06 을 함께 읽어야 한다.**
>
> ```text
> 컬럼은 NULL 허용이다        제약이 없다
> 실제 NULL 행은 0건이다      값은 채워졌다
> ```
>
> **이것이 이번 나선의 정확한 결과다.**
> 「데이터가 없어서 못 걸었다」도 아니고 「요구가 없어졌다」도 아니다 —
> **신규 Store 생성 경로 2건이 값을 공급하지 않으며, 그 2건 수정은 이 계약 밖이다**
> (`601717` §4.4). 이월 항목은 §12.4 를 보라.

### §5.7 두 INSERT RPC 를 임의 수정하지 않았는가 (4판 신설)

> `601718`/`601719` 가 함수를 **이름으로 특정**했으므로 검사도 이름으로 특정한다.

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| **TP-N-50** | **`catchmenu_common.provision_tenant` 의 `prosrc` md5 = `f84ac1a81da4ccba87930bf020a3e974`** (len 4758) | 일치 | **`601717` FO-A** / BL-35 |
| **TP-N-51** | **`catchmenu_hq.create_franchise_store` 의 `prosrc` md5 = `87511a95676a41d2c95866e0c2da8b7f`** (len 3460) | 일치 | **`601717` FO-B · FO-B1** — phantom 교정도 금지다 |
| **TP-N-52** | **두 함수의 `stores` INSERT 컬럼 목록에 `merchant_account_id` 가 없다** | 0건 | **`601717` FO-C** — 이번 계약이 공급하도록 고치지 않았음을 확인 |
| **TP-N-53** | `catchmenu_common.onboard_tenant` · `catchmenu_store.update_business_hours` 의 `prosrc` 불변 | 불변 | `601717` FO-D (BL-31) |
| TP-N-54 | `stores` 에 INSERT 하는 함수가 여전히 **2건** | 2건 (BL-28) | `601717` FO-E — 우회 경로 미생성 |
| TP-N-55 | `stores` 를 UPDATE 하는 함수가 여전히 **2건** | 2건 (BL-31) | 동일 |
| TP-N-56 | `stores` 에 INSERT/UPDATE 하는 신규 트리거 미생성 | 0건 | `601717` FO-E · FO-20 |
| **TP-N-59** | **`stores.brand_id` · `stores.extra_metadata` 컬럼이 생성되지 않음** | **0건** (BL-37) | **phantom 참조를 컬럼 추가로 해소하려는 시도 금지.** 교정은 `601717` §4.4.3 H-3a 로 이월 |
| **TP-N-60** | **`merchant_accounts` 에 `is_active` · `status` · provider 식별자 · `legal_entity_id` · `store_id` · 임의 metadata 컬럼이 없다** | **0건** | **`601717` §4.1 제외 목록 확정** / I-38 · I-39 |
| **TP-N-61** | **`merchant_accounts` 에 `account_name` 이라는 이름의 컬럼이 없다** | **0건** | **§4.1 — `account_name` 은 PG·settlement account 와 혼동될 수 있어 배제됐다** |

> **TP-N-52 가 이번 판에서 가장 미묘한 검사다.**
> 구현자가 「NOT NULL 을 걸려면 RPC 가 값을 줘야 하니 한 줄만 추가하자」고 판단하는 것은
> **자연스럽고, 정확히 금지된 것**이다(`601710` §3 RPC 재작성 Out of Scope).
> **그 한 줄이 0-A 가 provisioning 설계를 선점하는 지점이다.**

### §5.8 데이터 조작이 선언된 파생뿐인가

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-N-44 | migration 전체의 `INSERT` 가 `merchant_accounts` 대상 1건뿐 | 정확히 1건 | §1.45 / `601717` M-1 |
| TP-N-45 | migration 전체의 `UPDATE` 가 `stores.merchant_account_id` 대상 1건뿐 | 정확히 1건 | `601717` M-2 |
| TP-N-46 | migration 전체의 `DELETE` 0건 | 0건 | 선언 없음 |
| TP-N-47 | 두 DML 이 기존 행에서 파생되며 business data 리터럴을 포함하지 않는다 | 리터럴 0건 | §1.45 |
| TP-N-48 | Person 계열 4테이블에 DML 0건 — 전부 0행 유지 | 0행 | BL-1~4 |
| TP-N-49 | **`stores` 의 `merchant_account_id`·`updated_at` 외 컬럼이 수정되지 않음** | 나머지 전부 불변 | BL-26 · §12.2 N-4′ |
| TP-N-57 | seed SQL 미변경 | 0건 | `601711` P-5 |
| TP-N-58 | `tenants` 행이 수정되지 않음 — `tenant_status`/`isolation_state` 포함 | 불변 | BL-27 / `601505` §4 |

### §5.9 `provision_tenant` — 실행하지 않고 불변만 검사한다 (10판 신설)

> **TP-RT-03 폐기의 대체다**(F-5 처분). 실행 검증은 §12.4 로 이월한다.

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| **TP-N-62** | **`catchmenu_common.provision_tenant` 본문이 baseline md5 와 불변** — TP-N-50 과 연동 | `f84ac1a81da4ccba87930bf020a3e974` (len 4758) | **F-5 처분 — 대체 ①** |
| **TP-N-63** | **정적 증거로 검증한다** — ① `provision_tenant` `prosrc` md5 가 baseline 과 불변(TP-N-62 와 동일 근거) ② `0170`/`0171` migration 본문에 `provision_tenant` 호출문 0건 ③ 이 TestPlan 의 실행 command 목록에 `provision_tenant` 호출 0건 | 3건 모두 충족 | **R2-F3 처분** — 관측 장치를 도입하지 않는다 |
| ~~TP-N-63 (종전 정의)~~ | **폐기 (2026-08-23, R2-F3 처분)** — 종전 기대: 「0-A 검증 과정에서 `provision_tenant` 를 호출하지 않았다 / 호출 0건」 | — | **폐기 사유**: 호출 여부를 관측하려면 `pg_stat_statements` 또는 별도 logging 이 필요하다. **검증을 위한 runtime 구조를 이번 나선에서 새로 만드는 것은 0-A 범위를 넘는다.** 행은 기록으로 보존한다 |
| **TP-N-64** | **검증 과정이 `tenants` 행을 생성·수정하지 않았다** | BL-20 유지 | **F-5 처분 — 대체 ③.** TP-N-58 과 중복 검사이나 **실행 검증 금지**를 명시한다 |

> ⚠️ **이 절은 「실행되는가」를 묻지 않는다.**
>
> ```text
> 묻지 않는다   provision_tenant 가 성공하는가     ← 애초에 실패한다 (N-6″)
> 묻는다        본문을 건드리지 않았는가
> 묻는다        검증한다면서 실행해 버리지 않았는가
> ```
>
> **실행 검증은 후속 RPC alignment 나선이 N-6″ 를 정합화한 뒤에 가능해진다.**

## §6 Regression Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-R-01 | `catchmenu_hq` BASE TABLE 수 = **21** | 21 (BL-7) | 20이면 `merchant_accounts` 미생성, 22면 신규 생성이 남은 것 |
| TP-R-02 | `set_updated_at()` 호출 non-internal 트리거 총계 = **115** | 115 (BL-12) | |
| TP-R-03 | `set_updated_at()` 정의 불변 | 불변 | `601714`/`601715` Q-3 |
| TP-R-04 | `legal_entities` 11컬럼 불변 | 불변 | `601714`/`601715` Q-8 |
| TP-R-05 | `tenants` 10컬럼 불변 | 불변 | BL-20 |
| TP-R-06 | **`stores` 컬럼 수 = 17** | 17 (BL-21) | **`601720`/`601721` PRE-6 이 before=16 을 확정** |
| TP-R-07 | `chk_legal_entities_*` 3건 불변 | 불변 | `601714`/`601715` Q-2 |
| TP-R-08 | `chk_ler_*` / `chk_lepr_effective_range` 불변 | 불변 | 동일 |
| TP-R-09 | `chk_tenants_*` 4건 · `chk_stores_*` 3건 불변 | 불변 | `601701` E단계 |
| TP-R-10 | `chk_lepr_role_type` 허용값 5개 불변 | BL-18 | |
| TP-R-11 | `fk_stores_legal_entity_id` · `uq_stores_tenant_code` · `idx_stores_tenant_id` 등 기존 제약·인덱스 불변 | 불변 | `601701` E단계 |
| TP-R-12 | 타 스키마 → Person 계열 4테이블 FK 0건 유지 | 0건 (BL-13) | `601714`/`601715` Q-4 |
| TP-R-13 | 앱·패키지·테스트·seed 의 `owners`/`owner_id` 참조 0건 유지 | 0건 (BL-17) | `601711` P-5 |
| TP-R-14 | **`stores` 를 직접 참조하는 158개 FUNCTION 이 전부 유효** | **158건 유효** (BL-22) | **`601718`/`601719` S-1** |
| TP-R-15 | `tenants` 를 직접 참조하는 10개 FUNCTION 이 전부 유효 | 10건 유효 (BL-23) | `601701` E단계 |
| TP-R-16 | `0168`/`0169` 파일 checksum 이 `migration_history` 기록값과 동일 | 동일 | `000701` §14.5 |
| TP-R-17 | `migration_history` 의 기존 행이 수정·삭제되지 않음 | 불변 | 이력 보존 |
| TP-R-18 | 기존 RPC 시그니처 변경 0건 | 0건 | `601700` Readme §5 |
| TP-R-19 | **`stores` 트리거 총계 = 241** (internal 240 / user 1) | 241 (BL-33) | **`601718` S-6** — backfill 중 트리거 우회·비활성화 금지 |
| TP-R-20 | **`stores` 참조 VIEW / MATVIEW 가 여전히 0 / 0** | 0 / 0 (BL-34) | `601718`/`601719` S-6 |

> **TP-R-14 의 위험도가 4판에서 내려갔다.**
> 3판까지는 「151개 중 몇 개가 `SELECT *` 인지 모른다」가 미측정 위험이었다.
> **`601718`/`601719` 가 `SELECT *`·행 타입 의존 0건을 실측**해 그 위험이 사라졌다.
> 남은 것은 함수 유효성 확인이며, **컬럼 추가는 `COLUMN_LIST` INSERT 를 깨뜨리지 않는다.**

## §7 External Provider Mapping — negative 검증 (`601710` §7 필수)

### §7.1 금지 대상 — 하나라도 발견되면 FAIL

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-X-01 | provider mapping 테이블 미생성 | 0건 | `601710` §3.1 |
| TP-X-02 | 기존 테이블에 외부 provider 전용 컬럼 미추가 | 0건 | 동일 |
| TP-X-03 | provider contract 를 추정한 schema·타입·제약 미생성 | 0건 | 동일 |
| TP-X-04 | `stores` 에 늘어난 컬럼이 MerchantAccount 참조 1개뿐 | 정확히 1개 | TP-R-06 |
| TP-X-05 | 이름에 `merchant` 가 든 **테이블** 증가분이 `merchant_accounts` 1건뿐 | 정확히 1건 | BL-15 |
| TP-X-06 | 이름에 `merchant` 가 든 **컬럼** 증가분이 선언된 것뿐 | 대조 일치 | BL-16 |
| TP-X-07 | 특정 벤더명(TOSS / OKPOS / KICC / Smartcast 등)을 담은 신규 객체 미생성 | 0건 | `601710` §3.1 |
| TP-X-08 | `catchmenu_integrations`/`catchmenu_payment` 의 기존 5개 `merchant` 컬럼이 canonical identity 로 승격되지 않음 | 0건 | §1.43 |
| TP-X-09 | `merchant_accounts` 가 provider 계열 테이블로 향하는 FK 0건 | 0건 | §1.43 |
| TP-X-10 | **backfill 의 원천이 `catchmenu_hq.tenants` 하나뿐** | 원천 1개 | §1.45 + §1.43 |
| TP-X-11 | `stores.id` 를 외부 provider merchant id 와 동일시하는 제약·주석 미도입 | 0건 | `601710` §3.1 |

> ⚠️ **TP-X-10 은 값의 출처를 검사한다.**
> `merchant_accounts` 를 채울 때 `catchmenu_integrations.pos_store_configs.merchant_id` 같은
> 외부 값을 끌어오는 것은 어휘상 자연스러워 보이지만,
> **정확히 §1.43 이 금지한 provider identity 의 canonical 승격이다.**

### §7.2 확인해야 하는 것

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-X-12 | `601717` 이 provider mapping 물리 구현을 **명시적으로 금지**하는 조항을 포함 | 조항 존재 | `601710` §7 |
| TP-X-13 | migration 본문에 provider / external / mapping 관련 스키마 객체가 남지 않음 | 0건 | `601710` §3.1 |

## §8 Boundary / Forbidden File Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-B-01 | `git diff --name-only` 가 `601717` §1 허용 목록의 부분집합 | 부분집합 | `601717` §1 |
| TP-B-02 | `601717` §5 금지 파일 중 변경된 것 0건 | 0건 | `601717` §5 |
| TP-B-03 | `sql/migrations/` 기존 169개 파일 미수정 | 0건 | `000701` §14.5 |
| TP-B-04 | `apps/` / `packages/` / `catchmenu_app/` / `tests/` / `tools/` 변경 0건 | 0건 | `601717` §5 |
| TP-B-05 | `supabase/` 변경 0건 | 0건 | 동일 |
| TP-B-06 | `docs/` 변경이 허용된 문서 동기화 범위 내 — **Module 파일명이 `601722_Module_Operational_Authority_Foundation_V2.md`** 이고 27~30건 정합화 문서는 **미변경** | 범위 내 | `601717` §1.2 · **Stage 7 항목 1·7(B-9 DEFERRED)** |
| TP-B-07 | `601702` / `601705` / `601710` / `601713` / **`601718`** / **`601719`** 미수정 | 0건 | `601717` X-7·X-8·X-10 |
| TP-B-08 | 신규 migration 파일이 정확히 2개 | 2개 | `601717` §1.1 |

## §9 Migration / Schema Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-M-01 | 신규 migration 각 파일 상단 5행 이내 `-- Workpacket: 601700` | 2건 모두 | `000701` §6.11.1 |
| TP-M-02 | `tools/Check-Governance.ps1` 에서 두 파일에 G15 finding 없음 | 0건 | 동일 |
| TP-M-03 | `-StrictStage7` 로도 G15 ERROR 없음 | 0건 | 동일 |
| TP-M-04 | 파일명이 `0170_` / `0171_` 로 시작, 번호 재사용 없음 | 참 | 최신 = `0169` |
| TP-M-05 | 적용 후 `migration_history` 에 `success = true` 2행 추가 | 2행 | 적용 증거 |
| TP-M-06 | 적용 순서가 `0170` → `0171` | 참 | FK 의존 |
| TP-M-07 | `0171` 내부 순서가 **테이블 생성 → M-1 → stores 컬럼·FK·인덱스 → M-2** | 참 | 참조 무결성 |
| TP-M-08 | **clean baseline replay** — 깨끗한 baseline DB 에서 `0000`…`0169` → `0170` → `0171` **전체 순차 재생 성공** | 성공 | **Stage 7 Decision (`601717` §10.2)** — B-7 CLOSED |
| TP-M-09 | migration 본문에 `CASCADE` 0건 | 0건 | §1.39 / I-37 |
| TP-M-10 | migration 본문에 `DROP TABLE` 0건 | 0건 | `601717` §2 |
| TP-M-11 | **migration 본문에 `CREATE OR REPLACE FUNCTION` 0건** | 0건 | **`601717` FO-15 · §6.1** |

> ⚠️ **TP-M-08 의 범위를 Stage 7 이 좁혔다** (`601717` §10.2 — B-7 CLOSED).
>
> ```text
> 요구한다        깨끗한 baseline DB 에서 0000…0169 → 0170 → 0171 순차 재생 성공
> 요구하지 않는다  이미 0170/0171 이 적용된 동일 DB 에서 본문을 다시 실행
> ```
>
> **`0170` 의 rename 은 동일 DB 재실행에 적합하지 않다.**
> 7판까지의 「재적용(replay)」 표현은 「같은 DB 에서 두 번 실행」으로 읽힐 여지가 있었고,
> 그 해석으로 검사하면 **idempotent 를 요구하지 않기로 한 결정과 어긋난다.**
>
> `601718` S-5 가 기록한 `0034`/`0060`/`0082` 의 `stores` INSERT 는
> 전체 재생 시 `0171` 보다 앞서 적용되므로 backfill 이 사후에 덮는다 — 순서 충돌 없음.

> **TP-M-11 이 §5.7 의 파일 단위 대응물이다.**
> `prosrc` 대조(TP-N-50~53)는 사후 상태를 보고,
> TP-M-11 은 **migration 파일 자체에 함수 재정의가 들어 있는지**를 본다.

## §10 Runtime Behavior Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-RT-01 | Person 계열 변경으로 인한 RPC 회귀 없음 | 0건 | BL-8 |
| TP-RT-02 | **`stores` 컬럼 추가·UPDATE 로 인한 RPC 회귀 없음** | 0건 | BL-22·BL-30 — `SELECT *` 0건이 실측됨 |
| ~~TP-RT-03~~ | **폐기 (2026-08-23, F-5 처분)** — 종전 기대: 「`catchmenu_common.provision_tenant` 가 여전히 성공적으로 실행 가능」 | — | **대체: TP-N-62~64 (§5.9).** 폐기 사유는 아래 주석. 행은 기록으로 보존한다 |
| **TP-RT-08** | **`catchmenu_hq.create_franchise_store` 의 실패 양상이 구현 전후로 동일** — 부재 컬럼 `extra_metadata` 로 실패하며 `merchant_account_id` 때문이 아니다 | **동일 오류** | **§12.3 N-4″** — 이 함수는 구현 이전부터 실패한다. **성공을 기대값으로 두지 않는다** |
| TP-RT-04 | 앱 빌드 / 테스트 스위트가 이전과 동일하게 통과 | 동일 | BL-17·BL-32 |
| TP-RT-05 | `catchmenu_authority_owner` 경유 접근의 가능/불가능 불변 | 불변 | X-8 |
| TP-RT-06 | `merchant_accounts` 에 어떤 애플리케이션 경로도 도달하지 못한다 | 도달 0 | §1.45 fail-closed |
| TP-RT-07 | 다른 도메인의 트리거·제약 불변 | 불변 | TP-R-02 |

> 🛑 **TP-RT-03 은 10판에서 폐기됐다 (F-5 처분, 2026-08-23).**
>
> **폐기 사유 2건**
>
> ```text
> ① 실행하면 tenant_status = 'ACTIVE' tenant 를 만들어
>    FO-33 (tenant ACTIVE 승격 금지) 와 TP-N-58 (tenants 불변) 을 침범한다
> ② phantom tenant 컬럼 3건 때문에 애초에 성공 실행이 불가능하다
>    (owner_name · owner_email · owner_phone — 601725 / 601726)
> ```
>
> **대체 항목** — §5.9 **TP-N-62 · TP-N-63 · TP-N-64**
>
> ```text
> provision_tenant 본문이 baseline md5 와 불변인가         TP-N-62 (TP-N-50 연동)
> migration 본문·실행 command 에 호출문이 없는가            TP-N-63 (R2-F3 — 정적 증거)
> 검증 과정이 tenants 행을 건드리지 않았는가                TP-N-64
> ```
>
> **실행 검증은 후속 RPC alignment 나선으로 이월한다** — §12.4.
> 그 나선이 N-6″ phantom 컬럼을 정합화한 뒤에야 실행 검증이 가능해진다.
>
> **종전 서술은 아래에 사실 기록으로 보존한다.**

> ⚠️ **TP-RT-03 과 TP-RT-08 은 6판에서 갈라졌다.**
>
> ```text
> provision_tenant         성공해야 한다
>                          실패하면 NOT NULL 이 걸렸거나 우회 제약이 생긴 것이며
>                          601717 §1.5 C-1 이월을 위반한 것이다
>
> create_franchise_store   실패한다. 구현 이전부터 그렇다
>                          기대값은 「성공」이 아니라 「같은 이유로 실패」다
> ```
>
> **이미 깨진 것을 이 나선이 고쳐 놓았는지 묻지 않는다**(FO-B1 이 교정을 금지한다).
> **다만 실패 원인이 바뀌었는지는 묻는다** — 원인이 `merchant_account_id` 로 옮겨갔다면
> NOT NULL 이 걸린 것이다.
>
> **TP-RT-06 은 실패가 아니라 목표 상태다** — §1.45 fail-closed baseline.

## §11 Rollback Tests

| # | 검사 | 기대값 | 근거 |
|---|---|---|---|
| TP-RB-01 | rollback 이 역방향 신규 migration 으로 표현 가능 | 가능 | `000701` §14.5 |
| TP-RB-02 | rollback 계획이 `0170`/`0171` 수정·삭제를 전제하지 않음 | 전제 없음 | 동일 |
| TP-RB-03 | rollback 후 §2.1 기준선 before 값이 복원됨 | 복원 | 기준선 대조 |
| TP-RB-04 | rollback 시 RLS `ENABLE`+`FORCE` 와 GRANT 4건이 함께 복원됨 | 복원 | X-6·X-7 |
| TP-RB-05 | backfill 로 만든 행이 함께 제거된다 — `merchant_accounts` 0행 복귀 | 0행 | BL-24 역 |
| TP-RB-06 | **`stores.updated_at` 은 복원되지 않는다는 사실이 rollback 계획에 명시됐다** | 명시 | BL-26 — 비가역 |
| TP-RB-07 | rollback 순서가 `0171` 역 → `0170` 역 | 참 | FK 의존 역순 |
| TP-RB-08 | rollback 후에도 두 INSERT RPC 의 `prosrc` 가 불변 | 불변 | 애초에 건드리지 않았으므로 |

## §12 Blocker

### §12.1 해소된 것 (기록 보존)

| # | blocker | 해소 근거 |
|---|---|---|
| B-1 | `MerchantAccount` 목표 상태 미정의 | `601702` §1.44 |
| B-2a / B-2b | 트리거명 / `owner_name` 미선언 | `601702` §1.37 보강 |
| B-3 / B-4 | `is_active` / `ownership_percent` 충돌 | `601713` I-36 · I-37 |
| B-6(1판) / B-7(1판) | §1.43 vs §3.1 / §1.34~§1.44 미반영 | `601710` §2.3 / `601713` I-34~I-42 |
| N-1(2판) | MA→Store enforcement 원인 | `601702` §1.45 backfill |
| N-2 / N-3 / N-4 / N-6 | posture / 소관 순환 / 옛 서술 / 일자 | `601702` §1.45·§2.2·§5, `601713` 병기 |
| **N-5** | **`stores` 참조 함수 형태 미측정** | **`601718`/`601719` — `SELECT *`·`ROW_TYPE`·`NO_COLUMN_LIST` 전부 0건** |
| **N-1′** | **C-1 승격 가부 미판정** | **판정 가능해졌다. 결과는 `601717` §4.4 — 부적격** |
| **B-7** | **재적용 동작 요구사항 미선언** | **CLOSED by Stage 7 Decision (2026-08-23)** — clean baseline replay 만 요구. TP-M-08 |
| **B-8** | **검증 환경 미지정** | **CLOSED by Stage 7 Decision (2026-08-23)** — `postgres:17.6.1.140` / `0169` / `tenants`=1 · `stores`=1. PRE-3·5·6·7 |
| **N-3′** | **backfill 값 출처 미선언** | **CLOSED (2026-08-23)** — Stage 7 이 `601717` §4.5.1 구문 확정. 출처 `tenants.tenant_name`(`NOT NULL`). **동기화 정책은 §12.4 H-5 로 이월** |
| **N-2″** | **`stores` 실제 컬럼 수 미확정** | **`601720`/`601721` PRE-6 — 라이브 16컬럼, `601701` 기록과 차이 0. `brand_id`·`extra_metadata` 둘 다 부재. 기준선 기록이 정확했고 RPC 가 phantom 을 참조한다** |
| **N-5′** | **§1.45·§1.37 보강이 ERD/Overview/Logic 에 미반영** | **`601713` I-43~I-51 · §1.1 주석 · §1.5 write-path 승계 · §6 Q-10 / `601710` §2.3·§2.4 / `601705` §4.1·§4.4·§8·O20** |

### §12.2 남아 있는 것 — 처분 유효성 재확인

| # | Blocker | 처분이 여전히 유효한가 | 영향 |
|---|---|---|---|
| **B-5** | Store–LegalEntity 시점 관계 물리 구조 미정 | **유효.** `601710` §4 분기·확장 실측 부재 변동 없음 | TP-N-29 |
| **B-6** | `CHANGELOG.md` 규약 상태 미결 | **유효.** 변동 없음 | §8 |
| **B-9** | 문서 정합화 시점 미정 | **DEFERRED by Stage 7 Decision (2026-08-23).** 현 Stage 8 에서 27~30건 문서를 수정하지 않는다. 물리 구현 + Verification/Audit 완료 후 **별도 Documentation Vocabulary Reconciliation** | §8 TP-B-06. **정합화 전까지 그 문서군의 legacy `owners`/`owner_id` 를 새 나선의 canonical 근거로 쓰지 않는다** |
| **N-2′** | `stores` backfill 이 §1.45 의 직접 선언이 아니다 | **유효.** 신설된 **I-48 도 `merchant_accounts` 행 생성만** 다루고 `stores` backfill 을 다루지 않는다 | TP-D-05·TP-D-06 |
| **N-4′** | backfill UPDATE 의 `stores.updated_at` 부작용 | **유효.** `601713`/`601710`/`601705` 갱신분 어디에도 이 부작용 서술이 없다 | BL-26, TP-N-49, TP-RB-06 |

### §12.3 새로 생긴 것

| # | Blocker | 내용 | 영향 |
|---|---|---|---|
| **N-1″** | **backfill 이후 신규 provisioning 부터 1:1 invariant 가 다시 깨진다.** 5판에서 **선언에서 Logic 불변조건으로 승격** | `provision_tenant` 는 `merchant_accounts` 를 만들지 않는다(`601718` S-2). backfill 은 **기존** Tenant 만 덮는다. **`601713` I-47** 이 이를 불변조건으로 두었으나 **강제 장치가 없다** | TP-D-08 이 검증 시점 상태만 검사. `601717` §4.4.3 H-1 로 이월. §12.4 |
| **N-3″** | **`601710` §2.4 의 「§2.2 미결」 상호참조가 모호하다** | 151 vs 158 차이를 미결로 기록한 것은 **`601702` §2.2** 인데 `601710` §2.4 는 문서명 없이 「§2.2」로 적었다 | 이 TestPlan 은 `601702` §2.2 로 읽는다(BL-22). 문면 정정은 Stage 4 소관 |
| **N-4″** | **`catchmenu_hq.create_franchise_store` 가 현재 호출 시 실패한다** | INSERT 주 경로가 부재 컬럼 `extra_metadata` 를 참조한다(`601718` S-2 전문 / `601720`·`601721` PRE-6). **이 나선이 만든 결함이 아니며 이 나선이 고칠 수도 없다**(`601717` FO-B1) | **TP-RT-08 이 「실패 양상 불변」을 검사.** 성공을 기대값으로 두지 않는다. 교정은 `601717` §4.4.3 H-3a 이월 |
| **N-5″** | **`catchmenu_common.onboard_tenant` 의 `stores.brand_id` phantom 참조가 재측정되지 않았다** | `601718` S-4 / `601719` S-4 가 `update catchmenu_hq.stores set brand_id = v_brand_id` 를 전문과 함께 기록했고, `601720`/`601721` PRE-6 이 `stores.brand_id` **부재**를 확정했다. 그러나 두 사전 측정의 `prosrc` 토큰 검사는 **두 INSERT RPC 만** 대상으로 했고 `onboard_tenant` 는 범위 밖이었다 | 이 TestPlan 은 **판정하지 않는다.** TP-N-53 이 `prosrc` 불변만 검사한다 |
| **N-6″** | **`catchmenu_common.provision_tenant` 가 `tenants` 의 phantom 컬럼 3건을 참조해 첫 단계에서 실패한다** | `owner_name` · `owner_email` · `owner_phone`. `0002` 가 세 컬럼 없이 `catchmenu_hq.tenants` 를 만들었고 `0082` 가 `provision_tenant` 최초 정의에서 그대로 참조했다 — **처음부터 phantom**. `tenants` INSERT 가 첫 단계이므로 `stores` INSERT 에 도달하지 못한다 (`601725` / `601726` 이중 실측) | **TP-RT-03 폐기의 근거이자 `601717` C-1 사유 교체의 근거.** 이 TestPlan 은 판정하지 않는다. §5.9 가 불변만 검사한다. 후속 RPC alignment — H-1 prerequisite |
| **N-7″** | **`catchmenu_common.onboard_tenant` 가 `tenants.business_number` phantom 참조와 인자명 불일치를 갖는다** | pre-check 가 `tenants.business_number` 를 참조하나 라이브 스키마에 부재. `provision_tenant` 호출 시 라이브 시그니처에 없는 named argument 를 전달한다(`0112` 유래). `601725` E-5 / `601726` | 동상. TP-N-53 이 `prosrc` 불변만 검사한다. **N-5″ 와 같은 함수의 별개 결함** |
| **N-8″** | **`provision_tenant` 의 `store_type='RESTAURANT'` 가 `chk_stores_type` 허용값 밖이다** | `0002` `chk_stores_type` 허용값은 `DINE_IN` / `TAKEOUT` / `HYBRID` / `DELIVERY_ONLY`. `601725` 기록 | 동상. **N-6″ 때문에 이 지점에 도달하지 않으므로 현재 표면화되지 않는다** |

> **N-2″ 의 두 가능성**
>
> ```text
> 컬럼이 실재한다        601701 E단계 기록이 불완전하다 — 기준선 문서의 정확성 문제
> 컬럼이 없다            두 RPC 가 phantom 컬럼을 참조한다 — 런타임 결함
> ```
>
> 이 프로젝트에는 **phantom 컬럼 참조로 RPC 가 실패한 실제 이력**이 있다
> (`sql/migrations/CHANGELOG.md` 2026-07-18 — `0160`~`0164` 가 `order_sessions` phantom 컬럼 교정).
> **이 TestPlan 은 판정하지 않는다.** 기대값을 상수로 두지 않는 것으로 대응한다.
> **철회 (2026-08-23, F-3 처분)** — 위 「판정하지 않는다 / 기대값을 상수로 두지 않는다」는
> **더 이상 유효하지 않다.** `601720`/`601721` PRE-6 이 **라이브 16컬럼 · `brand_id`·`extra_metadata` 부재**를
> 확정해 두 가능성 중 **두 번째(RPC 가 phantom 을 참조한다)로 결정**됐다 — §12.1 N-2″.
> BL-21 은 이미 before=16 / after=17 을 상수로 쓴다.
> 위 문단은 **6판 이전의 사실 기록으로 보존**한다.

**미결로 기록된 것 (authority 가 이미 판정)**

| 항목 | 상태 |
|---|---|
| `stores` 참조 함수 수 151 vs 158 | `601702` §2.2 가 **미결이되 C-1 판정에 영향 없음**으로 기록. 이 TestPlan 은 live 값 158 을 기준선으로 쓴다(BL-22) |

### §12.4 이월 — blocker 가 아니라 판정된 상태

> **아래는 미해결이 아니다. `601717` §1.5 가 판정하고 Stage 7 이 승인한 상태이며, 후속 나선이 이어받는다.**
> Stage 7 항목 2(C-1·C-2)와 항목 3(H-1~H-5)이 **2026-08-23 APPROVED** 다 — `601717` §10.1.

| # | 이월 항목 | 상태 | 살아 있는 invariant |
|---|---|---|---|
| **C-1** | `stores.merchant_account_id` `NOT NULL` | **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** | `601702` §1.26 · §1.45 / `601713` I-27 |
| **C-2** | `stores.legal_entity_id` `NOT NULL` | **`DEFERRED — INELIGIBLE IN CURRENT 0-A CONTRACT`** | `601702` §1.24 · §1.34 / `601713` I-40~I-42 |
| **H-1** | `provision_tenant` 가 `merchant_accounts` 를 같은 transaction 에서 생성 | 후속 RPC alignment 나선 | `601702` §1.45 |
| **H-2** | `provision_tenant` 의 `stores` INSERT 가 `merchant_account_id` 공급 | 동일 | §1.26 / I-27 |
| **H-3** | `create_franchise_store` 의 `stores` INSERT 가 `merchant_account_id` 공급 | 동일 | 동일 |
| **H-4** | H-1~H-3 완료 후 C-1 재판정 | 동일 | `601717` §1.5 |
| **H-3a** | `create_franchise_store` 의 phantom `extra_metadata` 교정 (H-3 선행) | 동일 | §12.3 N-4″ |
| **H-5** | **`tenants.tenant_name` ↔ `merchant_accounts.merchant_account_name` 동기화 정책** — backfill 은 **초기값 복사**이며 영구 미러가 아니다 | **`601702` §2.2 — 0-A 에서 정하지 않는다** | `601717` §4.5.1 |

> ⚠️ **이 표를 `RESOLVED` 로 적지 않는다.**
> C-1 은 **요구가 살아 있고 이번 계약에서 적용할 수 없을 뿐**이다.
> `RESOLVED` 로 적으면 나중에 **NOT NULL 요구가 폐기된 것으로 읽힌다.**
>
> **이 TestPlan 은 §5.6 에서 「걸리지 않았음」을 검사하고,
> 이 표에서 「걸려야 한다」를 보존한다. 두 가지가 모순이 아니다** — 시점이 다르다.

### §12.5 Stage 6 findings 처분 (2026-08-23)

**Stage 6 독립 검증에서 두 검증자의 결론이 갈렸다.**

```text
601723 Cursor   blocking 0건 — NO CONCERNS FOUND
601724 Codex    blocking 5건 / 고유 findings 7건
```

Claude 통합 결과 **Codex 의 F-1·F-3·F-4·F-5·F-6·F-7 을 실재 findings 로 채택**했다.
따라서 Cursor 의 `NO CONCERNS FOUND` 는 **검증 누락**이다 — `601717` §7.4.

**`601724` Codex — 이 TestPlan 에 반영된 처분**

| # | 지점 | 처분 | 반영 위치 |
|---|---|---|---|
| **F-1** | TP-P-29 ↔ `601717` D-15 | **채택.** 계약이 허용 형태를 `ADD CONSTRAINT … UNIQUE` 하나로 좁혔고, TP-P-29 가 제약명까지 기대값으로 고정 | §4.2 TP-P-29 |
| **F-2** | COMMENT 허용 literal 부재 | **채택.** TP-P-23 을 literal 일치 검사로 바꾸고 **TP-P-38 신설** | §4.2 TP-P-23 · TP-P-38 |
| **F-3** | N-2″ 「확정」↔「판정하지 않는다」 병존 | **채택.** 미판정 서술을 **철회 병기**. 종전 문단은 사실 기록으로 보존 | §12.3 N-2″ 주석 |
| **F-4** | B-8 「CLOSED」↔「여전히 미해소」 병존 | **채택.** §2.2 의 「여전히 미해소」 서술을 **철회**하고 CLOSED 로 정정 | §2.2 |
| **F-5** | TP-RT-03 ↔ FO-33 · TP-N-58 | **채택.** TP-RT-03 **폐기** → **TP-N-62~64 신설**(§5.9). 실행 검증은 §12.4 이월 | §10 · §5.9 |
| **F-6** | `601717` N-4″ 가 TP-RT-03 인용 | **채택.** `601717` 쪽에서 **TP-RT-08** 로 정정 | `601717` §7.3 |
| **F-7** | `601717` §9.2 요약에 H-5 누락 | **채택.** `601717` 쪽에서 H-5 추가 | `601717` §9.2 |

**`601723` Cursor — informational 3건**

| # | 지점 | 처분 |
|---|---|---|
| 1 | I-18·I-19·I-21·I-22·I-25·I-26·I-31·I-32 에 명시 Test ID 없음 | **범위 한정으로 유지.** §14·§0.2 가 schema/backfill 로 범위를 한정했고 FO/negative 가 우회 구현을 막는다. **신규 조치 없음** |
| 2 | TP-P-08 이 `updated_at` 트리거 **존재**만 검사 | **유지.** 갱신 **동작** 검증은 DML 실행을 요구하며 허용 DML 은 M-1·M-2 뿐이다(FO-11). 후속 나선 소관. **신규 조치 없음** |
| 3 | §12.4 「Stage 7 APPROVED」 ↔ PRE-1 「대기」 | **의도적 병기로 유지.** `601717` §10 배너가 pre-decision 보존과 효력 부재를 구분한다. **신규 조치 없음** |

> **Cursor informational 3건은 전부 「신규 조치 없음」이다.**
> 처분하지 않은 것이 아니라 **검토하고 유지 판정한 것**이다.

> ⚠️ **이 절이 있어야 Stage 6 재검증이 가능하다.**
> 재검증자는 F-1~F-7 이 실제로 반영됐는지, Cursor 3건의 유지 판정이 타당한지를 본다.

### §12.6 Stage 6 Round 2 findings 처분 (2026-08-23)

> **finding 위치만 고치지 않는다.**
> R2-F1 이 그 증거다 — 1차 F-1 이 `601717` D-15 에서 `CREATE UNIQUE INDEX` 를 제외했으나
> **§1.6 허용 동사 목록에 그대로 잔존**했다.
> **같은 권한·같은 literal·같은 Test ID 가 등장하는 모든 지점을 함께 정합화한다.**

**검증자 발견 분포 — Round 2**

```text
Cursor        발견 5 / blocking 0
Codex         발견 7 / blocking 5
Antigravity   V11~V14 만 수행. 발견 0
```

두 라운드 연속 같은 패턴이며, 분석과 처분은 `601717` §7.4 에 기록했다.

| # | 지점 | 처분 | 이 TestPlan 의 반영 |
|---|---|---|---|
| **R2-F1** | `CREATE UNIQUE INDEX` 잔존 | **채택.** 계약이 `ALTER TABLE … ADD CONSTRAINT … UNIQUE` 하나로 통일 | TP-P-29 는 이미 제약 형태를 기대한다 — 변경 없음. `601717` §1.6·§4.2 가 정합화됨 |
| **R2-F2** | COMMENT exact literal 미확정 | **채택.** `601717` §4.2.1 이 4건의 exact literal 을 SQL 구문으로 고정 | **TP-P-23 · TP-P-38 에 literal 을 직접 기재**해 1:1 문자열 동일 검사로 만들었다 |
| **R2-F3** | TP-N-63 이 관측 장치를 요구 | **채택.** **정적 증거로 재정의.** 종전 정의는 폐기 기록으로 보존 | §5.9 TP-N-63 · §10 주석 |
| **R2-F4** | H-1 Prerequisite 이 N-6″ 만 연결 | **채택.** N-8″ 도 연결 | `601717` §4.4.3 — 이 TestPlan 은 §12.3 N-8″ 로 승계 |
| **R2-F5** | AC 에 TP-D-09 · H-3a 누락 | **채택.** **AC-4 에 TP-D-09**, **AC-12 에 H-3a** 명시 | §13 AC-4 · AC-12 / `601717` AC-10 |
| **R2-F6** | 재도출 요약의 Test ID 범위가 구판 | **채택(non-blocking).** 현 판 범위로 갱신 | §0.3 대조표 |
| **R2-F7** | `601725 §-4` 가 검증 불가능한 인용 | **채택(non-blocking).** `601725` §H unresolved facts #4 로 정정 | `601717` §7.3 N-8″ |

> ⚠️ **R2-F3 의 처분 원칙을 남긴다.**
>
> ```text
> 도입하지 않는다   pg_stat_statements · 별도 logging
>                   검증을 위한 runtime 구조는 0-A 범위 밖이다
>
> 대신 검사한다     prosrc md5 불변 · migration 본문 · 실행 command 목록
>                   전부 정적 파일·카탈로그 증거다
> ```

## §13 Acceptance Criteria

| # | 조건 |
|---|---|
| AC-1 | §2 Preconditions PRE-1~PRE-8 이 모두 충족됐다 — **PRE-3·5·6·7 은 environment drift 게이트다** |
| AC-2 | §4 Positive 중 `BLOCKED` 가 아닌 항목이 전부 PASS 다 |
| AC-3 | §4.3 에 따라 컬럼명·타입 기대값이 `601717` §4.1 로 확정된 뒤 실행됐다 |
| AC-4 | §4.4 backfill 검증 **TP-D-01~TP-D-09** 가 전부 PASS 다 — **TP-D-09(backfill 구문이 `601717` §4.5.1 확정 SQL 과 동일) 포함**(R2-F5 처분. 종전 범위는 TP-D-08 까지였다) |
| AC-5 | §5 Negative 전 항목이 PASS 다. **하나라도 FAIL 이면 전체 FAIL** |
| AC-6 | **§5.6 · §5.7 이 전부 PASS 다** — NOT NULL 미적용, 두 INSERT RPC 무변경 |
| AC-7 | §6 Regression 전 항목이 PASS 다 |
| AC-8 | §7 External Provider negative 전 항목이 PASS 다 |
| AC-9 | §8 Boundary · §9 Migration 전 항목이 PASS 다 |
| AC-10 | §11 Rollback 계획이 문서로 존재하고 TP-RB-01·TP-RB-02·TP-RB-06·TP-RB-07 을 만족한다 |
| AC-11 | §12.2·§12.3 의 blocker 중 해당 범위에 걸리는 것이 Human 판정으로 해소됐거나 구현에서 제외됐다 |
| AC-12 | **§12.4 의 C-1·C-2·H-1~H-5 가 Stage 7 Approval 에 이월로 명시되어 있다** — **H-3a 포함**(R2-F5 처분). H-3a 는 H-3 의 선행 조건이므로 누락 시 후속 나선이 순서를 잃는다 |
| AC-14 | **I-47 을 강제 장치 유무가 아니라 검증 시점 상태(TP-D-08)로 판정했다** — 강제 부재는 §12.3 N-1″ 이며 FAIL 사유가 아니다 |
| AC-15 | **`create_franchise_store` 의 실패를 이 구현의 결함으로 판정하지 않았다** — TP-RT-08 은 실패 양상 불변만 검사한다(§12.3 N-4″) |
| AC-16 | **`merchant_accounts` 가 `601717` §4.1 확정 정의와 정확히 일치한다** — TP-P-26~31 · TP-N-21 · TP-N-60 · TP-N-61 |
| AC-17 | **§12.4 H-5(name synchronization)가 Approval 에 이월로 명시되어 있다** — `601717` §10.1 항목 5 |
| AC-18 | **TP-M-08 을 clean baseline replay 로만 판정했다** — 동일 DB 재실행 실패는 FAIL 사유가 아니다(`601717` §10.2) |
| AC-13 | 검증자가 상위 문서 및 본 문서의 원작자가 아니다 (`000701` §37) |

> **AC-12 가 없으면 이 나선의 결과가 잘못 읽힌다.**
> `stores.merchant_account_id` 에 제약이 없는 상태를 보고
> 다음 사람이 **「그런 요구가 없구나」** 로 읽으면 §12.4 가 사라진다.

## §14 Out Of Scope

| 대상 | 사유 |
|---|---|
| Store 상태 3축의 값·전이 | `601710` §3 |
| `OperatingGroup` / `company` / `business_unit` persistence | 동일 |
| Staff / User / Session | 0-B (§1.18) |
| Role / Permission / Authorization | 0-C (§1.19·§1.45) |
| `merchant_accounts` 의 application access policy | §1.45 — 0-C 소관 |
| **`provision_tenant` / `create_franchise_store` 의 정렬** | **`601710` §3 RPC 재작성 Out of Scope. `601717` §4.4.3 H-1~H-3 으로 이월** |
| **`stores.merchant_account_id` NOT NULL 승격 검증** | **`601717` §1.5 C-1 이월. §12.4** |
| **`stores.legal_entity_id` NOT NULL 승격 검증** | **`601717` §1.5 C-2 이월. §12.4** |
| 과금·정산 경로 | §2.1 |
| 금전 객체 LegalEntity snapshot (§1.35) / Tenant 이전 (§1.36) | `601710` §2.3 — 원칙 전용 |
| External Provider Mapping 의 **positive** 검증 | §7 — negative 만 수행 |
| 과거 migration 파일의 `owner_` 잔존 | §1.37 「검증 범위」 명시적 제외 |
| **`create_franchise_store` 의 phantom `extra_metadata` 교정** | **`601717` FO-B1 · §4.4.3 H-3a — 후속 RPC alignment 나선** |
| **`onboard_tenant` 의 `stores.brand_id` phantom 참조 조사·교정** | **§12.3 N-5″ — 이번 측정 범위 밖. `601717` FO-D 로 수정 금지** |
| **`tenant_name` ↔ `merchant_account_name` 동기화 동작 검증** | **§12.4 H-5 — backfill 은 초기값 복사이며 영구 미러가 아니다. 동기화 정책은 `601702` §2.2 미결** |
| `stores` 참조 함수 151 vs 158 전수 대조 | `601702` §2.2 — 미결이되 C-1 판정에 영향 없음 |
| `000170` §4 deferred 권장 필드 | `601705` O19 |
| `0168`/`0169` historical disposition 재판정 | `601710` §5.1 |

## §15 근거 문서 목록 (`000701` §46)

| 문서 | 인용 절 | 권위 | 역할 |
|---|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4.1~§5.4.4, §5.7 | ACTIVE | TestPlan 규격·저자 분리·충돌 처리 |
| `docs/000700_…/000701_…Pipeline.md` | §3, §6.11.1, §10, §14.5, §35, §37, §46 | ACTIVE | Stage 게이트·헤더·검증자 분리 |
| `docs/…/601700_Readme_…V2.md` | §4, §5, §10, §10.1 | 본 워크패킷 | In/Out of Scope |
| `docs/…/601701_Register_Stage0_Evidence_Collection.md` | §4.5 D-3, E단계 | 본 워크패킷 | BL-5·BL-20·BL-21·BL-23·N-2″ |
| `docs/…/601702_Register_Stage1_Business_Rules.md` | §1.1, §1.2, §1.18, §1.19, §1.22~§1.27, §1.31, §1.34, §1.37(보강), §1.38, §1.39, §1.43, §1.44, §1.45, §2.1, **§2.2**, §5 | 본 워크패킷 | **최우선 근거** — Human 선언 |
| `docs/…/601705_Diagram_…ERD.md` | **§4.1**, §4.4, §4.6, §5.2, **§8**, §10 (**O20** 포함) | 본 워크패킷 | 물리 정의 · Physical Drift · Open Decisions |
| `docs/…/601710_Overview_…V2.md` | §2, §2.1~§2.3, **§2.4**, **§3**, §3.1, §4, §5, §7 | 본 워크패킷 | 구현 대상 · write-path 실측 · RPC Out of Scope · negative 지시 |
| `docs/…/601711_…Cursor.md` / `601712_…Codex.md` | P-1 ~ P-5 | 본 워크패킷 | 물리 기준선(이중) |
| `docs/…/601713_Logic_…V2.md` | §1.1~§1.5 (**I-1~I-51**), §2~§6 (**Q-10 포함**) | 본 워크패킷 | 불변조건 · 예외 · 미해결. **I-43~I-51 이 5판 기대값의 근거** |
| `docs/…/601714_…Cursor.md` / `601715_…Codex.md` | Environment, Q-2 ~ Q-8 | 본 워크패킷 | 갭 해소 실측(이중) |
| **`docs/…/601718_Evidence_Stores_Write_Path_Scan_Cursor.md`** | **Environment, S-1 ~ S-6** | **본 워크패킷** | **BL-22·BL-28~BL-34 · §5.7 근거** |
| **`docs/…/601719_Evidence_Stores_Write_Path_Scan_Codex.md`** | **Environment, S-1 ~ S-6** | **본 워크패킷** | **동일(이중, `000701` §35)** |
| **`docs/…/601720_Evidence_Stage7_Pre_Measurement_Cursor.md`** | **Environment, PRE-5 · PRE-6 · PRE-7** | **본 워크패킷** | **BL-21·BL-24·BL-35~BL-37 · N-2″ 확정** |
| **`docs/…/601721_Evidence_Stage7_Pre_Measurement_Codex.md`** | **환경, PRE-5 · PRE-6 · PRE-7** | **본 워크패킷** | **동일(이중, `000701` §35)** |
| `docs/…/601717_ChangeContract_…V2.md` | §1.2, §1.5, §4.1, §4.4, §4.4.3, §4.5, §6.1, FO-13, **§10 · §10.1~§10.6** | 본 워크패킷 | 검사 대상 계약 · **Stage 7 승인 기록** |
| `sql/migrations/CHANGELOG.md` | 2026-07-18(phantom 컬럼 사례) · 2026-08-07 | 프로젝트 파일 | B-7 · N-2″ |
| `tools/Check-Governance.ps1` | G15 | 프로젝트 파일 | TP-M-02·TP-M-03 |

**인용하지 않은 것**: `601500` 대역(`601501`~`601512`)의 설계 결론(`600020` §2).

---

> **이 TestPlan 은 구현을 승인하지 않는다.**
> 허용·금지 파일과 물리 표현은 ChangeContract `601717` 이,
> 착수 권한은 Stage 7 Human Approval 이 정한다.
>
> **이 판의 검사 대상은 현재 계약이다.**
> `NOT NULL` 이 걸려 있는지를 묻지 않고, **걸지 않았는지**를 묻는다.
> 두 INSERT RPC 가 값을 공급하는지를 묻지 않고, **건드리지 않았는지**를 묻는다.
>
> 걸려야 한다는 요구는 §12.4 에 살아 있으며 후속 나선이 이어받는다.
> **§12.4 가 Approval 에 이월로 남지 않으면 이 나선의 결과는 잘못 읽힌다.**
>
> **5판이 바꾼 것은 기대값이 아니라 그 근거다.**
> N-5′ 해소로 같은 기대값이 선언 단독이 아니라 Logic 불변조건(I-43~I-51)을 경유해 지지된다.
> 다만 **I-47 만은 강제되지 않는다** — 검증 시점 상태로만 참이며, 그 사실이 §12.3 N-1″ 다.
