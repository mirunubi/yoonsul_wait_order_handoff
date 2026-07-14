-- 0024_create_store_bootstrap_rpc.sql
-- Purpose: Store app post-login bootstrap RPC.
--          Returns tenant, store, tables, menus, active sessions,
--          and pending agent approvals for kiosk/KDS/staff app startup.
--          Single RPC call replaces multiple round trips on app launch.
-- Depends on: 0023_create_append_audit_rpc.sql
-- Creates:
--   function catchmenu_common.get_store_bootstrap(uuid, uuid)

create or replace function catchmenu_common.get_store_bootstrap(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common, catchmenu_hq,
                  catchmenu_store, catchmenu_pos,
                  catchmenu_kds, catchmenu_agent,
                  catchmenu_ledger
as $$
declare
  v_tenant record;
  v_store record;
  v_tables jsonb;
  v_categories jsonb;
  v_active_sessions jsonb;
  v_kds_hold_count int;
  v_kds_cooking_count int;
  v_open_exceptions_count int;
  v_pending_approvals_count int;
  v_active_fallback boolean;
  v_menu_count int;
  v_sold_out_count int;
begin
  -- tenant validation
  select id, tenant_code, tenant_name, tenant_type, plan_tier
  into v_tenant
  from catchmenu_hq.tenants
  where id = p_tenant_id
    and is_active = true;

  if v_tenant.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tenant_not_found'
    );
  end if;

  -- store validation
  select
    id, store_code, store_name, store_type,
    store_status, timezone, address, phone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  if v_store.store_status not in ('ACTIVE', 'PREPARING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_operational',
      'store_status', v_store.store_status
    );
  end if;

  -- dining tables
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'table_code', t.table_code,
        'table_name', t.table_name,
        'capacity', t.capacity,
        'floor_zone', t.floor_zone,
        'table_section', t.table_section,
        'table_status', t.table_status,
        'display_order', t.display_order,
        'qr_code', t.qr_code,
        'current_session_id', t.current_session_id
      )
      order by t.display_order, t.table_code
    ),
    '[]'::jsonb
  )
  into v_tables
  from catchmenu_store.dining_tables t
  where t.store_id = p_store_id
    and t.is_active = true;

  -- menu categories
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'category_code', c.category_code,
        'category_name', c.category_name,
        'parent_category_id', c.parent_category_id,
        'display_order', c.display_order
      )
      order by c.display_order
    ),
    '[]'::jsonb
  )
  into v_categories
  from catchmenu_pos.menu_categories c
  where c.store_id = p_store_id
    and c.is_active = true;

  -- active sessions (not completed/cancelled/expired)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'session_type', s.session_type,
        'session_status', s.session_status,
        'table_id', s.table_id,
        'wait_number', s.wait_number,
        'guest_count', s.guest_count,
        'guest_locale', s.guest_locale,
        'session_started_at', s.session_started_at,
        'seated_at', s.seated_at,
        'order_id', s.order_id
      )
      order by s.session_started_at asc
    ),
    '[]'::jsonb
  )
  into v_active_sessions
  from catchmenu_pos.order_sessions s
  where s.store_id = p_store_id
    and s.session_status not in (
      'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
    )
    and s.business_day = (
      timezone(v_store.timezone, now())::date
    );

  -- KDS summary counts
  select
    count(*) filter (
      where kds_status in ('HOLD', 'CAPACITY_CHECKING')
    ),
    count(*) filter (
      where kds_status in ('COOKING', 'COMMITTED')
    )
  into v_kds_hold_count, v_kds_cooking_count
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and business_day = (timezone(v_store.timezone, now())::date)
    and kds_status not in ('COMPLETED', 'CANCELLED');

  -- open exceptions count
  select count(*)
  into v_open_exceptions_count
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and exception_status in (
      'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY', 'ESCALATED'
    );

  -- pending agent approvals
  select count(*)
  into v_pending_approvals_count
  from catchmenu_agent.agent_approvals
  where store_id = p_store_id
    and approval_status in ('PENDING', 'NOTIFIED', 'UNDER_REVIEW');

  -- active manual fallback
  select exists (
    select 1
    from catchmenu_agent.manual_fallback_log
    where store_id = p_store_id
      and fallback_status in ('ACTIVE', 'RECOVERING')
  )
  into v_active_fallback;

  -- menu counts
  select
    count(*) filter (where menu_status = 'AVAILABLE'),
    count(*) filter (where menu_status = 'SOLD_OUT')
  into v_menu_count, v_sold_out_count
  from catchmenu_pos.menus
  where store_id = p_store_id
    and is_active = true;

  -- audit bootstrap event
  perform catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'system',
    p_audit_type := 'store_bootstrap_completed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'store',
    p_subject_id := p_store_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'table_count', jsonb_array_length(v_tables),
      'active_session_count', jsonb_array_length(v_active_sessions),
      'kds_hold_count', v_kds_hold_count,
      'open_exceptions_count', v_open_exceptions_count
    ),
    p_business_day := (timezone(v_store.timezone, now())::date),
    p_business_timezone := v_store.timezone
  );

  return jsonb_build_object(
    'success', true,
    'tenant', jsonb_build_object(
      'id', v_tenant.id,
      'tenant_code', v_tenant.tenant_code,
      'tenant_name', v_tenant.tenant_name,
      'tenant_type', v_tenant.tenant_type,
      'plan_tier', v_tenant.plan_tier
    ),
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_code', v_store.store_code,
      'store_name', v_store.store_name,
      'store_type', v_store.store_type,
      'store_status', v_store.store_status,
      'timezone', v_store.timezone,
      'address', v_store.address,
      'phone', v_store.phone,
      'business_day', (timezone(v_store.timezone, now())::date)
    ),
    'tables', v_tables,
    'menu_categories', v_categories,
    'active_sessions', v_active_sessions,
    'operational_summary', jsonb_build_object(
      'menu_available_count', v_menu_count,
      'menu_sold_out_count', v_sold_out_count,
      'kds_hold_count', v_kds_hold_count,
      'kds_cooking_count', v_kds_cooking_count,
      'open_exceptions_count', v_open_exceptions_count,
      'pending_approvals_count', v_pending_approvals_count,
      'active_fallback', v_active_fallback
    ),
    'alerts', jsonb_build_object(
      'has_open_exceptions',
        v_open_exceptions_count > 0,
      'has_pending_approvals',
        v_pending_approvals_count > 0,
      'fallback_active',
        v_active_fallback,
      'has_sold_out_menus',
        v_sold_out_count > 0,
      'has_kds_hold',
        v_kds_hold_count > 0
    )
  );
end;
$$;

revoke all on function catchmenu_common.get_store_bootstrap(uuid, uuid)
  from public;

grant execute on function catchmenu_common.get_store_bootstrap(uuid, uuid)
  to authenticated;

comment on function catchmenu_common.get_store_bootstrap(uuid, uuid) is
  'Store app bootstrap RPC. Single call on app startup.
   Returns everything the store app needs to initialize:
   tenant, store, tables, menu categories, active sessions,
   KDS summary, exception count, pending approvals, fallback status.
   Writes audit record on every bootstrap call.
   Used by kiosk, KDS display, staff tablet, and DID apps.';