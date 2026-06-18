# 040004_Policy_AI_Menu_Category_Context_Two_Level_Taxonomy_And_Classification

## 1. Purpose

This document defines the AI Menu Category Context, Two-Level Food Business Taxonomy, and Menu Classification Policy.

The previous artifact `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy` defined how menu images, PDFs, text lists, and menu boards may be uploaded, parsed by AI, reviewed by humans, validated, approved, versioned, deployed, and rolled back.

This document adds the category context layer needed before AI parsing:

- store business type selection
- large category selection
- middle category taxonomy
- AI prompt narrowing
- menu clustering
- OCR/LLM accuracy improvement
- hallucination reduction
- token/cost reduction
- menu default inference
- fast track attribute prefill
- KDS station recommendation
- cooking time default recommendation
- i18n/category governance

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

AI menu parsing must not begin from a blank universe.

The correct rule is:

Store category context improves AI accuracy.  
Large category narrows the search space.  
Middle category structures the extracted menu.  
AI classification is recommendation, not final truth.  
Menu category affects KDS, cooking time, fast track, POS, inventory, analytics, and customer browsing.  
Category taxonomy must be editable, versioned, tenant-scoped, and franchise-governed.  
AI must choose from approved categories unless review mode allows new category proposal.  
Unknown category must become review, not hallucinated certainty.  

The platform must guide AI before asking it to classify menu data.

---

## 3. Classification Scope

This policy applies to:

- initial store onboarding
- AI menu board upload
- seasonal menu upload
- franchise template menu import
- OCR/LLM menu parsing
- menu category recommendation
- menu clustering
- menu tag inference
- KDS station recommendation
- cooking time recommendation
- fast track eligibility recommendation
- menu analytics grouping
- customer app category display
- POS/KDS/inventory mapping
- i18n category label rendering
- multi-store category standardization

This taxonomy is a planning registry.

It is not a runtime implementation.

---

## 4. Two-Level Taxonomy Principle

The platform uses a two-level taxonomy:

| Level | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Store/business cuisine or operating type | Korean Food, Japanese Food, Chinese Food, Cafe/Dessert |
| `L2_MENU_CATEGORY` | Menu family inside the business type | Kimbap, Noodle, Sushi, Donkatsu, Beverage |

The L1 category gives AI context.

The L2 category organizes extracted menu items.

Additional tags may refine menu meaning but must not replace L1/L2.

---

## 5. Admin Category Selection Flow

Recommended admin flow:

1. Admin opens AI menu intake.
2. Admin selects L1 business category.
3. Admin optionally selects one or more likely L2 categories.
4. Admin uploads image/PDF/text/spreadsheet.
5. AI parses using selected category context.
6. AI creates structured menu draft with L2 candidates.
7. Admin reviews uncertain categories.
8. Admin confirms or corrects categories.
9. Menu validation checks required category fields.
10. Approved menu version is deployed.

Two clicks before upload can reduce downstream correction effort.

---

## 6. L1 Business Category Registry

Recommended L1 categories:

| L1 Code | Label | Scope |
|---|---|---|
| `KOREAN_FOOD` | Korean Food | 한식 |
| `JAPANESE_FOOD` | Japanese Food | 일식 |
| `CHINESE_FOOD` | Chinese Food | 중식 |
| `WESTERN_ASIAN_FOOD` | Western & Asian Food | 양식/아시안 |
| `CAFE_DESSERT` | Cafe & Dessert | 카페/디저트 |
| `FASTFOOD_CHICKEN` | Fast Food & Chicken | 패스트푸드/치킨 |
| `PUB_BAR` | Pub & Bar | 주점/포차 |
| `BUFFET_COURSE` | Buffet & Course Dining | 뷔페/코스 |
| `BAKERY_RETAIL` | Bakery & Retail Food | 베이커리/식품판매 |
| `HEALTH_WELLNESS` | Health & Wellness Food | 샐러드/포케/다이어트 |
| `DELIVERY_SPECIALTY` | Delivery Specialty | 배달 전문 |
| `MULTI_CONCEPT` | Multi-Concept Store | 복합 업태 |
| `UNKNOWN_REVIEW_REQUIRED` | Unknown / Review Required | 미분류 |

