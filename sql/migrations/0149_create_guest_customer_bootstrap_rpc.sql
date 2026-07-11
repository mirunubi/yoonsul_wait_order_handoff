-- 0149_create_guest_customer_bootstrap_rpc.sql
-- Purpose: Create the guest customer bootstrap helper and patch the two
--          existing customer-entry RPCs so omitted p_customer_id values are
--          filled through catchmenu_store.get_or_create_guest_customer().
-- Depends on: 0148_add_order_sessions_customer_id_and_guest_flag.sql
-- Creates:
--   catchmenu_store.get_or_create_guest_customer(uuid, text)
-- Patches via CREATE OR REPLACE FUNCTION:
--   catchmenu_pos.register_waiting(...)
--   catchmenu_store.bootstrap_customer_app_v2(...)
--
-- Human Boundary Approval: 600124_ChangeContract.md approved Stage 4.
-- Design source: 600122_Logic.md. The helper keeps is_guest out of the
-- ON CONFLICT DO UPDATE SET clause so an already-promoted customer is not
-- reverted to guest status by a later same-phone_hash guest bootstrap call.
-- Direct helper grants are intentionally not given to authenticated; callers
-- reach it only through the patched 0115/0116 SECURITY DEFINER RPCs.

create or replace function catchmenu_store.get_or_create_guest_customer(
  p_tenant_id uuid,
  p_phone_hash text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_store
as $$
declare
  v_customer_id uuid;
  v_customer_code text;
begin
  -- customer_code 생성: 0058 register_customer()의 패턴 재사용
  v_customer_code := 'C' || to_char(now(), 'YYMMDD')
    || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.customers
        where tenant_id = p_tenant_id
      )::text,
      6, '0'
    );

  if p_phone_hash is not null then
    insert into catchmenu_store.customers (
      tenant_id, customer_code,
      phone_hash, is_guest,
      preferred_locale, is_active,
      first_visit_at, last_visit_at
    ) values (
      p_tenant_id, v_customer_code,
      p_phone_hash, true,
      'ko', true,
      now(), now()
    )
    on conflict (tenant_id, phone_hash)
    do update set updated_at = now()
    returning id into v_customer_id;
  else
    -- phone_hash 없는 완전 익명: 매번 신규 row (Human 결정 #4)
    insert into catchmenu_store.customers (
      tenant_id, customer_code,
      is_guest,
      preferred_locale, is_active,
      first_visit_at, last_visit_at
    ) values (
      p_tenant_id, v_customer_code,
      true,
      'ko', true,
      now(), now()
    )
    returning id into v_customer_id;
  end if;

  return v_customer_id;
end;
$$;

create or replace function
  catchmenu_pos.register_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_guest_count int,
  p_session_type text default 'WAITING',
  p_guest_locale text default 'ko',
  p_phone_hash text default null,
  p_customer_id uuid default null,
  p_memo text default null,
  p_source text default 'STAFF',
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_wait_number int;
  v_queue_position int;
  v_session_id uuid;
  v_est_wait_minutes int;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정 확인
  select store_mode, waiting_enabled,
         max_wait_number
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 대기 비활성화 확인
  if coalesce(v_settings.store_mode, 'NORMAL')
    in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
    or not coalesce(
      v_settings.waiting_enabled, true
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_queue_disabled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 현재 대기 인원 확인
  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and session_type in (
      'WAITING', 'PRE_ORDER'
    );

  -- 대기 정원 초과
  if v_queue_position >=
    coalesce(v_settings.max_wait_number, 30)
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'wait_queue_full',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 오늘 대기 번호 채번
  select coalesce(
    max(wait_number), 0
  ) + 1
  into v_wait_number
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- p_customer_id가 없으면 게스트 헬퍼로 채운다 (600120 patch)
  if p_customer_id is null then
    p_customer_id := catchmenu_store.get_or_create_guest_customer(
      p_tenant_id := p_tenant_id,
      p_phone_hash := p_phone_hash
    );
  end if;

  -- 대기 세션 생성 (특허1 핵심)
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    wait_number, queue_position,
    guest_count, guest_locale,
    phone_hash, customer_id,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_type, 'WAITING',
    v_wait_number, v_queue_position + 1,
    p_guest_count, p_guest_locale,
    p_phone_hash, p_customer_id,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 예상 대기 시간 계산
  v_est_wait_minutes :=
    v_queue_position * 10;

  -- Realtime → 대기 화면 + DID 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_created',
    p_payload := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'source', p_source
    )
  );

  -- 고객 앱 푸시 알림 (전화번호 있는 경우)
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash,
        'customer_id', p_customer_id,
        'notification_type', 'WAITING_REGISTERED',
        'wait_number', v_wait_number,
        'queue_position', v_queue_position + 1,
        'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_registered', 1,
    'order_session', v_session_id,
    null, 'WAITING',
    p_source,
    jsonb_build_object(
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'session_type', p_session_type,
      'source', p_source
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_registered',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'pre_order_enabled',
        p_session_type = 'PRE_ORDER',
      'position_message',
        catchmenu_common.get_message(
          'waiting_current_position',
          p_guest_locale,
          jsonb_build_object(
            'position', v_queue_position + 1
          )
        ),
      'est_time_message',
        catchmenu_common.get_message(
          'waiting_est_time',
          p_guest_locale,
          jsonb_build_object(
            'minutes', v_est_wait_minutes
          )
        ),
      'registered_message',
        catchmenu_common.get_message(
          'waiting_registered',
          p_guest_locale,
          jsonb_build_object(
            'wait_number', v_wait_number
          )
        )
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function
  catchmenu_store.bootstrap_customer_app_v2(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid default null,
  p_phone_hash text default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_push_token text default null,
  p_os_type text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_store_settings record;
  v_customer record;
  v_membership jsonb;
  v_active_waiting jsonb;
  v_active_order jsonb;
  v_cms_bundle jsonb;
  v_menu_preview jsonb;
  v_business_day date;
  v_day_of_week int;
  v_business_hours record;
  v_is_open boolean;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;
  v_day_of_week := extract(
    dow from v_business_day
  )::int;

  -- 매장 정보
  select id, store_name, store_type, timezone
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
      p_rpc_name := 'bootstrap_customer_app_v2'
    );
  end if;

  -- 매장 설정
  -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was never
  -- a real column on catchmenu_store.store_settings (confirmed via
  -- \d catchmenu_store.store_settings -- no min_order_amount, no
  -- minimum_order_amount, no min_pre_order_amount equivalent). This
  -- SELECT would have failed at runtime with "column does not exist"
  -- on every call. The concept (minimum pre-order amount) was simply
  -- never implemented -- removed from this SELECT rather than mapped
  -- to a nonexistent column.
  select store_mode, waiting_enabled,
         pre_order_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 영업시간 확인
  select is_open, open_time, close_time,
         last_order_time
  into v_business_hours
  from catchmenu_store.store_business_hours
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and day_of_week = v_day_of_week;

  v_is_open := case
    when coalesce(
      v_store_settings.store_mode, 'NORMAL'
    ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
      then false
    when v_business_hours.is_open = false
      then false
    else true
  end;

  -- p_customer_id가 없으면 게스트 헬퍼로 채운다 (600120 patch)
  if p_customer_id is null then
    p_customer_id := catchmenu_store.get_or_create_guest_customer(
      p_tenant_id := p_tenant_id,
      p_phone_hash := p_phone_hash
    );
  end if;

  -- 고객 정보 + 멤버십
  if p_customer_id is not null then
    select id, display_name, membership_tier,
           point_balance, visit_count,
           last_visit_at, preferred_locale
    into v_customer
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_customer.id is not null then
      -- 멤버십 조회
      v_membership := (
        catchmenu_store.get_customer_membership(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_customer_id := p_customer_id,
          p_locale := p_locale
        )
      )->'data';

      -- 현재 대기 세션 확인
      select jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'queue_position', (
          select count(*)
          from catchmenu_pos.order_sessions
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and business_day = v_business_day
            and session_status in (
              'WAITING', 'ARRIVAL_PENDING'
            )
            and wait_number < os.wait_number
        ),
        'has_pre_order',
          false,
        'pre_order_amount',
          0
      )
      into v_active_waiting
      from catchmenu_pos.order_sessions os
      where os.store_id = p_store_id
        and os.tenant_id = p_tenant_id
        and os.customer_id = p_customer_id
        and os.business_day = v_business_day
        and os.session_status in (
          'WAITING', 'ARRIVAL_PENDING', 'SEATED'
        )
      order by os.session_started_at desc
      limit 1;

      -- 현재 진행 중 주문 확인
      select jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_status', o.order_status,
        'order_type', o.order_type,
        'final_amount', o.final_amount,
        'kds_status', (
          select max(kds_status)
          from catchmenu_kds.kds_tickets
          where order_id = o.id
        ),
        'is_paid', exists (
          select 1
          from catchmenu_payment.payment_ledger
          where order_id = o.id
            and ledger_status = 'APPROVED'
        )
      )
      into v_active_order
      from catchmenu_pos.orders o
      where o.store_id = p_store_id
        and o.tenant_id = p_tenant_id
        and o.business_day = v_business_day
        and o.order_status in (
          'CONFIRMED', 'COOKING',
          'READY', 'PAID'
        )
        and exists (
          select 1
          from catchmenu_pos.order_sessions os
          where os.id = o.session_id
            and os.customer_id = p_customer_id
        )
      order by o.ordered_at desc
      limit 1;

      -- 푸시 토큰 업데이트
      if p_push_token is not null then
        update catchmenu_store.customers
        set
          preferred_locale = p_locale,
          updated_at = now()
        where id = p_customer_id;
      end if;
    end if;
  end if;

  -- CMS 번들 (이벤트/배너/팝업)
  v_cms_bundle :=
    catchmenu_store.get_cms_display_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_display_target := 'CUSTOMER_APP',
      p_trigger_event := 'APP_OPEN',
      p_locale := p_locale
    );

  -- 메뉴 미리보기 (인기 5개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', case p_locale
          when 'en' then coalesce(
            m.menu_name_en, m.menu_name
          )
          when 'zh' then coalesce(
            m.menu_name_zh, m.menu_name
          )
          when 'ja' then coalesce(
            m.menu_name_ja, m.menu_name
          )
          else m.menu_name
        end,
        'price', m.price,
        'thumbnail_url', m.image_url,
        'menu_status', m.menu_status
      )
      order by m.display_order asc
    ),
    '[]'::jsonb
  )
  into v_menu_preview
  from catchmenu_pos.menus m
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and m.menu_status = 'AVAILABLE'
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_app_ready',
    p_data := jsonb_build_object(

      -- 매장
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_type', v_store.store_type,
        'is_open', v_is_open,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        ),
        -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was
        -- never implemented on store_settings (see the SELECT above);
        -- hardcoded to 0 rather than referencing a nonexistent field on
        -- v_store_settings, which would itself fail since the record
        -- only carries the columns actually selected into it.
        'min_order_amount', 0,
        'business_hours', case
          when v_business_hours.open_time
            is not null
          then jsonb_build_object(
            'open_time',
              v_business_hours.open_time,
            'close_time',
              v_business_hours.close_time,
            'last_order_time',
              v_business_hours.last_order_time
          )
          else null
        end
      ),

      -- 고객
      'customer', case
        when v_customer.id is not null
        then jsonb_build_object(
          'id', v_customer.id,
          'display_name', v_customer.display_name,
          'membership_tier',
            v_customer.membership_tier,
          'total_points', v_customer.point_balance,
          'visit_count', v_customer.visit_count
        )
        else null
      end,

      -- 멤버십
      'membership', v_membership,

      -- 현재 대기
      'active_waiting', v_active_waiting,
      'has_active_waiting',
        v_active_waiting is not null,

      -- 진행 중 주문
      'active_order', v_active_order,
      'has_active_order',
        v_active_order is not null,

      -- CMS
      'cms', v_cms_bundle->'data',

      -- 메뉴 미리보기
      'menu_preview', v_menu_preview,

      -- Realtime 채널
      'realtime_channel',
        'customer_app:' || p_store_id,

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;

revoke all on function catchmenu_store.get_or_create_guest_customer(uuid, text) from public;
revoke all on function catchmenu_store.get_or_create_guest_customer(uuid, text) from authenticated;

-- Preserve existing RPC execute grants for the patched public entry points.
grant execute on function catchmenu_pos.register_waiting(
  uuid, uuid, int, text, text, text, uuid, text, text, text, text
) to authenticated;

grant execute on function catchmenu_store.bootstrap_customer_app_v2(
  uuid, uuid, uuid, text, text, text, text, text
) to authenticated;
