# 004551_Policy_Payment_Boundary_Refund_Correction_And_Settlement_Security

## 1. Purpose

This document defines the payment boundary, refund, correction, settlement, and financial security policy for the Yoonsul Wait/Order Handoff project.

The project connects waiting, order, POS, KDS, payment, refund, settlement, customer recovery, degraded operation, and audit evidence.

Payment-related state must be protected as a high-risk authority boundary.

A kitchen ticket, customer waiting session, bridge event, agent recommendation, or support note must never become final payment truth by itself.

---

## 2. Scope

This policy applies to:

- payment initiation
- payment confirmation
- payment failure
- payment cancellation
- refund trigger
- refund confirmation
- partial refund
- split settlement
- table split payment
- payment provider reference
- POS payment state
- order payment state
- customer compensation
- settlement allocation
- owner/store settlement
- delivery/platform fee settlement where applicable
- POS/KDS mismatch affecting payment
- degraded mode payment uncertainty
- payment correction
- payment audit
- payment support access

This document does not define the final payment gateway integration.

It defines the mandatory payment security boundary that later POS, order, settlement, refund, support, audit, and implementation documents must follow.

---

## 3. Core Principle

Payment authority must be separated from operational visibility.

The project must follow this rule:

> A runtime may observe payment status, but only an authorized payment boundary may create, confirm, correct, refund, or settle payment truth.

Payment state must not be rewritten by kitchen execution, bridge relay, agent recommendation, or support convenience.

---

## 4. Payment Authority Boundary

Payment authority may belong to approved payment runtime, POS runtime, or server-side payment orchestration layer.

Payment authority owns:

- payment request creation
- payment provider confirmation
- payment failure classification
- payment cancellation boundary
- refund request boundary
- refund confirmation boundary
- payment correction workflow
- settlement reference
- transaction audit
- payment reconciliation

Other runtimes may receive payment visibility only within their allowed scope.

---

## 5. POS Payment Authority

POS is transaction-sensitive and may own or synchronize accepted payment truth depending on final architecture.

POS may handle:

- accepted order
- payment handoff
- payment status
- receipt reference
- cancellation request
- refund request initiation where authorized
- settlement reference
- payment correction request

POS must not allow:

- unaudited payment correction
- unverified payment replay overwrite
- KDS-originated payment mutation
- Agent-originated refund execution
- support-note-based refund finalization
- degraded local cache becoming final payment truth without verification

POS payment actions must be auditable.

---

## 6. KDS Payment Boundary

KDS must not own payment truth.

KDS may see limited payment-related markers only when operationally needed.

Examples:

- paid marker
- unpaid marker
- payment pending marker
- payment verification pending marker
- cancellation pending marker
- order hold due to payment issue

KDS must not:

- approve payment
- cancel payment
- refund payment
- settle payment
- correct payment
- expose payment provider reference
- expose payment token
- expose customer payment identity

Kitchen execution is not payment authority.

---

## 7. Bridge Payment Boundary

Bridge runtime may relay payment-related state between systems where required.

Bridge may:

- validate payment event format
- transmit payment status marker
- queue delayed payment status
- detect mismatch
- report stale payment state
- create evidence
- request reconciliation

Bridge must not:

- create final payment truth
- silently correct payment state
- approve refund
- finalize settlement
- overwrite provider-confirmed state
- treat replay result as final correction
- expose payment secrets

Bridge is a passage and validation layer, not payment authority.

---

## 8. Agent Payment Boundary

Agent may support payment risk detection and operational guidance.

Agent may:

- detect payment mismatch
- detect delayed confirmation
- recommend reconciliation
- summarize refund evidence
- flag suspicious payment pattern
- estimate customer recovery priority
- recommend manual review

Agent must not:

- execute refund
- correct payment
- finalize settlement
- approve compensation
- close payment incident
- override POS/payment provider truth
- mutate financial records

AI recommendation is not payment authority.

---

## 9. Support Payment Boundary

Support may inspect scoped payment issue information.

Support may:

- view masked payment status
- view order payment marker
- view refund request status
- attach customer inquiry note
- attach evidence
- request escalation
- request refund review
- explain verified state to customer

Support must not directly perform high-risk payment mutation unless separately authorized.

