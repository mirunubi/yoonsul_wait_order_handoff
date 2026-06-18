# 010731_Policy_Customer_Notice_Center_UX_Static_Surface_Index

## 1. Purpose

This document defines the Customer Notice Center UX Static Surface Index Policy for Catch Menu.

The previous document `10730 Legal Notice Evidence Packet Static Field Map Policy` defined field-level evidence packet planning for legal notice display, acknowledgement, privacy consent, alcohol verification, refund/no-show, food safety, coupon, review, hardware, disaster, support, export, masking, and tenant isolation.

This document focuses on the customer-facing Notice Center as a static UX surface.

It defines:

- notice center purpose
- tab structure
- surface inventory
- notice family index
- customer language behavior
- store-specific notice visibility
- platform notice visibility
- franchise/HQ notice visibility
- search and filtering
- receipt and order-history linkage
- accessibility
- evidence-safe display
- support linkage
- popup fatigue reduction

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

The Notice Center is the customer-facing legal and operational notice library.

The correct rule is:

Required popups show notices at the point of risk.  
The Notice Center provides full reference and transparency.  
The Notice Center does not replace mandatory consent.  
The Notice Center does not replace checkout confirmation.  
The Notice Center does not replace alcohol age-gate.  
The Notice Center does not replace refund/no-show acknowledgement.  
The Notice Center reduces popup fatigue by giving low-risk notices a stable home.  
The Notice Center must show current notices clearly.  
Historical order evidence must still reference the exact notice version shown at the time.  

The Notice Center is customer transparency infrastructure.

---

## 3. Scope

This policy applies to:

- customer app Notice Center
- mobile web Notice Center
- table order Notice Center
- mini kiosk Notice Center
- full kiosk Notice Center
- store detail legal notice area
- menu detail legal notice links
- cart legal notice link
- checkout legal notice link
- receipt legal notice link
- order history legal notice link
- privacy/terms page
- alcohol notice page
- refund/cancellation notice page
- coupon/event notice page
- review notice page
- support help link

This policy defines static UX planning only.

---

## 4. Notice Center Role

The Notice Center should provide:

| Role | Meaning |
|---|---|
| Transparency | Customer can review applicable notices |
| Reference | Full legal/operational text is accessible |
| Trust | Store and platform rules are visible |
| Popup reduction | Low-risk notices do not need repeated popups |
| Support bridge | Customers can reference notices in disputes |
| i18n support | Customers can read notices in selected language |
| Store context | Store-specific rules are visible |
| Platform context | Platform-wide terms are visible |
| Evidence context | Receipts can link to relevant notice versions |
| Accessibility | Notices remain readable for assistive tools |

The Notice Center is not an execution engine.

---

## 5. Notice Center Entry Points

Recommended entry points:

| Entry Point | Purpose |
|---|---|
| Footer policy link | Always available |
| Store info page | Store-specific rules |
| Menu detail link | Menu-related warnings |
| Cart legal summary | Order-related notices |
| Checkout notice link | Payment/refund/privacy |
| Alcohol popup full text link | Alcohol notice detail |
| Reservation policy link | No-show/deposit details |
| Waiting policy link | Waiting call expiry |
| Pickup policy link | Pickup freshness/hold time |
| Review page link | Review policy |
| Coupon page link | Coupon terms |
| Receipt link | Order-specific notice reference |
| Support case link | Dispute-related notice reference |
| Admin preview link | Owner preview, not customer route |

Entry point must be context-aware.

---

## 6. Notice Center Tab Structure

Recommended tab structure:

| Tab | Included Notice Families |
|---|---|
| `Overview` | Current store/platform key notices |
| `Food Safety` | Allergy, raw food, origin, storage |
| `Store Use` | Facility, CCTV, children, pets, parking |
| `Order And Payment` | Cancellation, refund, PG, receipt |
| `Reservation And Waiting` | Deposit, no-show, waiting call |
| `Privacy And Terms` | Terms, privacy, marketing, location |
| `Alcohol` | Age, ID, proxy order, delivery restriction |
| `Coupon And Event` | Coupon, point, reward, promotion |
| `Review And Content` | Review, copyright, moderation |
| `System And Device` | Tablet, kiosk, network, timeout |
| `Disaster And Exception` | Outage, force majeure, emergency |
| `Language And Accessibility` | Translation, controlling text, accessibility |

