# 600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`waiting_pipeline_sibling_functions_correction`

## §0 설계 원칙 요약

`600661_Overview.md` §1-§3의 재확인 결과를 그대로 적용한다. 4개 함수를 아래 4개 Slice로 나눠 설계한다(`601142_Logic.md`의 Slice 1/Slice 2 선례):

- **Slice A** — `confirm_arrival()`: 파사드화, `catchmenu_pos.mark_session_arrived()`(`0025`, 미변경)에 위임.
- **Slice B** — `get_waiting_status()`: 읽기 전용, LEFT JOIN 3종 + `session_events` 파생.
- **Slice C** — `get_waiting_admin_view()`: Slice B와 동일 패턴 + `memo` 필드 제거 결정.
- **Slice D** — `cancel_waiting()`: orders LEFT JOIN + phantom 쓰기(`cancel_reason`) 삭제, 렛저를 단일 진실 소스로 확정.

공통으로 적용하는 두 가지 교정:
1. **`has_pre_order` 판정 기준 통일**: 원본 4개 함수 모두 `pre_order_amount > 0`(phantom 컬럼 자체 값)로 판정했는데, `orders` LEFT JOIN 이후에는 사전주문이 없으면 `o.final_amount`가 `0`이 아니라 `NULL`이 된다 — `0`이 될 수도 있는 실제 케이스(무료 프로모션 등)와 구분되지 않는 문제도 있다. `0160`/`0163`이 이미 쓰는 `os.pre_order_created_at is not null` 기준으로 4개 함수 전부 통일한다.
2. **`EXCEPTION` 핸들러 추가 여부는 함수별로 결정**(§0.1) — 원본 4개는 전부 핸들러가 없었다.

### §0.1 `EXCEPTION` 핸들러 결정

| 함수 | 결정 | 근거 |
|---|---|---|
| Slice A `confirm_arrival()` | **추가** | `mark_session_arrived()`에 위임하는 새 파사드 — `seat_waiting_customer()`/`bind_table_to_session()`과 동일한 위험(위임 성공 후 파사드 자신의 코드에서 실패하면 원시 Postgres 에러가 클라이언트로 샐 수 있고, `600652_Logic.md` §9.2가 증명한 전체 원자성 때문에 위임된 core의 작업까지 조용히 롤백된다 — 최소한 실패 감사 기록은 남겨야 한다) |
| Slice B `get_waiting_status()` | **추가 안 함** | `STABLE`, 부수효과 없는 단순 조회 — 실패해도 롤백할 상태가 없고, 원본에도 없었다. 없어도 원시 에러가 새는 것 자체는 동일 리스크지만, 이 워크패킷의 핵심 목표(phantom 컬럼 교정)와 무관한 범위 확장으로 판단해 보류 |
| Slice C `get_waiting_admin_view()` | **추가 안 함** | Slice B와 동일 근거 |
| Slice D `cancel_waiting()` | **추가** | 상태 전이 + 조건부 KDS 티켓 UPDATE + 알림 + 렛저까지 여러 단계의 쓰기가 있는 함수 — `confirm_arrival()`과 동일한 근거 |

**결과: `error_codes`/`message_catalog`에 신규 키 2개가 필요하다** — `600661_Overview.md` §5의 "신규 키 0건 예상"은 이 Logic 설계 단계에서 §0.1 결정에 따라 2건으로 정정한다(§E).

## §A Slice A — `confirm_arrival()` 파사드 재작성

### §A.1 위임 대상 재확인 (인용, `600661_Overview.md` §1.5 근거)

`catchmenu_pos.mark_session_arrived(p_tenant_id, p_store_id, p_session_id, p_correlation_id)` — `0025:232-324`, 미변경. 반환 형태는 원시 flat JSON(`build_success_response`/`build_error_response` 아님): 성공 시 `{'success':true,'session_id':...,'session_status':'ARRIVAL_PENDING','arrived_at':...}`, 실패 시 `{'success':false,'error_key':'session_not_found'}` 또는 `{'success':false,'error_key':'invalid_session_status','current_status':...}`.

### §A.2 실패 키 도달 가능성 분석 (`0163` §7과 동일 형식)

