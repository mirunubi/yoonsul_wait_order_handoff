# 600010_Tracker_Spiral_Workpacket_Progress.md

Status: Active
Lifecycle: Tracker
Domain: Implementation Lifecycle (전 나선 공통)
Last Updated: 2026-08-10

## §0 목적과 경계

`000701` §47의 **6단계 나선 개발방법론**에 따라 진행되는 **구현 워크패킷**의 진행 상태를 한 곳에서 추적한다.
0-A 이후 0-B / 0-C / 1-1 등 **다른 나선의 워크패킷도 전부 여기에 누적**되므로,
특정 워크패킷 폴더 안이 아니라 `600000_implementation_lifecycle` **루트**에 둔다.

### §0.1 `601401_Master_Tracker.md`와 무엇이 다른가 (혼동 방지)

두 문서는 이름이 비슷하나 **추적 대상이 완전히 다르다.** 섞어 쓰면 잘못된 프로그램의 진행표를 오염시킨다.

| | **본 문서 (600010)** | `601401_Master_Tracker.md` |
|---|---|---|
| 추적 대상 | `000701` §47 나선의 **구현 워크패킷** | `601400_fable_design_integrity_inspection` 프로그램의 **13개 도메인 검사** |
| 성격 | 무언가를 **만드는** 작업 | 기존 산출물을 **검사하는** 작업 |
| 진행 축 | 13단계 파이프라인 Stage 1–12 | Stage 1 인벤토리 / Stage 2 분류 / Fable Pass |
| 소속 프로그램 | 없음 (전 나선 공통) | `601400` 전용 |

> 2026-08-10 기록: 0-A(601500)를 `601401`에 등재하려는 시도가 있었으나 **부적절**로 판정되어
> 본 트래커를 신설했다. 경위는 `601505` §8A 참조.

### §0.2 이 트래커가 하지 않는 것

- 승인·판정을 하지 않는다. Stage 7/11/12의 권한을 대체하지 않는다.
- 설계 내용을 담지 않는다. 각 워크패킷의 문서로 간다.
- **`완료`는 Stage 12(Human 병합/릴리스) 통과 후에만 기록한다.** 그 전에는 전부 `진행중`이다.

## §1 진행 현황

| 나선 | 워크패킷 | 현재 Stage | 최종 상태 | 최종 갱신일 |
|---|---|---|---|---|
| **0-A** Tenant/LegalEntity/HQ/Store | `601500_operational_authority_foundation` | **Stage 12** (Human Merge) | ✅ **완료** (2026-08-11, Human 최종승인) | 2026-08-11 |
| **0-B** Staff identity / session | 미배정 | — | **착수 가능** (0-A 완료로 선행조건 해소) | 2026-08-11 |

### §1.1 0-A / 601500 완료 기록

**전 Stage 통과** (2026-08-11 Stage 12 Human 승인으로 종결):

| Stage | 산출물 | 결과 |
|---|---|---|
| 8 | `0168` + `0169` | 적용 완료 |
| 9 | `601506` / `601507` | 차단 우려사항 없음 (Cursor + Claude Code, §37에 따라 Codex 제외) |
| 10 | `601507` / `601508` | 문서화 완료 |
| 11A | `601509` → **`601511`(재감사 최종)** | **`APPROVE_WITH_NOTES`** |
| **11B** | **`601510`** | **`BLOCK`** → 조건 ①③④ 충족, ②는 0-C로 이월(§1.2) → **해소** |
| 12 | Human | ✅ **승인 (2026-08-11)** |

**적용된 마이그레이션 2개**: `0168`(신규 테이블 4 + 컬럼 3), `0169`(전용 owner role + SOLE 유일성).

**완료 시점에도 남아 있는 것 (이월, 계속 추적)**:

| 항목 | 이월처 |
|---|---|
| **Stage 11B 조건 ②**(`SECURITY DEFINER` search_path/PUBLIC EXECUTE/tenant 경계) | **0-C — §1.2 게이트** |
| Open Item (m) 클라우드 미검증(`pg_cron` / 카탈로그 / PG 버전) | 클라우드 배포 시 |
| `tenant` `ACTIVE`+`ISOLATED` 동시상태의 **과금정책 미정** | **0-A-2 착수 전 결정 필요**(`601511`) |
| "행위기준 완료조건"의 **기계적 강제(CI) 부재** | 프로젝트 전체 구조적 공백(`601511`) |

> **⚠️ 완료가 곧 안전은 아니다**: 0-A는 `isolate_tenant()`를 **의도적 장애 상태**로 남긴 채 병합됐다.
> `601505` §4의 금지 조항(호출 금지·`ACTIVE` 승격 금지·신규 호출자 배포 금지)은 **0-A-2 완료까지 계속 유효**하다.

**다음 필수 워크패킷**: **0-A-2** — `601505` §8A에 따라 **0-B보다 우선**한다.

### §1.2 ⚠️ 0-C 착수 필수 선행조건 — `601503` §9 게이트 (미충족 시 반려)