Tabs may be simplified on small screens.

---

## 7. Overview Tab

The Overview tab should show:

- platform service terms link
- privacy policy link
- store refund/cancellation summary
- food safety/allergen summary
- alcohol policy if alcohol is enabled
- reservation/no-show summary if reservation is enabled
- pickup/delivery summary if enabled
- coupon/event summary if active
- store facility rules
- support contact route
- last updated date

Overview should be short.

It should link to full details by family.

---

## 8. Food Safety Tab

Food Safety tab should show:

- allergen notice
- cross-contact notice
- raw food warning
- takeout freshness notice
- storage/reheating notice
- spicy level warning policy
- bone/shell warning policy
- menu ingredient disclosure note
- origin display link if applicable
- health claim caution if applicable

Food safety notices should not claim the absence of allergens unless verified.

---

## 9. Store Use Tab

Store Use tab should show:

- CCTV notice
- facility safety notice
- table tablet handling notice
- no-kids-zone or child safety notice if enabled
- pet policy if enabled
- parking notice if available
- dining time limit if configured
- self-bar/waste notice if configured
- lost item notice
- customer conduct notice
- staff protection notice if applicable

Store rules must be store-specific and tenant-scoped.

---

## 10. Order And Payment Tab

Order and Payment tab should show:

- cancellation policy
- refund policy
- immediate cooking cancellation rule
- payment provider notice
- receipt/VAT notice
- coupon/point refund handling
- split payment notice
- market price notice
- duplicate payment support route
- payment error support route
- partial refund policy

Payment notices must match actual POS/payment behavior.

---

## 11. Reservation And Waiting Tab

Reservation and Waiting tab should show:

- waiting call expiry rule
- waiting grace period
- reservation cancellation cutoff
- reservation deposit rule
- no-show policy
- late arrival rule
- group reservation rule
- pickup no-show rule if applicable
- refund/forfeiture summary
- support route for dispute

No-show penalty rules must be visible before reservation or deposit.

---

## 12. Privacy And Terms Tab

Privacy and Terms tab should show:

- service terms
- privacy collection/use
- third-party provision
- processing outsourcing notice
- marketing consent summary
- advertising channel consent summary
- location-based service notice
- cookie/log notice
- app permission guide
- withdrawal/deletion guide
- privacy inquiry route

Required and optional consent must remain separated.

---

## 13. Alcohol Tab

Alcohol tab should show only when alcohol context exists or store enables alcohol.

It should include:

- adult-only notice
- ID verification requirement
- acceptable ID guidance summary
- proxy purchase prohibition
- fake ID warning
- intoxication refusal notice
- alcohol delivery restriction
- pickup verification notice
- alcohol set menu notice
- corkage notice if enabled
- staff verification process summary

Alcohol Notice Center text does not replace age-gate popup.

---

## 14. Coupon And Event Tab

Coupon and Event tab should show:

- coupon validity
- expiration rule
- stacking rule
- first-order coupon rule
- screenshot invalid rule
- gift exchange/refund rule
- event early termination rule
- abuse restriction
- store-specific event rule
- franchise coupon rule if applicable
- point accrual/reversal summary

Coupon notice must match coupon engine behavior.

---

## 15. Review And Content Tab

Review and Content tab should show:

- review eligibility
- copyright/photo upload notice
- portrait rights notice
- profanity/moderation notice
- review event abuse notice
- store reply policy
- deletion/non-restoration notice
- rights infringement report process
- malicious review response route
- content retention summary

Review policy must not suppress legitimate customer criticism.

---

## 16. System And Device Tab

System and Device tab should show:

- table tablet handling notice
- kiosk handling notice
- device timeout notice
- network outage notice
- POS/payment pending notice
- printer/receipt issue notice
- QR/external link caution
- manual fallback notice
- device damage incident process
- system support route

System notices should be written plainly.

---

## 17. Disaster And Exception Tab

Disaster and Exception tab should show:

- force majeure notice
- power/water outage notice
- kitchen equipment failure notice
- weather disaster notice
- server overload notice
- emergency evacuation notice
- ingredient shortage notice
- last-order exception
- refund/cancel route during exception
- support contact

Force majeure notice must not overclaim immunity.

---

## 18. Language And Accessibility Tab

Language and Accessibility tab should show:

- current language
- Korean controlling text notice if applicable
- translation availability
- fallback language explanation
- accessibility guide
- screen reader support note
- large text support if applicable
- customer support language route
- notice version/effective date if needed

Language transparency improves customer trust.

---

## 19. Current Notice Versus Historical Notice

The Notice Center generally shows current active notices.

Order history or dispute view may show historical notices.

Rules:

| View | Notice Version |
|---|---|
| General Notice Center | Current active version |
| Checkout before order | Current applicable version |
| Receipt | Version active at order time or reference |
| Order history | Version active at order time if relevant |
| Support dispute | Exact historical version shown |
| Export packet | Exact historical version shown |

Current Notice Center must not rewrite history.

---

## 20. Store-Specific Notice Display

Store-specific notices may include:

- store refund/cancel setting
- no-show grace period
- pickup hold time
- parking time
- corkage fee
- dining time limit
- pet policy
- child policy
- break time
- last order time
- support phone
- local event rules

Store-specific variables must be rendered from approved templates.

Store-specific text must not directly overwrite platform legal master.

---

## 21. Platform Notice Display

Platform notices may include:

- service terms
- privacy policy
- payment intermediary notice
- PG/payment notice
- platform support notice
- app permission notice
- security/breach notice
- platform-level refund support boundary
- legal notice meta policy
- Korean controlling text policy

Platform notices must not be disabled by store.

---

## 22. Franchise HQ Notice Display

Franchise HQ notices may include:

- brand refund standard
- brand allergen policy
- brand coupon/event policy
- brand review event rules
- brand alcohol policy
- brand customer recovery policy
- brand i18n notice template
- brand store conduct policy

HQ notices must be tenant/franchise-scoped.

They must not leak to unrelated tenants.

---

## 23. Search And Filter

Notice Center search should support:

- keyword search
- notice family filter
- store-specific filter
- platform notice filter
- high-risk notice filter
- language filter
- effective date filter if needed
- menu-related notice filter
- payment-related notice filter
- privacy-related notice filter

Search results must show the current active text unless historical context is requested.

---

## 24. Notice Summary Cards

Each notice card should show:

| Field | Meaning |
|---|---|
| Notice title | Customer-readable title |
| Short summary | Plain language summary |
| Family | Food, payment, privacy, etc. |
| Applies to | Store, platform, feature, menu |
| Required/optional | Whether related consent is required |
| Last updated | Effective date |
| Full text link | Expand full text |
| Language status | Current language/fallback |
| Support link | Ask support if needed |

Cards should avoid legal overload.

---

## 25. Full Notice Detail View

Full detail view should show:

- notice title
- full text
- plain language explanation if allowed
- applies-to scope
- effective date
- version label if appropriate
- Korean controlling text link if applicable
- related customer action
- related support route
- related receipt/order reference if opened from order history
- language selector
- accessibility controls

Full detail view must not expose internal admin fields.

---

## 26. Customer Support Linkage

Notice Center should provide support linkage:

| Context | Support Link |
|---|---|
| Refund notice | Refund/cancel support |
| Privacy notice | Privacy inquiry |
| Alcohol notice | Store/staff assistance |
| Food safety notice | Allergy inquiry |
| Coupon notice | Coupon support |
| Review notice | Review/content support |
| Device notice | Device incident support |
| Disaster notice | Order disruption support |

Support link should preserve context.

---

## 27. Receipt Linkage

Receipt may link to:

- refund/cancel policy version
- PG/payment notice
- coupon/point reversal rule
- no-show/deposit rule
- alcohol verification note if applicable
- market price confirmation if applicable
- store-specific policy reference
- support route

Receipt linkage should not expose unrelated legal notices.

---

## 28. Popup Fatigue Reduction Role

The Notice Center reduces popup fatigue by hosting:

- low-risk store use notices
- long full-policy text
- detailed coupon terms
- detailed privacy policy
- full food safety guide
- full review policy
- system/device help
- disaster policy reference

But high-risk actions still require contextual display.

Notice Center is reference, not consent substitute.

---

## 29. Accessibility Requirements

Notice Center must support:

- readable text size
- screen reader headings
- clear tab order
- language tags
- visible focus
- no color-only warnings
- collapsible sections with accessible labels
- keyboard/touch navigation
- clear close/back actions
- support link accessibility
- mobile/tablet/kiosk readability

Accessibility is required for meaningful notice.

---

