# 014106_Policy_POS_Gateway_Reconciliation_Case_Settlement_Matching_Provider_POS_And_Internal_Ledger

## 1. Purpose

This document defines the POS Gateway reconciliation case, settlement matching, provider matching, POS matching, internal ledger matching, mismatch classification, and reconciliation closure policy.

The POS Gateway must not assume that internal order state, POS state, payment provider state, VAN/PG state, refund state, cancellation state, settlement file state, and staff manual recovery state will always match.

The purpose of this policy is to ensure that every financially relevant mismatch is converted into a governed reconciliation case that can be reviewed, escalated, resolved, audited, and linked to dispute, refund, cancellation, settlement, and provider risk evidence.

## 2. Scope

This policy applies to reconciliation involving:

* internal order ledger
* financial event ledger
* payment attempt records
* POS submission records
* provider payment approval records
* provider payment failure records
* provider cancellation records
* provider refund records
* POS order records
* POS cancellation records
* settlement files
* receipt evidence
* local ledger replay records
* callback records
* provider lookup records
* manual POS entry records
* manual recovery records
* dispute cases
* chargeback cases
* customer notification evidence
* staff action evidence

This policy applies before production settlement processing, refund/cancellation automation closure, dispute evidence packet finalization, or finance handoff.

## 3. Relationship_To_Previous_Documents

This document follows:

* `014104_Policy_POS_Gateway_Callback_Webhook_Provider_Lookup_And_Async_State_Reconciliation.md`

It also depends on:

* `014096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry.md`
* `014098_Policy_POS_Gateway_State_Machine_Payment_POS_Cancellation_Refund_And_Customer_Status.md`
* `014102_Policy_POS_Gateway_Idempotency_Retry_Duplicate_Prevention_And_Safe_Replay_Implementation.md`
* `014071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md`
* `014073_Policy_POS_Gateway_Offline_Degraded_Mode_Local_Ledger_Replay_And_Reconciliation.md`

The rule is:

> Reconciliation is the process that proves whether internal truth, provider truth, POS truth, and settlement truth agree.

## 4. Core_Principle

The POS Gateway must treat reconciliation as a first-class control, not as an accounting afterthought.

Reconciliation must be able to answer:

* Did the customer pay?
* Did the provider approve payment?
* Did the POS receive the order?
* Did the store fulfill the order?
* Was cancellation requested?
* Was cancellation completed?
* Was refund requested?
* Was refund completed?
* Did settlement match expected amount?
* Did manual recovery create a mismatch?
* Did local replay create or resolve a mismatch?
* Is the customer-facing status consistent with evidence?
* Is the staff-facing status consistent with evidence?
* Is a dispute or chargeback case required?

If these cannot be answered, the reconciliation case must remain open.

## 5. Reconciliation_Case_Types

The POS Gateway must classify reconciliation cases into standardized types.

Required case types include:

* `PAYMENT_PROVIDER_INTERNAL_MATCH`
* `PAYMENT_PROVIDER_INTERNAL_MISMATCH`
* `POS_INTERNAL_MATCH`
* `POS_INTERNAL_MISMATCH`
* `PROVIDER_POS_MISMATCH`
* `SETTLEMENT_INTERNAL_MATCH`
* `SETTLEMENT_INTERNAL_MISMATCH`
* `SETTLEMENT_PROVIDER_MISMATCH`
* `CANCELLATION_MISMATCH`
* `REFUND_MISMATCH`
* `PARTIAL_REFUND_MISMATCH`
* `DUPLICATE_PAYMENT_RECONCILIATION`
* `LOCAL_REPLAY_RECONCILIATION`
* `MANUAL_POS_ENTRY_RECONCILIATION`
* `MANUAL_RECOVERY_RECONCILIATION`
* `CALLBACK_LOOKUP_CONFLICT_RECONCILIATION`
* `RECEIPT_EVIDENCE_RECONCILIATION`
* `DISPUTE_LINKED_RECONCILIATION`
* `CHARGEBACK_LINKED_RECONCILIATION`

Each case type must define required evidence, owner, aging threshold, closure condition, and escalation path.

## 6. Reconciliation_Result_Classes

Required reconciliation result classes include:

* `MATCHED`
* `MATCHED_WITH_MINOR_TIMING_DIFFERENCE`
* `INTERNAL_ONLY`
* `PROVIDER_ONLY`
* `POS_ONLY`
* `SETTLEMENT_ONLY`
* `INTERNAL_PROVIDER_AMOUNT_MISMATCH`
* `INTERNAL_POS_AMOUNT_MISMATCH`
* `PROVIDER_SETTLEMENT_AMOUNT_MISMATCH`
* `STATUS_MISMATCH`
* `CANCEL_MISMATCH`
* `REFUND_MISMATCH`
* `PARTIAL_REFUND_MISMATCH`
* `DUPLICATE_APPROVAL_CONFIRMED`
* `DUPLICATE_APPROVAL_DISMISSED`
* `CALLBACK_LOOKUP_CONFLICT`
* `MANUAL_ACTION_REVIEW_REQUIRED`
* `PROVIDER_EVIDENCE_MISSING`
* `POS_EVIDENCE_MISSING`
* `SETTLEMENT_EVIDENCE_MISSING`
* `RECEIPT_EVIDENCE_ONLY`
* `DISPUTE_REQUIRED`
* `LEGAL_HOLD_REQUIRED`
* `MANUAL_REVIEW_REQUIRED`
* `UNRESOLVED`

`MATCHED` must not be assigned unless all required evidence for the route and operation is present or the missing evidence is explicitly non-required.

## 7. Matching_Dimensions

Reconciliation must compare the following dimensions where applicable.

### 7.1 Identity_Matching

Required identity matching fields include:

* tenant_id
* store_id
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* provider_transaction_id
* provider_cancellation_id
* provider_refund_id
* POS order reference
* receipt reference
* settlement reference
* correlation_id
* idempotency_key

### 7.2 Amount_Matching

Required amount matching fields include:

* internal order amount
* payment request amount
* provider approved amount
* provider cancelled amount
* provider refunded amount
* POS accepted amount
* POS cancelled amount
* settlement gross amount
* settlement net amount
* fee amount where available
* tax amount where available
* partial refund amount
* unresolved amount

### 7.3 Status_Matching

Required status matching fields include:

* internal payment state
* provider payment state
* POS submission state
* order acceptance state
* cancellation state
* refund state
* settlement state
* customer-facing state
* staff-facing state
* dispute state
* manual recovery state

### 7.4 Time_Matching

Required time matching fields include:

* customer order time
* payment request time
* provider approval time
* POS submission time
* POS acceptance time
* callback received time
* lookup time
* cancellation request time
* refund request time
* settlement file time
* reconciliation run time
* manual recovery time
* dispute opened time

Timing differences must be classified and must not automatically create financial mismatch unless threshold is exceeded.

## 8. Reconciliation_Triggers

Reconciliation must be triggered by:

* scheduled daily reconciliation
* payment unknown
* POS unknown
* cancellation unknown
* refund unknown
* duplicate payment suspicion
* provider callback missing
* provider lookup inconclusive
* callback lookup conflict
* settlement file intake
* provider-only record
* POS-only record
* internal-only record
* local ledger replay
* manual POS entry
* manual recovery
* customer dispute
* chargeback notice
* provider incident
* route rollback
* audit sample
* legal hold

## 9. Scheduled_Reconciliation

### 9.1 Daily_Reconciliation

The POS Gateway must support daily reconciliation for production routes.

Daily reconciliation must compare:

* internal financial event ledger
* payment attempts
* POS submissions
* provider payment records
* provider cancellation/refund records
* POS order/cancellation records
* settlement files where available
* dispute and chargeback records
* manual recovery records

### 9.2 Intraday_Reconciliation

Intraday reconciliation may be required for:

* high-volume route
* active provider incident
* duplicate payment risk
* refund/cancellation backlog
* settlement cut-off risk
* store pilot
* new provider rollout
* route rollback
* provider behavior re-verification

### 9.3 On_Demand_Reconciliation

On-demand reconciliation may be triggered by:

* support review
* customer complaint
* tenant request
* HQ compliance review
* finance review
* provider escalation
* dispute case
* chargeback case
* post-incident review

## 10. Payment_Reconciliation

### 10.1 Payment_Match_Rule

Payment may be considered matched when:

* internal payment attempt exists
* provider payment record exists where required
* amount matches
* currency matches
* provider reference matches or is explainably mapped
* status is consistent
* idempotency relationship is valid
* no duplicate approval exists
* no unresolved cancellation/refund conflict exists

