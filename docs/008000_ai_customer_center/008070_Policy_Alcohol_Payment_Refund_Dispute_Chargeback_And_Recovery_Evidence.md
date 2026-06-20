# 008070_Policy_Alcohol_Payment_Refund_Dispute_Chargeback_And_Recovery_Evidence.md

## Purpose

This document defines the alcohol payment, refund, cancellation, dispute, chargeback, customer recovery, evidence packet, payment/KDS timeline, verification dependency, service refusal dependency, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined alcohol KDS hold, staff approval, manager approval, KDS release, cancellation, and service refusal boundary policy.

This document focuses on payment and recovery risk after alcohol-related order, verification, KDS, service, or refusal events occur.

This document does not implement payment gateway logic, refund API, chargeback handling, POS reconciliation, legal dispute process, or customer service automation.

It defines alcohol payment, refund, dispute, chargeback, and recovery evidence boundary policy only.

---

## 2. Scope

This document covers:

- alcohol payment boundary
- payment before verification
- payment after verification
- payment uncertainty
- refund before preparation
- refund after preparation
- refund after service
- service refusal after payment
- customer dispute
- chargeback risk
- evidence packet
- customer recovery
- support escalation
- no-implementation boundary

This document does not cover:

- final payment API
- final refund API
- final POS settlement logic
- final chargeback platform
- final legal dispute handling
- final accounting treatment
- final card company process
- final delivery platform refund rule
- final alcohol legal interpretation
- final customer service script

---

## 3. Core Principle

Alcohol payment must not erase verification, KDS, service, or customer intent uncertainty.

The project must follow this rule:

> Alcohol-related payment, refund, cancellation, dispute, and chargeback handling must preserve adult verification status, payment status, KDS execution status, service status, staff approval, service refusal, customer intent, and evidence timeline before deciding refund, refusal, recovery, or escalation.

Payment success is not legal service approval.

KDS release is not refund denial.

Service refusal is not customer punishment.

Evidence must come before conclusion.

---

## 4. Alcohol Payment Boundary Meaning

Alcohol payment boundary means the point where payment is requested, authorized, captured, reversed, refunded, disputed, or reconciled for an alcohol-related order.

This boundary must consider:

- adult verification status
- payment provider status
- POS status
- KDS status
- table/session status
- staff approval status
- manager approval status
- service refusal status
- customer intent clarity
- partial settlement status
- split payment status
- delivery platform status if any
- legal/compliance risk
- evidence completeness

Alcohol payment must be more conservative than ordinary food payment.

---

## 5. Alcohol Payment Status Values

Recommended alcohol payment status values:

- `ALCOHOL_PAYMENT_NOT_STARTED`
- `ALCOHOL_PAYMENT_VERIFICATION_REQUIRED`
- `ALCOHOL_PAYMENT_AUTHORIZATION_PENDING`
- `ALCOHOL_PAYMENT_AUTHORIZED`
- `ALCOHOL_PAYMENT_CAPTURED`
- `ALCOHOL_PAYMENT_FAILED`
- `ALCOHOL_PAYMENT_UNCERTAIN`
- `ALCOHOL_PAYMENT_DUPLICATE_SUSPECTED`
- `ALCOHOL_PAYMENT_REFUND_REVIEW`
- `ALCOHOL_PAYMENT_REFUND_PENDING`
- `ALCOHOL_PAYMENT_REFUNDED`
- `ALCOHOL_PAYMENT_PARTIAL_REFUND`
- `ALCOHOL_PAYMENT_CHARGEBACK_REVIEW`
- `ALCOHOL_PAYMENT_DISPUTED`
- `ALCOHOL_PAYMENT_RECONCILED`

Final values may be normalized later.

---

## 6. Payment Before Verification Rule

Payment before verification is high-risk.

If payment occurs before adult verification is completed:

- alcohol item must not be fulfilled automatically
- KDS should remain held
- payment status should show verification dependency
- customer should be informed calmly
- refund path must exist if verification fails
- staff review may be required
- evidence must link payment and verification status
- non-alcohol items may continue if safe

Payment before verification must not imply guaranteed alcohol service.

---

## 7. Verification Before Payment Rule

