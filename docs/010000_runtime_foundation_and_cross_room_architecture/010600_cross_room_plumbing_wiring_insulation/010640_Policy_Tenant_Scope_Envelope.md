# 010640_Policy_Tenant_Scope_Envelope

## 1. Purpose

This document defines the Tenant Scope Envelope Policy.

The previous artifact `10630 Authority Capability Gate Policy` defined the authority gate layer that determines whether an actor, device, provider, AI, sensor, admin surface, support surface, or automated workflow may act.

This document defines the mandatory scope envelope that every command, query, projection, event, evidence packet, audit record, reconciliation case, DLQ record, export, AI context, vector retrieval, provider callback, device event, sensor observation, policy decision, and financial ledger movement must carry.

The purpose is to ensure that tenant isolation, store isolation, legal entity separation, franchise hierarchy, provider scope, device scope, and financial authority context are enforced before any data is accepted, routed, displayed, reconciled, exported, or mutated.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Every object must carry scope before it can be trusted.

The correct rule is:

No tenant scope, no processing.  
No store scope for store-level action, no processing.  
No legal entity scope for financial action, no financial finality.  
No provider scope for provider event, no provider matching.  
No device scope for device-originated event, no device trust.  
No audience scope for projection, no visibility.  
No authority context for command, no mutation.  
No scope match, no cross-room routing.  
No proven isolation, no SaaS readiness.  

Tenant isolation is not a database feature only.

It is an envelope that wraps every data movement.

---

## 3. Scope Envelope Applicability

The scope envelope applies to:

- command
- query
- projection
- event
- evidence packet
- audit record
- reconciliation case
- DLQ record
- provider callback
- provider report
- POS/KDS event
- device event
- offline sync event
- local mesh event
- sensor observation
- AI advisory output
- pgvector retrieval
- analytics read model
- CMS content
- i18n message
- export
- retention/archive record
- policy decision
- financial ledger record
- settlement allocation
- payout instruction
- split payout
- royalty calculation
- fast payout
- no-show penalty
- supplier order
- IoT command
- DR recovery event
- support access record
- admin action

No object may be scope-free.

---

## 4. Scope Dimension Catalog

The platform must recognize the following scope dimensions:

| Scope Dimension | Meaning |
|---|---|
| `tenant_id` | SaaS tenant/customer organization |
| `store_id` | Individual store or outlet |
| `brand_id` | Brand identity or product line |
| `operating_group_id` | Operational grouping such as region/business unit |
| `legal_entity_id` | Legal/accounting/tax entity |
| `company_id` | Company or corporate entity if separate from legal entity |
| `franchise_group_id` | Franchise network or master group |
| `franchise_hq_id` | Franchise headquarters context |
| `region_id` | Geographic or operational region |
| `device_id` | Device identity |
| `surface_id` | App/web/POS/KDS/kiosk/admin surface |
| `provider_id` | PG/VAN/card/bank/provider |
| `merchant_id` | Provider-side merchant account |
| `terminal_id` | Terminal or SoftPOS identity |
| `customer_ref` | Customer pseudonym or scoped identity |
| `actor_id` | Acting user/system |
| `role_id` | Role context |
| `session_id` | Session context |
| `policy_scope_id` | Policy applicability scope |
| `data_residency_scope` | Data residency/region constraint |
| `visibility_scope` | Audience/visibility context |
| `authority_scope` | Scope within which action is allowed |

Scope dimensions may be nullable only if the object type explicitly does not require them.

---

## 5. Mandatory Envelope Fields

Every scoped object should carry:

| Field | Meaning |
|---|---|
| `scope_envelope_id` | Unique envelope id |
| `scope_version` | Envelope schema version |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope if applicable |
| `brand_id` | Brand scope if applicable |
| `operating_group_id` | Operating group if applicable |
| `legal_entity_id` | Legal/accounting scope if applicable |
| `franchise_group_id` | Franchise group if applicable |
| `provider_id` | Provider scope if applicable |
| `device_id` | Device scope if applicable |
| `actor_id` | Acting identity if applicable |
| `role_id` | Role context if applicable |
| `surface_id` | Source surface |
| `session_id` | Session context |
| `authority_scope` | Action authority scope |
| `visibility_scope` | Projection/query visibility |
| `data_class` | Data classification |
| `masking_class` | Masking class |
| `policy_version` | Policy version |
| `scope_hash` | Hash of scope fields for tamper detection |
| `scope_validated_at` | Scope validation timestamp |
| `scope_validation_status` | Validation result |

