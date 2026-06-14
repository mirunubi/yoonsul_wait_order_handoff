# 10723_Legal_Notice_i18n_Review_And_Controlled_Translation_Policy

## 1. Purpose

This document defines the Legal Notice i18n Review, Controlled Translation, Locale Fallback, Korean Controlling Text, Customer Surface Localization, Admin Review, Evidence Snapshot, and Translation Governance Policy for Catch Menu.

The previous document `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy` defined refund, cancellation, no-show, deposit, payment error, substitution, dispute evidence, and support SOP governance.

This document focuses on legal notice localization because Catch Menu, table order, kiosk, app order, and future franchise OS surfaces must support multilingual users while preserving legal accuracy.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Legal notice translation is not ordinary UI translation.

The correct rule is:

Legal notice text must be versioned.  
Legal notice translation must be reviewed.  
Machine translation is draft only.  
Customer locale display must record the exact language and version shown.  
Korean may remain the controlling legal text where policy requires.  
Translated notice must not alter legal meaning.  
Fallback language must be explicit.  
A missing translation must not silently suppress a mandatory notice.  
AI may suggest translation, but AI cannot approve legal translation.  

Legal i18n is a compliance workflow, not a convenience feature.

---

## 3. Scope

This policy applies to:

- legal notice master text
- short popup text
- full policy text
- checkbox labels
- receipt notices
- menu detail legal notices
- alcohol notices
- privacy consent text
- refund/cancellation notices
- no-show/deposit notices
- allergen/food safety notices
- review/content notices
- coupon/event notices
- hardware/device notices
- disaster/force majeure notices
- staff guidance
- admin guidance
- support summaries
- customer-facing multilingual surfaces
- legal notice evidence packets

This policy defines governance only.

It is not a runtime implementation.

---

## 4. Translation Object Boundary

Each legal notice version may have multiple localized text objects.

A localized text object must define:

| Field | Meaning |
|---|---|
| `notice_id` | Notice identity |
| `notice_version_id` | Exact notice version |
| `locale` | Locale such as `ko-KR`, `en-US`, `ja-JP`, `zh-CN` |
| `text_variant` | Short popup, full policy, checkbox, receipt, etc. |
| `text_body` | Localized text |
| `translation_state` | Draft, machine, reviewed, approved |
| `controlling_language_flag` | Whether this text controls legal interpretation |
| `reviewed_by` | Reviewer |
| `approved_by` | Approver |
| `effective_from` | Effective start |
| `effective_to` | Effective end |
| `text_hash` | Integrity hash |
| `audit_ref` | Audit reference |

Translation must be tied to a notice version.

---

## 5. Locale Strategy

Recommended initial locale strategy:

| Locale | Usage |
|---|---|
| `ko-KR` | Korean reference and controlling text |
| `en-US` | English customer support and foreign customer surfaces |
| `ja-JP` | Japanese customer surface |
| `zh-CN` | Simplified Chinese customer surface |
| `zh-TW` | Traditional Chinese customer surface if needed |
| `vi-VN` | Vietnamese staff/customer support if needed |
| `th-TH` | Thai customer support if needed |
| `id-ID` | Indonesian customer support if needed |
| `fil-PH` | Filipino customer support if needed |
| `mn-MN` | Mongolian customer support if needed |

Locale expansion must be controlled by business need and review capacity.

---

## 6. Text Variant Strategy

Legal notices should not use one text body for all surfaces.

Recommended variants:

| Variant | Usage |
|---|---|
| `SHORT_POPUP` | Short high-risk popup |
| `FULL_POLICY` | Full notice center text |
| `CHECKBOX_LABEL` | Consent checkbox label |
| `MENU_MODAL` | Menu detail notice |
| `CHECKOUT_NOTICE` | Cart/checkout notice |
| `RECEIPT_NOTE` | Receipt/order history |
| `ADMIN_GUIDANCE` | Admin configuration explanation |
| `STAFF_GUIDANCE` | Staff action guidance |
| `SUPPORT_SUMMARY` | Support case summary |
| `ACCESSIBILITY` | Screen reader optimized text |

