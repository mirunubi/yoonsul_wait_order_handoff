\set ON_ERROR_STOP off
\set tenant '00000000-0000-0000-0000-000000000001'
\set store '00000000-0000-0000-0000-000000000002'

BEGIN;

-- ========== Slice 1 setup IDs ==========
-- order/ledger for release_kds_after_payment direct call
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, order_number, order_type,
  order_status, total_amount, final_amount, business_day
) VALUES (
  'a1570001-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'ST5-S1-' || to_char(now(), 'HH24MISS'),
  'TAKEOUT', 'PENDING', 5000, 5000, current_date
);

INSERT INTO catchmenu_payment.payment_intents (
  id, tenant_id, store_id, order_id,
  payment_method, payment_channel, requested_amount,
  provider_type, idempotency_key, business_day
) VALUES (
  'a1570001-9001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570001-0001-4001-8001-000000000001'::uuid,
  'CARD', 'KIOSK_CARD', 5000,
  'TOSS_PAYMENTS', 'st5-s1-intent', current_date
);

INSERT INTO catchmenu_payment.payment_ledger (
  id, tenant_id, store_id, order_id, intent_id,
  ledger_entry_type, ledger_status, approved_amount, net_amount,
  provider_type, kds_release_authorized,
  business_day, business_timezone, approved_at
) VALUES (
  'a1570002-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570001-0001-4001-8001-000000000001'::uuid,
  'a1570001-9001-4001-8001-000000000001'::uuid,
  'APPROVAL', 'APPROVED', 5000, 5000,
  'TOSS_PAYMENTS', false,
  current_date, 'Asia/Seoul', now()
);

INSERT INTO catchmenu_kds.kds_tickets (
  id, tenant_id, store_id, order_id,
  ticket_number, kds_status, menu_name_snapshot,
  business_day, business_timezone
) VALUES (
  'a1570003-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570001-0001-4001-8001-000000000001'::uuid,
  'ST5-S1-01', 'HOLD', 'Stage5 Slice1 Test Menu',
  current_date, 'Asia/Seoul'
);

\echo '=== SLICE1 CALL release_kds_after_payment ==='
SELECT catchmenu_payment.release_kds_after_payment(
  p_tenant_id := :'tenant'::uuid,
  p_store_id := :'store'::uuid,
  p_order_id := 'a1570001-0001-4001-8001-000000000001'::uuid,
  p_ledger_id := 'a1570002-0001-4001-8001-000000000001'::uuid,
  p_locale := 'ko',
  p_correlation_id := 'verify-601023-slice1'
) AS slice1_result_json;

\echo '=== SLICE1 payment_ledger SELECT ==='
SELECT id, kds_release_authorized, kds_release_authorized_at, kds_release_authorized_by
FROM catchmenu_payment.payment_ledger
WHERE id = 'a1570002-0001-4001-8001-000000000001'::uuid;

-- ========== Slice 2 Case A: authorized ledger ==========
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, order_number, order_type,
  order_status, total_amount, final_amount, business_day
) VALUES (
  'a1570011-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'ST5-A-' || to_char(now(), 'HH24MISS'),
  'TAKEOUT', 'CONFIRMED', 3000, 3000, current_date
);

INSERT INTO catchmenu_pos.order_items (
  id, tenant_id, store_id, order_id, menu_id,
  menu_code_snapshot, menu_name_snapshot,
  unit_price_snapshot, quantity, item_amount, item_status
) VALUES (
  'a1570012-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570011-0001-4001-8001-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000057'::uuid,
  'ST5-A', 'Case A Menu', 3000, 1, 3000, 'CONFIRMED'
);

INSERT INTO catchmenu_payment.payment_intents (
  id, tenant_id, store_id, order_id,
  payment_method, payment_channel, requested_amount,
  provider_type, idempotency_key, business_day
) VALUES (
  'a1570011-9001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570011-0001-4001-8001-000000000001'::uuid,
  'CARD', 'KIOSK_CARD', 3000,
  'TOSS_PAYMENTS', 'st5-a-intent', current_date
);

