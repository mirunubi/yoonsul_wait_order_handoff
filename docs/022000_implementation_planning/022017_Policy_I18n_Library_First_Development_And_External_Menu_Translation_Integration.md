# 022017_Policy_I18n_Library_First_Development_And_External_Menu_Translation_Integration

## 1. Purpose

This document defines the i18n-library-first development rule, no-hardcoded-copy rule, menu translation readiness, system message localization, error message localization, external restaurant discovery integration, Google Maps aligned menu presentation, translated menu board delivery, partner integration boundary, review requirement, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous UI and message readiness documents defined i18n as a baseline for menu names, menu descriptions, allergy notices, order guidance, payment messages, KDS/staff messages, customer error messages, support messages, AI support responses, recovery instructions, and high-risk notices.

This document makes the rule explicit:

> All customer-facing, staff-facing, support-facing, Admin-facing, KDS-facing, Mini Kiosk-facing, menu-facing, error-facing, and AI-support-facing text must follow the approved i18n library/message-key structure. Hardcoded operational text is prohibited by default.

This document does not implement i18n libraries, localization files, translation workflows, external partner APIs, Google Maps integration, or translated menu publishing.

It defines i18n-library-first development and external menu translation integration policy only.

---

## 2. Scope

This document covers:

- i18n library first rule
- no hardcoded copy rule
- message key requirement
- menu translation requirement
- menu board translation requirement
- error message translation requirement
- system message translation requirement
- customer/staff/support/Admin/KDS/Mini Kiosk localization
- locale fallback rule
- translation review
- external menu translation partner integration
- Google Maps aligned restaurant/menu presentation
- evidence and audit linkage
- no-code boundary

This document does not cover:

- final i18n library selection
- final localization file format
- final translation vendor selection
- final external partner contract
- final Google Maps API implementation
- final translated menu publishing
- final AI translation execution
- final production deployment

---

## 3. Core Principle

I18n is not a decoration.

I18n is a runtime content infrastructure.

The project must follow this rule:

> No UI, menu, error message, system message, support message, KDS/staff message, Mini Kiosk message, Admin message, AI support message, or external menu presentation may be implemented with hardcoded display text unless explicitly allowed as temporary diagnostic-only copy.

Hardcoded text becomes future technical debt.

Hardcoded text blocks multilingual customers.

Hardcoded text breaks external platform expansion.

Hardcoded text weakens support traceability.

---

## 4. I18n Library First Rule

All development must use the approved i18n library or message-key runtime.

This applies to:

- Customer Web
- Mini Kiosk
- Staff App
- KDS Screen
- Support Console
- Admin Console
- AI Support Surface
- Billing Surface
- Menu Board
- External Menu View
- Error Message Surface
- Notification Surface
- Recovery Message Surface

Development should call message keys, not literal copy.

---

## 5. No Hardcoded Copy Rule

Hardcoded display text is prohibited for:

- menu name
- menu description
- ingredient explanation
- allergen notice
- order button
- payment message
- refund message
- waiting message
- error message
- warning message
- success message
- KDS instruction
- staff fallback instruction
- support reply template
- Admin action label
- AI support response template
- external partner menu copy

Exception may exist only for internal developer diagnostics that never reach operational UI.

---

## 6. Message Key Rule

Every display message should use a stable message key.

Recommended message key format:

    [domain].[surface].[context].[message_type].[semantic_name]

Examples:

    menu.item.yoonsul_kimbap.name
    menu.item.yoonsul_kimbap.description
    menu.item.yoonsul_kimbap.allergen_notice
    payment.customer.pending.message
    payment.customer.uncertain.recovery
    kds.staff.ticket_hold.payment_check
    support.customer.refund_review.message
    error.pay.payment.uncertain.customer
    ai_support.customer.source_stale.message

Message key should remain stable even when translated copy changes.

---

## 7. Menu I18n Rule

Every menu item should have i18n-ready fields.

Recommended menu i18n fields:

- menu item key
- display name
- short display name
- short description
- long description
- ingredient summary
- allergen notice
- spice level notice
- salt/sodium notice if needed
- temperature notice if needed
- pork/beef/chicken/seafood/egg/dairy indication
- vegetarian/vegan/halal-friendly indicator if applicable
- substitution note
- sold-out message
- preparation note
- photo alt text
- external platform description

Menu i18n is part of menu safety and sales conversion.

---

## 8. Menu Board Translation Rule

Translated menu board content should be available for foreign customers.

Menu board translation should support:

- in-store QR menu
- customer web menu
- Mini Kiosk menu
- external menu landing page
- Google Maps linked menu page
- partner restaurant discovery page
- tourism-oriented menu page
- AI customer support menu explanation

Menu board translation should not rely only on browser auto-translation.

---

## 9. External Restaurant Discovery Integration Rule

External restaurant discovery integration should receive i18n-ready menu data.

Partner integration may include:

- restaurant name
- store description
- menu item names
- menu descriptions
- allergens
- dietary indicators
- price display
- availability status
- store hours
- ordering path
- reservation or waiting path
- Google Maps aligned location context
- translated landing page link

External partner should consume structured multilingual content, not scraped Korean-only text.

---

## 10. Google Maps Aligned Menu Presentation Rule

When customers discover a store through Google Maps or map-linked restaurant discovery services, the menu presentation should support locale-aware viewing.

This may include:

- store landing page by locale
- translated menu board
- translated item descriptions
- allergy/diet indicators
- ordering guidance
- waiting guidance
- payment guidance
- support guidance
- external platform deep link
- QR-to-locale handoff

Map discovery should lead to understandable menu experience.

---

## 11. Partner Menu Translation Boundary Rule

External translation/menu partner integration must not become runtime authority.

Partner may receive or display:

- approved store profile
- approved menu names
- approved menu descriptions
- approved allergen/diet labels
- approved availability projection if allowed
- approved external landing links

Partner must not directly own:

- POS truth
- payment truth
- KDS truth
- stock truth
- sold-out truth unless validated
- customer identity
- support case
- internal evidence
- raw provider data

Partner integration is presentation and discovery, not runtime ownership.

---

## 12. Translation Source Of Truth Rule

The source of truth for translated content should remain inside Yoonsul-controlled content registry.

External partner display should be downstream.

Canonical content should include:

- original Korean copy
- approved translations
- locale status
- review status
- source author
- translation reviewer
- legal/security review if needed
- last updated time
- deprecated/superseded status

External partner should not become master content source.

---

## 13. Translation Review Rule

Translation review is required for:

- menu description
- allergen notice
- dietary indicator
- payment message
- refund/cancel message
- high-risk notice
- legal-sensitive notice
- customer recovery message
- service refusal message
- AI support customer-facing answer
- external platform restaurant description

Machine translation may assist, but sensitive copy requires review.

---

## 14. Locale Coverage Rule

Minimum launch locale candidates may include:

- `ko-KR`
- `en-US`
- `zh-CN`
- `zh-TW`
- `ja-JP`

Expansion locale candidates may include:

- `es-ES`
- `fr-FR`
- `vi-VN`
- `th-TH`
- `id-ID`
- `ru-RU`
- `mn-MN`
- `uz-UZ`
- `ne-NP`

Locale priority should be based on store location, tourist traffic, customer data, and partner channel demand.

---

## 15. Locale Selection Rule

Locale may be selected by:

- customer explicit selection
- browser locale
- device locale
- QR parameter
- external partner parameter
- Google Maps landing context
- saved customer preference
- staff-assisted selection
- fallback locale

Explicit customer selection should override inferred locale.

---

## 16. Locale Fallback Rule

If requested locale is unavailable, fallback must be safe.

Recommended fallback flow:

    requested locale
        -> configured fallback locale
        -> ko-KR default
        -> safe generic message with code

Fallback must not expose developer diagnostics.

Fallback must preserve recovery action.

---

## 17. Error Message I18n Rule

Every critical error message should be i18n-ready.

Critical error messages include:

- payment pending
- payment uncertain
- payment failed
- duplicate payment risk
- refund review required
- order state uncertain
- KDS hold
- Mini Kiosk timeout
- provider delay
- support escalation
- high-risk blocked
- staff assistance required
- AI support cannot answer confidently

A foreign customer must receive an understandable recovery message.

---

## 18. Payment Message I18n Rule

Payment messages must preserve exact operational meaning across languages.

Translated payment messages must distinguish:

- pending
- confirmed
- failed
- uncertain
- duplicate attempt risk
- refund requested
- refund processing
- refund completed
- support review required

Translation must not create false finality.

---

## 19. KDS Staff Message I18n Rule

KDS/staff messages may be localized where staff environment requires it.

KDS/staff messages should preserve:

- short operational wording
- status clarity
- hold/release meaning
- payment check meaning
- provider mapping meaning
- retry/remake meaning
- manual fallback instruction
- no customer identity exposure

Staff-facing i18n supports foreign staff and training.

---

## 20. Support Message I18n Rule

Support message templates should be locale-ready.

Support messages should preserve:

- case scope
- recovery step
- uncertainty
- apology tone if needed
- no blame
- no raw diagnostic
- support escalation
- error code reference

Support message i18n strengthens customer trust.

---

## 21. AI Support I18n Rule

AI support must respect locale.

AI support response should include:

- customer locale
- source language
- translated answer if allowed
- source citation
- freshness
- confidence
- human review if uncertain
- no legal conclusion
- no runtime mutation

AI translation must not change operational policy.

---

## 22. Menu Description Safety Rule

Translated menu descriptions must not mislead.

Review should confirm:

- ingredient accuracy
- allergen clarity
- spice level clarity
- meat type clarity
- seafood/egg/dairy clarity
- alcohol content if any
- no unsupported health claim
- no cultural misunderstanding
- no promise beyond actual menu

Menu translation can affect customer safety.

---

## 23. Allergen And Dietary Indicator Rule

Allergen and dietary indicators must be structured, not free text only.

Recommended structured indicators:

- contains egg
- contains dairy
- contains wheat/gluten
- contains soy
- contains peanut/tree nut
- contains seafood
- contains shellfish
- contains pork
- contains beef
- contains chicken
- vegetarian candidate
- vegan candidate
- spicy
- high sodium candidate
- alcohol included

Final indicator set may be refined later.

---

## 24. External Partner Data Package Rule

External partner menu package should include:

- store id or public store key
- store display name
- store location display
- map link
- locale list
- menu item keys
- translated menu names
- translated descriptions
- allergen/diet indicators
- price display
- availability display if approved
- photo links if approved
- ordering/waiting link
- last updated timestamp
- content version

Package should avoid sensitive operational data.

---

## 25. External Partner Prohibited Data Rule

External partner package must not include:

- customer identity
- CI/DI
- payment data
- support case data
- internal audit
- internal evidence
- provider secret
- raw POS data
- raw KDS data
- internal staff data
- internal cost/margin
- hidden menu experiment unless approved

External discovery needs public content only.

---

## 26. Content Versioning Rule

Translated content should have versioning.

Version should track:

- source copy version
- translation version
- reviewer
- approval status
- effective date
- deprecated date
- superseded version
- external publish status

External partners should receive versioned content.

---

## 27. Content Approval Status Values

Recommended content approval statuses:

- `CONTENT_DRAFT`
- `CONTENT_TRANSLATION_REQUIRED`
- `CONTENT_TRANSLATION_REVIEW_REQUIRED`
- `CONTENT_LEGAL_REVIEW_REQUIRED`
- `CONTENT_SECURITY_REVIEW_REQUIRED`
- `CONTENT_MENU_OWNER_REVIEW_REQUIRED`
- `CONTENT_READY_INTERNAL`
- `CONTENT_READY_EXTERNAL`
- `CONTENT_PUBLISHED`
- `CONTENT_DEPRECATED`
- `CONTENT_SUPERSEDED`
- `CONTENT_BLOCKED`

External publishing requires approval.

---

## 28. I18n Development Gate Rule

Build gate must block UI or message implementation when:

- hardcoded display text exists
- message key missing
- locale fallback missing
- critical customer message untranslated
- payment message lacks reviewed translation
- menu description lacks translation key
- allergen notice missing translation
- error message lacks i18n key
- support message lacks locale path
- AI support locale behavior undefined
- external partner content package lacks version

I18n is build gate requirement.

---

## 29. Hardcoded Text Exception Rule

Hardcoded text may be allowed only for:

- non-user-visible developer diagnostic
- temporary local debug label
- test fixture text
- internal migration note
- documentation example

Hardcoded exception must not appear in operational UI.

---

## 30. I18n Test Rule

I18n tests should verify:

- message key exists
- locale fallback works
- variables are safe
- missing locale shows safe generic message
- payment uncertainty meaning preserved
- error code remains visible
- menu description appears in selected locale
- allergen notice appears in selected locale
- no developer diagnostic appears
- no sensitive data appears in translation variable

I18n tests are required for customer-facing surfaces.

---

## 31. I18n Evidence Rule

I18n evidence may include:

- message key registry
- locale coverage report
- translation review record
- menu translation approval record
- screenshot by locale
- fallback test result
- external partner package sample
- content version history
- reviewer approval
- blocker record

I18n evidence supports build gate.

---

## 32. External Partner Integration Readiness Rule

External partner integration readiness requires:

- partner data boundary
- content source of truth
- public menu package format
- locale coverage
- update cadence
- versioning
- approval workflow
- no sensitive data
- fallback behavior
- support contact or recovery link
- partner display review

Partner integration should not begin from ad hoc menu text.

---

## 33. Google Maps Landing Readiness Rule

Google Maps or map-linked landing readiness requires:

- public store page
- locale selection
- translated menu board
- translated item detail
- allergy/diet indicators
- order/waiting path
- opening hours
- location guidance
- external partner link if applicable
- fallback language

Map traffic should land on understandable content.

---

## 34. Menu Translation Commercial Rule

Translated menu board can become commercial advantage.

Commercial claims may include:

- multilingual menu availability
- foreign customer-friendly ordering
- translated menu descriptions
- allergy/diet guidance where reviewed
- QR menu support
- map-linked menu page

Commercial claims must not imply unreviewed allergen, legal, or medical guarantees.

---

## 35. Red-Table Type Partner Join Rule

If partnering with a restaurant discovery or foreign-customer menu translation company, the project should preserve:

- Yoonsul content source of truth
- public-only partner package
- locale-aware menu display
- versioned menu updates
- translation review workflow
- map-aligned landing path
- no runtime authority transfer
- no sensitive data sharing
- commercial scope boundary
- partner evidence register

Partner join should extend customer acquisition, not surrender OS control.

---

## 36. AI Translation Assist Rule

AI may assist translation when:

- source copy is approved
- target locale is selected
- sensitive fields are excluded
- output is reviewed for critical content
- allergen/legal/payment/high-risk messages receive human review
- version is recorded
- source citation or source key is preserved

AI translation assist is not final approval.

---

## 37. Translation Quality Feedback Rule

Customer and staff feedback should be captured.

Feedback categories:

- unclear translation
- wrong ingredient meaning
- allergen confusion
- payment message confusion
- menu expectation mismatch
- cultural wording issue
- staff explanation needed
- foreign customer support issue
- external partner display mismatch

Translation feedback should become improvement data.

---

## 38. Data Capture Rule

I18n runtime should capture safe metrics:

- selected locale
- fallback locale used
- missing key event
- translation error report
- menu language view
- external partner referral
- Google Maps landing entry
- order conversion by locale if privacy-safe
- support case by locale
- repeated message confusion

Data capture must respect privacy.

---

## 39. Blocker Rule

Create blocker when:

- i18n library rule missing
- hardcoded copy appears in operational UI
- menu item has no message key
- critical error has no locale path
- payment message translation unreviewed
- allergen notice missing
- external partner package includes sensitive data
- partner display uses stale content
- map-linked menu lacks safe fallback
- AI translation used without review for sensitive copy

