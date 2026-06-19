-- 0054_create_inventory_rpc.sql
-- Purpose: Inventory management RPCs.
--          register_ingredient: registers ingredient/raw material.
--          record_inventory_movement: records stock in/out.
--          check_inventory_level: returns current stock levels.
--          auto_sold_out_by_inventory: triggers menu sold_out
--            when ingredient falls below threshold.
--          특허3 core: 재고 소진 → 메뉴 품절 자동 연동 → KDS 조건 변경.
-- Depends on: 0053_create_staff_management_rpc.sql
-- Creates:
--   catchmenu_store.ingredients (table)
--   catchmenu_store.inventory_movements (table)
--   function catchmenu_store.register_ingredient(...)
--   function catchmenu_store.record_inventory_movement(...)
--   function catchmenu_store.check_inventory_level(...)
--   function catchmenu_store.auto_sold_out_by_inventory(...)

-- =============================================
-- ingredients table
-- =============================================
create table if not exists catchmenu_store.ingredients (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- identity
  ingredient_code text not null,
  ingredient_name text not null,
  ingredient_category text,
  unit text not null default 'g',
  storage_type text not null default 'AMBIENT',

  -- stock levels
  current_quantity numeric(12,3) not null default 0,
  reserved_quantity numeric(12,3) not null default 0,
  available_quantity numeric(12,3)
    generated always as (
      current_quantity - reserved_quantity
    ) stored,

  -- thresholds
  min_quantity numeric(12,3) not null default 0,
  warning_quantity numeric(12,3) not null default 0,
  reorder_quantity numeric(12,3),

  -- linked menus for auto sold_out
  -- 특허3: 재고 소진 → 연동된 메뉴 자동 품절
  linked_menu_ids jsonb not null default '[]'::jsonb,

  -- cost
  unit_cost numeric(12,2),
  supplier_name text,
  supplier_code text,

  -- status
  ingredient_status text not null default 'ACTIVE',
  last_restocked_at timestamptz,
  last_checked_at timestamptz,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_ingredient_code unique (store_id, ingredient_code),
  constraint chk_storage_type check (
    storage_type in (
      'AMBIENT', 'REFRIGERATED', 'FROZEN', 'DRY'
    )
  ),
  constraint chk_ingredient_status check (
    ingredient_status in (
      'ACTIVE', 'LOW_STOCK', 'OUT_OF_STOCK',
      'DISCONTINUED'
    )
  ),
  constraint chk_quantity_positive check (
    current_quantity >= 0
    and reserved_quantity >= 0
    and min_quantity >= 0
  ),
  constraint chk_linked_menu_ids check (
    jsonb_typeof(linked_menu_ids) = 'array'
  )
);

create index if not exists idx_ingredients_store
  on catchmenu_store.ingredients(store_id);
create index if not exists idx_ingredients_status
  on catchmenu_store.ingredients(
    store_id, ingredient_status
  ) where is_active = true;
create index if not exists idx_ingredients_low_stock
  on catchmenu_store.ingredients(store_id)
  where ingredient_status in ('LOW_STOCK', 'OUT_OF_STOCK')
    and is_active = true;

alter table catchmenu_store.ingredients
  enable row level security;
alter table catchmenu_store.ingredients
  force row level security;

drop policy if exists ingredients_isolation
  on catchmenu_store.ingredients;
create policy ingredients_isolation
  on catchmenu_store.ingredients
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_ingredients_updated_at
  on catchmenu_store.ingredients;
create trigger trg_ingredients_updated_at
  before update on catchmenu_store.ingredients
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.ingredients is
  'Ingredient and raw material registry per store.
   linked_menu_ids: menus that use this ingredient.
   When available_quantity < min_quantity:
   → ingredient_status = OUT_OF_STOCK
   → auto_sold_out_by_inventory triggers linked menus.
   특허3: 재고 소진 이벤트 → 메뉴 품절 자동 연동
          → KDS conditions_met.menu_available = false.';


