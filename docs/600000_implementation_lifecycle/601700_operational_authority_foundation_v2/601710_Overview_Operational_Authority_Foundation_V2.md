# 601710_Overview_Operational_Authority_Foundation_V2.md

Status: Draft
Lifecycle: Overview
Last Updated: 2026-08-13

**개정 이력**

| 일자 | 내용 |
|---|---|
| 2026-08-13 | 초안 — 4단계 설계문서 정합화 |

> **표기 규약**
>
> | 표기 | 의미 |
> |---|---|
> | **Source Fact** | ACTIVE 문서 또는 실측이 서술하는 사실. 이 Overview 가 만들어낸 것이 아니다 |
> | **Human Decision** | `601702` 1단계 선언. Human 이 확정했고 AI 가 바꿀 수 없다 |
> | **Overview Judgement** | 위 둘을 근거로 이 문서가 내린 구현 범위 판단. Stage 7 승인 대상 |

## §1 Purpose

**0-A v2 는 design-to-implementation correction lifecycle 이며 설계만 하는 작업이 아니다.**

승인된 0-A Core 모델 중 물리화가 충분히 결정된 부분을
**새로운 forward migration 으로 구현**한다.
과거 `0168`/`0169` migration 은 **수정하지 않는다**(`000701` §14.5).

> **Source Fact**: 1차 0-A(`601500`)는 Stage 6·7 미수행 상태에서 Stage 8~12 를 통과했고
> 2026-08-10 권위가 보류되었다(`600020` §1.1).
>
> **Human Decision**: `601500` 을 답안지로 사용하지 않는다(`600020` §2, `601702` §3).
>
> **Overview Judgement**: 따라서 이 Overview 는 `601702` 선언과 ACTIVE 문서에서
> 독립적으로 구현 범위를 도출한다. 결과가 일부 같아지는 것은 허용하되
> 기존 구현에 맞추지 않는다.

## §2 Implementation Target

| # | 대상 | 근거 | 성격 | 비고 |
|---|---|---|---|---|
| 1 | canonical `Person` physical representation | `601702` §1.1, §1.16, §1.17 | Human Decision | 구현 방식은 ChangeContract 가 결정 — §2.1 |
| 2 | persistent `MerchantAccount` foundation | `601702` §1.14, §1.22, §1.23 | Human Decision | 현재 `CONCEPT PRESENT / PHYSICAL MISSING`(`601705` §8) |
| 3 | Tenant ↔ MerchantAccount (1:1) | `601702` §1.22 | Human Decision | `601704` Q1 은 「추정만 가능」이었고 1단계가 확정 |
| 4 | MerchantAccount → Store (1:N) | `601702` §1.14, `601704` Q2 | Human Decision + Source Fact | `000170` §7, `020320` §40 |
| 5 | Store–LegalEntity target invariant | `601702` §1.24, §1.31 | Human Decision | **조건부 — §4** |

**대상 5건 전부 `601702` 선언에 직접 근거한다.** 선언 없이 추가한 구현 대상은 없다.

### §2.1 `Person` — Overview 가 정하는 것과 정하지 않는 것

**정한다**: canonical physical concept 는 `Person` 이며
legacy `owners` terminology 를 authoritative 로 남기지 않는다.

**정하지 않는다**: 구현 방식.
`owners → persons` rename 인지 신규 생성 후 교체인지는
**physical impact scan 후 ChangeContract 가 결정**한다.

이유: `legal_entity_person_roles` / `legal_entity_representatives` 가
현재 `owners` 를 참조하며, `ownership_percent` 혼재(§1.3)도 남아 있다.

> **Source Fact**(`601701` §4.2 B-1·C-2): 네 테이블은 실재하나 참조 함수 0개,
> RLS 정책 0개, 데이터 0행이다. `ownership_percent` 는 문서상 사용 금지인데 컬럼·CHECK 가 실재한다.
>
> **Overview Judgement**: 참조 함수가 0개라는 사실이 rename 을 쉽게 만들지만,
> 그것만으로 방식을 확정하지 않는다. 앱 코드·뷰·정책의 physical impact scan 이 선행해야 한다.

