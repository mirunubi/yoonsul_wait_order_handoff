# 10719_Legal_Notice_Trigger_Matrix_And_UI_Surface_Mapping_Policy

## 1. Purpose

This document defines the Legal Notice Trigger Matrix and UI Surface Mapping Policy for Catch Menu.

The previous document `10718 Legal Notice Master Data Table Static Specification Policy` defined the static table planning model for legal notice master data, versions, i18n text, trigger rules, surface mapping, store settings, franchise locks, acknowledgement evidence, recommendation logs, review cases, dispute references, and retention policies.

This document defines how each legal notice is connected to:

- customer action
- menu item
- menu category
- store type
- payment mode
- reservation/waiting state
- alcohol state
- privacy/marketing state
- coupon/review state
- hardware/device state
- disaster/incident state
- UI surface
- popup behavior
- acknowledgement requirement
- blocking behavior
- evidence capture

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Legal notice trigger mapping must be deterministic.

The correct rule is:

A notice must appear because a defined trigger matched.  
A trigger must be tied to tenant, store, surface, policy version, and context.  
A popup must not appear randomly.  
A footer notice is not enough for high-risk consent.  
A checkbox is not needed for every notice.  
A mandatory notice must not depend only on store owner memory.  
A customer acknowledgement must be captured only when the notice requires acknowledgement.  
A notice shown on the wrong surface weakens evidence.  
A notice not shown at the right moment may be useless in dispute.  

Legal notices must be surfaced at the point of risk.

---

## 3. Scope

This policy applies to:

- legal notice trigger rules
- UI surface mapping
- popup timing
- modal display
- footer display
- menu detail notices
- checkout notices
- payment confirmation notices
- alcohol confirmation popups
- reservation/no-show notices
- waiting notices
- review notices
- coupon notices
- privacy consent notices
- hardware notices
- disaster notices
- receipt notices
- support evidence references

This document defines mapping governance only.

---

## 4. Trigger Categories

Recommended trigger categories:

| Trigger Category | Meaning |
|---|---|
| `MENU_ITEM_TRIGGER` | Specific menu item triggers notice |
| `MENU_CATEGORY_TRIGGER` | Category triggers notice |
| `INGREDIENT_TRIGGER` | Ingredient/allergen triggers notice |
| `OPTION_TRIGGER` | Option such as spicy level or doneness triggers notice |
| `STORE_TYPE_TRIGGER` | Store type triggers notice |
| `FEATURE_TRIGGER` | Feature use triggers notice |
| `ORDER_STAGE_TRIGGER` | Cart/checkout/payment/order state triggers notice |
| `PAYMENT_TRIGGER` | Payment mode or error triggers notice |
| `RESERVATION_TRIGGER` | Reservation/deposit/no-show triggers notice |
| `WAITING_TRIGGER` | Waiting call/no-show triggers notice |
| `ALCOHOL_TRIGGER` | Alcohol menu/order triggers notice |
| `PRIVACY_TRIGGER` | Signup/privacy/marketing triggers notice |
| `REVIEW_TRIGGER` | Review writing/event triggers notice |
| `COUPON_TRIGGER` | Coupon/promotion triggers notice |
| `DEVICE_TRIGGER` | Table tablet/kiosk/device triggers notice |
| `INCIDENT_TRIGGER` | Outage/failure/disaster triggers notice |
| `ADMIN_TRIGGER` | Store/admin setting triggers notice |
| `HQ_POLICY_TRIGGER` | Franchise/HQ policy requires notice |

---

## 5. UI Surface Categories

Recommended UI surface categories:

| Surface Category | Meaning |
|---|---|
| `MENU_SURFACE` | Menu detail, menu list, ingredient modal |
| `CART_SURFACE` | Cart and order review |
| `CHECKOUT_SURFACE` | Checkout and payment confirmation |
| `ALCOHOL_SURFACE` | Adult confirmation and ID check |
| `RESERVATION_SURFACE` | Reservation/deposit/no-show |
| `WAITING_SURFACE` | Waiting and call expiry |
| `PICKUP_DELIVERY_SURFACE` | Pickup, delivery, takeout |
| `MEMBERSHIP_SURFACE` | Signup, login, membership |
| `PRIVACY_SURFACE` | Privacy, location, marketing consent |
| `REVIEW_SURFACE` | Review and content submission |
| `COUPON_EVENT_SURFACE` | Coupon, promotion, reward |
| `HARDWARE_SURFACE` | Table tablet, kiosk, device notice |
| `LEGAL_CENTER_SURFACE` | Legal notice center |
| `RECEIPT_SURFACE` | Receipt and order history |
| `STAFF_SURFACE` | Staff confirmation/help screen |
| `ADMIN_SURFACE` | Owner/admin setup |
| `SUPPORT_SURFACE` | Support/dispute evidence |
| `INCIDENT_SURFACE` | Outage, disaster, fallback notice |

---

## 6. Surface Display Modes

Recommended display modes:

| Display Mode | Meaning |
|---|---|
| `INLINE_BADGE` | Small notice badge near item |
| `INLINE_TEXT` | Inline notice text |
| `EXPANDABLE_SECTION` | Expandable legal section |
| `BOTTOM_SHEET` | Mobile bottom sheet |
| `MODAL_POPUP` | Modal popup |
| `CHECKBOX_CONFIRM` | Checkbox required |
| `MULTI_CHECKBOX_CONFIRM` | Multiple confirmations |
| `STAFF_CONFIRM_SCREEN` | Staff confirmation required |
| `FOOTER_LINK` | Footer/legal center link |
| `RECEIPT_NOTE` | Receipt-level notice |
| `TOAST_INFO` | Non-blocking short info |
| `BLOCKING_DIALOG` | Must resolve before continuing |
| `ADMIN_REVIEW_CARD` | Admin recommendation/review card |
| `SUPPORT_EVIDENCE_CARD` | Support evidence view |

Display mode must match risk level.

---

## 7. Trigger-To-Surface Mapping Principle

A trigger must define:

| Field | Meaning |
|---|---|
| `trigger_code` | Stable trigger code |
| `trigger_category` | Trigger family |
| `trigger_condition` | Structured condition |
| `notice_id` | Notice to show |
| `surface_id` | Where to show |
| `display_mode` | How to show |
| `required_ack` | Whether acknowledgement is needed |
| `blocking_behavior` | Whether flow is blocked |
| `frequency` | How often to show |
| `evidence_required` | Whether to store shown/ack evidence |
| `priority` | Conflict priority |
| `fallback_surface` | Fallback if surface unavailable |
| `i18n_variant` | Text variant |
| `effective_period` | Active date range |

Trigger mapping is policy data.

It must be versioned and audited.

---

## 8. Food Safety Trigger Matrix

Recommended food safety mappings:

| Trigger | Notice Family | Surface | Mode | Ack |
|---|---|---|---|---|
| Menu has confirmed allergen | Food safety/allergen | Menu detail modal | Inline + expandable | No or optional |
| Menu has high-risk allergen | Food safety/allergen | Cart / checkout | Modal | Optional/required by policy |
| Store uses shared kitchen | Cross-contamination | Legal notice center / menu modal | Expandable | No |
| Menu is raw fish/yukhoe | Raw food warning | Menu detail + checkout | Modal | Required if high risk |
| Menu has extreme spicy level | Spicy warning | Option selection / cart | Inline + confirm | Optional/required |
| Menu has bone/shell risk | Bone/shell warning | Menu detail | Inline | No |
| Takeout fresh food | Storage/freshness warning | Pickup/receipt | Receipt note + modal | No |
| Salad/raw vegetable item | Non-heated fresh food | Menu detail | Inline | No |
| Caffeine drink | High caffeine warning | Menu detail | Inline | No |
| Health claim menu | Health claim review notice | Admin only / menu detail if approved | Admin card | No |

Food safety notices should be as close to menu selection as possible.

