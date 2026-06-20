-- 0084_create_reconciliation_advanced_rpc.sql
-- Purpose: Advanced payment reconciliation RPCs.
--          Layer 2: POS vs 내부 원장 대사.
--          Layer 3: VAN/PG 정산 대사.
--          Reconciliation report and gap detection.
--          특허1 core: 금융권 4단계 대사 고도화.
-- Depends on: 0083_create_push_notification_rpc.sql
-- Creates:
--   catchmenu_payment.reconciliation_layer2_results (table)
--   catchmenu_payment.reconciliation_layer3_results (table)
--   catchmenu_payment.pg_settlement_files (table)
--   function catchmenu_payment.run_layer2_reconciliation(...)
--   function catchmenu_payment.run_layer3_reconciliation(...)
--   function catchmenu_payment.import_pg_settlement(...)
--   function catchmenu_payment.get_reconciliation_report(...)
--   function catchmenu_payment.resolve_reconciliation_gap(...)

-- =============================================
-- reconciliation_layer2_results table
-- Layer 2: POS 원장 vs 내부 결제 원장 대사
-- =============================================
create table if not exists
  catchmenu_payment.reconciliation_layer2_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 대사 기간
  recon_date date not null,
  recon_status text not null default 'RUNNING',

  -- POS 집계
  pos_order_count int not null default 0,
  pos_total_amount int not null default 0,
  pos_provider_code text,

  -- 내부 원장 집계
  internal_order_count int not null default 0,
  internal_total_amount int not null default 0,

  -- 차이
  count_diff int not null default 0,
  amount_diff int not null default 0,

  -- 불일치 항목
  missing_in_internal jsonb
    default '[]'::jsonb,
  missing_in_pos jsonb
    default '[]'::jsonb,
  amount_mismatches jsonb
    default '[]'::jsonb,

  -- 결과
  is_balanced boolean not null default false,
  gap_count int not null default 0,
  gap_total_amount int not null default 0,

  -- 실행 정보
  run_at timestamptz not null default now(),
  run_duration_ms int,
  run_by_type text default 'SYSTEM',

  created_at timestamptz not null default now(),

  constraint uq_layer2_recon unique (
    store_id, recon_date, pos_provider_code
  ),
  constraint chk_l2_status check (
    recon_status in (
      'RUNNING', 'BALANCED', 'GAP_DETECTED',
      'MANUAL_REVIEW', 'RESOLVED', 'FAILED'
    )
  )
);

create index if not exists idx_l2_recon_store
  on catchmenu_payment.reconciliation_layer2_results(
    store_id, recon_date desc
  );
create index if not exists idx_l2_recon_gap
  on catchmenu_payment.reconciliation_layer2_results(
    tenant_id, recon_status
  ) where recon_status = 'GAP_DETECTED';

alter table
  catchmenu_payment.reconciliation_layer2_results
  enable row level security;
alter table
  catchmenu_payment.reconciliation_layer2_results
  force row level security;

drop policy if exists l2_recon_isolation
  on catchmenu_payment.reconciliation_layer2_results;
create policy l2_recon_isolation
  on catchmenu_payment.reconciliation_layer2_results
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.reconciliation_layer2_results is
  'Layer 2 대사 결과.
   POS 원장(OKpos/토스POS) vs 내부 결제 원장.
   불일치 감지:
   - POS에 있지만 내부에 없는 주문
   - 내부에 있지만 POS에 없는 주문
   - 금액 불일치
   특허1: 금융권 4단계 대사 Layer 2.
   Gap 발견 시 reconciliation_cases 자동 생성.';


-- =============================================
-- reconciliation_layer3_results table
-- Layer 3: VAN/PG 정산 vs 내부 결제 원장 대사
-- =============================================
create table if not exists
  catchmenu_payment.reconciliation_layer3_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 대사 기간
  recon_date date not null,
  recon_status text not null default 'RUNNING',

  -- VAN/PG 정산 데이터
  provider_type text not null,
  settlement_file_id uuid,
  pg_tx_count int not null default 0,
  pg_total_amount int not null default 0,
  pg_fee_amount int not null default 0,
  pg_net_amount int not null default 0,

  -- 내부 원장
  internal_tx_count int not null default 0,
  internal_total_amount int not null default 0,

  -- 차이
  count_diff int not null default 0,
  amount_diff int not null default 0,
  fee_diff int not null default 0,

  -- 불일치
  missing_in_internal jsonb
    default '[]'::jsonb,
  missing_in_pg jsonb
    default '[]'::jsonb,
  amount_mismatches jsonb
    default '[]'::jsonb,
  fee_discrepancies jsonb
    default '[]'::jsonb,

  -- 결과
  is_balanced boolean not null default false,
  gap_count int not null default 0,
  gap_total_amount int not null default 0,

  run_at timestamptz not null default now(),
  run_duration_ms int,

  created_at timestamptz not null default now(),

  constraint uq_layer3_recon unique (
    store_id, recon_date, provider_type
  ),
  constraint chk_l3_status check (
    recon_status in (
      'RUNNING', 'BALANCED', 'GAP_DETECTED',
      'MANUAL_REVIEW', 'RESOLVED', 'FAILED'
    )
  )
);

