# 014071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response

## 1. Purpose

This document defines the POS Gateway policy for dispute evidence packets, refund response, cancellation response, duplicate payment investigation, and chargeback readiness.

The POS Gateway must be able to prove what happened when a customer, store, tenant, POS provider, payment provider, VAN/PG route, kiosk, mini-kiosk, wait-order session, or manual recovery path creates a conflicting financial state.

The purpose of this policy is to ensure that every payment-related dispute can be handled with structured evidence instead of ad hoc screenshots, staff memory, provider guesswork, or incomplete logs.

## 2. Scope

This policy applies to all dispute scenarios involving:

* payment approval
* payment failure
* payment timeout
* duplicate payment suspicion
* order acceptance failure after payment
* order fulfillment failure after payment
* cancellation request
* cancellation failure
* refund request
* refund failure
* partial cancellation
* partial refund
* provider-side reversal
* POS-side cancellation
* customer claim
* store claim
* tenant claim
* VAN/PG provider mismatch
* chargeback or card-company dispute
* delayed settlement mismatch
* manual staff recovery
* offline/degraded gateway replay

This policy applies to all POS Gateway integration types, including official API integrations, unofficial bridge integrations, provider export/import flows, receipt-based verification, printer-based fallback, and manual POS entry fallback.

## 3. Relationship To Previous Document

This document follows:

* `05640_POS_Gateway_Compliance_Financial_Audit_Regulatory_And_Consumer_Protection_Readiness_Policy.md`

The previous document defines the compliance, financial audit, regulatory, and consumer-protection readiness requirements.

This document turns those requirements into a concrete dispute-response structure.

The rule is:

> 05640 defines what must be preserved.
> 05650 defines how preserved evidence is packaged, reviewed, escalated, and used to resolve disputes.

## 4. Core Principle

The POS Gateway must treat every unresolved financial conflict as an evidence case.

The system must not rely on:

* staff memory
* customer screenshots alone
* POS terminal display alone
* payment provider dashboard alone
* mutable order status alone
* support chat alone
* manual admin notes alone
* settlement file alone
* customer-facing status text alone

A dispute must be resolved through a structured evidence packet that connects internal events, POS events, payment provider events, customer notifications, staff actions, and reconciliation results.

## 5. Dispute Categories

The POS Gateway must classify disputes into standardized categories.

Required categories include:

* `PAYMENT_APPROVED_ORDER_NOT_CONFIRMED`
* `ORDER_CONFIRMED_PAYMENT_UNKNOWN`
* `CUSTOMER_PAID_STORE_DID_NOT_RECEIVE`
* `STORE_RECEIVED_CUSTOMER_PAYMENT_UNKNOWN`
* `DUPLICATE_PAYMENT_SUSPECTED`
* `DUPLICATE_PAYMENT_CONFIRMED`
* `CANCELLATION_REQUESTED_PROVIDER_UNKNOWN`
* `CANCELLATION_REQUESTED_POS_UNKNOWN`
* `CANCELLATION_COMPLETED_CUSTOMER_CLAIMS_NOT_REFLECTED`
* `REFUND_REQUESTED_PROVIDER_UNKNOWN`
* `REFUND_PENDING_CUSTOMER_ESCALATION`
* `REFUND_COMPLETED_CUSTOMER_CLAIMS_NOT_RECEIVED`
* `PARTIAL_CANCEL_AMOUNT_MISMATCH`
* `PARTIAL_REFUND_AMOUNT_MISMATCH`
* `ORDER_FULFILLED_PAYMENT_REVERSED`
* `PAYMENT_APPROVED_ORDER_CANCELLED`
* `POS_ACCEPTED_PROVIDER_DECLINED`
* `PROVIDER_APPROVED_POS_REJECTED`
* `SETTLEMENT_AMOUNT_MISMATCH`
* `CHARGEBACK_NOTICE_RECEIVED`
* `CHARGEBACK_EVIDENCE_REQUIRED`
* `MANUAL_OVERRIDE_DISPUTED`
* `CUSTOMER_NOTIFICATION_DISPUTED`
* `TABLE_MATCHING_DISPUTED`
* `WAIT_ORDER_HANDOFF_DISPUTED`

Each category must have a dispute owner, required evidence list, response deadline, customer-protection posture, and closure rule.

