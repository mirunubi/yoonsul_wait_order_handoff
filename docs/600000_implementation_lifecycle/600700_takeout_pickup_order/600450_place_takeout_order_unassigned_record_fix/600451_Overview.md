# 600451_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`place_takeout_order_unassigned_record_fix`

## §0 Human 결정 (재논의 금지)

정식 워크패킷으로 진행한다(§24 경량 방식 대신 전체 파이프라인 — Overview→Logic→TestPlan→ChangeContract→이중검증→감사). 배경(Antigravity+Cursor 조사 결과, 재확인 불필요로 전제): `catchmenu_store.place_takeout_order()`(`0081`)의 `v_customer`/`v_coupon` `record` 변수가 조건부로만 `SELECT INTO` 되는데, 이후 무조건 `.id is not null`로 접근하려다 "record is not assigned yet" 에러가 발생한다. 두 개의 독립 실패 경로가 이미 확인됨:
- 경로 A: 게스트(비회원) + 쿠폰 없음 → L609(`v_customer`)
- 경로 B: 회원 + 쿠폰 없음 → L714(`v_coupon`)

`600452_Logic.md` 최종본 기준의 확정 설계는 boolean 가드 방식이 아니라 **스칼라 변수 치환**이다. `v_customer_found and v_customer.id is not null` 류의 boolean 가드는 PL/pgSQL 무타입 `record` 해석 단계에서 무효로 확인됐으므로, L609/L622/L653/L661/L714/L852/L864/L869/L924/L930/L949 11곳 전부를 `v_customer_id`/`v_coupon_id` 등 스칼라 변수 참조로 전환한다. 포인트 정책은 Human 결정 A안(고객 식별 불가 시 조용히 skip) + `catchmenu_common.log_diagnostic()` 경고 로깅으로 확정됐다.

## §1 PL/pgSQL "record not assigned yet" 정확한 발생 조건 — 이번 턴 직접 실증

`v_customer`/`v_coupon`는 `record`(무타입) 변수로 선언되며(L531/L540), 이 타입은 **한 번도 `SELECT INTO`를 거치지 않으면 완전히 "unassigned" 상태**로 남는다. 이번 턴 익명 `DO $$` 블록으로 두 시나리오를 직접 대조 실증했다:

- **SELECT INTO가 실행됐지만 0행 매치**(분기에 진입은 함): `record`가 **assigned** 상태가 되며 모든 필드가 NULL — 이후 `.id is not null` 접근은 에러 없이 안전하게 `false`를 반환한다.
- **분기 자체를 건너뜀**(SELECT INTO가 아예 실행 안 됨): `record`는 여전히 **unassigned** — `.id` 접근 시 `ERROR: record "..." is not assigned yet`.
- **`v_test := null;`로 우회 시도도 실패**: 무타입 `record`는 한 번도 구조를 부여받지 않으면 `NULL` 대입으로도 "assigned" 상태로 만들 수 없다(동일 에러) — 즉 "그냥 else절에서 NULL 대입" 같은 얕은 수정은 통하지 않는다.

**이 사실이 바꾸는 정확한 결함 조건**:
- `v_customer`: `p_customer_id`도 `p_phone_hash`도 **둘 다 NULL**일 때만 unassigned — 아무 조건도 안 걸린, 진짜 완전 익명 호출(전화번호조차 없는 게스트)만 해당한다. `p_phone_hash`만 제공되고 매칭되는 고객이 없는 경우는 **안전**하다(분기 진입 → 0행 → NULL로 assigned).
- `v_coupon`: `p_coupon_issue_id`가 **NULL**일 때만 unassigned. 쿠폰 ID가 제공됐지만 유효하지 않은 경우는 L661에서 이미 명시적으로 `coupon_not_redeemable` 에러를 반환하도록 처리돼 있어 **안전**하다(분기 진입 → 0행 → NULL로 assigned → L661 명시적 에러).

