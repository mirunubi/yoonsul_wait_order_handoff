# 014330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md

## 1. Purpose

This template defines the first-store daily reconciliation and manual correction log for Catch & Order manual POS/KDS operation.

It is used when Catch & Order operates before deep POS, KDS, payment, or provider integration is approved.

The goal is to compare Catch & Order records, POS records, payment records, kitchen handoff records, and staff correction records at day close.

## 2. Core Rule

Daily reconciliation must be completed even when the store operates manually.

Manual operation without daily reconciliation creates hidden financial, operational, and customer-support risk.

## 3. Business Day Header

| Field | Value |
|---|---|
| business_date |  |
| store_id |  |
| store_name |  |
| shift | morning / lunch / dinner / full-day |
| reconciliation_owner |  |
| shift_lead |  |
| POS_operator |  |
| kitchen_lead |  |
| reviewed_at |  |
| review_status | Open / Matched / Mismatch Open / Escalated / Closed |

## 4. Source Records

| Source | Available | Reference / Export | Owner | Notes |
|---|---|---|---|---|
| Catch & Order order list |  |  |  |  |
| POS sales/order list |  |  |  |  |
| POS receipt list |  |  |  |  |
| payment terminal/CAT/VAN/PG record |  |  |  |  |
| kitchen handoff/KDS/print/manual note |  |  |  |  |
| cancellation/refund record |  |  |  |  |
| manual correction log |  |  |  |  |
| support/customer issue log |  |  |  |  |

## 5. Daily Count Summary

| Count Item | Catch & Order | POS | Payment Source | Kitchen Source | Difference | Status |
|---|---:|---:|---:|---:|---:|---|
| total orders |  |  |  |  |  |  |
| POS-entered orders |  |  |  |  |  |  |
| kitchen handoff confirmed |  |  |  |  |  |  |
| completed/served/picked-up orders |  |  |  |  |  |  |
| cancelled orders |  |  |  |  |  |  |
| refunded orders |  |  |  |  |  |  |
| corrected orders |  |  |  |  |  |  |
| manual fallback orders |  |  |  |  |  |  |

## 6. Order-Level Reconciliation Table

| Row | Catch Order ID | POS Ref | Payment Ref | Kitchen Ref | Order State | Payment State | Match Status | Notes |
|---:|---|---|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  |  |  |

## 7. Mismatch Log

| Mismatch ID | Type | Catch Order ID | POS Ref | Payment Ref | Description | Severity | Owner | Status |
|---|---|---|---|---|---|---:|---|---|
| MM-001 |  |  |  |  |  |  |  | Open |

## 8. Mismatch Types

| Type | Meaning |
|---|---|
| ORDER_WITHOUT_POS | Catch & Order order not found in POS |
| POS_WITHOUT_ORDER | POS order not found in Catch & Order |
| PAYMENT_WITHOUT_ORDER | Payment record lacks matching order |
| ORDER_WITHOUT_PAYMENT | Order requires payment but no payment evidence |
| KITCHEN_WITHOUT_POS | Kitchen handoff occurred before POS confirmation |
| POS_WITHOUT_KITCHEN | POS entry lacks kitchen handoff evidence |
| CANCEL_MISMATCH | Cancellation states differ |
| REFUND_MISMATCH | Refund states differ |
| STAFF_CORRECTION_MISMATCH | Manual correction not reflected across sources |
| DUPLICATE_ORDER_RISK | Duplicate order or duplicate POS entry suspected |
| UNKNOWN_STATE | State cannot be determined from available evidence |

## 9. Manual Correction Log

| Correction ID | Catch Order ID | POS Ref | Correction Type | Before | After | Reason | Approved By | Staff | Time | Reconciled |
|---|---|---|---|---|---|---|---|---|---|---|
| COR-001 |  |  |  |  |  |  |  |  |  | No |

## 10. Correction Types

