# 14157_WorkPackage_POS_Gateway_Table_QR_NFC_Kiosk_Device_Receipt_Proof_And_Customer_Status

## 1. Purpose

This document defines the implementation work package for POS Gateway table identity, QR/NFC object identity, kiosk/device identity, receipt/proof records, and customer-safe transaction status.

After the gateway can resolve registry context, validate menu/price/availability, maintain transaction state, prevent duplicate mutations, and call POS/KDS adapters through normalized contracts, it must correctly bind the transaction to the physical and customer-facing surface.

In real store operation, transaction truth can be corrupted by:

- wrong table QR scan;
- stale QR/NFC object;
- duplicated QR label;
- moved table;
- merged/split table session;
- kiosk device registered to wrong store;
- payment terminal bound to wrong kiosk;
- staff tablet using wrong store context;
- receipt missing or delayed;
- customer shown payment success before proof exists;
- customer shown order confirmed before POS write is confirmed;
- customer support seeing internal unknown state as final status.

This work package creates the physical identity and customer proof layer required before broader QR/table/kiosk/store operation.

---

## 2. Scope

This work package covers implementation planning for:

- table registry;
- seat and table zone reference;
- table session;
- table transfer, merge, and split events;
- QR object registry;
- NFC object registry;
- object token validation;
- QR/NFC rotation and suspension;
- kiosk device registry;
- staff device registry reference;
- payment terminal association reference;
- device trust state;
- receipt proof record;
- payment proof record;
- cancellation proof record;
- refund proof record;
- customer-safe status projection;
- customer-facing status confidence;
- customer notification state reference;
- proof lookup integration point;
- customer support read model;
- audit events;
- monitoring and tests.

This document is a work package.  
It identifies what must be built and verified.

Detailed Store Console workflows should move to the `06500` band.

---

## 3. Core Principle

Physical identity and customer-facing proof must never be guessed.

The POS Gateway must distinguish:

```text
visible table number
registered table object
active table session
customer scan token
device identity
payment terminal association
POS receipt proof
payment approval proof
refund proof
customer-safe status
```

A customer-facing status must be derived from verified internal state and proof references.

The system must never display unsupported certainty just because a request was sent.

---

## 4. Implementation Position

This work package follows:

```text
06310_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding.md
06320_WorkPackage_POS_Gateway_Menu_Mapping_Price_Availability_And_Calculation_Snapshot.md
06330_WorkPackage_POS_Gateway_Order_Payment_Cancel_Refund_State_Machine_And_Transaction_Timeline.md
14156_WorkPackage_POS_Gateway_Idempotency_Queue_Retry_Dead_Letter_Replay_And_Duplicate_Prevention.md
06350_WorkPackage_POS_Gateway_POS_KDS_Adapter_Interface_Routing_Error_Normalization_And_Provider_Contract.md
```

This work package precedes:

```text
14158_WorkPackage_POS_Gateway_Manual_Fallback_Manager_Approval_Staff_Action_And_Override.md
14159_WorkPackage_POS_Gateway_Reconciliation_Audit_Evidence_Settlement_And_Accounting_Guard.md
14160_WorkPackage_POS_Gateway_Monitoring_Incident_Disaster_Recovery_Pilot_Readiness_And_Closeout.md
```

Table, device, proof, and customer status models must exist before QR/table/kiosk operation is widely enabled.

---

## 5. Required Work Domains

The implementation plan must cover these domains:

```text
table_registry
seat_registry
table_zone
table_session
table_session_event
qr_object_registry
nfc_object_registry
object_token
object_validation_result
device_registry
kiosk_device_binding
staff_device_binding
payment_terminal_binding
device_trust_state
receipt_proof
payment_proof
cancel_proof
refund_proof
customer_status_projection
customer_status_confidence
customer_notification_state
customer_support_read_model
```

These may be implemented as separate tables or strongly separated logical models.

The key requirement is that physical identity, proof, and customer-safe status remain traceable.

---

