# 17090 Integration Status UI Wording Model

## 1 Purpose

Integration UI wording must not overstate operational or financial truth.

Different surfaces may expose different levels of integration status.

This document aligns with `11020`~`11060` and `13120`.

This document is UI wording governance only.
It does not create final copywriting, translations, or UI components.

## 2 Integration UI State Families

| state family | UI meaning |
| --- | --- |
| POS API unavailable | POS API not reachable or not configured. |
| POS API attempt pending | POS order creation in progress. |
| POS API success | POS authority confirms order creation. |
| POS API failure | POS authority rejects, times out, or errors. |
| printer output pending | Print job queued or awaiting device. |
| printer output sent | Print command dispatched successfully. |
| printer output failed | Printer unavailable, timeout, or error. |
| Store Agent online/offline | Local agent reachability indicator. |
| manual POS input needed | Staff must enter order into POS manually. |
| manual POS input completed | Staff marks manual entry completed. |
| payment pending | Payment expected but not confirmed. |
| payment confirmed by store POS | Store POS authority confirms payment. |
| platform payment future | Platform payment path; not default MVP. |
| recovery required | Operational recovery needed; not resolved. |
| integration disabled | Integration profile disabled with audit. |

## 3 Wording Rules

- printer sent does not equal POS confirmed.
- POS API attempt does not equal POS success.
- payment pending does not equal paid.
- manual POS input completed is staff assertion unless POS evidence exists.
- retry/recovery UI must not imply success before confirmation.
- Store Agent online does not equal POS authority.
- integration disabled does not erase previous attempts.
- customer-facing wording must avoid false confirmation.

## 4 Surface Differences

| surface | wording posture |
| --- | --- |
| customer wording | Simple, non-technical; avoid internal integration attempts unless approved. |
| store console wording | Operational states for printer, POS, manual input, and recovery. |
| admin console wording | Integration profile, status, change history, and health indicators. |
| support console wording | Scoped troubleshooting state within session boundary. |
| audit wording | Lineage and event history without overstating outcome. |

## 5 Cross-References

- `docs/11000_integration_boundary/11020_POS_API_Integration_Truth_Boundary.md`
- `docs/13000_app_api_projection/13120_Integration_Status_Projection_Boundary.md`
- `docs/17000_ui_screen_composition/17060_UI_State_Wording_And_Empty_State_Guideline.md`

## 6 Open Decisions

- whether printer-sent state is customer-visible.
- whether POS API failure is customer-visible.
- whether payment status appears in MVP.
- whether manual POS input completed is visible to tenant admin.
- whether integration health badges are shown.

## 7 Current Status

Status: active integration status UI wording model. Not implementation approval.
