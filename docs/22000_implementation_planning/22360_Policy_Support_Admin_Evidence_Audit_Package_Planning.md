# 22360_Policy_Support_Admin_Evidence_Audit_Package_Planning

## 1. Purpose

This document defines the planning boundary for support/admin packages, evidence packet handling, and audit lineage before controlled implementation begins.

The purpose is to prevent support/admin tools from becoming hidden mutation channels, unaudited override paths, unmasked data viewers, AI-assisted unauthorized action surfaces, or customer recovery shortcuts without evidence.

Support/admin surfaces may assist, classify, review, escalate, draft, approve, or execute only when the authority boundary is explicitly planned.

No support/admin implementation package may proceed to coding unless its evidence requirement, masking rule, audit event, authority level, i18n surface, and runtime contract dependency are explicitly mapped.

---

## 2. Scope

This policy applies to the following package families:

1. Support case inbox
2. Customer recovery support
3. Store incident support
4. Payment/refund support
5. KDS/order exception support
6. Provider issue support
7. External menu projection support
8. AI-assisted support response
9. Evidence packet viewer
10. Evidence packet creation
11. Audit event review
12. Masked data access
13. Break-glass or backup authority review
14. Support escalation workflow
15. HQ admin override review
16. Support/admin content and message templates
17. SOP-guided support workflows

This document does not implement any support console, admin screen, database table, RPC, Edge Function, AI retrieval function, audit trigger, or evidence storage system.

Coding remains deferred.

---

## 3. Core Principle

Support/admin is not a backdoor.

Support/admin packages must preserve:

- authority boundary
- evidence requirement
- masking boundary
- audit lineage
- customer/store/tenant boundary
- role boundary
- i18n/message key boundary
- SOP/content registry traceability
- AI assistance boundary
- escalation boundary
- provider evidence boundary

Support/admin tools must not mutate runtime state merely because an operator can see the issue.

Visibility does not equal authority.

Evidence does not equal approval.

AI suggestion does not equal decision.

Support convenience does not equal audit exemption.

---

## 4. Support/Admin Package Planning Rule

Every support/admin package must define:

| Field | Required Meaning |
|---|---|
| Package name | Stable planning identifier |
| Support domain | Payment, order, KDS, customer, provider, menu, incident, etc. |
| Actor | Support operator, HQ admin, owner, system, AI assistant |
| Authority level | View, draft, request, approve, execute, override |
| Data visibility | Full, masked, scoped, redacted, evidence-only |
| Evidence requirement | Required, optional, prohibited, system-generated |
| Audit requirement | Required audit event family |
| API/RPC dependency | Contract name from API/RPC/Event planning |
| Event dependency | Operational event consumed/emitted |
| i18n dependency | Message key/content key |
| SOP/content dependency | Source document/content registry linkage |
| AI boundary | None, retrieve, summarize, suggest, draft, blocked |
| Escalation path | Store, owner, HQ, provider, legal, finance |
| Coding status | Planned only / blocked / ready later |

---

## 5. Authority Classification

Support/admin actions must be classified by authority level.

| Authority Level | Meaning |
|---|---|
| `VIEW_ONLY` | May view permitted data only |
| `MASKED_VIEW` | May view masked or redacted data only |
| `EVIDENCE_REVIEW` | May review evidence but not decide |
| `DRAFT_RESPONSE` | May prepare response but not send/execute |
| `REQUEST_ACTION` | May request operational action |
| `APPROVAL_REQUIRED` | Requires authorized approval |
| `EXECUTE_APPROVED_ACTION` | May execute only after approval |
| `ESCALATE_ONLY` | May escalate but not resolve |
| `OVERRIDE_SCOPED` | Time/condition-scoped override only |
| `BLOCKED_NO_AUTHORITY` | UI/API must not expose action |

Support/admin UI must not visually hide these distinctions.

---

## 6. Evidence Packet Boundary

Evidence packets are structured accountability records.

An evidence packet may include:

- customer request
- order reference
- payment reference
- refund reference
- KDS ticket reference
- provider callback reference
- staff action reference
- support note
- uploaded image or document reference
- SOP section reference
- AI summary reference
- audit event reference
- timestamp sequence
- degraded state marker
- reconciliation marker

Evidence packets must preserve source traceability.

Evidence packets must not become unstructured notes.

Evidence packets must not replace approval.

---

## 7. Evidence Packet Minimum Fields

Every evidence packet contract must define:

| Field | Required Meaning |
|---|---|
| Evidence packet id | Stable evidence identifier |
| Case id | Related support/admin case |
| Tenant/store context | Scoped runtime context |
| Actor | Who created or attached evidence |
| Source type | Customer, staff, system, provider, AI, admin |
| Source reference | Original source id/document/event |
| Runtime domain | Payment, order, KDS, menu, provider, etc. |
| Evidence class | Photo, log, event, callback, note, SOP, AI summary |
| Timestamp | Created/received/observed time |
| Locale/audience | If content is user-facing |
| Masking status | Masked, unmasked, redacted, restricted |
| Integrity status | Original, derived, summarized, disputed |
| Review status | Pending, accepted, rejected, needs review |
| Audit link | Audit event reference |

Actual schema implementation is deferred.

---

## 8. Evidence Classes

Evidence classes must be planned explicitly.

Recommended classes:

- `CUSTOMER_MESSAGE`
- `CUSTOMER_IMAGE`
- `CUSTOMER_RECEIPT`
- `ORDER_EVENT`
- `PAYMENT_EVENT`
- `PROVIDER_CALLBACK`
- `KDS_EVENT`
- `STAFF_NOTE`
- `MANUAL_FALLBACK_NOTE`
- `SUPPORT_NOTE`
- `SOP_REFERENCE`
- `CONTENT_REGISTRY_REFERENCE`
- `AI_SUMMARY`
- `AI_DRAFT_RESPONSE`
- `ADMIN_APPROVAL`
- `AUDIT_EVENT_REFERENCE`
- `RECONCILIATION_REFERENCE`
- `LEGAL_REVIEW_REFERENCE`

AI-generated evidence must be labeled as AI-generated or AI-summarized.

---

## 9. Evidence Integrity Rule

Evidence must identify whether it is original or derived.

Integrity states should include:

- `ORIGINAL_SOURCE`
- `SYSTEM_CAPTURED`
- `USER_SUBMITTED`
- `STAFF_SUBMITTED`
- `PROVIDER_SUBMITTED`
- `AI_SUMMARIZED`
- `SUPPORT_DERIVED`
- `REDACTED_COPY`
- `DISPUTED`
- `UNVERIFIED`
- `RECONCILED`

Derived evidence must reference the original source.

AI summaries must never replace original evidence.

---

## 10. Audit Boundary

Audit is mandatory for authority-bearing support/admin actions.

Audit events must be created for:

- viewing restricted data
- unmasking data
- creating evidence packet
- attaching evidence
- rejecting evidence
- approving recovery
- approving refund
- executing refund
- escalating case
- closing case
- reopening case
- using backup/override authority
- changing provider capability status
- publishing external projection
- modifying support content template
- approving AI response template
- exporting evidence or reports

Support/admin audit is not optional.

---

## 11. Audit Event Minimum Fields

Each audit event contract must define:

| Field | Required Meaning |
|---|---|
| Audit event id | Stable audit identifier |
| Actor | Human/system actor |
| Actor role | Support, HQ, owner, staff, system |
| Authority used | Normal, scoped, backup, override |
| Target object | Case/order/payment/refund/ticket/provider/content |
| Previous state | Before action |
| Requested state | Intended action |
| Result state | Accepted, rejected, pending, failed |
| Evidence reference | Required if action is evidence-based |
| Reason code | Message/content key or controlled code |
| Locale/audience | If visible explanation exists |
| Timestamp | System timestamp |
| Correlation id | Runtime correlation |
| Review requirement | Whether later review is required |

Actual audit implementation is deferred.

---

## 12. Masking And Data Visibility Boundary

Support/admin packages must define data visibility before implementation.

Visibility classes:

| Class | Meaning |
|---|---|
| `PUBLIC_OPERATIONAL` | Safe operational data |
| `CUSTOMER_MASKED` | Customer data partially masked |
| `STAFF_MASKED` | Staff data partially masked |
| `PAYMENT_MASKED` | Payment data partially masked |
| `PROVIDER_DIAGNOSTIC` | Provider data visible only to scoped roles |
| `EVIDENCE_ONLY` | Visible only inside evidence packet |
| `RESTRICTED_FULL_VIEW` | Full view with audit and justification |
| `LEGAL_REVIEW_ONLY` | Legal/compliance restricted |
| `BLOCKED` | Must not be visible |

Support convenience must not bypass masking.

Unmasking must require role, reason, and audit.

---

## 13. Customer Data Boundary

Customer data in support/admin surfaces must be minimized.

Planning must define whether support may see:

- customer name
- customer phone
- customer email
- membership id
- order history
- payment method metadata
- refund history
- support case history
- location/session information
- device information
- language preference
- uploaded evidence

Default posture should be masked or scoped unless operational need is proven.

---

## 14. Payment And Refund Support Boundary

Payment/refund support packages must separate:

- payment state visibility
- refund request
- refund evidence
- refund approval
- refund execution
- refund failure
- reconciliation
- customer notification
- audit event

Support may assist with payment/refund handling only through defined contracts.

Support notes must not directly mutate payment, refund, or settlement state.

Refund execution requires explicit authority and audit.

---

