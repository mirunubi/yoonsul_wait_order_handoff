# 005011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog

## 1. Purpose

This document defines the test catalog policy for payment initiation, payment confirmation, webhook signature validation, webhook idempotency, webhook replay detection, refund request, refund approval, refund submission, refund completion, partial refund, settlement linkage, payment uncertainty, reconciliation, correction lineage, audit, masking, export restriction, and evidence requirements in the Yoonsul Wait/Order Handoff project.

Payment is one of the highest-risk runtime boundaries.

If payment behavior is not tested, the system may confirm payment from an untrusted source, duplicate refunds, expose payment secrets, settle unverified transactions, allow KDS or support to mutate payment state, or hide provider uncertainty.

Therefore, payment, refund, settlement, webhook, and reconciliation behavior must have explicit positive tests, negative tests, abuse-case tests, idempotency tests, replay tests, masking tests, audit tests, evidence tests, and deployment gate tests before implementation is allowed.

This document does not implement payment provider tests, webhook handlers, refund APIs, settlement jobs, database tests, or automated test code.

It defines the test catalog that future implementation must satisfy.

---

## 2. Scope

This test catalog applies to:

- payment initiation
- payment pending state
- payment confirmation
- payment failure
- payment cancellation
- payment expiration
- provider webhook receipt
- webhook signature verification
- webhook timestamp freshness
- webhook idempotency
- webhook replay detection
- provider event mapping
- payment amount validation
- tenant/store validation
- refund request
- refund approval
- refund denial
- refund submission
- refund completion
- partial refund
- refund idempotency
- refund reconciliation
- settlement linkage
- settlement hold
- settlement release
- payment uncertainty
- payment correction
- support payment visibility
- owner settlement visibility
- KDS payment boundary
- AI payment boundary
- payment audit
- payment masking
- payment export restriction
- payment evidence packet
- deployment gate requirements
- implementation blockers

This document focuses on test catalog design, not payment implementation.

---

## 3. Core Principle

Payment truth must be verified, idempotent, scoped, auditable, and separate from operational visibility.

The project must follow this rule:

> Client success page is not payment confirmation. KDS visibility is not payment authority. Support note is not refund approval. Settlement must be derived from verified payment and refund records.

Tests must prove these boundaries under normal, duplicate, replayed, malformed, mismatched, and degraded conditions.

---

## 4. Source Mapping Documents

This test catalog verifies constraints from:

- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping
- 04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping
- 04891_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping
- 04911_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_And_Manual_Evidence_Implementation_Mapping
- 04921_Policy_Export_Report_Benchmark_External_Sharing_And_Data_Extraction_Implementation_Mapping
- 04931_Policy_AI_Analytics_Dataset_Minimization_Model_Output_And_Recommendation_Boundary_Implementation_Mapping
- 04951_Policy_Secure_Deployment_Environment_Separation_Release_Gate_And_Rollback_Implementation_Mapping
- 04971_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance
- 04981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog
- 04991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy
- 05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog

---

## 5. Affected Runtime

This test catalog affects:

- Payment Runtime
- Refund Runtime
- Settlement Runtime
- Webhook Runtime
- POS Runtime
- KDS Runtime
- POS/KDS Bridge Runtime
- Customer Runtime
- Support Runtime
- Owner Runtime
- HQ Admin Runtime
- Export Runtime
- AI Analytics Runtime
- Audit Runtime
- Incident Runtime
- Deployment Runtime
- Vendor Integration Runtime

Payment behavior must be tested as a financial runtime boundary, not as a simple status field.

---

## 6. Risk Categories

This catalog covers the following risk categories:

- unverified payment confirmation
- client-side payment spoofing
- invalid webhook acceptance
- duplicate webhook mutation
- replayed webhook mutation
- payment amount mismatch
- wrong tenant/store payment mutation
- refund request treated as approval
- duplicate refund submission
- refund completion without provider verification
- partial refund exceeding paid amount
- settlement based on unverified payment
- KDS payment mutation
- support refund overreach
- AI refund or payment authority overreach
- payment uncertainty hidden
- reconciliation overwrite
- payment secrets in logs/audit/export
- raw provider payload leakage
- unsafe customer payment message
- deployment without webhook/refund tests

Critical failures in these categories block implementation.

---

## 7. Test Data Setup Requirement

Future tests should include at least:

- Tenant A
- Tenant B
- Store A1
- Store A2
- Customer A
- Customer B
- Order A1
- Order A2
- Payment A1 pending
- Payment A1 confirmed
- Payment A1 failed
- Payment A1 uncertain
- Refund Request A1
- Refund Approved A1
- Refund Pending A1
- Partial Refund A1
- Settlement Period A
- Provider webhook valid event
- Provider webhook invalid signature event
- Provider webhook duplicate event
- Provider webhook replayed event
- Provider event with amount mismatch
- Provider event with wrong tenant/store mapping
- Support case for payment issue
- Owner settlement view
- KDS device with payment visibility only
- Audit event candidate
- Evidence packet candidate

Test data must include valid, invalid, duplicate, replayed, and mismatched provider events.

---

