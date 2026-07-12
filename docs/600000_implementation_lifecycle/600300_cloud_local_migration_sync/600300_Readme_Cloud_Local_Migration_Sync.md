# 600300_Readme_Cloud_Local_Migration_Sync.md

Status: Draft  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-12

## Purpose

This folder owns controlled implementation lifecycle documentation for **cloud vs local SQL migration synchronization** — auditing what the hosted Supabase project (`upzthfwhtvazfftxnyfu`) actually contains versus `sql/migrations/`, and planning evidence-based apply/reconcile work.

## In Scope

- Workpacket subfolders for cloud-state audit and sync changes (starting with `600310_initial_cloud_state_audit/`)
- Stage 1 (Eyes Only) raw scope and inventory reports
- Human-executed cloud SQL query sets (Cursor cannot connect to cloud directly)
- Future Overview / Logic / TestPlan / ChangeContract / Module documents when authorized
- `ChangeHistory.md`, `NavigationMap.md`, and `DecisionLog.md` at this folder level

## Out of Scope

- Executing migrations against cloud without explicit Human Approval and ChangeContract
- Treating `supabase db diff --linked` or empty `supabase/migrations/` as authoritative sync truth without independent verification
- Runtime Flutter/Dart or application code changes unless separately authorized

## Owned Number Band

- Folder band: `600300`–`600399`
- Parent: `docs/600000_implementation_lifecycle/`
- Cloud project ref (audit target): `upzthfwhtvazfftxnyfu`

## Subfolder Map

| Folder | CHANGE_ID / Topic | Status |
| --- | --- | --- |
| `600310_initial_cloud_state_audit/` | `initial_cloud_state_audit` | Draft / Stage 1 |

## Boundary Reference Documents

`000001_Md_Rules.md` §5.2.1 — 이 모듈 산하 모든 변경건이 Stage 1 스캔 시 반드시 대조해야 하는 경계 정의 문서.

| 문서 | 필요한 이유 |
| --- | --- |
| `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` §25 (Reality-Verification Requirement) | 문서·체크섬·self-report와 실제 DB 상태 간 gap 검증 원칙; Stage 5는 raw command evidence만 신뢰 |
| `sql/migrations/CHANGELOG.md` (전체, 특히 **2026-07-11** 항목 전부) | 로컬 검증 이력·§24 live-function 재실행·0148–0150·stale 컬럼 수정·`supabase db diff --linked` 비신뢰 기록의 narrative authority |
| `sql/migrations/CHANGELOG.md` — `2026-07-11 — order_sessions.customer_id 컬럼 부재…` | 클라우드/로컬 동시 `customer_id` 부재 확정, 드리프트 아님 재분류, CLI vs `sql/migrations/` 이중 체계 |
| `sql/migrations/CHANGELOG.md` — `2026-07-11 — 0148 order_sessions customer identity FK and guest flag` | 0148 범위·out-of-band FK 정리·open items |
| `sql/migrations/CHANGELOG.md` — `2026-07-11 — 0149 guest customer bootstrap helper…` | `get_or_create_guest_customer`·0115/0116 patch·검증 시 발견된 stale 컬럼 blocker |
| `sql/migrations/CHANGELOG.md` — `2026-07-11 — 0115/0116/0149 live-function column audit and 0150…` | §24 checksum≠live function, 0081/0097/0108/0116/0149 stale 컬럼 수정, 0150 `chk_event_domain` |
| `sql/migrations/CHANGELOG.md` — `2026-07-11 — Lightweight Bugfix: register_waiting/bootstrap…` | 0115/0116 소스 정합 vs 라이브 DB 미해결 범위 제약 기록 |
| `sql/migrations/0000_create_migration_history_table.sql` | `catchmenu_meta.migration_history` 설계 — 클라우드에 스키마/테이블 부재 시 추적 공백의 근거 |
| `tools/apply_migrations.py` | 이 프로젝트의 실제 로컬 적용 경로 (`ls`/`docker cp` 계열; Supabase CLI native tracking 미사용) |

## File List

| Number | File | Status |
| --- | --- | --- |
| 600300 | `600300_Readme_Cloud_Local_Migration_Sync.md` | Draft |
| 600301 | `600301_ChangeHistory.md` | Draft (skeleton) |
| 600302 | `600302_NavigationMap.md` | Draft (skeleton) |
| 600303 | `600303_DecisionLog.md` | Draft (skeleton) |
| 600311 | `600310_initial_cloud_state_audit/600311_Overview.md` | Complete |

**Next free number: `600312`** (within the `600310_initial_cloud_state_audit/` subfolder band; the folder's own `600300`–`600309` file-level band remains at `600304` next free).

## Add / Move Rule

1. New workpacket subfolders use `{6-digit-band}_{snake_case_topic}/` under this folder.
2. The first official document in each new workpacket subfolder should use that subfolder's number band; add a subfolder Readme when the subfolder receives its first governed document.
3. Any create, rename, or move must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
4. Also update `600000_Readme_Implementation_Lifecycle.md` when this folder's role or membership changes.

## Non-Implementation Boundary

This folder does not grant permission to apply migrations to cloud, modify production schema, or treat inventory reports as sync approval. Human Approval and ChangeContract are required before any implementation stage.
