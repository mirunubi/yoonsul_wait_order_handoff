\set ON_ERROR_STOP on
BEGIN;

DO $$
DECLARE
  v_reg jsonb;
  v_session_id uuid;
BEGIN
  v_reg := catchmenu_pos.register_waiting(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_guest_count := 2,
    p_session_type := 'WAITING',
    p_correlation_id := 'verify-600490-preorder-' || substr(gen_random_uuid()::text,1,8)
  );
  v_session_id := (v_reg->'data'->>'session_id')::uuid;
  PERFORM catchmenu_pos.pre_order_while_waiting(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_session_id := v_session_id,
    p_cart_items := jsonb_build_array(jsonb_build_object('menu_id','00000000-0000-0000-0000-000000000050','quantity',1)),
    p_correlation_id := 'verify-600490-preorder-call-' || substr(gen_random_uuid()::text,1,8)
  );
END $$;

ROLLBACK;
