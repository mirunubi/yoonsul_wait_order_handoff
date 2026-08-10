# 601600_Readme_Upstream_Doctrine_Backpropagation.md

Status: Active
Lifecycle: Readme (폴더 진입점, `000001_Md_Rules.md` §5.4)
Domain: Upstream Doctrine Backpropagation (상위 정본문서 역전파)
Last Updated: 2026-08-11

## §1 폴더 목적

0-A(`601500`)가 **실제로 구현하고 검증한 구조**를 **상위 정본 문서에 역전파**한다.

Cursor의 거꾸로검사 결과, 0-A의 신규 구조(신규 4테이블 + `tenant_status`/`isolation_state` 분리)가
상위 문서(`000150`/`000170`/`003020`/`009030`/`010004`)와 **모순되는 것이 아니라 역전파가 안 된 상태**임이
확인됐다 — `601443` 패턴의 **B유형(설계문서가 낡음)** 이다.

**핵심 원칙**: 상위 문서를 **전체 재작성하지 않는다.** 기존 내용을 보존한 채
**개정 삽입**(superseded 표시 · 리다이렉트 각주 · 신설 조항)만으로 현재 상태를 반영한다.

## §2 폴더 경계 (Semantic Boundary)

### 속하는 것
- 0-A가 확정한 사실을 상위 정본 문서에 반영하는 **문서 개정**
- 어휘 대응표(구 어휘 → 실제 구현 어휘)와 미구현 항목의 명시

### 속하지 **않는** 것

| 대상 | 소속 |
|---|---|
| `.sql` 변경 일체 | 없음 — **본 워크패킷은 문서 전용** |
| 상위 문서의 **정책 자체를 바꾸는 결정** | Human(별도 판단) |
| RPC·배치 정합 | 0-A-2 |
| `franchise_brands` 등 다른 파일 수정 | 브랜드 나선 |
| 소유권(지분) 모델링 | 미정(`601501` Open Item (q)) |

## §3 문서 목록

| 번호 | 문서 | 역할 |
|---|---|---|
| 601600 | **본 Readme** | 폴더 진입점 |
| 601601 | `Register_Stage1_Business_Rules_And_Revision_Drafts` | **1단계 업무규칙(Human 확정) + 5개 문서 개정삽입 초안 + 확인 필요 지점** |

## §4 진행 상태

| 나선 단계 | 상태 |
|---|---|
| **1단계 업무규칙 선언** (Human) | ✅ 확정 — `601601` §1 |
| 개정삽입 초안 작성 (Claude Code) | ✅ `601601` §3 |
| **Human 확인 필요 지점** | ⏸ **`601601` §4 — 미해소. 이것부터 결정 필요** |
| 실제 문서 개정 적용 | 미착수(§4 해소 후) |

## §5 Boundary Reference Documents (`000001_Md_Rules.md` §5.2.1 필수 섹션)

| 문서 경로 | 필요한 이유 |
|---|---|
| `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | **개정 대상** — company/business_unit/legal_entity 개념 정본 |
| `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | **개정 대상** — merchant/store 상태 어휘 정본(§14/§15/§16) |
| `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | **개정 대상** — tenant/company/legal_entity/operating_group/store 축 정의 |
| `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | **개정 대상** — 개념 엔터티 정본 |
| `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | **개정 대상** — tenant 격리·필수 컨텍스트 필드(§4/§25) |
| `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | **역전파 원본** — §0.4 축 정의표, §0.6 4개념 분리, §2.7 접근제어, §3 상태축 |
| `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | **§9 SECURITY DEFINER 6대 규칙** — 전역테이블 예외 요건의 근거 |
| `sql/migrations/0002_create_hq_tenant_store.sql` / `0168` / `0169` | 실제 구현된 어휘의 유일한 진실원천 |
| `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | 나선 진행 추적 |
| `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` | §47(나선 6단계), §46, §48 |

> 새 변경건의 Stage 2가 이 표에 없는 경계 문서를 발견하면 그 Overview 작성과 동시에 여기에도 추가한다.
