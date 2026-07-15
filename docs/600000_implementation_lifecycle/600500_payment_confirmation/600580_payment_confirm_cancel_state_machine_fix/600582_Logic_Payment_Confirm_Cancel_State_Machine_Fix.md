# 600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16
Revision: 2 — 최종 확정(Human 결정, 2026-07-16). Rule 1 = 옵션 1a(`PENDING` 재사용) 채택, Rule 6/7(`reopen_order()`) 이번 워크패킷 범위에서 완전 제외.

## Change ID

`payment_confirm_cancel_state_machine_fix`

## §0 전제 — 분류 확정 및 8가지 규칙 원문

**Human 결정(2026-07-16, ChatGPT+제미나이 교차검증 완료, 재논의 금지)**: 이 워크패킷을 단순 correction이 아니라 **"Payment-Order State Transition Partial Redesign"**으로 분류하고, ChatGPT가 제시한 8가지 규칙을 그대로 채택한다.

**8가지 규칙(원문)**:

1. `confirm_payment()`는 `CANCELLED` 주문을 `CONFIRMED`로 변경할 수 없다.
2. 결제 실패 후 재시도는 동일 주문에서 허용할 수 있지만, 주문은 `PAYMENT_PENDING`이어야 하고 새로운 `payment_attempt_id`를 사용한다.
3. 같은 provider 거래의 재전송은 멱등 처리하며 새 원장을 생성하지 않는다.
4. 취소된 주문에 늦은 승인 신호가 도착하면 결제 사실은 원장에 기록하되 주문 상태와 KDS 상태는 변경하지 않는다.
5. 늦은 승인 건은 자동 void/refund 또는 운영 reconciliation 대상으로 전환한다.
6. 직원의 취소 실수는 `confirm_payment()`가 아니라 별도의 권한 있는 `reopen_order()` 명령으로만 복구한다.
7. 주문 복구 후 부수 효과를 안전하게 되돌릴 수 없으면 기존 주문을 부활시키지 않고 replacement order를 생성한다.
8. 새 provider 거래번호라는 이유만으로 취소 주문의 재확인을 허용하지 않는다.

**최종 결정문(원문 인용)**: "취소된 주문의 일반적인 재확인은 허용하지 않는다. 결제 실패 후 다른 카드로 재시도하는 경우에는 주문을 취소하지 않고 `PAYMENT_PENDING` 상태에서 새로운 결제 시도를 생성한다. 취소 완료 후 과거 결제의 지연 승인이 도착하면 승인 사실은 원장과 reconciliation 기록에 보존하되 주문을 되살리거나 KDS를 릴리스하지 않고 승인 취소 또는 환불 절차로 보낸다. 직원의 오취소 복구는 별도의 권한·사유·버전 검사를 갖춘 주문 재개 명령으로 분리하며, 부수 효과가 이미 발생한 경우 새 주문을 생성한다."

### §0.1 Revision 2 — 최종 결정 (Human, 2026-07-16, 재논의 금지)

**Rule 1 구현 확정**: 기존 `orders.order_status = 'PENDING'`을 "결제 확정이 허용되는 상태"로 그대로 사용한다(§1의 옵션 1a 채택 — `PAYMENT_PENDING`/`PAYMENT_PROCESSING` 신규 도입 안 함). `confirm_payment()`는 `PENDING → CONFIRMED` 전이만 허용하며, 조건부 UPDATE(`WHERE order_status = 'PENDING'`, 영향행 1건 확인)로 구현한다. 그 외 상태(`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`)에서는 거부한다. 단, **이미 `CONFIRMED`인 주문에 같은 provider 거래가 재전송되면 에러가 아니라 멱등 성공을 반환**한다(§2.2).

**책임 분리 원칙(명시)**: `orders.order_status`는 **주문 생명주기**를, `payment_intents.intent_status`는 **결제 시도 생명주기**를 나타내며, 이 둘을 섞지 않는다. `PAYMENT_PENDING`/`PAYMENT_PROCESSING` 같은 세부 결제-시도 상태는 이번에 `orders`에 추가하지 않는다 — 향후 필요성이 명확해지면 별도의 상태머신 재설계 워크패킷에서 다룬다. 이 원칙에 따라 §1.4의 "Overview 갱신 필요" 여부는 **불필요로 확정**됐다 — `order_status`/`reconciliation_status` 둘 다 기존 값만으로 구현되므로(§2/§4) `600581_Overview.md` §6이 스코핑한 "세 축"을 벗어나는 스키마 변경이 발생하지 않는다.

