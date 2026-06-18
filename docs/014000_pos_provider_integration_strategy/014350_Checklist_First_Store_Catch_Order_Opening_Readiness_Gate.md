# 014350_Checklist_First_Store_Catch_Order_Opening_Readiness_Gate.md

## 1. Purpose

This checklist defines the first-store Catch & Order opening readiness gate.

It is used after manual POS/KDS fallback readiness has been prepared, but before Catch & Order is activated for the first store.

The goal is to confirm that store operation, staff training, POS/KDS fallback, payment/order separation, support escalation, evidence capture, and daily close are ready for live use.

## 2. Core Rule

The first store must not activate Catch & Order unless the readiness gate passes.

If any critical item fails, activation must be delayed, downgraded, or limited to internal dry-run mode.

## 3. Gate Status

| Status | Meaning |
|---|---|
| Not Ready | Critical requirements are missing |
| Ready With Conditions | Activation allowed only with listed restrictions |
| Ready For Dry Run | Internal staff-only test allowed |
| Ready For Controlled Activation | Limited customer-facing activation allowed |
| Ready For Full First-Store Activation | Store can operate approved first-store scope |
| Hold | Do not activate until owner review |

## 4. Readiness Gate Summary

| Gate Area | Required | Status | Owner | Evidence |
|---|---|---|---|---|
| Store environment | Yes |  |  |  |
| POS readiness | Yes |  |  |  |
| KDS/kitchen readiness | Yes |  |  |  |
| Payment/order separation | Yes |  |  |  |
| Staff training | Yes |  |  |  |
| Manual fallback | Yes |  |  |  |
| Daily reconciliation | Yes |  |  |  |
| Support escalation | Yes |  |  |  |
| Customer-facing wording | Yes |  |  |  |
| Evidence/audit capture | Yes |  |  |  |
| Rollback/disable procedure | Yes |  |  |  |

## 5. Store Environment Gate

| Check | Required | Status | Notes |
|---|---|---|---|
| store_id assigned | Yes |  |  |
| store operating hours confirmed | Yes |  |  |
| service modes confirmed | Yes |  | dine-in / pickup / wait-order / table-order |
| staff roster confirmed | Yes |  |  |
| shift lead assigned | Yes |  |  |
| manager close owner assigned | Yes |  |  |
| support contact posted | Yes |  |  |
| network condition tested | Yes |  |  |
| staff device/tablet available | Yes |  |  |
| fallback materials ready | Yes |  | manual note paper, printer paper, pens |

## 6. POS Gate

| Check | Required | Status | Notes |
|---|---|---|---|
| POS provider identified | Yes |  |  |
| POS model/version recorded | Yes |  |  |
| POS order/receipt reference format known | Yes |  |  |
| manual order entry tested | Yes |  |  |
| duplicate prevention tested | Yes |  |  |
| cancellation flow tested | Yes |  |  |
| refund handoff understood | Yes |  |  |
| POS outage fallback known | Yes |  |  |
| provider verification status recorded | Yes |  |  |
| no unsupported local DB dependency | Yes |  |  |

## 7. KDS / Kitchen Gate

| Check | Required | Status | Notes |
|---|---|---|---|
| KDS availability checked | Yes |  |  |
| printer availability checked | Yes |  |  |
| manual kitchen note format trained | Yes |  |  |
| kitchen receiver acknowledgement trained | Yes |  |  |
| delay handling trained | Yes |  |  |
| correction/remake handling trained | Yes |  |  |
| cancellation after kitchen handoff trained | Yes |  |  |
| kitchen handoff evidence captured | Yes |  |  |

## 8. Payment / Order Separation Gate

| Check | Required | Status | Notes |
|---|---|---|---|
| staff understands order intent vs payment state | Yes |  |  |
| payment completion not inferred from order | Yes |  |  |
| payment evidence source identified | Yes |  |  |
| refund evidence rule trained | Yes |  |  |
| cancellation state rule trained | Yes |  |  |
| settlement not inferred from payment | Yes |  |  |
| customer wording for payment unknown approved | Yes |  |  |
| payment/order mismatch escalation assigned | Yes |  |  |

## 9. Staff Training Gate

