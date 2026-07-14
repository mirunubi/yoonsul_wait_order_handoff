-- 0151_create_check_kds_capacity_function.sql
-- Purpose: Create catchmenu_kds.check_kds_capacity(p_tenant_id, p_store_id).
--
-- Background:
--   The live KDS/payment/realtime pipeline references
--   catchmenu_kds.check_kds_capacity(...) from multiple later RPCs, including
--   release_kds_after_payment(), get_kds_realtime_state(), and delivery
--   platform flow code, but the function itself was not defined in prior
--   migrations. This caused runtime failures before those callers could reach
--   their next validation step.
--
-- Design authority:
--   docs/600000_implementation_lifecycle/600400_kds_did_implementation/
--     600410_kds_capacity_gate_and_status_reconciliation/
--       600411_Overview.md
--       600412_Logic.md
--       600413_TestPlan.md
--       600414_ChangeContract.md
--
-- Creates:
--   - catchmenu_kds.check_kds_capacity(p_tenant_id uuid, p_store_id uuid)
--
-- Notes:
--   - Reuses catchmenu_kds.evaluate_kds_capacity(...) for real kitchen zones.
--   - Builds the zone list from distinct kitchen_zone values already present
--     in catchmenu_kds.kds_tickets for the tenant/store. No business_day filter
--     is applied here.
--   - NULL kitchen_zone tickets are reported as a virtual UNASSIGNED group, but
--     UNASSIGNED is not passed to evaluate_kds_capacity(). NULL comparisons
--     would otherwise count zero rows. The wrapper counts NULL-zone tickets
--     directly, using the same threshold value (8) as evaluate_kds_capacity().
--   - Returns the nested shape expected by existing callers:
--       { "data": { "is_overloaded": boolean, "zones": [...] } }

create or replace function catchmenu_kds.check_kds_capacity(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_kds, catchmenu_common
as $$
declare
  v_zone text;
  v_zone_result jsonb;
  v_zone_results jsonb := '[]'::jsonb;
  v_all_ok boolean := true;
  v_zones text[];
  v_unassigned_cooking int := 0;
  v_unassigned_hold int := 0;
  v_unassigned_ready int := 0;
  v_unassigned_ok boolean := true;
  v_threshold int := 8;
begin
  select array_agg(
    distinct coalesce(kitchen_zone, 'UNASSIGNED')
    order by coalesce(kitchen_zone, 'UNASSIGNED')
  )
  into v_zones
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_zones is null then
    v_zones := array[]::text[];
  end if;

  foreach v_zone in array v_zones loop
    if v_zone = 'UNASSIGNED' then
      select
        count(*) filter (
          where kds_status in ('COOKING', 'COMMITTED')
        ),
        count(*) filter (
          where kds_status in ('HOLD', 'CAPACITY_CHECKING')
        ),
        count(*) filter (
          where kds_status = 'READY'
        )
      into
        v_unassigned_cooking,
        v_unassigned_hold,
        v_unassigned_ready
      from catchmenu_kds.kds_tickets
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and kds_status not in ('COMPLETED', 'CANCELLED', 'SERVED')
        and kitchen_zone is null;

      v_unassigned_ok := v_unassigned_cooking < v_threshold;
      v_zone_result := jsonb_build_object(
        'cooking_count', v_unassigned_cooking,
        'hold_count', v_unassigned_hold,
        'ready_count', v_unassigned_ready,
        'capacity_ok', v_unassigned_ok,
        'threshold', v_threshold,
        'kitchen_zone', 'UNASSIGNED'
      );
    else
      v_zone_result := catchmenu_kds.evaluate_kds_capacity(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_kitchen_zone := v_zone
      );
    end if;

    v_zone_results := v_zone_results || jsonb_build_array(v_zone_result);
    if not coalesce((v_zone_result->>'capacity_ok')::boolean, false) then
      v_all_ok := false;
    end if;
  end loop;

  return jsonb_build_object(
    'data', jsonb_build_object(
      'is_overloaded', not v_all_ok,
      'zones', v_zone_results
    )
  );
end;
$$;

comment on function catchmenu_kds.check_kds_capacity(uuid, uuid) is
  'Aggregates per-zone KDS capacity results into the {data:{is_overloaded,zones}} shape expected by payment, realtime, and delivery RPC callers. Created by migration 0151.';
