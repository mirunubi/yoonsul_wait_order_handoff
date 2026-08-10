SELECT catchmenu_payment.confirm_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := '44444444-4444-4444-4444-444444444444'::uuid,
  p_provider_type := 'TOSS_PAYMENTS',
  p_provider_approval_number := 'PAYCON001-APPR-SAME',
  p_provider_tx_id := 'PAYCON001-TX-SAME-001',
  p_approved_amount := 5000,
  p_payment_method := 'CARD',
  p_provider_response := '{"race":"pay_con001"}'::jsonb,
  p_actor_type := 'STAFF',
  p_locale := 'ko',
  p_correlation_id := NULL,
  p_intent_id := NULL
) AS result;
