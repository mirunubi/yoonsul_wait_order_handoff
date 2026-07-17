# 600651_Overview_Seat_Waiting_Customer_Facade_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`seat_waiting_customer_facade_correction`

## §0.1 원칙 (문서 전체에 적용, 최우선 명시)

**사용자/스태프가 보고 입력하는 것은 번호(`table_number`, 물리적으로 테이블에 인쇄/부착된 라벨) — 시스템 내부의 모든 참조·바인딩·FK는 예외 없이 `table_id`(UUID)를 기준으로 한다.** `p_table_number`는 이 워크패킷이 신설하는 리졸버(§2)를 통해 **한 번만** `table_id`로 변환되고, 그 이후의 모든 처리(`bind_table_to_session()` 호출, `order_sessions.table_id` 저장, `dining_tables` 갱신)는 오직 `table_id`만 사용한다. 이 원칙은 `601121_Overview_Dining_Table_Crud_Creation.md` §0.2가 이미 확립한 것과 동일하며(`table_code`는 표시용 라벨, `table_id`가 유일한 불변 참조), 이 워크패킷은 그 원칙을 대기열 파이프라인 쪽에서 실제로 지키도록 만드는 작업이다.

## §0.2 배경 — 발견 경위

이 워크패킷은 `601121_Overview_Dining_Table_Crud_Creation.md` §6 (f)에서 "Staff Seating And Table Assignment Orchestration Contract" 후속 워크패킷 후보로 이관된 항목의 첫 번째 조각이다. 그 문서가 이미 확인한 사실(재확인 완료, 아래 §1에서 라인 단위로 재검증): `catchmenu_pos.seat_waiting_customer()`(`sql/migrations/0115_create_waiting_pipeline_rpc.sql:988-1204`)는 존재하지 않는 `order_sessions.table_number` 컬럼에 쓰기를 시도해 호출할 때마다 크래시한다.

## §1 현황 — 라이브 재확인

### §1.1 `seat_waiting_customer()`의 정확한 크래시 지점과 범위 (재확인)

```sql
-- 0115:1048-1057
update catchmenu_pos.order_sessions
set
  session_status = 'SEATED',
  table_number = coalesce(
    p_table_number, table_number
  ),
  seated_at = now(),
  updated_at = now()
where id = p_session_id;
```

`information_schema.columns` 라이브 재조회 결과, `catchmenu_pos.order_sessions`에 `table_number` 컬럼은 **존재하지 않는다**(존재하는 컬럼: `table_id uuid`뿐). 이 UPDATE 문 하나가 이 함수 전체를 크래시시킨다 — `session_status`/`seated_at` 등 나머지 필드가 정상이어도, 하나의 UPDATE 문에 포함된 이상 전체가 원자적으로 실패한다.

### §1.2 `bind_table_to_session()` — 이미 존재하는 canonical core (전체 정독)

`catchmenu_pos.bind_table_to_session(p_tenant_id, p_store_id, p_session_id, p_table_id, p_actor_type default 'STAFF', p_actor_id default null, p_correlation_id default null)`(`sql/migrations/0025_create_session_rpc.sql:327-`, 라이브 `pg_get_functiondef()`로 전체 재확인) 가 실제로 하는 일:

1. 세션 조회 + `FOR UPDATE` 락.
2. **세션 사전조건**: `session_status in ('WAITING', 'ARRIVAL_PENDING', 'ORDERING')`이 아니면 `session_not_bindable` 에러 — 그 외 상태(`SEATED`/`CANCELLED`/`NO_SHOW`/`COMPLETED` 등)는 전부 거부.
3. **이미 바인딩됨 확인**: `session.table_id is not null`이면 `table_already_bound` 에러.
4. **테이블 조회**: `dining_tables where id = p_table_id and store_id = p_store_id and is_active = true` — 없으면 `table_not_found`.
5. **테이블 가용성 확인**: `table_status in ('AVAILABLE', 'RESERVED')`가 아니면 `table_not_available`(현재 `table_status`/`current_session_id`까지 응답에 포함).
6. **바인딩 실행**: `order_sessions.table_id = p_table_id`, `session_status = 'SEATED'`, `seated_at = now()`, `ordering_started_at = now()`.
7. **테이블 점유 처리**: `dining_tables.table_status = 'OCCUPIED'`, `current_session_id = p_session_id`, `occupied_since = now()`.
8. `session_events` INSERT(`table_bound`) + `catchmenu_ledger.events` INSERT(`session`/`table_bound`) + `catchmenu_audit.append_audit_record()`(`OPERATIONAL`, `COMPLETED`) — 3중 기록.
9. 성공 응답: `{success, session_id, session_status:'SEATED', table_id, table_code, seated_at, late_binding_completed, audit_id, message_code:'late_binding_completed'}`.

### §1.3 `seat_waiting_customer()`가 원래 하려던 것과의 정확한 대조

| 항목 | `seat_waiting_customer()`(0115, 크래시 이전 코드 기준) | `bind_table_to_session()` | 결론 |
|---|---|---|---|
| 세션 존재 확인 | O | O | 동일 |
| "이미 SEATED면 거부" | O(`session_status = 'SEATED'`만 검사) | O, 더 엄격함(`WAITING`/`ARRIVAL_PENDING`/`ORDERING` 화이트리스트 — `CANCELLED`/`NO_SHOW`/`COMPLETED` 세션의 착석 시도도 차단) | **개선** — 원래 설계(`900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:203`, `선행: session_status != 'SEATED'`)보다 `bind_table_to_session()`이 더 엄격하고 정확하다. 결함이 아니라 위임을 통한 자연스러운 보강. |
| `session_status = 'SEATED'` 전이 | O | O | 동일 |
| `seated_at` 기록 | O | O(+ `ordering_started_at`도 추가 기록, 원래 없던 필드) | 동등 이상 |
| **테이블 물리 점유 처리**(`dining_tables.table_status='OCCUPIED'` 등) | **없음** — 원본 설계 자체의 공백 | O | **원본에 없던 기능이 위임으로 새로 생김** — 이 워크패킷의 부수적 개선 |
| **테이블 가용성 검증**(활성/AVAILABLE 여부) | **없음** | O | **원본에 없던 검증이 위임으로 새로 생김** |
| 사전 주문 시 KDS HOLD 유지 안내 | O(`log_diagnostic`) | 없음(테이블-세션 바인딩만 담당, 대기열 도메인 지식 없음) | 파사드가 그대로 보존해야 함(§2) |
| 잔여 대기 인원 계산 + Realtime `waiting_session_seated` | O | 없음 | 파사드가 보존 |
| DID `call_dismissed` Realtime | O | 없음 | 파사드가 보존 |
| `ledger.events`(`waiting`/`customer_seated`, `wait_duration_seconds`) | O | 다른 이벤트(`session`/`table_bound`) — 스키마/목적이 다름, 대체 불가 | 파사드가 **별도로** 계속 기록(§2, 의도적으로 두 이벤트 병존) |

**결론(확인 필요 항목 1에 대한 답)**: `bind_table_to_session()`은 원래 `seat_waiting_customer()`가 하려던 **세션·테이블 상태 전이 불변조건을 전부 커버하며, 그중 두 가지(테이블 가용성 검증, 물리 점유 처리)는 원본에 없던 것까지 보강한다.** 빠진 것은 없다 — 다만 대기열 도메인 고유의 부수 효과(사전주문 안내/Realtime/도메인별 렛저 이벤트)는 `bind_table_to_session()`의 책임이 아니므로 파사드가 그대로 유지해야 한다(§2).

### §1.4 리졸버가 참조할 정확한 테이블 (확인 필요 항목 2에 대한 답)

