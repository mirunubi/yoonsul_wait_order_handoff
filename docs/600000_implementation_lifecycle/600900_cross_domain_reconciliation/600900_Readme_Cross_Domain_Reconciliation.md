# 600900_Readme_Cross_Domain_Reconciliation.md

Status: Active
Lifecycle: Readme
Domain: Cross-Domain Reconciliation

## Purpose

This folder owns cross-domain reconciliation workpackets whose scope spans more than one runtime domain and should not remain inside the KDS-only folder.

## In Scope

- Multi-file stale-column reconciliation batches.
- Cross-domain contract repairs that are not owned by a single payment, waiting/session, takeout/pickup, KDS, or DID folder.

## Out of Scope

- Single-domain KDS capacity/status work.
- Payment-only provider confirmation work.
- Waiting/order-session-only reconciliation.
- Takeout/pickup-only order timing work.
- DID-only overload work.

## Subfolder Map

| Folder | Role | Status |
|---|---|---|
| `600430_stale_column_reconciliation_batch/` | Cross-domain stale-column reconciliation batch. | Moved from `600400_kds_did_implementation/`. |

