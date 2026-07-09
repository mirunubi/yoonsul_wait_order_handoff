-- 0083_create_push_notification_rpc.sql
-- Purpose: Customer push notification and FCM integration RPCs.
--          Push token management, notification templates,
--          bulk notification, notification history.
--          1-B차 고객 앱 푸시 알림 기반.
-- Depends on: 0082_create_saas_billing_rpc.sql
-- Creates:
--   catchmenu_store.push_notification_templates (table)
--   catchmenu_store.push_notification_log (table)
--   function catchmenu_store.send_push_notification(...)
--   function catchmenu_store.send_bulk_push(...)
--   function catchmenu_store.send_order_status_push(...)
--   function catchmenu_store.get_notification_history(...)
--   function catchmenu_store.create_push_template(...)

-- =============================================
-- push_notification_templates table
-- 푸시 알림 템플릿 (i18n)
-- =============================================
create table if not exists
  catchmenu_store.push_notification_templates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 템플릿 식별
  template_code text not null,
  template_name text not null,
  notification_type text not null,
  trigger_event text not null,

  -- 내용 (다국어)
  title_ko text not null,
  body_ko text not null,
  title_en text,
  body_en text,
  title_zh text,
  body_zh text,
  title_ja text,
  body_ja text,

  -- 딥링크
  deep_link text,
  action_type text default 'OPEN_APP',

  -- 발송 설정
  is_silent boolean not null default false,
  badge_count int,
  sound text default 'default',
  priority text not null default 'HIGH',

  -- 발송 조건
  send_condition jsonb default '{}'::jsonb,
  cooldown_minutes int default 0,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_push_template unique (
    tenant_id, template_code
  ),
  constraint chk_notification_type check (
    notification_type in (
      'ORDER_STATUS',    -- 주문 상태 변경
      'PICKUP_READY',    -- 픽업 준비 완료
      'WAITING_CALL',    -- 대기 호출
      'POINT_EARNED',    -- 포인트 적립
      'COUPON_ISSUED',   -- 쿠폰 발급
      'PROMOTION',       -- 프로모션 알림
      'STORE_NOTICE',    -- 매장 공지
      'SYSTEM'           -- 시스템 알림
    )
  ),
  constraint chk_push_priority check (
    priority in ('HIGH', 'NORMAL', 'LOW')
  ),
  constraint chk_action_type check (
    action_type in (
      'OPEN_APP', 'OPEN_ORDER',
      'OPEN_COUPON', 'OPEN_PROMOTION',
      'OPEN_NOTICE', 'OPEN_HOME'
    )
  )
);

create index if not exists idx_push_templates_tenant
  on catchmenu_store.push_notification_templates(
    tenant_id, notification_type
  ) where is_active = true;

alter table
  catchmenu_store.push_notification_templates
  enable row level security;
alter table
  catchmenu_store.push_notification_templates
  force row level security;

drop policy if exists push_templates_isolation
  on catchmenu_store.push_notification_templates;
create policy push_templates_isolation
  on catchmenu_store.push_notification_templates
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_push_templates_updated
  on catchmenu_store.push_notification_templates;
create trigger trg_push_templates_updated
  before update on
    catchmenu_store.push_notification_templates
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.push_notification_templates is
  '푸시 알림 템플릿 (다국어).
   {param} 형식으로 파라미터 치환.
   예: "주문 {order_number}이 준비되었습니다"
   trigger_event: 발송 트리거 이벤트.
   deep_link: 앱 내 특정 화면으로 이동.
   cooldown_minutes: 동일 알림 재발송 방지.
   1-B차 고객 앱 푸시 알림 기반.';


-- seed push templates
insert into catchmenu_store.push_notification_templates (
  tenant_id,
  template_code, template_name,
  notification_type, trigger_event,
  title_ko, body_ko, title_en, body_en,
  title_zh, body_zh, title_ja, body_ja,
  deep_link, action_type, priority
)
select
  '00000000-0000-0000-0000-000000000001'::uuid,
  t.template_code, t.template_name,
  t.notification_type, t.trigger_event,
  t.title_ko, t.body_ko,
  t.title_en, t.body_en,
  t.title_zh, t.body_zh,
  t.title_ja, t.body_ja,
  t.deep_link, t.action_type, t.priority
