-- 0028_create_kds_capacity_commit_rpc.sql
-- Purpose: KDS capacity evaluation and Late Binding commit RPC.
--          Evaluates all 7 conditions for each KDS ticket.
--          When all conditions met: HOLD → READY_TO_COMMIT.
--          When conditions not met: updates conditions_met and stays HOLD.
--          특허2 core: KDS 수용상태 기반 Late Binding 조리 실행 큐 제어.
-- Depends on: 0027_create_payment_intent_rpc.sql
-- Creates:
--   function catchmenu_kds.evaluate_kds_capacity(...)
--   function catchmenu_kds.commit_kds_ticket(...)
--   function catchmenu_kds.authorize_kds_release(...)

create or replace function catchmenu_kds.evaluate_kds_capacity(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kitchen_zone text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_cooking_count int;
  v_hold_count int;
  v_ready_count int;
  v_capacity_ok boolean;
  v_threshold int := 8;
begin
  -- count active tickets per kitchen zone
  select
    count(*) filter (
      where kds_status in ('COOKING', 'READY_TO_COMMIT')
    ),
    count(*) filter (
      where kds_status in ('HOLD', 'CAPACITY_CHECKING')
    ),
    count(*) filter (
      where kds_status = 'READY'
    )
  into v_cooking_count, v_hold_count, v_ready_count
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and kds_status not in ('COMPLETED', 'CANCELLED', 'SERVED')
    and (
      p_kitchen_zone is null
      or kitchen_zone = p_kitchen_zone
    );

  -- capacity ok if cooking + ready_to_commit below threshold
  v_capacity_ok := v_cooking_count < v_threshold;

  return jsonb_build_object(
    'cooking_count', v_cooking_count,
    'hold_count', v_hold_count,
    'ready_count', v_ready_count,
    'capacity_ok', v_capacity_ok,
    'threshold', v_threshold,
    'kitchen_zone', p_kitchen_zone
  );
end;
$$;


create or replace function catchmenu_kds.commit_kds_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_conditions jsonb default '{}'::jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_merged_conditions jsonb;
  v_all_met boolean;
  v_capacity jsonb;
  v_audit_id uuid;
begin
  -- input validation
  if p_ticket_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_id_required'
    );
  end if;

  if jsonb_typeof(coalesce(p_conditions, '{}'::jsonb)) <> 'object' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'conditions_must_be_object'
    );
  end if;

  -- ticket validation with lock
  select
    kt.id, kt.store_id, kt.tenant_id,
    kt.order_id, kt.order_item_id, kt.session_id,
    kt.kds_status, kt.conditions_met,
    kt.kitchen_zone, kt.priority,
    kt.estimated_minutes_snapshot,
    kt.business_day, kt.business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets kt
  where kt.id = p_ticket_id
    and kt.store_id = p_store_id
    and kt.tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  -- ticket must be in holdable state
  if v_ticket.kds_status not in ('HOLD', 'CAPACITY_CHECKING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_holdable',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- merge incoming conditions with existing
  v_merged_conditions :=
    coalesce(v_ticket.conditions_met, '{}'::jsonb)
    || coalesce(p_conditions, '{}'::jsonb);

  -- evaluate KDS capacity for this kitchen zone
  v_capacity := catchmenu_kds.evaluate_kds_capacity(
    p_tenant_id,
    p_store_id,
    v_ticket.kitchen_zone
  );

  -- update kds_capacity_ok from real-time evaluation
  v_merged_conditions := v_merged_conditions || jsonb_build_object(
    'kds_capacity_ok',
    (v_capacity->>'capacity_ok')::boolean
  );

  -- check all 7 conditions
  -- 특허2: 7개 조건 모두 true일 때만 READY_TO_COMMIT 전환
  v_all_met := (
    coalesce(
      (v_merged_conditions->>'arrived')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'table_confirmed')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'payment_confirmed')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'kds_capacity_ok')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'menu_available')::boolean, true
    )
    and coalesce(
      (v_merged_conditions->>'peak_time_ok')::boolean, true
    )
    and coalesce(
      (v_merged_conditions->>'no_show_risk_ok')::boolean, true
    )
  );

  if v_all_met then
    -- all conditions met → READY_TO_COMMIT
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'READY_TO_COMMIT',
      conditions_met = v_merged_conditions,
      committed_at = now(),
      capacity_check_at = now(),
      kds_queue_length_at_check =
        (v_capacity->>'cooking_count')::int,
      updated_at = now()
    where id = p_ticket_id;

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id, ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type,
      conditions_at_event,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      p_ticket_id, v_ticket.order_id,
      'all_conditions_met',
      v_ticket.kds_status, 'READY_TO_COMMIT',
      'SYSTEM',
      v_merged_conditions,
      jsonb_build_object(
        'kitchen_zone', v_ticket.kitchen_zone,
        'kds_queue_length', v_capacity->>'cooking_count',
        'committed_at', now()
      ),
      p_correlation_id, now()
    );

    -- ledger event
    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, event_payload,
      order_id, kds_ticket_id,
      correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'kds', 'kds_committed', 1,
      'kds_ticket', p_ticket_id,
      v_ticket.kds_status, 'READY_TO_COMMIT',
      'SYSTEM',
      jsonb_build_object(
        'conditions_met', v_merged_conditions,
        'kitchen_zone', v_ticket.kitchen_zone,
        'late_binding_commit', true
      ),
      v_ticket.order_id, p_ticket_id,
      p_correlation_id,
      v_ticket.business_day, v_ticket.business_timezone, now()
    );

    -- audit record for KDS commit
    v_audit_id := catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'kds',
      p_audit_type := 'kds_committed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'SYSTEM',
      p_actor_id := null,
      p_subject_type := 'kds_ticket',
      p_subject_id := p_ticket_id,
      p_decision := 'APPROVED',
      p_decision_payload := jsonb_build_object(
        'conditions_met', v_merged_conditions,
        'kitchen_zone', v_ticket.kitchen_zone,
        'committed_at', now()
      ),
      p_before_state := jsonb_build_object(
        'kds_status', v_ticket.kds_status,
        'conditions_met', v_ticket.conditions_met
      ),
      p_after_state := jsonb_build_object(
        'kds_status', 'READY_TO_COMMIT',
        'conditions_met', v_merged_conditions
      ),
      p_order_id := v_ticket.order_id,
      p_kds_ticket_id := p_ticket_id,
      p_correlation_id := p_correlation_id,
      p_business_day := v_ticket.business_day,
      p_business_timezone := v_ticket.business_timezone
    );

    return jsonb_build_object(
      'success', true,
      'ticket_id', p_ticket_id,
      'kds_status', 'READY_TO_COMMIT',
      'conditions_met', v_merged_conditions,
      'committed_at', now(),
      'kitchen_zone', v_ticket.kitchen_zone,
      'audit_id', v_audit_id,
      'message_code', 'kds_committed'
    );

  else
    -- conditions not all met → CAPACITY_CHECKING
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'CAPACITY_CHECKING',
      conditions_met = v_merged_conditions,
      capacity_check_at = now(),
      kds_queue_length_at_check =
        (v_capacity->>'cooking_count')::int,
      updated_at = now()
    where id = p_ticket_id;

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id, ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type, conditions_at_event,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      p_ticket_id, v_ticket.order_id,
      'condition_updated',
      v_ticket.kds_status, 'CAPACITY_CHECKING',
      'SYSTEM', v_merged_conditions,
      jsonb_build_object(
        'missing_conditions', jsonb_build_object(
          'arrived',
            coalesce(
              (v_merged_conditions->>'arrived')::boolean, false
            ),
          'table_confirmed',
            coalesce(
              (v_merged_conditions->>'table_confirmed')::boolean,
              false
            ),
          'payment_confirmed',
            coalesce(
              (v_merged_conditions->>'payment_confirmed')::boolean,
              false
            ),
          'kds_capacity_ok',
            coalesce(
              (v_merged_conditions->>'kds_capacity_ok')::boolean,
              false
            ),
          'menu_available',
            coalesce(
              (v_merged_conditions->>'menu_available')::boolean,
              true
            )
        ),
        'kitchen_zone', v_ticket.kitchen_zone
      ),
      p_correlation_id, now()
    );

    return jsonb_build_object(
      'success', true,
      'ticket_id', p_ticket_id,
      'kds_status', 'CAPACITY_CHECKING',
      'conditions_met', v_merged_conditions,
      'all_conditions_met', false,
      'missing_conditions', jsonb_build_object(
        'arrived',
          coalesce(
            (v_merged_conditions->>'arrived')::boolean, false
          ),
        'table_confirmed',
          coalesce(
            (v_merged_conditions->>'table_confirmed')::boolean,
            false
          ),
        'payment_confirmed',
          coalesce(
            (v_merged_conditions->>'payment_confirmed')::boolean,
            false
          ),
        'kds_capacity_ok',
          coalesce(
            (v_merged_conditions->>'kds_capacity_ok')::boolean,
            false
          ),
        'menu_available',
          coalesce(
            (v_merged_conditions->>'menu_available')::boolean,
            true
          )
      ),
      'capacity_detail', v_capacity,
      'message_code', 'kds_conditions_pending'
    );
  end if;
