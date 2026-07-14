# 600500_Readme_Payment_Confirmation.md

Status: Active
Lifecycle: Readme
Domain: Payment Confirmation

## Purpose

This folder owns payment-confirmation workpackets that are not KDS, waiting/session, takeout/pickup, DID, or cross-domain reconciliation work.

## In Scope

- Payment provider confirmation RPC ambiguity and legacy overload disposition.
- Payment confirmation verification, module, and audit records moved out of the former mixed KDS/DID folder.

## Out of Scope

- KDS capacity/status reconciliation.
- Waiting/order-session reconciliation.
- Takeout/pickup order defects.
- DID display-state implementation.
- Cross-domain stale-column reconciliation batches.

## Subfolder Map

| Folder | Role | Status |
|---|---|---|
| `600510_confirm_payment_from_provider_overload_ambiguity/` | `confirm_payment_from_provider()` legacy overload disposition. | Moved from `600400_kds_did_implementation/`. |

