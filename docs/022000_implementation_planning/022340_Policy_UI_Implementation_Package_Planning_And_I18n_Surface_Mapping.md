# 022340_Policy_UI_Implementation_Package_Planning_And_I18n_Surface_Mapping

## 1. Purpose

This document defines the planning boundary for UI implementation packages and i18n surface mapping before controlled implementation begins.

The purpose is to prevent UI screens from becoming hidden sources of runtime authority, hardcoded operational text, provider assumptions, untranslated content, or unaudited actions.

UI planning must identify every surface where a user, staff member, owner, support operator, admin, AI assistant, KDS operator, payment user, or external partner sees or triggers operational behavior.

No UI implementation package may proceed to coding unless its i18n surface, content registry dependency, action authority, and event/audit boundary are explicitly mapped.

---

## 2. Scope

This policy applies to all UI-facing surfaces, including:

1. Customer web app
2. Customer mobile app
3. Staff tablet
4. Staff mobile
5. Owner/admin web
6. HQ admin web
7. Support/admin console
8. KDS display
9. Kitchen fallback screen
10. Payment and split payment surfaces
11. QR/NFC entry surfaces
12. Waiting/seating/order handoff surfaces
13. AI customer support surface
14. Staff training/SOP guidance surface
15. External menu projection preview
16. Partner-facing projection surface
17. Error and degraded operation screens
18. Provider capability warning surfaces

This policy does not define actual Flutter widgets, React components, CSS, routing code, localization files, or UI implementation.

Those remain deferred until coding entry is explicitly approved.

---

## 3. Core Principle

UI is not authority by itself.

UI may display, request, propose, confirm, or submit an action.

The runtime authority must remain in the proper API/RPC/event contract layer.

A button does not create authority.

A screen does not create authority.

A translated label does not create authority.

A UI package must map its authority dependency before it is implemented.

---

## 4. UI Package Planning Rule

Every UI package must define:

| Field | Required Meaning |
|---|---|
| UI package name | Stable planning identifier |
| User surface | Customer, staff, owner, HQ, support, partner, KDS, AI |
| Runtime domain | Waiting, order, payment, KDS, support, content, provider, etc. |
| Authority level | View, request, propose, confirm, execute, approve |
| API/RPC dependency | Contract name from API/RPC/Event planning |
| Event dependency | Required runtime event |
| Audit dependency | Required audit event if any |
| i18n dependency | Message key or content registry key |
| Content source | Registry/SOP/menu/provider evidence |
| Locale requirement | Supported locales and fallback rule |
| Audience | Customer/staff/owner/HQ/support/partner |
| Degraded behavior | Offline, stale, provider unavailable, manual fallback |
| Coding status | Planned only / blocked / ready later |

---

## 5. i18n Foundation Rule

i18n is Foundation-level policy.

All UI text must be resolved through i18n message keys or content registry keys.

Hardcoded operational strings are prohibited.

This applies to:

- screen titles
- buttons
- labels
- tabs
- menu names
- option names
- order status
- payment status
- KDS status
- error messages
- warning banners
- support response templates
- AI-generated customer responses
- staff guidance
- fallback instructions
- onboarding text
- training text
- provider capability notices
- partner projection labels
- external menu descriptions

Developer-only comments may exist in code later, but runtime-visible text must not be hardcoded.

---

## 6. UI Text Source Classification

Every UI-visible text must be classified as one of the following:

| Source Type | Meaning |
|---|---|
| `I18N_MESSAGE_KEY` | Stable UI/system message |
| `CONTENT_REGISTRY_KEY` | Runtime content controlled by registry |
| `MENU_REGISTRY_KEY` | Menu name, option, allergen, description, image, price label |
| `SOP_CONTENT_KEY` | SOP-derived guidance with traceability |
| `TRAINING_CONTENT_KEY` | Staff education/training content |
| `AI_APPROVED_RESPONSE_KEY` | AI response grounded in approved content |
| `PROVIDER_EVIDENCE_LABEL` | Provider-supported label verified by evidence |
| `BLOCKED_TRANSLATION_REQUIRED` | UI cannot proceed until translation/content source exists |