## §3 Out of Scope

| 대상 | 제외 사유 |
|---|---|
| Store 상태 3축의 값·전이 | `601702` §1.27 — 축만 확정, enum 미결. §2.1 과금 경계 |
| `OperatingGroup` persistence | `601702` §1.30 — ACTIVE 문서 넷이 미결 |
| Staff / User / Session | `601702` §1.18 — 0-B 인계 |
| Role / Permission / Authorization | `601702` §1.19 — 0-C |
| 과금과 운영권한 관계 | `601702` §2.1 |
| RPC 재작성 | `601700` Readme §5 |
| `FranchiseAgreement` | `601702` §1.10 — Franchise OS 소관 |
| 고객사-side `company` 엔티티 | `601702` §1.29 — 분해 대상 legacy terminology |
| `cross_business_link` 물리 구조 | `601702` §1.33 — `000190` §10이 필드 제시, 구현은 후속 |
| `store_operator_type` 물리 표현 | `601702` §1.32 — 축 분리만 확정 |
| External Provider Mapping (Toss / Smartcast 등) | `601702` §1.43 — 경계는 확정했으나 물리 구조는 integration contract 확보 후. §3.1 참조 |

### §3.1 External Provider Mapping — Deferred Boundary

`601702` §1.43 이 외부 provider 연결을 플랫폼 구조의 일부로 선언했다.
**다만 이번 나선에서 물리 구현을 하지 않는다.**

**0-A 에서 확정하는 것**

```text
External Provider Boundary 가 존재한다는 사실
Core authority 와 Provider authority 의 분리
provider-specific 식별자를 canonical identity 로 사용하지 않는다는 원칙
향후 mapping 이 필요하다는 선언
```

**0-A 에서 만들지 않는 것**

```text
provider mapping table
외부 provider 전용 컬럼
provider contract 를 추정한 schema
```

**사유**

Toss / Smartcast 의 실제 identifier 구조가 확보되지 않았다.
성급하게 만들면 provider 의 실제 축과 어긋나 재작업이 발생한다.

```text
지금 추정하면            실제 provider 는
tenant_id / store_id /   merchant_id / terminal_id /
external_store_id        business_registration_no / shop_id
```

**빈 테이블도 설계 결정이다.** 데이터가 없다고 비용이 0인 것은 아니다.

**§1.43 의 실질은 데이터 모델이 아니라 Authority Boundary 다**

```text
금지   stores.id = 외부 provider 의 merchant id

원칙   CatchMenu canonical identity
              │ mapping
              ▼
       External provider identity
```

**mapping 이 필요하다는 것**과 **mapping 테이블의 형태를 지금 안다는 것**은
전혀 다른 문제다.

**후속 처리**

0-B(Identity / Login / Session / Role / Permission)로 넘기지 않는다. 책임 축이 다르다.

```text
0-A                        Tenant / LegalEntity / Store canonical foundation
        ↓
별도 Integration 워크패킷    Provider identity / mapping / contract
        ↓
                           TOSS-TX  POS / Kiosk / Payment
                           SC-EXEC  KDS / DID
```

실제 계약·API·identifier 구조를 확보한 뒤
**별도 Provider Integration / External Identity Mapping 워크패킷**에서 설계한다.
워크패킷 번호는 지금 확정하지 않는다.

## §4 조건부 항목 — Store–LegalEntity

> ⚠️ **Human business data 가 없는 것을 설계가 만들어내지 않는다**(`601702` §1.31).

**현재 실측**(`601701` D-3) — Source Fact

```text
legal_entities          0행
stores.legal_entity_id  NULL, 백필 0행
stores                  1행
```

**business identity 의 원천**(`601702` §1.31 / `010901` §11)