## 8. Test ID Naming Rule

Recommended test id format:

    TC-PAYMENT-[NUMBER]-[TYPE]

Examples:

    TC-PAYMENT-001-POSITIVE
    TC-PAYMENT-002-NEGATIVE
    TC-PAYMENT-003-WEBHOOK
    TC-PAYMENT-004-IDEMPOTENCY
    TC-PAYMENT-005-REPLAY
    TC-PAYMENT-006-REFUND
    TC-PAYMENT-007-SETTLEMENT
    TC-PAYMENT-008-MASKING
    TC-PAYMENT-009-AUDIT
    TC-PAYMENT-010-DEPLOY

Final test IDs may change later.

Traceability must remain stable.

---

## 9. Positive Tests

### TC-PAYMENT-001-POSITIVE: Payment Initiation Creates Pending Payment

Precondition:

- Customer order exists.
- Payment initiation request is valid.
- Tenant/store/order context is valid.

Action:

- Payment is initiated.

Expected result:

- Payment record is created in initiated or pending state.
- Payment idempotency key is recorded.
- Provider request reference is recorded where applicable.
- Audit event is created.
- No provider secret is exposed.

Evidence:

- payment record
- idempotency record
- audit event
- masking verification

---

### TC-PAYMENT-002-POSITIVE: Valid Provider Webhook Confirms Payment

Precondition:

- Payment is pending.
- Provider webhook is valid.
- Signature is valid.
- Amount and reference match.

Action:

- Webhook is processed.

Expected result:

- Payment moves to confirmed.
- Tenant/store/order context matches.
- Audit event is created.
- POS/customer visibility may update safely.
- Settlement candidate may be created where applicable.

Evidence:

- payment state transition
- webhook verification record
- audit event
- settlement candidate where applicable

---

### TC-PAYMENT-003-POSITIVE: Payment Failure Is Recorded Safely

Precondition:

- Payment is pending.
- Provider sends valid failed event.

Action:

- Failure webhook is processed.

Expected result:

- Payment moves to failed.
- Customer-safe failure message is available.
- Raw provider payload is not exposed.
- Audit event is created.

Evidence:

- payment failed state
- safe message sample
- audit event

---

### TC-PAYMENT-004-POSITIVE: Authorized Refund Approval Creates Approved State

Precondition:

- Refund request exists.
- Actor has refund approval authority.
- Original payment is confirmed.

Action:

- Refund is approved.

Expected result:

- Refund state becomes approved.
- Approval actor and reason are recorded.
- Refund audit event is created.
- Refund is not yet completed unless provider confirms.

Evidence:

- refund approval record
- audit event
- original payment reference

---

### TC-PAYMENT-005-POSITIVE: Verified Refund Completion Updates Refund State

Precondition:

- Refund was submitted to provider.
- Provider sends valid refund completed event.

Action:

- Refund completion webhook or provider verification is processed.

Expected result:

- Refund state becomes completed.
- Original payment refund amount is updated or linked.
- Settlement impact is marked.
- Audit event is created.

Evidence:

- refund completion record
- provider verification record
- settlement impact record
- audit event

---

## 10. Negative Tests

### TC-PAYMENT-006-NEGATIVE: Client Success Page Cannot Confirm Payment

Precondition:

- Customer returns from client-side success page.
- No verified provider confirmation exists.

Action:

- Client success callback attempts to mark payment confirmed.

Expected result:

- Payment is not confirmed.
- Payment remains pending or verification required.
- Audit or trace records unverified client success.

Failure severity:

- CRITICAL

Evidence:

- payment state unchanged
- verification required state
- audit or trace

---

### TC-PAYMENT-007-NEGATIVE: KDS Cannot Mutate Payment State

Precondition:

- KDS device is authenticated.
- Payment record exists.

Action:

- KDS attempts to confirm, fail, cancel, refund, or correct payment.

Expected result:

- Request is denied.
- Payment state remains unchanged.
- Authority violation audit is created.

Failure severity:

- CRITICAL

Evidence:

- denial response
- before/after payment state
- audit event

---

### TC-PAYMENT-008-NEGATIVE: Support Note Cannot Approve Refund

Precondition:

- Support agent writes note saying refund should be given.
- Refund request exists.

Action:

- System evaluates refund state.

Expected result:

- Refund is not approved by support note alone.
- Approval remains required.
- Audit or case note exists, but refund state does not become approved.

Failure severity:

- CRITICAL if refund approved automatically

Evidence:

- support note
- refund state unchanged
- approval requirement record

---

### TC-PAYMENT-009-NEGATIVE: Owner Cannot Refund Unrelated Store Payment

Precondition:

- Owner is authorized for Store A1.
- Payment belongs to Store A2.

Action:

- Owner attempts refund action on Store A2 payment.

Expected result:

- Request is denied.
- Payment and refund state remain unchanged.

Failure severity:

- CRITICAL

Evidence:

- denial result
- before/after state
- audit event where required

---

### TC-PAYMENT-010-NEGATIVE: AI Cannot Approve Refund Or Confirm Payment

Precondition:

- AI recommends refund or payment issue classification.

Action:

- AI output attempts to trigger refund approval or payment confirmation.

Expected result:

- Mutation is denied.
- AI output remains recommendation only.
- Audit or trace is created where required.

Failure severity:

- CRITICAL

Evidence:

- denied mutation
- AI recommendation record
- audit event

---

## 11. Webhook Signature Tests

### TC-PAYMENT-011-WEBHOOK: Valid Signature Is Accepted

Precondition:

- Provider webhook has valid signature and timestamp.
- Payment reference matches.

Action:

- Webhook is processed.

Expected result:

- Signature validation passes.
- Event is processed according to mapped event type.
- Audit event records verified webhook.

Evidence:

- signature verification record
- audit event

---

### TC-PAYMENT-012-WEBHOOK: Invalid Signature Is Rejected

Precondition:

- Webhook has invalid signature.

Action:

- Webhook is received.

Expected result:

- Webhook is rejected or quarantined.
- Payment state is unchanged.
- Audit event is created.
- Raw payload is not exposed in logs.

Failure severity:

- CRITICAL

Evidence:

- rejection or quarantine record
- payment state unchanged
- audit event
- log masking check

---

### TC-PAYMENT-013-WEBHOOK: Expired Timestamp Is Rejected

Precondition:

- Webhook signature may be valid but timestamp is outside tolerance.

Action:

- Webhook is processed.

Expected result:

- Webhook is rejected or quarantined.
- Payment state remains unchanged.
- Replay or stale event audit is created.

Failure severity:

- HIGH

Evidence:

- rejection record
- audit event

---

### TC-PAYMENT-014-WEBHOOK: Unknown Provider Event Type Is Quarantined

Precondition:

- Webhook event type is unknown or unmapped.

Action:

- Webhook is processed.

Expected result:

- Event is quarantined or rejected.
- No payment/refund mutation occurs.
- Audit event is created.

Failure severity:

- HIGH

Evidence:

- quarantine record
- audit event

---

## 12. Webhook Idempotency Tests

### TC-PAYMENT-015-IDEMPOTENCY: Duplicate Payment Confirmation Does Not Duplicate Mutation

Precondition:

- Payment was already confirmed by provider event.
- Same provider event arrives again.

Action:

- Duplicate webhook is processed.

Expected result:

- Payment remains confirmed.
- No duplicate settlement trigger is created.
- Duplicate detection trace or audit exists.

Failure severity:

- HIGH to CRITICAL if duplicate settlement occurs

Evidence:

- payment state
- settlement candidate count
- duplicate detection audit

---

### TC-PAYMENT-016-IDEMPOTENCY: Duplicate Refund Completion Does Not Duplicate Refund

Precondition:

- Refund completion was already processed.
- Same refund completion event arrives again.

Action:

- Duplicate refund webhook is processed.

Expected result:

- Refund remains completed once.
- Cumulative refund amount does not increase again.
- Duplicate detection is recorded.

Failure severity:

- CRITICAL if refund amount duplicates

Evidence:

- refund amount comparison
- duplicate detection record

---

### TC-PAYMENT-017-IDEMPOTENCY: Same Provider Event ID With Conflicting Payload Is Quarantined

Precondition:

- Provider event id was processed with amount X.
- New event uses same provider event id with amount Y.

Action:

- Conflicting webhook is processed.

Expected result:

- Event is quarantined.
- Payment state is not changed.
- Incident or review path may be triggered.

Failure severity:

- CRITICAL

Evidence:

- quarantine record
- audit event
- no mutation proof

---

## 13. Webhook Replay Tests

### TC-PAYMENT-018-REPLAY: Replayed Webhook Does Not Mutate Final Payment

Precondition:

- Payment is already finalized.
- Old webhook is replayed.

Action:

- Replayed webhook is processed.

Expected result:

- Final state is not silently mutated.
- Replay is detected or ignored safely.
- Audit event is created.

Failure severity:

- CRITICAL if final state changes incorrectly

Evidence:

- before/after state
- replay audit

---

### TC-PAYMENT-019-REPLAY: Replay With Expired Signature Timestamp Is Rejected

Precondition:

- Old webhook is resent with expired timestamp.

Action:

- Webhook is processed.

Expected result:

- Webhook is rejected.
- No mutation occurs.
- Audit event records replay or stale timestamp.

Failure severity:

- HIGH

Evidence:

- rejection record
- audit event

---

### TC-PAYMENT-020-REPLAY: Replay Cannot Convert Failed Payment To Confirmed Without Valid New Provider Proof

Precondition:

- Payment is failed.
- Old or manipulated confirmation event is replayed.

Action:

- Event is processed.

Expected result:

- Payment is not changed to confirmed unless valid provider proof and transition rules allow.
- Review or reconciliation may be required.

Failure severity:

- CRITICAL

Evidence:

- payment state unchanged
- reconciliation candidate where applicable

---

## 14. Amount And Reference Validation Tests

### TC-PAYMENT-021-VALIDATION: Amount Mismatch Is Quarantined

Precondition:

- Payment expected amount is 10,000.
- Provider event reports 9,000 or 11,000.

Action:

- Webhook is processed.

