# 10550_Policy_pgvector_Context_Retrieval_And_Similarity_Boundary

## 1. Purpose

This document defines the pgvector Context Retrieval and Similarity Boundary Policy.

The previous artifact `10540` defined the AI Advisory Runtime and Non-Authority Boundary Policy.

This document frames the fifth Data Governance room:

`pgvector Context Retrieval And Similarity Room`

The purpose is to define the boundary where embeddings, vector sources, semantic retrieval, related-case search, SOP retrieval, provider evidence retrieval, anomaly similarity, AI context retrieval, and analytics support retrieval may be governed without becoming proof, authority, cross-tenant access, source truth, incident resolution, payment verification, refund approval, settlement correction, compensation approval, or AI execution authority.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The pgvector Context Retrieval and Similarity Room governs vectorized context and semantic retrieval.

It may later coordinate:

- vector source registration
- embedding generation eligibility
- embedding version
- source classification
- tenant/store scope
- masking status
- approved global source
- retrieval policy
- similarity threshold
- vector search result
- related-case candidate
- SOP retrieval candidate
- AI context candidate
- review requirement
- source traceability
- vector audit reference

pgvector retrieval is search support.

Similarity is not proof.

---

## 3. Core Principle

Similarity is not authority.

The correct rule is:

Embedding exists is not approved knowledge.  
Vector source exists is not safe retrieval.  
Similarity is not proof.  
Related case is not current case evidence.  
SOP retrieval is not execution authority.  
Provider evidence retrieval is not provider truth.  
AI context retrieval is not AI authority.  
Analytics similarity is not benchmark authority.  
Cross-tenant similarity is denied by default.  
Vector result must not bypass source permissions.  

pgvector must be scoped, classified, masked, source-linked, versioned, auditable, and review-required before use in decisions.

---

## 4. Scope

This room may define planning boundaries for:

- vector source eligibility
- embedding creation eligibility
- embedding versioning
- vector index scope
- tenant/store/customer/legal scope
- approved global knowledge
- SOP semantic retrieval
- incident related-case retrieval
- recovery related-case retrieval
- payment/refund/value related evidence retrieval
- provider evidence retrieval
- analytics context retrieval
- AI context retrieval
- similarity threshold
- retrieval projection
- retrieval audit
- deletion/retention interaction

This room does not implement pgvector runtime.

---

## 5. Vector Source Catalog

Recommended vector source catalog:

| Source Type | Meaning |
|---|---|
| `APPROVED_SOP` | Approved SOP or procedure |
| `APPROVED_POLICY` | Approved policy document |
| `CMS_APPROVED_CONTENT` | Approved CMS content |
| `I18N_APPROVED_MESSAGE` | Approved message text |
| `INCIDENT_SUMMARY_MASKED` | Masked incident summary |
| `RECOVERY_SUMMARY_MASKED` | Masked recovery summary |
| `SUPPORT_CASE_SUMMARY_MASKED` | Masked support case summary |
| `PAYMENT_EVIDENCE_SUMMARY_MASKED` | Masked payment evidence summary |
| `REFUND_EVIDENCE_SUMMARY_MASKED` | Masked refund evidence summary |
| `VALUE_LEDGER_SUMMARY_MASKED` | Masked coupon/point/wallet summary |
| `SETTLEMENT_SUMMARY_MASKED` | Masked settlement summary |
| `PROVIDER_EVIDENCE_SUMMARY_MASKED` | Masked provider evidence summary |
| `ANALYTICS_DEFINITION` | Metric/read model definition |
| `TRAINING_KNOWLEDGE_APPROVED` | Approved training/help material |

Raw restricted source is not eligible by default.

---

## 6. Prohibited Vector Source Catalog

The following must not be embedded by default:

| Prohibited Source | Rule |
|---|---|
| `RAW_PAYMENT_CREDENTIAL` | Never embed |
| `RAW_PROVIDER_PAYLOAD` | Must not embed unless summarized/masked and approved |
| `RAW_CUSTOMER_PII` | Must not embed unmasked |
| `RAW_STAFF_PRIVATE_NOTE` | Must not embed without authority |
| `SECRET_OR_TOKEN` | Never embed |
| `SECURITY_CONTAINMENT_DETAIL` | Must not embed by default |
| `LEGAL_RESTRICTED_RECORD` | Must not embed without legal approval |
| `UNRESOLVED_FINANCIAL_EVIDENCE` | Must not embed as truth |
| `DRAFT_POLICY_UNAPPROVED` | Must not embed as approved knowledge |
| `REJECTED_CMS_CONTENT` | Must not embed as approved content |
| `CROSS_TENANT_RAW_DATA` | Must not embed for shared retrieval |
| `UNCLASSIFIED_SOURCE` | Must fail closed |

