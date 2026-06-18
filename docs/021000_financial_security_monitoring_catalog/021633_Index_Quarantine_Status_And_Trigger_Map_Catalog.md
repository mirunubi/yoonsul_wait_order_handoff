# 021633_Index_Quarantine_Status_And_Trigger_Map_Catalog

## 1. Purpose

This document defines the quarantine status and trigger map for the Financial-Grade Security Monitoring Foundation Package.

The previous artifact `21632` defined containment, which blocks dangerous propagation after a risk condition is detected.

This document defines quarantine, which isolates suspicious, unverified, malformed, stale, duplicate, ambiguous, or evidence-incomplete inputs before they are allowed to affect runtime truth.

Quarantine is the controlled waiting room.

Containment blocks spread.

Quarantine isolates questionable input.

This document is catalog-only.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This catalog applies to quarantine planning for:

1. External POS events
2. Provider callbacks
3. Payment state events
4. Settlement/provider reports
5. Membership sync events
6. Coupon use events
7. Wallet/prepaid value events
8. Customer identity link candidates
9. KDS ticket events
10. Inventory/supplier events
11. Content/i18n publication candidates
12. External projection payloads
13. Support/admin requests
14. AI outputs
15. pgvector source items
16. Archive migration/retrieval items
17. Workforce/HR events
18. Supplier/SCM/WMS events
19. Franchise OS sync events
20. Trigger-View-Agent monitoring signals

This catalog does not implement quarantine queues, database tables, review UIs, triggers, views, daemons, or runtime state machines.

---

## 3. Core Principle

Quarantine means the system does not yet trust the input.

A quarantined object may be stored, reviewed, compared, summarized, or linked to evidence.

A quarantined object must not mutate final business truth until reviewed and released through authority.

Quarantine applies before trust is granted.

The correct rule is:

Untrusted input enters quarantine first.
Evidence is attached.
Review determines release, rejection, reconciliation, or escalation.
No silent application is allowed.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `21633` |
| Package ID | `foundation.security_monitoring.financial_grade.v1` |
| Artifact Type | `CATALOG` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATALOG_ONLY` |
| Owner | `Architecture / Security Foundation` |
| Dependencies | `21631`, `21632`, `21630`, `21620`, `21610`, `21570`, `21560` |
| Provider Evidence Status | `APPLIES_IF_PROVIDER_RELATED` |
| i18n Requirement | `APPLIES_IF_ALERT_VISIBLE` |
| Audit Requirement | `REQUIRED_FOR_QUARANTINE_RELEASE_REJECTION_ESCALATION` |
| Security Requirement | `FINANCIAL_GRADE_QUARANTINE_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_AUDIT_REVIEW_REQUIRED` |
| Blocker Status | `QUARANTINE_CATALOG_REVIEW_REQUIRED` |

---

## 5. Quarantine Record Schema

Each quarantine rule must include:

| Field | Required Meaning |
|---|---|
| Quarantine Rule ID | Stable quarantine rule id |
| Bulkhead | Affected compartment |
| Quarantine Target | Event, payload, source, output, archive object, vector item, etc. |
| Trigger Event | Event family or condition |
| Trigger Reason | Why trust is not granted |
| Scope | Tenant, store, provider, device, customer, order, payment, etc. |
| Quarantine Status | Controlled status value |
| Allowed While Quarantined | What may be done safely |
| Prohibited While Quarantined | What must not happen |
| Evidence Requirement | Evidence or metadata required |
| Audit Requirement | Audit requirement |
| Alert Family | Alert generated |
| Review Route | Responsible route |
| Release Authority | Who may release |
| Rejection Rule | How to reject |
| Escalation Rule | When to escalate |
| Reconciliation Requirement | Whether reconciliation is required |
| pgvector Eligibility | Whether summary may be vectorized |
| AI Boundary | What AI may summarize/classify |
| Readiness Blocker | Blocker if undefined |

A quarantine rule without release/rejection authority is incomplete.

---

## 6. Quarantine Status Catalog

| Status | Meaning |
|---|---|
| `QUARANTINE_NOT_REQUIRED` | Input can proceed without quarantine |
| `QUARANTINE_CANDIDATE` | Input may require quarantine |
| `QUARANTINE_ACTIVE` | Input is isolated |
| `QUARANTINE_METADATA_CAPTURED` | Metadata captured for review |
| `QUARANTINE_EVIDENCE_REQUIRED` | Evidence required before decision |
| `QUARANTINE_REVIEW_PENDING` | Human/system review pending |
| `QUARANTINE_PROVIDER_VERIFICATION_PENDING` | Provider verification pending |
| `QUARANTINE_IDENTITY_VERIFICATION_PENDING` | Identity/consent verification pending |
| `QUARANTINE_RECONCILIATION_REQUIRED` | Reconciliation required before release |
| `QUARANTINE_SECURITY_REVIEW_REQUIRED` | Security review required |
| `QUARANTINE_LEGAL_REVIEW_REQUIRED` | Legal/compliance review required |
| `QUARANTINE_AI_REVIEW_ALLOWED` | AI may summarize under boundary |
| `QUARANTINE_PGVECTOR_REVIEW_ALLOWED` | pgvector may use approved summary |
| `QUARANTINE_RELEASE_PENDING` | Release requested |
| `QUARANTINE_RELEASED` | Released after authority review |
| `QUARANTINE_REJECTED` | Rejected after review |
| `QUARANTINE_EXPIRED` | Expired without release |
| `QUARANTINE_ESCALATED` | Escalated due to risk or delay |
| `QUARANTINE_FALSE_POSITIVE_REVIEW` | False-positive review opened |
| `QUARANTINE_REOPENED` | Reopened after new evidence |
| `QUARANTINE_REPLAY_REQUIRED` | Replay required after release |

Quarantine states must not be collapsed into a boolean flag.

---

## 7. Quarantine Action Catalog

| Action | Meaning |
|---|---|
| `QUARANTINE_STORE_ONLY` | Store object without applying it |
| `QUARANTINE_METADATA_ONLY` | Store metadata only, not full payload |
| `QUARANTINE_REDACT_AND_STORE` | Redact sensitive fields and store |
| `QUARANTINE_HASH_ONLY` | Store hash/checksum only |
| `QUARANTINE_REVIEW_QUEUE` | Place item into review queue |
| `QUARANTINE_PROVIDER_VERIFY` | Require provider verification |
| `QUARANTINE_IDENTITY_VERIFY` | Require identity/consent verification |
| `QUARANTINE_RECONCILE` | Require reconciliation |
| `QUARANTINE_REJECT` | Reject input after review |
| `QUARANTINE_RELEASE` | Release after authority review |
| `QUARANTINE_ESCALATE` | Escalate due to severity/delay |
| `QUARANTINE_REPLAY_AFTER_RELEASE` | Replay only after release |
| `QUARANTINE_BLOCK_VECTORIZE` | Block vectorization |
| `QUARANTINE_BLOCK_AI_USE` | Block AI use |

These are planning actions.

They do not implement runtime behavior.

---

## 8. Quarantine Versus Containment

| Concept | Meaning | Example |
|---|---|---|
| Quarantine | Isolate untrusted input before it affects truth | Unverified provider callback stored for review |
| Containment | Block dangerous propagation after risk threshold | Payment state held after callback mismatch |
| Reconciliation | Compare and resolve mismatch through authority | Provider amount and internal amount differ |
| Evidence | Material used for review | Callback metadata, hash, audit signal |
| Audit | Accountability record | Who released/rejected/replayed |

Quarantine can lead to containment if the risk escalates.

Containment can generate quarantine of related inputs.

They are related but not identical.

---

## 9. External POS Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-POS-MALFORMED` | Malformed POS event | POS event metadata | Platform/security |
| `CTRL-QUAR-POS-UNMAPPED` | Store/order/session cannot be mapped | POS event | Store/platform |
| `CTRL-QUAR-POS-DUP-PAYLOAD` | Duplicate key with different payload | POS event | Security/reconciliation |
| `CTRL-QUAR-POS-STALE` | Event older than allowed window | POS event | Platform/store |
| `CTRL-QUAR-POS-CROSS-STORE` | Event refers to another store | POS event | Security |
| `CTRL-QUAR-POS-CROSS-TENANT` | Event refers to another tenant | POS event | Security/HQ |
| `CTRL-QUAR-POS-LOCAL-CACHE` | Local cache state sent as authority | POS state packet | Platform/security |
| `CTRL-QUAR-POS-UNKNOWN-DEVICE` | Unknown POS device/session | Device event | Security/platform |

