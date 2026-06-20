# 010300_Policy_Manual_Fallback_Room_Boundary

## 1. Purpose

This document defines the Manual Fallback Room Boundary Policy.

The previous artifact `10290` defined the Degraded Operation Room Boundary Policy.

This document frames the tenth Side B room:

`Manual Fallback Room`

The purpose is to define the boundary where store staff may preserve safe operation through paper, verbal, handwritten, offline, or local manual procedures when normal digital runtime, POS, KDS, payment, device, printer, CMS, network, or provider paths are impaired.

Manual fallback is a survival mechanism.

Manual fallback is not silent mutation.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Manual Fallback Room governs human-operated continuity when digital paths are unsafe, unavailable, stale, degraded, or uncertain.

It may later coordinate:

- manual order capture
- manual kitchen handoff
- handwritten ticket
- paper ticket
- verbal station handoff
- manual sold-out note
- manual delay note
- manual remake note
- manual customer guidance
- manual evidence capture
- later digital entry
- later reconciliation
- incident relation
- recovery route relation

Manual fallback must be explicit.

Manual fallback must be marked.

Manual fallback must be reconciled later where needed.

---

## 3. Core Principle

Manual fallback is survival mode, not data overwrite.

The correct rule is:

Manual note is not system truth.  
Manual order is not POS accepted.  
Manual kitchen ticket is not KDS accepted.  
Manual receipt note is not payment confirmed.  
Manual staff promise is not compensation approval.  
Manual correction is not silent mutation.  
Manual fallback is not normal operation.  
Manual fallback must be marked `FALLBACK_ORIGINATED`.  

Manual fallback preserves service continuity while protecting evidence and later reconciliation.

---

## 4. Scope

The Manual Fallback Room may define planning boundaries for:

- paper order capture
- verbal order confirmation
- manual kitchen ticket
- handwritten station note
- manual pickup note
- manual receipt note
- manual sold-out note
- manual delay note
- manual remake note
- manual substitution confirmation
- manual customer communication
- manual fallback evidence
- later data entry candidate
- reconciliation requirement
- incident relation
- tenant/store isolation

This room does not implement manual fallback runtime.

---

## 5. Manual Fallback Trigger Catalog

Manual fallback may be triggered by:

| Trigger | Meaning |
|---|---|
| `POS_UNAVAILABLE` | POS unavailable or unsafe |
| `KDS_UNAVAILABLE` | KDS unavailable or unsafe |
| `PAYMENT_UNAVAILABLE` | Payment unavailable or uncertain |
| `DEVICE_UNAVAILABLE` | Device unavailable |
| `PRINTER_UNAVAILABLE` | Printer/peripheral unavailable |
| `NETWORK_UNAVAILABLE` | Network unavailable |
| `CONFIG_STALE` | Runtime configuration stale |
| `PROVIDER_CALLBACK_DELAYED` | Provider callback delayed |
| `LOCAL_CENTRAL_DIVERGENCE` | Local/central mismatch |
| `MENU_STATE_UNCERTAIN` | Menu/availability state uncertain |
| `STORE_INCIDENT_ACTIVE` | Incident requires manual handling |
| `STAFF_DECISION_REQUIRED` | Staff judgment required |
| `CUSTOMER_SERVICE_CONTINUITY` | Customer service continuity requires manual path |

Fallback trigger must be recorded.

---

## 6. Manual Fallback State Skeleton

Recommended manual fallback states:

| State | Meaning |
|---|---|
| `FALLBACK_NOT_ACTIVE` | Manual fallback not active |
| `FALLBACK_REQUIRED` | Manual fallback required |
| `FALLBACK_ORIGINATED` | Manual fallback started |
| `FALLBACK_CAPTURE_IN_PROGRESS` | Manual capture in progress |
| `FALLBACK_CAPTURED` | Manual evidence captured |
| `FALLBACK_STAFF_REVIEW_REQUIRED` | Staff review required |
| `FALLBACK_MANAGER_REVIEW_REQUIRED` | Manager review required |
| `FALLBACK_RECONCILIATION_REQUIRED` | Reconciliation required |
| `FALLBACK_RECOVERY_REVIEW_REQUIRED` | Recovery review required |
| `FALLBACK_DIGITAL_ENTRY_CANDIDATE` | Later digital entry candidate |
| `FALLBACK_RECONCILED` | Reconciled after review |
| `FALLBACK_CLOSED` | Closed after review |
| `FALLBACK_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 7. Tenant And Store Isolation Boundary

Manual fallback remains tenant/store scoped.

Every manual fallback record should carry:

- tenant id
- store id
- source room
- affected surface/device if applicable
- affected order/reference if applicable
- staff id if applicable
- fallback trigger
- fallback state
- evidence reference
- audit reference

A manual fallback record from Store A must never enter Store B records.

A manual fallback record from Tenant A must never enter Tenant B context.

Default:

`CROSS_TENANT_ACCESS_DENIED`

Manual fallback must follow `10141`.

---

## 8. Manual Order Capture Boundary

Manual order capture may include:

- customer order written on paper
- staff-confirmed item list
- quantity
- option/modifier
- dine-in/takeout/pickup marker
- time
- staff name/id if applicable
- customer identifier if needed and minimized
- special request if allowed
- fallback trigger
- later digital entry marker

Manual order capture must not:

- bypass validation permanently
- bypass price policy
- bypass allergen/safety notice
- create POS accepted truth
- create payment confirmed truth
- create KDS accepted truth
- silently replace digital order

Manual order is evidence.

It is not final digital truth.

---

## 9. Manual Kitchen Handoff Boundary

Manual kitchen handoff may include:

- verbal kitchen instruction
- handwritten kitchen ticket
- station note
- remake note
- delay note
- sold-out note
- packing note
- pickup note

Manual kitchen handoff must not:

- mark KDS accepted
- mark KDS completed
- confirm payment
- approve compensation
- hide manual origin
- bypass allergen/safety caution
- erase future reconciliation need

Manual kitchen handoff is operational survival.

It is not KDS truth.

---

## 10. Manual Payment Handling Boundary

Manual fallback must be extremely cautious around payment.

Manual payment handling may be prohibited by default unless separately authorized.

If a manual payment-related note is captured, it must distinguish:

- payment not attempted
- payment unavailable
- payment state unknown
- payment collected outside system if legally and operationally allowed later
- payment review required
- receipt note issued
- reconciliation required

Manual note must not claim:

- payment confirmed
- refund approved
- wallet credited
- point granted
- settlement complete

Financial Trust owns payment truth.

---

## 11. Manual Receipt Note Boundary

A manual receipt note may be needed for customer communication or store continuity.

Manual receipt note must not:

- represent verified payment unless Financial Trust verifies later
- represent official refund unless executed and verified
- include raw payment payload
- include unnecessary personal data
- conflict with later reconciliation
- erase payment uncertainty

Manual receipt note is customer service evidence.

It is not financial truth.

---

## 12. Manual Sold-Out Boundary

Manual sold-out may be discovered when digital menu availability is stale or unavailable.

Manual sold-out note should record:

- item
- time
- staff reference
- reason category
- affected orders if any
- customer communication status
- validation feedback requirement
- inventory/menu update candidate
- recovery review if customer impacted

Manual sold-out must not:

- silently delete customer order
- silently substitute item
- skip customer/staff confirmation
- skip evidence
- skip later menu availability reconciliation

Sold-out manual note must feed later review.

---

## 13. Manual Delay Boundary

Manual delay note may be captured when digital delay detection is unavailable or late.

Manual delay note should record:

- affected order/reference
- delay reason category
- estimated delay if allowed
- staff note
- customer guidance key
- kitchen/station context if allowed
- incident trigger if severe
- recovery review if customer impacted

Manual delay is not automatic compensation.

Delay evidence supports review.

---

## 14. Manual Remake Boundary

Manual remake note may be captured when:

- wrong item prepared
- item damaged
- quality issue
- allergen/safety concern
- customer correction
- staff/kitchen error
- packaging issue

Manual remake note must record:

- original item
- remake item
- reason category
- staff reference
- waste/incident reference if applicable
- customer guidance if needed
- recovery review if impacted

Manual remake is not refund approval.

Manual remake is not compensation approval.

---

## 15. Manual Substitution Boundary

Manual substitution must be controlled.

Manual substitution may occur only when:

- policy allows substitution
- customer/staff confirmation is captured if required
- allergen/safety rules are checked
- price impact is reviewed
- POS/KDS/payment impact is reviewed if applicable
- evidence is captured

Manual substitution must not be silent.

Substitution without evidence is prohibited.

---

## 16. Manual Data Entry Candidate Boundary

Manual fallback may later become a digital entry candidate.

Digital entry candidate must preserve:

- original manual source
- fallback marker
- staff reference
- timestamp
- uncertainty
- evidence reference
- reconciliation requirement
- review status
- original and corrected values if any

Later digital entry must not pretend it was original real-time system data.

Manual-origin data must remain traceable.

---

## 17. Manual Fallback Evidence Boundary

Manual fallback evidence may include:

- tenant id
- store id
- fallback id
- source room
- trigger category
- affected order/session/reference
- staff id
- manual note reference
- manual ticket image/reference if later allowed
- customer guidance key
- timestamp
- fallback state
- digital entry candidate marker
- reconciliation marker
- incident reference
- recovery reference
- audit reference

Evidence supports review.

Evidence is not approval.

---

## 18. Manual Fallback Safe Projection Boundary

Customer-safe fallback projection may show:

- staff will help you
- order is being checked
- kitchen is checking your order
- service is temporarily manual
- payment is being checked
- please ask staff
- order status is temporarily unavailable
- we are confirming your request

Customer-safe projection must not show:

- internal failure details
- raw provider error
- payment uncertainty details
- staff-only notes
- compensation promise
- legal conclusion
- security detail
- AI reasoning
- vector similarity
- cross-tenant/store information

Fallback messages must be i18n-controlled.

---

## 19. Staff Responsibility Boundary

Staff using manual fallback must:

- mark fallback origin
- preserve customer-safe communication
- avoid financial promises
- avoid provider blame
- capture minimal necessary evidence
- escalate when required
- follow store policy
- preserve tenant/store scope
- avoid silent substitution
- avoid silent deletion
- avoid silent correction

Manual fallback increases responsibility.

It does not grant unrestricted authority.

---

## 20. Manager Review Boundary

Manager review may be required when:

- manual fallback affects payment
- manual fallback affects POS/KDS reconciliation
- customer impact is material
- substitution occurred
- sold-out discovered after order
- severe delay occurred
- wrong item/remake occurred
- staff note is disputed
- incident relation exists
- recovery review is needed

Manager review is not financial approval unless separately authorized.

---

## 21. Reconciliation Boundary

Manual fallback often requires reconciliation.

Reconciliation may compare:

- manual order note
- intake record
- validation record
- POS state
- KDS state
- kitchen state
- payment state
- receipt note
- staff note
- incident record
- customer communication
- audit event

Reconciliation must not silently overwrite system truth.

Manual-origin correction must remain traceable.

---

## 22. Incident Boundary

Manual fallback may open incident when:

- digital system unavailable
- provider outage affected store
- POS/KDS/payment uncertainty exists
- manual fallback was prolonged
- customer was affected
- financial uncertainty exists
- cross-tenant anomaly suspected
- device compromise suspected
- staff misuse suspected
- repeated fallback pattern exists

Incident acknowledgement is not resolution.

Manual fallback incident must preserve evidence.

---

## 23. Recovery Route Boundary

Manual fallback may open recovery review when customer impact occurs.

Customer impact may include:

- order delayed
- order missing
- wrong item
- payment confusion
- receipt confusion
- unavailable item after order
- service breakdown
- customer complaint

Recovery review is not compensation execution.

Compensation belongs to Financial Trust.

---

## 24. Relationship To Degraded Operation Room

Degraded Operation may trigger Manual Fallback.

Manual Fallback captures survival operation.

Manual Fallback must report back to:

- Degraded Operation
- Store Incident
- Operational Evidence
- Reconciliation
- Recovery Review if needed

Degraded mode chooses or permits fallback.

Manual fallback records what actually happened.

---

## 25. Relationship To Staff Assist Room

Staff Assist may execute or guide manual fallback.

Staff Assist must not:

- skip fallback marker
- skip evidence
- promise refund/compensation
- suppress incident
- ignore tenant/store scope
- overwrite system state silently

Staff Assist is human route.

Manual Fallback is continuity capture.

---

## 26. Relationship To POS Handoff Room

Manual Fallback must not overwrite POS state.

If POS is unavailable or uncertain:

- mark fallback
- capture manual record
- block false POS success
- reconcile later
- avoid duplicate POS order
- avoid duplicate receipt/payment
- preserve idempotency if later entered

Manual fallback is not POS accepted.

---

## 27. Relationship To KDS Ticket And Kitchen Execution Rooms

Manual Fallback may replace digital KDS path temporarily.

It must distinguish:

- manual kitchen ticket
- KDS ticket
- physical preparation
- completion marker
- staff note
- later reconciliation

Manual kitchen ticket is not KDS accepted.

Physical preparation may occur without KDS truth, but must be marked fallback-originated.

---

## 28. Relationship To Financial Trust

Manual Fallback must defer financial truth to Side C.

Manual Fallback must not:

- confirm payment
- approve refund
- execute refund
- issue coupon
- adjust points
- mutate wallet
- approve compensation
- confirm settlement

Any payment uncertainty must route to Financial Trust review.

---

## 29. Relationship To Data Governance

Manual Fallback uses Side D for:

- i18n fallback messages
- staff SOP
- support/admin visibility
- incident learning
- recovery templates
- AI summary if later authorized
- vector context if later authorized
- analytics/read model if later authorized

Data Governance supports guidance.

It does not make fallback truth.

---

## 30. Manual Fallback Anti-Patterns

Avoid:

- manual note treated as system truth
- manual order treated as POS accepted
- manual kitchen ticket treated as KDS accepted
- manual receipt treated as payment confirmed
- manual staff promise treated as compensation approval
- manual substitution without confirmation
- manual sold-out silently deleting order
- manual delay hidden from customer
- manual fallback not marked
- later digital entry pretending real-time origin
- manual fallback overwriting central state
- fallback record missing tenant/store
- staff using fallback to bypass policy
- AI summarizing fallback as final truth
- vector similarity proving fallback correctness

These anti-patterns must be blocked in future runtime design.

---

## 31. Runtime Deferral

This document defines the Manual Fallback Room boundary only.

It does not authorize:

- fallback workflow implementation
- manual order entry runtime
- offline cache runtime
- image capture implementation
- staff tablet runtime
- POS/KDS reconciliation engine
- payment review workflow
- recovery workflow runtime
- incident workflow runtime
- database schema
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 32. Validation Checklist

Validation must confirm:

1. Manual Fallback Room definition is clear.
2. Manual fallback is survival mode, not data overwrite.
3. Trigger catalog is defined.
4. State skeleton is defined.
5. Tenant/store isolation is defined.
6. Manual order capture boundary is defined.
7. Manual kitchen handoff boundary is defined.
8. Manual payment handling boundary is defined.
9. Manual receipt note boundary is defined.
10. Manual sold-out boundary is defined.
11. Manual delay boundary is defined.
12. Manual remake boundary is defined.
13. Manual substitution boundary is defined.
14. Manual data entry candidate boundary is defined.
15. Evidence boundary is defined.
16. Safe Projection boundary is defined.
17. Staff responsibility boundary is defined.
18. Manager review boundary is defined.
19. Reconciliation boundary is defined.
20. Incident boundary is defined.
21. Recovery route boundary is defined.
22. Relationships to related rooms are defined.
23. Anti-patterns are listed.
24. Coding remains unauthorized.
25. Runtime remains deferred.

---

## 33. Relationship To Previous Documents

This document follows:

- `10290 Degraded Operation Room Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10260 Staff Assist Room Boundary Policy`
- `10290 Degraded Operation Room Boundary Policy`

It prepares:

- `10310 Store Incident Room Boundary Policy`
- `10320 Operational Evidence Room Boundary Policy`
- `10330 Fulfillment Visibility Room Boundary Policy`
- future manual fallback static specification packet

This document is room boundary planning only.

It does not authorize coding.

---

## 34. Final Rule

The Manual Fallback Room governs controlled survival operation when digital paths are degraded, unavailable, stale, or unsafe.

Manual fallback is not normal operation.

Manual fallback is not silent mutation.

Manual note is not system truth.

Manual order is not POS accepted.

Manual kitchen ticket is not KDS accepted.

Manual receipt note is not payment confirmed.

Manual staff promise is not compensation approval.

Manual fallback must always be marked `FALLBACK_ORIGINATED`, tenant/store scoped, evidence-bound, auditable, reconcilable, safely projected, and reviewable.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
