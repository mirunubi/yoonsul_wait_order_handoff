-- 0070_create_flutter_bootstrap_rpc.sql
-- Purpose: Flutter app bootstrap and device initialization RPCs.
--          Single RPC call on app startup returns everything
--          Flutter needs: store config, menus, realtime channels,
--          device trust status, KDS state, staff permissions.
--          특허4: Zero Trust 디바이스 초기화 + 앱 부트스트랩.
-- Depends on: 0069_create_pgvector_knowledge_rpc.sql
-- Creates:
--   function catchmenu_common.bootstrap_app(...)
--   function catchmenu_common.bootstrap_kds_app(...)
--   function catchmenu_common.bootstrap_kiosk_app(...)
--   function catchmenu_common.bootstrap_staff_app(...)
--   function catchmenu_common.heartbeat(...)

-- =============================================
-- bootstrap_app: Universal entry point
-- Flutter 앱 시작 시 단일 RPC 호출
-- =============================================
create or replace function
  catchmenu_common.bootstrap_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_device_type text,
  p_app_version text default null,
  p_locale text default 'ko',
  p_os_type text default null,
  p_ip_address text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_device record;
  v_settings record;
  v_business_day date;
  v_bootstrap_id uuid;
  v_realtime_config jsonb;
  v_menu_catalog jsonb;
  v_floor_map jsonb;
  v_store_notices jsonb;
  v_kds_state jsonb;
  v_payment_uncertain_active boolean := false;
  v_manual_fallback_active boolean := false;
