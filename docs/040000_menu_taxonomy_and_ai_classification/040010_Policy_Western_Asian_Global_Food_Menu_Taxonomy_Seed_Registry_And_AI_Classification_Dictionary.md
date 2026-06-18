# 040010_Policy_Western_Asian_Global_Food_Menu_Taxonomy_Seed_Registry_And_AI_Classification_Dictionary

## 1. Purpose

This document defines the Western, Italian, American, Brunch, Southeast Asian, Mexican, and Global Food Menu Taxonomy Seed Registry and AI Classification Dictionary Policy.

The previous artifact `40009 Chinese Food Menu Taxonomy Seed Registry And AI Classification Dictionary Policy` expanded Chinese menus with size options, half-and-half menus, delivery sets, mala gram pricing, and option parsing boundaries.

This document expands the `WESTERN_ASIAN_GLOBAL_FOOD` category because Western/Asian/global restaurants have distinct menu structures:

- Korean and English mixed menu names
- pasta sauce-base options
- steak cut names
- pizza size and half-and-half options
- burger and sandwich customization
- brunch plate descriptions
- salad protein add-ons
- side platter composition
- Southeast Asian noodle/rice dishes
- Mexican taco/burrito/fajita structures
- set menu components
- sauce, spice, protein, and topping options
- long descriptive menu text
- imported/foreign spelling variants

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Western/Asian menu parsing requires synonym, option, and component-aware classification.

The correct rule is:

English menu terms must map to Korean customer-searchable names.  
Sauce base is an attribute, not always a separate category.  
Pizza half-and-half is an option/composition structure, not two unrelated menus.  
Steak cut and doneness are attributes.  
Brunch plates often contain multiple components.  
Set descriptions must be parsed as option or composition text.  
Southeast Asian and Mexican menus require cuisine-specific aliases.  
AI may recommend classification, but human review remains mandatory for price, set composition, option price, allergen, fast track, and customer-facing deployment.  

Western/Asian category affects customer display, KDS station, cooking time, fast track eligibility, POS options, inventory, allergen, i18n, and analytics.

---

## 3. Classification Scope

This registry applies to:

- Italian restaurants
- pasta/risotto restaurants
- steak restaurants
- western casual dining
- pizzerias
- burger restaurants
- sandwich shops
- brunch cafes
- salad and light meal restaurants
- Southeast Asian restaurants
- Vietnamese restaurants
- Thai restaurants
- Indonesian/Malaysian-style restaurants
- Mexican restaurants
- taco/burrito shops
- fusion global restaurants
- menu board OCR/AI parsing
- English/Korean synonym mapping
- sauce option parsing
- set component parsing
- pizza size/half parsing
- steak cut/doneness parsing
- POS/KDS mapping
- fast track suitability review
- customer display and i18n category grouping

This registry is an AI classification aid and governance seed.

It is not a runtime dictionary implementation.

---

## 4. Classification Depth

The Western/Asian category uses the following layers:

| Layer | Meaning | Example |
|---|---|---|
| `L1_BUSINESS_CATEGORY` | Western / Asian / Global Food | `WESTERN_ASIAN_GLOBAL_FOOD` |
| `L2_MENU_CATEGORY` | Major family | Pasta / Risotto |
| `L3_MENU_SUBCATEGORY` | Specific subfamily | Cream pasta |
| `ITEM_ATTRIBUTE` | Sauce, protein, size, doneness, set component | tomato, cream, rare, half-and-half |

Synonym mapping is mandatory because menus may mix Korean, English, and transliterated terms.

---

## 5. L2 Category Overview

Recommended L2 categories:

| L2 Code | Label |
|---|---|
| `WESTERN_PASTA_RISOTTO` | Pasta / Risotto |
| `WESTERN_STEAK_CUTLET` | Steak / Cutlet |
| `WESTERN_PIZZA` | Pizza |
| `WESTERN_BURGER_SANDWICH_BRUNCH` | Burger / Sandwich / Brunch |
| `WESTERN_SALAD_SIDE` | Salad / Western Sides |
| `ASIAN_NOODLE_RICE` | Southeast Asian Noodles / Rice |
| `MEXICAN_GLOBAL` | Mexican / Other Global Food |
| `WESTERN_SET_PLATTER` | Set / Platter |
| `WESTERN_ALCOHOL_DRINK` | Alcohol / Drinks |
| `WESTERN_NOTICE_OPTION_RULE` | Sauce / Spice / Size / Set Notice Rules |

Notice and option rules must be separated from menu items.

---

## 6. L2: Pasta / Risotto

L2 code:

    WESTERN_PASTA_RISOTTO

This category includes tomato, rose, cream, oil, soup-style pasta, risotto, and pilaf.

---

## 7. L3: Tomato / Rose Pasta

L3 code:

    WESTERN_PASTA_TOMATO_ROSE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 토마토파스타 | Tomato pasta |
