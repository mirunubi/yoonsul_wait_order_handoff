# 600641_Overview_Call_Waiting_Customer_Contract_Recovery.md

Status: Draft
Lifecycle: Overview
Stage: 1.5
Domain: Waiting / Order Session
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 이 워크패킷의 위치 — 왜 신설됐는가

`600630_mark_no_show_overload_and_redesign`의 `600632_Logic.md`를 작성하던 중, `mark_no_show()`의 진짜 선행조건인 `catchmenu_pos.call_waiting_customer()`(`sql/migrations/0115_create_waiting_pipeline_rpc.sql:419-599`)가 실행 시점에 크래시하는 함수임을 확인했다(`600632_Logic.md` 상단 BLOCKED 섹션). Human 결정(ChatGPT+제미나이 교차검증, 옵션 C)에 따라 이 함수의 phantom 컬럼을 "그냥 스키마에 추가"하는 방식은 금지하고, 각 값의 source of truth를 먼저 조사·결정하는 별도 선행 워크패킷으로 이 문서를 신설했다. `600630`은 이 워크패킷의 검증(생산자 복구 PASS) 완료 후 재개한다.

## §1 결함의 정확한 현재 위치 (재확인)

`call_waiting_customer(p_tenant_id, p_store_id, p_session_id, p_table_number default null, p_actor_id default null, p_locale default 'ko', p_correlation_id default null)` — `0115:419-599`.

크래시 지점, `0115:483-493`:
```sql
-- 호출 상태로 변경
update catchmenu_pos.order_sessions
set
  session_status = 'ARRIVAL_PENDING',
  called_at = now(),
  table_number = coalesce(
    p_table_number, table_number
  ),
  call_count = coalesce(call_count, 0) + 1,
  updated_at = now()
where id = p_session_id;
```
`called_at`/`table_number`/`call_count` 3개 모두 라이브 `catchmenu_pos.order_sessions`에 존재하지 않음(재확인, `information_schema.columns` 0 rows). `pre_order_amount`도 앞의 SELECT(`0115:446-449`)와 뒤의 ledger insert/응답(`0115:570-571, 584-587`)에서 참조되나 마찬가지로 phantom.

## §2 (1) `called_at` 조사 결과

**재호출은 설계상 의도된 시나리오다** — `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:291` 상태-액션 매트릭스: `| ARRIVAL_PENDING | ✗ | ✓ 재호출 | ✓ | ✓ | ✓ | ✓ | ✓ |` — 이미 `ARRIVAL_PENDING`인 세션에도 "call" 액션이 "재호출"로 명시 허용된다. `call_count += 1` 서술(`900101...md:183-189`)도 단발성 플래그가 아닌 누적 카운터를 의도한다.

**"최초 호출" vs "최근 호출" 구분은 900xxx 어디에도 없다** — 오직 단일 `called_at` 개념만 쓰이고, 15분 노쇼 타임아웃 조건(`900101...md:261-264`: `session_status='ARRIVAL_PENDING' AND called_at < now() - interval '15 minutes'`)의 기준으로만 쓰인다. 재호출 시 이 타이머가 리셋되어야 하는지는 900xxx 문서 32개 전체에서 논의되지 않은 공백이다(발견, 결정 아님).