Each variant may require separate review.

---

## 7. Translation State Registry

Recommended translation states:

| State | Meaning |
|---|---|
| `NOT_STARTED` | No translation |
| `MACHINE_DRAFT` | Machine/AI draft |
| `HUMAN_DRAFT` | Human draft |
| `I18N_REVIEW_PENDING` | Translation review pending |
| `LEGAL_REVIEW_PENDING` | Legal meaning review pending |
| `APPROVED` | Approved for use |
| `ACTIVE` | Currently used |
| `SUPERSEDED` | Replaced |
| `DEPRECATED` | Not usable |
| `BLOCKED` | Must not display |
| `FALLBACK_REQUIRED` | Approved translation missing |

Only approved/active translation may be used for critical legal surfaces.

---

## 8. Korean Controlling Text Policy

For legal notice families where Korean law and Korean store operations govern, Korean text may be designated as controlling.

Recommended rule:

    If translated text and Korean text conflict, the approved Korean text controls unless a legally reviewed multilingual controlling policy says otherwise.

Customer-facing text may include:

- localized explanation
- Korean controlling text link
- short notice that Korean version controls
- support inquiry route

This must be clear and not misleading.

---

## 9. Machine Translation Boundary

Machine translation may be used only as draft.

Rules:

- machine translation cannot be final legal text
- AI translation must be marked `MACHINE_DRAFT`
- legal/high-risk text requires human/legal review
- privacy consent requires review
- alcohol notice requires review
- refund/no-show notice requires review
- allergen/food safety notice requires review
- support/staff guidance may use draft only internally if marked
- production customer surface requires approved state unless low-risk fallback policy permits otherwise

AI translation is suggestion, not approval.

---

## 10. Review Requirements By Notice Family

Recommended review requirement:

| Notice Family | Translation Review | Legal Review |
|---|---:|---:|
| Food safety/allergen | Required | Required for high-risk |
| Alcohol/youth protection | Required | Required |
| Privacy/terms | Required | Required |
| Payment/refund/no-show | Required | Required |
| Review/content/IP | Required | Required for enforcement wording |
| Coupon/event | Required | Optional/required by risk |
| Store/facility | Required | Required for high-risk |
| Hardware/device | Required | Optional |
| Tax/receipt | Required | Required |
| Staff protection | Required | Required |
| Disaster/force majeure | Required | Required for liability text |
| Admin guidance | Required | Optional |
| Support summary | Required | Optional/legal if dispute-sensitive |

High-risk notices must not bypass review.

---

## 11. Critical Surface Fallback Policy

If approved translation is missing:

| Surface | Behavior |
|---|---|
| Alcohol age popup | Block or show approved Korean controlling text with support note |
| Privacy required consent | Block if no approved customer-understandable text policy exists |
| Payment/refund checkout | Show approved Korean controlling text and require review fallback |
| Allergen high-risk modal | Show approved Korean controlling text and safe icon/tag |
| Raw food warning | Show approved Korean controlling text if translation missing |
| Coupon low-risk notice | Show Korean or legal center fallback |
| Hardware low-risk notice | Show Korean or simple icon notice |
| Footer legal center | Show Korean reference if translation missing |
| Staff guidance | Show Korean and internal support note |
| Support case | Show original language and Korean reference |

Missing translation must not hide mandatory notice.

---

## 12. Locale Selection Flow

Recommended locale selection flow:

1. Use authenticated customer language preference if available.
2. Use session-selected language if available.
3. Use device/browser locale if reliable.
4. Use store default language if configured.
5. Use Korean fallback.
6. For legal critical notice, show Korean controlling text where required.
7. Record locale actually shown in evidence.

Locale selection must not change legal version identity.

---