-- =============================================
-- inventory_movements table
-- =============================================
create table if not exists catchmenu_store.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  ingredient_id uuid not null
    references catchmenu_store.ingredients(id),

  -- movement
  movement_type text not null,
  quantity_change numeric(12,3) not null,
  quantity_before numeric(12,3) not null,
  quantity_after numeric(12,3) not null,
  unit text not null,

  -- reference
  reference_type text,
  reference_id uuid,
  order_id uuid,

  -- cost
  unit_cost numeric(12,2),
  total_cost numeric(14,2),

  -- metadata
  movement_note text,
  actor_type text not null default 'STAFF',
  actor_id uuid,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',
  occurred_at timestamptz not null default now(),

  created_at timestamptz not null default now(),

  constraint chk_movement_type check (
    movement_type in (
      'RESTOCK', 'USAGE', 'WASTE',
      'ADJUSTMENT', 'TRANSFER_IN', 'TRANSFER_OUT',
      'INITIAL_STOCK', 'INVENTORY_CHECK'
    )
  )
);

create index if not exists idx_movements_ingredient
  on catchmenu_store.inventory_movements(
    ingredient_id, occurred_at desc
  );
create index if not exists idx_movements_date
  on catchmenu_store.inventory_movements(
    store_id, business_day
  );

alter table catchmenu_store.inventory_movements
  enable row level security;
alter table catchmenu_store.inventory_movements
  force row level security;

drop policy if exists movements_isolation
  on catchmenu_store.inventory_movements;
create policy movements_isolation
  on catchmenu_store.inventory_movements
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

comment on table catchmenu_store.inventory_movements is
  'Append-only inventory movement ledger.
   Every stock change must record quantity_before/after.
   USAGE movements link to order_id for food cost analysis.
   특허4: 재고 원장 = append-only 이벤트 기반 추적.';


