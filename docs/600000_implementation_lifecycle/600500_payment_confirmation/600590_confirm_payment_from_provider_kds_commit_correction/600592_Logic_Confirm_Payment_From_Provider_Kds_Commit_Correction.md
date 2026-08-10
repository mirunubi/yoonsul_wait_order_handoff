# 600592_Logic_Confirm_Payment_From_Provider_Kds_Commit_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`confirm_payment_from_provider_kds_commit_correction`

## §0 이 문서의 성격 — 두 방향을 모두 설계, 결정은 하지 않음

`600591_Overview.md` §3이 방향 A(용량확인 게이트 연동)/방향 B(단순화, `release_kds_after_payment()` 직접 호출)를 사실 근거와 함께 제시했다. 이 Logic 문서는 **둘 중 하나를 채택하지 않고, 둘 다 Stage 5(TestPlan/ChangeContract) 착수 가능한 수준까지 설계**한다 — Human이 §1.3에서 하나를 선택하면 다음 Stage는 선택된 쪽만 진행한다.

## §1 방향 A — 용량확인 게이트 연동

### §1.1 필요한 추가 단계 — 단순히 `bulk_commit_kds_tickets()`만 호출하면 안 되는 이유

`confirm_payment_from_provider()`는 `payment_ledger` INSERT 시점에 **명시적으로** `kds_release_authorized := false`를 세팅한다(특허1 원칙, `0027` 원문 그대로 보존). `bulk_commit_kds_tickets()`(`0039`)는 시작하자마자 `payment_ledger.kds_release_authorized`를 확인하고, `false`면 즉시 `kds_release_not_authorized` 에러를 반환한다(`0039:38-53`, 라이브 재확인). 즉 `confirm_payment_from_provider()`가 곧바로 `bulk_commit_kds_tickets()`를 호출하면 **매번 100% 실패**한다.

원래 이 간극을 메우던 함수가 `catchmenu_kds.authorize_kds_release()`(`0028`)였으나, `0157`에서 DROP됐다(`600591_Overview.md` §1.2). 따라서 방향 A는 그 기능을 **`confirm_payment_from_provider()` 자신이 인라인으로** 수행해야 한다 — `release_kds_after_payment()`가 이미 하고 있는 것과 동일한 패턴(`payment_ledger.kds_release_authorized`를 직접 `true`로 UPDATE)이다.

### §1.2 설계 — 인라인 authorize + `bulk_commit_kds_tickets()` 호출

```sql
-- confirm_payment_from_provider() 본문 마지막(기존 audit_id 계산 직후, return 직전)에 추가:

-- 방향 A: 특허1의 "결제승인≠KDS릴리즈" 분리를 유지하되, authorize_kds_release()가
-- 0157에서 DROP됐으므로 release_kds_after_payment()와 동일한 인라인 패턴으로 승인 처리.
update catchmenu_payment.payment_ledger
set
  kds_release_authorized = true,
  kds_release_authorized_at = now(),
  kds_release_authorized_by = 'PROVIDER'
where id = v_ledger_id;

v_bulk_commit_result := catchmenu_kds.bulk_commit_kds_tickets(
  p_tenant_id := p_tenant_id,
  p_store_id := p_store_id,
  p_order_id := v_intent.order_id,
  p_force_conditions := null,
  p_correlation_id := p_correlation_id
);

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized', true,
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_commit_result', v_bulk_commit_result,
  'reconciliation_status', 'PENDING',
  'message_code', 'payment_approved_kds_committed',
  'audit_id', v_audit_id
);
```

`v_bulk_commit_result`는 `declare` 블록에 `jsonb` 타입으로 추가 선언 필요. `next_step: 'KDS_CAPACITY_CHECK_REQUIRED'`는 이 시점에 실제로 용량확인까지 끝났으므로 응답에서 제거(또는 `bulk_commit_kds_tickets()`의 `pending_count > 0`이면 `'KDS_CAPACITY_RETRY_REQUIRED'`로 대체 — 7조건 중 `kds_capacity_ok`가 그 순간 `false`면 티켓이 `COMMITTED`가 아니라 `CAPACITY_CHECKING`에 머물 수 있으므로, 이 경우 "누가 재시도를 트리거하는지"가 새 Open Item이 된다 — §3 (a)).

### §1.3 방향 A가 만드는 새로운 질문 (설계상 불가피, 결정 필요)