| 뽀모도로 | Pomodoro |
| Pomodoro | English/Italian synonym |
| 아라비아따 | Arrabbiata |
| Arrabbiata | English/Italian synonym |
| 미트볼파스타 | Meatball pasta |
| 볼로네제 | Bolognese |
| Bolognese | English/Italian synonym |
| 라구파스타 | Ragu pasta |
| Ragu Pasta | English synonym |
| 해물토마토파스타 | Seafood tomato pasta |
| 로제파스타 | Rose pasta |
| 쉬림프로제파스타 | Shrimp rose pasta |
| 게살로제파스타 | Crab meat rose pasta |
| 뚝배기파스타 | Hot pot pasta |
| 매운토마토파스타 | Spicy tomato pasta |
| 토마토해산물파스타 | Tomato seafood pasta |

AI notes:

- “Tomato”, “Pomodoro”, “Arrabbiata”, “Bolognese”, and “Ragu” must map to customer-searchable Korean labels.
- Spice level may be explicit or inferred; inferred spice level must remain reviewable.

---

## 8. L3: Cream Pasta

L3 code:

    WESTERN_PASTA_CREAM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 크림파스타 | Cream pasta |
| Cream Pasta | English synonym |
| 까르보나라 | Carbonara |
| Carbonara | English/Italian synonym |
| 투움바파스타 | Toowoomba pasta |
| 빠네크림파스타 | Pane cream pasta |
| 빠네파스타 | Pane pasta |
| 버섯크림파스타 | Mushroom cream pasta |
| 명란크림파스타 | Pollack roe cream pasta |
| 고르곤졸라파스타 | Gorgonzola pasta |
| 트러플크림파스타 | Truffle cream pasta |
| 베이컨크림파스타 | Bacon cream pasta |
| 새우크림파스타 | Shrimp cream pasta |
| 해물크림파스타 | Seafood cream pasta |

AI notes:

- “Gorgonzola” may be pasta or pizza depending context.
- Cream base affects allergen candidates such as dairy.

---

## 9. L3: Oil / Soup-Style Pasta

L3 code:

    WESTERN_PASTA_OIL_SOUP

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 알리오올리오 | Aglio e olio |
| Aglio e Olio | English/Italian synonym |
| 봉골레파스타 | Vongole pasta |
| Vongole | English/Italian synonym |
| 상하이파스타 | Shanghai pasta |
| 감바스파스타 | Gambas pasta |
| 명란오일파스타 | Pollack roe oil pasta |
| 바질페스토파스타 | Basil pesto pasta |
| Basil Pesto Pasta | English synonym |
| 오일파스타 | Oil pasta |
| 해산물오일파스타 | Seafood oil pasta |
| 매콤오일파스타 | Spicy oil pasta |
| 엔초비파스타 | Anchovy pasta |
| 봉골레비앙코 | Vongole bianco |

AI notes:

- “Shanghai pasta” may indicate spicy seafood soup-style fusion.
- Oil pasta may be fast track candidate only after packaging review.

---

## 10. L3: Risotto / Pilaf

L3 code:

    WESTERN_RISOTTO_PILAF

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 크림리조또 | Cream risotto |
| 토마토리조또 | Tomato risotto |
| 로제리조또 | Rose risotto |
| 먹물리조또 | Squid ink risotto |
| 버섯크림리조또 | Mushroom cream risotto |
| 해산물리조또 | Seafood risotto |
| 새우크림리조또 | Shrimp cream risotto |
| 김치필라프 | Kimchi pilaf |
| 새우필라프 | Shrimp pilaf |
| 목살필라프 | Pork neck pilaf |
| 치킨필라프 | Chicken pilaf |
| 불고기필라프 | Bulgogi pilaf |
| 베이컨필라프 | Bacon pilaf |
| 볶음밥 | Fried rice, context required |

AI notes:

- Pilaf may overlap with rice/bowl categories.
- Rice-based items may be fast track candidates after packaging review.

---

## 11. L2: Steak / Cutlet

L2 code:

    WESTERN_STEAK_CUTLET

This category includes beef steaks, pork steaks, chicken steaks, fish steaks, hamburg steak, and western cutlets.

---

## 12. L3: Beef / Pork Steak

L3 code:

    WESTERN_STEAK_BEEF_PORK

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 안심스테이크 | Tenderloin steak |
| 텐더로인 | Tenderloin |
| Tenderloin Steak | English synonym |
| 등심스테이크 | Sirloin steak |
| 설로인 | Sirloin |
| 채끝스테이크 | Striploin steak |
| 립아이스테이크 | Ribeye steak |
| 꽃등심스테이크 | Ribeye steak Korean label |
| 티본스테이크 | T-bone steak |
| T-Bone Steak | English synonym |
| 토마호크스테이크 | Tomahawk steak |
| Tomahawk Steak | English synonym |
| 목살스테이크 | Pork neck steak |
| 찹스테이크 | Chop steak |
| 함박스테이크 | Hamburg steak |
| 햄버거스테이크 | Hamburg steak |
| 함박 | Hamburg steak short label |
| 포크스테이크 | Pork steak |
| 바베큐폭립 | BBQ pork ribs |

