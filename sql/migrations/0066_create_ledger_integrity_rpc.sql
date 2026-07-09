-- 0066_create_ledger_integrity_rpc.sql
-- Purpose: Event ledger integrity validation and replay verification.
--          verify_event_ledger_integrity: checks event chain consistency.
--          verify_audit_chain: validates audit record immutability.
--          run_state_projection_check: verifies current state matches
--            event log projection.
--          reconcile_ledger_gaps: detects and reports missing events.
--          특허4 core: 4원장 무결성 검증 + Event Replay 일관성 확인.
-- Depends on: 0065_create_security_isolation_rpc.sql
-- Creates:
--   catchmenu_ledger.integrity_check_results (table)
--   function catchmenu_ledger.verify_event_ledger_integrity(...)
--   function catchmenu_ledger.verify_audit_chain(...)
--   function catchmenu_ledger.run_state_projection_check(...)
--   function catchmenu_ledger.reconcile_ledger_gaps(...)

-- =============================================
-- integrity_check_results table
-- =============================================
create table if not exists
  catchmenu_ledger.integrity_check_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  check_type text not null,
  check_scope text not null,
  check_status text not null default 'PENDING',

  -- results
  total_records int not null default 0,
  valid_records int not null default 0,
  invalid_records int not null default 0,

  -- findings
  anomalies jsonb default '[]'::jsonb,
  gaps jsonb default '[]'::jsonb,
  projection_mismatches jsonb default '[]'::jsonb,

  -- integrity hash
  event_chain_hash text,
  audit_chain_hash text,

  -- meta
  check_started_at timestamptz not null default now(),
  check_completed_at timestamptz,
  check_duration_ms int,
  business_day date,

  created_at timestamptz not null default now(),

  constraint chk_check_type check (
    check_type in (
      'EVENT_CHAIN', 'AUDIT_CHAIN',
      'STATE_PROJECTION', 'GAP_DETECTION',
      'FULL_INTEGRITY'
    )
  ),
  constraint chk_check_status check (
    check_status in (
      'PENDING', 'RUNNING', 'PASSED',
      'FAILED', 'WARNING'
    )
  )
);

create index if not exists idx_integrity_tenant
  on catchmenu_ledger.integrity_check_results(
    tenant_id, check_type, check_started_at desc
  );
create index if not exists idx_integrity_status
  on catchmenu_ledger.integrity_check_results(
    check_status, check_started_at desc
  );

alter table catchmenu_ledger.integrity_check_results
  enable row level security;
alter table catchmenu_ledger.integrity_check_results
  force row level security;

drop policy if exists integrity_check_isolation
  on catchmenu_ledger.integrity_check_results;
