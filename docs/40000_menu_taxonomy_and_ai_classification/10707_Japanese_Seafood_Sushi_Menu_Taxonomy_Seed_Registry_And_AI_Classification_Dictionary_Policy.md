# 10707_Japanese_Seafood_Sushi_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary_Policy

## 1. Purpose

This document defines the Japanese, Seafood, Sushi, Sashimi, Donburi, Katsu, Noodle, Hotpot, Course, and Market-Price Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `10706 Korean Meat Grill BBQ Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded the meat/grill category with gram unit, serving rule, first-order limit, set/refill, side meal, alcohol, POS, and inventory parsing boundaries.

This document expands the `JAPANESE_SEAFOOD_SUSHI` category as a specialized high-risk menu type because Japanese/seafood menus contain unique structures:

- piece count such as `2pc`, `10p`, `12pcs`
- sashimi size levels such as small, medium, large
- market-price values such as `시가`, `싯가`, `변동`, `문의`
- raw fish and seafood safety concerns
- sushi set composition
- omakase/course structures
- fish species names
- donburi/rice bowl overlap
- Japanese noodles and katsu overlap
- izakaya/hotpot side menu overlap
- premium tuna/aged sashimi terms
- higher payment amount and customer dispute risk

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Japanese and seafood menus require specialized parsing beyond generic Japanese category labels.

The correct rule is:

Sushi piece count is not price.  
Market price is not zero-price discount.  
Sashimi size is not quantity unless mapped.  
Raw seafood requires safety and freshness review.  
AI must distinguish sushi, sashimi, donburi, katsu, noodle, hotpot, set, course, and market-price notice.  
AI may recommend classification, but human review is required for price, market price, raw item, course, and customer-facing deployment.  
Market price must be stored as a price policy state, not as ordinary numeric price.  
Piece count, set count, and course composition must be structured separately.  

Japanese/seafood classification affects POS, KDS, freshness, inventory, fast track eligibility, customer display, and refund/no-show policy.

---

## 3. Classification Scope

This registry applies to:

- sushi restaurants
- casual sushi shops
- omakase restaurants
- sashimi restaurants
- live fish restaurants
- seafood restaurants
- Japanese donburi restaurants
- Japanese katsu restaurants
- ramen/udon/soba restaurants
- izakaya restaurants
- fusion Japanese restaurants
- Japanese seafood delivery menus
- menu board OCR/AI parsing
- piece-count parsing
- market-price parsing
- raw seafood classification
- POS/KDS mapping
- inventory/freshness mapping
- fast track suitability review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Japanese/Seafood category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Japanese / Seafood / Sushi | `JAPANESE_SEAFOOD_SUSHI` |
| `L2_MENU_CATEGORY` | Major family | Sushi |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Single-kind sushi |
| `ITEM_ATTRIBUTE` | Piece count, market price, raw, set, course | 10p, 시가, raw fish |

Item attributes are mandatory for sushi and seafood pricing.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `JAPANESE_SUSHI` | Sushi |
| `JAPANESE_SASHIMI_SEAFOOD` | Sashimi / Raw Fish / Seafood |
| `JAPANESE_KATSU_TEMPURA` | Katsu / Tempura |
| `JAPANESE_DONBURI_RICE` | Donburi / Curry / Rice |
| `JAPANESE_NOODLE` | Ramen / Udon / Soba |
| `JAPANESE_SOUP_NABE_BRAISE` | Soup / Nabe / Braised / Grilled Fish Head |
| `JAPANESE_SET_COURSE` | Set / Course / Omakase |
| `JAPANESE_IZAKAYA_SIDE` | Izakaya Side / Small Dish |
| `JAPANESE_ALCOHOL_DRINK` | Alcohol / Drinks |
| `JAPANESE_NOTICE_PRICE_RULE` | Piece Count / Market Price / Notice |

Notice/rule text must be separated from menu items.

---

## 6. L2: Sushi

L2 code:

    JAPANESE_SUSHI

This category includes assorted sushi sets, single-kind sushi, half-and-half sushi, gunkan, roll, maki, and hand roll.

---

## 7. L3: Assorted Sushi Set

L3 code:

    JAPANESE_SUSHI_ASSORTED_SET

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 모듬초밥 | Assorted sushi |
| 모둠초밥 | Assorted sushi alias |
| 특선초밥 | Special sushi |
| 스페셜초밥 | Special sushi |
| 런치초밥 | Lunch sushi |
| 점심특선초밥 | Lunch special sushi |
| VIP초밥 | VIP sushi |
| 프리미엄초밥 | Premium sushi |
| 어린이초밥 | Kids sushi |
| 유부초밥세트 | Fried tofu sushi set |
| 계란초밥세트 | Egg sushi set |
| 오늘의초밥 | Today’s sushi |
| 셰프초밥 | Chef sushi |
| 커플초밥세트 | Couple sushi set |
| 가족초밥세트 | Family sushi set |
| 초밥한판 | Sushi platter |
| 초밥정식 | Sushi set meal |

AI notes:

- Assorted sushi often includes piece count and composition.
- Set name is not enough; parse `10p`, `12p`, `15p` if present.
- Customer-facing composition should be reviewed if AI infers fish types.

---

## 8. L3: Single-Kind / Half-and-Half Sushi

L3 code:

    JAPANESE_SUSHI_SINGLE_HALF

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 광어초밥 | Flatfish sushi |
| 연어초밥 | Salmon sushi |
| 생연어초밥 | Fresh salmon sushi |
| 아부리연어초밥 | Seared salmon sushi |
| 참치초밥 | Tuna sushi |
| 도로초밥 | Toro sushi |
| 오도로초밥 | Otoro sushi |
| 주도로초밥 | Chutoro sushi |
| 소고기초밥 | Beef sushi |
| 와규초밥 | Wagyu sushi |
| 생새우초밥 | Raw shrimp sushi |
| 간장새우초밥 | Soy-marinated shrimp sushi |
| 초새우초밥 | Cooked vinegar shrimp sushi |
| 장어초밥 | Eel sushi |
| 우나기초밥 | Unagi sushi |
| 계란초밥 | Egg sushi |
| 유부초밥 | Inari sushi |
| 타코와사비군함 | Tako wasabi gunkan |
| 날치알군함 | Flying fish roe gunkan |
| 성게알군함 | Sea urchin gunkan |
| 광어연어초밥 | Flatfish + salmon sushi |
| 광어+연어초밥 | Flatfish + salmon sushi |
| 연어새우초밥 | Salmon + shrimp sushi |
| 연어+새우초밥 | Salmon + shrimp sushi |
| 장어+연어초밥 | Eel + salmon sushi |

AI notes:

- `+` or slash often means half-and-half or combo.
- Piece count must be parsed separately.
- Raw fish items require freshness/safety category.

---

## 9. L3: Roll / Maki / Hand Roll

L3 code:

    JAPANESE_ROLL_MAKI

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 캘리포니아롤 | California roll |
| 연어롤 | Salmon roll |
| 새우튀김롤 | Shrimp tempura roll |
| 치즈롤 | Cheese roll |
| 후토마끼 | Futomaki |
| 대왕김밥 | Futomaki marketing/local label |
| 네기토로마끼 | Negitoro maki |
| 마끼 | Maki |
| 데마끼 | Hand roll |
| 참치마끼 | Tuna maki |
| 연어마끼 | Salmon maki |
| 장어롤 | Eel roll |
| 크런치롤 | Crunch roll |
| 스파이시롤 | Spicy roll |
| 아보카도롤 | Avocado roll |
| 유부롤 | Inari-style roll |

AI notes:

- “대왕김밥” in Japanese context may be 후토마끼, not Korean kimbap.
- Roll size/piece count may appear separately.

---

## 10. L2: Sashimi / Raw Fish / Seafood

L2 code:

    JAPANESE_SASHIMI_SEAFOOD

This category includes live fish sashimi, assorted sashimi, premium tuna, aged sashimi, raw seafood, boiled seafood, oysters, and cold seafood dishes.

---

## 11. L3: Live Fish / Assorted Sashimi

L3 code:

    JAPANESE_SASHIMI_LIVE_ASSORTED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 모듬회 | Assorted raw fish |
| 모둠회 | Assorted raw fish alias |
| 모듬사시미 | Assorted sashimi |
| 모둠사시미 | Assorted sashimi alias |
| 광어회 | Flatfish sashimi |
| 우럭회 | Rockfish sashimi |
| 연어회 | Salmon sashimi |
| 생연어사시미 | Fresh salmon sashimi |
| 참돔회 | Red sea bream sashimi |
| 돌돔회 | Rock bream sashimi |
| 감성돔회 | Black porgy sashimi |
| 농어회 | Sea bass sashimi |
| 밀치회 | Mullet sashimi |
| 가숭어회 | Mullet alias |
| 전어회 | Gizzard shad sashimi |
| 방어회 | Yellowtail sashimi |
| 대방어사시미 | Large yellowtail sashimi |
| 도다리세꼬시 | Sliced flounder with bones |
| 참가자미회 | Flounder sashimi |
| 숭어회 | Mullet sashimi |
| 줄돔 | Striped beakfish, often market price |
| 자연산회 | Wild-caught sashimi |

AI notes:

- Fish species may have market price.
- `소`, `중`, `대`, `특대` size markers must be parsed as size attributes.
- Raw fish is generally not fast track by default unless strict packaging/freshness policy exists.

---

## 12. L3: Premium Tuna / Aged Sashimi

L3 code:

    JAPANESE_TUNA_AGED_SASHIMI

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 참치사시미 | Tuna sashimi |
| 참치회 | Tuna sashimi |
| 혼마구로 | Bluefin tuna |
| 참다랑어 | Bluefin tuna |
| 오도로 | Fatty tuna belly |
| 주도로 | Medium fatty tuna |
| 아카미 | Lean tuna |
| 메카도로 | Swordfish belly |
| 황새치뱃살 | Swordfish belly |
| 숙성사시미 | Aged sashimi |
| 숙성회 | Aged raw fish |
| 선어회 | Aged/iced fish |
| 참치모듬 | Assorted tuna |
| 참치스페셜 | Tuna special |
| 참치오마카세 | Tuna omakase |

AI notes:

- Tuna terms may indicate premium price and course/set.
- Raw/premium handling requires review for pricing and inventory.

---

## 13. L3: Seafood / Raw And Boiled Seafood

L3 code:

    JAPANESE_SEAFOOD_RAW_BOILED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 산낙지 | Live octopus |
| 전복회 | Abalone sashimi |
| 멍게 | Sea squirt |
| 해삼 | Sea cucumber |
| 개불 | Spoon worm |
| 소라숙회 | Boiled turban shell |
| 문어숙회 | Boiled octopus |
| 석화 | Fresh oyster |
| 생굴 | Fresh oyster |
| 가리비회 | Scallop sashimi |
| 홍어회 | Skate sashimi |
| 오징어회 | Squid sashimi |
| 물회 | Cold raw fish soup |
| 모듬물회 | Assorted mulhoe |
| 오징어물회 | Squid mulhoe |
| 자리물회 | Jeju damselfish mulhoe |
| 해산물모듬 | Assorted seafood |
| 해물모듬 | Assorted seafood |
| 대게 | Snow crab, often market price |
| 킹크랩 | King crab, often market price |
| 랍스터 | Lobster, often market price |

AI notes:

- Market-price parsing is critical for crab/lobster/premium seafood.
- Raw seafood may have seasonal availability.
- Some items overlap with Korean seafood restaurants.

---

## 14. L2: Katsu / Tempura

L2 code:

    JAPANESE_KATSU_TEMPURA

This category includes donkatsu, Japanese katsu, fried seafood, tempura, tendon, croquettes, karaage, and fried side items.

---

## 15. L3: Donkatsu / Japanese Katsu

L3 code:

    JAPANESE_DONKATSU_KATSU

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 돈카츠 | Donkatsu |
| 돈까스 | Donkatsu Korean spelling |
| 등심카츠 | Loin katsu |
| 로스카츠 | Loin katsu |
| 안심카츠 | Tenderloin katsu |
| 히레카츠 | Tenderloin katsu |
| 치즈돈카츠 | Cheese donkatsu |
| 모짜렐라카츠 | Mozzarella katsu |
| 치킨카츠 | Chicken katsu |
| 생선카츠 | Fish katsu |
| 멘치카츠 | Menchi katsu |
| 모듬카츠 | Assorted katsu |
| 모둠까스 | Assorted katsu alias |
| 경양식돈까스 | Korean western-style donkatsu |
| 매운돈카츠 | Spicy donkatsu |
| 카츠정식 | Katsu set |
| 카츠산도 | Katsu sandwich |

AI notes:

- Donkatsu can be main item or set.
- Fast track may be review candidate if kitchen timing and packaging fit.

---

## 16. L3: Tempura / Tendon / Fried Dish

L3 code:

    JAPANESE_TEMPURA_TENDON_FRIED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 텐동 | Tempura rice bowl |
| 모듬튀김덮밥 | Assorted tempura bowl |
| 에비텐동 | Shrimp tendon |
| 모듬튀김 | Assorted tempura |
| 새우튀김 | Shrimp tempura |
| 에비후라이 | Ebi fry |
| 고로케 | Croquette |
| 감자고로케 | Potato croquette |
| 카레고로케 | Curry croquette |
| 야채고로케 | Vegetable croquette |
| 치킨가라아게 | Chicken karaage |
| 가라아게 | Karaage |
| 굴튀김 | Fried oyster |
| 카키후라이 | Fried oyster |
| 오징어다리튀김 | Fried squid legs |
| 이카게소 | Squid legs |
| 타코야끼 | Takoyaki |
| 게살크림고로케 | Crab cream croquette |

AI notes:

- Tempura may be side or donburi.
- Fried items may have KDS fry station routing.

---

## 17. L2: Donburi / Curry / Rice

L2 code:

    JAPANESE_DONBURI_RICE

This category includes Japanese rice bowls, seafood bowls, curry rice, and sashimi restaurant rice dishes.

---

## 18. L3: Japanese Donburi

L3 code:

    JAPANESE_DONBURI

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 가츠동 | Katsu rice bowl |
| 돈까스덮밥 | Katsu rice bowl Korean label |
| 에비동 | Shrimp tempura rice bowl |
| 새우튀김덮밥 | Shrimp tempura rice bowl |
| 규동 | Beef rice bowl |
| 부타동 | Pork rice bowl |
| 오야코동 | Chicken and egg rice bowl |
| 사케동 | Salmon rice bowl |
| 연어덮밥 | Salmon rice bowl |
| 에비사케동 | Shrimp salmon rice bowl |
| 카이센동 | Seafood rice bowl |
| 해산물덮밥 | Seafood rice bowl |
| 지라시스시 | Chirashi sushi |
| 네기토로동 | Negitoro rice bowl |
| 우나기동 | Eel rice bowl |
| 장어덮밥 | Eel rice bowl |
| 텐동 | Tempura rice bowl |
| 차슈동 | Chashu rice bowl |
| 스테키동 | Steak rice bowl |

AI notes:

- `동` suffix often indicates donburi in Japanese context.
- `회덮밥` may map to seafood rice in Korean/Japanese hybrid context.

---

## 19. L3: Sashimi Restaurant Rice

L3 code:

    JAPANESE_SEAFOOD_RICE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 회덮밥 | Raw fish rice bowl |
| 연어회덮밥 | Salmon sashimi rice bowl |
| 알밥 | Fish roe rice |
| 돌솥알밥 | Hot stone fish roe rice |
| 멍게비빔밥 | Sea squirt bibimbap |
| 장어덮밥 | Eel rice bowl |
| 물회밥 | Mulhoe with rice |
| 초밥밥 | Sushi rice add-on |
| 공기밥 | Rice add-on |
| 미니회덮밥 | Mini sashimi rice bowl |

AI notes:

- Sashimi restaurant rice should be separated from Korean bibimbap when L1 context is Japanese/Seafood.
- Rice add-ons are side items, not main bowls.

---

## 20. L3: Japanese Curry

L3 code:

    JAPANESE_CURRY_RICE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 카레라이스 | Curry rice |
| 일본식카레 | Japanese curry |
| 돈카츠카레 | Katsu curry |
| 에비후라이카레 | Shrimp fry curry |
| 가라아게카레 | Karaage curry |
| 치킨카레 | Chicken curry |
| 야채카레 | Vegetable curry |
| 치즈카레 | Cheese curry |
| 매운카레 | Spicy curry |

AI notes:

- Curry may overlap with Korean diner or Western category.
- L1 context matters.

---

## 21. L2: Japanese Noodles

L2 code:

    JAPANESE_NOODLE

This category includes ramen, tsukemen, maze soba, udon, soba, and stir-fried noodles.

---

## 22. L3: Ramen

L3 code:

    JAPANESE_RAMEN

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 돈코츠라멘 | Tonkotsu ramen |
| 소유라멘 | Shoyu ramen |
| 쇼유라멘 | Shoyu spelling variant |
| 시오라멘 | Shio ramen |
| 미소라멘 | Miso ramen |
| 카라미소라멘 | Spicy miso ramen |
| 탄탄멘 | Tantanmen |
| 츠케멘 | Tsukemen |
| 마제소바 | Maze soba |
| 아부라소바 | Abura soba |
| 차슈라멘 | Chashu ramen |
| 매운라멘 | Spicy ramen |
| 냉라멘 | Cold ramen |
| 규코츠라멘 | Beef bone ramen |
| 닭육수라멘 | Chicken broth ramen |

AI notes:

- Ramen is hot noodle KDS station.
- Fast track usually requires packaging review.

---

## 23. L3: Udon / Soba

L3 code:

    JAPANESE_UDON_SOBA

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 가츠오우동 | Katsuobushi udon |
| 꼬치어묵우동 | Skewered fish cake udon |
| 김치우동 | Kimchi udon |
| 튀김우동 | Tempura udon |
| 붓카케우동 | Bukkake udon |
| 냉우동 | Cold udon |
| 야키우동 | Stir-fried udon |
| 판모밀 | Cold soba tray |
| 판소바 | Cold soba tray |
| 냉모밀 | Cold soba |
| 냉소바 | Cold soba |
| 비빔모밀 | Spicy mixed soba |
| 자루소바 | Zaru soba |
| 카케소바 | Kake soba |
| 텐자루소바 | Tempura zaru soba |

AI notes:

- Korean spelling variants for soba/memil must be normalized.
- Cold noodle items may have better pickup suitability than hot noodle but still require review.

---

## 24. L2: Soup / Nabe / Braised / Grilled Fish Head

L2 code:

    JAPANESE_SOUP_NABE_BRAISE

This category includes spicy fish soup, clear fish soup, Japanese nabe, oden, fish head dishes, and braised/grilled fish.

---

## 25. L3: Maeuntang / Jiri

L3 code:

    JAPANESE_SEAFOOD_MAEUNTANG_JIRI

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 서더리매운탕 | Fish bone spicy soup |
| 우럭매운탕 | Rockfish spicy soup |
| 통우럭매운탕 | Whole rockfish spicy soup |
| 생태탕 | Fresh pollack soup |
| 대구탕 | Cod soup |
| 대구지리 | Clear cod soup |
| 복지리 | Clear pufferfish soup |
| 복어탕 | Pufferfish soup |
| 알탕 | Fish roe soup |
| 동태탕 | Frozen pollack soup |
| 지리탕 | Clear fish soup |
| 매운탕 | Spicy fish soup |
| 활어매운탕 | Live fish spicy soup |

AI notes:

- May overlap with Korean stew/tang.
- In sashimi restaurant context, often side/after-meal soup.

---

## 26. L3: Japanese Nabe / Braised / Grilled Fish

L3 code:

    JAPANESE_NABE_BRAISE_GRILL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 오뎅나베 | Oden nabe |
| 스지오뎅탕 | Tendon oden soup |
| 나가사키짬뽕탕 | Nagasaki champon soup |
| 간사이오뎅탕 | Kansai oden soup |
| 알스지전골 | Roe/tendon hotpot |
| 메로구이 | Grilled mero |
| 메로조림 | Braised mero |
| 도미머리구이 | Grilled sea bream head |
| 도미머리조림 | Braised sea bream head |
| 연어머리구이 | Grilled salmon head |
| 고등어구이 | Grilled mackerel, Japanese set context |
| 사바시오야끼 | Salt-grilled mackerel |
| 장어구이 | Grilled eel |
| 우나기구이 | Grilled eel |

AI notes:

- Fish head dishes are often izakaya or seafood side dishes.
- Nabe/hotpot is generally not fast track default.

---

## 27. L2: Set / Course / Omakase

L2 code:

    JAPANESE_SET_COURSE

This category includes set meals, lunch specials, sushi-soba/udon sets, katsu sets, sashimi sets, and omakase/course menus.

---

## 28. L3: Set Meal / Fixed Set

L3 code:

    JAPANESE_SET_MEAL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 초밥우동세트 | Sushi udon set |
| 초밥소바세트 | Sushi soba set |
| 돈카츠정식 | Donkatsu set |
| 라멘정식 | Ramen set |
| 회정식 | Sashimi set |
| 특정식 | Special set |
| 점심특선정식 | Lunch special set |
| 런치세트 | Lunch set |
| 디너세트 | Dinner set |
| 카츠정식 | Katsu set |
| 우동정식 | Udon set |
| 사시미정식 | Sashimi set |
| 초밥정식 | Sushi set |

AI notes:

- Set components must be parsed if visible.
- A set price is one menu price, not each component price.

---

## 29. L3: Omakase / Course

L3 code:

    JAPANESE_OMAKASE_COURSE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 스시오마카세 | Sushi omakase |
| 사시미오마카세 | Sashimi omakase |
| 오마카세 | Omakase |
| 런치오마카세 | Lunch omakase |
| 디너오마카세 | Dinner omakase |
| 디너코스 | Dinner course |
| 런치코스 | Lunch course |
| A코스 | Course A |
| B코스 | Course B |
| C코스 | Course C |
| 회코스요리 | Sashimi course |
| 셰프코스 | Chef course |
| 프리미엄코스 | Premium course |

AI notes:

- Course may require reservation, seat/time slot, and market availability.
- Usually not item-level fast track.

---

## 30. L2: Izakaya Side / Small Dish

L2 code:

    JAPANESE_IZAKAYA_SIDE

This category includes small plates, snacks, grilled skewers, and fusion izakaya items that may appear in Japanese/seafood menus.

---

## 31. L3: Izakaya Side

L3 code:

    JAPANESE_IZAKAYA_SMALL_DISH

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 타코와사비 | Tako wasabi |
| 에다마메 | Edamame |
| 명란구이 | Grilled pollack roe |
| 시샤모구이 | Grilled shishamo |
| 야키토리 | Yakitori |
| 닭꼬치 | Chicken skewer |
| 오코노미야끼 | Okonomiyaki |
| 야끼소바 | Yakisoba |
| 가지튀김 | Fried eggplant |
| 두부튀김 | Fried tofu |
| 아게다시도후 | Agedashi tofu |
| 감자사라다 | Potato salad |
| 해파리냉채 | Jellyfish salad |
| 가리비버터구이 | Butter grilled scallop |
| 콘버터 | Corn butter |

AI notes:

- Izakaya items may overlap with pub/bar.
- Alcohol age policy may apply when store type is izakaya.

---

## 32. L2: Alcohol / Drinks

L2 code:

    JAPANESE_ALCOHOL_DRINK

Alcohol and drinks must be separated from food items.

---

## 33. L3: Japanese Alcohol / Drinks

L3 code:

    JAPANESE_ALCOHOL_DRINK_ITEM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 사케 | Sake |
| 니혼슈 | Nihonshu |
| 준마이 | Junmai |
| 다이긴죠 | Daiginjo |
| 쇼츄 | Shochu |
| 하이볼 | Highball |
| 산토리하이볼 | Suntory highball |
| 생맥주 | Draft beer |
| 병맥주 | Bottled beer |
| 소주 | Soju |
| 와인 | Wine |
| 우롱하이 | Oolong highball |
| 레몬사와 | Lemon sour |
| 매실사와 | Plum sour |
| 라무네 | Ramune |
| 콜라 | Cola |
| 사이다 | Cider/sprite |
| 녹차 | Green tea |
| 우롱차 | Oolong tea |

AI notes:

- Alcohol requires age/legal handling.
- Drink items usually do not require KDS kitchen station.

---

## 34. L2: Piece Count / Market Price / Notice

L2 code:

    JAPANESE_NOTICE_PRICE_RULE

This category is not a normal menu item category.

It captures price structures, piece counts, market price labels, and customer-facing notice text.

---

## 35. L3: Piece Count Notice

L3 code:

    JAPANESE_NOTICE_PIECE_COUNT

Seed patterns:

| Pattern | Meaning |
|---|---|
| 2pc | 2 pieces |
| 2pcs | 2 pieces |
| 2p | 2 pieces |
| 10p | 10 pieces |
| 10pc | 10 pieces |
| 10pcs | 10 pieces |
| 12p | 12 pieces |
| 12pcs | 12 pieces |
| 1인 | Per person |
| 2인 | For 2 persons |
| 소 | Small |
| 중 | Medium |
| 대 | Large |
| 특대 | Extra large |
| 반반 | Half-and-half |
| half | Half-and-half |
| 세트 | Set |
| 구성 | Composition |

AI notes:

- Piece count must attach to the nearest sushi/menu item.
- Size labels must attach to sashimi/seafood platter where applicable.
- `p` can be confused with price marker; parse carefully.

---

## 36. L3: Market Price Notice

L3 code:

    JAPANESE_NOTICE_MARKET_PRICE

Seed patterns:

| Pattern | Meaning |
|---|---|
| 시가 | Market price |
| 싯가 | Market price variant |
| 변동 | Variable price |
| 문의 | Ask store |
| 점주문의 | Ask owner/store |
| 가격문의 | Ask for price |
| 당일시세 | Daily market price |
| 계절시가 | Seasonal market price |
| kg당 | Price per kg |
| 1kg | Weight price |
| kg | Kilogram unit |
| 싯가변동 | Variable market price |
| 산지시세 | Source market price |
| 예약문의 | Reservation inquiry |

AI notes:

- Market price must not be stored as numeric 0 unless there is explicit price-state field.
- Recommended state is `PRICE_MARKET`.
- Customer app display must show approved market-price label.

---

## 37. Piece Count And Price Parsing Boundary

Japanese/seafood parser must extract:

- menu name
- piece count
- piece unit
- set count
- size label
- price
- market price state
- weight unit if seafood
- per-person course price
- course time slot
- composition text
- raw item marker
- availability/seasonality marker

Example:

    연어초밥 10p 18,000원

Should parse as:

| Field | Value |
|---|---|
| menu_name | 연어초밥 |
| piece_count | 10 |
| piece_unit | p |
| price | 18000 |

Example:

    광어초밥 2pc 4,000원

Should parse as:

| Field | Value |
|---|---|
| menu_name | 광어초밥 |
| piece_count | 2 |
| piece_unit | pc |
| price | 4000 |

Example:

    줄돔 싯가

Should parse as:

| Field | Value |
|---|---|
| menu_name | 줄돔 |
| price_state | PRICE_MARKET |
| numeric_price | null |

---

## 38. Market Price Handling Boundary

Market price requires special policy.

Market-price item must include:

- price state
- display label
- update owner
- last confirmed price if available
- validity time if price is later entered
- customer confirmation requirement
- POS handling rule
- order availability rule
- payment capture rule
- refund/cancel rule
- audit reference

Market price must not be silently converted to 0.

Market price should not allow instant checkout unless current price is confirmed.

---

## 39. Raw Seafood Attribute Boundary

Raw seafood item may include:

- raw item flag
- live fish flag
- aged sashimi flag
- seasonal availability
- market price flag
- freshness window
- packaging suitability
- allergen candidates
- storage temperature
- inventory freshness batch
- no-show waste risk
- fast track disabled by default
- customer warning if required

Raw seafood requires stricter freshness and customer communication.

---

## 40. Japanese/Seafood Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Sushi set | Review candidate only if packaging/freshness controlled |
| Single sushi | Review candidate |
| Sashimi/live fish | Usually disabled |
| Premium tuna/aged sashimi | Usually disabled |
| Raw seafood | Usually disabled |
| Katsu | Review candidate |
| Tempura | Review candidate |
| Donburi | Review candidate |
| Ramen/hot noodle | Review or disabled |
| Cold soba/udon | Review candidate |
| Nabe/hotpot | Disabled |
| Course/omakase | Disabled |
| Izakaya side | Review by item |
| Alcohol | Disabled unless legal/age/payment policy exists |

Fast track must be explicitly approved by menu item.

---

## 41. Japanese/Seafood KDS Station Candidate Matrix

Candidate station mapping:

| Category | KDS Station Candidate |
|---|---|
| Sushi | Sushi/cold station |
| Sashimi | Sashimi/cold station |
| Raw seafood | Seafood/cold station |
| Katsu | Fry station |
| Tempura | Fry station |
| Donburi | Rice/hot station |
| Curry | Curry/hot station |
| Ramen | Ramen/noodle station |
| Udon/Soba | Noodle/cold station |
| Maeuntang/Jiri | Hot soup station |
| Nabe | Hotpot station |
| Grilled fish head | Grill station |
| Omakase/course | Course/service station |
| Izakaya side | Side/fry/grill station |
| Drinks | Beverage/service station |

Station recommendation must be confirmed by store configuration.

---

## 42. POS Mapping Boundary

Japanese/seafood POS mapping must handle:

- piece count
- set composition
- market price
- size pricing
- per-person course
- reservation/deposit if applicable
- alcohol
- raw item notice
- taxable category
- option/add-on
- same menu with different count/size
- inventory linkage
- daily price update
- refund/cancel rule

POS mapping requires human verification.

AI must not finalize market-price or financial mapping.

---

## 43. Customer Display Boundary

Customer-facing Japanese/seafood menu must distinguish:

- sushi set
- single sushi
- roll/maki
- sashimi/live fish
- seafood
- katsu/tempura
- donburi/curry
- ramen/udon/soba
- nabe/soup
- set/course/omakase
- izakaya side
- drinks/alcohol
- market price items
- piece count
- raw item notice
- seasonal availability

Market-price label must be clear.

Piece count must be shown if it affects customer expectation.

---

## 44. Japanese/Seafood Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `l1_category` | `JAPANESE_SEAFOOD_SUSHI` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `fish_species_candidate` | Fish/species if detected |
| `piece_count` | Piece count |
| `piece_unit` | pc/p/piece |
| `size_label` | small/medium/large/etc. |
| `price_candidate` | Numeric price if present |
| `price_state` | fixed, market, inquiry, variable |
| `raw_item_flag` | Raw item marker |
| `seasonality_candidate` | Seasonal marker |
| `set_components` | Set/course components |
| `fasttrack_default_candidate` | Candidate suitability |
| `kds_station_candidate` | Station |
| `confidence` | Confidence |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output is draft until human confirmation.

---

## 45. Japanese/Seafood Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `JAPANESE_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `SUSHI_PIECE_COUNT_DETECTED` | Piece count detected |
| `SASHIMI_SIZE_DETECTED` | Sashimi size detected |
| `MARKET_PRICE_DETECTED` | Market price detected |
| `RAW_SEAFOOD_DETECTED` | Raw seafood detected |
| `OMAKASE_COURSE_DETECTED` | Omakase/course detected |
| `JAPANESE_MENU_LOW_CONFIDENCE` | Low confidence |
| `JAPANESE_MENU_REVIEW_REQUIRED` | Human review required |
| `JAPANESE_CATEGORY_CONFIRMED` | Category confirmed |
| `MARKET_PRICE_REVIEW_REQUIRED` | Market price review required |
| `PIECE_COUNT_REVIEW_REQUIRED` | Piece count review required |
| `RAW_ITEM_NOTICE_REQUIRED` | Raw item notice required |
| `JAPANESE_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `JAPANESE_FASTTRACK_DISABLED_BY_DEFAULT` | Fast track disabled by default |

Events must route through `10610`.

---

## 46. Dictionary Governance Boundary

Japanese/seafood dictionary updates must be governed.

Update actions:

- add sushi term
- add fish species
- add sashimi alias
- add roll/maki term
- add market-price pattern
- add piece-count parsing pattern
- add omakase/course pattern
- change L2/L3 category
- mark raw item
- mark fast track guidance
- mark POS/inventory risk
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

## 47. Relationship To AI Menu Intake

This document supports:

- business category context
- OCR/LLM extraction
- piece count parsing
- market-price parsing
- raw seafood detection
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- KDS station recommendation
- fast track default guidance
- validation and deployment readiness

Japanese/seafood classification output remains draft until approved.

---

## 48. Relationship To Fast Track

Japanese/seafood fast track must be conservative.

Fast track approval requires:

- item-level approval
- freshness window
- packaging suitability
- raw seafood risk review
- KDS station readiness
- pickup timing reliability
- market price exclusion or confirmed price
- no-show waste risk
- customer notice
- policy version

Sashimi, live fish, market-price seafood, omakase, and course items are disabled by default.

---

## 49. Relationship To Inventory And Market Price

Japanese/seafood category is inventory and market-price sensitive.

Inventory mapping may include:

- fish species
- live/fresh/aged/frozen state
- portion size
- piece count
- market price
- daily price update
- supplier lot
- freshness batch
- waste risk
- raw item notice
- seasonal availability
- sold-out state

Wrong parsing can create customer dispute and financial mismatch.

---

## 50. Anti-Patterns

Avoid:

- storing `시가` as numeric 0 without price state
- treating `10p` as price
- treating price as piece count
- deploying raw seafood item without review
- auto-enabling fast track for sashimi/live fish
- treating omakase as normal item-level menu
- ignoring size labels such as 소/중/대
- treating course components as separate paid items without confirmation
- using AI to infer fish species not visible in source
- hiding market price from customer display
- accepting payment for market-price item without confirmed price
- ignoring raw item freshness window
- mapping seafood rice bowl to Korean bibimbap without context
- treating alcohol as ordinary drink without legal policy
- allowing dictionary mutation by AI without review

These anti-patterns must be blocked in future runtime design.

---

## 51. Runtime Deferral

This document defines Japanese/Seafood/Sushi menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- piece-count parser
- market-price parser
- AI classification runtime
- POS mapping runtime
- inventory/freshness mapping runtime
- customer display implementation
- KDS station mapping implementation
- fast track eligibility runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 52. Validation Checklist

Validation must confirm:

1. Classification scope is defined.
2. Classification depth is defined.
3. L2 category overview is defined.
4. Sushi L2 is defined.
5. Assorted sushi set L3 is defined.
6. Single-kind/half-and-half sushi L3 is defined.
7. Roll/maki L3 is defined.
8. Sashimi/seafood L2 is defined.
9. Live fish/assorted sashimi L3 is defined.
10. Premium tuna/aged sashimi L3 is defined.
11. Seafood/raw and boiled seafood L3 is defined.
12. Katsu/tempura L2 is defined.
13. Donkatsu/katsu L3 is defined.
14. Tempura/tendon/fried dish L3 is defined.
15. Donburi/rice L2 is defined.
16. Japanese donburi L3 is defined.
17. Sashimi restaurant rice L3 is defined.
18. Japanese curry L3 is defined.
19. Japanese noodle L2 is defined.
20. Ramen L3 is defined.
21. Udon/soba L3 is defined.
22. Soup/nabe/braise L2 is defined.
23. Maeuntang/jiri L3 is defined.
24. Japanese nabe/braise/grill L3 is defined.
25. Set/course/omakase L2 is defined.
26. Set meal L3 is defined.
27. Omakase/course L3 is defined.
28. Izakaya side L2 is defined.
29. Izakaya small dish L3 is defined.
30. Alcohol/drink L2 is defined.
31. Alcohol/drink item L3 is defined.
32. Piece count/market price/notice L2 is defined.
33. Piece count notice L3 is defined.
34. Market price notice L3 is defined.
35. Piece count and price parsing boundary is defined.
36. Market price handling boundary is defined.
37. Raw seafood attribute boundary is defined.
38. Fast track default guidance is defined.
39. KDS station candidate matrix is defined.
40. POS mapping boundary is defined.
41. Customer display boundary is defined.
42. Classification output format is defined.
43. Event catalog is defined.
44. Dictionary governance boundary is defined.
45. Relationships to AI Menu Intake, Fast Track, and Inventory/Market Price are defined.
46. Anti-patterns are listed.
47. Coding remains unauthorized.
48. Runtime remains deferred.

---

## 53. Relationship To Previous Documents

This document supplements:

- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10705 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `10706 Korean Meat Grill BBQ Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

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

- `10708 Chinese Food Menu Taxonomy Policy`
- `10709 Cafe Dessert Beverage Menu Taxonomy Policy`
- `10710 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 54. Final Rule

Japanese/seafood menu classification must treat piece count, market price, raw seafood, sashimi size, set composition, omakase/course structure, and seasonal availability as first-class parsing targets.

AI may match sushi, sashimi, seafood, katsu, tempura, donburi, curry, ramen, udon, soba, hotpot, course, izakaya side, alcohol, piece-count, and market-price patterns.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS mapping verification, market-price handling, raw item notice, and rollback remain mandatory before deployment.

Market-price items must not be stored as ordinary zero-price items.

Fast track must be disabled by default for sashimi, live fish, market-price seafood, omakase, and course experiences unless a separate approved policy enables specific packaged items.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.