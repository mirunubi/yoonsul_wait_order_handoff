===== BEGIN sql/migrations/0162_create_dining_table_admin_rpc.sql =====
-- 0162_create_dining_table_admin_rpc.sql
--
-- Purpose:
--   Store Admin Console dining table CRUD contract.
--
-- Background:
--   Workpacket:
--     docs/600000_implementation_lifecycle/601100_store_admin_console/
--       601120_dining_table_crud_creation/
--   Implements 601122_Logic_Dining_Table_Crud_Creation.md:
--     - catchmenu_store.upsert_dining_table()
--     - catchmenu_store.set_dining_table_active()
--     - catchmenu_store.get_dining_table_admin_list()
--     - message_catalog/error_codes rows for dining table admin responses
--     - explicit REVOKE/GRANT for the three new RPCs
--
-- Human decision:
--   601124_ChangeContract_Dining_Table_Crud_Creation.md §9 all five
--   approval boxes checked; §10 APPROVED (2026-07-17).
--
-- Non-goals:
--   - Do not modify existing operational table RPCs in 0048/0025/0050.
--   - Do not modify 0110/0115, including the known seat_waiting_customer()
--     crash.
--   - Do not add table_status/QR/NFC/session-runtime mutation behavior.

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('table_created', 'ko', '테이블이 생성되었습니다'),
('table_created', 'en', 'Table created'),
('table_updated', 'ko', '테이블 정보가 수정되었습니다'),
('table_updated', 'en', 'Table updated'),
('table_activated', 'ko', '테이블이 활성화되었습니다'),
('table_activated', 'en', 'Table activated'),
('table_deactivated', 'ko', '테이블이 비활성화되었습니다'),
('table_deactivated', 'en', 'Table deactivated'),
('dining_table_admin_list_loaded', 'ko', '테이블 목록이 로드되었습니다'),
('dining_table_admin_list_loaded', 'en', 'Table list loaded'),
('table_not_found', 'ko', '테이블을 찾을 수 없습니다'),
('table_not_found', 'en', 'Table not found'),
('table_code_required', 'ko', '테이블 코드는 필수입니다'),
('table_code_required', 'en', 'Table code is required'),
('table_code_duplicate', 'ko', '이미 사용 중인 테이블 코드입니다'),
('table_code_duplicate', 'en', 'Table code already in use'),
('table_has_active_session', 'ko', '진행 중인 세션이 있어 비활성화할 수 없습니다'),
('table_has_active_session', 'en', 'Cannot deactivate a table with an active session'),
('capacity_reduction_blocked_active_session', 'ko', '진행 중인 세션이 있어 정원을 줄일 수 없습니다'),
('capacity_reduction_blocked_active_session', 'en', 'Cannot reduce capacity while an active session is bound to this table'),
('dining_table_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
('dining_table_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7105, 'table_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7106, 'table_code_required',
  'STORE', 'INVALID_INPUT', 400, 'WARNING'),
(7107, 'table_code_duplicate',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7108, 'table_has_active_session',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7109, 'capacity_reduction_blocked_active_session',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7110, 'dining_table_operation_failed',
  'STORE', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;

create or replace function catchmenu_store.upsert_dining_table(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_id uuid default null,
  p_table_code text default null,
  p_table_name text default null,
  p_capacity int default null,
  p_floor_zone text default null,
  p_table_section text default null,
  p_display_order int default null,
  p_kds_device_id uuid default null,
  p_did_device_id uuid default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_audit, catchmenu_pos, catchmenu_hq
as $$
declare
  v_existing record;
  v_table_id uuid;
  v_is_new boolean := p_table_id is null;
  v_has_active_session boolean := false;
begin
  if not v_is_new then
    select *
    into v_existing
    from catchmenu_store.dining_tables
    where id = p_table_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id
    for update;

    if v_existing.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'table_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'upsert_dining_table',
        p_details := jsonb_build_object('table_id', p_table_id)
      );
    end if;

    v_has_active_session :=
      v_existing.current_session_id is not null
      and exists (
        select 1
        from catchmenu_pos.order_sessions os
        where os.id = v_existing.current_session_id
          and os.tenant_id = p_tenant_id
          and os.store_id = p_store_id
          and os.session_status not in (
            'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
          )
      );
  end if;

  if v_is_new and p_table_code is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_code_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_dining_table'
    );
  end if;

  if p_table_code is not null and exists (
    select 1
    from catchmenu_store.dining_tables dt
    where dt.tenant_id = p_tenant_id
      and dt.store_id = p_store_id
      and dt.table_code = p_table_code
      and (p_table_id is null or dt.id <> p_table_id)
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_code_duplicate',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_dining_table',
      p_details := jsonb_build_object('table_code', p_table_code)
    );
  end if;

  if not v_is_new then
    if v_has_active_session
       and p_capacity is not null
       and p_capacity < v_existing.capacity
    then
      return catchmenu_common.build_error_response(
        p_error_key := 'capacity_reduction_blocked_active_session',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'upsert_dining_table',
        p_details := jsonb_build_object(
          'table_id', p_table_id,
          'current_capacity', v_existing.capacity,
          'requested_capacity', p_capacity
        )
      );
    end if;
  end if;

  if v_is_new then
    insert into catchmenu_store.dining_tables (
      tenant_id, store_id,
      table_code, table_name,
      capacity, floor_zone, table_section,
      display_order, kds_device_id, did_device_id
    ) values (
      p_tenant_id, p_store_id,
      p_table_code, p_table_name,
      coalesce(p_capacity, 4),
      p_floor_zone, p_table_section,
      coalesce(p_display_order, 0),
      p_kds_device_id, p_did_device_id
    )
    returning id into v_table_id;
  else
    update catchmenu_store.dining_tables
    set
      table_code = coalesce(p_table_code, catchmenu_store.dining_tables.table_code),
      table_name = coalesce(p_table_name, catchmenu_store.dining_tables.table_name),
      capacity = coalesce(p_capacity, catchmenu_store.dining_tables.capacity),
      floor_zone = coalesce(p_floor_zone, catchmenu_store.dining_tables.floor_zone),
      table_section = coalesce(p_table_section, catchmenu_store.dining_tables.table_section),
      display_order = coalesce(p_display_order, catchmenu_store.dining_tables.display_order),
      kds_device_id = coalesce(p_kds_device_id, catchmenu_store.dining_tables.kds_device_id),
      did_device_id = coalesce(p_did_device_id, catchmenu_store.dining_tables.did_device_id),
      updated_at = now()
    where id = p_table_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id;

    v_table_id := p_table_id;

    if v_has_active_session and p_table_name is distinct from v_existing.table_name then
      perform catchmenu_audit.append_audit_record(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_audit_domain := 'system',
        p_audit_type := 'dining_table_name_changed_during_active_session',
        p_audit_category := 'OPERATIONAL',
        p_actor_type := 'STAFF',
        p_actor_id := p_actor_id,
        p_subject_type := 'dining_table',
        p_subject_id := p_table_id,
        p_decision := 'COMPLETED',
        p_decision_reason := 'active_session_table_name_update',
        p_decision_payload := jsonb_build_object(
          'current_session_id', v_existing.current_session_id
        ),
        p_before_state := jsonb_build_object(
          'table_name', v_existing.table_name
        ),
        p_after_state := jsonb_build_object(
          'table_name', p_table_name
        )
      );
    end if;
  end if;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'table_id', v_table_id,
      'is_new', v_is_new
    ),
    'message_code', case
      when v_is_new then 'table_created'
      else 'table_updated'
    end
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'system',
      p_audit_type := 'dining_table_upsert_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'dining_table',
      p_subject_id := p_table_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'table_code', p_table_code
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'dining_table_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_dining_table',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