INSERT INTO catchmenu_payment.payment_ledger (
  id, tenant_id, store_id, order_id, intent_id,
  ledger_entry_type, ledger_status, approved_amount, net_amount,
  provider_type, kds_release_authorized,
  kds_release_authorized_at, kds_release_authorized_by,
  business_day, business_timezone, approved_at
) VALUES (
  'a1570013-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570011-0001-4001-8001-000000000001'::uuid,
  'a1570011-9001-4001-8001-000000000001'::uuid,
  'APPROVAL', 'APPROVED', 3000, 3000,
  'TOSS_PAYMENTS', true, now(), 'SYSTEM',
  current_date, 'Asia/Seoul', now()
);

INSERT INTO catchmenu_kds.kds_tickets (
  id, tenant_id, store_id, order_id, order_item_id,
  payment_ledger_id, ticket_number, kds_status,
  menu_name_snapshot, business_day, business_timezone
) VALUES (
  'a1570014-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570011-0001-4001-8001-000000000001'::uuid,
  'a1570012-0001-4001-8001-000000000001'::uuid,
  'a1570013-0001-4001-8001-000000000001'::uuid,
  'ST5-A-01', 'COMMITTED', 'Case A Menu',
  current_date, 'Asia/Seoul'
);

\echo '=== CASE A SQL ==='
\echo SELECT catchmenu_kds.start_cooking(... ticket a1570014 ..., authorized ledger a1570013);
SELECT catchmenu_kds.start_cooking(
  p_tenant_id := :'tenant'::uuid,
  p_store_id := :'store'::uuid,
  p_ticket_id := 'a1570014-0001-4001-8001-000000000001'::uuid,
  p_actor_type := 'STAFF',
  p_correlation_id := 'verify-601023-case-a'
) AS case_a_result_json;

-- ========== Case B: ledger present, not authorized ==========
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, order_number, order_type,
  order_status, total_amount, final_amount, business_day
) VALUES (
  'a1570021-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'ST5-B-' || to_char(now(), 'HH24MISS'),
  'TAKEOUT', 'CONFIRMED', 3000, 3000, current_date
);

INSERT INTO catchmenu_payment.payment_intents (
  id, tenant_id, store_id, order_id,
  payment_method, payment_channel, requested_amount,
  provider_type, idempotency_key, business_day
) VALUES (
  'a1570021-9001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570021-0001-4001-8001-000000000001'::uuid,
  'CARD', 'KIOSK_CARD', 3000,
  'TOSS_PAYMENTS', 'st5-b-intent', current_date
);

INSERT INTO catchmenu_payment.payment_ledger (
  id, tenant_id, store_id, order_id, intent_id,
  ledger_entry_type, ledger_status, approved_amount, net_amount,
  provider_type, kds_release_authorized,
  business_day, business_timezone, approved_at
) VALUES (
  'a1570022-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570021-0001-4001-8001-000000000001'::uuid,
  'a1570021-9001-4001-8001-000000000001'::uuid,
  'APPROVAL', 'APPROVED', 3000, 3000,
  'TOSS_PAYMENTS', false,
  current_date, 'Asia/Seoul', now()
);

INSERT INTO catchmenu_kds.kds_tickets (
  id, tenant_id, store_id, order_id,
  payment_ledger_id, ticket_number, kds_status,
  menu_name_snapshot, business_day, business_timezone
) VALUES (
  'a1570023-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570021-0001-4001-8001-000000000001'::uuid,
  'a1570022-0001-4001-8001-000000000001'::uuid,
  'ST5-B-01', 'COMMITTED', 'Case B Menu',
  current_date, 'Asia/Seoul'
);

