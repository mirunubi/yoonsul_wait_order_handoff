-- 0044_create_menu_management_rpc.sql
-- Purpose: Menu status management RPCs.
--          update_menu_status: marks menu AVAILABLE/SOLD_OUT/HIDDEN.
--          bulk_update_menu_status: updates multiple menus at once.
--          get_menu_catalog: returns full menu for kiosk/app display.
--          특허2: 메뉴 품절 상태 → KDS Late Binding 조건 자동 연동.
-- Depends on: 0043_create_did_display_rpc.sql
-- Creates:
--   function catchmenu_pos.update_menu_status(...)
--   function catchmenu_pos.bulk_update_menu_status(...)
--   function catchmenu_pos.get_menu_catalog(...)

create or replace function catchmenu_pos.update_menu_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid,
  p_new_status text,
  p_reason text default null,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_menu record;
  v_affected_tickets int;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_new_status not in (
    'AVAILABLE', 'SOLD_OUT', 'HIDDEN', 'DISCONTINUED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_menu_status'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, menu_code, menu_name,
         menu_status, kitchen_zone,
         is_kds_required
  into v_menu
  from catchmenu_pos.menus
  where id = p_menu_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_menu.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'menu_not_found'
    );
  end if;

  if v_menu.menu_status = p_new_status then
    return jsonb_build_object(
      'success', true,
      'menu_id', p_menu_id,
      'menu_status', p_new_status,
      'message_code', 'status_unchanged'
    );
  end if;

  -- update menu status
  update catchmenu_pos.menus
  set
    menu_status = p_new_status,
    updated_at = now()
  where id = p_menu_id;

  -- if SOLD_OUT: update conditions_met.menu_available = false
  -- on all HOLD/CAPACITY_CHECKING KDS tickets for this menu
  -- 특허2: 품절 → KDS Late Binding 조건 menu_available = false
  if p_new_status = 'SOLD_OUT' then
    update catchmenu_kds.kds_tickets kt
    set
      conditions_met = conditions_met || jsonb_build_object(
        'menu_available', false
      ),
      hold_reason = 'MENU_SOLD_OUT',
      kds_status = 'HOLD',
      updated_at = now()
    from catchmenu_pos.order_items oi
    where oi.menu_id = p_menu_id
      and oi.order_id = kt.order_id
      and kt.store_id = p_store_id
      and kt.tenant_id = p_tenant_id
      and kt.kds_status in (
        'CAPACITY_CHECKING', 'READY_TO_COMMIT'
      );

    get diagnostics v_affected_tickets = row_count;

    -- KDS events for affected tickets
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id, ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type, caused_by_id,
      event_payload, correlation_id, occurred_at
    )
    select
      p_tenant_id, p_store_id,
      kt.id, kt.order_id,
      'peak_time_restricted',
      kt.kds_status, 'HOLD',
      p_actor_type, p_actor_id,
      jsonb_build_object(
        'menu_id', p_menu_id,
        'menu_name', v_menu.menu_name,
        'reason', 'MENU_SOLD_OUT'
      ),
      p_correlation_id, now()
    from catchmenu_kds.kds_tickets kt
    join catchmenu_pos.order_items oi
      on oi.order_id = kt.order_id
      and oi.menu_id = p_menu_id
    where kt.store_id = p_store_id
      and kt.kds_status = 'HOLD'
      and kt.hold_reason = 'MENU_SOLD_OUT';

  elsif p_new_status = 'AVAILABLE'
    and v_menu.menu_status = 'SOLD_OUT'
  then
    -- restore: update menu_available = true
    update catchmenu_kds.kds_tickets kt
    set
      conditions_met = conditions_met || jsonb_build_object(
        'menu_available', true
      ),
      hold_reason = null,
      updated_at = now()
    from catchmenu_pos.order_items oi
    where oi.menu_id = p_menu_id
      and oi.order_id = kt.order_id
      and kt.store_id = p_store_id
      and kt.tenant_id = p_tenant_id
      and kt.kds_status = 'HOLD'
      and kt.hold_reason = 'MENU_SOLD_OUT';

    get diagnostics v_affected_tickets = row_count;
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
    'order', 'menu_status_changed', 1,
    'menu', p_menu_id,
    v_menu.menu_status, p_new_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'menu_code', v_menu.menu_code,
      'menu_name', v_menu.menu_name,
      'reason', p_reason,
      'affected_kds_tickets', v_affected_tickets
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit for SOLD_OUT and DISCONTINUED
  if p_new_status in ('SOLD_OUT', 'DISCONTINUED') then
    v_audit_id := catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'order',
      p_audit_type := 'menu_status_changed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_subject_type := 'menu',
      p_subject_id := p_menu_id,
      p_decision := 'COMPLETED',
      p_decision_reason := p_reason,
      p_decision_payload := jsonb_build_object(
        'menu_code', v_menu.menu_code,
        'menu_name', v_menu.menu_name,
        'previous_status', v_menu.menu_status,
        'new_status', p_new_status,
        'affected_kds_tickets', v_affected_tickets
      ),
      p_before_state := jsonb_build_object(
        'menu_status', v_menu.menu_status
      ),
      p_after_state := jsonb_build_object(
        'menu_status', p_new_status
      ),
      p_correlation_id := p_correlation_id,
      p_business_day := v_business_day,
      p_business_timezone := v_timezone
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'menu_id', p_menu_id,
    'menu_code', v_menu.menu_code,
    'menu_name', v_menu.menu_name,
    'previous_status', v_menu.menu_status,
    'new_status', p_new_status,
    'affected_kds_tickets', coalesce(v_affected_tickets, 0),
    'audit_id', v_audit_id,
    'message_code', case p_new_status
      when 'SOLD_OUT' then 'menu_sold_out_kds_updated'
      when 'AVAILABLE' then 'menu_available_restored'
      else 'menu_status_updated'
    end
  );