**이미 존재하는 정확한 작동 선례 발견 — `0050.call_next_waiting()`**(`0050:151-305`, "call_waiting_customer"와는 다른 이름의 별개 함수, §7 참조). 이 함수는 동일한 "대기 고객 호출" 작업을 phantom 컬럼 없이 정확히 구현하고 있다:
```sql
-- 0050:244-262
insert into catchmenu_pos.session_events (
  tenant_id, store_id, session_id,
  event_type, from_status, to_status,
  caused_by_type, caused_by_id,
  event_payload, correlation_id, occurred_at
) values (
  p_tenant_id, p_store_id, v_session.id,
  'customer_called',
  'WAITING', 'ARRIVAL_PENDING',
  p_actor_type, p_actor_id,
  jsonb_build_object(
    'wait_number', v_session.wait_number,
    'expires_at', v_expire_at,
    'has_pre_order',
      v_session.pre_order_created_at is not null
  ),
  p_correlation_id, now()
);
```
`'customer_called'`는 `session_events`의 CHECK 제약(`chk_session_event_type`) 허용 목록에 실존하는 값이다(라이브 재확인):
```
CHECK (event_type = ANY (ARRAY['session_created','wait_number_assigned','customer_called',
'customer_arrived','table_bound','pre_order_created','pre_order_expired','ordering_started',
'order_confirmed','payment_requested','payment_confirmed','payment_failed','payment_uncertain',
'payment_recovered','session_completed','session_cancelled','session_expired','no_show_marked',
'manual_override','session_reopened']))
```
`order_sessions`에는 `called_at` 대신 `expires_at`(실존 컬럼)을 세팅하는 방식으로 15분 타이머를 표현한다(`0050:237-242`). **`0115`가 처음부터 만들지 말았어야 할 phantom 컬럼을, `0050`은 이미 정확한 방식(이벤트 원장 + 실존 `expires_at`)으로 표현하고 있었다는 뜻이다.**

**옵션(Human 결정 필요, 이 문서는 판단하지 않음)**:
| 옵션 | 내용 |
|---|---|
| A. 이벤트 원장만 | `session_events`에 `'customer_called'` insert(위 패턴 그대로), "언제 호출됐는지"는 `select min/max(occurred_at) where session_id=... and event_type='customer_called'`로 파생. `order_sessions`에 컬럼 추가 없음. |
| B. 캐시 컬럼 병행 | A + `order_sessions.last_called_at`(경량 캐시, 조회 성능용)도 같은 트랜잭션에서 갱신. 이중 저장이지만 `0118` cron 같은 핫패스 쿼리가 조인/서브쿼리 없이 필터링 가능. |

## §3 (2) `call_count` 조사 결과

`0115`의 `coalesce(call_count, 0) + 1`은 **UPDATE의 SET 표현식이 테이블의 현재(락 걸린) 행 값을 직접 참조하므로, 앞선 `for update`(`0115:455`)와 결합하면 이미 원자적이다** — 별도의 원자적 증가 메커니즘을 새로 설계할 필요는 없다(동시 호출 lost update는 행 잠금으로 이미 방지됨). 문제는 원자성이 아니라 `call_count` 컬럼 자체가 라이브에 없다는 것.

`0050.call_next_waiting()`은 애초에 `call_count`라는 개념 자체를 쓰지 않는다 — 호출 횟수가 필요하면 `session_events`에서 `count(*) where session_id=... and event_type='customer_called'`로 완전히 파생 가능하다(중복 저장 회피).

**옵션(Human 결정 필요)**: §2와 동일한 구도 — A) `session_events` COUNT로 파생, B) `order_sessions.call_count int not null default 0`을 캐시 컬럼으로 병행(원자적 증가는 이미 안전한 패턴이므로 그대로 재사용 가능).

## §4 (3) `table_number` 조사 결과

`order_sessions.table_id`(uuid)는 이미 존재하며 `catchmenu_store.dining_tables.id`를 FK로 참조한다(라이브 재확인):
```
order_sessions_table_id_fkey | table_id → catchmenu_store.dining_tables(id)
```
`dining_tables`는 `table_code`(text, not null)/`table_name`/`did_device_id`/`current_session_id` 등 20개 컬럼을 갖는 실제 테이블 마스터다(라이브 재확인). 이미 확립된 조인 패턴(`0025:388-394`, `0048:239-246`)은 표시용 식별자로 `table_code`를 쓴다 — `table_number`라는 이름의 텍스트 컬럼은 이 코드베이스 어디에도(900xxx 포함) `table_id`와 별개 개념으로 정의된 적이 없다.

`900101_Logic...md:189`는 `call_waiting_customer()` 처리에 "table_number 배정 (**선택**)"이라 적고, 같은 문서 `:207`은 `seat_waiting_customer()`에서 "table_number **최종** 배정"이라 적는다 — 즉 900xxx 자체가 "호출 시점 = 선택적 제안, 착석 시점 = 확정"이라는 이분법을 이미 전제하고 있다. 착석 시점의 "확정"은 이미 정상 작동하는 패턴으로 구현돼 있다(`0025:433-453`, `session_events` `'table_bound'` 이벤트에 실제 `table_id`/`table_code` 기록).