## 6. Table Registry

Table registry defines store table identity.

Required fields:

```text
table_id
tenant_id
store_id
table_code
table_display_name
table_zone_id
default_capacity
current_status
created_at_utc
updated_at_utc
status
```

Recommended current statuses:

```text
available
occupied
reserved
cleaning
disabled
merged
unknown
```

Visible display name must not be treated as unique proof of table identity.

---

## 7. Seat Registry

Seat registry may be used when seat-level ordering or object binding is required.

Required fields:

```text
seat_id
tenant_id
store_id
table_id
seat_code
seat_display_name
status
created_at_utc
updated_at_utc
```

Seat-level identity is optional for MVP but must be supported for advanced dining, bar seating, or shared-table models.

---

## 8. Table Zone Model

Table zone supports KDS routing, service area, and operational grouping.

Required fields:

```text
table_zone_id
tenant_id
store_id
zone_code
zone_name
service_area_type
kds_route_hint
status
created_at_utc
updated_at_utc
```

Example zone types:

```text
hall
counter
terrace
private_room
pickup_area
bar
shared_table
```

Zone may affect routing, staff responsibility, and service flow.

---

## 9. Table Session

Table session represents an active customer/store occupancy context.

Required fields:

```text
table_session_id
tenant_id
store_id
table_id
seat_id
session_status
opened_at_utc
closed_at_utc
business_date_local
local_timezone_name
local_timezone_offset_minutes
opened_by_actor_id
closed_by_actor_id
status
```

Recommended session statuses:

```text
opening
active
payment_pending
closing
closed
transferred
merged
split
manual_review_required
```

A QR/table order must bind to an active or valid table session unless channel policy allows sessionless ordering.

---

## 10. Table Session Event

Table session changes must be evented.

Required fields:

```text
table_session_event_id
table_session_id
event_type
from_table_id
to_table_id
from_session_id
to_session_id
actor_id
reason_code
created_at_utc
correlation_id
```

Recommended event types:

```text
session_opened
session_closed
table_transferred
table_merged
table_split
seat_changed
manual_correction
session_reopened
```

Events must be append-only.

---

## 11. QR Object Registry

QR object registry binds a physical QR label/object to a table, seat, store, or service point.

Required fields:

```text
qr_object_id
tenant_id
store_id
object_code
object_type
bound_table_id
bound_seat_id
token_version
current_token_ref
object_status
installed_at_utc
last_rotated_at_utc
status
```

Recommended object types:

```text
table_qr
seat_qr
pickup_qr
kiosk_qr
counter_qr
waiting_area_qr
```

QR object must be validated before order context is trusted.

---

## 12. NFC Object Registry

NFC object registry binds NFC tags or objects to store/table/session context.

Required fields:

```text
nfc_object_id
tenant_id
store_id
object_code
object_type
bound_table_id
bound_seat_id
nfc_uid_hash
token_version
object_status
installed_at_utc
last_rotated_at_utc
status
```

Raw NFC UID must not be exposed unnecessarily.

Hashed or tokenized representation should be used where possible.

---

## 13. Object Token Model

QR/NFC tokens must be versioned and revocable.

Required fields:

```text
object_token_id
tenant_id
store_id
object_type
object_id
token_hash
token_version
issued_at_utc
expires_at_utc
rotated_from_token_id
revoked_at_utc
status
```

Recommended statuses:

```text
active
expired
revoked
suspended
rotated
compromised
```

Token rotation must not break active sessions unless explicitly required.

---

## 14. Object Validation Result

Every QR/NFC scan must produce validation result.

Required fields:

```text
object_validation_result_id
tenant_id
store_id
object_type
object_id
token_version
validation_status
denial_reason
table_id
seat_id
table_session_id
validated_at_utc
correlation_id
```

Recommended validation statuses:

```text
valid
expired
revoked
suspended
wrong_store
unbound
stale
manual_review_required
```

Invalid object must not create a trusted order context.

---

