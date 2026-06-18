# 022440_Policy_Controlled_Foundation_Implementation_Handoff_And_Work_Order

## 1. Purpose

This document defines the controlled handoff and work order policy for foundation-first implementation packages.

The purpose is to ensure that even when a foundation package is later granted limited coding allowance, implementation does not begin from chat memory, informal intent, or broad interpretation.

Every implementation package must be handed off through a controlled work order that states:

- what is allowed
- what is excluded
- what files may be created or edited
- what runtime authority is prohibited
- what tests must exist
- what blockers remain
- what review is required before merge

This document does not authorize coding by itself.

Coding remains deferred unless a package-specific `CODING_ALLOWED` decision exists.

---

## 2. Scope

This policy applies to foundation-first packages that may later be approved for limited implementation, including:

1. i18n message catalog
2. Locale and audience catalog
3. Content registry catalog
4. SOP traceability catalog
5. Contract catalog
6. Provider capability registry
7. Audit event catalog
8. Evidence packet catalog
9. Visibility and masking catalog
10. Error/message key catalog
11. Degraded state catalog
12. Readiness/blocker inventory
13. Package handoff records
14. No-hardcoded-string guardrail
15. Boundary test planning artifacts

This policy does not apply to runtime-heavy implementation such as payment execution, KDS live integration, support mutation, AI automation, external projection publication, or provider adapters.

Those remain deferred.

---

## 3. Core Principle

A coding decision is not enough.

A package-specific work order must exist before implementation.

The work order must translate the planning boundary into safe, limited, testable execution.

No developer, AI agent, contractor, or future automation may implement from:

- memory
- chat summary
- broad document title
- assumed architecture
- inferred database shape
- provider marketing claim
- UI desire
- customer-facing shortcut

Implementation must follow the work order.

---

## 4. Handoff Requirement

Every package entering implementation must have a handoff record.

The handoff record must include:

| Field | Required Meaning |
|---|---|
| Handoff id | Stable handoff identifier |
| Package id | Package being implemented |
| Coding decision id | Related entry decision |
| Allowed scope | Exact permitted implementation scope |
| Excluded scope | Explicitly prohibited work |
| Files allowed | File paths or folders that may be created/edited |
| Files prohibited | Files/folders that must not be touched |
| Runtime authority | Must state no mutation unless approved |
| i18n/content rule | Required key/catalog behavior |
| Provider rule | Evidence-required defaults |
| Audit/evidence rule | Required catalog linkage |
| Security rule | Secret/data/masking restrictions |
| Test requirement | Required test/check scope |
| Review requirement | Required review before merge |
| Coding status | `CODING_ALLOWED` or `CODING_DEFERRED` |

No handoff record means no coding.

---

## 5. Work Order Requirement

A work order is the execution-level instruction derived from the handoff record.

A work order must define:

- exact task goal
- allowed files
- prohibited files
- expected output
- acceptance criteria
- non-goals
- tests/checks
- rollback expectation
- commit message guidance
- review checklist

A work order must be narrow enough that the implementer cannot accidentally create runtime business authority.

---

## 6. Allowed Work Order Types

Foundation-first work orders may include:

1. Create catalog definition file
2. Create status value catalog
3. Create message key family map
4. Create content key family map
5. Create contract identifier registry
6. Create provider capability status registry
7. Create audit family catalog
8. Create evidence family catalog
9. Create visibility/masking class catalog
10. Create degraded state catalog
11. Create readiness/blocker tracker template
12. Create package handoff template
13. Create validation schema
14. Create non-runtime test fixture
15. Create static guardrail check draft

These work orders must not create runtime mutation behavior.

---

## 7. Prohibited Work Order Types

The following must not be included in a foundation-first work order:

1. Create payment provider adapter
2. Create refund execution function
3. Create settlement allocation runtime
4. Create KDS provider connector
5. Create POS/KDS live bridge
6. Create customer-facing production UI
7. Create support/admin mutation screen
8. Create provider webhook endpoint
9. Create pgvector production table
10. Create embedding pipeline
11. Create production AI prompt/tool
12. Create customer-facing AI response automation
13. Create external menu publisher
14. Create Redtable-type API client
15. Create Google Maps publishing integration
16. Create NFC/QR provider integration
17. Create partner customer identity sharing
18. Create secret storage implementation
19. Create unmasking workflow
20. Create production export/report workflow

Any work order containing these must be rejected or split into later runtime entry review.

---

## 8. Allowed File Scope Rule

The handoff must define allowed file scope.

