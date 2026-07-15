# 600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`payment_confirm_cancel_state_machine_fix`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510`/`600540`/`600550`/`600560`/`600570` 5개다(재확인, `ls`). `600570`은 Stage 6 ACCEPT까지 완료됐다(`600502_NavigationMap_Payment_Confirmation.md` 재확인). 10단위 관례상 다음 빈 번호는 `600580` — 지시문의 가칭과 일치한다.

## §1 배경 재확인 — 두 재현 위험 독립 재검증

지시문은 "삼중검증 완료, 재현 데이터 확보"라고 명시했으나, 이번 세션 원칙(§43/§44)에 따라 라이브 소스 코드를 직접 재대조해 독립적으로 재확인했다.

### §1.1 위험 1 — cancel 이후 confirm 재시도 시 신규 APPROVED 원장 공존

`confirm_payment()`(`0098`)의 "이미 결제 완료" 사전 검사(`0098:283-288`, 라이브 재확인):
```sql
-- 이미 결제 완료
if exists (
  select 1 from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and ledger_status = 'APPROVED'
) then
  return catchmenu_common.build_error_response(
    p_error_key := 'payment_already_confirmed', ...
  );
end if;
```
**확인 결과**: 이 검사는 `ledger_status = 'APPROVED'`인 행이 있는지만 확인한다. `cancel_payment()`가 기존 원장을 `CANCELLED`로 바꿔놓은 상태(§2에서 확인)에서는 이 조건이 거짓이 되어 검사를 통과하고, 함수는 그대로 진행해 **새 `payment_ledger` 행을 INSERT한다**(`0098`의 INSERT 블록, `intent_id`/`ledger_entry_type` 등 `600550` 워크패킷에서 이미 정합화됨) — 배경의 주장대로 order당 `CANCELLED` 행과 새 `APPROVED` 행이 공존하게 된다.

추가로, 주문 조회(`0098:261-271`)는 `v_order.id is null`(주문 자체가 없는 경우)만 검사하며 **`order_status` 값 자체는 검사하지 않는다** — 이후 `update catchmenu_pos.orders set order_status = case order_type when 'TABLE' then 'COOKING' else 'CONFIRMED' end, confirmed_at = now(), ...`가 무조건 실행되므로, `cancel_payment()`가 이미 `order_status = 'CANCELLED'`로 바꿔놓은 주문이라도 재확인 호출 한 번으로 `CONFIRMED`/`COOKING`으로 **되돌아간다**. 배경의 "order_status가 CONFIRMED로 되돌아감" 주장도 코드로 확인된다.

### §1.2 위험 2 — `cancel_payment()`가 `payment_intents`를 전혀 갱신하지 않음

`grep -n "payment_intents" sql/migrations/0037_create_payment_cancel_refund_rpc.sql` 재실행 결과 **0건** — `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()` 어느 함수도 `payment_intents`를 조회하거나 갱신하지 않는다. `confirm_payment()`(`0098`)는 `600550` 워크패킷에서 `resolve_or_create_payment_intent()`를 통해 `payment_intents` 행을 `CONFIRMED` 상태로 만들거나 재사용하도록 이미 정합화됐다 — 그러나 이후 `cancel_payment()`가 호출돼 `payment_ledger.ledger_status = 'CANCELLED'`가 되어도, 그 결제가 참조하는 `payment_intents.intent_status`는 **영원히 `CONFIRMED`로 남는다.** 배경이 말한 "ledger=CANCELLED, intent=CONFIRMED 모순"이 코드 구조상 100% 발생함을 확인했다.

## §2 근본 원인 — `confirm_payment()`의 "이미 확인됨" 판정 기준이 너무 좁음