Expected result:

- Event is quarantined or reconciliation required.
- Payment is not confirmed as normal.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- quarantine record
- audit event

---

### TC-PAYMENT-022-VALIDATION: Wrong Payment Reference Is Rejected

Precondition:

- Provider event includes unknown or mismatched payment reference.

Action:

- Webhook is processed.

Expected result:

- Event is rejected or quarantined.
- No unrelated payment is mutated.

Failure severity:

- CRITICAL

Evidence:

- rejection record
- no mutation proof

---

### TC-PAYMENT-023-VALIDATION: Wrong Tenant Store Mapping Is Rejected

Precondition:

- Payment belongs to Tenant A Store A1.
- Webhook or mapped event attempts Tenant B or Store A2 context.

Action:

- Event is processed.

Expected result:

- Event is rejected or quarantined.
- Original payment state is unchanged unless correct context is verified.

Failure severity:

- CRITICAL

Evidence:

- rejection or quarantine record
- audit event

---

## 15. Refund Request And Approval Tests

### TC-PAYMENT-024-REFUND: Refund Request Does Not Equal Approval

Precondition:

- Customer or support creates refund request.

Action:

- Refund request is recorded.

Expected result:

- Refund state is requested or review required.
- Refund is not approved.
- Audit event is created.

Failure severity:

- CRITICAL if approval occurs automatically

Evidence:

- refund state
- audit event

---

### TC-PAYMENT-025-REFUND: Unauthorized Actor Cannot Approve Refund

Precondition:

- Refund request exists.
- Actor lacks refund approval authority.

Action:

- Actor attempts refund approval.

Expected result:

- Approval is denied.
- Refund state remains unchanged.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- denial result
- refund state unchanged
- audit event

---

### TC-PAYMENT-026-REFUND: Refund Approval Requires Reason

Precondition:

- Authorized approver attempts refund approval.

Action:

- Approval is submitted without required reason.

Expected result:

- Approval is denied or incomplete.
- Refund state does not become approved.

Failure severity:

- HIGH

Evidence:

- validation result
- refund state unchanged

---

### TC-PAYMENT-027-REFUND: Refund Denial Is Audited

Precondition:

- Refund request exists.

Action:

- Authorized actor denies refund with reason.

Expected result:

- Refund state becomes denied.
- Denial reason is recorded.
- Audit event is created.

Evidence:

- refund denial record
- audit event

---

## 16. Refund Submission And Completion Tests

### TC-PAYMENT-028-REFUND: Approved Refund Can Be Submitted To Provider

Precondition:

- Refund is approved.
- Original payment is confirmed.
- Refund amount is valid.

Action:

- Refund is submitted to provider.

Expected result:

- Refund state becomes submitted or pending.
- Provider refund reference is recorded.
- Audit event is created.

Evidence:

- refund submission record
- provider reference
- audit event

---

### TC-PAYMENT-029-REFUND: Refund Submission Is Idempotent

Precondition:

- Refund submission was already sent.
- Same submission is retried.

Action:

- Refund submission retry occurs.

Expected result:

- Provider submission is not duplicated logically.
- Refund state remains pending or previously completed.
- Idempotency trace exists.

Failure severity:

- CRITICAL if duplicate refund occurs

Evidence:

- idempotency record
- provider reference comparison

---

### TC-PAYMENT-030-REFUND: Refund Completion Requires Provider Verification

Precondition:

- Refund was submitted.
- No provider completion exists.

Action:

- Internal actor attempts to mark refund completed manually without authority.

Expected result:

- Completion is denied or review-required.
- Refund remains pending or review state.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- denial result
- refund state unchanged
- audit event

---

### TC-PAYMENT-031-REFUND: Refund Failed Event Is Recorded Safely

Precondition:

- Refund submitted.
- Provider sends valid refund failed event.

Action:

- Event is processed.

Expected result:

- Refund state becomes failed or review required.
- Customer-safe explanation is available.
- Audit event is created.

Evidence:

- refund failed state
- safe message
- audit event

---

## 17. Partial Refund Tests

### TC-PAYMENT-032-PARTIAL: Partial Refund Cannot Exceed Paid Amount

Precondition:

- Original payment amount is 10,000.
- Partial refund request is 12,000.

Action:

- Partial refund request is submitted.

Expected result:

- Request is denied.
- Refund state is not approved.
- Audit event is created where required.

Failure severity:

- CRITICAL

Evidence:

- denial result
- original payment amount
- refund request amount

---

### TC-PAYMENT-033-PARTIAL: Cumulative Partial Refund Cannot Exceed Paid Amount

Precondition:

- Original payment amount is 10,000.
- Prior partial refund is 6,000.
- New partial refund request is 5,000.

Action:

- New partial refund request is submitted.

Expected result:

- Request is denied or capped only if policy allows.
- Cumulative refund does not exceed paid amount.

Failure severity:

- CRITICAL

Evidence:

- cumulative refund calculation
- denial or review result

---

### TC-PAYMENT-034-PARTIAL: Valid Partial Refund Updates Settlement Impact

Precondition:

- Original payment confirmed.
- Partial refund approved and completed.

