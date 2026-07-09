-- 0141_hyper_personalization_menu_customization.sql
-- Purpose: Hyper-personalization menu customization and pricing
-- Schema:  catchmenu_pos, catchmenu_kds
-- Ref:     900178_Policy_Hyper_Personalization_Menu_Customization_And_Pricing.md
-- Depends: 0139_create_ai_inference_log.sql

-- =============================================
-- 1. menu_option_groups 확장
-- =============================================
ALTER TABLE catchmenu_pos.menu_option_groups
  ADD COLUMN IF NOT EXISTS
    group_type text NOT NULL DEFAULT 'ADD',
  ADD COLUMN IF NOT EXISTS
    is_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS
    min_select int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS
    max_select int NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS
    display_order int NOT NULL DEFAULT 0;

ALTER TABLE catchmenu_pos.menu_option_groups
  DROP CONSTRAINT IF EXISTS chk_group_type;
ALTER TABLE catchmenu_pos.menu_option_groups
  ADD CONSTRAINT chk_group_type
    CHECK (group_type IN (
      'ADD', 'REMOVE', 'EXTRA',
      'SUBSTITUTE', 'LESS'
    ));
ALTER TABLE catchmenu_pos.menu_option_groups
  DROP CONSTRAINT IF EXISTS chk_select_range;
ALTER TABLE catchmenu_pos.menu_option_groups
  ADD CONSTRAINT chk_select_range
    CHECK (min_select <= max_select);

COMMENT ON COLUMN catchmenu_pos.menu_option_groups.group_type IS
  'ADD=추가 REMOVE=제거 EXTRA=증량 SUBSTITUTE=대체 LESS=감량';
COMMENT ON COLUMN catchmenu_pos.menu_option_groups.min_select IS
  '최소 선택 수 (0=선택 안 해도 됨)';
COMMENT ON COLUMN catchmenu_pos.menu_option_groups.max_select IS
  '최대 선택 수';

-- =============================================
-- 2. menu_option_items 확장
-- =============================================
ALTER TABLE catchmenu_pos.menu_option_items
  ADD COLUMN IF NOT EXISTS
    price_delta int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS
    is_default_included boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS
    is_removable boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS
    max_extra_qty int NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS
    allergen_delta jsonb NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS
    kitchen_note text,
  ADD COLUMN IF NOT EXISTS
    display_order int NOT NULL DEFAULT 0;

COMMENT ON COLUMN catchmenu_pos.menu_option_items.price_delta IS
  '가격 변동. 양수=추가금 0=무료 음수=할인';
COMMENT ON COLUMN catchmenu_pos.menu_option_items.is_default_included IS
  '기본 메뉴에 포함된 재료인지';
COMMENT ON COLUMN catchmenu_pos.menu_option_items.allergen_delta IS
  '이 옵션 선택 시 알레르겐 변화 {"eggs": true} = 계란 추가';
COMMENT ON COLUMN catchmenu_pos.menu_option_items.kitchen_note IS
  'KDS 에 표시할 주방 지시사항';

-- =============================================
-- 3. order_items 확장
-- =============================================
ALTER TABLE catchmenu_pos.order_items
  ADD COLUMN IF NOT EXISTS
    base_price int,
  ADD COLUMN IF NOT EXISTS
    option_price_delta int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS
    final_price int,
  ADD COLUMN IF NOT EXISTS
    customization_log jsonb NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS
    customization_allergen_final jsonb NOT NULL DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS
    has_customization boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN catchmenu_pos.order_items.base_price IS
  '주문 시점 베이스 메뉴 가격 스냅샷';
COMMENT ON COLUMN catchmenu_pos.order_items.option_price_delta IS
  '옵션 합산 가격 변동';
COMMENT ON COLUMN catchmenu_pos.order_items.final_price IS
  'base_price + option_price_delta';
COMMENT ON COLUMN catchmenu_pos.order_items.customization_log IS
  '선택한 옵션 전체 기록
   [{"option_item_id":"...",
     "option_name":"계란지단 추가",
     "option_type":"ADD",
     "qty":1,
     "price_delta":500,
     "kitchen_note":"계란지단 2장"}]';
