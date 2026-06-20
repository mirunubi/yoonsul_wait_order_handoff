-- 0078_create_delivery_sync_rpc.sql
-- Purpose: Delivery platform order status sync RPCs.
--          Baemin/Yogiyo/Coupang order status polling,
--          delivery status update, auto-rejection rules,
--          delivery performance tracking.
--          3-B차 배달앱/외부 주문 채널 기반.
-- Depends on: 0077_create_multistore_rpc.sql
-- Creates:
--   catchmenu_integrations.delivery_order_sync_log (table)
--   catchmenu_integrations.delivery_platform_rules (table)
--   function catchmenu_integrations.sync_delivery_order_status(...)
--   function catchmenu_integrations.auto_reject_overloaded(...)
--   function catchmenu_integrations.update_delivery_status(...)
--   function catchmenu_integrations.get_delivery_performance(...)
--   function catchmenu_integrations.poll_pending_delivery_orders(...)

-- =============================================
-- delivery_order_sync_log table
-- 배달앱 주문 상태 동기화 로그
-- =============================================
create table if not exists
  catchmenu_integrations.delivery_order_sync_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 배달앱 정보
  platform_code text not null,
  platform_order_id text not null,

  -- 연결된 내부 주문
  order_id uuid,
  session_id uuid,

  -- 동기화 정보
  sync_type text not null,
  sync_direction text not null default 'INBOUND',

  -- 상태
  platform_status_before text,
  platform_status_after text,
  internal_status_before text,
  internal_status_after text,

  -- 결과
  sync_result text not null default 'PENDING',
  sync_error text,
  retry_count int not null default 0,

  -- 원본 페이로드
  raw_payload jsonb,

  business_day date,
  synced_at timestamptz not null default now(),
  created_at timestamptz not null default now(),

  constraint chk_platform_code check (
    platform_code in (
      'BAEMIN', 'YOGIYO', 'COUPANG_EATS',
      'NAVER_ORDER', 'KAKAO_ORDER', 'CUSTOM'
    )
  ),
  constraint chk_sync_type check (
    sync_type in (
      'ORDER_RECEIVED', 'STATUS_UPDATE',
      'ORDER_CANCEL', 'MENU_SYNC',
      'DRIVER_ASSIGNED', 'PICKUP_COMPLETE',
      'DELIVERY_COMPLETE', 'REJECTED'
    )
  ),
  constraint chk_sync_direction check (
    sync_direction in ('INBOUND', 'OUTBOUND')
  ),
  constraint chk_sync_result check (
    sync_result in (
      'PENDING', 'SUCCESS',
      'FAILED', 'IGNORED', 'PARTIAL'
    )
  )
);

create index if not exists idx_delivery_sync_store
  on catchmenu_integrations.delivery_order_sync_log(
    store_id, platform_code, business_day desc
  );
create index if not exists idx_delivery_sync_order
  on catchmenu_integrations.delivery_order_sync_log(
    platform_order_id, platform_code
  );
create index if not exists idx_delivery_sync_result
  on catchmenu_integrations.delivery_order_sync_log(
    sync_result, synced_at desc
  ) where sync_result in ('FAILED', 'PENDING');

alter table
  catchmenu_integrations.delivery_order_sync_log
  enable row level security;
alter table
  catchmenu_integrations.delivery_order_sync_log
  force row level security;

drop policy if exists delivery_sync_log_isolation
  on catchmenu_integrations.delivery_order_sync_log;
create policy delivery_sync_log_isolation
  on catchmenu_integrations.delivery_order_sync_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_integrations.delivery_order_sync_log is
  '배달앱 주문 상태 동기화 로그.
   INBOUND: 배달앱 → 캐치메뉴.
   OUTBOUND: 캐치메뉴 → 배달앱.
   retry_count: 실패 시 재시도 횟수.
   특허1: 모든 외부 주문 = 동기화 증빙 보관.
   3-B차 배달앱 연동 핵심 감사 테이블.';


