# 10210 Order Intake Room Boundary Policy

## 1. Purpose

This document defines the Order Intake Room Boundary Policy.

The previous artifact `10200` defined the Store Room Framing and Runtime Domain Boundary Index.

This document frames the first Side B room:

`Order Intake Room`

The purpose is to define the boundary where customer, staff, kiosk, and future external-channel order intent enters the platform before validation, POS handoff, KDS ticketing, payment verification, kitchen execution, or recovery workflow occurs.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Order Intake Room is the entry room for order intent.

It receives a proposed order from an approved surface or channel and records the fact that an order attempt may exist.

The Order Intake Room does not decide that the order is valid.

The Order Intake Room does not decide that the order is accepted.

The Order Intake Room does not decide that payment is confirmed.

The Order Intake Room does not decide that POS/KDS handoff succeeded.

Order intake is the beginning of a controlled workflow.

It is not fulfillment.

---

## 3. Core Principle

Order intent is not accepted order.

The correct rule is:

Customer selection is not order acceptance.  
Cart is not order.  
Order intent is not POS accepted.  
POS accepted is not payment confirmed.  
Payment confirmed is not KDS completed.  
KDS completed is not settlement.  
Staff assist is not approval.  
AI suggestion is not order creation authority.  

The Order Intake Room captures intent and context.

It does not create final truth.

---

## 4. Scope

The Order Intake Room may receive order intent from:

- Catch Menu
- Catch & Order
- Mini Kiosk
- Full Kiosk
- staff tablet
- owner/admin assisted surface if later authorized
- support/admin assisted flow if later authorized
- future external channel if later authorized
- future Franchise OS governed store template if later authorized

This room may define intake structure only.

It does not authorize runtime intake.

---

## 5. Intake Input Boundary

Order intake input may include:

| Input | Meaning |
|---|---|
| `tenant_id` | Tenant context |
| `store_id` | Store context |
| `surface_id` | Surface that initiated intent |
| `device_id` | Device if applicable |
| `session_id` | Customer/session reference |
| `locale` | Customer language/locale |
| `menu_version` | Menu version shown |
| `price_version` | Price version shown |
| `selected_items` | Items selected by customer/staff |
| `options` | Item options or modifiers |
| `quantity` | Quantity requested |
| `special_request` | Customer note if allowed |
| `staff_assist_requested` | Staff assist marker |
| `intake_channel` | Source channel |
| `created_at` | Capture time |
| `safe_message_key` | i18n key for visible state |

Inputs are not final accepted order fields.

They are intake evidence.

---

## 6. Intake Output Boundary

Order intake output may include:

| Output | Meaning |
|---|---|
| `order_intent_id` | Stable intent reference |
| `intake_status` | Intake room status |
| `validation_required` | Validation must occur |
| `staff_assist_required` | Human assist required |
| `fallback_required` | Fallback route needed |
| `blocked_reason_category` | Safe blocked reason |
| `safe_projection_reference` | Customer-safe output |
| `audit_placeholder` | Future audit reference |
| `evidence_reference` | Intake evidence reference |

Output must route to validation.

Output must not represent accepted order.

---

## 7. Order Intake State Skeleton

Recommended intake states:

| State | Meaning |
|---|---|
| `INTAKE_NOT_STARTED` | No intake attempt |
| `INTAKE_STARTED` | Intake started |
| `INTAKE_CAPTURED` | Intake captured |
| `INTAKE_INCOMPLETE` | Missing required input |
| `INTAKE_SURFACE_NOT_ALLOWED` | Surface not allowed |
| `INTAKE_DEVICE_NOT_ALLOWED` | Device not allowed |
| `INTAKE_STORE_NOT_AVAILABLE` | Store unavailable |
| `INTAKE_STAFF_ASSIST_REQUIRED` | Staff assist needed |
| `INTAKE_FALLBACK_REQUIRED` | Fallback needed |
| `INTAKE_READY_FOR_VALIDATION` | Ready for validation room |
| `INTAKE_REJECTED_PRE_VALIDATION` | Rejected before validation |
| `INTAKE_UNKNOWN` | Intake uncertainty |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. Surface Intake Boundary

Surfaces may request intake, but surfaces do not accept orders.

Surface examples:

| Surface | Intake Role |
|---|---|
| Catch Menu | May start lightweight order intent if enabled later |
| Catch & Order | May start order intent |
| Mini Kiosk | May start device-based order intent |
| Full Kiosk | May start richer order intent if authorized later |
| Staff Tablet | May assist or enter intent if authorized later |
| Admin Surface | Should not create customer order by default |
| Franchise OS | Should not create store order directly |

Surface request must pass through Use Case API and policy gate in future runtime.

---

## 9. Device Intake Boundary

Device participation must be safe.

Device intake may require:

- Device Profile
- Runtime Configuration
- surface role
- config version
- locale set
- store assignment
- device status
- revocation status
- degraded status
- fallback status

A device must not create authority by existence.

A kiosk device is not trusted merely because it is installed.

Device role is not authority.

---

## 10. Session Boundary

Order intake may rely on a customer/session reference.

Session may represent:

- anonymous customer session
- QR/NFC session
- Mini Kiosk session
- Full Kiosk session
- table/waiting context if later authorized
- staff-assisted session
- future membership identity if later authorized

Session identity is not payment identity.

Session identity is not legal identity.

Session continuity must be separated from financial confirmation.

---

## 11. Menu And Price Version Boundary

Order intake must preserve the menu and price version shown to the customer.

Captured version references may include:

- menu version
- item version
- option version
- price version
- availability snapshot
- allergen notice version
- CMS notice version if relevant
- locale/message key version

This protects later review.

However, shown price version does not guarantee acceptance until validation confirms policy.

---

## 12. Special Request Boundary

Special requests must be controlled.

Special request may include:

- customer note
- allergy-related note
- preparation request
- packaging request
- dining/takeout request
- staff assistance request

Special request must not:

- override menu policy
- override allergen policy
- override price
- override kitchen capacity
- bypass validation
- create legal or medical assurance
- create compensation promise

Special request is input.

It is not approval.

---

## 13. Staff-Assisted Intake Boundary

Staff may assist intake when authorized later.

Staff-assisted intake must record:

- staff id if applicable
- reason for assistance
- source surface
- customer context
- selected items
- staff note if allowed
- fallback marker if applicable
- audit/evidence placeholder

Staff assistance must not:

- bypass validation
- bypass payment verification
- create refund authority
- create compensation authority
- hide customer-facing uncertainty
- silently rewrite customer intent

Staff-assisted intake is still intake.

---

## 14. External Channel Intake Boundary

Future external channels may include:

- delivery app
- marketplace
- reservation/waiting app
- workforce/event channel if relevant
- Franchise OS external integration
- partner channel

External channel intake must be limited-trust.

External channel intake must preserve:

- source channel
- external reference
- payload snapshot if allowed
- provider evidence class
- idempotency key if applicable
- reconciliation requirement if needed
- safe projection boundary

External channel order is not internal accepted order until validated.

---

## 15. Intake Evidence Boundary

Order intake evidence may include:

- surface id
- device id
- session id
- menu/price version
- selected item list
- options
- quantity
- locale
- staff assist flag
- source timestamp
- customer-safe message key
- fallback marker
- external channel reference if any
- validation route reference

Evidence supports review.

Evidence is not acceptance.

---

## 16. Intake Safe Projection Boundary

Customer-facing intake projection may show only safe states.

Allowed customer-safe messages may include:

- order is being prepared for review
- item needs confirmation
- staff assistance is required
- store is temporarily unavailable
- device is unavailable
- menu information is being refreshed
- order cannot proceed now
- please ask staff

Customer-facing intake projection must not show:

- raw provider errors
- internal validation reason
- payment truth
- POS state
- KDS state
- compensation promise
- legal conclusion
- security detail
- AI reasoning

Safe Projection controls customer visibility.

---

## 17. Intake Fallback Boundary

Fallback may be required when:

- surface is unavailable
- device config is stale
- store state is uncertain
- menu version is stale
- order input is incomplete
- staff assist required
- network is unstable
- external channel payload is uncertain
- validation room is unavailable

Fallback must route to:

- staff assist
- manual fallback
- retry later
- safe cancellation of intake
- support route if later authorized

Fallback is not silent acceptance.

---

## 18. Intake Audit Boundary

Future intake audit may record:

- intake started
- intake captured
- intake incomplete
- intake blocked
- staff assist requested
- fallback required
- external channel intake received
- intake routed to validation
- intake rejected before validation

Audit does not make intake accepted.

Audit records the transition.

---