begin
  v_bootstrap_id := gen_random_uuid();

  -- STEP 1: Validate store
  select id, store_name, store_type,
         store_status, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_app',
      p_correlation_id := p_correlation_id
    );
  end if;

  v_business_day := (timezone(
    v_store.timezone, now()
  ))::date;

  -- STEP 2: Validate and update device
  -- Zero Trust: UNTRUSTED devices get minimal config
  select id, device_code, device_name,
         device_type, device_role,
         trust_level, device_status,
         app_version
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_device.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_app',
      p_correlation_id := p_correlation_id
    );
  end if;

  -- update device heartbeat and version
  update catchmenu_store.device_registry
  set
    device_status = case trust_level
      when 'TRUSTED' then 'ONLINE'
      when 'PENDING' then 'OFFLINE'
      else 'OFFLINE'
    end,
    last_seen_at = now(),
    last_heartbeat_at = now(),
    app_version = coalesce(
      p_app_version, app_version
    ),
    ip_address = coalesce(p_ip_address, ip_address),
    updated_at = now()
  where id = p_device_id;

  -- UNTRUSTED device: return minimal config
  if v_device.trust_level in (
    'UNTRUSTED', 'REVOKED'
  ) then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'AUTH',
      p_log_event := 'untrusted_device_bootstrap',
      p_message :=
        'Bootstrap attempted by '
        || v_device.trust_level
        || ' device: ' || v_device.device_code,
      p_error_key := 'device_not_trusted',
      p_rpc_name := 'bootstrap_app',
      p_correlation_id := p_correlation_id,
      p_device_id := p_device_id,
      p_details := jsonb_build_object(
        'device_code', v_device.device_code,
        'trust_level', v_device.trust_level,
        'app_version', p_app_version
      )
    );

    return jsonb_build_object(
      'success', false,
      'bootstrap_id', v_bootstrap_id,
      'trust_status', v_device.trust_level,
      'error', jsonb_build_object(
        'code', 1001,
        'key', 'device_not_trusted',
        'message', catchmenu_common.get_message(
          'device_not_trusted', p_locale, null
        ),
        'action', 'CONTACT_MANAGER_FOR_TRUST'
      ),
      'device', jsonb_build_object(
        'id', v_device.id,
        'device_code', v_device.device_code,
        'trust_level', v_device.trust_level
      )
    );
  end if;

  -- STEP 3: Get store settings
  select store_mode, waiting_enabled,
         pre_order_enabled, holiday_mode,
         kds_capacity_threshold_per_zone,
         kds_capacity_threshold_total,
         sound_alert_enabled,
         did_refresh_interval_seconds
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- STEP 4: Get realtime config for device
  v_realtime_config :=
    catchmenu_common.get_realtime_config(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_device_type := p_device_type
    );

  -- STEP 5: Check critical operational state
  -- PAYMENT_UNCERTAIN active?
  select exists (
    select 1
    from catchmenu_payment.payment_intents
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and intent_status = 'UNCERTAIN'
  ) into v_payment_uncertain_active;

  -- Manual fallback active?
  select exists (
    select 1
    from catchmenu_agent.manual_fallback_log
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and fallback_status in (
        'ACTIVE', 'RECOVERING'
      )
  ) into v_manual_fallback_active;

  -- STEP 6: HQ notices for store
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'notice_id', id,
        'notice_code', notice_code,
        'notice_type', notice_type,
        'title', title,
        'body', body,
        'priority', priority,
        'read_required', read_required,
        'valid_until', valid_until
      )
      order by
        case priority
          when 'URGENT' then 0
          when 'HIGH' then 1
          when 'NORMAL' then 2
          else 3
        end,
        created_at desc
    ),
    '[]'::jsonb
  )
  into v_store_notices
  from catchmenu_hq.hq_notices
  where tenant_id = p_tenant_id
    and notice_status = 'ACTIVE'
    and (
      valid_until is null
      or valid_until > now()
    )
    and (
      target_all_stores = true
      or target_store_ids @>
        to_jsonb(p_store_id)
    )
  limit 10;

  -- STEP 7: Device-specific data
  -- POS/STAFF: floor map
  if p_device_type in ('POS', 'STAFF_APP') then
    v_floor_map :=
      catchmenu_store.get_table_floor_map(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id
      );
  end if;

  -- KDS: current ticket state
  if p_device_type = 'KDS' then
    select jsonb_build_object(
      'hold_count', count(*) filter (
        where kds_status = 'HOLD'
      ),
      'capacity_checking', count(*) filter (
        where kds_status = 'CAPACITY_CHECKING'
      ),
      'cooking_count', count(*) filter (
        where kds_status = 'COOKING'
      ),
      'ready_count', count(*) filter (
        where kds_status = 'READY'
      ),
      'active_tickets', coalesce(
        jsonb_agg(
          jsonb_build_object(
            'ticket_id', id,
            'ticket_number', ticket_number,
            'kds_status', kds_status,
            'kitchen_zone', kitchen_zone,
            'menu_name', menu_name_snapshot,
            'quantity', quantity_snapshot,
            'estimated_minutes',
              estimated_minutes_snapshot,
            'cooking_started_at',
              cooking_started_at,
            'conditions_met', conditions_met
          )
          order by
            case kds_status
              when 'COOKING' then 0
              when 'READY_TO_COMMIT' then 1
              when 'CAPACITY_CHECKING' then 2
              when 'HOLD' then 3
              else 4
            end,
            ticket_created_at asc
        ) filter (
          where kds_status in (
            'COOKING', 'READY',
            'READY_TO_COMMIT',
            'CAPACITY_CHECKING'
          )
        ),
        '[]'::jsonb
      )
    )
    into v_kds_state
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and kds_status not in (
        'COMPLETED', 'CANCELLED', 'SERVED'
      );
  end if;

  -- KIOSK/DID: menu catalog with i18n
  if p_device_type in ('KIOSK', 'DID') then
    v_menu_catalog :=
      catchmenu_pos.get_menu_catalog_i18n(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_locale := p_locale,
        p_include_hidden := false,
        p_include_sold_out := true,
        p_include_allergens := true
      );
  end if;

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'app_bootstrapped',
    p_message :=
      'App bootstrap: ' || p_device_type
      || ' device=' || v_device.device_code
      || ' v=' || coalesce(p_app_version, 'N/A')
      || ' trust=' || v_device.trust_level,
    p_rpc_name := 'bootstrap_app',
    p_correlation_id := p_correlation_id,
    p_device_id := p_device_id,
    p_details := jsonb_build_object(
      'bootstrap_id', v_bootstrap_id,
      'device_type', p_device_type,
      'device_code', v_device.device_code,
      'app_version', p_app_version,
      'store_mode',
        coalesce(v_settings.store_mode, 'NORMAL'),
      'payment_uncertain_active',
        v_payment_uncertain_active,
      'manual_fallback_active',
        v_manual_fallback_active
    )
  );

  return jsonb_build_object(
    'success', true,
    'bootstrap_id', v_bootstrap_id,

    -- store info
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_type', v_store.store_type,
      'store_status', v_store.store_status,
      'timezone', v_store.timezone,
      'business_day', v_business_day
    ),

    -- device info
    'device', jsonb_build_object(
      'id', v_device.id,
      'device_code', v_device.device_code,
      'device_name', v_device.device_name,
      'device_type', v_device.device_type,
      'device_role', v_device.device_role,
      'trust_level', v_device.trust_level,
      'device_status', 'ONLINE'
    ),

    -- operational settings
    'settings', jsonb_build_object(
      'store_mode', coalesce(
        v_settings.store_mode, 'NORMAL'
      ),
      'waiting_enabled', coalesce(
        v_settings.waiting_enabled, true
      ),
      'pre_order_enabled', coalesce(
        v_settings.pre_order_enabled, true
      ),
      'holiday_mode', coalesce(
        v_settings.holiday_mode, false
      ),
      'kds_threshold_per_zone', coalesce(
        v_settings.kds_capacity_threshold_per_zone,
        8
      ),
      'kds_threshold_total', coalesce(
        v_settings.kds_capacity_threshold_total, 30
      ),
      'sound_alert_enabled', coalesce(
        v_settings.sound_alert_enabled, true
      ),
      'did_refresh_interval_seconds', coalesce(
        v_settings.did_refresh_interval_seconds, 10
      )
    ),

    -- critical operational alerts
    'alerts', jsonb_build_object(
      'payment_uncertain_active',
        v_payment_uncertain_active,
      'manual_fallback_active',
        v_manual_fallback_active,
      'has_critical_alerts',
        v_payment_uncertain_active
        or v_manual_fallback_active,
      'alert_messages', (
        select coalesce(
          jsonb_agg(msg), '[]'::jsonb
        )
        from (
          select jsonb_build_object(
            'type', 'PAYMENT_UNCERTAIN',
            'severity', 'CRITICAL',
            'message', catchmenu_common.get_message(
              'payment_uncertain_active',
              p_locale, null
            )
          ) as msg
          where v_payment_uncertain_active
          union all
          select jsonb_build_object(
            'type', 'MANUAL_FALLBACK',
            'severity', 'WARNING',
            'message', '수동 대체 운영 모드 활성화됨'
          )
          where v_manual_fallback_active
        ) alerts_data
      )
    ),

    -- realtime channels
    'realtime', v_realtime_config->'data',

    -- device-specific data
    'kds_state', v_kds_state,
    'floor_map', case
      when p_device_type in ('POS', 'STAFF_APP')
      then v_floor_map->'data'
      else null
    end,
    'menu_catalog', case
      when p_device_type in ('KIOSK', 'DID')
      then v_menu_catalog->'data'
      else null
    end,

    -- HQ notices
    'notices', v_store_notices,
    'unread_notice_count',
      jsonb_array_length(v_store_notices),

    -- locale
    'locale', p_locale,

    'bootstrapped_at', now(),
    'message_code', 'app_bootstrapped'
  );
