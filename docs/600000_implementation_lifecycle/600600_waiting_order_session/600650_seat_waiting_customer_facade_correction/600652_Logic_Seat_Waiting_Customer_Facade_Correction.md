# 600652_Logic_Seat_Waiting_Customer_Facade_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`seat_waiting_customer_facade_correction`

## §0 설계 원칙 요약 (승계)

`601121_Overview.md` §0.2(`table_id` 불변/`table_code` 표시용) 원칙을 대기열 파이프라인에 적용한다. `bind_table_to_session()`(`0025`)은 수정하지 않는다(`601121_Overview.md` §1.2/§1.3이 이미 필요한 불변조건을 전부 충족함을 확인). `seat_waiting_customer()`(`0115`)를 얇은 파사드로 재작성하고, 신규 리졸버 헬퍼를 하나 추가한다.

## §1 신규 헬퍼 — `catchmenu_pos._resolve_dining_table_by_number()`

```sql
create or replace function catchmenu_pos._resolve_dining_table_by_number(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_number text
)
returns table (
  v_table_id uuid,
  v_status text
)
language plpgsql
stable
security definer
set search_path = catchmenu_store
as $$
declare
  v_matches uuid[];
begin
  select array_agg(id) into v_matches
  from catchmenu_store.dining_tables
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and table_code = p_table_number;

  if v_matches is null or array_length(v_matches, 1) = 0 then
    return query select null::uuid, 'NOT_FOUND'::text;
    return;
  end if;

  if array_length(v_matches, 1) > 1 then
    return query select null::uuid, 'AMBIGUOUS'::text;
    return;
  end if;

  if exists (
    select 1 from catchmenu_store.dining_tables
    where id = v_matches[1] and is_active = true
  ) then
    return query select v_matches[1], 'FOUND'::text;
  else
    return query select v_matches[1], 'INACTIVE'::text;
  end if;
end;
$$;
```

**설계 근거**:

- `where table_code = p_table_number`만 두고 `is_active`를 필터에 넣지 않은 이유(`601121_Overview.md` §1.4): 비활성 테이블도 "찾았지만 비활성"임을 구분해 알려야 하기 때문이다 — `is_active`를 WHERE 절에 넣으면 비활성 테이블은 그냥 0건(= `NOT_FOUND`)이 되어 `waiting_table_inactive`라는 더 정확한 신호를 잃는다.
- `array_agg` + 배열 길이로 0/1/2+ 건을 구분한다 — `select ... into` 단일 스칼라로는 2건 이상을 감지할 수 없다(마지막 값만 남거나 에러가 나는 등 신뢰할 수 없는 동작).
- `store_id`를 반드시 WHERE 절에 포함한다 — `uq_dining_table_store_code`가 `(store_id, table_code)` 조합 유니크이므로, 이 조건이 정확한 한 `AMBIGUOUS` 분기는 도달 불가능하지만, 리졸버 자신의 정확성을 지키는 회귀 가드로 유지한다(`601121_Overview.md` §1.4).
- `returns table(...)`(레코드 집합)을 택한 이유: 예외(`raise`)를 던지지 않고 호출자가 `select * into v_resolved from ...`로 받아 `v_status`에 따라 분기하게 한다 — 오늘 이 세션이 반복 확립한 "예상 가능한 조건은 예외가 아니라 값으로 반환" 원칙(`601122_Logic.md` §1.5의 `raise;`→반환 정정과 같은 방향)과 일치한다.

### §1.1 GRANT/REVOKE — 내부 전용, `authenticated`에도 부여하지 않음

```sql
revoke all on function catchmenu_pos._resolve_dining_table_by_number(
  uuid, uuid, text
) from public;
```