create or replace function catchmenu_store.set_dining_table_active(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_id uuid,
  p_is_active boolean,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_audit, catchmenu_pos, catchmenu_hq
as $$
declare
  v_table record;
  v_has_active_session boolean;
begin
  select id, table_code, is_active, current_session_id
  into v_table
  from catchmenu_store.dining_tables
  where id = p_table_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
  for update;

  if v_table.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'set_dining_table_active',
      p_details := jsonb_build_object('table_id', p_table_id)
    );
  end if;

  v_has_active_session :=
    v_table.current_session_id is not null
    and exists (
      select 1
      from catchmenu_pos.order_sessions os
      where os.id = v_table.current_session_id
        and os.tenant_id = p_tenant_id
        and os.store_id = p_store_id
        and os.session_status not in (
          'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
        )
    );

  if p_is_active = false and v_has_active_session then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_has_active_session',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'set_dining_table_active',
      p_details := jsonb_build_object('table_id', p_table_id)
    );
  end if;

  if v_table.is_active = p_is_active then
    return jsonb_build_object(
      'success', true,
      'data', jsonb_build_object(
        'table_id', p_table_id,
        'is_active', p_is_active
      ),
      'message_code', 'table_active_unchanged'
    );
  end if;

  update catchmenu_store.dining_tables
  set is_active = p_is_active, updated_at = now()
  where id = p_table_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'is_active', p_is_active
    ),
    'message_code', case
      when p_is_active then 'table_activated'
      else 'table_deactivated'
    end
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'system',
      p_audit_type := 'dining_table_active_toggle_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'dining_table',
      p_subject_id := p_table_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'requested_is_active', p_is_active
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'dining_table_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'set_dining_table_active',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