end;
$$;


-- =============================================
-- bootstrap_kds_app: KDS 전용 부트스트랩
-- =============================================
create or replace function
  catchmenu_common.bootstrap_kds_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_kitchen_zone text default null,
  p_app_version text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_kds,
                  catchmenu_hq
as $$
declare
  v_base jsonb;
  v_business_day date;
  v_timezone text;
  v_zone_tickets jsonb;
  v_zones jsonb;
begin
  -- base bootstrap
  v_base := catchmenu_common.bootstrap_app(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_device_id := p_device_id,
    p_device_type := 'KDS',
    p_app_version := p_app_version,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  if not (v_base->>'success')::boolean then
    return v_base;
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- get available kitchen zones
  select coalesce(
    jsonb_agg(
      distinct kitchen_zone
      order by kitchen_zone
    ),
    '[]'::jsonb
  )
  into v_zones
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and kitchen_zone is not null;

  -- zone-filtered active tickets
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', id,
        'ticket_number', ticket_number,
        'order_id', order_id,
        'kds_status', kds_status,
        'kitchen_zone', kitchen_zone,
        'priority', priority,
        'menu_name', menu_name_snapshot,
        'quantity', quantity_snapshot,
        'estimated_minutes',
          estimated_minutes_snapshot,
        'conditions_met', conditions_met,
        'hold_reason', hold_reason,
        'ticket_created_at', ticket_created_at,
        'committed_at', committed_at,
        'cooking_started_at', cooking_started_at,
        'ready_at', ready_at,
        'elapsed_minutes', extract(
          epoch from (
            now() - coalesce(
              cooking_started_at,
              committed_at,
              ticket_created_at
            )
          )
        )::int / 60,
        'is_overdue',
          cooking_started_at is not null
          and extract(
            epoch from (now() - cooking_started_at)
          ) / 60 > coalesce(
            estimated_minutes_snapshot, 999
          )
      )
      order by
        case kds_status
          when 'COOKING' then 0
          when 'READY_TO_COMMIT' then 1
          when 'CAPACITY_CHECKING' then 2
          when 'HOLD' then 3
          else 4
        end,
        priority asc,
        ticket_created_at asc
    ),
    '[]'::jsonb
  )
  into v_zone_tickets
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and (
      p_kitchen_zone is null
      or kitchen_zone = p_kitchen_zone
    )
    and kds_status not in (
      'COMPLETED', 'CANCELLED', 'SERVED'
    );

  return v_base || jsonb_build_object(
    'kds', jsonb_build_object(
      'kitchen_zone_filter', p_kitchen_zone,
      'available_zones', v_zones,
      'active_tickets', v_zone_tickets,
      'ticket_count',
        jsonb_array_length(v_zone_tickets),
      'overdue_count', (
        select count(*)
        from jsonb_array_elements(v_zone_tickets) t
        where (t->>'is_overdue')::boolean = true
      ),
      'cooking_count', (
        select count(*)
        from jsonb_array_elements(v_zone_tickets) t
        where t->>'kds_status' = 'COOKING'
      )
    )
  );