COMMENT ON COLUMN catchmenu_pos.order_items.customization_allergen_final IS
  '최종 알레르겐 (베이스 + 옵션 반영)';
COMMENT ON COLUMN catchmenu_pos.order_items.has_customization IS
  '커스터마이징 여부 빠른 체크';

-- =============================================
-- 4. kds_tickets 확장
-- =============================================
ALTER TABLE catchmenu_kds.kds_tickets
  ADD COLUMN IF NOT EXISTS
    customization_display text,
  ADD COLUMN IF NOT EXISTS
    has_customization boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN catchmenu_kds.kds_tickets.customization_display IS
  'KDS 화면 표시용 요약 예: ▼단무지 ▲계란지단×2 ▲참기름';
COMMENT ON COLUMN catchmenu_kds.kds_tickets.has_customization IS
  '커스터마이징 있는 티켓 빠른 필터';

-- =============================================
-- 5. RPC: get_menu_customization_options
-- =============================================
CREATE OR REPLACE FUNCTION
  catchmenu_pos.get_menu_customization_options(
  p_menu_id uuid,
  p_tenant_id uuid,
  p_locale text DEFAULT 'ko'
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catchmenu_pos
AS $$
DECLARE
  v_menu record;
  v_groups jsonb;
  v_result jsonb;
BEGIN
  -- 메뉴 기본 정보
  SELECT
    m.id,
    m.menu_name,
    m.price
  INTO v_menu
  FROM catchmenu_pos.menus m
  WHERE m.id = p_menu_id
    AND m.tenant_id = p_tenant_id
    AND m.menu_status = 'AVAILABLE';

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'MENU_NOT_FOUND'
    );
  END IF;

  -- 옵션 그룹 + 항목
  SELECT jsonb_agg(
    jsonb_build_object(
      'group_id', g.id,
      'group_name', g.group_name,
      'group_type', g.group_type,
      'is_required', g.is_required,
      'min_select', g.min_select,
      'max_select', g.max_select,
      'items', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'item_id', i.id,
            'item_name', i.item_name,
            'price_delta', i.price_delta,
            'is_default_included', i.is_default_included,
            'is_removable', i.is_removable,
            'max_extra_qty', i.max_extra_qty,
            'allergen_delta', i.allergen_delta,
            'kitchen_note', i.kitchen_note,
            'display_order', i.display_order
          )
          ORDER BY i.display_order ASC
        )
        FROM catchmenu_pos.menu_option_items i
        WHERE i.option_group_id = g.id
          AND i.is_active = true
      )
    )
    ORDER BY g.display_order ASC
  )
  INTO v_groups
  FROM catchmenu_pos.menu_option_groups g
  WHERE g.menu_id = p_menu_id
    AND g.is_active = true;

  RETURN jsonb_build_object(
    'success', true,
    'menu_id', v_menu.id,
    'menu_name', v_menu.menu_name,
    'base_price', v_menu.price,
    'option_groups', COALESCE(v_groups, '[]'::jsonb)
  );
END;
$$;

