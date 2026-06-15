# 10130_Policy_CMS_i18n_AI_pgvector_Data_Governance_Skeleton

## 1. Purpose

This document defines the CMS, i18n, AI, pgvector, and Data Governance Skeleton Policy.

The previous artifact `10120` defined the Payment, Settlement, Refund, Wallet, and Financial Trust Skeleton Policy as Side C of the four-side platform skeleton.

This document builds Side D:

`Data Intelligence And Governance Skeleton`

The purpose is to define the governance frame for customer-visible content, multilingual messaging, AI assistance, vector context retrieval, analytics, support visibility, data retention, policy mapping, and incident learning before runtime intelligence, CMS publication, AI execution, embedding generation, pgvector retrieval, or automated decision-making is implemented.

This document is planning-only.

It does not authorize coding.

---

## 2. Side D Definition

Side D represents the platform’s data, content, language, intelligence, and governance layer.

It includes:

- CMS governance
- i18n message key governance
- customer-visible text control
- staff-visible text control
- admin/support-visible text control
- AI advisory boundary
- pgvector context boundary
- analytics/read model boundary
- support/admin visibility
- policy registry
- compliance mapping
- data retention
- privacy and masking
- incident learning
- provider evidence knowledge base
- SOP/training content governance
- multilingual customer support readiness

Side D answers:

How does the platform use data and intelligence without turning content, AI, similarity, analytics, or admin visibility into unchecked authority?

---

## 3. Core Principle

Data and intelligence must assist governance, not replace authority.

The correct rule is:

CMS draft is not publication.
i18n key is not message approval.
AI summary is not decision.
pgvector similarity is not proof.
Analytics signal is not authority.
Support visibility is not mutation permission.
Policy reference is not runtime execution.
Incident learning is not automatic rule change.

Data may inform.

Authority must approve.

Evidence must support.

Audit must record.

---

## 4. CMS Governance Skeleton

CMS governance should control all platform-managed content that may become visible to customers, staff, stores, owners, support, HQ, or Franchise OS.

CMS content may include:

- Catch Menu banner
- Mini Kiosk notice
- Full Kiosk home screen
- campaign message
- emergency notice
- degraded operation notice
- allergen/ingredient notice
- sold-out notice
- payment unavailable notice
- POS/KDS degraded notice
- store policy notice
- franchise policy notice
- customer recovery message draft
- support response template
- SOP/training material
- staff notice

CMS content must not be published without approval.

CMS draft is not customer-visible truth.

---

## 5. CMS Content State Skeleton

Recommended CMS skeleton states:

| State | Meaning |
|---|---|
| `CMS_DRAFT` | Draft created |
| `CMS_REVIEW_REQUIRED` | Review required |
| `CMS_APPROVED` | Approved |
| `CMS_REJECTED` | Rejected |
| `CMS_PUBLICATION_CANDIDATE` | Candidate for publication |
| `CMS_PUBLISHED` | Published if runtime later authorized |
| `CMS_ROLLBACK_REQUIRED` | Rollback required |
| `CMS_RETIRED` | Retired |
| `CMS_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `CMS_SECURITY_REVIEW_REQUIRED` | Security review required |
| `CMS_I18N_REVIEW_REQUIRED` | Locale/message review required |

These are skeleton states only.

They do not authorize CMS runtime.

---

## 6. i18n Governance Skeleton

i18n governance must control all human-visible operational messages.

i18n applies to:

- customer app text
- Catch Menu text
- Mini Kiosk text
- Full Kiosk text
- payment-safe status text
- POS/KDS-safe status text
- degraded mode text
- staff assist text
- CMS content
- support response templates
- admin labels
- alert messages
- audit reason labels
- policy explanation text
- franchise/store notices
- allergen/ingredient notices

No customer-visible operational text should be hardcoded.

Message key governance is a platform foundation.

---

## 7. i18n Message Key State Skeleton

Recommended i18n key states:

| State | Meaning |
|---|---|
| `I18N_KEY_DRAFT` | Key drafted |
| `I18N_KEY_REVIEW_REQUIRED` | Review required |
| `I18N_KEY_APPROVED` | Approved |
| `I18N_KEY_DEPRECATED` | Deprecated |
| `I18N_TRANSLATION_PENDING` | Translation pending |
| `I18N_TRANSLATION_REVIEW_REQUIRED` | Translation review required |
| `I18N_TRANSLATION_APPROVED` | Translation approved |
| `I18N_FALLBACK_REQUIRED` | Fallback required |
| `I18N_LEGAL_REVIEW_REQUIRED` | Legal-sensitive review required |
| `I18N_RUNTIME_NOT_AUTHORIZED` | Runtime usage not authorized |

i18n approval does not automatically publish CMS content.

i18n key approval does not authorize feature execution.

---

## 8. Customer-Visible Message Safety Skeleton

Customer-visible messages must be safe, non-blaming, and evidence-aware.

Customer messages must not:

- expose raw provider errors
- blame POS provider without review
- blame payment provider without review
- expose internal incident details
- promise refund without authority
- promise compensation without authority
- confirm payment without verification
- confirm POS/KDS truth without evidence
- reveal security containment
- reveal staff/internal notes
- reveal AI reasoning
- reveal vector similarity
- reveal raw audit data

Customer messages should use approved i18n keys and Safe Projections.

---

## 9. Staff And Admin Message Safety Skeleton

Staff/admin messages may contain more operational context than customer messages, but must still respect boundaries.

Staff/admin messages must not:

- expose unnecessary personal data
- expose secrets
- expose raw payment payloads
- expose raw provider credentials
- expose unrestricted internal evidence
- present AI summary as final truth
- present vector match as proof
- allow mutation without authority
- hide uncertainty
- suppress audit requirement

Admin visibility must be scoped by role, context, and purpose.

---

## 10. AI Advisory Skeleton

AI may assist with:

- support case summary
- incident summary
- provider evidence summary
- CMS draft suggestion
- i18n draft suggestion
- SOP/training draft
- missing evidence checklist
- anomaly explanation
- customer-safe response draft
- degraded mode explanation draft
- policy lookup summary
- store performance summary

AI must not:

- approve refund
- approve compensation
- confirm payment
- confirm provider fault
- publish CMS
- send customer message
- mutate POS/KDS/store state
- release containment
- make legal conclusion
- make employment/payroll decision
- override policy
- suppress audit
- become source of truth

AI is advisory only.

---

## 11. AI Output State Skeleton

Recommended AI output states:

| State | Meaning |
|---|---|
| `AI_NOT_REQUESTED` | No AI output |
| `AI_DRAFT_CREATED` | AI draft created |
| `AI_REVIEW_REQUIRED` | Human review required |
| `AI_APPROVED_FOR_REFERENCE` | Approved as reference |
| `AI_REJECTED` | Rejected |
| `AI_ESCALATION_REQUIRED` | Escalation required |
| `AI_UNCERTAIN` | Uncertain output |
| `AI_SOURCE_INSUFFICIENT` | Missing source/evidence |
| `AI_RUNTIME_NOT_AUTHORIZED` | Runtime not authorized |

AI draft is not publication.

AI summary is not evidence.

---

## 12. pgvector Context Skeleton

pgvector may later support context retrieval and similarity search.

Potential use cases:

- similar support case lookup
- similar incident lookup
- policy reference lookup
- SOP reference lookup
- provider limitation lookup
- recovery pattern lookup
- CMS template lookup
- i18n phrase reference
- audit anomaly reference
- training content retrieval

pgvector must not:

- prove root cause
- approve compensation
- approve refund
- confirm provider capability
- confirm payment
- confirm legal liability
- replace reconciliation
- replace evidence packet
- expose restricted raw data
- become source of truth

Similarity is not proof.

---

## 13. Vector Source Governance Skeleton

Vector sources must be approved before ingestion.

Approved source candidates may include:

- reviewed policy documents
- approved SOP documents
- approved support templates
- approved incident summaries
- approved provider limitation notes
- approved CMS templates
- approved i18n phrase references
- approved training content

Restricted or prohibited sources may include:

- raw payment payloads
- raw provider credentials
- raw customer personal data
- unmasked support transcripts
- legal hold material unless explicitly allowed
- unresolved incident raw notes
- private staff data
- secrets
- production logs with sensitive fields

Vector ingestion requires separate authorization.

This document does not authorize ingestion.

---

## 14. Analytics And Read Model Skeleton

Analytics and read models may support visibility and planning.

Analytics may include:

- menu view rate
- order intent rate
- staff assist frequency
- POS handoff failure rate
- KDS delay pattern
- payment exception rate
- refund request frequency
- coupon/point usage trend
- device health trend
- CMS performance
- i18n missing key rate
- support case pattern
- incident recurrence
- store performance trend
- franchise-level exception overview

Analytics must not directly mutate runtime state.

Analytics signal is not authority.

---

## 15. Support/Admin Visibility Skeleton

Support/Admin visibility should provide enough information for review without exposing unnecessary sensitive data.

Support/Admin may see:

- masked customer context
- customer-safe status
- order reference
- payment-safe status
- provider evidence reference
- incident category
- staff note if authorized
- recovery case context
- CMS/i18n message key
- AI draft if enabled
- vector reference if enabled
- audit reference

Support/Admin must not see unrestricted raw payloads by default.

Visibility must be role-scoped and purpose-scoped.

---

## 16. Policy Registry Skeleton

Policy registry should define referenceable policy rules.

Policy registry may include:

- product surface policy
- runtime feature policy
- payment policy
- refund policy
- compensation policy
- CMS approval policy
- i18n approval policy
- provider evidence policy
- device profile policy
- degraded operation policy
- manual fallback policy
- data retention policy
- masking/privacy policy
- AI advisory policy
- vector source policy
- Franchise OS inheritance policy

Policy reference is not execution.

Policy must be enforced by approved runtime later.

---

## 17. Compliance Mapping Skeleton

Compliance mapping should identify sensitive areas.

Areas may include:

- financial data
- payment data
- personal data
- customer support data
- employee/staff data
- provider credential data
- security event data
- audit data
- legal hold data
- consumer protection data
- food safety/allergen data
- franchise contract data
- marketing consent data

Compliance mapping should guide masking, retention, access, and review.

It does not replace legal review.

---

## 18. Data Retention Skeleton

Data retention should classify:

| Data Class | Retention Consideration |
|---|---|
| Customer-visible message | content history and rollback |
| Support case | review and dispute period |
| Payment evidence | financial/legal retention |
| Provider evidence | capability traceability |
| Device event | security/operations retention |
| Audit event | governance retention |
| CMS draft | content governance |
| i18n key history | message traceability |
| AI draft | review traceability if stored |
| Vector source | source lineage |
| Incident record | learning and accountability |
| Manual fallback note | reconciliation and evidence |

Retention must be policy-bound.

Deletion must not destroy required evidence.

---

## 19. Privacy And Masking Skeleton

Privacy and masking must apply across Side D.

Masking should protect:

- customer identifiers
- payment references
- phone numbers
- email addresses
- personal notes
- staff identifiers where not required
- raw provider payloads
- operational secrets
- device identifiers if unnecessary
- legal-sensitive details

Masking does not mean deletion.

Masking controls visibility.

Audit may retain protected reference under policy.

---

## 20. Incident Learning Skeleton

Incident learning may use reviewed incidents to improve:

- SOP
- support scripts
- degraded mode messages
- provider limitation notes
- staff training
- device readiness checklist
- KDS delay handling
- POS retry policy
- payment exception handling
- CMS emergency notice template
- i18n message coverage
- future AI reference content

Incident learning must not silently rewrite runtime policy.

Reviewed learning may propose updates.

Authority approves updates.

---

## 21. Provider Evidence Knowledge Base Skeleton

Provider evidence knowledge base may store:

- provider capability notes
- provider limitation notes
- callback behavior notes
- retry behavior notes
- idempotency behavior notes
- degraded mode notes
- support contact route
- certification/evidence reference
- test result summary
- rollout risk note
- known mismatch pattern

Provider knowledge base is evidence support.

It is not provider capability approval by itself.

---

## 22. SOP And Training Governance Skeleton

SOP/training content may include:

- staff assist SOP
- degraded operation SOP
- manual fallback SOP
- payment unavailable SOP
- POS/KDS mismatch SOP
- customer recovery SOP
- allergen notice SOP
- CMS publication SOP
- device replacement SOP
- incident escalation SOP
- support response SOP

SOP content must be versioned.

SOP publication must be reviewed.

SOP guidance must not override policy or authority.

---

## 23. Relationship To Side A

Side D governs product surface visibility.

Examples:

- Catch Menu uses i18n keys.
- Mini Kiosk uses Safe Projection messages.
- Full Kiosk uses CMS-approved notices.
- Admin Surface uses role-scoped projections.
- Franchise OS uses policy and governance context.

Side D shapes what surfaces may show.

Side D does not let surfaces bypass authority.

---

## 24. Relationship To Side B

Side D supports Store Runtime with:

- degraded mode messages
- staff assist scripts
- incident classification
- operational dashboards
- support context
- SOP references
- KDS/POS issue summaries
- provider limitation references
- manual fallback guidance

Side D must not mutate Store Runtime without approved authority.

---

## 25. Relationship To Side C

Side D supports Financial Trust with:

- payment-safe message keys
- refund review templates
- compensation review templates
- fraud/abuse pattern summaries
- financial exception dashboards
- masked support context
- policy references
- AI draft summaries if later approved
- vector policy lookup if later approved

Side D must not approve financial actions.

Financial evidence and authority remain in Side C.

---

## 26. Data Governance Anti-Patterns

Avoid:

- CMS draft treated as publication
- i18n key treated as legal approval
- AI summary treated as decision
- vector similarity treated as proof
- analytics signal treated as authority
- support visibility treated as mutation permission
- policy document treated as runtime enforcement
- incident learning silently changing live policy
- raw payment/provider payloads exposed to support
- hardcoded operational customer text
- customer message blaming provider without review
- AI-generated customer message auto-sent
- unapproved source ingested into vector index
- masking treated as deletion
- deletion destroying required evidence

These anti-patterns create governance, legal, financial, and operational risk.

---

## 27. Runtime Deferral

This document defines data governance skeleton only.

It does not authorize:

- CMS runtime
- CMS publication
- i18n runtime registry implementation
- AI model call
- AI prompt execution
- embedding generation
- pgvector ingestion
- pgvector retrieval
- analytics pipeline
- support/admin implementation
- policy engine implementation
- data retention engine
- masking engine
- training portal
- production deployment

All runtime remains deferred.

---

## 28. Recommended Next Documents

The next skeleton documents should be:

| Document | Purpose |
|---|---|
| `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy` | Connect all four sides |
| `10150 Four-Side Skeleton Closure And Runtime Deferral Policy` | Close skeleton sequence |

This document completes Side D at skeleton level.

---

## 29. Validation Checklist

Validation must confirm:

1. CMS governance is defined.
2. CMS content states are defined.
3. i18n governance is defined.
4. i18n key states are defined.
5. Customer-visible message safety is defined.
6. Staff/admin message safety is defined.
7. AI advisory boundary is defined.
8. AI output states are defined.
9. pgvector context boundary is defined.
10. Vector source governance is defined.
11. Analytics/read model boundary is defined.
12. Support/Admin visibility is defined.
13. Policy registry skeleton is defined.
14. Compliance mapping is defined.
15. Data retention skeleton is defined.
16. Privacy/masking skeleton is defined.
17. Incident learning skeleton is defined.
18. Provider evidence knowledge base is defined.
19. SOP/training governance is defined.
20. Relationship to Side A is defined.
21. Relationship to Side B is defined.
22. Relationship to Side C is defined.
23. Anti-patterns are listed.
24. Coding remains unauthorized.
25. Runtime remains deferred.

---

## 30. Relationship To Previous Documents

This document follows:

- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`

It references:

- `10100 Four-Side Platform Skeleton And Cross-Axis Construction Policy`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10047 Product Line Capability Matrix And Surface Reuse Registry Policy`
- `10052 Admin Surface Reuse Candidate And Franchise OS Future Handoff Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09990 AI pgvector Governance Catalog Static Package Handoff And Non Authority Boundary Policy`

It prepares:

- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`

This document is skeleton planning only.

It does not authorize coding.

---

## 31. Final Rule

Side D is now framed at skeleton level.

CMS governs content but does not publish without approval.

i18n governs message keys but does not authorize runtime action.

AI assists but does not decide.

pgvector retrieves context but does not prove.

Analytics informs but does not mutate.

Support/Admin visibility supports review but does not grant authority.

Policy references guide runtime but do not execute runtime by themselves.

All data intelligence and governance capabilities remain planning-only until a separate explicit authorization packet is approved.