L1 category must be editable during review.

---

## 7. Korean Food L2 Registry

Recommended L2 categories for `KOREAN_FOOD`:

| L2 Code | Label | Examples |
|---|---|---|
| `KOREAN_GRILL_STIR_BRAISE` | Grill / Stir-Fry / Braise | 삼겹살, 갈비, 제육볶음, 생선구이 |
| `KOREAN_SOUP_STEW_HOTPOT` | Soup / Stew / Hotpot | 김치찌개, 된장찌개, 국밥, 삼계탕, 감자탕 |
| `KOREAN_NOODLE` | Noodles | 냉면, 칼국수, 잔치국수, 수제비 |
| `KOREAN_RICE_BIBIMBAP_PORRIDGE` | Rice / Bibimbap / Porridge | 비빔밥, 볶음밥, 덮밥, 죽 |
| `KOREAN_SNACK_BUNSIK` | Bunsik / Snack | 떡볶이, 튀김, 순대, 김밥, 라면 |
| `KOREAN_JOKBAL_BOSSAM` | Jokbal / Bossam | 족발, 보쌈, 편육 |
| `KOREAN_STEAMED_SPICY_DISH` | Steamed / Spicy Braised Dish | 닭볶음탕, 아구찜, 갈비찜 |
| `KOREAN_SIDE_DISH` | Side Dish / Banchan | 반찬, 계란말이, 전 |
| `KOREAN_SET_MEAL` | Set Meal / Hanjeongsik | 백반, 정식, 한정식 |
| `KOREAN_SEASONAL` | Seasonal Korean | 계절 메뉴 |

Korean Food may require mixed category support because many stores combine rice, soup, noodle, and side dishes.

---

## 8. Japanese Food L2 Registry

Recommended L2 categories for `JAPANESE_FOOD`:

| L2 Code | Label | Examples |
|---|---|---|
| `JAPANESE_SUSHI_SASHIMI` | Sushi / Sashimi | 모듬초밥, 사시미, 회덮밥 |
| `JAPANESE_DONKATSU_TEMPURA` | Donkatsu / Tempura | 등심카츠, 안심카츠, 텐동 |
| `JAPANESE_NOODLE` | Ramen / Udon / Soba | 돈코츠라멘, 붓카케우동, 냉소바 |
| `JAPANESE_DONBURI_CURRY` | Donburi / Curry | 규동, 사케동, 일본식 카레 |
| `JAPANESE_IZAKAYA_SKEWER` | Izakaya / Skewer | 야키토리, 오뎅탕, 타코와사비 |
| `JAPANESE_BENTO_SET` | Bento / Set Meal | 도시락, 정식, 세트 |
| `JAPANESE_SIDE` | Side / Small Dish | 고로케, 교자, 샐러드 |
| `JAPANESE_DRINK` | Drink | 라무네, 하이볼, 사케 |

Japanese category context helps distinguish 우동, 돈부리, 카츠, 사케동, 텐동, and sushi variants.

---

## 9. Chinese Food L2 Registry

Recommended L2 categories for `CHINESE_FOOD`:

| L2 Code | Label | Examples |
|---|---|---|
| `CHINESE_NOODLE` | Noodles | 짜장면, 짬뽕, 울면, 마라탕, 우육면 |
| `CHINESE_RICE` | Rice | 볶음밥, 잡채밥, 짬뽕밥 |
| `CHINESE_FRIED_DISH` | Fried Dish | 탕수육, 꿔바로우, 유린기, 깐풍기 |
| `CHINESE_STIR_SPECIAL` | Stir-Fry / Special Dish | 양장피, 팔보채, 고추잡채, 마파두부 |
| `CHINESE_DUMPLING_DIMSUM` | Dumpling / Dimsum | 군만두, 물만두, 샤오롱바오 |
| `CHINESE_MALA_HOTPOT` | Mala / Hotpot | 마라탕, 마라샹궈, 훠궈 |
| `CHINESE_SET_COMBO` | Set / Combo | 세트메뉴, 코스요리 |
| `CHINESE_SIDE` | Side | 단무지, 춘권, 소스 추가 |