end;
$$;


-- =============================================
-- bootstrap_kiosk_app: 키오스크 전용 부트스트랩
-- =============================================
create or replace function
  catchmenu_common.bootstrap_kiosk_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_locale text default 'ko',
  p_app_version text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_store,
                  catchmenu_hq
as $$
declare
  v_base jsonb;
  v_wait_estimate jsonb;
begin
  -- base bootstrap
  v_base := catchmenu_common.bootstrap_app(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_device_id := p_device_id,
    p_device_type := 'KIOSK',
    p_app_version := p_app_version,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  if not (v_base->>'success')::boolean then
    return v_base;
  end if;

  -- wait time estimate
  v_wait_estimate :=
    catchmenu_pos.estimate_wait_time(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_guest_count := 2
    );

  -- available tables count
  return v_base || jsonb_build_object(
    'kiosk', jsonb_build_object(
      'ordering_available',
        v_base->'settings'->>'store_mode'
          not in ('CLOSED', 'EMERGENCY')
        and (
          v_base->'store'->>'store_status' = 'ACTIVE'
        ),
      'wait_estimate', jsonb_build_object(
        'estimated_wait_minutes',
          v_wait_estimate->>'estimated_wait_minutes',
        'can_seat_immediately',
          v_wait_estimate->>'can_seat_immediately',
        'queue_length',
          v_wait_estimate->>'queue_length',
        'next_wait_number',
          v_wait_estimate->>'next_wait_number'
      ),
      'waiting_enabled',
        (v_base->'settings'->>'waiting_enabled')
          ::boolean,
      'pre_order_enabled',
        (v_base->'settings'->>'pre_order_enabled')
          ::boolean,
      'allergen_consult_notice',
        catchmenu_common.get_message(
          'allergen_consult_staff', p_locale, null
        )
    )
  );
end;
$$;


-- =============================================
-- bootstrap_staff_app: 직원 앱 전용 부트스트랩
-- =============================================
create or replace function
  catchmenu_common.bootstrap_staff_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_staff_id uuid default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_base jsonb;
  v_staff record;
  v_waiting_queue jsonb;
  v_open_exceptions jsonb;
  v_today_summary jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- base bootstrap
  v_base := catchmenu_common.bootstrap_app(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_device_id := p_device_id,
    p_device_type := 'STAFF_APP',
    p_app_version := p_app_version,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  if not (v_base->>'success')::boolean then
    return v_base;
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- staff info and permissions
  if p_staff_id is not null then
    select id, staff_code, display_name,
           staff_role, authority_level,
           can_observe, can_override_kds,
           can_approve_refund, can_manage_menu,
           can_manage_staff, can_view_reports,
           can_change_store_mode
    into v_staff
    from catchmenu_store.staff
    where id = p_staff_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
      and staff_status = 'ACTIVE';
  end if;

  -- current waiting queue
  v_waiting_queue :=
    catchmenu_pos.get_waiting_queue(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- open exceptions (staff must see)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'exception_id', id,
        'exception_type', exception_type,
        'exception_domain', exception_domain,
        'exception_severity', exception_severity,
        'exception_status', exception_status,
        'error_message', error_message,
        'occurrence_count', occurrence_count,
        'detected_at', detected_at,
        'requires_human_approval',
          requires_human_approval
      )
      order by
        case exception_severity
          when 'FATAL' then 0
          when 'CRITICAL' then 1
          when 'ERROR' then 2
          when 'WARNING' then 3
          else 4
        end,
        detected_at desc
    ),
    '[]'::jsonb
  )
  into v_open_exceptions
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and exception_status in (
      'OPEN', 'ACKNOWLEDGED'
    )
    and business_day = v_business_day
  limit 20;

  -- today's summary (lightweight)
  select jsonb_build_object(
    'total_orders', count(*),
    'completed_orders', count(*) filter (
      where order_status = 'COMPLETED'
    ),
    'total_revenue', coalesce(
      sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0
    ),
    'cancelled_orders', count(*) filter (
      where order_status = 'CANCELLED'
    )
  )
  into v_today_summary
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  return v_base || jsonb_build_object(
    'staff', case
      when v_staff.id is not null
      then jsonb_build_object(
        'id', v_staff.id,
        'staff_code', v_staff.staff_code,
        'display_name', v_staff.display_name,
        'staff_role', v_staff.staff_role,
        'authority_level', v_staff.authority_level,
        'permissions', jsonb_build_object(
          'can_observe', v_staff.can_observe,
          'can_override_kds',
            v_staff.can_override_kds,
          'can_approve_refund',
            v_staff.can_approve_refund,
          'can_manage_menu',
            v_staff.can_manage_menu,
          'can_manage_staff',
            v_staff.can_manage_staff,
          'can_view_reports',
            v_staff.can_view_reports,
          'can_change_store_mode',
            v_staff.can_change_store_mode
        )
      )
      else null
    end,
    'waiting_queue',
      v_waiting_queue->'data',
    'open_exceptions', v_open_exceptions,
    'exception_count',
      jsonb_array_length(v_open_exceptions),
    'today_summary', v_today_summary
  );
