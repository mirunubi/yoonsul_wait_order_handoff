# 14079_Policy_POS_Gateway_Provider_Risk_Register_Known_Limitations_Waiver_And_Deferral

## 1. Purpose

This document defines the provider risk register, known limitations, waiver, deferral, and controlled risk acceptance policy for the POS Gateway Resilience lane.

The POS Gateway must not hide provider limitations inside implementation notes, developer comments, informal Slack messages, vendor emails, or temporary assumptions.

Every POS, payment, VAN/PG, kiosk, mini-kiosk, provider bridge, receipt, settlement, export/import, printer fallback, and manual fallback route must maintain a visible risk register before it can be used in controlled implementation, pilot, production, or tenant rollout.

The purpose of this policy is to ensure that known limitations are not forgotten, bypassed, normalized, or accidentally promoted into production risk.

## 2. Scope

This policy applies to all provider and route risks related to:

* POS provider API
* POS provider callback
* POS order submission
* POS cancellation
* POS receipt
* POS settlement
* payment authorization
* payment cancellation
* refund
* partial refund
* VAN/PG route
* payment provider callback
* provider lookup
* kiosk payment
* mini-kiosk payment
* wait-order handoff
* table order session handoff
* local ledger replay
* reconciliation
* dispute evidence packet
* provider official status
* provider sandbox limitation
* provider production limitation
* unofficial bridge
* tenant-specific exception
* store-specific workaround
* manual POS entry
* printer fallback
* settlement file ingestion

This policy applies to risks discovered during discovery, documentation review, sandbox test, certification, implementation, pilot, production operation, incident response, dispute review, reconciliation, and post-incident re-verification.

## 3. Relationship_To_Previous_Documents

This document follows:

* `05640_POS_Gateway_Compliance_Financial_Audit_Regulatory_And_Consumer_Protection_Readiness_Policy.md`
* `14071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md`
* `14073_Policy_POS_Gateway_Offline_Degraded_Mode_Local_Ledger_Replay_And_Reconciliation.md`
* `14075_Policy_POS_Gateway_Provider_Onboarding_Certification_Sandbox_And_Official_Verification.md`
* `14077_Policy_POS_Gateway_Observability_SLO_Incident_Command_And_Provider_Escalation.md`

The previous documents define compliance evidence, dispute handling, degraded-mode replay, provider verification, and runtime observability.

This document defines how known risks, limitations, waivers, and deferred controls must be registered and governed.

The rule is:

> A known limitation that is not registered is an unmanaged production hazard.

## 4. Core_Principle

The POS Gateway must treat every provider limitation as a governed risk object.

A limitation must not remain as:

* verbal knowledge
* developer memory
* vendor promise
* sales claim
* temporary TODO
* untracked workaround
* hidden exception
* pilot-only assumption
* undocumented manual step
* ignored sandbox gap
* ignored provider warning
* ignored incident lesson

If a provider route cannot fully satisfy a required control, the gap must be recorded as one of:

* known limitation
* accepted risk
* temporary waiver
* deferred scope
* blocked condition
* pilot-only restriction
* manual fallback dependency
* provider re-verification requirement

## 5. Risk_Register_Requirement

Every provider route must have a provider risk register before controlled implementation.

The risk register must include:

* provider-level risks
* route-level risks
* operation-level risks
* environment-level risks
* tenant/store/channel-specific risks
* compliance risks
* security risks
* financial risks
* consumer protection risks
* operational risks
* monitoring risks
* support escalation risks
* evidence gap risks
* rollback risks
* waiver and deferral records

A provider route without a current risk register must not be treated as production-ready.

## 6. Risk_Categories

The provider risk register must classify risks into standardized categories.

Required categories include:

* `OFFICIAL_STATUS_RISK`
* `CONTRACT_SCOPE_RISK`
* `DOCUMENTATION_GAP_RISK`
* `SANDBOX_LIMITATION_RISK`
* `PRODUCTION_BEHAVIOR_UNKNOWN_RISK`
* `AUTHENTICATION_RISK`
* `CREDENTIAL_RISK`
* `CALLBACK_RISK`
* `IDEMPOTENCY_RISK`
* `DUPLICATE_PAYMENT_RISK`
* `PAYMENT_STATE_AMBIGUITY_RISK`
* `POS_STATE_AMBIGUITY_RISK`
* `CANCELLATION_RISK`
* `REFUND_RISK`
* `PARTIAL_REFUND_RISK`
* `SETTLEMENT_RISK`
* `RECONCILIATION_RISK`
* `EVIDENCE_GAP_RISK`
* `DISPUTE_RESPONSE_RISK`
* `CUSTOMER_NOTIFICATION_RISK`
* `MANUAL_RECOVERY_RISK`
* `OFFLINE_REPLAY_RISK`
* `PERFORMANCE_RISK`
* `RATE_LIMIT_RISK`
* `COST_RISK`
* `PROVIDER_SUPPORT_RISK`
* `PRIVACY_RISK`
* `SECURITY_RISK`
* `LEGAL_COMPLIANCE_RISK`
* `TENANT_ROLLOUT_RISK`
* `STORE_OPERATION_RISK`
* `KIOSK_REUSE_RISK`
* `MINI_KIOSK_REUSE_RISK`

Each risk category must have an owner, severity, mitigation, status, and review date.

## 7. Risk_Severity_Model

Risks must be classified by severity.

Required severity levels include:

* `RISK_LOW`
* `RISK_MEDIUM`
* `RISK_HIGH`
* `RISK_CRITICAL`
* `RISK_BLOCKING`

### 7.1 RISK_LOW

A low risk is acceptable with normal monitoring.

Examples:

* minor provider documentation ambiguity
* non-critical dashboard delay
* non-financial notification limitation
* low-volume sandbox limitation

### 7.2 RISK_MEDIUM

A medium risk requires mitigation and owner tracking.

Examples:

* incomplete error code mapping
* provider lookup delay
* callback ordering not guaranteed
* settlement file delayed but available
* manual review needed for rare scenarios

### 7.3 RISK_HIGH

A high risk requires explicit approval before pilot or controlled implementation.

Examples:

* refund result may remain unknown
* cancellation result may remain unknown
* POS acceptance cannot be queried
* partial refund unsupported
* callback missing cannot be detected reliably
* provider support response path is weak
* reconciliation requires manual file upload

### 7.4 RISK_CRITICAL

A critical risk requires executive, compliance, or technical owner approval before any limited production use.

Examples:

* duplicate payment risk cannot be fully eliminated
* payment approval may be unknown during active checkout
* provider evidence may be unavailable for disputes
* customer-facing status may be delayed during outage
* settlement mismatch may affect payout
* provider route may require manual financial correction

### 7.5 RISK_BLOCKING

A blocking risk prevents route use.

Examples:

* provider prohibits the intended use
* credentials cannot be secured
* callback cannot be authenticated
* audit event cannot be written
* financial state cannot be reconciled
* refund/cancellation cannot be safely controlled
* duplicate payment risk is uncontrolled
* privacy exposure is unacceptable
* legal/compliance owner blocks the route

## 8. Known_Limitation_Record

Every known limitation must be recorded.

Required fields:

* limitation_id
* provider_id
* provider_route_id
* route_class
* environment
* operation_type
* limitation_category
* limitation_summary
* detailed_description
* discovered_at
* discovered_by
* discovery_source
* affected_tenants
* affected_stores
* affected_channels
* affected_customer_flow
* affected_financial_flow
* affected_compliance_flow
* severity
* customer_impact
* financial_impact
* compliance_impact
* operational_impact
* mitigation
* workaround
* owner
* review_due_at
* status
* related_test_result
* related_incident_id
* related_dispute_case_id
* related_waiver_id
* related_deferral_id

## 9. Discovery_Source_Classification

The risk register must classify how the limitation was discovered.

Required discovery sources include:

* `PROVIDER_DOCUMENTATION`
* `PROVIDER_CONTACT`
* `SANDBOX_TEST`
* `CERTIFICATION_TEST`
* `CONTROLLED_IMPLEMENTATION`
* `PILOT_OPERATION`
* `PRODUCTION_INCIDENT`
* `CUSTOMER_DISPUTE`
* `CHARGEBACK_CASE`
* `RECONCILIATION_MISMATCH`
* `SETTLEMENT_REVIEW`
* `SECURITY_REVIEW`
* `COMPLIANCE_REVIEW`
* `STORE_REPORT`
* `TENANT_REPORT`
* `SUPPORT_TICKET`
* `DEVELOPER_ANALYSIS`
* `POST_INCIDENT_REVIEW`
* `PROVIDER_NOTICE`

A limitation discovered through incident, dispute, or reconciliation must be treated as higher risk until reviewed.

## 10. Waiver_Policy

### 10.1 Waiver_Definition

A waiver is a temporary governance decision allowing a route to proceed despite a known unmet requirement.

A waiver does not mean the requirement is removed.

A waiver means:

* the gap is known
* the risk is accepted for a limited scope
* mitigation is defined
* owner is assigned
* expiration is defined
* review is required
* production expansion is blocked until resolved or reapproved

### 10.2 Waiver_Allowed_Use

A waiver may be used for:

* sandbox limitation
* pilot-only limitation
* low-volume tenant trial
* controlled store pilot
* non-financial feature gap
* manual fallback dependency
* provider documentation delay
* temporary monitoring gap
* temporary settlement file limitation
* temporary operational SOP dependency

### 10.3 Waiver_Prohibited_Use

A waiver must not be used to bypass:

* uncontrolled duplicate payment risk
* inability to write financial audit events
* unauthenticated callback
* exposed provider credentials
* illegal provider use
* known privacy exposure
* false customer-facing financial status
* inability to preserve dispute evidence
* inability to block unsafe replay
* inability to identify affected customers
* compliance owner block
* security owner block

### 10.4 Waiver_Record

Every waiver must record:

* waiver_id
* provider_id
* provider_route_id
* related_limitation_id
* waived_requirement
* waiver_reason
* allowed_scope
* prohibited_scope
* affected_tenant_scope
* affected_store_scope
* affected_channel_scope
* affected_operation_scope
* risk_severity
* mitigation
* monitoring_requirement
* customer_protection_condition
* manual_review_condition
* rollback_condition
* owner
* approver_role
* approver_id
* approved_at
* expires_at
* review_due_at
* status

## 11. Deferral_Policy

### 11.1 Deferral_Definition

A deferral is a decision to move a capability, control, provider feature, route expansion, or automation out of current scope.

A deferral differs from a waiver.

A waiver allows current operation despite an unmet requirement.
A deferral removes the affected capability from current allowed scope.

### 11.2 Deferral_Allowed_Use

A deferral may be used for:

* phase 2 provider expansion
* partial refund automation
* settlement automation
* real-time provider lookup
* full kiosk reuse path
* mini-kiosk advanced payment path
* automated chargeback packet export
* advanced monitoring dashboard
* multi-tenant bulk rollout
* provider-specific optional feature
* franchise-wide provider expansion

### 11.3 Deferral_Prohibited_Use

A deferral must not be used to hide a required production safety control while still enabling the risky flow.

Examples:

* deferring refund safety while enabling refund automation
* deferring idempotency while enabling payment retry
* deferring audit ledger while enabling payment operation
* deferring callback validation while accepting provider callbacks
* deferring reconciliation while enabling settlement-dependent operation
* deferring customer protection status while allowing ambiguous checkout
* deferring local ledger while allowing offline financial capture

### 11.4 Deferral_Record

Every deferral must record:

* deferral_id
* provider_id
* provider_route_id
* deferred_scope
* reason
* affected_capability
* affected_operation
* current_allowed_scope
* blocked_scope
* dependency
* target_phase
* target_review_date
* owner
* approver
* related_limitation_id
* related_waiver_id
* status

## 12. Accepted_Risk_Policy

### 12.1 Accepted_Risk_Definition

