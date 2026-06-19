-- 0005_create_ledger_task.sql
-- Purpose: Task ledger. Records all operational work units that must be performed.
--          Task is the "what needs to be done" layer.
--          특허4 core: Task/Event/Audit/Exception 4-ledger architecture.
-- Depends on: 0003_create_store_device_agent_registry.sql
-- Creates:
--   catchmenu_ledger.tasks

create table if not exists catchmenu_ledger.tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- task identity
  task_code text not null,
  task_domain text not null,
  task_type text not null,
  task_status text not null default 'PENDING',
  priority int not null default 5,

  -- what this task is about
  subject_type text,
  subject_id uuid,

  -- who/what initiated
  initiated_by_type text not null default 'SYSTEM',
  initiated_by_id uuid,
  initiated_by_device_id uuid references catchmenu_store.device_registry(id),
  initiated_by_agent_id uuid references catchmenu_store.agent_registry(id),

  -- task payload
  task_payload jsonb not null default '{}'::jsonb,

  -- timing
  scheduled_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  failed_at timestamptz,
  deadline_at timestamptz,

  -- result
  result_payload jsonb,
  failure_reason text,
  retry_count int not null default 0,
  max_retry int not null default 3,

  -- correlation
  parent_task_id uuid references catchmenu_ledger.tasks(id),
  correlation_id text,
  idempotency_key text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),

  constraint chk_task_domain check (
    task_domain in (
      'order',
      'payment',
      'kds',
      'session',
      'delivery',
      'inventory',
      'staff',
      'device',
      'agent',
      'recovery',
      'sync',
      'knowledge',
      'system'
    )
  ),
  constraint chk_task_status check (
    task_status in (
      'PENDING',
      'SCHEDULED',
      'IN_PROGRESS',
      'COMPLETED',
      'FAILED',
      'CANCELLED',
      'DELEGATED',
      'AWAITING_APPROVAL'
    )
  ),
  constraint chk_task_initiated_by_type check (
    initiated_by_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER'
    )
  ),
  constraint chk_task_payload_object check (
    jsonb_typeof(task_payload) = 'object'
  ),
  constraint chk_task_result_object check (
    result_payload is null
    or jsonb_typeof(result_payload) = 'object'
  ),
  constraint chk_task_priority check (priority between 1 and 10),
  constraint chk_task_retry check (retry_count >= 0)
);

create index if not exists idx_tasks_store_domain_status
  on catchmenu_ledger.tasks(store_id, task_domain, task_status);

create index if not exists idx_tasks_store_business_day
  on catchmenu_ledger.tasks(store_id, business_day desc);

create index if not exists idx_tasks_subject
  on catchmenu_ledger.tasks(subject_type, subject_id)
  where subject_id is not null;

create index if not exists idx_tasks_parent
  on catchmenu_ledger.tasks(parent_task_id)
  where parent_task_id is not null;

create index if not exists idx_tasks_correlation
  on catchmenu_ledger.tasks(correlation_id)
  where correlation_id is not null;

create index if not exists idx_tasks_deadline
  on catchmenu_ledger.tasks(deadline_at)
  where deadline_at is not null
    and task_status in ('PENDING', 'SCHEDULED', 'IN_PROGRESS');

comment on table catchmenu_ledger.tasks is
  'Task ledger. Append-only record of all operational work units.
   A Task is a discrete unit of work that must be performed:
   order intake, KDS transmission, cooking start, packaging,
   customer notification, delivery handoff, recovery, sync, etc.
   Task status tracks the lifecycle of each work unit.
   Tasks are never updated in place after creation except status fields.
   특허4: Task is the actionable work layer of the 4-ledger architecture.';
comment on column catchmenu_ledger.tasks.task_status is
  'PENDING = created, not yet started.
   SCHEDULED = will start at scheduled_at.
   IN_PROGRESS = currently being processed.
   COMPLETED = finished successfully.
   FAILED = failed, retry_count tracks attempts.
   CANCELLED = cancelled before completion.
   DELEGATED = handed off to secondary agent or manual process.
   AWAITING_APPROVAL = requires human approval before proceeding.';
comment on column catchmenu_ledger.tasks.priority is
  '1 = highest, 10 = lowest. Default 5 = normal.
   Payment and KDS release tasks default to priority 1.';
comment on column catchmenu_ledger.tasks.subject_type is
  'What this task operates on: order, session, kds_ticket, payment, device, etc.';
comment on column catchmenu_ledger.tasks.parent_task_id is
  'Links subtasks to parent task for complex multi-step operations.
   e.g. order_intake task spawns kds_transmit and payment_request subtasks.';
comment on column catchmenu_ledger.tasks.business_day is
  'Local business date at task creation time.
   Used for daily reporting and shift-based task aggregation.';