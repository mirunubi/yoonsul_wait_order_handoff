-- 0109_create_network_handoff_fallback_rpc.sql
-- Purpose: Network handoff and offline fallback
--          pipeline.
--          인터넷 장애 시 자동 전환 로직.
--          오프라인 큐 관리.
--          Flutter 로컬 fallback 가이드.
--          장애 복구 후 자동 동기화.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0108_create_membership_pipeline_rpc.sql
-- Creates:
--   catchmenu_common.network_status_log (table)
--   catchmenu_common.offline_queue (table)
--   catchmenu_common.fallback_configs (table)
--   function catchmenu_common.report_network_status(...)
--   function catchmenu_common.enqueue_offline_action(...)
--   function catchmenu_common.flush_offline_queue(...)
--   function catchmenu_common.get_fallback_config(...)
--   function catchmenu_common.get_network_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('network_switched', 'ko',
  '네트워크가 {from_isp}에서 {to_isp}(으)로 자동 전환되었습니다'),
('network_switched', 'en',
  'Network switched from {from_isp} to {to_isp}'),
('network_switched', 'zh',
  '网络已从{from_isp}自动切换至{to_isp}'),
('network_switched', 'ja',
  'ネットワークが{from_isp}から{to_isp}に切り替わりました'),
('network_switched', 'vi',
  'Mạng đã chuyển từ {from_isp} sang {to_isp}'),
('network_switched', 'th',
  'เครือข่ายสลับจาก {from_isp} ไปยัง {to_isp}'),

('network_restored', 'ko',
  '인터넷 연결이 복구되었습니다'),
('network_restored', 'en',
  'Internet connection restored'),
('network_restored', 'zh',
  '网络连接已恢复'),
('network_restored', 'ja',
  'インターネット接続が回復しました'),
('network_restored', 'vi',
  'Kết nối internet đã được khôi phục'),
('network_restored', 'th',
  'การเชื่อมต่ออินเทอร์เน็ตกลับมาแล้ว'),

('offline_mode_activated', 'ko',
  '오프라인 모드로 전환되었습니다. 주문은 계속 가능합니다'),
('offline_mode_activated', 'en',
  'Offline mode activated. Orders still available'),
('offline_mode_activated', 'zh',
  '已切换至离线模式，仍可继续下单'),
('offline_mode_activated', 'ja',
  'オフラインモードに切り替わりました。注文は引き続き可能です'),
('offline_mode_activated', 'vi',
  'Đã kích hoạt chế độ offline. Vẫn có thể đặt hàng'),
('offline_mode_activated', 'th',
  'เปิดใช้งานโหมดออฟไลน์ ยังสั่งอาหารได้'),

('offline_queue_flushed', 'ko',
  '오프라인 중 {count}건이 동기화되었습니다'),
('offline_queue_flushed', 'en',
  '{count} offline actions synced'),
('offline_queue_flushed', 'zh',
  '{count}条离线操作已同步'),
('offline_queue_flushed', 'ja',
  'オフライン中の{count}件が同期されました'),
('offline_queue_flushed', 'vi',
  '{count} thao tác offline đã đồng bộ'),
('offline_queue_flushed', 'th',
  'ซิงค์ {count} รายการออฟไลน์แล้ว'),

('fallback_payment_manual', 'ko',
  '결제 시스템 장애. 수기 영수증 모드로 전환됩니다'),
('fallback_payment_manual', 'en',
  'Payment system down. Manual receipt mode'),
('fallback_pos_direct', 'ko',
  'POS 연결 장애. 직접 POS 단말기를 사용해 주세요'),
('fallback_pos_direct', 'en',
  'POS connection failed. Use POS terminal directly'),
('fallback_kds_paper', 'ko',
  'KDS 장애. 주방 프린터 또는 구두 전달 모드'),
('fallback_kds_paper', 'en',
  'KDS down. Kitchen printer or verbal mode'),
('network_dashboard_loaded', 'ko',
  '네트워크 대시보드가 로드되었습니다'),
('network_dashboard_loaded', 'en',
  'Network dashboard loaded')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(3030, 'network_primary_down',
  'SYSTEM', 'TECHNICAL', 503, 'ERROR',
  'SOP-SYS-002'),
(3031, 'network_all_down',
  'SYSTEM', 'TECHNICAL', 503, 'CRITICAL',
  'SOP-SYS-002'),
(3032, 'offline_queue_overflow',
  'SYSTEM', 'CAPACITY', 507, 'WARNING', null),
(3033, 'offline_queue_flush_partial',
  'SYSTEM', 'TECHNICAL', 206, 'WARNING', null)
on conflict (code) do nothing;


