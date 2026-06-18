# 040016_Policy_AI_Menu_Review_Option_Builder_Set_Combo_Course_And_Special_Sales_Pattern_Governance

## 1. Purpose

This document defines the AI Menu Review, Admin Correction, Option Builder, Set Builder, Combo Builder, Course Builder, Promotion Builder, Size Merge, Add-On, Minimum Order, Alcohol Pairing, Corkage, and Special Sales Pattern Governance Policy.

The previous artifacts `40004` through `40015` defined the menu taxonomy seed registry and AI classification dictionary for major Korean restaurant categories:

- Korean Food
- Meat / Grill / BBQ
- Japanese / Seafood / Sushi
- Chinese Food
- Western / Asian / Global Food
- Chicken / Pizza / Fast Food
- Bunsik
- Cafe / Dessert / Beverage
- Salad / Healthy Food
- Pub / Pocha / Late-Night

This document defines the next business process after AI menu photo analysis:

- manager or sales representative review
- original image and AI result split-screen correction
- single item validation
- market-price handling
- set/course/combo creation
- option group binding
- parent-child menu structuring
- price policy and discount calculation
- special sales pattern templates
- alcohol and legal review triggers
- POS/KDS/customer display readiness

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

AI menu parsing produces raw draft material.

Admin review turns it into sellable menu structure.

The correct rule is:

AI extraction is not menu deployment.  
AI draft is not POS truth.  
AI category match is not customer-facing truth.  
AI-detected set text is not confirmed bundle structure.  
Option text is not standalone menu unless reviewed.  
Market price is not zero price.  
Set price is not merely discounted sum unless policy confirms it.  
Alcohol set requires legal and age-gate review.  
Corkage is service fee, not drink inventory.  
Minimum order is a rule, not a menu item.  
Manager correction must be audited.  

The admin page must make complex field sales patterns easy to complete without forcing the owner to type everything from scratch.

---

## 3. Process Scope

This policy applies to:

- AI menu board upload result review
- split-screen original image and parsed result correction
- menu name correction
- price correction
- category correction
- market-price conversion
- fixed price conversion
- set menu creation
- course creation
- combo creation
- 1+1 / 2+1 promotion creation
- size option merge
- sauce/spice option template
- gram-based add-on
- first-order minimum quantity
- unlimited refill per-person pricing
- alcohol set
- corkage / bottle charge
- customer display preview
- POS mapping readiness
- KDS routing readiness
- fast track readiness
- audit and rollback readiness

This policy is about governance and admin process design.

It is not a runtime implementation.

---

## 4. Admin Review Screen Principle

The AI menu review page should use a split-screen model:

| Area | Purpose |
|---|---|
| Left Panel | Original photo, PDF, scanned image, or menu source |
| Right Panel | AI-extracted structured draft |
| Bottom/Side Panel | Validation warnings, confidence, category suggestions, builder actions |
| Preview Panel | Customer menu preview, POS preview, KDS preview if available |

The user must be able to compare the original source and structured result without switching screens.

---

## 5. Step 1: AI Basic Data Verification

Step 1 is single item cleanup.

Admin verifies:

- menu name
- category
- subcategory
- price
- price state
- option candidate
- set candidate
- size candidate
- add-on candidate
- alcohol candidate
- market-price candidate
- confidence warnings
- source bounding box

The first step must clean the raw menu draft before building sets and complex options.

---

## 6. Step 1 Correction Actions

Allowed correction actions:

| Action | Meaning |
|---|---|
| `EDIT_MENU_NAME` | Correct OCR/AI menu name |
| `EDIT_PRICE` | Correct numeric price |
| `EDIT_CATEGORY` | Correct L1/L2/L3 category |
| `EDIT_DESCRIPTION` | Correct description |
| `MARK_AS_OPTION` | Convert item to option/add-on |
| `MARK_AS_NOTICE` | Convert text to notice |
| `MARK_AS_SET` | Convert item to set candidate |
| `MARK_AS_ALCOHOL` | Confirm alcohol item |
| `MARK_AS_MARKET_PRICE` | Keep item as market price |
| `CONVERT_TO_FIXED_PRICE` | Convert market/variable price to fixed price |
| `MERGE_DUPLICATE` | Merge duplicate AI-extracted items |
| `SPLIT_ITEM` | Split incorrectly merged item |
| `IGNORE_TEXT` | Ignore non-menu text |

All correction actions must create audit events.

---

## 7. Market Price Handling

Items detected as:

- 시가
- 싯가
- 변동
- 문의
- 가격문의
- 당일시세
- kg당
- seasonal market price

must not be stored as ordinary zero-price items.

Admin must choose:

| Choice | Meaning |
|---|---|
| `KEEP_MARKET_PRICE` | Keep as market price state |
| `SET_FIXED_PRICE` | Enter fixed price |
| `SET_PRICE_REQUIRED_AT_ORDER` | Customer must ask or staff must confirm |
| `HIDE_FROM_ORDERING` | Visible as inquiry-only or hidden from ordering |
| `DISABLE_ONLINE_PAYMENT` | No online payment until price confirmed |

Market price requires customer display policy.

---

## 8. Price State Registry

Recommended price states:

| State | Meaning |
|---|---|
| `PRICE_FIXED` | Fixed numeric price |
| `PRICE_MARKET` | Market price |
| `PRICE_VARIABLE` | Variable price |
| `PRICE_INQUIRY_REQUIRED` | Ask store |
| `PRICE_BY_WEIGHT` | Weight-based price |
| `PRICE_BY_PERSON` | Per-person price |
| `PRICE_BY_SIZE` | Size option price |
| `PRICE_BY_OPTION` | Option-based price |
| `PRICE_INCLUDED_IN_SET` | Component included in set |
| `PRICE_REVIEW_REQUIRED` | Human review required |

Unknown price must not deploy.

---

## 9. Step 2: Set / Course / Combo Builder Activation

After single item cleanup, the admin page may activate:

    Create Set / Course / Combo

Builder activation requires:

- at least one confirmed base item
- no unresolved critical price error
- no unresolved alcohol/legal error for alcohol sets
- no unresolved market-price checkout error
- category context selected
- tenant/store scope present
- actor authority verified

Builder activation does not mean deployment authorization.

---

## 10. Set Builder Principle

Set builder creates a sellable parent menu from existing menu items or option groups.

A set may include:

- fixed components
- selectable components
- optional upgrades
- included drink
- included side
- discount price
- per-person count
- serving count
- delivery packaging rule
- alcohol/legal rule
- KDS routing rule
- POS mapping rule

Set builder must preserve parent-child relationships.

---

## 11. Set Builder Example

Example:

    Set A = 삼겹살 2인분 + 된장찌개 + 음료수

Recommended structure:

| Field | Value |
|---|---|
| parent_menu | Set A |
| menu_type | set |
| component_1 | 삼겹살 |
| component_1_quantity | 2 servings |
| component_2 | 된장찌개 |
| component_3 | 음료수 |
| price_policy | fixed set price |
| review_state | pending or confirmed |

Set components must remain editable.

---

## 12. Selectable Option Group Builder

Some sets require “choose one” logic.

Example:

    Pasta choose 1: tomato / cream / oil

Recommended structure:

| Field | Value |
|---|---|
| option_group_name | Pasta Choice |
| selection_rule | choose_one |
| min_select | 1 |
| max_select | 1 |
| candidates | tomato pasta, cream pasta, oil pasta |
| price_behavior | included or surcharge |
| required | true |

Selectable option groups prevent messy customer display.

---

## 13. Option Group Types

Recommended option group types:

| Option Group Type | Example |
|---|---|
| `CHOOSE_ONE` | pasta 중 택 1 |
| `CHOOSE_MANY` | toppings 선택 |
| `REQUIRED_ONE` | 맵기 선택 |
| `OPTIONAL_ADDON` | 치즈 추가 |
| `SIZE_OPTION` | 소/중/대 |
| `TEMPERATURE_OPTION` | HOT/ICE |
| `PURCHASE_TYPE_OPTION` | 단품/세트 |
| `PROTEIN_OPTION` | 닭/소/새우 |
| `BASE_OPTION` | 채소/현미밥/메밀면 |
| `DRESSING_OPTION` | 오리엔탈/발사믹 |
| `SAUCE_OPTION` | 부먹/찍먹 |
| `ALCOHOL_UNIT_OPTION` | 잔/병/피처 |
| `CRUST_OPTION` | 치즈크러스트 |
| `BONE_OPTION` | 뼈/순살 |
| `MARKET_PRICE_CONFIRMATION` | 시가 확인 |

Option group type affects POS, KDS, and customer UI.

---

## 14. Step 3: Price Policy And Discount Application

After set components are built, the system should compute reference price.

Example:

| Field | Value |
|---|---|
| component_sum | 34,000 |
| final_set_price | 30,000 |
| discount_amount | 4,000 |
| discount_rate | 11.76% |
| discount_type | set bundle discount |

The admin may choose whether to display discount to customers.

Discount calculation must not override accounting or settlement policy.

---

## 15. Price Policy Types

Recommended price policies:

| Price Policy | Meaning |
|---|---|
| `FIXED_SET_PRICE` | Set has fixed final price |
| `SUM_OF_COMPONENTS` | Price equals component sum |
| `SUM_MINUS_DISCOUNT` | Component sum minus discount |
| `BASE_PLUS_OPTIONS` | Base price plus option deltas |
| `SIZE_BASED_PRICE` | Price by size |
| `PERSON_BASED_PRICE` | Price by person count |
| `WEIGHT_BASED_PRICE` | Price by gram/kg |
| `MARKET_PRICE_REQUIRED` | Price must be confirmed |
| `PROMOTION_PRICE` | Temporary promotion price |
| `TIME_SALE_PRICE` | Time-window price |
| `MANUAL_QUOTE_REQUIRED` | Staff quote required |

Price policy must be explicit.

---

## 16. Special Pattern 1: 1+1 / 2+1 Promotion

Promotion type:

    BUY_X_GET_Y

Examples:

- 하이볼 1+1
- 피자 한판 더
- 음료 2+1
- 타코 2+1
- 치킨 1+1 event

Required fields:

| Field | Meaning |
|---|---|
| buy_quantity | Required purchase quantity |
| get_quantity | Free/additional quantity |
| eligible_buy_items | Items that trigger promotion |
| eligible_get_items | Items that may be gifted |
| cross_choice_allowed | Whether different flavor/item may be selected |
| time_window | Promotion active time |
| day_window | Days active |
| stock_limit | Max quantity if any |
| customer_limit | Per-customer limit if any |
| order_channel_scope | Dine-in, pickup, delivery |
| stacking_rule | Coupon/promotion stacking |
| audit_ref | Audit reference |

1+1 must not be modeled as ordinary discount only.

---

## 17. Promotion Cross-Selection Boundary

Some promotions allow cross-selection.

Example:

    Lemon highball 1+1 may allow Earl Grey highball as free item.

Cross-selection fields:

| Field | Meaning |
|---|---|
| same_item_only | Same item required |
| same_category_allowed | Any item in category allowed |
| whitelist_items | Explicit allowed gift items |
| price_cap | Gift item price must not exceed cap |
| surcharge_allowed | Higher-priced gift with surcharge |
| unavailable_behavior | If selected gift unavailable |

Cross-selection must be explicit.

---

## 18. Special Pattern 2: Combo