## 15. QR/NFC Suspension and Rotation

QR/NFC objects must support suspension and rotation.

Suspension reasons:

```text
lost_object
damaged_label
wrong_table_detected
suspected_copy
store_layout_changed
incident_response
security_rotation
```

Suspended object must block new order context.

Existing orders must remain linked to the original object validation result.

---

## 16. Kiosk Device Registry

Kiosk device registry binds device identity to tenant/store/channel.

Required fields:

```text
kiosk_device_id
tenant_id
store_id
device_code
device_name
device_serial_hash
device_role
channel_scope
bound_payment_terminal_id
device_status
registered_at_utc
last_seen_at_utc
status
```

Recommended device statuses:

```text
registered
active
offline
degraded
suspended
lost
retired
unknown
```

Kiosk must not accept orders when device identity is unknown or bound to the wrong store.

---

## 17. Staff Device Binding

Staff device binding may be used for tablets or mobile admin operation.

Required fields:

```text
staff_device_binding_id
tenant_id
store_id
device_id
actor_id
device_role
trust_level
last_seen_at_utc
status
```

Device trust must be considered when allowing manual fallback, approval, or sensitive transaction actions.

---

## 18. Payment Terminal Binding

Payment terminal binding connects payment hardware or provider terminal to store/device context.

Required fields:

```text
payment_terminal_id
tenant_id
store_id
provider_id
terminal_code
terminal_serial_hash
bound_device_id
merchant_id
payment_route_id
terminal_status
registered_at_utc
status
```

Payment terminal binding is critical for:

- settlement route;
- receipt proof;
- payment route metadata;
- device-level troubleshooting;
- duplicate payment investigation.

---

## 19. Device Trust State

Device trust state determines whether a device can perform sensitive actions.

Recommended trust states:

```text
trusted
limited_trust
requires_reauth
suspended
lost
retired
unknown
```

Sensitive actions requiring trusted or reauthenticated device may include:

- refund approval;
- manual payment verification;
- manual POS correction;
- evidence export;
- emergency override;
- store context switching.

---

## 20. Receipt Proof Record

Receipt proof record represents evidence that a POS receipt or provider receipt exists.

Required fields:

```text
receipt_proof_id
transaction_id
tenant_id
store_id
provider_id
receipt_reference
receipt_number
receipt_amount_minor
currency_code
receipt_created_at_utc
receipt_business_date_local
proof_source
proof_status
raw_receipt_payload_ref
created_at_utc
status
```

Recommended proof statuses:

```text
not_requested
pending
confirmed
not_found
unknown
manual_verified
failed
```

Receipt proof is not the same as gateway order creation.

---

## 21. Payment Proof Record

Payment proof record represents payment approval or settlement-relevant evidence.

Required fields:

```text
payment_proof_id
transaction_id
payment_state_id
provider_id
payment_route_id
approval_number
provider_payment_reference
approved_amount_minor
currency_code
approved_at_utc
proof_source
proof_status
created_at_utc
status
```

Payment proof may come from:

```text
payment_provider
POS_provider
VAN_provider
PG_provider
manual_staff_verification
settlement_report
```

Manual proof must be clearly marked as manual.

---

## 22. Cancellation Proof Record

Cancellation proof record represents confirmed cancellation evidence.

Required fields:

```text
cancel_proof_id
transaction_id
cancel_state_id
provider_id
cancel_reference
cancel_amount_minor
currency_code
cancel_confirmed_at_utc
proof_source
proof_status
created_at_utc
status
```

Cancellation request is not cancellation proof.

If cancellation proof is missing, customer-safe status must remain pending or review-required.

---

## 23. Refund Proof Record

Refund proof record represents confirmed refund evidence.

Required fields:

```text
refund_proof_id
transaction_id
refund_state_id
provider_id
refund_reference
refund_amount_minor
currency_code
refund_confirmed_at_utc
partial_refund_sequence
proof_source
proof_status
created_at_utc
status
```

Refund proof must support partial refund and multiple refund events.