-- =============================================
-- network_status_log table
-- 네트워크 상태 이력
-- =============================================
create table if not exists
  catchmenu_common.network_status_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  device_id uuid,

  -- 네트워크 상태
  network_status text not null,
  isp_primary text,
  isp_fallback text,
  connection_type text,

  -- 전환 정보
  switched_from text,
  switched_to text,
  switch_reason text,
  auto_switched boolean not null default false,

  -- 장애 정보
  downtime_seconds int,
  is_recovered boolean not null default false,
  recovered_at timestamptz,

  -- 영향
  offline_queue_count int default 0,
  affected_orders int default 0,

  reported_at timestamptz
    not null default now(),

  constraint chk_network_status check (
    network_status in (
      'ONLINE',         -- 정상
      'SWITCHED',       -- ISP 전환됨
      'DEGRADED',       -- 느림/불안정
      'OFFLINE',        -- 완전 단절
      'RESTORED'        -- 복구됨
    )
  ),
  constraint chk_connection_type check (
    connection_type in (
      'KT_FIBER',       -- KT 유선
      'SKT_LTE',        -- SKT LTE
      'LGU_LTE',        -- LG U+ LTE
      'SKT_5G',         -- SKT 5G
      'LGU_5G',         -- LG U+ 5G
      'KT_LTE',         -- KT LTE
      'WIFI',           -- 기타 WiFi
      'OFFLINE'         -- 오프라인
    )
  )
);

create index if not exists idx_network_log_store
  on catchmenu_common.network_status_log(
    store_id, reported_at desc
  );
create index if not exists idx_network_log_offline
  on catchmenu_common.network_status_log(
    store_id, network_status
  ) where network_status in (
    'OFFLINE', 'DEGRADED'
  );

alter table catchmenu_common.network_status_log
  enable row level security;
alter table catchmenu_common.network_status_log
  force row level security;

drop policy if exists network_log_isolation
  on catchmenu_common.network_status_log;
create policy network_log_isolation
  on catchmenu_common.network_status_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_common.network_status_log is
  '네트워크 상태 이력.
   Flutter 앱이 연결 상태 감지 후 보고.
   ISP 전환: KT → SKT/LGU+ 자동 전환.
   downtime_seconds: 장애 지속 시간.
   offline_queue_count: 오프라인 중 쌓인 건수.
   특허1: 네트워크 이력 = 운영 감사 증빙.
   "KT 터져도 멀쩡" 증거 데이터.';


-- =============================================
-- offline_queue table
-- 오프라인 중 발생한 액션 큐
-- =============================================
create table if not exists
  catchmenu_common.offline_queue (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  device_id uuid,

  -- 액션 정보
  action_type text not null,
  action_payload jsonb not null,
  action_priority int not null default 5,

  -- 상태
  queue_status text not null default 'PENDING',
  retry_count int not null default 0,
  max_retries int not null default 3,

  -- 로컬 임시 ID (Flutter SQLite에서 생성)
  local_temp_id text,
  server_result_id uuid,

  -- 오프라인 발생 시각
  queued_at timestamptz not null default now(),
  flushed_at timestamptz,
  error_detail text,

  -- 만료
  expires_at timestamptz not null
    default now() + interval '24 hours',

  constraint chk_action_type check (
    action_type in (
      -- 주문
      'CREATE_ORDER',
      'ADD_ORDER_ITEM',
      'CANCEL_ORDER',
      -- KDS
      'UPDATE_KDS_STATUS',
      -- 대기
      'CREATE_WAITING_SESSION',
      'UPDATE_WAITING_STATUS',
      -- 결제 (수기)
      'RECORD_MANUAL_PAYMENT',
      -- 현금영수증
      'ISSUE_CASH_RECEIPT',
      -- CMS
      'LOG_BANNER_VIEW',
      'LOG_EVENT_TAP',
      -- 스탬프
      'STAMP_VISIT',
      -- 기타
      'LOG_DIAGNOSTIC'
    )
  ),
  constraint chk_queue_status check (
    queue_status in (
      'PENDING',    -- 동기화 대기
      'PROCESSING', -- 처리 중
      'COMPLETED',  -- 완료
      'FAILED',     -- 실패
      'EXPIRED',    -- 만료
      'SKIPPED'     -- 건너뜀
    )
  )
);

create index if not exists idx_offline_queue_store
  on catchmenu_common.offline_queue(
    store_id, queue_status,
    action_priority desc, queued_at asc
  ) where queue_status = 'PENDING';
create index if not exists idx_offline_queue_expire
  on catchmenu_common.offline_queue(
    expires_at
  ) where queue_status = 'PENDING';

alter table catchmenu_common.offline_queue
  enable row level security;
alter table catchmenu_common.offline_queue
  force row level security;

drop policy if exists offline_queue_isolation
  on catchmenu_common.offline_queue;
