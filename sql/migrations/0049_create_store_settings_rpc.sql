-- 0049_create_store_settings_rpc.sql
-- Purpose: Store operational settings management RPCs.
--          get_store_settings: returns all operational settings.
--          update_business_hours: updates store operating hours.
--          toggle_store_mode: switches store between operational modes.
--          update_kds_capacity_threshold: adjusts KDS capacity limits.
--          특허2: KDS 수용상태 임계값 관리.
-- Depends on: 0048_create_table_management_rpc.sql
-- Creates:
--   catchmenu_store.store_settings (table)
--   function catchmenu_store.get_store_settings(...)
--   function catchmenu_store.update_business_hours(...)
--   function catchmenu_store.toggle_store_mode(...)
--   function catchmenu_store.update_kds_capacity_threshold(...)

-- store settings table
create table if not exists catchmenu_store.store_settings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- operational mode
  store_mode text not null default 'NORMAL',
  mode_changed_at timestamptz,
  mode_changed_by uuid,
  mode_change_reason text,

  -- KDS capacity thresholds (특허2)
  kds_capacity_threshold_per_zone int not null default 8,
  kds_capacity_threshold_total int not null default 30,
  kds_peak_time_threshold int not null default 6,

  -- pre-order settings (특허2)
  pre_order_enabled boolean not null default true,
  pre_order_lead_minutes int not null default 15,
  pre_order_expire_minutes int not null default 30,
  arrival_reliability_threshold int not null default 60,

  -- waiting settings
  waiting_enabled boolean not null default true,
  max_wait_number int not null default 999,
  wait_call_expire_minutes int not null default 5,
  no_show_auto_expire_minutes int not null default 10,

  -- payment settings
  payment_uncertain_auto_resolve_minutes int
    not null default 10,
  kds_release_auto_authorize boolean
    not null default false,

  -- peak time definition
  peak_time_ranges jsonb not null default '[]'::jsonb,

  -- notification settings
  did_refresh_interval_seconds int not null default 10,
  staff_alert_enabled boolean not null default true,
  sound_alert_enabled boolean not null default true,

  -- business hours override
  business_hours_override jsonb,
  holiday_mode boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_store_settings unique (store_id),
  constraint chk_store_mode check (
    store_mode in (
      'NORMAL',
      'PEAK',
      'LIMITED',
      'TAKEOUT_ONLY',
      'DELIVERY_ONLY',
      'CLOSING',
      'CLOSED',
      'EMERGENCY'
    )
  ),
  constraint chk_kds_threshold check (
    kds_capacity_threshold_per_zone > 0
    and kds_capacity_threshold_total > 0
    and kds_peak_time_threshold > 0
  ),
  constraint chk_pre_order_minutes check (
    pre_order_lead_minutes > 0
    and pre_order_expire_minutes > 0
  ),
  constraint chk_peak_time_array check (
    jsonb_typeof(peak_time_ranges) = 'array'
  )
);

create index if not exists idx_store_settings_store
  on catchmenu_store.store_settings(store_id);

alter table catchmenu_store.store_settings
  enable row level security;
alter table catchmenu_store.store_settings
  force row level security;

drop policy if exists store_settings_isolation
  on catchmenu_store.store_settings;
create policy store_settings_isolation
  on catchmenu_store.store_settings
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_store_settings_updated_at
  on catchmenu_store.store_settings;
create trigger trg_store_settings_updated_at
  before update on catchmenu_store.store_settings
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.store_settings is
  'Operational settings per store.
   KDS capacity thresholds control Late Binding commit decisions.
   Pre-order settings control waiting session behavior.
   특허2: KDS 수용상태 임계값 — commit_kds_ticket의 판단 기준.';


