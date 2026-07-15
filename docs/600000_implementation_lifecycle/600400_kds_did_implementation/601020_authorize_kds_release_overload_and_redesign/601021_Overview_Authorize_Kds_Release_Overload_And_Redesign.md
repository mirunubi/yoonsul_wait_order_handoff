# 601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 3 — 전면 재작성. ChatGPT 옵션 1B(3개 결함 통합) 채택. Revision 2의 "옵션 a/b/c 트레이드오프만 비교, 판단 보류" 구조는 폐기 — 이번 Revision은 결정된 방향을 서술한다.

## Change ID

`authorize_kds_release_overload_and_redesign`

## §0 이 문서의 성격 — Revision 2 → 3, 결정된 방향으로 전환

Revision 2는 "게이트가 무엇을 신뢰할 것인가"를 옵션 a/b/c로 나열하고 판단을 Logic.md로 이월했다. **Human 결정(2026-07-15, ChatGPT+제미나이 교차검증, 재논의 금지)은 이 구조 자체를 기각했다** — 근거: Revision 2가 검토조차 하지 않았던 더 근본적인 문제, 즉 "`kds_status = COMMITTED`라는 **결과**로 결제 승인이라는 **원인**을 증명하려는 순환 논리"가 있었기 때문이다. COMMITTED 상태만으로는 그것이 정상 결제로 인한 것인지, 버그·테스트데이터·수동수정으로 인한 것인지 구분할 수 없다.

**확정된 방향(옵션 1B) — 3개 결함으로 재구성**:

| 결함 | 내용 | 이 문서에서의 근거 |
|---|---|---|
| 결함 1(최우선, 근본 원인) | 정상 결제 성공 경로(`confirm_payment()`/`release_kds_after_payment()`)가 `payment_ledger.kds_release_authorized`를 세팅하지 않음 | §4 |
| 결함 2(결함 1의 파생) | `bulk_commit_kds_tickets()`의 게이트 자체는 원칙적으로 옳음 — 게이트 로직은 바꾸지 않고, 결함 1이 고쳐지면 자연히 정상 통과하는지만 확인 | §4.4, §9 |
| 결함 3(신규 발견, 고위험) | `start_cooking()`이 `payment_ledger_id is null`이면 결제 검사 자체를 건너뛰는 **fail-open** 구조 — "원장 없음 = 결제 불필요"라는 암묵적 위험 정책 | §6 |

`authorize_kds_release()`(양쪽 오버로드) DROP은 여전히 확정 — "직원 클릭만으로 결제 권한을 만드는" 위험한 수동 함수라는 진단은 유효하다. 다만 이는 컬럼/개념 자체를 없애는 것이 아니라, "사람이 임의로 만드는 별도 RPC"만 제거하고 "정상 결제 흐름이 자동으로 만드는 내부 로직"(결함 1 수정)으로 대체하는 것이다.

**Slice 분할(하나의 승인 경계 안에서)**: Slice 1(권한 생산자 복구) → Slice 2(소비자 게이트 정렬/재확인 + fail-closed 전환) → Slice 3(폐기 정리). 상세 SQL 설계는 `601022_Logic.md`.

이 문서에서 **유지되는 부분**(Revision 2와 동일, 변경 없음): §1(번호 확인), §2(오버로드 배경), §3(호출 관계), §5(호출 체인), §7(특허1/2 라벨링), §8(900xxx 0건 검색). **이 문서에서 새로 추가되는 부분**: §4(결함 1의 정확한 코드 위치), §6(결함 3의 정확한 코드 위치), §10(신규 발견 — 두 번째 병렬 파이프라인의 미완성 상태, Human 결정 범위 밖 Open Item으로 별도 표시).

## §1 위치/번호 확인 (변경 없음)