**중요 — 이 §1의 내용은 "크래시가 언제 발생하는가"에 대한 사실이며, "boolean 가드로 막을 수 있는가"와는 다른 층위의 질문이다(`600452_Logic.md` §0-§1에서 별도로 실증됨, 갱신 이력 참고)**: 위 실증은 어떤 **입력 조건**이 `record`를 unassigned 상태로 남기는지를 규명한 것으로, 그 자체는 여전히 유효한 사실이다. 그러나 "unassigned 상태인지 여부를 boolean 플래그(`v_customer_found` 등)로 감싸서 접근을 막을 수 있는가"는 완전히 별개의 질문이며, 답은 **아니오**다 — `600452_Logic.md`가 `v_flag and v_test.id is not null` 형태의 표현식을 `DO $$` 블록으로 직접 테스트한 결과, `v_flag`의 값(short-circuit 여부)과 무관하게 크래시가 재현됐다. 원인은 Postgres가 이 표현식을 **평가하기 전, 해석(파싱/플랜 구성) 단계에서** `v_test`의 컬럼 구조를 알아야 하는데, 무타입 `record`는 구조 자체가 없기 때문이다 — 이는 런타임 조건 분기(§1이 다루는 "0행 매치 vs 분기 미진입")보다 더 이른 단계에서 발생하는 문제라 boolean 가드로는 원천적으로 막을 수 없다. 이 구분이 §2의 수정 설계 프레이밍을 바꾼다.

## §2 결함/참조 지점 11곳 — 전부 동일한 스칼라 전환 대상, "관찰된 에러"와 "잠재적 결함"을 구분해서 서술 (갱신, `600452_Logic.md` 최종본 반영)

**정정된 프레이밍**: 이전 버전은 L609/L714를 "실제 크래시 지점", 나머지를 "다운스트림 참조, 안전"으로 나눴다 — 이는 Cursor+Antigravity 독립 조사에서 틀린 것으로 확인됐다. `if`문은 `return`이 아니므로, L609/L714가 (가드를 통해) 크래시 없이 통과하더라도 그 뒤의 코드는 계속 실행되며, 여전히 unassigned일 수 있는 `v_customer`/`v_coupon`에 접근한다. **11곳 전부가 동일한 스칼라 전환 대상이며, 그 중 어디가 먼저 크래시하는지는 순전히 "현재 버그 있는 코드가 어디서 먼저 멈추는가"라는 우연에 불과하다** — "안전한 위치"는 없고, "아직 도달하지 못해 관찰되지 않은 위치"만 있다. 단, L661은 SELECT 직후 위치라 실행상 위험하지는 않지만, `v_coupon.id` 참조 지점이므로 일관된 스칼라 전환 원칙상 함께 포함한다.

이번 턴 원래 목록에 없던 **L661**(`if v_coupon.id is null then`)과 **L869**(`deduct_points()` 호출의 `p_customer_id` 인자)도 추가로 발견해 반영한다 — `600452_Logic.md` §4에서 동일하게 확인됨.

| 라인 | 코드 | 이 자리에서 실제로 관찰된 에러(현재 버그 있는 코드 기준) | 결함 성격 |
|---|---|---|---|
| L609 | `if v_customer.id is not null and p_use_points > 0 then`(포인트 잔액 확인 진입 가드) | **관찰됨** — `p_customer_id`/`p_phone_hash` 둘 다 NULL인 게스트 호출에서 `record "v_customer" is not assigned yet` 직접 재현. | `v_customer` 구조적 결함 — 게스트+쿠폰없음/게스트+쿠폰ID제공 경로에서 최초로 도달하는 지점이라 관찰됨. |
| L622 | `where customer_id = v_customer.id`(포인트 잔액 조회 WHERE) | 미관찰 — L609에서 먼저 멈추므로 현재 코드는 여기 도달하지 못함. | 동일한 `v_customer` 구조적 결함. L609가 고쳐지지 않은 채 이 지점까지 실행이 도달하면 동일하게 크래시한다. |
| L653 | `and ci.customer_id = v_customer.id`(쿠폰 조회 WHERE) | **관찰됨(Cursor+Antigravity, 게스트+쿠폰ID제공 경로)** — L609를 boolean 가드로 우회시킨 뒤 재실행하면 이 지점에서 크래시. | 동일한 `v_customer` 구조적 결함. L609와 별도의 독립 진입 지점(쿠폰 조회 블록은 `p_coupon_issue_id`로만 게이트되고 `v_customer` 상태로 게이트되지 않음). |
| L661 | `if v_coupon.id is null then`(쿠폰 조회 직후 명시적 에러 반환 가드) | 실행상 안전 — SELECT 직후라 0행이면 NULL assigned 상태로 `coupon_not_redeemable` 에러를 반환한다. | `v_coupon.id` 참조 지점. 안전하지만 일관된 스칼라 전환 원칙상 `v_coupon_id is null`로 함께 치환 대상에 포함. |
| L714 | `if v_coupon.id is not null then`(쿠폰 할인 계산 진입 가드) | **관찰됨** — `p_coupon_issue_id`가 NULL인 회원 호출에서 `record "v_coupon" is not assigned yet` 직접 재현. | `v_coupon` 구조적 결함 — 회원+쿠폰없음 경로에서 최초로 도달하는 지점이라 관찰됨. |
| L852 | `if v_coupon.id is not null then`(쿠폰 사용 처리 진입 가드) | **관찰됨(Cursor+Antigravity, 회원+쿠폰없음 경로)** — L714를 boolean 가드로 우회시킨 뒤 재실행하면 이 지점에서 크래시. | 동일한 `v_coupon` 구조적 결함. |
| L864 | `and v_customer.id is not null`(포인트 사용 처리 가드) | 미관찰 — L609에서 먼저 멈추므로 도달 못함. | 동일한 `v_customer` 구조적 결함. |
| L869 | `p_customer_id := v_customer.id,`(`deduct_points()` 호출 인자, 신규 발견) | 미관찰 — L609/L864에서 먼저 멈추므로 도달 못함. | 동일한 `v_customer` 구조적 결함. |
| L924 | `'CUSTOMER', v_customer.id,`(ledger 이벤트 `caused_by_id`) | **관찰됨(Cursor+Antigravity, 게스트+쿠폰없음 경로)** — L609를 우회시킨 뒤 재실행하면 이 지점에서 크래시. | 동일한 `v_customer` 구조적 결함. |
| L930 | `'coupon_used', v_coupon.id is not null,`(ledger 이벤트 payload) | 미관찰 — L852에서 먼저 멈추므로(회원+쿠폰없음 경로) 또는 L609에서 먼저 멈추므로(게스트 경로) 도달 못함. | 동일한 `v_coupon` 구조적 결함. |
| L949 | `coalesce(v_customer.display_name, '비회원'),`(직원 알림 payload) | **관찰됨(Cursor+Antigravity, 게스트+쿠폰없음 경로)** — L609를 우회시킨 뒤 재실행하면 이 지점에서 크래시. | 동일한 `v_customer` 구조적 결함. |

