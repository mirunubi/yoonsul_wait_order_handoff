# 000808_Template_POS_Transaction_Evidence_Event_Log_And_Diagnostic_Record.md

## 1. Purpose

This document defines the evidence packet, event log, and diagnostic record template for POS Gateway and provider adapter transactions.

The purpose is to make every POS-related order, payment, cancellation, refund, retry, timeout, recovery, reconciliation, manual operation, and degraded mode decision reconstructable.

This document is a template foundation document.

It is not implementation code.

## 2. Upstream Dependencies

This document depends on:

```text
000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md
000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md
000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md
000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md
000805_Policy_POS_Official_API_No_Scraping_And_Provider_Boundary.md
000806_Logic_POS_Idempotency_Retry_Timeout_Duplicate_Prevention_And_Unknown_State.md
000807_Runbook_POS_Reconciliation_Recovery_Manual_Operation_And_Degraded_Mode.md
```

The evidence template must support the authority boundary, adapter contract, state machine, provider capability matrix, official API policy, retry logic, and recovery runbook.

## 3. Core Rule

```text
No high-risk POS, payment, cancellation, refund, recovery, reconciliation, manual operation, or degraded mode decision is acceptable without evidence.
```

Evidence must make it possible to answer:

```text
What happened?
When did it happen?
Who or what triggered it?
Which provider was involved?
Which identifiers connect the events?
Was money moved?
Was a POS order created?
Was kitchen operation affected?
Was the customer-facing status affected?
Was retry safe?
Was recovery performed?
Was reconciliation completed?
Who approved the final interpretation?
```

## 4. Scope

This template covers evidence for:

* POS Gateway events
* provider adapter events
* order creation
* payment authorization
* payment cancellation
* refund
* POS order creation
* POS cancellation
* KDS display
* DID callout
* menu sync
* sold-out sync
* timeout
* retry
* duplicate detection
* unknown state
* provider unavailable
* recovery
* reconciliation
* manual operation
* degraded mode
* safe closure
* human review
* final acceptance

## 5. Non-Scope

This document does not define:

* database table implementation
* log storage implementation
* observability vendor configuration
* Flutter UI implementation
* provider-specific payload schema
* production credential storage
* legal retention period
* final privacy policy
* final customer support script

Those belong to separate data, security, observability, legal, or support documents.

## 6. Evidence Packet Types

The system should distinguish several evidence packet types.

| Evidence Type               | Purpose                                              |
| --------------------------- | ---------------------------------------------------- |
| `transaction_evidence`      | Records a POS/payment/order transaction event        |
| `provider_adapter_evidence` | Records provider adapter request/response behavior   |
| `timeout_evidence`          | Records timeout classification and retry eligibility |
| `duplicate_evidence`        | Records suspected or confirmed duplicate risk        |
| `recovery_evidence`         | Records recovery action and result                   |
| `reconciliation_evidence`   | Records mismatch comparison and resolution           |
| `manual_operation_evidence` | Records staff or operator manual action              |
| `degraded_mode_evidence`    | Records limited/manual operation state               |
| `human_review_evidence`     | Records human decision and approval                  |
| `incident_evidence`         | Records larger provider, store, or runtime incident  |

A single incident may contain multiple evidence packets.

## 7. Minimum Evidence Header

Every evidence packet must include the following header fields.

| Field              | Required | Description                                                          |
| ------------------ | -------: | -------------------------------------------------------------------- |
| `evidence_id`      |      Yes | Unique evidence packet identifier                                    |
| `evidence_type`    |      Yes | Evidence packet type                                                 |
| `gateway_event_id` |      Yes | POS Gateway event identifier                                         |
| `correlation_id`   |      Yes | Cross-runtime trace identifier                                       |
| `tenant_id`        |      Yes | Tenant boundary identifier                                           |
| `store_id`         |      Yes | Store boundary identifier                                            |
| `environment`      |      Yes | sandbox, staging, production, field_test, or local_test              |
| `created_at`       |      Yes | Evidence creation timestamp                                          |
| `created_by`       |      Yes | system, adapter, staff, support, manager, or reviewer                |
| `source_runtime`   |      Yes | order, payment, POS Gateway, adapter, KDS, DID, CMS, manual, support |
| `severity`         |      Yes | info, warning, high, critical                                        |
| `approval_status`  |      Yes | pending, approved, rejected, human_review_required, not_required     |

