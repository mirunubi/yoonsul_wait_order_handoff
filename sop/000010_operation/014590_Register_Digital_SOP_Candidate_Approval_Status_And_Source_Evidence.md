# 014590_Register_Digital_SOP_Candidate_Approval_Status_And_Source_Evidence.md

## 1. Purpose

This register tracks digital SOP candidates, their source evidence, risk class, approval status, owner, review path, publication status, and related answer-map or support-question references.

It is used after AI customer center unknown questions, support answer-map gaps, recurring store issues, or manual fallback events reveal missing or unclear operating procedures.

The purpose is to ensure that AI-assisted SOP generation remains evidence-backed, human-approved, versioned, and auditable.

## 2. Core Rule

No digital SOP candidate may become an active SOP unless:

- source evidence exists,
- owner is assigned,
- risk class is reviewed,
- related policy/SOP conflicts are checked,
- required approvals are complete,
- version and publication status are recorded,
- audit trail is preserved.

## 3. SOP Candidate Register

| Candidate ID | Proposed SOP Title | Source Type | Risk Class | Owner | Approval Status | Publication Status |
|---|---|---|---|---|---|---|
| DSOP-001 |  |  |  |  | Draft | Not Published |

## 4. Source Type

| Source Type | Meaning |
|---|---|
| UNKNOWN_QUESTION | unknown customer/staff question |
| REPEATED_QUESTION | repeated support/customer question |
| ANSWER_MAP_GAP | approved answer requires missing procedure |
| RECURRING_ISSUE | recurring issue/root cause register item |
| DAILY_ISSUE | daily issue/training/SOP queue |
| PAYMENT_REVIEW | payment/refund/cancel review |
| PROVIDER_BLOCKER | provider dependency or official response issue |
| SUPPORT_ESCALATION | support escalation revealed missing SOP |
| TRAINING_GAP | staff training gap |
| PRODUCT_UI_CHANGE | screen/workflow change requires SOP |
| AUDIT_FINDING | evidence/audit/reconciliation finding |

## 5. Risk Class

| Risk Class | Meaning | Required Review |
|---|---|---|
| S0 | payment/refund/cancel/customer harm risk | operations + support + payment/finance + security if needed |
| S1 | POS/KDS/order state risk | operations + product + technical if needed |
| S2 | staff operating procedure | operations + document owner |
| S3 | support wording / answer map | support + product |
| S4 | internal admin/document hygiene | document owner |

## 6. Approval Status

| Status | Meaning |
|---|---|
| Draft | candidate created |
| Evidence Review | source evidence being checked |
| AI Drafting | AI-assisted draft being prepared |
| Draft Ready | draft ready for review |
| Needs Ops Review | operations review required |
| Needs Support Review | support/customer wording review required |
| Needs Payment Review | payment/finance review required |
| Needs Security Review | security/sensitive-data review required |
| Needs Technical Review | provider/system/technical review required |
| Approved | approved for publication |
| Rejected | not valid or unsafe |
| Deferred | not current phase |
| Published | active SOP published |
| Superseded | replaced by newer SOP |
| Retired | no longer active |

## 7. Publication Status

| Status | Meaning |
|---|---|
| Not Published | candidate only |
| Draft Document Created | draft file exists |
| Ready To Publish | approval complete |
| Active | published active SOP |
| Active With Conditions | active but limited |
| Superseded | replaced |
| Retired | no longer used |
| Blocked | cannot publish |

## 8. Source Evidence Record

| Candidate ID | Source Ref | Source Summary | Frequency | Severity | Evidence Link / Ref |
|---|---|---|---:|---:|---|
|  |  |  |  |  |  |

## 9. Related Document Mapping

| Candidate ID | Related Current Document | Conflict Checked | Update Needed |
|---|---|---|---|
|  |  |  |  |

Potential related documents:

- approved answer map
- unknown question queue
- recurring issue register
- payment/order separation policy
- mismatch escalation runbook
- daily reconciliation template
- staff training checklist
- provider blocker register
- AI customer center guardrail document

## 10. Candidate Detail Template

| Field | Value |
|---|---|
| candidate_id |  |
| proposed_filename |  |
| proposed_title |  |
| document_type | SOP / Policy / Runbook / Checklist / Template |
| source_type |  |
| source_refs |  |
| risk_class |  |
| audience | staff / support / customer-facing support / internal |
| owner |  |
| reviewer_1 |  |
| reviewer_2 |  |
| approval_status |  |
| publication_status |  |
| target_effective_date |  |
| review_due_date |  |
| notes |  |

## 11. Required Approval Matrix

| Risk Class | Required Approvals |
|---|---|
| S0 | operations, support, payment/finance, security if sensitive |
| S1 | operations, product, technical if system/provider involved |
| S2 | operations, document owner |
| S3 | support, product |
| S4 | document owner |

## 12. Block Conditions

A candidate must be blocked when:

- source evidence is missing,
- proposed SOP conflicts with approved policy,
- payment/refund/cancel wording is unsafe,
- provider capability is assumed without official basis,
- customer-facing promise is not approved,
- manual fallback or escalation path is missing,
- audit trail cannot be preserved,
- owner is not assigned.

## 13. Candidate Priority

| Priority | Condition |
|---|---|
| P0 | customer/payment harm or duplicate risk |
| P1 | repeated POS/KDS/order state mismatch |
| P2 | repeated support unknown question |
| P3 | staff training and process clarity |
| P4 | documentation hygiene |

## 14. Weekly Review

| Week | New Candidates | Approved | Published | Blocked | Deferred | Open S0/S1 |
|---|---:|---:|---:|---:|---:|---:|
| Week 1 |  |  |  |  |  |  |
| Week 2 |  |  |  |  |  |  |
| Week 3 |  |  |  |  |  |  |
| Week 4 |  |  |  |  |  |  |

## 15. Audit Trail Fields

For each candidate, preserve:

- candidate creation timestamp
- creator/source
- source evidence
- AI draft generation timestamp if used
- reviewer comments
- approval/rejection decision
- publication version
- effective date
- retirement/supersession record
- related answer-map update
- related training/support update

## 16. Output Rules

When approved, candidate must create or update one of:

| Output | Destination |
|---|---|
| active SOP | SOP repository |
| policy update | policy document |
| runbook update | escalation/runtime runbook |
| checklist update | training/readiness checklist |
| answer-map update | AI customer center/support map |
| training update | staff training queue |
| blocker update | provider/payment/security queue |

## 17. Non-Goals

This register does not define:

- AI prompt implementation,
- model vendor,
- vector database,
- chatbot runtime,
- provider adapter code,
- payment gateway behavior.

It tracks candidate status, evidence, approval, and publication readiness.

## 18. Related Documents

- 14580_WorkPackage_Digital_SOP_Candidate_Generation_Approval_And_Publication_Control.md
- 14570_Index_AI_Customer_Center_Manual_Fallback_Knowledge_Closeout_And_Handoff.md
- 14560_Report_AI_Customer_Center_Answer_Map_Closeout_And_Digital_SOP_Handoff.md
- 14540_Register_AI_Customer_Center_Unknown_Question_And_SOP_Candidate_Queue.md
- 14550_Template_AI_Customer_Center_Approved_Answer_Map_And_Escalation_Rule.md
- 14460_Register_First_Store_Recurring_Issue_Root_Cause_And_Control_Action.md
- 08000_ai_customer_center
