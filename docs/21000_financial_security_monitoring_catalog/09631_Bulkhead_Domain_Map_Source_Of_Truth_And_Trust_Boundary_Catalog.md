# 09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog

## 1. Purpose

This document defines the first Foundation catalog artifact for the Financial-Grade Security Monitoring package.

The purpose is to map every major integration and runtime domain to a security bulkhead, source-of-truth rule, trust boundary, allowed propagation path, containment trigger, quarantine trigger, audit/evidence requirement, pgvector eligibility, and AI access boundary.

This is the first catalog artifact suggested by `09630`.

This document is catalog-only.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This catalog applies to the following domains:

1. External POS
2. Payment
3. Settlement ledger
4. Membership
5. Wallet and prepaid value
6. Coupon and promotion
7. Customer identity and consent
8. KDS
9. Inventory and sold-out
10. Content and i18n
11. External projection
12. Support/admin
13. AI
14. pgvector
15. Provider
16. Tenant
17. Store
18. Audit and evidence
19. Archive and retention
20. Workforce/HR
21. Supplier/SCM/WMS
22. Franchise OS

This catalog defines security compartments.

It does not implement runtime isolation, RLS, triggers, views, queues, daemons, pgvector schemas, or provider adapters.

---

## 3. Core Principle

Every domain must have a wall.

Every wall must declare:

- what it protects
- what it trusts
- what it refuses
- what it can send out
- what it can receive
- what must be quarantined
- what must trigger containment
- what evidence must be preserved
- what audit must be written
- whether pgvector may observe it
- whether AI may assist it
- who can release or resolve it

A domain without a bulkhead is not implementation-ready.

---

## 4. Bulkhead Catalog Header

| Field | Value |
|---|---|
| Document ID | `09631` |
| Package ID | `foundation.security_monitoring.financial_grade.v1` |
| Artifact Type | `CATALOG` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATALOG_ONLY` |
| Owner | `Architecture / Security Foundation` |
| Dependencies | `09560`, `09570`, `09580`, `09590`, `09600`, `09610`, `09620`, `09630` |
| Provider Evidence Status | `APPLIES_IF_PROVIDER_RELATED` |
| i18n Requirement | `APPLIES_IF_VISIBLE_ALERT_OR_STATUS` |
| Audit Requirement | `APPLIES_IF_AUTHORITY_OR_RESTRICTED_DATA` |
| Security Requirement | `FINANCIAL_GRADE_FOUNDATION_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_AUDIT_REVIEW_REQUIRED` |
| Blocker Status | `BULKHEAD_CATALOG_REVIEW_REQUIRED` |

---

## 5. Bulkhead Record Schema

Each bulkhead record must include:

| Field | Required Meaning |
|---|---|
| Bulkhead ID | Stable compartment id |
| Domain | Runtime or integration domain |
| Protected Assets | What must be protected |
| Source Of Truth | Authoritative system or rule |
| Trust Level | Trusted, limited-trust, untrusted, evidence-only |
| Allowed Inbound | Events/data allowed to enter |
| Allowed Outbound | Events/data allowed to leave |
| Prohibited Propagation | What must not cross the wall |
| Containment Trigger | Event that activates containment |
| Quarantine Trigger | Event that isolates input/data |
| Audit Requirement | Required audit family |
| Evidence Requirement | Required evidence packet |
| Alert Requirement | Required alert family |
| pgvector Eligibility | Allowed, summary-only, blocked |
| AI Access Boundary | Allowed assistance and prohibited authority |
| Release Authority | Who may release containment/quarantine |
| Readiness Blocker | Blocker if undefined |

---

## 6. Trust Level Catalog

| Trust Level | Meaning |
|---|---|
| `TRUST_INTERNAL_AUTHORITY` | Internal source-of-truth domain |
| `TRUST_INTERNAL_REVIEWED` | Internal domain with review control |
| `TRUST_LIMITED_CONTEXT` | May provide context but not final authority |
| `TRUST_EVIDENCE_ONLY` | May provide evidence only |
| `TRUST_PROVIDER_VERIFIED_REQUIRED` | Provider input requires verification |
| `TRUST_EXTERNAL_UNVERIFIED` | External input not trusted by default |
| `TRUST_PROJECTION_ONLY` | Output/display projection only |
| `TRUST_AI_ASSIST_ONLY` | AI may assist but not decide |
| `TRUST_VECTOR_ASSIST_ONLY` | pgvector may retrieve similarity but not decide |
| `TRUST_BLOCKED_BY_DEFAULT` | Blocked unless explicitly approved |

Default for external systems:

`TRUST_EXTERNAL_UNVERIFIED`

Default for AI:

`TRUST_AI_ASSIST_ONLY`

Default for pgvector:

`TRUST_VECTOR_ASSIST_ONLY`

---

## 7. Source Of Truth Catalog

| Source Type | Meaning |
|---|---|
| `SOT_INTERNAL_LEDGER` | Internal append-only ledger is authority |
| `SOT_INTERNAL_MEMBERSHIP_LEDGER` | Internal membership/value ledger is authority |
| `SOT_INTERNAL_IDENTITY_CONSENT` | Internal identity/consent registry is authority |
| `SOT_INTERNAL_CONTENT_REGISTRY` | Internal content registry is authority |
| `SOT_INTERNAL_I18N_REGISTRY` | Internal message/locale registry is authority |
| `SOT_INTERNAL_INVENTORY` | Internal inventory/availability authority |
| `SOT_KDS_EXECUTION_ONLY` | KDS is authority only for kitchen execution |
| `SOT_PROVIDER_VERIFIED_CALLBACK` | Provider callback only after verification |
| `SOT_PROVIDER_EVIDENCE_REQUIRED` | Provider evidence required before authority |
| `SOT_SUPPORT_REVIEW_ONLY` | Support can review/request, not silently mutate |
| `SOT_AI_NONE` | AI is not source of truth |
| `SOT_PGVECTOR_NONE` | pgvector is not source of truth |
| `SOT_EXTERNAL_PROJECTION_NONE` | Projection is not source of truth |
| `SOT_POS_CONTEXT_ONLY` | POS provides context only unless verified |

---

## 8. Bulkhead: External POS

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_POS` |
| Domain | External POS / POS module |
| Protected Assets | Store context, order context, payment references, device session, tokenized references |
| Source Of Truth | `SOT_POS_CONTEXT_ONLY` |
| Trust Level | `TRUST_LIMITED_CONTEXT` |
| Allowed Inbound | POS order context, table/session context, device health signal, tokenized references |
| Allowed Outbound | Display-safe order/payment status keys, scoped token response, limited operational status |
| Prohibited Propagation | Raw payment data, provider credentials, settlement authority, customer identity secrets |
| Containment Trigger | Cross-store event, token scope violation, malformed event, local cache used as truth |
| Quarantine Trigger | Unmapped POS event, duplicate payload mismatch, stale event |
| Audit Requirement | Required for rejected, quarantined, cross-store, or token events |
| Evidence Requirement | Required for contamination/reconciliation cases |
| Alert Requirement | POS security alert family |
| pgvector Eligibility | Metadata summary only |
| AI Access Boundary | May summarize POS anomaly, cannot trust POS event as truth |
| Release Authority | Security/platform review |
| Readiness Blocker | `BLOCKER-BULKHEAD-POS-0001` |

