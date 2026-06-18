# 014460_Register_First_Store_Recurring_Issue_Root_Cause_And_Control_Action.md

## 1. Purpose

This register tracks recurring first-store issues, root causes, control actions, owners, due dates, and closure evidence during the first-month stabilization period.

It converts repeated operational friction into controlled improvement.

The goal is to prevent the same problem from being solved repeatedly by memory, improvisation, or individual staff skill.

## 2. Core Rule

A recurring issue must not remain only in chat, staff memory, or manager notes.

If an issue repeats, it must be classified, assigned, controlled, and reviewed.

## 3. Recurring Issue Definition

An issue is recurring if any of the following is true:

- appears on 2 or more business days
- affects 3 or more orders
- appears across more than one shift
- requires repeated manager intervention
- creates repeated customer/support contact
- creates repeated daily reconciliation mismatch
- creates repeated manual correction
- reveals missing or unclear SOP
- reveals staff training gap
- reveals provider or system dependency

## 4. Recurring Issue Register

| Issue ID | Category | First Seen | Repeat Count | Severity | Root Cause Status | Control Action | Owner | Due | Status |
|---|---|---|---:|---:|---|---|---|---|---|
| RCI-001 |  |  |  |  | Not Started |  |  |  | Open |

## 5. Issue Categories

| Category | Meaning |
|---|---|
| POS_ENTRY | manual POS entry issue |
| DUPLICATE_RISK | duplicate order / duplicate POS entry risk |
| KITCHEN_HANDOFF | KDS/printer/manual kitchen note issue |
| PAYMENT_STATE | payment/order state confusion |
| CANCEL_REFUND | cancellation/refund evidence or flow issue |
| SOLD_OUT | menu availability/substitution issue |
| CUSTOMER_WORDING | customer-facing wording problem |
| STAFF_TRAINING | training or role clarity gap |
| SOP_GAP | procedure document missing/unclear |
| SUPPORT_GAP | support answer missing/unsafe |
| PROVIDER_DEPENDENCY | POS/KDS/payment provider fact needed |
| RECONCILIATION | daily close mismatch/evidence issue |
| UX_UI | staff/customer screen flow problem |
| STAFFING | shift role, workload, peak coverage issue |
| AUTOMATION_CANDIDATE | stable repeated manual burden suitable for automation |

## 6. Severity

| Severity | Meaning | Required Response |
|---|---|---|
| R0 | Customer/payment harm risk | immediate escalation and rollback/hold review |
| R1 | Critical recurring mismatch | owner, control action, no expansion |
| R2 | Repeated operational friction | control action with due date |
| R3 | Training/process improvement | training or SOP queue |
| R4 | Informational pattern | monitor |

## 7. Root Cause Status

| Status | Meaning |
|---|---|
| Not Started | no analysis yet |
| Investigating | evidence being reviewed |
| Staff Training | primarily training-related |
| SOP Gap | procedure missing/unclear |
| Support Gap | answer/wording missing |
| UX/UI Gap | screen/workflow issue |
| Provider Dependency | external provider fact needed |
| Process Design | flow design needs change |
| Staffing | role/coverage issue |
| Confirmed | root cause confirmed |
| Unknown | still unresolved |
| Closed | root cause no longer active |

## 8. Root Cause Analysis Template

| Field | Value |
|---|---|
| issue_id |  |
| issue_summary |  |
| affected_orders |  |
| affected_shift |  |
| affected_roles |  |
| first_seen |  |
| repeat_pattern |  |
| customer_impact |  |
| financial_impact |  |
| operational_impact |  |
| evidence_refs |  |
| suspected_root_cause |  |
| confirmed_root_cause |  |
| prevention_control |  |
| owner |  |
| due_date |  |

## 9. Control Action Types

