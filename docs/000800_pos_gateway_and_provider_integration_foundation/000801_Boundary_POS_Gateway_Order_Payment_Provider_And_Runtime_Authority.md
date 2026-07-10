# 000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md

## 1. Purpose

This document defines the authority and responsibility boundaries for POS Gateway, provider adapters, POS providers, payment runtime, order runtime, kitchen runtime, and human operations.

This document exists to prevent POS integration from becoming an uncontrolled provider-specific implementation.

The POS Gateway must not allow a POS provider, adapter vendor, external outsourcing vendor, payment provider, or implementation agent to redefine our order authority, payment authority, cancellation authority, refund authority, recovery policy, evidence policy, or operational source of truth.

This document is an internal foundation document.

It is used before implementation and before outsourcing.

## 2. Core Principle

```text
Our system defines authority, state, recovery, reconciliation, and evidence.
Provider adapters translate provider-specific behavior into our controlled POS Gateway contract.
Vendors may implement adapters later, but vendors must not define our order authority, payment authority, refund authority, recovery policy, or operational source of truth.
```

The POS provider may confirm what happened inside the provider system.

The provider adapter may translate provider-specific behavior.

The POS Gateway may normalize and record provider events.

However, final business interpretation must remain under our controlled runtime boundary.

## 3. Scope

This document covers:

* order authority boundary
* payment authority boundary
* cancellation authority boundary
* refund authority boundary
* POS provider responsibility boundary
* provider adapter responsibility boundary
* POS Gateway responsibility boundary
* Kiosk / KDS / DID / CMS runtime relationship
* evidence and audit authority
* recovery and reconciliation authority
* human approval boundary
* outsourcing vendor boundary
* unsupported provider boundary

## 4. Non-Scope

This document does not define:

* provider-specific API implementation
* actual adapter source code
* production credential handling code
* Flutter UI implementation
* Supabase schema implementation
* RLS policy implementation
* payment provider SDK implementation
* provider-specific commercial contract terms
* final legal contract language
* production deployment authorization

Those belong to separate implementation, contract, security, or release documents.

## 5. Authority Layers

The POS integration runtime must be understood as layered authority.

```text
Customer / Staff / Kiosk / App
        ↓
Order Runtime
        ↓
Payment Runtime
        ↓
POS Gateway
        ↓
Provider Adapter
        ↓
POS Provider
        ↓
Store Operation / Kitchen / KDS / DID / Manual Recovery
```

Each layer may emit events.

Each layer may fail independently.

No single provider event may automatically become final business truth without passing through our state, evidence, and recovery rules.

## 6. Our System Owns

Our system owns the following decisions and rules.

| Area                     | Our System Owns                                                                                        |
| ------------------------ | ------------------------------------------------------------------------------------------------------ |
| Order Authority          | Whether an order is accepted, pending, failed, completed, canceled, or requires manual review          |
| Payment Authority        | How payment authorization, cancellation, refund, and unknown payment status are interpreted            |
| Cancellation Authority   | When cancellation is allowed, blocked, pending, completed, or escalated                                |
| Refund Authority         | When refund is allowed, pending, completed, failed, or requires manual review                          |
| Source Of Truth          | Which runtime state is authoritative under normal, failure, and recovery conditions                    |
| State Machine            | All order/payment/POS/KDS/DID/customer-facing state transitions                                        |
| Retry Policy             | Which operations may be retried safely and which require manual review                                 |
| Idempotency Policy       | How duplicate orders, duplicate payments, duplicate cancellations, and duplicate refunds are prevented |
| Reconciliation Policy    | How POS, payment, KDS, DID, and order ledger mismatches are detected and resolved                      |
| Recovery Policy          | How failed or unknown transactions are recovered                                                       |
| Manual Operation Policy  | When store staff must operate manually or under degraded mode                                          |
| Customer-Facing Finality | What the customer is told and when a status becomes final                                              |
| Evidence Rule            | What event, payload, timestamp, actor, and diagnostic record must be retained                          |
| Audit Rule               | How decisions, failures, manual actions, and recovery are reviewed                                     |
| Tenant Boundary          | Which tenant, store, franchisee, or support context may access the event                               |
| Permission Boundary      | Which role may view, approve, retry, cancel, refund, recover, or escalate                              |

## 7. POS Gateway Owns

The POS Gateway owns the internal normalization layer between our runtime and provider adapters.

The POS Gateway is responsible for:

* enforcing the adapter contract
* normalizing provider-specific responses
* preserving provider-specific raw evidence references
* applying common error categories
* applying common timeout categories
* applying common idempotency rules
* applying common retry eligibility rules
* recording diagnostic events
* forwarding events to reconciliation logic
* preventing provider-specific behavior from leaking into business logic
* separating payment success from order success
* separating POS confirmation from KDS confirmation
* separating provider availability from store operational readiness