```text
Business Registration Intake
  business registration number / legal entity name / representative name /
  business address / business category / tax invoice email /
  settlement/billing owner / contract signer / verification state
        ↓
Verification
        ↓
Onboarding approval
        ↓
canonical LegalEntity 생성 · 연결
        ↓
Store ↔ LegalEntity mapping
        ↓
mapping completeness 검증
        ↓
NOT NULL enforcement **eligibility** 판단
```

> ⚠️ **마지막 단계를 `NOT NULL` 로 확정하지 않는다.**
>
> **신규 Store onboarding 경로가 올바른 것**과
> **기존 데이터 전체에 NOT NULL 을 걸 수 있는 것**은 별개의 검증이다.
> 전체 Store 가 검증된 LegalEntity 를 확보했는지 확인해야 한다.

**조건 판정** (ChangeContract 에서 수행)

| 조건 | 처리 |
|---|---|
| 검증된 business identity 확보 | LegalEntity 생성·확인 → backfill → 검증 → NOT NULL eligibility 판단 |
| 미확보 | 관계만 유지. **enforcement 는 명시적 blocker 와 함께 이월** |

> `legal_entities` 0행이라는 physical fact 만으로 모델 결함이라고 판정하지 않는다(§1.31).
> 실제 원인이 intake 미수행인지는 onboarding evidence 로 확인한다.

## §5 0168 / 0169 취급

`600020` §1.5 / §3 에 따라 **동결 상태를 유지**한다.

```text
0168 / 0169
  └─ historical physical lineage — 수정 금지 (000701 §14.5)

새 0-A 승인
  ↓
신규 번호 forward migration
```

**"동결"은 "앞으로 고치면 안 된다"가 아니라
"과거 파일을 수정하지 않고 forward migration 으로 교정한다"는 뜻이다.**

`601505` §4의 금지 조항(호출 금지 · `ACTIVE` 승격 금지 · 신규 호출자 배포 금지)은
0-A-2 완료까지 계속 유효하다.

### §5.1 "새 0-A 완료" 의 정의

`600020` §3이 `0168`/`0169` 처분을 "새 0-A 완료 후 재판정"으로 두었다.
**여기서 완료는 전체 lifecycle 완료를 뜻한다.**

```text
Evidence → Human Rules → ERD → Architecture → Approval
→ Forward Implementation → Verification → Audit → COMPLETE
        ↓
0168 / 0169 historical disposition 재판정
```

설계만 끝낸 뒤 처분하면 **대체할 물리 구현이 없는데
옛 foundation 의 지위를 먼저 정하는 역순**이 된다.

## §6 근거 문서 목록 (`000701` §46)

> §46: Overview 작성 시점에 실제로 참고한(또는 참고 대상으로 확인했으나
> 의도적으로 배제한) **모든 관련 문서를 빠짐없이 기록**한다.
> 배제한 문서가 있다면 왜 배제했는지 **한 줄 근거**를 남긴다.
> 이후 검증하는 사람이 **이 목록만으로 확인**할 수 있어야 한다.

### §6.0 Evidence Pack 이중 수행

| 수행 | 산출물 | 발견 | E-1 건수 |
|---|---|---|---:|
| Cursor | `601708` | 조직·경계·거버넌스 계열 | 65 |
| Codex | `601709` | 금융·법무·API 계열 | 53 |

**합집합 79건 중 한쪽만 찾은 문서가 40건**(Cursor 26 / Codex 14).
어느 하나만 수행했다면 절반 가까이 놓쳤을 것이다(`000701` §35).

§46이 든 CH-F04 사례(`005191`/`005241` 독립 작성 충돌)와 같은 위험이다.

**§6.1 ∪ §6.2 = 79건**으로 합집합 전체를 덮는다. 누락 없음.

> `601708`/`601709` 자신은 두 E-1 목록 어디에도 없다.
> 이 둘은 **모집단을 만든 문서**이므로 §6.1/§6.2 의 79건에 포함시키지 않고
> 여기 §6.0 에 기록한다. 두 문서 모두 E-1~E-4 전체를 인용했다.

### §6.1 인용한 문서 (29건)

**권위 열**: `ACTIVE` / `권위보류`(`600020` §1.1) / `본 워크패킷`

