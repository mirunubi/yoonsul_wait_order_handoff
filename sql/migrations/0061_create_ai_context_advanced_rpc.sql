-- 0061_create_ai_context_advanced_rpc.sql
-- Purpose: Advanced AI context builder RPCs.
--          build_operational_context: assembles real-time
--            store operational state for AI Engine.
--          build_exception_context: builds context for
--            exception resolution guidance.
--          build_sop_recommendation_context: builds context
--            for SOP recommendation based on current conditions.
--          record_ai_resolution_outcome: records AI-guided
--            resolution result for feedback loop.
--          특허3 core: Context Builder 고도화 — 다층 컨텍스트 조립.
-- Depends on: 0060_create_franchise_hq_rpc.sql
-- Creates:
--   function catchmenu_knowledge.build_operational_context(...)
--   function catchmenu_knowledge.build_exception_context(...)
--   function catchmenu_knowledge.build_sop_recommendation_context(...)
--   function catchmenu_knowledge.record_ai_resolution_outcome(...)

create or replace function
  catchmenu_knowledge.build_operational_context(
  p_tenant_id uuid,
  p_store_id uuid,
  p_context_depth text default 'STANDARD',
  p_include_kds boolean default true,
  p_include_payment boolean default false,
  p_include_inventory boolean default false,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_store,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_business_day date;
  v_context_id uuid;
  v_session_state jsonb;
  v_kds_state jsonb;
  v_payment_state jsonb;
  v_inventory_state jsonb;
  v_exception_state jsonb;
  v_store_mode text;
  v_agent_state jsonb;
begin
  if p_context_depth not in (
    'MINIMAL', 'STANDARD', 'DEEP'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_context_depth'
    );
  end if;

  select id, store_name, store_type,
         store_status, timezone
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

  v_business_day := (timezone(
    v_store.timezone, now()
  ))::date;

  -- store mode
  select store_mode
  into v_store_mode
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- session state
  select jsonb_build_object(
    'active_sessions', count(*) filter (
      where session_status not in (
        'COMPLETED', 'CANCELLED',
        'EXPIRED', 'NO_SHOW'
      )
    ),
    'waiting_sessions', count(*) filter (
      where session_status = 'WAITING'
    ),
    'arrival_pending', count(*) filter (
      where session_status = 'ARRIVAL_PENDING'
    ),
    'ordering_sessions', count(*) filter (
      where session_status = 'ORDERING'
    ),
    'pre_order_sessions', count(*) filter (
      where session_type = 'PRE_ORDER'
        and session_status not in (
          'COMPLETED', 'CANCELLED',
          'EXPIRED', 'NO_SHOW'
        )
    ),
    'today_completed', count(*) filter (
      where session_status = 'COMPLETED'
        and business_day = v_business_day
    )
  )
  into v_session_state
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- KDS state
  if p_include_kds then
    select jsonb_build_object(
      'hold_count', count(*) filter (
        where kds_status = 'HOLD'
      ),
      'capacity_checking_count', count(*) filter (
        where kds_status = 'CAPACITY_CHECKING'
      ),
      'cooking_count', count(*) filter (
        where kds_status = 'COOKING'
      ),
      'ready_count', count(*) filter (
        where kds_status = 'READY'
      ),
      'overdue_count', count(*) filter (
        where kds_status = 'COOKING'
          and cooking_started_at is not null
          and extract(
            epoch from (
              now() - cooking_started_at
            )
          ) / 60 > coalesce(
            estimated_minutes_snapshot, 999
          )
      ),
      'manual_fallback_active', bool_or(
        manual_fallback_activated
      ),
      'by_zone', (
        select coalesce(
          jsonb_object_agg(
            coalesce(kitchen_zone, 'GENERAL'),
            jsonb_build_object(
              'cooking', count(*) filter (
                where kds_status = 'COOKING'
              ),
              'hold', count(*) filter (
                where kds_status in (
                  'HOLD', 'CAPACITY_CHECKING'
                )
              )
            )
          ),
          '{}'::jsonb
        )
        from catchmenu_kds.kds_tickets kt2
        where kt2.store_id = p_store_id
          and kt2.tenant_id = p_tenant_id
          and kt2.business_day = v_business_day
          and kt2.kds_status not in (
            'COMPLETED', 'CANCELLED', 'SERVED'
          )
        group by kitchen_zone
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

  -- payment state (DEEP only by default)
  if p_include_payment
    or p_context_depth = 'DEEP'
  then
    select jsonb_build_object(
      'uncertain_count', count(*) filter (
        where ledger_status = 'UNCERTAIN'
      ),
      'pending_reconciliation', count(*) filter (
        where reconciliation_status = 'PENDING'
      ),
      'today_net_revenue', coalesce(
        sum(net_amount) filter (
          where ledger_status = 'APPROVED'
        ), 0
      ),
      'today_tx_count', count(*) filter (
        where ledger_status = 'APPROVED'
      )
    )
    into v_payment_state
    from catchmenu_payment.payment_ledger
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day;
  end if;

  -- inventory state
  if p_include_inventory
    or p_context_depth = 'DEEP'
  then
    select jsonb_build_object(
      'out_of_stock_count', count(*) filter (
        where ingredient_status = 'OUT_OF_STOCK'
      ),
      'low_stock_count', count(*) filter (
        where ingredient_status = 'LOW_STOCK'
      ),
      'critical_items', coalesce(
        jsonb_agg(
          jsonb_build_object(
            'ingredient_name', ingredient_name,
            'status', ingredient_status,
            'current_qty', current_quantity,
            'linked_menus',
              jsonb_array_length(linked_menu_ids)
          )
        ) filter (
          where ingredient_status in (
            'OUT_OF_STOCK', 'LOW_STOCK'
          )
          and jsonb_array_length(
            linked_menu_ids
          ) > 0
        ),
        '[]'::jsonb
      )
    )
    into v_inventory_state
    from catchmenu_store.ingredients
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;
  end if;

  -- exception state (always included)
  select jsonb_build_object(
    'open_count', count(*) filter (
      where exception_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    ),
    'critical_count', count(*) filter (
      where exception_severity in (
        'CRITICAL', 'FATAL'
      )
      and exception_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    ),
    'in_recovery_count', count(*) filter (
      where exception_status = 'IN_RECOVERY'
    ),
    'recent_exceptions', coalesce(
      jsonb_agg(
        jsonb_build_object(
          'exception_type', exception_type,
          'exception_domain', exception_domain,
          'severity', exception_severity,
          'status', exception_status,
          'detected_at', detected_at
        )
        order by detected_at desc
      ) filter (
        where exception_status in (
          'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY'
        )
        and detected_at >= now()
          - interval '2 hours'
      ),
      '[]'::jsonb
    )
  )
  into v_exception_state
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- agent state (STANDARD+)
  if p_context_depth in ('STANDARD', 'DEEP') then
    select jsonb_build_object(
      'online_agents', count(*) filter (
        where agent_status = 'ONLINE'
      ),
      'isolated_agents', count(*) filter (
        where agent_status = 'ISOLATED'
      ),
      'degraded_agents', count(*) filter (
        where agent_status = 'DEGRADED'
      ),
      'agents', coalesce(
        jsonb_agg(
          jsonb_build_object(
            'agent_code', agent_code,
            'agent_type', agent_type,
            'agent_status', agent_status,
            'last_heartbeat_at', last_heartbeat_at
          )
        ),
        '[]'::jsonb
      )
    )
    into v_agent_state
    from catchmenu_store.agent_registry
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;
  end if;

  v_context_id := gen_random_uuid();

  -- log context build
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'knowledge', 'operational_context_built', 1,
    'knowledge_context', v_context_id,
    null, 'BUILT',
    'SYSTEM',
    jsonb_build_object(
      'context_depth', p_context_depth,
      'include_kds', p_include_kds,
      'include_payment', p_include_payment,
      'include_inventory', p_include_inventory,
      'open_exceptions',
        (v_exception_state->>'open_count')::int
    ),
    p_correlation_id,
    v_business_day, v_store.timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'context_id', v_context_id,
    'context_depth', p_context_depth,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_type', v_store.store_type,
      'store_status', v_store.store_status,
      'store_mode', coalesce(
        v_store_mode, 'NORMAL'
      )
    ),
    'business_day', v_business_day,
    'sessions', v_session_state,
    'kds', case
      when p_include_kds then v_kds_state
      else null
    end,
    'payment', case
      when p_include_payment
        or p_context_depth = 'DEEP'
      then v_payment_state
      else null
    end,
    'inventory', case
      when p_include_inventory
        or p_context_depth = 'DEEP'
      then v_inventory_state
      else null
    end,
    'exceptions', v_exception_state,
    'agents', v_agent_state,
    'safety', jsonb_build_object(
      'raw_db_accessed', false,
      'pii_excluded', true,
      'context_ttl_seconds', 60,
      'source_traceable', true
    ),
    'built_at', now(),
    'message_code', 'operational_context_built'
  );
end;
$$;


create or replace function
  catchmenu_knowledge.build_exception_context(
  p_tenant_id uuid,
  p_store_id uuid,
  p_exception_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_exception record;
  v_related_events jsonb;
  v_related_exceptions jsonb;
  v_sop_documents jsonb;
  v_context_id uuid;
begin
  -- get exception details
  select id, exception_domain, exception_type,
         exception_severity, exception_status,
         subject_type, subject_id,
         error_message, exception_payload,
         occurrence_count, detected_at,
         business_day, business_timezone
  into v_exception
  from catchmenu_ledger.exceptions
  where id = p_exception_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_exception.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'exception_not_found'
    );
  end if;

  -- related events for the subject
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'event_type', event_type,
        'event_domain', event_domain,
        'from_state', from_state,
        'to_state', to_state,
        'occurred_at', occurred_at
      )
      order by occurred_at desc
    ),
    '[]'::jsonb
  )
  into v_related_events
  from catchmenu_ledger.events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and subject_type = v_exception.subject_type
    and subject_id = v_exception.subject_id
    and occurred_at >= now() - interval '1 hour'
  limit 20;

  -- similar open exceptions
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'exception_type', exception_type,
        'exception_severity', exception_severity,
        'exception_status', exception_status,
        'occurrence_count', occurrence_count,
        'detected_at', detected_at
      )
      order by detected_at desc
    ),
    '[]'::jsonb
  )
  into v_related_exceptions
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and exception_type = v_exception.exception_type
    and id <> p_exception_id
    and exception_status in (
      'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY'
    )
  limit 5;

  -- SOP documents for this exception domain
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'document_id', id,
        'document_type', document_type,
        'title', title,
        'summary', summary,
        'effectiveness_score',
          effectiveness_score,
        'last_used_at', last_used_at
      )
      order by effectiveness_score desc nulls last
    ),
    '[]'::jsonb
  )
  into v_sop_documents
  from catchmenu_knowledge.documents
  where tenant_id = p_tenant_id
    and document_status = 'PUBLISHED'
    and is_ai_retrievable = true
    and domain = v_exception.exception_domain
  limit 5;

  v_context_id := gen_random_uuid();

  return jsonb_build_object(
    'success', true,
    'context_id', v_context_id,
    'exception', jsonb_build_object(
      'id', v_exception.id,
      'exception_domain',
        v_exception.exception_domain,
      'exception_type', v_exception.exception_type,
      'exception_severity',
        v_exception.exception_severity,
      'exception_status',
        v_exception.exception_status,
      'subject_type', v_exception.subject_type,
      'subject_id', v_exception.subject_id,
      'error_message', v_exception.error_message,
      'exception_payload',
        v_exception.exception_payload,
      'occurrence_count',
        v_exception.occurrence_count,
      'detected_at', v_exception.detected_at
    ),
    'related_events', v_related_events,
    'related_exceptions', v_related_exceptions,
    'sop_documents', v_sop_documents,
    'safety', jsonb_build_object(
      'raw_db_accessed', false,
      'pii_excluded', true,
      'context_ttl_seconds', 120
    ),
    'built_at', now(),
    'message_code', 'exception_context_built'
  );