---

## 9. Bulkhead: Payment

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_PAYMENT` |
| Domain | Payment gateway and payment state |
| Protected Assets | Payment intent, authorization, capture, refund state, provider callback linkage |
| Source Of Truth | `SOT_PROVIDER_VERIFIED_CALLBACK` plus internal payment contract |
| Trust Level | `TRUST_PROVIDER_VERIFIED_REQUIRED` |
| Allowed Inbound | Verified provider callback, internal payment request, refund request candidate |
| Allowed Outbound | Payment status keys, reconciliation candidate, evidence packet references |
| Prohibited Propagation | Unverified callback to final payment state, KDS completion to payment success |
| Containment Trigger | Signature failure, duplicate capture risk, callback replay, payment state uncertainty |
| Quarantine Trigger | Unverified callback, unmapped callback, duplicate payload mismatch |
| Audit Requirement | Required for callback verification, refund request, refund execution candidate |
| Evidence Requirement | Required for provider callback, refund, mismatch |
| Alert Requirement | Payment/provider alert family |
| pgvector Eligibility | Provider/payment metadata summary only |
| AI Access Boundary | May summarize mismatch, cannot approve refund or capture |
| Release Authority | Finance/security/provider review |
| Readiness Blocker | `BLOCKER-BULKHEAD-PAYMENT-0001` |

---

## 10. Bulkhead: Settlement Ledger

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_LEDGER` |
| Domain | Settlement, double-entry ledger, reconciliation |
| Protected Assets | Ledger entries, settlement allocations, corrections, reversals, exchange-rate evidence |
| Source Of Truth | `SOT_INTERNAL_LEDGER` |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Verified payment events, provider settlement evidence, correction requests |
| Allowed Outbound | Reconciliation status, finance reports, evidence references |
| Prohibited Propagation | Silent UPDATE/DELETE, support-note mutation, AI correction, unverified provider report |
| Containment Trigger | Ledger imbalance, settlement mismatch, exchange-rate evidence missing |
| Quarantine Trigger | Provider settlement report missing/incomplete, correction without evidence |
| Audit Requirement | Always required for ledger changes and correction candidates |
| Evidence Requirement | Required for provider reports, corrections, reconciliation |
| Alert Requirement | Settlement/ledger alert family |
| pgvector Eligibility | Reconciliation summaries only |
| AI Access Boundary | May suggest pattern, cannot mutate ledger |
| Release Authority | Finance/reconciliation authority |
| Readiness Blocker | `BLOCKER-BULKHEAD-LEDGER-0001` |