Refund promised is not refund confirmed.

---

## 24. Proof Source Model

Recommended proof sources:

```text
provider_api
provider_webhook
POS_lookup
payment_lookup
receipt_lookup
settlement_report
manual_staff_verification
manager_approval
reconciliation_case
```

Proof source must be visible to support, reconciliation, and audit.

A manual proof source may be acceptable but must not be confused with provider-confirmed proof.

---

## 25. Customer Status Projection

Customer status projection maps internal transaction state into safe customer-facing state.

Required fields:

```text
customer_status_projection_id
transaction_id
projection_state
confidence_level
message_template_code
proof_reference
last_state_domain
last_updated_at_utc
status
```

Projection must derive from:

- order state;
- POS write state;
- payment state;
- cancel/refund state;
- fulfillment state;
- proof records;
- manual review markers;
- reconciliation markers.

Projection must not be manually edited without audit.

---

## 26. Customer Projection States

Recommended customer projection states:

```text
order_received
order_checking
order_confirmed
payment_checking
payment_confirmed
payment_needs_staff_check
preparing
ready_for_pickup
served_or_completed
cancel_checking
cancel_confirmed
refund_checking
refund_confirmed
staff_review_required
temporarily_unavailable
failed_with_staff_assistance
```

Projection states must avoid unsupported finality.

For example:

- `payment_checking` is safer than `payment_failed` when payment result is unknown;
- `refund_checking` is safer than `refund_completed` when provider proof is missing.

---

## 27. Customer Status Confidence

Recommended confidence levels:

```text
system_confirmed
provider_confirmed
staff_confirmed
pending
unknown
conflict_detected
manual_review_required
reconciliation_required
```

Customer-facing UI may hide internal labels, but the internal confidence must remain recorded.

Customer communication logic must use confidence level.

---

## 28. Customer Notification State

Notification state tracks whether customer was notified.

Required fields:

```text
customer_notification_state_id
transaction_id
notification_type
message_template_code
delivery_channel
delivery_status
sent_at_utc
delivered_at_utc
failure_reason
status
```

Delivery channels may include:

```text
web_app
native_app
sms
kakao
email
staff_verbal
receipt_print
kiosk_display
```

Staff verbal notice may be recorded as manual communication evidence.

---

## 29. Customer Support Read Model

Support read model must expose customer-safe evidence.

Support should see:

- transaction summary;
- customer-safe status;
- payment proof status;
- receipt proof status;
- cancel/refund proof status;
- manual review state;
- customer message history;
- escalation status.

Support should not see by default:

- raw provider payload;
- secrets;
- full payment data;
- unrelated customer data;
- internal credentials;
- sensitive audit payloads.

---

## 30. Wrong Table Risk Handling

Wrong table risk must be detected when:

- object token points to different table than active session;
- table has been transferred;
- session closed but token reused;
- QR object copied;
- device/store mismatch;
- staff correction changes table after order.

Wrong table risk must trigger:

```text
manual_review_marker
customer_status_projection = staff_review_required
audit_event
optional_order_hold
```

The gateway must not silently route food to a wrong table.

---

## 31. Kiosk Device Risk Handling

Kiosk device risk must be detected when:

- device unregistered;
- device bound to wrong store;
- payment terminal mismatch;
- device suspended;
- device offline during payment;
- device clock drift suspicious;
- kiosk channel disabled;
- unknown device attempts order.

Risk must trigger:

```text
block_order_or_payment
device_incident_marker
staff_assist_mode
audit_event
```

Kiosk identity is a transaction boundary.

---

## 32. Receipt Missing Handling

Receipt missing does not always mean order/payment failed.

Receipt missing handling must:

- preserve order/payment state;
- mark proof pending or unknown;
- schedule receipt lookup if supported;
- create reconciliation marker if financial proof risk exists;
- show customer-safe message;
- avoid false refund/cancel action.

Receipt proof may arrive later.

---

## 33. Proof Conflict Handling

