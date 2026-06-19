-- 0060_create_franchise_hq_rpc.sql
-- Purpose: Franchise HQ management RPCs.
--          create_franchise_store: provisions new franchise store.
--          get_franchise_dashboard: HQ-level multi-store KPI.
--          broadcast_hq_notice: sends notice to all stores.
--          sync_hq_menu_template: pushes menu template to stores.
--          특허4 core: HQ ↔ Store 경계 — 본사 권한과 매장 자율성 분리.
-- Depends on: 0059_create_point_ledger_rpc.sql
-- Creates:
--   catchmenu_hq.hq_notices (table)
--   catchmenu_hq.menu_templates (table)
--   function catchmenu_hq.create_franchise_store(...)
--   function catchmenu_hq.get_franchise_dashboard(...)
--   function catchmenu_hq.broadcast_hq_notice(...)
--   function catchmenu_hq.sync_hq_menu_template(...)

-- =============================================
-- hq_notices table
-- =============================================
create table if not exists catchmenu_hq.hq_notices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  notice_code text not null,
  notice_type text not null,
  title text not null,
  body text not null,
  priority text not null default 'NORMAL',

  -- target
  target_all_stores boolean not null default true,
  target_store_ids jsonb default '[]'::jsonb,

  -- validity
  valid_from timestamptz not null default now(),
  valid_until timestamptz,

  -- status
  notice_status text not null default 'ACTIVE',
  read_required boolean not null default false,

  -- author
  created_by_type text not null default 'HQ_ADMIN',
  created_by_id uuid,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_notice_code unique (tenant_id, notice_code),
  constraint chk_notice_type check (
    notice_type in (
      'OPERATIONAL', 'MENU_CHANGE', 'POLICY_UPDATE',
      'EMERGENCY', 'TRAINING', 'PROMOTION', 'SYSTEM'
    )
  ),
  constraint chk_notice_priority check (
    priority in ('LOW', 'NORMAL', 'HIGH', 'URGENT')
  ),
  constraint chk_notice_status check (
    notice_status in (
      'ACTIVE', 'EXPIRED', 'CANCELLED'
    )
  )
);

create index if not exists idx_hq_notices_tenant
  on catchmenu_hq.hq_notices(
    tenant_id, notice_status
  ) where notice_status = 'ACTIVE';

alter table catchmenu_hq.hq_notices
  enable row level security;
alter table catchmenu_hq.hq_notices
  force row level security;

drop policy if exists hq_notices_isolation
  on catchmenu_hq.hq_notices;
create policy hq_notices_isolation
  on catchmenu_hq.hq_notices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_hq_notices_updated_at
  on catchmenu_hq.hq_notices;
create trigger trg_hq_notices_updated_at
  before update on catchmenu_hq.hq_notices
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- menu_templates table
-- =============================================
create table if not exists catchmenu_hq.menu_templates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  template_code text not null,
  template_name text not null,
  template_version int not null default 1,
  template_status text not null default 'DRAFT',

  -- template content
  categories jsonb not null default '[]'::jsonb,
  menus jsonb not null default '[]'::jsonb,
  option_groups jsonb not null default '[]'::jsonb,

  -- applicability
  applicable_store_types jsonb
    default '["DINE_IN","TAKEOUT"]'::jsonb,
  is_mandatory boolean not null default false,
  allow_store_override boolean not null default true,

  -- publish
  published_at timestamptz,
  published_by uuid,
  effective_from date,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_menu_template unique (
    tenant_id, template_code, template_version
  ),
  constraint chk_template_status check (
    template_status in (
      'DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED'
    )
  )
);

create index if not exists idx_menu_templates_tenant
  on catchmenu_hq.menu_templates(
    tenant_id, template_status
  ) where template_status = 'PUBLISHED';

alter table catchmenu_hq.menu_templates
  enable row level security;
alter table catchmenu_hq.menu_templates
  force row level security;

drop policy if exists menu_templates_isolation
  on catchmenu_hq.menu_templates;
create policy menu_templates_isolation
  on catchmenu_hq.menu_templates
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_menu_templates_updated_at
  on catchmenu_hq.menu_templates;