High-risk actions include:

- refund execution
- payment correction
- settlement adjustment
- compensation approval
- transaction cancellation after payment
- payment provider configuration change

Support inquiry is not payment authority.

---

## 10. Payment State Classification

Payment state must be explicit.

Recommended payment states include:

- `PAYMENT_NOT_STARTED`
- `PAYMENT_INITIATED`
- `PAYMENT_PENDING`
- `PAYMENT_CONFIRMED`
- `PAYMENT_FAILED`
- `PAYMENT_CANCELLED`
- `PAYMENT_REFUND_REQUESTED`
- `PAYMENT_REFUND_PENDING`
- `PAYMENT_REFUNDED`
- `PAYMENT_PARTIALLY_REFUNDED`
- `PAYMENT_CORRECTION_REQUIRED`
- `PAYMENT_RECONCILIATION_REQUIRED`
- `PAYMENT_PROVIDER_UNCERTAIN`
- `PAYMENT_DEGRADED_PENDING`
- `PAYMENT_REVIEW_REQUIRED`

Uncertain payment state must not be displayed as final confirmation.

---

## 11. Payment Confirmation Policy

Payment confirmation must come from an approved source.

Approved sources may include:

- payment provider confirmation
- POS confirmed transaction record
- server-side verified payment result
- approved reconciliation record
- approved manual correction with evidence

Unapproved sources include:

- customer screenshot alone
- staff note alone
- KDS ticket state
- Agent recommendation
- bridge replay alone
- local cache alone
- support memo alone

Payment confirmation must be auditable.

---

## 12. Payment Failure Policy

Payment failure must be classified accurately.

Failure may include:

- customer cancelled payment
- payment provider declined
- payment timeout
- network failure
- duplicate payment risk
- provider status unknown
- POS confirmation missing
- order/payment mismatch
- degraded mode confirmation pending
- webhook delayed
- webhook signature failure

Payment failure must not automatically imply order cancellation unless policy allows and evidence supports it.

Uncertain payment failure must be marked for review.

---

## 13. Refund Policy

Refund is a high-risk financial action.

Refund requires:

- order reference
- payment reference
- customer reference where needed
- refund reason
- actor identity
- role authority
- refund amount
- full or partial refund classification
- evidence reference where applicable
- approval boundary where required
- payment provider confirmation
- audit event

Refund must not be triggered solely by:

- KDS delay state
- customer complaint without review
- Agent recommendation
- support note
- degraded local state
- replay output
- bridge mismatch

Refund execution must be controlled and auditable.

---

## 14. Partial Refund Policy

Partial refund requires stronger amount validation.

Partial refund must include:

- original payment amount
- proposed refund amount
- remaining paid amount
- refund reason
- calculation basis
- approval where required
- customer communication reference where applicable
- settlement impact review
- audit event

Partial refund must not create negative settlement or inconsistent accounting state.

Partial refund must preserve original transaction history.

---

## 15. Cancellation Policy

Cancellation must distinguish order cancellation and payment cancellation.

Order cancellation may affect:

- customer order state
- POS accepted order
- KDS ticket state
- inventory usage
- kitchen production
- customer communication
- payment state

Payment cancellation may affect:

- transaction state
- payment provider status
- receipt
- refund or void boundary
- settlement

Order cancellation must not automatically equal payment cancellation unless the payment boundary confirms it.

Payment cancellation must not erase order history.

---

## 16. Settlement Security Policy

Settlement is financial authority.

Settlement may include:

- store sales allocation
- HQ allocation
- franchise fee allocation
- delivery platform fee
- payment gateway fee
- refund deduction
- compensation deduction
- adjustment
- payout
- owner settlement report

Settlement must be based on verified payment and approved adjustment data.

Settlement must not be based on:

- unverified KDS completion
- unverified local cache
- support memo alone
- Agent recommendation
- replay output without approval
- provisional degraded state

Settlement adjustment must be auditable.

---

## 17. Split Payment And Shared Table Policy

A table may include multiple customers and multiple payments.

The system must not assume:

- one table equals one customer
- one order equals one payment
- one payment equals one customer
- one table session equals one account identity

Split payment must preserve:

- payment identity separation
- order item association where required
- table session boundary
- customer privacy
- refund traceability
- settlement traceability
- audit trail

