-- 0003_create_store_device_agent_registry.sql
-- Purpose: Register physical devices and software agents per store.
--          Devices are the hardware layer. Agents are the software layer.
-- Depends on: 0002_create_hq_tenant_store.sql
-- Creates:
--   catchmenu_store.device_registry
--   catchmenu_store.agent_registry

create table if not exists catchmenu_store.device_registry (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  device_code text not null,
  device_name text,
  device_type text not null,
  device_role text not null default 'PRIMARY',

  -- hardware info
  os_type text,
  os_version text,
  app_version text,
  ip_address text,
  mac_address text,

  -- trust state
  trust_level text not null default 'UNTRUSTED',
  last_seen_at timestamptz,
  last_heartbeat_at timestamptz,
  registered_at timestamptz not null default now(),

  device_status text not null default 'OFFLINE',
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_device_store_code unique (store_id, device_code),
  constraint chk_device_type check (
    device_type in (
      'POS',
      'KDS',
      'KIOSK',
      'DID',
      'CMS',
      'TABLET',
      'AGENT_SERVER',
      'PRINTER',
      'PAYMENT_TERMINAL',
      'SENSOR',
      'ROBOT',
      'OTHER'
    )
  ),
  constraint chk_device_role check (
    device_role in (
      'PRIMARY',
      'SECONDARY',
      'BACKUP',
      'READONLY'
    )
  ),
  constraint chk_device_trust check (
    trust_level in (
      'UNTRUSTED',
      'PENDING',
      'TRUSTED',
      'SUSPENDED',
      'REVOKED'
    )
  ),
  constraint chk_device_status check (
    device_status in (
      'ONLINE',
      'OFFLINE',
      'DEGRADED',
      'MAINTENANCE',
      'FAILED'
    )
  )
);

create index if not exists idx_device_registry_store
  on catchmenu_store.device_registry(store_id);

create index if not exists idx_device_registry_store_type
  on catchmenu_store.device_registry(store_id, device_type)
  where is_active = true;

drop trigger if exists trg_device_registry_updated_at
  on catchmenu_store.device_registry;
create trigger trg_device_registry_updated_at
  before update on catchmenu_store.device_registry
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_store.device_registry is
  'Physical device registry per store.
   All devices (POS, KDS, Kiosk, DID, payment terminal, sensor, robot)
   must be registered before receiving or sending operational events.
   Trust level controls what operations a device is allowed to initiate.';
comment on column catchmenu_store.device_registry.trust_level is
  'UNTRUSTED = just registered, not yet verified.
   PENDING = verification in progress.
   TRUSTED = verified and allowed to operate.
   SUSPENDED = temporarily blocked.
   REVOKED = permanently blocked. Must re-register to restore.';
comment on column catchmenu_store.device_registry.device_role is
  'PRIMARY = main operational device for this type.
   SECONDARY = failover device.
   BACKUP = emergency backup only.
   READONLY = display or monitoring only.';


create table if not exists catchmenu_store.agent_registry (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  device_id uuid references catchmenu_store.device_registry(id),

  agent_code text not null,
  agent_name text,
  agent_type text not null,
  agent_role text not null default 'PRIMARY',

  -- runtime info
  runtime_version text,
  agent_status text not null default 'OFFLINE',
  last_heartbeat_at timestamptz,
  last_action_at timestamptz,
  registered_at timestamptz not null default now(),

  -- capability flags
  can_observe boolean not null default true,
  can_recommend boolean not null default true,
  can_execute boolean not null default false,
  can_recover boolean not null default false,
  can_audit boolean not null default true,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_agent_store_code unique (store_id, agent_code),
  constraint chk_agent_type check (
    agent_type in (
      'FAULT_DETECTION',
      'RESOURCE_AVAILABILITY',
      'KDS_CAPACITY',
      'SOP_SELECTION',
      'RECOMMENDATION',
      'RECOVERY',
      'SYNC',
      'AUDIT',
      'KNOWLEDGE_GAP',
      'SOP_EVOLUTION',
      'GOVERNANCE',
      'PHYSICAL_AI_INTERFACE',
      'SUPERVISOR',
      'GENERAL'
    )
  ),
  constraint chk_agent_role check (
    agent_role in ('PRIMARY', 'SECONDARY', 'BACKUP')
  ),
  constraint chk_agent_status check (
    agent_status in (
      'ONLINE',
      'OFFLINE',
      'DEGRADED',
      'ISOLATED',
      'FAILED'
    )
  )
);

create index if not exists idx_agent_registry_store
  on catchmenu_store.agent_registry(store_id);

create index if not exists idx_agent_registry_store_type
  on catchmenu_store.agent_registry(store_id, agent_type)
  where is_active = true;

drop trigger if exists trg_agent_registry_updated_at
  on catchmenu_store.agent_registry;
create trigger trg_agent_registry_updated_at
  before update on catchmenu_store.agent_registry
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_store.agent_registry is
  'Software agent registry per store.
   Agents are lightweight functional modules that observe, classify,
   recommend, recover, and audit operational events.
   Agents do NOT execute business mutations without explicit human approval.
   특허4 principle: observation != change, recommendation != execution.';
comment on column catchmenu_store.agent_registry.can_execute is
  'False by default. Agents observe and recommend only.
   Execution requires explicit human approval recorded in agent_approvals.';
comment on column catchmenu_store.agent_registry.can_recover is
  'True only for Recovery Agent and Sync Agent.
   Even then, recovery actions are logged as audit events.';
comment on column catchmenu_store.agent_registry.agent_type is
  'FAULT_DETECTION = detects device/network/service failures.
   RESOURCE_AVAILABILITY = checks KDS capacity, staff, kitchen load.
   KDS_CAPACITY = 특허2 KDS Late Binding capacity judge.
   SOP_SELECTION = selects operational SOP for current situation.
   RECOMMENDATION = generates action candidates for human approval.
   RECOVERY = executes approved recovery procedures.
   SYNC = synchronizes local ledger with central ledger after outage.
   AUDIT = records operational evidence and audit trail.
   KNOWLEDGE_GAP = detects missing SOP or policy gaps. 특허3.
   SOP_EVOLUTION = generates draft SOP from accumulated events. 특허3.
   GOVERNANCE = validates document rules before SOP publication. 특허3.
   PHYSICAL_AI_INTERFACE = translates decisions to physical device commands.
   SUPERVISOR = monitors all agent modules, isolates failed modules.';