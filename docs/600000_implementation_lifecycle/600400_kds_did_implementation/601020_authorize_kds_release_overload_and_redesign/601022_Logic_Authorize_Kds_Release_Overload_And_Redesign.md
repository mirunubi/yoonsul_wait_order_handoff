# 601022_Logic_Authorize_Kds_Release_Overload_And_Redesign.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 3 — 전면 재작성. ChatGPT 옵션 1B(3개 결함, Slice 1/2/3) 채택. Revision 2의 옵션 a/b/c 비교 구조는 폐기.

## Change ID

`authorize_kds_release_overload_and_redesign`

## §0 전제 — `601021_Overview.md` Revision 3 반영

Revision 2는 컬럼 세팅 방법을 옵션 a(확장)/b(신규 함수)/c(게이트 재검토)로 나열하고 판단하지 않았다. **Human 결정(2026-07-15, ChatGPT+제미나이 교차검증, 재논의 금지)이 이 비교 구조 자체를 기각**했다 — "`kds_status=COMMITTED`로 확인"(옵션 c류의 접근)은 결과로 원인을 증명하려는 순환 논리이기 때문이다.

**확정된 방향**: 옵션 a에 해당하는 접근(기존 함수 확장)을 채택하되, Revision 2의 옵션 a보다 정밀하게 특정됐다 — `release_kds_after_payment()`(0098) 내부, `p_ledger_id`를 이미 갖고 있는 지점에 `payment_ledger` UPDATE 한 문장을 추가한다(`601021_Overview.md` §4.2). 이것이 Slice 1이다. `bulk_commit_kds_tickets()`의 게이트(옵션 c가 손대려 했던 대상)는 **변경하지 않는다** — 이것이 결함 2의 판단이다. 추가로, Revision 2에서는 전혀 다루지 않았던 `start_cooking()`의 fail-open 구조(결함 3, `601021_Overview.md` §6)를 이번 Revision에서 처음으로 fail-closed로 전환한다.

## §1 Slice 1 — 권한 생산자 복구 (결함 1)

### §1.1 변경 대상

`sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`의 `catchmenu_payment.release_kds_after_payment()` 함수 본문만 `create or replace function`(신규 마이그레이션 파일에서 재정의). `confirm_payment()`는 무변경.

### §1.2 정확한 SQL 변경 (설계, Stage 4 대상, 이번 턴 미실행)

```sql
-- 신규 마이그레이션 초안 (파일 번호는 Stage 4 착수 직전 확정)
-- Purpose: release_kds_after_payment()가 KDS 티켓을 COMMITTED로
--          전환하는 것과 같은 트랜잭션 안에서, payment_ledger.
--          kds_release_authorized(테이블 컬럼)도 함께 true로
--          세팅하도록 확장한다. "권한 생성이 결과보다 먼저 오도록"
--          kds_tickets UPDATE보다 앞에 배치한다.
-- Depends on: 0098_create_payment_confirm_pipeline_rpc.sql
-- Non-goals:
--   confirm_payment_from_provider()(0027)는 건드리지 않는다
--   (601021_Overview.md §10 — 별개의 병렬 파이프라인, 이번
--   워크패킷 범위 밖).
--   bulk_commit_kds_tickets()(0039)의 게이트 로직은 건드리지
--   않는다(결함 2 — 자연 해결만 확인, §2).

create or replace function
  catchmenu_payment.release_kds_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_released_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_capacity_check jsonb;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  -- KDS 용량 재확인 (기존, 변경 없음)
  v_capacity_check :=
    catchmenu_kds.check_kds_capacity(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- ============================================================
  -- 신규: payment_ledger.kds_release_authorized 세팅
  -- (kds_tickets UPDATE보다 반드시 먼저 — 권한 생성이 결과보다
  --  선행해야 한다는 원칙)
  -- ============================================================
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = 'SYSTEM'
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- HOLD 티켓 → COMMITTED (기존, 변경 없음)
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

  -- (이하 기존 로직 무변경: WARNING 로그, realtime 브로드캐스트, 반환값)
  ...
end;
$$;
```

