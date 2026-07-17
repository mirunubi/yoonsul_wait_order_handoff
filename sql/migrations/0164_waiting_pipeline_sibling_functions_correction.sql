-- 0164_waiting_pipeline_sibling_functions_correction.sql
--
-- Purpose:
--   Correct the remaining four waiting-pipeline sibling functions from 0115:
--   - confirm_arrival()
--   - get_waiting_status()
--   - get_waiting_admin_view()
--   - cancel_waiting()
--
-- Background:
--   docs/600000_implementation_lifecycle/600600_waiting_order_session/
--   600660_waiting_pipeline_sibling_functions_correction/
--   600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md
--   600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md
--   600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md
--   600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md
--
-- Human decision:
--   600664_ChangeContract §9 all six items checked; §10 APPROVED
--   (2026-07-18).
--
-- Depends on:
--   0163_seat_waiting_customer_facade_correction.sql
--
-- Statement order:
--   1. message_catalog / error_codes INSERT block
--   2. confirm_arrival() CREATE OR REPLACE
--   3. get_waiting_status() CREATE OR REPLACE
--   4. get_waiting_admin_view() CREATE OR REPLACE
--   5. cancel_waiting() CREATE OR REPLACE
--
-- GRANT/REVOKE:
--   No new GRANT/REVOKE statements are needed. All four public signatures are
--   unchanged from 0115, so existing EXECUTE grants remain in effect.
--
-- Non-goals:
--   - Do not modify 0115 source text.
--   - Do not modify mark_session_arrived() / 0025.
--   - Do not modify seat_waiting_customer() / 0163.
--   - Do not add a cancel_waiting() state guard or table-release logic.
--   - Do not add schema columns.

insert into catchmenu_common.message_catalog (
  message_key,
  locale,
  message_text
) values
  ('waiting_confirm_arrival_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_confirm_arrival_failed', 'en', 'A temporary error occurred. Please try again'),
  ('waiting_cancel_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_cancel_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code,
  error_key,
  error_domain,
  error_category,
  http_status,
  severity
) values
  (7078, 'waiting_confirm_arrival_failed',
    'ORDER', 'TECHNICAL', 500, 'ERROR'),
  (7079, 'waiting_cancel_operation_failed',
    'ORDER', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;

create or replace function catchmenu_pos.confirm_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_arrival_result jsonb;
begin
  select os.id, os.wait_number, os.session_status,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival'
    );
  end if;

  v_arrival_result := catchmenu_pos.mark_session_arrived(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_arrival_result->>'success')::boolean, false) then
    return v_arrival_result;
  end if;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_arrival_confirmed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount
    )
  );

  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'arrival_confirmed', 1,
    'order_session', p_session_id,
    v_session.session_status, 'ARRIVAL_PENDING',
    'CUSTOMER', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'arrival_confirmed',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then 'PROCEED_TO_PAYMENT'
        else 'WAIT_FOR_SEATING'
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'confirm_arrival_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'CUSTOMER',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_confirm_arrival_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

create or replace function catchmenu_pos.get_waiting_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_session record;
  v_queue_position int;
  v_est_wait_minutes int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.session_type, os.guest_count, os.guest_locale,
         os.pre_order_created_at,
         o.final_amount as pre_order_amount,
         dt.table_code as table_number,
         os.session_started_at,
         call_info.called_at,
         os.arrived_at,
         os.seated_at
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_waiting_status'
    );
  end if;

  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING')
    and wait_number < v_session.wait_number;

  v_est_wait_minutes := v_queue_position * 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'session_status', v_session.session_status,
      'session_type', v_session.session_type,
      'guest_count', v_session.guest_count,
      'table_number', v_session.table_number,
      'queue_position', v_queue_position,
      'est_wait_minutes', v_est_wait_minutes,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'timestamps', jsonb_build_object(
        'registered_at', v_session.session_started_at,
        'called_at', v_session.called_at,
        'arrival_at', v_session.arrived_at,
        'seated_at', v_session.seated_at
      ),
      'status_messages', jsonb_build_object(
        'position', catchmenu_common.get_message(
          'waiting_current_position',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('position', v_queue_position)
        ),
        'est_time', catchmenu_common.get_message(
          'waiting_est_time',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('minutes', v_est_wait_minutes)
        )
      )
    ),
    p_locale := p_locale
  );
end;
$$;

create or replace function catchmenu_pos.get_waiting_admin_view(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_business_day date;
  v_waiting_list jsonb;
  v_today_stats jsonb;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'queue_position', os.queue_position,
        'session_status', os.session_status,
        'session_type', os.session_type,
        'guest_count', os.guest_count,
        'guest_locale', os.guest_locale,
        'table_number', dt.table_code,
        'has_pre_order', os.pre_order_created_at is not null,
        'pre_order_amount', o.final_amount,
        'waited_minutes', extract(epoch from (now() - os.session_started_at))::int / 60,
        'called_at', call_info.called_at,
        'call_count', coalesce(call_info.call_count, 0),
        'is_foreign', os.guest_locale <> 'ko',
        'actions', jsonb_build_array(
          case when os.session_status = 'WAITING' then 'CALL' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'SEAT' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'NO_SHOW' else null end,
          'CANCEL'
        )
      )
      order by os.queue_position asc nulls last, os.wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select count(*) as call_count, max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day
    and os.session_status in ('WAITING', 'ARRIVAL_PENDING');

  select jsonb_build_object(
    'total_registered', count(*),
    'completed', count(*) filter (where os.session_status = 'COMPLETED'),
    'cancelled', count(*) filter (where os.session_status = 'CANCELLED'),
    'no_show', count(*) filter (where os.session_status = 'NO_SHOW'),
    'current_waiting', jsonb_array_length(v_waiting_list),
    'pre_order_count', count(*) filter (where os.pre_order_created_at is not null),
    'total_pre_order_amount', coalesce(
      sum(o.final_amount) filter (where os.pre_order_created_at is not null), 0
    ),
    'foreign_count', count(*) filter (where os.guest_locale <> 'ko'),
    'avg_wait_minutes', coalesce(
      avg(
        extract(epoch from (coalesce(os.seated_at, now()) - os.session_started_at)) / 60
      )::int, 0
    )
  )
  into v_today_stats
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'current_waiting', jsonb_array_length(v_waiting_list),
      'waiting_list', v_waiting_list,
      'today_stats', v_today_stats,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;

create or replace function catchmenu_pos.cancel_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text default null,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.guest_locale, os.pre_order_created_at,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting'
    );
  end if;

  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  if v_session.pre_order_created_at is not null then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'cancelled_by', p_actor_type
    )
  );

  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_cancelled',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'cancel_waiting_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'cancel_reason', p_cancel_reason
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_cancel_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
