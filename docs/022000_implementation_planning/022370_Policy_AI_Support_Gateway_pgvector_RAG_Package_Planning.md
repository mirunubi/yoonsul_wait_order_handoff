# 022370_Policy_AI_Support_Gateway_pgvector_RAG_Package_Planning

## 1. Purpose

This document defines the planning boundary for the AI Support Gateway, pgvector-based retrieval, RAG content governance, SOP-aware knowledge retrieval, and AI-assisted support workflows before controlled implementation begins.

The purpose is to prevent AI support from becoming an unauthorized decision engine, hidden mutation channel, untraceable answer generator, provider capability inventor, untranslated customer response surface, or evidence substitute.

The AI Support Gateway may assist support, staff, customer service, admin review, menu explanation, training, and foreign-language guidance only when source traceability, runtime boundary, locale, audience, content registry linkage, and audit rules are explicitly planned.

No AI Support Gateway, pgvector, embedding, retrieval, prompt, tool call, support response, or RAG implementation may proceed to coding unless its planning boundary is approved.

---

## 2. Scope

This policy applies to the following package families:

1. AI Support Gateway
2. pgvector document retrieval
3. SOP-aware RAG
4. Menu-aware RAG
5. Content registry retrieval
6. Support knowledge retrieval
7. AI customer service response assistance
8. Staff guidance assistance
9. Admin evidence summarization
10. Support case classification
11. Provider issue explanation assistance
12. External menu projection explanation
13. Translation-aware response generation
14. AI-safe fallback instruction
15. AI retrieval audit and traceability
16. AI response approval workflow

This document does not implement any embedding model, vector table, pgvector index, prompt, retrieval function, Edge Function, API route, UI component, chatbot, or support automation.

Coding remains deferred.

---

## 3. Core Principle

AI may retrieve, summarize, classify, draft, and recommend.

AI must not silently decide, approve, execute, mutate, override, refund, reconcile, publish, or invent.

AI support is a controlled assistance layer.

It is not runtime authority.

It is not payment authority.

It is not KDS authority.

It is not provider evidence.

It is not legal conclusion.

It is not the menu source of truth.

It is not a replacement for content registry approval.

---

## 4. AI Gateway Planning Rule

Every AI Support Gateway package must define:

| Field | Required Meaning |
|---|---|
| Package name | Stable planning identifier |
| AI use case | Retrieve, summarize, classify, draft, translate, recommend |
| Runtime domain | Support, menu, SOP, payment, KDS, provider, training, etc. |
| Allowed audience | Customer, staff, support, owner, HQ, partner |
| Source family | SOP, content registry, menu registry, audit/evidence, provider evidence |
| Retrieval boundary | What may be retrieved |
| Response boundary | What may be generated |
| Authority level | Read, suggest, draft, blocked |
| Mutation rule | Must be no mutation unless later explicitly approved |
| Locale rule | Source locale, output locale, fallback locale |
| Traceability rule | Source references required |
| i18n rule | Message/content key linkage required |
| Audit rule | Required if used in support/admin action |
| Escalation rule | When AI must defer to human/operator |
| Coding status | Planned only / blocked / ready later |

---

## 5. Allowed AI Functions

The AI Support Gateway may perform the following functions when properly scoped:

- retrieve SOP-aware content
- retrieve menu/content registry entries
- retrieve support knowledge
- retrieve provider evidence status
- summarize evidence packet content
- classify support case family
- identify missing evidence
- suggest escalation path
- draft customer response
- draft staff guidance
- draft support/admin internal note
- translate approved content where permitted
- explain menu items using approved menu content
- explain fallback instructions using approved SOP/content keys
- identify provider capability uncertainty
- identify when human approval is required

These functions remain assistance functions only.

---

## 6. Prohibited AI Functions

The AI Support Gateway must not:

1. approve refunds
2. execute refunds
3. cancel payments
4. finalize settlement
5. mutate order state
6. mutate KDS state
7. close support cases automatically
8. approve customer compensation
9. publish external menu projection
10. approve provider capability
11. invent provider API support
12. override staff, owner, or HQ decisions
13. expose restricted data
14. bypass masking
15. bypass audit
16. bypass tenant/store boundary
17. generate customer-facing operational messages without approved content boundary
18. treat SOP text as executable authority
19. treat AI summary as original evidence
20. provide legal or financial final conclusions

AI output must remain clearly bounded as suggestion, draft, summary, classification, or retrieval result unless a later contract explicitly permits otherwise.

---

## 7. pgvector Retrieval Boundary

pgvector-based retrieval must be treated as a controlled knowledge access layer.

Vector retrieval must preserve:

- source document id
- source section id
- content registry key
- SOP traceability
- locale
- audience
- runtime boundary
- tenant/store applicability
- effective date
- version
- approval status
- embedding version
- retrieval timestamp
- retrieval reason
- calling package
- actor or system actor

Vector similarity alone must not create authority.

High similarity does not mean content is currently approved.

---

## 8. Embedding Source Classification

Every embedded source must be classified.

Recommended source classes:

- `SOP_DOCUMENT`
- `MENU_REGISTRY_CONTENT`
- `CONTENT_REGISTRY_ENTRY`
- `TRAINING_CONTENT`
- `SUPPORT_KNOWLEDGE`
- `FAQ_CONTENT`
- `PROVIDER_EVIDENCE`
- `AUDIT_SUMMARY`
- `EVIDENCE_PACKET_SUMMARY`
- `ERROR_MESSAGE_CATALOG`
- `I18N_MESSAGE_CATALOG`
- `EXTERNAL_PROJECTION_CONTENT`
- `POLICY_DOCUMENT`
- `LEGAL_REVIEWED_CONTENT`

Unclassified documents must not be embedded into the runtime retrieval index.

---

## 9. Source Traceability Rule

Every AI answer must be traceable back to approved or permitted sources.

Traceability must include:

- source id
- source type
- section id
- version
- locale
- audience
- approval status
- retrieval score
- retrieval timestamp
- runtime boundary
- content registry key if applicable
- SOP parser lineage if applicable

AI-generated text without traceability must not become operational output.

---

## 10. SOP-Aware RAG Boundary

SOP-aware RAG must preserve operational meaning.

SOP retrieval must not flatten SOP content into generic text.

SOP-derived retrieval must preserve:

- SOP document id
- SOP section id
- source traceability
- locale
- audience
- runtime boundary
- authority boundary
- actionability level
- evidence requirement
- fallback condition
- i18n/content key linkage

SOP content may guide support, staff training, and AI responses only when the runtime boundary permits it.

SOP content must not automatically become executable authority.

---

## 11. Menu-Aware RAG Boundary

Menu-aware RAG must retrieve from approved menu/content registry sources.

Menu explanation must preserve:

- menu item id
- content registry key
- locale
- translation source
- allergen source
- ingredient source
- price source if displayed
- availability source if displayed
- image source if displayed
- effective version
- audience
- external projection target if applicable

AI must not invent menu ingredients, allergens, prices, availability, nutrition claims, health claims, or cultural explanations.

If source content is missing, AI must return a controlled missing-content state.

---

## 12. Content Registry Dependency

AI customer service, staff guidance, training, support, and external menu explanation must depend on the content registry where operational text is involved.

The AI gateway may reference:

- i18n message keys
- content registry keys
- SOP content keys
- menu registry keys
- provider evidence labels
- approved response templates

The AI gateway must not bypass the content registry with free-form operational text.

---

## 13. Locale And Translation Boundary

AI output must preserve locale rules.

Planning must define:

- source locale
- requested output locale
- fallback locale
- translation source
- machine translation permission
- human-approved translation requirement
- mixed-language prohibition
- audience-specific tone boundary
- provider-supported locale status

AI translation may be allowed only when the content class permits it.

Payment, refund, legal, allergen, safety, and provider capability text may require approved translations before customer display.

---

## 14. Audience Boundary

AI output must be audience-specific.

Audience classes include:

- customer
- foreign customer
- staff
- kitchen/KDS staff
- store owner
- HQ admin
- support operator
- AI internal planning
- provider/partner
- legal/compliance reviewer

The same retrieved fact may require different wording, visibility, detail level, and authority boundary per audience.

AI must not expose internal diagnostics to customers.

AI must not expose customer private data to unauthorized staff or partners.

---

## 15. Evidence Summarization Boundary

AI may summarize evidence packets only as derived content.

AI evidence summaries must preserve:

- original evidence references
- summary timestamp
- actor/system actor
- model/tool version if later available
- confidence or uncertainty marker if used
- omitted content warning if applicable
- masking status
- source integrity status
- review requirement

AI summaries must never replace original evidence.

Support/admin decisions must reference original evidence, not only AI summary.

---

## 16. Support Case Classification Boundary

AI may classify support cases into controlled families.

Candidate classification families include:

- `ORDER_ISSUE`
- `PAYMENT_ISSUE`
- `REFUND_REQUEST`
- `KDS_DELAY`
- `MENU_CONTENT_ISSUE`
- `ALLERGEN_OR_SAFETY_ISSUE`
- `PROVIDER_CALLBACK_ISSUE`
- `EXTERNAL_PROJECTION_ISSUE`
- `TRANSLATION_ISSUE`
- `CUSTOMER_RECOVERY_REQUEST`
- `STAFF_MANUAL_FALLBACK`
- `LEGAL_OR_COMPLIANCE_REVIEW_REQUIRED`
- `UNKNOWN_REVIEW_REQUIRED`

Classification must not close the case.

Classification may route review or request missing evidence.

---

## 17. AI Draft Response Boundary

AI may draft responses only within approved boundaries.

A draft response must identify:

- target audience
- locale
- source content keys
- SOP references
- evidence references
- confidence/uncertainty if applicable
- whether human review is required
- whether message is customer-visible
- whether legal/payment/provider approval is required

AI-drafted responses must not be sent automatically unless a later explicit contract allows it.

Default status:

`HUMAN_REVIEW_REQUIRED`

---

## 18. AI Customer-Facing Boundary

Customer-facing AI responses require strict control.

AI may answer customers only from:

- approved content registry entries
- approved menu registry content
- approved FAQ/support content
- approved i18n message keys
- approved SOP-derived customer guidance
- confirmed provider capability labels

AI must not answer from:

- internal admin notes
- raw provider diagnostics
- unapproved SOP drafts
- unverified external provider claims
- unmasked evidence
- legal/compliance-only content
- payment/refund internal review notes

If approved content is unavailable, AI must use a controlled fallback message key.

---

## 19. Provider Capability Boundary

AI must not invent provider capability.

For provider-related questions, AI must check capability status.

Provider capability states include:

- `CAPABILITY_NOT_PLANNED`
- `CAPABILITY_PLANNED`
- `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`
- `CAPABILITY_CONFIRMED`
- `CAPABILITY_LIMITED`
- `CAPABILITY_REJECTED`
- `CAPABILITY_DEPRECATED`

If provider evidence is missing, AI must say the capability requires provider evidence.

Redtable-type partner capabilities remain evidence-required until verified.

---

## 20. Redtable-Type Partner AI Boundary

AI may assist with Redtable-type partner planning only as a candidate support layer.

AI may help explain or draft planning for:

- foreigner menu translation
- external menu projection
- Google Maps-linked discovery
- NFC/QR entry
- tourism-friendly ordering
- global payment candidate flow
- partner-side content projection

AI must not claim that the following are available without evidence:

- actual Redtable API
- Alipay support
- WeChat Pay support
- overseas card support
- global settlement
- refund responsibility
- translation responsibility
- data retention terms
- Google Maps integration method
- NFC/QR provider method
- partner commission terms
- legal/compliance readiness

Default state:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 21. AI Retrieval Audit Boundary

AI retrieval may require audit depending on context.

Audit is required when AI retrieval involves:

- support case evidence
- customer data
- payment/refund data
- provider issue data
- restricted SOP content
- legal/compliance content
- admin-only content
- masked or unmasked data
- response generation for customer-facing use
- escalation recommendation
- refund/recovery recommendation