- `bulk_commit_kds_tickets()`가 `pending_count > 0`(용량 부족으로 일부만 `CAPACITY_CHECKING`에 머묾)을 반환하면, 웹훅/VAN 경로에는 이걸 재시도시킬 주체가 없다(정상 경로도 마찬가지지만, 정상 경로는애초에 이 상태에 도달하지 않으므로 이 질문 자체가 생기지 않았다). 이 워크패킷이 그 재시도 메커니즘까지 설계할지는 별도 판단 필요.
- `kds_release_authorized_by := 'PROVIDER'`(제안값) — `release_kds_after_payment()`는 `'SYSTEM'`을 쓴다(`0157`). 웹훅이 실제 승인 주체이므로 `'PROVIDER'`가 더 정확해 보이지만, `payment_ledger.kds_release_authorized_by`가 이미 `text` 자유 필드라 제약 위반 위험은 없다 — 다만 이 값을 소비하는 리포팅/대시보드가 있다면 새 값 도입이 영향을 줄 수 있어 Open Item으로 남긴다.

## §2 방향 B — 단순화, `release_kds_after_payment()` 직접 호출 (`confirm_payment()`와 동형)

### §2.1 설계 — `confirm_payment()`의 정확한 호출 패턴을 그대로 재사용

```sql
-- confirm_payment_from_provider() 본문 마지막(기존 audit_id 계산 직후, return 직전)에 추가:
-- confirm_payment()(0098:708-716)와 정확히 동일한 패턴 — p_locale은 파라미터가 없으므로 'ko' 하드코딩.

v_kds_release_result := catchmenu_payment.release_kds_after_payment(
  p_tenant_id := p_tenant_id,
  p_store_id := p_store_id,
  p_order_id := v_intent.order_id,
  p_ledger_id := v_ledger_id,
  p_locale := 'ko',
  p_correlation_id := p_correlation_id
);

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized', true,
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_release_result', v_kds_release_result,
  'reconciliation_status', 'PENDING',
  'message_code', 'payment_approved_kds_committed',
  'audit_id', v_audit_id
);
```

`v_kds_release_result`는 `declare` 블록에 `jsonb` 타입으로 추가 선언 필요. `next_step: 'KDS_CAPACITY_CHECK_REQUIRED'`는 제거(`release_kds_after_payment()`는 조건부 대기 상태를 만들지 않고 항상 즉시 커밋하거나 0건 커밋 후 경고 로그만 남기므로, "다음 단계 대기"라는 개념 자체가 방향 B에는 없다).

### §2.2 이 함수 자신의 기존 `conditions_met` UPDATE와의 관계 — 그대로 둔다

`confirm_payment_from_provider()`는 이미 `kds_tickets.conditions_met`에 `payment_confirmed:true`를 병합하는 UPDATE(`0027:301-309`)와 `kds_events` INSERT(`0027:314-331`)를 갖고 있다. `release_kds_after_payment()`는 뒤이어 `conditions_met`를 **완전히 새 객체로 덮어쓴다**(`0157:91-96`, `||` 병합이 아니라 대입) — 값 결과는 동일(`payment_confirmed:true`가 최종적으로 남음)하므로 충돌은 없지만, 확인 순서상 앞의 UPDATE가 사실상 즉시 덮어써지는 중간 상태가 된다. 이 워크패킷은 기존 코드를 그대로 유지한다(`kds_events`의 `payment_confirmed_released` 이벤트 자체는 감사 추적 가치가 있어 삭제하지 않음) — 순수하게 추가만 하는 최소 변경.

### §2.3 방향 B가 만드는 새로운 질문

- `confirm_payment()`가 이미 갖고 있던 "0건 커밋 시 WARNING 로그"(`0157`, `v_released_count = 0`) 동작이 웹훅/VAN 경로에도 그대로 적용된다 — 이 자체는 방향 B의 일관성 장점이지만, Toss 웹훅이 중복 전송되는 경우(이미 커밋된 주문에 대해 재호출) 이 WARNING이 노이즈성으로 반복될 수 있다는 점은 확인 필요(§3 (b)).

## §3 두 방향 공통 Open Items

