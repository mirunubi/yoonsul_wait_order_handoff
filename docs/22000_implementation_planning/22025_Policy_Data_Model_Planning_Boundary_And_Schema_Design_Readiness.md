# 22025_Policy_Data_Model_Planning_Boundary_And_Schema_Design_Readiness

## 1. Purpose

This document defines the data model planning boundary, schema design readiness, entity candidate planning, relationship candidate planning, state/event data separation, evidence/audit data boundary, i18n content data planning, provider mapping data planning, Redtable-type partner data planning, AI/RAG source data planning, and no-code boundary for the Yoonsul Wait/Order Handoff operating system.

The previous document defined runtime package decomposition, module boundary planning, runtime ownership, state ownership, event ownership, command/query/projection boundaries, cross-runtime dependencies, and authority prohibitions.

This document focuses on how data model candidates should be planned from those runtime boundaries before any schema, migration, table, function, index, RLS policy, view, API, or implementation code is created.

This document does not authorize schema creation.

It defines data model planning and schema readiness policy only.

---

## 2. Scope

This document covers:

- data model planning boundary
- schema design readiness
- entity candidate planning
- relationship candidate planning
- state data planning
- event data planning
- command/query data boundary
- evidence data boundary
- audit data boundary
- i18n content data planning
- menu content data planning
- provider mapping data planning
- payment/KDS/POS data planning
- support/Admin data planning
- AI/RAG source data planning
- external menu projection data planning
- Redtable-type partner data planning
- no-code boundary

This document does not cover:

- final schema
- SQL DDL
- migration files
- database functions
- RLS policies
- triggers
- indexes
- materialized views
- API implementation
- Flutter implementation
- production database design

---

## 3. Core Principle

Data model planning must follow runtime ownership.

The project must follow this rule:

> No entity, table, state, event, evidence record, audit record, content registry, provider mapping, or partner projection data model may be planned without knowing which runtime owns it, which runtime reads it, which surfaces display it, which messages explain it, which tests verify it, and which evidence proves it.

Database design must not invent authority.

Data model follows runtime truth.

Schema comes after ownership, boundary, test, evidence, and i18n readiness.

---

## 4. Data Model Planning Meaning

Data model planning means identifying candidate data structures before schema design.

It may define:

- entity candidates
- relationship candidates
- state candidates
- event candidates
- evidence candidates
- audit candidates
- i18n content candidates
- provider mapping candidates
- support case candidates
- projection candidates
- registry candidates

It must not define final SQL.

---

## 5. Schema Design Readiness Meaning

Schema design readiness means the project has enough clarity to later design actual tables, constraints, indexes, RLS, functions, and views.

Schema design readiness requires:

- source traceability
- runtime owner
- entity purpose
- relationship purpose
- state/event boundary
- authority boundary
- data sensitivity
- access/masking requirement
- evidence/audit requirement
- i18n requirement
- provider dependency if any
- fallback/rollback implication
- test candidates

Readiness is not implementation.

---

## 6. Data Model Candidate Status Values

Recommended status values:

- `DATA_MODEL_CANDIDATE_DRAFT`
- `DATA_MODEL_SOURCE_REQUIRED`
- `DATA_MODEL_OWNER_REQUIRED`
- `DATA_MODEL_ENTITY_REVIEW_REQUIRED`
- `DATA_MODEL_RELATIONSHIP_REVIEW_REQUIRED`
- `DATA_MODEL_STATE_EVENT_REVIEW_REQUIRED`
- `DATA_MODEL_SENSITIVITY_REVIEW_REQUIRED`
- `DATA_MODEL_I18N_REVIEW_REQUIRED`
- `DATA_MODEL_EVIDENCE_REVIEW_REQUIRED`
- `DATA_MODEL_ACCESS_REVIEW_REQUIRED`
- `DATA_MODEL_PROVIDER_REVIEW_REQUIRED`
- `DATA_MODEL_BLOCKED`
- `DATA_MODEL_READY_FOR_SCHEMA_PLANNING`
- `DATA_MODEL_APPROVED_WITH_CONDITIONS`
- `DATA_MODEL_DEFERRED`
- `DATA_MODEL_REJECTED`
- `DATA_MODEL_SUPERSEDED`