## 8. Order And Payment Identifiers

When applicable, evidence must include:

| Field                    | Required When Applicable | Description                                  |
| ------------------------ | -----------------------: | -------------------------------------------- |
| `order_id`               |                      Yes | Internal order identifier                    |
| `order_request_id`       |                      Yes | Customer or runtime order request identifier |
| `payment_id`             |                      Yes | Internal payment identifier                  |
| `payment_transaction_id` |                      Yes | Payment provider transaction ID              |
| `refund_id`              |                      Yes | Internal refund identifier                   |
| `refund_transaction_id`  |                      Yes | Provider refund transaction ID               |
| `payment_amount`         |                      Yes | Payment amount                               |
| `refund_amount`          |                      Yes | Refund amount                                |
| `currency`               |                      Yes | Currency                                     |
| `payment_status_before`  |                      Yes | Previous payment state                       |
| `payment_status_after`   |                      Yes | Resulting payment state                      |
| `refund_status_before`   |                      Yes | Previous refund state                        |
| `refund_status_after`    |                      Yes | Resulting refund state                       |

Payment and refund evidence must avoid exposing sensitive payment data.

## 9. POS Provider Identifiers

When a POS provider is involved, evidence must include:

| Field                              | Required When Applicable | Description                                  |
| ---------------------------------- | -----------------------: | -------------------------------------------- |
| `pos_provider_id`                  |                      Yes | POS provider identifier                      |
| `pos_provider_name`                |                      Yes | Provider display name                        |
| `pos_adapter_id`                   |                      Yes | Adapter identifier                           |
| `pos_adapter_version`              |                      Yes | Adapter version                              |
| `pos_order_id`                     |           When available | Provider-side POS order identifier           |
| `pos_transaction_id`               |           When available | Provider-side POS transaction identifier     |
| `pos_receipt_id`                   |           When available | Provider-side receipt identifier             |
| `provider_request_id`              |           When available | Provider request identifier                  |
| `provider_response_id`             |           When available | Provider response identifier                 |
| `provider_timestamp`               |           When available | Provider-side timestamp                      |
| `provider_raw_status`              |           When available | Provider raw status                          |
| `provider_error_code`              |           When available | Provider raw error code                      |
| `provider_error_message_reference` |           When available | Reference to raw error message after masking |

Provider-specific raw values must be preserved as references, not blindly trusted as final business truth.

## 10. Adapter Method Evidence

Each provider adapter method call must record:

| Field                           |        Required | Description                                                 |
| ------------------------------- | --------------: | ----------------------------------------------------------- |
| `adapter_method`                |             Yes | healthCheck, createOrder, cancelOrder, refundPayment, etc.  |
| `operation_type`                |             Yes | read, write, recovery, reconciliation, manual               |
| `request_payload_reference`     |             Yes | Reference to stored or masked request payload               |
| `response_payload_reference`    |  When available | Reference to stored or masked response payload              |
| `normalized_result_category`    |             Yes | success, failed, pending, unknown, duplicate_detected, etc. |
| `normalized_error_category`     | When applicable | timeout, provider_unavailable, state_conflict, etc.         |
| `contract_violation_detected`   |             Yes | true or false                                               |
| `unsupported_operation`         |             Yes | true or false                                               |
| `provider_limitation_reference` | When applicable | Link or reference to provider limitation                    |

The adapter evidence must show whether the adapter followed the contract in `000802`.

## 11. State Transition Evidence

Every meaningful state transition must record:

| Field                           |                        Required | Description                                                             |
| ------------------------------- | ------------------------------: | ----------------------------------------------------------------------- |
| `state_group`                   |                             Yes | order, payment, POS, KDS, DID, cancel, refund, recovery, reconciliation |
| `previous_state`                |                             Yes | Previous internal state                                                 |
| `next_state`                    |                             Yes | Resulting internal state                                                |
| `transition_reason`             |                             Yes | Reason for state transition                                             |
| `transition_source`             |                             Yes | system, provider, webhook, polling, manual, support, reviewer           |
| `transition_timestamp`          |                             Yes | Timestamp                                                               |
| `state_machine_reference`       |                             Yes | Reference to `000803` or related state rule                             |
| `customer_facing_status_before` |                 When applicable | Previous customer-facing status                                         |
| `customer_facing_status_after`  |                 When applicable | Resulting customer-facing status                                        |
| `finality_claimed`              |                             Yes | true or false                                                           |
| `finality_evidence_reference`   | Required if finality is claimed | Evidence supporting final state                                         |

Unknown, recovery, reconciliation, and manual review states must remain visible.

## 12. Idempotency And Retry Evidence

Every state-changing operation must record:

| Field                                   |            Required | Description                                                                  |
| --------------------------------------- | ------------------: | ---------------------------------------------------------------------------- |
| `idempotency_key`                       |                 Yes | Stable idempotency key                                                       |
| `idempotency_scope`                     |                 Yes | order, payment, refund, cancellation, sync, recovery                         |
| `provider_native_idempotency_supported` |                 Yes | yes, no, unknown                                                             |
| `gateway_duplicate_check_result`        |                 Yes | no_duplicate, suspected_duplicate, duplicate_detected, unknown               |
| `retry_count`                           |                 Yes | Number of retries attempted                                                  |
| `retry_category`                        |                 Yes | safe_retry, conditional_retry, unsafe_retry, manual_review_required, blocked |
| `retry_reason`                          | When retry occurred | Reason for retry                                                             |
| `retry_window_status`                   |                 Yes | active, exhausted, not_applicable                                            |
| `retry_block_reason`                    |        When blocked | Reason retry was blocked                                                     |
| `duplicate_risk_level`                  |                 Yes | none, low, medium, high, critical                                            |
| `duplicate_evidence_reference`          |     When applicable | Reference to duplicate evidence                                              |

The idempotency key must not change across logical retries.

## 13. Timeout Evidence

When timeout occurs, evidence must record:

| Field                               |      Required | Description                                                                                                                                                                             |
| ----------------------------------- | ------------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `timeout_detected`                  |           Yes | true or false                                                                                                                                                                           |
| `timeout_type`                      |  When timeout | pre_submit_timeout, submit_unknown_timeout, post_submit_timeout, provider_processing_timeout, callback_timeout, status_query_timeout, recovery_timeout, refund_timeout, payment_timeout |
| `timeout_started_at`                |  When timeout | Start timestamp                                                                                                                                                                         |
| `timeout_detected_at`               |  When timeout | Detection timestamp                                                                                                                                                                     |
| `request_may_have_reached_provider` |  When timeout | yes, no, unknown                                                                                                                                                                        |
| `provider_processing_possible`      |  When timeout | yes, no, unknown                                                                                                                                                                        |
| `status_query_available`            |  When timeout | yes, no, unknown                                                                                                                                                                        |
| `timeout_default_route`             |  When timeout | pending, unknown, reconciliation_required, manual_review_required, recovery_required                                                                                                    |
| `timeout_resolution`                | When resolved | success, failed, pending, unknown, manually_resolved                                                                                                                                    |
| `timeout_resolution_evidence`       | When resolved | Evidence reference                                                                                                                                                                      |

Timeout must not be treated as failure unless failure is proven.

## 14. Unknown State Evidence

When unknown state occurs, evidence must record:

| Field                    |      Required | Description                                                                                           |
| ------------------------ | ------------: | ----------------------------------------------------------------------------------------------------- |
| `unknown_state_detected` |           Yes | true or false                                                                                         |
| `unknown_state_type`     |  When unknown | payment_unknown, pos_order_unknown, cancel_unknown, refund_unknown, provider_unknown, general_unknown |
| `unknown_reason`         |  When unknown | Reason unknown state exists                                                                           |
| `known_facts`            |  When unknown | Facts that are known                                                                                  |
| `missing_facts`          |  When unknown | Facts required to resolve                                                                             |
| `money_risk`             |  When unknown | none, low, medium, high, critical                                                                     |
| `order_risk`             |  When unknown | none, low, medium, high, critical                                                                     |
| `kitchen_risk`           |  When unknown | none, low, medium, high, critical                                                                     |
| `customer_promise_risk`  |  When unknown | none, low, medium, high, critical                                                                     |
| `required_next_step`     |  When unknown | wait, poll, reconcile, manual_review, recover, block                                                  |
| `resolution_status`      | When resolved | resolved, unresolved, escalated                                                                       |

