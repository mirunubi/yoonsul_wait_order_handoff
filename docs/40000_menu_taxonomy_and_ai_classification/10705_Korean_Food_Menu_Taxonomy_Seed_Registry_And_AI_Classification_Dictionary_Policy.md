# 10705_Korean_Food_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary_Policy

## 1. Purpose

This document defines the Korean Food Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy` defined the two-level taxonomy model:

- L1 business category
- L2 menu category
- AI category context
- confidence-based menu classification
- cooking time, KDS station, fast track, POS, inventory, analytics, and i18n linkage

This document expands the `KOREAN_FOOD` L1 category into a deeper Korean menu dictionary for AI menu intake, OCR/LLM parsing, embedding search, category matching, and admin review.

The purpose is to help AI classify Korean restaurant menu boards more accurately by matching extracted text to a known middle-category and subcategory tree.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Korean food classification requires deeper structure than a single “한식” label.

The correct rule is:

Korean menu names are diverse, regional, abbreviated, and overlapping.  
AI must classify Korean menu text using a guided taxonomy.  
Menu dictionary is a classification aid, not final truth.  
OCR match is not deployment approval.  
AI category match must carry confidence.  
Low-confidence, ambiguous, price-sensitive, allergen-sensitive, or fast-track-sensitive items require human review.  
Dictionary match must not bypass menu validation, POS mapping, KDS routing, or fast track approval.  

The Korean Food dictionary improves menu intake accuracy but does not publish menus automatically.

---

## 3. Korean Food Dictionary Scope

This registry covers common Korean restaurant menu families including:

- rice dishes
- bibimbap
- porridge
- soups
- stews
- hotpots
- grilled dishes
- stir-fried dishes
- braised dishes
- steamed dishes
- Korean noodles
- pancakes
- egg dishes
- dumplings
- side dishes
- set meals
- Korean table meals
- regional Korean dishes
- Korean fast/light meal overlap where relevant

This dictionary is not exhaustive for all future cases.

Unknown items must route to review.

---

## 4. Classification Depth

The Korean Food classification uses three layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Korean Food | `KOREAN_FOOD` |
| `L2_MENU_CATEGORY` | Major family | Rice / Porridge |
| `L3_MENU_SUBCATEGORY` | Specific menu subfamily | Bibimbap |

An individual menu item may additionally have:

- normalized menu name
- aliases
- regional variant
- ingredient tag
- preparation method
- hot/cold marker
- fast track suitability candidate
- KDS station candidate
- cooking time default candidate
- allergen candidate
- review flag

---

## 5. L2 Category Overview

Recommended Korean Food L2 categories:

| L2 Code | Label |
|---|---|
| `KOREAN_RICE_PORRIDGE` | Rice / Bibimbap / Porridge |
| `KOREAN_SOUP_TANG_BAEKSUK` | Gukbap / Tang / Baeksuk |
| `KOREAN_STEW_HOTPOT_JJAGEULI` | Jjigae / Jeongol / Jjageuli |
| `KOREAN_GRILL_STIRFRY` | Grill / Stir-Fry |
| `KOREAN_STEAM_BRAISE_SUYUK` | Steamed / Braised / Suyuk |
| `KOREAN_NOODLE` | Korean Noodles |
| `KOREAN_SIDE_PANCAKE` | Side Dishes / Jeon / Pancakes |
| `KOREAN_SET_MEAL` | Set Meal / Baekban / Course |

These L2 categories may be expanded by franchise template or store-specific override.

---

## 6. L2: Rice / Bibimbap / Porridge

L2 code:

    KOREAN_RICE_PORRIDGE

This category includes rice-centered dishes, bibimbap, rice bowls, fried rice, nutrition rice, ssambap, and porridge.

---

## 7. L3: Bibimbap

L3 code:

    KOREAN_BIBIMBAP

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 전주비빔밥 | Jeonju-style bibimbap |
| 양푼비빔밥 | Large bowl bibimbap |
| 돌솥비빔밥 | Hot stone bibimbap |
| 육회비빔밥 | Raw beef bibimbap |
| 꼬막비빔밥 | Cockle bibimbap |
| 멍게비빔밥 | Sea squirt bibimbap |
| 불고기비빔밥 | Bulgogi bibimbap |
| 낙지비빔밥 | Octopus bibimbap |
| 제육비빔밥 | Spicy pork bibimbap |
| 참치비빔밥 | Tuna bibimbap |
| 야채비빔밥 | Vegetable bibimbap |
| 산채비빔밥 | Wild vegetable bibimbap |
| 강된장보리비빔밥 | Barley bibimbap with soybean paste |
| 보리비빔밥 | Barley bibimbap |
| 열무비빔밥 | Young radish kimchi bibimbap |

AI notes:

- “비빔” plus rice context usually maps here.
- “회덮밥” may map to Japanese/Sashimi or Korean Rice depending store context.
- “육회비빔밥” may require raw meat notice and food safety review.

---

## 8. L3: Rice Bowl / Fried Rice

L3 code:

    KOREAN_RICE_BOWL_FRIED_RICE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 오징어덮밥 | Squid rice bowl |
| 제육덮밥 | Spicy pork rice bowl |
| 낙지덮밥 | Octopus rice bowl |
| 쭈꾸미덮밥 | Webfoot octopus rice bowl |
| 불고기덮밥 | Bulgogi rice bowl |
| 김치볶음밥 | Kimchi fried rice |
| 새우볶음밥 | Shrimp fried rice |
| 야채볶음밥 | Vegetable fried rice |
| 해물볶음밥 | Seafood fried rice |
| 카레라이스 | Korean-style curry rice |
| 하이라이스 | Hayashi rice |
| 짜장밥 | Jjajang rice, Korean-style context |
| 참치마요덮밥 | Tuna mayo rice bowl |
| 치킨마요덮밥 | Chicken mayo rice bowl |
| 소고기덮밥 | Beef rice bowl |
| 오므라이스 | Omelet rice, Korean diner context |

AI notes:

- “덮밥” may appear in Korean, Japanese, or Asian contexts.
- Store L1 context is important.
- “사케동”, “규동”, “가츠동” should map to Japanese if L1 is Japanese.

---

## 9. L3: Nutrition Rice / Ssambap

L3 code:

    KOREAN_NUTRITION_RICE_SSAMBAP

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 곤드레밥 | Gondre rice |
| 굴밥 | Oyster rice |
| 연잎밥 | Lotus leaf rice |
| 대통밥 | Bamboo rice |
| 솥밥 | Pot rice |
| 가지솥밥 | Eggplant pot rice |
| 버섯솥밥 | Mushroom pot rice |
| 명란솥밥 | Pollack roe pot rice |
| 전복솥밥 | Abalone pot rice |
| 우렁쌈밥 | Freshwater snail ssambap |
| 제육쌈밥 | Spicy pork ssambap |
| 불고기쌈밥 | Bulgogi ssambap |
| 보리쌈밥 | Barley ssambap |
| 강된장쌈밥 | Soybean paste ssambap |

AI notes:

- “정식” suffix may map to set meal if served as full meal.
- Ssambap usually needs side dish/set meal display logic.

---

## 10. L3: Porridge / Gruel

L3 code:

    KOREAN_PORRIDGE_GRUEL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 전복죽 | Abalone porridge |
| 소고기야채죽 | Beef vegetable porridge |
| 삼계죽 | Chicken ginseng porridge |
| 낙지김치죽 | Octopus kimchi porridge |
| 단호박죽 | Sweet pumpkin porridge |
| 팥죽 | Red bean porridge |
| 잣죽 | Pine nut porridge |
| 흑임자죽 | Black sesame porridge |
| 야채죽 | Vegetable porridge |
| 버섯굴죽 | Mushroom oyster porridge |
| 흰죽 | Plain porridge |
| 참치죽 | Tuna porridge |
| 게살죽 | Crab meat porridge |

AI notes:

- Porridge may belong to specialized porridge restaurants.
- Fast track suitability depends on packaging and holding temperature.

---

## 11. L2: Gukbap / Tang / Baeksuk

L2 code:

    KOREAN_SOUP_TANG_BAEKSUK

This category includes meal soups, gukbap, hangover soup, gomtang, seolleongtang, galbitang, samgyetang, baeksuk, chicken, and duck soups.

---

## 12. L3: Gukbap / Hangover Soup

L3 code:

    KOREAN_GUKBAP_HAEJANGGUK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소머리국밥 | Ox head soup with rice |
| 돼지국밥 | Pork gukbap |
| 순대국밥 | Sundae gukbap |
| 콩나물국밥 | Bean sprout gukbap |
| 뼈다귀해장국 | Pork bone hangover soup |
| 선지해장국 | Blood hangover soup |
| 우거지해장국 | Cabbage hangover soup |
| 올갱이국밥 | Marsh snail soup |
| 다슬기국 | Marsh snail soup alias |
| 황태해장국 | Dried pollack soup |
| 굴국밥 | Oyster gukbap |
| 매생이국밥 | Seaweed soup with rice |
| 내장탕 | Offal soup |
| 양평해장국 | Yangpyeong-style hangover soup |
| 육개장 | Spicy beef soup |
| 닭개장 | Spicy chicken soup |
| 소고기무국 | Beef radish soup |
| 시래기국 | Dried radish greens soup |
| 우거지국 | Cabbage soup |
| 감자탕 | Pork backbone stew, may also map to stew/hotpot depending format |

AI notes:

- “국밥” strongly maps here.
- “감자탕” can be soup/stew family; store context matters.
- Soup categories are generally not default fast track unless packaging supports it.

---

## 13. L3: Gomtang / Seolleongtang / Galbitang

L3 code:

    KOREAN_GOMTANG_SEOLLEONGTANG_GALBITANG

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 설렁탕 | Seolleongtang |
| 곰탕 | Gomtang |
| 나주곰탕 | Naju gomtang |
| 꼬리곰탕 | Oxtail soup |
| 도가니탕 | Ox knee cartilage soup |
| 족탕 | Pork trotter soup |
| 갈비탕 | Short rib soup |
| 왕갈비탕 | Large short rib soup |
| 전복갈비탕 | Abalone short rib soup |
| 매운갈비탕 | Spicy short rib soup |
| 우족탕 | Beef foot soup |
| 수육국밥 | Suyuk gukbap |

AI notes:

- “탕” may also occur in seafood or pub contexts.
- Price range and menu grouping help classification.

---

## 14. L3: Samgyetang / Baeksuk / Duck

L3 code:

    KOREAN_SAMGYETANG_BAEKSUK_DUCK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 삼계탕 | Ginseng chicken soup |
| 들깨삼계탕 | Perilla samgyetang |
| 전복삼계탕 | Abalone samgyetang |
| 옻닭 | Lacquer chicken |
| 한방백숙 | Herbal boiled chicken |
| 능이버섯백숙 | Neungi mushroom baeksuk |
| 누룽지백숙 | Scorched rice baeksuk |
| 닭한마리 | Whole chicken soup |
| 오리백숙 | Duck baeksuk |
| 오리탕 | Duck soup |
| 능이오리백숙 | Neungi duck baeksuk |
| 닭곰탕 | Chicken gomtang |

AI notes:

- Long cooking time and reservation behavior may apply.
- Fast track default should usually be disabled unless pre-cooked and packaged.

---

## 15. L2: Jjigae / Jeongol / Jjageuli

L2 code:

    KOREAN_STEW_HOTPOT_JJAGEULI

This category includes Korean stews, hotpots, fish stews, budae-jjigae, and thick jjageuli-style stews.

---

## 16. L3: Jjigae

L3 code:

    KOREAN_JJIGAE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 김치찌개 | Kimchi stew |
| 돼지고기김치찌개 | Pork kimchi stew |
| 참치김치찌개 | Tuna kimchi stew |
| 꽁치김치찌개 | Pacific saury kimchi stew |
| 된장찌개 | Soybean paste stew |
| 차돌된장찌개 | Beef brisket soybean stew |
| 해물된장찌개 | Seafood soybean stew |
| 달래된장찌개 | Wild chive soybean stew |
| 순두부찌개 | Soft tofu stew |
| 해물순두부찌개 | Seafood soft tofu stew |
| 고기순두부찌개 | Meat soft tofu stew |
| 쫄면순두부 | Soft tofu stew with jjolmyeon |
| 청국장 | Fermented soybean stew |
| 비지찌개 | Soy pulp stew |
| 부대찌개 | Army stew |
| 고추장찌개 | Red pepper paste stew |
| 동태찌개 | Frozen pollack stew |
| 생태찌개 | Fresh pollack stew |
| 대구탕 | Cod soup/stew |
| 대구지리 | Clear cod soup |
| 알탕 | Fish roe soup |
| 조기찌개 | Yellow corvina stew |
| 갈치찌개 | Cutlassfish stew |
| 명란찌개 | Pollack roe stew |
| 두부찌개 | Tofu stew |

AI notes:

- “찌개” is strong match.
- “탕” and “지리” may overlap with soup.
- Customer-facing food temperature and packaging matter for fast track.

---

## 17. L3: Jeongol / Hotpot

L3 code:

    KOREAN_JEONGOL_HOTPOT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소불고기전골 | Beef bulgogi hotpot |
| 곱창전골 | Beef intestine hotpot |
| 낙지전골 | Octopus hotpot |
| 낙곱새전골 | Octopus, intestine, shrimp hotpot |
| 해물전골 | Seafood hotpot |
| 만두전골 | Dumpling hotpot |
| 두부전골 | Tofu hotpot |
| 버섯전골 | Mushroom hotpot |
| 부대전골 | Army hotpot |
| 군대전골 | Army hotpot alias |
| 샤브전골 | Shabu-style hotpot |
| 오뎅전골 | Fish cake hotpot |

AI notes:

- Jeongol often implies shared dish and table service.
- Fast track default should usually be disabled.

---

## 18. L3: Jjageuli / Thick Stew

L3 code:

    KOREAN_JJAGEULI

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 돼지고기짜글이 | Pork jjageuli |
| 스팸짜글이 | Spam jjageuli |
| 버섯짜글이 | Mushroom jjageuli |
| 김치짜글이 | Kimchi jjageuli |
| 두부짜글이 | Tofu jjageuli |
| 참치짜글이 | Tuna jjageuli |

AI notes:

- Often served with rice and may appear as set meal.
- KDS station may be hot station.

---

## 19. L2: Grill / Stir-Fry

L2 code:

    KOREAN_GRILL_STIRFRY

This category includes meat stir-fries, grilled meats, fish grills, seafood stir-fries, and spicy pan dishes.

---

## 20. L3: Meat Stir-Fry / Grill

L3 code:

    KOREAN_MEAT_STIRFRY_GRILL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 제육볶음 | Spicy pork stir-fry |
| 돼지불고기 | Pork bulgogi |
| 간장불고기 | Soy sauce bulgogi |
| 고추장불고기 | Spicy bulgogi |
| 소불고기 | Beef bulgogi |
| 오삼불고기 | Squid and pork bulgogi |
| 오징어제육볶음 | Squid and spicy pork stir-fry |
| 닭갈비 | Spicy stir-fried chicken |
| 춘천닭갈비 | Chuncheon dakgalbi |
| 닭똥집볶음 | Chicken gizzard stir-fry |
| 오리주물럭 | Duck jumulleok |
| 오리구이 | Grilled duck |
| 떡갈비 | Tteokgalbi |
| 바싹불고기 | Thin grilled bulgogi |
| LA갈비구이 | LA galbi |
| 고추장삼겹살 | Spicy pork belly |
| 두루치기 | Duruchigi |
| 주물럭 | Jumulleok |
| 낙삼볶음 | Octopus and pork belly stir-fry |

AI notes:

- Some grill items are table-cooked and should not be fast track default.
- Stir-fried single-portion dishes may be fast track candidate only after kitchen validation.

---

## 21. L3: Fish Grill

L3 code:

    KOREAN_FISH_GRILL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 고등어구이 | Grilled mackerel |
| 삼치구이 | Grilled Spanish mackerel |
| 갈치구이 | Grilled cutlassfish |
| 이면수구이 | Grilled atka mackerel |
| 임연수구이 | Alternative spelling |
| 굴비구이 | Grilled dried yellow corvina |
| 조기구이 | Grilled yellow corvina |
| 가자미구이 | Grilled flounder |
| 꽁치구이 | Grilled saury |
| 보리굴비 | Barley-dried yellow corvina |
| 생선구이모듬 | Assorted grilled fish |
| 연어구이 | Grilled salmon, Korean set context |
| 장어구이 | Grilled eel, may be separate specialty |

AI notes:

- Fish grill usually routes to grill station.
- Bones, smell, and packaging may affect fast track suitability.

---

## 22. L3: Seafood Stir-Fry / Spicy Seafood

L3 code:

    KOREAN_SEAFOOD_STIRFRY

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 오징어볶음 | Squid stir-fry |
| 낙지볶음 | Octopus stir-fry |
| 쭈꾸미볶음 | Webfoot octopus stir-fry |
| 문어볶음 | Octopus stir-fry |
| 홍어회무침 | Spicy skate salad |
| 골뱅이무침 | Spicy sea snail salad |
| 꼬막무침 | Seasoned cockle |
| 해물볶음 | Seafood stir-fry |
| 낙새볶음 | Octopus and shrimp stir-fry |
| 쭈삼볶음 | Webfoot octopus and pork belly stir-fry |

AI notes:

- “무침” may also map to side dish or pub.
- Store context and category grouping are important.

---

## 23. L2: Steamed / Braised / Suyuk

L2 code:

    KOREAN_STEAM_BRAISE_SUYUK

This category includes braised meat, steamed seafood, fish braise, and boiled meat dishes.

---

## 24. L3: Meat Braise / Steam

L3 code:

    KOREAN_MEAT_BRAISE_STEAM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 닭볶음탕 | Spicy braised chicken |
| 닭도리탕 | Alias |
| 찜닭 | Braised chicken |
| 안동찜닭 | Andong-style braised chicken |
| 간장찜닭 | Soy braised chicken |
| 매운찜닭 | Spicy braised chicken |
| 소갈비찜 | Braised beef short ribs |
| 돼지갈비찜 | Braised pork ribs |
| 매운갈비찜 | Spicy braised ribs |
| 묵은지갈비찜 | Aged kimchi rib braise |
| 등갈비찜 | Braised back ribs |
| 꼬리찜 | Braised oxtail |
| 도가니찜 | Braised ox knee |
| 김치찜 | Braised kimchi with meat |
| 묵은지찜 | Braised aged kimchi |

AI notes:

- Usually long prep and shared dish.
- Fast track default should be disabled unless portioned/prepared.

---

## 25. L3: Fish / Seafood Braise And Steam

L3 code:

    KOREAN_FISH_SEAFOOD_BRAISE_STEAM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 갈치조림 | Braised cutlassfish |
| 고등어조림 | Braised mackerel |
| 묵은지고등어조림 | Aged kimchi mackerel braise |
| 코다리조림 | Braised half-dried pollack |
| 명태조림 | Braised pollack |
| 동태조림 | Braised frozen pollack |
| 병어조림 | Braised butterfish |
| 아구찜 | Spicy steamed monkfish |
| 해물찜 | Spicy steamed seafood |
| 꽃게찜 | Steamed crab |
| 낙지찜 | Steamed octopus |
| 쭈꾸미찜 | Steamed webfoot octopus |
| 대구뽈찜 | Spicy steamed cod head |
| 대구머리찜 | Cod head steam alias |
| 가오리찜 | Steamed skate |
| 코다리찜 | Braised/steamed pollack |
| 해물갈비찜 | Seafood rib braise fusion |

AI notes:

- “찜” and “조림” can indicate high complexity.
- Usually not ideal for 5-minute fast track.

---

## 26. L3: Suyuk / Boiled Meat

L3 code:

    KOREAN_SUYUK_BOILED_MEAT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소고기수육 | Boiled beef slices |
| 돼지고기수육 | Boiled pork slices |
| 가브리살수육 | Boiled pork neck cut |
| 도가니수육 | Ox knee boiled meat |
| 머릿고기 | Boiled head meat |
| 편육 | Pressed boiled meat |
| 수육정식 | Suyuk set |
| 보쌈수육 | Boiled pork for bossam context |

AI notes:

- Suyuk may overlap with jokbal/bossam specialty.
- Store L1/subtype may refine later.

---

## 27. L2: Korean Noodles

L2 code:

    KOREAN_NOODLE

This category includes kalguksu, sujebi, Korean-style noodles, makguksu, cold noodles, and seasonal noodles.

---

## 28. L3: Kalguksu / Sujebi

L3 code:

    KOREAN_KALGUKSU_SUJEBI

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 바지락칼국수 | Clam kalguksu |
| 해물칼국수 | Seafood kalguksu |
| 사골칼국수 | Bone broth kalguksu |
| 멸치칼국수 | Anchovy broth kalguksu |
| 닭칼국수 | Chicken kalguksu |
| 얼큰칼국수 | Spicy kalguksu |
| 장칼국수 | Gochujang/doenjang kalguksu |
| 들깨칼국수 | Perilla kalguksu |
| 팥칼국수 | Red bean kalguksu |
| 항아리수제비 | Pot sujebi |
| 들깨수제비 | Perilla sujebi |
| 김치수제비 | Kimchi sujebi |
| 얼큰수제비 | Spicy sujebi |
| 감자수제비 | Potato sujebi |

AI notes:

- Hot noodle prep time depends on boiling and broth station.
- Fast track requires packaging validation.

---

## 29. L3: Korean Noodles

L3 code:

    KOREAN_GUKSU_MAKGUKSU

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 잔치국수 | Banquet noodles |
| 비빔국수 | Spicy mixed noodles |
| 열무국수 | Young radish kimchi noodles |
| 고기국수 | Meat noodles |
| 김치말이국수 | Kimchi cold noodles |
| 동치미국수 | Dongchimi cold noodles |
| 콩국수 | Soybean noodles |
| 메밀막국수 | Buckwheat makguksu |
| 물막국수 | Water makguksu |
| 비빔막국수 | Spicy makguksu |
| 회막국수 | Raw fish makguksu |
| 쟁반막국수 | Large platter makguksu |
| 초계국수 | Chilled chicken noodles |
| 골동면 | Mixed noodles |

AI notes:

- Cold noodle vs hot noodle affects KDS station and timing.
- Seasonal summer items should support seasonal tag.

---

## 30. L3: Korean Cold Noodles

L3 code:

    KOREAN_NAENGMYEON

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 물냉면 | Cold broth naengmyeon |
| 비빔냉면 | Spicy mixed naengmyeon |
| 회냉면 | Raw fish naengmyeon |
| 열무냉면 | Young radish kimchi naengmyeon |
| 육전냉면 | Naengmyeon with beef pancake |
| 평양냉면 | Pyongyang naengmyeon |
| 함흥냉면 | Hamheung naengmyeon |
| 진주냉면 | Jinju naengmyeon |
| 코다리냉면 | Pollack naengmyeon |
| 냉면사리 | Noodle add-on |

AI notes:

- Cold noodle specialty stores may need separate L1 subtype later.
- Fast track suitability depends on packaging and pickup timing.

---

## 31. L2: Side Dishes / Jeon / Pancakes

L2 code:

    KOREAN_SIDE_PANCAKE

This category includes Korean pancakes, egg dishes, dumplings, side dishes, and shared small plates.

---

## 32. L3: Jeon / Buchimgae

L3 code:

    KOREAN_JEON_BUCHIMGAE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 해물파전 | Seafood scallion pancake |
| 김치전 | Kimchi pancake |
| 감자전 | Potato pancake |
| 녹두빈대떡 | Mung bean pancake |
| 부추전 | Chive pancake |
| 호박전 | Zucchini pancake |
| 굴전 | Oyster pancake |
| 육전 | Beef pancake |
| 동태전 | Pollack pancake |
| 모듬전 | Assorted pancakes |
| 미나리전 | Water parsley pancake |
| 깻잎전 | Perilla leaf pancake |
| 두부전 | Tofu pancake |
| 동그랑땡 | Meat patty jeon |

AI notes:

- Pub category may also include jeon.
- Fry/pan station routing needed.

---

## 33. L3: Egg Dish

L3 code:

    KOREAN_EGG_DISH

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 계란말이 | Rolled omelet |
| 치즈계란말이 | Cheese rolled omelet |
| 왕계란말이 | Large rolled omelet |
| 계란찜 | Steamed egg |
| 폭탄계란찜 | Volcano steamed egg |
| 치즈계란찜 | Cheese steamed egg |
| 달걀찜 | Alternate spelling |
| 계란후라이 | Fried egg add-on |

AI notes:

- Often side or add-on.
- Fast track may be possible if kitchen process supports.

---

## 34. L3: Dumpling / Other Side

L3 code:

    KOREAN_DUMPLING_SIDE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 고기만두 | Meat dumplings |
| 김치만두 | Kimchi dumplings |
| 반반만두 | Half-and-half dumplings |
| 군만두 | Fried dumplings |
| 찐만두 | Steamed dumplings |
| 물만두 | Boiled dumplings |
| 두부김치 | Tofu with kimchi |
| 도토리묵무침 | Acorn jelly salad |
| 올갱이묵무침 | Marsh snail jelly salad |
| 잡채 | Japchae |
| 묵사발 | Cold acorn jelly soup |
| 우묵냉국 | Jelly cold soup |

AI notes:

- Dumplings may also appear in Chinese category.
- L1 context and surrounding menu items determine classification.

---

## 35. L2: Set Meal / Baekban / Course

L2 code:

    KOREAN_SET_MEAL

This category includes Korean set meals, baekban, grilled fish sets, ssambap sets, and hanjeongsik courses.

---

## 36. L3: Set Meal / Baekban

L3 code:

    KOREAN_SET_MEAL_BAEKBAN

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 가정식백반 | Home-style baekban |
| 매일백반 | Daily baekban |
| 제육정식 | Spicy pork set |
| 불고기정식 | Bulgogi set |
| 생선구이정식 | Grilled fish set |
| 보리굴비정식 | Barley-dried corvina set |
| 게장정식 | Marinated crab set |
| 간장게장정식 | Soy marinated crab set |
| 양념게장정식 | Spicy marinated crab set |
| 쌈밥정식 | Ssambap set |
| 곤드레정식 | Gondre rice set |
| 한정식코스 | Korean course |
| A코스 | Course A |
| B코스 | Course B |
| 특정식 | Special set |
| 오늘의정식 | Today’s set |
| 점심특선 | Lunch special |
| 직장인백반 | Office worker baekban |

AI notes:

- Set meal item may contain multiple components.
- POS/KDS mapping may require bundle/option structure.

---

## 37. Ambiguous Korean Menu Handling

Some Korean terms require context.

| Term | Possible Meaning |
|---|---|
| 탕 | Soup, stew, pub soup, seafood soup |
| 전골 | Hotpot/shared dish |
| 정식 | Set meal, course, combo |
| 덮밥 | Korean, Japanese, Asian rice bowl |
| 국수 | Korean noodle, Asian noodle |
| 만두 | Korean side, Chinese dimsum, bunsik |
| 무침 | Side dish, seafood salad, pub anju |
| 구이 | Table grill, fish grill, finished grilled dish |
| 찜 | Steamed dish, braised dish, shared dish |
| 볶음 | Stir-fry, side dish, main dish |

Ambiguous items must use L1 context, surrounding categories, price, option structure, and admin review.

---

## 38. Korean Food Fast Track Default Guidance

Candidate fast track suitability:

| Category | Default Guidance |
|---|---|
| Bibimbap | Review candidate |
| Rice bowl | Review candidate |
| Fried rice | Review candidate |
| Nutrition rice / ssambap | Usually review or disabled |
| Porridge | Review candidate if packaged |
| Gukbap / hot soup | Usually disabled unless packaged/prepared |
| Jjigae / jeongol | Usually disabled |
| Stir-fry single portion | Review candidate |
| Fish grill | Usually disabled or review |
| Braised/steamed shared dish | Usually disabled |
| Kalguksu / hot noodle | Review or disabled |
| Cold noodle | Review candidate |
| Jeon/pancake | Review candidate |
| Egg dish | Review candidate |
| Set meal / baekban | Usually disabled or special handling |

Fast track eligibility must be menu-specific and approved.

---

## 39. Korean Food KDS Station Candidate Matrix

Candidate station mapping:

| Category | KDS Station Candidate |
|---|---|
| Bibimbap | Rice/assembly station |
| Rice bowl | Rice/hot pan station |
| Porridge | Soup/porridge station |
| Gukbap/Tang | Soup station |
| Jjigae | Hot station |
| Jeongol | Hotpot/shared dish station |
| Stir-fry | Wok/pan station |
| Fish grill | Grill station |
| Braise/steam | Braise/hot station |
| Kalguksu/Sujebi | Noodle station |
| Cold noodle | Cold noodle station |
| Jeon | Pan/fry station |
| Egg dish | Side/pan station |
| Dumpling | Steam/fry station |
| Set meal | Assembly/packing plus component stations |

Store-specific station configuration must override defaults when needed.

---

## 40. Korean Food Classification Output Format

Recommended AI classification output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `l1_category` | `KOREAN_FOOD` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `matched_dictionary_terms` | Matched terms |
| `aliases_detected` | Alias terms |
| `price_candidate` | Price |
| `confidence` | Confidence score/class |
| `ambiguity_reason` | Ambiguity explanation |
| `fasttrack_default_candidate` | Candidate suitability |
| `kds_station_candidate` | Station |
| `cooking_time_default_candidate` | Prep time candidate |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output must remain draft until human confirmation.

---

## 41. Korean Food Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `KOREAN_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `KOREAN_MENU_AMBIGUOUS` | Ambiguous Korean menu detected |
| `KOREAN_MENU_L2_SUGGESTED` | L2 category suggested |
| `KOREAN_MENU_L3_SUGGESTED` | L3 category suggested |
| `KOREAN_MENU_LOW_CONFIDENCE` | Low confidence |
| `KOREAN_MENU_REVIEW_REQUIRED` | Human review required |
| `KOREAN_MENU_CATEGORY_CONFIRMED` | Category confirmed |
| `KOREAN_MENU_FASTTRACK_CANDIDATE_SUGGESTED` | Fast track candidate suggested |
| `KOREAN_MENU_KDS_STATION_SUGGESTED` | KDS station suggested |
| `KOREAN_MENU_DICTIONARY_TERM_UNKNOWN` | Unknown term detected |
| `KOREAN_MENU_DICTIONARY_TERM_ADDED` | Term added after review |