| `error_key` | 이 파사드를 통해 도달 가능? | 근거 |
|---|---|---|
| `session_not_found` | **아니오** | 파사드 자신의 §A.3 1단계가 이미 같은 `p_session_id`/`p_store_id`/`p_tenant_id`로 조회하고 `for update of os`로 잠근 뒤에만 위임한다 — 위임 시점에 행이 사라질 수 없다 |
| `invalid_session_status` | **예** | 파사드가 자체적으로 `session_status`를 사전 검사하지 않고 그대로 위임하므로(§A.3 설계 결정), `WAITING`/`ARRIVAL_PENDING`이 아닌 모든 상태(`SEATED`/`CANCELLED`/`COMPLETED`/`NO_SHOW` 등)에서 이 키로 실패한다 |

`session_not_found`가 구조적으로 도달 불가능하다는 것이 이 표 자체가 근거다(`0163` §7과 동일하게, 라이브 재현이 아니라 도달가능성 증명으로 TestPlan 커버리지를 대신한다 — 다음 Stage의 TestPlan에서 재확인).

**설계 결정**: 파사드는 `waiting_already_seated`처럼 더 친절한 별도 에러로 특정 상태를 가로채지 않는다. 원본 `confirm_arrival()`에는애초에 그런 세분화된 에러가 없었고(`600661_Overview.md` §1.1 — 상태 가드 자체가 없었다), 현재 호출자가 0건이므로 과설계할 이유가 없다. `invalid_session_status`를 `0163` §2.1과 동일하게 **재래핑 없이 그대로 반환**한다 — `mark_session_arrived()`의 `error_key`가 `error_codes`에 등록되어 있지 않으므로 `build_error_response()`로 감쌌다면 `600652_Logic.md` §2.1이 실증한 것과 같은 `log_diagnostic()` 크래시가 재발했을 것이다.

### §A.3 전체 함수

**(Stage 4 검증에서 명시 요구)** 이 파사드 호출 1회의 총 이벤트 발자국(event footprint): 위임이 성공하면 `mark_session_arrived()`(`0025:281-295`, `297-315`, 미변경)가 자신의 내부에서 **`session_events` 1건**(`event_type='customer_arrived'`)과 **`catchmenu_ledger.events` 1건**(`event_domain='session'`, `event_type='customer_arrived'`)을 이미 생성한다. 그 위에 파사드 자신이 아래 4단계에서 **`catchmenu_ledger.events` 1건을 추가로**(`event_domain='waiting'`, `event_type='arrival_confirmed'`) 생성한다. 즉 **`confirm_arrival()` 호출 1회 = `session_events` 1건 + `catchmenu_ledger.events` 2건**(`session`/`customer_arrived` + `waiting`/`arrival_confirmed`) — `0163`의 `seat_waiting_customer()`가 `bind_table_to_session()` 위임으로 만드는 "렛저 이벤트 2건, 의도적" 패턴(§A.3 4단계 주석, `0163 §3`)과 정확히 동형이며, 이 문서 §G에 다음 TestPlan의 acceptance criterion으로 포함하도록 명시해 둔다.

