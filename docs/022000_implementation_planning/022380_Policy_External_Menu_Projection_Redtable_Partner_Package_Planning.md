# 022380_Policy_External_Menu_Projection_Redtable_Partner_Package_Planning

## 1. Purpose

This document defines the planning boundary for external menu projection, Redtable-type partner modules, foreigner-facing menu translation, global payment candidate flows, Google Maps/NFC/QR projection candidates, and partner-side content publishing before controlled implementation begins.

The purpose is to prevent external partners, tourism-facing surfaces, translated menu boards, QR/NFC entry points, Google Maps-linked menu projections, or global payment candidates from becoming unverified runtime authority, untraceable content sources, hardcoded multilingual text, or assumed provider capabilities.

External menu projection must be planned as a controlled content and provider boundary.

No external projection, Redtable-type adapter, global payment bridge, foreign-language menu board, Google Maps-linked menu surface, QR/NFC projection, or partner publishing package may proceed to coding unless its content source, locale, provider evidence, payment boundary, audit rule, rollback rule, and authority boundary are explicitly mapped.

---

## 2. Scope

This policy applies to the following package families:

1. External menu projection
2. QR menu projection
3. NFC menu projection
4. Google Maps-linked menu projection candidate
5. Redtable-type partner projection
6. Foreigner-facing translated menu
7. Tourism-friendly ordering surface
8. Partner-side menu board publishing
9. Multilingual menu content delivery
10. External availability display
11. External allergen and ingredient display
12. External price display
13. External menu image projection
14. Global payment bridge candidate
15. Alipay candidate flow
16. WeChat Pay candidate flow
17. Overseas card candidate flow
18. Partner settlement candidate flow
19. External projection support and rollback

This document does not implement any provider API, Redtable API, Google Maps integration, QR/NFC runtime, payment connector, menu publishing function, translation engine, Flutter/React UI, database schema, or webhook.

Coding remains deferred.

---

## 3. Core Principle

External menu projection is projection.

It is not source of truth.

The internal menu registry, content registry, i18n registry, price authority, availability authority, allergen source, and audit lineage remain internal unless a later architecture explicitly changes that authority.

External partners may display, receive, project, route, or assist.

They must not silently become:

- menu authority
- price authority
- availability authority
- translation authority
- allergen authority
- payment settlement authority
- refund authority
- customer identity authority
- content approval authority

Projection must preserve source traceability.

---

## 4. Provider Evidence First Rule

Redtable-type partner capabilities are candidates only until provider evidence is confirmed.

The default status for Redtable-type partner capabilities is:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

No UI, API, adapter, AI response, support message, or business plan document may present the following as confirmed without evidence:

- actual Redtable API availability
- Redtable sandbox access
- Redtable production access
- Alipay support
- WeChat Pay support
- overseas card support
- global payment settlement
- Google Maps-linked projection
- NFC projection
- QR projection
- partner-side menu board publishing
- translation responsibility
- refund responsibility
- customer identity sharing
- data retention terms
- commission model
- settlement timing
- legal/compliance readiness

---

## 5. External Projection Package Planning Rule

Every external projection package must define:

| Field | Required Meaning |
|---|---|
| Package name | Stable planning identifier |
| Projection target | QR, NFC, Google Maps, partner, Redtable-type, etc. |
| Audience | Foreign customer, tourist, partner, customer, staff, support |
| Source authority | Menu registry, content registry, i18n registry, price source |
| Locale | Source locale, target locale, fallback locale |
| Translation source | Human-approved, machine-assisted, provider, blocked |
| Provider | External provider or internal projection layer |
| Provider evidence status | Confirmed, limited, evidence-required, rejected |
| Payment boundary | None, candidate, confirmed, blocked |
| API/RPC dependency | Contract name from API/RPC/Event planning |
| Event dependency | Projection published, failed, stale, rolled back, etc. |
| Audit requirement | Required for publication/change/rollback |
| Rollback rule | Previous version recovery rule |
| Support path | Issue correction/escalation path |
| Coding status | Planned only / blocked / ready later |

