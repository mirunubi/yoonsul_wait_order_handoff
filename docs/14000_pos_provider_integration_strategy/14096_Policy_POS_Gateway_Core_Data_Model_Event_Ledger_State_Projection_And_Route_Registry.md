# 14096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry

## 1. Purpose

This document defines the core POS Gateway data model policy for event ledger, state projection, provider route registry, provider profile, route scope, idempotency, correlation, and financial state reconstruction.

The POS Gateway must not depend on provider-specific transaction tables as the source of truth.

The system must maintain its own provider-independent event ledger and state projection model so that POS providers, payment providers, VAN/PG providers, kiosk routes, mini-kiosk routes, wait-order handoff routes, cancellation routes, refund routes, settlement routes, and manual fallback routes can be integrated without corrupting internal financial truth.

The purpose of this policy is to ensure that the first implementation layer of the POS Gateway is a controlled data spine, not a vendor-specific adapter.

## 2. Scope

This policy applies to core data models required for:

* provider route registry
* provider profile
* provider route scope
* route enablement
* route disablement
* route status
* financial event ledger
* payment attempt
* POS submission
* cancellation action
* refund action
* idempotency key
* correlation and causation identifiers
* state projection
* customer-facing status projection
* staff-facing status projection
* audit event reference
* manual override reference
* provider reference mapping
* local ledger linkage
* reconciliation linkage
* dispute case linkage
* release governance linkage
* route kill switch linkage

This policy applies before provider-specific implementation, first provider adapter, kiosk route implementation, mini-kiosk route implementation, production route release, or store pilot.

## 3. Relationship_To_Previous_Documents

This document follows:

* `14094_Policy_POS_Gateway_Implementation_Backlog_Provider_Route_Build_Order_And_Phase_Cutline.md`

It also implements data-model foundations required by:

* `05640_POS_Gateway_Compliance_Financial_Audit_Regulatory_And_Consumer_Protection_Readiness_Policy.md`
* `14071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md`
* `14073_Policy_POS_Gateway_Offline_Degraded_Mode_Local_Ledger_Replay_And_Reconciliation.md`
* `14075_Policy_POS_Gateway_Provider_Onboarding_Certification_Sandbox_And_Official_Verification.md`
* `14077_Policy_POS_Gateway_Observability_SLO_Incident_Command_And_Provider_Escalation.md`
* `14079_Policy_POS_Gateway_Provider_Risk_Register_Known_Limitations_Waiver_And_Deferral.md`
* `14081_Policy_POS_Gateway_Controlled_Production_Release_Rollback_And_Provider_Route_Change_Governance.md`
* `14083_Policy_POS_Gateway_Store_Tenant_Operations_Runbook_Handoff_And_Training_Readiness.md`
* `14092_Policy_POS_Gateway_Resilience_Lane_Index_Readiness_Check_And_Evidence_Handoff.md`

The rule is:

> Provider adapters may write events and references, but they must not become the core financial truth model.

## 4. Core_Principle

The POS Gateway must separate:

* event truth
* current projection
* provider reference
* route configuration
* operational display
* customer-facing status
* staff-facing status
* reconciliation result
* dispute resolution
* release governance

Mutable projections may be used for fast reads.

Provider payloads may be stored as evidence references.

Staff and customer statuses may be displayed as simplified views.

However, the authoritative system history must come from append-only events and controlled state transitions.

## 5. Core_Data_Model_Families

The POS Gateway core must support the following data model families:

* `Provider_Profile`
* `Provider_Route`
* `Provider_Route_Scope`
* `Provider_Route_Status`
* `Provider_Route_Config_Version`
* `Financial_Event_Ledger`
* `Payment_Attempt`
* `POS_Submission`
* `Cancellation_Action`
* `Refund_Action`
* `Idempotency_Record`
* `Correlation_Record`
* `State_Projection`
* `Customer_Status_Projection`
* `Staff_Status_Projection`
* `Provider_Reference_Map`
* `Manual_Override_Record`
* `Audit_Evidence_Reference`
* `Route_Kill_Switch_State`
* `Projection_Rebuild_Record`

These are logical model names.
The final implementation may use different physical table names, but must preserve the boundaries.

## 6. Provider_Profile_Model

### 6.1 Purpose

`Provider_Profile` defines the provider entity before any route is enabled.

A provider may represent:

* POS provider
* payment provider
* VAN provider
* PG provider
* kiosk payment provider
* mini-kiosk provider
* settlement file provider
* receipt provider
* bridge provider
* manual fallback provider profile

### 6.2 Required_Fields

Required fields include:

* provider_id
* provider_name
* provider_type
* provider_code
* official_status
* contract_status
* documentation_status
* sandbox_status
* production_credential_status
* support_scope
* support_contact_reference
* risk_grade
* owner_role
* owner_id
* last_verified_at
* next_verification_due_at
* created_at
* updated_at
* status

### 6.3 Required_Constraints

The implementation must ensure:

* provider_code is unique within active provider scope
* provider_type is controlled by enum or reference table
* official_status is not free text
* risk_grade affects route release eligibility
* provider cannot be deleted if active routes or evidence references exist
* provider deactivation must not delete historical event evidence

## 7. Provider_Route_Model

### 7.1 Purpose

`Provider_Route` defines a specific operational path through a provider.

A single provider may have multiple routes.

Examples:

* POS order submission route
* POS cancellation route
* payment authorization route
* payment cancellation route
* refund route
* callback route
* provider lookup route
* settlement file route
* receipt route
* kiosk route
* mini-kiosk route
* manual fallback route

### 7.2 Required_Fields

Required fields include:

* provider_route_id
* provider_id
* route_code
* route_class
* route_type
* environment
* operation_type
* adapter_key
* credential_reference
* endpoint_inventory_reference
* callback_inventory_reference
* state_mapping_version
* error_mapping_version
* idempotency_policy_id
* retry_policy_id
* timeout_policy_id
* monitoring_profile_id
* rollback_profile_id
* release_status
* approval_status
* risk_grade
* enabled_flag
* created_at
* updated_at
* status

### 7.3 Required_Constraints

The implementation must ensure:

* route_code is unique per provider and environment
* production route cannot be enabled without approval_status
* route_class must be controlled
* enabled_flag must be auditable
* credential_reference must not expose secret values
* route cannot be hard-deleted if events reference it
* route risk grade must block unsafe release
* route status must support disabled, pilot, production, deprecated, blocked

## 8. Provider_Route_Scope_Model

### 8.1 Purpose

`Provider_Route_Scope` defines where a route may operate.

A route must not be globally enabled by default.

### 8.2 Required_Fields

Required fields include:

* provider_route_scope_id
* provider_route_id
* tenant_id
* store_id
* operating_group_id
* legal_entity_id
* channel_id
* operation_scope
* payment_method_scope
* order_type_scope
* amount_limit
* transaction_volume_limit
* allowed_time_window
* effective_from
* effective_until
* approved_by
* approved_at
* status

### 8.3 Required_Constraints

The implementation must ensure:

* route scope is explicit
* missing scope means not allowed
* tenant scope does not imply all stores unless approved
* store scope does not imply all channels unless approved
* channel scope does not imply all operations unless approved
* expired scope disables route use
* amount and volume limits are enforced where configured

## 9. Financial_Event_Ledger_Model

### 9.1 Purpose

`Financial_Event_Ledger` is the append-only source of financial and POS Gateway event history.

It must record all financially relevant state transitions and evidence anchors.

### 9.2 Required_Event_Families

Required event families include:

* payment attempt created
* payment request sent
* payment approval received
* payment failure received
* payment timeout detected
* payment unknown classified
* duplicate payment suspected
* order submitted to POS
* POS accepted
* POS rejected
* POS unknown
* cancellation requested
* cancellation provider pending
* cancellation POS pending
* cancellation completed
* cancellation failed
* cancellation unknown
* refund requested
* refund provider pending
* refund completed
* refund failed
* refund unknown
* provider callback received
* provider callback rejected
* provider lookup performed
* manual override performed
* reconciliation mismatch detected
* reconciliation resolved
* dispute case opened
* evidence packet generated
* route disabled
* route enabled
* kill switch activated
* rollback executed

### 9.3 Required_Fields

Required fields include:

* financial_event_id
* event_type
* event_family
* event_version
* tenant_id
* store_id
* provider_id
* provider_route_id
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* dispute_case_id
* reconciliation_case_id
* release_request_id
* rollback_id
* actor_type
* actor_id
* source_channel
* amount
* currency
* status_before
* status_after
* reason_code
* idempotency_key
* correlation_id
* causation_id
* trace_id
* provider_reference
* pos_reference
* payload_hash
* evidence_reference
* occurred_at
* received_at
* recorded_at
* record_source
* immutable_sequence
* previous_event_hash
* event_hash

