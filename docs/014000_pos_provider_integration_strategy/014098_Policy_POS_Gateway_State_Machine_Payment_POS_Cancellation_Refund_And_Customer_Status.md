# 014098_Policy_POS_Gateway_State_Machine_Payment_POS_Cancellation_Refund_And_Customer_Status

## 1. Purpose

This document defines the POS Gateway state machine policy for payment, POS submission, order acceptance, cancellation, refund, duplicate payment review, customer-facing status, and staff-facing status.

The POS Gateway must not treat provider response fields, POS response fields, customer screen labels, or staff screen labels as the same state.

The purpose of this policy is to define controlled state transitions so that payment, POS confirmation, cancellation, refund, customer notification, staff action, dispute evidence, reconciliation, and provider replay remain consistent.

## 2. Scope

This policy applies to all POS Gateway state transitions involving:

* payment attempt
* payment authorization
* payment failure
* payment timeout
* payment unknown
* duplicate payment suspicion
* POS submission
* POS acceptance
* POS rejection
* POS unknown
* order acceptance
* order confirmation
* order rejection
* cancellation request
* POS cancellation
* provider cancellation
* cancellation unknown
* refund request
* refund provider response
* refund unknown
* partial refund
* customer status projection
* staff status projection
* manual recovery state
* dispute case linkage
* reconciliation linkage

This policy applies before provider-specific adapter implementation, refund automation, cancellation automation, kiosk payment reuse, mini-kiosk payment reuse, or store pilot.

## 3. Relationship_To_Previous_Documents

This document follows:

* `014096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry.md`

It depends on the core data model defined in that document, especially:

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

The rule is:

> Data models store state.
> State machines govern how state may change.

## 4. Core_Principle

The POS Gateway must separate the following state layers:

* internal financial state
* provider state
* POS state
* customer-facing state
* staff-facing state
* reconciliation state
* dispute state

A transition in one layer must not automatically imply final truth in another layer unless the mapping is explicitly allowed.

Examples:

* provider payment approved does not automatically mean POS order accepted
* customer order received does not mean payment approved
* cancellation requested does not mean cancellation completed
* refund requested does not mean refund completed
* POS accepted does not mean settlement matched
* staff note does not mean financial truth
* local ledger capture does not mean provider success

## 5. State_Machine_Families

The POS Gateway must define at minimum the following state machines:

* `Payment_Attempt_State_Machine`
* `POS_Submission_State_Machine`
* `Order_Acceptance_State_Machine`
* `Cancellation_State_Machine`
* `Refund_State_Machine`
* `Duplicate_Payment_State_Machine`
* `Customer_Status_State_Machine`
* `Staff_Status_State_Machine`
* `Manual_Recovery_State_Machine`
* `Reconciliation_State_Linkage`
* `Dispute_State_Linkage`

Each state machine must define:

* allowed states
* allowed transitions
* blocked transitions
* trigger events
* required evidence
* idempotency requirement
* customer status impact
* staff status impact
* reconciliation impact
* dispute impact

## 6. Payment_Attempt_State_Machine

### 6.1 Required_States

The payment attempt state machine must support:

* `PAYMENT_NOT_STARTED`
* `PAYMENT_REQUESTED`
* `PAYMENT_PROVIDER_PENDING`
* `PAYMENT_APPROVED`
* `PAYMENT_FAILED`
* `PAYMENT_TIMEOUT`
* `PAYMENT_UNKNOWN`
* `PAYMENT_DUPLICATE_SUSPECTED`
* `PAYMENT_CANCEL_REQUESTED`
* `PAYMENT_CANCEL_PENDING`
* `PAYMENT_CANCELLED`
* `PAYMENT_REFUND_REQUESTED`
* `PAYMENT_REFUND_PENDING`
* `PAYMENT_REFUNDED`
* `PAYMENT_DISPUTED`
* `PAYMENT_MANUAL_REVIEW_REQUIRED`

### 6.2 Allowed_Transitions

Allowed transitions include:

* `PAYMENT_NOT_STARTED` to `PAYMENT_REQUESTED`
* `PAYMENT_REQUESTED` to `PAYMENT_PROVIDER_PENDING`
* `PAYMENT_PROVIDER_PENDING` to `PAYMENT_APPROVED`
* `PAYMENT_PROVIDER_PENDING` to `PAYMENT_FAILED`
* `PAYMENT_PROVIDER_PENDING` to `PAYMENT_TIMEOUT`
* `PAYMENT_TIMEOUT` to `PAYMENT_UNKNOWN`
* `PAYMENT_UNKNOWN` to `PAYMENT_APPROVED`
* `PAYMENT_UNKNOWN` to `PAYMENT_FAILED`
* `PAYMENT_UNKNOWN` to `PAYMENT_MANUAL_REVIEW_REQUIRED`
* `PAYMENT_APPROVED` to `PAYMENT_CANCEL_REQUESTED`
* `PAYMENT_CANCEL_REQUESTED` to `PAYMENT_CANCEL_PENDING`
* `PAYMENT_CANCEL_PENDING` to `PAYMENT_CANCELLED`
* `PAYMENT_CANCEL_PENDING` to `PAYMENT_UNKNOWN`
* `PAYMENT_APPROVED` to `PAYMENT_REFUND_REQUESTED`
* `PAYMENT_REFUND_REQUESTED` to `PAYMENT_REFUND_PENDING`
* `PAYMENT_REFUND_PENDING` to `PAYMENT_REFUNDED`
* `PAYMENT_REFUND_PENDING` to `PAYMENT_UNKNOWN`
* any unresolved state to `PAYMENT_DISPUTED`
* any ambiguous state to `PAYMENT_MANUAL_REVIEW_REQUIRED`

### 6.3 Blocked_Transitions

Blocked transitions include:

* `PAYMENT_NOT_STARTED` directly to `PAYMENT_APPROVED`
* `PAYMENT_REQUESTED` directly to `PAYMENT_REFUNDED`
* `PAYMENT_TIMEOUT` directly to `PAYMENT_FAILED` without provider lookup or evidence
* `PAYMENT_UNKNOWN` directly to `PAYMENT_APPROVED` without provider evidence
* `PAYMENT_UNKNOWN` directly to `PAYMENT_FAILED` without provider evidence or authorized resolution
* `PAYMENT_REFUND_PENDING` directly to `PAYMENT_REFUNDED` without provider refund evidence or authorized compliance resolution
* `PAYMENT_CANCEL_PENDING` directly to `PAYMENT_CANCELLED` without provider cancellation evidence or authorized compliance resolution
* `PAYMENT_DUPLICATE_SUSPECTED` directly to normal success without reconciliation or authorized resolution

### 6.4 Required_Evidence_By_Transition

Payment transitions must preserve evidence.

Required evidence includes:

* payment request event
* provider route reference
* idempotency key
* request payload hash
* provider response reference
* provider transaction identifier if available
* timeout evidence if applicable
* provider lookup evidence if applicable
* manual resolution evidence if applicable
* customer notification evidence if status is customer-visible
* reconciliation marker if ambiguity remains

## 7. POS_Submission_State_Machine

### 7.1 Required_States

The POS submission state machine must support:

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

### 7.2 Allowed_Transitions

Allowed transitions include:

* `POS_NOT_SUBMITTED` to `POS_SUBMISSION_REQUESTED`
* `POS_SUBMISSION_REQUESTED` to `POS_SUBMISSION_PENDING`
* `POS_SUBMISSION_PENDING` to `POS_ACCEPTED`
* `POS_SUBMISSION_PENDING` to `POS_REJECTED`
* `POS_SUBMISSION_PENDING` to `POS_TIMEOUT`
* `POS_TIMEOUT` to `POS_UNKNOWN`
* `POS_UNKNOWN` to `POS_ACCEPTED`
* `POS_UNKNOWN` to `POS_REJECTED`
* `POS_UNKNOWN` to `POS_MANUAL_ENTRY_REQUIRED`
* `POS_MANUAL_ENTRY_REQUIRED` to `POS_MANUAL_ENTRY_RECORDED`
* `POS_UNKNOWN` to `POS_REPLAY_PENDING`
* `POS_REPLAY_PENDING` to `POS_ACCEPTED`
* `POS_REPLAY_PENDING` to `POS_RECONCILIATION_REQUIRED`
* any unresolved POS state to `POS_DISPUTED`