---

## 9. Allergen Trigger Detail

Ingredient trigger examples:

| Ingredient/Tag | Notice |
|---|---|
| egg | Egg allergen notice |
| milk/dairy | Milk allergen notice |
| buckwheat | Buckwheat allergen notice |
| peanut/nut | Peanut/nut notice |
| soybean | Soy allergen notice |
| wheat | Wheat/gluten candidate notice |
| mackerel/fish | Fish allergen notice |
| crab | Crab allergen notice |
| shrimp | Shrimp allergen notice |
| pork | Pork ingredient notice if needed |
| peach | Peach allergen notice |
| tomato | Tomato allergen notice |
| sulfite | Sulfite notice |
| chicken | Chicken allergen notice |
| beef | Beef allergen notice |
| squid | Squid allergen notice |
| shellfish | Shellfish notice |
| pine nut | Pine nut notice |

AI may suggest tags.

Confirmed tags trigger customer surfaces.

Candidate tags trigger admin review surfaces.

---

## 10. Alcohol Trigger Matrix

Recommended alcohol mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| Store sells alcohol | Alcohol policy notice | Legal center / admin | Footer/center | No |
| Customer opens alcohol menu | Alcohol sale warning | Menu category header | Inline | No |
| Customer adds alcohol to cart | Adult confirmation | Alcohol popup | Blocking dialog | Required |
| Customer checks out alcohol | ID check notice | Checkout/staff screen | Blocking + staff confirm | Required |
| Staff rejects ID | Alcohol cancellation notice | Staff/customer screen | Modal | Staff evidence |
| Alcohol delivery attempted | Alcohol delivery restriction | Checkout | Blocking | Required if policy |
| Highball/wine bottle unit | Serving unit notice | Menu detail | Inline | No |
| Corkage item | Corkage service fee notice | Menu detail/cart | Modal | Optional/required |
| Intoxicated customer incident | Refusal notice | Staff screen | Staff guidance | Staff evidence |

Alcohol notices must be conservative and age-gated.

---

## 11. Store Use And Facility Trigger Matrix

Recommended store/facility mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| Store has hot grill/table fire | Burn warning | Table order / menu category | Inline/modal | No |
| Store has child safety restriction | Child guardian notice | Legal center / waiting | Expandable | No |
| No-kids-zone enabled | No-kids-zone notice | Reservation/waiting/store page | Modal | Required if reservation |
| Pet-friendly enabled | Pet rules | Store page/reservation | Expandable | Optional |
| CCTV enabled | CCTV notice | Footer/legal center/table idle | Inline/link | No |
| Self bar enabled | Self bar/waste notice | Table idle / menu | Inline | No |
| Time limit enabled | Dining time notice | Waiting/reservation | Modal | Optional |
| Parking available | Parking notice | Store info/receipt | Inline | No |
| Break time configured | Break time notice | Store info/order attempt | Blocking if closed | No |
| Gas burner present | Burner safety notice | Table screen | Inline/modal | No |

Store notices should be available before customer arrives when relevant.

---

## 12. Privacy And Membership Trigger Matrix

Recommended privacy mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| User signs up | Terms agreement | Membership signup | Checkbox | Required |
| User signs up | Privacy collection/use | Membership signup | Checkbox | Required |
| Order requires third-party data | Third-party provision | Checkout/signup | Checkbox | Required if applicable |
| Marketing opt-in | Marketing consent | Signup/settings | Optional checkbox | Optional |
| Push/SMS/email marketing | Ad receipt consent | Settings/signup | Optional checkbox | Optional |
| Location feature used | Location terms | Location prompt/settings | Checkbox | Optional/required by feature |
| User requests withdrawal | Data deletion notice | My page | Confirm modal | Required |
| Privacy policy updated | Policy update notice | App notice/settings | Modal/link | Optional/required by change |
| App permission used | App access notice | Permission prompt | System + app text | Required by feature |

Privacy notices must separate required and optional consent.

---