`000150`/`000170`/`003020`/`009030`/`010004` 는 ACTIVE 본문과 AUTHORITY SUSPENDED
역전파 블록이 같은 파일에 혼재하므로 **어느 절을 인용했는지와
그 절의 권위 상태를 명시**한다. **역전파 블록은 인용하지 않았다.**

> `010004` 는 §4.1 **안에서** 권위가 갈린다.
> line 92~117 전역 객체 판별 기준은 ACTIVE 이고,
> line 118 이후 `601500` 구현 대응표는 ⛔ 권위 없음이다(`600020` §5).
> 인용한 것은 앞부분뿐이다.

| # | 문서 경로 | 인용 절 | 권위 | 이 Overview 에서의 역할 |
|---|---|---|---|---|
| 1 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | §4, §6, §7, §11 (ACTIVE 본문) | **ACTIVE 본문** (역전파 블록 ⛔ 미인용) | LegalEntity 정의, CatchMenu 내부 조직축, Franchise OS 분리 |
| 2 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | §4, §6, §7, §14~§16 (ACTIVE 본문) | **ACTIVE 본문** (역전파 블록 ⛔ 미인용) | MerchantAccount·Store 정의, Store 상태 3축 |
| 3 | `docs/000100_project_foundation/000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | §10, §11, §21 | ACTIVE | cross-business link 는 참조이며 권한이 아님 — §3 제외 근거 |
| 4 | `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` | §6.11.1, §14.5, §35, §46, §47.1 | ACTIVE | migration 불변 경계, Evidence Pack, Stage 7, G15 |
| 5 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | §3, §4 | ACTIVE | Tenant→Store runtime 축 — §6.3 #1 충돌 당사자 |
| 6 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | §2, §6 (ACTIVE 본문) | **ACTIVE 본문** (역전파 블록 ⛔ 미인용) | 5축 정의, Open Decisions — Store–LE *may link* |
| 7 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | §2 | ACTIVE | `company` homonym 근거 — §6.3 #3 |
| 8 | `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | §3 | ACTIVE | company ≠ legal_entity 금지 규칙 |
| 9 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | §2 (ACTIVE 본문) | **ACTIVE 본문** (역전파 블록 ⛔ 미인용) | 개념 엔터티 — 물리화 미결 등록 |
| 10 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | §2, §3, §6 | ACTIVE | 병렬 축, persistence depth open — §3 제외 근거 |
| 11 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §4, §4.1 판별 기준 (line 92~117) | **ACTIVE 본문** (§4.1 내 역전파 블록 ⛔ 미인용) | tenant-owned 객체 격리 invariant, 전역 객체 판별 기준 |
| 12 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md` | §7, §8, §9, §10, §11 | ACTIVE | LegalEntity 금전 최종성, 격리 scope, 계약 기반 franchise scope |
| 13 | `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | §4, §10, §11 | ACTIVE | **§4 조건부 항목의 핵심 근거** — business identity intake |
| 14 | `docs/020000_validation_security_audit/020310_Policy_User_Account_And_Login.md` | §12, §29 | ACTIVE | User/Session 경계 — §3 0-B 제외 근거 |
| 15 | `docs/020000_validation_security_audit/020320_Policy_Role_Permission_And_Scope.md` | §8~§11, §40 | ACTIVE | MerchantAccount scope 의 복수 Store 포함 — §2 대상 4 |
| 16 | `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | §1, §2 | ACTIVE | 나선 진행 상태 — §7 다음 단계 |
| 17 | `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | §1.1, §1.5, §2, §3, §5 | ACTIVE | `601500` 권위보류, 0168/0169 처분, 역전파 블록 권위 |
| 18 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | §0.1 | **권위보류** | §6.3 #4 충돌 당사자로만 인용. 구조를 근거로 삼지 않음 |
| 19 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | §4 | **권위보류** | 금지 조항이 0-A-2 완료까지 유효하다는 사실 기록 — §5 |
| 20 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md` | §2.3 | **권위보류** | 서술된 접근 경로 vs 실측 함수 0개 — §6.3 #6 |
| 21 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | §4.2, §4.3, §5.1 | **권위보류** | 원천 문서 노후 사례, 과금 로직 의존 금지 — finding 만 승계 |
| 22 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | §3, §4, §5 | 본 워크패킷 | In/Out of Scope, 착수 순서 |
| 23 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | §4.2 C-2, §4.5 D-3, §4.15 | 본 워크패킷 | 현재 실측 — LE 0행, 함수 0개, PUBLIC EXECUTE 20 |
| 24 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | §1.1~§1.33, §2.1, §2.2 | 본 워크패킷 | **최우선 근거** — 1단계 Human 선언 33건 |
| 25 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | 전체 | 본 워크패킷 | HQ/Staff/Session A단계 — 0-B 경계 확인 |
| 26 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601704_Register_Stage2_ERD_Relationship_Survey.md` | Q2, Q3, Q4 | 본 워크패킷 | cardinality 조사 — §2 대상 4의 근거 |
| 27 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601705_Diagram_Operational_Authority_Core_ERD.md` | §3, §5.1, §5.2, §8 | 본 워크패킷 | 2단계 ERD 기준선 — 구현 대상의 관계 모델 |
| 28 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | V1~V5, Blocker | 본 워크패킷 | 3단계 대조 — 외부 어휘·누락 |
| 29 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601707_Audit_Stage3_Adjacent_Domain_Codex.md` | V1~V5, Blocker | 본 워크패킷 | 3단계 대조 — ERD 내부 정합성 |