§1.1의 검사가 `ledger_status = 'APPROVED'`만 보는 것은, "이 주문에 대해 결제를 이미 승인한 적이 있는가"가 아니라 "이 주문에 현재 승인 **상태인** 원장이 있는가"만 확인하는 것과 같다 — 취소/환불로 상태가 바뀐 과거 이력은 이 검사의 사각지대에 있다. `600550` 워크패킷이 `intent_id` 바인딩으로 "이 결제가 어떤 intent에서 왔는가"는 정합화했지만, "이 주문에 대해 과거에 이미 결제가 있었고 그것이 취소/환불됐는가"라는 **주문 단위 원장 이력** 문제는 다루지 않았다 — `600560`(intent 레이스)/`600570`(phantom 컬럼)와도 다른, 이번 워크패킷 고유의 문제다.

## §3 `payment_intents` 상태 동기화 — 스키마 변경 없이 가능함을 확인

**질문**: `cancel_payment()`가 `intent_status`도 `CANCELLED`로 갱신해야 하는가, 아니면 다른 동기화 방식이 필요한가?

**라이브 재확인**: `payment_intents`의 `chk_intent_status` CHECK 제약(`ANY(ARRAY['CREATED','PENDING','PROCESSING','CONFIRMED','FAILED','CANCELLED','EXPIRED'])`)에 **`'CANCELLED'`가 이미 포함되어 있다.** 즉 `600550`이 `intent_origin`/`origin_reference`를 추가할 때처럼 새 컬럼이나 CHECK 값 확장이 필요 없다 — `cancel_payment()`(그리고 `partial_cancel_payment()`/`refund_payment()`)가 자신이 이미 조회해둔 `v_ledger.intent_id`를 이용해 `update catchmenu_payment.payment_intents set intent_status = 'CANCELLED' where id = v_ledger.intent_id` 형태의 UPDATE 한 줄을 추가하는 것만으로 스키마 변경 없이 해결 가능하다는 것을 확인했다. 다만 `cancel_payment()`의 현재 SELECT(`0037:43-49`)는 `intent_id`를 이미 `v_ledger` 레코드에 담고 있으므로(재확인, `select ... intent_id ... into v_ledger`) 이 값을 즉시 재사용할 수 있다 — 추가 조회조차 필요 없다.

**부분 환불/취소 시의 동기화는 별도 판단이 필요**: `partial_cancel_payment()`/`refund_payment()`(부분 취소/환불)의 경우 `ledger_status`가 `PARTIAL_CANCELLED`/`PARTIAL_REFUNDED`가 되는데, `chk_intent_status`에는 이에 대응하는 "부분" 상태값이 없다(`CREATED`/`PENDING`/`PROCESSING`/`CONFIRMED`/`FAILED`/`CANCELLED`/`EXPIRED`뿐) — 부분 취소/환불 시 intent를 그대로 `CONFIRMED`로 둘지, 아니면 CHECK 확장이 필요한 새 상태를 도입할지는 이 문서가 판단하지 않는다(§7 Open Item).

## §4 "주문당 활성 원장 최대 1개" 불변식의 DB 레벨 강제 가능성 검토

**질문**: `order_id`당 `ledger_status = 'APPROVED'`인 행이 최대 1개라는 불변식을 UNIQUE 제약 등으로 강제할 수 있는가?

**기술 검토**: PostgreSQL의 **부분 UNIQUE 인덱스(Partial Unique Index)**로 가능하다:
```sql
create unique index uq_payment_ledger_one_approved_per_order
  on catchmenu_payment.payment_ledger(order_id)
  where ledger_status = 'APPROVED';
```
이는 `order_id` 전체에 대한 유일성이 아니라 "`ledger_status = 'APPROVED'`인 행들 사이에서만" 유일성을 강제하므로, 한 주문이 `APPROVED` → `CANCELLED` → (재확인으로 인한 버그) `APPROVED`가 되는 시나리오에서 **두 번째 `INSERT`를 DB 레벨에서 직접 거부한다**(§1.1의 애플리케이션 레벨 검사가 놓친 것을 최종 방어선으로 보완) — `600560`(`payment_intent_race_condition_fix`) 워크패킷이 `idempotency_key`에 UNIQUE 제약을 추가했던 것과 동일한 카테고리의 해법이다.

