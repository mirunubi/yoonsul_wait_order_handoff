# 601032_Logic_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## §0 설계 원칙 요약

`601031_Overview.md`의 확인 결과를 그대로 적용한다: (1) `commit_kds_ticket()`/`bulk_commit_kds_tickets()`를 재사용하고 재구현하지 않는다(§1), (2) 신규 함수는 예외를 절대 재전파하지 않아 결제확정 성공이 KDS 방출 실패로부터 격리된다(§2), (3) `catchmenu_payment` 스키마에 배치한다(§4), (4) 재시도 메커니즘은 설계하지 않는다(§3, Open Item (a)로만 남김).

## §1 `catchmenu_payment.request_kds_release_after_payment()` — 신규 공용 함수 전체 설계

### §1.1 시그니처

```sql
create or replace function catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_actor_type text default 'SYSTEM',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
```

`p_order_id`/`p_ledger_id`는 `release_kds_after_payment()`와 동일한 파라미터 이름/순서를 재사용한다(호출자 입장에서 두 "release" 계열 함수가 대칭적으로 보이도록). `p_actor_type`을 추가한 이유: `confirm_payment_from_provider()`(웹훅/VAN, 실제 승인 주체는 `'PROVIDER'`)와 향후 `confirm_payment()`(POS, `'SYSTEM'` 또는 스태프)가 이 함수를 공용으로 쓸 것이므로(`601031_Overview.md` §0.2 (3) Open Item), 감사 기록에 정확한 주체를 남기려면 하드코딩하지 않고 파라미터화해야 한다 — `release_kds_after_payment()`가 `'SYSTEM'`을 하드코딩한 것과 다른 지점(§1.4에서 재확인).

### §1.2 본문 — `bulk_commit_kds_tickets()` 재사용, 결과 코드 번역

