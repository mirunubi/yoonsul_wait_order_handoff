-- Migration: 0175_kds_payment_precondition.sql
-- Workpacket: 602030
-- Runtime Gate RG-03: enforce an approved payment ledger before every
-- general KDS COMMITTED path.
-- Changes:
--   catchmenu_kds.commit_kds_ticket(...)
--   catchmenu_kds.bulk_commit_kds_tickets(...)
--   catchmenu_payment.release_kds_after_payment(...)
--   catchmenu_integrations.accept_delivery_order(...)
-- Non-goal:
--   catchmenu_kds.release_kds_ticket_no_payment(...) remains unchanged.

BEGIN;

create or replace function catchmenu_kds.commit_kds_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_conditions jsonb default '{}'::jsonb,
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
  v_approval_ledger_id uuid;
  v_merged_conditions jsonb;
  v_all_met boolean;
  v_capacity jsonb;
  v_audit_id uuid;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  -- input validation
  if p_ticket_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_id_required'
    );
  end if;

  if jsonb_typeof(coalesce(p_conditions, '{}'::jsonb)) <> 'object' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'conditions_must_be_object'
    );
  end if;

  -- ticket validation with lock
  select
    kt.id, kt.store_id, kt.tenant_id,
    kt.order_id, kt.order_item_id, kt.session_id,
    kt.kds_status, kt.conditions_met,
    kt.kitchen_zone, kt.priority,
    kt.estimated_minutes_snapshot,
    kt.business_day, kt.business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets kt
  where kt.id = p_ticket_id
    and kt.store_id = p_store_id
    and kt.tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  -- ticket must be in holdable state
  if v_ticket.kds_status not in ('HOLD', 'CAPACITY_CHECKING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_holdable',
      'current_status', v_ticket.kds_status
    );
  end if;

  select pl.id
  into v_approval_ledger_id
  from catchmenu_payment.payment_ledger pl
  where pl.tenant_id = p_tenant_id
    and pl.store_id = p_store_id
    and pl.order_id = v_ticket.order_id
    and pl.ledger_entry_type = 'APPROVAL'
    and pl.ledger_status = 'APPROVED'
  order by pl.approved_at, pl.id
  limit 1
  for share;

  if v_approval_ledger_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_approval_required',
      'order_id', v_ticket.order_id
    );
  end if;

  -- Caller JSON may carry non-payment late-binding facts. Payment facts are
  -- removed and rebuilt only from the approved ledger selected above.
  v_merged_conditions := (
    coalesce(v_ticket.conditions_met, '{}'::jsonb)
    || coalesce(p_conditions, '{}'::jsonb)
  )
    - 'payment_confirmed'
    - 'payment_ledger_id'
    - 'kds_release_authorized';

  v_merged_conditions := v_merged_conditions || jsonb_build_object(
    'payment_confirmed', true,
    'payment_ledger_id', v_approval_ledger_id
  );

  -- evaluate KDS capacity for this kitchen zone
  v_capacity := catchmenu_kds.evaluate_kds_capacity(
    p_tenant_id,
    p_store_id,
    v_ticket.kitchen_zone
  );

  -- update kds_capacity_ok from real-time evaluation
  v_merged_conditions := v_merged_conditions || jsonb_build_object(
    'kds_capacity_ok',
    (v_capacity->>'capacity_ok')::boolean
  );

  -- check all 7 conditions
  -- 특허2: 7개 조건 모두 true일 때만 COMMITTED 전환
  v_all_met := (
    coalesce(
      (v_merged_conditions->>'arrived')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'table_confirmed')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'payment_confirmed')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'kds_capacity_ok')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'menu_available')::boolean, true
    )
    and coalesce(
      (v_merged_conditions->>'peak_time_ok')::boolean, true
    )
    and coalesce(
      (v_merged_conditions->>'no_show_risk_ok')::boolean, true
    )
  );

  if v_all_met then
    -- all conditions met → COMMITTED
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = v_merged_conditions,
      payment_ledger_id = v_approval_ledger_id,
      committed_at = now(),
      capacity_check_at = now(),
      kds_queue_length_at_check =
        (v_capacity->>'cooking_count')::int,
      updated_at = now()
    where id = p_ticket_id;

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id, ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type,
      conditions_at_event,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      p_ticket_id, v_ticket.order_id,
      'all_conditions_met',
      v_ticket.kds_status, 'COMMITTED',
      'SYSTEM',
      v_merged_conditions,
      jsonb_build_object(
        'kitchen_zone', v_ticket.kitchen_zone,
        'kds_queue_length', v_capacity->>'cooking_count',
        'committed_at', now()
      ),
      p_correlation_id, now()
    );

    -- ledger event
    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, event_payload,
      order_id, kds_ticket_id,
      correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'kds', 'kds_committed', 1,
      'kds_ticket', p_ticket_id,
      v_ticket.kds_status, 'COMMITTED',
      'SYSTEM',
      jsonb_build_object(
        'conditions_met', v_merged_conditions,
        'kitchen_zone', v_ticket.kitchen_zone,
        'late_binding_commit', true
      ),
      v_ticket.order_id, p_ticket_id,
      p_correlation_id,
      v_ticket.business_day, v_ticket.business_timezone, now()
    );

    -- audit record for KDS commit
    v_audit_id := catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'kds',
      p_audit_type := 'kds_committed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'SYSTEM',
      p_actor_id := null,
      p_subject_type := 'kds_ticket',
      p_subject_id := p_ticket_id,
      p_decision := 'APPROVED',
      p_decision_payload := jsonb_build_object(
        'conditions_met', v_merged_conditions,
        'kitchen_zone', v_ticket.kitchen_zone,
        'committed_at', now()
      ),
      p_before_state := jsonb_build_object(
        'kds_status', v_ticket.kds_status,
        'conditions_met', v_ticket.conditions_met
      ),
      p_after_state := jsonb_build_object(
        'kds_status', 'COMMITTED',
        'conditions_met', v_merged_conditions
      ),
      p_order_id := v_ticket.order_id,
      p_kds_ticket_id := p_ticket_id,
      p_correlation_id := p_correlation_id,
      p_business_day := v_ticket.business_day,
      p_business_timezone := v_ticket.business_timezone
    );

    return jsonb_build_object(
      'success', true,
      'ticket_id', p_ticket_id,
      'kds_status', 'COMMITTED',
      'conditions_met', v_merged_conditions,
      'committed_at', now(),
      'kitchen_zone', v_ticket.kitchen_zone,
      'audit_id', v_audit_id,
      'message_code', 'kds_committed'
    );

  else
    -- conditions not all met → CAPACITY_CHECKING
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'CAPACITY_CHECKING',
      conditions_met = v_merged_conditions,
      capacity_check_at = now(),
      kds_queue_length_at_check =
        (v_capacity->>'cooking_count')::int,
      updated_at = now()
    where id = p_ticket_id;

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id, ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type, conditions_at_event,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      p_ticket_id, v_ticket.order_id,
      'condition_updated',
      v_ticket.kds_status, 'CAPACITY_CHECKING',
      'SYSTEM', v_merged_conditions,
      jsonb_build_object(
        'missing_conditions', jsonb_build_object(
          'arrived',
            coalesce(
              (v_merged_conditions->>'arrived')::boolean, false
            ),
          'table_confirmed',
            coalesce(
              (v_merged_conditions->>'table_confirmed')::boolean,
              false
            ),
          'payment_confirmed',
            coalesce(
              (v_merged_conditions->>'payment_confirmed')::boolean,
              false
            ),
          'kds_capacity_ok',
            coalesce(
              (v_merged_conditions->>'kds_capacity_ok')::boolean,
              false
            ),
          'menu_available',
            coalesce(
              (v_merged_conditions->>'menu_available')::boolean,
              true
            )
        ),
        'kitchen_zone', v_ticket.kitchen_zone
      ),
      p_correlation_id, now()
    );

    return jsonb_build_object(
      'success', true,
      'ticket_id', p_ticket_id,
      'kds_status', 'CAPACITY_CHECKING',
      'conditions_met', v_merged_conditions,
      'all_conditions_met', false,
      'missing_conditions', jsonb_build_object(
        'arrived',
          coalesce(
            (v_merged_conditions->>'arrived')::boolean, false
          ),
        'table_confirmed',
          coalesce(
            (v_merged_conditions->>'table_confirmed')::boolean,
            false
          ),
        'payment_confirmed',
          coalesce(
            (v_merged_conditions->>'payment_confirmed')::boolean,
            false
          ),
        'kds_capacity_ok',
          coalesce(
            (v_merged_conditions->>'kds_capacity_ok')::boolean,
            false
          ),
        'menu_available',
          coalesce(
            (v_merged_conditions->>'menu_available')::boolean,
            true
          )
      ),
      'capacity_detail', v_capacity,
      'message_code', 'kds_conditions_pending'
    );
  end if;
