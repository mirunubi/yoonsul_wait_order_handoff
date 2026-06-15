# 40007_Policy_Korean_Meat_Grill_BBQ_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary

## 1. Purpose

This document defines the Korean Meat Grill and BBQ Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `40006 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded the general Korean food dictionary.

This document expands the `MEAT_GRILL_BBQ` category as a specialized Korean restaurant type because meat/grill menus have unique structures that ordinary Korean food classification does not handle well:

- gram-based menu pricing
- minimum first-order quantity
- per-person serving rules
- set and platter menus
- unlimited refill menus
- raw meat cut names
- seasoned meat cut names
- pork, beef, entrails, chicken, lamb, duck, and specialty grill categories
- grill-side meals such as after-meal noodles, stew, fried rice, and rice
- grill extras such as mushrooms, cheese, vegetables, and side dishes
- alcohol and table-service context
- higher payment amount and higher dispute impact

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Meat/grill menus require a specialized AI dictionary.

The correct rule is:

A meat/grill store is not a generic Korean restaurant for menu parsing.  
Gram unit, serving unit, first-order rule, and set composition must be parsed separately.  
Side meals in a BBQ restaurant are not always main menu categories.  
AI must distinguish meat item, side meal, grill extra, alcohol, set, refill, and notice text.  
AI must not confuse “first order 3 servings minimum” with a menu item.  
AI must not treat gram weight as price.  
AI must not treat raw meat cut names as prepared dish names without context.  
AI may recommend category and attributes, but human review remains mandatory before deployment.  

Meat/grill menu classification affects POS, KDS, inventory, table service, pricing, settlement, customer display, and fast track eligibility.

---

## 3. Classification Scope

This registry applies to:

- Korean BBQ restaurants
- pork BBQ restaurants
- beef BBQ restaurants
- entrails/gopchang restaurants
- lamb skewer restaurants
- charcoal chicken grill restaurants
- duck grill restaurants
- unlimited refill meat restaurants
- grill pub hybrid restaurants
- meat plus meal set stores
- menu board OCR/AI parsing
- POS/KDS menu mapping
- inventory cut mapping
- gram/serving parsing
- first-order rule extraction
- set menu parsing
- fast track suitability review
- no-show/waste cost estimation
- customer display grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Meat/Grill category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Meat / Grill / BBQ | `MEAT_GRILL_BBQ` |
| `L2_MENU_CATEGORY` | Major grill family | Pork BBQ |
| `L3_MENU_SUBCATEGORY` | Specific cut/menu subfamily | Fresh pork cut |
| `ITEM_ATTRIBUTE` | Weight, serving, seasoning, set, refill, side | 180g, first order 3 servings |

Item attributes are especially important in this category.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `BBQ_PORK` | Pork BBQ |
| `BBQ_BEEF` | Beef BBQ |
| `BBQ_ENTRAILS` | Gopchang / Makchang / Entrails |
| `BBQ_SPECIALTY_MEAT` | Specialty Meat / Chicken / Lamb / Duck |
| `BBQ_SIDE_MEAL` | BBQ Side Meals |
| `BBQ_EXTRA_APPETIZER` | Grill Extras / Appetizers |
| `BBQ_SET_REFILL` | Set / Platter / Unlimited Refill |
| `BBQ_ALCOHOL_DRINK` | Alcohol / Drinks |
| `BBQ_NOTICE_RULE` | Order Rules / Notices |

Notice/rule text must be separated from menu items.

---

## 6. L2: Pork BBQ

L2 code:

    BBQ_PORK

This category includes fresh pork cuts, frozen pork cuts, seasoned pork, aged pork, pork skin, and pork mixed platters.

---

## 7. L3: Fresh Pork Cuts

L3 code:

    BBQ_PORK_FRESH_CUT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 삼겹살 | Pork belly |
| 눈꽃삼겹살 | Snowflake pork belly |
| 칼집삼겹살 | Scored pork belly |
| 대패삼겹살 | Thin frozen pork belly |
| 오겹살 | Five-layer pork belly |
| 목살 | Pork neck |
| 목소금구이 | Salt-grilled pork neck |
| 항정살 | Pork jowl |
| 천겹살 | Pork jowl alias/marketing term |
| 가브리살 | Pork cheek/neck cut |
| 등심덧살 | Garbri alias |
| 갈매기살 | Pork skirt meat |
| 뒷고기 | Assorted back cuts |
| 덜미살 | Pork neck/back cut |
| 꼬들살 | Crunchy pork cut |
| 뽈살 | Pork cheek |
| 돼지모듬구이 | Assorted pork grill |
| 돈마호크 | Pork tomahawk |
| 통삼겹 | Whole pork belly |
| 생삼겹 | Fresh pork belly |
| 생목살 | Fresh pork neck |

AI notes:

- “대패삼겹살” may be frozen/thin but still pork cut.
- “목살” may appear as standalone or in set.
- Weight and serving count must be parsed separately.

---

## 8. L3: Seasoned / Aged Pork Cuts

L3 code:

    BBQ_PORK_SEASONED_AGED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 돼지갈비 | Pork ribs |
| 양념돼지갈비 | Seasoned pork ribs |
| 매운돼지갈비 | Spicy pork ribs |
| 고추장삼겹살 | Spicy gochujang pork belly |
| 간장삼겹살 | Soy pork belly |
| 냉동삼겹살 | Frozen pork belly |
| 냉삼 | Frozen pork belly abbreviation |
| 숙성삼겹살 | Aged pork belly |
| 숙성목살 | Aged pork neck |
| 양념목살 | Seasoned pork neck |
| 껍데기 | Pork skin |
| 돼지껍데기 | Pork skin |
| 벌집껍데기 | Honeycomb-cut pork skin |
| 양념껍데기 | Seasoned pork skin |
| 매운껍데기 | Spicy pork skin |

AI notes:

- Pork skin is grill extra or pork subcategory depending menu layout.
- “냉삼” is important abbreviation.
- Seasoning affects inventory and prep mapping.

---

## 9. L2: Beef BBQ

L2 code:

    BBQ_BEEF

This category includes Korean beef, fresh beef cuts, raw beef dishes, seasoned beef, imported beef cuts, and beef platters.

---

## 10. L3: Hanwoo / Fresh Beef Cuts

L3 code:

    BBQ_BEEF_FRESH_HANWOO

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 등심 | Sirloin |
| 꽃등심 | Marbled sirloin |
| 안심 | Tenderloin |
| 갈비살 | Rib finger meat |
| 본살 | Rib meat/cut term |
| 살치살 | Chuck flap tail |
| 안창살 | Outside skirt |
| 토시살 | Hanging tender |
| 제비추리 | Thin flank/neck cut |
| 치마살 | Skirt meat |
| 부채살 | Flat iron |
| 낙엽살 | Flat iron alias |
| 차돌박이 | Beef brisket |
| 우삼겹 | Thin beef belly/brisket |
| 육회 | Beef tartare |
| 육사시미 | Raw beef slices |
| 뭉티기 | Daegu-style raw beef |
| 소한마리 | Assorted beef platter |
| 한우모듬 | Assorted Hanwoo |
| 한우등심 | Hanwoo sirloin |
| 한우갈비살 | Hanwoo rib finger |
| 한우안심 | Hanwoo tenderloin |

AI notes:

- Raw beef items require food safety and raw item notice.
- Beef cut names often appear without “구이”.
- “한우” prefix may indicate premium/grade and pricing.

---

## 11. L3: Seasoned / Imported Beef Cuts

L3 code:

    BBQ_BEEF_SEASONED_IMPORTED

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소양념갈비 | Seasoned beef ribs |
| 이동갈비 | Idong-style ribs |
| 수원왕갈비 | Suwon king ribs |
| LA갈비 | LA-style ribs |
| 소주물럭 | Seasoned beef jumulleok |
| 주물럭 | Seasoned meat, context required |
| 양념갈비살 | Seasoned rib finger |
| 네모안창살 | Square-cut skirt meat |
| 양념소갈비 | Seasoned beef ribs |
| 우대갈비 | Beef rib steak |
| 꽃갈비 | Premium ribs |
| 본갈비 | Rib cut |
| 늑간살 | Intercostal meat |
| 토마호크 | Tomahawk steak, grill context |
| 와규 | Wagyu |
| 블랙앵거스 | Black Angus |

AI notes:

- Imported/premium terms may affect price and POS category.
- “토마호크” may be steak or BBQ depending store context.

---

## 12. L2: Gopchang / Makchang / Entrails

L2 code:

    BBQ_ENTRAILS

This category includes beef entrails, pork entrails, grilled intestines, tripe, and mixed entrail platters.

---

## 13. L3: Beef Entrails

L3 code:

    BBQ_BEEF_ENTRAILS

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소곱창 | Beef small intestine |
| 한우곱창 | Hanwoo gopchang |
| 소대창 | Beef large intestine |
| 대창 | Large intestine |
| 막창 | Makchang, context may be beef or pork |
| 소막창 | Beef makchang |
| 특양 | First stomach/tripe |
| 염통 | Heart |
| 양깃머리 | Beef tripe cut |
| 모듬곱창구이 | Assorted grilled entrails |
| 곱창모듬 | Assorted gopchang |
| 곱창전골 | Hotpot, may be side/meal depending layout |
| 곱창구이 | Grilled gopchang |
| 대창구이 | Grilled daechang |
| 막창구이 | Grilled makchang |

AI notes:

- “곱창전골” is hotpot, not grill item unless listed under meals.
- Entrails often have strong side meal linkage such as 볶음밥.

---

## 14. L3: Pork Entrails

L3 code:

    BBQ_PORK_ENTRAILS

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 돼지막창 | Pork makchang |
| 대구막창 | Daegu-style makchang |
| 불막창 | Spicy makchang |
| 양념막창 | Seasoned makchang |
| 돼지곱창 | Pork intestine |
| 야채곱창구이 | Vegetable pork intestine grill |
| 곱창볶음 | Stir-fried intestine |
| 순대곱창 | Sundae and gopchang |
| 막창모듬 | Assorted makchang |
| 돼지특수부위 | Pork specialty cuts |

AI notes:

- Pork entrails overlap with stir-fry/pub categories.
- Store category and surrounding menu determine final mapping.

---

## 15. L2: Specialty Meat / Chicken / Lamb / Duck

L2 code:

    BBQ_SPECIALTY_MEAT

This category includes chicken grill, lamb, duck, and other specialty grilled meats.

---

## 16. L3: Chicken Grill

L3 code:

    BBQ_CHICKEN_GRILL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 숯불닭갈비 | Charcoal grilled dakgalbi |
| 양념닭갈비 | Seasoned chicken ribs |
| 간장닭갈비 | Soy chicken ribs |
| 닭목살구이 | Grilled chicken neck |
| 닭안창살구이 | Grilled chicken skirt |
| 닭발구이 | Grilled chicken feet |
| 똥집구이 | Grilled gizzard |
| 닭똥집구이 | Grilled chicken gizzard |
| 닭날개구이 | Grilled chicken wings |
| 닭다리살구이 | Grilled chicken thigh |
| 닭꼬치 | Chicken skewer |
| 닭모듬구이 | Assorted chicken grill |

AI notes:

- Chicken grill differs from stir-fried 닭갈비 in general Korean food.
- Charcoal context matters.

---

## 17. L3: Lamb / Mutton Grill

L3 code:

    BBQ_LAMB_GRILL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 양꼬치 | Lamb skewers |
| 양갈비 | Lamb ribs |
| 숄더랙 | Shoulder rack |
| 프렌치랙 | French rack |
| 양고기구이 | Grilled lamb |
| 양등심 | Lamb loin |
| 양갈비살 | Lamb rib meat |
| 양다리 | Lamb leg |
| 양모듬 | Assorted lamb |
| 마라양꼬치 | Mala lamb skewers |
| 고급양갈비 | Premium lamb ribs |

AI notes:

- Lamb stores often have Chinese/Asian side menus.
- Alcohol and skewer count parsing may be needed.

---

## 18. L3: Duck / Other Specialty Grill

L3 code:

    BBQ_DUCK_OTHER_GRILL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 오리구이 | Grilled duck |
| 유황오리숯불구이 | Sulfur duck charcoal grill |
| 오리로스 | Duck roast slices |
| 오리주물럭 | Seasoned duck jumulleok |
| 훈제오리 | Smoked duck |
| 오리불고기 | Duck bulgogi |
| 말고기구이 | Horse meat, rare/specialty |
| 흑염소구이 | Black goat grill |
| 토끼구이 | Rabbit grill, rare/specialty |

AI notes:

- Some items may be regional or specialty.
- Review required for rare categories.

---

## 19. L2: BBQ Side Meals

L2 code:

    BBQ_SIDE_MEAL

These are meal/after-meal items in BBQ restaurants.

They may look like ordinary Korean main dishes but should be classified as BBQ side meals when L1 is Meat/Grill.

---

## 20. L3: BBQ After-Meal Noodles

L3 code:

    BBQ_SIDE_NOODLE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 후식물냉면 | After-meal cold broth noodles |
| 후식비빔냉면 | After-meal spicy cold noodles |
| 고깃집냉면 | BBQ house naengmyeon |
| 물냉면 | May be side meal in BBQ context |
| 비빔냉면 | May be side meal in BBQ context |
| 김치말이국수 | Kimchi cold noodles |
| 멸치국수 | Anchovy noodles |
| 잔치국수 | Banquet noodles |
| 라면 | Ramen |
| 땡초라면 | Spicy chili ramen |
| 짜파게티 | Jjapaghetti |
| 비빔면 | Bibim noodles |
| 열무국수 | Young radish noodles |
| 된장라면 | Soybean paste ramen |

AI notes:

- “후식” prefix strongly indicates side meal.
- Noodle items affect KDS hot/cold station but not main meat category.

---

## 21. L3: BBQ Stew / Soup Side Meal

L3 code:

    BBQ_SIDE_STEW_SOUP

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 고깃집된장찌개 | BBQ house soybean stew |
| 된장찌개 | Side stew in BBQ context |
| 차돌된장찌개 | Brisket soybean stew |
| 해물된장찌개 | Seafood soybean stew |
| 후식된장 | After-meal doenjang |
| 김치찌개 | Kimchi stew |
| 돼지김치찌개 | Pork kimchi stew |
| 순두부찌개 | Soft tofu stew |
| 청국장 | Fermented soybean stew |
| 누룽지탕 | Scorched rice soup |
| 계란탕 | Egg soup |
| 어묵탕 | Fish cake soup, pub/grill context |
| 된장술밥 | Soybean soup rice |
| 술밥 | Soup rice, BBQ context |

AI notes:

- In BBQ store context, stew is often side/meal, not main stew category.
- “된장술밥” is an important BBQ-specific item.

---

## 22. L3: BBQ Rice / Fried Rice Side Meal

L3 code:

    BBQ_SIDE_RICE_FRIED_RICE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 날치알볶음밥 | Flying fish roe fried rice |
| 셀프볶음밥 | Self fried rice |
| 치즈볶음밥 | Cheese fried rice |
| 철판볶음밥 | Iron plate fried rice |
| 볶음밥 | Fried rice |
| 옛날도시락 | Old-school lunchbox |
| 추억의도시락 | Old-school lunchbox alias |
| 공기밥 | Bowl of rice |
| 영양솥밥 | Nutrition pot rice |
| 김가루밥 | Seaweed rice |
| 주먹밥 | Rice balls |
| 계란밥 | Egg rice |
| 된장밥 | Soybean stew rice |
| 누룽지 | Scorched rice |

AI notes:

- Rice add-ons are often not standalone main dishes.
- POS mapping may treat them as side/add-on category.

---

## 23. L2: Grill Extras / Appetizers

L2 code:

    BBQ_EXTRA_APPETIZER

This category includes grill extras, toppings, side dishes, and appetizers.

---

## 24. L3: Grill Add-Ons / Toppings

L3 code:

    BBQ_EXTRA_GRILL_TOPPING

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 모듬버섯구이 | Assorted mushrooms |
| 버섯추가 | Mushroom add-on |
| 새송이버섯 | King oyster mushroom |
| 구워먹는치즈 | Grill cheese |
| 치즈추가 | Cheese add-on |
| 미나리추가 | Water parsley add-on |
| 고사리추가 | Bracken add-on |
| 콩나물추가 | Bean sprout add-on |
| 김치추가 | Kimchi add-on |
| 소시지구이 | Grilled sausage |
| 떡사리 | Rice cake add-on |
| 파인애플구이 | Grilled pineapple |
| 마늘추가 | Garlic add-on |
| 쌈채소추가 | Lettuce/greens add-on |
| 파채추가 | Scallion salad add-on |

AI notes:

- “추가” usually indicates add-on, not main menu.
- Add-ons may not require KDS ticket or may route to service station.

---

## 25. L3: BBQ Side Appetizers

L3 code:

    BBQ_EXTRA_SIDE_DISH

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 계란찜 | Steamed egg |
| 폭탄계란찜 | Volcano steamed egg |
| 치즈계란찜 | Cheese steamed egg |
| 콘치즈 | Corn cheese |
| 김치전 | Kimchi pancake |
| 묵사발 | Acorn jelly cold soup |
| 육회 | Beef tartare, may be beef main/raw side |
| 육사시미 | Raw beef slices |
| 해장라면 | Ramen side |
| 감자튀김 | Fries, pub hybrid |
| 양념게장 | Spicy marinated crab side |
| 간장게장 | Soy marinated crab side |
| 명이나물추가 | Pickled leaf add-on |

AI notes:

- Some items can be high-price side items.
- Raw beef may belong to Beef BBQ if main section.

---

## 26. L2: Set / Platter / Unlimited Refill

L2 code:

    BBQ_SET_REFILL

This category includes set menus, platters, combos, unlimited refill, and per-person pricing.

---

## 27. L3: BBQ Set / Platter

L3 code:

    BBQ_SET_PLATTER

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 커플세트 | Couple set |
| 가족세트 | Family set |
| 삼목세트 | Pork belly + pork neck set |
| 돈한마리세트 | Whole pork set |
| 한우모듬세트 | Assorted Hanwoo set |
| A세트 | Set A |
| B세트 | Set B |
| 모듬세트 | Assorted set |
| 돼지한판 | Pork platter |
| 소한판 | Beef platter |
| 한판세트 | Platter set |
| 스페셜세트 | Special set |
| 갈비세트 | Rib set |
| 곱창모듬세트 | Gopchang set |
| 양꼬치세트 | Lamb skewer set |

AI notes:

- Set composition must be parsed as bundle/components when possible.
- Set price is not per item price unless specified.

---

## 28. L3: Unlimited Refill / Course

L3 code:

    BBQ_UNLIMITED_REFILL_COURSE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 무한리필삼겹살 | Unlimited pork belly |
| 고기무한리필 | Unlimited meat |
| 무한리필돼지갈비 | Unlimited pork ribs |
| 무한리필소고기 | Unlimited beef |
| 무한리필양꼬치 | Unlimited lamb skewers |
| 성인 | Adult price |
| 초등 | Elementary child price |
| 유아 | Toddler price |
| 어린이 | Child price |
| 런치무한리필 | Lunch unlimited refill |
| 디너무한리필 | Dinner unlimited refill |
| 평일런치 | Weekday lunch |
| 주말디너 | Weekend dinner |
| 코스 | Course |
| 시간제한 | Time limit notice |

AI notes:

- Adult/child/time labels are pricing classes, not menu items by themselves.
- Time-limit text must be classified as rule/notice.

---

## 29. L2: Alcohol / Drinks

L2 code:

    BBQ_ALCOHOL_DRINK

Alcohol and drinks are common in BBQ menus.

They must be separated from food items for legal, age, and POS mapping reasons.

---

## 30. L3: BBQ Alcohol / Drinks

L3 code:

    BBQ_ALCOHOL_DRINK_ITEM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소주 | Soju |
| 맥주 | Beer |
| 생맥주 | Draft beer |
| 병맥주 | Bottled beer |
| 막걸리 | Makgeolli |
| 청하 | Cheongha |
| 백세주 | Baekseju |
| 복분자 | Bokbunja wine |
| 하이볼 | Highball |
| 위스키 | Whisky |
| 와인 | Wine |
| 사케 | Sake |
| 콜라 | Cola |
| 사이다 | Cider/sprite |
| 환타 | Fanta |
| 탄산수 | Sparkling water |
| 생수 | Bottled water |
| 음료수 | Soft drink |

AI notes:

- Alcohol requires legal/age policy.
- Drink category may not route to KDS kitchen station.

---

## 31. L2: Order Rules / Notices

L2 code:

    BBQ_NOTICE_RULE

This category is not a menu item category.

It captures ordering rules and menu board notices.

---

## 32. L3: Serving / Weight / Minimum Order Notice

L3 code:

    BBQ_NOTICE_SERVING_WEIGHT_RULE

Seed notice patterns:

| Pattern | Meaning |
|---|---|
| 1인분 | Serving unit |
| 2인분 이상 주문 | Minimum 2 servings |
| 첫 주문 3인분부터 | First order minimum 3 servings |
| 기본 5인분 | Default/minimum 5 servings |
| 추가 주문 1인분 가능 | Add-on order rule |
| 100g | Gram unit |
| 120g | Gram unit |
| 150g | Gram unit |
| 180g | Gram unit |
| 200g | Gram unit |
| 국내산 | Origin notice |
| 한우 | Beef grade/source |
| 미국산 | Origin notice |
| 호주산 | Origin notice |
| 원산지 표시 | Origin notice |
| 상차림비 | Table setting fee |
| 숯불추가 | Charcoal extra |
| 시간제한 | Time limit |
| 남은 음식 포장 불가 | Leftover packaging rule |

AI notes:

- Notice text must not become menu item.
- Gram unit and serving rule must attach to nearby menu item when possible.

---

## 33. Gram And Serving Parsing Boundary

Meat/grill parser must extract:

- weight amount
- weight unit
- serving count
- price
- menu item
- minimum order rule
- add-on order rule
- table setting fee
- set composition
- origin label
- price per serving
- price per gram if shown
- option/extra marker

Example:

    삼겹살 180g 15,000원

Should parse as:

| Field | Value |
|---|---|
| menu_name | 삼겹살 |
| weight_amount | 180 |
| weight_unit | g |
| price | 15000 |

Example:

    첫 주문은 3인분부터 가능합니다

Should parse as:

| Field | Value |
|---|---|
| notice_type | minimum_first_order |
| minimum_servings | 3 |
| applies_to | context or section |

Notice is not menu item.

---

## 34. Meat Menu Attribute Boundary

Meat menu items may include:

- meat type: pork, beef, chicken, lamb, duck, other
- cut name
- fresh/frozen/aged/seasoned
- origin
- grade
- weight per serving
- serving unit
- minimum order
- add-on allowed
- grill method
- table-cooked or kitchen-cooked
- set/platter membership
- inventory cut mapping
- KDS station
- prep handling
- fast track suitability
- raw/rare notice if applicable

Meat attributes matter for POS, inventory, and customer display.

---

## 35. BBQ Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Raw table-cooked pork/beef | Usually not fast track food pickup |
| Grilled-to-go meat portion | Review candidate only |
| Set/platter raw grill | Usually disabled |
| Unlimited refill | Disabled |
| Side noodles | Review candidate |
| Stew/soup side | Review candidate or disabled |
| Fried rice/side rice | Review candidate |
| Grill extras | Not standalone fast track unless packaged |
| Drinks | May be eligible if non-alcohol and policy allows |
| Alcohol | Not fast track unless age/legal/payment policy allows |
| Raw beef | Usually disabled |

Fast track is generally not default for table-grill experiences.

---

## 36. BBQ KDS Station Candidate Matrix

Candidate station mapping:

| Category | KDS/Service Station Candidate |
|---|---|
| Pork BBQ | Meat service / grill prep |
| Beef BBQ | Meat service / premium cut prep |
| Entrails | Entrails prep / grill station |
| Chicken grill | Grill station |
| Lamb grill | Skewer/grill station |
| Duck grill | Grill station |
| Noodles | Noodle/cold station |
| Stew/soup | Hot station |
| Fried rice | Table/fry/rice station |
| Grill extras | Service/side station |
| Drinks | Beverage/cashier station |
| Set/platter | Meat service plus components |
| Unlimited refill | Service flow, not single KDS item |

Store configuration must override defaults.

---

## 37. POS Mapping Boundary

BBQ POS mapping must handle:

- gram/serving price
- per-person price
- adult/child price
- set/platter components
- unlimited refill course
- table setting fee
- charcoal fee
- add-on items
- alcohol
- origin/grade labels
- discount exclusions
- refund/cancel rules
- inventory deduction
- tax category
- service charge if applicable

POS mapping requires human verification.

AI must not finalize financial mapping.

---

## 38. Customer Display Boundary

Customer-facing BBQ menu must distinguish:

- main meat
- set/platter
- unlimited refill
- side meals
- extras
- drinks/alcohol
- notices
- minimum order rules
- gram/serving unit
- origin labels if required
- table cooking note
- fast track availability if any

Notices must be visually separated from menu items.

---

## 39. BBQ Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `l1_category` | `MEAT_GRILL_BBQ` |
| `l2_category` | Major BBQ category |
| `l3_subcategory` | Subcategory |
| `meat_type` | Pork, beef, entrails, chicken, lamb, duck |
| `cut_name` | Cut |
| `seasoning_state` | Fresh, seasoned, aged, frozen |
| `weight_amount` | Gram amount |
| `weight_unit` | Unit |
| `serving_rule` | Serving/minimum rule |
| `price_candidate` | Price |
| `notice_candidate` | Rule notice if not menu |
| `set_components` | Set components if detected |
| `origin_candidate` | Origin if shown |
| `confidence` | Confidence |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output is draft until human confirmation.

---

## 40. BBQ Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `BBQ_MENU_DICTIONARY_MATCHED` | BBQ dictionary match found |
| `BBQ_GRAM_UNIT_DETECTED` | Gram unit detected |
| `BBQ_SERVING_RULE_DETECTED` | Serving/minimum rule detected |
| `BBQ_NOTICE_TEXT_DETECTED` | Notice/rule text detected |
| `BBQ_MENU_ITEM_SUGGESTED` | Menu item suggested |
| `BBQ_SET_COMPONENT_DETECTED` | Set component detected |
| `BBQ_UNLIMITED_REFILL_DETECTED` | Unlimited refill detected |
| `BBQ_ALCOHOL_ITEM_DETECTED` | Alcohol item detected |
| `BBQ_LOW_CONFIDENCE` | Low confidence |
| `BBQ_REVIEW_REQUIRED` | Review required |
| `BBQ_CATEGORY_CONFIRMED` | Category confirmed |
| `BBQ_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `BBQ_FASTTRACK_DISABLED_BY_DEFAULT` | Fast track disabled by default |