지시문 제목("`601020`_...")과 최초 작업 지시 본문("600400 산하 다음 빈 번호 확인, 600440 다음")이 서로 다른 결과를 가리키는 모순을 발견, Human 확인을 거쳤다. **Human 결정(2026-07-15, 재논의 금지)**: `601020` 그대로 사용. 도메인 폴더(`600400_kds_did_implementation/`)와 번호 대역(`601000`대)의 불일치는 알려진 상태로 감수한다. 폴더 물리적 이동 논의는 별도 스레드로 보류 중 — 이 문서는 현재 물리적 위치를 그대로 다룬다.

## §2 배경 재확인 — `authorize_kds_release()` 2개 오버로드 (변경 없음)

| | `0028`(6-param) | `0063`(8-param) |
|---|---|---|
| 조회 기준 | `p_ledger_id`(`payment_ledger.id` 직접) | `p_order_id`(`orders.id` + `ledger_status='APPROVED'` 조인) |
| 권한 검사 | 없음(`p_actor_type default 'SYSTEM'`) | 있음 — `p_authorized_by_type IN ('MANAGER','OWNER','SYSTEM','HQ_ADMIN')` 아니면 `insufficient_authority` 반환 |
| 컬럼 세팅 | `0028` L456-458: `kds_release_authorized = true, ..._at = now(), ..._by = p_actor_type` | `0063` L874-876: `kds_release_authorized = true, ..._by = p_authorized_by_id, ..._at = now()` |
| 호출자 | 0건(재확인) | 0건(재확인) |

## §3 `release_kds_after_payment()`가 `authorize_kds_release()`를 호출하는가 (변경 없음)

**답: 아니오.** `release_kds_after_payment()`(`0098`)의 라이브 본문 전체에 `authorize_kds_release` 문자열이 0회 등장한다. 이 함수는 `authorize_kds_release()`를 전혀 거치지 않고 `kds_tickets`를 직접 `UPDATE`한다 — 다만 그 UPDATE가 세팅하는 것은 `kds_tickets.conditions_met`(JSON)의 동명 키이지, `payment_ledger.kds_release_authorized`(테이블 컬럼)가 아니다. 바로 이 간극이 결함 1이다(§4).

## §4 결함 1 — 정상 결제 확정 경로의 정확한 코드, 정확한 삽입 지점

### §4.1 `confirm_payment()`(`0098` L144-458) — 결제 승인이 확정되는 정확한 지점

라이브 코드 재확인(L305-331): 결제 승인은 아래 `INSERT`가 `ledger_status = 'APPROVED'`로 커밋되는 순간 확정된다.

```sql
-- L306-331 (0098)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, session_id,
  provider_type, payment_method,
  provider_tx_id,
  provider_approval_number,
  approved_amount, fee_amount, net_amount,
  ledger_status,
  approved_at,
  provider_response,
  reconciliation_status,
  business_day, business_timezone
) values (
  ...,
  'APPROVED',
  now(),
  ...
)
returning id into v_ledger_id;
```

`kds_release_authorized`는 이 컬럼 목록에 없으므로, 이 INSERT로 생성되는 `payment_ledger` 행은 테이블 기본값(`false`)으로 남는다. 이 INSERT 직후(L333-342, 주문 상태 갱신) `v_ledger_id`를 인자로 `release_kds_after_payment()`가 호출된다(L348-356):

```sql
-- L344-356 (0098)
-- ==========================================
-- 특허2 핵심: KDS Late Binding 해제
-- HOLD → COMMITTED (조리 시작 승인)
-- ==========================================
v_kds_result :=
  catchmenu_payment.release_kds_after_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_ledger_id := v_ledger_id,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
```

### §4.2 `release_kds_after_payment()`(`0098` L466-582) — 정확한 삽입 지점

이 함수는 이미 `p_ledger_id`를 파라미터로 받고 있고(L471), 함수 자신의 소스 주석이 명시하는 책임("특허2 핵심 함수", `900101` §2.4의 "SYSTEM 전용" 자동 릴리즈 경로)이 정확히 "결제 확인 → KDS 릴리즈"이므로, **이 함수 내부가 컬럼 세팅의 정확한 삽입 지점이다** — `confirm_payment()`의 INSERT문(Layer 1 원장 기록)을 건드릴 필요가 없다.

