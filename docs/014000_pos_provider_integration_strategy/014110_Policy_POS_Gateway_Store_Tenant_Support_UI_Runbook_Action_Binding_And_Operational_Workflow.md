# 014110_Policy_POS_Gateway_Store_Tenant_Support_UI_Runbook_Action_Binding_And_Operational_Workflow

## 1. Purpose

This document defines the POS Gateway store UI, tenant UI, HQ support UI, runbook action binding, operational workflow, staff action control, and support escalation policy.

The POS Gateway must not expose ambiguous payment, POS, cancellation, refund, duplicate payment, reconciliation, or dispute states as simple text labels without guiding the operator toward safe actions.

The purpose of this policy is to ensure that every store-facing, tenant-facing, and support-facing UI state binds to:

* allowed actions
* blocked actions
* required evidence
* customer-safe message
* escalation path
* runbook reference
* audit event
* reconciliation requirement
* dispute requirement where applicable

The UI must help operators do the correct thing and prevent them from doing unsafe things.

## 2. Scope

This policy applies to all operational UI and workflow surfaces related to POS Gateway, including:

* store staff order screen
* store manager recovery screen
* tenant admin monitoring screen
* HQ support console
* HQ compliance console
* HQ finance/reconciliation console
* dispute support screen
* refund/cancellation support screen
* duplicate payment review screen
* provider outage banner
* degraded-mode banner
* local replay screen
* reconciliation case screen
* evidence packet request screen
* provider escalation screen
* route rollback notice screen
* store activation readiness screen
* training acknowledgement screen

This policy applies before store pilot, tenant rollout, support console implementation, staff app implementation, tenant admin dashboard implementation, or production route activation.

## 3. Relationship_To_Previous_Documents

This document follows:

* `014108_Policy_POS_Gateway_Dispute_Case_Evidence_Packet_Generator_Support_And_Chargeback_Export.md`

It also depends on:

* `014083_Policy_POS_Gateway_Store_Tenant_Operations_Runbook_Handoff_And_Training_Readiness.md`
* `014098_Policy_POS_Gateway_State_Machine_Payment_POS_Cancellation_Refund_And_Customer_Status.md`
* `014102_Policy_POS_Gateway_Idempotency_Retry_Duplicate_Prevention_And_Safe_Replay_Implementation.md`
* `014106_Policy_POS_Gateway_Reconciliation_Case_Settlement_Matching_Provider_POS_And_Internal_Ledger.md`

The rule is:

> UI must not merely display POS Gateway state.
> UI must enforce the safe operational workflow for that state.

## 4. Core_Principle

Every operational UI state must answer five questions:

1. What is known?
2. What is unknown?
3. What may the operator do?
4. What must the operator not do?
5. Who owns the next step?

The UI must not leave staff, managers, tenant admins, or HQ support to infer financial truth from ambiguous states.

A payment unknown state must not look like a payment failure.
A refund pending state must not look like refund completion.
A cancellation requested state must not look like cancellation completion.
A POS unknown state must not look like POS rejection.
A duplicate payment warning must not be dismissible without review.

## 5. UI_Surface_Categories

The POS Gateway must define standardized UI surface categories.

Required categories include:

* `STORE_STAFF_OPERATION_UI`
* `STORE_MANAGER_RECOVERY_UI`
* `TENANT_ADMIN_OVERVIEW_UI`
* `HQ_SUPPORT_CASE_UI`
* `HQ_COMPLIANCE_REVIEW_UI`
* `HQ_FINANCE_RECONCILIATION_UI`
* `DISPUTE_CASE_UI`
* `REFUND_CANCELLATION_REVIEW_UI`
* `DUPLICATE_PAYMENT_REVIEW_UI`
* `PROVIDER_OUTAGE_STATUS_UI`
* `LOCAL_REPLAY_STATUS_UI`
* `RECONCILIATION_CASE_UI`
* `EVIDENCE_PACKET_UI`
* `ROUTE_RELEASE_ROLLBACK_UI`
* `STORE_ACTIVATION_READINESS_UI`
* `TRAINING_ACKNOWLEDGEMENT_UI`

Each UI surface must define:

* target role
* allowed data scope
* status display rules
* allowed action set
* blocked action set
* required confirmation
* evidence capture fields
* escalation path
* audit logging requirement

## 6. Status_Display_Principles

The UI must display status according to evidence confidence.

Status display must distinguish:

* confirmed success
* confirmed failure
* pending provider response
* pending POS response
* unknown result
* duplicate risk
* manual review required
* reconciliation required
* dispute required
* route disabled
* provider outage
* local replay pending

The UI must not use ambiguous labels such as:

* done
* complete
* ok
* processed
* failed
* pending

unless those labels are expanded into controlled, evidence-aware status categories.

## 7. Store_Staff_UI_Requirements

### 7.1 Purpose

Store staff UI must support fast operational handling without allowing unsafe financial decisions.

### 7.2 Required_Status_Cards

Store staff UI must show status cards for:

* order state
* payment state
* POS state
* cancellation state
* refund state
* duplicate payment warning
* provider route status
* local replay status
* reconciliation requirement
* support escalation requirement

### 7.3 Required_Action_Binding

Each status card must bind to:

* allowed actions
* blocked actions
* evidence required
* manager required
* HQ support required
* customer-safe message
* runbook link

### 7.4 Store_Staff_Allowed_Actions

Store staff may be allowed to:

* acknowledge customer waiting
* view customer-safe status
* view staff-safe operational status
* pause preparation
* mark preparation started where allowed
* request manager review
* request HQ support
* attach customer receipt evidence
* attach POS terminal evidence
* add operational note
* record customer cancellation request
* record customer refund request
* follow provider outage guide
* follow manual fallback guide

### 7.5 Store_Staff_Blocked_Actions

Store staff must be blocked from:

* marking payment complete without evidence
* marking refund complete without evidence
* marking cancellation complete without evidence
* clearing duplicate payment warning
* clearing reconciliation requirement
* clearing local replay conflict
* closing dispute case
* retrying payment during payment unknown
* retrying refund during refund unknown
* retrying cancellation during cancellation unknown
* manually replaying local ledger
* disabling provider route
* editing provider reference
* changing route configuration

## 8. Store_Manager_UI_Requirements

### 8.1 Purpose

Store manager UI must support controlled recovery and escalation.

### 8.2 Required_Manager_Workflows

Store manager UI must support:

* manual POS entry approval
* preparation decision review
* customer complaint intake
* staff action review
* evidence attachment review
* escalation to HQ support
* store-level incident note
* provider outage acknowledgment
* duplicate payment hold confirmation
* local replay conflict escalation
* reconciliation-required case acknowledgment

### 8.3 Manager_Approval_Rules

Manager approval must be required for:

* manual POS entry
* kitchen execution during POS unknown
* accepting customer receipt as supporting evidence
* store-side cancellation note after preparation started
* fulfillment decision during ambiguous state
* staff action correction
* escalation closure request

Manager approval must not finalize payment, refund, cancellation, or settlement truth unless authorized by separate financial workflow.

## 9. Tenant_Admin_UI_Requirements

### 9.1 Purpose

Tenant admin UI must provide tenant-level operational visibility without exposing unauthorized financial or cross-tenant evidence.

### 9.2 Required_Tenant_Views

Tenant admin UI must show:

* route health by store
* provider limitation summary
* payment unknown count
* POS unknown count
* cancellation pending count
* refund pending count
* duplicate payment review count
* reconciliation required count
* dispute case summary
* store training readiness
* store activation status
* provider outage impact
* route rollback notice
* tenant rollout scope

### 9.3 Tenant_Admin_Blocked_Actions

Tenant admin must be blocked from:

* enabling blocked provider route
* expanding route beyond release scope
* overriding financial state
* clearing provider risk
* closing dispute case without authority
* closing reconciliation case without authority
* viewing raw provider payload
* viewing cross-tenant evidence
* accessing credentials
* bypassing store readiness gate

## 10. HQ_Support_UI_Requirements

### 10.1 Purpose

HQ support UI must provide case-level operational review and customer response support.

### 10.2 Required_HQ_Support_Workflows

HQ support UI must support:

* dispute case intake
* payment unknown review
* POS unknown review
* duplicate payment review
* refund pending review
* cancellation pending review
* evidence packet generation request
* customer notification review
* store escalation review
* provider lookup request
* provider escalation request
* manual recovery review
* reconciliation case linkage
* support response template selection