Events must route through `10610`.

---

## 41. Dictionary Governance Boundary

BBQ dictionary updates must be governed.

Update actions:

- add meat cut term
- add alias
- add regional cut name
- change meat type
- change L2/L3 category
- add gram parsing pattern
- add serving notice pattern
- mark fast track guidance
- mark POS/inventory mapping risk
- deprecate term

Dictionary update requires:

- reason
- reviewer
- taxonomy version
- audit
- rollback path

AI may suggest dictionary additions.

AI must not mutate dictionary automatically.

---

## 42. Relationship To AI Menu Intake

This document supports:

- business category context
- OCR/LLM menu extraction
- gram/serving parsing
- notice separation
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- KDS/service station recommendation
- fast track default guidance
- validation and deployment readiness

BBQ classification output remains draft until approved.

---

## 43. Relationship To Fast Track

Meat/grill category is generally not default fast track.

Fast track may apply only to limited cases:

- prepacked side meal
- packaged lunch meat bowl
- non-alcohol beverage
- prepared takeaway grill portion
- approved store-specific fast track menu

Raw table-grill, unlimited refill, set/platter, alcohol, and shared grill experiences are generally disabled unless separate policy approves.

Fast track eligibility must be explicitly reviewed.

---

## 44. Relationship To Inventory And Loss

