-- 0126_create_staff_notification_pipeline.sql
-- Purpose: Staff notification and task feed.
--          직원 업무 피드 + 알림 관리.
--          역할별 알림 필터링.
--          업무 지시/확인 파이프라인.
--          직원 간 메모 전달.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0125_create_franchise_os_extension.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('staff_task_assigned', 'ko',
  '새 업무가 배정되었습니다: {task_title}'),
('staff_task_assigned', 'en',
  'New task assigned: {task_title}'),
('staff_task_completed', 'ko',
  '업무가 완료되었습니다'),
('staff_task_completed', 'en',
  'Task completed'),
('staff_memo_sent', 'ko',
  '메모가 전달되었습니다'),
('staff_memo_sent', 'en',
  'Memo sent'),
('staff_feed_loaded', 'ko',
  '업무 피드가 로드되었습니다'),
('staff_feed_loaded', 'en',
  'Staff feed loaded'),
('shift_started', 'ko',
  '출근 처리되었습니다'),
('shift_started', 'en',
  'Shift started'),
('shift_ended', 'ko',
  '퇴근 처리되었습니다'),
('shift_ended', 'en',
  'Shift ended')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7090, 'staff_task_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7091, 'shift_already_started',
  'STORE', 'CONFLICT', 409, 'INFO'),
(7092, 'shift_not_started',
  'STORE', 'BUSINESS_RULE', 409, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- staff_tasks table
-- 직원 업무 지시
-- =============================================
create table if not exists
  catchmenu_store.staff_tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 업무 정보
  task_title text not null,
  task_body text,
  task_type text not null default 'GENERAL',
  task_priority text not null default 'NORMAL',

  -- 대상
  assigned_to uuid
    references catchmenu_store.staff(id),
  assigned_role text,
  assigned_by uuid
    references catchmenu_store.staff(id),

  -- 상태
  task_status text not null default 'OPEN',
  due_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  completion_note text,

  -- 반복
  is_recurring boolean not null default false,
  recurrence_pattern text,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_task_type check (
    task_type in (
      'GENERAL',       -- 일반 업무
      'CLEANING',      -- 청소
      'INVENTORY',     -- 재고 확인
      'OPENING',       -- 오픈 준비
      'CLOSING',       -- 마감
      'CUSTOMER',      -- 고객 대응
      'MAINTENANCE',   -- 시설 점검
      'TRAINING'       -- 교육
    )
  ),
  constraint chk_task_priority check (
    task_priority in (
      'LOW', 'NORMAL', 'HIGH', 'URGENT'
    )
  ),
  constraint chk_task_status check (
    task_status in (
      'OPEN', 'IN_PROGRESS',
      'COMPLETED', 'CANCELLED', 'OVERDUE'
    )
  )
);

create index if not exists idx_staff_tasks
  on catchmenu_store.staff_tasks(
    store_id, task_status, due_at
  ) where task_status in (
    'OPEN', 'IN_PROGRESS'
  );

alter table catchmenu_store.staff_tasks
  enable row level security;
alter table catchmenu_store.staff_tasks
  force row level security;

drop policy if exists staff_tasks_isolation
  on catchmenu_store.staff_tasks;
create policy staff_tasks_isolation
  on catchmenu_store.staff_tasks
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_staff_tasks_updated
  on catchmenu_store.staff_tasks;
create trigger trg_staff_tasks_updated
  before update on catchmenu_store.staff_tasks
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.staff_tasks is
  '직원 업무 지시.
   OPENING/CLOSING: 오픈/마감 체크리스트 연동.
   is_recurring: 매일 반복 업무.
   assigned_role: 역할 전체에 배정.
   URGENT: 즉시 Realtime 알림.
   OVERDUE: pg_cron 자동 처리.';


