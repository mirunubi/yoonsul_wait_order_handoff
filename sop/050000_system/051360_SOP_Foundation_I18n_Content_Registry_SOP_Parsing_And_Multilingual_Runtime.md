# 051360_SOP_Foundation_I18n_Content_Registry_SOP_Parsing_And_Multilingual_Runtime.md

## 1. Purpose

This document defines the foundation-level i18n content registry, Markdown/SOP parsing, multilingual runtime content, menu translation source, error message localization, support script localization, staff training localization, AI customer support retrieval, external menu projection, Google Maps aligned menu display, partner menu integration, source traceability, audience-specific wording, and implementation deferral policy for the Yoonsul Wait/Order Handoff operating system.

This document establishes i18n as a foundation runtime rule, not a UI enhancement.

The core rule is:

> All Markdown policies, SOPs, menu documents, error messages, support scripts, training materials, customer-facing messages, staff-facing messages, KDS messages, Admin messages, AI support responses, and external-platform-facing menu content must be authored, normalized, parsed, stored, retrieved, and displayed through an i18n-aware content registry.

This document does not implement the i18n library, content registry, parser, translation workflow, AI retrieval system, external partner integration, or production localization runtime.

It defines the foundation policy only.

---

## 2. Scope

This document covers:

- i18n foundation rule
- Markdown policy i18n readiness
- SOP parsing rule
- content registry rule
- message key rule
- glossary key rule
- menu content i18n
- error message i18n
- support script i18n
- staff training i18n
- KDS/staff message i18n
- AI customer support retrieval
- pgvector/RAG source readiness
- external menu projection
- Google Maps aligned menu display
- partner restaurant discovery integration
- source traceability
- audience-specific wording
- no-hardcoded-copy rule
- implementation deferral

This document does not cover:

- final i18n library selection
- final database schema
- final parser implementation
- final localization files
- final translation vendor workflow
- final AI customer support implementation
- final pgvector/RAG implementation
- final external partner API
- final Google Maps integration
- final production deployment

---

## 3. Core Principle

I18n is content infrastructure.

The project must follow this rule:

> A large operating OS cannot treat translation as a final screen-layer task. Every operational document, policy, SOP, menu, message, error, support script, training material, and external projection must preserve source identity, message key, locale mapping, audience role, runtime boundary, and recovery meaning from the beginning.

Translation without structure creates drift.

SOP without keys cannot become training.

Menu without locale fields cannot serve foreign customers.

Error without i18n cannot support recovery.

AI retrieval without source traceability cannot be trusted.

---

## 4. Foundation Status

This policy is foundation-level.

It applies before:

- UI design
- Admin Console design
- Mini Kiosk design
- KDS design
- Customer Web design
- Support Console design
- AI customer support design
- external menu partner integration
- Google Maps landing integration
- franchise training content design
- SOP parsing implementation

Any later build gate must reference this foundation rule.

---

## 5. I18n-Aware Content Source Meaning

I18n-aware content source means a document or content item is structured so it can be:

- identified
- parsed
- translated
- localized
- summarized
- displayed by audience
- retrieved by AI
- linked to runtime authority
- versioned
- reviewed
- exported to approved external surfaces
- traced back to source

Markdown is not only human-readable text.

Markdown becomes operational knowledge source.

---

## 6. Covered Content Types

This policy covers:

- policy Markdown files
- SOP Markdown files
- menu documents
- recipe/menu explanation documents
- allergen notices
- dietary indicator notices
- error message definitions
- payment messages
- refund/cancel messages
- waiting/order messages
- KDS/staff messages
- support scripts
- Admin messages
- training materials
- AI customer support source documents
- external menu descriptions
- Google Maps landing content
- partner restaurant discovery content
- high-risk operation notices

All covered content should be normalized into i18n-aware registry later.

---

## 7. Markdown Policy I18n Rule

Markdown policy documents should be written so that key rules can later be extracted into structured entries.

Each important policy statement should be capable of mapping to:

- policy id
- section id
- source document number
- runtime owner
- audience
- message key if user/staff-facing
- glossary key if term-sensitive
- locale target
- evidence link if required
- test link if required
- review status

Markdown policy is future structured content.

---

## 8. SOP Parsing Rule

SOP documents must be parseable into operational units.

Each SOP unit should be capable of mapping to:

- SOP key
- source document
- source section
- source locale
- runtime references
- role/audience
- action
- condition
- expected result
- prohibited result
- recovery action
- message key
- training key
- evidence requirement
- audit requirement
- target locales

