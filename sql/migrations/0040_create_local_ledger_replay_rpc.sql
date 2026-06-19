-- 0040_create_local_ledger_replay_rpc.sql
-- Purpose: Local temporary ledger replay and conflict resolution RPCs.
--          replay_local_ledger: replays entries after network recovery.
--          resolve_replay_conflict: manager resolves conflicting entries.
--          get_replay_status: returns replay progress summary.
--          특허4 core: Local Temporary Ledger + Event Replay 기반 복구.
-- Depends on: 0039_create_kds_bulk_commit_rpc.sql
-- Creates:
--   function catchmenu_ledger.replay_local_ledger(...)
--   function catchmenu_ledger.resolve_replay_conflict(...)
--   function catchmenu_ledger.get_replay_status(...)

create or replace function catchmenu_ledger.replay_local_ledger(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_max_entries int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_entry record;
  v_replayed_count int := 0;
  v_conflict_count int := 0;
  v_skipped_count int := 0;
  v_failed_count int := 0;
  v_central_event_id uuid;
  v_conflict_detail jsonb;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
  v_gap_detected boolean := false;
  v_last_sequence int := 0;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- verify device belongs to store
  if not exists (
    select 1
    from catchmenu_store.device_registry
    where id = p_device_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_not_found'
    );
  end if;

  -- process entries in sequence order
  for v_entry in
    select
      id, entry_type, entry_domain,
      entry_sequence, original_event_type,
      original_subject_type, original_subject_id,
      entry_payload, locally_recorded_at
    from catchmenu_ledger.local_temporary_ledger
    where device_id = p_device_id
      and tenant_id = p_tenant_id
      and replay_status = 'PENDING'
    order by entry_sequence asc
    limit p_max_entries
    for update skip locked
  loop
    -- gap detection in sequence
    if v_last_sequence > 0
      and v_entry.entry_sequence > v_last_sequence + 1
    then
      v_gap_detected := true;
      -- log gap as exception
      perform catchmenu_ledger.create_exception(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_exception_domain := 'system',
        p_exception_type := 'local_ledger_sequence_gap',
        p_exception_severity := 'WARNING',
        p_subject_type := 'device',
        p_subject_id := p_device_id,
        p_error_message := format(
          'Sequence gap detected: expected %s, got %s',
          v_last_sequence + 1,
          v_entry.entry_sequence
        ),
        p_exception_payload := jsonb_build_object(
          'expected_sequence', v_last_sequence + 1,
          'actual_sequence', v_entry.entry_sequence,
          'device_id', p_device_id
        ),
        p_correlation_id := p_correlation_id
      );
    end if;

    v_last_sequence := v_entry.entry_sequence;

    -- mark as in progress
    update catchmenu_ledger.local_temporary_ledger
    set
      replay_status = 'IN_PROGRESS',
      replay_attempted_at = now(),
      replay_attempt_count = replay_attempt_count + 1
    where id = v_entry.id;

    -- conflict detection
    v_conflict_detail := null;

    -- check if subject already has newer events in central ledger
    if v_entry.original_subject_id is not null then
      if exists (
        select 1
        from catchmenu_ledger.events
        where subject_type = v_entry.original_subject_type
          and subject_id = v_entry.original_subject_id
          and occurred_at > v_entry.locally_recorded_at
          and is_replay = false
      ) then
        -- newer central event exists — potential conflict
        v_conflict_detail := jsonb_build_object(
          'conflict_type', 'NEWER_CENTRAL_EVENT',
          'subject_type', v_entry.original_subject_type,
          'subject_id', v_entry.original_subject_id,
          'local_recorded_at', v_entry.locally_recorded_at,
          'message', 'Central ledger has newer events for this subject'
        );
      end if;
    end if;

    if v_conflict_detail is not null then
      -- conflict detected — hold for manual review
      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'CONFLICT_DETECTED',
        replay_conflict_detected = true,
        replay_conflict_detail = v_conflict_detail,
        network_restored_at = coalesce(network_restored_at, now())
      where id = v_entry.id;

      v_conflict_count := v_conflict_count + 1;

    else
      -- safe to replay — insert into central event ledger
      begin
        insert into catchmenu_ledger.events (
          tenant_id, store_id,
          event_domain, event_type, event_version,
          subject_type, subject_id,
          from_state, to_state,
          caused_by_type,
          event_payload,
          is_replay, original_event_id,
          correlation_id,
          business_day, business_timezone,
          occurred_at, recorded_at
        ) values (
          p_tenant_id, p_store_id,
          v_entry.entry_domain,
          v_entry.original_event_type,
          1,
          v_entry.original_subject_type,
          v_entry.original_subject_id,
          v_entry.entry_payload->>'from_state',
          v_entry.entry_payload->>'to_state',
          coalesce(
            v_entry.entry_payload->>'caused_by_type',
            'REPLAY'
          ),
          v_entry.entry_payload,
          true, v_entry.id,
          p_correlation_id,
          v_business_day, v_timezone,
          v_entry.locally_recorded_at,
          now()
        )
        returning id into v_central_event_id;

        -- mark as replayed
        update catchmenu_ledger.local_temporary_ledger
        set
          replay_status = 'REPLAYED',
          replay_completed_at = now(),
          central_event_id = v_central_event_id,
          network_restored_at = coalesce(network_restored_at, now())
        where id = v_entry.id;

        v_replayed_count := v_replayed_count + 1;

      exception when others then
        -- replay failed
        update catchmenu_ledger.local_temporary_ledger
        set
          replay_status = 'FAILED',
          replay_conflict_detail = jsonb_build_object(
            'error', sqlerrm,
            'sqlstate', sqlstate
          )
        where id = v_entry.id;

        v_failed_count := v_failed_count + 1;
      end;
    end if;
  end loop;

  -- audit replay session
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'recovery',
    p_audit_type := 'local_ledger_replay_completed',
    p_audit_category := 'RECOVERY',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'device',
    p_subject_id := p_device_id,
    p_decision := case
      when v_conflict_count > 0 then 'NOTED'
      else 'COMPLETED'
    end,
    p_decision_payload := jsonb_build_object(
      'replayed_count', v_replayed_count,
      'conflict_count', v_conflict_count,
      'failed_count', v_failed_count,
      'gap_detected', v_gap_detected
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'device_id', p_device_id,
    'replayed_count', v_replayed_count,
    'conflict_count', v_conflict_count,
    'failed_count', v_failed_count,
    'skipped_count', v_skipped_count,
    'total_processed',
      v_replayed_count + v_conflict_count + v_failed_count,
    'gap_detected', v_gap_detected,
    'has_conflicts', v_conflict_count > 0,
    'has_failures', v_failed_count > 0,
    'audit_id', v_audit_id,
    'message_code', case
      when v_conflict_count = 0 and v_failed_count = 0
      then 'replay_completed_clean'
      when v_conflict_count > 0
      then 'replay_completed_with_conflicts'
      else 'replay_completed_with_failures'
    end
  );
end;
$$;


create or replace function catchmenu_ledger.resolve_replay_conflict(
  p_tenant_id uuid,
  p_store_id uuid,
  p_entry_id uuid,
  p_resolution text,
  p_resolved_by_type text,
  p_resolved_by_id uuid,
  p_resolution_note text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_entry record;
  v_central_event_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_resolution not in (
    'ACCEPT_LOCAL', 'REJECT_LOCAL', 'MANUAL_MERGE'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_resolution'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select
    id, entry_type, entry_domain,
    entry_sequence, original_event_type,
    original_subject_type, original_subject_id,
    entry_payload, replay_status,
    locally_recorded_at, device_id
  into v_entry
  from catchmenu_ledger.local_temporary_ledger
  where id = p_entry_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
  for update;

  if v_entry.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'entry_not_found'
    );
  end if;

  if v_entry.replay_status <> 'CONFLICT_DETECTED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'entry_not_in_conflict',
      'current_status', v_entry.replay_status
    );
  end if;

  case p_resolution
    when 'ACCEPT_LOCAL' then
      -- force replay into central ledger despite conflict
      insert into catchmenu_ledger.events (
        tenant_id, store_id,
        event_domain, event_type, event_version,
        subject_type, subject_id,
        from_state, to_state,
        caused_by_type, caused_by_id,
        event_payload,
        is_replay, original_event_id,
        correlation_id,
        business_day, business_timezone,
        occurred_at, recorded_at
      ) values (
        p_tenant_id, p_store_id,
        v_entry.entry_domain,
        v_entry.original_event_type, 1,
        v_entry.original_subject_type,
        v_entry.original_subject_id,
        v_entry.entry_payload->>'from_state',
        v_entry.entry_payload->>'to_state',
        'REPLAY', p_resolved_by_id,
        v_entry.entry_payload || jsonb_build_object(
          'conflict_resolution', 'ACCEPT_LOCAL',
          'resolved_by', p_resolved_by_id,
          'resolution_note', p_resolution_note
        ),
        true, v_entry.id,
        p_correlation_id,
        v_business_day, v_timezone,
        v_entry.locally_recorded_at, now()
      )
      returning id into v_central_event_id;

      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'CONFLICT_RESOLVED',
        replay_conflict_detected = false,
        central_event_id = v_central_event_id,
        replay_approved_by = p_resolved_by_id,
        replay_approved_at = now(),
        replay_completed_at = now()
      where id = p_entry_id;

    when 'REJECT_LOCAL' then
      -- discard local entry — central state wins
      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'SKIPPED',
        replay_conflict_detected = false,
        replay_approved_by = p_resolved_by_id,
        replay_approved_at = now(),
        replay_conflict_detail = replay_conflict_detail || jsonb_build_object(
          'resolution', 'REJECTED',
          'resolution_note', p_resolution_note
        )
      where id = p_entry_id;

    when 'MANUAL_MERGE' then
      -- record merge decision in audit, mark for manual handling
      update catchmenu_ledger.local_temporary_ledger
      set
        replay_status = 'CONFLICT_RESOLVED',
        replay_approved_by = p_resolved_by_id,
        replay_approved_at = now(),
        replay_conflict_detail = replay_conflict_detail || jsonb_build_object(
          'resolution', 'MANUAL_MERGE',
          'resolution_note', p_resolution_note
        )
      where id = p_entry_id;
  end case;

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'recovery',
    p_audit_type := 'replay_conflict_resolved',
    p_audit_category := 'RECOVERY',
    p_actor_type := p_resolved_by_type,
    p_actor_id := p_resolved_by_id,
    p_subject_type := 'local_ledger_entry',
    p_subject_id := p_entry_id,
    p_decision := case p_resolution
      when 'ACCEPT_LOCAL' then 'APPROVED'
      when 'REJECT_LOCAL' then 'REJECTED'
      when 'MANUAL_MERGE' then 'OVERRIDDEN'
    end,
    p_decision_reason := p_resolution_note,
    p_decision_payload := jsonb_build_object(
      'resolution', p_resolution,
      'entry_sequence', v_entry.entry_sequence,
      'device_id', v_entry.device_id,
      'original_event_type', v_entry.original_event_type
    ),
    p_before_state := jsonb_build_object(
      'replay_status', 'CONFLICT_DETECTED'
    ),
    p_after_state := jsonb_build_object(
      'replay_status', case p_resolution
        when 'REJECT_LOCAL' then 'SKIPPED'
        else 'CONFLICT_RESOLVED'
      end,
      'resolution', p_resolution
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'entry_id', p_entry_id,
    'resolution', p_resolution,
    'replay_status', case p_resolution
      when 'REJECT_LOCAL' then 'SKIPPED'
      else 'CONFLICT_RESOLVED'
    end,
    'central_event_id', v_central_event_id,
    'audit_id', v_audit_id,
    'message_code', 'replay_conflict_resolved'
  );
end;
$$;


create or replace function catchmenu_ledger.get_replay_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_ledger, catchmenu_store,
                  catchmenu_common
as $$
declare
  v_device record;
  v_summary record;
  v_oldest_pending timestamptz;
  v_newest_pending timestamptz;
begin
  -- device validation
  select id, device_code, device_name,
         device_type, device_status
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'device_not_found'
    );
  end if;

  -- aggregate replay status
  select
    count(*) filter (
      where replay_status = 'PENDING'
    ) as pending_count,
    count(*) filter (
      where replay_status = 'IN_PROGRESS'
    ) as in_progress_count,
    count(*) filter (
      where replay_status = 'REPLAYED'
    ) as replayed_count,
    count(*) filter (
      where replay_status = 'CONFLICT_DETECTED'
    ) as conflict_count,
    count(*) filter (
      where replay_status = 'CONFLICT_RESOLVED'
    ) as conflict_resolved_count,
    count(*) filter (
      where replay_status = 'SKIPPED'
    ) as skipped_count,
    count(*) filter (
      where replay_status = 'FAILED'
    ) as failed_count,
    count(*) as total_count,
    min(entry_sequence) as min_sequence,
    max(entry_sequence) as max_sequence,
    bool_or(replay_conflict_detected) as has_conflicts
  into v_summary
  from catchmenu_ledger.local_temporary_ledger
  where device_id = p_device_id
    and tenant_id = p_tenant_id;

  -- timing of pending entries
  select
    min(locally_recorded_at),
    max(locally_recorded_at)
  into v_oldest_pending, v_newest_pending
  from catchmenu_ledger.local_temporary_ledger
  where device_id = p_device_id
    and tenant_id = p_tenant_id
    and replay_status = 'PENDING';

  return jsonb_build_object(
    'success', true,
    'device', jsonb_build_object(
      'id', v_device.id,
      'device_code', v_device.device_code,
      'device_name', v_device.device_name,
      'device_type', v_device.device_type,
      'device_status', v_device.device_status
    ),
    'replay_summary', jsonb_build_object(
      'total_entries', v_summary.total_count,
      'pending', v_summary.pending_count,
      'in_progress', v_summary.in_progress_count,
      'replayed', v_summary.replayed_count,
      'conflict_detected', v_summary.conflict_count,
      'conflict_resolved', v_summary.conflict_resolved_count,
      'skipped', v_summary.skipped_count,
      'failed', v_summary.failed_count,
      'sequence_range', jsonb_build_object(
        'min', v_summary.min_sequence,
        'max', v_summary.max_sequence
      )
    ),
    'status', jsonb_build_object(
      'is_complete', v_summary.pending_count = 0
        and v_summary.in_progress_count = 0,
      'has_conflicts', v_summary.has_conflicts,
      'has_failures', v_summary.failed_count > 0,
      'needs_attention', v_summary.conflict_count > 0
        or v_summary.failed_count > 0
    ),
    'timing', jsonb_build_object(
      'oldest_pending', v_oldest_pending,
      'newest_pending', v_newest_pending
    ),
    'message_code', case
      when v_summary.pending_count = 0
        and v_summary.conflict_count = 0
      then 'replay_complete'
      when v_summary.conflict_count > 0
      then 'replay_has_conflicts'
      when v_summary.pending_count > 0
      then 'replay_in_progress'
      else 'replay_status_ok'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_ledger.replay_local_ledger(
    uuid, uuid, uuid, int, text
  ) from public;
  grant execute on function catchmenu_ledger.replay_local_ledger(
    uuid, uuid, uuid, int, text
  ) to authenticated;

  revoke all on function catchmenu_ledger.resolve_replay_conflict(
    uuid, uuid, uuid, text, text, uuid, text, text
  ) from public;
  grant execute on function catchmenu_ledger.resolve_replay_conflict(
    uuid, uuid, uuid, text, text, uuid, text, text
  ) to authenticated;

  revoke all on function catchmenu_ledger.get_replay_status(
    uuid, uuid, uuid
  ) from public;
  grant execute on function catchmenu_ledger.get_replay_status(
    uuid, uuid, uuid
  ) to authenticated;
end;
$$;

comment on function catchmenu_ledger.replay_local_ledger(
  uuid, uuid, uuid, int, text
) is
  'Replays pending local temporary ledger entries to central ledger.
   Processes entries in sequence order per device.
   Detects sequence gaps and logs as exceptions.
   Conflict detection: checks if central ledger has newer events
   for same subject since local entry was recorded.
   Safe entries replayed automatically.
   Conflicting entries held for manual resolution.
   특허4: Local Temporary Ledger → Event Replay 기반 복구.
   안전한 Event만 중앙 원장에 Replay.';

comment on function catchmenu_ledger.resolve_replay_conflict(
  uuid, uuid, uuid, text, text, uuid, text, text
) is
  'Resolves a conflicting local ledger entry.
   ACCEPT_LOCAL: forces replay into central ledger.
   REJECT_LOCAL: discards local entry, central state wins.
   MANUAL_MERGE: records merge decision for manual handling.
   All resolutions require manager authorization.
   특허4: 충돌 또는 손상 의심 Event는 관리자 승인 대상으로 분리.
   복구 후 재동기화 + 감사 기록.';

comment on function catchmenu_ledger.get_replay_status(
  uuid, uuid, uuid
) is
  'Returns replay progress summary for a device.
   Shows counts by status: pending, replayed, conflict, failed.
   Used by staff app to monitor post-outage recovery progress.
   특허4: 복구 상태 실시간 모니터링.';