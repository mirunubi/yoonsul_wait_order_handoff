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