### 10.3 Support_Action_Boundary

HQ support may recommend or initiate governed actions but must not bypass:

* provider evidence requirement
* reconciliation requirement
* refund/cancellation state machine
* dispute packet requirement
* compliance review requirement
* finance review requirement
* legal hold

## 11. HQ_Compliance_UI_Requirements

HQ compliance UI must support:

* evidence packet review
* missing evidence review
* manual override review
* consumer protection review
* customer-facing status review
* dispute closure review
* legal hold application
* export history review
* provider limitation review
* waiver and accepted risk review

Compliance UI must provide clear indicators for:

* misleading customer status risk
* missing provider evidence
* missing POS evidence
* unauthorized correction
* expired waiver
* legal hold active
* evidence export performed

## 12. HQ_Finance_Reconciliation_UI_Requirements

HQ finance UI must support:

* reconciliation case review
* settlement record review
* payment mismatch review
* refund mismatch review
* cancellation mismatch review
* provider-only record review
* internal-only record review
* POS-only record review
* settlement-only record review
* unresolved amount summary
* finance closure approval
* chargeback financial impact review

Finance UI must not allow closure without evidence and reason code.

## 13. Dispute_Case_UI_Requirements

Dispute case UI must show:

* dispute category
* current lifecycle state
* customer claim summary
* financial impact
* current payment state
* current POS state
* current cancellation state
* current refund state
* reconciliation status
* evidence packet status
* missing evidence flags
* owner
* due date
* next required action
* customer response status
* closure requirement

Dispute case UI must require evidence packet before closure.

## 14. Evidence_Packet_UI_Requirements

Evidence packet UI must support:

* packet generation request
* packet type selection
* redaction profile selection
* section preview
* missing evidence review
* packet version history
* export request
* export log
* access log
* legal hold indicator
* packet integrity check

The UI must warn when packet evidence is incomplete.

## 15. Refund_And_Cancellation_UI_Requirements

Refund and cancellation UI must distinguish:

* request received
* provider pending
* POS pending
* completed
* failed
* unknown
* manual review required
* reconciliation required
* dispute linked

The UI must not provide a “complete” button unless the user has authorized role and supporting evidence exists.

Refund and cancellation UI must show:

* original payment
* refund/cancel amount
* provider status
* POS status
* idempotency status
* duplicate risk
* customer notification status
* reconciliation requirement
* dispute linkage

## 16. Duplicate_Payment_UI_Requirements

Duplicate payment UI must show:

* detection rule
* primary payment attempt
* suspected duplicate payment attempt
* amount comparison
* timestamp comparison
* provider reference comparison
* POS reference comparison
* fulfillment status
* customer status
* refund recommendation
* reconciliation requirement
* final determination status

The UI must block:

* dismissing duplicate risk without reason
* asking customer to pay again without approval
* auto-refunding without idempotency and provider verification
* closing duplicate case without reconciliation or authorized decision

## 17. Local_Replay_UI_Requirements

Local replay UI must show:

* local ledger record
* replay eligibility
* replay status
* replay attempt count
* block reason
* idempotency status
* provider lookup status
* reconciliation requirement
* dispute linkage
* customer status impact
* staff action restriction

Store staff must not be able to manually force replay.

HQ support or technical owner may trigger replay only if policy permits and audit event is created.

## 18. Provider_Outage_UI_Requirements

Provider outage UI must show:

* affected provider
* affected route
* affected stores
* affected tenants
* affected channels
* current severity
* allowed actions
* blocked actions
* customer message guidance
* staff message guidance
* fallback path
* provider escalation status
* rollback status
* expected next review time

Provider outage banner must appear on store and tenant surfaces when customer flow is affected.

## 19. Route_Release_And_Rollback_UI_Requirements

Release and rollback UI must support:

* release request view
* release scope view
* approval status
* route enablement status
* kill switch status
* rollback trigger
* rollback action
* re-enable condition
* affected tenant/store/channel
* post-release monitoring
* rollback evidence

Route enablement UI must block activation if release gate fails.

## 20. Runbook_Action_Binding

Every operational status must bind to a runbook action.