호출 시점 쪽은 DID 로직 문서에서 다른 용어를 쓴다 — `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md:112`: `content: {wait_number, table_suggestion}`. **`table_number`가 아니라 `table_suggestion`** — DID 알림 payload 안에만 존재하는 값으로 읽히며, `order_sessions`에 영구 저장해야 한다는 근거가 900xxx 어디에도 없다. TestPlan도 이를 뒷받침한다 — TC-004(호출, `906000...md`)는 "DID가 호출 번호를 표시"/"직원 앱이 호출 상태 표시"만 요구하고, `table_number` 바인딩은 TC-005(착석)에서만 "And `table_number` is bound"로 등장한다.

**"추가 보류"가 유력하다는 원래 가설의 근거가 확인됐다**: `p_table_number` 파라미터는 계속 받되(스태프가 호출 시 "이 테이블로 오세요" 안내를 위해 필요할 수 있음), `notify_channel()` 페이로드(이미 존재하는 코드, `0115:501-531`)에만 전달하고 `order_sessions`에는 영구 저장하지 않는 방향이 900xxx와 라이브 스키마 둘 다와 정합적이다. 다만 이 결정은 이 문서가 최종 확정하지 않는다(Human 결정, §9).

## §5 (4) `pre_order_amount` 조사 결과

`mark_no_show()`와 다르다 — `call_waiting_customer()`는 **불리언뿐 아니라 실제 숫자값을 응답 payload에 그대로 반환**한다:
```sql
-- 0115:583-588
'has_pre_order',
  v_session.pre_order_amount > 0,
'pre_order_amount',
  v_session.pre_order_amount,
```
`pre_order_created_at is not null`로는 불리언(`has_pre_order`)만 대체 가능하고, `pre_order_amount` 자체(스태프가 호출 화면에서 사전주문 금액을 확인하려는 용도로 추정)는 대체되지 않는다. 실제 금액은 `orders.total_amount`/`orders.final_amount`에 존재한다(재확인, `0051_create_pre_order_rpc.sql:300-301`에서 `create_pre_order()`가 설정):
```sql
-- 0051:298-304
update catchmenu_pos.orders
set
  ...
  total_amount = v_total_amount,
  final_amount = v_total_amount,
  ...
```
`call_next_waiting()`(`0050`)은 실제 금액을 아예 응답하지 않고 `has_pre_order` 불리언만 반환한다(`0050:298-299`) — 즉 이 코드베이스에 "호출 시 실제 금액까지 보여주는" 선례는 없다. `call_waiting_customer()`가 실제 금액을 반환하는 것이 진짜 필요(스태프 UX 요구사항)인지, 아니면 `0115` 작성 시점의 과잉 설계인지는 900xxx TestPlan(`906000...md`/`900103...md`)의 픽스처(`pre_order_amount: 18000` 등)에 등장하나 TC-004(호출) 자체의 검증 조건으로 명시되지는 않는다 — 판단 근거가 확정적이지 않다.

**대체 방법(스키마 변경 불필요)**: 필요하다면 `orders o on o.id = v_session.order_id` 조인으로 `o.final_amount`를 읽으면 된다 — `order_sessions.order_id`는 이미 실존 컬럼이고 `create_pre_order()`가 이미 채운다.

## §6 900xxx 서술 + 실제/예정 호출자

**RPC 권한**: `900101_Logic...md:407` — `| call_waiting_customer | OWNER, MANAGER, STAFF | 직원만 |` (staff-only). `900150_Logic_Phase_Validation_Plan_Catch_Menu_To_Yoonsul_Embedded.md:169` — "1. 직원 앱 → call_waiting_customer() 호출".

