# 040018_Policy_Legal_Notice_Master_Data_Usage_Flow_And_Runtime_Retrieval_Governance

## 1. Purpose

This document defines how the Catch Menu Legal Notice Master Data Pool is used after being stored in the database.

The previous document `40017 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy` defined the legal notice master system, legal notice families, triggers, surfaces, versioning, evidence, and governance principles.

This document explains the usage flow:

- how legal notice master data is stored
- how notices are selected
- how store toggles activate notices
- how AI/menu/category triggers recommend notices
- how customer screens retrieve notices
- how acknowledgement evidence is captured
- how notice versions are preserved
- how POS/KDS/payment/support/dispute flows reference notice evidence
- how notices remain reusable without hardcoding

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Legal notices must be stored once and reused many times.

The correct rule is:

Legal notice text lives in master data.  
Screens retrieve notices by context.  
Admin toggles do not rewrite notice text.  
Customer acknowledgement must record the exact notice version shown.  
Menu/category triggers recommend notices automatically.  
Mandatory notices cannot be disabled by ordinary store users.  
Optional notices may be enabled by store owners.  
AI may recommend a notice, but AI does not activate legal finality.  
Legal notice display must be auditable.  
Legal notice evidence must be available for disputes.  

A notice is useful only if the system can prove what was shown, when it was shown, why it was shown, and which version was shown.

---

## 3. Usage Scope

This policy applies to legal notice use across:

- menu detail pages
- table order screens
- cart screens
- checkout screens
- payment screens
- reservation screens
- waiting screens
- pickup screens
- delivery screens
- alcohol order popups
- membership signup
- marketing consent
- review writing
- coupon/event participation
- receipt display
- customer support
- dispute evidence packets
- owner/admin console
- franchise HQ console
- legal/compliance console

---

## 4. Master Data Storage Principle

Legal notices must be stored as reusable master data.

Recommended storage families:

| Table / Object | Purpose |
|---|---|
| `legal_notice_master` | Stable notice identity and family |
| `legal_notice_version` | Versioned text and review state |
| `legal_notice_trigger_rule` | Context rules for automatic notice selection |
| `legal_notice_surface_map` | Where the notice can appear |
| `store_legal_notice_setting` | Store-level ON/OFF and override state |
| `legal_notice_ack_evidence` | Customer or staff acknowledgement evidence |
| `legal_notice_recommendation_log` | AI/system recommendation history |
| `legal_notice_i18n_text` | Localized notice text |
| `legal_notice_policy_review` | Legal/HQ review workflow |
| `legal_notice_dispute_ref` | Support/dispute reference records |

This document does not define actual SQL.

It defines usage governance only.

---

## 5. Legal Notice Retrieval Flow

Recommended retrieval sequence:

1. Identify current context.
2. Resolve tenant and store scope.
3. Resolve customer/session/order context.
4. Resolve menu/category/payment/alcohol/privacy/review context.
5. Fetch applicable mandatory notices.
6. Fetch applicable store-enabled optional notices.
7. Fetch automatically recommended notices.
8. Remove duplicates by notice family and priority.
9. Resolve latest approved version.
10. Resolve i18n text by locale.
11. Render on the correct surface.
12. Capture shown event.
13. Capture acknowledgement if required.
14. Attach evidence to order/session/payment/dispute packet.

Retrieval must be deterministic.

---

## 6. Context Inputs

Notice retrieval may use:

| Context | Example |
|---|---|
| `tenant_id` | SaaS tenant |
| `store_id` | Store |
| `brand_id` | Franchise brand |
| `surface_id` | Table order, kiosk, app, admin |
| `menu_item_id` | Shrimp tempura |
| `menu_category` | Pub / Alcohol |
| `order_id` | Current order |
| `cart_id` | Current cart |
| `payment_mode` | Prepaid, postpaid, deposit |
| `reservation_id` | Reservation |
| `waiting_id` | Waiting session |
| `customer_id` | Member if known |
| `session_id` | Non-member session |
| `device_id` | Table tablet or kiosk |
| `locale` | ko-KR, en-US, ja-JP, etc. |
| `feature_flag` | Review event, coupon, alcohol |
| `risk_signal` | Raw food, allergen, high caffeine |
| `policy_version` | Active policy context |