-- =============================================
-- RPCs
-- =============================================
create or replace function catchmenu_store.register_ingredient(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ingredient_code text,
  p_ingredient_name text,
  p_unit text,
  p_storage_type text default 'AMBIENT',
  p_ingredient_category text default null,
  p_min_quantity numeric default 0,
  p_warning_quantity numeric default 0,
  p_reorder_quantity numeric default null,
  p_unit_cost numeric default null,
  p_supplier_name text default null,
  p_linked_menu_ids jsonb default '[]'::jsonb,
  p_initial_quantity numeric default 0,
  p_actor_type text default 'STAFF',
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
  v_ingredient_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if trim(coalesce(p_ingredient_code, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ingredient_code_required'
    );
  end if;

  if p_storage_type not in (
    'AMBIENT', 'REFRIGERATED', 'FROZEN', 'DRY'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_storage_type'
    );
  end if;

  -- duplicate check
  if exists (
    select 1
    from catchmenu_store.ingredients
    where store_id = p_store_id
      and ingredient_code = p_ingredient_code
      and is_active = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ingredient_code_exists',
      'ingredient_code', p_ingredient_code
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- register ingredient
  insert into catchmenu_store.ingredients (
    tenant_id, store_id,
    ingredient_code, ingredient_name,
    ingredient_category, unit, storage_type,
    current_quantity, reserved_quantity,
    min_quantity, warning_quantity, reorder_quantity,
    linked_menu_ids,
    unit_cost, supplier_name,
    ingredient_status,
    last_restocked_at, last_checked_at
  ) values (
    p_tenant_id, p_store_id,
    p_ingredient_code, p_ingredient_name,
    p_ingredient_category, p_unit, p_storage_type,
    coalesce(p_initial_quantity, 0), 0,
    coalesce(p_min_quantity, 0),
    coalesce(p_warning_quantity, 0),
    p_reorder_quantity,
    coalesce(p_linked_menu_ids, '[]'::jsonb),
    p_unit_cost, p_supplier_name,
    case
      when coalesce(p_initial_quantity, 0) = 0
      then 'OUT_OF_STOCK'
      when coalesce(p_initial_quantity, 0) <=
        coalesce(p_warning_quantity, 0)
      then 'LOW_STOCK'
      else 'ACTIVE'
    end,
    case when coalesce(p_initial_quantity, 0) > 0
      then now() else null
    end,
    now()
  )
  returning id into v_ingredient_id;

  -- record initial stock movement
  if coalesce(p_initial_quantity, 0) > 0 then
    insert into catchmenu_store.inventory_movements (
      tenant_id, store_id, ingredient_id,
      movement_type,
      quantity_change, quantity_before, quantity_after,
      unit, unit_cost, total_cost,
      movement_note,
      actor_type, actor_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id, v_ingredient_id,
      'INITIAL_STOCK',
      p_initial_quantity, 0, p_initial_quantity,
      p_unit,
      p_unit_cost,
      case when p_unit_cost is not null
        then p_unit_cost * p_initial_quantity
        else null
      end,
      'Initial stock registration',
      p_actor_type, p_actor_id,
      v_business_day, v_timezone, now()
    );
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
    'inventory', 'ingredient_registered', 1,
    'ingredient', v_ingredient_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'ingredient_code', p_ingredient_code,
      'ingredient_name', p_ingredient_name,
      'unit', p_unit,
      'initial_quantity', p_initial_quantity,
      'min_quantity', p_min_quantity,
      'linked_menu_count',
        jsonb_array_length(
          coalesce(p_linked_menu_ids, '[]'::jsonb)
        )
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'ingredient_id', v_ingredient_id,
    'ingredient_code', p_ingredient_code,
    'ingredient_name', p_ingredient_name,
    'unit', p_unit,
    'current_quantity', p_initial_quantity,
    'ingredient_status', case
      when coalesce(p_initial_quantity, 0) = 0
      then 'OUT_OF_STOCK'
      when coalesce(p_initial_quantity, 0) <=
        coalesce(p_warning_quantity, 0)
      then 'LOW_STOCK'
      else 'ACTIVE'
    end,
    'message_code', 'ingredient_registered'
  );
end;
$$;


create or replace function catchmenu_store.record_inventory_movement(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ingredient_id uuid,
  p_movement_type text,
  p_quantity_change numeric,
  p_unit_cost numeric default null,
  p_reference_type text default null,
  p_reference_id uuid default null,
  p_order_id uuid default null,
  p_movement_note text default null,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_pos,
                  catchmenu_ledger, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_ingredient record;
  v_movement_id uuid;
  v_qty_change numeric;
  v_qty_after numeric;
  v_new_status text;
  v_auto_sold_out_result jsonb;
  v_business_day date;
  v_timezone text;
begin
  if p_movement_type not in (
    'RESTOCK', 'USAGE', 'WASTE',
    'ADJUSTMENT', 'TRANSFER_IN', 'TRANSFER_OUT',
    'INITIAL_STOCK', 'INVENTORY_CHECK'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_movement_type'
    );
  end if;

  if p_quantity_change = 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'quantity_change_cannot_be_zero'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- lock ingredient
  select id, ingredient_code, ingredient_name,
         current_quantity, min_quantity,
         warning_quantity, unit,
         linked_menu_ids, ingredient_status
  into v_ingredient
  from catchmenu_store.ingredients
  where id = p_ingredient_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_ingredient.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ingredient_not_found'
    );
  end if;

  -- outbound movements are negative
  v_qty_change := case p_movement_type
    when 'RESTOCK' then abs(p_quantity_change)
    when 'TRANSFER_IN' then abs(p_quantity_change)
    when 'INITIAL_STOCK' then abs(p_quantity_change)
    when 'USAGE' then -abs(p_quantity_change)
    when 'WASTE' then -abs(p_quantity_change)
    when 'TRANSFER_OUT' then -abs(p_quantity_change)
    when 'ADJUSTMENT' then p_quantity_change
    when 'INVENTORY_CHECK' then p_quantity_change
    else p_quantity_change
  end;

  v_qty_after := greatest(
    0, v_ingredient.current_quantity + v_qty_change
  );

  -- determine new status
  v_new_status := case
    when v_qty_after <= 0 then 'OUT_OF_STOCK'
    when v_qty_after <= v_ingredient.warning_quantity
    then 'LOW_STOCK'
    else 'ACTIVE'
  end;

  -- update ingredient quantity
  update catchmenu_store.ingredients
  set
    current_quantity = v_qty_after,
    ingredient_status = v_new_status,
    last_restocked_at = case p_movement_type
      when 'RESTOCK' then now()
      else last_restocked_at
    end,
    last_checked_at = now(),
    updated_at = now()
  where id = p_ingredient_id;

  -- record movement
  insert into catchmenu_store.inventory_movements (
    tenant_id, store_id, ingredient_id,
    movement_type,
    quantity_change, quantity_before, quantity_after,
    unit, unit_cost, total_cost,
    reference_type, reference_id, order_id,
    movement_note,
    actor_type, actor_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_ingredient_id,
    p_movement_type,
    v_qty_change,
    v_ingredient.current_quantity,
    v_qty_after,
    v_ingredient.unit,
    p_unit_cost,
    case when p_unit_cost is not null
      then p_unit_cost * abs(v_qty_change)
      else null
    end,
    p_reference_type, p_reference_id, p_order_id,
    p_movement_note,
    p_actor_type, p_actor_id,
    v_business_day, v_timezone, now()
  )
  returning id into v_movement_id;

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
    'inventory', 'inventory_movement_recorded', 1,
    'ingredient', p_ingredient_id,
    v_ingredient.ingredient_status, v_new_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'ingredient_code', v_ingredient.ingredient_code,
      'movement_type', p_movement_type,
      'quantity_change', v_qty_change,
      'quantity_before', v_ingredient.current_quantity,
      'quantity_after', v_qty_after,
      'new_status', v_new_status
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- 특허3: 재고 소진 → 연동 메뉴 자동 품절 트리거
  if v_new_status = 'OUT_OF_STOCK'
    and v_ingredient.ingredient_status <> 'OUT_OF_STOCK'
    and jsonb_array_length(
      v_ingredient.linked_menu_ids
    ) > 0
  then
    v_auto_sold_out_result :=
      catchmenu_store.auto_sold_out_by_inventory(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_ingredient_id := p_ingredient_id,
        p_correlation_id := p_correlation_id
      );
  end if;

  -- exception for OUT_OF_STOCK
  if v_new_status = 'OUT_OF_STOCK'
    and v_ingredient.ingredient_status <> 'OUT_OF_STOCK'
  then
    perform catchmenu_ledger.create_exception(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_exception_domain := 'inventory',
      p_exception_type := 'ingredient_out_of_stock',
      p_exception_severity := 'WARNING',
      p_subject_type := 'ingredient',
      p_subject_id := p_ingredient_id,
      p_error_message := v_ingredient.ingredient_name
        || ' 재고 소진',
      p_exception_payload := jsonb_build_object(
        'ingredient_code', v_ingredient.ingredient_code,
        'ingredient_name', v_ingredient.ingredient_name,
        'quantity_after', v_qty_after,
        'linked_menus_affected',
          jsonb_array_length(v_ingredient.linked_menu_ids)
      ),
      p_correlation_id := p_correlation_id
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'movement_id', v_movement_id,
    'ingredient_id', p_ingredient_id,
    'ingredient_code', v_ingredient.ingredient_code,
    'movement_type', p_movement_type,
    'quantity_change', v_qty_change,
    'quantity_before', v_ingredient.current_quantity,
    'quantity_after', v_qty_after,
    'previous_status', v_ingredient.ingredient_status,
    'new_status', v_new_status,
    'auto_sold_out_triggered',
      v_auto_sold_out_result is not null,
    'auto_sold_out_result', v_auto_sold_out_result,
    'message_code', case v_new_status
      when 'OUT_OF_STOCK' then 'ingredient_out_of_stock'
      when 'LOW_STOCK' then 'ingredient_low_stock'
      else 'inventory_movement_recorded'
    end
  );
end;
$$;


create or replace function catchmenu_store.check_inventory_level(
  p_tenant_id uuid,
  p_store_id uuid,
  p_storage_type text default null,
  p_status_filter text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_ingredients jsonb;
  v_summary jsonb;
begin
  -- ingredient list with latest movement
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', i.id,
        'ingredient_code', i.ingredient_code,
        'ingredient_name', i.ingredient_name,
        'ingredient_category', i.ingredient_category,
        'unit', i.unit,
        'storage_type', i.storage_type,
        'current_quantity', i.current_quantity,
        'available_quantity', i.available_quantity,
        'reserved_quantity', i.reserved_quantity,
        'min_quantity', i.min_quantity,
        'warning_quantity', i.warning_quantity,
        'ingredient_status', i.ingredient_status,
        'linked_menu_count', jsonb_array_length(
          i.linked_menu_ids
        ),
        'last_restocked_at', i.last_restocked_at,
        'last_checked_at', i.last_checked_at,
        'days_since_restock', case
          when i.last_restocked_at is not null
          then extract(
            epoch from (now() - i.last_restocked_at)
          )::int / 86400
          else null
        end
      )
      order by
        case i.ingredient_status
          when 'OUT_OF_STOCK' then 0
          when 'LOW_STOCK' then 1
          else 2
        end,
        i.ingredient_name
    ),
    '[]'::jsonb
  )
  into v_ingredients
  from catchmenu_store.ingredients i
  where i.store_id = p_store_id
    and i.tenant_id = p_tenant_id
    and i.is_active = true
    and (
      p_storage_type is null
      or i.storage_type = p_storage_type
    )
    and (
      p_status_filter is null
      or i.ingredient_status = p_status_filter
    );

  -- summary
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where ingredient_status = 'ACTIVE'
    ),
    'low_stock', count(*) filter (
      where ingredient_status = 'LOW_STOCK'
    ),
    'out_of_stock', count(*) filter (
      where ingredient_status = 'OUT_OF_STOCK'
    ),
    'needs_reorder', count(*) filter (
      where current_quantity <= coalesce(
        reorder_quantity, warning_quantity, 0
      )
    )
  )
  into v_summary
  from catchmenu_store.ingredients
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'ingredients', v_ingredients,
    'summary', v_summary,
    'checked_at', now(),
    'message_code', 'inventory_level_checked'
  );
