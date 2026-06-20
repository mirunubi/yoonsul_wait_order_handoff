# 010905_Policy_Allergen_Alcohol_Raw_Food_Market_Price_Detection_Handoff.md

## Purpose

This document defines the Allergen, Alcohol, Raw Food, and Market Price Detection Handoff Policy for Catch Menu.

The previous document `10804 Menu Category Option Set Combo Course Review Policy` defined structured menu review for categories, options, add-ons, sets, combos, courses, component inheritance, price calculation, coupon applicability, POS mapping, and KDS routing.

This document focuses on high-risk menu attribute detection and handoff.

It defines how AI, owner review, HQ review, food safety review, legal review, and support readiness should handle:

- allergen candidates
- alcohol candidates
- raw food candidates
- market price candidates
- spicy/high-risk ingredient candidates
- bone/shell candidates
- health claim candidates
- set/combo/course hidden component risks
- option/add-on inherited risks
- notice and evidence handoff

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

High-risk menu attributes must be detected early and confirmed separately.

The correct rule is:

AI may detect risk candidates.  
AI may not confirm legal or food safety facts.  
Owner may confirm menu intent and ingredients.  
Food safety/QC may review allergen and raw food risk.  
Legal/HQ may review alcohol, refund, market price, and notice obligations.  
A hidden component still creates parent menu risk.  
A risk candidate must not be ignored because it appears in an option, set, combo, or course.  
Unknown high-risk state must block or escalate.  

Risk detection is a handoff workflow, not a final decision.

---

## 3. Scope

This policy applies to:

- allergen candidate detection
- alcohol candidate detection
- raw food candidate detection
- market price candidate detection
- extreme spice detection
- bone/shell warning detection
- health/nutrition claim detection
- freshness/storage risk detection
- option/add-on risk inheritance
- set/combo/course risk inheritance
- menu material source linkage
- owner confirmation
- HQ review
- food safety/QC review
- legal review
- legal notice handoff
- evidence packet handoff
- support playbook handoff
- launch readiness blocking

This policy defines detection and handoff governance only.

---

## 4. Risk Candidate Types

Recommended candidate types:

| Candidate Type | Meaning |
|---|---|
| `ALLERGEN_CANDIDATE` | Menu may contain regulated or common allergen |
| `ALCOHOL_CANDIDATE` | Menu may contain alcoholic beverage or ingredient |
| `RAW_FOOD_CANDIDATE` | Menu may include raw or undercooked food |
| `MARKET_PRICE_CANDIDATE` | Price is variable or requires confirmation |
| `EXTREME_SPICE_CANDIDATE` | Very spicy or challenge-level menu |
| `BONE_SHELL_CANDIDATE` | Bone, shell, pit, hard object risk |
| `HEALTH_CLAIM_CANDIDATE` | Diet, detox, immune, medical-like claim |
| `FRESHNESS_STORAGE_CANDIDATE` | Takeout/storage/reheating risk |
| `SET_COMPONENT_RISK_CANDIDATE` | Risk hidden in set/combo/course component |
| `OPTION_INHERITED_RISK_CANDIDATE` | Risk introduced by option/add-on |
| `PRICE_CONFLICT_CANDIDATE` | Price differs across sources |
| `LEGAL_NOTICE_REQUIRED_CANDIDATE` | Notice likely required |

Candidate type is not final classification.

---

## 5. Risk Detection Source

Risk candidates may come from:

| Source | Example |
|---|---|
| AI menu parsing | “맥주”, “새우”, “육회”, “시가” detected |
| Owner input | Owner marks item as alcohol or raw food |
| HQ master menu | Brand allergen/alcohol data |
| POS export | Alcohol category or modifier |
| Ingredient list | Peanut, shrimp, egg, milk |
| Menu description | Raw egg, rare steak, fresh oyster |
| Option/add-on | Cheese, egg, shrimp add-on |
| Set component | Beer included in combo |
| Course pairing | Wine pairing |
| Delivery app capture | Platform-specific alcohol/delivery restriction |
| Support case trend | Repeated allergen dispute |
| Legal review | Notice required |
| Food safety/QC review | Allergen warning required |