Chinese category context must handle Korean-style Chinese and regional/traditional Chinese.

---

## 10. Western And Asian Food L2 Registry

Recommended L2 categories for `WESTERN_ASIAN_FOOD`:

| L2 Code | Label | Examples |
|---|---|---|
| `WESTERN_PASTA_RISOTTO` | Pasta / Risotto | 토마토 파스타, 크림 파스타, 리조또 |
| `WESTERN_PIZZA_STEAK` | Pizza / Steak | 화덕피자, 팬피자, 스테이크 |
| `WESTERN_BURGER_SANDWICH` | Burger / Sandwich | 수제버거, 샌드위치, 파니니 |
| `WESTERN_SALAD_BRUNCH` | Salad / Brunch | 샐러드, 에그 베네딕트, 브런치 플레이트 |
| `ASIAN_RICE_NOODLE` | Asian Rice / Noodle | 쌀국수, 팟타이, 나시고랭 |
| `ASIAN_TACO_WRAP` | Taco / Wrap / Fusion | 타코, 브리또, 랩 |
| `WESTERN_SIDE` | Side | 감자튀김, 치즈볼, 수프 |
| `WESTERN_SET_COURSE` | Set / Course | 세트, 코스 |

This category may overlap with health/wellness and fast food.

Admin review must handle ambiguity.

---

## 11. Cafe And Dessert L2 Registry

Recommended L2 categories for `CAFE_DESSERT`:

| L2 Code | Label | Examples |
|---|---|---|
| `CAFE_COFFEE_ESPRESSO` | Coffee / Espresso | 아메리카노, 라떼, 아인슈페너 |
| `CAFE_NON_COFFEE_DRINK` | Non-Coffee / Beverage | 에이드, 티, 스무디, 주스 |
| `CAFE_BAKERY_DESSERT` | Bakery / Dessert | 케이크, 크로플, 쿠키, 소금빵 |
| `CAFE_BINGSU_ICECREAM` | Bingsu / Ice Cream | 팥빙수, 젤라또 |
| `CAFE_BRUNCH_LIGHT_MEAL` | Brunch / Light Meal | 샌드위치, 샐러드, 토스트 |
| `CAFE_SET` | Set Menu | 커피 세트, 디저트 세트 |
| `CAFE_RETAIL` | Retail Goods | 원두, 드립백, 병음료 |

Cafe/Dessert category often has option-heavy menus.

Option extraction must be emphasized.

---

## 12. Fast Food And Chicken L2 Registry

Recommended L2 categories for `FASTFOOD_CHICKEN`:

| L2 Code | Label | Examples |
|---|---|---|
| `CHICKEN_FRIED_SEASONED` | Fried / Seasoned Chicken | 후라이드, 양념치킨, 반반 |
| `CHICKEN_GRILLED_ROASTED` | Grilled / Roasted Chicken | 구운치킨, 로스트치킨 |
| `CHICKEN_DAKGANGJEONG` | Dakgangjeong | 닭강정 |
| `FASTFOOD_BURGER` | Burger | 치즈버거, 불고기버거 |
| `FASTFOOD_PIZZA` | Pizza | 피자, 세트 |
| `FASTFOOD_SIDE` | Side | 감자튀김, 치즈스틱 |
| `FASTFOOD_DRINK` | Drink | 탄산음료, 쉐이크 |
| `FASTFOOD_SET_COMBO` | Set / Combo | 세트메뉴, 패밀리팩 |

Franchise-style menus often require option/combo parsing.

---

## 13. Pub And Bar L2 Registry

