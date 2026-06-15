# 14159_WorkPackage_POS_Gateway_Reconciliation_Audit_Evidence_Settlement_And_Accounting_Guard

## 1. Purpose

This document defines the work package for POS Gateway reconciliation, audit evidence, settlement linkage, and accounting guard control.

After the gateway can resolve registry context, validate sellable items, maintain transaction state, prevent duplicate mutation, call provider adapters, bind proof, and support manual fallback, it must be able to prove financial and operational truth.

The POS Gateway must not assume that a transaction is correct merely because one system says so.

A transaction may require reconciliation when:

- POS order exists but payment is missing;
- payment exists but POS order is missing;
- gateway amount differs from POS receipt;
- refund was requested but provider proof is missing;
- cancellation state differs between gateway and POS;
- manual POS entry was performed;
- manual refund was performed;
- receipt proof is missing;
- settlement report differs from gateway transaction;
- customer dispute claims a different outcome;
- provider webhook arrives late;
- accounting export would include unresolved variance.

This work package creates the reconciliation and evidence guard layer required before settlement, accounting export, and scalable franchise operation.

---

## 2. Scope

This work package covers implementation planning for:

- reconciliation marker intake;
- reconciliation case;
- variance classification;
- transaction matching;
- amount matching;
- POS/payment/receipt matching;
- cancellation/refund matching;
- manual fallback linkage;
- proof conflict linkage;
- provider settlement reference;
- settlement import reference;
- accounting export guard;
- known variance approval;
- manual adjustment record;
- audit evidence envelope;
- immutable evidence reference;
- redaction-aware evidence pointer;
- evidence access log;
- reconciliation closure;
- reopen rules;
- monitoring and tests.

This document does not implement the full Reconciliation Console UI.  
Reconciliation Console workflows should move to the `06600` band.

This document defines the work package that later reconciliation, finance, accounting, support, and audit tools must satisfy.

---

## 3. Core Principle

Reconciliation is not bookkeeping after the fact.

It is the control layer that prevents uncertain transaction state from becoming financial truth.

The gateway must enforce:

```text
no unresolved financial variance silently closes
no accounting export without guard check
no refund/cancel closure without proof or approved manual evidence
no manual adjustment without reason and approval
no evidence mutation without audit
no customer dispute closure without transaction proof review
```

