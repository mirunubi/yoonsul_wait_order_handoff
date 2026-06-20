# 010906_Policy_Store_Service_Mode_Selection_And_Feature_Readiness.md

## Purpose

This document defines the Store Service Mode Selection and Feature Readiness Policy for Catch Menu.

The previous document `10805_01_Ingredient_Master_Pool_Taxonomy_And_Korean_Namul_Seed_Registry_Policy` extended the ingredient master layer to support global ingredients, Korean namul, gimbap ingredients, banchan ingredients, allergen mapping, legal notice mapping, recipe mapping, and inventory readiness.

This document returns to the Store Onboarding and Sales Setup Axis and defines how a store selects service modes and how each selected mode creates feature readiness requirements.

Service mode selection determines which legal notices, menu structures, payment flows, POS/KDS integrations, devices, support routes, evidence packets, and owner confirmations are required before launch.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Service mode selection is a readiness contract.

The correct rule is:

A store should not enable a service mode casually.  
Each service mode creates operational, legal, payment, support, and evidence obligations.  
Table order is different from QR menu-only.  
Pickup is different from dine-in.  
Reservation is different from waiting.  
Prepaid order is different from postpaid order.  
Alcohol service is not an ordinary service mode.  
Coupon/event use creates customer notice and reversal obligations.  
Review/photo upload creates content and rights obligations.  
AI may recommend readiness requirements.  
AI cannot approve service mode activation.  

Service mode selection must drive feature gates.

---

## 3. Scope

This policy applies to:

- QR menu-only mode
- table order mode
- mini kiosk mode
- full kiosk mode
- pickup order mode
- delivery handoff mode
- waiting mode
- reservation mode
- reservation deposit mode
- prepaid payment mode
- postpaid payment mode
- split payment mode
- membership mode
- coupon/event mode
- review/content mode
- alcohol service mode
- market price mode
- multilingual customer surface mode
- POS/KDS integration mode
- manual fallback mode
- support route readiness
- launch readiness gates

This policy defines feature readiness governance only.

---

## 4. Service Mode Registry

Recommended service modes:

| Service Mode | Meaning |
|---|---|
| `QR_MENU_ONLY` | Customer views menu only |
| `TABLE_ORDER` | Customer orders from table |
| `MINI_KIOSK_ORDER` | Lightweight kiosk order |
| `FULL_KIOSK_ORDER` | Kiosk with payment/CMS/device controls |
| `PICKUP_ORDER` | Customer orders for pickup |
| `DELIVERY_HANDOFF` | Delivery flow or delivery app handoff |
| `WAITING_QUEUE` | Customer joins or manages waiting |
| `RESERVATION` | Customer reserves table/time |
| `RESERVATION_DEPOSIT` | Reservation with deposit |
| `PREPAID_PAYMENT` | Customer pays before fulfillment |
| `POSTPAID_PAYMENT` | Customer pays after dining |
| `SPLIT_PAYMENT` | Multi-person or partial settlement |
| `MEMBERSHIP` | Customer identity, points, wallet, benefits |
| `COUPON_EVENT` | Promotions, coupons, events |
| `REVIEW_CONTENT` | Customer reviews/photos/content |
| `ALCOHOL_SERVICE` | Alcohol ordering or service |
| `MARKET_PRICE_CONFIRMATION` | Variable price confirmation |
| `MULTILINGUAL_CUSTOMER_SURFACE` | Customer-facing language expansion |
| `POS_INTEGRATION` | POS connected or partially connected |
| `KDS_INTEGRATION` | Kitchen display/ticket routing |
| `MANUAL_FALLBACK` | Manual staff fallback |

Each mode must have readiness status.

---

## 5. Service Mode State Registry

Recommended states:

| State | Meaning |
|---|---|
| `NOT_SELECTED` | Mode not selected |
| `SELECTED_DRAFT` | Store wants mode |
| `REVIEW_REQUIRED` | Readiness review needed |
| `REQUIREMENTS_GENERATED` | Required checks generated |
| `OWNER_CONFIRMATION_PENDING` | Owner must confirm |
| `HQ_REVIEW_PENDING` | HQ review required |
| `LEGAL_REVIEW_PENDING` | Legal review required |
| `PAYMENT_REVIEW_PENDING` | Payment review required |
| `POS_KDS_REVIEW_PENDING` | POS/KDS review required |
| `SUPPORT_REVIEW_PENDING` | Support route required |
| `EVIDENCE_REVIEW_PENDING` | Evidence rules required |
| `READY_WITH_WARNINGS` | Non-blocking gaps remain |
| `READY_AS_PLANNING` | Ready as planning |
| `BLOCKED` | Cannot activate |
| `DEFERRED` | Intentionally deferred |
| `DISABLED` | Disabled |
| `SUPERSEDED` | Replaced by later mode config |

Ready as planning does not authorize runtime.

---

## 6. QR Menu-Only Readiness

QR menu-only mode requires:

| Readiness Area | Requirement |
|---|---|
| Store profile | Complete |
| Menu structure | Reviewed |
| Prices | Reviewed if shown |
| Legal notices | Food safety/store use/legal center |
| Privacy | Minimal unless tracking/customer account exists |
| Payment | Not required if no ordering/payment |
| POS/KDS | Not required |
| Device | QR placement readiness |
| i18n | Required if multilingual menu shown |
| Support | Menu inquiry route |
| Evidence | Minimal view evidence if required |
| Owner confirmation | Required |

QR menu-only is the safest entry mode but still needs menu accuracy.

---

## 7. Table Order Readiness

Table order mode requires:

| Readiness Area | Requirement |
|---|---|
| Table identity | Table IDs/QRs defined |
| Menu structure | Reviewed |
| Options/add-ons | Reviewed |
| Price calculation | Reviewed |
| Order submission | Readiness defined |
| KDS/POS handoff | Integrated or manual fallback defined |
| Refund/cancel notice | Required |
| Food safety notices | Required where relevant |
| Alcohol age-gate | Required if alcohol |
| Support route | Required |
| Evidence | Order, notice, table/session evidence |
| Owner confirmation | Required |

Table order creates operational responsibility.

---

## 8. Mini Kiosk Order Readiness

Mini kiosk mode requires:

- device identity
- store/table or counter scope
- menu display readiness
- order flow readiness
- timeout behavior
- accessibility basics
- language selector if multilingual
- device handling notice
- refund/cancel notice
- payment mode decision
- staff assistance route
- printer/KDS/POS handoff readiness
- fallback behavior
- owner confirmation

Mini kiosk should remain lightweight but controlled.

---

## 9. Full Kiosk Order Readiness

Full kiosk mode requires:

| Readiness Area | Requirement |
|---|---|
| Device management | Required |
| Payment integration | Required if prepaid |
| Receipt handling | Required |
| Refund/cancel policy | Required |
| POS/KDS handoff | Required or manual fallback |
| CMS content control | Required |
| Accessibility | Stronger requirement |
| Language support | Required if multilingual |
| Device incident notice | Required |
| Network fallback | Required |
| Support route | Required |
| Evidence | Payment/order/device evidence |
| Owner/HQ review | Required if franchise |

Full kiosk has higher operational and legal readiness burden.

---

## 10. Pickup Order Readiness

Pickup mode requires:

- pickup time setting
- pickup hold time
- freshness/storage notice
- cancellation cutoff
- prepaid/postpaid decision
- no-show pickup rule if applicable
- customer notification route
- support route
- refund policy
- order state visibility
- packaging notice
- alcohol pickup verification if alcohol
- KDS/POS readiness
- evidence timestamps

Pickup creates time-based evidence needs.

---

## 11. Delivery Handoff Readiness

Delivery handoff mode requires:

| Readiness Area | Requirement |
|---|---|
| Delivery channel | Platform, own delivery, manual |
| Delivery menu difference | Reviewed |
| Delivery price difference | Reviewed |
| Packaging notice | Required |
| Freshness/storage notice | Required |
| Third-party data notice | Required if applicable |
| Alcohol delivery | Disabled by default |
| Refund/cancel policy | Required |
| Delivery delay policy | Required |
| Support route | Required |
| Evidence | Order, handoff, notification evidence |
| Owner confirmation | Required |

Delivery handoff must not assume platform rules equal store rules.

---

## 12. Waiting Queue Readiness

Waiting mode requires:

- waiting registration flow
- customer identity or session model
- call notification method
- call expiry rule
- grace period
- no-show rule
- waiting cancellation route
- privacy notice if phone/customer info used
- support route
- store staff visibility
- table/seating handoff if applicable
- evidence timestamps
- owner confirmation

Waiting creates customer expectation and timestamp evidence.

---

## 13. Reservation Readiness

Reservation mode requires:

| Readiness Area | Requirement |
|---|---|
| Reservation slots | Required |
| Party size rule | Required |
| Reservation cancellation rule | Required |
| Late arrival rule | Required |
| No-show rule | Required |
| Customer notification | Required |
| Privacy notice | Required |
| Table allocation rule | Conditional |
| Staff confirmation | Conditional |
| Support route | Required |
| Evidence | Reservation, notice, notification timestamps |
| Owner/HQ review | Required if franchise |

Reservation without clear rule creates disputes.

---

## 14. Reservation Deposit Readiness

Reservation deposit mode requires:

- deposit amount
- payment provider readiness
- cancellation cutoff
- refund tier
- forfeiture rule
- no-show definition
- late arrival grace period
- customer acknowledgement
- receipt/payment evidence
- support dispute route
- legal notice review
- owner/HQ confirmation
- payment reconciliation path
- legal escalation path

Deposit mode is high-risk and must be blocked if notice or evidence is incomplete.

---

## 15. Prepaid Payment Readiness

Prepaid payment mode requires:

| Readiness Area | Requirement |
|---|---|
| Payment provider | Required |
| Payment intent model | Required in future runtime |
| Refund path | Required |
| Cancel path | Required |
| Provider callback plan | Required |
| Receipt plan | Required |
| Payment notice | Required |
| Privacy/payment data notice | Required |
| Reconciliation route | Required |
| Support route | Required |
| Evidence | Payment/order/notice/provider state |
| Security review | Required |

Prepaid mode must not launch without refund and reconciliation readiness.

---

## 16. Postpaid Payment Readiness

Postpaid payment mode requires:

- table/order continuity
- unpaid order visibility
- split/merge policy if applicable
- staff settlement flow
- receipt policy
- unpaid/abandoned table handling
- customer notice where needed
- POS handoff
- support route
- audit and reconciliation planning

Postpaid mode shifts risk from payment provider to store operations.

---

## 17. Split Payment Readiness

Split payment mode requires:

| Readiness Area | Requirement |
|---|---|
| Order grouping rule | Required |
| Payment identity rule | Required |
| Partial settlement state | Required |
| Remaining balance visibility | Required |
| Coupon/point allocation | Required |
| Refund split rule | Required |
| Receipt split rule | Required |
| Table/customer mapping | Required |
| Support route | Required |
| Reconciliation | Required |
| Evidence | Payment participant/state evidence |

Split payment must not fragment order authority incorrectly.

---

## 18. Membership Readiness

Membership mode requires:

- customer account model
- terms and privacy consent
- optional marketing separation
- point/wallet policy if used
- coupon linkage
- withdrawal/delete route
- customer support route
- identity continuity
- i18n privacy text
- evidence capture
- security review

Membership creates privacy and benefit obligations.

---

## 19. Coupon Event Readiness

Coupon/event mode requires:

| Readiness Area | Requirement |
|---|---|
| Coupon rule | Required |
| Event rule | Required |
| Expiry | Required |
| Stacking | Required |
| Store/franchise scope | Required |
| Refund reversal | Required |
| Abuse restriction | Required |
| Customer notice | Required |
| Support reason codes | Required |
| Owner/HQ review | Required |
| Evidence | Coupon use/reversal evidence |

Coupon/event mode must match actual benefit engine behavior.

---

## 20. Review Content Readiness

Review/content mode requires:

- review eligibility rule
- photo upload policy
- copyright notice
- portrait rights notice
- moderation policy
- deletion/non-restoration notice
- event reward rule if applicable
- support route
- rights report process
- customer notice
- legal review for high-risk wording

Review mode must not suppress legitimate criticism.

---

## 21. Alcohol Service Readiness

Alcohol service mode requires:

| Readiness Area | Requirement |
|---|---|
| Alcohol items confirmed | Required |
| Adult confirmation | Required |
| Staff ID verification | Required |
| POS alcohol category | Required if integrated |
| Delivery alcohol | Disabled by default |
| Pickup verification | Required if pickup |
| Refund on ID failure | Required |
| Staff training | Required |
| Legal notice | Required |
| Support route | Required |
| Evidence | Adult/staff verification evidence |
| Legal/HQ review | Required |

Alcohol service must fail closed.

---

## 22. Market Price Confirmation Readiness

Market price mode requires:

- market price item list
- price confirmation method
- staff confirmation role
- customer confirmation surface
- payment timing rule
- receipt display
- refund/cancel implication
- POS price handling
- support route
- legal notice mapping
- evidence capture

Market price cannot be treated as fixed price or zero price.

---

## 23. Multilingual Customer Surface Readiness

Multilingual customer surface mode requires:

| Readiness Area | Requirement |
|---|---|
| Target locales | Defined |
| Menu translation | Reviewed |
| Legal notice translation | Reviewed for high-risk |
| Fallback policy | Required |
| Korean controlling text | If applicable |
| Staff phrase support | Recommended |
| Support language route | Required |
| Locale evidence | Required |
| Accessibility | Required |

Multilingual mode is customer experience and legal clarity.

---

## 24. POS Integration Readiness

POS integration mode requires:

- POS provider identity
- integration mode
- item code mapping
- option/modifier mapping
- price mapping
- tax/category mapping
- order state mapping
- cancel/refund state mapping
- manual fallback
- reconciliation path
- audit event mapping
- readiness review

POS integration must not be assumed from provider name alone.

---

## 25. KDS Integration Readiness

KDS integration mode requires:

| Readiness Area | Requirement |
|---|---|
| KDS provider | Required |
| Ticket route | Required |
| Kitchen station mapping | Required |
| Option note mapping | Required |
| Set/combo routing | Required |
| Course timing | Required if course |
| Cancel lock state | Required |
| Retry/remake route | Conditional |
| Manual kitchen fallback | Required |
| Evidence | KDS state for disputes |
| Owner/staff review | Required |

KDS readiness affects refund and fulfillment disputes.

---

## 26. Manual Fallback Readiness

Manual fallback mode requires:

- staff procedure
- manual order capture
- manual kitchen note
- manual payment note
- incident reason
- evidence capture method
- later reconciliation
- customer notice if degraded
- support route
- owner/staff training

Manual fallback is planned resilience, not uncontrolled exception.

---

## 27. Feature Dependency Matrix

Recommended dependencies:

| Feature | Depends On |
|---|---|
| Reservation deposit | Reservation + prepaid payment + refund/no-show notice |
| Alcohol pickup | Pickup + alcohol service + staff verification |
| Split payment | Table order + payment reconciliation |
| Coupon refund reversal | Coupon/event + payment/refund state |
| Review reward event | Review/content + coupon/event |
| Market price payment | Market price confirmation + payment |
| Multilingual legal notice | i18n + legal notice review |
| Full kiosk payment | Full kiosk + prepaid payment + receipt |
| KDS cancel lock | KDS integration + refund/cancel policy |
| Manual fallback | Support + audit + reconciliation |