create index if not exists idx_l3_recon_store
  on catchmenu_payment.reconciliation_layer3_results(
    store_id, recon_date desc
  );

alter table
  catchmenu_payment.reconciliation_layer3_results
  enable row level security;
alter table
  catchmenu_payment.reconciliation_layer3_results
  force row level security;

drop policy if exists l3_recon_isolation
  on catchmenu_payment.reconciliation_layer3_results;
create policy l3_recon_isolation
  on catchmenu_payment.reconciliation_layer3_results
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.reconciliation_layer3_results is
  'Layer 3 대사 결과.
   VAN/PG 정산 파일 vs 내부 결제 원장.
   provider_type: TOSS_PAYMENTS/NICE/KIS.
   fee_discrepancies: 수수료 불일치 감지.
   특허1: 금융권 4단계 대사 Layer 3.
   PG사가 실제로 입금한 금액과 내부 원장 비교.
   불일치 시 → reconciliation_cases 생성.';


-- =============================================
-- pg_settlement_files table
-- PG/VAN 정산 파일 원본 보관
-- =============================================
create table if not exists
  catchmenu_payment.pg_settlement_files (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 파일 정보
  provider_type text not null,
  settlement_date date not null,
  file_name text,
  file_type text not null default 'JSON',

  -- 정산 집계
  tx_count int not null default 0,
  total_amount int not null default 0,
  fee_amount int not null default 0,
  net_amount int not null default 0,
  refund_amount int not null default 0,

  -- 원본 데이터
  settlement_data jsonb not null
    default '[]'::jsonb,

  -- 처리 상태
  import_status text not null default 'IMPORTED',
  imported_at timestamptz not null default now(),
  processed_at timestamptz,
  layer3_result_id uuid,

  created_at timestamptz not null default now(),

  constraint uq_settlement_file unique (
    store_id, provider_type, settlement_date
  ),
  constraint chk_file_type check (
    file_type in (
      'JSON', 'CSV', 'EXCEL', 'XML'
    )
  ),
  constraint chk_import_status check (
    import_status in (
      'IMPORTED', 'PROCESSING',
      'RECONCILED', 'ERROR'
    )
  )
);

create index if not exists idx_settlement_files_store
  on catchmenu_payment.pg_settlement_files(
    store_id, settlement_date desc
  );

alter table catchmenu_payment.pg_settlement_files
  enable row level security;
alter table catchmenu_payment.pg_settlement_files
  force row level security;

drop policy if exists settlement_files_isolation
  on catchmenu_payment.pg_settlement_files;
create policy settlement_files_isolation
  on catchmenu_payment.pg_settlement_files
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.pg_settlement_files is
  'PG/VAN 정산 파일 원본 보관.
   settlement_data: 개별 거래 내역 jsonb 배열.
   특허1: 외부 정산 = Gateway 원본 보관.
   파일 import 후 → Layer 3 대사 실행.
   보관 의무: 5년 (금융 감사 대비).';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_payment.run_layer2_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_recon_date date default null,
  p_pos_provider_code text default 'OKPOS',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_start timestamptz;
  v_target_date date;
  v_timezone text;
  v_result_id uuid;
  v_pos_data jsonb;
  v_internal_data jsonb;
  v_missing_internal jsonb := '[]'::jsonb;
  v_missing_pos jsonb := '[]'::jsonb;
  v_amount_mismatches jsonb := '[]'::jsonb;
  v_pos_count int := 0;
  v_pos_amount int := 0;
  v_internal_count int := 0;
  v_internal_amount int := 0;
  v_gap_count int := 0;
  v_gap_amount int := 0;
  v_is_balanced boolean;
  v_status text;
