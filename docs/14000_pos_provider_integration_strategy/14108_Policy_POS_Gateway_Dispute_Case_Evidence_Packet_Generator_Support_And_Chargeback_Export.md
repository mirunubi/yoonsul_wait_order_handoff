# 14108_Policy_POS_Gateway_Dispute_Case_Evidence_Packet_Generator_Support_And_Chargeback_Export

## 1. Purpose

This document defines the POS Gateway dispute case, evidence packet generator, support case linkage, customer dispute handling, chargeback export, and evidence delivery policy.

The POS Gateway must not resolve payment, POS, cancellation, refund, duplicate payment, settlement, or customer dispute cases through unstructured support notes, screenshots, staff memory, provider dashboard guesses, or ad hoc manual exports.

The purpose of this policy is to ensure that every customer-impacting or finance-impacting dispute can be converted into a structured evidence packet that includes internal events, provider evidence, POS evidence, reconciliation evidence, customer notification history, staff action history, manual recovery records, and final decision records.

## 2. Scope

This policy applies to disputes and evidence packets involving:

* payment approved but order unconfirmed
* order confirmed but payment unknown
* payment failed claim
* payment unknown claim
* duplicate payment suspicion
* duplicate payment confirmed
* POS order mismatch
* POS accepted but provider payment missing
* provider payment approved but POS order missing
* cancellation requested but not completed
* cancellation completed but customer claims unresolved
* refund requested but not completed
* refund completed but customer claims not received
* partial refund mismatch
* settlement mismatch
* chargeback notice
* card-company dispute
* VAN/PG provider inquiry
* customer support complaint
* tenant support complaint
* store manual recovery dispute
* local replay conflict
* customer notification dispute
* staff action dispute
* provider evidence gap
* POS evidence gap

This policy applies before support-facing dispute tooling, evidence packet export, chargeback response workflow, or finance/compliance dispute review is implemented.

## 3. Relationship_To_Previous_Documents

This document follows:

* `14106_Policy_POS_Gateway_Reconciliation_Case_Settlement_Matching_Provider_POS_And_Internal_Ledger.md`

It also implements the evidence requirements defined in:

* `14071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md`
* `05640_POS_Gateway_Compliance_Financial_Audit_Regulatory_And_Consumer_Protection_Readiness_Policy.md`
* `14096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry.md`
* `14098_Policy_POS_Gateway_State_Machine_Payment_POS_Cancellation_Refund_And_Customer_Status.md`
* `14104_Policy_POS_Gateway_Callback_Webhook_Provider_Lookup_And_Async_State_Reconciliation.md`

The rule is:

> A dispute case must be resolved from evidence, not from opinion.

## 4. Core_Principle

The POS Gateway must convert every dispute into a structured evidence case.

A dispute evidence packet must answer:

* what the customer did
* what the customer saw
* what the store saw
* what the POS received
* what the provider reported
* what the gateway recorded
* what callbacks or lookups arrived
* what staff actions occurred
* what customer notifications were sent
* what refund or cancellation actions occurred
* what reconciliation found
* what evidence is missing
* what decision was made
* who approved the decision
* what customer-facing action followed

If the packet cannot answer these questions, it must explicitly mark the missing evidence.

## 5. Dispute_Case_Categories

The POS Gateway must support standardized dispute case categories.

Required categories include:

* `PAYMENT_APPROVED_ORDER_UNCONFIRMED`
* `ORDER_CONFIRMED_PAYMENT_UNKNOWN`
* `CUSTOMER_PAID_STORE_DID_NOT_RECEIVE`
* `STORE_RECEIVED_CUSTOMER_PAYMENT_UNKNOWN`
* `PAYMENT_FAILED_CUSTOMER_CLAIMS_CHARGED`
* `DUPLICATE_PAYMENT_SUSPECTED`
* `DUPLICATE_PAYMENT_CONFIRMED`
* `DUPLICATE_PAYMENT_DISMISSED`
* `POS_ORDER_MISSING`
* `POS_PROVIDER_MISMATCH`
* `CANCEL_REQUEST_NOT_COMPLETED`
* `CANCEL_COMPLETED_CUSTOMER_DISPUTES`
* `REFUND_REQUEST_NOT_COMPLETED`
* `REFUND_COMPLETED_CUSTOMER_DISPUTES`
* `PARTIAL_REFUND_AMOUNT_DISPUTED`
* `SETTLEMENT_AMOUNT_DISPUTED`
* `CHARGEBACK_NOTICE_RECEIVED`
* `CARD_COMPANY_EVIDENCE_REQUEST`
* `CUSTOMER_NOTIFICATION_DISPUTED`
* `MANUAL_RECOVERY_DISPUTED`
* `LOCAL_REPLAY_DISPUTED`
* `PROVIDER_EVIDENCE_MISSING`
* `POS_EVIDENCE_MISSING`

Each category must define required evidence, owner role, SLA, customer-protection posture, and closure rule.

## 6. Dispute_Case_Lifecycle

Dispute cases must support the following lifecycle states:

* `DISPUTE_NOT_OPENED`
* `DISPUTE_OPENED`
* `EVIDENCE_GATHERING`
* `EVIDENCE_PACKET_GENERATING`
* `EVIDENCE_PACKET_READY`
* `MISSING_EVIDENCE_REVIEW`
* `SUPPORT_REVIEW_PENDING`
* `FINANCE_REVIEW_PENDING`
* `COMPLIANCE_REVIEW_PENDING`
* `PROVIDER_ESCALATION_PENDING`
* `STORE_REVIEW_PENDING`
* `CUSTOMER_RESPONSE_PENDING`
* `CHARGEBACK_RESPONSE_PENDING`
* `DECISION_PENDING`
* `RESOLVED_CUSTOMER_REFUNDED`
* `RESOLVED_CUSTOMER_NOTIFIED`
* `RESOLVED_NO_ACTION_REQUIRED`
* `RESOLVED_PROVIDER_ERROR`
* `RESOLVED_POS_ERROR`
* `RESOLVED_INTERNAL_ERROR`
* `RESOLVED_STORE_MANUAL_ERROR`
* `UNRESOLVED`
* `LEGAL_HOLD`
* `CLOSED`
* `REOPENED`

A dispute case must not be closed without a closure reason and evidence reference.

## 7. Dispute_Case_Creation_Triggers

A dispute case may be created by:

* customer support complaint
* store staff report
* store manager escalation
* tenant admin escalation
* HQ support review
* finance reconciliation mismatch
* compliance review
* payment unknown aging
* POS unknown aging
* cancellation unknown aging
* refund unknown aging
* duplicate payment detection
* provider callback conflict
* provider lookup conflict
* settlement mismatch
* local replay conflict
* manual recovery conflict
* chargeback notice
* card-company evidence request
* provider inquiry

System-created dispute cases must be linked to their triggering event.

## 8. Evidence_Packet_Generator

### 8.1 Generator_Purpose

The evidence packet generator must collect, normalize, redact, package, version, and export evidence for a dispute case.

The generator must not alter source evidence.

### 8.2 Generator_Input

Required generator input includes:

* dispute_case_id
* evidence_packet_type
* redaction_profile
* requested_by
* request_reason
* export_intent
* target_audience
* related_order_id
* related_payment_attempt_id
* related_pos_submission_id
* related_cancellation_action_id
* related_refund_action_id
* related_reconciliation_case_id
* related_chargeback_case_id

### 8.3 Generator_Output

Required generator output includes:

* evidence_packet_id
* packet_version
* packet_status
* generated_at
* generated_by
* redaction_profile
* evidence_source_summary
* missing_evidence_flags
* timeline_summary
* event_ledger_extract
* provider_evidence_summary
* POS_evidence_summary
* reconciliation_summary
* customer_notification_summary
* staff_action_summary
* manual_recovery_summary
* refund_cancellation_summary
* decision_summary
* export_hash
* access_log_reference

## 9. Evidence_Packet_Sections

Each evidence packet must support the following sections.

### 9.1 Packet_Header

Required fields:

* evidence_packet_id
* packet_type
* packet_version
* dispute_case_id
* tenant_id
* store_id
* provider_id
* provider_route_id
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* reconciliation_case_id
* chargeback_case_id
* generated_at
* generated_by
* redaction_profile
* packet_status

### 9.2 Executive_Summary

Required fields:

* dispute_category
* current_case_status
* customer_impact
* financial_impact
* disputed_amount
* current_payment_state
* current_POS_state
* current_cancellation_state
* current_refund_state
* current_reconciliation_state
* recommended_action
* unresolved_gaps
* owner_role
* due_at

### 9.3 Timeline

The packet must include a normalized timeline covering:

* customer order creation
* payment request
* provider response
* callback arrival
* provider lookup
* POS submission
* POS response
* cancellation request
* refund request
* customer notification
* staff action
* manual recovery
* reconciliation run
* dispute creation
* evidence packet generation
* decision and closure

### 9.4 Internal_Event_Ledger_Extract

The packet must include relevant append-only events.

Events must be ordered by event sequence or recorded timestamp and include:

* event type
* state before
* state after
* actor
* reason code
* correlation id
* idempotency key
* provider route
* evidence reference
* timestamp

### 9.5 Provider_Evidence

Provider evidence must include:

* provider name
* provider route
* provider transaction reference
* provider approval status
* provider cancellation status
* provider refund status
* provider lookup result
* provider callback records
* provider error class
* provider timestamp
* provider evidence limitations
* missing provider evidence flags

### 9.6 POS_Evidence

POS evidence must include:

* POS provider name
* POS route
* POS order reference
* POS submission state
* POS acceptance state
* POS cancellation state
* POS lookup result if available
* manual POS entry reference if used
* receipt reference if available
* missing POS evidence flags

### 9.7 Reconciliation_Evidence

Reconciliation evidence must include:

* reconciliation case id
* reconciliation result class
* matched sources
* mismatched sources
* amount comparison
* status comparison
* timing comparison
* unresolved items
* finance review result
* closure status
* owner decision

### 9.8 Customer_Notification_Evidence

Customer notification evidence must include:

* notification id
* notification type
* message template id
* message template version
* language
* channel
* send timestamp
* delivery result
* failure result
* customer-visible status at the time
* later correction if any

### 9.9 Staff_Action_Evidence

Staff action evidence must include:

* staff actor reference
* role
* action type
* action timestamp
* allowed or blocked action status
* manual note
* evidence attachment
* manager approval
* HQ approval if required
* before state
* after state

### 9.10 Refund_And_Cancellation_Evidence

Refund and cancellation evidence must include:

* cancellation request
* cancellation state
* cancellation provider evidence
* cancellation POS evidence
* refund request
* refund state
* refund provider evidence
* partial refund details
* refund amount
* unresolved refund/cancellation mismatch
* customer notification relationship

### 9.11 Missing_Evidence_Section

The packet must explicitly list missing evidence.

Required missing evidence flags include:

* `MISSING_PROVIDER_APPROVAL`
* `MISSING_PROVIDER_FAILURE`
* `MISSING_PROVIDER_CALLBACK`
* `MISSING_PROVIDER_LOOKUP`
* `MISSING_PROVIDER_CANCEL`
* `MISSING_PROVIDER_REFUND`
* `MISSING_POS_ACCEPTANCE`
* `MISSING_POS_REJECTION`
* `MISSING_POS_CANCEL`
* `MISSING_RECEIPT`
* `MISSING_SETTLEMENT_RECORD`
* `MISSING_CUSTOMER_NOTIFICATION`
* `MISSING_STAFF_ACTION`
* `MISSING_MANUAL_RECOVERY_APPROVAL`
* `MISSING_RECONCILIATION_RESULT`
* `MISSING_CHARGEBACK_NOTICE`

Missing evidence must not be hidden from support, finance, compliance, or legal review.

### 9.12 Decision_And_Closure_Section

Decision section must include:

* decision status
* decision owner
* decision timestamp
* decision reason code
* customer action
* refund action
* cancellation action
* provider escalation action
* finance action
* compliance action
* final customer message
* closure evidence
* reopen condition