### 9.4 Append_Only_Rule

The financial event ledger must be append-only.

The implementation must prohibit:

* direct update of event content
* direct deletion of event content
* silent mutation of status fields
* silent correction of provider reference
* silent rewrite of amount
* silent removal of actor attribution
* silent removal of evidence reference

Corrections must be represented as new events.

### 9.5 Event_Hash_Rule

Where feasible, financial events should include tamper-evident hash fields.

Required hash logic should support:

* payload_hash
* previous_event_hash
* event_hash
* immutable_sequence

If hash chaining is deferred, the deferral must be explicitly recorded.

## 10. Payment_Attempt_Model

### 10.1 Purpose

`Payment_Attempt` represents an internal payment attempt independent of provider-specific payment IDs.

### 10.2 Required_Fields

Required fields include:

* payment_attempt_id
* tenant_id
* store_id
* order_id
* provider_id
* provider_route_id
* payment_method_type
* amount
* currency
* current_payment_state
* customer_visible_state
* staff_visible_state
* idempotency_key
* correlation_id
* provider_transaction_id
* provider_approval_id
* provider_cancellation_id
* provider_refund_reference
* first_requested_at
* last_provider_response_at
* last_lookup_at
* duplicate_risk_flag
* dispute_case_id
* reconciliation_case_id
* created_at
* updated_at
* status

### 10.3 Required_States

Required payment states include:

* `PAYMENT_NOT_STARTED`
* `PAYMENT_REQUESTED`
* `PAYMENT_PROVIDER_PENDING`
* `PAYMENT_APPROVED`
* `PAYMENT_FAILED`
* `PAYMENT_TIMEOUT`
* `PAYMENT_UNKNOWN`
* `PAYMENT_DUPLICATE_SUSPECTED`
* `PAYMENT_CANCEL_REQUESTED`
* `PAYMENT_CANCELLED`
* `PAYMENT_REFUND_REQUESTED`
* `PAYMENT_REFUNDED`
* `PAYMENT_DISPUTED`
* `PAYMENT_MANUAL_REVIEW_REQUIRED`

### 10.4 Projection_Rule

`Payment_Attempt` may store current state, but it must be rebuildable from `Financial_Event_Ledger`.

If projection and event ledger disagree, the event ledger and reconciliation process must govern.

## 11. POS_Submission_Model

### 11.1 Purpose

`POS_Submission` represents an attempt to submit an internal order to a POS route.

### 11.2 Required_Fields

Required fields include:

* pos_submission_id
* tenant_id
* store_id
* order_id
* provider_id
* provider_route_id
* pos_order_reference
* current_pos_state
* idempotency_key
* correlation_id
* submitted_at
* provider_response_at
* last_lookup_at
* retry_count
* manual_entry_flag
* manual_entry_reference
* reconciliation_case_id
* dispute_case_id
* created_at
* updated_at
* status

### 11.3 Required_States

Required POS submission states include:

* `POS_NOT_SUBMITTED`
* `POS_SUBMISSION_REQUESTED`
* `POS_SUBMISSION_PENDING`
* `POS_ACCEPTED`
* `POS_REJECTED`
* `POS_TIMEOUT`
* `POS_UNKNOWN`
* `POS_MANUAL_ENTRY_REQUIRED`
* `POS_MANUAL_ENTRY_RECORDED`
* `POS_REPLAY_PENDING`
* `POS_RECONCILIATION_REQUIRED`
* `POS_DISPUTED`

### 11.4 Manual_Entry_Rule

Manual POS entry must not replace the original internal order or POS submission record.

Manual entry must be recorded as linked recovery evidence.

## 12. Cancellation_Action_Model

### 12.1 Purpose

`Cancellation_Action` represents a cancellation request and its lifecycle.

Cancellation must not be collapsed into order status alone.

### 12.2 Required_Fields

Required fields include:

* cancellation_action_id
* tenant_id
* store_id
* order_id
* payment_attempt_id
* pos_submission_id
* provider_id
* provider_route_id
* cancellation_type
* cancellation_reason
* current_cancellation_state
* requested_by_actor_type
* requested_by_actor_id
* requested_at
* pos_cancellation_reference
* provider_cancellation_reference
* provider_response_at
* pos_response_at
* customer_notification_id
* refund_action_id
* dispute_case_id
* reconciliation_case_id
* idempotency_key
* correlation_id
* created_at
* updated_at
* status