-- =============================================
-- delivery_platform_rules table
-- 배달앱별 자동 처리 규칙
-- =============================================
create table if not exists
  catchmenu_integrations.delivery_platform_rules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  platform_code text not null,

  -- 자동 수락 규칙
  auto_accept_enabled boolean
    not null default false,
  auto_accept_delay_seconds int
    not null default 30,

  -- 자동 거절 규칙
  auto_reject_if_kds_overloaded boolean
    not null default true,
  kds_overload_threshold int
    not null default 15,
  auto_reject_if_store_closed boolean
    not null default true,
  auto_reject_if_holiday boolean
    not null default true,

  -- 운영 시간 제한
  operating_hours jsonb,

  -- 재시도 정책
  max_sync_retries int not null default 3,
  retry_delay_seconds int not null default 30,

  -- 알림
  notify_on_new_order boolean
    not null default true,
  notify_on_cancel boolean
    not null default true,
  notify_channel text not null default 'APP',

  -- 거절 메시지 (플랫폼 전달용)
  reject_message_overloaded text
    default '주방이 바빠 주문을 받을 수 없습니다',
  reject_message_closed text
    default '현재 영업시간이 아닙니다',

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_delivery_rules unique (
    store_id, platform_code
  ),
  constraint chk_rules_platform check (
    platform_code in (
      'BAEMIN', 'YOGIYO', 'COUPANG_EATS',
      'NAVER_ORDER', 'KAKAO_ORDER', 'CUSTOM'
    )
  )
);

alter table
  catchmenu_integrations.delivery_platform_rules
  enable row level security;
alter table
  catchmenu_integrations.delivery_platform_rules
  force row level security;

drop policy if exists delivery_rules_isolation
  on catchmenu_integrations.delivery_platform_rules;
create policy delivery_rules_isolation
  on catchmenu_integrations.delivery_platform_rules
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_delivery_rules_updated
  on catchmenu_integrations.delivery_platform_rules;
create trigger trg_delivery_rules_updated
  before update on
    catchmenu_integrations.delivery_platform_rules
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_integrations.delivery_platform_rules is
  '배달앱별 자동 처리 규칙.
   auto_accept_enabled: 자동 수락 여부.
   auto_reject_if_kds_overloaded:
     KDS 과부하 시 자동 거절 (기본 true).
   kds_overload_threshold:
     HOLD/COOKING 합계 기준 (기본 15).
   특허2: KDS 수용 상태 기반 Late Binding.
   배달 주문도 KDS 과부하 시 자동 거절.
   3-B차 안전한 외부 주문 채널 핵심 규칙.';


-- seed delivery platform rules
insert into catchmenu_integrations.delivery_platform_rules (
  tenant_id, store_id, platform_code,
  auto_accept_enabled, auto_accept_delay_seconds,
  auto_reject_if_kds_overloaded,
  kds_overload_threshold,
  auto_reject_if_store_closed,
  notify_on_new_order, notify_channel
)
select
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  platform_code,
  false, 30, true, 15, true, true, 'APP'