The POS Gateway must not make final human-authority decisions by itself.

The POS Gateway may recommend status classification, recovery requirement, or manual review requirement.

Final irreversible actions must follow the approved authority and human approval rules.

## 8. Provider Adapter Owns

A provider adapter owns only provider-specific translation.

A provider adapter may own:

* provider-specific API endpoint mapping
* provider-specific request formatting
* provider-specific response parsing
* provider-specific error normalization
* provider-specific authentication flow under approved credential rules
* provider-specific health check logic
* provider-specific retry feasibility reporting
* provider-specific capability reporting
* provider-specific evidence capture
* provider-specific receipt or transaction ID extraction
* provider-specific polling or webhook translation
* provider-specific menu or availability sync translation

A provider adapter must not own:

* business order policy
* final order state
* final payment state
* refund policy
* cancellation policy
* customer-facing finality wording
* manual recovery policy
* tenant permission rules
* support policy
* production deployment decision
* commercial provider support status

The adapter is a translator.

It is not the business authority.

## 9. POS Provider Owns

A POS provider owns the behavior and records inside its own system.

A POS provider may provide:

* POS order receipt
* POS transaction ID
* POS order status
* POS cancellation status
* POS refund or payment-related status where applicable
* menu data where supported
* price data where supported
* option data where supported
* sold-out or availability data where supported
* provider-side error codes
* provider-side timestamps
* provider-side API documentation
* provider-side sandbox behavior
* provider-side official API boundary

A POS provider does not own:

* our customer-facing order finality
* our payment/refund finality
* our internal order ledger
* our KDS display state
* our DID callout state
* our recovery policy
* our reconciliation policy
* our support policy
* our tenant access policy
* our audit retention policy

Provider confirmation is evidence.

Provider confirmation is not automatically the full operational truth.

## 10. Payment Authority Boundary

Payment success and order success must not be treated as the same event.

The following are separate events:

* payment authorization requested
* payment authorization succeeded
* payment authorization failed
* payment authorization unknown
* POS order creation requested
* POS order creation succeeded
* POS order creation failed
* POS order creation unknown
* KDS display requested
* KDS display succeeded
* KDS display failed
* DID callout requested
* DID callout succeeded
* DID callout failed

A payment event may affect order state.

However, payment success alone does not prove that the POS order, kitchen display, store operation, or customer pickup flow succeeded.

The runtime must preserve split-brain cases such as:

```text
Payment succeeded, but POS order creation failed.
Payment succeeded, but POS response is unknown.
POS order succeeded, but KDS display failed.
POS order succeeded, but DID callout failed.
Payment cancel succeeded, but order cancel failed.
Refund status is unknown after provider timeout.
```

These cases must enter recovery, reconciliation, or manual review, not silent success.

## 11. Order Authority Boundary

The order runtime owns the order lifecycle.

POS provider confirmation may support the order state, but does not replace the order runtime.

The order runtime must distinguish:

* customer request created
* store accepted
* payment pending
* payment authorized
* POS order pending
* POS order confirmed
* KDS display pending
* KDS displayed
* preparing
* ready
* completed
* cancellation requested
* cancellation confirmed
* refund requested
* refund confirmed
* failed
* unknown
* recovery required
* manual review required

A provider adapter must not collapse these states into a single "success" or "failure" result.

## 12. Cancellation Authority Boundary

Cancellation is not a simple provider API call.

Cancellation authority must consider:

* order state
* kitchen state
* payment state
* POS state
* store acceptance state
* elapsed time
* customer-facing promise
* provider capability
* refund eligibility
* manual override policy
* evidence availability

The provider adapter may request or confirm provider-side cancellation.

The POS Gateway may normalize the result.

The order runtime must determine the final cancellation state.

Human approval may be required depending on state, amount, timing, and operational impact.

## 13. Refund Authority Boundary

Refund authority must remain under our controlled policy.

A provider or payment system may process a refund.

However, refund finality must be recorded by our runtime with evidence.

Refund handling must distinguish:

* refund requested
* refund accepted by provider
* refund completed
* refund failed
* refund pending
* refund unknown
* refund requires manual review
* refund requires reconciliation

No adapter may automatically mark a refund as final without required provider evidence and internal state transition.

## 14. KDS / DID / CMS Boundary

POS confirmation does not automatically mean that kitchen runtime succeeded.

The system must distinguish:

* POS order accepted
* KDS display succeeded
* kitchen station routing succeeded
* DID customer callout succeeded
* CMS menu or display sync succeeded
* pickup display succeeded

If POS succeeds but KDS fails, the order may require manual kitchen recovery.

If KDS succeeds but POS confirmation is unknown, the order may require reconciliation.