**변경 폭 확인**: 함수 시그니처(파라미터 목록) 무변경 — 기존 호출자(`confirm_payment()`)는 코드 수정 불필요. 신규 `UPDATE` 1문 추가가 전부다.

### §1.3 왜 `payment_ledger` UPDATE가 `kds_tickets` UPDATE보다 먼저인가

두 UPDATE 모두 같은 `security definer` 함수 호출 안에서 실행되므로 이미 하나의 트랜잭션으로 원자적이다 — 실패 시 롤백은 순서와 무관하게 둘 다 함께 이뤄진다. 그럼에도 순서를 지정하는 이유는 **가독성과 의도 표현**이다: "권한(authorized)이 먼저 생성되고, 그 권한에 의해 결과(COMMITTED)가 발생한다"는 인과 순서를 코드 순서로도 드러내어, `601021_Overview.md` §0이 지적한 "결과로 원인을 증명하는 순환 논리"를 코드 레벨에서도 반복하지 않도록 한다.

## §2 Slice 2 — 소비자 게이트 정렬/재확인 (결함 2 자연 해결 확인 + 결함 3 fail-closed 전환)

### §2.1 결함 2 — `bulk_commit_kds_tickets()` 게이트, 변경 없음, 자연 해결 확인 계획

`0039`의 게이트 코드 자체는 이번 워크패킷에서 **한 글자도 바꾸지 않는다**(`601021_Overview.md` §9). Slice 1 배포 후 아래를 확인해 "자연 해결"을 검증한다(Stage 5 검증 계획, 이번 턴은 계획만):

1. `BEGIN...ROLLBACK` 트랜잭션 안에서 테스트 주문 생성 → `confirm_payment()`(또는 3개 결제 통합 함수 중 하나) 호출 → `payment_ledger.kds_release_authorized`가 `true`로 바뀌었는지 직접 조회로 확인.
2. 같은 트랜잭션 안에서 `bulk_commit_kds_tickets(p_tenant_id, p_store_id, p_order_id)`를 호출 — Slice 1 이전에는 `kds_release_not_authorized`를 반환했을 케이스가, Slice 1 이후에는 `success: true`로 통과하는지 확인.
3. 위 1-2를 카드/PG 3개 경로(OKPOS/Toss Payments/Toss POS, 즉 `0102`/`0103`/`0104`를 통해 `confirm_payment()`에 도달하는 경로) 각각에 대해 최소 1회씩 재현.

이 확인이 "결함 2"의 전체 검증이다 — 게이트를 고치는 것이 아니라, 게이트가 원래 의도대로 동작하게 됐음을 증명하는 것.

### §2.2 결함 3 — `start_cooking()` fail-open → fail-closed 전환

`0029` L65-79(`601021_Overview.md` §6)의 정확한 변경:

```sql
-- 현재 (fail-open)
if v_ticket.payment_ledger_id is not null then
  if not exists (
    select 1 from catchmenu_payment.payment_ledger
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
-- payment_ledger_id가 null이면 여기로 바로 건너뜀 → 무조건 통과
```

```sql
-- 변경 후 (fail-closed 설계 초안, Stage 4 대상)
if v_ticket.payment_ledger_id is null then
  -- 결제 원장이 연결되지 않은 티켓은 기본적으로 거부한다.
  -- 무결제/현금 등 실제로 결제가 불필요한 티켓은, 이 워크패킷
  -- 범위 밖의 별도 명시적 경로(예: CASH_CONFIRMED류)를 통해
  -- payment_ledger_id를 채우거나 별도 플래그를 갖도록 재설계
  -- 되어야 한다 — 그 설계는 이번 워크패킷에서 하지 않는다
  -- (601021_Overview.md §11 (c), 아래 §4 참고).
  return jsonb_build_object(
    'success', false,
    'error_key', 'kds_release_ledger_missing',
    'message', 'payment_ledger_id is null; ticket has no linked payment record'
  );
end if;

if not exists (
  select 1 from catchmenu_payment.payment_ledger
  where id = v_ticket.payment_ledger_id
    and kds_release_authorized = true
) then
  return jsonb_build_object(
    'success', false,
    'error_key', 'kds_release_not_authorized',
    'message', 'payment_ledger.kds_release_authorized must be true'
  );
end if;
```