Status must not imply migration approval.

---

## 7. Data Model Candidate Record Fields

Each candidate record should include:

- data model candidate id
- candidate name
- candidate type
- source references
- linked package id
- runtime owner
- related runtime
- entity candidates
- relationship candidates
- state candidates
- event candidates
- sensitivity level
- access rule candidate
- masking requirement
- evidence requirement
- audit requirement
- i18n requirement
- provider dependency
- external projection dependency
- fallback/rollback implication
- blockers
- status
- notes

Record must be traceable.

---

## 8. Data Model Candidate ID Format

Recommended format:

    DATA-MODEL-[DOMAIN]-[YYYYMMDD]-[NUMBER]

Examples:

    DATA-MODEL-PAY-20260612-001
    DATA-MODEL-KDS-20260612-001
    DATA-MODEL-I18N-20260612-001
    DATA-MODEL-REDTABLE-20260612-001

Final format may be normalized later.

---

## 9. Candidate Type Values

Recommended candidate type values:

- `ENTITY_CANDIDATE`
- `RELATIONSHIP_CANDIDATE`
- `STATE_CANDIDATE`
- `EVENT_CANDIDATE`
- `COMMAND_RECORD_CANDIDATE`
- `QUERY_PROJECTION_CANDIDATE`
- `EVIDENCE_CANDIDATE`
- `AUDIT_CANDIDATE`
- `I18N_CONTENT_CANDIDATE`
- `MENU_CONTENT_CANDIDATE`
- `PROVIDER_MAPPING_CANDIDATE`
- `EXTERNAL_PROJECTION_CANDIDATE`
- `SUPPORT_CASE_CANDIDATE`
- `PILOT_LEARNING_CANDIDATE`
- `REGISTRY_CANDIDATE`

Candidate type guides future schema design.

---

## 10. Entity Candidate Rule

Each entity candidate should define:

- entity meaning
- runtime owner
- source references
- business reason
- lifecycle
- identity candidate
- relationship candidates
- state candidates if any
- event candidates if any
- access sensitivity
- evidence/audit requirement
- i18n/content requirement if applicable
- excluded meaning

Entity must not be created only because a screen needs it.

---

## 11. Relationship Candidate Rule

Each relationship candidate should define:

- source entity
- target entity
- relationship meaning
- cardinality candidate
- lifecycle dependency
- authority dependency
- optional/required candidate
- deletion/correction implication
- evidence requirement if any
- access/masking implication

Relationship must reflect runtime reality.

---

## 12. State Candidate Rule

Each state candidate should define:

- state name
- runtime owner
- meaning
- allowed previous state candidates
- allowed next state candidates
- transition event candidate
- command candidate if any
- evidence requirement
- audit requirement if any
- UI display implication
- i18n message implication

State candidate belongs to one runtime.

---

## 13. Event Candidate Rule

Each event candidate should define:

- event name
- source
- receiving runtime
- validation rule
- idempotency key candidate
- duplicate handling
- stale handling
- accepted result
- rejected result
- evidence output
- audit output if needed
- error message if rejected

Event candidate must preserve authority.

---

## 14. Command Record Candidate Rule

If commands need durable records, command candidate should define:

- command name
- requester
- target runtime
- precondition
- authority requirement
- expected state effect
- rejection reason candidate
- evidence output
- audit output if needed
- idempotency requirement
- i18n message if user-facing

Command record is not automatically state.

---

## 15. Query Projection Candidate Rule

Query/projection candidates should define:

- source runtime
- projection target
- audience
- visible fields
- hidden fields
- masking
- freshness
- stale indicator
- locale
- i18n keys
- access requirement
- audit if sensitive

Projection is read model, not truth owner.

---

## 16. Evidence Candidate Rule

Evidence candidate should define:

- evidence packet type
- source runtime
- trigger
- required fields
- masked fields
- prohibited fields
- correlation ids
- related event
- related support case if any
- retention placeholder
- access restriction

Evidence proves operation.

Evidence does not approve operation.

---

## 17. Audit Candidate Rule

Audit candidate should define:

- audited action
- actor
- target
- context
- timestamp
- before/after reference if applicable
- correlation id
- session id if applicable
- security relevance
- support relevance
- immutability expectation