from (
  values
  (
    'TAKEOUT_CONFIRMED',
    '포장 주문 확인',
    'ORDER_STATUS',
    'takeout_order_placed',
    '주문 접수 완료',
    '{order_number}번 주문이 접수되었습니다.',
    'Order Confirmed',
    'Order #{order_number} has been received.',
    '订单已确认',
    '{order_number}号订单已接受。',
    'ご注文確認',
    '{order_number}番のご注文を受け付けました。',
    'catchmenu://order/{order_id}',
    'OPEN_ORDER', 'HIGH'
  ),
  (
    'PICKUP_READY',
    '픽업 준비 완료',
    'PICKUP_READY',
    'order_ready',
    '포장 준비 완료!',
    '{order_number}번 포장이 준비되었습니다. '
      || '카운터로 와주세요.',
    'Order Ready for Pickup!',
    'Order #{order_number} is ready. '
      || 'Please come to the counter.',
    '取餐准备好了！',
    '{order_number}号，请到柜台取餐。',
    '商品の準備ができました！',
    '{order_number}番、カウンターへどうぞ。',
    'catchmenu://order/{order_id}',
    'OPEN_ORDER', 'HIGH'
  ),
  (
    'ORDER_CANCELLED',
    '주문 취소',
    'ORDER_STATUS',
    'order_cancelled',
    '주문이 취소되었습니다',
    '{order_number}번 주문이 취소되었습니다.',
    'Order Cancelled',
    'Order #{order_number} has been cancelled.',
    '订单已取消',
    '{order_number}号订单已取消。',
    'ご注文がキャンセルされました',
    '{order_number}番のご注文がキャンセルされました。',
    'catchmenu://order/{order_id}',
    'OPEN_ORDER', 'NORMAL'
  ),
  (
    'POINT_EARNED',
    '포인트 적립',
    'POINT_EARNED',
    'points_earned',
    '포인트가 적립되었습니다',
    '{point_amount}P 적립! 현재 잔액 {balance}P',
    'Points Earned!',
    '{point_amount}P earned! Balance: {balance}P',
    '积分已添加',
    '已积{point_amount}分！余额{balance}分',
    'ポイント積立',
    '{point_amount}Pが積立されました！'
      || '残高{balance}P',
    'catchmenu://mypage/points',
    'OPEN_HOME', 'NORMAL'
  ),
  (
    'COUPON_ISSUED',
    '쿠폰 발급',
    'COUPON_ISSUED',
    'coupon_issued',
    '쿠폰이 발급되었습니다!',
    '{coupon_name} 쿠폰이 발급되었습니다.',
    'Coupon Issued!',
    'You received {coupon_name} coupon.',
    '优惠券已发放！',
    '您获得了{coupon_name}优惠券。',
    'クーポンが発行されました！',
    '{coupon_name}クーポンが発行されました。',
    'catchmenu://mypage/coupons',
    'OPEN_COUPON', 'NORMAL'
  ),
  (
    'PROMOTION_ALERT',
    '프로모션 알림',
    'PROMOTION',
    'promotion_started',
    '특별 혜택 안내!',
    '{promotion_name} 이벤트가 시작되었습니다.',
    'Special Offer!',
    '{promotion_name} event has started.',
    '特别优惠！',
    '{promotion_name}活动已开始。',
    'お得なお知らせ！',
    '{promotion_name}イベントが始まりました。',
    'catchmenu://promotions',
    'OPEN_PROMOTION', 'NORMAL'
  )
) as t(
  template_code, template_name,
  notification_type, trigger_event,
  title_ko, body_ko, title_en, body_en,
  title_zh, body_zh, title_ja, body_ja,
  deep_link, action_type, priority
)
on conflict (tenant_id, template_code)
do nothing;


