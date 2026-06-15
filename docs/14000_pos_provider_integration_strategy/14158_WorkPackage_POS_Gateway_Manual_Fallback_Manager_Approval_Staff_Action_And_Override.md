# 14158_WorkPackage_POS_Gateway_Manual_Fallback_Manager_Approval_Staff_Action_And_Override

## 1. Purpose

This document defines the work package for POS Gateway manual fallback, manager approval, staff action, and override control.

After the gateway can resolve registry context, validate menu/price/availability, maintain transaction state, prevent duplicate mutation, use provider adapters, and bind physical identity/proof, it must support controlled human intervention.

Manual fallback is not a side path.

In real store operation, manual fallback becomes the safety net when:

- POS write result is unknown;
- payment result is unknown;
- refund/cancellation result is unknown;
- KDS ticket is missing;
- table/session identity is wrong;
- kiosk or QR object is invalid;
- provider is down;
- customer already paid but order cannot be confirmed;
- sold-out occurs after payment;
- staff must manually enter an order into POS;
- manager must approve refund, adjustment, or correction;
- an emergency override is required during outage.

This work package ensures that staff actions and overrides remain authorized, auditable, reversible where possible, and linked to transaction evidence.

---

## 2. Scope

This work package covers implementation planning for:

- manual fallback case;
- fallback trigger classification;
- staff action record;
- manual POS entry linkage;
- manual payment verification;
- manual KDS instruction;
- manual cancellation handling;
- manual refund handling;
- manual table/session correction;
- manual sold-out conflict handling;
- price adjustment request;
- manager approval request;
- approval policy binding;
- two-person control placeholder;
- emergency override record;
- override expiry and review;
- staff device trust requirement;
- role/permission check;
- evidence attachment;
- audit events;
- monitoring and tests.

This document does not implement the full Store Console UI.  
Store Console flows should move to the `06500` band.

This document defines the work package that later UI and service implementation must satisfy.

---

## 3. Core Principle

Manual fallback must be controlled like a financial system workflow.

A manual action must answer:

```text
who did it
why it was needed
what transaction it affected
what evidence existed
what system state was changed
what provider/POS/payment/KDS state was observed
who approved it
whether customer was affected
whether reconciliation is required
whether the action expires or requires review
```

Manual fallback is allowed because automation can be uncertain.

Manual fallback must not become invisible state mutation.

---

## 4. Implementation Position

This work package follows:

```text
06310_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding.md
06320_WorkPackage_POS_Gateway_Menu_Mapping_Price_Availability_And_Calculation_Snapshot.md
06330_WorkPackage_POS_Gateway_Order_Payment_Cancel_Refund_State_Machine_And_Transaction_Timeline.md
14156_WorkPackage_POS_Gateway_Idempotency_Queue_Retry_Dead_Letter_Replay_And_Duplicate_Prevention.md
06350_WorkPackage_POS_Gateway_POS_KDS_Adapter_Interface_Routing_Error_Normalization_And_Provider_Contract.md
14157_WorkPackage_POS_Gateway_Table_QR_NFC_Kiosk_Device_Receipt_Proof_And_Customer_Status.md
```

This work package precedes:

```text
14159_WorkPackage_POS_Gateway_Reconciliation_Audit_Evidence_Settlement_And_Accounting_Guard.md
14160_WorkPackage_POS_Gateway_Monitoring_Incident_Disaster_Recovery_Pilot_Readiness_And_Closeout.md
```

Manual fallback must be in place before a real pilot handles money, customers, and POS uncertainty.

---

## 5. Required Work Domains

The implementation plan must cover these domains:

```text
manual_fallback_case
fallback_trigger
manual_action_record
manual_pos_entry_link
manual_payment_verification
manual_kds_instruction
manual_cancel_action
manual_refund_action
manual_table_session_correction
manual_sold_out_resolution
price_adjustment_request
approval_policy_binding
manager_approval_request
approval_decision
two_person_control_placeholder
emergency_override_record
override_expiry_review
staff_authority_check
staff_device_trust_check
evidence_attachment
manual_recovery_resolution
```