create or replace function catchmenu_store.get_dining_table_admin_list(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_tables jsonb;
  v_active_count int;
  v_inactive_count int;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'table_code', t.table_code,
        'table_name', t.table_name,
        'capacity', t.capacity,
        'floor_zone', t.floor_zone,
        'table_section', t.table_section,
        'display_order', t.display_order,
        'table_status', t.table_status,
        'qr_code', t.qr_code,
        'nfc_tag_id', t.nfc_tag_id,
        'kds_device_id', t.kds_device_id,
        'did_device_id', t.did_device_id,
        'is_active', t.is_active,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      )
      order by t.display_order, t.table_code
    ),
    '[]'::jsonb
  )
  into v_tables
  from catchmenu_store.dining_tables t
  where t.tenant_id = p_tenant_id
    and t.store_id = p_store_id;

  select
    count(*) filter (where is_active),
    count(*) filter (where not is_active)
  into v_active_count, v_inactive_count
  from catchmenu_store.dining_tables t
  where t.tenant_id = p_tenant_id
    and t.store_id = p_store_id;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'tables', v_tables,
      'active_count', coalesce(v_active_count, 0),
      'inactive_count', coalesce(v_inactive_count, 0)
    ),
    'message_code', 'dining_table_admin_list_loaded'
  );
end;
$$;

revoke all on function catchmenu_store.upsert_dining_table(
  uuid, uuid, uuid, text, text, int, text, text, int, uuid, uuid, uuid, text
) from public;
grant execute on function catchmenu_store.upsert_dining_table(
  uuid, uuid, uuid, text, text, int, text, text, int, uuid, uuid, uuid, text
) to authenticated;

revoke all on function catchmenu_store.set_dining_table_active(
  uuid, uuid, uuid, boolean, uuid, text
) from public;
grant execute on function catchmenu_store.set_dining_table_active(
  uuid, uuid, uuid, boolean, uuid, text
) to authenticated;

revoke all on function catchmenu_store.get_dining_table_admin_list(
  uuid, uuid, text
) from public;
grant execute on function catchmenu_store.get_dining_table_admin_list(
  uuid, uuid, text
) to authenticated;

===== BEGIN sql/migrations/0048_create_table_management_rpc.sql =====
-- 0048_create_table_management_rpc.sql
-- Purpose: Dining table management RPCs.
--          update_table_status: updates table operational status.
--          get_table_floor_map: returns floor map for staff display.
--          register_table_qr: assigns QR/NFC to table.
--          release_table: releases table after session completes.
--          특허1 core: Late Binding 테이블 관리 + QR/NFC 앵커.
-- Depends on: 0047_create_device_registry_rpc.sql
-- Creates:
--   function catchmenu_store.update_table_status(...)
--   function catchmenu_store.get_table_floor_map(...)
--   function catchmenu_store.register_table_qr(...)
--   function catchmenu_store.release_table(...)

