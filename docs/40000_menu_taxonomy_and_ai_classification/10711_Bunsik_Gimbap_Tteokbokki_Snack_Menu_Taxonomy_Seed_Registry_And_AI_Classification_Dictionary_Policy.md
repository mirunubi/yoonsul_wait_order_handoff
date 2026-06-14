# 10711_Bunsik_Gimbap_Tteokbokki_Snack_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary_Policy

## 1. Purpose

This document defines the Bunsik, Gimbap, Tteokbokki, Fried Snack, Sundae, Fish Cake, Noodle, Snack-Shop Meal, Set, Topping, and Sari Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `10710 Chicken Pizza Fast Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded chicken, pizza, burger, fast food, side, sauce, drink, set, pack, and option-heavy menu classification.

This document expands the `BUNSIK_SNACK_FOOD` category because bunsik stores have unique high-throughput menu structures:

- many low-price items
- extremely fast turnover
- many gimbap variants
- tteokbokki base and fusion variants
- fried snack and sundae side structures
- ramen/noodle add-ons
- snack-shop meal overlap with Korean food
- set menus such as 떡튀순 and 김떡순
- topping/sari add-ons
- omitted repeated nouns in menu boards
- price-based add-on ambiguity
- high group-order frequency
- strong fast track potential

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Bunsik menu parsing requires context restoration and add-on separation.

The correct rule is:

Menu board shorthand must be restored using context.  
“참치” under a 김밥 section may mean 참치김밥.  
Tteokbokki toppings and sari are options, not standalone menu tabs by default.  
Low-price add-ons must be bound to parent menus when context indicates add-on behavior.  
Snack-shop 돈까스, 찌개, 덮밥, and 라면 must be classified under bunsik meal context when the store is a bunsik shop.  
Set menus such as 떡튀순 and 김떡순 must preserve components.  
AI may recommend classification, but human review remains mandatory for price, option, set, fast track, POS, and customer-facing deployment.  

Bunsik classification affects menu layout, KDS batching, fast track readiness, inventory, group order handling, and customer display.

---

## 3. Classification Scope

This registry applies to:

- gimbap restaurants
- tteokbokki shops
- bunsik restaurants
- snack bars
- school-zone snack shops
- franchise bunsik stores
- kimbap heaven-style broad-menu stores
- ramen snack shops
- fish cake/snack stores
- sundae/fried snack stores
- delivery bunsik stores
- menu board OCR/AI parsing
- shorthand restoration
- topping/sari parsing
- set component parsing
- POS/KDS mapping
- group order preparation
- fast track suitability review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Bunsik category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Bunsik / Snack Food | `BUNSIK_SNACK_FOOD` |
| `L2_MENU_CATEGORY` | Major family | Gimbap |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Protein gimbap |
| `ITEM_ATTRIBUTE` | Sari, topping, spice, set component, omitted suffix | 치즈추가, 라면사리, 참치 → 참치김밥 |

Context restoration is mandatory in this category.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `BUNSIK_GIMBAP` | Gimbap |
| `BUNSIK_TTEOKBOKKI` | Tteokbokki |
| `BUNSIK_FRIED_SUNDAE_SIDE` | Fried Snacks / Sundae / Sides |
| `BUNSIK_NOODLE` | Noodles |
| `BUNSIK_MEAL` | Snack Shop Meals |
| `BUNSIK_SET_TOPPING` | Set Menus / Toppings / Sari |
| `BUNSIK_DRINK` | Drinks |
| `BUNSIK_NOTICE_OPTION_RULE` | Spice / Topping / Sari / Group Order Notice Rules |

Notice and option rules must be separated from menu items.

---

## 6. L2: Gimbap

L2 code:

    BUNSIK_GIMBAP

This category includes classic gimbap, small gimbap, protein gimbap, meat-topping gimbap, spicy gimbap, pickled/seasoned gimbap, and wellness gimbap.

---

## 7. L3: Classic / Vegetable Gimbap

L3 code:

    BUNSIK_GIMBAP_CLASSIC_VEGETABLE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 원조김밥 | Original gimbap |
| 야채김밥 | Vegetable gimbap |
| 기본김밥 | Basic gimbap |
| 일반김밥 | Regular gimbap |
| 김밥 | Gimbap |
| 꼬마김밥 | Mini gimbap |
| 마약김밥 | Mini mustard-style gimbap |
| 충무김밥 | Chungmu gimbap |
| 석박지 | Usually component of Chungmu gimbap |
| 오징어무침 | Usually component of Chungmu gimbap |
| 미니김밥 | Mini gimbap |
| 한입김밥 | Bite-size gimbap |
| 왕김밥 | Large gimbap |
| 누드김밥 | Nude gimbap |
| 주먹김밥 | Rice-ball style, context required |

AI notes:

- If section header is “김밥류”, short items like “야채”, “기본”, “원조” may imply 김밥 suffix.
- 충무김밥 components must not become unrelated standalone menus unless separately priced.

---

## 8. L3: Protein / Meat Topping Gimbap

L3 code:

    BUNSIK_GIMBAP_PROTEIN_MEAT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 참치김밥 | Tuna gimbap |
| 참치마요김밥 | Tuna mayo gimbap |
| 치즈김밥 | Cheese gimbap |
| 햄김밥 | Ham gimbap |
| 계란말이김밥 | Rolled egg gimbap |
| 폭탄계란김밥 | Egg-heavy gimbap |
| 키토김밥 | Keto gimbap |
| 제육김밥 | Spicy pork gimbap |
| 불고기김밥 | Bulgogi gimbap |
| 돈까스김밥 | Donkatsu gimbap |
| 떡갈비김밥 | Tteokgalbi gimbap |
| 닭갈비김밥 | Dakgalbi gimbap |
| 스팸김밥 | Spam gimbap |
| 소고기김밥 | Beef gimbap |
| 크래미김밥 | Crab stick gimbap |
| 새우튀김김밥 | Shrimp tempura gimbap |
| 참치와사비김밥 | Tuna wasabi gimbap |
| 김치참치김밥 | Kimchi tuna gimbap |

AI notes:

- “참치”, “치즈”, “제육” under gimbap section should restore as full gimbap names.
- Protein/topping affects prep time, inventory, and fast track suitability.

---

## 9. L3: Spicy / Pickled / Wellness Gimbap

L3 code:

    BUNSIK_GIMBAP_SPICY_WELLNESS

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 매운고추김밥 | Spicy chili gimbap |
| 땡초김밥 | Cheongyang chili gimbap |
| 멸치고추김밥 | Anchovy chili gimbap |
| 진미채김밥 | Seasoned dried squid gimbap |
| 멸치김밥 | Anchovy gimbap |
| 샐러드김밥 | Salad gimbap |
| 묵은지김밥 | Aged kimchi gimbap |
| 웰빙야채김밥 | Wellness vegetable gimbap |
| 우엉김밥 | Burdock gimbap |
| 매운어묵김밥 | Spicy fish cake gimbap |
| 고추참치김밥 | Spicy tuna gimbap |
| 다이어트김밥 | Diet gimbap |
| 현미김밥 | Brown rice gimbap |
| 곤약김밥 | Konjac gimbap |
| 아보카도김밥 | Avocado gimbap |

AI notes:

- Wellness claims require review if customer-facing health claims are implied.
- Spicy marker should be an attribute.

---

## 10. L2: Tteokbokki

L2 code:

    BUNSIK_TTEOKBOKKI

This category includes basic tteokbokki, rice/wheat cake variants, broth tteokbokki, sauce variants, premium/fusion tteokbokki, rabokki, jjolbokki, and cheese/mala/rose variants.

---

## 11. L3: Basic / Sauce Tteokbokki

L3 code:

    BUNSIK_TTEOKBOKKI_BASIC_SAUCE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 떡볶이 | Tteokbokki |
| 쌀떡볶이 | Rice cake tteokbokki |
| 밀떡볶이 | Wheat cake tteokbokki |
| 옛날떡볶이 | Old-style tteokbokki |
| 시장떡볶이 | Market-style tteokbokki |
| 매운떡볶이 | Spicy tteokbokki |
| 국물떡볶이 | Broth tteokbokki |
| 짜장떡볶이 | Jjajang tteokbokki |
| 카레떡볶이 | Curry tteokbokki |
| 궁중떡볶이 | Royal soy tteokbokki |
| 즉석떡볶이 | Table-cooked tteokbokki |
| 부산떡볶이 | Busan-style tteokbokki |
| 신전식떡볶이 | Spicy franchise-style tteokbokki |
| 매콤달콤떡볶이 | Sweet-spicy tteokbokki |

AI notes:

- “즉석떡볶이” may be table-cooked and not default fast track.
- Rice cake type may be attribute if shown separately.

---

## 12. L3: Premium / Fusion Tteokbokki

L3 code:

    BUNSIK_TTEOKBOKKI_PREMIUM_FUSION

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 로제떡볶이 | Rose tteokbokki |
| 크림떡볶이 | Cream tteokbokki |
| 투움바떡볶이 | Toowoomba tteokbokki |
| 마라떡볶이 | Mala tteokbokki |
| 차돌박이떡볶이 | Beef brisket tteokbokki |
| 통오징어떡볶이 | Whole squid tteokbokki |
| 치즈떡볶이 | Cheese tteokbokki |
| 눈꽃치즈떡볶이 | Snow cheese tteokbokki |
| 라볶이 | Ramen tteokbokki |
| 쫄볶이 | Jjolmyeon tteokbokki |
| 분모자떡볶이 | Fenhaozi tteokbokki |
| 당면떡볶이 | Glass noodle tteokbokki |
| 짜장라볶이 | Jjajang rabokki |
| 카레라볶이 | Curry rabokki |
| 해물떡볶이 | Seafood tteokbokki |
| 닭갈비떡볶이 | Dakgalbi tteokbokki |
| 소세지떡볶이 | Sausage tteokbokki |

AI notes:

- Fusion variants often have sauce/base attributes and topping dependencies.
- Cheese may be menu variant or add-on depending context.

---

## 13. L2: Fried Snacks / Sundae / Sides

L2 code:

    BUNSIK_FRIED_SUNDAE_SIDE

This category includes fried snacks, sundae, fish cake, skewers, and classic bunsik sides.

---

## 14. L3: Assorted / Single Fried Snacks

L3 code:

    BUNSIK_FRIED_SNACK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 모듬튀김 | Assorted fried snacks |
| 모둠튀김 | Assorted fried snacks alias |
| 김말이튀김 | Fried seaweed roll |
| 오징어튀김 | Fried squid |
| 고구마튀김 | Fried sweet potato |
| 야채튀김 | Fried vegetable |
| 야끼만두 | Fried glass noodle dumpling |
| 당면만두 | Glass noodle dumpling |
| 고추튀김 | Fried chili |
| 새우튀김 | Fried shrimp |
| 쥐포튀김 | Fried filefish |
| 식빵튀김 | Fried bread |
| 소시지튀김 | Fried sausage |
| 팝콘만두 | Popcorn dumpling |
| 단호박튀김 | Fried pumpkin |
| 계란튀김 | Fried egg |
| 치즈스틱 | Cheese stick |
| 감자튀김 | Fries |
| 통김말이 | Large fried seaweed roll |

AI notes:

- Fried snacks may be sold individually or as set components.
- Piece count may matter if menu shows “3개”, “5개”.

---

## 15. L3: Sundae / Internal Parts

L3 code:

    BUNSIK_SUNDAE_INTERNALS

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 찰순대 | Glutinous sundae |
| 고기순대 | Meat sundae |
| 토종순대 | Traditional sundae |
| 순대만 | Sundae only |
| 순대 | Sundae |
| 순대+내장 | Sundae with internal parts |
| 간 | Liver |
| 허파 | Lung |
| 오소리감투 | Pork stomach |
| 내장만 | Internal parts only |
| 모듬순대 | Assorted sundae |
| 백순대 | White sundae |
| 아바이순대 | Abai sundae |
| 병천순대 | Byeongcheon sundae |
| 순대국 | Sundae soup, may map to meal/soup depending store |

AI notes:

- “간/허파/오소리감투” are components, not always standalone menu.
- Sundae may be sold by portion or set.

---

## 16. L3: Classic Bunsik Side

L3 code:

    BUNSIK_CLASSIC_SIDE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 꼬치어묵 | Skewered fish cake |
| 오뎅 | Fish cake |
| 물어묵 | Fish cake in broth |
| 매운어묵 | Spicy fish cake |
| 어묵탕 | Fish cake soup |
| 떡꼬치 | Rice cake skewer |
| 소떡소떡 | Sausage rice cake skewer |
| 피카츄돈까스 | Pikachu cutlet |
| 순살강정 | Boneless sweet-spicy chicken |
| 순대볶음 | Stir-fried sundae |
| 백순대볶음 | White stir-fried sundae |
| 납작만두 | Flat dumpling |
| 핫도그 | Korean corn dog |
| 감자핫도그 | Potato corn dog |
| 회오리감자 | Tornado potato |
| 계란빵 | Egg bread |
| 붕어빵 | Fish-shaped pastry, seasonal |
| 호떡 | Hotteok, seasonal |

AI notes:

- Some street-food items may be seasonal.
- “피카츄돈까스” should be mapped as bunsik side, not western cutlet.

---

## 17. L2: Noodles

L2 code:

    BUNSIK_NOODLE

This category includes ramen, jjajang ramen, spicy instant noodles, bunsik udon, guksu, and jjolmyeon.

---

## 18. L3: Ramen / Jjajang Ramen

L3 code:

    BUNSIK_RAMEN_JJAJANG_RAMEN

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 일반라면 | Regular ramen |
| 라면 | Ramen |
| 계란라면 | Egg ramen |
| 치즈라면 | Cheese ramen |
| 떡라면 | Rice cake ramen |
| 만두라면 | Dumpling ramen |
| 부대라면 | Budae ramen |
| 해물라면 | Seafood ramen |
| 짬뽕라면 | Jjamppong ramen |
| 땡초라면 | Spicy chili ramen |
| 짜파게티 | Jjapaghetti |
| 짜장라면 | Jjajang ramen |
| 불닭볶음면 | Spicy fire chicken noodles |
| 비빔면 | Bibim noodle instant style |
| 열라면 | Spicy instant ramen brand-style |
| 신라면 | Instant ramen brand-style |
| 라면사리 | Ramen add-on, not standalone if in toppings section |

AI notes:

- Brand-like instant ramen names may be used as menu names.
- `라면사리` is usually add-on, not base noodle.

---

## 19. L3: Udon / Guksu / Jjolmyeon

L3 code:

    BUNSIK_UDON_GUKSU_JJOLMYEON

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 분식우동 | Bunsik udon |
| 우동 | Udon in snack-shop context |
| 김치우동 | Kimchi udon |
| 어묵우동 | Fish cake udon |
| 잔치국수 | Banquet noodles |
| 비빔국수 | Spicy mixed noodles |
| 열무국수 | Young radish noodles |
| 쫄면 | Jjolmyeon |
| 비빔쫄면 | Spicy jjolmyeon |
| 냉쫄면 | Cold jjolmyeon |
| 물쫄면 | Broth jjolmyeon |
| 모밀 | Soba/memil context |
| 냉모밀 | Cold soba/memil |
| 칼국수 | Kalguksu, broad bunsik menu context |
| 수제비 | Sujebi, broad bunsik menu context |

AI notes:

- In bunsik stores, these are snack-shop noodles, not specialty noodle restaurant items.
- Hot/cold marker affects KDS station and packaging.

---

## 20. L2: Snack Shop Meals

L2 code:

    BUNSIK_MEAL

This category includes broad-meal items often sold at kimbap heaven-style bunsik stores.

---

## 21. L3: Donkatsu / Cutlet

L3 code:

    BUNSIK_MEAL_DONKATSU_CUTLET

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 등심돈까스 | Pork loin cutlet |
| 돈까스 | Donkatsu/cutlet in bunsik context |
| 치즈돈까스 | Cheese cutlet |
| 고구마돈까스 | Sweet potato cutlet |
| 왕돈까스 | Large cutlet |
| 피자돈까스 | Pizza cutlet |
| 생선까스 | Fish cutlet |
| 정식 | Mixed set, context required |
| 돈까스정식 | Donkatsu set |
| 생선까스정식 | Fish cutlet set |
| 함박정식 | Hamburg set |
| 돈생정식 | Donkatsu + fish cutlet set |
| 돈함정식 | Donkatsu + hamburg set |
| 수제비돈까스세트 | Sujebi + donkatsu set |

AI notes:

- In bunsik context, cutlet should not automatically map to Japanese katsu or western steak/cutlet.
- Set composition requires review.

---

## 22. L3: Fried Rice / Rice Bowl / Curry

L3 code:

    BUNSIK_MEAL_RICE_BOWL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 김치볶음밥 | Kimchi fried rice |
| 새우볶음밥 | Shrimp fried rice |
| 오징어덮밥 | Squid rice bowl |
| 제육덮밥 | Spicy pork rice bowl |
| 낙지덮밥 | Octopus rice bowl |
| 불고기덮밥 | Bulgogi rice bowl |
| 카레라이스 | Curry rice |
| 하이라이스 | Hayashi rice |
| 오므라이스 | Omelet rice |
| 참치마요덮밥 | Tuna mayo rice bowl |
| 치킨마요덮밥 | Chicken mayo rice bowl |
| 스팸마요덮밥 | Spam mayo rice bowl |
| 돈까스덮밥 | Cutlet rice bowl |
| 알밥 | Fish roe rice |
| 돌솥알밥 | Hot stone fish roe rice |

AI notes:

- These overlap with Korean, Chinese, Japanese, and Western categories.
- L1 bunsik context should keep them under snack-shop meals.

---

## 23. L3: Stew / Meal

L3 code:

    BUNSIK_MEAL_STEW

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 김치찌개 | Kimchi stew |
| 분식형김치찌개 | Snack-shop kimchi stew |
| 된장찌개 | Soybean paste stew |
| 순두부찌개 | Soft tofu stew |
| 부대찌개 | Army stew |
| 육개장 | Spicy beef soup |
| 뚝배기불고기 | Bulgogi hot pot |
| 뚝불 | Bulgogi hot pot abbreviation |
| 돌솥알밥 | Hot stone fish roe rice |
| 제육정식 | Spicy pork set |
| 불고기정식 | Bulgogi set |
| 고등어구이 | Grilled mackerel, broad-menu context |
| 갈비탕 | Short rib soup, broad-menu context |
| 비빔밥 | Bibimbap, broad-menu context |

AI notes:

- Broad bunsik restaurants often sell simplified Korean meals.
- Classification should preserve bunsik business context to avoid false specialty mapping.

---

## 24. L2: Set Menus / Toppings / Sari

L2 code:

    BUNSIK_SET_TOPPING

This category includes bunsik sets, tteokbokki toppings, noodle sari, cheese, eggs, fish cake, rice cake, and add-ons.

---

## 25. L3: Bunsik Set

L3 code:

    BUNSIK_SET_MENU

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 떡튀순세트 | Tteokbokki + fried snacks + sundae set |
| 떡튀순 | Tteok-fry-sundae set |
| 김떡순세트 | Gimbap + tteokbokki + sundae set |
| 김떡순 | Gimbap-tteok-sundae set |
| 1인세트 | Single-person set |
| 커플세트 | Couple set |
| 패밀리세트 | Family set |
| 모둠분식플래터 | Assorted bunsik platter |
| 모듬분식 | Assorted bunsik |
| 떡볶이세트 | Tteokbokki set |
| 김밥세트 | Gimbap set |
| 라면세트 | Ramen set |
| 튀김세트 | Fried snack set |
| 순대세트 | Sundae set |
| 학생세트 | Student set |
| 점심세트 | Lunch set |

AI notes:

- Set components must be preserved.
- Set menu must not create duplicate paid items unless configured.

---

## 26. L3: Topping / Sari / Add-On

L3 code:

    BUNSIK_TOPPING_SARI_ADDON

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 눈꽃치즈추가 | Snow cheese add-on |
| 치즈추가 | Cheese add-on |
| 삶은계란 | Boiled egg |
| 계란추가 | Egg add-on |
| 삶은계란 1알 | One boiled egg |
| 삶은계란 2알 | Two boiled eggs |
| 야끼만두사리 | Fried dumpling add-on |
| 라면사리 | Ramen add-on |
| 쫄면사리 | Jjolmyeon add-on |
| 중국당면사리 | Wide glass noodle add-on |
| 분모자사리 | Fenhaozi add-on |
| 당면사리 | Glass noodle add-on |
| 떡추가 | Extra rice cake |
| 어묵추가 | Extra fish cake |
| 비엔나추가 | Vienna sausage add-on |
| 소시지추가 | Sausage add-on |
| 햄추가 | Ham add-on |
| 튀김추가 | Fried snack add-on |
| 김말이추가 | Fried seaweed roll add-on |
| 만두추가 | Dumpling add-on |
| 매운맛추가 | Spice add-on |
| 볶음밥추가 | Fried rice add-on, instant tteokbokki context |
| 날치알추가 | Flying fish roe add-on |
| 모짜렐라추가 | Mozzarella add-on |

AI notes:

- Add-ons are usually not standalone menu tabs.
- Low price and “추가/사리” suffix are strong add-on signals.
- Parent menu binding must be reviewed if ambiguous.

---

## 27. L2: Drinks

L2 code:

    BUNSIK_DRINK

This category includes simple drinks sold in bunsik shops.

---

## 28. L3: Bunsik Drinks

L3 code:

    BUNSIK_DRINK_ITEM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 콜라 | Cola |
| 사이다 | Cider/sprite |
| 환타 | Fanta |
| 쿨피스 | Coolpis |
| 쥬시쿨 | Juicy Cool |
| 식혜 | Sikhye |
| 생수 | Water |
| 탄산수 | Sparkling water |
| 오렌지주스 | Orange juice |
| 아이스티 | Iced tea |
| 아메리카노 | Americano, broad-menu context |
| 캔음료 | Canned drink |
| 병음료 | Bottled drink |

AI notes:

- Drink items may be set components or standalone.
- No KDS hot station usually required.

---

## 29. L2: Spice / Topping / Sari / Group Order Notice Rules

L2 code:

    BUNSIK_NOTICE_OPTION_RULE

This category is not a normal menu item category.

It captures spice, topping, add-on, portion, and group-order notices.

---

## 30. L3: Bunsik Option / Notice Patterns

L3 code:

    BUNSIK_NOTICE_OPTION_PATTERN

Seed patterns:

| Pattern | Meaning |
|---|---|
| 매운맛 | Spicy option |
| 순한맛 | Mild option |
| 보통맛 | Normal spice |
| 1단계 | Spice level |
| 2단계 | Spice level |
| 3단계 | Spice level |
| 아주매운맛 | Very spicy |
| 치즈추가 | Cheese add-on |
| 계란추가 | Egg add-on |
| 사리추가 | Sari add-on |
| 라면사리 | Ramen add-on |
| 쫄면사리 | Jjolmyeon add-on |
| 당면사리 | Glass noodle add-on |
| 떡추가 | Rice cake add-on |
| 어묵추가 | Fish cake add-on |
| 곱빼기 | Large portion |
| 대盛 | Large serving variant |
| 1인분 | One serving |
| 2인분 | Two servings |
| 단체주문 | Group order |
| 예약주문 | Reservation order |
| 포장가능 | Takeout available |
| 배달가능 | Delivery available |
| 현금가 | Cash price |
| 카드가 | Card price |
| 품절 | Sold out |
| 준비중 | Preparing/unavailable |

AI notes:

- Notices and add-ons must be separated from menu items.
- Group-order notice may affect order policy, not menu item.

---

## 31. Shorthand Restoration Boundary

Bunsik parser must restore omitted common nouns using section context.

Example menu board:

    김밥류
    야채 3,500
    참치 4,500
    치즈 4,000
    제육 5,000

Should parse as:

| Raw Text | Restored Menu |
|---|---|
| 야채 | 야채김밥 |
| 참치 | 참치김밥 |
| 치즈 | 치즈김밥 |
| 제육 | 제육김밥 |

Context restoration must include confidence.

Low confidence requires review.

---

## 32. Add-On Price Filter Boundary

Low-price add-on detection may use price and suffix signals.

Candidate add-on signals:

- `추가`
- `사리`
- `1알`
- `2알`
- `개당`
- price far lower than main menu
- section header: 추가, 토핑, 사리
- position near bottom/right of menu board
- repeated parent items nearby
- item such as cheese, egg, ramen sari, fish cake

Price threshold may be store/category configurable.

A 3,000 KRW candidate threshold may be useful, but must not be hardcoded as universal truth.

---

## 33. Bunsik Set Component Parsing Boundary

Parser must preserve set components.

Example:

    떡튀순 세트 9,000

Should parse as:

| Field | Value |
|---|---|
| menu_name | 떡튀순 세트 |
| menu_type | set |
| component_1 | 떡볶이 |
| component_2 | 튀김 |
| component_3 | 순대 |
| price | 9000 |

Example:

    김떡순 세트

Should parse as gimbap + tteokbokki + sundae.

Set components must be editable.

---

## 34. Topping / Sari Binding Boundary

Parser must bind toppings to likely parent menu families.

Likely parent mapping:

| Add-On | Likely Parent |
|---|---|
| 라면사리 | 떡볶이, 라볶이, 부대라면 |
| 쫄면사리 | 떡볶이 |
| 중국당면사리 | 떡볶이, 마라떡볶이 |
| 분모자사리 | 떡볶이, 마라떡볶이 |
| 치즈추가 | 떡볶이, 라면, 김밥 depending context |
| 삶은계란 | 떡볶이, 라면 |
| 어묵추가 | 떡볶이, 어묵 |
| 떡추가 | 떡볶이 |
| 만두추가 | 떡볶이, 라면 |
| 김말이추가 | 떡볶이, 튀김 set |
| 볶음밥추가 | 즉석떡볶이 |

Binding must remain reviewable.

---

## 35. Bunsik Menu Attribute Boundary

Menu items may include:

- base family
- spice level
- rice cake type
- noodle/sari type
- topping/add-on flag
- set components
- group-order suitability
- prep speed
- batch preparation support
- hot/cold marker
- packaging type
- fast track suitability
- KDS station
- POS option group
- inventory component
- shorthand restoration source
- price confidence
- parent binding

Attributes must be reviewed before live deployment.

---

## 36. Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Classic gimbap | Strong candidate |
| Protein gimbap | Strong candidate if prep controlled |
| Wellness/keto gimbap | Review candidate |
| Basic tteokbokki | Strong review candidate |
| Fusion tteokbokki | Review candidate |
| Fried snacks | Strong candidate if prepped/batched |
| Sundae | Review candidate |
| Fish cake | Review candidate |
| Ramen/noodles | Review candidate |
| Jjolmyeon/cold noodles | Review candidate |
| Snack-shop meals | Review or disabled depending item |
| Sets | Strong candidate if components controlled |
| Toppings/sari | Add-on only |
| Drinks | Strong candidate |

Bunsik has strong fast track potential if batching and option complexity are controlled.

---

## 37. KDS Station Candidate Matrix

Candidate station mapping:

| Category | KDS Station Candidate |
|---|---|
| Gimbap | Gimbap/assembly station |
| Tteokbokki | Tteokbokki/hot station |
| Fried snacks | Fry station |
| Sundae | Sundae/steam/service station |
| Fish cake | Fish cake/hot broth station |
| Ramen | Ramen/noodle station |
| Udon/guksu/jjolmyeon | Noodle station |
| Donkatsu/cutlet | Fry station |
| Rice bowl/fried rice | Rice/hot station |
| Stew/meal | Hot station |
| Set menu | Assembly/packing station |
| Topping/sari | Parent station or packing station |
| Drinks | Beverage/service station |

Store configuration must override defaults.

---

## 38. POS Mapping Boundary

Bunsik POS mapping must handle:

- base menu
- restored menu name
- topping/add-on option
- sari option
- spice level
- set components
- individual item price
- combo price
- group order quantity
- batch order handling
- sold-out state
- packaging option
- discount/coupon eligibility
- refund/cancel rule
- inventory deduction
- tax category

POS mapping requires human verification.

AI must not finalize option price mapping.

---

## 39. Customer Display Boundary

Customer-facing bunsik menu must distinguish:

- gimbap
- tteokbokki
- fried snacks
- sundae
- fish cake
- noodles
- snack-shop meals
- sets
- toppings/sari
- drinks
- spice level
- add-ons
- group-order notice
- fast track availability if approved

Toppings and sari should generally appear under parent menus or add-on section, not as cluttered standalone tabs.

---

## 40. Group Order Boundary

Bunsik often supports group orders.

Group order controls may include:

- minimum advance time
- quantity threshold
- menu batching rule
- KDS grouping
- pickup time slot
- payment rule
- cancellation/no-show rule
- packaging count
- name labeling
- classroom/office delivery note
- receipt splitting
- bulk discount if policy allows

AI classification may mark group-order suitable items but must not create group-order policy automatically.

---

## 41. Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `restored_name` | Context-restored menu name |
| `normalized_name` | Normalized menu name |
| `l1_category` | `BUNSIK_SNACK_FOOD` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `is_shorthand_restored` | Whether suffix/name was restored |
| `parent_menu_candidate` | Parent menu for add-on |
| `add_on_flag` | Topping/sari/add-on flag |
| `set_components` | Components if set |
| `spice_level_candidate` | Spice level |
| `price_candidate` | Numeric price |
| `option_price_candidates` | Option prices |
| `fasttrack_default_candidate` | Candidate suitability |
| `kds_station_candidate` | Station |
| `group_order_candidate` | Group-order suitability |
| `confidence` | Confidence |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output is draft until human confirmation.

---

## 42. Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `BUNSIK_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `BUNSIK_SHORTHAND_RESTORED` | Omitted menu suffix restored |
| `BUNSIK_TOPPING_ADDON_DETECTED` | Topping/add-on detected |
| `BUNSIK_SARI_DETECTED` | Sari detected |
| `BUNSIK_SET_COMPONENT_DETECTED` | Set component detected |
| `BUNSIK_SPICE_OPTION_DETECTED` | Spice option detected |
| `BUNSIK_LOW_PRICE_ADDON_CANDIDATE` | Low-price add-on candidate detected |
| `BUNSIK_GROUP_ORDER_CANDIDATE` | Group-order suitability candidate |
| `BUNSIK_LOW_CONFIDENCE` | Low confidence |
| `BUNSIK_REVIEW_REQUIRED` | Human review required |
| `BUNSIK_CATEGORY_CONFIRMED` | Category confirmed |
| `BUNSIK_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `BUNSIK_FASTTRACK_REVIEW_REQUIRED` | Fast track review required |

Events must route through `10610`.

---

## 43. Dictionary Governance Boundary

Bunsik dictionary updates must be governed.

Update actions:

- add gimbap variant
- add tteokbokki variant
- add fried snack term
- add sundae/internal component
- add noodle term
- add snack-shop meal term
- add set abbreviation
- add topping/sari term
- add shorthand restoration pattern
- add group-order marker
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

## 44. Relationship To AI Menu Intake

This document supports:

- business category context
- OCR/LLM extraction
- shorthand restoration
- topping/sari detection
- low-price add-on detection
- set component parsing
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- KDS station recommendation
- fast track default guidance
- validation and deployment readiness

Bunsik classification output remains draft until approved.

---

## 45. Relationship To Fast Track

Bunsik is one of the strongest fast track candidate categories.

Fast track approval requires:

- item-level prep time
- batching capability
- packaging suitability
- option complexity control
- KDS station readiness
- pickup freshness window
- group order handling
- no-show waste risk
- policy version
- manager/HQ approval where required

Gimbap, fried snacks, selected tteokbokki, sets, and drinks may be strong candidates.

Complex meals, instant table-cooked items, and high-option items require review.

---

## 46. Relationship To 윤슬김밥 / Catch Menu

This category is strategically important for 윤슬김밥 and Catch Menu.

Relevant areas:

- gimbap variants
- wellness gimbap
- protein gimbap
- low-fume bunsik alternatives
- fast track pickup
- group orders
- KDS prep batching
- menu intake automation
- option/topping simplification
- customer-facing clear category tabs
- franchise-ready menu governance

Bunsik taxonomy may become one of the strongest default templates for 윤슬김밥-style operations.

---

## 47. Anti-Patterns

Avoid:

- treating “참치” under 김밥 section as standalone tuna menu without restoration
- treating 라면사리 as standalone ramen menu when in topping section
- treating 치즈추가 as standalone menu tab
- treating 떡튀순 components as independent paid menus without set structure
- mapping snack-shop 돈까스 to Japanese katsu by default
- mapping 분식우동 to Japanese udon by default
- auto-enabling fast track for every bunsik item without option complexity review
- hardcoding 3,000 KRW add-on threshold as universal truth
- ignoring group order behavior
- ignoring sold-out/prep batching constraints
- using AI to finalize POS option price without review
- allowing AI to mutate dictionary automatically

These anti-patterns must be blocked in future runtime design.

---

## 48. Runtime Deferral

This document defines Bunsik menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- shorthand restoration runtime
- topping/sari parser
- low-price add-on classifier
- set component parser
- AI classification runtime
- POS mapping runtime
- group-order runtime
- customer display implementation
- KDS station mapping implementation
- fast track eligibility runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 49. Validation Checklist

Validation must confirm:

1. Classification scope is defined.
2. Classification depth is defined.
3. L2 category overview is defined.
4. Gimbap L2 is defined.
5. Classic/vegetable gimbap L3 is defined.
6. Protein/meat topping gimbap L3 is defined.
7. Spicy/pickled/wellness gimbap L3 is defined.
8. Tteokbokki L2 is defined.
9. Basic/sauce tteokbokki L3 is defined.
10. Premium/fusion tteokbokki L3 is defined.
11. Fried snacks/sundae/sides L2 is defined.
12. Assorted/single fried snacks L3 is defined.
13. Sundae/internal parts L3 is defined.
14. Classic bunsik side L3 is defined.
15. Noodles L2 is defined.
16. Ramen/jjajang ramen L3 is defined.
17. Udon/guksu/jjolmyeon L3 is defined.
18. Snack shop meals L2 is defined.
19. Donkatsu/cutlet L3 is defined.
20. Fried rice/rice bowl/curry L3 is defined.
21. Stew/meal L3 is defined.
22. Set menus/toppings/sari L2 is defined.
23. Bunsik set menu L3 is defined.
24. Topping/sari/add-on L3 is defined.
25. Drinks L2 is defined.
26. Bunsik drinks L3 is defined.
27. Notice/option rules L2 is defined.
28. Option/notice patterns L3 is defined.
29. Shorthand restoration boundary is defined.
30. Add-on price filter boundary is defined.
31. Set component parsing boundary is defined.
32. Topping/sari binding boundary is defined.
33. Menu attribute boundary is defined.
34. Fast track default guidance is defined.
35. KDS station candidate matrix is defined.
36. POS mapping boundary is defined.
37. Customer display boundary is defined.
38. Group order boundary is defined.
39. Classification output format is defined.
40. Event catalog is defined.
41. Dictionary governance boundary is defined.
42. Relationships to AI Menu Intake, Fast Track, and 윤슬김밥/Catch Menu are defined.
43. Anti-patterns are listed.
44. Coding remains unauthorized.
45. Runtime remains deferred.

---

## 50. Relationship To Previous Documents

This document supplements:

- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10705 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10706 Korean Meat Grill BBQ Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10707 Japanese Seafood Sushi Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10708 Chinese Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10709 Western Asian Global Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10710 Chicken Pizza Fast Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

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

- `10712 Cafe Dessert Beverage Menu Taxonomy Policy`
- `10713 Pub Bar Izakaya Alcohol Anju Menu Taxonomy Policy`
- `10714 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`
- `10715 Group Order Menu Batching And Pickup SLA Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 51. Final Rule

Bunsik menu classification must treat shorthand restoration, gimbap variants, tteokbokki base/fusion variants, fried snacks, sundae components, ramen/noodle context, snack-shop meals, set components, toppings, sari, add-ons, and group-order behavior as first-class parsing targets.

AI may match bunsik menu terms, restore omitted suffixes, detect add-ons, bind sari to parent menus, recommend KDS station, suggest fast track suitability, and flag group-order candidates.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS option mapping, batching review, and rollback remain mandatory before deployment.

Bunsik is a strong fast track category only when batching, option complexity, packaging, freshness, and KDS station readiness are controlled.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.