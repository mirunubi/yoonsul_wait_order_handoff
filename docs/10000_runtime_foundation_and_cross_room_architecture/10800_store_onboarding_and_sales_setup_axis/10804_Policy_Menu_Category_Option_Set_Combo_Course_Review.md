# 10804_Policy_Menu_Category_Option_Set_Combo_Course_Review

## 1. Purpose

This document defines the Menu Category, Option, Set, Combo, and Course Review Policy for Catch Menu.

The previous document `10803 AI Menu Parsing Correction And Owner Review Workflow Policy` defined AI parsing, confidence handling, owner correction, conflict resolution, risk handoff, and owner confirmation.

This document focuses on structured menu review after AI parsing and owner correction.

It defines:

- category review
- menu hierarchy review
- option group review
- option value review
- add-on review
- set menu review
- combo menu review
- course menu review
- component inheritance
- price calculation review
- KDS/POS implications
- legal notice implications
- owner/HQ/domain review boundaries

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Structured menu design is operational design.

The correct rule is:

A menu item is not only a name and price.  
A category changes customer navigation.  
An option changes price, allergens, preparation, KDS routing, and refund logic.  
A set menu can hide regulated components.  
A combo can change coupon and tax behavior.  
A course can create timing and service obligations.  
AI may suggest structure.  
Owner/HQ must review structure.  
Legal/domain review is required when structure changes risk.  

Structured menu review must prevent hidden operational and legal defects.

---

## 3. Scope

This policy applies to:

- menu category review
- subcategory review
- menu display order
- item grouping
- option group review
- option value review
- required/optional option rules
- add-on review
- size option review
- spice option review
- sauce option review
- set menu review
- combo menu review
- course menu review
- component inheritance
- price calculation
- discount calculation
- coupon applicability
- POS item mapping
- KDS route mapping
- allergen/alcohol/raw food inheritance
- market price behavior
- legal notice handoff
- owner/HQ confirmation

This policy defines review governance only.

---

## 4. Menu Structure Levels

Recommended menu structure levels:

| Level | Meaning |
|---|---|
| `MENU_CATALOG` | Store menu catalog |
| `MENU_SECTION` | Large area such as food, drinks, lunch |
| `CATEGORY` | Customer-facing category |
| `SUBCATEGORY` | Optional narrower grouping |
| `MENU_ITEM` | Orderable item |
| `OPTION_GROUP` | Choice group such as size or spice |
| `OPTION_VALUE` | Specific option choice |
| `ADD_ON` | Additional item or modifier |
| `SET_MENU` | Fixed or selectable bundled menu |
| `COMBO_MENU` | Bundle with pricing/discount rule |
| `COURSE_MENU` | Sequential service menu |
| `COMPONENT_ITEM` | Item inside set/combo/course |

Each level must preserve ownership, review state, and risk inheritance.

---

## 5. Category Review Policy

Category review should confirm:

| Check | Requirement |
|---|---|
| Category name | Owner/HQ confirmation |
| Customer-facing label | Required |
| Internal category mapping | Required if POS/KDS integration |
| Display order | Required |
| Parent/child relation | Required if subcategory |
| Store category fit | Required |
| Tax/payment implication | Conditional |
| Alcohol category flag | Required if drinks/alcohol |
| Kitchen routing implication | Conditional |
| Legal notice implication | Conditional |
| i18n label readiness | Required if multilingual |
| Owner/HQ review state | Required |

Category is not just UI decoration.

---

## 6. Category State Registry

Recommended category states:

| State | Meaning |
|---|---|
| `DRAFT` | AI or system draft |
| `OWNER_REVIEW_PENDING` | Owner review required |
| `OWNER_CONFIRMED` | Owner confirmed |
| `HQ_REVIEW_PENDING` | HQ review required |
| `HQ_CONFIRMED` | HQ confirmed |
| `DOMAIN_REVIEW_PENDING` | Food/alcohol/payment review needed |
| `I18N_REVIEW_PENDING` | Translation review needed |
| `READY_AS_DRAFT` | Structured draft ready |
| `BLOCKED` | Cannot proceed |
| `DEPRECATED` | Not for new use |
| `SUPERSEDED` | Replaced by new category |

