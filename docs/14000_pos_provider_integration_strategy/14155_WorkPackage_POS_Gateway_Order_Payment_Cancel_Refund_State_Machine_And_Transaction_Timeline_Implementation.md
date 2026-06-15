# 14155_WorkPackage_POS_Gateway_Order_Payment_Cancel_Refund_State_Machine_And_Transaction_Timeline_Implementation

## 1. Purpose

This document defines the implementation work package for the POS Gateway order, payment, cancellation, refund state machine, and transaction timeline.

After the core registry, menu mapping, price versioning, availability control, and calculation snapshot are established, the gateway must create a transaction state spine.

The POS Gateway must not treat an order as a single flat status.

A real POS Gateway transaction may involve:

- customer cart;
- sellability validation;
- calculation snapshot;
- order creation;
- POS write request;
- POS write unknown result;
- POS order confirmation;
- payment initiation;
- payment pending;
- payment confirmed;
- payment failed;
- payment unknown;
- cancellation request;
- cancellation pending;
- cancellation confirmed;
- cancellation unknown;
- refund request;
- refund pending;
- refund confirmed;
- refund unknown;
- manual fallback;
- reconciliation case;
- customer dispute;
- audit timeline.

This work package creates the state machine layer that keeps these states distinct, traceable, and safe.

---

## 2. Scope

This work package covers implementation of:

- gateway transaction record;
- order lifecycle state;
- POS write state;
- payment state;
- cancellation state;
- refund state;
- transaction timeline;
- state transition rules;
- state transition audit;
- unknown state handling;
- manual review state;
- reconciliation-required state;
- customer-safe state projection;
- provider reference binding;
- calculation snapshot reference;
- business date and timezone context binding;
- payment route metadata readiness;
- cancellation/refund proof readiness;
- duplicate mutation guard integration points;
- incident and reconciliation trigger points.

This document does not fully implement idempotency, queues, retries, adapter calls, or reconciliation closure.  
Those are implemented in later work packages.

This document defines the authoritative transaction state model they must use.

---

## 3. Core Principle

The POS Gateway must separate actual state from customer-facing interpretation.

The gateway must never collapse the following into one ambiguous status:

```text
requested
sent
pending
unknown
confirmed_success
confirmed_failure
manual_review_required
reconciliation_required
```

Unknown is not failure.  
Pending is not success.  
Customer-facing messages must be derived from evidence-backed internal state.

The state machine must preserve uncertainty instead of hiding it.

---

## 4. Implementation Position

This work package follows:

```text
14153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md
14154_WorkPackage_POS_Gateway_Menu_Mapping_Price_Availability_And_Calculation_Snapshot_Implementation.md
```

This work package precedes:

```text
06340_POS_Gateway_Idempotency_Queue_Retry_Dead_Letter_Replay_And_Duplicate_Prevention_Implementation_Work_Package.md
06350_POS_Gateway_POS_KDS_Adapter_Interface_Routing_Error_Normalization_And_Provider_Contract_Implementation_Work_Package.md
06360_POS_Gateway_Table_QR_NFC_Kiosk_Device_Receipt_Proof_And_Customer_Status_Implementation_Work_Package.md
06370_POS_Gateway_Manual_Fallback_Manager_Approval_Staff_Action_And_Override_Implementation_Work_Package.md
06380_POS_Gateway_Reconciliation_Audit_Evidence_Settlement_And_Accounting_Guard_Implementation_Work_Package.md
```

Idempotency and provider adapters must operate against this state machine.

---

## 5. Required Implementation Domains

The implementation must define these domains:

```text
gateway_transaction
gateway_order_state
pos_write_state
payment_state
cancel_state
refund_state
transaction_timeline_event
transaction_state_transition
transaction_external_reference
transaction_business_context
transaction_financial_context
transaction_customer_safe_projection
manual_review_marker
reconciliation_required_marker
```

These may be implemented as separate tables or strongly separated logical models.

The key requirement is that every state transition remains reconstructable.

---

## 6. Gateway Transaction Record

The gateway transaction is the top-level transaction spine.

Required fields:

```text
transaction_id
tenant_id
store_id
order_channel
fulfillment_type
customer_session_id
table_session_id
device_id
provider_route_id
mapping_version_id
calculation_snapshot_id
currency_code
business_date_local
local_timezone_name
local_timezone_offset_minutes
created_at_utc
updated_at_utc
overall_transaction_state
status
```