### §6.2 확인했으나 인용하지 않은 문서 (50건)

`601708`/`601709` E-1 합집합 중 §6.1 에 없는 것 전부다.
**존재를 확인했고 읽었으며, 아래 사유로 이 Overview 의 근거에서 제외했다.**

| # | 문서 경로 | 배제 사유 |
|---|---|---|
| 1 | `docs/000020_Policy_Store_Capability_Stage_0_To_5_Module.md` | Store capability 단계 — Store 상태축이 out of scope(§3)이므로 이번 나선 미사용 |
| 2 | `docs/000100_project_foundation/000140_Guide_Organization_Core.md` | Organization Core 가이드 — 상위 정의는 `000150` 이 갖는다. 중복 인용 회피 |
| 3 | `docs/000100_project_foundation/000200_Boundary_Organization_Core_MVP_Cutline.md` | 범위·컷라인·인덱스 문서 — Core 축의 의미를 정의하지 않는다 |
| 4 | `docs/000100_project_foundation/000210_Index_Organization_Core_And_Readiness_Check.md` | 범위·컷라인·인덱스 문서 — Core 축의 의미를 정의하지 않는다 |
| 5 | `docs/000700_ai_agent_prelearning_and_project_context/000717_Guide_Pipeline_Rules_Summary.md` | 파이프라인 규칙 요약 — 원본 `000701` 을 직접 인용했다 |
| 6 | `docs/001000_mvp_scope/001040_Matrix_MVP_Active_Optional_Future_NonGoal.md` | 범위·컷라인·인덱스 문서 — Core 축의 의미를 정의하지 않는다 |
| 7 | `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | Store runtime profile / 상태·이벤트 ownership — Store 상태 3축이 out of scope(§3) |
| 8 | `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` | runtime owner 용어 — `601702` §1.2 가 이미 무수식 `Owner` 금지로 정리했다 |
| 9 | `docs/007000_admin_console/007020_Policy_Admin_Store_Runtime_Configuration_Model.md` | Admin 화면·navigation scope — 0-C Role/Permission 소관(`601702` §1.19) |
| 10 | `docs/007000_admin_console/007070_Policy_Admin_Context_Navigation_And_Scope_Model.md` | Admin 화면·navigation scope — 0-C Role/Permission 소관(`601702` §1.19) |
| 11 | `docs/009000_data_model_state_machine/009040_Policy_State_And_Event_Ownership_Model.md` | Store runtime profile / 상태·이벤트 ownership — Store 상태 3축이 out of scope(§3) |
| 12 | `docs/009000_data_model_state_machine/009060_Boundary_Implementation_Deferred_Data_Model.md` | 범위·컷라인·인덱스 문서 — Core 축의 의미를 정의하지 않는다 |
| 13 | `docs/010000_runtime_foundation_and_cross_room_architecture/010100_foundation_static_catalog_package/010145_Policy_Franchise_OS_Capability_Inheritance_And_Tenant_Store_Assembly.md` | Franchise OS 외부 경계 — source of truth 가 CatchMenu 밖이다(`601702` §1.10) |
| 14 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010416_Policy_Financial_Evidence_Audit_And_Export_Boundary.md` | 금전·KYC·과금 경계 — 과금과 운영권한 관계가 미결이므로 이번 나선 제외(`601702` §2.1) |
| 15 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010451_Policy_Financial_Risk_Boundary.md` | 금전·KYC·과금 경계 — 과금과 운영권한 관계가 미결이므로 이번 나선 제외(`601702` §2.1) |
| 16 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010458_Policy_External_Network_KYC.md` | 금전·KYC·과금 경계 — 과금과 운영권한 관계가 미결이므로 이번 나선 제외(`601702` §2.1) |
| 17 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010461_Policy_Multi_Tenant_Finance_SaaS.md` | 금전·KYC·과금 경계 — 과금과 운영권한 관계가 미결이므로 이번 나선 제외(`601702` §2.1) |
| 18 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010630_Policy_Authority_Capability_Gate.md` | authority capability gate — 0-C 소관. mutation 권한 검사는 이번 나선 밖 |
| 19 | `docs/010000_runtime_foundation_and_cross_room_architecture/010800_legal_notice_sop_and_regulatory_control/010813_Policy_Legal_Notice_Admin_Checklist_And_Store_Onboarding_Review.md` | 법적 고지 master data — LegalEntity 를 소비할 뿐 Core 축을 정의하지 않는다 |
| 20 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | RLS·access control 구현 매핑 — 물리 접근 계층이며 5단계 이후 대상 |
| 21 | `docs/013000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md` | API surface ↔ authority projection — 0-C 소관. 관계 모델이 아니다 |
| 22 | `docs/013000_app_api_projection/013090_Surface_To_Authority_Projection_Model.md` | API surface ↔ authority projection — 0-C 소관. 관계 모델이 아니다 |
| 23 | `docs/013000_app_api_projection/013100_Boundary_Customer_Store_Admin_Api_Group.md` | API surface ↔ authority projection — 0-C 소관. 관계 모델이 아니다 |
| 24 | `docs/014000_pos_provider_integration_strategy/014097_Policy_SaaS_Admin_Tenant_Store_Directory.md` | POS gateway registry binding — tenant/store 를 사용할 뿐 정의하지 않는다. 구현 대상 아님 |
| 25 | `docs/014000_pos_provider_integration_strategy/014153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md` | POS gateway registry binding — tenant/store 를 사용할 뿐 정의하지 않는다. 구현 대상 아님 |
| 26 | `docs/020000_validation_security_audit/020020_Boundary_Cross_Entity_Data_Sharing_And_Privacy.md` | 권한·격리 실행 계층 — 0-B/0-C 소관(`601702` §1.18·§1.19). Overview 는 관계 모델만 정한다 |
| 27 | `docs/020000_validation_security_audit/020040_Governance_Admin_Access_And_Support_Access.md` | 권한·격리 실행 계층 — 0-B/0-C 소관(`601702` §1.18·§1.19). Overview 는 관계 모델만 정한다 |
| 28 | `docs/020000_validation_security_audit/020170_Governance_Cross_Tenant_Isolation_And_Data_Leakage_Prevention.md` | 권한·격리 실행 계층 — 0-B/0-C 소관(`601702` §1.18·§1.19). Overview 는 관계 모델만 정한다 |
| 29 | `docs/020000_validation_security_audit/020210_Governance_Payment_Boundary_And_Financial_Authority.md` | 금전·KYC·과금 경계 — 과금과 운영권한 관계가 미결이므로 이번 나선 제외(`601702` §2.1) |
| 30 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | 권한·격리 실행 계층 — 0-B/0-C 소관(`601702` §1.18·§1.19). Overview 는 관계 모델만 정한다 |
| 31 | `docs/020000_validation_security_audit/020400_foundation_security/020450_Policy_Foundation_Security_Access_Control_RBAC_ABAC_And_Least_Privilege.md` | 권한·격리 실행 계층 — 0-B/0-C 소관(`601702` §1.18·§1.19). Overview 는 관계 모델만 정한다 |
| 32 | `docs/026000_analytics_reporting_bi/026040_Boundary_Cross_Tenant_Benchmark_And_Data_Sharing.md` | 금전·KYC·과금 경계 — 과금과 운영권한 관계가 미결이므로 이번 나선 제외(`601702` §2.1) |
| 33 | `docs/028000_future_expansion/028050_Boundary_Franchise_OS_Data_Handoff_Future.md` | Franchise OS 외부 경계 — source of truth 가 CatchMenu 밖이다(`601702` §1.10) |
| 34 | `docs/030000_future_saas_modules/030040_Policy_Franchise_Store_Billing_Responsibility_And_HQ_Store_SaaS_Fee_Split.md` | Franchise OS 외부 경계 — source of truth 가 CatchMenu 밖이다(`601702` §1.10) |
| 35 | `docs/040000_menu_taxonomy_and_ai_classification/040018_Policy_Legal_Notice_Master_Data_Usage_Flow_And_Runtime_Retrieval_Governance.md` | 법적 고지 master data — LegalEntity 를 소비할 뿐 Core 축을 정의하지 않는다 |
| 36 | `docs/040000_menu_taxonomy_and_ai_classification/040019_Policy_Legal_Notice_Master_Data_Table_Static_Specification.md` | 법적 고지 master data — LegalEntity 를 소비할 뿐 Core 축을 정의하지 않는다 |
| 37 | `docs/600000_implementation_lifecycle/601200_caller_authorization_foundation/601200_Readme_Caller_Authorization_Foundation.md` | caller authorization — 0-C 소관(`601702` §1.19). Overview 구현 대상 아님 |
| 38 | `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/601443_Consolidated_Owner_Decision_Registry_Cross_Domain.md` | design-integrity 점검 번들 — 어휘 findings 는 `601701` A-3 로 승계. 구현 대상 아님 |
| 39 | `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/domain_03_waiting_call_no_show/slice_B_store_legal_boundary/601453_Core_Payload_MD_Bundle_slice_B_store_legal_boundary.md` | design-integrity 점검 번들 — 어휘 findings 는 `601701` A-3 로 승계. 구현 대상 아님 |
| 40 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 41 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 42 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 43 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 44 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601506_Verification_Operational_Authority_Foundation_Ddl.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 45 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601507_Verification_Operational_Authority_Foundation_Ddl.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 46 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601508_Audit_Operational_Authority_Foundation_Ddl.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 47 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601509_AuditReview_Operational_Authority_Foundation_Ddl.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 48 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601510_AuditReview_Stage11B_Blind_Audit.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 49 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601511_AuditReview_Stage11A_Final.md` | 권위보류 워크패킷 산출물 — `600020` §2에 따라 답안지로 사용하지 않는다. finding 은 `601701`/`601702` 가 이미 승계 |
| 50 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601600_Readme_Upstream_Doctrine_Backpropagation.md` | 권위보류 역전파 워크패킷 진입점 — 판정 내용은 `600020` §5 로 대체 |

