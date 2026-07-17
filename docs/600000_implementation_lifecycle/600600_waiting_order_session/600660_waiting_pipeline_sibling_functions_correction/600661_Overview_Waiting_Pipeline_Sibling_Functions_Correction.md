# 600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`waiting_pipeline_sibling_functions_correction`

## §0.1 원칙 (문서 전체에 적용)

`0115_create_waiting_pipeline_rpc.sql`에 원래 작성된 함수들은 라이브 스키마와 어긋나는 `order_sessions`의 phantom 컬럼(존재한 적 없거나, 다른 이름의 실컬럼으로 대체된 컬럼)을 참조해서 호출할 때마다 크래시한다. `0160_call_waiting_customer_contract_recovery.sql`(`call_waiting_customer()`)과 `0163_seat_waiting_customer_facade_correction.sql`(`seat_waiting_customer()`)이 이미 이 문제를 해소한 두 가지 검증된 패턴이 있다:

1. **금액류 phantom 컬럼**(`pre_order_amount`): `order_sessions.order_id` → `catchmenu_pos.orders.final_amount` LEFT JOIN으로 대체.
2. **라벨류 phantom 컬럼**(`table_number`): `order_sessions`에 저장하지 않고, 호출 시점의 `p_table_number`/`dining_tables.table_code` 조회 결과를 응답 payload에만 실어 보낸다.

이 워크패킷은 이 두 패턴(및 §2가 새로 확립하는 세 번째 패턴)을 `0115`에 남은 나머지 4개 함수 — `confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` — 에 적용 가능한지 라이브로 재검증하고, 적용 설계를 확정한다.

## §0.2 배경 — 오늘 이전에 이미 확인된 사실 (재확인 없이 인용, §1에서 최신 라이브 상태만 재확인)

`600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` §4.1이 이미 다음을 확인해 스코프 밖으로 남겨두었다: `confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` 4개 함수 모두 phantom 컬럼(`pre_order_amount`/`table_number`/`called_at`/`arrival_confirmed_at`) 참조로 크래시하거나 크래시 위험이 있다.

## §1 함수별 라이브 재확인 — 정확한 라인, phantom 컬럼, 그 외 로직

사전 확인: `information_schema.columns`로 `catchmenu_pos.order_sessions`의 라이브 컬럼 전체를 재조회했다(2026-07-18). 존재하는 시간 계열 컬럼은 `session_started_at`/`arrived_at`/`seated_at`/`ordering_started_at`/`order_confirmed_at`/`payment_started_at`/`payment_completed_at`/`completed_at`/`cancelled_at`/`expires_at`/`pre_order_created_at`/`pre_order_expires_at`이 전부다. `queue_position`은 실컬럼이며 `0050_create_waiting_queue_rpc.sql`의 대기열 재정렬 RPC와 `0115`의 `register_waiting()`이 이미 이 컬럼에 쓰고 있어 활성 상태임을 확인했다(§1.3에서 이 사실이 중요해진다). `memo`/`call_count`/`table_number`/`pre_order_amount`/`called_at`/`arrival_confirmed_at`/`cancel_reason`은 **모두 존재하지 않는다.**

### §1.1 `confirm_arrival()` (`0115:872-985`)

**Phantom 컬럼 참조:**

| 라인 | 종류 | 컬럼 | 비고 |
|---|---|---|---|
| 897-899 | SELECT | `pre_order_amount`, `table_number` | `v_session` record에 로드 |
| **921** | **UPDATE (쓰기)** | **`arrival_confirmed_at`** | 이 UPDATE 문 자체가 크래시 지점 — `seat_waiting_customer()`의 `table_number` UPDATE(`600651_Overview.md` §1.1)와 동일한 클래스의 결함이지만, 저 함수와 달리 이건 **쓰기** 시도이므로 SELECT 단계까지 갈 것도 없이(사실 SELECT가 먼저 크래시하지만) 도달했다면 여기서도 별도로 크래시했을 것이다 |
| 934-937, 958-959, 970-973 | 응답/알림/렛저 payload 구성 | `pre_order_amount` | `v_session.pre_order_amount` 읽기 |
| 974 | 응답 payload | `table_number` | `v_session.table_number` |

