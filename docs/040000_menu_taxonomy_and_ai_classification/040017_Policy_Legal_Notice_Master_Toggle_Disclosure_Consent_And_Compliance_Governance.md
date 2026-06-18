# 040017_Policy_Legal_Notice_Master_Toggle_Disclosure_Consent_And_Compliance_Governance

## 1. Purpose

This document defines the Legal Notice Master, Disclosure, Consent, Toggle Activation, Store-Specific Legal Shield, Evidence Logging, and Compliance Governance Policy for Catch Menu.

This policy follows the previous menu taxonomy and builder artifacts:

- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `40006` through `40015` menu category taxonomy seed registries
- `40016 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

This document defines how legal notices, customer warnings, consent texts, store rules, refund notices, privacy consents, alcohol warnings, review policies, hardware disclaimers, coupon abuse controls, tax notices, black consumer response notices, and disaster exception notices should be systematized as a master data layer.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Legal notices are not decorative text.

The correct rule is:

Legal notice is a controlled master object.  
Legal notice is not free text scattered across screens.  
Legal notice visibility is not consent unless confirmed.  
Consent without evidence is weak.  
Evidence without policy version is weak.  
Policy version without store scope is unsafe.  
Toggle ON is not legal validity by itself.  
AI may recommend notices, but legal notice activation requires store context, category context, policy version, review state, and audit.  
A notice may reduce dispute risk, but it does not create automatic immunity.  

Catch Menu must treat legal notices as platform infrastructure.

---

## 3. Scope

This policy applies to:

- customer app
- table order
- mini kiosk
- full kiosk
- admin page
- owner console
- franchise HQ console
- support console
- payment flow
- order confirmation flow
- reservation flow
- waiting flow
- pickup flow
- delivery flow
- review flow
- coupon/event flow
- membership flow
- privacy consent flow
- alcohol order flow
- hardware/device screen
- legal notice popup
- footer legal page
- menu detail modal
- checkout agreement
- post-order evidence packet

---

## 4. Legal Notice Is A Master Data Object

Every legal notice must be stored as a master object, not hardcoded text.

Recommended object fields:

| Field | Meaning |
|---|---|
| `notice_id` | Unique notice identifier |
| `notice_code` | Stable code |
| `notice_family` | Food safety, alcohol, privacy, payment, etc. |
| `notice_title` | Admin-facing title |
| `notice_body_key` | i18n message key |
| `plain_text_ko` | Korean reference text |
| `plain_text_en` | English reference text if available |
| `legal_basis_ref` | Law/regulation/internal policy reference |
| `risk_class` | Low, medium, high, legal, financial, safety |
| `trigger_type` | Static, popup, checkbox, modal, footer, receipt |
| `required_ack` | Whether customer confirmation is required |
| `store_toggle_default` | Default ON/OFF |
| `category_trigger` | Restaurant/menu category trigger |
| `menu_trigger` | Menu/allergen/alcohol/refund trigger |
| `order_stage_trigger` | Before order, checkout, payment, pickup, etc. |
| `evidence_required` | Whether evidence record is required |
| `retention_policy` | Evidence retention rule |
| `review_state` | Draft, legal review, approved, deprecated |
| `policy_version` | Version of notice |
| `effective_from` | Effective date |
| `effective_to` | Expiry/deprecation date |
| `tenant_scope` | Platform, tenant, franchise, store |
| `audit_ref` | Audit reference |

---

## 5. Legal Notice Families

Recommended master families:

| Family Code | Family |
|---|---|
| `FOOD_SAFETY_HYGIENE` | Food safety, hygiene, allergy, raw food |
| `YOUTH_ALCOHOL_PROTECTION` | Youth protection and alcohol identity verification |
| `STORE_USE_FACILITY_SAFETY` | Store rules, facility safety, child/pet/CCTV |
| `PRIVACY_TERMS_MEMBERSHIP` | Membership, privacy, third-party, marketing consent |
| `PAYMENT_CANCEL_REFUND_ECOMMERCE` | Payment, cancellation, refund, e-commerce notices |
| `REVIEW_CONTENT_IP` | Review, post, copyright, abuse policy |
| `SYSTEM_POS_KIOSK_HARDWARE` | POS, kiosk, network, device error notices |
| `FRANCHISE_EVENT_COUPON_ABUSE` | Franchise event, coupon, promotion abuse |
| `TAX_SETTLEMENT_RECEIPT` | Tax, receipt, settlement, evidence |
| `BLACK_CONSUMER_STAFF_PROTECTION` | Malicious consumer, staff protection |
| `DISASTER_FORCE_MAJEURE_EXCEPTION` | Disaster, force majeure, infrastructure outage |
| `LEGAL_NOTICE_META` | Notice version, precedence, legal review metadata |

---

## 6. Notice Activation Model

Notices must be activated by context.

Activation sources:

| Source | Example |
|---|---|
| Store type | Pub store activates alcohol notices |
| Menu ingredient | Shrimp item activates shellfish allergen notice |
| Menu category | Raw fish activates raw food notice |
| Payment mode | Prepaid order activates cancellation notice |
| Order timing | Late-night order activates late-night policy |
| Customer action | Alcohol order activates adult confirmation popup |
| Feature toggle | Review event activates review abuse policy |
| Hardware context | Table tablet activates device damage notice |
| Reservation context | Reservation deposit activates no-show notice |
| Delivery context | Delivery activates packaging/freshness notice |
| Admin toggle | Owner activates no-kids-zone notice |
| Legal review | HQ activates regulated wording template |

Toggle is a configuration action.

It is not legal validation by itself.

---

## 7. Static Notice Versus Active Consent

The system must distinguish:

| Type | Meaning |
|---|---|
| `STATIC_NOTICE` | Informational display |
| `CONTEXTUAL_NOTICE` | Notice shown due to menu/action |
| `CONFIRMATION_POPUP` | Customer clicks confirm |
| `CHECKBOX_CONSENT` | Explicit consent checkbox |
| `MANDATORY_AGREEMENT` | Required agreement before proceeding |
| `OPTIONAL_AGREEMENT` | Optional consent such as marketing |
| `FOOTER_POLICY_LINK` | Always accessible policy page |
| `RECEIPT_NOTICE` | Notice attached to receipt |
| `ADMIN_ONLY_NOTICE` | Admin guidance only |
| `STAFF_CONFIRMATION` | Staff confirms ID/check/action |

A notice cannot be treated as consent unless the UI captures consent evidence.

---

## 8. Evidence Packet For Legal Notice

When notice acknowledgement is required, evidence must include:

| Field | Meaning |
|---|---|
| `notice_id` | Notice shown |
| `policy_version` | Version shown |
| `tenant_id` | Tenant |
| `store_id` | Store |
| `table_id` | Table if applicable |
| `order_id` | Order if applicable |
| `customer_id` | Customer if known |
| `session_id` | Session |
| `device_id` | Device |
| `locale` | Language shown |
| `shown_at` | Display time |
| `acknowledged_at` | Confirmation time |
| `ack_method` | Click, checkbox, staff confirm |
| `actor_type` | Customer, staff, owner |
| `screen_id` | Where notice appeared |
| `source_event` | Triggering event |
| `ip_hash` | Optional privacy-safe network evidence |
| `user_agent_hash` | Optional device evidence |
| `audit_ref` | Audit reference |

Evidence must be append-only.

Evidence must not be silently overwritten.

---

## 9. Food Safety And Hygiene Notice Registry

This family covers notice items 01 through 10 and 51 through 70.

Core notice groups:

| Range | Group |
|---|---|
| 01 | Mandatory allergen ingredient notice |
| 02 | Cross-contamination warning |
| 03 | Extreme spicy food caution |
| 04 | Fish bone and shell fragment warning |
| 05 | Steak/cutlet doneness selection warning |
| 06 | Raw fish, sashimi, yukhoe, raw food freshness warning |
| 07 | Nut topping exclusion notice |
| 08 | Digital origin display notice |
| 09 | External food and drink prohibition |
| 10 | Infant food heating service disclaimer |
| 51 | High caffeine caution |
| 52 | Fresh ingredient size/shape variation notice |
| 53 | High-temperature soup/container burn warning |
| 54 | Soft food/porridge non-medical notice |
| 55 | Takeout food consumption time warning |
| 56 | Non-heated fresh food storage warning |
| 57 | Residual bone possibility warning |
| 58 | Lactose intolerance warning |
| 59 | Raw egg/soft yolk hygiene notice |
| 60 | Herbal ingredient body constitution warning |
| 61 | Special fish/toxin removal qualified cooking notice |
| 62 | Pinkish effect notice |
| 63 | High sodium/high sugar caution |
| 64 | Shellfish toxin season safety notice |
| 65 | Powder seasoning inhalation caution |
| 66 | Food coloring notice |
| 67 | Cooking alcohol trace caution |
| 68 | Soybean paste/soy allergy notice |
| 69 | Buckwheat cross-contact notice |
| 70 | Long storage prohibition sticker notice |

Food safety notices should be activated by ingredient, menu category, preparation method, and service mode.

---

## 10. Allergen Notice Boundary

Allergen notices must support:

- menu-level allergen candidates
- store-level cross-contamination notice
- ingredient-level allergen tags
- customer-facing modal
- admin review
- optional exclusion request
- non-guarantee wording
- staff inquiry route

AI may suggest allergen tags.

AI must not finalize allergen/legal wording without review.

---

## 11. Youth Protection And Alcohol Notice Registry

This family covers notice items 11 through 15 and 91 through 100.

Core notice groups:

| Range | Group |
|---|---|
| 11 | ID required for alcohol order |
| 12 | 19세 미만 alcohol sale prohibition |
| 13 | Adult confirmation popup for table order |
| 14 | Alcohol sharing with minors warning |
| 15 | Adult-only non-alcohol beverage notice |
| 91 | Mobile ID acceptance standard |
| 92 | Student ID not accepted |
| 93 | Foreigner passport/alien registration card notice |
| 94 | Youth late-night entry restriction |
| 95 | Proxy alcohol order prohibition |
| 96 | Fake/altered ID zero-tolerance notice |
| 97 | Alcohol sale time restriction |
| 98 | Youth-prohibited business type notice |
| 99 | Drunk driving prevention and designated driver link |
| 100 | Refusal of alcohol sale to intoxicated customer |

Alcohol notice must be age-gated and evidence-backed where required.

---

## 12. Alcohol Governance Boundary

Alcohol notice activation requires:

- alcohol menu detection
- store alcohol sales flag
- legal review state
- age verification policy
- order channel scope
- delivery restriction
- staff confirmation where applicable
- payment compatibility
- customer notice
- audit evidence

AI alcohol detection is evidence.

It is not legal authorization.

---

## 13. Store Use And Facility Safety Notice Registry

This family covers notice items 16 through 25 and 71 through 90.

Core notice groups:

| Range | Group |
|---|---|
| 16 | Hot container/grill burn warning |
| 17 | Child guardian responsibility |
| 18 | No-kids-zone notice |
| 19 | Property damage and contamination compensation |
| 20 | Lost/stolen belongings disclaimer |
| 21 | CCTV recording notice |
| 22 | Self-bar food waste/environment fee |
| 23 | One menu per person rule |
| 24 | Waiting no-show auto cancel |
| 25 | Pet-friendly store rules |
| 71 | Stairs/ramp slip caution |
| 72 | Stroller/wheelchair storage/direction notice |
| 73 | Restroom slip/lock caution |
| 74 | Terrace/rooftop safety notice |
| 75 | No running in store |
| 76 | No unauthorized table/chair movement |
| 77 | Seat assignment rule |
| 78 | Parking lot damage disclaimer |
| 79 | Free parking registration notice |
| 80 | Waiting area restriction |
| 81 | No smoking including e-cigarettes |
| 82 | No disorderly drunken behavior |
| 83 | No removal of store property |
| 84 | Reservation no-show penalty notice |
| 85 | Break time notice |
| 86 | Dining time limit |
| 87 | Self return of dishes |
| 88 | Gas burner manipulation prohibition |
| 89 | Umbrella loss disclaimer |
| 90 | Store Wi-Fi misuse prohibition |

These notices must be store-configurable.

High-risk notices should require owner/HQ review.

---

## 14. Privacy Terms And Membership Notice Registry

This family covers notice items 26 through 35 and 101 through 115.

Core notice groups:

| Range | Group |
|---|---|
| 26 | Required service terms consent |
| 27 | Required personal data collection/use consent |
| 28 | Required third-party provision consent |
| 29 | Optional marketing data consent |
| 30 | Optional advertising receipt consent |
| 31 | Privacy policy permanent access notice |
| 32 | Member withdrawal and data destruction notice |
| 33 | Optional location-based service terms |
| 34 | Dormant member transition notice |
| 35 | Personal data breach notification notice |
| 101 | Under-14 membership restriction |
| 102 | Data access, correction, deletion rights |
| 103 | Personal data processing outsourcing notice |
| 104 | Password management responsibility |
| 105 | Log and cookie collection notice |
| 106 | Service interruption notice |
| 107 | Fraudulent point accumulation warning |
| 108 | Accuracy of registration information |
| 109 | Overseas server/cloud processing notice |
| 110 | Marketing opt-out method |
| 111 | Long-term inactive account handling |
| 112 | Third-party linked website disclaimer |
| 113 | Platform intermediary responsibility notice |
| 114 | App permission notice |
| 115 | Business information footer notice |

Privacy notices must distinguish required consent and optional consent.

Optional consent refusal must not block core service unless legally necessary.

---

## 15. Privacy Consent Boundary

Privacy consent must define:

- collected items
- purpose
- retention period
- third-party recipient
- outsourced processor
- optional/required status
- withdrawal method
- policy version
- consent timestamp
- customer identity or session
- evidence retention

Marketing consent must be separate from service-required consent.

---

## 16. Payment Cancel Refund And E-Commerce Notice Registry

This family covers notice items 36 through 45 and 116 through 130.

Core notice groups:

| Range | Group |
|---|---|
| 36 | Immediate cooking cancellation/refund restriction |
| 37 | Duplicate payment/error handling |
| 38 | Unpaid departure/fraud warning |
| 39 | Sold-out auto cancel/refund |
| 40 | Non-member order data consent |
| 41 | Receipt and VAT notice |
| 42 | Reservation deposit/no-show refund rule |
| 43 | Point/coupon expiration policy |
| 44 | PG name display notice |
| 45 | Minor payment cancellation right |
| 116 | No change after table order transmission |
| 117 | Card limit/balance failure notice |
| 118 | Dutch-pay amount mismatch lock |
| 119 | Cash receipt request deadline |
| 120 | Mobile payment recognition error |
| 121 | Additional prepaid order payment obligation |
| 122 | Mistaken order customer responsibility |
| 123 | PG/VAN system pending approval handling |
| 124 | Foreign card/payment limitation |
| 125 | Corporate card statement issue |
| 126 | Coupon stacking restriction |
| 127 | Tiered reservation cancellation penalty |
| 128 | Group reservation deposit requirement |
| 129 | Refund processing time |
| 130 | Minimum amount for installment payment |

Payment notices must be attached to order stage, payment mode, and menu state.

---

## 17. Refund And Cancellation Boundary

Refund/cancel notices must not be generic only.

They must consider:

- order sent to kitchen
- KDS accepted
- payment authorized
- payment captured
- menu sold out
- customer mistake
- store mistake
- system error
- force majeure
- reservation deposit
- no-show
- market-price item
- alcohol item
- delivery item
- pickup item

Refund policy must be consistent with POS/payment provider behavior.

---

## 18. Review Content And Intellectual Property Notice Registry

This family covers notice items 46 through 50 and 131 through 140.

Core notice groups:

| Range | Group |
|---|---|
| 46 | False/malicious review removal and restriction |
| 47 | Review copyright and marketing use notice |
| 48 | Legal action for malicious review |
| 49 | Portrait rights and photo theft notice |
| 50 | Review event abuse restriction |
| 131 | Account suspension for malicious rating attack |
| 132 | No unauthorized use of others' content |
| 133 | Immediate deletion of illegal/obscene content |
| 134 | Review manipulation penalty |
| 135 | Store interior/menu/UI IP notice |
| 136 | Temporary measure for rights infringement report |
| 137 | Review deletion non-restoration notice |
| 138 | Non-purchaser/no-show review restriction |
| 139 | Review mileage condition |
| 140 | Profanity and harmful-word filtering notice |

Review policies must preserve user rights and store protection.

Automated deletion should be reviewable where required.

---

## 19. System POS Kiosk Hardware Notice Registry

This family covers notice items 141 through 150.

Core notice groups:

| Range | Group |
|---|---|
| 141 | Manual counter payment during network outage |
| 142 | Tablet physical damage warning |
| 143 | POS power failure/order omission notice |
| 144 | Tablet liquid spill warning |
| 145 | Timeout auto logout notice |
| 146 | VAN pending approval notice |
| 147 | No hardware disassembly/cable removal |
| 148 | Automatic screen brightness notice |
| 149 | External QR/navigation error disclaimer |
| 150 | Printer paper shortage/reprint notice |

Hardware notices must be connected to device runtime, incident logs, and degraded operation SOP.

---

## 20. Franchise Event Coupon Abuse Notice Registry

This family covers notice items 151 through 160.

Core notice groups:

| Range | Group |
|---|---|
| 151 | Store-specific event independence |
| 152 | Coupon screenshot invalid |
| 153 | Multi-account benefit restriction |
| 154 | Early event termination |
| 155 | No cash refund/exchange for free gift |
| 156 | No duplicate third-party discount |
| 157 | First-order coupon rule |
| 158 | Set menu substitution surcharge |
| 159 | Unauthorized staff-only button click warning |
| 160 | Local currency restricted item notice |

Coupon/event notices must be bound to promotion rules.

Notice alone must not replace coupon engine enforcement.

---

## 21. Tax Settlement Receipt Notice Registry

This family covers notice items 161 through 170.

Core notice groups:

| Range | Group |
|---|---|
| 161 | Tax-exempt item separated display |
| 162 | No duplicate tax invoice after card payment |
| 163 | Post-day payment method change limitation |
| 164 | Service charge/tip separate notice |
| 165 | Delivery agency fee evidence notice |
| 166 | Prepaid/gift card refund rule |
| 167 | No illegal receipt alteration |
| 168 | Multi-PG settlement display notice |
| 169 | ZeroPay/mobile voucher recognition delay |
| 170 | Receipt transfer/fraud prevention |

Tax/receipt notices must align with financial ledger and settlement kernel.

---

## 22. Black Consumer And Staff Protection Notice Registry

This family covers notice items 171 through 180.

Core notice groups:

| Range | Group |
|---|---|
| 171 | Staff abuse recording notice |
| 172 | Malicious operational disruption removal |
| 173 | Foreign object evidence preservation |
| 174 | No private contact/stalking of staff |
| 175 | No unauthorized filming/live broadcasting |
| 176 | False claim/extortion warning |
| 177 | Abuse through table order message prohibition |
| 178 | Intentional contamination punishment warning |
| 179 | Manager removal order authority |
| 180 | Repeated malicious complaint account restriction |

This family must be handled carefully.

Notices must not encourage excessive confrontation by staff.

Incident evidence and escalation SOP are mandatory.

---

## 23. Disaster Force Majeure Exception Notice Registry

This family covers notice items 181 through 200.

Core notice groups:

| Range | Group |
|---|---|
| 181 | Natural disaster cooking/delivery cancellation |
| 182 | Building-wide water/power outage |
| 183 | Public road construction/parking limitation |
| 184 | National emergency/infectious disease order |
| 185 | Fire alarm evacuation and order exception |
| 186 | Kitchen equipment emergency failure |
| 187 | Ingredient early sold-out substitute proposal |
| 188 | Emergency closure due to lease/operation issue |
| 189 | Platform server overload order delay |
| 190 | Last order blocking |
| 191 | Menu price typo correction right |
| 192 | Automatic translation error disclaimer |
| 193 | Shared battery rental damage/loss |
| 194 | Takeout container misuse prohibition |
| 195 | Unauthorized outside alcohol corkage charge |
| 196 | Lost item storage/disposal rule |
| 197 | Franchise store independent business status |
| 198 | Group reservation late arrival auto no-show |
| 199 | Limited baby chair availability |
| 200 | Final terms precedence notice |

Force majeure notices must trigger operational recovery flows, not only text display.

---

## 24. Legal Notice Trigger Matrix

Recommended trigger matrix:

| Trigger | Notice Family |
|---|---|
| Menu contains shrimp, crab, shellfish | Allergy notice |
| Menu contains raw fish/yukhoe | Raw food warning |
| Menu contains alcohol | Youth/alcohol notice |
| Customer starts alcohol order | Adult confirmation popup |
| Store enables no-kids-zone | Facility/use notice |
| Customer joins membership | Privacy/terms consent |
| Customer opts into marketing | Marketing consent |
| Customer submits order | Cancellation/refund notice |
| Customer uses prepaid reservation | No-show/deposit notice |
| Customer writes review | Review/IP notice |
| Tablet device active | Hardware/device notice |
| Coupon applied | Coupon abuse notice |
| Receipt requested | Tax/receipt notice |
| Staff abuse report | Staff protection notice |
| System outage | Disaster/system exception notice |

Trigger must be deterministic and auditable.

---

## 25. Admin Toggle Design

Admin legal notice page should provide:

- notice family tabs
- store type recommendation
- menu-based auto recommendation
- toggle ON/OFF
- required notice lock
- optional notice toggle
- legal review badge
- risk level badge
- preview by surface
- Korean/English preview
- i18n key preview
- trigger preview
- consent evidence preview
- effective date
- audit history
- rollback to previous wording
- franchise HQ lock if applicable

Some notices may be mandatory and cannot be turned off by store owner.

---

## 26. Notice Recommendation Engine

The system may recommend notices.

Examples:

| Detected Context | Recommendation |
|---|---|
| Shrimp tempura | Shellfish allergen notice |
| Steak doneness option | Doneness selection notice |
| Sashimi | Raw food freshness notice |
| Alcohol menu | Adult confirmation and ID notice |
| No-show deposit | Reservation refund/no-show notice |
| Cafe with caffeine drinks | High caffeine caution |
| Pub/pocha | Alcohol unit and age-gate notices |
| Table tablet | Hardware damage notice |
| Marketing coupon | Coupon abuse and expiration notice |
| Review event | Review event abuse notice |
| Delivery night food | Takeout freshness and delivery exception notice |

AI may suggest notices.

Admin/legal review must confirm required notices.

---

## 27. Legal Notice Display Surfaces

Legal notices may appear on:

| Surface | Usage |
|---|---|
| Menu detail modal | Ingredient/allergen/raw food |
| Cart page | Cancellation, add-on, market price |
| Checkout page | Payment/refund/terms |
| Alcohol order popup | Adult confirmation |
| Reservation page | No-show/deposit |
| Waiting page | Auto cancel/no-show |
| Review page | Review/IP/abuse |
| Footer page | Privacy, terms, business info |
| Table order idle screen | CCTV/store rules/device notice |
| Receipt | VAT, refund, PG, order evidence |
| Admin page | Owner configuration |
| Staff screen | ID check, incident guidance |
| Support screen | Dispute evidence |

Surface-specific wording may differ but must reference the same master notice.

---

## 28. Notice Severity And Blocking Rules

Recommended severity:

| Severity | Meaning |
|---|---|
| `LOW_NOTICE` | Informational |
| `MEDIUM_NOTICE` | Customer awareness needed |
| `HIGH_RISK_NOTICE` | Safety/financial dispute risk |
| `MANDATORY_NOTICE` | Must be displayed |
| `CONSENT_REQUIRED` | Customer must confirm |
| `LEGAL_REVIEW_REQUIRED` | Must be reviewed before activation |
| `ORDER_BLOCKING` | Order cannot proceed without action |
| `STAFF_CONFIRMATION_REQUIRED` | Staff must confirm |

Examples:

- Alcohol order: `CONSENT_REQUIRED` and `STAFF_CONFIRMATION_REQUIRED`
- 개인정보 필수 동의: `ORDER_BLOCKING` for membership signup
- Menu allergen detail: `MANDATORY_NOTICE` when allergen known
- Takeout freshness: `HIGH_RISK_NOTICE`
- Coupon rule: `MEDIUM_NOTICE`

---

## 29. Legal Notice Versioning

Every notice must be versioned.

Versioning fields:

| Field | Meaning |
|---|---|
| `notice_version_id` | Version identifier |
| `notice_id` | Parent notice |
| `version_no` | Version number |
| `body_key` | i18n key |
| `legal_reviewed_by` | Reviewer |
| `approved_by` | Approver |
| `effective_from` | Effective date |
| `effective_to` | End date |
| `change_reason` | Reason |
| `supersedes_version` | Previous version |
| `rollback_allowed` | Whether rollback allowed |
| `audit_ref` | Audit reference |

A customer acknowledgement must record the version shown.

---

## 30. Tenant Store And Franchise Scope

Legal notice activation must support:

| Scope | Meaning |
|---|---|
| `PLATFORM_GLOBAL` | Platform-wide mandatory notice |
| `TENANT_GLOBAL` | Tenant-wide notice |
| `FRANCHISE_BRAND` | Franchise brand-level notice |
| `STORE_LOCAL` | Store-specific notice |
| `MENU_ITEM` | Menu-specific notice |
| `CATEGORY` | Category-specific notice |
| `ORDER_CHANNEL` | App/table/kiosk/delivery specific |
| `TIME_WINDOW` | Late-night/lunch/seasonal |
| `LEGAL_REGION` | Regional rule if applicable |

Store-specific notices must not leak across tenants.

Tenant isolation remains mandatory.

---

## 31. Legal Notice And i18n Boundary

All legal notices must use i18n message keys.

No hardcoded operational strings.

Required i18n fields:

- Korean official text
- English translation
- Chinese/Japanese translation if supported
- plain-language variant
- short popup variant
- full policy variant
- receipt variant
- screen reader/accessibility variant

Foreign-language translation must be reviewed.

Korean text may be designated as controlling version if policy requires.

---

## 32. Legal Notice And Safe Projection Boundary

Customer display must be safe.

Rules:

- show only relevant notice
- avoid overwhelming customer with 200 notices at once
- provide full legal notice center
- use contextual popups only where needed
- do not expose internal risk score
- do not expose staff-only legal memo
- do not claim absolute immunity
- do not use threatening wording unnecessarily
- preserve customer rights
- provide inquiry route

Legal notice should protect trust, not only shift blame.

---

## 33. Evidence And Audit Boundary

Legal notice actions must create audit where needed.

Audit event catalog:

| Event Type | Meaning |
|---|---|
| `LEGAL_NOTICE_MASTER_CREATED` | Notice created |
| `LEGAL_NOTICE_VERSION_APPROVED` | Version approved |
| `LEGAL_NOTICE_TOGGLE_ON` | Store activated notice |
| `LEGAL_NOTICE_TOGGLE_OFF` | Store deactivated notice |
| `LEGAL_NOTICE_AUTO_RECOMMENDED` | System recommended notice |
| `LEGAL_NOTICE_SHOWN` | Notice shown |
| `LEGAL_NOTICE_ACKNOWLEDGED` | Customer acknowledged |
| `LEGAL_NOTICE_REQUIRED_BUT_MISSING` | Required notice missing |
| `LEGAL_NOTICE_LEGAL_REVIEW_REQUESTED` | Legal review requested |
| `LEGAL_NOTICE_I18N_REVIEW_REQUESTED` | Translation review requested |
| `LEGAL_NOTICE_DEPRECATED` | Notice deprecated |
| `LEGAL_NOTICE_ROLLBACK_APPLIED` | Previous version restored |
| `ALCOHOL_NOTICE_ACKNOWLEDGED` | Alcohol notice confirmed |
| `PRIVACY_CONSENT_CAPTURED` | Privacy consent captured |
| `REFUND_NOTICE_ACKNOWLEDGED` | Refund notice acknowledged |
| `HARDWARE_DAMAGE_NOTICE_SHOWN` | Hardware notice shown |
| `DISASTER_EXCEPTION_NOTICE_SHOWN` | Force majeure notice shown |

Events must route through `10610`.

---

## 34. Relationship To AI Menu Intake

AI menu intake may trigger legal notice suggestions:

| AI Detection | Notice Suggestion |
|---|---|
| Shrimp/crab/shellfish | Allergen notice |
| Nut dessert | Nut allergy notice |
| Spicy level | Spicy food warning |
| Raw fish/yukhoe | Raw food freshness warning |
| Steak doneness | Doneness notice |
| Alcohol brand | Alcohol age-gate notice |
| Market price seafood | Market price and refund notice |
| Set with alcohol | Alcohol set legal review |
| Takeout/delivery item | Freshness/time warning |
| Cafe caffeine drink | High caffeine caution |
| Vegan/keto claim | Health claim review notice |

AI suggestion is draft evidence.

Human/legal review remains mandatory.

---

## 35. Relationship To Menu Builder

Menu builder must attach notices to:

- menu item
- option group
- set
- combo
- promotion
- alcohol set
- corkage fee
- market-price item
- per-person unlimited refill
- no-show deposit
- fast track item
- delivery item
- review event
- coupon event

A legal notice can be inherited from category but overridden by stricter store/franchise policy.

---

## 36. Relationship To POS KDS Payment

Legal notices affect:

- POS item category
- refund eligibility
- payment authorization
- alcohol sale lock
- cancellation workflow
- KDS order timing
- sold-out handling
- receipt wording
- PG evidence
- customer dispute packet
- support workflow

Notice must not conflict with actual POS/payment behavior.

If the system says cancellation is unavailable but POS allows silent cancellation, policy is inconsistent.

---

## 37. Relationship To Support And Dispute Evidence

Support must be able to see:

- notice shown
- notice version
- customer acknowledgement
- order stage
- payment stage
- menu item
- store toggle state
- policy basis
- admin activation actor
- any missing notice warning
- refund/cancel policy at time of order
- evidence packet

Support visibility is case-scoped.

Support cannot edit legal notice evidence.

---

## 38. Anti-Patterns

Avoid:

- claiming notices create perfect immunity
- hardcoding legal text in UI
- allowing store owner to edit legal wording freely without review
- showing all 200 notices as one giant popup
- treating optional marketing consent as required service consent
- using one generic refund notice for all order states
- treating alcohol as ordinary beverage
- showing legal notice without storing policy version
- storing acknowledgement without notice text version
- turning on legal notice across tenant without scope check
- using AI-generated legal wording directly in production
- hiding customer rights
- using threatening wording where plain notice is enough
- ignoring i18n review
- failing to log notice display and acknowledgement
- failing to connect notices to POS/KDS/payment behavior

These anti-patterns must be blocked in future runtime design.

---

## 39. Runtime Deferral

This document defines legal notice master, disclosure, consent, toggle activation, evidence, and compliance governance boundaries only.

It does not authorize:

- legal notice database implementation
- consent runtime
- admin toggle UI
- legal popup runtime
- privacy consent runtime
- alcohol age-gate runtime
- refund policy runtime
- coupon abuse engine
- review moderation engine
- POS/KDS/payment integration
- evidence storage implementation
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 40. Validation Checklist

Validation must confirm:

1. Legal notice master object is defined.
2. Legal notice families are defined.
3. Notice activation model is defined.
4. Static notice versus active consent is separated.
5. Evidence packet is defined.
6. Food safety notice registry is defined.
7. Allergen notice boundary is defined.
8. Youth/alcohol notice registry is defined.
9. Alcohol governance boundary is defined.
10. Store use/facility safety notice registry is defined.
11. Privacy/terms/membership notice registry is defined.
12. Privacy consent boundary is defined.
13. Payment/cancel/refund/e-commerce notice registry is defined.
14. Refund/cancellation boundary is defined.
15. Review/content/IP notice registry is defined.
16. POS/kiosk/hardware notice registry is defined.
17. Franchise/event/coupon abuse notice registry is defined.
18. Tax/settlement/receipt notice registry is defined.
19. Black consumer/staff protection notice registry is defined.
20. Disaster/force majeure notice registry is defined.
21. Trigger matrix is defined.
22. Admin toggle design is defined.
23. Recommendation engine is defined.
24. Display surfaces are defined.
25. Severity/blocking rules are defined.
26. Versioning is defined.
27. Tenant/store/franchise scope is defined.
28. i18n boundary is defined.
29. Safe projection boundary is defined.
30. Evidence/audit boundary is defined.
31. Relationship to AI menu intake is defined.
32. Relationship to menu builder is defined.
33. Relationship to POS/KDS/payment is defined.
34. Relationship to support/dispute evidence is defined.
35. Anti-patterns are listed.
36. Coding remains unauthorized.
37. Runtime remains deferred.
38. Final legal review remains required.

---

## 41. Relationship To Previous Documents

This document supplements:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`
- `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `40006` through `40015` menu taxonomy seed registry documents
- `40016 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `40018 Legal Notice Master Data Table Static Specification Policy`
- `40019 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `40020 Privacy Consent Evidence Packet And Retention Policy`
- `40021 Alcohol Age Gate Legal Notice And Staff Verification SOP`
- `10721 Refund Cancellation No-Show Notice And Dispute Evidence SOP`
- `10722 Legal Notice i18n Review And Controlled Translation Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 42. Final Rule

Catch Menu legal notices must be built as a controlled master data system.

The 200 legal notice pool should be organized by family, trigger, surface, severity, consent requirement, policy version, tenant/store scope, i18n key, review state, and evidence requirement.

AI may recommend legal notices from menu, ingredient, store type, order channel, payment mode, alcohol status, review event, coupon event, hardware state, or disaster condition.

AI-generated or AI-selected legal notices are draft recommendations only.

Human review, legal review where required, owner/HQ authority, tenant/store scope, versioning, audit, evidence capture, i18n review, POS/KDS/payment consistency, and rollback remain mandatory.

Legal notice is a shielding system, not absolute immunity.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.