**Rule 6/7(`reopen_order()`) 처리 확정**: 이번 워크패킷 범위에서 **완전히 제외**한다. 재고/쿠폰/포인트/KDS/대기열/환불 보상까지 연계되는 별도 복구 워크플로이므로 별도 워크패킷 대상이다. 이번 워크패킷은 "`CANCELLED` 주문은 `confirm_payment()`로 복구 불가"라는 정책만 코드로 강제하고(§2), 그 정책을 사용자에게 알리는 프론트엔드 UI 문구 권고만 Open Item으로 남긴다(§7).

## §1 범위 재확인 이력 — 스키마 변경 불필요로 최종 해소 (Revision 1 조사 보존)

Revision 1에서 확인한 사실(이번 최종본에서도 유효, 그대로 보존):

### §1.1 `order_status` — `PAYMENT_PENDING`/`PAYMENT_PROCESSING` 없음, 기존 값 `PENDING` 재사용으로 확정

라이브 재확인(Revision 1과 동일):
```sql
select conname, pg_get_constraintdef(oid) from pg_constraint
where conrelid='catchmenu_pos.orders'::regclass and contype='c';
```
```
chk_order_status  CHECK ((order_status = ANY (ARRAY[
  'PENDING','CONFIRMED','COOKING','READY','SERVED',
  'COMPLETED','CANCELLED','REFUNDED','PARTIAL_REFUNDED'])))
```
`PAYMENT_PENDING`/`PAYMENT_PROCESSING`은 이 목록에 없다 — Revision 1이 제시했던 옵션 1a(기존 `PENDING` 재사용)를 **§0.1에서 Human이 최종 채택**했다. `chk_order_status` CHECK 확장은 불필요하다.

### §1.2 `version` 컬럼 — 존재하지 않음, Rule 1 최소 구현에는 불필요

`information_schema.columns` 재확인 결과 `catchmenu_pos.orders.version`(또는 유사 컬럼) **0건**(변경 없음). §2.1의 조건부 UPDATE(`WHERE order_status = 'PENDING'` + 영향행 수 확인)만으로 규칙 1의 핵심 목적(취소된 주문의 재확인 차단)을 달성하므로, 이 컬럼 부재는 Rule 1 구현의 장애물이 아니다 — 더 엄격한 동시성 보호(동일 `PENDING` 상태 안에서의 동시 수정 탐지)가 필요하다면 `600560`류의 별도 동시성 워크패킷 대상이다(§8 Open Item).

### §1.3 라이브 데이터 표본 — 참고용, 변경 없음

`select distinct order_status from catchmenu_pos.orders` 결과 `CONFIRMED` 1종류만 관측(표본 작음, Revision 1과 동일).

### §1.4 결론 — Overview 갱신 불필요로 최종 확정

Revision 1은 이 항목을 Open Item으로 남겼으나, **§0.1의 Human 결정으로 해소됐다**: Rule 1(§2)도 Rule 4/5(§4)도 기존 CHECK 값만 재사용하므로, `600581_Overview.md`가 스코핑한 범위(§6의 세 축: 재확인 차단 로직/`payment_intents` 동기화/부분 UNIQUE 인덱스 검토)를 벗어나는 스키마 변경이 없다. Overview는 갱신하지 않는다.

## §2 Rule 1 최종 구현 설계 — `PENDING → CONFIRMED` 조건부 전이 + 멱등 성공 분기

### §2.1 조건부 UPDATE (핵심)

