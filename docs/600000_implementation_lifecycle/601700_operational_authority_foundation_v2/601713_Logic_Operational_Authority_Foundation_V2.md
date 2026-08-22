# 601713_Logic_Operational_Authority_Foundation_V2.md

Status: Draft
Lifecycle: Logic
Last Updated: 2026-08-22

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-13 | 초안 — 4단계 Logic |
| 2026-08-22 | Stage 2 blocker B-7 반영 — §1.34~§1.44 추가분. §6 질문 9건 전부 해소 병기 |
| 2026-08-22 | N-5′ 반영 — §1.37 보강 · §1.45 · write-path 실측. I-43~I-51 추가 |

## §0 성격과 경계

`000701` §47.1 4단계 산출물이다.
Overview(`601710`)가 정한 구현 대상 5건의 **동작과 불변조건**을 기술한다.

> `000001` §5.4 — `Logic explains how a slice should work.`
> 상태 전이, 예외 처리, 권한, 감사 로직 상세. **구현 전용.**

**이 문서가 하지 않는 것**

| # | 하지 않는 것 | 누구 소관인가 |
|---|---|---|
| 1 | 물리 변경 방법 판정 (rename / 신규 생성 / 그 외) | ChangeContract(`601715`) |
| 2 | SQL·의사 DDL 작성 | ChangeContract |
| 3 | 직접 조사 — DB 재조회 | `601711`/`601712` scan 이 이미 수행 |
| 4 | `601500`(`601501`~`601512`) 결론을 정답으로 전제 | `600020` §2 권위보류 |
| 5 | Overview §4 조건부 enforcement 판정 | ChangeContract |

**저자 분리** (`000001` §5.4.2)

> Overview/Logic 은 Stage 1.5(Claude Code)가, TestPlan/ChangeContract 는 Stage 2(Claude)가
> 각자 독립적으로 작성해야 하며, 한 행위자가 여러 Stage 의 산출물을 대신 작성해서는 안 된다.

이 Logic 의 저자는 Claude Code 다.
조사는 Cursor(`601711`)와 Codex(`601712`)가 독립 수행했고,
Logic 은 그 결과를 **소비**할 뿐 새로 조회하지 않았다.
scan 에 없는 사실이 필요했던 항목은 **§6** 에 기록하고 넘어갔다.

**용어 표기**

`Person` / `MerchantAccount` / `Store` / `LegalEntity` 는 **개념명**이다.
`owners` / `stores` / `legal_entities` 는 **현재 물리 테이블명**이다.
이 문서는 둘을 구분해 쓰며, 개념명이 어느 물리명으로 실현되는지는 판정하지 않는다.

## §1 대상별 동작과 불변조건

Overview(`601710`) §2 의 구현 대상 5건을 순서대로 기술한다.

### §1.1 canonical `Person`

**목표 동작**

- `Person` 은 자연인의 canonical identity 다 (`601702` §1.1, §1.17)
- legacy `owners` terminology 를 authoritative 개념으로 유지하지 않는다 (`601710` §2.1)
- Store / Tenant / 고용 / 로그인 / staff row 에 종속되지 않는다 (`601702` §1.17)
- 같은 자연인이 여러 LegalEntity 에서 역할을 가질 수 있다 (`601702` §1.1)

**불변조건 — 어느 방식을 택하든 지켜져야 하는 것**

| # | 불변조건 | 근거 |
|---:|---|---|
| I-1 | PersonRole 관계 보존 — 역할 행이 canonical Person 을 참조하는 상태가 끊기지 않는다 | `601711` P-1 FK #8 `legal_entity_person_roles_owner_id_fkey` / `601712` P-1 #9 |
| I-2 | Representative 관계 보존 — 대표자 행이 canonical Person 을 참조하는 상태가 끊기지 않는다 | `601711` P-1 FK #9 `legal_entity_representatives_owner_id_fkey` / `601712` P-1 #10 |
| I-3 | 두 FK 의 참조 동작(`ON DELETE NO ACTION` / `ON UPDATE NO ACTION`)이 완화되지 않는다 | `601711` P-1 FK 표 Notes |
| I-4 | `updated_at` 자동 갱신 동작 보존 — canonical 테이블에 UPDATE 가 일어나면 `updated_at` 이 갱신된다 | `601711` P-1 TRIGGER #10 `trg_owners_updated_at` → `catchmenu_common.set_updated_at()` / `601712` P-1 #15, #17 |
| I-5 | 역할 활성 유일성 보존 — `(legal_entity_id, owner_id, role_type)` active 부분 unique 의 의미가 유지된다 | `601712` P-1 #13 `uq_lepr_active` (라이브) / `601711` P-2 `0168` L103–109 |
| I-6 | 대표자 활성 유일성 보존 — `(legal_entity_id, owner_id)` active 부분 unique 의 의미가 유지된다 | `601712` P-1 #14 `uq_ler_active` (라이브) / `601711` P-2 `0168` L139–144 |
| I-7 | SOLE 대표자 유일성 보존 — LegalEntity 당 단독대표 유일 제약이 유지된다 | `601711` P-2 `0169` L5–8 `uq_ler_sole_active` / `601712` P-2 |
| I-8 | 역할 조회 인덱스 보존 — Person 기준 역할 조회 경로가 인덱스 없이 남지 않는다 | `601712` P-1 #12 `idx_lepr_owner` (라이브) / `601711` P-2 `0168` L111–113 |
| I-9 | PK 보존 — canonical Person 은 `uuid` 단일 PK 로 식별된다 | `601711` P-1 INDEX #19 `owners_pkey` / `601712` P-1 #11 |
| I-10 | RLS `ENABLE` + `FORCE` 유지 — 어느 시점에도 둘 중 하나가 꺼진 상태로 남지 않는다 | `601711` P-1 POLICY (`relrowsecurity=true`, `relforcerowsecurity=true`) / `601712` P-1 #22 |
| I-11 | 정책 0개 상태가 **의도된 상태**로 유지된다 — 교정 과정에서 정책이 우발적으로 생기거나 FORCE 가 풀리지 않는다 | `601711` P-1 POLICY 0건 / `601712` P-1 #19 |
| I-12 | `catchmenu_authority_owner` 의 4 privilege(SELECT/INSERT/UPDATE/DELETE, `grantable=NO`)가 확대·축소되지 않는다 | `601711` P-1 GRANT #15–18 / `601712` P-1 #20 |
| I-13 | 소유자(`postgres`) 기본 7 privilege 구성이 바뀌지 않는다 | `601712` P-1 #21 |
| I-14 | 컬럼 의미 보존 — 7컬럼의 자연인 식별·연락처·활성·타임스탬프 역할이 유실되지 않는다 | `601711` P-1 COLUMN #1–7 / `601712` P-1 #2–8. **⚠️ I-36 으로 대체 (2026-08-22)** — `is_active` 는 제거 대상이다(`601702` §1.38) |
| I-15 | 테이블 코멘트가 서술하는 의미(`People who hold operational or legal authority for legal entities.`)가 canonical 개념과 어긋나지 않는다 | `601711` P-1 Table comment |
| I-16 | forward-only — `0168`/`0169` 를 수정하지 않고 신규 번호 migration 으로만 교정한다 | `000701` §14.5 / `601710` §5 |

