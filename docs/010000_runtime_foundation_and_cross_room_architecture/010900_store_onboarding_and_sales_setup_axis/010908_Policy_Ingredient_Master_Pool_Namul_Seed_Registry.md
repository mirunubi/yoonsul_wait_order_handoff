# 010908_Policy_Ingredient_Master_Pool_Namul_Seed_Registry.md

## Purpose

This document defines the Ingredient Master Pool Taxonomy and Korean Namul Seed Registry Policy for Catch Menu.

The previous document `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy` defined high-risk menu attribute detection and handoff for allergens, alcohol, raw food, market price, spice, bone/shell, health claim, freshness, option risk, and set/combo/course inherited risk.

This document adds a deeper ingredient master layer.

It defines how the platform should treat the supplied full ingredient pool, including:

- meat and poultry
- seafood and shellfish
- vegetables
- Korean seasonal greens
- Korean wild herbs and namul
- grains, noodles, tofu, nuts
- dairy and eggs
- fruits
- condiments, sauces, fermented pastes
- oils and fats
- herbs and spices
- gimbap-specific ingredients
- banchan and namul ingredients
- pickles, jangajji, dried vegetables, sea vegetables
- high-risk ingredient flags
- allergen mapping
- alcohol ingredient mapping
- raw/undercooked ingredient mapping
- market-price ingredient mapping
- recipe and inventory readiness

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Ingredient master data is not a casual ingredient list.

The correct rule is:

Ingredient names must be normalized.  
Local names and synonyms must be preserved.  
Korean namul, wild greens, dried vegetables, sea vegetables, and banchan ingredients must be first-class ingredients.  
Ingredient master data must support menu parsing, recipe design, allergen detection, inventory, nutrition, procurement, legal notices, and support evidence.  
AI may suggest ingredient mapping.  
AI may not finalize allergen, alcohol, raw food, health claim, or legal notice classification.  
Ingredient master data must remain reviewable, versioned, and tenant-safe.  

Catch Menu needs an ingredient master that understands both global cuisine and Korean food reality.

---

## 3. Scope

This policy applies to:

- ingredient master pool
- ingredient category taxonomy
- Korean namul and wild herb registry
- gimbap ingredient registry
- banchan ingredient registry
- recipe ingredient mapping
- menu ingredient extraction
- allergen candidate detection
- alcohol candidate detection
- raw food candidate detection
- market price candidate detection
- health claim candidate detection
- origin/source labeling
- inventory mapping
- procurement mapping
- POS/KDS preparation notes
- legal notice trigger handoff
- support evidence handoff
- future seed data governance

This policy defines taxonomy and registry governance only.

---

## 4. Ingredient Master Object

Recommended ingredient master object:

| Field | Meaning |
|---|---|
| `ingredient_id` | Stable ingredient identity |
| `ingredient_code` | Stable code |
| `canonical_name_ko` | Korean canonical name |
| `canonical_name_en` | English canonical name if available |
| `synonyms_ko` | Korean synonyms |
| `synonyms_local` | Regional/local names |
| `ingredient_family` | Meat, seafood, vegetable, sauce, etc. |
| `ingredient_subfamily` | More specific category |
| `part_or_cut` | Cut, part, leaf, root, seed, etc. |
| `processing_state` | Fresh, dried, pickled, fermented, smoked, frozen |
| `risk_flags` | Allergen, alcohol, raw, bone, spice, etc. |
| `allergen_tags` | Allergen candidates |
| `legal_notice_tags` | Candidate notices |
| `recipe_usage_tags` | Gimbap, banchan, soup, sauce, topping |
| `inventory_unit_hint` | kg, g, bunch, pack, ea, bottle |
| `review_state` | Draft, reviewed, approved, deprecated |
| `audit_ref` | Audit reference |

Ingredient master must separate canonical name from local names and preparation forms.

---

## 5. Ingredient Category Families

Recommended top-level families:

| Family Code | Family |
|---|---|
| `MEAT_POULTRY` | Meat and poultry |
| `SEAFOOD_SHELLFISH` | Seafood and shellfish |
| `VEGETABLES` | General vegetables |
| `KOREAN_NAMUL_WILD_GREENS` | Korean namul, wild greens, seasonal greens |
| `GRAINS_NOODLES_TOFU_NUTS` | Grains, noodles, tofu, legumes, nuts |
| `DAIRY_EGGS` | Dairy and eggs |
| `FRUITS` | Fruits and processed fruits |
| `CONDIMENTS_SAUCES` | Condiments, fermented pastes, sauces |
| `OILS_FATS` | Oils and fats |
| `HERBS_SPICES` | Herbs and spices |
| `SEA_VEGETABLES` | Seaweed and sea vegetables |
| `PICKLES_JANGAJJI` | Pickles, jangajji, preserved vegetables |
| `PROCESSED_FOOD` | Processed food ingredients |
| `BEVERAGE_ALCOHOL` | Beverage and alcohol ingredients |
| `SPECIAL_LOCAL` | Regional, seasonal, or specialty ingredients |

Korean namul and sea vegetables should not be buried as minor vegetable subtypes.

---

## 6. Meat And Poultry Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Beef | sirloin, tenderloin, striploin, brisket, short plate, shank, round, ribs, ground beef, oxtail |
| Pork | pork belly, pork neck, front leg, hind leg, loin, tenderloin, ribs, pork jowl, gabrisal |
| Chicken | breast, thigh, whole chicken, wing, drumette, tenderloin, chicken feet, gizzard |
| Duck | smoked duck, duck roast, duck bulgogi cut, whole duck |
| Lamb | lamb rack, shoulder rack, French rack, lamb skewers cut, leg |
| Offal | gopchang, daechang, makchang, heart |
| Raw beef | yukhoe beef cut, round for raw beef |
| Processed meat | bacon, Vienna sausage, frank sausage, square ham, canned ham, pepperoni, salami, jamon, chorizo |

Meat cuts should preserve part, cut, and processing state.

---

## 7. Seafood And Shellfish Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Fish | mackerel, hairtail, yellow croaker, salmon, cod, pollock, flatfish, Spanish mackerel, saury, atka mackerel, anchovy, tuna |
| Crustacean | whiteleg shrimp, cocktail shrimp, tiger shrimp, blue crab, red crab, snow crab, king crab, lobster |
| Cephalopod | squid, cuttlefish, octopus, webfoot octopus, baby squid |
| Mollusk and shellfish | clam, mussel, blood cockle, cockle, scallop, pen shell adductor, abalone, oyster, turban shell, whelk |
| Sea squirt-like | mideodeok, omandungyi |
| Seafood processed | fish cake sheet, fish cake ball, crab stick, imitation crab, pollack roe, fermented seafood |

Seafood ingredients should carry allergen and freshness review candidates.

---

## 8. Sea Vegetable Registry

Sea vegetables should be treated as both ingredient and Korean food culture data.

Examples:

| Subfamily | Ingredient Examples |
|---|---|
| Dried seaweed | dried miyeok, dried kelp, dried laver |
| Salted seaweed | salted miyeok |
| Laver | traditional gim, parae-gim |
| Premium sea vegetables | gamtae, parae, tot, maesaengi |
| Regional sea vegetables | kkosiraegi, gompi, cheonggak, agar-agar seaweed |
| Processed sea vegetable | miyeok stem, seaweed sheets, seaweed flakes |

Sea vegetable registry should support soup, banchan, gimbap, salad, and side dish use cases.

---