SOP parsing must preserve operational meaning.

---

## 9. SOP Unit Example

Example source SOP sentence:

    결제 상태가 불확실하면 KDS 티켓을 즉시 조리 시작하지 않고 직원 확인 상태로 보류한다.

Structured interpretation:

    sop_key: sop.payment.kds.uncertain_payment_hold.rule
    source_locale: ko-KR
    runtime_refs: PAY, KDS
    audience: staff, kds, support, ai_support
    condition: payment state is uncertain
    action: hold KDS ticket
    prohibited_result: kitchen preparation starts without confirmation
    recovery_action: staff confirmation or payment reconciliation required
    target_locales: en-US, zh-CN, zh-TW, ja-JP, es-ES

This structure allows staff app, KDS, support, and AI customer support to use the same source rule.

---

## 10. Content Registry Rule

A future content registry should become the canonical internal source for localized operational content.

The registry should support:

- content key
- source document
- source section
- source locale
- canonical text
- audience
- runtime reference
- locale versions
- translation status
- review status
- version
- effective date
- deprecated status
- external publish status
- security/legal sensitivity
- evidence/test references

Content registry is the bridge between documents and runtime surfaces.

---

## 11. Content Key Rule

Every reusable operational content unit should have a stable key.

Recommended key patterns:

    policy.[range].[section].[semantic_name]
    sop.[runtime].[process].[semantic_name]
    menu.item.[item_key].[field]
    error.[system].[module].[process].[event].[audience]
    support.[case_type].[message_type]
    training.[role].[module].[lesson]
    external.menu.[store].[item_key].[field]

Examples:

    sop.payment.kds.uncertain_payment_hold.rule
    menu.item.yoonsul_maru_bowl.description
    error.pay.payment.uncertain.customer
    support.payment_uncertain.customer_message
    training.staff.kds.payment_hold.lesson

Keys must remain stable even if displayed text changes.

---

## 12. Message Key Rule

All operational messages must use message keys.

This includes:

- customer messages
- staff messages
- KDS messages
- Mini Kiosk messages
- Admin messages
- Support messages
- error messages
- recovery messages
- AI support response templates
- menu descriptions
- external menu projection text

Hardcoded operational strings are prohibited by default.

---

## 13. Glossary Key Rule

Important terms should have glossary keys.

Glossary keys should be used for:

- payment
- refund
- cancellation
- KDS
- hold
- release
- provider
- reconciliation
- verification
- adult verification
- allergen
- dietary indicators
- high-risk operation
- support case
- evidence
- audit
- manual fallback
- AI confidence
- stale state
- uncertain state

Glossary consistency prevents translation drift.

---

## 14. Audience-Specific Wording Rule

The same source rule may require different wording by audience.

Audience types include:

- customer
- staff
- KDS
- store manager
- store owner
- support
- Admin
- security reviewer
- legal reviewer
- developer diagnostic
- AI support
- external partner
- training learner

One source rule can produce multiple localized audience messages.

---

## 15. Audience Wording Example

Same operational rule:

    Payment is uncertain, so KDS release is blocked.

Customer wording:

    주문 확인이 필요합니다. 직원이 곧 도와드리겠습니다.

Staff wording:

    결제가 확인되지 않았습니다. 조리 시작 전 결제 상태를 확인해주세요.

Support wording:

    Payment state is uncertain. KDS release must remain blocked until staff confirmation or reconciliation.

KDS wording:

    결제 확인 필요. 조리 보류.

Same rule, different audience.

---

## 16. Locale Baseline Rule

Locale support must be designed from the beginning.

Minimum foundation locale candidates:

- `ko-KR`
- `en-US`
- `zh-CN`
- `zh-TW`
- `ja-JP`

Expansion candidates:

- `es-ES`
- `fr-FR`
- `vi-VN`
- `th-TH`
- `id-ID`
- `ru-RU`
- `mn-MN`
- `uz-UZ`
- `ne-NP`

Final locale priority may be based on store location, customer data, tourism data, and partner demand.

---

## 17. Locale Fallback Rule

Locale fallback must be controlled.

Recommended fallback order:

    requested locale
        -> customer preferred locale
        -> store configured fallback locale
        -> ko-KR default
        -> safe generic message with code

Fallback must preserve:

- recovery action
- error code if applicable
- safety meaning
- no developer diagnostic leakage
- no customer blame
- no false finality

