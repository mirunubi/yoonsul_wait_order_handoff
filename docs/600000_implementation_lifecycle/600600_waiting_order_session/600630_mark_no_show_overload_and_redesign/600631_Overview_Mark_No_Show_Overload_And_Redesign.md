# 600631_Overview_Mark_No_Show_Overload_And_Redesign.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`mark_no_show_overload_and_redesign`

## §0 번호 확인 — 도메인 재확인 결과: 결제 아님, 대기열 도메인

지시문의 가칭 `600590`은 `600500_payment_confirmation/`(결제) 도메인 번호 대역에 속한다. 그러나 `mark_no_show()`는 대기열/세션 상태(`order_sessions.session_status`, 노쇼 처리)를 다루는 함수이지 결제 개념이 아니다 — 도메인 재확인 결과 `600600_waiting_order_session/`이 정확한 도메인이다(재확인, `600600_Readme_Waiting_Order_Session.md`).

`600600_waiting_order_session/` 산하 현재 워크패킷 폴더는 `600610_takeout_session_type_fix/`/`600620_customer_handoff_contract_reconciliation/` 2개다(재확인, `ls`). 10단위 관례상 다음 빈 번호는 **`600630`**(`find`로 미사용 재확인) — 지시문의 가칭 `600590`을 **`600630`으로 정정**한다. Overview는 `600631`, Logic은 `600632`.

## §1 배경 재확인 — 두 오버로드 전문 재확인

지시문은 "Cursor 삼중 조사 완료, 재확인 불필요"라고 명시했으나, 이번 세션 원칙(§43/§44)에 따라 라이브 소스 전문을 직접 재대조했다.

### §1.1 `0050`(구) — `catchmenu_pos.mark_no_show(uuid,uuid,uuid,text,uuid,text)`

`0050:445-574` 전문 재확인:
```sql
create or replace function catchmenu_pos.mark_no_show(
  p_tenant_id uuid, p_store_id uuid, p_session_id uuid,
  p_actor_type text default 'STAFF', p_actor_id uuid default null,
  p_correlation_id text default null
)
...
select id, session_status, wait_number, arrival_reliability_score,
       business_day, business_timezone
into v_session
from catchmenu_pos.order_sessions
where id = p_session_id and store_id = p_store_id and tenant_id = p_tenant_id
for update;

if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
  return jsonb_build_object('success', false, 'error_key', 'session_not_markable', ...);
end if;

-- decrease arrival reliability score (특허2 주석)
v_new_score := greatest(0, coalesce(v_session.arrival_reliability_score, 100) - 20);

update catchmenu_pos.order_sessions
set session_status = 'NO_SHOW', arrival_reliability_score = v_new_score,
    cancelled_at = now(), updated_at = now()
where id = p_session_id;
```
선행 상태: `WAITING` 또는 `ARRIVAL_PENDING` 둘 다 허용. 사용 컬럼(`session_status`/`wait_number`/`arrival_reliability_score`/`business_day`/`business_timezone`/`cancelled_at`/`updated_at`) 전부 라이브 재확인 결과 실존. `session_events`/`catchmenu_ledger.events` INSERT도 전부 실존 컬럼만 사용. **KDS 연동 코드는 이 함수 어디에도 없다.**

### §1.2 `0115`(신) — `catchmenu_pos.mark_no_show(uuid,uuid,uuid,uuid,text,text)`

`0115:1333-1463` 전문 재확인:
```sql
create or replace function
  catchmenu_pos.mark_no_show(
  p_tenant_id uuid, p_store_id uuid, p_session_id uuid,
  p_actor_id uuid default null, p_locale text default 'ko',
  p_correlation_id text default null
)
...
select id, wait_number, session_status, guest_locale, pre_order_amount, called_at
into v_session
from catchmenu_pos.order_sessions
where id = p_session_id and store_id = p_store_id and tenant_id = p_tenant_id
for update;

-- (주문 없음 검사만 있고, session_status 유효성 검사는 없음)

update catchmenu_pos.order_sessions
set session_status = 'NO_SHOW', no_show_at = now(), updated_at = now()
where id = p_session_id;

if v_session.pre_order_amount > 0 then
  update catchmenu_kds.kds_tickets kt
  set kds_status = 'CANCELLED', cancelled_at = now(), updated_at = now()
  from catchmenu_pos.orders o
  where o.session_id = p_session_id and kt.order_id = o.id and kt.kds_status = 'HOLD';
end if;
```

