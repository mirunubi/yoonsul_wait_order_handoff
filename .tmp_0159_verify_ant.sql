-- Stage 5 independent verification setup (Ant/Cursor verifier)
-- Order A for race test
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, session_id,
  order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) VALUES (
  'a1590000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '11111111-1111-1111-1111-111111111111',
  'STAGE5-0159-RACE-A',
  'DINE_IN', 'CONFIRMED',
  5000, 0, 5000,
  current_date, 'Asia/Seoul'
) ON CONFLICT (id) DO NOTHING;

-- Order B for different-order regression
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, session_id,
  order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) VALUES (
  'a1590000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '11111111-1111-1111-1111-111111111111',
  'STAGE5-0159-REG-B',
  'DINE_IN', 'CONFIRMED',
  5000, 0, 5000,
  current_date, 'Asia/Seoul'
) ON CONFLICT (id) DO NOTHING;

CREATE OR REPLACE FUNCTION catchmenu_payment.__test_ant0159_race_call(
  p_order_id uuid,
  p_origin_reference jsonb,
  p_sleep_seconds numeric DEFAULT 1.0
)
RETURNS uuid
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = catchmenu_payment, catchmenu_pos, catchmenu_hq, catchmenu_common
AS $$
BEGIN
  PERFORM pg_sleep(p_sleep_seconds);
  RETURN catchmenu_payment.resolve_or_create_payment_intent(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_order_id := p_order_id,
    p_requested_amount := 5000,
    p_payment_method := 'CARD',
    p_payment_channel := 'STAFF_POS',
    p_provider_type := 'TOSS_PAYMENTS',
    p_intent_origin := 'POS_SYNTHESIZED',
    p_origin_reference := p_origin_reference,
    p_intent_id := NULL,
    p_session_id := NULL,
    p_locale := 'ko'
  );
END;
$$;