Unknown state must not be hidden as success.

## 15. Recovery Evidence

When recovery is attempted, evidence must record:

| Field                                    |       Required | Description                                                                                                                    |
| ---------------------------------------- | -------------: | ------------------------------------------------------------------------------------------------------------------------------ |
| `recovery_id`                            |            Yes | Recovery event identifier                                                                                                      |
| `recovery_reason`                        |            Yes | Why recovery was needed                                                                                                        |
| `original_failure_evidence_id`           |            Yes | Evidence of original failure or unknown state                                                                                  |
| `recovery_type`                          |            Yes | automatic, manual, provider_status_check, POS_manual_entry, KDS_resend, DID_manual_callout, refund_review, cancellation_review |
| `recovery_actor`                         |            Yes | system, staff, manager, support, reviewer                                                                                      |
| `recovery_started_at`                    |            Yes | Start timestamp                                                                                                                |
| `recovery_completed_at`                  | When completed | Completion timestamp                                                                                                           |
| `recovery_result`                        |            Yes | success, failed, partial, unknown, manual_review_required                                                                      |
| `recovery_side_effect_risk`              |            Yes | none, low, medium, high, critical                                                                                              |
| `human_approval_reference`               |  When required | Approval record                                                                                                                |
| `post_recovery_state`                    | When completed | Resulting state                                                                                                                |
| `reconciliation_required_after_recovery` |            Yes | true or false                                                                                                                  |

Recovery must not erase original failure evidence.

## 16. Reconciliation Evidence

When reconciliation is performed, evidence must record:

| Field                             |      Required | Description                                                                             |
| --------------------------------- | ------------: | --------------------------------------------------------------------------------------- |
| `reconciliation_id`               |           Yes | Reconciliation identifier                                                               |
| `reconciliation_scope`            |           Yes | order, payment, POS, KDS, DID, refund, cancellation, menu, sold_out, incident           |
| `reconciliation_reason`           |           Yes | Why reconciliation was required                                                         |
| `reconciliation_time_window`      |           Yes | Time range reviewed                                                                     |
| `matched_event_count`             |           Yes | Number of matched events                                                                |
| `mismatched_event_count`          |           Yes | Number of mismatched events                                                             |
| `unresolved_event_count`          |           Yes | Number of unresolved events                                                             |
| `duplicate_risk_count`            |           Yes | Number of duplicate risks found                                                         |
| `payment_order_split_brain_count` |           Yes | Count of payment/order mismatches                                                       |
| `pos_kds_split_brain_count`       |           Yes | Count of POS/KDS mismatches                                                             |
| `refund_risk_count`               |           Yes | Count of refund risks                                                                   |
| `recommended_action`              |           Yes | None, recover, manual_review, refund_review, cancel_review, degraded_mode, safe_closure |
| `reconciliation_result`           |           Yes | resolved, partially_resolved, unresolved, escalated                                     |
| `reviewer`                        | When required | Human reviewer                                                                          |

Reconciliation must compare internal state with provider, payment, POS, KDS, DID, manual operation, and customer-facing records where applicable.

## 17. Manual Operation Evidence

When manual operation occurs, evidence must record:

| Field                           |       Required | Description                                                                                                                                             |
| ------------------------------- | -------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `manual_operation_id`           |            Yes | Manual operation identifier                                                                                                                             |
| `manual_operation_type`         |            Yes | manual_POS_entry, manual_kitchen_ticket, manual_callout, manual_refund_review, manual_cancel_review, manual_menu_override, manual_availability_override |
| `manual_actor_role`             |            Yes | staff, manager, support, headquarters, platform_admin                                                                                                   |
| `manual_actor_reference`        |            Yes | Masked or internal actor reference                                                                                                                      |
| `manual_operation_reason`       |            Yes | Reason manual action was needed                                                                                                                         |
| `manual_operation_started_at`   |            Yes | Start timestamp                                                                                                                                         |
| `manual_operation_completed_at` | When completed | Completion timestamp                                                                                                                                    |
| `manual_result`                 |            Yes | success, failed, partial, unknown                                                                                                                       |
| `manager_approval_required`     |            Yes | true or false                                                                                                                                           |
| `manager_approval_reference`    |  When required | Approval reference                                                                                                                                      |
| `customer_impact`               |            Yes | none, delayed, corrected, canceled, refunded, unresolved                                                                                                |
| `follow_up_required`            |            Yes | true or false                                                                                                                                           |

