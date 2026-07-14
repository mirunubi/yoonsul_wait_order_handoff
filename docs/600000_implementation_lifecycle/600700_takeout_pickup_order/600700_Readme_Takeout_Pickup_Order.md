# 600700_Readme_Takeout_Pickup_Order.md

Status: Active
Lifecycle: Readme
Domain: Takeout / Pickup Order

## Purpose

This folder owns takeout and pickup-order workpackets whose primary defect surface is `catchmenu_pos.orders`, takeout order RPC behavior, or pickup/ready timing.

## In Scope

- `place_takeout_order()` record-to-scalar correction and associated takeout order behavior.
- `orders.requested_pickup_at` / `orders.ready_at` timing-column migration records.

## Out of Scope

- Waiting/order-session session-type contracts.
- Payment provider confirmation overload disposition.
- DID display-state overload work.
- KDS-only capacity/status reconciliation.

## Subfolder Map

| Folder | Role | Status |
|---|---|---|
| `600710_place_takeout_order_unassigned_record_fix/` | `place_takeout_order()` unassigned-record/scalar-variable correction. | Moved from `600400_kds_did_implementation/`; NavigationMap row newly created from existing completed records. |
| `600720_orders_pickup_ready_timing_columns_migration/` | `orders.requested_pickup_at` and `orders.ready_at` migration workpacket. | Moved from `600400_kds_did_implementation/`. |

