-- PAY-CON-003 verifier setup (prefix __test_ant003_)
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, session_id,
  order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) VALUES (
  'c0030000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '11111111-1111-1111-1111-111111111111',
  'PAYCON003-RACE-001',
  'DINE_IN', 'CONFIRMED',
  5000, 0, 5000,
  current_date, 'Asia/Seoul'
) ON CONFLICT (id) DO NOTHING;

CREATE OR REPLACE FUNCTION catchmenu_payment.__test_ant003_confirm(
  p_order_id uuid,
  p_tx_id text,
  p_sleep_before_insert numeric DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = catchmenu_payment, catchmenu_pos, catchmenu_common
AS $$
BEGIN
  IF p_sleep_before_insert > 0 THEN
    PERFORM pg_sleep(p_sleep_before_insert);
  END IF;
  RETURN catchmenu_payment.confirm_payment(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_order_id := p_order_id,
    p_provider_type := 'TOSS_PAYMENTS',
    p_provider_approval_number := 'ANT003-APPR',
    p_provider_tx_id := p_tx_id,
    p_approved_amount := 5000,
    p_payment_method := 'CARD',
    p_actor_type := 'STAFF',
    p_locale := 'ko',
    p_correlation_id := 'ant003-' || p_tx_id,
    p_intent_id := NULL
  );
END;
$$;

CREATE OR REPLACE FUNCTION catchmenu_payment.__test_ant003_cancel(
  p_ledger_id uuid,
  p_sleep_after_lock numeric DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = catchmenu_payment, catchmenu_common
AS $$
DECLARE
  v_ledger record;
BEGIN
  SELECT id, ledger_status INTO v_ledger
  FROM catchmenu_payment.payment_ledger
  WHERE id = p_ledger_id
  FOR UPDATE;

  IF p_sleep_after_lock > 0 THEN
    PERFORM pg_sleep(p_sleep_after_lock);
  END IF;

  RETURN catchmenu_payment.cancel_payment(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_ledger_id := p_ledger_id,
    p_cancel_reason := 'PAY-CON-003 race test',
    p_actor_type := 'STAFF',
    p_actor_id := NULL,
    p_correlation_id := 'ant003-cancel-' || p_ledger_id::text
  );
END;
$$;