Accepted risk is a formally approved condition where the organization knowingly proceeds with a risk that cannot be fully mitigated within the current phase.

Accepted risk must be rare.

Accepted risk must not be used for uncontrolled financial, privacy, security, legal, or consumer harm exposure.

### 12.2 Accepted_Risk_Requirement

Accepted risk requires:

* clear risk description
* severity classification
* affected scope
* business reason
* technical reason
* compliance review
* financial exposure estimate
* customer impact estimate
* mitigation plan
* monitoring plan
* rollback plan
* expiration or review date
* accountable owner
* approver

### 12.3 Accepted_Risk_Expiration

Accepted risk must expire or require periodic review.

Accepted risk must be re-reviewed when:

* provider changes behavior
* tenant scope expands
* store count expands
* transaction volume increases
* incident occurs
* dispute occurs
* chargeback occurs
* reconciliation mismatch occurs
* compliance requirement changes
* security finding appears
* customer harm occurs

## 13. Risk_Status_Model

Provider risks must have explicit statuses.

Required statuses include:

* `DRAFT`
* `UNDER_REVIEW`
* `OPEN`
* `MITIGATION_IN_PROGRESS`
* `WAIVER_REQUESTED`
* `WAIVER_APPROVED`
* `WAIVER_EXPIRED`
* `DEFERRED`
* `ACCEPTED_RISK`
* `BLOCKED`
* `RESOLVED`
* `CLOSED`
* `REOPENED`
* `REVERIFICATION_REQUIRED`

A risk must not move to `CLOSED` unless evidence of closure exists.

## 14. Risk_Owner_Model

Each risk must have an owner.

Owner classes include:

* technical owner
* provider liaison
* compliance owner
* security owner
* finance/reconciliation owner
* store operations owner
* tenant operations owner
* customer support owner
* legal reviewer
* business owner

High, critical, and blocking risks must not be ownerless.

## 15. Provider_Risk_Grade_Impact

Provider risk register state must affect provider route grade.

A provider route must be downgraded when:

* high risk remains open
* critical risk remains open
* waiver is required for core operation
* provider support is unreliable
* dispute evidence is incomplete
* refund/cancellation ambiguity is unresolved
* settlement mismatch is unresolved
* official status becomes weaker
* sandbox limitation affects production confidence
* incident re-verification is required
* monitoring gap remains open

A provider route must be blocked when:

* blocking risk exists
* waiver expired for required control
* accepted risk review expired
* compliance owner blocks route
* security owner blocks route
* provider prohibits intended use
* duplicate payment risk becomes uncontrolled
* financial audit evidence cannot be preserved

## 16. Risk_To_Runtime_Guardrail_Linkage

Provider risks must connect to runtime guardrails.

Examples:

* callback risk must adjust callback monitoring threshold
* refund risk must force manual review
* cancellation risk must force conservative customer status
* duplicate payment risk must block unsafe retry
* provider lookup risk must extend reconciliation workflow
* settlement risk must create finance review queue
* evidence gap risk must mark dispute packet limitation
* support risk must downgrade escalation confidence
* rate limit risk must adjust load shedding rule
* offline replay risk must restrict replay eligibility

A risk register that does not affect runtime behavior is incomplete.

## 17. Risk_To_Customer_Protection_Linkage

Provider risks must connect to customer protection.

If a limitation may affect customer experience, the risk record must define:

* customer-facing status rule
* prohibited customer message
* required support message
* refund/cancellation communication rule
* duplicate payment communication rule
* delay communication rule
* escalation condition
* compensation review condition if applicable

Known provider weakness must not be hidden from customer-safe status handling.

## 18. Risk_To_Reconciliation_Linkage

Provider risks must connect to reconciliation.

If a limitation affects financial truth, the risk record must define:

* reconciliation requirement
* reconciliation frequency
* mismatch category
* aging threshold
* owner
* escalation condition
* closure condition
* evidence packet marker

Examples:

* provider settlement file delayed
* provider lookup unavailable
* POS order id missing
* provider cancellation id missing
* refund status unavailable
* partial refund unsupported
* callback duplicated or delayed

