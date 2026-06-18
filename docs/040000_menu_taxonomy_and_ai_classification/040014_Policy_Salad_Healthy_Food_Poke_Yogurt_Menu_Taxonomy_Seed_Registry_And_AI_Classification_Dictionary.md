# 040014_Policy_Salad_Healthy_Food_Poke_Yogurt_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary

## 1. Purpose

This document defines the Salad, Healthy Food, Poke, Warm Bowl, Healthy Sandwich, Wrap, Greek Yogurt, Oatmeal, Diet Meal, Clean Drink, Dressing, Base, Topping, and Nutrition-Aware Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `40013 Cafe Dessert Beverage Bakery Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded cafe, coffee, tea, beverage, bakery, dessert, bingsu, ice cream, HOT/ICE, size, decaf, milk, topping, and bakery unit parsing.

This document expands the `SALAD_HEALTHY_FOOD` category because salad and wellness menus have a different order structure from ordinary Western or bunsik menus:

- base selection
- protein topping
- grain/rice/noodle base
- dressing selection
- add-on toppings
- calorie display
- macro/nutrition-like claims
- healthy sandwich and wrap options
- Greek yogurt bowl composition
- overnight oatmeal and chia pudding
- diet lunchbox and keto menu
- clean juice and protein drink
- vegan/vegetarian/low-calorie/high-protein claim risks
- strong fast track potential with option complexity

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Salad and healthy food menu parsing must be option-tree aware.

The correct rule is:

Base, protein, topping, dressing, and add-ons are order option groups, not ordinary menu rows by default.  
Kcal is nutrition information, not price.  
Protein grams and calories must not be mistaken for price or serving size.  
Vegan, keto, low-calorie, high-protein, and clean claims require review.  
AI may recommend classification and option structure, but human review remains mandatory for price, nutrition, allergen, health claim, fast track, POS, and customer-facing deployment.  
A salad menu is not merely Western salad; it is a customizable assembly model.  

This category is highly suitable for fast track only when base/topping/dressing complexity is controlled.

---

## 3. Classification Scope

This registry applies to:

- salad restaurants
- poke restaurants
- warm bowl restaurants
- diet meal stores
- wellness food stores
- Greek yogurt stores
- oatmeal/overnight oat shops
- healthy sandwich shops
- wrap shops
- clean juice shops
- protein shake shops
- vegan/vegetarian stores
- keto menu stores
- low-calorie meal prep stores
- menu board OCR/AI parsing
- base option parsing
- topping option parsing
- dressing option parsing
- kcal/nutrition parsing
- POS/KDS mapping
- fast track suitability review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Salad/Healthy Food category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Salad / Healthy Food | `SALAD_HEALTHY_FOOD` |
| `L2_MENU_CATEGORY` | Major family | Salad / Bowl |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Chicken salad |
| `ITEM_ATTRIBUTE` | Base, protein, dressing, topping, kcal, macro | 현미밥, 닭가슴살, 오리엔탈, 320kcal |

Option and nutrition attributes are mandatory in this category.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `HEALTH_SALAD_BOWL` | Salad / Bowl |
| `HEALTH_POKE_WARM_BOWL` | Poke / Warm Bowl / Grain Bowl |
| `HEALTH_SANDWICH_WRAP` | Healthy Sandwich / Wrap |
| `HEALTH_YOGURT_OATS` | Greek Yogurt / Oats |
| `HEALTH_DIET_MEAL_DRINK` | Diet Meals / Clean Drinks |
| `HEALTH_DRESSING_TOPPING` | Dressings / Toppings / Add-Ons |
| `HEALTH_NOTICE_OPTION_NUTRITION_RULE` | Base / Dressing / Kcal / Nutrition Notice Rules |

Notice, nutrition, and option rules must be separated from menu items.

---

## 6. L2: Salad / Bowl

L2 code:

    HEALTH_SALAD_BOWL

This category includes chicken, meat, seafood, cheese, egg, vegan, mushroom, tofu, pumpkin, sweet potato, and green salad bowls.

---

## 7. L3: Chicken / Meat Topping Salad

L3 code:

    HEALTH_SALAD_CHICKEN_MEAT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 닭가슴살샐러드 | Chicken breast salad |
| 수비드닭가슴살샐러드 | Sous-vide chicken breast salad |
| 닭다리살샐러드 | Chicken thigh salad |
| 우삼겹샐러드 | Beef brisket salad |
| 비프스테이크샐러드 | Beef steak salad |
| 목살샐러드 | Pork neck salad |
| 오리훈제샐러드 | Smoked duck salad |
| 텐더샐러드 | Chicken tender salad |
| 베이컨샐러드 | Bacon salad |
| 불고기샐러드 | Bulgogi salad |
| 닭갈비샐러드 | Dakgalbi salad |
| 터키샐러드 | Turkey salad |
| 햄치즈샐러드 | Ham cheese salad |
| 프로틴샐러드 | Protein salad, review required |

AI notes:

- Protein type affects inventory, prep time, and nutrition claims.
- “프로틴” claim should be reviewed before customer-facing use.

---

## 8. L3: Seafood / Fish Topping Salad

L3 code:

    HEALTH_SALAD_SEAFOOD_FISH

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 연어샐러드 | Salmon salad |
| 훈제연어샐러드 | Smoked salmon salad |
| 아보카도연어샐러드 | Avocado salmon salad |
| 쉬림프샐러드 | Shrimp salad |
| 새우샐러드 | Shrimp salad Korean label |
| 갈릭버터쉬림프샐러드 | Garlic butter shrimp salad |
| 오징어샐러드 | Squid salad |
| 참치샐러드 | Tuna salad |
| 크랩샐러드 | Crab salad |
| 게살샐러드 | Crab meat salad |
| 문어샐러드 | Octopus salad |
| 해산물샐러드 | Seafood salad |
| 아히참치샐러드 | Ahi tuna salad |
| 명란샐러드 | Pollack roe salad |

AI notes:

- Seafood allergen candidates must be suggested.
- Raw or smoked fish freshness review may be required.

---

## 9. L3: Cheese / Egg / Vegan / Vegetable Salad

L3 code:

    HEALTH_SALAD_CHEESE_EGG_VEGAN

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 리코타치즈샐러드 | Ricotta cheese salad |
| 모짜렐라보울 | Mozzarella bowl |
| 카프레제샐러드 | Caprese salad |
| 구운버섯샐러드 | Grilled mushroom salad |
| 두부버섯샐러드 | Tofu mushroom salad |
| 두부면샐러드 | Tofu noodle salad |
| 단호박샐러드 | Sweet pumpkin salad |
| 고구마샐러드 | Sweet potato salad |
| 템페샐러드 | Tempeh salad |
| 비건보울 | Vegan bowl |
| 그린샐러드 | Green salad |
| 기본야채샐러드 | Basic vegetable salad |
| 계란샐러드 | Egg salad |
| 아보카도샐러드 | Avocado salad |
| 병아리콩샐러드 | Chickpea salad |
| 렌틸콩샐러드 | Lentil salad |
| 퀴노아샐러드 | Quinoa salad |
| 콥샐러드 | Cobb salad |

AI notes:

- Vegan/vegetarian claims require review.
- Cheese/egg/dairy allergen candidates must be suggested.
- Tofu and tempeh may require soy allergen candidate.

---

## 10. L2: Poke / Warm Bowl / Grain Bowl

L2 code:

    HEALTH_POKE_WARM_BOWL

This category includes seafood poke, meat warm bowls, grain bowls, tofu/tempeh bowls, vegan bowls, and fusion healthy bowls.

---

## 11. L3: Seafood-Based Poke

L3 code:

    HEALTH_POKE_SEAFOOD

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 연어포케 | Salmon poke |
| 스파이시연어포케 | Spicy salmon poke |
| 참치포케 | Tuna poke |
| 마구로포케 | Maguro poke |
| 간장새우포케 | Soy-marinated shrimp poke |
| 문어포케 | Octopus poke |
| 쭈꾸미포케 | Webfoot octopus poke |
| 쉬림프포케 | Shrimp poke |
| 아히포케 | Ahi poke |
| 스파이시참치포케 | Spicy tuna poke |
| 연어아보카도포케 | Salmon avocado poke |
| 해산물포케 | Seafood poke |
| 명란포케 | Pollack roe poke |

AI notes:

- Raw fish and seafood allergen review may be required.
- Poke base and dressing must be parsed as options.

---

## 12. L3: Meat / Fusion Warm Bowl

L3 code:

    HEALTH_WARM_BOWL_MEAT_FUSION

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 우삼겹웜볼 | Beef brisket warm bowl |
| 비프포케 | Beef poke |
| 칠리베이컨웜볼 | Chili bacon warm bowl |
| 닭다리살포케 | Chicken thigh poke |
| 제육현미포케 | Spicy pork brown rice poke |
| 오리훈제웜볼 | Smoked duck warm bowl |
| 닭가슴살웜볼 | Chicken breast warm bowl |
| 수비드치킨웜볼 | Sous-vide chicken warm bowl |
| 불고기웜볼 | Bulgogi warm bowl |
| 목살웜볼 | Pork neck warm bowl |
| 스테이크웜볼 | Steak warm bowl |
| 치킨데리야끼볼 | Chicken teriyaki bowl |
| 차돌현미볼 | Beef brisket brown rice bowl |

AI notes:

- Warm bowl requires hot/cold component separation.
- Meat topping affects KDS station and prep time.

---

## 13. L3: Tofu / Tempeh / Vegan Poke

L3 code:

    HEALTH_POKE_TOFU_TEMPEH_VEGAN

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 구운두부포케 | Grilled tofu poke |
| 템페포케 | Tempeh poke |
| 아보카도버섯포케 | Avocado mushroom poke |
| 낫또포케 | Natto poke |
| 비건포케 | Vegan poke |
| 두부버섯포케 | Tofu mushroom poke |
| 병아리콩포케 | Chickpea poke |
| 렌틸콩포케 | Lentil poke |
| 팔라펠포케 | Falafel poke |
| 그린포케 | Green poke |
| 단호박두부포케 | Pumpkin tofu poke |

AI notes:

- Vegan claim must be verified.
- Soy and legume allergen candidates should be suggested.

---

## 14. L2: Healthy Sandwich / Wrap

L2 code:

    HEALTH_SANDWICH_WRAP

This category includes whole wheat/rye sandwiches, thick sandwiches, club-style sandwiches, tortilla wraps, taco wraps, and salad wraps.

---

## 15. L3: Whole Wheat / Rye Sandwich

L3 code:

    HEALTH_SANDWICH_WHOLEWHEAT_RYE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 닭가슴살샌드위치 | Chicken breast sandwich |
| 햄치즈호밀샌드위치 | Ham cheese rye sandwich |
| 에그마요샌드위치 | Egg mayo sandwich |
| 아보카도샌드위치 | Avocado sandwich |
| 단호박범벅샌드위치 | Sweet pumpkin mash sandwich |
| 바질토마토샌드위치 | Basil tomato sandwich |
| 웰빙야채샌드위치 | Wellness vegetable sandwich |
| 뚱샌드위치 | Thick sandwich |
| 클럽샌드위치 | Club sandwich |
| 통밀샌드위치 | Whole wheat sandwich |
| 호밀샌드위치 | Rye sandwich |
| 치킨텐더샌드위치 | Chicken tender sandwich |
| 연어샌드위치 | Salmon sandwich |
| 리코타샌드위치 | Ricotta sandwich |
| 크랜베리치킨샌드위치 | Cranberry chicken sandwich |

AI notes:

- Bread type, protein, and spread may be attributes.
- Sandwich has strong fast track potential.

---

## 16. L3: Tortilla Wrap / Taco Wrap

L3 code:

    HEALTH_WRAP_TORTILLA_TACO

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 치킨텐더랩 | Chicken tender wrap |
| 연어랩 | Salmon wrap |
| 우삼겹랩 | Beef brisket wrap |
| 멕시칸랩 | Mexican wrap |
| 쉬림프랩 | Shrimp wrap |
| 에그베이컨랩 | Egg bacon wrap |
| 샐러드랩 | Salad wrap |
| 야채랩 | Vegetable wrap |
| 닭가슴살랩 | Chicken breast wrap |
| 불고기랩 | Bulgogi wrap |
| 아보카도랩 | Avocado wrap |
| 두부랩 | Tofu wrap |
| 또띠아랩 | Tortilla wrap |
| 타코랩 | Taco wrap |

AI notes:

- Wraps overlap with Mexican and Western categories.
- In health context, base/protein/dressing attributes must be preserved.

---

## 17. L2: Greek Yogurt / Oats

L2 code:

    HEALTH_YOGURT_OATS

This category includes Greek yogurt, yogurt bowls, granola bowls, fruit yogurt bowls, overnight oatmeal, chia pudding, and related breakfast bowls.

---

## 18. L3: Greek Yogurt

L3 code:

    HEALTH_GREEK_YOGURT

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 플레인그릭요거트 | Plain Greek yogurt |
| 그릭요거트 | Greek yogurt |
| 딸기그릭요거트 | Strawberry Greek yogurt |
| 블루베리그릭요거트 | Blueberry Greek yogurt |
| 두유그릭요거트 | Soy Greek yogurt |
| 가당그릭요거트 | Sweetened Greek yogurt |
| 무당그릭요거트 | Unsweetened Greek yogurt |
| 저지방그릭요거트 | Low-fat Greek yogurt |
| 수제그릭요거트 | Homemade Greek yogurt |
| 꾸덕그릭요거트 | Thick Greek yogurt |
| 요거트컵 | Yogurt cup |
| 그릭요거트컵 | Greek yogurt cup |

AI notes:

- Dairy or soy allergen candidates must be suggested.
- Sweetened/unsweetened is an attribute.

---

## 19. L3: Yogurt Bowl

L3 code:

    HEALTH_YOGURT_BOWL

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 그래놀라요거트볼 | Granola yogurt bowl |
| 꿀자몽그릭볼 | Honey grapefruit Greek bowl |
| 트리플베리요거트볼 | Triple berry yogurt bowl |
| 바나나카카오그릭볼 | Banana cacao Greek bowl |
| 청포도코코넛그릭볼 | Green grape coconut Greek bowl |
| 딸기그래놀라볼 | Strawberry granola bowl |
| 블루베리그래놀라볼 | Blueberry granola bowl |
| 망고요거트볼 | Mango yogurt bowl |
| 아사이볼 | Acai bowl |
| 과일요거트볼 | Fruit yogurt bowl |
| 프로틴요거트볼 | Protein yogurt bowl |
| 견과요거트볼 | Nut yogurt bowl |

AI notes:

- Granola, nuts, fruit, and honey may be toppings.
- Protein claim requires review.

---

## 20. L3: Oatmeal / Chia Seed

L3 code:

    HEALTH_OATMEAL_CHIA

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 오버나이트오트밀 | Overnight oatmeal |
| 오오오 | Overnight oatmeal abbreviation |
| 바나나피넛버터오트밀 | Banana peanut butter oatmeal |
| 베리오트밀 | Berry oatmeal |
| 치아씨드푸딩 | Chia seed pudding |
| 초코오트밀 | Chocolate oatmeal |
| 애플시나몬오트밀 | Apple cinnamon oatmeal |
| 그래놀라오트밀 | Granola oatmeal |
| 프로틴오트밀 | Protein oatmeal |
| 오트밀볼 | Oatmeal bowl |
| 무가당오트밀 | Unsweetened oatmeal |
| 두유오트밀 | Soy milk oatmeal |

AI notes:

- Oat, peanut, soy, dairy, nut allergen candidates must be suggested.
- Nutrition claims require review.

---

## 21. L2: Diet Meals / Clean Drinks

L2 code:

    HEALTH_DIET_MEAL_DRINK

This category includes diet lunchboxes, brown rice meals, keto meals, tofu meals, chicken breast meals, clean juices, protein shakes, kombucha, and wellness drinks.

---

## 22. L3: Brown Rice Lunchbox / Keto Meal

L3 code:

    HEALTH_DIET_LUNCHBOX_KETO

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 현미밥닭가슴살도시락 | Brown rice chicken breast lunchbox |
| 곤약볶음밥 | Konjac fried rice |
| 키토김밥 | Keto gimbap |
| 계란지단김밥 | Egg sheet gimbap |
| 묵은지키토김밥 | Aged kimchi keto gimbap |
| 연두부정식 | Soft tofu set |
| 닭가슴살스테이크정식 | Chicken breast steak set |
| 다이어트도시락 | Diet lunchbox |
| 저칼로리도시락 | Low-calorie lunchbox |
| 단백질도시락 | Protein lunchbox |
| 현미도시락 | Brown rice lunchbox |
| 곤약면도시락 | Konjac noodle lunchbox |
| 두부면도시락 | Tofu noodle lunchbox |
| 샐러드도시락 | Salad lunchbox |

AI notes:

- Keto/low-calorie/protein claims require review.
- Lunchbox items may be stock-ready and fast track candidates.

---

## 23. L3: Clean Juice / Protein Drink

L3 code:

    HEALTH_CLEAN_JUICE_PROTEIN_DRINK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| ABC주스 | Apple beet carrot juice |
| 사과비트당근주스 | ABC juice expanded |
| 그린클렌즈주스 | Green cleanse juice |
| 케일사과주스 | Kale apple juice |
| 해독주스 | Detox juice |
| 토마토바나나주스 | Tomato banana juice |
| 프로틴쉐이크 | Protein shake |
| 초코프로틴쉐이크 | Chocolate protein shake |
| 곡물프로틴쉐이크 | Grain protein shake |
| 아몬드브리즈 | Almond Breeze |
| 콤부차 | Kombucha |
| 레몬콤부차 | Lemon kombucha |
| 베리콤부차 | Berry kombucha |
| 클렌즈주스 | Cleanse juice |
| 착즙주스 | Cold-pressed juice |
| 디톡스주스 | Detox juice |
| 그린주스 | Green juice |
| 비트주스 | Beet juice |
| 셀러리주스 | Celery juice |

AI notes:

- Detox/cleanse claims are sensitive and must be reviewed.
- Protein and health claims require approval before customer-facing display.

---

## 24. L2: Dressings / Toppings / Add-Ons

L2 code:

    HEALTH_DRESSING_TOPPING

This category includes dressings, sauces, base options, protein add-ons, grain add-ons, vegetable add-ons, egg add-ons, nuts, seeds, snacks, and specialty toppings.

These should generally become option groups under salad/poke/bowl menus, not standalone tabs.

---

## 25. L3: Dressing / Sauce

L3 code:

    HEALTH_DRESSING_SAUCE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 오리엔탈드레싱 | Oriental dressing |
| 발사믹드레싱 | Balsamic dressing |
| 크리미칠리소스 | Creamy chili sauce |
| 스파이시마요 | Spicy mayo |
| 시저드레싱 | Caesar dressing |
| 흑임자드레싱 | Black sesame dressing |
| 유자폰즈 | Yuzu ponzu |
| 참깨드레싱 | Sesame dressing |
| 허니머스타드 | Honey mustard |
| 랜치드레싱 | Ranch dressing |
| 레몬드레싱 | Lemon dressing |
| 올리브오일 | Olive oil |
| 비네그레트 | Vinaigrette |
| 칠리소스 | Chili sauce |
| 바질페스토 | Basil pesto |
| 소스 따로 | Sauce on the side |
| 소스 많이 | Extra sauce |
| 소스 적게 | Less sauce |

AI notes:

- Dressing should be an option group.
- Sesame, dairy, egg, mustard allergens may apply.

---

## 26. L3: Base / Protein / Main Topping Add-On

L3 code:

    HEALTH_BASE_PROTEIN_TOPPING_ADDON

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 연어추가 | Add salmon |
| 우삼겹추가 | Add beef brisket |
| 닭가슴살추가 | Add chicken breast |
| 아보카도추가 | Add avocado |
| 호밀빵추가 | Add rye bread |
| 현미밥추가 | Add brown rice |
| 채소믹스추가 | Add greens mix |
| 계란추가 | Add egg |
| 삶은계란추가 | Add boiled egg |
| 수란추가 | Add poached egg |
| 두부추가 | Add tofu |
| 템페추가 | Add tempeh |
| 새우추가 | Add shrimp |
| 참치추가 | Add tuna |
| 닭다리살추가 | Add chicken thigh |
| 고구마추가 | Add sweet potato |
| 단호박추가 | Add pumpkin |
| 병아리콩추가 | Add chickpeas |
| 퀴노아추가 | Add quinoa |
| 파스타면추가 | Add pasta noodle |
| 메밀면추가 | Add buckwheat noodle |
| 곡물밥추가 | Add grain rice |

AI notes:

- Base/protein add-ons must bind to eligible parent menus.
- Protein add-on affects prep time and inventory.

---

## 27. L3: Snack / Nut / Seed Topping Add-On

L3 code:

    HEALTH_SNACK_NUT_SEED_TOPPING

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 그래놀라추가 | Add granola |
| 구운아몬드 | Roasted almonds |
| 아몬드추가 | Add almonds |
| 코코넛청 | Coconut preserve |
| 코코넛칩 | Coconut chips |
| 청크초콜릿 | Chunk chocolate |
| 초콜릿칩 | Chocolate chips |
| 치아씨드 | Chia seed |
| 대마종자유 | Hemp seed oil |
| 햄프씨드 | Hemp seed |
| 올리브추가 | Add olives |
| 옥수수콘추가 | Add corn |
| 할라피뇨추가 | Add jalapeños |
| 크랜베리추가 | Add cranberries |
| 건포도추가 | Add raisins |
| 해바라기씨 | Sunflower seeds |
| 호두추가 | Add walnuts |
| 캐슈넛추가 | Add cashews |
| 피칸추가 | Add pecans |
| 땅콩추가 | Add peanuts |

AI notes:

- Nut/seed allergens must be suggested.
- Some toppings are yogurt-specific rather than salad-specific.

---

## 28. L2: Base / Dressing / Kcal / Nutrition Notice Rules

L2 code:

    HEALTH_NOTICE_OPTION_NUTRITION_RULE

This category is not a normal menu item category.

It captures base selection, topping selection, dressing selection, kcal, nutrition, diet claim, and customization notices.

---

## 29. L3: Base / Custom Option Patterns

L3 code:

    HEALTH_NOTICE_BASE_CUSTOM_PATTERN

Seed patterns:

| Pattern | Meaning |
|---|---|
| 베이스 선택 | Base selection |
| 채소만 | Greens-only base |
| 현미밥+채소 | Brown rice + greens base |
| 곡물밥+채소 | Grain rice + greens base |
| 파스타+채소 | Pasta + greens base |
| 메밀면+채소 | Buckwheat noodle + greens base |
| 두부면+채소 | Tofu noodle + greens base |
| 콜리플라워라이스 | Cauliflower rice |
| 귀리밥 | Oat rice base |
| 야채믹스 | Vegetable mix |
| 토핑 선택 | Topping selection |
| 드레싱 선택 | Dressing selection |
| 소스 선택 | Sauce selection |
| 무료 토핑 | Free topping |
| 유료 토핑 | Paid topping |
| 단백질 추가 | Protein add-on |
| 빵 추가 | Bread add-on |
| 밥 추가 | Rice add-on |
| 노드레싱 | No dressing |
| 소스 따로 | Sauce on the side |
| 소스 많이 | Extra sauce |
| 소스 적게 | Less sauce |

AI notes:

- Base/dressing/topping patterns must become option groups.
- Do not create separate menu tabs for every base.

---

## 30. L3: Kcal / Nutrition / Health Claim Patterns

L3 code:

    HEALTH_NOTICE_KCAL_NUTRITION_PATTERN

Seed patterns:

| Pattern | Meaning |
|---|---|
| kcal | Calorie marker |
| Kcal | Calorie marker |
| 칼로리 | Calorie marker |
| 320kcal | Calorie value example |
| 단백질 | Protein marker |
| protein | Protein marker |
| g단백질 | Protein gram marker |
| 저칼로리 | Low-calorie claim |
| 고단백 | High-protein claim |
| 저탄수 | Low-carb claim |
| 키토 | Keto claim |
| 비건 | Vegan claim |
| 채식 | Vegetarian claim |
| 글루텐프리 | Gluten-free claim |
| 무가당 | Unsweetened claim |
| 무설탕 | Sugar-free claim |
| 클렌즈 | Cleanse claim |
| 디톡스 | Detox claim |
| 다이어트 | Diet claim |
| 벌크업 | Bulk-up claim |
| 린매스 | Lean mass claim |

AI notes:

- Kcal numbers must not be parsed as price.
- Health claims require review before customer-facing use.

---

## 31. Kcal And Nutrition Parsing Boundary

Parser must separate calories and nutrition from price.

Example:

    수비드 닭가슴살 샐러드 (320kcal) - 10,900원

Should parse as:

| Field | Value |
|---|---|
| menu_name | 수비드 닭가슴살 샐러드 |
| kcal | 320 |
| price | 10900 |

Example:

    프로틴쉐이크 단백질 25g 6,500원

Should parse as:

| Field | Value |
|---|---|
| menu_name | 프로틴쉐이크 |
| protein_grams | 25 |
| price | 6500 |

Kcal, grams, and nutrition markers are not price.

---

## 32. Base And Topping Option Tree Boundary

Salad/poke parser must create option-tree candidates.

Recommended option tree:

    Base Selection
      - Greens only
      - Brown rice + greens
      - Grain rice + greens
      - Pasta + greens
      - Buckwheat noodle + greens
      - Tofu noodle + greens

    Main Protein
      - Chicken breast
      - Salmon
      - Shrimp
      - Beef brisket
      - Tofu
      - Tempeh

    Dressing
      - Oriental
      - Balsamic
      - Caesar
      - Sesame
      - Yuzu ponzu
      - Spicy mayo

    Add-On Toppings
      - Avocado
      - Egg
      - Sweet potato
      - Granola
      - Nuts
      - Corn
      - Jalapeño

This structure must be reviewable in admin UI.

---

## 33. Dressing And Topping Binding Boundary

Parser must bind options to eligible parent families.

Likely binding:

| Option | Likely Parent |
|---|---|
| Dressing | Salad, poke, warm bowl, wrap |
| Base selection | Salad, poke, warm bowl |
| Protein add-on | Salad, poke, bowl, wrap |
| Granola | Yogurt, oatmeal, some salad |
| Nuts/seeds | Salad, yogurt, oatmeal |
| Sauce on the side | Salad, poke, wrap |
| Bread add-on | Salad, soup set, sandwich |
| Rice add-on | Bowl, warm bowl |
| Avocado add-on | Salad, poke, sandwich, wrap |
| Egg add-on | Salad, poke, sandwich, diet meal |

Binding must remain reviewable.

---

## 34. Healthy Food Menu Attribute Boundary

Menu items may include:

- base type
- protein type
- dressing
- topping/add-on flag
- calorie
- protein grams
- carbohydrate indicator
- diet claim
- vegan/vegetarian claim
- keto claim
- gluten-free claim
- spicy marker
- hot/cold component
- packaging type
- freshness window
- fast track suitability
- KDS assembly station
- POS option group
- allergen candidates
- health claim review state
- parent option binding

Attributes must be reviewed before live deployment.

---

## 35. Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Salad | Strong candidate |
| Poke | Strong candidate if raw/freshness controlled |
| Warm bowl | Review candidate |
| Sandwich | Strong candidate |
| Wrap | Strong candidate |
| Greek yogurt | Strong candidate if stock-ready |
| Yogurt bowl | Strong candidate |
| Oatmeal | Review candidate |
| Diet lunchbox | Strong candidate if stock-ready |
| Keto gimbap | Review candidate |
| Clean juice | Strong candidate if stock-ready |
| Protein shake | Strong candidate |
| Dressings/toppings | Add-on only |

Fast track is strong only if customization is controlled and freshness is protected.

---

## 36. KDS / Assembly Station Candidate Matrix

Candidate station mapping:

| Category | Station Candidate |
|---|---|
| Salad | Salad assembly station |
| Poke | Poke/cold assembly station |
| Warm bowl | Hot/cold bowl assembly station |
| Sandwich | Sandwich station |
| Wrap | Wrap station |
| Greek yogurt | Yogurt/dessert station |
| Yogurt bowl | Yogurt assembly station |
| Oatmeal | Breakfast/oat station |
| Diet lunchbox | Stock/packing station |
| Clean juice | Juice station |
| Protein shake | Blender/shake station |
| Dressing/topping | Parent assembly station |
| Add-on base | Parent assembly or rice station |

Store configuration must override defaults.

---

## 37. POS Mapping Boundary

Salad/healthy POS mapping must handle:

- base menu
- base option
- protein option
- dressing option
- topping/add-on option
- calorie/nutrition display
- health claim status
- vegan/keto/gluten-free display state
- set components
- stock-ready item
- raw seafood flag
- cold chain flag
- packaging option
- coupon/loyalty eligibility
- refund/cancel rule
- inventory deduction
- tax category

POS mapping requires human verification.

AI must not finalize option price or health-claim mapping.

---

## 38. Customer Display Boundary

Customer-facing healthy food menu must distinguish:

- salad
- poke
- warm bowl
- sandwich
- wrap
- Greek yogurt
- oatmeal
- diet meal
- clean drink
- dressings
- toppings
- base options
- nutrition information if approved
- health/diet claims if approved
- allergen notices if approved
- fast track availability if approved

Option-heavy display must remain clear and not duplicate every topping as main menu.

---

## 39. Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `display_name_original` | Original display |
| `l1_category` | `SALAD_HEALTHY_FOOD` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `base_options` | Greens/rice/noodle/base options |
| `protein_candidate` | Chicken, salmon, shrimp, tofu, etc. |
| `dressing_options` | Dressing candidates |
| `topping_options` | Add-on candidates |
| `nutrition_candidates` | kcal/protein/carb/etc. |
| `health_claim_candidates` | Vegan/keto/low-calorie/etc. |
| `allergen_candidates` | Egg, dairy, soy, nuts, seafood, wheat |
| `price_candidate` | Numeric price |
| `option_price_candidates` | Option prices |
| `fasttrack_default_candidate` | Candidate suitability |
| `kds_station_candidate` | Station |
| `confidence` | Confidence |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output is draft until human confirmation.

---

## 40. Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `HEALTH_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `HEALTH_BASE_OPTION_DETECTED` | Base option detected |
| `HEALTH_DRESSING_OPTION_DETECTED` | Dressing option detected |
| `HEALTH_TOPPING_ADDON_DETECTED` | Topping/add-on detected |
| `HEALTH_KCAL_DETECTED` | Kcal marker detected |
| `HEALTH_PROTEIN_GRAMS_DETECTED` | Protein grams detected |
| `HEALTH_CLAIM_DETECTED` | Health claim detected |
| `HEALTH_ALLERGEN_CANDIDATE_DETECTED` | Allergen candidate detected |
| `HEALTH_OPTION_TREE_CREATED` | Option tree candidate created |
| `HEALTH_LOW_CONFIDENCE` | Low confidence |
| `HEALTH_REVIEW_REQUIRED` | Human review required |
| `HEALTH_CATEGORY_CONFIRMED` | Category confirmed |
| `HEALTH_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `HEALTH_FASTTRACK_REVIEW_REQUIRED` | Fast track review required |
| `HEALTH_CLAIM_REVIEW_REQUIRED` | Health claim review required |

Events must route through `10610`.

---

## 41. Dictionary Governance Boundary

Salad/healthy food dictionary updates must be governed.

Update actions:

- add salad term
- add poke term
- add warm bowl term
- add sandwich/wrap term
- add yogurt/oat term
- add diet meal term
- add clean drink term
- add dressing term
- add base option pattern
- add topping/add-on pattern
- add kcal/nutrition pattern
- add health claim pattern
- change L2/L3 category
- mark allergen candidate
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

## 42. Relationship To AI Menu Intake

This document supports:

- business category context
- OCR/LLM extraction
- base option parsing
- dressing option parsing
- topping/add-on parsing
- kcal/nutrition parsing
- health claim review
- structured option tree creation
- split-view review
- category confidence
- POS mapping warning
- KDS station recommendation
- fast track default guidance
- validation and deployment readiness

Salad/healthy food classification output remains draft until approved.

---

## 43. Relationship To Fast Track

Salad/healthy food is one of the strongest fast track categories.

Fast track approval requires:

- option complexity control
- freshness window
- cold-chain or holding policy if needed
- raw seafood review if applicable
- assembly station readiness
- packaging suitability
- stock-ready item control
- no-show waste risk
- nutrition/claim review if displayed
- policy version
- manager/HQ approval where required

Fast track works best when menu options are constrained into predefined base/protein/dressing/topping groups.

---

## 44. Relationship To 윤슬김밥 / 윤슬마루

This category is strategically important for 윤슬마루 and future 윤슬보울 / 단백 한컵 concepts.

Relevant areas:

- warm bowls
- protein cups
- low-fume menu design
- no-ham wellness positioning
- salad/poke-like assembly
- brown rice and vegetable bases
- chicken, tofu, egg, mushroom, and seasonal topping variants
- fast track pickup
- group order packaging
- menu option simplification
- KDS assembly station design
- nutrition-aware customer messaging

This taxonomy may become a core template for 윤슬마루-style menu expansion.

---

## 45. Relationship To Allergen And Health Claims

Salad/healthy menus frequently contain:

- egg
- dairy
- soy
- wheat/gluten
- nuts
- peanuts
- sesame
- seafood
- shellfish
- fruit allergens
- raw fish
- honey
- caffeine if clean drinks include tea/kombucha
- vegan claims
- vegetarian claims
- keto claims
- low-calorie claims
- high-protein claims
- detox/cleanse claims
- gluten-free claims

AI may suggest allergen and health tags.

Human/QC review is required before customer-facing allergen or health/diet claims are published.

---

## 46. Anti-Patterns

Avoid:

- treating dressing list as standalone menu tab
- treating base choices as separate menus without option structure
- treating kcal as price
- treating protein grams as price
- auto-publishing vegan/keto/low-calorie/high-protein claims
- auto-enabling fast track for raw fish poke without freshness review
- duplicating every topping as main menu
- losing parent-child relation between salad and toppings
- treating Greek yogurt toppings as salad toppings without context
- using AI to finalize POS option price without review
- hardcoding one base option tree for every store
- allowing AI to mutate dictionary automatically

These anti-patterns must be blocked in future runtime design.

---

## 47. Runtime Deferral

This document defines Salad/Healthy Food menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- base option parser
- dressing parser
- topping parser
- kcal/nutrition parser
- health claim runtime
- AI classification runtime
- POS mapping runtime
- customer display implementation
- KDS/assembly station mapping implementation
- fast track eligibility runtime
- allergen claim runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 48. Validation Checklist

Validation must confirm:

1. Classification scope is defined.
2. Classification depth is defined.
3. L2 category overview is defined.
4. Salad/Bowl L2 is defined.
5. Chicken/meat topping salad L3 is defined.
6. Seafood/fish topping salad L3 is defined.
7. Cheese/egg/vegan/vegetable salad L3 is defined.
8. Poke/Warm Bowl L2 is defined.
9. Seafood-based poke L3 is defined.
10. Meat/fusion warm bowl L3 is defined.
11. Tofu/tempeh/vegan poke L3 is defined.
12. Healthy sandwich/wrap L2 is defined.
13. Whole wheat/rye sandwich L3 is defined.
14. Tortilla/taco wrap L3 is defined.
15. Greek yogurt/oats L2 is defined.
16. Greek yogurt L3 is defined.
17. Yogurt bowl L3 is defined.
18. Oatmeal/chia L3 is defined.
19. Diet meals/clean drinks L2 is defined.
20. Brown rice lunchbox/keto meal L3 is defined.
21. Clean juice/protein drink L3 is defined.
22. Dressings/toppings/add-ons L2 is defined.
23. Dressing/sauce L3 is defined.
24. Base/protein/main topping add-on L3 is defined.
25. Snack/nut/seed topping L3 is defined.
26. Base/dressing/kcal/nutrition notice rules L2 is defined.
27. Base/custom option patterns L3 is defined.
28. Kcal/nutrition/health claim patterns L3 is defined.
29. Kcal and nutrition parsing boundary is defined.
30. Base and topping option tree boundary is defined.
31. Dressing and topping binding boundary is defined.
32. Menu attribute boundary is defined.
33. Fast track default guidance is defined.
34. KDS/assembly station candidate matrix is defined.
35. POS mapping boundary is defined.
36. Customer display boundary is defined.
37. Classification output format is defined.
38. Event catalog is defined.
39. Dictionary governance boundary is defined.
40. Relationships to AI Menu Intake, Fast Track, 윤슬김밥/윤슬마루, and Allergen/Health Claims are defined.
41. Anti-patterns are listed.
42. Coding remains unauthorized.
43. Runtime remains deferred.

---

## 49. Relationship To Previous Documents

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

- `40015 Pub Bar Izakaya Alcohol Anju Menu Taxonomy Policy`
- `40016 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`
- `40017 Health Bowl Assembly Station Fast Track SOP`
- `40018 Nutrition Allergen Health Claim Review Governance Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 50. Final Rule

Salad/Healthy Food menu classification must treat base selection, protein topping, dressing, add-on toppings, kcal, protein grams, health claims, allergen candidates, raw seafood, and option-tree structure as first-class parsing targets.

AI may match salad, poke, warm bowl, sandwich, wrap, Greek yogurt, oatmeal, diet meal, clean drink, dressing, topping, base option, nutrition, and health-claim patterns.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS option mapping, nutrition/health claim review, allergen review, freshness review, and rollback remain mandatory before deployment.

Salad/healthy food is a strong fast track category only when option complexity, assembly station readiness, packaging, freshness, stock readiness, and health-claim governance are controlled.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.