AI retrieval audit must identify:

- actor/system actor
- query purpose
- source classes accessed
- tenant/store context
- case id if any
- retrieved document ids
- output type
- customer-visible status
- review requirement

---

## 22. Data Visibility And Masking Boundary

AI must respect the same data visibility rules as support/admin surfaces.

AI retrieval must not bypass:

- customer masking
- staff masking
- payment masking
- provider diagnostic restriction
- evidence-only visibility
- legal review restriction
- tenant/store separation
- role separation

If AI receives masked data, it must not infer or reconstruct hidden data.

If data is restricted, AI retrieval must be blocked or escalated.

---

## 23. Prompt And Tool Boundary

Prompts and tools must be treated as controlled runtime assets.

Planning must define:

- prompt purpose
- allowed source classes
- blocked source classes
- allowed output type
- blocked output type
- locale behavior
- audience behavior
- safety boundary
- authority boundary
- audit requirement
- version
- approval status

Prompts must not contain secrets, provider credentials, private keys, raw customer data examples, or production-only sensitive data.

---

## 24. AI Output State Classification

AI outputs must be classified before use.

Recommended output states:

- `AI_RETRIEVAL_RESULT`
- `AI_SUMMARY_DRAFT`
- `AI_CLASSIFICATION_SUGGESTION`
- `AI_RESPONSE_DRAFT`
- `AI_TRANSLATION_DRAFT`
- `AI_ESCALATION_SUGGESTION`
- `AI_MISSING_EVIDENCE_NOTICE`
- `AI_PROVIDER_EVIDENCE_REQUIRED_NOTICE`
- `AI_BLOCKED_RESTRICTED_CONTENT`
- `AI_HUMAN_REVIEW_REQUIRED`
- `AI_APPROVED_RESPONSE_REFERENCE`

Only approved response references may be treated as customer-ready.

---

## 25. pgvector Index Planning Boundary

pgvector index planning must not begin as blind embedding.

Planning must define:

- indexed source class
- source approval requirement
- chunking strategy
- locale strategy
- audience strategy
- runtime boundary tags
- tenant/store applicability
- versioning rule
- re-embedding rule
- deletion/retirement rule
- stale content handling
- retrieval filter rule
- audit rule
- privacy boundary

Vector index design must prevent wrong-locale, wrong-audience, stale, unapproved, or cross-tenant retrieval.

---

## 26. Staleness And Versioning Rule

AI retrieval must handle stale content explicitly.

Planning must define:

- content effective date
- content expiration date if any
- document version
- embedding version
- registry version
- approval status
- superseded status
- retrieval freshness rule
- fallback behavior when current content is missing

Stale content must not be presented as current operational truth.

---

## 27. AI Failure And Degraded Boundary

AI support may be unavailable or uncertain.

Degraded states include:

- retrieval unavailable
- vector index stale
- content registry unavailable
- locale unavailable
- source trace missing
- confidence insufficient
- provider evidence missing
- restricted content blocked
- human review required
- AI service unavailable
- prompt version not approved

AI degraded states must be visible to support/admin surfaces where relevant.

AI failure must not block core store operation unless the business flow explicitly depends on AI assistance.

---

## 28. AI Package Naming Rule

AI package planning identifiers should follow:

`ai.<domain>.<purpose>.<version>`

Examples:

- `ai.support.retrieve_context.v1`
- `ai.support.case_classify.v1`
- `ai.support.evidence_summarize.v1`
- `ai.support.response_draft.v1`
- `ai.menu.explain_customer.v1`
- `ai.sop.staff_guidance.v1`
- `ai.provider.capability_notice.v1`
- `ai.external_projection.translation_review.v1`
- `ai.pgvector.index_sop_content.v1`
- `ai.pgvector.retrieve_content_registry.v1`

These identifiers are planning names only.

They do not imply implementation exists.

---

## 29. AI Readiness Levels

Each AI Support Gateway package must have a readiness status.

