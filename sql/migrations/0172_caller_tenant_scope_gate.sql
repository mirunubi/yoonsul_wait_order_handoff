-- Workpacket: 602010
-- Runtime Gate RG-01; Human invariant: 602010 section 3.
-- Scope: one internal helper and get_tenant_health entry point only.

BEGIN;

CREATE FUNCTION catchmenu_common.assert_caller_tenant_scope(p_tenant_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO pg_catalog
AS $gate$
DECLARE
  v_caller_tenant_id uuid;
BEGIN
  IF catchmenu_common.is_service_role() THEN
    RETURN;
  END IF;

  v_caller_tenant_id := catchmenu_common.current_tenant_id();
  IF v_caller_tenant_id IS NULL
     OR v_caller_tenant_id IS DISTINCT FROM p_tenant_id THEN
    RAISE EXCEPTION USING
      ERRCODE = '42501',
      MESSAGE = 'caller tenant scope denied';
  END IF;
END;
$gate$;

REVOKE ALL ON FUNCTION catchmenu_common.assert_caller_tenant_scope(uuid) FROM PUBLIC;

CREATE OR REPLACE FUNCTION catchmenu_common.get_tenant_health(p_tenant_id uuid, p_locale text DEFAULT 'ko'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'catchmenu_common', 'catchmenu_hq', 'catchmenu_pos', 'catchmenu_payment'
AS $function$
declare
  v_plan record;
  v_quota_summary jsonb;
  v_rate_limit_summary jsonb;
  v_security_summary jsonb;
  v_business_day date;
  v_store_count int;
  v_overall_health text;
begin
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 플랜 정보
  select plan_tier, plan_status,
         monthly_fee, trial_ends_at,
         subscription_starts_at
  into v_plan
  from catchmenu_common.tenant_plan_configs
  where tenant_id = p_tenant_id;

  -- 매장 수
  select count(*) into v_store_count
  from catchmenu_hq.stores
  where tenant_id = p_tenant_id
    and is_active = true;

  -- 쿼터 요약
  select jsonb_build_object(
    'total_quotas', count(*),
    'exceeded', count(*) filter (
      where current_usage > quota_limit
    ),
    'warning_level', count(*) filter (
      where current_usage::numeric
        / nullif(quota_limit, 0) * 100
        >= warning_threshold_pct
    ),
    'usage_by_resource', coalesce(
      jsonb_object_agg(
        resource_type,
        jsonb_build_object(
          'limit', quota_limit,
          'usage', current_usage,
          'pct', case quota_limit
            when 0 then 0
            else (
              current_usage::numeric
              / quota_limit * 100
            )::int
          end
        )
      ),
      '{}'::jsonb
    )
  )
  into v_quota_summary
  from catchmenu_common.tenant_quotas
  where tenant_id = p_tenant_id
    and is_active = true;

  -- Rate limit 요약
  select jsonb_build_object(
    'total_limits', count(*),
    'blocked', count(*) filter (
      where is_blocked = true
        and blocked_until > now()
    ),
    'violations_today', coalesce(
      sum(violation_count)
        filter (
          where last_violation_at::date
            = v_business_day
        ), 0
    )
  )
  into v_rate_limit_summary
  from catchmenu_common.tenant_rate_limits
  where tenant_id = p_tenant_id;

  -- 보안 요약
  select jsonb_build_object(
    'violations_24h', count(*) filter (
      where is_violation = true
        and created_at >
          now() - interval '24 hours'
    ),
    'critical_24h', count(*) filter (
      where event_severity = 'CRITICAL'
        and created_at >
          now() - interval '24 hours'
    ),
    'last_audit_at', max(created_at) filter (
      where audit_event
        = 'security_audit_completed'
    )
  )
  into v_security_summary
  from catchmenu_common.security_audit_log
  where tenant_id = p_tenant_id;

  -- 전체 건강 상태
  v_overall_health := case
    when (
      v_plan.plan_status not in (
        'ACTIVE', 'TRIAL'
      )
      or (
        v_plan.plan_status = 'TRIAL'
        and v_plan.trial_ends_at < now()
      )
    ) then 'CRITICAL'
    when (
      (v_security_summary->>'critical_24h')::int > 0
      or (v_quota_summary->>'exceeded')::int > 0
    ) then 'WARNING'
    else 'HEALTHY'
  end;

  return catchmenu_common.build_success_response(
    p_message_key := 'tenant_health_loaded',
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'overall_health', v_overall_health,
      'plan', jsonb_build_object(
        'tier', v_plan.plan_tier,
        'status', v_plan.plan_status,
        'monthly_fee', v_plan.monthly_fee,
        'trial_ends_at', v_plan.trial_ends_at,
        'subscription_starts_at',
          v_plan.subscription_starts_at
      ),
      'stores', jsonb_build_object(
        'active_count', v_store_count
      ),
      'quotas', v_quota_summary,
      'rate_limits', v_rate_limit_summary,
      'security', v_security_summary,
      'checked_at', now()
    ),
    p_locale := p_locale
  );
end;
$function$;

COMMIT;
