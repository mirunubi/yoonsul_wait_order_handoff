# 010220_Policy_Order_Validation_Room_Boundary

## 1. Purpose

This document defines the Order Validation Room Boundary Policy.

The previous artifact `10210` defined the Order Intake Room Boundary Policy.

This document frames the second Side B room:

`Order Validation Room`

The purpose is to define the boundary where captured order intent is checked against menu, price, availability, store state, surface eligibility, device eligibility, policy, feature entitlement, runtime configuration, and fallback conditions before any POS handoff, KDS ticketing, payment flow, or kitchen execution is attempted.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Order Validation Room receives an order intent from the Order Intake Room and determines whether the order intent may proceed toward controlled handoff.

The Order Validation Room does not mean the order is accepted.

The Order Validation Room does not mean POS accepted the order.

The Order Validation Room does not mean payment is confirmed.

The Order Validation Room does not mean KDS ticketing has occurred.

Validation is a gate.

It is not execution.

---

## 3. Core Principle

Validation prepares an order for handoff.

Validation does not complete the order.

The correct rule is:

Intake is not validation.  
Validation is not POS handoff.  
Validation is not payment confirmation.  
Validation is not KDS ticket creation.  
Validation is not kitchen execution.  
Validation is not refund, compensation, or recovery approval.  

Validation confirms whether the intent may move to the next room.

It does not create final operational or financial truth.

---

## 4. Scope

The Order Validation Room may evaluate:

- tenant context
- store context
- surface context
- device context
- customer/session context
- menu version
- item availability
- sold-out status
- price version
- option compatibility
- allergen notice requirement
- store operating status
- order channel policy
- order type policy
- staff assist requirement
- runtime configuration
- feature entitlement
- fallback requirement
- degraded operation condition
- provider readiness reference if applicable

This room does not execute provider calls.

This room does not execute payment.

---

## 5. Validation Input Boundary

Validation input may include:

| Input | Meaning |
|---|---|
| `order_intent_id` | Intake reference |
| `tenant_id` | Tenant context |
| `store_id` | Store context |
| `surface_id` | Surface source |
| `device_id` | Device source if applicable |
| `session_id` | Customer/session reference |
| `selected_items` | Captured item list |
| `options` | Captured option list |
| `quantity` | Requested quantities |
| `menu_version` | Menu version shown |
| `price_version` | Price version shown |
| `locale` | Customer locale |
| `order_type` | dine-in/takeout/waiting/etc. if applicable |
| `staff_assist_requested` | Assist flag |
| `intake_status` | Prior room status |
| `fallback_marker` | Fallback if originated |

Validation input is evidence.

It is not accepted order.

---

## 6. Validation Output Boundary

Validation output may include:

| Output | Meaning |
|---|---|
| `validation_id` | Validation reference |
| `validation_status` | Validation result |
| `handoff_eligible` | Whether handoff may be attempted later |
| `staff_assist_required` | Human intervention required |
| `fallback_required` | Fallback path required |
| `blocked_reason_category` | Safe blocked reason |
| `safe_projection_reference` | Surface-safe output |
| `validation_evidence_reference` | Evidence reference |
| `next_room_candidate` | POS/KDS/payment/order route candidate |
| `audit_placeholder` | Future audit reference |

Validation output is not POS acceptance.

Validation output is not payment confirmation.

---

## 7. Validation State Skeleton

Recommended validation states:

| State | Meaning |
|---|---|
| `VALIDATION_NOT_STARTED` | Validation not started |
| `VALIDATION_STARTED` | Validation started |
| `VALIDATION_INPUT_INCOMPLETE` | Required intake data missing |
| `VALIDATION_MENU_VERSION_STALE` | Menu version stale |
| `VALIDATION_PRICE_VERSION_STALE` | Price version stale |
| `VALIDATION_ITEM_UNAVAILABLE` | Item unavailable |
| `VALIDATION_OPTION_INVALID` | Option invalid |
| `VALIDATION_STORE_UNAVAILABLE` | Store unavailable |
| `VALIDATION_SURFACE_NOT_ALLOWED` | Surface not allowed |
| `VALIDATION_DEVICE_NOT_ALLOWED` | Device not allowed |
| `VALIDATION_POLICY_BLOCKED` | Policy blocks order |
| `VALIDATION_STAFF_ASSIST_REQUIRED` | Human assist required |
| `VALIDATION_FALLBACK_REQUIRED` | Fallback required |
| `VALIDATION_READY_FOR_HANDOFF` | Eligible for next room |
| `VALIDATION_REJECTED` | Rejected before handoff |
| `VALIDATION_UNKNOWN` | Validation uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. Menu Validation Boundary

Menu validation may check:

- item exists in current menu
- item was visible to the surface
- item is orderable through that surface
- item is available at the store
- item is not sold out
- item is compatible with order type
- item option rules are satisfied
- item requires staff confirmation
- item requires allergen notice
- item requires special handling

Menu validation must not:

- override menu master truth
- silently substitute items
- guarantee kitchen capacity
- bypass sold-out policy
- bypass allergen notice policy

