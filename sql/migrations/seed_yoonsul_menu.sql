-- seed_yoonsul_menu.sql
-- Purpose: Yoonsul Kimbap full menu seed data
-- Tenant:  00000000-0000-0000-0000-000000000001
-- Store:   00000000-0000-0000-0000-000000000002
-- Total:   64 menus + 13 categories
-- Source:  yoonsul_menu_sop_from_photo_21392.zip

-- =============================================
-- 1. 카테고리 등록
-- =============================================
-- 기존 데이터 초기화 (FK 순서 준수)
-- 1. menu_option_items (최하위)
DELETE FROM catchmenu_pos.menu_option_items
WHERE option_group_id IN (
  SELECT id FROM catchmenu_pos.menu_option_groups
  WHERE menu_id IN (
    SELECT id FROM catchmenu_pos.menus
    WHERE store_id = '00000000-0000-0000-0000-000000000002'
      AND tenant_id = '00000000-0000-0000-0000-000000000001'
  )
);

-- 2. menu_option_groups
DELETE FROM catchmenu_pos.menu_option_groups
WHERE menu_id IN (
  SELECT id FROM catchmenu_pos.menus
  WHERE store_id = '00000000-0000-0000-0000-000000000002'
    AND tenant_id = '00000000-0000-0000-0000-000000000001'
);

-- 3. menu_allergen_links
DELETE FROM catchmenu_pos.menu_allergen_links
WHERE menu_id IN (
  SELECT id FROM catchmenu_pos.menus
  WHERE store_id = '00000000-0000-0000-0000-000000000002'
    AND tenant_id = '00000000-0000-0000-0000-000000000001'
);

-- 4. menu_i18n
DELETE FROM catchmenu_pos.menu_i18n
WHERE menu_id IN (
  SELECT id FROM catchmenu_pos.menus
  WHERE store_id = '00000000-0000-0000-0000-000000000002'
    AND tenant_id = '00000000-0000-0000-0000-000000000001'
);

-- 5. menus
DELETE FROM catchmenu_pos.menus
WHERE store_id = '00000000-0000-0000-0000-000000000002'
  AND tenant_id = '00000000-0000-0000-0000-000000000001';

-- 6. menu_categories (최상위)
DELETE FROM catchmenu_pos.menu_categories
WHERE store_id = '00000000-0000-0000-0000-000000000002'
  AND tenant_id = '00000000-0000-0000-0000-000000000001';

INSERT INTO catchmenu_pos.menu_categories (
  tenant_id, store_id,
  category_code, category_name,
  display_order, is_active
) VALUES
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-001', '기본김밥', 1, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-002', '고추', 2, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-003', '참치듬뿍마요', 3, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-004', '치즈견과류', 4, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-005', '소고기', 5, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-006', '소시지스팸', 6, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-007', '날치알크래미', 7, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-008', '바삭바삭', 8, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-009', '와사비', 9, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-010', '어린이', 10, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-011', '다이어트김밥_키토김밥', 11, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-012', '짝꿍', 12, true),
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'CAT-013', '음료', 13, true)
;

-- =============================================
-- 2. 메뉴 등록
-- allergen_info: object 형태 (chk_menu_allergen_object 준수)
-- is_kds_required: 김밥/분식류 true, 음료 false
-- =============================================

-- 기본김밥 (CAT-001)
INSERT INTO catchmenu_pos.menus (
  tenant_id, store_id, category_id,
  menu_code, menu_name,
  menu_name_en, menu_name_zh, menu_name_ja,
  description, price,
  menu_status, is_kds_required, kitchen_zone,
  estimated_minutes, prep_complexity,
  allergen_info, display_order, is_active
) VALUES
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-001' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KB-001', '윤슬김밥', 'Yoonsul Kimbap', NULL, NULL,
   '대표 기본 메뉴. 시금치, 부추, 어묵, 햄, 계란, 단무지',
   5300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-001' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KB-002', '치즈김밥', 'Cheese Kimbap', NULL, NULL,
   '기본 구성 + 치즈',
   5300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-001' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KB-003', '멸치김밥', 'Anchovy Kimbap', NULL, NULL,
   '기본 구성 + 볶음 멸치',
   5300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-001' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KB-004', '참치김밥', 'Tuna Kimbap', NULL, NULL,
   '기본 구성 + 참치마요',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   4, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-001' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KB-005', '소고기김밥', 'Beef Kimbap', NULL, NULL,
   '기본 구성 + 소불고기양념',
   5800, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": true, "sesame": true}',
   5, true),

