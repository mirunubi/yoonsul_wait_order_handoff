-- 0100_create_staff_app_bootstrap_rpc.sql
-- Purpose: Staff app bootstrap and store operation
--          startup pipeline.
--          직원 앱 시작 시 단일 RPC로 전체 컨텍스트 로드.
--          매장 운영 시작/마감 파이프라인.
--          KDS 초기화 + 대기 초기화.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0099_create_realtime_pipeline_rpc.sql
-- Creates:
--   function catchmenu_common.bootstrap_staff_app(...)
--   function catchmenu_store.open_store(...)
--   function catchmenu_store.close_store(...)
--   function catchmenu_store.get_store_dashboard(...)
--   function catchmenu_store.change_store_mode(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('staff_app_bootstrapped', 'ko',
  '직원 앱이 시작되었습니다'),
('staff_app_bootstrapped', 'en',
  'Staff app initialized'),
('store_opened', 'ko',
  '매장 운영이 시작되었습니다'),
('store_opened', 'en',
  'Store opened'),
('store_closed', 'ko',
  '매장 마감이 완료되었습니다'),
('store_closed_msg', 'en',
  'Store closed'),
('store_dashboard_loaded', 'ko',
  '매장 대시보드가 로드되었습니다'),
('store_dashboard_loaded', 'en',
  'Store dashboard loaded'),
('store_mode_updated', 'ko',
  '매장 모드가 변경되었습니다'),
('store_mode_updated', 'en',
  'Store mode updated'),
('store_already_open', 'ko',
  '이미 운영 중인 매장입니다'),
('store_already_open', 'en',
  'Store is already open'),
('store_already_closed', 'ko',
  '이미 마감된 매장입니다'),
('store_already_closed', 'en',
  'Store is already closed'),
('new_customer', 'ko', '새 고객'),
('new_customer', 'en', 'New Customer'),
('new_customer', 'zh', '新客户'),
('new_customer', 'ja', '新規お客様'),
('new_customer', 'vi', 'Khách mới'),
('new_customer', 'th', 'ลูกค้าใหม่')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7020, 'store_already_open',
  'STORE', 'CONFLICT', 409, 'INFO'),
(7021, 'store_already_closed',
  'STORE', 'CONFLICT', 409, 'INFO'),