## 13. Evidence Snapshot For Localized Notice

When a localized legal notice is shown, evidence must record:

| Field | Meaning |
|---|---|
| `notice_id` | Notice |
| `notice_version_id` | Notice version |
| `locale` | Locale shown |
| `text_variant` | Variant shown |
| `translation_state` | Approved/fallback state |
| `controlling_language_flag` | Whether controlling text shown |
| `text_hash` | Hash of shown text |
| `fallback_used` | Whether fallback used |
| `fallback_reason` | Missing translation, blocked, etc. |
| `shown_at` | Display time |
| `acknowledged_at` | Ack time if required |
| `surface_id` | Surface |
| `session_id` | Session |
| `order_id` | Order if applicable |
| `audit_ref` | Audit reference |

Evidence must prove exactly what language and text were shown.

---

## 14. Customer-Facing Translation Quality Rules

Customer-facing legal notice translation must be:

- accurate
- plain enough to understand
- not overly threatening
- consistent with Korean controlling text
- consistent with POS/payment behavior
- consistent with customer rights
- culturally clear
- short enough for popup where needed
- complete enough in full notice center
- reviewed before use

Legal clarity and customer comprehension must both be protected.

---

## 15. Staff Guidance Translation

Staff guidance may include:

- ID verification steps
- refund/no-show dispute handling
- allergy inquiry response
- raw food warning response
- device damage incident guide
- customer abuse escalation guide
- foreign customer explanation
- translation conflict guidance
- support escalation wording

Staff guidance must distinguish:

- customer-facing text
- internal guidance
- legal escalation note
- prohibited staff statements

Staff must not improvise legally risky wording.

---

## 16. Admin Guidance Translation

Admin guidance should help owners understand:

- what the notice means
- when it is triggered
- where it appears
- whether it is mandatory
- whether it requires acknowledgement
- whether HQ/legal review is needed
- whether the store can toggle it
- what happens if disabled
- what customer sees
- what evidence is stored

Admin guidance is not the legal notice itself.

---

## 17. Support Summary Translation

Support summaries should show:

- original notice text
- translated text shown to customer
- Korean controlling text
- version
- locale
- fallback state
- acknowledgement evidence
- dispute context

Support must know whether a customer saw translated text or only Korean fallback text.

---

## 18. i18n Key Naming Rule

Recommended key pattern:

    legal.notice.<family>.<notice_code>.<variant>

Examples:

| Key | Meaning |
|---|---|
| `legal.notice.food.FOOD_ALLERGEN_001.short_popup` | Short allergen popup |
| `legal.notice.alcohol.ALCOHOL_ID_011.checkbox_label` | Alcohol ID checkbox |
| `legal.notice.payment.PAYMENT_CANCEL_036.checkout_notice` | Checkout cancellation notice |
| `legal.notice.privacy.PRIVACY_REQUIRED_027.full_policy` | Privacy collection full text |
| `legal.notice.refund.NO_SHOW_042.receipt_note` | No-show deposit receipt note |
| `legal.notice.device.DEVICE_DAMAGE_142.menu_modal` | Device damage notice |

Keys must be stable and not contain store-specific text.

---

## 19. Store-Specific Variable Interpolation Boundary

Some notices require store variables.

Examples:

- waiting grace minutes
- no-show cutoff time
- parking free hours
- corkage fee amount
- child age threshold
- dining time limit
- deposit amount
- refund tier timing
- sale time
- phone number
- support channel

Variable interpolation rules:

| Rule | Meaning |
|---|---|
| Use named variables | `{grace_minutes}` |
| Validate variable type | Number, money, time, date |
| Review variable range | Avoid absurd values |
| Store variable separately | Do not edit legal master text |
| Snapshot rendered text | Evidence records final text/hash |
| i18n formatting | Locale-specific money/time format |

Store-specific variables must not mutate master legal text.

---

## 20. Variable Example

Template:

    Waiting calls expire after {grace_minutes} minutes.

