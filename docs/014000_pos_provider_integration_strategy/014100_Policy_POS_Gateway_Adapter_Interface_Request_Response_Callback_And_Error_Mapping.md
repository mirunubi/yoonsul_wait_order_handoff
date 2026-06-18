# 014100_Policy_POS_Gateway_Adapter_Interface_Request_Response_Callback_And_Error_Mapping

## 1. Purpose

This document defines the POS Gateway adapter interface, request mapping, response mapping, callback handling, error mapping, provider lookup, and provider-specific translation policy.

The POS Gateway must not allow provider-specific APIs to directly control internal financial truth.

Provider adapters must translate external provider behavior into the internal POS Gateway state machine, event ledger, idempotency model, correlation model, evidence model, and reconciliation model.

The purpose of this policy is to ensure that each POS, payment, VAN/PG, kiosk, mini-kiosk, receipt, settlement, bridge, and manual fallback provider can be integrated through a controlled adapter boundary without contaminating the core gateway model.

## 2. Scope

This policy applies to all provider adapter routes involving:

* payment authorization request
* payment authorization response
* payment cancellation request
* payment cancellation response
* refund request
* refund response
* partial refund request
* POS order submission request
* POS order submission response
* POS cancellation request
* POS cancellation response
* provider lookup request
* provider lookup response
* provider callback
* duplicate callback
* delayed callback
* invalid callback
* settlement file intake
* receipt evidence intake
* provider error code mapping
* provider timeout mapping
* provider state mapping
* provider credential reference
* route-specific request schema
* route-specific response schema

This policy applies before first provider adapter implementation, sandbox testing, callback receiver activation, refund/cancellation automation, or production route release.

## 3. Relationship_To_Previous_Documents

This document follows:

* `014096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry.md`
* `014098_Policy_POS_Gateway_State_Machine_Payment_POS_Cancellation_Refund_And_Customer_Status.md`

It implements the adapter boundary required by:

* `014075_Policy_POS_Gateway_Provider_Onboarding_Certification_Sandbox_And_Official_Verification.md`
* `014081_Policy_POS_Gateway_Controlled_Production_Release_Rollback_And_Provider_Route_Change_Governance.md`
* `014094_Policy_POS_Gateway_Implementation_Backlog_Provider_Route_Build_Order_And_Phase_Cutline.md`

The rule is:

> Provider adapters translate provider facts.
> They do not invent internal truth.

## 4. Core_Principle

A POS Gateway adapter must be a controlled translation layer.

It may:

* build provider-specific requests
* parse provider-specific responses
* validate provider callbacks
* map provider references
* classify provider errors
* normalize provider state
* trigger internal events
* attach evidence references
* request provider lookup
* signal ambiguity
* mark provider limitations

It must not:

* directly mutate financial truth
* bypass the event ledger
* bypass idempotency
* bypass state machine rules
* treat unknown provider state as success
* treat timeout as failure without evidence
* mark refund complete without evidence
* mark cancellation complete without evidence
* override customer-facing status directly
* override staff-facing status directly
* skip reconciliation when provider evidence is incomplete
* store secrets in code or client payloads

## 5. Adapter_Interface_Families

The POS Gateway must define controlled adapter interfaces for the following families:

* `Payment_Authorization_Adapter`
* `Payment_Cancellation_Adapter`
* `Refund_Adapter`
* `POS_Order_Submission_Adapter`
* `POS_Cancellation_Adapter`
* `Provider_Lookup_Adapter`
* `Provider_Callback_Adapter`
* `Settlement_File_Adapter`
* `Receipt_Evidence_Adapter`
* `Manual_Fallback_Adapter`
* `Kiosk_Route_Adapter`
* `Mini_Kiosk_Route_Adapter`

Each adapter family must define:

* input contract
* output contract
* required idempotency behavior
* required correlation behavior
* allowed internal event outputs
* allowed state transition outputs
* error mapping
* evidence mapping
* unsupported behavior handling
* test requirements

## 6. Common_Adapter_Input_Contract

Every adapter request must receive a normalized internal input object.

Required fields include:

* provider_id
* provider_route_id
* route_class
* environment
* tenant_id
* store_id
* channel_id
* operation_type
* internal_entity_type
* internal_entity_id
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* amount
* currency
* idempotency_key
* correlation_id
* causation_id
* trace_id
* customer_reference
* staff_actor_reference
* request_context
* route_config_version
* state_mapping_version
* error_mapping_version

