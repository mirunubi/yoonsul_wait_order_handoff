# 14022_Policy_POS_Schema_Validation_Raw_Packet_Audit_And_Spec_Drift_Defense

## 1. Purpose

This policy defines how the POS Gateway must validate external POS provider payloads, preserve raw packet evidence, detect schema drift, and prevent malformed or unexpected provider data from contaminating the core order, payment, settlement, menu, table, printer, and audit domains.

The purpose is to ensure that external POS systems are treated as untrusted integration sources until their requests, responses, webhooks, files, local agent messages, and status payloads pass controlled schema validation.

The POS Gateway must reject, quarantine, or degrade unsafe provider packets before they enter the core domain.

## 2. Scope

This policy applies to:

* Provider API responses
* Provider API error payloads
* Provider webhooks
* Provider status query responses
* Provider menu sync payloads
* Provider sold-out sync payloads
* Provider table sync payloads
* Provider business day payloads
* Provider payment and receipt payloads
* Provider refund and void payloads
* Local agent messages
* Printer status messages
* Raw request and response preservation
* Schema validation
* Field-level validation
* Enum validation
* Required field validation
* Unknown field handling
* Provider contract drift
* Payload quarantine
* Audit evidence for raw packet handling

This policy applies to all POS provider integration modes, including cloud API, local agent, webhook, scheduled sync, file-based sync, printer-assisted, and manual-assisted flows.

## 3. Core Principle

External POS packets must be treated as untrusted until validated.

The core system must not directly ingest provider-native payloads.

The POS Gateway must validate provider payloads at the boundary, preserve raw evidence safely, normalize only valid data, and block or quarantine unsafe data.

A provider packet that does not match the expected contract is not a harmless formatting issue. It is a potential integrity risk.

## 4. Schema Defense Boundary

The schema validation and raw packet audit layer sits at the Gateway entrance and exit boundary.

```
[External POS Provider / Local Agent / Printer]
                     |
                     v
    [Raw Packet Capture And Schema Validation]
                     |
                     v
    [Provider Adapter Normalization Layer]
                     |
                     v
    [Gateway Normalized Contract]
                     |
                     v
    [Core Order / Payment / Settlement / Audit Domain]
```

Only normalized, validated, and policy-approved data may move toward the core domain.

## 5. Non-Negotiable Rules

### 5.1 Reject Before Core Rule

Malformed, incomplete, unexpected, or schema-drifted provider payloads must be rejected, quarantined, or routed to controlled exception handling before reaching the core domain.

The core must never parse provider-native packets directly.

### 5.2 Raw Evidence Preservation Rule

The Gateway must preserve raw provider packet evidence for integration debugging, audit reconstruction, provider dispute handling, and incident investigation.

Raw evidence must be stored with security controls, redaction, tokenization, or encryption where required.

### 5.3 Schema Version Rule

Every provider adapter must validate packets against a known schema version or contract snapshot.

Provider schema changes must not be silently accepted.

### 5.4 Unknown Field Policy Rule

Unknown fields must be handled by policy.

The Gateway must define whether unknown fields are:

* Allowed and ignored
* Preserved for observation
* Warned
* Quarantined
* Rejected
* Treated as schema drift

The choice must depend on provider, endpoint, field sensitivity, and operation risk.

### 5.5 Required Field Rule

Missing required fields must block normalization unless a documented fallback exists.

The Gateway must not invent critical provider data through assumption.

### 5.6 Audit Integrity Rule

Raw packet storage must not become an uncontrolled data swamp.

Raw evidence must be tied to trace ID, provider ID, adapter version, schema version, operation type, and decision outcome.

## 6. Packet Types

The Gateway must classify packet types.

Allowed packet categories include:

```
PROVIDER_REQUEST_OUTBOUND
PROVIDER_RESPONSE_INBOUND
PROVIDER_ERROR_INBOUND
PROVIDER_WEBHOOK_INBOUND
PROVIDER_STATUS_RESPONSE
PROVIDER_MENU_SYNC_PAYLOAD
PROVIDER_SOLD_OUT_SYNC_PAYLOAD
PROVIDER_TABLE_SYNC_PAYLOAD
PROVIDER_BUSINESS_DAY_PAYLOAD
PROVIDER_PAYMENT_PAYLOAD
PROVIDER_REFUND_PAYLOAD
PROVIDER_RECEIPT_PAYLOAD
LOCAL_AGENT_HEARTBEAT
LOCAL_AGENT_JOB_RESULT
LOCAL_AGENT_PRINT_RESULT
PRINTER_STATUS_PAYLOAD
MANUAL_OPERATOR_PACKET
UNKNOWN_PACKET_TYPE
```

Each packet type must have validation and audit handling rules.

## 7. Schema Validation Levels

The Gateway must support multiple validation levels.

### 7.1 Transport Validation