## 9. General Vegetable Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Root vegetables | potato, sweet potato, carrot, radish, kohlrabi, lotus root, burdock, yam, beet, turnip |
| Bulb and allium | onion, red onion, green onion, scallion, chive, garlic, minced garlic, ginger |
| Leaf vegetables | napa cabbage, cabbage, red cabbage, lettuce, perilla leaf, spinach, bok choy, chicory, romaine, mustard leaf, kale, bomdong, young cabbage |
| Fruit vegetables | tomato, cherry tomato, eggplant, cucumber, zucchini, Korean zucchini, pumpkin, kabocha, paprika, bell pepper, cucumber pepper, green chili, cheongyang chili, shishito pepper, red chili |
| Stem vegetables | asparagus, celery, taro stem, sweet potato stem, bamboo shoot |
| Mushrooms | enoki, shiitake, king oyster, oyster mushroom, button mushroom, wood ear, maitake-like mushroom, pine mushroom, neungi mushroom |

Vegetable master must support both raw and cooked preparation states.

---

## 10. Korean Namul And Wild Greens Registry

Korean namul and wild greens require a separate first-class registry.

Examples:

| Subfamily | Ingredient Examples |
|---|---|
| Spring greens | naengi, dallae, sseumbagwi, godeulppaegi, bomdong, wonchuri |
| Tree shoots | cham-dureup, ttang-dureup, gae-dureup, eomnamu shoots, bamboo shoot, gajuk-namul |
| Field greens | mugwort, dolnamul, minari, hanjae minari, dol-minari |
| Mountain greens | chwinamul, chamchwi, gomchwi, miyeokchwi, gosari, gobi, daraesun, bibichu |
| Everyday namul | sesame leaf, gondre, meowi, rape greens, sebal-namul, bireum-namul, chamnamul |
| Stem and vine greens | sweet potato stem, taro stem, pumpkin leaf, dried gourd strip, meowi stem |
| Root medicinal vegetables | deodeok, doraji, sseumbagwi root, taro, dungulle, Jerusalem artichoke |
| Kimjang and winter vegetables | Joseon radish, napa cabbage, altari radish, yeolmu, chorong radish, mustard greens, chives, green onion |
| Korean aromatic vegetables | bangat leaf, jepi, sancho, garlic shoots, dallae, Korean garlic, six-clove garlic, ginger |

Korean namul registry must support seasonal, dried, blanched, seasoned, stir-fried, pickled, and soup-use forms.

---

## 11. Gimbap Ingredient Registry

Gimbap-specific ingredients should be indexed separately for menu and recipe design.

Examples:

| Ingredient | Preparation Form |
|---|---|
| Burdock | Braised burdock |
| Pickled radish | Whole danmuji, yellow danmuji, crunchy danmuji |
| Dried gourd strip | Braised bakgoji |
| Carrot | Julienne stir-fried carrot |
| Spinach | Spinach namul |
| Cucumber | Salt-pickled cucumber, fresh cucumber strips |
| Chive | Stir-fried chive |
| Perilla leaf | Fresh perilla leaf |
| Egg | Egg sheet, egg strip |
| Fish cake | Stir-fried fish cake strip |
| Ham substitute | If used, processed meat risk review |
| Rice | Seasoned rice |
| Gim | Gimbap seaweed sheet |
| Sesame oil | Seasoning oil |
| Sesame seed | Topping/seasoning |

Gimbap ingredients must connect to allergen, processed meat, storage, and freshness notices.

---

## 12. Korean Banchan And Namul Dish Ingredient Registry

Banchan and namul ingredients should support both raw ingredient and prepared dish form.

Examples:

| Dish/Use Type | Ingredient Examples |
|---|---|
| Basic namul | spinach, bean sprout, gosari |
| Field greens | mung bean sprout, minari, chamnamul, bireum, rape greens |
| Stem namul | meowi, meowi stem, sweet potato stem, taro stem |
| Vegetable banchan | steamed eggplant, zucchini, Korean zucchini, pumpkin leaf |
| Mountain namul | chamchwi, gomchwi, gondre, daraesun, gobi, miyeokchwi, bujigaengi |
| Dried namul | dried radish greens, ugeoji, dried chwinamul, dried eggplant, dried pumpkin |
| Fresh seasoned vegetables | radish salad, doraji salad, deodeok salad, dallae salad, naengi salad |
| Leaf geotjeori | napa geotjeori, lettuce geotjeori, bomdong geotjeori |
| Summer vegetables | no-gak, cucumber, eggplant, zucchini |
| Root side dishes | lotus root, burdock, potato, garlic scape |
| Sea vegetable banchan | miyeok stem, tot, parae, kkosiraegi, gompi, maesaengi |
| Pickles and jangajji | myeongi, perilla leaf, garlic, garlic scape, onion chili pickle, maesil, persimmon, radish jangajji |