### §6.3 Evidence Pack 이 기록한 충돌 쌍

`601708` E-3 / `601709` E-3 에서 나온 충돌 중 이 Overview 의 판단에 영향을 준 것이다.

| # | 문서 A | 문서 B | 어긋나는 지점 | 이 Overview 의 처리 |
|---|---|---|---|---|
| 1 | `000170` §4 (MerchantAccount = 최상위 고객) | `003020` §2 (`tenant` = root SaaS 경계, MerchantAccount 없음) | 최상위 고객 축의 명칭과 개수 | `601702` §1.22 Human Decision(1:1)을 따른다. §2 대상 2·3 |
| 2 | `000170` §6~§9 (`Merchant Company` 중간 계층) | `601702` §1.25 / `601705` §4.6 (canonical 아님) | 3층 vs 2층 merchant 계층 | 3층 구조를 도입하지 않는다. §3 제외 |
| 3 | `000150` §4 (`company` = 플랫폼 운영사) | `003020` §2 / `007010` §2 (`company` = tenant 내 축) | **`company` homonym** | `601702` §1.21·§1.29 로 두 층위 구분. 고객사-side 는 §3 제외 |
| 4 | `601705` §5.2 U1 (Store→LE 개수 **미정**) | `601501` §0.1 (Store→**정확히 1** LE) | Store–LegalEntity invariant 강도 | 권위보류 쪽을 근거로 삼지 않는다. §4 조건부로 처리 |
| 5 | `000150`/`003020` ACTIVE 본문 | 동일 파일 2026-08-11 역전파 블록 | **같은 파일 이중 서술** | §6.1 권위 열에 인용 절과 권위를 명시. 역전파 블록 미인용 |
| 6 | `601512` §2.3 (SECURITY DEFINER 함수 경유 접근) | `601701` C-2 (참조 함수 **0개**) | 서술된 접근 경로 vs 현재 SQL | §2.1 — Person 구현 방식을 ChangeContract 로 미룬 근거 |
| 7 | `000150` §11 (Franchise HQ = Franchise OS) | `010640` §4·§11 (`franchise_hq_id` in CatchMenu envelope) | Franchise HQ 의 소재 | `601702` §2.4 판정 보류. §3 제외 유지 |
| 8 | `000170` §4 `primary_owner_user_id` (로그인 user) | `601702` §1.1 `Person` (자연인) | **Owner** 어휘 — user vs 자연인 | §2.1 — canonical 은 `Person`. `000170` 은 정합화 대상 |