begin
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_date := coalesce(
    p_recon_date,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ) - interval '1 day')::date
  );

  -- POS 거래 집계 (OKpos/Toss POS)
  case p_pos_provider_code
    when 'OKPOS' then
      select
        count(*),
        coalesce(sum(paid_amount), 0),
        coalesce(
          jsonb_agg(
            jsonb_build_object(
              'pos_order_id', okpos_order_id,
              'amount', paid_amount,
              'tx_type', okpos_tx_type
            )
          ) filter (
            where processing_status = 'COMPLETED'
          ),
          '[]'::jsonb
        )
      into v_pos_count, v_pos_amount, v_pos_data
      from catchmenu_integrations.okpos_transactions
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and business_day = v_target_date
        and okpos_tx_type = 'PAYMENT_CONFIRM'
        and processing_status = 'COMPLETED';

    when 'TOSS_POS' then
      select
        count(*),
        coalesce(sum(paid_amount), 0),
        coalesce(
          jsonb_agg(
            jsonb_build_object(
              'pos_order_id',
                toss_pos_order_id,
              'amount', paid_amount,
              'tx_type', toss_pos_tx_type
            )
          ) filter (
            where processing_status = 'COMPLETED'
          ),
          '[]'::jsonb
        )
      into v_pos_count, v_pos_amount, v_pos_data
      from catchmenu_integrations
        .toss_pos_transactions
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and business_day = v_target_date
        and toss_pos_tx_type = 'PAYMENT_CONFIRM'
        and processing_status = 'COMPLETED';

    else
      v_pos_count := 0;
      v_pos_amount := 0;
      v_pos_data := '[]'::jsonb;
  end case;

  -- 내부 결제 원장 집계
  select
    count(*),
    coalesce(sum(approved_amount), 0),
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'ledger_id', id,
          'approval_number',
            provider_approval_number,
          'amount', approved_amount,
          'provider_type', provider_type
        )
      ),
      '[]'::jsonb
    )
  into v_internal_count, v_internal_amount,
       v_internal_data
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_date
    and ledger_status = 'APPROVED'
    and provider_type like '%'
      || p_pos_provider_code || '%';

  -- 불일치 감지
  -- POS에 있지만 내부에 없는 거래
  if v_pos_count > v_internal_count then
    v_missing_internal := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'MISSING_IN_INTERNAL',
        'pos_count', v_pos_count,
        'internal_count', v_internal_count,
        'diff', v_pos_count - v_internal_count
      )
    );
    v_gap_count := v_gap_count + (
      v_pos_count - v_internal_count
    );
  end if;

  -- 내부에 있지만 POS에 없는 거래
  if v_internal_count > v_pos_count then
    v_missing_pos := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'MISSING_IN_POS',
        'pos_count', v_pos_count,
        'internal_count', v_internal_count,
        'diff', v_internal_count - v_pos_count
      )
    );
    v_gap_count := v_gap_count + (
      v_internal_count - v_pos_count
    );
  end if;

  -- 금액 불일치
  if abs(v_pos_amount - v_internal_amount) > 0 then
    v_amount_mismatches := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'AMOUNT_MISMATCH',
        'pos_amount', v_pos_amount,
        'internal_amount', v_internal_amount,
        'diff', v_pos_amount - v_internal_amount
      )
    );
    v_gap_amount := abs(
      v_pos_amount - v_internal_amount
    );
  end if;

  v_is_balanced :=
    v_gap_count = 0 and v_gap_amount = 0;

  v_status := case v_is_balanced
    when true then 'BALANCED'
    else 'GAP_DETECTED'
  end;

  -- 결과 저장
  insert into
    catchmenu_payment.reconciliation_layer2_results (
    tenant_id, store_id,
    recon_date, recon_status,
    pos_order_count, pos_total_amount,
    pos_provider_code,
    internal_order_count, internal_total_amount,
    count_diff, amount_diff,
    missing_in_internal, missing_in_pos,
    amount_mismatches,
    is_balanced, gap_count, gap_total_amount,
    run_at, run_duration_ms, run_by_type
  ) values (
    p_tenant_id, p_store_id,
    v_target_date, v_status,
    v_pos_count, v_pos_amount,
    p_pos_provider_code,
    v_internal_count, v_internal_amount,
    v_pos_count - v_internal_count,
    v_pos_amount - v_internal_amount,
    v_missing_internal, v_missing_pos,
    v_amount_mismatches,
    v_is_balanced, v_gap_count, v_gap_amount,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    'SYSTEM'
  )
  on conflict (store_id, recon_date, pos_provider_code)
  do update set
    recon_status = excluded.recon_status,
    pos_order_count = excluded.pos_order_count,
    pos_total_amount = excluded.pos_total_amount,
    internal_order_count =
      excluded.internal_order_count,
    internal_total_amount =
      excluded.internal_total_amount,
    count_diff = excluded.count_diff,
    amount_diff = excluded.amount_diff,
    missing_in_internal =
      excluded.missing_in_internal,
    missing_in_pos = excluded.missing_in_pos,
    amount_mismatches = excluded.amount_mismatches,
    is_balanced = excluded.is_balanced,
    gap_count = excluded.gap_count,
    gap_total_amount = excluded.gap_total_amount,
    run_at = now()
  returning id into v_result_id;

  -- Gap 발견 시 reconciliation_case 생성
  if not v_is_balanced then
    insert into
      catchmenu_payment.reconciliation_cases (
      tenant_id, store_id,
      case_type, case_status,
      case_severity,
      layer_number,
      subject_type, subject_id,
      amount_difference,
      case_description,
      correlation_id,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      'LAYER2_GAP', 'OPEN',
      case when v_gap_amount > 100000
        then 'CRITICAL' else 'HIGH'
      end,
      2,
      'recon_l2_result', v_result_id,
      v_gap_amount,
      'Layer 2 대사 불일치: '
        || p_pos_provider_code
        || ' | 건수차=' || v_gap_count
        || ' | 금액차=₩'
        || v_gap_amount,
      p_correlation_id,
      v_target_date, v_timezone
    )
    on conflict do nothing;

    -- CRITICAL 진단 로그
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'ERROR',
      p_log_domain := 'PAYMENT',
      p_log_event := 'layer2_recon_gap',
      p_message :=
        '[Layer2] 대사 불일치: '
        || p_pos_provider_code
        || ' | 날짜=' || v_target_date
        || ' | 건수차=' || v_gap_count
        || ' | 금액차=₩' || v_gap_amount,
      p_rpc_name := 'run_layer2_reconciliation',
      p_details := jsonb_build_object(
        'result_id', v_result_id,
        'recon_date', v_target_date,
        'pos_count', v_pos_count,
        'internal_count', v_internal_count,
        'pos_amount', v_pos_amount,
        'internal_amount', v_internal_amount
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'result_id', v_result_id,
    'recon_date', v_target_date,
    'pos_provider', p_pos_provider_code,
    'status', v_status,
    'is_balanced', v_is_balanced,
    'pos', jsonb_build_object(
      'count', v_pos_count,
      'amount', v_pos_amount
    ),
    'internal', jsonb_build_object(
      'count', v_internal_count,
      'amount', v_internal_amount
    ),
    'gaps', jsonb_build_object(
      'count_diff', v_gap_count,
      'amount_diff', v_gap_amount
    ),
    'message_code', case v_is_balanced
      when true then 'layer2_recon_balanced'
      else 'layer2_recon_gap_detected'
    end
  );
