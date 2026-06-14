# 10708_Chinese_Food_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary_Policy

## 1. Purpose

This document defines the Chinese Food Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `10707 Japanese Seafood Sushi Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded Japanese, sushi, sashimi, seafood, market-price, piece-count, omakase, and raw item classification.

This document expands the `CHINESE_FOOD` category as a specialized restaurant type because Chinese menus have distinct structures:

- noodle and rice meal categories
- fried dish and main dish categories
- small, medium, large size pricing
- half-and-half bowl menus
- combo/set menus
- delivery-heavy ordering patterns
- spicy Sichuan and mala menus
- gram-based mala pricing
- topping/add-on parsing
- seasonal items
- dish-size options
- side/dim sum categories
- high delivery throughput and packaging dependency

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Chinese food menus require specialized parsing beyond generic “중식” labels.

The correct rule is:

짜장 and 짬뽕 are meal noodles, not generic noodles.  
곱빼기 is an option, not a separate menu unless store defines it so.  
탕수육 소/중/대 is one parent menu with size options.  
짬짜면 is a half-and-half menu, not two separate orders by default.  
마라탕 100g당 pricing is weight-based pricing, not fixed menu price.  
마라 topping items must be parsed as add-ons or ingredient choices.  
Course/set menus must preserve bundle structure.  
AI may recommend classification, but human review remains mandatory for price, size, combo, gram-based, and customer-facing deployment.  

Chinese menu classification affects POS, KDS, delivery, packaging, option groups, inventory, fast track eligibility, analytics, and customer display.

---

## 3. Classification Scope

This registry applies to:

- Korean-style Chinese restaurants
- delivery Chinese restaurants
- premium Chinese restaurants
- Sichuan/Maratang restaurants
- mala hotpot/self-pick stores
- Chinese course restaurants
- dim sum restaurants
- Chinese pub/fusion restaurants
- menu board OCR/AI parsing
- size option parsing
- half-and-half menu parsing
- combo/set parsing
- gram-based mala pricing
- topping/add-on parsing
- POS/KDS mapping
- delivery menu layout
- fast track suitability review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Chinese Food category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Chinese Food | `CHINESE_FOOD` |
| `L2_MENU_CATEGORY` | Major family | Chinese Noodles |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Jjajang noodle |
| `ITEM_ATTRIBUTE` | Size, spicy, half-half, combo, gram price | 곱빼기, 소/중/대, 100g당 |

Item attributes are essential for Chinese menus.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `CHINESE_NOODLE` | Chinese Noodles |
| `CHINESE_RICE` | Chinese Rice Dishes |
| `CHINESE_FRIED_DISH` | Fried Dishes |
| `CHINESE_MAIN_DISH` | Stir-Fried / Braised / Premium Dishes |
| `CHINESE_DUMPLING_SIDE` | Dumplings / Dim Sum / Sides |
| `CHINESE_MALA_TRENDY` | Mala / Trendy Sichuan |
| `CHINESE_SET_COURSE` | Set / Combo / Course |
| `CHINESE_ALCOHOL_DRINK` | Alcohol / Drinks |
| `CHINESE_NOTICE_OPTION_RULE` | Size / Extra / Delivery / Notice Rules |

Notice and option rules must be separated from menu items.

---

## 6. L2: Chinese Noodles

L2 code:

    CHINESE_NOODLE

This category includes jjajang, jjamppong, Chinese udon, ulmyeon, giseumyeon, cold Chinese noodles, stir-fried noodles, and regional/trendy noodles.

---

## 7. L3: Jjajang Noodle Family

L3 code:

    CHINESE_NOODLE_JJAJANG

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 짜장면 | Jjajangmyeon |
| 자장면 | Alternative spelling |
| 간짜장 | Dry-style jjajang |
| 삼선짜장 | Three-delicacy jjajang |
| 유니짜장 | Minced pork jjajang |
| 쟁반짜장 | Platter jjajang |
| 해물쟁반짜장 | Seafood platter jjajang |
| 사천짜장 | Sichuan-style spicy jjajang |
| 고추짜장 | Chili jjajang |
| 고기짜장 | Meat jjajang |
| 유슬짜장 | Shredded ingredient jjajang |
| 옛날짜장 | Old-style jjajang |
| 불짜장 | Very spicy jjajang |
| 짜장곱빼기 | Large jjajang option-like item |
| 간짜장곱빼기 | Large gan-jjajang option-like item |

AI notes:

- “곱빼기” should usually be option attribute, not separate base menu.
- `쟁반짜장 2인` should parse person count.
- Jjajang and jajang spelling variants must normalize.

---

## 8. L3: Jjamppong Noodle Family

L3 code:

    CHINESE_NOODLE_JJAMPPONG

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 짬뽕 | Jjamppong |
| 삼선짬뽕 | Three-delicacy jjamppong |
| 해물짬뽕 | Seafood jjamppong |
| 차돌짬뽕 | Beef brisket jjamppong |
| 고기짬뽕 | Meat jjamppong |
| 고추짬뽕 | Chili jjamppong |
| 굴짬뽕 | Oyster jjamppong |
| 백짬뽕 | White jjamppong |
| 낙지짬뽕 | Octopus jjamppong |
| 전복짬뽕 | Abalone jjamppong |
| 불짬뽕 | Extra spicy jjamppong |
| 카레짬뽕 | Curry jjamppong |
| 짬뽕곱빼기 | Large jjamppong option-like item |
| 차돌해물짬뽕 | Beef brisket seafood jjamppong |
| 홍합짬뽕 | Mussel jjamppong |
| 냉짬뽕 | Cold jjamppong |
| 순두부짬뽕 | Soft tofu jjamppong |

AI notes:

- Seasonal terms such as 굴짬뽕 may require seasonal tag.
- Spicy level may be inferred but must not be final unless explicitly shown.
- Jjamppong rice variants belong to rice category.

---

## 9. L3: Other Chinese Noodles

L3 code:

    CHINESE_NOODLE_OTHER

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 우동 | Chinese-style udon |
| 중식우동 | Chinese udon |
| 울면 | Ulmyeon |
| 기스면 | Giseumyeon |
| 계란면 | Egg noodle |
| 중국식냉면 | Chinese cold noodles |
| 냉면 | Chinese cold noodle context |
| 볶음짬뽕 | Stir-fried jjamppong |
| 야끼우동 | Stir-fried udon, Daegu/Gyeongbuk style |
| 우육면 | Beef noodle soup |
| 탄탄면 | Dan dan noodles |
| 마라면 | Mala noodles |
| 해물우동 | Seafood Chinese udon |
| 사천탕면 | Sichuan noodle soup |
| 볶음면 | Stir-fried noodles |

AI notes:

- “우동” in Chinese category differs from Japanese udon.
- “탄탄면” may appear in Chinese, Japanese, or Asian context.
- L1 context must guide classification.

---

## 10. L2: Chinese Rice Dishes

L2 code:

    CHINESE_RICE

This category includes fried rice, jjajang rice, jjamppong rice, mapo tofu rice, japchae rice, and premium stir-fry rice bowls.

---

## 11. L3: Fried Rice Family

L3 code:

    CHINESE_RICE_FRIED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 볶음밥 | Fried rice |
| 짜장밥 | Jjajang rice |
| 삼선볶음밥 | Three-delicacy fried rice |
| 새우볶음밥 | Shrimp fried rice |
| 게살볶음밥 | Crab fried rice |
| 해물볶음밥 | Seafood fried rice |
| 야채볶음밥 | Vegetable fried rice |
| 고추잡채볶음밥 | Pepper japchae fried rice |
| 하이라이스 | Chinese-style hayashi rice context |
| 마파두부밥 | Mapo tofu rice |
| 계란볶음밥 | Egg fried rice |
| XO볶음밥 | XO fried rice |
| 잡채볶음밥 | Japchae fried rice |

AI notes:

- Fried rice often comes with jjajang sauce.
- Some menu boards display `볶음밥 곱빼기`; treat as option.

---

## 12. L3: Rice Bowl / Topping Rice

L3 code:

    CHINESE_RICE_TOPPING

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 잡채밥 | Japchae rice |
| 고추잡채밥 | Pepper japchae rice |
| 송이덮밥 | Mushroom rice bowl |
| 유산슬밥 | Yusanseul rice |
| 잡탕밥 | Mixed seafood rice |
| 해물덮밥 | Seafood rice bowl |
| 짬뽕밥 | Jjamppong rice |
| 차돌짬뽕밥 | Beef brisket jjamppong rice |
| 순두부짬뽕밥 | Soft tofu jjamppong rice |
| 마파밥 | Mapo rice |
| 오징어덮밥 | Squid rice bowl, context required |
| 제육덮밥 | May be Korean, context required |
| 군만두국 | Dumpling soup, may be side/meal |

AI notes:

- “밥” suffix may indicate rice conversion of noodle/soup.
- Some rice dishes overlap with Korean food; L1 context is important.

---

## 13. L2: Fried Dishes

L2 code:

    CHINESE_FRIED_DISH

This category includes tangsuyuk, guobaorou, fried chicken-style Chinese dishes, fried shrimp, and delivery-friendly fried dishes.

---

## 14. L3: Tangsuyuk Family

L3 code:

    CHINESE_FRIED_TANGSUYUK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 탕수육 | Sweet and sour pork |
| 찹쌀탕수육 | Glutinous rice tangsuyuk |
| 꿔바로우 | Guobaorou |
| 북경식탕수육 | Beijing-style tangsuyuk |
| 사천탕수육 | Sichuan tangsuyuk |
| 숙주탕수육 | Bean sprout tangsuyuk |
| 소고기탕수육 | Beef tangsuyuk |
| 미니탕수육 | Mini tangsuyuk |
| 1인탕수육 | Single-person tangsuyuk |
| 탕수육소 | Small tangsuyuk |
| 탕수육중 | Medium tangsuyuk |
| 탕수육대 | Large tangsuyuk |
| 탕수육 小 | Small size |
| 탕수육 中 | Medium size |
| 탕수육 大 | Large size |

AI notes:

- `소/중/대` must be size options under one parent menu.
- `1인탕수육` may be separate item depending store.
- Sauce on side may be option if shown.

---

## 15. L3: Fried Chicken / Processed Fried Dishes

L3 code:

    CHINESE_FRIED_CHICKEN_STYLE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 깐풍기 | Spicy garlic chicken |
| 유린기 | Yuringi |
| 라조기 | Laziji-style chicken |
| 라조육 | Spicy pork, may be main dish |
| 멘보샤 | Shrimp toast |
| 새우식빵튀김 | Shrimp toast alias |
| 향라닭날개 | Spicy aromatic chicken wings |
| 깐풍육 | Spicy garlic pork |
| 깐풍만두 | Spicy garlic dumplings |
| 깐풍새우 | Spicy garlic shrimp |
| 크림새우 | Cream shrimp, may be seafood dish |
| 칠리새우 | Chili shrimp, may be seafood dish |

AI notes:

- Some fried shrimp dishes may map to seafood main dish depending section.
- Size options commonly apply.

---

## 16. L2: Stir-Fried / Braised / Premium Dishes

L2 code:

    CHINESE_MAIN_DISH

This category includes shrimp dishes, seafood dishes, classic Chinese premium dishes, stir-fried dishes, braised pork, and banquet dishes.

---

## 17. L3: Shrimp Dishes

L3 code:

    CHINESE_MAIN_SHRIMP

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 칠리새우 | Chili shrimp |
| 깐쇼새우 | Chili shrimp alias |
| 크림새우 | Cream shrimp |
| 레몬새우 | Lemon shrimp |
| 깐풍새우 | Spicy garlic shrimp |
| 마요새우 | Mayo shrimp |
| 새우볶음 | Stir-fried shrimp |
| 새우튀김 | Fried shrimp, context required |
| 중새우칠리 | Medium shrimp chili |
| 대하요리 | Prawn dish |

AI notes:

- Shrimp dishes often have size options.
- Delivery packaging and sauce separation may be relevant.

---

## 18. L3: Classic Chinese Premium Dishes

L3 code:

    CHINESE_MAIN_CLASSIC_PREMIUM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 양장피 | Yangjangpi |
| 유산슬 | Yusanseul |
| 팔보채 | Palbochae |
| 전가복 | Jeongabok |
| 고추잡채 | Pepper japchae |
| 꽃빵 | Flower bun, may be included |
| 라조육 | Spicy pork |
| 동파육 | Dongpo pork |
| 오향장육 | Five-spice cold pork |
| 마라상궈 | Mala stir-fry, dish type |
| 전복송이볶음 | Abalone mushroom stir-fry |
| 누룽지탕 | Scorched rice soup |
| 해물누룽지탕 | Seafood scorched rice soup |
| 해삼탕 | Sea cucumber dish |
| 송이해삼 | Mushroom sea cucumber |
| 깐풍육 | Spicy garlic pork |
| 난자완스 | Lion’s head meatball |
| 어향동고 | Fish-fragrant mushroom |
| 마파두부 | Mapo tofu |
| 해물볶음 | Seafood stir-fry |
| 잡탕 | Mixed seafood dish |

AI notes:

- Premium dishes often use `소/중/대`.
- `마라상궈` may belong here or mala trendy category depending store.
- Course/banquet restaurants may have components.

---

## 19. L2: Dumplings / Dim Sum / Sides

L2 code:

    CHINESE_DUMPLING_SIDE

This category includes dumplings, dim sum, spring rolls, flower buns, and desserts.

---

## 20. L3: Dumplings / Dim Sum

L3 code:

    CHINESE_DUMPLING_DIMSUM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 군만두 | Fried dumplings |
| 물만두 | Boiled dumplings |
| 찐만두 | Steamed dumplings |
| 고기만두 | Meat dumplings |
| 김치만두 | Kimchi dumplings, Korean overlap |
| 샤오롱바오 | Xiaolongbao |
| 소롱포 | Xiaolongbao Korean variant |
| 하가우 | Har gow |
| 쇼마이 | Shumai |
| 춘권 | Spring rolls |
| 스프링롤 | Spring rolls |
| 왕만두 | Large dumpling |
| 새우딤섬 | Shrimp dim sum |
| 딤섬세트 | Dim sum set |

AI notes:

- Dumplings overlap with Korean and bunsik categories.
- In Chinese context, 군만두 is a common side.

---

## 21. L3: Dessert / Extras

L3 code:

    CHINESE_DESSERT_EXTRA

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 꽃빵튀김 | Fried flower bun |
| 연유꽃빵 | Flower bun with condensed milk |
| 꽃빵 | Steamed flower bun |
| 찐꽃빵 | Steamed flower bun |
| 고구마맛탕 | Candied sweet potato |
| 빠스 | Candied dessert |
| 빠스고구마 | Candied sweet potato |
| 빠스옥수수 | Candied corn |
| 빠스사과 | Candied apple |
| 연유 | Condensed milk |
| 단무지추가 | Pickled radish add-on |
| 양파추가 | Onion add-on |
| 춘장추가 | Chunjang add-on |

AI notes:

- Flower bun may be included with 고추잡채 or sold separately.
- Extras may not require KDS main station.

---

## 22. L2: Mala / Trendy Sichuan

L2 code:

    CHINESE_MALA_TRENDY

This category includes mala tang, mala xiangguo, mala ban, gram-based pricing, self-pick toppings, and add-ons.

---

## 23. L3: Mala Tang / Mala Xiangguo / Mala Ban

L3 code:

    CHINESE_MALA_BASE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 마라탕 | Mala tang |
| 마라탕 기본 | Mala tang base |
| 마라탕 100g당 | Mala tang per 100g |
| 마라샹궈 | Mala xiangguo |
| 마라샹궈 기본 | Mala xiangguo base |
| 마라샹궈 100g당 | Mala xiangguo per 100g |
| 마라반 | Mala ban |
| 마라면 | Mala noodles |
| 마라쌀국수 | Mala rice noodles |
| 마라전골 | Mala hotpot |
| 마라볶음 | Mala stir-fry |
| 마라닭날개 | Mala chicken wings |

AI notes:

- `100g당` indicates weight-based pricing.
- Base price and minimum weight may both appear.
- AI must not treat each ingredient as standalone fixed menu unless store sells it that way.

---

## 24. L3: Mala Toppings / Add-Ons

L3 code:

    CHINESE_MALA_TOPPING_ADDON

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소고기추가 | Beef add-on |
| 소고기 100g | Beef per 100g |
| 양고기추가 | Lamb add-on |
| 양고기 100g | Lamb per 100g |
| 꼬치류 | Skewers |
| 꼬치 개당 | Per skewer |
| 라면사리 | Ramen add-on |
| 분모자사리 | Fenhaozi add-on |
| 중국당면 | Wide glass noodles |
| 옥수수면 | Corn noodles |
| 푸주 | Dried bean curd |
| 건두부 | Tofu sheet |
| 두부피 | Tofu skin |
| 청경채 | Bok choy |
| 숙주 | Bean sprouts |
| 배추 | Cabbage |
| 버섯 | Mushroom |
| 목이버섯 | Wood ear mushroom |
| 완자 | Meatball/fishball |
| 어묵 | Fish cake |
| 소시지 | Sausage |
| 메추리알 | Quail egg |

AI notes:

- Toppings may be ingredient choices, not menu items.
- Ingredient list may be inventory/topping registry, not customer menu section.

---

## 25. L2: Set / Combo / Course

L2 code:

    CHINESE_SET_COURSE

This category includes half-and-half menus, one-person combo menus, dish sets, delivery sets, and Chinese course menus.

---

## 26. L3: Half-And-Half One-Bowl Menus

L3 code:

    CHINESE_HALF_HALF_MENU

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 짬짜면 | Jjamppong + jjajang half-and-half |
| 볶짜면 | Fried rice + jjajang half-and-half |
| 볶짬면 | Fried rice + jjamppong half-and-half |
| 탕짜면 | Tangsuyuk + jjajang half-and-half |
| 탕짬면 | Tangsuyuk + jjamppong half-and-half |
| 탕볶밥 | Tangsuyuk + fried rice |
| 짜짬면 | Jjajang + jjamppong alias |
| 짜볶밥 | Jjajang + fried rice |
| 짬볶밥 | Jjamppong + fried rice |
| 탕수육반반 | Tangsuyuk half-and-half, context required |
| 반반메뉴 | Half-and-half menu |

AI notes:

- These are single menu items with component tags.
- Do not create two independent paid menu items unless explicitly configured.

---

## 27. L3: Dish Set / Delivery Combo

L3 code:

    CHINESE_DISH_SET_DELIVERY_COMBO

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 탕수육+짜장2 세트 | Tangsuyuk + two jjajang set |
| 탕수육+짜장+짬뽕 세트 | Tangsuyuk + jjajang + jjamppong |
| 탕수육세트 | Tangsuyuk set |
| 1인탕수육세트 | Single-person tangsuyuk set |
| 미니요리세트 | Mini dish set |
| 커플세트 | Couple set |
| 가족세트 | Family set |
| A세트 | Set A |
| B세트 | Set B |
| C세트 | Set C |
| 짜장세트 | Jjajang set |
| 짬뽕세트 | Jjamppong set |
| 군만두서비스 | Free dumpling service notice |

AI notes:

- `+` indicates bundle components.
- `서비스` may be promotional notice, not paid item.
- Delivery platforms often require set component mapping.

---

## 28. L3: Chinese Course

L3 code:

    CHINESE_COURSE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 런치코스 | Lunch course |
| 디너코스 | Dinner course |
| 가족상차림 | Family table course |
| 코스요리 | Course meal |
| 매코스 | Course label |
| 난코스 | Course label |
| 국코스 | Course label |
| 죽코스 | Course label |
| A코스 | Course A |
| B코스 | Course B |
| C코스 | Course C |
| 연회코스 | Banquet course |
| 룸코스 | Room course |
| 단체코스 | Group course |

AI notes:

- Course components should not be treated as separate paid items unless explicitly priced.
- Reservation/group handling may apply.

---

## 29. L2: Alcohol / Drinks

L2 code:

    CHINESE_ALCOHOL_DRINK

Alcohol and drinks must be separated from food items.

---

## 30. L3: Chinese Alcohol / Drinks

L3 code:

    CHINESE_ALCOHOL_DRINK_ITEM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 고량주 | Kaoliang liquor |
| 연태고량주 | Yantai kaoliang |
| 공부가주 | Confucius liquor |
| 이과두주 | Erguotou |
| 죽엽청주 | Bamboo leaf liquor |
| 칭따오 | Tsingtao beer |
| 하얼빈맥주 | Harbin beer |
| 생맥주 | Draft beer |
| 병맥주 | Bottled beer |
| 소주 | Soju |
| 맥주 | Beer |
| 음료수 | Soft drink |
| 콜라 | Cola |
| 사이다 | Cider/sprite |
| 환타 | Fanta |
| 탄산수 | Sparkling water |
| 생수 | Water |

AI notes:

- Alcohol requires age/legal policy.
- Drink items generally do not route to kitchen KDS.

---

## 31. L2: Size / Extra / Delivery / Notice Rules

L2 code:

    CHINESE_NOTICE_OPTION_RULE

This category is not a normal menu item category.

It captures size options, extra serving, delivery notice, free service notice, spicy level, and gram-based notice.

---

## 32. L3: Size / Extra Option Rule

L3 code:

    CHINESE_NOTICE_SIZE_EXTRA_RULE

Seed patterns:

| Pattern | Meaning |
|---|---|
| 곱빼기 | Large portion option |
| 곱배기 | Large portion spelling variant |
| 면추가 | Noodle add-on |
| 밥추가 | Rice add-on |
| 소 | Small size |
| 小 | Small size |
| 중 | Medium size |
| 中 | Medium size |
| 대 | Large size |
| 大 | Large size |
| 특대 | Extra large |
| 특 | Special/extra |
| 1인 | Single-person |
| 2인 | Two-person |
| 3인 | Three-person |
| 100g당 | Per 100g |
| 최소주문 | Minimum order |
| 배달료 | Delivery fee |
| 서비스 | Free service |
| 군만두서비스 | Free dumpling service |
| 매운맛 | Spicy level |
| 순한맛 | Mild level |
| 보통맛 | Normal level |
| 아주매운맛 | Very spicy level |

AI notes:

- Size and option rules must attach to parent menu.
- Delivery fee and service text must not become menu items.

---

## 33. Size Option Parsing Boundary

Chinese parser must support size option grouping.

Example:

    탕수육 (小) 18,000 / (中) 24,000 / (大) 30,000

Should parse as one parent menu:

| Field | Value |
|---|---|
| parent_menu | 탕수육 |
| option_group | size |
| option_1 | 小 / 18000 |
| option_2 | 中 / 24000 |
| option_3 | 大 / 30000 |

Do not create three unrelated menu items unless store explicitly wants that structure.

---

## 34. Large Portion Parsing Boundary

Chinese parser must support `곱빼기`.

Example:

    짜장면 7,000 / 곱빼기 8,000

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 짜장면 |
| base_price | 7000 |
| option | 곱빼기 |
| option_price | 8000 or +1000 depending menu layout |

If unclear whether option price is total or add-on delta, require human review.

---

## 35. Half-And-Half Parsing Boundary

Chinese parser must structure half-and-half menus.

Example:

    짬짜면 9,000

Should parse as:

| Field | Value |
|---|---|
| menu_name | 짬짜면 |
| menu_type | half_half |
| component_1 | 짬뽕 |
| component_2 | 짜장 |
| price | 9000 |

Half-and-half menu is usually one order item with components.

---

## 36. Mala Gram-Based Pricing Boundary

Mala parser must support weight-based pricing.

Example:

    마라탕 100g당 1,900원

Should parse as:

| Field | Value |
|---|---|
| menu_name | 마라탕 |
| pricing_type | weight_based |
| unit_amount | 100 |
| unit | g |
| unit_price | 1900 |

Example:

    소고기추가 100g 3,000원

Should parse as:

| Field | Value |
|---|---|
| item_name | 소고기추가 |
| item_type | topping_addon |
| unit_amount | 100 |
| unit | g |
| price | 3000 |

Weight-based menu must not be treated as fixed-price menu.

---

## 37. Chinese Menu Attribute Boundary

Chinese menu items may include:

- noodle/rice/dish category
- spicy level
- seafood marker
- beef/pork/chicken/shrimp marker
- size option
- large portion option
- half-and-half components
- set components
- gram pricing
- topping/add-on flag
- delivery packaging flag
- wok/fry/noodle station
- fast track suitability
- preparation complexity
- sauce separation
- seasonal marker
- customer notice marker

Attributes must be reviewed before live deployment.

---

## 38. Chinese Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Jjajang | Review candidate |
| Jjamppong | Review or disabled depending packaging |
| Fried rice | Review candidate |
| Rice bowl | Review candidate |
| Tangsuyuk | Review candidate |
| Kkanpunggi/Yuringi | Review candidate |
| Premium dishes 소/중/대 | Usually disabled or review |
| Dumplings | Review candidate |
| Mala tang weight-based | Usually disabled for instant fast track |
| Mala toppings | Not standalone fast track |
| Half-and-half menu | Review candidate |
| Course menu | Disabled |
| Alcohol | Disabled unless legal policy exists |

Fast track eligibility must be item-specific.

---

## 39. Chinese KDS Station Candidate Matrix

Candidate station mapping:

| Category | KDS Station Candidate |
|---|---|
| Jjajang | Noodle/wok station |
| Jjamppong | Noodle/soup wok station |
| Other noodles | Noodle station |
| Fried rice | Wok/rice station |
| Rice topping dish | Wok/rice station |
| Tangsuyuk | Fry station |
| Fried chicken-style dish | Fry/wok station |
| Shrimp dish | Wok/fry station |
| Premium dish | Wok/premium station |
| Dumpling/dim sum | Steam/fry station |
| Mala tang | Mala/boil station |
| Mala xiangguo | Mala/wok station |
| Set/combo | Multi-station assembly |
| Drinks | Beverage/service station |

Store configuration must override defaults.

---

## 40. POS Mapping Boundary

Chinese POS mapping must handle:

- base menu
- size option
- large portion option
- half-and-half menu components
- set components
- course components
- gram-based mala pricing
- topping/add-on pricing
- delivery fee
- free service items
- spicy level option
- packaging option
- discount exclusion
- tax category
- refund/cancel rule
- inventory deduction

POS mapping requires human verification.

AI must not finalize price/option mapping.

---

## 41. Customer Display Boundary

Customer-facing Chinese menu must distinguish:

- noodles
- rice
- fried dishes
- premium dishes
- dumplings/sides
- mala
- set/combo
- course
- drinks/alcohol
- size options
- large portion options
- spicy options
- gram-based pricing
- delivery notice
- free service notice

Menu layout must avoid duplicating option rows as separate menus unless intended.

---

## 42. Chinese Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `l1_category` | `CHINESE_FOOD` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `base_menu_name` | Parent menu if option |
| `size_options` | 소/중/대 option list |
| `large_portion_option` | 곱빼기 option |
| `half_half_components` | Components if half-half |
| `set_components` | Set components |
| `pricing_type` | fixed, option, weight_based, course |
| `unit_amount` | 100 if 100g |
| `unit` | g/person/etc. |
| `price_candidate` | Numeric price if present |
| `spicy_level_candidate` | Spicy marker |
| `fasttrack_default_candidate` | Candidate suitability |
| `kds_station_candidate` | Station |
| `confidence` | Confidence |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output is draft until human confirmation.

---

## 43. Chinese Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `CHINESE_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `CHINESE_SIZE_OPTION_DETECTED` | Size option detected |
| `CHINESE_GOBBAEGI_OPTION_DETECTED` | Large portion option detected |
| `CHINESE_HALF_HALF_DETECTED` | Half-and-half menu detected |
| `CHINESE_SET_COMPONENT_DETECTED` | Set component detected |
| `CHINESE_MALA_WEIGHT_PRICE_DETECTED` | Mala weight pricing detected |
| `CHINESE_TOPPING_ADDON_DETECTED` | Add-on/topping detected |
| `CHINESE_SERVICE_NOTICE_DETECTED` | Free service notice detected |
| `CHINESE_LOW_CONFIDENCE` | Low confidence |
| `CHINESE_REVIEW_REQUIRED` | Human review required |
| `CHINESE_CATEGORY_CONFIRMED` | Category confirmed |
| `CHINESE_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `CHINESE_FASTTRACK_REVIEW_REQUIRED` | Fast track review required |

Events must route through `10610`.

---

## 44. Dictionary Governance Boundary

Chinese dictionary updates must be governed.

Update actions:

- add noodle term
- add rice term
- add dish term
- add mala ingredient/topping
- add size pattern
- add half-and-half pattern
- add regional menu alias
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
- size option parsing
- large portion parsing
- half-and-half parsing
- mala gram pricing parsing
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- KDS station recommendation
- fast track default guidance
- validation and deployment readiness

Chinese classification output remains draft until approved.

---

## 46. Relationship To Fast Track

Chinese category has moderate fast track potential.

Fast track approval requires:

- menu-specific cooking time
- packaging suitability
- heat/noodle quality tolerance
- sauce separation rule
- KDS station readiness
- option complexity review
- delivery/fast pickup workflow
- no-show waste risk
- policy version

Jjajang, fried rice, dumplings, and some fried dishes may be candidates.

Hot soups, gram-based mala, premium dishes, and course menus usually require stricter review or default disablement.

---

## 47. Relationship To Delivery Operations

Chinese restaurants are often delivery-heavy.

Delivery operation mapping may require:

- packaging type
- noodle separation
- sauce separation
- soup spill risk
- delivery fee notice
- free service rule
- minimum order amount
- delivery zone
- pickup readiness
- rider handoff
- delayed cooking strategy
- batch cooking strategy

Menu classification should support delivery layout and packaging logic.

---

## 48. Anti-Patterns

Avoid:

- treating 곱빼기 as separate menu when it is an option
- treating 소/중/대 as unrelated separate dishes
- treating 짬짜면 as two separate paid menu items
- treating `100g당` mala price as fixed menu price
- treating free 군만두 service as paid menu item
- auto-enabling fast track for all noodles
- storing course components as independent paid items without review
- mapping Chinese 우동 to Japanese udon when L1 is Chinese
- ignoring spicy level and sauce/packaging options
- using AI to finalize POS option price without review
- ignoring delivery notice text
- allowing AI to mutate dictionary automatically

These anti-patterns must be blocked in future runtime design.

---

## 49. Runtime Deferral

This document defines Chinese Food menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- size option parser
- large portion parser
- half-and-half parser
- mala gram pricing parser
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
4. Chinese Noodles L2 is defined.
5. Jjajang family L3 is defined.
6. Jjamppong family L3 is defined.
7. Other Chinese noodles L3 is defined.
8. Chinese Rice L2 is defined.
9. Fried rice family L3 is defined.
10. Rice bowl/topping rice L3 is defined.
11. Fried dishes L2 is defined.
12. Tangsuyuk family L3 is defined.
13. Fried chicken/processed fried dishes L3 is defined.
14. Stir-fried/braised/premium dishes L2 is defined.
15. Shrimp dishes L3 is defined.
16. Classic premium dishes L3 is defined.
17. Dumplings/dim sum/sides L2 is defined.
18. Dumplings/dim sum L3 is defined.
19. Dessert/extras L3 is defined.
20. Mala/trendy Sichuan L2 is defined.
21. Mala base L3 is defined.
22. Mala toppings/add-ons L3 is defined.
23. Set/combo/course L2 is defined.
24. Half-and-half menus L3 is defined.
25. Dish set/delivery combo L3 is defined.
26. Chinese course L3 is defined.
27. Alcohol/drinks L2 is defined.
28. Alcohol/drink item L3 is defined.
29. Notice/option rule L2 is defined.
30. Size/extra option rule L3 is defined.
31. Size option parsing boundary is defined.
32. Large portion parsing boundary is defined.
33. Half-and-half parsing boundary is defined.
34. Mala gram-based pricing boundary is defined.
35. Chinese menu attribute boundary is defined.
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

- `10709 Western Asian Food Menu Taxonomy Policy`
- `10710 Cafe Dessert Beverage Menu Taxonomy Policy`
- `10711 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 52. Final Rule

Chinese Food menu classification must treat size options, large-portion options, half-and-half menus, set components, course structures, delivery notices, mala gram-based pricing, and topping/add-on lists as first-class parsing targets.

AI may match Chinese noodles, rice dishes, fried dishes, premium dishes, dumplings, mala, sets, courses, alcohol, size options, and gram-based pricing patterns.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS option mapping, delivery packaging review, and rollback remain mandatory before deployment.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.