create or replace function catchmenu_store.update_table_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_id uuid,
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
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_table record;
  v_business_day date;
  v_timezone text;
begin
  if p_new_status not in (
    'AVAILABLE', 'OCCUPIED', 'RESERVED',
    'CLEANING', 'BLOCKED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_table_status'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, table_code, table_name,
         table_status, current_session_id,
         floor_zone, capacity
  into v_table
  from catchmenu_store.dining_tables
  where id = p_table_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_table.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_not_found'
    );
  end if;

  -- guard: cannot mark AVAILABLE if session active
  if p_new_status = 'AVAILABLE'
    and v_table.current_session_id is not null
  then
    -- check if session is still active
    if exists (
      select 1
      from catchmenu_pos.order_sessions
      where id = v_table.current_session_id
        and session_status not in (
          'COMPLETED', 'CANCELLED',
          'EXPIRED', 'NO_SHOW'
        )
    ) then
      return jsonb_build_object(
        'success', false,
        'error_key', 'session_still_active',
        'session_id', v_table.current_session_id,
        'message', 'Complete or cancel session before marking table available'
      );
    end if;
  end if;

  if v_table.table_status = p_new_status then
    return jsonb_build_object(
      'success', true,
      'table_id', p_table_id,
      'table_status', p_new_status,
      'message_code', 'status_unchanged'
    );
  end if;

  -- update table status
  update catchmenu_store.dining_tables
  set
    table_status = p_new_status,
    current_session_id = case p_new_status
      when 'AVAILABLE' then null
      when 'CLEANING' then null
      else current_session_id
    end,
    occupied_since = case p_new_status
      when 'OCCUPIED' then coalesce(occupied_since, now())
      when 'AVAILABLE' then null
      when 'CLEANING' then null
      else occupied_since
    end,
    last_cleaned_at = case p_new_status
      when 'AVAILABLE' then now()
      else last_cleaned_at
    end,
    updated_at = now()
  where id = p_table_id;

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
    'session', 'table_status_changed', 1,
    'dining_table', p_table_id,
    v_table.table_status, p_new_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'table_code', v_table.table_code,
      'floor_zone', v_table.floor_zone,
      'reason', p_reason,
      'previous_session_id', v_table.current_session_id
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'table_id', p_table_id,
    'table_code', v_table.table_code,
    'floor_zone', v_table.floor_zone,
    'previous_status', v_table.table_status,
    'new_status', p_new_status,
    'message_code', 'table_status_updated'
  );
end;
$$;


create or replace function catchmenu_store.get_table_floor_map(
  p_tenant_id uuid,
  p_store_id uuid,
  p_floor_zone text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_pos,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_store record;
  v_tables jsonb;
  v_zone_summary jsonb;
  v_business_day date;
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

  v_business_day := (timezone(v_store.timezone, now()))::date;

  -- tables with current session info
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
        'occupied_since', t.occupied_since,
        'last_cleaned_at', t.last_cleaned_at,
        'current_session', case
          when t.current_session_id is not null
          then (
            select jsonb_build_object(
              'session_id', s.id,
              'session_status', s.session_status,
              'session_type', s.session_type,
              'guest_count', s.guest_count,
              'seated_at', s.seated_at,
              'order_id', s.order_id,
              'minutes_occupied', extract(
                epoch from (now() - s.seated_at)
              )::int / 60
            )
            from catchmenu_pos.order_sessions s
            where s.id = t.current_session_id
          )
          else null
        end
      )
      order by t.floor_zone, t.display_order, t.table_code
    ),
    '[]'::jsonb
  )
  into v_tables
  from catchmenu_store.dining_tables t
  where t.store_id = p_store_id
    and t.tenant_id = p_tenant_id
    and t.is_active = true
    and (
      p_floor_zone is null
      or t.floor_zone = p_floor_zone
    );

  -- zone-level summary
  select coalesce(
    jsonb_object_agg(
      coalesce(floor_zone, 'DEFAULT'),
      jsonb_build_object(
        'total', count(*),
        'available', count(*) filter (
          where table_status = 'AVAILABLE'
        ),
        'occupied', count(*) filter (
          where table_status = 'OCCUPIED'
        ),
        'reserved', count(*) filter (
          where table_status = 'RESERVED'
        ),
        'cleaning', count(*) filter (
          where table_status = 'CLEANING'
        ),
        'blocked', count(*) filter (
          where table_status = 'BLOCKED'
        ),
        'total_capacity', sum(capacity),
        'available_capacity', sum(capacity) filter (
          where table_status = 'AVAILABLE'
        )
      )
    ),
    '{}'::jsonb
  )
  into v_zone_summary
  from catchmenu_store.dining_tables
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  group by floor_zone;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'floor_zone_filter', p_floor_zone,
    'tables', v_tables,
    'zone_summary', v_zone_summary,
    'table_count', jsonb_array_length(v_tables),
    'business_day', v_business_day,
    'refreshed_at', now(),
    'message_code', 'floor_map_loaded'
  );