Events must route through `10610`.

---

## 42. Dictionary Governance Boundary

Dictionary updates must be governed.

Update actions:

- add new menu term
- add alias
- merge duplicate term
- change L2 category
- change L3 subcategory
- mark regional variant
- mark fast track candidate
- mark allergen candidate
- mark cooking time candidate
- deprecate term

Dictionary change requires:

- reason
- scope
- reviewer
- taxonomy version
- audit
- rollback path

Dictionary is platform knowledge.

It must not be silently mutated by AI.

---

## 43. Relationship To AI Menu Intake

This document supports:

- category context selection
- OCR/LLM parsing
- structured menu draft
- split-view review
- category confidence
- cooking time prefill
- KDS station recommendation
- fast track candidate recommendation
- validation
- deployment readiness

Korean dictionary output remains draft until approved.

---

## 44. Relationship To Fast Track

Korean Food classification informs fast track readiness but does not decide it.

Fast track approval still requires:

- cooking time confirmation
- packaging suitability
- freshness window
- KDS station readiness
- inventory reliability
- no-show waste risk
- store-specific operational proof
- policy version
- manager/HQ approval where needed

Korean menu term match is not fast track authority.

---

## 45. Anti-Patterns

Avoid:

- treating this dictionary as exhaustive forever
- AI inventing unseen menu categories instead of review
- deploying low-confidence Korean menu classification
- using menu name match to skip price review
- auto-enabling fast track from category
- using soup/stew defaults for all stores equally
- ignoring regional names and aliases
- treating set meal as single simple item without component review
- mapping all “탕” to one category without context
- treating customer-facing category label as internal KDS routing
- letting AI mutate dictionary without review

