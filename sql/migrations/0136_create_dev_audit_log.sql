-- 0136_create_dev_audit_log.sql
-- Purpose: Development audit log for Codex implementation.
--          Pipeline session tracking.
--          Data flow recording.
--          Error and success logging.
--          DROP after development complete.
-- WARNING: Dev only. Drop before production.
--          Separate from catchmenu_ledger.events.
-- Depends on: 0135_create_flutter_mvp_start_package.sql

create schema if not exists catchmenu_dev;

comment on schema catchmenu_dev is
  'Dev only schema. Drop before production.
   DROP SCHEMA catchmenu_dev CASCADE;';

create table if not exists
  catchmenu_dev.dev_audit_log (
  id bigserial primary key,
  log_session_id text not null,
  log_sequence int not null default 0,
  pipeline text not null,
  module text not null,
  phase text not null default 'PHASE_1',
  channel text,
  event_type text not null,
  event_status text not null,
  input_payload jsonb,
  output_payload jsonb,
  error_detail jsonb,
  session_id uuid,
  order_id uuid,
  store_id uuid,
  tenant_id uuid,
  customer_id uuid,
  staff_id uuid,
  device_type text,
  from_state text,
  to_state text,
  state_object text,
  duration_ms int,
  rpc_name text,
  flutter_screen text,
  supabase_channel text,
  app_version text,
  flutter_platform text,
  codex_task_id text,
  logged_at timestamptz not null default now(),
  constraint chk_event_status check (
    event_status in (
      'SUCCESS','ERROR','WARNING',
      'SKIPPED','RETRY','DROP_RECOVERED'
    )
  ),
  constraint chk_phase check (
    phase in ('PHASE_1','PHASE_2','PHASE_3')
  )
);

create index if not exists idx_dev_audit_session
  on catchmenu_dev.dev_audit_log(
    log_session_id, logged_at desc
  );

create index if not exists idx_dev_audit_pipeline
  on catchmenu_dev.dev_audit_log(
    pipeline, module, event_status, logged_at desc
  );

create index if not exists idx_dev_audit_error
  on catchmenu_dev.dev_audit_log(
    event_status, logged_at desc
  ) where event_status = 'ERROR';

comment on table catchmenu_dev.dev_audit_log is
  'Dev audit log. Drop before production.
   DROP SCHEMA catchmenu_dev CASCADE;';


create table if not exists
  catchmenu_dev.dev_session_trace (
  id bigserial primary key,
  trace_id text not null,
  session_id uuid,
  customer_id uuid,
  channel_from text,
  channel_to text,
  channel_type text,
  session_status_before text,
  session_status_after text,
  jwt_refreshed boolean default false,
  realtime_reconnected boolean default false,
  drop_detected boolean default false,
  drop_type text,
  drop_recovered boolean default false,
  recovery_method text,
  store_id uuid,
  tenant_id uuid,
  flutter_screen text,
  device_platform text,
  payload jsonb,
  duration_ms int,
  traced_at timestamptz not null default now(),
  constraint chk_drop_type check (
    drop_type is null or drop_type in (
      'DROP_A_JWT_EXPIRE',
      'DROP_B_APP_RESUME',
      'DROP_C_DEVICE_CHANGE',
      'DROP_D_FCM_TOKEN',
      'DROP_E_PAYMENT_SWITCH',
      'DROP_F_TENANT_MIX',
      'DROP_G_TRANSFER_DISCONNECT',
      'DROP_H_APP_SESSION_COLLISION',
      'DROP_I_POS_SYNC',
      'DROP_J_POINTS_SYNC'
    )
  )
);

create index if not exists idx_dev_session_trace
  on catchmenu_dev.dev_session_trace(
    trace_id, traced_at desc
  );

create index if not exists idx_dev_drop_detected
  on catchmenu_dev.dev_session_trace(
    drop_detected, drop_type, traced_at desc
  ) where drop_detected = true;

comment on table catchmenu_dev.dev_session_trace is
  'Dev session trace. DROP-A to DROP-J detection.
   Drop before production.';


