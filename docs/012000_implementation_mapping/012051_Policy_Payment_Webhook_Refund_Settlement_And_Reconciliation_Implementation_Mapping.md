# 012051_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping.md

## Purpose

This document defines the implementation mapping policy for payment webhook handling, payment authority, refund authority, settlement linkage, reconciliation, payment uncertainty, audit evidence, and tenant/store context validation in the Yoonsul Wait/Order Handoff project.

Payment is a high-risk runtime boundary.

Customer order flow, POS confirmation, KDS visibility, refund handling, support response, owner settlement, and degraded recovery may all observe payment state, but they must not all own payment truth.

Therefore, payment implementation must be mapped before coding.

This document does not implement payment gateway integration, webhook handlers, refund APIs, settlement tables, reconciliation jobs, or provider-specific code.

It defines the constraints that future payment implementation must obey.

---

## 2. Scope

This mapping applies to:

- payment initiation
- payment confirmation
- payment failure
- payment cancellation
- payment webhook handling
- webhook signature validation
- webhook idempotency
- webhook replay detection
- payment state mapping
- refund request
- refund approval
- refund submission
- refund completion
- partial refund
- refund correction
- payment uncertainty
- reconciliation
- settlement linkage
- owner settlement visibility
- support payment visibility
- POS payment visibility
- KDS payment visibility restriction
- audit mapping
- evidence requirements
- testing requirements
- implementation blockers

This document does not define final provider, schema, or code.

---

## 3. Core Principle

Payment truth belongs to the payment boundary.

The project must follow this rule:

> POS, KDS, support, customer UI, and agent runtime may observe payment status only through controlled views. They must not become payment truth owners.

Payment mutation requires explicit payment authority, provider verification, idempotency, audit, and reconciliation path.

---

## 4. Related Policy Documents

This mapping depends on:

- 04471_Policy_Financial_Grade_Security_Baseline_And_Secret_Coding
- 04491_Policy_Degraded_Security_Recovery_And_Evidence_Boundary
- 04501_Policy_Secret_Rotation_Exposure_Response_And_Secure_Configuration
- 04531_Policy_Security_Audit_Event_Immutability_And_Tamper_Evidence
- 04551_Policy_Payment_Boundary_Refund_Correction_And_Settlement_Security
- 04561_Policy_Tenant_Store_Boundary_Isolation_And_Cross_Context_Access
- 04581_Policy_Log_Masking_Error_Disclosure_And_Diagnostic_Data
- 04591_Policy_Webhook_Signature_Idempotency_Replay_And_External_Integration_Security
- 04601_Policy_Data_Export_Report_Benchmark_And_External_Sharing_Security
- 04621_Policy_Security_Incident_Response_Severity_Classification_And_Recovery_Governance
- 04631_Policy_Compliance_Readiness_Evidence_Control_And_Financial_Grade_Security_Review
- 04661_Policy_Security_Testing_Abuse_Case_Threat_Modeling_And_Verification
- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping

Future payment implementation must inherit these constraints.

---

## 5. Affected Runtime

This mapping affects:

- Customer Web Runtime
- Customer Mobile Runtime
- POS Runtime
- Payment Runtime
- Refund Runtime
- Settlement Runtime
- Support Runtime
- Owner Runtime
- HQ Admin Runtime
- Audit Runtime
- Export Runtime
- Webhook Runtime
- Incident Runtime
- POS/KDS Bridge Runtime
- KDS Runtime
- AI Analytics Runtime

Payment Runtime is the authority boundary.

Other runtimes may receive scoped visibility or derived status only.

---

## 6. Payment Authority Mapping

Payment authority includes:

- initiating payment request
- receiving verified provider callback
- confirming payment
- marking payment failed
- marking payment cancelled
- marking payment uncertain
- linking payment to order
- linking payment to POS transaction
- opening reconciliation
- correcting payment state through approved process
- creating payment audit
- producing payment evidence

Payment authority does not belong to:

- KDS Runtime
- AI Runtime
- ordinary support view
- customer UI alone
- local agent alone
- bridge relay alone
- unverified webhook payload

Payment authority must be server-side.

---

## 7. Refund Authority Mapping

Refund authority includes:

- refund eligibility check
- refund request creation
- refund approval
- refund denial
- refund submission to provider
- refund provider callback verification
- refund completion
- partial refund completion
- refund correction
- refund evidence creation
- refund audit event creation

