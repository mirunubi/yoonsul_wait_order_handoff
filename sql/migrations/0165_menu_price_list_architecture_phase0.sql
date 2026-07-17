-- 0165_menu_price_list_architecture_phase0.sql
-- Purpose: Phase 0 infrastructure for menu price-list architecture.
-- Background: introduce normalized price-list tables and the canonical resolver
--   without wiring any existing menu/order/payment consumer to the new model.
-- Human decision: implement Phase 0 only; Phase 1 backfill, Phase 2 parallel
--   operation, Phase 3 consumer cutover, and Phase 4 cleanup are explicitly
--   out of scope for this migration.
-- Depends on: 0164_waiting_pipeline_sibling_functions_correction.sql
-- Creates:
--   catchmenu_pos.price_lists
--   catchmenu_pos.price_list_assignments
--   catchmenu_pos.menu_prices
--   catchmenu_pos.option_item_prices
--   catchmenu_pos.resolve_menu_price()
-- Non-goals:
--   - No backfill from catchmenu_pos.menus.price.
--   - No changes to existing consumers of menus.price.
--   - No authenticated grants on the 4 tables or resolver function.
--   - No fix for the known nullable-column uniqueness gap in assignments.

create table catchmenu_pos.price_lists (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  name text not null,
  currency text not null default 'KRW',
  valid_from timestamptz,
  valid_to timestamptz,
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_price_list_status check (status in ('ACTIVE', 'DRAFT', 'ARCHIVED')),
  constraint chk_price_list_valid_range check (
    valid_from is null or valid_to is null or valid_from <= valid_to
  )
);

create table catchmenu_pos.price_list_assignments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  price_list_id uuid not null references catchmenu_pos.price_lists(id),
  store_id uuid references catchmenu_hq.stores(id),
  sales_channel text,
  provider_id text,
  priority int not null default 0,
  created_at timestamptz not null default now()
);

create table catchmenu_pos.menu_prices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  price_list_id uuid not null references catchmenu_pos.price_lists(id),
  menu_id uuid not null references catchmenu_pos.menus(id),
  amount int not null,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_menu_price_amount check (amount >= 0),
  constraint chk_menu_price_range check (effective_to is null or effective_from <= effective_to)
);

create table catchmenu_pos.option_item_prices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  price_list_id uuid not null references catchmenu_pos.price_lists(id),
  option_item_id uuid not null references catchmenu_pos.menu_option_items(id),
  price_delta int not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table catchmenu_pos.price_lists enable row level security;
alter table catchmenu_pos.price_lists force row level security;

create policy price_lists_tenant_isolation
  on catchmenu_pos.price_lists
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

alter table catchmenu_pos.price_list_assignments enable row level security;
alter table catchmenu_pos.price_list_assignments force row level security;

create policy price_list_assignments_store_isolation
  on catchmenu_pos.price_list_assignments
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and (store_id = catchmenu_common.current_store_id() or store_id is null)
  );

alter table catchmenu_pos.menu_prices enable row level security;
alter table catchmenu_pos.menu_prices force row level security;

create policy menu_prices_store_isolation
  on catchmenu_pos.menu_prices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and exists (
      select 1
      from catchmenu_pos.price_list_assignments pla
      where pla.price_list_id = menu_prices.price_list_id
        and pla.tenant_id = catchmenu_common.current_tenant_id()
        and (pla.store_id = catchmenu_common.current_store_id() or pla.store_id is null)
    )
  );

alter table catchmenu_pos.option_item_prices enable row level security;
alter table catchmenu_pos.option_item_prices force row level security;

create policy option_item_prices_store_isolation
  on catchmenu_pos.option_item_prices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and exists (
      select 1
      from catchmenu_pos.price_list_assignments pla
      where pla.price_list_id = option_item_prices.price_list_id
        and pla.tenant_id = catchmenu_common.current_tenant_id()
        and (pla.store_id = catchmenu_common.current_store_id() or pla.store_id is null)
    )
  );

