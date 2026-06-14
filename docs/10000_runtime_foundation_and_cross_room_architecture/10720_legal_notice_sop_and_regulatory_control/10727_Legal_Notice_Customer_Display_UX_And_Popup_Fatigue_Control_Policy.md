# 10727_Legal_Notice_Customer_Display_UX_And_Popup_Fatigue_Control_Policy

## 1. Purpose

This document defines the Legal Notice Customer Display UX, Popup Fatigue Control, Contextual Notice Placement, Consent Clarity, Progressive Disclosure, Notice Center, Accessibility, Mobile/Table/Kiosk Surface Design, and Customer Trust Governance Policy for Catch Menu.

The previous document `10726 Legal Notice Evidence Export Support And Dispute Packet Policy` defined legal notice evidence export, dispute packets, support visibility, masking, legal hold, and audit governance.

This document focuses on how legal notices should be displayed to customers without overwhelming the ordering experience.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Legal notices must be visible enough to matter and quiet enough to preserve ordering flow.

The correct rule is:

High-risk notices must appear at the point of risk.  
Low-risk notices should not interrupt ordering.  
A footer link is not enough for required consent.  
A blocking popup is excessive for low-risk information.  
Required consent must be clear and separate.  
Optional consent must not be disguised as required.  
Repeated popups create customer fatigue and reduce comprehension.  
Customer trust is part of legal safety.  
A notice that customers ignore is weak evidence.  
A notice that blocks too much damages store operations.  

Legal notice UX must balance protection, comprehension, speed, and evidence.

---

## 3. Scope

This policy applies to:

- table order screen
- mobile web app
- customer app
- mini kiosk
- full kiosk
- menu detail modal
- cart page
- checkout page
- payment confirmation
- alcohol age popup
- reservation screen
- waiting screen
- pickup screen
- delivery screen
- review screen
- coupon/event screen
- privacy/signup screen
- legal notice center
- receipt/order history
- customer support evidence view
- accessibility mode
- multilingual surfaces

This policy defines UX governance only.

---

## 4. Customer Display Principles

Legal notice display should follow these principles:

1. Show notices when they matter.
2. Do not show irrelevant notices.
3. Use short text for interruption.
4. Use full text in legal notice center.
5. Use progressive disclosure.
6. Separate required and optional consent.
7. Group low-risk notices.
8. Do not group unrelated high-risk consent.
9. Preserve customer rights.
10. Avoid threatening language unless necessary.
11. Record evidence only where appropriate.
12. Respect locale and accessibility.
13. Keep table ordering fast.

---

## 5. Notice Display Levels

Recommended display levels:

| Level | Meaning | Example |
|---|---|---|
| `LEVEL_0_HIDDEN_INTERNAL` | Admin/staff only | Legal review memo |
| `LEVEL_1_LEGAL_CENTER` | Accessible but not interruptive | CCTV, Wi-Fi notice |
| `LEVEL_2_INLINE` | Shown near relevant UI | Allergen badge |
| `LEVEL_3_EXPANDABLE` | Collapsed but visible | Refund policy summary |
| `LEVEL_4_CONTEXTUAL_MODAL` | Popup at risk point | Raw food warning |
| `LEVEL_5_REQUIRED_CONFIRM` | Confirm required | Immediate cooking no-cancel |
| `LEVEL_6_BLOCKING_CONSENT` | Cannot proceed without action | Privacy required consent |
| `LEVEL_7_STAFF_CONFIRM` | Staff must verify | Alcohol ID check |

Display level must match risk and legal need.

---

## 6. Notice Surface Strategy

Recommended surface strategy:

| Surface | Notice UX |
|---|---|
| Menu list | Badges and small labels only |
| Menu detail | Allergen, raw food, spicy, origin link |
| Option selector | Choice-specific warnings |
| Cart | Refund, option, coupon, market price notices |
| Checkout | Payment, cancellation, privacy, deposit notices |
| Alcohol popup | Adult confirmation and ID check notice |
| Reservation | Deposit/no-show/time limit notice |
| Waiting | Call expiry and no-show notice |
| Pickup | Freshness and pickup hold notice |
| Delivery | Packaging, delivery restriction, alcohol restriction |
| Review | Review policy and content warning |
| Coupon | Expiry, stacking, abuse notice |
| Legal center | Full legal notice library |
| Receipt | Compact legal and payment references |

Each surface should use the minimum effective notice.

---

## 7. Popup Fatigue Control

Popup fatigue must be actively controlled.

Rules:

1. Do not show the same low-risk notice repeatedly in one session.
2. Do not stack multiple modals without grouping.
3. Do not use blocking modal for legal center-only notices.
4. Do not show all 200 notices at checkout.
5. Do not interrupt menu browsing unless risk is immediate.
6. Use inline badges for recurring menu warnings.
7. Use confirmation only for irreversible or regulated action.
8. Use receipt note for after-order reference.
9. Use legal notice center for full reference.
10. Use customer settings for preference and accessibility where applicable.

Popup fatigue weakens legal comprehension.

---

## 8. Display Frequency Policy

Recommended frequency policies:

| Frequency | Use Case |
|---|---|
| `EVERY_ACTION` | Alcohol confirmation, payment confirmation |
| `ONCE_PER_ORDER` | Refund/cancellation notice |
| `ONCE_PER_SESSION` | Store CCTV/facility notice |
| `ONCE_PER_MENU_ITEM` | Raw food menu warning |
| `ONCE_PER_CUSTOMER_VERSION` | Privacy terms after version change |
| `ON_FEATURE_USE` | Review/coupon/location feature |
| `ON_SETTING_CHANGE` | Marketing consent toggle |
| `FOOTER_ALWAYS_AVAILABLE` | Full legal policy |
| `RECEIPT_AFTER_ACTION` | Payment/refund note |
| `STAFF_ONLY_ON_EVENT` | Incident guidance |

Frequency must be stored as surface mapping policy.

---

## 9. Notice Grouping Policy

Low-risk notices may be grouped.

Safe grouping examples:

| Group | Included Notices |
|---|---|
| Store Use Guide | CCTV, Wi-Fi, parking, lost item |
| Food Safety Guide | Cross-contamination, origin, storage |
| Payment Guide | Receipt, VAT, PG name |
| Event Guide | Coupon expiry, stacking, gift exchange |
| Device Guide | Tablet handling, timeout, printer issue |

Unsafe grouping examples:

- alcohol adult confirmation with unrelated coupon terms
- privacy required consent with marketing consent
- refund cancellation consent with review policy
- no-show deposit consent hidden in long store notice
- allergen warning buried in full legal center only

High-risk consent must remain distinct.

---

## 10. Progressive Disclosure

Progressive disclosure structure:

1. Short summary near action.
2. Expandable details.
3. Full legal notice center.
4. Receipt/order history reference.
5. Support evidence if dispute occurs.

Example:

    Menu badge: Contains shrimp
    Modal: This menu may contain shellfish allergens.
    Full notice: Allergy and cross-contamination policy.
    Evidence: Notice version shown at order time.

Customers should not be forced to read full policy for every low-risk action.

---

## 11. Menu Detail UX

Menu detail should show:

- allergen badges
- spicy level warning
- raw food warning
- bone/shell warning
- market price state
- origin link
- storage/freshness warning for takeout
- health claim note if applicable
- alcohol flag if applicable
- option-specific notices
- full legal link

Menu detail should not show unrelated privacy/payment policies.

---

## 12. Cart UX

Cart should show:

- order summary
- item-level warnings
- cancellation policy summary
- market-price confirmation
- coupon/point effect
- set/component notices
- alcohol item warning if present
- pickup/delivery freshness notice
- required confirmations if applicable

Cart is the last correction stage before checkout.

---

## 13. Checkout UX

Checkout should show:

- payment amount
- refund/cancellation rule
- no-show/deposit rule if applicable
- PG/payment notice if needed
- privacy/third-party consent if needed
- alcohol confirmation if alcohol exists
- delivery/pickup restriction
- required checkbox only for high-risk notices
- final confirm button

Checkout must not hide irreversible order notice.

---

## 14. Alcohol UX

Alcohol UX must be strict and clear.

Alcohol UX should show:

- adult-only label
- ID check warning
- adult confirmation popup
- staff verification pending state if required
- delivery restriction if applicable
- refusal/cancellation rule
- separate alcohol component in set
- non-alcohol adult beverage distinction if needed

Alcohol confirmation must not be buried in generic terms.

---

## 15. Privacy Consent UX

Privacy consent UX must separate:

- required service terms
- required privacy collection/use
- required third-party provision
- optional marketing use
- optional channel consent
- optional location service

Rules:

- optional checkboxes must not be pre-checked unless legally reviewed
- optional refusal must be easy
- withdrawal method must be visible
- full text must be accessible
- consent version must be recorded
- required and optional must be visually separated

Privacy UX must avoid dark patterns.

---

## 16. Reservation And No-Show UX

Reservation/no-show UX should show:

- reservation time
- grace period
- deposit amount
- cancellation cutoff
- refund tier
- no-show penalty
- late arrival rule
- contact/change route
- required confirmation before deposit payment

