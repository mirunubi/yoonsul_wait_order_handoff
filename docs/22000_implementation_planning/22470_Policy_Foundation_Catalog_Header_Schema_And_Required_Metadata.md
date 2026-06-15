# 22470_Policy_Foundation_Catalog_Header_Schema_And_Required_Metadata

## 1. Purpose

This document defines the required header schema and metadata discipline for foundation catalog artifacts.

The purpose is to ensure that every foundation catalog, registry, map, readiness inventory, handoff record, work order, guardrail file, and boundary test plan clearly declares its status, authority, dependencies, provider evidence state, and coding permission.

Foundation artifacts must not be ambiguous.

A future developer or AI agent must be able to open a file and immediately know:

- whether it is planning-only
- whether coding is allowed
- whether runtime authority exists
- what package it belongs to
- what documents it depends on
- what blockers remain
- whether provider evidence is required
- whether i18n/content registry rules apply
- whether security/audit/evidence review is required

This document does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, and a narrow work order.

---

## 2. Scope

This policy applies to foundation artifacts, including:

1. Catalog files
2. Registry files
3. Status value maps
4. i18n message key maps
5. Content registry maps
6. SOP traceability maps
7. Contract catalogs
8. Event family catalogs
9. Audit event catalogs
10. Evidence packet catalogs
11. Provider capability registries
12. Security visibility catalogs
13. Degraded state catalogs
14. AI source/output catalogs
15. External projection status catalogs
16. Readiness inventories
17. Blocker inventories
18. Entry decision records
19. Handoff records
20. Work orders
21. Implementation result records
22. Guardrail documents
23. Boundary test planning documents

This policy does not define runtime implementation files.

Runtime implementation remains deferred.

---

## 3. Core Principle

Every foundation artifact must declare its own boundary.

A file title is not enough.

A folder path is not enough.

A package id is not enough.

Each file must include a standard metadata header that states the artifact type, package id, planning status, coding status, runtime authority, dependencies, and review requirements.

Missing metadata means the artifact is not ready for implementation handoff.

---

## 4. Standard Header Requirement

Every foundation artifact should begin with the following header block:

| Field | Required Meaning |
|---|---|
| Document ID | Stable document/file identifier |
| Package ID | Related package identifier |
| Artifact Type | Catalog, registry, map, readiness, handoff, workorder, result, guardrail, test plan |
| Version | Artifact version |
| Planning Status | Planning/review status |
| Coding Status | Whether coding is allowed |
| Runtime Authority | Whether the artifact can mutate runtime state |
| Owner | Runtime or planning owner |
| Dependencies | Required prior catalogs/documents |
| Related Documents | Cross-reference to planning documents |
| Provider Evidence Status | Required if provider-related |
| i18n Requirement | Required if visible text is involved |
| Content Registry Requirement | Required if runtime content is involved |
| Audit Requirement | Required if authority/evidence is involved |
| Security Requirement | Required if data/secret/access is involved |
| Review Requirement | Required review before merge/use |
| Blocker Status | Open/deferred/resolved blockers |
| Last Updated | Date or version marker |

The header must appear before body content.

---

## 5. Recommended Markdown Header Format

Foundation markdown artifacts should use this format:

| Metadata Field | Value |
|---|---|
| Document ID | `22470` |
| Package ID | `foundation.example.catalog.v1` |
| Artifact Type | `POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `NONE` |
| Owner | `Architecture / Foundation Planning` |
| Dependencies | `22460 Foundation Catalog File Layout And Naming Convention Policy` |
| Related Documents | `22390`, `22400`, `22410`, `22420`, `22430`, `22440`, `22450`, `22460` |
| Provider Evidence Status | `NOT_APPLICABLE` |
| i18n Requirement | `APPLIES_IF_VISIBLE_TEXT` |
| Content Registry Requirement | `APPLIES_IF_RUNTIME_CONTENT` |
| Audit Requirement | `APPLIES_IF_AUTHORITY_OR_EVIDENCE` |
| Security Requirement | `APPLIES_IF_DATA_OR_ACCESS` |
| Review Requirement | `ARCHITECTURE_REVIEW_REQUIRED` |
| Blocker Status | `NO_CODING_PERMISSION` |

This format keeps the artifact readable in markdown and stable for future parser use.

---

## 6. Required Status Values

The following status values should be used consistently.

### Planning Status

| Value | Meaning |
|---|---|
| `DRAFT` | Initial draft |
| `FOUNDATION_CANDIDATE` | Candidate foundation artifact |
| `ENTRY_REVIEW_REQUIRED` | Requires entry review |
| `REVIEW_REQUIRED` | Requires architecture/security/i18n/content review |
| `BLOCKED` | Blocker prevents progress |
| `APPROVED_AS_PLANNING` | Approved as planning artifact only |
| `DEPRECATED` | Replaced or retired |

### Coding Status

| Value | Meaning |
|---|---|
| `CODING_DEFERRED` | Coding not allowed |
| `ENTRY_REVIEW_REQUIRED` | Coding decision review required |
| `CODING_ALLOWED` | Coding allowed only for explicit package scope |
| `CODING_BLOCKED` | Coding blocked |
| `RUNTIME_SCOPE_PROHIBITED` | Runtime implementation not allowed |

Default coding status:

`CODING_DEFERRED`

---

## 7. Runtime Authority Declaration

Every foundation artifact must declare runtime authority.

Allowed values:

| Value | Meaning |
|---|---|
| `NONE` | No runtime authority |
| `CATALOG_ONLY` | Catalog/reference only |
| `READINESS_TRACKING_ONLY` | Tracks readiness only |
| `HANDOFF_CONTROL_ONLY` | Controls future handoff only |
| `TEST_PLANNING_ONLY` | Plans tests only |
| `RUNTIME_AUTHORITY_DEFERRED` | Runtime authority explicitly deferred |
| `RUNTIME_AUTHORITY_PROHIBITED` | Runtime authority prohibited |

Foundation artifacts should normally use:

`Runtime Authority: NONE`

or:

`Runtime Authority: CATALOG_ONLY`

If runtime authority is claimed, the artifact must be removed from foundation-first scope and deferred to a later runtime implementation review.

---

## 8. Artifact Type Values

Artifact type must be explicit.

Recommended values:

| Artifact Type | Meaning |
|---|---|
| `POLICY` | Governance document |
| `CATALOG` | Controlled value list |
| `REGISTRY` | Registry of controlled entries |
| `MAP` | Mapping between concepts |
| `TEMPLATE` | Reusable required format |
| `INVENTORY` | Package/blocker/readiness list |
| `HANDOFF_RECORD` | Package-specific handoff |
| `WORK_ORDER` | Execution-level instruction |
| `RESULT_RECORD` | Implementation result record |
| `GUARDRAIL` | Rule/check boundary |
| `TEST_PLAN` | Test planning artifact |
| `CHECKLIST` | Review checklist |
| `DECISION_RECORD` | Entry/coding decision record |

Ambiguous artifact types are prohibited.

---

## 9. Provider Evidence Metadata

Any provider-related artifact must include provider evidence metadata.

Required fields:

| Field | Required Meaning |
|---|---|
| Provider | Provider or partner name |
| Capability Family | Payment, KDS, projection, translation, settlement, etc. |
| Capability Status | Capability status value |
| Evidence Source | Documentation, agreement, sandbox, production test, or missing |
| Evidence Date | Date/version of evidence |
| Evidence Owner | Reviewer/owner |
| Limitation | Known limitation |
| Review Status | Open, confirmed, limited, rejected |
| Next Review | Future review trigger |

Default capability status for external providers:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

This applies to Redtable-type modules, Alipay, WeChat Pay, overseas cards, global settlement, Google Maps-linked projection, NFC/QR capability, partner menu publishing, customer identity sharing, and refund responsibility.

---

## 10. i18n Metadata

Any artifact that touches visible text must include i18n metadata.

Required i18n metadata:

| Field | Required Meaning |
|---|---|
| Locale Scope | Which locales are involved |
| Audience Scope | Customer, staff, support, owner, partner, AI, etc. |
| Message Key Family | Required message key family |
| Fallback Rule | Locale fallback behavior |
| Translation Status | Required, draft, approved, blocked |
| Hardcoded Text Risk | Whether runtime text risk exists |
| Review Requirement | i18n/content review requirement |

Hardcoded operational strings remain prohibited.

---

## 11. Content Registry Metadata

Any artifact involving runtime content must include content registry metadata.

Required metadata:

| Field | Required Meaning |
|---|---|
| Content Family | Menu, support, SOP, training, AI response, projection, etc. |
| Content Key Family | Required content key family |
| Source Traceability | Source document/section/version requirement |
| Locale | Source/target locale |
| Audience | Target audience |
| Approval Status | Draft, review, approved, blocked |
| Effective Version | Version/effective date |
| Rollback Requirement | Required if publishable |
| Runtime Boundary | Where content may be used |

Markdown/SOP content may be a source, but runtime use must preserve traceability.

---

## 12. Audit Metadata

Any artifact involving authority, review, evidence, mutation, approval, or restricted visibility must include audit metadata.

Required audit metadata:

| Field | Required Meaning |
|---|---|
| Audit Family | Audit event family |
| Actor Class | Human/system/support/admin/provider |
| Authority Marker | Normal, backup, override, system |
| Target Object | Case, order, payment, ticket, content, provider, etc. |
| Evidence Link | Whether evidence is required |
| Reason Code | Required reason code family |
| Review Requirement | Whether later review is required |

Audit metadata does not implement audit triggers.

It defines future accountability requirements.

---

## 13. Evidence Metadata

Any artifact involving evidence must include evidence metadata.

Required evidence metadata:

| Field | Required Meaning |
|---|---|
| Evidence Family | Evidence packet class |
| Source Class | Customer, staff, system, provider, AI, admin |
| Integrity State | Original, derived, redacted, disputed, AI summarized |
| Runtime Domain | Payment, KDS, support, provider, menu, etc. |
| Masking Status | Masked, restricted, evidence-only |
| Review Status | Pending, accepted, rejected, needs review |
| Audit Link | Audit event relationship |

AI summaries must be marked as derived evidence.

They must not replace original evidence.

---

## 14. Security Metadata

Any artifact involving access, data, masking, provider credentials, export, or customer identity must include security metadata.

Required security metadata:

| Field | Required Meaning |
|---|---|
| Data Class | Public, masked, restricted, provider diagnostic, legal review, etc. |
| Visibility Class | Who may view |
| Masking Rule | Required masking rule |
| Secret Risk | Whether secret/credential risk exists |
| Export Risk | Whether export/report risk exists |
| Provider Data Sharing | Whether data leaves system |
| Review Requirement | Security/privacy review requirement |

Foundation artifacts must not include secrets.

Secret-like values in foundation files are prohibited.

---

## 15. AI Metadata

Any AI-related foundation artifact must include AI metadata.

Required AI metadata:

| Field | Required Meaning |
|---|---|
| AI Use Case | Retrieve, summarize, classify, draft, translate, suggest |
| Source Class | Allowed source classes |
| Blocked Source Class | Source classes AI must not access |
| Output State | Draft, suggestion, summary, blocked, approved reference |
| Human Review | Required or not |
| Traceability | Source trace requirement |
| Masking Rule | AI data visibility boundary |
| Customer-Facing Status | Blocked, draft, approved reference only |

AI remains assistance only.

AI must not approve, execute, mutate, reconcile, publish, or invent provider capability.

---

## 16. External Projection Metadata

Any external projection artifact must include projection metadata.

Required metadata:

| Field | Required Meaning |
|---|---|
| Projection Target | QR, NFC, Google Maps, partner, Redtable-type, etc. |
| Source Authority | Menu/content/i18n registry |
| Locale | Source and target locale |
| Translation Status | Required, draft, approved, blocked |
| Provider Capability Status | Evidence-required, confirmed, limited, rejected |
| Payment Capability Status | Evidence-required or confirmed |
| Publication Status | Draft, staged, published, stale, rolled back |
| Rollback Rule | Required rollback behavior |
| Customer Identity Mode | Anonymous, internal, partner, linked, blocked |
| Data Sharing Rule | What leaves internal system |

External projection remains projection only.

It must not become source of truth.

---

## 17. Blocker Metadata

Any readiness, handoff, work order, or result artifact must include blocker metadata.

Required blocker fields:

| Field | Required Meaning |
|---|---|
| Blocker ID | Stable blocker id |
| Blocker Family | i18n, content, provider, audit, evidence, security, AI, projection, etc. |
| Description | What is missing |
| Impact | What cannot proceed |
| Required Resolution | What must be prepared |
| Status | Open, under review, resolved, deferred, rejected |
| Coding Impact | Blocks coding, blocks release, blocks customer surface |

Blockers must not be hidden only in prose.

---

## 18. Header Validation Rule

A foundation artifact is not valid for handoff unless its required header fields are complete.

Invalid header conditions include:

- missing package id
- missing artifact type
- missing coding status
- missing runtime authority
- missing dependencies
- missing provider evidence status for provider-related files
- missing i18n metadata for visible text files
- missing content traceability for runtime content files
- missing audit metadata for authority-bearing files
- missing security metadata for data/access files
- missing blocker status for readiness/handoff/workorder files

Invalid artifacts must remain planning-only and blocked from coding.

---

## 19. Minimal Header Template

Use this minimal template for general foundation catalog files:

| Field | Value |
|---|---|
| Document ID | `TBD` |
| Package ID | `foundation.<domain>.<purpose>.v1` |
| Artifact Type | `CATALOG` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `NONE` |
| Owner | `Architecture / Foundation Planning` |
| Dependencies | `TBD` |
| Related Documents | `22390`, `22400`, `22410`, `22420`, `22430`, `22440`, `22450`, `22460`, `22470` |
| Review Requirement | `ARCHITECTURE_REVIEW_REQUIRED` |
| Blocker Status | `NO_CODING_PERMISSION` |

This template may be extended by domain-specific metadata sections.

---

## 20. Provider Header Extension

Use this extension for provider-related files:

| Field | Value |
|---|---|
| Provider | `TBD` |
| Capability Family | `TBD` |
| Provider Evidence Status | `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED` |
| Evidence Source | `MISSING` |
| Evidence Date | `TBD` |
| Evidence Owner | `TBD` |
| Provider Review Status | `OPEN` |

No provider-related file may default to confirmed capability.

---

## 21. i18n/Header Extension

Use this extension for i18n-related files:

| Field | Value |
|---|---|
| Locale Scope | `TBD` |
| Audience Scope | `TBD` |
| Message Key Family | `TBD` |
| Fallback Rule | `TBD` |
| Translation Status | `TRANSLATION_REQUIRED` |
| Hardcoded Text Risk | `MUST_BE_PREVENTED` |
| i18n Review Status | `OPEN` |

Visible runtime text must not bypass message/content keys.

---

## 22. Content Header Extension

Use this extension for content-related files:

| Field | Value |
|---|---|
| Content Family | `TBD` |
| Content Key Family | `TBD` |
| Source Traceability | `REQUIRED` |
| Locale | `TBD` |
| Audience | `TBD` |
| Approval Status | `REVIEW_REQUIRED` |
| Runtime Boundary | `TBD` |

Content without traceability is blocked from runtime use.

---

## 23. Handoff Header Extension

Use this extension for handoff records:

| Field | Value |
|---|---|
| Handoff ID | `HANDOFF-XXXX` |
| Decision ID | `ENTRY-XXXX` |
| Allowed Scope | `TBD` |
| Excluded Scope | `TBD` |
| Allowed Files | `TBD` |
| Prohibited Files | `TBD` |
| Required Tests | `TBD` |
| Review Requirement | `REQUIRED` |
| Coding Status | `CODING_DEFERRED` unless explicitly allowed |

No handoff record may omit allowed and prohibited file scope.

---

## 24. Work Order Header Extension

Use this extension for work orders:

| Field | Value |
|---|---|
| Work Order ID | `workorder.foundation.<purpose>.v1` |
| Handoff ID | `HANDOFF-XXXX` |
| Decision ID | `ENTRY-XXXX` |
| Task Goal | `TBD` |
| Non-Goals | `TBD` |
| Allowed Files | `TBD` |
| Prohibited Files | `TBD` |
| Acceptance Criteria | `TBD` |
| Required Tests | `TBD` |
| Coding Status | `CODING_DEFERRED` unless explicitly allowed |

A work order without non-goals is incomplete.

---

## 25. Result Header Extension

Use this extension for implementation result records:

| Field | Value |
|---|---|
| Result ID | `RESULT-XXXX` |
| Work Order ID | `TBD` |
| Handoff ID | `TBD` |
| Package ID | `TBD` |
| Files Changed | `TBD` |
| Tests Run | `TBD` |
| Scope Deviations | `NONE` or listed |
| Blockers Found | `NONE` or listed |
| Review Status | `PENDING` |
| Merge Status | `NOT_MERGED` |

No implementation result should be undocumented.

---

## 26. Prohibited Header Shortcuts

The following are prohibited:

1. Omitting coding status
2. Omitting runtime authority
3. Omitting package id
4. Omitting dependencies
5. Omitting provider evidence status in provider files
6. Omitting i18n metadata in visible text files
7. Omitting content traceability metadata in content files
8. Omitting audit metadata in authority/evidence files
9. Omitting security metadata in data/access files
10. Omitting blocker metadata in readiness files
11. Using vague status values such as `done`, `ok`, or `active`
12. Marking provider capability confirmed without evidence
13. Marking runtime authority in a foundation-only file
14. Marking coding allowed without decision, handoff, and work order
15. Treating file header as optional

---

## 27. Relationship To Previous Documents

This document follows:

- `22440 Controlled Foundation Implementation Handoff And Work Order Policy`
- `22450 Foundation Catalog Implementation Order And Dependency Policy`
- `22460 Foundation Catalog File Layout And Naming Convention Policy`

This document defines required metadata for foundation catalog and handoff artifacts.

It does not authorize coding.

---

## 28. Final Rule

Every foundation artifact must carry its own boundary in its header.

The header must make clear whether the artifact is planning-only, whether coding is allowed, whether runtime authority exists, what package it belongs to, what dependencies it has, what evidence is required, and what review is needed.

Missing metadata means the artifact is incomplete.

Coding remains deferred unless a package-specific `CODING_ALLOWED` decision, completed handoff record, narrow work order, allowed file scope, required tests, and review approval exist.
