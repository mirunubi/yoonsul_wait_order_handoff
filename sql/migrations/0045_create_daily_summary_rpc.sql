-- 0045_create_daily_summary_rpc.sql
-- Purpose: Daily business summary and reporting RPCs.
--          get_daily_summary: returns business day operational summary.
--          get_kds_performance: returns KDS timing KPI by zone.
--          get_payment_summary: returns payment breakdown by method.
--          특허3: Task/Event 운영 원장 → AI Agent 학습 데이터 생성.
-- Depends on: 0044_create_menu_management_rpc.sql
-- Creates:
--   function catchmenu_pos.get_daily_summary(...)
--   function catchmenu_kds.get_kds_performance(...)
--   function catchmenu_payment.get_payment_summary(...)

create or replace function catchmenu_pos.get_daily_summary(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_payment, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_store record;
  v_timezone text;
  v_target_day date;

  -- session stats
  v_total_sessions int;
  v_completed_sessions int;
  v_cancelled_sessions int;
  v_no_show_sessions int;
  v_walk_in_count int;
  v_waiting_count int;
  v_delivery_count int;
  v_kiosk_count int;

  -- order stats
  v_total_orders int;
  v_completed_orders int;
  v_cancelled_orders int;
  v_total_revenue int;
  v_avg_order_amount int;
  v_dine_in_revenue int;
  v_delivery_revenue int;

  -- KDS stats
  v_avg_cooking_minutes numeric;
  v_max_cooking_minutes int;
  v_ticket_count int;
  v_on_time_rate numeric;

  -- exception stats
  v_open_exceptions int;
  v_resolved_exceptions int;
  v_critical_exceptions int;

  -- payment stats
  v_payment_approved int;
  v_payment_cancelled int;
  v_payment_refunded int;
begin
  select id, store_name, store_type, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  v_timezone := v_store.timezone;
  v_target_day := coalesce(
    p_business_day,
    (timezone(v_timezone, now()))::date
  );

  -- session stats
  select
    count(*),
    count(*) filter (where session_status = 'COMPLETED'),
    count(*) filter (where session_status = 'CANCELLED'),
    count(*) filter (where session_status = 'NO_SHOW'),
    count(*) filter (where session_type = 'WALK_IN'),
    count(*) filter (where session_type = 'WAITING'),
    count(*) filter (where session_type = 'DELIVERY'),
    count(*) filter (where session_type = 'KIOSK')
  into
    v_total_sessions,
    v_completed_sessions,
    v_cancelled_sessions,
    v_no_show_sessions,
    v_walk_in_count,
    v_waiting_count,
    v_delivery_count,
    v_kiosk_count
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- order stats
  select
    count(*),
    count(*) filter (
      where order_status = 'COMPLETED'
    ),
    count(*) filter (
      where order_status = 'CANCELLED'
    ),
    coalesce(sum(final_amount) filter (
      where order_status = 'COMPLETED'
    ), 0),
    coalesce(avg(final_amount) filter (
      where order_status = 'COMPLETED'
    ), 0)::int,
    coalesce(sum(final_amount) filter (
      where order_status = 'COMPLETED'
        and order_type = 'DINE_IN'
    ), 0),
    coalesce(sum(final_amount) filter (
      where order_status = 'COMPLETED'
        and order_type = 'DELIVERY'
    ), 0)
  into
    v_total_orders,
    v_completed_orders,
    v_cancelled_orders,
    v_total_revenue,
    v_avg_order_amount,
    v_dine_in_revenue,
    v_delivery_revenue
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- KDS performance
  select
    count(*),
    coalesce(avg(
      extract(epoch from (
        ready_at - cooking_started_at
      )) / 60
    ) filter (
      where cooking_started_at is not null
        and ready_at is not null
    ), 0)::numeric(10,1),
    coalesce(max(
      extract(epoch from (
        ready_at - cooking_started_at
      )) / 60
    ) filter (
      where cooking_started_at is not null
        and ready_at is not null
    ), 0)::int,
    coalesce(
      count(*) filter (
        where cooking_started_at is not null
          and ready_at is not null
          and extract(epoch from (
            ready_at - cooking_started_at
          )) / 60 <= estimated_minutes_snapshot
      )::numeric / nullif(
        count(*) filter (
          where cooking_started_at is not null
            and ready_at is not null
        ), 0
      ) * 100,
      0
    )::numeric(5,1)
  into
    v_ticket_count,
    v_avg_cooking_minutes,
    v_max_cooking_minutes,
    v_on_time_rate
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and kds_status not in ('HOLD', 'CAPACITY_CHECKING');

  -- exception stats
  select
    count(*) filter (
      where exception_status in (
        'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY'
      )
    ),
    count(*) filter (
      where exception_status = 'RESOLVED'
    ),
    count(*) filter (
      where exception_severity in ('CRITICAL', 'FATAL')
    )
  into
    v_open_exceptions,
    v_resolved_exceptions,
    v_critical_exceptions
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- payment stats
  select
    count(*) filter (
      where ledger_status = 'APPROVED'
    ),
    count(*) filter (
      where ledger_status in ('CANCELLED', 'PARTIAL_CANCELLED')
    ),
    count(*) filter (
      where ledger_status in ('REFUNDED', 'PARTIAL_REFUNDED')
    )
  into
    v_payment_approved,
    v_payment_cancelled,
    v_payment_refunded
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_type', v_store.store_type,
      'timezone', v_timezone
    ),
    'business_day', v_target_day,
    'sessions', jsonb_build_object(
      'total', v_total_sessions,
      'completed', v_completed_sessions,
      'cancelled', v_cancelled_sessions,
      'no_show', v_no_show_sessions,
      'by_type', jsonb_build_object(
        'walk_in', v_walk_in_count,
        'waiting', v_waiting_count,
        'delivery', v_delivery_count,
        'kiosk', v_kiosk_count
      ),
      'completion_rate', case v_total_sessions
        when 0 then 0
        else (
          v_completed_sessions::numeric
          / v_total_sessions * 100
        )::numeric(5,1)
      end,
      'no_show_rate', case v_total_sessions
        when 0 then 0
        else (
          v_no_show_sessions::numeric
          / v_total_sessions * 100
        )::numeric(5,1)
      end
    ),
    'orders', jsonb_build_object(
      'total', v_total_orders,
      'completed', v_completed_orders,
      'cancelled', v_cancelled_orders,
      'cancellation_rate', case v_total_orders
        when 0 then 0
        else (
          v_cancelled_orders::numeric
          / v_total_orders * 100
        )::numeric(5,1)
      end
    ),
    'revenue', jsonb_build_object(
      'total_revenue', v_total_revenue,
      'avg_order_amount', v_avg_order_amount,
      'dine_in_revenue', v_dine_in_revenue,
      'delivery_revenue', v_delivery_revenue,
      'currency', 'KRW'
    ),
    'kds_performance', jsonb_build_object(
      'ticket_count', v_ticket_count,
      'avg_cooking_minutes', v_avg_cooking_minutes,
      'max_cooking_minutes', v_max_cooking_minutes,
      'on_time_rate_pct', v_on_time_rate
    ),
    'exceptions', jsonb_build_object(
      'open', v_open_exceptions,
      'resolved', v_resolved_exceptions,
      'critical', v_critical_exceptions
    ),
    'payments', jsonb_build_object(
      'approved', v_payment_approved,
      'cancelled', v_payment_cancelled,
      'refunded', v_payment_refunded
    ),
    'generated_at', now(),
    'message_code', 'daily_summary_loaded'
  );
