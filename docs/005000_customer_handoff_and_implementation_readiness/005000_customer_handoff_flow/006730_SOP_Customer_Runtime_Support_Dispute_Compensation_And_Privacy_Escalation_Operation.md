# 006730_SOP_Customer_Runtime_Support_Dispute_Compensation_And_Privacy_Escalation_Operation

## 1. Purpose

This SOP defines the Customer Runtime support, dispute, compensation, and privacy escalation operating procedure.

The purpose is to ensure that unresolved customer-facing issues are handled through controlled support, manager, finance, privacy, and evidence workflows instead of informal staff memory, verbal promises, or untracked goodwill.

Customer support is part of runtime continuity.  
A customer dispute, compensation decision, refund/cancel request, benefit correction, or privacy-sensitive issue must preserve the original store runtime context, payment context, customer-facing message history, staff action, manager decision, and evidence.

## 2. Scope

This SOP covers:

- Customer dispute intake
- Support case creation
- Store-to-support handoff
- Manager escalation
- Compensation request handling
- Refund/cancel support routing
- Payment-sensitive support escalation
- Membership and benefit support issue handling
- Privacy-sensitive support issue handling
- Customer communication control
- Case closure and reopen
- Daily closeout review
- Evidence requirements

This SOP does not define final CRM tooling, legal claim procedure, full privacy incident response program, chargeback platform integration, or final compensation amount matrix.

## 3. Baseline Dependency

This SOP depends on:

`06600_Policy_Customer_Support_Case_Dispute_Resolution_Compensation_Refund_Cancel_Handoff_And_Evidence_Control.md`

`06610_Policy_Customer_Privacy_Consent_Data_Retention_Evidence_Access_Support_Visibility_And_Runtime_Governance.md`

`06590_Policy_Customer_Membership_Loyalty_Coupon_Visit_Count_Store_Benefit_And_Runtime_Control.md`

`006620_Policy_Customer_Runtime_Evidence_Audit_Trail_Traceability_Closeout_Handoff.md`

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

