# 601400_Readme_Fable_Design_Integrity_Inspection.md

Status: Active
Lifecycle: Readme (폴더 진입점, `000001_Md_Rules.md` §5.4)
Domain: Fable Design Integrity Inspection (검사 프로그램)
Last Updated: 2026-08-11

## §1 폴더 목적

**설계무결성 검사 프로그램.** 도메인별로 (1) 전체 파일 인벤토리(Stage 1)와 (2) lifecycle-layer 재분류(Stage 2)를
수행하고, Fable 슬라이스 검사로 **설계문서-실제 구현 간 불일치**를 구조적 사실로 기록한다.

**옳고그름을 판단하지 않고 사실만 기록**하는 것이 이 프로그램의 원칙이다.
`601300`(블라인드 역설계)과 달리 **설계 문서·SQL·JSON 계약을 모두 포함**해 본다.

> 이 프로그램에서 반복 발견된 문제(phantom 컬럼, 상태값 불일치, 번호충돌, "거버넌스 연극")가
> `000701` §47(6단계 나선 개발방법론) 신설의 직접적 계기였다.

## §2 폴더 경계 (Semantic Boundary)

### 속하는 것
- 13개 도메인의 파일 인벤토리·분류·슬라이스 검사 결과
- Owner Decision Registry(교차 도메인 결정 대기 항목)

### 속하지 **않는** 것

| 대상 | 소속 |
|---|---|
| 코드만 보고 하는 블라인드 역설계 | **`601300_fable_blind_reverse_engineering_audit/`** — 별개 프로그램 |
| 발견된 결함의 **수정 구현** | 각 도메인 구현 워크패킷 |
| **구현 워크패킷의 진행 추적** | **`600010_Tracker_Spiral_Workpacket_Progress.md`** — §4 참조 |

## §3 문서 목록

| 번호 | 문서 | 역할 |
|---|---|---|
| 601400 | **본 Readme** | 폴더 진입점 |
| 601401 | `Master_Tracker.md` | **13개 도메인 진행표** — 이 프로그램 전용 |
| 601402 | `Operating_Plan_Design_Integrity_Inspection.md` | 운영 계획 |
| 601443 | `Consolidated_Owner_Decision_Registry_Cross_Domain.md` | 교차 도메인 Owner 결정 레지스트리 |
| — | `domain_01_customer_handoff/` ~ `domain_13_physical_ai/` | 도메인별 인벤토리·분류·슬라이스 |

## §4 ⚠️ `601401_Master_Tracker`의 범위 (혼동 주의)

**`601401`은 이 검사 프로그램의 13개 도메인 전용 트래커다.**
`000701` §47 나선의 **구현 워크패킷**(0-A/0-B/1-1 등)은 여기에 등재하지 않는다 —
그것은 **`docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md`** 소관이다.

| | `601401` | `600010` |
|---|---|---|
| 추적 대상 | 13개 도메인 **검사** | 나선 **구현 워크패킷** |
| 성격 | 기존 산출물을 **검사** | 무언가를 **만듦** |
| 진행 축 | Stage 1 인벤토리 / Stage 2 분류 / Fable Pass | 13단계 파이프라인 Stage 1–12 |

> 2026-08-10에 0-A(601500) 워크패킷을 `601401`에 등재하려는 시도가 있었고 **부적절로 판정**되어
> `600010`이 신설됐다. 경위는 `600010` §0.1 및 `601505` §8A 참조.

## §5 Boundary Reference Documents (`000001_Md_Rules.md` §5.2.1 필수 섹션)

| 문서 경로 | 필요한 이유 |
|---|---|
| `docs/000700_.../000716_Guide_CatchMenu_One_Time_Design_Integrity_And_Reverse_Engineering_Inspection_Operational_Plan.md` | **운영안 canonical 위치** — §6.1/§6.2가 Stage 1/Stage 2 기준을 정의 |
| `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` | §46(근거목록), §47(이 프로그램의 발견이 계기가 된 나선 방법론), §48(증거수집 5단계 분류) |
| `docs/000001_Md_Rules.md` | 문서 규격·lifecycle DocumentType(재분류의 기준) |
| `docs/000005_Index_Document_Number.md` / `docs/000007_Map_Full_Directory.md` | 인벤토리 대조 기준 |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601301_Master_Tracker.md` | **자매 프로그램** — 범위 중복 방지(§2) |
| `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | **구현 워크패킷 트래커** — §4의 경계 구분 |

> 새 변경건의 Stage 2가 이 표에 없는 경계 문서를 발견하면 그 Overview 작성과 동시에 여기에도 추가한다.
