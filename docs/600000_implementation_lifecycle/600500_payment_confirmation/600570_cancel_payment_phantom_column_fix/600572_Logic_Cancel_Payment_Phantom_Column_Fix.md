# 600572_Logic_Cancel_Payment_Phantom_Column_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`cancel_payment_phantom_column_fix`

## §0 전제 — Workpacket 1 범위 (`0037` correction only)

`600571_Overview.md` §8이 확정한 Workpacket 1 범위를 그대로 따른다: `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`의 `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()` 세 함수에서 `payment_ledger.updated_at`(실존하지 않는 컬럼) 참조만 제거한다. 상태 전이 로직, 금액 계산, 함수 시그니처, 다른 파일(`0098` 등)은 전부 무변경 — `600571_Overview.md` §8의 허용/금지 목록을 그대로 상속한다.

**활성 경로 복구임을 재확인**: `cancel_payment()`는 실제 호출자 2개(`0038` Toss 웹훅, `0056` VAN)를 가진 활성 함수다(`600571_Overview.md` §7.5.1) — 이 수정은 사용되지 않는 코드의 정리 작업이 아니라, 현재 크래시하고 있는 실제 콜백 경로(PG/VAN이 결제 취소를 통보할 때마다 실패하고 있었을 가능성)를 복구하는 작업이다.

## §1 최종 라이브 재확인 — UPDATE 문이 참조하는 모든 컬럼, 마지막 기회

지시문의 "또 다른 숨은 phantom이 있는지 이번이 마지막 기회"라는 요청에 따라, 세 함수의 `payment_ledger` UPDATE 문이 참조하는 전체 컬럼(`updated_at` 제외)을 이번 문서 작성 시점에 다시 한번 라이브로 재조회했다:

```sql
select column_name, data_type, is_nullable from information_schema.columns
where table_schema='catchmenu_payment' and table_name='payment_ledger'
  and column_name in ('ledger_status','cancelled_amount','net_amount',
    'kds_release_authorized','evidence_packet_id','refunded_amount','approved_amount','updated_at');
```
```
      column_name       | data_type | is_nullable 
------------------------+-----------+-------------
 approved_amount        | integer   | NO
 cancelled_amount       | integer   | NO
 evidence_packet_id     | uuid      | YES
 kds_release_authorized | boolean   | NO
 ledger_status          | text      | NO
 net_amount             | integer   | NO
 refunded_amount        | integer   | NO
```
질의한 8개 컬럼명 중 `updated_at`만 결과에 없다(7행만 반환) — **세 UPDATE 문이 `updated_at` 외에 참조하는 모든 컬럼(`ledger_status`/`cancelled_amount`/`net_amount`/`kds_release_authorized`/`evidence_packet_id`/`refunded_amount`)은 전부 실존하며 타입도 코드의 대입값과 일치한다**(`cancelled_amount`/`net_amount`/`refunded_amount`는 `integer`— 코드가 정수 계산 결과를 대입, `kds_release_authorized`는 `boolean`— 코드가 `false` 리터럴을 대입, `ledger_status`는 `text`— 코드가 문자열 리터럴/`case` 결과를 대입, `evidence_packet_id`는 `uuid`— 코드가 `v_evidence_id`를 대입). 추가로 숨은 phantom은 발견되지 않았다 — `600571_Overview.md` §2/§3/§4의 결론(각 함수당 `updated_at` 1건만)이 이번 최종 재확인으로도 그대로 유지된다.

## §2 `cancel_payment()` — 정확한 Before/After

```sql
-- Before (0037:101-109, 현재)
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;

-- After (설계안)
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```
변경은 `updated_at = now()` 한 줄과 그 앞 줄의 트레일링 콤마뿐이다(`evidence_packet_id = v_evidence_id,` → `evidence_packet_id = v_evidence_id`). 그 외 함수 본문 전체(파라미터, `evidence_packets` INSERT, `kds_tickets`/`orders`/`order_sessions` UPDATE, `payment_events`/`catchmenu_ledger.events` INSERT, `append_audit_record` 호출, 반환값)는 완전히 동일하게 유지한다.

## §3 `partial_cancel_payment()` — 정확한 Before/After

```sql
-- Before (0037:352-362, 현재)
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;

-- After (설계안)
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```
동일하게 `updated_at = now()` 한 줄만 제거. `case` 분기 로직, 금액 계산, 나머지 함수 본문은 완전히 동일하게 유지한다.

## §4 `refund_payment()` — 정확한 Before/After

