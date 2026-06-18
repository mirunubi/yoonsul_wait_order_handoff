# 014137_Policy_POS_Gateway_Reconciliation_Case_Workflow_Variance_Resolution_Manual_Adjustment_And_Audit_Closure

## 1. Purpose

This document defines the reconciliation case workflow, variance resolution, manual adjustment, and audit closure policy for the POS Gateway.

The POS Gateway must not treat reconciliation as a background report that runs after transactions are completed.  
Reconciliation is the control layer that proves whether the gateway, POS, payment provider, KDS, receipt, cancellation, refund, settlement, and accounting records describe the same business reality.

If reconciliation is weak, the store may not discover:

- missing POS orders;
- duplicate payments;
- unlinked refunds;
- cancellation mismatches;
- receipt identity gaps;
- settlement variance;
- wrong channel classification;
- manual fallback leakage;
- provider-side discrepancies;
- accounting export errors.

This policy exists to ensure that:

- reconciliation variances create controlled cases;
- each variance is classified and owned;
- manual adjustments preserve original evidence;
- unresolved variance blocks closeout where necessary;
- audit closure requires evidence, not convenience;
- customer, store, provider, and accounting impacts are reviewed before reconciliation is closed.

---

## 2. Scope

This policy applies to all POS Gateway reconciliation case workflows, including:

- gateway vs POS order comparison;
- gateway vs payment provider comparison;
- gateway vs receipt record comparison;
- gateway vs KDS ticket comparison;
- gateway vs cancellation/refund comparison;
- gateway vs settlement report comparison;
- gateway vs store closing report comparison;
- gateway vs manual fallback record comparison;
- gateway vs external delivery/order provider comparison;
- gateway vs accounting export comparison;
- provider migration reconciliation;
- post-cutover reconciliation;
- post-rollback reconciliation;
- incident-related reconciliation;
- customer dispute reconciliation.

This document governs the case workflow after a variance, mismatch, or unresolved state is detected.

---

## 3. Core Principle

A reconciliation variance must never be hidden by editing data to match.

The correct reconciliation process is:

```text
detect variance
classify variance
preserve source evidence
identify affected transactions
assign owner
investigate source systems
apply controlled adjustment if needed
verify customer and financial impact
close with evidence
```

A clean report produced by deleting or overwriting evidence is not reconciliation.  
It is evidence corruption.

---

## 4. Reconciliation Case Model

Every material reconciliation variance must create a reconciliation case.

Required fields:

```text
reconciliation_case_id
tenant_id
store_id
provider_code
business_date
case_type
variance_type
severity
source_system_a
source_system_b
affected_transaction_count
affected_amount
customer_impact_flag
financial_impact_flag
settlement_impact_flag
accounting_impact_flag
incident_id
cutover_epoch_id
rollback_id
assigned_owner
status
created_at
closed_at
```

A reconciliation case must be linked to all relevant transactions and evidence records.

---

## 5. Reconciliation Case Types

Recommended case types:

| Case Type | Meaning |
|---|---|
| `order_count_variance` | Order count differs across systems |
| `payment_count_variance` | Payment count differs across systems |
| `amount_variance` | Total amount differs |
| `receipt_variance` | Receipt or bill identity mismatch |
| `cancel_variance` | Cancellation state differs |
| `refund_variance` | Refund state differs |
| `settlement_variance` | Settlement batch or amount differs |
| `kds_variance` | KDS ticket state differs |
| `manual_fallback_variance` | Manual action not aligned with gateway/POS/payment state |
| `channel_variance` | Order channel classification mismatch |
| `table_session_variance` | Table/session identity mismatch |
| `price_calculation_variance` | Calculation snapshot differs from POS/payment/receipt |
| `provider_reference_variance` | Provider identifier missing or inconsistent |
| `migration_variance` | Historical import/backfill mismatch |
| `unknown_variance` | Variance detected but not yet classified |

Unknown variance must be investigated and reclassified.

---

## 6. Variance Severity Model

Reconciliation variance severity must reflect financial and customer impact.

Recommended severities:

| Severity | Meaning |
|---|---|
| `V0_observation` | Small non-financial difference or informational issue |
| `V1_minor` | Low-risk discrepancy with no customer or settlement impact |
| `V2_operational` | Staff/process correction required |
| `V3_financial_review` | Amount/payment/refund/settlement review required |
| `V4_customer_impact` | Customer may be charged, refunded, or informed incorrectly |
| `V5_audit_blocker` | Cannot close accounting/audit/export without resolution |

Severity must not be reduced until evidence confirms the lower risk.

---

## 7. Reconciliation Case Status Model

Recommended statuses:

```text
open
triage_in_progress
evidence_collection_in_progress
source_lookup_required
provider_escalation_required
manual_review_required
adjustment_pending
adjustment_applied
customer_action_required
reconciliation_rerun_required
resolved
closed
closed_with_known_variance
blocked
reopened
```

A case must not move to `closed` without closure evidence.

`closed_with_known_variance` requires approval and reason.

---

## 8. Variance Detection Sources

Variance may be detected by:

- scheduled reconciliation job;
- post-cutover reconciliation;
- post-rollback reconciliation;
- incident investigation;
- customer dispute;
- store closing review;
- settlement report comparison;
- manual fallback review;
- provider escalation response;
- accounting export validation;
- dashboard monitoring;
- audit review.

Variance detection source must be recorded.

---

## 9. Evidence Collection Requirements

Each reconciliation case must collect evidence from relevant systems.

Evidence may include:

- gateway order record;
- POS order record;
- payment provider record;
- approval number;
- receipt number;
- cancellation reference;
- refund reference;
- KDS ticket;
- settlement batch;
- closing report;
- manual fallback record;
- staff action record;
- customer communication record;
- provider escalation packet;
- calculation snapshot;
- menu mapping version;
- routing decision record;
- table/session record;
- audit event chain.

Evidence must remain immutable after collection.

---

## 10. Transaction Matching Policy

Reconciliation must match transactions using layered keys.

### 10.1 Strong Matching Keys

- gateway transaction ID;
- POS order ID;
- receipt number;
- payment approval number;
- provider transaction ID;
- refund/cancellation reference;
- external order ID;
- settlement batch ID.

### 10.2 Medium Matching Keys

- store;
- business date;
- amount;
- payment method;
- timestamp window;
- terminal ID;
- table/session ID;
- order channel.

### 10.3 Weak Matching Signals

- item list similarity;
- staff actor;
- customer reference;
- pickup number;
- KDS ticket timing;
- manual fallback note.

Weak signals must not automatically close financial variance.

---

## 11. Amount Variance Classification

Amount variance must be classified.

Recommended amount variance classes:

| Class | Description |
|---|---|
| `rounding_variance` | Difference caused by approved rounding rule |
| `tax_variance` | Tax calculation differs |
| `discount_variance` | Discount/coupon/membership benefit differs |
| `service_charge_variance` | Fee or service charge differs |
| `modifier_price_variance` | Modifier price differs |
| `manual_adjustment_variance` | Staff adjustment caused difference |
| `partial_refund_variance` | Refund allocation differs |
| `settlement_fee_variance` | Provider fee or settlement deduction differs |
| `unexplained_amount_variance` | Difference not yet explained |

Unexplained amount variance must not be closed as harmless.

---

## 12. Order Count Variance Handling

Order count variance may indicate:

- POS order not created;
- gateway order not recorded;
- duplicate POS order;
- manual POS entry not linked;
- external provider order missing;
- cancelled order counted differently;
- test/probe order not classified;
- provider import/backfill mismatch.

Required handling:

- identify missing or extra records;
- classify each affected transaction;
- verify customer/payment impact;
- link manual fallback where applicable;
- create incident if duplicate or missing financial action is possible.

---

## 13. Payment Variance Handling

Payment variance is high risk.

Payment variance may include:

- payment success without POS order;
- POS order without payment success;
- duplicate payment;
- missing approval reference;
- payment method mismatch;
- split payment mismatch;
- external payment owner mismatch;
- payment amount mismatch.

Required handling:

- verify payment provider state;
- block repayment request until duplicate risk cleared;
- classify customer impact;
- review receipt/proof evidence;
- create incident for duplicate/missing payment risk;
- reconcile settlement impact.