-- 고추 (CAT-002)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-002' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KH-001', '매운오뎅김밥', 'Spicy Fish Cake Kimbap', NULL, NULL,
   '기본 구성 + 매운 오뎅. 매운 메뉴.',
   5600, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-002' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KH-002', '땡초김치김밥', 'Spicy Kimchi Kimbap', NULL, NULL,
   '기본 구성 + 땡초김치. 매운 메뉴.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-002' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KH-003', '땡초멸치김밥', 'Spicy Anchovy Kimbap', NULL, NULL,
   '기본 구성 + 땡초, 멸치. 매운 메뉴.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-002' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KH-004', '불오징어김밥', 'Spicy Squid Kimbap', NULL, NULL,
   '기본 구성 + 불오징어. 매운 메뉴.',
   6600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "shellfish": true, "gluten": true, "sesame": true}',
   4, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-002' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KH-005', '매콤불갈비김밥', 'Spicy Bulgalbi Kimbap', NULL, NULL,
   '기본 구성 + 매콤불갈비/제육. 추천/매운 메뉴.',
   6300, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": true, "sesame": true}',
   5, true),

-- 참치듬뿍마요 (CAT-003)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-003' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KT-001', '땡초참치김밥', 'Spicy Tuna Kimbap', NULL, NULL,
   '기본 구성 + 참치마요 + 땡초. 매운 메뉴.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-003' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KT-002', '김치참치김밥', 'Kimchi Tuna Kimbap', NULL, NULL,
   '기본 구성 + 참치마요 + 김치.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-003' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KT-003', '치즈참치김밥', 'Cheese Tuna Kimbap', NULL, NULL,
   '기본 구성 + 참치마요 + 치즈.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "fish": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-003' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KT-004', '명란마요참치김밥', 'Mentaiko Tuna Kimbap', NULL, NULL,
   '기본 구성 + 참치마요 + 명란마요. 추천 메뉴.',
   6600, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   4, true),

-- 치즈견과류 (CAT-004)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-004' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KC-001', '견과류김밥', 'Nut Kimbap', NULL, NULL,
   '기본 구성 + 견과류. 견과류 알레르기 주의.',
   5300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "nuts": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-004' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KC-002', '땡초견과류김밥', 'Spicy Nut Kimbap', NULL, NULL,
   '기본 구성 + 견과류 + 땡초. 매운/견과류 주의.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "nuts": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-004' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KC-003', '더블치즈김밥', 'Double Cheese Kimbap', NULL, NULL,
   '기본 구성 + 치즈 2배.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-004' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KC-004', '치란김밥', 'Cheese Egg Kimbap', NULL, NULL,
   '기본 구성 + 치즈 + 계란 강화.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   4, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-004' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KC-005', '크림치즈김밥', 'Cream Cheese Kimbap', NULL, NULL,
   '기본 구성 + 크림치즈.',
   5300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   5, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-004' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KC-006', '크림치즈견과류김밥', 'Cream Cheese Nut Kimbap', NULL, NULL,
   '기본 구성 + 크림치즈 + 견과류. 추천 메뉴.',
   6000, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "nuts": true, "gluten": true, "sesame": true}',
   6, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-004' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KC-007', '크림치즈소고기김밥', 'Cream Cheese Beef Kimbap', NULL, NULL,
   '기본 구성 + 크림치즈 + 소고기.',
   6600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "dairy": true, "soy": true, "gluten": true, "sesame": true}',
   7, true),

