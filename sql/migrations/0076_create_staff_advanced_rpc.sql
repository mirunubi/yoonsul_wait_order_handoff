-- 0076_create_staff_advanced_rpc.sql
-- Purpose: Advanced staff management RPCs.
--          Staff scheduling, shift management,
--          work hour calculation, pay basis records.
--          2차 yoonsul_os 매장 운영 기반 선행 작업.
-- Depends on: 0075_create_pos_edge_function_handlers.sql
-- Creates:
--   catchmenu_store.staff_schedules (table)
--   catchmenu_store.staff_shifts (table)
--   catchmenu_store.pay_basis_records (table)
--   function catchmenu_store.create_staff_schedule(...)
--   function catchmenu_store.open_shift(...)
--   function catchmenu_store.close_shift(...)
--   function catchmenu_store.get_staff_schedule_week(...)
--   function catchmenu_store.calculate_work_hours(...)
--   function catchmenu_store.get_pay_basis_summary(...)

-- =============================================
-- staff_schedules table
-- 직원 주간 스케줄 (그리드 스케줄)
-- =============================================
create table if not exists
  catchmenu_store.staff_schedules (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  staff_id uuid not null
    references catchmenu_store.staff(id),

  -- 스케줄 기간
  schedule_week_start date not null,
  schedule_week_end date not null,

  -- 요일별 스케줄
  -- {mon: {start: "09:00", end: "18:00", off: false}}
  schedule_grid jsonb not null
    default '{}'::jsonb,

  -- 상태
  schedule_status text not null default 'DRAFT',
  published_at timestamptz,
  published_by uuid,

  -- 확정 근무 시간 (그리드 기반)
  planned_hours numeric(5,2)
    not null default 0,

  -- 메모
  schedule_note text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_staff_schedule_week unique (
    staff_id, schedule_week_start
  ),
  constraint chk_schedule_status check (
    schedule_status in (
      'DRAFT', 'PUBLISHED',
      'CONFIRMED', 'ARCHIVED'
    )
  ),
  constraint chk_schedule_week check (
    schedule_week_end =
      schedule_week_start + interval '6 days'
  )
);

create index if not exists idx_staff_schedule_week
  on catchmenu_store.staff_schedules(
    store_id, schedule_week_start
  );
create index if not exists idx_staff_schedule_staff
  on catchmenu_store.staff_schedules(
    staff_id, schedule_week_start desc
  );

alter table catchmenu_store.staff_schedules
  enable row level security;
alter table catchmenu_store.staff_schedules
  force row level security;

drop policy if exists staff_schedules_isolation
  on catchmenu_store.staff_schedules;
create policy staff_schedules_isolation
  on catchmenu_store.staff_schedules
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_staff_schedules_updated
  on catchmenu_store.staff_schedules;
create trigger trg_staff_schedules_updated
  before update on catchmenu_store.staff_schedules
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.staff_schedules is
  '직원 주간 그리드 스케줄.
   schedule_grid 구조:
   {
     "mon": {"start": "09:00", "end": "18:00", "off": false},
     "tue": {"start": "09:00", "end": "18:00", "off": false},
     "wed": {"off": true},
     "thu": {"start": "13:00", "end": "22:00", "off": false},
     "fri": {"start": "13:00", "end": "22:00", "off": false},
     "sat": {"start": "10:00", "end": "19:00", "off": false},
     "sun": {"off": true}
   }
   planned_hours: 그리드 기반 예정 근무시간 합계.
   2차 yoonsul_os 인력관리 앱 선행 데이터 구조.';


-- =============================================
-- staff_shifts table
-- 실제 출퇴근 기록 (시프트)
-- =============================================
create table if not exists
  catchmenu_store.staff_shifts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  staff_id uuid not null
    references catchmenu_store.staff(id),
  schedule_id uuid
    references catchmenu_store.staff_schedules(id),

  -- 시프트 날짜
  shift_date date not null,
  day_of_week text not null,
  business_timezone text
    not null default 'Asia/Seoul',

  -- 예정 시간 (스케줄 기반)
  planned_start_time time,
  planned_end_time time,
  planned_hours numeric(5,2),

  -- 실제 시간 (출퇴근 기록)
  actual_clock_in timestamptz,
  actual_clock_out timestamptz,
  actual_hours numeric(5,2),

  -- 휴식
  break_minutes int not null default 0,
  net_work_minutes int,

  -- 지각/조기퇴근
  late_minutes int not null default 0,
  early_leave_minutes int not null default 0,

  -- 초과근무
  overtime_minutes int not null default 0,
  overtime_approved boolean not null default false,
  overtime_approved_by uuid,

  -- 상태
  shift_status text not null default 'SCHEDULED',
  shift_note text,

  -- 급여 계산용
  is_pay_calculated boolean not null default false,
  pay_calculated_at timestamptz,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_staff_shift_date unique (
    staff_id, shift_date
  ),
  constraint chk_day_of_week check (
    day_of_week in (
      'mon', 'tue', 'wed',
      'thu', 'fri', 'sat', 'sun'
    )
  ),
  constraint chk_shift_status check (
    shift_status in (
      'SCHEDULED', 'CLOCKED_IN',
      'CLOCKED_OUT', 'ABSENT',
      'NO_SHOW', 'CANCELLED'
    )
  )
);