Manual operation must be linked to original system evidence.

## 18. Degraded Mode Evidence

When degraded mode is activated, evidence must record:

| Field                                   |    Required | Description                                                                                                    |
| --------------------------------------- | ----------: | -------------------------------------------------------------------------------------------------------------- |
| `degraded_mode_id`                      |         Yes | Degraded mode identifier                                                                                       |
| `degraded_mode_level`                   |         Yes | D0_Normal, D1_Minor_Degraded, D2_Channel_Limited, D3_Manual_Operation, D4_Financial_Risk_Lock, D5_Safe_Closure |
| `degraded_mode_reason`                  |         Yes | Reason degraded mode was activated                                                                             |
| `affected_channels`                     |         Yes | app, kiosk, POS, KDS, DID, CMS, counter, delivery, takeout                                                     |
| `affected_store_ids`                    |         Yes | Store list or reference                                                                                        |
| `allowed_operations`                    |         Yes | Operations still allowed                                                                                       |
| `blocked_operations`                    |         Yes | Operations blocked                                                                                             |
| `activated_by`                          |         Yes | System or human actor                                                                                          |
| `activated_at`                          |         Yes | Activation timestamp                                                                                           |
| `exit_condition`                        |         Yes | Required condition to exit degraded mode                                                                       |
| `exited_at`                             | When exited | Exit timestamp                                                                                                 |
| `exit_approval_reference`               | When exited | Approval reference                                                                                             |
| `post_degraded_reconciliation_required` |         Yes | true or false                                                                                                  |

Degraded mode must not end without required checks.

## 19. Human Review Evidence

When human review is required, evidence must record:

| Field                     |        Required | Description                                                                     |
| ------------------------- | --------------: | ------------------------------------------------------------------------------- |
| `human_review_id`         |             Yes | Human review identifier                                                         |
| `review_reason`           |             Yes | Why review was required                                                         |
| `reviewer_role`           |             Yes | manager, support, payment_support, headquarters, platform_admin, human_reviewer |
| `reviewer_reference`      |             Yes | Masked or internal reviewer reference                                           |
| `review_started_at`       |             Yes | Review start timestamp                                                          |
| `review_completed_at`     |  When completed | Review completion timestamp                                                     |
| `review_decision`         |             Yes | approved, rejected, needs_more_evidence, escalated, accepted_with_limitations   |
| `decision_reason`         |             Yes | Explanation of decision                                                         |
| `accepted_risk`           |             Yes | none, low, medium, high, critical                                               |
| `required_follow_up`      |             Yes | Follow-up action                                                                |
| `payment_approval_status` | When applicable | approved, blocked, pending, not_applicable                                      |
| `final_state_approved`    |             Yes | true or false                                                                   |

Human review must be recorded for high-risk or irreversible decisions.

## 20. Incident Evidence

When an incident affects multiple orders, stores, providers, or tenants, evidence must record:

| Field                           |        Required | Description                                                                                                            |
| ------------------------------- | --------------: | ---------------------------------------------------------------------------------------------------------------------- |
| `incident_id`                   |             Yes | Incident identifier                                                                                                    |
| `incident_type`                 |             Yes | provider_outage, network_outage, payment_issue, POS_gateway_issue, KDS_issue, DID_issue, menu_sync_issue, refund_issue |
| `incident_severity`             |             Yes | low, medium, high, critical                                                                                            |
| `incident_started_at`           |             Yes | Start timestamp                                                                                                        |
| `incident_detected_at`          |             Yes | Detection timestamp                                                                                                    |
| `incident_resolved_at`          |   When resolved | Resolution timestamp                                                                                                   |
| `affected_provider`             | When applicable | Provider name                                                                                                          |
| `affected_tenants`              |             Yes | Tenant list or reference                                                                                               |
| `affected_stores`               |             Yes | Store list or reference                                                                                                |
| `affected_order_count`          |             Yes | Count                                                                                                                  |
| `affected_payment_count`        |             Yes | Count                                                                                                                  |
| `degraded_mode_reference`       | When applicable | Degraded mode evidence                                                                                                 |
| `root_cause_summary`            |      When known | Summary                                                                                                                |
| `post_incident_review_required` |             Yes | true or false                                                                                                          |