-- 소고기 (CAT-005)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-005' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KG-001', '와사비소고기김밥', 'Wasabi Beef Kimbap', NULL, NULL,
   '기본 구성 + 소고기 + 와사비소스. 와사비 주의.',
   6300, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-005' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KG-002', '김치소고기김밥', 'Kimchi Beef Kimbap', NULL, NULL,
   '기본 구성 + 소고기 + 김치.',
   6300, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-005' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KG-003', '명란마요소고기김밥', 'Mentaiko Beef Kimbap', NULL, NULL,
   '기본 구성 + 소고기 + 명란마요.',
   6600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "fish": true, "soy": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-005' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KG-004', '갈릭베이컨소고기김밥', 'Garlic Bacon Beef Kimbap', NULL, NULL,
   '기본 구성 + 소고기 + 갈릭베이컨. 추천 메뉴.',
   6800, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": true, "sesame": true}',
   4, true),

-- 소시지스팸 (CAT-006)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-006' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KS-001', '떡갈비김밥', 'Tteokgalbi Kimbap', NULL, NULL,
   '기본 구성 + 떡갈비.',
   5600, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-006' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KS-002', '명란마요베이컨김밥', 'Mentaiko Bacon Kimbap', NULL, NULL,
   '기본 구성 + 명란마요 + 베이컨.',
   6000, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-006' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KS-003', '베이컨치란김밥', 'Bacon Cheese Egg Kimbap', NULL, NULL,
   '기본 구성 + 베이컨 + 치즈 + 계란.',
   6000, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-006' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KS-004', '스팸김밥', 'Spam Kimbap', NULL, NULL,
   '기본 구성 + 스팸.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "gluten": true, "sesame": true}',
   4, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-006' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KS-005', '스팸치즈김밥', 'Spam Cheese Kimbap', NULL, NULL,
   '기본 구성 + 스팸 + 치즈.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   5, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-006' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KS-006', '스팸김치김밥', 'Spam Kimchi Kimbap', NULL, NULL,
   '기본 구성 + 스팸 + 김치. 추천 메뉴.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "gluten": true, "sesame": true}',
   6, true),

-- 날치알크래미 (CAT-007)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-007' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KN-001', '날치알김밥', 'Flying Fish Roe Kimbap', NULL, NULL,
   '기본 구성 + 날치알. 수산물 알레르기 주의.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-007' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KN-002', '크래미김밥', 'Crab Stick Kimbap', NULL, NULL,
   '기본 구성 + 크래미. 수산물 알레르기 주의.',
   5800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "shellfish": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-007' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KN-003', '크래미날치알김밥', 'Crab Roe Kimbap', NULL, NULL,
   '기본 구성 + 크래미 + 날치알. 추천 메뉴.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "shellfish": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-007' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KN-004', '왕새우날치알김밥', 'Shrimp Roe Kimbap', NULL, NULL,
   '기본 구성 + 왕새우 + 날치알. 프리미엄 메뉴.',
   6600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "fish": true, "shellfish": true, "gluten": true, "sesame": true}',
   4, true),

-- 바삭바삭 (CAT-008)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-008' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KR-001', '왕새우김밥', 'Shrimp Tempura Kimbap', NULL, NULL,
   '기본 구성 + 왕새우튀김.',
   6000, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "shellfish": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-008' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KR-002', '흑돼지돈까스김밥', 'Black Pork Cutlet Kimbap', NULL, NULL,
   '기본 구성 + 흑돼지돈까스. 추천 메뉴.',
   6000, 'AVAILABLE', true, 'MAIN', 7, 'COMPLEX',
   '{"eggs": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-008' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KR-003', '흑돼지돈까스치즈김밥', 'Black Pork Cutlet Cheese Kimbap', NULL, NULL,
   '기본 구성 + 흑돼지돈까스 + 치즈.',
   6600, 'AVAILABLE', true, 'MAIN', 7, 'COMPLEX',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   3, true),