Prepared dish forms must link back to raw ingredient master.

---

## 13. Grains Noodles Tofu Nuts Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Grains | white rice, glutinous rice, brown rice, black rice, barley, oats, millet, sorghum, quinoa |
| Flour and starch | bread flour, all-purpose flour, cake flour, frying mix, pancake mix, breadcrumbs, glutinous rice flour, potato starch, corn starch, sweet potato starch |
| Noodles | somyeon, jungmyeon, kalguksu, udon, ramen, glass noodle, flat glass noodle, rice noodle, spaghetti, penne, fusilli, lasagna |
| Tofu and soy products | stew tofu, pan-fry tofu, soft tofu, silken tofu, dried tofu, yuba, fried tofu pouch, bean sprout, mung bean sprout |
| Nuts and seeds | peanut, walnut, almond, cashew, macadamia, pistachio, pine nut, chestnut, ginkgo, sunflower seed, pumpkin seed, sesame, roasted sesame, black sesame |

Nuts and sesame should map to allergen candidate tags.

---

## 14. Dairy And Eggs Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Eggs | chicken egg, quail egg, duck egg, smoked egg |
| Milk | whole milk, low-fat milk, sterilized milk |
| Cream | fresh cream, whipping cream, vegetable cream |
| Butter and fat spread | processed butter, natural butter, unsalted butter, salted butter, margarine |
| Fermented dairy | plain yogurt, Greek yogurt, sour cream |
| Cheese | mozzarella, cheddar slice, parmesan powder, cream cheese, ricotta, mascarpone, burrata, gorgonzola, brie, camembert |

Dairy and eggs require allergen mapping and storage review.

---

## 15. Fruit Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Pome and stone fruits | apple, pear, peach, plum, apricot, persimmon, dried persimmon, jujube |
| Citrus | mandarin, orange, lemon, lime, grapefruit, hallabong, lemon juice |
| Berries and grapes | strawberry, blueberry, raspberry, cranberry, grape, Shine Muscat, Kyoho grape |
| Tropical and others | banana, mango, pineapple, kiwi, gold kiwi, avocado, coconut, watermelon, Korean melon, melon, fig |
| Processed fruit | raisin, dried cranberry, strawberry jam, blueberry jam, apple jam |

Fruit ingredients may create seasonal, storage, and seed/pit warning candidates.

---

## 16. Condiments Sauces Fermented Pastes Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Basic seasoning powders | refined salt, sea salt, herb salt, white sugar, brown sugar, dark brown sugar, powdered sugar, ground pepper, whole pepper, chili powder, curry powder, black bean sauce powder |
| Korean fermented pastes | soy sauce, brewed soy sauce, soup soy sauce, gochujang, doenjang, ssamjang, chunjang, cheonggukjang sauce |
| Fish sauce and seasoning liquids | anchovy fish sauce, sand lance fish sauce, tuna extract, chicken stock, yeondu, hondashi |
| Vinegars and fruit syrups | brewed vinegar, apple vinegar, brown rice vinegar, balsamic vinegar, white wine vinegar, maesil syrup, yuja syrup |
| Sweeteners and cooking alcohol | starch syrup, oligosaccharide, cooking syrup, honey, maple syrup, cooking wine, mirin, cheongju, soju, white wine, red wine |
| Popular sauces | oyster sauce, ketchup, mayonnaise, honey mustard, whole grain mustard, tonkatsu sauce, Worcestershire sauce, sriracha, hot sauce, Tabasco, balsamic glaze, doubanjiang, chili sauce |