(7022, 'invalid_store_mode',
  'STORE', 'INVALID_INPUT', 400, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
-- 0070's original bootstrap_staff_app used a different parameter
-- order/defaults (p_device_id before p_staff_id, no p_device_type).
-- This file supersedes it with a more complete, dedicated
-- implementation; no already-applied code depends on the old
-- signature, so the old function is dropped first.
drop function if exists catchmenu_common.bootstrap_staff_app(
  uuid, uuid, uuid, uuid, text, text, text
);

create or replace function
  catchmenu_common.bootstrap_staff_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_device_id uuid,
  p_device_type text,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment
as $$
declare
  v_store record;
  v_staff record;
  v_store_settings record;
  v_plan record;
  v_kds_state jsonb;
  v_waiting_state jsonb;
  v_alert_feed jsonb;
  v_realtime_config jsonb;
  v_today_summary jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- 매장 정보
  select id, store_name, store_status,
         timezone, store_type
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_staff_app'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 직원 정보
  select id, staff_name, staff_role,
         staff_status, allowed_features
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 매장 설정
  select store_mode, waiting_enabled,
         pre_order_enabled,
         kds_capacity_threshold_total,
         max_waiting_count,
         did_refresh_interval_seconds
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 플랜 정보
  select plan_tier, plan_status,
         enabled_features
  into v_plan
  from catchmenu_common.tenant_plan_configs
  where tenant_id = p_tenant_id;

  -- KDS 현황
  v_kds_state :=
    catchmenu_kds.get_kds_realtime_state(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := p_locale
    );

  -- 대기 현황
  v_waiting_state :=
    catchmenu_pos.get_waiting_realtime_state(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := p_locale
    );

  -- 직원 알림 피드
  v_alert_feed :=
    catchmenu_common.get_staff_alert_feed(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := p_locale
    );

  -- Realtime 설정
  v_realtime_config :=
    catchmenu_common.get_realtime_config(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_device_type := p_device_type,
      p_locale := p_locale
    );

  -- 오늘 요약
  select jsonb_build_object(
    'total_orders', count(*),
    'completed_orders', count(*) filter (
      where order_status = 'COMPLETED'
    ),
    'total_revenue', coalesce(
      sum(pl.net_amount), 0
    ),
    'takeout_orders', count(*) filter (
      where o.order_type = 'TAKEOUT'
    ),
    'delivery_orders', count(*) filter (
      where o.order_type = 'DELIVERY'
    )
  )
  into v_today_summary
  from catchmenu_pos.orders o
  left join catchmenu_payment.payment_ledger pl
    on pl.order_id = o.id
    and pl.ledger_status = 'APPROVED'
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.business_day = v_business_day;

  -- 디바이스 last_seen 업데이트
  update catchmenu_store.device_registry
  set
    last_seen_at = now(),
    updated_at = now()
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- ledger event
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
    'store', 'staff_app_bootstrapped', 1,
    'staff', p_staff_id,
    null, 'ACTIVE',
    'STAFF', p_staff_id,
    jsonb_build_object(
      'device_id', p_device_id,
      'device_type', p_device_type,
      'store_mode',
        v_store_settings.store_mode
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_app_bootstrapped',
    p_data := jsonb_build_object(

      -- 매장 컨텍스트
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_status', v_store.store_status,
        'store_type', v_store.store_type,
        'timezone', v_store.timezone,
        'business_day', v_business_day
      ),

      -- 설정
      'settings', jsonb_build_object(
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        ),
        'pre_order_enabled', coalesce(
          v_store_settings.pre_order_enabled, true
        ),
        'kds_threshold', coalesce(
          v_store_settings
            .kds_capacity_threshold_total, 30
        ),
        'max_waiting_count', coalesce(
          v_store_settings.max_waiting_count, 30
        )
      ),

      -- 직원
      'staff', case
        when v_staff.id is not null
        then jsonb_build_object(
          'id', v_staff.id,
          'staff_name', v_staff.staff_name,
          'staff_role', v_staff.staff_role,
          'allowed_features',
            v_staff.allowed_features
        )
        else null
      end,

      -- 플랜
      'plan', jsonb_build_object(
        'plan_tier', v_plan.plan_tier,
        'plan_status', v_plan.plan_status,
        'enabled_features',
          v_plan.enabled_features
      ),

      -- KDS 현황
      'kds', v_kds_state->'data',

      -- 대기 현황
      'waiting', v_waiting_state->'data',

      -- 알림 피드
      'alerts', v_alert_feed->'data',

      -- Realtime 설정
      'realtime', v_realtime_config->'data',

      -- 오늘 요약
      'today', v_today_summary,

      -- 메타
      'device_id', p_device_id,
      'device_type', p_device_type,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.open_store(
  p_tenant_id uuid,
  p_store_id uuid,
  p_opened_by uuid,
  p_opening_memo text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select store_mode, waiting_enabled
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if coalesce(v_settings.store_mode, 'CLOSED')
    = 'NORMAL'
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_already_open',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'open_store'
    );
  end if;

  -- 매장 모드 NORMAL로 변경
  update catchmenu_store.store_settings
  set
    store_mode = 'NORMAL',
    last_opened_at = now(),
    opened_by = p_opened_by,
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- Realtime 브로드캐스트
  perform catchmenu_common.broadcast_store_event(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_event_type := 'store_mode_changed',
    p_event_data := jsonb_build_object(
      'store_mode', 'NORMAL',
      'opened_by', p_opened_by,
      'opened_at', now(),
      'message',
        catchmenu_common.get_message(
          'store_opened', p_locale, null
        )
    ),
    p_channel_type := 'STORE_MODE',
    p_locale := p_locale
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'store',
    p_audit_type := 'store_opened',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_opened_by,
    p_subject_type := 'store',
    p_subject_id := p_store_id,
    p_decision := 'OPENED',
    p_decision_reason := p_opening_memo,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
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
    'store', 'store_opened', 1,
    'store', p_store_id,
    'CLOSED', 'NORMAL',
    'STAFF', p_opened_by,
    jsonb_build_object(
      'opening_memo', p_opening_memo,
      'audit_id', v_audit_id
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'store_opened',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'store_mode', 'NORMAL',
      'opened_at', now(),
      'opened_by', p_opened_by,
      'business_day', v_business_day,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.close_store(
  p_tenant_id uuid,
  p_store_id uuid,
  p_closed_by uuid,
  p_closing_memo text default null,
  p_force boolean default false,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_active_orders int;
  v_active_waiting int;
  v_active_kds int;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select store_mode
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if coalesce(v_settings.store_mode, 'NORMAL')
    = 'CLOSED'
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_already_closed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'close_store'
    );
  end if;

  -- 미완료 주문 확인
  select count(*) into v_active_orders
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and order_status in (
      'CONFIRMED', 'COOKING', 'READY'
    );

  -- 대기 중 고객 확인
  select count(*) into v_active_waiting
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    );

  -- 조리 중 KDS 확인
  select count(*) into v_active_kds
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and kds_status in (
      'COMMITTED', 'COOKING'
    );

  -- 강제 마감이 아닌데 미완료 항목 존재
  if not p_force and (
    v_active_orders > 0
    or v_active_waiting > 0
    or v_active_kds > 0
  ) then
    return catchmenu_common.build_success_response(
      p_message_key := 'store_already_open',
      p_data := jsonb_build_object(
        'warning', true,
        'active_orders', v_active_orders,
        'active_waiting', v_active_waiting,
        'active_kds', v_active_kds,
        'message',
          catchmenu_common.get_message(
            'store_already_open',
            p_locale, null
          ),
        'suggestion',
          'use p_force=true to force close'
      ),
      p_locale := p_locale
    );
  end if;

  -- 매장 CLOSED 처리
  update catchmenu_store.store_settings
  set
    store_mode = 'CLOSED',
    last_closed_at = now(),
    closed_by = p_closed_by,
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 강제 마감 시 미완료 처리
  if p_force then
    -- 미완료 대기 세션 EXPIRED 처리
    update catchmenu_pos.order_sessions
    set
      session_status = 'EXPIRED',
      updated_at = now()
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and session_status in (
        'WAITING', 'ARRIVAL_PENDING'
      );

    -- 조리 중 KDS 강제 종료
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and kds_status in (
        'HOLD', 'COMMITTED', 'COOKING'
      );
  end if;

  -- Realtime 브로드캐스트
  perform catchmenu_common.broadcast_store_event(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_event_type := 'store_mode_changed',
    p_event_data := jsonb_build_object(
      'store_mode', 'CLOSED',
      'closed_by', p_closed_by,
      'closed_at', now(),
      'was_forced', p_force,
      'message',
        catchmenu_common.get_message(
          'store_closed_msg', p_locale, null
        )
    ),
    p_channel_type := 'STORE_MODE',
    p_locale := p_locale
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'store',
    p_audit_type := 'store_closed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_closed_by,
    p_subject_type := 'store',
    p_subject_id := p_store_id,
    p_decision := 'CLOSED',
    p_decision_reason := p_closing_memo,
    p_decision_payload := jsonb_build_object(
      'was_forced', p_force,
      'active_orders_at_close',
        v_active_orders,
      'active_waiting_at_close',
        v_active_waiting,
      'active_kds_at_close', v_active_kds
    ),
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
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
    'store', 'store_closed', 1,
    'store', p_store_id,
    v_settings.store_mode, 'CLOSED',
    'STAFF', p_closed_by,
    jsonb_build_object(
      'closing_memo', p_closing_memo,
      'was_forced', p_force,
      'active_orders', v_active_orders,
      'active_waiting', v_active_waiting,
      'audit_id', v_audit_id
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'store_closed',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'store_mode', 'CLOSED',
      'closed_at', now(),
      'closed_by', p_closed_by,
      'was_forced', p_force,
      'summary', jsonb_build_object(
        'active_orders_closed',
          v_active_orders,
        'waiting_expired', v_active_waiting,
        'kds_cancelled', v_active_kds
      ),
      'business_day', v_business_day,
      'audit_id', v_audit_id,
      'next_step',
        'run_layer2_reconciliation() 실행 권장'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.change_store_mode(
  p_tenant_id uuid,
  p_store_id uuid,
  p_new_mode text,
  p_changed_by uuid,
  p_reason text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_old_mode text;
  v_business_day date;
  v_timezone text;
begin
  if p_new_mode not in (
    'NORMAL', 'BUSY', 'CLOSING',
    'CLOSED', 'EMERGENCY', 'HOLIDAY'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_store_mode',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'store_mode',
        'value', p_new_mode,
        'allowed', 'NORMAL/BUSY/CLOSING/'
          || 'CLOSED/EMERGENCY/HOLIDAY'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'change_store_mode'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 현재 모드 조회 + 업데이트
  update catchmenu_store.store_settings
  set
    store_mode = p_new_mode,
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  returning
    lag(store_mode) over (order by updated_at)
  into v_old_mode;

  -- Realtime 브로드캐스트
  perform catchmenu_common.broadcast_store_event(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_event_type := 'store_mode_changed',
    p_event_data := jsonb_build_object(
      'old_mode', v_old_mode,
      'new_mode', p_new_mode,
      'changed_by', p_changed_by,
      'reason', p_reason,
      'message',
        catchmenu_common.get_message(
          'store_mode_updated', p_locale,
          jsonb_build_object(
            'mode', p_new_mode
          )
        )
    ),
    p_channel_type := 'STORE_MODE',
    p_locale := p_locale
  );

  -- ledger event
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
    'store', 'store_mode_changed', 1,
    'store', p_store_id,
    v_old_mode, p_new_mode,
    'STAFF', p_changed_by,
    jsonb_build_object(
      'reason', p_reason,
      'auto_effects', case p_new_mode
        when 'EMERGENCY' then
          'delivery_auto_reject=true'
        when 'CLOSED' then
          'waiting_disabled, order_disabled'
        else 'none'
      end
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'store_mode_updated',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'old_mode', v_old_mode,
      'new_mode', p_new_mode,
      'changed_at', now(),
      'effects', case p_new_mode
        when 'EMERGENCY' then
          jsonb_build_object(
            'delivery_auto_reject', true,
            'new_orders_blocked', true
          )
        when 'BUSY' then
          jsonb_build_object(
            'delivery_auto_reject', true,
            'new_orders_blocked', false,
            'warning_displayed', true
          )
        when 'CLOSED' then
          jsonb_build_object(
            'all_orders_blocked', true,
            'waiting_disabled', true
          )
        when 'HOLIDAY' then
          jsonb_build_object(
            'delivery_auto_reject', true,
            'all_orders_blocked', true
          )
        else jsonb_build_object(
          'normal_operation', true
        )
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.get_store_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_settings record;
  v_business_day date;
  v_timezone text;
  v_hourly_revenue jsonb;
  v_menu_ranking jsonb;
  v_staff_performance jsonb;
  v_payment_summary jsonb;
  v_kds_summary jsonb;
  v_waiting_summary jsonb;
begin
  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_store_dashboard'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select store_mode, waiting_enabled,
         kds_capacity_threshold_total
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 시간대별 매출
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'hour', hour,
        'order_count', order_count,
        'revenue', revenue
      )
      order by hour
    ),
    '[]'::jsonb
  )
  into v_hourly_revenue
  from (
    select
      extract(hour from
        timezone(
          coalesce(v_timezone, 'Asia/Seoul'),
          o.ordered_at
        )
      )::int as hour,
      count(*) as order_count,
      coalesce(sum(pl.net_amount), 0) as revenue
    from catchmenu_pos.orders o
    left join catchmenu_payment.payment_ledger pl
      on pl.order_id = o.id
      and pl.ledger_status = 'APPROVED'
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_business_day
      and o.order_status = 'COMPLETED'
    group by hour
  ) h;

  -- 메뉴 판매 순위 (오늘 top 5)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_name', menu_name_snapshot,
        'quantity', total_qty,
        'revenue', total_revenue
      )
      order by total_qty desc
    ),
    '[]'::jsonb
  )
  into v_menu_ranking
  from (
    select
      oi.menu_name_snapshot,
      sum(oi.quantity) as total_qty,
      sum(oi.subtotal) as total_revenue
    from catchmenu_pos.order_items oi
    join catchmenu_pos.orders o
      on o.id = oi.order_id
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_business_day
      and o.order_status = 'COMPLETED'
    group by oi.menu_name_snapshot
    order by total_qty desc
    limit 5
  ) m;

  -- 결제 요약
  select jsonb_build_object(
    'total_approved', coalesce(
      sum(approved_amount) filter (
        where ledger_status = 'APPROVED'
      ), 0
    ),
    'total_net', coalesce(
      sum(net_amount) filter (
        where ledger_status = 'APPROVED'
      ), 0
    ),
    'total_fee', coalesce(
      sum(fee_amount) filter (
        where ledger_status = 'APPROVED'
      ), 0
    ),
    'total_refunded', coalesce(
      abs(sum(approved_amount)) filter (
        where ledger_status = 'REFUNDED'
      ), 0
    ),
    'by_method', (
      select coalesce(
        jsonb_object_agg(
          payment_method,
          cnt
        ),
        '{}'::jsonb
      )
      from (
        select payment_method, count(*)::int as cnt
        from catchmenu_payment.payment_ledger
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and business_day = v_business_day
          and ledger_status = 'APPROVED'
        group by payment_method
      ) pm
    )
  )
  into v_payment_summary
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- KDS 요약
  select jsonb_build_object(
    'total_tickets', count(*),
    'completed', count(*) filter (
      where kds_status in (
        'SERVED', 'COMPLETED'
      )
    ),
    'active', count(*) filter (
      where kds_status in (
        'COMMITTED', 'COOKING', 'READY'
      )
    ),
    'late', count(*) filter (
      where is_late = true
    ),
    'avg_cook_seconds', coalesce(
      avg(
        extract(epoch from (
          served_at - cooking_started_at
        ))
      ) filter (
        where served_at is not null
          and cooking_started_at is not null
      )::int, 0
    )
  )
  into v_kds_summary
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 대기 요약
  select jsonb_build_object(
    'total_today', count(*),
    'completed', count(*) filter (
      where session_status = 'COMPLETED'
    ),
    'current_waiting', count(*) filter (
      where session_status in (
        'WAITING', 'ARRIVAL_PENDING'
      )
    ),
    'no_show', count(*) filter (
      where session_status = 'NO_SHOW'
    ),
    'avg_wait_minutes', coalesce(
      avg(
        extract(epoch from (
          coalesce(
            arrival_confirmed_at, now()
          ) - session_started_at
        )) / 60
      ) filter (
        where arrival_confirmed_at is not null
      )::int, 0
    )
  )
  into v_waiting_summary
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_type in (
      'WAITING', 'PRE_ORDER'
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'store_dashboard_loaded',
    p_data := jsonb_build_object(
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_mode', coalesce(
          v_settings.store_mode, 'NORMAL'
        ),
        'business_day', v_business_day,
        'timezone', v_timezone
      ),
      'revenue', v_payment_summary,
      'hourly_revenue', v_hourly_revenue,
      'kds', v_kds_summary,
      'waiting', v_waiting_summary,
      'menu_ranking', v_menu_ranking,
      'generated_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.bootstrap_staff_app(
      uuid, uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_staff_app(
      uuid, uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.open_store(
      uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.open_store(
      uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.close_store(
      uuid, uuid, uuid, text, boolean, text, text
    ) from public;
  grant execute on function
    catchmenu_store.close_store(
      uuid, uuid, uuid, text, boolean, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.change_store_mode(
      uuid, uuid, text, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.change_store_mode(
      uuid, uuid, text, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_store_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.get_store_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_common.bootstrap_staff_app(
    uuid, uuid, uuid, uuid, text, text, text
  ) is
  '직원 앱 시작 시 단일 RPC 호출.
   반환 데이터:
   - 매장 정보 + 운영 설정
   - 직원 정보 + 권한
   - 플랜 + 활성 기능
   - KDS 현황 (활성 티켓 전체)
   - 대기 현황 (현재 대기 목록)
   - 직원 알림 피드 (CRITICAL 우선)
   - Realtime 채널 설정
   - 오늘 매출 요약

   Flutter 앱 시작 흐름:
   1. health_check()
   2. get_auth_context() → 세션 확인
   3. bootstrap_staff_app() → 전체 로드
   4. Realtime 채널 구독 시작
   5. 30초 폴링 시작 (백업)

   특허2 표시:
   KDS HOLD 티켓 = 결제 전 (조리 금지 표시).';

comment on function
  catchmenu_store.close_store(
    uuid, uuid, uuid, text, boolean, text, text
  ) is
  '매장 마감 파이프라인.
   p_force = false (기본):
     미완료 주문/대기 있으면 경고 반환.
     직원이 확인 후 재호출.
   p_force = true:
     강제 마감.
     미완료 대기 → EXPIRED.
     조리 중 KDS → CANCELLED.
   마감 후 권장 액션:
   → run_layer2_reconciliation() 호출.
   → get_store_dashboard() 마감 리포트.
   Realtime → 전 디바이스 CLOSED 브로드캐스트.';