Quarantined POS events must not update payment, ledger, membership, KDS, or inventory truth.

---

## 10. Provider Callback Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-PROVIDER-CALLBACK-UNSIGNED` | Missing signature | Callback metadata | Security/provider |
| `CTRL-QUAR-PROVIDER-CALLBACK-SIGNATURE-FAILED` | Signature failed | Callback metadata | Security/provider |
| `CTRL-QUAR-PROVIDER-CALLBACK-REPLAY` | Replay detected | Callback event | Security/provider |
| `CTRL-QUAR-PROVIDER-CALLBACK-UNMAPPED` | Cannot map callback | Callback payload/metadata | Provider/reconciliation |
| `CTRL-QUAR-PROVIDER-CALLBACK-DUP-MISMATCH` | Duplicate with payload mismatch | Callback metadata | Security/reconciliation |
| `CTRL-QUAR-PROVIDER-CAPABILITY-CLAIM` | Capability claim without evidence | Capability assertion | Provider/legal |
| `CTRL-QUAR-PROVIDER-SETTLEMENT-REPORT` | Report missing/incomplete | Settlement report | Finance/provider |
| `CTRL-QUAR-PROVIDER-CONTRACT-DRIFT` | API behavior changed | Provider contract signal | Provider/security |

Provider quarantine preserves evidence-required state.

No provider callback may mutate final state before verification.

---

## 11. Payment Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-PAYMENT-STATE-UNCERTAIN` | Conflicting payment state | Payment event | Finance/provider |
| `CTRL-QUAR-PAYMENT-AMOUNT-MISMATCH` | Amount mismatch | Payment event | Finance/reconciliation |
| `CTRL-QUAR-PAYMENT-DUP-CAPTURE` | Duplicate capture candidate | Payment event | Finance/security |
| `CTRL-QUAR-PAYMENT-REFUND-MISMATCH` | Refund status mismatch | Refund event | Finance/support |
| `CTRL-QUAR-PAYMENT-CALLBACK-MISSING` | Missing callback | Payment context | Finance/provider |
| `CTRL-QUAR-PAYMENT-POS-CANCELLED` | POS canceled but payment uncertain | Payment/order state | Finance/store |

Payment quarantine must block final financial mutation until review.

---

## 12. Ledger And Settlement Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-LEDGER-ENTRY-EVIDENCE-MISSING` | Evidence missing | Ledger candidate | Finance/reconciliation |
| `CTRL-QUAR-LEDGER-IMBALANCE-CANDIDATE` | Imbalance candidate | Ledger batch | Finance |
| `CTRL-QUAR-SETTLEMENT-PROVIDER-MISMATCH` | Provider/internal mismatch | Settlement row | Finance/provider |
| `CTRL-QUAR-SETTLEMENT-FX-MISSING` | FX evidence missing | Overseas settlement row | Finance/provider |
| `CTRL-QUAR-SETTLEMENT-PARTNER-STALE` | Partner report stale | Settlement report | Finance/provider |
| `CTRL-QUAR-LEDGER-CORRECTION-NO-AUTH` | Correction without authority | Correction request | Finance/security |