---

## 6. Content Source Boundary

External projection content must come from controlled sources.

Allowed source families:

- `MENU_REGISTRY_CONTENT`
- `CONTENT_REGISTRY_ENTRY`
- `I18N_MESSAGE_KEY`
- `SOP_CONTENT_KEY`
- `ALLERGEN_SOURCE`
- `PRICE_SOURCE`
- `AVAILABILITY_SOURCE`
- `IMAGE_SOURCE`
- `PROVIDER_EVIDENCE_LABEL`
- `APPROVED_TRANSLATION_SOURCE`

External projection must not use free-form menu text, manually pasted translations, unapproved partner edits, or AI-generated operational descriptions without registry linkage.

---

## 7. Menu Registry Boundary

External menu projection must preserve menu registry identity.

Projected menu content must include or preserve:

- menu item id
- menu version
- content registry key
- display name key
- description key
- option group key
- modifier key
- allergen reference
- ingredient reference
- price reference
- availability reference
- image reference
- effective date
- published version
- rollback version
- locale
- audience
- projection target

The external projected menu must be reproducible from internal sources.

---

## 8. Price Boundary

External price projection must preserve price authority.

Planning must define:

- internal price source
- tax/VAT display rule
- service charge display rule if any
- currency
- currency conversion rule if any
- provider fee display rule if any
- promotion/discount source
- price effective time
- stale price fallback
- rollback rule
- customer-facing message key

External partners must not independently modify price unless a later explicit contract permits partner pricing authority.

Global payment candidates must not imply dynamic currency conversion unless provider evidence confirms it.

---

## 9. Availability Boundary

External availability projection must preserve internal availability authority.

Availability states may include:

- `AVAILABLE`
- `LIMITED`
- `SOLD_OUT`
- `TEMPORARILY_UNAVAILABLE`
- `TIME_WINDOW_CLOSED`
- `STORE_CLOSED`
- `PROJECTION_STALE`
- `AVAILABILITY_UNKNOWN`
- `PROVIDER_SYNC_DELAYED`

External projection must not show unavailable menu items as orderable unless the internal availability source allows it.

Stale availability must be visible to staff/support/admin surfaces.

---

## 10. Allergen And Ingredient Boundary

Allergen and ingredient projection must be treated as safety-sensitive content.

External allergen/ingredient text must come from approved registry sources.

AI, provider, or partner translation must not invent or omit allergen information.

Planning must define:

- allergen source
- ingredient source
- locale
- approved translation status
- safety disclaimer key if needed
- missing allergen fallback
- review requirement
- audit requirement for changes

If allergen translation is not approved, external projection must be blocked or marked unavailable according to policy.

---

## 11. Translation Boundary

Foreigner-facing menu translation must preserve content authority.

Translation source states:

| State | Meaning |
|---|---|
| `TRANSLATION_NOT_PLANNED` | No translation planned |
| `TRANSLATION_REQUIRED` | Translation needed before projection |
| `TRANSLATION_MACHINE_DRAFT` | Machine draft only, not approved |
| `TRANSLATION_HUMAN_REVIEW_REQUIRED` | Requires review |
| `TRANSLATION_APPROVED` | Approved for target audience |
| `TRANSLATION_PROVIDER_EVIDENCE_REQUIRED` | Provider translation capability unverified |
| `TRANSLATION_BLOCKED` | Must not be projected |

Default for safety, allergen, payment, refund, and legal text should require approved translation before customer-facing use.

---

## 12. AI Translation Boundary

AI may assist with translation only as a draft or support layer unless explicitly approved.

AI may:

- draft menu translation
- suggest foreigner-friendly explanation
- flag missing cultural context
- identify untranslated keys
- propose glossary candidates
- summarize differences between source and target language

AI must not:

- approve translations
- alter allergen meaning
- invent ingredients
- invent cooking methods
- invent health claims
- invent provider capability
- publish external projection
- bypass content registry
- bypass human review where required

AI translation output must remain traceable to source content keys.

---

## 13. Redtable-Type Partner Boundary

Redtable-type partner modules are planning candidates for foreigner-facing menu projection and global payment bridge.

Candidate capabilities include:

- foreigner menu translation
- multilingual menu display
- external menu projection
- QR menu entry
- NFC menu entry
- Google Maps-linked discovery
- tourism-friendly ordering surface
- partner-side menu board projection
- global payment bridge candidate
- Alipay candidate support
- WeChat Pay candidate support
- overseas card candidate support

All candidate capabilities remain evidence-required until confirmed by provider documentation, agreement, sandbox, or production test.

Default state:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 14. Google Maps Projection Candidate Boundary

Google Maps-linked menu projection is a candidate capability.

Planning must not assume:

- direct menu API access
- partner-side Google Maps integration
- Google Business Profile write access
- menu deep link support
- ordering deep link support
- availability sync
- price sync
- translation sync
- image sync
- review/ratings linkage
- customer identity sharing

Google Maps-related capability must remain evidence-required until confirmed.

Any public map-linked projection must preserve menu source, version, locale, price, availability, and rollback trace.

---

## 15. NFC/QR Projection Boundary

NFC and QR projection must be treated as entry and projection surfaces, not authority sources.

NFC/QR may route users to:

- menu surface
- waiting session
- order preparation surface
- table join surface
- multilingual menu surface
- partner projection surface
- payment candidate surface if confirmed

NFC/QR must preserve:

- store context
- table or location context if applicable
- session context
- locale preference
- projection version
- content source
- provider status
- fallback URL or fallback instruction

NFC/QR text must use i18n/content keys.

---

## 16. Global Payment Candidate Boundary

Global payment through Redtable-type or other partners is candidate-only unless evidence is confirmed.

Candidate payment methods may include:

- overseas cards
- Alipay
- WeChat Pay
- UnionPay
- Apple Pay
- Google Pay
- tourism-friendly payment flow
- dynamic currency display
- foreign receipt language support

Each method must be separately verified.

No global payment method may be shown as available until provider evidence confirms:

- supported country
- supported currency
- settlement account
- refund flow
- chargeback/dispute responsibility
- payment fee
- payout timing
- tax/reporting impact
- customer data handling
- compliance boundary

---

## 17. Payment And Projection Separation

External menu projection and external payment are separate capabilities.

A partner may support menu projection but not payment.

A partner may support payment but not menu authority.

A partner may support translation but not settlement.

Planning must avoid bundling unconfirmed capabilities.

Projection package status and payment package status must be tracked separately.

---

## 18. Customer Identity Boundary

External projection must define customer identity behavior.

Possible identity modes:

- anonymous viewer
- anonymous order session
- internal customer account
- partner customer identity
- linked identity
- temporary tourism session
- payment-only identity
- no identity sharing

Customer identity sharing with external partners must remain blocked until legal/privacy/provider evidence is reviewed.

Customer identity from 캐치메뉴 or internal membership must not be shared externally by default.

---

## 19. Data Sharing Boundary

External projection packages must identify what data leaves the system.

Data categories include:

- store name
- store location
- opening hours
- menu names
- menu descriptions
- menu prices
- menu images
- availability
- allergens
- ingredients
- order session data
- customer language preference
- customer identity
- payment intent metadata
- device/session metadata
- support case data

Data minimization is required.

Sensitive or unnecessary data must not be sent to external providers.

---

## 20. Publication Boundary

External projection publication must be an auditable action.

Publication planning must define:

- publisher actor
- approval status
- source version
- target provider
- target locale
- target audience
- publication timestamp
- previous version
- rollback version
- provider response
- failure state
- stale state
- audit event

External publication must not be an untracked background side effect.