**변경의 정확한 범위**: 바깥쪽 `if`의 극성을 뒤집는다(`is not null` → `is null`이면 즉시 거부) — 안쪽의 `kds_release_authorized = true` 검사 로직 자체는 그대로 재사용한다. 새 에러 키 `kds_release_ledger_missing`을 도입해 "원장이 아예 없어서 거부"와 "원장은 있지만 미승인이라 거부"(`kds_release_not_authorized`)를 구분한다 — 향후 재조정/재시도 함수(§3)가 어느 케이스인지 원인을 구분해 처리할 수 있도록 한다.

### §2.3 회귀 확인 계획 (Human 명시적 요청)

**질문**: fail-closed 전환이 기존 정상 결제 흐름(`payment_ledger_id`가 있는 정상 케이스)에 회귀를 일으키는가?

**답(코드 근거)**: 아니오 — `payment_ledger_id is not null`인 분기의 로직(`kds_release_authorized = true` 검사)은 **한 글자도 바뀌지 않는다**. 바뀌는 것은 오직 `payment_ledger_id is null`인 분기의 결과(허용 → 거부)뿐이다. 따라서 "정상 케이스"(원장이 있고 Slice 1 배포 후 `kds_release_authorized`가 true인 케이스)는 이전과 동일하게 통과한다.

**그럼에도 확인해야 할 것 — 현재 라이브에 `payment_ledger_id is null`로 정상적으로 의존하는 케이스가 있는가**:

- `start_cooking()` 자체가 SQL/클라이언트 어디에서도 호출되지 않는다(`601021_Overview.md`에서 이미 재확인, 0건) — 따라서 **현재 프로덕션에 이 전환으로 깨지는 실제 호출은 없다**. 이는 "회귀가 없다"는 뜻이 아니라 "현재는 아무도 이 함수를 호출하지 않으므로 회귀가 드러날 지점 자체가 없다"는 뜻이다.
- 그러나 `release_kds_ticket_no_payment()`(`0143`)로 커밋된 티켓은 `payment_ledger_id`가 `null`인 채로 `COMMITTED` 상태가 된다(`601021_Overview.md` §4.5 관련 선례) — 만약 향후 누군가 이 함수를 `start_cooking()`과 연결한다면(현재는 그런 연결이 없음), fail-closed 전환 이후에는 이런 티켓이 영구히 `COOKING`으로 못 넘어가는 새로운 제약이 생긴다. **이것은 Human이 이미 인지하고 승인한 트레이드오프다**(지시문: "현금/무료증정 등 실제 비카드 결제 유형은 각각 명시적 근거를 가진 별도 경로로 표현되어야 함") — 이번 워크패킷은 그 별도 경로를 설계하지 않지만, 이 회귀 가능성 자체는 §4 Open Item으로 명시한다.

**Stage 5 검증 계획(테스트 항목)**:
1. `payment_ledger_id`가 있고 `kds_release_authorized = true`인 티켓 → `start_cooking()` 성공(회귀 없음 확인).
2. `payment_ledger_id`가 있고 `kds_release_authorized = false`인 티켓 → `kds_release_not_authorized` 반환(기존과 동일, 회귀 없음 확인).
3. `payment_ledger_id`가 `null`인 티켓 → **변경 전에는 성공, 변경 후에는 `kds_release_ledger_missing` 반환**(의도된 동작 변경 확인).
4. `0143`(`release_kds_ticket_no_payment()`)으로 커밋된 티켓을 3번 케이스로 재현해 실제로 막히는지 확인 — 막힌다면 이는 버그가 아니라 §4 Open Item에 기록된 알려진 결과다.

## §3 Slice 3 — 폐기 정리 (`authorize_kds_release()` DROP)

### §3.1 재확인 — 호출자 0건 (Slice 1/2 착수 전 마지막 재확인 필요)