```sql
create or replace function catchmenu_pos.confirm_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_arrival_result jsonb;
begin
  -- 1. 세션 조회 (사전주문 금액은 0160/0163과 동일한 orders LEFT JOIN 패턴)
  select os.id, os.wait_number, os.session_status,
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
      p_rpc_name := 'confirm_arrival'
    );
  end if;

  -- 2. 상태 전이 + arrived_at 기록을 canonical core에 위임 (§A.1/§A.2)
  v_arrival_result := catchmenu_pos.mark_session_arrived(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_arrival_result->>'success')::boolean, false) then
    -- mark_session_arrived()의 원시 flat JSON을 그대로 반환 (§A.2 설계 결정,
    -- 0163 §2.1과 동일 이유 — 미등록 error_key 재래핑 크래시 회피)
    return v_arrival_result;
  end if;

  -- 3. 대기열 도메인 고유 부수효과 (원본 로직 보존)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_arrival_confirmed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount
    )
  );

  -- 4. 파사드 자신의 렛저 이벤트 — mark_session_arrived()의 'session'/'customer_arrived'와
  --    별개로 유지 (0163 §3과 동일한 "두 렛저 이벤트, 의도적" 설계 — event_domain='waiting'은
  --    register_waiting/waiting_cancelled/customer_seated와 같은 버킷에 속해야 조회 일관성이 있다).
  --    from_state는 원본의 하드코딩된 'WAITING' 대신 v_session.session_status를 동적으로 사용한다
  --    (원본 결함 수정 — ARRIVAL_PENDING 세션의 재확인 호출에서도 정확한 from_state가 남는다).
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
    'waiting', 'arrival_confirmed', 1,
    'order_session', p_session_id,
    v_session.session_status, 'ARRIVAL_PENDING',
    'CUSTOMER', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  -- 5. 응답 — table_number 필드는 삭제 (ARRIVAL_PENDING 단계에서는 아직 테이블이
  --    배정되지 않아 원본에서도 항상 null이었던 무의미한 필드, 호출자 0건이므로
  --    호환성 부담 없이 정리)
  return catchmenu_common.build_success_response(
    p_message_key := 'arrival_confirmed',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then 'PROCEED_TO_PAYMENT'
        else 'WAIT_FOR_SEATING'
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
      p_audit_domain := 'session', -- 'waiting'은 chk_audit_domain에 없음 (600652_Logic.md §1.5 근거 재적용)
      p_audit_type := 'confirm_arrival_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'CUSTOMER',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_confirm_arrival_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

GRANT/REVOKE: 시그니처 불변(`0115`와 동일 파라미터 목록) — 기존 GRANT(`0115:1751-1754`, `authenticated`) 그대로 유지, 신규 GRANT 문 불필요.

## §B Slice B — `get_waiting_status()` 읽기 교정

### §B.1 설계

- `pre_order_amount` → `orders.final_amount` LEFT JOIN.
- `table_number` → `dining_tables.table_code` LEFT JOIN (`os.table_id`가 `null`이면 자연히 `null` — 착석 전에는 원본도 항상 `null`이었으므로 동작 동일).
- `called_at` → `session_events`에서 `event_type='customer_called'`의 최신 `occurred_at`(`600661_Overview.md` §1.6, `_record_waiting_call()`의 기존 파생 로직 재사용).
- `arrival_confirmed_at` → 실컬럼 `os.arrived_at`으로 직접 대체(파생 불필요).
- 죽은 `queue_position` SELECT 항목 삭제(`600661_Overview.md` §6 Open Item (e) 해소 — 실제로 쓰이는 것은 별도 카운트 쿼리로 계산되는 지역변수뿐이었다).

### §B.2 전체 함수

```sql
create or replace function catchmenu_pos.get_waiting_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_session record;
  v_queue_position int;
  v_est_wait_minutes int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.session_type, os.guest_count, os.guest_locale,
         os.pre_order_created_at,
         o.final_amount as pre_order_amount,
         dt.table_code as table_number,
         os.session_started_at,
         call_info.called_at,
         os.arrived_at,
         os.seated_at
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_waiting_status'
    );
  end if;

  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING')
    and wait_number < v_session.wait_number;

  v_est_wait_minutes := v_queue_position * 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'session_status', v_session.session_status,
      'session_type', v_session.session_type,
      'guest_count', v_session.guest_count,
      'table_number', v_session.table_number,
      'queue_position', v_queue_position,
      'est_wait_minutes', v_est_wait_minutes,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'timestamps', jsonb_build_object(
        'registered_at', v_session.session_started_at,
        'called_at', v_session.called_at,
        'arrival_at', v_session.arrived_at,
        'seated_at', v_session.seated_at
      ),
      'status_messages', jsonb_build_object(
        'position', catchmenu_common.get_message(
          'waiting_current_position',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('position', v_queue_position)
        ),
        'est_time', catchmenu_common.get_message(
          'waiting_est_time',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('minutes', v_est_wait_minutes)
        )
      )
    ),
    p_locale := p_locale
  );
