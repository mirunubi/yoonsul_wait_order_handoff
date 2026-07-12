# 604000_Readme_Workpackets.md

Status: Active  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-11

## Purpose

This folder owns implementation workpacket containers. Each workpacket is a bounded documentation pack for one controlled change lane (Overview / Logic / TestPlan / ChangeContract / Module / Audit as authorized).

## In Scope

- One subfolder per workpacket: `604xxx_<module_name>/`
- Workpacket Readme, ImpactScope, architecture, test, contract, module, and audit documents for authorized lanes
- Stage 1 (Eyes Only) inventory reports when explicitly scoped to a workpacket

## Out of Scope

- Documents placed directly under `604000_workpackets/` root (except this Readme)
- Runtime implementation without Human Approval and ChangeContract
- Reusing quarantined workpacket numbers for new active lanes without explicit renumbering review

## Owned Number Band

- Container band: `604000`–`604999`
- Container Readme number: `604000`
- Parent: `docs/600000_implementation_lifecycle/`

## Subfolder Map

| Folder | CHANGE_ID / Topic | Status |
| --- | --- | --- |
| `604500_order_sessions_customer_id_fk_and_guest_promotion/` | `order_sessions_customer_id_fk_and_guest_promotion` | Draft / Stage 1 |

Historical workpackets (`604100`–`604400` and related) remain in `docs/990000_legacy_quarantine/604000_workpackets/` until explicitly restored.

## File List

| Number | File | Status |
| --- | --- | --- |
| 604000 | `604000_Readme_Workpackets.md` | Active |

## Add / Move Rule

1. Allocate the next free `604xxx` workpacket folder band from `docs/000005_Index_Document_Number.md` before creating a subfolder.
2. The first file in every new workpacket subfolder must be `{folder_number}_Readme_{name}.md`.
3. Any create, rename, or move must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
4. Do not place implementation documents directly under `600000_implementation_lifecycle/` root.

## Non-Implementation Boundary

Workpacket folders are documentation containers only. They do not grant Codex, Cursor, or Claude permission to modify runtime assets.