AI notes:

- Steak cut, weight, doneness, and sauce may be attributes.
- Steak is usually not default fast track.

---

## 13. L3: Chicken / Fish / Western Cutlet

L3 code:

    WESTERN_CHICKEN_FISH_CUTLET

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 치킨스테이크 | Chicken steak |
| 연어스테이크 | Salmon steak |
| 경양식돈까스 | Western-style pork cutlet |
| 돈까스 | Cutlet context depends on store |
| 치즈돈까스 | Cheese cutlet |
| 생선까스 | Fish cutlet |
| 비프까스 | Beef cutlet |
| 치킨까스 | Chicken cutlet |
| 함박돈까스 | Hamburg plus cutlet |
| 왕돈까스 | Large cutlet |
| 수제돈까스 | Handmade cutlet |

AI notes:

- “돈까스” can be Japanese katsu or western cutlet depending store context.
- Cutlet items may be fast track review candidates.

---

## 14. L2: Pizza

L2 code:

    WESTERN_PIZZA

This category includes classic pizza, oven pizza, premium/fusion pizza, Chicago pizza, and half-and-half pizza.

---

## 15. L3: Classic / Oven Pizza

L3 code:

    WESTERN_PIZZA_CLASSIC

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 마르게리따피자 | Margherita pizza |
| Margherita Pizza | English synonym |
| 고르곤졸라피자 | Gorgonzola pizza |
| Gorgonzola Pizza | English synonym |
| 페페로니피자 | Pepperoni pizza |
| Pepperoni Pizza | English synonym |
| 치즈피자 | Cheese pizza |
| 콤비네이션피자 | Combination pizza |
| 슈프림피자 | Supreme pizza |
| 포테이토피자 | Potato pizza |
| 고구마피자 | Sweet potato pizza |
| 불고기피자 | Bulgogi pizza |
| 하와이안피자 | Hawaiian pizza |
| 화덕피자 | Oven-fired pizza |
| 루꼴라피자 | Arugula pizza |
| 바질피자 | Basil pizza |

AI notes:

- Pizza size and crust options must be parsed separately.
- “Gorgonzola” may be pizza or pasta.

---

## 16. L3: Premium / Fusion Pizza

L3 code:

    WESTERN_PIZZA_PREMIUM_FUSION

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 쉬림프피자 | Shrimp pizza |
| 스테이크피자 | Steak pizza |
| 루꼴라피자 | Arugula pizza |
| 리코타치즈피자 | Ricotta cheese pizza |
| 시카고피자 | Chicago pizza |
| 딥디쉬피자 | Deep dish pizza |
| 반반피자 | Half-and-half pizza |
| 하프앤하프 | Half-and-half |
| Half & Half | English synonym |
| 트러플피자 | Truffle pizza |
| 베이컨포테이토피자 | Bacon potato pizza |
| 고르곤졸라꿀피자 | Gorgonzola honey pizza |
| 크림치즈피자 | Cream cheese pizza |

AI notes:

- Half-and-half must be composition/option structure.
- Pizza size may be `R`, `L`, `M`, `Large`, `Regular`.

---

## 17. L2: Burger / Sandwich / Brunch

L2 code:

    WESTERN_BURGER_SANDWICH_BRUNCH

This category includes handmade burgers, sandwiches, panini, toast, brunch plates, pancakes, and egg-based brunch dishes.

---

## 18. L3: Handmade Burger

L3 code:

    WESTERN_BURGER

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 클래식버거 | Classic burger |
| Classic Burger | English synonym |
| 치즈버거 | Cheeseburger |
| Cheese Burger | English synonym |
| 베이컨치즈버거 | Bacon cheeseburger |
| 치킨버거 | Chicken burger |
| 쉬림프버거 | Shrimp burger |
| 머쉬룸버거 | Mushroom burger |
| 아보카도버거 | Avocado burger |
| 더블치즈버거 | Double cheeseburger |
| 불고기버거 | Bulgogi burger |
| 수제버거 | Handmade burger |
| 트러플버거 | Truffle burger |
| 베지버거 | Veggie burger |

AI notes:

- Burger protein, patty count, side set, and drink set are options.
- Fast track candidate depends on prep time and packaging.

---

## 19. L3: Sandwich / Panini