Incident evidence may reference many transaction evidence packets.

## 21. Privacy And Masking Rule

Evidence must preserve operational truth without exposing unnecessary sensitive data.

The following must be masked, tokenized, or referenced according to approved policy:

* customer name
* customer phone number
* payment card data
* wallet account data
* address
* raw payment credential
* provider credential
* staff personal data
* sensitive notes
* full raw payloads containing PII

Evidence should store references to secure payload storage rather than copying sensitive payloads directly into Markdown or plain text logs.

## 22. Payload Reference Rule

Evidence must not rely only on copied screenshots or pasted raw payloads.

For request and response payloads, record:

* payload reference ID
* payload storage location or secure reference
* payload masking status
* payload hash where applicable
* payload retention policy reference
* reviewer access requirement

Payload references must be stable enough for audit and troubleshooting.

## 23. Screenshot And Log Reference Rule

Screenshots and logs may support evidence but must not replace structured evidence.

Record:

* screenshot reference ID
* log reference ID
* capture timestamp
* capture actor
* masking status
* affected order/payment/POS ID
* storage location
* retention requirement

Screenshots containing PII or credentials must be masked or restricted.

## 24. Approval Status Values

Allowed approval status values:

| Status                      | Meaning                                   |
| --------------------------- | ----------------------------------------- |
| `not_required`              | No human approval required                |
| `pending`                   | Human approval required but not completed |
| `approved`                  | Human approval completed                  |
| `rejected`                  | Human approval rejected action            |
| `accepted_with_limitations` | Accepted but limitation remains           |
| `human_review_required`     | Requires explicit human review            |
| `escalated`                 | Escalated to higher authority             |

Do not invent new approval statuses without governance approval.

## 25. Evidence Completeness Levels

Evidence completeness may be classified as:

| Level          | Meaning                                                    |
| -------------- | ---------------------------------------------------------- |
| `complete`     | Sufficient to reconstruct and approve final interpretation |
| `partial`      | Some required evidence exists but unresolved gaps remain   |
| `insufficient` | Evidence is not enough to make final interpretation        |
| `missing`      | Required evidence is absent                                |
| `restricted`   | Evidence exists but access is restricted                   |
| `corrupted`    | Evidence exists but cannot be trusted                      |
| `conflicting`  | Evidence sources disagree                                  |

Financial or high-risk operational decisions require complete or explicitly human-accepted evidence.

## 26. Standard Evidence Packet Template

Use the following template when creating a transaction evidence packet.