**그 외 로직(정상, 보존 대상):** `session_status → 'ARRIVAL_PENDING'` 전이, `notify_channel()`(`WAITING_QUEUE`/`waiting_arrival_confirmed`), `catchmenu_ledger.events` 삽입(`waiting`/`arrival_confirmed`), 성공 응답의 `next_step`(사전주문 있으면 `PROCEED_TO_PAYMENT`, 없으면 `WAIT_FOR_SEATING`) 분기.

**phantom 컬럼과 무관한, 추가로 발견된 결함**: 이 함수는 `session_status`에 대한 사전 가드가 전혀 없다 — `v_session.id is null` 체크 다음 곧바로 `UPDATE ... session_status = 'ARRIVAL_PENDING'`을 실행한다. 즉 이미 `SEATED`/`CANCELLED`/`COMPLETED` 상태인 세션도 그대로 `ARRIVAL_PENDING`으로 되돌려버릴 수 있다. `call_waiting_customer()`(`0160`이 이미 수정)는 `session_status not in ('WAITING','ARRIVAL_PENDING')`을 명시적으로 검사하는데, `confirm_arrival()`에는 이 가드가 원래부터 없었다. §1.5에서 이 결함이 자연스럽게 해소되는 설계를 제시한다(범위 확장이 아니라, 이미 존재하는 canonical core에 위임하는 것의 부수 효과).

### §1.2 `get_waiting_status()` (`0115:1466-1579`)

**Phantom 컬럼 참조:**

| 라인 | 종류 | 컬럼 |
|---|---|---|
| 1490-1497 | SELECT | `pre_order_amount`, `table_number`, `called_at`, `arrival_confirmed_at` (4개) |
| 1536, 1540-1542 | 응답 payload | `table_number`, `pre_order_amount` |
| 1546, 1548 | 응답 `timestamps` payload | `called_at`, `arrival_confirmed_at` |

같은 SELECT가 `queue_position`(1492)과 `seated_at`(1497)도 함께 읽는데, 이 둘은 **실컬럼**이다 — 다만 `queue_position`은 읽고도 이후 전혀 쓰이지 않는 죽은 필드다(대신 라인 1515-1523의 별도 카운트 쿼리로 계산한 지역변수 `v_queue_position`을 응답에 사용). phantom 컬럼 수정과 무관한 사소한 정리 대상으로만 기록한다(§1.5에서 죽은 SELECT 항목 제거 여부 결정).

**그 외 로직(정상, 보존 대상):** `STABLE`(읽기 전용), 세션 존재 확인 후 "내 앞 대기 인원"(`wait_number` 비교 카운트)과 예상 대기시간(10분/인 고정 계수) 계산, `catchmenu_common.get_message()`를 통한 다국어 상태 메시지 조립.

### §1.3 `get_waiting_admin_view()` (`0115:1582-1729`)

**Phantom 컬럼 참조 (기존에 알려진 4개보다 1개 더 많다 — `memo`가 오늘 라이브 재확인에서 추가로 발견됨):**

| 라인 | 종류 | 컬럼 |
|---|---|---|
| 1616 | jsonb_build_object | `os.table_number` |
| 1618, 1620, 1680-1685 | jsonb_build_object + 통계 집계 | `os.pre_order_amount` / `pre_order_amount` |
| 1626 | jsonb_build_object | `os.called_at` |
| 1627 | jsonb_build_object | `os.call_count` |
| **1628** | jsonb_build_object | **`os.memo`** — 이번 재확인에서 처음 특정됨. `600651_Overview.md`가 나열한 4종(`pre_order_amount`/`table_number`/`called_at`/`arrival_confirmed_at`)에 없던 5번째 phantom 컬럼 |