```sql
-- Before (0037:603-610, 현재)
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;

-- After (설계안)
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```
동일 패턴. 이 함수 안의 별도 `catchmenu_pos.orders` UPDATE(`0037:613-620`)에 있는 `updated_at = now()`는 `orders` 테이블에는 실제로 존재하는 컬럼이므로(`600571_Overview.md` §4에서 이미 확인) **건드리지 않는다** — 이번 워크패킷은 `payment_ledger`의 `updated_at`만 제거 대상이다.

## §5 마이그레이션 설계 (Stage 4 대상, 이번 턴 미실행)

세 함수 모두 같은 파일(`0037`)에 있으므로, `0157`/`0158`이 그랬듯 하나의 신규 forward migration에서 세 함수 전부를 `create or replace function`으로 재정의한다(원본 `0037` 파일 자체는 무편집 유지, append-only 관례). 다음 candidate 번호는 Stage 4 착수 직전 재확인 필요(이번 문서 작성 시점 기준 `sql/migrations/` 최고 번호는 `0158`이므로 `0159`가 후보이나, Stage 4 시점에 다시 확인해야 한다).

## §6 Open Item — `refund_payment()`(호출자 0건) DROP 여부, 이번 워크패킷에서 결정하지 않음

`600571_Overview.md` §7.5.1이 확인한 대로 `refund_payment()`는 실제 호출자가 0건이며, `partial_cancel_payment()`도 마찬가지다. 이 두 함수를 이번 기회에 DROP할지, 아니면 `updated_at`만 고쳐서 향후 배선을 기다리는 상태로 남겨둘지는 **이번 워크패킷에서 판단하지 않는다** — `600571_Overview.md` §8의 Workpacket 1 허용 목록 자체가 "correction만 허용, 함수 통합·rename 금지"로 이미 DROP을 배제하고 있으며, Human 지시문("DROP 여부는 이번 워크패킷에서 결정하지 않고 별도 판단 대상으로 명시")과도 일치한다. 두 함수 모두 이번 워크패킷에서는 **살아있는 채로, `updated_at`만 고쳐서** 남긴다 — DROP 여부의 재판단은 별도 워크패킷(예: 호출자 0건 함수 전수 정리 워크패킷) 대상으로 이월한다.

이 Open Item은 `600571_Overview.md` §8의 Workpacket 2(환불 파이프라인 재설계)와도 다르다 — `refund_payment()`/`partial_cancel_payment()`의 DROP 여부는 원장 모델 재설계 문제가 아니라 단순 "미사용 코드 정리" 판단이므로, 필요하다면 Workpacket 2와도 별개인 세 번째 워크패킷으로 분리될 수 있다.

## §7 Open Items (그 외)

(a) §6의 DROP 판단 워크패킷 자체를 언제, 어떤 번호로 생성할지 — 이번 문서는 결정하지 않는다.
(b) `600571_Overview.md` §9 (f) — `cancel_payment()`의 `updated_at` 제거가 실제로 `0038`/`0056` 호출부에 어떤 변화를 일으키는지(그동안 Toss 웹훅/VAN의 결제 취소가 전부 실패해왔다는 뜻인지)는 TestPlan/Verification 단계에서 실제 호출 재현으로 확인해야 한다 — 이 Logic 문서는 설계만 다루고 검증은 하지 않았다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md`(Revision 2, §7.5/§8 — 이 문서의 직접 전제, Workpacket 1 범위와 허용/금지 목록).

### Full Rules Required

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`(L13-238)/`partial_cancel_payment()`(L241-479)/`refund_payment()`(L482-737), 수정 대상 3개 함수.
- `catchmenu_payment.payment_ledger` 라이브 스키마(28개 컬럼) — §1 최종 재확인의 근거.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`(`request_refund`/`confirm_refund`) — Workpacket 2, 이 문서는 다루지 않음.
- `refund_payment()`/`partial_cancel_payment()`의 DROP 여부(§6) — 별도 판단 대상, 이 문서는 결정하지 않음.
- `0102`/`0104`의 `p_refund_amount:=0` 호출 버그 — Workpacket 2 대상.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §1에서 세 함수의 `payment_ledger` UPDATE 문이 참조하는 전체 컬럼을 최종 재확인했다 — `updated_at` 외 추가 phantom은 없음을 재확인했다. §2/§3/§4에서 세 함수 각각의 정확한 Before/After를 설계했다 — 셋 다 `updated_at = now()` 한 줄 제거가 유일한 변경이며, 그 외 상태 전이/금액 계산/함수 시그니처는 완전히 동일하게 유지한다. §5에서 단일 forward migration으로 세 함수를 함께 재정의하는 마이그레이션 설계 방향을 제시했다. **§6에서 `refund_payment()`/`partial_cancel_payment()`의 DROP 여부를 이번 워크패킷 범위 밖으로 명시적으로 유보했다** — Human 지시와 일치. `600573_TestPlan.md`/`600574_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
