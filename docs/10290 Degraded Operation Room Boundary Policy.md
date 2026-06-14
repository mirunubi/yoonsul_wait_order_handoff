# 10290 Degraded Operation Room Boundary Policy

## 1. Purpose

This document defines the Degraded Operation Room Boundary Policy.

The previous artifact `10280` defined the Printer Peripheral Room Boundary Policy.

This document frames the ninth Side B room:

`Degraded Operation Room`

The purpose is to define the boundary where store operation continues under partial failure, provider instability, device failure, network degradation, POS/KDS/payment unavailability, stale configuration, CMS unavailability, or local/central divergence without pretending that normal operation is still occurring.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Degraded Operation Room governs controlled operation when one or more platform dependencies are impaired.

It may later coordinate:

- degraded mode detection
- degraded mode classification
- allowed actions
- prohibited actions
- customer-safe messages
- staff assist route
- manual fallback route
- provider degraded route
- device degraded route
- payment unavailable route
- POS/KDS unavailable route
- CMS unavailable route
- evidence capture
- reconciliation requirement
- recovery route
- incident relation
- containment trigger if needed

Degraded operation is not normal operation.

Degraded operation is controlled survival.

---

## 3. Core Principle

Degraded mode must be explicit, scoped, and reversible.

The correct rule is:

Failure is not permission to ignore boundaries.  
Degraded operation is not silent mutation.  
Offline operation is not unrestricted operation.  
Stale config is not permanent authority.  
Provider outage is not customer blame.  
POS unavailable is not payment confirmed.  
KDS unavailable is not kitchen completion.  
Payment unavailable is not free order approval.  
Manual fallback is not data overwrite.  

Degraded operation must preserve evidence, audit, fallback, reconciliation, tenant/store isolation, and Safe Projection.

---

## 4. Scope

The Degraded Operation Room may define planning boundaries for:

- network degradation
- central service degradation
- local device degradation
- POS provider degradation
- KDS provider degradation
- payment provider degradation
- printer/peripheral degradation
- CMS degradation
- i18n message fallback
- runtime config stale state
- support/admin unavailable state
- local/central divergence
- manual fallback initiation
- incident escalation
- containment trigger
- recovery review route

This room does not implement degraded operation runtime.

---

## 5. Degraded Condition Catalog

Recommended degraded condition catalog:

| Condition | Meaning |
|---|---|
| `NETWORK_DEGRADED` | Network unstable |
| `CENTRAL_SERVICE_DEGRADED` | Central system impaired |
| `POS_DEGRADED` | POS unavailable or unstable |
| `KDS_DEGRADED` | KDS unavailable or unstable |
| `PAYMENT_DEGRADED` | Payment unavailable or uncertain |
| `DEVICE_DEGRADED` | Device unstable or stale |
| `PRINTER_DEGRADED` | Printer/peripheral impaired |
| `CMS_DEGRADED` | CMS unavailable or stale |
| `I18N_FALLBACK_REQUIRED` | Locale/message fallback needed |
| `CONFIG_STALE` | Runtime config stale |
| `PROVIDER_CALLBACK_DELAYED` | Callback delayed |
| `LOCAL_CENTRAL_DIVERGENCE` | Local/central mismatch |
| `SUPPORT_ADMIN_DEGRADED` | Support/admin unavailable |
| `MULTI_DEPENDENCY_DEGRADED` | Multiple failures |

Condition catalog is planning-only.

---

## 6. Degraded Operation State Skeleton

Recommended degraded operation states:

| State | Meaning |
|---|---|
| `DEGRADED_NOT_ACTIVE` | Normal mode |
| `DEGRADED_DETECTED` | Degradation detected |
| `DEGRADED_CLASSIFICATION_REQUIRED` | Classification needed |
| `DEGRADED_ACTIVE` | Degraded mode active |
| `DEGRADED_STAFF_ASSIST_REQUIRED` | Staff assist required |
| `DEGRADED_MANUAL_FALLBACK_REQUIRED` | Manual fallback required |
| `DEGRADED_CONTAINMENT_REQUIRED` | Containment required |
| `DEGRADED_RECONCILIATION_REQUIRED` | Reconciliation required |
| `DEGRADED_RECOVERY_REVIEW_REQUIRED` | Recovery review required |
| `DEGRADED_RESOLUTION_REVIEW_REQUIRED` | Resolution review required |
| `DEGRADED_RESOLVED` | Resolved after review |
| `DEGRADED_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 7. Tenant And Store Isolation Boundary

Degraded operation must remain tenant/store scoped.

A degradation in Store A must not affect Store B unless explicitly scoped as tenant-wide or provider-wide.

Every degraded operation record must include:

- tenant id
- store id if store-scoped
- affected device id if applicable
- affected provider id if applicable
- affected surface id if applicable
- affected room
- condition category
- evidence reference
- audit reference

Default:

`CROSS_TENANT_ACCESS_DENIED`

Degraded operation must follow `10141`.

---

## 8. Allowed Action Boundary

Degraded operation may allow limited actions such as:

- show safe customer message
- request staff assist
- capture manual fallback note
- prepare manual kitchen ticket
- pause affected surface
- suspend affected device
- disable affected feature
- route to support/admin
- preserve evidence
- mark reconciliation required
- open incident
- open recovery review if customer impacted

Allowed actions must be explicit.

Allowed actions must not imply runtime authority outside scope.

---

## 9. Prohibited Action Boundary

Degraded operation must prohibit risky actions such as:

- confirm payment without verification
- approve refund automatically
- issue coupon automatically
- grant points automatically
- mutate wallet/prepaid balance
- treat POS timeout as success
- treat KDS timeout as completion
- publish unapproved CMS notice
- expose raw provider blame
- continue stale config indefinitely
- silently merge local state
- suppress audit
- cross-write tenant/store data
- allow AI to resolve incident
- use pgvector similarity as proof

Failure must not become shortcut authority.

---

## 10. Network Degradation Boundary

Network degradation may affect:

- customer surface
- Mini Kiosk
- Full Kiosk
- staff tablet
- POS bridge
- KDS bridge
- payment provider
- CMS display
- printer/peripheral bridge
- local agent
- support/admin view

Network degradation should trigger:

- safe message
- staff assist route
- local fallback if approved
- evidence capture
- later reconciliation
- device health update
- incident route if severe

Network failure must not erase state.

---

## 11. POS Degraded Boundary

POS degraded mode may occur when:

- POS provider unavailable
- POS handoff timeout
- POS callback delayed
- POS adapter unavailable
- POS mapping error
- POS store state mismatch
- POS provider limitation active

POS degraded mode must not:

- treat order as POS accepted
- confirm payment
- print receipt as proof
- silently retry without idempotency
- blame provider to customer without review
- overwrite POS state manually

POS degraded mode may route to staff assist or manual fallback if policy allows.

---

## 12. KDS Degraded Boundary

KDS degraded mode may occur when:

- KDS provider unavailable
- KDS ticket timeout
- KDS display unavailable
- station routing unavailable
- KDS callback delayed
- kitchen printer fallback required

KDS degraded mode must not:

- treat ticket as accepted without evidence
- mark kitchen completed
- approve compensation
- hide kitchen delay
- silently create duplicate ticket
- expose raw KDS error to customer

KDS degraded mode may route to manual kitchen fallback.

---

## 13. Payment Degraded Boundary

Payment degraded mode is high-risk.

Payment degraded mode may occur when:

- provider unavailable
- payment status unknown
- callback delayed
- authorization uncertain
- duplicate payment risk exists
- refund status uncertain
- wallet balance uncertain

Payment degraded mode must not:

- confirm payment
- release paid order without policy
- approve refund
- execute compensation
- mutate wallet
- create duplicate charge
- expose raw payment payload
- allow indefinite unknown state

Payment degraded mode must route to Financial Trust review.

---

## 14. Device Degraded Boundary

Device degraded mode may occur when:

- device offline
- config stale
- app version unsupported
- Kiosk mode broken
- heartbeat missing
- device storage/power issue
- device revoked/suspended
- tenant/store mismatch
- local cache stale

Device degraded mode must not:

- keep operating past expiry
- access cross-store data
- confirm payment
- bypass runtime config
- bypass emergency disable
- silently switch tenant/store
- continue with unknown profile

Device degraded mode may trigger suspension or replacement review.

---

## 15. Printer Peripheral Degraded Boundary

Printer/peripheral degraded mode may occur when:

- printer offline
- scanner unavailable
- NFC reader unavailable
- customer display unavailable
- buzzer unavailable
- peripheral bridge unavailable
- wrong-store print risk detected
- duplicate print risk detected

Peripheral degraded mode must not:

- treat print failure as order failure
- treat print success as transaction truth
- retry duplicate prints blindly
- expose raw error to customer
- print cross-store content

Peripheral degraded mode may route to manual fallback.

---

## 16. CMS And i18n Degraded Boundary

CMS/i18n degraded mode may occur when:

- CMS unavailable
- CMS content stale
- unapproved content detected
- locale missing
- message key missing
- fallback locale required
- emergency notice cannot be published safely

CMS/i18n degraded mode must not:

- show draft content
- show unapproved content
- hardcode unsafe operational text
- publish provider blame
- promise refund/compensation
- expose internal incident detail

If a message key is missing, safe fallback must be used or action blocked.

---

## 17. Runtime Config Stale Boundary

Stale runtime configuration is dangerous.

Config stale condition may require:

- disable high-risk features
- restrict order intent
- disable payment
- disable POS/KDS handoff
- disable CMS publication
- require staff assist
- require manual fallback
- require config refresh
- require device review
- require incident if prolonged

Stale config must not become permanent authority.

High-risk actions must fail closed.

---

## 18. Local/Central Divergence Boundary

Local/central divergence may occur when:

- local cache differs from central state
- device submitted offline record
- POS/KDS callback arrives late
- manual fallback was used
- central config changed while device offline
- provider event was delayed
- local agent state differs from central state

Divergence must trigger:

- evidence packet
- reconciliation requirement
- safe projection
- no silent merge
- review if high-risk
- audit

Local state must not overwrite central truth silently.

---

## 19. Customer-Safe Degraded Projection Boundary

Customer-safe degraded projection may show:

- service is temporarily limited
- staff will assist
- order status is being checked
- payment is temporarily unavailable
- kitchen is checking the order
- menu is being refreshed
- please ask staff
- try again later

Customer-safe projection must not show:

- raw provider error
- internal incident details
- payment uncertainty details
- security containment details
- staff-only notes
- provider blame
- refund/compensation promise
- cross-tenant/store information
- AI reasoning
- vector similarity

Degraded messages must be safe and i18n-controlled.

---

## 20. Staff/Admin Degraded Visibility Boundary

Staff/Admin may see more detail if authorized.

Staff/Admin degraded visibility may include:

- degraded condition category
- affected room
- affected device/provider
- safe error category
- current allowed/prohibited actions
- fallback requirement
- reconciliation requirement
- incident reference
- evidence reference
- audit reference

Staff/Admin must not see unrestricted secrets, raw payment payloads, raw provider credentials, or cross-tenant records by default.

Visibility is not mutation permission.

---

## 21. Degraded Evidence Boundary

Degraded evidence may include:

- tenant id
- store id
- affected room
- affected surface
- affected device
- affected provider
- degraded condition
- degraded state
- start time
- detection source
- safe message key
- allowed actions
- prohibited actions
- fallback marker
- reconciliation marker
- incident reference
- recovery reference
- staff/admin actor if involved
- audit reference

Evidence supports review.

Evidence is not resolution.

---

## 22. Degraded Incident Boundary

Degraded operation may open incident when:

- degradation affects customer service
- financial uncertainty exists
- provider callback mismatch exists
- device compromise suspected
- cross-tenant anomaly suspected
- manual fallback used
- stale config persists
- POS/KDS/payment outage persists
- repeated degradation occurs
- staff escalation required

Incident acknowledgement is not resolution.

Incident closure requires review.

---

## 23. Recovery Route Boundary

Degraded operation may open recovery review when customer impact occurs.

Customer impact may include:

- order could not proceed
- order delayed
- payment uncertainty affected customer
- POS/KDS mismatch affected service
- wrong message shown
- device failure interrupted order
- manual fallback created confusion
- support escalation required

Recovery route is review.

Recovery is not compensation execution.

---

## 24. Containment Boundary

Containment may be required when degradation creates security or financial risk.

Containment triggers may include:

- cross-tenant data risk
- compromised device
- payment unknown state
- duplicate charge risk
- wallet balance mismatch
- provider callback conflict
- wrong-store CMS display
- wrong-store print
- stale config with high-risk feature
- AI/vector source contamination if later enabled

Containment may restrict or suspend affected capability.

Containment is not resolution.

---

## 25. Reconciliation Boundary

Degraded operation often requires reconciliation.

Reconciliation may compare:

- local fallback record
- central order state
- POS state
- KDS state
- payment state
- provider callback history
- device config
- CMS state
- audit events
- staff notes
- peripheral events

Reconciliation must not silently mutate truth.

Reviewed correction may be needed.

---

## 26. Relationship To Manual Fallback Room

Degraded Operation may route to Manual Fallback when safe operation requires human/manual continuity.

Manual Fallback must be marked:

`FALLBACK_ORIGINATED`

Manual Fallback must later return evidence to Degraded Operation, Incident, Evidence, and Reconciliation paths.

Degraded mode chooses fallback.

Fallback captures survival operation.

---

## 27. Relationship To Staff Assist Room

Degraded Operation may route to Staff Assist when:

- customer needs help
- device unavailable
- order state uncertain
- payment unavailable
- POS/KDS degraded
- kitchen delay occurs
- manual fallback required
- safe explanation needed

Staff Assist must not resolve degraded state automatically.

---

## 28. Relationship To Device Runtime Room

Device Runtime provides:

- device status
- config version
- revoked/suspended state
- heartbeat
- local cache status
- degraded marker
- emergency disable state

Degraded Operation may use device signals.

Device signals are evidence, not final truth.

---

## 29. Relationship To Financial Trust

Degraded Operation must defer financial uncertainty to Side C.

Payment degraded, refund degraded, wallet degraded, coupon/point degraded, and settlement degraded conditions must route to Financial Trust review.

Degraded Operation must not execute financial actions.

---

## 30. Relationship To Data Governance

Degraded Operation uses Side D for:

- i18n safe messages
- CMS emergency notice governance
- support/admin visibility
- SOP guidance
- incident learning
- AI summary if later authorized
- vector context if later authorized
- analytics/read model if later authorized

Data Governance supports safe communication.

It does not resolve degraded state.

---

## 31. Degraded Operation Anti-Patterns

Avoid:

- degraded mode treated as normal mode
- failure treated as permission to bypass policy
- stale config treated as permanent config
- POS timeout treated as success
- KDS timeout treated as completion
- payment unknown treated as paid
- staff assist treated as degraded resolution
- manual fallback silently overwriting central state
- provider outage blamed to customer
- unapproved CMS emergency notice published
- AI resolving incident
- vector similarity proving root cause
- cross-tenant anomaly ignored
- containment released without authority

These anti-patterns must be blocked in future runtime design.

---

## 32. Runtime Deferral

This document defines the Degraded Operation Room boundary only.

It does not authorize:

- degraded mode engine
- device health monitor
- provider monitor
- payment fallback runtime
- POS/KDS fallback runtime
- CMS emergency runtime
- incident workflow runtime
- reconciliation engine
- containment system
- notification runtime
- database schema
- production deployment

All runtime remains deferred.

---

## 33. Validation Checklist

Validation must confirm:

1. Degraded Operation Room definition is clear.
2. Degraded mode is explicit, scoped, and reversible.
3. Condition catalog is defined.
4. State skeleton is defined.
5. Tenant/store isolation is defined.
6. Allowed action boundary is defined.
7. Prohibited action boundary is defined.
8. Network degradation boundary is defined.
9. POS degraded boundary is defined.
10. KDS degraded boundary is defined.
11. Payment degraded boundary is defined.
12. Device degraded boundary is defined.
13. Printer/peripheral degraded boundary is defined.
14. CMS/i18n degraded boundary is defined.
15. Runtime config stale boundary is defined.
16. Local/central divergence boundary is defined.
17. Customer-safe projection boundary is defined.
18. Staff/admin visibility boundary is defined.
19. Evidence boundary is defined.
20. Incident boundary is defined.
21. Recovery route boundary is defined.
22. Containment boundary is defined.
23. Reconciliation boundary is defined.
24. Relationships to related rooms are defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 34. Relationship To Previous Documents

This document follows:

- `10280 Printer Peripheral Room Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10260 Staff Assist Room Boundary Policy`
- `10270 Device Runtime Room Boundary Policy`
- `10280 Printer Peripheral Room Boundary Policy`

It prepares:

- `10300 Manual Fallback Room Boundary Policy`
- `10310 Store Incident Room Boundary Policy`
- future degraded operation static specification packet

This document is room boundary planning only.

It does not authorize coding.

---

## 35. Final Rule

The Degraded Operation Room governs controlled survival under partial failure.

Degraded mode is not normal mode.

Failure is not permission to bypass policy.

Stale config is not permanent authority.

POS timeout is not success.

KDS timeout is not completion.

Payment unknown is not paid.

Manual fallback is not silent mutation.

Containment is not resolution.

Degraded Operation must preserve tenant/store isolation, evidence, audit, fallback, reconciliation, containment, i18n, Safe Projection, staff assist, incident routing, recovery review, and financial/provider boundary separation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.