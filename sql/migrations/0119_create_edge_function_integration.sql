-- 0119_create_edge_function_integration.sql
-- Purpose: Edge Function integration guide
--          and Realtime channel completion.
--          Edge Function 트리거 설정.
--          pg_net 연동 가이드.
--          Realtime 채널 전체 정리.
--          Flutter Realtime 핸들러 가이드.
-- Depends on: 0118_create_schema_validation_update.sql

-- =============================================
-- Edge Function 트리거 설정 테이블
-- =============================================
create table if not exists
  catchmenu_common.edge_function_configs (
  id uuid primary key default gen_random_uuid(),
  function_code text not null unique,
  function_name text not null,
  function_url text,
  trigger_event text not null,
  trigger_channel text not null,
  timeout_seconds int not null default 10,
  retry_count int not null default 3,
  priority text not null default 'P1',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_priority check (
    priority in ('P1', 'P2', 'P3')
  )
);

alter table catchmenu_common.edge_function_configs
  enable row level security;
alter table catchmenu_common.edge_function_configs
  force row level security;

drop policy if exists edge_fn_configs_read
  on catchmenu_common.edge_function_configs;
create policy edge_fn_configs_read
  on catchmenu_common.edge_function_configs
  for select to authenticated
  using (true);

-- Edge Function 시드
insert into catchmenu_common.edge_function_configs (
  function_code, function_name,
  trigger_event, trigger_channel,
  timeout_seconds, retry_count, priority
) values
('EF-001', 'okpos-order-send',
  'okpos_order_send_requested',
  'SYSTEM_EVENTS', 5, 3, 'P1'),
('EF-002', 'okpos-menu-fetch',
  'okpos_menu_fetch_requested',
  'SYSTEM_EVENTS', 30, 2, 'P1'),
('EF-003', 'toss-payments-confirm',
  'toss_payment_confirm_requested',
  'SYSTEM_EVENTS', 10, 3, 'P1'),
('EF-004', 'toss-payments-webhook',
  'toss_webhook_received',
  'SYSTEM_EVENTS', 5, 3, 'P1'),
('EF-005', 'toss-pos-order-send',
  'toss_pos_order_send_requested',
  'SYSTEM_EVENTS', 5, 3, 'P1'),
('EF-006', 'okpos-heartbeat',
  'okpos_heartbeat_check',
  'SYSTEM_EVENTS', 5, 1, 'P1'),
('EF-007', 'toss-pos-heartbeat',
  'toss_pos_heartbeat_check',
  'SYSTEM_EVENTS', 5, 1, 'P1'),
('EF-008', 'cash-receipt-nts',
  'cash_receipt_issue_requested',
  'SYSTEM_EVENTS', 10, 3, 'P2'),
('EF-009', 'delivery-webhook-baemin',
  'baemin_webhook_received',
  'SYSTEM_EVENTS', 5, 3, 'P2'),
('EF-010', 'delivery-webhook-yogiyo',
  'yogiyo_webhook_received',
  'SYSTEM_EVENTS', 5, 3, 'P2'),
('EF-011', 'delivery-webhook-coupang',
  'coupang_webhook_received',
  'SYSTEM_EVENTS', 5, 3, 'P2'),
('EF-012', 'sms-send',
  'sms_send_requested',
  'SYSTEM_EVENTS', 10, 2, 'P2'),
('EF-013', 'push-fcm',
  'push_notification_queued',
  'SYSTEM_EVENTS', 10, 3, 'P2'),
('EF-014', 'franchise-point-transfer',
  'franchise_point_transfer_requested',
  'SYSTEM_EVENTS', 15, 3, 'P2'),
('EF-015', 'yoonsul-point-transfer',
  'yoonsul_point_transfer_requested',
  'SYSTEM_EVENTS', 15, 3, 'P2'),
('EF-016', 'embedding-request',
  'document_embedding_requested',
  'SYSTEM_EVENTS', 60, 1, 'P3')
on conflict (function_code) do nothing;

comment on table
  catchmenu_common.edge_function_configs is
  'Edge Function 설정 레지스트리.
   trigger_event: notify_channel 이벤트명.
   trigger_channel: 구독 채널 타입.
   P1: MVP 필수 (1호점 오픈 전 구현).
   P2: 1-B차 (오픈 후 1개월 내).
   P3: 1-C차 (AI/임베딩).
   외주 개발자에게 이 테이블 기준으로 작업 지시.';