Menu eligibility is not kitchen completion.

---

## 9. Price Validation Boundary

Price validation may check:

- price version shown
- current approved price
- channel-specific price rule
- store-specific price rule
- option price rule
- discount eligibility placeholder
- coupon eligibility placeholder
- tax/service rule placeholder if applicable
- stale price condition

Price validation must not:

- execute payment
- apply wallet/prepaid balance
- issue coupon
- grant points
- confirm settlement
- create final receipt

Price validation prepares handoff.

It is not financial execution.

---

## 10. Availability Validation Boundary

Availability validation may check:

- item availability
- sold-out status
- limited quantity status
- time window
- kitchen capacity placeholder
- store operating status
- manual sold-out marker
- inventory warning if later connected
- provider/channel availability if applicable

Availability validation must not:

- create inventory mutation
- force item sale
- hide uncertainty
- override manual sold-out evidence
- promise fulfillment

Availability is evidence-bound.

---

## 11. Option And Modifier Validation Boundary

Option validation may check:

- option exists
- option is allowed for item
- option quantity limit
- incompatible option combinations
- required option missing
- allergen-sensitive option
- price-impacting option
- kitchen-sensitive option

Option validation must not:

- create new menu option
- override kitchen rules
- change customer intent silently
- apply unapproved substitution

Invalid option requires safe projection or staff assist.

---

## 12. Allergen And Safety Notice Boundary

Allergen and safety-related validation must be conservative.

Validation may require:

- allergen notice shown
- ingredient notice shown
- cross-contact warning if applicable
- staff assist if uncertain
- blocked order if required notice unavailable
- i18n key availability
- CMS/legal review reference if applicable

Validation must not:

- guarantee medical safety
- infer allergy safety from AI
- bypass missing allergen notice
- hide uncertainty from customer
- present legal assurance without review

Allergen uncertainty should route to staff assist or block.

---

## 13. Store State Validation Boundary

Store state validation may check:

- store open/closed
- temporary pause
- degraded operation
- order channel availability
- kitchen acceptance window
- pickup/dine-in eligibility
- waiting/seating context if applicable
- device-specific service mode
- manual fallback mode
- incident mode

Store state validation must not:

- reopen store automatically
- override manual stop
- bypass degraded mode
- bypass incident containment
- force operational acceptance

Store availability must be explicit.

---

## 14. Surface And Device Eligibility Boundary

Surface/device validation may check:

- surface type allowed
- device profile valid
- runtime config current
- device not revoked
- device not suspended
- kiosk mode valid if applicable
- app version acceptable if later implemented
- locale supported
- feature enabled for surface
- emergency disabled flag

Surface/device validation must not:

- grant authority by device possession
- bypass tenant/store policy
- bypass provider evidence
- bypass runtime configuration
- bypass emergency disable

Device role is not authority.

---

## 15. Tenant Feature And Package Boundary

Validation may check:

- tenant entitlement
- SaaS package eligibility
- store activation status
- feature plan
- package limitation
- add-on eligibility
- trial/pilot status
- expiry/suspension status

Validation must preserve:

SaaS entitlement is not runtime authority.

Package inclusion does not prove provider capability.

Feature enabled for tenant does not mean store/device/surface may execute.

---

## 16. Policy Gate Boundary

Validation may check policy gates such as:

- channel policy
- order type policy
- menu policy
- price policy
- staff assist policy
- degraded operation policy
- fallback policy
- payment-required policy
- POS/KDS handoff policy
- customer message policy
- allergen notice policy

Policy gate result may block, allow, or require review.

Policy reference is not runtime enforcement until implementation is separately authorized.

---

## 17. Provider Readiness Reference Boundary

Validation may reference provider readiness only at a safe level.

It may check:

- provider profile assigned
- provider capability status
- provider evidence status
- provider degraded mode flag
- provider disabled flag
- provider limitation note

Validation must not:

- call provider
- verify payment provider status
- send POS request
- send KDS ticket
- assume provider capability without evidence
- expose raw provider limitation to customer

Provider readiness reference is not provider execution.

---

## 18. Staff Assist Requirement Boundary

Validation may require staff assist when:

- item or option is uncertain
- allergen notice is missing
- price version is stale
- availability is uncertain
- device config is stale
- store state is degraded
- customer request needs human review
- policy requires manual confirmation
- fallback originated
- validation uncertainty exists

Staff assist is not validation override.

Staff assist routes human review.

---

## 19. Fallback Requirement Boundary

Validation may require fallback when:

- menu version is stale
- price version is stale
- store state is uncertain
- device state is uncertain
- provider readiness is uncertain
- network/degraded condition exists
- input cannot be safely validated
- external channel payload is inconsistent
- staff assist route is required but unavailable

Fallback is not silent acceptance.

Fallback must preserve evidence.

---

## 20. Validation Evidence Boundary

Validation evidence may include:

- intake reference
- menu version checked
- price version checked
- item availability check result
- option rule result
- allergen notice status
- store state result
- device/surface status
- tenant entitlement status
- policy gate result
- provider readiness reference
- blocked reason category
- staff assist flag
- fallback flag
- timestamp
- future audit reference

Validation evidence supports review.

Evidence is not approval.

---

## 21. Validation Safe Projection Boundary

Customer-safe validation output may show:

- item unavailable
- option unavailable
- staff assistance required
- menu needs refresh
- price needs confirmation
- store temporarily unavailable
- device cannot continue
- order cannot proceed now
- please ask staff
- try again later

Customer-safe validation output must not show:

- raw internal rules
- raw provider errors
- payment truth
- POS/KDS state
- financial exception detail
- legal/security detail
- staff-only note
- AI reasoning
- vector similarity

Safe Projection controls visibility.

---

## 22. Relationship To Order Intake Room

Order Validation receives intake candidates.

Validation must reject or route incomplete intake.

Validation must preserve intake evidence.

Validation must not rewrite customer intent silently.

If input is incomplete, validation may return:

`VALIDATION_INPUT_INCOMPLETE`

or route to staff assist/fallback.

---

## 23. Relationship To POS Handoff Room

Only validation output marked:

`VALIDATION_READY_FOR_HANDOFF`

may become a POS handoff candidate later.

Even then, POS handoff requires separate room authority and future runtime authorization.

Validation does not call POS.

Validation does not create POS truth.

---

## 24. Relationship To KDS Ticket Room

Validation may identify future KDS ticket eligibility.

Validation does not create KDS ticket.

Validation does not assign kitchen station.

Validation does not mark cooking started.

Validation does not mark fulfillment complete.

KDS Ticket Room owns ticket boundary later.

---

## 25. Relationship To Financial Trust

Validation may identify whether payment is required.

Validation must not:

- create payment request
- confirm payment
- approve refund
- issue coupon
- adjust points
- mutate wallet
- execute compensation
- confirm settlement

Financial actions belong to Side C.

---

## 26. Relationship To Data Governance

Validation uses Side D for:

- i18n message keys
- customer-safe validation messages
- allergen notice governance
- CMS notice references if relevant
- policy references
- support/admin visibility
- analytics/read model if later authorized
- AI advisory only if later authorized
- pgvector reference only if later authorized

Data Governance supports validation visibility.

It does not validate by itself.

---

## 27. Validation Anti-Patterns

Avoid:

- validation treated as accepted order
- validation treated as POS handoff
- validation treated as payment confirmation
- stale price silently accepted
- unavailable item silently substituted
- allergen uncertainty hidden
- device eligibility treated as authority
- SaaS entitlement treated as runtime authority
- provider profile treated as provider capability proof
- staff assist treated as validation override
- fallback treated as silent acceptance
- AI recommendation treated as validation result
- vector similarity treated as product/menu proof

These anti-patterns must be blocked in future runtime design.

---

## 28. Runtime Deferral

This document defines the Order Validation Room boundary only.

It does not authorize:

- validation API implementation
- database schema
- menu validation engine
- price validation engine
- availability engine
- allergen engine
- provider call
- POS handoff
- KDS ticketing
- payment flow
- coupon/point/wallet logic
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 29. Validation Checklist

Validation must confirm:

1. Order Validation Room definition is clear.
2. Validation does not mean execution.
3. Input boundary is defined.
4. Output boundary is defined.
5. Validation states are defined.
6. Menu validation boundary is defined.
7. Price validation boundary is defined.
8. Availability validation boundary is defined.
9. Option/modifier validation boundary is defined.
10. Allergen/safety notice boundary is defined.
11. Store state validation boundary is defined.
12. Surface/device eligibility boundary is defined.
13. Tenant feature/package boundary is defined.
14. Policy gate boundary is defined.
15. Provider readiness reference boundary is defined.
16. Staff assist requirement is defined.
17. Fallback requirement is defined.
18. Validation evidence boundary is defined.
19. Safe Projection boundary is defined.
20. Relationship to Order Intake Room is defined.
21. Relationship to POS Handoff Room is defined.
22. Relationship to KDS Ticket Room is defined.
23. Relationship to Financial Trust is defined.
24. Relationship to Data Governance is defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 30. Relationship To Previous Documents

This document follows:

- `10210 Order Intake Room Boundary Policy`

It references:

- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10048 SaaS Packaging Pricing Boundary And Feature Entitlement Policy`

It prepares:

- `10230 POS Handoff Room Boundary Policy`
- `10240 KDS Ticket Room Boundary Policy`
- `10250 Kitchen Execution Room Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 31. Final Rule

The Order Validation Room checks whether captured order intent may proceed toward controlled handoff.

Validation is not acceptance.

Validation is not POS handoff.

Validation is not KDS ticket creation.

Validation is not payment confirmation.

Validation is not financial mutation.

Validation is not customer recovery or compensation execution.

Validation must preserve menu, price, availability, allergen, store, surface, device, package, policy, provider readiness, staff assist, fallback, evidence, audit, i18n, and Safe Projection boundaries.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