create or replace function catchmenu_pos.resolve_menu_price(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid,
  p_sales_channel text default null,
  p_provider_id text default null,
  p_at timestamptz default now()
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos
as $$
declare
  v_amount int;
  v_price_list_id uuid;
begin
  -- 1) Store + provider-specific price.
  select mp.amount, mp.price_list_id
    into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp
    on mp.price_list_id = pla.price_list_id
   and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl
    on pl.id = mp.price_list_id
   and pl.status = 'ACTIVE'
   and (pl.valid_from is null or pl.valid_from <= p_at)
   and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id
    and pla.store_id = p_store_id
    and pla.sales_channel is not distinct from p_sales_channel
    and pla.provider_id = p_provider_id
    and p_provider_id is not null
    and mp.effective_from <= p_at
    and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;

  if found then
    return jsonb_build_object(
      'amount', v_amount,
      'price_list_id', v_price_list_id,
      'resolved_tier', 'STORE_PROVIDER',
      'resolved_at', p_at
    );
  end if;

  -- 2) Store + channel price, provider-agnostic.
  select mp.amount, mp.price_list_id
    into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp
    on mp.price_list_id = pla.price_list_id
   and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl
    on pl.id = mp.price_list_id
   and pl.status = 'ACTIVE'
   and (pl.valid_from is null or pl.valid_from <= p_at)
   and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id
    and pla.store_id = p_store_id
    and pla.sales_channel is not distinct from p_sales_channel
    and p_sales_channel is not null
    and pla.provider_id is null
    and mp.effective_from <= p_at
    and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;

  if found then
    return jsonb_build_object(
      'amount', v_amount,
      'price_list_id', v_price_list_id,
      'resolved_tier', 'STORE_CHANNEL',
      'resolved_at', p_at
    );
  end if;

  -- 3) Store default price.
  select mp.amount, mp.price_list_id
    into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp
    on mp.price_list_id = pla.price_list_id
   and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl
    on pl.id = mp.price_list_id
   and pl.status = 'ACTIVE'
   and (pl.valid_from is null or pl.valid_from <= p_at)
   and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id
    and pla.store_id = p_store_id
    and pla.sales_channel is null
    and pla.provider_id is null
    and mp.effective_from <= p_at
    and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;

  if found then
    return jsonb_build_object(
      'amount', v_amount,
      'price_list_id', v_price_list_id,
      'resolved_tier', 'STORE_DEFAULT',
      'resolved_at', p_at
    );
  end if;

  -- 4) Brand + channel price. Provider-specific brand rows must not match here.
  select mp.amount, mp.price_list_id
    into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp
    on mp.price_list_id = pla.price_list_id
   and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl
    on pl.id = mp.price_list_id
   and pl.status = 'ACTIVE'
   and (pl.valid_from is null or pl.valid_from <= p_at)
   and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id
    and pla.store_id is null
    and pla.sales_channel is not distinct from p_sales_channel
    and p_sales_channel is not null
    and pla.provider_id is null
    and mp.effective_from <= p_at
    and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;

  if found then
    return jsonb_build_object(
      'amount', v_amount,
      'price_list_id', v_price_list_id,
      'resolved_tier', 'BRAND_CHANNEL',
      'resolved_at', p_at
    );
  end if;

  -- 5) Brand default price.
  select mp.amount, mp.price_list_id
    into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp
    on mp.price_list_id = pla.price_list_id
   and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl
    on pl.id = mp.price_list_id
   and pl.status = 'ACTIVE'
   and (pl.valid_from is null or pl.valid_from <= p_at)
   and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id
    and pla.store_id is null
    and pla.sales_channel is null
    and pla.provider_id is null
    and mp.effective_from <= p_at
    and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;

  if found then
    return jsonb_build_object(
      'amount', v_amount,
      'price_list_id', v_price_list_id,
      'resolved_tier', 'BRAND_DEFAULT',
      'resolved_at', p_at
    );
  end if;

  -- 6) Menu base price fallback.
  select price
    into v_amount
  from catchmenu_pos.menus
  where id = p_menu_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and is_active = true;

  if not found then
    return jsonb_build_object(
      'amount', null,
      'price_list_id', null,
      'resolved_tier', 'NOT_FOUND',
      'resolved_at', p_at
    );
  end if;

  return jsonb_build_object(
    'amount', v_amount,
    'price_list_id', null,
    'resolved_tier', 'MENU_BASE',
    'resolved_at', p_at
  );
end;
$$;

revoke all on function catchmenu_pos.resolve_menu_price(
  uuid, uuid, uuid, text, text, timestamptz
) from public;
