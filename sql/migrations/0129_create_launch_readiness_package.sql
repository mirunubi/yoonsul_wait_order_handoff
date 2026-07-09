-- 0129_create_launch_readiness_package.sql
-- Purpose: Launch readiness package.
--          1호점 오픈 운영 SOP.
--          오픈 당일 런북.
--          비상 연락망 설정.
--          운영 메트릭 수집.
--          일일 운영 리포트.
-- Depends on: 0128_create_system_integration_check.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('daily_report_loaded', 'ko',
  '일일 운영 리포트가 로드되었습니다'),
('daily_report_loaded', 'en',
  'Daily operation report loaded'),
('store_opened_msg', 'ko',
  '매장이 오픈되었습니다'),
('store_opened_msg', 'en',
  'Store opened'),
('metrics_recorded', 'ko',
  '운영 메트릭이 기록되었습니다'),
('metrics_recorded', 'en',
  'Metrics recorded')
on conflict (message_key, locale) do nothing;


-- =============================================
-- operation_metrics table
-- 운영 메트릭 수집
-- =============================================
create table if not exists
  catchmenu_common.operation_metrics (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  business_day date not null,
  metric_hour int,

  -- 주문 메트릭
  order_count int not null default 0,
  order_amount bigint not null default 0,
  avg_order_amount int not null default 0,
  cancelled_order_count int
    not null default 0,

  -- 대기 메트릭
  waiting_registered int not null default 0,
  waiting_seated int not null default 0,
  waiting_no_show int not null default 0,
  waiting_cancelled int not null default 0,
  avg_wait_minutes int,

  -- KDS 메트릭
  kds_total_tickets int not null default 0,
  kds_late_tickets int not null default 0,
  avg_cook_minutes int,

  -- 결제 메트릭
  payment_total bigint not null default 0,
  cash_total bigint not null default 0,
  card_total bigint not null default 0,
  refund_total bigint not null default 0,

  -- 고객 메트릭
  new_customers int not null default 0,
  returning_customers int not null default 0,
  foreign_customers int not null default 0,

  -- 키오스크 메트릭
  kiosk_sessions int not null default 0,
  kiosk_orders int not null default 0,

  -- 시스템 메트릭
  network_downtime_seconds int
    not null default 0,
  error_count int not null default 0,

  recorded_at timestamptz
    not null default now(),

  constraint uq_metrics_hour unique (
    store_id, business_day, metric_hour
  )
);

create index if not exists idx_metrics_store
  on catchmenu_common.operation_metrics(
    store_id, business_day desc
  );

alter table catchmenu_common.operation_metrics
  enable row level security;
alter table catchmenu_common.operation_metrics
  force row level security;

drop policy if exists metrics_isolation
  on catchmenu_common.operation_metrics;
create policy metrics_isolation
  on catchmenu_common.operation_metrics
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_common.operation_metrics is
  '시간별 운영 메트릭.
   pg_cron HOURLY_METRICS: 1시간마다 집계.
   business_day + metric_hour 기준.
   일일 리포트: metric_hour IS NULL.
   시간별 분석: metric_hour 0~23.
   기술신보 심사: 운영 데이터 근거 자료.
   1호점 오픈 후 데이터 축적 시작.';


-- =============================================
-- emergency_contacts table
-- 비상 연락망
-- =============================================
create table if not exists
  catchmenu_store.emergency_contacts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  contact_type text not null,
  contact_name text not null,
  contact_phone text not null,
  contact_role text,
  priority_order int not null default 1,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_contact_type check (
    contact_type in (
      'STORE_OWNER',    -- 업주
      'MANAGER',        -- 매니저
      'TECH_SUPPORT',   -- 기술 지원 (캐치메뉴)
      'POS_SUPPORT',    -- POS 지원
      'PAYMENT_SUPPORT',-- 결제 지원
      'DELIVERY_SUPPORT',-- 배달 지원
      'EMERGENCY_911',  -- 119/112
      'SUPPLIER'        -- 납품업체
    )
  )
);

alter table catchmenu_store.emergency_contacts
  enable row level security;
alter table catchmenu_store.emergency_contacts
  force row level security;

drop policy if exists emergency_contacts_isolation
  on catchmenu_store.emergency_contacts;
create policy emergency_contacts_isolation
  on catchmenu_store.emergency_contacts
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