-- 와사비 (CAT-009)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-009' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KW-001', '와사비참치김밥', 'Wasabi Tuna Kimbap', NULL, NULL,
   '기본 구성 + 참치마요 + 와사비. 와사비 주의.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-009' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KW-002', '와사비크래미김밥', 'Wasabi Crab Kimbap', NULL, NULL,
   '기본 구성 + 크래미 + 와사비. 와사비/수산물 주의.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "shellfish": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-009' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KW-003', '와사비날치알김밥', 'Wasabi Roe Kimbap', NULL, NULL,
   '기본 구성 + 날치알 + 와사비. 와사비/수산물 주의.',
   6300, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-009' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KW-004', '와사비크래미날치알김밥', 'Wasabi Crab Roe Kimbap', NULL, NULL,
   '기본 구성 + 크래미 + 날치알 + 와사비. 추천 메뉴.',
   6800, 'AVAILABLE', true, 'MAIN', 5, 'NORMAL',
   '{"eggs": true, "fish": true, "shellfish": true, "gluten": true, "sesame": true}',
   4, true),

-- 어린이 (CAT-010)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-010' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KI-001', '어린이김밥', 'Kids Kimbap', NULL, NULL,
   '작은 사이즈. 맵지 않은 기본 구성.',
   3800, 'AVAILABLE', true, 'MAIN', 4, 'SIMPLE',
   '{"eggs": true, "gluten": true, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-010' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KI-002', '치즈어린이김밥', 'Kids Cheese Kimbap', NULL, NULL,
   '어린이 기본 + 치즈.',
   4300, 'AVAILABLE', true, 'MAIN', 4, 'SIMPLE',
   '{"eggs": true, "dairy": true, "gluten": true, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-010' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KI-003', '참치어린이김밥', 'Kids Tuna Kimbap', NULL, NULL,
   '어린이 기본 + 참치마요.',
   4800, 'AVAILABLE', true, 'MAIN', 4, 'SIMPLE',
   '{"eggs": true, "fish": true, "gluten": true, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-010' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KI-004', '소고기어린이김밥', 'Kids Beef Kimbap', NULL, NULL,
   '어린이 기본 + 소고기.',
   4800, 'AVAILABLE', true, 'MAIN', 4, 'SIMPLE',
   '{"eggs": true, "soy": true, "gluten": true, "sesame": true}',
   4, true),

-- 키토김밥 (CAT-011)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-001', '윤슬키토김밥', 'Yoonsul Keto Kimbap', NULL, NULL,
   '밥 대신 계란/채소 중심 키토 구성. 다이어트 메뉴.',
   6600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "gluten": false, "sesame": true}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-002', '불오뎅키토김밥', 'Spicy Fish Cake Keto Kimbap', NULL, NULL,
   '키토 기본 + 불오뎅.',
   7000, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": false, "sesame": true}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-003', '견과류키토김밥', 'Nut Keto Kimbap', NULL, NULL,
   '키토 기본 + 견과류.',
   7000, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "nuts": true, "gluten": false, "sesame": true}',
   3, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-004', '참치키토김밥', 'Tuna Keto Kimbap', NULL, NULL,
   '키토 기본 + 참치마요.',
   7600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": false, "sesame": true}',
   4, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-005', '소고기키토김밥', 'Beef Keto Kimbap', NULL, NULL,
   '키토 기본 + 소고기.',
   7600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": false, "sesame": true}',
   5, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-006', '매콤진미키토김밥', 'Spicy Jinmi Keto Kimbap', NULL, NULL,
   '키토 기본 + 매콤진미.',
   7600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "shellfish": true, "gluten": false, "sesame": true}',
   6, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-007', '크래미키토김밥', 'Crab Keto Kimbap', NULL, NULL,
   '키토 기본 + 크래미.',
   7600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "shellfish": true, "gluten": false, "sesame": true}',
   7, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-008', '스팸키토김밥', 'Spam Keto Kimbap', NULL, NULL,
   '키토 기본 + 스팸.',
   7600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "gluten": false, "sesame": true}',
   8, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-009', '명란마요베이컨키토김밥', 'Mentaiko Bacon Keto Kimbap', NULL, NULL,
   '키토 기본 + 명란마요 + 베이컨.',
   7600, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "fish": true, "gluten": false, "sesame": true}',
   9, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-010', '매콤불갈비키토김밥', 'Spicy Bulgalbi Keto Kimbap', NULL, NULL,
   '키토 기본 + 매콤불갈비/제육.',
   7800, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "soy": true, "gluten": false, "sesame": true}',
   10, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-011', '불오징어키토김밥', 'Spicy Squid Keto Kimbap', NULL, NULL,
   '키토 기본 + 불오징어.',
   8000, 'AVAILABLE', true, 'MAIN', 6, 'NORMAL',
   '{"eggs": true, "shellfish": true, "gluten": false, "sesame": true}',
   11, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-011' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KK-012', '치즈롤', 'Cheese Roll', NULL, NULL,
   '치즈 중심 롤 메뉴.',
   8000, 'AVAILABLE', true, 'MAIN', 7, 'COMPLEX',
   '{"eggs": true, "dairy": true, "gluten": false, "sesame": true}',
   12, true),

