# 600561_Overview_Payment_Intent_Race_Condition_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`payment_intent_race_condition_fix`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510`/`600540`/`600550` 3개다(재확인, `ls`). 10단위 관례상 `600550` 다음 빈 번호는 `600560` — 지시문의 가칭과 일치한다. Overview는 `600561`, Logic은 `600562`.

## §1 배경 재확인 — `resolve_or_create_payment_intent()`(`0158`)의 락 부재, 독립 재검증

지시문은 "삼중검증 완료, 재확인 불필요"라고 명시했으나, 이번 세션의 §43/§44 원칙에 따라 핵심 코드를 직접 재확인했다.

`sql/migrations/0158_confirm_payment_intent_linkage_fix.sql:177-257`(라이브 소스 직접 재확인) — "신규 생성" 분기 전문:

```sql
select count(*)
into v_candidate_count
from catchmenu_payment.payment_intents
where tenant_id = p_tenant_id
  and store_id = p_store_id
  and order_id = p_order_id
  and intent_origin = p_intent_origin
  and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
  and intent_status in ('CREATED','PENDING','PROCESSING','CONFIRMED');

if v_candidate_count > 1 then
  raise exception 'payment_intent_resolution_conflict: ...' using errcode = 'P0001';
end if;

if v_candidate_count = 1 then
  select id into v_intent_id from catchmenu_payment.payment_intents where ... order by created_at desc limit 1;
  return v_intent_id;
end if;

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, session_id, intent_status,
  payment_method, payment_channel, requested_amount, currency,
  provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone, intent_origin, origin_reference
) values (
  ...,
  'OBS-' || p_order_id::text || '-' || p_intent_origin || '-'
    || substr(md5(v_origin_reference::text), 1, 12),
  ...
)
returning id into v_intent_id;
```

**확인 결과**: `select count(*)`(line 177)에 `for update`/`for share`가 전혀 없다 — `grep -n "for update\|for share\|advisory" sql/migrations/0158*.sql` 재실행 결과 0건(§2와 별개로 이번 문서에서 재확인). `count=0`으로 판정된 두 세션이 동시에 `insert`(line 219)까지 도달할 수 있는 고전적 TOCTOU 레이스다. 배경의 기술적 진단은 정확하다.

## §2 라이브 재현 사고 — 실제 중복 행이 현재도 DB에 남아있음 (신규 발견, 긴급)

지시문이 언급한 "실제 동시 2세션 재현 테스트"의 결과물을 라이브 DB에서 직접 재확인했다:

```sql
select order_id, intent_origin, origin_reference, count(*)
from catchmenu_payment.payment_intents
group by order_id, intent_origin, origin_reference
having count(*) > 1;
```
```
               order_id               |  intent_origin  |                          origin_reference                           | count
--------------------------------------+------------------+---------------------------------------------------------------------+-------
 33333333-3333-3333-3333-333333333333 | POS_SYNTHESIZED | {"source": "pay_con002_race_test", "provider_tx_id": "RACE-TX-001"} |     2
```
두 행의 `created_at`은 `2026-07-15 15:57:55.728129+00`/`2026-07-15 15:57:55.789718+00` — **61밀리초 간격**으로 실제 중복 생성됐다. `payment_intents` 테이블 전체 행 수는 현재 5건뿐이며, 그중 2건(테스트 재현분)과 3건(다른 테스트 시나리오, `order_id` 전부 `22222222.../33333333.../44444444...` 같은 합성 UUID)이 **전부 오늘 세션의 테스트 산출물**로 보인다 — 실제 운영 데이터가 아니다.

**이것은 "재현 테스트 결과 보고"가 아니라 현재 라이브 DB에 남아있는 실제 오염이다.** 이번 워크패킷 범위(Overview/Logic 설계, `.sql` 생성 금지)에서는 정리하지 않으며, `600562_Logic.md` §2에서 Open Item으로 등록하고 사용자에게 정리 여부를 별도로 확인받아야 한다(이 문서/Logic 문서 어디에서도 DML 정리를 수행하지 않았다 — 지시문에 정리 지시가 없었으므로 임의로 삭제하지 않았다).

## §3 옵션 (a) 기술 검토 — UNIQUE 제약 실현 가능성

**질문**: `payment_intents`에 `(order_id, intent_origin, origin_reference)` 조합의 UNIQUE 제약이 기술적으로 가능한가? `origin_reference`가 `jsonb`라 직접 인덱스에 못 쓸 수 있다는 우려가 있었다.

