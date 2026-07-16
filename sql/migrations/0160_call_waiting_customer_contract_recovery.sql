-- ============================================================================
-- Migration: 0160_call_waiting_customer_contract_recovery.sql
-- Purpose:
--   Recover the waiting-call contract by replacing phantom order_sessions
--   columns with session_events-derived call history, introducing an internal
--   shared waiting-call helper, adding an automatic next-customer call RPC,
--   dropping the legacy call_next_waiting() overload, and marking
--   no_show_auto_expire_minutes as deprecated by COMMENT only.
--
-- Depends on:
--   0159_fix_payment_intent_idempotency_key_race.sql
--
-- Creates/Changes:
--   - Creates catchmenu_pos._record_waiting_call(...)
--   - Replaces catchmenu_pos.call_waiting_customer(...)
--   - Creates catchmenu_pos.call_next_waiting_customer(...)
--   - Drops legacy catchmenu_pos.call_next_waiting(uuid, uuid, text, uuid, uuid, text)
--   - Comments catchmenu_store.store_settings.no_show_auto_expire_minutes as deprecated
--
-- Background:
--   600640_call_waiting_customer_contract_recovery confirmed that called_at,
--   call_count, table_number, and pre_order_amount must not be stored on
--   order_sessions. call history is recorded in session_events, call_count is
--   derived from session_events, table_number is request/response/event payload
--   only, and pre_order_amount is sourced from linked orders.final_amount.
--
-- Human decision:
--   Approved in 600644_ChangeContract.md §7/§8 on 2026-07-16.
--
-- Non-goals:
--   - Do not modify 0118 cron behavior.
--   - Do not modify confirm_arrival().
--   - Do not add new schema columns.
--   - Do not drop no_show_auto_expire_minutes.
-- ============================================================================

create or replace function catchmenu_pos._record_waiting_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_from_status text,
  p_wait_number int,
  p_guest_locale text,
  p_phone_hash text,
  p_customer_id uuid,
  p_has_pre_order boolean,
  p_pre_order_amount int,
  p_table_number text,
  p_expires_at timestamptz,
  p_actor_type text,
  p_actor_id uuid,
  p_locale text,
  p_correlation_id text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, catchmenu_ledger
as $$
declare
  v_call_count int;
begin
  -- 세션 상태 전이 + 만료시각 스냅샷 저장 (§4)
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    expires_at = p_expires_at,
    updated_at = now()
  where id = p_session_id;

  -- session_events (§1.1)
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'customer_called',
    p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number,
      'table_suggestion', p_table_number,
      'expires_at', p_expires_at,
      'has_pre_order', p_has_pre_order
    ),
    p_correlation_id, now()
  );

  -- call_count 파생 (§1.2)
  select count(*) into v_call_count
  from catchmenu_pos.session_events
  where session_id = p_session_id and event_type = 'customer_called';

  -- 알림 3종 (0115:495-532 원문 로직 그대로)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE', p_event_type := 'waiting_called',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_number', p_table_number, 'guest_locale', p_guest_locale,
      'called_at', now(),
      'message', catchmenu_common.get_message(
        'waiting_called_alert', p_guest_locale,
        jsonb_build_object('wait_number', p_wait_number)
      )
    )
  );
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY', p_event_type := 'WAITING_CALL',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'display_number', p_wait_number,
      'table_number', p_table_number, 'queue_type', 'WAITING_CALL',
      'guest_locale', p_guest_locale
    )
  );
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS', p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash, 'customer_id', p_customer_id,
        'notification_type', 'WAITING_CALLED', 'wait_number', p_wait_number,
        'table_number', p_table_number, 'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1, 두 원본 함수 모두 이미 쓰던 패턴)
  insert into catchmenu_ledger.events (
    tenant_id, store_id, event_domain, event_type, event_version,
    subject_type, subject_id, from_state, to_state,
    caused_by_type, caused_by_id, event_payload, session_id,
    correlation_id, business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id, 'session', 'customer_called', 1,
    'order_session', p_session_id, p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number, 'has_pre_order', p_has_pre_order,
      'pre_order_amount', p_pre_order_amount
    ),
    p_session_id, p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_called_alert',
    p_data := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_suggestion', p_table_number, 'guest_locale', p_guest_locale,
      'has_pre_order', p_has_pre_order, 'pre_order_amount', p_pre_order_amount,
      'call_count', v_call_count, 'expires_at', p_expires_at,
      'did_called', true, 'push_sent', p_phone_hash is not null
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object('wait_number', p_wait_number),
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.call_waiting_customer(
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
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_expire_at timestamptz;
begin
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
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
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 상태 게이트: WAITING/ARRIVAL_PENDING 둘 다 허용 (재호출 지원, 0115:467-481 원문 유지 —
  -- 900101:291 "✓ 재호출"과 정합. 0050의 WAITING-only보다 이쪽이 설계 문서와 일치.
  if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
    return catchmenu_common.build_error_response(
      p_error_key := case v_session.session_status
        when 'SEATED' then 'waiting_already_seated'
        else 'waiting_not_callable'
      end,
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 만료시각 스냅샷 계산 (§4 — wait_call_expire_minutes 채택, 매장별 설정)
  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := v_session.session_status,
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := p_table_number, p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.call_next_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
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
  v_expire_at timestamptz;
begin
  -- 자동 선택 (0050:194-211 원문 로직 그대로 — WAITING만 대상, 재호출 개념 없음)
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.session_status = 'WAITING'
  order by
    coalesce(os.queue_position, os.wait_number) asc nulls last,
    os.session_started_at asc
  limit 1
  for update of os skip locked;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'no_waiting_session_found',
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_next_waiting_customer'
    );
  end if;

  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := 'WAITING',
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := null,  -- 자동 호출 경로는 p_table_number 파라미터 자체가 없음(§1.3)
    p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;

drop function if exists catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
);

comment on column catchmenu_store.store_settings.no_show_auto_expire_minutes
  is 'DEPRECATED (600640): wait_call_expire_minutes로 대체됨. 사용처 없음. 별도 정리 워크패킷에서 DROP 검토.';
