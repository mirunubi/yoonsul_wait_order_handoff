# 40013_Policy_Cafe_Dessert_Beverage_Bakery_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary

## 1. Purpose

This document defines the Cafe, Coffee, Tea, Non-Coffee Beverage, Smoothie, Frappe, Bakery, Dessert, Bingsu, Ice Cream, Set, and Add-On Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `40012 Bunsik Gimbap Tteokbokki Snack Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded bunsik menus with shorthand restoration, topping/sari binding, set parsing, group-order behavior, and fast track readiness.

This document expands the `CAFE_DESSERT_BEVERAGE` category because cafe and dessert stores have structured but option-heavy menu patterns:

- HOT / ICE temperature split
- Regular / Large size split
- decaf option
- bean/origin option
- espresso shot add-on
- syrup add-on
- milk change option
- whipped cream option
- topping option
- bakery and dessert item variants
- cake slice/whole cake distinction
- seasonal fruit beverage and bingsu menus
- cafe set menus
- high i18n/search synonym value
- strong fast track and pickup-order suitability

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Cafe/dessert menu parsing is highly structured but must be option-aware.

The correct rule is:

HOT and ICE are options, not separate menus by default.  
Regular and Large are size options, not unrelated menu items.  
Decaf and bean change are option attributes.  
Shot, syrup, milk, whipping, pearl, and topping changes are add-ons.  
Cake slice and whole cake are distinct sale units.  
Bakery flavor variants may be child variants or separate SKUs depending store policy.  
AI may recommend classification, but human review remains mandatory for price, option, allergen, set, POS, fast track, and customer-facing deployment.  

Cafe/dessert classification affects customer display, POS options, KDS/barista station, inventory, allergen, fast track, pickup timing, and i18n.

---

## 3. Classification Scope

This registry applies to:

- cafes
- coffee shops
- dessert cafes
- bakery cafes
- bakery stores
- patisseries
- bingsu shops
- ice cream/gelato stores
- juice/smoothie shops
- bubble tea shops
- brunch cafes
- takeout coffee stores
- franchise cafes
- independent specialty coffee stores
- menu board OCR/AI parsing
- HOT/ICE option parsing
- size option parsing
- decaf/bean option parsing
- milk/syrup/shot add-on parsing
- bakery/dessert variant parsing
- cake unit parsing
- set component parsing
- POS/KDS mapping
- fast track suitability review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Cafe/Dessert category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Cafe / Dessert / Beverage | `CAFE_DESSERT_BEVERAGE` |
| `L2_MENU_CATEGORY` | Major family | Coffee |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Milk-based coffee |
| `ITEM_ATTRIBUTE` | Temperature, size, decaf, syrup, milk, topping | ICE, L, 디카페인, 오트밀크 |

Option attributes are mandatory in this category.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `CAFE_COFFEE_ESPRESSO` | Coffee / Espresso |
| `CAFE_TEA` | Tea |
| `CAFE_NON_COFFEE_DRINK` | Non-Coffee / Latte / Juice |
| `CAFE_BLENDED_SMOOTHIE_FRAPPE` | Blended / Smoothie / Frappe |
| `CAFE_BAKERY_DESSERT` | Bakery / Dessert |
| `CAFE_BINGSU_ICECREAM` | Bingsu / Ice Cream |
| `CAFE_SET_EXTRA` | Set Menus / Add-On Options |
| `CAFE_NOTICE_OPTION_RULE` | Temperature / Size / Bean / Milk / Topping Notice Rules |

Notice and option rules must be separated from menu items.

---

## 6. L2: Coffee / Espresso

L2 code:

    CAFE_COFFEE_ESPRESSO

This category includes espresso, black coffee, milk-based coffee, signature cream coffee, cold brew, drip coffee, and decaf coffee.

---

## 7. L3: Black Coffee / Espresso

L3 code:

    CAFE_COFFEE_BLACK_ESPRESSO

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 에스프레소 | Espresso |
| Espresso | English synonym |
| 에스프레소 콘파냐 | Espresso con panna |
| 콘파냐 | Con panna |
| 에스프레소 마끼아또 | Espresso macchiato |
| 마끼아또 | Macchiato, context required |
| 아메리카노 | Americano |
| Americano | English synonym |
| 아이스 아메리카노 | Iced Americano |
| 아아 | Iced Americano abbreviation |
| 롱블랙 | Long black |
| Long Black | English synonym |
| 드립커피 | Drip coffee |
| 핸드드립 | Hand drip |
| 필터커피 | Filter coffee |
| 콜드브루 | Cold brew |
| Cold Brew | English synonym |
| 아이스 콜드브루 | Iced cold brew |
| 디카페인 아메리카노 | Decaf Americano |
| 디카페인 커피 | Decaf coffee |
| 오늘의커피 | Coffee of the day |
| 브루잉커피 | Brewed coffee |
| 더치커피 | Dutch coffee |

AI notes:

- HOT/ICE should be temperature options where shown.
- Decaf is usually an option or variant, depending menu layout.
- Bean/origin may be separate option in specialty coffee stores.

---

## 8. L3: White / Milk-Based Coffee

L3 code:

    CAFE_COFFEE_MILK_BASED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 카페라떼 | Cafe latte |
| Latte | English synonym |
| 카푸치노 | Cappuccino |
| Cappuccino | English synonym |
| 플랫화이트 | Flat white |
| Flat White | English synonym |
| 바닐라라떼 | Vanilla latte |
| 헤이즐넛라떼 | Hazelnut latte |
| 카페모카 | Cafe mocha |
| Mocha | English synonym |
| 카라멜마끼아또 | Caramel macchiato |
| Caramel Macchiato | English synonym |
| 돌체라떼 | Dolce latte |
| 연유라떼 | Condensed milk latte |
| 시나몬라떼 | Cinnamon latte |
| 오트라떼 | Oat latte |
| 소이라떼 | Soy latte |
| 연유카페라떼 | Condensed milk cafe latte |
| 카라멜라떼 | Caramel latte |
| 라떼 | Latte generic |

AI notes:

- Milk type and dairy allergen are important.
- Oat/soy milk may be option or standalone menu.
- HOT/ICE and size options must attach to parent menu.

---

## 9. L3: Signature / Cream Coffee

L3 code:

    CAFE_COFFEE_SIGNATURE_CREAM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 아인슈페너 | Einspanner |
| Einspanner | English/German synonym |
| 크림라떼 | Cream latte |
| 너츠크림라떼 | Nuts cream latte |
| 흑임자라떼 | Black sesame latte |
| 달고나커피 | Dalgona coffee |
| 아포가토 | Affogato |
| Affogato | English/Italian synonym |
| 에스프레소 토닉 | Espresso tonic |
| Espresso Tonic | English synonym |
| 크림아메리카노 | Cream Americano |
| 소금커피 | Salt cream coffee |
| 버터크림라떼 | Butter cream latte |
| 피넛크림라떼 | Peanut cream latte |
| 말차크림라떼 | Matcha cream latte |
| 바닐라크림콜드브루 | Vanilla cream cold brew |
| 콜드브루라떼 | Cold brew latte |

AI notes:

- Cream, nuts, sesame, peanut, dairy, and caffeine tags may be relevant.
- Signature drinks may be cafe-specific and need original display name preservation.

---

## 10. L2: Tea

L2 code:

    CAFE_TEA

This category includes leaf tea, herbal tea, traditional Korean tea, fruit preserve tea, blended tea, and tea latte.

---

## 11. L3: Original / Leaf Tea

L3 code:

    CAFE_TEA_LEAF_HERBAL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 녹차 | Green tea |
| 그린티 | Green tea |
| Green Tea | English synonym |
| 우롱차 | Oolong tea |
| 얼그레이 | Earl Grey |
| Earl Grey | English synonym |
| 잉글리시 브렉퍼스트 | English Breakfast |
| English Breakfast | English synonym |
| 페퍼민트 | Peppermint |
| Peppermint | English synonym |
| 캐모마일 | Chamomile |
| Chamomile | English synonym |
| 루이보스 | Rooibos |
| Rooibos | English synonym |
| 히비스커스 | Hibiscus |
| Hibiscus | English synonym |
| 자스민차 | Jasmine tea |
| Jasmine Tea | English synonym |
| 블랙티 | Black tea |
| 홍차 | Black tea |
| 민트티 | Mint tea |
| 허브티 | Herbal tea |

AI notes:

- Tea may be HOT/ICE option.
- Caffeine and non-caffeine markers may be useful.

---

## 12. L3: Korean Traditional / Fruit Preserve Tea

L3 code:

    CAFE_TEA_KOREAN_FRUIT_PRESERVE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 유자차 | Citron tea |
| 생강차 | Ginger tea |
| 대추차 | Jujube tea |
| 쌍화차 | Ssanghwa tea |
| 매실차 | Plum tea |
| 오미자차 | Omija tea |
| 모과차 | Quince tea |
| 꿀자몽차 | Honey grapefruit tea |
| 레몬차 | Lemon tea |
| 자몽차 | Grapefruit tea |
| 한라봉차 | Hallabong tea |
| 청귤차 | Green mandarin tea |
| 배도라지차 | Pear bellflower tea |
| 감귤차 | Tangerine tea |
| 수제청차 | Homemade fruit preserve tea |

AI notes:

- Fruit preserve tea may share syrup/청 inventory.
- Health-like claims must be reviewed.

---

## 13. L3: Blended Tea / Tea Latte

L3 code:

    CAFE_TEA_BLENDED_LATTE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 밀크티 | Milk tea |
| 로얄 밀크티 | Royal milk tea |
| Royal Milk Tea | English synonym |
| 타로밀크티 | Taro milk tea |
| 그린티라떼 | Green tea latte |
| 말차라떼 | Matcha latte |
| Matcha Latte | English synonym |
| 홍차라떼 | Black tea latte |
| 자몽허니블랙티 | Grapefruit honey black tea |
| 자허블 | Grapefruit honey black tea abbreviation |
| 유자민트티 | Citron mint tea |
| 레몬얼그레이티 | Lemon Earl Grey tea |
| 얼그레이밀크티 | Earl Grey milk tea |
| 흑당밀크티 | Brown sugar milk tea |
| 버블티 | Bubble tea |
| 타피오카밀크티 | Tapioca milk tea |
| 차이라떼 | Chai latte |
| Chai Latte | English synonym |

AI notes:

- Milk tea may have pearl/tapioca add-on.
- Tea latte includes dairy/milk alternative options.

---

## 14. L2: Non-Coffee / Latte / Juice

L2 code:

    CAFE_NON_COFFEE_DRINK

This category includes non-coffee lattes, fruit milk, fresh juice, ade, and seasonal drinks.

---

## 15. L3: Non-Coffee Latte

L3 code:

    CAFE_NON_COFFEE_LATTE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 초코라떼 | Chocolate latte |
| 리얼초코 | Real chocolate |
| 화이트초코라떼 | White chocolate latte |
| 고구마라떼 | Sweet potato latte |
| 밤라떼 | Chestnut latte |
| 곡물라떼 | Grain latte |
| 미숫가루라떼 | Misutgaru latte |
| 토피넛라떼 | Toffee nut latte |
| 딸기라떼 | Strawberry latte |
| 생딸기우유 | Fresh strawberry milk |
| 망고라떼 | Mango latte |
| 바나나라떼 | Banana latte |
| 블루베리라떼 | Blueberry latte |
| 흑임자라떼 | Black sesame latte |
| 쑥라떼 | Mugwort latte |
| 단호박라떼 | Sweet pumpkin latte |
| 민트초코라떼 | Mint chocolate latte |
| 제주말차라떼 | Jeju matcha latte |

AI notes:

- Many non-coffee lattes contain milk/dairy.
- Seasonal fruit milk should be flagged as seasonal if indicated.

---

## 16. L3: Fresh Juice / Ade

L3 code:

    CAFE_JUICE_ADE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 딸기주스 | Strawberry juice |
| 바나나주스 | Banana juice |
| 딸바주스 | Strawberry banana juice |
| 딸기바나나주스 | Strawberry banana juice |
| 키위주스 | Kiwi juice |
| 토마토주스 | Tomato juice |
| 망고주스 | Mango juice |
| 수박주스 | Watermelon juice |
| 레몬에이드 | Lemon ade |
| 자몽에이드 | Grapefruit ade |
| 청포도에이드 | Green grape ade |
| 블루레몬에이드 | Blue lemon ade |
| 패션후르츠에이드 | Passion fruit ade |
| 오렌지에이드 | Orange ade |
| 유자에이드 | Citron ade |
| 복숭아에이드 | Peach ade |
| 라임에이드 | Lime ade |
| 체리에이드 | Cherry ade |
| 오미자에이드 | Omija ade |
| 매실에이드 | Plum ade |

AI notes:

- Ade is usually ICE-only unless specified.
- Fruit drinks may be seasonal and inventory-sensitive.

---

## 17. L2: Blended / Smoothie / Frappe

L2 code:

    CAFE_BLENDED_SMOOTHIE_FRAPPE

This category includes smoothies, yogurt smoothies, frappes, blended drinks, milkshakes, and frozen drinks.

---

## 18. L3: Smoothie / Yogurt Smoothie

L3 code:

    CAFE_SMOOTHIE_YOGURT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 딸기스무디 | Strawberry smoothie |
| 망고스무디 | Mango smoothie |
| 블루베리스무디 | Blueberry smoothie |
| 플레인요거트스무디 | Plain yogurt smoothie |
| 딸기요거트스무디 | Strawberry yogurt smoothie |
| 블루베리요거트스무디 | Blueberry yogurt smoothie |
| 유자스무디 | Citron smoothie |
| 키위스무디 | Kiwi smoothie |
| 복숭아스무디 | Peach smoothie |
| 바나나스무디 | Banana smoothie |
| 망고요거트스무디 | Mango yogurt smoothie |
| 청포도스무디 | Green grape smoothie |
| 수박스무디 | Watermelon smoothie |
| 요거트스무디 | Yogurt smoothie |
| 그릭요거트스무디 | Greek yogurt smoothie |

AI notes:

- Smoothies are usually cold/frozen.
- Yogurt/dairy allergen should be suggested.

---

## 19. L3: Frappe / Blended / Shake

L3 code:

    CAFE_FRAPPE_BLENDED_SHAKE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 자바칩프라페 | Java chip frappe |
| 쿠키앤크림프라페 | Cookies and cream frappe |
| 녹차프라페 | Green tea frappe |
| 말차블렌디드 | Matcha blended |
| 민트초코프라페 | Mint chocolate frappe |
| 바닐라프라페 | Vanilla frappe |
| 커피프라페 | Coffee frappe |
| 밀크쉐이크 | Milkshake |
| 초코쉐이크 | Chocolate shake |
| 딸기쉐이크 | Strawberry shake |
| 바닐라쉐이크 | Vanilla shake |
| 카라멜프라페 | Caramel frappe |
| 모카프라페 | Mocha frappe |
| 플레인블렌디드 | Plain blended |
| 초코칩프라페 | Chocolate chip frappe |

AI notes:

- Frappe/blended drinks may have whip/topping options.
- Coffee frappe may contain caffeine.

---

## 20. L2: Bakery / Dessert

L2 code:

    CAFE_BAKERY_DESSERT

This category includes cakes, tarts, trendy bakery, baked sweets, cookies, macarons, bread, waffles, churros, and classic cafe desserts.

---

## 21. L3: Cake / Tart

L3 code:

    CAFE_CAKE_TART

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 치즈케이크 | Cheesecake |
| 티라미수 | Tiramisu |
| 초코무스케이크 | Chocolate mousse cake |
| 딸기생크림케이크 | Strawberry cream cake |
| 당근케이크 | Carrot cake |
| 레드벨벳케이크 | Red velvet cake |
| 고구마케이크 | Sweet potato cake |
| 에그타르트 | Egg tart |
| 호두타르트 | Walnut tart |
| 가토쇼콜라 | Gateau chocolat |
| 바스크치즈케이크 | Basque cheesecake |
| 말차케이크 | Matcha cake |
| 얼그레이케이크 | Earl Grey cake |
| 생크림케이크 | Cream cake |
| 조각케이크 | Cake slice |
| 홀케이크 | Whole cake |
| 미니케이크 | Mini cake |
| 타르트 | Tart |

AI notes:

- Slice and whole cake must be separate sale units or options.
- Cake may require reservation or stock count.

---

## 22. L3: Trendy Bakery / Baked Sweets

L3 code:

    CAFE_TRENDY_BAKERY_BAKED_SWEETS

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소금빵 | Salt bread |
| 시오빵 | Salt bread Japanese-style name |
| 크로플 | Croffle |
| 플레인크로플 | Plain croffle |
| 브라운치즈크로플 | Brown cheese croffle |
| 크로와상 | Croissant |
| 크루아상 | Croissant spelling variant |
| 스콘 | Scone |
| 플레인스콘 | Plain scone |
| 대파스콘 | Green onion scone |
| 초코스콘 | Chocolate scone |
| 휘낭시에 | Financier |
| 마들렌 | Madeleine |
| 까눌레 | Canele |
| 쿠키 | Cookie |
| 르뱅쿠키 | Levain cookie |
| 마카롱 | Macaron |
| 뚱카롱 | Fat macaron |
| 베이글 | Bagel |
| 크림치즈베이글 | Cream cheese bagel |
| 퀸아망 | Kouign-amann |
| 몽블랑 | Mont blanc pastry |
| 식빵 | Loaf bread |
| 치아바타 | Ciabatta |

AI notes:

- Flavor variants may be child SKUs or separate menu items.
- Bakery inventory is stock-count sensitive.

---

## 23. L3: Classic Dessert / Bread

L3 code:

    CAFE_CLASSIC_DESSERT_BREAD

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 허니버터브레드 | Honey butter bread |
| 갈릭치즈브레드 | Garlic cheese bread |
| 와플 | Waffle |
| 조각롤케이크 | Roll cake slice |
| 슈크림 | Cream puff |
| 대만샌드위치 | Taiwanese sandwich |
| 츄러스 | Churros |
| 브라우니 | Brownie |
| 파운드케이크 | Pound cake |
| 머핀 | Muffin |
| 프레첼 | Pretzel |
| 카스테라 | Castella |
| 도넛 | Donut |
| 찹쌀도넛 | Glutinous rice donut |
| 샌드위치 | Sandwich, cafe context |
| 토스트 | Toast, cafe context |

AI notes:

- Some bakery items overlap with brunch/fast food.
- Context determines display category.

---

## 24. L2: Bingsu / Ice Cream

L2 code:

    CAFE_BINGSU_ICECREAM

This category includes traditional bingsu, snowflake bingsu, fruit bingsu, premium bingsu, soft ice cream, ice cream, and gelato.

---

## 25. L3: Snowflake / Traditional Bingsu

L3 code:

    CAFE_BINGSU_TRADITIONAL_SNOW

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 팥빙수 | Red bean bingsu |
| 옛날빙수 | Old-style bingsu |
| 인절미빙수 | Injeolmi bingsu |
| 콩고물빙수 | Bean powder bingsu |
| 우유눈꽃빙수 | Milk snowflake bingsu |
| 눈꽃빙수 | Snowflake bingsu |
| 흑임자빙수 | Black sesame bingsu |
| 녹차팥빙수 | Green tea red bean bingsu |
| 밀크빙수 | Milk bingsu |
| 단팥빙수 | Sweet red bean bingsu |

AI notes:

- Bingsu is usually seasonal and size/share-option sensitive.
- Dairy and nut/sesame allergen candidates may apply.

---

## 26. L3: Fruit / Premium Bingsu

L3 code:

    CAFE_BINGSU_FRUIT_PREMIUM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 망고빙수 | Mango bingsu |
| 애플망고빙수 | Apple mango bingsu |
| 딸기빙수 | Strawberry bingsu |
| 블루베리빙수 | Blueberry bingsu |
| 초코빙수 | Chocolate bingsu |
| 오레오빙수 | Oreo bingsu |
| 녹차빙수 | Green tea bingsu |
| 실타래빙수 | Thread-like bingsu |
| 멜론빙수 | Melon bingsu |
| 수박빙수 | Watermelon bingsu |
| 복숭아빙수 | Peach bingsu |
| 티라미수빙수 | Tiramisu bingsu |
| 치즈빙수 | Cheese bingsu |
| 요거트빙수 | Yogurt bingsu |

AI notes:

- Fruit bingsu may be seasonal and market-price-like in some stores.
- Size/share count may be needed.

---

## 27. L3: Ice Cream / Gelato

L3 code:

    CAFE_ICECREAM_GELATO

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소프트아이스크림 | Soft ice cream |
| 바닐라아이스크림 | Vanilla ice cream |
| 초코아이스크림 | Chocolate ice cream |
| 딸기아이스크림 | Strawberry ice cream |
| 녹차아이스크림 | Green tea ice cream |
| 아포가토용 아이스크림 | Ice cream for affogato |
| 수제 젤라또 | Handmade gelato |
| 젤라또 | Gelato |
| 초코젤라또 | Chocolate gelato |
| 바닐라젤라또 | Vanilla gelato |
| 녹차젤라또 | Green tea gelato |
| 딸기젤라또 | Strawberry gelato |
| 컵아이스크림 | Cup ice cream |
| 콘아이스크림 | Cone ice cream |
| 아이스크림라떼 | Ice cream latte |

AI notes:

- Cup/cone/scoop count may be options.
- Frozen inventory and stock count may matter.

---

## 28. L2: Set Menus / Add-On Options

L2 code:

    CAFE_SET_EXTRA

This category includes beverage-dessert sets, brunch sets, morning sets, and add-on options.

---

## 29. L3: Cafe Set Menu

L3 code:

    CAFE_SET_MENU

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 아메리카노+조각케이크 세트 | Americano + cake slice set |
| 케이크세트 | Cake set |
| 샌드위치 세트 | Sandwich set |
| 모닝세트 | Morning set |
| 베이글+커피 | Bagel + coffee |
| 브런치세트 | Brunch set |
| 커피세트 | Coffee set |
| 디저트세트 | Dessert set |
| 쿠키세트 | Cookie set |
| 크로플세트 | Croffle set |
| 빙수세트 | Bingsu set |
| 2인세트 | Two-person set |
| 애프터눈티세트 | Afternoon tea set |

AI notes:

- Set components and choice options must be structured.
- Drink choice may be required in set.

---

## 30. L3: Espresso / Syrup / Milk / Topping Add-Ons

L3 code:

    CAFE_EXTRA_ADDON

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 샷추가 | Extra shot |
| 에스프레소샷추가 | Extra espresso shot |
| 시럽추가 | Syrup add-on |
| 바닐라시럽 | Vanilla syrup |
| 헤이즐넛시럽 | Hazelnut syrup |
| 카라멜시럽 | Caramel syrup |
| 휘핑크림 추가 | Whipped cream add-on |
| 휘핑추가 | Whip add-on |
| 디카페인 변경 | Decaf change |
| 디카페인 변경 +500 | Decaf upcharge |
| 두유 변경 | Soy milk change |
| 오트밀크 변경 | Oat milk change |
| 저지방우유 변경 | Low-fat milk change |
| 락토프리 변경 | Lactose-free milk change |
| 펄 추가 | Tapioca pearl add-on |
| 타피오카 추가 | Tapioca add-on |
| 젤리 추가 | Jelly add-on |
| 아이스크림 추가 | Ice cream add-on |
| 크림 추가 | Cream add-on |
| 초코칩 추가 | Chocolate chip add-on |

AI notes:

- Add-ons should bind to beverage parent items.
- Upcharge requires POS option review.
- Milk change affects allergen/dietary tags.

---

## 31. L2: Temperature / Size / Bean / Milk / Topping Notice Rules

L2 code:

    CAFE_NOTICE_OPTION_RULE

This category is not a normal menu item category.

It captures temperature, size, bean, caffeine, syrup, milk, topping, and set-choice notices.

---

## 32. L3: Cafe Option / Notice Patterns

L3 code:

    CAFE_NOTICE_OPTION_PATTERN

Seed patterns:

| Pattern | Meaning |
|---|---|
| HOT | Hot temperature option |
| Hot | Hot temperature option |
| ICE | Ice temperature option |
| Ice | Ice temperature option |
| Iced | Iced temperature option |
| 아이스 | Iced option |
| 따뜻한 | Hot option |
| R | Regular size |
| Regular | Regular size |
| L | Large size |
| Large | Large size |
| M | Medium size |
| Grande | Grande size |
| Tall | Tall size |
| Venti | Venti size |
| 디카페인 | Decaf option |
| Decaf | Decaf option |
| 원두변경 | Bean change |
| 산미 | Acidity marker |
| 고소한 | Nutty bean profile |
| 블렌드 | Blend |
| 싱글오리진 | Single origin |
| 샷추가 | Extra shot |
| 시럽추가 | Syrup add-on |
| 우유변경 | Milk change |
| 두유 | Soy milk |
| 오트 | Oat milk |
| 휘핑 | Whip |
| 펄 | Pearl |
| 덜달게 | Less sweet |
| 당도선택 | Sweetness option |
| 얼음적게 | Less ice |
| 얼음많이 | More ice |
| 포장 | Takeout |
| 매장 | Dine-in |
| 품절 | Sold out |
| 시즌 | Seasonal |

AI notes:

- Option text must attach to parent menu or option group.
- Some size names are brand-specific and must remain configurable.

---

## 33. HOT / ICE Price Parsing Boundary

Cafe parser must group HOT and ICE price under one parent menu.

Example:

    아메리카노 HOT 4,000 / ICE 4,500

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 아메리카노 |
| option_group | temperature |
| option_1 | HOT / 4000 |
| option_2 | ICE / 4500 |

Do not create unrelated “HOT 아메리카노” and “ICE 아메리카노” rows unless store explicitly wants separate display.

---

## 34. Size Price Parsing Boundary

Cafe parser must group size price under one parent menu.

Example:

    카페라떼 (R) 4,500 / (L) 5,000

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 카페라떼 |
| option_group | size |
| option_1 | R / 4500 |
| option_2 | L / 5000 |

If size and temperature both affect price, parser must create multi-option candidate and require review.

---

## 35. Decaf / Bean / Milk Option Boundary

Parser must distinguish:

- decaf change
- bean change
- espresso shot add-on
- syrup add-on
- milk change
- non-dairy milk
- whipped cream
- topping
- sweetness
- ice amount

These options must bind to eligible beverage categories.

They must not become standalone customer menu categories.

---

## 36. Bakery Unit Parsing Boundary

Bakery/dessert parser must distinguish:

- piece
- slice
- whole cake
- box
- set
- flavor
- size
- daily limited stock
- reservation-only
- seasonal item
- sold-out state

Example:

    치즈케이크 조각 6,500 / 홀 38,000

Should parse as one dessert family with unit options or two sale units depending store policy.

Human review is required.

---

## 37. Cafe Menu Attribute Boundary

Menu items may include:

- caffeine flag
- decaf availability
- temperature option
- size option
- bean option
- milk option
- syrup option
- topping option
- sweetness option
- ice amount option
- bakery unit
- cake reservation flag
- seasonal flag
- allergen candidates
- fast track suitability
- KDS/barista station
- POS option group
- inventory component
- i18n/search aliases

Attributes must be reviewed before live deployment.

---

## 38. Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Americano / black coffee | Strong candidate |
| Milk coffee | Strong candidate |
| Signature cream coffee | Review candidate |
| Leaf tea | Strong candidate |
| Fruit tea / preserve tea | Strong candidate |
| Non-coffee latte | Strong candidate |
| Juice / ade | Strong candidate |
| Smoothie / frappe | Review candidate |
| Bakery | Strong candidate if stock-ready |
| Cake slice | Strong candidate if stock-ready |
| Whole cake | Review or reservation flow |
| Bingsu | Review or disabled depending prep time |
| Ice cream / gelato | Strong candidate if packed safely |
| Sets | Review candidate |
| Add-ons | Add-on only |

Cafe/dessert is one of the strongest fast track categories if option complexity is controlled.

---

## 39. KDS / Barista Station Candidate Matrix

Candidate station mapping:

| Category | Station Candidate |
|---|---|
| Espresso / black coffee | Barista espresso station |
| Milk coffee | Barista milk station |
| Signature coffee | Barista signature station |
| Tea | Tea station |
| Non-coffee latte | Barista/beverage station |
| Juice / ade | Cold beverage station |
| Smoothie / frappe | Blender station |
| Bakery | Bakery/display pickup station |
| Cake | Dessert/display pickup station |
| Bingsu | Bingsu station |
| Ice cream / gelato | Frozen dessert station |
| Set menu | Assembly/packing station |
| Add-ons | Parent beverage station |

Store configuration must override defaults.

---

## 40. POS Mapping Boundary

Cafe/dessert POS mapping must handle:

- base menu
- HOT/ICE price
- size price
- decaf upcharge
- bean change
- shot add-on
- syrup add-on
- milk change
- topping add-on
- sweetness/ice options
- bakery unit
- cake reservation
- set components
- seasonal availability
- sold-out state
- coupon/loyalty eligibility
- tax category
- inventory deduction
- refund/cancel rule

POS mapping requires human verification.

AI must not finalize option price mapping.

---

## 41. Customer Display Boundary

Customer-facing cafe menu must distinguish:

- coffee
- tea
- non-coffee drinks
- smoothie/frappe
- bakery/dessert
- bingsu/ice cream
- sets
- add-ons
- temperature options
- size options
- decaf/bean/milk options
- seasonal items
- sold-out items
- caffeine/allergen notices if approved
- fast track availability if approved

Option-heavy display must remain readable.

---

## 42. Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `display_name_original` | Original display |
| `search_aliases` | Korean/English aliases |
| `l1_category` | `CAFE_DESSERT_BEVERAGE` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `temperature_options` | HOT/ICE |
| `size_options` | R/L/M/etc. |
| `decaf_available` | Decaf flag |
| `bean_options` | Bean/origin options |
| `milk_options` | Dairy/non-dairy options |
| `addon_options` | Shot/syrup/whip/pearl/topping |
| `bakery_unit_options` | Piece/slice/whole/box |
| `set_components` | Set components |
| `price_candidate` | Numeric price |
| `option_price_candidates` | Option prices |
| `allergen_candidates` | Dairy, egg, wheat, nuts, etc. |
| `caffeine_flag` | Caffeine candidate |
| `seasonal_candidate` | Seasonal flag |
| `fasttrack_default_candidate` | Candidate suitability |
| `kds_station_candidate` | Station |
| `confidence` | Confidence |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output is draft until human confirmation.

---

## 43. Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `CAFE_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `CAFE_HOT_ICE_OPTION_DETECTED` | HOT/ICE option detected |
| `CAFE_SIZE_OPTION_DETECTED` | Size option detected |
| `CAFE_DECAF_OPTION_DETECTED` | Decaf option detected |
| `CAFE_BEAN_OPTION_DETECTED` | Bean option detected |
| `CAFE_MILK_CHANGE_DETECTED` | Milk change detected |
| `CAFE_SHOT_SYRUP_ADDON_DETECTED` | Shot/syrup add-on detected |
| `CAFE_TOPPING_ADDON_DETECTED` | Topping add-on detected |
| `CAFE_BAKERY_UNIT_DETECTED` | Bakery unit detected |
| `CAFE_SET_COMPONENT_DETECTED` | Set component detected |
| `CAFE_SEASONAL_ITEM_DETECTED` | Seasonal item detected |
| `CAFE_LOW_CONFIDENCE` | Low confidence |
| `CAFE_REVIEW_REQUIRED` | Human review required |
| `CAFE_CATEGORY_CONFIRMED` | Category confirmed |
| `CAFE_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `CAFE_FASTTRACK_REVIEW_REQUIRED` | Fast track review required |

Events must route through `10610`.

---

## 44. Dictionary Governance Boundary

Cafe/dessert dictionary updates must be governed.

Update actions:

- add coffee term
- add tea term
- add non-coffee beverage term
- add smoothie/frappe term
- add bakery/dessert term
- add bingsu/ice cream term
- add HOT/ICE pattern
- add size pattern
- add bean/decaf/milk option pattern
- add topping/add-on pattern
- add cake unit pattern
- add seasonal term
- change L2/L3 category
- mark allergen/caffeine candidate
- mark fast track guidance
- mark POS mapping risk
- deprecate term

Dictionary update requires:

- reason
- reviewer
- taxonomy version
- audit
- rollback path

AI may suggest additions.

AI must not mutate dictionary automatically.

---

## 45. Relationship To AI Menu Intake

This document supports:

- business category context
- OCR/LLM extraction
- HOT/ICE parsing
- size parsing
- decaf/bean parsing
- milk/add-on parsing
- bakery unit parsing
- set component parsing
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- barista/KDS station recommendation
- fast track default guidance
- validation and deployment readiness

Cafe/dessert classification output remains draft until approved.

---

## 46. Relationship To Fast Track

Cafe/dessert is one of the strongest fast track categories.

Fast track approval requires:

- drink prep time
- bakery stock readiness
- option complexity control
- barista station readiness
- pickup shelf temperature handling
- cold/hot separation
- packaging suitability
- no-show waste risk
- seasonal stock control
- policy version
- manager/HQ approval where required

Drinks and ready-stock bakery items are strong candidates.

Bingsu, whole cakes, high-complexity blended items, and reservation items require review.

---

## 47. Relationship To Allergen, Caffeine, And Health Claims

Cafe/dessert menus frequently contain:

- caffeine
- dairy
- egg
- wheat/gluten
- nuts
- peanuts
- soy
- sesame
- fruit allergens
- chocolate
- alcohol in desserts if applicable
- sugar-free/low-calorie claims
- vegan/non-dairy claims
- decaf claims

AI may suggest allergen, caffeine, and dietary tags.

Human/QC review is required before customer-facing allergen, caffeine-sensitive, or health/diet claims are published.

---

## 48. Anti-Patterns

Avoid:

- treating HOT and ICE as unrelated menus when they are options
- treating R/L size as separate unrelated menus when parent grouping is intended
- treating 디카페인 변경 as standalone menu
- treating 샷추가 or 시럽추가 as customer menu tab
- storing option price without parent option group
- treating 조각케이크 and 홀케이크 as same sale unit without review
- auto-enabling fast track for bingsu without prep-time review
- ignoring dairy/egg/wheat/nut allergen candidates
- losing English/Korean synonym mapping for coffee and dessert terms
- hiding caffeine or decaf distinction where relevant
- using AI to finalize POS option price without review
- allowing AI to mutate dictionary automatically

These anti-patterns must be blocked in future runtime design.

---

## 49. Runtime Deferral

This document defines Cafe/Dessert/Beverage menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- HOT/ICE parser
- size parser
- decaf/bean option parser
- milk/add-on parser
- bakery unit parser
- AI classification runtime
- POS mapping runtime
- customer display implementation
- KDS/barista station mapping implementation
- fast track eligibility runtime
- allergen/caffeine claim runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 50. Validation Checklist

Validation must confirm:

1. Classification scope is defined.
2. Classification depth is defined.
3. L2 category overview is defined.
4. Coffee/Espresso L2 is defined.
5. Black/Espresso L3 is defined.
6. White/Milk-Based Coffee L3 is defined.
7. Signature/Cream Coffee L3 is defined.
8. Tea L2 is defined.
9. Original/Leaf Tea L3 is defined.
10. Korean Traditional/Fruit Preserve Tea L3 is defined.
11. Blended Tea/Tea Latte L3 is defined.
12. Non-Coffee/Latte/Juice L2 is defined.
13. Non-Coffee Latte L3 is defined.
14. Fresh Juice/Ade L3 is defined.
15. Blended/Smoothie/Frappe L2 is defined.
16. Smoothie/Yogurt L3 is defined.
17. Frappe/Blended/Shake L3 is defined.
18. Bakery/Dessert L2 is defined.
19. Cake/Tart L3 is defined.
20. Trendy Bakery/Baked Sweets L3 is defined.
21. Classic Dessert/Bread L3 is defined.
22. Bingsu/Ice Cream L2 is defined.
23. Traditional/Snow Bingsu L3 is defined.
24. Fruit/Premium Bingsu L3 is defined.
25. Ice Cream/Gelato L3 is defined.
26. Set/Add-On Options L2 is defined.
27. Cafe Set Menu L3 is defined.
28. Espresso/Syrup/Milk/Topping Add-Ons L3 is defined.
29. Temperature/Size/Bean/Milk/Topping Notice Rules L2 is defined.
30. Cafe option/notice patterns L3 is defined.
31. HOT/ICE price parsing boundary is defined.
32. Size price parsing boundary is defined.
33. Decaf/bean/milk option boundary is defined.
34. Bakery unit parsing boundary is defined.
35. Menu attribute boundary is defined.
36. Fast track default guidance is defined.
37. KDS/barista station candidate matrix is defined.
38. POS mapping boundary is defined.
39. Customer display boundary is defined.
40. Classification output format is defined.
41. Event catalog is defined.
42. Dictionary governance boundary is defined.
43. Relationships to AI Menu Intake, Fast Track, and Allergen/Caffeine/Health Claims are defined.
44. Anti-patterns are listed.
45. Coding remains unauthorized.
46. Runtime remains deferred.

---

## 51. Relationship To Previous Documents

This document supplements:

- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `40006 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40007 Korean Meat Grill BBQ Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40008 Japanese Seafood Sushi Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40009 Chinese Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40010 Western Asian Global Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40011 Chicken Pizza Fast Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40012 Bunsik Gimbap Tteokbokki Snack Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`
- `10701 Five-Minute Smart Order Fast Track KDS Throttling No-Show Penalty And Abuse Control Boundary Policy`
- `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`

It prepares possible future documents:

- `40014 Salad Healthy Food Poke Yogurt Menu Taxonomy Policy`
- `40015 Pub Bar Izakaya Alcohol Anju Menu Taxonomy Policy`
- `40016 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`
- `40017 Cafe Pickup Barista Station Fast Track SOP`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 52. Final Rule

Cafe/Dessert/Beverage menu classification must treat HOT/ICE, size, decaf, bean, shot, syrup, milk change, whipped cream, pearl/topping, bakery unit, cake slice/whole, seasonal item, and set composition as first-class parsing targets.

AI may match coffee, tea, non-coffee beverages, smoothies, frappes, bakery, dessert, bingsu, ice cream, set, add-on, and option patterns.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS option mapping, allergen/caffeine claim review, and rollback remain mandatory before deployment.

Cafe/dessert is a strong fast track category only when option complexity, barista station load, packaging, temperature handling, stock readiness, and pickup freshness are controlled.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.