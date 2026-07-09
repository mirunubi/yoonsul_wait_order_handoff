-- 0122_create_coupon_pipeline_rpc.sql
-- Purpose: Coupon issue and redemption pipeline.
--          쿠폰 생성/발급/사용/만료.
--          멤버십 스탬프 보상 연동.
--          CMS 이벤트 탭 쿠폰 연동.
--          결제 시 쿠폰 적용.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0121_create_security_pipeline.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('coupon_created', 'ko',
  '쿠폰이 생성되었습니다'),
('coupon_created', 'en', 'Coupon created'),
('coupon_issued', 'ko',
  '쿠폰이 발급되었습니다'),
('coupon_issued', 'en', 'Coupon issued'),
('coupon_issued', 'zh', '优惠券已发放'),
('coupon_issued', 'ja', 'クーポンが発行されました'),
('coupon_issued', 'vi', 'Đã phát phiếu giảm giá'),
('coupon_issued', 'th', 'ออกคูปองแล้ว'),
('coupon_used', 'ko',
  '쿠폰이 사용되었습니다'),
('coupon_used', 'en', 'Coupon used'),
('coupon_used', 'zh', '优惠券已使用'),
('coupon_used', 'ja', 'クーポンを使用しました'),
('coupon_used', 'vi', 'Đã dùng phiếu giảm giá'),
('coupon_used', 'th', 'ใช้คูปองแล้ว'),
('coupon_discount_applied', 'ko',
  '{discount_amount}원 할인이 적용되었습니다'),
('coupon_discount_applied', 'en',
  '{discount_amount}₩ discount applied'),
('coupon_list_loaded', 'ko',
  '쿠폰 목록이 로드되었습니다'),
('coupon_list_loaded', 'en',
  'Coupon list loaded')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7080, 'coupon_min_order_not_met',
  'STORE', 'BUSINESS_RULE', 400, 'INFO'),
(7081, 'coupon_not_applicable',
  'STORE', 'BUSINESS_RULE', 400, 'WARNING'),
(7082, 'coupon_issue_limit_exceeded',
  'STORE', 'BUSINESS_RULE', 409, 'INFO'),