from (
  values
  ('BAEMIN'),
  ('YOGIYO'),
  ('COUPANG_EATS')
) as platforms(platform_code)
on conflict (store_id, platform_code) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.sync_delivery_order_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_platform_code text,
  p_platform_order_id text,
  p_platform_status text,
  p_raw_payload jsonb default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_log_id uuid;
  v_order record;
  v_session record;
  v_internal_status_before text;
  v_internal_status_after text;
  v_kds_action text;
  v_business_day date;
  v_timezone text;
  v_sync_result text := 'SUCCESS';
  v_error_msg text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 플랫폼 주문 ID로 내부 주문 조회
  select o.id, o.order_status,
         o.session_id, o.order_number
  into v_order
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.provider_order_id = p_platform_order_id
    and o.provider_type =
      'DELIVERY_' || p_platform_code
  order by o.created_at desc
  limit 1;

  v_internal_status_before :=
    coalesce(v_order.order_status, 'NOT_FOUND');

  -- 플랫폼 상태 → 내부 상태 매핑
  v_internal_status_after := case p_platform_status
    -- 배민 공통 상태
    when 'ACCEPTED' then 'CONFIRMED'
    when 'COOKING' then 'COOKING'
    when 'READY' then 'READY'
    when 'PICKED_UP' then 'PICKED_UP'
    when 'DELIVERED' then 'COMPLETED'
    when 'CANCELLED' then 'CANCELLED'
    when 'REJECTED' then 'CANCELLED'
    -- 요기요 상태
    when 'ORDER_CONFIRMED' then 'CONFIRMED'
    when 'FOOD_READY' then 'READY'
    when 'DELIVERED_TO_CUSTOMER' then 'COMPLETED'
    when 'ORDER_CANCELLED' then 'CANCELLED'
    -- 쿠팡이츠 상태
    when 'ACCEPTED_BY_STORE' then 'CONFIRMED'
    when 'FOOD_IN_PREPARATION' then 'COOKING'
    when 'READY_FOR_PICKUP' then 'READY'
    when 'DELIVERY_COMPLETED' then 'COMPLETED'
    when 'CANCELLED_BY_CUSTOMER' then 'CANCELLED'
    when 'CANCELLED_BY_STORE' then 'CANCELLED'
    else null
  end;

  -- sync log 기록
  insert into
    catchmenu_integrations.delivery_order_sync_log (
    tenant_id, store_id,
    platform_code, platform_order_id,
    order_id, session_id,
    sync_type, sync_direction,
    platform_status_before,
    platform_status_after,
    internal_status_before,
    internal_status_after,
    raw_payload,
    business_day, synced_at
  ) values (
    p_tenant_id, p_store_id,
    p_platform_code, p_platform_order_id,
    v_order.id, v_order.session_id,
    'STATUS_UPDATE', 'INBOUND',
    null, p_platform_status,
    v_internal_status_before,
    v_internal_status_after,
    p_raw_payload,
    v_business_day, now()
  )
  returning id into v_log_id;

  -- 내부 주문 없으면 무시
  if v_order.id is null then
    update catchmenu_integrations
      .delivery_order_sync_log
    set sync_result = 'IGNORED',
        sync_error = 'order_not_found'
    where id = v_log_id;

    return jsonb_build_object(
      'success', true,
      'action', 'IGNORED',
      'reason', 'order_not_found',
      'platform_order_id', p_platform_order_id
    );
  end if;

  -- 매핑 실패
  if v_internal_status_after is null then
    update catchmenu_integrations
      .delivery_order_sync_log
    set sync_result = 'IGNORED',
        sync_error =
          'unknown_platform_status: '
          || p_platform_status
    where id = v_log_id;

    return jsonb_build_object(
      'success', true,
      'action', 'IGNORED',
      'reason', 'unknown_platform_status',
      'platform_status', p_platform_status
    );
  end if;

  -- 상태 동일하면 무시
  if v_internal_status_before
    = v_internal_status_after
  then
    update catchmenu_integrations
      .delivery_order_sync_log
    set sync_result = 'IGNORED',
        sync_error = 'status_unchanged'
    where id = v_log_id;

    return jsonb_build_object(
      'success', true,
      'action', 'IGNORED',
      'reason', 'status_unchanged'
    );
  end if;

  begin
    -- 주문 상태 업데이트
    update catchmenu_pos.orders
    set
      order_status = v_internal_status_after,
      picked_up_at = case
        when v_internal_status_after = 'PICKED_UP'
          then now()
        else picked_up_at
      end,
      delivery_completed_at = case
        when v_internal_status_after = 'COMPLETED'
          then now()
        else delivery_completed_at
      end,
      cancelled_at = case
        when v_internal_status_after = 'CANCELLED'
          then now()
        else cancelled_at
      end,
      updated_at = now()
    where id = v_order.id;

    -- 완료/취소 시 KDS 처리
    if v_internal_status_after in (
      'COMPLETED', 'CANCELLED', 'PICKED_UP'
    ) then
      update catchmenu_kds.kds_tickets
      set
        kds_status = case
          when v_internal_status_after
            = 'COMPLETED'
            then 'SERVED'
          when v_internal_status_after
            = 'CANCELLED'
            then 'CANCELLED'
          when v_internal_status_after
            = 'PICKED_UP'
            then 'SERVED'
          else kds_status
        end,
        served_at = case
          when v_internal_status_after in (
            'COMPLETED', 'PICKED_UP'
          ) then now()
          else served_at
        end,
        cancelled_at = case
          when v_internal_status_after
            = 'CANCELLED'
            then now()
          else cancelled_at
        end,
        updated_at = now()
      where order_id = v_order.id
        and store_id = p_store_id
        and kds_status not in (
          'COMPLETED', 'CANCELLED', 'SERVED'
        );

      v_kds_action := case
        when v_internal_status_after
          = 'CANCELLED'
          then 'CANCELLED'
        else 'SERVED'
      end;
    end if;

    -- 세션 상태 업데이트
    if v_order.session_id is not null then
      update catchmenu_pos.order_sessions
      set
        session_status = case
          when v_internal_status_after
            = 'COMPLETED'
            then 'COMPLETED'
          when v_internal_status_after
            = 'CANCELLED'
            then 'CANCELLED'
          else session_status
        end,
        updated_at = now()
      where id = v_order.session_id
        and session_status not in (
          'COMPLETED', 'CANCELLED', 'EXPIRED'
        );
    end if;

    -- ledger event
    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, event_payload,
      order_id, correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'order', 'delivery_status_synced', 1,
      'order', v_order.id,
      v_internal_status_before,
      v_internal_status_after,
      'DELIVERY_PLATFORM',
      jsonb_build_object(
        'platform_code', p_platform_code,
        'platform_order_id', p_platform_order_id,
        'platform_status', p_platform_status,
        'kds_action', v_kds_action,
        'sync_log_id', v_log_id
      ),
      v_order.id, p_correlation_id,
      v_business_day, v_timezone, now()
    );

    -- 직원 알림 (취소 시)
    if v_internal_status_after = 'CANCELLED' then
      perform catchmenu_common.notify_channel(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel_type := 'STAFF_ALERTS',
        p_event_type := 'delivery_order_cancelled',
        p_payload := jsonb_build_object(
          'order_id', v_order.id,
          'order_number', v_order.order_number,
          'platform_code', p_platform_code,
          'platform_order_id', p_platform_order_id,
          'reason', 'platform_cancelled'
        )
      );
    end if;

    -- sync log 완료
    update catchmenu_integrations
      .delivery_order_sync_log
    set sync_result = 'SUCCESS'
    where id = v_log_id;

  exception when others then
    v_error_msg := sqlerrm;
    v_sync_result := 'FAILED';

    update catchmenu_integrations
      .delivery_order_sync_log
    set
      sync_result = 'FAILED',
      sync_error = v_error_msg
    where id = v_log_id;
  end;

  return jsonb_build_object(
    'success', v_sync_result = 'SUCCESS',
    'sync_log_id', v_log_id,
    'order_id', v_order.id,
    'order_number', v_order.order_number,
    'platform_code', p_platform_code,
    'platform_status', p_platform_status,
    'internal_status_before',
      v_internal_status_before,
    'internal_status_after',
      v_internal_status_after,
    'kds_action', v_kds_action,
    'sync_result', v_sync_result,
    'error', v_error_msg,
    'message_code', case v_sync_result
      when 'SUCCESS'
        then 'delivery_status_synced'
      else 'delivery_sync_failed'
    end
  );