end;
$$;


create or replace function catchmenu_store.register_table_qr(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_id uuid,
  p_qr_code text default null,
  p_nfc_tag_id text default null,
  p_actor_type text default 'MANAGER',
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
  v_table record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_qr_code is null and p_nfc_tag_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'qr_or_nfc_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, table_code, table_name,
         floor_zone, qr_code, nfc_tag_id
  into v_table
  from catchmenu_store.dining_tables
  where id = p_table_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_table.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_not_found'
    );
  end if;

  -- check QR uniqueness within store
  if p_qr_code is not null and exists (
    select 1
    from catchmenu_store.dining_tables
    where store_id = p_store_id
      and qr_code = p_qr_code
      and id <> p_table_id
      and is_active = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'qr_code_already_assigned',
      'qr_code', p_qr_code
    );
  end if;

  -- check NFC uniqueness within store
  if p_nfc_tag_id is not null and exists (
    select 1
    from catchmenu_store.dining_tables
    where store_id = p_store_id
      and nfc_tag_id = p_nfc_tag_id
      and id <> p_table_id
      and is_active = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'nfc_tag_already_assigned',
      'nfc_tag_id', p_nfc_tag_id
    );
  end if;

  -- update QR/NFC
  update catchmenu_store.dining_tables
  set
    qr_code = coalesce(p_qr_code, qr_code),
    nfc_tag_id = coalesce(p_nfc_tag_id, nfc_tag_id),
    updated_at = now()
  where id = p_table_id;

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
    'session', 'table_qr_registered', 1,
    'dining_table', p_table_id,
    null, 'QR_REGISTERED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'table_code', v_table.table_code,
      'qr_code', p_qr_code,
      'nfc_tag_id', p_nfc_tag_id,
      'previous_qr', v_table.qr_code,
      'previous_nfc', v_table.nfc_tag_id
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit for QR registration
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'security',
    p_audit_type := 'table_qr_registered',
    p_audit_category := 'SECURITY',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'dining_table',
    p_subject_id := p_table_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'table_code', v_table.table_code,
      'qr_code', p_qr_code,
      'nfc_tag_id', p_nfc_tag_id
    ),
    p_before_state := jsonb_build_object(
      'qr_code', v_table.qr_code,
      'nfc_tag_id', v_table.nfc_tag_id
    ),
    p_after_state := jsonb_build_object(
      'qr_code', coalesce(p_qr_code, v_table.qr_code),
      'nfc_tag_id', coalesce(
        p_nfc_tag_id, v_table.nfc_tag_id
      )
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'table_id', p_table_id,
    'table_code', v_table.table_code,
    'qr_code', coalesce(p_qr_code, v_table.qr_code),
    'nfc_tag_id', coalesce(
      p_nfc_tag_id, v_table.nfc_tag_id
    ),
    'audit_id', v_audit_id,
    'message_code', 'table_qr_registered'
  );
end;
$$;