Store configuration:

| Variable | Value |
|---|---|
| `grace_minutes` | 5 |

Rendered text:

    Waiting calls expire after 5 minutes.

Evidence must store:

- template version
- variable values
- rendered text hash

---

## 21. Translation Change Control

When a translation changes:

1. Create new localized text version or new notice version if meaning changes.
2. Mark previous translation superseded.
3. Review changed text.
4. Approve new translation.
5. Set effective date.
6. Future displays use new translation.
7. Past evidence remains tied to old text hash.
8. Re-consent policy is evaluated if meaning materially changed.

Translation changes must not rewrite past acknowledgements.

---

## 22. Material Meaning Change Boundary

A translation change may be material if it changes:

- cancellation eligibility
- refund rights
- privacy purpose
- third-party recipient
- marketing consent scope
- alcohol age confirmation
- customer liability
- store liability
- deposit forfeiture
- dispute process
- health/allergen warning
- data retention
- withdrawal method

Material change may require re-notice or re-consent.

---

## 23. Translation QA Checklist

Each translated legal notice should be checked for:

1. Same legal meaning as Korean reference.
2. Same consent scope.
3. Same required/optional status.
4. Same refund/cancel consequence.
5. Same privacy purpose.
6. Same retention period.
7. Same third-party recipient.
8. Same alcohol age requirement.
9. Same warning severity.
10. No added legal promise.
11. No removed customer right.
12. No unsupported immunity claim.
13. Correct variable placement.
14. Correct number/money/time formatting.
15. Correct tone for popup.
16. Correct surface variant.
17. Correct i18n key.
18. Reviewer and approval recorded.

---

## 24. Accessibility Translation Boundary

Accessibility text should be:

- screen-reader friendly
- concise
- complete enough for required consent
- not dependent only on color/icon
- able to read variable values
- language-tagged
- consistent with visual notice
- evidence-recorded if used for consent

Accessibility variant may differ in wording but must preserve meaning.

---

## 25. Translation And Legal Notice Center

Legal Notice Center must support:

- language selection
- Korean controlling text access
- localized text
- notice family tabs
- version display if needed
- effective date if needed
- search
- customer support link
- printable/shareable view if required
- low-bandwidth view for table order

Notice Center should not replace required popups for high-risk notices.

---

## 26. Translation And Receipt

Receipt legal notices must be compact.

Receipt text may include:

- refund status
- VAT/PG notice
- cancellation/refund reference
- no-show/deposit status
- alcohol verification status if appropriate
- legal notice link
- policy version reference if needed

Receipt translation must not create conflict with payment record.

---

## 27. Translation And Dispute Evidence

For disputes, support must view:

- customer locale
- translated text shown
- Korean controlling text
- fallback used or not
- text hash
- notice version
- acknowledgement event
- customer action
- support summary
- translation review state at time

Dispute evidence must not depend on live current translation.

---

## 28. Translation And Tenant Scope

Tenant/franchise may have localized brand wording, but:

- platform legal notice meaning must not be weakened
- HQ-approved template must be preserved
- store variables must be separate
- tenant text cannot override mandatory legal text without review
- tenant-specific translation must be scoped
- cross-tenant text leakage is prohibited

Tenant localization is not free legal editing.

---

## 29. Translation And AI Menu Intake

AI menu intake may detect:

- foreign-language menu names
- ingredient synonyms
- allergen terms
- alcohol brands
- raw food terms
- spicy terms
- market price terms
- health claim terms

AI may recommend localized notices.

AI must not approve legal notice translations.

Detected language and customer display locale are separate concepts.

---

## 30. Translation And Privacy Consent

Privacy consent translation is especially sensitive.

Privacy translations must preserve:

- collected items
- purpose
- retention period
- third-party recipient
- optional/required status
- withdrawal method
- effect of refusal
- overseas transfer notice if applicable
- marketing channel separation

