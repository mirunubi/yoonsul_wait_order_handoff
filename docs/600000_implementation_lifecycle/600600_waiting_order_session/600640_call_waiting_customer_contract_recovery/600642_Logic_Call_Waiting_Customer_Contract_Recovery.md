# 600642_Logic_Call_Waiting_Customer_Contract_Recovery.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 Human 결정 요약 (병합 원칙, 재논의 금지)

`call_next_waiting()`(`0050`, 데이터 모델 정확)과 `call_waiting_customer()`(`0115`, 알림/테이블제안 로직 있으나 phantom 컬럼으로 크래시)의 장점을 **합친다** — 둘 중 하나를 골라 버리는 것이 아니다. 이는 오늘 이 세션에서 `600632_Logic.md`가 `0050`의 `arrival_reliability_score -20` 페널티를 `0115` 기반 위에 병합한 것과 동일한 원칙이다. **단, "병합"의 형태는 Q1 결정(§2)에 따라 "하나의 함수로 합치기"가 아니라 "정확한 데이터 계층을 두 함수가 공유하는 하나의 내부 헬퍼로 뽑아내고, 각 함수는 자신의 호출 방식(지정/자동)에 필요한 로직만 유지하기"로 구체화됐다** — 함수는 두 개로 남지만, 정확성(데이터 계층)과 기능(알림/테이블제안)은 중복 없이 한 곳에서 공유된다.

## §1 확정된 4가지 결정 반영 설계

### §1.1 `called_at` → `session_events`의 `'customer_called'` 이벤트로 기록

`call_next_waiting()`(`0050:244-262`)이 이미 쓰는, 라이브 `chk_session_event_type` CHECK 제약에 실존하는 이벤트 타입을 그대로 재사용한다. 신규 컬럼 없음. 실제 INSERT는 §2.1의 공유 헬퍼 안에 위치한다(Q1 결정으로 두 개의 공개 함수가 이 로직을 공유하게 되었으므로, 이하 §1.1-§1.4는 개념/근거만 정리하고 구체 SQL은 §2.1에 통합했다).

`from_status`는 하드코딩하지 않고 호출자(§2.2/§2.3)가 넘겨주는 실제 값을 쓴다 — 지정 호출(`call_waiting_customer`)은 재호출 시 `'ARRIVAL_PENDING'`일 수 있고, 자동 호출(`call_next_waiting_customer`)은 큐 선택 조건상 항상 `'WAITING'`이다. `event_payload`에 `table_suggestion` 키를 넣어 §1.3의 "저장은 안 하되 기록/응답에는 남긴다" 요구를 이벤트 원장 레벨에서도 충족시킨다(900161의 DID payload 용어 `table_suggestion`과 일관).

### §1.2 `call_count` → `session_events`에서 `COUNT(*)`로 파생

별도 컬럼 불필요. 공유 헬퍼가 INSERT 직후 같은 트랜잭션에서 집계한다(방금 넣은 행 포함):
```sql
select count(*) into v_call_count
from catchmenu_pos.session_events
where session_id = p_session_id
  and event_type = 'customer_called';
```
호출 경로(지정/자동)에 관계없이 동일 세션에 대한 모든 `'customer_called'` 이벤트를 합산하므로, 두 함수 중 어느 쪽으로 호출됐는지와 무관하게 정확한 누적 횟수가 된다 — 함수를 두 개로 분리하기로 한 Q1 결정과 자연스럽게 맞는다(한쪽 함수만 카운트를 관리했다면 분리 시 카운트가 어긋났을 것). `FOR UPDATE`로 세션 행이 이미 잠겨 있으므로(§2.2/§2.3) 동시 호출 간 이 COUNT 자체에 lost update 문제는 없다.

### §1.3 `table_number` → 저장 보류, 응답/알림에만 포함

