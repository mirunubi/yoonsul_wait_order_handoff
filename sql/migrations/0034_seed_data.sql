-- 0034_seed_data.sql
-- Purpose: Seed data for development and testing.
--          Creates test tenant, store, devices, agents,
--          dining tables, menu categories, menus, and option groups.
--          DO NOT run in production environment.
-- Depends on: 0033_create_knowledge_gap_rpc.sql
-- Creates: test data only

-- =============================================
-- Safety guard
-- =============================================
do $$
begin
  if current_database() not like '%dev%'
    and current_database() not like '%test%'
    and current_database() not like '%local%'
  then
    raise exception
      'SEED_DATA_BLOCKED: This script must only run on dev/test/local databases. Current DB: %',
      current_database();
  end if;
end;
$$;

-- =============================================
-- Test tenant
-- =============================================
insert into catchmenu_hq.tenants (
  id,
  tenant_code,
  tenant_name,
  tenant_type,
  plan_tier,
  is_active
) values (
  '00000000-0000-0000-0000-000000000001',
  'YOONSUL_TEST',
  '윤슬 테스트 브랜드',
  'BRAND',
  'PRO',
  true
)
on conflict (tenant_code) do nothing;

-- =============================================
-- Test store
-- =============================================
insert into catchmenu_hq.stores (
  id,
  tenant_id,
  store_code,
  store_name,
  store_type,
  store_status,
  address,
  phone,
  timezone,
  business_hours,
  is_active,
  opened_on
) values (
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000001',
  'ULSAN_01',
  '윤슬 울산 1호점',
  'DINE_IN',
  'ACTIVE',
  '울산광역시 중구 테스트로 123',
  '052-000-0001',
  'Asia/Seoul',
  jsonb_build_object(
    'mon', jsonb_build_object('open', '10:00', 'close', '22:00'),
    'tue', jsonb_build_object('open', '10:00', 'close', '22:00'),
    'wed', jsonb_build_object('open', '10:00', 'close', '22:00'),
    'thu', jsonb_build_object('open', '10:00', 'close', '22:00'),
    'fri', jsonb_build_object('open', '10:00', 'close', '23:00'),
    'sat', jsonb_build_object('open', '10:00', 'close', '23:00'),
    'sun', jsonb_build_object('open', '11:00', 'close', '21:00')
  ),
  true,
  '2027-09-01'
)
on conflict (tenant_id, store_code) do nothing;

-- =============================================
-- Devices
-- =============================================
insert into catchmenu_store.device_registry (
  id, tenant_id, store_id,
  device_code, device_name, device_type, device_role,
  trust_level, device_status, is_active
) values
(
  '00000000-0000-0000-0000-000000000010',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'POS-01', '메인 POS', 'POS', 'PRIMARY',
  'TRUSTED', 'ONLINE', true
),
(
  '00000000-0000-0000-0000-000000000011',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'KDS-01', '주방 KDS 메인', 'KDS', 'PRIMARY',
  'TRUSTED', 'ONLINE', true
),
(
  '00000000-0000-0000-0000-000000000012',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'KIOSK-01', '입구 키오스크', 'KIOSK', 'PRIMARY',
  'TRUSTED', 'ONLINE', true
),
(
  '00000000-0000-0000-0000-000000000013',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'DID-01', '고객 대기 DID', 'DID', 'PRIMARY',
  'TRUSTED', 'ONLINE', true
)
on conflict (store_id, device_code) do nothing;

-- =============================================
-- Agents
-- =============================================
insert into catchmenu_store.agent_registry (
  id, tenant_id, store_id, device_id,
  agent_code, agent_name, agent_type, agent_role,
  agent_status,
  can_observe, can_recommend, can_execute,
  can_recover, can_audit, is_active
) values
(
  '00000000-0000-0000-0000-000000000020',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000010',
  'FAULT-AGENT-01', '장애 감지 Agent',
  'FAULT_DETECTION', 'PRIMARY',
  'ONLINE',
  true, true, false, false, true, true
),
(
  '00000000-0000-0000-0000-000000000021',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000011',
  'KDS-CAPACITY-01', 'KDS 수용상태 Agent',
  'KDS_CAPACITY', 'PRIMARY',
  'ONLINE',
  true, true, false, false, true, true
),
(
  '00000000-0000-0000-0000-000000000022',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  null,
  'KNOWLEDGE-GAP-01', 'Knowledge Gap 탐지 Agent',
  'KNOWLEDGE_GAP', 'PRIMARY',
  'ONLINE',
  true, true, false, false, true, true
),
(
  '00000000-0000-0000-0000-000000000023',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  null,
  'SOP-EVOLUTION-01', 'SOP 진화 Agent',
  'SOP_EVOLUTION', 'PRIMARY',
  'ONLINE',
  true, true, false, false, true, true
),
(
  '00000000-0000-0000-0000-000000000024',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  null,
  'RECOVERY-01', '복구 Agent',
  'RECOVERY', 'PRIMARY',
  'ONLINE',
  true, true, true, true, true, true
)
on conflict (store_id, agent_code) do nothing;