| Training Area | Required | Passed | Notes |
|---|---|---|---|
| manual POS entry | Yes |  |  |
| duplicate prevention | Yes |  |  |
| manual kitchen note | Yes |  |  |
| KDS/printer fallback | Yes |  |  |
| sold-out handling | Yes |  |  |
| correction handling | Yes |  |  |
| cancellation/refund evidence | Yes |  |  |
| customer-safe wording | Yes |  |  |
| daily reconciliation support | Yes |  |  |
| escalation procedure | Yes |  |  |

## 10. Manual Fallback Gate

| Scenario | Required | Tested | Pass/Fail |
|---|---|---|---|
| POS API unavailable | Yes |  |  |
| POS manually entered | Yes |  |  |
| KDS unavailable | Yes |  |  |
| printer unavailable | Yes |  |  |
| item sold out | Yes |  |  |
| customer changes order | Yes |  |  |
| duplicate order suspected | Yes |  |  |
| payment status unknown | Yes |  |  |
| cancellation after POS entry | Yes |  |  |
| cancellation after kitchen handoff | Yes |  |  |
| refund requested | Yes |  |  |
| daily mismatch found | Yes |  |  |

## 11. Evidence / Audit Gate

| Evidence | Required | Status | Notes |
|---|---|---|---|
| order id retained | Yes |  |  |
| POS reference captured when available | Yes |  |  |
| staff confirmation retained | Yes |  |  |
| kitchen handoff method retained | Yes |  |  |
| payment evidence retained | Yes |  |  |
| cancellation/refund evidence retained | Yes |  |  |
| manual correction reason retained | Yes |  |  |
| daily reconciliation retained | Yes |  |  |
| manager close decision retained | Yes |  |  |

## 12. Daily Close Gate

| Check | Required | Status |
|---|---|---|
| reconciliation owner assigned | Yes |  |
| reconciliation template ready | Yes |  |
| POS record source known | Yes |  |
| payment record source known | Yes |  |
| kitchen handoff source known | Yes |  |
| manual correction log ready | Yes |  |
| mismatch escalation rule known | Yes |  |
| manager review required | Yes |  |

## 13. Support / Escalation Gate

| Check | Required | Status |
|---|---|---|
| support owner assigned | Yes |  |
| store escalation contact assigned | Yes |  |
| payment mismatch escalation assigned | Yes |  |
| customer complaint escalation assigned | Yes |  |
| provider issue escalation assigned | If provider involved |  |
| AI/customer center answer map draft ready | Recommended |  |
| unsafe wording prohibited | Yes |  |

## 14. Activation Scope Decision

| Scope | Allowed | Notes |
|---|---|---|
| Internal dry run only |  |  |
| Staff-only manual order simulation |  |  |
| Controlled customer-facing activation |  |  |
| Wait-order only |  |  |
| Table-order only |  |  |
| Order intent only |  |  |
| POS manual entry enabled |  |  |
| KDS manual handoff enabled |  |  |
| Payment observation disabled | Default |  |
| Provider adapter disabled | Default unless approved |  |

## 15. Hard Stop Conditions

Do not activate if:

- staff cannot prevent duplicate POS entry
- POS manual entry is not tested
- kitchen handoff fallback is unclear
- payment/order separation is not understood
- refund/cancel evidence rule is unclear
- no daily reconciliation owner exists
- no shift lead escalation exists
- customer wording is unsafe
- support owner is not assigned
- manager does not approve manual fallback baseline

## 16. Gate Decision

| Field | Value |
|---|---|
| readiness_decision | Not Ready / Ready With Conditions / Ready For Dry Run / Ready For Controlled Activation / Ready |
| approved_scope |  |
| restricted_scope |  |
| required_conditions |  |
| decision_owner |  |
| decision_date |  |
| next_review_date |  |

## 17. Required Follow-Up

| Follow-Up ID | Gap | Owner | Due | Status |
|---|---|---|---|---|
| FU-001 |  |  |  | Open |

## 18. Non-Goals

This checklist does not approve:

- provider API integration
- payment execution
- franchise rollout
- automated KDS integration
- final production scaling

It only gates first-store Catch & Order activation readiness.

## 19. Related Documents

- 14340_Index_First_Store_Manual_Fallback_Readiness_Closeout_And_Handoff.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
- 14320_Checklist_First_Store_POS_KDS_Staff_Training_And_Fallback_Readiness.md
- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md
- 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md
- 14280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md