`dining_tables.table_code`가 맞다 — `uq_dining_table_store_code UNIQUE (store_id, table_code)`(`601121_Overview.md` §1.1에서 이미 확인, 이번 턴 라이브 재확인)가 스토어 내 유일성을 보장하는 실제 제약이다. `dining_tables`에 `table_number`라는 별도 컬럼은 없다 — `p_table_number`(대기열 파이프라인 파라미터명, `0115`부터의 기존 명칭)가 가리키는 대상은 `table_code`다.

**"2건 이상 → `table_number_ambiguous`" 규칙이 현재 스키마에서 발생 가능한가**: `uq_dining_table_store_code`가 `(store_id, table_code)` 조합에 **부분 인덱스가 아닌 전체 UNIQUE**이므로, 리졸버가 `store_id`를 정확히 WHERE 절에 포함하는 한 2건 이상은 구조적으로 불가능하다. 그럼에도 이 분기를 유지하는 이유(`601122_Logic.md`가 이미 확립한 "방어적 코드는 가치가 있다" 원칙과 동일선상): 리졸버 쿼리가 실수로 `store_id` 필터를 빠뜨리면(예: 향후 리팩터링 실수) 같은 테넌트의 다른 스토어에 동일한 `table_code`가 존재할 경우(제약이 `store_id` 단위이지 `tenant_id` 단위가 아니므로 이 시나리오는 실제로 가능) 조용히 엉뚱한 스토어의 테이블에 바인딩되는 대신, 즉시 명시적 에러로 드러난다 — 이 분기는 "일어날 수 없는 경우"가 아니라 "리졸버 자신의 쿼리 정확성을 지키는 회귀 가드"다.

## §2 확정된 설계 방향 (재논의 금지 대상 그대로 반영)

1. **`bind_table_to_session()`은 canonical core로 유지, 수정하지 않는다** — §1.3이 이미 확인했듯 필요한 불변조건을 전부(그 이상까지) 충족한다.
2. **`seat_waiting_customer()`를 얇은 파사드로 재작성** — `p_table_number` → `p_table_id` 리졸버(신설, §1.4/Logic §1) + `bind_table_to_session()` 호출 위임 + 대기열 도메인 고유 부수효과(§1.3 표의 마지막 4행) 보존.
3. **리졸버 규칙**: 정확히 1건(그리고 활성) → `table_id` 반환, 0건 → `waiting_table_not_found`, 2건 이상 → `waiting_table_number_ambiguous`(§1.4의 방어적 근거), 비활성(존재하지만 `is_active=false`) → `waiting_table_inactive`. 에러 키에 `waiting_` 접두어를 붙인 이유는 §6 (a) 참고(기존 `table_not_found` 등과의 충돌 회피).
4. **원칙 문구**(§0.1) 서두 명시 완료.
5. **`pre_order_amount` phantom 제거** — `catchmenu_pos.call_waiting_customer()`(`0160` 복구본, 라이브 재확인)가 이미 쓰는 패턴을 그대로 재사용 가능함을 확인했다:
   ```sql
   -- 0160 복구본, 라이브 확인
   select os.id, ..., os.pre_order_created_at, os.order_id,
          o.final_amount as pre_order_amount
   into v_session
   from catchmenu_pos.order_sessions os
   left join catchmenu_pos.orders o on o.id = os.order_id
   where os.id = p_session_id ...
   ```
   `order_sessions.order_id`(uuid)와 `order_sessions.pre_order_created_at`(timestamptz)은 둘 다 라이브에 실존하는 컬럼이다(재확인). `pre_order_amount`라는 컬럼은 없고, 실제 금액은 `orders.final_amount`를 `order_id`로 LEFT JOIN해 가져온다. `has_pre_order` 판정은 `pre_order_created_at is not null`을 쓴다(`0160`과 동일 관례). 이 패턴을 파사드에 그대로 재사용한다 — 새로 설계할 필요 없이 이미 검증된 패턴을 재사용하는 것이 목표에 정확히 부합한다.