-- =============================================
-- 6. RPC: calculate_customization_price
-- =============================================
CREATE OR REPLACE FUNCTION
  catchmenu_pos.calculate_customization_price(
  p_menu_id uuid,
  p_tenant_id uuid,
  p_selected_options jsonb
  -- [{"option_item_id": "...", "qty": 1}]
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catchmenu_pos
AS $$
DECLARE
  v_base_price int;
  v_option_delta int := 0;
  v_breakdown jsonb := '[]'::jsonb;
  v_allergen_base jsonb;
  v_allergen_final jsonb;
  v_display_parts text[] := '{}';
  v_opt record;
  v_item record;
  v_qty int;
BEGIN
  -- 베이스 가격
  SELECT price, allergen_info
  INTO v_base_price, v_allergen_base
  FROM catchmenu_pos.menus
  WHERE id = p_menu_id
    AND tenant_id = p_tenant_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'MENU_NOT_FOUND'
    );
  END IF;

  v_allergen_final := COALESCE(v_allergen_base, '{}');

  -- 각 옵션 계산
  FOR v_opt IN
    SELECT
      (opt->>'option_item_id')::uuid as item_id,
      COALESCE((opt->>'qty')::int, 1) as qty
    FROM jsonb_array_elements(p_selected_options) opt
  LOOP
    SELECT
      i.item_name,
      i.price_delta,
      i.allergen_delta,
      i.kitchen_note,
      g.group_type
    INTO v_item
    FROM catchmenu_pos.menu_option_items i
    JOIN catchmenu_pos.menu_option_groups g
      ON g.id = i.option_group_id
    WHERE i.id = v_opt.item_id
      AND i.is_active = true;

    IF NOT FOUND THEN CONTINUE; END IF;

    v_qty := v_opt.qty;
    v_option_delta := v_option_delta
      + (v_item.price_delta * v_qty);

    -- breakdown 추가
    v_breakdown := v_breakdown || jsonb_build_object(
      'name', v_item.item_name,
      'delta', v_item.price_delta * v_qty,
      'qty', v_qty,
      'type', v_item.group_type
    );

    -- 알레르겐 반영
    v_allergen_final := v_allergen_final
      || v_item.allergen_delta;

    -- KDS 표시 문자열
    v_display_parts := v_display_parts ||
      CASE v_item.group_type
        WHEN 'REMOVE' THEN '▼' || v_item.item_name
        WHEN 'ADD' THEN '▲' || v_item.item_name
          || CASE WHEN v_qty > 1
             THEN '×' || v_qty ELSE '' END
        WHEN 'EXTRA' THEN '▲' || v_item.item_name || '더'
        WHEN 'LESS' THEN '▽' || v_item.item_name || '적게'
        ELSE v_item.item_name
      END;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'base_price', v_base_price,
    'option_price_delta', v_option_delta,
    'final_price', v_base_price + v_option_delta,
    'price_breakdown', v_breakdown,
    'allergen_final', v_allergen_final,
    'customization_display',
      array_to_string(v_display_parts, ' ')
  );
END;
$$;

-- =============================================
-- 7. 윤슬김밥 옵션 시드 데이터
-- =============================================

-- 제거 가능 재료 그룹
WITH menu AS (
  SELECT id, store_id FROM catchmenu_pos.menus
  WHERE menu_code = 'KB-001'
    AND store_id = '00000000-0000-0000-0000-000000000002'
  LIMIT 1
)
INSERT INTO catchmenu_pos.menu_option_groups (
  tenant_id, store_id, menu_id,
  group_code, group_name, group_type,
  is_required, min_select, max_select,
  display_order, is_active
)
SELECT
  '00000000-0000-0000-0000-000000000001',
  menu.store_id,
  menu.id,
  'KB001_' || col.group_type,
  col.group_name,
  col.group_type,
  false, 0, col.max_select,
  col.ord, true
FROM menu,
(VALUES
  ('제거할 재료', 'REMOVE', 10, 1),
  ('추가 재료',   'ADD',     5, 2),
  ('증량',        'EXTRA',   3, 3)
) AS col(group_name, group_type, max_select, ord)
ON CONFLICT DO NOTHING;

-- 제거 옵션 아이템
WITH grp AS (
  SELECT g.id, g.tenant_id, g.store_id
  FROM catchmenu_pos.menu_option_groups g
  JOIN catchmenu_pos.menus m ON m.id = g.menu_id
  WHERE m.menu_code = 'KB-001'
    AND m.store_id = '00000000-0000-0000-0000-000000000002'
    AND g.group_type = 'REMOVE'
  LIMIT 1
)
INSERT INTO catchmenu_pos.menu_option_items (
  tenant_id, store_id, option_group_id,
  item_code, item_name,
  price_delta, is_default_included,
  is_removable, kitchen_note,
  display_order, is_active
)
SELECT
  grp.tenant_id,
  grp.store_id,
  grp.id,
  'KB001_REMOVE_' || col.ord,
  col.item_name,
  0,
  true,
  true,
  col.item_name || ' 제외',
  col.ord,
  true