No UI package may classify operational text as free text.

---

## 7. Locale Mapping Rule

Each UI surface must define locale behavior.

Minimum mapping:

- primary locale
- supported locales
- fallback locale
- untranslated content behavior
- provider-supported locale status
- tenant/store-specific locale override
- customer-selected locale behavior
- staff/admin locale behavior
- external projection locale behavior

If a locale is not ready, the UI must not silently display a wrong or mixed-language operational message.

Fallback must be explicit.

---

## 8. Audience Mapping Rule

The same runtime fact may require different text for different audiences.

Audience must be mapped separately for:

1. Customer
2. Staff
3. Kitchen/KDS
4. Store owner
5. HQ operator
6. Support operator
7. AI support gateway
8. External partner
9. Foreign tourist/customer
10. Provider callback/admin review

Example:

A payment failure may require:

- simple customer message
- staff recovery instruction
- support diagnostic text
- audit reason code
- provider error detail
- AI-safe explanation

These must not be collapsed into one hardcoded string.

---

## 9. UI Authority Levels

UI actions must be classified by authority level.

| Level | Meaning |
|---|---|
| `VIEW_ONLY` | Displays state or content only |
| `REQUEST_ACTION` | Requests runtime action |
| `PROPOSE_ACTION` | Suggests action but cannot execute |
| `CONFIRM_USER_INTENT` | Confirms customer/staff intent |
| `EXECUTE_BOUNDARY_ACTION` | Calls authorized RPC/API |
| `APPROVAL_REQUIRED` | Requires owner/HQ/support approval |
| `EVIDENCE_REQUIRED` | Requires evidence packet |
| `BLOCKED_NO_AUTHORITY` | UI must not expose action |

UI implementation must not upgrade authority through visual convenience.

---

## 10. Customer UI Surface Mapping

Customer UI packages include:

- QR/NFC entry
- waiting session
- order preparation while waiting
- seating handoff
- table joining
- menu browsing
- multilingual menu
- cart
- payment
- split payment
- order status
- pickup status
- support request
- AI customer service
- coupon/point/wallet surfaces if applicable

Customer UI must preserve:

- customer identity continuity
- session continuity
- locale
- menu registry source
- price source
- availability source
- allergen source
- payment authority boundary
- support escalation boundary
- external projection boundary

Customer UI must not invent menu text, price text, availability status, payment status, refund status, or support conclusions.

---

## 11. Staff UI Surface Mapping

Staff UI packages include:

- staff tablet
- staff mobile
- order handoff monitor
- waiting/seating control
- manual fallback entry
- KDS-adjacent kitchen note
- customer recovery request
- inventory/soldout marking
- SOP guidance
- training content
- degraded operation screen

Staff UI must preserve:

- store context
- role context
- shift/work context if relevant
- evidence requirement
- audit event requirement
- manual fallback lineage
- content registry linkage
- i18n/message key linkage

Staff UI must not silently mutate customer order, payment, refund, settlement, or provider state.

---

## 12. KDS UI Surface Mapping

KDS UI packages include:

- kitchen ticket display
- item preparation state
- delay marker
- remake request visibility
- completion action
- degraded/manual kitchen note
- provider/POS/KDS bridge state visibility

KDS UI must preserve:

- ticket source
- order source
- routing source
- kitchen station context
- preparation status
- delay/remake event
- degraded state
- audit/evidence reference where needed

KDS UI text must use message keys or content registry references.

KDS UI must not become payment authority, refund authority, customer identity authority, or settlement authority.

---

## 13. Owner/Admin UI Surface Mapping

Owner/admin UI packages include:

- store operational dashboard
- payment status review
- KDS operational visibility
- menu/content preview
- provider capability status
- support cases
- evidence review
- staff operation visibility
- degraded mode review
- configuration planning screen