Every candidate should preserve source reference.

---

## 6. Detection Record Header

Each risk candidate record should include:

| Field | Required | Meaning |
|---|---:|---|
| `candidate_id` | yes | Candidate identity |
| `tenant_id` | yes | Tenant scope |
| `store_id` | conditional | Store scope |
| `onboarding_case_id` | yes | Onboarding context |
| `menu_item_draft_id` | conditional | Related draft item |
| `option_value_id` | conditional | Related option |
| `set_combo_course_id` | conditional | Related parent structure |
| `component_item_id` | conditional | Related component |
| `candidate_type` | yes | Risk candidate type |
| `source_material_id` | conditional | Source material |
| `source_location_ref` | optional | Page/image/row region |
| `detected_by` | yes | AI, owner, HQ, reviewer, support |
| `detected_at` | yes | Detection time |
| `confidence_score` | conditional | AI confidence if AI-generated |
| `review_state` | yes | Pending/confirmed/rejected |
| `audit_ref` | yes | Audit reference |

Risk candidate must remain traceable.

---

## 7. Candidate Review States

Recommended review states:

| State | Meaning |
|---|---|
| `CANDIDATE_DETECTED` | Candidate detected |
| `OWNER_CONFIRMATION_REQUIRED` | Owner must confirm |
| `OWNER_CONFIRMED` | Owner confirmed candidate fact |
| `OWNER_REJECTED` | Owner rejected candidate |
| `HQ_REVIEW_REQUIRED` | HQ review required |
| `FOOD_SAFETY_REVIEW_REQUIRED` | Food/QC review required |
| `LEGAL_REVIEW_REQUIRED` | Legal review required |
| `I18N_REVIEW_REQUIRED` | Translation review required |
| `NOTICE_MAPPING_REQUIRED` | Notice trigger/surface required |
| `EVIDENCE_RULE_REQUIRED` | Evidence capture rule required |
| `CONFIRMED_RISK` | Risk confirmed |
| `REJECTED_FALSE_POSITIVE` | Candidate rejected |
| `BLOCKED_UNRESOLVED` | Cannot proceed |
| `READY_WITH_NOTICE` | Risk ready with notice |
| `READY_WITH_STAFF_CONFIRMATION` | Staff confirmation required |
| `SUPERSEDED` | Replaced by later candidate |

Unknown high-risk candidate should not be silently ignored.

---

## 8. Allergen Candidate Policy

Allergen candidate detection should include:

| Check | Requirement |
|---|---|
| Candidate allergen name | Required |
| Source text or ingredient | Required |
| Direct ingredient or cross-contact | Distinguish |
| Option/add-on source | Required if option-based |
| Set/component inheritance | Required if bundled |
| Owner confirmation | Required |
| Food safety/QC review | Required for high-risk |
| Customer display notice | Required if confirmed |
| KDS highlight | Conditional |
| Exclusion/substitution rule | Conditional |
| Evidence requirement | Required for high-risk |
| Support route | Required |

Allergen candidate must not be treated as final without review.

---

## 9. Allergen Candidate Examples

Examples:

| Detected Text | Candidate |
|---|---|
| 새우 | Shellfish candidate |
| 계란 | Egg candidate |
| 우유, 치즈, 크림 | Milk/dairy candidate |
| 땅콩, 견과류 | Peanut/tree nut candidate |
| 밀, 빵, 면 | Wheat/gluten candidate |
| 참깨, 깨소스 | Sesame candidate |
| 간장 | Soy/wheat candidate |
| 마요네즈 | Egg candidate |
| 해물 | Shellfish/fish candidate |
| 치킨 소스 | Ingredient review required |

Examples are candidate rules only.

---

## 10. Alcohol Candidate Policy

Alcohol candidate detection should include:

| Check | Requirement |
|---|---|
| Candidate alcohol item | Required |
| Alcohol type | Beer, soju, wine, cocktail, etc. |
| ABV if known | Conditional |
| Serving unit | Conditional |
| Set/combo inclusion | Required if bundled |
| Option/add-on inclusion | Required if option |
| Owner confirmation | Required |
| HQ/legal review | Required |
| Age-gate notice | Required |
| Staff ID verification policy | Required |
| Delivery block | Default block unless separately approved |
| Payment/refund on ID failure | Required |
| POS alcohol category | Required if integrated |
| Evidence packet | Required |

Alcohol candidate must fail closed if uncertain.

---

## 11. Alcohol Candidate Examples

Examples:

| Detected Text | Candidate |
|---|---|
| 맥주 | Alcohol candidate |
| 소주 | Alcohol candidate |
| 와인 | Alcohol candidate |
| 막걸리 | Alcohol candidate |
| 칵테일 | Alcohol candidate |
| 하이볼 | Alcohol candidate |
| 사케 | Alcohol candidate |
| 샴페인 | Alcohol candidate |
| 무알콜 맥주 | Adult beverage review candidate |
| 와인 페어링 | Course alcohol candidate |
| 콜키지 | Alcohol service policy candidate |

Non-alcohol wording must still be reviewed if adult beverage confusion exists.

---

## 12. Raw Food Candidate Policy

Raw food candidate detection should include:

| Check | Requirement |
|---|---|
| Raw/undercooked item | Required |
| Source text | Required |
| Ingredient involved | Required |
| Preparation state | Raw, rare, undercooked |
| Owner confirmation | Required |
| Food safety review | Required |
| Customer warning | Required if confirmed |
| Takeout/delivery restriction | Conditional |
| KDS handling note | Conditional |
| Refund/cancel notice implication | Conditional |
| Evidence requirement | Conditional |
| Support route | Required for complaint |

Raw food warning must appear before selection or checkout.

---

## 13. Raw Food Candidate Examples

Examples:

| Detected Text | Candidate |
|---|---|
| 육회 | Raw beef candidate |
| 사시미 | Raw fish candidate |
| 회 | Raw fish candidate |
| 굴 | Raw seafood candidate |
| 반숙 | Undercooked egg candidate |
| 레어 | Undercooked meat candidate |
| 타르타르 | Raw/undercooked candidate |
| 생연어 | Raw salmon candidate |
| 날치알 | Raw/seafood review candidate |
| 수란 | Undercooked egg candidate |

Food safety review determines final handling.

---

## 14. Market Price Candidate Policy

Market price candidate detection should include:

| Check | Requirement |
|---|---|
| Variable price phrase | Required |
| Source text | Required |
| Price confirmation method | Required |
| Owner confirmation | Required |
| Staff confirmation requirement | Conditional |
| Customer confirmation surface | Required |
| Payment timing effect | Required |
| Receipt display | Required |
| Refund/cancel implication | Required |
| Evidence capture | Required |
| POS price handling | Required if integrated |
| Support route | Required |

Market price must not be represented as a normal fixed price.

---

## 15. Market Price Candidate Examples

Examples:

| Detected Text | Candidate |
|---|---|
| 시가 | Market price |
| 변동가 | Market price |
| 당일가 | Market price |
| 싯가 | Market price |
| 문의 | Price confirmation required |
| 계절가 | Seasonal variable price |
| kg당 | Weight-based price |
| 100g당 | Weight-based price |
| 주문 전 확인 | Confirmation required |
| 가격 변동 | Variable price |

Market price requires pre-order customer confirmation.

---

## 16. Extreme Spice Candidate Policy

Extreme spice candidate detection should include:

- spice level
- challenge menu wording
- customer warning need
- option-level spice inheritance
- refund limitation if customer selected extreme spice
- staff caution if needed
- i18n warning text
- owner confirmation
- customer display surface
- support reason code

Extreme spice is not ordinary flavor preference when marketed as challenge or unusually strong.

---

## 17. Bone Shell Candidate Policy

Bone/shell candidate detection should include:

- fish bone
- chicken bone
- shellfish shell
- crab shell
- clam shell
- olive pit
- fruit seed
- hard spice fragment
- customer warning need
- takeout warning
- staff/KDS note if needed
- owner confirmation
- support route

Bone/shell warning may be important for customer safety.

---

## 18. Health Claim Candidate Policy

Health/nutrition claim detection should include:

| Claim Type | Examples |
|---|---|
| Diet claim | 다이어트, 체중감량 |
| Detox claim | 디톡스 |
| Medical claim | 면역, 치료, 혈당 |
| Functional claim | 장건강, 피로회복 |
| Low-calorie claim | 저칼로리 |
| High-protein claim | 고단백 |
| No-sugar claim | 무설탕 |
| Vegan/vegetarian claim | 비건, 채식 |
| Gluten-free claim | 글루텐프리 |
| Organic claim | 유기농 |

Health claims require owner/legal/marketing review.

AI cannot approve health claims.

---

## 19. Freshness Storage Candidate Policy

Freshness/storage candidate detection applies when:

- pickup is enabled
- delivery is enabled
- raw food exists
- dairy/cream exists
- seafood exists
- hot/cold separation matters
- reheating required
- storage time matters
- takeout delay affects quality
- customer must consume within a time window

Freshness/storage notice may be needed for dispute prevention.

---

## 20. Option Add-On Risk Inheritance

Option/add-on risk inheritance rules:

| Option/Add-On Risk | Parent Item Effect |
|---|---|
| Shrimp add-on | Parent item allergen candidate |
| Cheese add-on | Parent item dairy candidate |
| Egg add-on | Parent item egg candidate |
| Alcohol sauce | Parent item alcohol candidate |
| Raw egg option | Parent item raw food candidate |
| Extra spicy option | Parent item spice warning candidate |
| Market price add-on | Parent item market price confirmation |
| Bone-in option | Parent item bone warning |
| Gluten-free option | Health/claim review candidate |

Options can transform risk state.

---

## 21. Set Combo Course Risk Inheritance

Set/combo/course inheritance rules:

| Component Risk | Parent Effect |
|---|---|
| Alcohol component | Parent requires alcohol age-gate |
| Raw component | Parent requires raw food warning |
| Allergen component | Parent requires allergen notice |
| Market price component | Parent requires price confirmation |
| Course deposit | Parent requires no-show/deposit notice |
| Wine pairing | Course requires alcohol review |
| Seafood component | Food safety review |
| Coupon-excluded component | Coupon applicability review |
| KDS timing component | Course/service timing review |
| Substitution component | Substitution consent review |

A parent menu must not hide component obligations.

---

## 22. Review Handoff Matrix

Recommended handoff matrix:

| Candidate | Owner | HQ | Food Safety/QC | Legal | Payment/POS/KDS | i18n | Support |
|---|---:|---:|---:|---:|---:|---:|---:|
| Allergen | Yes | If franchise | Yes | If high-risk | KDS if note needed | Yes | Yes |
| Alcohol | Yes | If franchise | No | Yes | POS/payment/KDS | Yes | Yes |
| Raw Food | Yes | If franchise | Yes | If needed | KDS if route needed | Yes | Yes |
| Market Price | Yes | If franchise | No | If needed | Payment/POS | Yes | Yes |
| Extreme Spice | Yes | If brand | Optional | Optional | KDS note | Yes | Yes |
| Bone/Shell | Yes | If brand | Yes | Optional | KDS note | Yes | Yes |
| Health Claim | Yes | HQ/Marketing | Optional | Yes | No | Yes | Yes |
| Freshness | Yes | If brand | Yes | Optional | Pickup/delivery | Yes | Yes |

Handoff requirements depend on risk and service mode.

---

## 23. Legal Notice Mapping

Confirmed risk may require legal notice mapping.

Examples:

| Risk | Notice Family |
|---|---|
| Allergen | Food safety/allergen notice |
| Cross-contact | Food safety/cross-contact notice |
| Raw food | Raw/undercooked food warning |
| Alcohol | Alcohol age-gate notice |
| Market price | Market price confirmation notice |
| Extreme spice | Spicy warning notice |
| Bone/shell | Bone/shell caution notice |
| Health claim | Health/nutrition disclaimer |
| Freshness | Takeout/storage notice |
| Course deposit | No-show/deposit notice |

Notice mapping must follow `10719`.

---

## 24. Evidence Handoff

Risk confirmation should define evidence needs:

| Risk | Evidence Need |
|---|---|
| Allergen | Notice shown, item snapshot, option snapshot |
| Alcohol | Adult confirmation, staff verification |
| Raw food | Warning shown before order |
| Market price | Price confirmed before payment |
| Extreme spice | Customer selection and warning |
| Bone/shell | Warning shown if required |
| Health claim | Reviewed claim version |
| Freshness | Pickup/delivery notice |
| Set component | Component snapshot |
| Option risk | Option selection snapshot |

Evidence handoff must follow `10730`.

---

## 25. Support Handoff

Confirmed risk should create support readiness:

| Risk | Support Preparation |
|---|---|
| Allergen | Food safety case reason codes |
| Alcohol | ID/refusal/refund reason codes |
| Raw food | Freshness/raw food complaint route |
| Market price | Price dispute route |
| Extreme spice | Customer selection dispute route |
| Bone/shell | Safety complaint route |
| Health claim | Legal/marketing escalation |
| Freshness | Pickup/delivery dispute route |
| Set hidden component | Component visibility dispute route |
| Option risk | Option selection evidence route |

Support playbook must be ready before launch.

---

## 26. Blocking Rules

Recommended blocking rules:

| Condition | Result |
|---|---|
| Alcohol candidate unresolved | Block |
| Allergen high-risk candidate unresolved | Block |
| Raw food candidate unresolved | Block |
| Market price candidate unresolved | Block |
| Health claim unresolved | Block if customer-facing claim |
| Set component alcohol unresolved | Block |
| Option allergen unresolved | Block if selectable |
| Price conflict unresolved | Block |
| Notice mapping missing for confirmed high-risk | Block |
| Evidence rule missing for confirmed high-risk | Block |
| i18n missing for high-risk customer surface | Block or fallback review |

Blocking protects store and platform.

---

## 27. Warning Rules

Warnings may apply when:

- low-risk spice warning unresolved
- bone/shell warning needs wording improvement
- low-risk freshness notice translation missing
- optional support article missing
- non-customer-facing internal category unclear
- risk candidate rejected but confidence record retained
- delivery-only menu has separate unreviewed notice while delivery disabled
- coupon review pending while coupon feature disabled

Warnings must not hide high-risk blockers.

---

## 28. Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `MENU_RISK_CANDIDATE_CREATED` | Risk candidate created |
| `MENU_RISK_CANDIDATE_OWNER_CONFIRMED` | Owner confirmed candidate |
| `MENU_RISK_CANDIDATE_OWNER_REJECTED` | Owner rejected candidate |
| `MENU_RISK_FOOD_SAFETY_REVIEW_REQUESTED` | Food safety review requested |
| `MENU_RISK_LEGAL_REVIEW_REQUESTED` | Legal review requested |
| `MENU_RISK_HQ_REVIEW_REQUESTED` | HQ review requested |
| `MENU_RISK_CONFIRMED` | Risk confirmed |
| `MENU_RISK_REJECTED` | Candidate rejected |
| `MENU_RISK_NOTICE_MAPPING_CREATED` | Notice mapping created |
| `MENU_RISK_EVIDENCE_RULE_CREATED` | Evidence rule created |
| `MENU_RISK_SUPPORT_HANDOFF_CREATED` | Support handoff created |
| `MENU_RISK_BLOCKER_CREATED` | Blocking risk created |
| `MENU_RISK_BLOCKER_RESOLVED` | Blocking risk resolved |
| `MENU_RISK_READY_WITH_NOTICE` | Risk ready with notice |

Events must route through `10610` if implemented later.

---

## 29. Security Boundary