create or replace function
  catchmenu_dev.write_audit_log(
  p_pipeline text,
  p_module text,
  p_event_type text,
  p_event_status text,
  p_log_session_id text default null,
  p_phase text default 'PHASE_1',
  p_channel text default null,
  p_rpc_name text default null,
  p_flutter_screen text default null,
  p_session_id uuid default null,
  p_order_id uuid default null,
  p_store_id uuid default null,
  p_tenant_id uuid default null,
  p_customer_id uuid default null,
  p_from_state text default null,
  p_to_state text default null,
  p_state_object text default null,
  p_input_payload jsonb default null,
  p_output_payload jsonb default null,
  p_error_detail jsonb default null,
  p_duration_ms int default null,
  p_codex_task_id text default null,
  p_supabase_channel text default null,
  p_app_version text default null,
  p_flutter_platform text default null
)
returns bigint
language plpgsql
volatile
security definer
set search_path = catchmenu_dev
as $$
declare
  v_log_id bigint;
  v_sequence int;
begin
  select coalesce(max(log_sequence), 0) + 1
  into v_sequence
  from catchmenu_dev.dev_audit_log
  where log_session_id = coalesce(
    p_log_session_id, 'default'
  );

  insert into catchmenu_dev.dev_audit_log (
    log_session_id, log_sequence,
    pipeline, module, phase, channel,
    event_type, event_status,
    rpc_name, flutter_screen,
    session_id, order_id,
    store_id, tenant_id, customer_id,
    from_state, to_state, state_object,
    input_payload, output_payload,
    error_detail, duration_ms,
    codex_task_id, supabase_channel,
    app_version, flutter_platform
  ) values (
    coalesce(p_log_session_id, 'default'),
    v_sequence,
    p_pipeline, p_module,
    p_phase, p_channel,
    p_event_type, p_event_status,
    p_rpc_name, p_flutter_screen,
    p_session_id, p_order_id,
    p_store_id, p_tenant_id, p_customer_id,
    p_from_state, p_to_state, p_state_object,
    p_input_payload, p_output_payload,
    p_error_detail, p_duration_ms,
    p_codex_task_id, p_supabase_channel,
    p_app_version, p_flutter_platform
  )
  returning id into v_log_id;

  return v_log_id;
end;
$$;


create or replace function
  catchmenu_dev.write_session_trace(
  p_trace_id text,
  p_channel_from text default null,
  p_channel_to text default null,
  p_channel_type text default null,
  p_session_id uuid default null,
  p_customer_id uuid default null,
  p_session_status_before text default null,
  p_session_status_after text default null,
  p_jwt_refreshed boolean default false,
  p_realtime_reconnected boolean default false,
  p_drop_detected boolean default false,
  p_drop_type text default null,
  p_drop_recovered boolean default false,
  p_recovery_method text default null,
  p_store_id uuid default null,
  p_tenant_id uuid default null,
  p_flutter_screen text default null,
  p_device_platform text default null,
  p_payload jsonb default null,
  p_duration_ms int default null
)
returns bigint
language plpgsql
volatile
security definer
set search_path = catchmenu_dev
as $$
declare
  v_trace_id bigint;
begin
  insert into catchmenu_dev.dev_session_trace (
    trace_id, channel_from, channel_to,
    channel_type, session_id, customer_id,
    session_status_before, session_status_after,
    jwt_refreshed, realtime_reconnected,
    drop_detected, drop_type,
    drop_recovered, recovery_method,
    store_id, tenant_id,
    flutter_screen, device_platform,
    payload, duration_ms
  ) values (
    p_trace_id, p_channel_from, p_channel_to,
    p_channel_type, p_session_id, p_customer_id,
    p_session_status_before, p_session_status_after,
    p_jwt_refreshed, p_realtime_reconnected,
    p_drop_detected, p_drop_type,
    p_drop_recovered, p_recovery_method,
    p_store_id, p_tenant_id,
    p_flutter_screen, p_device_platform,
    p_payload, p_duration_ms
  )
  returning id into v_trace_id;

  return v_trace_id;