현재 코드(L501-529, `kds_tickets` UPDATE만 존재):

```sql
-- 현재 (0098 L501-529)
-- HOLD 티켓 → COMMITTED (조리 시작)
-- conditions_met 업데이트:
--   payment_confirmed = true
--   kds_release_authorized = true   -- ← 이것은 kds_tickets.conditions_met의 JSON 키일 뿐,
--                                       payment_ledger.kds_release_authorized(테이블 컬럼)가 아님
with released as (
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COMMITTED',
    conditions_met = jsonb_build_object(
      'payment_confirmed', true,
      'kds_release_authorized', true,
      'payment_ledger_id', p_ledger_id,
      'released_at', now()
    ),
    committed_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and kds_status = 'HOLD'
  returning id
)
select count(*), coalesce(jsonb_agg(to_jsonb(id)), '[]'::jsonb)
into v_released_count, v_ticket_ids
from released;
```

**정확한 삽입 지점**: 위 `with released as (...)` 블록 **직전**(L501 앞, 함수 본문의 KDS 용량 재확인(L493-499) 이후) — `payment_ledger`에 대한 `UPDATE`를 한 문장 추가한다:

```sql
-- 신규 삽입 (정확한 위치: L500 직후, kds_tickets UPDATE 직전)
update catchmenu_payment.payment_ledger
set
  kds_release_authorized = true,
  kds_release_authorized_at = now(),
  kds_release_authorized_by = 'SYSTEM'
where id = p_ledger_id
  and tenant_id = p_tenant_id
  and store_id = p_store_id;
```

이 위치를 택한 이유(사실 근거, 판단 아님): (1) `p_ledger_id`가 이미 파라미터로 존재해 추가 조회가 불필요하다, (2) 이 함수 자신이 "결제 확인 시점에 KDS 릴리즈 권한을 확정한다"는 책임을 이미 지고 있다(소스 주석·900101 §2.4와 일치), (3) `confirm_payment()`의 INSERT문(Layer 1 원장 기록)은 결제 자체의 기록이 책임이고 KDS 관련 권한 부여는 이 함수(Layer 2, KDS 전용)의 책임으로 남기는 것이 관심사 분리 원칙에 부합한다. (4) 같은 함수 호출 내에서 `kds_tickets` UPDATE와 `payment_ledger` UPDATE가 함께 실행되므로, 두 UPDATE는 이 함수를 감싸는 단일 트랜잭션(`security definer` 함수 호출) 안에서 원자적으로 처리된다 — "권한 생성이 결과보다 먼저 오도록" 한다는 Human 요구가 정확히 이 순서(권한 UPDATE 먼저, `kds_tickets` COMMITTED UPDATE 나중)로 충족된다.

## §5 실제 호출 체인 재확인 — `release_kds_after_payment()`는 어디서 트리거되는가 (변경 없음)

`release_kds_after_payment()`(`0098`)의 유일한 호출자는 `confirm_payment()`(`0098` 내 정의)이며, 이 `confirm_payment()`는 3개의 실제 라이브 결제 통합 함수(`0102` OKPOS, `0103` Toss Payments, `0104` Toss POS)에서 `v_result := catchmenu_payment.confirm_payment(...)` 형태로 실제 호출된다. **결함 1 수정은 이 3개 경로(카드/PG 결제) 모두에 자동으로 적용된다** — `confirm_payment()`를 개별 수정할 필요 없이, 공통으로 호출하는 `release_kds_after_payment()` 한 곳만 고치면 된다.

## §6 결함 3 — `start_cooking()`의 fail-open 구조, 정확한 코드 재확인

`start_cooking()`(`0029` L15-95)의 게이트 로직 전체(L65-79, 이번 재작성에서 재확인):