Quarantine does not create ledger correction.

---

## 13. Membership Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-MEMBERSHIP-IDENTITY-CONFLICT` | Identity conflict | Membership event | Membership/privacy |
| `CTRL-QUAR-MEMBERSHIP-PARTNER-SYNC` | Partner sync mismatch | Sync packet | Membership/support |
| `CTRL-QUAR-MEMBERSHIP-POINT-MISMATCH` | Point mismatch | Point event | Membership/support |
| `CTRL-QUAR-MEMBERSHIP-GRADE-MISMATCH` | Grade mismatch | Grade event | Membership/support |
| `CTRL-QUAR-MEMBERSHIP-BENEFIT-CONFLICT` | Benefit rule conflict | Benefit event | CRM/support |
| `CTRL-QUAR-MEMBERSHIP-CONSENT-MISSING` | Consent missing | Identity/benefit link | Privacy/legal |

Membership quarantine must not adjust points, grade, or benefits.

---

## 14. Coupon Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-COUPON-DUPLICATE-USE` | Duplicate use candidate | Coupon use event | CRM/support |
| `CTRL-QUAR-COUPON-RULE-MISMATCH` | Rule mismatch | Coupon event | CRM |
| `CTRL-QUAR-COUPON-CAMPAIGN-CONFLICT` | Campaign conflict | Campaign/coupon | CRM/HQ |
| `CTRL-QUAR-COUPON-PARTNER-STALE` | Partner coupon state stale | Partner sync | CRM/provider |
| `CTRL-QUAR-COUPON-IDEMPOTENCY-MISSING` | Missing idempotency key | Coupon use event | CRM/platform |

Coupon quarantine must preserve duplicate prevention.

---

## 15. Wallet Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-WALLET-DUP-CHARGE` | Duplicate charge candidate | Wallet charge event | Finance/support |
| `CTRL-QUAR-WALLET-DUP-USE` | Duplicate use candidate | Wallet use event | Finance/support |
| `CTRL-QUAR-WALLET-BALANCE-MISMATCH` | Balance mismatch | Wallet balance event | Finance/reconciliation |
| `CTRL-QUAR-WALLET-REFUND-MISMATCH` | Refund mismatch | Wallet refund event | Finance/support |
| `CTRL-QUAR-WALLET-UNAUTH-ADJUSTMENT` | Unauthorized adjustment | Adjustment request | Finance/security |

Wallet quarantine must not alter balance.

---

## 16. Identity Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-IDENTITY-WRONG-LINK` | Wrong account candidate | Link request | Privacy/support |
| `CTRL-QUAR-IDENTITY-DUPLICATE` | Duplicate identity candidate | Identity candidate | Privacy/support |
| `CTRL-QUAR-IDENTITY-CONSENT-MISSING` | Consent missing | Link/merge request | Privacy/legal |
| `CTRL-QUAR-IDENTITY-PARTNER-MISMATCH` | Partner identity mismatch | Partner identity packet | Privacy/provider |
| `CTRL-QUAR-IDENTITY-CROSS-CUSTOMER` | Cross-customer mapping risk | Mapping request | Privacy/security |

Identity quarantine must block link, unlink, merge, and relink until authorized.

---

## 17. KDS Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-KDS-DUP-TICKET` | Duplicate ticket candidate | Ticket event | Store/support |
| `CTRL-QUAR-KDS-ORDER-MISMATCH` | Order/ticket mismatch | Ticket/order event | Store/support |
| `CTRL-QUAR-KDS-PAYMENT-MISMATCH` | Ticket/payment mismatch | Ticket/payment context | Store/finance/support |
| `CTRL-QUAR-KDS-MANUAL-NO-EVIDENCE` | Manual fallback missing evidence | Manual ticket | Store/support |
| `CTRL-QUAR-KDS-UNMAPPED-STATION` | Station route unmapped | Route event | Store/platform |
| `CTRL-QUAR-KDS-UNAVAILABLE-ITEM` | Item unavailable conflict | Ticket item | Store/inventory |