## 13. Payment Refund Trigger Matrix

Recommended payment/refund mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| Immediate cooking item checkout | No cancellation after kitchen send | Checkout | Modal/checkbox | Required by policy |
| Prepaid order | Refund/payment policy | Checkout | Expandable/checkbox | Optional/required |
| KDS accepted order | Cancellation locked notice | Order status | Inline | No |
| Sold-out event | Auto cancel/refund notice | Order status | Modal | No |
| Duplicate payment error | Payment error guidance | Payment error screen | Modal | No |
| Reservation deposit | Deposit refund rule | Reservation checkout | Checkbox | Required |
| No-show penalty enabled | No-show penalty notice | Reservation/waiting | Checkbox/modal | Required |
| Coupon applied | Coupon stacking/expiry notice | Cart | Inline | No |
| Minor payment context | Minor cancellation right | Terms/legal center | Footer/link | No |
| PG name differs | PG name notice | Receipt/payment | Receipt note | No |

Refund notice must match actual payment state machine.

---

## 14. Review Content Trigger Matrix

Recommended review mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| User opens review form | Review policy | Review page | Expandable | No |
| Review event active | Review event abuse notice | Review page | Checkbox | Optional/required |
| Photo upload | Copyright/portrait notice | Review upload | Inline | No |
| Profanity detected | Profanity filter notice | Review form | Inline/block | No |
| Rights infringement report | Temporary measure notice | Support/review case | Support card | Staff |
| Non-purchaser tries review | Review eligibility notice | Review attempt | Blocking dialog | No |
| Review deleted by user | Non-restoration notice | Delete confirm | Confirm modal | Required |

Review notices must protect both store and customer rights.

---

## 15. Coupon Event Trigger Matrix

Recommended coupon/event mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| Coupon issued | Expiration notice | Coupon detail | Inline | No |
| Coupon applied | No stacking notice | Cart | Inline | No |
| Screenshot detected or manual entry | Screenshot invalid notice | Coupon use | Blocking | No |
| First-order coupon | First-order rule | Coupon detail/cart | Inline | No |
| Event limited stock | Early termination notice | Event page | Inline | No |
| Gift item included | Gift no cash exchange notice | Cart/receipt | Inline | No |
| Multi-account abuse suspected | Abuse restriction notice | Account/coupon | Modal | No |
| Store-specific event | Store-only event notice | Event page | Inline | No |

Notice must align with coupon engine enforcement.

---

## 16. Hardware And System Trigger Matrix

Recommended hardware/system mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| Table tablet active | Tablet handling notice | Idle/help screen | Inline | No |
| Water-prone table | Liquid spill notice | Idle/help screen | Inline | No |
| Timeout configured | Timeout notice | Idle/cart warning | Toast/modal | No |
| Network outage | Manual payment notice | Incident screen | Modal | No |
| POS outage | Order delay/manual check notice | Incident screen | Modal | No |
| VAN pending | Approval waiting notice | Payment screen | Blocking info | No |
| Printer failure | Receipt reprint notice | Receipt screen | Inline | No |
| External QR link | External site disclaimer | Redirect interstitial | Confirm | Optional |
| Device damage incident | Damage notice evidence | Staff/support | Evidence card | Staff |

Hardware notice should connect to incident and device evidence.

---

## 17. Disaster And Exception Trigger Matrix

Recommended exception mappings:

| Trigger | Notice | Surface | Mode | Ack |
|---|---|---|---|---|
| Weather disaster | Force majeure cancellation | Order status | Modal | No |
| Building water/power outage | Forced cancellation notice | Order status | Modal | No |
| Kitchen equipment failure | Delay/cancel notice | Order status | Modal | No |
| Ingredient sold out | Substitute/refund notice | Order status | Modal | Optional |
| Server overload | System delay notice | App/table screen | Modal | No |
| Last order passed | Last order block notice | Order attempt | Blocking dialog | No |
| Price typo detected | Price correction notice | Order/support | Modal | Required if reprice |
| Translation mismatch | Controlling Korean notice | Menu/legal center | Inline | No |
| Emergency evacuation | Fire alarm evacuation notice | Incident screen | Blocking | No |