`601021_Overview.md` §2에서 이미 재확인했으나, Slice 3 실행 직전(Stage 4)에 다시 한번 `count(*) from pg_proc where proname='authorize_kds_release'` 및 `grep -rn "authorize_kds_release(" sql/migrations/*.sql`로 재확인해야 한다 — Slice 1/2 배포 사이에 다른 변경이 이 함수를 호출하도록 만들지 않았는지 확인하는 절차다.

### §3.2 DROP 마이그레이션 설계 (Stage 4 대상)

```sql
drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
);
drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text, text, text
);
```

Slice 1(§1)이 이미 배포되어 `authorize_kds_release()`가 하던 유일한 일(컬럼 세팅)을 `release_kds_after_payment()`가 대신하고 있으므로, 이 DROP은 더 이상 "대체 경로 없는 DROP"이 아니다(Revision 1의 문제 해소).

### §3.3 문서 정리

- `601021_Overview.md`/`601022_Logic.md` 자체의 Snapshot Decision을 Stage 6 시점 최종 상태로 갱신.
- `600402_NavigationMap.md`/`000053_Matrix_Domain_To_Artifact_Traceability.md`에 이 워크패킷의 최종 상태 반영(Slice 1/2/3 전부 완료 시점).

## §4 재시도/재조정 함수 8가지 조건 — 결함 1 수정이 이 설계에 미치는 영향

**원문 보존**(이전 워크패킷 이월):

1. PaymentIntent(또는 이에 상응하는 결제 의도 레코드) 존재 확인.
2. 승인된 결제 원장(`payment_ledger`, `ledger_status = 'APPROVED'`) 존재 확인.
3. 결제 금액과 주문 금액 일치 확인.
4. 환불되지 않았음(미환불) 확인.
5. `payment_ledger.kds_release_authorized = true`(또는 재조정 대상이라면 이 값이 아직 `false`인 상태) 확인.
6. 대상 `kds_tickets`가 실제로 `HOLD` 상태인지 확인(이미 `COMMITTED`라면 재실행 대상 아님).
7. 중복 COMMIT 방지 — 이미 `COMMITTED`된 티켓을 다시 처리하지 않음.
8. 멱등키(idempotency key) 기반 재실행 안전성.

**결함 1 수정이 재시도 함수 설계를 더 명확하게 만드는가 — 그렇다**:

Slice 1 이전에는 "재시도가 왜 필요한가"에 대한 답이 모호했다 — `payment_ledger.kds_release_authorized`를 세팅하는 라이브 경로가 아예 없었으므로, "재시도"가 실질적으로는 "최초 실행"과 구분되지 않았다(세팅된 적이 한 번도 없는 값을 "재시도로 복구"한다는 것이 정의상 이상했다). **Slice 1 이후에는 재시도의 의미가 명확해진다**: `release_kds_after_payment()`가 정상적으로 실행됐다면 5번 조건은 이미 충족된 상태로 남는다 — 재시도가 실제로 필요한 케이스는 다음 중 하나로 좁혀진다.

- (i) `release_kds_after_payment()` 호출 자체가 실패했거나 예외로 중단된 경우(예: `check_kds_capacity()` 이후 어떤 이유로 트랜잭션이 롤백된 경우) — 이 경우 `payment_ledger`는 `APPROVED`인데 `kds_release_authorized`는 여전히 `false`인 상태로 남는다. 8가지 조건의 1-5번이 정확히 이 불일치를 탐지하는 조건이 된다.
- (ii) §10(`601021_Overview.md`)에서 발견한 별도 파이프라인(`confirm_payment_from_provider()`) 경로 — 이 경로는 Slice 1로 고쳐지지 않으므로, 재시도 함수가 이 경로의 결제 건까지 커버 대상으로 삼을지는 Human의 향후 결정 사항이다(이번 워크패킷 범위 밖, `601021_Overview.md` Open Item (a)와 연결).