```sql
declare
  v_bulk_result jsonb;
  v_result_code text;
  v_audit_id uuid;
begin
  -- Step 1: authorize (authorize_kds_release()가 0157에서 DROP됐으므로,
  -- release_kds_after_payment()와 동일한 인라인 패턴으로 승인 처리).
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = p_actor_type
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- Step 2: 실제 게이트 통과 — commit_kds_ticket()의 7조건 평가를 주문 단위로
  -- 순회 호출하는 기존, 이미 구현된 함수를 그대로 재사용한다(§0/601031_Overview §1).
  v_bulk_result := catchmenu_kds.bulk_commit_kds_tickets(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_force_conditions := null,
    p_correlation_id := p_correlation_id
  );

  -- Step 3: 결과 코드 번역 (ChatGPT 제안 형태 참고).
  -- (Stage 4 Critical tier에서 발견/정정) "처리 대상 티켓이 0건"인 경우를
  -- committed_count=0/pending_count=0/skipped_count=0으로 반드시 먼저 분기시켜야
  -- 한다 — 이 조건은 "pending=0 and skipped=0"이라는 COMMITTED 판정 조건도
  -- 동시에 만족시키므로, 순서를 지키지 않으면 "아무 티켓도 처리하지 않았다"가
  -- "전부 성공적으로 커밋했다"로 잘못 보고된다. 웹훅 재전송 시나리오(§6 (e),
  -- High priority)에서 특히 위험하다 — 이미 완전히 처리된 주문에 대해 웹훅이
  -- 재전송되면 bulk_commit_kds_tickets()는 HOLD/CAPACITY_CHECKING 티켓을 하나도
  -- 찾지 못해 committed_count=0으로 끝나는데, 이 버그가 있으면 그걸 "이번에도
  -- 커밋 성공"으로 잘못 보고하게 된다. pg_temp로 라이브 재현해 정정을 확인했다
  -- (§3.1 참고).
  v_result_code := case
    when not coalesce((v_bulk_result->>'success')::boolean, false)
      then 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'
    when coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_COMMITTED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) > 0
      then 'PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD'
    else 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'
  end;

  -- 감사 기록 — 성공/대기/차단/무티켓 모든 경우에 남긴다(재무 인접 도메인).
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'kds_release_requested',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    -- (Stage 4 Critical tier 정정, Cursor+Codex 교차검증) 'PENDING'은
    -- catchmenu_ledger.audit_records.chk_audit_decision(0008:105-119)의
    -- 허용값 11개(APPROVED/REJECTED/OVERRIDDEN/DELEGATED/ESCALATED/
    -- CANCELLED/COMPLETED/FAILED/NOTED/SUSPENDED/REVOKED) 어디에도 없다 —
    -- PARTIAL_CAPACITY_HOLD/CAPACITY_HOLD 분기가 실행될 때마다 이
    -- append_audit_record() INSERT 자체가 제약 위반으로 크래시하고, 아래
    -- EXCEPTION 핸들러가 이를 삼켜 PAYMENT_CONFIRMED_KDS_RELEASE_FAILED로
    -- 잘못 보고했을 결함이었다(결제도 KDS도 정상 대기 상태였을 뿐인데
    -- "실패"로 오분류). 'SUSPENDED'로 정정 — "일시 중단, 재개 가능"이라는
    -- 기존 코드베이스 관례(0041의 'agent_module_isolated' 감사기록이 동일
    -- 의미로 이미 사용 중)와 가장 가깝고, 이미 §1.2 다른 분기에서 쓰는
    -- 'NOTED'(0027/0031/0036의 기존 관례 — "사람 검토가 필요한 사실 기록")와도
    -- 의미가 겹치지 않는다. 'DELEGATED'는 재시도/재평가를 실제로 넘겨받을
    -- 프로세스가 없다는 사실(601031_Overview.md §3)과 모순되므로 기각했다.
    p_decision := case
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED' then 'APPROVED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED' then 'FAILED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS' then 'NOTED'
      else 'SUSPENDED'
    end,
    p_decision_payload := jsonb_build_object(
      'result_code', v_result_code,
      'bulk_commit_result', v_bulk_result
    ),
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id
  );

  -- 결제 도메인 관점의 성공/실패가 아니라, 항상 success:true로 반환한다 —
  -- 이 함수의 "성공"은 "요청 처리가 정상적으로 끝났다"는 뜻이지
  -- "티켓이 즉시 COMMITTED됐다"는 뜻이 아니다(§2 원칙).
  return jsonb_build_object(
    'success', true,
    'result_code', v_result_code,
    'ledger_id', p_ledger_id,
    'order_id', p_order_id,
    'committed_count', v_bulk_result->'committed_count',
    'pending_count', v_bulk_result->'pending_count',
    'skipped_count', v_bulk_result->'skipped_count',
    'bulk_commit_detail', v_bulk_result,
    'audit_id', v_audit_id
  );
exception
  when others then
    -- 절대 RAISE하지 않는다 — 호출자(confirm_payment_from_provider())의
    -- payment_ledger INSERT가 KDS 쪽 예외로 함께 롤백되는 것을 원천 차단한다
    -- (601031_Overview.md §2, 600652_Logic.md §1.5/§9.2 원칙의 재적용).
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'payment',
      p_audit_type := 'kds_release_requested_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := null,
      p_subject_type := 'payment_ledger',
      p_subject_id := p_ledger_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate
      ),
      p_order_id := p_order_id,
      p_correlation_id := p_correlation_id
    );
    return jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', p_ledger_id,
      'order_id', p_order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**`success:true`를 예외 분기에서도 유지하는 이유**(재확인, §2 원칙의 직접 적용): 이 함수를 호출하는 시점에는 결제 자체(`payment_ledger` INSERT)가 이미 성공적으로 완료된 뒤다. 이 함수의 실패는 "결제가 실패했다"는 뜻이 결코 아니므로, `success:false`를 반환하면 호출자가 이를 결제 실패로 오인해 잘못된 사용자 응답(예: 웹훅에 5xx 반환 → PG가 재시도 → 중복 결제 확인 시도)을 만들 위험이 있다. `result_code`만으로 상태를 구분하게 하는 것이 더 안전하다.

### §1.3 GRANT/REVOKE

```sql
revoke all on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) from public;
grant execute on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) to authenticated;
```

`bulk_commit_kds_tickets()`/`commit_kds_ticket()`/`evaluate_kds_capacity()`는 **전혀 수정하지 않는다** — `security definer`이므로 신규 함수 안에서 그대로 호출 가능하다(GRANT 재확인: `bulk_commit_kds_tickets()`는 이미 `authenticated`에 GRANT돼 있으나, `security definer` 함수 내부 호출은 어차피 호출자 GRANT와 무관하게 함수 소유자 권한으로 실행되므로 이 재확인은 참고 목적일 뿐 필수 전제조건은 아니다).

### §1.4 `kds_release_authorized_by` 값 — `release_kds_after_payment()`와의 차이, 의도적

`release_kds_after_payment()`는 `'SYSTEM'`을 하드코딩한다(`0157`). 신규 함수는 `p_actor_type` 파라미터를 받아 호출자가 실제 주체(웹훅=`'PROVIDER'`, 향후 POS 연동 시=`'SYSTEM'` 또는 스태프)를 전달하게 한다 — 두 함수가 공존하는 동안 `payment_ledger.kds_release_authorized_by`에 서로 다른 관례가 생기는 것은 감내할 만한 차이로 판단한다(둘 다 자유 텍스트 컬럼, 제약 위반 없음). `601031_Overview.md` §6 (b)에서 POS 경로도 이 신규 함수로 전환하면 이 차이는 자연히 사라진다.

## §2 `confirm_payment_from_provider()`(`0027`) 수정 설계

### §2.1 변경 지점 — 기존 `kds_release_authorized:false` INSERT는 유지, 새 호출을 추가

`payment_ledger` INSERT 자체는 **변경하지 않는다** — `kds_release_authorized := false`로 계속 시작한다(특허1 원칙: "결제 승인"과 "KDS 릴리즈 승인"은 논리적으로 분리된 순간이어야 한다는 서술 자체는 유효한 설계 의도이며, 신규 함수의 Step 1이 그 다음 순간 `true`로 전환한다 — 순간의 간격이 매우 짧아졌을 뿐, 두 단계가 존재한다는 사실 자체는 보존된다). `kds_tickets.conditions_met` 병합 UPDATE(`0027:301-309`)와 `kds_events` INSERT(`0027:314-331`)도 그대로 둔다(감사 추적 가치, `601032_Logic.md`가 아니라 이미 `600592_Logic.md` §2.2가 동일 판단을 내린 바 있음).

**기존 `audit_id` 계산 직후, `return` 직전에 추가**:

**(Stage 4 재정정, 2026-07-18 — ChatGPT 교차검증 + Human 최종 결정, "옵션 C")** 아래 블록은 `request_kds_release_after_payment()` 호출 **그 자체만** 좁은 중첩 `begin...exception...end`로 감싼다 — 이 지점 이전(intent 검증, `payment_ledger` INSERT, `kds_tickets`/`kds_events` 갱신, 이 함수 자신의 `append_audit_record()` 호출)은 전혀 감싸지 않고 그대로 둔다. 근거와 이전 설계(Option A/B)와의 차이는 §2.2 참고.

```sql
-- (옵션 C) request_kds_release_after_payment() 호출만 좁게 감싼다 —
-- 이 begin의 시작점이 이 함수 자신의 payment-core 작업(위의 payment_ledger
-- INSERT 등) *이후*이므로, 이 블록 안에서 예외가 발생해도 그 이전 작업은
-- 롤백되지 않는다(중첩 begin/exception 블록은 자신의 시작점까지만 롤백하는
-- 서브트랜잭션을 형성한다 — pg_temp로 라이브 실증, §2.2 참고).
begin
  v_kds_release_result := catchmenu_payment.request_kds_release_after_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_intent.order_id,
    p_ledger_id := v_ledger_id,
    p_actor_type := 'PROVIDER',
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    -- 정상 운영 중에는 도달 불가능해야 한다(§1.2) — 신규 함수는 이미 자신의
    -- 모든 내부 예외를 삼키도록 설계됐다. 이 핸들러가 실행됐다는 것은 신규
    -- 함수 자신의 안전장치 자체에 버그가 있어 정말로 예외가 새어나온
    -- 극단적 상황이라는 뜻이다. 결제 자체는 이미 성공했으므로(위의
    -- payment_ledger INSERT는 이 블록의 시작 이전에 완료돼 안전하다),
    -- 신규 함수 자신이 RELEASE_FAILED를 반환했을 때와 동일한 형태로
    -- 통일해서 반환한다 — 호출자 입장에서 "신규 함수 내부에서 잡힌 실패"와
    -- "신규 함수 호출 자체가 실패"를 구분할 필요가 없다.
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'payment',
      p_audit_type := 'kds_release_call_unexpected_exception',
      p_audit_category := 'FINANCIAL',
      p_actor_type := 'PROVIDER',
      p_actor_id := null,
      p_subject_type := 'payment_ledger',
      p_subject_id := v_ledger_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate
      ),
      p_order_id := v_intent.order_id,
      p_correlation_id := p_correlation_id
    );
    v_kds_release_result := jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', v_ledger_id,
      'order_id', v_intent.order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized',
    (v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'),
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_release_result', v_kds_release_result,
  'result_code', v_kds_release_result->>'result_code',
  'reconciliation_status', 'PENDING',
  'message_code', case
    when v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'
      then 'payment_approved_kds_released'
    else 'payment_approved_kds_pending'
  end,
  'audit_id', v_audit_id
);
```

**(Stage 4 검증에서 지적된 하드코딩 정정)** `v_kds_release_result`는 `declare` 블록에 `jsonb` 타입으로 추가. 기존 반환값의 `'kds_release_authorized', false`/`'next_step', 'KDS_CAPACITY_CHECK_REQUIRED'`는 제거(더 이상 사실이 아님 — 이 시점에는 이미 요청이 끝났다).

**정정 전 문제**: `'kds_release_authorized', true`를 무조건 하드코딩했었다 — `result_code`가 `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD`/`RELEASE_BLOCKED`/`RELEASE_FAILED`여도 응답은 항상 `true`를 보고해, 호출자(Toss/VAN)가 `result_code`를 별도로 파싱하지 않으면 "KDS가 실제로 방출됐다"고 오인할 위험이 있었다.

**정정 방식과 의미 변경 명시**: 이 응답 필드의 값을 `payment_ledger.kds_release_authorized` **DB 컬럼 값**이 아니라 `result_code`로부터 파생시킨다 — 즉 이 시점 이후 DB 컬럼 자체는 항상 `true`(§1.2 Step 1에서 결과와 무관하게 무조건 승인)이지만, **응답 필드는 "실제로 KDS 방출(COMMITTED)까지 끝났는가"라는 더 유용한 신호로 의도적으로 재정의**한다 — 원본 DB 컬럼 값과 응답 필드 값이 이 시점부터 다른 의미를 갖게 되는 것은 이 워크패킷의 명시적 설계 결정이며, 혼동을 막기 위해 이 사실을 여기 명시적으로 기록한다. `result_code` 필드 자체도 응답에 계속 노출되므로, 호출자는 필요시 더 세분화된 상태(`PARTIAL_CAPACITY_HOLD` vs `CAPACITY_HOLD` 등)를 직접 확인할 수 있다.

### §2.2 왜 함수 전체가 아니라 호출부만 좁게 감싸는가 — 옵션 C (ChatGPT 교차검증, Human 최종 결정, 재논의 금지)

**이전 설계(Option A/B)의 문제**: 이전 라운드는 "`confirm_payment_from_provider()` **자신**에도 `EXCEPTION` 핸들러를 추가할지"를 이분법(포함/제외)으로 물었다. 그런데 이 질문 자체가 애매했다 — "추가한다"는 것이 함수 **전체**를 감싸는 것인지, `request_kds_release_after_payment()` 호출 지점만 감싸는 것인지 명시하지 않았다. 만약 문자 그대로 이 함수의 기존 단일 최상위 `begin ... end;` 블록(현재 `declare` 바로 다음, intent 검증보다도 앞)에 `exception` 절만 덧붙이는 방식(Option A가 실제로 그렇게 작성돼 있었다)으로 구현했다면, PL/pgSQL의 중첩 예외 블록 동작 원리상(§2.1의 pg_temp 실증 참고 — 예외 블록은 **자신이 시작된 지점까지만** 롤백하는 서브트랜잭션을 형성한다) 그 최상위 블록의 시작점이 함수의 맨 처음이므로, `request_kds_release_after_payment()` 호출(함수 끝부분)에서 발생한 예외라도 그 핸들러가 잡는 순간 **함수 시작부터 그 시점까지의 모든 작업**(intent 상태 갱신, `payment_ledger` INSERT, `kds_tickets`/`kds_events` 갱신, 이 함수 자신의 감사기록까지)이 전부 롤백된다 — ChatGPT가 정확히 지적한 위험이다: KDS 알림이라는, 원래 결제 성공과 무관하게 격리돼야 할 보조 단계의 버그가 정작 이미 정상적으로 완료된 결제 승인 자체를 무효화시켜버리는 것 — 이 워크패킷 전체의 목적(결제확정 성공과 KDS 방출 실패의 격리, §0/`601031_Overview.md` §2)과 정반대의 결과를 낳는다.

**옵션 C 해법**: `EXCEPTION` 핸들러를 함수의 기존 최상위 블록이 아니라, `request_kds_release_after_payment()` 호출 **그 자체만**을 감싸는 신규 중첩 `begin...exception...end` 블록에 붙인다(§2.1의 최종 SQL). 이 중첩 블록의 시작점이 이미 `payment_ledger` INSERT 등 payment-core 작업이 전부 끝난 **이후**이므로, 이 블록 안에서 발생하는 예외는 그 이전 작업을 전혀 건드리지 않는다 — 2026-07-18 `pg_temp`로 직접 실증(§2.1 참고, 아래 검증 결과 요약).

**payment-core 로직(intent 검증 ~ `payment_ledger` INSERT ~ 이 함수 자신의 감사기록)은 이전과 마찬가지로 전혀 감싸지 않는다** — 이 구간에서 실패하면 예외가 자연스럽게 함수 밖으로 전파되어 호출자(Toss/VAN 웹훅 핸들러)가 이를 진짜 결제 실패로 인식한다(옵션 B와 동일한 부분). 옵션 C는 "함수 전체 EXCEPTION 포함(A)이냐 제외(B)냐"라는 양자택일이 아니라, **애초에 그 이분법이 잘못 설정된 질문이었음을 바로잡은 하나의 개선된 설계**다 — Human 승인은 이제 이 하나의 설계를 적용할지 여부만 확인하면 된다(§9).

**PL/pgSQL 중첩 예외 블록 검증 결과 (2026-07-18, `pg_temp`로 라이브 실증)**:

```sql
-- outer_fn()이 (1) "payment-core" INSERT를 먼저 실행하고, (2) 그 다음
-- 존재하지 않는 함수를 호출해 강제로 예외를 유발하는 좁은 내부 블록을
-- 실행한다.
create function pg_temp.outer_fn() returns jsonb language plpgsql as $fn$
declare
  v_ledger_id uuid := gen_random_uuid();
  v_kds_release_result jsonb;