create policy offline_queue_isolation
  on catchmenu_common.offline_queue
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table catchmenu_common.offline_queue is
  '오프라인 액션 큐.
   Flutter SQLite에서 로컬 처리 후
   온라인 복구 시 서버 동기화.
   action_priority: 낮을수록 우선 처리.
   CREATE_ORDER: 1 (최우선)
   RECORD_MANUAL_PAYMENT: 2
   UPDATE_KDS_STATUS: 3
   STAMP_VISIT: 5
   LOG_*: 9 (나중에)
   expires_at: 24시간 후 자동 만료.
   "오프라인에서도 주문 가능" 핵심 테이블.';


-- =============================================
-- fallback_configs table
-- 장애 시나리오별 fallback 설정
-- =============================================
create table if not exists
  catchmenu_common.fallback_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 장애 시나리오
  failure_scenario text not null,
  is_enabled boolean not null default true,

  -- Fallback 동작
  fallback_action text not null,
  fallback_message_key text not null,
  sop_runbook_code text,

  -- ISP 전환 설정
  primary_isp text default 'KT_FIBER',
  fallback_isp_priority jsonb
    default '["SKT_LTE","LGU_LTE","SKT_5G"]'::jsonb,
  auto_switch_enabled boolean
    not null default true,
  switch_threshold_seconds int default 10,

  -- 오프라인 설정
  offline_order_enabled boolean
    not null default true,
  offline_kds_enabled boolean
    not null default true,
  offline_payment_mode text
    default 'MANUAL_RECEIPT',

  -- 복구 설정
  auto_sync_on_restore boolean
    not null default true,
  sync_priority_order jsonb
    default '["CREATE_ORDER","RECORD_MANUAL_PAYMENT","UPDATE_KDS_STATUS"]'::jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_fallback_scenario unique (
    store_id, failure_scenario
  ),
  constraint chk_failure_scenario check (
    failure_scenario in (
      'NETWORK_PRIMARY_DOWN',   -- 주회선 장애
      'NETWORK_ALL_DOWN',       -- 전체 통신 장애
      'POS_CONNECTION_FAILED',  -- POS 연결 장애
      'KDS_CONNECTION_FAILED',  -- KDS 연결 장애
      'PAYMENT_GATEWAY_DOWN',   -- 결제망 장애
      'SUPABASE_DOWN',          -- Supabase 장애
      'DELIVERY_PLATFORM_DOWN'  -- 배달앱 장애
    )
  ),
  constraint chk_offline_payment check (
    offline_payment_mode in (
      'MANUAL_RECEIPT',  -- 수기 영수증
      'VAN_TERMINAL',    -- VAN 단말기 직접
      'CASH_ONLY',       -- 현금만
      'DEFER'            -- 나중에 결제
    )
  )
);

alter table catchmenu_common.fallback_configs
  enable row level security;
alter table catchmenu_common.fallback_configs
  force row level security;

drop policy if exists fallback_config_isolation
  on catchmenu_common.fallback_configs;
create policy fallback_config_isolation
  on catchmenu_common.fallback_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_fallback_config_updated
  on catchmenu_common.fallback_configs;
create trigger trg_fallback_config_updated
  before update on catchmenu_common.fallback_configs
  for each row execute function
    catchmenu_common.set_updated_at();

-- 기본 fallback 설정 시드
insert into catchmenu_common.fallback_configs (
  tenant_id, store_id,
  failure_scenario, fallback_action,
  fallback_message_key, sop_runbook_code,
  primary_isp, fallback_isp_priority,
  auto_switch_enabled, switch_threshold_seconds,
  offline_order_enabled, offline_kds_enabled,
  offline_payment_mode, auto_sync_on_restore
) values
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'NETWORK_PRIMARY_DOWN',
  'AUTO_SWITCH_ISP',
  'network_switched',
  'SOP-SYS-002',
  'KT_FIBER',
  '["SKT_LTE","LGU_LTE","SKT_5G","LGU_5G"]'::jsonb,
  true, 10,
  true, true,
  'VAN_TERMINAL', true
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'NETWORK_ALL_DOWN',
  'OFFLINE_MODE',
  'offline_mode_activated',
  'SOP-SYS-002',
  'KT_FIBER',
  '["SKT_LTE","LGU_LTE","SKT_5G","LGU_5G"]'::jsonb,
  false, 30,
  true, true,
  'VAN_TERMINAL', true
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'POS_CONNECTION_FAILED',
  'DIRECT_POS_TERMINAL',
  'fallback_pos_direct',
  'SOP-POS-001',
  'KT_FIBER',
  '["SKT_LTE","LGU_LTE"]'::jsonb,
  false, 0,
  true, true,
  'VAN_TERMINAL', true
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'KDS_CONNECTION_FAILED',
  'KITCHEN_PRINTER_OR_VERBAL',
  'fallback_kds_paper',
  'SOP-KDS-001',
  'KT_FIBER',
  '["SKT_LTE","LGU_LTE"]'::jsonb,
  false, 0,
  true, true,
  'MANUAL_RECEIPT', true
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'PAYMENT_GATEWAY_DOWN',
  'VAN_DIRECT_OR_MANUAL',
  'fallback_payment_manual',
  'SOP-PAY-001',
  'KT_FIBER',
  '["SKT_LTE","LGU_LTE"]'::jsonb,
  false, 0,
  true, true,
  'VAN_TERMINAL', true
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'DELIVERY_PLATFORM_DOWN',
  'MANUAL_ORDER_INTAKE',
  'delivery_sync_failed',
  'SOP-DEL-001',
  'KT_FIBER',
  '["SKT_LTE","LGU_LTE"]'::jsonb,
  false, 0,
  true, true,
  'MANUAL_RECEIPT', true
)
on conflict (store_id, failure_scenario)
do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.report_network_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_network_status text,
  p_connection_type text,
  p_isp_primary text default null,
  p_isp_fallback text default null,
  p_switched_from text default null,
  p_switched_to text default null,
  p_switch_reason text default null,
  p_offline_queue_count int default 0,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_log_id uuid;
  v_fallback_config record;
  v_prev_log record;
  v_downtime_seconds int;
  v_message_key text;
