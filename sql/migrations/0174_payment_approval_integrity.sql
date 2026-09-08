-- Workpacket: 602020
-- Runtime Gate RG-02; provider approval integrity.
-- Scope: payment approval identity constraints and
--        catchmenu_payment.confirm_payment_from_provider(...) only.

BEGIN;

DO $precheck$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM catchmenu_payment.payment_ledger
    WHERE ledger_entry_type = 'APPROVAL'
      AND provider_payment_key IS NULL
  ) THEN
    RAISE EXCEPTION
      'payment_ledger contains APPROVAL rows with NULL provider_payment_key';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM catchmenu_payment.payment_ledger
    WHERE ledger_entry_type = 'APPROVAL'
    GROUP BY tenant_id, provider_type, provider_payment_key
    HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION
      'payment_ledger contains duplicate provider approval identities';
  END IF;
END;
$precheck$;

ALTER TABLE catchmenu_payment.payment_ledger
  ADD CONSTRAINT chk_payment_ledger_approval_provider_key_not_null
  CHECK (
    ledger_entry_type <> 'APPROVAL'
    OR provider_payment_key IS NOT NULL
  );

CREATE UNIQUE INDEX uq_payment_ledger_provider_approval_identity
  ON catchmenu_payment.payment_ledger (
    tenant_id,
    provider_type,
    provider_payment_key
  )
  WHERE ledger_entry_type = 'APPROVAL';

CREATE OR REPLACE FUNCTION catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_provider_payment_key text,
  p_provider_approval_number text,
  p_approved_amount int,
  p_provider_raw_event_id uuid,
  p_correlation_id text default null
)
RETURNS jsonb
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
AS $function$
DECLARE
  v_intent record;
  v_raw_event record;
  v_existing_ledger record;
  v_existing_audit_id uuid;
  v_existing_kds_audit_id uuid;
  v_existing_kds_payload jsonb;
  v_existing_ticket_count int;
  v_ledger_id uuid;
  v_audit_id uuid;
  v_kds_release_result jsonb;
  v_kds_updated int;