### §6.4 배제 판정의 근거

1차 0-A(`601500`)가 `000150`/`000170` 을 인용하지 않은 채 진행해
어휘 축이 통째로 어긋났다(`600020` §1.1 사유 4).
§6.1/§6.2는 그 재발을 막기 위한 것이며 **목록만으로 사후 확인 가능**해야 한다.

## §7 다음 단계

| 단계 | 산출물 | 비고 |
|---|---|---|
| 4단계 (계속) | Logic / TestPlan / ChangeContract | |
| **Stage 7** | **Human Approval** | **1차 0-A 가 건너뛴 관문**(`600020` §1.1 사유 1) |
| 5단계 | forward migration + 이중검증 | Stage 7 승인 후에만 |
| 6단계 | 나선 종료 판정 | Human |

> ⚠️ `tools/Check-Governance.ps1` 의 G15 가 Stage 7 미승인 상태의 migration 을
> 커밋 시점에 잡는다(`000701` §6.11.1).
> 신규 migration 은 파일 상단 5행 이내에 `-- Workpacket: 601700` 을 명시한다.

> ⚠️ **TestPlan / ChangeContract 작성 시 주의**
>
> §3.1 은 **negative 검증** 대상이다.
> "만들었는가"가 아니라 **"만들지 않았는가"** 를 확인해야 한다.
>
> ChangeContract 는 provider mapping 물리 구현을 **명시적으로 금지**해야 한다.
> 선언만 있고 금지가 없으면, 구현 주체가
> "mapping 이 필요하다고 했으니 테이블을 만들어야겠다"고 판단할 여지가 남는다.

> **이 Overview 는 구현을 승인하지 않는다.**
> 무엇을 왜 만드는지를 정할 뿐이며, 허용 파일과 금지 조작은 ChangeContract 가,
> 착수 권한은 Stage 7 Human Approval 이 정한다.