Sauces can introduce allergens, alcohol, fish/shellfish, gluten, dairy, egg, or spice risk.

---

## 17. Oils And Fats Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Neutral vegetable oils | cooking oil, canola oil, soybean oil, sunflower oil, grapeseed oil, corn oil |
| Flavor oils | pressed sesame oil, perilla oil, chili oil, infused oil |
| Western and premium oils | extra virgin olive oil, pure olive oil, avocado oil, truffle oil |
| Animal fats | lard, beef tallow |

Oils may affect allergen, flavor, vegan/vegetarian, and storage claims.

---

## 18. Herbs And Spices Seed Registry

Seed category examples:

| Subfamily | Ingredient Examples |
|---|---|
| Fresh herbs | basil, arugula, parsley, rosemary, thyme, mint, cilantro, dill |
| Dried herbs and spices | dried basil, oregano, parsley powder, bay leaf, cinnamon powder, vanilla extract, paprika powder, cumin, basil pesto |
| Korean aromatics | bangat leaf, jepi, sancho, garlic shoot, dallae |
| Heat/spice sources | gochugaru, cheongyang chili, hot sauce, chili oil, pepper |
| Flavor concentrates | pesto, curry powder, black bean powder |

Herbs and spices may trigger flavor, spice, allergen, and alcohol extract review.

---

## 19. Processing State Registry

Ingredient processing state must be normalized.

Recommended processing states:

| State | Meaning |
|---|---|
| `FRESH` | Fresh raw ingredient |
| `FROZEN` | Frozen |
| `DRIED` | Dried |
| `SALTED` | Salted |
| `PICKLED` | Pickled |
| `FERMENTED` | Fermented |
| `SMOKED` | Smoked |
| `CANNED` | Canned |
| `BRAISED` | Braised/prepared |
| `BLANCHED` | Blanched |
| `ROASTED` | Roasted |
| `FRIED` | Fried |
| `POWDERED` | Powder |
| `GROUND` | Ground/minced |
| `SLICED` | Sliced |
| `JULIENNED` | Julienned |
| `SEASONED` | Seasoned |
| `SAUCE_BASED` | Sauce form |

Processing state changes shelf life, risk, inventory, and recipe behavior.

---

## 20. Ingredient Risk Flag Registry

Recommended risk flags:

| Risk Flag | Meaning |
|---|---|
| `ALLERGEN_CANDIDATE` | Potential allergen |
| `ALCOHOL_CANDIDATE` | Alcoholic ingredient or beverage |
| `RAW_FOOD_CANDIDATE` | Raw/undercooked use candidate |
| `MARKET_PRICE_CANDIDATE` | Variable price candidate |
| `BONE_SHELL_CANDIDATE` | Bone/shell/pit warning candidate |
| `EXTREME_SPICE_CANDIDATE` | High spice warning candidate |
| `HEALTH_CLAIM_REVIEW` | Claim-sensitive ingredient |
| `FRESHNESS_STORAGE_REVIEW` | Storage/freshness sensitive |
| `PREGNANCY_CAUTION_CANDIDATE` | Caution candidate if policy requires |
| `CHILD_CAUTION_CANDIDATE` | Child caution candidate if policy requires |
| `VEGAN_VEGETARIAN_REVIEW` | Plant-based claim review |
| `HALAL_KOSHER_REVIEW` | Religious dietary claim review |
| `ORIGIN_LABEL_REVIEW` | Origin/source labeling candidate |

Risk flags are candidates until reviewed.

---

## 21. Ingredient Allergen Tag Registry

Candidate allergen tags may include:

| Allergen Tag | Examples |
|---|---|
| `EGG` | Egg, mayonnaise, egg sheet |
| `MILK_DAIRY` | Milk, cheese, cream, butter |
| `WHEAT_GLUTEN` | Flour, noodles, soy sauce candidate |
| `SOY` | Soybean, tofu, soy sauce |
| `PEANUT` | Peanut |
| `TREE_NUT` | Walnut, almond, cashew, pine nut |
| `SESAME` | Sesame, sesame oil, black sesame |
| `FISH` | Fish, anchovy, tuna extract |
| `CRUSTACEAN` | Shrimp, crab, lobster |
| `MOLLUSK_SHELLFISH` | Clam, mussel, oyster, abalone |
| `SULFITE_REVIEW` | Dried fruit, wine, processed foods if applicable |
| `MUSTARD_REVIEW` | Mustard sauce |
| `CELERY_REVIEW` | Celery if policy requires |

Final allergen policy requires food safety/legal review.

---

## 22. Ingredient Usage Tags

Recommended usage tags:

| Usage Tag | Meaning |
|---|---|
| `GIMBAP_CORE` | Common gimbap ingredient |
| `BANCHAN_CORE` | Banchan ingredient |
| `NAMUL_CORE` | Namul ingredient |
| `SOUP_STEW` | Soup/stew ingredient |
| `SAUCE_BASE` | Sauce or seasoning base |
| `KDS_PREP_NOTE` | Requires kitchen note |
| `PICKUP_STORAGE_NOTICE` | Storage notice candidate |
| `DELIVERY_RESTRICTION` | Delivery caution candidate |
| `ALCOHOL_SERVICE` | Alcohol service item |
| `COURSE_COMPONENT` | Course component |
| `SET_COMPONENT` | Set/combo component |
| `OPTION_ADDON` | Option/add-on candidate |
| `INVENTORY_TRACKED` | Inventory-tracked ingredient |
| `PROCUREMENT_ITEM` | Procurement item |
| `SEASONAL_ITEM` | Seasonal ingredient |

Usage tags connect ingredient master to actual operations.

---

## 23. Korean Ingredient Synonym Policy

Korean ingredients often have regional or preparation-based synonyms.

Examples:

| Canonical | Synonyms / Related Terms |
|---|---|
| Meowi | Meogu, meowi stem |
| Sweet potato stem | Goguma-sun, goguma-julgi |
| Mustard greens | Gat, dolsan-gat, cheong-gat, jeok-gat |
| Dureup | Cham-dureup, ttang-dureup, gae-dureup |
| Minari | Hanjae minari, dol-minari |
| Dried radish greens | Siraegi |
| Napa outer leaves | Ugeoji |
| Dried gourd strip | Bakgoji |
| Burdock | Ueong, braised burdock |
| Pickled radish | Danmuji, chija danmuji, crunchy danmuji |
| Perilla leaf | Kkaennip |
| Mugwort | Ssuk |
| Bangat leaf | Baechohyang |

Synonyms must not create duplicate ingredients unless the ingredient is materially different.

---

## 24. Ingredient To Recipe Mapping

Ingredient master must support recipe mapping.

Recipe ingredient mapping should include:

- ingredient ID
- quantity
- unit
- preparation state
- cut shape
- cooking method
- optional/required flag
- substitution allowed flag
- allergen impact
- alcohol impact
- raw food impact
- inventory deduction unit
- procurement item mapping
- yield/waste factor
- KDS prep note
- customer display flag
- legal notice tag

Recipe mapping is future runtime and remains deferred.

---

## 25. Ingredient To Inventory Mapping

Ingredient master should prepare inventory mapping.

Inventory mapping should distinguish:

| Layer | Example |
|---|---|
| Ingredient | Garlic |
| Purchase item | Peeled garlic 1 kg |
| Inventory unit | kg |
| Recipe unit | g |
| Prep state | Minced garlic |
| Yield factor | Loss after peeling |
| Storage group | Refrigerated, frozen, dry |
| Shelf life | Candidate |
| Supplier item | Supplier SKU |
| Substitute | Alternative ingredient |
| Waste tracking | Required if spoilage-sensitive |

Ingredient is not always the same as purchase item.

---

## 26. Ingredient To Legal Notice Mapping