Required binding fields include:

* status_code
* role
* allowed_action_set
* blocked_action_set
* required_evidence
* required_approval
* escalation_target
* customer_message_template
* staff_guidance_template
* runbook_reference
* audit_event_type
* reconciliation_requirement
* dispute_requirement

A UI action without runbook binding must not be exposed in production.

## 21. Action_Confirmation_Requirements

High-risk actions must require confirmation.

Confirmation is required for:

* manual POS entry
* manager recovery approval
* HQ support refund recommendation
* HQ support cancellation recommendation
* evidence packet export
* legal hold release
* route disable
* route re-enable
* reconciliation closure
* dispute closure
* duplicate payment dismissal
* accepted risk approval

Confirmation must show:

* action summary
* affected customer/order/payment
* evidence status
* risk warning
* reason code field
* audit consequence

## 22. Reason_Code_Requirements

Reason code is required for:

* manual recovery
* manual POS entry
* refund/cancellation review decision
* duplicate payment dismissal
* reconciliation closure
* dispute closure
* route rollback
* route re-enable
* evidence export
* legal hold release
* customer compensation decision

Reason codes must be controlled values, not free text only.

Free-text notes may supplement but not replace reason code.

## 23. Audit_Event_Requirements

Every high-risk UI action must create an audit event.

Required audit fields include:

* actor_type
* actor_id
* role
* tenant_id
* store_id
* action_type
* target_entity_type
* target_entity_id
* before_state
* after_state
* reason_code
* evidence_reference
* approval_reference
* occurred_at
* recorded_at

UI must not allow silent state mutation.

## 24. UI_Data_Model_Requirements

The implementation must support the following logical records.

### 24.1 Operational_UI_Action_Binding

Required fields:

* action_binding_id
* ui_surface
* role
* status_code
* allowed_action_set
* blocked_action_set
* required_evidence
* required_approval
* escalation_target
* runbook_reference
* customer_message_template_id
* staff_guidance_template_id
* audit_event_type
* status

### 24.2 UI_Action_Record

Required fields:

* ui_action_id
* action_binding_id
* actor_type
* actor_id
* role
* tenant_id
* store_id
* target_entity_type
* target_entity_id
* action_type
* reason_code
* evidence_reference
* approval_reference
* result_status
* created_at

### 24.3 UI_Alert_Banner_Record

Required fields:

* ui_alert_banner_id
* banner_type
* severity
* provider_id
* provider_route_id
* tenant_id
* store_id
* channel_id
* message_template_id
* allowed_action_summary
* blocked_action_summary
* runbook_reference
* active_from
* active_until
* status

### 24.4 Operational_Workflow_Record

Required fields:

* workflow_id
* workflow_type
* tenant_id
* store_id
* provider_route_id
* related_entity_type
* related_entity_id
* current_step
* owner_role
* owner_id
* due_at
* status
* created_at
* updated_at

### 24.5 Training_Acknowledgement_Record

Required fields:

* acknowledgement_id
* trainee_role
* trainee_id
* tenant_id
* store_id
* runbook_reference
* prohibited_action_set
* acknowledged_at
* version
* status

## 25. Access_Control

UI surfaces must enforce role-based and context-based access.

### 25.1 Store_Staff

Store staff may access only:

* store-scoped operational status
* allowed action buttons
* blocked action warnings
* customer-safe message
* evidence attachment where allowed
* escalation request

### 25.2 Store_Manager

Store manager may access:

* store-scoped recovery workflows
* staff action review
* manager approval actions
* store escalation cases
* manual POS entry workflow

### 25.3 Tenant_Admin

Tenant admin may access:

* tenant-scoped operational summary
* store readiness
* route health
* unresolved case summary
* rollout and rollback notices

### 25.4 HQ_Support

HQ support may access:

* support case workflows
* evidence packet request
* provider lookup request
* support response templates
* store escalation review

### 25.5 HQ_Compliance_And_Finance

Compliance and finance may access:

* evidence packet review
* reconciliation closure
* dispute closure
* export history
* legal hold
* financial impact records

### 25.6 Developer

Developer must not have production UI override authority by default.

Break-glass diagnostic access must not expose operational action buttons unless explicitly authorized.