```yaml
evidence_id: TBD
evidence_type: transaction_evidence
gateway_event_id: TBD
correlation_id: TBD
tenant_id: TBD
store_id: TBD
environment: TBD
created_at: TBD
created_by: TBD
source_runtime: TBD
severity: TBD
approval_status: TBD

order:
  order_id: TBD
  order_request_id: TBD
  customer_facing_status_before: TBD
  customer_facing_status_after: TBD

payment:
  payment_id: TBD
  payment_transaction_id: TBD
  payment_amount: TBD
  currency: TBD
  payment_status_before: TBD
  payment_status_after: TBD

refund:
  refund_id: TBD
  refund_transaction_id: TBD
  refund_amount: TBD
  refund_status_before: TBD
  refund_status_after: TBD

pos_provider:
  pos_provider_id: TBD
  pos_provider_name: TBD
  pos_adapter_id: TBD
  pos_adapter_version: TBD
  pos_order_id: TBD
  pos_transaction_id: TBD
  pos_receipt_id: TBD
  provider_request_id: TBD
  provider_response_id: TBD
  provider_timestamp: TBD
  provider_raw_status: TBD
  provider_error_code: TBD

adapter_method:
  method_name: TBD
  operation_type: TBD
  request_payload_reference: TBD
  response_payload_reference: TBD
  normalized_result_category: TBD
  normalized_error_category: TBD
  contract_violation_detected: false
  unsupported_operation: false
  provider_limitation_reference: TBD

state_transition:
  state_group: TBD
  previous_state: TBD
  next_state: TBD
  transition_reason: TBD
  transition_source: TBD
  transition_timestamp: TBD
  finality_claimed: false
  finality_evidence_reference: TBD

idempotency_and_retry:
  idempotency_key: TBD
  idempotency_scope: TBD
  provider_native_idempotency_supported: TBD
  gateway_duplicate_check_result: TBD
  retry_count: 0
  retry_category: TBD
  retry_reason: TBD
  retry_window_status: TBD
  retry_block_reason: TBD
  duplicate_risk_level: TBD
  duplicate_evidence_reference: TBD

timeout:
  timeout_detected: false
  timeout_type: TBD
  request_may_have_reached_provider: TBD
  provider_processing_possible: TBD
  status_query_available: TBD
  timeout_default_route: TBD
  timeout_resolution: TBD
  timeout_resolution_evidence: TBD

unknown_state:
  unknown_state_detected: false
  unknown_state_type: TBD
  unknown_reason: TBD
  known_facts: TBD
  missing_facts: TBD
  money_risk: TBD
  order_risk: TBD
  kitchen_risk: TBD
  customer_promise_risk: TBD
  required_next_step: TBD
  resolution_status: TBD

recovery:
  recovery_id: TBD
  recovery_reason: TBD
  original_failure_evidence_id: TBD
  recovery_type: TBD
  recovery_actor: TBD
  recovery_result: TBD
  recovery_side_effect_risk: TBD
  human_approval_reference: TBD
  post_recovery_state: TBD
  reconciliation_required_after_recovery: TBD

reconciliation:
  reconciliation_id: TBD
  reconciliation_scope: TBD
  reconciliation_reason: TBD
  reconciliation_result: TBD
  recommended_action: TBD
  unresolved_event_count: TBD

manual_operation:
  manual_operation_id: TBD
  manual_operation_type: TBD
  manual_actor_role: TBD
  manual_actor_reference: TBD
  manual_operation_reason: TBD
  manual_result: TBD
  manager_approval_reference: TBD
  customer_impact: TBD
  follow_up_required: TBD

degraded_mode:
  degraded_mode_id: TBD
  degraded_mode_level: TBD
  degraded_mode_reason: TBD
  affected_channels: TBD
  allowed_operations: TBD
  blocked_operations: TBD
  exit_condition: TBD

human_review:
  human_review_id: TBD
  review_reason: TBD
  reviewer_role: TBD
  reviewer_reference: TBD
  review_decision: TBD
  decision_reason: TBD
  accepted_risk: TBD
  required_follow_up: TBD
  final_state_approved: false

attachments:
  screenshot_reference: TBD
  log_reference: TBD
  payload_hash: TBD
  masking_status: TBD
  retention_reference: TBD

final:
  evidence_completeness: TBD
  unresolved_risk: TBD
  final_runtime_state: TBD
  final_customer_facing_state: TBD
  final_owner: TBD
  final_approval_status: TBD
```

## 27. Minimal Event Log Line Template

For lightweight diagnostic event logs, use this minimal line structure.

```text
timestamp=<TBD>
severity=<TBD>
gateway_event_id=<TBD>
correlation_id=<TBD>
tenant_id=<TBD>
store_id=<TBD>
order_id=<TBD>
payment_id=<TBD>
provider=<TBD>
adapter=<TBD>
method=<TBD>
previous_state=<TBD>
next_state=<TBD>
result=<TBD>
error_category=<TBD>
idempotency_key=<TBD>
retry_count=<TBD>
timeout_type=<TBD>
duplicate_risk=<TBD>
manual_review=<TBD>
evidence_id=<TBD>
```

This minimal line is not a replacement for the full evidence packet in high-risk cases.

## 28. Evidence Required By Scenario

