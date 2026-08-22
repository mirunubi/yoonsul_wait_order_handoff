# 601700_Readme_Operational_Authority_Foundation_V2.md

Status: Active
Lifecycle: Readme
Last Updated: 2026-08-10

## §1 Purpose

0단계 운영 권위 기반(Operational Authority Foundation) 하위 나선 **0-A의 재수행** 워크패킷이다.

Tenant / LegalEntity(사업주체) / HQ / Store의 권위 구조를 확정한다.

## §2 왜 재수행인가

`601500`(1차 0-A)은 2026-08-10 **AUTHORITY SUSPENDED** 판정을 받았다.

| 사유 | 근거 |
|---|---|
| Stage 7(Human Approval) 미수행 상태에서 Stage 8 진행 | `601505` §9.3/§10 |
| §47.1 1단계 Human 업무규칙 선언이 독립 문서로 부재 | `601501` §0.2는 대응표일 뿐 |
| 원천 설계문서 `000150`/`000170` 인용 0건 | `601501` §8 |

판정 전문: `600020_Governance_Implementation_Lifecycle_Authority_Reset.md`

### ⛔ `601500`을 답안지로 사용하지 않는다

- `601501`~`601508`의 설계 결론(테이블 구조·컬럼·판정식)을 **정답으로 놓고 맞추지 않는다.**
- 새 설계가 결과적으로 `0168`과 동일해지는 것은 허용한다. 다만 **독립적으로 도출**해야 한다.
- `601509`~`601511` 감사 **finding은 증거로 승계**한다. **APPROVE 판정은 승계하지 않는다.**

## §3 착수 순서 (`000701` §47.1 + §48.4)

```text
[1단계 직전] §48 증거수집 — A~E 5단계 분류, 표 형식 필수
[1단계] 업무규칙 선언        — Human 전담, AI 위임 불가
[2단계] ERD 초안
[3단계] 인접 도메인 대조      — 반드시 새 세션(사전 맥락 0)
[4단계] 설계문서 정합화        — §46 근거 문서 목록 의무
[5단계] SQL 구현 + 이중검증
[6단계] 나선 종료 판정        — Human
```

**현재 위치 (2026-08-13)**

| 단계 | 상태 | 산출물 |
|---|---|---|
| §48 증거수집 | ✅ 완료 | `601701`(5개 대상 A~E) / `601703`(HQ·HR 5개 대상 A단계) |
| 1단계 업무규칙 선언 | ✅ 완료 | `601702` §1.1~§1.30 (선언 30건) |
| 2단계 ERD | ✅ 완료 | `601705` — Active, 4단계 진입 기준선 |
| 3단계 인접 도메인 대조 | ✅ 완료 | `601706`(Cursor) / `601707`(Codex) — Blocker 8건 전건 반영 |
| 4단계 설계문서 정합화 | 미착수 | Overview / Logic / TestPlan / ChangeContract |
| 5단계 SQL 구현 | 미착수 | |
| 6단계 나선 종료 판정 | 미착수 | |

> **3단계 세션 분리 요건**(`000701` §47.1): `601705` 는 Claude Code 가 작성했으므로
> 검증자에서 제외했다(§37). 대조는 Cursor 와 Codex 가 각각 독립 수행했으며,
> 두 결과의 발견이 갈렸다(§35) — Cursor 는 외부 어휘·누락, Codex 는 ERD 내부 정합성.

**증거수집을 1단계 앞에 두는 이유**: 검증되지 않은 옛 설계문서를 Human이 그대로 받아 적는 것을 막기 위함이다.
`000150`/`000170`/`003020`/`009030`/`010004`는 **검증을 거친 적이 없다**(`600020` §2.2).

## §4 In Scope

- §48 증거수집 (Company / Owner / Tenant / HQ / Store 5개 대상)
- 1단계 업무규칙 선언 (Human 산출물)
- ERD / Overview / Logic / TestPlan / ChangeContract
- Stage 7 Approval 기록
- 구현 후 Module / Verification / Audit

## §5 Out of Scope

