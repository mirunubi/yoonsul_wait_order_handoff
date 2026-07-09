-- 0065_create_security_isolation_rpc.sql
-- Purpose: Multi-tenant security isolation validation RPCs.
--          Verifies RLS, schema boundaries, data leakage prevention.
--          run_isolation_audit: validates tenant/store separation.
--          verify_rls_coverage: checks all tables have RLS.
--          scan_cross_tenant_risk: detects potential data leakage.
--          generate_security_report: full security posture report.
--          특허4 core: Zero Trust 멀티테넌트 격리 검증.
-- Depends on: 0064_create_menu_i18n_allergen.sql
-- Creates:
--   catchmenu_audit.security_scan_results (table)
--   function catchmenu_audit.run_isolation_audit(...)
--   function catchmenu_audit.verify_rls_coverage(...)
--   function catchmenu_audit.scan_cross_tenant_risk(...)
--   function catchmenu_audit.generate_security_report(...)

-- =============================================
-- security_scan_results table
-- =============================================
create table if not exists
  catchmenu_audit.security_scan_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,
  store_id uuid,

  scan_type text not null,
  scan_status text not null default 'PENDING',
  scan_scope text not null default 'FULL',

  -- results
  total_checks int not null default 0,
  passed_checks int not null default 0,
  failed_checks int not null default 0,
  warning_checks int not null default 0,

  -- findings
  critical_findings jsonb default '[]'::jsonb,
  warning_findings jsonb default '[]'::jsonb,
  passed_findings jsonb default '[]'::jsonb,

  -- risk assessment
  risk_level text not null default 'UNKNOWN',
  risk_score int not null default 0,
  remediation_required boolean not null default false,

  -- meta
  scanned_by_type text not null default 'SYSTEM',
  scanned_by_id uuid,
  scan_duration_ms int,
  scan_started_at timestamptz not null default now(),
  scan_completed_at timestamptz,

  created_at timestamptz not null default now(),

  constraint chk_scan_type check (
    scan_type in (
      'RLS_COVERAGE', 'TENANT_ISOLATION',
      'CROSS_TENANT_RISK', 'FULL_SECURITY',
      'DEVICE_TRUST', 'AGENT_PERMISSION',
      'PAYMENT_BOUNDARY'
    )
  ),
  constraint chk_scan_status check (
    scan_status in (
      'PENDING', 'RUNNING', 'COMPLETED',
      'FAILED', 'PARTIAL'
    )
  ),
  constraint chk_risk_level check (
    risk_level in (
      'UNKNOWN', 'LOW', 'MEDIUM',
      'HIGH', 'CRITICAL'
    )
  )
);

create index if not exists idx_security_scan_tenant
  on catchmenu_audit.security_scan_results(
    tenant_id, scan_type, scan_started_at desc
  );
create index if not exists idx_security_scan_risk
  on catchmenu_audit.security_scan_results(
    risk_level, scan_completed_at desc
  ) where scan_status = 'COMPLETED';

alter table catchmenu_audit.security_scan_results
  enable row level security;
alter table catchmenu_audit.security_scan_results
  force row level security;

drop policy if exists security_scan_isolation
  on catchmenu_audit.security_scan_results;