## 19. Relationship To Order Validation Room

The Order Intake Room must route valid intake candidates to the Order Validation Room.

The Order Validation Room decides whether the intake is eligible for handoff.

Order Intake must not perform full validation.

Order Intake may only perform minimal structural checks such as:

- required input present
- surface allowed placeholder
- device allowed placeholder
- store context present
- selected item list present

Business validation belongs to the Order Validation Room.

---

## 20. Relationship To POS Handoff Room

The Order Intake Room must not call POS.

POS handoff may occur only after validation and future authorization.

Order Intake must not create:

- POS request
- POS acceptance
- POS rejection
- POS receipt
- POS payment relation
- POS reconciliation status

POS Handoff Room owns POS boundary later.

---

## 21. Relationship To KDS Ticket Room

The Order Intake Room must not create KDS tickets.

KDS ticketing may occur only after validation, POS/payment/order policy, and future authorization.

Order Intake must not create:

- KDS ticket
- KDS station route
- cooking started state
- KDS completion state
- kitchen delay state

KDS Ticket Room owns KDS boundary later.

---

## 22. Relationship To Financial Trust

The Order Intake Room must not confirm financial state.

Order Intake must not create:

- payment confirmation
- refund request approval
- coupon issue
- point adjustment
- wallet mutation
- settlement candidate
- compensation execution

Financial Trust belongs to Side C.

---

## 23. Relationship To Data Governance

The Order Intake Room must use Side D for:

- i18n message keys
- Safe Projection messages
- CMS notice references if relevant
- policy references
- support visibility references
- analytics/read model references if later authorized
- AI/pgvector advisory only if later authorized

Data Governance shapes visibility and policy.

It does not accept orders.

---

## 24. Intake Anti-Patterns

Avoid:

- cart treated as order
- order intent treated as accepted order
- customer note treated as approved request
- staff assist treated as validation
- device presence treated as authority
- session identity treated as payment identity
- shown price treated as final acceptance without validation
- external channel payload treated as internal truth
- AI-suggested item treated as customer order
- intake audit treated as POS handoff
- fallback treated as silent acceptance

These anti-patterns must be blocked in later runtime design.

---

## 25. Runtime Deferral

This document defines the Order Intake Room boundary only.

It does not authorize:

- intake API implementation
- frontend cart implementation
- Kiosk order implementation
- database schema
- order table creation
- POS handoff
- KDS ticketing
- payment workflow
- staff tablet runtime
- external channel integration
- AI recommendation runtime
- pgvector context runtime
- production deployment

All runtime remains deferred.

---

## 26. Validation Checklist

Validation must confirm:

1. Order Intake Room definition is clear.
2. Intake does not mean accepted order.
3. Input boundary is defined.
4. Output boundary is defined.
5. Intake states are defined.
6. Surface intake boundary is defined.
7. Device intake boundary is defined.
8. Session boundary is defined.
9. Menu/price version boundary is defined.
10. Special request boundary is defined.
11. Staff-assisted intake boundary is defined.
12. External channel intake boundary is defined.
13. Intake evidence boundary is defined.
14. Safe Projection boundary is defined.
15. Fallback boundary is defined.
16. Audit boundary is defined.
17. Relationship to Order Validation Room is defined.
18. Relationship to POS Handoff Room is defined.
19. Relationship to KDS Ticket Room is defined.
20. Relationship to Financial Trust is defined.
21. Relationship to Data Governance is defined.
22. Anti-patterns are listed.
23. Coding remains unauthorized.
24. Runtime remains deferred.

---

## 27. Relationship To Previous Documents

This document follows:

- `10200 Store Room Framing And Runtime Domain Boundary Index`

It references:

- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10047 Product Line Capability Matrix And Surface Reuse Registry Policy`

It prepares:

- `10220 Order Validation Room Boundary Policy`
- `10230 POS Handoff Room Boundary Policy`
- `10240 KDS Ticket Room Boundary Policy`
- `10250 Kitchen Execution Room Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 28. Final Rule

The Order Intake Room captures order intent and context.

It does not create accepted order truth.

It does not validate the full order.

It does not call POS.

It does not create KDS ticket.

It does not confirm payment.

It does not approve refund, coupon, point, wallet, compensation, or recovery execution.

Order intake must route to validation through controlled authority, evidence, audit, fallback, policy, i18n, and Safe Projection beams.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.