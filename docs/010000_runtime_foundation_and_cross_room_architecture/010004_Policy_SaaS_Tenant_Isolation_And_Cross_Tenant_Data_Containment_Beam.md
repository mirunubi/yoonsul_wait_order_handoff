# 010141_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam

## 1. Purpose

This document defines the SaaS Tenant Isolation and Cross-Tenant Data Containment Beam Policy.

The previous artifact `10140` defined the Cross-Axis Authority, Evidence, Audit, and Fallback Beam Policy.

This document adds a mandatory SaaS isolation beam across all product surfaces, runtime rooms, financial trust rooms, data governance rooms, admin surfaces, provider integrations, AI context, pgvector context, and Franchise OS governance.

The purpose is to ensure that data, state, evidence, analytics, support visibility, POS records, payment records, store operations, customer messages, and admin projections from one tenant or store can never leak into another tenant or store context.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Tenant isolation is not an optional security feature.

Tenant isolation is the platform spine.

The correct rule is:

Every object must know its tenant.  
Every store-scoped object must know its store.  
Every query must be scoped.  
Every command must be scoped.  
Every projection must be scoped.  
Every admin view must be scoped.  
Every provider event must be scoped.  
Every audit event must be scoped.  
Every AI context must be scoped.  
Every vector retrieval must be scoped.  
Every export must be scoped.  

No tenant may ever see, infer, retrieve, aggregate, search, export, or act upon another tenant’s data unless a separately authorized cross-tenant governance role exists.

Default rule:

`CROSS_TENANT_ACCESS_DENIED`

---

## 3. SaaS Isolation Threat

The most dangerous SaaS failure is cross-tenant contamination.

Examples:

- Store A POS data appears in Store B screen.
- Tenant A sales summary appears in Tenant B report.
- Franchise owner sees another franchise group’s data.
- Support admin sees unnecessary cross-tenant raw data.
- AI retrieves similar cases from another tenant without masking or authorization.
- pgvector returns evidence from another tenant.
- CMS notice is published to the wrong store.
- Runtime configuration for Store A is applied to Store B.
- Device profile from one store is accepted in another store.
- Provider callback is attached to the wrong tenant/store.
- Payment/refund evidence is joined across tenants.
- Export includes hidden rows from another tenant.

Even one leaked bit is unacceptable.

---

## 4. Mandatory Context Fields

Every material domain object should carry explicit context.

Minimum context fields should include:

| Field | Requirement |
|---|---|
| `tenant_id` | Required for all tenant-owned objects |
| `store_id` | Required for store-scoped objects |
| `brand_id` | Required when brand context matters |
| `operating_group_id` | Required when operational grouping matters |
| `legal_entity_id` | Required when settlement/legal ownership matters |
| `device_id` | Required for device-originated records |
| `surface_id` | Required for surface-originated records |
| `provider_id` | Required for provider-originated records |
| `actor_id` | Required for human/system action records |
| `scope_class` | Required for visibility classification |
| `authority_context` | Required for mutation/review actions |

Objects without required context must be treated as unsafe.

---

## 5. MD-Level Isolation Rule

Every micro-domain object must be isolation-aware.

For every MD object, the design must answer:

1. Who owns this object?
2. Which tenant owns it?
3. Which store owns it, if any?
4. Which surface created it?
5. Which device created it, if any?
6. Which actor can view it?
7. Which actor can mutate it?
8. Which role can review it?
9. Which projection may expose it?
10. Which export may include it?
11. Which AI/vector context may reference it?
12. Which audit event records access or mutation?
13. Which fallback/reconciliation process may touch it?
14. Which cross-tenant access is explicitly prohibited?

If the answers are missing, the MD object is not ready.

---

## 6. Tenant Isolation Layers

Tenant isolation must exist in multiple layers.