create index if not exists idx_staff_shifts_date
  on catchmenu_store.staff_shifts(
    store_id, shift_date desc
  );
create index if not exists idx_staff_shifts_staff
  on catchmenu_store.staff_shifts(
    staff_id, shift_date desc
  );
create index if not exists idx_staff_shifts_status
  on catchmenu_store.staff_shifts(
    store_id, shift_status
  ) where shift_status = 'CLOCKED_IN';

alter table catchmenu_store.staff_shifts
  enable row level security;
alter table catchmenu_store.staff_shifts
  force row level security;

drop policy if exists staff_shifts_isolation
  on catchmenu_store.staff_shifts;
create policy staff_shifts_isolation
  on catchmenu_store.staff_shifts
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_staff_shifts_updated
  on catchmenu_store.staff_shifts;
create trigger trg_staff_shifts_updated
  before update on catchmenu_store.staff_shifts
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.staff_shifts is
  '직원 실제 출퇴근 기록.
   schedule_id → staff_schedules 연결.
   actual_clock_in/out: 실제 출퇴근 시각.
   net_work_minutes = actual - break_minutes.
   overtime_minutes: 초과근무 (승인 필요).
   is_pay_calculated: 급여 계산 완료 여부.
   2차 yoonsul_os 인력관리 앱 핵심 데이터.';


-- =============================================
-- pay_basis_records table
-- 급여 산정 기초 기록
-- =============================================
create table if not exists
  catchmenu_store.pay_basis_records (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  staff_id uuid not null
    references catchmenu_store.staff(id),

  -- 급여 기간
  pay_period_start date not null,
  pay_period_end date not null,
  pay_period_type text not null default 'MONTHLY',

  -- 시급 정보 (시점 스냅샷)
  hourly_rate int not null,
  currency text not null default 'KRW',

  -- 근무 집계
  total_scheduled_hours numeric(6,2)
    not null default 0,
  total_actual_hours numeric(6,2)
    not null default 0,
  total_overtime_hours numeric(6,2)
    not null default 0,
  total_absent_days int not null default 0,
  total_late_count int not null default 0,

  -- 급여 계산
  base_pay int not null default 0,
  overtime_pay int not null default 0,
  deduction_amount int not null default 0,
  deduction_reason text,
  net_pay int not null default 0,

  -- 4대보험 (기초 정보)
  national_pension int not null default 0,
  health_insurance int not null default 0,
  employment_insurance int not null default 0,
  industrial_accident int not null default 0,

  -- 상태
  pay_status text not null default 'CALCULATED',
  confirmed_at timestamptz,
  confirmed_by uuid,
  paid_at timestamptz,
  payment_note text,

  -- 증빙
  shift_ids jsonb default '[]'::jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_pay_period unique (
    staff_id, pay_period_start, pay_period_type
  ),
  constraint chk_pay_period_type check (
    pay_period_type in (
      'WEEKLY', 'BIWEEKLY', 'MONTHLY'
    )
  ),
  constraint chk_pay_status check (
    pay_status in (
      'CALCULATED', 'CONFIRMED',
      'PAID', 'DISPUTED', 'ADJUSTED'
    )
  )
);

create index if not exists idx_pay_basis_period
  on catchmenu_store.pay_basis_records(
    store_id, pay_period_start desc
  );
create index if not exists idx_pay_basis_staff
  on catchmenu_store.pay_basis_records(
    staff_id, pay_period_start desc
  );

alter table catchmenu_store.pay_basis_records
  enable row level security;
alter table catchmenu_store.pay_basis_records
  force row level security;

drop policy if exists pay_basis_isolation
  on catchmenu_store.pay_basis_records;
create policy pay_basis_isolation
  on catchmenu_store.pay_basis_records
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_pay_basis_updated
  on catchmenu_store.pay_basis_records;