end;
$$;


create or replace function
  catchmenu_integrations.auto_reject_overloaded(
  p_tenant_id uuid,
  p_store_id uuid,
  p_platform_code text,
  p_platform_order_id text,
  p_raw_payload jsonb default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_kds,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_rules record;
  v_kds_active_count int;
  v_store_mode text;
  v_holiday_mode boolean;
  v_reject_reason text;
  v_should_reject boolean := false;
  v_log_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 자동 처리 규칙 조회
  select
    auto_reject_if_kds_overloaded,
    kds_overload_threshold,
    auto_reject_if_store_closed,
    auto_reject_if_holiday,
    reject_message_overloaded,
    reject_message_closed
  into v_rules
  from catchmenu_integrations.delivery_platform_rules
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_code = p_platform_code
    and is_active = true;

  -- 규칙 없으면 기본값으로 검사
  if v_rules.kds_overload_threshold is null then
    v_rules.kds_overload_threshold := 15;
    v_rules.auto_reject_if_kds_overloaded := true;
    v_rules.auto_reject_if_store_closed := true;
    v_rules.reject_message_overloaded :=
      '주방이 바빠 주문을 받을 수 없습니다';
    v_rules.reject_message_closed :=
      '현재 영업시간이 아닙니다';
  end if;

  -- 매장 모드 확인
  select store_mode, holiday_mode
  into v_store_mode, v_holiday_mode
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 규칙 1: 매장 닫힘/홀리데이
  if v_rules.auto_reject_if_store_closed
    and v_store_mode in ('CLOSED', 'EMERGENCY')
  then
    v_should_reject := true;
    v_reject_reason := 'STORE_CLOSED';
  end if;

  if not v_should_reject
    and v_rules.auto_reject_if_holiday
    and coalesce(v_holiday_mode, false)
  then
    v_should_reject := true;
    v_reject_reason := 'HOLIDAY_MODE';
  end if;

  -- 규칙 2: KDS 과부하 확인
  if not v_should_reject
    and v_rules.auto_reject_if_kds_overloaded
  then
    select count(*)
    into v_kds_active_count
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and kds_status in (
        'HOLD', 'CAPACITY_CHECKING', 'COOKING'
      );

    if v_kds_active_count >=
      v_rules.kds_overload_threshold
    then
      v_should_reject := true;
      v_reject_reason := 'KDS_OVERLOADED';
    end if;
  end if;

  -- sync log 기록
  insert into
    catchmenu_integrations.delivery_order_sync_log (
    tenant_id, store_id,
    platform_code, platform_order_id,
    sync_type, sync_direction,
    platform_status_after,
    sync_result,
    raw_payload,
    business_day, synced_at
  ) values (
    p_tenant_id, p_store_id,
    p_platform_code, p_platform_order_id,
    case v_should_reject
      when true then 'REJECTED'
      else 'ORDER_RECEIVED'
    end,
    'OUTBOUND',
    case v_should_reject
      when true then 'REJECTED'
      else 'ACCEPTED'
    end,
    'SUCCESS',
    p_raw_payload,
    v_business_day, now()
  )
  returning id into v_log_id;

  -- 진단 로그
  if v_should_reject then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'DELIVERY',
      p_log_event := 'delivery_order_auto_rejected',
      p_message :=
        p_platform_code
        || ' 주문 자동 거절: '
        || v_reject_reason
        || ' | kds_count='
        || coalesce(v_kds_active_count::text, 'N/A'),
      p_rpc_name := 'auto_reject_overloaded',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'platform_code', p_platform_code,
        'platform_order_id', p_platform_order_id,
        'reject_reason', v_reject_reason,
        'kds_active_count', v_kds_active_count,
        'threshold',
          v_rules.kds_overload_threshold
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'should_reject', v_should_reject,
    'reject_reason', v_reject_reason,
    'reject_message', case v_reject_reason
      when 'KDS_OVERLOADED' then
        v_rules.reject_message_overloaded
      when 'STORE_CLOSED' then
        v_rules.reject_message_closed
      when 'HOLIDAY_MODE' then
        v_rules.reject_message_closed
      else null
    end,
    'kds_active_count', v_kds_active_count,
    'kds_threshold', v_rules.kds_overload_threshold,
    'store_mode', v_store_mode,
    'sync_log_id', v_log_id,
    'message_code', case v_should_reject
      when true then 'order_auto_rejected'
      else 'order_accepted'
    end
  );