The transaction record must not be used as the only state holder.

It is an index and correlation root.

Detailed state must remain in domain-specific state records.

---

## 7. Transaction Business Context Binding

Every transaction must bind local business context at creation time.

Required fields:

```text
transaction_business_context_id
transaction_id
tenant_id
store_id
country_code
region_code
city_code
currency_code
tax_jurisdiction_code
business_date_local
local_timezone_name
local_timezone_offset_minutes
store_local_created_at
provider_business_day
created_at_utc
```

Business context must be snapshotted.

Later changes to store timezone or business-day cutoff must not alter historical transaction context.

---

## 8. Transaction Financial Context Binding

Every transaction must bind financial context.

Required fields:

```text
transaction_financial_context_id
transaction_id
calculation_snapshot_id
currency_code
grand_total_minor
subtotal_amount_minor
discount_total_minor
coupon_total_minor
fee_total_minor
service_charge_total_minor
tip_amount_minor
tax_total_minor
rounding_amount_minor
provider_adjustment_total_minor
created_at_utc
```

This is not a recalculation table.

It is a reference and summary of the immutable calculation snapshot used for the transaction.

---

## 9. Overall Transaction State

Overall transaction state must be derived from detailed states.

Recommended values:

```text
draft
validated
order_pending
order_confirmed
payment_pending
payment_confirmed
fulfillment_pending
fulfilled
cancel_pending
cancelled
refund_pending
refunded
partially_refunded
manual_review_required
reconciliation_required
failed
voided
closed
```

The overall state is for summary only.

It must not hide internal unknown states.

---

## 10. Order Lifecycle State

Order lifecycle state represents the gateway order before and after POS write.

Recommended order states:

```text
draft
validated
created
pos_write_requested
pos_write_pending
pos_write_unknown
pos_write_confirmed
pos_write_failed
accepted_by_store
preparation_pending
preparing
ready
completed
cancel_requested
cancelled
failed
manual_review_required
reconciliation_required
```

Order state must reference:

```text
transaction_id
state
state_reason
source
created_at_utc
actor_id
provider_reference
correlation_id
```

Order state transition must be append-only.

---

## 11. POS Write State

POS write state must be separate from order state.

Recommended POS write states:

```text
not_requested
request_prepared
request_sent
acknowledged
pending
confirmed_written
confirmed_not_written
unknown
retry_scheduled
manual_lookup_required
manual_pos_entry_required
duplicate_detected
failed
dead_lettered
```

The gateway must not treat `request_sent` as `confirmed_written`.

POS write success requires provider evidence or manual verified evidence.

---

## 12. Payment State

Payment state must represent financial mutation uncertainty.

Recommended payment states:

```text
not_required
not_started
authorization_requested
authorization_pending
authorized
capture_requested
capture_pending
captured
confirmed_paid
confirmed_failed
unknown
duplicate_risk
manual_verification_required
cancel_requested
cancelled
failed
reconciliation_required
```

Payment unknown must block unsafe customer instruction.

The system must not ask the customer to pay again until duplicate risk is reviewed.

---

## 13. Payment Route Metadata Binding

Payment state must support multi-VAN/PG/card-company route metadata.

Required fields where available:

```text
payment_route_id
van_provider_code
pg_provider_code
card_company_code
issuer_code
acquirer_code
merchant_id
terminal_id
approval_number
payment_method
currency_code
country_code
provider_payment_reference
```

Domestic MVP may not fill all fields, but schema must allow them.

Settlement reconciliation later depends on these fields.

---

## 14. Cancellation State

Cancellation state must be distinct from order failure.

Recommended cancellation states:

```text
not_requested
requested
validation_pending
provider_cancel_requested
provider_cancel_pending
cancel_confirmed
cancel_rejected
cancel_failed
cancel_unknown
manual_review_required
reconciliation_required
```

Cancellation must reference:

- order state;
- payment state;
- POS write state;
- provider cancellation reference;
- customer message state;
- approval reference where required.

Cancellation success must not be assumed from request submission.

---

## 15. Refund State

Refund state must be distinct from cancellation state.

Recommended refund states:

```text
not_required
not_requested
requested
eligibility_review
approval_required
approved
provider_refund_requested
provider_refund_pending
refund_confirmed
refund_rejected
refund_failed
refund_unknown
partial_refund_confirmed
manual_review_required
reconciliation_required
```