## 6. Evidence Packet Requirement

Every dispute must generate or reference a dispute evidence packet.

The packet must include enough structured information to answer the following questions:

* Who initiated the transaction?
* Which store and tenant were involved?
* Which order was affected?
* Which payment attempt was affected?
* Which POS route was used?
* Which payment provider route was used?
* What did the customer see?
* What did the store see?
* What did the POS report?
* What did the provider report?
* What did the internal gateway record?
* What notifications were sent?
* What staff actions occurred?
* Was any manual override performed?
* Was cancellation attempted?
* Was refund attempted?
* Was settlement matched?
* Is there unresolved ambiguity?
* What action was taken to protect the customer?
* Who approved the final resolution?

## 7. Standard Dispute Evidence Packet Structure

A standard dispute evidence packet must contain the following sections.

### 7.1 Packet Header

Required fields:

* evidence_packet_id
* dispute_case_id
* packet_type
* packet_version
* generated_at
* generated_by
* tenant_id
* store_id
* order_id
* customer_reference
* payment_attempt_id
* provider_transaction_id
* pos_transaction_id
* correlation_id
* trace_id
* current_case_status
* current_financial_status
* current_order_status
* current_customer_status

### 7.2 Timeline Summary

The packet must include a normalized event timeline.

The timeline must include:

* customer order creation time
* wait-order session creation time if applicable
* table matching time if applicable
* payment request time
* payment provider response time
* POS request time
* POS response time
* store acceptance time
* kitchen ticket creation time if applicable
* cancellation request time if applicable
* cancellation provider response time if applicable
* refund request time if applicable
* refund provider response time if applicable
* customer notification send time
* staff manual action time
* reconciliation run time
* dispute open time
* dispute resolution time if closed

### 7.3 Internal Event Ledger Extract

The packet must include all relevant append-only internal events.

Required event families include:

* order events
* payment events
* POS gateway events
* provider request events
* provider response events
* cancellation events
* refund events
* customer notification events
* staff action events
* manual override events
* reconciliation events
* dispute case events
* evidence export events

### 7.4 Provider Evidence Summary

The packet must summarize payment provider, VAN, PG, or card-route evidence.

Required fields include:

* provider name
* provider route
* provider transaction identifier
* provider approval status
* provider approval timestamp
* provider failure status if any
* provider cancellation status if any
* provider refund status if any
* provider settlement status if available
* provider lookup timestamp
* provider evidence source
* provider evidence limitation
* missing provider evidence flag

### 7.5 POS Evidence Summary

The packet must summarize POS-side evidence.

Required fields include:

* POS provider name
* POS integration type
* POS request identifier
* POS order identifier
* POS accepted status
* POS rejected status
* POS cancellation status if available
* POS receipt status if available
* POS terminal/manual evidence if applicable
* POS lookup timestamp if supported
* missing POS evidence flag

### 7.6 Customer-Facing Evidence

The packet must include customer-visible evidence.

Required fields include:

* customer-facing order number
* customer-facing payment status
* customer-facing order status
* customer-facing cancellation status
* customer-facing refund status
* screen state snapshot reference if available
* message template id
* message template version
* notification channel
* notification send result
* notification delivery result if available
* customer support contact history if applicable

### 7.7 Staff And Manual Recovery Evidence

The packet must include staff-side action evidence.

Required fields include:

* staff actor type
* staff actor identifier
* store role
* action type
* action timestamp
* reason code
* manual note
* attached evidence reference if any
* reauthentication marker if required
* manager approval marker if required
* HQ approval marker if required
* before state
* after state

### 7.8 Reconciliation Evidence

The packet must include reconciliation results.

Required fields include:

* reconciliation_batch_id
* reconciliation_run_at
* internal order amount
* internal payment amount
* provider approved amount
* provider cancelled amount
* provider refunded amount
* POS accepted amount
* POS cancelled amount
* settlement amount if available
* mismatch category
* mismatch age
* resolution status
* unresolved amount
* owner
* due date

### 7.9 Decision And Resolution Evidence

The packet must record the final or current decision.

Required fields include:

* decision_status
* decision_owner
* decision_timestamp
* decision_reason_code
* customer_protection_action
* store_protection_action
* tenant_action
* provider_escalation_action
* refund_action
* cancellation_action
* compensation_action if any
* final customer-facing message
* closure evidence
* reopen condition