L3 code:

    WESTERN_SANDWICH_PANINI

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 클래식샌드위치 | Classic sandwich |
| Classic Sandwich | English synonym |
| BLT샌드위치 | BLT sandwich |
| 클럽샌드위치 | Club sandwich |
| 잠봉뵈르 | Jambon beurre |
| 햄치즈파니니 | Ham cheese panini |
| 불고기파니니 | Bulgogi panini |
| 토마토모짜렐라파니니 | Tomato mozzarella panini |
| 치킨샌드위치 | Chicken sandwich |
| 에그샌드위치 | Egg sandwich |
| 크로아상샌드위치 | Croissant sandwich |
| 바게트샌드위치 | Baguette sandwich |
| 루벤샌드위치 | Reuben sandwich |
| 파니니 | Panini |
| 토스트 | Toast |

AI notes:

- Cafe/brunch stores may share this category.
- Bread type and protein can be attributes.

---

## 20. L3: Brunch Plate

L3 code:

    WESTERN_BRUNCH_PLATE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 프렌치토스트 | French toast |
| 에그베네딕트 | Eggs Benedict |
| Eggs Benedict | English synonym |
| 팬케이크 | Pancake |
| Pancake | English synonym |
| 잉글리시브렉퍼스트 | English breakfast |
| English Breakfast | English synonym |
| 오믈렛 | Omelet |
| Omelette | English synonym |
| 크로크무슈 | Croque monsieur |
| 크로크마담 | Croque madame |
| 브런치플레이트 | Brunch plate |
| 모닝플레이트 | Morning plate |
| 에그스크램블 | Scrambled eggs |
| 샥슈카 | Shakshuka |
| 아보카도토스트 | Avocado toast |

AI notes:

- Brunch plates contain components; components should not become separate paid items unless priced.
- Egg/allergen tags may be relevant.

---

## 21. L2: Salad / Western Sides

L2 code:

    WESTERN_SALAD_SIDE

This category includes salads, fries, fried sides, wings, platters, tapas-style western sides, and appetizer dishes.

---

## 22. L3: Salad

L3 code:

    WESTERN_SALAD

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 그린샐러드 | Green salad |
| 가든샐러드 | Garden salad |
| 시저샐러드 | Caesar salad |
| 리코타치즈샐러드 | Ricotta cheese salad |
| 카프레제샐러드 | Caprese salad |
| 연어샐러드 | Salmon salad |
| 치킨텐더샐러드 | Chicken tender salad |
| 스테이크샐러드 | Steak salad |
| 닭가슴살샐러드 | Chicken breast salad |
| 쉬림프샐러드 | Shrimp salad |
| 아보카도샐러드 | Avocado salad |
| 콥샐러드 | Cobb salad |
| 부라타치즈샐러드 | Burrata salad |
| 퀴노아샐러드 | Quinoa salad |

AI notes:

- Protein add-on and dressing choice are important options.
- Salad may overlap with Health/Wellness category.

---

## 23. L3: Western Side / Platter

L3 code:

    WESTERN_SIDE_PLATTER

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 감자튀김 | French fries |
| 프렌치프라이 | French fries |
| 치즈프라이 | Cheese fries |
| 버팔로윙 | Buffalo wings |
| 버팔로봉 | Buffalo drumettes |
| 치킨텐더 | Chicken tenders |
| 어니언링 | Onion rings |
| 나쵸 | Nachos |
| 감바스 알 아히요 | Gambas al ajillo |
| 감바스 | Gambas |
| 치즈플래터 | Cheese platter |
| 소시지플래터 | Sausage platter |
| 바베큐플래터 | BBQ platter |
| 미트플래터 | Meat platter |
| 해산물플래터 | Seafood platter |
| 칠리치즈프라이 | Chili cheese fries |
| 윙봉세트 | Wings and drumettes set |
| 피쉬앤칩스 | Fish and chips |

AI notes:

- Platter composition must be retained.
- Some items may belong to pub/bar context.

---

## 24. L2: Southeast Asian Noodles / Rice

L2 code:

    ASIAN_NOODLE_RICE

This category includes Vietnamese, Thai, Indonesian, Malaysian, and Asian fusion noodle/rice dishes.

---

## 25. L3: Asian Noodles

L3 code:

    ASIAN_NOODLE

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 소고기쌀국수 | Beef pho |
| Beef Pho | English synonym |
| 닭고기쌀국수 | Chicken pho |
| Chicken Pho | English synonym |
| 매운쌀국수 | Spicy pho |
| 분짜 | Bun cha |
| 팟타이 | Pad Thai |
| 볶음쌀국수 | Stir-fried rice noodles |
| 미고랭 | Mie goreng |
| 락사 | Laksa |
| 탄탄면 | Tantanmen, Asian fusion context |
| 분보후에 | Bun bo hue |
| 반쎄오 | Banh xeo |
| 카오소이 | Khao soi |
| 팟씨유 | Pad see ew |
| 팟키마오 | Pad kee mao |
| 월남쌈 | Vietnamese spring roll/platter context |
| 짜조 | Vietnamese fried spring rolls |
| 쌀국수 | Pho/noodle generic |