**실제 호출자: 0건, 예정 호출자만 존재.** `catchmenu_app/lib/features/staff/README.md` 전문 확인:
```
# features/staff — 직원 앱 (Scope B)
900102 ChangeContract 의 waiting_admin Scope 에 해당. Scope D 통과 후 구현.
...
## 예정 파일
- waiting_admin_screen.dart
- waiting_list_tile.dart
- waiting_admin_state_notifier.dart
- waiting_admin_repository.dart
## 허용 동작
- 대기 목록 관리, 호출, 도착 확인, 착석/테이블 배정, 노쇼/호출만료 처리
```
디렉터리 확인 결과 `catchmenu_app/lib/features/staff/`에는 `README.md`만 존재 — `.dart` 파일 0개, "Scope D 통과 후" 구현 예정으로 게이트됨. DID 앱 디렉터리 자체가 리포에 없다. `call_waiting_customer` 문자열이 실제로 등장하는 곳은 이 README(관련 RPC로 언급)뿐, SQL 마이그레이션 외 어디에도 호출 코드가 없다 — `600632_Logic.md`가 이미 확인한 "0건" 결론과 일치.

## §7 구조적 발견 — `call_next_waiting()`과 `call_waiting_customer()`의 중복

이번 조사로 발견된, 원래 지시문에 없던 사실: `0050.call_next_waiting()`(`0050:151-305`)과 `0115.call_waiting_customer()`(`0115:419-599`)는 **이름이 다른 별개 함수**이며(따라서 `mark_no_show()`처럼 Postgres 오버로드 충돌은 아니다), 둘 다 "대기 고객을 호출해 `WAITING`→`ARRIVAL_PENDING` 전환"이라는 같은 목적을 수행하는 중복 구현이다. 기능은 서로의 부분집합이 아니다:

| | `call_next_waiting()` (0050) | `call_waiting_customer()` (0115) |
|---|---|---|
| 컬럼 정합성 | 전부 실존 컬럼 — 정상 작동 | phantom 4종 — 크래시 |
| 대상 선택 | 특정 세션 또는 "큐의 다음 자동 선택"(`p_specific_session_id` 옵션) | 특정 세션만(`p_session_id` 필수) |
| 알림(DID/푸시) | 없음 | `notify_channel()` 3종(WAITING_QUEUE/DID_DISPLAY/SYSTEM_EVENTS) |
| 테이블 제안 | 없음 | `p_table_number` 파라미터 존재 |
| 이벤트 기록 | `session_events` + `catchmenu_ledger.events` 둘 다 | `catchmenu_ledger.events`만(`session_events` insert 없음, `0115` 전체에서 0건) |
| 만료 처리 | `expires_at`(실존) 세팅, `store_settings.no_show_auto_expire_minutes` 사용 | 없음(만료는 별도로 `0118` cron이 `called_at` 기준으로 처리하려 하나 그 자체도 phantom) |

어느 한쪽이 다른 쪽을 완전히 대체할 수 없다 — `0050` 버전은 데이터는 맞지만 알림/테이블 제안 기능이 없고, `0115` 버전은 기능은 맞지만 데이터가 깨져 있다. **이 문서는 병합/폐기/역할 분리 중 어느 방향이 맞는지 판단하지 않는다** — Logic 단계의 Human 결정 사항으로 이월한다(§9).

## §8 부가 발견 — `store_settings`의 이름 불일치

`store_settings`에 만료 관련 컬럼이 2개 존재한다(라이브 재확인): `no_show_auto_expire_minutes`, `wait_call_expire_minutes`. `call_next_waiting()`은 `no_show_auto_expire_minutes`만 사용하고(`0050:222-230`), 이름상 이 시나리오에 더 정확히 맞아 보이는 `wait_call_expire_minutes`는 SQL 전체에서 참조하는 함수가 없다(미사용 컬럼으로 추정, 이번 조사에서 사용처 확인 안 됨). 어느 쪽이 "호출 후 노쇼 타임아웃"의 진짜 설정값인지 Open Item으로 이월한다.

## §9 이 워크패킷의 제안 범위 (Logic 단계에서 확정, 이 문서는 판단하지 않음)