end;
$$;


create or replace function
  catchmenu_knowledge.build_sop_recommendation_context(
  p_tenant_id uuid,
  p_store_id uuid,
  p_recommendation_domain text,
  p_trigger_event_type text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_business_day date;
  v_timezone text;
  v_context_id uuid;
  v_applicable_sops jsonb;
  v_recent_outcomes jsonb;
  v_domain_stats jsonb;
  v_knowledge_gaps jsonb;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- get applicable SOPs for domain
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'document_id', d.id,
        'document_code', d.document_code,
        'document_type', d.document_type,
        'title', d.title,
        'summary', d.summary,
        'domain', d.domain,
        'effectiveness_score',
          d.effectiveness_score,
        'applied_count', dv.applied_count,
        'success_count', dv.success_count,
        'success_rate_pct', case
          when coalesce(dv.applied_count, 0) = 0
          then null
          else (
            dv.success_count::numeric
            / dv.applied_count * 100
          )::int
        end,
        'last_used_at', d.last_used_at
      )
      order by d.effectiveness_score desc nulls last,
               d.last_used_at desc nulls last
    ),
    '[]'::jsonb
  )
  into v_applicable_sops
  from catchmenu_knowledge.documents d
  left join catchmenu_knowledge.document_versions dv
    on dv.id = d.current_version_id
  where d.tenant_id = p_tenant_id
    and d.document_status = 'PUBLISHED'
    and d.is_ai_retrievable = true
    and d.domain = p_recommendation_domain
    and d.document_type in ('SOP', 'RUNBOOK')
  limit 10;

  -- recent resolution outcomes for this domain
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'exception_type', exception_type,
        'resolution_type', resolution_type,
        'resolved_at', resolved_at,
        'occurrence_count', occurrence_count
      )
      order by resolved_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_outcomes
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and exception_domain = p_recommendation_domain
    and exception_status = 'RESOLVED'
    and resolved_at >= now() - interval '7 days'
  limit 10;

  -- domain stats
  select jsonb_build_object(
    'open_exceptions', count(*) filter (
      where exception_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
      and business_day = v_business_day
    ),
    'resolved_today', count(*) filter (
      where exception_status = 'RESOLVED'
        and business_day = v_business_day
    ),
    'recurring_types', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'exception_type', exception_type,
            'count', cnt
          )
          order by cnt desc
        ),
        '[]'::jsonb
      )
      from (
        select exception_type,
               count(*) as cnt
        from catchmenu_ledger.exceptions
        where store_id = p_store_id
          and exception_domain =
            p_recommendation_domain
          and detected_at >= now()
            - interval '7 days'
        group by exception_type
        having count(*) >= 3
        limit 5
      ) recurring
    )
  )
  into v_domain_stats
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and exception_domain = p_recommendation_domain;

  -- open knowledge gaps for domain
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'gap_id', id,
        'gap_type', gap_type,
        'gap_summary', gap_summary,
        'occurrence_count', occurrence_count,
        'gap_status', gap_status,
        'first_detected_at', first_detected_at
      )
      order by occurrence_count desc
    ),
    '[]'::jsonb
  )
  into v_knowledge_gaps
  from catchmenu_knowledge.knowledge_gaps
  where tenant_id = p_tenant_id
    and domain = p_recommendation_domain
    and gap_status not in (
      'RESOLVED', 'DISMISSED'
    )
  limit 5;

  v_context_id := gen_random_uuid();

  return jsonb_build_object(
    'success', true,
    'context_id', v_context_id,
    'recommendation_domain', p_recommendation_domain,
    'trigger_event_type', p_trigger_event_type,
    'business_day', v_business_day,
    'applicable_sops', v_applicable_sops,
    'sop_count', jsonb_array_length(
      coalesce(v_applicable_sops, '[]'::jsonb)
    ),
    'recent_outcomes', v_recent_outcomes,
    'domain_stats', v_domain_stats,
    'knowledge_gaps', v_knowledge_gaps,
    'safety', jsonb_build_object(
      'raw_db_accessed', false,
      'pii_excluded', true,
      'context_ttl_seconds', 300
    ),
    'built_at', now(),
    'message_code', 'sop_recommendation_context_built'
  );