Adapter input must not include raw secrets.

## 7. Common_Adapter_Output_Contract

Every adapter must return a normalized output object.

Required fields include:

* adapter_result_id
* provider_id
* provider_route_id
* operation_type
* result_class
* provider_reference
* provider_status_raw
* provider_status_normalized
* internal_state_recommendation
* confidence_level
* retry_recommendation
* lookup_recommendation
* reconciliation_requirement
* dispute_requirement
* customer_status_recommendation
* staff_status_recommendation
* evidence_reference
* payload_hash
* error_class
* error_code_raw
* error_message_safe
* occurred_at
* received_at

The adapter output must be processed by the internal state machine before any current state projection changes.

## 8. Adapter_Result_Classes

Every adapter must classify result into one of the following result classes:

* `PROVIDER_SUCCESS_CONFIRMED`
* `PROVIDER_FAILURE_CONFIRMED`
* `PROVIDER_PENDING`
* `PROVIDER_TIMEOUT`
* `PROVIDER_UNKNOWN`
* `PROVIDER_REJECTED`
* `PROVIDER_DUPLICATE`
* `PROVIDER_IDEMPOTENCY_CONFLICT`
* `PROVIDER_VALIDATION_ERROR`
* `PROVIDER_AUTHENTICATION_ERROR`
* `PROVIDER_AUTHORIZATION_ERROR`
* `PROVIDER_RATE_LIMITED`
* `PROVIDER_UNAVAILABLE`
* `PROVIDER_UNSUPPORTED_OPERATION`
* `PROVIDER_MALFORMED_RESPONSE`
* `PROVIDER_CALLBACK_ACCEPTED`
* `PROVIDER_CALLBACK_REJECTED`
* `PROVIDER_LOOKUP_REQUIRED`
* `PROVIDER_MANUAL_REVIEW_REQUIRED`

Unknown or unparseable provider results must not be mapped to success.

## 9. Request_Mapping_Policy

### 9.1 Request_Build_Rule

Adapter request mapping must:

* use internal identifiers
* include idempotency key where supported
* include correlation field where provider supports it
* preserve provider route version
* preserve amount and currency
* preserve operation type
* preserve request payload hash
* validate required fields before provider call
* avoid exposing internal secrets
* avoid including unnecessary personal data
* record request evidence before or during provider call according to operation risk

### 9.2 Request_Validation

Before provider call, the adapter must validate:

* route is enabled for requested scope
* route operation is allowed
* route environment matches credential environment
* idempotency key exists
* amount is valid
* currency is valid
* order/payment/action reference exists
* operation is allowed by state machine
* route is not killed, blocked, or throttled
* required provider capability is verified
* no blocking risk prevents the operation

### 9.3 Request_Blocking_Conditions

Adapter request must be blocked when:

* provider route is disabled
* provider route is out of scope
* provider route approval is missing
* operation is not supported
* idempotency key is missing
* duplicate risk is active
* state transition is blocked
* credential reference is invalid
* route kill switch is active
* waiver expired
* blocking provider risk exists
* customer status would become misleading
* audit event write is unavailable for financial operation

## 10. Response_Mapping_Policy

### 10.1 Response_Parse_Rule

Adapter response mapping must:

* parse provider response without assuming success
* preserve raw response hash
* extract provider references
* extract provider status
* extract provider error code
* extract provider timestamp if available
* classify normalized result
* map to internal state recommendation
* mark confidence level
* mark lookup requirement if uncertain
* mark reconciliation requirement if necessary
* record evidence reference

### 10.2 Response_To_State_Rule

A provider response must not directly mutate projection.

The flow must be:

1. provider response received
2. adapter normalizes response
3. response event is written
4. state machine validates transition
5. projection is updated only if transition is allowed
6. customer/staff status projection is updated conservatively
7. reconciliation/dispute linkage is created where required

### 10.3 Confirmed_Success_Rule

A provider success response may be treated as confirmed only when:

* response is authenticated or came through trusted request channel
* provider reference is stable
* response maps to known provider state
* operation matches original request
* amount matches where relevant
* idempotency key or equivalent relationship is valid
* state machine allows transition
* no conflict exists with prior internal state

