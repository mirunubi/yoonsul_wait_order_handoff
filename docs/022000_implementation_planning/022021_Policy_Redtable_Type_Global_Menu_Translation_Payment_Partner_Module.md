# 022021_Policy_Redtable_Type_Global_Menu_Translation_Payment_Partner_Module

## 1. Purpose

This document defines the Redtable-type global menu translation and foreign customer payment partner module policy for the Yoonsul Wait/Order Handoff operating system.

This policy covers external menu translation partner integration, verified multilingual menu dataset usage, Google Maps or tourism-channel-aligned restaurant discovery, foreign customer NFC/QR menu entry, global payment bridge, Alipay/WeChat Pay/foreign card network assumptions, domestic payment separation, Toss Payments coexistence, partner settlement boundary, source-of-truth boundary, provider evidence requirement, and implementation deferral.

This document does not assume that any specific partner capability is officially confirmed.

All Redtable-type capabilities must be verified through official provider documents, contract terms, API specifications, payment settlement documents, and test evidence before implementation planning.

---

## 2. Scope

This document covers:

- Redtable-type partner module
- external multilingual menu dataset usage
- Korean menu to global menu mapping
- foreign customer translated menu presentation
- Google Maps aligned restaurant discovery
- NFC/QR foreign customer entry
- domestic payment versus global payment routing
- Toss Payments coexistence
- Alipay / WeChat Pay / foreign card payment bridge candidate
- in-app partner payment module candidate
- settlement and margin boundary
- partner data package
- content source-of-truth boundary
- provider evidence requirement
- security/legal/payment review
- no-code boundary

This document does not cover:

- final Redtable contract
- final Redtable API integration
- final global payment implementation
- final Toss Payments implementation
- final Alipay or WeChat Pay implementation
- final foreign card acquiring implementation
- final Google Maps integration
- final production launch

---

## 3. Core Principle

Redtable-type partner integration is an external projection and global payment bridge, not the owner of Yoonsul runtime truth.

The project must follow this rule:

> External menu translation and global payment partners may enrich foreign customer discovery, translated menu understanding, and global payment acceptance, but they must not become the canonical owner of menu truth, POS truth, payment truth, KDS truth, customer identity, support cases, audit evidence, or settlement authority inside Yoonsul OS.

Partner integration extends market reach.

It must not surrender operating authority.

---

## 4. Redtable-Type Partner Meaning

Redtable-type partner means an external company or service that may provide one or more of the following:

- multilingual restaurant/menu presentation
- foreign tourist restaurant discovery
- translated menu dataset
- Google Maps or tourism-channel landing support
- foreign customer payment module
- Alipay payment candidate
- WeChat Pay payment candidate
- foreign card payment candidate
- restaurant onboarding support
- public menu display
- inbound foreign customer conversion channel

Actual capabilities must be officially verified.

---

## 5. Provider Evidence Required Rule

All partner capability assumptions must remain in evidence-required status until verified.

Required evidence may include:

- official API documentation
- official partner guide
- official payment method list
- settlement term document
- contract or proposal
- sample menu mapping payload
- sample payment flow
- test account or sandbox evidence
- provider email confirmation
- security documentation
- privacy/data sharing documentation
- support boundary documentation

Marketing claims are not sufficient.

---

## 6. Candidate Capability Register

Candidate capabilities may include:

- `GLOBAL_MENU_TRANSLATION`
- `VERIFIED_MENU_DATASET_MAPPING`
- `GOOGLE_MAPS_RESTAURANT_DISCOVERY`
- `FOREIGN_CUSTOMER_QR_MENU`
- `FOREIGN_CUSTOMER_NFC_ENTRY`
- `ALIPAY_PAYMENT`
- `WECHAT_PAY_PAYMENT`
- `FOREIGN_CARD_PAYMENT`
- `IN_APP_PARTNER_PAYMENT_MODULE`
- `PARTNER_SETTLEMENT_REPORT`
- `TOURISM_CHANNEL_MENU_PROJECTION`
- `EXTERNAL_PUBLIC_MENU_PAGE`

Each capability must have evidence status.

---

## 7. Capability Status Values

Recommended capability status values:

- `CAPABILITY_ASSUMED`
- `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`
- `CAPABILITY_DOC_RECEIVED`
- `CAPABILITY_CONTRACT_REVIEW_REQUIRED`
- `CAPABILITY_API_REVIEW_REQUIRED`
- `CAPABILITY_PAYMENT_REVIEW_REQUIRED`
- `CAPABILITY_SECURITY_REVIEW_REQUIRED`
- `CAPABILITY_LEGAL_REVIEW_REQUIRED`
- `CAPABILITY_TEST_REQUIRED`
- `CAPABILITY_APPROVED_FOR_PLANNING`
- `CAPABILITY_APPROVED_WITH_CONDITIONS`
- `CAPABILITY_REJECTED`
- `CAPABILITY_DEFERRED`

Assumed capability cannot enter implementation planning.

---

## 8. Domestic And Foreign Payment Split Rule

Payment routing may be designed as a hybrid candidate.

Candidate strategy:

- domestic customers use Toss Payments or domestic POS/payment route
- domestic simple payments may include Naver Pay, Kakao Pay, domestic card network if supported
- foreign tourists may use Redtable-type global payment route if officially supported
- global payment may include Alipay, WeChat Pay, foreign card network if officially supported
- routing decision may depend on customer locale, payment method selection, entry channel, and payment provider availability

This routing remains candidate until provider evidence is confirmed.

---

## 9. Toss Payments Coexistence Rule

Toss Payments and Redtable-type partner routes should coexist without mixing truth ownership.

Toss route may be responsible for:

- domestic payment attempt
- domestic payment callback
- domestic settlement evidence
- domestic payment reconciliation
- domestic payment margin strategy if commercially valid

Redtable-type route may be responsible for:

- foreign payment candidate flow
- global payment module candidate
- partner settlement evidence
- foreign customer payment support path

Both routes must map into Yoonsul canonical Payment Runtime.

---

## 10. Payment Runtime Ownership Rule

Regardless of provider, Yoonsul Payment Runtime remains the canonical internal payment state owner.

External providers may send:

- payment attempt result
- payment pending status
- payment success callback
- payment failure callback
- cancellation/refund event if supported
- settlement report
- provider reference

External providers must not directly mutate Yoonsul order, KDS, refund, or settlement truth without validation.

---

## 11. Partner Payment Module Boundary Rule

If Redtable-type partner payment is embedded in-app, the boundary must be explicit.

The module must define:

- entry point
- customer locale
- payment method selected
- provider session id
- payment attempt id
- callback result
- settlement reference
- failure status
- cancellation/refund support
- support boundary
- evidence output
- security review

In-app payment module must not become invisible black box.

---

## 12. Foreign Payment Method Candidate Rule

Foreign payment methods may include:

- Alipay
- WeChat Pay
- UnionPay candidate if supported
- Visa/Mastercard/JCB/Amex foreign card candidate if supported
- other regional wallet candidates if supported

Each method requires:

- provider evidence
- fee structure
- settlement currency
- refund support
- dispute handling
- customer message
- i18n support
- legal/security review

No payment method should be advertised until confirmed.

---

## 13. Settlement Boundary Rule

Partner settlement must be separated from internal payment state.

Settlement review should define:

- who collects money
- who settles to store
- settlement timing
- settlement currency
- exchange rate handling
- fee deduction
- refund deduction
- chargeback/dispute handling
- invoice/report format
- accounting evidence
- commercial margin impact

Settlement is finance truth, not UI convenience.

---

## 14. Margin And Back-Margin Boundary Rule

If domestic payment route creates commercial margin or holding-company revenue, this must remain separate from runtime payment truth.

Commercial margin tracking must not distort:

- customer payment status
- order status
- refund status
- KDS release
- settlement evidence
- tax/accounting evidence
- provider reconciliation

Revenue strategy must not alter payment integrity.

---

## 15. Menu Translation Partner Rule

Redtable-type partner may support menu translation by mapping Korean menu items to a verified multilingual menu dataset.

Candidate flow:

    Korean menu item registered
        -> menu item key created
        -> partner lookup or translation dataset query
        -> candidate translated menu content returned
        -> Yoonsul review or approval
        -> content registry mapping
        -> locale-specific menu board display
        -> external projection if approved

Partner translation is candidate content until approved.

---

## 16. Menu Translation Source Of Truth Rule

Yoonsul content registry remains canonical.

Partner data may be:

- candidate translation
- reference translation
- external display projection
- search/discovery enrichment
- public description candidate

Partner data must not overwrite canonical menu content without review.

---

## 17. Menu Mapping Rule

Korean menu to partner dataset mapping should preserve:

- menu item key
- Korean source name
- menu category
- ingredient summary
- allergen indicators
- dietary indicators
- cooking method if relevant
- translated name candidates
- translated description candidates
- confidence or match score if available
- reviewer decision
- version

Mapping must avoid false menu equivalence.

---

## 18. Menu Translation Review Rule

Human or owner review is required for:

- new menu item translation
- allergen-related translation
- pork/beef/chicken/seafood indicator
- spicy/salt level statement
- health or dietary claim
- high-risk menu content
- external publishing
- partner dataset mismatch
- AI-generated translation

Verified dataset may reduce review burden but should not eliminate responsibility for sensitive fields.

---

## 19. Allergen And Dietary Safety Rule

External menu translation must not weaken allergen or dietary clarity.

Required checks:

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
- vegetarian candidate
- vegan candidate
- halal-friendly candidate

External partner content must not imply certainty beyond verified data.

---

## 20. External Menu Projection Rule

Approved translated menu content may be projected to:

- QR menu
- NFC menu entry
- customer web menu
- Mini Kiosk
- Google Maps landing
- external restaurant discovery platform
- tourism channel
- partner landing page
- translated menu board

Projection must use approved public content only.

---

## 21. Google Maps Discovery Rule

If customer enters from Google Maps or map-aligned discovery flow, the system should support:

- locale-aware store page
- translated menu
- public item descriptions
- allergen/diet indicators
- ordering or waiting path
- payment method guidance
- foreign customer support path
- partner payment availability if confirmed
- fallback language

Discovery should become understandable ordering.

---

## 22. NFC Foreign Customer Entry Rule

Foreign customer NFC entry may route to:

- locale detection
- language selection
- translated menu board
- foreign payment method availability
- order guidance
- staff help path
- customer support message
- safe error message
- fallback payment route

NFC entry should not assume the customer understands Korean.

---

## 23. QR Foreign Customer Entry Rule

QR entry may support the same flow as NFC.

QR entry should include:

- public landing
- locale selection
- translated menu
- payment method guidance
- staff help
- error recovery
- fallback locale
- support path

QR/NFC should share content registry.

---

## 24. Partner Data Package Rule

Partner data package may include:

- public store key
- store display name
- public address or map link
- opening hours
- public menu category
- menu item key
- translated name
- translated description
- public price display
- allergen/diet indicators
- image URL if approved
- availability projection if approved
- order/waiting link
- content version
- last updated time

Partner package must be public-only.

---

## 25. Partner Prohibited Data Rule

Partner package must not include:

- customer identity
- CI/DI
- payment data
- support cases
- audit events
- evidence packets
- provider secrets
- POS raw data
- KDS raw data
- staff private data
- internal margin
- supplier cost
- hidden menu experiments unless approved
- internal incident data

External partner must not receive operational private data.

---

## 26. Partner Availability Projection Rule

If partner displays availability, sold-out, or orderability, the source must be controlled.

Availability projection must define:

- source runtime
- freshness
- stale threshold
- fallback display
- sold-out confirmation
- provider sync dependency
- manual override boundary
- public display wording
- evidence if dispute occurs

Stale availability can damage trust.

---

## 27. Global Payment Message I18n Rule

Global payment messages must be i18n-ready.

Messages should include:

- payment method available
- payment method unavailable
- payment pending
- payment confirmed
- payment failed
- payment uncertain
- refund review required
- provider delay
- support needed
- alternative payment path

Foreign customer must understand payment state.

---

## 28. Global Payment Error Code Rule

Global payment errors should follow OS message code hierarchy.

Example candidate:

    YS-PAY-PRV-CAPTURE-REDTABLE-ALIPAY_PENDING-W01
    YS-PAY-PRV-CALLBACK-REDTABLE-WECHAT_STALE-E03
    YS-PAY-PRV-RECONCILE-REDTABLE-FOREIGN_CARD_MISMATCH-C03

Actual provider code naming may be normalized later.

Error code must be traceable and i18n-ready.

---

## 29. Provider Callback Rule

If partner payment callback exists, it must define:

- event source
- authentication/signature
- timestamp
- provider payment id
- Yoonsul payment attempt id
- idempotency key
- duplicate behavior
- stale behavior
- failure behavior
- reconciliation path
- evidence output

Callback without idempotency is blocked.

---

## 30. Refund Cancel Rule

Partner payment refund/cancel support must be verified.

Review must confirm:

- refund availability
- cancel availability
- partial refund support
- refund timing
- customer message
- settlement effect
- provider fee effect
- dispute/chargeback handling
- support path
- evidence record

Refund/cancel cannot be assumed from payment success.

---

## 31. Support Boundary Rule

Support boundary must define who handles:

- payment failure
- payment uncertainty
- refund request
- partner payment app issue
- foreign customer language support
- menu translation issue
- external partner landing issue
- settlement discrepancy
- provider outage
- customer complaint

Yoonsul and partner support roles must not be ambiguous.

---

## 32. Admin Visibility Rule

Admin Console may display:

- partner capability status
- partner evidence status
- global payment route status
- settlement status summary
- translation mapping status
- content version
- external projection status
- partner incident status
- blocker status

Admin must not mutate partner payment truth directly.

---

## 33. Support Console Rule

Support Console may display:

- case-scoped partner payment reference
- masked customer context
- payment state
- provider status summary
- translated customer message
- recovery guidance
- evidence link
- escalation path
- partner contact path if allowed

Support must remain case-scoped.

---

## 34. AI Support Rule

AI support may explain partner flow only from approved source content.

AI support must not:

- claim unverified payment method availability
- give legal/payment final conclusion
- expose provider payload
- expose settlement detail
- invent translation
- approve refund
- bypass support case scope

AI support should cite source and freshness.

---

## 35. Security Review Rule

Security review is required for:

- partner API authentication
- payment callback
- customer locale data
- payment reference mapping
- menu package export
- external landing link
- provider secret handling
- partner admin access if any
- support access to partner data
- AI access to partner data

Partner integration is external data movement.

---

## 36. Legal Review Rule

Legal review is required for:

- global payment acceptance
- settlement responsibility
- refund/dispute obligations
- foreign customer notices
- privacy/data sharing
- external partner terms
- menu/allergen statements
- dietary claims
- tourism platform claims
- commercial revenue sharing

Foreign customer flow creates legal exposure.

---

## 37. Commercial Review Rule

Commercial review must define:

- partner fee
- payment processing fee
- settlement fee
- revenue share
- back-margin effect
- domestic versus foreign payment route strategy
- store fee impact
- HQ fee impact
- pilot pricing
- commercial promise boundary

Commercial strategy must not distort payment truth.

---

## 38. Provider Evidence Blocker Rule

Create blocker when:

- partner API evidence missing
- payment method support unverified
- settlement terms unknown
- callback behavior unknown
- refund behavior unknown
- translation dataset behavior unknown
- data sharing boundary unclear
- external menu package format unknown
- security review missing
- legal review missing

Partner module cannot proceed without evidence.

---

## 39. I18n Blocker Rule

Create blocker when:

- translated menu source unclear
- menu mapping unreviewed
- allergen translation missing
- payment messages not localized
- fallback language missing
- partner display uses stale content
- external menu version missing
- AI support translation ungrounded
- foreign customer recovery message missing

I18n blocker stops foreign customer flow.

---

## 40. Payment Blocker Rule

Create blocker when:

- global payment route unclear
- Toss/Redtable routing unclear
- provider callback unclear
- idempotency missing
- duplicate/stale handling missing
- reconciliation missing
- refund/cancel behavior unverified
- settlement evidence missing
- support path missing

Payment blocker stops payment route planning.

---

## 41. Pilot Rule

Redtable-type module pilot must be limited.

Pilot should define:

- selected store
- selected menu items
- selected locales
- selected payment methods
- selected customer entry path
- partner evidence scope
- support path
- rollback path
- external projection scope
- daily learning review

Pilot must not imply full global rollout.

---

## 42. Rollback Rule

Rollback must define:

- disable partner menu projection
- disable partner payment route
- fall back to Toss/domestic payment if appropriate
- fall back to staff-assisted payment
- unpublish stale external menu
- disable AI partner answers
- create support notice
- preserve evidence
- notify partner if needed

Rollback protects customer trust.

---

## 43. Data Capture Rule

Safe data capture may include:

- locale selected
- partner entry source
- translated menu viewed
- payment method selected
- payment success/failure/uncertainty
- support case type
- translation issue report
- partner referral conversion
- external menu stale issue
- refund/dispute count
- reconciliation mismatch

Data capture must respect privacy.

---

## 44. Build Gate Input Rule

Build gate should receive:

- partner capability status
- provider evidence status
- menu translation mapping status
- global payment route status
- Toss coexistence status
- settlement review status
- security review status
- legal review status
- commercial review status
- i18n blocker status
- payment blocker status
- pilot scope
- rollback path