create policy integrity_check_isolation
  on catchmenu_ledger.integrity_check_results
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_ledger.integrity_check_results is
  '4-ledger integrity check results.
   Stores event chain hash for replay validation.
   Stores audit chain hash for immutability proof.
   특허4: 4원장 무결성 증빙 — append-only 보장.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_ledger.verify_event_ledger_integrity(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_event_domain text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_total int := 0;
  v_valid int := 0;
  v_invalid int := 0;
  v_anomalies jsonb := '[]'::jsonb;
  v_chain_hash text;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- insert check record
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'EVENT_CHAIN', 'RUNNING',
    coalesce(p_event_domain, 'ALL'),
    v_target_day
  );

  -- count total events for day
  select count(*)
  into v_total
  from catchmenu_ledger.events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and (
      p_event_domain is null
      or event_domain = p_event_domain
    );

  -- CHECK 1: Future events (occurred_at > now)
  with future_events as (
    select id, event_type, event_domain,
           occurred_at
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and occurred_at > now() + interval '5 minutes'
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'FUTURE_EVENT',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail',
          'Events with future occurred_at timestamp',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from future_events limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end, count(*)
  into v_anomalies, v_invalid
  from future_events;

  -- CHECK 2: Events without valid subject reference
  with orphaned_events as (
    select id, event_type, event_domain,
           subject_type, subject_id
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and subject_id is not null
      and is_replay = false
      -- check for known subject types
      -- that should have real references
      and event_domain = 'payment'
      and subject_type = 'payment_ledger'
      and not exists (
        select 1
        from catchmenu_payment.payment_ledger pl
        where pl.id = subject_id
          and pl.tenant_id = p_tenant_id
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'ORPHANED_PAYMENT_EVENT',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Payment events with no ledger reference',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from orphaned_events limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from orphaned_events;

  -- CHECK 3: Replay events without original_event_id
  with bad_replays as (
    select id, event_type, event_domain
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and is_replay = true
      and original_event_id is null
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'REPLAY_WITHOUT_ORIGIN',
        'severity', 'MEDIUM',
        'count', count(*),
        'detail',
          'Replay events missing original_event_id',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from bad_replays limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from bad_replays;

  -- CHECK 4: Duplicate correlation_ids
  -- (same correlation = same request)
  -- multiple successful payment events
  -- with same correlation = double charge risk
  with dup_payments as (
    select correlation_id, count(*) as cnt
    from catchmenu_ledger.events
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and event_type = 'payment_confirmed'
      and correlation_id is not null
      and is_replay = false
    group by correlation_id
    having count(*) > 1
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'DUPLICATE_PAYMENT_CONFIRMED',
        'severity', 'CRITICAL',
        'count', count(*),
        'total_duplicates', sum(cnt),
        'detail',
          'Multiple payment_confirmed events '
          || 'with same correlation_id. '
          || 'POSSIBLE DOUBLE CHARGE.',
        'correlation_ids', (
          select coalesce(
            jsonb_agg(sample.correlation_id),
            '[]'::jsonb
          )
          from (
            select correlation_id from dup_payments limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from dup_payments;

  -- CHECK 5: Payment events without KDS events
  -- (payment confirmed but no KDS condition update)
  with payment_no_kds as (
    select e.id, e.order_id, e.occurred_at
    from catchmenu_ledger.events e
    where e.store_id = p_store_id
      and e.tenant_id = p_tenant_id
      and e.business_day = v_target_day
      and e.event_type = 'payment_confirmed'
      and e.is_replay = false
      and not exists (
        select 1
        from catchmenu_ledger.events e2
        where e2.order_id = e.order_id
          and e2.event_domain = 'kds'
          and e2.event_type in (
            'kds_condition_updated',
            'condition_updated',
            'kds_bulk_commit_attempted'
          )
          and e2.occurred_at >= e.occurred_at
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'PAYMENT_NO_KDS_UPDATE',
        'severity', 'MEDIUM',
        'count', count(*),
        'detail',
          'Payment confirmed but no KDS condition update',
        'order_ids', (
          select coalesce(
            jsonb_agg(sample.order_id),
            '[]'::jsonb
          )
          from (
            select order_id from payment_no_kds limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from payment_no_kds;

  -- compute chain hash for integrity proof
  select encode(
    digest(
      string_agg(
        id::text || occurred_at::text
        || event_type || coalesce(
          subject_id::text, ''
        ),
        '|' order by occurred_at, id
      ),
      'sha256'
    ),
    'hex'
  )
  into v_chain_hash
  from catchmenu_ledger.events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  v_invalid := jsonb_array_length(v_anomalies);
  v_valid := v_total - v_invalid;

  -- update check result
  update catchmenu_ledger.integrity_check_results
  set
    check_status = case v_invalid
      when 0 then 'PASSED'
      else 'FAILED'
    end,
    total_records = v_total,
    valid_records = greatest(v_valid, 0),
    invalid_records = v_invalid,
    anomalies = v_anomalies,
    event_chain_hash = v_chain_hash,
    check_completed_at = now(),
    check_duration_ms = extract(
      epoch from (now() - v_start)
    )::int * 1000
  where id = v_check_id;

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := case v_invalid
      when 0 then 'INFO'
      else 'WARNING'
    end,
    p_log_domain := 'SYSTEM',
    p_log_event := 'event_ledger_integrity_checked',
    p_message :=
      'Event ledger integrity: '
      || v_total || ' events checked'
      || ', ' || v_invalid || ' anomalies'
      || ' hash=' || coalesce(
        left(v_chain_hash, 16), 'null'
      ),
    p_rpc_name := 'verify_event_ledger_integrity',
    p_details := jsonb_build_object(
      'check_id', v_check_id,
      'total', v_total,
      'valid', v_valid,
      'invalid', v_invalid,
      'business_day', v_target_day,
      'event_domain', p_event_domain
    )
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'EVENT_CHAIN',
    'business_day', v_target_day,
    'event_domain_filter', p_event_domain,
    'result', jsonb_build_object(
      'total_events', v_total,
      'valid_events', greatest(v_valid, 0),
      'anomaly_count', v_invalid,
      'status', case v_invalid
        when 0 then 'PASSED'
        else 'FAILED'
      end,
      'event_chain_hash', v_chain_hash,
      'chain_hash_prefix',
        left(coalesce(v_chain_hash, ''), 16)
    ),
    'anomalies', v_anomalies,
    'message_code', case v_invalid
      when 0 then 'event_integrity_passed'
      else 'event_integrity_anomalies_found'
    end
  );
end;
$$;


create or replace function
  catchmenu_ledger.verify_audit_chain(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_total int;
  v_anomalies jsonb := '[]'::jsonb;
  v_chain_hash text;
  v_modified_count int;
  v_missing_decision int;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- total audit records for day
  select count(*)
  into v_total
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- CHECK 1: Audit records with modified timestamps
  -- (append-only: recorded_at = created_at)
  select count(*)
  into v_modified_count
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and recorded_at <> created_at;

  if v_modified_count > 0 then
    v_anomalies := v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'AUDIT_RECORD_MODIFIED',
        'severity', 'CRITICAL',
        'count', v_modified_count,
        'detail',
          'Audit records have been modified '
          || '(recorded_at ≠ created_at). '
          || 'POSSIBLE TAMPERING.',
        'remediation',
          'Investigate immediately. '
          || 'Compare with backup/WAL logs.'
      )
    );
  end if;

  -- CHECK 2: Audit records without decision
  select count(*)
  into v_missing_decision
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day
    and (
      audit_decision is null
      or trim(audit_decision) = ''
    );

  if v_missing_decision > 0 then
    v_anomalies := v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'AUDIT_MISSING_DECISION',
        'severity', 'HIGH',
        'count', v_missing_decision,
        'detail',
          'Audit records missing decision field'
      )
    );
  end if;

  -- CHECK 3: Financial audit records without
  -- actor (anonymous financial action = high risk)
  with anon_financial as (
    select id, audit_type, audit_category,
           recorded_at
    from catchmenu_ledger.audit_records
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and audit_category = 'FINANCIAL'
      and actor_id is null
      and actor_type not in (
        'PROVIDER', 'SYSTEM', 'TOSS_PAYMENTS',
        'NICE_PAYMENTS', 'KIS'
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type',
          'ANONYMOUS_FINANCIAL_AUDIT',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Financial audit records without actor_id',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from anon_financial limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from anon_financial;

  -- CHECK 4: Audit records with future timestamps
  with future_audit as (
    select id, audit_type, recorded_at
    from catchmenu_ledger.audit_records
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_target_day
      and recorded_at > now() + interval '5 minutes'
    limit 10
  )
  select case when count(*) > 0 then
    v_anomalies || jsonb_build_array(
      jsonb_build_object(
        'anomaly_type', 'FUTURE_AUDIT_TIMESTAMP',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail',
          'Audit records with future timestamps',
        'sample_ids', (
          select coalesce(jsonb_agg(sample.id), '[]'::jsonb)
          from (
            select id from future_audit limit 5
          ) sample
        )
      )
    )
    else v_anomalies
  end
  into v_anomalies
  from future_audit;

  -- compute audit chain hash
  select encode(
    digest(
      string_agg(
        id::text || recorded_at::text
        || audit_type
        || coalesce(actor_id::text, 'SYSTEM')
        || coalesce(audit_decision, ''),
        '|' order by recorded_at, id
      ),
      'sha256'
    ),
    'hex'
  )
  into v_chain_hash
  from catchmenu_ledger.audit_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_day;

  -- store check result
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    total_records, valid_records, invalid_records,
    anomalies, audit_chain_hash,
    check_completed_at, check_duration_ms,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'AUDIT_CHAIN',
    case jsonb_array_length(v_anomalies)
      when 0 then 'PASSED'
      else 'FAILED'
    end,
    'DAILY',
    v_total,
    v_total - jsonb_array_length(v_anomalies),
    jsonb_array_length(v_anomalies),
    v_anomalies, v_chain_hash,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    v_target_day
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'AUDIT_CHAIN',
    'business_day', v_target_day,
    'result', jsonb_build_object(
      'total_audit_records', v_total,
      'anomaly_count',
        jsonb_array_length(v_anomalies),
      'status', case jsonb_array_length(v_anomalies)
        when 0 then 'PASSED'
        else 'FAILED'
      end,
      'audit_chain_hash', v_chain_hash,
      'chain_hash_prefix',
        left(coalesce(v_chain_hash, ''), 16),
      'is_immutable',
        jsonb_array_length(v_anomalies) = 0
    ),
    'anomalies', v_anomalies,
    'message_code', case
      when jsonb_array_length(v_anomalies) = 0
      then 'audit_chain_intact'
      else 'audit_chain_anomalies_detected'
    end
  );
end;
$$;


create or replace function
  catchmenu_ledger.run_state_projection_check(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_mismatches jsonb := '[]'::jsonb;
  v_total_checked int := 0;
  v_mismatch_count int := 0;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- PROJECT 1: Payment status projection
  -- Current state in payment_ledger
  -- must match last payment event to_state
  with payment_projection as (
    select
      pl.id as ledger_id,
      pl.ledger_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_payment.payment_ledger pl
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.payment_id = pl.id
        and e.event_domain = 'payment'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.business_day = v_target_day
      and last_evt.to_state is not null
      and pl.ledger_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'PAYMENT_STATE',
          'severity', 'HIGH',
          'mismatch_count', count(*),
          'detail',
            'Payment ledger state does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'ledger_id', ledger_id,
                'current', current_status,
                'projected', projected_status
              ) as item
              from payment_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from payment_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- PROJECT 2: Order status projection
  -- last order event to_state must
  -- match orders.order_status
  with order_projection as (
    select
      o.id as order_id,
      o.order_number,
      o.order_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_pos.orders o
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.order_id = o.id
        and e.event_domain = 'order'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_target_day
      and last_evt.to_state is not null
      and o.order_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'ORDER_STATE',
          'severity', 'MEDIUM',
          'mismatch_count', count(*),
          'detail',
            'Order status does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'order_id', order_id,
                'order_number', order_number,
                'current', current_status,
                'projected', projected_status
              ) as item
              from order_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from order_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- PROJECT 3: KDS state projection
  -- KDS ticket status vs last KDS event
  with kds_projection as (
    select
      kt.id as ticket_id,
      kt.ticket_number,
      kt.kds_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_kds.kds_tickets kt
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.kds_ticket_id = kt.id
        and e.event_domain = 'kds'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where kt.store_id = p_store_id
      and kt.tenant_id = p_tenant_id
      and kt.business_day = v_target_day
      and last_evt.to_state is not null
      and kt.kds_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'KDS_STATE',
          'severity', 'HIGH',
          'mismatch_count', count(*),
          'detail',
            'KDS ticket status does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'ticket_id', ticket_id,
                'ticket_number', ticket_number,
                'current', current_status,
                'projected', projected_status
              ) as item
              from kds_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from kds_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- PROJECT 4: Session state projection
  with session_projection as (
    select
      s.id as session_id,
      s.session_status as current_status,
      last_evt.to_state as projected_status
    from catchmenu_pos.order_sessions s
    join lateral (
      select to_state
      from catchmenu_ledger.events e
      where e.session_id = s.id
        and e.event_domain = 'session'
        and e.is_replay = false
      order by e.occurred_at desc
      limit 1
    ) last_evt on true
    where s.store_id = p_store_id
      and s.tenant_id = p_tenant_id
      and s.business_day = v_target_day
      and last_evt.to_state is not null
      and s.session_status <> last_evt.to_state
    limit 20
  )
  select
    count(*),
    case when count(*) > 0 then
      v_mismatches || jsonb_build_array(
        jsonb_build_object(
          'projection_type', 'SESSION_STATE',
          'severity', 'MEDIUM',
          'mismatch_count', count(*),
          'detail',
            'Session status does not match '
            || 'event projection',
          'sample', (
            select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
            from (
              select jsonb_build_object(
                'session_id', session_id,
                'current', current_status,
                'projected', projected_status
              ) as item
              from session_projection
              limit 5
            ) sample
          )
        )
      )
      else v_mismatches
    end
  into v_mismatch_count, v_mismatches
  from session_projection;

  v_total_checked := v_total_checked
    + v_mismatch_count;

  -- store check
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    total_records, invalid_records,
    projection_mismatches,
    check_completed_at, check_duration_ms,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'STATE_PROJECTION',
    case jsonb_array_length(v_mismatches)
      when 0 then 'PASSED'
      else 'WARNING'
    end,
    'DAILY',
    v_total_checked,
    jsonb_array_length(v_mismatches),
    v_mismatches,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    v_target_day
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'STATE_PROJECTION',
    'business_day', v_target_day,
    'result', jsonb_build_object(
      'total_checked', v_total_checked,
      'mismatch_count',
        jsonb_array_length(v_mismatches),
      'status', case jsonb_array_length(v_mismatches)
        when 0 then 'PASSED'
        else 'WARNING'
      end,
      'projections_checked', jsonb_build_array(
        'PAYMENT_STATE', 'ORDER_STATE',
        'KDS_STATE', 'SESSION_STATE'
      )
    ),
    'mismatches', v_mismatches,
    'message_code', case
      when jsonb_array_length(v_mismatches) = 0
      then 'state_projection_consistent'
      else 'state_projection_mismatches_found'
    end
  );
end;
$$;


create or replace function
  catchmenu_ledger.reconcile_ledger_gaps(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_check_id uuid;
  v_start timestamptz;
  v_target_day date;
  v_timezone text;
  v_gaps jsonb := '[]'::jsonb;
  v_gap_count int := 0;
begin
  v_check_id := gen_random_uuid();
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- GAP 1: Confirmed orders with no payment event
  with gap_order_payment as (
    select o.id as order_id, o.order_number,
           o.order_status, o.final_amount
    from catchmenu_pos.orders o
    where o.store_id = p_store_id
      and o.tenant_id = p_tenant_id
      and o.business_day = v_target_day
      and o.order_status in (
        'CONFIRMED', 'COOKING', 'COMPLETED'
      )
      and o.final_amount > 0
      and not exists (
        select 1
        from catchmenu_ledger.events e
        where e.order_id = o.id
          and e.event_domain = 'payment'
          and e.event_type = 'payment_confirmed'
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'ORDER_NO_PAYMENT_EVENT',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Paid orders with no payment_confirmed event',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'order_id', order_id,
              'order_number', order_number,
              'order_status', order_status,
              'final_amount', final_amount
            ) as item
            from gap_order_payment
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_order_payment;

  -- GAP 2: KDS tickets with no KDS events
  with gap_kds as (
    select kt.id as ticket_id, kt.ticket_number,
           kt.kds_status
    from catchmenu_kds.kds_tickets kt
    where kt.store_id = p_store_id
      and kt.tenant_id = p_tenant_id
      and kt.business_day = v_target_day
      and kt.kds_status not in ('HOLD')
      and not exists (
        select 1
        from catchmenu_kds.kds_events ke
        where ke.ticket_id = kt.id
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'KDS_TICKET_NO_EVENTS',
        'severity', 'MEDIUM',
        'count', count(*),
        'detail',
          'KDS tickets in non-HOLD state '
          || 'with no KDS events',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'ticket_id', ticket_id,
              'ticket_number', ticket_number,
              'kds_status', kds_status
            ) as item
            from gap_kds
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_kds;

  -- GAP 3: Sessions with no session events
  with gap_session as (
    select s.id as session_id,
           s.session_status, s.session_type
    from catchmenu_pos.order_sessions s
    where s.store_id = p_store_id
      and s.tenant_id = p_tenant_id
      and s.business_day = v_target_day
      and not exists (
        select 1
        from catchmenu_pos.session_events se
        where se.session_id = s.id
      )
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'SESSION_NO_EVENTS',
        'severity', 'LOW',
        'count', count(*),
        'detail',
          'Sessions with no session events recorded',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'session_id', session_id,
              'session_status', session_status,
              'session_type', session_type
            ) as item
            from gap_session
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_session;

  -- GAP 4: Payments without reconciliation check
  with gap_reconciliation as (
    select pl.id as ledger_id,
           pl.approved_amount,
           pl.ledger_status,
           pl.provider_type
    from catchmenu_payment.payment_ledger pl
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.business_day = v_target_day
      and pl.ledger_status = 'APPROVED'
      and pl.reconciliation_status = 'PENDING'
      and pl.reconciliation_checked_at is null
      -- older than 1 hour without reconciliation
      and pl.created_at < now() - interval '1 hour'
    limit 10
  )
  select case when count(*) > 0 then
    v_gaps || jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'PAYMENT_RECONCILIATION_PENDING',
        'severity', 'MEDIUM',
        'count', count(*),
        'total_amount', sum(approved_amount),
        'detail',
          'Approved payments pending reconciliation '
          || 'for over 1 hour',
        'sample', (
          select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
          from (
            select jsonb_build_object(
              'ledger_id', ledger_id,
              'approved_amount', approved_amount,
              'provider_type', provider_type
            ) as item
            from gap_reconciliation
            limit 5
          ) sample
        )
      )
    )
    else v_gaps
  end
  into v_gaps
  from gap_reconciliation;

  v_gap_count := jsonb_array_length(v_gaps);

  -- store gap check result
  insert into catchmenu_ledger.integrity_check_results (
    id, tenant_id, store_id,
    check_type, check_status, check_scope,
    total_records, invalid_records,
    gaps,
    check_completed_at, check_duration_ms,
    business_day
  ) values (
    v_check_id, p_tenant_id, p_store_id,
    'GAP_DETECTION',
    case v_gap_count
      when 0 then 'PASSED'
      else 'WARNING'
    end,
    'DAILY',
    0,
    v_gap_count,
    v_gaps,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    v_target_day
  );

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := case v_gap_count
      when 0 then 'INFO'
      else 'WARNING'
    end,
    p_log_domain := 'SYSTEM',
    p_log_event := 'ledger_gap_reconciliation',
    p_message :=
      'Ledger gap check: '
      || v_gap_count || ' gap types found'
      || ' on ' || v_target_day,
    p_rpc_name := 'reconcile_ledger_gaps',
    p_details := jsonb_build_object(
      'check_id', v_check_id,
      'gap_count', v_gap_count,
      'business_day', v_target_day
    )
  );

  return jsonb_build_object(
    'success', true,
    'check_id', v_check_id,
    'check_type', 'GAP_DETECTION',
    'business_day', v_target_day,
    'result', jsonb_build_object(
      'gap_type_count', v_gap_count,
      'status', case v_gap_count
        when 0 then 'PASSED'
        else 'WARNING'
      end,
      'gaps_checked', jsonb_build_array(
        'ORDER_NO_PAYMENT_EVENT',
        'KDS_TICKET_NO_EVENTS',
        'SESSION_NO_EVENTS',
        'PAYMENT_RECONCILIATION_PENDING'
      )
    ),
    'gaps', v_gaps,
    'message_code', case v_gap_count
      when 0 then 'ledger_gap_check_clean'
      else 'ledger_gaps_detected'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function
    catchmenu_ledger.verify_event_ledger_integrity(
      uuid, uuid, date, text
    ) from public;
  grant execute on function
    catchmenu_ledger.verify_event_ledger_integrity(
      uuid, uuid, date, text
    ) to authenticated;

  revoke all on function
    catchmenu_ledger.verify_audit_chain(
      uuid, uuid, date
    ) from public;
  grant execute on function
    catchmenu_ledger.verify_audit_chain(
      uuid, uuid, date
    ) to authenticated;

  revoke all on function
    catchmenu_ledger.run_state_projection_check(
      uuid, uuid, date
    ) from public;
  grant execute on function
    catchmenu_ledger.run_state_projection_check(
      uuid, uuid, date
    ) to authenticated;

  revoke all on function
    catchmenu_ledger.reconcile_ledger_gaps(
      uuid, uuid, date
    ) from public;
  grant execute on function
    catchmenu_ledger.reconcile_ledger_gaps(
      uuid, uuid, date
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_ledger.verify_event_ledger_integrity(
    uuid, uuid, date, text
  ) is
  'Validates event ledger integrity for a business day.
   Checks:
   1. Future event timestamps
   2. Orphaned payment events
   3. Replay events without origin reference
   4. Duplicate payment_confirmed events (double charge risk)
   5. Payment confirmed but no KDS condition update
   Computes event_chain_hash for integrity proof.
   특허4: Event 원장 무결성 = 이벤트 체인 해시 검증.
   hash는 당일 전체 이벤트의 sha256 fingerprint.
   동일 hash = 원장 변조 없음.';

comment on function
  catchmenu_ledger.verify_audit_chain(
    uuid, uuid, date
  ) is
  'Validates audit record immutability.
   CRITICAL: detects tampered audit records
   (recorded_at ≠ created_at).
   HIGH: anonymous financial audit records.
   Computes audit_chain_hash for compliance proof.
   특허4: Audit 원장 = append-only 불변 원장.
   감사 기록 변조 탐지 = 최우선 보안 검사.
   Daily run recommended. 이상 시 즉시 DBA 알림.';

comment on function
  catchmenu_ledger.run_state_projection_check(
    uuid, uuid, date
  ) is
  'Verifies current state matches event log projection.
   Current state = last event to_state per subject.
   Checks: payment, order, KDS ticket, session states.
   Mismatch = direct UPDATE bypassed event ledger.
   특허4: 현재 상태 = Event 원장 Projection.
   직접 UPDATE 금지 원칙 위반 탐지.
   mismatch 발견 시 → replay 또는 manual reconciliation.';

comment on function
  catchmenu_ledger.reconcile_ledger_gaps(
    uuid, uuid, date
  ) is
  'Detects gaps in event coverage.
   Gaps detected:
   1. Paid orders with no payment event
   2. Non-HOLD KDS tickets with no events
   3. Sessions with no events
   4. Approved payments pending reconciliation >1h
   특허4: Event 원장 Gap 탐지 → 복구 우선순위 결정.
   Gap = 이벤트가 기록되지 않은 상태 변경 의심.
   Daily cron 권장: run after business close.';