`order_sessions`에 대한 UPDATE 문에서 `table_number` 컬럼 자체를 완전히 제거한다(원래 `0115:488-490`에 있던 `table_number = coalesce(p_table_number, table_number)` 절 삭제). `p_table_number`는 지정 호출(§2.2)에만 파라미터로 존재하며 계속 받되:
- `notify_channel()` 3종 호출(원본 `0115:495-532` 로직 그대로 유지)에 그대로 전달.
- §1.1의 `session_events.event_payload.table_suggestion`에 기록.
- 성공 응답 payload에 `table_suggestion`으로 echo.

세션 레코드 자체에는 영구 저장하지 않는다 — 900101이 호출 시점을 "선택사항"으로, TestPlan TC-004가 검증 조건에서 미요구로 명시한 근거를 그대로 따른다. 자동 호출(§2.3)은 애초에 `p_table_number` 파라미터가 없으므로 `null`로 헬퍼에 전달한다(§2.3).

### §1.4 `pre_order_amount` → `orders.final_amount` 조인으로 계산

스키마 변경 없음. `order_sessions.order_id`(실존)를 통해 조인 — 정확한 SELECT는 §2.2/§2.3 각 함수의 세션 조회부에 위치(두 함수 모두 동일 패턴 사용):
```sql
select os.id, os.wait_number, os.session_status,
       os.guest_count, os.guest_locale,
       os.phone_hash, os.customer_id,
       os.pre_order_created_at, os.order_id,
       o.final_amount as pre_order_amount
into v_session
from catchmenu_pos.order_sessions os
left join catchmenu_pos.orders o on o.id = os.order_id
where ...
for update of os;
```
`left join`인 이유: 사전주문 없이 호출되는 세션(`order_id is null`)도 정상 케이스이므로 — 이 경우 `pre_order_amount`는 `null`, `has_pre_order`는 `os.pre_order_created_at is not null`(false)로 자연스럽게 처리된다. `for update of os`로 잠금 대상을 `order_sessions`로 한정(`orders` 잠금 불필요, 락 범위 최소화).

## §2 병합 함수 설계 — 두 함수로 분리 유지, 공통 로직은 내부 헬퍼로 공유 (Human 결정 Q1, 재논의 금지)

**Q1 결정 요약**: 자동 큐 선택 기능은 병합하지 않는다. `call_waiting_customer()`(지정 호출)와 `call_next_waiting_customer()`(자동 다음 호출, 가칭)를 별도 함수로 유지하되, 공통 로직(호출 기록/이벤트/알림)은 내부 헬퍼로 공유한다. 이 결정으로 이전 버전 §2.1(함수명 단일화 옵션 비교)과 §2.2(자동 선택 병합 여부 Open Item)는 해소됐다 — 더 이상 "하나로 합칠지" 선택하는 문제가 아니라, "두 함수가 공통 코어를 어떻게 공유하는지" 설계 문제로 바뀌었다.

### §2.1 공유 내부 헬퍼 — `catchmenu_pos._record_waiting_call()`

PL/pgSQL 함수 파라미터는 익명 `record` 타입을 받을 수 없으므로(리턴 타입으로만 가능), 헬퍼는 두 호출자가 이미 조회·검증까지 마친 세션 정보를 개별 스칼라 파라미터로 전달받는 방식으로 설계한다 — 세션 조회/상태 게이트/만료시각 계산은 각 공개 함수(§2.2/§2.3)가 자신의 시나리오에 맞게 수행하고, "호출 확정 이후" 공통 부분(UPDATE, 이벤트 기록, 알림, 응답 조립)만 헬퍼가 담당한다.