end;
$$;
```

GRANT/REVOKE: 시그니처 불변, 기존 GRANT(`authenticated`) 유지.

## §C Slice C — `get_waiting_admin_view()` 읽기 교정 + `memo` 결정

### §C.1 `memo` 결정 (`600661_Overview.md` §4-4/§6 Open Item (d) 확정)

`memo`는 `order_sessions`에도 다른 어떤 테이블에도 대응하는 실컬럼이나 파생 가능한 소스가 없다. 두 옵션:

- **(옵션 1) 필드를 응답에서 제거** — 이 워크패킷의 범위("기존 실컬럼/파생 소스로 phantom을 치환")를 지키고, 스키마 변경 없이 크래시만 없앤다.
- **(옵션 2) `order_sessions.memo text` 컬럼 신설** — 직원이 대기 손님에 대해 메모(알레르기, VIP 등)를 남기는 기능이 실제로 필요하다면 정당한 요구지만, 새 컬럼 추가는 `.sql` 작성이 필요한 별도 스키마 변경 워크패킷이다(이번 턴은 `.sql` 생성/수정 금지).

**결정: 옵션 1(제거)을 채택한다.** 이 워크패킷은 "phantom 컬럼을 이미 존재하는 것으로 치환"하는 것이 목적이며, 새 기능(직원 메모)을 설계하는 것은 다른 종류의 작업이다(`600661_Overview.md` §3의 "다른 개념이 섞이면 쪼갠다" 원칙과 동일 논리로, 이 필드 하나만 별도 워크패킷 후보로 이관한다 — 가칭 `waiting_session_staff_memo_feature`). 메모 기능이 실제로 필요하다고 확인되면 그때 별도 Overview에서 컬럼 신설부터 다시 설계한다.

### §C.2 전체 함수

```sql
create or replace function catchmenu_pos.get_waiting_admin_view(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_business_day date;
  v_waiting_list jsonb;
  v_today_stats jsonb;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'queue_position', os.queue_position,
        'session_status', os.session_status,
        'session_type', os.session_type,
        'guest_count', os.guest_count,
        'guest_locale', os.guest_locale,
        'table_number', dt.table_code,
        'has_pre_order', os.pre_order_created_at is not null,
        'pre_order_amount', o.final_amount,
        'waited_minutes', extract(epoch from (now() - os.session_started_at))::int / 60,
        'called_at', call_info.called_at,
        'call_count', coalesce(call_info.call_count, 0),
        'is_foreign', os.guest_locale <> 'ko',
        'actions', jsonb_build_array(
          case when os.session_status = 'WAITING' then 'CALL' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'SEAT' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'NO_SHOW' else null end,
          'CANCEL'
        )
      )
      order by os.queue_position asc nulls last, os.wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select count(*) as call_count, max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day
    and os.session_status in ('WAITING', 'ARRIVAL_PENDING');

  select jsonb_build_object(
    'total_registered', count(*),
    'completed', count(*) filter (where os.session_status = 'COMPLETED'),
    'cancelled', count(*) filter (where os.session_status = 'CANCELLED'),
    'no_show', count(*) filter (where os.session_status = 'NO_SHOW'),
    'current_waiting', jsonb_array_length(v_waiting_list),
    'pre_order_count', count(*) filter (where os.pre_order_created_at is not null),
    'total_pre_order_amount', coalesce(
      sum(o.final_amount) filter (where os.pre_order_created_at is not null), 0
    ),
    'foreign_count', count(*) filter (where os.guest_locale <> 'ko'),
    'avg_wait_minutes', coalesce(
      avg(
        extract(epoch from (coalesce(os.seated_at, now()) - os.session_started_at)) / 60
      )::int, 0
    )
  )
  into v_today_stats
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'current_waiting', jsonb_array_length(v_waiting_list),
      'waiting_list', v_waiting_list,
      'today_stats', v_today_stats,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;