Combo type:

    MAIN_PLUS_SIDE_UPGRADE

Examples:

- 라멘 + 미니규동 콤보
- 돈카츠 콤보 with soba
- burger combo with fries and cola
- pasta combo with mini salad
- taco combo with drink

Required fields:

| Field | Meaning |
|---|---|
| main_item | Parent menu |
| side_group | Side options |
| drink_group | Drink options if any |
| upgrade_price | Fixed surcharge |
| included_items | Included components |
| selection_rule | choose one or fixed |
| KDS_routing | Main and side station |
| POS_mapping | Option group or bundle SKU |

Combo is lighter than set but still structured.

---

## 19. Special Pattern 3: Gram-Based Protein Add-On

Add-on type:

    QUANTIFIED_UNIT_ADDON

Examples:

- 고기추가 100g 8,000
- 우삼겹 추가 +3,500
- 소고기추가 100g
- 양고기추가 100g
- 연어추가
- 닭가슴살추가
- 첫 주문 3인분부터
- 추가 1인분 가능

Required fields:

| Field | Meaning |
|---|---|
| addon_name | Add-on name |
| unit_amount | 100 |
| unit | g |
| unit_price | Price |
| parent_menu_scope | Eligible menus |
| minimum_initial_quantity | First-order minimum |
| additional_order_quantity | Add-on order unit |
| inventory_mapping | Ingredient/cut mapping |
| KDS_station | Station |
| weight_rounding_policy | If needed |
| review_state | Review state |

Gram-based add-ons must support inventory and cost tracking.

---

## 20. Minimum Order Rule Boundary

Minimum order is a rule.

It is not a menu item.

Example:

    첫 주문은 3인분부터 가능합니다.
    추가 주문은 1인분 가능.

Recommended structure:

| Field | Value |
|---|---|
| rule_type | minimum_order |
| applies_to | selected menu/category |
| initial_min_quantity | 3 |
| additional_min_quantity | 1 |
| customer_message_key | i18n key |
| enforcement_scope | POS/order UI |
| review_state | confirmed |

This rule affects ordering flow.

---

## 21. Special Pattern 4: Size / Serving Count Option

Option type:

    SIZE_OR_SERVING_OPTION

Examples:

- 탕수육 小 / 中 / 大
- 닭볶음탕 2~3인분
- 감자탕 소/중/대
- 아구찜 중/대
- 족발 앞다리/뒷다리
- 보쌈 소/중/대

Required fields:

| Field | Meaning |
|---|---|
| parent_menu | Base item |
| size_options | Small/medium/large |
| serving_range | 2~3 persons |
| price_by_size | Price list |
| default_size | Optional |
| display_order | UI order |
| KDS_estimate | Cooking/prep impact |
| packaging_impact | Packaging by size |
| review_state | Review state |

AI may initially split sizes into separate menus.

Admin must be able to merge them.

---

## 22. Size Merge Function

If AI extracts:

- 탕수육 소
- 탕수육 중
- 탕수육 대

Admin should be able to select all and click:

    Merge As Size Option

Merge action creates:

| Field | Value |
|---|---|
| parent_menu | 탕수육 |
| option_group | size |
| options | 소, 중, 대 |
| prices | respective prices |

Merge must be reversible.

Merge must create audit event.

---

## 23. Special Pattern 5: Spice Level / Sauce Selection

Option type:

    COMMON_TASTE_OPTION_TEMPLATE

Examples:

- 0단계 담백
- 1단계 신라면
- 2단계 불닭
- 3단계 매우매움
- 부먹/찍먹
- 순한맛/보통맛/매운맛
- 소스 따로
- 드레싱 선택
- 마라 맵기 단계

Required fields:

| Field | Meaning |
|---|---|
| template_name | Spice or sauce template |
| option_values | List of choices |
| applies_to | Store, category, or menu |
| required | true/false |
| default_value | Default option |
| price_delta | If any |
| KDS_message | Kitchen instruction |
| customer_message_key | i18n key |
| review_state | Review state |