Verification before payment is safer but still requires evidence.

If verification occurs before payment:

- verification status must be current
- verification scope must match order/session
- verification expiration must be checked
- table participant ambiguity must be reviewed
- payment must still be validated
- KDS release must wait for payment if policy requires
- staff confirmation may still be required

Verification passed does not eliminate payment or service risk.

---

## 8. Payment After KDS Release Rule

If payment occurs after KDS release:

- KDS execution status must be preserved
- payment failure must trigger staff review
- customer recovery may be required
- refund/cancel path may differ
- waste or service evidence may be needed
- manager escalation may be required
- support case may be created

Payment timing must be visible in the evidence timeline.

---

## 9. Payment Uncertainty Rule

Payment uncertainty exists when:

- provider callback delayed
- provider callback duplicated
- POS state differs from payment provider
- table partial settlement unclear
- split payment mapping unclear
- customer repeated payment tap occurred
- customer disputes payment intent
- payment authorized but not captured
- refund requested while capture pending
- provider outage exists
- delivery platform payment state unknown

Uncertainty must be shown and handled conservatively.

---

## 10. Duplicate Payment Risk Rule

Duplicate payment risk may occur when:

- customer taps repeatedly
- network delay causes retry
- provider sends duplicate callback
- POS creates second payment attempt
- table split payment overlaps
- staff retries manually
- platform order and POS order both charge
- refund/reversal status is unclear

Duplicate payment risk requires immediate review and customer recovery readiness.

---

## 11. Alcohol Refund Boundary Meaning

Alcohol refund boundary means determining whether and how payment should be reversed or refunded after an alcohol-related issue.

Refund decision must consider:

- verification result
- payment status
- KDS status
- preparation status
- service status
- service refusal status
- customer intent dispute
- staff approval
- partial settlement
- split payment
- provider responsibility
- legal/compliance rule
- customer recovery policy

Refund should not be decided from payment state alone.

---

## 12. Refund Before Preparation Rule

Refund before preparation may be allowed when:

- KDS not released
- KDS held
- verification failed before service
- customer cancels before staff approval
- duplicate payment suspected
- service refusal occurs before preparation
- provider duplicate event is detected
- payment was captured but order cannot proceed

Refund before preparation should be straightforward but evidence-linked.

---

## 13. Refund After Preparation Rule

Refund after preparation requires review because:

- kitchen labor occurred
- alcohol or paired food may be prepared
- product may be wasted
- service may not have occurred
- verification or service refusal may have changed
- customer intent may be disputed
- staff approval may be missing
- provider cancellation may be late

Refund after preparation must involve KDS and staff evidence.

---

## 14. Refund After Service Rule

Refund after alcohol service is high-risk.

Review should consider:

- whether alcohol was actually served
- whether verification evidence exists
- whether staff approval exists
- whether customer alleges mistouch
- whether customer alleges wrong item
- whether service refusal should have occurred
- whether payment dispute is valid
- whether legal/compliance review is needed
- whether customer recovery is appropriate

Refund after service must not be automatic.

---

## 15. Service Refusal After Payment Rule

If service is refused after payment:

- payment must be reviewed
- KDS status must be checked
- whether item was prepared must be checked
- whether item was served must be checked
- customer communication must be respectful
- refund or partial refund path must be considered
- service refusal evidence must be linked
- manager approval may be required
- support escalation may be needed

Service refusal after payment creates high dispute risk.

---

## 16. Refund Status Values

Recommended refund status values:

- `REFUND_NOT_REQUIRED`
- `REFUND_REVIEW_REQUIRED`
- `REFUND_REQUESTED`
- `REFUND_BEFORE_PREP_ALLOWED`
- `REFUND_AFTER_PREP_REVIEW`
- `REFUND_AFTER_SERVICE_REVIEW`
- `REFUND_PARTIAL_REVIEW`
- `REFUND_APPROVED`
- `REFUND_REJECTED`
- `REFUND_PROVIDER_PENDING`
- `REFUND_COMPLETED`
- `REFUND_FAILED`
- `REFUND_DISPUTED`
- `REFUND_ESCALATED`

Refund status must remain visible.