Payment variance may not be closed without payment evidence.

---

## 14. Cancellation and Refund Variance Handling

Cancellation/refund variance must be handled conservatively.

Variance may include:

- gateway says cancellation requested but provider has no cancellation;
- provider cancelled but gateway not updated;
- refund requested but not completed;
- duplicate refund suspected;
- partial refund amount mismatch;
- coupon/membership restoration mismatch;
- settlement refund timing mismatch.

Required handling:

- verify original transaction;
- verify provider state;
- verify amount;
- verify prior cancellation/refund history;
- prevent duplicate retry;
- create manual review if uncertain;
- communicate customer status conservatively.

Refund variance must not be closed without refund evidence or formal unresolved owner.

---

## 15. Receipt Variance Handling

Receipt variance may include:

- missing receipt number;
- wrong receipt number;
- receipt linked to wrong order;
- cancellation receipt missing;
- refund receipt missing;
- gateway confirmation mistaken for receipt;
- external platform receipt mismatch.

Required handling:

- verify POS/provider receipt source;
- preserve customer proof;
- link receipt to order/payment;
- classify dispute risk;
- restrict receipt-based closure if proof is missing.

Receipt variance affects customer dispute and audit evidence.

---

## 16. KDS Variance Handling

KDS variance may include:

- order not sent to kitchen;
- duplicate kitchen ticket;
- wrong table/channel on ticket;
- cancellation not reflected;
- remake not recorded;
- ticket completed but POS/gateway state differs.

Required handling:

- confirm kitchen preparation state;
- identify duplicate cook or missed cook risk;
- link staff manual action;
- classify customer impact;
- link inventory/waste impact where relevant.

KDS variance may not always affect payment, but it affects store operation and customer experience.

---

## 17. Manual Fallback Reconciliation

Manual fallback actions must be reconciled.

Manual fallback reconciliation must check:

- manual POS entry linked to gateway order;
- manual payment check linked to payment provider evidence;
- manual receipt check linked to receipt evidence;
- manual refund/cancel action linked to provider evidence;
- manual table/session correction linked to original identity evidence;
- manual price adjustment linked to calculation snapshot and approval.

Manual fallback records must not be omitted from financial reconciliation.

---

## 18. Provider Escalation During Reconciliation

Provider escalation is required when internal evidence cannot resolve variance.

Provider escalation should include:

- safe transaction reference;
- provider code;
- store/provider account reference;
- timestamp;
- request/response evidence summary;
- amount involved;
- expected state;
- observed state;
- requested provider confirmation.

Provider response must be attached to reconciliation case.

If provider does not respond within required window, case must remain open, restricted, or closed with known variance only by approval.

---

## 19. Manual Adjustment Policy

Manual adjustment may be required after reconciliation.

Allowed manual adjustments:

- attach missing provider reference with evidence;
- add manual POS entry link;
- add manual settlement annotation;
- create accounting adjustment record;
- create customer protection adjustment;
- create coupon/point restoration record;
- create refund correction request;
- mark transaction as unresolved with owner.

Prohibited manual adjustments:

- overwriting original transaction amount;
- deleting duplicate record to hide variance;
- changing original payment state without provider evidence;
- marking refund complete without proof;
- modifying calculation snapshot after payment;
- removing audit events;
- closing variance by narrative only.

Manual adjustment must be additive.

---

## 20. Adjustment Record Requirements

Each manual adjustment must create an adjustment record.

Required fields:

```text
adjustment_id
reconciliation_case_id
tenant_id
store_id
transaction_id
adjustment_type
original_value
adjusted_value
reason
evidence_reference
actor_id
approver_id
created_at
status
```

Adjustment records must be linked to accounting and audit where applicable.

---

## 21. Accounting Export Impact

Reconciliation cases may affect accounting export.

Accounting export must be blocked or flagged when:

- unresolved payment variance exists;
- unresolved refund variance exists;
- unresolved settlement variance exists;
- tax amount variance exists;
- receipt identity missing;
- manual adjustment not approved;
- provider ownership unclear;
- duplicate transaction risk exists.

Accounting export may proceed with restrictions only when variance is classified and approved.

---

## 22. Settlement Closure Policy

