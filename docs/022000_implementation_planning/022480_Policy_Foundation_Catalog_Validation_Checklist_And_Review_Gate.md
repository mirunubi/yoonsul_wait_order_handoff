# 022480_Policy_Foundation_Catalog_Validation_Checklist_And_Review_Gate

## 1. Purpose

This document defines the validation checklist and review gate policy for foundation catalog artifacts.

The purpose is to ensure that foundation catalogs, registries, maps, readiness inventories, handoff records, work orders, guardrails, and boundary test plans are reviewed consistently before any package can move toward controlled coding entry.

This document follows the metadata requirements defined in `22470`.

A foundation artifact is not considered ready merely because it exists.

It must pass validation.

This document does not authorize coding.

Coding remains deferred unless a package-specific `CODING_ALLOWED` decision, completed handoff record, narrow work order, allowed file scope, required tests, and review approval exist.

---

## 2. Scope

This policy applies to validation and review gates for:

1. Locale and audience catalogs
2. Status value catalogs
3. Provider capability registries
4. i18n message catalogs
5. Error message key catalogs
6. Content registry catalogs
7. SOP traceability catalogs
8. Contract catalogs
9. Event family catalogs
10. Audit event catalogs
11. Evidence packet catalogs
12. Security visibility catalogs
13. Degraded state catalogs
14. AI source/output catalogs
15. External projection status catalogs
16. Readiness inventories
17. Blocker inventories
18. Handoff records
19. Work orders
20. Implementation result records
21. Guardrail plans
22. Boundary test plans

This policy does not validate runtime implementation code.

Runtime implementation remains deferred.

---

## 3. Core Principle

Validation must prove boundary discipline.

A foundation artifact must prove that it does not accidentally create:

- runtime authority
- provider assumption
- hardcoded operational string
- untraceable content
- unaudited action
- unsupported locale behavior
- unmasked data visibility
- AI authority drift
- external projection authority drift
- coding permission without decision

Validation is not a style review only.

It is a boundary review.

---

## 4. Validation Gate Types

Foundation artifacts must pass relevant validation gates.

| Gate | Applies To | Required Meaning |
|---|---|---|
| Header Gate | All artifacts | Required metadata exists |
| Status Gate | All artifacts | Status values are controlled |
| Runtime Authority Gate | All artifacts | Runtime mutation is absent or deferred |
| Dependency Gate | Catalogs/maps | Required dependencies are declared |
| i18n Gate | Visible text artifacts | Message/content key discipline exists |
| Content Gate | Content artifacts | Source traceability exists |
| Provider Evidence Gate | Provider artifacts | Evidence-required default is preserved |
| Audit Gate | Authority/evidence artifacts | Audit family linkage exists |
| Evidence Gate | Evidence artifacts | Source and integrity states exist |
| Security Gate | Data/access artifacts | Masking and data visibility are declared |
| AI Gate | AI artifacts | AI remains assistance only |
| Projection Gate | External projection artifacts | Projection remains non-authoritative |
| Handoff Gate | Handoff/work orders | Allowed and prohibited scope is explicit |
| Test Gate | Guardrail/test artifacts | Boundary tests/checks are defined |

Missing applicable gate means the artifact remains blocked.

---

## 5. Header Validation Checklist

Every artifact must include the required header fields.

Minimum checklist:

| Check | Required Result |
|---|---|
| Document ID exists | Must be present |
| Package ID exists | Must be present |
| Artifact Type exists | Must use controlled value |
| Version exists | Must be present |
| Planning Status exists | Must use controlled value |
| Coding Status exists | Must use controlled value |
| Runtime Authority exists | Must use controlled value |
| Owner exists | Must be declared |
| Dependencies exist | Must be declared, even if `NONE` |
| Related Documents exist | Must include relevant prior docs |
| Review Requirement exists | Must be declared |
| Blocker Status exists | Must be declared |

If any required header field is missing, the artifact is invalid for handoff.

---

## 6. Coding Status Validation

Every artifact must declare coding status.

Allowed values:

- `CODING_DEFERRED`
- `ENTRY_REVIEW_REQUIRED`
- `CODING_ALLOWED`
- `CODING_BLOCKED`
- `RUNTIME_SCOPE_PROHIBITED`

Default value:

`CODING_DEFERRED`

`CODING_ALLOWED` is valid only when all of the following exist:

1. package-specific entry decision
2. completed handoff record
3. narrow work order
4. allowed file scope
5. prohibited file scope
6. required tests/checks
7. review approval