### 10.2 Payment_Mismatch_Classes

Required payment mismatch classes include:

* `INTERNAL_PAYMENT_WITHOUT_PROVIDER`
* `PROVIDER_PAYMENT_WITHOUT_INTERNAL`
* `PAYMENT_AMOUNT_MISMATCH`
* `PAYMENT_STATUS_MISMATCH`
* `PAYMENT_REFERENCE_MISMATCH`
* `PAYMENT_DUPLICATE_APPROVAL`
* `PAYMENT_TIMEOUT_UNRESOLVED`
* `PAYMENT_CALLBACK_MISSING`
* `PAYMENT_LOOKUP_INCONCLUSIVE`
* `PAYMENT_CUSTOMER_STATUS_MISMATCH`

### 10.3 Payment_Mismatch_Response

Payment mismatch must:

* create or update reconciliation case
* set customer status conservatively if customer-impacting
* set staff status to review where needed
* trigger provider lookup if supported
* trigger dispute case if customer claim exists
* block unsafe retry
* block duplicate refund unless safe
* link to evidence packet where needed

## 11. POS_Reconciliation

### 11.1 POS_Match_Rule

POS may be considered matched when:

* internal order or POS submission exists
* POS order record exists where required
* POS reference is mapped
* amount and item summary match within allowed tolerance
* POS state is consistent with internal order state
* manual POS entry is linked if used
* no duplicate POS order exists
* cancellation state is consistent

### 11.2 POS_Mismatch_Classes

Required POS mismatch classes include:

* `INTERNAL_ORDER_WITHOUT_POS`
* `POS_ORDER_WITHOUT_INTERNAL`
* `POS_AMOUNT_MISMATCH`
* `POS_STATUS_MISMATCH`
* `POS_REFERENCE_MISMATCH`
* `POS_DUPLICATE_ORDER`
* `POS_MANUAL_ENTRY_UNLINKED`
* `POS_CANCELLATION_MISSING`
* `POS_ACCEPTED_PAYMENT_UNKNOWN`
* `PAYMENT_APPROVED_POS_UNKNOWN`

### 11.3 POS_Mismatch_Response

POS mismatch must:

* create or update reconciliation case
* update staff status to review
* protect customer status from false confirmation
* link manual POS entry evidence if used
* trigger POS lookup if supported
* trigger store manager review if operationally relevant
* link to dispute case if customer-impacting

## 12. Cancellation_Reconciliation

### 12.1 Cancellation_Match_Rule

Cancellation may be considered matched when:

* cancellation request exists
* POS cancellation evidence exists where required
* provider cancellation evidence exists where required
* refund relationship is resolved where applicable
* customer notification is consistent
* order preparation state is accounted for
* manual recovery is linked if used

### 12.2 Cancellation_Mismatch_Classes

Required cancellation mismatch classes include:

* `CANCEL_REQUEST_WITHOUT_PROVIDER_CANCEL`
* `CANCEL_REQUEST_WITHOUT_POS_CANCEL`
* `PROVIDER_CANCEL_WITHOUT_INTERNAL_REQUEST`
* `POS_CANCEL_WITHOUT_INTERNAL_REQUEST`
* `CANCEL_AMOUNT_MISMATCH`
* `CANCEL_STATUS_MISMATCH`
* `CANCEL_AFTER_FULFILLMENT_CONFLICT`
* `CANCEL_CUSTOMER_STATUS_MISMATCH`
* `CANCEL_REFUND_RELATIONSHIP_MISSING`

### 12.3 Cancellation_Mismatch_Response

Cancellation mismatch must:

* keep cancellation state pending, unknown, or review
* avoid customer completion message without evidence
* trigger provider/POS lookup where supported
* create dispute case if customer claim exists
* create refund review if payment was affected
* require owner closure

## 13. Refund_Reconciliation

### 13.1 Refund_Match_Rule

Refund may be considered matched when:

* refund request exists
* provider refund evidence exists where required
* refund amount matches
* refund type matches
* original payment exists
* partial refund cumulative amount is valid
* customer notification is consistent
* settlement effect is accounted for

### 13.2 Refund_Mismatch_Classes

Required refund mismatch classes include:

* `REFUND_REQUEST_WITHOUT_PROVIDER_REFUND`
* `PROVIDER_REFUND_WITHOUT_INTERNAL_REQUEST`
* `REFUND_AMOUNT_MISMATCH`
* `REFUND_STATUS_MISMATCH`
* `PARTIAL_REFUND_LIMIT_EXCEEDED`
* `REFUND_CUSTOMER_STATUS_MISMATCH`
* `REFUND_SETTLEMENT_MISMATCH`
* `REFUND_DUPLICATE_RISK`
* `REFUND_PROVIDER_UNKNOWN`

### 13.3 Refund_Mismatch_Response

Refund mismatch must:

* prevent refund completed status without evidence
* trigger provider lookup where supported
* create or update dispute case if customer-impacting
* block duplicate refund unless safe
* link to settlement review
* require owner closure

## 14. Settlement_Matching

### 14.1 Settlement_Match_Rule

Settlement may be considered matched when:

* provider settlement record exists
* internal payment/refund/cancellation records exist
* amount matches expected settlement logic
* fee and net amount are explainable where available
* store and tenant mapping are correct
* settlement date matches expected window
* no unresolved dispute or chargeback affects the record
* no unresolved refund/cancellation mismatch affects the record

### 14.2 Settlement_Mismatch_Classes

Required settlement mismatch classes include:

* `SETTLEMENT_FILE_MISSING`
* `SETTLEMENT_RECORD_WITHOUT_INTERNAL`
* `INTERNAL_RECORD_WITHOUT_SETTLEMENT`
* `SETTLEMENT_GROSS_AMOUNT_MISMATCH`
* `SETTLEMENT_NET_AMOUNT_MISMATCH`
* `SETTLEMENT_FEE_MISMATCH`
* `SETTLEMENT_DATE_MISMATCH`
* `SETTLEMENT_STORE_MAPPING_MISMATCH`
* `SETTLEMENT_REFUND_MISSING`
* `SETTLEMENT_CANCELLATION_MISSING`
* `SETTLEMENT_CHARGEBACK_IMPACT`
* `SETTLEMENT_PROVIDER_DELAY`

### 14.3 Settlement_Response

Settlement mismatch must:

* create finance review case
* link affected payment/refund/cancellation records
* link provider settlement evidence
* link dispute or chargeback case where applicable
* prevent final finance closure until classified
* update provider risk register if repeated

## 15. Manual_Recovery_Reconciliation

Manual recovery must be reconciled against provider, POS, and internal evidence.

Required checks include:

* who performed manual recovery
* what state existed before action
* what state changed after action
* whether provider evidence later confirmed or contradicted it
* whether POS evidence later confirmed or contradicted it
* whether customer was notified
* whether financial state was affected
* whether refund/cancellation was affected
* whether dispute case is required

Manual recovery must not be treated as final reconciliation by itself.

## 16. Local_Replay_Reconciliation

Local replay must create reconciliation evidence.

Required checks include:

* local ledger record
* replay attempt
* idempotency result
* provider response
* POS response
* duplicate risk
* replay conflict
* customer status update
* staff status update
* final reconciliation result

Local replay result must remain open if provider/POS/internal evidence cannot be matched.

## 17. Reconciliation_Case_Lifecycle

Reconciliation cases must support the following lifecycle states:

* `RECONCILIATION_NOT_REQUIRED`
* `RECONCILIATION_REQUIRED`
* `RECONCILIATION_OPEN`
* `RECONCILIATION_IN_PROGRESS`
* `PROVIDER_LOOKUP_PENDING`
* `POS_LOOKUP_PENDING`
* `FINANCE_REVIEW_PENDING`
* `STORE_REVIEW_PENDING`
* `COMPLIANCE_REVIEW_PENDING`
* `DISPUTE_LINKED`
* `MANUAL_REVIEW_REQUIRED`
* `RESOLVED_MATCHED`
* `RESOLVED_CORRECTED`
* `RESOLVED_ACCEPTED_DIFFERENCE`
* `RESOLVED_PROVIDER_ERROR`
* `RESOLVED_POS_ERROR`
* `RESOLVED_INTERNAL_ERROR`
* `UNRESOLVED`
* `LEGAL_HOLD`

## 18. Reconciliation_Case_Closure

A reconciliation case may be closed only when:

* mismatch class is assigned
* evidence sources are attached
* affected customer status is corrected
* affected staff status is corrected
* refund/cancellation state is corrected where needed
* dispute case is opened if customer-impacting
* finance review is complete where settlement is affected
* provider risk register is updated where repeated provider issue exists
* manual correction event is written if correction occurred
* closure reason is recorded
* owner approval is recorded

A reconciliation case must not be closed only because the dashboard warning disappeared.

## 19. Reconciliation_Aging_And_Escalation

Suggested aging thresholds:

* 10 minutes: operational warning
* 30 minutes: support review
* 2 hours: compliance or operations queue
* 1 business day: finance review
* 3 business days: management review
* 7 business days: legal/compliance review

Thresholds must be provider-route-specific where required.

Escalation must consider:

* customer impact
* financial amount
* store count
* tenant count
* provider route
* dispute or chargeback deadline
* settlement deadline
* legal hold status

## 20. Reconciliation_Data_Model_Requirements

The implementation must support the following logical records.

### 20.1 Reconciliation_Case

Required fields:

* reconciliation_case_id
* case_type
* result_class
* tenant_id
* store_id
* provider_id
* provider_route_id
* order_id
* payment_attempt_id
* pos_submission_id
* cancellation_action_id
* refund_action_id
* settlement_reference
* dispute_case_id
* chargeback_case_id
* severity
* status
* owner_role
* owner_id
* opened_at
* due_at
* resolved_at
* closure_reason
* closure_evidence_reference

### 20.2 Reconciliation_Match_Item

Required fields:

* reconciliation_match_item_id
* reconciliation_case_id
* source_type
* source_reference
* source_status
* source_amount
* source_currency
* source_timestamp
* provider_reference
* pos_reference
* internal_reference
* match_status
* mismatch_reason
* evidence_reference

### 20.3 Settlement_Record

Required fields:

* settlement_record_id
* provider_id
* provider_route_id
* tenant_id
* store_id
* settlement_file_reference
* provider_transaction_reference
* gross_amount
* net_amount
* fee_amount
* currency
* settlement_date
* settlement_status
* matched_payment_attempt_id
* matched_refund_action_id
* matched_cancellation_action_id
* reconciliation_case_id
* evidence_reference
* status

### 20.4 Reconciliation_Action_Record

Required fields:

* reconciliation_action_id
* reconciliation_case_id
* action_type
* actor_type
* actor_id
* reason_code
* before_state
* after_state
* evidence_reference
* customer_status_changed
* staff_status_changed
* dispute_case_created
* provider_risk_updated
* created_at
* status

### 20.5 Reconciliation_Batch

Required fields:

* reconciliation_batch_id
* provider_id
* provider_route_id
* tenant_id
* store_id
* batch_type
* batch_window_start
* batch_window_end
* started_at
* completed_at
* total_items
* matched_items
* mismatched_items
* unresolved_items
* opened_case_count
* owner
* status

## 21. Access_Control

Reconciliation records must be access-controlled.

### 21.1 Store_Staff

Store staff may view:

* operational review required indicator
* customer-safe guidance
* allowed action
* blocked action
* manager escalation path

Store staff must not close reconciliation cases.

### 21.2 Store_Manager

Store manager may view:

* store-scoped reconciliation cases
* manual POS entry linkage
* operational mismatch summary
* staff action evidence
* escalation requirement

Store manager must not close financial mismatch unless authorized.

### 21.3 Tenant_Admin

Tenant admin may view:

* tenant-scoped reconciliation summary
* store mismatch counts
* refund/cancellation aging summary
* settlement issue summary subject to permission
* provider issue summary

Tenant admin must not access cross-tenant reconciliation evidence.

### 21.4 HQ_Finance

HQ finance may view and manage:

* settlement records
* settlement mismatch cases
* refund/cancellation financial impact
* provider-only records
* internal-only records
* unresolved amount exposure
* finance closure evidence

### 21.5 HQ_Compliance

HQ compliance may view and manage:

* customer-impacting reconciliation
* dispute-linked reconciliation
* chargeback-linked reconciliation
* manual override reconciliation
* legal hold cases
* audit evidence

### 21.6 Developer

Developer production access must be masked, ticket-linked, and logged.

Developers must not alter reconciliation outcomes directly.

## 22. Observability_Requirements

The system must monitor:

* reconciliation case count
* open reconciliation case count
* unresolved reconciliation case count
* reconciliation aging
* payment mismatch count
* POS mismatch count
* provider POS mismatch count
* cancellation mismatch count
* refund mismatch count
* settlement mismatch count
* duplicate approval confirmed count
* provider-only record count
* internal-only record count
* POS-only record count
* manual recovery reconciliation count
* local replay reconciliation count
* dispute-linked reconciliation count
* legal hold reconciliation count

Metrics must be tagged by:

* provider_id
* provider_route_id
* tenant_id
* store_id
* channel_id
* operation_type
* mismatch_class

## 23. Test_Requirements

The implementation must support tests for:

* internal payment without provider creates reconciliation case
* provider payment without internal creates reconciliation case
* payment amount mismatch is classified
* POS accepted payment unknown creates reconciliation case
* payment approved POS unknown creates reconciliation case
* cancellation request without provider cancellation remains open
* refund request without provider refund remains open
* settlement provider-only record creates finance review
* manual POS entry links to reconciliation
* local replay conflict creates reconciliation case
* duplicate payment reconciliation distinguishes confirmed and dismissed
* reconciliation closure requires evidence
* reconciliation closure updates customer/staff status where needed
* reconciliation cannot be closed by store staff
* legal hold blocks closure
* provider repeated mismatch updates risk register

## 24. Readiness_Checklist

Before production settlement matching, refund/cancellation closure, or finance handoff can be implemented, the following checklist must pass.

### 24.1 Case_Model

* [ ] Reconciliation case types are defined.
* [ ] Reconciliation result classes are defined.
* [ ] Reconciliation lifecycle is defined.
* [ ] Case closure rules are defined.
* [ ] Aging and escalation rules are defined.

### 24.2 Matching

* [ ] Identity matching dimensions are defined.
* [ ] Amount matching dimensions are defined.
* [ ] Status matching dimensions are defined.
* [ ] Time matching dimensions are defined.
* [ ] Payment matching rules are defined.
* [ ] POS matching rules are defined.
* [ ] Cancellation matching rules are defined.
* [ ] Refund matching rules are defined.
* [ ] Settlement matching rules are defined.

### 24.3 Evidence_And_Control

* [ ] Manual recovery reconciliation is defined.
* [ ] Local replay reconciliation is defined.
* [ ] Customer/staff status correction is required where needed.
* [ ] Dispute linkage is required where customer-impacting.
* [ ] Finance review is required where settlement-impacting.
* [ ] Provider risk linkage is defined.
* [ ] Closure requires owner approval.

### 24.4 Data_And_Access

* [ ] Reconciliation case model exists.
* [ ] Reconciliation match item model exists.
* [ ] Settlement record model exists.
* [ ] Reconciliation action record exists.
* [ ] Reconciliation batch model exists.
* [ ] Access control is defined.
* [ ] Observability metrics are defined.
* [ ] Tests are defined.

## 25. Non_Goals

This policy does not define:

* final accounting journal posting
* final tax filing process
* final settlement payout process
* final provider-specific settlement parser
* final finance dashboard UI
* final dispute compensation policy
* final legal recovery process
* final database SQL implementation

Those must be handled by accounting, finance, provider-specific, legal, UI, and implementation documents.

This policy defines the POS Gateway reconciliation and settlement matching boundary required before finance-grade operation.

## 26. Acceptance_Criteria

This policy is accepted when:

* reconciliation case model is defined
* reconciliation result classes are defined
* payment matching rules are defined
* POS matching rules are defined
* cancellation matching rules are defined
* refund matching rules are defined
* settlement matching rules are defined
* provider-only, POS-only, internal-only, and settlement-only cases are classified
* manual recovery requires reconciliation
* local replay requires reconciliation
* reconciliation closure requires evidence
* reconciliation closure can update customer and staff status safely
* finance review is required for settlement-impacting cases
* dispute linkage is required for customer-impacting cases
* provider repeated mismatch updates provider risk register
* reconciliation records are observable and access-controlled

## 27. Final_Rule

Reconciliation is not a report.

It is the control that prevents payment, POS, provider, settlement, staff, and customer-facing truth from drifting apart.

If the POS Gateway cannot reconcile a transaction, it must not pretend the transaction is settled, resolved, refunded, cancelled, or undisputed.
