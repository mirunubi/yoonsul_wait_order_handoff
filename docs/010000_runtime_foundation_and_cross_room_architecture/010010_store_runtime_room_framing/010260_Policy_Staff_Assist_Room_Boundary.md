# 010260_Policy_Staff_Assist_Room_Boundary

## 1. Purpose

This document defines the Staff Assist Room Boundary Policy.

The previous artifact `10250` defined the Kitchen Execution Room Boundary Policy.

This document frames the sixth Side B room:

`Staff Assist Room`

The purpose is to define the boundary where human intervention, store staff assistance, customer guidance, operational review, manual confirmation, and escalation routing occur without becoming hidden authority for validation, POS handoff, KDS ticketing, payment confirmation, refund, compensation, CMS publication, AI decision, or system state overwrite.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Staff Assist Room is the human intervention route for operational uncertainty.

It may later coordinate:

- customer help request
- staff confirmation
- menu uncertainty handling
- item availability clarification
- allergen/safety escalation
- device issue response
- payment unavailable guidance
- POS/KDS failure guidance
- kitchen delay explanation
- manual fallback routing
- recovery route initiation
- support escalation
- incident relation

Staff Assist does not mean resolution.

Staff Assist does not mean approval.

Staff Assist does not mean financial authority.

Staff Assist is a route to a human-controlled operational decision path.

---

## 3. Core Principle

Staff assist is not authority expansion.

The correct rule is:

Staff assist is not validation override.  
Staff assist is not POS acceptance.  
Staff assist is not KDS completion.  
Staff assist is not payment confirmation.  
Staff assist is not refund approval.  
Staff assist is not compensation execution.  
Staff assist is not CMS publication.  
Staff assist is not incident resolution.  
Staff assist is not legal conclusion.  

Staff assist must be scoped, auditable, evidence-bound, and safely projected.

---

## 4. Scope

The Staff Assist Room may define planning boundaries for:

- assist request
- assist reason category
- staff assignment candidate
- customer-safe assist message
- staff-visible assist context
- escalation requirement
- manual confirmation path
- fallback path
- incident relation
- recovery route relation
- evidence reference
- audit placeholder
- tenant/store isolation

This room does not implement staff workflow runtime.

---

## 5. Staff Assist Input Boundary

Staff assist input may include:

| Input | Meaning |
|---|---|
| `tenant_id` | Tenant context |
| `store_id` | Store context |
| `assist_request_id` | Assist request reference |
| `source_room` | Room that triggered assist |
| `surface_id` | Source surface |
| `device_id` | Source device if applicable |
| `session_id` | Customer/session reference |
| `order_intent_id` | Order intent reference if applicable |
| `validation_id` | Validation reference if applicable |
| `pos_handoff_id` | POS reference if applicable |
| `kds_ticket_id` | KDS reference if applicable |
| `kitchen_execution_id` | Kitchen reference if applicable |
| `assist_reason_category` | Safe reason category |
| `safe_message_key` | Customer-safe message key |
| `fallback_marker` | Fallback marker if applicable |

Input must be tenant/store scoped.

Input must not include unrestricted sensitive data by default.

---

## 6. Staff Assist Output Boundary

Staff assist output may include:

| Output | Meaning |
|---|---|
| `assist_result_id` | Assist result reference |
| `assist_status` | Assist state |
| `staff_id` | Acting staff if applicable |
| `staff_note_reference` | Staff note reference |
| `customer_guidance_key` | Customer-safe message key |
| `manual_confirmation_marker` | Manual confirmation marker |
| `fallback_required` | Whether fallback is required |
| `incident_required` | Whether incident route is required |
| `recovery_review_required` | Whether recovery review is required |
| `next_room_candidate` | Candidate room to route next |
| `evidence_reference` | Staff assist evidence reference |
| `audit_placeholder` | Future audit reference |

Output must not represent final approval unless a separate authority policy allows it.

---

## 7. Staff Assist State Skeleton

