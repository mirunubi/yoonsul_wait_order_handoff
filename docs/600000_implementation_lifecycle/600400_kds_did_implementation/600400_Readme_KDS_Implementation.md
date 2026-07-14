# 600400_Readme_KDS_Implementation.md

Status: Draft  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-14

## Purpose

This folder owns controlled implementation lifecycle documentation for **KDS(주방 디스플레이) 관련 결함 발견 및 정정 작업**을 다룬다. DID work has been separated into `../600800_did_implementation/`. `000701_Guide_Controlled_AI_Development_Pipeline.md` §35의 "전수 문서 조사 폐기, 결함-기반 문서 연결" 원칙을 이 모듈에서 적용한다.

## §0 이 모듈의 작업 방식 (Human 결정, 2026-07-11, 재논의 금지)

전수 문서 조사 방식을 폐기한다. 대신: **결함을 하나 고칠 때마다, 그 근거가 된 원본 설계 문서(900xxx 등)를 해당 변경건의 `Overview.md`에 링크하고, `600401_ChangeHistory.md`에 무엇을/왜 고쳤는지 기록**하는 방식으로 문서-코드 연결을 자연스럽게 구축한다. 이렇게 연결이 확인된 문서는 "살아있는 문서"로 남고, 끝까지 연결 안 되는 문서는 자연스럽게 고아 문서 후보로 드러난다 — 별도 전수 검증 작업을 만들지 않는다.

## In Scope

- KDS 런타임 결함 발견 및 정정 워크패킷
- 각 변경건의 `Overview.md`에 그 결함과 직접 관련된 설계 문서만 선별적으로 링크(전수 스캔 아님)
- `ChangeHistory.md`, `NavigationMap.md`, `DecisionLog.md` 이 폴더 레벨에서 관리

## Out of Scope

- Human Approval 없이 `sql/migrations/**` 실제 생성/수정
- 이 모듈 밖 결함(결제/대기·세션/포장·픽업/DID/교차도메인/고객식별/Flutter 등)을 이 모듈에서 다루는 것 — 각자의 도메인 폴더로 분리
- 결함과 무관한 문서를 "혹시 몰라서" 미리 링크하는 것(§0 원칙 위반 — 연결은 결함이 실제로 그 문서를 근거로 삼을 때만 생긴다)

## Owned Number Band

- Folder band: `600400`–`600499`
- Parent: `docs/600000_implementation_lifecycle/`

## Subfolder Map

| Folder | CHANGE_ID / Topic | Status |
| --- | --- | --- |
| `600410_kds_capacity_gate_and_status_reconciliation/` | `kds_capacity_gate_and_status_reconciliation` | Audited |
| `600420_kds_status_naming_and_stale_columns/` | `kds_status_naming_and_stale_columns` | Audited |
| `600440_kds_status_committed_unification/` | `kds_status_committed_unification` | Audited |

## File List

| Number | File | Status |
| --- | --- | --- |
| 600400 | `600400_Readme_KDS_Implementation.md` | Draft |
| 600401 | `600401_ChangeHistory.md` | Draft (skeleton) |
| 600402 | `600402_NavigationMap.md` | Draft (skeleton) |
| 600403 | `600403_DecisionLog.md` | Draft (skeleton) |
| 600404 | `600404_PlaceTakeoutOrder_Defect_Roadmap.md` | Living roadmap |

## Add / Move Rule

1. New KDS workpacket subfolders use `{6-digit-band}_{snake_case_topic}/` under this folder.
2. The first official document in each new workpacket subfolder should use that subfolder's number band; add a subfolder Readme when the subfolder receives its first governed document.
3. Any create, rename, or move must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
4. Also update `600000_Readme_Implementation_Lifecycle.md` when this folder's role or membership changes.

## Non-Implementation Boundary

This folder does not grant permission to modify SQL, migrations, application code, or runtime configuration. Human Approval and ChangeContract are required before any implementation stage.