No context means no unsafe assumption.

Missing scope must fail closed for mandatory legal flows.

---

## 7. Notice Selection Priority

When multiple notices apply, priority must be clear.

Recommended priority order:

| Priority | Notice Type |
|---|---|
| 1 | Platform mandatory legal notice |
| 2 | Regulated consent notice |
| 3 | Alcohol/youth protection notice |
| 4 | Privacy/terms notice |
| 5 | Payment/refund/cancellation notice |
| 6 | Food safety/allergen/raw food notice |
| 7 | Store safety/facility notice |
| 8 | Store owner enabled notice |
| 9 | AI/system recommended notice |
| 10 | Informational notice |

Higher priority notices may block order progression.

Lower priority notices may be shown in notice center only.

---

## 8. Mandatory Versus Optional Use

Legal notices must be classified by enforcement behavior.

| Enforcement Class | Meaning |
|---|---|
| `MANDATORY_LOCKED` | Cannot be disabled by store |
| `MANDATORY_CONTEXTUAL` | Required only when context matches |
| `STORE_OPTIONAL` | Store may enable |
| `FRANCHISE_REQUIRED` | Franchise HQ requires |
| `LEGAL_REVIEW_REQUIRED` | Cannot activate until reviewed |
| `ADMIN_GUIDANCE_ONLY` | Not customer-facing |
| `AI_RECOMMENDED_ONLY` | Suggested but not active |
| `DEPRECATED` | Not usable |

Example:

- Alcohol adult confirmation: `MANDATORY_CONTEXTUAL`
- Privacy required consent: `MANDATORY_LOCKED`
- No-kids-zone notice: `STORE_OPTIONAL` with review
- Marketing consent: optional consent, not required for basic service
- Legal disclaimer under review: `LEGAL_REVIEW_REQUIRED`

---

## 9. Store Toggle Usage

Store owners may toggle approved notices.

Toggle fields should capture:

| Field | Meaning |
|---|---|
| `notice_id` | Notice |
| `store_id` | Store |
| `enabled` | ON/OFF |
| `enabled_by` | Actor |
| `enabled_at` | Time |
| `disabled_by` | Actor if disabled |
| `disabled_at` | Time if disabled |
| `source` | Manual, recommendation, HQ mandate |
| `lock_state` | Editable or locked |
| `reason` | Reason |
| `effective_from` | Start time |
| `effective_to` | End time |
| `audit_ref` | Audit reference |

A toggle changes activation.

It does not change legal text.

---

## 10. Franchise HQ Lock

Franchise HQ may lock certain notices.

Examples:

- brand-wide allergen notice
- refund policy notice
- coupon abuse notice
- review event notice
- no-show deposit notice
- alcohol policy notice
- food safety notice
- privacy notice

HQ lock rules:

| Rule | Meaning |
|---|---|
| `HQ_LOCKED_ON` | Store cannot turn off |
| `HQ_LOCKED_TEXT` | Store cannot edit wording |
| `HQ_TEMPLATE_REQUIRED` | Store must choose approved template |
| `HQ_REVIEW_REQUIRED` | Store change requires HQ approval |
| `STORE_APPEND_ALLOWED` | Store may add local detail |
| `STORE_OVERRIDE_DENIED` | Store override prohibited |

Franchise templates must preserve tenant/store isolation.

---

## 11. AI Recommendation Usage

AI may recommend notices after menu analysis.

Example recommendations:

| AI Detection | Recommended Notice |
|---|---|
| 새우튀김 | Shellfish allergen notice |
| 연어사시미 | Raw food freshness notice |
| 스테이크 굽기 | Doneness notice |
| 주류 메뉴 | Adult confirmation notice |
| 콜키지 | Corkage notice |
| 시가 | Market price notice |
| 1+1 이벤트 | Promotion condition notice |
| 예약금 | No-show/deposit notice |
| 디카페인/카페인 | High caffeine/decaf notice |
| 비건/키토 | Health claim review notice |

AI recommendation states:

| State | Meaning |
|---|---|
| `RECOMMENDED` | Suggested |
| `OWNER_ACCEPTED` | Store accepted |
| `OWNER_REJECTED` | Store rejected |
| `HQ_REQUIRED` | HQ requires |
| `LEGAL_REVIEW_PENDING` | Legal review needed |
| `ACTIVATED` | Active |
| `DISMISSED_WITH_REASON` | Dismissed |

AI recommendation is not activation unless accepted and allowed.

---

## 12. Surface Mapping Usage

The same notice may appear differently by surface.

| Surface | Example Use |
|---|---|
| Menu detail modal | Allergen/raw food |
| Cart | Cancellation/option warning |
| Checkout | Refund/payment terms |
| Alcohol popup | Adult confirmation |
| Reservation page | Deposit/no-show rule |
| Waiting page | Late arrival auto-cancel |
| Review page | Review abuse/IP |
| Footer | Terms/privacy/business info |
| Receipt | VAT/PG/refund notice |
| Table idle screen | CCTV/device/facility notice |
| Admin page | Owner configuration |
| Staff screen | ID check/support guidance |
| Support screen | Dispute evidence |

Surface map must define:

- short text
- full text
- acknowledgement requirement
- display frequency
- blocking behavior
- evidence requirement

---

## 13. Display Frequency Rules

Notices must not overwhelm customers.

Recommended display frequency:

| Frequency | Usage |
|---|---|
| `EVERY_TIME` | Required consent before action |
| `ONCE_PER_SESSION` | Session-level notice |
| `ONCE_PER_ORDER` | Order-level notice |
| `ONCE_PER_CUSTOMER_VERSION` | Show again when version changes |
| `ON_MENU_OPEN` | Menu-specific warning |
| `ON_CHECKOUT` | Payment/refund notice |
| `ON_FEATURE_USE` | Review/coupon/location feature |
| `FOOTER_ONLY` | Always accessible but not popup |
| `RECEIPT_ONLY` | Attached after order |

High-risk notices may require every-time display.

Low-risk notices should avoid popup fatigue.

---

## 14. Acknowledgement Requirement Usage

Some notices require acknowledgement.

Acknowledgement types:

| Type | Meaning |
|---|---|
| `NO_ACK_REQUIRED` | Display only |
| `SIMPLE_CONFIRM` | Confirm button |
| `CHECKBOX_REQUIRED` | Checkbox |
| `MULTI_CHECKBOX` | Multiple required confirmations |
| `STAFF_CONFIRM` | Staff confirms |
| `ADULT_CONFIRM` | Customer adult declaration |
| `ID_CHECK_CONFIRM` | Staff ID check |
| `SIGNATURE_REQUIRED` | Signature or equivalent |
| `PAYMENT_CONTINUE_CONFIRM` | Confirm before payment |
| `ORDER_BLOCKING_CONFIRM` | Cannot order unless confirmed |

Acknowledgement must capture exact notice version.

---

## 15. Legal Notice Evidence Usage

Evidence may be used for:

- refund disputes
- no-show disputes
- alcohol disputes
- allergy disputes
- raw food freshness disputes
- device damage disputes
- coupon abuse disputes
- review abuse disputes
- privacy consent audit
- payment error support
- reservation cancellation support
- customer support escalation
- franchise HQ audit
- legal review

Evidence must be immutable or append-only.

Support can view evidence but cannot rewrite it.

---

## 16. Customer Journey Usage

Example customer journey:

1. Customer opens menu.
2. Menu contains raw fish.
3. System shows raw food freshness notice in menu detail.
4. Customer adds item to cart.
5. System records `LEGAL_NOTICE_SHOWN`.
6. Customer checks out.
7. Refund/cancellation notice appears.
8. Customer confirms.
9. System records `LEGAL_NOTICE_ACKNOWLEDGED`.
10. Order is sent.
11. Notice evidence is attached to order.
12. Support can retrieve evidence if dispute occurs.

The notice follows the order lifecycle.

---

## 17. Alcohol Order Usage

Alcohol notice flow:

1. Customer selects alcohol item.
2. System detects `alcohol_flag = true`.
3. Adult confirmation popup appears.
4. Customer confirms adult status.
5. Staff ID check may be required.
6. If ID check fails, alcohol order is blocked/cancelled.
7. Evidence records notice, confirmation, staff action, and policy version.
8. Alcohol item remains separate in POS/payment category.

Alcohol cannot use ordinary beverage flow.

---

## 18. Privacy Consent Usage

Privacy consent flow:

1. Customer signs up or uses member feature.
2. Required terms are shown.
3. Required privacy consent is shown.
4. Optional marketing consent is shown separately.
5. Optional consent refusal must not block core service unless required.
6. Consent evidence records version, timestamp, method, and scope.
7. Consent withdrawal must be available where applicable.

Privacy consent must be granular.

---

## 19. Refund And Cancellation Usage

Refund/cancellation notice flow:

1. Customer enters checkout.
2. System determines order type.
3. If immediate cooking item, cancellation notice appears.
4. If reservation deposit, deposit/refund rule appears.
5. If market-price item, price confirmation rule appears.
6. If prepaid order, payment/refund policy appears.
7. Customer acknowledgement is captured where required.
8. Evidence is attached to order/payment.

Refund notices must match actual POS/payment behavior.

---

## 20. Menu Ingredient Notice Usage

Menu ingredient notice flow:

1. AI/menu dictionary identifies allergen candidate.
2. Admin confirms allergen or keeps candidate under review.
3. Confirmed allergen attaches to menu item.
4. Customer opens menu detail.
5. Allergen notice appears.
6. Customer can view full allergen/cross-contamination notice.
7. Evidence may be captured for high-risk menu or allergen warning.

Allergen claims require review.

AI detection alone is not final allergen declaration.

---

## 21. Market Price Notice Usage

Market-price flow:

1. AI detects `시가`, `싯가`, `변동`, or `문의`.
2. Admin confirms price state.
3. If market price remains active, customer display shows inquiry/market-price notice.
4. Online payment may be disabled or require staff confirmation.
5. Order evidence records price state at time of order.
6. If price is later fixed, a new version or price event must be recorded.

Market price must not be stored as zero-price.

---

## 22. Hardware And Device Notice Usage

Hardware notice flow:

1. Customer uses table tablet/kiosk.
2. Device notice may appear on idle screen or device help menu.
3. If damage/water spill incident occurs, staff can open incident evidence packet.
4. System links notice shown state, device ID, table, time, and incident.
5. Support/HQ can review evidence.

Hardware notice must be connected to device runtime governance.

---

## 23. Coupon And Promotion Notice Usage

Coupon notice flow:

1. Customer opens coupon or promotion.
2. Coupon validity, expiration, duplicate-use, screenshot restriction, and stacking rules appear.
3. Customer applies coupon.
4. System enforces coupon engine rules.
5. Notice evidence may be recorded for abuse-sensitive promotions.
6. Abuse event links to notice version and usage record.

Notice does not replace enforcement.

Promotion engine must enforce rules.

---

## 24. Review Notice Usage

Review notice flow:

1. Customer opens review page.
2. Review/IP/abuse notice is shown.
3. Customer submits review.
4. System records review notice version.
5. If moderation/dispute occurs, support can see notice shown and review content evidence.
6. Rights infringement process follows policy.

Review notice must protect both customer rights and store rights.

---

## 25. Disaster And Force Majeure Notice Usage

Force majeure notice flow:

1. Store/system detects outage, disaster, power failure, ingredient shortage, or last-order block.
2. Applicable exception notice is shown.
3. Customer order may be cancelled, delayed, or rerouted.
4. Refund/cancel flow must match actual payment state.
5. Evidence packet records cause, notice shown, order state, and refund action.

Force majeure notice must trigger operational workflow, not only text display.

---

## 26. Notice Center Usage

The app/table order should provide a legal notice center.

Recommended tabs:

| Tab | Content |
|---|---|
| Food Safety | Allergy, hygiene, raw food, storage |
| Store Use | Facility, CCTV, child/pet, no-show |
| Payment | Refund, cancellation, VAT, receipt |
| Privacy | Terms, privacy, marketing, location |
| Alcohol | Youth protection, ID check, alcohol policy |
| Review | Review, content, copyright |
| System | Device, network, error |
| Event | Coupon, promotion, abuse |
| Disaster | Force majeure and exceptions |