begin
  insert into pg_temp.tmp_optionc_ledger_stub (id, status) values (v_ledger_id, 'APPROVED');
  begin
    select pg_temp.nonexistent_kds_release_fn(v_ledger_id) into v_kds_release_result;
  exception
    when others then
      v_kds_release_result := jsonb_build_object(
        'success', true, 'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
        'caught_sqlstate', sqlstate
      );
  end;
  return jsonb_build_object('ledger_id', v_ledger_id, 'kds_release_result', v_kds_release_result);
end;
$fn$;
```

결과: `outer_fn()` 호출은 `{"kds_release_result": {"success": true, "result_code": "PAYMENT_CONFIRMED_KDS_RELEASE_FAILED", "caught_sqlstate": "42883"}}`을 정상 반환했고(예외가 함수 밖으로 새어나가지 않음), **"payment-core" INSERT가 이 내부 블록의 예외 이후에도 살아남아 있음을 확인**(`select count(*) from pg_temp.tmp_optionc_ledger_stub` → `1`). 문법적으로도 지역변수(`v_kds_release_result`)를 내부 블록 안에서 대입하고 바깥 블록에서 그대로 읽는 데 아무 문제가 없었다(`declare` 재선언 불필요, 스코프가 자연스럽게 공유됨) — Postgres 문서가 이미 서술하는 "예외 절이 있는 블록은 자신의 시작점에 암묵적 세이브포인트를 만든다"는 동작이 이 프로젝트의 실제 스키마 위에서도 그대로 성립함을 실증했다.

**옵션 A의 핸들러와 이 좁은 블록의 핸들러가 여전히 서로 다른 "실패 의미 계층"을 가진다는 점은 유지된다** — payment-core 구간(감싸지 않음)의 예외는 여전히 "결제 자체 실패"이고, 이 좁은 블록(§2.1)의 예외는 "결제는 성공, KDS 호출 메커니즘 자체에 예상 못 한 버그"다. 다만 이제는 함수 전체를 감싸는 별도의 바깥쪽 핸들러(과거 Option A)가 존재하지 않으므로, "결제 자체 실패"는 여전히 이 함수 자체의 예외 전파(payment-core 구간에서 raise된 예외가 그대로 밖으로 나가는 것)로만 표현된다 — 이는 옵션 B와 동일하다.

## §3 설계 검증 — `pg_temp` 라이브 재현 3건 완료 (2026-07-18)

**(Stage 4 검증에서 지적된 §3/§6(e)/Snapshot 간 표현 불일치 정정)** 아래 3개 시나리오는 **실제로 `pg_temp`에 §1.2/§1.2-수정판 함수를 그대로 정의해 라이브로 재현했다** — 개념 검토가 아니라 실행 결과를 직접 확인한 것이다(AGENTS.md §3.8 — 이 워크패킷 ChangeContract가 아직 없으므로 트랜잭션 밖 영구 객체는 생성하지 않았고, 전부 `begin;...rollback;` 안에서 실행 후 흔적 없이 제거됨). **다만 "이 세션이 검증을 완료했다"는 것이 "Stage 5/8/9가 검증을 생략해도 된다"는 뜻은 아니다** — 이 세션의 표준 원칙대로, 각 fixture는 Stage 5(TestPlan)/Stage 8-9(구현·독립검증) 각자가 **자기 자신의 새 데이터로 다시 재현**해야 하며, 아래 결과를 그대로 재신뢰해서는 안 된다. §6 (g)에 이 구분을 별도 Open Item으로 명시한다.

### §3.1 시나리오 1(정상 경로) — 재현 완료

fixture: `catchmenu_pos.orders`에 주문 1건(`order_number='CV601030-TEST1'`) + `catchmenu_payment.payment_intents`/`payment_ledger` 각 1건(`kds_release_authorized=false`로 시작) + `catchmenu_kds.kds_tickets`에 `ticket_number='T-CV601030-1'`, `conditions_met={"arrived":true,"table_confirmed":true,"payment_confirmed":true}`인 `HOLD` 티켓 1건. `request_kds_release_after_payment()` 호출 결과: `result_code:'PAYMENT_CONFIRMED_KDS_COMMITTED'`, `committed_count:1`, 티켓 `kds_status`가 실제로 `COMMITTED`로 전이, `payment_ledger.kds_release_authorized`가 `true`로 갱신됨을 확인.

### §3.2 시나리오 2(KDS 쪽 예외) — 재현 완료

동일 패턴의 fixture(`order_number='CV601030-TEST2'`, `ticket_number='T-CV601030-2'`)에, `catchmenu_kds.kds_events`에 `commit_kds_ticket()`이 성공 시 쓰는 `event_type='all_conditions_met'`만 정확히 겨냥한 임시 `CHECK` 제약(`tmp_block_all_conditions_met`)을 추가해(`0163 §9`/`600663 §2.4`와 동일 기법), `commit_kds_ticket()`(→`bulk_commit_kds_tickets()`) 내부에서 강제로 예외(`sqlstate='23514'`)를 유발했다. 결과:

- `request_kds_release_after_payment()`는 예외를 재전파하지 않고 `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', error_detail:{sqlstate:'23514'}}`를 정상적으로 반환했다.
- **결정적 확인**: 이 호출보다 먼저 INSERT됐던 `payment_ledger` 행(위 fixture의 그 행, "결제는 이미 확정된 상태"를 시뮬레이션)이 예외 이후에도 트랜잭션 안에서 그대로 조회됨(`ledger_status='APPROVED'`, `approved_amount=15000` 그대로) — §2 원칙("결제확정 성공은 KDS 방출 실패로부터 격리되어야 한다")이 실제로 지켜짐을 실증했다.
- `commit_kds_ticket()` 자신의 UPDATE(티켓을 `COMMITTED`로 전이시키려던 것)는 정상적으로 롤백되어 티켓이 `HOLD`로 남았다 — `600652_Logic.md` §9.2가 이미 확립한 원자성 성질(예외 발생 시 그 함수 자신의 작업만 롤백되고, 더 이전에 이미 완료된 호출자의 작업은 영향받지 않음)이 이 새 설계에서도 동일하게 성립함을 확인.

