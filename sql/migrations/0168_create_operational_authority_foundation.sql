-- 0168_create_operational_authority_foundation.sql
-- Workpacket 601500 / Stage 8
-- Additive DDL only. No RPC rewrites, data promotion, grants, or RLS policies.

create table if not exists catchmenu_hq.legal_entities (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  legal_name text not null,
  business_registration_number text,
  brn_normalized text generated always as (
    nullif(
      regexp_replace(
        coalesce(business_registration_number, ''),
        '[^0-9]',
        '',
        'g'
      ),
      ''
    )
  ) stored,
  corporate_registration_number text,
  crn_normalized text generated always as (
    nullif(
      regexp_replace(
        coalesce(corporate_registration_number, ''),
        '[^0-9]',
        '',
        'g'
      ),
      ''
    )
  ) stored,
  tax_id text,
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_legal_entities_entity_type check (
    entity_type in (
      'SOLE_PROPRIETOR',
      'CORPORATION',
      'PARTNERSHIP',
      'NON_PROFIT'
    )
  ),
  constraint chk_legal_entities_status check (
    status in ('ACTIVE', 'SUSPENDED', 'CLOSED')
  ),
  constraint chk_legal_entities_crn_not_for_sole check (
    entity_type <> 'SOLE_PROPRIETOR'
    or corporate_registration_number is null
  )
);

create unique index if not exists uq_legal_entities_brn_normalized
  on catchmenu_hq.legal_entities (brn_normalized)
  where brn_normalized is not null;

create unique index if not exists uq_legal_entities_crn_normalized
  on catchmenu_hq.legal_entities (crn_normalized)
  where crn_normalized is not null;

create table if not exists catchmenu_hq.owners (
  id uuid primary key default gen_random_uuid(),
  owner_name text not null,
  contact_phone_hash text,
  contact_email text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists catchmenu_hq.legal_entity_person_roles (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null
    references catchmenu_hq.legal_entities(id),
  owner_id uuid not null
    references catchmenu_hq.owners(id),
  role_type text not null,
  ownership_percent numeric(5,2),
  effective_from date not null default current_date,
  effective_to date,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_lepr_role_type check (
    role_type in (
      'OWNER',
      'REPRESENTATIVE',
      'DIRECTOR',
      'EXECUTIVE',
      'INVESTOR'
    )
  ),
  constraint chk_lepr_ownership_percent check (
    ownership_percent is null
    or (ownership_percent >= 0 and ownership_percent <= 100)
  ),
  constraint chk_lepr_effective_range check (
    effective_to is null or effective_to >= effective_from
  )
);

create unique index if not exists uq_lepr_active
  on catchmenu_hq.legal_entity_person_roles (
    legal_entity_id,
    owner_id,
    role_type
  )
  where is_active = true;

create index if not exists idx_lepr_owner
  on catchmenu_hq.legal_entity_person_roles (owner_id)
  where is_active = true;

create index if not exists idx_lepr_legal_entity
  on catchmenu_hq.legal_entity_person_roles (legal_entity_id)
  where is_active = true;

create table if not exists catchmenu_hq.legal_entity_representatives (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null
    references catchmenu_hq.legal_entities(id),
  owner_id uuid not null
    references catchmenu_hq.owners(id),
  representation_mode text not null,
  effective_from date not null default current_date,
  effective_to date,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_ler_representation_mode check (
    representation_mode in ('SOLE', 'JOINT', 'INDIVIDUAL')
  ),
  constraint chk_ler_effective_range check (
    effective_to is null or effective_to >= effective_from
  )
);

create unique index if not exists uq_ler_active
  on catchmenu_hq.legal_entity_representatives (
    legal_entity_id,
    owner_id
  )
  where is_active = true;

create index if not exists idx_ler_legal_entity
  on catchmenu_hq.legal_entity_representatives (legal_entity_id)
  where is_active = true;

-- Add columns before constraints, per the controlled pipeline ordering rule.
alter table catchmenu_hq.tenants
  add column if not exists tenant_status text not null default 'TRIAL';

alter table catchmenu_hq.tenants
  add column if not exists isolation_state text not null default 'NONE';

alter table catchmenu_hq.stores
  add column if not exists legal_entity_id uuid;

do $ddl$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'catchmenu_hq.tenants'::regclass
      and conname = 'chk_tenants_status'
  ) then
    alter table catchmenu_hq.tenants
      add constraint chk_tenants_status check (
        tenant_status in (
          'ACTIVE',
          'TRIAL',
          'SUSPENDED',
          'CANCELLED',
          'TERMINATED'
        )
      );
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'catchmenu_hq.tenants'::regclass
      and conname = 'chk_tenants_isolation_state'
  ) then
    alter table catchmenu_hq.tenants
      add constraint chk_tenants_isolation_state check (
        isolation_state in ('NONE', 'ISOLATED')
      );
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'catchmenu_hq.stores'::regclass
      and conname = 'fk_stores_legal_entity_id'
  ) then
    alter table catchmenu_hq.stores
      add constraint fk_stores_legal_entity_id
      foreign key (legal_entity_id)
      references catchmenu_hq.legal_entities(id);
  end if;
end
$ddl$;

create index if not exists idx_stores_legal_entity_id
  on catchmenu_hq.stores (legal_entity_id)
  where legal_entity_id is not null;

alter table catchmenu_hq.owners
  enable row level security;
alter table catchmenu_hq.owners
  force row level security;
alter table catchmenu_hq.legal_entities
  enable row level security;
alter table catchmenu_hq.legal_entities
  force row level security;
alter table catchmenu_hq.legal_entity_person_roles
  enable row level security;
alter table catchmenu_hq.legal_entity_person_roles
  force row level security;
alter table catchmenu_hq.legal_entity_representatives
  enable row level security;
alter table catchmenu_hq.legal_entity_representatives
  force row level security;

drop trigger if exists trg_owners_updated_at
  on catchmenu_hq.owners;
create trigger trg_owners_updated_at
  before update on catchmenu_hq.owners
  for each row execute function catchmenu_common.set_updated_at();

drop trigger if exists trg_legal_entities_updated_at
  on catchmenu_hq.legal_entities;
create trigger trg_legal_entities_updated_at
  before update on catchmenu_hq.legal_entities
  for each row execute function catchmenu_common.set_updated_at();

drop trigger if exists trg_lepr_updated_at
  on catchmenu_hq.legal_entity_person_roles;
create trigger trg_lepr_updated_at
  before update on catchmenu_hq.legal_entity_person_roles
  for each row execute function catchmenu_common.set_updated_at();

drop trigger if exists trg_ler_updated_at
  on catchmenu_hq.legal_entity_representatives;
create trigger trg_ler_updated_at
  before update on catchmenu_hq.legal_entity_representatives
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_hq.owners is
  'People who hold operational or legal authority for legal entities.';
comment on table catchmenu_hq.legal_entities is
  'Legal operating entities associated with stores.';
comment on table catchmenu_hq.legal_entity_person_roles is
  'Time-bounded roles held by owners in legal entities.';
comment on table catchmenu_hq.legal_entity_representatives is
  'Single source of truth for legal representation authority.';
comment on column catchmenu_hq.tenants.tenant_status is
  'Subscription lifecycle state; independent of security isolation.';
comment on column catchmenu_hq.tenants.isolation_state is
  'Security isolation state; independent of subscription lifecycle.';
comment on column catchmenu_hq.stores.legal_entity_id is
  'Nullable legal operating entity reference; backfill occurs separately.';