Refund confirmed requires provider evidence, payment provider evidence, or approved manual evidence.

Refund request is not refund completion.

---

## 16. Partial Refund Readiness

The state machine must support partial refund even if MVP does not enable it.

Required fields:

```text
refund_amount_minor
refund_currency_code
refund_reason_code
refund_line_refs
remaining_refundable_amount_minor
partial_refund_sequence
```

If partial refund is not supported by provider, capability registry must block it.

The state model must not require rewrite later.

---

## 17. State Transition Record

Every state transition must create a transition record.

Required fields:

```text
state_transition_id
transaction_id
state_domain
from_state
to_state
transition_reason
actor_type
actor_id
source_system
provider_id
provider_reference
approval_reference
created_at_utc
correlation_id
causation_id
```

State domains:

```text
order
pos_write
payment
cancel
refund
fulfillment
customer_status
manual_review
reconciliation
```

Transitions must be append-only.

---

## 18. Transaction Timeline Event

Transaction timeline must aggregate important events across domains.

Required fields:

```text
timeline_event_id
transaction_id
event_type
event_domain
event_summary
event_payload_ref
actor_type
actor_id
source_system
provider_id
created_at_utc
store_local_time
business_date_local
correlation_id
causation_id
```

Timeline events should be readable by support, reconciliation, incident, and audit tools.

Sensitive payloads must be referenced, not copied raw.

---

## 19. External Reference Binding

External provider references must be stored separately.

Required fields:

```text
external_reference_id
transaction_id
provider_id
provider_type
reference_type
reference_value
reference_status
created_at_utc
updated_at_utc
```

Reference types:

```text
pos_order_id
payment_reference
approval_number
cancel_reference
refund_reference
receipt_reference
kds_ticket_id
delivery_order_id
settlement_reference
```

One transaction may have multiple external references.

---

## 20. Unknown State Handling

Unknown states are first-class.

Unknown may occur when:

- provider timeout after mutation request;
- network loss after request sent;
- provider returns ambiguous error;
- webhook delayed;
- POS lookup unavailable;
- payment lookup unavailable;
- cancellation/refund status unavailable;
- manual fallback evidence missing.

Unknown state must trigger:

```text
manual_verification_required
reconciliation_required
customer_safe_uncertainty_message
retry_or_lookup_policy
incident_if_threshold_exceeded
```

Unknown must not be converted to failure without evidence.

---

## 21. Manual Review Marker

Manual review marker identifies states requiring human action.

Required fields:

```text
manual_review_marker_id
transaction_id
review_type
reason_code
related_state_domain
severity
assigned_role
assigned_actor_id
created_at_utc
resolved_at_utc
resolution_reference
status
```

Review types:

```text
payment_unknown
pos_write_unknown
cancel_unknown
refund_unknown
sold_out_after_payment
wrong_table_risk
duplicate_risk
provider_limitation
manual_pos_entry_required
```

Manual review marker is later handled by the manual fallback work package.

---

## 22. Reconciliation Required Marker

Reconciliation marker identifies transaction states requiring financial or evidence reconciliation.

Required fields:

```text
reconciliation_marker_id
transaction_id
reason_code
state_domain
amount_minor
currency_code
provider_id
external_reference_id
created_at_utc
resolved_at_utc
reconciliation_case_id
status
```

Reason codes:

```text
payment_unknown
refund_unknown
cancel_unknown
pos_payment_mismatch
receipt_missing
amount_mismatch
duplicate_risk
provider_settlement_pending
manual_adjustment_required
```

Markers later create reconciliation cases.

---

## 23. Customer-Safe Projection

Customer-safe projection must translate internal states into safe display states.

Required fields:

```text
customer_safe_projection_id
transaction_id
projection_state
confidence_level
message_template_code
last_evidence_reference
created_at_utc
updated_at_utc
```

Recommended projection states:

```text
order_received
order_checking
payment_checking
payment_confirmed
preparing
ready
completed
cancel_checking
cancel_confirmed
refund_checking
refund_confirmed
staff_review_required
temporarily_unavailable
```

Customer projection must not expose internal provider errors or unsupported certainty.

---

## 24. State Confidence Model

Every customer-safe projection should include confidence.

Recommended confidence levels:

```text
confirmed
provider_confirmed
staff_confirmed
pending
unknown
conflict_detected
manual_review_required
```

For example:

- payment request sent = pending;
- payment provider confirmed = provider_confirmed;
- staff saw approval slip = staff_confirmed;
- timeout after request = unknown;
- provider and POS disagree = conflict_detected.

---

## 25. State Transition Validation

State transition validation must prevent illegal transitions.

Examples:

- refund cannot be confirmed before payment confirmed;
- POS write cannot be confirmed without provider or manual evidence;
- order cannot be completed when KDS state is missing for required channel;
- cancellation cannot be confirmed from unknown provider state without evidence;
- payment failed cannot follow payment unknown without lookup or verification;
- closed transaction cannot accept new mutation except controlled correction.

Illegal transition must be rejected and audited.

---

## 26. State Transition Idempotency Readiness

This work package must prepare for idempotency.

Every mutation request must carry:

```text
idempotency_key
correlation_id
causation_id
request_source
request_hash
```

The actual idempotency store is implemented in `06340`.

This work package ensures state transition model can accept idempotency references.

---

## 27. Provider Adapter Integration Readiness

This work package must prepare for provider adapter responses.

Adapter response must be able to update:

- POS write state;
- payment state;
- cancellation state;
- refund state;
- external references;
- timeline events;
- manual review markers;
- reconciliation markers.

Provider response classification must include:

```text
confirmed_success
confirmed_failure
pending
unknown
retryable_failure
non_retryable_failure
duplicate_detected
manual_lookup_required
```

Adapter implementation is later, but state model must support the outcomes.

---

## 28. KDS and Fulfillment Readiness

Fulfillment state may be minimal in this work package but must exist.

Recommended fulfillment states:

```text
not_required
kds_ticket_pending
kds_ticket_confirmed
preparation_pending
preparing
ready
served
picked_up
delivery_handoff
completed
failed
manual_review_required
```

Detailed KDS routing is handled later, but order timeline must support fulfillment events.

---

## 29. Cancellation and Refund Dependency Rules

Cancellation and refund behavior depends on transaction state.

Examples:

```text
order not paid -> cancellation may void order only
paid but not fulfilled -> cancellation may require payment cancel or refund
fulfilled order -> refund may require manager approval
payment unknown -> cancellation/refund must wait or route manual review
POS write unknown -> cancellation must verify POS state first
```

The state machine must allow dependency checks before initiating cancel/refund.

---

## 30. Closed Transaction Rule

A transaction may be closed only when:

- order state final;
- payment/cancel/refund state final or not required;
- POS write state final or manually resolved;
- fulfillment state final or not required;
- reconciliation markers closed or accepted;
- customer dispute not open;
- required audit evidence exists.

Closed does not mean deleted.

Closed means normal mutation is no longer allowed.

---

## 31. Correction Event Rule

If a closed or final transaction needs correction, the system must create a correction event.

Correction must not overwrite historical state.

Correction examples:

- manual adjustment;
- late refund confirmation;
- provider settlement correction;
- receipt reference correction;
- customer dispute resolution;
- tax/accounting correction.

Correction events must be additive and audited.

---

## 32. Data Model Draft

Recommended table group:

```text
pos_gateway_transactions
pos_gateway_transaction_business_contexts
pos_gateway_transaction_financial_contexts
pos_gateway_order_states
pos_gateway_pos_write_states
pos_gateway_payment_states
pos_gateway_cancel_states
pos_gateway_refund_states
pos_gateway_fulfillment_states
pos_gateway_state_transitions
pos_gateway_transaction_timeline_events
pos_gateway_external_references
pos_gateway_manual_review_markers
pos_gateway_reconciliation_markers
pos_gateway_customer_safe_projections
```

The implementation may use event sourcing or state tables, but final behavior must remain reconstructable.

---

## 33. API Requirements

Recommended internal APIs or service methods:

```text
createGatewayTransaction()
validateTransactionContext()
transitionOrderState()
transitionPosWriteState()
transitionPaymentState()
transitionCancelState()
transitionRefundState()
appendTransactionTimelineEvent()
bindExternalReference()
markManualReviewRequired()
markReconciliationRequired()
deriveCustomerSafeProjection()
validateStateTransition()
closeTransaction()
appendCorrectionEvent()
```

All state mutation APIs must audit transition.

---

## 34. Denial and Error Reason Codes

Recommended reason codes:

```text
invalid_state_transition
missing_calculation_snapshot
missing_business_context
missing_provider_route
payment_state_unknown
pos_write_state_unknown
refund_not_allowed
cancel_not_allowed
manual_review_required
reconciliation_required
provider_reference_missing
evidence_missing
transaction_closed
duplicate_mutation_risk
capability_not_supported
```

