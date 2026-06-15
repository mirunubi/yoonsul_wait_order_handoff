# 04303_Policy_POS_Adapter_Runtime_Data_Object_And_Event_Family

## 1. Purpose

This document defines the POS Adapter Runtime data object and event family policy.

The purpose of this policy is to identify the conceptual runtime objects and event families required to support POS provider abstraction, payment provider integration, canonical order normalization, KDS release, customer display synchronization, replay, reconciliation, audit, and support escalation.

This document is not a final database schema.

It defines the object families and event families that implementation planning must respect.

---

## 2. Scope

This policy applies to:

* POS adapter runtime objects
* Payment provider runtime objects
* Canonical order runtime objects
* Provider event storage
* Raw payload references
* Payment request and payment event objects
* KDS release objects
* Customer display projection objects
* Diagnostic error objects
* Replay objects
* Reconciliation objects
* Support escalation objects
* Audit event linkage

This policy does not define final SQL migrations, final table names, final column types, final API endpoints, provider-specific code, or UI implementation.

---

## 3. Core Principle

Runtime objects must preserve source, authority, and replayability.

The system must not collapse external provider data, internal normalized state, payment truth, KDS execution, customer display, and support notes into one mutable order record.

The core principle is:

```text
raw provider event
        ↓
normalized internal event
        ↓
canonical order projection
        ↓
payment / KDS / display / audit / reconciliation projections
```

Source events must remain separate from projections.

Projection may change.

Source truth must not be silently rewritten.

---

## 4. Object Family Overview

The POS Adapter Runtime should include the following conceptual object families:

```text
provider family
adapter family
raw provider event family
canonical order family
order item mapping family
payment family
KDS release family
customer display family
diagnostic error family
replay family
reconciliation family
support family
audit family
```

Each family has a distinct responsibility.

No object family should silently take over another family’s authority.

---

## 5. Provider Family

Provider family objects represent external systems.

Conceptual objects include:

```text
provider
provider_capability
provider_contract
provider_credential
provider_health
provider_onboarding_evidence
provider_known_limitation
```

Provider types may include:

```text
POS
PAYMENT_PROVIDER
TABLE_ORDER
KIOSK
DELIVERY_APP
ORDER_AGGREGATOR
OPEN_BANKING
FINTECH
LEGACY_IMPORT
EXTERNAL_PARTNER
```

Provider objects describe who the external party is and what they are allowed to do.

They do not store internal order truth.

---

## 6. Adapter Family

Adapter family objects represent the internal integration layer that connects provider data to the canonical model.

Conceptual objects include:

```text
adapter
adapter_version
adapter_capability_level
adapter_mapping_version
adapter_runtime_status
adapter_certification_result
adapter_configuration
```

Adapter objects must track:

```text
provider_id
tenant_id
store_id
adapter_name
adapter_version
capability_level
enabled_status
created_at
updated_at
```

Adapter version must be recorded on every normalized event.

---

## 7. Store Provider Integration Object

Each store-provider connection must be represented separately.

Conceptual object:

```text
store_provider_integration
```

Required conceptual fields:

```text
tenant_id
store_id
provider_id
adapter_id
adapter_version
external_store_id
external_merchant_id
external_terminal_id
capability_level
enabled_capabilities
credential_reference
menu_mapping_version
table_mapping_version
payment_mapping_version
integration_status
fallback_mode
enabled_at
disabled_at
```

Provider capability may differ by store.

A provider may be Level 3 for one store and Level 1 for another.

---

## 8. Raw Provider Event Family

Raw provider event objects preserve original external input.

Conceptual objects include:

```text
raw_provider_event
raw_provider_payload
provider_webhook_event
provider_polling_result
provider_file_import_event
```

Required conceptual fields:

```text
raw_event_id
provider_id
adapter_id
tenant_id
store_id
external_event_id
external_order_id
external_payment_id
provider_event_type
provider_event_time
received_at
payload_hash
raw_payload_reference
verification_status
processing_status
```

Raw provider events must not be edited to fit internal state.

---

## 9. Provider Event Verification Object