Refund authority must not be implied by:

- support note
- customer complaint
- KDS delay
- agent recommendation
- owner dashboard view
- POS/KDS mismatch alone

Refund must follow authority, reason, audit, and evidence requirements.

---

## 8. Settlement Authority Mapping

Settlement authority includes:

- settlement calculation
- payout allocation
- settlement hold
- settlement release
- fee adjustment
- owner settlement visibility
- HQ settlement review
- settlement correction
- reconciliation linkage
- settlement evidence creation

Settlement authority must be separate from payment confirmation.

A payment can be confirmed but settlement may still be pending, delayed, held, corrected, or reconciled.

---

## 9. Payment State Mapping

Recommended payment states:

- `PAYMENT_NOT_STARTED`
- `PAYMENT_INITIATED`
- `PAYMENT_PENDING`
- `PAYMENT_CONFIRMED`
- `PAYMENT_FAILED`
- `PAYMENT_CANCELLED`
- `PAYMENT_EXPIRED`
- `PAYMENT_PROVIDER_UNCERTAIN`
- `PAYMENT_DEGRADED_PENDING`
- `PAYMENT_RECONCILIATION_REQUIRED`
- `PAYMENT_CORRECTION_REQUIRED`
- `PAYMENT_REVIEW_REQUIRED`

Final state naming may change later.

State ownership must remain clear.

---

## 10. Refund State Mapping

Recommended refund states:

- `REFUND_NOT_REQUESTED`
- `REFUND_REQUESTED`
- `REFUND_ELIGIBILITY_REVIEW`
- `REFUND_APPROVAL_REQUIRED`
- `REFUND_APPROVED`
- `REFUND_DENIED`
- `REFUND_SUBMITTED`
- `REFUND_PENDING`
- `REFUND_COMPLETED`
- `PARTIAL_REFUND_COMPLETED`
- `REFUND_FAILED`
- `REFUND_CANCELLED`
- `REFUND_CORRECTION_REQUIRED`
- `REFUND_RECONCILIATION_REQUIRED`
- `REFUND_REVIEW_REQUIRED`

Refund state must not be changed by KDS, AI, or ordinary support view.

---

## 11. Settlement State Mapping

Recommended settlement states:

- `SETTLEMENT_NOT_STARTED`
- `SETTLEMENT_PENDING`
- `SETTLEMENT_CALCULATED`
- `SETTLEMENT_HELD`
- `SETTLEMENT_DELAYED`
- `SETTLEMENT_RELEASED`
- `SETTLEMENT_PARTIAL`
- `SETTLEMENT_ADJUSTMENT_REQUIRED`
- `SETTLEMENT_RECONCILIATION_REQUIRED`
- `SETTLEMENT_CORRECTION_REQUIRED`
- `SETTLEMENT_CLOSED`

Settlement state must link to payment and order records through controlled references.

---

## 12. Required Payment Context

Payment-related records should include:

- tenant_id
- store_id where applicable
- order_id
- table_session_id where applicable
- customer_session_id where applicable
- payment_id
- payment_provider
- payment_provider_event_id where applicable
- payment_reference
- pos_order_reference where applicable
- pos_transaction_reference where applicable
- request_id
- correlation_id
- idempotency_key
- payment_state
- amount
- currency
- created_at
- updated_at
- confirmed_at where applicable
- failed_at where applicable
- cancelled_at where applicable
- reconciliation_status
- audit_event_id reference where applicable

Sensitive provider details must be minimized.

---

## 13. Required Refund Context

Refund-related records should include:

- tenant_id
- store_id where applicable
- refund_id
- original_payment_id
- order_id
- refund_amount
- refund_reason
- refund_state
- requested_by
- requested_at
- approved_by where applicable
- approved_at where applicable
- provider_refund_reference
- provider_event_id where applicable
- idempotency_key
- support_case_id where applicable
- incident_id where applicable
- audit_event_id
- evidence_id where applicable

Refund must link back to original payment.

A refund without original payment context is invalid.

---

## 14. Webhook Runtime Boundary

Webhook Runtime receives external provider events.

Webhook Runtime must:

- authenticate provider event
- verify signature
- verify timestamp freshness
- validate provider identity
- validate event type
- validate event id
- apply idempotency
- detect replay
- map provider event to internal payment/refund record
- validate tenant/store context
- quarantine invalid events
- create audit event
- update payment/refund state only after verification

Webhook payload is untrusted until verified.

---

## 15. Webhook Signature Mapping

Webhook signature verification must define:

- provider-specific signature header
- signing secret source
- timestamp tolerance
- payload canonicalization rule
- verification failure behavior
- secret rotation behavior
- audit event for failure
- quarantine behavior
- no-state-change rule on failure

Signature secret must never be exposed to frontend or logs.

---

## 16. Webhook Idempotency Mapping

Webhook idempotency must prevent duplicate state changes.

Idempotency may use:

- provider event id
- provider payment reference
- event type
- tenant_id
- store_id
- payment_id
- refund_id
- provider timestamp
- internal idempotency key

Duplicate webhook should not duplicate:

- payment confirmation
- refund completion
- settlement trigger
- audit mutation
- customer notification
- owner settlement effect

Duplicate receipt may still be recorded safely.

---

## 17. Webhook Replay Detection

Replay detection should consider:

- provider event id already processed
- timestamp too old
- signature timestamp outside tolerance
- event sequence mismatch
- same payload delivered after final state
- event source mismatch
- tenant/store mapping mismatch
- previously quarantined event repeated

Replay should be rejected, ignored safely, quarantined, or marked for review depending on risk.

Replay must not silently mutate final payment truth.

---

## 18. Provider Event Mapping

Provider events must be mapped into internal event types.

Examples:

- payment authorized
- payment captured
- payment confirmed
- payment failed
- payment cancelled
- payment expired
- refund created
- refund pending
- refund completed
- refund failed
- chargeback opened
- dispute opened
- settlement created
- settlement paid
- provider error

Provider-specific naming must not leak into business logic without mapping.

---

## 19. Payment Initiation Mapping

Payment initiation must define:

- actor or runtime requesting payment
- tenant_id
- store_id
- order_id
- amount
- currency
- payment method class
- idempotency key
- provider request reference
- customer session reference
- audit event
- failure behavior
- expiration behavior
- return or callback path

Payment initiation must not expose provider secret to customer runtime.

---

## 20. Payment Confirmation Mapping

Payment confirmation must require:

- verified provider event
- matching payment reference
- matching amount
- matching tenant/store/order context
- valid state transition
- idempotency check
- audit event
- customer visibility update
- POS visibility update
- settlement candidate creation where applicable

Payment confirmation must not be based only on client-side success page.

---

## 21. Payment Failure Mapping

Payment failure must define:

- failure source
- verified provider event where applicable
- failure reason class
- customer-safe message
- staff-visible message where applicable
- retry eligibility
- order impact
- POS visibility
- KDS visibility restriction
- audit event
- support case trigger where applicable

Failure reason must avoid exposing raw provider payload.

---

## 22. Payment Cancellation Mapping

Payment cancellation must define:

- who may request cancellation
- when cancellation is allowed
- provider cancellation requirement
- order state dependency
- POS state dependency
- KDS ticket dependency
- refund fallback if capture already occurred
- audit event
- evidence requirement where applicable

Cancellation must not bypass refund governance.

---

## 23. Payment Uncertainty Mapping

Payment uncertainty occurs when payment truth cannot be confirmed safely.

Examples:

- provider callback delayed
- webhook signature failed
- provider timeout
- POS payment state mismatch
- customer success page returned but provider not confirmed
- duplicate event conflict
- degraded operation
- local cache mismatch
- partial provider outage

Uncertainty state should be visible to authorized staff/support but not treated as confirmation.

---

## 24. Payment Reconciliation Mapping

Reconciliation must define:

- reconciliation trigger
- reconciliation source
- provider lookup authority
- POS lookup authority
- internal payment record
- mismatch type
- reconciliation result
- correction request
- audit event
- evidence packet
- support visibility
- owner visibility where applicable

Reconciliation must append corrections.

It must not silently overwrite payment history.

---

## 25. Payment Correction Mapping

Payment correction must define:

- original payment state
- corrected payment state
- reason
- evidence
- approver where required
- actor
- audit event
- customer impact
- POS impact
- settlement impact
- support note
- incident link where applicable

Correction must be append-only.

Original payment event must remain traceable.

---

## 26. Refund Request Mapping

