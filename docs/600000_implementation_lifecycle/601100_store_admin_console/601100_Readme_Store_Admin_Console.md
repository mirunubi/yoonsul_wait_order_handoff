# 601100_Readme_Store_Admin_Console.md

Status: Active
Lifecycle: Readme
Domain: Store Admin Console

## Purpose

This folder owns the **store owner/manager back-office console** domain: the SQL-layer RPCs a store admin (`OWNER`/`MANAGER` role, per `catchmenu_store.staff.staff_role`) uses to configure their own store's operational master data — menu catalog (items, categories, options), dining table inventory, staff accounts, business hours/holidays, store settings, and POS/delivery-app integration. This is a **new** domain (2026-07-16) — no prior workpacket owned this scope as a unit. The closest existing pieces (`0110_create_store_admin_rpc.sql`'s 10-function RPC suite, `0048_create_table_management_rpc.sql`'s 4-function table-operations suite, `0044_create_menu_management_rpc.sql`'s menu-catalog/status RPCs) were scattered across the POS/Store schemas and are catalogued, not owned, by this folder until a workpacket formally migrates or wraps them.

## In Scope

- Menu catalog admin CRUD (create/edit/status, categories, option groups/items) — currently `catchmenu_store.upsert_menu()`/`set_menu_status()`/`get_menu_admin_list()` (`0110`), broken by phantom-column drift.
- Dining table admin CRUD (create/edit/deactivate table records) — currently absent; only operational RPCs (status/QR/release, `0048`) exist, seeded via direct `INSERT` (`0034`) only.
- Multi-channel menu price list architecture (`price_lists`/`price_list_assignments`/`menu_prices`/`option_item_prices`, canonical `resolve_menu_price()` resolver) — new sub-scope discovered/split 2026-07-16 (`601130_menu_price_list_architecture/`), not covered by any prior workpacket.
- Staff account admin (`upsert_staff()`/`get_staff_admin_list()`, `0110`) — not yet investigated by this domain's first workpacket.
- Business hours / holiday admin (`set_store_hours()`/`set_holiday()`, `0110`) — not yet investigated.
- Store settings / POS integration admin (`update_store_settings()`/`setup_pos_integration()`, `0110`) — not yet investigated.
- Store admin dashboard aggregation (`get_store_admin_dashboard()`, `0110`) — not yet investigated; depends on the menu/staff/hours pieces above being correct.

## Out of Scope

- Menu **content delivery** to signage/kiosk/DID devices — owned by `601000_cms_content_management/`.
- KDS ticket lifecycle — owned by `600400_kds_did_implementation/`.
- Table **operational** state machine (status/QR/release/session binding) — already implemented and column-correct in `0048_create_table_management_rpc.sql`; this domain only adds the missing CRUD (create/list/deactivate) layer around it.
- Payment confirmation — `600500_payment_confirmation/`.
- Waiting/order session lifecycle — `600600_waiting_order_session/`.

## Subfolder Map

See `601102_NavigationMap_Store_Admin_Console.md` for the detailed per-workpacket stage tracking (Overview → Logic → TestPlan → ChangeContract → Module → Verification → Audit). The table below is a lighter-weight summary.

| Folder | Role | Status |
|---|---|---|
| `601110_store_admin_sql_layer_reconciliation/` | Stage 1.5 Overview + Logic — **menu-RPC phantom-column repair only** (`upsert_menu()`/`set_menu_status()`/`get_menu_admin_list()` + the shared `get_store_admin_dashboard()` crash point, 3-tier redesign per Option C). Scope narrowed twice 2026-07-16 (Human decisions) — dining-table CRUD split out to `601120`, then the Price List architecture extension (discovered mid-Logic) split out to `601130`. | Overview + Logic complete 2026-07-16, ready for TestPlan/ChangeContract. |
| `601120_dining_table_crud_creation/` (가칭) | Dining table admin CRUD (create/list/deactivate) — split out from `601110` for separate rollback/verification/traceability. Investigation already done (20-column schema, `table_code`+`capacity` minimal-create finding, 4 existing operational RPCs confirmed phantom-free) is preserved in `601111_Overview...md` §4 as the starting point. | **Number reserved only — not started.** |
| `601130_menu_price_list_architecture/` | Multi-channel menu price list architecture (`price_lists`/`price_list_assignments`/`menu_prices`/`option_item_prices` schema + canonical `resolve_menu_price()` resolver + additive, non-destructive migration path for the 9 confirmed live consumers of `menus.price`). Split out from `601110`'s Logic doc 2026-07-16 (Human decision) once its scope/risk proved fundamentally different from the phantom-column repair. | Overview + Logic complete 2026-07-16 (investigation + design), Open Items remain before TestPlan/ChangeContract. |

## Numbering Note

`601100` is the next unused domain-range slot following the existing `600100`-`601000` sequence (confirmed via directory listing — no folder or `990000_legacy_quarantine/` entry occupies `601100`). See `601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md` §0 for the full confirmation basis.