If any of these are missing, `CODING_ALLOWED` is invalid.

---

## 7. Runtime Authority Validation

Foundation artifacts must not carry runtime authority unless explicitly deferred or prohibited.

Allowed values:

- `NONE`
- `CATALOG_ONLY`
- `READINESS_TRACKING_ONLY`
- `HANDOFF_CONTROL_ONLY`
- `TEST_PLANNING_ONLY`
- `RUNTIME_AUTHORITY_DEFERRED`
- `RUNTIME_AUTHORITY_PROHIBITED`

Invalid conditions:

- artifact mutates runtime state
- artifact calls provider APIs
- artifact creates customer-facing automation
- artifact publishes external content
- artifact executes refunds
- artifact creates KDS tickets
- artifact grants unmasking access
- artifact finalizes settlement
- artifact stores secrets

If runtime authority exists, the artifact is not foundation-only and must be deferred to later runtime entry review.

---

## 8. Dependency Validation

Every artifact must declare dependencies.

Dependency validation must check:

- dependency is listed
- dependency exists or is explicitly planned
- dependency order matches `22450`
- undefined status values are not referenced
- undefined locale/audience values are not referenced
- undefined provider capability states are not referenced
- undefined i18n key families are not referenced
- undefined content key families are not referenced
- undefined audit/evidence families are not referenced
- undefined visibility classes are not referenced
- undefined degraded states are not referenced

A dependency violation blocks handoff.

---

## 9. Status Value Validation

Controlled statuses must not be ambiguous.

Prohibited vague values include:

- `ok`
- `done`
- `active`
- `ready`
- `maybe`
- `normal`
- `pending` without family context
- `success` without domain context
- `failed` without domain context

Status values must be domain-specific when authority matters.

Examples:

- `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`
- `TRANSLATION_HUMAN_REVIEW_REQUIRED`
- `READINESS_BLOCKED_PROVIDER_EVIDENCE`
- `ENTRY_ALLOWED_LIMITED_FOUNDATION`
- `AI_HUMAN_REVIEW_REQUIRED`
- `PROJECTION_ROLLBACK_REQUIRED`

Status naming must prevent operational ambiguity.

---

## 10. i18n Validation

Any artifact involving visible text must pass i18n validation.

Checklist:

| Check | Required Result |
|---|---|
| Locale scope declared | Required |
| Audience scope declared | Required |
| Message key family declared | Required |
| Fallback rule declared | Required |
| Translation status declared | Required |
| Hardcoded operational text risk declared | Required |
| Runtime-visible text uses keys | Required |
| Customer/staff/support/partner wording separated | Required where applicable |
| Error/payment/KDS/support messages use keys | Required where applicable |

Hardcoded operational strings remain prohibited.

---

## 11. Content Registry Validation

Any artifact involving runtime content must pass content registry validation.

Checklist:

| Check | Required Result |
|---|---|
| Content family declared | Required |
| Content key family declared | Required |
| Source traceability declared | Required |
| Locale declared | Required |
| Audience declared | Required |
| Approval status declared | Required |
| Runtime boundary declared | Required |
| Version/effective date declared where applicable | Required |
| Rollback rule declared where publishable | Required |

Markdown and SOP documents may be sources only when traceability is preserved.

Runtime content must not be copied directly into code.

---

## 12. SOP Traceability Validation

SOP-related artifacts must preserve parser metadata.

Checklist:

- source document id exists
- source section id exists
- source version exists
- locale exists
- audience exists
- runtime boundary exists
- authority boundary exists
- actionability level exists
- evidence requirement exists
- fallback condition exists
- content registry linkage exists
- approval status exists

SOP text must not become executable authority.

SOP guidance supports decisions.

It does not grant runtime permission.

---

## 13. Provider Evidence Validation

Provider-related artifacts must preserve evidence-required defaults.

Checklist:

| Check | Required Result |
|---|---|
| Provider declared | Required |
| Capability family declared | Required |
| Capability status declared | Required |
| Evidence source declared | Required |
| Evidence date declared or marked missing | Required |
| Evidence owner declared or marked TBD | Required |
| Limitations declared | Required where applicable |
| Review status declared | Required |
| Default unverified state preserved | Required |

Default unverified state:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

No provider capability may be marked confirmed without attached or referenced evidence.

---

## 14. Redtable-Type Capability Validation

Redtable-type partner artifacts must validate each capability separately.

Separate validation is required for:

- Redtable API availability
- sandbox access
- production access
- menu projection API
- translation responsibility
- Google Maps-linked projection
- QR capability
- NFC capability
- Alipay support
- WeChat Pay support
- overseas card support
- global settlement
- refund responsibility
- customer identity sharing
- data retention
- commission model
- support responsibility
- legal/compliance readiness

Bundled approval is prohibited.

Each capability defaults to:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 15. Audit Validation

Audit-related artifacts must pass audit validation.

Checklist:

- audit family declared
- actor class declared
- authority marker declared
- target object declared
- evidence link declared
- reason code family declared
- review requirement declared
- override/backup authority marker exists where applicable
- restricted data view audit exists where applicable
- export/report audit exists where applicable

Audit is accountability.

It must not be collapsed into vague logging.

---

## 16. Evidence Validation

Evidence-related artifacts must pass evidence validation.

Checklist:

- evidence family declared
- source class declared
- integrity state declared
- runtime domain declared
- masking status declared
- review status declared
- audit link declared
- original vs derived distinction exists
- AI summary is marked derived
- disputed/unverified state exists where applicable

Evidence does not equal approval.

Evidence packet existence does not grant action authority.

---

## 17. Security And Masking Validation

Security-related artifacts must pass security validation.

Checklist:

- data class declared
- visibility class declared
- masking rule declared
- restricted data marker declared
- provider diagnostic marker declared where applicable
- evidence-only marker declared where applicable
- legal review marker declared where applicable
- export restriction declared where applicable
- secret risk declared
- provider data sharing declared where applicable
- customer identity sharing blocked unless reviewed

Foundation artifacts must not contain secrets or credential-like values.

---

## 18. AI Validation

AI-related artifacts must pass AI boundary validation.

Checklist:

- AI use case declared
- allowed source classes declared
- blocked source classes declared
- output state declared
- human review requirement declared
- traceability requirement declared
- masking rule declared
- customer-facing status declared
- provider evidence notice state exists
- AI authority limits declared

AI must remain assistance only.

AI must not approve, execute, mutate, reconcile, publish, or invent provider capability.

---

## 19. External Projection Validation

External projection artifacts must pass projection validation.

Checklist:

- projection target declared
- source authority declared
- locale declared
- translation status declared
- provider capability status declared
- payment capability status declared where applicable
- publication status declared
- rollback rule declared
- customer identity mode declared
- data sharing rule declared
- stale projection state declared
- support correction path declared

External projection remains projection only.

It must not become source of truth.

---

## 20. Handoff Validation

Handoff records must pass handoff validation.

Checklist:

- handoff id exists
- package id exists
- decision id exists
- allowed scope exists
- excluded scope exists
- allowed files listed
- prohibited files listed
- runtime authority exclusion stated
- i18n/content rule stated
- provider rule stated where applicable
- audit/evidence rule stated
- security rule stated
- test requirement stated
- review requirement stated
- coding status stated

A handoff without allowed and prohibited file scope is invalid.

---

## 21. Work Order Validation

Work orders must pass work order validation.

Checklist:

- work order id exists
- package id exists
- decision id exists
- handoff id exists
- task goal exists
- non-goals exist
- allowed files exist
- prohibited files exist
- expected output exists
- acceptance criteria exist
- tests/checks exist
- rollback expectation exists
- review checklist exists
- coding status exists

A work order without non-goals is incomplete.

A work order without prohibited scope is unsafe.

---

## 22. Implementation Result Validation

Implementation result records must pass result validation.

Checklist:

- result id exists
- work order id exists
- handoff id exists
- package id exists
- files changed listed
- tests run listed
- result status declared
- scope deviations declared
- blockers found declared
- review status declared
- merge status declared

No implementation result should be undocumented.

---

## 23. No-Hardcoded-String Validation

The no-hardcoded-string guardrail must validate future runtime-visible surfaces.

Surfaces include:

- UI
- API responses
- RPC errors
- support/admin messages
- payment statuses
- refund statuses
- KDS statuses
- degraded instructions
- AI customer responses
- external projection text
- provider capability labels
- training/SOP guidance

Any runtime-visible operational text must resolve through i18n message keys or content registry keys.

---

## 24. Secret Exposure Validation

Foundation validation must check that no secret-like values appear in foundation artifacts.

Prohibited examples include:

- API keys
- provider secrets
- webhook secrets
- JWT secrets
- private keys
- database passwords
- service role keys
- OAuth client secrets
- production credentials
- sandbox credentials if sensitive
- real customer payment tokens

Secrets must not appear in docs, prompts, catalogs, tests, examples, or handoff records.

---

## 25. Boundary Test Validation