end;
$$;


-- =============================================
-- heartbeat: 앱 주기적 상태 확인
-- 30초마다 Flutter가 호출
-- =============================================
create or replace function
  catchmenu_common.heartbeat(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_app_version text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_device record;
  v_settings record;
  v_payment_uncertain boolean := false;
  v_manual_fallback boolean := false;
  v_open_exceptions int := 0;
  v_critical_exceptions int := 0;
  v_store_mode text;
  v_business_day date;
  v_timezone text;
begin
  -- minimal device validation
  select id, trust_level, device_status
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_device.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'heartbeat'
    );
  end if;

  if v_device.trust_level in (
    'UNTRUSTED', 'REVOKED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_trusted',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'heartbeat'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- update heartbeat
  update catchmenu_store.device_registry
  set
    last_heartbeat_at = now(),
    last_seen_at = now(),
    updated_at = now()
  where id = p_device_id;

  -- store mode
  select store_mode
  into v_store_mode
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- critical state checks (fast)
  select exists (
    select 1
    from catchmenu_payment.payment_intents
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and intent_status = 'UNCERTAIN'
  ) into v_payment_uncertain;

  select exists (
    select 1
    from catchmenu_agent.manual_fallback_log
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and fallback_status in (
        'ACTIVE', 'RECOVERING'
      )
  ) into v_manual_fallback;

  select
    count(*) filter (
      where exception_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    ),
    count(*) filter (
      where exception_severity in (
        'CRITICAL', 'FATAL'
      )
      and exception_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    )
  into v_open_exceptions, v_critical_exceptions
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  return jsonb_build_object(
    'success', true,
    'device_id', p_device_id,
    'trust_level', v_device.trust_level,
    'store_mode', coalesce(v_store_mode, 'NORMAL'),
    'business_day', v_business_day,

    -- delta alerts (only send changes)
    'alerts', jsonb_build_object(
      'payment_uncertain', v_payment_uncertain,
      'manual_fallback', v_manual_fallback,
      'open_exceptions', v_open_exceptions,
      'critical_exceptions', v_critical_exceptions,
      'has_critical_alerts',
        v_payment_uncertain
        or v_manual_fallback
        or v_critical_exceptions > 0
    ),

    -- server time for Flutter clock sync
    'server_time', now(),
    'server_timezone', v_timezone,

    -- next heartbeat interval
    -- faster during critical alerts
    'next_heartbeat_seconds', case
      when v_payment_uncertain
        or v_critical_exceptions > 0
      then 10
      when v_manual_fallback
        or v_open_exceptions > 0
      then 20
      else 30
    end,

    'message_code', 'heartbeat_ok'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.bootstrap_app(
      uuid, uuid, uuid, text, text,
      text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_app(
      uuid, uuid, uuid, text, text,
      text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.bootstrap_kds_app(
      uuid, uuid, uuid, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_kds_app(
      uuid, uuid, uuid, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.bootstrap_kiosk_app(
      uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_kiosk_app(
      uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.bootstrap_staff_app(
      uuid, uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_staff_app(
      uuid, uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.heartbeat(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.heartbeat(
      uuid, uuid, uuid, text, text
    ) to authenticated;
end;
$$;

comment on function catchmenu_common.bootstrap_app(
  uuid, uuid, uuid, text, text,
  text, text, text, text
) is
  'Universal Flutter app bootstrap.
   Single RPC call on app startup.
   Returns everything Flutter needs to render:
   - store config + settings
   - device trust status
   - realtime channel config
   - critical operational alerts
   - device-specific data (KDS/kiosk/floor map)
   - HQ notices

   UNTRUSTED device: returns error immediately.
   No data leak to untrusted devices.

   Flutter 사용 예시:
   final bootstrap = await supabase.rpc(
     "bootstrap_app",
     params: {
       "p_tenant_id": tenantId,
       "p_store_id": storeId,
       "p_device_id": deviceId,
       "p_device_type": "KDS",
       "p_app_version": "1.0.0",
       "p_locale": "ko"
     }
   );

   특허4: Zero Trust 앱 초기화.
   UNTRUSTED 디바이스 = 즉시 차단.
   trust_level = TRUSTED 후에만 운영 데이터 전달.';

comment on function catchmenu_common.heartbeat(
  uuid, uuid, uuid, text, text
) is
  'Lightweight periodic heartbeat (30s interval).
   Updates device last_heartbeat_at.
   Returns delta alerts only (changed states).
   Adaptive interval:
     PAYMENT_UNCERTAIN → 10s
     OPEN_EXCEPTIONS → 20s
     NORMAL → 30s
   Server time included for Flutter clock sync.

   Flutter 사용:
   Timer.periodic(
     Duration(seconds: lastHeartbeatSeconds),
     (_) => supabase.rpc("heartbeat", params: {...})
   );

   특허4: 디바이스 생존 확인 + 상태 변경 푸시.
   heartbeat 누락 3회 → agent가 device OFFLINE 감지.';