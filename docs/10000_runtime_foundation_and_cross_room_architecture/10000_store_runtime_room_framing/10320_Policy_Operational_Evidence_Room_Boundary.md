# 10320_Policy_Operational_Evidence_Room_Boundary

## 1. Purpose

This document defines the Operational Evidence Room Boundary Policy.

The previous artifact `10310` defined the Store Incident Room Boundary Policy.

This document frames the twelfth Side B room:

`Operational Evidence Room`

The purpose is to define the boundary where operational facts, event traces, fallback records, provider responses, device signals, staff notes, kitchen states, POS/KDS references, payment-related references, incident evidence, and recovery-related records are captured, preserved, scoped, masked, linked, reviewed, and retained without being confused with approval, mutation, financial truth, root cause proof, compensation, or final resolution.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Operational Evidence Room governs evidence packets for store runtime.

It may later coordinate:

- evidence packet creation
- evidence source classification
- evidence timeline
- evidence scope
- evidence masking
- evidence retention
- evidence linkage
- evidence immutability rule
- evidence review state
- evidence export control
- incident evidence relation
- fallback evidence relation
- reconciliation evidence relation
- recovery evidence relation
- audit relation

Evidence is captured reality.

Evidence is not approval.

---

## 3. Core Principle

Evidence preserves what happened.

Evidence does not decide what should happen.

The correct rule is:

Evidence is not approval.  
Evidence is not authority.  
Evidence is not compensation.  
Evidence is not refund.  
Evidence is not root cause proof by itself.  
Staff note is evidence, not final truth.  
Provider callback is evidence, not verified truth by itself.  
Device signal is evidence, not transaction truth.  
AI summary is not evidence authority.  
pgvector similarity is not proof.  

Evidence must be scoped, immutable, traceable, masked when needed, and reviewable.

---

## 4. Scope

The Operational Evidence Room may define planning boundaries for evidence related to:

- order intake
- order validation
- POS handoff
- KDS ticketing
- kitchen execution
- staff assist
- device runtime
- printer/peripheral events
- degraded operation
- manual fallback
- store incident
- payment uncertainty reference
- customer-safe communication
- support/admin action
- provider event
- tenant/store isolation anomaly
- recovery review candidate
- reconciliation candidate

This room does not implement evidence runtime.

---

## 5. Evidence Source Catalog

Recommended evidence source catalog:

| Source | Meaning |
|---|---|
| `CUSTOMER_SURFACE_EVENT` | Customer-facing interaction |
| `ORDER_INTAKE_EVENT` | Intake-related event |
| `VALIDATION_EVENT` | Validation-related event |
| `POS_PROVIDER_EVENT` | POS provider/adapter evidence |
| `KDS_PROVIDER_EVENT` | KDS provider/adapter evidence |
| `PAYMENT_PROVIDER_REFERENCE` | Payment-related reference, not financial truth here |
| `KITCHEN_EXECUTION_EVENT` | Physical kitchen evidence |
| `STAFF_ASSIST_NOTE` | Staff assist evidence |
| `DEVICE_HEALTH_EVENT` | Device health/status evidence |
| `PERIPHERAL_EVENT` | Printer/scanner/NFC/display/buzzer evidence |
| `DEGRADED_OPERATION_EVENT` | Degraded mode evidence |
| `MANUAL_FALLBACK_RECORD` | Manual fallback evidence |
| `INCIDENT_RECORD` | Incident-related evidence |
| `SUPPORT_ADMIN_ACTION` | Support/admin action evidence |
| `CMS_I18N_MESSAGE_EVENT` | Customer/staff message evidence |
| `AUDIT_EVENT_REFERENCE` | Audit reference |
| `RECONCILIATION_REFERENCE` | Reconciliation reference |

Source catalog is planning-only.

---

## 6. Evidence Packet Boundary

An evidence packet should contain or reference:

| Field | Meaning |
|---|---|
| `evidence_packet_id` | Evidence packet reference |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope if applicable |
| `source_room` | Originating room |
| `source_type` | Evidence source type |
| `source_reference` | Source object reference |
| `related_order_reference` | Related order if applicable |
| `related_incident_id` | Incident reference if applicable |
| `related_fallback_id` | Fallback reference if applicable |
| `related_reconciliation_id` | Reconciliation reference if applicable |
| `related_recovery_id` | Recovery reference if applicable |
| `evidence_class` | Evidence classification |
| `masking_class` | Masking requirement |
| `retention_class` | Retention requirement |
| `created_at` | Creation time |
| `created_by` | Actor/system reference |
| `audit_reference` | Audit reference |