begin
  -- 이전 상태 조회 (장애 시간 계산)
  select network_status, reported_at
  into v_prev_log
  from catchmenu_common.network_status_log
  where store_id = p_store_id
    and device_id = p_device_id
  order by reported_at desc
  limit 1;

  -- 장애 시간 계산
  if v_prev_log.network_status = 'OFFLINE'
    and p_network_status = 'RESTORED'
  then
    v_downtime_seconds := extract(
      epoch from (
        now() - v_prev_log.reported_at
      )
    )::int;
  end if;

  -- 메시지 키 결정
  v_message_key := case p_network_status
    when 'SWITCHED' then 'network_switched'
    when 'OFFLINE' then 'offline_mode_activated'
    when 'RESTORED' then 'network_restored'
    else 'network_restored'
  end;

  -- 네트워크 로그 기록
  insert into
    catchmenu_common.network_status_log (
    tenant_id, store_id, device_id,
    network_status, isp_primary, isp_fallback,
    connection_type,
    switched_from, switched_to, switch_reason,
    auto_switched, downtime_seconds,
    is_recovered,
    recovered_at,
    offline_queue_count
  ) values (
    p_tenant_id, p_store_id, p_device_id,
    p_network_status, p_isp_primary,
    p_isp_fallback, p_connection_type,
    p_switched_from, p_switched_to,
    p_switch_reason,
    p_switched_from is not null,
    v_downtime_seconds,
    p_network_status = 'RESTORED',
    case p_network_status = 'RESTORED'
      when true then now() else null
    end,
    p_offline_queue_count
  )
  returning id into v_log_id;

  -- CRITICAL 장애 시 운영 알림
  if p_network_status = 'OFFLINE' then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'CUSTOM',
      p_alert_severity := 'CRITICAL',
      p_alert_domain := 'SYSTEM',
      p_alert_title_key :=
        'offline_mode_activated',
      p_alert_detail := jsonb_build_object(
        'device_id', p_device_id,
        'connection_type', p_connection_type,
        'offline_queue_count',
          p_offline_queue_count
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-SYS-002'
    );
  end if;

  -- ISP 전환 시 직원 알림
  if p_network_status in (
    'SWITCHED', 'OFFLINE', 'RESTORED'
  ) then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'STAFF_ALERTS',
      p_event_type := 'network_status_changed',
      p_payload := jsonb_build_object(
        'network_status', p_network_status,
        'connection_type', p_connection_type,
        'switched_from', p_switched_from,
        'switched_to', p_switched_to,
        'downtime_seconds', v_downtime_seconds,
        'offline_queue_count',
          p_offline_queue_count,
        'message',
          catchmenu_common.get_message(
            v_message_key, p_locale,
            jsonb_build_object(
              'from_isp',
                coalesce(p_switched_from, ''),
              'to_isp',
                coalesce(p_switched_to, '')
            )
          )
      )
    );
  end if;

  -- fallback 설정 조회
  select failure_scenario, fallback_action,
         offline_order_enabled,
         offline_payment_mode,
         fallback_isp_priority,
         sync_priority_order
  into v_fallback_config
  from catchmenu_common.fallback_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and failure_scenario = case p_network_status
      when 'OFFLINE' then 'NETWORK_ALL_DOWN'
      when 'SWITCHED' then 'NETWORK_PRIMARY_DOWN'
      else 'NETWORK_PRIMARY_DOWN'
    end
    and is_enabled = true;

  return catchmenu_common.build_success_response(
    p_message_key := v_message_key,
    p_data := jsonb_build_object(
      'log_id', v_log_id,
      'network_status', p_network_status,
      'connection_type', p_connection_type,
      'switched_from', p_switched_from,
      'switched_to', p_switched_to,
      'downtime_seconds', v_downtime_seconds,
      'offline_queue_count',
        p_offline_queue_count,
      'fallback', case
        when v_fallback_config.failure_scenario
          is not null
        then jsonb_build_object(
          'action', v_fallback_config
            .fallback_action,
          'offline_order_enabled',
            v_fallback_config
              .offline_order_enabled,
          'offline_payment_mode',
            v_fallback_config
              .offline_payment_mode,
          'next_isp_priority',
            v_fallback_config
              .fallback_isp_priority
        )
        else null
      end
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'from_isp', coalesce(p_switched_from, ''),
      'to_isp', coalesce(p_switched_to, '')
    )
  );