Risk detection security rules:

- tenant/store scope mandatory
- risk flags must not leak across tenants
- AI candidate output must be marked draft
- owner confirmation requires authentication
- HQ review must be franchise-scoped
- food safety/legal review access must be role-scoped
- alcohol candidates are regulated feature data
- allergen data is food safety-sensitive
- health claim review is legal/marketing-sensitive
- risk rejection history must remain auditable
- support handoff must not expose unnecessary personal data

Risk detection is compliance-sensitive.

---

## 30. Anti-Patterns

Avoid:

- treating AI risk candidate as final fact
- treating absence of AI detection as absence of risk
- ignoring option/add-on allergens
- hiding alcohol inside set menu
- treating non-alcohol adult beverage as always safe
- showing market price without pre-order confirmation
- treating “문의” price as zero
- hiding raw food warning until receipt
- allowing health claims without review
- suppressing low-confidence risk candidates
- letting sales reject risk candidates alone
- letting owner bypass legal alcohol review
- launching high-risk menu without notice mapping
- launching high-risk menu without evidence rule
- deleting rejected candidate history

These anti-patterns must remain prohibited.

---

## 31. Runtime Deferral

This document defines allergen, alcohol, raw food, market price, and related risk detection handoff governance only.

It does not authorize:

- risk detection implementation
- AI classification runtime
- allergen database implementation
- alcohol category implementation
- market price confirmation runtime
- legal notice trigger implementation
- evidence capture runtime
- support handoff runtime
- menu database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 32. Validation Checklist

Validation must confirm:

1. Risk candidate types are defined.
2. Risk detection sources are defined.
3. Detection record header is defined.
4. Candidate review states are defined.
5. Allergen candidate policy is defined.
6. Allergen examples are defined.
7. Alcohol candidate policy is defined.
8. Alcohol examples are defined.
9. Raw food candidate policy is defined.
10. Raw food examples are defined.
11. Market price candidate policy is defined.
12. Market price examples are defined.
13. Extreme spice candidate policy is defined.
14. Bone/shell candidate policy is defined.
15. Health claim candidate policy is defined.
16. Freshness/storage candidate policy is defined.
17. Option/add-on risk inheritance is defined.
18. Set/combo/course risk inheritance is defined.
19. Review handoff matrix is defined.
20. Legal notice mapping is defined.
21. Evidence handoff is defined.
22. Support handoff is defined.
23. Blocking rules are defined.
24. Warning rules are defined.
25. Audit events are defined.
26. Security boundary is defined.
27. Anti-patterns are listed.
28. Coding remains unauthorized.
29. Runtime remains deferred.

---

## 33. Relationship To Previous Documents

This document follows:

- `10800 Store Onboarding And Sales Setup Axis Index`
- `10801 Store Sales Intake And Tenant Store Profile Setup Policy`
- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`
- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`
- `10804 Menu Category Option Set Combo Course Review Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10705` through `10714` AI Menu Taxonomy Seed Registry policies
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`
- `10734 Legal Notice Support Playbook And Case Reason Code Policy`
- `10804 Menu Category Option Set Combo Course Review Policy`

It prepares:

- `10806 Store Service Mode Selection And Feature Readiness Policy`
- `10807 POS Payment KDS Integration Readiness Intake Policy`
- `10808 Store Legal Notice Variable Setup And Owner Confirmation Policy`
- `10809 Store i18n Language Customer Surface Readiness Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 34. Final Rule

Catch Menu must detect and hand off high-risk menu attributes before customer-facing launch.

Allergen, alcohol, raw food, market price, extreme spice, bone/shell, health claim, freshness, option-inherited risk, and set/combo/course component risk must be source-linked, review-stated, owner-confirmed, and escalated to HQ, food safety, legal, payment/POS/KDS, i18n, or support review where required.

AI may detect candidates and suggest handoff.

AI cannot confirm facts, approve alcohol, approve allergen safety, approve market price behavior, approve health claims, suppress risk, or approve launch readiness.

Unknown high-risk state must block or escalate.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