Exception notices must trigger operational workflow, not only text display.

---

## 18. Trigger Priority Conflict Resolution

When multiple notices apply:

| Conflict | Resolution |
|---|---|
| Same notice appears from multiple triggers | Deduplicate by notice ID/version |
| Mandatory and optional version conflict | Mandatory wins |
| Platform and store notice conflict | Platform/HQ wins unless store is stricter |
| Korean and translated text conflict | Controlling language policy applies |
| Footer-only and popup mapping conflict | Higher-risk surface wins |
| Payment notice and promotion notice conflict | Payment/refund priority wins |
| Alcohol notice and ordinary drink notice conflict | Alcohol priority wins |
| Missing i18n for high-risk notice | Block or use approved fallback |

Conflict resolution must be deterministic.

---

## 19. UI Surface Mapping Table

Recommended base mapping:

| Surface | Suitable Notice Types |
|---|---|
| `MENU_DETAIL_MODAL` | Allergen, raw food, kcal, health claim, spicy warning |
| `CART_PAGE` | Option, cancellation, coupon, market price |
| `CHECKOUT_PAGE` | Payment, refund, privacy, delivery, deposit |
| `PAYMENT_CONFIRM_MODAL` | Payment confirmation, refund, PG notice |
| `ALCOHOL_AGE_POPUP` | Adult confirmation, ID check |
| `RESERVATION_PAGE` | Deposit, no-show, time limit |
| `WAITING_PAGE` | Waiting auto-cancel, no-show |
| `PICKUP_PAGE` | Freshness, storage, no-show pickup |
| `DELIVERY_PAGE` | Delivery restriction, packaging, alcohol restriction |
| `REVIEW_PAGE` | Review/IP/abuse |
| `COUPON_PAGE` | Coupon expiration, screenshot invalid, stacking |
| `TABLE_IDLE_SCREEN` | CCTV, tablet, facility, Wi-Fi, safety |
| `LEGAL_NOTICE_CENTER` | Full notice library |
| `RECEIPT` | VAT, PG, refund, order evidence |
| `STAFF_CONFIRM_SCREEN` | ID check, incident, refusal, staff guidance |
| `ADMIN_SETTING_PAGE` | Toggle, legal review, recommendations |
| `SUPPORT_CASE_SCREEN` | Evidence, version, trigger, dispute |

---

## 20. Popup Fatigue Control

The system must avoid excessive popups.

Rules:

1. High-risk notices may interrupt.
2. Low-risk notices should be inline or legal center.
3. Repeated notices should obey frequency.
4. The same notice should not show repeatedly in one session unless required.
5. Notices should be grouped when safe.
6. Mandatory consent must remain clear.
7. Optional marketing consent must not be hidden inside required consent.
8. Alcohol notice must not be bundled with unrelated notices.
9. Payment/refund notice must appear before payment.
10. Allergen notice must be near menu decision point.

Legal clarity and UX must be balanced.

---

## 21. Evidence Capture Matrix

Recommended evidence behavior:

| Notice Type | Show Evidence | Ack Evidence |
|---|---:|---:|
| Footer policy | Optional | No |
| Menu allergen inline | Optional | Usually no |
| Raw food high-risk modal | Yes | Optional/required |
| Alcohol adult popup | Yes | Yes |
| Staff ID check | Yes | Yes, staff |
| Privacy required consent | Yes | Yes |
| Marketing optional consent | Yes | Yes if accepted |
| Payment/refund checkout | Yes | Yes if required |
| Reservation deposit | Yes | Yes |
| Coupon rule | Optional | No |
| Review policy | Optional | No |
| Device damage notice | Optional | Staff evidence if incident |
| Disaster notice | Yes | No |
| Price correction notice | Yes | Yes if repricing |

Evidence behavior must be notice-specific.

---

