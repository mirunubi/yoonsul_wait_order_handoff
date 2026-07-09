-- 0144_create_cron_job_executions_and_daily_close.sql
-- Purpose: Fill the 2 gaps 0073_final_verification.sql found and could
--          not pass without (0072/0073 themselves left untouched, per
--          instruction, since both are already-applied/already-fixed):
--            1. catchmenu_common.cron_job_executions — a run-history
--               table 0072's own commented-out reference queries and
--               0073's existence check both expect, but 0072 never
--               actually created.
--            2. catchmenu_common.run_daily_close_batch(...) — the
--               function 0072's DAILY_CLOSE_BATCH pg_cron seed row
--               names as its sql_command target, and 0073 checks for,
--               but which was never defined anywhere in 0001~0072.
-- Depends on: 0073_final_verification.sql
-- Creates:
--   catchmenu_common.cron_job_executions (table)
--   function catchmenu_common.run_daily_close_batch(...)

-- =============================================
-- cron_job_executions table
-- pg_cron_jobs 실행 이력 (스케줄 정의는 pg_cron_jobs, 실행 기록은 여기)
-- =============================================
create table if not exists
  catchmenu_common.cron_job_executions (
  id uuid primary key default gen_random_uuid(),

  job_code text not null
    references catchmenu_common.pg_cron_jobs(job_code),

  started_at timestamptz not null default now(),
  completed_at timestamptz,
  status text not null default 'RUNNING',
  records_processed int,
  error_message text,

  created_at timestamptz not null default now(),

  constraint chk_cron_job_execution_status check (
    status in ('RUNNING', 'SUCCESS', 'FAILURE')
  )
);

-- job_code + started_at: matches how 0072's own commented-out
-- "17. 배치 실행 현황" reference query orders by started_at desc, scoped
-- to a job.
create index if not exists
  idx_cron_job_executions_job_started
  on catchmenu_common.cron_job_executions(
    job_code, started_at desc
  );

-- job_code has no tenant_id (pg_cron_jobs itself has none either — a
-- schedule/job is a system-level concept, not tenant-scoped), so this
-- follows pg_cron_jobs' own pattern in 0072: no RLS, plain grants. This
-- deliberately does NOT follow the tenant-scoped RLS pattern used by
-- customer-data tables like document_embeddings — job execution history
-- is an operations/admin concern, same category as pg_cron_jobs and
-- deployment_checklist (0072's other two tables, neither of which use
-- RLS either).
grant select on catchmenu_common.cron_job_executions
  to authenticated;

comment on table catchmenu_common.cron_job_executions is
  'pg_cron job run-history log. One row per execution attempt of a
   pg_cron_jobs schedule.
   status: RUNNING (in progress) / SUCCESS / FAILURE.

   조회:
   SELECT * FROM catchmenu_common.cron_job_executions
   WHERE job_code = ''DAILY_CLOSE_BATCH''
   ORDER BY started_at DESC LIMIT 30;';