Boundary test planning artifacts must define tests/checks for:

- catalog id uniqueness
- required header presence
- status value validity
- provider evidence default status
- no confirmed provider capability without evidence
- no hardcoded operational strings
- no missing i18n key family
- no missing content key family
- no package marked coding-ready with blockers
- runtime authority absent in foundation artifacts
- audit family reference validity
- evidence class reference validity
- visibility class reference validity
- degraded state reference validity
- AI customer-ready output restriction
- external projection rollback requirement

A foundation package that cannot define tests/checks should not enter coding.

---

## 26. Review Gate Outcome Values

Each artifact review must produce one of the following outcomes:

| Outcome | Meaning |
|---|---|
| `REVIEW_NOT_STARTED` | No review performed |
| `REVIEW_PASSED_PLANNING_ONLY` | Valid as planning artifact only |
| `REVIEW_PASSED_ENTRY_CANDIDATE` | May move to entry decision review |
| `REVIEW_BLOCKED_METADATA` | Header/metadata incomplete |
| `REVIEW_BLOCKED_DEPENDENCY` | Dependency missing |
| `REVIEW_BLOCKED_I18N` | i18n requirement incomplete |
| `REVIEW_BLOCKED_CONTENT` | Content traceability incomplete |
| `REVIEW_BLOCKED_PROVIDER_EVIDENCE` | Provider evidence missing |
| `REVIEW_BLOCKED_AUDIT` | Audit metadata incomplete |
| `REVIEW_BLOCKED_EVIDENCE` | Evidence metadata incomplete |
| `REVIEW_BLOCKED_SECURITY` | Security/masking incomplete |
| `REVIEW_BLOCKED_AI` | AI boundary incomplete |
| `REVIEW_BLOCKED_PROJECTION` | Projection/rollback incomplete |
| `REVIEW_REJECTED_RUNTIME_DRIFT` | Artifact creates runtime authority |
| `REVIEW_REJECTED_SCOPE` | Artifact violates package scope |

Review outcome does not grant coding unless followed by package-specific coding approval.

---

## 27. Validation Table Template

Use the following table for artifact validation.

| Artifact ID | Package ID | Gate | Result | Blocker | Reviewer | Status |
|---|---|---|---|---|---|---|
| `docs/021000_financial_security_monitoring_catalog/021510_Policy_Financial_Event_Alert_Logging_And_Automated_Warning_System.md` | `foundation.locale.audience_catalog.v1` | Header Gate | Pending | Review required | TBD | `REVIEW_NOT_STARTED` |
| `docs/021000_financial_security_monitoring_catalog/021530_Policy_Universal_Integration_Event_Catalog_And_Alert_Family_Index.md` | `foundation.provider.capability_registry.v1` | Provider Evidence Gate | Pending | Evidence default review | TBD | `REVIEW_NOT_STARTED` |

This table is a planning and review artifact.

It does not authorize coding.

---

## 28. Prohibited Validation Shortcuts

The following are prohibited:

1. Treating file existence as validation
2. Treating complete header as full review
3. Treating planning approval as coding approval
4. Skipping provider evidence validation
5. Skipping i18n validation for visible text
6. Skipping content traceability validation
7. Skipping audit validation for authority-bearing artifacts
8. Skipping evidence validation for support/refund/KDS artifacts
9. Skipping security validation for data/access artifacts
10. Skipping AI validation for AI-related artifacts
11. Skipping projection validation for external projection artifacts
12. Marking `CODING_ALLOWED` without decision, handoff, and work order
13. Marking Redtable-type capability confirmed as a bundle
14. Treating tests/checks as optional
15. Allowing runtime authority in foundation artifacts

---

## 29. Relationship To Previous Documents

This document follows:

- `22450 Foundation Catalog Implementation Order And Dependency Policy`
- `22460 Foundation Catalog File Layout And Naming Convention Policy`
- `22470 Foundation Catalog Header Schema And Required Metadata Policy`

This document defines the validation checklist and review gates for foundation artifacts.

It does not authorize coding.

---

## 30. Final Rule

Foundation artifacts must pass validation before they can move toward controlled coding entry.

Validation must prove header completeness, dependency discipline, i18n/content discipline, provider evidence discipline, audit/evidence discipline, security/masking discipline, AI boundary discipline, external projection discipline, handoff/work order completeness, and no runtime authority drift.

Coding remains deferred unless a package-specific `CODING_ALLOWED` decision, completed handoff record, narrow work order, allowed file scope, required tests, and review approval exist.