Recommended L2 categories for `PUB_BAR`:

| L2 Code | Label | Examples |
|---|---|---|
| `PUB_COOKED_DISH` | Cooked Anju | 골뱅이무침, 두부김치, 탕류 |
| `PUB_DRY_SNACK` | Dry Snack | 먹태, 오징어, 견과 |
| `PUB_FRIED_SNACK` | Fried Snack | 감자튀김, 치즈볼, 튀김 |
| `PUB_SOUP_STEW` | Soup / Stew | 오뎅탕, 부대찌개, 나가사키짬뽕탕 |
| `PUB_ALCOHOL_SOJU_BEER` | Soju / Beer | 소주, 맥주 |
| `PUB_ALCOHOL_TRADITIONAL` | Traditional Alcohol | 막걸리, 전통주 |
| `PUB_ALCOHOL_COCKTAIL_WINE` | Cocktail / Wine / Highball | 하이볼, 와인, 칵테일 |
| `PUB_SET_PLATTER` | Set / Platter | 모듬안주, 세트 |

Alcohol-related menus may require age/legal policy separation.

---

## 14. Buffet And Course L2 Registry

Recommended L2 categories for `BUFFET_COURSE`:

| L2 Code | Label | Examples |
|---|---|---|
| `BUFFET_ENTRY` | Buffet Entry | 성인, 아동, 런치, 디너 |
| `BUFFET_TIME_SLOT` | Time Slot / Session | 평일런치, 주말디너 |
| `COURSE_MENU` | Course Menu | 런치코스, 디너코스 |
| `COURSE_ADDON` | Course Add-on | 와인페어링, 추가요리 |
| `BUFFET_DRINK` | Drink | 음료, 주류 |
| `BUFFET_CHILD_SENIOR` | Child / Senior Pricing | 아동, 경로 |
| `BUFFET_SPECIAL` | Special Event | 시즌 특선 |

Buffet/course menus may classify price by time/person rather than item.

AI must avoid treating each phrase as separate food item.

---

## 15. Health And Wellness L2 Registry

Recommended L2 categories for `HEALTH_WELLNESS`:

| L2 Code | Label | Examples |
|---|---|---|
| `WELLNESS_SALAD` | Salad | 샐러드 |
| `WELLNESS_POKE_BOWL` | Poke / Bowl | 포케, 웜볼 |
| `WELLNESS_PROTEIN_CUP` | Protein Cup | 단백질컵 |
| `WELLNESS_WRAP_SANDWICH` | Wrap / Sandwich | 랩, 샌드위치 |
| `WELLNESS_SMOOTHIE_JUICE` | Smoothie / Juice | 스무디, 주스 |
| `WELLNESS_LOW_CALORIE` | Low-Calorie Meal | 저칼로리 식단 |
| `WELLNESS_ADDON_TOPPING` | Add-on / Topping | 닭가슴살 추가, 아보카도 추가 |
| `WELLNESS_DRESSING_SAUCE` | Dressing / Sauce | 드레싱, 소스 |

This category is highly relevant to 윤슬김밥/윤슬마루 future bowls and protein cups.

Health claims must be controlled.

---

## 16. Multi-Concept Store Boundary

Some stores have multiple concepts.

Examples:

- kimbap plus cafe
- brunch plus bowl
- chicken plus beer
- bakery plus coffee
- pub plus Japanese dishes
- franchise store plus seasonal local menu
- shop-in-shop night delivery menu

For `MULTI_CONCEPT`, admin may select multiple L1 categories.

AI must parse with multiple weighted category contexts.

Menu item confidence should show which L1 context influenced classification.

---

## 17. Unknown Category Review Boundary

If AI cannot classify confidently:

- assign `UNKNOWN_REVIEW_REQUIRED`
- show candidate categories
- show source evidence
- require admin selection
- do not auto-deploy
- do not infer fast track eligibility
- do not assign final KDS station
- do not assign final cooking time

Unknown category must become review, not hallucination.

---