**요약**: "관찰됨"과 "미관찰"의 차이는 결함의 유무가 아니라 **현재 버그 있는 코드가 어디서 먼저 멈추느냐**의 차이일 뿐이다. `600452_Logic.md` 최종본은 이 11곳 전부를 예외 없이 스칼라 변수 치환으로 수정한다 — L661은 실행상 안전하지만 같은 `v_coupon.id` 참조 지점이라 일관성 원칙상 포함한다. boolean 가드가 아니라 스칼라 변수를 쓰는 이유는 `600452_Logic.md` §0-§2에서 별도로 실증/확정됐다(위 §0 및 §1 마지막 문단 참고). 포인트 사용 경로의 `v_customer_id is null and p_use_points > 0`은 `600452_Logic.md` §3의 Human 결정 A안대로 주문을 실패시키지 않고 skip하며, `catchmenu_common.log_diagnostic()`으로 경고를 기록한다.

## §3 "회원+쿠폰 사용" 조합 — 이번 턴 직접 테스트, **성공하지 않음(단, 원인이 다름)**

작업 지시에서 "아직 검증 안 된 유일한 성공 후보"로 지목한 조합을 이번 턴 실제로 호출했다. **결과: 실패한다 — 그러나 record-unassigned 문제 때문이 아니라, 완전히 별개인 스키마 불일치 때문이다.**

```
ERROR:  column c.discount_pct does not exist
LINE 4:            c.discount_pct,
QUERY:  select ci.id, ci.issue_status, ci.expires_at,
               c.discount_type, c.discount_value,
               c.discount_pct,
               c.min_order_amount, c.max_discount_amount
        from catchmenu_store.coupon_issues ci
        join catchmenu_store.coupons c on c.id = ci.coupon_id
        where ci.id = p_coupon_issue_id and ci.customer_id = v_customer.id ...
```

**투명 공개 — 새로 발견된 별개 결함(이번 workpacket 범위 밖)**: `catchmenu_store.coupons`의 실제 컬럼은 `discount_type`(허용값 `'FIXED'`/`'PERCENTAGE'`, `chk_discount_type` 제약으로 이번 턴 재확인)과 `discount_value`(정수, 고정/비율 겸용으로 보임) 두 개뿐이다 — `discount_pct`라는 컬럼 자체가 존재하지 않는다. 게다가 L731-744의 할인 계산 로직도 `case v_coupon.discount_type when 'AMOUNT' then ... when 'PCT' then ...`로 분기하는데, 이 리터럴(`'AMOUNT'`/`'PCT'`)도 실제 허용값(`'FIXED'`/`'PERCENTAGE'`)과 일치하지 않는다 — 즉 쿠폰 서브시스템 전체가 `0081` 작성 시점 이후 스키마가 바뀌었는데 소스가 따라가지 못한, 이번 세션에서 반복적으로 발견해온 stale-schema 패턴의 또 다른 사례다.