end;
$$;


create or replace function
  catchmenu_payment.import_pg_settlement(
  p_tenant_id uuid,
  p_store_id uuid,
  p_provider_type text,
  p_settlement_date date,
  p_settlement_data jsonb,
  p_file_name text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_file_id uuid;
  v_tx_count int := 0;
  v_total_amount int := 0;
  v_fee_amount int := 0;
  v_net_amount int := 0;
  v_refund_amount int := 0;
  v_tx jsonb;
begin
  -- 정산 데이터 집계
  for v_tx in
    select * from jsonb_array_elements(
      p_settlement_data
    )
  loop
    v_tx_count := v_tx_count + 1;

    v_total_amount := v_total_amount
      + coalesce(
        (v_tx->>'amount')::int, 0
      );
    v_fee_amount := v_fee_amount
      + coalesce(
        (v_tx->>'fee_amount')::int, 0
      );
    v_net_amount := v_net_amount
      + coalesce(
        (v_tx->>'net_amount')::int, 0
      );

    if coalesce(
      (v_tx->>'is_refund')::boolean, false
    ) then
      v_refund_amount := v_refund_amount
        + coalesce(
          (v_tx->>'amount')::int, 0
        );
    end if;
  end loop;

  -- 정산 파일 저장
  insert into
    catchmenu_payment.pg_settlement_files (
    tenant_id, store_id,
    provider_type, settlement_date,
    file_name, file_type,
    tx_count, total_amount,
    fee_amount, net_amount, refund_amount,
    settlement_data, import_status,
    imported_at
  ) values (
    p_tenant_id, p_store_id,
    p_provider_type, p_settlement_date,
    p_file_name, 'JSON',
    v_tx_count, v_total_amount,
    v_fee_amount, v_net_amount, v_refund_amount,
    p_settlement_data, 'IMPORTED',
    now()
  )
  on conflict (store_id, provider_type, settlement_date)
  do update set
    settlement_data = excluded.settlement_data,
    tx_count = excluded.tx_count,
    total_amount = excluded.total_amount,
    fee_amount = excluded.fee_amount,
    net_amount = excluded.net_amount,
    refund_amount = excluded.refund_amount,
    import_status = 'IMPORTED',
    imported_at = now()
  returning id into v_file_id;

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'PAYMENT',
    p_log_event := 'pg_settlement_imported',
    p_message :=
      p_provider_type || ' 정산 파일 임포트'
      || ' | 날짜=' || p_settlement_date
      || ' | 건수=' || v_tx_count
      || ' | 금액=₩' || v_total_amount,
    p_rpc_name := 'import_pg_settlement',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'file_id', v_file_id,
      'provider_type', p_provider_type,
      'settlement_date', p_settlement_date,
      'tx_count', v_tx_count,
      'net_amount', v_net_amount
    )
  );

  return jsonb_build_object(
    'success', true,
    'file_id', v_file_id,
    'provider_type', p_provider_type,
    'settlement_date', p_settlement_date,
    'summary', jsonb_build_object(
      'tx_count', v_tx_count,
      'total_amount', v_total_amount,
      'fee_amount', v_fee_amount,
      'net_amount', v_net_amount,
      'refund_amount', v_refund_amount
    ),
    'next_step', 'RUN_LAYER3_RECONCILIATION',
    'message_code', 'pg_settlement_imported'
  );