## 30. Mobile Table Kiosk Adaptation

Different surfaces require adaptation.

| Surface | Adaptation |
|---|---|
| Mobile web | Searchable tabs, bottom sheet |
| Table tablet | Large touch targets, short tabs |
| Mini kiosk | Simplified Notice Center, key notices |
| Full kiosk | Larger Notice Center with search |
| Customer app | Full Notice Center and settings |
| Receipt/order history | Contextual historical reference |
| Support view | Evidence-focused version reference |

Do not force the same layout on every device.

---

## 31. Evidence Boundary

Notice Center view may create view evidence only when needed.

Rules:

- browsing general Notice Center does not always need evidence capture
- required consent surfaces must capture evidence
- order-specific historical notice views may log access
- support-related notice views may log case context
- privacy consent pages may log shown/accepted/refused
- high-risk notice full-text opens may be recorded if policy requires

Do not over-surveil casual notice browsing.

---

## 32. Admin Preview Boundary

Admin preview of Notice Center should show:

- customer layout
- store-specific variables
- current language
- high-risk badges
- locked notices
- optional notices
- missing translation warnings
- missing surface mapping warnings
- preview mode watermark
- not customer evidence

Admin preview must not create customer evidence.

---

## 33. Anti-Patterns

Avoid:

- using Notice Center as replacement for required consent
- hiding alcohol age-gate only inside Notice Center
- hiding no-show penalty only inside Notice Center
- hiding refund restriction only inside Notice Center
- showing internal admin/legal review notes to customers
- showing unrelated tenant notices
- showing outdated notice as current
- omitting Korean controlling text where required
- making Notice Center unsearchable
- making full text unreadable on kiosk
- capturing excessive evidence for casual browsing
- allowing store custom text to bypass approved templates
- confusing platform notice with store notice
- mixing required and optional consent in one card
- ignoring accessibility

These anti-patterns must be blocked in future runtime design.

---

## 34. Runtime Deferral

This document defines Customer Notice Center UX static surface index planning only.

It does not authorize:

- Notice Center UI implementation
- customer app implementation
- table order UI implementation
- kiosk UI implementation
- search implementation
- receipt linkage implementation
- support linkage implementation
- accessibility runtime
- i18n runtime
- evidence logging runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 35. Validation Checklist

Validation must confirm:

1. Notice Center role is defined.
2. Notice Center entry points are defined.
3. Notice Center tab structure is defined.
4. Overview tab is defined.
5. Food Safety tab is defined.
6. Store Use tab is defined.
7. Order and Payment tab is defined.
8. Reservation and Waiting tab is defined.
9. Privacy and Terms tab is defined.
10. Alcohol tab is defined.
11. Coupon and Event tab is defined.
12. Review and Content tab is defined.
13. System and Device tab is defined.
14. Disaster and Exception tab is defined.
15. Language and Accessibility tab is defined.
16. Current notice versus historical notice boundary is defined.
17. Store-specific notice display is defined.
18. Platform notice display is defined.
19. Franchise HQ notice display is defined.
20. Search and filter are defined.
21. Notice summary cards are defined.
22. Full notice detail view is defined.
23. Customer support linkage is defined.
24. Receipt linkage is defined.
25. Popup fatigue reduction role is defined.
26. Accessibility requirements are defined.
27. Mobile/table/kiosk adaptation is defined.
28. Evidence boundary is defined.
29. Admin preview boundary is defined.
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
- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`
- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`
- `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`

It also references:

- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`

It prepares possible future documents:

- `10732 Regulatory Change Watchlist And Legal Notice Review Queue Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10734 Legal Notice Support Playbook And Case Reason Code Policy`
- `10735 Legal Notice Static Registry Readiness Check Policy`
- `10736 Legal Notice Implementation Authorization Draft Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 37. Final Rule

Catch Menu must provide a Customer Notice Center as a transparent, searchable, accessible, multilingual, store-aware, platform-aware, and franchise-scoped reference surface for legal and operational notices.

The Notice Center reduces popup fatigue but does not replace required contextual notices, required consent, alcohol age-gate, refund/no-show acknowledgement, or privacy agreement flows.

Current Notice Center text must not rewrite historical order evidence.

Store-specific variables must render from approved templates.

Platform and HQ notices must remain scoped and controlled.

Customer browsing of the Notice Center should be useful without becoming excessive surveillance.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.