Common option templates prevent repetitive manual work.

---

## 24. Store-Wide Option Template Boundary

Option template may apply to:

| Scope | Example |
|---|---|
| Store-wide | All tteokbokki items have spice level |
| Category-wide | All mala items have spice level |
| Menu-specific | One 찜닭 menu has sauce option |
| Set-specific | Set includes drink choice |
| Channel-specific | Delivery requires sauce selection |
| Time-specific | Lunch set options only during lunch |

Template scope must be explicit.

---

## 25. Special Pattern 6: Unlimited Refill / Per-Person Pricing

Pricing type:

    PERSON_BASED_REQUIRED_ORDER

Examples:

- 성인 무한리필 19,900
- 초등학생 12,900
- 미취학 아동 6,000
- 샤브샤브 1인
- 훠궈 1인
- 고기 무한리필 성인/아동

Required fields:

| Field | Meaning |
|---|---|
| pricing_subject | Person |
| person_class | Adult, elementary, child, preschool |
| price_by_class | Price |
| required_by_headcount | Whether required for each person |
| table_headcount_source | Table order / staff input |
| lock_rule | Must order for all eligible persons |
| time_limit | If any |
| refill_scope | Included items |
| exclusion_items | Items not included |
| legal_notice | If needed |
| review_state | Review state |

This pattern affects table order flow.

---

## 26. Headcount Lock Boundary

For per-person pricing, the system may need a lock.

Example:

    Table has 4 adult guests.
    Adult unlimited refill must be ordered quantity 4.

Lock rule must define:

- who confirms headcount
- whether customer can edit
- staff override authority
- child pricing evidence if needed
- audit event
- cancellation behavior
- payment behavior

Headcount lock is not ordinary menu option.

---

## 27. Special Pattern 7: Alcohol Set / Corkage / Bottle Charge

Pattern types:

| Type | Meaning |
|---|---|
| `ALCOHOL_INCLUDED_SET` | Food set includes alcohol |
| `DRINK_PAIRING_OPTION` | Optional alcohol pairing |
| `CORKAGE_FEE` | Customer brings bottle |
| `BOTTLE_CHARGE` | Per-bottle service fee |
| `GLASS_CHARGE` | Per-glass service fee |
| `NON_ALCOHOL_PAIRING` | Non-alcohol drink pairing |

Examples:

- 삼겹 3인분 + 소주 1병 세트
- 사시미 + 화요 세트
- 콜키지 프리
- 양주 콜키지 병당 20,000
- 와인 콜키지 1병 30,000

Alcohol set requires legal/age review.

Corkage is service fee, not inventory drink.

---

## 28. Alcohol Set Governance Boundary

Alcohol set must require:

- alcohol flag
- adult/age verification policy
- customer notice
- legal review state
- delivery restriction
- payment compatibility
- POS alcohol category
- staff accountability
- audit
- refund/cancel rule
- customer display control

AI cannot activate alcohol set automatically.

---

## 29. Corkage / Bottle Charge Boundary

Corkage fields:

| Field | Meaning |
|---|---|
| service_name | Corkage / bottle charge |
| fee_unit | per bottle, per glass, per table |
| allowed_alcohol_type | Wine, whisky, etc. |
| free_limit | Free bottle count if any |
| price | Fee |
| staff_confirmation_required | Yes/no |
| legal_notice | If needed |
| POS_mapping | Service fee category |
| inventory_mapping | None unless store provides item |
| audit_ref | Audit reference |

Corkage must not deduct drink inventory.

---

## 30. Builder Suggestion Engine

After AI classification, the admin page may suggest templates.

Examples:

| Detected Store Type | Suggested Template |
|---|---|
| Meat/Grill | Meat add-on, first-order minimum, after-meal side setup |
| Chinese | Size merge, 곱빼기, half-and-half, set combo |
| Japanese/Seafood | Piece count, market price, sushi set, raw item notice |
| Chicken/Pizza/Fast Food | Single/set price, bone/boneless, half-and-half, pizza crust |
| Bunsik | Topping/sari, set, shorthand restoration |
| Cafe/Dessert | HOT/ICE, size, decaf, milk change |
| Salad/Healthy | Base/protein/dressing/topping option tree |
| Pub/Pocha | Alcohol unit, anju set, corkage, age/legal review |
| BBQ/Jokbal | Size, part, half-and-half, side inclusion |

Suggestion is advisory.

Admin must confirm.

---

## 31. Admin Builder UX Requirements

The builder UI should provide:

- drag/select menu items
- merge as option
- convert to add-on
- convert to notice
- create set
- create combo
- create course
- create 1+1 promotion
- create gram add-on
- create size option
- create spice/sauce template
- create per-person pricing
- create alcohol set
- create corkage fee
- preview customer display
- preview POS mapping
- preview KDS routing
- view discount calculation
- view unresolved warnings
- undo/rollback

UI must reduce manual typing.

---

## 32. Validation Warning Levels

Recommended warning levels:

| Level | Meaning |
|---|---|
| `INFO` | Suggestion or optional improvement |
| `WARNING` | Needs review before deployment |
| `BLOCKER` | Cannot deploy until resolved |
| `LEGAL_REVIEW` | Legal/compliance review required |
| `FINANCIAL_REVIEW` | POS/price/settlement review required |
| `KDS_REVIEW` | Kitchen routing review required |
| `FASTTRACK_REVIEW` | Fast track review required |
| `AI_LOW_CONFIDENCE` | AI confidence too low |

Warnings must be visible before deployment.

---

## 33. Deployment Readiness States

Recommended states:

| State | Meaning |
|---|---|
| `AI_DRAFT_CREATED` | AI parsed draft |
| `BASIC_REVIEW_IN_PROGRESS` | Single item cleanup |
| `BASIC_REVIEW_COMPLETE` | Basic items cleaned |
| `BUILDER_READY` | Set/option builder available |
| `BUILDER_IN_PROGRESS` | Complex menu being structured |
| `OPTION_MAPPING_PENDING` | Options need review |
| `PRICE_POLICY_PENDING` | Price policy needs review |
| `POS_MAPPING_PENDING` | POS mapping needs review |
| `KDS_MAPPING_PENDING` | KDS routing needs review |
| `LEGAL_REVIEW_PENDING` | Legal/alcohol/claim review needed |
| `FASTTRACK_REVIEW_PENDING` | Fast track review needed |
| `DEPLOYMENT_READY` | Ready for deployment approval |
| `DEPLOYED` | Live menu version |
| `ROLLBACK_READY` | Previous version available |
| `REVIEW_BLOCKED` | Blocker exists |

Deployment requires explicit approval.

---

## 34. Audit Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `MENU_AI_REVIEW_STARTED` | Review started |
| `MENU_AI_FIELD_CORRECTED` | Field corrected |
| `MENU_PRICE_STATE_CHANGED` | Price state changed |
| `MENU_MARKET_PRICE_CONFIRMED` | Market price confirmed |
| `MENU_ITEM_MARKED_AS_OPTION` | Item converted to option |
| `MENU_ITEM_MARKED_AS_NOTICE` | Item converted to notice |
| `MENU_SET_BUILDER_STARTED` | Set builder started |
| `MENU_SET_CREATED` | Set created |
| `MENU_COMBO_CREATED` | Combo created |
| `MENU_COURSE_CREATED` | Course created |
| `MENU_SIZE_OPTIONS_MERGED` | Size items merged |
| `MENU_OPTION_TEMPLATE_APPLIED` | Template applied |
| `MENU_PROMOTION_CREATED` | Promotion created |
| `MENU_MINIMUM_ORDER_RULE_CREATED` | Minimum order rule created |
| `MENU_PERSON_PRICING_CREATED` | Per-person pricing created |
| `MENU_ALCOHOL_SET_CREATED` | Alcohol set created |
| `MENU_CORKAGE_FEE_CREATED` | Corkage fee created |
| `MENU_POS_MAPPING_REVIEW_REQUESTED` | POS mapping review requested |
| `MENU_KDS_MAPPING_REVIEW_REQUESTED` | KDS review requested |
| `MENU_FASTTRACK_REVIEW_REQUESTED` | Fast track review requested |
| `MENU_LEGAL_REVIEW_REQUESTED` | Legal review requested |
| `MENU_DEPLOYMENT_READY` | Ready for deployment |
| `MENU_BUILDER_ROLLED_BACK` | Builder change rolled back |

