# 000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md

## 1. Purpose

This document defines the logical state machine for POS-related order, payment, cancellation, refund, and status synchronization.

The purpose is to prevent POS integration from treating complex operational flow as a single success or failure result.

The POS Gateway must preserve the difference between:

- customer order request
- store acceptance
- payment authorization
- POS order creation
- KDS display
- DID callout
- kitchen preparation
- pickup completion
- cancellation
- refund
- unknown provider result
- recovery
- reconciliation
- manual review

This document is a logic foundation document.

It is not implementation code.

## 2. Upstream Dependencies

This document depends on:

```text
000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md
000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md
```

The authority boundary in `000801` and the adapter contract in `000802` are upstream standards.

This file must not redefine those standards differently.

## 3. Core Rule

```text
Payment success and order success must not be treated as the same event.
```

Additional rules:

```text
POS success and KDS success must not be treated as the same event.
KDS success and DID callout success must not be treated as the same event.
Cancellation success and refund success must not be treated as the same event.
Provider timeout must not be treated as failure unless failure is proven.
Unknown state must not be treated as success.
```

## 4. Scope

This document defines:

* order request state
* payment state
* POS order state
* KDS display state
* DID callout state
* cancellation state
* refund state
* unknown state
* recovery state
* manual review state
* state transition principles
* split-brain handling
* reconciliation trigger
* evidence requirement per transition

## 5. Non-Scope

This document does not define:

* actual adapter code
* provider-specific API payloads
* Flutter UI state implementation
* SQL schema implementation
* Supabase RLS policy
* payment provider SDK details
* production deployment procedure
* final customer support wording
* final legal refund policy

Those belong to separate implementation, UI, data, legal, or support documents.

## 6. State Machine Principle

The state machine must preserve operational truth.

A transaction may be partially successful.

A transaction may be financially successful but operationally failed.

A transaction may be operationally visible in the kitchen but financially unresolved.

A transaction may be unknown until reconciliation.

The state machine must therefore avoid shallow binary status values such as:

```text
success
failed
done
completed
```

unless the state has sufficient evidence and the required downstream states are also resolved.

## 7. Primary State List

The POS integration state machine uses the following primary states.

| State                     | Meaning                                                                |
| ------------------------- | ---------------------------------------------------------------------- |
| `request_created`         | Customer or runtime order request was created                          |
| `store_accepted`          | Store accepted the order request                                       |
| `payment_pending`         | Payment authorization is pending                                       |
| `payment_authorized`      | Payment authorization succeeded                                        |
| `payment_failed`          | Payment authorization failed with sufficient evidence                  |
| `payment_unknown`         | Payment result cannot be safely determined                             |
| `pos_order_pending`       | POS order creation was requested                                       |
| `pos_order_confirmed`     | POS provider confirmed order creation                                  |
| `pos_order_failed`        | POS provider rejected or failed order creation with evidence           |
| `pos_order_unknown`       | POS order result cannot be safely determined                           |
| `kds_display_pending`     | KDS display request was issued                                         |
| `kds_displayed`           | KDS confirmed that the order is visible to kitchen staff               |
| `kds_display_failed`      | KDS failed to display the order                                        |
| `did_callout_pending`     | DID or pickup display callout was requested                            |
| `did_callout_done`        | DID or pickup display callout succeeded                                |
| `did_callout_failed`      | DID or pickup display callout failed                                   |
| `preparing`               | Kitchen preparation started                                            |
| `ready`                   | Order is ready for pickup or handoff                                   |
| `completed`               | Order lifecycle is operationally completed                             |
| `cancel_requested`        | Cancellation was requested                                             |
| `cancel_pending`          | Cancellation is being processed                                        |
| `cancel_confirmed`        | Cancellation was confirmed                                             |
| `cancel_failed`           | Cancellation failed with evidence                                      |
| `cancel_unknown`          | Cancellation result cannot be safely determined                        |
| `refund_requested`        | Refund was requested                                                   |
| `refund_pending`          | Refund is being processed                                              |
| `refund_confirmed`        | Refund was confirmed                                                   |
| `refund_failed`           | Refund failed with evidence                                            |
| `refund_unknown`          | Refund result cannot be safely determined                              |
| `failed`                  | Final failure state with sufficient evidence                           |
| `unknown`                 | General unknown state when no more specific unknown state is available |
| `recovery_required`       | Recovery action is required                                            |
| `reconciliation_required` | Reconciliation is required                                             |
| `manual_review_required`  | Human review is required                                               |
| `degraded_mode_required`  | Store operation must continue through limited or manual mode           |

## 8. State Grouping