Notice center should be searchable and not block normal ordering unless required.

---

## 27. Admin Usage Flow

Admin flow:

1. Owner opens legal notice settings.
2. System shows recommended notices based on store type and menu.
3. Mandatory notices are already locked ON.
4. Optional notices can be toggled.
5. High-risk notices show legal/HQ review badge.
6. Owner previews customer display.
7. Owner confirms activation.
8. System records audit.
9. Notices become active on selected surfaces.
10. Evidence starts being captured when shown.

Admin should not edit approved legal wording freely.

---

## 28. Sales Representative Usage Flow

Sales representative flow:

1. Sales rep uploads menu photo.
2. AI classifies menu and store type.
3. System recommends legal notices.
4. Sales rep explains required notices to owner.
5. Owner confirms store-specific toggles.
6. High-risk items remain pending legal/HQ review.
7. Setup checklist marks legal notice readiness.

Sales reps may configure but should not approve legal text.

---

## 29. Support Usage Flow

Support flow during dispute:

1. Support opens order case.
2. System displays notice evidence.
3. Support sees:
   - notice shown
   - notice version
   - customer acknowledgement
   - order stage
   - payment state
   - store toggle state
   - policy basis
4. Support cannot modify evidence.
5. Support may escalate to legal/HQ if notice missing or inconsistent.

Support visibility is case-scoped.

---

## 30. Missing Notice Handling

If required notice was not shown:

| Situation | Action |
|---|---|
| Required notice missing before order | Block deployment or order if detected in time |
| Required notice missing after order | Create compliance incident |
| Optional notice missing | Log warning |
| Legal review notice missing | Block activation |
| i18n missing | Use approved fallback language or block if required |
| Evidence missing | Create evidence gap case |
| Version mismatch | Create audit mismatch case |

Missing mandatory notice must not be ignored.

---

## 31. Notice Consistency Boundary

Notice must match actual system behavior.

Examples:

| Notice Claim | Required System Behavior |
|---|---|
| “주문 후 취소 불가” | POS/payment/KDS must block or govern cancellation |
| “품절 시 자동 환불” | Payment refund route must exist |
| “성인인증 필요” | Alcohol order must trigger age-gate |
| “쿠폰 중복 불가” | Coupon engine must enforce non-stacking |
| “시가 문의” | Checkout must not silently charge zero |
| “마케팅 수신 선택” | Optional consent must be withdrawable |
| “테이블 오더 timeout” | Session timeout must actually exist |

Legal notice without matching runtime behavior is dangerous.

---

## 32. Notice Deactivation Boundary

Notice deactivation must be controlled.

Deactivation rules:

- mandatory locked notices cannot be disabled by store owner
- optional notices may be disabled with reason
- deactivation must record audit
- deactivation must not delete past evidence
- active orders keep the notice version shown at order time
- deactivation must not change historical receipts
- legal/HQ notices may require approval to deactivate

Deactivation is not deletion.

---

## 33. Version Upgrade Usage

When legal notice text changes:

1. New version is drafted.
2. Legal/HQ review is completed if needed.
3. New version becomes effective.
4. Future displays use new version.
5. Past acknowledgements retain old version.
6. Customers may be re-prompted if material change requires it.
7. Admin can view version history.
8. Support can compare old and new version.

Version upgrade must not rewrite history.

---

## 34. i18n Usage

When customer locale is not Korean:

1. System attempts approved translation.
2. If approved translation exists, show localized notice.
3. If translation is missing and notice is low-risk, show Korean with fallback guide.
4. If notice is legally critical and translation is missing, block or require approved Korean controlling text display.
5. Evidence records locale and text version shown.

Legal translation must be controlled.

Machine translation alone is not legal approval.

---

## 35. Data Retention Usage

Legal notice evidence retention depends on notice type.

Suggested retention classes:

| Retention Class | Example |
|---|---|
| `SHORT_SESSION` | Low-risk informational display |
| `ORDER_LIFECYCLE` | Menu/order notices |
| `PAYMENT_RETENTION` | Refund/payment notices |
| `PRIVACY_RETENTION` | Consent records |
| `ALCOHOL_RETENTION` | Adult confirmation/ID check evidence |
| `DISPUTE_RETENTION` | Dispute-related evidence |
| `LEGAL_HOLD` | Litigation or investigation hold |

Retention policy must be legally reviewed.

---

## 36. Security Boundary

Legal notice data must be protected.

Security rules:

- only approved users can edit master notices
- store owners cannot edit platform legal text freely
- support cannot modify evidence
- evidence is append-only
- tenant/store scope is mandatory
- i18n text must match approved version
- legal notice trigger changes are audited
- high-risk notice toggle requires reauthentication
- bulk changes require HQ/admin authority
- export of consent evidence requires purpose and audit

Legal notice evidence is compliance-sensitive data.

---

## 37. Anti-Patterns

Avoid:

- hardcoding notices into app screens
- copying legal text into each store manually
- losing notice version after acknowledgement
- treating toggle ON as legal approval
- treating AI recommendation as active notice
- showing notice without recording shown event where evidence is required
- recording acknowledgement without storing version
- letting owners freely rewrite legal wording
- showing all notices every time
- hiding mandatory notices in footer only
- using machine translation as legal final text
- deleting old notice versions
- changing notice text retroactively
- disconnecting notice from POS/payment behavior
- failing to expose evidence to support
- using notice to claim absolute immunity

These anti-patterns must be blocked in future runtime design.

---

## 38. Runtime Deferral

This document defines legal notice master usage flow, retrieval, activation, acknowledgement, evidence, and support usage governance only.

It does not authorize:

- legal notice database implementation
- admin toggle UI implementation
- customer popup implementation
- consent runtime
- legal notice trigger engine
- evidence storage implementation
- POS/payment integration
- alcohol age-gate implementation
- privacy consent implementation
- support console implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 39. Validation Checklist

Validation must confirm:

1. Master data storage principle is defined.
2. Legal notice retrieval flow is defined.
3. Context inputs are defined.
4. Notice selection priority is defined.
5. Mandatory versus optional use is defined.
6. Store toggle usage is defined.
7. Franchise HQ lock is defined.
8. AI recommendation usage is defined.
9. Surface mapping usage is defined.
10. Display frequency rules are defined.
11. Acknowledgement requirement usage is defined.
12. Legal notice evidence usage is defined.
13. Customer journey usage is defined.
14. Alcohol order usage is defined.
15. Privacy consent usage is defined.
16. Refund and cancellation usage is defined.
17. Menu ingredient notice usage is defined.
18. Market price notice usage is defined.
19. Hardware and device notice usage is defined.
20. Coupon and promotion notice usage is defined.
21. Review notice usage is defined.
22. Disaster and force majeure notice usage is defined.
23. Notice center usage is defined.
24. Admin usage flow is defined.
25. Sales representative usage flow is defined.
26. Support usage flow is defined.
27. Missing notice handling is defined.
28. Notice consistency boundary is defined.
29. Notice deactivation boundary is defined.
30. Version upgrade usage is defined.
31. i18n usage is defined.
32. Data retention usage is defined.
33. Security boundary is defined.
34. Anti-patterns are listed.
35. Coding remains unauthorized.
36. Runtime remains deferred.

---

## 40. Relationship To Previous Documents

This document supplements:

- `40017 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `40006` through `40015` menu taxonomy seed registry documents
- `40016 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `40019 Legal Notice Master Data Table Static Specification Policy`
- `40020 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `40021 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 41. Final Rule

Catch Menu must use the legal notice pool as controlled database master data.

The system should retrieve notices by tenant, store, menu, category, order stage, payment mode, alcohol status, privacy flow, coupon event, review action, hardware state, disaster condition, surface, locale, and policy version.

Store owners may toggle approved optional notices.

Mandatory notices must be locked or contextually enforced.

AI may recommend notices.

Legal/HQ review must approve high-risk notice wording and activation.

Customer-facing notices must record the exact version shown, the surface, the trigger, the timestamp, and acknowledgement when required.

Past evidence must never be rewritten.

Legal notice usage is a governance and evidence system, not absolute immunity.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.