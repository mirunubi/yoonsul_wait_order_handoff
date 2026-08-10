# 600591_Overview_Confirm_Payment_From_Provider_Kds_Commit_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`confirm_payment_from_provider_kds_commit_correction`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷: `600510`/`600540`/`600550`/`600560`/`600570`/`600580`. 다음 빈 10단위 번호는 `600590` — 이 워크패킷에 배정한다(라이브 `ls` 재확인).

## §0.1 배경 (Cursor+안티 전수조사 완료, 재확인 불필요로 인용 — 단 아래 §1은 이번 턴 라이브 재확인)

`catchmenu_payment.confirm_payment_from_provider()`(`0027`, Toss 웹훅 `0038`/VAN 콜백 `0056` 경로)가 결제 승인 직후 `kds_tickets.conditions_met`에 `payment_confirmed:true` JSON 플래그만 찍고, `kds_status`를 `HOLD`→`COMMITTED`로 전환하는 후속 호출이 전혀 없다. 함수 자신의 반환값이 `next_step: KDS_CAPACITY_CHECK_REQUIRED`를 예고하지만, 호출자(`0038`/`0056`) 어디에도 이 후속 단계를 트리거하는 코드가 없다. 이미 `601021_Overview.md` §10 / `601024_ChangeContract.md` §5.1에 알려진 결함으로 기록돼 있었고, `0157`(`600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign`)의 범위에서 명시적으로 제외됐다 — 그 워크패킷의 헤더 주석 자체가 "Does not modify confirm_payment_from_provider(), Toss webhook, or VAN paths (0027/0038/0056)"라고 못박았다.

## §1 최우선 확인 — "용량확인(capacity check)" 메커니즘이 실제로 존재하는가 (라이브 재확인 완료)

**결론: 메커니즘은 실제로 존재하고, 완전히 구현되어 있으며, 라이브 스키마에도 등록돼 있다.** 다만 그 메커니즘이 결제확인 파이프라인의 **어느 경로에서도 실제로 게이트(차단 조건)로 쓰이고 있지 않다** — 아래 §1.4가 이 지점을 정확히 특정한다.

### §1.1 `CAPACITY_CHECKING` — `chk_kds_status`에 실제로 존재

```sql
-- 라이브 재확인
select pg_get_constraintdef(oid) from pg_constraint where conname = 'chk_kds_status';
-- CHECK ((kds_status = ANY (ARRAY['HOLD', 'CAPACITY_CHECKING', 'COMMITTED', 'COOKING', 'READY', 'SERVED', 'COMPLETED', 'CANCELLED', 'MANUAL_FALLBACK'])))
```

우연히 남은 값이 아니다 — 아래 §1.2의 실제 함수들이 이 값으로 전이시키고, 이 값에서 전이시킨다.

### §1.2 용량확인/커밋 함수 — 코드베이스 전체에 이미 존재 (`0028`/`0039`/`0151`)

| 함수 | 파일 | 역할 |
|---|---|---|
| `catchmenu_kds.evaluate_kds_capacity(p_tenant_id, p_store_id, p_kitchen_zone)` | `0028_create_kds_capacity_commit_rpc.sql` | 주방구역별 `COOKING+COMMITTED` 티켓 수를 임계값(8)과 비교해 `capacity_ok` 반환. |
| `catchmenu_kds.commit_kds_ticket(p_tenant_id, p_store_id, p_ticket_id, p_conditions, p_correlation_id)` | `0028` | **특허2 core.** 7개 조건(`arrived`/`table_confirmed`/`payment_confirmed`/`kds_capacity_ok`/`menu_available`/`peak_time_ok`/`no_show_risk_ok`) 전부 충족 시 `HOLD`/`CAPACITY_CHECKING`→`COMMITTED`, 아니면 `CAPACITY_CHECKING`에 머물며 `conditions_met` 갱신. |
| `catchmenu_kds.authorize_kds_release(...)` | `0028` | 원래 존재했던 "결제 승인 ≠ KDS 릴리즈" 분리 단계 — **`0157`에서 DROP됨**(§1.5 참고). |
| `catchmenu_kds.check_kds_capacity(p_tenant_id, p_store_id)` | `0151_create_check_kds_capacity_function.sql` | `evaluate_kds_capacity()`를 매장 내 모든 주방구역에 대해 집계하는 wrapper. `{data:{is_overloaded, zones}}` 형태 반환. 설계 근거: `600410_kds_capacity_gate_and_status_reconciliation`(Stage 11까지 완료된 별도 워크패킷). |
| `catchmenu_kds.bulk_commit_kds_tickets(p_tenant_id, p_store_id, p_order_id, p_force_conditions, p_correlation_id)` | `0039_create_kds_bulk_commit_rpc.sql` | `payment_ledger.kds_release_authorized`를 먼저 확인한 뒤, 주문의 `HOLD`/`CAPACITY_CHECKING` 티켓 각각에 대해 **`commit_kds_ticket()`을 실제로 호출**한다(라이브 재확인, `0039:72`). `authenticated`에 GRANT됨. |