end;
$$;


create or replace function
  catchmenu_dev.get_audit_summary(
  p_pipeline text default null,
  p_phase text default 'PHASE_1',
  p_hours_ago int default 24
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_dev
as $$
declare
  v_summary jsonb;
  v_errors jsonb;
  v_session_drops jsonb;
  v_pipeline_stats jsonb;
begin
  select jsonb_build_object(
    'total_logs', count(*),
    'success', count(*) filter (
      where event_status = 'SUCCESS'
    ),
    'errors', count(*) filter (
      where event_status = 'ERROR'
    ),
    'warnings', count(*) filter (
      where event_status = 'WARNING'
    ),
    'retries', count(*) filter (
      where event_status = 'RETRY'
    ),
    'error_rate', case count(*)
      when 0 then 0
      else round(
        count(*) filter (
          where event_status = 'ERROR'
        )::numeric / count(*) * 100, 1
      )
    end
  )
  into v_summary
  from catchmenu_dev.dev_audit_log
  where phase = p_phase
    and logged_at > now()
      - (p_hours_ago || ' hours')::interval
    and (
      p_pipeline is null
      or pipeline = p_pipeline
    );

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', id,
        'pipeline', pipeline,
        'module', module,
        'event_type', event_type,
        'rpc_name', rpc_name,
        'flutter_screen', flutter_screen,
        'error_detail', error_detail,
        'logged_at', logged_at
      )
      order by logged_at desc
    ),
    '[]'::jsonb
  )
  into v_errors
  from catchmenu_dev.dev_audit_log
  where event_status = 'ERROR'
    and phase = p_phase
    and logged_at > now()
      - (p_hours_ago || ' hours')::interval
    and (
      p_pipeline is null
      or pipeline = p_pipeline
    )
  limit 10;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'drop_type', drop_type,
        'count', cnt,
        'recovered', recovered_cnt,
        'recovery_rate', case cnt
          when 0 then 0
          else round(
            recovered_cnt::numeric / cnt * 100, 1
          )
        end
      )
      order by cnt desc
    ),
    '[]'::jsonb
  )
  into v_session_drops
  from (
    select
      drop_type,
      count(*) as cnt,
      count(*) filter (
        where drop_recovered = true
      ) as recovered_cnt
    from catchmenu_dev.dev_session_trace
    where drop_detected = true
      and traced_at > now()
        - (p_hours_ago || ' hours')::interval
    group by drop_type
  ) d;

  select coalesce(
    jsonb_object_agg(
      pipeline,
      jsonb_build_object(
        'total', total,
        'errors', errors,
        'error_rate', case total
          when 0 then 0
          else round(
            errors::numeric / total * 100, 1
          )
        end
      )
    ),
    '{}'::jsonb
  )
  into v_pipeline_stats
  from (
    select
      pipeline,
      count(*) as total,
      count(*) filter (
        where event_status = 'ERROR'
      ) as errors
    from catchmenu_dev.dev_audit_log
    where phase = p_phase
      and logged_at > now()
        - (p_hours_ago || ' hours')::interval
    group by pipeline
  ) p;

  return jsonb_build_object(
    'phase', p_phase,
    'hours_ago', p_hours_ago,
    'summary', v_summary,
    'recent_errors', v_errors,
    'session_drops', v_session_drops,
    'pipeline_stats', v_pipeline_stats,
    'generated_at', now()
  );
end;
$$;