## 10. Packet_Types

Required packet types include:

* `CUSTOMER_SUPPORT_PACKET`
* `STORE_MANAGER_PACKET`
* `TENANT_ADMIN_SUMMARY_PACKET`
* `HQ_SUPPORT_PACKET`
* `FINANCE_RECONCILIATION_PACKET`
* `COMPLIANCE_REVIEW_PACKET`
* `PROVIDER_ESCALATION_PACKET`
* `CHARGEBACK_RESPONSE_PACKET`
* `LEGAL_HOLD_PACKET`
* `AUDIT_EXPORT_PACKET`

Each packet type must define required sections, redaction profile, and allowed audience.

## 11. Redaction_Profile_Policy

Evidence packets must apply redaction profiles.

Required redaction profiles include:

* `STORE_STAFF_REDACTED`
* `STORE_MANAGER_REDACTED`
* `TENANT_ADMIN_REDACTED`
* `HQ_SUPPORT_MASKED`
* `HQ_SUPPORT_ELEVATED`
* `FINANCE_REVIEW`
* `COMPLIANCE_REVIEW`
* `PROVIDER_ESCALATION_REDACTED`
* `CHARGEBACK_EXPORT`
* `LEGAL_EXPORT`
* `AUDIT_EXPORT`
* `DEVELOPER_DIAGNOSTIC_MASKED`

Redaction must protect:

* customer personal information
* payment tokens
* raw provider payload
* credentials
* staff personal identifiers where not required
* unrelated tenant/store data
* internal security notes
* legal privileged notes where applicable

## 12. Support_Case_Linkage

Dispute cases may link to customer support cases.

Support linkage must include:

* support_case_id
* dispute_case_id
* customer_reference
* support_channel
* opened_at
* opened_by
* support_status
* customer_claim_summary
* evidence_packet_id
* support_response_template_id
* final_response_sent_at
* closure_status

Support notes must not replace evidence.

## 13. Chargeback_Case_Policy

### 13.1 Chargeback_Intake

Chargeback notice must create or link to:

* chargeback_case_id
* dispute_case_id
* payment_attempt_id
* provider_reference
* card_company_reference
* notice_received_at
* response_due_at
* disputed_amount
* dispute_reason
* evidence_packet_id
* owner
* status

### 13.2 Chargeback_Response_Packet

Chargeback response packet must include:

* payment authorization evidence
* order acceptance evidence
* fulfillment evidence where available
* customer notification evidence
* cancellation/refund history
* POS evidence
* provider evidence
* reconciliation evidence
* support history
* final response recommendation

### 13.3 Chargeback_Response_Status

Required statuses include:

* `CHARGEBACK_NOTICE_RECEIVED`
* `EVIDENCE_GATHERING`
* `PACKET_READY`
* `RESPONSE_DRAFTED`
* `RESPONSE_APPROVED`
* `RESPONSE_SUBMITTED`
* `PROVIDER_REVIEW_PENDING`
* `WON`
* `LOST`
* `PARTIAL_LOSS`
* `WITHDRAWN`
* `EXPIRED`
* `LEGAL_REVIEW_REQUIRED`

### 13.4 Deadline_Control

Chargeback case must track deadlines.

Escalation must occur when:

* response due date approaches
* evidence packet missing
* required evidence missing
* provider response pending
* legal review pending
* response submission failed

## 14. Evidence_Export_Policy

Evidence packet export must be controlled.

Export must record:

* export_id
* evidence_packet_id
* packet_version
* exported_by
* exported_at
* export_reason
* export_target
* redaction_profile
* export_format
* export_hash
* access_scope
* retention_requirement
* legal_hold_status

Export must not expose raw provider secrets or unrelated customer data.

## 15. Packet_Versioning

Evidence packets must be versioned.

A new packet version must be created when:

* new provider evidence arrives
* new POS evidence arrives
* reconciliation result changes
* refund/cancellation state changes
* dispute decision changes
* redaction profile changes
* chargeback response is revised
* legal hold is applied
* correction event is created

Old packet versions must remain accessible to authorized roles.

## 16. Packet_Integrity