---

## 11. Bulkhead: Membership

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_MEMBERSHIP` |
| Domain | Membership, points, grade, visit count, benefits |
| Protected Assets | Point balance, grade, visit count, benefit eligibility, customer membership identity |
| Source Of Truth | `SOT_INTERNAL_MEMBERSHIP_LEDGER` |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Internal order completion evidence, verified partner sync, customer consent-linked identity |
| Allowed Outbound | Display-safe membership status, benefit eligibility status, support review candidate |
| Prohibited Propagation | Partner state silently overwriting internal membership, duplicate points, wrong identity merge |
| Containment Trigger | Point mismatch, duplicate identity, benefit rule conflict |
| Quarantine Trigger | Partner sync mismatch, duplicate account candidate, identity conflict |
| Audit Requirement | Required for value/identity-related changes |
| Evidence Requirement | Required for mismatch and customer recovery cases |
| Alert Requirement | Membership alert family |
| pgvector Eligibility | Conflict summaries only |
| AI Access Boundary | May summarize conflict, cannot adjust points/grade |
| Release Authority | Membership/support/privacy review |
| Readiness Blocker | `BLOCKER-BULKHEAD-MEMBERSHIP-0001` |

---

## 12. Bulkhead: Wallet And Prepaid Value

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_WALLET` |
| Domain | Wallet, prepaid card, stored value |
| Protected Assets | Wallet balance, charge/use/refund/hold/adjustment records |
| Source Of Truth | `SOT_INTERNAL_LEDGER` or wallet-specific append-only value ledger |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Verified payment charge, authorized use request, refund candidate |
| Allowed Outbound | Masked balance status, support/reconciliation candidate |
| Prohibited Propagation | Silent balance overwrite, duplicate charge/use, AI adjustment |
| Containment Trigger | Duplicate charge, duplicate use, unauthorized adjustment |
| Quarantine Trigger | Balance mismatch, provider/payment link mismatch |
| Audit Requirement | Always required for value changes |
| Evidence Requirement | Required for mismatch/refund/adjustment |
| Alert Requirement | Wallet alert family |
| pgvector Eligibility | Value mismatch summaries only |
| AI Access Boundary | May summarize, cannot adjust balance |
| Release Authority | Finance/support review |
| Readiness Blocker | `BLOCKER-BULKHEAD-WALLET-0001` |

---

## 13. Bulkhead: Coupon And Promotion

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_COUPON` |
| Domain | Coupon, promotion, benefit campaign |
| Protected Assets | Coupon issuance, reservation, use, cancellation, expiration, campaign rules |
| Source Of Truth | Internal coupon authority |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Campaign rule, eligible customer event, verified coupon use request |
| Allowed Outbound | Coupon status, customer-safe benefit message, support candidate |
| Prohibited Propagation | Duplicate use, partner coupon overwrite, campaign conflict silent apply |
| Containment Trigger | Duplicate use risk, rule mismatch, campaign conflict |
| Quarantine Trigger | Partner coupon sync mismatch, duplicate payload |
| Audit Requirement | Required for issue/use/cancel/adjustment where value-bearing |
| Evidence Requirement | Required for duplicate/dispute/customer recovery |
| Alert Requirement | Coupon alert family |
| pgvector Eligibility | Duplicate/conflict summaries only |
| AI Access Boundary | May summarize, cannot issue/reissue coupon |
| Release Authority | CRM/support review |
| Readiness Blocker | `BLOCKER-BULKHEAD-COUPON-0001` |

---

## 14. Bulkhead: Customer Identity And Consent

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_IDENTITY` |
| Domain | Customer identity, consent, account linking |
| Protected Assets | Customer identity links, consent records, duplicate account resolution |
| Source Of Truth | `SOT_INTERNAL_IDENTITY_CONSENT` |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Customer consent, verified identity claim, support review request |
| Allowed Outbound | Tokenized identity link status, support/privacy review status |
| Prohibited Propagation | Wrong account merge, partner identity overwrite, AI identity linking |
| Containment Trigger | Wrong account risk, consent missing, cross-customer mapping risk |
| Quarantine Trigger | Duplicate identity candidate, partner identity mismatch |
| Audit Requirement | Required for link/unlink/relink |
| Evidence Requirement | Required for consent and dispute |
| Alert Requirement | Identity/privacy alert family |
| pgvector Eligibility | Redacted conflict summaries only |
| AI Access Boundary | May summarize conflict, cannot link identity |
| Release Authority | Privacy/support/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-IDENTITY-0001` |

---

## 15. Bulkhead: KDS

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_KDS` |
| Domain | Kitchen execution and ticket state |
| Protected Assets | Kitchen ticket, station route, remake, delay, fulfillment state |
| Source Of Truth | `SOT_KDS_EXECUTION_ONLY` |
| Trust Level | `TRUST_INTERNAL_REVIEWED` |
| Allowed Inbound | Validated order-to-ticket request, kitchen status update, manual fallback evidence |
| Allowed Outbound | Ticket status, delay/remake evidence, support/store alert |
| Prohibited Propagation | KDS completion implying payment success, KDS remake implying refund approval |
| Containment Trigger | Duplicate ticket risk, payment/order mismatch, unavailable item accepted |
| Quarantine Trigger | Unmapped ticket, duplicate ticket payload, manual fallback without evidence |
| Audit Requirement | Required for fallback/remake/high-risk mismatch |
| Evidence Requirement | Required for manual/remake/customer recovery |
| Alert Requirement | KDS alert family |
| pgvector Eligibility | Mismatch/delay summaries only |
| AI Access Boundary | May summarize kitchen incident, cannot complete/void tickets |
| Release Authority | Store ops/support review |
| Readiness Blocker | `BLOCKER-BULKHEAD-KDS-0001` |

