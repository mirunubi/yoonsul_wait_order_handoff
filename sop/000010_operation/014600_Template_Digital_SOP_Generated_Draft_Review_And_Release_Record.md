# 014600_Template_Digital_SOP_Generated_Draft_Review_And_Release_Record.md

## 1. Purpose

This template records the review, approval, release, revision, and audit trail of an AI-assisted digital SOP draft.

It is used after a SOP candidate has passed evidence intake and is ready for draft review.

The purpose is to prevent AI-generated SOP content from becoming active operational truth without human review, version control, publication status, and rollback path.

## 2. Core Rule

A generated SOP draft is not an active SOP.

It becomes active only after:

- source evidence is verified,
- owner review is completed,
- required approvals are recorded,
- version is assigned,
- release status is set,
- related answer map/training/support documents are updated if needed.

## 3. Draft Record Identity

| Field | Value |
|---|---|
| draft_record_id |  |
| candidate_id |  |
| proposed_filename |  |
| proposed_document_type | SOP / Policy / Runbook / Checklist / Template |
| proposed_title |  |
| source_register_ref |  |
| generated_by | AI-assisted / human / mixed |
| draft_created_at |  |
| draft_owner |  |
| review_owner |  |
| target_effective_date |  |
| current_status | Draft |

## 4. Source Evidence Summary

| Evidence Field | Value |
|---|---|
| source_type |  |
| source_question_or_issue_ids |  |
| frequency |  |
| severity |  |
| affected_process |  |
| affected_roles |  |
| customer_impact |  |
| payment_or_financial_impact |  |
| related_order_refs |  |
| related_support_refs |  |
| related_reconciliation_refs |  |
| related_provider_refs |  |

## 5. Risk Classification

| Field | Value |
|---|---|
| risk_class | S0 / S1 / S2 / S3 / S4 |
| risk_reason |  |
| payment_sensitive | Yes / No |
| customer_facing | Yes / No |
| provider_dependent | Yes / No |
| security_sensitive | Yes / No |
| requires_fallback | Yes / No |
| requires_escalation_rule | Yes / No |

## 6. Draft Review Checklist

| Check | Required | Result | Notes |
|---|---|---|---|
| filename follows naming rule | Yes |  |  |
| H1 matches filename stem | Yes |  |  |
| purpose is clear | Yes |  |  |
| scope is clear | Yes |  |  |
| non-goals are clear | Yes |  |  |
| source evidence is linked | Yes |  |  |
| procedure does not contradict existing policy | Yes |  |  |
| escalation path is clear | Yes |  |  |
| fallback path is clear | If operational |  |  |
| payment/refund/cancel wording is safe | If relevant |  |  |
| customer-facing promises are approved | If relevant |  |  |
| provider assumptions are removed | If relevant |  |  |
| audit/evidence requirements are included | Yes |  |  |
| related documents are linked | Yes |  |  |
| owner and review cadence are included | Yes |  |  |

## 7. Prohibited Content Check

The draft must not include unapproved statements such as:

- payment complete without evidence,
- refund complete without evidence,
- cancellation complete without evidence,
- POS entry complete without POS/staff confirmation,
- kitchen handoff complete without KDS/printer/manual confirmation,
- provider outage claim without official basis,
- automatic compensation promise,
- automatic refund promise,
- undocumented legal or financial obligation.

| Prohibited Content Found | Correction Required |
|---|---|
|  |  |

## 8. Review Comment Log

| Comment ID | Reviewer | Section | Comment | Required Change | Status |
|---|---|---|---|---|---|
| RC-001 |  |  |  |  | Open |

## 9. Approval Record

| Approval Area | Required Reviewer | Decision | Name / Date |
|---|---|---|---|
| Document owner |  | Approve / Reject / Revise |  |
| Operations owner | If operational | Approve / Reject / Revise |  |
| Support owner | If customer/support-facing | Approve / Reject / Revise |  |
| Product owner | If product/customer flow affected | Approve / Reject / Revise |  |
| Payment/finance owner | If payment/refund/cancel involved | Approve / Reject / Revise |  |
| Security owner | If sensitive/provider/payment event involved | Approve / Reject / Revise |  |
| Technical owner | If provider/system dependency involved | Approve / Reject / Revise |  |

## 10. Release Record

| Field | Value |
|---|---|
| release_decision | Publish / Publish With Conditions / Hold / Reject / Defer |
| version |  |
| status | Active / Active With Conditions / Draft / Rejected / Deferred |
| effective_date |  |
| review_due_date |  |
| published_location |  |
| supersedes |  |
| superseded_by |  |
| rollback_path |  |
| retirement_condition |  |

## 11. Conditional Release Controls

If released with conditions, record:

| Condition | Owner | Review Date | Status |
|---|---|---|---|
|  |  |  |  |

Examples:

- only for first-store pilot,
- staff-only, not customer-facing,
- escalation required for payment/refund/cancel,
- provider-dependent section disabled,
- AI customer center may retrieve but not auto-answer,
- manual fallback remains mandatory.

## 12. Downstream Update Checklist

| Downstream Item | Update Required | Status |
|---|---|---|
| answer map |  |  |
| unknown question queue |  |  |
| staff training material |  |  |
| support script |  |  |
| escalation runbook |  |  |
| payment/security review record |  |  |
| provider blocker register |  |  |
| implementation backlog |  |  |
| index/readme cross-link |  |  |

## 13. Audit Trail

| Event | Timestamp | Actor | Notes |
|---|---|---|---|
| candidate created |  |  |  |
| source evidence attached |  |  |  |
| AI draft generated |  |  |  |
| draft reviewed |  |  |  |
| changes requested |  |  |  |
| approvals completed |  |  |  |
| released |  |  |  |
| revised |  |  |  |
| retired/superseded |  |  |  |

## 14. Rejection / Deferral Record

If rejected or deferred:

| Field | Value |
|---|---|
| reason |  |
| risk |  |
| missing evidence |  |
| required future condition |  |
| owner |  |
| next_review_date |  |

## 15. Non-Goals

This template does not define:

- AI model implementation,
- prompt design,
- vector database,
- chatbot deployment,
- provider adapter code,
- payment gateway behavior.

It records review and release control for generated digital SOP drafts.

## 16. Related Documents

- 14590_Register_Digital_SOP_Candidate_Approval_Status_And_Source_Evidence.md
- 14580_WorkPackage_Digital_SOP_Candidate_Generation_Approval_And_Publication_Control.md
- 14570_Index_AI_Customer_Center_Manual_Fallback_Knowledge_Closeout_And_Handoff.md
- 14560_Report_AI_Customer_Center_Answer_Map_Closeout_And_Digital_SOP_Handoff.md
- 14550_Template_AI_Customer_Center_Approved_Answer_Map_And_Escalation_Rule.md
- 08000_ai_customer_center