---

## 17. Cancellation And Refund Separation Rule

Cancellation and refund are not the same.

Cancellation affects:

- order state
- KDS state
- service state
- kitchen action
- customer communication
- provider state

Refund affects:

- payment state
- settlement state
- customer recovery
- accounting/reconciliation
- provider/card state

Cancel may occur without refund.

Refund may occur after cancel.

Both must be linked but not merged.

---

## 18. Alcohol Dispute Meaning

Alcohol dispute means a customer, staff, provider, or payment party questions the validity of alcohol-related order, payment, service, cancellation, or refund.

Disputes may involve:

- wrong item
- wrong quantity
- accidental tap
- unclear payment intent
- failed verification
- service refusal
- late cancellation
- item not served
- item already prepared
- split payment confusion
- table participant dispute
- delivery platform mismatch
- provider duplicate event

Dispute must be evidence-led.

---

## 19. Alcohol Dispute Status Values

Recommended dispute status values:

- `ALCOHOL_DISPUTE_NOT_OPEN`
- `ALCOHOL_DISPUTE_OPEN`
- `ALCOHOL_DISPUTE_EVIDENCE_REQUIRED`
- `ALCOHOL_DISPUTE_PAYMENT_REVIEW`
- `ALCOHOL_DISPUTE_KDS_REVIEW`
- `ALCOHOL_DISPUTE_VERIFICATION_REVIEW`
- `ALCOHOL_DISPUTE_SERVICE_REVIEW`
- `ALCOHOL_DISPUTE_CUSTOMER_RECOVERY`
- `ALCOHOL_DISPUTE_MANAGER_REVIEW`
- `ALCOHOL_DISPUTE_SUPPORT_ESCALATED`
- `ALCOHOL_DISPUTE_RESOLVED`
- `ALCOHOL_DISPUTE_UNRESOLVED`
- `ALCOHOL_DISPUTE_CHARGEBACK_RISK`

Dispute status should link to support and evidence.

---

## 20. Chargeback Risk Meaning

Chargeback risk means a payment dispute may later be raised through payment provider, card company, delivery platform, or other external channel.

Chargeback risk increases when:

- customer claims unauthorized payment
- customer claims accidental tap
- customer claims alcohol was not served
- customer claims wrong item
- customer claims service refusal after payment
- verification failed after payment
- refund was delayed
- provider callback was duplicated
- receipt and KDS timeline conflict
- partial settlement is unclear
- staff evidence is missing

Chargeback risk must trigger evidence preservation.

---

## 21. Chargeback Risk Status Values

Recommended values:

- `CHARGEBACK_RISK_NONE`
- `CHARGEBACK_RISK_WATCH`
- `CHARGEBACK_RISK_EVIDENCE_REQUIRED`
- `CHARGEBACK_RISK_PROVIDER_REVIEW`
- `CHARGEBACK_RISK_SUPPORT_REVIEW`
- `CHARGEBACK_RISK_HIGH`
- `CHARGEBACK_RISK_SUBMITTED`
- `CHARGEBACK_RISK_RESPONDED`
- `CHARGEBACK_RISK_CLOSED`

Chargeback status must not be hidden in support-only notes.

---

## 22. Evidence Timeline Rule

Alcohol payment evidence must preserve timeline across:

- order creation
- adult verification
- staff confirmation
- payment attempt
- payment authorization
- payment capture
- KDS hold
- KDS release
- preparation
- service
- cancellation request
- refund request
- service refusal
- customer dispute
- support escalation
- chargeback risk
- final resolution

Timeline must be append-only.

---

## 23. Payment Evidence Packet Fields

Alcohol payment evidence packet should include:

- evidence packet id
- order/session reference
- table reference
- payment reference
- provider reference
- alcohol item classification
- verification status
- staff approval status
- manager approval status
- payment status
- KDS status
- preparation status
- service status
- cancellation status
- refund status
- dispute status
- chargeback risk status
- customer communication status
- support case reference
- timestamps
- masking status
- notes

Evidence must avoid raw identity or payment secrets.

---

## 24. Payment Evidence ID Format

Recommended format:

    ALCOHOL-PAYMENT-EVIDENCE-[YYYYMMDD]-[NUMBER]