```sql
create or replace function catchmenu_pos._record_waiting_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_from_status text,
  p_wait_number int,
  p_guest_locale text,
  p_phone_hash text,
  p_customer_id uuid,
  p_has_pre_order boolean,
  p_pre_order_amount int,
  p_table_number text,
  p_expires_at timestamptz,
  p_actor_type text,
  p_actor_id uuid,
  p_locale text,
  p_correlation_id text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, catchmenu_ledger
as $$
declare
  v_call_count int;
begin
  -- 세션 상태 전이 + 만료시각 스냅샷 저장 (§4)
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    expires_at = p_expires_at,
    updated_at = now()
  where id = p_session_id;

  -- session_events (§1.1)
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'customer_called',
    p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number,
      'table_suggestion', p_table_number,
      'expires_at', p_expires_at,
      'has_pre_order', p_has_pre_order
    ),
    p_correlation_id, now()
  );

  -- call_count 파생 (§1.2)
  select count(*) into v_call_count
  from catchmenu_pos.session_events
  where session_id = p_session_id and event_type = 'customer_called';

  -- 알림 3종 (0115:495-532 원문 로직 그대로)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE', p_event_type := 'waiting_called',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_number', p_table_number, 'guest_locale', p_guest_locale,
      'called_at', now(),
      'message', catchmenu_common.get_message(
        'waiting_called_alert', p_guest_locale,
        jsonb_build_object('wait_number', p_wait_number)
      )
    )
  );
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY', p_event_type := 'WAITING_CALL',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'display_number', p_wait_number,
      'table_number', p_table_number, 'queue_type', 'WAITING_CALL',
      'guest_locale', p_guest_locale
    )
  );
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS', p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash, 'customer_id', p_customer_id,
        'notification_type', 'WAITING_CALLED', 'wait_number', p_wait_number,
        'table_number', p_table_number, 'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1, 두 원본 함수 모두 이미 쓰던 패턴)
  insert into catchmenu_ledger.events (
    tenant_id, store_id, event_domain, event_type, event_version,
    subject_type, subject_id, from_state, to_state,
    caused_by_type, caused_by_id, event_payload, session_id,
    correlation_id, business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id, 'session', 'customer_called', 1,
    'order_session', p_session_id, p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number, 'has_pre_order', p_has_pre_order,
      'pre_order_amount', p_pre_order_amount
    ),
    p_session_id, p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_called_alert',
    p_data := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_suggestion', p_table_number, 'guest_locale', p_guest_locale,
      'has_pre_order', p_has_pre_order, 'pre_order_amount', p_pre_order_amount,
      'call_count', v_call_count, 'expires_at', p_expires_at,
      'did_called', true, 'push_sent', p_phone_hash is not null
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object('wait_number', p_wait_number),
    p_correlation_id := p_correlation_id
  );
end;
$$;
```
헬퍼는 `security definer`이지만 스키마 프리픽스(`_record_waiting_call`, 언더스코어 관례)로 "내부 전용, 직접 호출 대상 아님"을 표시한다 — 실제 접근 제어(권한 REVOKE 등)는 Stage 4 구현 시 프로젝트의 기존 internal-helper 관례를 따른다(이 문서는 명명 관례만 제안, 권한 설계는 범위 밖).

### §2.2 `call_waiting_customer()` — 지정 호출 (기존 `0115` 이름/시그니처 유지, `CREATE OR REPLACE`)

```sql
create or replace function catchmenu_pos.call_waiting_customer(
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
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_expire_at timestamptz;
begin
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
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
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 상태 게이트: WAITING/ARRIVAL_PENDING 둘 다 허용 (재호출 지원, 0115:467-481 원문 유지 —
  -- 900101:291 "✓ 재호출"과 정합. 0050의 WAITING-only보다 이쪽이 설계 문서와 일치.
  if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
    return catchmenu_common.build_error_response(
      p_error_key := case v_session.session_status
        when 'SEATED' then 'waiting_already_seated'
        else 'waiting_not_callable'
      end,
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 만료시각 스냅샷 계산 (§4 — wait_call_expire_minutes 채택, 매장별 설정)
  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := v_session.session_status,
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := p_table_number, p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;
```

### §2.3 `call_next_waiting_customer()`(가칭) — 자동 다음 호출 (신규 함수, `0050.call_next_waiting()`의 자동 선택 로직 이식)

"가칭"인 이유: Human 결정문이 이 이름을 "(가칭)"으로 명시했다 — 함수를 별도로 유지한다는 것과 그 역할(자동 큐 선택)은 확정이지만, 정확한 최종 명칭은 아직 확정이 아니다.