- §2/§3(called_at/call_count)의 옵션 A/B 중 선택.
- §4(table_number) 영구 저장 보류 여부 확정.
- §5(pre_order_amount)의 orders 조인 대체 채택 여부.
- §7(구조적 중복) 처리 방향 — 최소 범위로는 "`call_waiting_customer()`의 데이터 계층만 고치고 `call_next_waiting()`은 그대로 둔다"가 가장 좁지만, 두 함수가 계속 공존/분기하는 것이 맞는지는 별도 판단 필요.
- §8(`wait_call_expire_minutes` 미사용) 처리 여부 — 이번 워크패킷 범위인지 별도 이월인지.
- 이 워크패킷의 산출물이 정확히 무엇인지(예: `call_waiting_customer()`를 `0115`에 새 버전으로 재정의할지, 별도 마이그레이션 파일로 분리할지)도 Logic 단계 결정 사항.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600632_Logic_Mark_No_Show_Overload_And_Redesign.md`(BLOCKED 섹션) — 이 워크패킷을 신설하게 만든 직접 원인.
- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` — 설계 권한 문서, §2-§6 인용 근거.

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:419-599` — 수정 대상 `call_waiting_customer()`.
- `sql/migrations/0050_create_waiting_queue_rpc.sql:151-305` — 정상 작동 선례 `call_next_waiting()`, §7의 중복 비교 대상.
- `sql/migrations/0012_create_pos_order_sessions.sql:221-243` — `session_events` `event_type` CHECK 허용 목록.
- `sql/migrations/0025_create_session_rpc.sql:388-453` — `dining_tables` 조인 및 `table_bound` 이벤트 선례.
- `sql/migrations/0051_create_pre_order_rpc.sql:298-304` — `orders.total_amount`/`final_amount` 실제 소스.
- `900101_Logic...md:180-217, 261-264, 291, 407` — 호출/재호출/table_number/권한 서술.
- `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md:112` — `table_suggestion` DID payload 용어.
- `900103_TestPlan...md` / `906000_TestPlan...md` TC-004/TC-005 — 호출/착석 시점의 검증 조건 구분.
- 라이브 스키마: `catchmenu_pos.order_sessions`/`session_events`, `catchmenu_store.dining_tables`/`store_settings` (본 문서에서 재확인한 컬럼/제약 전체).

### Domain Indexes

- `600602_NavigationMap_Waiting_Order_Session.md`.
- `docs/000053_Matrix_Domain_To_Artifact_Traceability.md:51` — 이 결함을 "미해결"로 이미 등재한 기존 추적 항목.

### Excluded Rule Families

- `0118`의 `WAITING_SESSION_EXPIRE` cron 자체의 수정(§8) — `600630`/`600632` 범위, 이 워크패킷은 생산자 계약만 다룬다.
- `confirm_arrival()`의 phantom 컬럼(`600631_Overview.md` §4) — 범위 밖.
- Flutter/Staff 앱 실제 구현 — Scope D 게이트 이후, 이 워크패킷은 SQL 레이어만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Logic 단계로 진행 가능 — 단 다수 항목이 Human 결정 대기.** 4가지 조사 사항 전부에 실증적 근거를 확보했다: (1) `called_at`은 이미 정상 작동하는 `session_events`(`'customer_called'`) + `call_next_waiting()`의 `expires_at` 패턴으로 대체 가능(옵션 A/B); (2) `call_count`는 `for update` 락 하에서 이미 원자적이며, 컬럼 자체를 `session_events` COUNT로 파생할 수도 있음(옵션 A/B); (3) `table_number`는 900xxx 자체가 "호출 시 선택적, 착석 시 확정"으로 구분하고 DID 로직 문서는 아예 다른 용어(`table_suggestion`)를 쓰며 TestPlan도 호출 시점 검증에 테이블 바인딩을 요구하지 않아 "영구 저장 보류"가 유력하다는 원래 가설이 뒷받침됨; (4) `pre_order_amount`는 `mark_no_show()`와 달리 실제 숫자 반환이 필요해 보이며 `orders.final_amount` 조인으로 스키마 변경 없이 대체 가능. 예상치 못한 구조적 발견(§7) — `call_next_waiting()`(0050)과 `call_waiting_customer()`(0115)가 서로의 부분집합이 아닌 중복 함수라는 점 — 을 Open Item으로 명시했다. `.sql` 파일은 생성·수정하지 않았다. 다음 단계(`600642_Logic.md`)에서 §9의 각 항목에 대한 Human 결정을 받아 캐노니컬 설계를 확정해야 한다.