Action:

- Settlement linkage is evaluated.

Expected result:

- Settlement impact reflects partial refund.
- Audit event is created.
- Owner-facing summary is updated safely.

Evidence:

- settlement impact record
- audit event
- owner summary sample

---

## 18. Settlement Tests

### TC-PAYMENT-035-SETTLEMENT: Confirmed Payment Creates Settlement Candidate

Precondition:

- Payment is verified and confirmed.

Action:

- Settlement candidate logic runs.

Expected result:

- Settlement candidate is created or updated.
- Candidate links to verified payment.
- Audit event exists where required.

Evidence:

- settlement candidate
- payment reference
- audit event

---

### TC-PAYMENT-036-SETTLEMENT: Unverified Payment Does Not Settle

Precondition:

- Payment is pending or uncertain.

Action:

- Settlement calculation runs.

Expected result:

- Payment is excluded, held, or marked reconciliation required.
- Settlement is not released based on unverified payment.

Failure severity:

- CRITICAL

Evidence:

- settlement hold/exclusion record
- payment state proof

---

### TC-PAYMENT-037-SETTLEMENT: Refund Updates Settlement Correctly

Precondition:

- Payment was included in settlement candidate.
- Refund is completed.

Action:

- Settlement recalculation or adjustment runs.

Expected result:

- Settlement reflects refund.
- Adjustment lineage is traceable.
- Audit event is created.

Failure severity:

- HIGH

Evidence:

- settlement adjustment
- refund reference
- audit event

---

### TC-PAYMENT-038-SETTLEMENT: Settlement Hold Is Visible To Authorized Owner

Precondition:

- Settlement is held due to payment uncertainty or dispute.

Action:

- Authorized owner views settlement summary.

Expected result:

- Owner sees safe hold indicator and reason class.
- Raw provider data or secrets are not visible.

Evidence:

- owner view sample
- masking verification

---

## 19. Reconciliation Tests

### TC-PAYMENT-039-RECONCILIATION: Payment Uncertainty Opens Reconciliation

Precondition:

- Provider callback delayed or conflicting.
- Payment cannot be confirmed safely.

Action:

- Reconciliation trigger runs.

Expected result:

- Payment enters reconciliation required or provider uncertain state.
- Reconciliation case is created.
- Audit event is created.

Evidence:

- payment uncertainty state
- reconciliation case
- audit event

---

### TC-PAYMENT-040-RECONCILIATION: Reconciliation Correction Is Append-Only

Precondition:

- Payment state requires correction after provider verification.

Action:

- Authorized correction is applied.

Expected result:

- Original state remains traceable.
- Correction event is appended.
- Audit event links original and corrected state.

Failure severity:

- CRITICAL if history overwritten

Evidence:

- original state
- correction event
- audit lineage

---

### TC-PAYMENT-041-RECONCILIATION: POS Payment Mismatch Creates Review Not Silent Mutation

Precondition:

- POS payment state differs from provider-verified state.

Action:

- Reconciliation runs.

Expected result:

- Review or correction candidate is created.
- No silent overwrite occurs.
- Evidence packet is created.

Failure severity:

- HIGH

Evidence:

- reconciliation case
- evidence packet

---

### TC-PAYMENT-042-RECONCILIATION: Settlement Reconciliation Links Payment And Refund Evidence

Precondition:

- Settlement mismatch exists due to refund or provider delay.

Action:

- Settlement reconciliation runs.

Expected result:

- Settlement reconciliation case links payment, refund, provider, and audit references.
- Correction is append-only.

Evidence:

- settlement reconciliation case
- audit references

---

## 20. Degraded Payment Tests

### TC-PAYMENT-043-DEGRADED: Degraded Mode Does Not Confirm Payment Locally

Precondition:

- Store is in degraded mode.
- Provider confirmation unavailable.

Action:

- Local runtime attempts to mark payment confirmed.

Expected result:

- Payment remains pending, uncertain, or reconciliation required.
- No local confirmation occurs.
- Audit/evidence is created.

Failure severity:

- CRITICAL

Evidence:

- payment state unchanged
- degraded evidence

---

### TC-PAYMENT-044-DEGRADED: Payment Uncertainty Is Visible To Authorized Staff

Precondition:

- Payment is provider uncertain.

Action:

- Authorized staff views operational screen.

Expected result:

- Staff sees safe payment review or verification pending indicator.
- Staff does not see raw provider payload.

Evidence:

- staff view sample
- masking verification

---

### TC-PAYMENT-045-DEGRADED: KDS May See Limited Payment Signal Only

Precondition:

- Payment is pending or confirmed.
- KDS ticket exists.

Action:

- KDS view is rendered.

Expected result:

- KDS sees only allowed operational signal if needed.
- KDS cannot access provider details or mutate payment.

Failure severity:

- CRITICAL if mutation available

Evidence:

- KDS view sample
- mutation denial

---

## 21. Support And Owner Visibility Tests

### TC-PAYMENT-046-SUPPORT: Support Payment View Is Case-Scoped And Masked

Precondition:

- Support agent is assigned to payment issue case.

Action:

- Support agent views payment summary.

