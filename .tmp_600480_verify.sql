-- 600480 Stage 5/6 verification (Tests A-D), independent IDs
\set ON_ERROR_STOP on

-- Test A: overload count (read-only, no drop needed - 0153 already applied)
SELECT count(*) AS test_a_overload_count
FROM pg_proc
WHERE proname = 'confirm_payment_from_provider'
  AND pronamespace = 'catchmenu_meta'::regnamespace OR pronamespace = 'catchmenu_payment'::regnamespace;

SELECT pg_get_function_identity_arguments(oid) AS test_a_identity_args
FROM pg_proc
WHERE proname = 'confirm_payment_from_provider'
  AND pronamespace = 'catchmenu_payment'::regnamespace;

BEGIN;

-- Test B: 8 named-arg call (needs existing intent - will create minimal for call resolution test)
INSERT INTO catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'TEST-600480-B-' || substr(gen_random_uuid()::text,1,8), 'TAKEOUT', 'CONFIRMED',
  4200, 0, 4200,
  current_date, 'Asia/Seoul'
) RETURNING id \gset ord_b_

INSERT INTO catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status,
  payment_method, payment_channel, requested_amount,
  provider_type, idempotency_key, business_day, business_timezone
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  :'ord_b_id'::uuid, 'PENDING',
  'CARD', 'CUSTOMER_APP', 4200,
  'TOSS_PAYMENTS', 'test-idem-600480-B-' || substr(gen_random_uuid()::text,1,8), current_date, 'Asia/Seoul'
) RETURNING id \gset intent_b_

SELECT catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_b_id'::uuid,
  p_provider_payment_key := 'test_key_600480_B',
  p_provider_approval_number := 'test_approval_600480_B',
  p_approved_amount := 4200,
  p_provider_raw_event_id := null,
  p_correlation_id := 'verify-600480-testB-' || substr(gen_random_uuid()::text,1,8)
) AS test_b_result;

ROLLBACK;

BEGIN;

-- Test C/D: full E2E with different amounts/ids
INSERT INTO catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'TEST-600480-CD-' || substr(gen_random_uuid()::text,1,8), 'TAKEOUT', 'CONFIRMED',
  5100, 0, 5100,
  current_date, 'Asia/Seoul'
) RETURNING id \gset ord_cd_

INSERT INTO catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status,
  payment_method, payment_channel, requested_amount,
  provider_type, idempotency_key, business_day, business_timezone
) VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  :'ord_cd_id'::uuid, 'PENDING',
  'CARD', 'CUSTOMER_APP', 5100,
  'TOSS_PAYMENTS', 'test-idem-600480-CD-' || substr(gen_random_uuid()::text,1,8), current_date, 'Asia/Seoul'
) RETURNING id \gset intent_cd_

SELECT catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_cd_id'::uuid,
  p_provider_payment_key := 'test_provider_key_600480_CD',
  p_provider_approval_number := 'test_approval_600480_CD',
  p_approved_amount := 5100,
  p_provider_raw_event_id := null,
  p_correlation_id := 'verify-600480-testCD-' || substr(gen_random_uuid()::text,1,8)
) AS test_cd_result;

SELECT intent_id, ledger_entry_type, ledger_status,
       approved_amount, net_amount, provider_type,
       provider_payment_key, provider_approval_number,
       reconciliation_status, kds_release_authorized
FROM catchmenu_payment.payment_ledger
WHERE intent_id = :'intent_cd_id'::uuid;

SELECT intent_status, confirmed_at IS NOT NULL AS confirmed_at_set
FROM catchmenu_payment.payment_intents
WHERE id = :'intent_cd_id'::uuid;

ROLLBACK;