end;
$$;


create or replace function
  catchmenu_knowledge.record_ai_resolution_outcome(
  p_tenant_id uuid,
  p_store_id uuid,
  p_exception_id uuid,
  p_context_id uuid,
  p_sop_document_id uuid,
  p_resolution_outcome text,
  p_resolution_time_minutes int default null,
  p_staff_feedback text default null,
  p_ai_recommendation_used boolean default true,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_knowledge,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_business_day date;
  v_timezone text;
  v_gap_detection_result jsonb;
  v_feedback_result jsonb;
begin
  if p_resolution_outcome not in (
    'SUCCESS', 'FAILURE', 'PARTIAL', 'ESCALATED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_resolution_outcome'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- record SOP feedback if document provided
  if p_sop_document_id is not null then
    -- get current version
    declare
      v_version_id uuid;
    begin
      select current_version_id
      into v_version_id
      from catchmenu_knowledge.documents
      where id = p_sop_document_id
        and tenant_id = p_tenant_id;

      if v_version_id is not null then
        v_feedback_result :=
          catchmenu_knowledge.record_sop_feedback(
            p_tenant_id := p_tenant_id,
            p_version_id := v_version_id,
            p_outcome := case p_resolution_outcome
              when 'ESCALATED' then 'FAILURE'
              else p_resolution_outcome
            end,
            p_exception_context := jsonb_build_object(
              'exception_id', p_exception_id,
              'context_id', p_context_id,
              'resolution_time_minutes',
                p_resolution_time_minutes,
              'ai_recommendation_used',
                p_ai_recommendation_used
            ),
            p_feedback_note := p_staff_feedback,
            p_correlation_id := p_correlation_id
          );
      end if;
    end;
  end if;

  -- if AI recommendation not helpful or failed:
  -- trigger knowledge gap detection
  if p_resolution_outcome in ('FAILURE', 'ESCALATED')
    or not p_ai_recommendation_used
  then
    v_gap_detection_result :=
      catchmenu_knowledge.detect_knowledge_gap(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_gap_type := case p_resolution_outcome
          when 'FAILURE' then 'INADEQUATE_SOP'
          when 'ESCALATED' then 'MISSING_ESCALATION_PATH'
          else 'AI_RECOMMENDATION_REJECTED'
        end,
        p_domain := 'system',
        p_gap_summary :=
          'AI resolution outcome: '
          || p_resolution_outcome
          || '. Staff feedback: '
          || coalesce(p_staff_feedback, 'none'),
        p_triggering_exception_ids :=
          jsonb_build_array(p_exception_id),
        p_gap_context := jsonb_build_object(
          'exception_id', p_exception_id,
          'context_id', p_context_id,
          'sop_document_id', p_sop_document_id,
          'resolution_outcome', p_resolution_outcome,
          'resolution_time_minutes',
            p_resolution_time_minutes,
          'ai_recommendation_used',
            p_ai_recommendation_used,
          'staff_feedback', p_staff_feedback
        ),
        p_existing_document_id := p_sop_document_id,
        p_detection_threshold := 2,
        p_correlation_id := p_correlation_id
      );
  end if;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'knowledge', 'ai_resolution_outcome_recorded', 1,
    'knowledge_context', p_context_id,
    null, p_resolution_outcome,
    'SYSTEM',
    jsonb_build_object(
      'exception_id', p_exception_id,
      'sop_document_id', p_sop_document_id,
      'resolution_outcome', p_resolution_outcome,
      'resolution_time_minutes',
        p_resolution_time_minutes,
      'ai_recommendation_used',
        p_ai_recommendation_used,
      'gap_detection_triggered',
        v_gap_detection_result is not null
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'context_id', p_context_id,
    'exception_id', p_exception_id,
    'resolution_outcome', p_resolution_outcome,
    'sop_feedback_recorded',
      v_feedback_result is not null
      and (v_feedback_result->>'success')::boolean,
    'gap_detection_triggered',
      v_gap_detection_result is not null,
    'gap_detection_result', v_gap_detection_result,
    'message_code', 'ai_resolution_outcome_recorded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function
    catchmenu_knowledge.build_operational_context(
      uuid, uuid, text, boolean, boolean, boolean, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.build_operational_context(
      uuid, uuid, text, boolean, boolean, boolean, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.build_exception_context(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.build_exception_context(
      uuid, uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.build_sop_recommendation_context(
      uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.build_sop_recommendation_context(
      uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_knowledge.record_ai_resolution_outcome(
      uuid, uuid, uuid, uuid, uuid,
      text, int, text, boolean, text
    ) from public;
  grant execute on function
    catchmenu_knowledge.record_ai_resolution_outcome(
      uuid, uuid, uuid, uuid, uuid,
      text, int, text, boolean, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_knowledge.build_operational_context(
    uuid, uuid, text, boolean, boolean, boolean, text
  ) is
  'Assembles multi-layer real-time operational context.
   MINIMAL: sessions + exceptions only.
   STANDARD: + KDS + agents.
   DEEP: + payment + inventory.
   특허3: 다층 컨텍스트 조립 — AI Engine에 전달.
   AI는 절대 직접 DB 조회 불가.
   build_operational_context → AI Engine Interface
   → AI Response → 직원 화면.
   context_ttl_seconds: 60 (실시간 운영 데이터).';

comment on function
  catchmenu_knowledge.build_exception_context(
    uuid, uuid, uuid, text
  ) is
  'Builds focused context for exception resolution.
   Includes: exception details, related events,
   similar open exceptions, applicable SOP documents.
   특허3: 장애 상황 컨텍스트 조립.
   Fault Detection Agent → build_exception_context
   → SOP Selection Agent → 직원 추천 화면.';

comment on function
  catchmenu_knowledge.build_sop_recommendation_context(
    uuid, uuid, text, text, text
  ) is
  'Builds context for SOP recommendation based on domain.
   Returns applicable SOPs ranked by effectiveness.
   Includes domain stats, recurring exception types,
   open knowledge gaps.
   특허3: SOP 추천 컨텍스트 조립.
   SOP Selection Agent → build_sop_recommendation_context
   → 효과성 순위 기반 SOP 추천 → 직원 실행.';

comment on function
  catchmenu_knowledge.record_ai_resolution_outcome(
    uuid, uuid, uuid, uuid, uuid,
    text, int, text, boolean, text
  ) is
  'Records AI-guided resolution outcome for feedback loop.
   SUCCESS: updates SOP effectiveness score.
   FAILURE/ESCALATED: triggers Knowledge Gap detection.
   ai_recommendation_used = false: gap detection triggered.
   특허3: 자동 피드백 반영 구조.
   AI 추천 → 사람 실행 → 결과 기록 → 피드백 루프.
   실패 누적 → Knowledge Gap → SOP Evolution → 재검증.';