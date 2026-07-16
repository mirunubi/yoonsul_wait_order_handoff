-- ============================================================================
-- Migration: 0161_mark_no_show_overload_and_redesign.sql
-- Purpose:
--   Redesign mark_no_show() around a shared no-show transition core, add KDS
--   no-show grace expiry/recovery handling, drop the legacy 0050 overload, and
--   replace the WAITING_SESSION_EXPIRE cron inline phantom-column update with
--   store-scoped batch function calls.
--
-- Depends on:
--   0160_call_waiting_customer_contract_recovery.sql
--
-- Creates/Changes:
--   - Registers five error catalog keys required by the no-show redesign.
--   - Adds catchmenu_kds.kds_tickets.hold_expires_at.
--   - Creates catchmenu_pos.apply_no_show_transition(...).
--   - Replaces catchmenu_pos.mark_no_show(...).
--   - Creates catchmenu_pos.process_expired_no_shows(...).
--   - Creates catchmenu_kds.expire_no_show_kds_hold(...).
--   - Creates catchmenu_kds.recover_no_show_grace_ticket(...).
--   - Drops legacy catchmenu_pos.mark_no_show(uuid, uuid, uuid, text, uuid, text).
--   - Updates catchmenu_common.pg_cron_jobs WAITING_SESSION_EXPIRE sql_command.
--
-- Background:
--   600630_mark_no_show_overload_and_redesign confirmed that the old 0050
--   mark_no_show() overload conflicts with the current 0115 signature and that
--   the 0118 WAITING_SESSION_EXPIRE cron still referenced phantom columns
--   called_at/no_show_at/cancel_reason. 600632_Logic.md finalizes a shared
--   transition core, manual wrapper, automatic no-show batch, KDS grace expiry,
--   and late-arrival KDS ticket recovery.
--
-- Human decision:
--   Approved in 600634_ChangeContract.md §7/§8 on 2026-07-16, including the
--   corrected scope allowing only the hold_expires_at schema addition.
--
-- Non-goals:
--   - Do not modify confirm_arrival().
--   - Do not modify unrelated 0115 functions.
--   - Do not add schema columns other than kds_tickets.hold_expires_at.
--   - Do not implement complex late-arrival exception policy.
--   - Do not change Flutter/runtime code.
-- ============================================================================

insert into catchmenu_common.error_codes (
  code, error_key, error_domain, error_category,
  http_status, severity
) values
  (2026, 'invalid_trigger_source', 'ORDER', 'INVALID_INPUT', 400, 'WARNING'),
  (5008, 'kds_ticket_not_found', 'KDS', 'NOT_FOUND', 404, 'INFO'),
  (5009, 'no_show_grace_already_expired', 'KDS', 'CONFLICT', 409, 'INFO'),
  (2027, 'session_not_markable', 'ORDER', 'CONFLICT', 409, 'INFO'),
  (5016, 'ticket_not_recoverable', 'KDS', 'CONFLICT', 409, 'INFO')
on conflict (code) do nothing;

alter table catchmenu_kds.kds_tickets
  add column if not exists hold_expires_at timestamptz;

