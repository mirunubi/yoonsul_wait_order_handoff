-- 0053_create_staff_management_rpc.sql
-- Purpose: Staff management RPCs.
--          register_staff: registers new staff member.
--          update_staff_role: changes staff role and permissions.
--          record_staff_attendance: clock-in/clock-out recording.
--          get_staff_schedule: returns staff schedule for a day.
--          특허4 core: Human Authority Runtime — 직원 권한 계층 관리.
-- Depends on: 0052_create_kiosk_session_rpc.sql
-- Creates:
--   catchmenu_store.staff (table)
--   catchmenu_store.staff_attendance (table)
--   function catchmenu_store.register_staff(...)
--   function catchmenu_store.update_staff_role(...)
--   function catchmenu_store.record_staff_attendance(...)
--   function catchmenu_store.get_staff_schedule(...)

-- =============================================
-- staff table
-- =============================================
create table if not exists catchmenu_store.staff (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- identity
  staff_code text not null,
  display_name text not null,
  legal_name text,
  phone text,
  email text,

  -- role and authority
  staff_role text not null default 'STAFF',
  staff_status text not null default 'ACTIVE',
  authority_level int not null default 1,

  -- Human Authority Runtime
  -- 특허4: 역할별 관찰/추천/실행 권한 분리
  can_observe boolean not null default true,
  can_override_kds boolean not null default false,
  can_approve_refund boolean not null default false,
  can_manage_menu boolean not null default false,
  can_manage_staff boolean not null default false,
  can_view_reports boolean not null default false,
  can_change_store_mode boolean not null default false,

  -- scheduling
  employment_type text not null default 'PART_TIME',
  scheduled_hours_per_week numeric(5,1),
  hourly_wage numeric(10,2),

  -- metadata
  hired_on date,
  terminated_on date,
  pin_hash text,
  last_login_at timestamptz,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_staff_code unique (store_id, staff_code),
  constraint chk_staff_role check (
    staff_role in (
      'OWNER', 'MANAGER', 'SUPERVISOR',
      'STAFF', 'PART_TIME', 'TRAINEE'
    )
  ),
  constraint chk_staff_status check (
    staff_status in (
      'ACTIVE', 'ON_LEAVE', 'SUSPENDED', 'TERMINATED'
    )
  ),
  constraint chk_employment_type check (
    employment_type in (
      'FULL_TIME', 'PART_TIME', 'CONTRACT', 'TEMPORARY'
    )
  ),
  constraint chk_authority_level check (
    authority_level between 1 and 10
  )
);

create index if not exists idx_staff_store
  on catchmenu_store.staff(store_id);
create index if not exists idx_staff_status
  on catchmenu_store.staff(store_id, staff_status)
  where is_active = true;

alter table catchmenu_store.staff
  enable row level security;
alter table catchmenu_store.staff
  force row level security;

drop policy if exists staff_isolation
  on catchmenu_store.staff;
create policy staff_isolation
  on catchmenu_store.staff
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_staff_updated_at
  on catchmenu_store.staff;
create trigger trg_staff_updated_at
  before update on catchmenu_store.staff
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.staff is
  'Staff registry per store.
   Authority levels: OWNER=10, MANAGER=8,
   SUPERVISOR=5, STAFF=3, PART_TIME=2, TRAINEE=1.
   특허4: Human Authority Runtime.
   직원별 관찰/추천/실행 권한을 분리하여
   Agent 추천과 사람 실행 경계를 명확히 함.';


-- =============================================
-- staff_attendance table
-- =============================================
create table if not exists catchmenu_store.staff_attendance (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  staff_id uuid not null
    references catchmenu_store.staff(id),

  attendance_date date not null,
  business_timezone text not null default 'Asia/Seoul',

  -- clock in/out
  clocked_in_at timestamptz,
  clocked_out_at timestamptz,
  break_minutes int not null default 0,

  -- computed
  worked_minutes int,
  overtime_minutes int not null default 0,

  -- status
  attendance_status text not null default 'PRESENT',
  late_minutes int not null default 0,
  early_leave_minutes int not null default 0,

  -- scheduled
  scheduled_start_at timestamptz,
  scheduled_end_at timestamptz,

  -- notes
  attendance_note text,
  approved_by uuid,
  approved_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_staff_attendance unique (
    staff_id, attendance_date
  ),
  constraint chk_attendance_status check (
    attendance_status in (
      'PRESENT', 'ABSENT', 'LATE',
      'EARLY_LEAVE', 'HOLIDAY', 'SICK_LEAVE'
    )
  )
);