**답(라이브 재확인)**: PostgreSQL의 `jsonb` 타입은 자체 동등 연산자(`=`)를 지원하며, `jsonb`는 **정규화된(canonical) 비교**를 쓴다 — 키 순서가 달라도(`{"a":1,"b":2}` vs `{"b":2,"a":1}`) 동일한 값으로 간주된다(참고: `json` 타입은 텍스트 비교라 이 성질이 없지만, 이 컬럼은 `jsonb`다). 따라서 `create unique index ... on payment_intents(order_id, intent_origin, origin_reference)` 자체는 **문법적으로도, 의미적으로도 가능하다.**

**그러나 이 접근보다 더 나은 기존 자산을 발견했다.** `0158`의 INSERT(§1 인용부)는 이미 `idempotency_key`를 다음과 같이 **결정론적으로** 생성하고 있다:
```
'OBS-' || p_order_id::text || '-' || p_intent_origin || '-' || substr(md5(v_origin_reference::text), 1, 12)
```
즉 `(order_id, intent_origin, origin_reference)` 조합이 이미 `idempotency_key` 하나의 컬럼(순수 `text`)으로 완전히 압축되어 있다. **라이브 재확인 결과, `payment_intents.idempotency_key`에는 현재 UNIQUE 제약이나 UNIQUE 인덱스가 전혀 없다**(`pg_constraint`/`pg_indexes` 전체 조회 — `payment_intents`의 UNIQUE는 `payment_token`/`provider_order_id`/`id(pk)` 3개뿐, `idempotency_key`는 없음). 이는 배경이 물었던 "jsonb 직접 UNIQUE" 질문 자체를 우회한다 — 원본 jsonb 컬럼에 직접 제약을 거는 대신, 이미 존재하는 정규화된 텍스트 해시 컬럼에 제약을 거는 쪽이 더 단순하고, jsonb 필드 구성이 호출부마다 조금씩 달라져도(예: 어떤 호출은 `note` 키를 포함하고 어떤 호출은 안 함) `md5(v_origin_reference::text)`가 이미 그 정규화를 흡수한다 — 이 점은 원본 jsonb 위에 직접 UNIQUE를 거는 방식보다 더 견고하다(jsonb 직접 방식은 필드 구성이 미세하게 달라지면 같은 논리적 이벤트인데도 다른 값으로 취급될 위험이 있음).

## §4 옵션 (b) 기술 검토 — Advisory Lock, `0142`의 기존 패턴과 비교

`0142_patch_toss_mvp_payment_intent_binding.sql`의 `bind_toss_payment_intent()` 트리거(`0142:54-60`, 이번 세션 이전 조사에서 이미 확인, 이번 문서에서 재확인)는 이미 다음 3중 보호를 쓰고 있다:

1. `pg_advisory_xact_lock(hashtextextended(tenant_id::text||':'||store_id::text||':'||order_id::text, 604260))` — order 단위 논리적 잠금(트랜잭션 종료 시 자동 해제).
2. `select ... from catchmenu_pos.orders where id = new.order_id ... for share` — 주문 행 공유 잠금.
3. `select ... from catchmenu_payment.payment_intents ... for update` — 기존 intent 후보 행 배타 잠금.

**`resolve_or_create_payment_intent()`에 이식 가능한가**: 부분적으로 가능하다 — 이 헬퍼는 트리거가 아니라 일반 함수 호출이므로 `new`/`old` 레코드가 없고, 잠금 대상 자체를 직접 선택해야 한다는 차이가 있다. `advisory_xact_lock`은 트리거 여부와 무관하게 동일하게 적용 가능하다(`tenant_id+store_id+order_id` 해시 — `0142`와 동일한 키 구성 요소를 그대로 재사용 가능, 다만 magic namespace `604260`은 `0142` 전용이므로 이 헬퍼는 별도 namespace를 써야 충돌하지 않는다). `for share`(orders)도 그대로 재사용 가능하다(이 헬퍼도 이미 `orders`를 조회하고 있음, `0158:96-100`). `for update`(intent 후보)도 마찬가지로 이식 가능하다 — 현재 `select count(*)`(락 없음) 쿼리를 `select ... for update`로 바꾸면 된다.

## §5 옵션 (c) 참고 — `confirm_payment()`의 `orders FOR UPDATE`와 비교 (PAY-CON-001, 범위 밖 spot check)