The states must be grouped by responsibility.

| Group            | States                                                                                             |
| ---------------- | -------------------------------------------------------------------------------------------------- |
| Order Request    | `request_created`, `store_accepted`                                                                |
| Payment          | `payment_pending`, `payment_authorized`, `payment_failed`, `payment_unknown`                       |
| POS Order        | `pos_order_pending`, `pos_order_confirmed`, `pos_order_failed`, `pos_order_unknown`                |
| Kitchen          | `kds_display_pending`, `kds_displayed`, `kds_display_failed`, `preparing`, `ready`                 |
| Customer Display | `did_callout_pending`, `did_callout_done`, `did_callout_failed`                                    |
| Cancellation     | `cancel_requested`, `cancel_pending`, `cancel_confirmed`, `cancel_failed`, `cancel_unknown`        |
| Refund           | `refund_requested`, `refund_pending`, `refund_confirmed`, `refund_failed`, `refund_unknown`        |
| Control          | `recovery_required`, `reconciliation_required`, `manual_review_required`, `degraded_mode_required` |
| Final            | `completed`, `failed`                                                                              |

No adapter may collapse these groups into one provider status.

## 9. Normal Order Flow

The preferred normal flow is:

```text
request_created
  -> store_accepted
  -> payment_pending
  -> payment_authorized
  -> pos_order_pending
  -> pos_order_confirmed
  -> kds_display_pending
  -> kds_displayed
  -> preparing
  -> ready
  -> did_callout_pending
  -> did_callout_done
  -> completed
```

This flow may vary by store configuration, payment timing, or provider capability.

However, any skipped step must be explicitly justified by configuration or provider capability.

A skipped step must not be hidden.

## 10. Payment-First Flow

Some flows may authorize payment before POS order confirmation.

Example:

```text
request_created
  -> payment_pending
  -> payment_authorized
  -> pos_order_pending
  -> pos_order_confirmed
```

Risk:

```text
Payment may succeed while POS order creation fails or remains unknown.
```

Required handling:

* preserve payment evidence
* preserve POS request evidence
* enter `recovery_required` if POS order fails
* enter `reconciliation_required` if POS status is unknown
* enter `manual_review_required` if duplicate payment or refund risk exists

## 11. POS-First Flow

Some flows may create or reserve POS order before payment authorization.

Example:

```text
request_created
  -> pos_order_pending
  -> pos_order_confirmed
  -> payment_pending
  -> payment_authorized
```

Risk:

```text
POS may contain an order while payment fails or remains unknown.
```

Required handling:

* preserve POS order evidence
* preserve payment attempt evidence
* cancel or void provider-side order if policy allows
* trigger manual review when kitchen preparation already started
* avoid automatic customer finality until payment state is resolved

## 12. Store-Acceptance Flow

If store acceptance is required, the order must not be treated as accepted before store confirmation.

Example:

```text
request_created
  -> store_accepted
  -> payment_pending
```

If store rejects or times out before acceptance, the runtime must not create irreversible payment or POS state unless specifically approved by policy.

## 13. KDS Display Flow

POS confirmation does not automatically mean kitchen visibility.

The KDS flow must be tracked separately:

```text
pos_order_confirmed
  -> kds_display_pending
  -> kds_displayed
  -> preparing
```

If KDS display fails:

```text
pos_order_confirmed
  -> kds_display_pending
  -> kds_display_failed
  -> recovery_required
```

Possible recovery:

* resend to KDS
* route to alternate kitchen station
* print fallback ticket
* staff manual kitchen entry
* degraded mode

KDS failure must not be hidden as successful order completion.

## 14. DID Callout Flow

DID callout or pickup display is separate from kitchen preparation.

Example:

```text
ready
  -> did_callout_pending
  -> did_callout_done
  -> completed
```

If DID callout fails:

```text
ready
  -> did_callout_pending
  -> did_callout_failed
  -> recovery_required
```

Possible recovery:

* manual callout by staff
* printed pickup ticket
* app notification fallback
* KDS-side pickup confirmation

DID failure does not necessarily invalidate the order, but it affects customer handoff.

## 15. Cancellation Flow

Cancellation must preserve order, payment, POS, and kitchen state.

Basic flow:

```text
cancel_requested
  -> cancel_pending
  -> cancel_confirmed
```

Failure flow:

```text
cancel_requested
  -> cancel_pending
  -> cancel_failed
  -> manual_review_required
```

Unknown flow:

```text
cancel_requested
  -> cancel_pending
  -> cancel_unknown
  -> reconciliation_required
```

Cancellation must consider:

* whether payment was authorized
* whether POS order was created
* whether KDS displayed the order
* whether preparation started
* whether refund is required
* whether customer-facing promise has changed
* whether staff approval is required

Cancellation confirmation does not automatically mean refund confirmation.

## 16. Refund Flow

Refund state must be separate from cancellation state.

Basic flow:

```text
refund_requested
  -> refund_pending
  -> refund_confirmed
```

Failure flow:

```text
refund_requested
  -> refund_pending
  -> refund_failed
  -> manual_review_required
```

Unknown flow:

```text
refund_requested
  -> refund_pending
  -> refund_unknown
  -> reconciliation_required
```

Refund must preserve:

* original payment ID
* payment transaction ID
* refund request ID
* refund amount
* refund reason
* provider response
* evidence reference
* approval reference where required

Refund unknown must never be treated as refund confirmed.

## 17. Split-Brain States

Split-brain means two or more runtime layers disagree.

Common split-brain cases:

| Case                                                   | Required State                                   |
| ------------------------------------------------------ | ------------------------------------------------ |
| Payment succeeded, POS order failed                    | `recovery_required` and `manual_review_required` |
| Payment succeeded, POS order unknown                   | `reconciliation_required`                        |
| POS order succeeded, payment failed                    | `manual_review_required`                         |
| POS order succeeded, KDS failed                        | `recovery_required`                              |
| POS order succeeded, DID failed                        | `recovery_required` or manual callout            |
| Cancel succeeded, refund failed                        | `manual_review_required`                         |
| Refund unknown after timeout                           | `reconciliation_required`                        |
| Menu sync succeeded, sold-out sync failed              | `reconciliation_required`                        |
| Provider says completed, internal runtime says pending | `manual_review_required`                         |

Split-brain must be visible in evidence and audit logs.

## 18. Unknown State Handling

Unknown state is not success.

Unknown state is not failure.

Unknown state means the runtime lacks enough evidence to make a final decision.

Unknown state may be produced by:

* provider timeout
* network interruption
* provider delayed response
* ambiguous provider response
* missing webhook
* late webhook
* polling conflict
* duplicate callback
* local KDS event without POS confirmation
* POS confirmation without payment confirmation
* manual operation outside system

Required handling:

```text
unknown
  -> evidence preservation
  -> retry eligibility evaluation
  -> reconciliation_required
  -> manual_review_required where needed
```

Unknown state may later resolve to success, failure, cancellation, refund, recovery, or manual closure.

## 19. Retry Transition Rule

Retry is allowed only when safe.

Safe retry conditions may include:

* idempotency key exists
* provider supports idempotency
* duplicate detection is available
* provider status check confirms no previous processing
* operation is read-only
* retry does not create duplicate financial or operational effect

Unsafe retry conditions include:

* payment authorization unknown
* refund unknown
* cancellation unknown
* POS order creation unknown after request submission
* provider does not support idempotency
* duplicate order risk exists
* duplicate payment risk exists

Unsafe retry must transition to:

```text
manual_review_required
```

or:

```text
reconciliation_required
```

depending on available evidence.

## 20. Reconciliation Trigger

Reconciliation is required when:

* payment and POS disagree
* POS and order runtime disagree
* POS and KDS disagree
* KDS and DID disagree
* refund state is unknown
* cancel state is unknown
* provider response arrives after timeout
* duplicate order risk exists
* duplicate payment risk exists
* manual operation occurred outside the system
* evidence is incomplete
* provider polling conflicts with prior webhook

Reconciliation must produce:

* reconciliation ID
* matched event list
* mismatched event list
* unresolved event list
* recommended recovery action
* manual review requirement
* evidence reference

## 21. Recovery Transition Rule

Recovery is required when a failed or partial state can be corrected operationally.

Examples:

```text
pos_order_failed
  -> recovery_required
  -> manual POS entry
  -> reconciliation_required
```

```text
kds_display_failed
  -> recovery_required
  -> KDS resend or manual kitchen ticket
  -> kds_displayed or manual_review_required
```

```text
did_callout_failed
  -> recovery_required
  -> manual callout
  -> completed
```

Recovery must not erase original failure evidence.

Recovery must create new recovery evidence.

## 22. Manual Review Transition Rule

Manual review is required for high-risk or irreversible decisions.

Manual review is required when:

* duplicate payment risk exists
* refund unknown exists
* cancellation conflicts with kitchen state
* provider state conflicts with internal ledger
* payment succeeded but POS order failed
* POS order succeeded but payment failed
* recovery action may affect customer, money, or kitchen operation
* support compensation may be required
* final state cannot be determined automatically
* provider limitation prevents safe automation