create trigger trg_pay_basis_updated
  before update on catchmenu_store.pay_basis_records
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.pay_basis_records is
  '급여 산정 기초 기록.
   hourly_rate: 급여 계산 시점 스냅샷 (변경 불가).
   net_pay = base_pay + overtime_pay - deduction.
   4대보험: 기초 계산값 (실제 신고는 별도).
   pay_status CONFIRMED → 확정 후 수정 금지.
   특허4: 급여 원장 = append-only 증빙.
   2차 yoonsul_os 인력관리 앱 핵심 산출물.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.create_staff_schedule(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_week_start date,
  p_schedule_grid jsonb,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_schedule_note text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_schedule_id uuid;
  v_week_end date;
  v_planned_hours numeric(5,2) := 0;
  v_day text;
  v_day_data jsonb;
  v_start_time time;
  v_end_time time;
  v_day_hours numeric(5,2);
  v_business_day date;
  v_timezone text;
  v_days text[] := array[
    'mon','tue','wed','thu','fri','sat','sun'
  ];
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- week_start는 월요일이어야 함
  if extract(dow from p_week_start) <> 1 then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := 'ko',
      p_params := jsonb_build_object(
        'field', 'week_start',
        'message', '주간 시작일은 월요일이어야 합니다'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'create_staff_schedule'
    );
  end if;

  v_week_end := p_week_start + interval '6 days';

  -- 직원 존재 확인
  if not exists (
    select 1 from catchmenu_store.staff
    where id = p_staff_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_not_found',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'create_staff_schedule'
    );
  end if;

  -- 예정 근무시간 계산
  foreach v_day in array v_days loop
    v_day_data := p_schedule_grid->v_day;

    if v_day_data is not null
      and not coalesce(
        (v_day_data->>'off')::boolean, false
      )
    then
      begin
        v_start_time := (
          v_day_data->>'start'
        )::time;
        v_end_time := (
          v_day_data->>'end'
        )::time;

        if v_end_time > v_start_time then
          v_day_hours := extract(
            epoch from (v_end_time - v_start_time)
          ) / 3600;
          v_planned_hours :=
            v_planned_hours + v_day_hours;
        end if;
      exception when others then
        null; -- invalid time format → skip
      end;
    end if;
  end loop;

  -- upsert schedule
  insert into catchmenu_store.staff_schedules (
    tenant_id, store_id, staff_id,
    schedule_week_start, schedule_week_end,
    schedule_grid, schedule_status,
    planned_hours, schedule_note
  ) values (
    p_tenant_id, p_store_id, p_staff_id,
    p_week_start, v_week_end,
    p_schedule_grid, 'DRAFT',
    v_planned_hours, p_schedule_note
  )
  on conflict (staff_id, schedule_week_start)
  do update set
    schedule_grid = excluded.schedule_grid,
    planned_hours = excluded.planned_hours,
    schedule_status = case
      when catchmenu_store.staff_schedules
        .schedule_status = 'PUBLISHED'
      then 'DRAFT'
      else catchmenu_store.staff_schedules
        .schedule_status
    end,
    schedule_note = coalesce(
      excluded.schedule_note,
      catchmenu_store.staff_schedules.schedule_note
    ),
    updated_at = now()
  returning id into v_schedule_id;

  -- 시프트 자동 생성
  declare
    v_day_idx int := 0;
    v_shift_date date;
    v_dow text;
  begin
    foreach v_dow in array v_days loop
      v_shift_date := p_week_start + v_day_idx;
      v_day_data := p_schedule_grid->v_dow;

      if v_day_data is not null
        and not coalesce(
          (v_day_data->>'off')::boolean, false
        )
      then
        insert into catchmenu_store.staff_shifts (
          tenant_id, store_id, staff_id,
          schedule_id, shift_date, day_of_week,
          business_timezone,
          planned_start_time, planned_end_time,
          planned_hours,
          shift_status, business_day
        ) values (
          p_tenant_id, p_store_id, p_staff_id,
          v_schedule_id, v_shift_date, v_dow,
          coalesce(v_timezone, 'Asia/Seoul'),
          (v_day_data->>'start')::time,
          (v_day_data->>'end')::time,
          extract(epoch from (
            (v_day_data->>'end')::time
            - (v_day_data->>'start')::time
          )) / 3600,
          'SCHEDULED', v_shift_date
        )
        on conflict (staff_id, shift_date)
        do update set
          schedule_id = excluded.schedule_id,
          planned_start_time =
            excluded.planned_start_time,
          planned_end_time = excluded.planned_end_time,
          planned_hours = excluded.planned_hours,
          shift_status = case
            when catchmenu_store.staff_shifts
              .shift_status in (
                'CLOCKED_IN', 'CLOCKED_OUT'
              )
            then catchmenu_store.staff_shifts
              .shift_status
            else 'SCHEDULED'
          end,
          updated_at = now();
      end if;

      v_day_idx := v_day_idx + 1;
    end loop;
  end;

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
    'staff', 'schedule_created', 1,
    'staff_schedule', v_schedule_id,
    null, 'DRAFT',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'staff_id', p_staff_id,
      'week_start', p_week_start,
      'week_end', v_week_end,
      'planned_hours', v_planned_hours
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'schedule_id', v_schedule_id,
    'staff_id', p_staff_id,
    'week_start', p_week_start,
    'week_end', v_week_end,
    'planned_hours', v_planned_hours,
    'schedule_status', 'DRAFT',
    'message_code', 'schedule_created'
  );
