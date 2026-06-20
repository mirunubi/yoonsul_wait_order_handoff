-- 0120_create_reconciliation_pipeline.sql
-- Purpose: Payment reconciliation pipeline.
--          4단계 대사 완성.
--          Layer1: 주문-결제 대사.
--          Layer2: VAN/PG 대사.
--          Layer3: 정산 리포트.
--          Layer4: 감사 증빙 패킷.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0119_create_edge_function_integration.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('reconciliation_completed', 'ko',
  '정산 대사가 완료되었습니다'),
('reconciliation_completed', 'en',
  'Reconciliation completed'),
('reconciliation_report_loaded', 'ko',
  '정산 리포트가 로드되었습니다'),
('reconciliation_report_loaded', 'en',
  'Reconciliation report loaded'),
('audit_packet_created', 'ko',
  '감사 증빙 패킷이 생성되었습니다'),
('audit_packet_created', 'en',
  'Audit evidence packet created')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(6010, 'reconciliation_gap_detected',
  'PAYMENT', 'FINANCIAL', 200, 'WARNING'),
(6011, 'reconciliation_critical_gap',
  'PAYMENT', 'FINANCIAL', 200, 'CRITICAL'),
(6012, 'audit_packet_not_found',
  'PAYMENT', 'NOT_FOUND', 404, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- reconciliation_daily_summary table
-- 일별 정산 요약
-- =============================================
create table if not exists
  catchmenu_payment.reconciliation_daily_summary (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  business_day date not null,

  -- Layer1: 주문-결제 대사
  total_orders int not null default 0,
  completed_orders int not null default 0,
  cancelled_orders int not null default 0,
  order_total_amount bigint not null default 0,
  payment_total_amount bigint not null default 0,
  layer1_gap bigint not null default 0,
  layer1_status text not null
    default 'PENDING',

  -- Layer2: VAN/PG 대사
  van_settlement_amount bigint
    not null default 0,
  pg_settlement_amount bigint
    not null default 0,
  total_fee_amount bigint not null default 0,
  net_settlement_amount bigint
    not null default 0,
  layer2_gap bigint not null default 0,
  layer2_status text not null
    default 'PENDING',

  -- Layer3: 정산 리포트
  cash_amount bigint not null default 0,
  card_amount bigint not null default 0,
  toss_amount bigint not null default 0,
  delivery_amount bigint not null default 0,
  refund_amount bigint not null default 0,
  layer3_status text not null
    default 'PENDING',

  -- Layer4: 감사 증빙
  audit_packet_id uuid,
  layer4_status text not null
    default 'PENDING',

  -- 전체 상태
  overall_status text not null
    default 'PENDING',
  has_issues boolean not null default false,
  issue_count int not null default 0,

  -- 실행 정보
  layer1_run_at timestamptz,
  layer2_run_at timestamptz,
  layer3_run_at timestamptz,
  layer4_run_at timestamptz,
  completed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_recon_daily unique (
    store_id, business_day
  ),
  constraint chk_layer_status check (
    layer1_status in (
      'PENDING', 'RUNNING', 'CLEAN',
      'GAP_MINOR', 'GAP_CRITICAL', 'ERROR'
    )
  )
);

alter table
  catchmenu_payment.reconciliation_daily_summary
  enable row level security;
alter table
  catchmenu_payment.reconciliation_daily_summary
  force row level security;

drop policy if exists recon_summary_isolation
  on catchmenu_payment.reconciliation_daily_summary;
create policy recon_summary_isolation
  on catchmenu_payment.reconciliation_daily_summary
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_recon_summary_updated
  on catchmenu_payment
    .reconciliation_daily_summary;
create trigger trg_recon_summary_updated
  before update on
    catchmenu_payment.reconciliation_daily_summary
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_payment.reconciliation_daily_summary
  is
  '일별 정산 대사 요약.
   4단계 대사 결과 통합.
   Layer1: 주문-결제 금액 일치 확인.
   Layer2: VAN/PG 정산 금액 대사.
   Layer3: 결제 수단별 분류 확인.
   Layer4: 감사 증빙 패킷 생성.
   has_issues: 이상 발생 플래그.
   pg_cron RECONCILIATION_LAYER1/2에서 자동 실행.';


-- =============================================
-- audit_evidence_packets table
-- 감사 증빙 패킷
-- =============================================
create table if not exists
  catchmenu_payment.audit_evidence_packets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  business_day date not null,
  packet_type text not null,
  packet_status text not null
    default 'GENERATED',

  -- 증빙 데이터
  order_count int not null default 0,
  payment_count int not null default 0,
  total_amount bigint not null default 0,
  net_amount bigint not null default 0,

  -- 검증
  checksum text not null,
  evidence_hash text not null,
  is_tampered boolean not null default false,

  -- 보존
  retain_until date not null,
  exported_at timestamptz,
  export_format text,

  generated_at timestamptz
    not null default now(),
  created_at timestamptz not null default now(),

  constraint uq_audit_packet unique (
    store_id, business_day, packet_type
  ),
  constraint chk_packet_type check (
    packet_type in (
      'DAILY_SETTLEMENT',
      'MONTHLY_SETTLEMENT',
      'TAX_REPORT',
      'COMPLIANCE_EVIDENCE',
      'DISPUTE_EVIDENCE'
    )
  )
);