Example:

    ALCOHOL-PAYMENT-EVIDENCE-20260612-001

Final format may be normalized later.

---

## 25. Customer Recovery Meaning

Customer recovery means actions taken to preserve trust, reduce conflict, and resolve harm after alcohol-related payment, order, verification, service refusal, or dispute issue.

Recovery may include:

- explanation
- refund or partial refund
- non-alcohol item continuation
- replacement
- coupon or goodwill credit if policy allows
- manager apology
- support follow-up
- safe service refusal explanation
- incident review

Recovery is not admission of legal fault by default.

---

## 26. Customer Recovery Status Values

Recommended values:

- `RECOVERY_NOT_REQUIRED`
- `RECOVERY_REVIEW_REQUIRED`
- `RECOVERY_IN_PROGRESS`
- `RECOVERY_REFUND_OFFERED`
- `RECOVERY_PARTIAL_REFUND_OFFERED`
- `RECOVERY_REPLACEMENT_OFFERED`
- `RECOVERY_GOODWILL_CREDIT_OFFERED`
- `RECOVERY_MANAGER_CONTACT_REQUIRED`
- `RECOVERY_SUPPORT_FOLLOWUP_REQUIRED`
- `RECOVERY_COMPLETED`
- `RECOVERY_REJECTED_BY_CUSTOMER`
- `RECOVERY_ESCALATED`

Recovery status should be separate from refund status.

---

## 27. Customer Communication Rule

Customer communication should be:

- calm
- respectful
- clear
- non-accusatory
- avoiding identity exposure
- avoiding legal overstatement
- explaining what is being reviewed
- separating payment, order, and service state
- offering staff or manager help

Example:

    결제와 주문 상태를 확인 중입니다. 주류 주문은 확인 절차가 필요한 경우가 있어 직원이 상황을 확인한 뒤 안내드리겠습니다.

Avoid:

    환불 안 됩니다.
    이미 술 나갔으니 끝입니다.
    고객님이 잘못 누르셨습니다.
    신분 확인 실패라 어쩔 수 없습니다.

---

## 28. Staff Communication Rule

Staff display should show:

- payment status
- refund review status
- KDS status
- verification status
- service status
- dispute status
- customer recovery recommendation
- evidence completeness
- manager approval requirement
- safe customer wording
- support escalation path

Staff should not need to infer refund decision from one system.

---

## 29. Support Boundary

Support may assist when:

- refund/cancel conflict exists
- payment provider state unclear
- chargeback risk exists
- evidence packet incomplete
- customer disputes payment
- service refusal after payment occurred
- KDS and payment timeline conflict
- provider event duplicated
- partial settlement confused
- customer recovery escalated

Support must be case-scoped, masked, and evidence-based.

Support must not rewrite payment, KDS, or verification truth.

---

## 30. Manager Review Boundary

Manager review may be required when:

- refund after service requested
- chargeback risk high
- customer is upset
- staff safety issue occurred
- service refusal after payment occurred
- KDS already prepared disputed item
- alcohol was served
- partial settlement involved multiple customers
- legal/compliance concern exists
- evidence is incomplete

Manager review must be recorded.

---

## 31. Provider Boundary

Provider events relevant to payment/refund include:

- payment authorization callback
- payment capture callback
- refund callback
- cancellation callback
- chargeback notification
- duplicate event
- stale event
- provider outage
- delivery platform payment state
- POS settlement state

Provider event must be validated and mapped before changing canonical status.

---

## 32. POS Reconciliation Boundary

POS reconciliation may be required when:

- payment provider and POS disagree
- POS shows paid but provider uncertain
- provider shows captured but POS missing
- refund completed but POS not updated
- partial settlement mapping failed
- split payment allocation mismatched
- manual POS adjustment occurred
- delivery platform settlement differs

POS reconciliation must be evidence-linked.

---

## 33. KDS Reconciliation Boundary

KDS reconciliation may be required when:

- KDS released before payment certainty
- KDS prepared after cancellation
- KDS held after payment completion
- KDS ticket duplicated
- KDS status missing
- service status disputed
- kitchen manual note conflicts with payment
- provider order created duplicate KDS