## 22. Admin Configuration Matrix

Admin page should show:

| Column | Meaning |
|---|---|
| Notice title | Admin-friendly name |
| Family | Notice family |
| Recommended reason | Why suggested |
| Required state | Mandatory/optional |
| Toggle | ON/OFF if allowed |
| Lock state | Platform/HQ/store |
| Surface | Where shown |
| Ack required | Whether customer must confirm |
| Risk | Risk class |
| Legal review | Review badge |
| i18n status | Translation readiness |
| Effective date | Activation date |
| Preview | Customer preview |
| Audit history | Change history |

Admin must see the consequence of turning notices on/off.

---

## 23. Staff Surface Matrix

Staff screens may need legal prompts.

Examples:

| Staff Action | Notice / Guidance |
|---|---|
| ID check for alcohol | Acceptable ID guidance |
| Reject alcohol order | Rejection reason guidance |
| Foreign object complaint | Evidence preservation guidance |
| Device damage incident | Device damage notice/evidence |
| Customer abuse | Staff protection guidance |
| Refund dispute | Refund notice evidence |
| No-show dispute | Reservation notice evidence |
| Translation complaint | Korean controlling text guidance |
| Food allergy inquiry | Allergen/cross-contact guidance |

Staff guidance is not always customer-facing notice.

---

## 24. Support Surface Matrix

Support case should show:

| Case Type | Evidence Needed |
|---|---|
| Allergy complaint | Menu notice, allergen tags, acknowledgement if any |
| Raw food complaint | Raw food notice, pickup time, order time |
| Refund dispute | Refund notice, KDS/order/payment state |
| Alcohol dispute | Adult confirmation, staff ID check, alcohol item |
| No-show dispute | Reservation/waiting notice, timestamps |
| Coupon abuse | Coupon notice, usage logs |
| Review dispute | Review policy, review content, moderation logs |
| Device damage | Device notice, incident evidence |
| Server outage | Disaster/system notice, incident timeline |
| Price typo | Price correction notice, order state |

Support must view evidence without mutating it.

---

## 25. i18n Surface Mapping

Each notice surface must choose correct text variant.

| Surface | Preferred Variant |
|---|---|
| Menu detail | `MENU_MODAL` |
| Popup | `SHORT_POPUP` |
| Checkbox | `CHECKBOX_LABEL` |
| Legal center | `FULL_POLICY` |
| Receipt | `RECEIPT_NOTE` |
| Admin | `ADMIN_GUIDANCE` |
| Staff | `STAFF_GUIDANCE` |
| Support | `SUPPORT_SUMMARY` |
| Accessibility | `ACCESSIBILITY` |

If localized variant is missing, fallback behavior must be defined.

---

## 26. Missing Mapping Handling

If a trigger matches but no surface mapping exists:

| Risk | Behavior |
|---|---|
| Low | Log warning and show in legal center if possible |
| Medium | Show safe fallback modal |
| High | Block action until mapping resolved |
| Legal | Block action and create compliance case |
| Payment | Block payment if required notice missing |
| Alcohol | Block alcohol order |
| Privacy | Block consent-dependent flow |
| Food safety | Show fallback notice and create review case |

Missing mapping is a configuration defect.

---

## 27. Audit Event Catalog

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `LEGAL_TRIGGER_RULE_CREATED` | Trigger rule created |
| `LEGAL_TRIGGER_RULE_UPDATED` | Trigger rule updated |
| `LEGAL_TRIGGER_RULE_DISABLED` | Trigger rule disabled |
| `LEGAL_SURFACE_MAP_CREATED` | Surface mapping created |
| `LEGAL_SURFACE_MAP_UPDATED` | Surface mapping updated |
| `LEGAL_SURFACE_MAP_MISSING` | Trigger matched but mapping missing |
| `LEGAL_NOTICE_SELECTED` | Notice selected by trigger |
| `LEGAL_NOTICE_DEDUPED` | Duplicate notice removed |
| `LEGAL_NOTICE_RENDERED` | Notice rendered |
| `LEGAL_NOTICE_ACK_REQUIRED` | Ack required |
| `LEGAL_NOTICE_ACK_CAPTURED` | Ack captured |
| `LEGAL_NOTICE_BLOCKED_FLOW` | Notice blocked flow |
| `LEGAL_NOTICE_FALLBACK_USED` | Fallback surface/text used |
| `LEGAL_NOTICE_I18N_MISSING` | Translation missing |
| `LEGAL_NOTICE_CONFLICT_RESOLVED` | Conflict resolved by priority |

