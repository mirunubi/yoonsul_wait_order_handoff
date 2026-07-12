# 604500_Readme_Order_Sessions_Customer_Id_Fk_And_Guest_Promotion.md

Status: Draft  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-11  
CHANGE_ID: `order_sessions_customer_id_fk_and_guest_promotion`

## Purpose

This folder owns controlled implementation lifecycle documentation for **order_sessions.customer_id FK and guest-to-customer promotion** (`order_sessions_customer_id_fk_and_guest_promotion`).

## In Scope

- Stage 1 (Eyes Only) raw scope and inventory reports
- Future Overview / Logic / TestPlan / ChangeContract / Module documents for this change, when authorized
- Documentation traceability from SQL (`catchmenu_pos.order_sessions`, `catchmenu_store.customers`), RLS, tests, Flutter callers, and related docs

## Out of Scope

- Runtime implementation (SQL migrations, RLS edits, Flutter/Dart, Supabase Edge) unless explicitly authorized via Controlled Implementation Gate
- Architecture or DB standard decisions in Stage 1
- Treating `docs/implementation_evidence/order_sessions_customer_id_fk_and_guest_promotion/DesignPack.md` as authoritative input

## Owned Number Band

- Folder band: `604500`–`604599`
- Parent: `docs/600000_implementation_lifecycle/604000_workpackets/`

## File List

| Number | File | Status |
| --- | --- | --- |
| 604500 | `604500_Readme_Order_Sessions_Customer_Id_Fk_And_Guest_Promotion.md` | Draft |

## Subfolder Map

This folder has no child subfolders. It is a leaf workpacket under `604000_workpackets/`.

## Add / Move Rule

1. New documents must use numbers within `604500`–`604599` without reusing existing numbers.
2. Add files only inside this folder; do not place workpacket documents directly under `600000_implementation_lifecycle/` root.
3. Any create, rename, or move must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
4. Parent folder Readmes (`600000_Readme_Implementation_Lifecycle.md`, `604000_Readme_Workpackets.md`) must also be updated when this folder's role or membership changes.
5. Stage 1 artifacts are inventory/report only; they do not authorize implementation.

## Non-Implementation Boundary

This folder does not grant Codex, Cursor, or Claude permission to modify SQL, migrations, application code, or runtime configuration. Human Approval and ChangeContract are required before any implementation stage.
