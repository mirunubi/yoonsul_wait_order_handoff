# 013120_Boundary_Integration_Status_Projection

## 1 Purpose

Integration states must be projected without overstating truth.

Customer/store/admin/support surfaces may see different integration states.

This document aligns with `11020`~`11060`.

This document is projection governance only.
It does not approve status endpoints, webhooks, polling, or integration runtime.

## 2 Integration Projection Families

| projection family | conceptual meaning |
| --- | --- |
| POS API availability | Provider interfaces available for store context. |
| POS API attempt pending | Outbound POS order creation in progress. |
| POS API success | POS authority confirms order creation. |
| POS API failure | POS authority rejects, times out, or errors. |
| printer output pending | Print job queued or awaiting device. |
| printer output sent | Print command dispatched successfully. |
| printer output failed | Printer unavailable, timeout, or error. |
| Store Agent online/offline | Local agent reachability state. |
| manual POS input needed | Staff must enter order into POS manually. |
| manual POS input completed | Staff marks manual entry completed. |
| payment pending | Payment expected but not confirmed. |
| payment confirmed by store POS | Store POS authority confirms payment. |
| platform payment future | Platform payment path; not default MVP. |
| recovery required | Operational recovery needed; not resolved. |
| integration disabled | Integration profile disabled with audit. |

## 3 Surface Visibility Rules

- customer surface should not see internal integration attempts unless wording is approved.
- store console may see printer/POS/manual input operational states.
- admin console may see integration profile/status/change history.
- support console may see scoped troubleshooting state.
- audit surface may see lineage.
- export/report requires approval.

## 4 Truth Rules

- POS API attempt does not equal POS success.
- printer output does not equal POS sales creation.
- manual POS input completed is staff assertion unless POS evidence exists.
- payment pending does not equal paid.
- recovery required does not equal resolved.
- integration disabled does not erase previous attempts.

## 5 Non-Implementation Boundary

- no status endpoint.
- no webhook.
- no polling.
- no printer integration.
- no payment API.
- no recovery runtime.

## 6 Cross-References

- `docs/11000_integration_boundary/011020_Boundary_POS_API_Integration_Truth.md`
- `docs/11000_integration_boundary/011030_Boundary_Printer_And_Store_Agent.md`
- `docs/11000_integration_boundary/011040_Boundary_Payment_And_Financial_Truth.md`
- `docs/11000_integration_boundary/011050_Boundary_Manual_POS_Input_And_Reconciliation.md`
- `docs/11000_integration_boundary/011060_Boundary_Integration_Failure_Retry_And_Recovery.md`
- `docs/17000_ui_screen_composition/017060_Guide_UI_State_Wording_And_Empty_State_Guideline.md`

## 7 Open Decisions

- customer-visible integration wording.
- store-facing status granularity.
- support troubleshooting depth.
- admin integration health view.
- audit detail depth.
- exportability of integration attempts.

## 8 Current Status

Status: active integration status projection boundary. Not implementation approval.