### 7.3 Blocked_Transitions

Blocked transitions include:

* `POS_NOT_SUBMITTED` directly to `POS_ACCEPTED`
* `POS_TIMEOUT` directly to `POS_REJECTED` without lookup or evidence
* `POS_UNKNOWN` directly to `POS_ACCEPTED` without POS evidence, replay success, or authorized manual evidence
* `POS_MANUAL_ENTRY_RECORDED` replacing the original internal order
* `POS_REPLAY_PENDING` directly to success without idempotency and conflict checks
* `POS_RECONCILIATION_REQUIRED` directly to closed without reconciliation evidence

### 7.4 Required_Evidence_By_Transition

POS transitions must preserve:

* POS submission request event
* provider route reference
* idempotency key
* POS request payload hash
* POS response reference
* POS order identifier if available
* POS timeout evidence if applicable
* POS lookup evidence if available
* manual entry evidence if used
* reconciliation marker if unresolved

## 8. Order_Acceptance_State_Machine

### 8.1 Required_States

The order acceptance state machine must support:

* `ORDER_DRAFT`
* `ORDER_RECEIVED`
* `ORDER_PAYMENT_PENDING`
* `ORDER_PAYMENT_APPROVED`
* `ORDER_POS_PENDING`
* `ORDER_POS_ACCEPTED`
* `ORDER_STORE_REVIEW_REQUIRED`
* `ORDER_ACCEPTED`
* `ORDER_REJECTED`
* `ORDER_CANCEL_REQUESTED`
* `ORDER_CANCELLED`
* `ORDER_FULFILLMENT_STARTED`
* `ORDER_FULFILLED`
* `ORDER_AMBIGUOUS`
* `ORDER_DISPUTED`

### 8.2 Acceptance_Rule

An order may be marked `ORDER_ACCEPTED` only when the required acceptance conditions for the route are satisfied.

Depending on route policy, acceptance may require:

* payment approved
* POS accepted
* store confirmation
* kitchen ticket created
* manual manager approval
* fallback route evidence

The required acceptance rule must be route-specific and versioned.

### 8.3 Ambiguous_Order_Rule

If payment and POS/order states conflict, the order must enter an ambiguity or review state.

Examples:

* payment approved but POS unknown
* POS accepted but payment unknown
* order received but provider callback missing
* staff manually entered POS order but gateway payment unknown
* customer sees order received but store sees no POS order

Ambiguous order state must create staff-visible and support-visible review signals.

## 9. Cancellation_State_Machine

### 9.1 Required_States

The cancellation state machine must support:

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

### 9.2 Completion_Rule

Cancellation may be marked `CANCEL_COMPLETED` only when the required cancellation evidence exists.

Depending on route, required evidence may include:

* provider cancellation accepted
* POS cancellation accepted
* order preparation state permits cancellation
* refund action completed or not required
* manager or HQ approval where required
* reconciliation marker where provider/POS finality is delayed

### 9.3 Blocked_Transitions

Blocked cancellation transitions include:

* `CANCEL_REQUESTED` directly to `CANCEL_COMPLETED` without evidence
* `CANCEL_PROVIDER_PENDING` directly to completed without provider evidence
* `CANCEL_POS_PENDING` directly to completed without POS evidence
* `CANCEL_UNKNOWN` directly to completed without lookup, reconciliation, or authorized resolution
* `CANCEL_FAILED` directly to completed without new action
* `CANCEL_DISPUTED` directly to closed without evidence packet

## 10. Refund_State_Machine

### 10.1 Required_States

The refund state machine must support:

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

### 10.2 Completion_Rule

Refund may be marked `REFUND_COMPLETED` only when provider evidence, reconciliation evidence, or authorized compliance resolution exists.

A refund request is not refund completion.

### 10.3 Blocked_Transitions

Blocked refund transitions include:

* `REFUND_REQUESTED` directly to `REFUND_COMPLETED` without provider or authorized evidence
* `REFUND_PROVIDER_PENDING` directly to completed without provider evidence
* `REFUND_UNKNOWN` directly to completed without lookup, reconciliation, or authorized resolution
* `REFUND_FAILED` directly to completed without new refund action
* `REFUND_PROVIDER_REJECTED` directly to completed without new provider action or manual resolution
* `REFUND_DISPUTED` directly to closed without evidence packet

## 11. Duplicate_Payment_State_Machine

### 11.1 Required_States

The duplicate payment state machine must support:

* `DUPLICATE_NOT_SUSPECTED`
* `DUPLICATE_SIGNAL_DETECTED`
* `DUPLICATE_REVIEW_REQUIRED`
* `DUPLICATE_PROVIDER_LOOKUP_REQUIRED`
* `DUPLICATE_RECONCILIATION_REQUIRED`
* `DUPLICATE_CONFIRMED`
* `DUPLICATE_DISMISSED`
* `DUPLICATE_REFUND_REQUIRED`
* `DUPLICATE_REFUND_PENDING`
* `DUPLICATE_RESOLVED`
* `DUPLICATE_DISPUTED`

### 11.2 Detection_Triggers

Duplicate suspicion may be triggered by:

* same idempotency key conflict
* same order and multiple provider approvals
* same customer and amount within short window
* same device and amount within short window
* same POS order with multiple payments
* provider duplicate callback
* staff report
* customer claim
* reconciliation mismatch

### 11.3 Blocked_Transitions

Blocked transitions include:

* duplicate suspicion directly to resolved without review
* duplicate confirmed directly to resolved without refund or compensation decision
* duplicate dismissed without evidence
* duplicate refund required directly to resolved without refund evidence
* duplicate disputed directly to closed without evidence packet

## 12. Customer_Status_State_Machine

### 12.1 Required_Statuses

Customer-facing status must support:

* `ORDER_RECEIVED`
* `PAYMENT_PENDING`
* `PAYMENT_APPROVED`
* `PAYMENT_CONFIRMATION_PENDING`
* `PAYMENT_FAILED`
* `ORDER_CONFIRMATION_PENDING`
* `ORDER_CONFIRMED`
* `STORE_REVIEW_REQUIRED`
* `CANCEL_REQUEST_RECEIVED`
* `CANCEL_CONFIRMATION_PENDING`
* `CANCEL_COMPLETED`
* `CANCEL_FAILED`
* `REFUND_REQUEST_RECEIVED`
* `REFUND_CONFIRMATION_PENDING`
* `REFUND_COMPLETED`
* `REFUND_FAILED`
* `DUPLICATE_PAYMENT_UNDER_REVIEW`
* `SUPPORT_REVIEW_REQUIRED`
* `ROUTE_TEMPORARILY_UNAVAILABLE`

### 12.2 Customer_Status_Mapping_Rule

Customer status must be derived from internal state and evidence confidence.

Examples:

* `PAYMENT_REQUESTED` may map to `PAYMENT_PENDING`
* `PAYMENT_TIMEOUT` may map to `PAYMENT_CONFIRMATION_PENDING`
* `PAYMENT_UNKNOWN` may map to `PAYMENT_CONFIRMATION_PENDING` or `SUPPORT_REVIEW_REQUIRED`
* `POS_UNKNOWN` may map to `ORDER_CONFIRMATION_PENDING` or `STORE_REVIEW_REQUIRED`
* `CANCEL_REQUESTED` must map to `CANCEL_REQUEST_RECEIVED`
* `CANCEL_PROVIDER_PENDING` must map to `CANCEL_CONFIRMATION_PENDING`
* `REFUND_REQUESTED` must map to `REFUND_REQUEST_RECEIVED`
* `REFUND_PROVIDER_PENDING` must map to `REFUND_CONFIRMATION_PENDING`
* `DUPLICATE_PAYMENT_REVIEW` must map to `DUPLICATE_PAYMENT_UNDER_REVIEW`

### 12.3 Prohibited_Customer_Status

Customer status must not show:

* payment approved unless payment evidence exists
* order confirmed unless order acceptance evidence exists
* cancellation completed unless cancellation completion evidence exists
* refund completed unless refund completion evidence exists
* duplicate resolved unless reconciliation or authorized resolution exists
* failed payment when provider result is unknown
* failed refund when refund result is unknown
* failed cancellation when cancellation result is unknown