## 8. Refund Response Policy

### 8.1 Refund State Separation

The POS Gateway must distinguish refund states clearly.

Required refund states include:

* `REFUND_NOT_REQUESTED`
* `REFUND_REQUESTED`
* `REFUND_PROVIDER_PENDING`
* `REFUND_PROVIDER_ACCEPTED`
* `REFUND_PROVIDER_REJECTED`
* `REFUND_COMPLETED`
* `REFUND_FAILED`
* `REFUND_UNKNOWN`
* `REFUND_MANUAL_REVIEW_REQUIRED`
* `REFUND_RECONCILIATION_REQUIRED`
* `REFUND_DISPUTED`

The system must not display refund completion until provider evidence, reconciliation evidence, or authorized compliance resolution exists.

### 8.2 Refund Evidence Requirements

Every refund attempt must record:

* original payment attempt id
* refund request id
* refund amount
* full or partial refund marker
* refund reason code
* actor type
* actor id
* request timestamp
* provider request timestamp
* provider response timestamp
* provider refund id if available
* provider result status
* customer notification id
* reconciliation status
* dispute case id if applicable

### 8.3 Refund Failure Handling

If refund fails or becomes unknown, the system must:

* open or update a dispute case
* preserve original payment evidence
* preserve refund request evidence
* mark customer-facing status as pending or under review
* prevent duplicate refund execution unless idempotency is verified
* escalate by aging threshold
* create provider follow-up task where applicable
* require manual resolution reason if closed without provider confirmation

### 8.4 Refund Aging Thresholds

Recommended aging thresholds:

* 10 minutes: provider delay warning
* 30 minutes: support review
* 2 hours: compliance queue
* 1 business day: provider escalation
* 3 business days: management review
* 7 business days: legal or formal dispute review

Thresholds may be adjusted by provider, tenant, channel, or contract, but must be explicitly configured.

## 9. Cancellation Response Policy

### 9.1 Cancellation State Separation

The POS Gateway must distinguish cancellation states clearly.

Required cancellation states include:

* `CANCEL_NOT_REQUESTED`
* `CANCEL_REQUESTED`
* `CANCEL_POS_PENDING`
* `CANCEL_PROVIDER_PENDING`
* `CANCEL_POS_ACCEPTED`
* `CANCEL_PROVIDER_ACCEPTED`
* `CANCEL_COMPLETED`
* `CANCEL_REJECTED`
* `CANCEL_FAILED`
* `CANCEL_UNKNOWN`
* `CANCEL_MANUAL_REVIEW_REQUIRED`
* `CANCEL_DISPUTED`

The system must not treat customer cancellation, POS cancellation, and payment provider cancellation as the same event.

### 9.2 Cancellation Evidence Requirements

Every cancellation attempt must record:

* original order id
* original payment attempt id if applicable
* cancellation request id
* cancellation reason code
* actor type
* actor id
* customer request timestamp if applicable
* store acknowledgement timestamp if applicable
* POS cancellation request timestamp if applicable
* POS cancellation response timestamp if applicable
* provider cancellation request timestamp if applicable
* provider cancellation response timestamp if applicable
* preparation state at cancellation request
* customer notification id
* refund relationship if applicable
* dispute case id if applicable

### 9.3 Cancellation After Preparation

If cancellation is requested after preparation has started, the system must record:

* preparation start timestamp
* kitchen ticket status
* staff confirmation
* cancellation eligibility decision
* customer-facing explanation template
* refund eligibility decision
* store manager approval if required

The system must not silently cancel a prepared or fulfilled order without evidence.

### 9.4 Cancellation Unknown Handling

If cancellation state is unknown, the system must:

* prevent misleading customer success messages
* preserve the customer request
* preserve POS/provider request evidence
* mark the case as pending review
* block duplicate cancellation unless safe
* require lookup or provider escalation where supported
* attach the case to reconciliation

## 10. Chargeback Readiness Policy

### 10.1 Chargeback Notice Intake

When a chargeback, card-company dispute, PG dispute, VAN dispute, or provider inquiry is received, the system must create a chargeback response case.

Required fields:

* chargeback_case_id
* provider_reference
* card-company reference if available
* tenant_id
* store_id
* order_id
* payment_attempt_id
* notice_received_at
* response_due_at
* dispute_amount
* dispute_reason
* current owner
* evidence_packet_id
* response_status