| Layer | Requirement |
|---|---|
| Data Model | Required tenant/store context columns |
| Query Layer | Tenant-scoped filters by default |
| Command Layer | Tenant authority checked before mutation |
| RLS / DB Policy | Deny-by-default row isolation |
| API Layer | Context resolver required |
| Projection Layer | Safe tenant/store projection only |
| Admin Layer | Role/context scoped visibility |
| Support Layer | Masked and purpose-limited access |
| Provider Layer | Provider events attached to verified tenant/store |
| Device Layer | Device profile locked to tenant/store |
| AI Layer | Context retrieval restricted by tenant policy |
| pgvector Layer | Vector search scoped and source-governed |
| Export Layer | Export scoped, logged, and reviewed |
| Audit Layer | Access/mutation traceable by tenant/store |

No single layer is sufficient.

Tenant isolation must be defense-in-depth.

---

## 7. Deny-By-Default Rule

Every tenant-scoped object must default to:

`DENY_UNLESS_CONTEXT_MATCHES`

Allowed access requires:

- authenticated actor
- resolved tenant context
- resolved store context if applicable
- valid role
- valid authority
- valid surface/device context if applicable
- policy permission
- Safe Projection rule
- audit requirement if sensitive
- no containment block
- no suspension block

If context cannot be resolved, access must fail closed.

Fail closed is mandatory.

---

## 8. Store Isolation Rule

Within the same tenant, store isolation still matters.

A tenant may operate multiple stores.

A user authorized for Store A must not automatically access Store B.

Store isolation applies to:

- orders
- POS handoff
- KDS tickets
- payment status
- refunds
- recovery cases
- staff assist
- device profiles
- runtime configuration
- CMS target content
- inventory/sold-out
- incident records
- support notes
- operational evidence
- analytics
- exports

Tenant access does not automatically mean all-store access.

Store scope must be explicit.

---

## 9. Franchise OS Isolation Rule

Franchise OS may aggregate multi-store data only through governed context.

Franchise OS visibility must distinguish:

| Scope | Meaning |
|---|---|
| `single_store` | One store only |
| `store_group` | Approved store cluster |
| `brand_scope` | Brand-level visibility |
| `operating_group_scope` | Operational group visibility |
| `legal_entity_scope` | Legal/settlement visibility |
| `tenant_scope` | Tenant-level visibility |
| `cross_tenant_platform_scope` | Platform internal only, highly restricted |

Franchise OS must never become an unrestricted cross-tenant data browser.

---

## 10. Admin And Support Isolation Rule

Admin and support access must be purpose-limited.

Support/Admin may see data only when:

- role permits it
- purpose permits it
- tenant/store context permits it
- case context permits it
- masking rule permits it
- audit captures access
- sensitive fields are minimized
- cross-tenant visibility is explicitly blocked unless platform-level authority exists

Support visibility is not ownership.

Admin visibility is not mutation permission.

---

## 11. Provider Event Isolation Rule

Provider events must be attached to the correct tenant/store context before use.

Provider callbacks or payloads must not be trusted unless matched through:

- provider id
- provider profile
- tenant id
- store id
- external reference
- idempotency key
- payment/order/POS/KDS reference if applicable
- timestamp
- reconciliation rule
- evidence packet

Unmatched provider events must enter quarantine.

Unmatched provider event must not be projected to customer/admin as verified truth.

---

## 12. Device Isolation Rule

Devices must be bound to tenant/store context.

A device profile should define:

- tenant id
- store id
- device role
- surface type
- config version
- allowed modules
- revoked/suspended status
- emergency disable status
- last verified context

A device from Store A must not operate as Store B.

Device reset must not erase tenant/store binding without re-provisioning.

Device role is not authority.

---

## 13. CMS And i18n Isolation Rule

CMS content and i18n message usage must be target-scoped.

CMS must define:

- target tenant
- target brand
- target store or store group
- target surface
- locale
- publication window
- approval status
- fallback key

A CMS notice intended for one store must not appear in another store.

i18n keys may be shared globally, but actual rendered content must respect tenant/store/surface policy.

---

## 14. Payment And Financial Isolation Rule

Financial data requires stronger isolation.

Payment, refund, settlement, wallet, point, coupon, and compensation records must be scoped by:

- tenant id
- store id if applicable
- order reference
- payment reference
- provider reference
- financial authority
- masking class
- audit class

Financial projections must never aggregate or leak unauthorized store or tenant values.

Financial export must be explicitly scoped and audited.

---

## 15. AI Isolation Rule

AI must not mix tenant contexts by default.

AI input context must be scoped by:

- tenant
- store
- role
- case
- data class
- policy
- masking
- approved source set

AI must not use another tenant’s raw cases, payment evidence, support transcripts, incident data, or operational data unless the source is explicitly approved, masked, and permitted for platform-level learning.

AI output must carry source scope metadata.

AI summary is not authority.

---

## 16. pgvector Isolation Rule

pgvector retrieval must be tenant-safe.

Vector records must include:

- source id
- source type
- tenant scope
- store scope if applicable
- data class
- masking status
- approval status
- retention class
- usage permission
- embedding version
- source policy reference

Vector search must default to same-tenant or approved-global sources only.

Cross-tenant vector retrieval must be denied unless explicitly permitted with masking and governance.

Similarity is not proof.

---

## 17. Analytics Isolation Rule

Analytics must preserve scope.

Analytics may be:

- store-level
- store-group-level
- brand-level
- operating-group-level
- tenant-level
- platform-level anonymized aggregate

Analytics must not expose another tenant’s identifiable data.

Benchmarking requires separate approval.

Platform aggregate must be anonymized, thresholded, and policy-reviewed.

---

## 18. Export Isolation Rule

Exports are high-risk.

Every export must define:

- tenant scope
- store scope
- date range
- data class
- requester
- role
- purpose
- masking requirement
- approval requirement
- audit event
- expiration if applicable

Export must fail closed when scope is ambiguous.

Exported file must not contain hidden cross-tenant rows.

---

## 19. Audit Isolation Rule

Audit events must include context.

Audit event should record:

- tenant id
- store id if applicable
- actor id
- actor role
- surface/device
- target object id
- target object type
- action
- previous scope
- new scope if changed
- authority reference
- policy reference
- evidence reference
- cross-scope attempt if any

Cross-tenant access attempts must be auditable.

Failed access is also security evidence.

---

## 20. Cross-Tenant Containment Rule

If cross-tenant contamination is suspected, containment must trigger.

Possible triggers:

- unexpected tenant id in response
- wrong store data rendered
- vector result from wrong tenant
- support view shows wrong tenant
- export row scope mismatch
- provider callback attached to wrong store
- device context mismatch
- CMS target mismatch
- financial report mismatch
- audit context missing

Containment actions may include:

- block projection
- suspend affected view
- quarantine event
- disable export
- disable vector retrieval
- disable AI context
- require admin/security review
- preserve evidence
- notify internal incident route

Containment is not resolution.

---

## 21. Tenant Isolation Test Principle

Every future implementation candidate must include isolation tests.

Test categories should include:

- tenant A cannot read tenant B data
- store A cannot read store B data unless authorized
- admin scope is enforced
- support masking is enforced
- provider event cannot attach to wrong store
- device cannot switch store without re-provisioning
- CMS target does not leak
- export contains only approved scope
- AI context is tenant-safe
- vector retrieval is tenant-safe
- audit records denied access
- fallback does not bypass scope
- reconciliation does not cross-write

No implementation candidate may be accepted without isolation validation.

---

## 22. MD Readiness Checklist

Every MD document should include tenant isolation readiness:

1. Required context fields defined.
2. Tenant scope defined.
3. Store scope defined if applicable.
4. Role visibility defined.
5. Mutation authority defined.
6. Safe Projection scope defined.
7. Export behavior defined or prohibited.
8. Support/Admin masking defined.
9. Provider event scope defined if applicable.
10. AI usage scope defined or prohibited.
11. pgvector usage scope defined or prohibited.
12. Audit context defined.
13. Fallback scope defined.
14. Reconciliation scope defined.
15. Cross-tenant access default denied.

If this checklist is absent, the MD is incomplete.

---

## 23. Relationship To Four-Side Skeleton

Tenant isolation applies to all sides:

| Side | Isolation Requirement |
|---|---|
| Side A | Product surfaces must project only scoped data |
| Side B | Store Runtime must operate only within scoped tenant/store |
| Side C | Financial Trust must isolate payment/value data strictly |
| Side D | Data Governance must prevent AI/vector/analytics/CMS leakage |

Tenant isolation is a cross-axis beam.

It must not be localized to only database policy.

---

## 24. Relationship To Runtime Authorization

No future coding authorization packet should be approved unless it declares:

- tenant isolation impact
- store isolation impact
- context fields
- access model
- RLS or equivalent policy expectation
- Safe Projection scope
- audit scope
- export scope
- AI/vector scope if applicable
- isolation validation plan
- rollback/containment plan

If tenant isolation is missing, coding must be blocked.

---

## 25. Anti-Patterns

Avoid:

- tenant id optional on tenant-owned objects
- store id omitted from store-scoped records
- admin query without tenant filter
- support view without masking
- export generated before scope validation
- AI prompt containing mixed tenant data
- vector search across tenants by default
- provider event matched only by external id
- device accepted without store binding
- CMS content published without target scope
- report using global aggregation without thresholding
- cache key missing tenant/store prefix
- fallback record created without tenant/store
- reconciliation updating wrong tenant/store
- audit event missing context
- “HQ admin” treated as unrestricted all-data access

These anti-patterns are SaaS security failures.

---

## 26. Runtime Deferral

This document defines tenant isolation skeleton only.

It does not authorize:

- RLS policy implementation
- database schema changes
- API context resolver
- admin permission engine
- support masking engine
- export engine
- AI context filter
- pgvector scoped retrieval
- tenant isolation test suite
- production deployment

All runtime remains deferred.

---

## 27. Validation Checklist

Validation must confirm:

1. Tenant isolation is defined as a platform spine.
2. Cross-tenant contamination threat is defined.
3. Mandatory context fields are listed.
4. MD-level isolation rule is defined.
5. Multi-layer isolation model is defined.
6. Deny-by-default rule is defined.
7. Store isolation is defined.
8. Franchise OS isolation is defined.
9. Admin/support isolation is defined.
10. Provider event isolation is defined.
11. Device isolation is defined.
12. CMS/i18n isolation is defined.
13. Financial isolation is defined.
14. AI isolation is defined.
15. pgvector isolation is defined.
16. Analytics isolation is defined.
17. Export isolation is defined.
18. Audit isolation is defined.
19. Cross-tenant containment is defined.
20. Tenant isolation test principle is defined.
21. MD readiness checklist is defined.
22. Runtime authorization dependency is defined.
23. Anti-patterns are listed.
24. Coding remains unauthorized.
25. Runtime remains deferred.

---

## 28. Relationship To Previous Documents

This document supplements:

- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`

It applies to:

- `10020~10057 Product Surface, SaaS, Mini Kiosk, Admin Reuse, and Static Authorization Planning Sequence`
- `10100~10150 Four-Side Skeleton Sequence`
- `10200 Store Room Framing And Runtime Domain Boundary Index`
- all future Store, Financial, Data Governance, Admin, Provider, AI, pgvector, and Franchise OS documents

It prepares:

- future tenant isolation static catalog
- future tenant context resolver policy
- future RLS policy packet
- future cross-tenant contamination incident policy
- future isolation test checklist
- future SaaS security authorization gate

This document is cross-axis skeleton planning only.

It does not authorize coding.

---

## 29. Final Rule

Tenant isolation is a load-bearing security beam across the entire SaaS platform.

Every MD object, query, command, projection, admin view, support view, provider event, device record, CMS target, financial record, AI context, pgvector source, analytics report, export, audit event, fallback record, and reconciliation process must carry and enforce tenant/store scope.

A Store A record must never appear in Store B context.

Tenant A data must never appear in Tenant B context.

Cross-tenant access is denied by default.

If tenant isolation cannot be proven, the feature is not ready.

Runtime implementation remains deferred until a separate explicit authorization packet with tenant isolation validation is approved.