Allowed file scope may include future folders such as:

- `docs/`
- `catalogs/`
- `metadata/`
- `schemas/`
- `tests/catalog/`
- `tests/guardrails/`
- `tools/validation/`
- `handoff/`
- `readiness/`

The exact project folder may differ, but the work order must specify it.

No implementation may edit unrelated runtime files unless explicitly allowed.

---

## 9. Prohibited File Scope Rule

Foundation-first implementation must not touch runtime-heavy folders unless explicitly approved later.

Prohibited areas may include:

- production payment adapter code
- production KDS adapter code
- production provider SDK code
- production Edge Functions
- production Supabase RPCs
- production customer UI screens
- production support/admin mutation screens
- production AI runtime prompts/tools
- production pgvector runtime migrations
- production external projection publishers
- production secret configuration

If file boundaries are unclear, coding must stop.

---

## 10. Runtime Authority Exclusion

Foundation-first work orders must state that runtime authority is excluded.

The package must not:

- mutate orders
- mutate payments
- mutate refunds
- mutate settlements
- mutate KDS tickets
- mutate support cases
- mutate provider state
- publish external content
- send customer-facing messages
- execute AI decisions
- share customer identity
- unmask restricted data
- call external providers

Catalog creation is allowed only when approved.

Runtime execution remains deferred.

---

## 11. i18n And Content Handoff Rule

Any foundation implementation touching text must preserve the i18n and content registry boundary.

The work order must define:

- message key naming rule
- content key naming rule
- locale field requirement
- audience field requirement
- fallback rule placeholder
- source traceability field
- no hardcoded runtime text rule
- missing key behavior
- validation requirement

The work order must not instruct the implementer to paste operational text directly into runtime UI/API responses.

---

## 12. Provider Capability Handoff Rule

Any provider-related foundation implementation must default unverified capabilities to:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

This applies to:

- Redtable-type API capability
- Alipay
- WeChat Pay
- overseas cards
- global settlement
- Google Maps-linked projection
- QR provider capability
- NFC provider capability
- partner menu publishing
- refund responsibility
- translation responsibility
- customer identity sharing
- data retention
- commission/fee model
- legal/compliance readiness

No work order may mark provider capability as confirmed unless provider evidence is attached to the decision record.

---

## 13. Audit And Evidence Handoff Rule

Any audit/evidence foundation implementation must preserve future accountability.

The work order must define:

- audit family id format
- evidence family id format
- actor marker
- authority marker
- evidence source class
- original vs derived evidence state
- AI summary as derived evidence only
- review status
- correlation field placeholder
- no silent mutation rule

Audit/evidence catalog work must not create runtime audit-triggering actions unless later approved.

---

## 14. Security And Masking Handoff Rule

Any security or masking catalog implementation must preserve least privilege.

The work order must define:

- visibility class
- masking class
- restricted data marker
- provider diagnostic marker
- evidence-only marker
- legal review marker
- export restriction marker
- no secret exposure rule
- no broad admin access rule

Foundation security work may define categories.

It must not grant actual production access.

---

## 15. AI Handoff Rule

Any AI-related foundation implementation must preserve AI as assistance only.

The work order may define:

- source class catalog
- output state catalog
- human review status
- traceability metadata
- masking requirement
- provider evidence notice
- customer-facing approval requirement

The work order must not create:

- production RAG
- production pgvector retrieval
- production chatbot
- automated customer response
- automated support case closure
- refund approval recommendation executor
- external projection publisher

AI remains non-authoritative.

---

## 16. Test Requirement Rule

Every approved foundation work order must include tests or checks appropriate to its scope.

Possible tests/checks:

- catalog id uniqueness
- status value validity
- required field presence
- no missing key family
- no provider capability confirmed without evidence
- no hardcoded operational string in controlled surfaces
- no runtime mutation file touched
- no external provider call introduced
- no secret-like value committed
- no package marked ready with open blocker
- no AI output state marked customer-ready without approval state

If no test/check can be defined, the package should not enter coding.

---

## 17. Acceptance Criteria Rule

Every work order must define acceptance criteria.

Minimum acceptance criteria:

1. Allowed files only were changed.
2. Prohibited runtime files were not changed.
3. Catalog/schema/template matches the planning document.
4. Provider capabilities default to evidence-required where applicable.
5. No hardcoded operational runtime text is introduced.
6. No runtime mutation is introduced.
7. No external provider call is introduced.
8. No secrets are introduced.
9. Required tests/checks pass.
10. Handoff record is updated with result status.