-- helper: ensure settings row exists
create or replace function catchmenu_store.ensure_store_settings(
  p_tenant_id uuid,
  p_store_id uuid
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_hq
as $$
declare
  v_id uuid;
begin
  select id into v_id
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_id is null then
    insert into catchmenu_store.store_settings (
      tenant_id, store_id
    ) values (
      p_tenant_id, p_store_id
    )
    returning id into v_id;
  end if;

  return v_id;
end;
$$;


create or replace function catchmenu_store.get_store_settings(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_settings record;
  v_store record;
begin
  select id, store_name, timezone, store_status
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  -- ensure settings exist
  perform catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  select *
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'timezone', v_store.timezone,
      'store_status', v_store.store_status
    ),
    'operational_mode', jsonb_build_object(
      'store_mode', v_settings.store_mode,
      'mode_changed_at', v_settings.mode_changed_at,
      'mode_change_reason', v_settings.mode_change_reason,
      'holiday_mode', v_settings.holiday_mode
    ),
    'kds_settings', jsonb_build_object(
      'capacity_threshold_per_zone',
        v_settings.kds_capacity_threshold_per_zone,
      'capacity_threshold_total',
        v_settings.kds_capacity_threshold_total,
      'peak_time_threshold',
        v_settings.kds_peak_time_threshold,
      'release_auto_authorize',
        v_settings.kds_release_auto_authorize
    ),
    'pre_order_settings', jsonb_build_object(
      'enabled', v_settings.pre_order_enabled,
      'lead_minutes', v_settings.pre_order_lead_minutes,
      'expire_minutes', v_settings.pre_order_expire_minutes,
      'arrival_reliability_threshold',
        v_settings.arrival_reliability_threshold
    ),
    'waiting_settings', jsonb_build_object(
      'enabled', v_settings.waiting_enabled,
      'max_wait_number', v_settings.max_wait_number,
      'wait_call_expire_minutes',
        v_settings.wait_call_expire_minutes,
      'no_show_auto_expire_minutes',
        v_settings.no_show_auto_expire_minutes
    ),
    'payment_settings', jsonb_build_object(
      'uncertain_auto_resolve_minutes',
        v_settings.payment_uncertain_auto_resolve_minutes
    ),
    'peak_time_ranges', v_settings.peak_time_ranges,
    'notification_settings', jsonb_build_object(
      'did_refresh_interval_seconds',
        v_settings.did_refresh_interval_seconds,
      'staff_alert_enabled',
        v_settings.staff_alert_enabled,
      'sound_alert_enabled',
        v_settings.sound_alert_enabled
    ),
    'business_hours_override',
      v_settings.business_hours_override,
    'updated_at', v_settings.updated_at,
    'message_code', 'store_settings_loaded'
  );
end;
$$;


create or replace function catchmenu_store.update_business_hours(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_hours jsonb,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_settings_id uuid;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
begin
  if p_business_hours is null
    or jsonb_typeof(p_business_hours) <> 'object'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'business_hours_must_be_object'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  v_settings_id := catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  update catchmenu_store.store_settings
  set
    business_hours_override = p_business_hours,
    updated_at = now()
  where id = v_settings_id;

  -- also update main store record
  update catchmenu_hq.stores
  set
    business_hours = p_business_hours,
    updated_at = now()
  where id = p_store_id
    and tenant_id = p_tenant_id;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'store',
    p_audit_type := 'business_hours_updated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store',
    p_subject_id := p_store_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'business_hours', p_business_hours
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'business_hours', p_business_hours,
    'audit_id', v_audit_id,
    'message_code', 'business_hours_updated'
  );
end;
$$;