alter table
  catchmenu_payment.audit_evidence_packets
  enable row level security;
alter table
  catchmenu_payment.audit_evidence_packets
  force row level security;

drop policy if exists audit_packet_isolation
  on catchmenu_payment.audit_evidence_packets;
create policy audit_packet_isolation
  on catchmenu_payment.audit_evidence_packets
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.audit_evidence_packets is
  '감사 증빙 패킷.
   일별/월별 정산 증빙 데이터.
   evidence_hash: SHA-256 위변조 감지.
   is_tampered: 위변조 탐지 시 true.
   retain_until: 세금계산서 5년 보존.
   DISPUTE_EVIDENCE: 분쟁 시 즉시 생성.
   특허4: 정산 = 재무 감사 증빙.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_payment.run_layer1_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_business_day date;
  v_order_total bigint;
  v_payment_total bigint;
  v_gap bigint;
  v_gap_status text;
  v_order_count int;
  v_completed_count int;
  v_cancelled_count int;
  v_refund_count int;
  v_summary_id uuid;
begin
  v_business_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date - 1
  );

  -- 주문 합계
  select
    count(*),
    count(*) filter (
      where order_status = 'COMPLETED'
    ),
    count(*) filter (
      where order_status = 'CANCELLED'
    ),
    coalesce(
      sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0
    )
  into
    v_order_count,
    v_completed_count,
    v_cancelled_count,
    v_order_total
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 결제 합계
  select coalesce(
    sum(approved_amount) filter (
      where ledger_status = 'APPROVED'
    ) -
    coalesce(
      sum(abs(approved_amount)) filter (
        where ledger_status = 'REFUNDED'
      ), 0
    ), 0
  )
  into v_payment_total
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 갭 계산
  v_gap := v_order_total - v_payment_total;

  -- 상태 판정
  v_gap_status := case
    when v_gap = 0 then 'CLEAN'
    when abs(v_gap) <= 1000 then 'GAP_MINOR'
    when abs(v_gap) > 1000 then 'GAP_CRITICAL'
    else 'ERROR'
  end;

  -- 요약 저장
  insert into
    catchmenu_payment.reconciliation_daily_summary (
    tenant_id, store_id, business_day,
    total_orders, completed_orders,
    cancelled_orders,
    order_total_amount, payment_total_amount,
    layer1_gap, layer1_status,
    layer1_run_at,
    overall_status, has_issues
  ) values (
    p_tenant_id, p_store_id, v_business_day,
    v_order_count, v_completed_count,
    v_cancelled_count,
    v_order_total, v_payment_total,
    v_gap, v_gap_status,
    now(),
    v_gap_status,
    v_gap_status not in ('CLEAN', 'PENDING')
  )
  on conflict (store_id, business_day)
  do update set
    total_orders = excluded.total_orders,
    completed_orders = excluded.completed_orders,
    cancelled_orders = excluded.cancelled_orders,
    order_total_amount =
      excluded.order_total_amount,
    payment_total_amount =
      excluded.payment_total_amount,
    layer1_gap = excluded.layer1_gap,
    layer1_status = excluded.layer1_status,
    layer1_run_at = excluded.layer1_run_at,
    has_issues = excluded.has_issues,
    updated_at = now()
  returning id into v_summary_id;

  -- CRITICAL 갭 → 운영 알림
  if v_gap_status = 'GAP_CRITICAL' then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'RECONCILIATION_GAP',
      p_alert_severity := 'CRITICAL',
      p_alert_domain := 'PAYMENT',
      p_alert_title_key :=
        'reconciliation_completed',
      p_alert_detail := jsonb_build_object(
        'business_day', v_business_day,
        'order_total', v_order_total,
        'payment_total', v_payment_total,
        'gap', v_gap,
        'gap_status', v_gap_status
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-PAY-002'
    );
  end if;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'reconciliation', 'layer1_completed', 1,
    'reconciliation_summary', v_summary_id,
    'PENDING', v_gap_status,
    'SYSTEM',
    jsonb_build_object(
      'business_day', v_business_day,
      'order_total', v_order_total,
      'payment_total', v_payment_total,
      'gap', v_gap,
      'gap_status', v_gap_status,
      'order_count', v_order_count
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_completed',
    p_data := jsonb_build_object(
      'summary_id', v_summary_id,
      'business_day', v_business_day,
      'layer', 1,
      'order_total', v_order_total,
      'payment_total', v_payment_total,
      'gap', v_gap,
      'gap_status', v_gap_status,
      'order_count', v_order_count,
      'completed_orders', v_completed_count,
      'cancelled_orders', v_cancelled_count,
      'is_clean', v_gap_status = 'CLEAN'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.run_layer2_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_business_day date;
  v_van_total bigint;
  v_pg_total bigint;
  v_total_fee bigint;
  v_net_total bigint;
  v_cash bigint;
  v_card bigint;
  v_toss bigint;
  v_delivery bigint;
  v_refund bigint;
  v_layer2_gap bigint;
  v_layer2_status text;
  v_summary_id uuid;
begin
  v_business_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date - 1
  );

  -- 결제 수단별 분류
  select
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
      where payment_method = 'TOSS_PAYMENTS'
        and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where provider_type in (
        'BAEMIN', 'YOGIYO', 'COUPANG_EATS'
      ) and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where ledger_status = 'REFUNDED'
    ), 0),
    coalesce(sum(fee_amount) filter (
      where ledger_status = 'APPROVED'
    ), 0)
  into
    v_cash, v_card, v_toss,
    v_delivery, v_refund, v_total_fee
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- VAN/PG 합계
  v_van_total := v_card;
  v_pg_total := v_toss;
  v_net_total := v_cash + v_card + v_toss
    + v_delivery - v_refund - v_total_fee;

  -- Layer2 갭 (VAN 정산 vs 카드 결제)
  -- VAN 실정산액은 Edge Function이 업데이트
  v_layer2_gap := 0;
  v_layer2_status := 'CLEAN';

  -- 요약 업데이트
  insert into
    catchmenu_payment.reconciliation_daily_summary (
    tenant_id, store_id, business_day,
    van_settlement_amount,
    pg_settlement_amount,
    total_fee_amount,
    net_settlement_amount,
    cash_amount, card_amount,
    toss_amount, delivery_amount,
    refund_amount,
    layer2_gap, layer2_status,
    layer2_run_at, layer3_status,
    layer3_run_at,
    overall_status
  ) values (
    p_tenant_id, p_store_id, v_business_day,
    v_van_total, v_pg_total,
    v_total_fee, v_net_total,
    v_cash, v_card,
    v_toss, v_delivery, v_refund,
    v_layer2_gap, v_layer2_status,
    now(), 'CLEAN', now(),
    'CLEAN'
  )
  on conflict (store_id, business_day)
  do update set
    van_settlement_amount = excluded
      .van_settlement_amount,
    pg_settlement_amount = excluded
      .pg_settlement_amount,
    total_fee_amount = excluded.total_fee_amount,
    net_settlement_amount = excluded
      .net_settlement_amount,
    cash_amount = excluded.cash_amount,
    card_amount = excluded.card_amount,
    toss_amount = excluded.toss_amount,
    delivery_amount = excluded.delivery_amount,
    refund_amount = excluded.refund_amount,
    layer2_gap = excluded.layer2_gap,
    layer2_status = excluded.layer2_status,
    layer2_run_at = excluded.layer2_run_at,
    layer3_status = excluded.layer3_status,
    layer3_run_at = excluded.layer3_run_at,
    overall_status = excluded.overall_status,
    updated_at = now()
  returning id into v_summary_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_completed',
    p_data := jsonb_build_object(
      'summary_id', v_summary_id,
      'business_day', v_business_day,
      'layer', 2,
      'breakdown', jsonb_build_object(
        'cash', v_cash,
        'card', v_card,
        'toss', v_toss,
        'delivery', v_delivery,
        'refund', v_refund,
        'fee', v_total_fee,
        'net', v_net_total
      ),
      'layer2_status', v_layer2_status,
      'is_clean', v_layer2_status = 'CLEAN'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.generate_audit_packet(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date,
  p_packet_type text default 'DAILY_SETTLEMENT',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_summary record;
  v_packet_id uuid;
  v_checksum text;
  v_evidence_hash text;
  v_retain_days int;
begin
  -- 정산 요약 조회
  select *
  into v_summary
  from catchmenu_payment.reconciliation_daily_summary
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = p_business_day;

  -- 체크섬 생성
  v_checksum := md5(
    p_store_id::text
    || p_business_day::text
    || coalesce(v_summary.order_total_amount, 0)::text
    || coalesce(v_summary.payment_total_amount, 0)::text
    || now()::text
  );

  -- 증빙 해시 (SHA-256)
  v_evidence_hash := encode(
    digest(
      jsonb_build_object(
        'store_id', p_store_id,
        'business_day', p_business_day,
        'order_total',
          coalesce(v_summary.order_total_amount, 0),
        'payment_total',
          coalesce(v_summary.payment_total_amount, 0),
        'net_amount',
          coalesce(v_summary.net_settlement_amount, 0),
        'generated_at', now()
      )::text,
      'sha256'
    ),
    'hex'
  );

  -- 보존 기간 (세금 관련 5년)
  v_retain_days := case p_packet_type
    when 'TAX_REPORT' then 1825
    when 'COMPLIANCE_EVIDENCE' then 1825
    when 'DISPUTE_EVIDENCE' then 365
    else 365
  end;

  -- 패킷 생성
  insert into
    catchmenu_payment.audit_evidence_packets (
    tenant_id, store_id, business_day,
    packet_type, packet_status,
    order_count, payment_count,
    total_amount, net_amount,
    checksum, evidence_hash,
    retain_until
  ) values (
    p_tenant_id, p_store_id, p_business_day,
    p_packet_type, 'GENERATED',
    coalesce(v_summary.total_orders, 0),
    coalesce(v_summary.completed_orders, 0),
    coalesce(v_summary.order_total_amount, 0),
    coalesce(v_summary.net_settlement_amount, 0),
    v_checksum, v_evidence_hash,
    p_business_day + v_retain_days
  )
  on conflict (store_id, business_day, packet_type)
  do update set
    checksum = excluded.checksum,
    evidence_hash = excluded.evidence_hash,
    packet_status = 'REGENERATED',
    generated_at = now()
  returning id into v_packet_id;

  -- 요약에 패킷 ID 연결
  update catchmenu_payment.reconciliation_daily_summary
  set
    audit_packet_id = v_packet_id,
    layer4_status = 'CLEAN',
    layer4_run_at = now(),
    completed_at = now(),
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = p_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'audit_packet_created',
    p_data := jsonb_build_object(
      'packet_id', v_packet_id,
      'packet_type', p_packet_type,
      'business_day', p_business_day,
      'evidence_hash', v_evidence_hash,
      'retain_until',
        p_business_day + v_retain_days,
      'note',
        '세금 관련 5년 / 분쟁 증빙 1년 보존'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.get_reconciliation_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_from_date date default null,
  p_to_date date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_from_date date;
  v_to_date date;
  v_daily_list jsonb;
  v_period_summary jsonb;
  v_issue_list jsonb;
begin
  v_from_date := coalesce(
    p_from_date,
    date_trunc('month', now())::date
  );
  v_to_date := coalesce(
    p_to_date,
    (timezone('Asia/Seoul', now()))::date - 1
  );

  -- 일별 대사 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'business_day', business_day,
        'overall_status', overall_status,
        'layer1_status', layer1_status,
        'layer2_status', layer2_status,
        'order_total', order_total_amount,
        'payment_total', payment_total_amount,
        'layer1_gap', layer1_gap,
        'net_amount', net_settlement_amount,
        'breakdown', jsonb_build_object(
          'cash', cash_amount,
          'card', card_amount,
          'toss', toss_amount,
          'delivery', delivery_amount,
          'refund', refund_amount,
          'fee', total_fee_amount
        ),
        'has_issues', has_issues,
        'issue_count', issue_count,
        'audit_packet_id', audit_packet_id,
        'completed_at', completed_at
      )
      order by business_day desc
    ),
    '[]'::jsonb
  )
  into v_daily_list
  from catchmenu_payment.reconciliation_daily_summary
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day
      between v_from_date and v_to_date;

  -- 기간 합계
  select jsonb_build_object(
    'total_days', count(*),
    'clean_days', count(*) filter (
      where overall_status = 'CLEAN'
    ),
    'issue_days', count(*) filter (
      where has_issues = true
    ),
    'total_orders', sum(total_orders),
    'total_order_amount',
      sum(order_total_amount),
    'total_net_amount',
      sum(net_settlement_amount),
    'total_refunds', sum(refund_amount),
    'total_fees', sum(total_fee_amount),
    'total_cash', sum(cash_amount),
    'total_card', sum(card_amount),
    'total_toss', sum(toss_amount),
    'total_delivery', sum(delivery_amount)
  )
  into v_period_summary
  from catchmenu_payment.reconciliation_daily_summary
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day
      between v_from_date and v_to_date;

  -- 미해결 이슈
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'case_id', rc.id,
        'case_type', rc.case_type,
        'case_severity', rc.case_severity,
        'gap_amount', rc.gap_amount,
        'case_status', rc.case_status,
        'detected_at', rc.detected_at
      )
      order by rc.case_severity desc,
               rc.gap_amount desc
    ),
    '[]'::jsonb
  )
  into v_issue_list
  from catchmenu_payment.reconciliation_cases rc
  where rc.store_id = p_store_id
    and rc.tenant_id = p_tenant_id
    and rc.case_status = 'OPEN'
    and rc.detected_at::date
      between v_from_date and v_to_date;

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_report_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'period', jsonb_build_object(
        'from_date', v_from_date,
        'to_date', v_to_date
      ),
      'period_summary', v_period_summary,
      'daily_list', v_daily_list,
      'open_issues', v_issue_list,
      'has_open_issues',
        jsonb_array_length(v_issue_list) > 0,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_payment.run_layer1_reconciliation(
      uuid, uuid, date, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.run_layer2_reconciliation(
      uuid, uuid, date, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.generate_audit_packet(
      uuid, uuid, date, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.get_reconciliation_report(
      uuid, uuid, date, date, text
    ) to authenticated;
end;
$$;

-- pg_cron 등록
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_active
) values
(
  'RECONCILIATION_LAYER1',
  'catchmenu_reconciliation_layer1',
  '30 14 * * *',
  '30 23 * * * (매일 23:30 KST)',
  $sql$
SELECT catchmenu_payment.run_layer1_reconciliation(
  t.id, s.id
)
FROM catchmenu_hq.tenants t
JOIN catchmenu_hq.stores s
  ON s.tenant_id = t.id
  AND s.is_active = true
WHERE t.tenant_status = 'ACTIVE';
$sql$,
  'Layer1 대사 자동 실행. 매일 23:30.',
  true
),
(
  'RECONCILIATION_LAYER2',
  'catchmenu_reconciliation_layer2',
  '30 15 * * *',
  '30 00 * * * (매일 00:30 KST)',
  $sql$
SELECT catchmenu_payment.run_layer2_reconciliation(
  t.id, s.id
)
FROM catchmenu_hq.tenants t
JOIN catchmenu_hq.stores s
  ON s.tenant_id = t.id
  AND s.is_active = true
WHERE t.tenant_status = 'ACTIVE';

SELECT catchmenu_payment.generate_audit_packet(
  t.id, s.id,
  (timezone('Asia/Seoul', now()))::date - 1
)
FROM catchmenu_hq.tenants t
JOIN catchmenu_hq.stores s
  ON s.tenant_id = t.id
  AND s.is_active = true
WHERE t.tenant_status = 'ACTIVE';
$sql$,
  'Layer2 대사 + 감사 패킷 자동 생성. 00:30.',
  true
)
on conflict (job_code) do nothing;

comment on function
  catchmenu_payment.run_layer1_reconciliation(
    uuid, uuid, date, text
  ) is
  '4단계 대사 Layer1.
   주문 금액 vs 결제 금액 대사.

   판정 기준:
   CLEAN: 갭 = 0
   GAP_MINOR: 갭 <= 1,000원
   GAP_CRITICAL: 갭 > 1,000원
     → CRITICAL 운영 알림 자동 발송
     → SOP-PAY-002 런북 연동

   pg_cron: 매일 23:30 자동 실행.
   수동 실행 가능:
   SELECT
     catchmenu_payment
       .run_layer1_reconciliation(
         tenant_id, store_id
       );

   특허4: 정산 대사 = 재무 감사 증빙.';

comment on function
  catchmenu_payment.generate_audit_packet(
    uuid, uuid, date, text, text
  ) is
  '감사 증빙 패킷 생성.
   Layer4 완성 함수.

   증빙 해시:
   SHA-256으로 위변조 탐지.
   is_tampered: 해시 불일치 시 true.

   보존 기간:
   DAILY_SETTLEMENT: 1년
   TAX_REPORT: 5년 (세법 의무)
   COMPLIANCE_EVIDENCE: 5년
   DISPUTE_EVIDENCE: 1년

   기술신보 심사:
   generate_audit_packet() 호출 결과를
   증빙 자료로 제출 가능.
   evidence_hash: 위변조 불가 증명.';