Fallback is part of reliability.

---

## 18. No Hardcoded Operational Copy Rule

Hardcoded operational display text is prohibited.

Prohibited hardcoding includes:

- menu names
- menu descriptions
- allergen notices
- order instructions
- payment messages
- refund messages
- KDS messages
- error messages
- support responses
- Admin labels
- customer recovery messages
- AI support answer templates
- external platform descriptions

Temporary developer diagnostic text may be allowed only if it never reaches operational UI.

---

## 19. Menu Content I18n Rule

Menu content must be i18n-aware from source.

Each menu item should support:

- menu item key
- display name
- short name
- short description
- long description
- ingredient summary
- allergen notice
- dietary indicators
- spice/salt/temperature note
- photo alt text
- sold-out message
- substitution message
- preparation note
- external platform description
- locale versions
- review status

Menu is not only sales copy.

Menu is customer safety content.

---

## 20. Allergen And Dietary Indicator Rule

Allergen and dietary information should be structured.

Recommended indicators:

- egg
- dairy
- wheat/gluten
- soy
- peanut/tree nut
- seafood
- shellfish
- pork
- beef
- chicken
- alcohol
- spicy
- high sodium candidate
- vegetarian candidate
- vegan candidate
- halal-friendly candidate

Translation must not weaken allergen clarity.

---

## 21. Error Message I18n Rule

Every critical error message must be i18n-ready.

Critical error messages include:

- payment pending
- payment uncertain
- payment failed
- duplicate payment risk
- refund review required
- order state uncertain
- KDS hold
- KDS release blocked
- Mini Kiosk timeout
- provider delay
- support escalation
- high-risk blocked
- AI support uncertainty

Foreign customers must receive an understandable recovery message.

---

## 22. Error Code Traceability Rule

Error messages must preserve error code traceability.

Each error message should support:

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
- recovery action
- support action
- audit linkage
- evidence linkage if needed

Translation must not break traceability.

---

## 23. Payment Message Localization Rule

Payment messages must preserve exact operational meaning.

Localized messages must distinguish:

- pending
- confirmed
- failed
- uncertain
- duplicate attempt risk
- refund requested
- refund processing
- refund completed
- support review required

Do not translate payment uncertainty into payment failure.

---

## 24. KDS Staff Message Localization Rule

KDS/staff messages should support localization when needed.

They must preserve:

- short operational wording
- hold/release meaning
- payment check meaning
- provider mapping meaning
- retry/remake meaning
- manual fallback instruction
- no customer identity exposure
- peak-hour readability

Staff-facing localization supports training and foreign staff.

---

## 25. Support Script Localization Rule

Support scripts must be locale-ready.

Support scripts should preserve:

- case type
- recovery path
- uncertainty
- apology tone if needed
- no blame
- no raw diagnostic
- support escalation
- error code reference
- evidence relation

Support translation is part of customer recovery.

---

## 26. Training Content Localization Rule

Training content should be i18n-aware.

Training content should support:

- role
- module
- lesson key
- source SOP key
- plain-language explanation
- checklist
- error examples
- recovery examples
- locale versions
- review status

Foreign staff or future franchise staff should receive consistent training.

---

## 27. AI Customer Support Retrieval Rule

AI customer support must retrieve from source-traceable i18n-aware content.

AI retrieval should preserve:

- source document
- source section
- content key
- locale
- audience
- freshness
- confidence
- runtime boundary
- recovery action
- human review requirement if uncertain

AI must not freely translate sensitive operational rules without structure.

---

## 28. pgvector RAG Source Rule

pgvector/RAG content should be built from approved content sources.

Approved source candidates:

- policy documents
- SOP documents
- menu content registry
- error message registry
- support script registry
- training registry
- external public menu registry
- approved FAQ registry

Excluded by default:

- raw CI/DI
- payment secrets
- provider secrets
- raw support cases
- raw evidence packets
- raw provider payloads
- private staff data
- unreviewed legal-sensitive copy

RAG source must be safe before indexing.

---

## 29. SOP Translation Retrieval Rule

When SOP is retrieved for staff, support, Admin, AI support, or training, the system should display:

- original source reference
- localized explanation
- audience-specific wording
- recovery action
- related error codes if any
- related runtime owners
- freshness status
- review status if needed

SOP translation must not detach from source.

---

## 30. External Menu Projection Rule

External menu projection means sending approved multilingual public menu content to outside surfaces.

External surfaces may include:

- Google Maps linked landing page
- QR menu landing page
- restaurant discovery partner
- foreign customer menu portal
- tourism channel
- translated menu board
- partner restaurant introduction page

External projection must use approved public content only.

---

## 31. External Partner Boundary Rule

External menu partner may display approved public content.

External partner must not own:

- canonical menu source
- POS truth
- payment truth
- KDS truth
- stock truth unless explicitly projected
- customer identity
- support case
- internal evidence
- provider secret
- staff data
- cost/margin data

Partner integration is discovery/projection, not runtime authority.

---

## 32. Google Maps Landing Rule

Map-driven customer entry should support locale-aware content.

Google Maps or map-linked landing should provide:

- store name
- store introduction
- translated menu board
- item descriptions
- allergen/diet indicators
- price display
- order/waiting link
- opening hours
- location guidance
- selected locale
- fallback locale

Foreign customers should understand the restaurant before ordering.

---

## 33. Translation Source Of Truth Rule

The canonical translation source must remain controlled by Yoonsul.

External partner content should be downstream.

Canonical source should track:

- original copy
- translation copy
- locale
- source key
- version
- reviewer
- approval status
- effective date
- deprecated date
- external publish status

No external partner should become the master copy for menu or operational messages.

---

## 34. Translation Review Rule

Human review is required for sensitive translation.

Sensitive translation includes:

- allergens
- dietary claims
- payment messages
- refund/cancel messages
- high-risk notices
- adult verification
- service refusal
- legal-sensitive support scripts
- AI customer-facing answers
- external restaurant descriptions

AI translation may assist but must not be final for sensitive content.

---

## 35. Content Versioning Rule

All important content should be versioned.

Versioning should track:

- source version
- translation version
- approval status
- effective date
- deprecated date
- superseded version
- external publish status
- rollback version
- reviewer

Content versioning prevents stale external menus.

---

## 36. Content Approval Status Values

Recommended content approval statuses:

- `CONTENT_DRAFT`
- `CONTENT_SOURCE_REVIEW_REQUIRED`
- `CONTENT_TRANSLATION_REQUIRED`
- `CONTENT_TRANSLATION_REVIEW_REQUIRED`
- `CONTENT_MENU_OWNER_REVIEW_REQUIRED`
- `CONTENT_SUPPORT_REVIEW_REQUIRED`
- `CONTENT_SECURITY_REVIEW_REQUIRED`
- `CONTENT_LEGAL_REVIEW_REQUIRED`
- `CONTENT_READY_INTERNAL`
- `CONTENT_READY_EXTERNAL`
- `CONTENT_PUBLISHED`
- `CONTENT_BLOCKED`
- `CONTENT_DEPRECATED`
- `CONTENT_SUPERSEDED`

External publication requires appropriate approval.

---

## 37. I18n Build Gate Rule

Build gate must block when:

- hardcoded operational copy exists
- message key is missing
- locale fallback is missing
- critical customer message has no locale path
- menu item has no translation key
- allergen notice is unstructured
- SOP content cannot be traced to source
- error message has no code/key
- support script has no locale path
- AI support retrieval lacks source traceability
- external menu projection lacks approved content version

I18n is mandatory build readiness.

---

## 38. SOP Parser Build Gate Rule

Build gate must block SOP parser planning when:

- SOP sections lack stable identifiers
- source document references are missing
- audience mapping is missing
- runtime mapping is missing
- locale mapping is missing
- recovery action is missing for operational SOP
- sensitive data boundary is missing
- AI retrieval boundary is missing
- review status is missing

SOP parser must not create untraceable operational advice.

---

## 39. External Menu Projection Build Gate Rule

Build gate must block external menu projection when:

- menu translation not reviewed
- allergen/diet data missing
- public content package undefined
- external partner boundary unclear
- Google Maps landing fallback missing
- content versioning missing
- stale content handling missing
- sensitive data leakage risk exists
- commercial claim exceeds content readiness

External menu projection must be safe and current.

---

## 40. AI Support Build Gate Rule

Build gate must block AI support when:

- source content not traceable
- locale handling undefined
- SOP translation behavior undefined
- sensitive content exclusion missing
- freshness missing
- confidence missing
- human review missing
- runtime authority boundary missing
- support case scope missing

AI support must be grounded in structured content.

---

## 41. Data Capture Rule

The system should capture safe i18n/content metrics.

Possible metrics:

- selected locale
- fallback locale used
- missing key event
- translation feedback
- menu view by locale
- support case by locale
- external partner referral
- Google Maps landing entry
- customer confusion report
- staff translation issue
- AI support source failure

Data capture must respect privacy.

---

## 42. Translation Feedback Rule

Customer, staff, and support feedback should be captured.

Feedback types:

- unclear menu translation
- wrong ingredient meaning
- allergen confusion
- payment message confusion
- error message confusion
- staff instruction confusion
- support script issue
- AI answer translation issue
- external partner display mismatch
- cultural wording issue

Feedback should create content improvement candidates.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      Foundation_I18n_Content_Registry.md
      Markdown_SOP_I18n_Source_Register.md
      SOP_Parsing_Key_Register.md
      Message_Key_Registry.md
      Glossary_Key_Register.md
      Menu_Content_I18n_Register.md
      Error_Message_I18n_Register.md
      Support_Script_I18n_Register.md
      Training_Content_I18n_Register.md
      AI_Support_Content_Source_Register.md
      PGVector_RAG_I18n_Source_Register.md
      External_Menu_Projection_Register.md
      Google_Maps_Landing_Content_Register.md
      Translation_Review_Register.md
      Content_Version_Register.md
      I18n_Build_Gate_Blocker_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- treating i18n as screen-level decoration
- writing SOPs that cannot be parsed
- hardcoding Korean UI text
- Korean-only menu board as final product strategy
- translating payment uncertainty incorrectly
- translating allergen content without review
- using AI-translated legal-sensitive content without review
- letting external partner own canonical menu text
- indexing raw sensitive data into RAG
- allowing AI support to answer from untraceable translated text
- publishing stale translated menu externally
- disconnecting SOP translation from source policy

---

## 45. No-Code Boundary

This document does not authorize:

- i18n library implementation
- content registry implementation
- Markdown parser implementation
- SOP parser implementation
- localization file creation
- translation execution
- AI customer support implementation
- pgvector/RAG implementation
- external partner integration
- Google Maps integration
- translated menu publishing
- production deployment

This document defines foundation policy only.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. Why is i18n foundation-level?
2. What is i18n-aware content source?
3. What content types are covered?
4. What Markdown policy i18n rule applies?
5. What SOP parsing rule applies?
6. What content registry rule applies?
7. What content key rule applies?
8. What message key rule applies?
9. What glossary key rule applies?
10. What audience-specific wording rule applies?
11. What locale baseline rule applies?
12. What locale fallback rule applies?
13. What no-hardcoded-copy rule applies?
14. What menu content i18n rule applies?
15. What allergen/dietary indicator rule applies?
16. What error message i18n rule applies?
17. What error code traceability rule applies?
18. What payment message localization rule applies?
19. What KDS/staff message localization rule applies?
20. What support script localization rule applies?
21. What training content localization rule applies?
22. What AI customer support retrieval rule applies?
23. What pgvector/RAG source rule applies?
24. What SOP translation retrieval rule applies?
25. What external menu projection rule applies?
26. What external partner boundary rule applies?
27. What Google Maps landing rule applies?
28. What translation source-of-truth rule applies?
29. What translation review rule applies?
30. What content versioning rule applies?
31. What content approval statuses exist?
32. What i18n build gate rule applies?
33. What SOP parser build gate rule applies?
34. What external menu projection build gate rule applies?
35. What AI support build gate rule applies?
36. What data capture rule applies?
37. What translation feedback rule applies?
38. What registers are recommended?
39. What anti-patterns are prohibited?
40. What no-code boundary applies?

If these questions cannot be answered, foundation i18n content registry, SOP parsing, and multilingual runtime planning is incomplete.

---

## 47. Conclusion

Yoonsul OS must treat Markdown, SOPs, menus, messages, errors, support scripts, training materials, and AI support sources as multilingual operational content from the beginning.

The safe foundation flow is:

    Markdown policy and SOP
        -> stable section and content keys
        -> i18n-aware content registry
        -> audience-specific wording
        -> locale-specific copy
        -> review and versioning
        -> runtime display
        -> AI retrieval
        -> external menu projection if approved
        -> feedback and improvement

This document ensures that future Customer Web, Mini Kiosk, KDS, Staff App, Admin Console, Support Console, AI Customer Support, pgvector/RAG, Google Maps landing, external restaurant discovery partners, translated menu boards, and franchise training systems all share the same source-traceable, localized, reviewable, and authority-safe content foundation.