KDS reconciliation must not mutate payment truth silently.

---

## 34. Partial Settlement Boundary

Alcohol partial settlement requires review when:

- one customer pays alcohol
- another customer consumed alcohol
- one participant leaves
- refund applies to only part of table
- split bill is disputed
- service refusal affects only alcohol item
- non-alcohol food continues
- payment was grouped but refund should be itemized

Partial settlement must preserve item-level and session-level evidence.

---

## 35. Delivery Platform Boundary

If delivery platform is involved:

- platform payment rule must be reviewed
- platform cancellation state must be mapped
- platform refund rule must be respected
- rider pickup status must be considered
- store responsibility must be clear
- delivery alcohol must remain disabled unless separately approved
- customer recovery may depend on platform channel
- evidence must link provider and canonical states

This document does not approve delivery alcohol sale.

---

## 36. Alcohol Payment Incident Trigger

Alcohol payment incident should be created when:

- duplicate payment suspected
- refund after service requested
- chargeback risk high
- payment/KDS timeline conflict exists
- payment after verification failure occurred
- service refusal after payment occurred
- partial settlement dispute exists
- provider callback duplicated
- POS/payment mismatch unresolved
- customer recovery escalates

Incident should be evidence-linked.

---

## 37. Alcohol Payment Incident Status Values

Recommended values:

- `PAYMENT_INCIDENT_NOT_OPEN`
- `PAYMENT_INCIDENT_OPEN`
- `PAYMENT_INCIDENT_EVIDENCE_REQUIRED`
- `PAYMENT_INCIDENT_PROVIDER_REVIEW`
- `PAYMENT_INCIDENT_POS_RECONCILIATION`
- `PAYMENT_INCIDENT_KDS_RECONCILIATION`
- `PAYMENT_INCIDENT_MANAGER_REVIEW`
- `PAYMENT_INCIDENT_SUPPORT_ESCALATED`
- `PAYMENT_INCIDENT_RECOVERY_REQUIRED`
- `PAYMENT_INCIDENT_RESOLVED`
- `PAYMENT_INCIDENT_UNRESOLVED`

Incident status must not be buried in notes.

---

## 38. Evidence Masking Rule

Alcohol payment evidence must not expose:

- raw CI/DI
- raw ID data
- payment card data
- provider secrets
- raw webhook secret
- raw identity provider payload
- sensitive customer private data
- accusatory drunk label
- unnecessary staff private data

Evidence should use safe references and masked summaries.

---

## 39. Audit Rule

Audit is required for:

- refund approval
- refund rejection
- partial refund
- service refusal after payment
- chargeback response
- support escalation
- manager review
- manual POS correction
- payment/KDS reconciliation
- evidence packet update
- customer recovery decision

Audit must be append-only.

---

## 40. Admin Console Boundary

Future Admin Console may show:

- alcohol payment dispute count
- refund review count
- chargeback risk count
- service refusal after payment count
- duplicate payment risk
- POS reconciliation required
- KDS reconciliation required
- evidence completeness
- customer recovery status

Admin Console must not directly issue refund without payment authority workflow.

Admin Console must not expose raw payment or identity secrets.

---

## 41. Training Boundary

Staff training must later cover:

- explaining payment review calmly
- separating payment and service state
- handling refund before preparation
- escalating refund after service
- recognizing chargeback risk
- preserving evidence
- avoiding blame language
- involving manager
- using support escalation
- protecting customer dignity

Alcohol payment disputes require training before activation.

---

## 42. Commercial Boundary

Alcohol payment/refund support may affect:

- high-risk operation package
- payment provider cost
- support tier
- incident handling cost
- staff training fee
- legal/compliance setup
- refund/chargeback support workload
- night operation premium
- provider gateway scope

Alcohol payment risk should not be treated as ordinary payment support.

---

## 43. Legal/Compliance Handoff

Legal/compliance review may be needed for:

- refund after alcohol service
- service refusal after payment
- chargeback evidence
- adult verification failure after payment
- data retention
- customer communication
- consumer dispute handling
- delivery platform refund responsibility
- local alcohol sale rule
- record retention