Dependencies must be deterministic.

---

## 28. Blocking Rules

Recommended blocking rules:

| Condition | Result |
|---|---|
| Alcohol service selected without age-gate | Block |
| Prepaid selected without refund path | Block |
| Reservation deposit without no-show notice | Block |
| Pickup without freshness/hold rule | Block |
| Delivery alcohol selected | Block unless separately approved |
| Split payment without reconciliation | Block |
| Coupon/event without terms | Block |
| Review/photo without content notice | Block |
| Multilingual high-risk notice unreviewed | Block or fallback review |
| POS integration claimed without mapping | Block integration claim |
| KDS integration claimed without route mapping | Block integration claim |
| Support route missing for high-risk mode | Block |

Blocking must be visible to onboarding users.

---

## 29. Warning Rules

Warnings may apply when:

- QR menu-only has low-risk notice missing
- multilingual low-risk translation missing
- POS integration deferred but manual fallback exists
- KDS integration deferred but manual kitchen note exists
- coupon/event disabled but future plan exists
- review disabled but policy draft missing
- parking/pet/store-use notice incomplete
- support article missing for low-risk mode
- table count approximate before device setup

Warnings must not override blockers.

---

## 30. Service Mode Readiness Packet

Each store should have a readiness packet containing:

| Section | Meaning |
|---|---|
| Selected modes | Active candidate modes |
| Deferred modes | Intentionally deferred |
| Disabled modes | Not used |
| Required checks | Generated by modes |
| Blocking gaps | Must resolve |
| Warnings | Non-blocking |
| Legal notice requirements | Required notice families |
| Evidence requirements | Required packet types |
| Payment/POS/KDS dependencies | Integration readiness |
| Support route requirements | Case family readiness |
| Owner confirmation | Owner acknowledgement |
| HQ/legal review | If required |
| Launch readiness conclusion | Ready, warning, blocked |
| Audit reference | Evidence |

Service mode packet is onboarding control-plane evidence.

---

## 31. Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `SERVICE_MODE_SELECTED` | Service mode selected |
| `SERVICE_MODE_DISABLED` | Service mode disabled |
| `SERVICE_MODE_DEFERRED` | Service mode deferred |
| `SERVICE_MODE_REQUIREMENTS_GENERATED` | Requirements generated |
| `SERVICE_MODE_BLOCKER_CREATED` | Blocker created |
| `SERVICE_MODE_BLOCKER_RESOLVED` | Blocker resolved |
| `SERVICE_MODE_WARNING_CREATED` | Warning created |
| `SERVICE_MODE_OWNER_CONFIRMED` | Owner confirmed |
| `SERVICE_MODE_HQ_REVIEW_REQUESTED` | HQ review requested |
| `SERVICE_MODE_LEGAL_REVIEW_REQUESTED` | Legal review requested |
| `SERVICE_MODE_PAYMENT_REVIEW_REQUESTED` | Payment review requested |
| `SERVICE_MODE_POS_KDS_REVIEW_REQUESTED` | POS/KDS review requested |
| `SERVICE_MODE_READY_WITH_WARNINGS` | Ready with warnings |
| `SERVICE_MODE_BLOCKED` | Mode blocked |
| `SERVICE_MODE_READY_AS_PLANNING` | Ready as planning |

Events must route through `10610` if implemented later.

---

## 32. AI Assistance Boundary

AI may assist by:

- suggesting service modes from sales intake
- detecting missing readiness checks
- generating requirement checklist
- detecting dependency conflicts
- suggesting legal notice families
- suggesting support case families
- summarizing blockers
- identifying mode incompatibilities
- suggesting safer deferred mode

AI must not:

- enable service mode
- approve readiness
- override blockers
- approve alcohol
- approve payment readiness
- approve POS/KDS integration
- approve privacy consent
- approve legal notices
- mark store launch-ready
- suppress missing support route

AI remains advisory.

---

## 33. Security Boundary

Service mode readiness is control-plane data.