Reason codes must be internal first.

Customer-facing mapping happens through customer status/message policy.

---

## 35. Audit Event Requirements

Required audit events:

```text
pos_gateway.transaction.created
pos_gateway.transaction.business_context_bound
pos_gateway.transaction.financial_context_bound
pos_gateway.transaction.order_state_changed
pos_gateway.transaction.pos_write_state_changed
pos_gateway.transaction.payment_state_changed
pos_gateway.transaction.cancel_state_changed
pos_gateway.transaction.refund_state_changed
pos_gateway.transaction.fulfillment_state_changed
pos_gateway.transaction.external_reference_bound
pos_gateway.transaction.manual_review_required
pos_gateway.transaction.reconciliation_required
pos_gateway.transaction.customer_projection_updated
pos_gateway.transaction.closed
pos_gateway.transaction.correction_appended
```

Audit must include:

```text
transaction_id
tenant_id
store_id
state_domain
from_state
to_state
reason
actor_id
created_at_utc
correlation_id
```

---

## 36. Monitoring Requirements

Monitoring must detect:

- high payment unknown count;
- high POS write unknown count;
- high refund unknown count;
- high cancellation unknown count;
- illegal transition rejection spike;
- manual review backlog;
- reconciliation marker backlog;
- transactions stuck in pending state;
- customer projection conflict;
- closed transaction correction spike;
- missing external references;
- missing business context.

Monitoring thresholds must be scoped by tenant, store, provider, and channel.

---

## 37. Test Requirements

Required tests:

```text
transaction creation requires registry context test
transaction requires calculation snapshot test
business context snapshot immutability test
order state transition test
POS write unknown preservation test
payment unknown preservation test
payment duplicate risk state test
cancel dependency validation test
refund dependency validation test
partial refund readiness test
manual review marker creation test
reconciliation marker creation test
customer-safe projection test
illegal transition rejection test
closed transaction mutation block test
correction event append-only test
external reference binding test
timeline reconstruction test
```

State machine tests must run before adapter and queue implementation is trusted.

---

## 38. Acceptance Criteria

This work package is acceptable only when:

- gateway transaction root exists;
- business context binding exists;
- financial context binding exists;
- order lifecycle state exists;
- POS write state exists;
- payment state exists;
- cancellation state exists;
- refund state exists;
- transaction timeline exists;
- external reference binding exists;
- unknown state handling exists;
- manual review marker exists;
- reconciliation marker exists;
- customer-safe projection exists;
- state confidence model exists;
- state transition validation exists;
- idempotency readiness exists;
- adapter response readiness exists;
- fulfillment readiness exists;
- cancellation/refund dependency rules exist;
- closed transaction and correction event rules exist;
- audit events, monitoring, tests, and denial codes exist.

---

## 39. Relationship To Adjacent Documents

This document is related to:

- 06320 POS Gateway menu mapping, price, availability, and calculation snapshot implementation work package;
- 06310 POS Gateway core registry, tenant, store, provider capability, and environment binding implementation work package;
- 06305 POS Gateway global scale final boss risk absorption architecture invariant implementation guardrail;
- 06300 POS Gateway implementation task breakdown, executable work package index, and build sequence policy;
- 06120 POS Gateway reconciliation case workflow, variance resolution, manual adjustment, and audit closure policy;
- 06110 POS Gateway customer status message, receipt proof, notification, and dispute communication policy;
- 06100 POS Gateway staff operation, manual fallback, override authority, and manager approval policy;
- 06060 POS Gateway price, promotion, discount, coupon, tax, service charge, and total calculation integrity policy.

Where conflict exists, this document governs implementation of the POS Gateway transaction state machine, state transitions, unknown-state handling, and transaction timeline.

---

## 40. Summary

The POS Gateway transaction state machine is the heart of the implementation spine.

It must preserve the difference between:

- requested and confirmed;
- pending and successful;
- unknown and failed;
- customer-safe message and internal truth;
- payment and refund;
- cancellation and order failure;
- POS write and gateway order creation.

A gateway that collapses these states will eventually create duplicate payments, false refunds, wrong receipts, broken reconciliation, and customer disputes.

A gateway that preserves uncertainty can survive provider failure, network failure, staff fallback, and financial audit.

The state machine must be strict now so the platform can scale safely later.