**2026-08-22 선언 추가분**

| # | 불변조건 | 근거 |
|---|---|---|
| I-34 | `owner_id` → `person_id` 로 정규화한다. FK 제약명·인덱스명도 `person` 기준으로 정렬한다 | `601702` §1.37 |
| I-35 | `legal_entity_representatives` 명칭은 유지한다 | `601702` §1.37 |
| I-36 | `is_active` 를 사람 레코드에서 제거한다. 같은 이름을 다른 의미로 재사용하지 않는다 | `601702` §1.38 |
| I-37 | `ownership_percent` 를 역할 테이블에서 제거한다. `CASCADE` 로 일괄 제거하지 않는다 | `601702` §1.39 |
| I-43 | 트리거명 `trg_owners_updated_at` → `trg_persons_updated_at` | `601702` §1.37 보강 |
| I-44 | 컬럼 `owner_name` → `person_name` | `601702` §1.37 보강 |
| I-45 | `catchmenu_common.set_updated_at()` 함수명은 유지한다 | `601702` §1.37 보강 |
| I-46 | PostgreSQL role `catchmenu_authority_owner` 명칭은 유지한다 | `601702` §1.37 보강 |

> ⚠️ **§1.38 · §1.39 는 §6 의 Q-1 · Q-9 에 대한 답이다.**
>
> 이 Logic 이 "어떤 §1.x 선언도 정의하지 않았다"고 기록한 상태에서
> 선언이 추가되었다. **모순이 아니라 순서다.**
>
> 기존 §2.1 · §6 의 서술은 **작성 시점의 사실 기록으로 보존**한다.
>
> **보존 대상에 I-14 와 §1.1 본문의 `ownership_percent` 서술도 포함된다.**
> 각 자리에 대체 관계를 병기했다. 삭제하지 않는 이유는
> **선언이 답이었다는 사실이 질문과 함께 있어야 추적되기 때문**이다.

> ⚠️ **`owner` 가 들어갔다는 이유만으로 바꾸지 않는다**(`601702` §1.37 보강).
>
> ```text
> 직접 Owner semantic identifier   →  Person 으로 변경
> generic technical identifier     →  유지
> ```
>
> `owner_` 잔존 검사는 **신규 canonical schema 와 forward migration 결과**를 대상으로 한다.
> 과거 migration 에서 0건을 요구하지 않는다.

**I-11 이 왜 불변조건인가**

RLS 가 `FORCE` 이고 정책이 0개면 테이블 소유자를 포함해 통상 경로로는 행을 볼 수 없다.
현재 접근이 성립하는 이유는 `catchmenu_authority_owner` 가 `bypassrls` 로 생성됐기 때문이다
(`601711` P-2 `0169` L10–22 — `nologin`, `bypassrls`).
따라서 **정책 0개는 "미완성"이 아니라 현재 접근 모델의 일부**이며,
교정 중에 이 조합이 깨지면 접근 가능/불가능이 조용히 뒤바뀐다.
어느 쪽이 옳은 최종 모델인지는 이 Logic 이 판정하지 않는다 — 0-C 소관(`601702` §1.19).

**건드리지 않는 것**

| 대상 | 근거 |
|---|---|
| Staff / User / Auth Identity / Session | `601702` §1.18 — 0-B 이관 |
| Role / Permission / Authorization 모델 | `601702` §1.19 — 0-C |
| `ownership_percent` | `601702` §1.3 — 역할과 경제적 지분의 분리만 확정. 모델링은 별도 |
| `role_type` 의 허용값 재정의 | `601702` 선언 없음. §6 참조 |

`ownership_percent` 는 컬럼과 CHECK 제약이 실재하나 사용 금지가 선언된 상태다
(`601711` P-6 / `601712` P-6). 이 Logic 은 **제거도 사용도 지시하지 않는다.**
현 상태를 그대로 두는 것과 제거하는 것 중 무엇을 할지는 ChangeContract 소관이다.

> ⚠️ **I-37 로 대체 (2026-08-22)** — `601702` §1.39 가 제거를 확정했다.
> 위 서술은 **작성 시점의 사실 기록**이다.

**scan 이 확인한 현재 상태**