AI notes:

- “탄탄면” may be Chinese, Japanese, or Asian fusion.
- Pho menus may have meat/protein options and size options.

---

## 26. L3: Asian Rice / Dish

L3 code:

    ASIAN_RICE_DISH

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 나시고랭 | Nasi goreng |
| Nasi Goreng | English synonym |
| 카오팟 | Thai fried rice |
| 태국식볶음밥 | Thai fried rice |
| 푸팟퐁커리 | Poo pad pong curry |
| 꿍팟퐁커리 | Shrimp curry stir-fry |
| 모닝글로리볶음 | Morning glory stir-fry |
| 공심채볶음 | Water spinach stir-fry |
| 공공빌로우 | OCR/variant candidate for 공심채볶음 |
| 춘권 | Spring roll |
| 톰얌쿵 | Tom yum goong |
| 똠얌꿍 | Tom yum goong variant |
| 카오만까이 | Thai chicken rice |
| 그린커리 | Green curry |
| 레드커리 | Red curry |
| 파인애플볶음밥 | Pineapple fried rice |
| 반미 | Banh mi |
| 커리 | Curry, context required |

AI notes:

- Many spellings are transliterated inconsistently.
- Curry names must not automatically map to Japanese curry or Korean curry.

---

## 27. L2: Mexican / Other Global Food

L2 code:

    MEXICAN_GLOBAL

This category includes tacos, burritos, burrito bowls, quesadillas, fajitas, enchiladas, and global fusion platters.

---

## 28. L3: Mexican

L3 code:

    MEXICAN_FOOD

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 타코 | Taco |
| Taco | English synonym |
| 비프타코 | Beef taco |
| 포크타코 | Pork taco |
| 치킨타코 | Chicken taco |
| 쉬림프타코 | Shrimp taco |
| 브리또 | Burrito |
| Burrito | English synonym |
| 브리또보울 | Burrito bowl |
| Burrito Bowl | English synonym |
| 퀘사디아 | Quesadilla |
| Quesadilla | English synonym |
| 화이타 | Fajita |
| 파히타 | Fajita spelling variant |
| Fajita | English synonym |
| 엔칠라다 | Enchilada |
| Enchilada | English synonym |
| 나쵸 | Nachos |
| 타코라이스 | Taco rice |
| 과카몰리 | Guacamole |
| 살사 | Salsa |
| 칠리콘카르네 | Chili con carne |

AI notes:

- Protein type is important.
- Taco count, set count, and topping/sauce options must be parsed separately.

---

## 29. L3: Global Set / Platter

L3 code:

    GLOBAL_SET_PLATTER

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 2인세트 | Two-person set |
| 커플세트 | Couple set |
| 런치세트 | Lunch set |
| 패밀리세트 | Family set |
| 바베큐플래터 | BBQ platter |
| 타코플래터 | Taco platter |
| 샘플러 | Sampler |
| 플래터 | Platter |
| 파티팩 | Party pack |
| 세트A | Set A |
| 세트B | Set B |
| Set A | English pattern |
| Set B | English pattern |
| Course | Course-like set |
| Combo | Combo |

AI notes:

- Set composition should be structured from parentheses or description.
- Components must not become separate paid menus without review.

---

## 30. L2: Alcohol / Drinks

L2 code:

    WESTERN_ALCOHOL_DRINK

This category includes alcohol, soft drinks, coffee-like drinks in restaurants, wine, cocktails, beer, and global drink items.

---

## 31. L3: Western / Global Alcohol And Drinks

L3 code:

    WESTERN_ALCOHOL_DRINK_ITEM

Seed menu terms:

| Menu Term | Notes |
|---|---|
| 와인 | Wine |
| 레드와인 | Red wine |
| 화이트와인 | White wine |
| 스파클링와인 | Sparkling wine |
| 샴페인 | Champagne |
| 맥주 | Beer |
| 생맥주 | Draft beer |
| 수제맥주 | Craft beer |
| 하이볼 | Highball |
| 칵테일 | Cocktail |
| 모히또 | Mojito |
| 마가리타 | Margarita |
| 샹그리아 | Sangria |
| 콜라 | Cola |
| 사이다 | Cider/sprite |
| 에이드 | Ade |
| 탄산수 | Sparkling water |
| 주스 | Juice |
| 커피 | Coffee |
| 아이스티 | Iced tea |
| 라씨 | Lassi |
| 타이티 | Thai tea |

AI notes:

- Alcohol requires legal/age policy.
- Drinks may overlap with Cafe/Dessert but remain restaurant drink category under this L1.

---

## 32. L2: Sauce / Spice / Size / Set Notice Rules

L2 code:

    WESTERN_NOTICE_OPTION_RULE

This category is not a normal menu item category.

It captures option and notice structures.

---