---

## 16. Bulkhead: Inventory And Sold-Out

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_INVENTORY` |
| Domain | Inventory, stock, sold-out, availability |
| Protected Assets | Stock state, sold-out state, availability projection, waste/disposal evidence |
| Source Of Truth | `SOT_INTERNAL_INVENTORY` |
| Trust Level | `TRUST_INTERNAL_REVIEWED` |
| Allowed Inbound | Stock update, receiving evidence, manual sold-out action, supplier evidence |
| Allowed Outbound | Availability status, sold-out projection candidate, support/store alert |
| Prohibited Propagation | External projection overwriting internal availability, AI stock adjustment |
| Containment Trigger | KDS order for unavailable item, projection availability mismatch |
| Quarantine Trigger | Supplier mismatch, stock mismatch, stale availability |
| Audit Requirement | Required for manual adjustment and waste/disposal evidence |
| Evidence Requirement | Required for supplier/QC/customer impact |
| Alert Requirement | Inventory/SCM alert family |
| pgvector Eligibility | Stock/projection mismatch summaries only |
| AI Access Boundary | May suggest pattern, cannot adjust stock |
| Release Authority | Store/inventory/QC review |
| Readiness Blocker | `BLOCKER-BULKHEAD-INVENTORY-0001` |

---

## 17. Bulkhead: Content And i18n

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_CONTENT_I18N` |
| Domain | Content registry, message keys, locale/audience surfaces |
| Protected Assets | Approved menu text, allergen text, alert messages, support messages, locale keys |
| Source Of Truth | `SOT_INTERNAL_CONTENT_REGISTRY` and `SOT_INTERNAL_I18N_REGISTRY` |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Approved content source, translation review, SOP source reference |
| Allowed Outbound | Message keys, content keys, projection candidates |
| Prohibited Propagation | Hardcoded runtime text, unapproved translation, AI-generated final customer text |
| Containment Trigger | Allergen mismatch, customer-visible untranslated text, hardcoded operational string |
| Quarantine Trigger | Missing key, unapproved translation, source trace missing |
| Audit Requirement | Required for publication/rollback/approved customer surfaces |
| Evidence Requirement | Required for allergen/customer impact |
| Alert Requirement | Content/i18n alert family |
| pgvector Eligibility | Approved content/SOP only |
| AI Access Boundary | May draft from approved sources, cannot approve final text |
| Release Authority | Content/localization/support review |
| Readiness Blocker | `BLOCKER-BULKHEAD-CONTENT-I18N-0001` |

---

## 18. Bulkhead: External Projection

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_PROJECTION` |
| Domain | QR/NFC/Google Maps/partner menu projection |
| Protected Assets | Public menu projection, price, availability, allergen, translation, payment capability display |
| Source Of Truth | `SOT_EXTERNAL_PROJECTION_NONE` |
| Trust Level | `TRUST_PROJECTION_ONLY` |
| Allowed Inbound | Approved registry content, approved locale content, provider capability evidence |
| Allowed Outbound | Public-safe projection payload, rollback status |
| Prohibited Propagation | Partner state overwriting internal source, unverified payment capability display |
| Containment Trigger | Allergen mismatch, price mismatch, unverified payment capability, identity sharing risk |
| Quarantine Trigger | Provider sync mismatch, stale projection, unapproved translation |
| Audit Requirement | Required for publish/rollback/high-risk projection |
| Evidence Requirement | Required for mismatch/customer impact |
| Alert Requirement | Projection alert family |
| pgvector Eligibility | Projection mismatch summaries only |
| AI Access Boundary | May draft projection content, cannot publish |
| Release Authority | Projection/content/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-PROJECTION-0001` |

---