```sql
-- 현재 (0029 L65-79)
-- verify payment_ledger kds_release_authorized
if v_ticket.payment_ledger_id is not null then
  if not exists (
    select 1
    from catchmenu_payment.payment_ledger
    where id = v_ticket.payment_ledger_id
      and kds_release_authorized = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_not_authorized',
      'message', 'payment_ledger.kds_release_authorized must be true'
    );
  end if;
end if;
-- (조건문이 여기서 끝남 — payment_ledger_id가 null이면 위 if 블록 전체를 건너뛰고
--  곧바로 L81의 COMMITTED → COOKING UPDATE로 진행됨)
```

**fail-open의 정확한 지점**: `if v_ticket.payment_ledger_id is not null then ... end if;` — 이 바깥쪽 `if`가 "게이트를 적용할지 말지"를 결정한다. `payment_ledger_id`가 `null`인 티켓은 이 `if` 자체가 거짓이 되어 안쪽의 `kds_release_authorized` 검사를 **아예 실행하지 않고** L81-87의 `COMMITTED → COOKING` UPDATE로 직행한다. 이것이 "결제 원장이 없으면 결제 불필요로 간주"하는 암묵적 정책이다.

`kds_tickets.payment_ledger_id`는 라이브 스키마상 `nullable`(재확인) — 티켓 생성 시점에는 `null`이다. **정정(Cursor+Codex 발견, 이번 턴 재확인)**: `release_kds_after_payment()`는 `kds_tickets.payment_ledger_id` 컬럼을 갱신하지 않는다 — 이 컬럼은 `confirm_payment_from_provider()`(`0027` L306, §10)를 통해서만 채워진다. `release_kds_after_payment()`(`0098` L512)가 다루는 `'payment_ledger_id', p_ledger_id`는 `conditions_met`(JSON) 안의 동명 키일 뿐, `kds_tickets` 테이블의 `payment_ledger_id` 컬럼(FK, `0016` 정의)과는 무관하다 — §3/§4.2에서 이미 확인한 "컬럼과 동명 JSON 키의 혼동" 패턴이 이 자리에도 반복되어 있었다. 즉 "아직 결제 확인 경로를 한 번도 거치지 않은 티켓"과 "애초에 결제가 필요 없는 티켓"이 현재 코드상 **구분 불가능**하며, 둘 다 `start_cooking()`을 통과한다.

## §7 특허1/2 라벨링이 공식 설계 문서와 불일치 (변경 없음)

- `release_kds_after_payment()`(`0098` L364-365) 자신의 소스 주석: "특허2 핵심 함수 / KDS Late Binding 해제".
- `900100_Overview_...md`("핵심 비즈니스 클레임", 직접 인용): `Patent 1: Wait/Order Handoff`(대기~착석 세션 추적), `Patent 2: KDS Late Binding`(결제 확인 전 HOLD 유지) — `release_kds_after_payment()`는 명백히 Patent 2 구현체다.
- `authorize_kds_release()`(`0028`) 자신의 소스 주석(직접 인용): "특허1: 결제 승인 ≠ KDS 자동 릴리즈. 별도 authorize 단계 필수." — 이 "특허1" 정의는 900xxx 공식 문서 어디에도 없다(§8). **신규 확인(§10)**: 이 정확히 같은 문구가 `confirm_payment_from_provider()`(`0027` L271)에도 등장한다 — "특허1"이라는 라벨링이 `authorize_kds_release()` 하나만의 오기(誤記)가 아니라, `0027`/`0028` 두 파일에 걸쳐 일관되게 쓰인 (문서화되지 않은) 내부 설계 개념이었을 가능성을 시사한다.

## §8 900xxx 설계 문서 전수 검색 — 0건 (변경 없음)

`docs/900000_patent_and_handoff_package/` 전체 재검색: `authority_kds_release` 0건, `"수동 승인"`/`"manual approv"` 0건, `start_cooking` 0건, `bulk_commit_kds_tickets` 0건. `900101_Logic_...md` §1.2의 상태 전이 다이어그램은 `transition_kds_ticket()`(라이브 미구현, `0113` 스펙에만 존재)을 언급하며, 이 스펙 자체도 `kds_release_authorized` 컬럼이나 별도 authorize 단계를 언급하지 않는다.