## 18. Category Prompt Constraint Boundary

AI prompt should constrain candidate categories.

For selected L1:

- provide only relevant L2 registry
- allow “Other/Review Required”
- allow multiple candidates with confidence
- require evidence reference
- require price parsing confidence
- prohibit unsupported categories
- require uncertainty marker

Prompt narrowing reduces hallucination and token cost.

---

## 19. Category Confidence Boundary

Each classified item should include:

- primary L2 candidate
- secondary L2 candidate
- confidence score
- source text
- source bounding box
- reason summary
- uncertainty marker
- human confirmed value
- reviewer id
- policy version

Low confidence must require review.

---

## 20. Category And Cooking Time Link

Category may prefill cooking time default.

Examples:

| L2 Category | Cooking Time Effect |
|---|---|
| Coffee | very short default |
| Beverage | short default |
| Kimbap | short assembly default |
| Salad/Poke | short-to-medium assembly default |
| Noodle | medium/hot cooking default |
| Soup/Stew | medium-to-long default |
| Fried dish | medium-to-long and station-dependent |
| Course/Buffet | not item-level fast track by default |
| Alcohol | no cooking time or age/legal rule |
| Option/Topping | component time or additive time |

Category default must remain editable and calibrated.

---

## 21. Category And Fast Track Link

Category may recommend fast track suitability.

Likely suitable candidates:

- kimbap
- protein cup
- salad/poke
- beverage
- prepacked dessert
- simple side
- some rice bowls

Needs review candidates:

- noodle
- hot soup
- fried items
- steak
- sushi/sashimi
- course menu
- buffet entry
- alcohol
- highly customized item

Unsuitable by default may still be enabled by policy if store proves operational readiness.

AI recommendation does not activate fast track.

---

## 22. Category And KDS Station Link

Category may recommend KDS station.

Examples:

| Category Type | Station Candidate |
|---|---|
| Kimbap | Kimbap station |
| Noodle | Noodle station |
| Beverage | Beverage station |
| Fried dish | Fry station |
| Sushi | Sushi/cold station |
| Salad/Poke | Bowl/salad station |
| Soup/Stew | Hot station |
| Dessert | Dessert/cafe station |
| Side | Side/packing station |

Station recommendation must be admin-confirmed.

Station affects KDS load and dynamic throttling.

---

## 23. Category And POS Mapping Link

Category may influence:

- POS item group
- tax class
- refund rule
- discount eligibility
- option group
- set/combo treatment
- inventory deduction
- reporting group
- franchise royalty category

POS mapping must not rely on AI category alone.

Human confirmation and integration validation are required.

---

## 24. Category And Customer Display Link

Category affects customer app display:

- menu sections
- search/filter
- icons
- recommendation grouping
- fast track badge
- sold-out grouping
- allergy notices
- seasonal labels
- ranking/analytics
- translation keys

Customer-facing category must be approved and localized.

---

## 25. Category Version Boundary

Taxonomy must be versioned.

Taxonomy version includes:

- L1 registry version
- L2 registry version
- category labels
- i18n keys
- default cooking time matrix
- default fast track suitability
- KDS station mapping
- POS group mapping
- category merge/split history
- deprecated categories
- approval reference
- audit reference

Menu item must record taxonomy version used at classification time.

---

## 26. Category Governance Boundary

Category changes require governance.

Governance applies to:

- new L1 category
- new L2 category
- category merge
- category split
- category deprecation
- mapping change
- default cooking time change
- fast track default change
- KDS station default change
- customer label change
- franchise template change

Category taxonomy is platform configuration.

It must not be edited casually per store without scope.

---

## 27. Store-Specific Category Override Boundary

A store may need local override.

Override fields:

- store id
- base category
- local display label
- local KDS station
- local cooking time default
- local fast track suitability
- reason
- expiration if temporary
- approval
- audit

Local override must not break franchise reporting unless mapped back to canonical category.

---

## 28. Franchise Template Boundary

Franchise HQ may define category templates.