Category readiness does not mean launch readiness.

---

## 7. Option Group Review Policy

Option group review should confirm:

| Check | Requirement |
|---|---|
| Option group name | Required |
| Option group purpose | Required |
| Required/optional flag | Required |
| Single/multiple selection | Required |
| Minimum selection count | Conditional |
| Maximum selection count | Conditional |
| Default value | Conditional |
| Price impact | Required if priced |
| Allergen impact | Required |
| Alcohol impact | Required |
| Raw food impact | Required |
| KDS routing impact | Conditional |
| POS modifier mapping | Conditional |
| Refund/cancel implication | Conditional |
| Sold-out behavior | Conditional |
| Owner confirmation | Required |

Option group configuration can break ordering if wrong.

---

## 8. Option Value Review Policy

Option value review should confirm:

| Check | Requirement |
|---|---|
| Option value label | Required |
| Price delta | Required if priced |
| Default flag | Conditional |
| Ingredient implication | Conditional |
| Allergen implication | Conditional |
| Alcohol implication | Conditional |
| Spice level | Conditional |
| Size impact | Conditional |
| Preparation impact | Conditional |
| KDS note impact | Conditional |
| POS modifier code | Conditional |
| Sold-out state | Conditional |
| Legal notice trigger | Conditional |
| Owner confirmation | Required |

Option values must not hide risk.

---

## 9. Required Option Governance

Required options must be clear.

Rules:

1. Required option must block incomplete order selection.
2. Required option must have clear label.
3. Required option must not hide price increase.
4. Required option must not force alcohol selection without age-gate.
5. Required option must not force allergen component without warning.
6. Required option default must be reviewed.
7. Required option must map to POS/KDS if orderable.
8. Required option must be included in order evidence.
9. Required option must be visible on receipt if it changes price or preparation.
10. Required option must be included in refund dispute evidence.

Required option is order contract data.

---

## 10. Optional Add-On Governance

Optional add-ons must define:

- add-on label
- add-on price
- add-on ingredient
- add-on allergen
- add-on alcohol flag if any
- add-on raw food flag if any
- add-on KDS route
- add-on POS modifier or item code
- add-on sold-out behavior
- add-on refund behavior
- add-on coupon applicability
- add-on display order
- add-on max quantity

Optional does not mean risk-free.

---

## 11. Size Option Review

Size options should define:

| Field | Meaning |
|---|---|
| Size label | Small, medium, large, etc. |
| Base item relation | Which item size modifies |
| Price delta | Price impact |
| Portion impact | Portion difference |
| Packaging impact | Packaging difference |
| Nutrition/allergen impact | If changed |
| KDS impact | Prep quantity |
| POS mapping | Modifier or separate item |
| Receipt display | Customer evidence |
| Availability | Sold-out by size if applicable |

Size can affect price and operations.

---

## 12. Spice Option Review

Spice options should define:

- spice level label
- numeric level if used
- customer warning threshold
- extreme spice warning
- ingredient difference
- allergen implication
- default spice level
- kitchen note mapping
- staff caution if needed
- refund limitation notice if customer selects extreme option

Spice challenge or extreme spice requires careful notice.

---

## 13. Sauce Option Review

Sauce options should define:

- sauce label
- default sauce
- alternative sauce
- price delta
- allergen implication
- alcohol ingredient if any
- raw egg/dairy/nut presence if any
- kitchen route
- packaging effect
- add-on quantity
- sold-out behavior

Sauce can materially change allergen risk.

---

## 14. Set Menu Review Policy

Set menu review should confirm:

| Check | Requirement |
|---|---|
| Set name | Required |
| Fixed components | Required if fixed |
| Selectable components | Required if selectable |
| Component quantities | Required |
| Component prices | Conditional |
| Total price | Required |
| Discount logic | Conditional |
| Alcohol component flag | Required |
| Allergen component flag | Required |
| Raw food component flag | Required |
| Market price component | Conditional |
| Substitution rule | Required |
| Coupon applicability | Required |
| Refund split rule | Required |
| POS mapping | Required if integrated |
| KDS routing | Required |
| Owner/HQ confirmation | Required |

Set menu must inherit component risks.

---

## 15. Combo Menu Review Policy

Combo menu review should confirm:

- combo name
- base item
- add-on item
- discount rule
- required components
- optional components
- beverage component
- alcohol component
- dessert component
- side component
- coupon compatibility
- point accrual effect
- receipt display
- refund component logic
- POS mapping
- KDS routing
- legal notice inheritance

Combo discount must not hide restricted items.

---

## 16. Course Menu Review Policy

Course menu review should confirm:

| Check | Requirement |
|---|---|
| Course name | Required |
| Course sequence | Required |
| Number of courses | Required |
| Service timing | Required |
| Per-person price | Required |
| Minimum persons | Conditional |
| Reservation requirement | Conditional |
| Deposit requirement | Conditional |
| Cancellation rule | Required |
| Alcohol pairing | Conditional |
| Allergy check | Required |
| Substitution rule | Required |
| KDS timing | Required |
| Staff confirmation | Required |
| Legal notice handoff | Required |

Course menu creates service obligations and timing risk.

---

## 17. Component Inheritance Rules

Component risk inheritance must follow these rules:

| Component Risk | Parent Menu Behavior |
|---|---|
| Alcohol component | Set/combo/course inherits alcohol flag |
| Allergen component | Parent inherits allergen warning |
| Raw food component | Parent inherits raw food warning |
| Market price component | Parent inherits market price confirmation |
| Extreme spice component | Parent inherits spice warning |
| Coupon-excluded component | Parent coupon eligibility reviewed |
| Refund-locked component | Parent refund/cancel reviewed |
| KDS-special route | Parent KDS route reviewed |
| Sold-out component | Parent availability depends on component |
| Regulated ingredient | Parent legal review required |

Parent item must not hide component risk.

---

## 18. Price Calculation Review

Price calculation review should define:

- base price
- option price delta
- add-on price
- set price
- combo discount
- course per-person price
- market price override
- tax inclusion
- dine-in price
- pickup price
- delivery price
- coupon discount order
- point accrual base
- refund calculation
- receipt display

Price calculation must be deterministic.

---

## 19. Coupon Applicability Review

Coupon applicability should check:

| Check | Requirement |
|---|---|
| Coupon applies to base item | Required |
| Coupon applies to options | Required |
| Coupon applies to add-ons | Required |
| Coupon applies to set/combo | Required |
| Alcohol excluded | Required if alcohol |
| Event menu excluded | Conditional |
| Market price excluded | Conditional |
| Minimum order calculation | Required |
| Stacking allowed | Required |
| Refund reversal | Required |
| Customer notice | Required |

Coupon logic must match customer notice.

---

## 20. POS Mapping Review

POS mapping should check:

- item code
- category code
- modifier code
- option code
- set/combo code
- course code if supported
- tax category
- alcohol category
- kitchen printer group
- inventory link if any
- sold-out sync if any
- manual fallback mapping
- unknown mapping state
- POS conflict state

POS mapping must be reviewed before integration claims.

---

## 21. KDS Routing Review

KDS routing should check:

| Menu Structure | KDS Concern |
|---|---|
| Base item | Kitchen station |
| Option | Prep note |
| Add-on | Station or item route |
| Set menu | Multiple station route |
| Combo | Component route |
| Course | Sequenced fire timing |
| Alcohol | Bar/service route |
| Raw food | Special prep route |
| Allergy exclusion | Highlighted kitchen note |
| Market price | Staff confirmation note |
| Sold-out component | Availability block |

KDS route affects kitchen execution and refund timing.

---

## 22. Customer Display Review

Customer display review should check:

- category label clarity
- option label clarity
- required option clarity
- price delta visibility
- set component visibility
- alcohol component visibility
- allergen warning visibility
- raw food warning visibility
- market price confirmation visibility
- coupon limitation visibility
- receipt display clarity
- i18n label readiness
- accessibility

Customer must understand what is being ordered.

---

## 23. Owner Confirmation Packet

Owner confirmation packet should include:

| Section | Meaning |
|---|---|
| Categories confirmed | Category structure |
| Options confirmed | Option groups and values |
| Add-ons confirmed | Add-on rules |
| Sets confirmed | Set components and price |
| Combos confirmed | Combo rule and price |
| Courses confirmed | Course sequence and timing |
| Component risks confirmed | Alcohol/allergen/raw/market |
| POS mapping notes | If any |
| KDS routing notes | If any |
| Price calculation notes | If any |
| Coupon applicability notes | If any |
| Remaining review items | Blockers/warnings |
| Owner acknowledgement | Authenticated confirmation |
| Audit reference | Evidence |

Owner confirmation is not legal approval.

---

## 24. HQ Franchise Review Packet

HQ review packet should include:

- brand category compliance
- item naming compliance
- price band compliance
- set/combo compliance
- course compliance
- coupon/event compliance
- alcohol policy compliance
- allergen/origin master alignment
- store override request
- HQ lock requirement
- franchise template version
- review decision
- audit reference

HQ review applies only within tenant/franchise scope.

---

## 25. Legal Domain Handoff

Legal/domain handoff is required when:

- set/combo includes alcohol
- course includes alcohol pairing
- option changes allergen risk
- add-on contains allergen
- raw food is included
- market price appears
- no-show/deposit applies to course/reservation
- refund restriction differs by menu type
- coupon excludes regulated item
- health/nutrition claim appears
- customer warning required
- i18n high-risk text needed

Menu structure can create legal notice obligations.

---

## 26. Review State Registry

Recommended states:

| State | Meaning |
|---|---|
| `STRUCTURE_DRAFT` | Draft menu structure |
| `OWNER_STRUCTURE_REVIEW_PENDING` | Owner review needed |
| `OWNER_STRUCTURE_CONFIRMED` | Owner confirmed |
| `HQ_STRUCTURE_REVIEW_PENDING` | HQ review needed |
| `DOMAIN_RISK_REVIEW_PENDING` | Legal/QC/payment review needed |
| `POS_MAPPING_REVIEW_PENDING` | POS review needed |
| `KDS_ROUTING_REVIEW_PENDING` | KDS review needed |
| `I18N_LABEL_REVIEW_PENDING` | i18n review needed |
| `STRUCTURE_READY_WITH_WARNINGS` | Non-blocking warnings |
| `STRUCTURE_BLOCKED` | Blocking issue |
| `STRUCTURE_READY_AS_DRAFT` | Draft ready for next readiness gate |
| `STRUCTURE_SUPERSEDED` | Replaced |
| `STRUCTURE_DEPRECATED` | Retired |

Ready as draft does not mean active.

---

## 27. Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `MENU_CATEGORY_REVIEW_STARTED` | Category review started |
| `MENU_CATEGORY_CONFIRMED` | Category confirmed |
| `MENU_OPTION_GROUP_REVIEWED` | Option group reviewed |
| `MENU_OPTION_VALUE_REVIEWED` | Option value reviewed |
| `MENU_ADDON_REVIEWED` | Add-on reviewed |
| `MENU_SET_REVIEWED` | Set reviewed |
| `MENU_COMBO_REVIEWED` | Combo reviewed |
| `MENU_COURSE_REVIEWED` | Course reviewed |
| `MENU_COMPONENT_RISK_INHERITED` | Component risk inherited |
| `MENU_PRICE_CALCULATION_REVIEWED` | Price calculation reviewed |
| `MENU_COUPON_APPLICABILITY_REVIEWED` | Coupon applicability reviewed |
| `MENU_POS_MAPPING_REVIEWED` | POS mapping reviewed |
| `MENU_KDS_ROUTING_REVIEWED` | KDS routing reviewed |
| `MENU_STRUCTURE_OWNER_CONFIRMED` | Owner confirmed structure |
| `MENU_STRUCTURE_HQ_CONFIRMED` | HQ confirmed structure |
| `MENU_STRUCTURE_BLOCKED` | Structure blocked |
| `MENU_STRUCTURE_READY_AS_DRAFT` | Structure draft ready |

