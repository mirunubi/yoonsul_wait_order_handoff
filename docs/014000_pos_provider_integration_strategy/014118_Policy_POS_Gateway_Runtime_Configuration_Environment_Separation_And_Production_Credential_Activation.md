# 014118_Policy_POS_Gateway_Runtime_Configuration_Environment_Separation_And_Production_Credential_Activation

## 1. Purpose

This document defines the POS Gateway runtime configuration, environment separation, production credential activation, provider route configuration versioning, configuration approval, configuration rollback, and runtime safety policy.

The POS Gateway must not allow sandbox credentials, staging routes, pilot settings, production provider endpoints, callback endpoints, tenant/store scopes, amount limits, feature flags, or route enablement controls to be mixed accidentally.

The purpose of this policy is to ensure that every runtime configuration affecting provider routes, payment, POS submission, refund, cancellation, callback, lookup, settlement, kiosk, mini-kiosk, local replay, and tenant/store rollout is environment-separated, versioned, approved, auditable, reversible, and tied to production credential activation controls.

## 2. Scope

This policy applies to runtime configuration for:

* provider profile
* provider route
* provider route scope
* provider endpoint
* provider credential reference
* callback endpoint
* callback security profile
* idempotency policy
* retry policy
* timeout policy
* error mapping version
* state mapping version
* release version
* adapter version
* kill switch state
* amount limit
* transaction volume limit
* tenant/store/channel scope
* device scope
* payment method scope
* operation type scope
* settlement intake scope
* receipt evidence scope
* kiosk route scope
* mini-kiosk route scope
* local replay scope
* observability and alert thresholds
* UI action binding configuration
* runbook configuration
* production credential activation

This policy applies before any production route, pilot route, provider expansion, tenant expansion, store expansion, kiosk reuse, or mini-kiosk reuse is enabled.

## 3. Relationship_To_Previous_Documents

This document follows:

* `014117_Policy_POS_Gateway_Credential_Secret_Callback_Security_And_Provider_Access_Control.md`

It also supports:

* `014114_Policy_POS_Gateway_Release_Gate_Kill_Switch_Rollback_Execution_And_Post_Release_Monitoring.md`
* `014116_Policy_POS_Gateway_Provider_Route_Certification_Sandbox_Test_Result_And_Production_Approval_Evidence.md`
* `014100_Policy_POS_Gateway_Adapter_Interface_Request_Response_Callback_And_Error_Mapping.md`
* `014112_Policy_POS_Gateway_Observability_Dashboard_Alert_Rule_SLO_Metric_And_Incident_Record_Implementation.md`

The rule is:

> Runtime configuration is production behavior.
> It must be governed like code when it can affect money, orders, customer status, provider access, or store operation.

## 4. Core_Principle

The POS Gateway must treat runtime configuration as controlled operational authority.

A configuration change may:

* enable a payment route
* disable a POS submission route
* activate production credentials
* route transactions to a provider
* alter callback verification
* change refund behavior
* change cancellation behavior
* change retry behavior
* change timeout behavior
* change customer-facing status
* change store staff actions
* change tenant rollout scope
* change settlement matching
* affect reconciliation
* affect dispute evidence
* expose or protect financial risk

Therefore, runtime configuration must be:

* environment-separated
* versioned
* scoped
* approved
* auditable
* tested
* reversible
* observable
* linked to release request
* blocked when unsafe

## 5. Environment_Model

The POS Gateway must define controlled environments.

Required environments include:

* `LOCAL_DEVELOPMENT`
* `TEST`
* `SANDBOX`
* `STAGING`
* `PILOT`
* `PRODUCTION`
* `DISASTER_RECOVERY`

Each environment must define:

* allowed credential classes
* allowed provider endpoints
* allowed callback endpoints
* allowed tenant/store scope
* allowed data class
* allowed transaction class
* allowed external side effects
* allowed release type
* allowed user role access
* observability requirement
* rollback requirement

## 6. Environment_Separation_Rules

The following rules must be enforced:

* production credentials must not be used outside production or approved pilot production scope
* sandbox credentials must not be used in production route
* staging endpoints must not receive production callbacks
* production callbacks must not be processed by sandbox route
* production transactions must not be replayed in non-production environment
* test fixtures must not contain live customer payment data
* provider production reference must not be reused as sandbox reference
* callback signing secret must be environment-specific
* settlement files from production must not be ingested into test without approved masking
* store devices must not switch environment without reauthorization
* tenant/store route scope must be environment-specific
* release approval must be environment-specific