Events must route through `10610`.

---

## 35. Authority Boundary

Admin builder actions require authority.

Authority examples:

| Action | Authority Requirement |
|---|---|
| Edit menu name | Store menu editor |
| Edit price | Store owner or authorized manager |
| Convert market price to fixed price | Price authority |
| Create set | Menu editor |
| Apply discount | Price authority |
| Create promotion | Owner/HQ policy authority |
| Create alcohol set | Legal/owner authority |
| Create corkage fee | Owner/HQ authority |
| Apply fast track | Fast track authority |
| Deploy live menu | Deployment authority |
| Rollback menu | Deployment authority |

Visibility is not authority.

AI recommendation is not authority.

---

## 36. Tenant And Store Scope Boundary

Every builder object must carry:

- tenant_id
- store_id
- menu_version_id
- source_file_id
- actor_id
- authority_context
- policy_version
- audit_ref

A set or option created in one store must not appear in another store unless explicitly created as franchise template and approved.

Tenant isolation remains mandatory.

---

## 37. POS Mapping Boundary

Builder output must map cleanly to POS concepts:

- base item
- option group
- modifier
- bundle
- set
- course
- promotion
- service fee
- discount
- alcohol item
- weight-based item
- per-person item
- market-price item
- delivery restriction
- tax category
- inventory deduction rule

POS mapping remains review-required.

AI and builder do not finalize financial truth.

---

## 38. KDS Mapping Boundary

Builder output must map cleanly to KDS concepts:

- kitchen ticket item
- option note
- station routing
- set component routing
- timing dependency
- course sequencing
- combo assembly
- drink/bar routing
- packaging station
- pickup readiness
- fast track eligibility
- excluded option

KDS mapping remains review-required.

A set is not necessarily one KDS ticket line.

---

## 39. Customer Display Boundary

Customer display must avoid messy menu duplication.

Customer display should show:

- parent menu
- clean option groups
- set components
- choose-one choices
- add-ons
- size options
- price impact
- alcohol/legal notices
- market-price notice
- minimum order notice
- availability
- fast track badge if approved

Draft builder structure must not be exposed to customers until deployed.

---

## 40. Rollback Boundary

Every builder operation must be reversible before deployment.

Rollback targets:

- field correction
- option merge
- set creation
- combo creation
- promotion creation
- price policy change
- alcohol set creation
- corkage creation
- POS mapping change
- KDS mapping change
- customer display change

Deployed rollback must create a new version or restore previous version through governed process.

Rollback is not silent mutation.

---

## 41. Anti-Patterns

Avoid:

- forcing owners to manually type all set structures from scratch
- treating AI draft as deployed menu
- treating 시가 as zero price
- treating set components as independent paid menus without structure
- treating 1+1 as ordinary discount only
- treating combo as free-text description only
- treating minimum order notice as menu item
- treating size variants as unrelated items when they are options
- applying spice template to all menus without scope
- treating per-person pricing as ordinary item quantity
- treating alcohol set as ordinary food set
- treating corkage as inventory drink
- applying fast track before option complexity review
- deploying without POS/KDS mapping review
- allowing AI to create live option groups without human confirmation