create or replace function
  catchmenu_dev.get_session_flow(
  p_session_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_dev
as $$
declare
  v_logs jsonb;
  v_traces jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'seq', log_sequence,
        'pipeline', pipeline,
        'module', module,
        'event_type', event_type,
        'status', event_status,
        'from_state', from_state,
        'to_state', to_state,
        'rpc_name', rpc_name,
        'screen', flutter_screen,
        'duration_ms', duration_ms,
        'error', error_detail,
        'at', logged_at
      )
      order by log_sequence asc
    ),
    '[]'::jsonb
  )
  into v_logs
  from catchmenu_dev.dev_audit_log
  where session_id = p_session_id;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'channel_from', channel_from,
        'channel_to', channel_to,
        'status_before', session_status_before,
        'status_after', session_status_after,
        'jwt_refreshed', jwt_refreshed,
        'realtime_reconnected', realtime_reconnected,
        'drop_detected', drop_detected,
        'drop_type', drop_type,
        'recovered', drop_recovered,
        'recovery_method', recovery_method,
        'at', traced_at
      )
      order by traced_at asc
    ),
    '[]'::jsonb
  )
  into v_traces
  from catchmenu_dev.dev_session_trace
  where session_id = p_session_id;

  return jsonb_build_object(
    'session_id', p_session_id,
    'audit_logs', v_logs,
    'session_traces', v_traces,
    'total_steps', jsonb_array_length(v_logs),
    'total_traces', jsonb_array_length(v_traces)
  );
end;
$$;


create or replace function
  catchmenu_dev.drop_dev_schema(
  p_confirm text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_dev
as $$
declare
  v_log_count bigint;
  v_trace_count bigint;
begin
  if p_confirm != 'DROP_DEV_CONFIRMED' then
    return jsonb_build_object(
      'success', false,
      'message',
        'Confirmation required. '
        || 'Run with p_confirm = ''DROP_DEV_CONFIRMED''',
      'warning',
        'This will drop the entire catchmenu_dev schema.'
    );
  end if;

  select count(*) into v_log_count
  from catchmenu_dev.dev_audit_log;

  select count(*) into v_trace_count
  from catchmenu_dev.dev_session_trace;

  drop schema if exists catchmenu_dev cascade;

  return jsonb_build_object(
    'success', true,
    'message', 'catchmenu_dev schema dropped.',
    'deleted_logs', v_log_count,
    'deleted_traces', v_trace_count,
    'dropped_at', now(),
    'note', 'Production data not affected.'
  );
end;
$$;


grant usage on schema catchmenu_dev
  to authenticated, service_role;

grant execute on function
  catchmenu_dev.write_audit_log(
    text, text, text, text, text, text, text,
    text, text, uuid, uuid, uuid, uuid, uuid,
    text, text, text, jsonb, jsonb, jsonb,
    int, text, text, text, text
  ) to authenticated, service_role;

grant execute on function
  catchmenu_dev.write_session_trace(
    text, text, text, text, uuid, uuid,
    text, text, boolean, boolean,
    boolean, text, boolean, text,
    uuid, uuid, text, text, jsonb, int
  ) to authenticated, service_role;

grant execute on function
  catchmenu_dev.get_audit_summary(
    text, text, int
  ) to authenticated, service_role;

grant execute on function
  catchmenu_dev.get_session_flow(uuid)
  to authenticated, service_role;

grant execute on function
  catchmenu_dev.drop_dev_schema(text)
  to service_role;

comment on function
  catchmenu_dev.write_audit_log(
    text, text, text, text, text, text, text,
    text, text, uuid, uuid, uuid, uuid, uuid,
    text, text, text, jsonb, jsonb, jsonb,
    int, text, text, text, text
  ) is
  'Dev audit log writer.
   pipeline values:
   WAITING_HANDOFF / KDS_LATE_BINDING /
   PAYMENT / SESSION_MGMT / REALTIME /
   POS_INTEGRATION / MEMBERSHIP / DID
   event_status values:
   SUCCESS / ERROR / WARNING /
   SKIPPED / RETRY / DROP_RECOVERED
   Drop after dev complete:
   SELECT catchmenu_dev.drop_dev_schema(
     ''DROP_DEV_CONFIRMED''
   );';

comment on function
  catchmenu_dev.get_audit_summary(
    text, text, int
  ) is
  'Dev audit summary.
   Includes: error rate, recent errors,
   session drops (DROP-A to DROP-J),
   pipeline stats.';