Recommended staff assist states:

| State | Meaning |
|---|---|
| `ASSIST_NOT_REQUESTED` | No assist request |
| `ASSIST_REQUESTED` | Assist requested |
| `ASSIST_ACKNOWLEDGED` | Staff acknowledged |
| `ASSIST_IN_PROGRESS` | Staff assisting |
| `ASSIST_INFORMATION_PROVIDED` | Information provided |
| `ASSIST_MANUAL_CONFIRMATION_REQUIRED` | Manual confirmation required |
| `ASSIST_FALLBACK_REQUIRED` | Fallback required |
| `ASSIST_ESCALATION_REQUIRED` | Escalation required |
| `ASSIST_RECOVERY_REVIEW_REQUIRED` | Recovery route required |
| `ASSIST_COMPLETED` | Assist completed |
| `ASSIST_UNRESOLVED` | Assist did not resolve issue |
| `ASSIST_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. Tenant And Store Isolation Boundary

Staff assist is tenant/store scoped.

Every staff assist record must carry:

- tenant id
- store id
- source surface/device
- related order or room reference if applicable
- staff reference if applicable
- evidence reference
- audit reference

A staff assist request from Store A must never appear in Store B staff queue.

A staff assist record from Tenant A must never appear in Tenant B context.

Default:

`CROSS_TENANT_ACCESS_DENIED`

Staff assist must follow `10141`.

---

## 9. Assist Reason Category Boundary

Assist reason categories should be safe and structured.

Recommended categories:

| Category | Meaning |
|---|---|
| `MENU_UNCERTAIN` | Menu information unclear |
| `ITEM_UNAVAILABLE` | Item unavailable |
| `PRICE_CONFIRMATION_REQUIRED` | Price confirmation needed |
| `ALLERGEN_REVIEW_REQUIRED` | Allergen/safety review needed |
| `DEVICE_ISSUE` | Device issue |
| `PAYMENT_UNAVAILABLE` | Payment unavailable |
| `POS_HANDOFF_ISSUE` | POS handoff issue |
| `KDS_OR_KITCHEN_DELAY` | KDS/kitchen delay |
| `MANUAL_FALLBACK_REQUIRED` | Manual fallback needed |
| `CUSTOMER_REQUEST_HELP` | Customer requested help |
| `RECOVERY_REVIEW_NEEDED` | Recovery route needed |
| `UNKNOWN_OPERATIONAL_ISSUE` | Unknown issue |

Reason category should be customer-safe or mapped to customer-safe message keys.

---

## 10. Staff Role Boundary

Not every staff member may perform every assist action.

Staff role boundary may distinguish:

| Staff Role | Possible Assist Boundary |
|---|---|
| Crew | customer guidance, basic order help |
| Station Staff | kitchen/task clarification |
| Shift Lead | manual confirmation, issue routing |
| Manager | degraded operation, recovery route |
| Owner | store-level review |
| Support Admin | remote case support |
| Finance Admin | financial review only |
| HQ Admin | policy/governance review |

Staff role must not grant automatic financial authority.

Store staff may assist.

Finance actions require financial authority.

---

## 11. Customer Guidance Boundary

Staff may provide customer guidance through approved messages or direct conversation.

System-projected guidance should use i18n keys.

Customer guidance must not:

- promise refund
- promise compensation
- blame provider without review
- confirm payment without verification
- confirm POS/KDS truth without evidence
- provide legal conclusion
- expose internal staff note
- expose raw error details
- expose cross-tenant/store information

Customer guidance should be safe, calm, and non-blaming.

---

## 12. Manual Confirmation Boundary

Manual confirmation may be needed when:

- customer changes request
- item substitution is proposed
- allergen/safety notice needs confirmation
- price version is stale
- order type is uncertain
- POS/KDS state is uncertain
- fallback originated
- kitchen sold-out discovery occurred
- staff needs to confirm continuation

Manual confirmation must be recorded.

Manual confirmation must not silently overwrite prior state.

Manual confirmation is not financial approval unless separately authorized.

---

## 13. Staff Note Boundary

Staff notes may include:

- customer requested help
- item clarification
- kitchen clarification
- device issue observation
- manual fallback note
- delay explanation
- substitution discussion
- recovery route reason
- incident relation

Staff notes must not include:

- unnecessary personal data
- raw payment payload
- provider credentials
- legal conclusion
- medical guarantee
- unreviewed blame statement
- compensation promise
- cross-tenant/store data
- AI reasoning as fact

Staff note is evidence.

Staff note is not final truth by itself.

---

## 14. Escalation Boundary

Staff assist may escalate to:

- shift lead
- manager
- support admin
- finance admin
- provider ops
- security admin
- legal/admin review
- incident room
- recovery route room
- manual fallback room
- degraded operation room

Escalation must preserve:

- reason category
- evidence reference
- current state
- customer-safe message
- tenant/store scope
- audit reference

Escalation is not resolution.

---

## 15. Relationship To Order Intake Room

Order Intake may route to Staff Assist when:

- customer needs help
- input incomplete
- surface cannot continue
- device state uncertain
- special request needs staff
- fallback required

Staff Assist must not convert incomplete intake into accepted order without validation.

---

## 16. Relationship To Order Validation Room

Order Validation may route to Staff Assist when:

- item unavailable
- price stale
- option invalid
- allergen review required
- store state uncertain
- policy requires manual review
- provider readiness uncertain
- fallback required

Staff Assist may clarify or route.

It must not bypass validation gate.

---

## 17. Relationship To POS Handoff Room

POS Handoff may route to Staff Assist when:

- POS rejected
- POS timeout occurred
- duplicate risk exists
- POS degraded mode active
- retry review required
- manual fallback needed
- provider status uncertain

Staff Assist may help choose route.

It must not confirm POS acceptance or payment.

---

## 18. Relationship To KDS Ticket Room

KDS Ticket may route to Staff Assist when:

- KDS rejected
- KDS timeout occurred
- ticket duplicate risk exists
- station routing failed
- KDS degraded mode active
- manual kitchen fallback required
- kitchen delay/remake needs explanation

Staff Assist may coordinate human response.

It must not mark KDS completed without evidence.

---

## 19. Relationship To Kitchen Execution Room

Kitchen Execution may route to Staff Assist when:

- item delayed
- remake required
- sold-out discovered
- substitution requires confirmation
- allergen/safety review required
- manual fallback required
- customer communication needed

Staff Assist supports communication and coordination.

It does not approve compensation.

---

## 20. Relationship To Financial Trust

Staff Assist must defer financial authority to Side C.

Staff Assist must not:

- confirm payment
- approve refund
- execute refund
- issue coupon
- grant points
- mutate wallet
- approve compensation
- confirm settlement

Staff Assist may open or route financial review if authorized later.

Financial action requires financial authority.

---

## 21. Relationship To Data Governance

Staff Assist uses Side D for:

- i18n customer-safe messages
- support templates
- SOP guidance
- CMS notice references if relevant
- AI summary if later authorized
- pgvector context if later authorized
- incident learning
- support/admin visibility policy

Data Governance may guide staff.

It does not replace staff judgment or authority.

---

## 22. Relationship To Store Incident Room

Staff Assist may create or link to Store Incident when:

- issue affects service continuity
- repeated issue occurs
- provider/system failure suspected
- manual fallback triggered
- customer dispute exists
- safety/allergen issue exists
- financial uncertainty exists
- cross-tenant/store anomaly suspected

Incident acknowledgement is not resolution.

Staff Assist must not suppress incident capture.

---

## 23. Relationship To Store Recovery Route Room

Staff Assist may route to Store Recovery when:

- customer impact occurred
- delay was severe
- wrong item occurred
- sold-out occurred after order
- manual fallback caused confusion
- customer complaint requires review
- service failure requires follow-up

Recovery is review.

Recovery is not compensation execution.

---

## 24. Staff Assist Evidence Boundary

Staff assist evidence may include:

- tenant id
- store id
- assist request id
- source room
- related order/reference
- surface/device reference
- staff id
- assist reason category
- staff note reference
- customer guidance key
- fallback marker
- escalation marker
- incident reference
- recovery reference
- timestamp
- audit reference

Evidence supports review.

Evidence is not approval.

---

## 25. Staff Assist Safe Projection Boundary

Customer-safe assist projection may show:

- staff is checking
- please ask staff
- staff assistance is required
- item needs confirmation
- payment is temporarily unavailable
- order status is being checked
- kitchen is checking the item
- service is temporarily unavailable

Customer-safe projection must not show:

- raw POS/KDS/provider errors
- staff-only notes
- payment truth
- refund/compensation promise
- legal conclusion
- security detail
- AI reasoning
- vector similarity
- cross-tenant/store information

Safe Projection controls customer visibility.

---

## 26. Staff Assist Anti-Patterns

Avoid:

- staff assist treated as resolution
- staff acknowledgement treated as issue closure
- staff note treated as final truth
- staff role treated as financial authority
- staff retry bypassing idempotency
- staff assist bypassing validation
- staff assist bypassing POS/KDS evidence
- staff promising refund/compensation
- staff exposing raw provider blame
- staff suppressing incident
- staff message bypassing i18n/customer-safe rules
- staff assist leaking another store’s data
- AI output treated as staff decision
- vector similarity treated as proof

These anti-patterns must be blocked in future runtime design.

---

## 27. Runtime Deferral

This document defines the Staff Assist Room boundary only.

It does not authorize:

- staff assist API implementation
- staff task queue
- staff tablet runtime
- notification runtime
- support workflow runtime
- incident workflow runtime
- recovery workflow runtime
- refund/compensation workflow
- AI runtime
- pgvector runtime
- database schema
- production deployment

All runtime remains deferred.

---

## 28. Validation Checklist

Validation must confirm:

1. Staff Assist Room definition is clear.
2. Staff assist is not authority expansion.
3. Input boundary is defined.
4. Output boundary is defined.
5. Staff assist states are defined.
6. Tenant/store isolation is defined.
7. Assist reason category boundary is defined.
8. Staff role boundary is defined.
9. Customer guidance boundary is defined.
10. Manual confirmation boundary is defined.
11. Staff note boundary is defined.
12. Escalation boundary is defined.
13. Relationship to Order Intake Room is defined.
14. Relationship to Order Validation Room is defined.
15. Relationship to POS Handoff Room is defined.
16. Relationship to KDS Ticket Room is defined.
17. Relationship to Kitchen Execution Room is defined.
18. Relationship to Financial Trust is defined.
19. Relationship to Data Governance is defined.
20. Relationship to Store Incident Room is defined.
21. Relationship to Store Recovery Route Room is defined.
22. Evidence boundary is defined.
23. Safe Projection boundary is defined.
24. Anti-patterns are listed.
25. Coding remains unauthorized.
26. Runtime remains deferred.

---

## 29. Relationship To Previous Documents

This document follows:

- `10250 Kitchen Execution Room Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`

It prepares:

- `10270 Device Runtime Room Boundary Policy`
- `10280 Printer Peripheral Room Boundary Policy`
- `10290 Degraded Operation Room Boundary Policy`
- future staff assist static specification packet

This document is room boundary planning only.

It does not authorize coding.

---

## 30. Final Rule

The Staff Assist Room routes human intervention under tenant/store scope, role boundary, Safe Projection, evidence, audit, fallback, escalation, and review rules.

Staff assist is not validation override.

Staff assist is not POS acceptance.

Staff assist is not KDS completion.

Staff assist is not payment confirmation.

Staff assist is not refund, coupon, point, wallet, compensation, CMS publication, incident resolution, legal conclusion, AI decision, or pgvector proof.

Staff assist supports safe human operation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