Evidence packet may link to raw or structured evidence, but must preserve scope.

---

## 7. Evidence State Skeleton

Recommended evidence states:

| State | Meaning |
|---|---|
| `EVIDENCE_NOT_CREATED` | No evidence packet |
| `EVIDENCE_CAPTURED` | Evidence captured |
| `EVIDENCE_LINKED` | Evidence linked to room/incident |
| `EVIDENCE_MASKING_REQUIRED` | Masking required |
| `EVIDENCE_REVIEW_REQUIRED` | Review required |
| `EVIDENCE_IN_REVIEW` | Review active |
| `EVIDENCE_INCOMPLETE` | Evidence incomplete |
| `EVIDENCE_CONFLICT_DETECTED` | Conflicting evidence exists |
| `EVIDENCE_RECONCILIATION_REQUIRED` | Reconciliation required |
| `EVIDENCE_ACCEPTED_FOR_REVIEW` | Accepted as review material |
| `EVIDENCE_REJECTED_FOR_USE` | Rejected as unreliable/unusable |
| `EVIDENCE_RETAINED` | Retained under policy |
| `EVIDENCE_EXPIRED` | Retention expired |
| `EVIDENCE_UNKNOWN` | Evidence state uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. Tenant And Store Isolation Boundary

Every evidence packet must be tenant/store scoped.

A Store A evidence packet must never appear in Store B evidence context.

A Tenant A evidence packet must never appear in Tenant B visibility.

Evidence access must fail closed when:

- tenant context is missing
- store context is missing where required
- source room context is missing
- masking class is unresolved
- actor role is unauthorized
- support/admin case context is missing
- export scope is ambiguous
- AI/vector usage scope is missing

Default:

`CROSS_TENANT_ACCESS_DENIED`

Operational Evidence Room must follow `10141`.

---

## 9. Immutability Boundary

Evidence should be append-only.

Evidence must not be silently rewritten.

Allowed evidence operations should be separated:

| Operation | Rule |
|---|---|
| Create | Capture new evidence |
| Link | Link evidence to incident/recovery/reconciliation |
| Mask | Create masked projection |
| Annotate | Add review note without overwriting source |
| Supersede | Mark later evidence supersedes earlier evidence |
| Reject | Mark evidence unusable without deleting source |
| Retain | Preserve under retention policy |
| Expire | Expire under policy if allowed |

Correction must be appended.

Original evidence should remain traceable unless legal/security deletion policy applies.

---

## 10. Evidence Classification Boundary

Evidence classification may include:

| Class | Meaning |
|---|---|
| `LOW_RISK_OPERATIONAL` | Routine operational evidence |
| `CUSTOMER_VISIBLE_EVENT` | Customer-facing event evidence |
| `STAFF_NOTE` | Staff note evidence |
| `PROVIDER_REFERENCE` | Provider-related evidence |
| `DEVICE_PERIPHERAL_SIGNAL` | Device/peripheral evidence |
| `FINANCIAL_REFERENCE` | Financial reference, not financial truth here |
| `SECURITY_SENSITIVE` | Security-sensitive evidence |
| `PERSONAL_DATA` | Personal data involved |
| `ALLERGEN_SAFETY_RELATED` | Safety/allergen related |
| `CROSS_TENANT_RISK` | Tenant isolation risk |
| `LEGAL_REVIEW_REQUIRED` | Legal/compliance review required |

Classification controls visibility, masking, retention, and export.

---

## 11. Masking Boundary

Evidence may require masking before display.

Masking may apply to:

- customer phone/email/name
- payment reference
- provider payload
- staff private note
- device identifier
- security detail
- raw logs
- support/admin action detail
- cross-tenant anomaly detail
- financial reference
- sensitive kitchen/safety note

Masked projection must not alter source evidence.

Masked projection is visibility control.

It is not evidence mutation.

---

## 12. Timeline Boundary

Evidence timeline must preserve chronology.

Timeline may include:

- source event time
- capture time
- provider callback time
- device event time
- staff note time
- manual fallback time
- incident creation time
- acknowledgement time
- reconciliation review time
- recovery review time
- closure time

Timeline correction must be append-only.

Backfilled evidence must be marked as backfilled.

---

## 13. Provider Evidence Boundary

Provider evidence may include:

- provider profile id
- provider event id
- provider reference
- request timestamp
- response timestamp
- callback timestamp
- status category
- error category
- idempotency key
- retry marker
- reconciliation marker

Provider evidence must not be treated as verified truth by itself.

Provider evidence must be matched, scoped, and reconciled.

Unmatched provider evidence must be quarantined.

---

## 14. Device And Peripheral Evidence Boundary

Device/peripheral evidence may include:

- device id
- peripheral id
- config version
- health status
- heartbeat
- print event
- scan event
- NFC event
- display event
- buzzer event
- error category
- degraded marker
- fallback marker

Device/peripheral evidence must not become transaction truth.

Device/peripheral evidence supports operational review.

---

## 15. Staff Note Evidence Boundary

Staff notes are useful but limited evidence.

Staff note may capture:

- customer request
- staff observation
- manual fallback reason
- kitchen delay
- remake reason
- substitution discussion
- incident observation
- recovery context

Staff note must not be treated as:

- payment confirmation
- refund approval
- compensation approval
- legal conclusion
- provider fault proof
- customer fault proof
- root cause proof by itself

Staff note is review material.

---

## 16. Financial Reference Boundary

Operational Evidence Room may link financial references.

It must not become Financial Trust.

Financial references may include:

- payment reference
- refund reference
- wallet reference
- coupon reference
- point reference
- settlement reference
- provider financial event reference

Operational Evidence may preserve references.

Financial Trust owns financial truth.

---

## 17. Customer Communication Evidence Boundary

Customer communication evidence may include:

- message key
- locale
- rendered message reference if retained
- channel
- timestamp
- surface/device
- staff actor if applicable
- customer-safe projection reference

Customer communication evidence must not include unsafe raw internal detail by default.

Customer-visible message must be i18n-controlled.

---

## 18. AI Evidence Boundary

AI may summarize evidence only if separately authorized.

AI summary must not replace evidence.

AI output must preserve:

- source evidence references
- scope
- masking status
- uncertainty
- reviewer requirement
- no authority marker

AI summary is not evidence authority.

AI must not create root cause or compensation decision.

---

## 19. pgvector Evidence Boundary

pgvector may later support related-case retrieval.

Vector retrieval must not become proof.

Vector source must include:

- source id
- tenant/store scope
- data class
- masking status
- approval status
- usage permission
- embedding version
- retention class

Similarity is not proof.

Related case is not evidence for the current case unless reviewed and linked.

---

## 20. Export Boundary

Evidence export is high-risk.

Evidence export must define:

- tenant scope
- store scope
- incident/recovery scope
- requester
- purpose
- role
- data class
- masking class
- date range
- approval requirement
- expiration
- audit reference

Export must fail closed when scope is ambiguous.

Export must not include hidden cross-tenant rows.

---

## 21. Retention Boundary

Evidence retention must be class-based.

Retention class may depend on:

- operational importance
- financial relevance
- incident severity
- safety/allergen relevance
- customer dispute relevance
- security relevance
- legal/compliance relevance
- provider contract relevance

Retention expiration must not destroy unresolved incident, reconciliation, recovery, or legal review evidence.

Retention is governance.

It is not deletion shortcut.

---

## 22. Evidence Conflict Boundary

Evidence conflict may occur when:

- staff note conflicts with POS state
- KDS state conflicts with kitchen state
- payment provider callback conflicts with local status
- device timestamp conflicts with central timestamp
- manual fallback conflicts with digital state
- customer communication conflicts with support note
- provider callback arrives late
- cross-store reference appears

Conflict must trigger review.

Conflict must not be resolved by silent overwrite.

---

## 23. Evidence Review Boundary

Evidence review may determine:

- evidence completeness
- evidence reliability
- scope correctness
- masking correctness
- timeline correctness
- conflict presence
- need for reconciliation
- need for incident escalation
- need for recovery review
- need for financial review
- need for containment

Evidence review is not approval for financial action.

---

## 24. Relationship To Store Incident Room

Store Incident Room links to Operational Evidence.

Incident Room manages workflow.

Operational Evidence Room preserves proof material and review material.

Incident acknowledgement is not evidence approval.

Evidence linked to incident is not incident resolution.

---

## 25. Relationship To Manual Fallback Room

Manual Fallback creates evidence requiring traceability.

Manual fallback evidence must preserve:

- fallback origin
- staff action
- manual note
- source uncertainty
- later digital entry candidate
- reconciliation requirement

Manual fallback evidence must not pretend to be original digital truth.