## §9 결함 2 — `bulk_commit_kds_tickets()`의 게이트는 그대로 유지, 자연 해결만 확인

`bulk_commit_kds_tickets()`(`0039` L37-53)의 게이트(재확인, 변경 없음):

```sql
-- 0039 L37-53 (변경 없음, 이번 워크패킷에서 로직 자체는 수정 안 함)
select coalesce(bool_or(kds_release_authorized), false)
into v_payment_authorized
from catchmenu_payment.payment_ledger
where order_id = p_order_id
  and store_id = p_store_id
  and tenant_id = p_tenant_id
  and ledger_status = 'APPROVED';

if not v_payment_authorized then
  return jsonb_build_object(
    'success', false,
    'error_key', 'kds_release_not_authorized', ...
  );
end if;
```

Human 판단: 이 게이트는 원칙적으로 옳다(결제 원장 검증 자체가 맞는 방향) — 결함 1이 고쳐지면(§4) `confirm_payment()`/`release_kds_after_payment()` 경로로 확정된 주문은 `payment_ledger.kds_release_authorized = true`가 되므로 이 게이트를 자연히 통과한다. **이 문서는 이 게이트 로직을 변경하지 않는다.** `601022_Logic.md`에서 "자연 해결"을 실제로 확인하는 테스트 계획을 다룬다.

**단, §10의 신규 발견은 이 "자연 해결"이 결제 경로 전부에 적용되지는 않는다는 것을 보여준다.**

## §10 신규 발견 — 두 번째 병렬 결제 파이프라인(`0027`)의 `kds_release_authorized` 처리, 이번 Human 결정 범위 밖 Open Item

이 세션에서 반복 확인된 사실: `confirm_payment()`(`0098`, `0102`/`0103`/`0104` 호출)와 `confirm_payment_from_provider()`(`0027`/`600510`, `0038` Toss 웹훅 + `0056` VAN 호출)는 완전히 별개의, 병렬로 존재하는 두 결제 확인 파이프라인이다. 이번 재작성에서 `0027`의 실제 코드를 재확인한 결과, **결함 1과 구조적으로 유사하지만 별개인 문제**가 있다.

`0027` L267-289(라이브 재확인):

```sql
-- 0027 L267-289
insert into catchmenu_payment.payment_ledger (
  ...
  reconciliation_status,
  -- 특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용
  -- kds_release_authorized starts FALSE
  kds_release_authorized,
  business_day, business_timezone,
  approved_at
) values (
  ...
  'PENDING',
  false,
  ...
)
returning id into v_ledger_id;

-- update KDS tickets: set payment_confirmed = true in conditions_met
-- but kds_status stays HOLD until capacity check
update catchmenu_kds.kds_tickets
set
  conditions_met = conditions_met || jsonb_build_object('payment_confirmed', true),
  payment_ledger_id = v_ledger_id,
  updated_at = now()
where order_id = v_intent.order_id
  and kds_status in ('HOLD', 'CAPACITY_CHECKING');
```

이 함수는 **명시적으로, 의도적으로** `kds_release_authorized = false`를 INSERT 시점에 세팅한다(주석: "특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용" — §7에서 확인한 `authorize_kds_release()`의 주석과 동일한 문구). 동시에 `kds_tickets.payment_ledger_id`는 이 시점에 채워지지만(§6의 fail-open 조건에서 `not null`이 되는 케이스), `kds_status`는 `HOLD`에 머문다(주석: "kds_status stays HOLD until capacity check").

