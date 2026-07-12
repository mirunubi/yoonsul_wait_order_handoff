# 600000_Readme_Implementation_Lifecycle.md

Status: Active  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-11

## Purpose

This folder is the active implementation lifecycle band for controlled workpacket documentation: planning, design, approval, execution evidence, verification, audit, and closeout records.

## In Scope

- Active domain folders such as `600100_customer_identity_and_guest_promotion/` and `600200_flutter_waiting_feature_implementation/`
- Active workpacket folders under `604000_workpackets/`
- Future restoration of other quarantined `60xxxx` sub-bands when explicitly authorized
- Registration in `docs/000005_Index_Document_Number.md` and `docs/000007_Map_Full_Directory.md`

## Out of Scope

- Runtime code, SQL migrations, Flutter/Dart, Supabase Edge, or package changes unless a separate authorized gate grants them
- Direct placement of workpacket documents at this folder root
- Treating quarantined historical copies as the active source of truth

## Owned Number Band

- Root band: `600000`–`609999`
- Root Readme number: `600000`
- Active navigation index for historical content: `docs/990000_legacy_quarantine/600000_Index_Implementation_Lifecycle.md`
- Governance foundation: `docs/000700_ai_agent_prelearning_and_project_context/000714_Readme_Implementation_Lifecycle_Governance.md`

## Subfolder Map

| Folder | Role | Status |
| --- | --- | --- |
| `600100_customer_identity_and_guest_promotion/` | Customer identity / guest promotion documentation lane | Active |
| `600200_flutter_waiting_feature_implementation/` | Flutter waiting feature implementation documentation lane | Active |
| `604000_workpackets/` | Approved implementation workpacket containers | Active |

Quarantined historical bands (`600100_readme_governance/`, `601000`, `602000`, `603000`, `605000`–`609000`) remain in `docs/990000_legacy_quarantine/` until explicitly restored.

## File List

| Number | File | Status |
| --- | --- | --- |
| 600000 | `600000_Readme_Implementation_Lifecycle.md` | Active |

## Add / Move Rule

1. Every new subfolder must receive `{folder_number}_Readme_{name}.md` before other documents are added.
2. Any folder create, rename, move, or quarantine must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
3. Do not create another active `600000_*` index file in this folder root.
4. Workpacket documents belong under `604000_workpackets/<workpacket_folder>/`, not directly here.

## Non-Implementation Boundary

This folder does not authorize implementation by itself. Controlled Implementation Gate approval is required before any runtime change.