```

**(Stage 4 검증에서 재분류)** `patent_note`(`600661_Overview.md` §1.3/§6 Open Item (b)) 제거는 이 Slice의 다른 모든 변경(phantom 컬럼 → 실컬럼/파생 치환)과 **같은 종류의 작업이 아니다** — phantom 컬럼 치환은 "크래시하던 것을 크래시하지 않게 만드는" 무결점 교정인 반면, `patent_note` 제거는 이미 정상 동작하던(크래시와 무관한) 응답 필드를 삭제하는 **응답 계약(response contract) 변경**이다. 이 워크패킷 위에서 설계 편의상 함께 처리하지만, 승인 근거는 서로 다르다 — §H에 별도 Open Item으로 명시하고, `600663_ChangeContract.md`(다음 Stage)의 Allowed Operations에도 phantom 컬럼 치환 항목과 분리된 별도 항목으로 기재해 Human이 이 부분만 따로도 판단할 수 있게 한다. 유지할 근거(클라이언트가 실제로 소비)가 없고 호출자 0건이라는 점은 여전히 유효하지만, "무해한 정리"로 뭉뚱그리지 않는다.

GRANT/REVOKE: 시그니처 불변, 기존 GRANT(`authenticated`) 유지.

## §D Slice D — `cancel_waiting()` 쓰기 교정

### §D.1 `cancel_reason` 설계 (`600661_Overview.md` §1.7 확정)

`cancel_reason`은 대체 실컬럼이 없다. `p_cancel_reason`은 이미 렛저 이벤트(`event_payload.cancel_reason`)와 `notify_channel()` payload에 담겨 영구 보존되므로, `order_sessions.cancel_reason`에 대한 UPDATE SET 절 자체를 삭제한다 — 정보 손실이 아니라 중복 제거다.

**(Stage 4 검증에서 지적된 경계 케이스, §H (i)로도 기록)** §0의 `has_pre_order` 통일 기준(`os.pre_order_created_at is not null`)은 "사전주문이 있으면 `orders`/`kds_tickets` 행도 함께 존재한다"는 암묵적 가정에 기대고 있다. 그러나 `pre_order_created_at`을 세팅하는 쓰기 경로 중 하나인 `pre_order_while_waiting()`이 `600661_Overview.md`가 인용하는 `600651_Overview.md` §4.2에서 이미 "고장 상태이거나 죽은 코드일 가능성"으로 플래그된 바 있다 — 즉 `pre_order_created_at is not null`이지만 실제로는 대응하는 `orders`(또는 `orders`는 있지만 `kds_tickets`는 없는) 행이 없는 비정상 상태가 라이브 데이터에 이미 존재할 가능성을 배제할 수 없다. 이 경우 Slice D의 `update ... from catchmenu_pos.orders o where o.session_id = p_session_id ...`는 매칭되는 행이 없으면 단순히 0행 UPDATE로 끝나 크래시하지는 않을 것으로 판단되지만(`update ... from`은 매칭 실패 시 조용히 no-op), **이 판단 자체가 라이브 재현으로 검증된 적은 없다** — 다음 TestPlan에서 반드시 재현 테스트로 확인해야 한다(§G).

### §D.2 전체 함수

```sql
create or replace function catchmenu_pos.cancel_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text default null,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.guest_locale, os.pre_order_created_at,
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
      p_rpc_name := 'cancel_waiting'
    );
  end if;

  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  if v_session.pre_order_created_at is not null then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'cancelled_by', p_actor_type
    )
  );

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
    'waiting', 'waiting_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_cancelled',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
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
      p_audit_type := 'cancel_waiting_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'cancel_reason', p_cancel_reason
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_cancel_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**명시적으로 하지 않는 것** (`600661_Overview.md` §4-1, §1.4): `session_status`에 대한 사전 가드를 추가하지 않는다. 이미 `SEATED`인 세션도 여전히 `CANCELLED`로 전이될 수 있고, 테이블 반납 로직은 여전히 없다 — 이번 워크패킷은 phantom 컬럼만 교정하며, 이 갭은 별도 워크패킷(가칭 `cancel_waiting_state_guard_and_table_release`)으로 이관한다.

GRANT/REVOKE: 시그니처 불변, 기존 GRANT(`authenticated`) 유지.

## §E `message_catalog`/`error_codes` 신규 항목

`§0.1`의 결정에 따라 2개 신규 `error_key`가 필요하다. `error_domain := 'ORDER'`(`0163`과 동일 도메인 — 대기열/세션 관련 사용자 대면 에러가 이미 이 도메인에 모여 있다), 코드는 라이브 재확인 결과(`0163` 적용 이후 ORDER 도메인 상한 `7077`) 다음 값을 임시 배정한다 — **정확한 값은 `0163` §2.5/`600654_ChangeContract.md` §6 Stop Condition #2와 동일하게, Stage 8 직전 라이브 재확인 대상이며 이 문서가 고정하지 않는다.**