BEGIN
  -- RG-01 tenant gate must precede every tenant-scoped read or mutation.
  PERFORM catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  -- Intent validation and serialization boundary.
  SELECT id, order_id, session_id, store_id, provider_type,
         requested_amount, payment_method, payment_channel,
         business_day, business_timezone, provider_order_id
  INTO v_intent
  FROM catchmenu_payment.payment_intents
  WHERE id = p_intent_id
    AND store_id = p_store_id
    AND tenant_id = p_tenant_id
  FOR UPDATE;

  IF v_intent.id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'intent_not_found'
    );
  END IF;

  IF v_intent.requested_amount <> p_approved_amount THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'amount_mismatch',
      'requested_amount', v_intent.requested_amount,
      'approved_amount', p_approved_amount
    );
  END IF;

  IF p_provider_raw_event_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_required'
    );
  END IF;

  IF trim(coalesce(p_provider_payment_key, '')) = '' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'provider_payment_key_required'
    );
  END IF;

  -- Only the TOSS_PAYMENTS structural binding is established in RG-02.
  IF v_intent.provider_type <> 'TOSS_PAYMENTS' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'provider_binding_unsupported',
      'provider_type', v_intent.provider_type
    );
  END IF;

  SELECT id, tenant_id, store_id,
         provider_type, provider_code,
         provider_event_id, provider_event_type,
         raw_payload, payload_hash,
         signature_verified, signature_verified_at,
         schema_validated, schema_validation_errors,
         processing_status
  INTO v_raw_event
  FROM catchmenu_gateway.provider_raw_events
  WHERE id = p_provider_raw_event_id
    AND tenant_id = p_tenant_id
    AND store_id = p_store_id
    AND provider_type = v_intent.provider_type;

  IF v_raw_event.id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_scope_mismatch'
    );
  END IF;

  IF v_raw_event.provider_event_id IS DISTINCT FROM p_provider_payment_key
     OR v_raw_event.signature_verified IS DISTINCT FROM true
     OR v_raw_event.signature_verified_at IS NULL
     OR v_raw_event.schema_validated IS DISTINCT FROM true
     OR v_raw_event.schema_validation_errors IS NOT NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_verification_failed'
    );
  END IF;

  IF v_raw_event.provider_code <> 'TOSS'
     OR v_raw_event.processing_status NOT IN ('VALIDATING', 'ACCEPTED')
     OR v_raw_event.raw_payload->>'paymentKey'
          IS DISTINCT FROM p_provider_payment_key
     OR v_raw_event.raw_payload->>'orderId'
          IS DISTINCT FROM v_intent.provider_order_id
     OR v_raw_event.raw_payload->>'status' IS DISTINCT FROM 'DONE'
     OR v_raw_event.raw_payload->>'totalAmount'
          IS DISTINCT FROM p_approved_amount::text
     OR v_raw_event.raw_payload->>'approveNo'
          IS DISTINCT FROM p_provider_approval_number
     OR v_raw_event.payload_hash IS DISTINCT FROM encode(
          extensions.digest(v_raw_event.raw_payload::text, 'sha256'),
          'hex'
        ) THEN
    RETURN jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_payment_mismatch'
    );
  END IF;

  -- The partial unique index is the concurrency backstop. DO NOTHING lets
  -- an exact replay return the first ledger row instead of a duplicate error.
  INSERT INTO catchmenu_payment.payment_ledger (
    tenant_id, store_id, order_id, session_id, intent_id,
    ledger_entry_type, ledger_status,
    approved_amount, net_amount,
    provider_type, provider_payment_key,
    provider_approval_number, provider_approved_at,
    provider_response_id,
    reconciliation_status,
    kds_release_authorized,
    business_day, business_timezone,
    approved_at
  ) VALUES (
    p_tenant_id, p_store_id,
    v_intent.order_id, v_intent.session_id, p_intent_id,
    'APPROVAL', 'APPROVED',
    p_approved_amount, p_approved_amount,
    v_intent.provider_type, p_provider_payment_key,
    p_provider_approval_number, now(),
    p_provider_raw_event_id,
    'PENDING',
    false,
    v_intent.business_day, v_intent.business_timezone,
    now()
  )
  ON CONFLICT (tenant_id, provider_type, provider_payment_key)
    WHERE ledger_entry_type = 'APPROVAL'
  DO NOTHING
  RETURNING id INTO v_ledger_id;

  IF v_ledger_id IS NULL THEN
    SELECT id, tenant_id, store_id, order_id, session_id, intent_id,
           ledger_entry_type, ledger_status,
           approved_amount, provider_type, provider_payment_key,
           provider_approval_number, reconciliation_status,
           kds_release_authorized
    INTO v_existing_ledger
    FROM catchmenu_payment.payment_ledger
    WHERE tenant_id = p_tenant_id
      AND provider_type = v_intent.provider_type
      AND provider_payment_key = p_provider_payment_key
      AND ledger_entry_type = 'APPROVAL';

    IF v_existing_ledger.id IS NULL THEN
      RAISE EXCEPTION USING
        ERRCODE = '40001',
        MESSAGE = 'provider approval conflict row was not visible';
    END IF;

    IF v_existing_ledger.store_id IS DISTINCT FROM p_store_id
       OR v_existing_ledger.order_id IS DISTINCT FROM v_intent.order_id
       OR v_existing_ledger.session_id IS DISTINCT FROM v_intent.session_id
       OR v_existing_ledger.intent_id IS DISTINCT FROM p_intent_id
       OR v_existing_ledger.ledger_status IS DISTINCT FROM 'APPROVED'
       OR v_existing_ledger.approved_amount IS DISTINCT FROM p_approved_amount
       OR v_existing_ledger.provider_approval_number
            IS DISTINCT FROM p_provider_approval_number THEN
      RETURN jsonb_build_object(
        'success', false,
        'error_key', 'provider_approval_identity_conflict',
        'ledger_id', v_existing_ledger.id
      );
    END IF;

    SELECT ar.id
    INTO v_existing_audit_id
    FROM catchmenu_ledger.audit_records ar
    WHERE ar.payment_id = v_existing_ledger.id
      AND ar.audit_domain = 'payment'
      AND ar.audit_type = 'payment_approved'
    ORDER BY ar.recorded_at, ar.id
    LIMIT 1;

    SELECT coalesce(
             (pe.event_payload->>'kds_tickets_updated')::int,
             0
           )
    INTO v_existing_ticket_count
    FROM catchmenu_payment.payment_events pe
    WHERE pe.ledger_id = v_existing_ledger.id
      AND pe.event_type = 'payment_approved'
    ORDER BY pe.occurred_at, pe.id
    LIMIT 1;

    v_existing_ticket_count := coalesce(v_existing_ticket_count, 0);

    SELECT ar.id, ar.decision_payload
    INTO v_existing_kds_audit_id, v_existing_kds_payload
    FROM catchmenu_ledger.audit_records ar
    WHERE ar.subject_id = v_existing_ledger.id
      AND ar.audit_domain = 'payment'
      AND ar.audit_type = 'kds_release_requested'
    ORDER BY ar.recorded_at, ar.id
    LIMIT 1;

    IF v_existing_kds_audit_id IS NOT NULL THEN
      v_kds_release_result := jsonb_build_object(
        'success', true,
        'result_code', v_existing_kds_payload->>'result_code',
        'ledger_id', v_existing_ledger.id,
        'order_id', v_existing_ledger.order_id,
        'committed_count',
          v_existing_kds_payload->'bulk_commit_result'->'committed_count',
        'pending_count',
          v_existing_kds_payload->'bulk_commit_result'->'pending_count',
        'skipped_count',
          v_existing_kds_payload->'bulk_commit_result'->'skipped_count',
        'bulk_commit_detail',
          v_existing_kds_payload->'bulk_commit_result',
        'audit_id', v_existing_kds_audit_id
      );
    ELSE
      v_kds_release_result := jsonb_build_object(
        'success', true,
        'ledger_id', v_existing_ledger.id,
        'order_id', v_existing_ledger.order_id,
        'result_code', 'PAYMENT_APPROVAL_ALREADY_RECORDED'
      );
    END IF;

    RETURN jsonb_build_object(
      'success', true,
      'ledger_id', v_existing_ledger.id,
      'intent_id', v_existing_ledger.intent_id,
      'ledger_status', v_existing_ledger.ledger_status,
      'approved_amount', v_existing_ledger.approved_amount,
      'kds_release_authorized',
        (v_kds_release_result->>'result_code' =
          'PAYMENT_CONFIRMED_KDS_COMMITTED'),
      'kds_tickets_payment_confirmed', v_existing_ticket_count,
      'kds_release_result', v_kds_release_result,
      'result_code', v_kds_release_result->>'result_code',
      'reconciliation_status',
        v_existing_ledger.reconciliation_status,
      'message_code', CASE
        WHEN v_kds_release_result->>'result_code' =
             'PAYMENT_CONFIRMED_KDS_COMMITTED'
          THEN 'payment_approved_kds_released'
        ELSE 'payment_approved_kds_pending'
      END,
      'audit_id', v_existing_audit_id
    );
  END IF;

  UPDATE catchmenu_payment.payment_intents
  SET
    intent_status = 'CONFIRMED',
    confirmed_at = now(),
    updated_at = now()
  WHERE id = p_intent_id;

  UPDATE catchmenu_pos.order_sessions
  SET
    session_status = 'PAYMENT_PENDING',
    payment_completed_at = now(),
    updated_at = now()
  WHERE id = v_intent.session_id;

  UPDATE catchmenu_kds.kds_tickets
  SET
    conditions_met = conditions_met || jsonb_build_object(
      'payment_confirmed', true
    ),
    payment_ledger_id = v_ledger_id,
    updated_at = now()
  WHERE order_id = v_intent.order_id
    AND kds_status IN ('HOLD', 'CAPACITY_CHECKING');

  GET DIAGNOSTICS v_kds_updated = ROW_COUNT;

  INSERT INTO catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, caused_by_type,
    conditions_at_event, event_payload, occurred_at
  )
  SELECT
    p_tenant_id, p_store_id, kt.id, v_intent.order_id,
    'payment_confirmed_released',
    'SYSTEM',
    kt.conditions_met,
    jsonb_build_object(
      'payment_ledger_id', v_ledger_id,
      'approved_amount', p_approved_amount
    ),
    now()
  FROM catchmenu_kds.kds_tickets kt
  WHERE kt.order_id = v_intent.order_id
    AND kt.kds_status IN ('HOLD', 'CAPACITY_CHECKING');

  INSERT INTO catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    intent_id, ledger_id,
    event_type, from_status, to_status,
    caused_by_type, amount_at_event,
    provider_event_id,
    event_payload, correlation_id, occurred_at
  ) VALUES (
    p_tenant_id, p_store_id, v_intent.order_id,
    p_intent_id, v_ledger_id,
    'payment_approved', 'PROCESSING', 'APPROVED',
    'PROVIDER', p_approved_amount,
    p_provider_payment_key,
    jsonb_build_object(
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_tickets_updated', v_kds_updated,
      'kds_release_authorized', false,
      'kds_release_pending_capacity_check', true
    ),
    p_correlation_id, now()
  );

  INSERT INTO catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) VALUES (
    p_tenant_id, p_store_id,
    'payment', 'payment_approved', 1,
    'payment_ledger', v_ledger_id,
    'PROCESSING', 'APPROVED',
    'PROVIDER',
    jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'kds_release_authorized', false,
      'reconciliation_required', true
    ),
    v_intent.session_id, v_intent.order_id, v_ledger_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_approved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'PROVIDER',
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_release_authorized', false,
      'reconciliation_status', 'PENDING'
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', 'APPROVED',
      'kds_release_authorized', false
    ),
    p_payment_id := v_ledger_id,
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  BEGIN
    v_kds_release_result := catchmenu_payment.request_kds_release_after_payment(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := v_intent.order_id,
      p_ledger_id := v_ledger_id,
      p_actor_type := 'PROVIDER',
      p_correlation_id := p_correlation_id
    );
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        PERFORM catchmenu_audit.append_audit_record(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_audit_domain := 'payment',
          p_audit_type := 'kds_release_call_unexpected_exception',
          p_audit_category := 'FINANCIAL',
          p_actor_type := 'PROVIDER',
          p_actor_id := null,
          p_subject_type := 'payment_ledger',
          p_subject_id := v_ledger_id,
          p_decision := 'FAILED',
          p_decision_payload := jsonb_build_object(
            'error', sqlerrm,
            'sqlstate', sqlstate
          ),
          p_order_id := v_intent.order_id,
          p_correlation_id := p_correlation_id
        );
      EXCEPTION
        WHEN OTHERS THEN
          RAISE WARNING 'confirm_payment_from_provider(): audit logging of the KDS-release-call failure itself failed (sqlstate=%) -- payment_ledger row % still committed; server log only for the original KDS failure', sqlstate, v_ledger_id;
      END;

      v_kds_release_result := jsonb_build_object(
        'success', true,
        'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
        'ledger_id', v_ledger_id,
        'order_id', v_intent.order_id,
        'error_detail', jsonb_build_object('sqlstate', sqlstate)
      );
  END;

  RETURN jsonb_build_object(
    'success', true,
    'ledger_id', v_ledger_id,
    'intent_id', p_intent_id,
    'ledger_status', 'APPROVED',
    'approved_amount', p_approved_amount,
    'kds_release_authorized',
      (v_kds_release_result->>'result_code' =
        'PAYMENT_CONFIRMED_KDS_COMMITTED'),
    'kds_tickets_payment_confirmed', v_kds_updated,
    'kds_release_result', v_kds_release_result,
    'result_code', v_kds_release_result->>'result_code',
    'reconciliation_status', 'PENDING',
    'message_code', CASE
      WHEN v_kds_release_result->>'result_code' =
           'PAYMENT_CONFIRMED_KDS_COMMITTED'
        THEN 'payment_approved_kds_released'
      ELSE 'payment_approved_kds_pending'
    END,
    'audit_id', v_audit_id
  );
END;
$function$;

COMMIT;