Refund request must define:

- requester
- reason
- original payment
- order status
- KDS status where relevant
- service failure link where relevant
- support case link where relevant
- amount requested
- full or partial refund flag
- eligibility status
- audit event

Refund request is not refund approval.

---

## 27. Refund Approval Mapping

Refund approval must define:

- approver role
- approval scope
- amount limit
- reason
- policy basis
- customer communication requirement
- evidence requirement
- audit event
- expiration if approval not executed
- escalation path

Refund approval must not be performed by AI recommendation alone.

---

## 28. Refund Submission Mapping

Refund submission to provider must define:

- original payment reference
- refund amount
- idempotency key
- provider refund request reference
- submission actor or service
- provider response
- refund pending state
- audit event
- retry behavior
- failure behavior

Refund submission must be idempotent.

---

## 29. Refund Completion Mapping

Refund completion must require:

- verified provider event or provider lookup
- matching refund reference
- matching original payment
- matching amount
- valid refund state transition
- audit event
- customer visibility update
- support visibility update
- settlement impact update where applicable

Refund completion must not be assumed from request submission alone.

---

## 30. Partial Refund Mapping

Partial refund mapping must define:

- original payment amount
- refundable remaining amount
- requested partial amount
- reason
- approval requirement
- provider partial refund support
- settlement impact
- customer communication
- audit event
- cumulative refund check

Partial refund must not exceed original paid amount.

---

## 31. Chargeback And Dispute Mapping

If provider supports chargebacks or disputes, mapping should define:

- dispute event source
- affected payment
- affected order
- evidence packet
- support case
- owner visibility
- settlement hold
- response deadline
- audit event
- incident link where applicable

Chargeback is not ordinary refund.

It requires separate handling.

---

## 32. Settlement Linkage Mapping

Settlement must link:

- payment
- refund
- partial refund
- fee
- store
- tenant
- owner
- settlement period
- payout reference
- reconciliation status
- adjustment reason
- audit event
- evidence where applicable

Settlement must be derived from verified payment/refund records.

---

## 33. Settlement Hold Mapping

Settlement may be held when:

- payment uncertain
- refund pending
- dispute opened
- provider mismatch
- POS mismatch
- suspected fraud
- support incident unresolved
- degraded recovery unresolved
- reconciliation required

Settlement hold must be visible to authorized owner/HQ roles with safe explanation.

---

## 34. POS Visibility Mapping

POS may see payment status needed for transaction flow.

Allowed POS visibility:

- initiated
- pending
- confirmed
- failed
- cancelled
- refund requested
- refund pending
- refunded
- reconciliation required

POS visibility does not automatically grant provider mutation authority.

---

## 35. KDS Visibility Mapping

KDS may see only operational payment signals when needed.

Allowed KDS visibility may include:

- payment confirmed
- payment pending
- payment failed
- payment review required

KDS must not see:

- payment tokens
- provider payload
- settlement details
- refund authority controls
- raw payment identity
- customer identity linkage
- provider secret

KDS must never mutate payment or refund state.

---

## 36. Support Visibility Mapping

Support payment visibility must be case-scoped.

Support may see:

- masked payment reference
- payment status
- refund status
- order linkage
- customer-safe failure reason
- reconciliation status
- evidence packet reference
- communication history

Support must not see:

- payment token
- card data
- provider secret
- raw webhook payload
- unrestricted settlement data
- unrelated customer payment history

Unmasking requires approval and audit where applicable.

---

## 37. Owner Visibility Mapping

Owner may see payment and settlement summaries scoped to authorized stores.

Owner may see:

- sales summary
- payment confirmed amount
- refund summary
- settlement pending
- settlement released
- settlement held reason class
- reconciliation required indicator

Owner must not automatically see:

- raw provider payload
- payment secrets
- raw CI / DI
- unrelated tenant data
- unrestricted customer identity
- support internal notes

---

## 38. Customer Visibility Mapping

Customer may see:

- payment initiated
- payment pending
- payment confirmed
- payment failed
- payment cancelled
- refund requested
- refund pending
- refund completed
- refund denied where appropriate
- customer-safe reason

Customer must not see:

- provider internal payload
- internal reconciliation detail
- staff notes
- risk scoring
- settlement data
- audit internals

Customer-facing messages must be safe and understandable.

---

