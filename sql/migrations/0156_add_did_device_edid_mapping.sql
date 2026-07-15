-- Migration: 0156_add_did_device_edid_mapping.sql
-- Purpose:
--   Add EDID-based physical display identity fields to catchmenu_store.did_devices
--   and create the Stage-A registry RPCs needed by the CMS/DID device routing
--   architecture.
--
-- Background:
--   601010_cms_device_content_routing_architecture confirmed that physical DID
--   and signage devices should be identified by EDID rather than by fixed port
--   number. The chosen Option 3 keeps the existing device_registry and
--   update_did_display() behavior untouched, while adding a new lightweight
--   lookup/reporting layer on top of did_devices.
--
-- Human decision:
--   2026-07-15 Human Boundary Approval approved:
--   - four nullable did_devices columns;
--   - get_did_device_by_edid();
--   - report_did_device_edid_scan();
--   - no changes to 0043_create_did_display_rpc.sql.
--
-- Depends on:
--   0155_drop_get_did_display_state_legacy_overload.sql
--
-- Non-goals:
--   Does not modify 0043_create_did_display_rpc.sql.
--   Does not modify catchmenu_store.device_registry.
--   Does not implement the CMS content delivery engine.
--   Does not decide the final EDID normalization format.
--   Does not implement mismatch notification or mismatch history tracking.

alter table catchmenu_store.did_devices
  add column if not exists edid_serial text,
  add column if not exists last_detected_edid text,
  add column if not exists last_edid_check_at timestamptz,
  add column if not exists physical_position_label text;

create or replace function catchmenu_store.get_did_device_by_edid(
  p_tenant_id uuid,
  p_store_id uuid,
  p_edid_serial text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common
as $$
declare
  v_device record;
begin
  select
    id,
    did_code,
    did_name,
    device_id,
    display_mode,
    zone,
    orientation,
    resolution,
    edid_serial,
    last_detected_edid,
    last_edid_check_at,
    physical_position_label
  into v_device
  from catchmenu_store.did_devices
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and edid_serial = p_edid_serial
    and is_active = true
  order by updated_at desc, created_at desc
  limit 1;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'edid_not_registered',
      'data', jsonb_build_object(
        'edid_serial', p_edid_serial
      ),
      'meta', jsonb_build_object(
        'locale', p_locale,
        'occurred_at', now()
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'device_id', v_device.id,
      'registry_device_id', v_device.device_id,
      'did_code', v_device.did_code,
      'did_name', v_device.did_name,
      'display_mode', v_device.display_mode,
      'zone', v_device.zone,
      'orientation', v_device.orientation,
      'resolution', v_device.resolution,
      'edid_serial', v_device.edid_serial,
      'last_detected_edid', v_device.last_detected_edid,
      'last_edid_check_at', v_device.last_edid_check_at,
      'physical_position_label', v_device.physical_position_label
    ),
    'meta', jsonb_build_object(
      'locale', p_locale,
      'occurred_at', now()
    )
  );
end;
$$;

create or replace function catchmenu_store.report_did_device_edid_scan(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_detected_edid text,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_common
as $$
declare
  v_device record;
  v_is_mismatch boolean;
begin
  select
    id,
    did_code,
    did_name,
    edid_serial
  into v_device
  from catchmenu_store.did_devices
  where id = p_device_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and is_active = true
  for update;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'did_device_not_found',
      'data', jsonb_build_object(
        'device_id', p_device_id,
        'detected_edid', p_detected_edid
      ),
      'meta', jsonb_build_object(
        'correlation_id', p_correlation_id,
        'occurred_at', now()
      )
    );
  end if;

  update catchmenu_store.did_devices
  set
    last_detected_edid = p_detected_edid,
    last_edid_check_at = now(),
    updated_at = now()
  where id = v_device.id;

  v_is_mismatch := v_device.edid_serial is distinct from p_detected_edid;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'device_id', v_device.id,
      'did_code', v_device.did_code,
      'did_name', v_device.did_name,
      'edid_serial', v_device.edid_serial,
      'last_detected_edid', p_detected_edid,
      'last_edid_check_at', now(),
      'is_mismatch', v_is_mismatch
    ),
    'meta', jsonb_build_object(
      'correlation_id', p_correlation_id,
      'occurred_at', now()
    )
  );
end;
$$;

do $$
begin
  grant execute on function
    catchmenu_store.get_did_device_by_edid(
      uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.report_did_device_edid_scan(
      uuid, uuid, uuid, text, text
    ) to authenticated;
end;
$$;

comment on function catchmenu_store.get_did_device_by_edid(
  uuid, uuid, text, text
) is
  'Looks up an active DID/signage device by normalized EDID serial within tenant/store scope.';

comment on function catchmenu_store.report_did_device_edid_scan(
  uuid, uuid, uuid, text, text
) is
  'Records the latest detected EDID for a DID/signage device and returns whether it differs from the registered EDID.';
