# 014580_WorkPackage_Digital_SOP_Candidate_Generation_Approval_And_Publication_Control.md

## 1. Purpose

This work package defines the control process for generating, reviewing, approving, publishing, versioning, retiring, and auditing digital SOP candidates.

It starts after AI customer center unknown-question governance has produced answer-map candidates or SOP candidates.

The purpose is to ensure that AI-assisted SOP generation becomes controlled operational documentation, not uncontrolled auto-publication.

## 2. Core Principle

AI may draft SOP candidates.

AI must not approve, publish, replace, retire, or enforce SOP without human approval and audit trail.

The operational source of truth remains approved digital SOP.

## 3. Scope

This work package covers:

- SOP candidate intake
- source evidence requirements
- AI-assisted draft generation boundary
- human review and approval
- publication control
- versioning and retirement
- rollback and correction
- audit trail
- cross-linking to unknown questions, answer maps, and operating evidence

This work package does not define AI model vendor, vector database, chatbot deployment, or implementation code.

## 4. SOP Candidate Sources

| Source | Example |
|---|---|
| unknown customer question | repeated customer asks about refund/payment state |
| staff operation question | staff repeatedly asks how to handle duplicate order |
| support answer-map gap | approved answer requires missing procedure |
| recurring issue register | repeated POS/kitchen/payment mismatch |
| daily issue queue | repeated training or SOP gap |
| provider blocker | provider response requires procedure update |
| payment/security review | sensitive state handling requires documented procedure |
| product/UX change | workflow change requires staff operating SOP |

## 5. Candidate Intake Register

| Candidate ID | Source | Proposed SOP Title | Risk Class | Owner | Status |
|---|---|---|---|---|---|
| DSOP-001 |  |  |  |  | Draft Candidate |

## 6. Risk Class

| Risk Class | Meaning | Required Review |
|---|---|---|
| S0 | payment/refund/cancel/customer harm risk | operations + support + payment/finance + security if needed |
| S1 | POS/KDS/order state risk | operations + product + technical if needed |
| S2 | staff operating procedure | operations + document owner |
| S3 | support wording / answer map | support + product |
| S4 | internal admin/document hygiene | document owner |

## 7. Candidate Status

| Status | Meaning |
|---|---|
| Draft Candidate | candidate created but not drafted |
| AI Drafting | AI-assisted draft being generated |
| Draft Ready | draft exists |
| Needs Evidence | source evidence insufficient |
| Needs Ops Review | operations review required |
| Needs Support Review | support/customer wording review required |
| Needs Payment Review | payment/refund/cancel review required |
| Needs Security Review | sensitive/provider/payment review required |
| Approved For Publication | ready to publish |
| Published | active SOP |
| Rejected | not valid or unsafe |
| Deferred | not current phase |
| Superseded | replaced by newer SOP |
| Retired | no longer active |

## 8. Source Evidence Requirements

Every SOP candidate must include:

| Evidence | Required |
|---|---|
| source question or issue id | Yes |
| frequency or severity | Yes |
| affected process | Yes |
| related order/payment/support case if any | If applicable |
| current answer/SOP/policy reference | If exists |
| proposed operational rule | Yes |
| risk if not documented | Yes |
| owner assignment | Yes |
| approval path | Yes |

## 9. AI Drafting Boundary

AI may generate:

- SOP title candidate
- purpose and scope draft
- step-by-step procedure draft
- escalation rule draft
- evidence checklist draft
- staff/customer wording draft
- related document links
- non-goals draft
- review checklist draft

AI must not:

- mark draft as approved,
- publish to active SOP,
- change policy by itself,
- create refund/payment promises,
- create provider integration claims,
- override human owner,
- delete or retire previous SOP,
- bypass audit trail.

## 10. Review Gate

Before publication, each SOP must pass:

| Gate | Required |
|---|---|
| title follows naming rule | Yes |
| document type is correct | Yes |
| source evidence linked | Yes |
| operational owner assigned | Yes |
| scope and non-goals clear | Yes |
| risk class reviewed | Yes |
| escalation path defined | Yes |
| payment/refund/cancel wording checked if relevant | If relevant |
| support answer map updated if customer-facing | If relevant |
| training update created if staff-facing | If relevant |
| related documents linked | Yes |
| version and publication date assigned | Yes |

## 11. Publication Control

Published SOP must include:

| Field | Required |
|---|---|
| SOP ID / filename | Yes |
| version | Yes |
| status | Active |
| owner | Yes |
| approval date | Yes |
| source evidence refs | Yes |
| related answer-map refs | If applicable |
| effective date | Yes |
| review date | Yes |
| rollback/retirement path | Yes |

## 12. Versioning Rule

| Change Type | Version Action |
|---|---|
| typo / format only | patch |
| wording clarification | patch or minor |
| procedure change | minor |
| payment/refund/cancel rule change | major |
| provider integration behavior change | major |
| risk control change | major |
| retired process | retire old SOP and publish replacement |

## 13. Retirement Rule

An SOP may be retired only when:

- replacement exists or process is no longer used,
- owner approves,
- downstream answer maps are updated,
- training references are updated,
- audit trail remains,
- old SOP is marked retired, not deleted.

## 14. Audit Trail

Maintain audit records for:

- candidate creation
- AI draft generation
- human review comments
- approval/rejection
- publication
- revision
- retirement
- linked source questions/issues
- linked answer-map changes

## 15. Required Outputs

This work package should produce:

- SOP candidate approval register
- generated draft review template
- publication/versioning governance
- digital SOP audit trail rule
- closeout and handoff index

## 16. Recommended Next Documents

| No. | Document |
|---:|---|
| 14590_Register_Digital_SOP_Candidate_Approval_Status_And_Source_Evidence.md |
| 14600_Template_Digital_SOP_Generated_Draft_Review_And_Release_Record.md |
| 14610_Governance_Digital_SOP_Publication_Versioning_Retirement_And_Audit_Trail.md |
| 14620_Index_Digital_SOP_Generation_Control_Closeout_And_Handoff.md |

## 17. Non-Goals

This work package does not define:

- AI model vendor,
- prompt implementation,
- vector database,
- chatbot deployment,
- payment gateway execution,
- provider adapter code.

It defines governance for digital SOP candidate generation and publication control.

## 18. Related Documents

- 14570_Index_AI_Customer_Center_Manual_Fallback_Knowledge_Closeout_And_Handoff.md
- 14560_Report_AI_Customer_Center_Answer_Map_Closeout_And_Digital_SOP_Handoff.md
- 14540_Register_AI_Customer_Center_Unknown_Question_And_SOP_Candidate_Queue.md
- 14550_Template_AI_Customer_Center_Approved_Answer_Map_And_Escalation_Rule.md
- 14460_Register_First_Store_Recurring_Issue_Root_Cause_And_Control_Action.md
- 08000_ai_customer_center