| Type | Meaning |
|---|---|
| ITEM_CHANGE | Menu item changed |
| OPTION_CHANGE | Option/modifier changed |
| QUANTITY_CHANGE | Quantity changed |
| SOLD_OUT_REPLACEMENT | Sold-out item replaced |
| CUSTOMER_CHANGE | Customer requested change |
| STAFF_ENTRY_ERROR | Staff entered wrong POS item |
| KITCHEN_CORRECTION | Kitchen note or KDS correction |
| PRICE_DISCOUNT_ERROR | POS price/discount/coupon correction |
| CANCEL_AFTER_POS | Cancel after POS entry |
| CANCEL_AFTER_KITCHEN | Cancel after kitchen handoff |
| REFUND_AFTER_PAYMENT | Refund after payment |
| DUPLICATE_PREVENTED | Duplicate order prevented before entry |

## 11. Cancellation / Refund Log

| Case ID | Catch Order ID | POS Ref | Payment Ref | Case Type | Requested Time | Confirmed Time | Evidence | Status |
|---|---|---|---|---|---|---|---|---|
| CR-001 |  |  |  | cancel/refund |  |  |  | Open |

## 12. Kitchen Handoff Review

| Catch Order ID | POS Ref | Handoff Method | Handoff Time | Kitchen Receiver | Fulfillment Status | Issue |
|---|---|---|---|---|---|---|
|  |  | KDS / Printer / Manual Note / Verbal |  |  |  |  |

## 13. Payment Review

| Catch Order ID | POS Ref | Payment Ref | Payment State | Evidence Source | Mismatch | Notes |
|---|---|---|---|---|---|---|
|  |  |  |  | POS / CAT / VAN / PG / Staff Evidence |  |  |

## 14. Escalation Log

| Escalation ID | Issue | Severity | Escalated To | Time | Required Action | Status |
|---|---|---:|---|---|---|---|
| ESC-001 |  |  |  |  |  | Open |

## 15. Severity Rule

| Severity | Meaning | Action |
|---|---|---|
| R0 | Customer/payment harm risk | Immediate manager/payment/support escalation |
| R1 | Financial/order mismatch | Must resolve before close |
| R2 | Operational correction | Resolve or explain in daily close |
| R3 | Training or process issue | Track for training |
| R4 | Informational | Keep evidence only |

## 16. Daily Close Decision

| Decision | Meaning |
|---|---|
| Matched | No unresolved mismatch |
| Matched With Correction | Differences corrected and evidenced |
| Closed With Accepted Difference | Manager accepted known difference |
| Mismatch Open | Unresolved issue remains |
| Escalated | Finance/support/security/owner review required |
| Reopen Required | Prior close was wrong or incomplete |

## 17. Manager Review

| Review Item | Result | Notes |
|---|---|---|
| Counts matched |  |  |
| Payment records matched |  |  |
| Cancellations/refunds reviewed |  |  |
| Kitchen handoff reviewed |  |  |
| Manual corrections reviewed |  |  |
| Duplicate risks reviewed |  |  |
| Customer/support issues reviewed |  |  |
| Training gaps identified |  |  |
| Next-day action assigned |  |  |

## 18. Next-Day Action List

| Action ID | Issue | Owner | Due | Status |
|---|---|---|---|---|
| NDA-001 |  |  |  | Open |

## 19. Required Storage

This daily reconciliation log must be stored with:

- business date
- store id
- reconciliation owner
- source record references
- final decision
- unresolved mismatch list
- manager review result

## 20. Non-Goals

This template does not define:

- automated settlement accounting
- payment gateway integration
- provider API mapping
- tax reporting
- final finance close

It only supports first-store manual operation reconciliation.

## 21. Related Documents

- 14310_Policy_First_Store_Payment_Order_Separation_And_Reconciliation.md
- 14320_Checklist_First_Store_POS_KDS_Staff_Training_And_Fallback_Readiness.md
- 14290_SOP_First_Store_Manual_POS_Entry_And_Order_Confirmation.md
- 14300_SOP_First_Store_Manual_KDS_Kitchen_Note_And_Fulfillment_Handoff.md
- 14160_Register_POS_Provider_Incident_Reconciliation_And_Mismatch_Tracking.md
- 14280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md
