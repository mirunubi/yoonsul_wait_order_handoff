-- 0047_create_device_registry_rpc.sql
-- Purpose: Device registry management RPCs.
--          register_device: registers new device with UNTRUSTED status.
--          trust_device: elevates device trust level after verification.
--          update_device_status: updates operational status.
--          get_store_devices: returns all devices for a store.
--          특허4 core: Zero Trust 디바이스 등록 + 신뢰 레벨 관리.
-- Depends on: 0046_create_context_builder_rpc.sql
-- Creates:
--   function catchmenu_store.register_device(...)
--   function catchmenu_store.trust_device(...)
--   function catchmenu_store.update_device_status(...)
--   function catchmenu_store.get_store_devices(...)

create or replace function catchmenu_store.register_device(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_code text,
  p_device_name text,
  p_device_type text,
  p_device_role text default 'PRIMARY',
  p_os_type text default null,
  p_os_version text default null,
  p_app_version text default null,
  p_ip_address text default null,
  p_mac_address text default null,
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
  v_device_id uuid;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
begin
  -- validate device type
  if p_device_type not in (
    'POS', 'KDS', 'KIOSK', 'DID', 'CMS',
    'TABLET', 'AGENT_SERVER', 'PRINTER',
    'PAYMENT_TERMINAL', 'SENSOR', 'ROBOT', 'OTHER'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_device_type'
    );
  end if;

  if trim(coalesce(p_device_code, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_code_required'
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- check duplicate
  if exists (
    select 1
    from catchmenu_store.device_registry
    where store_id = p_store_id
      and device_code = p_device_code
      and is_active = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_code_already_exists',
      'device_code', p_device_code
    );
  end if;

  -- register device with UNTRUSTED status
  -- 특허4: Zero Trust — 모든 디바이스는 UNTRUSTED로 시작
  insert into catchmenu_store.device_registry (
    tenant_id, store_id,
    device_code, device_name,
    device_type, device_role,
    os_type, os_version, app_version,
    ip_address, mac_address,
    trust_level, device_status,
    registered_at, is_active
  ) values (
    p_tenant_id, p_store_id,
    p_device_code, p_device_name,
    p_device_type, p_device_role,
    p_os_type, p_os_version, p_app_version,
    p_ip_address, p_mac_address,
    'UNTRUSTED', 'OFFLINE',
    now(), true
  )
  returning id into v_device_id;

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
    'device', 'device_registered', 1,
    'device', v_device_id,
    null, 'UNTRUSTED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'device_code', p_device_code,
      'device_type', p_device_type,
      'device_role', p_device_role,
      'ip_address', p_ip_address,
      'mac_address', p_mac_address
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit for device registration
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'device',
    p_audit_type := 'device_registered',
    p_audit_category := 'SECURITY',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'device',
    p_subject_id := v_device_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'device_code', p_device_code,
      'device_type', p_device_type,
      'trust_level', 'UNTRUSTED',
      'ip_address', p_ip_address,
      'mac_address', p_mac_address
    ),
    p_after_state := jsonb_build_object(
      'trust_level', 'UNTRUSTED',
      'device_status', 'OFFLINE'
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'device_id', v_device_id,
    'device_code', p_device_code,
    'device_type', p_device_type,
    'trust_level', 'UNTRUSTED',
    'device_status', 'OFFLINE',
    'next_step', 'TRUST_VERIFICATION_REQUIRED',
    'audit_id', v_audit_id,
    'message_code', 'device_registered_pending_trust'
  );
end;
$$;


create or replace function catchmenu_store.trust_device(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_new_trust_level text,
  p_trust_reason text,
  p_actor_type text,
  p_actor_id uuid,
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
  v_device record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_new_trust_level not in (
    'PENDING', 'TRUSTED', 'SUSPENDED', 'REVOKED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_trust_level',
      'allowed', array[
        'PENDING', 'TRUSTED', 'SUSPENDED', 'REVOKED'
      ]
    );
  end if;

  if trim(coalesce(p_trust_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'trust_reason_required'
    );
  end if;

  -- manager or above required for trust changes
  if p_actor_type not in (
    'MANAGER', 'OWNER', 'HQ_ADMIN', 'SYSTEM'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'insufficient_authority',
      'required_role', 'MANAGER or above'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, device_code, device_name,
         device_type, trust_level, device_status
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_not_found'
    );
  end if;

  if v_device.trust_level = p_new_trust_level then
    return jsonb_build_object(
      'success', false,
      'error_key', 'trust_level_unchanged',
      'current_trust_level', p_new_trust_level
    );
  end if;

  -- update trust level
  update catchmenu_store.device_registry
  set
    trust_level = p_new_trust_level,
    device_status = case p_new_trust_level
      when 'REVOKED' then 'FAILED'
      when 'SUSPENDED' then 'MAINTENANCE'
      else device_status
    end,
    updated_at = now()
  where id = p_device_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'device', case p_new_trust_level
      when 'TRUSTED' then 'device_trust_granted'
      when 'REVOKED' then 'device_trust_revoked'
      when 'SUSPENDED' then 'device_trust_suspended'
      else 'device_trust_changed'
    end,
    1,
    'device', p_device_id,
    v_device.trust_level, p_new_trust_level,
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'device_code', v_device.device_code,
      'device_type', v_device.device_type,
      'trust_reason', p_trust_reason
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- exception for REVOKED
  if p_new_trust_level = 'REVOKED' then
    perform catchmenu_ledger.create_exception(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_exception_domain := 'device',
      p_exception_type := 'device_trust_revoked',
      p_exception_severity := 'CRITICAL',
      p_subject_type := 'device',
      p_subject_id := p_device_id,
      p_error_message := p_trust_reason,
      p_exception_payload := jsonb_build_object(
        'device_code', v_device.device_code,
        'device_type', v_device.device_type
      ),
      p_requires_human_approval := true,
      p_correlation_id := p_correlation_id
    );
  end if;

  -- audit (always for trust changes — security category)
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'security',
    p_audit_type := 'device_trust_changed',
    p_audit_category := 'SECURITY',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'device',
    p_subject_id := p_device_id,
    p_decision := case p_new_trust_level
      when 'TRUSTED' then 'APPROVED'
      when 'REVOKED' then 'REVOKED'
      when 'SUSPENDED' then 'SUSPENDED'
      else 'NOTED'
    end,
    p_decision_reason := p_trust_reason,
    p_decision_payload := jsonb_build_object(
      'device_code', v_device.device_code,
      'device_type', v_device.device_type,
      'previous_trust_level', v_device.trust_level,
      'new_trust_level', p_new_trust_level
    ),
    p_before_state := jsonb_build_object(
      'trust_level', v_device.trust_level
    ),
    p_after_state := jsonb_build_object(
      'trust_level', p_new_trust_level
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'device_id', p_device_id,
    'device_code', v_device.device_code,
    'device_type', v_device.device_type,
    'previous_trust_level', v_device.trust_level,
    'new_trust_level', p_new_trust_level,
    'trust_reason', p_trust_reason,
    'audit_id', v_audit_id,
    'message_code', case p_new_trust_level
      when 'TRUSTED' then 'device_trust_granted'
      when 'REVOKED' then 'device_trust_revoked'
      when 'SUSPENDED' then 'device_trust_suspended'
      else 'device_trust_updated'
    end
  );
end;
$$;


create or replace function catchmenu_store.update_device_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_new_status text,
  p_reason text default null,
  p_app_version text default null,
  p_ip_address text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_device record;
  v_recovered boolean := false;
  v_business_day date;
  v_timezone text;
begin
  if p_new_status not in (
    'ONLINE', 'OFFLINE', 'DEGRADED',
    'MAINTENANCE', 'FAILED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_device_status'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, device_code, device_type,
         device_status, trust_level
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_not_found'
    );
  end if;

  -- block ONLINE for UNTRUSTED/REVOKED devices
  if p_new_status = 'ONLINE'
    and v_device.trust_level in ('UNTRUSTED', 'REVOKED')
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_not_trusted',
      'trust_level', v_device.trust_level,
      'message', 'Device must be TRUSTED before going ONLINE'
    );
  end if;

  if v_device.device_status in ('DEGRADED', 'FAILED', 'OFFLINE')
    and p_new_status = 'ONLINE'
  then
    v_recovered := true;
  end if;

  -- update device
  update catchmenu_store.device_registry
  set
    device_status = p_new_status,
    last_seen_at = now(),
    last_heartbeat_at = case
      when p_new_status = 'ONLINE' then now()
      else last_heartbeat_at
    end,
    app_version = coalesce(p_app_version, app_version),
    ip_address = coalesce(p_ip_address, ip_address),
    updated_at = now()
  where id = p_device_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_device_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'device', case p_new_status
      when 'ONLINE' then 'device_online'
      when 'OFFLINE' then 'device_offline'
      when 'FAILED' then 'device_failed'
      when 'DEGRADED' then 'device_degraded'
      else 'device_status_changed'
    end,
    1,
    'device', p_device_id,
    v_device.device_status, p_new_status,
    'SYSTEM', p_device_id,
    jsonb_build_object(
      'device_code', v_device.device_code,
      'device_type', v_device.device_type,
      'reason', p_reason,
      'recovered', v_recovered,
      'app_version', p_app_version
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- create exception for FAILED devices
  if p_new_status = 'FAILED' then
    perform catchmenu_ledger.create_exception(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_exception_domain := case v_device.device_type
        when 'POS' then 'pos'
        when 'KDS' then 'kds'
        when 'KIOSK' then 'kiosk'
        else 'device'
      end,
      p_exception_type := lower(v_device.device_type)
        || '_offline',
      p_exception_severity := 'ERROR',
      p_subject_type := 'device',
      p_subject_id := p_device_id,
      p_error_message := coalesce(
        p_reason, v_device.device_type || ' device failed'
      ),
      p_triggered_by_device_id := p_device_id,
      p_exception_payload := jsonb_build_object(
        'device_code', v_device.device_code,
        'device_type', v_device.device_type
      ),
      p_requires_human_approval := false,
      p_correlation_id := p_correlation_id
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'device_id', p_device_id,
    'device_code', v_device.device_code,
    'device_type', v_device.device_type,
    'previous_status', v_device.device_status,
    'new_status', p_new_status,
    'recovered', v_recovered,
    'message_code', case
      when v_recovered then 'device_recovered'
      else 'device_status_updated'
    end
  );
end;
$$;


create or replace function catchmenu_store.get_store_devices(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_type text default null,
  p_include_inactive boolean default false
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_devices jsonb;
  v_summary jsonb;
begin
  select id, store_name
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

  -- device list
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', d.id,
        'device_code', d.device_code,
        'device_name', d.device_name,
        'device_type', d.device_type,
        'device_role', d.device_role,
        'trust_level', d.trust_level,
        'device_status', d.device_status,
        'os_type', d.os_type,
        'os_version', d.os_version,
        'app_version', d.app_version,
        'ip_address', d.ip_address,
        'last_seen_at', d.last_seen_at,
        'last_heartbeat_at', d.last_heartbeat_at,
        'registered_at', d.registered_at,
        'is_active', d.is_active
      )
      order by d.device_type, d.device_code
    ),
    '[]'::jsonb
  )
  into v_devices
  from catchmenu_store.device_registry d
  where d.store_id = p_store_id
    and d.tenant_id = p_tenant_id
    and (
      p_include_inactive = true
      or d.is_active = true
    )
    and (
      p_device_type is null
      or d.device_type = p_device_type
    );

  -- summary by type and status
  select jsonb_build_object(
    'total', count(*),
    'online', count(*) filter (
      where device_status = 'ONLINE'
    ),
    'offline', count(*) filter (
      where device_status = 'OFFLINE'
    ),
    'degraded', count(*) filter (
      where device_status = 'DEGRADED'
    ),
    'failed', count(*) filter (
      where device_status = 'FAILED'
    ),
    'trusted', count(*) filter (
      where trust_level = 'TRUSTED'
    ),
    'untrusted', count(*) filter (
      where trust_level = 'UNTRUSTED'
    ),
    'revoked', count(*) filter (
      where trust_level = 'REVOKED'
    )
  )
  into v_summary
  from catchmenu_store.device_registry
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'devices', v_devices,
    'summary', v_summary,
    'device_count', jsonb_array_length(v_devices),
    'message_code', 'store_devices_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.register_device(
    uuid, uuid, text, text, text, text,
    text, text, text, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.register_device(
    uuid, uuid, text, text, text, text,
    text, text, text, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.trust_device(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.trust_device(
    uuid, uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.update_device_status(
    uuid, uuid, uuid, text, text, text, text, text
  ) from public;
  grant execute on function catchmenu_store.update_device_status(
    uuid, uuid, uuid, text, text, text, text, text
  ) to authenticated;

  revoke all on function catchmenu_store.get_store_devices(
    uuid, uuid, text, boolean
  ) from public;
  grant execute on function catchmenu_store.get_store_devices(
    uuid, uuid, text, boolean
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.register_device(
  uuid, uuid, text, text, text, text,
  text, text, text, text, text, text, uuid, text
) is
  'Registers new device with UNTRUSTED status.
   All devices start UNTRUSTED regardless of who registers them.
   trust_device() must be called by MANAGER+ to elevate trust.
   특허4 Zero Trust 원칙:
   등록된 디바이스는 신뢰 검증 전까지 UNTRUSTED.
   UNTRUSTED 디바이스는 ONLINE 상태가 될 수 없음.';

comment on function catchmenu_store.trust_device(
  uuid, uuid, uuid, text, text, text, uuid, text
) is
  'Elevates device trust level. Requires MANAGER or above.
   Trust changes are SECURITY category audit events.
   REVOKED: device is permanently blocked, exception created.
   SUSPENDED: device temporarily blocked.
   TRUSTED: device allowed to operate.
   특허4: 디바이스 신뢰 레벨 변경 = 보안 감사 이벤트.
   모든 신뢰 변경은 감사 원장에 기록.';

comment on function catchmenu_store.update_device_status(
  uuid, uuid, uuid, text, text, text, text, text
) is
  'Updates device operational status.
   ONLINE blocked for UNTRUSTED/REVOKED devices.
   FAILED status automatically creates exception in ledger.
   Recovery from FAILED/DEGRADED logged as recovery event.
   특허4: 디바이스 장애 → Exception 원장 자동 생성
          → Fault Detection Agent 탐지 → SOP 추천.';