end;
$$;


create or replace function
  catchmenu_store.open_shift(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_shift_date date default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_shift record;
  v_staff record;
  v_clock_in timestamptz;
  v_late_minutes int := 0;
  v_target_date date;
  v_timezone text;
  v_business_day date;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_clock_in := now();
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), v_clock_in
  ))::date;
  v_target_date := coalesce(
    p_shift_date, v_business_day
  );

  -- 직원 확인
  select id, display_name, staff_status,
         hourly_rate
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_staff.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'open_shift'
    );
  end if;

  if v_staff.staff_status = 'TERMINATED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_terminated',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'open_shift'
    );
  end if;

  -- 이미 출근 중인지 확인
  if exists (
    select 1 from catchmenu_store.staff_shifts
    where staff_id = p_staff_id
      and shift_date = v_target_date
      and shift_status = 'CLOCKED_IN'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'already_clocked_in',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'open_shift'
    );
  end if;

  -- 스케줄 기반 시프트 가져오기
  select id, planned_start_time,
         planned_end_time, planned_hours
  into v_shift
  from catchmenu_store.staff_shifts
  where staff_id = p_staff_id
    and shift_date = v_target_date
    and shift_status = 'SCHEDULED';

  -- 지각 계산
  if v_shift.id is not null
    and v_shift.planned_start_time is not null
  then
    declare
      v_planned_start timestamptz;
    begin
      v_planned_start := (
        v_target_date::text || ' '
        || v_shift.planned_start_time::text
      )::timestamptz
        at time zone coalesce(v_timezone, 'Asia/Seoul');

      if v_clock_in > v_planned_start
        + interval '5 minutes'
      then
        v_late_minutes := extract(
          epoch from (v_clock_in - v_planned_start)
        )::int / 60;
      end if;
    end;
  end if;

  -- upsert shift (스케줄 없으면 새로 생성)
  if v_shift.id is not null then
    update catchmenu_store.staff_shifts
    set
      actual_clock_in = v_clock_in,
      shift_status = 'CLOCKED_IN',
      late_minutes = v_late_minutes,
      updated_at = now()
    where id = v_shift.id
    returning id into v_shift.id;
  else
    -- 스케줄 없는 임시 출근
    insert into catchmenu_store.staff_shifts (
      tenant_id, store_id, staff_id,
      shift_date, day_of_week,
      business_timezone,
      actual_clock_in, shift_status,
      late_minutes, business_day
    ) values (
      p_tenant_id, p_store_id, p_staff_id,
      v_target_date,
      lower(to_char(v_target_date, 'dy')),
      coalesce(v_timezone, 'Asia/Seoul'),
      v_clock_in, 'CLOCKED_IN',
      0, v_business_day
    )
    returning id into v_shift.id;
  end if;

  -- 출근 기록 (attendance)
  insert into catchmenu_store.staff_attendance (
    tenant_id, store_id, staff_id,
    attendance_type, attendance_status,
    clock_in_at, clock_in_method,
    late_minutes, shift_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_staff_id,
    'CLOCK_IN', 'CONFIRMED',
    v_clock_in, 'APP',
    v_late_minutes, v_shift.id,
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul')
  );

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
    'staff', 'shift_opened', 1,
    'staff_shift', v_shift.id,
    'SCHEDULED', 'CLOCKED_IN',
    'STAFF', p_staff_id,
    jsonb_build_object(
      'staff_id', p_staff_id,
      'display_name', v_staff.display_name,
      'shift_date', v_target_date,
      'clock_in_at', v_clock_in,
      'late_minutes', v_late_minutes,
      'is_scheduled',
        v_shift.planned_start_time is not null
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := case
      when v_late_minutes > 10 then 'WARNING'
      else 'INFO'
    end,
    p_log_domain := 'STAFF',
    p_log_event := 'shift_opened',
    p_message :=
      v_staff.display_name
      || ' 출근 | '
      || to_char(v_clock_in at time zone
        coalesce(v_timezone, 'Asia/Seoul'),
        'HH24:MI'
      )
      || case when v_late_minutes > 0
        then ' | 지각 ' || v_late_minutes || '분'
        else ''
      end,
    p_rpc_name := 'open_shift',
    p_correlation_id := p_correlation_id,
    p_staff_id := p_staff_id,
    p_details := jsonb_build_object(
      'shift_id', v_shift.id,
      'shift_date', v_target_date,
      'late_minutes', v_late_minutes
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'session_created',
    p_data := jsonb_build_object(
      'shift_id', v_shift.id,
      'staff_id', p_staff_id,
      'display_name', v_staff.display_name,
      'shift_date', v_target_date,
      'clock_in_at', v_clock_in,
      'late_minutes', v_late_minutes,
      'is_late', v_late_minutes > 5,
      'planned_start_time',
        v_shift.planned_start_time,
      'planned_end_time',
        v_shift.planned_end_time
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.close_shift(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_break_minutes int default 0,
  p_shift_note text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_shift record;
  v_staff record;
  v_clock_out timestamptz;
  v_actual_minutes int;
  v_net_minutes int;
  v_overtime_minutes int := 0;
  v_early_leave_minutes int := 0;
  v_actual_hours numeric(5,2);
  v_timezone text;
  v_business_day date;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_clock_out := now();
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), v_clock_out
  ))::date;

  -- 직원 확인
  select id, display_name, hourly_rate
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_staff.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'close_shift'
    );
  end if;

  -- 현재 출근 중인 시프트 확인
  select id, actual_clock_in,
         planned_end_time, planned_hours,
         late_minutes, shift_date
  into v_shift
  from catchmenu_store.staff_shifts
  where staff_id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and shift_status = 'CLOCKED_IN'
  order by actual_clock_in desc
  limit 1;

  if v_shift.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'not_clocked_in',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'close_shift'
    );
  end if;

  -- 근무 시간 계산
  v_actual_minutes := extract(
    epoch from (v_clock_out - v_shift.actual_clock_in)
  )::int / 60;

  v_net_minutes := greatest(
    0, v_actual_minutes - p_break_minutes
  );
  v_actual_hours := v_net_minutes::numeric / 60;

  -- 초과근무 / 조기퇴근 계산
  if v_shift.planned_end_time is not null then
    declare
      v_planned_end timestamptz;
      v_diff_minutes int;
    begin
      v_planned_end := (
        v_shift.shift_date::text || ' '
        || v_shift.planned_end_time::text
      )::timestamptz
        at time zone coalesce(v_timezone, 'Asia/Seoul');

      v_diff_minutes := extract(
        epoch from (v_clock_out - v_planned_end)
      )::int / 60;

      if v_diff_minutes > 10 then
        v_overtime_minutes := v_diff_minutes;
      elsif v_diff_minutes < -10 then
        v_early_leave_minutes := abs(v_diff_minutes);
      end if;
    end;
  end if;

  -- 시프트 업데이트
  update catchmenu_store.staff_shifts
  set
    actual_clock_out = v_clock_out,
    actual_hours = v_actual_hours,
    break_minutes = p_break_minutes,
    net_work_minutes = v_net_minutes,
    overtime_minutes = v_overtime_minutes,
    early_leave_minutes = v_early_leave_minutes,
    shift_status = 'CLOCKED_OUT',
    shift_note = coalesce(
      p_shift_note, shift_note
    ),
    updated_at = now()
  where id = v_shift.id;

  -- 출퇴근 기록 업데이트
  update catchmenu_store.staff_attendance
  set
    clock_out_at = v_clock_out,
    work_minutes = v_net_minutes,
    break_minutes = p_break_minutes,
    attendance_status = 'CONFIRMED',
    updated_at = now()
  where staff_id = p_staff_id
    and shift_id = v_shift.id
    and attendance_type = 'CLOCK_IN';

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
    'staff', 'shift_closed', 1,
    'staff_shift', v_shift.id,
    'CLOCKED_IN', 'CLOCKED_OUT',
    'STAFF', p_staff_id,
    jsonb_build_object(
      'staff_id', p_staff_id,
      'display_name', v_staff.display_name,
      'clock_in_at', v_shift.actual_clock_in,
      'clock_out_at', v_clock_out,
      'actual_hours', v_actual_hours,
      'net_minutes', v_net_minutes,
      'overtime_minutes', v_overtime_minutes,
      'early_leave_minutes', v_early_leave_minutes,
      'break_minutes', p_break_minutes
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'STAFF',
    p_log_event := 'shift_closed',
    p_message :=
      v_staff.display_name
      || ' 퇴근 | 근무 '
      || v_net_minutes || '분'
      || case when v_overtime_minutes > 0
        then ' | 초과 ' || v_overtime_minutes || '분'
        else ''
      end,
    p_rpc_name := 'close_shift',
    p_staff_id := p_staff_id,
    p_details := jsonb_build_object(
      'shift_id', v_shift.id,
      'actual_hours', v_actual_hours,
      'overtime_minutes', v_overtime_minutes
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'session_created',
    p_data := jsonb_build_object(
      'shift_id', v_shift.id,
      'staff_id', p_staff_id,
      'display_name', v_staff.display_name,
      'clock_in_at', v_shift.actual_clock_in,
      'clock_out_at', v_clock_out,
      'actual_hours', v_actual_hours,
      'net_work_minutes', v_net_minutes,
      'break_minutes', p_break_minutes,
      'overtime_minutes', v_overtime_minutes,
      'early_leave_minutes', v_early_leave_minutes,
      'is_overtime', v_overtime_minutes > 0,
      'hourly_rate', v_staff.hourly_rate,
      'estimated_pay',
        (v_actual_hours * v_staff.hourly_rate)::int
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.get_staff_schedule_week(
  p_tenant_id uuid,
  p_store_id uuid,
  p_week_start date,
  p_staff_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_schedules jsonb;
  v_week_end date;
  v_summary jsonb;
begin
  v_week_end := p_week_start + interval '6 days';

  -- 주간 스케줄 + 실제 시프트 조인
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'staff_id', s.id,
        'staff_code', s.staff_code,
        'display_name', s.display_name,
        'staff_role', s.staff_role,
        'hourly_rate', s.hourly_rate,
        'schedule', case
          when ss.id is not null
          then jsonb_build_object(
            'schedule_id', ss.id,
            'schedule_status', ss.schedule_status,
            'planned_hours', ss.planned_hours,
            'schedule_grid', ss.schedule_grid
          )
          else null
        end,
        'shifts', (
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'shift_id', sh.id,
                'shift_date', sh.shift_date,
                'day_of_week', sh.day_of_week,
                'planned_start_time',
                  sh.planned_start_time,
                'planned_end_time',
                  sh.planned_end_time,
                'actual_clock_in',
                  sh.actual_clock_in,
                'actual_clock_out',
                  sh.actual_clock_out,
                'actual_hours', sh.actual_hours,
                'shift_status', sh.shift_status,
                'late_minutes', sh.late_minutes,
                'overtime_minutes',
                  sh.overtime_minutes,
                'net_work_minutes',
                  sh.net_work_minutes
              )
              order by sh.shift_date
            ),
            '[]'::jsonb
          )
          from catchmenu_store.staff_shifts sh
          where sh.staff_id = s.id
            and sh.shift_date between
              p_week_start and v_week_end
        ),
        'week_summary', (
          select jsonb_build_object(
            'total_planned_hours',
              coalesce(ss.planned_hours, 0),
            'total_actual_hours', coalesce(
              sum(sh.actual_hours), 0
            ),
            'total_overtime_minutes', coalesce(
              sum(sh.overtime_minutes), 0
            ),
            'total_late_count', count(*)
              filter (where sh.late_minutes > 5),
            'absent_count', count(*)
              filter (
                where sh.shift_status = 'ABSENT'
              ),
            'estimated_pay', (
              coalesce(sum(sh.actual_hours), 0)
              * s.hourly_rate
            )::int
          )
          from catchmenu_store.staff_shifts sh
          where sh.staff_id = s.id
            and sh.shift_date between
              p_week_start and v_week_end
        )
      )
      order by s.display_name
    ),
    '[]'::jsonb
  )
  into v_schedules
  from catchmenu_store.staff s
  left join catchmenu_store.staff_schedules ss
    on ss.staff_id = s.id
    and ss.schedule_week_start = p_week_start
  where s.store_id = p_store_id
    and s.tenant_id = p_tenant_id
    and s.is_active = true
    and s.staff_status = 'ACTIVE'
    and (
      p_staff_id is null
      or s.id = p_staff_id
    );

  -- 매장 주간 요약
  select jsonb_build_object(
    'total_staff', count(distinct staff_id),
    'total_planned_hours',
      coalesce(sum(planned_hours), 0),
    'total_actual_hours',
      coalesce(sum(actual_hours), 0),
    'total_overtime_minutes',
      coalesce(sum(overtime_minutes), 0),
    'total_estimated_pay', coalesce(
      sum(
        actual_hours * (
          select hourly_rate
          from catchmenu_store.staff
          where id = staff_id
        )
      ), 0
    )::int
  )
  into v_summary
  from catchmenu_store.staff_shifts
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and shift_date between
      p_week_start and v_week_end
    and (
      p_staff_id is null
      or staff_id = p_staff_id
    );

  return jsonb_build_object(
    'success', true,
    'week_start', p_week_start,
    'week_end', v_week_end,
    'staff_schedules', v_schedules,
    'staff_count', jsonb_array_length(v_schedules),
    'week_summary', v_summary,
    'message_code', 'staff_schedule_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.calculate_work_hours(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_period_start date,
  p_period_end date,
  p_pay_period_type text default 'MONTHLY',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_staff record;
  v_record_id uuid;
  v_totals record;
  v_base_pay int;
  v_overtime_pay int;
  v_net_pay int;
  v_shift_ids jsonb;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  -- 직원 및 시급 정보
  select id, display_name, staff_role,
         hourly_rate, is_active
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_staff.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_not_found',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'calculate_work_hours'
    );
  end if;

  -- 기간 내 시프트 집계
  select
    coalesce(sum(planned_hours), 0)
      as total_scheduled,
    coalesce(sum(actual_hours), 0)
      as total_actual,
    coalesce(
      sum(overtime_minutes)::numeric / 60, 0
    ) as total_overtime,
    count(*) filter (
      where shift_status = 'ABSENT'
    ) as absent_days,
    count(*) filter (
      where late_minutes > 5
    ) as late_count,
    coalesce(
      jsonb_agg(id) filter (
        where shift_status in (
          'CLOCKED_OUT', 'ABSENT'
        )
      ),
      '[]'::jsonb
    ) as shift_ids
  into v_totals
  from catchmenu_store.staff_shifts
  where staff_id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and shift_date between p_period_start
      and p_period_end;

  -- 급여 계산
  v_base_pay := (
    v_totals.total_actual * v_staff.hourly_rate
  )::int;

  -- 초과근무 1.5배 (한국 근로기준법 기준)
  v_overtime_pay := (
    v_totals.total_overtime
    * v_staff.hourly_rate * 1.5
  )::int;

  v_net_pay := v_base_pay + v_overtime_pay;

  -- pay_basis_record upsert
  insert into catchmenu_store.pay_basis_records (
    tenant_id, store_id, staff_id,
    pay_period_start, pay_period_end,
    pay_period_type,
    hourly_rate,
    total_scheduled_hours,
    total_actual_hours,
    total_overtime_hours,
    total_absent_days,
    total_late_count,
    base_pay, overtime_pay, net_pay,
    pay_status, shift_ids
  ) values (
    p_tenant_id, p_store_id, p_staff_id,
    p_period_start, p_period_end,
    p_pay_period_type,
    v_staff.hourly_rate,
    v_totals.total_scheduled,
    v_totals.total_actual,
    v_totals.total_overtime,
    v_totals.absent_days,
    v_totals.late_count,
    v_base_pay, v_overtime_pay, v_net_pay,
    'CALCULATED', v_totals.shift_ids
  )
  on conflict (staff_id, pay_period_start, pay_period_type)
  do update set
    total_scheduled_hours =
      excluded.total_scheduled_hours,
    total_actual_hours = excluded.total_actual_hours,
    total_overtime_hours =
      excluded.total_overtime_hours,
    total_absent_days = excluded.total_absent_days,
    total_late_count = excluded.total_late_count,
    base_pay = excluded.base_pay,
    overtime_pay = excluded.overtime_pay,
    net_pay = excluded.net_pay,
    pay_status = 'CALCULATED',
    shift_ids = excluded.shift_ids,
    updated_at = now()
  returning id into v_record_id;

  return jsonb_build_object(
    'success', true,
    'record_id', v_record_id,
    'staff_id', p_staff_id,
    'display_name', v_staff.display_name,
    'period_start', p_period_start,
    'period_end', p_period_end,
    'calculation', jsonb_build_object(
      'hourly_rate', v_staff.hourly_rate,
      'total_scheduled_hours',
        v_totals.total_scheduled,
      'total_actual_hours', v_totals.total_actual,
      'total_overtime_hours',
        v_totals.total_overtime,
      'absent_days', v_totals.absent_days,
      'late_count', v_totals.late_count,
      'base_pay', v_base_pay,
      'overtime_pay', v_overtime_pay,
      'net_pay', v_net_pay,
      'currency', 'KRW'
    ),
    'message_code', 'work_hours_calculated'
  );