-- =============================================
-- Dining tables
-- =============================================
insert into catchmenu_store.dining_tables (
  id, tenant_id, store_id,
  table_code, table_name,
  capacity, floor_zone, table_section,
  display_order, table_status, is_active
) values
(
  '00000000-0000-0000-0000-000000000030',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'A01', 'A01번 테이블',
  4, '1층', 'A구역', 10, 'AVAILABLE', true
),
(
  '00000000-0000-0000-0000-000000000031',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'A02', 'A02번 테이블',
  4, '1층', 'A구역', 20, 'AVAILABLE', true
),
(
  '00000000-0000-0000-0000-000000000032',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'A03', 'A03번 테이블',
  2, '1층', 'A구역', 30, 'AVAILABLE', true
),
(
  '00000000-0000-0000-0000-000000000033',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'B01', 'B01번 테이블',
  6, '1층', 'B구역', 40, 'AVAILABLE', true
),
(
  '00000000-0000-0000-0000-000000000034',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'B02', 'B02번 테이블',
  6, '1층', 'B구역', 50, 'AVAILABLE', true
),
(
  '00000000-0000-0000-0000-000000000035',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'COUNTER-01', '카운터석 01',
  1, '1층', '카운터', 60, 'AVAILABLE', true
)
on conflict (store_id, table_code) do nothing;

-- =============================================
-- Menu categories
-- =============================================
insert into catchmenu_pos.menu_categories (
  id, tenant_id, store_id,
  parent_category_id,
  category_code, category_name,
  display_order, is_active
) values
(
  '00000000-0000-0000-0000-000000000040',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  null,
  'MAIN', '메인메뉴',
  10, true
),
(
  '00000000-0000-0000-0000-000000000041',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  null,
  'SET', '세트메뉴',
  20, true
),
(
  '00000000-0000-0000-0000-000000000042',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  null,
  'SIDE', '사이드',
  30, true
),
(
  '00000000-0000-0000-0000-000000000043',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  null,
  'DRINK', '음료',
  40, true
),
(
  '00000000-0000-0000-0000-000000000044',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000040',
  'KIMBAP', '김밥류',
  11, true
),
(
  '00000000-0000-0000-0000-000000000045',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000040',
  'RAMEN', '라면류',
  12, true
)
on conflict (store_id, category_code) do nothing;

-- =============================================
-- Menus
-- =============================================
insert into catchmenu_pos.menus (
  id, tenant_id, store_id, category_id,
  menu_code, menu_name, description,
  price, menu_status,
  is_kds_required, kitchen_zone,
  estimated_minutes, prep_complexity,
  peak_time_restricted,
  menu_name_en,
  allergen_info,
  display_order, is_active
) values
-- 김밥류
(
  '00000000-0000-0000-0000-000000000050',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000044',
  'KB-001', '기본김밥', '고소한 참기름 기본 김밥',
  3500, 'AVAILABLE',
  true, '김밥',
  5, 'NORMAL', false,
  'Basic Kimbap',
  jsonb_build_object(
    'gluten', true, 'eggs', true,
    'sesame', true, 'dairy', false
  ),
  10, true
),
(
  '00000000-0000-0000-0000-000000000051',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000044',
  'KB-002', '참치김밥', '고소한 참치 마요 김밥',
  4500, 'AVAILABLE',
  true, '김밥',
  5, 'NORMAL', false,
  'Tuna Kimbap',
  jsonb_build_object(
    'gluten', true, 'eggs', true,
    'sesame', true, 'fish', true
  ),
  20, true
),
(
  '00000000-0000-0000-0000-000000000052',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000044',
  'KB-003', '불고기김밥', '달콤한 불고기 김밥',
  5000, 'AVAILABLE',
  true, '김밥',
  7, 'NORMAL', false,
  'Bulgogi Kimbap',
  jsonb_build_object(
    'gluten', true, 'eggs', true,
    'sesame', true, 'soy', true
  ),
  30, true
),
-- 라면류
(
  '00000000-0000-0000-0000-000000000053',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000045',
  'RM-001', '라면', '국물이 진한 라면',
  4000, 'AVAILABLE',
  true, '라면',
  8, 'NORMAL', true,
  'Ramen',
  jsonb_build_object(
    'gluten', true, 'eggs', false,
    'shellfish', false
  ),
  10, true
),
(
  '00000000-0000-0000-0000-000000000054',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000045',
  'RM-002', '라볶이', '라면과 떡볶이의 환상 조합',
  6000, 'AVAILABLE',
  true, '라면',
  10, 'COMPLEX', true,
  'Rabokki',
  jsonb_build_object(
    'gluten', true, 'eggs', false,
    'shellfish', false
  ),
  20, true
),
-- 사이드
(
  '00000000-0000-0000-0000-000000000055',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000042',
  'SD-001', '공기밥', '따뜻한 공기밥',
  1000, 'AVAILABLE',
  true, '김밥',
  3, 'SIMPLE', false,
  'Steamed Rice',
  jsonb_build_object(
    'gluten', false, 'eggs', false
  ),
  10, true
),
(
  '00000000-0000-0000-0000-000000000056',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000042',
  'SD-002', '단무지', '시원한 단무지',
  500, 'AVAILABLE',
  false, null,
  1, 'SIMPLE', false,
  'Pickled Radish',
  jsonb_build_object(
    'gluten', false, 'eggs', false
  ),
  20, true
),
-- 음료
(
  '00000000-0000-0000-0000-000000000057',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000043',
  'DR-001', '물', '시원한 물',
  0, 'AVAILABLE',
  false, null,
  1, 'SIMPLE', false,
  'Water',
  jsonb_build_object(
    'gluten', false, 'eggs', false
  ),
  10, true
),
(
  '00000000-0000-0000-0000-000000000058',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000043',
  'DR-002', '캔음료', '시원한 캔음료',
  2000, 'AVAILABLE',
  false, null,
  1, 'SIMPLE', false,
  'Canned Drink',
  jsonb_build_object(
    'gluten', false, 'eggs', false
  ),
  20, true
)
on conflict (store_id, menu_code) do nothing;