### 10.2 Chargeback Evidence Requirements

A chargeback response packet must include:

* order evidence
* payment authorization evidence
* customer confirmation evidence
* fulfillment evidence
* store acceptance evidence
* cancellation/refund history
* customer notification history
* provider transaction evidence
* POS transaction evidence
* staff manual action evidence
* delivery or pickup evidence if available
* table/wait-order matching evidence if applicable
* prior customer support history
* reconciliation result
* final response recommendation

### 10.3 Chargeback Response States

Required states include:

* `NOTICE_RECEIVED`
* `EVIDENCE_GATHERING`
* `EVIDENCE_PACKET_READY`
* `RESPONSE_DRAFTED`
* `RESPONSE_SUBMITTED`
* `PROVIDER_REVIEW_PENDING`
* `WON`
* `LOST`
* `PARTIAL_LOSS`
* `WITHDRAWN`
* `EXPIRED`
* `MANUAL_LEGAL_REVIEW_REQUIRED`

### 10.4 Chargeback Deadline Control

The system must track response deadlines.

If a response deadline is approaching, the case must escalate.

Recommended escalation:

* 7 days before due date: owner reminder
* 3 days before due date: compliance escalation
* 1 day before due date: management escalation
* due date missed: critical incident

The exact schedule may vary by provider contract and dispute process.

## 11. Duplicate Payment Response

### 11.1 Duplicate Payment Detection

The POS Gateway must detect possible duplicate payment using:

* same customer reference
* same order reference
* same amount
* same store
* same device/channel
* same payment method class
* close timestamp window
* repeated idempotency key
* repeated provider transaction pattern
* multiple provider approvals for one order
* multiple POS order records for one internal order

### 11.2 Duplicate Payment Case

A duplicate payment suspicion must create a case.

Required fields:

* suspected_duplicate_case_id
* primary payment attempt id
* secondary payment attempt id
* order id
* amount comparison
* timestamp comparison
* provider comparison
* POS comparison
* customer notification status
* fulfillment hold status
* refund recommendation
* final determination

### 11.3 Duplicate Payment Customer Protection

When duplicate payment is suspected:

* the customer-facing status must show review or pending resolution
* staff must be warned before fulfilling duplicate orders
* automatic duplicate refund must not run unless provider safety is verified
* reconciliation must confirm final outcome
* customer notification must be conservative
* closure must record whether duplicate was confirmed or dismissed

## 12. Dispute Workflow

### 12.1 Case Creation

A dispute case may be created by:

* system detection
* customer complaint
* staff report
* store manager report
* tenant admin report
* HQ compliance review
* provider notice
* reconciliation mismatch
* chargeback notice
* monitoring alert

### 12.2 Case Assignment

Each case must be assigned to an owner.

Owner classes include:

* store manager
* tenant operator
* tenant admin
* HQ support
* HQ compliance
* finance operator
* provider liaison
* legal reviewer
* system automation owner

### 12.3 Case Review

The review process must include:

* evidence packet generation
* missing evidence check
* financial state check
* customer-facing state check
* refund/cancellation status check
* POS/provider mismatch check
* staff action review
* reconciliation review
* decision recommendation
* owner approval

### 12.4 Case Closure

A dispute case may be closed only when:

* final financial state is determined
* customer-facing state is corrected
* refund/cancellation action is completed or explicitly denied
* customer notification is sent if required
* reconciliation status is updated
* manual correction is recorded if used
* provider escalation is closed or marked unavailable
* evidence packet is attached
* closure reason is recorded

## 13. Missing Evidence Handling

If required evidence is missing, the system must not hide it.

Missing evidence must be explicitly flagged.

Required missing evidence flags include:

* `MISSING_PROVIDER_APPROVAL`
* `MISSING_PROVIDER_FAILURE`
* `MISSING_PROVIDER_CANCEL`
* `MISSING_PROVIDER_REFUND`
* `MISSING_POS_ACCEPTANCE`
* `MISSING_POS_CANCEL`
* `MISSING_CUSTOMER_NOTIFICATION`
* `MISSING_STAFF_ACTION`
* `MISSING_RECONCILIATION`
* `MISSING_SETTLEMENT_FILE`
* `MISSING_RECEIPT`
* `MISSING_TABLE_MATCH`
* `MISSING_WAIT_ORDER_SESSION`
* `MISSING_KITCHEN_STATUS`

