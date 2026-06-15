# 40015_Policy_Pub_Pocha_Late_Night_Delivery_Alcohol_Anju_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary

## 1. Purpose

This document defines the Pub, Pocha, Late-Night Delivery, Hof, Izakaya, Wine Bar, Alcohol, Anju, Jokbal, Bossam, Night Food, Soup, Stir-Fry, Fried Food, Dry Snack, Fruit, Side Meal, and Set Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `40014 Salad Healthy Food Poke Yogurt Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded salad, poke, warm bowl, yogurt, oatmeal, diet meal, clean drink, base, dressing, topping, nutrition, and health-claim parsing.

This document expands the `PUB_POCHA_LATE_NIGHT` category because late-night Korean dining and drinking menus have broad and high-risk structures:

- alcohol-heavy menu boards
- anju and drink separation
- volume unit parsing such as 300cc, 500cc, pitcher, bottle, glass
- set menu parsing such as 족발 + 쟁반국수 + 음료
- spicy late-night dishes
- delivery night food
- jokbal/bossam size and front/back leg options
- dry snacks and fruit platters
- soup/stew anju
- fried anju and jeon
- high late-night average order value
- age/legal policy for alcohol
- delivery alcohol restriction and jurisdiction risk
- broad overlap with Korean, Japanese, BBQ, bunsik, and fast food categories

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Pub/pocha/late-night menus require alcohol-aware and set-aware classification.

The correct rule is:

Alcohol must be separated from food.  
Bottle, glass, pitcher, 300cc, and 500cc are serving units, not menu names.  
Anju categories must not be misclassified as ordinary meals without context.  
Jokbal and bossam night menus require size, part, and half-and-half options.  
Set menus must preserve components.  
Delivery night food must preserve packaging, cancellation, and age/legal constraints where applicable.  
AI may recommend classification, but human review remains mandatory for alcohol, price, set, size, option, POS, delivery, legal notice, fast track, and customer-facing deployment.  

This category can support late-night pickup and delivery, but alcohol and age/legal controls must remain separate and strict.

---

## 3. Classification Scope

This registry applies to:

- hof houses
- pubs
- Korean pocha
- indoor pocha
- izakaya-style pubs
- wine bars
- beer pubs
- makgeolli pubs
- soju pubs
- late-night delivery restaurants
- chicken feet delivery shops
- jokbal/bossam night shops
- spicy anju shops
- dry snack pubs
- fruit/snack bars
- menu board OCR/AI parsing
- alcohol volume/unit parsing
- set component parsing
- jokbal/bossam option parsing
- night food classification
- POS/KDS mapping
- delivery layout
- fast track suitability review
- age/legal policy review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Pub/Pocha/Late-Night category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Pub / Pocha / Late Night | `PUB_POCHA_LATE_NIGHT` |
| `L2_MENU_CATEGORY` | Major family | Stir-Fried Anju |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Spicy night food |
| `ITEM_ATTRIBUTE` | Alcohol unit, size, set, spiciness, delivery | 500cc, 병, 잔, 소/중/대, A세트 |

Alcohol and anju attributes are mandatory in this category.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `PUB_STIR_SPICY_ANJU` | Stir-Fried / Spicy / Seasoned Anju |
| `PUB_SOUP_STEW_HOTPOT` | Soup / Stew / Hotpot Anju |
| `PUB_FRIED_JEON` | Fried Food / Jeon / Pancake Anju |
| `PUB_DRY_FRUIT_LIGHT` | Dry Snacks / Fruit / Light Anju |
| `PUB_JOKBAL_BOSSAM_NIGHT` | Jokbal / Bossam / Late-Night Specialty |
| `PUB_ALCOHOL_BEVERAGE` | Alcohol / Beverages |
| `PUB_SIDE_MEAL` | Pub Side Meals |
| `PUB_SET_COMBO` | Set / Combo / Platter |
| `PUB_NOTICE_OPTION_RULE` | Alcohol Unit / Size / Delivery / Legal Notice Rules |

Notice and option rules must be separated from menu items.

---

## 6. L2: Stir-Fried / Spicy / Seasoned Anju

L2 code:

    PUB_STIR_SPICY_ANJU

This category includes spicy night dishes, stir-fried entrails, chicken feet, pork skin, gizzard, spicy pork, and seasoned cold/spicy mixed dishes.

---

## 7. L3: Spicy Night Food / Stir-Fry

L3 code:

    PUB_SPICY_NIGHT_STIRFRY

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 원조불닭발 | Original spicy chicken feet |
| 불닭발 | Spicy chicken feet |
| 뼈없는닭발 | Boneless chicken feet |
| 무뼈닭발 | Boneless chicken feet alias |
| 국물닭발 | Soup-style chicken feet |
| 오돌뼈 | Pork cartilage |
| 오돌뼈주먹밥세트 | Pork cartilage with rice ball set |
| 양념곱창볶음 | Spicy seasoned gopchang stir-fry |
| 순대곱창볶음 | Sundae gopchang stir-fry |
| 돼지껍데기볶음 | Stir-fried pork skin |
| 제육볶음 | Pocha-style spicy pork |
| 똥집소금구이 | Salt-grilled gizzard |
| 닭똥집볶음 | Chicken gizzard stir-fry |
| 매운족발 | Spicy jokbal |
| 불족발 | Spicy jokbal alias |
| 닭갈비안주 | Dakgalbi anju |
| 매운오돌뼈 | Spicy pork cartilage |
| 쭈꾸미볶음 | Webfoot octopus stir-fry |
| 낙지볶음 | Octopus stir-fry |
| 무뼈닭발세트 | Boneless chicken feet set |

AI notes:

- Many dishes overlap with Korean food or BBQ, but pub/late-night context changes display category.
- Rice ball set components must be preserved.
- Spiciness is a key attribute.

---

## 8. L3: Sweet-Sour / Seasoned Mixed Anju

L3 code:

    PUB_MUCHIM_COLD_SEASONED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 골뱅이무침 | Spicy sea snail salad |
| 골뱅이소면 | Sea snail salad with noodles |
| 소면사리 | Noodle add-on |
| 소라무침 | Seasoned turban shell |
| 홍어회무침 | Seasoned skate |
| 오징어초무침 | Spicy vinegar squid |
| 도토리묵무침 | Seasoned acorn jelly |
| 두부김치 | Tofu and kimchi |
| 탕평채 | Tangpyeongchae |
| 회무침 | Seasoned raw fish |
| 꼬막무침 | Seasoned cockle |
| 낙지초무침 | Spicy vinegar octopus |
| 오이소박이무침 | Cucumber side, context required |
| 묵은지두부김치 | Aged kimchi tofu |
| 번데기무침 | Seasoned silkworm pupae, rare/contextual |

AI notes:

- “소면사리 포함” should be component/add-on, not standalone base menu.
- Muchim items may be cold station or assembly station.

---

## 9. L2: Soup / Stew / Hotpot Anju

L2 code:

    PUB_SOUP_STEW_HOTPOT

This category includes classic pocha soups, seafood soups, meat hotpots, pub stews, and large shared soup anju.

---

## 10. L3: Classic Pocha Soup

L3 code:

    PUB_CLASSIC_SOUP

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 양은냄비오뎅탕 | Aluminum pot oden soup |
| 오뎅탕 | Fish cake soup |
| 어묵탕 | Fish cake soup |
| 모둠조개탕 | Assorted clam soup |
| 모듬조개탕 | Assorted clam soup alias |
| 홍합탕 | Mussel soup |
| 바지락술찜 | Steamed clams with alcohol |
| 알탕 | Fish roe soup |
| 동태탕 | Frozen pollack soup |
| 번데기탕 | Silkworm pupae soup |
| 계란탕 | Egg soup |
| 누룽지탕 | Scorched rice soup |
| 짬뽕탕 | Spicy seafood soup |
| 해장탕 | Hangover soup |
| 순두부탕 | Soft tofu soup |
| 조개술찜 | Clams steamed with alcohol |
| 문어탕 | Octopus soup |

AI notes:

- Soup anju is usually shared dish, not ordinary Korean meal soup.
- Pot size and serving size may be options.

---

## 11. L3: Spicy / Meat Hotpot

L3 code:

    PUB_SPICY_MEAT_HOTPOT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 나가사키짬뽕탕 | Nagasaki champon soup |
| 해물짬뽕탕 | Seafood jjamppong soup |
| 부대찌개 | Budae stew anju |
| 안주용부대찌개 | Budae stew for anju |
| 돼지고기김치찌개 | Large pork kimchi stew |
| 대용량김치찌개 | Large kimchi stew |
| 곱창전골 | Gopchang hotpot |
| 소고기버섯전골 | Beef mushroom hotpot |
| 스지전골 | Beef tendon hotpot |
| 밀푀유나베 | Mille-feuille nabe |
| 짜글이찌개 | Thick jjageuli stew |
| 닭볶음탕 | Braised spicy chicken |
| 감자탕 | Pork backbone stew |
| 해물탕 | Seafood soup |
| 마라전골 | Mala hotpot |
| 알스지전골 | Roe and tendon hotpot |
| 김치전골 | Kimchi hotpot |

AI notes:

- Hotpot items are generally not instant fast track by default.
- Shared dish size options should be parsed.

---

## 12. L2: Fried Food / Jeon / Pancake Anju

L2 code:

    PUB_FRIED_JEON

This category includes beer pub fried food, hof-style sides, chicken wings, karaage, and makgeolli-style jeon/pancakes.

---

## 13. L3: Beer Pub Fried Food

L3 code:

    PUB_BEER_FRIED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 모둠감자튀김 | Assorted fries |
| 모듬감자튀김 | Assorted fries alias |
| 감자튀김 | Fries |
| 버팔로윙 | Buffalo wings |
| 버팔로봉 | Buffalo drumettes |
| 윙봉 | Wing and drumette |
| 치즈스틱 | Cheese sticks |
| 치킨가라아게 | Chicken karaage |
| 가라아게 | Karaage |
| 오징어튀김 | Fried squid |
| 똥집튀김 | Fried gizzard |
| 멘보샤 | Shrimp toast |
| 새우튀김 | Fried shrimp |
| 치즈볼 | Cheese balls |
| 어니언링 | Onion rings |
| 나쵸 | Nachos |
| 피쉬앤칩스 | Fish and chips |
| 치킨텐더 | Chicken tenders |
| 소시지튀김 | Fried sausage |
| 깐풍만두 | Spicy dumplings |
| 튀김플래터 | Fried platter |

AI notes:

- Fried platter components should be preserved.
- Pub fried items often pair with beer but remain food items.

---

## 14. L3: Makgeolli Jeon / Pancake

L3 code:

    PUB_MAKGEOLLI_JEON

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 해물파전 | Seafood scallion pancake |
| 김치전 | Kimchi pancake |
| 감자전 | Potato pancake |
| 치즈감자전 | Cheese potato pancake |
| 녹두빈대떡 | Mung bean pancake |
| 부추전 | Chive pancake |
| 모둠전 | Assorted jeon |
| 모듬전 | Assorted jeon alias |
| 육전 | Beef jeon |
| 미나리전 | Water parsley jeon |
| 굴전 | Oyster jeon |
| 동태전 | Pollack jeon |
| 호박전 | Zucchini jeon |
| 두부전 | Tofu jeon |
| 깻잎전 | Perilla leaf jeon |

AI notes:

- Jeon overlaps with Korean side category, but pub context changes display placement.
- Makgeolli pairing may be relevant for recommendations, not authority.

---

## 15. L2: Dry Snacks / Fruit / Light Anju

L2 code:

    PUB_DRY_FRUIT_LIGHT

This category includes dry seafood snacks, jerky, fruit platters, sherbet, light salads, and refreshing anju.

---

## 16. L3: Dry Seafood / Dry Snacks

L3 code:

    PUB_DRY_SNACK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 반건조오징어 | Semi-dried squid |
| 피데기 | Semi-dried squid alias |
| 마른오징어 | Dried squid |
| 한치구이 | Grilled arrow squid |
| 먹태 | Dried pollack |
| 황태채 | Dried pollack strips |
| 노가리 | Dried young pollack |
| 쥐포구이 | Grilled filefish |
| 아귀포 | Dried monkfish |
| 육포 | Beef jerky |
| 모둠마른안주 | Assorted dry snacks |
| 모듬마른안주 | Assorted dry snacks alias |
| 오징어입 | Squid beak |
| 땅콩 | Peanuts |
| 믹스넛 | Mixed nuts |
| 마른멸치 | Dried anchovy |
| 건어물세트 | Dried seafood set |

AI notes:

- Dry snacks may have simple prep and strong late-night pickup potential.
- Nuts/seafood allergen candidates may apply.

---

## 17. L3: Fruit / Sherbet / Light Anju

L3 code:

    PUB_FRUIT_SHERBET_LIGHT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 모둠과일 | Assorted fruit |
| 모듬과일 | Assorted fruit alias |
| 과일안주 | Fruit anju |
| 황도 | Canned peach |
| 아이스황도 | Iced canned peach |
| 파인애플샤베트 | Pineapple sherbet |
| 요구르트샤베트 | Yogurt sherbet |
| 코코넛샤베트 | Coconut sherbet |
| 케이준치킨샐러드 | Cajun chicken salad |
| 리코타치즈샐러드 | Ricotta cheese salad, pub context |
| 카프레제 | Caprese |
| 토마토카프레제 | Tomato caprese |
| 치즈플래터 | Cheese platter |
| 크래커치즈 | Cracker and cheese |
| 아이스크림 | Ice cream |
| 요거트아이스 | Yogurt ice |

AI notes:

- Fruit and sherbet may be cold station items.
- Platter composition must be preserved.

---

## 18. L2: Jokbal / Bossam / Late-Night Specialty

L2 code:

    PUB_JOKBAL_BOSSAM_NIGHT

This category includes jokbal, bossam, spicy jokbal, garlic jokbal, cold jokbal, oyster bossam, hong-eo samhap, boiled pork platters, and late-night delivery specialty meals.

---

## 19. L3: Jokbal Specialty

L3 code:

    PUB_JOKBAL_SPECIALTY

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 한방족발 | Herbal jokbal |
| 족발 | Jokbal |
| 앞다리족발 | Front leg jokbal |
| 뒷다리족발 | Rear leg jokbal |
| 온족발 | Warm jokbal |
| 냉채족발 | Cold jellyfish jokbal |
| 불족발 | Spicy jokbal |
| 매운족발 | Spicy jokbal alias |
| 마늘족발 | Garlic jokbal |
| 반반족발 | Half-and-half jokbal |
| 일반+불족 | Regular + spicy jokbal |
| 미니족발 | Mini jokbal |
| 왕족발 | Large jokbal |
| 족발세트 | Jokbal set |
| 족발대 | Large jokbal |
| 족발중 | Medium jokbal |
| 족발소 | Small jokbal |
| 막국수포함 | Makguksu included notice |
| 보쌈김치추가 | Bossam kimchi add-on |

AI notes:

- Front/rear leg and size options are important.
- Half-and-half jokbal requires component structure.
- Included side dishes must not become unrelated paid items unless separately priced.

---

## 20. L3: Bossam / Samhap / Boiled Pork

L3 code:

    PUB_BOSSAM_SAMHAP_SUYUK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 한방보쌈 | Herbal bossam |
| 보쌈 | Bossam |
| 마늘보쌈 | Garlic bossam |
| 굴보쌈 | Oyster bossam |
| 홍어삼합 | Skate samhap |
| 수육플래터 | Boiled pork platter |
| 수육 | Boiled pork |
| 보쌈세트 | Bossam set |
| 보쌈정식 | Bossam meal/set context |
| 보쌈김치 | Bossam kimchi |
| 무김치추가 | Radish kimchi add-on |
| 굴추가 | Oyster add-on |
| 막국수추가 | Makguksu add-on |
| 쟁반국수 | Platter noodles |
| 족보세트 | Jokbal + bossam set |
| 반반보쌈 | Half-and-half bossam |
| 보쌈대 | Large bossam |
| 보쌈중 | Medium bossam |
| 보쌈소 | Small bossam |

AI notes:

- Oyster bossam may be seasonal and raw/seafood allergen-sensitive.
- Set and size options must be preserved.

---

## 21. L2: Alcohol / Beverages

L2 code:

    PUB_ALCOHOL_BEVERAGE

This category includes soju, beer, draft beer, imported beer, highball, makgeolli, traditional liquor, wine, corkage, mixers, soft drinks, and hangover drinks.

Alcohol requires separate legal and age-gated handling.

---

## 22. L3: Soju / Beer

L3 code:

    PUB_ALCOHOL_SOJU_BEER

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 참이슬 | Soju brand |
| 처음처럼 | Soju brand |
| 새로 | Soju brand |
| 진로 | Soju brand |
| 좋은데이 | Soju brand |
| 대선 | Soju brand |
| 한라산 | Soju brand |
| 카스 | Beer brand |
| 테라 | Beer brand |
| 켈리 | Beer brand |
| 크러시 | Beer brand |
| 생맥주 | Draft beer |
| 생맥주 500cc | Draft beer 500cc |
| 생맥주 300cc | Draft beer 300cc |
| 피처 | Beer pitcher |
| pitcher | Beer pitcher |
| 병맥주 | Bottled beer |
| 칭따오 | Tsingtao |
| 아사히 | Asahi |
| 호가든 | Hoegaarden |
| 하이네켄 | Heineken |
| 기네스 | Guinness |
| 코로나 | Corona beer |
| 클라우드 | Kloud beer |
| 수제맥주 | Craft beer |

AI notes:

- 300cc, 500cc, pitcher, bottle are serving units.
- Alcohol must not be routed as ordinary beverage without legal policy.

---

## 23. L3: Highball / Traditional Liquor / Wine

L3 code:

    PUB_ALCOHOL_HIGHBALL_TRADITIONAL_WINE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 산토리하이볼 | Suntory highball |
| 짐빔하이볼 | Jim Beam highball |
| 얼그레이하이볼 | Earl Grey highball |
| 하이볼 | Highball |
| 레몬하이볼 | Lemon highball |
| 자몽하이볼 | Grapefruit highball |
| 장수막걸리 | Jangsu makgeolli |
| 지평막걸리 | Jipyeong makgeolli |
| 밤막걸리 | Chestnut makgeolli |
| 막걸리 | Makgeolli |
| 동동주 | Dongdongju |
| 청하 | Cheongha |
| 백세주 | Baekseju |
| 복분자 | Bokbunja wine |
| 화요 | Hwayo |
| 화요 25도 | Hwayo 25 |
| 화요 41도 | Hwayo 41 |
| 일품진로 | Ilpoom Jinro |
| 하우스와인 | House wine |
| 레드와인 | Red wine |
| 화이트와인 | White wine |
| 스파클링와인 | Sparkling wine |
| 콜키지 | Corkage |
| 사케 | Sake |
| 위스키 | Whisky |

AI notes:

- Bottle/glass/unit and alcohol percentage may be attributes.
- Corkage is a service/fee item, not drink inventory.

---

## 24. L3: Soft Drinks / Mixers / Hangover Drinks

L3 code:

    PUB_SOFT_MIXER_HANGOVER

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 콜라 | Cola |
| 사이다 | Cider/sprite |
| 토닉워터 | Tonic water |
| 진저에일 | Ginger ale |
| 탄산수 | Sparkling water |
| 레몬슬라이스 | Lemon slice |
| 레몬추가 | Add lemon |
| 초코에몽 | Chocolate milk hangover drink |
| 갈아만든배 | Pear drink |
| 헛개수 | Hovenia drink |
| 컨디션 | Hangover drink |
| 여명808 | Hangover drink |
| 생수 | Water |
| 주스 | Juice |
| 에너지드링크 | Energy drink |
| 아이스 | Ice add-on |

AI notes:

- Mixer and garnish may be add-ons.
- Hangover drinks are non-alcohol items but often in pub context.

---

## 25. L2: Pub Side Meals

L2 code:

    PUB_SIDE_MEAL

This category includes rice balls, lunchbox-style meals, noodles, ramen, and rice add-ons commonly sold in pubs and late-night stores.

---

## 26. L3: Pub Side Meals

L3 code:

    PUB_SIDE_MEAL_ITEM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 날치알주먹밥 | Flying fish roe rice ball |
| 참치마요주먹밥 | Tuna mayo rice ball |
| 셀프주먹밥 | Self-made rice ball |
| 주먹밥 | Rice ball |
| 추억의도시락 | Old-school lunchbox |
| 옛날도시락 | Old-school lunchbox alias |
| 짜파구리 | Jjapaguri |
| 해장라면 | Hangover ramen |
| 라면 | Ramen |
| 김치말이국수 | Kimchi cold noodles |
| 공기밥 | Bowl of rice |
| 볶음밥 | Fried rice |
| 계란찜 | Steamed egg |
| 콘치즈 | Corn cheese |
| 쟁반국수 | Platter noodles |
| 막국수 | Buckwheat noodles |
| 소면사리 | Thin noodle add-on |
| 우동사리 | Udon add-on |
| 라면사리 | Ramen add-on |

AI notes:

- Side meals may be components of spicy anju sets.
- Sari items should usually be add-ons.

---

## 27. L2: Set / Combo / Platter

L2 code:

    PUB_SET_COMBO

This category captures pub sets, late-night sets, jokbal/bossam sets, anju+drink sets, and platter bundles.

---

## 28. L3: Pub / Late-Night Set

L3 code:

    PUB_SET_COMBO_ITEM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| A세트 | Set A |
| B세트 | Set B |
| C세트 | Set C |
| 세트1 | Set 1 |
| 세트2 | Set 2 |
| 족발세트 | Jokbal set |
| 보쌈세트 | Bossam set |
| 족보세트 | Jokbal + bossam set |
| 닭발세트 | Chicken feet set |
| 오돌뼈세트 | Pork cartilage set |
| 안주세트 | Anju set |
| 커플세트 | Couple set |
| 패밀리세트 | Family set |
| 모둠안주 | Assorted anju |
| 모듬안주 | Assorted anju alias |
| 튀김안주세트 | Fried anju set |
| 마른안주세트 | Dry snack set |
| 과일안주세트 | Fruit set |
| 술안주세트 | Alcohol pairing set |
| 족발+쟁반국수+음료 | Jokbal + noodles + drink |
| 닭발+오돌뼈+주먹밥 | Chicken feet + pork cartilage + rice ball |
| 보쌈+막국수+음료 | Bossam + makguksu + drink |

AI notes:

- `+`, comma, slash, and parentheses often indicate components.
- Set components must be preserved and editable.
- Alcohol set requires legal review.

---

## 29. L2: Alcohol Unit / Size / Delivery / Legal Notice Rules

L2 code:

    PUB_NOTICE_OPTION_RULE

This category is not a normal menu item category.

It captures alcohol serving units, food size options, delivery notices, age/legal notices, corkage rules, and late-night ordering notices.

---

## 30. L3: Alcohol Unit / Serving Pattern

L3 code:

    PUB_NOTICE_ALCOHOL_UNIT_PATTERN

Seed patterns:

| Pattern | Meaning |
|---|---|
| 300cc | Draft beer volume |
| 500cc | Draft beer volume |
| 1700cc | Pitcher volume candidate |
| 피처 | Pitcher |
| pitcher | Pitcher |
| 병 | Bottle |
| Bottle | Bottle |
| 잔 | Glass |
| Glass | Glass |
| 정 | Bottle/unit, OCR/context review |
| 캔 | Can |
| 캔맥주 | Canned beer |
| 생맥 | Draft beer abbreviation |
| 도수 | Alcohol percentage |
| 25도 | Alcohol percentage |
| 41도 | Alcohol percentage |
| 레드/화이트 | Wine color option |
| R/W | Red/white wine option |
| 온더락 | On the rocks |
| 스트레이트 | Straight |
| 샷 | Shot |
| 토닉세트 | Tonic set |
| 레몬추가 | Lemon add-on |
| 얼음추가 | Ice add-on |

AI notes:

- Unit text must attach to alcohol item.
- Alcohol unit parsing requires legal and POS review.

---

## 31. L3: Size / Part / Delivery / Legal Notice Pattern

L3 code:

    PUB_NOTICE_SIZE_DELIVERY_LEGAL_PATTERN

Seed patterns:

| Pattern | Meaning |
|---|---|
| 소 | Small size |
| 중 | Medium size |
| 대 | Large size |
| 특대 | Extra large |
| 앞다리 | Front leg option |
| 뒷다리 | Rear leg option |
| 반반 | Half-and-half |
| 일반+불족 | Regular + spicy jokbal |
| 막국수 포함 | Makguksu included |
| 음료 포함 | Drink included |
| 보쌈김치 추가 | Bossam kimchi add-on |
| 쟁반국수 추가 | Noodle add-on |
| 배달가능 | Delivery available |
| 포장가능 | Takeout available |
| 야식배달 | Late-night delivery |
| 최소주문금액 | Minimum order |
| 배달팁 | Delivery fee |
| 미성년자 구매불가 | Minor purchase prohibited |
| 신분증 확인 | ID check |
| 주류 배달 제한 | Alcohol delivery restriction |
| 콜키지 | Corkage |
| 병당 | Per bottle |
| 잔당 | Per glass |
| 라스트오더 | Last order |
| 심야할증 | Late-night surcharge |

AI notes:

- Legal notices must not become menu items.
- Delivery and alcohol restrictions require policy review.

---

## 32. Alcohol Parsing Boundary

Parser must separate alcohol item, unit, and price.

Example:

    생맥주 500cc 4,500 / 300cc 3,000

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 생맥주 |
| option_group | volume |
| option_1 | 500cc / 4500 |
| option_2 | 300cc / 3000 |

Example:

    하우스와인 잔 8,000 / 병 38,000

Should parse as:

| Field | Value |
|---|---|
| parent_menu | 하우스와인 |
| option_group | serving_unit |
| option_1 | glass / 8000 |
| option_2 | bottle / 38000 |

Alcohol cannot be treated as ordinary drink.

---

## 33. Set Component Parsing Boundary

Parser must preserve set composition.

Example:

    A세트: 족발(소)+쟁반국수+음료 32,000

Should parse as:

| Field | Value |
|---|---|
| menu_name | A세트 |
| menu_type | set |
| component_1 | 족발 |
| component_1_option | 소 |
| component_2 | 쟁반국수 |
| component_3 | 음료 |
| price | 32000 |

Set component text must be editable in admin UI.

---

## 34. Jokbal / Bossam Size And Option Parsing Boundary

Parser must handle:

- size: 소/중/대/특대
- front leg/back leg
- hot/cold jokbal
- spicy/general half-and-half
- garlic option
- oyster seasonal option
- side inclusion
- kimchi add-on
- makguksu/jangban-guksu add-on
- drink inclusion
- delivery pack structure

Example:

    반반족발 일반+불족 중 39,000

Should parse as:

| Field | Value |
|---|---|
| menu_name | 반반족발 |
| menu_type | half_half |
| component_1 | 일반족발 |
| component_2 | 불족발 |
| size | 중 |
| price | 39000 |

---

## 35. Pub/Late-Night Menu Attribute Boundary

Menu items may include:

- anju type
- alcohol flag
- alcohol volume
- bottle/glass/pitcher unit
- size option
- spice level
- delivery eligibility
- takeout eligibility
- set components
- part option
- included side
- add-on side
- hot/cold marker
- late-night surcharge
- age/legal restriction
- KDS station
- fast track suitability
- packaging type
- no-show waste risk
- POS option group
- inventory component

Attributes must be reviewed before live deployment.

---

## 36. Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Spicy stir-fried anju | Review candidate |
| Chicken feet / odolbone | Review candidate |
| Muchim/cold anju | Review candidate |
| Soup/hotpot anju | Usually disabled or review |
| Fried anju | Review candidate |
| Jeon | Review candidate |
| Dry snack | Strong candidate |
| Fruit/sherbet | Strong candidate if stock-ready |
| Jokbal/bossam | Review candidate |
| Pub side meals | Review candidate |
| Alcohol | Disabled unless legal/age/payment policy exists |
| Set/combo | Review candidate |
| Late-night delivery packs | Review candidate |

Fast track must be conservative where age/legal, shared hotpot, or delivery restrictions exist.

---

## 37. KDS / Service Station Candidate Matrix

Candidate station mapping:

| Category | Station Candidate |
|---|---|
| Spicy stir-fry | Wok/pan station |
| Chicken feet / odolbone | Spicy anju station |
| Muchim/cold anju | Cold assembly station |
| Soup/hotpot | Hot soup station |
| Fried anju | Fry station |
| Jeon | Pan station |
| Dry snack | Dry snack/service station |
| Fruit/sherbet | Cold dessert station |
| Jokbal/bossam | Slicing/packing station |
| Side meal | Rice/noodle/side station |
| Alcohol | Bar/service station |
| Soft drinks/mixers | Bar/service station |
| Set/combo | Assembly/packing station |

Store configuration must override defaults.

---

## 38. POS Mapping Boundary

Pub/pocha/late-night POS mapping must handle:

- food item
- alcohol item
- alcohol serving unit
- bottle/glass/pitcher price
- size price
- part option
- half-and-half option
- set components
- included side
- add-on side
- delivery eligibility
- alcohol legal restriction
- late-night surcharge
- corkage fee
- service charge if applicable
- refund/cancel rule
- inventory deduction
- tax category
- coupon eligibility
- age verification requirement

POS mapping requires human verification.

AI must not finalize alcohol, legal, or option price mapping.

---

## 39. Customer Display Boundary

Customer-facing pub/pocha menu must distinguish:

- spicy anju
- soup/stew/hotpot
- fried food
- jeon
- dry snacks
- fruit/light anju
- jokbal/bossam
- side meals
- sets/combos
- alcohol
- mixers/drinks
- size options
- alcohol volume options
- age/legal notices
- delivery/takeout restrictions
- fast track availability if approved

Alcohol must be displayed under legal policy and age-gated surfaces where required.

---

## 40. Late-Night Delivery Boundary

Late-night delivery menus require:

- delivery available flag
- takeout available flag
- alcohol delivery restriction
- minimum order amount
- delivery fee
- late-night surcharge
- packaging rule
- cancellation/no-show rule
- rider handoff rule
- customer age verification where alcohol is involved
- store closing/last order time
- menu availability schedule
- kitchen load throttling
- incident/fallback route

AI may detect delivery-related text but must not create policy automatically.

---

## 41. Alcohol Legal Governance Boundary

Alcohol-related menu handling must be governed separately.

Alcohol governance must consider:

- age verification
- legal sale restrictions
- delivery restrictions
- local regulation
- ID check notice
- intoxication/refusal policy
- payment restriction if applicable
- refund/cancel policy
- platform policy
- audit
- staff responsibility
- customer-facing warning
- admin permission

AI detection of alcohol is evidence.

It is not legal authorization.

---

## 42. Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `display_name_original` | Original display |
| `l1_category` | `PUB_POCHA_LATE_NIGHT` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `alcohol_flag` | Alcohol candidate |
| `alcohol_unit_options` | Bottle/glass/cc/pitcher |
| `size_options` | 소/중/대/etc. |
| `part_options` | Front/back leg, bone/boneless, etc. |
| `set_components` | Set components |
| `spice_level_candidate` | Spicy marker |
| `delivery_flags` | Delivery/takeout/late-night markers |
| `legal_notice_candidates` | Age/ID/alcohol restriction markers |
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
| `PUB_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `PUB_ALCOHOL_ITEM_DETECTED` | Alcohol item detected |
| `PUB_ALCOHOL_UNIT_DETECTED` | Alcohol unit detected |
| `PUB_SET_COMPONENT_DETECTED` | Set component detected |
| `PUB_JOKBAL_SIZE_OPTION_DETECTED` | Jokbal/bossam size option detected |
| `PUB_HALF_HALF_DETECTED` | Half-and-half detected |
| `PUB_DELIVERY_NOTICE_DETECTED` | Delivery notice detected |
| `PUB_LEGAL_NOTICE_DETECTED` | Legal/age notice detected |
| `PUB_LATE_NIGHT_NOTICE_DETECTED` | Late-night notice detected |
| `PUB_LOW_CONFIDENCE` | Low confidence |
| `PUB_REVIEW_REQUIRED` | Human review required |
| `PUB_CATEGORY_CONFIRMED` | Category confirmed |
| `PUB_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `PUB_ALCOHOL_POLICY_REVIEW_REQUIRED` | Alcohol policy review required |
| `PUB_FASTTRACK_REVIEW_REQUIRED` | Fast track review required |

Events must route through `10610`.

---

## 44. Dictionary Governance Boundary

Pub/pocha/late-night dictionary updates must be governed.

Update actions:

- add anju term
- add alcohol brand term
- add beer/highball/traditional liquor term
- add volume/unit pattern
- add jokbal/bossam option pattern
- add late-night delivery term
- add set parsing pattern
- add legal notice pattern
- change L2/L3 category
- mark fast track guidance
- mark POS mapping risk
- mark alcohol/legal review required
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
- alcohol detection
- serving unit parsing
- size option parsing
- set component parsing
- jokbal/bossam option parsing
- late-night delivery notice parsing
- legal notice detection
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- KDS/bar station recommendation
- fast track default guidance
- validation and deployment readiness

Pub/pocha/late-night classification output remains draft until approved.

---

## 46. Relationship To Fast Track

Pub/pocha/late-night food can support fast track selectively.

Fast track approval requires:

- menu-specific prep time
- legal/alcohol exclusion or approval
- packaging suitability
- kitchen/bar station readiness
- hot/cold holding policy
- delivery/takeout policy
- late-night load control
- age/legal notice if applicable
- no-show waste risk
- policy version
- manager/HQ approval where required

Alcohol must be disabled by default for fast track unless a separate approved age/legal/payment policy explicitly enables it.

---

## 47. Relationship To Security And Compliance

This category has higher compliance risk due to alcohol and late-night operations.

Required security/compliance attention:

- age verification
- alcohol visibility gating
- restricted delivery logic
- staff accountability
- customer notice
- transaction audit
- refund/cancel audit
- incident handling
- disorderly customer handling if applicable
- data minimization
- support escalation
- policy version tracking

AI classification does not replace legal or operational policy.

---

## 48. Anti-Patterns

Avoid:

- classifying alcohol as ordinary beverage
- treating 500cc or 병/잔 as menu name
- treating legal notice as menu item
- treating set components as separate paid items without review
- losing A세트/B세트 component structure
- treating 반반족발 as unrelated two menu items
- auto-enabling fast track for alcohol
- auto-enabling fast track for hotpot/shared dishes without review
- ignoring front/back leg and size options in jokbal
- ignoring delivery/takeout restrictions
- treating corkage as drink inventory
- using AI to finalize alcohol POS mapping without review
- allowing AI to mutate dictionary automatically

These anti-patterns must be blocked in future runtime design.

---

## 49. Runtime Deferral

This document defines Pub/Pocha/Late-Night menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- alcohol parser
- alcohol legal policy runtime
- volume/unit parser
- set component parser
- jokbal/bossam option parser
- late-night delivery policy runtime
- AI classification runtime
- POS mapping runtime
- customer display implementation
- KDS/bar station mapping implementation
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
4. Stir-fried/spicy anju L2 is defined.
5. Spicy night food/stir-fry L3 is defined.
6. Sweet-sour/seasoned mixed anju L3 is defined.
7. Soup/stew/hotpot anju L2 is defined.
8. Classic pocha soup L3 is defined.
9. Spicy/meat hotpot L3 is defined.
10. Fried/jeon anju L2 is defined.
11. Beer pub fried food L3 is defined.
12. Makgeolli jeon/pancake L3 is defined.
13. Dry snacks/fruit/light anju L2 is defined.
14. Dry seafood/dry snacks L3 is defined.
15. Fruit/sherbet/light anju L3 is defined.
16. Jokbal/bossam/night specialty L2 is defined.
17. Jokbal specialty L3 is defined.
18. Bossam/samhap/suyuk L3 is defined.
19. Alcohol/beverages L2 is defined.
20. Soju/beer L3 is defined.
21. Highball/traditional liquor/wine L3 is defined.
22. Soft drinks/mixers/hangover drinks L3 is defined.
23. Pub side meals L2 is defined.
24. Pub side meals L3 is defined.
25. Set/combo/platter L2 is defined.
26. Pub/late-night set L3 is defined.
27. Alcohol unit/size/delivery/legal notice rules L2 is defined.
28. Alcohol unit/serving pattern L3 is defined.
29. Size/part/delivery/legal notice pattern L3 is defined.
30. Alcohol parsing boundary is defined.
31. Set component parsing boundary is defined.
32. Jokbal/bossam size and option parsing boundary is defined.
33. Menu attribute boundary is defined.
34. Fast track default guidance is defined.
35. KDS/service station candidate matrix is defined.
36. POS mapping boundary is defined.
37. Customer display boundary is defined.
38. Late-night delivery boundary is defined.
39. Alcohol legal governance boundary is defined.
40. Classification output format is defined.
41. Event catalog is defined.
42. Dictionary governance boundary is defined.
43. Relationships to AI Menu Intake, Fast Track, and Security/Compliance are defined.
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
- `40013 Cafe Dessert Beverage Bakery Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`
- `40014 Salad Healthy Food Poke Yogurt Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

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

- `40016 Menu Taxonomy Master Closure And Label Dictionary Governance Policy`
- `40017 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`
- `40018 Alcohol Age Gate Delivery Compliance And Pub POS Boundary Policy`
- `40019 Late-Night Delivery Order No-Show And Cancellation SOP Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 52. Final Rule

Pub/Pocha/Late-Night menu classification must treat alcohol separation, serving unit, bottle/glass/pitcher volume, anju category, set components, jokbal/bossam size, front/back leg option, half-and-half structure, delivery notice, legal notice, and late-night operating constraints as first-class parsing targets.

AI may match stir-fried anju, spicy night dishes, soups, hotpots, fried food, jeon, dry snacks, fruit, jokbal, bossam, alcohol, side meals, sets, delivery notices, and alcohol unit patterns.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS option mapping, alcohol/legal review, delivery policy review, and rollback remain mandatory before deployment.

Alcohol must remain disabled by default for fast track or delivery flows unless a separate approved legal, age-gate, payment, and operational policy explicitly enables it.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.