```sql
create or replace function catchmenu_pos.call_next_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
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
  v_expire_at timestamptz;
begin
  -- 자동 선택 (0050:194-211 원문 로직 그대로 — WAITING만 대상, 재호출 개념 없음)
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.session_status = 'WAITING'
  order by
    coalesce(os.queue_position, os.wait_number) asc nulls last,
    os.session_started_at asc
  limit 1
  for update of os skip locked;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'no_waiting_session_found',
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_next_waiting_customer'
    );
  end if;

  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := 'WAITING',
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := null,  -- 자동 호출 경로는 p_table_number 파라미터 자체가 없음(§1.3)
    p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;
```

### §2.4 DROP / CREATE 대상 — Q1로 확정

| 대상 | 처리 |
|---|---|
| `catchmenu_pos.call_next_waiting(uuid, uuid, text, uuid, uuid, text)`(`0050:151-305`) | **DROP**. 자동 선택 로직은 `call_next_waiting_customer()`로 완전히 이식되므로 대체됨. |
| `catchmenu_pos.call_waiting_customer(...)`(`0115:419-599`) | **DROP하지 않고 `CREATE OR REPLACE`**(시그니처 동일 유지 — 900xxx 21곳 인용과의 정합성, §2.1 옛 버전의 "옵션 A" 방향이 이번 Q1 결정으로 사실상 그대로 확정됨). |
| `catchmenu_pos.call_next_waiting_customer(...)`(가칭) | **신규 CREATE**. |
| `catchmenu_pos._record_waiting_call(...)` | **신규 CREATE**(internal 헬퍼). |

셋 다(DROP 대상 포함) 실호출자 0건이므로 이 변경 자체의 실행 리스크는 없다(재확인, `600631_Overview.md`/`600641_Overview.md`에서 이미 두 함수 모두 SQL/Flutter 어디서도 호출되지 않음을 확인).

## §3 §7 구조적 문제의 완전한 해소

`600641_Overview.md` §7이 지적한 "duplicate, non-overlapping implementations"(데이터는 맞지만 알림이 없는 `0050` vs 알림은 있지만 데이터가 깨진 `0115`) 문제는 이 설계로 완전히 해소된다 — Q1 결정으로 두 함수(지정 호출/자동 호출)가 계속 별도로 존재하게 됐지만, **더 이상 "우연히 중복된 두 구현"이 아니라 "의도적으로 역할이 분리된 두 진입점이 하나의 검증된 공통 코어(`_record_waiting_call()`)를 공유하는" 구조**로 바뀐다. 데이터 계층(§1.1-§1.4)과 알림/이벤트 기록 로직은 정확히 한 곳(헬퍼)에만 존재하므로, "기능은 맞지만 데이터가 깨진 버전"과 "데이터는 맞지만 기능이 없는 버전"이 별도로 존재하던 이전 상태는 사라진다 — 두 진입점 중 어느 쪽으로 호출되든 동일한 정확한 데이터 처리를 보장받는다.

## §4 `store_settings` 설정값 — 최종 확정 (Human 결정 Q2 + 시간 값 원칙, 재논의 금지)

### §4.1 재확인된 사실관계 (변경 없음, 근거로 유지)

```sql
-- 0049:42-43 (테이블 정의, "waiting settings" 섹션에 순서대로 인접)
wait_call_expire_minutes int not null default 5,
no_show_auto_expire_minutes int not null default 10,
```
- `wait_call_expire_minutes`: `0049`에서 정의되고(L42), `get_store_settings()` 응답 JSON에 노출된다(L230-231) — 이전까지는 이 컬럼을 실제로 읽는 함수가 SQL 전체에 0건이었다.
- `no_show_auto_expire_minutes`: `0049`에서 정의되고(L43) `get_store_settings()`에 노출되며(L232-233), `0050.call_next_waiting()`이 유일하게 읽어 `expires_at` 계산에 쓰던 소비처였다(`0050:222-230`).
- `0118`의 `WAITING_SESSION_EXPIRE` cron(`600630`/`600632` 범위)은 이 두 컬럼 중 어느 쪽도 읽지 않고 `interval '15 minutes'`를 하드코딩한다 — 이 워크패킷의 확정 범위 밖이므로 그대로 이월(§7 항목 2).