## 19. Bulkhead: Support/Admin

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_SUPPORT_ADMIN` |
| Domain | Support/admin tooling and authority |
| Protected Assets | Support case, restricted data, refunds requests, evidence, override actions, exports |
| Source Of Truth | `SOT_SUPPORT_REVIEW_ONLY` |
| Trust Level | `TRUST_INTERNAL_REVIEWED` |
| Allowed Inbound | Case evidence, support action request, approved review workflow |
| Allowed Outbound | Support decision candidate, customer response candidate, escalation |
| Prohibited Propagation | Support note mutating ledger, unauthorized refund, unmasking without audit |
| Containment Trigger | Unauthorized mutation, export risk, unapproved AI draft sent |
| Quarantine Trigger | Evidence mismatch, refund without evidence, restricted export request |
| Audit Requirement | Required for restricted data, unmasking, override, export, refund-related actions |
| Evidence Requirement | Required for case closure/refund/customer recovery |
| Alert Requirement | Support/admin alert family |
| pgvector Eligibility | Approved support summaries only |
| AI Access Boundary | May draft support response, cannot send/resolve without approval |
| Release Authority | Support lead/security/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-SUPPORT-ADMIN-0001` |

---

## 20. Bulkhead: AI

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_AI` |
| Domain | AI retrieval, summarization, drafting, classification |
| Protected Assets | AI input sources, outputs, prompts, review decisions, customer-facing drafts |
| Source Of Truth | `SOT_AI_NONE` |
| Trust Level | `TRUST_AI_ASSIST_ONLY` |
| Allowed Inbound | Approved summaries, approved SOP/content, approved vector retrieval results |
| Allowed Outbound | Draft, summary, suggestion, classification candidate |
| Prohibited Propagation | AI final decision, AI mutation, AI provider capability confirmation, AI alert resolution |
| Containment Trigger | Authority overreach, restricted source request, unapproved customer output |
| Quarantine Trigger | Untraceable output, wrong-locale output, evidence summary misuse |
| Audit Requirement | Required when AI output influences support/admin/high-risk review |
| Evidence Requirement | AI summary is derived evidence only |
| Alert Requirement | AI governance alert family |
| pgvector Eligibility | AI may use approved vector outputs only |
| AI Access Boundary | Self-boundary: assistance only |
| Release Authority | AI governance/security/content review |
| Readiness Blocker | `BLOCKER-BULKHEAD-AI-0001` |

---

## 21. Bulkhead: pgvector

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_PGVECTOR` |
| Domain | Vector similarity memory and anomaly retrieval |
| Protected Assets | Vectorized summaries, source metadata, similarity search results |
| Source Of Truth | `SOT_PGVECTOR_NONE` |
| Trust Level | `TRUST_VECTOR_ASSIST_ONLY` |
| Allowed Inbound | Approved source summaries with traceability |
| Allowed Outbound | Similarity result, related incident candidates, retrieval context |
| Prohibited Propagation | Similarity as proof, vector result as authority, restricted data leakage |
| Containment Trigger | Restricted source vectorized, cross-tenant retrieval, vector output used as authority |
| Quarantine Trigger | Unapproved source, missing traceability, stale vector |
| Audit Requirement | Required when vector output used in high-risk review |
| Evidence Requirement | Vector output is derived support only |
| Alert Requirement | pgvector alert family |
| pgvector Eligibility | Self-managed with strict source catalog |
| AI Access Boundary | AI may consume only approved vector results |
| Release Authority | AI/security/data governance review |
| Readiness Blocker | `BLOCKER-BULKHEAD-PGVECTOR-0001` |

---

## 22. Bulkhead: Provider

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_PROVIDER` |
| Domain | External providers and partner systems |
| Protected Assets | Provider callbacks, capability claims, settlement reports, API contracts |
| Source Of Truth | `SOT_PROVIDER_EVIDENCE_REQUIRED` |
| Trust Level | `TRUST_PROVIDER_VERIFIED_REQUIRED` |
| Allowed Inbound | Signed callback, documented capability evidence, settlement report |
| Allowed Outbound | Provider request, status inquiry, support/provider escalation |
| Prohibited Propagation | Provider claim marked confirmed without evidence, unsigned callback mutation |
| Containment Trigger | Signature failure, API contract change, settlement evidence missing |
| Quarantine Trigger | Capability claim without evidence, unmapped callback, stale partner sync |
| Audit Requirement | Required for provider evidence acceptance/change |
| Evidence Requirement | Always required for capability confirmation |
| Alert Requirement | Provider alert family |
| pgvector Eligibility | Provider error summaries only |
| AI Access Boundary | May identify evidence missing, cannot confirm capability |
| Release Authority | Provider integration/security/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-PROVIDER-0001` |

---