Privacy consent should not be shown in unapproved translation for production signup.

---

## 31. Translation And Alcohol Notice

Alcohol notice translation must preserve:

- age requirement
- ID check requirement
- refusal consequence
- proxy purchase prohibition
- fake ID warning
- delivery restriction
- staff verification route
- Korean legal controlling version if needed

Alcohol notice must fail closed if translation is unavailable and policy requires clear acknowledgement.

---

## 32. Security Boundary

Legal i18n data is compliance-sensitive.

Security rules:

- only authorized translators/reviewers can edit
- legal/high-risk translations require approval
- AI draft must be labeled
- translation access is audited
- tenant-specific translations are scoped
- text hashes are stored
- old translations are not deleted
- support cannot edit translation evidence
- bulk translation import requires authority
- production promotion requires review state

Translation is part of compliance control.

---

## 33. Anti-Patterns

Avoid:

- treating machine translation as final legal notice
- showing unreviewed translation for privacy consent
- showing alcohol warning only in unsupported language
- changing translation without versioning
- editing master Korean text to fit translation
- embedding store variables directly into master text
- losing text hash in evidence
- showing translated text but recording only Korean version
- hiding Korean controlling text when policy requires it
- using one long full policy text as popup
- omitting customer rights in translation
- adding excessive liability waiver in translation
- letting store owner freely rewrite legal translation
- using current translation to explain old dispute
- not recording fallback usage

These anti-patterns must be blocked in future runtime design.

---

## 34. Runtime Deferral

This document defines legal notice i18n review, controlled translation, fallback, evidence, and governance only.

It does not authorize:

- translation database implementation
- i18n runtime
- fallback runtime
- translation review workflow implementation
- legal notice center implementation
- customer language selector
- evidence hash implementation
- admin translation UI
- support translation evidence UI
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 35. Validation Checklist

Validation must confirm:

1. Translation object boundary is defined.
2. Locale strategy is defined.
3. Text variant strategy is defined.
4. Translation state registry is defined.
5. Korean controlling text policy is defined.
6. Machine translation boundary is defined.
7. Review requirements by notice family are defined.
8. Critical surface fallback policy is defined.
9. Locale selection flow is defined.
10. Evidence snapshot for localized notice is defined.
11. Customer-facing translation quality rules are defined.
12. Staff guidance translation is defined.
13. Admin guidance translation is defined.
14. Support summary translation is defined.
15. i18n key naming rule is defined.
16. Store-specific variable interpolation boundary is defined.
17. Variable example is defined.
18. Translation change control is defined.
19. Material meaning change boundary is defined.
20. Translation QA checklist is defined.
21. Accessibility translation boundary is defined.
22. Translation and legal notice center boundary is defined.
23. Translation and receipt boundary is defined.
24. Translation and dispute evidence boundary is defined.
25. Translation and tenant scope boundary is defined.
26. Translation and AI menu intake boundary is defined.
27. Translation and privacy consent boundary is defined.
28. Translation and alcohol notice boundary is defined.
29. Security boundary is defined.
30. Anti-patterns are listed.
31. Coding remains unauthorized.
32. Runtime remains deferred.

---

## 36. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10720 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy`

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Legal Notice Static Seed Review And Approval Workflow Policy`
- `10726 Legal Notice Evidence Export Support And Dispute Packet Policy`
- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 37. Final Rule

Catch Menu legal notice i18n must be controlled, versioned, reviewed, and evidence-backed.

Machine translation may be used only as draft.

High-risk notices such as privacy consent, alcohol age confirmation, refund/cancellation, no-show deposit, allergen, raw food, tax, staff protection, and force majeure notices require approved translation or controlled fallback.

Customer evidence must record the exact locale, text variant, notice version, translation state, fallback state, and text hash shown.

Korean controlling text may govern where policy requires.

Store-specific variables must be interpolated without mutating legal master text.

Historical translation evidence must never be rewritten.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.