KDS quarantine must not approve refund or payment mutation.

---

## 18. Inventory And Supplier Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-INVENTORY-STOCK-MISMATCH` | Stock mismatch | Stock event | Store/inventory |
| `CTRL-QUAR-INVENTORY-AVAILABILITY-STALE` | Availability stale | Availability projection | Store/platform |
| `CTRL-QUAR-INVENTORY-WASTE-NO-EVIDENCE` | Waste evidence missing | Waste/disposal event | Store/QC |
| `CTRL-QUAR-SUPPLIER-DELIVERY-MISMATCH` | Delivery mismatch | Delivery/receiving event | SCM/store |
| `CTRL-QUAR-SUPPLIER-QUALITY-ISSUE` | Quality issue | Supplier batch/item | QC/SCM |
| `CTRL-QUAR-WMS-STOCK-CONFLICT` | WMS stock conflict | WMS stock event | WMS/inventory |

Inventory quarantine must not silently adjust stock.

---

## 19. Content And i18n Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-I18N-MISSING-KEY` | Message key missing | Message/content reference | Localization/content |
| `CTRL-QUAR-I18N-WRONG-LOCALE` | Wrong locale candidate | Locale text | Localization |
| `CTRL-QUAR-CONTENT-SOURCE-MISSING` | Source trace missing | Content item | Content |
| `CTRL-QUAR-CONTENT-UNAPPROVED` | Content unapproved | Content item | Content/support |
| `CTRL-QUAR-ALLERGEN-MISMATCH` | Allergen text mismatch | Menu text | Content/QC/legal |
| `CTRL-QUAR-AI-GENERATED-TEXT` | AI-generated text needs approval | Draft text | Content/localization |

Content quarantine must block customer-facing publication until approved.

---

## 20. External Projection Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-PROJECTION-PRICE-MISMATCH` | Price mismatch | Projection payload | Projection/content |
| `CTRL-QUAR-PROJECTION-ALLERGEN-MISMATCH` | Allergen mismatch | Projection payload | QC/content/legal |
| `CTRL-QUAR-PROJECTION-AVAILABILITY-MISMATCH` | Availability mismatch | Projection payload | Store/inventory |
| `CTRL-QUAR-PROJECTION-PAYMENT-CAPABILITY` | Payment capability unverified | Projection capability | Provider/legal |
| `CTRL-QUAR-PROJECTION-STALE` | Projection stale | Projection snapshot | Projection/platform |
| `CTRL-QUAR-PROJECTION-PARTNER-SYNC` | Partner sync mismatch | Partner payload | Provider/projection |

Projection quarantine prevents public exposure of unverified state.

---

## 21. Support/Admin Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-SUPPORT-REFUND-NO-EVIDENCE` | Refund request lacks evidence | Refund request | Support/finance |
| `CTRL-QUAR-SUPPORT-EXPORT-RISK` | Restricted export request | Export request | Security/legal |
| `CTRL-QUAR-SUPPORT-UNMASKING-NO-AUTH` | Unmasking lacks authority | Unmask request | Security/support lead |
| `CTRL-QUAR-SUPPORT-CASE-EVIDENCE-MISSING` | Case closure lacks evidence | Case closure request | Support lead |
| `CTRL-QUAR-SUPPORT-AI-DRAFT` | AI draft not approved | Support message draft | Support/content |
| `CTRL-QUAR-SUPPORT-OVERRIDE` | Override action candidate | Override request | Support/security |

Support quarantine must not allow execution until reviewed.

---