create trigger trg_menu_templates_updated_at
  before update on catchmenu_hq.menu_templates
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- RPCs
-- =============================================
create or replace function catchmenu_hq.create_franchise_store(
  p_tenant_id uuid,
  p_store_code text,
  p_store_name text,
  p_store_type text default 'DINE_IN',
  p_address text default null,
  p_phone text default null,
  p_timezone text default 'Asia/Seoul',
  p_opened_on date default null,
  p_franchisee_name text default null,
  p_franchisee_phone text default null,
  p_business_hours jsonb default null,
  p_actor_type text default 'HQ_ADMIN',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq, catchmenu_store,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_store_id uuid;
  v_audit_id uuid;
  v_business_day date;
begin
  if trim(coalesce(p_store_code, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_code_required'
    );
  end if;

  if p_store_type not in (
    'DINE_IN', 'TAKEOUT', 'DELIVERY_ONLY', 'HYBRID'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_store_type'
    );
  end if;

  -- duplicate check
  if exists (
    select 1
    from catchmenu_hq.stores
    where tenant_id = p_tenant_id
      and store_code = p_store_code
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_code_already_exists',
      'store_code', p_store_code
    );
  end if;

  v_business_day := (timezone(
    coalesce(p_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- provision store
  insert into catchmenu_hq.stores (
    tenant_id,
    store_code, store_name, store_type,
    store_status, address, phone, timezone,
    business_hours, opened_on, is_active,
    extra_metadata
  ) values (
    p_tenant_id,
    p_store_code, p_store_name, p_store_type,
    'ACTIVE', p_address, p_phone,
    coalesce(p_timezone, 'Asia/Seoul'),
    p_business_hours,
    coalesce(p_opened_on, current_date),
    true,
    jsonb_build_object(
      'franchisee_name', p_franchisee_name,
      'franchisee_phone', p_franchisee_phone
    )
  )
  returning id into v_store_id;

  -- auto-initialize store settings
  perform catchmenu_store.ensure_store_settings(
    p_tenant_id, v_store_id
  );

  -- auto-initialize point rules
  perform catchmenu_store.ensure_point_rules(p_tenant_id);

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
    p_tenant_id, v_store_id,
    'system', 'franchise_store_created', 1,
    'store', v_store_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'store_code', p_store_code,
      'store_name', p_store_name,
      'store_type', p_store_type,
      'franchisee_name', p_franchisee_name
    ),
    p_correlation_id,
    v_business_day,
    coalesce(p_timezone, 'Asia/Seoul'),
    now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := v_store_id,
    p_audit_domain := 'system',
    p_audit_type := 'franchise_store_created',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store',
    p_subject_id := v_store_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'store_code', p_store_code,
      'store_name', p_store_name,
      'store_type', p_store_type,
      'franchisee_name', p_franchisee_name
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone :=
      coalesce(p_timezone, 'Asia/Seoul')
  );

  return jsonb_build_object(
    'success', true,
    'store_id', v_store_id,
    'store_code', p_store_code,
    'store_name', p_store_name,
    'store_type', p_store_type,
    'store_status', 'ACTIVE',
    'settings_initialized', true,
    'audit_id', v_audit_id,
    'message_code', 'franchise_store_created'
  );
end;
$$;


create or replace function catchmenu_hq.get_franchise_dashboard(
  p_tenant_id uuid,
  p_target_date date default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq, catchmenu_pos,
                  catchmenu_payment, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_target_date date;
  v_store_count int;
  v_store_summaries jsonb;
  v_hq_totals jsonb;
  v_exception_summary jsonb;
  v_top_stores jsonb;
begin
  v_target_date := coalesce(
    p_target_date,
    (timezone('Asia/Seoul', now()))::date
  );

  -- store count
  select count(*)
  into v_store_count
  from catchmenu_hq.stores
  where tenant_id = p_tenant_id
    and is_active = true
    and store_status = 'ACTIVE';

  -- per-store summary
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_code', s.store_code,
        'store_name', s.store_name,
        'store_type', s.store_type,
        'revenue', coalesce(os.revenue, 0),
        'order_count', coalesce(os.order_count, 0),
        'cancelled_count',
          coalesce(os.cancelled_count, 0),
        'session_count',
          coalesce(os.session_count, 0),
        'open_exceptions',
          coalesce(es.open_count, 0),
        'critical_exceptions',
          coalesce(es.critical_count, 0),
        'is_operational',
          coalesce(os.order_count, 0) > 0
            or coalesce(os.session_count, 0) > 0
      )
      order by coalesce(os.revenue, 0) desc
    ),
    '[]'::jsonb
  )
  into v_store_summaries
  from catchmenu_hq.stores s
  left join (
    select
      store_id,
      coalesce(sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0) as revenue,
      count(*) filter (
        where order_status = 'COMPLETED'
      ) as order_count,
      count(*) filter (
        where order_status = 'CANCELLED'
      ) as cancelled_count,
      0 as session_count
    from catchmenu_pos.orders
    where tenant_id = p_tenant_id
      and business_day = v_target_date
    group by store_id
  ) os on os.store_id = s.id
  left join (
    select
      store_id,
      count(*) filter (
        where exception_status in (
          'OPEN', 'ACKNOWLEDGED'
        )
      ) as open_count,
      count(*) filter (
        where exception_severity in (
          'CRITICAL', 'FATAL'
        )
        and exception_status in (
          'OPEN', 'ACKNOWLEDGED'
        )
      ) as critical_count
    from catchmenu_ledger.exceptions
    where tenant_id = p_tenant_id
      and business_day = v_target_date
    group by store_id
  ) es on es.store_id = s.id
  where s.tenant_id = p_tenant_id
    and s.is_active = true;

  -- HQ totals
  select jsonb_build_object(
    'total_revenue', coalesce(sum(
      (store->>'revenue')::int
    ), 0),
    'total_orders', coalesce(sum(
      (store->>'order_count')::int
    ), 0),
    'total_sessions', coalesce(sum(
      (store->>'session_count')::int
    ), 0),
    'open_exceptions', coalesce(sum(
      (store->>'open_exceptions')::int
    ), 0),
    'critical_exceptions', coalesce(sum(
      (store->>'critical_exceptions')::int
    ), 0),
    'stores_operational', count(*) filter (
      where (store->>'is_operational')::boolean
    ),
    'stores_total', v_store_count,
    'avg_store_revenue', case v_store_count
      when 0 then 0
      else coalesce(sum(
        (store->>'revenue')::int
      ), 0) / v_store_count
    end
  )
  into v_hq_totals
  from jsonb_array_elements(v_store_summaries) store;

  -- top 5 stores by revenue
  select coalesce(
    jsonb_agg(store order by
      (store->>'revenue')::int desc
    ),
    '[]'::jsonb
  )
  into v_top_stores
  from jsonb_array_elements(v_store_summaries) store
  limit 5;

  return jsonb_build_object(
    'success', true,
    'tenant_id', p_tenant_id,
    'target_date', v_target_date,
    'store_count', v_store_count,
    'hq_totals', v_hq_totals,
    'store_summaries', v_store_summaries,
    'top_stores', v_top_stores,
    'generated_at', now(),
    'message_code', 'franchise_dashboard_loaded'
  );
end;
$$;


create or replace function catchmenu_hq.broadcast_hq_notice(
  p_tenant_id uuid,
  p_notice_type text,
  p_title text,
  p_body text,
  p_priority text default 'NORMAL',
  p_target_store_ids jsonb default null,
  p_valid_until timestamptz default null,
  p_read_required boolean default false,
  p_actor_type text default 'HQ_ADMIN',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_notice_id uuid;
  v_notice_code text;
  v_target_all boolean;
  v_store_count int;
  v_audit_id uuid;
  v_business_day date;
begin
  if p_notice_type not in (
    'OPERATIONAL', 'MENU_CHANGE', 'POLICY_UPDATE',
    'EMERGENCY', 'TRAINING', 'PROMOTION', 'SYSTEM'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_notice_type'
    );
  end if;

  if trim(coalesce(p_title, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'title_required'
    );
  end if;

  if trim(coalesce(p_body, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'body_required'
    );
  end if;

  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_target_all := p_target_store_ids is null
    or jsonb_array_length(
      coalesce(p_target_store_ids, '[]'::jsonb)
    ) = 0;

  -- count target stores
  if v_target_all then
    select count(*)
    into v_store_count
    from catchmenu_hq.stores
    where tenant_id = p_tenant_id
      and is_active = true;
  else
    v_store_count := jsonb_array_length(
      p_target_store_ids
    );
  end if;

  -- generate notice code
  v_notice_code := 'NTC-'
    || upper(substr(p_notice_type, 1, 3))
    || '-'
    || extract(epoch from now())::bigint;

  -- create notice
  insert into catchmenu_hq.hq_notices (
    tenant_id,
    notice_code, notice_type,
    title, body, priority,
    target_all_stores, target_store_ids,
    valid_until, read_required,
    created_by_type, created_by_id
  ) values (
    p_tenant_id,
    v_notice_code, p_notice_type,
    p_title, p_body, p_priority,
    v_target_all,
    coalesce(p_target_store_ids, '[]'::jsonb),
    p_valid_until, p_read_required,
    p_actor_type, p_actor_id
  )
  returning id into v_notice_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id,
    'system', 'hq_notice_broadcast', 1,
    'hq_notice', v_notice_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'notice_code', v_notice_code,
      'notice_type', p_notice_type,
      'priority', p_priority,
      'target_all_stores', v_target_all,
      'store_count', v_store_count,
      'read_required', p_read_required
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  -- audit for EMERGENCY and POLICY notices
  if p_notice_type in (
    'EMERGENCY', 'POLICY_UPDATE'
  ) then
    v_audit_id := catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := null,
      p_audit_domain := 'system',
      p_audit_type := 'hq_notice_broadcast',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_subject_type := 'hq_notice',
      p_subject_id := v_notice_id,
      p_decision := 'COMPLETED',
      p_decision_payload := jsonb_build_object(
        'notice_code', v_notice_code,
        'notice_type', p_notice_type,
        'priority', p_priority,
        'store_count', v_store_count,
        'title', p_title
      ),
      p_correlation_id := p_correlation_id,
      p_business_day := v_business_day,
      p_business_timezone := 'Asia/Seoul'
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'notice_id', v_notice_id,
    'notice_code', v_notice_code,
    'notice_type', p_notice_type,
    'priority', p_priority,
    'target_all_stores', v_target_all,
    'store_count', v_store_count,
    'read_required', p_read_required,
    'audit_id', v_audit_id,
    'message_code', 'hq_notice_broadcast'
  );
end;
$$;


create or replace function catchmenu_hq.sync_hq_menu_template(
  p_tenant_id uuid,
  p_template_id uuid,
  p_target_store_ids jsonb default null,
  p_sync_mode text default 'MERGE',
  p_actor_type text default 'HQ_ADMIN',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq, catchmenu_pos,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_template record;
  v_store record;
  v_synced_count int := 0;
  v_failed_count int := 0;
  v_store_results jsonb := '[]'::jsonb;
  v_sync_result jsonb;
  v_business_day date;
  v_audit_id uuid;
  v_target_stores jsonb;
begin
  if p_sync_mode not in ('MERGE', 'REPLACE') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_sync_mode',
      'allowed', array['MERGE', 'REPLACE']
    );
  end if;

  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- get template
  select id, template_code, template_name,
         template_version, template_status,
         categories, menus, option_groups,
         is_mandatory, allow_store_override
  into v_template
  from catchmenu_hq.menu_templates
  where id = p_template_id
    and tenant_id = p_tenant_id;

  if v_template.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'template_not_found'
    );
  end if;

  if v_template.template_status <> 'PUBLISHED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'template_not_published',
      'template_status', v_template.template_status
    );
  end if;

  -- determine target stores
  if p_target_store_ids is null
    or jsonb_array_length(p_target_store_ids) = 0
  then
    -- all active stores
    select jsonb_agg(id)
    into v_target_stores
    from catchmenu_hq.stores
    where tenant_id = p_tenant_id
      and is_active = true
      and store_status = 'ACTIVE';
  else
    v_target_stores := p_target_store_ids;
  end if;

  -- sync to each store
  for v_store in
    select s.id as store_id,
           s.store_code, s.store_name
    from catchmenu_hq.stores s
    where s.tenant_id = p_tenant_id
      and s.id in (
        select (val::text)::uuid
        from jsonb_array_elements_text(
          v_target_stores
        ) val
      )
      and s.is_active = true
  loop
    begin
      -- MERGE: insert only new menus
      -- REPLACE: full replace (future)
      -- For now: insert categories/menus
      -- that don't exist in the store

      if p_sync_mode = 'MERGE' then
        -- insert categories from template
        -- that don't exist
        insert into catchmenu_pos.menu_categories (
          tenant_id, store_id,
          category_code, category_name,
          display_order, is_active
        )
        select
          p_tenant_id, v_store.store_id,
          (cat->>'category_code')::text,
          (cat->>'category_name')::text,
          coalesce(
            (cat->>'display_order')::int, 10
          ),
          true
        from jsonb_array_elements(
          v_template.categories
        ) cat
        where not exists (
          select 1
          from catchmenu_pos.menu_categories
          where store_id = v_store.store_id
            and category_code =
              (cat->>'category_code')::text
        )
        on conflict (store_id, category_code)
          do nothing;

        -- insert menus from template
        -- that don't exist
        insert into catchmenu_pos.menus (
          tenant_id, store_id,
          menu_code, menu_name,
          price, menu_status,
          display_order, is_active
        )
        select
          p_tenant_id, v_store.store_id,
          (m->>'menu_code')::text,
          (m->>'menu_name')::text,
          (m->>'price')::int,
          'AVAILABLE',
          coalesce(
            (m->>'display_order')::int, 10
          ),
          true
        from jsonb_array_elements(
          v_template.menus
        ) m
        where not exists (
          select 1
          from catchmenu_pos.menus
          where store_id = v_store.store_id
            and menu_code =
              (m->>'menu_code')::text
        )
        on conflict (store_id, menu_code)
          do nothing;
      end if;

      v_synced_count := v_synced_count + 1;

      v_store_results := v_store_results
        || jsonb_build_array(
          jsonb_build_object(
            'store_id', v_store.store_id,
            'store_code', v_store.store_code,
            'store_name', v_store.store_name,
            'success', true,
            'sync_mode', p_sync_mode
          )
        );

    exception when others then
      v_failed_count := v_failed_count + 1;
      v_store_results := v_store_results
        || jsonb_build_array(
          jsonb_build_object(
            'store_id', v_store.store_id,
            'store_code', v_store.store_code,
            'success', false,
            'error', sqlerrm
          )
        );
    end;
  end loop;

  -- broadcast notice about menu template sync
  perform catchmenu_hq.broadcast_hq_notice(
    p_tenant_id := p_tenant_id,
    p_notice_type := 'MENU_CHANGE',
    p_title := '메뉴 템플릿 동기화: '
      || v_template.template_name,
    p_body := '본사 메뉴 템플릿 v'
      || v_template.template_version
      || '이 ' || v_synced_count
      || '개 매장에 동기화되었습니다.',
    p_priority := 'NORMAL',
    p_target_store_ids := v_target_stores,
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := null,
    p_audit_domain := 'system',
    p_audit_type := 'hq_menu_template_synced',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'menu_template',
    p_subject_id := p_template_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'template_code', v_template.template_code,
      'template_version', v_template.template_version,
      'sync_mode', p_sync_mode,
      'synced_count', v_synced_count,
      'failed_count', v_failed_count
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  return jsonb_build_object(
    'success', v_failed_count = 0,
    'template_id', p_template_id,
    'template_code', v_template.template_code,
    'template_version', v_template.template_version,
    'sync_mode', p_sync_mode,
    'synced_count', v_synced_count,
    'failed_count', v_failed_count,
    'store_results', v_store_results,
    'audit_id', v_audit_id,
    'message_code', case
      when v_failed_count = 0
      then 'menu_template_synced'
      else 'menu_template_partial_sync'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_hq.create_franchise_store(
    uuid, text, text, text, text, text,
    text, date, text, text, jsonb, text, uuid, text
  ) from public;
  grant execute on function catchmenu_hq.create_franchise_store(
    uuid, text, text, text, text, text,
    text, date, text, text, jsonb, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_hq.get_franchise_dashboard(
    uuid, date
  ) from public;
  grant execute on function catchmenu_hq.get_franchise_dashboard(
    uuid, date
  ) to authenticated;

  revoke all on function catchmenu_hq.broadcast_hq_notice(
    uuid, text, text, text, text, jsonb,
    timestamptz, boolean, text, uuid, text
  ) from public;
  grant execute on function catchmenu_hq.broadcast_hq_notice(
    uuid, text, text, text, text, jsonb,
    timestamptz, boolean, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_hq.sync_hq_menu_template(
    uuid, uuid, jsonb, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_hq.sync_hq_menu_template(
    uuid, uuid, jsonb, text, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_hq.create_franchise_store(
  uuid, text, text, text, text, text,
  text, date, text, text, jsonb, text, uuid, text
) is
  'Provisions new franchise store under tenant.
   Auto-initializes store_settings and point_rules.
   Stores franchisee info in extra_metadata.
   특허4: HQ ↔ Store 경계.
   본사는 매장을 생성하고 초기화하지만
   일상 운영 권한은 매장에 위임됨.';

comment on function catchmenu_hq.get_franchise_dashboard(
  uuid, date
) is
  'HQ-level multi-store dashboard.
   Returns per-store revenue, orders, exceptions.
   Identifies top performers and problem stores.
   특허3: 전체 가맹점 KPI → AI Agent 본사 운영 최적화 추천.
   open_exceptions > 0 인 매장 → HQ 즉시 개입 신호.';

comment on function catchmenu_hq.sync_hq_menu_template(
  uuid, uuid, jsonb, text, text, uuid, text
) is
  'Syncs HQ menu template to target stores.
   MERGE: inserts only new items (preserves store customization).
   REPLACE: full replacement (future — currently MERGE only).
   Auto-broadcasts MENU_CHANGE notice to target stores.
   특허4: HQ 메뉴 템플릿 = 본사 표준.
   allow_store_override = true → 매장별 가격/설명 수정 허용.
   is_mandatory = true → 매장이 삭제 불가능한 메뉴.';