## 13. Staff_Status_State_Machine

### 13.1 Required_Statuses

Staff-facing status must support:

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

### 13.2 Staff_Action_Binding

Every staff-facing status must bind to:

* allowed actions
* blocked actions
* escalation requirement
* runbook reference
* evidence capture requirement

Examples:

* `PAYMENT_UNKNOWN` must block asking customer to pay again unless support-approved
* `DUPLICATE_PAYMENT_REVIEW` must block unsafe payment retry
* `REFUND_PENDING` must block marking refund complete
* `CANCEL_PENDING` must block marking cancellation complete
* `ORDER_POS_UNKNOWN` must show store review or support escalation path
* `LOCAL_REPLAY_PENDING` must block manual replay by staff

## 14. Manual_Recovery_State_Machine

### 14.1 Required_States

Manual recovery must support:

* `MANUAL_RECOVERY_NOT_REQUIRED`
* `MANUAL_RECOVERY_RECOMMENDED`
* `MANUAL_RECOVERY_REQUESTED`
* `MANUAL_RECOVERY_MANAGER_REVIEW`
* `MANUAL_RECOVERY_HQ_REVIEW`
* `MANUAL_RECOVERY_APPROVED`
* `MANUAL_RECOVERY_REJECTED`
* `MANUAL_RECOVERY_EXECUTED`
* `MANUAL_RECOVERY_RECONCILIATION_REQUIRED`
* `MANUAL_RECOVERY_DISPUTED`

### 14.2 Manual_Recovery_Rule

Manual recovery may not directly alter final financial truth unless the action is explicitly authorized.

Manual recovery must:

* create manual override record
* create financial event if financially relevant
* require reason code
* require actor attribution
* require evidence attachment where applicable
* require reconciliation if provider/POS state remains ambiguous
* update staff status
* update customer status conservatively

## 15. Reconciliation_State_Linkage

State machines must link unresolved or conflicting states to reconciliation.

Reconciliation must be required when:

* payment unknown persists
* POS unknown persists
* cancellation unknown persists
* refund unknown persists
* duplicate payment suspected
* provider-only record appears
* POS-only record appears
* internal-only record appears
* amount mismatch occurs
* status mismatch occurs
* manual recovery changes operational state
* local replay occurred
* settlement mismatch occurs

A reconciliation-required state must not be silently closed.

## 16. Dispute_State_Linkage

State machines must link customer-impacting ambiguity to dispute cases.

Dispute case may be required when:

* customer claims paid but order unconfirmed
* customer claims refund missing
* customer claims cancellation missing
* duplicate payment suspected
* provider evidence missing
* POS evidence missing
* staff manual recovery is contested
* customer-facing status was wrong
* chargeback notice received

Dispute closure must require evidence packet reference.

## 17. Transition_Event_Requirement

Every state transition must create or reference an event.

Required transition event fields include:

* event_type
* source_state
* target_state
* trigger_source
* actor_type
* actor_id
* provider_route_id
* idempotency_key
* correlation_id
* evidence_reference
* reason_code
* occurred_at
* recorded_at

A current state update without a transition event must be treated as projection corruption or unauthorized mutation.

## 18. State_Confidence_Level

The POS Gateway must classify state confidence.

Required confidence levels include:

* `CONFIRMED_BY_INTERNAL_EVENT`
* `CONFIRMED_BY_PROVIDER`
* `CONFIRMED_BY_POS`
* `CONFIRMED_BY_RECONCILIATION`
* `CONFIRMED_BY_AUTHORIZED_MANUAL_REVIEW`
* `PENDING_PROVIDER`
* `PENDING_POS`
* `UNKNOWN`
* `CONFLICTED`
* `DISPUTED`

Customer and staff status must consider confidence level.

## 19. Route_Specific_State_Mapping

Each provider route must define its own mapping from provider states to internal states.

Mapping must include:

* provider raw state
* internal state
* confidence level
* required evidence
* allowed customer status
* allowed staff status
* reconciliation requirement
* dispute requirement
* unsupported state handling