The key requirement is that manual action becomes structured evidence, not informal staff memory.

---

## 6. Manual Fallback Case

Manual fallback case represents a controlled human-handled exception.

Required fields:

```text
manual_fallback_case_id
transaction_id
tenant_id
store_id
case_type
case_reason
severity
related_state_domain
current_transaction_state
assigned_role
assigned_actor_id
opened_at_utc
closed_at_utc
status
```

Recommended case types:

```text
pos_write_unknown
payment_unknown
cancel_unknown
refund_unknown
kds_ticket_missing
wrong_table_risk
device_identity_issue
sold_out_after_payment
manual_pos_entry_required
provider_outage
customer_dispute
price_adjustment
emergency_override
```

Manual fallback case must link to transaction timeline.

---

## 7. Fallback Trigger Classification

Fallback trigger must describe why automation could not continue safely.

Recommended trigger classes:

```text
provider_failure
timeout_after_mutation
unknown_result
capability_not_supported
blocking_limitation
configuration_conflict
identity_conflict
proof_missing
proof_conflict
customer_request
staff_detected_issue
incident_mode
manager_discretion
```

Trigger classification supports:

- monitoring;
- training;
- runbook improvement;
- provider governance;
- reconciliation;
- incident analysis.

---

## 8. Staff Action Record

Every staff action affecting a transaction must be recorded.

Required fields:

```text
staff_action_id
manual_fallback_case_id
transaction_id
tenant_id
store_id
actor_id
actor_role
device_id
action_type
action_reason
before_state_ref
after_state_ref
evidence_ref
performed_at_utc
status
```

Recommended action types:

```text
manual_pos_entry
manual_payment_check
manual_kds_instruction
manual_table_correction
manual_customer_notice
manual_cancel_request
manual_refund_request
manual_price_adjustment
manual_sold_out_resolution
manual_provider_lookup
manual_receipt_check
manual_case_close
```

Staff action must not directly mutate final transaction state without transition and audit.

---

## 9. Staff Authority Check

Before sensitive staff action, authority must be checked.

Authority check input:

```text
actor_id
tenant_id
store_id
role_code
action_type
transaction_id
amount_minor
risk_level
device_trust_state
```

Authority check output:

```text
allowed
approval_required
denial_reason
required_role
required_approval_type
```

Sensitive actions must not rely only on UI visibility.

Backend must enforce authority.

---

## 10. Staff Device Trust Check

Device trust affects sensitive action permission.

Actions requiring trusted or reauthenticated device may include:

- refund approval;
- payment verification;
- manual POS correction;
- evidence export;
- emergency override;
- forced state correction;
- manager approval.

If device trust is insufficient:

```text
require_reauthentication
block_action
route_to_manager_device
create_security_review_marker
```

Device trust result must be recorded.

---

## 11. Manual POS Entry Link

Manual POS entry must link a manually entered POS order to gateway transaction.

Required fields:

```text
manual_pos_entry_id
manual_fallback_case_id
transaction_id
actor_id
pos_provider_id
pos_order_reference
manual_entry_reason
entered_amount_minor
currency_code
entered_at_utc
verification_status
status
```

Manual POS entry must record:

- who entered it;
- why it was entered;
- whether amount matches calculation snapshot;
- whether receipt proof exists;
- whether reconciliation is required.

Manual POS entry must not create hidden duplicate POS order.

---

## 12. Manual Payment Verification

Manual payment verification represents staff-observed payment evidence.

Required fields:

```text
manual_payment_verification_id
manual_fallback_case_id
transaction_id
actor_id
verification_source
approval_number
amount_minor
currency_code
payment_route_hint
verified_at_utc
confidence_level
evidence_ref
status
```

Recommended verification sources:

```text
POS_screen
payment_terminal_slip
VAN_terminal
PG_dashboard
provider_support_confirmation
customer_bank_app_visual_check
settlement_report
```