-- =============================================
-- staff_memos table
-- 직원 간 메모 전달
-- =============================================
create table if not exists
  catchmenu_store.staff_memos (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 메모 정보
  memo_text text not null,
  memo_type text not null default 'GENERAL',

  -- 발신/수신
  from_staff_id uuid
    references catchmenu_store.staff(id),
  to_staff_id uuid
    references catchmenu_store.staff(id),
  to_role text,
  to_all boolean not null default false,

  -- 상태
  is_read boolean not null default false,
  read_at timestamptz,

  -- 연결
  related_order_id uuid,
  related_table_number text,

  business_day date,
  created_at timestamptz not null default now(),

  constraint chk_memo_type check (
    memo_type in (
      'GENERAL',
      'ORDER_NOTE',    -- 주문 관련
      'CUSTOMER_NOTE', -- 고객 특이사항
      'SHIFT_HANDOFF', -- 교대 인수인계
      'URGENT'         -- 긴급
    )
  )
);

create index if not exists idx_staff_memos
  on catchmenu_store.staff_memos(
    store_id, to_staff_id,
    is_read, created_at desc
  );

alter table catchmenu_store.staff_memos
  enable row level security;
alter table catchmenu_store.staff_memos
  force row level security;

drop policy if exists staff_memos_isolation
  on catchmenu_store.staff_memos;
create policy staff_memos_isolation
  on catchmenu_store.staff_memos
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table catchmenu_store.staff_memos is
  '직원 간 메모 전달.
   SHIFT_HANDOFF: 교대 인수인계 필수.
   to_all=true: 전 직원 공지.
   URGENT: 즉시 Realtime 알림.
   related_order_id: 주문 관련 메모 연결.
   is_read: 읽음 확인 추적.';


-- =============================================
-- staff_shifts table
-- 직원 출퇴근 기록
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

  -- 근무 정보
  shift_date date not null,
  shift_type text not null default 'REGULAR',

  -- 시간
  scheduled_start timestamptz,
  scheduled_end timestamptz,
  actual_start timestamptz,
  actual_end timestamptz,

  -- 계산
  work_minutes int,
  break_minutes int not null default 0,
  net_work_minutes int,

  -- 상태
  shift_status text not null default 'SCHEDULED',

  -- 비고
  memo text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_staff_shift unique (
    staff_id, shift_date, shift_type
  ),
  constraint chk_shift_type check (
    shift_type in (
      'REGULAR', 'OVERTIME',
      'PART_TIME', 'SUBSTITUTE'
    )
  ),
  constraint chk_shift_status check (
    shift_status in (
      'SCHEDULED', 'STARTED',
      'COMPLETED', 'ABSENT', 'LATE'
    )
  )
);

create index if not exists idx_staff_shifts
  on catchmenu_store.staff_shifts(
    store_id, shift_date desc
  );

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
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_staff_shifts_updated
  on catchmenu_store.staff_shifts;