(7083, 'coupon_already_issued',
  'STORE', 'CONFLICT', 409, 'INFO')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.create_coupon(
  p_tenant_id uuid,
  p_store_id uuid,
  p_coupon_name text,
  p_coupon_code text default null,
  p_discount_type text default 'FIXED',
  p_discount_value int default 0,
  p_min_order_amount int default 0,
  p_max_discount_amount int default null,
  p_total_issue_limit int default null,
  p_per_customer_limit int default 1,
  p_valid_days int default 30,
  p_issue_method text default 'MANUAL',
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_coupon_id uuid;
  v_coupon_code text;
begin
  if p_discount_type not in (
    'FIXED', 'PERCENT', 'FREE_ITEM'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'discount_type'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'create_coupon'
    );
  end if;

  -- 쿠폰 코드 자동 생성
  v_coupon_code := coalesce(
    p_coupon_code,
    upper(
      substr(md5(random()::text), 1, 8)
    )
  );

  insert into catchmenu_store.coupons (
    tenant_id, store_id,
    coupon_name, coupon_code,
    discount_type, discount_value,
    min_order_amount, max_discount_amount,
    total_issue_limit, per_customer_limit,
    valid_days, issue_method,
    coupon_status
  ) values (
    p_tenant_id, p_store_id,
    p_coupon_name, v_coupon_code,
    p_discount_type, p_discount_value,
    p_min_order_amount, p_max_discount_amount,
    p_total_issue_limit, p_per_customer_limit,
    p_valid_days, p_issue_method,
    'ACTIVE'
  )
  returning id into v_coupon_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'coupon_created',
    p_data := jsonb_build_object(
      'coupon_id', v_coupon_id,
      'coupon_code', v_coupon_code,
      'coupon_name', p_coupon_name,
      'discount_type', p_discount_type,
      'discount_value', p_discount_value,
      'valid_days', p_valid_days
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.issue_coupon_to_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_coupon_id uuid,
  p_customer_id uuid,
  p_issue_reason text default 'MANUAL',
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_coupon record;
  v_issue_id uuid;
  v_valid_until timestamptz;
  v_existing_count int;
  v_total_issued int;
begin
  -- 쿠폰 조회
  select id, coupon_name, coupon_status,
         per_customer_limit, total_issue_limit,
         valid_days, discount_type,
         discount_value, min_order_amount
  into v_coupon
  from catchmenu_store.coupons
  where id = p_coupon_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_coupon.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'coupon_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'issue_coupon_to_customer'
    );
  end if;

  if v_coupon.coupon_status <> 'ACTIVE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'coupon_not_applicable',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'issue_coupon_to_customer'
    );
  end if;

  -- 고객별 발급 한도 확인
  select count(*) into v_existing_count
  from catchmenu_store.coupon_issues
  where coupon_id = p_coupon_id
    and customer_id = p_customer_id
    and tenant_id = p_tenant_id;

  if v_existing_count
    >= coalesce(v_coupon.per_customer_limit, 1)
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'coupon_already_issued',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'issue_coupon_to_customer'
    );
  end if;

  -- 전체 발급 한도 확인
  if v_coupon.total_issue_limit is not null then
    select count(*) into v_total_issued
    from catchmenu_store.coupon_issues
    where coupon_id = p_coupon_id
      and tenant_id = p_tenant_id;

    if v_total_issued
      >= v_coupon.total_issue_limit
    then
      return catchmenu_common.build_error_response(
        p_error_key := 'coupon_issue_limit_exceeded',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'issue_coupon_to_customer'
      );
    end if;
  end if;

  v_valid_until := now()
    + (v_coupon.valid_days || ' days')::interval;

  -- 쿠폰 발급
  insert into catchmenu_store.coupon_issues (
    tenant_id, store_id,
    coupon_id, customer_id,
    issue_reason, issued_at, valid_until,
    is_used
  ) values (
    p_tenant_id, p_store_id,
    p_coupon_id, p_customer_id,
    p_issue_reason, now(), v_valid_until,
    false
  )
  returning id into v_issue_id;

  -- 고객 앱 Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'CUSTOMER_APP',
    p_event_type := 'coupon_issued',
    p_payload := jsonb_build_object(
      'customer_id', p_customer_id,
      'coupon_id', p_coupon_id,
      'coupon_name', v_coupon.coupon_name,
      'discount_type', v_coupon.discount_type,
      'discount_value', v_coupon.discount_value,
      'valid_until', v_valid_until,
      'issue_reason', p_issue_reason
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
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'coupon', 'coupon_issued', 1,
    'customer', p_customer_id,
    null, 'ISSUED',
    'SYSTEM', p_actor_id,
    jsonb_build_object(
      'coupon_id', p_coupon_id,
      'coupon_name', v_coupon.coupon_name,
      'issue_reason', p_issue_reason,
      'valid_until', v_valid_until
    ),
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'coupon_issued',
    p_data := jsonb_build_object(
      'issue_id', v_issue_id,
      'coupon_id', p_coupon_id,
      'coupon_name', v_coupon.coupon_name,
      'discount_type', v_coupon.discount_type,
      'discount_value', v_coupon.discount_value,
      'min_order_amount',
        v_coupon.min_order_amount,
      'valid_until', v_valid_until,
      'issue_reason', p_issue_reason
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.apply_coupon_to_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_coupon_issue_id uuid,
  p_customer_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_coupon_issue record;
  v_coupon record;
  v_order record;
  v_discount_amount int;
  v_final_amount int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 쿠폰 발급 정보 조회
  select ci.id, ci.coupon_id,
         ci.customer_id, ci.is_used,
         ci.valid_until, ci.used_at
  into v_coupon_issue
  from catchmenu_store.coupon_issues ci
  where ci.id = p_coupon_issue_id
    and ci.store_id = p_store_id
    and ci.tenant_id = p_tenant_id
    and ci.customer_id = p_customer_id
  for update;

  if v_coupon_issue.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'coupon_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'apply_coupon_to_order'
    );
  end if;

  if v_coupon_issue.is_used then
    return catchmenu_common.build_error_response(
      p_error_key := 'coupon_already_used',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'apply_coupon_to_order'
    );
  end if;

  if v_coupon_issue.valid_until < now() then
    return catchmenu_common.build_error_response(
      p_error_key := 'coupon_expired',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'apply_coupon_to_order'
    );
  end if;

  -- 쿠폰 정보
  select id, coupon_name, discount_type,
         discount_value, min_order_amount,
         max_discount_amount
  into v_coupon
  from catchmenu_store.coupons
  where id = v_coupon_issue.coupon_id;

  -- 주문 조회
  select id, total_amount, final_amount,
         order_status
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'apply_coupon_to_order'
    );
  end if;

  -- 최소 주문 금액 확인
  if v_order.total_amount
    < coalesce(v_coupon.min_order_amount, 0)
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'coupon_min_order_not_met',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'min_order_amount',
          v_coupon.min_order_amount
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'apply_coupon_to_order'
    );
  end if;

  -- 할인 금액 계산
  v_discount_amount := case v_coupon.discount_type
    when 'FIXED' then
      v_coupon.discount_value
    when 'PERCENT' then
      least(
        (v_order.total_amount
          * v_coupon.discount_value / 100)::int,
        coalesce(
          v_coupon.max_discount_amount,
          v_order.total_amount
        )
      )
    else 0
  end;

  v_final_amount := greatest(
    0,
    v_order.total_amount - v_discount_amount
  );

  -- 주문 금액 업데이트
  update catchmenu_pos.orders
  set
    discount_amount = v_discount_amount,
    final_amount = v_final_amount,
    coupon_issue_id = p_coupon_issue_id,
    updated_at = now()
  where id = p_order_id;

  -- 쿠폰 사용 처리
  update catchmenu_store.coupon_issues
  set
    is_used = true,
    used_at = now(),
    used_order_id = p_order_id
  where id = p_coupon_issue_id;

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
    'coupon', 'coupon_used', 1,
    'order', p_order_id,
    'ISSUED', 'USED',
    'CUSTOMER', p_customer_id,
    jsonb_build_object(
      'coupon_id', v_coupon_issue.coupon_id,
      'coupon_name', v_coupon.coupon_name,
      'discount_type', v_coupon.discount_type,
      'discount_amount', v_discount_amount,
      'original_amount', v_order.total_amount,
      'final_amount', v_final_amount
    ),
    p_order_id, p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'coupon_discount_applied',
    p_data := jsonb_build_object(
      'coupon_issue_id', p_coupon_issue_id,
      'coupon_name', v_coupon.coupon_name,
      'discount_type', v_coupon.discount_type,
      'discount_amount', v_discount_amount,
      'original_amount', v_order.total_amount,
      'final_amount', v_final_amount,
      'order_id', p_order_id
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'discount_amount', v_discount_amount
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.get_customer_coupons(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_only_usable boolean default true,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_coupons jsonb;
  v_usable_count int;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'issue_id', ci.id,
        'coupon_id', c.id,
        'coupon_name', c.coupon_name,
        'coupon_code', c.coupon_code,
        'discount_type', c.discount_type,
        'discount_value', c.discount_value,
        'min_order_amount', c.min_order_amount,
        'max_discount_amount',
          c.max_discount_amount,
        'is_used', ci.is_used,
        'valid_until', ci.valid_until,
        'is_expired', ci.valid_until < now(),
        'issue_reason', ci.issue_reason,
        'issued_at', ci.issued_at,
        'days_remaining', greatest(
          0,
          extract(
            day from (ci.valid_until - now())
          )::int
        ),
        'discount_display', case
          c.discount_type
          when 'FIXED' then
            to_char(c.discount_value, 'FM999,999')
            || '원 할인'
          when 'PERCENT' then
            c.discount_value::text || '% 할인'
          else '무료 제공'
        end
      )
      order by
        ci.is_used asc,
        ci.valid_until asc
    ),
    '[]'::jsonb
  )
  into v_coupons
  from catchmenu_store.coupon_issues ci
  join catchmenu_store.coupons c
    on c.id = ci.coupon_id
    and c.coupon_status = 'ACTIVE'
  where ci.store_id = p_store_id
    and ci.tenant_id = p_tenant_id
    and ci.customer_id = p_customer_id
    and (
      not p_only_usable
      or (
        ci.is_used = false
        and ci.valid_until > now()
      )
    );

  -- 사용 가능한 쿠폰 수
  select count(*) into v_usable_count
  from catchmenu_store.coupon_issues ci
  where ci.store_id = p_store_id
    and ci.tenant_id = p_tenant_id
    and ci.customer_id = p_customer_id
    and ci.is_used = false
    and ci.valid_until > now();

  return catchmenu_common.build_success_response(
    p_message_key := 'coupon_list_loaded',
    p_data := jsonb_build_object(
      'coupons', v_coupons,
      'total_count',
        jsonb_array_length(v_coupons),
      'usable_count', v_usable_count
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron: 쿠폰 만료
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'COUPON_EXPIRE',
  'catchmenu_coupon_expire',
  '0 2 * * *',
  '0 11 * * * (매일 11:00 KST)',
  $sql$
UPDATE catchmenu_store.coupons
SET coupon_status = 'EXPIRED'
WHERE coupon_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();
$sql$,
  '만료된 쿠폰 자동 처리. 매일 11:00.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.create_coupon(
      uuid, uuid, text, text, text, int,
      int, int, int, int, int, text, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.issue_coupon_to_customer(
      uuid, uuid, uuid, uuid, text, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.apply_coupon_to_order(
      uuid, uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_customer_coupons(
      uuid, uuid, uuid, boolean, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.apply_coupon_to_order(
    uuid, uuid, uuid, uuid, uuid, text, text
  ) is
  '주문에 쿠폰 적용.
   결제 전 호출.

   흐름:
   1. 고객 쿠폰 목록: get_customer_coupons()
   2. 쿠폰 선택 → apply_coupon_to_order()
   3. final_amount 할인 적용
   4. confirm_payment(final_amount) 호출
   5. 쿠폰 USED 처리

   할인 계산:
   FIXED: discount_value원 고정 할인
   PERCENT: total × rate (max_discount 적용)
   FREE_ITEM: 별도 처리

   멤버십 연동:
   STAMP_REWARD: stamp_visit()에서 자동 발급
   CMS_TAP: get_cms_display_bundle() 탭 시 발급

   ledger event: 쿠폰 사용 감사 기록.';