create or replace function catchmenu_store.toggle_store_mode(
  p_tenant_id uuid,
  p_store_id uuid,
  p_new_mode text,
  p_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_settings_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_new_mode not in (
    'NORMAL', 'PEAK', 'LIMITED',
    'TAKEOUT_ONLY', 'DELIVERY_ONLY',
    'CLOSING', 'CLOSED', 'EMERGENCY'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_store_mode'
    );
  end if;

  if trim(coalesce(p_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'reason_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  v_settings_id := catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  select store_mode into v_settings
  from catchmenu_store.store_settings
  where id = v_settings_id
  for update;

  -- update mode
  update catchmenu_store.store_settings
  set
    store_mode = p_new_mode,
    mode_changed_at = now(),
    mode_changed_by = p_actor_id,
    mode_change_reason = p_reason,
    -- auto-adjust settings for specific modes
    pre_order_enabled = case p_new_mode
      when 'CLOSING' then false
      when 'CLOSED' then false
      when 'EMERGENCY' then false
      else pre_order_enabled
    end,
    waiting_enabled = case p_new_mode
      when 'TAKEOUT_ONLY' then false
      when 'DELIVERY_ONLY' then false
      when 'CLOSING' then false
      when 'CLOSED' then false
      when 'EMERGENCY' then false
      else waiting_enabled
    end,
    updated_at = now()
  where id = v_settings_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'system', 'store_mode_changed', 1,
    'store', p_store_id,
    v_settings.store_mode, p_new_mode,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'previous_mode', v_settings.store_mode,
      'new_mode', p_new_mode,
      'reason', p_reason
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'system',
    p_audit_type := 'store_mode_changed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store',
    p_subject_id := p_store_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_reason,
    p_decision_payload := jsonb_build_object(
      'previous_mode', v_settings.store_mode,
      'new_mode', p_new_mode
    ),
    p_before_state := jsonb_build_object(
      'store_mode', v_settings.store_mode
    ),
    p_after_state := jsonb_build_object(
      'store_mode', p_new_mode
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'previous_mode', v_settings.store_mode,
    'new_mode', p_new_mode,
    'reason', p_reason,
    'audit_id', v_audit_id,
    'message_code', 'store_mode_changed'
  );
end;
$$;


create or replace function catchmenu_store.update_kds_capacity_threshold(
  p_tenant_id uuid,
  p_store_id uuid,
  p_threshold_per_zone int default null,
  p_threshold_total int default null,
  p_peak_time_threshold int default null,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_settings_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  -- at least one threshold required
  if p_threshold_per_zone is null
    and p_threshold_total is null
    and p_peak_time_threshold is null
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'at_least_one_threshold_required'
    );
  end if;

  -- validate ranges
  if p_threshold_per_zone is not null
    and p_threshold_per_zone not between 1 and 50
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'threshold_per_zone_out_of_range',
      'allowed_range', '1-50'
    );
  end if;

  if p_threshold_total is not null
    and p_threshold_total not between 1 and 200
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'threshold_total_out_of_range',
      'allowed_range', '1-200'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  v_settings_id := catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  select
    kds_capacity_threshold_per_zone,
    kds_capacity_threshold_total,
    kds_peak_time_threshold
  into v_settings
  from catchmenu_store.store_settings
  where id = v_settings_id
  for update;

  update catchmenu_store.store_settings
  set
    kds_capacity_threshold_per_zone = coalesce(
      p_threshold_per_zone,
      kds_capacity_threshold_per_zone
    ),
    kds_capacity_threshold_total = coalesce(
      p_threshold_total,
      kds_capacity_threshold_total
    ),
    kds_peak_time_threshold = coalesce(
      p_peak_time_threshold,
      kds_peak_time_threshold
    ),
    updated_at = now()
  where id = v_settings_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_threshold_updated', 1,
    'store_settings', v_settings_id,
    null, 'UPDATED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'previous', jsonb_build_object(
        'per_zone',
          v_settings.kds_capacity_threshold_per_zone,
        'total',
          v_settings.kds_capacity_threshold_total,
        'peak_time',
          v_settings.kds_peak_time_threshold
      ),
      'new', jsonb_build_object(
        'per_zone', coalesce(
          p_threshold_per_zone,
          v_settings.kds_capacity_threshold_per_zone
        ),
        'total', coalesce(
          p_threshold_total,
          v_settings.kds_capacity_threshold_total
        ),
        'peak_time', coalesce(
          p_peak_time_threshold,
          v_settings.kds_peak_time_threshold
        )
      )
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_threshold_updated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store_settings',
    p_subject_id := v_settings_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'threshold_per_zone', coalesce(
        p_threshold_per_zone,
        v_settings.kds_capacity_threshold_per_zone
      ),
      'threshold_total', coalesce(
        p_threshold_total,
        v_settings.kds_capacity_threshold_total
      ),
      'peak_time_threshold', coalesce(
        p_peak_time_threshold,
        v_settings.kds_peak_time_threshold
      )
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'thresholds', jsonb_build_object(
      'per_zone', coalesce(
        p_threshold_per_zone,
        v_settings.kds_capacity_threshold_per_zone
      ),
      'total', coalesce(
        p_threshold_total,
        v_settings.kds_capacity_threshold_total
      ),
      'peak_time', coalesce(
        p_peak_time_threshold,
        v_settings.kds_peak_time_threshold
      )
    ),
    'audit_id', v_audit_id,
    'message_code', 'kds_threshold_updated'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.ensure_store_settings(
    uuid, uuid
  ) from public;
  grant execute on function catchmenu_store.ensure_store_settings(
    uuid, uuid
  ) to authenticated;

  revoke all on function catchmenu_store.get_store_settings(
    uuid, uuid
  ) from public;
  grant execute on function catchmenu_store.get_store_settings(
    uuid, uuid
  ) to authenticated;

  revoke all on function catchmenu_store.update_business_hours(
    uuid, uuid, jsonb, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.update_business_hours(
    uuid, uuid, jsonb, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.toggle_store_mode(
    uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.toggle_store_mode(
    uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.update_kds_capacity_threshold(
    uuid, uuid, int, int, int, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.update_kds_capacity_threshold(
    uuid, uuid, int, int, int, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.toggle_store_mode(
  uuid, uuid, text, text, text, uuid, text
) is
  'Switches store between operational modes.
   NORMAL = standard operation.
   PEAK = high demand, KDS thresholds tightened.
   LIMITED = reduced capacity, some features disabled.
   TAKEOUT_ONLY = no dine-in, waiting disabled.
   DELIVERY_ONLY = delivery only.
   CLOSING = approaching close, no new waiting/pre-orders.
   CLOSED = store closed.
   EMERGENCY = emergency closure, all operations suspended.
   특허4: 무장애 운영 — 장애 시 운영 모드 전환 구조.
   Agent SOP Selection이 장애 유형에 따라 이 RPC를 추천.';

comment on function catchmenu_store.update_kds_capacity_threshold(
  uuid, uuid, int, int, int, text, uuid, text
) is
  'Adjusts KDS capacity thresholds used in Late Binding decisions.
   per_zone: max tickets COOKING per kitchen station (default 8).
   total: max tickets across all zones (default 30).
   peak_time: tighter threshold during peak hours (default 6).
   Changes take effect immediately on next commit_kds_ticket call.
   특허2: KDS 수용상태 임계값 동적 조정.
   피크타임/특별이벤트 시 임계값을 낮춰 과부하 방지.';