Provider event verification must be tracked separately.

Conceptual object:

```text
provider_event_verification
```

Required conceptual fields:

```text
raw_event_id
provider_id
verification_method
verification_status
signature_status
secret_status
duplicate_check_status
timestamp_check_status
amount_check_status
verified_at
verification_error_code
```

Webhook received is not webhook verified.

Provider event verification must be complete before authority-sensitive state changes.

---

## 10. Canonical Order Family

Canonical order objects represent the internal normalized order.

Conceptual objects include:

```text
canonical_order
canonical_order_event
canonical_order_projection
canonical_order_state_snapshot
```

Minimum conceptual fields:

```text
internal_order_id
tenant_id
store_id
order_source
order_channel
external_provider_name
external_store_id
external_order_id
customer_session_id
seating_session_id
table_reference
order_status
payment_status
fulfillment_status
kitchen_release_status
subtotal_amount
discount_amount
tax_amount
service_charge_amount
total_amount
currency
source_confidence
normalization_status
adapter_version
raw_payload_reference
created_at
updated_at
```

Canonical order is internal operational language.

It is not the raw POS payload.

---

## 11. Canonical Order Event Family

Canonical order events describe state changes.

Conceptual event types include:

```text
ORDER_CREATED
ORDER_ACCEPTED
ORDER_UPDATED
ORDER_CANCELED
ITEM_ADDED
ITEM_VOIDED
DISCOUNT_APPLIED
PAYMENT_PENDING
PAYMENT_DONE
PAYMENT_FAILED
KITCHEN_RELEASE_REQUESTED
KITCHEN_RELEASED
KITCHEN_HELD
ORDER_READY
ORDER_COMPLETED
RECONCILIATION_REQUIRED
```

Each canonical order event should link to:

```text
internal_order_id
raw_event_id
provider_id
adapter_version
source_confidence
audit_event_reference
```

---

## 12. Order Item Family

Order item objects represent normalized items, modifiers, options, bundles, and discounts.

Conceptual objects include:

```text
canonical_order_item
canonical_order_modifier
canonical_order_bundle
canonical_order_discount
canonical_order_tax
canonical_order_service_charge
```

Required item fields include:

```text
internal_order_item_id
internal_order_id
external_item_id
external_item_name
internal_menu_item_id
internal_recipe_id
display_name
quantity
unit_price
line_subtotal
line_discount
line_total
tax_category
kitchen_station
item_status
mapping_status
source_confidence
raw_item_reference
```

Unknown or unmapped items must remain visible.

They must not be silently dropped.

---

## 13. Mapping Family

Mapping objects connect external provider data to internal operational definitions.

Conceptual objects include:

```text
item_mapping
modifier_mapping
bundle_mapping
discount_mapping
tax_mapping
table_mapping
payment_status_mapping
order_status_mapping
```

Mapping objects should track:

```text
provider_id
store_id
external_value
internal_value
mapping_status
mapping_version
created_at
updated_at
review_required
```

Mapping gaps must create diagnostic errors or review states.

---

## 14. Payment Family

Payment family objects represent internal payment requests, provider payment events, and payment verification results.

Conceptual objects include:

```text
payment_provider
payment_request
payment_event
payment_verification_result
payment_status_projection
payment_error
payment_reconciliation_case
```

Payment request fields should include:

```text
payment_request_id
internal_order_id
tenant_id
store_id
provider_id
locked_amount
currency
payment_request_status
provider_payment_reference
created_at
expires_at
```

Payment event fields should include:

```text
payment_event_id
payment_request_id
provider_id
provider_event_id
provider_payment_reference
payment_status
amount
currency
received_at
verified_at
verification_status
idempotency_status
raw_payload_reference
```

---

## 15. Payment Authority Rule

Payment family owns payment verification state.

KDS, customer display, adapter, and support objects must not directly mark payment truth.

Payment authority transitions must be represented as events such as:

```text
PAYMENT_PROVIDER_EVENT_RECEIVED
PAYMENT_PROVIDER_EVENT_VERIFIED
PAYMENT_DONE
PAYMENT_FAILED
PAYMENT_EXPIRED
PAYMENT_AMOUNT_MISMATCH
PAYMENT_DUPLICATE_EVENT_IGNORED
MANUAL_PAYMENT_CONFIRMATION_USED
RECONCILIATION_REQUIRED
```

Payment visibility is not payment authority.

---

## 16. KDS Release Family

KDS release family objects represent kitchen eligibility and kitchen release events.

Conceptual objects include:

```text
kds_release_request
kds_release_event
kds_ticket_projection
kds_hold_record
manual_kitchen_recovery_reference
```

KDS release object fields should include:

```text
kds_release_id
internal_order_id
payment_request_id
store_id
kds_release_status
release_eligibility_reason
blocked_reason
created_at
released_at
source_runtime
audit_event_reference
```

KDS release must not happen directly from external provider event without internal authority verification.

---

## 17. Customer Display Family

Customer display objects represent customer-facing state.

Conceptual objects include:

```text
customer_display_session
customer_payment_display_state
customer_order_status_projection
customer_display_event
```

Customer display states may include:

```text
ORDER_CONFIRMING
ORDER_CONFIRMED
PAYMENT_REQUIRED
QR_READY
PAYMENT_PROCESSING
PAYMENT_CHECKING
PAYMENT_COMPLETE
KITCHEN_RECEIVED
PAYMENT_FAILED
PAYMENT_EXPIRED
STAFF_ASSISTANCE_REQUIRED
```

Customer display must consume verified internal projection.

It must not own order, payment, or KDS authority.

---

## 18. Diagnostic Error Family

Diagnostic error objects represent structured failures.

Conceptual objects include:

```text
diagnostic_error
diagnostic_error_event
diagnostic_error_aggregation
diagnostic_error_lifecycle
```

Required fields include:

```text
error_code
severity
audience
tenant_id
store_id
provider_id
adapter_id
adapter_version
external_order_id
external_event_id
internal_order_id
authority_impact
customer_impact
kitchen_impact
payment_impact
detected_at
recommended_action
lifecycle_state
audit_event_reference
```

Diagnostic errors must be stable, searchable, and auditable.

---

## 19. Replay Family

Replay family objects represent controlled reconstruction.

Conceptual objects include:

```text
replay_request
replay_scope
replay_result
replay_projection_diff
```

Replay request fields should include:

```text
replay_request_id
scope_type
scope_reference
provider_id
adapter_version
requested_by
requested_at
reason
status
```

Replay result states may include:

```text
REPLAY_COMPLETED
REPLAY_COMPLETED_WITH_WARNING
REPLAY_PRODUCED_CONFLICT
REPLAY_BLOCKED
REPLAY_REQUIRES_RECONCILIATION
REPLAY_PROJECTION_UPDATED
REPLAY_NO_CHANGE
```

Replay must not mutate source events.

---

## 20. Reconciliation Family

Reconciliation family objects represent accepted operational conclusions after uncertainty.

Conceptual objects include:

```text
reconciliation_case
reconciliation_evidence
reconciliation_conclusion
reconciliation_exception
```

Reconciliation case fields should include:

```text
reconciliation_case_id
case_type
internal_order_id
payment_request_id
kds_release_id
provider_id
store_id
trigger_error_code
uncertainty_reason
evidence_references
status
created_at
resolved_at
conclusion
```

Reconciliation may accept a conclusion.

It must not rewrite raw source events.

---

## 21. Support Family

Support family objects represent escalation and communication.

Conceptual objects include:

```text
support_ticket
support_ticket_event
vendor_escalation
developer_escalation
store_escalation
support_evidence
```

Support ticket fields should include:

```text
ticket_id
incident_id
store_id
tenant_id
provider_id
adapter_version
error_codes
affected_order_ids
severity
owner
status
evidence_references
reconciliation_required
created_at
closed_at
closure_type
```

Support closure is not the same as reconciliation closure.

---

## 22. Incident Family

Incident family objects represent aggregated operational issues.

Conceptual objects include:

```text
integration_incident
incident_event
incident_runbook_step
incident_affected_order
incident_postmortem
```

Incident fields should include:

```text
incident_id
incident_type
provider_id
adapter_id
store_id
tenant_id
severity
health_state
affected_order_count
affected_store_count
trigger_error_codes
state
created_at
resolved_at
postmortem_required
```

Incidents may aggregate many errors.

They must preserve individual affected order links.

---

## 23. Audit Family

Audit family objects preserve append-only operational memory.

Conceptual object:

```text
audit_event
```

Audit event fields should include:

```text
audit_event_id
tenant_id
store_id
actor_type
actor_id
runtime_family
event_type
target_type
target_id
before_state_reference
after_state_reference
source_reference
created_at
```

Every authority-sensitive state change must create audit.

Audit must be append-only.

---

## 24. Event Family Overview

The runtime should support event families such as:

```text
PROVIDER_EVENT
ADAPTER_EVENT
NORMALIZATION_EVENT
ORDER_EVENT
PAYMENT_EVENT
KDS_EVENT
CUSTOMER_DISPLAY_EVENT
DIAGNOSTIC_EVENT
FALLBACK_EVENT
REPLAY_EVENT
RECONCILIATION_EVENT
SUPPORT_EVENT
AUDIT_EVENT
```

Each event family should be separate enough to preserve runtime responsibility.

---

## 25. Provider Event Family

Provider event types may include:

```text
PROVIDER_WEBHOOK_RECEIVED
PROVIDER_WEBHOOK_VERIFIED
PROVIDER_WEBHOOK_REJECTED
PROVIDER_POLLING_RESULT_RECEIVED
PROVIDER_EVENT_DUPLICATE_IGNORED
PROVIDER_EVENT_DELAYED
PROVIDER_UNAVAILABLE
PROVIDER_CREDENTIAL_FAILED
```

Provider event does not automatically become internal order or payment truth.

---

## 26. Adapter Event Family

Adapter event types may include:

```text
ADAPTER_ENABLED
ADAPTER_DISABLED
ADAPTER_CAPABILITY_ASSIGNED
ADAPTER_CAPABILITY_DOWNGRADED
ADAPTER_MAPPING_VERSION_CHANGED
ADAPTER_CERTIFICATION_PASSED
ADAPTER_CERTIFICATION_FAILED
ADAPTER_RUNTIME_ERROR
```

Adapter events describe integration layer behavior.

They do not directly approve payment or kitchen execution.

---

## 27. Normalization Event Family

Normalization event types may include:

```text
NORMALIZATION_STARTED
NORMALIZATION_COMPLETED
NORMALIZATION_COMPLETED_WITH_WARNING
NORMALIZATION_FAILED
MAPPING_REQUIRED
SOURCE_CONFIDENCE_ASSIGNED
CANONICAL_ORDER_CREATED
CANONICAL_ORDER_UPDATED
```

Normalization creates internal representation.

It does not erase raw provider event.

---

## 28. Payment Event Family

Payment event types may include:

```text
PAYMENT_REQUEST_CREATED
PAYMENT_QR_DISPLAYED
PAYMENT_ATTEMPT_STARTED
PAYMENT_PROVIDER_EVENT_RECEIVED
PAYMENT_PROVIDER_EVENT_VERIFIED
PAYMENT_DONE
PAYMENT_FAILED
PAYMENT_EXPIRED
PAYMENT_AMOUNT_MISMATCH
PAYMENT_DUPLICATE_SUSPECTED
MANUAL_PAYMENT_CONFIRMATION_REQUIRED
MANUAL_PAYMENT_CONFIRMATION_USED
```

Payment events must link to payment request and internal order.

---

## 29. KDS Event Family

KDS event types may include:

```text
KDS_RELEASE_ELIGIBILITY_CREATED
KDS_RELEASE_BLOCKED
KDS_RELEASE_REQUESTED
KDS_RELEASED
KDS_HELD
KDS_CANCEL_REQUESTED
KDS_CANCEL_CONFIRMED
KDS_PROJECTION_REPLAYED
MANUAL_KITCHEN_RECOVERY_REQUIRED
```