-- =============================================
-- Menu option groups
-- =============================================
insert into catchmenu_pos.menu_option_groups (
  id, tenant_id, store_id, menu_id,
  group_code, group_name,
  is_required, min_select, max_select,
  display_order, is_active
) values
(
  '00000000-0000-0000-0000-000000000060',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000053',
  'SPICY', '맵기 선택',
  true, 1, 1,
  10, true
),
(
  '00000000-0000-0000-0000-000000000061',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000053',
  'TOPPING', '토핑 추가',
  false, 0, 3,
  20, true
)
on conflict (menu_id, group_code) do nothing;

-- =============================================
-- Menu option items
-- =============================================
insert into catchmenu_pos.menu_option_items (
  id, tenant_id, store_id, option_group_id,
  item_code, item_name,
  additional_price, display_order, is_active
) values
-- 맵기 선택
(
  '00000000-0000-0000-0000-000000000070',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000060',
  'MILD', '순한맛', 0, 10, true
),
(
  '00000000-0000-0000-0000-000000000071',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000060',
  'NORMAL', '보통맛', 0, 20, true
),
(
  '00000000-0000-0000-0000-000000000072',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000060',
  'HOT', '매운맛', 0, 30, true
),
(
  '00000000-0000-0000-0000-000000000073',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000060',
  'VERY_HOT', '아주매운맛', 0, 40, true
),
-- 토핑 추가
(
  '00000000-0000-0000-0000-000000000074',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000061',
  'EGG', '계란 추가', 500, 10, true
),
(
  '00000000-0000-0000-0000-000000000075',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000061',
  'CHEESE', '치즈 추가', 500, 20, true
),
(
  '00000000-0000-0000-0000-000000000076',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000061',
  'RICE_CAKE', '떡 추가', 500, 30, true
)
on conflict (option_group_id, item_code) do nothing;

-- =============================================
-- Verification
-- =============================================
do $$
declare
  v_tenant_count int;
  v_store_count int;
  v_table_count int;
  v_menu_count int;
  v_device_count int;
  v_agent_count int;
begin
  select count(*) into v_tenant_count
  from catchmenu_hq.tenants
  where tenant_code = 'YOONSUL_TEST';

  select count(*) into v_store_count
  from catchmenu_hq.stores
  where store_code = 'ULSAN_01';

  select count(*) into v_table_count
  from catchmenu_store.dining_tables
  where store_id = '00000000-0000-0000-0000-000000000002';

  select count(*) into v_menu_count
  from catchmenu_pos.menus
  where store_id = '00000000-0000-0000-0000-000000000002';

  select count(*) into v_device_count
  from catchmenu_store.device_registry
  where store_id = '00000000-0000-0000-0000-000000000002';

  select count(*) into v_agent_count
  from catchmenu_store.agent_registry
  where store_id = '00000000-0000-0000-0000-000000000002';

  raise notice '=== Seed Data Verification ===';
  raise notice 'Tenants   : %', v_tenant_count;
  raise notice 'Stores    : %', v_store_count;
  raise notice 'Tables    : %', v_table_count;
  raise notice 'Menus     : %', v_menu_count;
  raise notice 'Devices   : %', v_device_count;
  raise notice 'Agents    : %', v_agent_count;
  raise notice '==============================';

  if v_tenant_count = 0 or v_store_count = 0 then
    raise exception 'SEED_VERIFICATION_FAILED: tenant or store missing';
  end if;

  raise notice 'Seed data verification PASSED';
end;
$$;