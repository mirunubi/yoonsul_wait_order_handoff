# 010604_Policy_SaaS_Scale_Constraints

## 1. Purpose

This document defines the SaaS Scale Constraint, Multi-Tenancy, Hardware, Regulation, Noise, and Distributed Batch Policy.

The previous artifacts defined:

- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`
- `10603 Reconciliation DLQ Device Non-Repudiation And Cold Storage Lifecycle Policy`

This document adds the SaaS expansion constraints that arise when Catch Menu, Mini Kiosk, NFC Table Order, POS/KDS handoff, financial-grade reconciliation, AI immune security, and four-layer audit are offered not only to Yoonsul-owned stores but also to many independent external food-service tenants as a subscription SaaS.

The purpose is to ensure that the architecture does not collapse under multi-tenant leakage, payment regulation risk, hardware fragmentation, AI noise, infrastructure cost explosion, or nightly batch scaling limits.

This document is planning-only.

It does not authorize coding.

It is not legal advice.

Legal and regulatory conclusions must be confirmed separately with qualified counsel before implementation or commercialization.

---

## 2. Core Position

A system that works for one controlled brand store may fail as SaaS if its constraints are not controlled.

The correct rule is:

SaaS scale increases tenant isolation risk.  
SaaS scale increases legal and payment-flow risk.  
SaaS scale increases hardware fragmentation.  
SaaS scale increases false-positive security noise.  
SaaS scale increases AI and logging cost.  
SaaS scale increases nightly batch pressure.  
SaaS scale requires certified device boundaries.  
SaaS scale requires distributed reconciliation.  
SaaS scale requires standardization before openness.  

The platform must not become an uncontrolled “install anywhere, connect anything, trust everything” system.

---

## 3. SaaS Constraint Catalog

The following constraint families must be considered before SaaS commercialization:

| Constraint | Risk |
|---|---|
| `MULTI_TENANCY_ISOLATION` | Tenant/store data leakage |
| `PAYMENT_REGULATORY_BOUNDARY` | Becoming a regulated money-handling entity unintentionally |
| `PERSONAL_DATA_PROTECTION` | Customer/staff/privacy leakage |
| `LOG_RETENTION_COMPLIANCE` | Audit/security log preservation burden |
| `NETWORK_OPERATION_SECURITY` | Admin/operator environment risk |
| `HARDWARE_FRAGMENTATION` | Unknown devices cannot support security guarantees |
| `DEVICE_KEY_ASSURANCE` | Non-certified devices weaken non-repudiation |
| `OS_LOG_ACCESS_VARIANCE` | OS log availability differs by device/OS |
| `NOISE_AND_FALSE_POSITIVE` | Real-world tenant behavior mistaken for attacks |
| `AI_COST_EXPLOSION` | LLM/security analysis cost becomes unsustainable |
| `DATABASE_COST_EXPLOSION` | Log/read/write volume overwhelms hot DB |
| `BATCH_SCALING_LIMIT` | Nightly reconciliation does not finish in time |
| `TENANT_SUPPORT_COMPLEXITY` | Manual exception review burden grows |
| `PROVIDER_FRAGMENTATION` | Many PG/POS/KDS providers create mapping risk |
| `LEGAL_DISPUTE_SCALE` | Many tenants create many settlement disputes |

Each constraint must have an architecture control.

---

## 4. Multi-Tenancy Isolation Boundary

Multi-tenancy is the highest SaaS risk.

A tenant must not see or affect another tenant’s:

- sales data
- payment data
- refund data
- settlement data
- customer data
- POS/KDS data
- device logs
- OS logs
- security events
- DLQ records
- audit records
- export files
- analytics
- AI context
- pgvector retrieval
- CMS content
- i18n customizations
- provider credentials
- device keys
- batch reports

Default:

`CROSS_TENANT_ACCESS_DENIED`

Tenant isolation failure is SaaS failure.

---

## 5. Tenant Isolation Implementation Boundary

Future implementation must not rely on UI filtering alone.

Tenant isolation should be enforced across:

- authentication claims
- device enrollment
- API gateway
- command gate
- query gate
- projection layer
- database RLS or equivalent enforcement
- storage path
- export path
- archive path
- AI context retrieval
- vector retrieval
- analytics aggregation
- batch partition
- audit partition
- support/admin access
- provider credential mapping

If tenant isolation cannot be proven, the feature is not SaaS-ready.

---

## 6. Firebase / Firestore Constraint Boundary

If Firebase or Firestore is used, the design must account for:

- security rules complexity
- tenant/store path structure
- document read/write cost
- index cost
- high-volume log write cost
- batch read window cost
- rule test coverage
- device identity claims
- custom claims lifecycle
- offline sync behavior
- export/archive lifecycle
- per-tenant access rule validation
- cross-tenant query prevention

Firestore/Firebase convenience must not weaken Financial Trust or tenant isolation.

Firebase mapping is candidate architecture only.

It does not authorize implementation.

---

## 7. Supabase / PostgreSQL Constraint Boundary

If Supabase/PostgreSQL is used, the design must account for:

- tenant/store scoped tables
- RLS deny-by-default
- schema-per-tenant versus shared-schema tradeoff
- partitioning by tenant/store/date
- audit trigger load
- batch query load
- read model materialization
- cold archive export
- pgvector tenant isolation
- provider credential isolation
- admin/support scoped access
- cross-tenant analytics aggregation controls

PostgreSQL flexibility must not become unrestricted cross-tenant access.

---

## 8. Data Partition Strategy Boundary

SaaS may require tiered partitioning strategies.

Candidate approaches:

| Approach | Strength | Risk |
|---|---|---|
| Shared DB, shared schema | Lowest cost | Highest isolation complexity |
| Shared DB, tenant partition | Balanced | Needs strict RLS and query discipline |
| Shared DB, schema per tenant group | Better separation | More operational complexity |
| Separate DB per large tenant/group | Stronger isolation | Higher cost and deployment complexity |
| Hybrid | Flexible | Requires clear routing rules |

Initial SaaS should prefer controlled tenant groups and explicit partition strategy.

Do not over-open before isolation tests are proven.

---

## 9. Payment Regulatory Boundary

Payment regulation risk must be controlled.

The platform must distinguish:

| Model | Risk |
|---|---|
| Order SaaS with tenant-owned PG account | Lower platform custody risk |
| Platform collects money then pays tenant | Higher regulatory/custody risk |
| Platform wallet/stored value | Higher financial regulation risk |
| Platform-issued points with cash-like value | Higher value-liability risk |
| Platform settlement aggregation | Higher compliance and licensing risk |
| Provider-to-tenant direct settlement | Lower direct money custody risk |

Preferred early SaaS model:

- Tenant owns PG/VAN/payment contract.
- Platform connects order/payment workflow.
- Platform does not custody tenant funds unless legally authorized.
- Platform reconciles records but does not become unapproved money handler.
- Stored value/wallet features remain restricted until legal review.

This must be reviewed by legal counsel before commercialization.

---

## 10. Provider Credential Boundary

In SaaS, each tenant may have separate provider credentials.

Provider credentials must be:

- tenant-scoped
- store-scoped if needed
- encrypted or secret-managed
- never exposed to client app
- never exposed to other tenants
- mapped to provider capability evidence
- rotated under policy
- revoked on tenant termination
- audited on access
- blocked from AI/vector exposure

Provider credential mapping error can become financial disaster.

---

## 11. Legal And Compliance Boundary

Legal/compliance readiness must be assessed before SaaS launch.

Areas requiring legal confirmation include:

- electronic financial transaction obligations
- payment agency obligations
- stored value and wallet obligations
- personal data protection
- consent and privacy policy
- log retention periods
- security audit requirements
- breach notification duties
- subcontractor/provider obligations
- cross-border data handling if any
- franchise/tenant contract terms
- data processing agreement
- dispute handling
- evidence retention
- admin access policy
- operator network/security policy

This document does not assert final legal requirements.

It requires counsel-reviewed compliance matrix before coding authorization.

---

## 12. Hardware Certification Boundary

SaaS must not allow arbitrary untrusted hardware for financial-grade functions.

Certified hardware policy should define:

- supported device models
- OS version range
- security patch level
- device integrity checks
- secure storage capability
- certificate/key storage capability
- kiosk mode capability
- OS log availability
- offline log storage capability
- network recovery behavior
- local DB encryption capability
- device management capability
- remote revocation capability
- receipt/printer integration capability if needed

Uncertified device may run only reduced-risk mode.

Certified device may run financial-grade mode.

---

## 13. Hardware Lock-In Strategy Boundary

For early SaaS, hardware lock-in may be necessary.

Recommended phased approach:

| Phase | Device Policy |
|---|---|
| Phase 1 | Only HQ-certified kiosk/tablet/POS device |
| Phase 2 | Certified device families with provisioning test |
| Phase 3 | Partner hardware certification program |
| Phase 4 | Limited BYOD with reduced capability |
| Phase 5 | Open device ecosystem only after security proof |

Open hardware is business attractive but security expensive.

Financial-grade audit requires controlled hardware.

---

## 14. OS Log Availability Boundary

OS log collection differs by:

- Android version
- manufacturer customization
- root/non-root status
- kiosk mode
- permission model
- enterprise device management
- local agent capability
- storage limits
- battery optimization
- background execution restrictions
- app lifecycle restrictions

If OS log cannot be trusted, the device must have lower audit confidence.

No device should be advertised as financial-grade unless OS/runtime evidence can meet policy.

---

## 15. Device Capability Classification Boundary

Devices should be classified by capability.

Recommended classes:

| Class | Meaning |
|---|---|
| `CERTIFIED_FINANCIAL_DEVICE` | Full device key, logs, offline chain, secure storage |
| `CERTIFIED_OPERATIONAL_DEVICE` | Operational use, limited financial trust |
| `VIEW_ONLY_DEVICE` | Menu/display only |
| `STAFF_ASSIST_DEVICE` | Staff workflow, limited payment authority |
| `UNTRUSTED_BYOD_DEVICE` | No financial-grade authority |
| `QUARANTINED_DEVICE` | Blocked pending review |
| `RETIRED_DEVICE` | No longer active |

Capability class must control what the device may do.

---

## 16. Noise And False Positive Boundary

At SaaS scale, real-world noise increases.

Noise sources include:

- tenant unplugging device
- unstable Wi-Fi
- LAN cable movement
- cheap router failure
- app force close
- OS battery kill
- provider retry storm
- staff repeated retries
- campaign traffic
- delivery platform bursts
- store opening/closing spikes
- batch import delay
- kiosk fleet reconnect
- daylight saving/timezone misconfiguration if applicable
- local terminal clock drift

Noise must not automatically become security incident.

Noise must be classified and routed.

---

## 17. AI Cost Boundary

AI must not analyze every event with heavy LLM calls.

Recommended AI cost ladder:

| Layer | Cost Strategy |
|---|---|
| Rule filter | Deterministic, cheapest |
| Lightweight anomaly scoring | Local/server-side numeric scoring |
| Edge/device precheck | Small local checks if possible |
| Batch statistical review | Nightly/periodic cost-controlled analysis |
| Medium model triage | Only selected suspicious cases |
| LLM orchestration | Only high-risk, ambiguous, evidence-rich cases |
| Human review | DLQ/high-value/legal/security cases |

LLM is not first-line filter.

AI usage must be cost-gated.

---

## 18. Edge AI And Lightweight Detection Boundary

Lightweight detection may handle:

- request rate spike
- duplicate tap
- repeated login failure
- device reconnect loop
- offline backlog sync
- clock drift marker
- signature failure
- missing provider record
- simple anomaly threshold
- local resource anomaly
- basic fraud pattern

Heavy AI should be reserved for ambiguous cases.

Cost control is architecture, not later optimization.

---

## 19. Log Volume And Database Cost Boundary

At SaaS scale, logs may dominate cost.

High-volume records include:

- DB trigger audit
- OS/runtime logs
- projection audit
- AI outputs
- vector retrieval audit
- security detection signals
- provider callbacks
- export access logs
- device heartbeats
- kiosk interactions
- batch reconciliation records

Cost controls must include:

- sampling only where legally safe
- aggregation where safe
- partitioning
- tiering
- compression
- hot/warm/cold storage
- DLQ isolation
- per-tenant quotas
- log class retention
- read model materialization
- avoiding raw log dashboards

Financial/security evidence must not be sampled away when required.

---

## 20. Batch Scaling Boundary

Nightly batch must finish within operational window.

Batch scaling concerns:

- number of tenants
- number of stores
- number of transactions
- number of provider reports
- number of terminal logs
- number of OS logs
- number of DLQ cases
- number of archive objects
- number of export reports
- number of reconciliation exceptions
- retry/backoff behavior
- provider API rate limits
- database query time
- cold archive retrieval time

A single monolithic batch is not SaaS-ready.

---

## 21. Distributed Batch Boundary

SaaS batch should be partitioned.

Possible partition keys:

- tenant
- store
- operating group
- legal entity
- region
- provider
- business date
- event family
- risk class
- settlement cycle

Distributed batch must preserve:

- idempotency
- exactly-once or effectively-once result handling where required
- audit
- retry control
- partial failure handling
- DLQ routing
- settlement hold
- report hash
- tenant isolation
- batch completion summary

Distributed batch is complex but necessary at scale.

---

## 22. Partial Closing Boundary

At SaaS scale, one tenant/store failure must not block all tenants.

Partial closing may allow:

- Tenant A closes normally.
- Tenant B has DLQ exceptions.
- Store C is held for security review.
- Provider D report is delayed.
- Region E batch is retried.
- Global summary shows partial completion.

Partial close must be honest.

No unresolved tenant/store should be shown as fully closed.

---

## 23. Provider Fragmentation Boundary

Different tenants may use different providers.

Provider fragmentation risks:

- different callback formats
- different settlement reports
- different cancellation timing
- different approval numbers
- different fee structures
- different merchant id mapping
- different provider API limits
- different retry policies
- different reconciliation windows
- different dispute handling

Provider adapter must be evidence-based.

Provider capability is `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED` until verified.

---

## 24. Tenant Support Complexity Boundary

As tenants grow, exception handling grows.

Support scaling must define:

- finance review queue
- security review queue
- store ops review queue
- provider review queue
- compliance review queue
- SLA class
- priority by amount/risk
- tenant communication template
- evidence package generation
- escalation route
- owner/franchise safe message
- DLQ aging report

Manual review must not become invisible backlog.

---

## 25. SaaS Package Boundary

Not every tenant should receive every capability.

Package tiers may separate:

| Capability | Possible Tier |
|---|---|
| Menu display only | Basic |
| Order intake | Standard |
| POS/KDS handoff | Standard/Pro |
| Payment handoff | Pro with provider verification |
| Financial-grade reconciliation | Certified |
| Device-key non-repudiation | Certified |
| Offline local mode | Certified |
| AI immune security | Certified/Enterprise |
| Analytics benchmark | Pro/Enterprise |
| Franchise OS integration | Enterprise |
| API/export access | Controlled add-on |

Capability packaging must match operational and security readiness.

Do not sell capability that the tenant’s hardware/provider setup cannot support.

---

## 26. Tenant Onboarding Boundary

SaaS onboarding must verify:

- tenant identity
- store identity
- legal entity
- provider account ownership
- device certification
- device enrollment
- admin roles
- support contacts
- payment route
- POS/KDS route
- retention/export agreement
- privacy/compliance agreement
- log retention consent/notice if required
- dispute handling policy
- SLA tier
- feature package

Onboarding is security and legal control.

It is not just account creation.

---

## 27. SaaS Contract Boundary

Tenant contract should later address:

- data ownership
- payment provider responsibility
- settlement responsibility
- platform responsibility
- device certification requirement
- unsupported device limitation
- log retention
- evidence use
- dispute process
- DLQ handling
- maintenance window
- batch closing timing
- partial closing
- outage/degraded mode
- security containment
- admin access
- termination and data export
- liability limits

Legal counsel must review SaaS contract language.

This document does not provide final legal terms.

---

## 28. SaaS Trust Statement Boundary

The platform may later communicate trust carefully.

Allowed direction:

- financial-grade reconciliation design
- multi-source evidence matching
- tenant-isolated architecture
- certified device support
- staged security containment
- auditable settlement process
- DLQ exception transparency
- controlled export and retention
- distributed batch architecture

Avoid absolute claims:

- impossible to hack
- zero error guaranteed
- all disputes automatically solved
- all devices supported
- all providers supported
- instant settlement always available
- legal compliance guaranteed without tenant cooperation

Trust claim must match actual certified capability.

---

## 29. SaaS Rollout Strategy Boundary

Recommended rollout:

| Stage | Strategy |
|---|---|
| Stage 1 | Yoonsul-owned stores only |
| Stage 2 | Friendly pilot stores with certified hardware |
| Stage 3 | Limited partner tenants by provider/device |
| Stage 4 | Regional/franchise group rollout |
| Stage 5 | Certified SaaS package |
| Stage 6 | Broader marketplace only after evidence |
| Stage 7 | Franchise OS integration |

Do not open the platform broadly before isolation, hardware, provider, batch, and support controls are proven.

---

## 30. Relationship To Tenant Isolation

This document reinforces `10141`.

SaaS scale makes tenant isolation non-negotiable.

Every table, view, command, query, projection, AI context, vector source, analytics report, export file, archive object, DLQ record, batch report, device key, provider credential, and support case must carry tenant/store/legal scope.

Tenant isolation must be tested continuously.

---

## 31. Relationship To Financial Reconciliation

This document extends:

- `10601`
- `10602`
- `10603`

SaaS scale adds:

- many tenants
- many providers
- many devices
- many OS variants
- many DLQ cases
- many batch partitions
- many legal disputes
- many support queues
- many archive objects

Reconciliation must be distributed, scoped, and package-aware.

---

## 32. Relationship To Security Agent

Security Agent must adapt to SaaS noise.

Security Agent must distinguish:

- attack
- noisy tenant behavior
- device failure
- offline recovery burst
- provider retry
- campaign traffic
- hardware incompatibility
- admin misuse
- cross-tenant attempt
- real compromise

Security Agent must be cost-gated.

Security Agent must not overuse LLM calls.

Security containment must be tenant/store scoped.

---

## 33. Relationship To Data Governance

Data Governance must govern SaaS-scale:

- CMS tenant targeting
- i18n tenant customization
- Safe Projection by package
- AI output visibility
- pgvector tenant isolation
- analytics aggregation threshold
- export approval
- retention tiering
- cold archive retrieval
- support/admin access
- legal/compliance hold
- owner/franchise messaging

Data Governance becomes more important as tenant count grows.

---

## 34. Relationship To Hardware Provisioning

This document connects to:

- Android device provisioning policy
- Windows installer/local runtime policy
- certified device enrollment
- device key lifecycle
- OS log collection
- kiosk mode
- local offline mode
- device revocation
- hardware certification program

Hardware certification is not optional for financial-grade SaaS.

---

## 35. Anti-Patterns

Avoid:

- open SaaS launch with arbitrary devices
- relying on UI filtering for tenant isolation
- mixing tenant logs in one unscoped export
- allowing tenant-owned provider keys in client app
- treating platform as fund custodian without legal review
- claiming regulatory compliance without counsel
- calling LLM on every log event
- storing all OS logs forever in hot DB
- one monolithic nightly batch for all tenants
- one tenant batch failure blocking all tenants
- unsupported hardware advertised as financial-grade
- BYOD device allowed to sign financial logs
- noisy tenant behavior treated as attack automatically
- provider capability assumed without evidence
- selling Enterprise features without operational support
- final settlement shown while tenant batch partition is incomplete

These anti-patterns must be blocked in future runtime design.

---

## 36. Runtime Deferral

This document defines SaaS scale constraints only.

It does not authorize:

- Firebase implementation
- Firestore security rules
- Supabase schema
- RLS policy
- tenant partitioning implementation
- payment provider integration
- legal compliance program
- certified hardware program
- device provisioning runtime
- AI cost control runtime
- distributed batch implementation
- SaaS packaging/pricing implementation
- contract issuance
- production launch

All runtime remains deferred.

---

## 37. Validation Checklist

Validation must confirm:

1. SaaS constraint catalog is defined.
2. Multi-tenancy isolation boundary is defined.
3. Tenant isolation implementation boundary is defined.
4. Firebase/Firestore constraint boundary is defined.
5. Supabase/PostgreSQL constraint boundary is defined.
6. Data partition strategy boundary is defined.
7. Payment regulatory boundary is defined without final legal assertion.
8. Provider credential boundary is defined.
9. Legal/compliance boundary is defined.
10. Hardware certification boundary is defined.
11. Hardware lock-in strategy boundary is defined.
12. OS log availability boundary is defined.
13. Device capability classification boundary is defined.
14. Noise/false positive boundary is defined.
15. AI cost boundary is defined.
16. Edge AI/lightweight detection boundary is defined.
17. Log volume/database cost boundary is defined.
18. Batch scaling boundary is defined.
19. Distributed batch boundary is defined.
20. Partial closing boundary is defined.
21. Provider fragmentation boundary is defined.
22. Tenant support complexity boundary is defined.
23. SaaS package boundary is defined.
24. Tenant onboarding boundary is defined.
25. SaaS contract boundary is defined.
26. SaaS trust statement boundary is defined.
27. SaaS rollout strategy boundary is defined.
28. Relationships to tenant isolation, financial reconciliation, security agent, data governance, and hardware provisioning are defined.
29. Anti-patterns are listed.
30. Coding remains unauthorized.
31. Runtime remains deferred.

---

## 38. Relationship To Previous Documents

This document supplements:

- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`
- `10603 Reconciliation DLQ Device Non-Repudiation And Cold Storage Lifecycle Policy`

It references:

- `10020~10057 Product Surface And SaaS Product Line Sequence`
- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400~10480 Financial Trust Room Framing Sequence`
- `10500~10580 Data Governance Room Framing Sequence`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`
- `10603 Reconciliation DLQ Device Non-Repudiation And Cold Storage Lifecycle Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future SaaS tenant isolation test matrix
- future certified hardware policy
- future distributed batch partition specification
- future AI cost control policy
- future SaaS package entitlement matrix
- future legal/compliance review packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 39. Final Rule

The four-layer immune security and financial-grade reconciliation platform may become SaaS only if scale constraints are controlled.

Multi-tenant isolation must be proven.

Payment custody and regulatory boundaries must be legally reviewed.

Provider credentials must be tenant-scoped and secret-managed.

Hardware must be certified before financial-grade capability is promised.

Uncertified devices must receive reduced authority.

AI must be cost-gated and noise-aware.

Logs must be partitioned, tiered, and retained without overloading the hot database.

Nightly reconciliation must become distributed, tenant-scoped, partially closable, DLQ-aware, and provider-aware.

SaaS rollout must begin with controlled hardware, controlled tenants, controlled providers, and controlled feature packages.

Open SaaS comes later.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