If DID fails, the customer-facing pickup notification may require manual callout or fallback.

These are separate runtime responsibilities.

## 15. Source Of Truth Boundary

The source of truth may vary by context.

| Context                    | Preferred Authority                          |
| -------------------------- | -------------------------------------------- |
| Customer request existence | Order runtime                                |
| Payment authorization      | Payment runtime and provider evidence        |
| POS receipt existence      | POS provider evidence through adapter        |
| Kitchen visibility         | KDS runtime                                  |
| Pickup display             | DID runtime                                  |
| Refund finality            | Payment runtime plus provider evidence       |
| Recovery status            | Recovery runtime and human-reviewed evidence |
| Audit history              | Audit/evidence ledger                        |

The system must not declare a single universal source of truth for all cases.

Instead, the system must define contextual authority and reconciliation rules.

## 16. Unknown State Boundary

Unknown state is not success.

Unknown state is not failure.

Unknown state means the runtime lacks enough evidence to make a final decision.

Unknown state may occur when:

* provider timeout occurs
* network interruption occurs
* provider returns ambiguous response
* provider processes request after timeout
* webhook arrives late
* polling result conflicts with prior response
* payment provider and POS provider disagree
* local KDS receives an event but POS confirmation is missing
* manual operation happens outside the system

Unknown state must trigger:

* evidence preservation
* retry eligibility evaluation
* reconciliation attempt
* manual review where required
* customer-facing caution where applicable

## 17. Human Authority Boundary

Human authority is required for irreversible or high-impact actions.

Human approval may be required for:

* final refund approval
* manual recovery confirmation
* forced cancellation
* forced completion
* correction of duplicate order
* correction of duplicate payment
* override of provider mismatch
* degraded mode activation
* safe closure decision
* customer compensation decision
* production provider support status change

The system may recommend.

The human approves.

The evidence ledger records.

## 18. Outsourcing Vendor Boundary

An outsourcing vendor may implement provider adapters only within approved boundaries.

The vendor may not decide:

* order authority
* payment authority
* refund policy
* cancellation policy
* source of truth
* customer finality wording
* recovery policy
* reconciliation policy
* security policy
* production deployment approval
* provider commercial support status

The vendor must follow the internal standard defined in this `000800` foundation.

The vendor-facing documents in `000900_outsourcing_vendor_handoff_and_acceptance` must reference this standard rather than redefining it.

## 19. Unsupported Provider Boundary

Integration possibility does not equal official support.

A provider may be technically connectable but still unsupported.

Provider support status must be clearly classified.

Allowed support statuses include:

* Official
* Candidate
* Limited
* Research
* Unsupported
* Human Review

Unsupported or research providers must not be marketed, documented, or operationally treated as fully supported.

Manual or semi-manual integration must be labeled clearly.

## 20. Boundary Violation Examples

The following are boundary violations:

* treating payment success as order success
* treating POS success as KDS success
* allowing provider adapter to decide refund finality
* allowing vendor to define state machine
* allowing undocumented provider workaround
* using scraping as if it were official integration
* bypassing idempotency because provider lacks native support
* hiding unknown state as success
* removing manual review for high-risk recovery
* giving vendor production database access
* embedding production credentials in adapter code
* changing customer-facing finality wording inside provider adapter
* presenting unsupported provider as officially supported
* modifying runtime source code without approved implementation gate

## 21. Required Downstream Documents

This boundary document must be used by:

* `000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md`
* `000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md`
* `000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md`
* `000806_Logic_POS_Idempotency_Retry_Timeout_Duplicate_Prevention_And_Unknown_State.md`
* `000807_Runbook_POS_Reconciliation_Recovery_Manual_Operation_And_Degraded_Mode.md`
* `000808_Template_POS_Transaction_Evidence_Event_Log_And_Diagnostic_Record.md`
* `000809_Checklist_POS_Gateway_Internal_Readiness_Before_Outsourcing_Or_Implementation.md`
* `000900_outsourcing_vendor_handoff_and_acceptance` documents

Downstream documents must not redefine the authority model differently.

## 22. Acceptance Criteria

This boundary document is considered acceptable only if it clearly confirms that:

* our system owns authority and business interpretation
* provider adapters are translators only
* providers provide evidence but not full operational truth
* payment success and order success are separate
* POS success and KDS success are separate
* unknown state is handled explicitly
* recovery and reconciliation remain under our policy
* human approval is required for high-impact decisions
* outsourcing vendors cannot define authority
* unsupported provider status is clearly controlled
* no implementation is authorized by this document

## 23. Final Rule

```text
Provider adapters translate.
POS providers confirm provider-side events.
The POS Gateway normalizes and records.
Our runtime decides state, recovery, reconciliation, evidence, and authority.
Humans approve irreversible or high-risk operational decisions.
```