-- =============================================
-- push_notification_log table
-- 푸시 알림 발송 이력
-- =============================================
create table if not exists
  catchmenu_store.push_notification_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- 수신자
  customer_id uuid
    references catchmenu_store.customers(id),
  push_token text,

  -- 알림 내용
  template_code text,
  notification_type text not null,
  title text not null,
  body text not null,
  locale text not null default 'ko',
  data_payload jsonb default '{}'::jsonb,
  deep_link text,

  -- FCM 발송 정보
  fcm_message_id text,
  fcm_response jsonb,

  -- 연결 주문/이벤트
  order_id uuid,
  session_id uuid,
  promotion_id uuid,

  -- 결과
  send_status text not null default 'PENDING',
  sent_at timestamptz,
  delivered_at timestamptz,
  read_at timestamptz,
  error_message text,
  retry_count int not null default 0,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_send_status check (
    send_status in (
      'PENDING', 'SENT', 'DELIVERED',
      'READ', 'FAILED', 'SKIPPED',
      'INVALID_TOKEN'
    )
  )
);

create index if not exists idx_push_log_customer
  on catchmenu_store.push_notification_log(
    customer_id, created_at desc
  ) where customer_id is not null;
create index if not exists idx_push_log_order
  on catchmenu_store.push_notification_log(
    order_id
  ) where order_id is not null;
create index if not exists idx_push_log_status
  on catchmenu_store.push_notification_log(
    send_status, created_at desc
  ) where send_status in ('PENDING', 'FAILED');
create index if not exists idx_push_log_tenant
  on catchmenu_store.push_notification_log(
    tenant_id, business_day desc
  );

alter table catchmenu_store.push_notification_log
  enable row level security;
alter table catchmenu_store.push_notification_log
  force row level security;

drop policy if exists push_log_isolation
  on catchmenu_store.push_notification_log;
create policy push_log_isolation
  on catchmenu_store.push_notification_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_push_log_updated
  on catchmenu_store.push_notification_log;