6. **형제 함수 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`) 범위 제외, Open Item으로 이월** — §4/§6 (b).

## §3 라이브 재확인 (설계 방향 5의 근거 자료)

이번 턴 `information_schema.columns` 직접 재조회:

| 컬럼 | 존재 여부 |
|---|---|
| `order_sessions.table_id` | 존재(uuid) |
| `order_sessions.table_number` | **없음** |
| `order_sessions.order_id` | 존재(uuid) |
| `order_sessions.pre_order_created_at` | 존재(timestamptz) |
| `order_sessions.pre_order_amount` | **없음** |
| `order_sessions.called_at` / `call_count` / `arrival_confirmed_at` / `no_show_at` / `cancel_reason` | **없음**(전부, §4 형제 함수 4개가 참조하는 phantom들) |

## §4 범위 밖 확인

### §4.1 형제 함수 4개 — 지시된 범위 제외, Open Item으로 이월 (§6 (b))

`confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` 네 함수의 라이브 본문을 이번 턴 직접 대조했다 — 넷 다 여전히 `table_number`/`pre_order_amount`/`called_at`/`call_count`/`arrival_confirmed_at`/`cancel_reason` 중 하나 이상을 참조하며 크래시 상태다(§3 표). 이번 워크패킷은 손대지 않는다.

### §4.2 **[신규 발견, 지시문의 "형제 함수 4개" 목록에 없던 다섯 번째 후보]** `pre_order_while_waiting()`

지시문은 정확히 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`)를 형제 함수로 지목했으나, 이번 턴 `0115` 전체를 직접 재검토한 결과 **`catchmenu_pos.pre_order_while_waiting()`(`0115:602-869`)도 동일 클래스의 phantom 참조를 갖고 있다**:

```sql
-- 라이브 재확인, 여전히 존재하는 코드
update catchmenu_pos.order_sessions
set
  session_type = 'PRE_ORDER',
  pre_order_amount = v_total_amount,
  updated_at = now()
where id = p_session_id;
```

**다만 이 함수가 실제로 "죽은 코드"일 가능성이 있다** — `sql/migrations/0051_create_pre_order_rpc.sql`이 별도로 `catchmenu_pos.create_pre_order()`를 정의하며, 그 함수가 `order_sessions.order_id`/`pre_order_created_at`을 **정확히** 채운다(`0051:311-312`, 라이브 확인). 즉 `call_waiting_customer()`(§2 항목 5)가 실제로 읽는 사전주문 데이터의 진짜 생산자는 `pre_order_while_waiting()`이 아니라 `create_pre_order()`로 보인다 — `pre_order_while_waiting()`이 여전히 호출되는 활성 경로인지, 아니면 `0051`로 대체된 뒤 방치된 죽은 함수인지는 이번 턴에 확인하지 않았다. 어느 쪽이든 크래시 상태인 것은 사실이므로, 이 워크패킷의 범위에는 포함하지 않고 **형제 함수 4개와 별도로, 우선순위 판단이 필요한 다섯 번째 후보**로 Open Item에 추가한다(§6 (c)) — Cursor의 전수조사가 이 함수를 놓친 것인지, 의도적으로 죽은 코드로 판단해 제외한 것인지 확인이 필요하다.

### §4.3 `did_display_queue` 테이블 — 설계 문서에만 있고 구현된 적 없음

`900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:214`("`did_display_queue UPDATE: DISMISSED`")를 참고했으나, 라이브 스키마에 `did_display_queue`라는 테이블 자체가 존재하지 않는다(`information_schema.tables` 확인, 0 rows). 이것은 원본 `seat_waiting_customer()`에도 없던 기능이므로 이 워크패킷이 새로 만들 필요는 없다 — 설계 문서와 구현 사이의 기존 공백을 그대로 기록만 한다(§6 (d)).

### §4.4 기타 범위 밖