## 7. Runtime_Configuration_Families

The POS Gateway must support the following runtime configuration families:

* `Provider_Route_Config`
* `Provider_Endpoint_Config`
* `Credential_Reference_Config`
* `Callback_Security_Config`
* `Route_Scope_Config`
* `Operation_Enablement_Config`
* `Payment_Method_Config`
* `Timeout_And_Retry_Config`
* `Idempotency_Config`
* `State_Mapping_Config`
* `Error_Mapping_Config`
* `Observability_Config`
* `Alert_Threshold_Config`
* `Kill_Switch_Config`
* `Rollback_Config`
* `UI_Action_Binding_Config`
* `Runbook_Config`
* `Settlement_Intake_Config`
* `Kiosk_Route_Config`
* `Mini_Kiosk_Route_Config`
* `Local_Replay_Config`

Each configuration family must be versioned and linked to release evidence.

## 8. Provider_Route_Config

### 8.1 Purpose

`Provider_Route_Config` defines whether and how a provider route operates.

### 8.2 Required_Fields

Required fields include:

* provider_route_config_id
* provider_route_id
* environment
* config_version
* adapter_version
* state_mapping_version
* error_mapping_version
* endpoint_config_id
* credential_reference_id
* callback_security_config_id
* route_scope_config_id
* timeout_retry_config_id
* idempotency_config_id
* observability_config_id
* release_request_id
* approval_status
* effective_from
* effective_until
* status

### 8.3 Required_Constraints

The implementation must ensure:

* production config cannot be active without release approval
* active config must reference valid credential reference
* active config must reference valid route scope
* active config must reference valid endpoint config
* active config must reference valid observability config
* expired config cannot process new operations
* disabled config blocks new unsafe operations
* config version is recorded on events

## 9. Provider_Endpoint_Config

Endpoint configuration must define:

* endpoint_config_id
* provider_id
* provider_route_id
* environment
* base_url_reference
* operation_path_reference
* callback_url_reference
* timeout_policy_id
* TLS_requirement
* allowed_method
* API_version
* provider_documentation_reference
* effective_from
* status

Endpoint configuration must not contain raw secrets.

Production endpoint must not be active in non-production environment.

## 10. Credential_Reference_Config

Credential reference configuration must define:

* credential_reference_config_id
* provider_id
* provider_route_id
* environment
* credential_reference_id
* secret_class
* secret_purpose
* credential_version
* activation_status
* activation_approval_reference
* activated_at
* rotated_at
* expires_at
* revoked_at
* status

Production credential activation must require:

* credential security readiness
* provider certification
* release approval
* route scope approval
* callback security readiness where applicable
* rollback plan
* audit logging

## 11. Callback_Security_Config

Callback security configuration must define:

* callback_security_config_id
* provider_id
* provider_route_id
* environment
* callback_endpoint_reference
* signature_required
* signature_algorithm
* secret_reference_id
* timestamp_required
* replay_window_seconds
* source_control_type
* validation_version
* quarantine_policy
* invalid_callback_policy
* effective_from
* status

Callback security configuration must be tested before production callback activation.

## 12. Route_Scope_Config

Route scope configuration must define where the route is allowed.

Required scope fields include:

* route_scope_config_id
* provider_route_id
* environment
* tenant_id
* store_id
* operating_group_id
* legal_entity_id
* channel_id
* device_type
* payment_method
* operation_type
* order_type
* amount_limit
* transaction_volume_limit
* allowed_time_window
* release_request_id
* effective_from
* effective_until
* status

Missing route scope must mean not allowed.

## 13. Operation_Enablement_Config

Operation enablement must define whether each operation is allowed.

Required operation flags include:

* payment_authorization_enabled
* payment_cancellation_enabled
* refund_enabled
* partial_refund_enabled
* POS_submission_enabled
* POS_cancellation_enabled
* callback_processing_enabled
* provider_lookup_enabled
* settlement_intake_enabled
* receipt_evidence_enabled
* local_replay_enabled
* manual_fallback_enabled
* kiosk_route_enabled
* mini_kiosk_route_enabled