### §3.3 시나리오 3(0-티켓, §1.2 수정판) — 재현 완료

`order_number='CV601030-ZEROTICKET'`, `payment_ledger` 1건은 있으나 **`kds_tickets` 자체를 생성하지 않은** fixture(이미 완전히 처리된 주문에 대해 웹훅이 재전송되는 상황을 시뮬레이션). 정정 전 로직으로는 `committed_count:0/pending_count:0/skipped_count:0`이 `'PAYMENT_CONFIRMED_KDS_COMMITTED'`로 잘못 분류됐으나, 정정 후 로직(§1.2)으로 재현한 결과 `result_code:'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'`가 정확히 반환됨을 확인했다 — `bulk_commit_kds_tickets()` 자신의 `message_code:'no_tickets_committed'`와도 의미가 일치한다.

세 시나리오 모두 재현 SQL은 이 문서에 직접 포함하지 않았다(임시 검증 스크립트, `.sql` 파일로 저장하지 않음, 트랜잭션 종료 시 전부 롤백되어 라이브에 흔적 없음).

## §4 멱등성(웹훅 재전송) — Open Item 재확인, 이번 문서에서 설계하지 않음

`601032_Logic.md`(이 문서) 작성 과정에서도 `confirm_payment_from_provider()` 자체의 재호출(Toss가 같은 웹훅을 중복 전송하는 경우) 시 신규 함수가 어떻게 동작할지 확인이 필요하다는 점을 재확인했다 — `request_kds_release_after_payment()`는 이미 `COMMITTED`된 티켓에 대해 다시 호출돼도 `bulk_commit_kds_tickets()`가 `HOLD`/`CAPACITY_CHECKING` 상태의 티켓만 대상으로 순회하므로(§1 시그니처 재확인) 안전할 것으로 **추정**되나, 이는 `confirm_payment_from_provider()` 자체의 상위 레벨 멱등성 처리 여부에 달린 문제이지 신규 함수의 책임 범위가 아니다 — Open Item으로 유지(`601031_Overview.md` §6 (e)).