Settlement closure requires reconciliation evidence.

Required settlement closure checks:

- gross sales matched or variance classified;
- refund total matched or variance classified;
- cancellation total matched or variance classified;
- payment method split matched;
- provider fee treatment understood where available;
- settlement batch linked;
- unresolved variance assigned owner;
- accounting impact classified.

Settlement closure must not be based solely on POS closing report when gateway/payment evidence conflicts.

---

## 23. Customer Impact Review

Before closing a reconciliation case, customer impact must be reviewed.

Customer impact exists when:

- customer may have been charged incorrectly;
- refund may be missing or duplicated;
- receipt/proof may be wrong;
- order status message may have been wrong;
- cancellation may not have been completed;
- customer dispute is open;
- customer was asked to repay during uncertainty;
- amount charged differs from displayed total.

Customer-impacting reconciliation cases must link to customer communication or dispute record.

---

## 24. Audit Closure Requirements

Audit closure requires evidence.

A reconciliation case may be audit-closed only when:

- variance type is classified;
- affected transactions are linked;
- evidence has been collected;
- financial impact is resolved or approved as known variance;
- customer impact is resolved or assigned;
- manual adjustments are audited;
- provider escalation is closed or tracked;
- accounting/export impact is classified;
- approver is recorded.

Audit closure must create a closure record.

---

## 25. Closure Decision Types

Recommended closure decisions:

| Decision | Meaning |
|---|---|
| `resolved_matched` | Records now match or were matched with evidence |
| `resolved_adjusted` | Controlled adjustment resolved variance |
| `resolved_provider_confirmed` | Provider confirmation resolved variance |
| `resolved_manual_fallback_linked` | Manual fallback explains variance |
| `closed_known_rounding` | Approved rounding variance |
| `closed_known_provider_limitation` | Provider limitation explains variance |
| `closed_with_restriction` | Closed but future operation restricted |
| `blocked_unresolved` | Cannot close due to missing evidence |
| `escalated_to_incident` | Reconciliation case became incident |
| `reopened` | Prior closure invalidated by new evidence |

Closure decision must be explicit.

---

## 26. Closure Record

Required closure record fields:

```text
closure_id
reconciliation_case_id
closure_decision
closure_reason
financial_impact_summary
customer_impact_summary
accounting_impact_summary
evidence_reference_list
adjustment_reference_list
provider_escalation_reference
incident_reference
approved_by
closed_at
reopen_condition
```

Closure records must be immutable after approval.

Corrections require reopening or linked amendment.

---

## 27. Reopening Policy

A reconciliation case must be reopened when:

- new provider evidence contradicts closure;
- customer dispute is opened after closure;
- settlement report changes;
- accounting review finds mismatch;
- manual adjustment was incorrect;
- duplicate transaction discovered;
- refund/cancellation state changes;
- audit review rejects evidence.

Reopening must preserve original closure record and create a reopened status timeline.

---

## 28. Recurring Variance Pattern

Recurring variance patterns must trigger broader review.

Pattern triggers:

- same provider error repeated;
- same store repeated;
- same menu/price mismatch repeated;
- same refund variance repeated;
- same manual fallback cause repeated;
- same receipt identity issue repeated;
- same settlement variance repeated;
- same channel mismatch repeated.

Recurring patterns may require:

- provider reassessment;
- rollout freeze;
- readiness reassessment;
- adapter fix;
- mapping correction;
- staff training;
- runbook update;
- monitoring rule update.

---

## 29. Dashboard Requirements

Operations dashboard must show:

- open reconciliation cases;
- case severity;
- affected amount;
- affected transaction count;
- customer impact flag;
- settlement impact flag;
- accounting export block flag;
- assigned owner;
- provider escalation status;
- manual adjustment status;
- closure decision;
- overdue cases;
- recurring variance patterns.

Dashboard must not hide unresolved variance behind successful order count.

---

## 30. Monitoring Requirements

Reconciliation workflow must be monitored.

Required metrics:

- reconciliation case count;
- open case count;
- high severity case count;
- average time to triage;
- average time to close;
- provider escalation count;
- manual adjustment count;
- reopened case count;
- accounting export blocked count;
- customer-impact reconciliation count;
- recurring variance count.