Envelope must be attached before routing, projection, or mutation.

---

## 6. Scope Validation State Skeleton

Recommended scope validation states:

| State | Meaning |
|---|---|
| `SCOPE_NOT_EVALUATED` | Scope not evaluated |
| `SCOPE_VALIDATING` | Scope validation in progress |
| `SCOPE_VALID` | Scope valid |
| `SCOPE_PARTIAL_VALID` | Scope valid only for limited operation |
| `SCOPE_MISSING` | Required scope missing |
| `SCOPE_MISMATCH` | Scope mismatch |
| `SCOPE_CROSS_TENANT_DENIED` | Cross-tenant access denied |
| `SCOPE_STORE_MISMATCH` | Store scope mismatch |
| `SCOPE_LEGAL_ENTITY_MISMATCH` | Legal entity mismatch |
| `SCOPE_PROVIDER_MISMATCH` | Provider scope mismatch |
| `SCOPE_DEVICE_MISMATCH` | Device scope mismatch |
| `SCOPE_VISIBILITY_DENIED` | Visibility denied |
| `SCOPE_AUTHORITY_DENIED` | Authority denied |
| `SCOPE_REVIEW_REQUIRED` | Human/security review required |
| `SCOPE_QUARANTINED` | Quarantined for safety |
| `SCOPE_DLQ_REQUIRED` | DLQ required |

Scope failures must not be ignored.

---

## 7. Tenant Isolation Boundary

Tenant isolation is mandatory.

Tenant A data must not appear in Tenant B context.

Tenant A command must not mutate Tenant B object.

Tenant A export must not include Tenant B record.

Tenant A AI context must not retrieve Tenant B private data.

Tenant A pgvector query must not retrieve Tenant B private vector source.

Tenant A support case must not open Tenant B evidence.

Tenant A provider event must not match Tenant B merchant mapping.

Default rule:

    CROSS_TENANT_ACCESS_DENIED

---

## 8. Store Isolation Boundary

Store isolation is mandatory inside a tenant.

Store A order must not appear in Store B staff surface.

Store A POS event must not update Store B KDS.

Store A settlement line must not appear in Store B payout.

Store A no-show penalty must not affect Store B customer policy.

Store A device must not issue commands for Store B.

Store A local mesh event must not sync into Store B.

Exception requires explicit multi-store authority and evidence.

---

## 9. Legal Entity Boundary

Legal entity scope is required for financial actions.

Legal entity affects:

- settlement
- payout
- tax/reporting
- platform fee billing
- split payout
- royalty settlement
- fast payout exposure
- KYC/account ownership
- supplier invoice
- accounting journal
- legal hold
- export/compliance

A financial object without legal entity context must not become final.

Legal entity mismatch must route to reconciliation or review.

---

## 10. Operating Group Boundary

Operating group is operational grouping.

It must not be confused with legal ownership.

Operating group may control:

- regional operations dashboard
- staffing view
- regional inventory
- queue monitoring
- campaign operations
- operational benchmarks
- kitchen performance
- incident routing

Operating group does not automatically imply financial authority.

---

## 11. Brand And Franchise Boundary

Brand/franchise scope must be explicit.

Franchise HQ may access:

- authorized brand aggregate
- authorized royalty basis
- authorized split payout evidence
- authorized operational benchmark
- authorized store compliance status

Franchise HQ must not automatically access:

- unrelated brand data
- raw customer PII
- platform internal margin
- unrelated store owner private financial details
- raw security evidence
- raw sensor media

Franchise scope is contract-scoped.

---

## 12. Provider Scope Boundary

Provider scope must be explicit for all external financial/provider events.

Provider-scoped objects include:

- provider callback
- provider settlement file
- provider dispute notice
- provider FDS signal
- provider account verification
- provider payout response
- provider merchant mapping
- provider route state
- provider fee table
- provider acquiring state

Provider event must match tenant, store, legal entity, merchant id, terminal id, amount, currency, and transaction id where applicable.

Provider scope mismatch must quarantine or DLQ.

---

## 13. Device Scope Boundary

Device scope must be explicit for device-originated events.

Device-scoped objects include:

- POS device event
- KDS device event
- tablet event
- kiosk event
- SoftPOS event
- local hub event
- IoT device event
- printer event
- UWB anchor event
- camera sensor event
- audio sensor event
- NFC/QR event
- offline sync event

Device belongs to a tenant/store/device registry.

Device event outside its assigned scope must be rejected or quarantined.

---

## 14. Surface Scope Boundary

Surface scope defines where an action came from.