**현재 라이브에 이런 제약이 없음을 재확인**: `payment_ledger`의 UNIQUE 제약/인덱스를 재조회한 결과(`pg_indexes`), 현재 `order_id` 관련 유일성 제약은 전혀 없다(`idx_payment_ledger_kds_auth`가 `(order_id, kds_release_authorized)` 부분 인덱스로 존재하지만 UNIQUE가 아님).

**주의할 부작용**: 이 부분 UNIQUE 인덱스를 추가하면, §1.1의 버그가 고쳐지지 않은 상태에서 재확인이 시도될 경우 "새 phantom 400에러"가 아니라 **"UNIQUE 위반 500에러"**로 실패 모드가 바뀔 뿐 근본 해결은 아니다 — 이 인덱스는 §1.1의 애플리케이션 레벨 수정(검사 조건 강화)과 **함께** 적용해야 의미가 있으며, 인덱스만 단독으로 추가하는 것은 §2가 지적한 근본 원인(검사 범위가 좁음)을 고치지 못한 채 에러 유형만 바꾸는 것이다 — Logic 단계에서 두 조치의 적용 순서/조합이 정해져야 한다(§7 Open Item).

## §5 "조건부 원자적 UPDATE" 방향 재정리 (ChatGPT 제안, 판단 없이 정리만)

배경이 언급한 "confirm_payment()의 APPROVED 중복 체크를 order 단위로 더 강하게" 방향을 §1.1/§2의 코드 근거와 연결하면, 최소 다음 두 갈래로 구체화된다(Logic 단계에서 옵션으로 비교할 재료, 이 문서는 선택하지 않음):

- **갈래 1 — 검사 조건 확장**: `ledger_status = 'APPROVED'`만이 아니라, "이 주문에 대해 어떤 상태로든(APPROVED/CANCELLED/PARTIAL_CANCELLED/REFUNDED 등) 원장이 이미 존재하는가"로 검사를 넓히고, 존재한다면 무조건 거부가 아니라 그 상태에 따라 다른 처리(예: CANCELLED 상태면 "이 주문은 이미 취소됨"이라는 명확한 별도 에러 키 반환, 재확인을 원천 차단하거나 명시적 재활성화 절차를 요구)를 하는 방향.
- **갈래 2 — order_status 기반 게이트**: `confirm_payment()` 진입 시 `v_order.order_status`가 이미 `'CANCELLED'`이면 즉시 거부하는 명시적 가드 추가(§1.1에서 확인한, 현재 이 검사 자체가 아예 없다는 사실이 근거) — `payment_ledger`뿐 아니라 `orders` 테이블 자체의 상태도 신뢰 기준으로 함께 쓰는 방향.

두 갈래는 배타적이지 않으며 함께 적용될 수도 있다 — Logic 단계에서 §4의 부분 UNIQUE 인덱스와 조합해 비교한다.

## §6 종합 — 이번 워크패킷이 다루는 세 가지 축

1. `confirm_payment()`의 재확인 차단 로직 강화(§1.1/§2/§5) — `payment_ledger`/`orders` 상태를 더 넓게 신뢰.
2. `cancel_payment()`(및 `partial_cancel_payment()`/`refund_payment()`)의 `payment_intents` 동기화(§3) — 스키마 변경 불필요, UPDATE 추가만으로 가능.
3. "주문당 활성 원장 최대 1개" 불변식의 DB 레벨 보강(§4) — 부분 UNIQUE 인덱스, 다만 단독 적용은 부작용 있음.

세 축 모두 `0037`/`0098` 양쪽 파일을 함께 손대야 하며, `600570`(0037 단독 correction)이나 `600550`(0098 단독 정합화)보다 범위가 넓다 — 두 파일이 서로의 상태를 인식하도록 만드는 것이 이번 워크패킷의 본질이다.

## §7 Open Questions