## §5 마이그레이션 파일 배치 (Stage 8 대상, 이번 문서는 설계만)

Human이 방향(이번엔 이미 확정됨)에 따라 Stage 5에서 다음 마이그레이션 번호를 확정한다(이 문서 작성 시점 기준 `0165`가 최신 — Stage 5 직전 재확인 필요). `0027` 원본 소스 텍스트는 수정하지 않고 `CREATE OR REPLACE`로만 라이브 정의를 덮어쓴다. 신규 `error_codes`/`message_catalog` 항목은 필요 없을 것으로 예상(신규 함수는 클라이언트에 직접 노출되는 `error_key` 기반 실패를 반환하지 않고 `result_code` 필드만 씀 — `build_error_response()`를 쓰지 않는 설계이므로 `error_codes` 등록 불필요) — Stage 5에서 재확인.

## §6 Open Items (`601031_Overview.md` §6과 완전히 동일한 (a)-(h) 목록을 공유)

**(Stage 4 Critical tier — Cursor+Codex 지적사항 반영)** 이 목록은 `601031_Overview.md` §6과 글자 그대로 동일한 항목/순서를 유지한다 — 두 문서가 서로 다른 내용을 같은 문자에 담고 있던 이전 상태(예: 이 문서의 옛 (d)가 Overview의 (e)와 다른 항목이었던 것)를 정정.