## 33. L3: Sauce / Base / Spice / Option Rule

L3 code:

    WESTERN_NOTICE_OPTION_PATTERN

Seed patterns:

| Pattern | Meaning |
|---|---|
| 토마토 | Sauce/base option |
| 크림 | Sauce/base option |
| 로제 | Sauce/base option |
| 오일 | Sauce/base option |
| 매운맛 | Spice option |
| 순한맛 | Mild option |
| 보통맛 | Normal spice |
| 1단계 | Spice level |
| 2단계 | Spice level |
| 3단계 | Spice level |
| 소스선택 | Sauce selection |
| 면 선택 | Noodle/pasta choice |
| 밥 선택 | Rice choice |
| 고기 선택 | Protein choice |
| 새우 추가 | Shrimp add-on |
| 치즈 추가 | Cheese add-on |
| 아보카도 추가 | Avocado add-on |
| 드레싱 선택 | Dressing choice |
| 굽기 선택 | Steak doneness |
| 레어 | Rare |
| 미디엄 | Medium |
| 웰던 | Well done |
| R | Regular size |
| L | Large size |
| M | Medium size |
| 하프앤하프 | Half-and-half |
| 반반 | Half-and-half |
| 택1 | Choose one |
| 선택1 | Choose one |
| 파스타 택1 | Choose one pasta |
| 음료 포함 | Drink included |
| 미니샐러드 포함 | Mini salad included |

AI notes:

- Option text should not become ordinary menu item.
- Parentheses may contain description, option, or set composition.

---

## 34. English Synonym Mapping Boundary

English and foreign terms must map to normalized Korean/customer-searchable labels.

Examples:

| English / Foreign Term | Normalized Label |
|---|---|
| Carbonara | 까르보나라 |
| Pomodoro | 뽀모도로 |
| Arrabbiata | 아라비아따 |
| Bolognese | 볼로네제 |
| Ragu | 라구 |
| Aglio e Olio | 알리오올리오 |
| Vongole | 봉골레 |
| Basil Pesto | 바질페스토 |
| Margherita | 마르게리따 |
| Pepperoni | 페페로니 |
| Gorgonzola | 고르곤졸라 |
| Tenderloin | 안심 |
| Sirloin | 등심 |
| Ribeye | 립아이 |
| T-Bone | 티본 |
| Tomahawk | 토마호크 |
| BLT | BLT |
| Eggs Benedict | 에그베네딕트 |
| Pad Thai | 팟타이 |
| Nasi Goreng | 나시고랭 |
| Taco | 타코 |
| Burrito | 브리또 |
| Quesadilla | 퀘사디아 |
| Fajita | 화이타/파히타 |

Synonym mapping supports search and classification.

It must preserve original display if admin wants brand-style naming.

---

## 35. Set Component Parsing Boundary

Western/Asian parser must parse set descriptions.

Example:

    Set A (파스타 택1 + 미니샐러드 + 음료) 24,000원

Should parse as:

| Field | Value |
|---|---|
| menu_name | Set A |
| menu_type | set |
| component_1 | pasta choice |
| component_2 | mini salad |
| component_3 | drink |
| price | 24000 |
| option_required | pasta choice |

Set component text may become description or option group depending policy.

Human review required if unclear.

---

## 36. Sauce And Option Parsing Boundary

Parser must distinguish:

- sauce/base option
- spice level
- protein option
- topping/add-on
- pasta noodle type
- steak doneness
- pizza size
- pizza crust
- salad dressing
- burger side set
- taco protein
- burrito bowl base
- set choice

Option price must be reviewed.

Do not create duplicate menu items for each option unless explicitly intended.

---

## 37. Western/Asian Menu Attribute Boundary

Menu items may include:

- cuisine type
- sauce/base
- protein
- spice level
- size
- set component
- topping/add-on
- cooking method
- doneness
- hot/cold marker
- allergen candidates
- vegetarian/vegan candidate
- fast track suitability
- KDS station candidate
- packaging suitability
- option group
- English synonym
- customer-search label

Attributes must be reviewed before live deployment.

---

## 38. Western/Asian Fast Track Default Guidance

Candidate fast track guidance:

| Category | Default Guidance |
|---|---|
| Pasta | Review candidate |
| Risotto / pilaf | Review candidate |
| Steak | Usually disabled |
| Cutlet | Review candidate |
| Pizza | Review candidate depending prep and slice/whole |
| Burger | Review candidate |
| Sandwich / panini | Review candidate |
| Brunch plate | Review or disabled depending components |
| Salad | Strong review candidate |
| Western sides | Review candidate |
| Asian noodles | Review or disabled depending soup/packaging |
| Asian rice dishes | Review candidate |
| Mexican tacos/burritos | Review candidate |
| Platter/set | Review or disabled |
| Alcohol | Disabled unless legal/age policy exists |