## 19. Risk_To_Dispute_Packet_Linkage

Provider risks must connect to dispute evidence packets.

If a provider limitation affects dispute evidence, the evidence packet must mark:

* missing provider evidence
* missing POS evidence
* missing callback evidence
* missing receipt evidence
* missing settlement evidence
* manual verification dependency
* provider support dependency
* accepted risk reference
* waiver reference
* deferral reference

Dispute packet generation must not present incomplete evidence as complete evidence.

## 20. Risk_Review_Cadence

Provider risks must be reviewed periodically.

Suggested review cadence:

* blocking risk: immediate review until resolved or route blocked
* critical risk: weekly during active route use
* high risk: biweekly during pilot or monthly in production
* medium risk: monthly or before expansion
* low risk: quarterly or before re-verification
* waiver: before expiration and before scope expansion
* accepted risk: before expiration and after incident
* deferral: before target phase or roadmap checkpoint

Review cadence may be adjusted by route grade, tenant scope, provider behavior, and incident history.

## 21. Risk_Escalation

Risk escalation is required when:

* risk severity increases
* waiver expiration is approaching
* waiver expires
* accepted risk review expires
* risk affects active customers
* risk affects financial state
* risk affects refund/cancellation
* risk affects settlement
* risk affects audit evidence
* risk affects privacy or security
* risk affects legal/compliance readiness
* provider route is expanding
* provider behavior changes
* incident occurs
* dispute volume increases
* reconciliation mismatch increases

Escalation target must match risk category and severity.

## 22. Risk_Register_Data_Model_Requirements

The implementation must support the following logical records.

### 22.1 Provider_Risk_Record

Required fields:

* risk_id
* provider_id
* provider_route_id
* risk_category
* risk_title
* risk_description
* severity
* status
* owner_role
* owner_id
* discovered_at
* discovered_by
* discovery_source
* affected_environment
* affected_tenant_scope
* affected_store_scope
* affected_channel_scope
* affected_operation_scope
* customer_impact
* financial_impact
* compliance_impact
* security_impact
* mitigation_plan
* workaround
* runtime_guardrail_reference
* reconciliation_reference
* dispute_packet_reference
* review_due_at
* closed_at
* closure_evidence_reference

### 22.2 Provider_Limitation_Record

Required fields:

* limitation_id
* risk_id
* provider_id
* provider_route_id
* limitation_summary
* limitation_detail
* capability_affected
* capability_status
* provider_statement_reference
* test_result_reference
* production_observation_reference
* workaround
* blocked_scope
* allowed_scope
* status

### 22.3 Waiver_Record

Required fields:

* waiver_id
* risk_id
* limitation_id
* provider_id
* provider_route_id
* waived_requirement
* reason
* allowed_scope
* expiration
* owner
* approver
* approved_at
* customer_protection_condition
* monitoring_condition
* rollback_condition
* review_due_at
* status

### 22.4 Deferral_Record

Required fields:

* deferral_id
* risk_id
* provider_id
* provider_route_id
* deferred_scope
* deferred_capability
* blocked_scope
* target_phase
* target_review_date
* owner
* approver
* dependency
* status

### 22.5 Accepted_Risk_Record

Required fields:

* accepted_risk_id
* risk_id
* provider_id
* provider_route_id
* acceptance_reason
* accepted_scope
* severity
* financial_exposure
* customer_impact
* compliance_impact
* mitigation
* monitoring
* rollback_condition
* accepted_by
* accepted_at
* expires_at
* review_due_at
* status

## 23. Dashboard_Requirements

The provider risk dashboard must show:

* open risks by provider
* open risks by route
* open risks by severity
* open risks by tenant/store/channel scope
* waivers expiring soon
* expired waivers
* accepted risks requiring review
* deferred scope by target phase
* blocking risks
* risks linked to active incidents
* risks linked to disputes
* risks linked to reconciliation mismatches
* risks linked to provider re-verification
* provider route grade impact
* production approval impact
* rollout blocking conditions

