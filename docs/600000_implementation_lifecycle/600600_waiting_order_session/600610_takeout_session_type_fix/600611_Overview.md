# 600611_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`takeout_session_type_fix`

## §0 배경 (오늘 이미 확정된 조사 결과, 재확인 불필요로 전제 — 원문은 이번 턴 재확인)

`place_takeout_order()`(`0081`)가 `catchmenu_pos.order_sessions` INSERT 시 `session_type = 'ONLINE'`을 쓰는데, 실제 `chk_session_type` 허용값은 `WALK_IN`/`WAITING`/`PRE_ORDER`/`KIOSK`/`TAKEOUT`/`DELIVERY`뿐(`0012` 정의)이다. `'ONLINE'`은 어디에도 허용되지 않아 모든 포장 주문이 이 지점에서 100% 실패한다. `register_waiting()`(`0115`)은 `'WAITING'`을, delivery intake는 `'DELIVERY'`를 정상 사용 — `place_takeout_order()`만 유일하게 어긋난다. `'TAKEOUT'`이 유력 후보(이미 허용값, 같은 함수의 `order_type = 'TAKEOUT'`과도 의미상 일치).

## §1 L826 정확한 위치와 INSERT 문 전체 (이번 턴 원문 재확인)

```sql
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    guest_count, guest_locale,
    session_started_at,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'ONLINE', 'ORDER_CONFIRMED',
    1, p_locale,
    now(),
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_session_id;
```

`'ONLINE'`은 L826에 정확히 위치(`'ONLINE', 'ORDER_CONFIRMED',` 라인). `session_status`는 `'ORDER_CONFIRMED'`로 함께 세팅되며, 이는 `chk_session_type`과 별개의 제약(`session_status` 자체의 허용값)이므로 이번 수정 범위와 무관하다 — `session_type`만 문제다.

`chk_session_type` 라이브 정의(이번 턴 재확인): `CHECK ((session_type = ANY (ARRAY['WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'TAKEOUT', 'DELIVERY'])))` — `0012_create_pos_order_sessions.sql`에서 정의된 이후 다른 어떤 마이그레이션도 이 제약을 `ALTER`한 적이 없음(전수 재확인, `0097`이 같은 이름의 제약을 갖고 있으나 이는 완전히 다른 테이블 — 로그인/인증 세션 테이블 — 의 동명 제약일 뿐임을 재확인).

## §2 `0063`의 "RPC validation ↔ 테이블 constraint 드리프트" — 이번 workpacket에서 함께 수정 확정

**Human 결정 (2026-07-13, 재논의 금지)**: `0063_patch_core_rpc_i18n_diagnostics.sql`의 `create_order_session()` 두 번째 오버로드 드리프트를 이번 workpacket에서 함께 고친다(이월하지 않음). 근거: "같은 증상, 같은 근본 원인이므로 조사 비용 재사용"이라는 반대 논거를 채택 — 이는 이전 초안(`600612_Logic.md` 초판)의 "이월 권고"를 대체한다.

**투명 공개 — 작업 지시의 파일 번호 참조 정정**: 지시문은 "`0063_create_order_session()`"이라 표현했으나, `catchmenu_pos.create_order_session()`이라는 함수는 실제로 **두 개의 파일에 걸쳐 두 개의 서로 다른 오버로드**로 존재한다 — 함수 이름 자체는 맞으나 파일명은 `0063_patch_core_rpc_i18n_diagnostics.sql`이다(`0063_create_order_session.sql`이라는 파일은 없음).

이번 턴 라이브 재확인 결과 `create_order_session`은 실제로 **2개 오버로드**가 공존한다:

| 오버로드 (파라미터로 식별) | 정의 파일 | `p_session_type` 검증 목록 | 테이블 제약과 일치? |
|---|---|---|---|
| `..., p_wait_number, p_table_id, p_expires_minutes, ...` | `0025_create_session_rpc.sql` | `'WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'TAKEOUT', 'DELIVERY'` | **일치** — `chk_session_type`과 정확히 동일. `when 'TAKEOUT' then 'ORDERING'` 같은 상태 매핑도 이미 존재. |
| `..., p_wait_number, p_queue_position, p_pre_order_expires_at, ...` | `0063_patch_core_rpc_i18n_diagnostics.sql` | `'WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'DELIVERY', 'ONLINE'` | **불일치** — `'TAKEOUT'`이 빠지고 `'ONLINE'`이 대신 들어가 있다. 이 오버로드도 `p_session_type`을 그대로 `insert`에 전달(L142)하므로, `'ONLINE'`으로 호출하면 이 오버로드도 `chk_session_type` 위반으로 크래시한다 — `place_takeout_order()`와 **같은 증상, 다른 함수**. |

**이 함수(어느 오버로드든)의 실제 호출자는 이번 턴 재확인 결과 0건**이다(Flutter `catchmenu_app/lib` 0건, 다른 SQL 정의부 라이브 `prosrc` 스캔 0건 — `0035`/`0073`은 함수 존재 여부만 확인하는 검증 스크립트일 뿐 실제 호출 아님). 호출자 0건이라는 사실관계 자체는 변하지 않는다 — 다만 Human 결정에 따라 "긴급하지 않으니 이월"이 아니라 "지금 같이 고쳐서 조사 비용을 재사용"하는 쪽으로 범위를 확정한다.

**정확한 위치 재확인 (이번 턴)**: `0063`의 `create_order_session()` 두 번째 오버로드에서 검증 배열은 L44-47:

```sql
  if p_session_type not in (
    'WALK_IN', 'WAITING', 'PRE_ORDER',
    'KIOSK', 'DELIVERY', 'ONLINE'
  ) then
```

이 배열의 `'ONLINE'`(L46)이 `'TAKEOUT'`으로 바뀌어야 할 대상이다. 같은 함수 L142에서 `p_session_type`이 그대로 `order_sessions` INSERT에 전달되므로(값 자체는 그대로 통과), 이번 배열 수정으로 `'TAKEOUT'` 호출이 처음으로 검증을 통과해 실제 INSERT까지 도달하게 된다 — 상세 Before/After와 하류 영향은 `600612_Logic.md` §2 참조.

## §2.5 Candidate Affected Files — 2개 파일, 2개 함수로 확장

| 파일 | 함수 | 수정 내용 | 위치 |
|---|---|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `catchmenu_store.place_takeout_order()` | `order_sessions` INSERT의 `session_type` 리터럴 `'ONLINE'` → `'TAKEOUT'` | L826 |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | `catchmenu_pos.create_order_session()` (두 번째 오버로드 — `p_queue_position`/`p_pre_order_expires_at` 시그니처) | (a) `p_session_type not in (...)` 검증 배열의 `'ONLINE'` → `'TAKEOUT'` | L46 |
| 〃 | 〃 | (b) `case p_session_type` 분기 4곳에 `when 'TAKEOUT' then 'ORDERING'` 명시 추가(Human 결정, `0025` L71과 정합) | L143-148, L173-178, L202-206, L244-249 |

두 파일 모두 "허용값/분기 목록에 `'TAKEOUT'`이 빠져 있거나 `'ONLINE'`으로 잘못 들어가 있다"는 동일한 근본 원인 계열을 공유하지만, 서로 다른 함수·다른 시그니처·다른 파일이므로 각각 독립적으로 수정한다. `0081`은 1곳(리터럴 1개), `0063`은 검증 배열 1곳 + `case` 분기 4곳으로 총 5곳(상세 Before/After는 `600612_Logic.md` §2/§2.1 참조). `0025_create_session_rpc.sql`의 `create_order_session()` 첫 번째 오버로드는 이미 정확하므로(§1 표 참조) 수정 대상이 아니다. `0063`의 `case` 분기 4곳 중 L202-206은 `'DELIVERY'` 분기 자체가 원래 없는 별개의 기존 불일치를 이번 턴에 발견했으나, 이번 Human 결정(TAKEOUT 추가)의 범위 밖이므로 손대지 않는다(`600612_Logic.md` §2.1 투명 공개).