Fast track eligibility must be item-specific and packaging-aware.

---

## 39. Western/Asian KDS Station Candidate Matrix

Candidate station mapping:

| Category | KDS Station Candidate |
|---|---|
| Pasta | Pasta/hot station |
| Risotto/Pilaf | Rice/hot station |
| Steak | Grill station |
| Cutlet | Fry station |
| Pizza | Oven station |
| Burger | Grill/assembly station |
| Sandwich/Panini | Sandwich/panini station |
| Brunch | Brunch/egg station |
| Salad | Salad/cold station |
| Western sides | Fry/side station |
| Asian noodles | Noodle/soup station |
| Asian rice | Wok/rice station |
| Mexican | Assembly/grill station |
| Set/platter | Multi-station assembly |
| Drinks | Beverage/service station |

Station recommendation must be confirmed by store configuration.

---

## 40. POS Mapping Boundary

Western/Asian POS mapping must handle:

- base menu
- sauce option
- protein option
- size option
- set choice
- side/drink combo
- topping/add-on
- pizza half-and-half
- steak doneness
- salad dressing
- alcohol/drink separation
- discount exclusion
- tax category
- inventory deduction
- packaging option
- refund/cancel rule

POS mapping requires human verification.

AI must not finalize option price mapping.

---

## 41. Customer Display Boundary

Customer-facing Western/Asian menu must distinguish:

- pasta/risotto
- steak/cutlet
- pizza
- burger/sandwich/brunch
- salad/sides
- Asian noodles/rice
- Mexican/global
- set/platter
- drinks/alcohol
- sauce options
- spice level
- protein option
- size option
- set composition
- allergen notices
- vegetarian/vegan candidates if approved
- fast track availability if approved

Customer display must preserve readability despite long option text.

---

## 42. Western/Asian Classification Output Format

Recommended AI output:

| Field | Meaning |
|---|---|
| `raw_text` | OCR text |
| `normalized_name` | Normalized menu name |
| `display_name_original` | Original menu display |
| `search_aliases` | Korean/English aliases |
| `l1_category` | `WESTERN_ASIAN_GLOBAL_FOOD` |
| `l2_category` | Major category |
| `l3_subcategory` | Subcategory |
| `cuisine_subtype` | Italian, American, Thai, Vietnamese, Mexican, etc. |
| `sauce_base` | Tomato, cream, rose, oil, etc. |
| `protein_candidate` | Beef, chicken, shrimp, salmon, etc. |
| `option_groups` | Sauce, spice, size, protein, set choice |
| `set_components` | Components if set/platter |
| `price_candidate` | Numeric price if present |
| `allergen_candidates` | Dairy, egg, wheat, seafood, nuts, etc. |
| `fasttrack_default_candidate` | Candidate suitability |
| `kds_station_candidate` | Station |
| `confidence` | Confidence |
| `human_review_required` | Review flag |
| `source_ref` | Image/page/bounding box |

Output is draft until human confirmation.

---

## 43. Western/Asian Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `WESTERN_MENU_DICTIONARY_MATCHED` | Dictionary match found |
| `ENGLISH_SYNONYM_DETECTED` | English synonym detected |
| `SAUCE_BASE_DETECTED` | Sauce/base detected |
| `SPICE_OPTION_DETECTED` | Spice option detected |
| `PROTEIN_OPTION_DETECTED` | Protein option detected |
| `SET_COMPONENT_DETECTED` | Set component detected |
| `PIZZA_HALF_HALF_DETECTED` | Pizza half-and-half detected |
| `STEAK_DONENESS_DETECTED` | Doneness option detected |
| `SALAD_DRESSING_OPTION_DETECTED` | Dressing option detected |
| `WESTERN_LOW_CONFIDENCE` | Low confidence |
| `WESTERN_REVIEW_REQUIRED` | Human review required |
| `WESTERN_CATEGORY_CONFIRMED` | Category confirmed |
| `WESTERN_POS_MAPPING_REVIEW_REQUIRED` | POS mapping review required |
| `WESTERN_FASTTRACK_REVIEW_REQUIRED` | Fast track review required |

Events must route through `10610`.

---

## 44. Dictionary Governance Boundary

Western/Asian dictionary updates must be governed.

Update actions:

- add English synonym
- add Korean transliteration
- add cuisine subtype
- add sauce/base pattern
- add option pattern
- add set parsing pattern
- add pizza half-and-half pattern
- add steak cut/doneness pattern
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

## 45. Relationship To AI Menu Intake

This document supports:

- business category context
- OCR/LLM extraction
- English/Korean synonym mapping
- sauce/base parsing
- set component parsing
- option parsing
- structured menu draft
- split-view review
- category confidence
- POS mapping warning
- KDS station recommendation
- fast track default guidance
- validation and deployment readiness

Western/Asian classification output remains draft until approved.

---

## 46. Relationship To Fast Track