create index if not exists idx_attendance_date
  on catchmenu_store.staff_attendance(
    store_id, attendance_date
  );
create index if not exists idx_attendance_staff
  on catchmenu_store.staff_attendance(
    staff_id, attendance_date
  );

alter table catchmenu_store.staff_attendance
  enable row level security;
alter table catchmenu_store.staff_attendance
  force row level security;

drop policy if exists attendance_isolation
  on catchmenu_store.staff_attendance;
create policy attendance_isolation
  on catchmenu_store.staff_attendance
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_attendance_updated_at
  on catchmenu_store.staff_attendance;
create trigger trg_attendance_updated_at
  before update on catchmenu_store.staff_attendance
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.staff_attendance is
  'Daily attendance records per staff.
   Clock-in/out times, break, overtime, late minutes.
   특허3: 근태 데이터 → KPI → SOP 개선 피드백 루프.';


-- =============================================
-- RPCs
-- =============================================
create or replace function catchmenu_store.register_staff(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_code text,
  p_display_name text,
  p_staff_role text,
  p_employment_type text default 'PART_TIME',
  p_phone text default null,
  p_email text default null,
  p_legal_name text default null,
  p_hired_on date default null,
  p_hourly_wage numeric default null,
  p_scheduled_hours_per_week numeric default null,
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
  v_staff_id uuid;
  v_authority_level int;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if trim(coalesce(p_staff_code, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'staff_code_required'
    );
  end if;

  if trim(coalesce(p_display_name, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'display_name_required'
    );
  end if;

  if p_staff_role not in (
    'OWNER', 'MANAGER', 'SUPERVISOR',
    'STAFF', 'PART_TIME', 'TRAINEE'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_staff_role'
    );
  end if;

  -- duplicate check
  if exists (
    select 1
    from catchmenu_store.staff
    where store_id = p_store_id
      and staff_code = p_staff_code
      and is_active = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'staff_code_already_exists',
      'staff_code', p_staff_code
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- authority level by role
  v_authority_level := case p_staff_role
    when 'OWNER' then 10
    when 'MANAGER' then 8
    when 'SUPERVISOR' then 5
    when 'STAFF' then 3
    when 'PART_TIME' then 2
    when 'TRAINEE' then 1
    else 1
  end;

  -- insert staff
  insert into catchmenu_store.staff (
    tenant_id, store_id,
    staff_code, display_name, legal_name,
    phone, email,
    staff_role, staff_status, authority_level,
    employment_type,
    -- default permissions by role
    can_observe,
    can_override_kds,
    can_approve_refund,
    can_manage_menu,
    can_manage_staff,
    can_view_reports,
    can_change_store_mode,
    hourly_wage,
    scheduled_hours_per_week,
    hired_on, is_active
  ) values (
    p_tenant_id, p_store_id,
    p_staff_code, p_display_name, p_legal_name,
    p_phone, p_email,
    p_staff_role, 'ACTIVE', v_authority_level,
    p_employment_type,
    -- 특허4: 역할별 기본 권한 설정
    true, -- can_observe (all roles)
    p_staff_role in ('OWNER', 'MANAGER', 'SUPERVISOR'),
    p_staff_role in ('OWNER', 'MANAGER'),
    p_staff_role in ('OWNER', 'MANAGER', 'SUPERVISOR'),
    p_staff_role in ('OWNER', 'MANAGER'),
    p_staff_role in ('OWNER', 'MANAGER', 'SUPERVISOR'),
    p_staff_role in ('OWNER', 'MANAGER'),
    p_hourly_wage,
    p_scheduled_hours_per_week,
    p_hired_on, true
  )
  returning id into v_staff_id;

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
    'staff', 'staff_registered', 1,
    'staff', v_staff_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'staff_code', p_staff_code,
      'display_name', p_display_name,
      'staff_role', p_staff_role,
      'authority_level', v_authority_level,
      'employment_type', p_employment_type
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'staff',
    p_audit_type := 'staff_registered',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'staff',
    p_subject_id := v_staff_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'staff_code', p_staff_code,
      'staff_role', p_staff_role,
      'authority_level', v_authority_level,
      'employment_type', p_employment_type
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'staff_id', v_staff_id,
    'staff_code', p_staff_code,
    'display_name', p_display_name,
    'staff_role', p_staff_role,
    'authority_level', v_authority_level,
    'staff_status', 'ACTIVE',
    'audit_id', v_audit_id,
    'message_code', 'staff_registered'
  );
end;
$$;


create or replace function catchmenu_store.update_staff_role(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_new_role text,
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
  v_staff record;
  v_new_authority int;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_new_role not in (
    'OWNER', 'MANAGER', 'SUPERVISOR',
    'STAFF', 'PART_TIME', 'TRAINEE'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_staff_role'
    );
  end if;

  if trim(coalesce(p_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'reason_required'
    );
  end if;

  -- only MANAGER+ can change roles
  if p_actor_type not in (
    'MANAGER', 'OWNER', 'HQ_ADMIN', 'SYSTEM'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'insufficient_authority'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, staff_code, display_name,
         staff_role, authority_level
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_staff.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'staff_not_found'
    );
  end if;

  v_new_authority := case p_new_role
    when 'OWNER' then 10
    when 'MANAGER' then 8
    when 'SUPERVISOR' then 5
    when 'STAFF' then 3
    when 'PART_TIME' then 2
    when 'TRAINEE' then 1
    else 1
  end;

  -- update role and permissions
  update catchmenu_store.staff
  set
    staff_role = p_new_role,
    authority_level = v_new_authority,
    can_override_kds =
      p_new_role in ('OWNER', 'MANAGER', 'SUPERVISOR'),
    can_approve_refund =
      p_new_role in ('OWNER', 'MANAGER'),
    can_manage_menu =
      p_new_role in ('OWNER', 'MANAGER', 'SUPERVISOR'),
    can_manage_staff =
      p_new_role in ('OWNER', 'MANAGER'),
    can_view_reports =
      p_new_role in ('OWNER', 'MANAGER', 'SUPERVISOR'),
    can_change_store_mode =
      p_new_role in ('OWNER', 'MANAGER'),
    updated_at = now()
  where id = p_staff_id;

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
    'staff', 'staff_role_changed', 1,
    'staff', p_staff_id,
    v_staff.staff_role, p_new_role,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'staff_code', v_staff.staff_code,
      'display_name', v_staff.display_name,
      'previous_role', v_staff.staff_role,
      'new_role', p_new_role,
      'reason', p_reason
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'staff',
    p_audit_type := 'staff_role_changed',
    p_audit_category := 'SECURITY',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'staff',
    p_subject_id := p_staff_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_reason,
    p_decision_payload := jsonb_build_object(
      'staff_code', v_staff.staff_code,
      'previous_role', v_staff.staff_role,
      'new_role', p_new_role,
      'new_authority_level', v_new_authority
    ),
    p_before_state := jsonb_build_object(
      'staff_role', v_staff.staff_role,
      'authority_level', v_staff.authority_level
    ),
    p_after_state := jsonb_build_object(
      'staff_role', p_new_role,
      'authority_level', v_new_authority
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'staff_id', p_staff_id,
    'staff_code', v_staff.staff_code,
    'previous_role', v_staff.staff_role,
    'new_role', p_new_role,
    'new_authority_level', v_new_authority,
    'reason', p_reason,
    'audit_id', v_audit_id,
    'message_code', 'staff_role_updated'
  );
end;
$$;


create or replace function catchmenu_store.record_staff_attendance(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_action text,
  p_attendance_date date default null,
  p_scheduled_start_at timestamptz default null,
  p_scheduled_end_at timestamptz default null,
  p_note text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_staff record;
  v_attendance record;
  v_timezone text;
  v_attendance_date date;
  v_late_minutes int := 0;
  v_worked_minutes int;
  v_attendance_id uuid;
begin
  if p_action not in ('CLOCK_IN', 'CLOCK_OUT') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_action',
      'allowed', array['CLOCK_IN', 'CLOCK_OUT']
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_attendance_date := coalesce(
    p_attendance_date,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- validate staff
  select id, staff_code, display_name, staff_status
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_staff.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'staff_not_found'
    );
  end if;

  if v_staff.staff_status = 'TERMINATED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'staff_terminated'
    );
  end if;

  -- get or create attendance record
  select id, clocked_in_at, clocked_out_at,
         attendance_status
  into v_attendance
  from catchmenu_store.staff_attendance
  where staff_id = p_staff_id
    and attendance_date = v_attendance_date
  for update;

  if p_action = 'CLOCK_IN' then
    if v_attendance.id is not null
      and v_attendance.clocked_in_at is not null
    then
      return jsonb_build_object(
        'success', false,
        'error_key', 'already_clocked_in',
        'clocked_in_at', v_attendance.clocked_in_at
      );
    end if;

    -- calculate late minutes
    if p_scheduled_start_at is not null then
      v_late_minutes := greatest(
        0,
        extract(
          epoch from (now() - p_scheduled_start_at)
        )::int / 60
      );
    end if;

    if v_attendance.id is null then
      insert into catchmenu_store.staff_attendance (
        tenant_id, store_id, staff_id,
        attendance_date, business_timezone,
        clocked_in_at,
        attendance_status, late_minutes,
        scheduled_start_at, scheduled_end_at,
        attendance_note
      ) values (
        p_tenant_id, p_store_id, p_staff_id,
        v_attendance_date, v_timezone,
        now(),
        case when v_late_minutes > 10
          then 'LATE' else 'PRESENT'
        end,
        v_late_minutes,
        p_scheduled_start_at, p_scheduled_end_at,
        p_note
      )
      returning id into v_attendance_id;
    else
      update catchmenu_store.staff_attendance
      set
        clocked_in_at = now(),
        attendance_status = case
          when v_late_minutes > 10 then 'LATE'
          else 'PRESENT'
        end,
        late_minutes = v_late_minutes,
        scheduled_start_at = coalesce(
          p_scheduled_start_at, scheduled_start_at
        ),
        updated_at = now()
      where id = v_attendance.id
      returning id into v_attendance_id;
    end if;

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
      'staff', 'staff_clocked_in', 1,
      'staff', p_staff_id,
      null, 'WORKING',
      'STAFF', p_staff_id,
      jsonb_build_object(
        'staff_code', v_staff.staff_code,
        'late_minutes', v_late_minutes,
        'attendance_date', v_attendance_date
      ),
      p_correlation_id,
      v_attendance_date, v_timezone, now()
    );

    return jsonb_build_object(
      'success', true,
      'attendance_id', v_attendance_id,
      'staff_id', p_staff_id,
      'staff_code', v_staff.staff_code,
      'display_name', v_staff.display_name,
      'action', 'CLOCK_IN',
      'clocked_in_at', now(),
      'late_minutes', v_late_minutes,
      'attendance_status', case
        when v_late_minutes > 10 then 'LATE'
        else 'PRESENT'
      end,
      'message_code', 'staff_clocked_in'
    );

  else -- CLOCK_OUT
    if v_attendance.id is null
      or v_attendance.clocked_in_at is null
    then
      return jsonb_build_object(
        'success', false,
        'error_key', 'not_clocked_in'
      );
    end if;

    if v_attendance.clocked_out_at is not null then
      return jsonb_build_object(
        'success', false,
        'error_key', 'already_clocked_out',
        'clocked_out_at', v_attendance.clocked_out_at
      );
    end if;

    v_worked_minutes := extract(
      epoch from (
        now() - v_attendance.clocked_in_at
      )
    )::int / 60;

    update catchmenu_store.staff_attendance
    set
      clocked_out_at = now(),
      worked_minutes = v_worked_minutes,
      overtime_minutes = greatest(
        0,
        v_worked_minutes - coalesce(
          extract(
            epoch from (
              scheduled_end_at - scheduled_start_at
            )
          )::int / 60,
          480
        )
      ),
      attendance_note = coalesce(
        p_note, attendance_note
      ),
      updated_at = now()
    where id = v_attendance.id
    returning id into v_attendance_id;

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
      'staff', 'staff_clocked_out', 1,
      'staff', p_staff_id,
      'WORKING', 'OFF_DUTY',
      'STAFF', p_staff_id,
      jsonb_build_object(
        'staff_code', v_staff.staff_code,
        'worked_minutes', v_worked_minutes,
        'attendance_date', v_attendance_date
      ),
      p_correlation_id,
      v_attendance_date, v_timezone, now()
    );

    return jsonb_build_object(
      'success', true,
      'attendance_id', v_attendance_id,
      'staff_id', p_staff_id,
      'staff_code', v_staff.staff_code,
      'display_name', v_staff.display_name,
      'action', 'CLOCK_OUT',
      'clocked_in_at', v_attendance.clocked_in_at,
      'clocked_out_at', now(),
      'worked_minutes', v_worked_minutes,
      'message_code', 'staff_clocked_out'
    );
  end if;
end;
$$;


create or replace function catchmenu_store.get_staff_schedule(
  p_tenant_id uuid,
  p_store_id uuid,
  p_target_date date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_timezone text;
  v_target_date date;
  v_staff_list jsonb;
  v_summary jsonb;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_date := coalesce(
    p_target_date,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ))::date
  );

  -- staff with attendance for target date
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'staff_id', s.id,
        'staff_code', s.staff_code,
        'display_name', s.display_name,
        'staff_role', s.staff_role,
        'authority_level', s.authority_level,
        'employment_type', s.employment_type,
        'attendance', case
          when a.id is not null
          then jsonb_build_object(
            'attendance_id', a.id,
            'clocked_in_at', a.clocked_in_at,
            'clocked_out_at', a.clocked_out_at,
            'worked_minutes', a.worked_minutes,
            'overtime_minutes', a.overtime_minutes,
            'attendance_status', a.attendance_status,
            'late_minutes', a.late_minutes,
            'scheduled_start_at', a.scheduled_start_at,
            'scheduled_end_at', a.scheduled_end_at
          )
          else null
        end,
        'is_working', a.clocked_in_at is not null
          and a.clocked_out_at is null
      )
      order by s.authority_level desc, s.display_name
    ),
    '[]'::jsonb
  )
  into v_staff_list
  from catchmenu_store.staff s
  left join catchmenu_store.staff_attendance a
    on a.staff_id = s.id
    and a.attendance_date = v_target_date
  where s.store_id = p_store_id
    and s.tenant_id = p_tenant_id
    and s.is_active = true
    and s.staff_status = 'ACTIVE';

  -- daily summary
  select jsonb_build_object(
    'total_staff', count(distinct s.id),
    'working_now', count(distinct a.staff_id) filter (
      where a.clocked_in_at is not null
        and a.clocked_out_at is null
    ),
    'clocked_out', count(distinct a.staff_id) filter (
      where a.clocked_out_at is not null
    ),
    'not_arrived', count(distinct s.id) filter (
      where a.id is null
    ),
    'late_count', count(distinct a.staff_id) filter (
      where a.attendance_status = 'LATE'
    ),
    'total_worked_minutes', coalesce(
      sum(a.worked_minutes), 0
    )
  )
  into v_summary
  from catchmenu_store.staff s
  left join catchmenu_store.staff_attendance a
    on a.staff_id = s.id
    and a.attendance_date = v_target_date
  where s.store_id = p_store_id
    and s.tenant_id = p_tenant_id
    and s.is_active = true
    and s.staff_status = 'ACTIVE';

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'target_date', v_target_date,
    'staff', v_staff_list,
    'summary', v_summary,
    'generated_at', now(),
    'message_code', 'staff_schedule_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.register_staff(
    uuid, uuid, text, text, text, text,
    text, text, text, date, numeric, numeric,
    text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.register_staff(
    uuid, uuid, text, text, text, text,
    text, text, text, date, numeric, numeric,
    text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.update_staff_role(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.update_staff_role(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.record_staff_attendance(
    uuid, uuid, uuid, text, date,
    timestamptz, timestamptz, text, text
  ) from public;
  grant execute on function catchmenu_store.record_staff_attendance(
    uuid, uuid, uuid, text, date,
    timestamptz, timestamptz, text, text
  ) to authenticated;

  revoke all on function catchmenu_store.get_staff_schedule(
    uuid, uuid, date
  ) from public;
  grant execute on function catchmenu_store.get_staff_schedule(
    uuid, uuid, date
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.register_staff(
  uuid, uuid, text, text, text, text,
  text, text, text, date, numeric, numeric,
  text, uuid, text
) is
  'Registers new staff member with role-based default permissions.
   Authority levels: OWNER=10, MANAGER=8, SUPERVISOR=5,
   STAFF=3, PART_TIME=2, TRAINEE=1.
   특허4: Human Authority Runtime.
   역할별 권한 자동 설정 — MANAGER 이상만 실행 권한 보유.';

comment on function catchmenu_store.record_staff_attendance(
  uuid, uuid, uuid, text, date,
  timestamptz, timestamptz, text, text
) is
  'Records staff clock-in and clock-out.
   Calculates late_minutes against scheduled_start_at.
   Calculates worked_minutes and overtime at clock-out.
   특허3: 근태 데이터 → 일별 KPI → SOP 개선 피드백.
   피크타임 인력 배치 최적화 Agent의 학습 데이터.';

comment on function catchmenu_store.get_staff_schedule(
  uuid, uuid, date
) is
  'Returns all active staff with attendance status for target date.
   Shows: working_now, clocked_out, not_arrived, late_count.
   Used by manager dashboard for daily staffing overview.
   특허3: 인력 현황 → Agent 추천 → SOP 개선.';