### 10.4 Ambiguous_Response_Rule

Response must be classified as ambiguous when:

* provider returns unknown state
* provider response is malformed
* provider reference is missing
* amount differs
* provider response conflicts with prior state
* response is delayed beyond allowed window
* operation type does not match request
* provider says pending but finality is required
* provider error code is unmapped

Ambiguous response must create review, lookup, or reconciliation requirement.

## 11. Callback_Handling_Policy

### 11.1 Callback_Validation

Provider callback must be validated before processing.

Validation must include where applicable:

* route lookup
* environment match
* signature verification
* authentication token validation
* source allowlist if used
* timestamp freshness check
* replay protection
* idempotency check
* payload schema validation
* operation type validation
* provider reference validation
* correlation field validation
* amount validation where relevant

Invalid callback must not update financial state.

### 11.2 Callback_Idempotency

Callback processing must be idempotent.

Duplicate callback must:

* not duplicate financial event outcome
* not duplicate customer notification
* not duplicate refund/cancellation
* not duplicate POS submission
* not silently overwrite final state
* create duplicate callback evidence where useful

### 11.3 Delayed_Callback

Delayed callback must be processed according to current state.

If delayed callback confirms an already unknown state, the system may resolve ambiguity only through state machine rules.

If delayed callback conflicts with current state, the system must create reconciliation or dispute review.

### 11.4 Callback_Output

Validated callback adapter output must include:

* callback_id
* provider_id
* provider_route_id
* callback_event_type
* provider_reference
* provider_status_raw
* provider_status_normalized
* related_internal_entity
* idempotency_result
* confidence_level
* state_recommendation
* reconciliation_requirement
* dispute_requirement
* evidence_reference

## 12. Error_Mapping_Policy

### 12.1 Required_Error_Classes

Provider errors must be mapped to internal error classes.

Required classes include:

* `AUTHENTICATION_ERROR`
* `AUTHORIZATION_ERROR`
* `VALIDATION_ERROR`
* `RATE_LIMIT`
* `TIMEOUT`
* `PROVIDER_INTERNAL_ERROR`
* `PROVIDER_UNAVAILABLE`
* `DUPLICATE_REQUEST`
* `IDEMPOTENCY_CONFLICT`
* `PAYMENT_DECLINED`
* `PAYMENT_UNKNOWN`
* `CANCEL_UNSUPPORTED`
* `CANCEL_FAILED`
* `CANCEL_UNKNOWN`
* `REFUND_UNSUPPORTED`
* `REFUND_FAILED`
* `REFUND_UNKNOWN`
* `POS_REJECTED`
* `POS_UNKNOWN`
* `SETTLEMENT_UNAVAILABLE`
* `CALLBACK_INVALID`
* `CALLBACK_DUPLICATE`
* `CALLBACK_DELAYED`
* `MALFORMED_RESPONSE`
* `UNKNOWN_PROVIDER_ERROR`

### 12.2 Error_To_Action_Rule

Each error class must define:

* retry eligibility
* lookup requirement
* customer status impact
* staff status impact
* reconciliation requirement
* dispute requirement
* provider escalation requirement
* route risk impact
* monitoring impact

### 12.3 Unknown_Error_Rule

Unknown provider error must not be treated as failure, success, cancellation, or refund completion.

Unknown error must create:

* internal event
* safe customer status
* staff review status
* provider limitation marker if repeated
* lookup or reconciliation requirement where applicable

## 13. Provider_Lookup_Policy

### 13.1 Lookup_Purpose

Provider lookup is used to resolve unknown or conflicting provider state.

Lookup may be triggered by:

* timeout
* missing callback
* malformed response
* delayed callback
* duplicate payment suspicion
* refund unknown
* cancellation unknown
* POS unknown
* reconciliation mismatch
* dispute case
* manual support review

### 13.2 Lookup_Input

Lookup input must include:

* provider_id
* provider_route_id
* operation_type
* provider_reference if available
* internal_entity_id
* idempotency_key
* correlation_id
* amount
* timestamp window
* lookup_reason

### 13.3 Lookup_Output

Lookup output must include:

* lookup_result_id
* provider_status_raw
* provider_status_normalized
* provider_reference
* confidence_level
* evidence_reference
* state_recommendation
* unresolved_gap
* next_action