Expected result:

- Masked payment reference and status are visible.
- Payment token, card data, provider secret, raw webhook payload are hidden.
- Access is audited.

Failure severity:

- CRITICAL if secrets visible

Evidence:

- support view sample
- audit event

---

### TC-PAYMENT-047-SUPPORT: Support Cannot Access Payment Without Case Scope

Precondition:

- Support agent has no assigned case.

Action:

- Support agent attempts payment view.

Expected result:

- Access is denied.
- Audit event is created where required.

Failure severity:

- HIGH

Evidence:

- denial result
- support audit

---

### TC-PAYMENT-048-OWNER: Owner Settlement View Is Store-Scoped

Precondition:

- Owner is authorized for Store A1 only.
- Store A2 settlement exists.

Action:

- Owner views settlement summary.

Expected result:

- Only Store A1 settlement is visible.
- Store A2 settlement is excluded.

Failure severity:

- HIGH to CRITICAL depending leakage

Evidence:

- owner view sample
- scope verification

---

## 22. Export And Masking Tests

### TC-PAYMENT-049-MASKING: Payment Logs Do Not Expose Secrets

Precondition:

- Payment initiation, webhook, refund, or reconciliation occurs.

Action:

- Logs are inspected.

Expected result:

- Logs do not contain payment token, card data, provider secret, webhook secret, authorization header, or raw provider payload.

Failure severity:

- CRITICAL

Evidence:

- log sample inspection

---

### TC-PAYMENT-050-MASKING: Payment Audit Does Not Store Secrets

Precondition:

- Payment audit event is created.

Action:

- Audit payload is inspected.

Expected result:

- Audit excludes payment token, card data, provider secret, webhook secret, raw provider payload.
- Masked payment reference is used.

Failure severity:

- CRITICAL

Evidence:

- audit inspection

---

### TC-PAYMENT-051-EXPORT: Payment Export Excludes Secrets

Precondition:

- Authorized payment export is requested.

Action:

- Export is generated.

Expected result:

- Export excludes payment token, card data, provider secrets, webhook secrets, raw provider payload, raw CI / DI.
- Export is masked and audited.

Failure severity:

- CRITICAL

Evidence:

- export sample inspection
- export audit

---

### TC-PAYMENT-052-EXPORT: Unauthorized Payment Export Is Denied

Precondition:

- Actor lacks payment export authority.

Action:

- Actor requests payment export.

Expected result:

- Export is denied.
- Export denial audit is created.

Failure severity:

- HIGH

Evidence:

- export denial
- audit event

---

## 23. AI Boundary Tests

### TC-PAYMENT-053-AI: AI Receives Status Class Only For Payment Issue

Precondition:

- AI support summary is requested for payment issue.

Action:

- AI prompt/context is generated.

Expected result:

- AI receives masked payment reference, status class, and safe issue summary only.
- AI does not receive token, card data, provider secret, raw webhook payload, or raw CI / DI.

Failure severity:

- CRITICAL if secrets or raw identity enter AI

Evidence:

- AI context inspection
- AI audit event

---

### TC-PAYMENT-054-AI: AI Refund Recommendation Does Not Approve Refund

Precondition:

- AI recommends refund policy candidate.

Action:

- Recommendation is produced.

Expected result:

- Refund state remains unchanged.
- Human/system approval is still required.
- Recommendation is labeled as recommendation.

Failure severity:

- CRITICAL if refund is approved

Evidence:

- AI output
- refund state unchanged

---

## 24. Audit Tests

### TC-PAYMENT-055-AUDIT: Payment Confirmation Creates Audit

Precondition:

- Valid webhook confirms payment.

Action:

- Payment state changes to confirmed.

Expected result:

- Audit event records confirmation with tenant/store/order/payment reference and provider event reference.
- Secrets are excluded.

Failure severity:

- CRITICAL if missing

Evidence:

- audit event

---

### TC-PAYMENT-056-AUDIT: Refund Approval Creates Audit

Precondition:

- Authorized refund approval occurs.

Action:

- Refund state changes to approved.

Expected result:

- Audit event records approver, reason, refund reference, payment reference, amount class, and tenant/store.

Failure severity:

- CRITICAL if missing

Evidence:

- audit event

---

### TC-PAYMENT-057-AUDIT: Webhook Rejection Creates Audit

Precondition:

- Invalid webhook is received.

Action:

- Webhook is rejected.

Expected result:

- Audit event records rejection reason class without exposing raw secret or payload.

Failure severity:

- HIGH

Evidence:

- audit event
- masking verification

---

### TC-PAYMENT-058-AUDIT: Reconciliation Correction Creates Audit Lineage

Precondition:

- Payment correction is applied.

Action:

- Correction event is appended.

Expected result:

- Audit links original state and corrected state.
- Original history remains.

Failure severity:

- CRITICAL if overwrite occurs

Evidence:

- audit lineage

---

## 25. Evidence Packet Tests

### TC-PAYMENT-059-EVIDENCE: Payment Evidence Packet Contains Required References

Precondition:

- Payment issue requires evidence packet.

Action:

- Evidence packet is created.