create trigger trg_push_log_updated
  before update on
    catchmenu_store.push_notification_log
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.push_notification_log is
  '푸시 알림 발송 이력.
   append-only 로그.
   fcm_message_id: FCM 발송 ID.
   INVALID_TOKEN: 토큰 만료 → 자동 무효화.
   read_at: 고객이 알림 클릭 시 기록.
   특허4: 알림 발송 = 감사 추적 가능.
   Edge Function (FCM)이 send_status 업데이트.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.create_push_template(
  p_tenant_id uuid,
  p_template_code text,
  p_template_name text,
  p_notification_type text,
  p_trigger_event text,
  p_title_ko text,
  p_body_ko text,
  p_title_en text default null,
  p_body_en text default null,
  p_deep_link text default null,
  p_action_type text default 'OPEN_APP',
  p_priority text default 'NORMAL',
  p_cooldown_minutes int default 0
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_template_id uuid;
  v_is_new boolean;
begin
  v_is_new := not exists (
    select 1
    from catchmenu_store.push_notification_templates
    where tenant_id = p_tenant_id
      and template_code = p_template_code
  );

  insert into
    catchmenu_store.push_notification_templates (
    tenant_id, template_code, template_name,
    notification_type, trigger_event,
    title_ko, body_ko,
    title_en, body_en,
    deep_link, action_type,
    priority, cooldown_minutes
  ) values (
    p_tenant_id, p_template_code,
    p_template_name,
    p_notification_type, p_trigger_event,
    p_title_ko, p_body_ko,
    p_title_en, p_body_en,
    p_deep_link, p_action_type,
    p_priority, p_cooldown_minutes
  )
  on conflict (tenant_id, template_code)
  do update set
    template_name = excluded.template_name,
    title_ko = excluded.title_ko,
    body_ko = excluded.body_ko,
    title_en = coalesce(
      excluded.title_en,
      push_notification_templates.title_en
    ),
    body_en = coalesce(
      excluded.body_en,
      push_notification_templates.body_en
    ),
    deep_link = excluded.deep_link,
    priority = excluded.priority,
    cooldown_minutes = excluded.cooldown_minutes,
    is_active = true,
    updated_at = now()
  returning id into v_template_id;

  return jsonb_build_object(
    'success', true,
    'template_id', v_template_id,
    'template_code', p_template_code,
    'is_new', v_is_new,
    'message_code', 'push_template_saved'
  );
end;
$$;


create or replace function
  catchmenu_store.send_push_notification(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_template_code text,
  p_params jsonb default null,
  p_order_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_template record;
  v_session record;
  v_push_token text;
  v_log_id uuid;
  v_title text;
  v_body text;
  v_business_day date;
  v_param_key text;
  v_param_value text;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 템플릿 조회
  select id, notification_type,
         template_code,
         title_ko, body_ko,
         title_en, body_en,
         title_zh, body_zh,
         title_ja, body_ja,
         deep_link, action_type, priority,
         cooldown_minutes, is_silent, sound
  into v_template
  from catchmenu_store.push_notification_templates
  where tenant_id = p_tenant_id
    and template_code = p_template_code
    and is_active = true;

  if v_template.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'template_not_found',
      'template_code', p_template_code
    );
  end if;

  -- 푸시 토큰 조회
  select push_token, locale
  into v_session
  from catchmenu_store.customer_app_sessions
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and session_status = 'ACTIVE'
    and push_enabled = true
    and push_token is not null
  order by last_active_at desc
  limit 1;

  if v_session.push_token is null then
    -- 토큰 없음 → SKIPPED 기록
    insert into
      catchmenu_store.push_notification_log (
      tenant_id, store_id, customer_id,
      template_code, notification_type,
      title, body, locale,
      order_id, send_status,
      business_day
    ) values (
      p_tenant_id, p_store_id, p_customer_id,
      p_template_code, v_template.notification_type,
      'N/A', 'No push token',
      p_locale, p_order_id, 'SKIPPED',
      v_business_day
    );

    return jsonb_build_object(
      'success', false,
      'skipped', true,
      'reason', 'no_push_token'
    );
  end if;

  -- 쿨다운 확인
  if v_template.cooldown_minutes > 0 then
    if exists (
      select 1
      from catchmenu_store.push_notification_log
      where customer_id = p_customer_id
        and template_code = p_template_code
        and send_status in ('SENT', 'DELIVERED')
        and created_at > now()
          - (v_template.cooldown_minutes
            || ' minutes')::interval
    ) then
      return jsonb_build_object(
        'success', false,
        'skipped', true,
        'reason', 'cooldown_active',
        'cooldown_minutes',
          v_template.cooldown_minutes
      );
    end if;
  end if;

  -- locale 기반 제목/내용 선택
  v_title := coalesce(
    case coalesce(
      v_session.locale, p_locale
    )
      when 'en' then v_template.title_en
      when 'zh' then v_template.title_zh
      when 'ja' then v_template.title_ja
      else null
    end,
    v_template.title_ko
  );

  v_body := coalesce(
    case coalesce(
      v_session.locale, p_locale
    )
      when 'en' then v_template.body_en
      when 'zh' then v_template.body_zh
      when 'ja' then v_template.body_ja
      else null
    end,
    v_template.body_ko
  );

  -- 파라미터 치환
  if p_params is not null then
    for v_param_key, v_param_value in
      select key, value::text
      from jsonb_each_text(p_params)
    loop
      v_title := replace(
        v_title, '{' || v_param_key || '}',
        v_param_value
      );
      v_body := replace(
        v_body, '{' || v_param_key || '}',
        v_param_value
      );
    end loop;
  end if;

  -- 발송 로그 생성 (FCM은 Edge Function이 처리)
  insert into
    catchmenu_store.push_notification_log (
    tenant_id, store_id, customer_id,
    push_token, template_code,
    notification_type, title, body,
    locale, data_payload, deep_link,
    order_id, send_status,
    business_day
  ) values (
    p_tenant_id, p_store_id, p_customer_id,
    v_session.push_token, p_template_code,
    v_template.notification_type,
    v_title, v_body,
    coalesce(v_session.locale, p_locale),
    coalesce(p_params, '{}'::jsonb),
    replace(
      coalesce(v_template.deep_link, ''),
      '{order_id}',
      coalesce(p_order_id::text, '')
    ),
    p_order_id, 'PENDING',
    v_business_day
  )
  returning id into v_log_id;

  -- Realtime → Edge Function에 FCM 발송 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'push_notification_queued',
    p_payload := jsonb_build_object(
      'log_id', v_log_id,
      'push_token', v_session.push_token,
      'title', v_title,
      'body', v_body,
      'notification_type',
        v_template.notification_type,
      'data', coalesce(p_params, '{}'::jsonb),
      'deep_link', v_template.deep_link,
      'priority', v_template.priority,
      'is_silent', v_template.is_silent,
      'sound', v_template.sound
    )
  );

  return jsonb_build_object(
    'success', true,
    'log_id', v_log_id,
    'customer_id', p_customer_id,
    'template_code', p_template_code,
    'title', v_title,
    'send_status', 'PENDING',
    'message_code', 'push_notification_queued'
  );