| 임시 code | error_key | error_category | http_status | 용도 |
|---|---|---|---|---|
| 7078 | `waiting_confirm_arrival_failed` | `TECHNICAL` | 500 | Slice A `EXCEPTION` 핸들러 |
| 7079 | `waiting_cancel_operation_failed` | `TECHNICAL` | 500 | Slice D `EXCEPTION` 핸들러 |

`message_catalog` (`ko`/`en` 각 1행, 총 4행):

```sql
insert into catchmenu_common.message_catalog (message_key, locale, message_text) values
  ('waiting_confirm_arrival_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_confirm_arrival_failed', 'en', 'A temporary error occurred. Please try again'),
  ('waiting_cancel_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_cancel_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;
```

## §F 마이그레이션 파일 배치 (Stage 8 대상, 이번 턴은 작성하지 않음)

파일명 잠정: `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql`(`600661_Overview.md` 시점 기준 다음 번호 — Stage 8은 `select max(...)` 재확인 후 실제 번호 확정, `0163` §1.1과 동일 절차). `0163` §6.1이 확립한 문 순서를 그대로 따른다:

1. `message_catalog`/`error_codes` INSERT 블록 (§E) — 함수 정의보다 먼저.
2. `catchmenu_pos.confirm_arrival()` `CREATE OR REPLACE` (Slice A).
3. `catchmenu_pos.get_waiting_status()` `CREATE OR REPLACE` (Slice B).
4. `catchmenu_pos.get_waiting_admin_view()` `CREATE OR REPLACE` (Slice C).
5. `catchmenu_pos.cancel_waiting()` `CREATE OR REPLACE` (Slice D).
6. `GRANT`/`REVOKE` — 4개 함수 모두 시그니처 불변이므로 신규 GRANT문 자체는 불필요하지만, 헤더 주석에 "기존 GRANT 유지, 신규 GRANT 없음"을 명시해 Stage 8이 실수로 중복 GRANT를 추가하지 않도록 한다.

`0115` 원본 소스 텍스트는 수정하지 않는다(`CREATE OR REPLACE`로만 라이브 정의를 덮어씀 — `0160`/`0163`과 동일 기법). `mark_session_arrived()`(`0025`)는 이 파일에서 전혀 건드리지 않는다(위임만 함).

## §G TestPlan 영향 (다음 Stage 예고, 이번 턴 범위 아님)

다음 Stage(TestPlan/ChangeContract 작성)에서 `600653_TestPlan.md`와 동형의 구조로 4개 Slice 각각에 대해: 정상 동작(Slice A는 `mark_session_arrived()` 위임 성공 경로, Slice D는 사전주문 있는/없는 취소 양쪽), phantom 컬럼이 실제로 사라졌는지(크래시 없이 완주하는지가 1차 회귀 증거), Slice A의 `invalid_session_status` 도달가능성 재현(§A.2 표), Slice A/D의 `EXCEPTION` 원자성(`600653_TestPlan.md` §9와 동일한 임시 CHECK 제약 기법 재사용 가능), `0025`/`0115`(원본 텍스트)/`0160`/`0163`에 대한 0 diff 경계 확인이 필요할 것으로 예상한다.

**Stage 4 검증에서 명시 요구된 추가 acceptance criteria 2건 (다음 TestPlan에 반드시 포함):**

1. **Slice A 이벤트 개수 검증** — `confirm_arrival()` 정상 호출 1회 후 `session_events`에서 해당 `session_id`/`event_type='customer_arrived'` 행이 정확히 1건, `catchmenu_ledger.events`에서 해당 `subject_id`의 `event_type in ('customer_arrived','arrival_confirmed')` 행이 정확히 2건(`event_domain='session'`인 것 1건 + `event_domain='waiting'`인 것 1건)임을 직접 카운트로 확인 — §A.3의 이벤트 발자국 명시 사항 재확인.
2. **Slice D `has_pre_order` 경계 케이스** — `os.pre_order_created_at is not null`이지만 대응하는 `orders`/`kds_tickets` 행이 실제로는 없는(또는 `orders`는 있지만 `kds_tickets`가 없는) 비정상 상태에서 `cancel_waiting()`을 호출했을 때 크래시 없이 정상 완주하는지 확인 — §0/§D.1 Open Item.

## §H Open Items