## 39. AI Payment Boundary Mapping

AI may:

- classify payment issue type
- summarize support case
- recommend reconciliation review
- detect mismatch pattern
- suggest likely customer-facing explanation
- identify refund policy candidate

AI must not:

- confirm payment
- approve refund
- submit refund
- change settlement
- access raw payment secrets
- access raw CI / DI
- generate provider API calls
- close reconciliation as final authority

AI output is recommendation only.

---

## 40. Degraded Payment Mapping

During degraded mode:

- payment truth must not be guessed
- local payment status may be provisional
- provider confirmation may be delayed
- POS payment mismatch may be marked
- KDS may receive limited operational visibility
- refund should generally require central verification
- settlement should wait for reconciliation
- audit and evidence must record uncertainty
- customer messaging must avoid false confirmation

Degraded mode is not payment authority bypass.

---

## 41. Webhook Quarantine Mapping

Webhook events must be quarantined when:

- signature invalid
- timestamp expired
- provider unknown
- event id duplicate with conflicting payload
- tenant/store mapping fails
- payment reference unknown
- amount mismatch
- state transition invalid
- refund reference mismatch
- payload malformed
- event attempts unauthorized mutation

Quarantine must create audit and review path.

---

## 42. Audit Mapping

Payment audit events should include:

- payment initiated
- payment provider request created
- webhook received
- webhook signature verified
- webhook signature failed
- webhook duplicate detected
- webhook replay detected
- payment confirmed
- payment failed
- payment cancelled
- payment uncertainty marked
- reconciliation opened
- correction requested
- correction approved
- refund requested
- refund approved
- refund denied
- refund submitted
- refund completed
- refund failed
- settlement calculated
- settlement held
- settlement released
- payment-sensitive view accessed

Audit must avoid raw secrets and raw provider payload.

---

## 43. Masking Mapping

Payment masking must apply to:

- payment reference
- provider reference
- refund reference
- settlement reference
- customer identity
- customer phone/email
- support case payment detail
- export payment detail
- audit payment detail
- logs and errors

Never expose:

- card data
- payment token
- provider secret
- webhook signing secret
- raw authorization header
- raw CI / DI
- production `.env`

---

## 44. Error Handling Mapping

Payment errors must be safe by audience.

Customer-facing examples:

- "Payment could not be completed."
- "Payment confirmation is delayed."
- "Refund request is under review."
- "Refund has been completed."

Staff-facing examples:

- "Payment status requires review."
- "Refund approval is required."
- "Payment reconciliation is required."

Internal diagnostic may include masked references.

Errors must not expose provider secrets or raw payload.

---

## 45. Export Mapping

Payment export is high-risk.

Export must define:

- export authority
- purpose
- tenant/store scope
- period
- fields
- masking
- approval where needed
- audit
- retention
- secure delivery
- revocation or expiration where possible

View authority must not imply export authority.

---

## 46. Evidence Packet Mapping

Payment evidence packet may include:

- payment event references
- provider event references
- webhook verification result
- POS reference
- order reference
- refund references
- reconciliation notes
- audit events
- masked customer reference
- mismatch summary
- correction approval
- settlement impact

Evidence packet must not store provider secrets or payment tokens.

---

## 47. Testing Requirements

Future tests must include:

- client success page alone cannot confirm payment
- valid webhook confirms payment
- invalid signature webhook is rejected
- duplicate webhook does not duplicate state change
- replayed webhook does not silently mutate final state
- webhook with wrong tenant/store is rejected
- amount mismatch is quarantined
- refund request does not equal refund approval
- refund submission is idempotent
- refund completion requires provider verification
- partial refund cannot exceed paid amount
- KDS cannot mutate payment state
- support cannot approve refund without authority
- owner cannot access unrelated store payment data
- export requires separate authority
- payment audit events are created
- logs do not expose secrets or raw CI / DI
- degraded payment uncertainty does not become confirmed payment

Testing must include abuse cases.

---

## 48. Evidence Requirements

Evidence must prove:

- payment authority boundary exists
- webhook signature verification exists
- webhook idempotency exists
- replay detection exists
- invalid webhook quarantine exists
- payment state transitions are controlled
- refund approval is separate from request
- refund submission is idempotent
- refund completion is provider-verified
- KDS cannot mutate payment
- support access is case-scoped
- owner access is store-scoped
- settlement is linked to verified payment/refund
- payment uncertainty is represented
- reconciliation is append-only
- audit exists for high-risk payment actions
- masking prevents secret and raw identity exposure