(a) 부분 취소/환불(`PARTIAL_CANCELLED`/`PARTIAL_REFUNDED`) 시 `payment_intents.intent_status`를 어떻게 동기화할지 — `chk_intent_status`에 대응 값이 없음(§3), CHECK 확장이 필요한지 아니면 `CONFIRMED` 유지가 맞는지는 판단하지 않았다.
(b) §4의 부분 UNIQUE 인덱스와 §1.1/§5의 애플리케이션 레벨 검사 강화 중 어느 쪽을 먼저 적용할지, 아니면 동시에 적용할지의 순서/조합 — Logic 단계 결정 사항.
(c) `confirm_payment()`가 이미 `CANCELLED`된 주문의 재확인 요청을 받았을 때 "완전히 거부"할지, 아니면 "새로운 정당한 재시도(예: 첫 결제 시도가 실패해서 취소된 뒤 고객이 다른 카드로 다시 결제하는 정상 시나리오)로 허용"할지는 순수 기술 문제가 아니라 비즈니스 정책 문제다 — 이 문서는 기술적 강제 수단(§1.1/§4)만 조사했고 정책 판단은 하지 않는다. `600570` 워크패킷이 COOKING 상태 취소를 운영 정책 문제로 유보했던 것과 같은 종류의 구분이다.
(d) `600560`(`payment_intent_race_condition_fix`)이 이미 다룬 "동시성" 문제와 이번 워크패킷의 "상태 머신 정합성" 문제가 겹치는 지점(예: 동시에 두 `confirm_payment()`가 취소된 주문에 대해 재확인을 시도하는 경우)이 있는지는 이번 문서에서 조사하지 않았다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`/`600551_Overview...md` — `confirm_payment()`의 `resolve_or_create_payment_intent()` 정합화 선례, 이번 워크패킷이 그 위에 쌓임.
- `600572_Logic_Cancel_Payment_Phantom_Column_Fix.md`/`600571_Overview...md` — `cancel_payment()`의 `updated_at` correction 선례, 이번 워크패킷이 이어서 `payment_intents` 동기화를 추가.
- `000056_Register_Concurrency_Risk.md` — `PAY-CON-003`(결제 확인과 취소/환불 경쟁)이 이 워크패킷과 인접하나 동시성이 아니라 상태 머신 정합성 문제라는 점에서 구분됨(§7 (d)).

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`의 사전 검사 블록(L283-295) 및 주문 상태 갱신부.
- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()`, `payment_intents` 갱신 추가 대상.
- `catchmenu_payment.payment_intents`의 `chk_intent_status` CHECK 제약(라이브 재확인).
- `catchmenu_payment.payment_ledger`의 인덱스 전체(`pg_indexes`, 부분 UNIQUE 인덱스 부재 확인).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- 부분 취소/환불 시 intent 상태 동기화 방식(§7 (a)) — 판단하지 않음.
- 비즈니스 정책 문제(취소된 주문의 재확인 허용 여부, §7 (c)) — 기술 조사만, 정책 판단은 범위 밖.
- `600560`과의 동시성 교차 영향(§7 (d)) — 조사하지 않음.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0(번호: `600580`)을 확정했다. §1에서 배경의 두 재현 위험(신규 APPROVED 원장 공존, `payment_intents` 미동기화)을 라이브 코드 직접 대조로 독립 재확인했다 — 둘 다 정확했다. §2에서 근본 원인(`confirm_payment()`의 재확인 차단 검사가 `ledger_status='APPROVED'`만 보고 `order_status`는 아예 확인하지 않음)을 특정했다. §3에서 `payment_intents` 동기화가 스키마 변경 없이(`chk_intent_status`에 `CANCELLED` 이미 존재) UPDATE 추가만으로 가능함을 확인했다. §4에서 부분 UNIQUE 인덱스로 "활성 원장 최대 1개" 불변식을 DB 레벨로 강제하는 것이 기술적으로 가능함을 확인하되, 단독 적용 시의 부작용(에러 유형만 바뀜)을 명시했다. §5에서 ChatGPT의 "조건부 원자적 UPDATE" 제안을 두 갈래(검사 조건 확장/order_status 게이트)로 구체화했다 — 판단하지 않았다. `600582_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