### §4.2 확정 — `wait_call_expire_minutes`를 canonical로 채택 (Q2)

이름이 실제 의미("호출 후 응답 대기시간")와 정확히 일치하는 `wait_call_expire_minutes`를 canonical 설정으로 확정한다. §2.2/§2.3의 만료 시각 계산은 이미 이 컬럼을 사용하도록 설계했다:
```sql
select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
into v_expire_at
from catchmenu_store.store_settings ss
where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');
```
`no_show_auto_expire_minutes`(`0050.call_next_waiting()`의 옛 소비처)의 이전 사용처는 이번 병합으로 `wait_call_expire_minutes`로 완전히 이전된다 — `call_next_waiting_customer()`(§2.3)도 동일하게 `wait_call_expire_minutes`만 읽는다.

`no_show_auto_expire_minutes`는 **즉시 DROP하지 않는다** — deprecated 표시만 하고 컬럼은 남긴다:
```sql
comment on column catchmenu_store.store_settings.no_show_auto_expire_minutes
  is 'DEPRECATED (600640): wait_call_expire_minutes로 대체됨. 사용처 없음. 별도 정리 워크패킷에서 DROP 검토.';
```
컬럼 제거 자체는 별도 후속 정리 워크패킷의 범위로 명시적으로 이월한다(§7 항목 1).

### §4.3 만료시각 스냅샷 저장 원칙 (Q2)

`expires_at`은 호출 시점에 **스냅샷으로 고정 저장**한다 — `now() + wait_call_expire_minutes`를 호출 시 1회 계산해 컬럼에 저장하고, 이후 이 값을 다시 계산하지 않는다(§2.1 헬퍼의 `update ... set expires_at = p_expires_at`). 재호출 시(`call_waiting_customer()`를 `ARRIVAL_PENDING` 세션에 다시 호출하는 경우) 헬퍼가 다시 실행되며 `expires_at`도 그 시점 기준으로 재스냅샷된다 — 이는 자연스럽게 "재호출하면 응답 대기시간이 그 시점부터 다시 시작된다"는 동작이 되며, §2 옛 버전에서 미해결로 남겼던 "재호출 시 타이머 리셋 여부"(900xxx 공백 영역)에 대해 이 설계가 실질적인 답을 제공한다 — 다만 이것이 최적의 운영 정책인지는 여전히 실제 데이터로 검증될 사안이다(§4.4).

### §4.4 매장별 설정 가능 원칙 (Human 결정, 재확인 문구)

**`wait_call_expire_minutes`의 정확한 유예 시간(몇 분)은 지금 하나의 값으로 확정하지 않는다.** 이 문서는 `store_settings`의 현재 스키마 기본값(`0049:42`, 5분)을 그대로 default로 유지할 뿐, 이 값이 모든 매장에 적용될 "정답"이라고 주장하지 않는다. `store_settings`는 이미 매장(`store_id`) 단위로 행이 존재하는 구조이므로, **이 값은 매장마다 자유롭게 재설정 가능해야 하며 이미 그렇게 설계되어 있다** — `catchmenu_store.get_store_settings()`/`update_business_hours()` 등 기존 `0049` RPC들이 이미 매장별 조회/수정을 전제로 하는 것과 동일한 구조를 그대로 따른다. 실제 운영 데이터가 쌓이면 매장마다 최적값이 다를 것을 전제로 하며, 이는 `600632_Logic.md`가 이미 확립한 "지금 결정은 확정이 아니다" 원칙의 연장선이다 — 하드코딩 금지, 조정 가능한 설정으로 유지, 향후 데이터 기반 재조정을 전제로 한다.

## §5 범위 경계 — 이 워크패킷이 다루는 "노쇼"의 정의 (제미나이 분류 활용, Human 결정)