### 13.4 Lookup_Limitation

If provider lookup is unsupported or inconclusive, the route must record a provider limitation and create reconciliation or manual review requirement.

## 14. Settlement_File_Adapter_Policy

Settlement file adapter must not directly mark payment truth.

It may:

* ingest provider settlement files
* validate file format
* map provider references
* compare amounts
* create reconciliation events
* create mismatch cases
* attach evidence

It must not:

* overwrite payment approval state
* silently close refund/cancellation ambiguity
* delete provider-only records
* ignore internal-only records
* hide amount mismatch

## 15. Receipt_Evidence_Adapter_Policy

Receipt evidence adapter may ingest:

* provider receipt reference
* POS receipt number
* receipt image
* receipt print capture
* customer receipt reference
* staff-attached receipt evidence

Receipt evidence is supporting evidence.

It must not alone become final financial truth unless an authorized policy explicitly allows it.

## 16. Manual_Fallback_Adapter_Policy

Manual fallback adapter represents staff or manager-entered recovery evidence.

It must:

* create manual override record
* create event ledger entry
* require reason code
* require actor attribution
* require approval where needed
* attach evidence where available
* trigger reconciliation requirement
* preserve original ambiguity

It must not:

* bypass provider evidence
* bypass state machine
* mark payment/refund/cancellation complete without authorization
* delete prior provider or POS state

## 17. Adapter_Versioning

Every adapter must be versioned.

Versioned items include:

* request mapping version
* response mapping version
* callback mapping version
* error mapping version
* state mapping version
* credential reference version
* endpoint version
* provider documentation version

Adapter version must be recorded on events.

A provider behavior change must trigger version review.

## 18. Adapter_Credential_Boundary

Adapter must use credential references, not raw credential values, in application logs or event records.

Credential controls must ensure:

* no secret in code
* no secret in markdown
* no secret in client bundle
* no secret in provider payload evidence
* environment separation
* credential rotation support
* credential revocation support
* access logging
* emergency disable support

Any adapter requiring client-exposed secret material must be blocked or redesigned.

## 19. Adapter_Observability

Every adapter must emit observability signals.

Required signals include:

* request count
* success count
* failure count
* timeout count
* unknown count
* rate-limit count
* retry count
* lookup count
* callback count
* duplicate callback count
* invalid callback count
* latency
* provider error class
* state mapping conflict
* evidence gap
* route blocked count
* kill switch block count

Metrics must be tagged by:

* provider_id
* provider_route_id
* tenant_id
* store_id
* channel_id
* operation_type
* environment

## 20. Adapter_Data_Model_Requirements

The implementation must support the following logical records.

### 20.1 Adapter_Request_Record

Required fields:

* adapter_request_id
* provider_id
* provider_route_id
* operation_type
* internal_entity_type
* internal_entity_id
* idempotency_key
* correlation_id
* request_mapping_version
* request_payload_hash
* request_status
* requested_at
* evidence_reference

### 20.2 Adapter_Response_Record

Required fields:

* adapter_response_id
* adapter_request_id
* provider_id
* provider_route_id
* operation_type
* provider_reference
* provider_status_raw
* provider_status_normalized
* response_mapping_version
* result_class
* confidence_level
* error_class
* response_payload_hash
* received_at
* evidence_reference

### 20.3 Adapter_Callback_Record

Required fields:

* adapter_callback_id
* provider_id
* provider_route_id
* callback_event_type
* provider_reference
* callback_mapping_version
* validation_status
* idempotency_status
* provider_status_raw
* provider_status_normalized
* result_class
* confidence_level
* payload_hash
* received_at
* evidence_reference

### 20.4 Adapter_Error_Map_Record

Required fields:

* adapter_error_map_id
* provider_id
* provider_route_id
* provider_error_code
* provider_error_message_pattern
* internal_error_class
* retry_eligibility
* lookup_requirement
* reconciliation_requirement
* customer_status_rule
* staff_status_rule
* mapping_version
* last_verified_at
* status

### 20.5 Adapter_State_Map_Record

Required fields:

* adapter_state_map_id
* provider_id
* provider_route_id
* provider_state_raw
* internal_state
* confidence_level
* allowed_transition
* customer_status_rule
* staff_status_rule
* reconciliation_requirement
* dispute_requirement
* mapping_version
* last_verified_at
* status