end;
$$;


create or replace function
  catchmenu_common.enqueue_offline_action(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_action_type text,
  p_action_payload jsonb,
  p_local_temp_id text default null,
  p_action_priority int default 5
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_queue_id uuid;
  v_queue_count int;
  v_max_queue int := 500;
begin
  -- 큐 용량 확인
  select count(*) into v_queue_count
  from catchmenu_common.offline_queue
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and queue_status = 'PENDING';

  if v_queue_count >= v_max_queue then
    return catchmenu_common.build_error_response(
      p_error_key := 'offline_queue_overflow',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'enqueue_offline_action'
    );
  end if;

  -- 우선순위 자동 설정
  declare
    v_priority int;
  begin
    v_priority := case p_action_type
      when 'CREATE_ORDER' then 1
      when 'RECORD_MANUAL_PAYMENT' then 2
      when 'UPDATE_KDS_STATUS' then 3
      when 'CANCEL_ORDER' then 3
      when 'CREATE_WAITING_SESSION' then 4
      when 'STAMP_VISIT' then 5
      when 'ISSUE_CASH_RECEIPT' then 5
      when 'LOG_BANNER_VIEW' then 9
      when 'LOG_EVENT_TAP' then 9
      when 'LOG_DIAGNOSTIC' then 10
      else p_action_priority
    end;

    insert into catchmenu_common.offline_queue (
      tenant_id, store_id, device_id,
      action_type, action_payload,
      action_priority, local_temp_id,
      queue_status
    ) values (
      p_tenant_id, p_store_id, p_device_id,
      p_action_type, p_action_payload,
      v_priority, p_local_temp_id,
      'PENDING'
    )
    returning id into v_queue_id;
  end;

  return catchmenu_common.build_success_response(
    p_message_key := 'usage_recorded',
    p_data := jsonb_build_object(
      'queue_id', v_queue_id,
      'action_type', p_action_type,
      'local_temp_id', p_local_temp_id,
      'queue_position', v_queue_count + 1,
      'total_pending', v_queue_count + 1,
      'note',
        '온라인 복구 시 자동 동기화됩니다'
    ),
    p_locale := 'ko'
  );
end;
$$;


create or replace function
  catchmenu_common.flush_offline_queue(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid default null,
  p_max_batch int default 50,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_store
as $$
declare
  v_item record;
  v_processed int := 0;
  v_failed int := 0;
  v_skipped int := 0;
  v_results jsonb := '[]'::jsonb;
  v_result jsonb;
begin
  -- 우선순위 순으로 배치 처리
  for v_item in
    select id, action_type, action_payload,
           local_temp_id, retry_count
    from catchmenu_common.offline_queue
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and queue_status = 'PENDING'
      and expires_at > now()
      and (
        p_device_id is null
        or device_id = p_device_id
      )
    order by action_priority asc,
             queued_at asc
    limit p_max_batch
    for update skip locked
  loop
    -- PROCESSING 표시
    update catchmenu_common.offline_queue
    set queue_status = 'PROCESSING'
    where id = v_item.id;

    begin
      -- 액션 타입별 실제 처리
      case v_item.action_type

        when 'CREATE_ORDER' then
          -- 주문 생성
          declare
            v_order_id uuid;
          begin
            -- 로컬 임시 ID로 중복 확인
            select id into v_order_id
            from catchmenu_pos.orders
            where tenant_id = p_tenant_id
              and store_id = p_store_id
              and local_temp_id =
                v_item.local_temp_id;

            if v_order_id is null then
              insert into catchmenu_pos.orders (
                tenant_id, store_id,
                order_number, order_type,
                order_status, order_source,
                total_amount, final_amount,
                memo,
                local_temp_id,
                ordered_at, business_day,
                business_timezone
              )
              select
                p_tenant_id, p_store_id,
                v_item.action_payload
                  ->>'order_number',
                v_item.action_payload
                  ->>'order_type',
                'CONFIRMED',
                'OFFLINE',
                (v_item.action_payload
                  ->>'total_amount')::int,
                (v_item.action_payload
                  ->>'final_amount')::int,
                v_item.action_payload
                  ->>'request_memo',
                v_item.local_temp_id,
                (v_item.action_payload
                  ->>'ordered_at')::timestamptz,
                (v_item.action_payload
                  ->>'business_day')::date,
                'Asia/Seoul'
              returning id into v_order_id;
            end if;

            v_result := jsonb_build_object(
              'success', true,
              'order_id', v_order_id
            );
          end;

        when 'UPDATE_KDS_STATUS' then
          -- KDS 상태 업데이트
          update catchmenu_kds.kds_tickets
          set
            kds_status = v_item.action_payload
              ->>'new_status',
            updated_at = now()
          where id = (
            v_item.action_payload->>'ticket_id'
          )::uuid;

          v_result := jsonb_build_object(
            'success', true,
            'ticket_id', v_item.action_payload
              ->>'ticket_id'
          );

        when 'RECORD_MANUAL_PAYMENT' then
          -- 수기 결제 기록
          declare
            v_ledger_id uuid;
            v_intent_id uuid;
            v_provider_response_id uuid;
            v_order_id uuid;
            v_amount int;
            v_payment_method text;
            v_payment_key text;
            v_provider_payload jsonb;
          begin
            v_order_id := (
              v_item.action_payload
                ->>'order_id'
            )::uuid;
            v_amount := (
              v_item.action_payload
                ->>'amount'
            )::int;
            v_payment_method := coalesce(
              v_item.action_payload
                ->>'payment_method',
              'CASH'
            );
            v_payment_key := 'MANUAL-' || v_item.id::text;
            v_provider_payload := jsonb_build_object(
              'offline', true,
              'manual', true,
              'queue_item_id', v_item.id,
              'note', v_item.action_payload
                ->>'note'
            );

            insert into catchmenu_gateway.provider_raw_events (
              tenant_id,
              store_id,
              provider_type,
              provider_code,
              provider_event_id,
              provider_event_type,
              raw_payload,
              correlation_id
            ) values (
              p_tenant_id,
              p_store_id,
              'OTHER',
              'MANUAL',
              v_payment_key,
              'RECORD_MANUAL_PAYMENT',
              v_provider_payload,
              null
            )
            returning id into v_provider_response_id;

            v_intent_id :=
              catchmenu_payment.resolve_or_create_payment_intent(
                p_tenant_id := p_tenant_id,
                p_store_id := p_store_id,
                p_order_id := v_order_id,
                p_requested_amount := v_amount,
                p_payment_method := v_payment_method,
                p_payment_channel := 'STAFF_POS',
                p_provider_type := 'MANUAL',
                p_intent_origin := 'MANUAL_ENTRY',
                p_origin_reference := jsonb_build_object(
                  'source', 'flush_offline_queue',
                  'queue_item_id', v_item.id,
                  'payment_key', v_payment_key
                ),
                p_intent_id := null,
                p_session_id := null,
                p_locale := p_locale
              );
            insert into
              catchmenu_payment.payment_ledger (
              tenant_id, store_id,
              order_id, intent_id,
              ledger_entry_type,
              provider_type,
              provider_payment_key,
              provider_response_id,
              approved_amount,
              net_amount, ledger_status,
              approved_at, business_day,
              business_timezone
            ) values (
              p_tenant_id, p_store_id,
              v_order_id,
              v_intent_id,
              'APPROVAL',
              'MANUAL',
              v_payment_key,
              v_provider_response_id,
              v_amount,
              v_amount,
              'APPROVED',
              (v_item.action_payload
                ->>'paid_at')::timestamptz,
              (v_item.action_payload
                ->>'business_day')::date,
              'Asia/Seoul'
            )
            returning id into v_ledger_id;

            v_result := jsonb_build_object(
              'success', true,
              'ledger_id', v_ledger_id
            );
          end;

        when 'STAMP_VISIT' then
          v_result :=
            catchmenu_store.stamp_visit(
              p_tenant_id := p_tenant_id,
              p_store_id := p_store_id,
              p_customer_id := (
                v_item.action_payload
                  ->>'customer_id'
              )::uuid,
              p_order_id := (
                v_item.action_payload
                  ->>'order_id'
              )::uuid,
              p_order_amount := (
                v_item.action_payload
                  ->>'order_amount'
              )::int,
              p_locale := p_locale
            );

        when 'LOG_BANNER_VIEW',
             'LOG_EVENT_TAP',
             'LOG_DIAGNOSTIC' then
          -- 통계/로그는 단순 기록
          v_result := jsonb_build_object(
            'success', true,
            'action', v_item.action_type
          );

        else
          v_result := jsonb_build_object(
            'success', false,
            'reason', 'unhandled_action_type'
          );
          v_skipped := v_skipped + 1;
      end case;

      -- 완료 처리
      update catchmenu_common.offline_queue
      set
        queue_status = 'COMPLETED',
        server_result_id = case
          when v_result->>'order_id' is not null
          then (v_result->>'order_id')::uuid
          when v_result->>'ledger_id' is not null
          then (v_result->>'ledger_id')::uuid
          else null
        end,
        flushed_at = now()
      where id = v_item.id;

      v_processed := v_processed + 1;
      v_results := v_results
        || jsonb_build_object(
          'queue_id', v_item.id,
          'action_type', v_item.action_type,
          'status', 'COMPLETED',
          'result', v_result
        );

    exception when others then
      -- 실패 처리
      update catchmenu_common.offline_queue
      set
        queue_status = case
          when retry_count + 1
            >= max_retries then 'FAILED'
          else 'PENDING'
        end,
        retry_count = retry_count + 1,
        error_detail = sqlerrm
      where id = v_item.id;

      v_failed := v_failed + 1;
      v_results := v_results
        || jsonb_build_object(
          'queue_id', v_item.id,
          'action_type', v_item.action_type,
          'status', 'FAILED',
          'error', sqlerrm
        );
    end;
  end loop;

  -- 복구 네트워크 로그
  if v_processed > 0 then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'SYSTEM',
      p_log_event := 'offline_queue_flushed',
      p_message :=
        '오프라인 큐 동기화 완료'
        || ' | 처리=' || v_processed
        || ' | 실패=' || v_failed,
      p_rpc_name := 'flush_offline_queue',
      p_details := jsonb_build_object(
        'processed', v_processed,
        'failed', v_failed,
        'skipped', v_skipped
      )
    );
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'offline_queue_flushed',
    p_data := jsonb_build_object(
      'processed', v_processed,
      'failed', v_failed,
      'skipped', v_skipped,
      'total', v_processed + v_failed
        + v_skipped,
      'results', v_results
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'count', v_processed
    )
  );