Build gate must not accept unverified partner assumptions.

---

## 45. Registers Recommendation

Recommended future files:

    docs/_index/
      Redtable_Type_Partner_Capability_Register.md
      Global_Menu_Translation_Partner_Register.md
      Partner_Menu_Mapping_Register.md
      External_Menu_Projection_Partner_Register.md
      Google_Maps_Menu_Landing_Partner_Register.md
      Global_Payment_Route_Register.md
      Toss_Redtable_Payment_Coexistence_Register.md
      Partner_Settlement_Review_Register.md
      Partner_Provider_Evidence_Register.md
      Partner_Security_Legal_Review_Register.md
      Partner_Pilot_Readiness_Register.md
      Partner_Rollback_Register.md

This document only recommends these files.

It does not create them.

---

## 46. Anti-Patterns

The following are prohibited:

- assuming Redtable capabilities without official evidence
- letting partner become canonical menu owner
- letting partner directly mutate Yoonsul payment truth
- letting partner directly affect KDS without validation
- exposing customer identity to menu partner
- exposing CI/DI to partner
- exposing provider secrets to partner
- using stale partner menu content
- advertising Alipay/WeChat Pay support before verified
- mixing domestic payment margin strategy into payment truth
- treating foreign payment callback as trusted without idempotency
- using unreviewed translated allergen text
- letting AI support claim unverified partner capability

---

## 47. No-Code Boundary

This document does not authorize:

- Redtable API integration
- partner contract execution
- global payment implementation
- Alipay implementation
- WeChat Pay implementation
- foreign card implementation
- Toss routing implementation
- external menu projection implementation
- Google Maps landing implementation
- translated menu publishing
- provider callback implementation
- production pilot

This document defines partner module planning policy only.

---

## 48. Readiness Check

This document is ready when the project can answer:

1. What is Redtable-type partner?
2. What provider evidence is required?
3. What candidate capabilities exist?
4. What capability status values exist?
5. What domestic/foreign payment split rule applies?
6. What Toss coexistence rule applies?
7. What Payment Runtime ownership rule applies?
8. What partner payment module boundary applies?
9. What foreign payment method candidate rule applies?
10. What settlement boundary rule applies?
11. What margin/back-margin boundary rule applies?
12. What menu translation partner rule applies?
13. What menu translation source-of-truth rule applies?
14. What menu mapping rule applies?
15. What menu translation review rule applies?
16. What allergen/dietary safety rule applies?
17. What external menu projection rule applies?
18. What Google Maps discovery rule applies?
19. What NFC foreign customer entry rule applies?
20. What QR foreign customer entry rule applies?
21. What partner data package rule applies?
22. What partner prohibited data rule applies?
23. What partner availability projection rule applies?
24. What global payment message i18n rule applies?
25. What global payment error code rule applies?
26. What provider callback rule applies?
27. What refund/cancel rule applies?
28. What support boundary rule applies?
29. What Admin visibility rule applies?
30. What Support Console rule applies?
31. What AI Support rule applies?
32. What security review rule applies?
33. What legal review rule applies?
34. What commercial review rule applies?
35. What provider evidence blocker rule applies?
36. What i18n blocker rule applies?
37. What payment blocker rule applies?
38. What pilot rule applies?
39. What rollback rule applies?
40. What data capture rule applies?
41. What build gate input rule applies?
42. What registers are recommended?
43. What anti-patterns are prohibited?
44. What no-code boundary applies?

If these questions cannot be answered, Redtable-type global menu translation and payment partner module planning is incomplete.

---

## 49. Conclusion

Redtable-type partner integration can become a strategic bridge between Yoonsul/Catch Menu and foreign customers.

The safe partner flow is:

    Korean menu source
        -> Yoonsul menu key
        -> partner translation dataset candidate
        -> review and mapping
        -> multilingual menu registry
        -> QR/NFC/Google Maps/external projection
        -> foreign customer order/payment route
        -> validated global payment callback
        -> Yoonsul Payment Runtime
        -> evidence, support, settlement, and learning

This document ensures that global menu translation, foreign customer discovery, Alipay/WeChat Pay/foreign card payment candidates, Toss coexistence, partner settlement, external menu projection, and Google Maps landing can be planned without surrendering Yoonsul runtime authority, payment truth, menu source-of-truth, customer privacy, or commercial control.