**정정(지시문과 불일치, 코드로 직접 확인)**: 지시문은 "0115가 `ARRIVAL_PENDING`만 허용"이라고 서술했으나, **`0115`의 함수 본문 어디에도 `session_status` 유효성 검사가 없다** — `v_session.id is null`(세션 자체가 없는 경우)만 검사하고, 그 외에는 현재 `session_status` 값과 무관하게 무조건 `NO_SHOW`로 덮어쓴다. `chk_session_status` CHECK 제약이나 트리거로 전이를 제한하는 메커니즘도 라이브에 없음을 재확인했다(`pg_trigger` 조회 결과 `order_sessions`에는 `updated_at` 자동 갱신 트리거 1개뿐). **`0115`는 `0050`이 갖고 있던 상태 검사(`WAITING`/`ARRIVAL_PENDING`만 허용)를 아예 갖고 있지 않다** — "더 좁은 허용"이 아니라 "검사 자체가 없는 회귀"다.

**phantom 컬럼 3개 재확인**: `pre_order_amount`/`called_at`/`no_show_at` 전부 라이브 `order_sessions`(35개 컬럼, 전수 재조회)에 없음을 확인했다.

## §2 900xxx 설계 문서 재확인 — 부분 지지, 부분 내부 모순 발견

전담 조사(별도 서브에이전트, `docs/900000_patent_and_handoff_package/` 전수 검색)로 확인한 결과:

- **선행 상태 제한**: `900101_Logic...md:249-250`("선행: `session_status = 'ARRIVAL_PENDING'`")와 상태-액션 매트릭스(`900101:288-295`, `mark_no_show`는 `ARRIVAL_PENDING`만 ✓, `WAITING`은 ✗)가 `0115`(상태 검사 자체가 없다는 점은 별개로, 의도했던 시맨틱은) `ARRIVAL_PENDING` 전용을 지지한다 — `0050`의 "`WAITING`도 허용"과는 다르다. **지시문의 이 부분은 정확하다(설계 의도 차원에서).**
- **`arrival_reliability_score` 페널티**: 900xxx 전체에서 **0건 언급** — 유지/폐기 어느 쪽도 설계 문서가 결정하지 않았다. 완전한 설계 공백이다.
- **KDS HOLD→CANCELLED 연동 — 내부 모순 발견**: `900101_Logic...md:254-256`("사이드 이펙트: `pre_order_amount > 0`이면 `kds_tickets UPDATE: HOLD → CANCELLED`")는 `0115`의 동작과 일치한다. **그러나 같은 900xxx 패키지 안의 다른 3개 문서(`900102_ChangeContract` F-003, `906010_ChangeContract` §13.3 영문판, `900103_TestPlan` TC-104, `906000_TestPlan` 영문판)는 정반대로 "`KDS HOLD 유지`(사전주문 미조리, 취소하지 않음)"를 명시한다.** 즉 **900xxx 설계 문서 패키지 자체가 이 지점에서 내부적으로 모순**되어 있다 — `900101`(로직 스펙)은 취소를, `900102`/`900103`/`906010`/`906000`(ChangeContract/TestPlan, 한글+영문 양쪽 다)은 HOLD 유지를 각각 명시한다. `0115`의 실제 코드는 `900101` 한 문서만을 따른다.

**결론**: 지시문의 "900100/900101이 0115 시맨틱을 canonical로 명시"는 **선행 상태 제한에 대해서는 정확**하지만, **KDS 연동 부분은 부정확/과장**이다 — 실제로는 설계 문서 패키지 자체가 이 지점에서 다수결로는 오히려 "HOLD 유지" 쪽(4개 문서)이 우세하고 `900101` 1개 문서만 "CANCELLED"를 명시한다. 어느 쪽이 "진짜 canonical"인지는 이 문서가 판단하지 않는다(§9 Open Item) — 이 모순 자체를 발견해 기록하는 것이 이번 조사의 성과다.

## §3 `pre_order_amount`의 실제 출처 — `order_sessions`에는 없음, 항상 boolean 용도로만 쓰임

`0051_create_pre_order_rpc.sql`의 `create_pre_order()`(`0051:15-` 전문 재확인) 패턴: 사전주문은 `catchmenu_pos.orders` 행을 실제로 생성하고(`v_order_id`), 그 금액은 `orders.total_amount`/`orders.final_amount`에 저장한다(`0051:298-304`) — `order_sessions`에는 금액 컬럼이 전혀 없다. 대신 `order_sessions`는 `order_id`(FK)와 `pre_order_created_at`/`pre_order_expires_at`(둘 다 라이브 실존, 재확인)만 갖는다.