\echo '=== CASE B SQL ==='
SELECT catchmenu_kds.start_cooking(
  p_tenant_id := :'tenant'::uuid,
  p_store_id := :'store'::uuid,
  p_ticket_id := 'a1570023-0001-4001-8001-000000000001'::uuid,
  p_actor_type := 'STAFF',
  p_correlation_id := 'verify-601023-case-b'
) AS case_b_result_json;

-- ========== Case C: payment_ledger_id null ==========
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, order_number, order_type,
  order_status, total_amount, final_amount, business_day
) VALUES (
  'a1570031-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'ST5-C-' || to_char(now(), 'HH24MISS'),
  'TAKEOUT', 'CONFIRMED', 3000, 3000, current_date
);

INSERT INTO catchmenu_kds.kds_tickets (
  id, tenant_id, store_id, order_id,
  payment_ledger_id, ticket_number, kds_status,
  menu_name_snapshot, business_day, business_timezone
) VALUES (
  'a1570032-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570031-0001-4001-8001-000000000001'::uuid,
  NULL,
  'ST5-C-01', 'COMMITTED', 'Case C Menu',
  current_date, 'Asia/Seoul'
);

\echo '=== CASE C SQL ==='
SELECT catchmenu_kds.start_cooking(
  p_tenant_id := :'tenant'::uuid,
  p_store_id := :'store'::uuid,
  p_ticket_id := 'a1570032-0001-4001-8001-000000000001'::uuid,
  p_actor_type := 'STAFF',
  p_correlation_id := 'verify-601023-case-c'
) AS case_c_result_json;

-- ========== Case D: 0143-style no-payment committed, ledger null ==========
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, order_number, order_type,
  order_status, total_amount, final_amount, business_day
) VALUES (
  'a1570041-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'ST5-D-' || to_char(now(), 'HH24MISS'),
  'TAKEOUT', 'CONFIRMED', 3000, 3000, current_date
);

INSERT INTO catchmenu_kds.kds_tickets (
  id, tenant_id, store_id, order_id,
  payment_ledger_id, ticket_number, kds_status,
  menu_name_snapshot, conditions_met,
  business_day, business_timezone
) VALUES (
  'a1570042-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'a1570041-0001-4001-8001-000000000001'::uuid,
  NULL,
  'ST5-D-01', 'COMMITTED', 'Case D No-Payment Menu',
  jsonb_build_object(
    'no_payment_policy_released', true,
    'no_payment_policy_release_source', 'STORE_NO_PAYMENT_POLICY'
  ),
  current_date, 'Asia/Seoul'
);

\echo '=== CASE D SQL ==='
SELECT catchmenu_kds.start_cooking(
  p_tenant_id := :'tenant'::uuid,
  p_store_id := :'store'::uuid,
  p_ticket_id := 'a1570042-0001-4001-8001-000000000001'::uuid,
  p_actor_type := 'STAFF',
  p_correlation_id := 'verify-601023-case-d'
) AS case_d_result_json;

-- ========== confirm_payment crash test ==========
INSERT INTO catchmenu_pos.orders (
  id, tenant_id, store_id, order_number, order_type,
  order_status, total_amount, final_amount, business_day
) VALUES (
  'a1570051-0001-4001-8001-000000000001'::uuid,
  :'tenant'::uuid, :'store'::uuid,
  'ST5-CP-' || to_char(now(), 'HH24MISS'),
  'TAKEOUT', 'PENDING', 4500, 4500, current_date
);

\echo '=== confirm_payment CALL ==='
DO $$
BEGIN
  PERFORM catchmenu_payment.confirm_payment(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_order_id := 'a1570051-0001-4001-8001-000000000001'::uuid,
    p_provider_type := 'TOSS_PAYMENTS',
    p_provider_approval_number := 'ST5-APPR-001',
    p_provider_tx_id := 'ST5-TX-001',
    p_approved_amount := 4500,
    p_payment_method := 'CARD',
    p_correlation_id := 'verify-601023-confirm-payment-crash'
  );
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'confirm_payment ERROR SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

ROLLBACK;