**(중요, 이번 턴 발견)** `authenticated`에도 GRANT하지 않는다 — 이 함수는 순수 내부 헬퍼(`_` 접두어 관례, `catchmenu_pos._record_waiting_call()`과 동일한 명명 패턴)로, `seat_waiting_customer()`(SECURITY DEFINER)의 실행 컨텍스트 안에서만 호출되면 충분하다. 라이브 확인 결과 `catchmenu_pos._record_waiting_call()`의 `proacl`이 **비어 있다**(`REVOKE`조차 없음) — `601142_Logic.md` §1.2/§3(a)가 `upsert_menu_core()`에서 지적한 것과 동일한 패턴(내부 헬퍼가 의도치 않게 PUBLIC 기본 실행 권한에 열려 있는 상태)이 이미 이 코드베이스에 살아있다. 이 워크패킷은 `_record_waiting_call()`을 고치지 않지만(범위 밖, §8 Open Item (d)), 신규로 만드는 헬퍼에서는 이 패턴을 원천적으로 피한다 — `REVOKE ALL FROM PUBLIC`만으로 충분하다(`authenticated`에도 열 필요가 없으므로 `GRANT`문 자체가 없다).

## §2 `catchmenu_pos.seat_waiting_customer()` — 파사드 전체 재작성

시그니처는 기존과 동일하게 유지한다(하위 호환, 실호출자 0건이지만 문서상 계약 유지):