**재확인한 사실 — 이후 아무것도 이 티켓들을 커밋하지 않는다**: `0038`(Toss 웹훅 핸들러)과 `0056`(VAN 핸들러) 양쪽 모두, `confirm_payment_from_provider()` 호출 이후 `kds_status`/`bulk_commit`/`commit_kds_ticket`/`CAPACITY_CHECKING` 관련 코드가 **전혀 없다**(전수 grep 재확인). 즉 이 파이프라인(Toss 웹훅 + VAN)을 통해 결제가 확인된 주문의 KDS 티켓은, `payment_ledger_id`는 채워지지만(`start_cooking()`의 fail-open 조건을 회피하게 됨 — §6과 연결) `kds_status`가 `HOLD`에서 한 발짝도 나아가지 않는다 — **현재 이 파이프라인은 완결되지 않은 상태다.**

**이것이 왜 결함 1과 다른, 별개의 문제인가**: 결함 1(§4)의 수정은 `release_kds_after_payment()`(`0098` 경로) 안에서만 이뤄진다. `0027`의 INSERT는 별개의 코드이며, 결함 1 수정이 여기에는 영향을 주지 않는다 — Slice 1(§4의 수정)을 배포해도, Toss 웹훅/VAN으로 확인된 주문은 여전히 `kds_release_authorized = false`로 남고, 여전히 `bulk_commit_kds_tickets()`를 통과하지 못한다(어차피 그 함수 자체가 호출되는 곳도 없어 현재는 영향이 드러나지 않지만).

**이 문서의 판단**: 이 발견을 Human의 현재 결정("정상 결제 확정 경로 안에서, 결제 승인이 확정되는 바로 그 지점")이 명시적으로 `confirm_payment()`/`release_kds_after_payment()`(0098 경로)를 지칭했다는 점에서, **이번 워크패킷의 확정된 3개 결함 범위에 포함되지 않는 것으로 판단**하고 임의로 범위를 확장하지 않는다. 다만 이는 "재논의"가 아니라 새로 확인된 사실이므로, Open Item으로 명시적으로 기록한다(§11 (a)) — Slice 1이 "정상 결제 흐름 전체"의 근본 원인을 해결한다고 보고할 경우, 이 발견을 근거로 그 표현은 부정확함을 분명히 한다: **Slice 1은 두 개의 병렬 결제 파이프라인 중 하나(`confirm_payment()`/카드·PG 3사 경로)만 고친다.**

## §11 Open Items (갱신)

(a) **신규, 우선순위 높음** — `confirm_payment_from_provider()`(`0027`, Toss 웹훅/VAN 경로)가 결함 1과 동일한 문제를 별도로 갖고 있으며, 게다가 이 경로로 확인된 주문의 KDS 티켓은 현재 `HOLD` 상태에서 전혀 진행되지 않는다(커밋 로직 자체 부재). Slice 1은 이 경로를 고치지 않는다. 별도 워크패킷 필요 여부는 Human 결정 사항.

**(a)-1 별도 워크패킷 착수 시 필수 요구사항(Human 결정, 2026-07-15, 실무 경험 기반 — 이번 워크패킷 범위에는 포함하지 않고 기록만 함)**:

이 파이프라인(PG/VAN 웹훅 경로)은 다른 파이프라인과 다른 특수한 위험을 갖는다 — PG/VAN사가 체크섬/정산 대사(reconciliation)를 지금 당장이 아니라 1주일/1달/심지어 연말에 요청할 수 있다. 이때 그 시점의 거래를 완전히 재구성할 수 있어야 하며, 그러지 못하면 전체 데이터베이스를 수동으로 뒤져야 하는 상황이 발생할 수 있다(Human의 과거 ERP 프로젝트 실경험 — 10원 오차 하나 찾는 데 1년치 DB 전체를 뒤진 사례).

따라서 이 워크패킷 착수 시 다음을 필수 요구사항으로 포함해야 한다:

1. 모든 PG/VAN 웹훅 수신 시 완전한 append-only 감사 기록(`append_audit_record` 활용, §41 원칙).
2. 외부(PG/VAN)에서 오는 입력에 대한 샌드박스/검증 강화 — 이 경로가 카드사/VAN사로부터 직접 데이터를 받는 만큼, 위변조/재전송 공격 가능성에 대한 방어 필요.
3. 나중에(수개월 후) 특정 거래 하나를 추적할 수 있는 최소 요건: 정확한 금액, 정확한 provider 참조번호(`approval_number` 등), 정확한 타임스탬프, `correlation_id` 전부가 하나의 불변 레코드에 함께 남아야 함.
4. 이 요구사항은 결함 1(`confirm_payment`/`release_kds_after_payment`, 현재 워크패킷)에는 적용하지 않음 — 그쪽은 고객앱 직접 결제 경로라 PG/VAN 사후 대사 위험이 상대적으로 낮음.
(b) `confirm_payment_from_provider()`와 `confirm_payment()` 두 파이프라인이 왜 병렬로 존재하는지, 어느 쪽이 실제 운영 중인 주 경로인지 — 여전히 미해결.
(c) 현금/무료증정 등 비카드 결제의 `start_cooking()` fail-closed 전환 이후 취급 방식 — Human 지시상 이번 워크패킷에서 설계하지 않음(§6, Logic.md §Slice 3에서 Open Item으로 명시).
(d) `COMMITTED → COOKING` 전이를 수행하는 라이브 경로가 `start_cooking()`(호출자 0건) 외에 사실상 없다는 공백 — 이번 워크패킷 범위 밖으로 유지.
(e) `0063`의 권한 검사 로직 재사용 여부 — DROP 확정으로 실익이 줄었으나 참고 기록 유지.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `900100_Overview_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md`(Patent 1/2 공식 정의)
- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md`(§2.4 SYSTEM 전용 제약, §1.2 상태 전이 다이어그램)

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`(L144-458)/`release_kds_after_payment()`(L466-582), 결함 1의 정확한 삽입 지점(§4).
- `sql/migrations/0029_create_kds_cooking_rpc.sql` — `start_cooking()`(L15-95), 결함 3의 정확한 fail-open 코드(§6).
- `sql/migrations/0039_create_kds_bulk_commit_rpc.sql` — `bulk_commit_kds_tickets()`, 결함 2의 게이트(변경 없음, §9).
- `sql/migrations/0028_create_kds_capacity_commit_rpc.sql`/`0063_patch_core_rpc_i18n_diagnostics.sql` — DROP 대상 `authorize_kds_release()`.
- `sql/migrations/0027_create_payment_intent_rpc.sql` — `confirm_payment_from_provider()`, §10 신규 발견의 근거(L267-331).
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`/`0056_*.sql` — `confirm_payment_from_provider()`의 실제 호출자, §10의 "커밋 로직 부재" 확인 근거.

### Domain Indexes

- `600402_NavigationMap.md`.
- `000053_Matrix_Domain_To_Artifact_Traceability.md`.

### Excluded Rule Families

- §10에서 발견됐지만 이번 워크패킷 범위에 포함되지 않는 `confirm_payment_from_provider()` 파이프라인 자체의 수정 — Open Item (a)로만 기록.
- 폴더 물리적 이동 논의 — 별도 스레드, 보류.
- `601010_cms_device_content_routing_architecture` — 도메인 무관.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**재작성 확정, 방향 확정(Revision 2와 달리 이번엔 판단 보류 없음).** §0에서 옵션 1B(3개 결함) 채택을 확정했다. §4에서 결함 1의 정확한 코드 위치와 삽입 지점(`release_kds_after_payment()` L500 직후, `payment_ledger` UPDATE 추가)을 특정했다. §6에서 결함 3의 정확한 fail-open 코드(L65-79의 바깥쪽 `if v_ticket.payment_ledger_id is not null`)를 특정했다. §9에서 결함 2(게이트 자체는 무변경, 자연 해결만 확인)를 재확인했다. **§10에서 이번 워크패킷 범위 밖의 중대한 신규 발견**(`confirm_payment_from_provider()` 파이프라인이 동일 문제를 별도로 가지며 커밋 로직 자체가 없음)을 Human 재논의 요청 없이 사실로만 기록했다. `601022_Logic.md`(Slice 1/2/3 SQL 설계)로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
