# 014490_WorkPackage_First_Store_Next_Scope_Expansion_And_Automation_Backlog.md

## 1. Purpose

This work package defines how Catch & Order decides the first-store next operating scope and converts stable repeated manual burdens into automation backlog candidates.

It starts after first-month operational stabilization closeout.

The purpose is to prevent premature automation while still capturing automation opportunities proven by actual store operation.

## 2. Core Principle

Do not automate confusion.

Only automate a manual process when:

- the manual process is stable,
- the root cause is understood,
- the evidence shows repeated burden,
- staff can still fall back manually,
- customer/payment safety is not weakened,
- owner approves the next scope.

## 3. Scope

This work package covers:

- next-scope expansion candidates
- automation candidate intake
- safety gate for automation
- operating scope expansion gate
- provider dependency separation
- support/AI customer center handoff
- implementation backlog handoff

This work package does not define implementation code.

## 4. Next Scope Types

| Scope Type | Meaning |
|---|---|
| SERVICE_MODE_EXPANSION | add wait-order, table-order, pickup, or other mode |
| CUSTOMER_SCOPE_EXPANSION | expose to more customers or time windows |
| STAFF_SCOPE_EXPANSION | train more shifts/roles |
| STORE_SCOPE_EXPANSION | prepare another store or test environment |
| AUTOMATION_SCOPE | automate stable manual burden |
| PROVIDER_SCOPE | prepare provider evidence packet or adapter gate |
| SUPPORT_SCOPE | expand support/AI customer center answer map |
| PAYMENT_SCOPE | improve payment/refund/cancel evidence handling |
| MENU_SCOPE | improve sold-out/menu availability handling |

## 5. Expansion Candidate Register

| Candidate ID | Scope Type | Description | Evidence Source | Risk | Owner | Status |
|---|---|---|---|---:|---|---|
| EXP-001 |  |  |  |  |  | Open |

## 6. Automation Candidate Register

| Candidate ID | Manual Burden | Frequency | Risk Reduced | Required Evidence | Fallback Exists | Status |
|---|---|---:|---|---|---|---|
| AUTO-001 | duplicate check assist |  | duplicate POS entry risk | recurring duplicate-risk evidence | Yes | Candidate |
| AUTO-002 | POS entry confirmation capture |  | missing POS reference | POS confirmation gaps | Yes | Candidate |
| AUTO-003 | kitchen note generation |  | kitchen handoff miss | manual kitchen note frequency | Yes | Candidate |
| AUTO-004 | sold-out substitution workflow |  | staff/customer confusion | sold-out issue pattern | Yes | Candidate |
| AUTO-005 | payment evidence prompt |  | payment/order mismatch | payment unknown cases | Yes | Candidate |
| AUTO-006 | daily reconciliation summary |  | daily close burden | reconciliation time/gap data | Yes | Candidate |
| AUTO-007 | support answer suggestion |  | unsafe wording | repeated support questions | Yes | Candidate |
| AUTO-008 | correction categorization |  | hidden correction patterns | correction logs | Yes | Candidate |
| AUTO-009 | provider evidence packet generation |  | provider verification delay | official response and evidence refs | Yes | Candidate |

## 7. Automation Safety Gate

An automation candidate may move to implementation planning only if:

| Check | Required |
|---|---|
| Manual process is documented | Yes |
| Manual fallback remains possible | Yes |
| Root cause is known | Yes |
| Evidence shows repetition | Yes |
| Automation reduces risk or burden | Yes |
| Customer-facing wording remains safe | Yes |
| Payment/order separation is preserved | Yes |
| Staff can override or escalate | Yes |
| Audit/evidence trail remains | Yes |
| Product owner approves | Yes |

## 8. Automation Block Conditions

Do not automate if:

- payment state is ambiguous,
- cancellation/refund evidence is unclear,
- staff still disagrees on correct process,
- SOP is missing,
- support wording is unsafe,
- root cause is unknown,
- provider dependency is unresolved,
- manual fallback would disappear,
- automation would hide mismatch rather than expose it.

## 9. Next Scope Expansion Gate

Next operating scope may expand only when:

1. first-month closeout is approved,
2. no open R0/R1 recurring issue remains,
3. daily reconciliation is reliable,
4. support wording is approved,
5. staff training gaps are closed or controlled,
6. SOP updates are complete or scheduled,
7. rollback path exists,
8. owner approves scope.

## 10. Provider Dependency Separation

If a candidate depends on provider capability, classify it separately.

| Candidate | Provider Dependency |
|---|---|
| automated POS order handoff | official POS order API |
| payment status observation | payment/VAN/PG event and security review |
| refund/cancel sync | official cancel/refund event |
| KDS automation | official KDS/printer path |
| settlement reconciliation | provider/payment settlement reference data |

Provider-dependent items must return to provider readiness, evidence packet, blocker register, and decision gate.

## 11. Support / AI Customer Center Handoff

Support automation may proceed only when:

- approved answer map exists,
- unknown-question capture exists,
- escalation rules exist,
- AI does not invent operational promises,
- repeated question patterns are logged,
- answer updates have owner approval.

## 12. Backlog Handoff Types

| Handoff Type | Destination |
|---|---|
| SOP_UPDATE | operating SOP backlog |
| TRAINING_UPDATE | staff training backlog |
| SUPPORT_UPDATE | support/AI customer center answer map |
| PRODUCT_UI | staff/customer UI backlog |
| PROVIDER_FOLLOW_UP | provider verification backlog |
| PAYMENT_REVIEW | payment/security/finance review |
| AUTOMATION_IMPLEMENTATION | implementation backlog after safety gate |
| SCOPE_EXPANSION | next operating scope decision |

## 13. Required Outputs

This work package should produce:

- next scope expansion candidate register
- automation candidate register
- automation safety gate assessment
- provider dependency split
- support/AI handoff list
- implementation backlog candidates
- next-scope readiness decision

## 14. Recommended Next Documents

| No. | Document |
|---:|---|
| 14500_Register_First_Store_Automation_Candidate_Backlog_And_Safety_Gate.md |
| 14510_Report_First_Store_Next_Scope_Expansion_Readiness_Decision.md |
| 14520_Index_First_Store_Next_Scope_Expansion_And_Automation_Handoff.md |

## 15. Non-Goals

This work package does not define:

- automation implementation code,
- provider adapter code,
- payment gateway execution,
- franchise rollout,
- final accounting close.

It defines controlled next-scope and automation backlog intake.

## 16. Related Documents

- 14480_Index_First_Store_Operational_Stabilization_Closeout_And_Handoff.md
- 14470_Report_First_Store_First_Month_Closeout_And_System_Hardening_Decision.md
- 14460_Register_First_Store_Recurring_Issue_Root_Cause_And_Control_Action.md
- 14380_Template_First_Store_Support_Answer_Map_For_Manual_Fallback.md
- 14370_Runbook_First_Store_Order_Payment_Kitchen_Mismatch_Escalation.md
- 14140_Governance_POS_Provider_Integration_Decision_Gate.md
