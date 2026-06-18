# 014500_Register_First_Store_Automation_Candidate_Backlog_And_Safety_Gate.md

## 1. Purpose

This register tracks first-store automation candidates and applies a safety gate before any candidate can move to implementation planning.

It is used after first-month stabilization has identified repeated manual burdens, stable operating flows, and system hardening needs.

The purpose is to prevent premature automation while preserving useful automation opportunities discovered from real store operation.

## 2. Core Rule

Automation may not replace an unclear manual process.

A candidate can move forward only when the manual process is documented, tested, evidenced, reversible, and safe.

## 3. Automation Candidate Register

| Candidate ID | Candidate | Source Issue | Frequency | Risk Reduced | Burden Reduced | Owner | Status |
|---|---|---|---:|---|---|---|---|
| AUTO-001 | Duplicate check assist | duplicate order risk |  | duplicate POS entry | staff verification load |  | Candidate |
| AUTO-002 | POS entry confirmation capture | missing POS reference |  | reconciliation gap | staff note burden |  | Candidate |
| AUTO-003 | Kitchen note generation | manual kitchen note burden |  | kitchen handoff miss | ticket writing burden |  | Candidate |
| AUTO-004 | Sold-out substitution workflow | sold-out/customer change |  | wrong replacement/cancel | staff/customer clarification |  | Candidate |
| AUTO-005 | Payment evidence prompt | payment unknown cases |  | payment/order mismatch | staff evidence reminder |  | Candidate |
| AUTO-006 | Daily reconciliation summary | daily close burden |  | missed mismatch | manager close burden |  | Candidate |
| AUTO-007 | Support answer suggestion | repeated customer questions |  | unsafe wording | support/staff response load |  | Candidate |
| AUTO-008 | Correction categorization | manual correction logs |  | hidden pattern | manager review burden |  | Candidate |
| AUTO-009 | Provider evidence packet generation | provider verification docs |  | missing provider evidence | documentation burden |  | Candidate |

## 4. Candidate Status

| Status | Meaning |
|---|---|
| Candidate | Identified but not assessed |
| Assessing | Safety gate review underway |
| Needs Evidence | More operating evidence required |
| Needs SOP | Manual SOP not clear enough |
| Needs Training | Staff process not stable enough |
| Needs Support Approval | Customer/staff wording not approved |
| Needs Provider Fact | External provider dependency unresolved |
| Ready For Backlog | Can move to implementation backlog |
| Deferred | Useful but not current phase |
| Blocked | Unsafe or unclear |
| Closed | No longer needed |

## 5. Safety Gate Checklist

Each automation candidate must pass:

| Gate | Required | Result |
|---|---|---|
| Manual process documented | Yes |  |
| Manual fallback remains possible | Yes |  |
| Root cause understood | Yes |  |
| Repeated burden evidenced | Yes |  |
| Automation reduces risk or load | Yes |  |
| Audit/evidence trail remains | Yes |  |
| Staff can override/escalate | Yes |  |
| Customer-safe wording preserved | Yes |  |
| Payment/order separation preserved | If relevant |  |
| Provider dependency resolved or separated | If relevant |  |
| Product owner approval | Yes |  |
| Operations owner approval | Yes |  |
| Security/payment review | If sensitive/payment-related |  |

## 6. Candidate Detail Template

| Field | Value |
|---|---|
| candidate_id |  |
| candidate_name |  |
| source_issue_ids |  |
| manual_process_ref |  |
| evidence_refs |  |
| frequency |  |
| affected_roles |  |
| customer_impact |  |
| financial_impact |  |
| operational_impact |  |
| risk_reduced |  |
| burden_reduced |  |
| fallback_path |  |
| owner |  |
| proposed_backlog_destination |  |

## 7. Automation Risk Class

| Risk Class | Meaning | Required Review |
|---|---|---|
| A0 | payment/customer harm possible | product + ops + payment/security |
| A1 | order/POS/kitchen state changes | product + ops + technical |
| A2 | staff suggestion only | product + ops |
| A3 | report/evidence summarization | product/ops |
| A4 | internal convenience only | owner approval |

## 8. Candidate-Specific Safety Notes

### AUTO-001 Duplicate Check Assist

Allowed only if it suggests duplicate risk and does not auto-cancel or auto-merge orders without staff confirmation.

### AUTO-002 POS Entry Confirmation Capture

Allowed if staff remains responsible for confirming POS entry and POS reference.

### AUTO-003 Kitchen Note Generation

Allowed if kitchen receiver acknowledgement remains required.

### AUTO-004 Sold-Out Substitution Workflow

Allowed if customer/store confirmation rules remain explicit.

### AUTO-005 Payment Evidence Prompt

Allowed if it prompts evidence capture but does not mark payment complete without evidence.

### AUTO-006 Daily Reconciliation Summary

Allowed if it summarizes evidence but does not close mismatches automatically.

### AUTO-007 Support Answer Suggestion

Allowed only from approved answer map and escalation rules.

### AUTO-008 Correction Categorization

Allowed if staff/manager can override category.

### AUTO-009 Provider Evidence Packet Generation

Allowed if generated packet remains review-required and does not approve provider integration.

## 9. Block Conditions

Block automation if:

- it hides unresolved mismatch,
- it marks payment/cancel/refund without evidence,
- it removes staff confirmation from POS entry,
- it removes kitchen acknowledgement,
- it creates customer-facing promise without approval,
- it depends on unofficial provider access,
- it bypasses manual fallback,
- it cannot be audited,
- it cannot be disabled.

## 10. Backlog Handoff

When candidate passes safety gate, create backlog entry with:

| Field | Required |
|---|---|
| backlog_id | Yes |
| candidate_id | Yes |
| target_module | Yes |
| safety_gate_result | Yes |
| fallback_path | Yes |
| audit/evidence requirement | Yes |
| owner | Yes |
| implementation phase | Yes |
| non-goals | Yes |

## 11. Prioritization Matrix

| Priority | Condition |
|---|---|
| P0 | prevents customer/payment harm |
| P1 | reduces repeated order/POS/kitchen mismatch |
| P2 | reduces staff burden and improves evidence |
| P3 | improves support answer consistency |
| P4 | convenience or reporting only |

## 12. Required Updates

When a candidate changes status, update:

- first-month closeout report
- recurring issue register
- SOP update queue if needed
- support answer map if customer-facing
- payment/security review if payment-related
- provider blocker register if provider-dependent
- implementation backlog if approved

## 13. Non-Goals

This register does not define:

- implementation code,
- UI design,
- provider adapter details,
- payment gateway logic,
- final release plan.

It only gates automation candidates.

## 14. Related Documents

- 14490_WorkPackage_First_Store_Next_Scope_Expansion_And_Automation_Backlog.md
- 14480_Index_First_Store_Operational_Stabilization_Closeout_And_Handoff.md
- 14470_Report_First_Store_First_Month_Closeout_And_System_Hardening_Decision.md
- 14460_Register_First_Store_Recurring_Issue_Root_Cause_And_Control_Action.md
- 14380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md
- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