## 22. AI Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-AI-RESTRICTED-SOURCE` | Restricted source requested | AI request | AI/security |
| `CTRL-QUAR-AI-UNTRACEABLE-OUTPUT` | Output lacks traceability | AI output | AI governance |
| `CTRL-QUAR-AI-WRONG-LOCALE` | Wrong locale output | AI output | Localization/content |
| `CTRL-QUAR-AI-CUSTOMER-FACING` | Customer-facing draft | AI output | Support/content |
| `CTRL-QUAR-AI-PROVIDER-CAPABILITY` | Provider capability invented/asserted | AI output | Provider/legal |
| `CTRL-QUAR-AI-EVIDENCE-SUMMARY` | Evidence summary ambiguous | AI summary | Audit/security |

AI quarantine must preserve “derived only” status.

---

## 23. pgvector Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-PGVECTOR-SOURCE-UNAPPROVED` | Unapproved source | Source item | AI/security |
| `CTRL-QUAR-PGVECTOR-TRACE-MISSING` | Traceability missing | Vector item | AI/data governance |
| `CTRL-QUAR-PGVECTOR-RESTRICTED-DATA` | Restricted data risk | Source/vector | Security/legal |
| `CTRL-QUAR-PGVECTOR-CROSS-TENANT` | Cross-tenant retrieval risk | Query/result | Security |
| `CTRL-QUAR-PGVECTOR-WRONG-LOCALE` | Wrong locale result | Query/result | Localization |
| `CTRL-QUAR-PGVECTOR-STALE` | Stale vector | Vector/source link | AI/data governance |
| `CTRL-QUAR-PGVECTOR-AUTHORITY-MISUSE` | Similarity used as truth | Review/action | AI/security |

pgvector quarantine must block vector ingestion/retrieval when trust is unclear.

---

## 24. Archive And Retention Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-ARCHIVE-MANIFEST-MISSING` | Manifest missing | Archive object | Data governance/audit |
| `CTRL-QUAR-ARCHIVE-CHECKSUM-FAILED` | Checksum/hash failed | Archive object | Security/audit |
| `CTRL-QUAR-ARCHIVE-LEGAL-HOLD-CONFLICT` | Deletion during legal hold | Delete request | Legal/security |
| `CTRL-QUAR-ARCHIVE-CROSS-TENANT` | Cross-tenant retrieval candidate | Retrieval request | Security/legal |
| `CTRL-QUAR-ARCHIVE-VECTOR-DEPENDENCY` | Vector depends on deleted/anonymized source | Vector/source dependency | AI/data governance |
| `CTRL-QUAR-ARCHIVE-RESTORE-REQUEST` | Archive restore requested | Restore request | Data governance/security |

Archive quarantine prevents archive from becoming uncontrolled runtime authority.

---

## 25. Workforce HR Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-HR-ROLE-MISMATCH` | Role mismatch | Role update | HR/security |
| `CTRL-QUAR-HR-ATTENDANCE-DUP` | Duplicate attendance | Attendance event | HR/store |
| `CTRL-QUAR-HR-ATTENDANCE-UNMAPPED` | Unmapped attendance | Attendance event | HR/store |
| `CTRL-QUAR-HR-ELIGIBILITY-MISSING` | Eligibility evidence missing | Eligibility record | HR/legal |
| `CTRL-QUAR-HR-PAYROLL-ADJACENT` | Payroll-adjacent mismatch | HR/payroll event | HR/finance |

HR quarantine must not make final legal/employment decision automatically.

---

## 26. Franchise OS Quarantine Rules

| Rule ID | Trigger | Quarantine Target | Required Review |
|---|---|---|---|
| `CTRL-QUAR-FRANCHISE-POLICY-MISMATCH` | Policy version mismatch | Policy sync | Franchise/HQ |
| `CTRL-QUAR-FRANCHISE-ROYALTY-CONFLICT` | Royalty rule conflict | Royalty rule event | Franchise/finance |
| `CTRL-QUAR-FRANCHISE-LEGAL-ENTITY` | Legal entity mismatch | Store/legal entity event | Franchise/legal |
| `CTRL-QUAR-FRANCHISE-STORE-SYNC` | Store sync mismatch | Store sync event | Franchise/HQ |
| `CTRL-QUAR-FRANCHISE-MENU-POLICY` | Menu policy mismatch | Menu/policy event | Franchise/content |

