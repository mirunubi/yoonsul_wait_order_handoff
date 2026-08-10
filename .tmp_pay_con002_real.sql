SELECT catchmenu_payment.resolve_or_create_payment_intent(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := '33333333-3333-3333-3333-333333333333'::uuid,
  p_requested_amount := 5000,
  p_payment_method := 'CARD',
  p_payment_channel := 'STAFF_POS',
  p_provider_type := 'TOSS_PAYMENTS',
  p_intent_origin := 'POS_SYNTHESIZED',
  p_origin_reference := jsonb_build_object(
    'source', 'pay_con002_race_real_v2',
    'provider_tx_id', 'RACE-TX-REAL-001'
  ),
  p_intent_id := NULL,
  p_session_id := NULL,
  p_locale := 'ko'
) AS intent_id;