end;
$$;


create or replace function
  catchmenu_integrations.update_delivery_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_new_delivery_status text,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_delivery_note text default null,
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
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_business_day date;
  v_timezone text;
  v_allowed_transitions jsonb;
begin
  -- 허용된 상태 전환
  v_allowed_transitions := '{
    "CONFIRMED": ["COOKING", "CANCELLED"],
    "COOKING": ["READY", "CANCELLED"],
    "READY": ["PICKED_UP", "CANCELLED"],
    "PICKED_UP": ["COMPLETED"],
    "COMPLETED": [],
    "CANCELLED": []
  }'::jsonb;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 주문 조회
  select id, order_status, order_number,
         provider_type, provider_order_id,
         session_id
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'update_delivery_status',
      p_order_id := p_order_id
    );
  end if;

  -- 전환 가능 여부 확인
  if not (
    v_allowed_transitions->v_order.order_status
  ) @> to_jsonb(p_new_delivery_status) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_confirmable',
      'current_status', v_order.order_status,
      'requested_status', p_new_delivery_status,
      'allowed', v_allowed_transitions
        ->v_order.order_status
    );
  end if;

  -- 주문 상태 업데이트
  update catchmenu_pos.orders
  set
    order_status = p_new_delivery_status,
    cooking_started_at = case
      when p_new_delivery_status = 'COOKING'
        then coalesce(cooking_started_at, now())
      else cooking_started_at
    end,
    picked_up_at = case
      when p_new_delivery_status = 'PICKED_UP'
        then now()
      else picked_up_at
    end,
    delivery_completed_at = case
      when p_new_delivery_status = 'COMPLETED'
        then now()
      else delivery_completed_at
    end,
    cancelled_at = case
      when p_new_delivery_status = 'CANCELLED'
        then now()
      else cancelled_at
    end,
    updated_at = now()
  where id = p_order_id;

  -- KDS 상태 연동
  if p_new_delivery_status in (
    'COOKING', 'READY', 'PICKED_UP',
    'COMPLETED', 'CANCELLED'
  ) then
    update catchmenu_kds.kds_tickets
    set
      kds_status = case p_new_delivery_status
        when 'COOKING' then 'COOKING'
        when 'READY' then 'READY'
        when 'PICKED_UP' then 'SERVED'
        when 'COMPLETED' then 'SERVED'
        when 'CANCELLED' then 'CANCELLED'
        else kds_status
      end,
      cooking_started_at = case
        when p_new_delivery_status = 'COOKING'
          then coalesce(
            cooking_started_at, now()
          )
        else cooking_started_at
      end,
      served_at = case
        when p_new_delivery_status in (
          'PICKED_UP', 'COMPLETED'
        ) then now()
        else served_at
      end,
      cancelled_at = case
        when p_new_delivery_status = 'CANCELLED'
          then now()
        else cancelled_at
      end,
      updated_at = now()
    where order_id = p_order_id
      and store_id = p_store_id
      and kds_status not in (
        'COMPLETED', 'CANCELLED', 'SERVED'
      );
  end if;

  -- sync log (OUTBOUND)
  insert into
    catchmenu_integrations.delivery_order_sync_log (
    tenant_id, store_id,
    platform_code, platform_order_id,
    order_id, session_id,
    sync_type, sync_direction,
    internal_status_before,
    internal_status_after,
    platform_status_after,
    sync_result,
    business_day, synced_at
  ) values (
    p_tenant_id, p_store_id,
    coalesce(
      replace(v_order.provider_type,
        'DELIVERY_', ''
      ),
      'CUSTOM'
    ),
    coalesce(v_order.provider_order_id, ''),
    p_order_id, v_order.session_id,
    'STATUS_UPDATE', 'OUTBOUND',
    v_order.order_status,
    p_new_delivery_status,
    p_new_delivery_status,
    'SUCCESS',
    v_business_day, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'delivery_status_updated', 1,
    'order', p_order_id,
    v_order.order_status, p_new_delivery_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'order_number', v_order.order_number,
      'provider_type', v_order.provider_type,
      'delivery_note', p_delivery_note
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- 직원 앱 Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'delivery_status_updated',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'old_status', v_order.order_status,
      'new_status', p_new_delivery_status,
      'provider_type', v_order.provider_type
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_confirmed',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'old_status', v_order.order_status,
      'new_status', p_new_delivery_status,
      'provider_type', v_order.provider_type
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.poll_pending_delivery_orders(
  p_tenant_id uuid,
  p_store_id uuid,
  p_platform_code text default null,
  p_max_age_minutes int default 60
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_pending_orders jsonb;
  v_failed_syncs jsonb;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 미완료 배달 주문 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_status', o.order_status,
        'provider_type', o.provider_type,
        'provider_order_id',
          o.provider_order_id,
        'ordered_at', o.ordered_at,
        'age_minutes', extract(
          epoch from (now() - o.ordered_at)
        )::int / 60,
        'total_amount', o.final_amount,
        'last_sync_at', (
          select max(synced_at)
          from catchmenu_integrations
            .delivery_order_sync_log
          where order_id = o.id
        )
      )
      order by o.ordered_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_orders
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.business_day = v_business_day
    and o.order_type = 'DELIVERY'
    and o.order_status not in (
      'COMPLETED', 'CANCELLED', 'PICKED_UP'
    )
    and o.ordered_at >
      now() - (p_max_age_minutes
        || ' minutes')::interval
    and (
      p_platform_code is null
      or o.provider_type =
        'DELIVERY_' || p_platform_code
    );

  -- 실패한 동기화 (재시도 필요)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'sync_log_id', id,
        'platform_code', platform_code,
        'platform_order_id', platform_order_id,
        'sync_type', sync_type,
        'sync_error', sync_error,
        'retry_count', retry_count,
        'synced_at', synced_at
      )
      order by synced_at desc
    ),
    '[]'::jsonb
  )
  into v_failed_syncs
  from catchmenu_integrations.delivery_order_sync_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and sync_result = 'FAILED'
    and retry_count < 3
    and (
      p_platform_code is null
      or platform_code = p_platform_code
    );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'platform_code', p_platform_code,
    'business_day', v_business_day,
    'pending_orders', v_pending_orders,
    'pending_count',
      jsonb_array_length(v_pending_orders),
    'failed_syncs', v_failed_syncs,
    'failed_sync_count',
      jsonb_array_length(v_failed_syncs),
    'needs_attention',
      jsonb_array_length(v_pending_orders) > 0
      or jsonb_array_length(v_failed_syncs) > 0,
    'checked_at', now(),
    'message_code', 'delivery_poll_completed'
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_delivery_performance(
  p_tenant_id uuid,
  p_store_id uuid,
  p_period_start date,
  p_period_end date,
  p_platform_code text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_performance jsonb;
  v_by_platform jsonb;
begin
  -- 플랫폼별 성과
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'platform_code', platform_code,
        'total_orders', total_orders,
        'completed_orders', completed_orders,
        'cancelled_orders', cancelled_orders,
        'rejected_orders', rejected_orders,
        'total_revenue', total_revenue,
        'avg_order_value', case
          when completed_orders > 0
          then (total_revenue / completed_orders)::int
          else 0
        end,
        'completion_rate_pct', case
          when total_orders > 0
          then (
            completed_orders::numeric
            / total_orders * 100
          )::int
          else 0
        end,
        'cancel_rate_pct', case
          when total_orders > 0
          then (
            cancelled_orders::numeric
            / total_orders * 100
          )::int
          else 0
        end,
        'auto_rejected_count', (
          select count(*)
          from catchmenu_integrations
            .delivery_order_sync_log
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and sync_type = 'REJECTED'
            and business_day between
              p_period_start and p_period_end
            and platform_code = perf.platform_code
        ),
        'failed_sync_count', (
          select count(*)
          from catchmenu_integrations
            .delivery_order_sync_log
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and sync_result = 'FAILED'
            and business_day between
              p_period_start and p_period_end
            and platform_code = perf.platform_code
        )
      )
      order by total_revenue desc nulls last
    ),
    '[]'::jsonb
  )
  into v_by_platform
  from (
    select
      replace(o.provider_type, 'DELIVERY_', '')
        as platform_code,
      count(*) as total_orders,
      count(*) filter (
        where o.order_status = 'COMPLETED'
      ) as completed_orders,
      count(*) filter (
        where o.order_status = 'CANCELLED'
      ) as cancelled_orders,
      count(*) filter (
        where o.order_status = 'REJECTED'
      ) as rejected_orders,
      coalesce(sum(pl.net_amount), 0)
        as total_revenue
    from catchmenu_pos.orders o
    left join catchmenu_payment.payment_ledger pl
      on pl.order_id = o.id
      and pl.ledger_status = 'APPROVED'
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.order_type = 'DELIVERY'
      and o.business_day between
        p_period_start and p_period_end
      and o.provider_type like 'DELIVERY_%'
      and (
        p_platform_code is null
        or o.provider_type =
          'DELIVERY_' || p_platform_code
      )
    group by o.provider_type
  ) perf;

  -- 전체 합계
  select jsonb_build_object(
    'total_orders', coalesce(
      sum((p->>'total_orders')::int), 0
    ),
    'total_revenue', coalesce(
      sum((p->>'total_revenue')::numeric), 0
    ),
    'total_completed', coalesce(
      sum((p->>'completed_orders')::int), 0
    ),
    'total_cancelled', coalesce(
      sum((p->>'cancelled_orders')::int), 0
    ),
    'platform_count',
      jsonb_array_length(v_by_platform)
  )
  into v_performance
  from jsonb_array_elements(v_by_platform) p;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'period_start', p_period_start,
    'period_end', p_period_end,
    'platform_filter', p_platform_code,
    'by_platform', v_by_platform,
    'totals', v_performance,
    'message_code', 'delivery_performance_loaded'
  );