| 항목 | 실측 | 출처 |
|---|---:|---|
| `owners` 행 수 | 0 | `601711` P-3 / `601712` P-3 |
| `legal_entity_person_roles` 행 수 | 0 | 동일 |
| `legal_entity_representatives` 행 수 | 0 | 동일 |
| `legal_entities` 행 수 | 0 | `601711` P-3 |
| `ownership_percent IS NOT NULL` 행 수 | 0 | 동일 |
| `role_type` distinct 값 | 0 (빈 테이블) | `601711` P-3 |
| VIEW / MATVIEW 참조 | 0 | `601711` P-1 VIEW / `601712` P-1 #16 |
| `owners` 를 직접 참조하는 FUNCTION | 0 | `601711` P-1 FUNCTION / `601712` P-1 #18 |
| RLS POLICY | 0 | `601711` P-1 POLICY / `601712` P-1 #19 |
| 앱·패키지·테스트 코드 참조 | 0 | `601711` P-5 / `601712` P-5 |
| seed SQL 참조 | 0 | `601711` P-5 / `601712` P-3 |
| 관련 migration 파일 | 2 (`0168`, `0169`) | `601711` P-2 / `601712` P-2 |
| `owners` 를 참조하는 문서 | 27 (`601711`) / 30 (`601712`) | P-4 |

> ⚠️ **위 수치는 "물리 교정 부담이 작다"는 사실이지,
> "어떻게 고칠지"의 답이 아니다.**
>
> 데이터 0행·코드 참조 0건은 **데이터 이관 위험이 없다**는 뜻이며,
> rename 이 옳다거나 신규 생성이 옳다는 뜻이 아니다.
> 두 방식 모두 위 I-1~I-16 을 지켜야 한다.
> 방식 선택은 ChangeContract(`601715`)가 판정한다.

한편 **문서 의존은 27~30건으로 물리 의존보다 훨씬 크다.**
교정의 실제 비용은 SQL 이 아니라 **문서 정합화**에 있다는 사실을 기록한다.

### §1.2 persistent `MerchantAccount`

**목표 동작**

- CatchMenu SaaS 계약·관리 단위다 (`601702` §1.14)
- LegalEntity · Brand · User Identity 와 독립된 축이다 (`601702` §1.14)
- Tenant 와 1:1 이다 (`601702` §1.22)
- Store 를 1:N 으로 포함한다 (`601702` §1.14)

**불변조건**

| # | 불변조건 | 근거 |
|---:|---|---|
| I-17 | Tenant isolation 을 변경하지 않는다 — MerchantAccount 도입이 tenant 경계를 넓히거나 좁히지 않는다 | `601702` §1.22 / `010004` §4 |
| I-18 | 서로 다른 LegalEntity 의 Store 를 한 MerchantAccount 가 포함할 수 있으나, **각 Store 의 LegalEntity context 는 독립 보존**된다 | `601702` §1.23 |
| I-19 | MerchantAccount 공유가 LegalEntity 간 재무권한 공유를 뜻하지 않는다 | `601702` §1.23 / `010640` §9 |
| I-20 | MerchantAccount 는 LegalEntity 를 추론하는 근거가 되지 않는다 | `601702` §1.23 |

**scan 이 확인하지 못한 것**

`601711`/`601712` 는 `catchmenu_hq.owners` 를 대상으로 한 조사이므로
`merchant_accounts` 의 물리 존재 여부를 직접 조회하지 않았다.

`601705` §8 이 `MerchantAccount` 를 `CONCEPT PRESENT / PHYSICAL MISSING` 으로 기록했다.
**물리 미구현이면 보존해야 할 기존 의존이 없다**는 것이 논리적 귀결이나,
이는 scan 이 확인한 사실이 아니라 다른 문서의 기록이다. §6 에 확인 항목으로 남긴다.

