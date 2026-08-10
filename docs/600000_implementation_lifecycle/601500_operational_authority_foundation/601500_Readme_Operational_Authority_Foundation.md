# 601500_Readme_Operational_Authority_Foundation.md

> # ⚠️ AUTHORITY SUSPENDED — NON-AUTHORITATIVE HISTORICAL WORKPACKET
>
> **판정일: 2026-08-10**
>
> 이 폴더의 모든 문서는 **설계·구현의 권위 자료가 아니다.**
> 과거에 이런 시도가 있었고 어떻게 실패했는지를 기록한 **증거자료**로만 사용한다.
>
> ## 권위 보류 사유
>
> | # | 사유 | 근거 |
> |---|---|---|
> | 1 | **Stage 7(Human Approval) 미수행** — `601505` §10이 `Stage 7 대기`로 기록된 상태에서 `0168`/`0169`가 적용됨. §9.3 승인란 공란 | `601505` §9.3/§10 |
> | 2 | **Stage 6(계약 검증)도 `대기`로 기록** | `601505` §10 |
> | 3 | **1단계 Human 업무규칙 선언이 독립 문서로 존재하지 않음** — `601501` §0.2는 선언이 아니라 선언과 구현의 *대응표* | `000701` §47.1 |
> | 4 | **원천 설계문서 `000150`/`000170` 인용 0건** — 두 문서가 소유한 어휘(`merchant_account`/`service_status`/`STORE_*`)와의 대조가 수행되지 않음 | `601501` §8 |
> | 5 | **완료일 오기** — 문서상 `2026-08-11`이나 실제 커밋은 `2026-08-10 16:14:09 KST` | git log |
>
> ## 과거 기록 (보존)
>
> - Stage 8~12가 실제로 진행되었고, Stage 12 Human 병합 승인이 기록되었다.
> - Stage 11B 블라인드 감사가 `BLOCK` 4개 조건을 실제로 잡아냈고 v5/`0169`에 반영되었다.
> - **이 기록들은 삭제하지 않는다.** 무슨 일이 있었는지가 추적 가능해야 한다.
>
> ## 현재 처분
>
> | 대상 | 처분 |
> |---|---|
> | `601501`~`601508` 설계·계약 산출물 | 존치. **권위 없음.** 새 설계의 근거로 인용 금지 |
> | `601509`/`601510`/`601511` 감사 판정 | 존치. `000001` §5.10 frozen historical snapshot — **수정 금지** |
> | `601512` 기준선 | 존치. 별도 배너로 §2 효력 정지 |
> | `0168`/`0169` migration | 존치·휴면. `000701` §14.5에 따라 파일 직접 수정·삭제 금지 |
> | 물리적 존치/정리 | **새 0-A 완료 후 재판정** |
>
> ## 새 0-A에 대한 구속
>
> 새 0-A는 이 폴더를 **답안지로 사용하지 않는다.**
> 원천 설계문서 검증 → Human 업무규칙 선언 → ERD 순서로 새로 시작한다.
> 새 설계가 결과적으로 `0168`과 동일해지는 것은 허용하나,
> **기존 구현을 정답으로 놓고 맞추지 않는다.**
>
> Findings(설계 결함 발견·감사 지적)만 증거로 승계한다.
>
> **판정: 정영석 / 2026-08-10**

Status: Active
Lifecycle: Readme (폴더 진입점, `000001_Md_Rules.md` §5.4)
Domain: Operational Authority Foundation — 0단계 하위 나선 **0-A**
Last Updated: 2026-08-11

## §1 폴더 목적

`000701_Guide_Controlled_AI_Development_Pipeline.md` §47.3이 정의한 **0단계(운영 권위 기반)** 의
첫 하위 나선 **0-A — Tenant / Company / HQ / Store** 의 전체 산출물을 담는다.

**0-A의 목표**: SaaS 전체를 구현하는 것이 아니라, **이후 어떤 도메인을 만들어도 다시 흔들리지 않을
최소 권위 구조를 확정**하는 것(§47.3, §47.6-1).

**핵심 결과물** — 마이그레이션 2개:

| 파일 | 내용 |
|---|---|
| `sql/migrations/0168_create_operational_authority_foundation.sql` | 신규 테이블 4개(`owners`/`legal_entities`/`legal_entity_person_roles`/`legal_entity_representatives`) + 신규 컬럼 3개(`tenants.tenant_status`/`tenants.isolation_state`/`stores.legal_entity_id`) |
| `sql/migrations/0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 전용 NOLOGIN role `catchmenu_authority_owner` + SOLE 대표 유일성 부분 UNIQUE |

**상태**: ✅ **완료** — Stage 12 Human Merge 승인(2026-08-11).
자세한 진행 상태·복구용 기준선은 **`601512_Baseline_Summary.md`** 참조.

## §2 폴더 경계 (Semantic Boundary)

### 이 폴더에 속하는 것

- 0-A 나선의 설계(ERD/Overview/Logic), 계약, 검증, 감사 문서 전체
- `0168`/`0169`가 만든 **구조 자체**에 대한 기록

### 이 폴더에 속하지 **않는** 것

| 대상 | 소속 |
|---|---|
| `isolate_tenant()`/`manage_subscription()`/배치 필터 **RPC 재작성** | **0-A-2**(별도 워크패킷) |
| `onboard_tenant()`/`provision_tenant()` **재설계** | **0-A-3** |
| 신규 4테이블 접근 **함수·RLS 정책** | **0-C**(Authorization) — §4 게이트 |
| 브랜드 축(`franchise_brands`) | 미래 브랜드 나선 |
| 소유권(지분) 모델링 | 미정(`601501` Open Item (q)) |

## §3 문서 목록

| 번호 | 문서 | 역할 |
|---|---|---|
| 601500 | **본 Readme** | 폴더 진입점 |
| 601501 | `ERD_Tenant_Company_HQ_Store` (**v5**) | **설계 원본** — 충돌 시 이 문서가 우선 |
| 601502 | `Overview_..._Ddl` (v5) | 워크패킷 맥락·범위 절단 |
| 601503 | `Logic_..._Ddl` (v5) | 의사 DDL·적용 순서·멱등성·**§9 SECURITY DEFINER 보안규칙** |
| 601504 | `TestPlan_..._Ddl` | 검증 계획 |
| 601505 | `ChangeContract_..._Ddl` (**v3**) | 허용/금지·Stop Conditions |
| 601506 | `Verification_..._Ddl` | Stage 9 독립검증 **raw 원문** |
| 601507 | `Verification_..._Ddl` | Stage 10 정리된 검증 기록 |
| 601508 | `Audit_..._Ddl` | Stage 10 Audit **초안**(판정 없음) |
| 601509 | `AuditReview_..._Ddl` | Stage 11A 1차 감사 |
| 601510 | `AuditReview_Stage11B_Blind_Audit` | **Stage 11B 블라인드 감사 — BLOCK 판정** |
| 601511 | `AuditReview_Stage11A_Final` | Stage 11A 재감사 — Stage 11 종결 |
| 601512 | `Baseline_Summary` | **진행 상태 1페이지 요약 — 공백 후 복구용 진입점** |

> **어디부터 읽어야 하나**: 처음이면 본 Readme → `601512`(현재 상태) → `601501`(설계).
> 구현을 이어받는다면 `601505`(계약)와 `601503` §9(보안규칙)를 반드시 함께 읽을 것.

## §4 ⚠️ 이 폴더를 이어받는 사람이 반드시 알아야 할 것

### §4.1 완료 ≠ 안전

0-A는 `isolate_tenant()`를 **의도적 장애 상태**로 남긴 채 병합됐다.
`601505` §4의 금지 조항(**호출 금지 · tenant `ACTIVE` 승격 금지 · 신규 호출자 배포 금지**)은
**0-A-2 완료까지 계속 유효**하다.

### §4.2 0-C 착수 게이트 (Stage 11B 조건 ② 미이행분)

**신규 4개 테이블에 접근하는 `SECURITY DEFINER` 함수를 만드는 어떤 작업이든**
— 워크패킷 이름과 무관하게 — `601503` **§9의 필수 6규칙**을 지켜야 한다.
특히 `search_path` 위반은 함수 소유자 위반보다 위험하다(권한상승 취약점).

### §4.3 다음 워크패킷 순서

**0-A-2 → 0-A-3 → 0-B** 순. `601505` §8A에 따라 **0-A-2가 0-B보다 우선**한다.

## §5 Boundary Reference Documents (`000001_Md_Rules.md` §5.2.1 필수 섹션)

이 모듈 산하 모든 변경건이 **Stage 1 스캔 시 반드시 대조해야 하는** 경계 정의 문서.

| 문서 경로 | 필요한 이유 |
|---|---|
| `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` | §3(13단계 파이프라인·단계 소유자), §13.7–13.8(Dual Anchor·Stage 11B 의무), §37(검증자 배제), §46(근거목록), §47(6단계 나선·개발순서), §48(증거수집), §49.2(`ADD COLUMN` 선행순서) — 이 워크패킷의 절차 전체가 여기서 나온다 |
| `docs/000001_Md_Rules.md` | §5.2/§5.2.1(Readme·경계문서), §5.4(DocumentType), §5.12(폴더번호 슬롯) — 문서 규격 |
| `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | **tenant/company/legal_entity/operating_group/store를 별개 축으로 규정.** LegalEntity 중심 모델의 상위 근거이며, "company를 legal_entity와 자동 동일시하지 말 것"의 출처 |
| `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | 개념 엔터티 정의(`company`는 "Not automatically legal entity") |
| `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | `company`와 `operating_group`이 **서로 다른 축**임을 규정 — 매핑 오류 방지 |
| `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | 관리자 화면의 축 구분("Do not treat company as legal entity automatically") |
| `sql/migrations/0002_create_hq_tenant_store.sql` | `tenants`/`stores` 원형과 `uq_stores_tenant_code` — 모든 스키마 변경의 기준선 |
| `sql/migrations/0021_enable_rls.sql` / `0022_create_rls_policies.sql` | RLS 활성화와 정책의 **짝 구조**, `is_service_role()` 메커니즘 — 접근제어 판단의 근거 |
| `supabase/config.toml` | PostgREST 노출 스키마(`catchmenu_hq` 미노출) — **실제 1차 차단 계층** |
| `sql/migrations/0085_create_franchise_os_foundation_rpc.sql` | `franchise_brands` — **읽기 전용 참조**. 사업자 축과 브랜드 축을 가르는 기준 |
| `sql/migrations/0090`/`0112`/`0121`/`0130`/`0131` | `isolate_tenant()` 도달 경로 7개 함수 — §4.1 금지 조항의 대상 |
| `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | 전 나선 진행 상태·0-C 착수 게이트 |

> 새 변경건의 Stage 2(Overview 작성)가 이 표에 없는 경계 문서를 발견하면,
> **그 Overview 작성과 동시에 이 표에도 추가**한다(§5.2.1).