Checks whether the packet arrived through an allowed channel.

Examples:

* HTTPS request
* Authenticated webhook
* Local agent channel
* Provider SDK response
* Scheduled sync job
* File import
* Printer status response

### 7.2 Authentication And Signature Validation

Checks whether the packet is authorized.

Examples:

* API token valid
* Webhook signature valid
* Local agent certificate valid
* Provider secret valid
* Store-device binding valid
* Replay window valid

### 7.3 Structural Validation

Checks whether the packet shape matches the expected schema.

Examples:

* Required object exists
* Required array exists
* Data types match
* Nested structure matches
* Field names match
* Field cardinality matches

### 7.4 Semantic Validation

Checks whether values make business sense.

Examples:

* Amount is not negative unless refund context
* Quantity is positive
* Order status transition is valid
* Provider table ID maps to known table
* Provider menu code maps to known item
* Business date is plausible
* Currency is expected
* Store ID matches binding

### 7.5 Contract Drift Validation

Checks whether the provider payload differs from the known contract.

Examples:

* Field renamed
* Required field removed
* Enum value added
* Nested object moved
* Response type changed
* Error format changed
* Amount field semantics changed

## 8. Validation Result Classification

The Gateway must normalize validation results.

Allowed results include:

```
VALID
VALID_WITH_UNKNOWN_FIELDS
VALID_WITH_WARNING
INVALID_AUTH
INVALID_SIGNATURE
INVALID_SCHEMA
MISSING_REQUIRED_FIELD
INVALID_FIELD_TYPE
INVALID_ENUM_VALUE
INVALID_SEMANTICS
STORE_BINDING_MISMATCH
PROVIDER_BINDING_MISMATCH
REPLAY_DETECTED
SCHEMA_DRIFT_DETECTED
CONTRACT_VERSION_MISMATCH
PAYLOAD_TOO_LARGE
QUARANTINED
REJECTED
UNKNOWN_VALIDATION_FAILURE
```

Each result must map to a controlled decision outcome.

## 9. Decision Outcomes

The Gateway may choose one of the following outcomes:

```
ACCEPT_AND_NORMALIZE
ACCEPT_WITH_WARNING
ACCEPT_AND_OBSERVE_UNKNOWN_FIELDS
REJECT_PACKET
QUARANTINE_PACKET
BLOCK_CORE_TRANSITION
REQUIRE_OPERATOR_REVIEW
REQUIRE_PROVIDER_REVIEW
OPEN_PROVIDER_CIRCUIT
DISABLE_ENDPOINT
MARK_ADAPTER_CONTRACT_STALE
ESCALATE_SECURITY_REVIEW
ESCALATE_INTEGRATION_INCIDENT
```

The decision must be based on operation risk and packet type.

## 10. Raw Packet Capture

Raw packet capture must occur before transformation when safe and technically possible.

Captured evidence should include:

```
raw_packet_id
provider_id
store_id
packet_type
operation_type
endpoint
direction
trace_id
idempotency_key
adapter_version
schema_version
received_at
sent_at
payload_hash
payload_storage_reference
redaction_status
validation_result
decision_outcome
```

The raw packet ID must be linked to normalized events and audit records.

## 11. Raw Packet Security

Raw packet evidence may contain sensitive information.

The system must apply appropriate controls:

* Redaction
* Tokenization
* Encryption
* Field-level masking
* Access restriction
* Retention policy
* Tamper-evident storage
* Audit trail for raw evidence access

Sensitive data may include:

* Payment references
* Customer phone number
* Customer name
* Address
* Access token
* API secret
* Signature
* Device identifier
* Internal IP
* Provider merchant ID
* Receipt details
* Operator identity

Raw packet evidence must not be exposed casually in operator tools.

## 12. Redaction Rules

Redaction must occur according to field sensitivity.

Examples:

```
access_token -> redact
api_secret -> redact
authorization_header -> redact
card_number -> never store raw
customer_phone -> mask or tokenize
customer_name -> minimize or mask
internal_ip -> restrict or hash
signature -> preserve only if needed and protected
payment_transaction_id -> tokenize or restrict
provider_receipt_id -> preserve with access control
```

The redaction rule version must be recorded.

## 13. Payload Hashing

The Gateway should store payload hashes for evidence integrity.

Payload hashes may support:

* Duplicate packet detection
* Webhook replay detection
* Audit reconstruction
* Tamper evidence
* Provider dispute handling
* Incident comparison

The hash must be computed before mutation or redaction when security policy allows.

If computed after redaction, that must be recorded.

## 14. Unknown Field Handling

Unknown fields may indicate harmless provider expansion or breaking contract drift.

The Gateway must classify unknown fields by risk.

### 14.1 Low-Risk Unknown Field

Example:

* New optional display label
* New metadata field
* New non-critical description

Possible outcome:

```
ACCEPT_AND_OBSERVE_UNKNOWN_FIELDS
```

### 14.2 Medium-Risk Unknown Field

Example:

* New discount-related field
* New table status field
* New fulfillment status field

Possible outcome:

```
ACCEPT_WITH_WARNING
REQUIRE_PROVIDER_REVIEW
```

### 14.3 High-Risk Unknown Field

Example:

* New payment amount field
* New tax field
* New refund field
* New order status field
* New authorization field

Possible outcome:

```
QUARANTINE_PACKET
BLOCK_CORE_TRANSITION
MARK_ADAPTER_CONTRACT_STALE
```

Unknown field policy must be endpoint-specific.

## 15. Missing Field Handling

Missing required fields must be treated conservatively.

Examples:

* Missing provider order ID
* Missing amount
* Missing order status
* Missing store ID
* Missing receipt ID
* Missing business date
* Missing refund status
* Missing menu code
* Missing table ID in table-required flow

Possible outcomes:

```
REJECT_PACKET
QUARANTINE_PACKET
BLOCK_CORE_TRANSITION
REQUIRE_PROVIDER_REVIEW
```

Fallback is allowed only if documented and safe.

## 16. Enum Drift Handling

Providers may add or change enum values.

Examples:

```
Old known values:
ACCEPTED
REJECTED
CANCELED

New unexpected value:
PARTIALLY_ACCEPTED
```

Unexpected enum values must not be mapped to a generic default unless policy explicitly allows it.

For critical states such as payment, refund, order status, and cancellation, unknown enum values should block state transition or require review.

## 17. Amount Field Drift Handling

Amount-related fields are high-risk.

Schema drift involving the following fields must be treated as payment integrity risk:

* Total amount
* Tax amount
* Discount amount
* Refund amount
* Void amount
* Paid amount
* Remaining amount
* Service charge
* Tip
* Coupon amount
* Point amount
* Currency
* Rounding field

Any changed meaning, missing field, renamed field, or new competing amount field must be reviewed before normalization.

## 18. Status Field Drift Handling

Status-related fields are high-risk.

Schema drift involving the following must be treated as state integrity risk:

* Order status
* Payment status
* Refund status
* Cancellation status
* Kitchen status
* Table status
* Business day status
* Provider health status
* Queue job status

Unknown status values must not silently drive core state transitions.

## 19. Store And Provider Binding Validation

Every inbound provider packet must be bound to the correct store and provider.

Validation must check:

* Provider ID
* Merchant ID
* Store ID
* Terminal ID, if applicable
* Local agent ID, if applicable
* Device ID, if applicable
* Tenant ID, where applicable
* Expected integration path

A packet for one store must never update another store.

Binding mismatch must be rejected or quarantined.

## 20. Webhook Replay And Ordering

Provider webhooks may be duplicated, delayed, replayed, or delivered out of order.

Webhook handling must validate:

* Event ID
* Event timestamp
* Signature
* Replay window
* Payload hash
* Previous processing status
* State transition eligibility
* Related order or payment state

A valid webhook packet must still pass idempotency and state transition rules before updating normalized state.

## 21. Local Agent Message Validation

Local agent messages must be validated as strictly as provider messages.

The Gateway must validate:

* Agent identity
* Store binding
* Device binding
* Agent version
* Message type
* Job ID
* Idempotency key
* Local timestamp
* Gateway receipt timestamp
* Payload schema
* State transition eligibility

Unknown local agent messages must not mutate core state.

## 22. Printer Status Message Validation

Printer status messages may be unreliable or incomplete.

The Gateway must validate:

* Printer profile ID
* Store binding
* Local agent binding
* Kitchen ticket ID
* Print job ID
* Status value
* Timestamp
* Retry count
* Failure reason

Printer status must not override order state directly.

It may update print state according to kitchen printer policy.

## 23. Contract Snapshot

Each provider adapter must maintain a contract snapshot.

The snapshot should include:

```
provider_id
contract_version
adapter_version
endpoint
method
request_schema_reference
response_schema_reference
webhook_schema_reference
error_schema_reference
enum_catalog_reference
amount_field_policy
status_field_policy
unknown_field_policy
last_verified_at
verified_by
source_reference
breaking_change_flag
```

A contract snapshot is required evidence for production readiness.

## 24. Schema Drift Detection

Schema drift may be detected by:

* Runtime validation failure
* Contract test failure
* Provider announcement
* Webhook payload mismatch
* Field frequency anomaly
* Unknown enum observation
* Missing required field observation
* Amount reconciliation mismatch
* Operator report
* Provider support communication

Schema drift must be classified and tracked as an integration incident when it affects production safety.

## 25. Schema Drift Severity

Schema drift severity must be classified.

Allowed severities include:

```
OBSERVATION
LOW_RISK_EXTENSION
MEDIUM_RISK_WARNING
HIGH_RISK_BLOCKING
PAYMENT_INTEGRITY_RISK
ORDER_STATE_INTEGRITY_RISK
SECURITY_RISK
PROVIDER_CONTRACT_BREAKING
```

Severity determines whether the Gateway can continue, warn, quarantine, or block.

## 26. Quarantine Handling

Quarantined packets must be isolated from core state transitions.

A quarantine record should include:

```
quarantine_id
raw_packet_id
provider_id
store_id
packet_type
validation_result
severity
quarantine_reason
related_order_id
related_payment_id
related_table_id
related_print_ticket_id
decision_owner
review_status
created_at
resolved_at
```

Quarantine review must be controlled and auditable.

## 27. Adapter Contract Stale Handling

If repeated schema drift occurs, the adapter contract may be marked stale.

Adapter stale outcomes may include:

```
CONTINUE_WITH_WARNING
DISABLE_SPECIFIC_ENDPOINT
OPEN_PROVIDER_CIRCUIT
BLOCK_PAYMENT_OPERATIONS
BLOCK_ORDER_SUBMISSION
REQUIRE_ADAPTER_UPDATE
REQUIRE_PROVIDER_RECERTIFICATION
```

The stale adapter state must be visible in readiness evidence.

## 28. Normalization Rules

Only validated packets may be normalized.

Normalization must:

* Map provider fields to Gateway contract fields
* Preserve original provider references
* Record schema version
* Record adapter version
* Preserve raw packet reference
* Preserve validation result
* Avoid inventing missing critical data
* Avoid lossy transformation for critical financial or state data

Normalization must be deterministic and testable.

## 29. Audit Requirements

Every schema validation and raw packet handling decision must preserve:

* Raw packet ID
* Provider ID
* Store ID
* Packet type
* Operation type
* Direction
* Endpoint
* Adapter version
* Schema version
* Validation level applied
* Validation result
* Decision outcome
* Unknown fields observed
* Missing fields observed
* Invalid enum values
* Semantic validation errors
* Binding validation result
* Payload hash
* Redaction status
* Quarantine ID, if applicable
* Related order ID, if applicable
* Related payment ID, if applicable
* Trace ID
* Idempotency key
* Timestamp

Sensitive values must be protected according to the security runtime policy.

## 30. Operator And Support Visibility

Operator and support tools must show schema-related issues without exposing unsafe raw data by default.

Visible information may include:

* Provider
* Store
* Endpoint
* Packet type
* Validation result
* Drift severity
* Affected order
* Affected payment
* Decision outcome
* Whether provider review is required
* Whether adapter update is required
* Whether order flow is blocked

Raw payload access must be restricted and audited.

## 31. Customer-Facing Messaging

Customers must not see schema validation details.

Possible customer-facing messages:

```
The store could not confirm this order.
This payment could not be completed safely.
The store is temporarily unable to accept online orders.
The order is under review by the store.
Please try again shortly.
```

Customer-facing messages must not expose provider schema errors, raw payloads, field names, endpoint names, or internal contract versions.

## 32. Test Requirements

Each provider adapter must test:

* Valid response
* Valid webhook
* Invalid signature
* Missing required field
* Invalid field type
* Unknown low-risk field
* Unknown high-risk field
* Unknown enum value
* Amount field missing
* Status field drift
* Store binding mismatch
* Provider binding mismatch
* Duplicate webhook
* Replay webhook
* Payload too large
* Local agent invalid message
* Printer invalid status
* Quarantine path
* Adapter stale path
* Raw packet redaction
* Audit preservation for validation decisions

A provider cannot be production-ready without schema validation and raw packet audit test evidence.

## 33. Anti-Patterns

The following are prohibited:

* Passing provider-native payloads directly into core logic
* Treating unknown provider fields as harmless by default
* Mapping unknown enum values to generic success
* Inventing missing amount, status, receipt, or store fields
* Ignoring provider schema drift because the order “seems to work”
* Storing raw packets without redaction or access control
* Exposing raw payloads to ordinary operators
* Allowing one store’s packet to update another store
* Treating local agent messages as trusted without validation
* Treating printer status as order status
* Updating core state from quarantined packets
* Running production adapter without contract snapshot

## 34. Relationship With Other Documents

This policy depends on and supports:

```
04900 Security Runtime Test Catalog
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05320 POS Menu Hierarchy Option Transformer Policy
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
```

Schema validation is the final gate that prevents external POS disorder from becoming core data corruption.

## 35. Final Rule

The POS Gateway must be able to prove which external packet was received, which schema it was validated against, what was accepted, what was rejected, what was quarantined, and which normalized state transition was allowed.

If malformed, drifted, or untrusted provider data can enter the core domain without validation, raw evidence, and audit-linked decisioning, the schema defense boundary has failed.
