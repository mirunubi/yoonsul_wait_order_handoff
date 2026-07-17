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
