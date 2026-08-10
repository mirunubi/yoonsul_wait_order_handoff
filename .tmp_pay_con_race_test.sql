-- PAY-CON-001 / PAY-CON-002 race reproduction harness (rollback-safe setup)
\set tenant_id '00000000-0000-0000-0000-000000000001'
\set store_id '00000000-0000-0000-0000-000000000002'

-- Fresh order for intent race (no pre-existing intents)
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, session_id,
  order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) VALUES (
  '33333333-3333-3333-3333-333333333333',
  :'tenant_id'::uuid,
  :'store_id'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  'PAYCON-TEST-001',
  'DINE_IN',
  'CONFIRMED',
  5000, 0, 5000,
  current_date,
  'Asia/Seoul'
) ON CONFLICT (id) DO NOTHING;

SELECT 'setup_order' AS step, id, order_status
FROM catchmenu_pos.orders
WHERE id = '33333333-3333-3333-3333-333333333333';

-- Slow wrapper mirroring 0158 resolve_or_create insert path
CREATE OR REPLACE FUNCTION catchmenu_payment.__pay_con002_slow_resolve(
  p_sleep_seconds numeric DEFAULT 2
)
RETURNS uuid
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = catchmenu_payment, catchmenu_pos, catchmenu_hq, catchmenu_common
AS $$
DECLARE
  v_intent_id uuid;
  v_candidate_count int;
  v_origin_reference jsonb := jsonb_build_object(
    'source', 'pay_con002_race_test',
    'provider_tx_id', 'RACE-TX-001'
  );
BEGIN
  SELECT count(*)
  INTO v_candidate_count
  FROM catchmenu_payment.payment_intents
  WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
    AND store_id = '00000000-0000-0000-0000-000000000002'::uuid
    AND order_id = '33333333-3333-3333-3333-333333333333'::uuid
    AND intent_origin = 'POS_SYNTHESIZED'
    AND coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
    AND intent_status IN (
      'CREATED', 'PENDING', 'PROCESSING', 'CONFIRMED'
    );

  IF v_candidate_count > 0 THEN
    SELECT id INTO v_intent_id
    FROM catchmenu_payment.payment_intents
    WHERE tenant_id = '00000000-0000-0000-0000-000000000001'::uuid
      AND store_id = '00000000-0000-0000-0000-000000000002'::uuid
      AND order_id = '33333333-3333-3333-3333-333333333333'::uuid
      AND intent_origin = 'POS_SYNTHESIZED'
      AND coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
      AND intent_status IN (
        'CREATED', 'PENDING', 'PROCESSING', 'CONFIRMED'
      )
    ORDER BY created_at DESC
    LIMIT 1;
    RETURN v_intent_id;
  END IF;

  PERFORM pg_sleep(p_sleep_seconds);

  INSERT INTO catchmenu_payment.payment_intents (
    tenant_id, store_id, order_id, session_id,
    intent_status, payment_method, payment_channel,
    requested_amount, currency, provider_type,
    provider_order_id, idempotency_key,
    business_day, business_timezone,
    intent_origin, origin_reference
  ) VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000002'::uuid,
    '33333333-3333-3333-3333-333333333333'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    'CONFIRMED', 'CARD', 'STAFF_POS',
    5000, 'KRW', 'INTERNAL',
    NULL,
    'OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-' ||
      substr(md5(v_origin_reference::text), 1, 12),
    current_date, 'Asia/Seoul',
    'POS_SYNTHESIZED', v_origin_reference
  )
  RETURNING id INTO v_intent_id;

  RETURN v_intent_id;
END;
$$;