Each missing evidence flag must have:

* impact level
* possible source
* recovery action
* owner
* due date
* final disposition

## 14. Customer Communication Rules

### 14.1 Conservative Messaging

Customer messages must never overstate evidence certainty.

Examples:

* use “refund is being processed” only when refund request exists but completion is not confirmed
* use “refund completed” only when completion evidence exists
* use “payment is under confirmation” when provider state is unknown
* use “order is under store review” when POS acceptance is unknown
* use “duplicate payment is under review” when duplicate approval is suspected
* use “cancellation request received” before cancellation is final

### 14.2 Required Customer Notification Events

The system must record customer notifications for:

* payment ambiguity
* order acceptance ambiguity
* cancellation request
* cancellation completion
* cancellation failure
* refund request
* refund completion
* refund delay
* duplicate payment review
* dispute case opened
* dispute case resolved
* chargeback-related customer contact where applicable

### 14.3 Message Template Governance

All dispute-related messages must be template-driven.

Each template must have:

* template id
* template version
* language
* allowed dispute categories
* prohibited dispute categories
* legal/compliance review status
* last reviewed date
* owner

## 15. Staff And Store Communication Rules

Store-facing messages must clearly distinguish:

* customer says paid
* provider says paid
* internal gateway says paid
* POS says accepted
* POS state unknown
* refund requested
* refund completed
* cancellation requested
* cancellation completed
* manual review required
* duplicate payment suspected
* fulfillment hold recommended
* provider escalation required

Staff must not be asked to infer final financial truth from partial evidence.

## 16. Access Control

Dispute evidence must be access-controlled.

### 16.1 Store Staff

Store staff may view:

* operational summary
* customer-facing status
* action required
* allowed manual recovery actions
* masked payment state
* masked customer contact reference

Store staff must not view:

* raw provider payloads
* full payment tokens
* unrelated customer records
* cross-store evidence
* chargeback legal notes unless authorized

### 16.2 Store Manager

Store manager may view:

* store-scoped dispute cases
* store staff actions
* store operational timeline
* store cancellation/refund queue
* store fulfillment evidence

Store manager must not override final financial evidence without authorized workflow.

### 16.3 Tenant Admin

Tenant admin may view:

* tenant-scoped dispute summary
* store-level case status
* refund/cancellation aging
* unresolved mismatch dashboard
* evidence packet summary subject to redaction

Tenant admin access must remain tenant-scoped.

### 16.4 HQ Compliance

HQ compliance may view full evidence where authorized.

HQ compliance access must be logged.

### 16.5 Developer Access

Developer access to production dispute evidence must be prohibited by default.

If break-glass access is required:

* access must be time-limited
* access must be ticket-linked
* access must be logged
* sensitive fields must be masked unless explicitly approved
* post-access review must be required

## 17. Data Model Requirements

The implementation must support the following logical records.

### 17.1 Dispute Case

Required fields:

* dispute_case_id
* dispute_category
* severity
* tenant_id
* store_id
* order_id
* payment_attempt_id
* customer_reference
* provider_reference
* pos_reference
* opened_by
* opened_at
* owner_role
* owner_id
* status
* due_at
* resolved_at
* resolution_code
* customer_impact
* financial_impact
* evidence_packet_id
* legal_review_required
* chargeback_related

### 17.2 Dispute Evidence Packet

Required fields:

* evidence_packet_id
* dispute_case_id
* packet_version
* generated_at
* generated_by
* source_event_range
* correlation_id
* trace_id
* redaction_profile
* missing_evidence_flags
* export_hash
* export_status
* access_scope
* last_exported_at

### 17.3 Refund Action

Required fields:

* refund_action_id
* payment_attempt_id
* order_id
* refund_amount
* refund_type
* reason_code
* requested_by
* requested_at
* provider_refund_id
* provider_status
* customer_notification_id
* reconciliation_status
* dispute_case_id

### 17.4 Cancellation Action

Required fields:

* cancellation_action_id
* order_id
* payment_attempt_id
* cancellation_type
* cancellation_reason
* requested_by
* requested_at
* pos_status
* provider_status
* preparation_state
* customer_notification_id
* refund_relationship_id
* dispute_case_id