Ingredient master should support legal notice mapping.

Examples:

| Ingredient / Flag | Notice Candidate |
|---|---|
| Shrimp | Shellfish allergy notice |
| Peanut | Peanut allergy notice |
| Egg | Egg allergy notice |
| Milk/cheese/cream | Dairy allergy notice |
| Raw oyster | Raw seafood warning |
| Soju/wine/beer | Alcohol age-gate |
| Market-price crab | Market price confirmation |
| Extra spicy chili | Spice warning |
| Fish with bones | Bone warning |
| Fresh cream dessert | Storage/freshness notice |
| Detox wording | Health claim review |
| Wine in sauce | Alcohol ingredient review |

Mapping creates candidates, not final legal approval.

---

## 27. Ingredient Review States

Recommended review states:

| State | Meaning |
|---|---|
| `SEED_DRAFT` | Draft seed ingredient |
| `NORMALIZATION_REVIEW_REQUIRED` | Name/synonym review needed |
| `CATEGORY_REVIEW_REQUIRED` | Category review needed |
| `RISK_REVIEW_REQUIRED` | Risk tag review needed |
| `ALLERGEN_REVIEW_REQUIRED` | Allergen review needed |
| `LEGAL_REVIEW_REQUIRED` | Legal notice review needed |
| `I18N_REVIEW_REQUIRED` | Translation review needed |
| `APPROVED_FOR_MASTER` | Approved as master ingredient |
| `APPROVED_FOR_RECIPE_USE` | Approved for recipe mapping |
| `DEPRECATED` | No longer used |
| `MERGED` | Merged into canonical ingredient |
| `BLOCKED` | Cannot use |

Ingredient approval level must be separate from recipe approval.

---

## 28. Seed Import Governance

Ingredient seed import must follow these rules:

1. Seed import does not mean production approval.
2. Duplicate detection is required.
3. Synonym normalization is required.
4. Category mapping is required.
5. Allergen/risk flags are draft until reviewed.
6. Local Korean ingredients must not be dropped.
7. Processing state must not create uncontrolled duplicates.
8. Ingredient master must support future i18n.
9. High-risk flags require domain/legal review.
10. Tenant-specific custom ingredients must not pollute global master without review.

Seed import must be controlled.

---

## 29. Audit Events

Recommended audit events:

| Event Type | Meaning |
|---|---|
| `INGREDIENT_MASTER_SEED_CREATED` | Ingredient seed created |
| `INGREDIENT_MASTER_IMPORTED` | Ingredient imported |
| `INGREDIENT_CATEGORY_ASSIGNED` | Category assigned |
| `INGREDIENT_SYNONYM_ADDED` | Synonym added |
| `INGREDIENT_DUPLICATE_DETECTED` | Duplicate detected |
| `INGREDIENT_MERGED` | Ingredient merged |
| `INGREDIENT_RISK_FLAG_ASSIGNED` | Risk flag assigned |
| `INGREDIENT_ALLERGEN_TAG_ASSIGNED` | Allergen tag assigned |
| `INGREDIENT_LEGAL_NOTICE_MAPPING_CREATED` | Notice mapping created |
| `INGREDIENT_REVIEW_REQUESTED` | Review requested |
| `INGREDIENT_APPROVED_FOR_MASTER` | Master approval |
| `INGREDIENT_APPROVED_FOR_RECIPE_USE` | Recipe-use approval |
| `INGREDIENT_DEPRECATED` | Ingredient deprecated |
| `INGREDIENT_BLOCKED` | Ingredient blocked |

Events must route through `10610` if implemented later.

---

## 30. Security Boundary

Ingredient master security rules:

- global master and tenant custom ingredients must be separated
- tenant custom ingredients must not leak
- supplier/procurement mapping may be tenant-sensitive
- recipe mapping may be trade-secret-sensitive
- allergen and food safety tags require controlled review
- AI-generated tags must be marked draft
- high-risk changes must be audited
- ingredient merge must preserve history
- ingredient deletion should be avoided after recipe/evidence linkage
- support views should expose only necessary ingredient information