---

## 21. Rollback Boundary

Every external projection package must define rollback behavior.

Rollback planning must identify:

- last known good version
- rollback trigger
- rollback actor
- rollback approval requirement
- rollback event
- rollback audit
- customer-facing fallback message
- provider rollback limitation
- manual correction path

If provider rollback is not supported, this must be marked as evidence-required or limited.

---

## 22. Staleness Boundary

External projection may become stale.

Stale states include:

- menu content stale
- price stale
- availability stale
- translation stale
- image stale
- provider sync delayed
- publication failed
- rollback pending
- provider unavailable
- unknown projection state

Staleness must be visible to staff/support/admin surfaces.

Customer-facing stale handling must use approved i18n/content keys.

---

## 23. Support Boundary

External projection support must handle issues such as:

- mistranslation
- missing allergen
- wrong price
- sold-out item still displayed
- wrong image
- QR/NFC broken link
- Google Maps link issue
- partner projection not updated
- payment method incorrectly shown
- foreign customer misunderstanding
- provider callback failure

Support workflow must trace the issue to source registry, projection version, provider response, and audit lineage.

Support must not directly edit external content without controlled publication authority.

---

## 24. Audit Boundary

Audit is required for:

- external projection publication
- external projection rollback
- external projection provider status change
- translation approval
- allergen/ingredient external text change
- price projection change
- global payment capability status change
- partner API credential use
- provider callback processing
- external support correction
- customer identity sharing approval
- data export to partner

Audit must identify actor, source version, target provider, target locale, action, result, evidence, and rollback relationship.

---

## 25. Security Boundary

External projection and partner adapters must define security requirements before implementation.

Planning must include:

- provider authentication method
- API credential storage
- request signing if required
- webhook signature verification if any
- rate limit
- IP allowlist if any
- production/sandbox separation
- credential rotation
- least privilege
- secret exposure prevention
- provider access revocation
- audit of credential use

Secrets must not appear in UI, mobile apps, public repositories, documentation examples, prompts, or content registry entries.

---

## 26. Provider Capability Registry Boundary

Provider capability must be tracked in a controlled registry or equivalent planning artifact.

Capability registry entries must include:

- provider
- capability family
- status
- evidence source
- evidence date
- limitation
- commercial condition
- technical condition
- security condition
- locale/currency/country condition
- support responsibility
- fallback behavior
- review owner
- next review date

A capability registry entry does not implement the capability.

It only controls planning status.

---

## 27. External Projection Naming Rule

External projection package planning identifiers should follow:

`projection.<target>.<purpose>.<version>`

or:

`partner.<provider>.<capability>.<version>`

Examples:

- `projection.qr.menu_multilingual.v1`
- `projection.nfc.menu_entry.v1`
- `projection.google_maps.menu_candidate.v1`
- `projection.partner.menu_board.v1`
- `partner.redtable.menu_projection.v1`
- `partner.redtable.translation_candidate.v1`
- `partner.redtable.global_payment_candidate.v1`
- `partner.redtable.alipay_candidate.v1`
- `partner.redtable.wechatpay_candidate.v1`
- `partner.redtable.overseas_card_candidate.v1`

These identifiers are planning names only.

They do not imply implementation exists.

---

## 28. External Projection Readiness Levels

Each external projection or partner package must have a readiness status.

| Status | Meaning |
|---|---|
| `PROJECTION_IDEA` | Candidate only |
| `PROJECTION_PLANNED` | Boundary described |
| `PROJECTION_CONTENT_REQUIRED` | Content registry/menu registry source incomplete |
| `PROJECTION_TRANSLATION_REQUIRED` | Translation not ready |
| `PROJECTION_I18N_REQUIRED` | Message/content keys missing |
| `PROJECTION_PROVIDER_EVIDENCE_REQUIRED` | Provider support not confirmed |
| `PROJECTION_PAYMENT_EVIDENCE_REQUIRED` | Payment capability not confirmed |
| `PROJECTION_SECURITY_REVIEW_REQUIRED` | Security boundary incomplete |
| `PROJECTION_AUDIT_REQUIRED` | Audit/rollback lineage incomplete |
| `PROJECTION_ROLLBACK_REQUIRED` | Rollback rule incomplete |
| `PROJECTION_READY_FOR_IMPLEMENTATION_PLANNING` | Ready for package planning, not coding |
| `PROJECTION_CODING_ALLOWED` | Only after explicit coding entry approval |

