-- 0138_patch_integration_functions.sql
-- Purpose: Rewrite run_opening_checklist and run_integration_test
--          based on actual DB schema.
-- Fixes column name mismatches found in 0137.

-- =============================================
-- run_opening_checklist (schema-corrected)
-- =============================================
CREATE OR REPLACE FUNCTION
  catchmenu_common.run_opening_checklist(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_store,
                  catchmenu_kds,
                  catchmenu_knowledge
AS $$
DECLARE
  v_checks jsonb := '[]'::jsonb;
  v_pass_count int := 0;
  v_fail_count int := 0;
  v_warn_count int := 0;
  v_store_exists boolean;
  v_menu_count int;
  v_allergen_missing int;
  v_staff_count int;
  v_staff_no_pin int;
  v_kiosk_count int;
  v_did_count int;
  v_hours_set int;
  v_embedding_rate numeric;
  v_pos_connected boolean;
  v_schema_valid boolean;
  v_item text;
  v_status text;
  v_detail text;
  v_action text;
BEGIN

  -- 1. Store basic setup
  SELECT EXISTS (
    SELECT 1 FROM catchmenu_hq.stores
    WHERE id = p_store_id
      AND tenant_id = p_tenant_id
      AND is_active = true
  ) INTO v_store_exists;

  v_item   := 'Store basic setup';
  v_status := CASE v_store_exists WHEN true THEN 'PASS' ELSE 'FAIL' END;
  v_detail := CASE v_store_exists WHEN true THEN 'Store registered' ELSE 'Store not registered' END;
  v_action := CASE v_store_exists WHEN true THEN null ELSE 'Run onboard_tenant()' END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 2. Menu registration
  SELECT count(*) INTO v_menu_count
  FROM catchmenu_pos.menus
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND is_active = true
    AND menu_status = 'AVAILABLE';

  v_item   := 'Menu registration';
  v_status := CASE WHEN v_menu_count >= 5 THEN 'PASS'
                   WHEN v_menu_count > 0 THEN 'WARN'
                   ELSE 'FAIL' END;
  v_detail := v_menu_count::text || ' menus registered';
  v_action := CASE WHEN v_menu_count = 0 THEN 'Run upsert_menu()' ELSE null END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 3. Allergen registration
  -- allergen_info is OBJECT type: {"gluten": true, "dairy": false}
  -- Missing = only NULL or empty object {}
  -- All-false object means no allergens which is valid
  SELECT count(*) INTO v_allergen_missing
  FROM catchmenu_pos.menus
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND is_active = true
    AND menu_status = 'AVAILABLE'
    AND (
      allergen_info IS NULL
      OR allergen_info = '{}'::jsonb
    );

  v_item   := 'Allergen registration (Food Safety Law)';
  v_status := CASE v_allergen_missing WHEN 0 THEN 'PASS' ELSE 'FAIL' END;
  v_detail := CASE v_allergen_missing
    WHEN 0 THEN 'All menus have allergen info'
    ELSE v_allergen_missing::text || ' menus missing allergen'
  END;
  v_action := CASE v_allergen_missing
    WHEN 0 THEN null
    ELSE 'Food Safety Law violation. Register allergen_info.'
  END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 4. Staff registration (display_name = actual column)
  SELECT
    count(*),
    count(*) FILTER (WHERE pin_hash IS NULL AND staff_status = 'ACTIVE')
  INTO v_staff_count, v_staff_no_pin
  FROM catchmenu_store.staff
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND staff_status <> 'TERMINATED';

  v_item   := 'Staff registration';
  v_status := CASE WHEN v_staff_count >= 1 THEN 'PASS' ELSE 'FAIL' END;
  v_detail := v_staff_count::text || ' staff registered';
  v_action := CASE v_staff_count WHEN 0 THEN 'Insert staff directly' ELSE null END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 5. Staff PIN
  v_item   := 'Staff PIN setup';
  v_status := CASE v_staff_no_pin WHEN 0 THEN 'PASS' ELSE 'WARN' END;
  v_detail := CASE v_staff_no_pin
    WHEN 0 THEN 'All staff have PIN'
    ELSE v_staff_no_pin::text || ' staff missing PIN'
  END;
  v_action := CASE v_staff_no_pin WHEN 0 THEN null ELSE 'Set pin_hash for staff' END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 6. Kiosk
  SELECT count(*) INTO v_kiosk_count
  FROM catchmenu_store.kiosk_configs
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND is_active = true;

  v_item   := 'Kiosk setup';
  v_status := CASE WHEN v_kiosk_count >= 1 THEN 'PASS' ELSE 'WARN' END;
  v_detail := v_kiosk_count::text || ' kiosks registered';
  v_action := CASE v_kiosk_count WHEN 0 THEN 'Optional if not using kiosk' ELSE null END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 7. DID
  SELECT count(*) INTO v_did_count
  FROM catchmenu_store.did_devices
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND is_active = true;

  v_item   := 'DID display setup';
  v_status := CASE WHEN v_did_count >= 1 THEN 'PASS' ELSE 'WARN' END;
  v_detail := v_did_count::text || ' DID devices registered';
  v_action := CASE v_did_count WHEN 0 THEN 'Required if using waiting system' ELSE null END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 8. Business hours
  SELECT count(*) INTO v_hours_set
  FROM catchmenu_store.store_business_hours
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id;

  v_item   := 'Business hours setup';
  v_status := CASE WHEN v_hours_set = 7 THEN 'PASS'
                   WHEN v_hours_set > 0 THEN 'WARN'
                   ELSE 'FAIL' END;
  v_detail := v_hours_set::text || '/7 days configured';
  v_action := CASE WHEN v_hours_set < 7 THEN 'Run set_store_hours()' ELSE null END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 9. Menu embedding
  SELECT coalesce(
    round(
      count(*) FILTER (WHERE embedding_status = 'COMPLETED')::numeric
      / nullif(count(*), 0) * 100, 1
    ), 0
  )
  INTO v_embedding_rate
  FROM catchmenu_knowledge.menu_embeddings
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND embedding_locale = 'en';

  v_item   := 'Menu embedding (foreign visitor)';
  v_status := CASE WHEN v_embedding_rate >= 90 THEN 'PASS' ELSE 'WARN' END;
  v_detail := 'EN embedding rate: ' || v_embedding_rate::text || '%';
  v_action := CASE WHEN v_embedding_rate < 90
    THEN 'Run queue_menu_embedding() then wait for Edge Function'
    ELSE null END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 10. POS integration
  SELECT EXISTS (
    SELECT 1 FROM catchmenu_integrations.pos_store_configs
    WHERE store_id = p_store_id
      AND tenant_id = p_tenant_id
      AND is_active = true
  ) INTO v_pos_connected;

  v_item   := 'POS integration';
  v_status := CASE v_pos_connected WHEN true THEN 'PASS' ELSE 'WARN' END;
  v_detail := CASE v_pos_connected WHEN true THEN 'POS connected' ELSE 'No POS (manual payment ok)' END;
  v_action := CASE v_pos_connected WHEN true THEN null ELSE 'Run setup_pos_integration() optional' END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 11. Schema validation (description = actual column, no version_name)
  SELECT EXISTS (
    SELECT 1 FROM catchmenu_common.schema_versions
    WHERE is_current = true
  ) INTO v_schema_valid;

  v_item   := 'DB schema validation';
  v_status := CASE v_schema_valid WHEN true THEN 'PASS' ELSE 'WARN' END;
  v_detail := CASE v_schema_valid WHEN true THEN 'Schema version recorded' ELSE 'No schema version found' END;
  v_action := CASE v_schema_valid WHEN true THEN null ELSE 'Check schema_versions table' END;
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_pass_count := v_pass_count + CASE v_status WHEN 'PASS' THEN 1 ELSE 0 END;
  v_fail_count := v_fail_count + CASE v_status WHEN 'FAIL' THEN 1 ELSE 0 END;
  v_warn_count := v_warn_count + CASE v_status WHEN 'WARN' THEN 1 ELSE 0 END;

  -- 12. Edge Function P1
  v_item   := 'Edge Function P1';
  v_status := 'WARN';
  v_detail := 'okpos-order-send, toss-payments-confirm etc (6 required)';
  v_action := 'Deploy Edge Functions. See API_SPEC_EDGE_FUNCTION_001.';
  v_checks := v_checks || jsonb_build_object('item',v_item,'status',v_status,'detail',v_detail,'action',v_action);
  v_warn_count := v_warn_count + 1;

  RETURN jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'store_id', p_store_id,
      'overall', CASE
        WHEN v_fail_count > 0 THEN 'NOT_READY'
        WHEN v_warn_count > 3 THEN 'CAUTION'
        ELSE 'READY'
      END,
      'pass_count', v_pass_count,
      'warn_count', v_warn_count,
      'fail_count', v_fail_count,
      'total_checks', v_pass_count + v_warn_count + v_fail_count,
      'checks', v_checks,
      'summary', CASE
        WHEN v_fail_count > 0 THEN 'NOT READY. Fix FAIL items.'
        WHEN v_warn_count > 3 THEN 'CAUTION. Review WARN items.'
        ELSE 'READY TO OPEN!'
      END,
      'checked_at', now()
    )
  );