BBQ category is inventory-sensitive.

Inventory mapping may include:

- meat cut
- origin
- grade
- gram weight
- serving count
- yield/loss rate
- aging state
- frozen/fresh state
- side meal ingredients
- alcohol/drink stock
- waste class
- no-show loss risk

Wrong parsing can distort COGS, inventory, and profitability.

---

## 45. Anti-Patterns

Avoid:

- treating gram notice as menu name
- treating first-order rule as menu item
- treating side 냉면 as main Korean noodle category in BBQ context
- auto-enabling fast track for raw grill meat
- ignoring alcohol/legal separation
- mapping adult/child unlimited refill price as ordinary menu item
- losing set/platter component structure
- treating weight as price
- treating price as weight
- ignoring origin/grade labels
- using AI category match to finalize POS price
- hardcoding one gram size for all stores
- treating Web menu display as inventory deduction rule
- allowing store manager to hide minimum order notice without review

These anti-patterns must be blocked in future runtime design.

---

## 46. Runtime Deferral

This document defines Korean Meat/Grill BBQ menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- gram parsing runtime
- serving rule parser
- AI classification runtime
- POS mapping runtime
- inventory mapping runtime
- customer display implementation
- KDS station mapping implementation
- fast track eligibility runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 47. Validation Checklist