Default status for Redtable-type partner capabilities:

`PROJECTION_PROVIDER_EVIDENCE_REQUIRED`

Coding is not allowed by this document.

---

## 29. Prohibited External Projection Shortcuts

The following are prohibited:

1. Treating external projection as menu source of truth
2. Publishing unapproved menu text
3. Publishing unapproved allergen translation
4. Publishing hardcoded foreign-language menu text
5. Presenting Redtable API as available without evidence
6. Presenting Alipay as available without evidence
7. Presenting WeChat Pay as available without evidence
8. Presenting overseas card support without evidence
9. Assuming Google Maps menu sync without evidence
10. Assuming NFC/QR provider capability without evidence
11. Sending customer identity to partner without review
12. Allowing partner to modify price without authority
13. Allowing partner translation to override registry
14. Publishing without audit
15. Publishing without rollback plan
16. Hiding stale projection state
17. Exposing provider secrets in UI/docs/prompts
18. Mixing projection and payment capability status
19. AI inventing menu descriptions, allergens, or provider support
20. Coding partner adapter before evidence and security review

---

## 30. Minimum External Projection Planning Checklist

Before any external projection or Redtable-type partner package proceeds, the following must be answered:

- What projection target is being planned?
- Who is the audience?
- What internal source is the authority?
- What content registry keys are required?
- What menu registry keys are required?
- What i18n message keys are required?
- What locale and fallback rules apply?
- What translation approval status applies?
- What provider is involved?
- What provider evidence exists?
- What remains evidence-required?
- What payment capability is claimed?
- What payment evidence exists?
- What customer identity mode applies?
- What data leaves the system?
- What publication event is emitted?
- What audit event is required?
- What rollback rule exists?
- What stale state behavior applies?
- What support path exists?
- What security review is required?
- What coding entry status applies?

If any answer is missing, the package remains planning-only.

---

## 31. Relationship To Previous Documents

This document follows:

- `docs/022000_implementation_planning/022023_Index_Controlled_Implementation_Planning_README_And_Package_Decomposition.md`
- `docs/022000_implementation_planning/022024_Policy_Runtime_Package_Decomposition_And_Module_Boundary_Planning.md`
- `docs/022000_implementation_planning/022025_Policy_Data_Model_Planning_Boundary_And_Schema_Design_Readiness.md`
- `22330 API RPC Event Contract Planning Boundary Policy`
- `22340 UI Implementation Package Planning And I18n Surface Mapping Policy`
- `22350 Payment KDS Provider Adapter Package Planning Policy`
- `22360 Support Admin Evidence Audit Package Planning Policy`
- `22370 AI Support Gateway pgvector RAG Package Planning Policy`

This document prepares the boundary for:

- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`

---

## 32. Final Rule

External menu projection and Redtable-type partner modules are content, provider, payment, translation, and audit-sensitive boundaries.

At this stage, the correct output is not a Redtable adapter, Google Maps integration, QR/NFC runtime, global payment connector, or multilingual menu board.

The correct output is a controlled external projection package map that preserves internal source of truth, content registry authority, i18n keys, translation approval, provider evidence status, payment capability separation, customer identity protection, publication audit, rollback, staleness handling, and no-assumption rules.

Coding remains deferred until content readiness, translation readiness, provider evidence, payment evidence, security review, audit lineage, rollback planning, and explicit package entry gates are approved.