end;
$$;


create or replace function catchmenu_pos.bulk_update_menu_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_updates jsonb,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common
as $$
declare
  v_item jsonb;
  v_result jsonb;
  v_results jsonb := '[]'::jsonb;
  v_success_count int := 0;
  v_failed_count int := 0;
begin
  -- validate input
  if p_updates is null
    or jsonb_typeof(p_updates) <> 'array'
    or jsonb_array_length(p_updates) = 0
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'updates_array_required'
    );
  end if;

  if jsonb_array_length(p_updates) > 50 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'too_many_updates',
      'max_allowed', 50
    );
  end if;

  -- process each update
  for v_item in
    select * from jsonb_array_elements(p_updates)
  loop
    if v_item->>'menu_id' is null
      or v_item->>'new_status' is null
    then
      v_results := v_results || jsonb_build_array(
        jsonb_build_object(
          'menu_id', v_item->>'menu_id',
          'success', false,
          'error_key', 'menu_id_and_status_required'
        )
      );
      v_failed_count := v_failed_count + 1;
      continue;
    end if;

    v_result := catchmenu_pos.update_menu_status(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_menu_id := (v_item->>'menu_id')::uuid,
      p_new_status := v_item->>'new_status',
      p_reason := v_item->>'reason',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_correlation_id := p_correlation_id
    );

    if (v_result->>'success')::boolean then
      v_success_count := v_success_count + 1;
    else
      v_failed_count := v_failed_count + 1;
    end if;

    v_results := v_results || jsonb_build_array(
      jsonb_build_object(
        'menu_id', v_item->>'menu_id',
        'success', v_result->>'success',
        'new_status', v_result->>'new_status',
        'error_key', v_result->>'error_key',
        'affected_kds_tickets',
          v_result->>'affected_kds_tickets'
      )
    );
  end loop;

  return jsonb_build_object(
    'success', v_failed_count = 0,
    'success_count', v_success_count,
    'failed_count', v_failed_count,
    'total', v_success_count + v_failed_count,
    'results', v_results,
    'message_code', case
      when v_failed_count = 0 then 'bulk_update_completed'
      when v_success_count = 0 then 'bulk_update_all_failed'
      else 'bulk_update_partial'
    end
  );
end;
$$;