**`grep -rln "commit_kds_ticket(" sql/migrations`** 결과 정의(`0028`)와 단 하나의 호출자(`0039`)만 존재한다 — 즉 `commit_kds_ticket()`의 7조건 게이트는 `bulk_commit_kds_tickets()`를 통해서만 도달 가능하다.

### §1.3 900xxx 설계문서 확인 — 특허 서사에는 "3단계" 언급 없음, 그러나 `600410`이라는 별도 SQL 레벨 설계 이력은 존재

`grep -rln "capacity" docs/900000_patent_and_handoff_package` → **0건.** 즉 `900xxx` 특허/인수인계 문서 어디에도 "결제확인→용량확인→KDS커밋"이라는 3단계 흐름을 명시적으로 서술한 곳이 없다 — 특허 서사 차원에서는 이 개념이 언급되지 않는다.

그러나 이것이 "실수로 넣은 불필요한 개념"이라는 뜻은 아니다 — `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/`(Stage 11 Audit까지 완료, 7개 문서 전부 존재)가 `check_kds_capacity()`를 정확히 이 목적(용량 게이트)으로 설계했고, 그 설계 문서 자체가 `0098`(`confirm_payment()`)의 `check_kds_capacity()` 사용을 조사한 결과를 담고 있다(§1.4에서 인용).

**결론**: 용량확인 메커니즘은 (a) 900xxx 특허 서사에는 없지만 (b) `600000_implementation_lifecycle` 레벨의 실제 SQL 설계·구현으로는 존재하며 완결되어 있다 — "이 함수만 실수로 중간에 불필요한 개념을 넣어놓았다"는 가설은 **근거가 약하다**. `confirm_payment_from_provider()`(`0027`)의 코드 주석 자체(`600591_Overview.md` §1.4 인용)가 "특허2: KDS Late Binding 조건 중 payment_confirmed 업데이트"라고 명시하고 있어, 이 함수는 애초에 7조건 게이트 시스템과 연동될 것을 전제로 작성됐다.

### §1.4 결정적 사실 — `confirm_payment()`(정상 파이프라인)의 자매 함수조차 이 게이트를 실제로는 쓰지 않는다

`600412_Logic.md`(600410 워크패킷)가 이미 라이브로 재확인한 사실을 그대로 인용한다: `0098`(`confirm_payment()`)의 `check_kds_capacity()` 호출(`0098` L562, L575 부근)은 `v_capacity_check->'data'`를 **감사 로그/응답 payload에 정보성으로만 첨부**할 뿐, `is_overloaded` 값을 조건 분기(`if`)에서 실제로 소비하지 않는다(`grep -n "is_overloaded" 0098` → 0건, 600412가 직접 확인). 이번 턴 `0157`(가장 최근, Human 승인 2026-07-15)의 `release_kds_after_payment()` 전문을 재확인한 결과도 동일하다:

```sql
-- 0157, release_kds_after_payment() 발췌
v_capacity_check := catchmenu_kds.check_kds_capacity(...);  -- 호출만 함
...
update catchmenu_payment.payment_ledger set kds_release_authorized = true ...;  -- 무조건 승인
with released as (
  update catchmenu_kds.kds_tickets
  set kds_status = 'COMMITTED', ...
  where order_id = p_order_id and kds_status = 'HOLD'  -- v_capacity_check 값과 무관하게 무조건 커밋
  ...
```

즉 **현재 라이브에 살아있는, Human이 가장 최근(2026-07-15) 승인한 정상 결제 파이프라인(`confirm_payment()`→`release_kds_after_payment()`)조차 7조건 게이트(`commit_kds_ticket()`)를 전혀 거치지 않고, `check_kds_capacity()`를 정보성으로만 호출한 뒤 무조건 `HOLD`→`COMMITTED`로 직행한다.** 원래 있었던 `authorize_kds_release()`(결제승인≠KDS릴리즈 분리 단계)도 `0157`에서 DROP됐다.

### §1.5 종합 — 사실 관계만 정리 (판단 없음)

| 항목 | 사실 |
|---|---|
| `CAPACITY_CHECKING` 상태값 | 스키마에 존재, `0028`/`0039` 함수들이 실제로 전이시킴 |
| 7조건 게이트(`commit_kds_ticket()`) | 존재, 구현 완료, GRANT됨, `bulk_commit_kds_tickets()`를 통해서만 도달 가능 |
| `bulk_commit_kds_tickets()`의 실제 호출자 | SQL 레벨에서는 **0건**(`grep` 재확인) — Flutter/클라이언트에서 직접 호출하는지는 SQL 레이어 밖이라 이번 조사 범위 아님(§4 스코프 제한 참고) |
| `confirm_payment()`→`release_kds_after_payment()`(정상 경로, 가장 최근 Human 승인) | 게이트 미사용, `check_kds_capacity()`는 정보성 호출만, 무조건 커밋 |
| `confirm_payment_from_provider()`(`0027`, 웹훅/VAN 경로) | 자체 코드 주석·반환값이 게이트 연동을 전제하나, 실제로는 아무것도 호출하지 않아 `HOLD`에 무기한 머묾 |
| 900xxx 특허 문서 | "capacity" 개념 자체가 서술되지 않음(0건) |
| `600410` 설계 문서 | 존재, Stage 11 Audit까지 완료, `check_kds_capacity()`를 게이트 목적으로 설계했음을 명시 |

## §2 `confirm_payment_from_provider()`/`release_kds_after_payment()` 시그니처 재확인 (라이브)

```sql
-- 라이브 재확인, 2026-07-18
release_kds_after_payment(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_ledger_id uuid, p_locale text default 'ko', p_correlation_id text default null)
confirm_payment_from_provider(p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_provider_payment_key text, p_provider_approval_number text, p_approved_amount integer, p_provider_raw_event_id uuid, p_correlation_id text)
```

`confirm_payment_from_provider()`는 `release_kds_after_payment()`가 요구하는 `p_order_id`(`v_intent.order_id`로 이미 조회됨)와 `p_ledger_id`(방금 INSERT한 `v_ledger_id`)를 **이미 지역 변수로 갖고 있다** — 호출에 필요한 값 자체는 함수 본문 안에 전부 존재한다. 유일한 차이는 `confirm_payment_from_provider()`에 `p_locale` 파라미터가 없다는 것인데, `release_kds_after_payment()`의 `p_locale`은 `default 'ko'`이므로 생략 가능(사소한 차이, 블로커 아님).

`confirm_payment_from_provider()`는 `0153`에서 중복 오버로드가 DROP되어 현재 단일 8-파라미터 버전만 라이브에 존재함을 재확인했다(`600510` 워크패킷이 이미 해결 — 이 함수는 현재 정상적으로 호출 가능한 상태이며, 문제는 순수하게 "결제확인 이후 후속 KDS 전이가 없다"는 것 하나뿐이다).

## §3 방향 A/B — 사실 근거 제시 (판단은 Human, `600592_Logic.md` §1에서 두 옵션 모두 설계)