Events must route through `10610` if implemented later.

---

## 28. Security Boundary

Menu structure review security rules:

- tenant/store scope mandatory
- franchise/HQ templates must be scoped
- owner confirmation requires authentication
- sales cannot approve structure alone
- AI cannot approve structure
- POS codes are operationally sensitive
- KDS routing may reveal store operation details
- allergen/alcohol risk flags must not be hidden
- correction history must remain auditable
- cross-tenant structure leakage prohibited
- customer-facing labels must not expose internal codes

Structured menu data is SaaS control-plane data.

---

## 29. Anti-Patterns

Avoid:

- treating category as cosmetic only
- hiding alcohol in set menu
- hiding allergen in option/add-on
- applying coupon to regulated item by accident
- showing price delta only after checkout
- allowing required option without clear label
- allowing default option that changes price without notice
- allowing set/combo without component review
- allowing course without timing/cancel rule
- treating POS mapping as automatically correct
- treating KDS routing as irrelevant to refund
- letting AI resolve component inheritance alone
- letting sales approve menu structure
- launching with unresolved structure blockers

These anti-patterns must remain prohibited.

---

## 30. Runtime Deferral

This document defines menu category, option, set, combo, and course review governance only.

It does not authorize:

- menu structure database implementation
- option builder implementation
- set/combo/course builder implementation
- POS mapping runtime
- KDS routing runtime
- price calculation runtime
- coupon engine runtime
- customer menu UI
- owner review UI
- HQ review UI
- audit runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 31. Validation Checklist

Validation must confirm:

1. Menu structure levels are defined.
2. Category review policy is defined.
3. Category state registry is defined.
4. Option group review policy is defined.
5. Option value review policy is defined.
6. Required option governance is defined.
7. Optional add-on governance is defined.
8. Size option review is defined.
9. Spice option review is defined.
10. Sauce option review is defined.
11. Set menu review policy is defined.
12. Combo menu review policy is defined.
13. Course menu review policy is defined.
14. Component inheritance rules are defined.
15. Price calculation review is defined.
16. Coupon applicability review is defined.
17. POS mapping review is defined.
18. KDS routing review is defined.
19. Customer display review is defined.
20. Owner confirmation packet is defined.
21. HQ franchise review packet is defined.
22. Legal/domain handoff is defined.
23. Review state registry is defined.
24. Audit events are defined.
25. Security boundary is defined.
26. Anti-patterns are listed.
27. Coding remains unauthorized.
28. Runtime remains deferred.

---

## 32. Relationship To Previous Documents

This document follows:

- `10800 Store Onboarding And Sales Setup Axis Index`
- `10801 Store Sales Intake And Tenant Store Profile Setup Policy`
- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`
- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`

It references:

- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10705` through `10714` AI Menu Taxonomy Seed Registry policies
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`
- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`

It prepares:

- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`
- `10806 Store Service Mode Selection And Feature Readiness Policy`
- `10807 POS Payment KDS Integration Readiness Intake Policy`
- `10808 Store Legal Notice Variable Setup And Owner Confirmation Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 33. Final Rule

Catch Menu structured menu review must treat categories, options, add-ons, sets, combos, and courses as operational and legal configuration, not simple display text.

Any menu structure that changes price, preparation, allergen risk, alcohol status, raw food status, market price behavior, coupon eligibility, refund logic, POS mapping, or KDS routing must be reviewed and source-linked.

AI may suggest structure and detect risk.

AI cannot approve structure, resolve conflicts silently, inherit risk alone, approve prices, approve alcohol/allergen classification, or approve launch readiness.

Owner/HQ/domain review remains required.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.