-- 짝꿍 (CAT-012)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-012' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KJ-001', '떡볶이', 'Tteokbokki', NULL, NULL,
   '떡, 오뎅, 떡볶이소스.',
   5800, 'AVAILABLE', true, 'SIDE', 7, 'NORMAL',
   '{"eggs": false, "gluten": true, "sesame": false}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-012' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KJ-002', '모둠튀김', 'Assorted Tempura', NULL, NULL,
   '튀김류 모둠 구성.',
   6500, 'AVAILABLE', true, 'SIDE', 8, 'NORMAL',
   '{"eggs": true, "gluten": true, "sesame": false}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-012' AND store_id='00000000-0000-0000-0000-000000000002'),
   'KJ-003', '꼬불이어묵', 'Curly Fish Cake', NULL, NULL,
   '꼬불이 어묵, 어묵국물. 계절 메뉴.',
   5000, 'AVAILABLE', true, 'SIDE', 6, 'SIMPLE',
   '{"eggs": false, "fish": true, "gluten": true, "sesame": false}',
   3, true),

-- 음료 (CAT-013)
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-013' AND store_id='00000000-0000-0000-0000-000000000002'),
   'DR-001', '전통식혜', 'Traditional Sikhye', NULL, NULL,
   '전통 쌀음료.',
   3500, 'AVAILABLE', false, 'BAR', 1, 'SIMPLE',
   '{"eggs": false, "gluten": false}',
   1, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-013' AND store_id='00000000-0000-0000-0000-000000000002'),
   'DR-002', '단호박식혜', 'Sweet Pumpkin Sikhye', NULL, NULL,
   '단호박 쌀음료.',
   3500, 'AVAILABLE', false, 'BAR', 1, 'SIMPLE',
   '{"eggs": false, "gluten": false}',
   2, true),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   (SELECT id FROM catchmenu_pos.menu_categories WHERE category_code='CAT-013' AND store_id='00000000-0000-0000-0000-000000000002'),
   'DR-003', '아메리카노', 'Americano', NULL, NULL,
   '아메리카노.',
   3000, 'AVAILABLE', false, 'BAR', 2, 'SIMPLE',
   '{"eggs": false, "gluten": false}',
   3, true)

;

-- =============================================
-- 3. 검증
-- =============================================
SELECT
  c.category_name,
  count(m.id) as menu_count,
  min(m.price) as min_price,
  max(m.price) as max_price
FROM catchmenu_pos.menu_categories c
LEFT JOIN catchmenu_pos.menus m
  ON m.category_id = c.id
  AND m.store_id = '00000000-0000-0000-0000-000000000002'
WHERE c.store_id = '00000000-0000-0000-0000-000000000002'
GROUP BY c.category_name, c.display_order
ORDER BY c.display_order;