Shared table convenience must not collapse payment identity boundaries.

---

## 18. Payment Identity Protection

Payment identity is sensitive.

The system must protect:

- payment provider reference
- payment method token
- refund reference
- transaction id
- receipt reference
- customer payment account linkage
- settlement reference

Payment identity must not be shown to:

- kitchen staff
- ordinary staff without need
- public customer pages beyond safe receipt information
- unrelated store users
- unrelated tenant users
- AI tools without minimization
- logs without masking

Payment identity leakage must be treated as a security incident.

---

## 19. Payment Secret Handling

Payment secrets are critical or high-risk secrets.

Payment secrets must:

- remain server-side
- never be placed in frontend code
- never be committed
- never be logged
- never be pasted into prompts
- never be included in screenshots
- be separated by environment
- be rotated if exposed
- be access-restricted
- be audited where possible

Payment webhook signing secrets must be protected and rotated if exposed.

---

## 20. Webhook Payment Verification Policy

Payment webhooks must be validated.

Webhook verification should include:

- trusted endpoint
- signing secret or equivalent verification
- timestamp or replay protection where applicable
- payment provider event id
- idempotency handling
- tenant/store mapping where applicable
- transaction reference validation
- duplicate event handling
- audit event

Invalid webhook must be rejected or quarantined.

Webhook failure must not silently mutate payment state.

---

## 21. Idempotency Policy

Payment mutation must be idempotent.

Idempotency is required for:

- payment initiation
- payment confirmation processing
- refund request
- payment cancellation
- payment correction
- settlement adjustment
- webhook processing
- retry processing

Duplicate requests must not create duplicate charges, duplicate refunds, or duplicate settlement adjustments.

Duplicate detection must be auditable.

---

## 22. Replay And Payment Correction

Replay must not mutate payment state.

Replay may support:

- reconstruction
- mismatch detection
- duplicate detection
- webhook delay review
- payment reconciliation evidence
- settlement verification

Replay must not:

- mark payment confirmed
- mark payment refunded
- create settlement adjustment
- erase failed payment
- overwrite provider result
- close payment incident

Replay-derived payment insight must create review or reconciliation event.

---

## 23. Degraded Mode Payment Policy

Degraded mode must be cautious around payment.

If payment state is uncertain during degraded operation, the system must mark:

- `PAYMENT_DEGRADED_PENDING`
- `PAYMENT_PROVIDER_UNCERTAIN`
- `PAYMENT_RECONCILIATION_REQUIRED`
- `PAYMENT_REVIEW_REQUIRED`

Degraded local state must not become final payment truth.

Customer and staff communication must avoid false certainty.

The system must not claim payment success, refund completion, or settlement correction unless verified.

---

## 24. Payment Reconciliation Policy

Payment reconciliation is required when states differ.

Reconciliation may be needed when:

- POS and provider differ
- order and payment differ
- payment webhook is delayed
- refund status is unclear
- degraded local state conflicts with central state
- duplicate payment risk exists
- split payment allocation is unclear
- settlement report conflicts with payment record

Reconciliation must include:

- source records
- mismatch description
- evidence reference
- proposed resolution
- actor or reviewer
- approval where required
- audit event

Reconciliation must not silently overwrite history.

---

## 25. Customer Communication Policy

Payment communication must be accurate.

Customer-facing messages may say:

- payment pending
- payment verification required
- refund requested
- refund processing
- refund completed when verified
- staff review required
- duplicate payment review in progress

Customer-facing messages must not say:

- paid when unverified
- refunded when unverified
- cancelled when payment state is uncertain
- compensation approved when unapproved
- settlement completed when irrelevant to customer

Payment trust requires accurate status language.

---

## 26. Staff Communication Policy

Staff-facing payment state must distinguish:

- confirmed
- pending
- failed
- uncertain
- degraded pending
- reconciliation required
- refund requested
- refund approved
- refund completed
- payment correction required

Staff must not be shown uncertain payment as confirmed.

Staff must know when manager, support, or HQ review is required.

---

## 27. Payment Audit Requirements

Audit is required for:

- payment initiation
- payment confirmation
- payment failure
- payment cancellation request
- payment cancellation confirmation
- refund request
- refund approval
- refund execution
- refund failure
- partial refund
- payment correction request
- payment correction approval
- settlement adjustment
- webhook received
- webhook rejected
- duplicate payment detection
- duplicate refund detection
- payment reconciliation request
- payment reconciliation completion
- degraded payment uncertainty
- payment support access
- payment identity unmasking
- payment secret rotation

Audit must include:

- actor where applicable
- tenant id
- store id
- order reference
- payment reference masked where needed
- action
- before state
- after state
- amount where applicable
- reason
- approval reference where applicable
- evidence reference where applicable
- timestamp
- result

Audit must not store payment secrets.

---

## 28. Payment Support Access

Payment support access must be scoped and masked.

Support may view:

- masked payment status
- order reference
- refund request state
- provider status marker where allowed
- reconciliation case
- customer communication note

Support must not view:

- payment secret
- webhook signing secret
- raw payment token
- full sensitive payment identity
- unrelated payment records

Support payment access must be case-based and audited.

---

## 29. Payment Export Policy

Payment-related export is security-sensitive.

Exports require:

- actor authority
- purpose
- tenant scope
- store scope where applicable
- masking rule
- approval where required
- secure delivery method
- audit event
- retention rule

Payment export must not include secrets.

Raw payment identity export must be exceptional and justified.

---

## 30. Secure Payment Checklist

Before implementation, confirm:

- Payment authority is separated from KDS.
- Payment authority is separated from Agent.
- Payment authority is separated from support notes.
- POS payment mutation is audited.
- Refund requires controlled workflow.
- Partial refund validates amount.
- Settlement uses verified payment data.
- Split payment preserves identity separation.
- Payment secrets remain server-side.
- Payment webhooks are verified.
- Payment mutation is idempotent.
- Replay cannot mutate payment state.
- Degraded payment uncertainty is marked.
- Payment reconciliation is append-only.
- Customer communication avoids false certainty.
- Staff communication distinguishes uncertain state.
- Payment support access is scoped.
- Payment identity is masked.
- Payment export is audited.
- Payment audit does not store secrets.

If any item fails, implementation must not proceed.

---

## 31. Non-Goals

This document does not define:

- final payment gateway
- final POS vendor integration
- final refund UI
- final settlement schema
- final split payment UI
- final webhook implementation
- final accounting integration
- final tax treatment
- final legal refund policy text
- final customer compensation rules
- final payout schedule

Those must be defined in later payment, POS, finance, legal, customer recovery, or implementation documents.

---

## 32. Readiness Check

This policy is ready when the project can answer:

1. Which runtime owns payment truth?
2. Can KDS mutate payment state?
3. Can Agent execute refund?
4. Can support execute payment correction?
5. What confirms payment success?
6. What happens when payment provider status is unknown?
7. How is refund approved?
8. How is partial refund calculated?
9. How is split payment traced?
10. How is payment identity protected?
11. Where are payment secrets stored?
12. How are payment webhooks verified?
13. How is duplicate payment prevented?
14. How is duplicate refund prevented?
15. How does replay handle payment mismatch?
16. How is degraded payment uncertainty shown?
17. How is payment reconciliation audited?
18. How is settlement protected from unverified data?
19. How is payment support access scoped?
20. How is payment export controlled?

If these questions cannot be answered, implementation must not proceed.

---

## 33. Conclusion

Payment is one of the highest-risk authority boundaries in the Yoonsul Wait/Order Handoff system.

The system connects customer order, POS transaction, KDS execution, payment confirmation, refund, settlement, degraded mode, support access, and audit evidence.

Therefore, the system must preserve the following rules:

- payment authority is separate from kitchen execution
- KDS cannot mutate payment truth
- Agent cannot execute refund
- Bridge cannot silently correct payment state
- Support inquiry is not payment authority
- refund requires controlled workflow
- settlement requires verified payment data
- replay is not payment mutation
- degraded payment state must be marked uncertain
- payment identity must be protected
- payment secrets must remain server-side
- payment actions must be idempotent
- payment correction must be auditable
- customer communication must avoid false certainty

A trustworthy operational system must not only take payments.

It must prove that every payment, refund, correction, and settlement action occurred under the right authority boundary.