end;
$$;


-- pg_cron: 배달 주문 폴링 (5분마다)
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'DELIVERY_POLL_BATCH',
  'catchmenu_delivery_poll',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
SELECT catchmenu_integrations.poll_pending_delivery_orders(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid,
  p_max_age_minutes := 60
);
$sql$,
  '미완료 배달 주문 + 실패 동기화 감지. 5분마다.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.sync_delivery_order_status(
      uuid, uuid, text, text, text, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.sync_delivery_order_status(
      uuid, uuid, text, text, text, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.auto_reject_overloaded(
      uuid, uuid, text, text, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.auto_reject_overloaded(
      uuid, uuid, text, text, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.update_delivery_status(
      uuid, uuid, uuid, text, text, uuid,
      text, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.update_delivery_status(
      uuid, uuid, uuid, text, text, uuid,
      text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.poll_pending_delivery_orders(
      uuid, uuid, text, int
    ) from public;
  grant execute on function
    catchmenu_integrations.poll_pending_delivery_orders(
      uuid, uuid, text, int
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_delivery_performance(
      uuid, uuid, date, date, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_delivery_performance(
      uuid, uuid, date, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.auto_reject_overloaded(
    uuid, uuid, text, text, jsonb, text
  ) is
  'KDS 과부하/매장 닫힘 시 배달 주문 자동 거절.
   거절 조건 (우선순위):
   1. store_mode = CLOSED/EMERGENCY
   2. holiday_mode = true
   3. KDS active tickets >= threshold (기본 15)
   특허2: KDS 수용 상태 기반 Late Binding.
   배달 주문도 KDS 과부하 시 즉시 거절.
   3-B차 안전한 외부 주문 채널 핵심 규칙.';

comment on function
  catchmenu_integrations.sync_delivery_order_status(
    uuid, uuid, text, text, text, jsonb, text
  ) is
  '배달앱 주문 상태 → 내부 주문/KDS 동기화.
   플랫폼 상태 매핑:
   BAEMIN: ACCEPTED→CONFIRMED, DELIVERED→COMPLETED
   YOGIYO: ORDER_CONFIRMED→CONFIRMED
   COUPANG: ACCEPTED_BY_STORE→CONFIRMED
   완료/취소 시 KDS 자동 처리.
   모든 동기화 = delivery_order_sync_log 기록.
   특허1: 배달 주문 = Gateway 샌드박스 증빙.';