**결론(판단 아님, 사실 정리)**: Slice 1 배포 이후, 재시도/재조정 함수는 "정상적으로는 거의 트리거되지 않는, 예외 상황(트랜잭션 실패/파이프라인 불일치) 전용 안전망"으로 성격이 명확해진다 — Slice 1 이전에 우려했던 "상시 필요한 보정 장치"가 아니다. 이 재시도 함수의 구체 설계(시그니처, 트리거 방식)는 여전히 이번 워크패킷 범위 밖이며, 8가지 조건은 다음 워크패킷을 위해 원문 그대로 보존한다.

## §5 Open Items (갱신, 이번 워크패킷에서 설계하지 않는 것들)

(a) `confirm_payment_from_provider()`(`0027`, Toss 웹훅/VAN) 파이프라인의 동일 문제 — `601021_Overview.md` §10, Human 결정 범위 밖으로 확인, 별도 워크패킷 필요 여부는 Human 결정 사항.
(b) 현금/무료증정 등 비카드 결제를 위한 명시적 근거 경로(`CASH_CONFIRMED` 등) — §2.3에서 확인한 fail-closed 전환의 알려진 트레이드오프에 대한 해법. 이번 워크패킷은 설계하지 않는다.
(c) 재시도/재조정 함수의 구체 시그니처·SQL — §4에서 성격만 정리, 구체 설계는 별도 워크패킷.
(d) `COMMITTED → COOKING` 전이의 라이브 경로 공백(`start_cooking()` 호출자 0건 자체) — 이번 워크패킷은 그 게이트만 fail-closed로 고치고, "누가 이 함수를 호출하게 할 것인가"는 다루지 않는다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md`(Revision 3 — §4/§6/§10, 이 문서의 직접 전제)
- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md`(§2.4)

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — Slice 1의 정확한 변경 대상(`release_kds_after_payment()`).
- `sql/migrations/0029_create_kds_cooking_rpc.sql` — Slice 2의 정확한 변경 대상(`start_cooking()`).
- `sql/migrations/0039_create_kds_bulk_commit_rpc.sql` — Slice 2에서 무변경 확인 대상(`bulk_commit_kds_tickets()`).
- `sql/migrations/0028_create_kds_capacity_commit_rpc.sql`/`0063_patch_core_rpc_i18n_diagnostics.sql` — Slice 3의 DROP 대상.
- `sql/migrations/0143_add_no_payment_kds_release_policy.sql` — §2.3 회귀 확인의 근거(`release_kds_ticket_no_payment()`가 만드는 `payment_ledger_id is null` 케이스).
- `sql/migrations/0027_create_payment_intent_rpc.sql` — §4 (ii)의 근거.

### Domain Indexes

- `600402_NavigationMap.md`.

### Excluded Rule Families

- `confirm_payment_from_provider()`(0027) 파이프라인 자체의 수정 — §5 (a), 범위 밖.
- 현금/무료증정 명시적 경로 설계 — §5 (b), 범위 밖.
- 재시도/재조정 함수 구체 설계 — §5 (c), 범위 밖.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**재작성 확정, 방향 확정.** §1에서 Slice 1(`release_kds_after_payment()` 내부, `p_ledger_id` 기준 `payment_ledger` UPDATE 삽입, kds_tickets UPDATE보다 선행)을 정확한 코드 수준으로 설계했다. §2에서 결함 2(게이트 무변경, 자연 해결 확인 계획)와 결함 3(`start_cooking()` fail-open → fail-closed, 정확한 극성 반전 지점)을 설계하고, 명시적으로 요청된 회귀 확인 계획을 포함했다. §3에서 `authorize_kds_release()` DROP을 Slice 1이 대체 경로를 마련한 이후의 안전한 정리로 재확인했다. §4에서 8가지 재시도 조건이 Slice 1 이후 "예외 전용 안전망"으로 성격이 명확해짐을 정리했다. `601021_Overview.md` §10의 범위 밖 발견(별도 파이프라인 미해결)은 이 문서에서도 Open Item (a)로 동일하게 유지했다 — 임의로 범위를 확장하지 않았다. Stage 2(`601023_TestPlan.md`/`601024_ChangeContract.md`)로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