(a) 방향 A를 택할 경우 `CAPACITY_CHECKING`에 머문 티켓의 재시도 주체 — 미설계.
(b) 웹훅 중복 전송(재시도) 시나리오에서 두 방향 모두 `confirm_payment_from_provider()`의 멱등성 처리가 어떻게 되는지 — 이번 조사에서 별도 확인하지 않음, 원본 함수에 idempotency_key 기반 처리가 있는지 재확인 필요(`create_payment_intent()`에는 있으나 `confirm_payment_from_provider()` 자체에는 `0038`/`0056` 호출부의 상위 레벨 idempotency에 의존하는 것으로 보임 — 미확정).
(c) 두 방향 모두 `v_kds_updated`(현재 `HOLD`/`CAPACITY_CHECKING` 티켓 개수)가 0이었던 경우(예: 이미 다른 경로로 처리된 주문) 새로 추가되는 호출을 그대로 실행해도 안전한지 — `release_kds_after_payment()`/`bulk_commit_kds_tickets()` 둘 다 "대상 티켓 0건"을 에러가 아니라 정상 케이스(카운트 0)로 처리하므로 안전할 것으로 판단되나, 라이브 재현 검증은 다음 Stage(TestPlan)에서 필요.

## §4 `resolve_payment_uncertain()` — 별도 워크패킷 권고 재확인

`600591_Overview.md` §4의 판단 근거를 그대로 유지한다 — 이 함수의 수정은 `payment_ledger`에 대한 **신규 INSERT 설계**(어떤 `ledger_entry_type`을 쓸지, `provider_payment_key`/`provider_approval_number`가 없는 상태를 어떻게 표현할지, 금액을 어디서 가져올지)가 필요해 방향 A/B 어느 쪽보다도 설계 범위가 크다. 이 문서는 그 설계를 진행하지 않는다 — Human이 분리를 승인하면 별도 Overview/Logic(가칭 `resolve_payment_uncertain_ledger_gap_correction`)에서 처음부터 설계한다.

참고로 `payment_ledger`의 관련 컬럼 재확인 결과(이번 턴 라이브 조회): `ledger_entry_type`/`ledger_status`/`approved_amount`/`net_amount`/`provider_type`(전부 `not null`), `provider_payment_key`/`provider_approval_number`/`provider_approved_at`/`provider_response_id`(전부 nullable). `provider_type`이 `not null`인데 `mark_payment_uncertain()`이 애초에 `provider_type` 자체를 파라미터로 받지 않으므로(`0027:432-438`), `resolve_payment_uncertain()`이 새 `payment_ledger` 행을 만들려면 `payment_intents.provider_type`(원래 `create_payment_intent()`가 저장한 값)을 다시 조회해야 한다는 것도 향후 설계에서 확인이 필요한 지점이다(이 문서에서는 설계하지 않고 기록만 함).

## §5 마이그레이션 파일 배치 (Stage 8 대상, 이번 문서는 설계만)

Human이 방향 A 또는 B를 선택한 이후, Stage 5(TestPlan/ChangeContract)에서 다음 마이그레이션 번호를 확정한다(이 문서 작성 시점 기준 `0165`가 최신 — 재확인 필요). `0027` 원본 소스 텍스트는 수정하지 않고 `CREATE OR REPLACE`로만 라이브 정의를 덮어쓴다(`0160`/`0163`/`0164`와 동일 기법). 신규 `error_codes`/`message_catalog` 항목은 두 방향 모두 필요 없을 것으로 예상(기존 등록된 키만 재사용) — Stage 5에서 재확인.

## §6 Open Items (Overview에서 이월)

(a) 방향 A/B 선택 — Human 결정 필요(§0/§1/§2).
(b) `resolve_payment_uncertain()` 분리 여부 — Human 결정 필요(§4).
(c) `bulk_commit_kds_tickets()`의 실제 호출자 존재 여부(Flutter 확인 필요, SQL 레이어 밖) — 방향 A의 실효성에 영향.
(d) `start_cooking()` 호출자 부재(`601024_ChangeContract.md` §5.4) — 이 워크패킷과 별개, 참고만.
(e) 900xxx 특허 문서의 "capacity" 서술 부재 — 별도 문서화 갭, 참고만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Human 결정 대기 — 두 방향 모두 Stage 5 착수 가능한 수준까지 설계 완료.** 방향 A(§1)는 `authorize_kds_release()`가 `0157`에서 DROP된 빈자리를 인라인 승인으로 메우고 `bulk_commit_kds_tickets()`를 호출하는 설계이며, 방향 B(§2)는 `confirm_payment()`의 `release_kds_after_payment()` 호출 패턴을 그대로 재사용하는 설계다. 두 방향 모두 파라미터가 이미 함수 본문 안에 존재해 호출 자체는 간단하지만, 각각 서로 다른 새 질문(§1.3/§2.3)을 만든다. `resolve_payment_uncertain()`의 형제 결함은 신규 `payment_ledger` INSERT 설계가 필요해 이 워크패킷보다 범위가 크다는 근거로 분리를 재확인했다(§4) — 최종 결정은 Human.