-- =============================================
-- run_daily_close_batch
--
-- CONFIRMED from other files (reused, not guessed):
--   - catchmenu_pos.get_daily_summary(p_tenant_id, p_store_id,
--     p_business_day) already exists (0045) and computes the exact
--     business-day operational summary this function needs — reused
--     directly rather than re-deriving those stats.
--   - catchmenu_ledger.events is this codebase's established pattern
--     for recording a completed business action as an auditable event
--     (see catchmenu_knowledge.build_grounded_ai_context in 0069 for
--     the same insert-an-event-after-the-action shape).
--   - catchmenu_ledger.exceptions with exception_severity IN
--     ('CRITICAL','FATAL') and exception_status IN ('OPEN',
--     'ACKNOWLEDGED','IN_RECOVERY') is the existing convention (see
--     0073's own "미해결 Exception 목록" reference query in 0072) for
--     "is there an unresolved blocking problem."
--
-- BEST-EFFORT INFERENCE (not confirmed anywhere else — review before
-- trusting this in production):
--   - There is no dedicated "day closed" flag/table anywhere in
--     0001~0072. This implementation treats "closing the day" as:
--     verify no unresolved CRITICAL/FATAL exception exists for that
--     business day (unless p_force), then record a CLOSED event in
--     catchmenu_ledger.events carrying the day's summary as its
--     payload. If the real intended semantics are different (e.g. a
--     dedicated closure/lock table that blocks further order writes
--     for that business_day), that would need its own migration — this
--     is the minimal version that performs a real, correct action
--     (blocking check + auditable closure record + summary capture)
--     without inventing schema the rest of the codebase doesn't
--     already expect.
--   - records_processed is reported as the day's total completed
--     order count, taken from get_daily_summary's output — a
--     reasonable single number to log per run, not a value 0072/0073
--     specify precisely.
-- =============================================
create or replace function
  catchmenu_common.run_daily_close_batch(
  p_tenant_id uuid,
  p_store_id uuid,
  p_force boolean default false
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common, catchmenu_pos,
                  catchmenu_hq, catchmenu_ledger
as $$
declare
  v_store record;
  v_timezone text;
  v_business_day date;
  v_summary jsonb;
  v_open_critical_count int;
  v_close_id uuid;
  v_records_processed int;
  v_execution_id uuid;
  v_started_at timestamptz := now();
begin
  insert into catchmenu_common.cron_job_executions (
    job_code, started_at, status
  ) values (
    'DAILY_CLOSE_BATCH', v_started_at, 'RUNNING'
  )
  returning id into v_execution_id;

  select id, timezone into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    update catchmenu_common.cron_job_executions
    set completed_at = now(), status = 'FAILURE',
        error_message = 'store_not_found'
    where id = v_execution_id;

    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(v_timezone, now()))::date;

  -- blocking check: unresolved CRITICAL/FATAL exceptions for this day
  select count(*)
  into v_open_critical_count
  from catchmenu_ledger.exceptions
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and detected_at::date = v_business_day
    and exception_severity in ('CRITICAL', 'FATAL')
    and exception_status in ('OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY');

  if v_open_critical_count > 0 and not p_force then
    update catchmenu_common.cron_job_executions
    set completed_at = now(), status = 'FAILURE',
        error_message = format(
          'blocked_by_open_exceptions: %s', v_open_critical_count
        )
    where id = v_execution_id;

    return jsonb_build_object(
      'success', false,
      'error_key', 'daily_close_blocked_by_open_exceptions',
      'open_critical_exceptions', v_open_critical_count,
      'message',
        'Daily close blocked: ' || v_open_critical_count
        || ' unresolved CRITICAL/FATAL exception(s) for '
        || v_business_day::text
        || '. Resolve them or call with p_force := true.'
    );
  end if;

  v_summary := catchmenu_pos.get_daily_summary(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_business_day := v_business_day
  );

  -- get_daily_summary (0045) returns completed-order count nested at
  -- results->'orders'->'completed' — confirmed by reading that function.
  v_records_processed := coalesce(
    (v_summary->'orders'->>'completed')::int,
    0
  );

  v_close_id := gen_random_uuid();

  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'system', 'daily_close_completed', 1,
    'business_day_close', v_close_id,
    'OPEN', 'CLOSED',
    'SYSTEM',
    jsonb_build_object(
      'business_day', v_business_day,
      'forced', p_force,
      'open_critical_exceptions_at_close', v_open_critical_count,
      'summary', v_summary
    ),
    v_business_day, v_timezone, now()
  );

  update catchmenu_common.cron_job_executions
  set completed_at = now(), status = 'SUCCESS',
      records_processed = v_records_processed
  where id = v_execution_id;

  return jsonb_build_object(
    'success', true,
    'close_id', v_close_id,
    'business_day', v_business_day,
    'forced', p_force,
    'records_processed', v_records_processed,
    'summary', v_summary,
    'message_code', 'daily_close_completed'
  );

exception when others then
  update catchmenu_common.cron_job_executions
  set completed_at = now(), status = 'FAILURE',
      error_message = sqlerrm
  where id = v_execution_id;
  raise;
end;
$$;

comment on function
  catchmenu_common.run_daily_close_batch(uuid, uuid, boolean) is
  'Daily close batch: verifies no unresolved CRITICAL/FATAL exception
   exists for the store''s current business day (unless p_force),
   captures a get_daily_summary() snapshot, and records a
   business_day_close event in catchmenu_ledger.events. Every run is
   logged to catchmenu_common.cron_job_executions.

   BEST-EFFORT DESIGN NOTE: no dedicated "day closed" flag/table exists
   elsewhere in this schema (0001~0072) — review this function''s
   definition of "closing the day" before relying on it in production.

   Scheduled via pg_cron_jobs.DAILY_CLOSE_BATCH (see 0072), nightly at
   23:00 KST / 14:00 UTC.';

-- grants
do $$
begin
  revoke all on function
    catchmenu_common.run_daily_close_batch(uuid, uuid, boolean)
    from public;
  grant execute on function
    catchmenu_common.run_daily_close_batch(uuid, uuid, boolean)
    to authenticated;
end;
$$;