Evidence must be reviewable without leaking sensitive payment data.

---

## 49. Implementation Blockers

Implementation must be blocked if:

- payment authority is unclear
- refund authority is unclear
- settlement authority is unclear
- payment states are undefined
- refund states are undefined
- webhook signature verification is undefined
- webhook idempotency is undefined
- replay detection is undefined
- provider event mapping is undefined
- payment confirmation can rely on client-side result
- refund request can become refund approval automatically
- KDS can mutate payment
- support can approve refund without authority
- settlement can use unverified payment state
- payment uncertainty is not represented
- reconciliation correction is not append-only
- audit mapping is missing
- masking is missing
- tests are missing

These blockers must be added to the implementation blocker register.

---

## 50. Mapping Status

Recommended status for this mapping:

- `DRAFT`
- `POLICY_LINKED`
- `RUNTIME_DEFINED`
- `AUTHORITY_MAPPED`
- `STATE_MAPPED`
- `WEBHOOK_MAPPED`
- `IDEMPOTENCY_MAPPED`
- `REPLAY_MAPPED`
- `REFUND_MAPPED`
- `SETTLEMENT_MAPPED`
- `RECONCILIATION_MAPPED`
- `AUDIT_MAPPED`
- `MASKING_MAPPED`
- `TEST_MAPPED`
- `BLOCKED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`

This document starts as `DRAFT`.

It becomes implementation-ready only after detailed provider selection, schema mapping, webhook mapping, refund workflow mapping, settlement mapping, and test catalogs are completed.

---

## 51. Non-Goals

This document does not define:

- final payment provider
- final payment gateway code
- final webhook handler
- final refund API
- final settlement schema
- final reconciliation job
- final provider credential storage
- final POS payment adapter
- final customer payment UI
- final owner settlement dashboard
- final automated test code
- final production deployment

Those belong to later controlled implementation phase.

---

## 52. Readiness Check

This mapping is ready when the project can answer:

1. Who owns payment truth?
2. Who may observe payment status?
3. What does refund authority include?
4. What does settlement authority include?
5. What payment states exist?
6. What refund states exist?
7. What settlement states exist?
8. What context is required for payment?
9. What context is required for refund?
10. How is webhook signature verified?
11. How is webhook idempotency handled?
12. How is webhook replay detected?
13. How are provider events mapped?
14. How is payment initiated?
15. How is payment confirmed?
16. Why can client success page not confirm payment?
17. How is payment failure handled?
18. How is payment uncertainty represented?
19. How is reconciliation performed?
20. How is correction appended?
21. How is refund requested?
22. How is refund approved?
23. How is refund submitted?
24. How is refund completion verified?
25. How is partial refund controlled?
26. How is settlement linked?
27. What can POS see?
28. What can KDS see?
29. What can support see?
30. What can owner see?
31. What can customer see?
32. What can AI do?
33. What must AI not do?
34. What changes during degraded mode?
35. What webhooks are quarantined?
36. What audit events are required?
37. What fields must be masked?
38. What tests prove payment safety?
39. What evidence proves payment control?
40. What blocks implementation?

If these questions cannot be answered, payment implementation mapping is incomplete.

---

## 53. Conclusion

Payment is one of the highest-risk boundaries in the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

- payment truth belongs to payment boundary
- refund authority is separate from support note or customer complaint
- settlement authority is separate from payment confirmation
- webhook payload is untrusted until verified
- client success page cannot confirm payment
- idempotency prevents duplicate payment/refund mutation
- replay must not silently mutate final truth
- invalid webhooks must be quarantined
- payment uncertainty must be represented
- reconciliation must append corrections
- KDS must not mutate payment
- support must be case-scoped
- owner visibility must be store-scoped
- customer messages must be safe
- AI may recommend but must not execute payment/refund authority
- degraded mode is not payment authority bypass
- audit must capture high-risk payment actions
- masking must protect provider secrets and raw identity
- export authority is separate from view authority
- implementation is blocked until webhook, refund, settlement, reconciliation, audit, masking, and tests are mapped

This mapping does not implement payment runtime.

It defines the constraints that future payment implementation must obey.