Proof conflict occurs when:

- payment proof amount differs from calculation snapshot;
- receipt amount differs from payment amount;
- refund proof amount differs from refund request;
- POS receipt exists but gateway order failed;
- payment proof exists but POS order missing;
- cancellation proof conflicts with order state.

Proof conflict must create reconciliation marker and possibly incident.

---

## 34. Data Model Draft

Recommended table group:

```text
pos_gateway_table_zones
pos_gateway_tables
pos_gateway_seats
pos_gateway_table_sessions
pos_gateway_table_session_events
pos_gateway_qr_objects
pos_gateway_nfc_objects
pos_gateway_object_tokens
pos_gateway_object_validation_results
pos_gateway_kiosk_devices
pos_gateway_staff_device_bindings
pos_gateway_payment_terminals
pos_gateway_device_trust_states
pos_gateway_receipt_proofs
pos_gateway_payment_proofs
pos_gateway_cancel_proofs
pos_gateway_refund_proofs
pos_gateway_customer_status_projections
pos_gateway_customer_notification_states
pos_gateway_customer_support_read_models
pos_gateway_proof_conflicts
```

The implementation may separate read models from canonical state tables, but proof and identity records must remain auditable.

---

## 35. API Requirements

Recommended internal APIs or service methods:

```text
registerTable()
openTableSession()
closeTableSession()
transferTableSession()
mergeTableSessions()
splitTableSession()
registerQrObject()
registerNfcObject()
rotateObjectToken()
suspendObjectToken()
validateObjectToken()
registerKioskDevice()
bindPaymentTerminal()
updateDeviceTrustState()
createReceiptProof()
createPaymentProof()
createCancelProof()
createRefundProof()
deriveCustomerStatusProjection()
recordCustomerNotificationState()
buildCustomerSupportReadModel()
detectProofConflict()
detectWrongTableRisk()
detectKioskDeviceRisk()
```

All sensitive state changes must emit audit events.

---

## 36. Denial Reason Codes

Recommended denial reason codes:

```text
table_not_found
table_session_missing
table_session_closed
table_session_conflict
qr_token_expired
qr_token_revoked
qr_object_suspended
nfc_object_suspended
object_wrong_store
object_unbound
wrong_table_risk
device_unregistered
device_wrong_store
device_suspended
payment_terminal_mismatch
receipt_proof_missing
payment_proof_missing
refund_proof_missing
proof_conflict_detected
customer_status_uncertain
manual_review_required
```

Denial reason codes must be mapped to customer-safe messages.

---

## 37. Audit Event Requirements

Required audit events:

```text
pos_gateway.table.registered
pos_gateway.table.session_opened
pos_gateway.table.session_closed
pos_gateway.table.session_transferred
pos_gateway.table.session_merged
pos_gateway.table.session_split
pos_gateway.object.qr_registered
pos_gateway.object.nfc_registered
pos_gateway.object.token_rotated
pos_gateway.object.token_suspended
pos_gateway.object.validation_completed
pos_gateway.device.kiosk_registered
pos_gateway.device.payment_terminal_bound
pos_gateway.device.trust_state_changed
pos_gateway.proof.receipt_created
pos_gateway.proof.payment_created
pos_gateway.proof.cancel_created
pos_gateway.proof.refund_created
pos_gateway.customer_status.projection_updated
pos_gateway.customer_notification.state_recorded
pos_gateway.proof.conflict_detected
pos_gateway.identity.wrong_table_risk_detected
pos_gateway.identity.kiosk_device_risk_detected
```

Audit must include:

```text
tenant_id
store_id
transaction_id
table_id
table_session_id
object_id
device_id
proof_id
actor_id
created_at_utc
correlation_id
```

---

## 38. Monitoring Requirements

Monitoring must detect:

- invalid QR/NFC scans;
- suspended object scan attempts;
- wrong table risk count;
- table session conflict count;
- kiosk wrong-store attempts;
- device offline rate;
- payment terminal mismatch;
- receipt proof pending backlog;
- payment proof missing count;
- refund proof pending backlog;
- proof conflict count;
- customer status unknown backlog;
- notification failure count.