```sql
-- 기존 order 조회(0098:261-271, for update 락 이미 보유) 직후에 삽입
if v_order.order_status = 'CONFIRMED' then
  -- §2.2로 분기(멱등 성공 또는 충돌)
elsif v_order.order_status <> 'PENDING' then
  -- CANCELLED/REFUNDED/PARTIAL_REFUNDED는 §4(Rule 4/5)의 "기록 후 거부" 분기로
  -- COOKING/READY/SERVED/COMPLETED는 단순 거부(늦은 승인 기록 불필요 — 이미 정상 진행 중인 주문)
  if v_order.order_status in ('CANCELLED', 'REFUNDED', 'PARTIAL_REFUNDED') then
    -- §4로 위임
  else
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_params := jsonb_build_object('current_status', v_order.order_status),
      p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;
end if;

-- v_order.order_status = 'PENDING'인 경우에만 도달하는 실제 확정 UPDATE
update catchmenu_pos.orders
set
  order_status = case order_type when 'TABLE' then 'COOKING' else 'CONFIRMED' end,
  confirmed_at = now(),
  updated_at = now()
where id = p_order_id
  and order_status = 'PENDING';

get diagnostics v_row_count = row_count;

if v_row_count = 0 then
  -- SELECT ... FOR UPDATE와 이 UPDATE 사이에 상태가 바뀐 경쟁 상황
  return catchmenu_common.build_error_response(
    p_error_key := 'order_status_changed_concurrently',
    p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_rpc_name := 'confirm_payment'
  );
end if;
```
`FOR UPDATE` 락을 이미 조회 시점에 보유하고 있으므로(`0098:261-271`) 같은 트랜잭션 안에서 이 시점의 `order_status`가 조회 시점과 달라질 수는 없다 — `get diagnostics ... row_count`/0건 분기는 Human이 명시적으로 요구한 방어적 구현이며, 락이 어떤 이유로든 우회되는 미래의 코드 변경에 대비한 안전망 역할을 한다.

### §2.2 이미 `CONFIRMED`인 주문 — 멱등 성공 vs 충돌 분기

```sql
if v_order.order_status = 'CONFIRMED' then
  if exists (
    select 1 from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
  ) then
    -- 같은 provider 거래의 재전송 → 멱등 성공(Rule 3/8과 동일 원칙)
    select id into v_ledger_id from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
    order by approved_at desc limit 1;

    return catchmenu_common.build_success_response(
      p_message_key := 'payment_already_confirmed_idempotent',
      p_data := jsonb_build_object('ledger_id', v_ledger_id, 'order_id', p_order_id, 'already_confirmed', true),
      p_locale := p_locale, p_correlation_id := p_correlation_id
    );
  else
    -- 다른 provider 거래가 이미 CONFIRMED인 주문에 새로 확인을 시도 → 충돌(이중 결제 의심)
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;
end if;
```
이 분기는 §3(Rule 3)의 기존 멱등성 검사(`p_correlation_id is not null`일 때만 작동, `0098:224-230`)와 별개로 **항상** 작동한다 — Human의 "이미 CONFIRMED인 주문에 같은 provider 거래가 재전송되면 에러가 아니라 멱등 성공"이라는 지시는 `correlation_id` 유무를 조건으로 걸지 않았으므로, `order_status` 기반의 이 분기가 §3의 검사보다 먼저(또는 독립적으로) 실행되도록 배치한다.

**남는 사각지대(정직하게 기록, §8 Open Item)**: 이 멱등 성공 분기는 `order_status = 'CONFIRMED'`일 때만 작동한다 — Human의 지시문을 문자 그대로 구현한 결과다. 주문이 이미 `COOKING`/`READY`/`SERVED`/`COMPLETED`로 더 진행된 뒤(정상적인 시간 경과) 같은 provider 거래가 뒤늦게 재전송되면, 이 분기의 조건(`order_status = 'CONFIRMED'`)에 걸리지 않고 §2.1의 "단순 거부"로 빠진다 — 정당한 웹훅 재전송인데도 에러를 받게 되는 경우가 이론상 있다. 이 문서는 이를 임의로 넓히지 않고 Open Item으로만 기록한다.

## §3 Rule 3 구현 설계 — 멱등성 체크가 `CANCELLED` 여부와 무관하게 항상 먼저 실행되는지 재확인