## 21. Access_Control

Adapter records must be access-controlled.

### 21.1 Developer

Developer may access adapter diagnostics in non-production.

Production access must be masked and controlled.

### 21.2 HQ_Compliance_And_Finance

HQ compliance and finance may access:

* normalized provider status
* evidence reference
* provider reference
* error class
* reconciliation linkage
* dispute linkage

Raw payload access must be controlled.

### 21.3 Store_And_Tenant

Store and tenant roles may access only operational summaries.

They must not access:

* raw provider payload
* credentials
* callback secrets
* internal error mapping details
* cross-tenant provider evidence

## 22. Test_Requirements

Adapter implementation must support tests for:

* request validation blocks disabled route
* request validation blocks out-of-scope route
* request validation blocks missing idempotency key
* response success maps only when evidence is valid
* response timeout maps to unknown or pending, not false failure
* malformed response maps to provider unknown
* unknown provider error maps to review
* callback signature failure blocks state update
* duplicate callback is idempotent
* delayed callback is processed against current state
* provider lookup resolves unknown where supported
* provider lookup unsupported creates limitation
* refund unsupported blocks refund automation
* cancellation unsupported blocks cancellation automation
* error mapping drives customer/staff safe status
* adapter event includes mapping version

## 23. Readiness_Checklist

Before first provider adapter can enter controlled implementation, the following checklist must pass.

### 23.1 Interface

* [ ] Common adapter input contract exists.
* [ ] Common adapter output contract exists.
* [ ] Adapter result classes are defined.
* [ ] Adapter families are defined.
* [ ] Adapter versioning is required.
* [ ] Adapter cannot directly mutate projection.

### 23.2 Request_Response

* [ ] Request mapping policy exists.
* [ ] Request validation exists.
* [ ] Request blocking conditions exist.
* [ ] Response mapping policy exists.
* [ ] Confirmed success rule exists.
* [ ] Ambiguous response rule exists.
* [ ] Response creates event before projection update.

### 23.3 Callback

* [ ] Callback validation exists.
* [ ] Callback idempotency exists.
* [ ] Duplicate callback handling exists.
* [ ] Delayed callback handling exists.
* [ ] Invalid callback cannot update state.
* [ ] Callback output contract exists.

### 23.4 Error_And_Lookup

* [ ] Error classes are defined.
* [ ] Error-to-action rule exists.
* [ ] Unknown error rule exists.
* [ ] Provider lookup policy exists.
* [ ] Lookup limitation rule exists.
* [ ] Unsupported operation creates limitation.

### 23.5 Security_And_Observability

* [ ] Credential boundary exists.
* [ ] Raw secrets are prohibited.
* [ ] Adapter metrics are defined.
* [ ] Adapter records are access-controlled.
* [ ] Raw payload access is restricted.
* [ ] Tests cover timeout, callback, duplicate, and unknown states.

## 24. Non_Goals

This policy does not define:

* final provider-specific API code
* final provider-specific request schema
* final provider-specific callback signature algorithm
* final HTTP client implementation
* final retry library
* final queue implementation
* final vault implementation
* final database table names
* final UI behavior

Those must be handled by provider-specific integration, implementation, security, and UI documents.

This policy defines the generic adapter interface and mapping boundary required before provider-specific adapters are built.

## 25. Acceptance_Criteria

This policy is accepted when:

* adapter interface is defined
* request mapping boundary is defined
* response mapping boundary is defined
* callback validation boundary is defined
* error mapping boundary is defined
* provider lookup boundary is defined
* adapter cannot directly mutate financial projection
* adapter output must pass through state machine
* timeout does not become false failure
* unknown provider state does not become success
* callback invalidity blocks state update
* duplicate callback is idempotent
* settlement file adapter cannot overwrite payment truth
* receipt evidence cannot alone become financial truth
* manual fallback adapter preserves ambiguity
* adapter versions are recorded
* adapter credentials remain secret-governed
* adapter metrics are emitted
* first provider adapter cannot proceed without these controls

## 26. Final_Rule

A provider adapter is not the POS Gateway.

It is only a translator between provider behavior and internal gateway truth.

If an adapter can directly decide payment success, refund completion, cancellation completion, POS acceptance, or customer-facing certainty without event, idempotency, state machine, and evidence controls, the adapter boundary is broken.