Audit is append-only history.

---

## 18. I18n Content Candidate Rule

I18n content candidate should define:

- content key
- message key
- source locale
- target locales
- audience
- runtime reference
- fallback locale
- translation status
- review status
- version
- external publish eligibility
- source document reference

I18n content is foundation data.

---

## 19. Menu Content Candidate Rule

Menu content candidate should define:

- menu item key
- category
- display name
- short description
- long description
- ingredient summary
- allergen indicators
- dietary indicators
- spice/temperature note
- image/alt text reference
- locale versions
- external projection eligibility
- review status
- version

Menu content is public-facing safety and sales data.

---

## 20. SOP Parsing Data Candidate Rule

SOP parsing candidate should define:

- SOP key
- source document
- source section
- source locale
- runtime references
- audience
- condition
- action
- prohibited result
- recovery action
- message key
- training key
- evidence requirement
- target locales

SOP parser data must preserve operational meaning.

---

## 21. Error Message Data Candidate Rule

Error message data candidate should define:

- full error code
- short error code
- system
- module
- process
- program
- event
- severity
- audience
- locale
- message key
- recovery action
- support action
- evidence link if any
- audit link if any
- safe variables

Error message is a traceable runtime data object.

---

## 22. Payment Data Candidate Rule

Payment data candidate should define:

- payment attempt
- provider reference
- payment state
- payment event
- idempotency candidate
- duplicate/stale marker
- reconciliation status
- evidence packet
- refund/cancel linkage
- support linkage
- customer-facing message key
- security sensitivity

Payment data must protect money truth.

---

## 23. Refund Cancel Data Candidate Rule

Refund/cancel data candidate should define:

- refund request
- cancel request
- review status
- decision status
- reason candidate
- payment linkage
- KDS linkage
- support case linkage
- evidence packet
- audit requirement
- customer message key

Refund/cancel must not be vague.

---

## 24. KDS Data Candidate Rule

KDS data candidate should define:

- KDS ticket
- ticket state
- item state
- hold/release marker
- preparation status
- ready/served status
- remake/retry marker
- duplicate/stale marker
- payment dependency marker
- evidence packet
- staff message key

KDS data owns kitchen execution, not payment.

---

## 25. POS Data Candidate Rule

POS data candidate should define:

- POS accepted order reference
- POS transaction reference
- POS status
- rejection reason candidate
- reconciliation status
- provider mapping candidate
- receipt/ledger reference candidate
- evidence output
- error message key
- support linkage

POS data owns transaction boundary.

---

## 26. Provider Mapping Data Candidate Rule

Provider mapping candidate should define:

- provider name
- provider event id
- provider event type
- raw event sensitivity
- normalized event candidate
- idempotency key candidate
- duplicate/stale classification
- mapping status
- quarantine status
- evidence packet
- provider incident linkage

Provider data is candidate until validated.

---

## 27. Mini Kiosk Data Candidate Rule

Mini Kiosk data candidate should define:

- kiosk session
- device context
- customer interaction state
- locale
- cart candidate
- timeout marker
- abandoned flow marker
- payment attempt linkage
- staff call linkage
- evidence packet
- message keys

Mini Kiosk data is interaction data, not payment truth.

---

## 28. Support Case Data Candidate Rule

Support case candidate should define:

- case id candidate
- case type
- customer context reference
- store context reference
- order/payment/KDS/provider reference if applicable
- masked default view
- support notes
- escalation status
- evidence links
- audit links
- closure status
- customer message keys

Support data must remain case-scoped.

---

## 29. Admin Data Candidate Rule

Admin data candidate should define:

- task queue item
- review request
- blocker item
- approval workflow candidate
- dashboard projection
- evidence link
- audit link
- role/context permission
- visible fields
- prohibited actions
- i18n labels

Admin data coordinates workflow.

---

## 30. Security Access Data Candidate Rule

Security/access data candidate should define:

- actor
- role
- context
- permission candidate
- session trust
- device trust
- masking policy
- export/unmask request
- break-glass record if applicable
- audit requirement
- expiration or scope limit

Security data defines access boundary.

---

## 31. AI Support Gateway Data Candidate Rule