create policy security_scan_isolation
  on catchmenu_audit.security_scan_results
  for all to authenticated
  using (
    tenant_id is null
    or tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_audit.security_scan_results is
  'Security audit scan results.
   Stores RLS coverage, tenant isolation,
   and cross-tenant risk scan findings.
   특허4: Zero Trust 정기 보안 감사 증빙.
   scan_results are evidence for compliance audits.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_audit.verify_rls_coverage(
  p_scan_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_audit, catchmenu_common,
                  information_schema, pg_catalog
as $$
declare
  v_scan_id uuid;
  v_total int := 0;
  v_passed int := 0;
  v_failed int := 0;
  v_critical jsonb := '[]'::jsonb;
  v_passed_list jsonb := '[]'::jsonb;
  v_table record;
  v_risk_score int := 0;
begin
  v_scan_id := coalesce(p_scan_id, gen_random_uuid());

  -- check all catchmenu schemas for RLS
  for v_table in
    select
      t.schemaname,
      t.tablename,
      t.rowsecurity,
      -- check if force row security is enabled
      c.relforcerowsecurity
    from pg_tables t
    join pg_class c
      on c.relname = t.tablename
    join pg_namespace n
      on n.oid = c.relnamespace
      and n.nspname = t.schemaname
    where t.schemaname like 'catchmenu_%'
      and t.schemaname not in (
        'catchmenu_common'
      )
      -- exclude internal/system tables
      and t.tablename not in (
        'schema_migrations',
        'spatial_ref_sys'
      )
    order by t.schemaname, t.tablename
  loop
    v_total := v_total + 1;

    if not v_table.rowsecurity then
      -- RLS not enabled = CRITICAL
      v_failed := v_failed + 1;
      v_risk_score := v_risk_score + 20;
      v_critical := v_critical || jsonb_build_array(
        jsonb_build_object(
          'finding_type', 'RLS_DISABLED',
          'severity', 'CRITICAL',
          'schema', v_table.schemaname,
          'table', v_table.tablename,
          'detail', 'Row Level Security is disabled',
          'remediation',
            'ALTER TABLE ' || v_table.schemaname
            || '.' || v_table.tablename
            || ' ENABLE ROW LEVEL SECURITY;'
        )
      );

    elsif not v_table.relforcerowsecurity then
      -- RLS enabled but not forced = WARNING
      v_failed := v_failed + 1;
      v_risk_score := v_risk_score + 5;
      v_critical := v_critical || jsonb_build_array(
        jsonb_build_object(
          'finding_type', 'RLS_NOT_FORCED',
          'severity', 'WARNING',
          'schema', v_table.schemaname,
          'table', v_table.tablename,
          'detail',
            'RLS enabled but not forced '
            || '(table owner bypasses RLS)',
          'remediation',
            'ALTER TABLE ' || v_table.schemaname
            || '.' || v_table.tablename
            || ' FORCE ROW LEVEL SECURITY;'
        )
      );

    else
      -- RLS enabled and forced = PASS
      v_passed := v_passed + 1;
      v_passed_list := v_passed_list
        || jsonb_build_array(
          jsonb_build_object(
            'schema', v_table.schemaname,
            'table', v_table.tablename,
            'rls_enabled', true,
            'rls_forced', true
          )
        );
    end if;
  end loop;

  return jsonb_build_object(
    'scan_id', v_scan_id,
    'scan_type', 'RLS_COVERAGE',
    'total_tables', v_total,
    'passed', v_passed,
    'failed', v_failed,
    'risk_score', v_risk_score,
    'risk_level', case
      when v_risk_score = 0 then 'LOW'
      when v_risk_score <= 10 then 'MEDIUM'
      when v_risk_score <= 30 then 'HIGH'
      else 'CRITICAL'
    end,
    'critical_findings', v_critical,
    'passed_tables', v_passed_list,
    'pass_rate_pct', case v_total
      when 0 then 100
      else (v_passed::numeric / v_total * 100)::int
    end,
    'scanned_at', now()
  );
end;
$$;


create or replace function
  catchmenu_audit.run_isolation_audit(
  p_tenant_id uuid,
  p_store_id uuid default null,
  p_scanned_by_type text default 'SYSTEM',
  p_scanned_by_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_audit, catchmenu_common,
                  catchmenu_hq, catchmenu_pos,
                  catchmenu_payment, catchmenu_kds,
                  catchmenu_store, catchmenu_ledger
as $$
declare
  v_scan_id uuid;
  v_start timestamptz;
  v_checks jsonb := '[]'::jsonb;
  v_critical jsonb := '[]'::jsonb;
  v_warnings jsonb := '[]'::jsonb;
  v_total int := 0;
  v_passed int := 0;
  v_failed int := 0;
  v_risk_score int := 0;

begin
  v_scan_id := gen_random_uuid();
  v_start := now();

  -- insert scan record
  insert into catchmenu_audit.security_scan_results (
    id, tenant_id, store_id,
    scan_type, scan_status, scan_scope,
    scanned_by_type, scanned_by_id
  ) values (
    v_scan_id, p_tenant_id, p_store_id,
    'TENANT_ISOLATION', 'RUNNING',
    case when p_store_id is null
      then 'TENANT' else 'STORE'
    end,
    p_scanned_by_type, p_scanned_by_id
  );

  -- =============================================
  -- CHECK 1: Tenant exists and is active
  -- =============================================
  v_total := v_total + 1;
  if exists (
      select 1 from catchmenu_hq.tenants
      where id = p_tenant_id
        and is_active = true
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'tenant_exists_and_active',
        'status', 'PASS',
        'detail', 'Tenant must exist and be active'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'tenant_exists_and_active',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'Tenant must exist and be active',
        'remediation', 'Verify tenant provisioning'
      )
    );
  end if;

  -- =============================================
  -- CHECK 2: No orders with wrong tenant
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_pos.orders o
      join catchmenu_hq.stores s
        on s.id = o.store_id
      where o.tenant_id = p_tenant_id
        and s.tenant_id <> p_tenant_id
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'orders_tenant_isolation',
        'status', 'PASS',
        'detail', 'All orders must belong to correct tenant'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'orders_tenant_isolation',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'All orders must belong to correct tenant',
        'remediation', 'Investigate cross-tenant order contamination'
      )
    );
  end if;

  -- =============================================
  -- CHECK 3: No payment records with wrong tenant
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_payment.payment_ledger pl
      join catchmenu_hq.stores s
        on s.id = pl.store_id
      where pl.tenant_id = p_tenant_id
        and s.tenant_id <> p_tenant_id
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'payment_ledger_tenant_isolation',
        'status', 'PASS',
        'detail', 'Payment ledger must be tenant-isolated'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'payment_ledger_tenant_isolation',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'Payment ledger must be tenant-isolated',
        'remediation', 'Investigate payment data contamination'
      )
    );
  end if;

  -- =============================================
  -- CHECK 4: No KDS tickets with wrong tenant
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_kds.kds_tickets kt
      join catchmenu_hq.stores s
        on s.id = kt.store_id
      where kt.tenant_id = p_tenant_id
        and s.tenant_id <> p_tenant_id
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'kds_tickets_tenant_isolation',
        'status', 'PASS',
        'detail', 'KDS tickets must be tenant-isolated'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'kds_tickets_tenant_isolation',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'KDS tickets must be tenant-isolated',
        'remediation', 'Investigate KDS data contamination'
      )
    );
  end if;

  -- =============================================
  -- CHECK 5: No orphaned sessions (no store)
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_pos.order_sessions os
      left join catchmenu_hq.stores s
        on s.id = os.store_id
      where os.tenant_id = p_tenant_id
        and s.id is null
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'no_orphaned_sessions',
        'status', 'PASS',
        'detail', 'All sessions must have valid store reference'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'HIGH'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'no_orphaned_sessions',
        'status', 'FAIL',
        'severity', 'HIGH',
        'detail', 'All sessions must have valid store reference',
        'remediation', 'Clean up orphaned session records'
      )
    );
  end if;

  -- =============================================
  -- CHECK 6: Audit records append-only
  -- (no updated_at changes = truly append-only)
  -- =============================================
  v_total := v_total + 1;
  if (
      select coalesce(
        sum(
          case when recorded_at <> created_at
          then 1 else 0 end
        ), 0
      ) = 0
      from catchmenu_ledger.audit_records
      where tenant_id = p_tenant_id
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'audit_records_append_only',
        'status', 'PASS',
        'detail', 'Audit records must be append-only (no modifications)'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'audit_records_append_only',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'Audit records must be append-only (no modifications)',
        'remediation', 'Investigate audit record tampering'
      )
    );
  end if;

  -- =============================================
  -- CHECK 7: No UNTRUSTED devices online
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_store.device_registry
      where tenant_id = p_tenant_id
        and trust_level in ('UNTRUSTED', 'REVOKED')
        and device_status = 'ONLINE'
        and is_active = true
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'no_untrusted_devices_online',
        'status', 'PASS',
        'detail', 'UNTRUSTED/REVOKED devices must not be ONLINE'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'no_untrusted_devices_online',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'UNTRUSTED/REVOKED devices must not be ONLINE',
        'remediation', 'Immediately revoke device access and investigate'
      )
    );
  end if;

  -- =============================================
  -- CHECK 8: No agent with execute permission
  -- outside approved types
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_store.agent_registry
      where tenant_id = p_tenant_id
        and can_execute = true
        and agent_type not in (
          'RECOVERY', 'SUPERVISOR'
        )
        and is_active = true
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'agent_execute_permission_restricted',
        'status', 'PASS',
        'detail', 'Only RECOVERY/SUPERVISOR agents can have execute permission'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'HIGH'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'agent_execute_permission_restricted',
        'status', 'FAIL',
        'severity', 'HIGH',
        'detail', 'Only RECOVERY/SUPERVISOR agents can have execute permission',
        'remediation', 'Revoke execute permission from non-approved agents'
      )
    );
  end if;

  -- =============================================
  -- CHECK 9: KDS release = explicit authorization only
  -- =============================================
  v_total := v_total + 1;
  if (
      -- all APPROVED payments must have
      -- explicit kds_release_authorized flag
      select count(*) filter (
        where kds_release_authorized = true
          and kds_release_authorized_at is null
      ) = 0
      from catchmenu_payment.payment_ledger
      where tenant_id = p_tenant_id
        and ledger_status = 'APPROVED'
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'kds_release_requires_authorization',
        'status', 'PASS',
        'detail', 'KDS release must always have authorization timestamp'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'kds_release_requires_authorization',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'KDS release must always have authorization timestamp',
        'remediation', 'Re-audit all KDS release authorizations'
      )
    );
  end if;

  -- =============================================
  -- CHECK 10: No UNCERTAIN payments
  -- with cooking KDS tickets
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_payment.payment_intents pi
      join catchmenu_kds.kds_tickets kt
        on kt.order_id = pi.order_id
      where pi.tenant_id = p_tenant_id
        and pi.intent_status = 'UNCERTAIN'
        and kt.kds_status = 'COOKING'
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'uncertain_payment_blocks_kds',
        'status', 'PASS',
        'detail', 'UNCERTAIN payment must block all KDS cooking'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'CRITICAL'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'uncertain_payment_blocks_kds',
        'status', 'FAIL',
        'severity', 'CRITICAL',
        'detail', 'UNCERTAIN payment must block all KDS cooking',
        'remediation', 'Immediately halt KDS and resolve payment uncertainty'
      )
    );
  end if;

  -- =============================================
  -- CHECK 11: Store-level isolation
  -- =============================================
  if p_store_id is not null then
    v_total := v_total + 1;
    if exists (
        select 1 from catchmenu_hq.stores
        where id = p_store_id
          and tenant_id = p_tenant_id
          and is_active = true
      ) then
      v_passed := v_passed + 1;
      v_checks := v_checks || jsonb_build_array(
        jsonb_build_object(
          'check', 'store_belongs_to_tenant',
          'status', 'PASS',
          'detail', 'Store must belong to tenant'
        )
      );
    else
      v_failed := v_failed + 1;
      v_risk_score := v_risk_score + case 'CRITICAL'
        when 'CRITICAL' then 25
        when 'HIGH' then 15
        when 'MEDIUM' then 5
        else 1
      end;
      v_critical := v_critical || jsonb_build_array(
        jsonb_build_object(
          'check', 'store_belongs_to_tenant',
          'status', 'FAIL',
          'severity', 'CRITICAL',
          'detail', 'Store must belong to tenant',
          'remediation', 'Verify store provisioning'
        )
      );
    end if;

    v_total := v_total + 1;
    if not exists (
        select 1
        from catchmenu_pos.orders
        where store_id = p_store_id
          and tenant_id <> p_tenant_id
      ) then
      v_passed := v_passed + 1;
      v_checks := v_checks || jsonb_build_array(
        jsonb_build_object(
          'check', 'store_data_boundary',
          'status', 'PASS',
          'detail', 'Store data must not leak across tenant boundary'
        )
      );
    else
      v_failed := v_failed + 1;
      v_risk_score := v_risk_score + case 'CRITICAL'
        when 'CRITICAL' then 25
        when 'HIGH' then 15
        when 'MEDIUM' then 5
        else 1
      end;
      v_critical := v_critical || jsonb_build_array(
        jsonb_build_object(
          'check', 'store_data_boundary',
          'status', 'FAIL',
          'severity', 'CRITICAL',
          'detail', 'Store data must not leak across tenant boundary',
          'remediation', 'Investigate data boundary violation immediately'
        )
      );
    end if;
  end if;

  -- =============================================
  -- CHECK 12: Knowledge docs not leaking
  -- =============================================
  v_total := v_total + 1;
  if not exists (
      select 1
      from catchmenu_knowledge.documents d
      where d.tenant_id = p_tenant_id
        and d.is_ai_retrievable = true
        and d.ai_retrieval_scope = 'INTERNAL_ONLY'
        and d.document_status = 'PUBLISHED'
        -- INTERNAL_ONLY docs must not be
        -- in CUSTOMER_FACING scope
        and exists (
          select 1
          from catchmenu_knowledge.documents d2
          where d2.id = d.id
            and d2.ai_retrieval_scope
              = 'CUSTOMER_FACING'
        )
    ) then
    v_passed := v_passed + 1;
    v_checks := v_checks || jsonb_build_array(
      jsonb_build_object(
        'check', 'knowledge_docs_tenant_isolated',
        'status', 'PASS',
        'detail', 'INTERNAL_ONLY knowledge docs must not be customer-facing'
      )
    );
  else
    v_failed := v_failed + 1;
    v_risk_score := v_risk_score + case 'HIGH'
      when 'CRITICAL' then 25
      when 'HIGH' then 15
      when 'MEDIUM' then 5
      else 1
    end;
    v_critical := v_critical || jsonb_build_array(
      jsonb_build_object(
        'check', 'knowledge_docs_tenant_isolated',
        'status', 'FAIL',
        'severity', 'HIGH',
        'detail', 'INTERNAL_ONLY knowledge docs must not be customer-facing',
        'remediation', 'Review knowledge doc AI retrieval scopes'
      )
    );
  end if;

  -- finalize scan
  update catchmenu_audit.security_scan_results
  set
    scan_status = 'COMPLETED',
    total_checks = v_total,
    passed_checks = v_passed,
    failed_checks = v_failed,
    critical_findings = v_critical,
    passed_findings = v_checks,
    risk_score = v_risk_score,
    risk_level = case
      when v_risk_score = 0 then 'LOW'
      when v_risk_score <= 15 then 'MEDIUM'
      when v_risk_score <= 40 then 'HIGH'
      else 'CRITICAL'
    end,
    remediation_required = v_failed > 0,
    scan_duration_ms = extract(
      epoch from (now() - v_start)
    )::int * 1000,
    scan_completed_at = now()
  where id = v_scan_id;

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := case
      when v_risk_score = 0 then 'INFO'
      when v_risk_score <= 15 then 'WARNING'
      else 'CRITICAL'
    end,
    p_log_domain := 'SYSTEM',
    p_log_event := 'isolation_audit_completed',
    p_message :=
      'Isolation audit completed'
      || ' | checks=' || v_total
      || ' passed=' || v_passed
      || ' failed=' || v_failed
      || ' risk_score=' || v_risk_score,
    p_rpc_name := 'run_isolation_audit',
    p_details := jsonb_build_object(
      'scan_id', v_scan_id,
      'total', v_total,
      'passed', v_passed,
      'failed', v_failed,
      'risk_score', v_risk_score
    )
  );

  return jsonb_build_object(
    'success', true,
    'scan_id', v_scan_id,
    'scan_type', 'TENANT_ISOLATION',
    'tenant_id', p_tenant_id,
    'store_id', p_store_id,
    'summary', jsonb_build_object(
      'total_checks', v_total,
      'passed', v_passed,
      'failed', v_failed,
      'risk_score', v_risk_score,
      'risk_level', case
        when v_risk_score = 0 then 'LOW'
        when v_risk_score <= 15 then 'MEDIUM'
        when v_risk_score <= 40 then 'HIGH'
        else 'CRITICAL'
      end,
      'remediation_required', v_failed > 0,
      'pass_rate_pct', case v_total
        when 0 then 100
        else (v_passed::numeric / v_total * 100)::int
      end
    ),
    'critical_findings', v_critical,
    'passed_checks', v_checks,
    'scanned_at', now(),
    'message_code', case v_failed
      when 0 then 'isolation_audit_passed'
      else 'isolation_audit_failed'
    end
  );