No-show penalty must be shown before reservation confirmation.

---

## 17. Pickup And Delivery UX

Pickup/delivery UX should show:

- ready time
- pickup hold time
- freshness/storage warning
- delivery restriction
- alcohol delivery block if applicable
- refund/cancel after prep rule
- packaging notice
- rider/handoff notice if applicable
- contact route

Fresh food disputes often depend on pickup/delivery timing.

---

## 18. Review UX

Review UX should show:

- review eligibility
- copyright/photo notice
- portrait rights notice
- profanity/filter warning
- event abuse condition
- delete/non-restoration notice if deleting
- rights infringement process link

Review policy should not discourage legitimate criticism.

---

## 19. Coupon And Event UX

Coupon/event UX should show:

- coupon validity
- expiration
- applicable store
- stacking rule
- screenshot invalid rule
- first-order rule
- gift exchange/refund rule
- early termination possibility
- abuse restriction

Coupon notice must match actual coupon engine behavior.

---

## 20. Hardware And Device UX

Table tablet/kiosk notices should be light unless incident occurs.

Display examples:

| Situation | UX |
|---|---|
| Idle screen | Small device care notice |
| Help screen | Device handling full notice |
| Timeout approaching | Toast or countdown |
| Network outage | Incident modal |
| Payment pending | Blocking status screen |
| Device damage incident | Staff/support evidence, not customer overload |

Device notices should not interrupt ordinary ordering repeatedly.

---

## 21. Legal Notice Center UX

Legal notice center should provide:

- family tabs
- search
- short summary
- full notice text
- language selector
- Korean controlling text if applicable
- effective date if needed
- contact/support link
- store-specific policies
- platform policies
- privacy/terms links
- accessibility support

Recommended tabs:

| Tab | Content |
|---|---|
| Food Safety | Allergy, raw food, storage |
| Store Use | CCTV, facility, child, pet, parking |
| Payment | Refund, cancellation, receipt |
| Privacy | Terms, data, marketing, location |
| Alcohol | Age, ID, refusal, delivery restriction |
| Review | Content, copyright, abuse |
| Event | Coupon, point, promotion |
| System | Device, network, outage |
| Disaster | Force majeure and exception |

Notice center is reference, not replacement for required popups.

---

## 22. Receipt And Order History UX

Receipt/order history should show:

- final amount
- payment state
- refund/cancel state if any
- coupon/point effect
- legal notice references where relevant
- no-show/deposit status
- PG name notice
- VAT/tax notice
- support contact
- order policy version reference if needed

Receipt text must be compact and accurate.

---

## 23. Accessibility UX

Accessibility requirements:

- legal notices must be screen-reader readable
- required consent must be keyboard/touch accessible
- color cannot be the only warning signal
- icons need labels
- text size must be readable
- modal focus must be controlled
- acknowledgement buttons must be clear
- timeout notices must be accessible
- multilingual text must have language tags
- long legal text must be navigable

Accessibility is part of legal notice effectiveness.

---

## 24. Multilingual UX

Multilingual notice UX must:

- show customer-selected language when approved
- expose Korean controlling text where required
- mark fallback when translation missing
- avoid mixing languages in the same confirmation unless necessary
- preserve meaning across variants
- record locale shown
- provide support route for language confusion
- avoid unreviewed machine translation for high-risk consent

Language clarity affects consent quality.

---

## 25. Tone And Wording UX

Legal notice tone should be:

- clear
- firm where needed
- not overly aggressive
- customer-rights aware
- operationally realistic
- short on popup
- complete in full policy
- consistent with brand trust
- i18n-ready

Avoid wording that sounds like absolute immunity or intimidation.

---

## 26. Customer Trust Boundary

Legal notice should protect trust.

Rules:

- explain reason for high-risk confirmation
- provide help route
- avoid hiding fees
- show refund limits before payment
- show alcohol limits before order
- show allergy warning before item selection
- show no-show penalty before deposit
- distinguish store policy from platform policy
- do not surprise customer after payment

Trust reduces disputes.

---

## 27. Evidence UX Boundary

When acknowledgement is required, UX must make evidence meaningful.

Evidence-friendly UX:

- notice visible before confirm
- checkbox label clear
- full text link accessible
- confirm button unambiguous
- version recorded silently
- locale recorded
- acknowledgement timestamp recorded
- no forced hidden consent
- no misleading button text

A meaningless checkbox is weak evidence.

---

## 28. Admin Preview UX

Admin should preview:

- customer menu modal
- cart notice
- checkout notice
- alcohol popup
- reservation notice
- waiting notice
- legal center tab
- receipt note
- i18n variants
- mobile/tablet/kiosk layout
- popup frequency
- required acknowledgement behavior

Admin preview reduces misconfiguration.

---

## 29. Staff UX Boundary

Staff screens should show:

- concise guidance
- customer-facing wording if needed
- do/don't statements
- escalation action
- evidence capture status
- refusal reason templates
- foreign-language support phrase if needed
- manager call button

Staff should not improvise legal language during disputes.

---

## 30. Support UX Boundary

Support screens should show:

- notice shown
- version
- locale
- surface
- trigger
- acknowledgement
- customer journey timeline
- store setting at time
- current setting difference
- missing evidence warning
- export eligibility
- masking state

Support UX must distinguish evidence from interpretation.

---

## 31. Popup Conflict Resolution

If multiple popups are needed:

| Conflict | UX Resolution |
|---|---|
| Allergen + raw food | Combine if same menu item and safe |
| Refund + payment | Show checkout combined payment policy |
| Alcohol + refund | Alcohol popup first, refund at checkout |
| Privacy + marketing | Separate required and optional sections |
| No-show + deposit | Combine into reservation deposit confirmation |
| Coupon + payment | Show coupon inline, payment modal separately |
| System outage + payment | System outage modal takes priority |
| Emergency evacuation | Emergency notice overrides all |

Priority must be deterministic.

---

## 32. UX Metrics

Future runtime may track:

- notice impressions
- acknowledgement rate
- drop-off rate
- dispute rate after notice
- support cases by notice family
- popup frequency per session
- repeated notice dismissals
- missing acknowledgement incidents
- i18n fallback usage
- customer complaint rate
- owner toggle confusion
- staff escalation rate

Metrics are for improvement, not customer punishment.

---

## 33. Anti-Patterns

Avoid:

- showing all notices in one giant popup
- hiding required consent in footer
- forcing optional marketing consent
- showing allergen warning only after checkout
- showing no-show penalty after deposit payment
- showing alcohol warning only after order acceptance
- repeating the same notice every screen
- using long legal paragraphs in small popup
- using vague confirm button text
- using dark patterns
- using unreviewed translation
- ignoring accessibility
- making notice UX hostile
- collecting acknowledgement without visible text
- using popup fatigue as evidence strategy

These anti-patterns must be blocked in future runtime design.

---

## 34. Runtime Deferral

This document defines legal notice customer display UX and popup fatigue control governance only.

It does not authorize:

- customer UI implementation
- popup runtime
- legal notice center implementation
- accessibility runtime
- i18n runtime
- admin preview UI
- staff UX implementation
- support UX implementation
- evidence capture implementation
- analytics implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 35. Validation Checklist

Validation must confirm:

1. Customer display principles are defined.
2. Notice display levels are defined.
3. Notice surface strategy is defined.
4. Popup fatigue control is defined.
5. Display frequency policy is defined.
6. Notice grouping policy is defined.
7. Progressive disclosure is defined.
8. Menu detail UX is defined.
9. Cart UX is defined.
10. Checkout UX is defined.
11. Alcohol UX is defined.
12. Privacy consent UX is defined.
13. Reservation/no-show UX is defined.
14. Pickup/delivery UX is defined.
15. Review UX is defined.
16. Coupon/event UX is defined.
17. Hardware/device UX is defined.
18. Legal notice center UX is defined.
19. Receipt/order history UX is defined.
20. Accessibility UX is defined.
21. Multilingual UX is defined.
22. Tone and wording UX is defined.
23. Customer trust boundary is defined.
24. Evidence UX boundary is defined.
25. Admin preview UX is defined.
26. Staff UX boundary is defined.
27. Support UX boundary is defined.
28. Popup conflict resolution is defined.
29. UX metrics are defined.
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
- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Legal Notice Static Seed Review And Approval Workflow Policy`
- `10726 Legal Notice Evidence Export Support And Dispute Packet Policy`

It also references:

- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10703 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`
- `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`
- `10731 Customer Notice Center UX Static Surface Index Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 37. Final Rule

Catch Menu legal notice UX must show the right notice, at the right time, on the right surface, in the right language, with the right level of interruption.

High-risk legal notices such as alcohol, privacy, refund/cancellation, no-show deposit, allergen, raw food, and payment notices must appear before the risky action.

Low-risk notices should be available through inline display, expandable sections, receipt notes, or the legal notice center.

Popup fatigue must be actively controlled.

Required consent must be clear, separate, accessible, and evidence-backed.

Legal notice UX must protect the platform and store without damaging customer trust or operational speed.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.