## §3 `order_sessions.session_type` 값 참조/기대 전수 확인 — 회귀 위험 없음

**`'ONLINE'`을 읽는(WHERE/필터) 쪽**: `sql/migrations/*.sql` 전체와 `catchmenu_app/lib` 전체를 `session_type.*=.*'ONLINE'` / `session_type.*in.*'ONLINE'` 패턴으로 재검색한 결과 **0건**. `'ONLINE'`이 다른 맥락(예: `device_status`, `agent_status`)에서 널리 쓰이는 리터럴이긴 하나(`0003`/`0041`/`0047`/`0070` 등, 전부 디바이스/에이전트 상태값이지 `session_type`이 아님), `order_sessions.session_type` 필터 조건으로서의 `'ONLINE'` 참조는 어디에도 없다.

**앞으로 쓰일 `'TAKEOUT'`을 읽는(WHERE/필터) 쪽**: 동일하게 `session_type.*'TAKEOUT'` 패턴으로 전수 검색한 결과도 **0건**. 즉 `session_type = 'TAKEOUT'`을 특별 취급하는 기존 로직이 전혀 없으므로, 이번 값 변경으로 새로 생성될 `'TAKEOUT'` 세션이 기존의 어떤 필터링된 조회/집계에 예기치 않게 편입되거나 배제될 위험도 없다.

**결론**: `'ONLINE'` → `'TAKEOUT'` 값 변경은 이 저장소 범위 안에서 회귀 위험이 확인되지 않는, 격리된 단일 지점 수정이다.

## §4 `0081` 자체 내 다른 `'ONLINE'` 언급 — 무관함 확인

`0081` L193(`grep`으로 발견)에도 `'TAKEOUT', 'DELIVERY', 'ONLINE'`이라는 문구가 있으나, 확인 결과 이는 L185-198 범위의 **완전히 주석 처리(비활성)된 `catchmenu_store.customer_order_history` 뷰 정의 초안**의 일부이며, `catchmenu_pos.orders.order_type`(별개 컬럼, `order_sessions.session_type`이 아님) 값 목록을 나열한 것이다. 실행되지 않는 코드이고 다루는 컬럼도 다르므로 이번 수정과 무관하다 — 참고만 하고 손대지 않는다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md` — 이번 문서가 따르는 8단계 파이프라인(Stage 1.5) 그 자체.
- `000001_Md_Rules.md` — 문서 작성 규칙 상위 anchor.

### Full Rules Required

- `sql/migrations/0012_create_pos_order_sessions.sql` — `chk_session_type` 제약의 원 정의(전체 허용값 목록의 유일한 출처).
- `sql/migrations/0025_create_session_rpc.sql` — `create_order_session()` 첫 번째(정확한) 오버로드. 이번 수정이 목표로 하는 "정답" 값 목록의 근거.

### Domain Indexes

- 해당 없음 — 본문에 도메인 Index/NavigationMap/Readme 인용은 없다.

### Excluded Rule Families

- 900시리즈(설계/특허 문서군) — 이번 수정은 리터럴 값 하나(그리고 동일 근본 원인의 두 번째 리터럴 값 하나)를 허용값 목록에 맞게 교정하는 단순 정합화이며, 상위 설계/특허 anchor를 참조하지 않는다.
- `600717_Audit.md`의 `point_ledger`/`discount_pct` Open Items — 관련 있으나 이번 workpacket의 수정 범위(§2.5의 2개 파일)와는 완전히 다른 코드 영역이므로 이번 Context Snapshot에 포함하지 않는다.
- 쿠폰 이중 사용 레이스컨디션 — `600712_Logic.md` Open Questions로 이월된 별도 후보, 이번 수정과 무관.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600612_Logic.md` 작성 진행 가능.