Each operation must be independently controllable.

Enabling payment must not automatically enable refund.

Enabling POS submission must not automatically enable POS cancellation.

## 14. Timeout_And_Retry_Config

Timeout and retry configuration must define:

* timeout_retry_config_id
* provider_route_id
* environment
* operation_type
* request_timeout_ms
* provider_response_timeout_ms
* callback_expected_within_seconds
* lookup_after_timeout_enabled
* max_retry_attempts
* retry_backoff_strategy
* unsafe_retry_blocked
* reconciliation_after_timeout_required
* idempotency_required
* status

Unsafe retry block must be enabled for financial operations unless provider-specific certification approves otherwise.

## 15. Idempotency_Config

Idempotency configuration must define:

* idempotency_config_id
* provider_route_id
* environment
* operation_type
* idempotency_required
* idempotency_key_strategy
* request_hash_required
* provider_idempotency_supported
* internal_idempotency_enforced
* conflict_policy
* expiration_policy
* status

Production financial operation must require idempotency.

## 16. State_Mapping_Config

State mapping configuration must define:

* state_mapping_config_id
* provider_id
* provider_route_id
* environment
* mapping_version
* provider_state_raw
* internal_state
* confidence_level
* allowed_transition
* customer_status_rule
* staff_status_rule
* reconciliation_requirement
* dispute_requirement
* effective_from
* status

Unknown provider state must map to review, unknown, or reconciliation state.

It must not map to success.

## 17. Error_Mapping_Config

Error mapping configuration must define:

* error_mapping_config_id
* provider_id
* provider_route_id
* environment
* mapping_version
* provider_error_code
* provider_error_pattern
* internal_error_class
* retry_eligibility
* lookup_requirement
* reconciliation_requirement
* customer_status_rule
* staff_status_rule
* provider_escalation_requirement
* effective_from
* status

Unmapped provider error must map to unknown provider error and safe review path.

## 18. Observability_And_Alert_Config

Observability configuration must define:

* observability_config_id
* provider_route_id
* environment
* metric_set
* SLO_profile_id
* alert_rule_set
* dashboard_scope
* owner_role
* incident_policy_id
* retention_period
* status

Production route must not activate without observability configuration.

## 19. UI_Action_Binding_Config

UI action binding configuration must define:

* UI_action_binding_config_id
* environment
* provider_route_id
* role
* status_code
* allowed_action_set
* blocked_action_set
* runbook_reference
* customer_message_template_id
* staff_guidance_template_id
* audit_event_type
* effective_from
* status

Production route must not expose UI action without binding.

## 20. Runbook_Config

Runbook configuration must define:

* runbook_config_id
* provider_route_id
* environment
* runbook_type
* runbook_reference
* version
* owner_role
* training_required
* acknowledgement_required
* effective_from
* status

Runbook version must be linked to store and support readiness.

## 21. Production_Credential_Activation

Production credential activation must be treated as a controlled event.

Activation requires:

* provider route certification approved
* production approval evidence exists
* release request approved
* credential security checklist passed
* callback security configured
* route scope configured
* operation enablement configured
* observability configured
* rollback configured
* access audit enabled
* secret rotation schedule defined
* incident response path defined

Activation must create:

* credential activation event
* configuration version event
* release evidence reference
* audit record
* route readiness record

## 22. Activation_Blocking_Conditions

Production credential activation must be blocked when:

* provider certification is missing
* certification expired
* release request is missing
* release approval is missing
* route scope is missing
* route config version is missing
* credential reference is invalid
* secret is expired
* secret is revoked
* callback security is missing where required
* observability is missing
* rollback plan is missing
* idempotency config is missing
* unknown state mapping is missing
* runbook is missing
* access audit is disabled
* unresolved blocking risk exists
* environment mismatch is detected

## 23. Configuration_Change_Control

Any runtime configuration change must create a change record.

Required fields include:

* config_change_id
* config_family
* target_config_id
* environment
* provider_route_id
* tenant_id
* store_id
* old_version
* new_version
* change_type
* change_reason
* requested_by
* approved_by
* applied_by
* applied_at
* release_request_id
* rollback_reference
* evidence_reference
* status

Configuration change must be reviewable and reversible where feasible.

## 24. Configuration_Change_Types

Required change types include:

* route enable
* route disable
* credential activation
* credential rotation
* endpoint change
* callback endpoint change
* callback security change
* route scope expansion
* route scope reduction
* amount limit change
* operation enablement change
* timeout change
* retry change
* state mapping change
* error mapping change
* observability threshold change
* UI action binding change
* runbook version change
* settlement intake change
* local replay enablement change
* kiosk route enablement change
* mini-kiosk route enablement change

High-risk configuration changes must require approval.

## 25. Configuration_Rollback

Configuration rollback must restore a prior approved version.

Rollback must:

* record rollback event
* identify prior config version
* identify affected scope
* preserve current evidence
* prevent deletion of events
* mark affected in-flight records for review
* update route state
* update UI banners where applicable
* trigger post-rollback monitoring
* require re-approval for re-enable if rollback was incident-related

Rollback must not rewrite historical config events.

## 26. Configuration_Drift_Detection

The system must detect drift between approved configuration and active runtime behavior.

Drift examples include:

* active route without approved config
* active credential different from approved reference
* production endpoint used in non-production environment
* route scope expanded without release approval
* callback endpoint mismatch
* state mapping version mismatch
* error mapping version mismatch
* observability disabled for active route
* UI action exposed without binding
* kill switch state inconsistent with route status
* store enabled before training readiness

Configuration drift must create alert and may block route.

## 27. Tenant_And_Store_Config_Inheritance

Configuration inheritance must be explicit.

Allowed inheritance may include:

* tenant default route config
* store override
* channel override
* payment method override
* device override
* operation-specific override

Inheritance must not imply production activation.

A child scope must not become active unless:

* parent config is active
* child scope is approved
* no blocking override exists
* environment matches
* release scope permits it

## 28. Emergency_Configuration_Change

Emergency configuration change may be allowed only when:

* incident exists
* authorized role initiates change
* reason code is recorded
* affected scope is explicit
* evidence is preserved
* post-action review is required
* rollback plan exists or emergency stop is used
* compliance/finance are notified where required

Emergency change must not become permanent without normal approval.

## 29. Runtime_Config_Data_Model_Requirements

The implementation must support the following logical records.

### 29.1 Runtime_Config_Record

Required fields:

* runtime_config_id
* config_family
* provider_route_id
* environment
* tenant_id
* store_id
* channel_id
* config_version
* config_payload_reference
* release_request_id
* approval_status
* effective_from
* effective_until
* status

### 29.2 Config_Change_Record

Required fields:

* config_change_id
* runtime_config_id
* config_family
* change_type
* old_version
* new_version
* change_reason
* requested_by
* approved_by
* applied_by
* applied_at
* release_request_id
* rollback_reference
* evidence_reference
* status

### 29.3 Production_Credential_Activation_Record

Required fields:

* production_credential_activation_id
* credential_reference_id
* provider_id
* provider_route_id
* environment
* activation_scope
* certification_id
* release_request_id
* activated_by
* activated_at
* activation_status
* security_check_reference
* rollback_reference
* audit_reference
* status

### 29.4 Environment_Separation_Check_Record

Required fields:

* environment_separation_check_id
* provider_route_id
* source_environment
* target_environment
* check_type
* result_status
* mismatch_detected
* mismatch_summary
* blocker_created
* checked_at
* status

### 29.5 Configuration_Drift_Record

Required fields:

* configuration_drift_id
* provider_route_id
* environment
* drift_type
* approved_config_reference
* active_runtime_reference
* severity
* detected_at
* detected_by
* route_action_taken
* incident_id
* resolved_at
* status

## 30. Access_Control

### 30.1 Store_Staff

Store staff must not edit runtime configuration.

Store staff may view operational route status only.

### 30.2 Store_Manager

Store manager may view store-scoped route readiness and outage status.

Store manager must not activate production credentials or expand route scope.

### 30.3 Tenant_Admin

Tenant admin may request configuration change where product design permits, but activation must follow approval workflow.

Tenant admin must not access raw credential references or secret values.

### 30.4 HQ_Operations

HQ operations may manage route enablement, route disablement, runbook binding, and emergency operational configuration within approved authority.

### 30.5 HQ_Security

HQ security must approve production credential activation, callback security configuration, and credential incident recovery.

### 30.6 HQ_Finance_And_Compliance