**`memo`는 §1.6에서 별도로 다룬다** — 나머지 4종과 달리 대체할 실컬럼이나 파생 가능한 소스가 전혀 없다(스키마 신설이 필요할 수 있는 유일한 케이스).

**그 외 로직(정상, 보존 대상):** `STABLE`(읽기 전용), 오늘 영업일 `WAITING`/`ARRIVAL_PENDING` 세션 목록을 `queue_position asc nulls last, wait_number asc`로 정렬해 배열로 조립, 상태별 `actions`(CALL/SEAT/NO_SHOW/CANCEL) 힌트 배열 생성, 오늘 통계(등록/완료/취소/노쇼/사전주문 건수·금액/외국인 비율/평균 대기시간) 별도 집계.

**phantom 컬럼과 무관하게 발견된 이상 항목**: 응답 payload에 `'patent_note', jsonb_build_object('patent1', 'Full journey tracked per session', 'patent2', 'Pre-order KDS HOLD until payment', ...)`가 하드코딩되어 있다(라인 1716-1723). 대기열 관리 API 응답에 특허 관련 문구를 담아 보내는 것은 이 워크패킷의 phantom 컬럼 교정과는 무관한 별개 사안이므로, §6 Open Item으로만 기록하고 이 문서에서 제거 여부를 판단하지 않는다.

### §1.4 `cancel_waiting()` (`0115:1207-1330`)

**Phantom 컬럼 참조 (2개, 가장 적음):**

| 라인 | 종류 | 컬럼 |
|---|---|---|
| 1235-1236 | SELECT | `pre_order_amount` |
| **1259** | **UPDATE (쓰기)** | **`cancel_reason`** |

**그 외 로직(정상, 보존 대상):** `session_status → 'CANCELLED'`, `cancelled_at = now()`(실컬럼, 정상), 사전주문이 있으면 연결된 `catchmenu_kds.kds_tickets`(HOLD 상태)를 `CANCELLED`로 함께 전이, `notify_channel()`, 렛저 이벤트(`waiting`/`waiting_cancelled`) — `cancel_reason` 값은 이미 렛저 `event_payload`에도 담기고 있다(1307, 1322)는 점이 §1.7의 수정 설계에서 근거가 된다.

**phantom 컬럼과 무관하게 발견된 결함**: `confirm_arrival()`과 마찬가지로 `session_status`에 대한 사전 가드가 없다 — 이미 `SEATED`(테이블 점유 중)인 세션도 그대로 `CANCELLED`로 전이시킬 수 있는데, 이 경우 `dining_tables.table_status`를 `AVAILABLE`로 되돌리는 로직이 이 함수는 물론 코드베이스 전체 어디에도 없다(`table_status = 'AVAILABLE'`을 UPDATE SET 대상으로 쓰는 함수를 전수 검색한 결과 0건, §1.7에서 스코프 제외 근거로 재인용). `confirm_arrival()`과 달리 위임할 수 있는 canonical core(`bind_table_to_session()`에 대응하는 "테이블 반납/세션 취소" 함수)가 존재하지 않아, 이 결함은 이번 워크패킷의 위임 패턴으로 자동 해소되지 않는다 — §6 Open Item으로 명시적으로 남긴다.

### §1.5 `confirm_arrival()`의 위임 대상 — `catchmenu_pos.mark_session_arrived()` (신규 발견, `0025_create_session_rpc.sql:232-324`)

`seat_waiting_customer()`가 `bind_table_to_session()`에 위임하는 것과 정확히 같은 구조의 canonical core 함수가 이미 존재한다. 라이브 `pg_get_functiondef()`로 전문을 재확인했다:

```sql
-- 0025:264-278 (핵심부)
if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
  return jsonb_build_object(
    'success', false, 'error_key', 'invalid_session_status',
    'current_status', v_session.session_status
  );
end if;

update catchmenu_pos.order_sessions
set
  session_status = 'ARRIVAL_PENDING',
  arrived_at = now(),          -- 실컬럼. confirm_arrival()의 phantom arrival_confirmed_at이 원래 의도했을 대상
  updated_at = now()
where id = p_session_id;
-- + session_events('customer_arrived') 삽입, ledger.events('session'/'customer_arrived') 삽입
-- + return jsonb_build_object('success', true, 'session_id', ..., 'session_status', 'ARRIVAL_PENDING', 'arrived_at', now())
```

라이브 확인 결과:
- `chk_session_seated_after_arrived` 제약(`CHECK (seated_at IS NULL OR arrived_at IS NULL OR seated_at >= arrived_at)`)이 `arrived_at`을 "착석 이전에 채워지는 시각"으로 스키마 레벨에서 이미 규정하고 있다 — `confirm_arrival()`이 원래 쓰려던 `arrival_confirmed_at`의 정확한 실질적 대응물이다.
- `proacl`은 `{postgres=X/postgres, authenticated=X/postgres}` — 이미 `authenticated`에게 GRANT되어 있다.
- 이 함수를 호출하는 곳은 SQL 마이그레이션 전체에 0건이다(`grep -rn mark_session_arrived sql/migrations` 결과 정의·GRANT/REVOKE 줄만 매치) — `bind_table_to_session()`이 `0163` 이전까지 고아 상태였던 것과 동일한 상황.
- 자체 `EXCEPTION` 핸들러 없음(단순 `begin...end` 블록) — `bind_table_to_session()`과 동일한 특성. 즉 `600652_Logic.md` §9.2가 확인한 "호출자의 EXCEPTION 핸들러가 잡으면 이 함수의 변경도 함께 롤백된다"는 원자성 성질이 여기도 그대로 적용된다.

**결론**: `confirm_arrival()`을 `seat_waiting_customer()`와 같은 얇은 파사드로 다시 짜서 `mark_session_arrived()`에 위임하면, phantom 컬럼 문제와 §1.1이 발견한 "상태 가드 없음" 문제가 **동시에** 해소된다 — `mark_session_arrived()`가 이미 `session_status not in ('WAITING','ARRIVAL_PENDING')` 가드를 갖고 있기 때문이다. 이것은 범위 확장이 아니라, `bind_table_to_session()`을 쓸 때와 정확히 같은 이유(이미 존재하는, 더 엄격하고 올바른 core를 그대로 재사용)로 자연스럽게 딸려오는 개선이다.

### §1.6 `called_at`/`arrival_confirmed_at` — 두 컬럼 모두 phantom, 대체 방법 확인 (작업 지시 항목 3)

- **`arrival_confirmed_at`**: phantom. 실컬럼 `arrived_at`으로 직접 대체(파생·JOIN 불필요 — §1.5).
- **`called_at`**: phantom. 그러나 **`0160`이 이미 확립한 파생 패턴**이 정확히 이 정보를 담고 있다: `_record_waiting_call()`(`0160_call_waiting_customer_contract_recovery.sql:37` 함수 정의 시작, `73-88`에서 `catchmenu_pos.session_events`에 `event_type='customer_called'` 행을 `occurred_at=now()`로 삽입)이 매 호출 시 이 행을 삽입하고, 같은 함수의 `92-95`줄이 `select count(*) from session_events where session_id=... and event_type='customer_called'`로 `call_count`(§1.3의 4번째 phantom 컬럼)를 파생시키는 것을 이미 라이브로 확인했다(`600653_TestPlan.md`류 검증 대상은 아니었지만 이번 재확인으로 직접 읽음 — 최초 인용 시 `11-38`/`41-43`으로 잘못 기재했던 것을 Stage 4 검증에서 지적받아 재확인 후 정정). 즉:
  - `called_at` := `select max(occurred_at) from session_events where session_id=<id> and event_type='customer_called'` (재호출 지원 — `call_waiting_customer()`가 여러 번 호출될 수 있으므로 마지막 호출 시각)
  - `call_count` := `select count(*) from session_events where session_id=<id> and event_type='customer_called'` — `_record_waiting_call()` 92-95줄과 동일한 표현식, 새로 발명하지 않고 그대로 재사용

