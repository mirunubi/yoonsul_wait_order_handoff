# 10230_POS_Handoff_Room_Boundary_Policy

## 1. Purpose

This document defines the POS Handoff Room Boundary Policy.

The previous artifact `10220` defined the Order Validation Room Boundary Policy.

This document frames the third Side B room:

`POS Handoff Room`

The purpose is to define the boundary where a validated order candidate may later be handed off to an external or internal POS system under controlled policy, provider evidence, idempotency, retry, degraded operation, reconciliation, and audit rules.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The POS Handoff Room manages the boundary between validated internal order candidates and POS transaction acceptance.

The POS Handoff Room may later coordinate:

- POS handoff candidate
- POS request attempt
- POS accepted status
- POS rejected status
- POS timeout
- POS duplicate risk
- POS retry candidate
- POS provider degraded state
- POS evidence reference
- POS reconciliation requirement

The POS Handoff Room does not confirm payment.

The POS Handoff Room does not confirm settlement.

The POS Handoff Room does not create KDS completion.

The POS Handoff Room does not approve refund or compensation.

---

## 3. Core Principle

POS handoff is not financial truth.

The correct rule is:

Validation ready is not POS accepted.  
POS request sent is not POS accepted.  
POS accepted is not payment confirmed.  
POS rejected is not customer fault.  
POS timeout is not safe success.  
POS provider callback is not verified truth by itself.  
POS receipt reference is not settlement.  
POS handoff failure is not automatic compensation.  

POS handoff must be evidence-bound, idempotent, reconcilable, and safely projected.

---

## 4. Scope

The POS Handoff Room may define planning boundaries for:

- validated order candidate
- POS provider profile reference
- POS capability evidence reference
- handoff request state
- POS acceptance state
- POS rejection state
- timeout state
- retry state
- duplicate prevention
- provider degraded mode
- manual fallback route
- POS evidence packet
- reconciliation requirement
- customer-safe status projection
- support/admin visibility

This room does not implement POS integration.

---

## 5. POS Handoff Input Boundary

POS handoff input may include:

| Input | Meaning |
|---|---|
| `validation_id` | Validation reference |
| `order_intent_id` | Order intent reference |
| `tenant_id` | Tenant context |
| `store_id` | Store context |
| `surface_id` | Source surface |
| `device_id` | Device if applicable |
| `validated_items` | Items eligible for handoff |
| `validated_price_snapshot` | Validated price reference |
| `order_type` | dine-in/takeout/waiting/etc. |
| `provider_profile_id` | POS provider profile reference |
| `provider_capability_reference` | Provider evidence reference |
| `idempotency_key` | Duplicate prevention reference |
| `fallback_marker` | Fallback if originated |
| `safe_message_key` | Customer-safe message key |

Input must come from a validated candidate.

Raw intake should not call POS directly.

---

## 6. POS Handoff Output Boundary

POS handoff output may include:

| Output | Meaning |
|---|---|
| `pos_handoff_id` | POS handoff reference |
| `pos_handoff_status` | Handoff state |
| `pos_provider_reference` | Provider reference if available |
| `pos_acceptance_reference` | Acceptance reference if available |
| `pos_rejection_reason_category` | Safe rejection category |
| `retry_candidate` | Whether retry may be considered |
| `reconciliation_required` | Whether reconciliation is required |
| `fallback_required` | Whether fallback route is needed |
| `evidence_reference` | POS evidence reference |
| `safe_projection_reference` | Customer/staff-safe projection |
| `audit_placeholder` | Future audit reference |

Output must not claim payment confirmation.

---

## 7. POS Handoff State Skeleton

Recommended POS handoff states:

| State | Meaning |
|---|---|
| `POS_HANDOFF_NOT_STARTED` | No POS handoff attempted |
| `POS_HANDOFF_CANDIDATE` | Candidate prepared |
| `POS_HANDOFF_BLOCKED` | Handoff blocked before request |
| `POS_HANDOFF_REQUEST_READY` | Ready to request |
| `POS_HANDOFF_REQUESTED` | Request attempted |
| `POS_HANDOFF_PROVIDER_PENDING` | Provider pending |
| `POS_HANDOFF_ACCEPTED` | POS accepted |
| `POS_HANDOFF_REJECTED` | POS rejected |
| `POS_HANDOFF_TIMEOUT` | Timeout occurred |
| `POS_HANDOFF_DUPLICATE_RISK` | Duplicate risk detected |
| `POS_HANDOFF_RETRY_REVIEW_REQUIRED` | Retry requires review |
| `POS_HANDOFF_DEGRADED` | Provider degraded |
| `POS_HANDOFF_FALLBACK_REQUIRED` | Manual/degraded fallback required |
| `POS_HANDOFF_RECONCILIATION_REQUIRED` | Reconciliation required |
| `POS_HANDOFF_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. Provider Capability Boundary

POS provider capability must be evidence-based.

The room may reference:

- provider profile
- supported request type
- supported callback type
- idempotency support
- retry support
- cancellation support
- error code behavior
- timeout behavior
- degraded mode behavior
- reconciliation support
- test evidence
- certification evidence if available

The room must not assume capability from provider name.

Provider profile is not proof.

Provider capability requires evidence.

---

## 9. POS Request Boundary

A future POS request may be allowed only when:

- validation state is ready for handoff
- POS provider capability is verified
- store runtime configuration allows POS handoff
- device/surface is allowed
- tenant package entitlement exists
- policy gate allows handoff
- idempotency key exists
- fallback route exists
- audit/evidence route exists

This document does not authorize sending requests.

It only defines the future gate.

---

## 10. Idempotency Boundary

POS handoff must be idempotent.

Idempotency must handle:

- user double tap
- kiosk retry
- network retry
- delayed provider callback
- duplicate provider response
- manual fallback after timeout
- app refresh
- staff retry
- support-assisted retry
- provider partial response

Duplicate attempt must not create duplicate POS order.

Retry is not automatic.

Retry may require review depending on risk.

---

## 11. Timeout Boundary

POS timeout is uncertain state.

Timeout must not be treated as success.

Timeout must not be treated as failure without review if provider may still complete later.

Timeout may require:

- safe customer message
- staff assist
- retry review
- duplicate-risk check
- provider status check if later authorized
- reconciliation requirement
- manual fallback route
- audit event

Timeout is not safe success.

---

## 12. Rejection Boundary

POS rejection may occur because of:

- provider unavailable
- invalid item mapping
- invalid price mapping
- store closed in POS
- unsupported option
- duplicate request
- provider validation failure
- configuration mismatch
- device/store mismatch
- policy block
- unknown provider error

Customer-safe projection must not expose raw provider details.

POS rejection is not automatically customer fault.

Rejection should route to staff assist or fallback if needed.

---

## 13. Retry Boundary

Retry must be controlled.

Retry may be considered only when:

- idempotency is available
- duplicate risk is evaluated
- provider retry behavior is known
- previous state is not accepted
- payment state is safe or separated
- staff/support review is satisfied if required
- audit/evidence exists
- retry limit is respected

Retry must not create duplicate POS orders.

Retry must not bypass validation.

---

## 14. POS Degraded Mode Boundary

POS degraded mode may occur when:

- POS provider unavailable
- POS callback delayed
- POS response stale
- POS adapter unavailable
- network unstable
- store POS offline
- provider limitation active
- configuration mismatch detected

POS degraded mode should define:

- allowed actions
- prohibited actions
- customer-safe message
- staff assist route
- manual fallback route
- reconciliation requirement
- support/admin visibility
- recovery route if customer affected

Degraded mode is not normal operation.

---

## 15. POS Evidence Boundary

POS evidence may include:

- validation id
- order intent id
- POS handoff id
- provider profile id
- provider capability evidence reference
- idempotency key
- request timestamp
- response timestamp
- provider reference
- acceptance/rejection category
- timeout marker
- retry marker
- fallback marker
- device/surface reference
- staff id if assisted
- safe message key
- audit reference

Evidence supports review.

Evidence is not financial truth.

---

## 16. POS Safe Projection Boundary

Customer-safe POS projection may show:

- order is being processed
- staff assistance required
- order could not proceed
- retry is needed
- store is temporarily unable to accept the order
- please ask staff
- order status is being checked

Customer-safe projection must not show:

- raw POS provider error
- provider credentials or payload
- payment confirmation
- settlement state
- compensation promise
- legal conclusion
- internal duplicate-risk detail
- AI reasoning
- vector similarity

Safe Projection protects customer communication.

---

## 17. POS Support/Admin Visibility Boundary

Support/Admin may see more detail if authorized.

Support/Admin visibility may include:

- POS provider reference
- safe provider error category
- request/response timestamp
- idempotency reference
- retry status
- degraded mode status
- reconciliation status
- evidence packet reference
- masked customer/order context

Support/Admin must not see:

- raw secrets
- unrestricted raw payloads by default
- payment credentials
- unnecessary personal data
- unmasked financial data without role authority

Visibility is not mutation permission.

---

## 18. Relationship To Order Validation Room

POS Handoff receives only validated candidates.

The required prior state is:

`VALIDATION_READY_FOR_HANDOFF`

If validation is stale, unknown, rejected, fallback-required, or staff-assist-required, POS handoff must not proceed automatically.

Validation must not be bypassed.

---

## 19. Relationship To KDS Ticket Room

KDS ticketing may depend on POS handoff policy.

Possible future patterns:

- KDS after POS accepted
- KDS before POS accepted in limited workflows
- KDS after payment confirmed
- KDS manual fallback when POS unavailable
- KDS disabled when POS handoff fails

This document does not choose one runtime pattern.

It requires explicit policy before KDS ticket creation.

---

## 20. Relationship To Financial Trust

POS Handoff must defer financial truth to Side C.

POS Handoff must not:

- confirm payment
- confirm settlement
- execute refund
- issue coupon
- adjust points
- mutate wallet
- approve compensation

POS references may help reconciliation.

They do not replace Financial Trust.

---

## 21. Relationship To Data Governance

POS Handoff uses Side D for:

- i18n safe messages
- POS degraded notice templates
- support/admin visibility policy
- provider evidence knowledge base
- incident learning
- AI summary if later authorized
- vector context if later authorized
- analytics/read model if later authorized

Data Governance supports review and messaging.

It does not execute POS.

---

## 22. Relationship To Manual Fallback Room

POS Handoff may route to Manual Fallback when:

- POS unavailable
- POS timeout creates uncertainty
- provider rejected but store can safely handle manually
- device/network issue blocks handoff
- configuration mismatch requires human action
- degraded operation policy allows manual capture

Manual fallback must be marked:

`FALLBACK_ORIGINATED`

Manual fallback must later reconcile with POS/payment/KDS state if needed.

---

## 23. POS Incident Boundary

POS incidents may include:

- handoff rejected
- handoff timeout
- duplicate risk
- provider unavailable
- callback mismatch
- provider reference missing
- item mapping error
- price mapping error
- store/device mismatch
- retry failure
- fallback triggered

Incident acknowledgement is not resolution.

POS incident must capture evidence and route review.

---

## 24. POS Handoff Anti-Patterns

Avoid:

- validation treated as POS accepted
- POS request sent treated as POS accepted
- POS accepted treated as payment confirmed
- POS timeout treated as success
- POS rejection blamed on customer without review
- retry without idempotency
- duplicate POS order created by app refresh
- provider callback treated as verified truth
- raw POS error shown to customer
- staff retry bypassing evidence
- manual fallback overwriting POS state
- AI deciding POS retry
- pgvector similarity proving provider behavior

These anti-patterns must be blocked in future runtime design.

---

## 25. Runtime Deferral

This document defines the POS Handoff Room boundary only.

It does not authorize:

- POS adapter implementation
- POS API call
- POS webhook processing
- provider credential storage
- POS request schema
- database schema
- retry engine
- reconciliation engine
- customer POS status runtime
- support/admin POS runtime
- payment integration
- KDS integration
- production deployment

All runtime remains deferred.

---

## 26. Validation Checklist

Validation must confirm:

1. POS Handoff Room definition is clear.
2. POS handoff is not financial truth.
3. Input boundary is defined.
4. Output boundary is defined.
5. POS handoff states are defined.
6. Provider capability boundary is evidence-based.
7. POS request boundary is gated.
8. Idempotency boundary is defined.
9. Timeout boundary is defined.
10. Rejection boundary is defined.
11. Retry boundary is defined.
12. POS degraded mode boundary is defined.
13. POS evidence boundary is defined.
14. POS Safe Projection boundary is defined.
15. Support/Admin visibility boundary is defined.
16. Relationship to Order Validation Room is defined.
17. Relationship to KDS Ticket Room is defined.
18. Relationship to Financial Trust is defined.
19. Relationship to Data Governance is defined.
20. Relationship to Manual Fallback Room is defined.
21. POS incident boundary is defined.
22. Anti-patterns are listed.
23. Coding remains unauthorized.
24. Runtime remains deferred.

---

## 27. Relationship To Previous Documents

This document follows:

- `10220 Order Validation Room Boundary Policy`

It references:

- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`

It prepares:

- `10240 KDS Ticket Room Boundary Policy`
- `10250 Kitchen Execution Room Boundary Policy`
- future POS provider evidence packet planning
- future POS handoff static specification packet

This document is room boundary planning only.

It does not authorize coding.

---

## 28. Final Rule

The POS Handoff Room may later coordinate validated order candidates with POS provider boundaries, but it must not become payment truth, settlement truth, refund authority, compensation authority, KDS completion authority, or provider capability authority.

POS accepted is not payment confirmed.

POS timeout is uncertain.

POS retry requires idempotency.

POS provider callback is not verified truth by itself.

POS handoff must preserve evidence, audit, fallback, reconciliation, i18n, Safe Projection, provider trust, and authority boundaries.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