| Action Type | Meaning |
|---|---|
| TRAINING_REFRESH | retrain staff/role |
| SOP_UPDATE | update SOP or policy |
| SUPPORT_ANSWER_UPDATE | update answer map |
| CHECKLIST_UPDATE | update readiness/daily checklist |
| UI_COPY_UPDATE | update wording/labels |
| UI_FLOW_UPDATE | adjust staff/customer flow |
| RECONCILIATION_RULE_UPDATE | update close/reconciliation logic |
| STAFFING_ADJUSTMENT | adjust role or shift coverage |
| PROVIDER_FOLLOW_UP | ask provider or update blocker |
| SCOPE_RESTRICTION | restrict risky flow |
| SCOPE_EXPANSION_HOLD | block expansion until fixed |
| AUTOMATION_BACKLOG | create automation candidate |
| INCIDENT_ESCALATION | escalate to incident/payment/security/support |

## 10. Control Action Register

| Control ID | Issue ID | Action Type | Description | Owner | Due | Evidence Required | Status |
|---|---|---|---|---|---|---|---|
| CTRL-001 |  |  |  |  |  |  | Open |

## 11. Control Action Status

| Status | Meaning |
|---|---|
| Open | action defined but not started |
| Assigned | owner assigned |
| In Progress | action underway |
| Waiting Training | training scheduled |
| Waiting Document Update | SOP/support/checklist update needed |
| Waiting Provider | external answer needed |
| Waiting Product | UX/UI/product decision needed |
| Waiting Review | awaiting manager/product review |
| Mitigated | temporary control exists |
| Done | action completed |
| Verified | action worked in operation |
| Deferred | not blocking current scope |
| Closed | no further action |

## 12. Closure Requirements

A recurring issue can close only when:

1. root cause is identified or explicitly accepted as unknown,
2. control action is completed or risk is accepted,
3. evidence shows the issue stopped or reduced,
4. SOP/training/support updates are completed if needed,
5. next-scope decision accounts for the issue,
6. owner signs off.

## 13. Weekly Review Table

| Week | Open R0/R1 | Open R2 | New Recurring Issues | Closed Issues | Expansion Allowed |
|---|---:|---:|---:|---:|---|
| Week 1 |  |  |  |  |  |
| Week 2 |  |  |  |  |  |
| Week 3 |  |  |  |  |  |
| Week 4 |  |  |  |  |  |

## 14. Expansion Block Rules

Do not expand scope if:

- any R0 issue is open,
- R1 issue lacks control action,
- payment/order mismatch repeats,
- duplicate risk repeats,
- daily reconciliation is not reliable,
- customer-facing wording remains unsafe,
- staff training gap repeats across shifts,
- provider dependency blocks safe flow.

## 15. Automation Candidate Rule

An issue may become automation backlog only when:

- the manual process is understood,
- root cause is not staff confusion alone,
- the issue repeats despite training/SOP clarity,
- automation would reduce risk or load,
- fallback remains possible,
- product owner approves.

Automation must not hide unresolved operational ambiguity.

## 16. Required Updates

When an issue or control action changes, update:

- 14410 daily issue/training/SOP queue
- relevant SOP/policy/checklist
- support answer map if customer-facing
- provider blocker register if provider-dependent
- first-month closeout report
- implementation backlog if automation is approved

## 17. Non-Goals

This register does not define:

- final product roadmap
- provider adapter implementation
- payment gateway execution
- full franchise training program
- accounting close

It tracks recurring first-store issues and control actions.

## 18. Related Documents

- 14450_WorkPackage_First_Store_First_Month_Stabilization_And_Operational_Learning.md
- 14470_Report_First_Store_First_Month_Closeout_And_System_Hardening_Decision.md
- 14410_Register_First_Store_Daily_Issue_Training_Gap_And_SOP_Update_Queue.md
- 14430_Report_First_Store_First_Week_Closeout_And_Next_Scope_Decision.md
- 14380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md
- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
- 14330_Template_First_Store_Daily_Reconciliation_And_Manual_Correction_Log.md