| Status | Meaning |
|---|---|
| `AI_IDEA` | Candidate only |
| `AI_PLANNED` | Boundary described |
| `AI_SOURCE_REQUIRED` | Approved source content missing |
| `AI_TRACEABILITY_REQUIRED` | Source traceability incomplete |
| `AI_I18N_REQUIRED` | Message/content keys missing |
| `AI_VECTOR_INDEX_REQUIRED` | Index planning incomplete |
| `AI_AUDIT_REQUIRED` | Retrieval/output audit incomplete |
| `AI_MASKING_REQUIRED` | Data visibility boundary incomplete |
| `AI_PROVIDER_EVIDENCE_REQUIRED` | Provider capability not confirmed |
| `AI_HUMAN_REVIEW_REQUIRED` | Output requires human review |
| `AI_READY_FOR_IMPLEMENTATION_PLANNING` | Ready for package planning, not coding |
| `AI_CODING_ALLOWED` | Only after explicit coding entry approval |

Default status for this phase:

`AI_PLANNED`

Coding is not allowed by this document.

---

## 30. Prohibited AI Shortcuts

The following are prohibited:

1. Embedding unclassified documents
2. Embedding unapproved operational content
3. Retrieving across wrong tenant/store boundary
4. Retrieving wrong-locale content silently
5. Using AI answer without source traceability
6. Treating AI summary as original evidence
7. Treating AI classification as final decision
8. Sending AI customer response without approved content boundary
9. AI refund approval
10. AI payment cancellation
11. AI settlement reconciliation
12. AI KDS mutation
13. AI provider capability invention
14. AI legal conclusion
15. AI bypassing masking
16. AI bypassing audit
17. Prompt containing secrets or production credentials
18. Vector retrieval from stale content as current truth
19. AI-generated hardcoded operational text
20. AI replacing content registry authority

---

## 31. Minimum AI Package Planning Checklist

Before any AI Support Gateway or pgvector RAG package proceeds, the following must be answered:

- What AI use case is being planned?
- What domain does it touch?
- What audience may receive the output?
- What source classes may be retrieved?
- What source classes are blocked?
- What source traceability is required?
- What locale behavior applies?
- What content registry or i18n keys are required?
- What SOP parser metadata must be preserved?
- What menu/content registry metadata must be preserved?
- What evidence may be summarized?
- What masking rule applies?
- What audit event is required?
- What authority is allowed?
- What authority is prohibited?
- What human review is required?
- What provider evidence is required?
- What vector index boundary applies?
- What stale content behavior applies?
- What degraded AI behavior applies?
- What coding entry status applies?

If any answer is missing, the AI package remains planning-only.

---

## 32. Relationship To Previous Documents

This document follows:

- `docs/022000_implementation_planning/022023_Index_Controlled_Implementation_Planning_README_And_Package_Decomposition.md`
- `docs/022000_implementation_planning/022024_Policy_Runtime_Package_Decomposition_And_Module_Boundary_Planning.md`
- `docs/022000_implementation_planning/022025_Policy_Data_Model_Planning_Boundary_And_Schema_Design_Readiness.md`
- `22330 API RPC Event Contract Planning Boundary Policy`
- `22340 UI Implementation Package Planning And I18n Surface Mapping Policy`
- `22350 Payment KDS Provider Adapter Package Planning Policy`
- `22360 Support Admin Evidence Audit Package Planning Policy`

This document prepares the boundary for:

- `22380 External Menu Projection Redtable Partner Package Planning Policy`
- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`

---

## 33. Final Rule

The AI Support Gateway is an assistance and retrieval boundary, not an execution authority.

At this stage, the correct output is not a chatbot, vector table, embedding pipeline, prompt, or support automation.

The correct output is a controlled AI/RAG package map that preserves source traceability, SOP metadata, content registry authority, i18n keys, locale/audience separation, masking, audit, provider evidence status, human review, and no-mutation boundaries.

Coding remains deferred until source readiness, vector index planning, traceability, i18n/content readiness, masking, audit, provider evidence, human review workflow, and explicit package entry gates are approved.