Manual review must record:

* reviewer
* review timestamp
* decision
* reason
* evidence reference
* follow-up requirement

## 23. Degraded Mode Transition Rule

Degraded mode may be required when normal POS integration cannot continue safely but store operation may continue manually.

Possible triggers:

* POS provider unavailable
* network failure
* KDS unavailable
* DID unavailable
* provider rate limit
* adapter unavailable
* menu sync unavailable
* payment provider unavailable

Possible degraded modes:

* manual POS entry
* printed kitchen ticket
* handwritten kitchen ticket
* staff verbal callout
* limited menu
* payment-at-counter only
* pause mobile ordering
* pause kiosk ordering
* safe closure if unsafe

Degraded mode requires evidence and human authority.

## 24. Final State Rule

The `completed` state may be reached only when required operational states are resolved according to configuration.

A completed order normally requires:

* order request exists
* payment state resolved according to payment policy
* POS order state resolved
* KDS or manual kitchen handling resolved
* readiness or pickup state resolved
* customer handoff state resolved
* no unresolved financial risk
* no unresolved duplicate risk
* required evidence exists

The `failed` state may be reached only when failure is proven or policy determines final failure after review.

Unknown state must not directly become final completed.

## 25. Customer-Facing Status Rule

Customer-facing status must be safer than internal status.

Internal states may include:

* unknown
* recovery required
* reconciliation required
* manual review required
* provider timeout
* split-brain

Customer-facing status must avoid misleading finality.

Example customer-facing statuses may include:

* order received
* waiting for store confirmation
* payment being checked
* preparing
* ready for pickup
* completed
* cancellation being checked
* refund being checked
* staff assistance required

Customer-facing wording must not expose internal provider details unless approved by support policy.

## 26. Evidence Requirement Per Transition

Every state transition must record:

* previous state
* next state
* transition reason
* actor or system source
* timestamp
* correlation ID
* order ID
* payment ID where applicable
* POS provider where applicable
* POS transaction ID where applicable
* provider response reference where applicable
* retry count where applicable
* idempotency key where applicable
* evidence reference
* manual review reference where applicable

State transition without evidence is not acceptable for financial or operational actions.

## 27. Provider Adapter Limitation Rule

If a provider does not support a state or transition, the adapter must report the limitation.

The runtime must not pretend unsupported provider behavior exists.

Examples:

* provider does not support refund through POS API
* provider does not support idempotency
* provider does not expose receipt ID
* provider does not support webhook
* provider requires polling
* provider does not support menu sync
* provider does not support sold-out sync

Unsupported features must be reflected in:

```text
000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md
```

## 28. State Transition Anti-Patterns

The following are prohibited:

* `payment_authorized` directly becomes `completed`
* `pos_order_confirmed` directly becomes `completed` without kitchen/handoff resolution
* `refund_unknown` becomes `refund_confirmed`
* `cancel_unknown` becomes `cancel_confirmed`
* `provider_timeout` becomes `failed` without evidence
* `unknown` becomes `success` for convenience
* duplicate order risk is ignored
* duplicate payment risk is ignored
* KDS failure is hidden behind POS success
* DID failure is hidden behind ready state
* manual recovery occurs without evidence
* adapter returns provider-specific success that bypasses internal state machine

## 29. Relationship To Downstream Documents

This document must be used by:

* `000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md`
* `000806_Logic_POS_Idempotency_Retry_Timeout_Duplicate_Prevention_And_Unknown_State.md`
* `000807_Runbook_POS_Reconciliation_Recovery_Manual_Operation_And_Degraded_Mode.md`
* `000808_Template_POS_Transaction_Evidence_Event_Log_And_Diagnostic_Record.md`
* `000809_Checklist_POS_Gateway_Internal_Readiness_Before_Outsourcing_Or_Implementation.md`
* `000900_outsourcing_vendor_handoff_and_acceptance` documents

Downstream documents must not collapse or redefine this state machine.

## 30. Acceptance Criteria

This state machine document is acceptable only if it confirms that:

* payment success and order success are separate
* POS success and KDS success are separate
* cancellation and refund are separate
* unknown state is explicitly preserved
* split-brain cases are handled
* retry is allowed only when safe
* reconciliation is triggered for mismatches
* recovery creates new evidence
* manual review is required for high-risk cases
* customer-facing status does not overstate finality
* unsupported provider behavior is documented
* no implementation is authorized by this document

## 31. Final Rule

```text
The state machine must protect money, kitchen operations, customer trust, and auditability.
A state is final only when the required authority, evidence, reconciliation, and recovery conditions are satisfied.
```