**결론**: "회원+쿠폰" 조합은 지금 record-unassigned 크래시(L714)에 도달하기도 전에 더 앞단(L648 SELECT 자체)에서 완전히 다른 이유로 죽는다. 정적으로 추론하면(이 `discount_pct` 결함이 언젠가 별도로 고쳐진다는 가정 하에) `p_coupon_issue_id`가 제공된 이상 `v_coupon`은 L641 분기에 진입해 assigned 상태가 되므로, record-unassigned 문제 자체는 이 조합에서 발생하지 않았을 것으로 판단된다 — 그러나 이는 **오늘 실제로 실행해서 확인한 사실이 아니라, 코드를 정적으로 읽어서 내린 추론**임을 명시한다. `discount_pct`/`'AMOUNT'`/`'PCT'` 결함은 이번 workpacket이 다루는 record-unassigned 문제와 무관한 별개 결함으로, 고치지 않고 별도 후속 워크패킷 후보(Open Item)로만 기록한다(`600452_Logic.md` §Open Questions).

**함의**: 이번 재조사 결과, **`place_takeout_order()`는 현재 상태에서 사실상 모든 실사용 조합이 실패한다** — 게스트/회원, 쿠폰 있음/없음 어느 조합이든 record-unassigned 또는 별개의 `discount_pct` 결함 중 하나에 걸린다. 유일하게 크래시 없이 성공 가능성이 있는 조합은 "완전 익명이 아닌 식별 수단(customer_id 또는 phone_hash 매칭 여부 무관하게 제공됨) + 쿠폰 미사용 + 포인트 미사용"이지만, 이조차 아직 이번 조사에서 직접 실행 확인하지는 않았다(§Open Question으로 `600452_Logic.md`에 이월).

## §4 영향 범위 — 이 함수를 호출하는 다른 곳이 있는지 (재확인)

이번 턴 재확인 결과, `place_takeout_order()`의 실제 호출자는 **없다**:
- `catchmenu_app/lib` 전체 재검색: 0건.
- `sql/migrations/*.sql` 전체 재검색(정의 자체 제외): `0092`(Dart 클라이언트 예시 텍스트, 실행 안 됨), `0096`(함수 존재 여부만 확인하는 검증 리스트), `0113`(API 스펙 문서, 순수 텍스트) — 실제 SQL 호출 0건.
- 라이브 `pg_proc.prosrc` 전체 스캔(정의 자체 제외): 0건.

즉 이 함수는 **현재 아무도 호출하지 않는다** — 실제 서비스 영향은 0이지만, MVP 단계에서 곧 Flutter 고객 앱이 이 RPC를 쓰게 될 것이 예상되므로, Human 결정대로 정식 파이프라인으로 지금 고쳐두는 것이 타당하다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- 해당 없음 — 본문은 Cursor+Antigravity 조사 결과와 `0081`의 `place_takeout_order()` 직접 실증에 기반한 순수 코드 정합화이며, 별도 900시리즈/특허/상위 설계 문서를 anchor로 삼지 않는다.

### Full Rules Required

- `600452_Logic.md` — boolean 가드 무효, 스칼라 변수 치환, 11곳 참조 지점, 포인트 정책 A안 + `log_diagnostic()` 로깅을 확정한 직접 후속 설계 문서.

### Domain Indexes

- 해당 없음 — 본문에 도메인 Index/NavigationMap/Readme 인용은 없다.

### Excluded Rule Families

- `discount_pct`/`'AMOUNT'`/`'PCT'` 쿠폰 스키마 불일치 — 본문 §3에서 별도 후속 워크패킷 후보(Open Item)로 이월하며 이번 fix 설계에 포함하지 않는다고 명시.
- 쿠폰 이중 사용 레이스컨디션 — `600452_Logic.md` Open Questions로 이월된 별도 후보이며, 이번 Overview의 record-unassigned 수정 범위에는 포함하지 않는다.
- 실제 Flutter 호출부 구현 — 본문 §4에서 현재 호출자 0건으로 확인했으며, 이번 workpacket은 RPC 내부 안전화에 한정한다.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷은 `600452_Logic.md` 최종본과 정합한다 — boolean 가드가 아니라 스칼라 변수 치환으로 11곳 전체를 다루며, 포인트 정책은 A안(조용히 skip) + `log_diagnostic()` 로깅으로 확정됐다. `discount_pct` 별개 결함은 별도 후속 워크패킷 후보(Open Item)로 이월하며, 이번 fix 설계에는 포함하지 않는다.