### 12.3 Required_States

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
* `CANCEL_RECONCILIATION_REQUIRED`
* `CANCEL_DISPUTED`

## 13. Refund_Action_Model

### 13.1 Purpose

`Refund_Action` represents refund request and lifecycle.

Refund must not be collapsed into payment status alone.

### 13.2 Required_Fields

Required fields include:

* refund_action_id
* tenant_id
* store_id
* order_id
* payment_attempt_id
* provider_id
* provider_route_id
* refund_type
* refund_reason
* refund_amount
* currency
* current_refund_state
* requested_by_actor_type
* requested_by_actor_id
* requested_at
* provider_refund_reference
* provider_response_at
* customer_notification_id
* dispute_case_id
* reconciliation_case_id
* idempotency_key
* correlation_id
* created_at
* updated_at
* status

### 13.3 Required_States

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

### 13.4 Refund_Amount_Rule

Refund amount must be explicit.

Partial refund support must be provider-route-specific.

If partial refund is unsupported, the route must block partial refund automation and record a limitation.

## 14. Idempotency_Record_Model

### 14.1 Purpose

`Idempotency_Record` prevents duplicate financial and POS operations.

### 14.2 Required_Fields

Required fields include:

* idempotency_record_id
* idempotency_key
* tenant_id
* store_id
* provider_route_id
* operation_type
* target_entity_type
* target_entity_id
* request_hash
* first_seen_at
* last_seen_at
* request_count
* result_reference
* idempotency_state
* conflict_reason
* expires_at
* created_at
* updated_at

### 14.3 Required_States

Required idempotency states include:

* `IDEMPOTENCY_RESERVED`
* `IDEMPOTENCY_IN_PROGRESS`
* `IDEMPOTENCY_COMPLETED`
* `IDEMPOTENCY_CONFLICT`
* `IDEMPOTENCY_EXPIRED`
* `IDEMPOTENCY_BLOCKED`

### 14.4 Required_Constraints

The implementation must ensure:

* duplicate key with same request hash returns same result where safe
* duplicate key with different request hash creates conflict
* financial operation cannot proceed without idempotency key
* refund and cancellation replay must reuse governed idempotency keys
* idempotency expiration must not remove audit evidence

## 15. Correlation_Record_Model

### 15.1 Purpose

`Correlation_Record` links related events, requests, callbacks, provider references, order states, and dispute/reconciliation cases.

### 15.2 Required_Fields

Required fields include:

* correlation_id
* root_entity_type
* root_entity_id
* tenant_id
* store_id
* customer_reference
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* provider_route_id
* created_at
* closed_at
* status

### 15.3 Correlation_Rule

The system must be able to correlate:

* wait-order session
* table order session
* customer order
* payment attempt
* POS submission
* provider request
* provider callback
* cancellation
* refund
* customer notification
* staff action
* reconciliation case
* dispute case
* evidence packet
* release incident where applicable

## 16. State_Projection_Model

### 16.1 Purpose

`State_Projection` provides current operational state derived from event history.

Projection is not the audit source of truth.

### 16.2 Required_Fields

Required fields include:

* state_projection_id
* projection_type
* tenant_id
* store_id
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* current_internal_state
* current_customer_state
* current_staff_state
* current_financial_state
* current_pos_state
* current_reconciliation_state
* current_dispute_state
* source_event_sequence
* source_event_hash
* projection_version
* rebuilt_at
* updated_at
* status

### 16.3 Rebuild_Rule

Every projection must be rebuildable from source events.

Projection rebuild must support:

* single order rebuild
* payment attempt rebuild
* cancellation/refund rebuild
* dispute case rebuild
* reconciliation case rebuild
* provider route incident rebuild
* batch rebuild by store
* batch rebuild by provider route

If projection cannot be rebuilt, it must not be treated as authoritative.

## 17. Customer_Status_Projection_Model

### 17.1 Purpose

`Customer_Status_Projection` defines what the customer may safely see.

Customer status must be conservative and must not overstate certainty.

### 17.2 Required_Fields

Required fields include:

* customer_status_projection_id
* tenant_id
* store_id
* customer_reference
* order_id
* payment_attempt_id
* current_customer_status
* message_template_id
* message_template_version
* status_reason
* evidence_confidence_level
* updated_at
* expires_at
* status

### 17.3 Required_Statuses

Required customer statuses include:

* `ORDER_RECEIVED`
* `PAYMENT_PENDING`
* `PAYMENT_APPROVED`
* `PAYMENT_CONFIRMATION_PENDING`
* `ORDER_CONFIRMATION_PENDING`
* `ORDER_CONFIRMED`
* `STORE_REVIEW_REQUIRED`
* `CANCEL_REQUEST_RECEIVED`
* `CANCEL_CONFIRMATION_PENDING`
* `CANCEL_COMPLETED`
* `REFUND_REQUEST_RECEIVED`
* `REFUND_CONFIRMATION_PENDING`
* `REFUND_COMPLETED`
* `DUPLICATE_PAYMENT_UNDER_REVIEW`
* `SUPPORT_REVIEW_REQUIRED`
* `ROUTE_TEMPORARILY_UNAVAILABLE`

### 17.4 Prohibited_Status_Rule

Customer status must not show:

* payment completed without payment evidence
* cancellation completed without cancellation evidence
* refund completed without refund evidence
* order confirmed without order/POS/store evidence
* duplicate resolved without reconciliation or authorized decision

## 18. Staff_Status_Projection_Model

### 18.1 Purpose

`Staff_Status_Projection` defines what store staff may see and act upon.

Staff status must separate operational facts from financial facts.

### 18.2 Required_Fields

Required fields include:

* staff_status_projection_id
* tenant_id
* store_id
* order_id
* payment_attempt_id
* pos_submission_id
* current_staff_status
* allowed_action_set
* blocked_action_set
* escalation_required
* runbook_reference
* updated_at
* status

### 18.3 Required_Statuses

Required staff statuses include:

* `ORDER_RECEIVED`
* `ORDER_POS_PENDING`
* `ORDER_POS_ACCEPTED`
* `ORDER_POS_REJECTED`
* `ORDER_POS_UNKNOWN`
* `PAYMENT_PENDING`
* `PAYMENT_APPROVED`
* `PAYMENT_FAILED`
* `PAYMENT_UNKNOWN`
* `DUPLICATE_PAYMENT_REVIEW`
* `CANCEL_REQUESTED`
* `CANCEL_PENDING`
* `CANCEL_COMPLETED`
* `CANCEL_UNKNOWN`
* `REFUND_REQUESTED`
* `REFUND_PENDING`
* `REFUND_COMPLETED`
* `REFUND_UNKNOWN`
* `MANUAL_REVIEW_REQUIRED`
* `LOCAL_REPLAY_PENDING`
* `RECONCILIATION_REQUIRED`
* `PROVIDER_OUTAGE`
* `ROUTE_DISABLED`

## 19. Provider_Reference_Map_Model

### 19.1 Purpose

`Provider_Reference_Map` links internal IDs to provider-specific references without allowing provider IDs to become primary internal truth.

### 19.2 Required_Fields

Required fields include:

* provider_reference_map_id
* provider_id
* provider_route_id
* internal_entity_type
* internal_entity_id
* provider_reference_type
* provider_reference_value
* provider_reference_status
* first_seen_at
* last_seen_at
* evidence_reference
* created_at
* status

### 19.3 Required_Constraints

The implementation must ensure:

* provider references are linked, not primary
* multiple provider references can map to one internal entity where appropriate
* conflicting provider references create review condition
* provider reference update must be event-backed
* provider reference deletion must not remove audit history

## 20. Manual_Override_Record_Model

### 20.1 Purpose

`Manual_Override_Record` captures controlled manual changes or recovery actions.

### 20.2 Required_Fields

Required fields include:

* manual_override_id
* tenant_id
* store_id
* actor_type
* actor_id
* role_id
* target_entity_type
* target_entity_id
* override_type
* reason_code
* before_state
* after_state
* evidence_reference
* approval_required
* approved_by
* approved_at
* reauthentication_required
* reauthentication_result
* created_at
* status

### 20.3 Required_Constraints

Manual override must:

* create financial event where financially relevant
* require reason code
* require actor attribution
* require approval for sensitive actions
* not delete original state
* not bypass reconciliation requirement
* not mark payment/refund/cancellation complete without evidence unless authorized compliance resolution exists

## 21. Route_Kill_Switch_State_Model

### 21.1 Purpose

`Route_Kill_Switch_State` records whether a route is disabled, throttled, blocked, or emergency-stopped.

### 21.2 Required_Fields

Required fields include:

* kill_switch_state_id
* provider_route_id
* kill_switch_type
* current_state
* affected_scope
* activated_by
* activated_at
* activation_reason
* incident_id
* release_request_id
* rollback_id
* reenable_condition
* reenabled_by
* reenabled_at
* reviewed_by
* reviewed_at
* status

### 21.3 Required_States

Required kill switch states include:

* `ROUTE_ENABLED`
* `ROUTE_THROTTLED`
* `ROUTE_READ_ONLY`
* `ROUTE_DISABLED`
* `ROUTE_PAYMENT_BLOCKED`
* `ROUTE_REFUND_BLOCKED`
* `ROUTE_CANCELLATION_BLOCKED`
* `ROUTE_REPLAY_BLOCKED`
* `ROUTE_EMERGENCY_STOP`

## 22. Projection_Rebuild_Record_Model

### 22.1 Purpose

`Projection_Rebuild_Record` tracks projection rebuilds from event history.

### 22.2 Required_Fields

Required fields include:

* projection_rebuild_id
* projection_type
* target_entity_type
* target_entity_id
* tenant_id
* store_id
* source_event_start_sequence
* source_event_end_sequence
* rebuild_started_at
* rebuild_completed_at
* rebuild_status
* mismatch_detected
* mismatch_summary
* reviewer
* evidence_reference
* status

### 22.3 Rebuild_Trigger

Projection rebuild may be triggered by:

* event replay
* incident review
* reconciliation mismatch
* dispute case
* provider callback delay
* manual override
* code migration
* projection corruption suspicion
* audit sample
* legal hold review
* release rollback

## 23. Multi_Tenant_And_Store_Context

All POS Gateway core records must preserve tenant and store context where applicable.

Required context axes include:

* tenant_id
* store_id
* legal_entity_id where settlement or contract relevance exists
* operating_group_id where operational grouping relevance exists
* channel_id where customer or device route differs
* provider_route_id where route behavior differs

The implementation must not assume:

* one tenant has one provider
* one store has one provider
* one provider route applies to every channel
* one POS route applies to every payment method
* one legal entity maps directly to one operating group
* one store configuration is safe for franchise-wide rollout

## 24. Event_To_Projection_Rules

Every current state projection must define its source events.

Examples:

* payment current state must derive from payment events
* POS current state must derive from POS submission events
* cancellation current state must derive from cancellation events
* refund current state must derive from refund events
* customer status must derive from internal state and evidence confidence
* staff status must derive from internal state and runbook action boundary
* reconciliation status must derive from reconciliation events
* dispute status must derive from dispute case events
* route status must derive from release, kill switch, and configuration events

Projection rules must be versioned.

## 25. Data_Retention_And_Deletion_Rules

Core POS Gateway records must respect retention and legal hold policies.

The implementation must prohibit deletion when records are linked to:

* financial event ledger
* unresolved payment unknown
* unresolved POS unknown
* unresolved refund/cancellation unknown
* duplicate payment suspicion
* dispute case
* chargeback case
* reconciliation mismatch
* legal hold
* security incident
* audit sampling
* provider incident
* release rollback

Privacy deletion or masking must preserve lawful financial and audit metadata where required.

## 26. Access_Control_Requirements

Core records must be protected by role and context.

### 26.1 Store_Staff

Store staff may access:

* staff status projection
* allowed action set
* blocked action set
* masked customer reference
* operational runbook reference

Store staff must not access:

* raw provider payload
* provider credentials
* full financial event detail
* cross-store records
* raw dispute packet
* sensitive audit logs

### 26.2 Store_Manager

Store manager may access:

* store-scoped staff status
* store-scoped manual recovery records
* store-scoped reconciliation required indicators
* store-scoped escalation cases
* training and runbook status

### 26.3 Tenant_Admin

Tenant admin may access:

* tenant-scoped route summary
* tenant-scoped unresolved cases
* tenant-scoped store readiness
* tenant-scoped provider limitation summary
* masked financial status summaries

### 26.4 HQ_Compliance_And_Finance

HQ compliance and finance may access:

* financial event ledger
* refund/cancellation evidence
* dispute evidence
* reconciliation evidence
* manual override evidence
* route release and rollback evidence
* provider limitation evidence

Access must be logged.

### 26.5 Developer

Developer access to production financial data must be prohibited by default.

Break-glass access must be:

* time-limited
* ticket-linked
* logged
* reviewed
* masked where possible

## 27. Implementation_Order