**기존에 이미 확립된 대체 패턴 발견**: `0050`/`0051`의 `get_pre_order_status()` 등 여러 곳(`0050:70`/`258`/`284`/`298`, `0051:823-829`)이 이미 `v_session.pre_order_created_at is not null`을 "사전주문 존재 여부" 판정에 일관되게 사용하고 있다 — `pre_order_amount`라는 컬럼이 있었던 적이 없고, 애초에 이 boolean 패턴이 표준이었던 것으로 보인다.

**결정적 확인**: `mark_no_show()`(`0115`)와 `confirm_arrival()`(`0115`, §4에서 별도 발견) 양쪽 모두에서 `pre_order_amount`는 **오직 `> 0` 비교(boolean 게이트)로만 쓰이고, 실제 금액 숫자값 자체는 어디에도 노출되지 않는다**(`mark_no_show()`의 응답 `'pre_order_cancelled', v_session.pre_order_amount > 0`도 boolean). **따라서 `v_session.pre_order_created_at is not null`로 완전히 대체 가능하다 — 추가 JOIN도, 스키마 변경도 필요 없다.** `orders.final_amount`를 실제로 조회해야 하는 경우(예: 응답에 정확한 취소 금액을 포함해야 한다는 새 요구사항이 생긴다면)는 `order_sessions.order_id`를 거쳐 `catchmenu_pos.orders`를 조인해야 하며, 이는 현재 코드가 하지 않는 추가 작업이다.

## §4 신규 발견 — phantom 컬럼이 `mark_no_show()`/`0118` 밖으로도 확장됨 (범위 초과, Open Item)

지시문이 요청한 범위(`mark_no_show()`, `0118` cron)를 조사하는 과정에서, `0115`의 **다른 함수에도 같은 phantom 컬럼이 있음**을 발견했다 — 이 문서는 이를 전수 감사하지는 않았으나(§9 Open Item, 범위 밖) 발견한 것은 기록한다.

`confirm_arrival()`(`0115:872-985`, `mark_no_show()`와 다른 함수)의 SELECT/응답:
```sql
select id, wait_number, session_status, guest_locale, pre_order_amount, table_number
...
'has_pre_order', v_session.pre_order_amount > 0,
'pre_order_amount', v_session.pre_order_amount,
'table_number', v_session.table_number,
```
`pre_order_amount`(§3과 동일 phantom)뿐 아니라 **`table_number`도 phantom**(라이브 재확인 — `order_sessions`에는 `table_id`(uuid)만 있고 `table_number`는 없음). 또한 이 함수의 UPDATE(`0115:918-923`)는 `arrival_confirmed_at`을 세팅하는데 이 컬럼도 **phantom**(라이브 재확인). `confirm_arrival()` 하나에서만 phantom 컬럼이 3개(`pre_order_amount`/`table_number`/`arrival_confirmed_at`) 추가로 발견됐다 — `mark_no_show()`와 무관한 별개 함수이므로 이번 워크패킷 범위에는 포함하지 않되, `0115` 파일 전체가 phantom 컬럼을 광범위하게 갖고 있을 가능성을 시사하는 신호로 기록한다.

## §5 `0050`의 `arrival_reliability_score` 페널티 로직 — 정확한 재확인 (통합 시 반영 방식은 Logic 단계)

`0050:501-507`(재확인, §1.1에 이미 인용) — `v_new_score := greatest(0, coalesce(v_session.arrival_reliability_score, 100) - 20)`. 페널티는 정확히 **20점 고정 감점**, 하한선 0(음수 방지, `greatest`). 기본값 100(NULL일 때). 이 값은 `arrival_reliability_score`(`chk_session_arrival_reliability` CHECK: 0-100 범위, 라이브 재확인)에 직접 반영되며, `create_pre_order()`(`0051:111-124`)의 `arrival_reliability_too_low` 게이트(스토어 설정 `arrival_reliability_threshold`, 기본 60)가 이 점수를 실제로 소비한다 — 즉 이 페널티는 장식이 아니라 "노쇼 이력이 있는 고객은 향후 사전주문이 거부될 수 있다"는 실제 비즈니스 로직에 연결된 살아있는 메커니즘이다. §2에서 확인했듯 900xxx 설계 문서는 이 페널티 자체를 언급하지 않으므로, `0115` 기반 통합본에 이 로직을 그대로 이식할지/조정할지/제거할지는 설계 결정 사항이며 이 문서는 판단하지 않는다(Logic 단계).

## §6 `0118`의 `WAITING_SESSION_EXPIRE` cron job — 정확한 현재 코드 재확인, phantom 컬럼 1개 추가 발견