Embedding unsafe source creates long-lived leakage risk.

---

## 7. Vector Record Boundary

A vector record should include:

| Field | Meaning |
|---|---|
| `vector_record_id` | Vector record reference |
| `source_object_id` | Source object reference |
| `source_type` | Source catalog type |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope if applicable |
| `brand_id` | Brand scope if applicable |
| `legal_entity_id` | Legal entity scope if applicable |
| `customer_account_scope` | Customer/account scope if applicable |
| `data_class` | Data classification |
| `masking_class` | Masking status |
| `approval_status` | Source approval status |
| `embedding_model_version` | Embedding version |
| `embedding_policy_version` | Policy version |
| `retention_class` | Retention class |
| `retrieval_permission` | Retrieval permission |
| `audit_reference` | Audit reference |

Vector record must never be scope-free.

---

## 8. Vector State Skeleton

Recommended vector states:

| State | Meaning |
|---|---|
| `VECTOR_NOT_CREATED` | Vector not created |
| `VECTOR_SOURCE_CANDIDATE` | Source candidate identified |
| `VECTOR_SOURCE_REVIEW_REQUIRED` | Source review required |
| `VECTOR_SOURCE_BLOCKED` | Source blocked |
| `VECTOR_MASKING_REQUIRED` | Masking required |
| `VECTOR_EMBEDDING_ALLOWED` | Embedding allowed |
| `VECTOR_EMBEDDED` | Vector created |
| `VECTOR_ACTIVE` | Available for retrieval |
| `VECTOR_RETRIEVAL_RESTRICTED` | Restricted retrieval |
| `VECTOR_STALE` | Source or embedding stale |
| `VECTOR_REEMBED_REQUIRED` | Re-embedding required |
| `VECTOR_REVOKED` | Retrieval revoked |
| `VECTOR_RETENTION_EXPIRED` | Retention expired |
| `VECTOR_CONTAINMENT_REQUIRED` | Containment required |
| `VECTOR_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 9. Tenant Store Scope Boundary

Every vector record and retrieval request must preserve scope.

Required scope may include:

- tenant id
- store id if store-scoped
- brand id if brand-scoped
- operating group id if applicable
- legal entity id if financial/legal context applies
- customer/account scope if customer-specific
- actor id
- actor role
- audience class
- source class
- masking class
- retrieval purpose
- audit reference

Cross-tenant retrieval is denied by default.

Default:

`CROSS_TENANT_ACCESS_DENIED`

pgvector must follow `10141`.

---

## 10. Approved Global Source Boundary

Some sources may be global across tenants.

Approved global sources may include:

- public SOP template
- general system policy
- common safety guidance
- common i18n key explanation
- common training guide
- non-tenant-specific documentation

Global source must be explicitly marked.

Tenant data must never become global by accident.

Global retrieval must not include tenant-specific examples unless masked, approved, and generalized.

---

## 11. Embedding Eligibility Boundary

Embedding may occur only when:

- source is classified
- source scope is known
- source is approved for vector use
- masking is complete
- retention policy is known
- retrieval permission is defined
- embedding version is recorded
- audit route exists
- no containment block exists

Embedding must fail closed if any requirement is missing.

---

## 12. Masking Before Embedding Boundary

Masking must occur before embedding when source includes sensitive content.

Masking may remove or summarize:

- customer name
- phone/email
- payment reference
- provider transaction id
- card/payment detail
- wallet/point/coupon identifiers
- staff private detail
- support private note
- legal/compliance detail
- security containment detail
- device secret
- cross-tenant identifiers

Embedding unmasked sensitive data is prohibited unless separately approved under restricted policy.

---

## 13. Retrieval Request Boundary

Retrieval request should define:

- actor
- role
- tenant/store scope
- source class allowed
- target task
- query purpose
- audience class
- data class allowed
- masking class required
- max result count
- similarity threshold
- review requirement
- audit requirement

A retrieval query must not search all vectors by default.

Scope-limited retrieval is mandatory.

---

## 14. Similarity Threshold Boundary

Similarity threshold must be policy-driven.

Threshold may vary by:

- SOP retrieval
- incident related-case search
- support case search
- payment evidence search
- refund evidence search
- provider evidence search
- analytics definition search
- AI context search

High similarity is not proof.

Low similarity may still be useful as weak hint.

Threshold result must be labeled as retrieval confidence, not truth confidence.

---

## 15. Retrieval Result Boundary

Retrieval result should include:

- source title/reference
- source type
- source scope
- masking status
- approval status
- similarity score/category
- freshness/staleness marker
- retention status
- review required marker
- not-proof marker where applicable
- audit reference

Retrieval result must not expose raw restricted source unless the audience is authorized.

---

## 16. Related Case Boundary

Related case retrieval may support review.

Related case result is not current-case evidence.

Related case must not:

- resolve incident
- approve refund
- approve compensation
- prove abuse
- prove provider fault
- prove staff fault
- prove customer fault
- create settlement correction
- replace source evidence

A reviewer may link a related case as supporting context only after review.

---

## 17. SOP Retrieval Boundary

SOP retrieval may help staff/admin find guidance.

SOP retrieval must:

- use approved SOP source
- show SOP version
- show scope/applicability
- show review status
- show not-execution-authority reminder if needed
- require human/operator action

SOP retrieval is not execution.

SOP retrieval does not mutate runtime state.

---

## 18. Provider Evidence Retrieval Boundary

Provider evidence retrieval may help locate related provider events or summaries.

Provider evidence retrieval must not:

- treat provider payload as verified truth
- expose raw payload without authority
- cross tenant/store boundary
- infer payment confirmation
- infer refund completion
- infer settlement match
- override reconciliation

Provider evidence remains limited trust until verified in the proper room.

---

## 19. Financial Evidence Retrieval Boundary

Financial evidence retrieval may support finance/admin review.

It must preserve:

- tenant/store/legal entity scope
- financial data class
- masking class
- role authority
- access audit
- evidence source reference
- review requirement

Similarity to a previous refund, payment, or settlement case is not financial proof.

Financial Trust remains source of truth.

---

## 20. Incident And Recovery Retrieval Boundary

Incident/recovery retrieval may support:

- similar incident search
- similar recovery route
- SOP suggestion
- evidence checklist suggestion
- escalation suggestion
- customer-safe draft support

It must not:

- resolve incident
- close recovery
- approve compensation
- assign blame
- suppress escalation
- create customer promise

Incident owner must review.

---

## 21. AI Context Retrieval Boundary

AI may use vector retrieval only through approved context boundary.

AI context retrieval must provide:

- source references
- scope
- masking status
- similarity label
- uncertainty marker
- review requirement

AI must not convert retrieved similarity into authority.

Retrieved context must not bypass AI input source boundary.

---

## 22. Analytics Context Retrieval Boundary

Analytics may use retrieval for:

- metric definitions
- similar dashboard notes
- prior analysis summaries
- anomaly explanation candidates
- benchmark policy references

Analytics retrieval must not become source truth.

Benchmark interpretation remains governed.

---

## 23. Staleness And Re-Embedding Boundary

Vector records may become stale when:

- source document changes
- source approval changes
- masking policy changes
- tenant/store scope changes
- retention expires
- embedding model changes
- content is deprecated
- incident/recovery is reopened
- financial evidence is amended
- CMS content is rolled back
- i18n message is replaced

Stale vectors must not be treated as current guidance.

Re-embedding must be versioned.

---

## 24. Retention And Deletion Boundary

Vector retention must follow source retention.

If source expires, is revoked, or is restricted:

- retrieval may be blocked
- vector may be revoked
- vector may require deletion under policy
- audit trace may remain if allowed
- derived summaries may require review
- AI context using prior vector may require containment

Vector retention must not outlive source policy without authorization.

---

## 25. Access Audit Boundary

Vector retrieval may require audit when:

- source is financial
- source is incident/recovery
- source is support/admin
- source is legal/compliance
- source is security-restricted
- source includes customer/account context
- retrieval supports AI output
- retrieval supports export
- retrieval crosses aggregation boundary

Access audit should record query purpose, actor, scope, source class, and result references.

---

## 26. Vector Containment Boundary

Vector containment is required when:

- unmasked sensitive data was embedded
- cross-tenant source was indexed incorrectly
- restricted source was retrieved by unauthorized actor
- stale vector caused unsafe guidance
- AI output used restricted vector source
- provider payload leaked into vector context
- legal/security data was embedded improperly
- source approval was revoked

Containment is not resolution.

Containment must trigger review and remediation.

---

## 27. Relationship To AI Advisory Room

AI Advisory Room may request vector context.

pgvector Room controls eligible sources and retrieval boundaries.

AI must not use unrestricted vector search.

AI output must cite retrieved sources and uncertainty.

Similarity is not AI authority.

---

## 28. Relationship To Safe Projection Room

Safe Projection Room controls how retrieval results are shown.

Vector results must be projected with:

- source classification
- masking status
- similarity label
- review requirement
- not-proof marker where needed

Vector retrieval must not expose raw restricted source.

---

## 29. Relationship To i18n Room

pgvector may retrieve approved message examples or translation references.

It must not:

- treat similar translation as approved translation
- retrieve draft translation as approved text
- cross tenant/brand custom message scope
- bypass i18n review

i18n Room owns message approval.

---

## 30. Relationship To CMS Room

pgvector may retrieve approved CMS examples or prior notices.

It must not:

- retrieve draft/rejected CMS as approved content
- treat similar CMS as approved publication
- bypass CMS approval
- bypass targeting rules
- leak tenant/store content

CMS Room owns publication authority.

---

## 31. Relationship To Financial Trust

pgvector may assist financial review with masked, approved summaries.

It must not:

- confirm payment
- approve refund
- issue value
- mutate wallet
- approve compensation
- decide settlement
- amend reconciliation
- approve payout
- verify provider truth

Financial Trust remains source of truth.

---

## 32. Relationship To Store Runtime

pgvector may assist operational review or SOP retrieval.

It must not:

- create POS handoff
- create KDS ticket
- complete kitchen task
- close incident
- trigger manual fallback mutation
- authorize degraded operation
- override operator decision

Store Runtime remains execution boundary.

---

## 33. pgvector Anti-Patterns

Avoid:

- embedding raw payment/provider payload
- embedding unmasked customer PII
- embedding secret or token
- embedding draft policy as approved guidance
- embedding rejected CMS as approved content
- cross-tenant vector search by default
- vector result treated as proof
- related case treated as current evidence
- high similarity treated as authority
- SOP retrieval treated as execution
- AI using vector context without source references
- stale vector treated as current
- vector retention outliving source policy
- vector access without audit where required
- vector source missing tenant/store scope

These anti-patterns must be blocked in future runtime design.

---

## 34. Runtime Deferral

This document defines the pgvector Context Retrieval and Similarity Room boundary only.

It does not authorize:

- pgvector schema
- embedding generation
- vector indexing
- vector retrieval API
- semantic search runtime
- AI context retrieval runtime
- related-case search runtime
- analytics retrieval runtime
- masking engine
- retention engine
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 35. Validation Checklist

Validation must confirm:

1. pgvector Room definition is clear.
2. Similarity is separated from proof.
3. Vector source catalog is defined.
4. Prohibited vector source catalog is defined.
5. Vector record boundary is defined.
6. Vector state skeleton is defined.
7. Tenant/store scope boundary is defined.
8. Approved global source boundary is defined.
9. Embedding eligibility boundary is defined.
10. Masking-before-embedding boundary is defined.
11. Retrieval request boundary is defined.
12. Similarity threshold boundary is defined.
13. Retrieval result boundary is defined.
14. Related case boundary is defined.
15. SOP retrieval boundary is defined.
16. Provider evidence retrieval boundary is defined.
17. Financial evidence retrieval boundary is defined.
18. Incident/recovery retrieval boundary is defined.
19. AI context retrieval boundary is defined.
20. Analytics context retrieval boundary is defined.
21. Staleness/re-embedding boundary is defined.
22. Retention/deletion boundary is defined.
23. Access audit boundary is defined.
24. Vector containment boundary is defined.
25. Relationships to Data Governance rooms are defined.
26. Relationships to Financial Trust and Store Runtime are defined.
27. Anti-patterns are listed.
28. Coding remains unauthorized.
29. Runtime remains deferred.

---

## 36. Relationship To Previous Documents

This document follows:

- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10480 Financial Trust Closure And Data Governance Handoff Policy`
- `10500 Data Governance Room Framing And Intelligence Boundary Index`
- `10510 CMS Content Publication And Targeting Boundary Policy`
- `10520 i18n Message Key And Human Visible Text Boundary Policy`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`

It prepares:

- `10560 Analytics Read Model And Benchmark Boundary Policy`
- `10570 Retention Export And Compliance Data Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 37. Final Rule

The pgvector Context Retrieval and Similarity Room governs vectorized context and semantic retrieval.

Embedding exists is not approved knowledge.

Vector source exists is not safe retrieval.

Similarity is not proof.

Related case is not current case evidence.

SOP retrieval is not execution authority.

Provider evidence retrieval is not provider truth.

AI context retrieval is not AI authority.

Analytics similarity is not benchmark authority.

Cross-tenant similarity is denied by default.

Vector result must not bypass source permissions.

pgvector must preserve tenant/store/legal/customer scope, approved source classification, masking before embedding, retrieval permission, embedding versioning, source traceability, staleness handling, retention alignment, access audit, containment, AI non-authority, Safe Projection, Financial Trust separation, Store Runtime separation, and runtime deferral.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.