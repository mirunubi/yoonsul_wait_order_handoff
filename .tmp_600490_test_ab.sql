\set ON_ERROR_STOP on

-- Test A (isolated kds_tickets INSERT, fresh data)
BEGIN;

INSERT INTO catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'W-TEST-600490-A-' || substr(gen_random_uuid()::text,1,8), 'DINE_IN', 'CONFIRMED',
  4800, 0, 4800, current_date, 'Asia/Seoul'
) RETURNING id AS ordid \gset

INSERT INTO catchmenu_kds.kds_tickets (
  tenant_id, store_id,
  order_id, ticket_number,
  menu_name_snapshot,
  quantity_snapshot,
  kitchen_zone, kds_status,
  conditions_met,
  ticket_created_at,
  business_day, business_timezone
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  :'ordid'::uuid, 'W-TEST-600490-A-01',
  'TestMenu490A', 2,
  'MAIN', 'HOLD',
  jsonb_build_object('payment_confirmed', false, 'kds_release_authorized', false),
  now(), current_date, 'Asia/Seoul'
) RETURNING id, ticket_number, kds_status;

ROLLBACK;

-- Test B (live get_waiting_realtime_state)
BEGIN;
SELECT catchmenu_pos.get_waiting_realtime_state(
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid
);
ROLLBACK;