Franchise quarantine preserves HQ, finance, and legal review boundaries.

---

## 27. Allowed While Quarantined

Quarantined objects may be used for:

- structured logging
- evidence packet creation
- audit signal creation
- review queue display
- reconciliation candidate creation
- pgvector-approved summary creation
- AI-assisted internal summary
- provider verification
- legal/compliance review
- support/admin review
- false-positive review
- rejection decision
- release decision

Only approved metadata or summaries may be used for pgvector/AI.

---

## 28. Prohibited While Quarantined

Quarantined objects must not:

- mutate payment state
- mutate ledger
- mutate settlement allocation
- mutate membership points
- mutate wallet balance
- mutate coupon state
- link customer identity
- publish external projection
- publish customer-facing content
- create final KDS execution state
- close support case
- approve refund
- approve compensation
- confirm provider capability
- release containment
- bypass audit
- become source of truth

Quarantine is not permission to apply.

---

## 29. Quarantine Release Rule

Quarantine release requires:

- quarantine id
- affected bulkhead
- target object id
- release authority
- review reason
- evidence status
- audit event
- release scope
- downstream action allowed
- reconciliation requirement if any
- replay rule if any
- customer/store impact review if any
- pgvector/AI derived-output status if used

Release must be scoped.

Release does not automatically mean final resolution.

---

## 30. Quarantine Rejection Rule

Quarantine rejection requires:

- quarantine id
- target object id
- rejection authority
- rejection reason
- evidence status
- audit event
- alert update
- whether customer/support action is needed
- whether provider escalation is needed
- whether security/legal review is needed
- whether rule tuning is needed

Rejected objects must not be silently deleted if audit/evidence retention applies.

---

## 31. Quarantine Escalation Rule

Quarantine must escalate when:

- severity is critical
- evidence is missing beyond threshold
- provider verification fails
- legal/compliance trigger exists
- customer impact exists
- value-bearing risk exists
- identity/privacy risk exists
- cross-tenant risk exists
- repeated quarantine occurs
- same source repeatedly fails
- quarantine queue becomes stale
- AI/pgvector misuse is detected
- false-positive rate suggests rule problem

Escalation route must follow alert routing policy.

---

## 32. Quarantine Evidence Requirements

Quarantine evidence may include:

- raw-safe metadata
- redacted payload
- hash/checksum
- provider event id
- callback verification result
- source table/id
- idempotency key
- correlation id
- tenant/store scope
- actor/source class
- error code
- monitoring view reference
- AI summary marked derived
- pgvector source metadata
- archive manifest
- support case reference
- legal hold reference

Evidence must be sufficient to explain why the object was quarantined.

---

## 33. Quarantine Audit Requirements

Audit is required for:

- quarantine activation
- quarantine release
- quarantine rejection
- quarantine escalation
- quarantine false-positive release
- manual override
- provider evidence acceptance
- identity release
- value-bearing release
- archive retrieval release
- AI output release
- pgvector source/retrieval release
- legal hold conflict handling

Audit must record actor/system actor, reason, scope, evidence, and authority.

---

## 34. Quarantine And pgvector

pgvector may observe quarantine only through approved summaries.

Allowed:

- quarantine reason summary
- redacted incident summary
- alert family
- error code
- domain
- severity
- review outcome
- source trace metadata

Blocked:

- full sensitive payload
- raw payment data
- raw identity data
- provider secrets
- service role keys
- unrestricted support notes
- legal hold material without approval
- unmasked customer data

Quarantine does not automatically make data vector-eligible.

---

## 35. Quarantine And AI

AI may assist quarantine review only under strict boundaries.

AI may:

- summarize quarantine reason
- classify likely event family
- suggest missing evidence
- identify related prior incidents
- draft internal reviewer note
- suggest escalation route
- suggest whether provider evidence is missing

AI must not:

- release quarantine
- reject quarantine
- approve mutation
- confirm provider capability
- approve refund/compensation
- link identity
- publish projection
- close support case
- treat its summary as original evidence

AI output must be marked derived.

---

## 36. Quarantine Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-QUARANTINE-CATALOG-0001` | Quarantine catalog not reviewed |
| `BLOCKER-QUARANTINE-STATUS-0001` | Quarantine status catalog incomplete |
| `BLOCKER-QUARANTINE-ACTION-0001` | Quarantine action catalog incomplete |
| `BLOCKER-QUARANTINE-SCOPE-0001` | Quarantine scope missing |
| `BLOCKER-QUARANTINE-RELEASE-0001` | Release authority missing |
| `BLOCKER-QUARANTINE-REJECTION-0001` | Rejection rule missing |
| `BLOCKER-QUARANTINE-ESCALATION-0001` | Escalation rule missing |
| `BLOCKER-QUARANTINE-EVIDENCE-0001` | Evidence requirement missing |
| `BLOCKER-QUARANTINE-AUDIT-0001` | Audit requirement missing |
| `BLOCKER-QUARANTINE-AI-PGVECTOR-0001` | AI/pgvector boundary missing |
| `BLOCKER-QUARANTINE-PROHIBITED-ACTION-0001` | Prohibited while quarantined rule missing |

Open quarantine blockers prevent runtime quarantine implementation.

---

## 37. Validation Checklist

Validation must confirm:

- every quarantine rule has rule id
- every quarantine rule maps to a bulkhead
- every quarantine rule has target object
- every quarantine rule has trigger reason
- every quarantine rule has scope
- every quarantine rule has allowed/prohibited behavior
- every quarantine rule has release authority
- every quarantine rule has rejection rule
- every quarantine rule has escalation rule
- every quarantine rule has evidence requirement
- every quarantine rule has audit requirement
- quarantined objects cannot mutate runtime truth
- quarantined provider callback cannot mutate payment/ledger
- quarantined identity event cannot link accounts
- quarantined coupon/wallet event cannot change value
- quarantined AI output cannot be customer-facing
- quarantined vector source cannot be ingested
- AI cannot release quarantine
- pgvector cannot release quarantine
- quarantine is not resolution

---

## 38. Relationship To Previous Documents

This document implements Artifact Group B from:

- `21630 Financial-Grade Security Monitoring Foundation Catalog Execution Plan And Artifact Map`

It follows:

- `21631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `21632 Containment Status And Trigger Map Catalog`

It depends on:

- `21570 Financial-Grade Security Foundation Control Catalog And Bulkhead Readiness Policy`
- `21580 AI Daemon Security Monitoring Agent And Autonomous Containment Policy`
- `21590 Trigger View Agent Monitoring Pipeline And Audit Projection Policy`
- `21620 Financial-Grade Security Monitoring Catalog Work Order And Implementation Handoff Policy`

This document is Foundation-grade and catalog-only.

It does not authorize coding.

---

## 39. Final Rule

Quarantine is the controlled isolation state for untrusted, suspicious, stale, malformed, duplicate, ambiguous, evidence-incomplete, or authority-uncertain input.

A quarantined object may be logged, reviewed, summarized, evidenced, audited, reconciled, rejected, released, or escalated.

A quarantined object must not mutate runtime truth, value, identity, ledger, payment, projection, support resolution, provider capability, or customer-facing state before authorized release.

AI and pgvector may assist quarantine review only through approved summaries and traceable metadata.

AI and pgvector may not release, reject, resolve, mutate, publish, compensate, refund, link, or confirm authority.

Coding remains deferred until this quarantine catalog is reviewed, validated, and attached to package-specific entry gates.