`0098:224-230`(재확인, 변경 없음)의 기존 멱등성 검사:
```sql
if p_correlation_id is not null then
  if exists (
    select 1 from catchmenu_payment.payment_ledger
    where store_id = p_store_id and tenant_id = p_tenant_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
  ) then
    return error 'payment_already_confirmed';
  end if;
end if;
```
**순서 재확인 결과**: 이 검사는 함수 최상단(주문 조회보다도 앞, `0098:224` — 주문 조회는 `0098:261`)에 있어 이미 "가장 먼저" 실행된다 — 순서 자체는 문제가 없다. **문제는 순서가 아니라 조건**이었다(Revision 1에서 이미 지적) — `ledger_status = 'APPROVED'`만 확인하므로 `CANCELLED`로 바뀐 뒤의 재전송을 잡지 못한다. §2.2에서 `order_status = 'CONFIRMED'`인 경우의 재전송을 별도로 처리하도록 설계했으므로, 이 기존 검사(§3)는 **`order_status`가 아직 `PENDING`인 상태에서 provider 거래가 중복 전송되는 경우**(예: 웹훅이 짧은 시간 안에 두 번 도착, 아직 `PENDING → CONFIRMED` 전이가 완료되기 전에 두 번째 전송이 도착)를 계속 담당한다 — §2.1/§2.2와 역할이 겹치지 않고 상호 보완적이다. 이 검사의 조건(`ledger_status='APPROVED'`)과 위치는 그대로 두고, §2.1/§2.2를 추가로 배치하는 것으로 Rule 3을 충족한다 — 기존 검사 자체를 재작성할 필요는 없다.

## §4 Rule 4/5 최종 구현 설계 — 취소된 주문에 늦은 승인이 도착하는 경우, `reconciliation_status` 기존 값 재사용으로 확정

```sql
if v_order.order_status in ('CANCELLED', 'REFUNDED', 'PARTIAL_REFUNDED') then
  -- 규칙 4: 결제 사실은 원장에 기록하되 orders/kds_tickets는 건드리지 않음
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id, order_id, session_id,
    intent_id, ledger_entry_type, provider_type, provider_payment_key,
    provider_approval_number, provider_approved_at, provider_response_id,
    approved_amount, net_amount, ledger_status,
    reconciliation_status,
    approved_at, business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_order_id, v_order.session_id,
    v_intent_id, 'APPROVAL', p_provider_type, p_provider_tx_id,
    p_provider_approval_number, now(), v_provider_response_id,
    p_approved_amount, p_approved_amount, 'APPROVED',
    'MANUAL_REVIEW',   -- 규칙 5: 기존 값 재사용, 아래 참고
    now(), v_business_day, v_timezone
  )
  returning id into v_ledger_id;

  -- orders/kds_tickets UPDATE 없음(규칙 4)

  return catchmenu_common.build_error_response(
    p_error_key := 'payment_approved_after_order_cancelled',
    p_data := jsonb_build_object('ledger_id', v_ledger_id, 'order_status', v_order.order_status),
    p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_rpc_name := 'confirm_payment'
  );
end if;
```

**`reconciliation_status` 재검토 결과 — 신규 값 불필요, 기존 값 재사용으로 확정**: `chk_ledger_reconciliation` CHECK 제약을 이번 턴에 재확인한 결과, 허용값은 여전히 `PENDING`/`MATCHED`/`MISMATCH`/`MANUAL_REVIEW`/`RESOLVED` 5개뿐이다. Revision 1이 예시로 들었던 `'PAYMENT_RECEIVED_AFTER_ORDER_CANCEL'`(신규 값)은 **채택하지 않는다** — 기존 값 `MANUAL_REVIEW`("수동 검토 필요")가 "취소된 주문에 결제가 뒤늦게 승인됨, 담당자가 void/환불 여부를 판단해야 함"이라는 상황을 의미상 정확히 포괄한다. 이 상황이 왜 `MANUAL_REVIEW`가 됐는지의 **구체적 사유는 `reconciliation_status` 컬럼이 아니라 다른 곳에 남긴다** — `payment_events`/`catchmenu_ledger.events` INSERT의 `event_payload`(jsonb, 자유 형식)에 `'reason', 'payment_approved_after_order_cancelled'` 같은 키를 추가하는 방식이면 스키마 변경 없이 원인을 그대로 보존할 수 있다(구체 페이로드 설계는 TestPlan 단계). **결론: `chk_ledger_reconciliation` CHECK 확장도 불필요.**