end;
$$;


create or replace function catchmenu_kds.get_kds_performance(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_kitchen_zone text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_kds, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_timezone text;
  v_target_day date;
  v_zone_stats jsonb;
  v_hold_duration jsonb;
  v_hourly_load jsonb;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(coalesce(v_timezone, 'Asia/Seoul'), now()))::date
  );

  -- zone-level performance stats
  select coalesce(
    jsonb_object_agg(
      coalesce(zone, 'GENERAL'),
      jsonb_build_object(
        'ticket_count', ticket_count,
        'avg_hold_minutes', avg_hold_minutes,
        'avg_cooking_minutes', avg_cooking_minutes,
        'on_time_count', on_time_count,
        'late_count', late_count,
        'on_time_rate_pct', on_time_rate_pct,
        'cancelled_count', cancelled_count,
        'manual_fallback_count', manual_fallback_count
      )
    ),
    '{}'::jsonb
  )
  into v_zone_stats
  from (
    select
      kitchen_zone as zone,
      count(*) as ticket_count,
      coalesce(avg(
        extract(epoch from (
          committed_at - ticket_created_at
        )) / 60
      ) filter (
        where committed_at is not null
      ), 0)::numeric(10,1) as avg_hold_minutes,
      coalesce(avg(
        extract(epoch from (
          ready_at - cooking_started_at
        )) / 60
      ) filter (
        where cooking_started_at is not null
          and ready_at is not null
      ), 0)::numeric(10,1) as avg_cooking_minutes,
      count(*) filter (
        where cooking_started_at is not null
          and ready_at is not null
          and extract(epoch from (
            ready_at - cooking_started_at
          )) / 60 <= coalesce(
            estimated_minutes_snapshot, 999
          )
      ) as on_time_count,
      count(*) filter (
        where cooking_started_at is not null
          and ready_at is not null
          and extract(epoch from (
            ready_at - cooking_started_at
          )) / 60 > coalesce(
            estimated_minutes_snapshot, 999
          )
      ) as late_count,
      coalesce(
        count(*) filter (
          where cooking_started_at is not null
            and ready_at is not null
            and extract(epoch from (
              ready_at - cooking_started_at
            )) / 60 <= coalesce(
              estimated_minutes_snapshot, 999
            )
        )::numeric / nullif(
          count(*) filter (
            where cooking_started_at is not null
              and ready_at is not null
          ), 0
        ) * 100,
        0
      )::numeric(5,1) as on_time_rate_pct,
      count(*) filter (
        where kds_status = 'CANCELLED'
      ) as cancelled_count,
      count(*) filter (
        where manual_fallback_activated = true
      ) as manual_fallback_count
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and (
        p_kitchen_zone is null
        or kitchen_zone = p_kitchen_zone
      )
    group by kitchen_zone
  ) zone_data;

  -- hold duration analysis
  select jsonb_build_object(
    'avg_hold_minutes',
      coalesce(avg(
        extract(epoch from (
          coalesce(committed_at, now())
          - ticket_created_at
        )) / 60
      ), 0)::numeric(10,1),
    'max_hold_minutes',
      coalesce(max(
        extract(epoch from (
          coalesce(committed_at, now())
          - ticket_created_at
        )) / 60
      ), 0)::int,
    'still_holding_count',
      count(*) filter (
        where kds_status in ('HOLD', 'CAPACITY_CHECKING')
      ),
    'avg_conditions_wait_minutes',
      coalesce(avg(
        extract(epoch from (
          committed_at - ticket_created_at
        )) / 60
      ) filter (
        where committed_at is not null
      ), 0)::numeric(10,1)
  )
  into v_hold_duration
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- hourly load distribution
  select coalesce(
    jsonb_object_agg(
      hour_label,
      jsonb_build_object(
        'ticket_count', ticket_count,
        'avg_cooking_minutes', avg_cooking_minutes
      )
    ),
    '{}'::jsonb
  )
  into v_hourly_load
  from (
    select
      to_char(
        timezone(
          coalesce(v_timezone, 'Asia/Seoul'),
          ticket_created_at
        ),
        'HH24:00'
      ) as hour_label,
      count(*) as ticket_count,
      coalesce(avg(
        extract(epoch from (
          ready_at - cooking_started_at
        )) / 60
      ) filter (
        where cooking_started_at is not null
          and ready_at is not null
      ), 0)::numeric(10,1) as avg_cooking_minutes
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
    group by hour_label
    order by hour_label
  ) hourly_data;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'business_day', v_target_day,
    'kitchen_zone_filter', p_kitchen_zone,
    'zone_performance', v_zone_stats,
    'hold_duration', v_hold_duration,
    'hourly_load', v_hourly_load,
    'generated_at', now(),
    'message_code', 'kds_performance_loaded'
  );