Owner/admin UI must distinguish:

- view
- request
- approve
- override
- escalate
- reconcile
- export
- configure

Each action must be tied to API/RPC/event/audit contract planning.

Owner/admin UI must not expose hidden override paths.

---

## 14. HQ Admin UI Surface Mapping

HQ admin UI packages include:

- tenant/store management
- provider capability registry
- content registry approval
- i18n readiness dashboard
- audit review
- evidence packet review
- support escalation
- partner projection control
- AI support content approval
- package readiness review

HQ admin UI must preserve:

- tenant boundary
- company/legal entity boundary where relevant
- operating group boundary where relevant
- store boundary
- role authority
- backup/override authority
- evidence requirement
- audit lineage

HQ admin UI must not collapse normal authority and emergency/backup authority into the same action.

---

## 15. Support/Admin UI Surface Mapping

Support/admin UI packages include:

- support case inbox
- evidence packet viewer
- masked customer/store data view
- AI suggested response preview
- refund request routing
- escalation workflow
- provider issue review
- audit trail display
- SOP-guided support flow

Support/admin UI must define:

- what data is visible
- what data is masked
- what action is request-only
- what action requires approval
- what action requires evidence
- what action creates audit
- what AI content may be used
- what customer-facing message key is used

Support/admin UI must not create direct mutation authority through convenience buttons.

---

## 16. AI Support UI Surface Mapping

AI support UI packages may display:

- retrieved SOP/content context
- suggested response
- issue classification
- next-step recommendation
- escalation reason
- confidence marker
- unavailable capability warning
- translation-safe response candidate

AI support UI must not display AI output as final operational truth unless the content source is approved.

AI support UI must clearly distinguish:

- retrieved source
- generated summary
- suggested response
- approved response
- operator action
- customer-visible output

AI UI must preserve source traceability, locale, audience, and runtime boundary.

---

## 17. External Menu Projection UI Mapping

External menu projection UI packages include:

- QR menu preview
- NFC menu preview
- Google Maps-linked menu candidate
- partner menu board preview
- foreign-language menu preview
- Redtable-type projection preview
- tourism-facing ordering preview

External projection UI must preserve:

- internal menu source
- content registry key
- locale
- translation source
- price source
- availability source
- allergen source
- image source
- provider capability state
- last published version
- rollback version

External projection UI must not imply provider capability unless evidence is confirmed.

Default provider capability status remains:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 18. Provider Capability UI Mapping

Provider capability UI must distinguish between:

- planned capability
- evidence required
- confirmed capability
- limited capability
- blocked capability
- deprecated capability

UI labels for provider status must use message keys.

For Redtable-type partner modules, the following must be displayed as evidence-required until confirmed:

- Redtable API availability
- Alipay support
- WeChat Pay support
- overseas card support
- global payment settlement
- refund responsibility
- translation ownership
- data retention
- Google Maps/NFC/QR projection capability
- commission and settlement conditions

No UI should present these as available features before provider evidence exists.

---

## 19. Error UI Mapping

Every error surface must define:

- error code
- message key
- audience
- severity
- retryability
- fallback instruction
- escalation path
- provider evidence requirement if applicable
- AI-safe explanation boundary
- internal diagnostic separation

Customer-facing error text must not expose internal technical detail.

Support-facing error text may include controlled diagnostic references.

Developer/debug text must not leak into production UI.

---

## 20. Degraded Operation UI Mapping

Degraded operation UI must support explicit runtime states, such as:

- provider unavailable
- KDS bridge degraded
- payment callback delayed
- menu projection stale
- content registry unavailable
- local cache uncertain
- manual fallback required
- AI support unavailable
- translation unavailable
- provider evidence missing

Degraded UI must not hide uncertainty.

Uncertain state must be visible to the proper audience.

Manual fallback instructions must be i18n/content-key based.

---

## 21. UI Package Naming Rule

UI package planning identifiers should follow:

`<surface>.<domain>.<purpose>.<version>`

Examples:

- `customer.waiting.entry.v1`
- `customer.menu.multilingual.v1`
- `customer.payment.split.v1`
- `staff.kds.ticket_monitor.v1`
- `staff.fallback.manual_order.v1`
- `owner.support.case_review.v1`
- `hq.content.registry_approval.v1`
- `support.ai.response_assist.v1`
- `partner.menu.projection_preview.v1`

These identifiers are planning names only.

They do not imply implementation exists.

---

## 22. UI Readiness Levels

Each UI package must have a readiness status.

| Status | Meaning |
|---|---|
| `UI_IDEA` | Candidate only |
| `UI_PLANNED` | Surface boundary described |
| `UI_I18N_REQUIRED` | Message/content keys not ready |
| `UI_CONTENT_REGISTRY_REQUIRED` | Content source not ready |
| `UI_CONTRACT_REQUIRED` | API/RPC/event contract missing |
| `UI_AUDIT_REQUIRED` | Audit/evidence boundary missing |
| `UI_PROVIDER_EVIDENCE_REQUIRED` | External capability not confirmed |
| `UI_READY_FOR_IMPLEMENTATION_PLANNING` | Ready for package planning, not coding |
| `UI_CODING_ALLOWED` | Only after explicit coding entry approval |

Default status for this phase:

`UI_PLANNED`

Coding is not allowed by this document.

---

## 23. Prohibited UI Shortcuts

The following are prohibited:

1. Hardcoded operational strings
2. UI-only authority
3. Buttons without API/RPC/event contract mapping
4. Customer-facing AI output without approved content boundary
5. Provider capability labels without evidence
6. Error messages without message keys
7. Menu text outside content/menu registry
8. SOP text pasted directly into UI without traceability
9. Mixed-language fallback without explicit policy
10. KDS UI mutating payment/refund/settlement authority
11. Support UI mutating state without evidence/audit
12. External menu projection becoming source of truth
13. Debug/provider detail leaking to customers
14. Degraded state hidden as normal operation
15. Coding UI before i18n and contract mapping

---

## 24. Minimum UI Planning Checklist

Before any UI implementation package proceeds, the following must be answered:

- What user surface is this?
- What runtime domain does it touch?
- What authority level does the UI action carry?
- What API/RPC contract does it call?
- What event is emitted or consumed?
- What audit event is required?
- What text is shown?
- What i18n/message keys are required?
- What content registry keys are required?
- What locale behavior applies?
- What audience behavior applies?
- What degraded state is visible?
- What provider capability evidence is required?
- What must be blocked?
- What must never be hardcoded?
- What coding entry status applies?

If any answer is missing, the UI package remains planning-only.

---

## 25. Relationship To Previous Documents

This document follows:

- `22023_Index_Controlled_Implementation_Planning_README_And_Package_Decomposition`
- `22024_Policy_Runtime_Package_Decomposition_And_Module_Boundary_Planning`
- `22025_Policy_Data_Model_Planning_Boundary_And_Schema_Design_Readiness`
- `22330 API RPC Event Contract Planning Boundary Policy`

This document prepares the boundary for:

- `22350 Payment KDS Provider Adapter Package Planning Policy`
- `22360 Support Admin Evidence Audit Package Planning Policy`
- `22370 AI Support Gateway pgvector RAG Package Planning Policy`
- `22380 External Menu Projection Redtable Partner Package Planning Policy`
- `22390 Controlled Implementation Planning Closure And Coding Entry Deferral Policy`

---

## 26. Final Rule

UI implementation must not begin from screen desire alone.

Every UI surface must be mapped to authority, API/RPC/event contracts, audit requirements, content registry, i18n message keys, locale behavior, audience behavior, degraded state, and provider evidence status.

At this stage, the correct output is not UI code.

The correct output is a controlled UI surface map that prevents hidden authority, untranslated content, hardcoded operational strings, provider assumptions, AI overreach, support/admin mutation shortcuts, and external projection drift.

Coding remains deferred.