`006700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

## 4. Core Operating Principle

A customer issue must be resolved with context, authority, and evidence.

Staff and managers must ensure:

1. Customer claim is recorded.
2. Affected runtime references are linked.
3. Payment and refund/cancel issues are not guessed.
4. Compensation is distinguished from refund and normal loyalty.
5. Privacy-sensitive issues are escalated immediately.
6. Customer-facing wording is conservative.
7. Case owner is assigned.
8. Closure requires reason and evidence.
9. Daily closeout reviews unresolved customer-facing issues.

## 5. Roles And Authority

| Role | Allowed Actions |
|---|---|
| Store Staff | Receive customer claim, record initial note, create support handoff, use approved wording |
| Staff Lead | Review operational context, coordinate staff correction, request manager review |
| Store Manager | Approve store-level resolution, compensation request, no-show/table/order exception, closeout carry-forward |
| Customer Support Owner | Own support case, customer communication, resolution, reopen, and follow-up |
| Finance/Reconciliation Owner | Own payment, refund, cancel, settlement, duplicate charge, or financial ambiguity review |
| Membership/Loyalty Owner | Own coupon, visit count, benefit, compensation-benefit correction |
| Privacy/Compliance Owner | Own privacy-sensitive access, wrong-session display, consent, data exposure issues |
| Evidence Owner | Confirms support and dispute evidence packet completeness |
| Release Owner | Restricts or rolls back customer flow when support/privacy/payment issue indicates rollout risk |

Staff must not promise refund, coupon restoration, payment result, or compensation without authority.

## 6. Dispute Intake Procedure

When a customer raises an issue:

1. Listen and classify the issue without arguing.
2. Identify customer-facing flow:
   - Waiting
   - Table
   - Order
   - Payment
   - Kiosk/app/link
   - Kitchen/service
   - Membership/benefit
   - Privacy/data
   - Other
3. Record customer claim in short factual language.
4. Identify store and business date.
5. Identify affected session/order/payment/table/KDS/support/benefit reference where possible.
6. Avoid unsupported promises.
7. Decide whether staff can resolve immediately or must escalate.
8. Create support case or manager review when required.

Expected event:

- `support_case_created`

Initial support evidence must include:

- Customer claim
- Intake channel
- Store ID
- Business date
- Staff actor, where applicable
- Affected references, where available
- Initial case family
- Initial severity
- Customer-facing status

## 7. Case Family Classification Procedure

Classify the case into one or more families.

| Case Family | Examples |
|---|---|
| Waiting | Skipped queue, not called, no-show dispute, waiting disappeared |
| Table | Wrong table, lost preorder after seating, table QR issue |
| Order | Wrong item, duplicate order, order not found, cancelled order confusion |
| Payment | Duplicate charge, payment succeeded but order failed, refund not visible |
| Kiosk/App/Link | Expired link, web error, kiosk continuation failed, duplicate submission |
| Kitchen/Service | Delay, remake, ready/served confusion, missing item |
| Membership/Benefit | Coupon missing, coupon consumed incorrectly, visit count missing |
| Compensation | Apology coupon, goodwill, refund request, replacement item |
| Privacy | Wrong customer data shown, wrong recipient, wrong account/session link |
| Compliance-Sensitive | Legal, safety, privacy, payment, audit-sensitive matter |

Expected event:

- `support_case_classified`

A payment, privacy, or legal-sensitive issue must not remain classified only as a general complaint.

## 8. Severity Assignment Procedure

Assign severity based on customer impact and risk.

| Severity | Use When |
|---|---|
| CS-SEV-1 | Payment ambiguity, privacy exposure, safety/legal risk, severe trust issue |
| CS-SEV-2 | Material customer impact requiring owner follow-up |
| CS-SEV-3 | Normal support case with limited risk |
| CS-SEV-4 | Low-risk feedback or improvement note |

Expected event:

- `support_case_severity_assigned`

Severity must be escalated if new evidence shows payment, privacy, legal, or repeated customer trust impact.

## 9. Store-To-Support Handoff Procedure

Create store-to-support handoff when the store cannot fully resolve the issue during the visit.

Procedure:

1. Open or create support case.
2. Attach store ID and business date.
3. Attach affected waiting/table/order/payment/KDS/benefit references.
4. Add staff note.
5. Add manager note if reviewed.
6. Add customer-facing message history if available.
7. Add evidence links.
8. Assign support owner or queue.
9. Tell customer that support will review the case, not that the outcome is guaranteed.

Expected event:

- `store_support_handoff_attached`

Support handoff must not be a free-text complaint without runtime references.

## 10. Manager Escalation Procedure

Escalate to manager when:

- Customer disputes no-show or seating fairness
- Customer claims wrong order or wrong table context
- Customer asks for refund, cancel, or compensation
- Staff action would affect payment, coupon, benefit, or another customer
- Evidence is missing for material claim
- Customer-facing message may have been misleading
- Privacy-sensitive issue is suspected
- Customer is upset and issue may continue
- Staff authority is insufficient

Procedure:

1. Staff summarizes the claim.
2. Manager reviews runtime evidence.
3. Manager confirms whether immediate action is allowed.
4. Manager records decision.
5. If unresolved, manager assigns support/finance/privacy owner.
6. Customer-facing response is given using conservative wording.

Expected events:

- `manager_customer_dispute_review_started`
- `manager_customer_dispute_decision_recorded`

Manager decision must not erase original staff action.

## 11. Compensation Request Procedure

Compensation may be requested for:

- Service failure
- Wrong order
- Long delay
- Customer inconvenience
- Missed waiting call caused by store issue
- Table/order context error
- Coupon/benefit failure
- Support-approved goodwill
- Privacy-sensitive trust recovery, where policy allows

Procedure:

1. Confirm compensation type requested or proposed.
2. Confirm whether refund/cancel is separate.
3. Confirm affected order/payment/benefit references.
4. Confirm authority required.
5. Manager or support owner approves or rejects.
6. Record reason and evidence.
7. Communicate decision conservatively.
8. Link compensation to support case.
9. Link finance if financial impact exists.
10. Link membership owner if coupon/benefit is used.

Expected events:

- `support_compensation_requested`
- `support_compensation_approved`
- `support_compensation_rejected`
- `compensation_benefit_issued`, where applicable

Compensation must not be hidden as normal loyalty accrual.

## 12. Refund And Cancel Support Routing Procedure

Refund and cancel must be distinguished.

When customer asks for cancellation or refund:

1. Identify whether customer wants:
   - Order cancellation
   - Payment refund
   - Both
   - Coupon restoration
   - Compensation
2. Confirm order state.
3. Confirm payment state.
4. Confirm kitchen/KDS state.
5. Confirm POS Gateway or provider reference.
6. Route payment-sensitive case to finance/reconciliation owner.
7. Record customer-facing wording.
8. Do not promise refund completion before finance/payment confirmation.
9. Record final outcome or carry-forward owner.

Expected events:

- `support_refund_request_created`
- `support_cancel_request_created`
- `support_finance_handoff_attached`

A cancelled order does not automatically mean refund is complete.  
A refund does not automatically mean kitchen/order state was cancelled cleanly.

## 13. Payment-Sensitive Escalation Procedure

Escalate to finance/reconciliation owner when:

- Customer claims duplicate charge
- Payment succeeded but order failed
- Payment failed but customer sees charge
- Refund did not arrive
- Cancelled order appears charged
- POS Gateway and customer claim conflict
- Settlement mismatch appears
- Coupon/benefit affects charged amount
- Payment uncertainty exists at closeout

Procedure:

1. Create or update support case.
2. Attach order/payment/POS Gateway references.
3. Attach customer claim.
4. Attach customer-facing payment status evidence.
5. Attach refund/cancel request if any.
6. Assign finance owner.
7. Mark customer-facing status as payment review.
8. Record finance response when available.
9. Close only with evidence or owner-approved decision.

Expected events:

- `support_finance_handoff_attached`
- `payment_evidence_linked`

Payment cases must not be closed just because the customer left the store.

## 14. Membership And Benefit Issue Procedure

Membership/benefit issues include:

- Coupon missing
- Coupon not applied
- Coupon consumed incorrectly
- Coupon not restored after failed payment
- Visit count missing
- Guest order claim failed
- Benefit attached to wrong account
- Staff promised benefit
- Compensation coupon not received

Procedure:

1. Open support case.
2. Attach customer account or guest reference.
3. Attach coupon/benefit/visit count reference where available.
4. Attach order/payment reference if benefit affects financial amount.
5. Check coupon lifecycle state.
6. Check refund/cancel impact.
7. Request membership/loyalty owner review where required.
8. Record correction, rejection, restoration, or compensation.
9. Communicate customer-facing status conservatively.

Expected events:

- `benefit_dispute_created`
- `coupon_restored`
- `visit_count_reversed`
- `compensation_benefit_issued`

Benefit correction must preserve before/after state.

## 15. Privacy-Sensitive Escalation Procedure

Privacy-sensitive cases include:

- Customer sees another customer’s waiting/order/payment/status
- Table QR opens wrong session
- Link opens wrong customer context
- Notification sent to wrong recipient
- Staff attaches wrong account
- Support case visible to wrong account
- Internal staff note exposed to customer
- Payment status shown to wrong user
- Customer requests data restriction/deletion/anonymization review

Procedure:

1. Stop active exposure path if ongoing.
2. Notify manager.
3. Create privacy incident.
4. Attach affected customer/session/order/payment/link/support references.
5. Preserve display/access/token evidence.
6. Escalate privacy/compliance owner.
7. Use safe customer-facing wording.
8. Do not delete evidence casually.
9. Record containment and resolution.
10. Route rollout risk if systemic.

Expected events:

- `privacy_incident_created`
- `customer_data_restricted`
- `privacy_incident_resolved`

Privacy-sensitive issues should be treated as high-risk until reviewed.

## 16. Customer Communication Procedure

Customer communication must be clear, factual, and conservative.

Allowed status messages include:

- Received
- Checking
- Store Review
- Payment Review
- Finance Review
- Benefit Review
- Privacy Review
- Waiting For Customer
- Resolution Proposed
- Resolved
- Rejected
- Carried Forward

Staff or support should say:

- “확인 후 안내드리겠습니다.”
- “결제 상태는 별도 확인이 필요합니다.”
- “환불 여부와 완료 여부는 확인 후 안내드리겠습니다.”
- “쿠폰/혜택 상태를 확인하고 있습니다.”
- “개인정보 노출 가능성이 있어 담당자가 확인하겠습니다.”
- “처리 결과는 기록을 기준으로 안내드리겠습니다.”

Avoid unsupported statements:

- “무조건 환불됩니다.”
- “결제는 문제없습니다.”
- “쿠폰은 바로 복구됩니다.”
- “기록은 없지만 처리했습니다.”
- “개인정보 문제는 아닙니다.”
- “고객님 말씀이 맞으니 바로 보상하겠습니다.”

Customer communication must not outrun evidence.

## 17. Case Closure Procedure

A support case may be closed only when:

1. Customer claim is recorded.
2. Case family and severity are classified.
3. Affected references are linked or missing references are documented.
4. Required evidence is reviewed.
5. Payment/refund/cancel status is final or owner-assigned.
6. Compensation decision is recorded.
7. Membership/benefit adjustment is completed, rejected, or owner-assigned.
8. Privacy issue is resolved or escalated.
9. Customer-facing response is completed or not required.
10. Closure reason is recorded.

Expected event:

- `support_case_resolved`
- `support_case_rejected`

Closure must not erase case history.

## 18. Case Reopen Procedure

Reopen case when:

- Customer disputes resolution
- Payment evidence changes
- Refund/cancel fails after promised status
- Coupon/benefit restoration fails
- Store finds new evidence
- Finance result contradicts earlier assumption
- Privacy review requires additional action
- Customer provides new proof

Procedure:

1. Reopen existing case rather than creating unrelated duplicate where possible.
2. Preserve previous closure state.
3. Record reopen reason.
4. Assign owner.
5. Attach new evidence.
6. Update customer-facing status.
7. Route finance/privacy/membership if required.

Expected event:

- `support_case_reopened`

## 19. Daily Closeout Procedure

At daily closeout, review:

- New support cases
- Open support cases
- Resolved support cases
- Rejected support cases
- Reopened support cases
- Payment-sensitive cases
- Refund/cancel cases
- Compensation cases
- Membership/benefit cases
- Privacy-sensitive cases
- Cases missing owner
- Cases missing evidence
- Cases requiring finance/support/privacy carry-forward

Closeout result must classify:

- Clean
- Exception Close
- Carry-Forward
- Blocked

A clean close must not be declared if material support cases lack owner or evidence.

## 20. Evidence Requirements

Support SOP must preserve evidence for:

- Dispute intake
- Case creation
- Case family classification
- Severity assignment
- Store-to-support handoff
- Manager review
- Compensation request
- Compensation approval/rejection
- Refund/cancel request
- Finance handoff
- Membership/benefit review
- Privacy incident escalation
- Customer communication
- Case closure
- Case reopen
- Daily closeout review

Evidence fields must include:

- Support case ID
- Store ID
- Business date
- Customer or guest reference
- Affected waiting/table/order/payment/KDS/benefit references
- Actor ID
- Event name
- Case family
- Severity
- Previous state
- New state
- Reason code
- Customer-facing status
- Evidence record ID
- Owner
- Timestamp
- Related finance/privacy/incident/closeout reference, where applicable

## 21. Blocking Conditions

Support or rollout flow must be blocked, restricted, or escalated when:

- Payment-sensitive case has no owner
- Refund/cancel promise was made without payment evidence
- Privacy exposure is suspected and not contained
- Support case lacks customer claim or affected reference
- Compensation was granted without authority
- Benefit adjustment affects payment but lacks finance handoff
- Customer-facing status contradicts runtime state
- Evidence is missing for high-risk dispute
- Repeated support case pattern indicates systemic runtime issue
- Daily closeout cannot account for open customer cases

Blocking conditions must route to:

`06670_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md`

## 22. Training Checklist

Staff, manager, and support training must cover:

- Customer claim intake
- Case family classification
- Severity assignment
- Store-to-support handoff
- Manager escalation
- Compensation distinction
- Refund vs cancel distinction
- Payment-sensitive escalation
- Membership/benefit issue handling
- Privacy-sensitive escalation
- Customer-facing wording
- Evidence requirements
- Case closure and reopen
- Daily closeout review

Training must include at least one payment-sensitive case and one privacy-sensitive case.

## 23. Acceptance Criteria

This SOP is accepted when:

- Dispute intake procedure is defined
- Case family classification is defined
- Severity assignment is defined
- Store-to-support handoff is defined
- Manager escalation procedure is defined
- Compensation request procedure is defined
- Refund/cancel support routing is defined
- Payment-sensitive escalation is defined
- Membership/benefit issue procedure is defined
- Privacy-sensitive escalation is defined
- Customer communication procedure is defined
- Case closure and reopen procedures are defined
- Daily closeout procedure is defined
- Evidence requirements are traceable
- Blocking conditions are documented
- Training checklist is included

## 24. Related Documents

Related document families include:

- Customer support case dispute resolution policy
- Customer privacy consent data retention policy
- Membership loyalty coupon benefit policy
- Customer runtime evidence packet policy
- Customer runtime state authority event evidence matrix
- Customer runtime event audit evidence field specification template
- Waiting call no-show recovery SOP
- Table matching preorder link service context SOP
- Customer Runtime pilot readiness checklist
- Customer Runtime pilot execution runbook
- Customer Runtime risk waiver blocker register
- Finance reconciliation handoff policy
- Refund and cancel policy
- Payment uncertainty policy

## 25. Final Rule

Customer support must not be a memory-based apology desk.

It must be the controlled continuation of customer runtime truth.

Every dispute, compensation, refund/cancel request, benefit issue, privacy concern, and case closure must remain linked to runtime context, authority, evidence, owner, and closeout.