(a) `CAPACITY_CHECKING` 재시도 메커니즘 부재 — 별도 워크패킷 필요(`601031_Overview.md` §3/§6 (a)).
(b) `confirm_payment()`(POS, `0098`)를 동일 신규 함수로 연결 — 최우선 후속 워크패킷 후보(§6 (b)).
(c) `resolve_payment_uncertain()` 분리 — 재확인, 이번엔 다루지 않음(§6 (c)).
(d) `bulk_commit_kds_tickets()`의 UI/Flutter 호출자 존재 여부 — SQL 레이어 밖, 미확정(`601031_Overview.md` §6 (d), 이전에 이 문서에서 누락돼 있었음).
(e) **[High priority — Stage 4에서 격상]** 웹훅 멱등성(재전송) 시나리오 — §4에서 상세 설계 부재 확인, Stage 5 이전 확인 필요. **격상 근거**: Cursor+Codex 둘 다 "스코프 제외는 타당하나 실제 운영 위험이 크다"고 지적 — §1.2 item 1의 0-티켓 `result_code` 수정 자체가 이 시나리오(이미 완전히 처리된 주문에 대한 웹훅 재전송)의 실질적 위험을 방증한다.
(f) 도메인 번호 공간 소진(`601031_Overview.md` §0/§6 (f)) — 이 워크패킷 범위 밖, Human 결정 필요.
(g) §3의 `pg_temp` 재현 3건은 이 세션이 직접 수행한 것이나, Stage 5/8-9는 각자 자기 자신의 새 fixture로 독립 재현해 재확인해야 한다 — "이 세션이 검증했다"가 "다음 Stage가 검증을 생략해도 된다"는 뜻으로 오독되지 않도록 명시(`601031_Overview.md` §6 (g)와 동일, Stage 4에서 §3/§6/Snapshot 간 표현 불일치 지적을 해소하며 신설).