이 워크패킷(및 상위 `600630`/`600632`)이 다루는 "노쇼"는 **웨이팅(대기열) 노쇼**로 한정한다 — 순수 대기 노쇼, 사전주문 대기 노쇼(`has_pre_order`로 구분되는 것)만이 범위다. 아래 4개 범주는 완전히 다른 정책(결제/환불 방어, 좌석 점유, 폐기 비용, 블랙리스트)이 필요한 별도 도메인이며, 이번 워크패킷 및 `600630`/`600632`의 설계·구현 범위에 포함되지 않는다:

| 노쇼 유형 | 특징 | 이번 범위 포함 여부 |
|---|---|---|
| **웨이팅(대기열) 노쇼** | 순수 대기 / 사전주문 대기, `has_pre_order`로 구분 | **포함** (`600630`/`600632`/`600640`/`600642`) |
| 포장/픽업 노쇼 | 선결제 미수령(환불 처리 필요) 또는 현장결제 악성 노쇼(조리된 음식 폐기 비용 발생) | 범위 밖 |
| 예약 노쇼 | 전체 노쇼/부분 노쇼(일부 인원만 도착)/지각 — 좌석을 미리 점유해 둔 상태에서의 기회비용 문제 | 범위 밖 |
| 단체·케이터링 노쇼 | 대규모 사전 준비(식자재/인력)가 걸린 고액 리스크 | 범위 밖 |
| 배달 연락두절 | 배달원/고객 연락 두절, 배달 특유의 물류·환불 문제 | 범위 밖 |

이 분류는 향후 각 유형별로 별도 워크패킷이 필요할 수 있음을 명시하기 위한 참고 자료로 기록하며, 이번 워크패킷에서 어떤 설계도 선결정하지 않는다.

## §6 향후 전략 아이디어 — 이번 범위 아님 (기록용)

**노쇼 블랙리스트/페널티 시스템**(제미나이 제안): 반복적으로 악성 노쇼를 저지르는 고객의 계정을 정지하거나 향후 예약/대기 시 선결제를 강제하는 시스템. 이는 개별 세션이 아니라 **고객 계정을 가로지르는 별도 도메인**(현재 `arrival_reliability_score`가 세션 단위로만 존재하는 것과 달리, 고객 단위 누적 이력·정책 집행이 필요)이며, 이번 워크패킷 범위에 포함하지 않는다 — 향후 전략 아이디어로만 기록한다.

## §7 Open Items (Human 결정 필요, 이전 §5의 1-4번은 이번 Q1/Q2 결정으로 해소됨)

1. `no_show_auto_expire_minutes` 컬럼의 실제 DROP 시점 — §4.2에서 deprecated 표시만 하기로 확정했으나, 실제 제거는 별도 후속 정리 워크패킷(가칭 `store_settings_deprecated_column_cleanup`)의 범위로 이월.
2. `0118`의 `WAITING_SESSION_EXPIRE` cron이 여전히 `interval '15 minutes'` 하드코딩(어느 `store_settings` 컬럼도 읽지 않음) — 이 워크패킷이 `wait_call_expire_minutes`를 canonical로 확정했으므로, `600630`/`600632`가 그 cron을 고칠 때 이 컬럼을 반영해야 한다는 점을 교차 참조로 남긴다(`600632_Logic.md`의 §8 갱신 필요 여부는 `600630` 쪽 판단).
3. §1.2의 `call_count` COUNT(*) 방식이 응답 payload 표시 목적 이상(예: N회 이상 재호출 시 자동 알림 등 향후 정책)으로 쓰일 가능성이 있다면 컬럼화가 필요할 수 있음 — 현재는 표시 전용으로 가정, 추가 요구사항 발견 시 재검토.
4. `call_next_waiting_customer()`의 최종 명칭 확정 — "(가칭)" 상태(§2.3).
5. §5/§6에서 범위 밖으로 명시한 4개 노쇼 유형 및 블랙리스트 시스템 — 각각 별도 워크패킷 필요 여부와 우선순위는 이 문서가 판단하지 않음.
6. 이 워크패킷의 Stage 4 구현이 완료·검증(PASS)되어야 `600630`/`600632`의 BLOCKED 상태가 해제된다 — 순서 의존성 재확인.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` — 이 문서의 직접 전제(4가지 결정의 증거 전체).
- `600632_Logic_Mark_No_Show_Overload_And_Redesign.md`(BLOCKED 섹션) — 이 워크패킷의 완료 조건을 요구하는 다운스트림 문서.

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:419-599` — 병합 베이스(알림/게이트/시그니처).
- `sql/migrations/0050_create_waiting_queue_rpc.sql:151-305` — 병합 베이스(데이터 계층/이벤트 기록).
- `sql/migrations/0012_create_pos_order_sessions.sql:221-243` — `session_events` `event_type` CHECK 허용 목록.
- `sql/migrations/0049_create_store_settings_rpc.sql:17-60, 220-235` — `store_settings` 두 컬럼 정의/노출부, §4 근거.
- `sql/migrations/0051_create_pre_order_rpc.sql:298-304` — `orders.final_amount` 소스.
- 900xxx 21곳 `call_waiting_customer` 인용(전체 목록은 grep 결과, §2.4의 이름 유지 결정 근거) — 특히 `900161_Logic...md:104`(단일 세션 트리거 서술).