create or replace function catchmenu_store.release_table(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_id uuid,
  p_release_reason text default 'SESSION_COMPLETED',
  p_set_cleaning boolean default true,
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
  v_table record;
  v_session record;
  v_new_status text;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, table_code, table_status,
         floor_zone, current_session_id,
         occupied_since
  into v_table
  from catchmenu_store.dining_tables
  where id = p_table_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_table.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_not_found'
    );
  end if;

  if v_table.table_status = 'AVAILABLE' then
    return jsonb_build_object(
      'success', true,
      'table_id', p_table_id,
      'table_status', 'AVAILABLE',
      'message_code', 'table_already_available'
    );
  end if;

  -- get session occupation duration
  if v_table.current_session_id is not null then
    select id, session_status,
           session_started_at, seated_at
    into v_session
    from catchmenu_pos.order_sessions
    where id = v_table.current_session_id;
  end if;

  v_new_status := case
    when p_set_cleaning then 'CLEANING'
    else 'AVAILABLE'
  end;

  -- release table
  update catchmenu_store.dining_tables
  set
    table_status = v_new_status,
    current_session_id = null,
    occupied_since = null,
    last_cleaned_at = case
      when not p_set_cleaning then now()
      else last_cleaned_at
    end,
    updated_at = now()
  where id = p_table_id;

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
    'session', 'table_released', 1,
    'dining_table', p_table_id,
    v_table.table_status, v_new_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'table_code', v_table.table_code,
      'floor_zone', v_table.floor_zone,
      'release_reason', p_release_reason,
      'previous_session_id', v_table.current_session_id,
      'occupied_since', v_table.occupied_since,
      'occupation_minutes', case
        when v_table.occupied_since is not null
        then extract(
          epoch from (now() - v_table.occupied_since)
        )::int / 60
        else null
      end
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'table_id', p_table_id,
    'table_code', v_table.table_code,
    'floor_zone', v_table.floor_zone,
    'previous_status', v_table.table_status,
    'new_status', v_new_status,
    'release_reason', p_release_reason,
    'previous_session_id', v_table.current_session_id,
    'occupation_minutes', case
      when v_table.occupied_since is not null
      then extract(
        epoch from (now() - v_table.occupied_since)
      )::int / 60
      else null
    end,
    'set_cleaning', p_set_cleaning,
    'message_code', case v_new_status
      when 'CLEANING' then 'table_released_to_cleaning'
      else 'table_released_to_available'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.update_table_status(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.update_table_status(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.get_table_floor_map(
    uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_store.get_table_floor_map(
    uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.register_table_qr(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.register_table_qr(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.release_table(
    uuid, uuid, uuid, text, boolean, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.release_table(
    uuid, uuid, uuid, text, boolean, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.update_table_status(
  uuid, uuid, uuid, text, text, text, uuid, text
) is
  'Updates dining table operational status.
   Guards against marking AVAILABLE when active session exists.
   Tracks occupation time for table turnover KPI.
   특허1: 테이블 상태 관리 — Late Binding 이후 테이블 점유/해제 추적.';

comment on function catchmenu_store.get_table_floor_map(
  uuid, uuid, text
) is
  'Returns floor map with current session info per table.
   Includes zone-level summary for staff dashboard.
   Shows occupation duration in minutes.
   Used by staff tablet and POS table selection screen.
   특허1: 실시간 테이블 현황 — Late Binding 후 테이블 매칭 확인용.';

comment on function catchmenu_store.register_table_qr(
  uuid, uuid, uuid, text, text, text, uuid, text
) is
  'Assigns QR code or NFC tag ID to a dining table.
   QR and NFC must be unique within store.
   QR/NFC registration is a SECURITY audit event.
   특허1: QR/NFC = 고객 단말과 테이블을 연결하는 물리적 앵커.
   대기 세션이 QR/NFC를 스캔하면 Late Binding이 시작됨.';

comment on function catchmenu_store.release_table(
  uuid, uuid, uuid, text, boolean, text, uuid, text
) is
  'Releases table after session completion.
   Default: sets CLEANING status for hygiene tracking.
   Records occupation duration for table turnover analysis.
   특허2: 테이블 해제 → 회전율 KPI 데이터 생성.
   특허3: 회전율 데이터 → AI Agent 테이블 배정 최적화 추천.';