**방향 A(용량확인 게이트 연동)의 근거**: `commit_kds_ticket()`/`bulk_commit_kds_tickets()`가 이미 완전히 구현·GRANT되어 있고, `confirm_payment_from_provider()` 자신의 코드 주석·반환값이 애초에 이 흐름을 전제로 작성됐다(§1.3/§1.4). 이 방향을 택하면 웹훅/VAN 결제는 정상 결제(`confirm_payment()`)보다 **더 엄격한** 용량 게이트를 통과해야 커밋된다.

**방향 B(단순화, `release_kds_after_payment()` 직접 호출)의 근거**: 가장 최근(2026-07-15), Human이 명시적으로 승인한 정상 결제 파이프라인 재설계(`0157`)가 이미 이 게이트를 **의도적으로 우회**하도록 만들어졌다(§1.4) — `authorize_kds_release()`(분리된 승인 단계)도 같은 턴에 DROP됐다. `confirm_payment_from_provider()`를 방향 A로 고치면, 완전히 같은 "결제 승인" 이벤트인데도 **경로에 따라 다른 커밋 규칙**(하나는 게이트 있음, 하나는 없음)이 생긴다 — 이것 자체가 새로운 불일치이며, 그 불일치를 만든 쪽은 `confirm_payment_from_provider()`가 아니라 원래 `0157`이 정상 경로를 단순화하기로 결정했다는 사실이다.

**어느 쪽도 아직 확정된 "틀린 방향"이 아니다** — A는 이미 존재하는 인프라를 실제로 쓰게 만드는 것이고, B는 가장 최근 Human 결정과의 일관성을 우선하는 것이다. 이 판단은 Human 결정 사항이다.

## §4 `resolve_payment_uncertain()` 형제 결함 — 포함 여부 판단 근거

Cursor가 같은 파일(`0027`)에서 발견한 별도 결함: `resolve_payment_uncertain()`은 `p_resolution_type in ('CONFIRMED_APPROVED', 'MANUAL_OVERRIDE_APPROVED')`(주석: "결제 확인, KDS 용량확인으로 진행")일 때도 **`payment_ledger`에 INSERT하는 코드가 전혀 없다**(라이브 재확인, 함수 전문에 `insert into catchmenu_payment.payment_ledger` 0회 등장). `order_sessions.session_status`/`payment_intents.intent_status`만 갱신되고, KDS 티켓에 대한 갱신도 전혀 없다 — `PAYMENT_UNCERTAIN`으로 분류됐다가 사람이 수동으로 "승인" 처리한 결제는, 승인 이후에도 **원장 기록도 없고 KDS도 영원히 `HOLD`에 머문다.**

**같은 워크패킷에 포함할지 판단 근거**:

| 근거 | 방향 |
|---|---|
| 같은 파일(`0027`), Cursor가 같은 조사 턴에 발견, 둘 다 "결제확인 이후 후속 처리 누락"이라는 공통 상위 주제 | 묶는 쪽 근거 |
| `confirm_payment_from_provider()`의 수정은 **이미 존재하는 함수를 호출로 배선**하는 작업(낮은 설계 리스크) | — |
| `resolve_payment_uncertain()`의 수정은 **`payment_ledger`에 새로운 INSERT 형태를 설계**해야 하는 작업 — `mark_payment_uncertain()` 시점에는 provider 확정 데이터(`provider_payment_key`/`provider_approval_number`)가 아예 없을 수 있어(애초에 "불확실"했으므로), `CONFIRMED_APPROVED`/`MANUAL_OVERRIDE_APPROVED` 각각에 대해 `ledger_entry_type`/금액 출처/provider 필드 처리 방식을 새로 정의해야 한다 — `payment_ledger`는 "단일 진실 소스"로 문서화된 재무 원장 테이블이라 리스크 등급이 다르다 | 쪼개는 쪽 근거 |
| `confirm_payment_from_provider()`는 "무엇을 호출할지"(A/B) 자체가 아직 Human 미결정이라 이미 그 자체로 하나의 완결된 논의 단위 | 쪼개는 쪽 근거 |