create or replace function catchmenu_pos.get_menu_catalog(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko',
  p_include_hidden boolean default false,
  p_include_sold_out boolean default true
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_categories jsonb;
  v_menus jsonb;
begin
  select id, store_name, timezone
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

  -- categories
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'category_code', c.category_code,
        'category_name', c.category_name,
        'parent_category_id', c.parent_category_id,
        'display_order', c.display_order
      )
      order by c.display_order, c.category_name
    ),
    '[]'::jsonb
  )
  into v_categories
  from catchmenu_pos.menu_categories c
  where c.store_id = p_store_id
    and c.tenant_id = p_tenant_id
    and c.is_active = true;

  -- menus with options
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', m.id,
        'category_id', m.category_id,
        'menu_code', m.menu_code,
        'menu_name', case p_locale
          when 'en' then coalesce(m.menu_name_en, m.menu_name)
          when 'zh' then coalesce(m.menu_name_zh, m.menu_name)
          when 'ja' then coalesce(m.menu_name_ja, m.menu_name)
          else m.menu_name
        end,
        'description', m.description,
        'price', m.price,
        'image_url', m.image_url,
        'menu_status', m.menu_status,
        'is_kds_required', m.is_kds_required,
        'estimated_minutes', m.estimated_minutes,
        'allergen_info', m.allergen_info,
        'display_order', m.display_order,
        'option_groups', (
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'id', og.id,
                'group_code', og.group_code,
                'group_name', og.group_name,
                'is_required', og.is_required,
                'min_select', og.min_select,
                'max_select', og.max_select,
                'display_order', og.display_order,
                'items', (
                  select coalesce(
                    jsonb_agg(
                      jsonb_build_object(
                        'id', oi.id,
                        'item_code', oi.item_code,
                        'item_name', oi.item_name,
                        'additional_price',
                          oi.additional_price,
                        'display_order', oi.display_order
                      )
                      order by oi.display_order
                    ),
                    '[]'::jsonb
                  )
                  from catchmenu_pos.menu_option_items oi
                  where oi.option_group_id = og.id
                    and oi.is_active = true
                )
              )
              order by og.display_order
            ),
            '[]'::jsonb
          )
          from catchmenu_pos.menu_option_groups og
          where og.menu_id = m.id
            and og.is_active = true
        )
      )
      order by m.display_order, m.menu_name
    ),
    '[]'::jsonb
  )
  into v_menus
  from catchmenu_pos.menus m
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and (
      p_include_hidden = true
      or m.menu_status <> 'HIDDEN'
    )
    and (
      p_include_sold_out = true
      or m.menu_status = 'AVAILABLE'
    )
    and m.menu_status <> 'DISCONTINUED';

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'locale', p_locale,
    'categories', v_categories,
    'menus', v_menus,
    'category_count', jsonb_array_length(v_categories),
    'menu_count', jsonb_array_length(v_menus),
    'generated_at', now(),
    'message_code', 'menu_catalog_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.update_menu_status(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.update_menu_status(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.bulk_update_menu_status(
    uuid, uuid, jsonb, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.bulk_update_menu_status(
    uuid, uuid, jsonb, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.get_menu_catalog(
    uuid, uuid, text, boolean, boolean
  ) from public;
  grant execute on function catchmenu_pos.get_menu_catalog(
    uuid, uuid, text, boolean, boolean
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.update_menu_status(
  uuid, uuid, uuid, text, text, text, uuid, text
) is
  'Updates menu item status with KDS cascade effect.
   SOLD_OUT: sets conditions_met.menu_available = false
     on all active KDS tickets using this menu.
     Tickets revert to HOLD state automatically.
   AVAILABLE (from SOLD_OUT): restores menu_available = true.
     KDS capacity check re-runs on next commit attempt.
   특허2: 메뉴 품절 → KDS Late Binding 조건 menu_available 자동 연동.
   품절된 메뉴가 포함된 KDS 티켓은 자동으로 HOLD 복귀.';

comment on function catchmenu_pos.get_menu_catalog(
  uuid, uuid, text, boolean, boolean
) is
  'Returns full menu catalog for kiosk and customer app display.
   Supports locale-based name selection: ko/en/zh/ja.
   Includes nested option groups and option items.
   Excludes DISCONTINUED menus always.
   Used by kiosk boot and customer app menu page load.
   특허1: 다국어 메뉴 표시 + allergen_info 포함.';