- `mark_no_show()` — 이번 턴 확인 결과 phantom 참조가 **없다**(라이브 grep 0건). `600630_mark_no_show_overload_and_redesign` 워크패킷에서 이미 재설계·복구된 것으로 보인다(시그니처는 `0115`와 동일하나 본문이 다름). 이 워크패킷과 무관.
- `register_waiting()` — phantom 참조 없음(라이브 grep 0건), 애초에 문제없는 함수.
- `catchmenu_pos.orders`/`catchmenu_kds.kds_tickets` 스키마 자체 — 변경하지 않음, 읽기만.
- `catchmenu_store.dining_tables`/`bind_table_to_session()` 본문 — 수정하지 않음(§2 항목 1).

## §5 영향 범위 요약

- **결함 클래스**: phantom 컬럼(`table_number`) 참조로 인한 확정적 크래시 — `601140`/`601110`이 다뤄온 것과 동일한 결함 클래스이나, 이번엔 "값을 보존/기본값 처리"가 아니라 "존재 자체가 다른 곳(`table_id`)으로 이미 이관된 개념을 재정렬"하는 문제라 파사드+리졸버 패턴이 필요하다.
- **실호출자**: 0건 — `catchmenu_app/lib/` 전체 재검색(이번 턴), 실제 Dart 코드에서 `seat_waiting_customer`/`bind_table_to_session`을 호출하는 곳 없음(`catchmenu_app/lib/features/waiting/README.md`가 "관련 RPC"로 문서에만 언급).
- **위험**: 리졸버가 `store_id`를 빠뜨리면 크로스-스토어 오탐이 가능(§1.4) — Logic 단계에서 정확한 WHERE 절 명시로 방지.
- **의존 관계**: `bind_table_to_session()`(읽기 전용 의존, 수정 없음), `catchmenu_pos.orders`(읽기 전용, LEFT JOIN), `catchmenu_store.dining_tables`(읽기 전용, 리졸버가 조회만).

## §6 Open Items