(h) **[신규, 2026-07-18, `p_decision='PENDING'` 결함 수정 중 부수적으로 발견 — canonical 위치는 `601034_ChangeContract.md` §8 (h), 이 항목은 교차참조용 사본]** `catchmenu_audit.append_audit_record()`를 호출하는 다른 기존 라이브 함수 **7개 파일**에서도 `chk_audit_decision`(`0008:105-119`)의 11개 허용값에 없는 리터럴을 `p_decision`에 전달하고 있음을 발견했다 — 리터럴 개수로는 **8개**(타겟 grep 기준 — 전수조사 아님, 그 이상일 수 있음): `0084`(`'RESOLVED'`), `0085`(`'PUBLISHED'`), `0086`(`'PUBLISHED'`), `0087`(`'ROLLED_BACK'`), `0091`(`'GO_LIVE_AUTHORIZED'`), `0098`(`'REFUND_PENDING'`), `0100`(같은 파일 안에 `'OPENED'`/`'CLOSED'` 2개 — 이 파일이 리터럴 수를 파일 수보다 1개 더 많게 만드는 원인). 실행되면 이번 워크패킷에서 고친 것과 동일한 방식(제약 위반 → INSERT 크래시)으로 실패할 가능성이 높다. 이 워크패킷은 이 7개 파일 중 어느 것도 건드리지 않으며, 별도의 독립 감사(가칭 `audit_decision_literal_repair`) 워크패킷 후보로만 기록한다. 최신·상세 버전은 `601034_ChangeContract.md` §8 (h)를 참조 — 두 문서가 서로 어긋나면 `601034`가 우선한다(ChangeContract가 Human Approval의 근거 문서이므로).

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Stage 5(TestPlan/ChangeContract) 착수 가능한 수준까지 설계 완료.** 신규 함수 `catchmenu_payment.request_kds_release_after_payment()`는 `bulk_commit_kds_tickets()`를 재사용하는 얇은 오케스트레이션 계층으로 설계했다(§1) — 스스로 모든 예외를 삼키고 항상 `success:true`를 반환해, 결제확정 성공이 KDS 방출 실패로부터 격리되도록 했다(§1.2/§2 원칙 재적용). `confirm_payment_from_provider()`는 이 신규 함수를 호출하도록 수정하되, **(2026-07-18 재정정, 옵션 C)** 방어적 `EXCEPTION` 핸들러를 함수 전체가 아니라 `request_kds_release_after_payment()` 호출 지점만 감싸는 좁은 중첩 블록으로 한정했다 — 함수 전체를 감싸면 이 호출부에서 발생한 예외가 이미 완료된 payment-core 작업(`payment_ledger` INSERT 포함)까지 롤백시켜버리는 위험을 ChatGPT 교차검증이 지적했고, 이를 `pg_temp`로 직접 실증해 좁은 중첩 블록만이 안전함을 확인했다(§2.1/§2.2). "payment-core 구간의 예외=결제 실패"와 "이 좁은 블록의 예외=결제 성공/KDS 호출 메커니즘만 실패"라는 두 계층의 의미 차이는 여전히 설계 자체로 구분된다(§2.2). 원자성 가설(예외 발생 시 그 블록 자신의 작업만 롤백되고 그 이전에 이미 완료된 작업은 보존된다)은 이 세션이 `pg_temp`로 4개 시나리오(정상 경로/KDS 예외/0-티켓/옵션 C 좁은 블록)의 재현을 완료해 실증했다(§2.1/§2.2/§3) — 다만 이 완료가 Stage 5/8-9의 독립 재검증 의무를 대체하지 않는다는 점을 §6 (g)에 명시했다.

**(Stage 4 Critical tier 정정 반영, 2026-07-18)** Cursor+Codex가 지적한 3가지 결함을 이번 정정에서 해소했다: (1) 0-티켓 시나리오를 위한 신규 `result_code`(`PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`) 추가 및 `pg_temp` 재검증(§1.2/§3.3), (2) §3의 "완료" 서술과 §6/Snapshot의 "미완료" 서술 간 모순을 §3 재작성으로 해소(§3/§6 (g)), (3) §2.1 반환값의 `kds_release_authorized` 하드코딩을 `result_code` 파생 값으로 교체, (4) 웹훅 멱등성 Open Item을 High priority로 격상(§6 (e)), (5) 이 문서와 `601031_Overview.md`의 §6 Open Items를 (a)-(g) 동일 목록으로 동기화.