end;
$$;


create or replace function
  catchmenu_store.get_pay_basis_summary(
  p_tenant_id uuid,
  p_store_id uuid,
  p_period_start date,
  p_period_end date
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_records jsonb;
  v_totals jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'record_id', pbr.id,
        'staff_id', pbr.staff_id,
        'display_name', s.display_name,
        'staff_role', s.staff_role,
        'hourly_rate', pbr.hourly_rate,
        'total_actual_hours',
          pbr.total_actual_hours,
        'total_overtime_hours',
          pbr.total_overtime_hours,
        'absent_days', pbr.total_absent_days,
        'late_count', pbr.total_late_count,
        'base_pay', pbr.base_pay,
        'overtime_pay', pbr.overtime_pay,
        'net_pay', pbr.net_pay,
        'pay_status', pbr.pay_status,
        'confirmed_at', pbr.confirmed_at,
        'paid_at', pbr.paid_at
      )
      order by s.display_name
    ),
    '[]'::jsonb
  )
  into v_records
  from catchmenu_store.pay_basis_records pbr
  join catchmenu_store.staff s
    on s.id = pbr.staff_id
  where pbr.store_id = p_store_id
    and pbr.tenant_id = p_tenant_id
    and pbr.pay_period_start = p_period_start
    and pbr.pay_period_end = p_period_end;

  -- 매장 전체 급여 합계
  select jsonb_build_object(
    'total_staff', count(*),
    'total_actual_hours',
      coalesce(sum(total_actual_hours), 0),
    'total_base_pay',
      coalesce(sum(base_pay), 0),
    'total_overtime_pay',
      coalesce(sum(overtime_pay), 0),
    'total_net_pay',
      coalesce(sum(net_pay), 0),
    'confirmed_count', count(*) filter (
      where pay_status in ('CONFIRMED', 'PAID')
    ),
    'pending_count', count(*) filter (
      where pay_status = 'CALCULATED'
    )
  )
  into v_totals
  from catchmenu_store.pay_basis_records
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and pay_period_start = p_period_start
    and pay_period_end = p_period_end;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'period_start', p_period_start,
    'period_end', p_period_end,
    'records', v_records,
    'totals', v_totals,
    'message_code', 'pay_basis_summary_loaded'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.create_staff_schedule(
      uuid, uuid, uuid, date, jsonb,
      text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.create_staff_schedule(
      uuid, uuid, uuid, date, jsonb,
      text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.open_shift(
      uuid, uuid, uuid, date, text, text
    ) from public;
  grant execute on function
    catchmenu_store.open_shift(
      uuid, uuid, uuid, date, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.close_shift(
      uuid, uuid, uuid, int, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.close_shift(
      uuid, uuid, uuid, int, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_staff_schedule_week(
      uuid, uuid, date, uuid
    ) from public;
  grant execute on function
    catchmenu_store.get_staff_schedule_week(
      uuid, uuid, date, uuid
    ) to authenticated;

  revoke all on function
    catchmenu_store.calculate_work_hours(
      uuid, uuid, uuid, date, date, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.calculate_work_hours(
      uuid, uuid, uuid, date, date, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_pay_basis_summary(
      uuid, uuid, date, date
    ) from public;
  grant execute on function
    catchmenu_store.get_pay_basis_summary(
      uuid, uuid, date, date
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.create_staff_schedule(
    uuid, uuid, uuid, date, jsonb,
    text, uuid, text, text
  ) is
  '주간 그리드 스케줄 생성.
   schedule_grid: 요일별 출퇴근 시간 설정.
   planned_hours: 그리드 기반 자동 계산.
   staff_shifts 자동 생성 (요일별).
   특허4: 직원 스케줄 = 운영 원장 연동.
   2차 yoonsul_os 인력관리 앱 핵심 기능.';

comment on function
  catchmenu_store.calculate_work_hours(
    uuid, uuid, uuid, date, date, text, uuid, text
  ) is
  '근무시간 집계 + 급여 산정 기초 계산.
   base_pay = actual_hours × hourly_rate.
   overtime_pay = overtime_hours × hourly_rate × 1.5.
   한국 근로기준법 기준 초과근무 1.5배 적용.
   hourly_rate: 계산 시점 스냅샷 (변경 불가).
   pay_status CONFIRMED 후 수정 금지.
   특허4: 급여 산정 = append-only 증빙 원장.';