FROM grp,
(VALUES
  ('단무지', 1),
  ('오이',   2),
  ('시금치', 3),
  ('어묵',   4),
  ('햄',     5),
  ('계란',   6),
  ('부추',   7),
  ('당근',   8)
) AS col(item_name, ord)
ON CONFLICT DO NOTHING;

-- 추가 옵션 아이템
WITH grp AS (
  SELECT g.id, g.tenant_id, g.store_id
  FROM catchmenu_pos.menu_option_groups g
  JOIN catchmenu_pos.menus m ON m.id = g.menu_id
  WHERE m.menu_code = 'KB-001'
    AND m.store_id = '00000000-0000-0000-0000-000000000002'
    AND g.group_type = 'ADD'
  LIMIT 1
)
INSERT INTO catchmenu_pos.menu_option_items (
  tenant_id, store_id, option_group_id,
  item_code, item_name,
  price_delta, is_default_included,
  is_removable, allergen_delta,
  kitchen_note, display_order, is_active
)
SELECT
  grp.tenant_id,
  grp.store_id,
  grp.id,
  'KB001_ADD_' || col.ord,
  col.item_name,
  col.price_delta,
  false,
  false,
  col.allergen_delta::jsonb,
  col.kitchen_note,
  col.ord,
  true
FROM grp,
(VALUES
  ('계란지단 추가', 500, '{"eggs":true}',
   '계란지단 2장 추가', 1),
  ('치즈 추가',     500, '{"dairy":true}',
   '슬라이스 치즈 1장 추가', 2),
  ('베이컨 추가',   800, '{}',
   '베이컨 2줄 추가', 3),
  ('맛살 추가',     300, '{"shellfish":true}',
   '맛살 추가', 4)
) AS col(item_name, price_delta, allergen_delta,
         kitchen_note, ord)
ON CONFLICT DO NOTHING;

-- 증량 옵션 아이템
WITH grp AS (
  SELECT g.id, g.tenant_id, g.store_id
  FROM catchmenu_pos.menu_option_groups g
  JOIN catchmenu_pos.menus m ON m.id = g.menu_id
  WHERE m.menu_code = 'KB-001'
    AND m.store_id = '00000000-0000-0000-0000-000000000002'
    AND g.group_type = 'EXTRA'
  LIMIT 1
)
INSERT INTO catchmenu_pos.menu_option_items (
  tenant_id, store_id, option_group_id,
  item_code, item_name,
  price_delta, is_default_included,
  is_removable, kitchen_note,
  display_order, is_active
)
SELECT
  grp.tenant_id,
  grp.store_id,
  grp.id,
  'KB001_EXTRA_' || col.ord,
  col.item_name,
  col.price_delta,
  true,
  false,
  col.kitchen_note,
  col.ord,
  true
FROM grp,
(VALUES
  ('참기름 더',      200, '참기름 2배', 1),
  ('밥 더',          300, '밥 1.5배',   2),
  ('계란지단 곱빼기', 800, '계란지단 4장', 3)
) AS col(item_name, price_delta, kitchen_note, ord)
ON CONFLICT DO NOTHING;

-- =============================================
-- 8. 검증
-- =============================================
SELECT
  g.group_name,
  g.group_type,
  count(i.id) as item_count,
  sum(i.price_delta) as total_delta
FROM catchmenu_pos.menu_option_groups g
LEFT JOIN catchmenu_pos.menu_option_items i
  ON i.option_group_id = g.id
JOIN catchmenu_pos.menus m ON m.id = g.menu_id
WHERE m.menu_code = 'KB-001'
  AND m.store_id = '00000000-0000-0000-0000-000000000002'
GROUP BY g.group_name, g.group_type,
         g.display_order
ORDER BY g.display_order;
