-- Regression: same order, different origin_reference -> new intent
SELECT catchmenu_payment.resolve_or_create_payment_intent(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := 'a1590000-0000-0000-0000-000000000001'::uuid,
  p_requested_amount := 5000,
  p_payment_method := 'CARD',
  p_payment_channel := 'STAFF_POS',
  p_provider_type := 'TOSS_PAYMENTS',
  p_intent_origin := 'POS_SYNTHESIZED',
  p_origin_reference := jsonb_build_object(
    'source', 'stage5_ant0159_regress_origin_b',
    'run_id', '20260716-ant-reg-b'
  ),
  p_intent_id := NULL,
  p_session_id := NULL,
  p_locale := 'ko'
) AS same_order_diff_origin_intent_id;

-- Regression: different order_id -> separate intent
SELECT catchmenu_payment.resolve_or_create_payment_intent(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := 'a1590000-0000-0000-0000-000000000002'::uuid,
  p_requested_amount := 5000,
  p_payment_method := 'CARD',
  p_payment_channel := 'STAFF_POS',
  p_provider_type := 'TOSS_PAYMENTS',
  p_intent_origin := 'POS_SYNTHESIZED',
  p_origin_reference := jsonb_build_object(
    'source', 'stage5_ant0159_race',
    'run_id', '20260716-ant-race-001'
  ),
  p_intent_id := NULL,
  p_session_id := NULL,
  p_locale := 'ko'
) AS diff_order_intent_id;