Surfaces may include:

- customer app
- mobile web
- kiosk
- mini kiosk
- table tablet
- staff tablet
- owner app
- PC admin
- franchise HQ admin
- platform support
- platform finance admin
- platform security console
- KDS screen
- POS surface
- SoftPOS surface
- supplier portal
- API client
- batch/system worker

Surface may limit allowed actions.

A customer surface must not execute admin command.

A support surface must not execute owner financial authority without delegation.

---

## 15. Actor And Role Scope Boundary

Actor and role scope must be explicit.

Actor may be:

- customer
- store staff
- store manager
- owner
- HQ staff
- platform support
- platform finance
- platform security
- platform admin
- auditor
- system worker
- AI agent
- provider adapter
- device agent

Role must be scoped.

Global role should be rare and heavily audited.

---

## 16. Customer Scope Boundary

Customer scope must be minimized.

Customer context may include:

- customer id
- pseudonymous customer reference
- session id
- reservation id
- wait id
- preorder id
- payment customer token
- loyalty id
- device/session reference
- consent state

Customer scope must not leak across tenants unless explicitly governed by the public service identity model.

Customer behavior/risk signals must be privacy-governed.

---

## 17. Public Service Identity Boundary

Public-facing service may have its own customer identity.

Example:

- customer uses Catch Menu public service
- customer interacts with multiple tenant stores
- customer may also belong to tenant-specific membership program

Cross-tenant customer identity must be handled through safe identity linking and consent.

A public customer profile must not expose one tenant’s private transaction details to another tenant.

---

## 18. AI Context Scope Boundary

AI context must be scoped.

AI input must include:

- tenant scope
- store scope if applicable
- data class
- masking class
- source references
- purpose
- actor/requester
- retention rule
- output audience
- policy version

AI must not receive unrestricted cross-tenant raw data.

Global model learning requires separate anonymization, aggregation, legal/privacy review, and governance.

---

## 19. pgvector Scope Boundary

pgvector retrieval must be scope-filtered.

Vector records must carry:

- tenant id
- store id if applicable
- source object id
- source data class
- masking class
- embedding version
- retention class
- allowed audience
- source approval status
- legal/privacy status

Vector similarity across tenants is denied by default unless source is approved global/public knowledge.

Similarity is not proof.

---

## 20. Analytics Scope Boundary

Analytics must preserve scope.

Analytics may be:

- store-level
- tenant-level
- brand-level
- operating-group-level
- franchise-HQ-level
- platform-internal
- anonymized benchmark
- global aggregate

Benchmark must enforce aggregation threshold, masking, and non-identification.

Analytics aggregate must not leak individual tenant/store data.

---

## 21. CMS And i18n Scope Boundary

CMS/i18n scope must be explicit.

CMS content may target:

- tenant
- brand
- store
- region
- surface
- audience
- locale
- campaign
- emergency/degraded state

i18n message may vary by:

- locale
- audience
- tenant customization
- legal wording
- financial wording
- error state
- degraded operation

CMS/i18n text must not escape scope.

---

## 22. Export Scope Boundary

Export is high-risk.

Export must include:

- requester scope
- export scope
- tenant/store/legal scope
- data class
- masking class
- approval state
- purpose
- recipient
- expiration
- audit reference
- retention/legal hold status

Export must not include out-of-scope records.

Export generation must be audited.

---

## 23. Retention And Archive Scope Boundary

Retention/archive must preserve scope.

Archived records must remain retrievable by:

- tenant
- store
- legal entity
- business date
- settlement date
- ledger sequence
- evidence packet
- policy version
- legal hold
- retention class

Cold storage is not scope erasure.

Archive retrieval must enforce the same scope rules as hot storage.

---

## 24. DR And Replication Scope Boundary

Disaster recovery and replication must preserve scope.

Replicated records must include:

- tenant id
- store id
- legal entity id
- provider id if applicable
- ledger sequence
- policy version
- scope hash
- WORM/hash reference
- data residency constraint

Failover must not mix tenant scopes.

Restore must verify scope integrity before financial finality resumes.

---

## 25. Sharding Scope Boundary

Sharding must be scope-aware.

Shard assignment must preserve:

- tenant isolation
- store grouping
- brand/franchise grouping
- legal entity constraints
- data residency
- backup/DR mapping
- batch partition
- cost attribution
- migration path
- hash continuity

Shard movement must not change business truth.

Shard movement requires evidence.

---

## 26. Local/Offline Scope Boundary

Local/offline events must carry scope.

Offline event must include:

- tenant id
- store id
- device id
- offline session id
- local sequence number
- signed payload
- local timestamp
- server sync timestamp
- scope hash

Offline event without scope must be rejected.

Local events are provisional until central reconciliation.

---

## 27. Sensor Scope Boundary

Sensor events must be scope-bound.

Sensor scope includes:

- tenant
- store
- zone/table
- device/sensor id
- model version
- privacy class
- retention class
- evidence use
- human review requirement

Sensor event cannot escape its store context.

Raw media access must be restricted.

---

## 28. Physical Execution Scope Boundary

Physical execution must be scope-bound.

Physical execution includes:

- KDS ticket
- printer job
- IoT command
- robot task
- local hub routing
- supplier receiving
- table binding

Device in Store A must not execute command for Store B.

Physical command without matching tenant/store/device scope must be blocked.

---

## 29. Financial Ledger Scope Boundary

Financial ledger must include:

- tenant id
- store id if applicable
- legal entity id
- provider id if applicable
- account code
- journal id
- ledger sequence
- policy version
- amount
- currency
- business date
- settlement date
- audit reference

Ledger without proper scope cannot be final.

Financial scope errors are critical incidents.

---

## 30. Scope Hash Boundary

Scope hash may be used to detect tampering or mismatch.

Scope hash may include:

- tenant id
- store id
- legal entity id
- provider id
- device id
- actor id
- policy version
- source object id

Scope hash mismatch must route to review, DLQ, or security.

Scope hash is evidence, not authority by itself.

---

## 31. Scope Propagation Boundary

Scope must propagate across:

- command
- event
- evidence packet
- audit
- projection
- query response
- reconciliation case
- DLQ record
- export
- archive
- AI context
- vector record
- analytics read model

Scope must not be dropped between rooms.

Scope drop is a routing failure.

---

## 32. Scope Downscoping Boundary

Downscoping may create safer projections.

Examples:

- raw financial ledger to owner dashboard summary
- raw provider callback to safe payment status
- raw sensor event to redacted incident summary
- raw support case to customer-safe explanation
- raw platform cost to internal margin dashboard
- raw tenant data to anonymized benchmark

Downscoping must preserve source references and masking.

Downscoping must not create false finality.

---

## 33. Scope Escalation Boundary

Scope escalation means broader visibility or authority.

Examples:

- store-level to tenant-level
- tenant-level to franchise-HQ-level
- support case to platform security
- owner case to legal/compliance
- store incident to HQ
- financial mismatch to platform finance
- security anomaly to security admin

Scope escalation requires reason, authority, audit, and often evidence.

Silent escalation is prohibited.

---

## 34. Cross-Tenant Aggregation Boundary

Cross-tenant aggregation is allowed only if:

- aggregation is approved
- data is anonymized or aggregated
- minimum threshold is met
- no tenant/store is identifiable
- sensitive categories are masked
- purpose is allowed
- export restrictions are enforced
- legal/privacy review is satisfied where required

Cross-tenant aggregate must not become cross-tenant raw access.

---

## 35. Scope Conflict Boundary

Scope conflict occurs when identifiers disagree.

Examples:

- event tenant id differs from object tenant id
- provider merchant maps to different tenant
- device assigned to different store
- actor role belongs to different tenant
- payment legal entity differs from settlement legal entity
- export includes out-of-scope row
- AI context retrieves wrong tenant
- vector result crosses tenant boundary
- sensor event zone mismatches table/order

Scope conflict must fail closed.

---

## 36. Scope Audit Boundary

Scope validation must be audited for high-impact actions.

Audit should record:

- scope requested
- scope resolved
- scope validation result
- actor
- role
- source surface
- policy version
- reason code
- denied fields if safe
- DLQ/quarantine route
- reviewer if applicable

Scope audit supports security and due diligence.

---

## 37. Scope Reason Codes

Recommended scope reason codes:

| Reason Code | Meaning |
|---|---|
| `TENANT_SCOPE_MISSING` | Missing tenant |
| `TENANT_SCOPE_MISMATCH` | Tenant mismatch |
| `STORE_SCOPE_MISSING` | Missing store for store-scoped object |
| `STORE_SCOPE_MISMATCH` | Store mismatch |
| `LEGAL_ENTITY_SCOPE_MISSING` | Missing legal entity |
| `LEGAL_ENTITY_SCOPE_MISMATCH` | Legal entity mismatch |
| `PROVIDER_SCOPE_MISMATCH` | Provider mismatch |
| `DEVICE_SCOPE_MISMATCH` | Device mismatch |
| `ACTOR_SCOPE_DENIED` | Actor lacks scope |
| `ROLE_SCOPE_DENIED` | Role lacks scope |
| `VISIBILITY_SCOPE_DENIED` | Visibility denied |
| `AUTHORITY_SCOPE_DENIED` | Authority denied |
| `EXPORT_SCOPE_DENIED` | Export out of scope |
| `AI_CONTEXT_SCOPE_DENIED` | AI context denied |
| `VECTOR_SCOPE_DENIED` | Vector retrieval denied |
| `SENSOR_SCOPE_DENIED` | Sensor scope denied |
| `SHARD_SCOPE_MISMATCH` | Shard mapping mismatch |
| `DR_SCOPE_MISMATCH` | Restore/replication mismatch |

Reason codes must be safe for internal review and external projection where appropriate.

---

## 38. Anti-Patterns

Avoid:

- relying only on app route to infer tenant
- storing financial records without legal entity
- provider callback accepted without merchant-to-tenant mapping
- device event accepted without device registry match
- projection generated without audience scope
- export generated from broad query without row-level scope
- AI prompt built from unscoped raw data
- vector retrieval without tenant filter
- support agent browsing tenant data without case scope
- franchise HQ seeing raw unrelated store data
- sharding without preserving tenant/store/legal mapping
- offline event sync without signed scope
- sensor event crossing store boundary
- aggregate benchmark exposing tenant identity
- scope dropped during event routing

These anti-patterns must be blocked in future runtime design.

---

## 39. Runtime Deferral

This document defines tenant scope envelope boundaries only.

It does not authorize:

- tenant scope service implementation
- scope envelope schema
- RLS policy
- sharding implementation
- scope hash implementation
- export scope filter
- AI/vector scope filter
- device registry enforcement
- provider mapping runtime
- analytics aggregation runtime
- database schema
- production deployment

All runtime remains deferred.

---

## 40. Validation Checklist

Validation must confirm:

1. Scope envelope applicability is defined.
2. Scope dimension catalog is defined.
3. Mandatory envelope fields are defined.
4. Scope validation state skeleton is defined.
5. Tenant isolation boundary is defined.
6. Store isolation boundary is defined.
7. Legal entity boundary is defined.
8. Operating group boundary is defined.
9. Brand/franchise boundary is defined.
10. Provider scope boundary is defined.
11. Device scope boundary is defined.
12. Surface scope boundary is defined.
13. Actor/role scope boundary is defined.
14. Customer scope boundary is defined.
15. Public service identity boundary is defined.
16. AI context scope boundary is defined.
17. pgvector scope boundary is defined.
18. Analytics scope boundary is defined.
19. CMS/i18n scope boundary is defined.
20. Export scope boundary is defined.
21. Retention/archive scope boundary is defined.
22. DR/replication scope boundary is defined.
23. Sharding scope boundary is defined.
24. Local/offline scope boundary is defined.
25. Sensor scope boundary is defined.
26. Physical execution scope boundary is defined.
27. Financial ledger scope boundary is defined.
28. Scope hash boundary is defined.
29. Scope propagation boundary is defined.
30. Scope downscoping boundary is defined.
31. Scope escalation boundary is defined.
32. Cross-tenant aggregation boundary is defined.
33. Scope conflict boundary is defined.
34. Scope audit boundary is defined.
35. Scope reason codes are defined.
36. Anti-patterns are listed.
37. Coding remains unauthorized.
38. Runtime remains deferred.

---

## 41. Relationship To Previous Documents

This document follows:

- `10630 Authority Capability Gate Policy`

It prepares:

- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10690 Cross-Room Plumbing Closure Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- all prior Store Runtime, Financial Trust, Data Governance, Security, SaaS, Field, Physical, Sensor, and Franchise OS boundary documents where tenant, store, legal, provider, device, actor, or visibility scope must be preserved.

This document is architecture boundary planning only.

It does not authorize coding.

---

## 42. Final Rule

Every data object, command, query, projection, event, evidence packet, audit record, reconciliation case, DLQ record, export, AI context, vector record, analytics aggregate, provider callback, device event, sensor observation, physical command, financial ledger line, and policy decision must carry a tenant scope envelope.

Scope must include tenant, store, legal entity, provider, device, actor, role, surface, authority, visibility, policy, and data classification context as applicable.

If scope is missing, mismatched, dropped, unverifiable, or cross-tenant unsafe, the object must be denied, quarantined, or routed to DLQ.

Tenant isolation is not optional.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.