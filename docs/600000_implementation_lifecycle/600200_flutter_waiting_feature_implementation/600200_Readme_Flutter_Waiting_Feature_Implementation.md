# 600200_Readme_Flutter_Waiting_Feature_Implementation.md

Status: Draft  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-11

## Purpose

This folder owns controlled implementation lifecycle documentation for **Flutter waiting feature implementation** in the CatchMenu customer handoff lane, including integration with guest `customer_id` linkage after `0148`.

## In Scope

- Workpacket subfolders for waiting-feature changes (starting with `600210_waiting_feature_guest_customer_id_integration/`)
- Stage 1 (Eyes Only) raw scope and inventory reports
- Future Overview / Logic / TestPlan / ChangeContract / Module documents when authorized
- `ChangeHistory.md`, `NavigationMap.md`, and `DecisionLog.md` at this folder level

## Out of Scope

- Runtime implementation (Flutter/Dart, SQL migrations, RLS edits, Supabase Edge) unless explicitly authorized via Controlled Implementation Gate
- Architecture or client state-management standard decisions in Stage 1
- Treating quarantined `604101`–`604103` as authoritative without independent re-verification against current `catchmenu_app/`

## Owned Number Band

- Folder band: `600200`–`600299`
- Parent: `docs/600000_implementation_lifecycle/`
- Related upstream SQL lane: `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/`

## Subfolder Map

| Folder | CHANGE_ID / Topic | Status |
| --- | --- | --- |
| `600210_waiting_feature_guest_customer_id_integration/` | `waiting_feature_guest_customer_id_integration` | Draft / Stage 1 |

## Boundary Reference Documents

`000001_Md_Rules.md` §5.2.1 — 이 모듈 산하 모든 변경건(`600210` 등)이 Stage 1 스캔 시 반드시 대조해야 하는 경계 정의 문서. 각 변경건의 `Overview.md`가 갖는 "Required Context Snapshot Candidates"(1회성 스냅샷)와 달리, 이 표는 모듈 전체에 걸쳐 영구 누적된다.

| 문서 | 필요한 이유 |
| --- | --- |
| `docs/990000_legacy_quarantine/604000_workpackets/604100_flutter_mvp_foundation/604101_Overview_Flutter_MVP_Project_Structure.md` | Flutter 프로젝트 구조 baseline (§5.10 frozen, 재검증 필요 — Out of Scope 항목 참고) |
| `docs/990000_legacy_quarantine/604000_workpackets/604100_flutter_mvp_foundation/604102_Logic_Flutter_MVP_Core_Implementation.md` | `rpc_caller.dart` 설계 근거, INV 규칙 반영 방식 |
| `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | 클라이언트 RPC 호출 경계 (`rpc_caller.dart` 필수 경유 원칙) |

## File List

| Number | File | Status |
| --- | --- | --- |
| 600200 | `600200_Readme_Flutter_Waiting_Feature_Implementation.md` | Draft |
| 600201 | `600201_ChangeHistory.md` | Draft (skeleton) |
| 600202 | `600202_NavigationMap.md` | Draft (skeleton) |
| 600203 | `600203_DecisionLog.md` | Draft (skeleton) |

## Add / Move Rule

1. New workpacket subfolders use `{6-digit-band}_{snake_case_topic}/` under this folder.
2. The first official document in each new workpacket subfolder should use that subfolder's number band; add a subfolder Readme when the subfolder receives its first governed document.
3. Any create, rename, or move must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
4. Also update `600000_Readme_Implementation_Lifecycle.md` when this folder's role or membership changes.

## Non-Implementation Boundary

This folder does not grant Codex, Cursor, or Claude permission to modify SQL, migrations, application code, or runtime configuration. Human Approval and ChangeContract are required before any implementation stage.