`000170` §4 가 Merchant Account 의 권장 필드를 제시한다는 사실은 기록한다.
**그러나 `601702` 가 필드 집합을 선언하지 않았으므로 이 Logic 은 필드를 확정하지 않는다.**
`000170` 은 ACTIVE 본문이나, 같은 문서 §6~§9 의 3층 merchant 계층은
`601702` §1.25 가 canonical 이 아니라고 선언했다(`601710` §6.3 #2).
따라서 `000170` §4 를 **필드 참고 자료로만** 취급하고 구조 근거로 삼지 않는다.

**2026-08-22 물리 정의 확정** (`601702` §1.44)

| 항목 | 확정 |
|---|---|
| 물리 entity 명칭 | `merchant_accounts` |
| 0-A 최소 필드 | 식별자 · Tenant 참조 · 계정 명칭 · 생성/수정 시각 |

**미채택**: `primary_owner_user_id` / 서비스·체험 상태 / 청구·계약 연락처
**deferred**: `000170` §4 그 외 권장 필드

| # | 불변조건 | 근거 |
|---|---|---|
| I-38 | `merchant_accounts` 는 LegalEntity 참조를 보유하지 않는다 | `601702` §1.44, §1.23 |
| I-39 | 미채택 필드를 임의로 추가하지 않는다 | `601702` §1.44 |

> ⚠️ **필드명·타입은 확정되지 않았다.** ChangeContract 소관이다.

**2026-08-22 생성·배치·posture 확정** (`601702` §1.45)

| # | 불변조건 | 근거 |
|---|---|---|
| I-47 | Tenant 만 존재하고 MerchantAccount 가 없는 상태를 정상 운영 상태로 허용하지 않는다 | `601702` §1.45 |
| I-48 | 기존 Tenant 는 forward migration 에서 backfill 한다. Tenant 가 0개면 아무 행도 만들지 않는다 | `601702` §1.45 |
| I-49 | 1:1 은 `merchant_accounts` 쪽에서만 강제한다. `tenants` 에 역참조를 두어 순환을 만들지 않는다 | `601702` §1.45 |
| I-50 | `catchmenu_hq` 에 둔다 | `601702` §1.45 |
| I-51 | RLS `ENABLE` + `FORCE`, policy 0개. GRANT 는 `catchmenu_authority_owner` 외에 확대하지 않는다 | `601702` §1.45 |

> ⚠️ **backfill 은 seed 가 아니다.**
> 기존 canonical row 를 새 invariant 에 맞추는 것이며,
> 임의 business data 를 만드는 것이 아니다.
>
> ⚠️ **fail-closed posture 는 임시가 아니다.**
> 0-C 가 그 위에 필요한 접근 정책을 추가한다(`601713` §4).

### §1.3 Tenant ↔ MerchantAccount (1:1)

**목표 동작**

- 이번 나선에서 Tenant 와 MerchantAccount 는 1:1 이다 (`601702` §1.22)

**불변조건**

| # | 불변조건 | 근거 |
|---:|---|---|
| I-21 | 오용 경로 차단 — 독립된 가맹사업자를 "같은 브랜드"라는 이유로 동일 Tenant 에 두지 않는다 | `601702` §1.22 |
| I-22 | 1:1 은 이번 나선의 결정이며, 향후 1:N 은 **실제 사례를 근거로 스키마 변경으로** 연다. 애플리케이션 우회로 열지 않는다 | `601702` §1.22 |
| I-23 | 1:1 이라는 이유로 두 축을 하나로 합치지 않는다 — Tenant 는 격리 축, MerchantAccount 는 계약 축으로 분리 유지 | `601702` §1.14, §1.22 / `601705` §5.3 |

**I-23 이 왜 필요한가**

1:1 관계는 "한 테이블로 합쳐도 된다"는 유혹을 만든다.
합치면 향후 1:N 확장이 스키마 변경이 아니라 **개념 분해**가 되어 비용이 급증하고,
`601704` Q1 이 「추정만 가능」으로 남겼던 미확정성이 구조에 고착된다.

### §1.4 MerchantAccount → Store (1:N)

**목표 동작**

- Store 로 가는 **구조 경로는 `Tenant → MerchantAccount → Store` 하나**다 (`601702` §1.26)
- 한 MerchantAccount 가 복수 Store 를 포함한다 (`601702` §1.14 / `000170` §7 / `020320` §40)

**불변조건**

| # | 불변조건 | 근거 |
|---:|---|---|
| I-24 | **Tenant 는 Store 의 두 번째 구조 부모가 아니다.** Tenant–Store 관계는 격리 invariant 다 | `601702` §1.26 / `601705` §5.3 |
| I-25 | 모든 Store 는 Tenant scope 를 보유하고 검증한다 | `010004` §4 / `010640` §7·§8 |
| I-26 | `stores.tenant_id` 의 물리 보유는 격리·RLS 를 위한 것이며 **개념적 두 번째 소유 계층이 아니다** | `601702` §1.26 / `010004` §4 |
| I-27 | Store 를 MerchantAccount 없이 Tenant 에 직접 매달지 않는다 | `601702` §1.26 |

**I-24 ~ I-26 을 명시하는 이유**

물리적으로 `stores` 가 `tenant_id` 와 (신설될) merchant account 참조를 **둘 다** 갖게 되면,
읽는 사람이 이를 이중 소유 경로로 오해하기 쉽다.
`003020` 이 이미 이중 FK 안티패턴을 경고하고 있다(`601711` P-4 #2 / `601712` P-4.1 #2).
이 Logic 은 **두 컬럼의 역할이 다르다**는 것을 불변조건으로 고정한다 —
하나는 격리 경계, 하나는 구조 부모다.

물리 컬럼을 어떻게 둘지는 ChangeContract 소관이다.

### §1.5 Store–LegalEntity (조건부)

**목표 동작**

- 각 Store 는 **현재 시점의** 법적 운영주체를 명시한다 (`601702` §1.24)

**불변조건**

| # | 불변조건 | 근거 |
|---:|---|---|
| I-28 | **검증되지 않은 synthetic LegalEntity 를 생성하지 않는다.** placeholder 로 `stores.legal_entity_id` 를 채우지 않는다 | `601702` §1.31 |
| I-29 | business identity 의 원천은 검증된 영업 intake 다 | `601702` §1.31 / `010901` §11 |
| I-30 | `store_operator_type` 으로 LegalEntity 를 추론하지 않는다. `FRANCHISEE`/`DIRECT` 어느 값도 LegalEntity 배정 근거가 아니다 | `601702` §1.32 |
| I-31 | Store 당 LegalEntity 개수는 **미정 상태를 유지**한다. 이번 나선이 `정확히 1` 로 확정하지 않는다 | `601705` §5.2 U1 / `601710` §6.3 #4 |
| I-32 | LegalEntity 는 tenant 에 종속되지 않는 전역 개념이다 — 하나의 LegalEntity 가 서로 다른 tenant 의 Store 를 운영할 수 있다 | `010004` §4.1 판별 기준 |
| I-33 | 법적 운영주체가 바뀌는 경우(양도·승계)에 **과거 시점의 주체를 알 수 없게 만들지 않는다** | `601702` §1.24 「현재 시점의」 |

**2026-08-22 선언 추가분**

| # | 불변조건 | 근거 |
|---|---|---|
| I-40 | Store–LegalEntity 배정은 유효기간을 갖는 시점 관계로 표현한다 | `601702` §1.34 |
| I-41 | 유효기간이 겹치는 두 운영주체가 동시에 존재하지 않는다 | `601702` §1.34 |
| I-42 | Store 의 현재 운영주체 값은 권위 원본이 아니라 현재 포인터다 | `601702` §1.34 |

> ⚠️ **enforcement 조건은 바뀌지 않는다.**
> 시점 관계로 표현하든 단일 값이든 **검증된 business identity 없이 채울 수 없다**(§1.31).

**I-33 은 이력 테이블을 지시하지 않는다**

`601702` §1.24 가 "현재 시점의 법적 운영주체"라고 선언했으므로,
현재값을 덮어쓰는 구조는 과거 주체를 잃는다.
이 Logic 은 **잃어도 되는지가 선언되지 않았다**는 사실을 기록할 뿐이며,
이력 보존 방식(SCD·감사 로그·별도 테이블 등)을 지시하지 않는다. §6 참조.

**enforcement 판정은 Logic 이 하지 않는다**

Overview(`601710`) §4 의 조건 판정은 ChangeContract 소관이다.
Logic 은 **"enforcement 가 가능해지려면 무엇이 참이어야 하는가"** 만 기술한다.

| # | `stores.legal_entity_id` 를 NOT NULL 로 만들 수 있으려면 |
|---:|---|
| E-1 | 모든 Store 가 검증된 business identity 를 확보했다 (`010901` §11 intake 완료) |
| E-2 | 그 identity 로부터 canonical LegalEntity 가 생성·연결됐다 (I-28 을 위반하지 않고) |
| E-3 | mapping completeness 가 검증됐다 — 미매핑 Store 가 0 이다 |
| E-4 | 신규 onboarding 경로가 LegalEntity 없이 Store 를 만들 수 없다 |

> E-1~E-3 이 **기존 데이터**에 대한 조건이고, E-4 가 **향후 유입**에 대한 조건이다.
> 둘은 별개다. E-4 만 충족하고 NOT NULL 을 걸면 기존 행에서 실패한다.
>
> 현재 실측은 `legal_entities` 0행 / `stores` 1행 / 백필 0행이다(`601701` §4.5 D-3).
> **이 수치만으로 E-1 이 거짓이라고 판정하지 않는다.**
> 원인이 intake 미수행인지 여부는 onboarding evidence 로 확인한다(`601702` §1.31). §6 참조.

**2026-08-22 write-path 실측** (`601718` / `601719`)

두 조사가 상대 결과를 참조하지 않고 동일 수치에 도달했다.

| 항목 | 실측 |
|---|---|
| `stores` 참조 함수 | 158 |
| INSERT 경로 | 2 — `provision_tenant` / `create_franchise_store` |
| INSERT 형태 | 둘 다 `COLUMN_LIST` |
| `NO_COLUMN_LIST` / `ROW_TYPE` | 0 / 0 |
| `SELECT *` · 행 타입 의존 | 0 |
| 앱 코드 직접 INSERT | 0 |

**두 INSERT 경로 모두 `merchant_account_id` 를 공급하지 않는다.**

> ⚠️ 이 실측은 `601717` §1.5 C-1 판정의 직접 근거다.
> **Logic 은 판정하지 않는다.** 사실만 승계한다.

## §2 상태 전이

`000001` §5.4 가 Logic 에 상태 전이 기술을 요구한다.

**이번 나선에서 상태 전이를 정의하지 않는다.**

| 대상 | 사유 |
|---|---|
| Store 서비스·운영·trial 상태 3축 | `601702` §1.27 — 축만 확정, enum·전이 미결. `601710` §3 out of scope |
| `tenant_status` / `isolation_state` | `601505` §4 금지 조항이 0-A-2 완료까지 유효(`601710` §5). 0-A-2 소관 |
| Trial → Production 전환 | `601702` §2.1 과금 경계. 과금과 운영권한 관계 미결 |
| Store 계층별 상태 독립성 | `601702` §1.28 — 독립이라는 것만 확정, 값 미정 |

### §2.1 신규 구현 대상에 상태 전이가 필요한가

**`Person` — 이번 나선에서는 필요 없다.**

`Person` 은 자연인 canonical identity 이며 Store/Tenant/고용/로그인에 종속되지 않는다
(`601702` §1.17). 종속이 없으므로 **다른 축의 상태 변화에 따라 전이할 것이 없다.**

다만 물리에는 `is_active boolean NOT NULL DEFAULT true` 가 실재한다
(`601711` P-1 COLUMN #5 / `601712` P-1 #6).
**어떤 §1.x 선언도 자연인의 `is_active` 가 무엇을 뜻하는지 정의하지 않았다.**
2값 플래그를 상태 기계로 승격하지 않으며, 의미 확정은 §6 항목으로 넘긴다.

**`MerchantAccount` — 이번 나선에서는 정의하지 않는다.**

`000170` §5(Merchant Account Types) · §10(Trial Merchant) · §11(Production Merchant)이
ACTIVE 본문에 상태 어휘를 두고 있으나,
`601702` 는 MerchantAccount 의 상태를 선언하지 않았고
Trial 전환은 §2.1 과금 경계에 걸린다.

> **선언되지 않은 상태를 Logic 이 만들어내지 않는다.**
> MerchantAccount 는 이번 나선에서 **상태 없는 계약·관리 단위**로 도입되며,
> 상태가 필요하다는 것이 확인되면 그때 선언을 받아 별도 나선에서 추가한다.

**`Tenant ↔ MerchantAccount` / `MerchantAccount → Store` / `Store–LegalEntity`**

관계이지 상태가 아니다. 전이 대상이 없다.
단 `Store–LegalEntity` 는 §1.5 I-33 이 지적한 대로
**운영주체 변경이라는 사건**이 존재할 수 있으나, 그 처리는 선언되지 않았다. §6 참조.

## §3 예외 처리

`601711`/`601712` scan 이 확인한 의존을 근거로,
교정 중 발생 가능한 실패 지점과 **그때 무엇이 참이어야 하는지**를 기술한다.

**복구 절차나 rollback SQL 을 쓰지 않는다.** ChangeContract 소관이다.

| # | 실패 지점 | 무엇이 참이어야 하는가 | 근거 |
|---:|---|---|---|
| X-1 | 두 FK 중 하나만 canonical Person 을 향하고 다른 하나가 남겨진 상태 | 두 하위 테이블의 참조 대상이 **동시에** 같은 canonical 대상을 가리킨다. 한쪽만 이관된 중간 상태로 커밋이 끝나지 않는다 | `601711` P-1 FK #8·#9 |
| X-2 | FK 는 옮겨졌으나 참조 동작이 `CASCADE` 등으로 바뀐 상태 | `ON DELETE / ON UPDATE` 가 `NO ACTION` 으로 유지된다 (I-3) | `601711` P-1 FK Notes |
| X-3 | 트리거가 새 대상에 붙지 않아 `updated_at` 이 멈춘 상태 | canonical 대상에 UPDATE 트리거가 존재하고 `catchmenu_common.set_updated_at()` 을 호출한다 (I-4) | `601711` P-1 TRIGGER #10 / `601712` P-1 #15 |
| X-4 | 부분 unique 인덱스가 재생성되지 않아 활성 중복이 허용되는 상태 | `uq_lepr_active` / `uq_ler_active` / `uq_ler_sole_active` 의 유일성 의미가 끊긴 구간 없이 유지된다 (I-5~I-7) | `601712` P-1 #13·#14 / `601711` P-2 `0169` L5–8 |
| X-5 | 조회 인덱스 누락으로 역할 조회가 순차 스캔이 되는 상태 | Person 기준 역할 조회 인덱스가 존재한다 (I-8) | `601712` P-1 #12 |
| X-6 | 새 대상에 RLS 가 켜지지 않았거나 `FORCE` 가 빠진 상태 | `ENABLE` 과 `FORCE` 가 **둘 다** 설정돼 있다 (I-10) | `601711` P-1 POLICY / `601712` P-1 #22 |
| X-7 | RLS 는 켜졌으나 GRANT 가 새 대상으로 따라가지 않아 `catchmenu_authority_owner` 가 접근 불가가 된 상태 | 4 privilege 가 `grantable=NO` 로 유지된다 (I-12) | `601711` P-1 GRANT #15–18 |
| X-8 | GRANT 는 따라갔으나 `bypassrls` 전제가 깨져 조용히 접근 가능/불가능이 뒤바뀐 상태 | 정책 0개 + `FORCE` + `bypassrls` role 이라는 **조합 전체**가 의도대로 유지된다 (I-11) | `601711` P-2 `0169` L10–22 |
| X-9 | 문서는 `owners` 를 가리키는데 물리는 canonical 로 바뀐 상태 | 27~30건의 문서 의존이 **어느 시점에 정합화되는지**가 정해져 있다. 물리만 바뀌고 문서가 남으면 다음 나선이 다시 어긋난 어휘를 근거로 삼는다 | `601711` P-4 (27) / `601712` P-4.1 (30) |
| X-10 | `0168`/`0169` 를 수정해 교정하려는 상태 | forward migration 으로만 교정한다 (I-16) | `000701` §14.5 |
| X-11 | Stage 7 승인 없이 migration 이 적용된 상태 | 승인 기록이 선행한다. `-- Workpacket: 601700` 헤더가 있다 | `000701` §10, §6.11.1 |

**X-9 를 예외 처리에 넣는 이유**

물리 의존은 FK 2 · TRIGGER 1 · INDEX 4 로 작고, 데이터는 0행이다.
반면 **문서 의존은 27~30건**이다(`601711` P-4 / `601712` P-4.1).
`600020` §1.1 사유 4가 기록한 1차 0-A 실패는 물리 실패가 아니라 어휘 실패였다.
따라서 "문서가 물리를 따라오지 못한 상태"는 이 교정에서 가장 큰 실패 지점이며,
**정합화 시점이 정해지지 않은 채 물리를 바꾸는 것**을 예외 상황으로 명시한다.

## §4 권한

**현재 상태 — scan 실측**

| 항목 | 값 | 출처 |
|---|---|---|
| RLS | `ENABLE` + `FORCE` | `601711` P-1 / `601712` P-1 #22 |
| POLICY | 0건 | `601711` P-1 / `601712` P-1 #19 |
| GRANT — `catchmenu_authority_owner` | SELECT / INSERT / UPDATE / DELETE, `grantable=NO` | `601711` P-1 #15–18 / `601712` P-1 #20 |
| GRANT — `postgres` (소유자) | 기본 7 privilege, `grantable=YES` | `601712` P-1 #21 |
| role 속성 | `nologin`, `bypassrls` | `601711` P-2 `0169` L10–22 |
| `owners` 를 참조하는 FUNCTION | 0건 | `601711` P-1 / `601712` P-1 #18 |

**불변조건** — I-10 ~ I-13, X-6 ~ X-8 참조.

**이 Logic 이 정하지 않는 것**

- **권한 모델 자체는 0-C 소관**이다 (`601702` §1.19).
  Role / Permission / Scope 의 정의, RBAC/ABAC 실행 계층은 이번 나선 밖이다.
- 정책 0개 상태를 유지할지 정책을 추가할지 판정하지 않는다.
  현재 조합을 **보존**하라는 것이 이 Logic 의 요구다.
- `601503` §9 SECURITY DEFINER 6규칙의 현황은 `601701` §4.15 에 정리돼 있다.
  `601503` 은 권위보류이며 `601710` §6.2 가 배제한 문서다.
  이 Logic 은 `601503` 을 직접 인용하지 않고 `601701` §4.15 의 현황 기록만 참조한다.

**미해결로 남는 접근 경로**

`601512` §2.3 은 전역 테이블 접근이 SECURITY DEFINER 함수를 경유한다고 서술하나,
두 scan 모두 **참조 함수 0건**을 실측했다(`601710` §6.3 #6).
따라서 **현재 실제 접근 주체가 누구인지가 확인되지 않았다.** §6 참조.

## §5 감사

**이번 구현이 남겨야 할 감사 흔적**

| # | 남겨야 할 것 | 근거 |
|---:|---|---|
| A-1 | 신규 migration 파일 상단 5행 이내 `-- Workpacket: 601700` 헤더 | `000701` §6.11.1 |
| A-2 | Stage 7 Human Approval 기록 — 승인 없이 migration 이 나가지 않는다 | `000701` §10 / `601710` §7 |
| A-3 | 교정 전 물리 기준선 — `601711`/`601712` 가 그 baseline 이다. 사후 Verification 이 **같은 카탈로그 질의를 재실행해 비교**할 수 있어야 한다 | `601711` Executed queries / `601712` 실행한 쿼리 전문 |
| A-4 | `0168`/`0169` 로부터 이어지는 계보가 끊기지 않는 기록 — 무엇이 왜 대체됐는지 | `000701` §14.5 / `601711` P-2 |
| A-5 | 문서 정합화 대상 목록과 처리 결과 — `601711` P-4 27건 / `601712` P-4.1 30건이 그 모집단이다 | X-9 |
| A-6 | 권위보류 문서(`601500` 대역) 는 정합화 대상이 아니라 **폐기·이월 판정 대상**이라는 구분 | `600020` §2 |

**G15 자동 검출**

`tools/Check-Governance.ps1` 의 G15 가 Stage 7 미승인 상태의 migration 을
커밋 시점에 검출한다(`000701` §6.11.1). 헤더가 없으면 ChangeContract 를 찾지 못한다.

**감사 로직 자체는 이번 나선에서 만들지 않는다**

`Person` / `MerchantAccount` 에 대한 변경 이력 테이블·감사 트리거를 지시하지 않는다.
`601702` 에 그런 선언이 없고, 감사 로그 모델은 이번 구현 대상 5건에 포함되지 않는다.
단 §1.5 I-33(법적 운영주체 변경 이력)은 **필요성이 확인되지 않은 상태**로 §6 에 남긴다.

## §6 scan 이 답하지 못한 것

Logic 이 필요로 했으나 `601711`/`601712` 에 없는 사실이다.
**ChangeContract 작성 전에 추가 조사 또는 Human 선언이 필요한 항목**이다.

| # | 필요한 사실 | 왜 필요한가 | 성격 |
|---:|---|---|---|
| Q-1 | `owners.is_active` 의 업무 의미 | 자연인에게 "비활성"이 무엇인지 정의되지 않으면 canonical `Person` 이 그 컬럼을 승계해야 하는지 판단할 수 없다. §2.1 참조 | Human 선언 필요. **해소 (2026-08-22)** — `601702` §1.38: `is_active` 를 사람 레코드에서 **제거**한다 |
| Q-2 | `legal_entity_person_roles.role_type` 의 허용값 | `0168` L85–92 에 CHECK 가 있으나 테이블 0행이라 distinct 값이 0이다(`601711` P-3). Person 교정 시 역할 의미를 보존하려면 값 집합이 필요하다 | 추가 조사 (migration 본문). **해소 (2026-08-21~22)** — `601714`/`601715` 실측 |
| Q-3 | `catchmenu_common.set_updated_at()` 의 정의 | I-4 가 이 함수의 동작 보존을 요구하나, 두 scan 모두 **호출 관계만** 확인하고 함수 본문은 조사하지 않았다(`601712` P-1 #17) | 추가 조사. **해소 (2026-08-21~22)** — `601714`/`601715` 실측 |
| Q-4 | 현재 `catchmenu_authority_owner` 로 접속하는 실제 주체 | role 은 `nologin`·`bypassrls` 이고 참조 함수는 0개다. **누가 어떤 경로로 이 테이블에 접근하는지 확인되지 않았다.** X-7·X-8 의 판정 근거가 된다 | 추가 조사. **해소 (2026-08-21~22)** — `601714`/`601715` 실측 |
| Q-5 | `merchant_accounts` 의 물리 존재 여부 | §1.2 가 "물리 미구현이므로 보존할 의존이 없다"에 의존한다. 두 scan 은 `owners` 대상이라 이를 직접 조회하지 않았고, 근거는 `601705` §8 문서 기록뿐이다 | 추가 조사. **해소 (2026-08-21~22)** — `601714`/`601715` 실측 |
| Q-6 | `legal_entities` / 두 junction 테이블의 canonical 명칭 | `601702` 는 `Person` 만 명명했다. 나머지 3테이블명을 유지하는지 함께 교정하는지 선언이 없다. 교정 범위가 여기서 갈린다 | Human 선언 필요. **해소 (2026-08-22)** — `601702` §1.37: `owners`→`persons`, `owner_id`→`person_id`. `legal_entity_representatives` 명칭은 유지 |
| Q-7 | 법적 운영주체 변경 시 과거 주체 보존 필요 여부 | `601702` §1.24 는 "현재 시점"만 선언했다. 과거를 잃어도 되는지가 미선언이다. I-33 참조 | Human 선언 필요. **해소 (2026-08-22)** — `601702` §1.34: 유효기간을 갖는 시점 관계. 다만 enforcement 는 §1.31 조건에 걸림 |
| Q-8 | `stores` 의 onboarding evidence — intake 수행 여부 | Overview §4 의 E-1 판정 근거다. `legal_entities` 0행의 원인이 intake 미수행인지 확인해야 한다(`601702` §1.31). scan 범위 밖이다 | 추가 조사. **해소 (2026-08-21~22)** — `601714`/`601715` 실측 |
| Q-9 | `ownership_percent` 컬럼·CHECK 의 처리 방침 | 사용 금지가 선언됐으나 물리는 실재한다. 남길지 제거할지 선언이 없다(`601702` §1.3 은 분리만 확정) | Human 선언 필요. **해소 (2026-08-22)** — `601702` §1.39: `ownership_percent` 를 역할 테이블에서 **제거**한다 |
| Q-10 | `stores` write-path 형태 — INSERT 경로 수와 컬럼 목록 명시 여부 | `merchant_account_id` 를 공급하지 않는 INSERT 가 있으면 NOT NULL 승격이 그 경로를 깨뜨린다 | 추가 조사 — **해소 (2026-08-22)** `601718`/`601719` 실측 |

**합계 10건** — Human 선언 필요 4건(Q-1, Q-6, Q-7, Q-9) / 추가 조사 6건(Q-2, Q-3, Q-4, Q-5, Q-8, Q-10).

> Q-2 · Q-3 은 migration 파일과 함수 정의를 읽으면 해결되며 DB 재조회가 필요 없을 수 있다.
> **이 Logic 이 직접 읽지 않은 이유는 저자 분리다** — 조사자와 설계자가 한 행위자에 섞이면
> `000701` §37 이 막으려는 상태가 된다.

### 두 scan 이 다르게 기록한 것

판정하지 않고 사실만 기록한다. ChangeContract 가 필요하면 확인한다.

| 항목 | `601711` (Cursor) | `601712` (Codex) |
|---|---|---|
| P-4 문서 건수 | 27 | 30 (+ 일반 `owner_id` 8건 별도) |
| `600010` 의 권위 | ACTIVE | 권위보류 |
| `601200` 의 권위 | ACTIVE | 권위보류 |
| 하위 테이블 인덱스 | P-2 migration 계보로만 기록 | P-1 라이브 실측으로 기록(#12–14) |
| TRIGGER 건수 | 5 (user 1 + internal RI 4) | 1 (user only) |
| GRANT 건수 | 4 (non-postgres) | 11 (postgres 7 포함) |

> 건수 차이는 대체로 **집계 기준 차이**이며 모순이 아니다.
> 다만 `600010`/`601200` 의 권위 표기는 두 조사가 실제로 다르게 판단한 것이다.
> `600020` §2 는 `601500` 대역을 권위보류로 두었고 `600010`/`601200` 은 그 대역이 아니다.
> **이 Logic 은 어느 쪽이 옳은지 판정하지 않으며**, 두 문서 모두 이 Logic 의 근거로 쓰지 않았다.

## §7 근거 문서 목록 (`000701` §46)

Overview(`601710`) §6.1/§6.2 가 이미 79건을 전수 분류했다.
**여기에는 Logic 이 추가로 인용한 것만 기록**하고, 나머지는 `601710` §6 을 참조한다.

| 문서 | 인용 | 권위 |
|---|---|---|
| `docs/000001_Md_Rules.md` | §5.4 (Logic 규격), §5.4.2 (저자 분리 원칙) | ACTIVE |
| `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601711_Evidence_Person_Physical_Impact_Scan_Cursor.md` | P-1 ~ P-6, Executed queries | 본 워크패킷 |
| `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601712_Evidence_Person_Physical_Impact_Scan_Codex.md` | P-1 ~ P-6, 실행 쿼리 전문 | 본 워크패킷 |
| `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601710_Overview_Operational_Authority_Foundation_V2.md` | §2, §3, §4, §5, §6.3, §7 | 본 워크패킷 |

**`601710` §6.1 에서 이어받아 인용한 문서**
`601702`(§1.1·§1.3·§1.14·§1.17~§1.19·§1.22~§1.24·§1.26~§1.28·§1.31·§1.32·§2.1) ·
`601701`(§4.5 D-3, §4.15) · `601705`(§5.2, §5.3, §8) · `601704`(Q1) ·
`000170`(§4, §5, §7, §10, §11) · `000701`(§10, §14.5, §37, §6.11.1, §46, §47.1) ·
`003020`(§2) · `010004`(§4, §4.1 판별 기준) · `010640`(§7, §8, §9) ·
`010901`(§11) · `020320`(§40) · `600020`(§1.1, §2)

**권위보류 문서 인용 — 명시**

| 문서 | 인용 위치 | 어떻게 썼는가 |
|---|---|---|
| `601505` §4 | §2 상태 전이 | 금지 조항이 0-A-2 완료까지 유효하다는 **사실**만 인용. 설계 결론을 전제하지 않았다 |
| `601512` §2.3 | §4 미해결 접근 경로 | scan 실측(함수 0건)과 **어긋난다는 사실**로만 인용 |
| `601503` §9 | §4 | **직접 인용하지 않았다.** `601701` §4.15 의 현황 기록만 참조 |

`601501`~`601512` 의 설계 결론을 정답으로 전제한 곳은 없다(`600020` §2).

---

> **이 Logic 은 구현 방법을 정하지 않는다.**
> 어느 방식을 택하든 §1 의 I-1~I-33 과 §3 의 X-1~X-11 이 지켜져야 한다는 것,
> 그리고 §6 의 Q-1~Q-9 이 먼저 해소돼야 한다는 것이 이 문서의 결론이다.
> 방식 선택과 허용 파일 범위는 ChangeContract(`601715`)가, 착수 권한은 Stage 7 이 정한다.