**권고(판단 아님, 근거 제시)**: 오늘 이 세션이 반복 적용한 "같은 패턴이면 묶고 다른 패턴이면 쪼갠다" 원칙을 그대로 적용하면, `confirm_payment_from_provider()`(배선 수정)와 `resolve_payment_uncertain()`(신규 원장 INSERT 설계)은 **수정 패턴의 성격이 다르다** — 전자는 `600650`/`600660`류(기존 함수 호출 배선)에 가깝고 후자는 `601130`류(신규 스키마/로직 설계)에 가깝다. **분리를 권고**하되(가칭 `resolve_payment_uncertain_ledger_gap_correction`), 이번 문서는 이 판단의 근거만 제시하고 최종 결정은 Human에게 남긴다(`600592_Logic.md` §2에서 재확인).

## §5 스코프 한정

- `.sql` 파일 생성/수정 없음(이번 턴).
- Flutter/클라이언트 코드 확인 안 함 — `bulk_commit_kds_tickets()`의 실제 호출자가 클라이언트 레벨에 있는지는 SQL 레이어 조사만으로는 확정할 수 없다(§1.5 명시).
- `resolve_payment_uncertain()`의 실제 수정 설계는 이 워크패킷에 포함하지 않음(§4 권고에 따름) — `600592_Logic.md`는 방향 A/B 설계와 스코프 판단 근거만 다룬다.
- Cash/무결제 경로(`601024_ChangeContract.md` §5.2), 재시도/정산 함수(§5.3), `start_cooking()`의 호출자 부재(§5.4) — 전부 이 워크패킷 밖, 이미 알려진 별도 Open Item.

## §6 Open Items

(a) 방향 A/B 중 어느 쪽을 택할지 — Human 결정 필요, `600592_Logic.md`에서 두 옵션 모두 설계 완료 상태로 대기.
(b) `resolve_payment_uncertain()`의 `payment_ledger` INSERT 누락 — 별도 워크패킷 권고(§4), Human 결정 필요.
(c) `bulk_commit_kds_tickets()`의 실제 호출자가 존재하는지(Flutter 또는 다른 SQL 경로) — SQL 레이어 조사로는 미확정, 방향 A를 택할 경우 이 사실이 A의 실질적 효과(사람이 실제로 그 결과를 보는지)에 영향을 줌.
(d) `601024_ChangeContract.md` §5.4(`start_cooking()` 호출자 부재)와 이 워크패킷의 관계 — 방향 A/B 어느 쪽이든 `COMMITTED` 이후 `COOKING` 전이 자체가 이미 별도로 끊겨 있다는 사실은 이 워크패킷의 수정 효과를 제한할 수 있음, 별도 확인 필요.
(e) 900xxx 특허 문서에 "capacity" 서술이 없다는 사실 자체를 문서화 갭으로 볼지(특허2 서사 보강 필요) — 이 워크패킷 범위 밖, 참고로만 기록.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `600592_Logic.md`로 이어짐.** 용량확인 메커니즘은 (1) 스키마에 실제로 존재(`CAPACITY_CHECKING`), (2) 완전히 구현된 지원 함수 3종(`evaluate_kds_capacity`/`commit_kds_ticket`/`check_kds_capacity`) + 게이트를 실제로 통과시키는 `bulk_commit_kds_tickets()`가 존재, (3) `600410` 설계 문서가 Stage 11까지 완료된 상태로 뒷받침하지만, (4) 정작 가장 최근(2026-07-15) Human이 승인한 정상 결제 파이프라인(`confirm_payment()`→`release_kds_after_payment()`)조차 이 게이트를 실제로는 우회하고 있다는 사실을 라이브 재확인으로 실증했다(§1.4). 이 사실 관계에 근거해 방향 A/B를 둘 다 근거와 함께 제시했고(§3), `resolve_payment_uncertain()`의 형제 결함은 수정 패턴이 근본적으로 다르다는 근거로 분리를 권고했다(§4) — 두 판단 모두 최종 결정은 Human에게 남긴다.