-- =============================================
-- Realtime 채널 전체 정리
-- =============================================
create or replace function
  catchmenu_common.get_realtime_channel_guide(
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
begin
  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(

      'channels', jsonb_build_object(

        -- KDS 채널
        'kds', jsonb_build_object(
          'channel_name',
            'kds:' || p_store_id,
          'subscribers',
            jsonb_build_array(
              'KDS_DISPLAY 앱',
              '직원 앱 (주방 담당)'
            ),
          'events', jsonb_build_array(
            jsonb_build_object(
              'event', 'kds_tickets_released',
              'trigger',
                'release_kds_after_payment()',
              'payload',
                'order_id, ticket_ids, table_number'
            ),
            jsonb_build_object(
              'event', 'kds_ticket_updated',
              'trigger',
                'transition_kds_ticket()',
              'payload',
                'ticket_id, old_status, new_status'
            ),
            jsonb_build_object(
              'event', 'kds_overloaded',
              'trigger', 'check_kds_capacity()',
              'payload', 'current_count, threshold'
            )
          )
        ),

        -- 직원 알림 채널
        'staff', jsonb_build_object(
          'channel_name',
            'staff:' || p_store_id,
          'subscribers',
            jsonb_build_array('직원 앱 전체'),
          'events', jsonb_build_array(
            jsonb_build_object(
              'event', 'takeout_order_received',
              'trigger',
                'place_kiosk_order() / place_order()',
              'payload',
                'order_number, total_amount, source'
            ),
            jsonb_build_object(
              'event', 'network_status_changed',
              'trigger',
                'report_network_status()',
              'payload',
                'network_status, switched_from/to'
            ),
            jsonb_build_object(
              'event', 'store_settings_changed',
              'trigger',
                'update_store_settings()',
              'payload',
                'updated_settings'
            ),
            jsonb_build_object(
              'event', 'menu_status_changed',
              'trigger', 'set_menu_status()',
              'payload',
                'menu_ids, new_status'
            )
          )
        ),

        -- 대기 채널
        'waiting', jsonb_build_object(
          'channel_name',
            'waiting:' || p_store_id,
          'subscribers', jsonb_build_array(
            '직원 앱 (대기 관리)',
            'DID 디스플레이',
            '고객 앱'
          ),
          'events', jsonb_build_array(
            jsonb_build_object(
              'event',
                'waiting_session_created',
              'trigger', 'register_waiting()',
              'payload',
                'wait_number, queue_position'
            ),
            jsonb_build_object(
              'event', 'waiting_called',
              'trigger',
                'call_waiting_customer()',
              'payload',
                'wait_number, table_number'
            ),
            jsonb_build_object(
              'event',
                'waiting_session_seated',
              'trigger',
                'seat_waiting_customer()',
              'payload',
                'wait_number, remaining_queue'
            ),
            jsonb_build_object(
              'event',
                'waiting_session_cancelled',
              'trigger',
                'cancel_waiting() / mark_no_show()',
              'payload', 'wait_number, reason'
            )
          )
        ),

        -- 매장 모드 채널
        'store', jsonb_build_object(
          'channel_name',
            'store:' || p_store_id,
          'subscribers', jsonb_build_array(
            '직원 앱', '키오스크', '고객 앱'
          ),
          'events', jsonb_build_array(
            jsonb_build_object(
              'event', 'store_mode_changed',
              'trigger', 'change_store_mode()',
              'payload', 'old_mode, new_mode'
            ),
            jsonb_build_object(
              'event', 'menu_updated',
              'trigger', 'upsert_menu()',
              'payload', 'menu_id, is_new'
            )
          )
        ),

        -- DID 채널
        'did', jsonb_build_object(
          'channel_name',
            'did:' || p_store_id,
          'subscribers',
            jsonb_build_array('DID 디스플레이'),
          'events', jsonb_build_array(
            jsonb_build_object(
              'event', 'WAITING_CALL',
              'trigger',
                'call_waiting_customer()',
              'payload',
                'display_number, table_number'
            ),
            jsonb_build_object(
              'event', 'call_dismissed',
              'trigger',
                'seat_waiting_customer() / dismiss_did_call()',
              'payload', 'wait_number'
            )
          )
        ),

        -- 고객 앱 채널
        'customer_app', jsonb_build_object(
          'channel_name',
            'customer_app:' || p_store_id,
          'subscribers',
            jsonb_build_array('고객 앱'),
          'events', jsonb_build_array(
            jsonb_build_object(
              'event', 'tier_upgraded',
              'trigger',
                'earn_points_after_order()',
              'payload',
                'old_tier, new_tier'
            ),
            jsonb_build_object(
              'event', 'stamp_reward_issued',
              'trigger', 'stamp_visit()',
              'payload',
                'current_stamps, reward_coupon_id'
            ),
            jsonb_build_object(
              'event', 'stamp_added',
              'trigger', 'stamp_visit()',
              'payload',
                'stamps_added, current_stamps'
            )
          )
        ),

        -- 시스템 이벤트 채널
        'system_events', jsonb_build_object(
          'channel_name',
            'system_events:' || p_store_id,
          'subscribers',
            jsonb_build_array(
              'Edge Functions',
              'pg_net 웹훅'
            ),
          'events', jsonb_build_array(
            'okpos_order_send_requested',
            'toss_payment_confirm_requested',
            'cash_receipt_issue_requested',
            'push_notification_queued',
            'franchise_point_transfer_requested',
            'yoonsul_point_transfer_requested',
            'document_embedding_requested'
          )
        )
      ),

      -- Flutter 구독 패턴
      'flutter_guide', jsonb_build_object(
        'staff_app', jsonb_build_array(
          'staff:{store_id}',
          'kds:{store_id}',
          'waiting:{store_id}',
          'store:{store_id}'
        ),
        'kds_display', jsonb_build_array(
          'kds:{store_id}'
        ),
        'did_display', jsonb_build_array(
          'did:{store_id}',
          'waiting:{store_id}'
        ),
        'customer_app', jsonb_build_array(
          'customer_app:{store_id}'
        ),
        'mini_kiosk', jsonb_build_array(
          'store:{store_id}'
        )
      ),

      'note',
        'store_id를 실제 UUID로 치환하여 사용'
    )
  );