Reconciliation must preserve source truth and add corrective records.  
It must never overwrite history to make numbers look clean.

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
14158_WorkPackage_POS_Gateway_Manual_Fallback_Manager_Approval_Staff_Action_And_Override.md
```

This work package precedes:

```text
14160_WorkPackage_POS_Gateway_Monitoring_Incident_Disaster_Recovery_Pilot_Readiness_And_Closeout.md
06600_Index_POS_Gateway_Reconciliation_Console_Workflow_And_Finance_Support_UI.md
```

Reconciliation and accounting guard must exist before real money flows scale beyond pilot.

---

## 5. Required Work Domains

The implementation plan must cover these domains:

```text
reconciliation_marker
reconciliation_case
variance_classification
transaction_match_candidate
amount_match_result
pos_payment_match_result
receipt_match_result
cancel_refund_match_result
manual_fallback_link
proof_conflict_link
provider_settlement_reference
settlement_import_reference
accounting_export_guard
known_variance_approval
manual_adjustment_record
audit_evidence_envelope
immutable_evidence_reference
redaction_evidence_pointer
evidence_access_log
reconciliation_closure
reconciliation_reopen_record
```

The key requirement is that every financial or proof variance becomes reviewable and auditable.

---

## 6. Reconciliation Marker Intake

Reconciliation marker is created by upstream transaction, proof, manual fallback, queue, adapter, or customer-support flows.

Required fields:

```text
reconciliation_marker_id
transaction_id
tenant_id
store_id
marker_type
reason_code
state_domain
amount_minor
currency_code
provider_id
external_reference_id
source_module
source_reference_id
created_at_utc
status
```

Recommended marker types:

```text
payment_unknown
pos_write_unknown
receipt_missing
amount_mismatch
refund_unknown
cancel_unknown
manual_pos_entry
manual_refund
manual_price_adjustment
proof_conflict
settlement_mismatch
customer_dispute
accounting_export_blocker
```

Markers should be converted into reconciliation cases by rule or review.

---

## 7. Reconciliation Case

Reconciliation case is the primary review unit.

Required fields:

```text
reconciliation_case_id
transaction_id
tenant_id
store_id
case_type
severity
case_status
opened_from_marker_id
assigned_role
assigned_actor_id
opened_at_utc
closed_at_utc
reopened_at_utc
status
```

Recommended case statuses:

```text
open
triage
evidence_collecting
matching
provider_escalation
manual_adjustment_pending
approval_required
resolved
closed
reopened
blocked
```

A reconciliation case must not be closed without closure reason and evidence summary.

---

## 8. Variance Classification

Variance classification must describe what does not match.

Recommended variance classes:

```text
amount_variance
payment_state_variance
pos_order_existence_variance
receipt_variance
cancel_state_variance
refund_state_variance
manual_action_variance
settlement_variance
business_date_variance
currency_variance
tax_component_variance
tip_component_variance
provider_reference_variance
customer_dispute_variance
evidence_missing
```

Classification supports reporting, provider escalation, root-cause review, and continuous improvement.

---

## 9. Transaction Match Candidate

Transaction matching must compare gateway, POS, payment, receipt, and provider records.

Required fields:

```text
match_candidate_id
reconciliation_case_id
transaction_id
source_system
source_reference
candidate_reference
match_score
match_reason
amount_minor
currency_code
business_date_local
created_at_utc
status
```

Match score must not automatically close high-risk cases unless policy permits.

Low-confidence match requires human review.

---

## 10. Amount Match Result

Amount matching must compare calculation snapshot, payment proof, receipt proof, refund proof, and settlement records.

Required fields:

```text
amount_match_result_id
reconciliation_case_id
transaction_id
calculation_amount_minor
payment_amount_minor
receipt_amount_minor
refund_amount_minor
settlement_amount_minor
currency_code
difference_minor
match_status
created_at_utc
status
```

Recommended match statuses:

```text
matched
minor_rounding_difference
known_provider_adjustment
mismatch
missing_reference
manual_review_required
```

Amount variance must not be hidden by overwriting one side.

---

## 11. POS / Payment Match Result

POS/payment match must determine whether POS order and payment record describe the same business transaction.

Required fields:

```text
pos_payment_match_result_id
reconciliation_case_id
transaction_id
pos_order_reference
payment_reference
receipt_reference
approval_number
amount_match_status
business_date_match_status
match_confidence
created_at_utc
status
```

Mismatch may indicate:

- paid but not ordered;
- ordered but not paid;
- duplicate POS entry;
- duplicate payment;
- wrong receipt binding;
- wrong terminal route.

---

## 12. Receipt Match Result

Receipt matching must compare receipt proof with transaction state and payment proof.

Required fields:

```text
receipt_match_result_id
reconciliation_case_id
transaction_id
receipt_proof_id
receipt_amount_minor
payment_amount_minor
calculation_amount_minor
receipt_business_date_local
match_status
created_at_utc
status
```

Receipt missing may remain pending if provider lookup is delayed, but it must not be ignored.

---

## 13. Cancellation and Refund Match Result

Cancel/refund matching must compare requested, provider-confirmed, manually verified, and settlement-visible states.

Required fields:

```text
cancel_refund_match_result_id
reconciliation_case_id
transaction_id
cancel_state
refund_state
cancel_proof_id
refund_proof_id
requested_amount_minor
confirmed_amount_minor
settlement_amount_minor
match_status
created_at_utc
status
```

Refund and cancellation mismatch must trigger financial review.

---

## 14. Manual Fallback Link

Manual fallback actions must link to reconciliation.

Required fields:

```text
manual_fallback_link_id
reconciliation_case_id
manual_fallback_case_id
staff_action_id
manual_action_type
amount_minor
currency_code
evidence_ref
created_at_utc
status
```

Manual action must not close reconciliation automatically.

It provides evidence for review.

---

## 15. Proof Conflict Link

Proof conflict must be linked to reconciliation case.

Required fields:

```text
proof_conflict_link_id
reconciliation_case_id
transaction_id
proof_conflict_type
proof_a_ref
proof_b_ref
conflict_summary
created_at_utc
status
```

Recommended proof conflict types:

```text
payment_vs_receipt
receipt_vs_calculation
refund_vs_request
cancel_vs_order_state
pos_vs_gateway_order
settlement_vs_payment
manual_vs_provider
```

Proof conflict requires resolution or known variance approval.

---

## 16. Provider Settlement Reference

Provider settlement reference connects transaction evidence to settlement data.

Required fields:

```text
provider_settlement_reference_id
transaction_id
tenant_id
store_id
provider_id
payment_route_id
settlement_batch_id
settlement_reference
settlement_business_date_local
settlement_amount_minor
currency_code
settlement_status
created_at_utc
status
```

Payment route metadata must support VAN/PG/card-company grouping.

This is required for large franchise settlement.

---

## 17. Settlement Import Reference

Settlement import reference tracks external settlement data ingestion.

Required fields:

```text
settlement_import_reference_id
tenant_id
store_id
provider_id
import_batch_id
source_file_ref
source_type
business_date_local
currency_code
import_status
imported_at_utc
status
```

Recommended source types:

```text
VAN_report
PG_report
POS_report
card_company_report
bank_deposit_report
provider_api
manual_upload
```

Settlement import must not overwrite gateway transaction state.

It provides comparison data.

---

## 18. Accounting Export Guard

Accounting export guard prevents unresolved risky transactions from entering accounting output.

Required fields:

```text
accounting_export_guard_id
tenant_id
store_id
business_date_local
export_scope
guard_status
blocking_case_count
known_variance_count
approved_exception_count
checked_at_utc
status
```

Recommended guard statuses:

```text
pass
pass_with_known_variance
blocked
manual_review_required
export_paused
```

Accounting export must be blocked when unresolved material variance exists.

---

## 19. Known Variance Approval

Known variance approval allows export or closure with documented exception.

Required fields:

```text
known_variance_approval_id
reconciliation_case_id
transaction_id
variance_type
amount_minor
currency_code
approval_reason
approved_by_actor_id
approved_at_utc
expires_at_utc
status
```

Known variance approval must be limited and auditable.

It must not become a shortcut for unresolved recurring errors.

---

## 20. Manual Adjustment Record

Manual adjustment record corrects financial reporting without rewriting source transaction.

Required fields:

```text
manual_adjustment_id
reconciliation_case_id
transaction_id
adjustment_type
adjustment_amount_minor
currency_code
adjustment_reason
source_state_ref
approval_reference
created_by_actor_id
created_at_utc
status
```

Recommended adjustment types:

```text
payment_correction
refund_correction
receipt_correction
rounding_correction
provider_fee_correction
tax_correction
manual_pos_entry_correction
settlement_correction
```

Manual adjustment must be additive.

---

## 21. Audit Evidence Envelope

Audit evidence envelope is the immutable wrapper around important evidence.

Required fields:

```text
audit_evidence_envelope_id
tenant_id
store_id
transaction_id
evidence_type
evidence_ref
evidence_hash
hash_algorithm
created_at_utc
created_by_system
retention_category
privacy_category
status
```

Evidence envelope should preserve proof of existence and integrity without necessarily exposing raw payload.

---

## 22. Immutable Evidence Reference

Immutable evidence reference points to transaction-critical records.

Evidence references may include:

```text
calculation_snapshot
provider_request_envelope
provider_response_envelope
payment_proof
receipt_proof
cancel_proof
refund_proof
state_transition
manual_action
approval_decision
customer_message
settlement_import
reconciliation_closure
```

Immutable references must not be deleted as normal cleanup.

Corrections must be additive.

---

## 23. Redaction-Aware Evidence Pointer

Evidence may include personal data requiring redaction or deletion.

Redaction-aware pointer must include:

```text
evidence_pointer_id
audit_evidence_envelope_id
raw_payload_ref
redacted_payload_ref
personal_data_present_flag
redaction_status
redacted_at_utc
legal_hold_flag
status
```

This supports audit immutability while allowing privacy compliance.

Transaction facts remain.  
Personal payload may be redacted according to policy.

---

## 24. Evidence Access Log

Access to sensitive evidence must be logged.

Required fields:

```text
evidence_access_log_id
actor_id
actor_role
tenant_id
store_id
transaction_id
evidence_ref
access_reason
accessed_at_utc
access_result
status
```

Evidence access should be reviewed for:

- raw provider payload;
- payment proof;
- customer communication;
- identity/device evidence;
- manual fallback evidence;
- forensic evidence.

---

## 25. Reconciliation Closure

Reconciliation closure must document the final conclusion.

Required fields:

```text
reconciliation_closure_id
reconciliation_case_id
transaction_id
closure_type
closure_reason
evidence_summary_ref
financial_impact_minor
currency_code
customer_impact_flag
manual_adjustment_id
known_variance_approval_id
closed_by_actor_id
closed_at_utc
status
```

Recommended closure types:

```text
matched
resolved_by_provider_lookup
resolved_by_manual_verification
resolved_by_refund
resolved_by_cancellation
resolved_by_manual_adjustment
closed_with_known_variance
escalated_to_incident
unable_to_resolve
```

Closure must not destroy or rewrite the variance history.

---

## 26. Reopen Rules

A reconciliation case must be reopenable when:

- late provider webhook contradicts closure;
- settlement report differs from prior result;
- customer dispute arrives after closure;
- refund proof changes;
- receipt proof appears late;
- manual evidence is found invalid;
- audit review finds missing proof;
- known variance approval expires.

Reopen record must include:

```text
reconciliation_reopen_id
reconciliation_case_id
reopen_reason
reopened_by_actor_id
reopened_at_utc
prior_closure_id
status
```

Reopening is not failure.  
It preserves truth when new evidence appears.

---

## 27. Customer Dispute Link

Customer dispute must link to reconciliation where financial or proof conflict exists.

Required fields:

```text
customer_dispute_link_id
reconciliation_case_id
transaction_id
support_case_id
dispute_type
customer_claim_summary
evidence_required_flag
created_at_utc
status
```

Customer dispute should not be resolved solely from customer narrative or internal assumption.

Transaction evidence must be reviewed.

---

## 28. Provider Escalation Link

Provider escalation must link to reconciliation when provider evidence is needed.

Required fields:

```text
provider_escalation_link_id
reconciliation_case_id
provider_id
escalation_packet_ref
provider_ticket_reference
escalation_status
created_at_utc
updated_at_utc
status
```

Provider escalation packet must be redacted and safe.

---

## 29. Data Model Draft

Recommended table group:

```text
pos_gateway_reconciliation_markers
pos_gateway_reconciliation_cases
pos_gateway_variance_classifications
pos_gateway_transaction_match_candidates
pos_gateway_amount_match_results
pos_gateway_pos_payment_match_results
pos_gateway_receipt_match_results
pos_gateway_cancel_refund_match_results
pos_gateway_manual_fallback_links
pos_gateway_proof_conflict_links
pos_gateway_provider_settlement_references
pos_gateway_settlement_import_references
pos_gateway_accounting_export_guards
pos_gateway_known_variance_approvals
pos_gateway_manual_adjustments
pos_gateway_audit_evidence_envelopes
pos_gateway_immutable_evidence_references
pos_gateway_redaction_evidence_pointers
pos_gateway_evidence_access_logs
pos_gateway_reconciliation_closures
pos_gateway_reconciliation_reopens
pos_gateway_customer_dispute_links
pos_gateway_provider_escalation_links
```

The implementation may integrate with broader finance/audit schemas, but POS Gateway evidence linkage must remain intact.

---

## 30. API Requirements

Recommended internal APIs or service methods:

```text
createReconciliationMarker()
openReconciliationCase()
classifyVariance()
generateMatchCandidates()
recordAmountMatchResult()
recordPosPaymentMatchResult()
recordReceiptMatchResult()
recordCancelRefundMatchResult()
linkManualFallback()
linkProofConflict()
recordProviderSettlementReference()
recordSettlementImportReference()
evaluateAccountingExportGuard()
requestKnownVarianceApproval()
recordManualAdjustment()
createAuditEvidenceEnvelope()
createImmutableEvidenceReference()
createRedactionEvidencePointer()
logEvidenceAccess()
closeReconciliationCase()
reopenReconciliationCase()
linkCustomerDispute()
linkProviderEscalation()
```

All reconciliation closure and adjustment APIs must be permission-controlled and audited.

---

## 31. Denial Reason Codes

Recommended denial reason codes:

```text
reconciliation_case_missing
variance_unclassified
evidence_missing
match_confidence_too_low
amount_mismatch_unresolved
payment_proof_missing
receipt_proof_missing
refund_proof_missing
manual_adjustment_requires_approval
known_variance_approval_required
accounting_export_blocked
case_closure_not_allowed
case_already_closed
case_reopen_required
evidence_access_denied
legal_hold_blocks_redaction
```

Denial reasons should be operator-facing and not directly customer-facing.

---

## 32. Audit Event Requirements

Required audit events:

```text
pos_gateway.reconciliation.marker_created
pos_gateway.reconciliation.case_opened
pos_gateway.reconciliation.variance_classified
pos_gateway.reconciliation.match_candidate_generated
pos_gateway.reconciliation.amount_match_recorded
pos_gateway.reconciliation.pos_payment_match_recorded
pos_gateway.reconciliation.receipt_match_recorded
pos_gateway.reconciliation.cancel_refund_match_recorded
pos_gateway.reconciliation.manual_fallback_linked
pos_gateway.reconciliation.proof_conflict_linked
pos_gateway.reconciliation.settlement_reference_recorded
pos_gateway.reconciliation.accounting_export_guard_evaluated
pos_gateway.reconciliation.known_variance_approved
pos_gateway.reconciliation.manual_adjustment_recorded
pos_gateway.audit.evidence_envelope_created
pos_gateway.audit.evidence_accessed
pos_gateway.reconciliation.case_closed
pos_gateway.reconciliation.case_reopened
pos_gateway.reconciliation.customer_dispute_linked
pos_gateway.reconciliation.provider_escalation_linked
```

Audit must include:

```text
tenant_id
store_id
transaction_id
reconciliation_case_id
actor_id
amount_minor
currency_code
created_at_utc
correlation_id
```

---

## 33. Monitoring Requirements

Monitoring must detect:

- open reconciliation case count;
- case aging;
- high-severity variance count;
- payment unknown cases;
- refund unknown cases;
- receipt missing cases;
- settlement mismatch count;
- manual adjustment count;
- known variance approval count;
- accounting export blocked count;
- evidence access spike;
- redaction pending backlog;
- reopened case count;
- provider escalation aging;
- customer dispute linked to payment/refund.

Monitoring must be scoped by tenant, store, provider, payment route, business date, and currency.

---

## 34. Alert Requirements

Critical alerts:

```text
accounting_export_blocked
payment_reconciliation_backlog_high
refund_reconciliation_backlog_high
settlement_mismatch_high
manual_adjustment_spike
known_variance_approval_spike
high_value_amount_variance
evidence_missing_for_closure_attempt
case_reopen_after_closure
provider_escalation_overdue
raw_evidence_access_spike
```

Alerts must link to reconciliation runbook and provider/customer support workflow.

---

## 35. Test Requirements

Required tests:

```text
reconciliation_marker_creation_test
case_open_from_marker_test
variance_classification_test
transaction_match_candidate_test
amount_match_exact_test
amount_match_mismatch_test
POS_payment_match_test
receipt_missing_case_test
cancel_refund_match_test
manual_fallback_link_test
proof_conflict_link_test
settlement_reference_record_test
accounting_export_guard_block_test
known_variance_approval_test
manual_adjustment_additive_test
audit_evidence_envelope_hash_test
redaction_pointer_test
evidence_access_log_test
case_closure_requires_evidence_test
case_reopen_test
customer_dispute_link_test
provider_escalation_link_test
```

Reconciliation tests are mandatory before accounting export or scale rollout.

---

## 36. Acceptance Criteria

This work package is acceptable only when:

- reconciliation marker intake exists;
- reconciliation case exists;
- variance classification exists;
- transaction match candidate model exists;
- amount, POS/payment, receipt, cancel/refund matching exists;
- manual fallback and proof conflict linkage exists;
- provider settlement reference exists;
- settlement import reference exists;
- accounting export guard exists;
- known variance approval exists;
- manual adjustment record exists;
- audit evidence envelope exists;
- immutable evidence reference exists;
- redaction-aware evidence pointer exists;
- evidence access log exists;
- reconciliation closure and reopen rules exist;
- customer dispute and provider escalation links exist;
- APIs, denial codes, audit events, monitoring, alerts, and tests exist.

---

## 37. Relationship To Adjacent Documents

This document is related to:

- 06370 WorkPackage POS Gateway manual fallback, manager approval, staff action, and override;
- 06360 WorkPackage POS Gateway table, QR, NFC, kiosk device, receipt proof, and customer status;
- 06350 WorkPackage POS Gateway POS/KDS adapter interface, routing, error normalization, and provider contract;
- 06340 WorkPackage POS Gateway idempotency, queue, retry, dead-letter, replay, and duplicate prevention;
- 06330 WorkPackage POS Gateway order, payment, cancel, refund state machine, and transaction timeline;
- 06120 Policy POS Gateway reconciliation case workflow, variance resolution, manual adjustment, and audit closure;
- 06130 Policy POS Gateway data retention, archive, privacy, redaction, and forensic evidence lifecycle;
- 06140 Policy POS Gateway access control, role segregation, tenant isolation, privileged action, and approval audit.

Where conflict exists, this document governs implementation work planning for reconciliation, audit evidence, settlement linkage, and accounting guard behavior in POS Gateway operations.

---

## 38. Summary

The POS Gateway must be able to prove what happened.

Reconciliation is the layer that protects the business when systems disagree.

The correct implementation standard is:

- create markers when uncertainty appears;
- open cases for material variance;
- classify variance;
- compare transaction, POS, payment, receipt, refund, cancellation, and settlement evidence;
- link manual fallback;
- preserve immutable evidence;
- support privacy-aware redaction;
- block accounting export when unresolved risk remains;
- approve known variance explicitly;
- make adjustments additively;
- close cases only with evidence;
- reopen when late evidence contradicts closure.

A transaction is not financially safe until it can survive reconciliation.