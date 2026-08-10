\set ON_ERROR_STOP on
\set tenant '00000000-0000-0000-0000-000000000001'
\set store '00000000-0000-0000-0000-000000000002'
\set fake_uuid '00000000-0000-0000-0000-000000000099'

BEGIN;

-- 1 mark_payment_uncertain: 5 named args (0027 shape)
DO $$
BEGIN
  PERFORM catchmenu_payment.mark_payment_uncertain(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_intent_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_uncertain_reason := 'eyes-only-ambiguity-test',
    p_correlation_id := 'verify-mmu-5arg'
  );
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'mark_payment_uncertain 5-arg: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

-- 1b 6 named with p_locale (0063 shape)
DO $$
BEGIN
  PERFORM catchmenu_payment.mark_payment_uncertain(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_intent_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_uncertain_reason := 'eyes-only-ambiguity-test',
    p_locale := 'ko',
    p_correlation_id := 'verify-mmu-6arg'
  );
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'mark_payment_uncertain 6-arg: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

-- 2 authorize_kds_release 0028 shape (p_ledger_id)
DO $$
DECLARE v_result jsonb;
BEGIN
  v_result := catchmenu_kds.authorize_kds_release(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_ledger_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_actor_type := 'SYSTEM',
    p_correlation_id := 'verify-akr-ledger'
  );
  RAISE NOTICE 'authorize_kds_release ledger-path result=%', v_result;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'authorize_kds_release ledger-path: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

-- 2b authorize_kds_release 0063 shape (p_order_id)
DO $$
DECLARE v_result jsonb;
BEGIN
  v_result := catchmenu_kds.authorize_kds_release(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_order_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_authorized_by_type := 'MANAGER',
    p_authorized_by_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_locale := 'ko',
    p_correlation_id := 'verify-akr-order'
  );
  RAISE NOTICE 'authorize_kds_release order-path result=%', v_result;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'authorize_kds_release order-path: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

-- 3 mark_no_show 0050 shape (p_actor_type)
DO $$
DECLARE v_result jsonb;
BEGIN
  v_result := catchmenu_pos.mark_no_show(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_session_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_actor_type := 'STAFF',
    p_correlation_id := 'verify-mns-actor-type'
  );
  RAISE NOTICE 'mark_no_show actor_type-path result=%', v_result;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'mark_no_show actor_type-path: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

-- 3b mark_no_show 0115 shape (p_actor_id + p_locale)
DO $$
DECLARE v_result jsonb;
BEGIN
  v_result := catchmenu_pos.mark_no_show(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_session_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_actor_id := null,
    p_locale := 'ko',
    p_correlation_id := 'verify-mns-locale'
  );
  RAISE NOTICE 'mark_no_show locale-path result=%', v_result;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'mark_no_show locale-path: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

-- 4 get_did_display_state 0043 shape (p_device_id)
DO $$
DECLARE v_result jsonb;
BEGIN
  v_result := catchmenu_store.get_did_display_state(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_device_id := null
  );
  RAISE NOTICE 'get_did_display_state device-path result keys=%', (SELECT array_agg(k) FROM jsonb_object_keys(v_result) k);
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'get_did_display_state device-path: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

-- 4b get_did_display_state 0117 shape (p_did_id + p_locale)
DO $$
DECLARE v_result jsonb;
BEGIN
  v_result := catchmenu_store.get_did_display_state(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_did_id := '00000000-0000-0000-0000-000000000099'::uuid,
    p_locale := 'ko'
  );
  RAISE NOTICE 'get_did_display_state did-path result=%', v_result;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'get_did_display_state did-path: SQLSTATE=% MSG=%', SQLSTATE, SQLERRM;
END $$;

ROLLBACK;