파일명 정정: 지시문은 "0118의 pg_cron"이라 지칭했으나 실제 파일명은 `0118_create_schema_validation_update.sql`이다(`0118:165-190`에 cron job 정의가 포함되어 있을 뿐, 파일 자체는 스키마 검증 관련 다른 내용도 함께 다룸).

`0118:164-188` 전문 재확인:
```sql
(
  'WAITING_SESSION_EXPIRE',
  'catchmenu_waiting_session_expire',
  '*/10 * * * *', '*/10 * * * * (10분마다)',
  $sql$
-- 호출 후 15분 노응답 → 자동 노쇼
UPDATE catchmenu_pos.order_sessions
SET session_status = 'NO_SHOW', no_show_at = now()
WHERE session_status = 'ARRIVAL_PENDING'
  AND called_at < now() - interval '15 minutes'
  AND no_show_at IS NULL;

-- 대기 등록 후 2시간 미착석 → 자동 취소
UPDATE catchmenu_pos.order_sessions
SET session_status = 'CANCELLED', cancelled_at = now(), cancel_reason = 'AUTO_EXPIRE'
WHERE session_status = 'WAITING'
  AND session_started_at < now() - interval '2 hours';
$sql$,
  '대기 세션 자동 만료. 10분마다.', true
)
```
지시문이 언급한 `called_at`/`no_show_at` phantom은 재확인됐다(첫 번째 UPDATE). **신규 발견**: 같은 cron job의 **두 번째 UPDATE**(대기 2시간 초과 자동 취소, 지시문이 언급하지 않은 부분)가 `cancel_reason`을 세팅하는데, 이 컬럼도 라이브 `order_sessions`에 **존재하지 않는다**(재확인, 0건). 즉 이 cron job은 **두 UPDATE 문 전부**가 각자 다른 phantom 컬럼으로 크래시한다 — 첫 번째는 `called_at`/`no_show_at`(2개), 두 번째는 `cancel_reason`(1개), 총 3개.

## §7 실제 호출자 재확인 — 0건 (SQL/Flutter 전체)

`grep -rn "mark_no_show(" sql/migrations/*.sql`를 grant/revoke/comment/자기 정의 라인 제외하고 재실행한 결과, 유일하게 남는 것은 `0119_create_edge_function_integration.sql:237`의 문서 문자열(`'cancel_waiting() / mark_no_show()'`, 실제 호출 아님)뿐이다. `catchmenu_app/`/`apps/` 재검색 결과도 0건. 지시문의 "실제 호출자 0건" 주장을 정확히 재확인했다 — 두 오버로드 모두, 그리고 `0118`의 cron job도 현재 실행돼도 아무도 그 결과를 소비하지 않는 상태다(다만 cron job 자체는 10분마다 실제로 실행은 시도되어 매번 크래시할 것이라는 점에서 `mark_no_show()` 자체보다 위험도가 약간 높다 — cron은 "호출자"가 pg_cron 스케줄러 자신이므로).

## §8 통합 방향에 대한 함의 (판단 아님, Logic 단계로 이월)

- `0115`를 canonical 베이스로 삼는 것은 §2(선행 상태 제한)/§1.2(KDS 연동 존재 자체)의 설계 의도와 부합하지만, **`0050`이 갖고 있던 상태 검사(`session_status not in (...)`)를 반드시 복원해야 한다** — `0115`는 이 검사가 아예 없는 회귀 상태이므로, 단순히 phantom 컬럼만 고치면 "어떤 상태의 세션이든 무조건 NO_SHOW로 덮어쓸 수 있는" 더 위험한 함수가 배포된다.
- `pre_order_amount > 0` 게이트는 `pre_order_created_at is not null`로 1:1 치환 가능(§3) — 스키마 변경 없이 해결.
- `arrival_reliability_score` 페널티(§5)를 유지할지는 설계 문서가 침묵하므로 Human 결정 필요.
- KDS HOLD→CANCELLED 연동(§2)을 유지할지(900101 근거) 제거할지(900102/900103/906000/906010 근거)는 설계 문서 내부 모순 때문에 이 문서가 판단할 수 없다 — Human 결정 필요.
- `0118` cron job(§6)의 두 UPDATE 문 모두 이번 워크패킷의 수정 범위에 포함해야 자연스럽다 — `mark_no_show()`와 정확히 같은 개념(`ARRIVAL_PENDING`+무응답→`NO_SHOW`)을 자동화한 것이므로, 함수만 고치고 cron을 방치하면 자동화 경로가 여전히 깨진 채로 남는다.
- `confirm_arrival()`(§4)의 phantom 컬럼 3개는 이번 워크패킷 범위 밖으로 유지할지, 함께 묶을지는 Logic 단계에서 옵션으로 다뤄야 한다.