end;
$$;


create or replace function
  catchmenu_common.get_fallback_config(
  p_tenant_id uuid,
  p_store_id uuid,
  p_failure_scenario text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_configs jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'failure_scenario', failure_scenario,
        'fallback_action', fallback_action,
        'fallback_message',
          catchmenu_common.get_message(
            fallback_message_key,
            p_locale, null
          ),
        'sop_runbook_code', sop_runbook_code,
        'primary_isp', primary_isp,
        'fallback_isp_priority',
          fallback_isp_priority,
        'auto_switch_enabled',
          auto_switch_enabled,
        'switch_threshold_seconds',
          switch_threshold_seconds,
        'offline_order_enabled',
          offline_order_enabled,
        'offline_kds_enabled',
          offline_kds_enabled,
        'offline_payment_mode',
          offline_payment_mode,
        'auto_sync_on_restore',
          auto_sync_on_restore,
        'sync_priority_order',
          sync_priority_order,
        'is_enabled', is_enabled
      )
      order by failure_scenario
    ),
    '[]'::jsonb
  )
  into v_configs
  from catchmenu_common.fallback_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and (
      p_failure_scenario is null
      or failure_scenario = p_failure_scenario
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'membership_config_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'configs', v_configs,
      'scenario_count',
        jsonb_array_length(v_configs),
      'flutter_guide', jsonb_build_object(
        'network_check',
          'ConnectivityPlus 패키지 사용',
        'isp_switch',
          '모바일 데이터 자동 전환',
        'offline_storage',
          'Hive AES-256 로컬 저장',
        'queue_flush',
          '온라인 복구 감지 → flush_offline_queue()',
        'manual_payment',
          'RECORD_MANUAL_PAYMENT → enqueue'
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_network_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_business_day date;
  v_current_status record;
  v_today_summary jsonb;
  v_offline_queue_summary jsonb;
  v_recent_events jsonb;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 네트워크 상태
  select network_status, connection_type,
         isp_primary, isp_fallback,
         reported_at
  into v_current_status
  from catchmenu_common.network_status_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  order by reported_at desc
  limit 1;

  -- 오늘 장애 요약
  select jsonb_build_object(
    'total_events', count(*),
    'offline_count', count(*) filter (
      where network_status = 'OFFLINE'
    ),
    'switch_count', count(*) filter (
      where network_status = 'SWITCHED'
    ),
    'total_downtime_seconds', coalesce(
      sum(downtime_seconds), 0
    ),
    'affected_orders', coalesce(
      sum(affected_orders), 0
    ),
    'offline_queue_synced', coalesce(
      sum(offline_queue_count) filter (
        where network_status = 'RESTORED'
      ), 0
    )
  )
  into v_today_summary
  from catchmenu_common.network_status_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and reported_at::date = v_business_day;

  -- 오프라인 큐 현황
  select jsonb_build_object(
    'pending_count', count(*) filter (
      where queue_status = 'PENDING'
    ),
    'completed_today', count(*) filter (
      where queue_status = 'COMPLETED'
        and flushed_at::date = v_business_day
    ),
    'failed_count', count(*) filter (
      where queue_status = 'FAILED'
    ),
    'by_action_type', (
      select coalesce(
        jsonb_object_agg(
          action_type, cnt
        ),
        '{}'::jsonb
      )
      from (
        select action_type,
               count(*)::int as cnt
        from catchmenu_common.offline_queue
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and queue_status = 'PENDING'
        group by action_type
      ) a
    )
  )
  into v_offline_queue_summary
  from catchmenu_common.offline_queue
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 최근 네트워크 이벤트
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'network_status', network_status,
        'connection_type', connection_type,
        'switched_from', switched_from,
        'switched_to', switched_to,
        'downtime_seconds', downtime_seconds,
        'reported_at', reported_at
      )
      order by reported_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_events
  from catchmenu_common.network_status_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and network_status in (
      'OFFLINE', 'SWITCHED', 'RESTORED'
    )
  limit 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'network_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'current_status', case
        when v_current_status.network_status
          is not null
        then jsonb_build_object(
          'status',
            v_current_status.network_status,
          'connection_type',
            v_current_status.connection_type,
          'isp_primary',
            v_current_status.isp_primary,
          'isp_fallback',
            v_current_status.isp_fallback,
          'reported_at',
            v_current_status.reported_at
        )
        else jsonb_build_object(
          'status', 'ONLINE',
          'note', '보고 없음 = 정상'
        )
      end,
      'today_summary', v_today_summary,
      'offline_queue', v_offline_queue_summary,
      'recent_events', v_recent_events,
      'handoff_principle', jsonb_build_object(
        'primary', 'KT 유선',
        'fallback_1', 'SKT LTE/5G',
        'fallback_2', 'LGU+ LTE/5G',
        'offline', 'Flutter 로컬 SQLite',
        'restore', '자동 동기화',
        'motto', 'KT 터져도 멀쩡한 매장'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- pg_cron: 오프라인 큐 만료 처리
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'OFFLINE_QUEUE_EXPIRE',
  'catchmenu_offline_queue_expire',
  '0 */1 * * *',
  '0 */1 * * * (1시간마다)',
  $sql$
UPDATE catchmenu_common.offline_queue
SET queue_status = 'EXPIRED'
WHERE queue_status = 'PENDING'
  AND expires_at < now();
$sql$,
  '오프라인 큐 만료 처리. 1시간마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.report_network_status(
      uuid, uuid, uuid, text, text,
      text, text, text, text, text, int, text
    ) from public;
  grant execute on function
    catchmenu_common.report_network_status(
      uuid, uuid, uuid, text, text,
      text, text, text, text, text, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.enqueue_offline_action(
      uuid, uuid, uuid, text, jsonb, text, int
    ) from public;
  grant execute on function
    catchmenu_common.enqueue_offline_action(
      uuid, uuid, uuid, text, jsonb, text, int
    ) to authenticated;

  revoke all on function
    catchmenu_common.flush_offline_queue(
      uuid, uuid, uuid, int, text
    ) from public;
  grant execute on function
    catchmenu_common.flush_offline_queue(
      uuid, uuid, uuid, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_fallback_config(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.get_fallback_config(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_network_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.get_network_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_common.flush_offline_queue(
    uuid, uuid, uuid, int, text
  ) is
  '오프라인 큐 동기화 함수.
   온라인 복구 감지 후 Flutter가 즉시 호출.

   처리 순서 (우선순위):
   1. CREATE_ORDER (주문 생성)
   2. RECORD_MANUAL_PAYMENT (수기 결제)
   3. UPDATE_KDS_STATUS (KDS 상태)
   4. CREATE_WAITING_SESSION (대기 등록)
   5. STAMP_VISIT (스탬프)
   9. LOG_* (통계 로그)

   중복 방지:
   CREATE_ORDER: local_temp_id로 중복 확인.
   RECORD_MANUAL_PAYMENT: MANUAL provider.

   배치 처리:
   p_max_batch = 50 (기본값).
   실패 시 retry_count + 1.
   3회 초과 시 FAILED.

   Flutter 호출 시점:
   ConnectivityPlus → onConnectivityChanged
   → ONLINE 감지 → flush_offline_queue().';

comment on table catchmenu_common.offline_queue is
  '오프라인 액션 큐.
   "KT 터져도 멀쩡한 매장" 핵심 테이블.

   시나리오:
   1. KT 장애 → SKT LTE 자동 전환
      (report_network_status SWITCHED)
   2. 모든 통신 두절 → 오프라인 모드
      (Flutter SQLite 로컬 운영)
   3. 주문/KDS/결제 → SQLite 저장
      + enqueue_offline_action()
   4. 복구 → flush_offline_queue()
      → 서버 자동 동기화

   Flutter 구현:
   connectivity_plus: 연결 상태 감지
   Hive AES-256: 로컬 데이터 암호화
   WorkManager: 백그라운드 동기화

   소문의 근거:
   이 큐 테이블이 채워지고 비워지는
   이력이 곧 "장애에도 버텼다" 증거.
   특허1: 오프라인 이력 = 감사 증빙.';