> **Stage 11B(`601510`) 4개 조건 중 ②만 0-A에서 이행할 수 없어 0-C로 이월된 항목이다.**
> 0-A에는 함수가 하나도 없어 조건 ②(search_path / PUBLIC EXECUTE / tenant 경계)의 **적용 대상 자체가 없었다**.
> **따라서 조건 ②는 지금도 미충족 상태이며, 0-C가 이행하지 않으면 영구히 미충족으로 남는다.**

**적용 대상**: `catchmenu_hq`의 **4개 테이블** —
`owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives` —
에 접근하는 **모든 `SECURITY DEFINER` 함수**.

**필수 6규칙 (`601503` §9.1) — 하나라도 누락 시 반려**:

| # | 규칙 |
|---|---|
| 1 | 함수 소유자를 **`catchmenu_authority_owner`** 로 지정 |
| 2 | migration에 **`alter function … owner to catchmenu_authority_owner;`** 명시 |
| 3 | **`revoke all on function … from public;`** 후 필요 role에만 `grant execute` |
| 4 | **`set search_path = catchmenu_hq, pg_catalog`** 고정 (**`public` 제외**) |
| 5 | 함수 본문의 모든 테이블·함수 참조를 **schema-qualified** 로 작성 |
| 6 | 함수 내부에서 **호출자의 tenant 권한을 명시적으로 검증**(confused deputy 방지) |

**함수 생성 후 반드시 `601503` §9.4의 CI 검증 쿼리 3종을 실행**한다
(소유자·`proconfig` 점검 / `PUBLIC` EXECUTE 잔존 0건 / `search_path` 미설정 0건).

> **우선순위 주의**: **4·5번(`search_path`)이 1번(소유자)보다 시급하다.**
> 소유자 위반의 최악은 "함수가 동작하지 않음"이지만,
> `search_path` 위반의 최악은 **"공격자가 함수 소유자 권한으로 임의 코드 실행"** 이다(`601503` §9.2).

> **이 게이트는 워크패킷 이름과 무관하게 적용된다** — "0-C"라고 불리지 않는 작업이라도,
> 위 4개 테이블에 접근하는 `SECURITY DEFINER` 함수를 만든다면 동일하게 적용한다.

## §2 나선 로드맵 (등재 예정)

`000701` §47.3 확정 순서. 착수 시 §1에 행을 추가한다.

| 나선 | 범위 | 상태 |
|---|---|---|
| 0-A | Tenant / Company / HQ / Store | ✅ **완료 (2026-08-11)** — §1 등재 |
| **0-A-2** | RPC·배치 정합(`isolate_tenant`/`manage_subscription`/필터/`is_registered`) | ⭐ **다음 필수 착수** (0-A 완료로 선행조건 해소, **0-B보다 우선**) |
| 0-A-3 | `onboard_tenant` / `provision_tenant` 재설계 | 미착수 |
| **0-B** | Staff identity / session | **착수 가능** (0-A 완료). 다만 §8A 순서상 **0-A-2 이후** 권장 |
| **0-C** | Authorization (caller-authorization 공백 해결) — ⚠️ **착수 전 §1.2 필독** | 미착수 |
| 0-D | Customer identity 기반 | 미착수 |
| 0-E | Menu definition (seed_menu 포함) | 미착수 |
| 0-F | Dining table definition | 미착수 |
| 1-1 | 멤버십 | 미착수 |
| 1-2 | 관리자페이지 UI | 미착수 |
| 1-3A~G | 대기-사전주문-홀배정 (7개 소나선) | 미착수 |
| 1-4 | KDS/DID | 미착수 |

> 0-A-2 / 0-A-3은 `000701` §47.3 원문에는 없고, 0-A 진행 중 범위 절단(`601502` §3.2)으로 분리된
> **파생 워크패킷**이다. 나선 순서상 0-B보다 앞선다.

## §3 갱신 규칙

1. Stage가 바뀔 때마다 해당 행의 `현재 Stage`와 `최종 갱신일`을 갱신한다.
2. **`완료`는 Stage 12 통과 후에만** 기록한다(§0.2).
3. 새 워크패킷 착수 시 §1에 행을 추가하고 §2에서 상태를 옮긴다.
4. 이 문서는 **상태만** 담는다. 근거·판정은 각 워크패킷 문서에 있다.

## §4 근거 문서 목록 (§46)

| 문서 | 역할 |
|---|---|
| `docs/000700_.../000701_Guide_Controlled_AI_Development_Pipeline.md` §3(13단계), §13.7–§13.8(Stage 11B 의무), §47(6단계 나선·개발순서) | 추적 축의 정의 |
| `docs/000001_Md_Rules.md` §5.4.x | 문서 규격 |
| `docs/.../601500_operational_authority_foundation/` `601500`~`601508` | 0-A 워크패킷 산출물 |
| `docs/.../601400_.../601401_Master_Tracker.md` | §0.1 구분 대상(별개 프로그램) |