create or replace function catchmenu_pos.apply_no_show_transition(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_type text,
  p_actor_id uuid,
  p_trigger_source text,
  p_reason_code text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds, catchmenu_store,
                  catchmenu_audit, catchmenu_common, pg_catalog
as $$
declare
  v_session record;
  v_existing record;
  v_old_score int;
  v_grace_minutes int := 15;
  v_grace_ticket_ids jsonb := '[]'::jsonb;
  v_grace_ticket_count int := 0;
  v_grace_expires_at timestamptz;
  v_audit_id uuid;
begin
  if p_trigger_source not in ('STAFF', 'SYSTEM') then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_trigger_source',
      p_params := jsonb_build_object('trigger_source', p_trigger_source),
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'apply_no_show_transition',
      p_session_id := p_session_id
    );
  end if;

  select arrival_reliability_score
  into v_old_score
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  update catchmenu_pos.order_sessions
  set
    session_status = 'NO_SHOW',
    arrival_reliability_score = greatest(0, coalesce(arrival_reliability_score, 100) - 20),
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and session_status = 'ARRIVAL_PENDING'
    and (
      p_trigger_source = 'STAFF'
      or (p_trigger_source = 'SYSTEM' and expires_at <= now())
    )
  returning
    id, wait_number, guest_locale, pre_order_created_at, order_id,
    expires_at as original_call_expires_at,
    arrival_reliability_score as new_score,
    business_day, business_timezone
  into v_session;

  if v_session.id is null then
    select id, session_status, expires_at
    into v_existing
    from catchmenu_pos.order_sessions
    where id = p_session_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id;

    if v_existing.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'waiting_session_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'apply_no_show_transition',
        p_session_id := p_session_id
      );
    elsif v_existing.session_status = 'NO_SHOW' then
      return catchmenu_common.build_success_response(
        p_message_key := 'no_show_already_applied',
        p_data := jsonb_build_object('session_id', p_session_id, 'idempotent', true),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );
    else
      return catchmenu_common.build_error_response(
        p_error_key := 'session_not_markable',
        p_params := jsonb_build_object(
          'current_status', v_existing.session_status,
          'expires_at', v_existing.expires_at,
          'trigger_source', p_trigger_source
        ),
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'apply_no_show_transition',
        p_session_id := p_session_id
      );
    end if;
  end if;

  if v_session.pre_order_created_at is not null then
    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'catchmenu_store'
        and table_name = 'store_settings'
        and column_name = 'no_show_kds_grace_minutes'
    ) then
      execute
        'select coalesce(no_show_kds_grace_minutes, 15)
           from catchmenu_store.store_settings
          where tenant_id = $1 and store_id = $2'
      into v_grace_minutes
      using p_tenant_id, p_store_id;
    end if;

    v_grace_minutes := coalesce(v_grace_minutes, 15);

    with graced as (
      update catchmenu_kds.kds_tickets kt
      set
        hold_reason = 'NO_SHOW_GRACE',
        hold_expires_at = now() + (v_grace_minutes || ' minutes')::interval,
        updated_at = now()
      from catchmenu_pos.orders o
      where o.session_id = p_session_id
        and kt.order_id = o.id
        and kt.tenant_id = p_tenant_id
        and kt.store_id = p_store_id
        and kt.kds_status = 'HOLD'
      returning kt.id, kt.hold_expires_at
    )
    select coalesce(jsonb_agg(id), '[]'::jsonb), count(*), max(hold_expires_at)
    into v_grace_ticket_ids, v_grace_ticket_count, v_grace_expires_at
    from graced;
  end if;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'session',
    p_audit_type := 'no_show_marked',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'trigger_source', p_trigger_source,
      'reason_code', p_reason_code,
      'no_show_determined_at', now(),
      'original_call_expires_at', v_session.original_call_expires_at,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'kds_grace_ticket_ids', v_grace_ticket_ids,
      'kds_grace_ticket_count', v_grace_ticket_count,
      'kds_grace_expires_at', v_grace_expires_at,
      'arrival_reliability_score_new', v_session.new_score
    ),
    p_before_state := jsonb_build_object(
      'session_status', 'ARRIVAL_PENDING',
      'arrival_reliability_score', v_old_score,
      'kds_ticket_hold_reason', null
    ),
    p_after_state := jsonb_build_object(
      'session_status', 'NO_SHOW',
      'arrival_reliability_score', v_session.new_score,
      'kds_ticket_hold_reason', case when v_grace_ticket_count > 0 then 'NO_SHOW_GRACE' else null end
    ),
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_session.business_day,
    p_business_timezone := v_session.business_timezone
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'no_show_applied',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'idempotent', false,
      'audit_id', v_audit_id,
      'arrival_reliability_score', v_session.new_score,
      'kds_grace_ticket_count', v_grace_ticket_count,
      'kds_grace_ticket_ids', v_grace_ticket_ids
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.mark_no_show(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, pg_catalog
as $$
begin
  return catchmenu_pos.apply_no_show_transition(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_trigger_source := 'STAFF',
    p_reason_code := null,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.process_expired_no_shows(
  p_tenant_id uuid,
  p_store_id uuid,
  p_batch_size int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, pg_catalog
as $$
declare
  v_session_id uuid;
  v_result jsonb;
  v_processed int := 0;
  v_failed int := 0;
  v_failed_ids jsonb := '[]'::jsonb;
begin
  for v_session_id in
    select id
    from catchmenu_pos.order_sessions
    where tenant_id = p_tenant_id
      and store_id = p_store_id
      and session_status = 'ARRIVAL_PENDING'
      and expires_at <= now()
    order by expires_at asc
    limit p_batch_size
    for update skip locked
  loop
    begin
      v_result := catchmenu_pos.apply_no_show_transition(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_session_id := v_session_id,
        p_actor_type := 'SYSTEM',
        p_actor_id := null,
        p_trigger_source := 'SYSTEM',
        p_reason_code := 'WAIT_CALL_EXPIRED',
        p_correlation_id := p_correlation_id
      );

      if coalesce((v_result->>'success')::boolean, false) then
        v_processed := v_processed + 1;
      else
        v_failed := v_failed + 1;
        v_failed_ids := v_failed_ids || jsonb_build_array(v_session_id);
      end if;
    exception when others then
      v_failed := v_failed + 1;
      v_failed_ids := v_failed_ids || jsonb_build_array(v_session_id);
    end;
  end loop;

  return jsonb_build_object(
    'success', true,
    'processed_count', v_processed,
    'failed_count', v_failed,
    'failed_session_ids', v_failed_ids
  );
end;
$$;

create or replace function catchmenu_kds.expire_no_show_kds_hold(
  p_tenant_id uuid,
  p_store_id uuid,
  p_batch_size int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_audit, catchmenu_common, pg_catalog
as $$
declare
  v_ticket_id uuid;
  v_order_id uuid;
  v_hold_expires_at timestamptz;
  v_business_day date;
  v_business_timezone text;
  v_processed int := 0;
  v_failed int := 0;
  v_failed_ids jsonb := '[]'::jsonb;
begin
  for v_ticket_id, v_order_id, v_hold_expires_at, v_business_day, v_business_timezone in
    select id, order_id, hold_expires_at, business_day, business_timezone
    from catchmenu_kds.kds_tickets
    where tenant_id = p_tenant_id
      and store_id = p_store_id
      and kds_status = 'HOLD'
      and hold_reason = 'NO_SHOW_GRACE'
      and hold_expires_at <= now()
    order by hold_expires_at asc
    limit p_batch_size
    for update skip locked
  loop
    begin
      update catchmenu_kds.kds_tickets
      set
        kds_status = 'CANCELLED',
        hold_reason = 'NO_SHOW_GRACE_EXPIRED',
        cancelled_at = now(),
        updated_at = now()
      where id = v_ticket_id
        and tenant_id = p_tenant_id
        and store_id = p_store_id
        and kds_status = 'HOLD'
        and hold_reason = 'NO_SHOW_GRACE'
        and hold_expires_at <= now();

      if found then
        perform catchmenu_audit.append_audit_record(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_audit_domain := 'kds',
          p_audit_type := 'no_show_grace_expired',
          p_audit_category := 'OPERATIONAL',
          p_actor_type := 'SYSTEM',
          p_actor_id := null,
          p_subject_type := 'kds_ticket',
          p_subject_id := v_ticket_id,
          p_decision := 'COMPLETED',
          p_decision_payload := jsonb_build_object(
            'grace_expires_at', v_hold_expires_at,
            'cancelled_at', now()
          ),
          p_before_state := jsonb_build_object(
            'kds_status', 'HOLD',
            'hold_reason', 'NO_SHOW_GRACE'
          ),
          p_after_state := jsonb_build_object(
            'kds_status', 'CANCELLED',
            'hold_reason', 'NO_SHOW_GRACE_EXPIRED'
          ),
          p_order_id := v_order_id,
          p_kds_ticket_id := v_ticket_id,
          p_correlation_id := p_correlation_id,
          p_business_day := v_business_day,
          p_business_timezone := v_business_timezone
        );
        v_processed := v_processed + 1;
      else
        v_failed := v_failed + 1;
        v_failed_ids := v_failed_ids || jsonb_build_array(v_ticket_id);
      end if;
    exception when others then
      v_failed := v_failed + 1;
      v_failed_ids := v_failed_ids || jsonb_build_array(v_ticket_id);
    end;
  end loop;

  return jsonb_build_object(
    'success', true,
    'processed_count', v_processed,
    'failed_count', v_failed,
    'failed_ticket_ids', v_failed_ids
  );
end;
$$;

create or replace function catchmenu_kds.recover_no_show_grace_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kds_ticket_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_audit, catchmenu_common, pg_catalog
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'HOLD',
    hold_reason = null,
    hold_expires_at = null,
    updated_at = now()
  where id = p_kds_ticket_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and kds_status = 'HOLD'
    and hold_reason = 'NO_SHOW_GRACE'
    and hold_expires_at > now()
  returning *
  into v_ticket;

  if v_ticket.id is null then
    select *
    into v_ticket
    from catchmenu_kds.kds_tickets
    where id = p_kds_ticket_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id;

    if v_ticket.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'kds_ticket_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'recover_no_show_grace_ticket'
      );
    elsif v_ticket.kds_status = 'HOLD'
      and v_ticket.hold_reason = 'NO_SHOW_GRACE'
      and v_ticket.hold_expires_at <= now() then
      return catchmenu_common.build_error_response(
        p_error_key := 'no_show_grace_already_expired',
        p_params := jsonb_build_object('hold_expires_at', v_ticket.hold_expires_at),
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'recover_no_show_grace_ticket'
      );
    else
      return catchmenu_common.build_error_response(
        p_error_key := 'ticket_not_recoverable',
        p_params := jsonb_build_object(
          'kds_status', v_ticket.kds_status,
          'hold_reason', v_ticket.hold_reason
        ),
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'recover_no_show_grace_ticket'
      );
    end if;
  end if;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'no_show_grace_recovered',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_kds_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'recovered_at', now(),
      'correlation_id', p_correlation_id
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'HOLD',
      'hold_reason', 'NO_SHOW_GRACE'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'HOLD',
      'hold_reason', null
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_kds_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'no_show_grace_recovered',
    p_data := jsonb_build_object(
      'kds_ticket_id', p_kds_ticket_id,
      'kds_status', 'HOLD',
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

drop function if exists catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
);

update catchmenu_common.pg_cron_jobs
set
  sql_command = $sql$
do $$
declare
  r record;
begin
  for r in
    select distinct tenant_id, store_id
    from catchmenu_pos.order_sessions
    where session_status = 'ARRIVAL_PENDING'
      and expires_at <= now()
  loop
    perform catchmenu_pos.process_expired_no_shows(
      p_tenant_id := r.tenant_id,
      p_store_id := r.store_id,
      p_batch_size := 100
    );
  end loop;

  for r in
    select distinct tenant_id, store_id
    from catchmenu_kds.kds_tickets
    where kds_status = 'HOLD'
      and hold_reason = 'NO_SHOW_GRACE'
      and hold_expires_at <= now()
  loop
    perform catchmenu_kds.expire_no_show_kds_hold(
      p_tenant_id := r.tenant_id,
      p_store_id := r.store_id,
      p_batch_size := 100
    );
  end loop;

  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now()
  where session_status = 'WAITING'
    and session_started_at < now() - interval '2 hours';
end $$;
$sql$,
  notes = 'Waiting no-show expiry now delegates to process_expired_no_shows() and expire_no_show_kds_hold(); WAITING stale-session cancellation remains.'
where job_code = 'WAITING_SESSION_EXPIRE';