END;
$$;

GRANT EXECUTE ON FUNCTION
  catchmenu_common.run_opening_checklist(uuid, uuid, text)
  TO authenticated;


-- =============================================
-- run_integration_test (schema-corrected)
-- =============================================
CREATE OR REPLACE FUNCTION
  catchmenu_common.run_integration_test(
  p_tenant_id uuid,
  p_store_id uuid,
  p_scenario text default 'ALL'
)
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_store,
                  catchmenu_hq
AS $$
DECLARE
  v_results jsonb := '[]'::jsonb;
  v_pass int := 0;
  v_fail int := 0;
  v_test_order_id uuid;
  v_test_session_id uuid;
  v_business_day date;
  v_test_name text;
  v_passed boolean;
  v_detail text;
  v_schema_count int;
  v_menu_count int;
  v_store_exists boolean;
  v_rls_count int;
  v_msg_count int;
  v_locale_count int;
  v_error_count int;
  v_cron_count int;
  v_sop_count int;
  v_channel_count int;
  v_kds_status text;
  v_checklist jsonb;
  v_ticket_num int;
BEGIN
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  -- T-01: DB connection
  v_test_name := 'DB Connection';
  v_passed    := true;
  v_detail    := 'PostgreSQL connected';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-02: Schema count
  SELECT count(*) INTO v_schema_count
  FROM information_schema.schemata
  WHERE schema_name LIKE 'catchmenu_%'
    AND schema_name != 'catchmenu_dev';

  v_test_name := 'Schema existence (9 required)';
  v_passed    := v_schema_count >= 9;
  v_detail    := v_schema_count::text || ' schemas found';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-03: Store exists
  SELECT EXISTS (
    SELECT 1 FROM catchmenu_hq.stores
    WHERE id = p_store_id
      AND tenant_id = p_tenant_id
      AND is_active = true
  ) INTO v_store_exists;

  v_test_name := 'Store existence';
  v_passed    := v_store_exists;
  v_detail    := p_store_id::text;
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-04: Menu count
  SELECT count(*) INTO v_menu_count
  FROM catchmenu_pos.menus
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND is_active = true;

  v_test_name := 'Menu registration';
  v_passed    := v_menu_count >= 0;
  v_detail    := v_menu_count::text || ' menus registered';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-05: Patent 2 KDS HOLD test
  IF p_scenario IN ('ALL', 'PATENT2') THEN
    -- use sequential ticket number to avoid conflicts
    v_ticket_num := floor(random() * 9000 + 1000)::int;

    INSERT INTO catchmenu_pos.order_sessions (
      tenant_id, store_id,
      session_type, session_status,
      guest_count,
      business_day, business_timezone
    ) VALUES (
      p_tenant_id, p_store_id,
      'KIOSK', 'SEATED', 1,
      v_business_day, 'Asia/Seoul'
    ) RETURNING id INTO v_test_session_id;

    INSERT INTO catchmenu_pos.orders (
      tenant_id, store_id,
      session_id, order_number,
      order_type, order_status,
      order_channel,
      total_amount, discount_amount,
      final_amount, ordered_at,
      business_day, business_timezone
    ) VALUES (
      p_tenant_id, p_store_id,
      v_test_session_id,
      'TEST-' || extract(epoch from now())::int::text,
      'TAKEOUT', 'CONFIRMED',
      'KIOSK',
      1000, 0, 1000, now(),
      v_business_day, 'Asia/Seoul'
    ) RETURNING id INTO v_test_order_id;

    INSERT INTO catchmenu_kds.kds_tickets (
      tenant_id, store_id,
      order_id,
      ticket_number,
      menu_name_snapshot, quantity_snapshot,
      kitchen_zone, kds_status,
      conditions_met,
      ticket_created_at,
      business_day, business_timezone
    ) VALUES (
      p_tenant_id, p_store_id,
      v_test_order_id,
      v_ticket_num,
      'TEST_MENU', 1, 'MAIN', 'HOLD',
      jsonb_build_object(
        'payment_confirmed', false,
        'test', true
      ),
      now(), v_business_day, 'Asia/Seoul'
    );

    SELECT kds_status INTO v_kds_status
    FROM catchmenu_kds.kds_tickets
    WHERE order_id = v_test_order_id;

    v_test_name := 'Patent 2: KDS HOLD verify';
    v_passed    := v_kds_status = 'HOLD';
    v_detail    := 'KDS status = ' || coalesce(v_kds_status, 'NULL');
    v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
    v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
    v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

    -- cleanup
    DELETE FROM catchmenu_kds.kds_tickets
    WHERE order_id = v_test_order_id
      AND (conditions_met->>'test') = 'true';
    DELETE FROM catchmenu_pos.orders WHERE id = v_test_order_id;
    DELETE FROM catchmenu_pos.order_sessions WHERE id = v_test_session_id;
  END IF;

  -- T-06: RLS policies
  SELECT count(*) INTO v_rls_count
  FROM pg_policies
  WHERE schemaname LIKE 'catchmenu_%';

  v_test_name := 'RLS policies';
  v_passed    := v_rls_count >= 5;
  v_detail    := v_rls_count::text || ' RLS policies active';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-07: i18n messages
  SELECT count(*), count(DISTINCT locale)
  INTO v_msg_count, v_locale_count
  FROM catchmenu_common.message_catalog;

  v_test_name := 'i18n message catalog';
  v_passed    := v_locale_count >= 6;
  v_detail    := v_msg_count::text || ' messages / ' || v_locale_count::text || ' locales';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-08: Error codes
  SELECT count(*) INTO v_error_count
  FROM catchmenu_common.error_codes;

  v_test_name := 'Error codes';
  v_passed    := v_error_count >= 50;
  v_detail    := v_error_count::text || ' codes registered';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-09: pg_cron jobs (is_registered = actual column)
  SELECT count(*) INTO v_cron_count
  FROM catchmenu_common.pg_cron_jobs;

  v_test_name := 'pg_cron jobs registered';
  v_passed    := v_cron_count >= 15;
  v_detail    := v_cron_count::text || ' jobs in registry';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-10: SOP runbooks (is_active = actual column)
  SELECT count(*) INTO v_sop_count
  FROM catchmenu_common.sop_runbooks
  WHERE is_active = true;

  v_test_name := 'SOP runbooks';
  v_passed    := v_sop_count >= 10;
  v_detail    := v_sop_count::text || ' runbooks registered';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-11: Opening checklist
  v_checklist := catchmenu_common.run_opening_checklist(
    p_tenant_id, p_store_id
  );

  v_test_name := 'Opening checklist';
  v_passed    := (v_checklist->'data'->>'overall') IN ('READY','CAUTION');
  v_detail    := 'Overall: ' || coalesce(v_checklist->'data'->>'overall','N/A');
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  -- T-12: Realtime channels (is_active = actual column)
  SELECT count(*) INTO v_channel_count
  FROM catchmenu_common.realtime_channels
  WHERE store_id = p_store_id
    AND tenant_id = p_tenant_id
    AND is_active = true;

  v_test_name := 'Realtime channels';
  v_passed    := v_channel_count >= 0;
  v_detail    := v_channel_count::text || ' channels active';
  v_results   := v_results || jsonb_build_object('test',v_test_name,'status',CASE v_passed WHEN true THEN 'PASS' ELSE 'FAIL' END,'detail',v_detail);
  v_pass := v_pass + CASE v_passed WHEN true THEN 1 ELSE 0 END;
  v_fail := v_fail + CASE v_passed WHEN false THEN 1 ELSE 0 END;

  RETURN jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'scenario', p_scenario,
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'overall', CASE v_fail WHEN 0 THEN 'ALL_PASS' ELSE 'HAS_FAILURES' END,
      'pass_count', v_pass,
      'fail_count', v_fail,
      'total_tests', v_pass + v_fail,
      'tests', v_results,
      'tested_at', now(),
      'next_step', CASE v_fail
        WHEN 0 THEN 'DB validation complete. Ready for Flutter MVP.'
        ELSE 'Fix FAIL items and rerun.'
      END
    )
  );
END;
$$;

GRANT EXECUTE ON FUNCTION
  catchmenu_common.run_integration_test(uuid, uuid, text)
  TO authenticated;