The core data model should be implemented in the following order:

1. provider profile
2. provider route
3. provider route scope
4. financial event ledger
5. idempotency record
6. correlation record
7. payment attempt
8. POS submission
9. cancellation action
10. refund action
11. provider reference map
12. state projection
13. customer status projection
14. staff status projection
15. manual override record
16. route kill switch state
17. projection rebuild record

Provider-specific adapter tables must not be built before the provider-independent core model exists.

## 28. Test_Requirements

The implementation must support tests for:

* provider route cannot enable without scope
* provider route cannot enable without approval
* financial event ledger is append-only
* payment state projection rebuilds from events
* POS state projection rebuilds from events
* refund state projection rebuilds from events
* cancellation state projection rebuilds from events
* customer status does not overstate certainty
* staff status separates operational and financial truth
* idempotency conflict is detected
* duplicate request does not duplicate financial state
* provider reference conflict creates review condition
* manual override creates audit event
* kill switch blocks route use
* projection rebuild detects mismatch
* deletion is blocked when legal hold or dispute exists

## 29. Readiness_Checklist

Before provider-specific adapter implementation begins, the following checklist must pass.

### 29.1 Core_Registry

* [ ] Provider profile model exists.
* [ ] Provider route model exists.
* [ ] Provider route scope model exists.
* [ ] Route class is controlled.
* [ ] Route type is controlled.
* [ ] Route environment is controlled.
* [ ] Route approval status is controlled.
* [ ] Route cannot be globally enabled by default.

### 29.2 Event_And_State

* [ ] Financial event ledger exists.
* [ ] Financial event ledger is append-only.
* [ ] Event type is controlled.
* [ ] Event version is recorded.
* [ ] Correlation id is recorded.
* [ ] Idempotency key is recorded.
* [ ] Projection model exists.
* [ ] Projection rebuild rule exists.

### 29.3 Payment_POS_Cancel_Refund

* [ ] Payment attempt model exists.
* [ ] POS submission model exists.
* [ ] Cancellation action model exists.
* [ ] Refund action model exists.
* [ ] Payment unknown state exists.
* [ ] POS unknown state exists.
* [ ] Cancellation unknown state exists.
* [ ] Refund unknown state exists.
* [ ] Requested and completed states are separated.

### 29.4 Evidence_And_Control

* [ ] Provider reference map exists.
* [ ] Manual override record exists.
* [ ] Customer status projection exists.
* [ ] Staff status projection exists.
* [ ] Kill switch state exists.
* [ ] Projection rebuild record exists.
* [ ] Access control requirements are defined.
* [ ] Deletion block rules are defined.

### 29.5 Implementation_Safety

* [ ] Provider-specific adapter work is blocked until core model exists.
* [ ] Production route enablement requires scope.
* [ ] Production route enablement requires approval.
* [ ] Customer success status requires evidence.
* [ ] Staff financial override is blocked without authorization.
* [ ] Route disable does not delete evidence.
* [ ] Projection mismatch creates review path.

## 30. Non_Goals

This policy does not define:

* final SQL migration syntax
* final table naming convention
* final index strategy
* final RLS policy text
* final provider adapter code
* final API endpoint implementation
* final UI projection queries
* final observability dashboard
* final accounting ledger model

Those must be handled by implementation, database, security, API, UI, and finance documents.

This policy defines the logical core data model boundary required before POS Gateway provider-specific implementation begins.

## 31. Acceptance_Criteria

This policy is accepted when:

* provider-independent data model is defined
* provider profile model exists
* provider route model exists
* provider route scope model exists
* financial event ledger model exists
* payment attempt model exists
* POS submission model exists
* cancellation action model exists
* refund action model exists
* idempotency model exists
* correlation model exists
* state projection model exists
* customer status projection model exists
* staff status projection model exists
* provider reference map exists
* manual override model exists
* kill switch state model exists
* projection rebuild model exists
* current state is rebuildable from events
* provider-specific references do not become internal source of truth
* production route cannot be globally enabled by default
* provider adapter implementation is blocked until this core model exists

## 32. Final_Rule

The POS Gateway must own its financial truth.

Providers may supply references, responses, callbacks, receipts, settlement files, and errors.

They must not define the internal source of truth.

The core data model must be built before provider adapters, because once provider-specific assumptions enter the data spine, every later POS, kiosk, refund, cancellation, reconciliation, and dispute feature becomes harder to trust.