end;
$$;


create or replace function catchmenu_kds.authorize_kds_release(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_actor_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_ledger record;
  v_audit_id uuid;
  v_tickets_ready int;
begin
  -- ledger validation
  select id, order_id, session_id,
         ledger_status, reconciliation_status,
         kds_release_authorized,
         business_day, business_timezone
  into v_ledger
  from catchmenu_payment.payment_ledger
  where id = p_ledger_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ledger.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_found'
    );
  end if;

  if v_ledger.kds_release_authorized then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_already_authorized'
    );
  end if;

  if v_ledger.ledger_status <> 'APPROVED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_approved',
      'ledger_status', v_ledger.ledger_status
    );
  end if;

  -- check no active PAYMENT_UNCERTAIN exception
  if exists (
    select 1
    from catchmenu_ledger.exceptions
    where subject_type = 'payment_intent'
      and store_id = p_store_id
      and exception_type = 'payment_uncertain'
      and exception_status in (
        'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY'
      )
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_uncertain_active',
      'message', 'Cannot authorize KDS release while PAYMENT_UNCERTAIN is open'
    );
  end if;

  -- authorize KDS release
  -- 특허1: 결제 원장 확인 + 불확실 예외 없음 → KDS 릴리즈 허용
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = p_actor_type,
    updated_at = now()
  where id = p_ledger_id;

  -- count tickets that become releasable
  select count(*)
  into v_tickets_ready
  from catchmenu_kds.kds_tickets
  where order_id = v_ledger.order_id
    and kds_status in ('READY_TO_COMMIT', 'CAPACITY_CHECKING')
    and (conditions_met->>'payment_confirmed')::boolean = true;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    v_ledger.order_id, p_ledger_id,
    'kds_release_authorized',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_releasable', v_tickets_ready,
      'authorized_at', now()
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'kds_release_authorized', 1,
    'payment_ledger', p_ledger_id,
    'APPROVED_NO_KDS_RELEASE', 'APPROVED_KDS_AUTHORIZED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_releasable', v_tickets_ready,
      'authorized_at', now()
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'kds_release_authorized',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'kds_release_authorized', true,
      'kds_tickets_releasable', v_tickets_ready,
      'authorized_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_release_authorized', false
    ),
    p_after_state := jsonb_build_object(
      'kds_release_authorized', true
    ),
    p_payment_id := p_ledger_id,
    p_order_id := v_ledger.order_id,
    p_session_id := v_ledger.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ledger.business_day,
    p_business_timezone := v_ledger.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', p_ledger_id,
    'kds_release_authorized', true,
    'kds_tickets_releasable', v_tickets_ready,
    'authorized_at', now(),
    'next_step', 'RUN_KDS_COMMIT_FOR_EACH_TICKET',
    'message_code', 'kds_release_authorized',
    'audit_id', v_audit_id
  );