Monitoring must be scoped by tenant, store, table zone, device, provider, and channel.

---

## 39. Alert Requirements

Critical alerts:

```text
wrong_table_risk_detected
qr_token_copy_suspected
kiosk_device_wrong_store
payment_terminal_mismatch
payment_proof_missing_after_confirmed_payment
refund_proof_missing_after_refund_request
receipt_proof_conflict
customer_status_unknown_spike
notification_failure_spike
```

Alerts must link to manual fallback, reconciliation, or incident runbook.

---

## 40. Test Requirements

Required tests:

```text
table_session_open_close_test
table_transfer_event_test
table_merge_split_event_test
qr_token_validation_success_test
qr_token_expired_block_test
qr_token_revoked_block_test
nfc_object_validation_test
wrong_table_risk_detection_test
kiosk_device_binding_test
kiosk_wrong_store_block_test
payment_terminal_binding_test
receipt_proof_creation_test
payment_proof_creation_test
cancel_proof_creation_test
refund_proof_partial_sequence_test
customer_status_projection_from_unknown_payment_test
customer_status_projection_from_confirmed_payment_test
proof_conflict_detection_test
support_read_model_redaction_test
notification_state_record_test
```

QR/table/kiosk operations must not be enabled without identity validation tests.

---

## 41. Acceptance Criteria

This work package is acceptable only when:

- table registry exists;
- seat and table zone models exist where needed;
- table session and table session event models exist;
- QR and NFC object registries exist;
- object token versioning, validation, suspension, and rotation exist;
- kiosk device registry exists;
- staff device and payment terminal binding references exist;
- device trust state exists;
- receipt proof, payment proof, cancel proof, and refund proof records exist;
- proof source model exists;
- customer status projection exists;
- customer status confidence exists;
- customer notification state exists;
- customer support read model exists;
- wrong table risk handling exists;
- kiosk device risk handling exists;
- receipt missing and proof conflict handling exist;
- APIs, denial codes, audit events, monitoring, alerts, and tests exist.

---

## 42. Relationship To Adjacent Documents

This document is related to:

- 06350 WorkPackage POS Gateway POS/KDS adapter interface, routing, error normalization, and provider contract;
- 06340 WorkPackage POS Gateway idempotency, queue, retry, dead-letter, replay, and duplicate prevention;
- 06330 WorkPackage POS Gateway order, payment, cancel, refund state machine, and transaction timeline;
- 06320 WorkPackage POS Gateway menu mapping, price, availability, and calculation snapshot;
- 06310 WorkPackage POS Gateway core registry, tenant, store, provider capability, and environment binding;
- 06090 Policy POS Gateway table, session, seat, object, QR, NFC, device identity, and handoff integrity;
- 06110 Policy POS Gateway customer status message, receipt proof, notification, and dispute communication;
- 06080 Policy POS Gateway order channel separation, dine-in, takeout, delivery, kiosk, table QR, and staff order routing.

Where conflict exists, this document governs implementation work planning for table/QR/NFC/kiosk device identity, receipt/proof records, and customer-safe status projection for POS Gateway operations.

---

## 43. Summary

The POS Gateway does not only move data between software systems.

It binds software transactions to physical tables, QR labels, NFC objects, kiosks, payment terminals, receipts, and customer-facing truth.

The correct implementation standard is:

- validate table/session identity;
- validate QR/NFC object identity;
- validate kiosk/device identity;
- bind payment terminal context;
- record proof separately from request;
- distinguish receipt proof, payment proof, cancel proof, and refund proof;
- derive customer status from evidence and confidence;
- expose customer-safe read models;
- detect wrong-table and proof-conflict risk.

A wrong table or false payment status can damage customer trust as much as a failed API call.

Physical identity and proof must therefore be first-class parts of the transaction spine.