## §5 Rule 2 재확인 결과 — 변경 없음 (Claude Code 확인 완료, 그대로 반영)

Revision 1의 조사와 결론을 그대로 유지한다: `confirm_payment()`(`0098`) 전체에서 `order_status` 대입이 일어나는 지점은 성공 시(`PENDING → CONFIRMED`/`COOKING`) 단 한 곳뿐이며, 어떤 조기 반환 경로도 `order_status`를 `CANCELLED`로 설정하지 않는다 — "결제 시도 실패가 주문 취소를 유발"하는 코드 경로는 `confirm_payment()`에 없다. `order_status = 'CANCELLED'`는 오직 `cancel_payment()`(`0037`)의 명시적 호출, 또는 `request_refund()`(`0098:987`, 별도 기존 결함)에서만 발생한다. 재시도 시 새로운 결제 시도 단위가 필요하다는 Rule 2의 실질 요구는 `payment_intents`(`600550`의 `resolve_or_create_payment_intent()`)가 이미 충족하고 있다 — **이번 워크패킷에서 Rule 2를 위해 추가로 구현할 것은 없다.**

## §6 Rule 8 재확인 — 변경 없음, Rule 1로 자연히 해소됨

§2.1/§2.2의 게이트는 `provider_tx_id`/`provider_payment_key` 값 자체가 아니라 `v_order.order_status`로 1차 판정하므로("새 거래번호"라는 사실은 판정에 영향 없음), "새로운 provider 거래번호라는 이유만으로 취소 주문의 재확인을 허용하지 않는다"는 규칙 8은 별도 구현 없이 충족된다.

## §7 Rule 6/7(`reopen_order()`) — Open Item으로 이월 확정 (Human 결정, 옵션 비교 종료)

**Revision 1의 옵션 A/B 비교는 종료됐다** — Human이 옵션 B(이번 워크패킷에서 완전 제외)를 확정했다. 이번 워크패킷은 다음 두 가지만 산출한다:

1. **정책 명시(코드로 강제됨)**: §2.1/§2.2/§4의 게이트가 이미 "`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED` 주문은 `confirm_payment()`로 복구 불가능"하다는 정책을 코드 수준에서 강제한다 — 이것으로 정책 자체는 이번 워크패킷 산출물에 포함된다. `reopen_order()`라는 **복구 수단의 부재**만 별도 워크패킷으로 이월되는 것이다.
2. **프론트엔드 UI 문구 권고**(구현 아님, Open Item으로 기록): `confirm_payment()`가 `order_not_confirmable`/`payment_approved_after_order_cancelled` 에러를 반환할 때, 직원 앱/POS 화면에 아래와 같은 안내 문구를 표시할 것을 권고한다 — "취소된 주문입니다. 결제 확인으로 복구할 수 없습니다. [새 주문 만들기]". 이 문구의 정확한 톤/번역/버튼 동작은 이 문서가 결정하지 않으며, Flutter/클라이언트 코드 변경은 이번 워크패킷(`.sql`만 다루는 SQL 레이어 워크패킷) 범위 밖이다.

## §8 Open Items