This document does not provide legal conclusion.

---

## 44. Implementation Deferral Boundary

This document does not authorize:

- alcohol payment flow implementation
- refund automation
- chargeback automation
- POS reconciliation implementation
- payment provider integration
- Admin Console refund action
- support refund override
- delivery alcohol refund handling
- customer recovery automation
- legal dispute automation

Implementation requires separate readiness, legal, payment, and build approval.

---

## 45. Registers Recommendation

Recommended future files:

    docs/_index/
      Alcohol_Payment_Status_Register.md
      Alcohol_Refund_Status_Register.md
      Alcohol_Dispute_Register.md
      Alcohol_Chargeback_Risk_Register.md
      Alcohol_Customer_Recovery_Register.md
      Alcohol_Payment_Evidence_Register.md
      Alcohol_Payment_Incident_Register.md
      POS_Reconciliation_Register.md
      KDS_Reconciliation_Register.md

This document only recommends these files.

It does not create them.

---

## 46. Anti-Patterns

The following are prohibited:

- treating payment success as legal service approval
- refunding without checking KDS state
- refusing refund without checking service state
- hiding verification failure after payment
- blaming customer for mistouch without review
- ignoring duplicate payment risk
- merging cancel and refund into one state
- deleting evidence after refund
- allowing support to rewrite payment truth
- letting Admin Console issue direct refund without authority
- ignoring partial settlement context
- treating chargeback risk as ordinary note
- exposing raw identity or payment data in evidence
- deciding refund from payment provider status alone

---

## 47. Non-Goals

This document does not define:

- final refund policy
- final chargeback response procedure
- final payment API
- final POS settlement implementation
- final accounting treatment
- final legal standard
- final customer service script
- final Admin Console refund UI
- final provider integration

Those belong to later legal, finance, payment, support, UI, and implementation planning.

---

## 48. Readiness Check

This document is ready when the project can answer:

1. What is alcohol payment boundary?
2. What alcohol payment status values exist?
3. What payment before verification rule applies?
4. What verification before payment rule applies?
5. What payment after KDS release rule applies?
6. What payment uncertainty rule applies?
7. What duplicate payment risk rule applies?
8. What is alcohol refund boundary?
9. When may refund before preparation be allowed?
10. Why does refund after preparation require review?
11. Why is refund after service high-risk?
12. What service refusal after payment rule applies?
13. What refund status values exist?
14. Why are cancellation and refund separate?
15. What does alcohol dispute mean?
16. What dispute status values exist?
17. What does chargeback risk mean?
18. What chargeback risk statuses exist?
19. What evidence timeline rule applies?
20. What fields should payment evidence packet include?
21. What does customer recovery mean?
22. What recovery status values exist?
23. What customer communication rule applies?
24. What staff communication rule applies?
25. What support boundary applies?
26. What manager review boundary applies?
27. What provider boundary applies?
28. What POS reconciliation boundary applies?
29. What KDS reconciliation boundary applies?
30. What partial settlement boundary applies?
31. What delivery platform boundary applies?
32. When should alcohol payment incident be created?
33. What incident status values exist?
34. What evidence masking rule applies?
35. What audit rule applies?
36. What Admin Console boundary applies?
37. What training boundary applies?
38. What commercial boundary applies?
39. What legal/compliance handoff is needed?
40. What implementation deferral boundary applies?
41. What anti-patterns are prohibited?

If these questions cannot be answered, alcohol payment, refund, dispute, chargeback, and recovery evidence planning is incomplete.

---

## 49. Conclusion

Alcohol payment disputes are harsh because payment, verification, KDS, service, customer intent, partial settlement, and legal risk can diverge.

The safe alcohol payment recovery flow is:

    payment event
        -> verification and KDS timeline review
        -> service and staff approval review
        -> cancel/refund/dispute classification
        -> customer recovery if needed
        -> chargeback risk preservation
        -> support, manager, provider, POS, or KDS reconciliation
        -> evidence and audit
        -> legal/compliance handoff if needed

This document ensures that alcohol-related payment, refund, cancellation, dispute, chargeback, and recovery are handled with conservative evidence and authority boundaries before implementation.