KDS event must not decide payment truth.

---

## 30. Customer Display Event Family

Customer display event types may include:

```text
CUSTOMER_PAYMENT_SCREEN_SHOWN
CUSTOMER_QR_DISPLAYED
CUSTOMER_PAYMENT_CHECKING_SHOWN
CUSTOMER_PAYMENT_COMPLETE_SHOWN
CUSTOMER_PAYMENT_FAILED_SHOWN
CUSTOMER_KITCHEN_RECEIVED_SHOWN
CUSTOMER_STAFF_HELP_REQUESTED
```

Customer display events show what was presented to the customer.

They do not prove payment truth.

---

## 31. Diagnostic Event Family

Diagnostic event types may include:

```text
DIAGNOSTIC_ERROR_DETECTED
DIAGNOSTIC_ERROR_AGGREGATED
DIAGNOSTIC_ERROR_DEDUPED
DIAGNOSTIC_ACTION_RECOMMENDED
DIAGNOSTIC_ESCALATION_REQUIRED
DIAGNOSTIC_LIFECYCLE_UPDATED
```

Diagnostic events should reuse 04330 error code policy.

---

## 32. Fallback Event Family

Fallback event types may include:

```text
FALLBACK_MODE_ACTIVATED
MANUAL_ORDER_ENTRY_USED
MANUAL_PAYMENT_CONFIRMATION_USED
MANUAL_KITCHEN_RECOVERY_USED
FALLBACK_EVIDENCE_ATTACHED
FALLBACK_RECONCILIATION_REQUIRED
FALLBACK_MODE_ENDED
```

Fallback-originated state must remain visible.

---

## 33. Replay Event Family

Replay event types may include:

```text
REPLAY_REQUESTED
REPLAY_STARTED
REPLAY_BLOCKED
REPLAY_COMPLETED
REPLAY_COMPLETED_WITH_WARNING
REPLAY_PRODUCED_CONFLICT
REPLAY_REQUIRES_RECONCILIATION
```

Replay events must preserve replay scope and result.

---

## 34. Reconciliation Event Family

Reconciliation event types may include:

```text
RECONCILIATION_CASE_CREATED
RECONCILIATION_EVIDENCE_ATTACHED
RECONCILIATION_STARTED
RECONCILIATION_CONCLUSION_RECORDED
RECONCILIATION_CLOSED
RECONCILIATION_CLOSED_WITH_EXCEPTION
HQ_REVIEW_REQUIRED
```

Reconciliation conclusion must be append-only.

---

## 35. Support Event Family

Support event types may include:

```text
SUPPORT_TICKET_CREATED
SUPPORT_TICKET_CLASSIFIED
SUPPORT_OWNER_ASSIGNED
STORE_ESCALATION_RECEIVED
HQ_TRIAGE_COMPLETED
DEVELOPER_ESCALATION_SENT
VENDOR_ESCALATION_SENT
VENDOR_RESPONSE_RECEIVED
SUPPORT_TICKET_CLOSED
SUPPORT_TICKET_CLOSED_WITH_EXCEPTION
```

Support events must not mutate operational truth.

---

## 36. State Separation Rule

The system must preserve separation among:

```text
order_status
payment_status
fulfillment_status
kitchen_release_status
display_status
adapter_status
provider_health_status
diagnostic_lifecycle_status
incident_status
reconciliation_status
support_ticket_status
```

These states must not be collapsed into one generic order state.

A support ticket being closed does not mean reconciliation is closed.

A customer display showing payment complete does not prove payment authority unless Payment Runtime already verified it.

---

## 37. Source Reference Rule

Each derived object should reference its source.

Examples:

```text
canonical_order -> raw_provider_event
payment_event -> provider_webhook_event
kds_release_event -> payment_verification_result
customer_display_event -> customer_display_projection
diagnostic_error -> affected event or object
reconciliation_case -> evidence references
support_ticket -> incident and error references
audit_event -> target object
```

No important runtime object should be orphaned from its source.

---