High-severity unresolved cases must alert owners.

---

## 31. Prohibited Practices

The following practices are prohibited:

- deleting records to make reconciliation pass;
- overwriting original amount to match settlement;
- closing payment variance without payment evidence;
- closing refund variance without refund evidence;
- ignoring manual fallback in reconciliation;
- treating weak match as financial proof;
- exporting accounting data while critical variance is unresolved;
- closing customer-impact variance without customer impact review;
- hiding provider limitation as resolved;
- changing closure decision without reopening record.

---

## 32. Minimum Acceptance Criteria

Reconciliation case workflow is acceptable only when:

- reconciliation case model exists;
- variance types are defined;
- severity model exists;
- case status model exists;
- evidence collection is mandatory;
- transaction matching policy exists;
- amount/order/payment/cancel/refund/receipt/KDS variance handling exists;
- manual fallback reconciliation exists;
- provider escalation is supported;
- manual adjustment is additive and audited;
- accounting and settlement closure policies exist;
- customer impact review exists;
- audit closure requirements exist;
- closure and reopening policies exist;
- dashboard and monitoring visibility exist.

---

## 33. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_reconciliation_cases
pos_gateway_reconciliation_case_transactions
pos_gateway_reconciliation_evidence
pos_gateway_variance_classifications
pos_gateway_transaction_match_results
pos_gateway_reconciliation_adjustments
pos_gateway_reconciliation_closures
pos_gateway_reconciliation_reopenings
pos_gateway_settlement_closure_reviews
pos_gateway_accounting_export_blocks
pos_gateway_recurring_variance_patterns
```

Recommended services:

```text
ReconciliationCaseService
VarianceClassificationService
TransactionMatchingService
EvidenceCollectionService
AmountVarianceService
PaymentVarianceService
CancelRefundVarianceService
ReceiptVarianceService
KdsVarianceService
ManualFallbackReconciliationService
ProviderEscalationLinkService
ManualAdjustmentService
SettlementClosureService
AccountingExportGuard
CustomerImpactReviewService
AuditClosureService
ReconciliationReopenService
RecurringVariancePatternService
```

Recommended event types:

```text
pos_gateway.reconciliation.case_created
pos_gateway.reconciliation.variance_classified
pos_gateway.reconciliation.evidence_collected
pos_gateway.reconciliation.transaction_matched
pos_gateway.reconciliation.provider_escalation_required
pos_gateway.reconciliation.manual_adjustment_requested
pos_gateway.reconciliation.manual_adjustment_applied
pos_gateway.reconciliation.customer_impact_detected
pos_gateway.reconciliation.accounting_export_blocked
pos_gateway.reconciliation.closure_requested
pos_gateway.reconciliation.closed
pos_gateway.reconciliation.reopened
pos_gateway.reconciliation.recurring_pattern_detected
```

---

## 34. Relationship To Adjacent Documents

This document is related to:

- 06110 POS Gateway customer status message, receipt proof, notification, and dispute communication policy;
- 06100 POS Gateway staff operation, manual fallback, override authority, and manager approval policy;
- 06080 POS Gateway order channel separation, dine-in, takeout, delivery, kiosk, table QR, and staff order routing policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy;
- POS Gateway settlement, reconciliation, closing report, and accounting linkage implementation policy;
- POS Gateway incident response, dispute investigation, provider escalation, and postmortem policy;
- POS Gateway audit event, evidence retention, and forensic traceability policy;
- POS Gateway cancellation, refund, exception, manual override, and customer protection policy.

Where conflict exists, this document governs reconciliation case workflow, variance resolution, manual adjustment, and audit closure behavior.

---

## 35. Summary

Reconciliation is not bookkeeping after the fact.

It is the process that proves whether the POS Gateway, POS provider, payment provider, receipt, KDS, settlement, and manual staff actions describe the same transaction reality.

The correct standard is:

- detect variance;
- preserve evidence;
- classify impact;
- investigate by source;
- adjust only additively;
- review customer and accounting impact;
- close with evidence;
- reopen when new truth appears.

A reconciliation process that makes numbers match by editing history is dangerous.  
A reconciliation process that preserves truth is operationally and legally defensible.