```sql
create or replace function
  catchmenu_pos.seat_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_resolved record;
  v_bind_result jsonb;
  v_remaining_queue int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  -- 1. 세션 조회 (사전주문 정보는 0160의 orders LEFT JOIN 패턴 재사용,
  --    §2.1 Overview 항목 5 — pre_order_amount phantom 컬럼 제거)
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.session_started_at,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 2. 이미 착석했는지 확인 (bind_table_to_session()이 더 엄격한
  --    사전조건을 다시 확인하지만, 여기서 먼저 확인하면 더 정확한
  --    에러 키(waiting_already_seated)를 유지할 수 있다 — 원본 동작 보존.
  if v_session.session_status = 'SEATED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_already_seated',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 3. p_table_number 필수 확인 (Overview §6 (f)) — bind_table_to_session()이
  --    p_table_id를 필수로 요구하고, order_sessions.table_id는 착석 이전엔
  --    항상 NULL이라 "생략 시 기존 값 유지"가 성립하지 않는다.
  if p_table_number is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 4. table_number -> table_id 리졸버 (§1)
  select * into v_resolved
  from catchmenu_pos._resolve_dining_table_by_number(
    p_tenant_id, p_store_id, p_table_number
  );

  if v_resolved.v_status = 'NOT_FOUND' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'AMBIGUOUS' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_ambiguous',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'INACTIVE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_inactive',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'table_number', p_table_number,
        'table_id', v_resolved.v_table_id
      )
    );
  end if;
  -- v_resolved.v_status = 'FOUND' 부터는 v_resolved.v_table_id가 유효하다.

  -- 5. canonical core에 위임 (Overview §1.2/§1.3 — 수정하지 않음)
  v_bind_result := catchmenu_pos.bind_table_to_session(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_table_id := v_resolved.v_table_id,
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_bind_result->>'success')::boolean, false) then
    -- (2026-07-18 정정, Stage 4 검증 — 아래 §2.1 참고) bind_table_to_session()의
    -- 원본 응답을 build_error_response()로 다시 감싸지 않고 그대로 반환한다.
    return v_bind_result;
  end if;

  -- 6. 대기열 도메인 고유 부수효과 (원본 0115 로직 보존, 0160 패턴으로 갱신)
  if v_session.pre_order_created_at is not null then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'KDS',
      p_log_event := 'pre_order_seated_waiting_payment',
      p_message :=
        '사전 주문 착석 완료 - 결제 대기 중. KDS HOLD 유지',
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'session_id', p_session_id,
        'wait_number', v_session.wait_number,
        'pre_order_amount', v_session.pre_order_amount
      )
    );
  end if;

  select count(*) into v_remaining_queue
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING');

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_seated',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null
    )
  );

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number
    )
  );

  -- 7. 'waiting' 도메인 렛저 이벤트 — bind_table_to_session()의 'session'/
  --    'table_bound' 이벤트와 의도적으로 별도로 기록한다(§3 설계 근거).
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
    'waiting', 'customer_seated', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'wait_duration_seconds', extract(
        epoch from (now() - v_session.session_started_at)
      )::int,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'kds_note', case
        when v_session.pre_order_created_at is not null
          then 'KDS HOLD - 결제 후 COMMITTED'
        else 'No pre-order - normal flow'
      end
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_seated',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'guest_count', v_session.guest_count,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'late_binding_completed', true,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then jsonb_build_object(
            'action', 'PROCEED_TO_PAYMENT',
            'note', '결제 완료 후 KDS 자동 COMMITTED',
            'kds_status_now', 'HOLD',
            'kds_status_after_payment', 'COMMITTED'
          )
        else jsonb_build_object(
          'action', 'TAKE_ORDER',
          'note', '일반 주문 접수'
        )
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'seat_waiting_customer_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'table_number', p_table_number
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_seat_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**(중요)** `EXCEPTION` 핸들러도 `raise;`가 아니라 `build_error_response()` 반환으로 설계했다 — `601122_Logic.md` §1.5/§8 (h)가 라이브 실증한 "감사 기록 후 `raise;`하면 그 기록까지 롤백된다"는 원칙을 이 워크패킷의 신규 코드에도 처음부터 적용한다(재발견이 아니라 이미 확립된 교훈의 재적용).

**(2026-07-18 정정, Codex+Cursor 검증 — 차단급 결함)** `p_audit_domain`을 최초 `'waiting'`으로 썼으나, 라이브 재확인 결과 `catchmenu_ledger.audit_records.chk_audit_domain`은 `'order'`/`'payment'`/`'kds'`/`'session'`/`'delivery'`/`'inventory'`/`'staff'`/`'device'`/`'agent'`/`'recovery'`/`'knowledge'`/`'gateway'`/`'security'`/`'system'`만 허용하고 **`'waiting'`은 포함하지 않는다**(참고: `catchmenu_ledger.events.chk_event_domain`은 `'waiting'`을 허용하지만, 이는 별개 테이블의 별개 제약이다 — §2 step 7의 렛저 이벤트와 여기 `audit_records`를 혼동해서는 안 된다). `'waiting'`으로 그대로 두면 이 `EXCEPTION` 핸들러 자신의 `append_audit_record()` 호출이 `chk_audit_domain` 위반으로 **다시 크래시**하고, 이 두 번째 예외는 잡아줄 상위 핸들러가 없어 그대로 클라이언트에 원본 Postgres 에러가 전파된다 — `raise;`→반환 정정(§1.5, `601122_Logic.md` §8 (h))이 지키려던 "친절한 에러 응답 + 영구 감사 기록"이 이 두 번째 크래시 때문에 둘 다 무효화되는 셈이었다. `'session'`으로 정정했다 — `0161_mark_no_show_overload_and_redesign.sql:209`가 `order_session` 대상 실패 감사에 동일하게 `p_audit_domain := 'session'`을 쓰는 기존 선례와 일치한다(이 함수의 `p_subject_type := 'order_session'`과도 일관).

### §2.1 `bind_table_to_session()` 실패 응답 — 정정: `build_error_response()`로 감싸지 않고 그대로 반환 (2026-07-18, Stage 4 검증에서 발견된 차단급 결함 정정)

**이전 버전의 결함(라이브 재현으로 확인)**: 이전 초안은 `bind_table_to_session()`이 반환한 `error_key`(`session_not_found`, `session_not_bindable`, `table_already_bound`, `table_not_found`, `table_not_available`)를 그대로 `catchmenu_common.build_error_response()`에 다시 넣어 감쌌다. 이번 턴 라이브로 직접 재현한 결과, `session_not_bindable`/`table_already_bound`는 `catchmenu_common.error_codes`에 **등록돼 있지 않고**, 등록되지 않은 `error_key`로 `build_error_response()`를 호출하면 그 함수가 내부적으로 호출하는 `catchmenu_common.log_diagnostic()`이 `diagnostic_logs.is_recoverable`(NOT NULL) 컬럼에 `NULL`을 넣으려다 제약 위반으로 **크래시한다**:

```
ERROR:  null value in column "is_recoverable" of relation "diagnostic_logs" violates not-null constraint
```

`table_not_found`는 등록은 돼 있지만 `error_domain='STORE'`, `code=7105`(`601122_Logic_Dining_Table_Crud_Creation.md`가 다이닝 테이블 CRUD 전용으로 등록한 것)로, 착석 파이프라인의 바인딩 실패에 이 도메인/코드를 그대로 노출하면 API 소비자 입장에서 오도된 `error.domain`을 받게 된다 — 사람이 읽는 메시지 텍스트 자체는 우연히 통하지만("테이블을 찾을 수 없습니다"), 구조화된 `error.domain`/`error.code` 필드는 실제 실패 맥락(대기열 바인딩)과 무관한 값이 된다.

**정정된 설계**: `bind_table_to_session()`의 실패 응답(`jsonb_build_object('success', false, 'error_key', ...)`)을 **그대로(`return v_bind_result;`) 반환한다** — `build_error_response()`를 다시 씌우지 않는다.

**근거**:

1. **차단급 결함을 원천 차단**: `build_error_response()`를 아예 호출하지 않으므로, 미등록 `error_key`로 인한 크래시(위)와 도메인 오매핑 둘 다 구조적으로 발생할 수 없다.
2. **`0025` 워크패킷 범위 침범 회피**: `session_not_bindable`/`table_already_bound`를 `error_codes`/`message_catalog`에 신규 등록하는 방안(대안)도 검토했으나, 이 두 키는 `bind_table_to_session()`(`0025`, 이 워크패킷이 수정하지 않기로 확정한 canonical core)이 정의한 에러 어휘다 — 그 함수의 에러 계약을 이 워크패킷이 대신 등록하는 것은 `0025`의 소유 경계를 침범하는 일이고, 등록하더라도 근본 해결이 아니라 이 워크패킷의 증상만 가리는 것이다: `bind_table_to_session()`을 직접 호출하는 다른 호출자의 상황은 라이브로 전수 확인한 결과 제각각이다 — `0051.confirm_pre_order_arrival()`은 반환값을 확인해 안전하게 전파하지만(§8 (h)), `0052`의 키오스크 `DINE_IN` 경로는 `perform`으로 반환값 자체를 검사하지 않는다(§8 (h)) — 이런 호출자들의 크래시/침묵 위험은 이 워크패킷이 `error_codes`를 대신 등록해도 전혀 해소되지 않는다.
3. **`bind_table_to_session()`은 이미 `build_error_response()`를 쓰지 않는다** — 원본 자체가 `jsonb_build_object()`로 직접 완결된 응답을 만드는 설계였다(`601121_Overview.md` §1.2). 파사드가 그 응답을 있는 그대로 통과시키는 것은 새로운 관례를 만드는 게 아니라 원본이 이미 쓰던 관례를 그대로 존중하는 것이다.
4. **트레이드오프(정직하게 기록)**: 이 경로의 실패 응답은 `{success:false, error_key:'...'}`(평평한 구조)이고, 이 파사드의 다른 실패 경로(§2 단계 1-4, `EXCEPTION` 핸들러)는 `build_error_response()`의 `{success:false, error:{key, message, domain, code, ...}}`(중첩 구조)를 쓴다 — 같은 함수의 응답 형태가 실패 원인에 따라 두 가지로 갈린다. 현재 실호출자가 0건이라(`601121_Overview.md` §1.6) 이 비일관성의 실질적 비용은 낮지만, Open Item으로 남긴다(§8 (g)).

이전에 계획했던 폴백 키 `waiting_table_bind_failed`(`v_bind_result->>'error_key'`가 `NULL`일 경우 대비)도 `§5`에 등록된 적이 없어 동일한 크래시 위험을 안고 있었다 — 이번 정정으로 `build_error_response()` 호출 자체가 사라지면서 이 잠재적 결함도 함께 해소됐다(부수적으로 발견, 별도 대응 불필요).

## §3 두 렛저 이벤트가 공존하는 이유 (설계 근거, Open Item 아님)

`bind_table_to_session()`은 `event_domain='session', event_type='table_bound'`를 기록하고, 이 파사드는 별도로 `event_domain='waiting', event_type='customer_seated'`를 기록한다 — **의도적 중복이 아니라 서로 다른 분석 축**이다. `session`/`table_bound`는 "테이블-세션 바인딩"이라는 좌석 배정 인프라 관점의 이벤트이고, `waiting`/`customer_seated`는 "대기 고객이 착석까지 도달했다"는 대기열 KPI 관점의 이벤트다(`wait_duration_seconds`는 후자에만 있다). `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md`가 복구한 `call_waiting_customer()`도 동일하게 `session`/`customer_called` 이벤트를 유지하는 관례를 따랐다 — 이 문서는 그 확립된 관례를 그대로 계승한다.

## §4 GRANT/REVOKE — `seat_waiting_customer()`

기존 GRANT(`0115:1756-1759`)를 그대로 유지한다 — 시그니처가 바뀌지 않았으므로 새로 등록할 필요가 없다. 라이브 확인 결과 `proacl`이 이미 `{=X/postgres,postgres=X/postgres,authenticated=X/postgres}`로 정상 설정돼 있다(`PUBLIC` 기본 권한 아님).

## §5 `message_catalog` / `error_codes` — 신규 5개 키

```sql
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('waiting_table_not_found', 'ko', '해당 테이블 번호를 찾을 수 없습니다'),
('waiting_table_not_found', 'en', 'Table number not found'),
('waiting_table_number_ambiguous', 'ko', '테이블 번호가 중복되어 특정할 수 없습니다'),
('waiting_table_number_ambiguous', 'en', 'Table number matches more than one table'),
('waiting_table_inactive', 'ko', '비활성화된 테이블입니다'),
('waiting_table_inactive', 'en', 'This table is inactive'),
('waiting_table_number_required', 'ko', '테이블 번호는 필수입니다'),
('waiting_table_number_required', 'en', 'Table number is required'),
('waiting_seat_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
('waiting_seat_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7073, 'waiting_table_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING'),
(7074, 'waiting_table_number_ambiguous',
  'ORDER', 'CONFLICT', 409, 'WARNING'),
(7075, 'waiting_table_inactive',
  'ORDER', 'CONFLICT', 409, 'WARNING'),
(7076, 'waiting_table_number_required',
  'ORDER', 'INVALID_INPUT', 400, 'WARNING'),
(7077, 'waiting_seat_operation_failed',
  'ORDER', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;
```

**(중요, Stage 5/8 재확인 필요)** `code` 7073-7077은 이번 턴 라이브 확인한 `select max(code) from catchmenu_common.error_codes where error_domain='ORDER'` = `7072`를 기준으로 다음 번호를 잠정 배정했다 — Stage 8 구현 직전 재조회해 확정한다(`601122_Logic.md` §5와 동일한 절차). `error_category`는 `601122_Logic.md`가 정정한 라이브 `chk_error_category` 허용값(`NOT_FOUND`/`CONFLICT`/`INVALID_INPUT`/`PERMISSION`/`BUSINESS_RULE`/`TECHNICAL`/`TIMEOUT`/`CAPACITY`/`FINANCIAL`/`SECURITY`/`INTEGRATION`/`RECOVERABLE`)를 그대로 재사용해 검증했다 — `'TECHNICAL'`(내부 오류)/`'NOT_FOUND'`/`'CONFLICT'`/`'INVALID_INPUT'` 전부 그 목록 안에 있다.

`error_key`에 `table_not_found`/`table_code_duplicate` 같은 기존 `STORE` 도메인 키를 재사용하지 않고 전부 `waiting_` 접두어를 새로 붙인 이유는 `601121_Overview.md` §6 (a) 참고 — `build_error_response()`의 `error_key` 조회가 `error_domain`을 필터링하지 않아 동일 키의 다른 도메인 등록과 충돌할 수 있다.

## §6 마이그레이션 파일 배치

파일: `sql/migrations/0163_seat_waiting_customer_facade_correction.sql`(잠정, Stage 5에서 번호 재확인 — `601121`/`601122`와 동일한 사유).

```sql
-- 0163_seat_waiting_customer_facade_correction.sql
-- Purpose: seat_waiting_customer()를 얇은 파사드로 재작성 —
--          phantom 컬럼(table_number/pre_order_amount) 크래시 제거.
--          bind_table_to_session()(0025)을 canonical core로 위임,
--          신규 리졸버(_resolve_dining_table_by_number)로
--          p_table_number -> table_id 변환.
-- Depends on: 0162_create_dining_table_admin_rpc.sql
-- Creates:
--   function catchmenu_pos._resolve_dining_table_by_number(...)
-- Replaces (create or replace, no signature change):
--   function catchmenu_pos.seat_waiting_customer(...) (원본 0115:988-1204)
```

`Depends on`을 `0162`로 잡은 이유: 리졸버가 `catchmenu_store.dining_tables`를 참조하며, `0162`가 그 테이블의 최신 CRUD 계약(`kds_device_id`/`did_device_id` 포함)을 확정한 가장 최근 워크패킷이기 때문이다 — 실제 스키마 의존은 훨씬 이전 마이그레이션(`0010`)부터지만, 순서상 최신 관련 작업을 명시한다.

### §6.1 파일 내부 문장 순서 (2026-07-18 명시, Codex+Cursor 검증)

파일 내부는 다음 순서로 구성한다 — `0110`/`0115`가 이미 쓰는 관례(i18n 블록 → 함수 정의 → GRANT 블록)를 그대로 따른다:

1. `message_catalog`/`error_codes` INSERT 블록(§5) — **함수 정의보다 먼저.**
2. `catchmenu_pos._resolve_dining_table_by_number(...)` 생성(§1).
3. `catchmenu_pos.seat_waiting_customer(...)` `create or replace`(§2).
4. `_resolve_dining_table_by_number(...)`의 `revoke`(§1.1).

**순서가 중요한 이유**: 이 마이그레이션 파일이 하나의 트랜잭션으로 통째로 적용되는 한(이 프로젝트의 `tools/apply_migrations.py` 관례) 파일 내부 문장 순서 자체는 최종 커밋 결과에 영향을 주지 않는다 — 함수 본문은 `error_codes` 행을 생성 시점이 아니라 **호출 시점**에 조회하기 때문이다. 하지만 이 프로젝트가 반복 확립해 온 "라이브 함수 직접 재실행" 절차(`601114_ChangeContract.md` §1.1/§5 등에 명시된 "source file update → ... → 직접 라이브 재실행 → `pg_get_functiondef()` 검증")에서, 구현자가 파일 전체가 아니라 **함수 정의 부분만** 골라 라이브에 재실행하는 실수를 하면 — INSERT 블록이 아직 라이브에 반영되지 않은 상태로 함수만 살아있는 순간이 생길 수 있다. `error_codes`/`message_catalog` INSERT를 파일 맨 앞에 두는 것은 이 실수를 하더라도 "함수보다 먼저 눈에 띄어 함께 실행될 가능성"을 높이는 방어적 배치다 — 완전한 보장은 아니므로, `600653_TestPlan.md`가 §9.3의 실제 실행 전제로 이를 명시적으로 요구한다.

## §7 TestPlan 영향 확인

- `bind_table_to_session()`/`orders`/`dining_tables` 어디도 본문을 수정하지 않는다 — `0 diff` 경계 대상.
- 최소 커버리지 후보(TestPlan 단계에서 확정): 정상 착석(리졸버 FOUND → bind 성공 → 부수효과 전부 확인), `waiting_table_number_required`(생략), `waiting_table_not_found`(존재하지 않는 코드), `waiting_table_inactive`(비활성 테이블), `waiting_table_number_ambiguous`(방어적 코드라 현재 스키마로는 직접 재현 불가 — 유니크 제약을 우회하는 테스트 방법이 필요, TestPlan 단계에서 설계), `bind_table_to_session()`의 각 실패 케이스(이미 바인딩됨/세션 바인딩 불가 상태/테이블 미가용)가 파사드를 통해 **`bind_table_to_session()`의 원본 평평한 응답 형태(`{success:false, error_key:...}`) 그대로** 노출되는지(§2.1, `build_error_response()`로 감싸지 않음을 확인 — 크래시하지 않는지가 핵심 회귀 테스트), 사전주문 있는 세션의 착석 시 `orders.final_amount` LEFT JOIN이 정확한 금액을 반환하는지, `EXCEPTION` 핸들러의 `waiting_seat_operation_failed` 반환 + 감사 기록 실제 영구 보존 확인(`601122_Logic.md` §5.4와 동일 패턴 재현).

## §8 Open Items

(a) `601121_Overview.md` §6 (f) / `600651_Overview.md` §6 (b) — 형제 함수 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`), 이 워크패킷에서 이어받아 그대로 유효, 후속 워크패킷 필요.
(b) `600651_Overview.md` §6 (c) — `pre_order_while_waiting()`도 동일 클래스 phantom을 갖고 있으나 죽은 코드일 가능성(§4.2), 확인 필요.
(c) `600651_Overview.md` §6 (d) — `did_display_queue` 테이블 자체가 구현된 적 없음, 이 워크패킷이 새로 만들지 않음.
(d) **[신규]** `catchmenu_pos._record_waiting_call()`의 `proacl`이 비어 있다(§1.1 발견) — `601142_Logic.md` §1.2/§3(a)와 동일한 클래스의 PUBLIC 기본 실행 권한 노출 위험이나, 이 워크패킷은 그 함수를 건드리지 않는다. `0160` 계열 후속 정리 워크패킷의 후보로 남긴다.
(e) `600651_Overview.md` §6 (a)/(e) — `waiting_` 접두어 명명 판단, `p_table_number` 정규화(trim/대소문자) 여부 — 이 문서에서 이어받아 그대로 유효.
(f) **[해소, 2026-07-18, Stage 4 검증 — §2.1 정정으로 자동 해결]** `bind_table_to_session()`의 5가지 실패 케이스에 대응하는 `error_key`가 `catchmenu_common.error_codes`에 등록돼 있는지 확인이 필요하다고 남겼던 항목 — 이번 정정으로 파사드가 그 키들을 `build_error_response()`에 넣지 않고 그대로 통과시키게 되면서(§2.1), 등록 여부 자체가 더 이상 이 워크패킷의 관심사가 아니게 됐다. 실제로 `session_not_bindable`/`table_already_bound`는 라이브 확인 결과 **등록돼 있지 않았고**(§2.1), 이것이 바로 이전 설계의 크래시 원인이었다.
(g) **[신규, 2026-07-18, §2.1 정정에서 발견]** 이 파사드의 응답 형태가 실패 원인에 따라 두 가지로 갈린다 — 리졸버/필수값 검증/`EXCEPTION` 핸들러 실패는 `build_error_response()`의 중첩 구조(`error.key`/`error.message`/`error.domain` 등)를, `bind_table_to_session()` 위임 실패는 평평한 구조(`error_key`만)를 반환한다(§2.1). 실호출자 0건이라 현재 비용은 낮지만, 향후 실제 클라이언트가 붙을 때 두 형태를 모두 처리해야 한다는 점을 인지해야 한다 — 통일하려면 `bind_table_to_session()` 자체를 `build_error_response()` 관례로 재설계해야 하는데, 그건 이 워크패킷이 명시적으로 범위 밖으로 둔 `0025`의 영역이다(§2.1 근거 2).

(h) **[신규, 2026-07-18, §9.2(TestPlan) 발견 → Codex+Cursor 검증으로 구체화 — canonical 위치는 `600654_ChangeContract.md` §8 (h), 이 항목은 교차참조용 사본]** `bind_table_to_session()`이 자체 `EXCEPTION` 핸들러를 갖고 있지 않다는 사실(`600653_TestPlan.md` §9.2)은 이 워크패킷의 파사드에서는 "실패 시 전체 원자성"이라는 바람직한 결과를 낳지만, 다른 호출자에게는 그렇지 않을 수 있다 — 라이브로 전수 확인한 결과:

- `sql/migrations/0051_create_pre_order_rpc.sql:453-465`(`confirm_pre_order_arrival()`) — 반환값을 확인하고(`if not (v_bind_result->>'success')::boolean then return v_bind_result; end if;`) 안전하게 그대로 전파한다. **문제 없음** — 이 워크패킷의 §2.2 설계와 정확히 동일한 기존 패턴.
- `sql/migrations/0052_create_kiosk_session_rpc.sql:226-233`(키오스크 `DINE_IN` 주문 제출 경로) — `perform`으로 호출해 반환값 자체를 검사하지 않는다. `bind_table_to_session()`이 실패해도 호출자가 알아챌 방법이 없다 — "조용히 사라지는" 위험 패턴의 실제 사례.

이 워크패킷은 `bind_table_to_session()`도 `0052`도 수정하지 않으므로(`600654_ChangeContract.md` §8 (h)와 동일한 범위 밖 원칙) 손대지 않지만, `0052` 사례는 향후 `0025` 계열 검토 워크패킷의 최우선 확인 대상으로 격상해 기록한다. 최신·상세 버전은 `600654_ChangeContract.md` §8 (h)를 참조 — 두 문서가 서로 어긋나면 `600654`가 우선한다(ChangeContract가 Human Approval의 근거 문서이므로).

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, TestPlan/ChangeContract 단계로 진행 가능.** §1에서 리졸버(`_resolve_dining_table_by_number()`)를 실제 SQL 수준으로 설계했다 — 0/1/2+ 건 판정, `is_active` 별도 확인, 방어적 `AMBIGUOUS` 분기의 근거, 내부 전용 GRANT(`authenticated`에도 열지 않음, `_record_waiting_call()`의 기존 `proacl` 공백을 발견하고 이 신규 헬퍼에서는 반복하지 않도록 설계). §2에서 `seat_waiting_customer()` 파사드 전체를 재작성했다 — `bind_table_to_session()` 위임, `0160`의 `orders` LEFT JOIN 패턴 재사용, 대기열 도메인 고유 부수효과 보존, `EXCEPTION` 핸들러의 `raise;`→반환 원칙 선제 적용. 두 렛저 이벤트(`table_bound`/`customer_seated`)가 공존하는 이유를 설계 근거로 명시했다(§3, Open Item 아님). GRANT/REVOKE(§4), i18n 등록(§5, 5개 키, 코드 7073-7077 잠정), 마이그레이션 파일 배치(§6)까지 포함한다.

**(2026-07-18 정정, Stage 4 검증에서 발견된 차단급 결함 2건 해소)** `bind_table_to_session()`의 실패 응답을 `build_error_response()`로 다시 감싸던 이전 설계를 라이브로 재현한 결과, 미등록 `error_key`(`session_not_bindable`/`table_already_bound`) 사용 시 `diagnostic_logs.is_recoverable` NOT NULL 위반으로 크래시함을 확인했다 — `table_not_found` 재사용도 `STORE` 도메인(`601122_Logic.md`의 다이닝 테이블 CRUD 전용 코드 7105)과 오매핑되는 문제가 있었다. `bind_table_to_session()`의 원본 응답을 그대로 반환하는 방식(`return v_bind_result;`)으로 정정해 두 문제를 구조적으로 제거했다(§2.1) — `0025` 워크패킷의 에러 어휘를 대신 등록하지 않는 것이 그 함수의 소유 경계를 지키는 선택이라는 근거도 함께 기록했다. 이 정정으로 응답 형태 비일관성(중첩 vs 평평)이라는 새로운 트레이드오프가 생겼음을 Open Item으로 정직하게 남겼다(§8 (g)).

**(2026-07-18 추가 정정, Codex+Cursor 검증 — 3건 해소)** (1) `EXCEPTION` 핸들러의 `p_audit_domain`을 `'waiting'`에서 `'session'`으로 정정했다 — 라이브 재확인 결과 `chk_audit_domain`이 `'waiting'`을 허용하지 않아, 방치했다면 이 핸들러 자신의 `append_audit_record()` 호출이 다시 크래시하며 상위 핸들러 없이 그대로 전파됐을 차단급 결함이었다(§1.5의 정정 주석). (2) 마이그레이션 파일 내부 문장 순서를 명시했다 — `error_codes`/`message_catalog` INSERT가 함수 정의보다 먼저 오도록(§6.1), 그리고 이 전제를 `600653_TestPlan.md` §9.3에도 명시적으로 추가했다. (3) Open Item (h)가 애초에 막연히 "다른 호출자가 있다면"으로 남겨뒀던 부분을 라이브 검증한 실제 두 사례로 구체화했다 — `0051.confirm_pre_order_arrival()`은 반환값을 확인하고 안전하게 전파함(문제 없음, 이 워크패킷의 설계와 동일 패턴), `0052`의 키오스크 DINE_IN 경로는 `perform`으로 반환값을 버려 바인딩 실패가 완전히 조용히 사라짐(실제 위험 사례, 후속 워크패킷 최우선 확인 대상으로 격상). `.sql` 파일은 생성·수정하지 않았다.
