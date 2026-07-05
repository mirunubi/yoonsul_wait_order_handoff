-- 0143_add_no_payment_kds_release_policy.sql
-- Purpose: Store-scoped no-payment pilot release from KDS HOLD.
-- Boundary: This policy is independent from manual fallback and preserves
--           the existing payment-confirmed release path.
-- Depends on: 0049_create_store_settings_rpc.sql,
--             0053_create_staff_management_rpc.sql

alter table catchmenu_store.store_settings
  add column if not exists payment_required_for_kds_release boolean
  not null default true;

comment on column
  catchmenu_store.store_settings.payment_required_for_kds_release is
  'Store-scoped KDS payment policy. TRUE preserves the normal payment-required '
  'release path. FALSE enables the explicitly authorized NO_PAYMENT_PILOT RPC. '
  'This setting is unrelated to manual_fallback_activated.';

create or replace function catchmenu_kds.release_kds_ticket_no_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ticket_id uuid,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = pg_catalog
as $$
declare
  v_ticket record;
  v_staff record;
  v_capacity jsonb;
  v_conditions jsonb;
  v_remaining_conditions_met boolean;
  v_audit_id uuid;
begin
  if p_tenant_id is null
     or p_store_id is null
     or p_order_id is null
     or p_ticket_id is null
     or p_actor_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'release_scope_required'
    );
  end if;

  if catchmenu_common.current_tenant_id() is distinct from p_tenant_id
     or catchmenu_common.current_store_id() is distinct from p_store_id
     or catchmenu_common.current_actor_id() is distinct from p_actor_id then
    return jsonb_build_object(
      'success', false,
      'error_key', 'release_context_mismatch'
    );
  end if;

  select
    s.id,
    s.staff_role,
    s.authority_level,
    s.can_override_kds
  into v_staff
  from catchmenu_store.staff s
  where s.id = p_actor_id
    and s.tenant_id = p_tenant_id
    and s.store_id = p_store_id
    and s.staff_status = 'ACTIVE'
    and s.is_active = true;

  if v_staff.id is null or not coalesce(v_staff.can_override_kds, false) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'unauthorized_release'
    );
  end if;

  if not exists (
    select 1
    from catchmenu_store.store_settings ss
    where ss.tenant_id = p_tenant_id
      and ss.store_id = p_store_id
      and ss.payment_required_for_kds_release = false
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'no_payment_policy_not_active'
    );
  end if;

  select
    kt.id,
    kt.tenant_id,
    kt.store_id,
    kt.order_id,
    kt.session_id,
    kt.kds_status,
    kt.conditions_met,
    kt.kitchen_zone,
    kt.business_day,
    kt.business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets kt
  where kt.id = p_ticket_id
    and kt.tenant_id = p_tenant_id
    and kt.store_id = p_store_id
    and kt.order_id = p_order_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_scope_mismatch'
    );
  end if;

  if v_ticket.kds_status = 'READY_TO_COMMIT'
     and coalesce(
       (v_ticket.conditions_met->>'no_payment_policy_released')::boolean,
       false
     ) then
    return jsonb_build_object(
      'success', true,
      'already_released', true,
      'ticket_id', p_ticket_id,
      'kds_status', v_ticket.kds_status,
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'message_code', 'kds_no_payment_policy_already_released'
    );
  end if;

  if v_ticket.kds_status <> 'HOLD' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_holdable',
      'current_status', v_ticket.kds_status
    );
  end if;

  v_capacity := catchmenu_kds.evaluate_kds_capacity(
    p_tenant_id,
    p_store_id,
    v_ticket.kitchen_zone
  );

  v_conditions := coalesce(v_ticket.conditions_met, '{}'::jsonb)
    || jsonb_build_object(
      'kds_capacity_ok',
      coalesce((v_capacity->>'capacity_ok')::boolean, false)
    );

  v_remaining_conditions_met := (
    coalesce((v_conditions->>'arrived')::boolean, false)
    and coalesce((v_conditions->>'table_confirmed')::boolean, false)
    and coalesce((v_conditions->>'kds_capacity_ok')::boolean, false)
    and coalesce((v_conditions->>'menu_available')::boolean, true)
    and coalesce((v_conditions->>'peak_time_ok')::boolean, true)
    and coalesce((v_conditions->>'no_show_risk_ok')::boolean, true)
  );

  if not v_remaining_conditions_met then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_conditions_not_met',
      'ticket_id', p_ticket_id,
      'conditions_met', v_conditions
    );
  end if;

  v_conditions := v_conditions || jsonb_build_object(
    'no_payment_policy_released', true,
    'no_payment_policy_release_source', 'STORE_NO_PAYMENT_POLICY',
    'no_payment_policy_authorized_by', p_actor_id
  );

  update catchmenu_kds.kds_tickets
  set
    kds_status = 'READY_TO_COMMIT',
    conditions_met = v_conditions,
    committed_at = now(),
    capacity_check_at = now(),
    kds_queue_length_at_check =
      (v_capacity->>'cooking_count')::int,
    updated_at = now()
  where id = p_ticket_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and order_id = p_order_id
    and kds_status = 'HOLD';

  if not found then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_release_conflict'
    );
  end if;

  insert into catchmenu_kds.kds_events (
    tenant_id,
    store_id,
    ticket_id,
    order_id,
    event_type,
    from_status,
    to_status,
    caused_by_type,
    caused_by_id,
    conditions_at_event,
    event_payload,
    correlation_id,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    p_ticket_id,
    p_order_id,
    'all_conditions_met',
    'HOLD',
    'READY_TO_COMMIT',
    'STAFF',
    p_actor_id,
    v_conditions,
    jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_confirmed',
        coalesce((v_conditions->>'payment_confirmed')::boolean, false),
      'staff_role', v_staff.staff_role,
      'authority_level', v_staff.authority_level
    ),
    p_correlation_id,
    now()
  );

  insert into catchmenu_ledger.events (
    tenant_id,
    store_id,
    event_domain,
    event_type,
    event_version,
    subject_type,
    subject_id,
    from_state,
    to_state,
    caused_by_type,
    caused_by_id,
    event_payload,
    session_id,
    order_id,
    kds_ticket_id,
    correlation_id,
    business_day,
    business_timezone,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    'kds',
    'kds_no_payment_policy_released',
    1,
    'kds_ticket',
    p_ticket_id,
    'HOLD',
    'READY_TO_COMMIT',
    'STAFF',
    p_actor_id,
    jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_required_for_kds_release', false,
      'payment_confirmed',
        coalesce((v_conditions->>'payment_confirmed')::boolean, false)
    ),
    v_ticket.session_id,
    p_order_id,
    p_ticket_id,
    p_correlation_id,
    v_ticket.business_day,
    v_ticket.business_timezone,
    now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_no_payment_policy_released',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'APPROVED',
    p_decision_reason := 'STORE_NO_PAYMENT_POLICY',
    p_decision_payload := jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_required_for_kds_release', false,
      'authorizing_actor_id', p_actor_id
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'HOLD',
      'conditions_met', v_ticket.conditions_met
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'READY_TO_COMMIT',
      'conditions_met', v_conditions
    ),
    p_session_id := v_ticket.session_id,
    p_order_id := p_order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'already_released', false,
    'ticket_id', p_ticket_id,
    'order_id', p_order_id,
    'kds_status', 'READY_TO_COMMIT',
    'release_source', 'STORE_NO_PAYMENT_POLICY',
    'authorized_by', p_actor_id,
    'audit_id', v_audit_id,
    'message_code', 'kds_no_payment_policy_released'
  );
end;
$$;

revoke all on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) from public;

grant execute on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) to authenticated;

comment on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) is
  'Releases one HOLD ticket to READY_TO_COMMIT only when the exact tenant/store '
  'has payment_required_for_kds_release = FALSE and the authenticated active '
  'staff actor has can_override_kds. The RPC preserves payment_confirmed and '
  'does not read or use manual_fallback_activated.';