These anti-patterns must be blocked in future runtime design.

---

## 42. Runtime Deferral

This document defines AI menu review, option builder, set builder, combo builder, course builder, promotion pattern, and special sales pattern governance boundaries only.

It does not authorize:

- admin UI implementation
- builder runtime
- POS mapping implementation
- KDS mapping implementation
- promotion engine
- option engine
- market-price engine
- alcohol legal engine
- fast track engine
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 43. Validation Checklist

Validation must confirm:

1. Admin review screen principle is defined.
2. Step 1 AI basic data verification is defined.
3. Step 1 correction actions are defined.
4. Market price handling is defined.
5. Price state registry is defined.
6. Step 2 builder activation is defined.
7. Set builder principle is defined.
8. Set builder example is defined.
9. Selectable option group builder is defined.
10. Option group types are defined.
11. Step 3 price policy and discount application is defined.
12. Price policy types are defined.
13. 1+1 / 2+1 promotion pattern is defined.
14. Promotion cross-selection boundary is defined.
15. Combo pattern is defined.
16. Gram-based protein add-on pattern is defined.
17. Minimum order rule boundary is defined.
18. Size/serving count option pattern is defined.
19. Size merge function is defined.
20. Spice/sauce selection pattern is defined.
21. Store-wide option template boundary is defined.
22. Unlimited refill/per-person pricing is defined.
23. Headcount lock boundary is defined.
24. Alcohol set/corkage pattern is defined.
25. Alcohol set governance boundary is defined.
26. Corkage/bottle charge boundary is defined.
27. Builder suggestion engine is defined.
28. Admin builder UX requirements are defined.
29. Validation warning levels are defined.
30. Deployment readiness states are defined.
31. Audit event catalog is defined.
32. Authority boundary is defined.
33. Tenant/store scope boundary is defined.
34. POS mapping boundary is defined.
35. KDS mapping boundary is defined.
36. Customer display boundary is defined.
37. Rollback boundary is defined.
38. Anti-patterns are listed.
39. Coding remains unauthorized.
40. Runtime remains deferred.

---

## 44. Relationship To Previous Documents

This document supplements:

- `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `40006 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40007 Korean Meat Grill BBQ Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40008 Japanese Seafood Sushi Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40009 Chinese Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40010 Western Asian Global Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40011 Chicken Pizza Fast Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40012 Bunsik Gimbap Tteokbokki Snack Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40013 Cafe Dessert Beverage Bakery Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40014 Salad Healthy Food Poke Yogurt Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40015 Pub Pocha Late Night Delivery Alcohol Anju Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`
- `10701 Five-Minute Smart Order Fast Track KDS Throttling No-Show Penalty And Abuse Control Boundary Policy`

It prepares possible future documents:

- `40017 Menu Taxonomy Master Closure And Label Dictionary Governance Policy`
- `40018 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`
- `40019 POS KDS Menu Option Mapping Readiness Policy`
- `40020 Menu Builder Admin UI Permission Matrix Policy`
- `40021 Menu Builder Deployment Rollback And Versioning SOP Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 45. Final Rule

AI menu analysis extracts raw draft menu data.

The admin review and builder process turns that draft into sellable, structured, auditable menu configuration.

The platform must support three stages:

1. basic AI data verification and correction
2. set, course, combo, option, add-on, promotion, and special sales pattern building
3. price policy, discount, POS, KDS, legal, fast track, and deployment readiness review

Special field patterns such as 1+1, combo, gram-based add-on, minimum order, size option, spice/sauce template, unlimited refill, alcohol set, and corkage must be first-class templates.

AI may suggest templates.

Human confirmation, authority gates, tenant/store scope, audit, POS/KDS review, legal review where applicable, versioning, and rollback remain mandatory.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.