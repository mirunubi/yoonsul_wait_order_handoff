# 014410_Register_First_Store_Daily_Issue_Training_Gap_And_SOP_Update_Queue.md

## 1. Purpose

This register tracks first-store daily issues, staff training gaps, SOP update candidates, and support answer-map update candidates during the first-week stabilization window.

It is used after Day-Zero activation and during the first controlled operating week.

The purpose is to ensure that early operational friction becomes structured improvement instead of informal memory.

## 2. Core Rule

Every repeated issue must become one of:

- training gap
- SOP update candidate
- support answer update candidate
- reconciliation issue
- provider dependency blocker
- product/UX issue
- staffing/process issue

Do not allow repeated friction to remain as verbal notes.

## 3. Daily Issue Register

| Issue ID | Business Date | Category | Severity | Description | Source | Owner | Status | Next Action |
|---|---|---|---:|---|---|---|---|---|
| ISS-001 |  |  |  |  |  |  | Open |  |

## 4. Issue Categories

| Category | Meaning |
|---|---|
| POS_ENTRY | manual POS entry problem |
| DUPLICATE_RISK | duplicate order or duplicate POS entry risk |
| KITCHEN_HANDOFF | KDS/printer/manual kitchen note issue |
| PAYMENT_STATE | payment/order state confusion |
| CANCEL_REFUND | cancellation or refund evidence issue |
| SOLD_OUT | menu availability, substitution, or sold-out flow issue |
| CUSTOMER_WORDING | unsafe or unclear customer-facing wording |
| STAFF_TRAINING | staff does not know procedure |
| SOP_GAP | procedure missing, unclear, or outdated |
| SUPPORT_GAP | support answer missing or unsafe |
| PROVIDER_DEPENDENCY | issue depends on POS/KDS/payment provider |
| RECONCILIATION | daily close mismatch or missing evidence |
| UX_UI | staff screen/customer screen needs improvement |
| STAFFING | staffing or role assignment issue |

## 5. Severity

| Severity | Meaning | Required Response |
|---|---|---|
| S0 | Customer/payment harm risk | Immediate escalation and possible rollback |
| S1 | Critical operating mismatch | Resolve before scope expansion |
| S2 | Repeated operational issue | Assign owner and due date |
| S3 | Training/process improvement | Track and review |
| S4 | Informational | Keep as evidence |

## 6. Status Values

| Status | Meaning |
|---|---|
| Open | Identified but not assigned/resolved |
| Assigned | Owner assigned |
| In Progress | Fix/training/update underway |
| Waiting Evidence | Need more records |
| Waiting Staff Training | Training action pending |
| Waiting SOP Update | Document update pending |
| Waiting Support Update | Support answer update pending |
| Waiting Provider | Provider fact needed |
| Mitigated | Temporary control exists |
| Resolved | Fix confirmed |
| Deferred | Not blocking current scope |
| Closed | No further action |

## 7. Training Gap Queue

| Gap ID | Business Date | Staff Role | Scenario | Gap Description | Required Training | Owner | Due | Status |
|---|---|---|---|---|---|---|---|---|
| TRG-001 |  |  |  |  |  |  |  | Open |

Training gap triggers:

- duplicate check skipped
- POS entry confirmation missed
- kitchen handoff not recorded
- payment completion assumed
- refund request treated as refund complete
- cancellation stage misunderstood
- manual correction not logged
- unsafe customer wording used
- daily reconciliation input incomplete

## 8. SOP Update Queue

| SOP Update ID | Source Issue | Affected Document | Update Needed | Priority | Owner | Due | Status |
|---|---|---|---|---:|---|---|---|
| SOPU-001 |  |  |  |  |  |  | Open |

SOP update triggers:

- repeated staff workaround
- missing cancellation/refund edge case
- unclear kitchen handoff step
- sold-out flow not covered
- payment/order state wording insufficient
- mismatch escalation unclear
- daily reconciliation field missing
- support answer not aligned with operation

## 9. Support Answer Update Queue

| Answer Update ID | Source Issue | Scenario | Current Answer Gap | Proposed Safe Wording | Owner | Status |
|---|---|---|---|---|---|---|
| ANSU-001 |  |  |  |  |  | Draft |

Support answer update triggers:

- customer asks repeated unknown question
- staff gives inconsistent answer
- customer-facing status causes confusion
- refund/cancel wording unclear
- payment state wording unsafe
- delay wording too specific without evidence
- AI customer center lacks approved answer

## 10. Provider Dependency Queue

| Dependency ID | Provider / System | Issue | Required Provider Fact | Blocks | Owner | Status |
|---|---|---|---|---|---|---|
| PDE-001 |  |  |  |  |  | Open |

Provider dependency examples:

- POS receipt reference unavailable
- POS export format unclear
- printer/KDS behavior unknown
- payment terminal reference unclear
- refund/cancel evidence format unclear
- provider support route unknown
- official API status unknown

## 11. Reconciliation Issue Queue

| Reconciliation Issue ID | Business Date | Mismatch Type | Affected Orders | Severity | Owner | Resolution |
|---|---|---|---:|---:|---|---|
| RECISS-001 |  |  |  |  |  |  |

## 12. Required Daily Review

At day close, review:

1. All daily issues.
2. All unresolved mismatches.
3. Staff training gaps.
4. SOP update candidates.
5. Support answer gaps.
6. Provider dependency blockers.
7. Next-day scope restrictions.
8. Whether activation should continue, restrict, hold, or rollback.

## 13. Weekly Pattern Review

At first-week close, summarize:

| Pattern | Count | Decision |
|---|---:|---|
| POS entry errors |  |  |
| duplicate risks |  |  |
| kitchen handoff misses |  |  |
| payment/order mismatches |  |  |
| cancel/refund mismatches |  |  |
| unsafe wording cases |  |  |
| staff training gaps |  |  |
| SOP update candidates |  |  |
| support answer gaps |  |  |
| provider dependencies |  |  |

## 14. Close Criteria

A queue item can be closed only when:

- evidence is captured,
- owner has confirmed resolution,
- training is completed if needed,
- SOP/support answer is updated if needed,
- next-day operation no longer repeats the issue,
- unresolved risk is accepted or deferred explicitly.

## 15. Non-Goals

This register does not define:

- final operating SOP
- provider implementation
- payment gateway design
- final customer support policy
- franchise-wide training program

It only tracks first-store first-week improvement queues.

## 16. Related Documents

- 14400_WorkPackage_First_Store_First_Week_Stabilization_And_Evidence_Capture.md
- 14420_Template_First_Store_Day_Zero_And_First_Week_Evidence_Packet.md
- 14430_Report_First_Store_First_Week_Closeout_And_Next_Scope_Decision.md
- 14390_Index_First_Store_Opening_Readiness_Closeout_And_Handoff.md
- 14380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md
- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