end;
$$;

create or replace function catchmenu_kds.bulk_commit_kds_tickets(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_force_conditions jsonb default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_payment,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_ticket record;
  v_committed_count int := 0;
  v_pending_count int := 0;
  v_skipped_count int := 0;
  v_commit_result jsonb;
  v_ticket_results jsonb := '[]'::jsonb;
  v_approval_ledger_id uuid;
  v_merged_conditions jsonb;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select pl.id
  into v_approval_ledger_id
  from catchmenu_payment.payment_ledger pl
  where pl.tenant_id = p_tenant_id
    and pl.store_id = p_store_id
    and pl.order_id = p_order_id
    and pl.ledger_entry_type = 'APPROVAL'
    and pl.ledger_status = 'APPROVED'
  order by pl.approved_at, pl.id
  limit 1
  for share;

  if v_approval_ledger_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_approval_required',
      'order_id', p_order_id
    );
  end if;

  -- process each holdable ticket for this order
  for v_ticket in
    select id, kds_status, conditions_met,
           kitchen_zone, ticket_number
    from catchmenu_kds.kds_tickets
    where order_id = p_order_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status in ('HOLD', 'CAPACITY_CHECKING')
    order by priority asc, ticket_created_at asc
  loop
    -- merge force_conditions if provided
    v_merged_conditions := (
      coalesce(
      v_ticket.conditions_met, '{}'::jsonb
      ) || coalesce(p_force_conditions, '{}'::jsonb)
    )
      - 'payment_confirmed'
      - 'payment_ledger_id'
      - 'kds_release_authorized';

    -- attempt commit
    v_commit_result := catchmenu_kds.commit_kds_ticket(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_ticket_id := v_ticket.id,
      p_conditions := v_merged_conditions,
      p_correlation_id := p_correlation_id
    );

    if (v_commit_result->>'kds_status') = 'COMMITTED' then
      v_committed_count := v_committed_count + 1;
    elsif (v_commit_result->>'kds_status') = 'CAPACITY_CHECKING' then
      v_pending_count := v_pending_count + 1;
    else
      v_skipped_count := v_skipped_count + 1;
    end if;

    v_ticket_results := v_ticket_results || jsonb_build_array(
      jsonb_build_object(
        'ticket_id', v_ticket.id,
        'ticket_number', v_ticket.ticket_number,
        'kitchen_zone', v_ticket.kitchen_zone,
        'kds_status', v_commit_result->>'kds_status',
        'all_conditions_met',
          coalesce(
            (v_commit_result->>'all_conditions_met')::boolean,
            (v_commit_result->>'kds_status') = 'COMMITTED'
          )
      )
    );
  end loop;

  -- ledger event for bulk commit
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  )
  select
    p_tenant_id, p_store_id,
    'kds', 'kds_bulk_commit_attempted', 1,
    'order', p_order_id,
    'HOLD_OR_CHECKING', 'BULK_COMMIT_ATTEMPTED',
    'SYSTEM',
    jsonb_build_object(
      'committed_count', v_committed_count,
      'pending_count', v_pending_count,
      'skipped_count', v_skipped_count,
      'ticket_results', v_ticket_results
    ),
    p_order_id, p_correlation_id,
    business_day, business_timezone, now()
  from catchmenu_pos.orders
  where id = p_order_id;

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'committed_count', v_committed_count,
    'pending_count', v_pending_count,
    'skipped_count', v_skipped_count,
    'total_processed',
      v_committed_count + v_pending_count + v_skipped_count,
    'all_committed', v_pending_count = 0 and v_skipped_count = 0,
    'ticket_results', v_ticket_results,
    'message_code', case
      when v_committed_count > 0 and v_pending_count = 0
      then 'all_tickets_committed'
      when v_committed_count > 0 and v_pending_count > 0
      then 'partial_tickets_committed'
      else 'no_tickets_committed'
    end
  );