Expected result:

- Packet includes payment reference, provider event reference, webhook verification result, order reference, audit references, and reconciliation status.
- Secrets are excluded.

Evidence:

- evidence packet sample

---

### TC-PAYMENT-060-EVIDENCE: Refund Evidence Packet Links Request Approval Submission Completion

Precondition:

- Refund lifecycle completes.

Action:

- Evidence packet is generated.

Expected result:

- Packet links refund request, approval, provider submission, provider completion, audit events, and settlement impact.

Evidence:

- refund evidence packet

---

### TC-PAYMENT-061-EVIDENCE: Settlement Evidence Links Payment And Refund Records

Precondition:

- Settlement includes payment and refund impact.

Action:

- Settlement evidence packet is created.

Expected result:

- Packet links settlement period, payment, refund, adjustment, audit, and owner-facing summary.

Evidence:

- settlement evidence packet

---

## 26. Deployment Gate Tests For Payment

### TC-PAYMENT-062-DEPLOY: Payment Release Requires Webhook Signature Tests

Precondition:

- Release changes payment webhook handling.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless signature validation tests exist.
- Gate result is audited.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- test evidence reference

---

### TC-PAYMENT-063-DEPLOY: Payment Release Requires Idempotency And Replay Tests

Precondition:

- Release changes webhook processing or payment state transition.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless idempotency and replay tests exist.

Failure severity:

- CRITICAL

Evidence:

- release gate result

---

### TC-PAYMENT-064-DEPLOY: Refund Release Requires Approval And Provider Completion Tests

Precondition:

- Release changes refund workflow.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless refund request/approval/submission/completion tests exist.

Failure severity:

- HIGH

Evidence:

- release gate result
- refund test references

---

### TC-PAYMENT-065-DEPLOY: Settlement Release Requires Reconciliation Tests

Precondition:

- Release changes settlement or payout calculation.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless settlement reconciliation and refund impact tests exist.

Failure severity:

- HIGH

Evidence:

- release gate result

---

## 27. Regression Tests

Regression tests should be created for every payment failure.

Regression candidates:

- client success confirmed payment
- invalid webhook accepted
- duplicate webhook created duplicate settlement
- replayed webhook mutated final state
- amount mismatch confirmed payment
- wrong tenant/store webhook mutated payment
- refund request auto-approved
- duplicate refund submitted
- partial refund exceeded paid amount
- settlement released unverified payment
- KDS mutated payment
- support approved refund without authority
- AI approved refund
- payment secret appeared in log, audit, export, or AI
- reconciliation overwrote history
- payment release skipped webhook test

Every payment incident should generate a regression test.

---

## 28. Coverage Matrix

Recommended coverage matrix:

| Area | Positive | Negative | Webhook | Idempotency | Replay | Masking | Audit | Deploy |
| ---- | -------- | -------- | ------- | ----------- | ------ | ------- | ----- | ------ |
| Payment Initiation | Required | Required | N/A | Required | N/A | Required | Required | Conditional |
| Payment Confirmation | Required | Required | Required | Required | Required | Required | Required | Required |
| Payment Failure | Required | Required | Required | Conditional | Conditional | Required | Required | Conditional |
| Refund Request | Required | Required | N/A | Conditional | N/A | Required | Required | Conditional |
| Refund Approval | Required | Required | N/A | Conditional | N/A | Required | Required | Required |
| Refund Submission | Required | Required | Conditional | Required | Required | Required | Required | Required |
| Refund Completion | Required | Required | Required | Required | Required | Required | Required | Required |
| Partial Refund | Required | Required | Conditional | Required | Conditional | Required | Required | Conditional |
| Settlement | Required | Required | Conditional | Conditional | Conditional | Required | Required | Required |
| Reconciliation | Required | Required | Conditional | Conditional | Required | Required | Required | Required |
| Support/Owner Visibility | Required | Required | N/A | N/A | N/A | Required | Required | Conditional |
| AI Boundary | Required | Required | N/A | N/A | N/A | Required | Required | Conditional |

Coverage gaps become blockers.

---

## 29. Evidence Requirements

Evidence must prove:

- payment initiation creates pending state
- client success page cannot confirm payment
- valid webhook confirms payment
- invalid signature is rejected
- expired timestamp is rejected
- unknown event is quarantined
- duplicate webhook does not duplicate mutation
- replayed webhook does not mutate final truth
- amount mismatch is quarantined
- wrong tenant/store mapping is rejected
- refund request does not equal approval
- unauthorized actor cannot approve refund
- refund approval requires authority and reason
- refund submission is idempotent
- refund completion requires provider verification
- partial refund cannot exceed paid amount
- settlement uses verified payment/refund records
- payment uncertainty opens reconciliation
- correction is append-only
- degraded mode does not confirm payment locally
- support visibility is case-scoped and masked
- owner settlement view is store-scoped
- payment logs/audit/export/AI exclude secrets
- payment and refund audit events exist
- evidence packets link provider, payment, refund, settlement, and audit references
- release gates block unsafe payment changes

Evidence must not expose payment tokens, card data, provider secrets, webhook secrets, raw CI / DI, or unrestricted provider payloads.