Dashboard entries must link to source evidence where authorized.

## 24. Access_Control

Risk register access must be role-scoped.

### 24.1 Technical_Team

Technical team may view:

* technical limitations
* endpoint risks
* callback risks
* idempotency risks
* retry risks
* test results
* implementation mitigation

### 24.2 Compliance_Team

Compliance team may view:

* compliance risks
* financial audit evidence gaps
* consumer protection risks
* dispute evidence risks
* waiver and accepted risk records
* legal hold implications

### 24.3 Business_Owner

Business owner may view:

* provider grade impact
* rollout limitation
* tenant expansion risk
* commercial dependency
* accepted business risk
* blocked provider scope

### 24.4 Store_And_Tenant_Admin

Store and tenant admins may view only operationally relevant limitations.

They must not view:

* credential risks in detail
* exploit-level security notes
* cross-tenant provider risks
* internal legal review notes
* raw provider contract evidence
* sensitive incident details

## 25. Readiness_Checklist

Before a provider route may enter controlled implementation, the following checklist must pass.

### 25.1 Risk_Register

* [ ] Provider risk register exists.
* [ ] Provider route risk record exists.
* [ ] Known limitations are recorded.
* [ ] Discovery sources are recorded.
* [ ] Risk severity is assigned.
* [ ] Risk owner is assigned.
* [ ] Review due date is assigned.
* [ ] Runtime guardrail linkage exists where required.

### 25.2 Waiver

* [ ] Waiver is not used for prohibited controls.
* [ ] Waiver scope is limited.
* [ ] Waiver expiration is defined.
* [ ] Waiver approver is recorded.
* [ ] Waiver monitoring condition is defined.
* [ ] Waiver rollback condition is defined.
* [ ] Waiver does not silently approve production expansion.

### 25.3 Deferral

* [ ] Deferred scope is blocked from current operation.
* [ ] Deferral target phase is recorded.
* [ ] Deferral owner is assigned.
* [ ] Deferred capability is visible in capability matrix.
* [ ] Deferral does not hide required safety control.

### 25.4 Accepted_Risk

* [ ] Accepted risk has severity.
* [ ] Accepted risk has business reason.
* [ ] Accepted risk has compliance review where needed.
* [ ] Accepted risk has monitoring plan.
* [ ] Accepted risk has rollback condition.
* [ ] Accepted risk has expiration or review date.
* [ ] Accepted risk is not used for blocking risk.

### 25.5 Route_Grade_Impact

* [ ] Open high/critical risks affect provider grade.
* [ ] Blocking risks prevent route enablement.
* [ ] Expired waiver blocks route expansion.
* [ ] Reverification-required risk blocks production promotion.
* [ ] Risk dashboard shows rollout impact.

## 26. Non_Goals

This policy does not define:

* final legal risk acceptance language
* final commercial contract risk model
* provider pricing negotiation
* complete enterprise risk management system
* complete security vulnerability management process
* final compensation policy
* final customer support SOP
* final accounting reserve policy
* final board-level risk governance

Those must be handled by separate legal, security, finance, support, and business governance documents.

This policy defines the POS Gateway provider risk register and waiver boundary required for safe integration governance.

## 27. Acceptance_Criteria

This policy is accepted when:

* every provider route has a risk register
* every known limitation has an owner
* every high or critical risk affects route grade
* blocking risks prevent route enablement
* waivers are scope-limited and expiring
* deferrals block deferred capabilities from current use
* accepted risks require review
* runtime guardrails link to provider risks
* customer protection rules link to provider risks
* reconciliation rules link to provider risks
* dispute packets expose evidence limitations
* expired waivers cannot silently continue
* risk register entries are visible before rollout
* provider expansion cannot bypass unresolved risks

## 28. Final_Rule

A provider limitation is not dangerous because it exists.

It is dangerous when it is hidden.

The POS Gateway must make every known limitation, waiver, deferral, accepted risk, and blocking condition visible before the route can touch customer orders, payment state, cancellation, refund, settlement, or dispute evidence.