- RPC 재작성 (`isolate_tenant` / `manage_subscription` / `detect_threat`) — 파생 나선 소관
- Staff identity / session — 0-B
- Authorization — 0-C
- **과금 로직에 의존하는 어떤 것도 만들지 않는다** (`601601` §5.1)
  `ACTIVE`+`ISOLATED` 과금 정책은 미결(Open Item)이며 사업 정책 결정 사항이다.
  상태를 기록하는 데까지만 하고 해석하지 않는다.

## §6 Boundary Reference Documents (`000001` §5.2.1)

이 폴더 산하 모든 변경건이 Stage 1 스캔 시 **반드시 대조해야 하는** 경계 정의 문서다.
새 경계 문서를 발견하면 그 변경건의 Overview 작성과 동시에 이 표에 추가한다.

| 문서 경로 | 필요한 이유 |
|---|---|
| `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | company / business_unit / legal_entity 개념 정의. **1차 0-A가 인용하지 않은 문서** |
| `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | merchant_account / service_status / trial_status / STORE_* 어휘 소유. **1차 0-A가 인용하지 않은 문서** |
| `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | 5개 축(tenant/company/legal_entity/operating_group/store) 정의 |
| `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | 개념 엔터티 등록부 |
| `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | company ≠ operating_group 축 구분 |
| `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | Admin Console 축·역할 모델 |
| `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | 관리자 화면 축 구분. Company List 화면 vs 실제 테이블 갭 |
| `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | tenant 격리·context 요건. §4.1 전역 테이블 판별 기준 |
| `docs/000700_ai_agent_prelearning_and_project_context/000717_Guide_Pipeline_Rules_Summary.md` | 파이프라인·문서규칙 요약. 세션 시작 시 필독 |
| `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | 600000 대역 권위 상태. 601500 사용 제약 |

> ⚠️ **위 문서들은 검증을 거친 적이 없다.** 노후·모순 확인 사례는 `600020` §2.2 참조.
> 증거수집 단계에서 문서 자체의 결함도 함께 기록한다.

## §7 Owned Number Band

- 폴더 밴드: `601700`–`601799`
- 상위: `docs/600000_implementation_lifecycle/`
- 새 문서는 `000005_Index_Document_Number.md` 기준 다음 빈 번호를 사용한다

## §8 File List

| 번호 | 파일 | 상태 |
|---|---|---|
| 601700 | `601700_Readme_Operational_Authority_Foundation_V2.md` | Active |
| 601701 | `601701_Register_Stage0_Evidence_Collection.md` | Active — §48 증거수집 A~E. 대상 5개(Company/Owner/Tenant/HQ/Store) |
| 601702 | `601702_Register_Stage1_Business_Rules.md` | Active — 1단계 업무규칙 선언(Human 전담). §1.1~§1.30 선언 30건. 3단계 대조 결과 반영 완료 |
| 601703 | `601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | Active — §48 증거수집 A단계. 대상 5개(HQ/Staff/Session/Role/Permission). **A-2 어휘표 신뢰 불가 — 배너 참조** |
| 601704 | `601704_Register_Stage2_ERD_Relationship_Survey.md` | Active — 2단계 ERD 선행 관계·cardinality 조사(Cursor). Q1~Q8. Q1·Q5는 미판정이며 `601702` §1.22·§1.23이 확정 |
| 601705 | `601705_Diagram_Operational_Authority_Core_ERD.md` | Active — 2단계 ERD 초안. 4단계 진입 기준선 |
| 601706 | `601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | Active — 3단계 인접 도메인 대조(Cursor). 외부 어휘·누락 중심 |
| 601707 | `601707_Audit_Stage3_Adjacent_Domain_Codex.md` | Active — 3단계 인접 도메인 대조(Codex). ERD 내부 정합성 중심 |
| 601708 | `601708_Evidence_Stage4_Overview_Evidence_Pack_Cursor.md` | Active — §46 Evidence Pack(Cursor). 지정 목록 없이 자체 탐색 |
| 601709 | `601709_Evidence_Stage4_Overview_Evidence_Pack_Codex.md` | Active — §46 Evidence Pack(Codex). §35 이중 검증 |
| 601710 | `601710_Overview_Operational_Authority_Foundation_V2.md` | Draft — 4단계 Overview. §46 근거 79건 전수 분류. Stage 7 승인 대상 |
| 601711 | `601711_Evidence_Person_Physical_Impact_Scan_Cursor.md` | Active — Person 물리 영향 조사(Cursor). Logic 입력 자료 |
| 601712 | `601712_Evidence_Person_Physical_Impact_Scan_Codex.md` | Active — Person 물리 영향 조사(Codex). §35 이중 검증 |
| 601713 | `601713_Logic_Operational_Authority_Foundation_V2.md` | Draft — 4단계 Logic. 불변조건 33건. 물리 변경 방법은 ChangeContract 소관 |
| 601714 | `601714_Evidence_Stage4_Logic_Gap_Survey_Cursor.md` | Active — Logic §6 미해결 5건 조사(Cursor). ChangeContract 입력 |
| 601715 | `601715_Evidence_Stage4_Logic_Gap_Survey_Codex.md` | Active — 동일 조사(Codex). §35 이중 검증 |

## §9 Add / Move Rule

1. 새 문서는 `601700`–`601799` 범위에서 기존 번호를 재사용하지 않고 배정한다.
2. 생성·개명·이동 시 **이 Readme**, `000005_Index_Document_Number.md`,
   `000007_Map_Full_Directory.md`를 **같은 배치에서** 갱신한다 (`000001` §5.11).
3. `600010_Tracker_Spiral_Workpacket_Progress.md`의 진행 현황도 Stage 변경 시 갱신한다.
4. 문서를 `600000_implementation_lifecycle/` 루트에 직접 두지 않는다.

## §10 Non-Implementation Boundary

이 폴더는 문서 컨테이너다. Codex / Cursor / Claude / Claude Code에게
SQL·마이그레이션·애플리케이션 코드·런타임 설정을 수정할 권한을 부여하지 않는다.

**Stage 7 Human Approval과 ChangeContract 없이 Stage 8을 시작하지 않는다.**
착수 전 ChangeContract `§10 Approval State`에서 Stage 7이 승인 상태인지 확인한다.

## §10.1 Actor 배정 규칙 (`000701` §34 / §37)

| 작업 성격 | 도구 |
|---|---|
| 대용량 스캔 / 트리 탐색 / grep (읽기 전용) | Cursor |
| **한글 본문이 있는 문서의 작성·수정** | **Cursor 금지** — Codex 또는 Claude Code |
| 단순·반복 검증, 소규모 수정 | Codex |
| ChangeContract 준수 구현, 규칙 정확성이 중요한 작업 | Claude Code |
| 설계 / 감사 / 최종 판단 (Stage 3·4·6·11) | Claude |

**Cursor 제약**: 한글 파일 처리 시 인코딩을 깨뜨린 실제 손상 사례가 있다
(`900160~179` 계열, 2026-07-11). `000001` §1은 "Cursor must not edit Korean body text"로 금지한다.

**원작자 검증 제외 (§37)**: 검증 작업을 배정하기 전에 그 산출물의 실제 작성자를 확인하고
검증자 후보에서 제외한다. 검증 지시문 서두에
`원작자: OOO, 따라서 검증자는 OOO 제외`를 명시한다.

**단일 검증자 금지 (§35)**: 검증자가 1명이면 그 1명의 사각지대가 남는다.
`600210` 사례에서 Codex 구현 → Claude Code 검증 후, Cursor 재검증이
양쪽 다 놓친 결함(하드코딩된 tenant_id/store_id)을 발견했다.

## §11 관련 문서

| 문서 | 관계 |
|---|---|
| `601500_operational_authority_foundation/` | 1차 0-A. **AUTHORITY SUSPENDED**. Findings만 승계 |
| `601600_upstream_doctrine_backpropagation/` | 1차 0-A 역전파. 5개 상위문서 삽입분 권위 보류됨 |
| `600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | 권위 판정 전문 |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | 전 나선 진행 현황 |
| `sql/migrations/0168`, `0169` | 1차 0-A 산출물. **동결**. 처분은 본 워크패킷 완료 후 재판정 |