Customer bank app visual check is weak evidence and must be classified accordingly.

Manual verification must not be treated as provider-confirmed proof unless verified through provider source.

---

## 13. Manual KDS Instruction

Manual KDS instruction is used when KDS ticket is missing, duplicated, or wrong.

Required fields:

```text
manual_kds_instruction_id
manual_fallback_case_id
transaction_id
actor_id
kitchen_station
instruction_type
line_item_refs
reason_code
issued_at_utc
acknowledged_by_actor_id
status
```

Recommended instruction types:

```text
prepare_order
hold_order
cancel_preparation
remake_item
correct_table
ignore_duplicate_ticket
manual_print
```

Manual KDS instruction must prevent duplicate cooking where possible.

---

## 14. Manual Cancellation Action

Manual cancellation action must preserve proof boundary.

Required fields:

```text
manual_cancel_action_id
manual_fallback_case_id
transaction_id
actor_id
cancel_reason
provider_cancel_reference
pos_cancel_reference
cancel_amount_minor
proof_status
approval_reference
performed_at_utc
status
```

Cancellation action must distinguish:

```text
cancel_requested
cancel_manually_verified
cancel_provider_confirmed
cancel_unknown
```

Manual cancellation cannot become confirmed without proof or approved manual evidence.

---

## 15. Manual Refund Action

Manual refund action must preserve financial control.

Required fields:

```text
manual_refund_action_id
manual_fallback_case_id
transaction_id
actor_id
refund_reason
refund_amount_minor
currency_code
partial_refund_sequence
provider_refund_reference
proof_status
approval_reference
performed_at_utc
status
```

Refund action must check:

- refundable amount;
- duplicate refund risk;
- provider capability;
- approval threshold;
- payment proof;
- prior refund state.

Manual refund requires reconciliation linkage.

---

## 16. Manual Table Session Correction

Manual table/session correction must be auditable.

Required fields:

```text
manual_table_correction_id
manual_fallback_case_id
transaction_id
actor_id
from_table_id
to_table_id
from_session_id
to_session_id
correction_reason
customer_impact_flag
performed_at_utc
status
```

Correction should create table session event and transaction timeline event.

Wrong-table correction after payment or KDS ticket may require manager approval.

---

## 17. Manual Sold-Out Resolution

Sold-out after payment must be handled carefully.

Required fields:

```text
manual_sold_out_resolution_id
manual_fallback_case_id
transaction_id
actor_id
menu_item_id
resolution_type
replacement_item_id
refund_required_flag
customer_notice_ref
approval_reference
performed_at_utc
status
```

Recommended resolution types:

```text
substitute_item
cancel_item
refund_item
refund_order
customer_wait
manager_decision_required
```

Customer communication must remain safe and evidence-linked.

---

## 18. Price Adjustment Request

Manual price adjustment is high risk.

Required fields:

```text
price_adjustment_request_id
manual_fallback_case_id
transaction_id
actor_id
adjustment_reason
original_amount_minor
adjusted_amount_minor
difference_minor
currency_code
approval_required_flag
approval_reference
created_at_utc
status
```

Price adjustment must not mutate original calculation snapshot.

It must create an adjustment record and reconciliation marker.

---

## 19. Approval Policy Binding

Approval policy binding determines which actions require approval.

Policy inputs:

```text
action_type
amount_minor
risk_level
actor_role
store_id
tenant_id
transaction_state
device_trust_state
```

Approval outputs:

```text
approval_required
required_approver_role
two_person_required
reauth_required
approval_expiry_minutes
```

Approval policy must be versioned.

---

## 20. Manager Approval Request

Manager approval request must be explicit.

Required fields:

```text
manager_approval_request_id
manual_fallback_case_id
transaction_id
requested_by_actor_id
approval_type
approval_reason
amount_minor
currency_code
required_role
requested_at_utc
expires_at_utc
status
```

Recommended approval types:

```text
refund
cancel_after_payment
manual_price_adjustment
wrong_table_correction
manual_pos_entry_after_unknown
sold_out_customer_resolution
emergency_override
case_closure_with_variance
```

Approval request does not mean approval granted.

---

## 21. Approval Decision

Approval decision records manager or authorized approver action.

Required fields:

```text
approval_decision_id
manager_approval_request_id
approver_actor_id
approver_role
decision
decision_reason
approved_scope
decided_at_utc
reauth_completed_flag
status
```

Recommended decisions:

```text
approved
rejected
expired
revoked
escalated
```

Approval must be linked to final staff action.

Unused approvals must expire.

---

## 22. Two-Person Control Placeholder

Some actions may require two-person control later.

Candidate actions:

- high-value refund;
- accounting-impacting manual adjustment;
- evidence export;
- emergency override;
- force-closing reconciliation variance;
- provider route override;
- privacy deletion exception.

Required placeholder fields:

```text
two_person_control_id
approval_request_id
first_approver_actor_id
second_approver_actor_id
required_flag
status
```

Even if MVP does not enable two-person control, schema and policy must leave room.

---

## 23. Emergency Override Record

Emergency override is used only during incident, outage, or continuity mode.

Required fields:

```text
emergency_override_id
tenant_id
store_id
transaction_id
override_type
reason_code
activated_by_actor_id
approved_by_actor_id
activated_at_utc
expires_at_utc
deactivated_at_utc
review_required_flag
status
```

Recommended override types:

```text
force_manual_mode
allow_manual_pos_entry
pause_provider_route
allow_counter_payment_only
suspend_qr_ordering
override_store_pause
force_customer_message
emergency_refund_hold
```

Emergency override must be time-bounded.

---

## 24. Override Expiry and Review

Every override must expire or require review.

Required review fields:

```text
override_review_id
emergency_override_id
reviewed_by_actor_id
review_result
continued_risk
corrective_action_ref
reviewed_at_utc
status
```

Expired override must not remain silently active.

Emergency override cannot become permanent configuration without change governance.

---

## 25. Evidence Attachment

Manual action must support evidence attachment.

Evidence types:

```text
staff_note
receipt_photo_ref
POS_screen_reference
payment_terminal_reference
provider_dashboard_reference
customer_message_reference
manager_approval_reference
reconciliation_case_reference
incident_reference
```

Evidence must be stored by reference, not as uncontrolled raw payload in action record.

Sensitive evidence must follow retention and redaction policy.

---

## 26. Manual Recovery Resolution

Manual fallback case must close with explicit resolution.

Required fields:

```text
manual_recovery_resolution_id
manual_fallback_case_id
transaction_id
resolution_type
final_state_domain
final_state
customer_impact_summary
financial_impact_summary
reconciliation_required_flag
resolved_by_actor_id
resolved_at_utc
status
```

Recommended resolution types:

```text
resolved_by_provider_lookup
resolved_by_manual_pos_entry
resolved_by_manual_payment_verification
resolved_by_refund
resolved_by_cancellation
resolved_by_customer_substitution
resolved_by_reconciliation_case
escalated_to_incident
unable_to_resolve
```

Case closure must not hide unresolved reconciliation risk.

---

## 27. Customer Communication Link

Manual fallback often requires customer communication.

Manual action must link to customer message state when:

- payment is unknown;
- refund is pending;
- cancellation is pending;
- item is sold out after payment;
- table/session issue affects order;
- provider outage affects operation;
- staff review is required.

Customer-facing message must come from approved templates or reviewed staff script.

---

## 28. Reconciliation Link

Manual fallback must create reconciliation marker when it affects:

- payment;
- refund;
- cancellation;
- receipt;
- amount;
- POS order existence;
- manual price adjustment;
- manual POS entry;
- proof conflict.

Reconciliation linkage must include:

```text
transaction_id
manual_fallback_case_id
staff_action_id
amount_minor
currency_code
reason_code
created_at_utc
```

---

## 29. Incident Link

Manual fallback must link to incident when:

- provider outage affects multiple transactions;
- payment unknown backlog exceeds threshold;
- refund/cancel unknown backlog exceeds threshold;
- wrong table risk repeats;
- kiosk device identity failure repeats;
- manual action error causes customer/financial impact;
- emergency override activated.

Incident linkage is required for pattern analysis.

---

## 30. Data Model Draft

Recommended table group:

```text
pos_gateway_manual_fallback_cases
pos_gateway_fallback_triggers
pos_gateway_staff_actions
pos_gateway_staff_authority_checks
pos_gateway_staff_device_trust_checks
pos_gateway_manual_pos_entries
pos_gateway_manual_payment_verifications
pos_gateway_manual_kds_instructions
pos_gateway_manual_cancel_actions
pos_gateway_manual_refund_actions
pos_gateway_manual_table_corrections
pos_gateway_manual_sold_out_resolutions
pos_gateway_price_adjustment_requests
pos_gateway_approval_policy_bindings
pos_gateway_manager_approval_requests
pos_gateway_approval_decisions
pos_gateway_two_person_control_placeholders
pos_gateway_emergency_overrides
pos_gateway_override_reviews
pos_gateway_manual_evidence_attachments
pos_gateway_manual_recovery_resolutions
```

The implementation may split approval into broader access-control modules later, but POS Gateway must retain transaction linkage.

---

## 31. API Requirements

Recommended internal APIs or service methods:

```text
openManualFallbackCase()
classifyFallbackTrigger()
recordStaffAction()
checkStaffAuthority()
checkDeviceTrust()
createManualPosEntry()
verifyManualPayment()
issueManualKdsInstruction()
recordManualCancelAction()
recordManualRefundAction()
correctTableSessionManually()
resolveSoldOutManually()
requestPriceAdjustment()
evaluateApprovalPolicy()
requestManagerApproval()
recordApprovalDecision()
activateEmergencyOverride()
expireEmergencyOverride()
reviewEmergencyOverride()
attachManualEvidence()
resolveManualFallbackCase()
linkManualFallbackToReconciliation()
linkManualFallbackToIncident()
```

All APIs that affect transaction state must call state transition and audit services.

---

## 32. Denial Reason Codes

Recommended denial reason codes:

```text
staff_authority_insufficient
device_trust_insufficient
approval_required
approval_expired
approval_rejected
two_person_control_required
transaction_state_invalid
manual_action_not_allowed
duplicate_manual_pos_entry_risk
duplicate_refund_risk
payment_proof_missing
refund_proof_missing
cancel_proof_missing
evidence_required
override_expired
override_not_allowed
reconciliation_required_before_closure
```

Denial reasons must be operator-safe and customer-safe only after message mapping.

---

## 33. Audit Event Requirements

Required audit events:

```text
pos_gateway.manual.case_opened
pos_gateway.manual.trigger_classified
pos_gateway.manual.staff_action_recorded
pos_gateway.manual.authority_checked
pos_gateway.manual.device_trust_checked
pos_gateway.manual.pos_entry_created
pos_gateway.manual.payment_verified
pos_gateway.manual.kds_instruction_issued
pos_gateway.manual.cancel_action_recorded
pos_gateway.manual.refund_action_recorded
pos_gateway.manual.table_correction_recorded
pos_gateway.manual.sold_out_resolution_recorded
pos_gateway.manual.price_adjustment_requested
pos_gateway.manual.approval_requested
pos_gateway.manual.approval_decided
pos_gateway.manual.emergency_override_activated
pos_gateway.manual.emergency_override_expired
pos_gateway.manual.override_review_completed
pos_gateway.manual.evidence_attached
pos_gateway.manual.case_resolved
```

Audit must include:

```text
tenant_id
store_id
transaction_id
manual_fallback_case_id
staff_action_id
actor_id
approver_actor_id
created_at_utc
correlation_id
```

---

## 34. Monitoring Requirements

Monitoring must detect:

- manual fallback case count;
- fallback case aging;
- payment unknown manual review backlog;
- refund manual review backlog;
- manual POS entry count;
- manual price adjustment count;
- manager approval pending count;
- approval expiration count;
- emergency override active count;
- expired override still active;
- manual action denied count;
- duplicate manual action risk;
- reconciliation-required case not linked;
- staff/device trust failure count.

Monitoring must be scoped by tenant, store, staff role, provider, channel, and case type.

---

## 35. Alert Requirements

Critical alerts:

```text
payment_unknown_manual_review_backlog_high
refund_manual_review_backlog_high
manual_pos_entry_spike
manager_approval_backlog_high
emergency_override_active_too_long
expired_override_still_active
manual_refund_without_proof_attempt
manual_price_adjustment_spike
reconciliation_required_case_closed_attempt
device_trust_failure_for_sensitive_action
```

Alerts must link to staff runbook and incident workflow.

---

## 36. Test Requirements

Required tests:

```text
manual_fallback_case_open_test
fallback_trigger_classification_test
staff_authority_check_test
device_trust_check_test
manual_pos_entry_linkage_test
manual_payment_verification_confidence_test
manual_kds_instruction_test
manual_cancel_action_requires_proof_test
manual_refund_action_requires_approval_test
manual_table_correction_audit_test
sold_out_resolution_customer_notice_test
price_adjustment_does_not_mutate_snapshot_test
manager_approval_request_decision_test
approval_expiry_test
emergency_override_expiry_test
override_review_required_test
manual_evidence_attachment_test
manual_case_closure_reconciliation_required_test
```

Manual fallback tests are required before real store pilot.

---

## 37. Acceptance Criteria

This work package is acceptable only when:

- manual fallback case exists;
- fallback trigger classification exists;
- staff action record exists;
- staff authority check exists;
- staff device trust check exists;
- manual POS entry linkage exists;
- manual payment verification exists;
- manual KDS instruction exists;
- manual cancel/refund action models exist;
- manual table/session correction exists;
- manual sold-out resolution exists;
- price adjustment request exists;
- approval policy binding exists;
- manager approval request and decision exist;
- two-person control placeholder exists;
- emergency override record exists;
- override expiry and review exist;
- evidence attachment exists;
- manual recovery resolution exists;
- customer communication, reconciliation, and incident links exist;
- APIs, denial codes, audit events, monitoring, alerts, and tests exist.

---

## 38. Relationship To Adjacent Documents

This document is related to:

- 06360 WorkPackage POS Gateway table, QR, NFC, kiosk device, receipt proof, and customer status;
- 06350 WorkPackage POS Gateway POS/KDS adapter interface, routing, error normalization, and provider contract;
- 06340 WorkPackage POS Gateway idempotency, queue, retry, dead-letter, replay, and duplicate prevention;
- 06330 WorkPackage POS Gateway order, payment, cancel, refund state machine, and transaction timeline;
- 06100 Policy POS Gateway staff operation, manual fallback, override authority, and manager approval;
- 06110 Policy POS Gateway customer status message, receipt proof, notification, and dispute communication;
- 06120 Policy POS Gateway reconciliation case workflow, variance resolution, manual adjustment, and audit closure;
- 06140 Policy POS Gateway access control, role segregation, tenant isolation, privileged action, and approval audit.

Where conflict exists, this document governs implementation work planning for manual fallback, manager approval, staff action, and override control in POS Gateway operations.

---

## 39. Summary

Manual fallback is not a weakness.

It is the safety mechanism that keeps the store operating when automation is uncertain.

But uncontrolled manual action can create duplicate POS orders, false refunds, wrong table corrections, missing evidence, and financial variance.

The correct implementation standard is:

- open a manual fallback case;
- classify the trigger;
- check staff authority;
- check device trust;
- record every manual action;
- require manager approval for sensitive actions;
- preserve proof and evidence;
- link to customer communication;
- link to reconciliation;
- expire emergency overrides;
- audit the whole path.

A staff member may fix the situation.  
The system must remember exactly how.