I18n blocker must stop affected UI/content planning.

---

## 40. Build Gate Input Rule

Build gate should receive:

- i18n library compliance status
- hardcoded copy exception list
- message key registry status
- menu translation readiness status
- error message locale readiness
- payment/KDS/support message readiness
- external partner package readiness
- Google Maps landing readiness
- translation review blockers
- content versioning status

Build gate must treat i18n as core readiness.

---

## 41. Registers Recommendation

Recommended future files:

    docs/_index/
      I18n_Library_Compliance_Register.md
      Hardcoded_Copy_Exception_Register.md
      Message_Key_Registry.md
      Menu_Translation_Register.md
      Menu_Board_I18n_Register.md
      Error_Message_I18n_Register.md
      External_Partner_Menu_Package_Register.md
      Google_Maps_Landing_I18n_Register.md
      Translation_Review_Register.md
      Content_Version_Register.md
      Translation_Feedback_Register.md

This document only recommends these files.

It does not create them.

---

## 42. Anti-Patterns

The following are prohibited:

- hardcoded UI copy
- Korean-only menu board as final design
- translating menu text outside source-of-truth
- external partner owning canonical menu content
- sharing sensitive data with menu discovery partner
- using browser auto-translation as product strategy
- translating allergen text without review
- translating payment uncertainty incorrectly
- AI-translating legal/high-risk copy without review
- using stale translated menu on external platform
- creating Google Maps landing page with Korean-only recovery messages

---

## 43. No-Code Boundary

This document does not authorize:

- i18n library implementation
- localization file creation
- translation execution
- external partner API integration
- Google Maps integration
- translated menu publishing
- AI translation workflow implementation
- customer-facing launch
- production deployment

This document governs i18n-library-first development and external menu translation readiness only.

---

## 44. Readiness Check

This document is ready when the project can answer:

1. What is the i18n library first rule?
2. What is the no hardcoded copy rule?
3. What message key rule applies?
4. What menu i18n rule applies?
5. What menu board translation rule applies?
6. What external restaurant discovery integration rule applies?
7. What Google Maps aligned menu presentation rule applies?
8. What partner menu translation boundary rule applies?
9. What translation source of truth rule applies?
10. What translation review rule applies?
11. What locale coverage rule applies?
12. What locale selection rule applies?
13. What locale fallback rule applies?
14. What error message i18n rule applies?
15. What payment message i18n rule applies?
16. What KDS/staff message i18n rule applies?
17. What support message i18n rule applies?
18. What AI support i18n rule applies?
19. What menu description safety rule applies?
20. What allergen and dietary indicator rule applies?
21. What external partner data package rule applies?
22. What external partner prohibited data rule applies?
23. What content versioning rule applies?
24. What content approval status values exist?
25. What i18n development gate rule applies?
26. What hardcoded text exception rule applies?
27. What i18n test rule applies?
28. What i18n evidence rule applies?
29. What external partner integration readiness rule applies?
30. What Google Maps landing readiness rule applies?
31. What menu translation commercial rule applies?
32. What Red-Table type partner join rule applies?
33. What AI translation assist rule applies?
34. What translation quality feedback rule applies?
35. What data capture rule applies?
36. What blocker rule applies?
37. What build gate input rule applies?
38. What registers are recommended?
39. What anti-patterns are prohibited?
40. What no-code boundary applies?

If these questions cannot be answered, i18n-library-first development and external menu translation integration planning is incomplete.

---

## 45. Conclusion

Multilingual menu and message infrastructure is not a late-stage enhancement.

It is a core operating requirement for customer acquisition, foreign customer usability, support recovery, external restaurant discovery, Google Maps landing, translated menu boards, AI support, and future platform expansion.

The safe i18n flow is:

    source content
        -> message key
        -> locale-specific copy
        -> review
        -> versioning
        -> runtime display
        -> external partner package if approved
        -> feedback and improvement

This document ensures that all development follows the approved i18n library/message-key structure and that future restaurant discovery partners can show translated menu boards to foreign customers without taking over runtime authority or exposing sensitive operational data.