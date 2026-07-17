-- 0163_seat_waiting_customer_facade_correction.sql
--
-- Purpose:
--   Rewrite catchmenu_pos.seat_waiting_customer() as a thin facade:
--   - remove phantom order_sessions.table_number/pre_order_amount access,
--   - resolve caller-facing table_number/table_code to canonical table_id,
--   - delegate the core late-binding state transition to
--     catchmenu_pos.bind_table_to_session(),
--   - preserve waiting-pipeline-specific diagnostics, realtime notifications,
--     and waiting/customer_seated ledger event.
--
-- Background:
--   docs/600000_implementation_lifecycle/600600_waiting_order_session/
--   600650_seat_waiting_customer_facade_correction/
--   600651_Overview_Seat_Waiting_Customer_Facade_Correction.md
--   600652_Logic_Seat_Waiting_Customer_Facade_Correction.md
--   600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md
--   600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md
--
-- Human decision:
--   600654_ChangeContract §9 all five items checked; §10 APPROVED
--   (2026-07-18).
--
-- Depends on:
--   0162_create_dining_table_admin_rpc.sql
--
-- Non-goals:
--   - Do not modify bind_table_to_session() / 0025.
--   - Do not modify 0115 source text or sibling waiting functions.
--   - Do not modify _record_waiting_call(), pre_order_while_waiting(),
--     dining_tables schema, or orders schema.

insert into catchmenu_common.message_catalog (
  message_key,
  locale,
  message_text
) values
  ('waiting_table_not_found', 'ko', '해당 테이블 번호를 찾을 수 없습니다'),
  ('waiting_table_not_found', 'en', 'Table number not found'),
  ('waiting_table_number_ambiguous', 'ko', '테이블 번호가 중복되어 특정할 수 없습니다'),
  ('waiting_table_number_ambiguous', 'en', 'Table number matches more than one table'),
  ('waiting_table_inactive', 'ko', '비활성화된 테이블입니다'),
  ('waiting_table_inactive', 'en', 'This table is inactive'),
  ('waiting_table_number_required', 'ko', '테이블 번호는 필수입니다'),
  ('waiting_table_number_required', 'en', 'Table number is required'),
  ('waiting_seat_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_seat_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code,
  error_key,
  error_domain,
  error_category,
  http_status,
  severity
) values
  (7073, 'waiting_table_not_found',
    'ORDER', 'NOT_FOUND', 404, 'WARNING'),
  (7074, 'waiting_table_number_ambiguous',
    'ORDER', 'CONFLICT', 409, 'WARNING'),
  (7075, 'waiting_table_inactive',
    'ORDER', 'CONFLICT', 409, 'WARNING'),
  (7076, 'waiting_table_number_required',
    'ORDER', 'INVALID_INPUT', 400, 'WARNING'),
  (7077, 'waiting_seat_operation_failed',
    'ORDER', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;

create or replace function catchmenu_pos._resolve_dining_table_by_number(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_number text
)
returns table (
  v_table_id uuid,
  v_status text
)
language plpgsql
stable
security definer
set search_path = catchmenu_store
as $$
declare
  v_matches uuid[];
begin
  select array_agg(id) into v_matches
  from catchmenu_store.dining_tables
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and table_code = p_table_number;

  if v_matches is null or array_length(v_matches, 1) = 0 then
    return query select null::uuid, 'NOT_FOUND'::text;
    return;
  end if;

  if array_length(v_matches, 1) > 1 then
    return query select null::uuid, 'AMBIGUOUS'::text;
    return;
  end if;

  if exists (
    select 1
    from catchmenu_store.dining_tables
    where id = v_matches[1]
      and is_active = true
  ) then
    return query select v_matches[1], 'FOUND'::text;
  else
    return query select v_matches[1], 'INACTIVE'::text;
  end if;
end;
$$;

create or replace function
  catchmenu_pos.seat_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_resolved record;
  v_bind_result jsonb;
  v_remaining_queue int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  -- 1. Session lookup. Pre-order amount is read through the 0160
  --    orders LEFT JOIN pattern; order_sessions.pre_order_amount does not exist.
  select os.id,
         os.wait_number,
         os.session_status,
         os.guest_count,
         os.guest_locale,
         os.phone_hash,
         os.customer_id,
         os.session_started_at,
         os.pre_order_created_at,
         os.order_id,
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
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 2. Preserve the original, more specific already-seated error before
  --    delegating to the stricter bind_table_to_session() preconditions.
  if v_session.session_status = 'SEATED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_already_seated',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 3. table_number is required because bind_table_to_session() requires a
  --    concrete table_id and order_sessions.table_id is null before seating.
  if p_table_number is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 4. Resolve table_number/table_code to canonical table_id.
  select * into v_resolved
  from catchmenu_pos._resolve_dining_table_by_number(
    p_tenant_id, p_store_id, p_table_number
  );

  if v_resolved.v_status = 'NOT_FOUND' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'AMBIGUOUS' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_ambiguous',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'INACTIVE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_inactive',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'table_number', p_table_number,
        'table_id', v_resolved.v_table_id
      )
    );
  end if;

  -- 5. Delegate canonical state transition to bind_table_to_session().
  v_bind_result := catchmenu_pos.bind_table_to_session(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_table_id := v_resolved.v_table_id,
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_bind_result->>'success')::boolean, false) then
    -- Return bind_table_to_session()'s original flat error JSON unchanged.
    -- Re-wrapping these keys through build_error_response() is intentionally
    -- forbidden because some bind_table_to_session() keys are not registered
    -- in error_codes and would crash through log_diagnostic().
    return v_bind_result;
  end if;

  -- 6. Waiting-domain side effects preserved from the original facade.
  if v_session.pre_order_created_at is not null then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'KDS',
      p_log_event := 'pre_order_seated_waiting_payment',
      p_message :=
        '사전 주문 착석 완료 - 결제 대기 중. KDS HOLD 유지',
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'session_id', p_session_id,
        'wait_number', v_session.wait_number,
        'pre_order_amount', v_session.pre_order_amount
      )
    );
  end if;

  select count(*) into v_remaining_queue
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING');

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_seated',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null
    )
  );

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number
    )
  );

  -- 7. Waiting-domain ledger event distinct from bind_table_to_session()'s
  --    session/table_bound event.
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
    'waiting', 'customer_seated', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'wait_duration_seconds', extract(
        epoch from (now() - v_session.session_started_at)
      )::int,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'kds_note', case
        when v_session.pre_order_created_at is not null
          then 'KDS HOLD - 결제 후 COMMITTED'
        else 'No pre-order - normal flow'
      end
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_seated',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'guest_count', v_session.guest_count,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'late_binding_completed', true,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then jsonb_build_object(
            'action', 'PROCEED_TO_PAYMENT',
            'note', '결제 완료 후 KDS 자동 COMMITTED',
            'kds_status_now', 'HOLD',
            'kds_status_after_payment', 'COMMITTED'
          )
        else jsonb_build_object(
          'action', 'TAKE_ORDER',
          'note', '일반 주문 접수'
        )
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
      p_audit_type := 'seat_waiting_customer_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'table_number', p_table_number
      )
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_seat_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

revoke all on function catchmenu_pos._resolve_dining_table_by_number(
  uuid, uuid, text
) from public;