이 두 값은 하나의 `LEFT JOIN LATERAL` 서브쿼리로 한 번에 계산 가능하다(Logic.md §C에서 확정).

### §1.7 `cancel_reason` — 대체 컬럼 없음, 별도 패턴 필요

나머지 phantom 컬럼(`pre_order_amount`/`table_number`/`called_at`/`arrival_confirmed_at`)은 전부 "실컬럼 또는 파생 가능한 소스가 존재"하는 케이스인 반면, `cancel_reason`은 `order_sessions`에도, 다른 어떤 테이블에도 대응하는 컬럼이 없다. 다만 라이브 재확인 결과 `cancel_waiting()`은 이미 `p_cancel_reason` 값을 `catchmenu_ledger.events.event_payload`(1307)와 `notify_channel()` payload(1285)에 담아 보내고 있다 — 즉 **취소 사유 정보 자체는 이미 유실 없이 렛저에 영구 보존된다.** 세션 행 자체에 중복 저장하지 않는 것은 정보 손실이 아니라 단순 중복 제거다. Logic.md §D에서 "phantom 쓰기를 삭제하고 렛저를 단일 진실 소스로 삼는다"는 세 번째 패턴으로 확정한다.

## §2 admin_list 패턴 일관성 검토 (작업 지시 항목 4)

기존 admin_list류 3개 함수의 응답 형태를 라이브로 대조했다:

| 함수 | 응답 형태 | 비고 |
|---|---|---|
| `catchmenu_store.get_staff_admin_list()` | `catchmenu_common.build_success_response()` + `message_catalog` | |
| `catchmenu_pos.get_waiting_admin_view()` | `catchmenu_common.build_success_response()` + `message_catalog` | **이미 이 패턴을 따르고 있음** |
| `catchmenu_store.get_dining_table_admin_list()`(`601120`, 이번 세션에 신설) | 원시 `jsonb_build_object('success', true, 'data', {...}, 'message_code', ...)` | 3개 중 유일하게 `build_success_response()`를 쓰지 않는 예외 |

**결론**: `get_waiting_admin_view()`는 이미 더 오래되고 더 널리 쓰이는 다수 패턴(`build_success_response()`)을 따르고 있다 — 오히려 `601120`의 `get_dining_table_admin_list()` 쪽이 소수/예외 사례다. 따라서 이 워크패킷에서 `get_waiting_admin_view()`의 응답 형태(shape) 자체를 바꿀 필요는 없다 — phantom 컬럼만 교정하면 기존 형태를 그대로 유지할 수 있다. (`601120`의 불일치는 이 워크패킷의 범위가 아니므로 손대지 않는다 — §6 Open Item으로만 기록.)

## §3 워크패킷 분리 여부 판단 (작업 지시 항목 5)

"같은 클래스(phantom 컬럼 치환)면 묶고, 다른 개념이 섞이면 쪼갠다" 원칙 적용:

**같은 워크패킷으로 묶는 근거:**
1. 4개 함수 모두 **동일한 단일 원인**(`0115` 원저작 시점에 실제 스키마와 다른 컬럼명을 가정)에서 비롯된 결함이고, 수정 패턴은 이미 `0160`/`0163`이 확립한 두 가지(orders LEFT JOIN, payload-only) + 이 문서 §1.6/§1.7이 새로 확정한 두 가지(session_events 파생, 렛저-단일-진실-소스)의 조합일 뿐 — 함수마다 처음부터 설계를 새로 하는 게 아니라 기존 패턴을 적용하는 작업이다.
2. `confirm_arrival()`을 제외한 나머지 3개(`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`)는 위임 대상 core 함수를 새로 설계할 필요가 없는, 상대적으로 소규모인 SELECT/UPDATE 컬럼 치환이다.
3. `601120_dining_table_crud_creation`이 이미 "성격이 다른 3개 함수(upsert/activate/list)를 하나의 워크패킷으로 묶는" 직접 선례다 — 그 경우도 "다이닝 테이블 CRUD"라는 하나의 일관된 주제 아래 여러 함수를 함께 설계했다.
4. `0160`/`0163`이 각각 별도 워크패킷이었던 것은 "같은 클래스라서 쪼갠 것"이 아니라, 서로 다른 시점에 순차적으로 발견·착수되었기 때문이다(설계 원칙에 따른 의도적 분리가 아님) — 지금은 4개를 동시에 파악한 시점이므로 순차적 발견이라는 분리 사유 자체가 없다.

**다만 완전히 균일하지는 않다** — `confirm_arrival()`만 "파사드 신설 + canonical core 위임"이라는 `0163`과 동형의 설계가 필요하고, 나머지 3개는 위임 없는 단순 컬럼 치환이다. 이 차이는 워크패킷을 쪼갤 정도는 아니지만(모두 "phantom 컬럼 치환"이라는 상위 클래스에 속함), Logic.md 내부에서 **Slice A(confirm_arrival, 위임형) / Slice B(get_waiting_status, 읽기형) / Slice C(get_waiting_admin_view, 읽기형 + memo 결정) / Slice D(cancel_waiting, 쓰기형 + 스코프 제외)**로 명확히 나눠 기술한다 — `601142_Logic.md`가 이미 이 세션에서 Slice 1/Slice 2로 같은 워크패킷 내부를 나눈 선례를 따른다.

**결론: 4개 함수를 `600660_waiting_pipeline_sibling_functions_correction` 하나의 워크패킷으로 묶는다.**

## §4 이번 워크패킷에서 명시적으로 제외하는 항목 (스코프 밖)

1. **`cancel_waiting()`의 상태 가드 부재 + 테이블 반납 로직 부재** (§1.4) — `dining_tables.table_status`를 `AVAILABLE`로 되돌리는 함수가 코드베이스 전체에 0건이라는, 이 워크패킷보다 훨씬 넓은 범위의 시스템 갭이다. 별도 워크패킷 후보(가칭 `cancel_waiting_state_guard_and_table_release`)로 이관.
2. **`get_waiting_admin_view()`의 `patent_note` 하드코딩 문구** (§1.3) — phantom 컬럼과 무관.
3. **`get_dining_table_admin_list()`(`601120`)의 응답 형태 불일치** (§2) — 이 워크패킷의 대상 함수가 아니다.
4. **`get_waiting_admin_view()`의 `memo` phantom 컬럼** (§1.3, §1.6) — 대체 실컬럼이나 파생 소스가 전혀 없어 스키마 신설이 필요할 수 있는 유일한 케이스. 이 워크패킷의 "기존 실컬럼/파생으로 치환" 패턴 범위를 벗어나므로, Logic.md §C에서 "필드를 임시로 제거"와 "새 컬럼 추가(별도 스코프)" 두 옵션을 제시하고 하나를 확정하되, 후자를 선택하더라도 실제 스키마 변경(.sql)은 이번 워크패킷에서 수행하지 않는다.
5. Flutter/클라이언트 통합 — 4개 함수 모두 현재 호출자 0건이므로 범위 밖(작업 지시 명시).

## §5 영향 요약