Finance and compliance must approve configurations affecting settlement, refund, cancellation, dispute evidence, legal hold, or customer-protection flow.

### 30.7 Developer_And_SRE

Developer and SRE may apply technical configuration only through approved change workflow or logged break-glass.

## 31. Observability_Requirements

The system must monitor:

* active production config count
* config change count
* high-risk config change count
* config rollback count
* environment mismatch count
* production credential activation count
* production credential activation failure count
* invalid credential reference count
* expired config active count
* unapproved route active count
* config drift count
* UI action without binding count
* observability missing active route count
* runbook missing active route count

Metrics must be tagged by:

* provider_id
* provider_route_id
* environment
* tenant_id
* store_id
* config_family
* change_type
* severity

## 32. Test_Requirements

The implementation must support tests for:

* production route cannot use sandbox credential
* sandbox route cannot use production credential
* production endpoint cannot be active in staging config
* callback endpoint environment mismatch blocks activation
* production credential activation blocked without certification
* production credential activation blocked without release request
* active route blocked when route scope missing
* operation enablement does not imply other operations
* unmapped provider state maps to review
* unmapped error maps to unknown provider error
* active route without observability is blocked
* UI action without binding is blocked
* config rollback restores prior version
* configuration drift creates alert
* tenant/store config inheritance does not activate unapproved scope
* emergency config change creates post-action review

## 33. Readiness_Checklist

Before production credential activation or runtime route activation, the following checklist must pass.

### 33.1 Environment

* [ ] Environment model is defined.
* [ ] Environment separation rules are defined.
* [ ] Production credential cannot be used outside approved scope.
* [ ] Production callback cannot be processed by wrong environment.
* [ ] Production transaction replay in non-production is blocked.
* [ ] Environment mismatch creates blocker.

### 33.2 Configuration

* [ ] Runtime configuration families are defined.
* [ ] Provider route config is defined.
* [ ] Endpoint config is defined.
* [ ] Credential reference config is defined.
* [ ] Callback security config is defined.
* [ ] Route scope config is defined.
* [ ] Operation enablement config is defined.
* [ ] Timeout/retry config is defined.
* [ ] Idempotency config is defined.
* [ ] State/error mapping config is defined.
* [ ] Observability config is defined.
* [ ] UI action binding config is defined.
* [ ] Runbook config is defined.

### 33.3 Activation_And_Change

* [ ] Production credential activation rule is defined.
* [ ] Activation blocking conditions are defined.
* [ ] Configuration change control is defined.
* [ ] High-risk change types are defined.
* [ ] Configuration rollback is defined.
* [ ] Configuration drift detection is defined.
* [ ] Emergency configuration change is defined.

### 33.4 Control

* [ ] Access control is defined.
* [ ] Observability metrics are defined.
* [ ] Tests are defined.
* [ ] Release request linkage is required.
* [ ] Audit record is required.
* [ ] Reversible configuration is required where feasible.

## 34. Non_Goals

This policy does not define:

* final configuration storage technology
* final feature flag vendor
* final secret manager integration
* final deployment pipeline
* final environment naming in infrastructure
* final provider endpoint values
* final UI for configuration management
* final CI/CD approval implementation

Those must be handled by infrastructure, DevOps, security, implementation, provider-specific, and UI documents.

This policy defines the runtime configuration, environment separation, and production credential activation boundary for POS Gateway provider routes.

## 35. Acceptance_Criteria

This policy is accepted when:

* environment model is defined
* environment separation rules are defined
* runtime configuration families are defined
* provider route config is versioned
* endpoint config is environment-specific
* credential reference config is environment-specific
* callback security config is environment-specific
* route scope config is explicit
* operation enablement is independently controlled
* timeout/retry/idempotency configs are defined
* state and error mapping configs are versioned
* observability and UI action binding configs are required
* production credential activation requires certification and release approval
* activation blocking conditions are defined
* configuration change control is defined
* configuration rollback is defined
* configuration drift detection is defined
* emergency configuration change is auditable
* access control, observability, and tests are defined

## 36. Final_Rule

A production credential must not become active simply because it exists.

A runtime configuration must not become production behavior simply because it was saved.

The POS Gateway may use production configuration only when the environment, credential, route scope, operation enablement, state mapping, observability, runbook, release approval, and rollback path all agree.