지시문은 PAY-CON-001(`confirm_payment()` 이중 호출)이 이미 안전함이 3중 확인됐다고 명시했다. 이번 문서는 재론하지 않되, `confirm_payment()`가 실제로 `orders`에 `for update`를 쓰는지만 최소 재확인했다: `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql:267-271` — `select ... from catchmenu_pos.orders where id = p_order_id ... for update;` 존재 확인. 이 패턴(주문 행을 통째로 잠가 그 주문에 대한 모든 후속 작업을 직렬화)을 `resolve_or_create_payment_intent()`에도 적용할 수 있는가는 `600562_Logic.md`의 옵션 (c)로 다룬다 — 다만 이 헬퍼는 `confirm_payment()` 내부에서 호출될 수도 있고(이 경우 이미 락이 걸린 상태), `0109`/`0130`(별도 함수)에서도 호출되므로 "이미 걸려있는 락에 얹혀가는 방식"이 항상 성립하지는 않는다는 점이 옵션 비교의 핵심 변수다.

## §6 정리

세 옵션 모두 기술적으로 실현 가능함을 확인했다(§3/§4/§5) — 판단은 하지 않는다(`600562_Logic.md`로 이월). §3에서 당초 우려했던 "jsonb 직접 UNIQUE 인덱스 가능 여부"라는 기술적 장벽 자체가 실제로는 존재하지 않음을 확인했고(가능함), 더 나아가 이미 존재하는 `idempotency_key`(정규화된 결정론적 해시)를 활용하는 편이 원본 jsonb에 직접 제약을 거는 것보다 더 견고한 대안임을 발견했다.

## §7 Open Questions

(a) `idempotency_key`에 UNIQUE 제약을 추가할 경우, 기존 5건의 테스트 오염 데이터(§2)와 향후 생성될 정상 `PREAUTHORIZED` 경로 데이터(이 헬퍼의 다른 분기, `0142`가 별도로 만드는 intent) 사이에 `idempotency_key` 형식 충돌이 없는지 확인 필요 — `0142`가 만드는 intent의 `idempotency_key` 형식(`'TOSS-INTENT:' || ...`, 이전 조사에서 확인)과 `'OBS-...'` 접두사가 겹치지 않음은 이번 문서에서 육안 확인했으나, 다른 경로(예: `0027`이 만드는 intent)의 형식까지 전수 확인하지는 않았다.
(b) `advisory lock`의 magic namespace 값 — `0142`가 `604260`을 쓰므로 이 워크패킷은 다른 값(예: 이 워크패킷 번호 `600560`)을 쓰는 것이 자연스러우나, 프로젝트 전체에서 advisory lock namespace를 중앙 관리하는 레지스트리가 있는지는 확인하지 않았다.
(c) §2의 라이브 오염 데이터(5건) 정리 여부 — 이 문서/Logic 문서는 판단하지 않고 Human 확인을 요청한다(`600562_Logic.md` §2).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000056_Register_Concurrency_Risk.md` §3(PAY-CON-002)/§9 — 이 워크패킷의 직접 발단.
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` §3 — `resolve_or_create_payment_intent()`의 원 설계 의도(옵션 C+).

### Full Rules Required

- `sql/migrations/0158_confirm_payment_intent_linkage_fix.sql` — `resolve_or_create_payment_intent()`(L43-259) 전체, 이번 워크패킷의 수정 대상.
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — `bind_toss_payment_intent()`(L29-203), advisory+row lock 재사용 템플릿.
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`의 `orders FOR UPDATE`(L267-271), PAY-CON-001 대조용.
- `catchmenu_payment.payment_intents` 라이브 스키마/제약(이번 턴 재확인) — `idempotency_key` UNIQUE 부재 확인.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- PAY-CON-001(`confirm_payment()` 이중 호출) 자체의 재조사 — 이미 3중 확인됐다는 전제를 그대로 수용, 이 워크패킷 범위 밖.
- §2의 라이브 오염 데이터 정리(DML) — 이 문서는 수행하지 않음, Human 확인 대기.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0(번호: `600560`)/§1(락 부재 독립 재검증)은 확정됐다. **§2에서 라이브 DB에 실제로 남아있는 중복 행(오염) 2건을 직접 발견해 긴급 기록했다** — 재현 "보고"가 아니라 현재도 존재하는 실제 데이터임을 재확인, 정리는 수행하지 않고 Human 확인을 요청한다. §3에서 jsonb 직접 UNIQUE가 기술적으로 가능함을 확인했고, 더 나아가 이미 존재하는 `idempotency_key`(UNIQUE 제약 부재 확인)를 활용하는 대안을 새로 발견했다. §4/§5에서 advisory lock/orders FOR UPDATE 옵션의 재사용 가능성을 각각 확인했다. `600562_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