Events must route through `10610`.

---

## 28. Security Boundary

Trigger and surface mapping are security-sensitive configuration.

Rules:

- only authorized users can edit trigger rules
- only authorized users can edit surface mapping
- legal/high-risk mappings require review
- bulk mapping changes require HQ/platform authority
- store users cannot weaken mandatory mapping
- support cannot edit mapping from case screen
- AI cannot create active mappings automatically
- every mapping change must be audited
- rollback must be possible
- tenant/store scope must be enforced

Bad mapping can create legal exposure.

---

## 29. Anti-Patterns

Avoid:

- showing all legal notices at checkout regardless of relevance
- hiding high-risk alcohol notice in footer only
- showing allergen notice only after payment
- asking marketing consent inside required privacy consent
- showing refund notice after order is already irreversible
- showing no-show penalty only after no-show occurs
- treating AI recommendation as trigger activation
- using unversioned popup text
- failing to capture acknowledgement for required consent
- duplicating the same notice multiple times in one flow
- letting store owner disable mandatory legal notice
- using machine-translated legal text without review
- blocking all orders due to low-risk missing notice
- ignoring missing surface mapping
- making support evidence depend on current notice text

These anti-patterns must be blocked in future runtime design.

---

## 30. Runtime Deferral

This document defines legal notice trigger matrix and UI surface mapping governance only.

It does not authorize:

- trigger engine implementation
- UI popup implementation
- legal notice center implementation
- admin mapping UI implementation
- acknowledgement runtime
- evidence runtime
- i18n runtime
- staff screen implementation
- support screen implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 31. Validation Checklist

Validation must confirm:

1. Trigger categories are defined.
2. UI surface categories are defined.
3. Surface display modes are defined.
4. Trigger-to-surface mapping principle is defined.
5. Food safety trigger matrix is defined.
6. Allergen trigger detail is defined.
7. Alcohol trigger matrix is defined.
8. Store use and facility trigger matrix is defined.
9. Privacy and membership trigger matrix is defined.
10. Payment/refund trigger matrix is defined.
11. Review/content trigger matrix is defined.
12. Coupon/event trigger matrix is defined.
13. Hardware/system trigger matrix is defined.
14. Disaster/exception trigger matrix is defined.
15. Trigger priority conflict resolution is defined.
16. UI surface mapping table is defined.
17. Popup fatigue control is defined.
18. Evidence capture matrix is defined.
19. Admin configuration matrix is defined.
20. Staff surface matrix is defined.
21. Support surface matrix is defined.
22. i18n surface mapping is defined.
23. Missing mapping handling is defined.
24. Audit event catalog is defined.
25. Security boundary is defined.
26. Anti-patterns are listed.
27. Coding remains unauthorized.
28. Runtime remains deferred.

---

## 32. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10703 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10720 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 33. Final Rule

Catch Menu legal notices must be shown through a deterministic trigger matrix and controlled UI surface mapping.

A notice must appear on the right surface, at the right time, in the right language, with the right display mode, acknowledgement requirement, blocking behavior, evidence rule, tenant/store scope, and policy version.

High-risk notices such as alcohol, privacy consent, refund/cancellation, reservation deposit, raw food, allergen, and payment notices must not be hidden in generic footer text.

AI may recommend triggers.

AI must not activate legal notice mapping automatically.

Trigger rules, surface mappings, acknowledgement requirements, and blocking behavior require authority, audit, versioning, and review.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.