## 23. Bulkhead: Tenant

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_TENANT` |
| Domain | SaaS tenant isolation |
| Protected Assets | Tenant data, tenant configuration, tenant customer/store/ledger/support records |
| Source Of Truth | Internal tenant authority |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Authenticated tenant-scoped actions |
| Allowed Outbound | Tenant-scoped responses only |
| Prohibited Propagation | Cross-tenant data access, vector retrieval, archive retrieval, support leakage |
| Containment Trigger | Cross-tenant access risk |
| Quarantine Trigger | Unmapped tenant context, ambiguous tenant identity |
| Audit Requirement | Required for cross-tenant risk and restricted admin access |
| Evidence Requirement | Required for security incident |
| Alert Requirement | Tenant boundary alert family |
| pgvector Eligibility | Tenant-scoped only |
| AI Access Boundary | Tenant-scoped approved sources only |
| Release Authority | Security/HQ review |
| Readiness Blocker | `BLOCKER-BULKHEAD-TENANT-0001` |

---

## 24. Bulkhead: Store

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_STORE` |
| Domain | Store boundary |
| Protected Assets | Store order, POS, KDS, inventory, membership events, support records |
| Source Of Truth | Internal store context authority |
| Trust Level | `TRUST_INTERNAL_REVIEWED` |
| Allowed Inbound | Store-scoped events |
| Allowed Outbound | Store-scoped operational projections |
| Prohibited Propagation | Cross-store event application, wrong-store POS/payment/KDS mapping |
| Containment Trigger | Cross-store event risk |
| Quarantine Trigger | Unmapped store context, duplicated store event |
| Audit Requirement | Required for cross-store or security events |
| Evidence Requirement | Required for support/reconciliation cases |
| Alert Requirement | Store boundary alert family |
| pgvector Eligibility | Store-scoped summaries only |
| AI Access Boundary | Store-scoped approved sources only |
| Release Authority | Security/support/store ops review |
| Readiness Blocker | `BLOCKER-BULKHEAD-STORE-0001` |

---

## 25. Bulkhead: Audit And Evidence

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_AUDIT_EVIDENCE` |
| Domain | Audit trail and evidence packets |
| Protected Assets | Audit events, evidence packets, incident records, archive manifests |
| Source Of Truth | Internal audit/evidence authority |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Structured event, reviewed evidence, derived AI summary with label |
| Allowed Outbound | Evidence references, audit history, review material |
| Prohibited Propagation | AI summary replacing original evidence, silent edit/delete |
| Containment Trigger | Audit write failure, evidence tamper risk |
| Quarantine Trigger | Evidence source unclear, integrity mismatch |
| Audit Requirement | Self-auditing for restricted/high-risk actions |
| Evidence Requirement | Required for authority and dispute |
| Alert Requirement | Audit/evidence alert family |
| pgvector Eligibility | Approved summaries only |
| AI Access Boundary | May summarize evidence, cannot replace original |
| Release Authority | Audit/security/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-AUDIT-EVIDENCE-0001` |

---

## 26. Bulkhead: Archive And Retention

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_ARCHIVE_RETENTION` |
| Domain | Log lifecycle, archive, legal hold, deletion/anonymization |
| Protected Assets | Archive objects, manifests, retention status, legal hold records |
| Source Of Truth | Internal archive manifest and retention policy |
| Trust Level | `TRUST_INTERNAL_REVIEWED` |
| Allowed Inbound | Verified migration job output, legal hold instruction, deletion review request |
| Allowed Outbound | Archive manifest, retrieval result, retention status |
| Prohibited Propagation | Archive restore mutating runtime truth, deletion during legal hold |
| Containment Trigger | Archive verification failure, cross-tenant archive access risk |
| Quarantine Trigger | Manifest missing, checksum mismatch, vector dependency conflict |
| Audit Requirement | Required for migration, retrieval, deletion, legal hold |
| Evidence Requirement | Required for archive verification and legal hold |
| Alert Requirement | Archive alert family |
| pgvector Eligibility | Archive summaries only, lifecycle-linked |
| AI Access Boundary | May summarize approved archive data, cannot restore/mutate |
| Release Authority | Data governance/security/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-ARCHIVE-RETENTION-0001` |

---

## 27. Bulkhead: Workforce HR

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_WORKFORCE_HR` |
| Domain | Workforce, attendance, role, eligibility, payroll-adjacent events |
| Protected Assets | Staff identity, attendance records, role permissions, eligibility evidence |
| Source Of Truth | Internal HR authority |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Staff action, manager review, verified device/app event |
| Allowed Outbound | HR status, support/HQ review candidate |
| Prohibited Propagation | Role mismatch granting access, payroll-adjacent silent correction |
| Containment Trigger | Role sync mismatch, unauthorized HR mutation, eligibility risk |
| Quarantine Trigger | Unmapped attendance, duplicate attendance, missing evidence |
| Audit Requirement | Required for role/eligibility/payroll-adjacent changes |
| Evidence Requirement | Required for manual correction and eligibility review |
| Alert Requirement | Workforce alert family |
| pgvector Eligibility | Redacted HR incident summaries only |
| AI Access Boundary | May summarize, cannot decide employment/legal status |
| Release Authority | HR/security/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-WORKFORCE-HR-0001` |