end;
$$;


create or replace function
  catchmenu_payment.run_layer3_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_recon_date date default null,
  p_provider_type text default 'TOSS_PAYMENTS',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_start timestamptz;
  v_target_date date;
  v_timezone text;
  v_result_id uuid;
  v_settlement record;
  v_internal_count int := 0;
  v_internal_amount int := 0;
  v_missing_internal jsonb := '[]'::jsonb;
  v_missing_pg jsonb := '[]'::jsonb;
  v_amount_mismatches jsonb := '[]'::jsonb;
  v_fee_discrepancies jsonb := '[]'::jsonb;
  v_gap_count int := 0;
  v_gap_amount int := 0;
  v_is_balanced boolean;
  v_status text;
  v_tx jsonb;
  v_approval_number text;
  v_internal_tx record;
begin
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_date := coalesce(
    p_recon_date,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ) - interval '1 day')::date
  );

  -- 정산 파일 조회
  select id, tx_count, total_amount,
         fee_amount, net_amount,
         settlement_data
  into v_settlement
  from catchmenu_payment.pg_settlement_files
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_type = p_provider_type
    and settlement_date = v_target_date;

  if v_settlement.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'settlement_file_not_found',
      'message', p_provider_type
        || ' 정산 파일이 없습니다. '
        || 'import_pg_settlement() 먼저 실행하세요.',
      'settlement_date', v_target_date
    );
  end if;

  -- 내부 원장 집계
  select
    count(*),
    coalesce(sum(approved_amount), 0)
  into v_internal_count, v_internal_amount
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_date
    and provider_type = p_provider_type
    and ledger_status = 'APPROVED';

  -- 개별 거래 대사
  for v_tx in
    select * from jsonb_array_elements(
      v_settlement.settlement_data
    )
  loop
    v_approval_number :=
      v_tx->>'approval_number';

    -- 내부 원장에서 승인번호로 조회
    select id, approved_amount, net_amount
    into v_internal_tx
    from catchmenu_payment.payment_ledger
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and provider_approval_number
        = v_approval_number
      and provider_type = p_provider_type
    limit 1;

    if v_internal_tx.id is null then
      -- PG에 있지만 내부에 없음
      v_missing_internal := v_missing_internal
        || jsonb_build_array(
          jsonb_build_object(
            'approval_number', v_approval_number,
            'pg_amount',
              (v_tx->>'amount')::int,
            'gap_type', 'IN_PG_NOT_INTERNAL'
          )
        );
      v_gap_count := v_gap_count + 1;
      v_gap_amount := v_gap_amount
        + coalesce(
          (v_tx->>'amount')::int, 0
        );

    elsif abs(
      v_internal_tx.approved_amount
      - (v_tx->>'amount')::int
    ) > 0 then
      -- 금액 불일치
      v_amount_mismatches := v_amount_mismatches
        || jsonb_build_array(
          jsonb_build_object(
            'approval_number', v_approval_number,
            'pg_amount',
              (v_tx->>'amount')::int,
            'internal_amount',
              v_internal_tx.approved_amount,
            'diff',
              (v_tx->>'amount')::int
              - v_internal_tx.approved_amount,
            'gap_type', 'AMOUNT_MISMATCH'
          )
        );
      v_gap_count := v_gap_count + 1;
      v_gap_amount := v_gap_amount + abs(
        (v_tx->>'amount')::int
        - v_internal_tx.approved_amount
      );
    end if;
  end loop;

  -- 전체 금액 비교
  if v_settlement.tx_count <> v_internal_count then
    v_missing_pg := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'COUNT_MISMATCH',
        'pg_count', v_settlement.tx_count,
        'internal_count', v_internal_count,
        'diff',
          v_settlement.tx_count
          - v_internal_count
      )
    );
  end if;

  v_is_balanced :=
    v_gap_count = 0
    and abs(
      v_settlement.total_amount
      - v_internal_amount
    ) = 0;

  v_status := case v_is_balanced
    when true then 'BALANCED'
    else 'GAP_DETECTED'
  end;

  -- 결과 저장
  insert into
    catchmenu_payment.reconciliation_layer3_results (
    tenant_id, store_id,
    recon_date, recon_status,
    provider_type, settlement_file_id,
    pg_tx_count, pg_total_amount,
    pg_fee_amount, pg_net_amount,
    internal_tx_count, internal_total_amount,
    count_diff, amount_diff,
    missing_in_internal, missing_in_pg,
    amount_mismatches, fee_discrepancies,
    is_balanced, gap_count, gap_total_amount,
    run_at, run_duration_ms
  ) values (
    p_tenant_id, p_store_id,
    v_target_date, v_status,
    p_provider_type, v_settlement.id,
    v_settlement.tx_count,
    v_settlement.total_amount,
    v_settlement.fee_amount,
    v_settlement.net_amount,
    v_internal_count, v_internal_amount,
    v_settlement.tx_count - v_internal_count,
    v_settlement.total_amount - v_internal_amount,
    v_missing_internal, v_missing_pg,
    v_amount_mismatches, v_fee_discrepancies,
    v_is_balanced, v_gap_count, v_gap_amount,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000
  )
  on conflict (store_id, recon_date, provider_type)
  do update set
    recon_status = excluded.recon_status,
    pg_tx_count = excluded.pg_tx_count,
    pg_total_amount = excluded.pg_total_amount,
    internal_tx_count = excluded.internal_tx_count,
    internal_total_amount =
      excluded.internal_total_amount,
    is_balanced = excluded.is_balanced,
    gap_count = excluded.gap_count,
    gap_total_amount = excluded.gap_total_amount,
    missing_in_internal =
      excluded.missing_in_internal,
    amount_mismatches = excluded.amount_mismatches,
    run_at = now()
  returning id into v_result_id;

  -- 정산 파일 처리 완료
  update catchmenu_payment.pg_settlement_files
  set
    import_status = 'RECONCILED',
    layer3_result_id = v_result_id,
    processed_at = now()
  where id = v_settlement.id;

  -- Gap 시 case 생성
  if not v_is_balanced then
    insert into
      catchmenu_payment.reconciliation_cases (
      tenant_id, store_id,
      case_type, case_status, case_severity,
      layer_number,
      subject_type, subject_id,
      amount_difference, case_description,
      correlation_id,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      'LAYER3_GAP', 'OPEN',
      case when v_gap_amount > 50000
        then 'CRITICAL' else 'HIGH'
      end,
      3,
      'recon_l3_result', v_result_id,
      v_gap_amount,
      'Layer 3 대사 불일치: '
        || p_provider_type
        || ' | 건수차='
          || (v_settlement.tx_count
            - v_internal_count)
        || ' | 금액차=₩' || v_gap_amount,
      p_correlation_id,
      v_target_date, v_timezone
    )
    on conflict do nothing;

    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'CRITICAL',
      p_log_domain := 'PAYMENT',
      p_log_event := 'layer3_recon_gap',
      p_message :=
        '[Layer3] PG 정산 불일치: '
        || p_provider_type
        || ' | 날짜=' || v_target_date
        || ' | 금액차=₩' || v_gap_amount,
      p_rpc_name := 'run_layer3_reconciliation',
      p_details := jsonb_build_object(
        'result_id', v_result_id,
        'pg_amount', v_settlement.total_amount,
        'internal_amount', v_internal_amount,
        'gap_amount', v_gap_amount,
        'gap_count', v_gap_count
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'result_id', v_result_id,
    'recon_date', v_target_date,
    'provider_type', p_provider_type,
    'status', v_status,
    'is_balanced', v_is_balanced,
    'pg', jsonb_build_object(
      'tx_count', v_settlement.tx_count,
      'total_amount', v_settlement.total_amount,
      'fee_amount', v_settlement.fee_amount,
      'net_amount', v_settlement.net_amount
    ),
    'internal', jsonb_build_object(
      'tx_count', v_internal_count,
      'total_amount', v_internal_amount
    ),
    'gaps', jsonb_build_object(
      'gap_count', v_gap_count,
      'gap_amount', v_gap_amount,
      'missing_in_internal',
        jsonb_array_length(v_missing_internal),
      'amount_mismatches',
        jsonb_array_length(v_amount_mismatches)
    ),
    'message_code', case v_is_balanced
      when true then 'layer3_recon_balanced'
      else 'layer3_recon_gap_detected'
    end
  );