## 15. KDS And Order Exception Support Boundary

KDS/order support packages must separate:

- customer complaint
- order event
- POS accepted order
- KDS ticket state
- kitchen delay
- remake request
- manual fallback note
- completion evidence
- customer recovery proposal
- refund/compensation request

KDS evidence may support review.

KDS evidence does not automatically approve refund or compensation.

Support/admin UI must preserve this distinction.

---

## 16. Provider Issue Support Boundary

Provider issue support packages apply to:

- payment provider issue
- KDS provider issue
- POS provider issue
- external menu projection provider issue
- Redtable-type partner issue
- global payment candidate issue
- provider callback failure
- provider settlement delay

Provider issue handling must preserve:

- provider capability status
- provider evidence source
- callback verification status
- escalation channel
- retry/replay rule
- customer-facing message key
- internal diagnostic boundary
- audit event

Provider marketing claims must not be treated as confirmed capability.

---

## 17. External Menu Projection Support Boundary

External menu projection support packages must handle:

- wrong translation
- wrong price
- wrong availability
- wrong allergen display
- stale menu projection
- provider projection failure
- QR/NFC projection failure
- Google Maps-linked projection issue
- Redtable-type partner projection issue
- foreign customer misunderstanding

Support must trace the issue back to:

- internal menu source
- content registry key
- locale
- translation source
- publication version
- provider projection target
- provider capability status
- rollback version

External projection support must not change menu source of truth directly.

---

## 18. AI-Assisted Support Boundary

AI may assist support/admin packages only within controlled limits.

AI may:

- retrieve SOP-aware content
- retrieve menu/content registry entries
- summarize evidence
- classify issue family
- suggest escalation path
- draft support response
- identify missing evidence
- identify provider evidence requirement
- translate approved content where allowed

AI must not:

- approve refunds
- execute refunds
- finalize customer compensation
- close support cases automatically
- invent provider capability
- override staff/store decisions
- expose restricted data
- produce customer-facing operational content without approved content boundary
- bypass audit
- bypass masking
- bypass tenant/store boundary

AI output must be labeled as suggestion, summary, or draft unless explicitly approved by contract.

---

## 19. SOP-Guided Support Boundary

SOP content may guide support/admin workflows only when traceability is preserved.

SOP-guided support must preserve:

- SOP document id
- section id
- locale
- audience
- runtime boundary
- authority boundary
- actionability level
- evidence requirement
- fallback condition
- content registry linkage

SOP text must not be pasted as free-form support authority.

SOP guidance does not automatically grant action authority.

---

## 20. Support Message i18n Boundary

All customer/staff/owner/provider-visible support messages must use i18n message keys or content registry keys.

This includes:

- case received message
- refund request received message
- evidence required message
- approval pending message
- rejection explanation
- provider issue explanation
- KDS delay explanation
- menu projection correction notice
- foreign-language support message
- AI-assisted draft response
- escalation notice
- closure message

Hardcoded support messages are prohibited.

---

## 21. Case State Planning

Support/admin packages must distinguish case states.

Recommended state families:

- `CASE_CREATED`
- `CASE_TRIAGE_PENDING`
- `CASE_EVIDENCE_REQUIRED`
- `CASE_EVIDENCE_ATTACHED`
- `CASE_REVIEW_PENDING`
- `CASE_ESCALATED_STORE`
- `CASE_ESCALATED_HQ`
- `CASE_ESCALATED_PROVIDER`
- `CASE_ESCALATED_LEGAL`
- `CASE_ACTION_REQUESTED`
- `CASE_APPROVAL_REQUIRED`
- `CASE_APPROVED`
- `CASE_REJECTED`
- `CASE_ACTION_EXECUTED`
- `CASE_RECONCILIATION_REQUIRED`
- `CASE_CLOSED`
- `CASE_REOPENED`

Actual enum/schema implementation is deferred.

---

## 22. Escalation Boundary

Escalation paths must be explicitly planned.

Escalation targets may include:

- store staff
- store manager
- store owner
- HQ operations
- HQ finance
- HQ support lead
- HQ legal/compliance
- payment provider
- KDS/POS provider
- external menu projection partner
- AI/content review
- translation/content registry reviewer

Escalation must preserve evidence and audit lineage.

Escalation must not erase previous support state.

---

## 23. Override And Backup Authority Boundary

Support/admin packages must distinguish normal authority from backup or override authority.

Override authority must be:

- explicit
- role-scoped
- time-scoped
- condition-scoped
- reason-required
- evidence-required where applicable
- reauthentication-required for sensitive actions
- fully audited
- reviewable after execution

Override actions must not appear as ordinary support actions.

---

## 24. Export And Report Boundary

Support/admin evidence or audit export must be treated as restricted.

Export planning must define:

- who may export
- what data is included
- masking/redaction rule
- purpose/reason requirement
- time range
- case scope
- legal/compliance review if needed
- audit event
- retention rule

Evidence export must not become uncontrolled data leakage.

---

## 25. Support/Admin Package Naming Rule

Support/admin package planning identifiers should follow:

`support.<domain>.<purpose>.<version>`

or:

`admin.<domain>.<purpose>.<version>`

Examples:

- `support.case.inbox.v1`
- `support.payment.refund_review.v1`
- `support.kds.delay_evidence.v1`
- `support.provider.callback_issue.v1`
- `support.ai.response_draft.v1`
- `admin.audit.event_review.v1`
- `admin.evidence.packet_viewer.v1`
- `admin.content.support_template_approval.v1`
- `admin.provider.capability_review.v1`

These identifiers are planning names only.

They do not imply implementation exists.

---

## 26. Support/Admin Readiness Levels

Each support/admin package must have a readiness status.

| Status | Meaning |
|---|---|
| `SUPPORT_IDEA` | Candidate only |
| `SUPPORT_PLANNED` | Boundary described |
| `SUPPORT_CONTRACT_REQUIRED` | API/RPC/event contract missing |
| `SUPPORT_EVIDENCE_REQUIRED` | Evidence model incomplete |
| `SUPPORT_AUDIT_REQUIRED` | Audit lineage incomplete |
| `SUPPORT_MASKING_REQUIRED` | Data visibility/masking incomplete |
| `SUPPORT_I18N_REQUIRED` | Message/content keys missing |
| `SUPPORT_AI_BOUNDARY_REQUIRED` | AI assistance boundary incomplete |
| `SUPPORT_PROVIDER_EVIDENCE_REQUIRED` | Provider support not confirmed |
| `SUPPORT_READY_FOR_IMPLEMENTATION_PLANNING` | Ready for package planning, not coding |
| `SUPPORT_CODING_ALLOWED` | Only after explicit coding entry approval |

Default status for this phase:

`SUPPORT_PLANNED`

Coding is not allowed by this document.

---

## 27. Prohibited Support/Admin Shortcuts

The following are prohibited:

1. Support/admin mutation without audit
2. Support/admin mutation without authority contract
3. Refund execution from support note alone
4. KDS evidence treated as automatic compensation approval
5. AI suggestion treated as final decision
6. SOP text treated as executable authority
7. Unmasked data access without reason and audit
8. Provider capability upgrade without evidence
9. Customer-facing support message without i18n/content key
10. Evidence packet without source traceability
11. Evidence export without audit
12. Override action hidden as normal action
13. Case closure without required evidence/action lineage
14. External menu projection correction without content registry linkage
15. Hardcoded support/admin operational strings
16. Debug/provider diagnostics shown to customer
17. Manual fallback evidence silently merged as normal state

---

## 28. Minimum Support/Admin Planning Checklist

Before any support/admin package proceeds, the following must be answered:

- What support/admin domain does this package handle?
- Who is the actor?
- What authority level is allowed?
- What data is visible?
- What data is masked?
- What evidence is required?
- What audit event is required?
- What API/RPC/event contract does it depend on?
- What operational event does it consume or emit?
- What i18n/message keys are required?
- What content registry/SOP source is required?
- What AI assistance is allowed?
- What AI assistance is blocked?
- What escalation path exists?
- What provider evidence is required?
- What override/backup authority boundary applies?
- What export/report restriction applies?
- What coding entry status applies?

If any answer is missing, the package remains planning-only.

---

## 29. Relationship To Previous Documents

This document follows:

- `22023_Index_Controlled_Implementation_Planning_README_And_Package_Decomposition`
- `22024_Policy_Runtime_Package_Decomposition_And_Module_Boundary_Planning`
- `22025_Policy_Data_Model_Planning_Boundary_And_Schema_Design_Readiness`
- `22330 API RPC Event Contract Planning Boundary Policy`
- `22340 UI Implementation Package Planning And I18n Surface Mapping Policy`
- `22350 Payment KDS Provider Adapter Package Planning Policy`

This document prepares the boundary for:

- `22370 AI Support Gateway pgvector RAG Package Planning Policy`
- `22380 External Menu Projection Redtable Partner Package Planning Policy`
- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`

---

## 30. Final Rule

Support/admin packages are authority-sensitive operational control surfaces.

At this stage, the correct output is not a support console, database schema, audit trigger, AI tool, or admin UI.

The correct output is a controlled support/admin package map that preserves evidence traceability, audit accountability, masking, i18n/content keys, SOP boundaries, AI limits, provider evidence status, escalation paths, and authority separation.

Coding remains deferred until evidence model readiness, audit lineage, masking policy, API/RPC/event contracts, i18n/content readiness, provider evidence, AI boundary, and explicit package entry gates are approved.