---

## 28. Bulkhead: Supplier SCM WMS

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_SUPPLIER_SCM_WMS` |
| Domain | Supplier, SCM, WMS, delivery, receiving, stock movement |
| Protected Assets | Purchase order, receiving evidence, stock record, quality evidence |
| Source Of Truth | Internal SCM/WMS authority with supplier evidence |
| Trust Level | `TRUST_INTERNAL_REVIEWED` |
| Allowed Inbound | Supplier acknowledgement, delivery evidence, receiving record |
| Allowed Outbound | SCM status, inventory update candidate, QC alert |
| Prohibited Propagation | Supplier claim overwriting inventory without receiving evidence |
| Containment Trigger | Quality issue, delivery mismatch, stock mismatch |
| Quarantine Trigger | Supplier report mismatch, WMS stock conflict |
| Audit Requirement | Required for receiving adjustment and QC issues |
| Evidence Requirement | Required for supplier/quality disputes |
| Alert Requirement | SCM/WMS alert family |
| pgvector Eligibility | Supplier/QC incident summaries only |
| AI Access Boundary | May summarize, cannot adjust stock or approve supplier claim |
| Release Authority | SCM/QC/store review |
| Readiness Blocker | `BLOCKER-BULKHEAD-SUPPLIER-SCM-WMS-0001` |

---

## 29. Bulkhead: Franchise OS

| Field | Value |
|---|---|
| Bulkhead ID | `BULKHEAD_FRANCHISE_OS` |
| Domain | Franchise OS policy, royalty, store metadata, operating group integration |
| Protected Assets | Store metadata, franchise policy, royalty rules, operating group/legal entity context |
| Source Of Truth | Internal franchise/HQ authority |
| Trust Level | `TRUST_INTERNAL_AUTHORITY` |
| Allowed Inbound | Reviewed franchise policy, store metadata sync, royalty rule update |
| Allowed Outbound | Store/franchise policy projection, support escalation, finance candidate |
| Prohibited Propagation | Policy version overwrite, royalty rule conflict, wrong legal entity context |
| Containment Trigger | Policy version mismatch, royalty rule conflict, legal entity mismatch |
| Quarantine Trigger | Store sync mismatch, operating group ambiguity |
| Audit Requirement | Required for policy/royalty/legal entity changes |
| Evidence Requirement | Required for disputes and finance impact |
| Alert Requirement | Franchise OS alert family |
| pgvector Eligibility | Policy conflict summaries only |
| AI Access Boundary | May summarize policy conflict, cannot set royalty/policy |
| Release Authority | Franchise/HQ/finance/legal review |
| Readiness Blocker | `BLOCKER-BULKHEAD-FRANCHISE-OS-0001` |

---

## 30. Cross-Bulkhead Prohibited Propagation Map

The following propagation paths are prohibited unless a later contract explicitly allows controlled transfer.

| From | To | Prohibited Propagation |
|---|---|---|
| POS | Payment | POS event directly finalizes payment |
| POS | Ledger | POS event creates ledger truth |
| Provider | Ledger | Unverified provider callback creates ledger entry |
| KDS | Payment | KDS completion implies payment success |
| Support | Ledger | Support note changes ledger |
| AI | Any value domain | AI mutates money/points/wallet/coupon |
| pgvector | Any authority domain | Similarity result treated as truth |
| Projection | Content registry | Partner projection overwrites internal content |
| Projection | Payment | Displayed payment capability confirms provider capability |
| Membership | Wallet | Membership error mutates wallet balance |
| Identity | Membership | Unreviewed identity link changes membership value |
| Archive | Runtime | Restored archive overwrites current runtime state |
| Store | Tenant | Store event crosses tenant boundary |
| Tenant | Tenant | Cross-tenant data leakage |
| Provider | Provider registry | Provider claim confirmed without evidence |

---

## 31. Allowed Controlled Propagation Map

Some cross-domain propagation is allowed only through controlled contracts.

| From | To | Allowed Condition |
|---|---|---|
| Payment | Ledger | Verified payment event and ledger contract |
| Ledger | Finance report | Read-only report projection |
| Membership | Support | Support-visible summary with masking |
| Coupon | Payment | Coupon application through idempotent contract |
| Wallet | Payment | Wallet use through value-bearing contract |
| KDS | Support | Delay/remake evidence |
| Inventory | Projection | Approved availability projection |
| Content/i18n | Projection | Approved localized content |
| Provider | Payment | Verified signed callback |
| Provider | Capability registry | Evidence-reviewed capability update |
| Archive | Review | Retrieval through audit/legal policy |
| pgvector | AI | Approved vector result with traceability |
| AI | Support | Draft only, approval required |

Allowed propagation must preserve audit, evidence, idempotency, and source-of-truth boundaries.

---

## 32. pgvector Eligibility Summary

| Bulkhead | pgvector Eligibility |
|---|---|
| POS | Metadata summary only |
| Payment | Provider/payment metadata summary only |
| Ledger | Reconciliation summaries only |
| Membership | Conflict summaries only |
| Wallet | Value mismatch summaries only |
| Coupon | Duplicate/conflict summaries only |
| Identity | Redacted conflict summaries only |
| KDS | Mismatch/delay summaries only |
| Inventory | Stock/projection mismatch summaries only |
| Content/i18n | Approved content/SOP only |
| Projection | Projection mismatch summaries only |
| Support/admin | Approved support summaries only |
| AI | Approved vector outputs only |
| pgvector | Source-approved only |
| Provider | Provider error summaries only |
| Tenant | Tenant-scoped only |
| Store | Store-scoped only |
| Audit/evidence | Approved summaries only |
| Archive/retention | Archive summaries only |
| Workforce/HR | Redacted summaries only |
| Supplier/SCM/WMS | Supplier/QC summaries only |
| Franchise OS | Policy conflict summaries only |

Raw sensitive data must not be vectorized.

---

## 33. AI Access Summary

AI may assist across domains only under these limits:

| AI May Do | AI Must Not Do |
|---|---|
| Summarize incidents | Decide final truth |
| Classify alert candidates | Resolve alerts |
| Suggest evidence gaps | Release containment |
| Suggest routing | Release quarantine |
| Draft support response | Send response without approval |
| Retrieve approved SOP/content | Invent provider capability |
| Compare similar patterns | Treat similarity as proof |
| Draft incident report | Mutate runtime state |
| Suggest reconciliation path | Execute correction |
| Explain risk to reviewer | Approve money/value/identity action |

This summary applies to every bulkhead.

---

## 34. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-BULKHEAD-CATALOG-0001` | Bulkhead catalog not reviewed |
| `BLOCKER-SOT-0001` | Source-of-truth map incomplete |
| `BLOCKER-TRUST-0001` | Trust boundary map incomplete |
| `BLOCKER-PROPAGATION-0001` | Prohibited propagation map incomplete |
| `BLOCKER-PGVECTOR-ELIGIBILITY-0001` | pgvector eligibility incomplete |
| `BLOCKER-AI-ACCESS-0001` | AI access summary incomplete |
| `BLOCKER-RELEASE-AUTHORITY-0001` | Release authority missing |
| `BLOCKER-AUDIT-EVIDENCE-0001` | Audit/evidence mapping incomplete |
| `BLOCKER-CONTAINMENT-TRIGGER-0001` | Containment triggers missing |
| `BLOCKER-QUARANTINE-TRIGGER-0001` | Quarantine triggers missing |