## 26. Observability_Requirements

The system must monitor:

* staff blocked action attempts
* manager approval count
* manual POS entry count
* support escalation count
* evidence packet request count
* reconciliation closure count
* dispute closure count
* duplicate payment dismissal count
* route rollback UI action count
* provider outage banner delivery
* customer-safe message usage
* runbook link usage
* training acknowledgement completion
* unauthorized UI action attempt

Metrics must be tagged by:

* tenant_id
* store_id
* provider_route_id
* role
* ui_surface
* action_type
* status_code

## 27. Test_Requirements

The implementation must support tests for:

* payment unknown blocks pay-again action
* duplicate payment warning cannot be dismissed by staff
* refund pending cannot be marked completed without evidence
* cancellation pending cannot be marked completed without evidence
* POS unknown shows manager/HQ escalation
* local replay cannot be forced by store staff
* provider outage banner appears on affected store UI
* route enable button is blocked when release gate fails
* evidence packet export requires role and reason code
* reconciliation closure requires evidence and approval
* staff cannot view raw provider payload
* tenant admin cannot view cross-tenant cases
* runbook binding is required before action appears
* high-risk action creates audit event

## 28. Readiness_Checklist

Before operational UI enters controlled implementation, the following checklist must pass.

### 28.1 UI_Surface

* [ ] Store staff UI surface is defined.
* [ ] Store manager UI surface is defined.
* [ ] Tenant admin UI surface is defined.
* [ ] HQ support UI surface is defined.
* [ ] HQ compliance UI surface is defined.
* [ ] HQ finance UI surface is defined.
* [ ] Evidence packet UI surface is defined.
* [ ] Reconciliation UI surface is defined.

### 28.2 Action_Binding

* [ ] Allowed actions are defined.
* [ ] Blocked actions are defined.
* [ ] Runbook action binding is defined.
* [ ] High-risk confirmations are defined.
* [ ] Reason codes are defined.
* [ ] Audit event requirements are defined.
* [ ] UI action without runbook binding is blocked.

### 28.3 Safety

* [ ] Payment unknown blocks unsafe staff action.
* [ ] Duplicate payment warning blocks unsafe staff action.
* [ ] Refund pending blocks completion.
* [ ] Cancellation pending blocks completion.
* [ ] Reconciliation required cannot be cleared by staff.
* [ ] Dispute case cannot close without evidence packet.
* [ ] Route release gate blocks enablement.
* [ ] Provider outage banner is defined.

### 28.4 Access_And_Monitoring

* [ ] Role-based access is defined.
* [ ] Context-based access is defined.
* [ ] Raw provider payload is restricted.
* [ ] UI action audit is defined.
* [ ] Blocked action metrics are defined.
* [ ] Tests are defined.

## 29. Non_Goals

This policy does not define:

* final UI layout
* final component design
* final color system
* final frontend framework
* final translation copy
* final customer support script
* final mobile app implementation
* final tenant dashboard implementation
* final role permission SQL

Those must be handled by UI/UX, frontend, i18n, support, security, and implementation documents.

This policy defines the operational UI and runbook action-binding boundary required before POS Gateway store, tenant, and support screens are implemented.

## 30. Acceptance_Criteria

This policy is accepted when:

* operational UI surfaces are defined
* store staff UI blocks unsafe financial actions
* store manager UI supports controlled recovery
* tenant admin UI provides scoped visibility
* HQ support UI supports evidence-based review
* HQ compliance and finance UIs support controlled closure
* dispute UI requires evidence packet
* refund/cancellation UI distinguishes pending from completed
* duplicate payment UI blocks unsafe dismissal
* local replay UI blocks staff-forced replay
* provider outage UI gives allowed and blocked actions
* route release UI blocks failed release gate
* every UI action binds to runbook action policy
* high-risk actions require confirmation and reason code
* UI actions create audit events
* access is role-scoped and context-scoped
* UI safety is testable

## 31. Final_Rule

A dangerous POS Gateway state becomes more dangerous when the UI makes it look simple.

The UI must not hide uncertainty, collapse states, or offer unsafe buttons.

If the system is unsure, the UI must show uncertainty, block unsafe action, guide the operator, preserve evidence, and escalate to the right owner.