AI support gateway data candidate should define:

- AI request
- requester context
- support case scope
- masked context reference
- source set
- freshness
- confidence
- response candidate
- human review status
- audit/access log
- prohibited action marker

AI support data must not mutate runtime truth.

---

## 32. pgvector RAG Data Candidate Rule

pgvector/RAG candidate should define:

- source document key
- content key
- chunk candidate
- embedding source status
- access scope
- freshness metadata
- citation reference
- sensitive data exclusion
- locale
- audience
- retrieval status

RAG source must be approved before indexing.

---

## 33. External Menu Projection Data Candidate Rule

External projection candidate should define:

- public store key
- public menu package
- locale
- menu content version
- allergen/diet indicators
- price display if approved
- Google Maps landing package
- QR/NFC package
- partner package status
- external publish status
- stale threshold

External projection data must be public-only.

---

## 34. Redtable-Type Partner Data Candidate Rule

Redtable-type partner candidate should define:

- partner capability
- provider evidence status
- menu dataset mapping candidate
- global payment route candidate
- payment method candidate
- settlement report candidate
- support boundary
- security/legal review status
- commercial review status
- rollback status

Partner data remains evidence-required until verified.

---

## 35. Domestic Global Payment Coexistence Data Candidate Rule

Domestic/global payment coexistence candidate should define:

- domestic payment route
- foreign payment route
- Toss candidate route
- Redtable-type candidate route
- Alipay candidate
- WeChat Pay candidate
- foreign card candidate
- route selection factor
- provider reference
- reconciliation requirement
- settlement evidence

Coexistence data must not distort payment truth.

---

## 36. Pilot Learning Data Candidate Rule

Pilot learning data candidate should define:

- pilot id candidate
- dry run id candidate
- scenario
- participants
- runtime affected
- locale used
- message shown
- incident type
- staff action
- support action
- recovery time
- blocker created
- learning summary

Pilot data becomes future OS improvement input.

---

## 37. Data Sensitivity Classification Rule

Every candidate should classify sensitivity.

Recommended sensitivity classes:

- `PUBLIC_CONTENT`
- `INTERNAL_OPERATIONAL`
- `STORE_CONFIDENTIAL`
- `CUSTOMER_PERSONAL`
- `PAYMENT_SENSITIVE`
- `IDENTITY_SENSITIVE`
- `SECURITY_SENSITIVE`
- `PROVIDER_CONFIDENTIAL`
- `EVIDENCE_RESTRICTED`
- `AUDIT_RESTRICTED`
- `LEGAL_REVIEW_REQUIRED`

Sensitivity drives access and masking.

---

## 38. Access And Masking Planning Rule

Each candidate should identify:

- who can view
- who can edit
- who can request action
- what is masked by default
- what is hidden
- what requires approval
- what is exportable
- what is prohibited from export
- what requires audit

Access planning precedes schema.

---

## 39. Correction And Supersession Rule

Data model planning must support correction and supersession.

Correction planning should consider:

- append-only correction
- superseded content
- deprecated status
- version history
- audit trail
- evidence linkage
- no silent overwrite
- external projection update

Correction is not deletion.

---

## 40. Retention Placeholder Rule

Data model planning should include retention placeholder when content is sensitive.

Retention placeholder applies to:

- support cases
- evidence packets
- audit events
- payment references
- provider events
- AI access logs
- export/unmask requests
- pilot incidents
- high-risk operation records

Final retention policy may be defined later.

---

## 41. Schema Design Readiness Gate Rule

A data model candidate may move toward schema design only when:

- source is known
- runtime owner is known
- entity/relationship/state/event meaning is clear
- sensitivity is classified
- access/masking needs are known
- evidence/audit needs are known
- i18n/content needs are known
- provider/external dependencies are known
- fallback/rollback implication is known
- tests are identified

Schema design without these is blocked.

---

## 42. Schema Design Blocker Rule

Create blocker when:

- runtime owner missing
- entity meaning unclear
- state owner unclear
- event owner unclear
- sensitivity unclassified
- access/masking undefined
- evidence/audit unclear
- i18n requirement ignored
- provider data treated as truth
- external partner data treated as canonical
- AI/RAG source includes sensitive raw data
- correction/versioning missing
- payment/KDS/POS boundaries mixed

