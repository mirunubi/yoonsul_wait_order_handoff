# 601300_Readme_Fable_Blind_Reverse_Engineering_Audit.md

Status: Active
Lifecycle: Readme (폴더 진입점, `000001_Md_Rules.md` §5.4)
Domain: Fable Blind Reverse-Engineering Audit (감사 프로그램)
Last Updated: 2026-08-11

## §1 폴더 목적

**블라인드 역설계 감사 프로그램.** 설계 문서를 보여주지 않고 **실제 코드/SQL만으로** 시스템의 의도를
역으로 재구성하게 한 뒤, 그 결과를 실제 설계 의도와 대조해 **문서-구현 간 간극**을 찾는다.

수행자는 Claude Fable, 구조·추적표 관리는 Claude Code. 도메인 6개 × Pass A/B/C 구조로 진행한다.

| Pass | 내용 |
|---|---|
| A | **블라인드 역설계** — 설계문서 없이 코드만으로 의도 재구성 |
| B | **의도 대조** — Pass A 결과 vs 실제 설계문서 |
| C | **확정 간극과 처분** |

## §2 폴더 경계 (Semantic Boundary)

### 속하는 것
- 코드만으로 수행하는 역설계 감사(Pass A/B/C)와 그 추적표
- 감사 결과로 확정된 간극 목록과 처분 판정

### 속하지 **않는** 것

| 대상 | 소속 |
|---|---|
| **설계문서·SQL·JSON 계약을 포함**한 설계무결성 검사 | **`601400_fable_design_integrity_inspection/`** — 별개 프로그램 |
| 실제 결함 수정 구현 | 각 도메인의 구현 워크패킷 |
| 13단계 파이프라인의 Stage 11B 블라인드 감사 | 각 워크패킷 내부(예: `601510`) |

> **601300 vs 601400 구분**: 601300은 **코드만 보고 역설계**(문서 미제공), 601400은 **문서·SQL·계약을 함께 보고
> 구조적 사실 기록**(옳고그름 판단 없음). 두 프로그램을 섞지 말 것.

## §3 문서 목록

| 번호 | 문서 | 역할 |
|---|---|---|
| 601300 | **본 Readme** | 폴더 진입점 |
| 601301 | `Master_Tracker.md` | 6도메인 × Pass A/B/C 진행표, Pass 불변성 원칙, Modularization Entry Gate |
| 601310 | `domain_00_common_auth/` | 공통/인증 도메인 |
| 601320 | `domain_01_payment/` | 결제 |
| 601330 | `domain_02_waiting_order/` | 대기·주문 세션 |
| 601340 | `domain_03_store_admin/` | 매장 관리자 콘솔 |
| 601350 | `domain_04_kds_did/` | KDS/DID |
| 601360 | `domain_05_cms/` | CMS |
| 601390 | `Modularization_Integration_Plan.md` | Phase 4 최종 산출물(Entry Gate로 잠김) |

## §4 운영 주의

- **Known Prior Finding 원칙**: `601210`/`601211`/`601212`는 Pass A 입력에서 **의도적으로 제외**된다 —
  이미 알려진 발견을 감사자에게 주면 블라인드가 성립하지 않기 때문이다(`601301`).
- **Pass 불변성**: 완료된 Pass 결과는 사후 수정하지 않는다. 정정이 필요하면 다음 Pass에 기록한다.

## §5 Boundary Reference Documents (`000001_Md_Rules.md` §5.2.1 필수 섹션)

| 문서 경로 | 필요한 이유 |
|---|---|
| `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` | §13.7–13.8(Dual Anchor·블라인드 감사 원칙 — 이 프로그램의 방법론적 근거), §46, §48(증거수집 5단계 분류) |
| `docs/000700_.../000716_Guide_CatchMenu_One_Time_Design_Integrity_And_Reverse_Engineering_Inspection_Operational_Plan.md` | **운영안 canonical 위치** — 두 감사 프로그램(601300/601400)의 상위 운영 계획 |
| `docs/000001_Md_Rules.md` | 문서 규격 |
| `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/601401_Master_Tracker.md` | **자매 프로그램** — 범위 중복·혼동 방지(§2 구분표) |
| `docs/600000_implementation_lifecycle/601200_caller_authorization_foundation/` | Known Prior Finding 대상 — Pass A 입력에서 제외할 문서 확인 |
| `sql/migrations/` 전체 | Pass A의 유일한 입력(설계문서 없이 코드만) |

> 새 변경건의 Stage 2가 이 표에 없는 경계 문서를 발견하면 그 Overview 작성과 동시에 여기에도 추가한다.