## 38. Idempotency Rule

Idempotency must be represented at the event processing level.

Idempotency keys may include:

```text
provider_id
external_event_id
external_order_id
provider_payment_reference
event_type
payload_hash
adapter_version
```

Duplicate events must be marked, not reprocessed into duplicate orders, payments, or KDS releases.

---

## 39. Authority-Sensitive Event Rule

Authority-sensitive events require audit and verification.

Authority-sensitive events include:

```text
PAYMENT_DONE
PAYMENT_AMOUNT_MISMATCH
KDS_RELEASED
MANUAL_PAYMENT_CONFIRMATION_USED
MANUAL_KITCHEN_RECOVERY_USED
REFUND_REVIEW_REQUIRED
SETTLEMENT_REVIEW_REQUIRED
RECONCILIATION_CONCLUSION_RECORDED
CAPABILITY_DOWNGRADED
```

These events must not occur silently.

---

## 40. MVP Cutline

For MVP, the system should prepare conceptual support for:

```text
provider
store_provider_integration
adapter
adapter_version
raw_provider_event
canonical_order
canonical_order_event
canonical_order_item
payment_request
payment_event
payment_verification_result
kds_release_request
customer_display_state
diagnostic_error
reconciliation_case
support_ticket
audit_event
```

MVP event families should include:

```text
PROVIDER_EVENT
NORMALIZATION_EVENT
ORDER_EVENT
PAYMENT_EVENT
KDS_EVENT
CUSTOMER_DISPLAY_EVENT
DIAGNOSTIC_EVENT
FALLBACK_EVENT
AUDIT_EVENT
```

Excluded from MVP:

```text
full vendor portal objects
advanced certification object graph
multi-provider settlement objects
full refund execution objects
AI diagnostic objects
automatic adapter generation objects
enterprise SLA objects
```

---

## 41. Relationship To Previous Documents

This document supports:

```text
04260 POS Payment Webhook And Kitchen Release Boundary Policy
04270 Payment Failure Timeout Duplicate And Manual Confirmation Policy
04280 Customer Display Dynamic QR And Payment Status UX Policy
04290 Store Payment Device And Counter Bottleneck Reduction Policy
04300 POS Provider Abstraction And Multi-POS Adapter Policy
04310 Canonical Order Model And POS Event Normalization Policy
04320 POS Adapter Capability Level And Integration Contract Policy
04330 POS Adapter Error Code And Diagnostic Message Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04390 POS Integration Governance Index And Readiness Check
04400 Toss Payments MVP Integration Boundary Policy
04410 PAYCO Payment And Order Provider MVP Boundary Policy
```

The relationship is:

```text
04300~04390 = governance and integration boundary
04400~04410 = provider MVP boundary
04420 = shared runtime object and event family foundation
```

---

## 42. Patent And SaaS Relevance

This document supports the broader BM and SaaS architecture because it shows how multiple external providers can be absorbed into common runtime objects and event families.

The structural value is:

```text
external provider events
        ↓
raw event preservation
        ↓
canonical normalization
        ↓
runtime-specific projections
        ↓
diagnostic errors
        ↓
replay and reconciliation
        ↓
audit and support
```

This is the internal skeleton that allows the platform to scale beyond one POS, one PG, or one store environment.

---

## 43. Readiness Check

This policy is ready when:

```text
provider objects are separated from adapter objects
raw provider events are separated from canonical orders
payment objects are separated from KDS release objects
customer display objects are visibility-only
diagnostic errors are first-class objects
replay and reconciliation are separated
support tickets do not equal operational truth
audit events are append-only
event families are defined
authority-sensitive events are identified
MVP object cutline is explicit
```

---

## 44. Summary

A multi-POS platform cannot be built around one mutable order table.

It needs object families and event families.

The system must preserve:

```text
what the provider sent
what the adapter understood
what the internal order became
what payment verified
what KDS released
what the customer saw
what failed
what was replayed
what was reconciled
what support closed
what audit remembers
```

This separation is what allows the platform to be diagnosable, replayable, auditable, and scalable across many POS and payment environments.