Western/Asian category has strong fast track potential in selected menu families.

Fast track approval requires:

- menu-specific cooking time
- packaging suitability
- sauce separation if needed
- hot/cold quality tolerance
- KDS station readiness
- option complexity review
- no-show waste risk
- policy version
- customer notice if timing varies

Salads, sandwiches, pilaf, burgers, tacos, and selected sides may be strong candidates.

Steak, course, platter, complex brunch, alcohol, and long-cook items are disabled or review-only by default.

---

## 47. Relationship To Allergen And Health Claims

Western/Asian menus frequently contain:

- dairy
- egg
- wheat/gluten
- seafood
- shellfish
- nuts
- soy
- sesame
- meat
- raw/undercooked protein
- spicy ingredients
- vegetarian/vegan claims
- low-calorie/high-protein claims

AI may suggest allergen or health tags.

Human/QC review is required before customer-facing allergen or health claims.

---

## 48. Anti-Patterns

Avoid:

- treating English menu term as unknown when synonym exists
- replacing original brand-style English name without preserving display
- treating sauce option as separate menu item by default
- treating Set A components as separate paid items without review
- duplicating pizza half-and-half as two full pizzas
- auto-enabling fast track for steak or platter
- marking vegetarian/vegan claim without review
- ignoring allergen candidates in cream/cheese/nut/seafood menus
- treating taco protein choices as separate base menus unless intended
- using AI to finalize POS option price without review
- hardcoding only Korean labels and losing English search
- allowing AI to mutate dictionary automatically

These anti-patterns must be blocked in future runtime design.

---

## 49. Runtime Deferral

This document defines Western/Asian/Global Food menu taxonomy seed registry and AI classification dictionary boundaries only.

It does not authorize:

- dictionary database implementation
- OCR implementation
- LLM prompt implementation
- English synonym runtime
- sauce option parser
- set component parser
- pizza half-and-half parser
- AI classification runtime
- POS mapping runtime
- customer display implementation
- KDS station mapping implementation
- fast track eligibility runtime
- allergen/health claim runtime
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
4. Pasta/Risotto L2 is defined.
5. Tomato/Rose Pasta L3 is defined.
6. Cream Pasta L3 is defined.
7. Oil/Soup-Style Pasta L3 is defined.
8. Risotto/Pilaf L3 is defined.
9. Steak/Cutlet L2 is defined.
10. Beef/Pork Steak L3 is defined.
11. Chicken/Fish/Western Cutlet L3 is defined.
12. Pizza L2 is defined.
13. Classic/Oven Pizza L3 is defined.
14. Premium/Fusion Pizza L3 is defined.
15. Burger/Sandwich/Brunch L2 is defined.
16. Handmade Burger L3 is defined.
17. Sandwich/Panini L3 is defined.
18. Brunch Plate L3 is defined.
19. Salad/Western Sides L2 is defined.
20. Salad L3 is defined.
21. Western Side/Platter L3 is defined.
22. Southeast Asian Noodles/Rice L2 is defined.
23. Asian Noodles L3 is defined.
24. Asian Rice/Dish L3 is defined.
25. Mexican/Global L2 is defined.
26. Mexican L3 is defined.
27. Global Set/Platter L3 is defined.
28. Alcohol/Drinks L2 is defined.
29. Alcohol/Drinks L3 is defined.
30. Sauce/Spice/Size/Set Notice Rules L2 is defined.
31. Sauce/Base/Spice/Option Rule L3 is defined.
32. English synonym mapping boundary is defined.
33. Set component parsing boundary is defined.
34. Sauce and option parsing boundary is defined.
35. Menu attribute boundary is defined.
36. Fast track default guidance is defined.
37. KDS station candidate matrix is defined.
38. POS mapping boundary is defined.
39. Customer display boundary is defined.
40. Classification output format is defined.
41. Event catalog is defined.
42. Dictionary governance boundary is defined.
43. Relationships to AI Menu Intake, Fast Track, and Allergen/Health Claims are defined.
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

- `40011 Chicken Pizza Fast Food Menu Taxonomy Policy`
- `40012 Cafe Dessert Beverage Menu Taxonomy Policy`
- `40013 Menu Cooking Time Default Matrix And Fast Track Eligibility Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 52. Final Rule

Western/Asian/Global Food menu classification must treat English synonyms, sauce base, spice level, protein choice, pizza size, half-and-half composition, steak doneness, set components, salad dressing, and global cuisine aliases as first-class parsing targets.

AI may match pasta, risotto, steak, cutlet, pizza, burger, sandwich, brunch, salad, side, Southeast Asian noodle/rice, Mexican/global, set/platter, drinks, and option patterns.

AI dictionary match is draft evidence.

Human review, validation, approval, versioning, audit, POS option mapping, allergen/health claim review, and rollback remain mandatory before deployment.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
```