| 함수 | phantom 컬럼 수 | 수정 패턴 | 위임 대상 |
|---|---|---|---|
| `confirm_arrival()` | 2 read + 1 write | 파사드화 | `mark_session_arrived()` (`0025`, 미변경) |
| `get_waiting_status()` | 4 read | orders LEFT JOIN + dining_tables LEFT JOIN + session_events 파생 | 없음(단일 함수 내 수정) |
| `get_waiting_admin_view()` | 5 read (`memo` 포함) | 동상 + `memo` 별도 결정 | 없음 |
| `cancel_waiting()` | 1 read + 1 write | orders LEFT JOIN + phantom 쓰기 삭제(렛저가 단일 진실 소스) | 없음 |

신규 `error_codes`/`message_catalog` 항목: **잠정 0건**(phantom 컬럼 치환 자체만 놓고 보면 4개 함수 모두 기존에 등록된 `waiting_session_not_found`만 재사용하거나, `mark_session_arrived()`의 미등록 flat key를 `0163` §2.1과 동일하게 재래핑 없이 그대로 통과시킨다). **단, `600662_Logic.md` §0.1이 Slice A(`confirm_arrival`)/Slice D(`cancel_waiting`)에 신규 `EXCEPTION` 핸들러를 추가하기로 결정하면서 신규 키가 2건(`waiting_confirm_arrival_failed`/`waiting_cancel_operation_failed`) 필요해졌다 — 이 문서 작성 시점의 전망이 Logic 설계 단계에서 정정된 것이며, `600662_Logic.md` §E가 최신·확정 값이다.** 그래도 `0163`(5개 신규 키)보다는 가벼운 워크패킷이다.

## §6 Open Items

(a) `cancel_waiting()` 상태 가드 부재 + 테이블 반납 로직 부재 — 별도 워크패킷 후보 (§4-1).
(b) `get_waiting_admin_view()`의 `patent_note` 하드코딩 — 별도 사안 (§4-2).
(c) `get_dining_table_admin_list()`(`601120`) 응답 형태 불일치 — 이 워크패킷 범위 밖 (§4-3).
(d) `get_waiting_admin_view()`의 `memo` — 실컬럼/파생 소스 없음, Logic.md §C에서 임시 제거 vs 신규 컬럼 중 결정 (§4-4).
(e) `get_waiting_status()`의 죽은 `queue_position` SELECT 항목 — phantom은 아니지만 정리 대상 여부 결정 필요 (§1.2).
(f) `_record_waiting_call()`의 `proacl` 공백 — `600652_Logic.md` §8 Open Item (d), 이 워크패킷도 손대지 않음(범위 밖 원칙 동일 적용).
(g) 이 4개 함수 모두 원본에 `EXCEPTION` 핸들러가 없다 — `0160`/`0163`이 신규로 확립한 "raise 대신 build_error_response 반환" 패턴을 추가할지 여부, Logic.md에서 함수별로 결정.

## Module Domain Tags

`waiting-pipeline`, `order-session`, `phantom-column-correction`, `facade-delegation`, `admin-view`, `session-events-derivation`

## Snapshot Decision

이 문서는 `confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` 4개 함수를 `600660_waiting_pipeline_sibling_functions_correction` 하나의 워크패킷으로 묶기로 결정했다(§3) — `0160`/`0163`이 확립한 2가지 패턴에 더해, `called_at`/`call_count`를 `session_events`에서 파생시키는 패턴(§1.6)과 `cancel_reason`을 렛저 전용으로 남기는 패턴(§1.7)을 새로 확정했고, `confirm_arrival()`은 기존에 고아 상태였던 `mark_session_arrived()`(`0025`)에 위임하는 파사드로 재설계하기로 했다(§1.5). `memo`(§1.3, §1.6)는 대체 소스가 없는 유일한 예외로 남아 Logic.md에서 별도 결정이 필요하다. `cancel_waiting()`의 상태 가드/테이블 반납 갭(§1.4)은 이번 워크패킷보다 넓은 시스템 갭으로 판단해 명시적으로 제외했다(§4-1).
