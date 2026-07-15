-- 0157_authorize_kds_release_overload_and_redesign.sql
-- Purpose:
--   Restore the payment-ledger KDS release authorization contract for the
--   normal confirm_payment() path, make start_cooking() fail closed when a
--   committed ticket has no linked payment ledger, and remove the legacy
--   authorize_kds_release() overloads.
--
-- Background:
--   Defect 1: release_kds_after_payment() committed KDS tickets but only wrote
--             kds_release_authorized into kds_tickets.conditions_met JSON; it
--             did not set payment_ledger.kds_release_authorized.
--   Defect 2: bulk_commit_kds_tickets() already gates on the payment_ledger
--             column. It should remain unchanged and pass naturally once
--             Defect 1 is fixed.
--   Defect 3: start_cooking() was fail-open when payment_ledger_id was null.
--             It must fail closed with kds_release_ledger_missing.
--
-- Human decision:
--   601024_ChangeContract.md approved Slice 1, Slice 2, and Slice 3
--   on 2026-07-15.
--
-- Depends on:
--   0156_add_did_device_edid_mapping.sql
--   0098_create_payment_confirm_pipeline_rpc.sql
--   0029_create_kds_cooking_rpc.sql
--   0028_create_kds_capacity_commit_rpc.sql
--   0063_patch_core_rpc_i18n_diagnostics.sql
--
-- Non-goals:
--   Does not modify confirm_payment() body.
--   Does not modify bulk_commit_kds_tickets().
--   Does not modify confirm_payment_from_provider(), Toss webhook, or VAN
--   paths (0027/0038/0056).
--   Does not modify release_kds_ticket_no_payment() (0143).
--   Does not design cash payment, retry, reconciliation, or PG/VAN audit flow.

create or replace function
  catchmenu_payment.release_kds_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_released_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_capacity_check jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- Recheck KDS capacity at the payment-complete late-binding point.
  v_capacity_check :=
    catchmenu_kds.check_kds_capacity(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- Slice 1: create the table-level KDS release authorization before
  -- committing KDS tickets. This aligns the payment_ledger column with the
  -- existing kds_tickets.conditions_met JSON evidence.
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = 'SYSTEM'
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- HOLD tickets -> COMMITTED.
  -- conditions_met JSON evidence:
  --   payment_confirmed = true
  --   kds_release_authorized = true
  with released as (
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'payment_ledger_id', p_ledger_id,
        'released_at', now()
      ),
      committed_at = now(),
      updated_at = now()
    where order_id = p_order_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'HOLD'
    returning id
  )
  select
    count(*),
    coalesce(
      jsonb_agg(to_jsonb(id)), '[]'::jsonb
    )
  into v_released_count, v_ticket_ids
  from released;

  if v_released_count = 0 then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'KDS',
      p_log_event := 'kds_no_hold_tickets',
      p_message :=
        'KDS HOLD tickets not found for order_id='
        || p_order_id,
      p_rpc_name := 'release_kds_after_payment',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'order_id', p_order_id,
        'ledger_id', p_ledger_id
      )
    );
  end if;

  -- KDS realtime broadcast.
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'KDS_TICKETS',
    p_event_type := 'kds_tickets_released',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'ledger_id', p_ledger_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'capacity', v_capacity_check->'data',
      'released_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'kds_released',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'kds_status', 'COMMITTED',
      'capacity_after',
        v_capacity_check->'data',
      'late_binding_principle',
        'HOLD -> COMMITTED after payment only'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_kds.start_cooking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_device_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  select
    id, order_id, session_id, order_item_id, kds_status,
    kitchen_zone, ticket_number,
    menu_name_snapshot, quantity_snapshot,
    estimated_minutes_snapshot,
    payment_ledger_id,
    conditions_met,
    business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'COMMITTED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_ready_to_commit',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- Slice 2: fail closed when the ticket has no linked payment ledger.
  if v_ticket.payment_ledger_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_ledger_missing',
      'message', 'payment_ledger_id is null; ticket has no linked payment record'
    );
  end if;

  if not exists (
    select 1
    from catchmenu_payment.payment_ledger
    where id = v_ticket.payment_ledger_id
      and kds_release_authorized = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_not_authorized',
      'message', 'payment_ledger.kds_release_authorized must be true'
    );
  end if;

  -- COMMITTED -> COOKING
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COOKING',
    cooking_started_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item status
  update catchmenu_pos.order_items
  set
    item_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_item_id;

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    conditions_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'cooking_started',
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    v_ticket.conditions_met,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'menu_name', v_ticket.menu_name_snapshot,
      'estimated_minutes', v_ticket.estimated_minutes_snapshot
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_cooking_started', 1,
    'kds_ticket', p_ticket_id,
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'kitchen_zone', v_ticket.kitchen_zone,
      'ticket_number', v_ticket.ticket_number
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_cooking_started',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'cooking_started_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'COMMITTED'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'COOKING'
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  -- update order status to COOKING if not already
  update catchmenu_pos.orders
  set
    order_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_id
    and order_status = 'CONFIRMED';

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'COOKING',
    'kitchen_zone', v_ticket.kitchen_zone,
    'cooking_started_at', now(),
    'estimated_minutes', v_ticket.estimated_minutes_snapshot,
    'audit_id', v_audit_id
  );
end;
$$;

drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
);

drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text, text, text
);