### 17.5 Chargeback Case

Required fields:

* chargeback_case_id
* dispute_case_id
* provider_reference
* card_company_reference
* notice_received_at
* response_due_at
* dispute_amount
* dispute_reason
* response_status
* submitted_at
* result_status
* result_at
* evidence_packet_id

## 18. Monitoring And Alerting

The system must monitor:

* refund pending aging
* cancellation pending aging
* duplicate payment suspicion count
* chargeback case count
* chargeback due date risk
* missing evidence count
* provider evidence unavailable count
* POS evidence unavailable count
* customer notification failure count
* manual override dispute count
* unresolved high-severity dispute count
* evidence packet generation failure count
* dispute closure without packet count
* refund completion without provider evidence count
* cancellation completion without provider/POS evidence count

Critical alerts must be sent when:

* audit event writing fails
* evidence packet generation fails
* duplicate payment risk exceeds threshold
* chargeback deadline is missed
* refund aging exceeds configured limit
* cancellation aging exceeds configured limit
* manual override bypass is attempted
* missing evidence affects financial closure

## 19. Readiness Checklist

Before a POS/payment route may be considered dispute-ready, the following checklist must pass.

### 19.1 Evidence Packet

* [ ] Standard dispute evidence packet can be generated.
* [ ] Packet includes internal event timeline.
* [ ] Packet includes provider evidence.
* [ ] Packet includes POS evidence where available.
* [ ] Packet includes customer notification evidence.
* [ ] Packet includes staff action evidence.
* [ ] Packet includes refund/cancellation evidence.
* [ ] Packet includes reconciliation evidence.
* [ ] Packet marks missing evidence explicitly.
* [ ] Packet export is logged.

### 19.2 Refund

* [ ] Refund requested and refund completed are separate states.
* [ ] Refund failure opens or updates a dispute case.
* [ ] Refund unknown does not display as completed.
* [ ] Partial refund is supported or explicitly blocked.
* [ ] Refund idempotency is enforced.
* [ ] Refund aging escalation exists.

### 19.3 Cancellation

* [ ] Cancellation requested and cancellation completed are separate states.
* [ ] POS cancellation and provider cancellation are separate.
* [ ] Cancellation after preparation requires evidence.
* [ ] Cancellation unknown does not display as completed.
* [ ] Cancellation idempotency is enforced.
* [ ] Cancellation aging escalation exists.

### 19.4 Chargeback

* [ ] Chargeback notice can create a case.
* [ ] Chargeback deadline is tracked.
* [ ] Chargeback evidence packet can be generated.
* [ ] Chargeback response status is tracked.
* [ ] Chargeback result is recorded.
* [ ] Missed deadline creates critical incident.

### 19.5 Duplicate Payment

* [ ] Duplicate payment suspicion can be detected.
* [ ] Duplicate payment case can be created.
* [ ] Duplicate payment does not trigger unsafe automatic refund.
* [ ] Fulfillment hold can be recommended.
* [ ] Customer message is conservative.
* [ ] Final determination is recorded.

## 20. Non-Goals

This policy does not define:

* provider-specific legal dispute response templates
* final card-company chargeback evidence format
* accounting journal posting
* tax filing correction
* full legal claims process
* civil litigation strategy
* complete customer support SOP
* final refund commercial policy

Those must be handled in provider-specific, legal, accounting, and customer-support SOP documents.

This policy defines the POS Gateway system boundary required to support those processes.

## 21. Acceptance Criteria

This policy is accepted when:

* every dispute case can reference an evidence packet
* every refund action is state-separated and auditable
* every cancellation action is state-separated and auditable
* chargeback notices create deadline-tracked cases
* duplicate payment suspicion creates a controlled case
* missing evidence is explicitly flagged
* customer-facing status remains conservative
* staff-facing status does not imply final financial truth without evidence
* manual override is audit-controlled
* evidence packet export is logged
* dispute closure requires reason code and evidence reference
* provider and POS evidence gaps are visible
* unresolved financial ambiguity cannot be silently closed

## 22. Final Rule

A payment dispute is not a support conversation.

It is a financial evidence case.

The POS Gateway must preserve, package, classify, review, and resolve the evidence in a way that protects the customer, the store, the tenant, the operator, and the integrity of the financial record.