Blocker stops schema planning.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      Data_Model_Candidate_Register.md
      Entity_Candidate_Register.md
      Relationship_Candidate_Register.md
      State_Candidate_Register.md
      Event_Candidate_Register.md
      Evidence_Data_Candidate_Register.md
      Audit_Data_Candidate_Register.md
      I18n_Content_Data_Candidate_Register.md
      Menu_Content_Data_Candidate_Register.md
      SOP_Parsing_Data_Candidate_Register.md
      Provider_Mapping_Data_Candidate_Register.md
      AI_RAG_Data_Candidate_Register.md
      External_Menu_Projection_Data_Candidate_Register.md
      Redtable_Partner_Data_Candidate_Register.md
      Schema_Design_Readiness_Blocker_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- designing schema before runtime owner is known
- creating table because UI screen needs a field
- mixing state and event without boundary
- treating provider payload as internal truth
- treating external partner menu as canonical source
- storing sensitive data without sensitivity classification
- indexing raw sensitive data into RAG
- creating hardcoded menu/message data outside i18n registry
- allowing correction by overwrite
- mixing payment, KDS, and POS truth in one ambiguous entity
- skipping evidence/audit planning
- designing Admin mutation data without authority review

---

## 45. No-Code Boundary

This document does not authorize:

- SQL DDL
- migration creation
- database table creation
- enum creation
- view creation
- function creation
- trigger creation
- RLS policy creation
- index creation
- API implementation
- Flutter implementation
- provider connector
- payment integration
- KDS integration
- AI/RAG implementation

This document governs data model planning only.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. What is data model planning?
2. What is schema design readiness?
3. What data model candidate statuses exist?
4. What fields should data model candidate record include?
5. What candidate type values exist?
6. What entity candidate rule applies?
7. What relationship candidate rule applies?
8. What state candidate rule applies?
9. What event candidate rule applies?
10. What command record candidate rule applies?
11. What query projection candidate rule applies?
12. What evidence candidate rule applies?
13. What audit candidate rule applies?
14. What i18n content candidate rule applies?
15. What menu content candidate rule applies?
16. What SOP parsing data candidate rule applies?
17. What error message data candidate rule applies?
18. What payment data candidate rule applies?
19. What refund/cancel data candidate rule applies?
20. What KDS data candidate rule applies?
21. What POS data candidate rule applies?
22. What provider mapping data candidate rule applies?
23. What Mini Kiosk data candidate rule applies?
24. What support case data candidate rule applies?
25. What Admin data candidate rule applies?
26. What security/access data candidate rule applies?
27. What AI Support Gateway data candidate rule applies?
28. What pgvector/RAG data candidate rule applies?
29. What external menu projection data candidate rule applies?
30. What Redtable-type partner data candidate rule applies?
31. What domestic/global payment coexistence data candidate rule applies?
32. What pilot learning data candidate rule applies?
33. What data sensitivity classification rule applies?
34. What access and masking planning rule applies?
35. What correction and supersession rule applies?
36. What retention placeholder rule applies?
37. What schema design readiness gate rule applies?
38. What schema design blocker rule applies?
39. What registers are recommended?
40. What anti-patterns are prohibited?
41. What no-code boundary applies?

If these questions cannot be answered, data model planning and schema design readiness are incomplete.

---

## 47. Conclusion

Data model planning is the bridge between runtime ownership and future schema design.

The safe data planning flow is:

    runtime package
        -> entity candidate
        -> relationship candidate
        -> state/event candidate
        -> sensitivity classification
        -> access/masking planning
        -> evidence/audit planning
        -> i18n/content planning
        -> provider/external dependency planning
        -> correction/versioning planning
        -> schema design readiness gate

This document ensures that future schema work for Customer Session, Table Session, Order, Payment, Refund/Cancel, KDS, POS, Provider Adapter, Mini Kiosk, Support, Admin, Evidence, Audit, Security, I18n Content, Menu Content, SOP Parsing, AI Support Gateway, pgvector/RAG, External Menu Projection, Redtable-type Partner, Commercial, Billing, Pilot, and Documentation Governance follows runtime ownership and does not create uncontrolled data authority.