end;
$$;


create or replace function catchmenu_payment.get_payment_summary(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_timezone text;
  v_target_day date;
  v_total_approved int;
  v_total_cancelled int;
  v_total_refunded int;
  v_net_revenue int;
  v_by_provider jsonb;
  v_by_status jsonb;
  v_reconciliation_summary jsonb;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(coalesce(v_timezone, 'Asia/Seoul'), now()))::date
  );

  -- overall payment amounts
  select
    coalesce(sum(approved_amount) filter (
      where ledger_status not in ('CANCELLED')
    ), 0),
    coalesce(sum(cancelled_amount), 0),
    coalesce(sum(refunded_amount), 0),
    coalesce(sum(net_amount), 0)
  into
    v_total_approved,
    v_total_cancelled,
    v_total_refunded,
    v_net_revenue
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- by provider type
  select coalesce(
    jsonb_object_agg(
      provider_type,
      jsonb_build_object(
        'transaction_count', count(*),
        'total_amount', coalesce(sum(net_amount), 0),
        'avg_amount', coalesce(
          avg(net_amount)::int, 0
        )
      )
    ),
    '{}'::jsonb
  )
  into v_by_provider
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and ledger_status = 'APPROVED'
  group by provider_type;

  -- by status
  select coalesce(
    jsonb_object_agg(
      ledger_status,
      jsonb_build_object(
        'count', count(*),
        'total_amount', coalesce(sum(net_amount), 0)
      )
    ),
    '{}'::jsonb
  )
  into v_by_status
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
  group by ledger_status;

  -- reconciliation summary
  select jsonb_build_object(
    'pending_count', count(*) filter (
      where reconciliation_status = 'PENDING'
    ),
    'matched_count', count(*) filter (
      where reconciliation_status = 'MATCHED'
    ),
    'mismatch_count', count(*) filter (
      where reconciliation_status = 'MISMATCH'
    ),
    'manual_review_count', count(*) filter (
      where reconciliation_status = 'MANUAL_REVIEW'
    )
  )
  into v_reconciliation_summary
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'business_day', v_target_day,
    'summary', jsonb_build_object(
      'total_approved_amount', v_total_approved,
      'total_cancelled_amount', v_total_cancelled,
      'total_refunded_amount', v_total_refunded,
      'net_revenue', v_net_revenue,
      'currency', 'KRW'
    ),
    'by_provider', v_by_provider,
    'by_status', v_by_status,
    'reconciliation', v_reconciliation_summary,
    'generated_at', now(),
    'message_code', 'payment_summary_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.get_daily_summary(
    uuid, uuid, date
  ) from public;
  grant execute on function catchmenu_pos.get_daily_summary(
    uuid, uuid, date
  ) to authenticated;

  revoke all on function catchmenu_kds.get_kds_performance(
    uuid, uuid, date, text
  ) from public;
  grant execute on function catchmenu_kds.get_kds_performance(
    uuid, uuid, date, text
  ) to authenticated;

  revoke all on function catchmenu_payment.get_payment_summary(
    uuid, uuid, date
  ) from public;
  grant execute on function catchmenu_payment.get_payment_summary(
    uuid, uuid, date
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.get_daily_summary(
  uuid, uuid, date
) is
  'Returns comprehensive business day operational summary.
   Covers: sessions, orders, revenue, KDS performance,
   exceptions, and payment stats in a single call.
   Used by manager dashboard and end-of-day reporting.
   특허3: 운영 이벤트 원장 → 일별 KPI → AI Agent 학습 데이터.
   KDS on-time rate, no-show rate, cancellation rate
   are primary inputs for SOP Evolution Agent.';

comment on function catchmenu_kds.get_kds_performance(
  uuid, uuid, date, text
) is
  'Returns KDS timing KPI broken down by kitchen zone and hour.
   avg_hold_minutes: time from ticket creation to COMMITTED.
   avg_cooking_minutes: time from COOKING to READY.
   on_time_rate_pct: % of tickets completed within estimated_minutes.
   hourly_load: ticket distribution by hour for peak time analysis.
   특허2: KDS 수용상태 판단 기준 데이터 생성.
   특허3: KDS 성능 데이터 → Knowledge Gap 탐지 → SOP 개선.';

comment on function catchmenu_payment.get_payment_summary(
  uuid, uuid, date
) is
  'Returns payment breakdown by provider, status, and reconciliation.
   Used by manager for daily revenue reconciliation review.
   Highlights pending reconciliation items requiring attention.
   특허1: 금융권형 결제 대사 현황 조회.
   PENDING/MISMATCH 건수가 0이어야 일일 정산 완료.';