end;
$$;


create or replace function catchmenu_store.auto_sold_out_by_inventory(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ingredient_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_pos,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_ingredient record;
  v_menu_id text;
  v_affected_menus int := 0;
  v_menu_results jsonb := '[]'::jsonb;
  v_result jsonb;
begin
  select id, ingredient_code, ingredient_name,
         linked_menu_ids, ingredient_status
  into v_ingredient
  from catchmenu_store.ingredients
  where id = p_ingredient_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_ingredient.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ingredient_not_found'
    );
  end if;

  if jsonb_array_length(
    v_ingredient.linked_menu_ids
  ) = 0 then
    return jsonb_build_object(
      'success', true,
      'affected_menus', 0,
      'message_code', 'no_linked_menus'
    );
  end if;

  -- 특허3: 재고 소진 → 연동 메뉴 자동 품절
  -- → update_menu_status 호출
  -- → KDS conditions_met.menu_available = false 자동 연동
  for v_menu_id in
    select jsonb_array_elements_text(
      v_ingredient.linked_menu_ids
    )
  loop
    begin
      v_result := catchmenu_pos.update_menu_status(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_menu_id := v_menu_id::uuid,
        p_new_status := 'SOLD_OUT',
        p_reason := '재고 소진: ' ||
          v_ingredient.ingredient_name,
        p_actor_type := 'SYSTEM',
        p_correlation_id := p_correlation_id
      );

      if (v_result->>'success')::boolean then
        v_affected_menus := v_affected_menus + 1;
      end if;

      v_menu_results := v_menu_results
        || jsonb_build_array(
          jsonb_build_object(
            'menu_id', v_menu_id,
            'success', v_result->>'success',
            'message_code', v_result->>'message_code',
            'affected_kds_tickets',
              v_result->>'affected_kds_tickets'
          )
        );

    exception when others then
      v_menu_results := v_menu_results
        || jsonb_build_array(
          jsonb_build_object(
            'menu_id', v_menu_id,
            'success', false,
            'error', sqlerrm
          )
        );
    end;
  end loop;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'inventory', 'auto_sold_out_triggered', 1,
    'ingredient', p_ingredient_id,
    'ACTIVE', 'OUT_OF_STOCK',
    'SYSTEM',
    jsonb_build_object(
      'ingredient_code', v_ingredient.ingredient_code,
      'ingredient_name', v_ingredient.ingredient_name,
      'affected_menus', v_affected_menus,
      'menu_results', v_menu_results
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'ingredient_id', p_ingredient_id,
    'ingredient_code', v_ingredient.ingredient_code,
    'ingredient_name', v_ingredient.ingredient_name,
    'affected_menus', v_affected_menus,
    'menu_results', v_menu_results,
    'message_code', 'auto_sold_out_completed'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.register_ingredient(
    uuid, uuid, text, text, text, text,
    text, numeric, numeric, numeric, numeric,
    text, jsonb, numeric, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.register_ingredient(
    uuid, uuid, text, text, text, text,
    text, numeric, numeric, numeric, numeric,
    text, jsonb, numeric, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.record_inventory_movement(
    uuid, uuid, uuid, text, numeric, numeric,
    text, uuid, uuid, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.record_inventory_movement(
    uuid, uuid, uuid, text, numeric, numeric,
    text, uuid, uuid, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.check_inventory_level(
    uuid, uuid, text, text
  ) from public;
  grant execute on function catchmenu_store.check_inventory_level(
    uuid, uuid, text, text
  ) to authenticated;

  revoke all on function catchmenu_store.auto_sold_out_by_inventory(
    uuid, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_store.auto_sold_out_by_inventory(
    uuid, uuid, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.record_inventory_movement(
  uuid, uuid, uuid, text, numeric, numeric,
  text, uuid, uuid, text, text, uuid, text
) is
  'Records inventory stock change and updates ingredient status.
   Outbound movements (USAGE/WASTE/TRANSFER_OUT) auto-negated.
   When status transitions to OUT_OF_STOCK:
   → auto_sold_out_by_inventory triggered for linked menus
   → update_menu_status sets SOLD_OUT on each linked menu
   → KDS conditions_met.menu_available = false cascades
   → Active KDS tickets revert to HOLD.
   특허3: 재고 소진 → 메뉴 품절 자동 연동 → KDS 조건 자동 변경.';

comment on function catchmenu_store.auto_sold_out_by_inventory(
  uuid, uuid, uuid, text
) is
  'Marks all linked menus as SOLD_OUT when ingredient runs out.
   Calls update_menu_status for each menu in linked_menu_ids.
   update_menu_status cascades to KDS tickets automatically.
   특허3: 재고 소진 이벤트 → 자동 품절 체인:
   ingredient OUT_OF_STOCK
   → linked menu SOLD_OUT
   → KDS conditions_met.menu_available = false
   → 해당 티켓 HOLD 복귀
   → 직원 알림 → 고객 안내.';