Rules:

- tenant/store scope mandatory
- owner confirmation requires authentication
- HQ review must be franchise-scoped
- sales cannot approve high-risk modes
- support cannot enable modes
- AI cannot enable modes
- service mode changes must be audited
- high-risk mode selection requires review
- selected modes must not expose customer surfaces before activation
- disabled modes must not accidentally create customer flows
- feature flags must not bypass readiness gates

Service mode controls must not be casual toggles.

---

## 34. Anti-Patterns

Avoid:

- enabling every feature by default
- treating QR menu-only as same as order/payment
- enabling prepaid without refund path
- enabling alcohol without staff verification
- enabling deposit without no-show notice
- enabling delivery alcohol casually
- enabling split payment without reconciliation
- enabling coupon without reversal rules
- enabling review photos without rights notice
- claiming POS integration before mapping
- claiming KDS integration before route review
- ignoring manual fallback
- letting AI mark readiness complete
- letting sales override blockers
- hiding readiness warnings from owner

These anti-patterns must remain prohibited.

---

## 35. Runtime Deferral

This document defines store service mode selection and feature readiness governance only.

It does not authorize:

- service mode database implementation
- feature flag implementation
- readiness engine implementation
- launch gate implementation
- payment runtime
- POS/KDS integration runtime
- customer UI
- admin UI
- support runtime
- legal notice runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 36. Validation Checklist

Validation must confirm:

1. Service mode registry is defined.
2. Service mode state registry is defined.
3. QR menu-only readiness is defined.
4. Table order readiness is defined.
5. Mini kiosk readiness is defined.
6. Full kiosk readiness is defined.
7. Pickup readiness is defined.
8. Delivery handoff readiness is defined.
9. Waiting readiness is defined.
10. Reservation readiness is defined.
11. Reservation deposit readiness is defined.
12. Prepaid payment readiness is defined.
13. Postpaid payment readiness is defined.
14. Split payment readiness is defined.
15. Membership readiness is defined.
16. Coupon/event readiness is defined.
17. Review/content readiness is defined.
18. Alcohol service readiness is defined.
19. Market price readiness is defined.
20. Multilingual readiness is defined.
21. POS integration readiness is defined.
22. KDS integration readiness is defined.
23. Manual fallback readiness is defined.
24. Feature dependency matrix is defined.
25. Blocking rules are defined.
26. Warning rules are defined.
27. Service mode readiness packet is defined.
28. Audit events are defined.
29. AI assistance boundary is defined.
30. Security boundary is defined.
31. Anti-patterns are listed.
32. Coding remains unauthorized.
33. Runtime remains deferred.

---

## 37. Relationship To Previous Documents

This document follows:

- `10800 Store Onboarding And Sales Setup Axis Index`
- `10801 Store Sales Intake And Tenant Store Profile Setup Policy`
- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`
- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`
- `10804 Menu Category Option Set Combo Course Review Policy`
- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`
- `10805_01_Ingredient_Master_Pool_Taxonomy_And_Korean_Namul_Seed_Registry_Policy`

It references:

- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`

It prepares:

- `10807 POS Payment KDS Integration Readiness Intake Policy`
- `10808 Store Legal Notice Variable Setup And Owner Confirmation Policy`
- `10809 Store i18n Language Customer Surface Readiness Policy`
- `10810 Table QR Mini Kiosk Device Setup Readiness Policy`
- `10811 Store Support Route Escalation And Case Readiness Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 38. Final Rule

Catch Menu service mode selection must generate explicit readiness requirements.

A store cannot safely enable table ordering, pickup, delivery, waiting, reservation, deposits, prepaid payment, split payment, membership, coupons, reviews, alcohol, market price, multilingual customer surfaces, POS integration, KDS integration, or manual fallback without the corresponding legal, operational, evidence, support, payment, and owner confirmation checks.

AI may recommend readiness requirements.

AI cannot approve service mode activation, override blockers, or mark launch readiness complete.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