Open blockers prevent runtime integration coding.

---

## 35. Validation Checklist

Validation must confirm:

- every domain has a bulkhead id
- every bulkhead has protected assets
- every bulkhead has source of truth
- every bulkhead has trust level
- every bulkhead has allowed inbound/outbound
- every bulkhead has prohibited propagation
- every bulkhead has containment trigger
- every bulkhead has quarantine trigger
- every bulkhead has audit/evidence requirement
- every bulkhead has pgvector eligibility
- every bulkhead has AI boundary
- every bulkhead has release authority
- external systems are not trusted by default
- AI is assistance only
- pgvector is assistance only
- projection is not source of truth
- archive restore does not mutate runtime truth
- cross-tenant and cross-store propagation are blocked

---

## 36. Relationship To Previous Documents

This document implements Artifact Group A from:

- `09630 Financial-Grade Security Monitoring Foundation Catalog Execution Plan And Artifact Map`

It depends on:

- `09620 Financial-Grade Security Monitoring Catalog Work Order And Implementation Handoff Policy`
- `09610 Financial-Grade Security Monitoring Foundation Package Index And Runtime Entry Deferral Policy`
- `09570 Financial-Grade Security Foundation Control Catalog And Bulkhead Readiness Policy`
- `09560 Financial-Grade Foundation Security Bulkhead Alert Log And pgvector Observability Policy`

This document is Foundation-grade and catalog-only.

It does not authorize coding.

---

## 37. Final Rule

Every major runtime and integration domain must have a security bulkhead before implementation.

A bulkhead defines the protected assets, source of truth, trust level, allowed inbound/outbound flows, prohibited propagation, containment triggers, quarantine triggers, audit/evidence linkage, pgvector eligibility, AI access boundary, release authority, and readiness blockers.

The system must not allow a fault, compromise, stale state, duplicate event, provider mismatch, support mistake, AI output, pgvector similarity result, external projection, POS event, or archive restore to cross into another domain as silent authority.

Coding remains deferred until this bulkhead catalog is reviewed, validated, and attached to package-specific entry gates.