-- 기본 비상 연락망 시드
insert into catchmenu_store.emergency_contacts (
  tenant_id, store_id,
  contact_type, contact_name,
  contact_phone, contact_role,
  priority_order
) values
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'TECH_SUPPORT',
  '캐치메뉴 기술지원',
  '1234-5678',
  'SaaS 기술 지원 (24시간)',
  1
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'PAYMENT_SUPPORT',
  '토스페이먼츠 고객센터',
  '1599-4905',
  '결제 오류 시',
  2
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'EMERGENCY_911',
  '소방서/경찰',
  '119',
  '화재/응급 시',
  9
)
on conflict do nothing;

comment on table
  catchmenu_store.emergency_contacts is
  '비상 연락망.
   TECH_SUPPORT: 캐치메뉴 기술 지원.
   POS_SUPPORT: OKpos/토스POS 지원.
   priority_order: 낮을수록 우선.
   직원 앱 비상 연락망 화면에서 표시.
   SOP 런북에서 참조.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.collect_hourly_metrics(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_metric_hour int default null
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
  v_business_day date;
  v_hour int;
  v_hour_start timestamptz;
  v_hour_end timestamptz;
  v_timezone text := 'Asia/Seoul';

  -- 메트릭 변수
  v_order_count int;
  v_order_amount bigint;
  v_avg_order_amount int;
  v_cancelled_count int;
  v_waiting_registered int;
  v_waiting_seated int;
  v_waiting_no_show int;
  v_waiting_cancelled int;
  v_avg_wait_minutes int;
  v_kds_total int;
  v_kds_late int;
  v_avg_cook int;
  v_payment_total bigint;
  v_cash_total bigint;
  v_card_total bigint;
  v_refund_total bigint;
  v_new_customers int;
  v_returning_customers int;
  v_foreign_customers int;
  v_kiosk_sessions int;
  v_kiosk_orders int;
  v_network_downtime int;
  v_error_count int;
  v_metric_id uuid;
begin
  v_business_day := coalesce(
    p_business_day,
    (timezone(v_timezone, now()))::date
  );
  v_hour := coalesce(
    p_metric_hour,
    extract(hour from timezone(
      v_timezone, now()
    ))::int - 1
  );

  -- 시간 범위
  v_hour_start := timezone(
    v_timezone,
    (v_business_day::text
      || ' ' || lpad(v_hour::text, 2, '0')
      || ':00:00')::timestamp
  );
  v_hour_end := v_hour_start + interval '1 hour';

  -- 주문 메트릭
  select
    count(*),
    coalesce(sum(final_amount), 0),
    coalesce(avg(final_amount)::int, 0),
    count(*) filter (
      where order_status = 'CANCELLED'
    )
  into
    v_order_count, v_order_amount,
    v_avg_order_amount, v_cancelled_count
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and ordered_at
      between v_hour_start and v_hour_end;

  -- 대기 메트릭
  select
    count(*),
    count(*) filter (
      where session_status = 'COMPLETED'
        or session_status = 'SEATED'
    ),
    count(*) filter (
      where session_status = 'NO_SHOW'
    ),
    count(*) filter (
      where session_status = 'CANCELLED'
    ),
    coalesce(
      avg(
        extract(epoch from (
          coalesce(seated_at, now())
          - session_started_at
        )) / 60
      )::int, 0
    )
  into
    v_waiting_registered,
    v_waiting_seated,
    v_waiting_no_show,
    v_waiting_cancelled,
    v_avg_wait_minutes
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and session_started_at
      between v_hour_start and v_hour_end;

  -- KDS 메트릭
  select
    count(*),
    count(*) filter (
      where is_late = true
    ),
    coalesce(
      avg(
        extract(epoch from (
          coalesce(served_at, now())
          - coalesce(committed_at, now())
        )) / 60
      )::int, 0
    )
  into v_kds_total, v_kds_late, v_avg_cook
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and ticket_created_at
      between v_hour_start and v_hour_end;

  -- 결제 메트릭
  select
    coalesce(sum(approved_amount) filter (
      where ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where payment_method = 'CASH'
        and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where payment_method in (
        'CREDIT_CARD', 'DEBIT_CARD'
      ) and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where ledger_status = 'REFUNDED'
    ), 0)
  into
    v_payment_total, v_cash_total,
    v_card_total, v_refund_total
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and approved_at
      between v_hour_start and v_hour_end;

  -- 고객 메트릭
  select
    count(*) filter (
      where first_visit_at
        between v_hour_start and v_hour_end
    ),
    count(*) filter (
      where last_visit_at
        between v_hour_start and v_hour_end
        and first_visit_at < v_hour_start
    ),
    count(*) filter (
      where locale != 'ko'
        and last_visit_at
          between v_hour_start and v_hour_end
    )
  into
    v_new_customers,
    v_returning_customers,
    v_foreign_customers
  from catchmenu_store.customers
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 키오스크 메트릭
  select
    count(*),
    count(*) filter (
      where session_status = 'COMPLETED'
    )
  into v_kiosk_sessions, v_kiosk_orders
  from catchmenu_store.kiosk_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and session_started_at
      between v_hour_start and v_hour_end;

  -- 네트워크 다운타임
  select coalesce(
    sum(downtime_seconds), 0
  ) into v_network_downtime
  from catchmenu_common.network_status_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and reported_at
      between v_hour_start and v_hour_end
    and network_status = 'OFFLINE';

  -- 에러 수
  select count(*) into v_error_count
  from catchmenu_common.operation_alerts
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and alert_severity in ('ERROR', 'CRITICAL')
    and created_at
      between v_hour_start and v_hour_end;

  -- 메트릭 저장
  insert into catchmenu_common.operation_metrics (
    tenant_id, store_id,
    business_day, metric_hour,
    order_count, order_amount,
    avg_order_amount, cancelled_order_count,
    waiting_registered, waiting_seated,
    waiting_no_show, waiting_cancelled,
    avg_wait_minutes,
    kds_total_tickets, kds_late_tickets,
    avg_cook_minutes,
    payment_total, cash_total,
    card_total, refund_total,
    new_customers, returning_customers,
    foreign_customers,
    kiosk_sessions, kiosk_orders,
    network_downtime_seconds, error_count
  ) values (
    p_tenant_id, p_store_id,
    v_business_day, v_hour,
    v_order_count, v_order_amount,
    v_avg_order_amount, v_cancelled_count,
    v_waiting_registered, v_waiting_seated,
    v_waiting_no_show, v_waiting_cancelled,
    v_avg_wait_minutes,
    v_kds_total, v_kds_late, v_avg_cook,
    v_payment_total, v_cash_total,
    v_card_total, v_refund_total,
    v_new_customers, v_returning_customers,
    v_foreign_customers,
    v_kiosk_sessions, v_kiosk_orders,
    v_network_downtime, v_error_count
  )
  on conflict (store_id, business_day, metric_hour)
  do update set
    order_count = excluded.order_count,
    order_amount = excluded.order_amount,
    payment_total = excluded.payment_total,
    waiting_registered =
      excluded.waiting_registered,
    kds_total_tickets =
      excluded.kds_total_tickets,
    foreign_customers =
      excluded.foreign_customers,
    network_downtime_seconds =
      excluded.network_downtime_seconds,
    error_count = excluded.error_count,
    recorded_at = now()
  returning id into v_metric_id;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'metric_id', v_metric_id,
      'business_day', v_business_day,
      'metric_hour', v_hour,
      'order_count', v_order_count,
      'order_amount', v_order_amount,
      'payment_total', v_payment_total,
      'waiting_registered',
        v_waiting_registered,
      'foreign_customers', v_foreign_customers,
      'network_downtime_seconds',
        v_network_downtime,
      'error_count', v_error_count
    )
  );