Template may include:

- approved category tree
- menu display order
- category labels
- KDS station defaults
- prep time defaults
- fast track eligibility defaults
- option groups
- allergen tag expectations
- i18n keys
- analytics mapping

Store may inherit and override within policy.

---

## 29. Category Review UI Boundary

Category review UI should show:

- extracted menu name
- extracted price
- source image highlight
- AI category candidate
- confidence score
- alternate category candidates
- suggested cooking time
- suggested KDS station
- suggested fast track suitability
- admin dropdown
- “unknown/review” option
- bulk apply by category
- validation warnings

Review UI must make uncertainty obvious.

---

## 30. Bulk Classification Boundary

Bulk actions may include:

- assign category to selected items
- apply cooking time default
- apply KDS station
- disable fast track for category
- enable fast track candidates for review
- apply display order
- apply option group template

Bulk action must be previewed and auditable.

Bulk action must not silently affect financial or allergen fields.

---

## 31. Category Analytics Boundary

Category data may support analytics:

- sales by category
- preparation time by category
- Red/Yellow zone triggers by category
- no-show rate by category
- waste cost by category
- fast track success by category
- KDS bottleneck by category
- inventory consumption by category
- seasonal performance by category

Analytics must use approved deployed categories, not draft AI categories.

---

## 32. Category Security Boundary

Category classification must obey:

- tenant scope
- store scope
- upload file security
- AI source control
- no cross-tenant leakage
- no raw source exposure
- admin authority
- audit
- rollback
- taxonomy versioning

AI category prompt must not include another tenant’s private menu unless explicitly approved as aggregate/training data.

---

## 33. Category i18n Boundary

Every category label must have i18n key.

Example key pattern:

    menu.category.l1.korean_food
    menu.category.l2.korean_noodle
    menu.category.l2.japanese_sushi_sashimi
    menu.category.l2.cafe_non_coffee_drink

Missing category i18n key blocks customer-facing deployment.

Admin-only draft may show fallback label under review.

---

## 34. Category Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `CATEGORY_CONTEXT_SELECTED` | Admin selected L1 category |
| `CATEGORY_CONTEXT_CHANGED` | L1 context changed |
| `MENU_ITEM_CATEGORY_SUGGESTED` | AI suggested category |
| `MENU_ITEM_CATEGORY_LOW_CONFIDENCE` | Low confidence category |
| `MENU_ITEM_CATEGORY_CONFIRMED` | Human confirmed category |
| `MENU_ITEM_CATEGORY_CHANGED` | Human changed category |
| `CATEGORY_UNKNOWN_REVIEW_REQUIRED` | Unknown category review required |
| `CATEGORY_BULK_APPLIED` | Bulk category action applied |
| `CATEGORY_TAXONOMY_VERSION_CREATED` | New taxonomy version |
| `CATEGORY_MAPPING_CHANGED` | Mapping changed |
| `CATEGORY_I18N_MISSING` | Category translation missing |
| `CATEGORY_FASTTRACK_DEFAULT_APPLIED` | Fast track default applied |
| `CATEGORY_KDS_STATION_SUGGESTED` | KDS station suggested |
| `CATEGORY_COOKING_TIME_SUGGESTED` | Cooking time suggested |

Events must route through `10610`.

---

## 35. Relationship To AI Menu Intake

This document extends:

- AI parsing boundary
- structured menu draft boundary
- category classification boundary
- cooking time recommendation boundary
- fast track eligibility boundary
- KDS station routing boundary
- validation and deployment boundary

AI menu intake must request category context before parsing whenever possible.

---

## 36. Relationship To Fast Track

Category informs fast track but does not authorize it.

Fast track still requires:

- menu-specific eligibility
- cooking time approval
- freshness window
- packaging suitability
- KDS station readiness
- inventory reliability
- no-show waste risk review
- policy version
- manager/HQ approval where required

Category default is only a starting point.

---

## 37. Relationship To KDS Load

Category affects KDS load scoring.