Validation must confirm:

1. Classification scope is defined.
2. Classification depth is defined.
3. L2 category overview is defined.
4. Pork BBQ L2 is defined.
5. Fresh pork cuts L3 is defined.
6. Seasoned/aged pork cuts L3 is defined.
7. Beef BBQ L2 is defined.
8. Hanwoo/fresh beef cuts L3 is defined.
9. Seasoned/imported beef cuts L3 is defined.
10. Entrails L2 is defined.
11. Beef entrails L3 is defined.
12. Pork entrails L3 is defined.
13. Specialty meat L2 is defined.
14. Chicken grill L3 is defined.
15. Lamb grill L3 is defined.
16. Duck/other specialty grill L3 is defined.
17. BBQ side meal L2 is defined.
18. BBQ after-meal noodles L3 is defined.
19. BBQ stew/soup side meal L3 is defined.
20. BBQ rice/fried rice side meal L3 is defined.
21. Grill extras/appetizers L2 is defined.
22. Grill add-ons/toppings L3 is defined.
23. BBQ side appetizers L3 is defined.
24. Set/platter/unlimited refill L2 is defined.
25. BBQ set/platter L3 is defined.
26. Unlimited refill/course L3 is defined.
27. Alcohol/drink L2 is defined.
28. Alcohol/drink item L3 is defined.
29. Notice/rule L2 is defined.
30. Serving/weight/minimum order notice L3 is defined.
31. Gram and serving parsing boundary is defined.
32. Meat menu attribute boundary is defined.
33. Fast track default guidance is defined.
34. KDS station candidate matrix is defined.
35. POS mapping boundary is defined.
36. Customer display boundary is defined.
37. Classification output format is defined.
38. Event catalog is defined.
39. Dictionary governance boundary is defined.
40. Relationships to AI Menu Intake, Fast Track, and Inventory/Loss are defined.
41. Anti-patterns are listed.
42. Coding remains unauthorized.
43. Runtime remains deferred.

---

## 48. Relationship To Previous Documents

This document supplements:

- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `40006 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

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
- `40006 Korean Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy`

It prepares possible future documents:

- `40008 Japanese Seafood Sushi Menu Taxonomy Policy`
- `40009 Chinese Food Menu Taxonomy Policy`
- `40010 Cafe Dessert Beverage Menu Taxonomy Policy`
- `40011 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 49. Final Rule

Meat/grill menu classification must treat gram unit, serving unit, first-order rule, set composition, refill pricing, side meals, alcohol, and notices as first-class parsing targets.

AI may match meat cut names, side meals, set menus, refill rules, weight units, serving constraints, POS mapping risks, KDS/service station candidates, and fast track guidance.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS mapping verification, and rollback remain mandatory before deployment.

Fast track must be disabled by default for raw table-grill and unlimited refill experiences unless a separate approved policy enables specific packaged items.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.