Acceptance must be based on artifacts, not confidence.

---

## 18. Review Requirement Rule

Foundation implementation must be reviewed before merge.

Review must check:

- scope compliance
- file boundary compliance
- no runtime authority drift
- no provider assumption
- no hardcoded operational strings
- no secret exposure
- i18n/content key discipline
- audit/evidence linkage
- security/masking discipline
- test/check result
- handoff record completion

A package must not be merged only because it compiles.

---

## 19. Rollback And Revert Rule

Each work order must be reversible.

Rollback planning must identify:

- files created
- files edited
- catalog values added
- status values added
- tests added
- validation rules added
- how to revert safely
- whether any downstream package depends on it

Foundation catalog changes should be traceable and reversible.

---

## 20. Implementation Result Record

After work order execution, a result record must be created.

Required fields:

| Field | Required Meaning |
|---|---|
| Result id | Stable result identifier |
| Handoff id | Related handoff |
| Package id | Implemented package |
| Work order id | Related work order |
| Files changed | Exact changed files |
| Tests run | Tests/checks performed |
| Result | Passed, failed, partial, reverted |
| Scope deviations | Any deviation from allowed scope |
| Blockers found | New blockers discovered |
| Review status | Pending, approved, rejected |
| Merge status | Not merged, merged, reverted |

No implementation result should be undocumented.

---

## 21. Work Order Naming Rule

Work order identifiers should follow:

`workorder.<package_family>.<purpose>.<version>`

Examples:

- `workorder.foundation.i18n_message_catalog.v1`
- `workorder.foundation.contract_catalog.v1`
- `workorder.foundation.provider_capability_registry.v1`
- `workorder.foundation.audit_event_catalog.v1`
- `workorder.foundation.evidence_packet_catalog.v1`
- `workorder.foundation.visibility_catalog.v1`
- `workorder.foundation.no_hardcoded_string_guard.v1`

These identifiers are planning and execution-control names.

They do not imply broad implementation permission.

---

## 22. Work Order Template

Use the following template for future foundation implementation work orders.

| Field | Value |
|---|---|
| Work order id | `workorder.foundation.example.v1` |
| Package id | `foundation.example.v1` |
| Decision id | `ENTRY-XXXX` |
| Allowed scope | Define exact catalog/template only |
| Excluded scope | Runtime mutation, provider call, UI/API execution |
| Allowed files | List exact files/folders |
| Prohibited files | List exact files/folders |
| Required tests | List required tests/checks |
| Acceptance criteria | List artifact-based criteria |
| Review requirement | Architecture/security/i18n review |
| Coding status | `CODING_ALLOWED` only if explicitly approved |

This template must be filled before coding starts.

---

## 23. Prohibited Handoff Shortcuts

The following are prohibited:

1. Coding without a handoff record
2. Coding without a work order
3. Coding from chat memory
4. Coding from document title alone
5. Editing files outside allowed scope
6. Adding runtime mutation in a foundation package
7. Adding provider calls in a catalog package
8. Adding customer-facing AI automation
9. Adding hardcoded operational strings
10. Marking provider capability confirmed without evidence
11. Committing secrets or credential-like values
12. Creating support/admin mutation paths
13. Publishing external content
14. Treating tests as optional
15. Merging without review
16. Hiding deviations from work order
17. Treating compile success as boundary success

---

## 24. Relationship To Previous Documents

This document follows:

- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`
- `22400 Controlled Implementation Readiness Review And Blocker Inventory Policy`
- `22410 Controlled Coding Entry Candidate Package Selection Policy`
- `22420 Foundation-First Coding Entry Gate And Guardrail Package Policy`
- `22430 Controlled Foundation Coding Entry Decision And Limited Allowance Policy`

This document prepares the project for safe, package-specific, foundation-first implementation handoff.

It does not authorize coding by itself.

---

## 25. Final Rule

A controlled coding entry decision must be followed by a controlled handoff and a narrow work order.

No package may be implemented from memory, broad intent, or informal conversation.

Foundation-first implementation must remain limited to guardrails, catalogs, templates, schemas, and boundary checks.

Runtime mutation, payment execution, KDS integration, support/admin mutation, AI automation, provider adapters, external projection publication, Redtable-type partner integration, and global payment remain deferred until later package-specific entry approval.

Coding is allowed only when a package has:

1. `CODING_ALLOWED` decision,
2. completed handoff record,
3. narrow work order,
4. allowed file scope,
5. required tests/checks,
6. review requirement,
7. no prohibited runtime scope.