---

## 26. Relationship To Degraded Operation Room

Degraded Operation creates evidence for:

- degraded condition
- allowed/prohibited actions
- fallback trigger
- containment trigger
- reconciliation need
- customer-safe message
- staff/admin visibility

Degraded evidence supports review.

It does not resolve degradation.

---

## 27. Relationship To Fulfillment Visibility Room

Fulfillment Visibility Room will project safe status to customers, staff, and admin.

Operational Evidence Room supplies scoped evidence.

Fulfillment Visibility must not expose raw evidence directly.

Projection is not evidence mutation.

---

## 28. Relationship To Store Recovery Route Room

Store Recovery Route may use evidence to determine customer recovery review.

Evidence can support review.

Evidence does not execute recovery.

Evidence does not approve compensation.

---

## 29. Relationship To Financial Trust

Operational Evidence must defer financial authority to Side C.

Operational Evidence must not:

- confirm payment
- approve refund
- execute refund
- issue coupon
- grant points
- mutate wallet
- approve compensation
- confirm settlement

Financial evidence references may be linked.

Financial truth remains in Financial Trust.

---

## 30. Relationship To Data Governance

Operational Evidence uses Side D for:

- classification policy
- masking policy
- retention policy
- export policy
- support/admin visibility policy
- AI summary governance if later authorized
- pgvector source governance if later authorized
- analytics/read model governance if later authorized

Data Governance governs use.

Operational Evidence preserves material.

---

## 31. Evidence Anti-Patterns

Avoid:

- evidence treated as approval
- staff note treated as root cause
- provider callback treated as verified truth
- device signal treated as transaction truth
- print event treated as payment proof
- AI summary treated as evidence authority
- pgvector similarity treated as proof
- evidence overwritten silently
- evidence exported without scope
- evidence displayed without masking
- evidence packet missing tenant/store
- evidence conflict resolved by overwrite
- backfilled evidence pretending real-time origin
- unresolved evidence expired improperly

These anti-patterns must be blocked in future runtime design.

---

## 32. Runtime Deferral

This document defines the Operational Evidence Room boundary only.

It does not authorize:

- evidence database schema
- evidence packet API
- evidence storage engine
- masking engine
- export engine
- retention engine
- incident workflow
- reconciliation workflow
- AI summary runtime
- pgvector retrieval
- production deployment

All runtime remains deferred.

---

## 33. Validation Checklist

Validation must confirm:

1. Operational Evidence Room definition is clear.
2. Evidence preserves what happened but does not decide what should happen.
3. Evidence source catalog is defined.
4. Evidence packet boundary is defined.
5. Evidence state skeleton is defined.
6. Tenant/store isolation is defined.
7. Immutability boundary is defined.
8. Evidence classification boundary is defined.
9. Masking boundary is defined.
10. Timeline boundary is defined.
11. Provider evidence boundary is defined.
12. Device/peripheral evidence boundary is defined.
13. Staff note evidence boundary is defined.
14. Financial reference boundary is defined.
15. Customer communication evidence boundary is defined.
16. AI evidence boundary is defined.
17. pgvector evidence boundary is defined.
18. Export boundary is defined.
19. Retention boundary is defined.
20. Evidence conflict boundary is defined.
21. Evidence review boundary is defined.
22. Relationships to related rooms are defined.
23. Financial Trust separation is defined.
24. Data Governance relationship is defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 34. Relationship To Previous Documents

This document follows:

- `10310 Store Incident Room Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10300 Manual Fallback Room Boundary Policy`
- `10310 Store Incident Room Boundary Policy`

It prepares:

- `10330 Fulfillment Visibility Room Boundary Policy`
- `10340 Store Recovery Route Room Boundary Policy`
- future operational evidence static specification packet

This document is room boundary planning only.

It does not authorize coding.

---

## 35. Final Rule

The Operational Evidence Room preserves scoped, traceable, reviewable material about what happened.

Evidence is not approval.

Evidence is not authority.

Evidence is not compensation.

Evidence is not refund.

Evidence is not root cause proof by itself.

Provider callback is not verified truth by itself.

Staff note is not final truth by itself.

Device signal is not transaction truth.

AI summary is not evidence authority.

pgvector similarity is not proof.

Operational Evidence must preserve tenant/store isolation, immutability, masking, retention, timeline, audit, fallback, reconciliation, incident linkage, recovery linkage, i18n, Safe Projection, and financial/provider boundary separation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