### Domain Indexes

- `600602_NavigationMap_Waiting_Order_Session.md`.

### Excluded Rule Families

- `0118`의 cron 자체 수정 — `600630`/`600632` 범위, 이 문서는 `store_settings` 컬럼 사실관계만 제공(§4).
- `confirm_arrival()` phantom 컬럼 — 범위 밖(기존 확정 유지).
- Flutter Staff 앱 실제 구현 — Scope D 게이트 이후.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**§2/§4 최종 확정 완료 — Q1/Q2 반영, 잔여 Open Item은 부수적 사안으로 축소.** §1의 4가지 결정(called_at→session_events, call_count→COUNT(*), table_number→저장보류, pre_order_amount→orders 조인)을 구체적 SQL로 설계했다. §2는 Human 결정 Q1(자동 큐 선택 기능은 병합하지 않고 별도 함수 유지, 공통 로직은 내부 헬퍼 `_record_waiting_call()`로 공유)을 전면 반영해 재작성했다 — `call_waiting_customer()`(지정 호출, `0115` 이름/시그니처 유지)와 `call_next_waiting_customer()`(자동 다음 호출, 가칭, `0050`의 자동 선택 로직 이식)를 완전한 SQL 본문으로 설계했고, §2.4에서 DROP/CREATE 대상을 확정했다(더 이상 옵션 비교가 아님). §3에서 `600641_Overview.md` §7의 구조적 중복 문제가 "의도적 역할 분리 + 공유 코어" 구조로 완전히 해소됨을 명시했다. §4는 Human 결정 Q2(`wait_call_expire_minutes`를 canonical로 확정, `no_show_auto_expire_minutes`는 deprecated 표시만 하고 즉시 DROP하지 않음, 만료시각은 호출 시점 스냅샷으로 고정 저장)와 "매장별 설정 가능" 원칙(기본값 5분 유지하되 `store_settings`를 통해 매장마다 자유롭게 재설정 가능해야 함을 명시적으로 재확인 — `600632_Logic.md`가 확립한 "지금 결정은 확정이 아니다" 원칙의 연장)을 반영해 확정했다. §5/§6에서 제미나이의 4대 노쇼 유형 분류(포장/픽업, 예약, 단체·케이터링, 배달)와 노쇼 블랙리스트 시스템 아이디어를 이번 범위 밖으로 명시적으로 경계 짓고 향후 참고용으로 기록했다. `.sql` 파일은 생성·수정하지 않았다. §7의 6개 잔여 Open Item(대부분 후속 정리/이월성 사안, Q1/Q2처럼 이 워크패킷의 캐노니컬 설계 자체를 좌우하는 사안은 아님)에 대한 Human 결정 이후 `600643_TestPlan.md`로 진행한다.