## §9 Open Questions

(a) KDS HOLD→CANCELLED 연동 유지 여부 — 900xxx 설계 문서 내부 모순(§2)으로 이 문서는 판단하지 않는다. Human 결정 필요.
(b) `arrival_reliability_score` -20 페널티를 통합본에 유지/조정/제거할지(§5) — 설계 문서 공백, Human 결정 필요.
(c) `confirm_arrival()`(§4)의 phantom 컬럼 3개를 이번 워크패킷에 포함할지, 별도 워크패킷으로 이월할지 — 범위 옵션, Logic 단계.
(d) `0115`의 나머지 6개 함수(`register_waiting`/`call_waiting_customer`/`pre_order_while_waiting`/`seat_waiting_customer`/`cancel_waiting`/`get_waiting_status`/`get_waiting_admin_view` 등)에도 유사한 phantom 컬럼이 더 있는지는 이번 문서에서 전수 감사하지 않았다 — §4의 발견이 시사하는 것처럼 `0115` 파일 전체의 phantom 컬럼 전수 조사가 별도로 필요할 수 있다.
(e) `0118` cron job의 두 번째 UPDATE(`WAITING`+2시간→`CANCELLED`, `cancel_reason` phantom)를 이번 워크패킷에 포함할지 — §8에서 포함이 자연스럽다고 봤으나 최종 판단은 Human.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` §2.4-2.5 — `mark_no_show()` 선행 상태/KDS 사이드이펙트 명시(단, §2의 내부 모순 발견분과 함께 읽을 것).
- `900102_ChangeContract...md`(F-003)/`900103_TestPlan...md`(TC-104)/`906010`/`906000`(영문판) — `900101`과 모순되는 "HOLD 유지" 명시, §2에서 신규 발견.

### Full Rules Required

- `sql/migrations/0050_create_waiting_queue_rpc.sql` — `mark_no_show()` 구버전(L445-574) 전체, 페널티 로직(L501-507).
- `sql/migrations/0115_create_waiting_pipeline_rpc.sql` — `mark_no_show()` 신버전(L1333-1463), `confirm_arrival()`(L872-985, §4 신규 발견).
- `sql/migrations/0051_create_pre_order_rpc.sql` — `create_pre_order()`(L15-, 사전주문 금액의 실제 저장 위치), `get_pre_order_status()`.
- `sql/migrations/0118_create_schema_validation_update.sql` — `WAITING_SESSION_EXPIRE` cron job(L164-188).
- `catchmenu_pos.order_sessions` 라이브 스키마(35개 컬럼) 및 `chk_session_status`/`chk_session_arrival_reliability` CHECK 제약.

### Domain Indexes

- `600602_NavigationMap_Waiting_Order_Session.md`.

### Excluded Rule Families

- `confirm_arrival()`의 phantom 컬럼 3개 자체 수정(§4/§9 (c)) — 범위 포함 여부만 Open Item, 이번 문서는 수정하지 않음.
- `0115`의 나머지 6개 함수 전수 감사(§9 (d)) — 이번 문서는 하지 않음.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0에서 도메인 오류(결제→대기열)를 정정하고 번호를 `600630`으로 확정했다. §1에서 두 오버로드 전문을 재확인했고, **지시문의 "0115가 ARRIVAL_PENDING만 허용"이 부정확함을 코드로 직접 반박했다** — 0115는 상태 검사 자체가 없는 회귀 상태다. §2에서 900xxx 설계 문서를 전담 조사한 결과, 선행 상태 제한은 0115를 지지하지만 **KDS 연동 부분은 900xxx 패키지 자체가 내부 모순**(900101 vs 900102/900103/906000/906010)임을 발견했다. §3에서 `pre_order_amount`가 boolean 용도로만 쓰인다는 것을 확인해 `pre_order_created_at is not null`로 스키마 변경 없이 대체 가능함을 확정했다. **§4에서 범위 밖(`confirm_arrival()`)의 phantom 컬럼 3개를 추가로 발견**해 별도 Open Item으로 기록했다. §5에서 페널티 로직(고정 -20점, 하한 0)을 정확히 재확인했다. §6에서 `0118` cron job에서 지시문이 언급하지 않은 세 번째 phantom(`cancel_reason`)을 신규 발견했다. §7에서 호출자 0건을 재확인했다. `600632_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