end;
$$;


create or replace function
  catchmenu_payment.get_reconciliation_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_period_start date,
  p_period_end date
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_l1_summary jsonb;
  v_l2_summary jsonb;
  v_l3_summary jsonb;
  v_open_cases jsonb;
  v_overall_health text;
begin
  -- Layer 1 요약
  select jsonb_build_object(
    'total_days', count(distinct business_day),
    'balanced_days', count(*) filter (
      where reconciliation_status = 'BALANCED'
    ),
    'gap_days', count(*) filter (
      where reconciliation_status = 'GAP_DETECTED'
    ),
    'total_approved', coalesce(
      sum(approved_amount)
        filter (where ledger_status = 'APPROVED'),
      0
    ),
    'total_refunded', coalesce(
      sum(approved_amount)
        filter (where ledger_status = 'REFUNDED'),
      0
    ),
    'pending_reconciliation', count(*) filter (
      where reconciliation_status = 'PENDING'
    )
  )
  into v_l1_summary
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day between
      p_period_start and p_period_end;

  -- Layer 2 요약
  select jsonb_build_object(
    'total_runs', count(*),
    'balanced', count(*) filter (
      where recon_status = 'BALANCED'
    ),
    'gap_detected', count(*) filter (
      where recon_status = 'GAP_DETECTED'
    ),
    'total_gap_amount', coalesce(
      sum(gap_total_amount)
        filter (where not is_balanced),
      0
    )
  )
  into v_l2_summary
  from catchmenu_payment
    .reconciliation_layer2_results
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and recon_date between
      p_period_start and p_period_end;

  -- Layer 3 요약
  select jsonb_build_object(
    'total_runs', count(*),
    'balanced', count(*) filter (
      where recon_status = 'BALANCED'
    ),
    'gap_detected', count(*) filter (
      where recon_status = 'GAP_DETECTED'
    ),
    'total_gap_amount', coalesce(
      sum(gap_total_amount)
        filter (where not is_balanced),
      0
    ),
    'total_pg_fee', coalesce(
      sum(pg_fee_amount), 0
    )
  )
  into v_l3_summary
  from catchmenu_payment
    .reconciliation_layer3_results
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and recon_date between
      p_period_start and p_period_end;

  -- 미해결 대사 케이스
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'case_id', id,
        'case_type', case_type,
        'case_status', case_status,
        'case_severity', case_severity,
        'layer_number', layer_number,
        'amount_difference', amount_difference,
        'case_description', case_description,
        'created_at', created_at
      )
      order by
        case case_severity
          when 'CRITICAL' then 0
          when 'HIGH' then 1
          else 2
        end,
        created_at desc
    ),
    '[]'::jsonb
  )
  into v_open_cases
  from catchmenu_payment.reconciliation_cases
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and case_status in ('OPEN', 'INVESTIGATING')
    and business_day between
      p_period_start and p_period_end;

  -- 전체 건전성 판단
  v_overall_health := case
    when jsonb_array_length(v_open_cases) = 0
      then 'HEALTHY'
    when (
      select count(*) from jsonb_array_elements(
        v_open_cases
      ) c
      where c->>'case_severity' = 'CRITICAL'
    ) > 0
      then 'CRITICAL'
    else 'WARNING'
  end;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'period_start', p_period_start,
    'period_end', p_period_end,
    'overall_health', v_overall_health,
    'layer1', v_l1_summary,
    'layer2', v_l2_summary,
    'layer3', v_l3_summary,
    'open_cases', v_open_cases,
    'open_case_count',
      jsonb_array_length(v_open_cases),
    'message_code', 'recon_report_loaded'
  );