end;
$$;

grant execute on function
  catchmenu_common.get_realtime_channel_guide(uuid)
  to authenticated;


-- =============================================
-- Flutter 앱별 부트스트랩 매핑 문서
-- =============================================
insert into catchmenu_knowledge.documents (
  tenant_id, store_id,
  document_code, title,
  document_type, domain,
  content, content_locale,
  document_status, approved_at, published_at
) values (
  '00000000-0000-0000-0000-000000000001', null,
  'FLUTTER_BOOTSTRAP_MAP_001_KO',
  'Flutter 앱별 부트스트랩 매핑표',
  'GUIDE', 'flutter',
  $ko$
# Flutter 앱별 부트스트랩 매핑표

## 앱 타입별 시작 RPC

| 앱 타입 | 시작 RPC | Realtime 채널 |
|---------|----------|---------------|
| 직원 앱 | bootstrap_staff_app | staff + kds + waiting + store |
| KDS 디스플레이 | get_kds_realtime_state | kds |
| 미니 키오스크 | bootstrap_kiosk | store |
| DID 디스플레이 | bootstrap_did_app | did + waiting |
| 고객 앱 | bootstrap_customer_app_v2 | customer_app |

## 공통 시작 순서

1. health_check()
2. 디바이스 타입별 bootstrap RPC
3. Realtime 채널 구독
4. 30초 폴링 시작 (Realtime 백업)

## Edge Function P1 구현 (1호점 MVP)

| 코드 | 함수명 | 트리거 이벤트 |
|------|--------|---------------|
| EF-001 | okpos-order-send | okpos_order_send_requested |
| EF-002 | okpos-menu-fetch | okpos_menu_fetch_requested |
| EF-003 | toss-payments-confirm | toss_payment_confirm_requested |
| EF-004 | toss-payments-webhook | toss_webhook_received |
| EF-005 | toss-pos-order-send | toss_pos_order_send_requested |
| EF-006 | okpos-heartbeat | okpos_heartbeat_check |
| EF-007 | toss-pos-heartbeat | toss_pos_heartbeat_check |

## 특허 구현 RPC 흐름

### 특허1 + 특허2 결합 흐름
register_waiting → pre_order_while_waiting
→ call_waiting_customer → seat_waiting_customer
→ confirm_payment → release_kds_after_payment
→ KDS COMMITTED → 조리 시작
$ko$,
  'ko',
  'PUBLISHED', now(), current_date
),
(
  '00000000-0000-0000-0000-000000000001', null,
  'FLUTTER_BOOTSTRAP_MAP_001_EN',
  'Flutter 앱별 부트스트랩 매핑표',
  'GUIDE', 'flutter',
  $en$
# Flutter App Bootstrap Mapping

See Korean version for full table.
Key: each app type has one bootstrap RPC.
Patent 1+2 combined in pre_order_while_waiting.
$en$,
  'en',
  'PUBLISHED', now(), current_date
)
on conflict (tenant_id, document_code)
do update set
  content = excluded.content;

comment on function
  catchmenu_common.get_realtime_channel_guide(uuid)
  is
  'Realtime 채널 전체 가이드.
   Flutter 개발자 참고용.

   채널 목록:
   kds:{store_id}: KDS 상태 변경
   staff:{store_id}: 직원 알림
   waiting:{store_id}: 대기 현황
   store:{store_id}: 매장 설정/메뉴
   did:{store_id}: DID 호출
   customer_app:{store_id}: 고객 멤버십

   system_events:{store_id}:
     Edge Function 트리거 전용
     Flutter에서 구독 불필요

   DBeaver에서 확인:
   SELECT
     catchmenu_common
       .get_realtime_channel_guide(
         (SELECT id FROM catchmenu_hq.stores
          LIMIT 1)
       );';