end;
$$;


create or replace function
  catchmenu_common.get_daily_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_store,
                  catchmenu_hq
as $$
declare
  v_business_day date;
  v_store_name text;
  v_daily_metrics record;
  v_hourly_trend jsonb;
  v_top_menus jsonb;
  v_payment_breakdown jsonb;
  v_waiting_stats jsonb;
  v_alerts_summary jsonb;
  v_comparison jsonb;
begin
  v_business_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date
  );

  select store_name into v_store_name
  from catchmenu_hq.stores
  where id = p_store_id;

  -- 일별 집계 메트릭
  select
    coalesce(sum(order_count), 0),
    coalesce(sum(order_amount), 0),
    coalesce(avg(avg_order_amount)::int, 0),
    coalesce(sum(cancelled_order_count), 0),
    coalesce(sum(waiting_registered), 0),
    coalesce(sum(waiting_seated), 0),
    coalesce(sum(waiting_no_show), 0),
    coalesce(sum(payment_total), 0),
    coalesce(sum(cash_total), 0),
    coalesce(sum(card_total), 0),
    coalesce(sum(refund_total), 0),
    coalesce(sum(new_customers), 0),
    coalesce(sum(returning_customers), 0),
    coalesce(sum(foreign_customers), 0),
    coalesce(sum(kiosk_sessions), 0),
    coalesce(sum(kiosk_orders), 0),
    coalesce(sum(network_downtime_seconds), 0),
    coalesce(sum(error_count), 0),
    coalesce(avg(avg_wait_minutes)::int, 0),
    coalesce(avg(avg_cook_minutes)::int, 0)
  into
    v_daily_metrics
  from catchmenu_common.operation_metrics
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and metric_hour is not null;

  -- 시간별 매출 트렌드
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'hour', metric_hour,
        'order_count', order_count,
        'order_amount', order_amount,
        'waiting_registered',
          waiting_registered
      )
      order by metric_hour asc
    ),
    '[]'::jsonb
  )
  into v_hourly_trend
  from catchmenu_common.operation_metrics
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and metric_hour is not null;

  -- 인기 메뉴 TOP 5
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', m.menu_name,
        'order_count', pop.cnt,
        'revenue', pop.revenue
      )
      order by pop.cnt desc
    ),
    '[]'::jsonb
  )
  into v_top_menus
  from (
    select
      oi.menu_id,
      count(*) as cnt,
      sum(oi.subtotal) as revenue
    from catchmenu_pos.order_items oi
    join catchmenu_pos.orders o
      on o.id = oi.order_id
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_business_day
      and o.order_status = 'COMPLETED'
    group by oi.menu_id
    order by count(*) desc
    limit 5
  ) pop
  join catchmenu_pos.menus m
    on m.id = pop.menu_id;

  -- 결제 수단별
  select jsonb_build_object(
    'cash', (v_daily_metrics).cash_total,
    'card', (v_daily_metrics).card_total,
    'total', (v_daily_metrics).payment_total,
    'refund', (v_daily_metrics).refund_total,
    'net', (v_daily_metrics).payment_total
      - (v_daily_metrics).refund_total
  )
  into v_payment_breakdown;

  -- 대기 통계
  select jsonb_build_object(
    'registered',
      (v_daily_metrics).waiting_registered,
    'seated',
      (v_daily_metrics).waiting_seated,
    'no_show',
      (v_daily_metrics).waiting_no_show,
    'avg_wait_minutes',
      (v_daily_metrics).avg_wait_minutes,
    'seat_rate', case
      (v_daily_metrics).waiting_registered
      when 0 then null
      else round(
        (v_daily_metrics).waiting_seated
          ::numeric
        / (v_daily_metrics).waiting_registered
        * 100, 1
      )
    end
  )
  into v_waiting_stats;

  -- 알림 요약
  select jsonb_build_object(
    'total', count(*),
    'critical', count(*) filter (
      where alert_severity in (
        'CRITICAL', 'FATAL'
      )
    ),
    'resolved', count(*) filter (
      where alert_status = 'RESOLVED'
    )
  )
  into v_alerts_summary
  from catchmenu_common.operation_alerts
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and created_at::date = v_business_day;

  -- 전일 비교
  declare
    v_prev_day date := v_business_day - 1;
    v_prev_amount bigint;
    v_prev_orders int;
  begin
    select
      coalesce(sum(order_amount), 0),
      coalesce(sum(order_count), 0)
    into v_prev_amount, v_prev_orders
    from catchmenu_common.operation_metrics
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_prev_day
      and metric_hour is not null;

    v_comparison := jsonb_build_object(
      'prev_day', v_prev_day,
      'prev_order_amount', v_prev_amount,
      'prev_order_count', v_prev_orders,
      'amount_change_rate', case v_prev_amount
        when 0 then null
        else round(
          (
            (v_daily_metrics).order_amount
            - v_prev_amount
          )::numeric / v_prev_amount * 100, 1
        )
      end,
      'order_change_rate', case v_prev_orders
        when 0 then null
        else round(
          (
            (v_daily_metrics).order_count
            - v_prev_orders
          )::numeric / v_prev_orders * 100, 1
        )
      end
    );
  end;

  return catchmenu_common.build_success_response(
    p_message_key := 'daily_report_loaded',
    p_data := jsonb_build_object(
      'store_name', v_store_name,
      'business_day', v_business_day,
      'summary', jsonb_build_object(
        'total_orders',
          (v_daily_metrics).order_count,
        'total_revenue',
          (v_daily_metrics).order_amount,
        'avg_order_amount',
          (v_daily_metrics).avg_order_amount,
        'cancelled_orders',
          (v_daily_metrics).cancelled_order_count,
        'new_customers',
          (v_daily_metrics).new_customers,
        'returning_customers',
          (v_daily_metrics).returning_customers,
        'foreign_customers',
          (v_daily_metrics).foreign_customers,
        'kiosk_orders',
          (v_daily_metrics).kiosk_orders,
        'avg_cook_minutes',
          (v_daily_metrics).avg_cook_minutes,
        'network_downtime_seconds',
          (v_daily_metrics)
            .network_downtime_seconds,
        'error_count',
          (v_daily_metrics).error_count
      ),
      'payment_breakdown', v_payment_breakdown,
      'waiting_stats', v_waiting_stats,
      'top_menus', v_top_menus,
      'hourly_trend', v_hourly_trend,
      'alerts_summary', v_alerts_summary,
      'vs_yesterday', v_comparison,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- SOP 런북 (오픈 당일)
insert into catchmenu_common.sop_runbooks (
  runbook_code, runbook_name,
  runbook_domain, symptom_description,
  recovery_steps, escalation_contact,
  escalation_threshold_minutes,
  is_active
) values
(
  'SOP-OPS-001',
  '매장 오픈 절차',
  'OPERATION',
  '매일 오픈 준비',
  jsonb_build_array(
    '1. 직원 앱 로그인 (staff_login)',
    '2. record_shift_start() 출근 처리',
    '3. get_store_dashboard() 현황 확인',
    '4. get_inventory_dashboard() 재고 확인',
    '5. set_menu_status() 품절 메뉴 처리',
    '6. open_store() 매장 오픈',
    '7. KDS 디스플레이 부트스트랩 확인',
    '8. DID 디스플레이 부트스트랩 확인',
    '9. 키오스크 부트스트랩 확인',
    '10. 오픈 준비 완료 메모 전송 (STAFF 전체)'
  ),
  '시스템 장애 → SOP-SYS-002 / 결제 장애 → SOP-PAY-001 / 기술 지원 → 캐치메뉴 기술지원팀',
  30, true
),
(
  'SOP-OPS-002',
  '매장 마감 절차',
  'OPERATION',
  '매일 마감',
  jsonb_build_array(
    '1. 대기 남은 고객 처리 완료 확인',
    '2. KDS 잔여 티켓 처리 완료 확인',
    '3. close_store() 매장 마감',
    '4. 재고 실사 → update_inventory(ADJUST)',
    '5. get_daily_report() 일일 리포트 확인',
    '6. get_reconciliation_report() 정산 확인',
    '7. 다음날 휴무 여부 set_holiday() 확인',
    '8. record_shift_end() 퇴근 처리',
    '9. 교대 인수인계 send_staff_memo(SHIFT_HANDOFF)',
    '10. 마감 완료'
  ),
  '정산 이상 → SOP-PAY-002 / 재고 부족 → 납품업체 연락',
  45, true
),
(
  'SOP-OPS-003',
  '외국인 고객 대응 절차',
  'OPERATION',
  '외국인 고객 방문 시',
  jsonb_build_array(
    '1. 키오스크 언어 선택 안내',
    '   (EN/ZH/JA/VI/TH 지원)',
    '2. QR코드 스캔으로 대기 등록 안내',
    '3. 알레르겐 정보 확인 요청 시',
    '   → 메뉴 알레르겐 표시 확인',
    '4. 메뉴 자연어 검색 지원',
    '   → 키오스크 검색창 이용',
    '5. 결제: 카드/토스페이먼츠',
    '6. 대기 호출 시 DID + 푸시 알림',
    '7. 사전 주문 안내 (착석 즉시 음식 제공)'
  ),
  '언어 지원 불가 → 번역 앱 활용 / 알레르겐 심각 → 음식 제공 거부 가능',
  5, true
),
(
  'SOP-OPS-004',
  '점심 피크 시간 운영 절차',
  'OPERATION',
  '11:30~13:30 피크 시간',
  jsonb_build_array(
    '1. KDS 용량 확인 (check_kds_capacity)',
    '2. 대기 인원 20명+ → 사전 주문 적극 안내',
    '   (대기 중 주문 → 착석 즉시 음식)',
    '3. 재고 실시간 확인 (get_inventory_dashboard)',
    '4. 품절 메뉴 즉시 처리 (set_menu_status)',
    '5. KDS 과부하 시 신규 주문 일시 중단',
    '   change_store_mode(BUSY)',
    '6. 피크 종료 후 재고 재확인',
    '7. 피크 메트릭 확인 (get_daily_report)'
  ),
  'KDS 과부하 → change_store_mode(BUSY) / 재고 소진 → 자동 품절 또는 수동 처리',
  0, true
)
on conflict (runbook_code) do nothing;


-- pg_cron 추가
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'HOURLY_METRICS',
  'catchmenu_hourly_metrics',
  '5 * * * *',
  '5 * * * * (매시 5분)',
  $sql$
SELECT catchmenu_common.collect_hourly_metrics(
  t.id, s.id
)
FROM catchmenu_hq.tenants t
JOIN catchmenu_hq.stores s
  ON s.tenant_id = t.id
  AND s.is_active = true
WHERE t.tenant_status = 'ACTIVE';
$sql$,
  '시간별 운영 메트릭 집계. 매시 5분.',
  true
),
(
  'DAILY_REPORT_GENERATE',
  'catchmenu_daily_report',
  '0 15 * * *',
  '0 0 * * * (매일 자정 KST)',
  $sql$
-- 전날 일별 집계 메트릭 생성
INSERT INTO catchmenu_common.operation_metrics (
  tenant_id, store_id, business_day,
  metric_hour,
  order_count, order_amount,
  payment_total, waiting_registered,
  new_customers, foreign_customers
)
SELECT
  o.tenant_id, o.store_id,
  o.business_day, NULL,
  count(DISTINCT o.id),
  coalesce(sum(o.final_amount), 0),
  coalesce(sum(pl.approved_amount), 0),
  coalesce(ws.waiting_count, 0),
  0, 0
FROM catchmenu_pos.orders o
LEFT JOIN catchmenu_payment.payment_ledger pl
  ON pl.order_id = o.id
  AND pl.ledger_status = 'APPROVED'
LEFT JOIN LATERAL (
  SELECT count(*) as waiting_count
  FROM catchmenu_pos.order_sessions
  WHERE store_id = o.store_id
    AND business_day = o.business_day
) ws ON true
WHERE o.business_day =
  (timezone('Asia/Seoul', now()))::date - 1
  AND o.order_status = 'COMPLETED'
GROUP BY o.tenant_id, o.store_id,
         o.business_day, ws.waiting_count
ON CONFLICT (store_id, business_day, metric_hour)
DO UPDATE SET
  order_count = excluded.order_count,
  order_amount = excluded.order_amount,
  payment_total = excluded.payment_total,
  recorded_at = now();
$sql$,
  '일별 집계 메트릭. 매일 자정.',
  true
)
on conflict (job_code) do nothing;


-- grants
grant execute on function
  catchmenu_common.collect_hourly_metrics(
    uuid, uuid, date, int
  ) to authenticated;

grant execute on function
  catchmenu_common.get_daily_report(
    uuid, uuid, date, text
  ) to authenticated;

comment on function
  catchmenu_common.get_daily_report(
    uuid, uuid, date, text
  ) is
  '일일 운영 리포트.
   업주가 매일 마감 후 확인하는 리포트.

   포함 데이터:
   - 오늘 전체 주문/매출 요약
   - 결제 수단별 분류
   - 대기 통계 (착석률 포함)
   - 인기 메뉴 TOP 5
   - 시간별 매출 트렌드
   - 운영 알림 요약
   - 전일 대비 성장률

   SOP-OPS-002 마감 절차에서 확인.
   기술신보: 실제 운영 데이터 근거.
   1호점 오픈 후 데이터 축적 시작.';