Category may influence:

- station assignment
- prep time estimate
- complexity weight
- queue priority
- Red/Yellow zone threshold effect
- manual buffer recommendation
- bottleneck analytics

Wrong category can distort load control.

Therefore classification confidence matters operationally.

---

## 38. Anti-Patterns

Avoid:

- asking AI to classify against unlimited global food universe when store type is known
- deploying AI category without human review when confidence is low
- treating category as cosmetic only
- using category default cooking time as final truth
- enabling fast track automatically from category
- exposing draft category to customer app
- merging local store categories into platform taxonomy without governance
- using another tenant’s private menu as prompt example
- hardcoding categories in UI without versioning
- changing taxonomy without migration plan
- ignoring multi-concept stores
- treating alcohol category like ordinary food without legal policy
- treating buffet/course menu as item menu without review
- using analytics from draft categories as final business report

These anti-patterns must be blocked in future runtime design.

---

## 39. Runtime Deferral

This document defines AI menu category context and two-level taxonomy boundaries only.

It does not authorize:

- category registry implementation
- AI prompt implementation
- OCR/LLM implementation
- menu classification runtime
- category review UI
- taxonomy database schema
- KDS station mapping implementation
- cooking time default engine
- fast track default engine
- customer menu display implementation
- i18n implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 40. Validation Checklist

Validation must confirm:

1. Classification scope is defined.
2. Two-level taxonomy principle is defined.
3. Admin category selection flow is defined.
4. L1 business category registry is defined.
5. Korean Food L2 registry is defined.
6. Japanese Food L2 registry is defined.
7. Chinese Food L2 registry is defined.
8. Western/Asian Food L2 registry is defined.
9. Cafe/Dessert L2 registry is defined.
10. Fast Food/Chicken L2 registry is defined.
11. Pub/Bar L2 registry is defined.
12. Buffet/Course L2 registry is defined.
13. Health/Wellness L2 registry is defined.
14. Multi-concept store boundary is defined.
15. Unknown category review boundary is defined.
16. Category prompt constraint boundary is defined.
17. Category confidence boundary is defined.
18. Category and cooking time link is defined.
19. Category and fast track link is defined.
20. Category and KDS station link is defined.
21. Category and POS mapping link is defined.
22. Category and customer display link is defined.
23. Category version boundary is defined.
24. Category governance boundary is defined.
25. Store-specific category override boundary is defined.
26. Franchise template boundary is defined.
27. Category review UI boundary is defined.
28. Bulk classification boundary is defined.
29. Category analytics boundary is defined.
30. Category security boundary is defined.
31. Category i18n boundary is defined.
32. Category event catalog is defined.
33. Relationships to AI Menu Intake, Fast Track, and KDS Load are defined.
34. Anti-patterns are listed.
35. Coding remains unauthorized.
36. Runtime remains deferred.

---

## 41. Relationship To Previous Documents

This document supplements:

- `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`
- `10701 Five-Minute Smart Order Fast Track KDS Throttling No-Show Penalty And Abuse Control Boundary Policy`
- `10702 Fast Track Admin Console Control Tower KDS Load Penalty Governance And Store Operations Policy`
- `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`

It prepares possible future documents:

- `40006 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`
- `40007 Menu Validation Deployment Rollback And Versioning Policy`
- `40008 Menu POS KDS Inventory Mapping Governance Policy`
- `40009 Menu AI Parsing Evidence Audit And Human Review SOP`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 42. Final Rule

AI menu parsing must begin with store category context whenever possible.

The platform uses a two-level taxonomy: L1 business category and L2 menu category.

AI may recommend category, cooking time, KDS station, and fast track suitability from the selected taxonomy.

Human review remains mandatory for low-confidence, price-sensitive, allergen-sensitive, fast-track-sensitive, and customer-facing deployment decisions.

Category is not cosmetic.

Category affects KDS load, cooking time, fast track, POS mapping, inventory, analytics, customer display, i18n, and franchise reporting.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.