end;
$$;

-- grants
revoke all on function catchmenu_kds.evaluate_kds_capacity(
  uuid, uuid, text
) from public;
grant execute on function catchmenu_kds.evaluate_kds_capacity(
  uuid, uuid, text
) to authenticated;

revoke all on function catchmenu_kds.commit_kds_ticket(
  uuid, uuid, uuid, jsonb, text
) from public;
grant execute on function catchmenu_kds.commit_kds_ticket(
  uuid, uuid, uuid, jsonb, text
) to authenticated;

revoke all on function catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
) from public;
grant execute on function catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
) to authenticated;

comment on function catchmenu_kds.evaluate_kds_capacity(
  uuid, uuid, text
) is
  'Evaluates current KDS kitchen load per zone.
   Returns capacity_ok = true when cooking count below threshold.
   Called by commit_kds_ticket to check kds_capacity_ok condition.
   특허2: KDS 수용상태 실시간 판단 — 조리 큐 투입 가능 여부 결정.';

comment on function catchmenu_kds.commit_kds_ticket(
  uuid, uuid, uuid, jsonb, text
) is
  'KDS Late Binding commit RPC. Core of 특허2.
   Merges incoming conditions with existing conditions_met.
   Evaluates real-time KDS capacity for kitchen zone.
   When all 7 conditions true → HOLD/CAPACITY_CHECKING → READY_TO_COMMIT.
   Otherwise → stays CAPACITY_CHECKING with updated conditions.
   Conditions: arrived, table_confirmed, payment_confirmed,
               kds_capacity_ok, menu_available,
               peak_time_ok, no_show_risk_ok.
   특허2: 7개 조건 모두 충족 시 조리 실행 큐 투입.';

comment on function catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
) is
  'Authorizes KDS release for a payment ledger entry.
   Sets kds_release_authorized = TRUE on payment_ledger.
   Requires ledger_status = APPROVED AND no active PAYMENT_UNCERTAIN.
   This is a separate step from payment approval.
   특허1: 결제 승인 ≠ KDS 자동 릴리즈.
          별도 authorize 단계 필수.
   After this: run commit_kds_ticket for each ticket in READY_TO_COMMIT.';