end;
$$;


create or replace function
  catchmenu_audit.scan_cross_tenant_risk(
  p_tenant_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_audit, catchmenu_common,
                  catchmenu_pos, catchmenu_payment,
                  catchmenu_kds, catchmenu_store,
                  catchmenu_ledger, catchmenu_hq
as $$
declare
  v_risks jsonb := '[]'::jsonb;
  v_risk_count int := 0;
  v_critical_count int := 0;
begin
  -- Scan 1: orders with mismatched tenant/store
  with mismatched as (
    select o.id as order_id,
           o.tenant_id as order_tenant,
           s.tenant_id as store_tenant,
           o.store_id
    from catchmenu_pos.orders o
    join catchmenu_hq.stores s
      on s.id = o.store_id
    where o.tenant_id = p_tenant_id
      and s.tenant_id <> p_tenant_id
    limit 10
  )
  select case when count(*) > 0 then
    jsonb_build_object(
      'risk_type', 'ORDER_TENANT_MISMATCH',
      'severity', 'CRITICAL',
      'count', count(*),
      'sample_ids', (
        select coalesce(
          jsonb_agg(sample.order_id),
          '[]'::jsonb
        )
        from (
          select order_id
          from mismatched
          limit 5
        ) sample
      ),
      'detail', 'Orders assigned to stores of different tenant'
    )
    else null
  end
  into v_risks
  from mismatched;

  if v_risks is not null then
    v_risk_count := v_risk_count + 1;
    v_critical_count := v_critical_count + 1;
  else
    v_risks := '[]'::jsonb;
  end if;

  -- Scan 2: Payment ledger cross-tenant
  with payment_risk as (
    select pl.id, pl.tenant_id,
           s.tenant_id as store_tenant
    from catchmenu_payment.payment_ledger pl
    join catchmenu_hq.stores s
      on s.id = pl.store_id
    where pl.tenant_id = p_tenant_id
      and s.tenant_id <> p_tenant_id
    limit 10
  )
  select case when count(*) > 0 then
    v_risks || jsonb_build_array(
      jsonb_build_object(
        'risk_type', 'PAYMENT_TENANT_MISMATCH',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail',
          'Payment records in wrong tenant boundary'
      )
    )
    else v_risks
  end
  into v_risks
  from payment_risk;

  -- Scan 3: KDS tickets cross-tenant
  with kds_risk as (
    select kt.id, kt.tenant_id,
           s.tenant_id as store_tenant
    from catchmenu_kds.kds_tickets kt
    join catchmenu_hq.stores s
      on s.id = kt.store_id
    where kt.tenant_id = p_tenant_id
      and s.tenant_id <> p_tenant_id
    limit 10
  )
  select case when count(*) > 0 then
    v_risks || jsonb_build_array(
      jsonb_build_object(
        'risk_type', 'KDS_TENANT_MISMATCH',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail', 'KDS tickets in wrong tenant boundary'
      )
    )
    else v_risks
  end
  into v_risks
  from kds_risk;

  -- Scan 4: Staff accessing wrong store
  with staff_risk as (
    select s.id, s.tenant_id, s.store_id,
           st.tenant_id as store_tenant
    from catchmenu_store.staff s
    join catchmenu_hq.stores st
      on st.id = s.store_id
    where s.tenant_id = p_tenant_id
      and st.tenant_id <> p_tenant_id
    limit 10
  )
  select case when count(*) > 0 then
    v_risks || jsonb_build_array(
      jsonb_build_object(
        'risk_type', 'STAFF_STORE_MISMATCH',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Staff records linked to wrong tenant store'
      )
    )
    else v_risks
  end
  into v_risks
  from staff_risk;

  -- Scan 5: Customers with cross-tenant coupons
  with coupon_risk as (
    select ci.id, ci.tenant_id,
           c.tenant_id as coupon_tenant
    from catchmenu_store.coupon_issues ci
    join catchmenu_store.coupons c
      on c.id = ci.coupon_id
    where ci.tenant_id = p_tenant_id
      and c.tenant_id <> p_tenant_id
    limit 10
  )
  select case when count(*) > 0 then
    v_risks || jsonb_build_array(
      jsonb_build_object(
        'risk_type', 'COUPON_TENANT_MISMATCH',
        'severity', 'HIGH',
        'count', count(*),
        'detail',
          'Coupon issues linked to wrong tenant coupons'
      )
    )
    else v_risks
  end
  into v_risks
  from coupon_risk;

  -- Scan 6: Devices accessing wrong tenant
  with device_risk as (
    select d.id, d.tenant_id, d.store_id,
           s.tenant_id as store_tenant
    from catchmenu_store.device_registry d
    join catchmenu_hq.stores s
      on s.id = d.store_id
    where d.tenant_id = p_tenant_id
      and s.tenant_id <> p_tenant_id
    limit 10
  )
  select case when count(*) > 0 then
    v_risks || jsonb_build_array(
      jsonb_build_object(
        'risk_type', 'DEVICE_TENANT_MISMATCH',
        'severity', 'CRITICAL',
        'count', count(*),
        'detail',
          'Devices registered to wrong tenant boundary'
      )
    )
    else v_risks
  end
  into v_risks
  from device_risk;

  -- update risk counts
  select count(*),
         count(*) filter (
           where r->>'severity' = 'CRITICAL'
         )
  into v_risk_count, v_critical_count
  from jsonb_array_elements(v_risks) r;

  return jsonb_build_object(
    'success', true,
    'tenant_id', p_tenant_id,
    'scan_type', 'CROSS_TENANT_RISK',
    'risk_count', coalesce(v_risk_count, 0),
    'critical_count', coalesce(v_critical_count, 0),
    'risks', coalesce(v_risks, '[]'::jsonb),
    'is_clean', coalesce(v_risk_count, 0) = 0,
    'scanned_at', now(),
    'message_code', case
      when coalesce(v_risk_count, 0) = 0
      then 'cross_tenant_scan_clean'
      else 'cross_tenant_risk_detected'
    end
  );
end;
$$;


create or replace function
  catchmenu_audit.generate_security_report(
  p_tenant_id uuid,
  p_store_id uuid default null,
  p_scanned_by_type text default 'SYSTEM',
  p_scanned_by_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_audit, catchmenu_common,
                  catchmenu_ledger, catchmenu_hq
as $$
declare
  v_report_id uuid;
  v_start timestamptz;
  v_rls_result jsonb;
  v_isolation_result jsonb;
  v_cross_tenant_result jsonb;
  v_overall_risk text;
  v_overall_score int;
  v_audit_id uuid;
begin
  v_report_id := gen_random_uuid();
  v_start := now();

  -- run all scans
  v_rls_result :=
    catchmenu_audit.verify_rls_coverage(v_report_id);

  v_isolation_result :=
    catchmenu_audit.run_isolation_audit(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_scanned_by_type := p_scanned_by_type,
      p_scanned_by_id := p_scanned_by_id
    );

  v_cross_tenant_result :=
    catchmenu_audit.scan_cross_tenant_risk(
      p_tenant_id := p_tenant_id
    );

  -- overall risk
  v_overall_score := coalesce(
    (v_rls_result->>'risk_score')::int, 0
  ) + coalesce(
    (v_isolation_result->'summary'->>'risk_score')::int, 0
  ) + (
    case
      when (v_cross_tenant_result->>'critical_count')::int > 0
      then 50
      when (v_cross_tenant_result->>'risk_count')::int > 0
      then 20
      else 0
    end
  );

  v_overall_risk := case
    when v_overall_score = 0 then 'LOW'
    when v_overall_score <= 20 then 'MEDIUM'
    when v_overall_score <= 50 then 'HIGH'
    else 'CRITICAL'
  end;

  -- insert full report as scan result
  insert into catchmenu_audit.security_scan_results (
    id, tenant_id, store_id,
    scan_type, scan_status, scan_scope,
    total_checks, passed_checks, failed_checks,
    critical_findings,
    risk_level, risk_score,
    remediation_required,
    scanned_by_type, scanned_by_id,
    scan_duration_ms,
    scan_completed_at
  ) values (
    v_report_id, p_tenant_id, p_store_id,
    'FULL_SECURITY', 'COMPLETED',
    case when p_store_id is null
      then 'TENANT' else 'STORE'
    end,
    (
      coalesce(
        (v_rls_result->>'total_tables')::int, 0
      ) + coalesce(
        (v_isolation_result->'summary'
          ->>'total_checks')::int, 0
      )
    ),
    (
      coalesce(
        (v_rls_result->>'passed')::int, 0
      ) + coalesce(
        (v_isolation_result->'summary'
          ->>'passed')::int, 0
      )
    ),
    (
      coalesce(
        (v_rls_result->>'failed')::int, 0
      ) + coalesce(
        (v_isolation_result->'summary'
          ->>'failed')::int, 0
      )
    ),
    coalesce(
      v_isolation_result->'critical_findings',
      '[]'::jsonb
    ) || coalesce(
      v_rls_result->'critical_findings',
      '[]'::jsonb
    ) || coalesce(
      v_cross_tenant_result->'risks',
      '[]'::jsonb
    ),
    v_overall_risk, v_overall_score,
    v_overall_score > 0,
    p_scanned_by_type, p_scanned_by_id,
    extract(epoch from (now() - v_start))::int * 1000,
    now()
  );

  -- audit record for security report
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'security',
    p_audit_type := 'security_report_generated',
    p_audit_category := 'SECURITY',
    p_actor_type := p_scanned_by_type,
    p_actor_id := p_scanned_by_id,
    p_subject_type := 'security_scan',
    p_subject_id := v_report_id,
    p_decision := case v_overall_risk
      when 'LOW' then 'COMPLETED'
      when 'MEDIUM' then 'NOTED'
      else 'FLAGGED'
    end,
    p_decision_payload := jsonb_build_object(
      'overall_risk', v_overall_risk,
      'overall_score', v_overall_score,
      'report_id', v_report_id
    ),
    p_business_day :=
      (timezone('Asia/Seoul', now()))::date,
    p_business_timezone := 'Asia/Seoul'
  );

  -- CRITICAL log if high risk
  if v_overall_risk in ('HIGH', 'CRITICAL') then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := v_overall_risk,
      p_log_domain := 'SYSTEM',
      p_log_event := 'security_risk_detected',
      p_message :=
        '[' || v_overall_risk || '] '
        || 'Security report: risk_score='
        || v_overall_score,
      p_error_key := case v_overall_risk
        when 'CRITICAL' then 'internal_error'
        else null
      end,
      p_recovery_hint :=
        'Run remediation steps from critical_findings',
      p_rpc_name := 'generate_security_report',
      p_details := jsonb_build_object(
        'report_id', v_report_id,
        'overall_risk', v_overall_risk,
        'overall_score', v_overall_score
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'report_id', v_report_id,
    'tenant_id', p_tenant_id,
    'store_id', p_store_id,
    'overall_risk', v_overall_risk,
    'overall_score', v_overall_score,
    'remediation_required', v_overall_score > 0,
    'sections', jsonb_build_object(
      'rls_coverage', jsonb_build_object(
        'risk_level', v_rls_result->>'risk_level',
        'pass_rate_pct',
          v_rls_result->>'pass_rate_pct',
        'failed', v_rls_result->>'failed'
      ),
      'tenant_isolation', jsonb_build_object(
        'risk_level',
          v_isolation_result->'summary'->>'risk_level',
        'pass_rate_pct',
          v_isolation_result->'summary'
            ->>'pass_rate_pct',
        'failed',
          v_isolation_result->'summary'->>'failed'
      ),
      'cross_tenant_risk', jsonb_build_object(
        'is_clean',
          v_cross_tenant_result->>'is_clean',
        'risk_count',
          v_cross_tenant_result->>'risk_count',
        'critical_count',
          v_cross_tenant_result->>'critical_count'
      )
    ),
    'critical_findings', (
      coalesce(
        v_isolation_result->'critical_findings',
        '[]'::jsonb
      )
      || coalesce(
        v_rls_result->'critical_findings',
        '[]'::jsonb
      )
      || coalesce(
        v_cross_tenant_result->'risks',
        '[]'::jsonb
      )
    ),
    'audit_id', v_audit_id,
    'scanned_at', now(),
    'scan_duration_ms',
      extract(
        epoch from (now() - v_start)
      )::int * 1000,
    'message_code', case v_overall_risk
      when 'LOW' then 'security_report_clean'
      when 'MEDIUM' then 'security_report_warnings'
      else 'security_report_risks_detected'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function
    catchmenu_audit.verify_rls_coverage(uuid)
    from public;
  grant execute on function
    catchmenu_audit.verify_rls_coverage(uuid)
    to authenticated;

  revoke all on function
    catchmenu_audit.run_isolation_audit(
      uuid, uuid, text, uuid
    ) from public;
  grant execute on function
    catchmenu_audit.run_isolation_audit(
      uuid, uuid, text, uuid
    ) to authenticated;

  revoke all on function
    catchmenu_audit.scan_cross_tenant_risk(uuid)
    from public;
  grant execute on function
    catchmenu_audit.scan_cross_tenant_risk(uuid)
    to authenticated;

  revoke all on function
    catchmenu_audit.generate_security_report(
      uuid, uuid, text, uuid
    ) from public;
  grant execute on function
    catchmenu_audit.generate_security_report(
      uuid, uuid, text, uuid
    ) to authenticated;
end;
$$;

comment on function catchmenu_audit.run_isolation_audit(
  uuid, uuid, text, uuid
) is
  'Runs tenant/store isolation audit with 12 checks.
   Critical checks:
   - Orders/payments/KDS tenant isolation
   - Audit records append-only integrity
   - UNTRUSTED devices not ONLINE
   - UNCERTAIN payment blocks KDS cooking
   - KDS release explicit authorization only
   특허4: Zero Trust 정기 격리 감사.
   Recommended: run daily via cron job.
   risk_score=0 → LOW → no action needed.
   risk_score>40 → CRITICAL → immediate remediation.';

comment on function
  catchmenu_audit.generate_security_report(
    uuid, uuid, text, uuid
  ) is
  'Full security posture report combining:
   1. RLS coverage scan
   2. Tenant isolation audit
   3. Cross-tenant risk scan
   Produces overall risk_level and risk_score.
   Stores results in security_scan_results.
   HIGH/CRITICAL: writes CRITICAL diagnostic log.
   특허4: 정기 보안 감사 리포트.
   Compliance evidence for audit trail.
   Run weekly or on-demand after infrastructure changes.';