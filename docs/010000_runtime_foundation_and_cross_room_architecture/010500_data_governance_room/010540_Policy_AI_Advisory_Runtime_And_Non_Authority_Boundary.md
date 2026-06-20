# 010540_Policy_AI_Advisory_Runtime_And_Non_Authority_Boundary.md

## Purpose

This document defines the AI Advisory Runtime and Non-Authority Boundary Policy.

The previous artifact `10530` defined the Safe Projection, Masking, and Audience Visibility Boundary Policy.

This document frames the fourth Data Governance room:

`AI Advisory Runtime And Non-Authority Room`

The purpose is to define the boundary where AI may assist with summaries, recommendations, anomaly hints, SOP guidance, support drafting, incident triage, recovery suggestion, translation assistance, content drafting, and operational explanation without becoming execution authority, approval authority, financial authority, provider truth verifier, settlement authority, compensation authority, security containment authority, or source of truth.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The AI Advisory Runtime and Non-Authority Room governs advisory AI usage.

It may later coordinate:

- AI input source approval
- AI prompt/context boundary
- masking before AI use
- tenant/store scope enforcement
- AI task classification
- AI output classification
- AI advisory label
- source reference requirement
- uncertainty marker
- human review requirement
- prohibited action enforcement
- AI evidence linkage
- AI audit reference
- AI containment if unsafe output occurs

AI may assist.

AI must not become authority.

---

## 3. Core Principle

AI is advisory only.

The correct rule is:

AI summary is not truth.  
AI recommendation is not approval.  
AI confidence is not evidence.  
AI explanation is not root cause authority.  
AI draft is not publication.  
AI triage is not incident resolution.  
AI suggested refund is not refund approval.  
AI suggested coupon is not coupon issuance.  
AI suggested settlement correction is not amendment.  
AI related-case reasoning is not proof.  
AI must not execute, approve, mutate, reconcile, confirm, suppress, or release containment.  

AI output must be source-linked, masked, scoped, reviewable, auditable, and safely projected.

---

## 4. Scope

This room may define planning boundaries for:

- AI summary
- AI recommendation
- AI anomaly hint
- AI SOP guidance
- AI support draft
- AI CMS draft
- AI translation assistance
- AI incident triage
- AI recovery suggestion
- AI financial explanation
- AI analytics explanation
- AI search/routing assistance
- AI human-review workflow
- AI output projection
- AI audit
- tenant/store isolation
- masking and source classification

This room does not implement AI runtime.

---

## 5. AI Task Catalog

Recommended AI task catalog:

| Task | Meaning |
|---|---|
| `AI_SUMMARY` | Summarize approved scoped source data |
| `AI_RECOMMENDATION` | Suggest next review action |
| `AI_ANOMALY_HINT` | Suggest possible anomaly pattern |
| `AI_SOP_GUIDANCE` | Retrieve/explain approved SOP guidance |
| `AI_SUPPORT_DRAFT` | Draft support response for review |
| `AI_CMS_DRAFT` | Draft CMS content for review |
| `AI_TRANSLATION_DRAFT` | Draft translation for review |
| `AI_INCIDENT_TRIAGE` | Triage incident category for human review |
| `AI_RECOVERY_SUGGESTION` | Suggest recovery option for review |
| `AI_FINANCIAL_EXPLANATION` | Explain financial state for authorized admin |
| `AI_ANALYTICS_EXPLANATION` | Explain analytics/read model output |
| `AI_PROVIDER_EVENT_SUMMARY` | Summarize provider evidence for review |
| `AI_VECTOR_CONTEXT_EXPLANATION` | Explain retrieved related context |
| `AI_RISK_HINT` | Provide risk hint without authority |

Task catalog determines allowed inputs, outputs, and review rules.

---

## 6. AI Prohibited Task Catalog

AI must not perform:

| Prohibited Task | Rule |
|---|---|
| `EXECUTE_ORDER` | AI must not execute order |
| `CREATE_KDS_TICKET` | AI must not create kitchen ticket |
| `CONFIRM_PAYMENT` | AI must not confirm payment |
| `APPROVE_REFUND` | AI must not approve refund |
| `EXECUTE_REFUND` | AI must not execute refund |
| `ISSUE_COUPON` | AI must not issue coupon |
| `GRANT_POINTS` | AI must not grant points |
| `MUTATE_WALLET` | AI must not mutate wallet |
| `APPROVE_COMPENSATION` | AI must not approve compensation |
| `CONFIRM_SETTLEMENT` | AI must not confirm settlement |
| `APPROVE_PAYOUT` | AI must not approve payout |
| `PUBLISH_CMS` | AI must not publish CMS content |
| `RESOLVE_INCIDENT` | AI must not resolve incident |
| `CLOSE_RECOVERY` | AI must not close recovery |
| `VERIFY_PROVIDER_TRUTH` | AI must not verify provider truth |
| `RELEASE_CONTAINMENT` | AI must not release containment |
| `BYPASS_TENANT_ISOLATION` | AI must not bypass tenant/store scope |
| `BYPASS_MASKING` | AI must not bypass masking |
| `BYPASS_AUDIT` | AI must not bypass audit |

Prohibited tasks are non-negotiable.

---

## 7. AI State Skeleton

Recommended AI states:

| State | Meaning |
|---|---|
| `AI_NOT_REQUESTED` | AI not requested |
| `AI_CONTEXT_CANDIDATE` | Context candidate prepared |
| `AI_CONTEXT_REVIEW_REQUIRED` | Context review required |
| `AI_CONTEXT_ALLOWED` | Context allowed |
| `AI_CONTEXT_BLOCKED` | Context blocked |
| `AI_MASKING_REQUIRED` | Masking required |
| `AI_OUTPUT_GENERATED` | Output generated |
| `AI_OUTPUT_REVIEW_REQUIRED` | Human review required |
| `AI_OUTPUT_ACCEPTED_AS_DRAFT` | Accepted as draft |
| `AI_OUTPUT_REJECTED` | Rejected |
| `AI_OUTPUT_ESCALATION_REQUIRED` | Escalation required |
| `AI_OUTPUT_CONTAINMENT_REQUIRED` | Unsafe output containment required |
| `AI_OUTPUT_ARCHIVED` | Archived for trace |
| `AI_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 8. AI Input Source Boundary

AI input source must be approved before use.

Allowed source candidates may include:

- approved SOP
- approved policy document
- scoped order summary
- scoped incident summary
- scoped recovery summary
- masked customer support case
- masked payment status summary
- masked refund status summary
- masked value ledger summary
- masked settlement summary for finance role
- approved CMS draft context
- approved i18n message context
- approved analytics/read model summary
- approved pgvector retrieved context

Raw restricted data must not be passed to AI by default.

---

## 9. AI Input Prohibited Source Boundary

AI must not directly consume:

- unmasked customer personal data
- raw payment credentials
- raw provider payment payload
- raw wallet/stored value ledger if not authorized
- raw settlement/payout detail without finance scope
- security containment secrets
- secret keys or tokens
- unrestricted staff private notes
- legal/compliance restricted records without approval
- cross-tenant raw data
- unresolved provider truth as verified fact
- unapproved draft policy as final guidance
- vector retrieval without source classification

Unsafe input must fail closed.

---

## 10. Tenant Store Scope Boundary

Every AI request must preserve scope.

AI context must include or derive:

- tenant id
- store id if store-scoped
- brand id if applicable
- operating group id if applicable
- legal entity id if financial/legal context applies
- customer/account id if customer-scoped
- actor id
- actor role
- audience class
- source data class
- masking class
- permitted task
- audit reference

AI must not combine tenants or stores unless explicitly allowed, aggregated, masked, and governed.

Default:

`CROSS_TENANT_ACCESS_DENIED`

AI must follow `10141`.

---

## 11. Masking Before AI Boundary

Masking must occur before AI use.

Masking may remove or transform:

- customer name
- phone/email
- payment reference
- provider transaction reference
- wallet/point/coupon sensitive detail
- staff personal note
- legal/compliance detail
- security containment detail
- device secret
- raw provider payload
- unrelated store/tenant context

AI must not be used as a masking engine for raw sensitive data unless separately authorized under a secure boundary.

---

## 12. AI Output Classification Boundary

AI output must be classified before projection.

Recommended output classes:

| Output Class | Meaning |
|---|---|
| `AI_DRAFT_ONLY` | Draft requiring human review |
| `AI_INTERNAL_HINT` | Internal hint only |
| `AI_REVIEW_SUMMARY` | Review summary |
| `AI_SUPPORT_DRAFT` | Support draft requiring approval |
| `AI_CMS_DRAFT` | CMS draft requiring approval |
| `AI_TRANSLATION_DRAFT` | Translation draft requiring review |
| `AI_OPERATIONAL_SUGGESTION` | Operational suggestion only |
| `AI_FINANCIAL_EXPLANATION` | Finance/admin explanation only |
| `AI_RISK_HINT` | Risk hint, not decision |
| `AI_BLOCKED_OUTPUT` | Unsafe output blocked |
| `AI_ESCALATION_OUTPUT` | Output requires escalation |

Output classification determines visibility and next action.

---

## 13. Source Reference Requirement

AI output must reference source material where applicable.

Source reference may include:

- SOP reference
- policy reference
- order summary reference
- incident reference
- recovery reference
- evidence packet reference
- payment/refund/value status reference
- analytics source reference
- CMS draft reference
- i18n key reference
- vector source reference

AI output without source reference must be treated as weaker advisory text.

AI must not invent authority.

---

## 14. Uncertainty Marker Boundary

AI output must carry uncertainty when:

- source is incomplete
- source conflicts
- provider state is unknown
- payment state is pending
- refund state is pending
- recovery review is unresolved
- settlement mismatch exists
- vector retrieval is similarity-based
- analytics is stale
- legal/compliance review is needed
- human review is required

Uncertainty must not be hidden behind confident wording.

---

## 15. Human Review Boundary

Human review is required before AI output affects:

- customer communication
- CMS publication
- translation publication
- support response
- incident categorization
- recovery action
- financial explanation shown beyond safe status
- refund/compensation recommendation
- settlement/reconciliation suggestion
- legal/compliance route
- security containment response

Human review does not automatically approve execution.

Execution still belongs to source authority rooms.

---

## 16. AI Support Draft Boundary

AI may draft support response only if authorized.

Support draft must:

- use customer-safe or support-safe sources
- avoid unapproved promises
- avoid legal conclusion
- avoid blame
- avoid raw provider detail
- avoid financial confirmation beyond verified state
- include review requirement
- use approved i18n or translation review path if customer-facing

AI support draft is not sent message.

---

## 17. AI CMS Draft Boundary

AI may draft CMS content only if authorized.

AI CMS draft must:

- be marked draft
- preserve tenant/store/brand scope
- avoid unapproved financial/value promises
- avoid legal/policy interpretation without source
- avoid incident/security detail
- route to CMS approval
- route to i18n review if human-visible

AI CMS draft is not approved content.

AI must not publish CMS.

---

## 18. AI Translation Draft Boundary

AI may draft translation only if authorized.

AI translation draft must:

- preserve message key
- preserve audience class
- preserve safety class
- preserve legal/financial meaning
- preserve degraded/fallback safety
- avoid over-promising
- require review
- record source language/version

AI translation draft is not approved translation.

---

## 19. AI Incident Triage Boundary

AI may suggest incident category only if authorized.

AI triage may suggest:

- possible incident type
- missing evidence
- likely affected room
- escalation candidate
- SOP reference
- customer-safe wording candidate

AI triage must not:

- resolve incident
- assign blame
- declare root cause as authority
- close incident
- approve compensation
- release containment

Incident owner must review.

---

## 20. AI Recovery Suggestion Boundary

AI may suggest recovery options only if authorized.

AI may suggest:

- apology-only candidate
- staff assist candidate
- remake/replacement candidate
- refund review candidate
- coupon/point/wallet review candidate
- manager escalation
- HQ escalation
- legal/compliance route

AI suggestion is not approval.

Compensation authority remains separate.

---

## 21. AI Financial Explanation Boundary

AI may explain financial state only from verified, masked, scoped summaries.

AI must not:

- confirm payment beyond Financial Trust state
- approve refund
- execute refund
- issue coupon
- grant points
- mutate wallet
- decide settlement
- amend reconciliation
- approve payout
- expose raw provider payload
- expose restricted financial evidence

AI financial explanation is advisory.

Financial Trust remains source of truth.

---

## 22. AI Analytics Explanation Boundary

AI may explain analytics only if authorized.

AI explanation must include:

- metric definition
- source period
- stale marker
- aggregation level
- scope
- caveat if sample is limited
- unresolved data conflict marker if applicable

AI analytics explanation must not become punitive authority.

Benchmark interpretation must remain governed.

---

## 23. AI Security Boundary

AI must not expose or act on sensitive security details.

AI must not:

- reveal containment details to unauthorized audiences
- recommend bypassing controls
- release quarantine
- approve provider trust
- generate secrets
- handle raw credentials
- disclose security incident internals
- infer tenant access
- suppress alerts

Security-restricted analysis requires separate authority and masking.

---

## 24. AI Output Projection Boundary

AI output must pass Safe Projection before display.

Projection must check:

- audience class
- data class
- masking class
- tenant/store scope
- source reference
- uncertainty marker
- review requirement
- prohibited action content
- i18n/customer-safe requirements if customer-facing

AI output must not be shown directly to customers unless explicitly approved as customer-safe text.

---

## 25. AI Audit Boundary

AI usage should record:

- actor
- tenant/store scope
- task type
- input source references
- masking status
- output class
- output reference
- review status
- projection audience
- prohibited action check
- uncertainty marker
- timestamp
- audit reference

AI audit is not approval.

AI audit supports traceability.

---

## 26. AI Containment Boundary

AI output must be contained when:

- it exposes restricted data
- it crosses tenant/store scope
- it makes unauthorized promise
- it suggests prohibited action
- it claims verified truth without source
- it hides uncertainty
- it produces unsafe customer text
- it conflicts with source evidence
- it encourages unsafe retry or bypass
- it reveals security/internal details

Containment is not resolution.

Contained output must be reviewed.

---

## 27. Relationship To CMS Room

AI may draft CMS content if authorized.

CMS Room owns content review, approval, targeting, publication, rollback, and expiration.

AI must not approve or publish CMS.

AI draft remains draft until CMS process approves it.

---

## 28. Relationship To i18n Room

AI may draft translation if authorized.

i18n Room owns message key, locale, fallback, safety class, versioning, and approval.

AI translation draft is not approved translation.

---

## 29. Relationship To Safe Projection Room

Safe Projection Room controls AI output visibility.

AI output must be classified, masked, scoped, and reviewed before projection.

AI output must carry advisory/non-authority framing.

---

## 30. Relationship To pgvector Room

AI may use pgvector retrieval only if vector sources are approved, scoped, masked, and traceable.

Vector similarity is not proof.

AI must not convert retrieved similarity into authority.

AI output must cite source references and uncertainty.

---

## 31. Relationship To Analytics Room

AI may explain analytics/read models.

Analytics Room owns metric definition, refresh cadence, stale marker, aggregation threshold, and benchmark eligibility.

AI explanation is not metric truth.

---

## 32. Relationship To Financial Trust

Financial Trust owns payment, refund, value, settlement, and compensation truth.

AI must not:

- confirm payment
- approve refund
- issue value
- mutate wallet
- approve compensation
- amend settlement
- approve payout

AI may summarize or explain only verified, masked, scoped financial projections.

---

## 33. Relationship To Store Runtime

Store Runtime owns operational execution.

AI must not:

- create POS handoff
- create KDS ticket
- complete kitchen state
- resolve fulfillment
- close incident
- trigger manual fallback mutation
- override staff/operator authority

AI may suggest next action for human review.

---

## 34. AI Anti-Patterns

Avoid:

- AI summary treated as truth
- AI confidence treated as evidence
- AI recommendation treated as approval
- AI draft sent to customer without review
- AI CMS draft published directly
- AI translation published directly
- AI triage resolving incident
- AI suggesting refund treated as refund approval
- AI suggesting coupon treated as coupon issuance
- AI explaining settlement treated as settlement correction
- AI output hiding uncertainty
- AI using raw unmasked financial/provider data
- AI combining cross-tenant context
- AI output projected without Safe Projection
- AI audit treated as approval

These anti-patterns must be blocked in future runtime design.

---

## 35. Runtime Deferral

This document defines the AI Advisory Runtime and Non-Authority Room boundary only.

It does not authorize:

- AI runtime
- AI agent implementation
- prompt orchestration
- model integration
- AI support drafting runtime
- AI CMS drafting runtime
- AI translation runtime
- AI incident triage runtime
- AI financial explanation runtime
- AI analytics explanation runtime
- pgvector integration
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 36. Validation Checklist

Validation must confirm:

1. AI Advisory Room definition is clear.
2. AI is advisory only.
3. AI task catalog is defined.
4. AI prohibited task catalog is defined.
5. AI state skeleton is defined.
6. AI input source boundary is defined.
7. AI prohibited source boundary is defined.
8. Tenant/store scope boundary is defined.
9. Masking-before-AI boundary is defined.
10. AI output classification boundary is defined.
11. Source reference requirement is defined.
12. Uncertainty marker boundary is defined.
13. Human review boundary is defined.
14. Support draft boundary is defined.
15. CMS draft boundary is defined.
16. Translation draft boundary is defined.
17. Incident triage boundary is defined.
18. Recovery suggestion boundary is defined.
19. Financial explanation boundary is defined.
20. Analytics explanation boundary is defined.
21. Security boundary is defined.
22. Output projection boundary is defined.
23. AI audit boundary is defined.
24. AI containment boundary is defined.
25. Relationships to Data Governance rooms are defined.
26. Relationships to Financial Trust and Store Runtime are defined.
27. Anti-patterns are listed.
28. Coding remains unauthorized.
29. Runtime remains deferred.

---

## 37. Relationship To Previous Documents

This document follows:

- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10480 Financial Trust Closure And Data Governance Handoff Policy`
- `10500 Data Governance Room Framing And Intelligence Boundary Index`
- `10510 CMS Content Publication And Targeting Boundary Policy`
- `10520 i18n Message Key And Human Visible Text Boundary Policy`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`

It prepares:

- `10550 pgvector Context Retrieval And Similarity Boundary Policy`
- `10560 Analytics Read Model And Benchmark Boundary Policy`
- `10570 Retention Export And Compliance Data Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 38. Final Rule

The AI Advisory Runtime and Non-Authority Room governs AI assistance without granting AI authority.

AI summary is not truth.

AI recommendation is not approval.

AI confidence is not evidence.

AI explanation is not root cause authority.

AI draft is not publication.

AI triage is not incident resolution.

AI suggested refund is not refund approval.

AI suggested coupon is not coupon issuance.

AI suggested settlement correction is not amendment.

AI related-case reasoning is not proof.

AI must never execute, approve, mutate, reconcile, confirm, suppress, publish, compensate, refund, settle, issue value, verify provider truth, bypass tenant isolation, bypass masking, bypass audit, or release containment.

AI output must preserve tenant/store/legal/customer scope, approved sources, masking, source references, uncertainty markers, human review, Safe Projection, i18n, audit, containment, Financial Trust separation, Store Runtime separation, pgvector non-proof, analytics non-authority, and runtime deferral.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