end;
$$;


create or replace function
  catchmenu_store.send_order_status_push(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_order_status text,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_order record;
  v_template_code text;
  v_params jsonb;
  v_push_result jsonb;
begin
  -- 주문 정보
  select o.id, o.order_number, o.order_status,
         o.final_amount,
         os.customer_id
  into v_order
  from catchmenu_pos.orders o
  join catchmenu_pos.order_sessions os
    on os.id = o.session_id
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null
    or v_order.customer_id is null
  then
    return jsonb_build_object(
      'success', false,
      'skipped', true,
      'reason', case
        when v_order.id is null
          then 'order_not_found'
        else 'no_customer'
      end
    );
  end if;

  -- 상태별 템플릿 선택
  v_template_code := case p_order_status
    when 'CONFIRMED' then 'TAKEOUT_CONFIRMED'
    when 'READY' then 'PICKUP_READY'
    when 'CANCELLED' then 'ORDER_CANCELLED'
    else null
  end;

  if v_template_code is null then
    return jsonb_build_object(
      'success', false,
      'skipped', true,
      'reason', 'no_template_for_status',
      'order_status', p_order_status
    );
  end if;

  -- 파라미터 구성
  v_params := jsonb_build_object(
    'order_number', v_order.order_number,
    'order_id', v_order.id,
    'final_amount', v_order.final_amount
  );

  -- 푸시 발송
  v_push_result :=
    catchmenu_store.send_push_notification(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_customer_id := v_order.customer_id,
      p_template_code := v_template_code,
      p_params := v_params,
      p_order_id := p_order_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  return jsonb_build_object(
    'success', (v_push_result->>'success')::boolean,
    'order_id', p_order_id,
    'order_status', p_order_status,
    'template_code', v_template_code,
    'push_result', v_push_result
  );
end;
$$;


create or replace function
  catchmenu_store.send_bulk_push(
  p_tenant_id uuid,
  p_store_id uuid,
  p_template_code text,
  p_customer_ids jsonb,
  p_params jsonb default null,
  p_filter_tier text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_customer_id uuid;
  v_sent int := 0;
  v_skipped int := 0;
  v_failed int := 0;
  v_result jsonb;
  v_customer_list jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 고객 목록 결정
  if jsonb_array_length(
    coalesce(p_customer_ids, '[]'::jsonb)
  ) > 0 then
    -- 명시적 고객 목록
    v_customer_list := p_customer_ids;
  else
    -- 필터 기반 (티어, 활성 구독 등)
    select coalesce(
      jsonb_agg(c.id),
      '[]'::jsonb
    )
    into v_customer_list
    from catchmenu_store.customers c
    join catchmenu_store.customer_app_sessions cas
      on cas.customer_id = c.id
    where c.tenant_id = p_tenant_id
      and c.is_active = true
      and cas.push_enabled = true
      and cas.push_token is not null
      and cas.session_status = 'ACTIVE'
      and (
        p_filter_tier is null
        or c.membership_tier = p_filter_tier
      )
    limit 500; -- 안전 한도
  end if;

  if jsonb_array_length(v_customer_list) = 0 then
    return jsonb_build_object(
      'success', true,
      'sent', 0,
      'skipped', 0,
      'total', 0,
      'reason', 'no_eligible_customers'
    );
  end if;

  -- 개별 발송
  for v_customer_id in
    select jsonb_array_elements_text(
      v_customer_list
    )::uuid
  loop
    begin
      v_result := catchmenu_store
        .send_push_notification(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_customer_id := v_customer_id,
          p_template_code := p_template_code,
          p_params := p_params,
          p_correlation_id := p_correlation_id
        );

      if (v_result->>'success')::boolean then
        v_sent := v_sent + 1;
      elsif (v_result->>'skipped')::boolean then
        v_skipped := v_skipped + 1;
      else
        v_failed := v_failed + 1;
      end if;

    exception when others then
      v_failed := v_failed + 1;
    end;
  end loop;

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'bulk_push_completed',
    p_message :=
      '대량 푸시 발송 완료'
      || ' | 템플릿=' || p_template_code
      || ' | 발송=' || v_sent
      || ' | 건너뜀=' || v_skipped
      || ' | 실패=' || v_failed,
    p_rpc_name := 'send_bulk_push',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'template_code', p_template_code,
      'total_target',
        jsonb_array_length(v_customer_list),
      'sent', v_sent,
      'skipped', v_skipped,
      'failed', v_failed
    )
  );

  return jsonb_build_object(
    'success', v_failed = 0,
    'template_code', p_template_code,
    'total_target',
      jsonb_array_length(v_customer_list),
    'sent', v_sent,
    'skipped', v_skipped,
    'failed', v_failed,
    'business_day', v_business_day,
    'message_code', 'bulk_push_completed'
  );
end;
$$;


create or replace function
  catchmenu_store.get_notification_history(
  p_tenant_id uuid,
  p_customer_id uuid,
  p_limit int default 20,
  p_offset int default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_notifications jsonb;
  v_total int;
  v_unread int;
begin
  select count(*)
  into v_total
  from catchmenu_store.push_notification_log
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and send_status not in (
      'SKIPPED', 'INVALID_TOKEN', 'FAILED'
    );

  select count(*)
  into v_unread
  from catchmenu_store.push_notification_log
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and send_status in ('SENT', 'DELIVERED')
    and read_at is null;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'log_id', id,
        'notification_type', notification_type,
        'template_code', template_code,
        'title', title,
        'body', body,
        'deep_link', deep_link,
        'send_status', send_status,
        'is_read', read_at is not null,
        'order_id', order_id,
        'sent_at', sent_at,
        'created_at', created_at
      )
      order by created_at desc
    ),
    '[]'::jsonb
  )
  into v_notifications
  from catchmenu_store.push_notification_log
  where customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and send_status not in (
      'SKIPPED', 'INVALID_TOKEN'
    )
  order by created_at desc
  limit p_limit
  offset p_offset;

  return jsonb_build_object(
    'success', true,
    'customer_id', p_customer_id,
    'total', v_total,
    'unread', v_unread,
    'notifications', v_notifications,
    'message_code', 'notification_history_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.mark_notification_read(
  p_tenant_id uuid,
  p_customer_id uuid,
  p_log_id uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_updated int;
begin
  update catchmenu_store.push_notification_log
  set
    read_at = now(),
    send_status = 'READ',
    updated_at = now()
  where id = p_log_id
    and customer_id = p_customer_id
    and tenant_id = p_tenant_id
    and read_at is null;

  get diagnostics v_updated = row_count;

  return jsonb_build_object(
    'success', v_updated > 0,
    'log_id', p_log_id,
    'message_code', case v_updated
      when 0 then 'already_read'
      else 'notification_read'
    end
  );
end;
$$;


-- FCM Edge Function 등록
insert into catchmenu_common.edge_function_registry (
  function_code, function_name, function_path,
  function_method, trigger_type,
  requires_auth, timeout_seconds,
  rate_limit_per_minute,
  flutter_invoke_name
) values
(
  'FCM_PUSH_SENDER',
  'FCM 푸시 알림 발송',
  '/functions/v1/fcm-push',
  'POST', 'HTTP',
  true, 10, 200,
  'fcm-push'
)
on conflict (tenant_id, function_code) do nothing;


-- Flutter SDK 패턴: 푸시 알림
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dependencies, dart_code
) values
(
  'FLUTTER_PUSH_NOTIFICATION',
  'FCM 푸시 알림 패턴',
  'RPC_CALL',
  '["CUSTOMER_APP"]'::jsonb,
  '고객 앱 FCM 토큰 등록 + 알림 수신 처리',
  ('["supabase_flutter: ^2.0.0",'
  || '"firebase_messaging: ^14.0.0",'
  || '"flutter_local_notifications: ^17.0.0"]')::jsonb,
  $dart$
// lib/services/push_notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final _supabase = Supabase.instance.client;
  final _fcm = FirebaseMessaging.instance;

  // FCM 토큰 등록
  Future<void> registerToken({
    required String tenantId,
    required String customerId,
  }) async {
    // 권한 요청
    final settings =
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

    if (settings.authorizationStatus
        != AuthorizationStatus.authorized) {
      return;
    }

    // 토큰 가져오기
    final token = await _fcm.getToken();
    if (token == null) return;

    // Supabase에 토큰 등록
    await _supabase.rpc(
      'register_customer_push_token',
      params: {
        'p_tenant_id': tenantId,
        'p_customer_id': customerId,
        'p_push_token': token,
        'p_os_type': Platform.isIOS
          ? 'IOS' : 'ANDROID',
      },
    );

    // 토큰 갱신 리스너
    _fcm.onTokenRefresh.listen((newToken) async {
      await _supabase.rpc(
        'register_customer_push_token',
        params: {
          'p_tenant_id': tenantId,
          'p_customer_id': customerId,
          'p_push_token': newToken,
        },
      );
    });
  }

  // 포그라운드 메시지 처리
  void initForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      // 로컬 알림 표시
      _showLocalNotification(message);

      // 딥링크 처리
      final deepLink =
        message.data['deep_link'] as String?;
      if (deepLink != null) {
        _handleDeepLink(deepLink);
      }
    });
  }

  // 백그라운드 메시지 처리
  static Future<void> backgroundHandler(
    RemoteMessage message
  ) async {
    // 백그라운드에서는 FCM이 자동 처리
    print('[FCM] Background: ${message.data}');
  }

  // 알림 읽음 처리
  Future<void> markAsRead({
    required String tenantId,
    required String customerId,
    required String logId,
  }) async {
    await _supabase.rpc(
      'mark_notification_read',
      params: {
        'p_tenant_id': tenantId,
        'p_customer_id': customerId,
        'p_log_id': logId,
      },
    );
  }

  void _showLocalNotification(
    RemoteMessage message
  ) {
    // flutter_local_notifications 사용
    // 구현 생략 (앱별 커스터마이징)
  }

  void _handleDeepLink(String deepLink) {
    // catchmenu://order/{id} 등 처리
    // go_router 연동
  }
}
$dart$
)
on conflict (pattern_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.create_push_template(
      uuid, text, text, text, text,
      text, text, text, text, text, text, text, int
    ) from public;
  grant execute on function
    catchmenu_store.create_push_template(
      uuid, text, text, text, text,
      text, text, text, text, text, text, text, int
    ) to authenticated;

  revoke all on function
    catchmenu_store.send_push_notification(
      uuid, uuid, uuid, text, jsonb,
      uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.send_push_notification(
      uuid, uuid, uuid, text, jsonb,
      uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.send_order_status_push(
      uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.send_order_status_push(
      uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.send_bulk_push(
      uuid, uuid, text, jsonb, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_store.send_bulk_push(
      uuid, uuid, text, jsonb, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_notification_history(
      uuid, uuid, int, int
    ) from public;
  grant execute on function
    catchmenu_store.get_notification_history(
      uuid, uuid, int, int
    ) to authenticated;

  revoke all on function
    catchmenu_store.mark_notification_read(
      uuid, uuid, uuid
    ) from public;
  grant execute on function
    catchmenu_store.mark_notification_read(
      uuid, uuid, uuid
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.send_push_notification(
    uuid, uuid, uuid, text, jsonb,
    uuid, text, text
  ) is
  '단일 고객 푸시 알림 발송.
   처리 흐름:
   1. 템플릿 조회 (i18n)
   2. 고객 푸시 토큰 조회
   3. 쿨다운 확인
   4. 파라미터 치환
   5. push_notification_log 생성 (PENDING)
   6. Realtime → Edge Function FCM 발송 요청

   FCM 실제 발송:
   Edge Function(fcm-push)이 FCM API 호출.
   발송 완료 후 log.send_status = SENT.

   INVALID_TOKEN: 토큰 만료 → 자동 SKIPPED.
   cooldown_minutes: 중복 발송 방지.
   1-B차 고객 앱 푸시 알림 핵심 기능.';

comment on function
  catchmenu_store.send_bulk_push(
    uuid, uuid, text, jsonb, jsonb, text, text
  ) is
  '대량 푸시 알림 발송.
   p_customer_ids 비어있으면 필터 기반 자동 선택.
   p_filter_tier: 특정 멤버십 티어만 발송.
   안전 한도: 500명.
   개별 send_push_notification() 순차 호출.
   1-B차 프로모션 알림 일괄 발송.
   예: 프로모션 시작 → 전체 고객 알림.';