(a) 신규 에러 키(`waiting_table_not_found`/`waiting_table_number_ambiguous`/`waiting_table_inactive`)에 `waiting_` 접두어를 붙인 이유: `601122_Logic_Dining_Table_Crud_Creation.md` §5가 이미 `'table_not_found'`를 `STORE` 도메인 코드로 등록했다 — `catchmenu_common.build_error_response()`는 `error_key`만으로 `error_codes`를 조회하므로(`error_domain` 필터 없음), 같은 키를 다른 도메인에 재등록하면 조회가 두 행 중 어느 것을 반환할지 불확실해지는 실질적 충돌이 생긴다. 접두어로 회피했다 — Human이 이 판단을 재검토할 수 있도록 남긴다.
(b) **[이관, `601121_Overview.md` §6 (f)와 동일 근거]** 형제 함수 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`) — 전부 여전히 크래시 상태(§4.1), 별도 후속 워크패킷 필요. 이 문서는 조사만 하고 수정하지 않는다.
(c) **[신규 발견, §4.2]** `pre_order_while_waiting()`도 동일 클래스 phantom(`pre_order_amount`)을 갖고 있으나 지시문의 "형제 함수 4개" 목록에 없었다 — 죽은 코드인지(`0051.create_pre_order()`로 대체됨) 실제 사용 경로인지 확인 필요. 형제 함수 4개와 함께든, 별도로든 후속 워크패킷 후보.
(d) `did_display_queue` 테이블 자체가 구현된 적이 없다(§4.3) — `900101` 설계 문서와 실제 구현 사이의 기존 공백, 이 워크패킷이 새로 만들지 않는다.
(e) 리졸버가 `p_table_number`를 대소문자/공백 등을 정규화(trim, 대소문자 무시)하지 않고 정확히 일치(`table_code = p_table_number`)만 본다 — 정규화가 필요한지는 실제 스태프 입력 UX(Flutter 클라이언트 미착수)에 달려 있어 이 워크패킷 범위 밖으로 둔다. 정규화를 도입하면 §1.4가 분석한 "2건 이상" 시나리오가 현실적으로 발생 가능해지므로(예: `'A1'`과 `'a1'`이 둘 다 존재), 그때는 `waiting_table_number_ambiguous` 분기가 실제로 도달 가능해진다.
(f) `p_table_number`가 생략되면(`NULL`) 이 워크패킷의 파사드는 `waiting_table_number_required` 에러로 거부한다(Logic §2) — `bind_table_to_session()`이 `p_table_id`를 필수 파라미터로 요구하고, `order_sessions.table_id`가 착석 시점 이전엔 항상 `NULL`이라 "생략 시 기존 값 유지"라는 원본의 `coalesce` 개념 자체가 성립하지 않기 때문이다. 이 동작 변화(원본은 생략을 허용했으나 어차피 크래시했으므로 실질적 동작 차이는 없음)를 Human이 인지해야 한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601121_Overview_Dining_Table_Crud_Creation.md` §6 (f) — 이 워크패킷의 직접 출발점.
- `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` — 동일 파일(`0115`)의 동일 결함 클래스를 먼저 다룬 선례, 조사/정정 관례의 직접 템플릿.

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:988-1204`(`seat_waiting_customer()`, 대상) 전체, 그리고 나머지 8개 함수(§4.1/§4.2/§4.4의 근거).
- `sql/migrations/0025_create_session_rpc.sql`(`bind_table_to_session()`, canonical core) — 라이브 `pg_get_functiondef()`로 전체 재확인.
- `sql/migrations/0160_call_waiting_customer_contract_recovery.sql`(재사용할 `orders` LEFT JOIN 패턴의 원본).
- `sql/migrations/0051_create_pre_order_rpc.sql:311-312`(`create_pre_order()`의 `order_id`/`pre_order_created_at` 실제 생산 지점, §4.2 근거).
- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:202-217`(원본 설계 의도, §1.3 대조표의 비교 대상).

### Domain Indexes

- `600600_Readme_Waiting_Order_Session.md`(이 워크패킷의 번호 등록처 — 이번 문서 자체는 Subfolder Map 갱신을 포함하지 않음).
- `600602_NavigationMap_Waiting_Order_Session.md`(동일).

### Excluded Rule Families

- 형제 함수 4개 + `pre_order_while_waiting()` — §4.1/§4.2에서 명시적으로 제외, Open Item (b)/(c)로 이관.
- `mark_no_show()`/`register_waiting()` — §4.4, 문제없음 확인, 손대지 않음.
- `did_display_queue` — §4.3, 구현된 적 없는 별개 공백.
- `601100_store_admin_console/`의 모든 워크패킷 — 완전히 다른 도메인, `table_code`/`table_id` 원칙(§0.1)만 교차 참조.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Logic 단계(`600652_Logic.md`)로 진행 가능.** §1에서 크래시 지점(§1.1), `bind_table_to_session()`의 전체 커버리지(§1.2/§1.3 대조표 — 원본이 갖지 못했던 테이블 가용성 검증/물리 점유 처리까지 보강됨을 확인), 리졸버 대상(`table_code`, §1.4)을 전부 라이브 재확인했다. 확정된 설계 방향 6개 항목 전부에 근거를 붙여 반영했다(§2) — 특히 `pre_order_amount` 제거는 `0160`이 이미 쓰는 검증된 패턴의 재사용임을 확인했다(§2 항목 5/§3). 형제 함수 4개는 여전히 크래시 상태임을 재확인해 Open Item으로 이관했고(§4.1), 지시문에 없던 다섯 번째 후보(`pre_order_while_waiting()`)를 새로 발견해 별도로 기록했다(§4.2) — 죽은 코드일 가능성이 있다는 단서까지 포함해서. `.sql` 파일은 생성·수정하지 않았다.