create trigger trg_staff_shifts_updated
  before update on catchmenu_store.staff_shifts
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.staff_shifts is
  '직원 출퇴근 기록.
   actual_start/end: 실제 출퇴근 시간.
   net_work_minutes: 실 근무 시간.
   LATE: 지각 자동 처리.
   yoonsul_os 노무 관리와 연동 예정.
   캐치메뉴: 운영 참고용 기록만.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.assign_staff_task(
  p_tenant_id uuid,
  p_store_id uuid,
  p_task_title text,
  p_task_type text default 'GENERAL',
  p_task_priority text default 'NORMAL',
  p_task_body text default null,
  p_assigned_to uuid default null,
  p_assigned_role text default null,
  p_assigned_by uuid default null,
  p_due_at timestamptz default null,
  p_is_recurring boolean default false,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_task_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  insert into catchmenu_store.staff_tasks (
    tenant_id, store_id,
    task_title, task_body,
    task_type, task_priority,
    assigned_to, assigned_role,
    assigned_by, due_at,
    is_recurring, business_day,
    task_status
  ) values (
    p_tenant_id, p_store_id,
    p_task_title, p_task_body,
    p_task_type, p_task_priority,
    p_assigned_to, p_assigned_role,
    p_assigned_by, p_due_at,
    p_is_recurring, v_business_day,
    'OPEN'
  )
  returning id into v_task_id;

  -- 직원 앱 Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'staff_task_assigned',
    p_payload := jsonb_build_object(
      'task_id', v_task_id,
      'task_title', p_task_title,
      'task_type', p_task_type,
      'task_priority', p_task_priority,
      'assigned_to', p_assigned_to,
      'assigned_role', p_assigned_role,
      'due_at', p_due_at,
      'is_urgent',
        p_task_priority = 'URGENT',
      'message',
        catchmenu_common.get_message(
          'staff_task_assigned', p_locale,
          jsonb_build_object(
            'task_title', p_task_title
          )
        )
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_task_assigned',
    p_data := jsonb_build_object(
      'task_id', v_task_id,
      'task_title', p_task_title,
      'task_type', p_task_type,
      'task_priority', p_task_priority,
      'assigned_to', p_assigned_to,
      'assigned_role', p_assigned_role,
      'due_at', p_due_at
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'task_title', p_task_title
    )
  );
end;
$$;


create or replace function
  catchmenu_store.complete_staff_task(
  p_tenant_id uuid,
  p_store_id uuid,
  p_task_id uuid,
  p_actor_id uuid,
  p_completion_note text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_task record;
begin
  select id, task_title, task_type,
         task_status, assigned_by,
         is_recurring
  into v_task
  from catchmenu_store.staff_tasks
  where id = p_task_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_task.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_task_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'complete_staff_task'
    );
  end if;

  update catchmenu_store.staff_tasks
  set
    task_status = 'COMPLETED',
    completed_at = now(),
    completion_note = p_completion_note,
    updated_at = now()
  where id = p_task_id;

  -- 배정자에게 완료 알림
  if v_task.assigned_by is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'STAFF_ALERTS',
      p_event_type := 'staff_task_completed',
      p_payload := jsonb_build_object(
        'task_id', p_task_id,
        'task_title', v_task.task_title,
        'completed_by', p_actor_id,
        'completion_note', p_completion_note
      )
    );
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_task_completed',
    p_data := jsonb_build_object(
      'task_id', p_task_id,
      'task_title', v_task.task_title,
      'completed_at', now(),
      'completion_note', p_completion_note
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.send_staff_memo(
  p_tenant_id uuid,
  p_store_id uuid,
  p_from_staff_id uuid,
  p_memo_text text,
  p_memo_type text default 'GENERAL',
  p_to_staff_id uuid default null,
  p_to_role text default null,
  p_to_all boolean default false,
  p_related_order_id uuid default null,
  p_related_table_number text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_memo_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  insert into catchmenu_store.staff_memos (
    tenant_id, store_id,
    memo_text, memo_type,
    from_staff_id, to_staff_id,
    to_role, to_all,
    related_order_id,
    related_table_number,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    p_memo_text, p_memo_type,
    p_from_staff_id, p_to_staff_id,
    p_to_role, p_to_all,
    p_related_order_id,
    p_related_table_number,
    v_business_day
  )
  returning id into v_memo_id;

  -- Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'staff_memo_received',
    p_payload := jsonb_build_object(
      'memo_id', v_memo_id,
      'memo_type', p_memo_type,
      'memo_text', p_memo_text,
      'from_staff_id', p_from_staff_id,
      'to_staff_id', p_to_staff_id,
      'to_role', p_to_role,
      'to_all', p_to_all,
      'is_urgent',
        p_memo_type = 'URGENT',
      'related_order_id',
        p_related_order_id,
      'related_table_number',
        p_related_table_number
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_memo_sent',
    p_data := jsonb_build_object(
      'memo_id', v_memo_id,
      'memo_type', p_memo_type,
      'to_staff_id', p_to_staff_id,
      'to_role', p_to_role,
      'to_all', p_to_all
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.record_shift_start(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_shift_type text default 'REGULAR',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_shift_id uuid;
  v_shift_date date;
  v_existing record;
begin
  v_shift_date := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 이미 출근한 경우 확인
  select id, shift_status
  into v_existing
  from catchmenu_store.staff_shifts
  where staff_id = p_staff_id
    and shift_date = v_shift_date
    and shift_type = p_shift_type
    and shift_status in (
      'STARTED', 'SCHEDULED'
    );

  if v_existing.shift_status = 'STARTED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'shift_already_started',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'record_shift_start'
    );
  end if;

  if v_existing.id is not null then
    -- 예정된 시프트 업데이트
    update catchmenu_store.staff_shifts
    set
      actual_start = now(),
      shift_status = 'STARTED',
      updated_at = now()
    where id = v_existing.id;

    v_shift_id := v_existing.id;
  else
    -- 신규 시프트 생성
    insert into catchmenu_store.staff_shifts (
      tenant_id, store_id, staff_id,
      shift_date, shift_type,
      actual_start, shift_status
    ) values (
      p_tenant_id, p_store_id, p_staff_id,
      v_shift_date, p_shift_type,
      now(), 'STARTED'
    )
    returning id into v_shift_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'shift_started',
    p_data := jsonb_build_object(
      'shift_id', v_shift_id,
      'staff_id', p_staff_id,
      'shift_date', v_shift_date,
      'actual_start', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.record_shift_end(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_break_minutes int default 0,
  p_memo text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_shift record;
  v_work_minutes int;
  v_net_work_minutes int;
begin
  select id, actual_start, shift_status
  into v_shift
  from catchmenu_store.staff_shifts
  where staff_id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and shift_date = (timezone(
      'Asia/Seoul', now()
    ))::date
    and shift_status = 'STARTED'
  for update;

  if v_shift.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'shift_not_started',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'record_shift_end'
    );
  end if;

  v_work_minutes := extract(
    epoch from (now() - v_shift.actual_start)
  )::int / 60;

  v_net_work_minutes :=
    v_work_minutes - p_break_minutes;

  update catchmenu_store.staff_shifts
  set
    actual_end = now(),
    work_minutes = v_work_minutes,
    break_minutes = p_break_minutes,
    net_work_minutes = v_net_work_minutes,
    shift_status = 'COMPLETED',
    memo = p_memo,
    updated_at = now()
  where id = v_shift.id;

  return catchmenu_common.build_success_response(
    p_message_key := 'shift_ended',
    p_data := jsonb_build_object(
      'shift_id', v_shift.id,
      'staff_id', p_staff_id,
      'actual_start', v_shift.actual_start,
      'actual_end', now(),
      'work_minutes', v_work_minutes,
      'break_minutes', p_break_minutes,
      'net_work_minutes', v_net_work_minutes
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_staff_feed(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_staff_role text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_tasks jsonb;
  v_memos jsonb;
  v_alerts jsonb;
  v_shift record;
  v_business_day date;
  v_unread_memo_count int;
  v_open_task_count int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 내 업무 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'task_id', id,
        'task_title', task_title,
        'task_type', task_type,
        'task_priority', task_priority,
        'task_status', task_status,
        'due_at', due_at,
        'is_overdue',
          due_at < now()
          and task_status not in (
            'COMPLETED', 'CANCELLED'
          )
      )
      order by
        case task_priority
          when 'URGENT' then 0
          when 'HIGH' then 1
          when 'NORMAL' then 2
          else 3
        end,
        due_at asc nulls last
    ),
    '[]'::jsonb
  )
  into v_tasks
  from catchmenu_store.staff_tasks
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and task_status in (
      'OPEN', 'IN_PROGRESS', 'OVERDUE'
    )
    and business_day = v_business_day
    and (
      assigned_to = p_staff_id
      or (
        assigned_role is not null
        and p_staff_role is not null
        and assigned_role = p_staff_role
      )
      or (
        assigned_to is null
        and assigned_role is null
      )
    );

  -- 읽지 않은 메모
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'memo_id', id,
        'memo_text', memo_text,
        'memo_type', memo_type,
        'from_staff_id', from_staff_id,
        'is_read', is_read,
        'related_order_id', related_order_id,
        'related_table_number',
          related_table_number,
        'created_at', created_at
      )
      order by created_at desc
    ),
    '[]'::jsonb
  )
  into v_memos
  from catchmenu_store.staff_memos
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and (
      to_staff_id = p_staff_id
      or to_all = true
      or (
        to_role is not null
        and p_staff_role is not null
        and to_role = p_staff_role
      )
    )
  limit 20;

  -- 오늘 운영 알림 (상위 5개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'alert_id', id,
        'alert_type', alert_type,
        'alert_severity', alert_severity,
        'alert_domain', alert_domain,
        'alert_detail', alert_detail,
        'created_at', created_at
      )
      order by
        case alert_severity
          when 'CRITICAL' then 0
          when 'ERROR' then 1
          when 'WARNING' then 2
          else 3
        end,
        created_at desc
    ),
    '[]'::jsonb
  )
  into v_alerts
  from catchmenu_common.operation_alerts
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and alert_status in ('OPEN', 'ACKNOWLEDGED')
    and created_at::date = v_business_day
  limit 5;

  -- 오늘 시프트
  select id, actual_start, shift_status
  into v_shift
  from catchmenu_store.staff_shifts
  where staff_id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and shift_date = v_business_day;

  -- 카운트
  select count(*) into v_unread_memo_count
  from catchmenu_store.staff_memos
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and is_read = false
    and (
      to_staff_id = p_staff_id
      or to_all = true
    );

  select count(*) into v_open_task_count
  from catchmenu_store.staff_tasks
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and task_status in (
      'OPEN', 'IN_PROGRESS', 'OVERDUE'
    )
    and (
      assigned_to = p_staff_id
      or assigned_to is null
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_feed_loaded',
    p_data := jsonb_build_object(
      'staff_id', p_staff_id,
      'business_day', v_business_day,
      'shift', case
        when v_shift.id is not null
        then jsonb_build_object(
          'shift_id', v_shift.id,
          'shift_status', v_shift.shift_status,
          'actual_start', v_shift.actual_start
        )
        else null
      end,
      'tasks', v_tasks,
      'open_task_count', v_open_task_count,
      'memos', v_memos,
      'unread_memo_count', v_unread_memo_count,
      'alerts', v_alerts,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron: 업무 지연 자동 처리
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_active
) values
(
  'STAFF_TASK_OVERDUE',
  'catchmenu_staff_task_overdue',
  '*/30 * * * *',
  '*/30 * * * * (30분마다)',
  $sql$
UPDATE catchmenu_store.staff_tasks
SET
  task_status = 'OVERDUE',
  updated_at = now()
WHERE task_status IN ('OPEN', 'IN_PROGRESS')
  AND due_at IS NOT NULL
  AND due_at < now();
$sql$,
  '기한 초과 업무 자동 OVERDUE. 30분마다.',
  true
),
(
  'DAILY_TASK_GENERATE',
  'catchmenu_daily_task_generate',
  '30 21 * * *',
  '30 6 * * * (매일 06:30 KST)',
  $sql$
-- 반복 업무 매일 생성
INSERT INTO catchmenu_store.staff_tasks (
  tenant_id, store_id,
  task_title, task_body,
  task_type, task_priority,
  assigned_role, is_recurring,
  business_day, task_status
)
SELECT
  tenant_id, store_id,
  task_title, task_body,
  task_type, task_priority,
  assigned_role, true,
  (timezone('Asia/Seoul', now()))::date,
  'OPEN'
FROM catchmenu_store.staff_tasks
WHERE is_recurring = true
  AND business_day
    = (timezone('Asia/Seoul', now()))::date - 1
  AND task_status = 'COMPLETED'
ON CONFLICT DO NOTHING;
$sql$,
  '반복 업무 매일 자동 생성. 06:30 KST.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.assign_staff_task(
      uuid, uuid, text, text, text, text,
      uuid, text, uuid, timestamptz,
      boolean, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.complete_staff_task(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.send_staff_memo(
      uuid, uuid, uuid, text, text,
      uuid, text, boolean, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.record_shift_start(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.record_shift_end(
      uuid, uuid, uuid, int, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_staff_feed(
      uuid, uuid, uuid, text, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.get_staff_feed(
    uuid, uuid, uuid, text, text
  ) is
  '직원 업무 피드 단일 RPC.
   직원 앱 홈 화면 메인 데이터.

   포함 데이터:
   - 오늘 시프트 상태 (출근 여부)
   - 내 업무 목록 (우선순위 정렬)
   - 읽지 않은 메모
   - 오늘 운영 알림 (상위 5개)
   - 미완료 업무 수 / 미읽 메모 수

   업무 필터:
   - assigned_to = 내 ID
   - assigned_role = 내 역할
   - 전체 배정 (null)

   메모 필터:
   - to_staff_id = 내 ID
   - to_all = true
   - to_role = 내 역할

   교대 인수인계:
   send_staff_memo(type=SHIFT_HANDOFF)
   → 다음 교대 직원에게 전달.';