Ingredient master is operational and compliance infrastructure.

---

## 31. Anti-Patterns

Avoid:

- treating ingredient list as flat text only
- excluding Korean namul and wild greens
- merging different processing states incorrectly
- creating duplicates for every synonym
- treating AI allergen tags as final
- treating alcohol in cooking sauce as always irrelevant
- hiding market-price seafood risk
- ignoring set/combo ingredient inheritance
- ignoring option/add-on ingredient risk
- using ingredient master as recipe truth without review
- exposing tenant custom recipe ingredients across tenants
- deleting ingredient master rows after use
- importing huge seed list as approved production data
- dropping local Korean ingredient names during English normalization

These anti-patterns must remain prohibited.

---

## 32. Runtime Deferral

This document defines ingredient master pool taxonomy and Korean namul seed registry governance only.

It does not authorize:

- ingredient database implementation
- seed import implementation
- recipe database implementation
- inventory database implementation
- allergen engine implementation
- legal notice trigger implementation
- procurement mapping implementation
- AI ingredient classifier runtime
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 33. Validation Checklist

Validation must confirm:

1. Ingredient master object is defined.
2. Ingredient category families are defined.
3. Meat and poultry seed registry is defined.
4. Seafood and shellfish seed registry is defined.
5. Sea vegetable registry is defined.
6. General vegetable registry is defined.
7. Korean namul and wild greens registry is defined.
8. Gimbap ingredient registry is defined.
9. Korean banchan and namul dish ingredient registry is defined.
10. Grains/noodles/tofu/nuts registry is defined.
11. Dairy and eggs registry is defined.
12. Fruit registry is defined.
13. Condiments/sauces/fermented pastes registry is defined.
14. Oils and fats registry is defined.
15. Herbs and spices registry is defined.
16. Processing state registry is defined.
17. Ingredient risk flag registry is defined.
18. Ingredient allergen tag registry is defined.
19. Ingredient usage tags are defined.
20. Korean ingredient synonym policy is defined.
21. Ingredient-to-recipe mapping is defined.
22. Ingredient-to-inventory mapping is defined.
23. Ingredient-to-legal-notice mapping is defined.
24. Ingredient review states are defined.
25. Seed import governance is defined.
26. Audit events are defined.
27. Security boundary is defined.
28. Anti-patterns are listed.
29. Coding remains unauthorized.
30. Runtime remains deferred.

---

## 34. Relationship To Previous Documents

This document follows and supplements:

- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10703 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `10704 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `10705` through `10714` AI Menu Taxonomy Seed Registry policies
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`
- `10802 Menu Material Intake Photo PDF Text And POS Export Policy`
- `10803 AI Menu Parsing Correction And Owner Review Workflow Policy`
- `10804 Menu Category Option Set Combo Course Review Policy`
- `10805 Allergen Alcohol Raw Food Market Price Detection Handoff Policy`

It prepares:

- `10806 Store Service Mode Selection And Feature Readiness Policy`
- `10807 POS Payment KDS Integration Readiness Intake Policy`
- `10808 Store Legal Notice Variable Setup And Owner Confirmation Policy`
- future Recipe, Inventory, Procurement, and Allergen Master documents

This document is architecture boundary planning only.

It does not authorize coding.

---

## 35. Final Rule

Catch Menu must treat ingredient master data as a normalized, reviewable, risk-aware, Korean-food-capable registry.

Global ingredients, Korean namul, wild greens, sea vegetables, gimbap ingredients, banchan ingredients, sauces, oils, herbs, processed foods, and preparation states must be preserved as structured master data rather than flat text.

AI may suggest ingredient normalization, synonyms, categories, allergens, and risk flags.

AI cannot approve ingredient facts, allergen tags, alcohol tags, health claims, recipe truth, legal notice mapping, or production seed activation.

Ingredient master planning remains static.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