end;
$$;

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
  v_approval_ledger_id uuid;
  v_capacity_check jsonb;
  v_business_day date;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select pl.id
  into v_approval_ledger_id
  from catchmenu_payment.payment_ledger pl
  where pl.id = p_ledger_id
    and pl.tenant_id = p_tenant_id
    and pl.store_id = p_store_id
    and pl.order_id = p_order_id
    and pl.ledger_entry_type = 'APPROVAL'
    and pl.ledger_status = 'APPROVED'
  order by pl.approved_at, pl.id
  limit 1
  for share;

  if v_approval_ledger_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_approval_required',
      'order_id', p_order_id,
      'ledger_id', p_ledger_id
    );
  end if;

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
  where id = v_approval_ledger_id;

  -- HOLD tickets -> COMMITTED.
  -- conditions_met JSON evidence:
  --   payment_confirmed = true
  --   kds_release_authorized = true
  with released as (
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = conditions_met || jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'payment_ledger_id', v_approval_ledger_id,
        'released_at', now()
      ),
      payment_ledger_id = v_approval_ledger_id,
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

create or replace function
  catchmenu_integrations.accept_delivery_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intake_id uuid,
  p_estimated_minutes int default 20,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_intake record;
  v_order_id uuid;
  v_order_number text;
  v_kds_ticket_id uuid;
  v_business_day date;
  v_timezone text;
  v_item jsonb;
  v_menu_id uuid;
  v_session_id uuid;
  v_order_item_id uuid;
  v_approval_ledger_id uuid;
  v_ticket_count int := 0;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 수신 로그 조회
  select id, platform_code,
         platform_order_id,
         platform_order_number,
         parsed_items, final_amount,
         intake_status, order_id
  into v_intake
  from catchmenu_integrations.delivery_intake_log
  where id = p_intake_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intake.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'delivery_order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'accept_delivery_order'
    );
  end if;

  if v_intake.intake_status <> 'RECEIVED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'accept_delivery_order'
    );
  end if;

  if v_intake.order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_approval_required',
      'intake_id', p_intake_id
    );
  end if;

  select pl.id
  into v_approval_ledger_id
  from catchmenu_payment.payment_ledger pl
  where pl.tenant_id = p_tenant_id
    and pl.store_id = p_store_id
    and pl.order_id = v_intake.order_id
    and pl.ledger_entry_type = 'APPROVAL'
    and pl.ledger_status = 'APPROVED'
  order by pl.approved_at, pl.id
  limit 1
  for share;

  if v_approval_ledger_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_approval_required',
      'intake_id', p_intake_id,
      'order_id', v_intake.order_id
    );
  end if;

  select o.id, o.session_id, o.order_number,
         o.business_day, o.business_timezone
  into v_order_id, v_session_id, v_order_number,
       v_business_day, v_timezone
  from catchmenu_pos.orders o
  where o.id = v_intake.order_id
    and o.tenant_id = p_tenant_id
    and o.store_id = p_store_id;

  if v_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'delivery_order_not_found',
      'intake_id', p_intake_id
    );
  end if;

  -- The intake must be pre-bound to an existing approved order. Build its
  -- item/ticket records only after the server-side approval lookup succeeds.
  for v_item in
    select * from jsonb_array_elements(
      v_intake.parsed_items
    )
  loop
    -- 메뉴 매칭 시도 (메뉴명 기반)
    select id into v_menu_id
    from catchmenu_pos.menus
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and menu_name = v_item->>'menu_name'
      and is_active = true
    limit 1;

    insert into catchmenu_pos.order_items (
      tenant_id, store_id, order_id, menu_id,
      menu_code_snapshot, menu_name_snapshot,
      unit_price_snapshot, quantity, item_amount,
      selected_options, kitchen_zone_snapshot,
      is_kds_required_snapshot
    ) values (
      p_tenant_id, p_store_id, v_order_id, v_menu_id,
      coalesce(v_item->>'menu_code', v_menu_id::text),
      v_item->>'menu_name',
      (v_item->>'unit_price')::int,
      (v_item->>'quantity')::int,
      (v_item->>'subtotal')::int,
      coalesce(v_item->'options', '[]'::jsonb),
      'MAIN', true
    )
    returning id into v_order_item_id;

    v_ticket_count := v_ticket_count + 1;

    -- KDS 티켓 생성 (HOLD 상태 = 특허2)
    -- 배달 주문 = 결제 이미 완료
    -- → 즉시 COMMITTED 처리
    insert into catchmenu_kds.kds_tickets (
      tenant_id, store_id,
      order_id, order_item_id, session_id,
      payment_ledger_id, ticket_number,
      menu_name_snapshot,
      quantity_snapshot,
      kitchen_zone,
      kds_status,
      conditions_met,
      ticket_created_at,
      committed_at,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_order_item_id, v_session_id,
      v_approval_ledger_id,
      v_order_number || '-' || lpad(v_ticket_count::text, 2, '0'),
      v_item->>'menu_name',
      (v_item->>'quantity')::int,
      'MAIN',
      -- 배달 = 선결제 완료 → COMMITTED
      'COMMITTED',
      jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'payment_ledger_id', v_approval_ledger_id,
        'delivery_pre_paid', true,
        'platform', v_intake.platform_code
      ),
      now(), now(),
      v_business_day, v_timezone
    )
    returning id into v_kds_ticket_id;
  end loop;

  -- 수신 로그 업데이트
  update catchmenu_integrations.delivery_intake_log
  set
    order_id = v_order_id,
    intake_status = 'ACCEPTED',
    accepted_at = now(),
    updated_at = now()
  where id = p_intake_id;

  -- Edge Function에 배달앱 수락 응답 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'delivery_order_accept_requested',
    p_payload := jsonb_build_object(
      'intake_id', p_intake_id,
      'order_id', v_order_id,
      'platform_code', v_intake.platform_code,
      'platform_order_id',
        v_intake.platform_order_id,
      'estimated_minutes', p_estimated_minutes,
      'correlation_id', p_correlation_id
    )
  );

  -- KDS Realtime 브로드캐스트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'KDS_TICKETS',
    p_event_type := 'kds_ticket_created',
    p_payload := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'order_type', 'DELIVERY',
      'platform_code', v_intake.platform_code,
      'kds_status', 'COMMITTED',
      'items_count',
        jsonb_array_length(v_intake.parsed_items)
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'delivery', 'delivery_order_accepted', 1,
    'delivery_intake', p_intake_id,
    'RECEIVED', 'ACCEPTED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'platform_code', v_intake.platform_code,
      'order_id', v_order_id,
      'order_number', v_order_number,
      'estimated_minutes', p_estimated_minutes,
      'kds_status', 'COMMITTED'
    ),
    v_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'delivery_order_accepted',
    p_data := jsonb_build_object(
      'intake_id', p_intake_id,
      'order_id', v_order_id,
      'order_number', v_order_number,
      'platform_code', v_intake.platform_code,
      'estimated_minutes', p_estimated_minutes,
      'kds_status', 'COMMITTED',
      'kds_note',
        '배달 선결제 → COMMITTED 즉시 처리',
      'items_count',
        jsonb_array_length(v_intake.parsed_items)
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

COMMIT;