(a) **신규** — §2.2의 멱등 성공 분기가 `order_status = 'CONFIRMED'`인 경우만 다루고 `COOKING`/`READY`/`SERVED`/`COMPLETED`로 더 진행된 뒤의 정당한 재전송은 처리하지 못하는 사각지대(§2.2 "남는 사각지대") — Human 지시를 문자 그대로 구현한 결과이며, 이 문서는 임의로 범위를 넓히지 않았다. 실제 웹훅 재전송 지연이 이 사각지대에 도달할 빈도가 운영상 유의미한지는 라이브 운영 데이터가 쌓인 뒤 판단할 사안.
(b) §1.2에서 언급한 더 엄격한 동시성 보호(`version` 컬럼 기반 낙관적 잠금)의 필요성 — 이번 워크패킷은 불필요로 판단했으나, `600560`류의 동시성 워크패킷에서 재검토 여지.
(c) §4의 "자동 void/refund" 메커니즘(규칙 5 후반부, PG/VAN에 실제 취소·환불 API를 자동 호출하는 부분) — 이 문서는 "reconciliation 대상으로 표시(`MANUAL_REVIEW`)"까지만 설계했고, 자동화는 설계하지 않았다. `600570_Overview.md`가 별도로 다루는 PG/VAN 대사 감사 요구사항과 연결될 가능성.
(d) §7의 UI 문구 권고를 실제 Flutter/클라이언트 코드에 반영하는 작업 — SQL 레이어 워크패킷 범위 밖, 별도 프론트엔드 작업으로 이월.
(e) `reopen_order()` 자체의 설계(권한/사유/버전 검사/재고·쿠폰·포인트·대기열 복원 조건, `600582_Logic.md` §0 원문의 상세 조건 목록) — 완전히 별도 워크패킷, 이번 문서는 존재만 기록.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md` — 이 문서의 직접 전제(§1.1/§2/§5의 근본 원인 분석).
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` §6.1 — `payment_intents` 재시도/복수 intent 이력 전제, §5(Rule 2)의 근거.
- `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md` §5 — `request_refund()`가 `order_status`를 무조건 `CANCELLED`로 설정하는 별도 결함, §5에서 인용.

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`(게이트/멱등성 검사/조건부 UPDATE 삽입 대상, `0098:224-230`/`261-271`/`283-295`/`463` 부근).
- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`(참고, 이번 워크패킷의 직접 수정 대상 아님).
- `catchmenu_pos.orders`의 `chk_order_status` CHECK 제약(라이브 재확인, 변경 없음으로 확정).
- `catchmenu_payment.payment_ledger`의 `chk_ledger_reconciliation` CHECK 제약(라이브 재확인, 변경 없음으로 확정, `MANUAL_REVIEW` 재사용).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- `reopen_order()` 설계 전체(§7/§8 (e)) — 완전히 별도 워크패킷.
- PG/VAN 자동 void/refund API 호출 메커니즘(§8 (c)) — 범위 밖.
- 프론트엔드 UI 문구 구현(§8 (d)) — SQL 레이어 워크패킷 범위 밖.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**최종 확정(Revision 2, Human 결정 전부 반영).** §0.1에서 Rule 1 = 옵션 1a(`PENDING` 재사용, 스키마 변경 없음) 채택과 책임 분리 원칙(`orders.order_status` = 주문 생명주기, `payment_intents.intent_status` = 결제 시도 생명주기)을 확정했다. **§1.4에서 "Overview 갱신 필요" Open Item이 해소됐음을 명시했다** — Rule 1도 Rule 4/5도 기존 CHECK 값만으로 구현되므로 스키마 변경이 없다. §2에서 Rule 1의 정확한 조건부 UPDATE(`WHERE order_status='PENDING'`, 영향행 확인)와 이미 `CONFIRMED`인 주문에 대한 멱등 성공/충돌 분기(§2.2)를 구체화했다 — 문자 그대로 구현한 결과 생기는 사각지대(`COOKING` 이후 재전송)를 정직하게 Open Item으로 남겼다. §3에서 기존 멱등성 검사의 위치는 이미 최상단이었음을 재확인하고(순서 문제 아님, 조건 문제였음) §2와의 역할 분담을 명확히 했다. §4에서 `reconciliation_status` 신규 값이 불필요함을 최종 확정했다(`MANUAL_REVIEW` 재사용, 구체 사유는 `event_payload`에 보존). §5/§6은 Revision 1 그대로 유지(Rule 2 구현 불필요, Rule 8은 Rule 1로 자연히 해소). **§7에서 Rule 6/7(`reopen_order()`)을 Open Item으로 명확히 이월했다** — 정책 자체는 이번 워크패킷의 게이트로 이미 강제되며, 복구 수단(`reopen_order()`)과 UI 문구만 별도로 남긴다. `600583_TestPlan.md`/`600584_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
