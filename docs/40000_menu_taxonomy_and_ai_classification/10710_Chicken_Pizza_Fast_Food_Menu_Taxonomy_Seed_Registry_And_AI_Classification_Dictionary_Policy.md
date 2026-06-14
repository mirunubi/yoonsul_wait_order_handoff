# 10710_Chicken_Pizza_Fast_Food_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary_Policy

## 1. Purpose

This document defines the Chicken, Pizza Chain, Burger, Fast Food, Side, Sauce, Drink, Combo, and Option-Heavy Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `10709 Western Asian Global Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded Western, Italian, American, brunch, Southeast Asian, Mexican, and global menu classification.

This document expands the `CHICKEN_PIZZA_FASTFOOD` category because this restaurant type has highly option-combinatorial menu structures:

- bone-in versus boneless chicken
- half-and-half chicken
- sauce and seasoning variants
- wing, drumstick, combo, and part-specific packs
- burger single versus set price
- lunch/set/pack menu structure
- pizza size options
- pizza crust options
- half-and-half pizza
- franchise signature names
- side bundle options
- dipping sauce and drink add-ons
- delivery-heavy packaging logic
- brand-specific naming conventions

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Chicken, pizza, and fast food menus require option-first parsing.

The correct rule is:

Franchise signature name must map to standard morphology.  
Single item and set price must be grouped under one menu when intended.  
Bone-in, boneless, wing, drumstick, and combo are item attributes or variants.  
Half-and-half chicken and half-and-half pizza are composition structures.  
Sauce and seasoning are option or flavor attributes.  
Pizza size and crust are option groups.  
Fast food packs are bundles, not unrelated menu items.  
Side and sauce add-ons must not be confused with main menu.  
AI may recommend classification, but human review remains mandatory for price, option, set, POS, delivery, fast track, and customer-facing deployment.  

This category has strong fast track potential but high option complexity.

---

## 3. Classification Scope

This registry applies to:

- chicken franchises
- independent chicken stores
- dakgangjeong stores
- pizza franchises
- burger chains
- fast food restaurants
- sandwich fast food stores
- delivery chicken/pizza stores
- combo/pack-heavy stores
- menu board OCR/AI parsing
- brand signature name normalization
- single/set price parsing
- bone/boneless option parsing
- half-and-half parsing
- pizza size/crust parsing
- sauce/dip parsing
- side/drink parsing
- POS/KDS mapping
- delivery layout
- fast track suitability review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Chicken/Pizza/Fast Food category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Chicken / Pizza / Fast Food | `CHICKEN_PIZZA_FASTFOOD` |
| `L2_MENU_CATEGORY` | Major family | Chicken |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Seasoned chicken |
| `ITEM_ATTRIBUTE` | Bone, boneless, sauce, size, set, crust | 순살, 반반, L, 치즈크러스트 |

Option attributes are mandatory in this category.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `FAST_CHICKEN` | Chicken / Dakgangjeong |
| `FAST_BURGER_SANDWICH` | Burger / Fast Sandwich |
| `FAST_PIZZA_CHAIN` | Pizza Chain |
| `FAST_SIDE` | Fast Food Sides |
| `FAST_SAUCE_DRINK` | Sauce / Dips / Drinks |
| `FAST_SET_PACK_COMBO` | Set / Pack / Combo |
| `FAST_NOTICE_OPTION_RULE` | Bone / Boneless / Size / Crust / Set Notice Rules |

Notice and option rules must be separated from menu items.

---

## 6. L2: Chicken / Dakgangjeong

L2 code:

    FAST_CHICKEN

This category includes fried chicken, roasted chicken, oven chicken, seasoned chicken, dakgangjeong, part-specific packs, boneless variants, and half-and-half menus.

---

## 7. L3: Fried / Basic / Roasted Chicken

L3 code:

    FAST_CHICKEN_FRIED_BASIC_ROASTED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 후라이드치킨 | Fried chicken |
| 프라이드치킨 | Fried chicken spelling variant |
| 크리스피치킨 | Crispy chicken |
| 핫크리스피 | Hot crispy chicken |
| 통닭 | Whole chicken |
| 옛날통닭 | Old-style whole chicken |
| 오븐구이치킨 | Oven-roasted chicken |
| 로스트치킨 | Roasted chicken |
| 베이크치킨 | Baked chicken |
| 파닭 | Scallion chicken |
| 오리엔탈파닭 | Oriental sauce scallion chicken |
| 양파치킨 | Onion chicken |
| 어니언치킨 | Onion chicken |
| 숯불치킨 | Charcoal chicken |
| 바베큐치킨 | BBQ chicken |
| 훈제치킨 | Smoked chicken |

AI notes:

- “파닭” and “양파치킨” are chicken with topping/sauce identity.
- Oven/roast/bake may route differently than fry station.
- Brand signature names should map to morphology if known.

---

## 8. L3: Seasoned / Sauce / Powder Chicken

L3 code:

    FAST_CHICKEN_SEASONED_SAUCE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 양념치킨 | Seasoned sweet-spicy chicken |
| 매운양념치킨 | Spicy seasoned chicken |
| 간장치킨 | Soy sauce chicken |
| 소유치킨 | Soy chicken |
| 마늘치킨 | Garlic chicken |
| 갈릭치킨 | Garlic chicken |
| 허니간장치킨 | Honey soy chicken |
| 시즈닝치킨 | Seasoning powder chicken |
| 치즈가루치킨 | Cheese powder chicken |
| 뿌링계열 | Cheese/seasoning powder brand-style family |
| 슈프림양념치킨 | Supreme seasoned chicken |
| 닭강정 | Dakgangjeong |
| 순살닭강정 | Boneless dakgangjeong |
| 매콤닭강정 | Spicy dakgangjeong |
| 불닭치킨 | Fire spicy chicken |
| 고추치킨 | Chili chicken |
| 핫치킨 | Hot chicken |
| 레드치킨 | Red spicy chicken |
| 블랙페퍼치킨 | Black pepper chicken |
| 허니버터치킨 | Honey butter chicken |
| 치즈볼케이노치킨 | Cheese/spicy marketing-style chicken |
| 스노윙치킨 | Snow seasoning chicken |
| 골드킹계열 | Honey/soy premium chicken family |
| 황금올리브계열 | Olive/fried signature family |
| 뿌링클계열 | Powder/cheese seasoning signature family |

AI notes:

- Brand-specific product names should map to sauce/seasoning morphology without losing original display name.
- Sauce/seasoning may be flavor option or separate menu depending menu layout.
- Spicy level and powder/sauce type are attributes.

---

## 9. L3: Chicken Part / Half-And-Half / Boneless

L3 code:

    FAST_CHICKEN_PART_HALF_BONELESS

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 반반치킨 | Half-and-half chicken |
| 후라이드+양념 | Fried + seasoned half |
| 윙봉세트 | Wing and drumette set |
| 윙봉 | Wing and drumette |
| 닭다리팩 | Drumstick pack |
| 콤보 | Combo pack |
| 닭날개팩 | Wing pack |
| 윙 | Wings |
| 봉 | Drumettes |
| 닭다리 | Drumsticks |
| 순살치킨 | Boneless chicken |
| 순살변경 | Boneless change option |
| 뼈치킨 | Bone-in chicken |
| 뼈 | Bone-in option |
| 반마리 | Half chicken |
| 한마리 | Whole chicken |
| 두마리 | Two chickens |
| 1마리 | One chicken |
| 2마리 | Two chickens |
| 세트반반 | Set half-and-half |
| 소스반반 | Sauce half-and-half |

AI notes:

- Bone/boneless is often option, not separate menu.
- Part packs may be separate SKU.
- Half-and-half requires component parsing.

---

## 10. L2: Burger / Fast Sandwich

L2 code:

    FAST_BURGER_SANDWICH

This category includes beef burgers, chicken burgers, shrimp/fish burgers, fast sandwiches, and set upgrade structures.

---

## 11. L3: Beef Patty Burger

L3 code:

    FAST_BURGER_BEEF

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 불고기버거 | Bulgogi burger |
| 치즈버거 | Cheeseburger |
| 더블치즈버거 | Double cheeseburger |
| 베이컨토마토디럭스 | Bacon tomato deluxe |
| 빅버거 | Big burger |
| 에그불고기버거 | Egg bulgogi burger |
| 수제스타일비프버거 | Handmade-style beef burger |
| 비프버거 | Beef burger |
| 클래식버거 | Classic burger |
| 데리버거 | Teriyaki-style burger |
| 한우버거 | Hanwoo burger |
| 트리플치즈버거 | Triple cheeseburger |
| 쿼터파운더계열 | Quarter-pounder style |
| 와퍼계열 | Flame-grilled large burger style |

AI notes:

- Brand-specific names should normalize to beef patty burger family when possible.
- Single versus set price must be grouped.

---

## 12. L3: Chicken / Shrimp / Fish Burger

L3 code:

    FAST_BURGER_CHICKEN_SEAFOOD

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 치킨버거 | Chicken burger |
| 휠레버거 | Filet chicken burger |
| 통다리살버거 | Whole thigh chicken burger |
| 싸이계열 | Chicken thigh signature family |
| 상하이버거 | Shanghai-style chicken burger |
| 타워버거 | Tower burger |
| 통새우버거 | Whole shrimp burger |
| 새우버거 | Shrimp burger |
| 생선까스버거 | Fish cutlet burger |
| 피쉬버거 | Fish burger |
| 치킨필렛버거 | Chicken filet burger |
| 핫치킨버거 | Hot chicken burger |
| 스파이시치킨버거 | Spicy chicken burger |
| 크리스피치킨버거 | Crispy chicken burger |

AI notes:

- “싸이버거” style names should map to chicken thigh burger morphology if brand mapping exists.
- Chicken burger may share fryer station with chicken sides.

---

## 13. L3: Burger Set / Pack Upgrade

L3 code:

    FAST_BURGER_SET_PACK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 버거세트 | Burger set |
| 세트 | Set option |
| 단품 | Single item |
| 런치세트 | Lunch set |
| 맥런치계열 | Lunch set family |
| 올데이킹계열 | Value set family |
| 팩메뉴 | Pack menu |
| 2인팩 | Two-person pack |
| 패밀리팩 | Family pack |
| 커플팩 | Couple pack |
| 라지세트 | Large set |
| 세트업 | Set upgrade |
| 감자튀김+콜라 | Fries + cola component |
| 사이드변경 | Side change option |
| 음료변경 | Drink change option |

AI notes:

- `단품 4,600 / 세트 6,900` must be one parent menu with purchase type options.
- Set components must be structured, not free text only.

---

## 14. L2: Pizza Chain

L2 code:

    FAST_PIZZA_CHAIN

This category includes franchise-style pizza with size, dough, crust, topping, half-and-half, quarter pizza, and pizza-side sets.

---

## 15. L3: Meat / Seafood Topping Pizza

L3 code:

    FAST_PIZZA_MEAT_SEAFOOD

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 불고기피자 | Bulgogi pizza |
| 바베큐치킨피자 | BBQ chicken pizza |
| 스테이크피자 | Steak pizza |
| 페페로니피자 | Pepperoni pizza |
| 슈프림피자 | Supreme pizza |
| 콤비네이션피자 | Combination pizza |
| 쉬림프피자 | Shrimp pizza |
| 직화구이피자 | Flame-grilled topping pizza |
| 베이컨피자 | Bacon pizza |
| 핫치킨피자 | Hot chicken pizza |
| 풀드포크피자 | Pulled pork pizza |
| 씨푸드피자 | Seafood pizza |
| 갈릭스테이크피자 | Garlic steak pizza |
| 미트러버피자 | Meat lover pizza |

AI notes:

- Pizza size must be parsed separately.
- Meat/seafood toppings may affect price tier and inventory.

---

## 16. L3: Vegetable / Cheese / Potato Pizza

L3 code:

    FAST_PIZZA_VEGETABLE_CHEESE_POTATO

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 포테이토피자 | Potato pizza |
| 고구마피자 | Sweet potato pizza |
| 단호박피자 | Sweet pumpkin pizza |
| 치즈피자 | Cheese pizza |
| 고르곤졸라피자 | Gorgonzola pizza |
| 야채피자 | Vegetable pizza |
| 파인애플피자 | Pineapple pizza |
| 하와이안피자 | Hawaiian pizza |
| 콘치즈피자 | Corn cheese pizza |
| 트러플치즈피자 | Truffle cheese pizza |
| 마르게리타피자 | Margherita pizza |
| 리코타피자 | Ricotta pizza |

AI notes:

- Some pizza terms overlap with Western category.
- In franchise pizza context, size/crust options are key.

---

## 17. L3: Signature / Half / Quarter / Pizza Set

L3 code:

    FAST_PIZZA_SIGNATURE_HALF_SET

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 네가지맛피자 | Four-flavor pizza |
| 쿼터피자 | Quarter pizza |
| 반반피자 | Half-and-half pizza |
| 하프앤하프 | Half-and-half |
| 피자+오븐스파게티세트 | Pizza + oven spaghetti set |
| 피자세트 | Pizza set |
| 피낙세트 | Pizza + octopus/chicken fusion set |
| 패밀리세트 | Family set |
| 커플세트 | Couple set |
| 라지피자세트 | Large pizza set |
| 프리미엄피자 | Premium pizza |
| 시그니처피자 | Signature pizza |
| 인기반반 | Popular half-and-half |
| 1+1피자 | One plus one pizza |

AI notes:

- Half/quarter composition must be parsed.
- Set components must be structured.
- `1+1` is promotion/set logic, not ordinary item name only.

---

## 18. L2: Fast Food Sides

L2 code:

    FAST_SIDE

This category includes fries, fried sides, cheese sides, chicken sides, bakery sides, pasta sides, salads, and dessert sides.

---

## 19. L3: Potato / Fried Sides

L3 code:

    FAST_SIDE_POTATO_FRIED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 감자튀김 | French fries |
| 후렌치후라이 | French fries variant |
| 프렌치프라이 | French fries |
| 양념감자 | Seasoned fries |
| 쉐이크포테이토 | Shake potato |
| 웨지감자 | Potato wedges |
| 케이준감자 | Cajun fries |
| 해쉬브라운 | Hash brown |
| 어니언링 | Onion rings |
| 오징어링 | Squid rings |
| 김말이튀김 | Fried seaweed roll |
| 만두튀김 | Fried dumpling |
| 치즈감자 | Cheese fries |
| 칠리치즈프라이 | Chili cheese fries |

AI notes:

- Side size may have small/medium/large.
- Some sides can be set components.

---

## 20. L3: Cheese / Chicken Sides

L3 code:

    FAST_SIDE_CHEESE_CHICKEN

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 치즈스틱 | Cheese sticks |
| 고구마치즈스틱 | Sweet potato cheese sticks |
| 치즈볼 | Cheese balls |
| 크림치즈볼 | Cream cheese balls |
| 치킨텐더 | Chicken tenders |
| 치킨너겟 | Chicken nuggets |
| 버팔로윙 | Buffalo wings |
| 버팔로봉 | Buffalo drumettes |
| 팝콘치킨 | Popcorn chicken |
| 콜팝치킨 | Chicken cup with cola |
| 순살텐더 | Boneless tender |
| 핫윙 | Hot wings |
| 너겟킹계열 | Nugget family |
| 치킨랩 | Chicken wrap, side/light meal context |

AI notes:

- Chicken sides may overlap with chicken main.
- Piece count may be needed.

---

## 21. L3: Bakery / Pasta / Salad / Dessert Sides

L3 code:

    FAST_SIDE_BAKERY_PASTA_SALAD

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 치즈오븐스파게티 | Cheese oven spaghetti |
| 토마토오븐스파게티 | Tomato oven spaghetti |
| 미트오븐스파게티 | Meat oven spaghetti |
| 미트볼스파게티 | Meatball spaghetti |
| 콘샐러드 | Corn salad |
| 코울슬로 | Coleslaw |
| 비스킷 | Biscuit |
| 에그타르트 | Egg tart |
| 애플파이 | Apple pie |
| 갈릭브레드 | Garlic bread |
| 치즈빵 | Cheese bread |
| 초코파이 | Choco pie dessert |
| 아이스크림 | Ice cream |
| 선데이 | Sundae dessert |

AI notes:

- Pizza/chicken stores may use pasta as side, not Western main pasta.
- Dessert side may belong to fast food context.

---

## 22. L2: Sauce / Dips / Drinks

L2 code:

    FAST_SAUCE_DRINK

This category includes dipping sauces, pickles, chicken radish, carbonated drinks, shakes, juice, and fast food coffee.

---

## 23. L3: Sauce / Dips / Pickles

L3 code:

    FAST_SAUCE_DIP_PICKLE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 갈릭디핑소스 | Garlic dipping sauce |
| 양념치킨소스 | Seasoned chicken sauce |
| 머스타드소스 | Mustard sauce |
| 청양마요소스 | Cheongyang mayo sauce |
| 스리라차소스 | Sriracha sauce |
| 핫소스 | Hot sauce |
| 피클 | Pickles |
| 치킨무추가 | Extra chicken radish |
| 치킨무 | Chicken radish |
| 랜치소스 | Ranch sauce |
| 바베큐소스 | BBQ sauce |
| 칠리소스 | Chili sauce |
| 허니머스타드 | Honey mustard |
| 마요소스 | Mayo sauce |
| 치즈소스 | Cheese sauce |
| 뿌링소스계열 | Powder-seasoning dipping sauce family |
| 디핑소스 | Dipping sauce |

AI notes:

- Sauces are usually add-ons/options.
- Sauce should not become main menu unless sold as add-on item.

---

## 24. L3: Carbonated / Fast Food Drinks

L3 code:

    FAST_DRINK_CARBONATED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 콜라 | Cola |
| 펩시 | Pepsi |
| 코카콜라 | Coca-Cola |
| 제로콜라 | Zero cola |
| 사이다 | Cider/sprite |
| 칠성사이다 | Chilsung cider |
| 스프라이트 | Sprite |
| 제로사이다 | Zero cider |
| 환타 | Fanta |
| 웰치스 | Welch's |
| 쉐이크 | Shake |
| 밀크쉐이크 | Milk shake |
| 초코쉐이크 | Chocolate shake |
| 딸기쉐이크 | Strawberry shake |
| 오렌지주스 | Orange juice |
| 아메리카노 | Americano |
| 아이스아메리카노 | Iced Americano |
| 생수 | Water |
| 탄산수 | Sparkling water |

AI notes:

- Drink size and set substitution are options.
- Fast food coffee may remain drink category, not cafe category.

---

## 25. L2: Set / Pack / Combo

L2 code:

    FAST_SET_PACK_COMBO

This category captures meal bundles, family packs, combo packs, party packs, and promotion structures.

---

## 26. L3: Chicken Set / Pack

L3 code:

    FAST_SET_CHICKEN_PACK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 치킨세트 | Chicken set |
| 반반세트 | Half-and-half set |
| 두마리세트 | Two-chicken set |
| 순살세트 | Boneless set |
| 윙봉세트 | Wing/drumette set |
| 닭다리세트 | Drumstick set |
| 치킨팩 | Chicken pack |
| 패밀리팩 | Family pack |
| 커플팩 | Couple pack |
| 파티팩 | Party pack |
| 치킨+사이드세트 | Chicken + side set |
| 치킨+콜라세트 | Chicken + cola set |
| 치킨+피자세트 | Chicken + pizza set |
| 치킨+떡볶이세트 | Chicken + tteokbokki set, fusion/delivery context |

AI notes:

- Set components must be parsed.
- Set pricing and individual item pricing must not be mixed.

---

## 27. L3: Burger / Pizza / Fast Food Set

L3 code:

    FAST_SET_BURGER_PIZZA

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 버거세트 | Burger set |
| 런치세트 | Lunch set |
| 라지세트 | Large set |
| 올데이세트 | All-day set |
| 팩메뉴 | Pack menu |
| 2인팩 | Two-person pack |
| 패밀리팩 | Family pack |
| 피자세트 | Pizza set |
| 피자+사이드세트 | Pizza + side set |
| 피자+콜라세트 | Pizza + cola set |
| 피자+스파게티세트 | Pizza + spaghetti set |
| 하프앤하프세트 | Half-and-half set |
| 1+1세트 | One plus one set |
| 콤보세트 | Combo set |
| 세트업 | Set upgrade |

AI notes:

- “세트” often means purchase option, not separate product.
- Pack menus may have multiple SKUs/components.

---

## 28. L2: Bone / Boneless / Size / Crust / Set Notice Rules

L2 code:

    FAST_NOTICE_OPTION_RULE

This category is not a normal menu item category.

It captures options, notices, and modifiers.

---

## 29. L3: Chicken Option Rules

L3 code:

    FAST_NOTICE_CHICKEN_OPTION

Seed patterns:

| Pattern | Meaning |
|---|---|
| 뼈 | Bone-in option |
| 순살 | Boneless option |
| 순살변경 | Boneless change |
| 순살 변경 + | Boneless upcharge |
| 반반 | Half-and-half |
| 소스선택 | Sauce selection |
| 맛 선택 | Flavor selection |
| 2가지맛 | Two flavors |
| 3가지맛 | Three flavors |
| 맵기선택 | Spice selection |
| 매운맛 | Spicy |
| 보통맛 | Normal |
| 치킨무 추가 | Chicken radish add-on |
| 콜라 포함 | Cola included |
| 한마리 | One chicken |
| 반마리 | Half chicken |
| 두마리 | Two chickens |
| 윙 | Wing part |
| 봉 | Drumette part |
| 콤보 | Combo part pack |
| 닭다리 | Drumstick part |

AI notes:

- Option text must attach to chicken parent menu.
- Upcharge requires POS option mapping review.

---

## 30. L3: Pizza Option Rules

L3 code:

    FAST_NOTICE_PIZZA_OPTION

Seed patterns:

| Pattern | Meaning |
|---|---|
| M | Medium size |
| L | Large size |
| R | Regular size |
| F | Family size |
| 라지 | Large |
| 레귤러 | Regular |
| 미디엄 | Medium |
| 크러스트변경 | Crust change |
| 치즈크러스트 | Cheese crust |
| 고구마무스 | Sweet potato mousse |
| 골드크러스트 | Gold crust |
| 씬도우 | Thin dough |
| 오리지널도우 | Original dough |
| 팬피자 | Pan pizza |
| 치즈추가 | Extra cheese |
| 토핑추가 | Extra topping |
| 하프앤하프 | Half-and-half |
| 반반 | Half-and-half |
| 쿼터 | Quarter |
| 네가지맛 | Four flavors |
| 피클포함 | Pickle included |
| 핫소스포함 | Hot sauce included |

AI notes:

- Size and crust options must attach to pizza parent menu.
- Crust upcharge must not become standalone menu.

---

## 31. L3: Burger/Fast Food Set Option Rules

L3 code:

    FAST_NOTICE_BURGER_SET_OPTION

Seed patterns:

| Pattern | Meaning |
|---|---|
| 단품 | Single item |
| 세트 | Set |
| 라지세트 | Large set |
| 런치 | Lunch |
| 올데이 | All-day |
| 감자튀김 포함 | Fries included |
| 콜라 포함 | Cola included |
| 사이드 변경 | Side substitution |
| 음료 변경 | Drink substitution |
| 치즈추가 | Cheese add-on |
| 패티추가 | Patty add-on |
| 베이컨추가 | Bacon add-on |
| 에그추가 | Egg add-on |
| 세트업 | Set upgrade |
| + | Add-on/plus marker |

AI notes:

- `단품/세트` is often two price columns for one base item.
- Add-ons require option group mapping.

---

## 32. Single Versus Set Price Parsing Boundary

Parser must group single and set prices.

Example:

    싸이버거 4,600 / 세트 6,900

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 싸이버거 |
| purchase_option_1 | 단품 / 4600 |
| purchase_option_2 | 세트 / 6900 |

Do not create “세트” as unrelated menu.

---

## 33. Bone / Boneless Parsing Boundary

Parser must distinguish bone/boneless.

Example:

    양념치킨 19,000 / 순살 변경 +2,000

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 양념치킨 |
| base_variant | 뼈 or default |
| option | 순살변경 |
| option_price_delta | 2000 |

If the menu lists “순살양념치킨 21,000” as separate item, admin may choose variant-as-menu or option-as-variant.

---

## 34. Half-And-Half Parsing Boundary

Parser must structure half-and-half.

Example:

    반반치킨 후라이드+양념 20,000

Should parse as:

| Field | Value |
|---|---|
| menu_name | 반반치킨 |
| menu_type | half_half |
| component_1 | 후라이드치킨 |
| component_2 | 양념치킨 |
| price | 20000 |

Half-and-half is one order item with component attributes unless store defines otherwise.

---

## 35. Pizza Size And Crust Parsing Boundary

Parser must group pizza size and crust.

Example:

    포테이토피자 M 18,900 / L 21,900
    치즈크러스트 변경 +3,000

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 포테이토피자 |
| size_option_1 | M / 18900 |
| size_option_2 | L / 21900 |
| crust_option | 치즈크러스트 |
| crust_option_delta | 3000 |

Crust option is not standalone menu.

---

## 36. Franchise Signature Normalization Boundary

Brand-specific menu names may need morphology mapping.

Examples:

| Signature-Like Term | Standard Morphology Candidate |
|---|---|
| 뿌링클계열 | Powder/cheese seasoning chicken |
| 황금올리브계열 | Premium fried chicken |
| 싸이버거계열 | Chicken thigh burger |
| 상하이버거계열 | Spicy chicken burger |
| 와퍼계열 | Flame-grilled beef burger |
| 맥런치계열 | Lunch set |
| 올데이킹계열 | Value set |
| 스노윙계열 | Powder seasoning chicken |
| 골드킹계열 | Honey soy chicken |
| 슈프림계열 | Creamy seasoned chicken |

Original display name must be preserved.

Standard morphology supports search, analytics, and category matching.

---

## 37. Fast Food Menu Attribute Boundary

Menu items may include:

- base item
- flavor
- sauce
- seasoning
- bone/boneless
- part
- size
- set/single
- side choice
- drink choice
- crust
- topping
- half-and-half components
- pack components
- spice level
- brand signature alias
- delivery packaging
- fast track suitability
- KDS station
- POS option group
- inventory component

Attributes must be reviewed before live deployment.

---

## 38. Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Fried chicken whole | Review candidate depending prep time |
| Boneless chicken | Review candidate |
| Dakgangjeong | Strong review candidate |
| Chicken part packs | Review candidate |
| Burger single | Strong review candidate |
| Burger set | Strong review candidate |
| Pizza whole | Review candidate depending oven time |
| Pizza slice/prepared | Strong review candidate if available |
| Sides | Strong review candidate |
| Drinks | Strong candidate if non-alcohol |
| Sauce/dip | Add-on only |
| Large family pack | Review or disabled |
| Half-and-half custom | Review candidate |
| Alcohol if present | Disabled unless legal policy exists |

This category can support fast track well if prep time and option complexity are controlled.

---

## 39. KDS Station Candidate Matrix

Candidate station mapping:

| Category | KDS Station Candidate |
|---|---|
| Fried chicken | Fry station |
| Oven/roast chicken | Oven station |
| Sauce/seasoned chicken | Sauce/finishing station |
| Dakgangjeong | Fry/sauce station |
| Burger | Grill/assembly station |
| Sandwich/wrap | Assembly station |
| Pizza | Oven station |
| Sides fries | Fry station |
| Cheese/chicken sides | Fry station |
| Pasta side | Oven/hot station |
| Salad/coleslaw | Cold station |
| Sauce/dip | Packing/service station |
| Drinks | Beverage/service station |
| Set/pack | Assembly/packing station |

Store configuration must override defaults.

---

## 40. POS Mapping Boundary

Chicken/Pizza/Fast Food POS mapping must handle:

- base item
- single/set price
- size price
- bone/boneless upcharge
- half-and-half components
- flavor options
- sauce options
- crust options
- topping options
- side substitution
- drink substitution
- pack components
- promotion/1+1
- delivery fee
- coupon applicability
- refund/cancel rule
- inventory deduction
- tax category

POS mapping requires human verification.

AI must not finalize option price mapping.

---

## 41. Customer Display Boundary

Customer-facing fast food menu must distinguish:

- chicken
- burger/sandwich
- pizza
- sides
- sauces/dips
- drinks
- set/pack/combo
- single/set price
- bone/boneless
- pizza size
- crust option
- flavor option
- half-and-half option
- pack components
- promotion notices
- fast track availability if approved

Option-heavy display must be structured to avoid duplicate messy menu rows.

---

## 42. Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `display_name_original` | Original display |
| `standard_morphology` | Standard category-like morphology |
| `l1_category` | `CHICKEN_PIZZA_FASTFOOD` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `base_menu_name` | Parent menu if option |
| `flavor_candidate` | Sauce/seasoning |
| `bone_option` | Bone/boneless |
| `part_option` | Wing, drumstick, combo |
| `size_options` | Pizza/drink/side size |
| `set_options` | Single/set/pack |
| `half_half_components` | Components |
| `crust_options` | Pizza crust |
| `side_drink_components` | Set components |
| `price_candidate` | Numeric price |
| `option_price_candidates` | Option prices |
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
| `FASTFOOD_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `FRANCHISE_SIGNATURE_DETECTED` | Brand-style signature detected |
| `SINGLE_SET_PRICE_DETECTED` | Single/set price detected |
| `BONE_BONELESS_OPTION_DETECTED` | Bone/boneless option detected |
| `CHICKEN_HALF_HALF_DETECTED` | Half-and-half chicken detected |
| `PIZZA_SIZE_OPTION_DETECTED` | Pizza size detected |
| `PIZZA_CRUST_OPTION_DETECTED` | Crust option detected |
| `PIZZA_HALF_HALF_DETECTED` | Half-and-half pizza detected |
| `PACK_COMPONENT_DETECTED` | Pack component detected |
| `SAUCE_DIP_ADDON_DETECTED` | Sauce/dip add-on detected |
| `FASTFOOD_LOW_CONFIDENCE` | Low confidence |
| `FASTFOOD_REVIEW_REQUIRED` | Human review required |
| `FASTFOOD_CATEGORY_CONFIRMED` | Category confirmed |
| `FASTFOOD_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `FASTFOOD_FASTTRACK_REVIEW_REQUIRED` | Fast track review required |

Events must route through `10610`.

---

## 44. Dictionary Governance Boundary

Chicken/Pizza/Fast Food dictionary updates must be governed.

Update actions:

- add franchise-style signature term
- add flavor/sauce term
- add chicken part term
- add burger signature alias
- add pizza crust pattern
- add size pattern
- add set/pack pattern
- add half-and-half pattern
- add option price pattern
- change L2/L3 category
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
- franchise signature normalization
- single/set price parsing
- bone/boneless parsing
- half-and-half parsing
- pizza size/crust parsing
- sauce/dip parsing
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- KDS station recommendation
- fast track default guidance
- validation and deployment readiness

Chicken/Pizza/Fast Food classification output remains draft until approved.

---

## 46. Relationship To Fast Track

This category has strong fast track potential but must be option-controlled.

Fast track approval requires:

- prep time per item and option
- packaging suitability
- option complexity control
- KDS station readiness
- set/pack assembly time
- hot holding/freshness window
- customer arrival timing
- no-show waste risk
- policy version
- manager/HQ approval where required

Fast track should prefer menu items with stable prep time and controlled options.

---

## 47. Relationship To Delivery Operations

Chicken, pizza, and fast food menus are often delivery-heavy.

Delivery operation mapping may require:

- packaging type
- sauce separation
- drink separation
- side packing
- pizza box size
- chicken box size
- hot/cold separation
- rider handoff
- delivery time tolerance
- promotion pack handling
- coupon/app eligibility
- order batching
- cancellation/refund rules

Menu classification should support delivery layout and packaging logic.

---

## 48. Anti-Patterns

Avoid:

- creating separate menu rows for every single/set option when parent grouping is intended
- treating 순살변경 as standalone menu
- treating 치즈크러스트 변경 as standalone menu
- losing original franchise signature name during normalization
- treating 반반치킨 as two independent full chicken orders
- treating 반반피자 as two unrelated pizzas
- mixing side menu and set component without structure
- auto-enabling fast track for complex custom packs
- ignoring option price deltas
- treating sauces/dips as main menu
- using AI to finalize POS option price without review
- allowing AI to mutate dictionary automatically

These anti-patterns must be blocked in future runtime design.

---

## 49. Runtime Deferral

This document defines Chicken/Pizza/Fast Food menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- franchise signature runtime
- single/set parser
- bone/boneless parser
- pizza size/crust parser
- half-and-half parser
- AI classification runtime
- POS mapping runtime
- delivery integration
- customer display implementation
- KDS station mapping implementation
- fast track eligibility runtime
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
4. Chicken L2 is defined.
5. Fried/basic/roasted chicken L3 is defined.
6. Seasoned/sauce/powder chicken L3 is defined.
7. Chicken part/half/boneless L3 is defined.
8. Burger/fast sandwich L2 is defined.
9. Beef patty burger L3 is defined.
10. Chicken/shrimp/fish burger L3 is defined.
11. Burger set/pack upgrade L3 is defined.
12. Pizza chain L2 is defined.
13. Meat/seafood topping pizza L3 is defined.
14. Vegetable/cheese/potato pizza L3 is defined.
15. Signature/half/quarter/pizza set L3 is defined.
16. Fast food sides L2 is defined.
17. Potato/fried sides L3 is defined.
18. Cheese/chicken sides L3 is defined.
19. Bakery/pasta/salad/dessert sides L3 is defined.
20. Sauce/dips/drinks L2 is defined.
21. Sauce/dips/pickles L3 is defined.
22. Carbonated/fast food drinks L3 is defined.
23. Set/pack/combo L2 is defined.
24. Chicken set/pack L3 is defined.
25. Burger/pizza/fast food set L3 is defined.
26. Bone/boneless/size/crust/set notice rules L2 is defined.
27. Chicken option rules L3 is defined.
28. Pizza option rules L3 is defined.
29. Burger/fast food set option rules L3 is defined.
30. Single versus set price parsing boundary is defined.
31. Bone/boneless parsing boundary is defined.
32. Half-and-half parsing boundary is defined.
33. Pizza size and crust parsing boundary is defined.
34. Franchise signature normalization boundary is defined.
35. Menu attribute boundary is defined.
36. Fast track default guidance is defined.
37. KDS station candidate matrix is defined.
38. POS mapping boundary is defined.
39. Customer display boundary is defined.
40. Classification output format is defined.
41. Event catalog is defined.
42. Dictionary governance boundary is defined.
43. Relationships to AI Menu Intake, Fast Track, and Delivery Operations are defined.
44. Anti-patterns are listed.
45. Coding remains unauthorized.
46. Runtime remains deferred.

---

## 51. Relationship To Previous Documents

This document supplements:

- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10705 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10706 Korean Meat Grill BBQ Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10707 Japanese Seafood Sushi Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10708 Chinese Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10709 Western Asian Global Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10700 Security And Trust Foundation Index`
- `10701 Five-Minute Smart Order Fast Track KDS Throttling No-Show Penalty And Abuse Control Boundary Policy`
- `10703 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`

It prepares possible future documents:

- `10711 Bunsik Kimbap Tteokbokki Snack Menu Taxonomy Policy`
- `10712 Cafe Dessert Beverage Menu Taxonomy Policy`
- `10713 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 52. Final Rule

Chicken/Pizza/Fast Food menu classification must treat single/set price, bone/boneless, chicken part, sauce/flavor, half-and-half composition, pizza size, crust option, side/drink substitution, pack components, and franchise signature normalization as first-class parsing targets.

AI may match chicken, burger, pizza, side, sauce, drink, set, pack, option, and franchise-style signature patterns.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS option mapping, delivery packaging review, and rollback remain mandatory before deployment.

Fast track may be strong for this category only when option complexity, prep time, KDS station, and packaging are controlled.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.