(a) `cancel_waiting()` 상태 가드 + 테이블 반납 로직 부재 — 별도 워크패킷 후보 `cancel_waiting_state_guard_and_table_release` (`600661_Overview.md` §4-1, §D.2).
(b) `get_waiting_admin_view()`의 `patent_note` — 이 워크패킷에서 제거하기로 확정(§C.2)했지만, **phantom 컬럼 교정과는 무관한 별개의 응답 계약(response contract) 변경이므로 Human이 이 항목만 따로 명시 승인해야 한다.** 다음 Stage(`600663_TestPlan.md`/`600664_ChangeContract.md`) 작성 시 `600654_ChangeContract.md` 형식의 Allowed Operations 목록에서 phantom 컬럼 치환 항목들과 분리된 별도 줄로 기재할 것 — "무해한 정리"로 다른 phantom 교정 항목들과 뭉뚱그려 일괄 승인받지 않는다. 반론 시 되돌림.
(c) `get_dining_table_admin_list()`(`601120`) 응답 형태 불일치 — 범위 밖, 별도 사안.
(d) `memo` — 옵션 1(제거)로 확정(§C.1), 별도 기능 워크패킷 후보 `waiting_session_staff_memo_feature`.
(e) `get_waiting_status()`의 죽은 `queue_position` SELECT — 이 워크패킷에서 제거하기로 확정(§B.1/§B.2).
(f) `_record_waiting_call()`의 `proacl` 공백 — `600652_Logic.md` §8 Open Item (d), 이 워크패킷도 범위 밖.
(g) `error_codes` code 7078/7079는 임시값 — Stage 8 직전 라이브 재확인 필수(§E).
(h) Slice B/C에 `EXCEPTION` 핸들러를 추가하지 않기로 한 결정(§0.1)은 최종 확정이 아니라 이 Logic 단계의 판단이다 — Stage 6 검증에서 이견이 나오면 재논의 대상.
(i) **(Stage 4 검증에서 신규 추가)** `has_pre_order`(`pre_order_created_at is not null`) 판정 기준이 "사전주문이 있으면 `orders`/`kds_tickets` 행도 함께 존재한다"고 암묵적으로 가정한다 — `pre_order_while_waiting()`이 고장/죽은 코드일 가능성(`600651_Overview.md` §4.2)과 맞물려, `pre_order_created_at`만 세팅되고 실제 `orders`/`kds_tickets` 행이 없는 비정상 상태가 라이브에 존재할 수 있다. Slice D는 크래시하지 않을 것으로 판단되나 라이브 검증되지 않았다 — 다음 TestPlan에서 이 경계 케이스를 반드시 재현 테스트로 확인해야 한다(§D.1, §G).

## Module Domain Tags

`waiting-pipeline`, `order-session`, `phantom-column-correction`, `facade-delegation`, `admin-view`, `session-events-derivation`, `exception-atomicity`

## Snapshot Decision

4개 함수를 4개 Slice로 나눠 설계했다: Slice A(`confirm_arrival`)는 `mark_session_arrived()`(`0025`, 미변경)에 위임하는 파사드로 재작성했고, Slice B/C(`get_waiting_status`/`get_waiting_admin_view`)는 `orders`/`dining_tables` LEFT JOIN과 `session_events` 파생(`called_at`/`call_count`)으로 phantom 컬럼을 치환했으며, Slice D(`cancel_waiting`)는 `cancel_reason`의 phantom 쓰기를 삭제하고 렛저를 단일 진실 소스로 확정했다. `has_pre_order` 판정 기준을 4개 함수 전부 `pre_order_created_at is not null`로 통일했다(§0). Slice A/D에는 `600652_Logic.md`가 확립한 `EXCEPTION` 핸들러 패턴(`audit_domain:='session'`, `raise` 대신 `build_error_response` 반환)을 새로 추가해 신규 `error_key` 2개(`waiting_confirm_arrival_failed`/`waiting_cancel_operation_failed`)가 필요해졌다 — `600661_Overview.md` §5의 "신규 키 0건" 전망을 이 Logic 단계에서 2건으로 정정한다. `memo`(§C.1)는 이번 워크패킷 범위에서 제거하기로 확정했고, `cancel_waiting()`의 상태 가드/테이블 반납 갭(§D.2)은 명시적으로 스코프 밖에 남겼다.