These anti-patterns must be blocked in future runtime design.

---

## 46. Runtime Deferral

This document defines Korean Food menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- embedding index implementation
- OCR implementation
- LLM prompt implementation
- AI classification runtime
- Korean menu matching engine
- admin review UI
- taxonomy versioning runtime
- KDS station mapping runtime
- cooking time engine
- fast track eligibility engine
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 47. Validation Checklist

Validation must confirm:

1. Korean Food dictionary scope is defined.
2. Classification depth is defined.
3. L2 category overview is defined.
4. Rice/Bibimbap/Porridge L2 is defined.
5. Bibimbap L3 is defined.
6. Rice Bowl/Fried Rice L3 is defined.
7. Nutrition Rice/Ssambap L3 is defined.
8. Porridge L3 is defined.
9. Gukbap/Tang/Baeksuk L2 is defined.
10. Gukbap/Hangover Soup L3 is defined.
11. Gomtang/Seolleongtang/Galbitang L3 is defined.
12. Samgyetang/Baeksuk/Duck L3 is defined.
13. Jjigae/Jeongol/Jjageuli L2 is defined.
14. Jjigae L3 is defined.
15. Jeongol/Hotpot L3 is defined.
16. Jjageuli L3 is defined.
17. Grill/Stir-Fry L2 is defined.
18. Meat Stir-Fry/Grill L3 is defined.
19. Fish Grill L3 is defined.
20. Seafood Stir-Fry L3 is defined.
21. Steamed/Braised/Suyuk L2 is defined.
22. Meat Braise/Steam L3 is defined.
23. Fish/Seafood Braise/Steam L3 is defined.
24. Suyuk/Boiled Meat L3 is defined.
25. Korean Noodles L2 is defined.
26. Kalguksu/Sujebi L3 is defined.
27. Korean Noodles/Makguksu L3 is defined.
28. Korean Cold Noodles L3 is defined.
29. Side/Jeon/Pancake L2 is defined.
30. Jeon/Buchimgae L3 is defined.
31. Egg Dish L3 is defined.
32. Dumpling/Other Side L3 is defined.
33. Set Meal/Baekban/Course L2 is defined.
34. Set Meal/Baekban L3 is defined.
35. Ambiguous Korean menu handling is defined.
36. Fast track default guidance is defined.
37. KDS station candidate matrix is defined.
38. Classification output format is defined.
39. Event catalog is defined.
40. Dictionary governance boundary is defined.
41. Relationships to AI Menu Intake and Fast Track are defined.
42. Anti-patterns are listed.
43. Coding remains unauthorized.
44. Runtime remains deferred.

---

## 48. Relationship To Previous Documents

This document supplements:

- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`

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

- `10706 Korean Meat Grill Specialty Menu Taxonomy Policy`
- `10707 Japanese Seafood Sushi Menu Taxonomy Policy`
- `10708 Chinese Food Menu Taxonomy Policy`
- `10709 Cafe Dessert Beverage Menu Taxonomy Policy`
- `10710 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 49. Final Rule

Korean Food menu classification must use a deeper dictionary because Korean menus are broad, regional, and ambiguous.

AI may match extracted menu text to L2 and L3 Korean menu categories, recommend KDS station, cooking time, and fast track suitability, and mark confidence.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, and rollback remain mandatory before deployment.

Unknown or ambiguous Korean menu terms must route to review.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.