end;
$$;


create or replace function
  catchmenu_payment.resolve_reconciliation_gap(
  p_tenant_id uuid,
  p_store_id uuid,
  p_case_id uuid,
  p_resolution_type text,
  p_resolution_note text,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_case record;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  if p_resolution_type not in (
    'MANUAL_MATCH', 'WRITE_OFF',
    'PROVIDER_CONFIRMED', 'DATA_ENTRY_ERROR',
    'TIMING_DIFFERENCE', 'SYSTEM_ERROR'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_resolution_type',
      'allowed', jsonb_build_array(
        'MANUAL_MATCH', 'WRITE_OFF',
        'PROVIDER_CONFIRMED',
        'DATA_ENTRY_ERROR',
        'TIMING_DIFFERENCE', 'SYSTEM_ERROR'
      )
    );
  end if;

  select id, case_type, case_status,
         case_severity, layer_number,
         amount_difference, business_day
  into v_case
  from catchmenu_payment.reconciliation_cases
  where id = p_case_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_case.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'case_already_resolved',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'resolve_reconciliation_gap'
    );
  end if;

  if v_case.case_status = 'RESOLVED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'case_already_resolved',
      'case_id', p_case_id
    );
  end if;

  -- 케이스 해결
  update catchmenu_payment.reconciliation_cases
  set
    case_status = 'RESOLVED',
    resolution_type = p_resolution_type,
    resolution_note = p_resolution_note,
    resolved_at = now(),
    resolved_by = p_actor_id,
    updated_at = now()
  where id = p_case_id;

  -- Layer 결과 업데이트
  case v_case.layer_number
    when 2 then
      update catchmenu_payment
        .reconciliation_layer2_results
      set recon_status = 'RESOLVED'
      where id = v_case.subject_id;
    when 3 then
      update catchmenu_payment
        .reconciliation_layer3_results
      set recon_status = 'RESOLVED'
      where id = v_case.subject_id;
    else null;
  end case;

  -- 감사 기록
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'reconciliation_gap_resolved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'reconciliation_case',
    p_subject_id := p_case_id,
    p_decision := 'RESOLVED',
    p_decision_reason := p_resolution_type,
    p_decision_payload := jsonb_build_object(
      'case_type', v_case.case_type,
      'layer_number', v_case.layer_number,
      'amount_difference',
        v_case.amount_difference,
      'resolution_note', p_resolution_note
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'PAYMENT',
    p_log_event := 'recon_gap_resolved',
    p_message :=
      'Layer' || v_case.layer_number
      || ' 대사 Gap 해결: '
      || p_resolution_type
      || ' | 금액=₩' || v_case.amount_difference,
    p_rpc_name := 'resolve_reconciliation_gap',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'case_id', p_case_id,
      'case_type', v_case.case_type,
      'resolution_type', p_resolution_type
    )
  );

  return jsonb_build_object(
    'success', true,
    'case_id', p_case_id,
    'case_type', v_case.case_type,
    'layer_number', v_case.layer_number,
    'resolution_type', p_resolution_type,
    'amount_difference', v_case.amount_difference,
    'audit_id', v_audit_id,
    'message_code', 'recon_gap_resolved'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_payment.run_layer2_reconciliation(
      uuid, uuid, date, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.run_layer2_reconciliation(
      uuid, uuid, date, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.import_pg_settlement(
      uuid, uuid, text, date, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.import_pg_settlement(
      uuid, uuid, text, date, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.run_layer3_reconciliation(
      uuid, uuid, date, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.run_layer3_reconciliation(
      uuid, uuid, date, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.get_reconciliation_report(
      uuid, uuid, date, date
    ) from public;
  grant execute on function
    catchmenu_payment.get_reconciliation_report(
      uuid, uuid, date, date
    ) to authenticated;

  revoke all on function
    catchmenu_payment.resolve_reconciliation_gap(
      uuid, uuid, uuid, text, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_payment.resolve_reconciliation_gap(
      uuid, uuid, uuid, text, text, text, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_payment.run_layer2_reconciliation(
    uuid, uuid, date, text, text
  ) is
  'Layer 2 대사: POS 원장 vs 내부 결제 원장.
   비교 대상:
   - OKpos: okpos_transactions vs payment_ledger
   - Toss POS: toss_pos_transactions vs payment_ledger
   불일치 감지:
   1. 건수 차이 (POS vs 내부)
   2. 금액 차이
   3. POS에만 있는 거래
   4. 내부에만 있는 거래
   Gap 감지 시 → reconciliation_cases 자동 생성.
   특허1: 금융권 4단계 대사 Layer 2.
   권장 실행: 매일 00:30 (일일 마감 후).';

comment on function
  catchmenu_payment.run_layer3_reconciliation(
    uuid, uuid, date, text, text
  ) is
  'Layer 3 대사: PG 정산 파일 vs 내부 결제 원장.
   사전 조건: import_pg_settlement() 먼저 실행.
   승인번호 기반 1:1 거래 매칭.
   불일치 감지:
   1. PG에 있지만 내부에 없는 거래
   2. 금액 불일치
   3. 수수료 불일치
   Gap 감지 시 → CRITICAL 진단 로그 + case 생성.
   특허1: 금융권 4단계 대사 Layer 3.
   PG사 실제 입금액 = 내부 원장 검증.
   권장 실행: PG 정산 파일 수신 즉시.';