Evidence packet integrity must be protected.

Required controls include:

* source event references
* export hash
* packet version
* generated timestamp
* generator identity
* redaction profile
* access log
* immutable export log
* missing evidence markers
* correction history

The packet must not be silently edited after export.

## 17. Provider_Escalation_Packet

Provider escalation packet must include:

* provider route
* issue summary
* affected transaction references
* provider reference
* callback evidence
* lookup evidence
* request/response hashes
* error classes
* timeline
* customer impact
* financial exposure
* requested provider action
* due date

Provider escalation packet must be redacted to avoid exposing unrelated customer or internal security data.

## 18. Legal_Hold_Policy

A dispute case or evidence packet must support legal hold.

Legal hold must block:

* evidence deletion
* packet deletion
* export log deletion
* source event deletion
* related reconciliation closure without review
* retention cleanup
* redaction changes that destroy required evidence

Legal hold must record:

* legal_hold_id
* reason
* applied_by
* applied_at
* affected_scope
* review_due_at
* released_by
* released_at
* status

## 19. Evidence_Packet_Data_Model_Requirements

The implementation must support the following logical records.

### 19.1 Dispute_Case

Required fields:

* dispute_case_id
* dispute_category
* tenant_id
* store_id
* provider_id
* provider_route_id
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* reconciliation_case_id
* chargeback_case_id
* customer_reference
* disputed_amount
* currency
* severity
* status
* owner_role
* owner_id
* opened_at
* due_at
* resolved_at
* closure_reason
* closure_evidence_packet_id

### 19.2 Evidence_Packet

Required fields:

* evidence_packet_id
* dispute_case_id
* packet_type
* packet_version
* redaction_profile
* generated_by
* generated_at
* packet_status
* evidence_source_summary
* missing_evidence_flags
* export_hash
* access_scope
* legal_hold_status
* status

### 19.3 Evidence_Packet_Section

Required fields:

* evidence_packet_section_id
* evidence_packet_id
* section_type
* section_version
* source_reference
* redaction_status
* generated_at
* status

### 19.4 Evidence_Export_Record

Required fields:

* evidence_export_id
* evidence_packet_id
* packet_version
* exported_by
* exported_at
* export_reason
* export_target
* export_format
* redaction_profile
* export_hash
* retention_requirement
* access_scope
* status

### 19.5 Chargeback_Case

Required fields:

* chargeback_case_id
* dispute_case_id
* payment_attempt_id
* provider_reference
* card_company_reference
* notice_received_at
* response_due_at
* disputed_amount
* dispute_reason
* evidence_packet_id
* response_status
* submitted_at
* result_status
* result_at
* owner_role
* owner_id
* status

### 19.6 Legal_Hold_Record

Required fields:

* legal_hold_id
* target_entity_type
* target_entity_id
* reason
* applied_by
* applied_at
* affected_scope
* review_due_at
* released_by
* released_at
* status

## 20. Access_Control

Evidence packet access must be role-scoped.

### 20.1 Store_Staff

Store staff may view only:

* operational summary
* customer-safe response guidance
* allowed action
* blocked action
* escalation status

Store staff must not view full evidence packet.

### 20.2 Store_Manager

Store manager may view:

* store-scoped dispute summary
* staff action evidence
* store operation timeline
* store-level customer response guidance

Store manager must not view raw provider payloads or cross-store evidence.

### 20.3 Tenant_Admin

Tenant admin may view:

* tenant-scoped dispute summary
* store-level dispute counts
* refund/cancellation aging summary
* masked evidence summary
* tenant communication status

Tenant admin must not access cross-tenant packet evidence.

### 20.4 HQ_Support

HQ support may view:

* support packet
* customer notification evidence
* masked provider summary
* masked POS evidence
* runbook guidance
* support response template

Elevated access may be required for sensitive evidence.

### 20.5 HQ_Finance

HQ finance may view:

* finance reconciliation packet
* settlement evidence
* refund/cancellation financial evidence
* amount mismatch evidence
* chargeback financial packet

### 20.6 HQ_Compliance

HQ compliance may view:

* compliance review packet
* full audit trail where authorized
* legal hold status
* export history
* missing evidence flags
* manual override evidence

### 20.7 Developer

Developer access to production dispute packets must be prohibited by default.

Diagnostic access must be masked, ticket-linked, time-limited, and logged.

## 21. Observability_Requirements

The system must monitor:

* dispute case count
* open dispute case count
* dispute aging
* evidence packet generation count
* evidence packet generation failure count
* missing evidence flag count
* chargeback case count
* chargeback deadline risk count
* packet export count
* legal hold count
* unresolved provider evidence gap count
* unresolved POS evidence gap count
* support response pending count
* dispute reopened count

Metrics must be tagged by:

* provider_id
* provider_route_id
* tenant_id
* store_id
* dispute_category
* packet_type
* severity

## 22. Test_Requirements

The implementation must support tests for:

* dispute case creation from payment unknown
* dispute case creation from refund unknown
* dispute case creation from duplicate payment suspicion
* evidence packet includes event ledger extract
* evidence packet includes provider evidence where available
* evidence packet includes POS evidence where available
* evidence packet includes reconciliation evidence
* evidence packet marks missing provider evidence
* evidence packet marks missing POS evidence
* redaction profile hides sensitive fields
* packet export creates export record
* packet version changes when new evidence arrives
* chargeback case tracks response deadline
* legal hold blocks evidence deletion
* store staff cannot access full packet
* developer cannot access unmasked packet without break-glass

## 23. Readiness_Checklist

Before dispute packet generation, support case linkage, or chargeback export enters controlled implementation, the following checklist must pass.

### 23.1 Dispute_Case

* [ ] Dispute categories are defined.
* [ ] Dispute lifecycle is defined.
* [ ] Creation triggers are defined.
* [ ] Closure requires evidence.
* [ ] Owner and due date are required.
* [ ] Customer impact and financial impact are recorded.

### 23.2 Evidence_Packet

* [ ] Packet generator input is defined.
* [ ] Packet generator output is defined.
* [ ] Packet sections are defined.
* [ ] Missing evidence flags are defined.
* [ ] Packet types are defined.
* [ ] Packet versioning is defined.
* [ ] Packet integrity controls are defined.

### 23.3 Support_And_Chargeback

* [ ] Support case linkage is defined.
* [ ] Chargeback intake is defined.
* [ ] Chargeback response packet is defined.
* [ ] Chargeback deadline control is defined.
* [ ] Provider escalation packet is defined.
* [ ] Evidence export policy is defined.

### 23.4 Security_And_Control

* [ ] Redaction profiles are defined.
* [ ] Legal hold policy is defined.
* [ ] Access control is defined.
* [ ] Export logging is defined.
* [ ] Observability metrics are defined.
* [ ] Tests are defined.

## 24. Non_Goals

This policy does not define:

* final customer support UI
* final evidence packet PDF design
* final chargeback provider submission format
* final legal response template
* final compensation policy
* final accounting correction process
* final OCR or attachment parsing implementation
* final customer service script content

Those must be handled by support, legal, finance, UI, provider-specific, and implementation documents.

This policy defines the dispute evidence packet and chargeback export control boundary required before support-grade dispute handling.

## 25. Acceptance_Criteria

This policy is accepted when:

* dispute case categories are defined
* dispute case lifecycle is defined
* evidence packet generator is defined
* packet sections are defined
* missing evidence flags are explicit
* redaction profiles are defined
* support case linkage is defined
* chargeback case model is defined
* chargeback deadline control exists
* evidence export is logged
* packet versioning exists
* packet integrity controls exist
* legal hold blocks deletion
* store/tenant access is redacted
* HQ finance and compliance can access required evidence
* developer access is controlled
* dispute closure requires evidence packet reference
* chargeback response can be generated from structured evidence

## 26. Final_Rule

A dispute is not solved because someone wrote an explanation.

A dispute is solved only when the system can show what happened, what evidence exists, what evidence is missing, what decision was made, who approved it, and what action was taken for the customer.

If the POS Gateway cannot generate that packet, the dispute is not ready to close.
