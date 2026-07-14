# 600600_Readme_Waiting_Order_Session.md

Status: Active
Lifecycle: Readme
Domain: Waiting / Order Session

## Purpose

This folder owns waiting and order-session workpackets that were previously mixed into the KDS/DID implementation folder.

## In Scope

- Takeout session-type reconciliation where the defect is rooted in order-session status/session-type contracts.
- Customer handoff contract reconciliation for waiting, pre-order, payment, KDS, and DID boundary facts where the active fix belongs to waiting/order-session contracts.

## Out of Scope

- Payment provider confirmation overload disposition.
- Takeout/pickup order table timing columns.
- DID display-state overload work.
- KDS-only capacity/status work.

## Subfolder Map

| Folder | Role | Status |
|---|---|---|
| `600610_takeout_session_type_fix/` | `TAKEOUT` session-type alignment across order-session creation and takeout order flow. | Moved from `600400_kds_did_implementation/`. |
| `600620_customer_handoff_contract_reconciliation/` | Customer handoff contract reconciliation for waiting/order-session flow. | Moved from `600400_kds_did_implementation/`. |