| Scenario                             | Required Evidence                                                                                  |
| ------------------------------------ | -------------------------------------------------------------------------------------------------- |
| Payment success but POS order failed | payment evidence, POS failure evidence, idempotency key, recovery decision, reconciliation result  |
| POS order success but KDS failed     | POS evidence, KDS failure evidence, manual kitchen evidence, reconciliation result                 |
| Kiosk order duplicated               | all related order IDs, idempotency keys, payment references, POS receipt references                |
| Payment duplicated                   | payment transaction IDs, provider status, duplicate risk review, refund/void evidence if performed |
| POS timeout                          | timeout type, request reference, retry count, status query result, reconciliation result           |
| Provider unavailable                 | health check evidence, outage timestamp, affected orders, degraded mode level                      |
| Refund unknown                       | refund request, payment reference, timeout type, provider status query, reviewer decision          |
| Cancel failed                        | cancellation request, provider response, kitchen state, payment state, reviewer decision           |
| Menu sync mismatch                   | menu versions, affected items, POS/CMS/app/kiosk comparison                                        |
| Sold-out sync mismatch               | availability snapshots, affected item IDs, staff confirmation, correction record                   |
| Internet failure                     | affected systems, affected orders, manual operation records, recovery timestamp                    |
| Local fallback                       | degraded mode decision, local POS receipts, manual order list, reconciliation result               |
| Manual recovery                      | original failure, approval record, manual POS/kitchen record, reconciliation result                |

## 29. Evidence Review Checklist

Before closing an evidence packet, verify:

* evidence ID exists
* correlation ID exists
* tenant and store are identified
* order ID is present where applicable
* payment ID is present where applicable
* POS provider is identified where applicable
* adapter version is recorded where applicable
* idempotency key is recorded for state-changing operations
* retry count is recorded
* timeout type is recorded when timeout occurred
* unknown state reason is recorded when unknown exists
* duplicate risk is recorded
* request and response references exist where applicable
* state transition is recorded
* recovery action is recorded when recovery occurred
* reconciliation result is recorded when reconciliation occurred
* manual operation is recorded when manual action occurred
* degraded mode is recorded when activated
* human review is recorded when required
* approval status is recorded
* evidence completeness is classified
* unresolved risk is recorded

## 30. Anti-Patterns

The following are prohibited:

* recording only “success” without provider evidence
* recording only “failed” after timeout without proof
* omitting idempotency key for state-changing operations
* omitting retry count
* omitting duplicate risk classification
* omitting payment ID during refund or payment issue
* omitting POS receipt ID when provider returned one
* omitting KDS state when kitchen visibility is affected
* overwriting unknown state without reconciliation
* deleting failure evidence after recovery
* storing raw credentials in evidence
* storing unmasked customer PII in plain text
* treating screenshots as the only evidence
* accepting vendor delivery without evidence samples
* finalizing refund or cancellation without approval evidence where required

## 31. Relationship To 000900 Outsourcing Package

The outsourcing package under:

```text
docs/000900_outsourcing_vendor_handoff_and_acceptance/
```

must require vendors to produce evidence compatible with this template.

Vendor evidence must include:

* provider adapter evidence
* request/response references
* idempotency evidence
* retry evidence
* timeout evidence
* duplicate prevention evidence
* recovery evidence
* reconciliation evidence
* known limitation evidence
* test scenario evidence
* final handoff evidence

A vendor adapter is not complete if it cannot produce evidence needed by this template.

## 32. Acceptance Criteria

This template is acceptable only if it confirms that:

* evidence is mandatory for high-risk POS operations
* transaction identifiers are preserved
* provider identifiers are preserved
* adapter method evidence is recorded
* state transition evidence is recorded
* idempotency and retry evidence are recorded
* timeout and unknown state evidence are recorded
* recovery and reconciliation evidence are recorded
* manual operation and degraded mode evidence are recorded
* human review evidence is recorded
* sensitive data must be masked or referenced securely
* vendor evidence must follow this structure
* no implementation is authorized by this document

## 33. Final Rule

```text
If the transaction cannot be reconstructed, reviewed, reconciled, and approved from evidence, the transaction must not be treated as operationally closed.
```