---

## 30. Failure Severity

Critical failures include:

- client success page confirms payment
- invalid webhook confirms payment
- replayed webhook mutates final state
- duplicate refund occurs
- partial refund exceeds paid amount
- wrong tenant/store payment mutation
- KDS mutates payment
- support approves refund without authority
- AI approves refund
- settlement releases unverified payment
- payment token or provider secret appears in log, audit, export, or AI
- reconciliation overwrites original history
- production payment release without webhook tests

High failures include:

- payment uncertainty hidden
- refund denial lacks audit
- duplicate webhook lacks trace
- owner sees unrelated store settlement
- support sees payment without case scope
- refund completion assumed from submission
- settlement hold not visible where required
- release skips refund or settlement tests

Medium failures include:

- customer-facing message is unclear but safe
- non-sensitive provider status mapping inconsistency
- minor audit category mismatch without financial impact

Critical and high failures block implementation.

---

## 31. Implementation Blockers

Implementation must be blocked if:

- payment initiation tests are missing
- client success denial test is missing
- webhook signature tests are missing
- webhook idempotency tests are missing
- webhook replay tests are missing
- amount/reference validation tests are missing
- tenant/store payment context tests are missing
- refund request versus approval tests are missing
- refund authority tests are missing
- refund submission idempotency tests are missing
- refund completion verification tests are missing
- partial refund tests are missing
- settlement verification tests are missing
- reconciliation append-only tests are missing
- degraded payment uncertainty tests are missing
- KDS payment mutation denial test is missing
- support payment scope tests are missing
- owner settlement scope tests are missing
- payment masking tests are missing
- payment audit tests are missing
- evidence packet tests are missing
- deployment gate tests are missing

These blockers must be added to the implementation blocker register.

---

## 32. Test Status Values

Recommended status values:

- `NOT_DEFINED`
- `DRAFT`
- `MAPPED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`
- `IMPLEMENTED`
- `PASS`
- `FAIL`
- `BLOCKED`
- `WAIVED_WITH_APPROVAL`
- `DEFERRED`
- `OBSOLETE`

Critical payment tests should not be waived unless the payment-related feature is removed from implementation scope.

---

## 33. Non-Goals

This document does not define:

- final payment provider
- final payment schema
- final webhook handler
- final refund API
- final settlement job
- final reconciliation job
- final provider credential storage
- final automated test code
- final sandbox provider setup
- final POS payment adapter
- final customer payment UI
- final owner settlement dashboard
- final deployment pipeline
- final production monitoring

Those belong to later controlled implementation phase.

---

## 34. Readiness Check

This test catalog is ready when the project can answer:

1. How is payment initiation tested?
2. Why can client success page not confirm payment?
3. How is valid webhook tested?
4. How is invalid signature tested?
5. How is expired timestamp tested?
6. How is unknown event quarantined?
7. How is duplicate webhook tested?
8. How is replayed webhook tested?
9. How is amount mismatch tested?
10. How is wrong reference tested?
11. How is wrong tenant/store payment context tested?
12. How is refund request separated from approval?
13. How is unauthorized refund approval denied?
14. How is refund approval reason required?
15. How is refund submission idempotent?
16. How is refund completion provider-verified?
17. How is partial refund capped?
18. How is settlement candidate created?
19. How is unverified payment excluded from settlement?
20. How does refund affect settlement?
21. How is payment uncertainty reconciled?
22. How is correction append-only?
23. How does degraded mode avoid local payment confirmation?
24. How is support payment visibility scoped?
25. How is owner settlement visibility scoped?
26. How are logs, audit, export, and AI checked for secrets?
27. How is AI payment authority denied?
28. How are payment audit events tested?
29. How are evidence packets tested?
30. How do release gates protect payment, refund, and settlement changes?
31. What regression tests are required?
32. What evidence is required?
33. What failures are critical?
34. What blocks implementation?

If these questions cannot be answered, payment webhook refund settlement reconciliation test catalog is incomplete.

---

## 35. Conclusion

Payment, refund, settlement, and reconciliation are financial-grade boundaries in the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

- client success page is not payment confirmation
- provider webhook must be verified
- webhook signature must be tested
- webhook idempotency must be tested
- webhook replay must not mutate final truth
- amount and reference must match
- tenant/store context must match
- refund request is not refund approval
- refund approval requires authority and reason
- refund submission must be idempotent
- refund completion requires provider verification
- partial refund must not exceed paid amount
- settlement must use verified payment and refund records
- payment uncertainty must be visible and reconciled
- correction must be append-only
- degraded mode must not confirm payment locally
- KDS must not mutate payment
- support must be case-scoped
- owner settlement visibility must be store-scoped
- AI may recommend but must not execute payment/refund authority
- payment logs, audit, export, and AI must exclude secrets
- payment, refund, settlement, and reconciliation actions must be audited
- evidence packets must link provider, payment, refund, settlement, and audit records
- deployment gates must block unsafe payment releases
- critical failures block implementation

This document does not implement payment tests.

It defines the payment webhook refund settlement reconciliation test catalog that future implementation must satisfy.