Unknown provider state must map to an unsafe or review state, not success.

## 20. Kiosk_And_Mini_Kiosk_State_ReUse

Kiosk and mini-kiosk routes must reuse the POS Gateway state machines.

They must not define separate payment truth.

Required reuse areas include:

* payment attempt state
* payment unknown state
* duplicate payment state
* order confirmation pending state
* cancellation/refund state
* customer-facing conservative status
* staff-facing review status
* dispute case linkage
* reconciliation linkage

Kiosk-specific UI may differ, but financial truth must not.

## 21. Test_Requirements

The implementation must support tests for:

* payment timeout becomes unknown, not failed
* payment unknown cannot become approved without evidence
* refund requested cannot become completed without evidence
* cancellation requested cannot become completed without evidence
* POS timeout becomes POS unknown, not rejected
* duplicate payment suspicion blocks unsafe retry
* customer status remains conservative
* staff status shows allowed and blocked actions
* manual recovery creates audit event
* provider unknown state maps to review
* projection update requires source event
* dispute closure requires evidence packet
* reconciliation-required state cannot be silently closed

## 22. Readiness_Checklist

Before provider adapter implementation or refund/cancellation automation, the following checklist must pass.

### 22.1 Payment

* [ ] Payment states are defined.
* [ ] Payment transitions are defined.
* [ ] Payment blocked transitions are defined.
* [ ] Payment timeout handling is defined.
* [ ] Payment unknown handling is defined.
* [ ] Duplicate payment suspicion is defined.
* [ ] Payment transition evidence is required.

### 22.2 POS

* [ ] POS submission states are defined.
* [ ] POS transitions are defined.
* [ ] POS blocked transitions are defined.
* [ ] POS timeout handling is defined.
* [ ] POS unknown handling is defined.
* [ ] Manual POS entry linkage is defined.
* [ ] POS transition evidence is required.

### 22.3 Cancellation_And_Refund

* [ ] Cancellation states are defined.
* [ ] Cancellation completion rule is defined.
* [ ] Cancellation blocked transitions are defined.
* [ ] Refund states are defined.
* [ ] Refund completion rule is defined.
* [ ] Refund blocked transitions are defined.
* [ ] Requested and completed states are separated.

### 22.4 Customer_And_Staff_Status

* [ ] Customer statuses are defined.
* [ ] Customer prohibited status rules are defined.
* [ ] Staff statuses are defined.
* [ ] Staff allowed actions are bound to status.
* [ ] Staff blocked actions are bound to status.
* [ ] Customer and staff statuses consider confidence level.

### 22.5 Linkage

* [ ] Reconciliation linkage is defined.
* [ ] Dispute linkage is defined.
* [ ] Manual recovery linkage is defined.
* [ ] Route-specific state mapping is required.
* [ ] Kiosk and mini-kiosk reuse is required.
* [ ] Transition events are required.

## 23. Non_Goals

This policy does not define:

* final database enum syntax
* final API response schema
* final UI text
* final customer message templates
* final provider-specific mapping table
* final POS provider adapter
* final payment provider adapter
* final reconciliation implementation
* final dispute packet implementation

Those must be handled by implementation, provider-specific, UI, support, and test documents.

This policy defines the state machine boundary required before provider-specific POS Gateway behavior is implemented.

## 24. Acceptance_Criteria

This policy is accepted when:

* payment state machine is defined
* POS submission state machine is defined
* order acceptance state machine is defined
* cancellation state machine is defined
* refund state machine is defined
* duplicate payment state machine is defined
* customer status mapping is conservative
* staff status mapping separates operational and financial truth
* blocked transitions are explicit
* state confidence level is defined
* every transition requires an event
* reconciliation-required states cannot be silently closed
* dispute-required states link to evidence packet
* provider-specific states must map through internal state machine
* kiosk and mini-kiosk routes reuse the same financial state machine

## 25. Final_Rule

A POS Gateway state is not a label.

It is a governed claim about what the system knows, what it does not know, what evidence exists, what the customer may be told, what staff may do, and what must be reconciled.

If a state transition cannot be proven, it must not occur.
