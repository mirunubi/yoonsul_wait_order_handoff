# 600532_Logic_Refund_Pipeline_Ledger_Status_Reconciliation.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-20

## Change ID

`refund_pipeline_ledger_status_reconciliation`

> 이 Logic은 `600531_Overview.md`를 전제로 한다.
>
> **조사·결정 상태 (2026-07-20 최종):** Cursor 조사 **C1~C4 전 게이트 PASS**, 설계 결정 **O1/O3/O4/O5/O7 확정**. 잠정 표시는 모두 해소됐다.
>
> **Stage 5 ChangeContract에서 확정값으로 고정해야 할 잔여 2건:** ① §4.2.1 `provider_response` payload 키 표현 ② §7.1 `get_payment_status()` 포함 여부. 둘 다 Stage 4 진입을 막지 않는다(Overview §0.3).

---

## §1 정정 원칙

이번 변경을 관통하는 원칙은 하나다.

> **구현을 스키마에 맞추지 않는다. 스키마를 다수 합의 어휘에 맞춘다.**
> 단, 그 원칙은 **도메인-로컬 어휘**에만 적용한다. **교차 도메인 공용 어휘는 확장하지 않고 매핑한다.**

이 비대칭이 §2와 §3을 가른다.

| 대상 | 성격 | 처리 |
|---|---|---|
| `payment_ledger.ledger_status` | **결제 도메인 로컬** 상태값. 설계문서 10개+가 `REFUND_PENDING`을, 6개가 `REFUND_FAILED`를 이미 사용 | **확장** (§2) |
| `audit_records.decision` | **교차 도메인 공용** 감사 어휘. 모든 도메인이 같은 11개 값을 공유 | **매핑** (§3) |

세 번째 축(오참조 식별자)은 어휘 문제가 아니라 단순 대조 오류이므로 실제 컬럼으로 교정한다(§4).

### §1.1 하지 않는 것

새 환불 절차·새 권한·새 상태 전이·부분환불 계산 규칙 변경을 **설계하지 않는다.** 이번 변경 후에도 환불의 업무 의미는 `0098`이 원래 의도한 것과 동일해야 한다. 달라지는 것은 "그 의도가 제약 위반 없이 실제로 실행되는가"뿐이다.

---

## §2 `chk_ledger_status` 확장

### §2.1 현재

`0014`(L212~223)가 정의한 8개 값. 이후 어떤 마이그레이션도 이 제약을 건드리지 않았다(601400 검사에서 `chk_ledger_status`를 참조하는 파일은 `0014` 단독으로 확인됨).

```
APPROVED, CANCELLED, REFUNDED, PARTIAL_CANCELLED,
PARTIAL_REFUNDED, UNCERTAIN, DISPUTED, UNDER_REVIEW
```

### §2.2 정정 후 (10개)

기존 8개를 **그대로 두고** 2개만 추가한다. 기존 값의 삭제·개명은 없다.

```
APPROVED, CANCELLED, REFUNDED, PARTIAL_CANCELLED,
PARTIAL_REFUNDED, UNCERTAIN, DISPUTED, UNDER_REVIEW,
REFUND_PENDING, REFUND_FAILED          ← 추가
```

### §2.3 형식

`0150_widen_event_domain_constraint.sql`이 확립한 패턴을 그대로 따른다(그 자신도 `0140/0145/0146/0147`의 선례를 인용한다).

```
alter table catchmenu_payment.payment_ledger
  drop constraint if exists chk_ledger_status;

alter table catchmenu_payment.payment_ledger
  add constraint chk_ledger_status check (
    ledger_status in ( ...10개... )
  );
```

> 위 블록은 **Stage 2 구현자를 위한 형태 예시**이며, 이 워크패킷은 `.sql` 파일을 만들지 않는다.

### §2.4 안전성 논거

- **확장(widening)이므로 기존 행이 위반될 수 없다.** 허용 집합에 값을 추가할 뿐 제거하지 않으므로, 현재 저장된 모든 `ledger_status` 값은 새 제약도 통과한다. 백필·데이터 마이그레이션이 불필요하다.
- `chk_ledger_amounts` 등 `payment_ledger`의 다른 제약은 건드리지 않는다.
- **(2026-07-20 정정)** 최초 판본은 "실호출자 0건이므로 확장 시점에 진행 중인 환불 트랜잭션이 없다"를 안전성 근거로 들었다. **C3 결과로 이 전제는 무효다** — `request_refund()`에는 실호출자 3건이 있다(Overview §1.2). 다만 **확장의 안전성 자체는 영향받지 않는다**: 허용값 추가는 진행 중 트랜잭션의 기존 write를 무효화하지 않으며, `DROP CONSTRAINT`/`ADD CONSTRAINT`는 `ACCESS EXCLUSIVE` 락을 짧게 잡을 뿐이다. 근거를 "호출자가 없어서 안전"에서 **"확장 연산의 성질상 안전"**으로 교체한다.
- 배포 시점 고려사항: 취소 트래픽이 낮은 시간대를 택하는 것이 바람직하다(락 구간 최소화). 이는 ChangeContract에서 다룬다.

### §2.5 왜 반대 방향(0098을 8개 값에 맞추기)이 아닌가

이론상 대안은 `0098`을 기존 8개 값으로 재작성하는 것이다. 기각 근거:

1. 설계문서 **10개 이상**이 `REFUND_PENDING`을 쓰고 있다. 스키마에 맞춰 구현을 고치면 **문서 10개+가 일제히 틀린 상태로 남는다.**
2. `REFUND_PENDING`이 표현하는 "PG에 환불을 요청했고 결과 대기 중"이라는 상태는 기존 8개 값 중 어느 것으로도 정확히 표현되지 않는다. `UNDER_REVIEW`(사람 검토 대기)나 `UNCERTAIN`(상태 불명)으로 눌러 담으면 **의미가 왜곡**되고, 조정(reconciliation) 로직이 사람 검토 큐와 PG 대기 큐를 구분할 수 없게 된다.
3. Human 결정(2026-07-20)이 이미 "다수 합의 어휘를 그대로 채택"으로 확정했다.

---

## §3 감사 리터럴 정정 — 확장이 아니라 매핑

### §3.1 문제

`0098`의 환불 경로가 `append_audit_record(p_decision := 'REFUND_PENDING', ...)`를 호출한다. `chk_audit_decision`(`0008` L105~119)의 허용값 11개에 `REFUND_PENDING`은 없다.

```
APPROVED, REJECTED, OVERRIDDEN, DELEGATED, ESCALATED,
CANCELLED, COMPLETED, FAILED, NOTED, SUSPENDED, REVOKED
```

`append_audit_record()` INSERT 자체가 23514로 실패한다.

### §3.2 선택지

**Option A — `chk_audit_decision` 확장 (기각 권고)**

11개에 `REFUND_PENDING`/`REFUND_FAILED`를 추가.

- 반대 근거 ①: `audit_records.decision`은 **모든 도메인이 공유하는 교차 도메인 어휘**다. 결제 전용 상태를 넣으면 이후 KDS·대기열·재고도 각자 도메인 상태를 밀어넣게 되어 감사 어휘가 도메인 상태의 합집합으로 붕괴한다.
- 반대 근거 ②: `decision`은 **"그 행위에 대한 판단"**을 담는 필드이지 **"그 결과 원장이 어떤 상태가 됐는지"**를 담는 필드가 아니다. 후자는 이미 `ledger_status`가 담고, `p_decision_payload`가 상세를 담는다. 확장은 두 필드의 책임을 혼동시킨다.
- 반대 근거 ③: **`601030` 선례가 정확히 이 상황에서 확장을 기각했다**(아래).

**Option B — 기존 유효값 매핑 (권고)**

| 원래 리터럴 | 매핑 대상 | 근거 |
|---|---|---|
| `REFUND_PENDING` | **`SUSPENDED`** | "일시 중단, 재개 가능". `601030`이 동일 성격의 `PENDING` 상태를 정확히 이 값으로 매핑한 선례 |
| `REFUND_FAILED` | **`FAILED`** | 이미 허용값. 추가 판단 불요 |

정밀한 상태값은 소실되지 않는다 — `p_decision_payload`에 `ledger_status`(= `REFUND_PENDING`/`REFUND_FAILED`)를 그대로 실어 보존한다.

### §3.3 `601030` 선례 (직접 인용 근거)

`601032_Logic` L105~126은 `PAYMENT_CONFIRMED_*` 분기에서 쓰던 `'PENDING'`이 `chk_audit_decision` 밖임을 발견하고, **제약을 넓히는 대신 `'SUSPENDED'`로 매핑**했다. 그 선택 논리:

- `'SUSPENDED'` = "일시 중단, 재개 가능" — `0041`의 기존 관례와 일치.
- `'NOTED'`(0027/0031/0036 관례 = "사람 검토가 필요한 사실 기록")와 **의미가 겹치지 않음**.
- `'DELEGATED'`는 "재시도를 실제로 넘겨받을 프로세스가 없다"는 사실과 모순되어 기각.

본 변경의 `REFUND_PENDING`은 `601030`의 `PENDING`과 성격이 동일하다 — **외부(PG) 응답을 기다리는 중단 상태이며 재개 가능**. 따라서 같은 매핑을 적용하는 것이 일관적이다.

### §3.4 O1 확정 (2026-07-20, Human 승인)

> **O1 확정(2026-07-20, Human 승인): 매핑 방식 채택.** `chk_audit_decision`은 **확장하지 않는다.**

| 항목 | 확정 내용 |
|---|---|
| 방식 | **Option B — 기존 유효값 매핑** (Option A 확장은 기각) |
| `REFUND_PENDING` → | **`SUSPENDED`** |
| `REFUND_FAILED` → | **`FAILED`** (이미 허용값) |
| **`REFUNDED` / `PARTIAL_REFUNDED`** → | **`COMPLETED`** (2026-07-20 보완) |
| 정확한 상태 보존 | `p_decision_payload`에 **`ledger_status` 키를 명시적으로 포함** |
| 선례 | `601030`(`PENDING`→`SUSPENDED`) **그대로 적용** |

**전 분기 매핑표 (누락 없이 명시)**

| 함수·분기 | `ledger_status` | `p_decision` |
|---|---|---|
| `request_refund()` 환불 요청 | `REFUND_PENDING` | **`SUSPENDED`** |
| `confirm_refund()` 성공(전액) | `REFUNDED` | **`COMPLETED`** |
| `confirm_refund()` 성공(부분) | `PARTIAL_REFUNDED` | **`COMPLETED`** |
| `confirm_refund()` 실패 | `REFUND_FAILED` | **`FAILED`** |

> **`COMPLETED` 보완 근거:** 최초 판본은 실패·대기 두 분기만 매핑하고 **성공 경로를 누락**했다. 환불이 정상 완료된 경우도 감사기록이 필요하며, `chk_audit_decision`의 `COMPLETED`("완료")가 정확히 대응한다. `APPROVED`는 "승인 판단"의 의미라 이미 실행된 환불에는 부적합하다.

**`p_decision_payload` 필수 키:** `ledger_status`(원값), `refund_amount`, `original_ledger_id`. 감사 어휘가 4개 상태를 3개 값(`SUSPENDED`/`COMPLETED`/`FAILED`)으로 축약하므로, `ledger_status` 키가 없으면 `REFUNDED`와 `PARTIAL_REFUNDED`를 감사기록만으로 구분할 수 없다.

**확정에 따른 귀결:**

- `0008`의 `chk_audit_decision` 11개 값은 **변경하지 않는다.** 본 워크패킷의 스키마 변경은 §4.3.1의 `original_ledger_id` 컬럼 추가 **단 1건뿐**이며, 감사 제약은 손대지 않는다.
- 감사기록에서 "환불 대기"와 "일반 일시중단"이 같은 `SUSPENDED`로 보이게 되므로, **`p_decision_payload`의 `ledger_status` 보존이 필수**다. 이것이 없으면 감사 추적에서 환불 대기를 식별할 수 없다 — TestPlan V7의 검증 대상.
- 교차 도메인 감사 어휘가 결제 도메인 상태로 오염되지 않는다(§3.2 반대근거 ①·② 유지).

---

## §4 오참조 식별자 매핑

Overview §2의 재분류에 따른 목적지 설계. **`payment_ledger`에 신규 컬럼을 추가하지 않는 것을 원칙**으로 한다(예외 후보는 §4.4).

### §4.1 확정 매핑 (Cursor C1/C2로 라인 단위 확인 후 적용)

| # | 오참조 식별자 | 0098 사용 | 목적지 | 처리 |
|---|---|---|---|---|
| 1 | `provider_tx_id` | 30회 | `payment_ledger.provider_payment_key` | 컬럼명 치환. PG가 발급한 거래 키. 환불 원장 행에서는 **그 환불 자체의** provider key를 담는다 |
| 2 | `payment_method` | 11회 | `payment_intents.payment_method` | **조인으로 해소.** `payment_ledger.intent_id → payment_intents.id`. 읽기 전용, `payment_ledger`에 쓰지 않는다 |
| 3 | `is_partial_refund` | 2회 | (없음 — 계산) | `refunded_amount < approved_amount`로 파생. **저장하지 않는다** |
| 4 | `refunded_at` | 3회 | `payment_ledger.approved_at` | 환불 원장 행의 자기 승인시각. 행 단위 의미로 이미 존재하는 컬럼을 쓴다 |
| 5 | `refund_reason` | 8회 | `payment_events.event_payload` | 사유는 원장 컬럼이 아니라 이벤트 페이로드. `reconciliation_mismatch_reason`은 **의미가 다르므로 쓰지 않는다**(조정 불일치 사유 전용) |

### §4.2 `provider_response` 매핑 — O5 정밀화 (2026-07-20 정정)

> **정정:** 최초 판본의 "12곳"은 부정확했다. 정확한 실측은 **0098 전체 12행 / 13토큰**이며, 그중 **환불 함수 범위 내 실제 터치포인트는 3곳**이다.

**전체 분포 (0098 12행 / 13토큰)**

| 성격 | 개수 | 위치 | 판정 |
|---|---|---|---|
| **UUID 계열** (`provider_response_id` / `v_provider_response_id`) | **6** | L188, L489, L543, L558, L653, L668 | **실재 컬럼 — 정정 불요** |
| **JSON 계열** (`p_provider_response` / `provider_response`) | **7** | L159, L478, L1067, L1341, L1401(×2 토큰), L1402 | 아래 범위 판정 |

**범위 판정**

| 위치 | 소속 | 범위 |
|---|---|---|
| L159 / L478 / L1067 | `confirm_payment` · `confirm_payment_from_provider` 경로 | **범위 밖 확정** — 본 워크패킷은 환불 함수만 정정 |
| **L1341** | `confirm_refund()` 파라미터 `p_provider_response jsonb default null` | **범위 내 ①** — 1토큰 |
| **L1401** | `provider_response = coalesce(` — **대입 대상 컬럼** | **범위 내 ②** — 1토큰 |
| **L1402** | `p_provider_response, provider_response` — **파라미터 + fallback 소스 컬럼** | **범위 내 ③④** — 2토큰 |

> **토큰 위치 정정 (2026-07-20):** 최초 판본은 "L1401(×2 토큰)"으로 적었으나 부정확하다. 실제로는 **L1401에 1토큰**(대입 대상), **L1402에 2토큰**(파라미터 + fallback 소스)이다. 환불 범위 내 총 **4토큰 / 3행**(L1341, L1401, L1402).

### §4.2.1 ⚠️ `coalesce` fallback은 단순 컬럼 삭제로 해소되지 않는다

L1401–1402의 실제 형태:

```
provider_response = coalesce(p_provider_response, provider_response)
```

이 구문은 **삭제하려는 phantom 컬럼을 fallback 소스로 읽는다.** 즉 "새 응답이 오면 갱신하고, 없으면 **기존 저장값을 유지**한다"는 의미를 담고 있다. 컬럼을 없애면 **유지할 기존값 자체가 사라지므로**, 단순 삭제는 이 의미를 소리 없이 바꾼다.

따라서 이 항목은 **컬럼 삭제가 아니라 신규 INSERT 설계 + fallback 의미 재정의**가 필요하다.

| 쟁점 | 내용 |
|---|---|
| 목적지 | JSON 페이로드이므로 `payment_events.event_payload` |
| 구조 변화 | `payment_ledger` 행의 **UPDATE(누적 갱신)** → `payment_events` 행의 **INSERT(이벤트 append)** |
| fallback 의미 | 기존: "없으면 이전 값 유지". **이벤트 모델에서는 직전 이벤트에 이전 값이 남아 있으므로 fallback 자체가 불요** |

**⚠️ 선택지 재정의 (2026-07-20 정정).** 최초 판본은 선택지를 "이벤트를 남기지 않거나 / NULL로 기록"으로 적었으나 **잘못된 프레이밍**이다. **이벤트 자체는 §4.2.2 계약에 따라 언제나 기록된다** — `p_provider_response`의 NULL 여부는 이벤트 발생 여부와 무관하다. 실제 쟁점은 **payload 안에서 선택적 키를 어떻게 표현할 것인가**이다.

| 선택지 | 표현 | 성격 |
|---|---|---|
| **(A)** | `p_provider_response`가 NULL이면 **`provider_response` 키를 생략** | payload가 간결. 키 부재 = 정보 없음 |
| **(B)** | **`provider_response: null`을 명시적으로 기록** | 키가 항상 존재. "시도했으나 응답 없음"과 "해당 없음"의 구분이 명시적 |

> **결정 필요 — Stage 5 ChangeContract에서 고정.** 두 대안 모두 이벤트 기록 자체에는 영향이 없으므로 Stage 4 진입을 막지 않는다. 소비자(조정·감사)가 키 부재를 어떻게 다루는지에 따라 갈리므로, `payment_events` 소비 측 관례(O7 조사 결과)와 함께 판단할 것.

> **주의:** 이 재설계는 §1.1의 "새 로직 설계 금지"에 저촉되지 않는다. 새 업무 규칙을 만드는 것이 아니라, **저장 위치 변경에 수반되는 동등 의미 보존**이기 때문이다. 다만 "동등"의 판정이 필요하므로 Stage 4가 명시적으로 확인해야 한다.

### §4.3 Open Item — Human 결정 필요

| # | 식별자 | 0098 사용 | 쟁점 | 선택지 |
|---|---|---|---|---|
| ~~7~~ | ~~`fee_amount`~~ | 6회 | **✅ 종결 (2026-07-20)** — (a) 제거로 확정, (b) 정산 조회 기각 | Open Item 아님 → §4.3.2 |
| ~~8~~ | ~~`original_ledger_id`~~ | 3회 | **✅ 종결 (2026-07-20)** — (a)/(b) 기각, **(c) 컬럼 추가로 확정.** §4.3.1 참조 | Open Item 아님 |

**(a) 안의 전제였던 것:** 한 `order_id`에 대해 원거래(`APPROVED`) 행이 유일해야 한다.

### §4.2.2 O7 종결 — 환불 이벤트 계약 확정 (2026-07-20)

`refund_reason`(§4.1 #5)과 `provider_response`(§4.2)의 목적지가 모두 `payment_events`이므로, **이벤트 계약을 명시적으로 고정**한다.

**기존 정본 관례 (`0037` `refund_payment`)** — 이 관례를 그대로 따른다:

| 요소 | 기존 값 |
|---|---|
| `event_type` | `'payment_partial_refunded'` (부분) / `'payment_refunded'` (전액) — L631–632, L661–662, L685–686 |
| payload 키 | `refund_reason`, `refund_amount`, `new_net_amount`, `evidence_id` |

**확정 계약**

| 함수 | `event_type` | `event_payload` 키 |
|---|---|---|
| **`request_refund()`** | `'payment_refund_requested'` | `refund_reason`, `refund_amount`, `original_ledger_id`, `provider_response`(있으면), `ledger_status`(=`REFUND_PENDING`) |
| **`confirm_refund()` 성공** | 부분 → `'payment_partial_refunded'` / 전액 → `'payment_refunded'` **(0037 관례 그대로)** | `refund_reason`, `refund_amount`, `new_net_amount`, `evidence_id`, `original_ledger_id`, `provider_response`(있으면), `ledger_status`(=`REFUNDED`/`PARTIAL_REFUNDED`) |
| **`confirm_refund()` 실패** | `'payment_refund_failed'` | `refund_reason`, `refund_amount`, `original_ledger_id`, `provider_response`(있으면), `ledger_status`(=`REFUND_FAILED`) |

**설계 근거:**

- **확정 단계는 `0037` 관례를 그대로 채택한다.** 같은 업무 사실(환불 완료)이 함수마다 다른 `event_type`으로 기록되면 조정·감사에서 두 계보를 합칠 수 없다.
- **요청·실패 단계만 신규 명명**한다. `0037`은 1단계 모델이라 대응 이벤트가 없었기 때문이며, 접두어(`payment_refund_*`)를 맞춰 계보를 유지한다.
- `ledger_status`를 payload에 **항상 포함**한다 — §3.4의 감사 매핑(`SUSPENDED`/`COMPLETED`/`FAILED`)이 정밀 상태를 지우므로, 이벤트 쪽에 원값이 남아야 추적이 가능하다.

### §4.2.3 ⚠️ `chk_payment_event_type` 확장 필요 — 신규 결함 방지 (2026-07-20)

> **최초 §4.2.2 판본은 그 자체로 새로운 23514를 만들 뻔했다.** 신규 `event_type` 2개를 제안하면서 이를 규율하는 CHECK 제약을 확인하지 않았다. 본 워크패킷이 고치려는 결함 유형(합의 어휘 vs 미확장 제약)과 **정확히 동일한 실수**이므로 명시적으로 기록한다.

`payment_events.chk_payment_event_type`(`0014` L325–347)은 **19개 값**만 허용한다:

```
intent_created, payment_window_opened, payment_submitted,
provider_callback_received, provider_callback_verified,
payment_approved, payment_failed, payment_uncertain,
payment_uncertain_resolved, payment_cancelled,
payment_refunded, payment_partial_refunded,
kds_release_authorized, reconciliation_matched,
reconciliation_mismatch_detected, reconciliation_resolved,
manual_correction_applied, dispute_raised, dispute_resolved
```

| 계약상 `event_type` | 허용 여부 |
|---|---|
| `payment_refunded` | ✅ 허용 |
| `payment_partial_refunded` | ✅ 허용 |
| **`payment_refund_requested`** | ❌ **미허용 → 23514** |
| **`payment_refund_failed`** | ❌ **미허용 → 23514** |

**선택지**

| | 방식 | 평가 |
|---|---|---|
| **(A) 권장** | forward migration으로 **2개 값 추가** (19→21) | `0150`(`chk_event_domain` 확장) 선례와 일관. **본 워크패킷 §2의 `chk_ledger_status` 확장과 동일한 논리** — 합의된 어휘를 제약이 수용하도록 맞춘다 |
| (B) | 기존 허용값(`payment_cancelled`/`payment_failed` 등)으로 계약 재작성 | 요청·실패 단계가 취소·결제실패와 구분되지 않아 **의미가 왜곡**된다. 조정에서 환불요청과 결제실패를 분리할 수 없다 |

**확정: (A) 채택.** §7 DDL 목록에 **CHECK 확장 1건 추가**(아래 §7 2-b 단계).

### §4.2.4 부분/전액 환불 판정 — **범위 확장 확정** (§1.1 명시적 예외, 2026-07-20 Human 승인)

> **§1.1 예외 기록:** 본 항목은 "새 로직 설계 금지" 원칙에 대한 **명시적 예외**로 Human 승인됐다(2026-07-20). 예외 범위는 **"이미 요청된 환불 금액을 보고 REFUNDED / PARTIAL_REFUNDED로 분류하는 판정"** 하나로 한정한다. 환불 승인·거부 워크플로우, 부분환불 한도, 다단계 승인은 **여전히 금지**다(§8).

**발견된 사실:** 현재 `confirm_refund()`는 성공 시 **언제나 `REFUNDED`(전액)만** 생성하며 `PARTIAL_REFUNDED`를 만들지 않는다. 따라서 §4.2.2 계약의 `payment_partial_refunded` 분기는 **현 구현으로는 도달 불가**하다.

#### §4.2.4.1 이 판정이 "새 업무 규칙"이 아닌 이유 — 스키마가 이미 전제하고 있다

부분환불에 필요한 **모든 구성요소가 이미 스키마·선례에 존재**한다. 없는 것은 `confirm_refund()`의 분류 한 줄뿐이다.

| 구성요소 | 위치 | 상태 |
|---|---|---|
| `ledger_entry_type` = **`REFUND` / `PARTIAL_REFUND`** | `0014` L201–211 (7개 값 중 2개) | ✅ 이미 존재 |
| `ledger_status` = **`REFUNDED` / `PARTIAL_REFUNDED`** | `0014` L212–223 | ✅ 이미 존재 |
| 누적 환불액 `refunded_amount` + 잔액 `net_amount` | `0014` L224–229 | ✅ 이미 존재 |
| `event_type` = `payment_refunded` / `payment_partial_refunded` | `0014` L325–347, `0037` 관례 | ✅ 이미 존재 |

따라서 이 설계는 **새 개념 도입이 아니라 이미 정의된 두 갈래 중 하나를 고르는 분기**다.

#### §4.2.4.2 ⚠️ 선결 쟁점 — 두 엔진의 금액 모델이 상충한다 (신규 결함 발견)

판정 기준을 정하려면 **환불이 원장에 어떻게 기록되는지**가 먼저 확정돼야 한다. 두 엔진이 **서로 다른 모델**을 쓴다.

| 모델 | 엔진 | 방식 |
|---|---|---|
| **(가) 원거래 행 누적** | `0037` `refund_payment` | 원거래 행을 **UPDATE** — `cancelled_amount = approved_amount, net_amount = 0` |
| **(나) 음수 자식 행** | `0098` `request_refund` | **새 행 INSERT** — `approved_amount = -p_refund_amount`, `net_amount = -(비율계산)`, `original_ledger_id = 원거래.id` |

**(나)는 스키마 제약을 위반한다 — 제4·제5 결함:**

`chk_ledger_amounts`(`0014` L224–229):

```
approved_amount > 0
and cancelled_amount >= 0
and refunded_amount >= 0
and net_amount = approved_amount - cancelled_amount - refunded_amount
```

| 위반 | 내용 |
|---|---|
| **④ `approved_amount > 0`** | `0098`이 `-p_refund_amount`(음수)를 넣는다 → **23514** |
| **⑤ `net_amount` 항등식** | 음수 `net_amount`를 비율로 계산해 넣으므로 `approved - cancelled - refunded`와 불일치 → **23514** |

> **`request_refund()`의 INSERT는 `REFUND_PENDING`(§2) 외에 `chk_ledger_amounts`를 2가지 방식으로 더 위반한다.** 최초 진단(§1.1)이 포착하지 못한 결함이며, INSERT를 어차피 재작성하므로 같은 범위에서 해소된다.

**권고: (가) 원거래 행 누적 모델 채택.** 근거 — `net_amount = approved_amount - cancelled_amount - refunded_amount` 항등식이 `approved_amount > 0`·`refunded_amount >= 0`과 결합되면 **한 행에 누적하는 설계임이 명확**하다. 음수 자식 행 모델은 이 제약과 구조적으로 양립 불가하다. `0037`이 이미 (가)를 쓴다는 점도 일관성을 지지한다.

#### §4.2.4.3 판정 규칙 (권고안 — Cursor 확인 후 확정)

**비교 기준: 원거래 전체 승인액이 아니라 `잔여 미환불액`.**

```
잔여 = 원거래.net_amount        -- = approved_amount - cancelled_amount - refunded_amount

p_refund_amount <  잔여  →  PARTIAL_REFUND / PARTIAL_REFUNDED
p_refund_amount =  잔여  →  REFUND         / REFUNDED
p_refund_amount >  잔여  →  오류 (기존 refund_amount_invalid, error_code 4016 재사용)
```

**왜 `approved_amount`가 아니라 `net_amount`인가 (중요):** 순차 부분환불에서 `approved_amount` 기준은 **마지막 환불을 오분류**한다.

> 예: 승인 10,000 → 1차 환불 3,000(부분) → 2차 환불 7,000.
> 2차는 **잔여 7,000을 전부 소진**하므로 `REFUNDED`(전액)여야 한다.
> 그러나 `approved_amount`(10,000) 기준이면 7,000 < 10,000 이므로 **`PARTIAL`로 오분류**된다.

`net_amount` 기준은 이 오류를 구조적으로 배제하며 `chk_ledger_amounts` 항등식과 정확히 맞물린다.

#### §4.2.4.4 판정값의 사용처 — O1·O7과의 연결 (재확인 결과 정합)

| 소비처 | 전액 | 부분 | 근거 |
|---|---|---|---|
| `ledger_entry_type` | `REFUND` | `PARTIAL_REFUND` | `0014` L201–211 |
| `ledger_status` | `REFUNDED` | `PARTIAL_REFUNDED` | §2 (확장 후 10개 값) |
| `event_type` (O7) | `payment_refunded` | `payment_partial_refunded` | §4.2.2 — **판정 결과를 그대로 사용** |
| `p_decision` (O1) | **`COMPLETED`** | **`COMPLETED`** | §3.4 — **양쪽 동일** |

> **O1 재확인 — 정합함.** §3.4가 `REFUNDED`/`PARTIAL_REFUNDED`를 **둘 다 `COMPLETED`로** 매핑하므로 판정 결과가 감사 매핑을 바꾸지 않는다. 두 경우를 감사기록에서 구분하는 수단은 §3.4가 이미 필수화한 **`p_decision_payload.ledger_status`** 이며, 이 판정으로 그 키의 값이 비로소 두 갈래가 된다 — §3.4 설계가 이 판정을 **선반영**하고 있었다.

#### §4.2.4.5 `p_is_partial` 파라미터 — 계산 vs 신뢰

`0098`의 INSERT는 `is_partial_refund` 컬럼에 **`p_is_partial` 파라미터**를 그대로 넣는다. 즉 부분 여부가 **호출자 입력**으로 이미 존재한다.

| 선택지 | 내용 | 평가 |
|---|---|---|
| **(A) 서버 계산** (권고) | `p_is_partial`을 **무시하고** §4.2.4.3 규칙으로 판정 | 호출자가 틀린 값을 보내도 원장이 스스로 정합. 3개 호출자(0102/0103/0104)가 이 값을 어떻게 채우는지 미확인이므로 안전 |
| (B) 호출자 신뢰 | `p_is_partial`을 그대로 사용 | 잘못된 입력이 곧바로 원장 오분류 |

**권고: (A).** 단 `p_is_partial`을 **제거하지 않는다**(시그니처 변경은 3개 호출자에 영향). 계산값과 다르면 `payment_events.event_payload`에 불일치를 기록해 후속 정리 근거로 남긴다.

#### §4.2.4.6 이전 판본(선택지 가/나) — 무효

> **아래 표와 권고는 2026-07-20 Human 승인으로 무효화됐다.** (나) 방향이 채택됐으며, 다만 판정 기준은 표에 적힌 `approved_amount`가 아니라 **`net_amount`(잔여)** 로 정정됐다(§4.2.4.3). 이력 추적용으로만 보존한다.

| ~~선택지~~ | ~~내용~~ | ~~§1.1 정합~~ |
|---|---|---|
| **(가)** 최소 유지 | 판정 로직을 만들지 않고, 계약에서 `payment_partial_refunded`/`PARTIAL_REFUNDED` 분기를 **제거** | ✅ 새 로직 없음 |
| **(나)** 판정 설계 | `p_refund_amount < 원거래 approved_amount` → `PARTIAL_REFUNDED` / 같으면 `REFUNDED` | ⚠️ **새 계산 규칙 도입 — §1.1 저촉 소지** |

> **Human 범위 확인 필요.** (나)는 부분환불 금액 판정이라는 **새 업무 규칙**을 도입하므로 §4.2("새 환불 비즈니스 로직 설계 금지")의 예외 승인이 필요하다.
>
> **다만 (가)를 택하면 결함이 하나 남는다** — 부분 금액으로 환불해도 원장이 `REFUNDED`(전액 환불)로 기록되어 **잔액 정합성이 깨진다.** 이는 본 워크패킷이 만든 결함이 아니라 **기존 구현의 결함**이며, (가) 선택 시 **알려진 잔여로 명시하고 후속 이월**해야 한다.
>
> **권고:** 범위 규율을 우선해 **(가) + 잔여 명시**. 부분환불 판정은 별도 워크패킷이 적절하다.

### §4.3.2 O4 종결 — `fee_amount` 참조 완전 제거 (2026-07-20)

> **O4 확정(2026-07-20, Human 승인): 컬럼 참조 완전 제거.** 저장하지 않으며, **별도 대안(정산 테이블 조회 등)을 두지 않는다.**

| 항목 | 확정 내용 |
|---|---|
| 처리 | `0098`의 `fee_amount` **참조 6곳 전부 삭제** |
| 대체 | **없음.** 조회·계산·페이로드 어디에도 넣지 않는다 |
| 근거 | 수수료는 **정산 도메인 소관**(`0084`)이며 `payment_ledger`의 책임이 아니다. 제거해도 환불 업무 의미가 바뀌지 않는다 |

**§1.1과의 정합:** 제거는 새 로직 설계가 아니라 **잘못된 참조의 삭제**다. `fee_amount`는 애초에 `payment_ledger`에 존재한 적이 없으므로, 이 6곳은 실행되면 42703을 낼 죽은 참조였다. 삭제로 환불 흐름이 잃는 정보는 없다.

**주의:** 향후 환불 수수료를 실제로 다뤄야 한다면 그것은 **정산 도메인의 별도 워크패킷**이다. 본 변경은 그 가능성을 막지 않으며, 단지 `payment_ledger`에 잘못 놓인 참조를 걷어낼 뿐이다.

### §4.3.1 O3 종결 — (a) 기각, 컬럼 추가로 확정 (2026-07-20)

> **O3 종결(2026-07-20, Cursor):** 라이브 `payment_ledger` 0행으로 empirical 중복은 없으나, 스키마·`0098` 코드상 `(order_id, ledger_entry_type)`은 **설계상 비유일**(`request_refund`의 `ORDER BY approved_at DESC LIMIT 1`이 동일 order에 복수 `APPROVED` 행을 전제, `confirm_payment`가 취소/환불된 주문에도 `APPROVAL` 행 추가 가능) — **(a) 파생안 기각. `original_ledger_id` 컬럼 추가로 확정.**

**이 근거의 성격 (2026-07-20 표현 정정):** 판정 근거는 *empirical*(현재 데이터에 중복이 없다)이 아니라 **구현 신호와 제약 부재의 종합**이다. 라이브가 0행이므로 데이터만 봤다면 "유일하다"는 잘못된 결론에 도달했을 것이다.

> **정확한 진술:** `ORDER BY approved_at DESC LIMIT 1`은 **복수 행을 허용하거나 그에 방어하려는 구현 신호**이며, 여기에 **`(order_id, ledger_entry_type)`에 대한 UNIQUE 제약 부재**와 **재승인 행 생성 가능성**(`confirm_payment`가 취소·환불된 주문에도 `APPROVAL` 행을 추가할 수 있음)을 함께 고려하면, **유일성을 보장할 수 없다.**

최초 판본은 이를 "코드 레벨 증명" / "복수 행을 전제"로 적었으나, `ORDER BY … LIMIT 1`은 복수 행의 *증명*이 아니라 *가능성에 대한 방어*로도 읽힌다. 결론(유일성 보장 불가)은 동일하지만, 근거의 강도를 실제 수준으로 낮춰 기술한다.

따라서 파생(`order_id` + `ledger_entry_type`)은 **원거래를 유일하게 특정할 수 없다.** 환불 행이 어느 승인 행을 되돌리는지 잘못 지목하면 부분환불·재승인 이력에서 금액 귀속이 어긋나므로, 명시적 참조가 필요하다.

**확정: `payment_ledger.original_ledger_id` 컬럼 추가.** Overview §4.2의 단일 예외로 Human 승인됨(2026-07-20).

| 항목 | 값 |
|---|---|
| 컬럼명 | `original_ledger_id` |
| 타입 | `uuid` |
| NULL 허용 | **nullable** — 원거래 행 자신은 이 값이 없다 |
| 제약 | `FK → catchmenu_payment.payment_ledger(id)` (자기참조) |
| 의미 | 환불/취소 행이 되돌리는 **원 승인 행**의 id |

**추가 안전성:** nullable 컬럼 추가이므로 기존 28개 행 구조·기존 데이터에 영향이 없고, 라이브가 0행이므로 백필 대상도 없다. 자기참조 FK는 순환이 아니라 계층(원거래 ← 환불)이므로 안전하다.

### §4.4 컬럼 추가에 대한 입장 (2026-07-20 확정)

> **최초 판본 입장:** "추가를 권고하지 않는다 — (a) 파생이 가능하면 스키마 변경 없이 해소되기 때문."
> **확정 입장:** **(a) 파생이 불가능함이 증명되어 추가로 확정.**

O3 종결(§4.3.1)이 §4.3의 유일성 전제를 **기각**했다. 최초 판본이 "유일성 전제가 깨지면 (c)가 유일한 정답"이라고 명시했으므로, 이 전환은 최초 설계 논리를 따른 결과이지 입장 번복이 아니다.

**`original_ledger_id` 추가는 §1.1("새 로직 설계 금지")을 위반하지 않는다.** 근거:

- 이 컬럼은 **새 업무 개념을 도입하지 않는다.** `0098`은 이미 `original_ledger_id := v_payment.id`를 쓰도록 작성돼 있었다 — 즉 "환불 행이 원거래 행을 가리킨다"는 개념은 **원래 설계에 있었고**, 스키마에만 없었다.
- 따라서 이 변경은 **설계 의도를 스키마가 뒤늦게 수용**하는 것이며, §1의 대원칙("구현을 스키마에 맞추지 않는다, 스키마를 합의된 설계에 맞춘다")과 정확히 같은 방향이다. `chk_ledger_status` 확장과 성격이 동일하다.

**예외의 경계:** 허용은 이 컬럼 **하나뿐**이다. 다른 phantom 식별자를 컬럼 추가로 해소하는 것은 금지된다(§4.1이 기존 컬럼·조인·계산으로 해소).

---

## §5 정본 환불 엔진 지정

### §5.1 현재 3개 엔진

| 엔진 | 위치 | 형태 |
|---|---|---|
| E1 | `0098.request_refund()` | 환불 요청 → `REFUND_PENDING` 기록 |
| E2 | `0098.confirm_refund()` | PG 결과 수신 → `REFUNDED` 또는 `REFUND_FAILED` |
| E3 | `0037.refund_payment()` | 단일 호출 환불 ("refund after order completion") |

E1+E2는 **2단계(요청→확정)** 모델, E3는 **1단계** 모델이다.

### §5.2 판단 기준 (Cursor C3 결과에 적용할 프레임)

| 기준 | 가중 |
|---|---|
| K1. 실호출자 존재 여부 (Flutter / RPC / Edge Function / cron) | 최우선 — 호출자가 있는 엔진을 함부로 폐기할 수 없다 |
| K2. 설계 코퍼스 정합성 | `010802 §4`는 `REFUND_PENDING → REFUND_APPROVED → REFUND_COMPLETED`의 **다단계** 모델을 규정 → 2단계 모델(E1+E2)과 정합 |
| K3. 감사·이벤트 완결성 | `append_audit_record` / `payment_events` 기록 유무 |
| K4. PG 비동기 응답 수용력 | 환불은 PG 응답이 지연·실패할 수 있으므로 2단계가 구조적으로 유리 |

### §5.3 C3 확정 후 결론 (2026-07-20 갱신)

**C3 결과가 K1을 확정했다.**

| 엔진 | 실호출자 | K1 | K2 (설계 정합) | K4 (PG 비동기) |
|---|---|---|---|---|
| **E1 `request_refund()`** | **3건** (0102/0103/0104의 `cancel_*`) | ✅ 유일 | ✅ 2단계 모델 | ✅ |
| E2 `confirm_refund()` | 0건 | — | ✅ 같은 파이프라인 | ✅ |
| E3 `refund_payment()` (0037) | 0건 | — | 1단계 | ✖ |

**K1·K2·K4가 모두 같은 방향(0098 2단계 파이프라인)을 가리킨다.** 최초 판본의 "잠정 권고"는 이제 확정 가능하다.

### §5.4 결론은 "정본 선택"이 아니라 **정정 순서**다

C3 결과를 "E3를 버린다"로 읽어서는 안 된다. 정확한 함의는 **어느 것을 먼저 고쳐야 실제 운영 위험이 가장 빨리 줄어드는가**이다.

> **`request_refund()`(+ 같은 0098 파이프라인의 `confirm_refund()`)를 먼저 고친다.**
> 이유는 설계적 우월성이 아니라 **노출도**다 — 실제 운영 트래픽(OKPOS·Toss 취소)이 지나가는 유일한 경로가 E1이고, 그 경로가 지금 23514로 깨져 있다.

| 순위 | 대상 | 근거 |
|---|---|---|
| **1** | E1 `request_refund()` | 실호출자 3건. **여기를 고치는 것만으로 실제 운영 크래시가 해소된다** |
| **2** | E2 `confirm_refund()` | E1과 같은 마이그레이션·같은 상태 어휘. E1만 고치면 `REFUND_PENDING` 행이 쌓이고 확정 주체가 없어 정합성이 무너지므로 **함께 고쳐야 한다** |
| **3** | E3 `refund_payment()` | 실호출자 0건 → 운영 위험 없음. 처분은 **급하지 않다** |

**E3 처분은 이번 워크패킷에서 확정하지 않아도 된다.** 선택지(유지+`REVOKE` / historical 표기 / 존치)는 §5.2의 프레임 그대로 남기고, Human 결정을 **Stage 5 또는 후속 워크패킷으로 이월**할 수 있다. 급하지 않은 결정을 급한 배포에 묶지 않는 것이 낫다.

> **주의 — 파사드 재작성은 여전히 범위 밖이다.** §5.2의 선택지 (ii)("E3를 정본 위임 파사드로 재작성")는 새 로직 설계에 해당하므로 §8 Non-goals에 따라 본 워크패킷에서 수행하지 않는다.

### §5.5 확정 사항이 아닌 것 — `confirm_refund()` 미호출

C3는 부수적으로 **`confirm_refund()`를 아무도 호출하지 않는다**는 사실도 드러냈다. 즉 현재 시스템은 환불을 **요청만 하고 확정하지 않는다**. 이는 제약 위반과는 **별개의 미완성**이다.

본 워크패킷은 이를 **고치지 않는다**(§8 — 새 로직 설계 금지). 그러나 §5.4의 순위 2가 성립하는 근거이므로 기록한다: 정정 후 `REFUND_PENDING` 행이 정상적으로 기록되기 시작하면, **확정 주체가 없다는 사실이 비로소 데이터로 드러난다.** 후속 워크패킷 후보로 Open Item(O8)에 등록한다.

---

## §6 `010412`(`REVERSAL_*`) 처리

`010412`는 `REVERSAL_NOT_REQUESTED … REVERSAL_UNKNOWN` 19개 상태를 정의하며, 이는 다수 합의 어휘(`REFUND_*`)와 다른 소수 이상치다.

### §6.1 C4 판정 — 범위 밖 확정 (2026-07-20)

**Cursor C4 결과: `REVERSAL_*` 리터럴을 사용하는 SQL 함수·제약·테이블 연결 0건.**

따라서 `010412`는 **순수 설계문서**이며, 어떤 실행 코드도 이 어휘에 의존하지 않는다.

| 판정 | 내용 |
|---|---|
| 본 워크패킷 범위 | **밖 (확정)** |
| 근거 | SQL 연결 0건 → 정정할 실행 코드가 존재하지 않음 |
| 남는 일 | `010412`의 `REVERSAL_*`와 다수 합의 어휘(`REFUND_*`)의 **문서 간 정합화** |
| 처분 | **별도 이월.** 본 워크패킷에서 수행하지 않는다 |

### §6.2 이월 항목 기록

`010412` 어휘 정합화는 아래 성격이므로 별도 워크패킷 후보로만 남긴다.

- **실행 위험 없음** — SQL 연결이 0건이므로 런타임 결함을 만들지 않는다.
- **문서 무결성 문제** — 같은 도메인에서 환불 상태 어휘가 두 갈래(`REFUND_*` 다수 / `REVERSAL_*` 소수)로 남는다. 601400 검사가 지적한 canonical ambiguity 계열이다.
- **본 변경이 오히려 근거를 강화한다** — 본 워크패킷이 `chk_ledger_status`를 `REFUND_PENDING`/`REFUND_FAILED`로 확장하면, 스키마가 다수 합의 어휘를 공식 채택하게 되므로 `010412`가 **더 뚜렷한 이상치**가 된다. 이월 시 이 사실을 근거로 쓸 수 있다.

> 만약 이후 `REVERSAL_*`를 쓰는 SQL이 새로 발견되면, 자동 편입하지 말고 Overview §4.1 범위를 갱신한 뒤 **Human 재승인**을 받는다(범위 확장 금지 원칙).

---

## §7 변경 대상 SQL 개요 (Stage 2 인계용, 본 워크패킷은 생성하지 않음)

신규 forward migration **1개**로 묶는 것을 권고한다(제약 확장과 함수 정정이 원자적으로 적용되어야 하므로).

구성 **(순서가 중요하다 — 스키마 변경이 함수 교체보다 먼저 와야 한다)**:

1. **`payment_ledger.original_ledger_id` 컬럼 추가** (§4.3.1) — `uuid`, nullable, `FK → payment_ledger(id)` 자기참조. **§4.2 단일 예외 승인 항목**
2. **CHECK 확장 2건**
   - **2-a.** `chk_ledger_status` DROP → ADD, 8→10 (§2.3)
   - **2-b.** **`chk_payment_event_type` DROP → ADD, 19→21** — `payment_refund_requested`/`payment_refund_failed` 추가 (**§4.2.3**)
3. `catchmenu_payment.request_refund()` `CREATE OR REPLACE` — §3.4 매핑 + §4 식별자 정정 + §4.2.2 이벤트 계약 적용 (여기서 `original_ledger_id := v_payment.id`가 **비로소 유효해진다**)
4. `catchmenu_payment.confirm_refund()` `CREATE OR REPLACE` — 동일 + §4.2.1 fallback 재설계
5. **`catchmenu_payment.get_payment_status()` `CREATE OR REPLACE`** — **§7.1 참조 (권장: 포함)**
6. (E3 처분 결정 시) `refund_payment()` 정정 또는 `REVOKE` — **§5.4에 따라 이월 가능**
7. 필요 시 message_catalog / error_codes 행 보정

> **순서 근거 (권장 순서):** 3~5단계의 함수 본문이 1·2단계의 컬럼·허용값을 참조한다. PL/pgSQL 본문은 지연 바인딩이므로 역순으로 적용해도 `CREATE OR REPLACE` 자체는 통과하지만, **첫 실행에서 실패**한다. 단일 마이그레이션 트랜잭션 안에서 적용되면 최종 상태는 동일하므로 순서가 절대적 요건은 아니나, **안전을 위해 1→7 순서를 권장한다**(중간 실패 시 진단이 명확해진다).

### §7.1 `fee_amount` 전수 분포와 REPLACE 범위 (2026-07-20 정밀화)

`0098`의 `fee_amount` 6곳을 함수별·성격별로 전수 분류했다. **변수 사용과 컬럼 참조를 구분하는 것이 핵심**이다.

| 위치 | 함수 (경계) | 형태 | 판정 |
|---|---|---|---|
| L186 | `confirm_payment()` (L149–825) | `v_fee_amount int;` **선언** | **정상 — 로컬 변수** |
| L426 | `confirm_payment()` | `v_fee_amount := case p_provider_type` **계산** | **정상 — 로컬 변수** |
| L804 | `confirm_payment()` | `'fee_amount', v_fee_amount,` **JSON 출력** | **정상 — 로컬 변수 값 출력** |
| **L1190** | **`request_refund()`** (L1092–1333) | `fee_amount, net_amount,` **컬럼 목록** | ❌ **phantom** |
| **L1204** | **`request_refund()`** | `-(pl.fee_amount * p_refund_amount` **컬럼 참조** | ❌ **phantom** |
| **L1579** | **`get_payment_status()`** (L1527–) | `'fee_amount', fee_amount,` **컬럼 참조** | ❌ **phantom** |

> **⚠️ 지적사항 #6에 대한 정정.** "`confirm_payment()`에 `fee_amount` 3곳이 있으므로 REPLACE 범위에 포함"이라는 지적은 **성립하지 않는다.** `confirm_payment`의 3곳(L186/426/804)은 **모두 로컬 변수 `v_fee_amount`** 이며 컬럼을 참조하지 않는다 — 42703이 발생하지 않고 고칠 것도 없다. **불필요하게 REPLACE 범위에 넣으면 마이그레이션 위험만 커진다.**
>
> 실제 phantom **컬럼** 참조는 **3곳**이며, `request_refund()` 2곳 + `get_payment_status()` 1곳으로 나뉜다. `request_refund()`는 이미 §7 3단계에 포함돼 있으므로, 남는 쟁점은 **`get_payment_status()` 포함 여부 하나**다.

**API 계약 변경 (ChangeContract 기록 필요):**

| 함수 | 변경 | 계약 영향 |
|---|---|---|
| `confirm_payment()` | **없음** | `fee_amount` 키 **유지**(변수 기반) |
| `get_payment_status()` | 포함 시 `fee_amount` 키 **삭제** | ⚠️ **응답 스키마 변경** — Stage 5 ChangeContract에 명시적 계약변경으로 기록 |

**`get_payment_status()` 포함 여부**

| 선택지 | 결과 |
|---|---|
| **(권장) §7 REPLACE 범위에 포함** | `fee_amount` phantom이 `0098`에서 **완전 소멸**. O4의 "참조 완전 제거"가 문자 그대로 달성됨 |
| 미포함 | `get_payment_status()` 호출 시 **42703 잔존**. O4는 "환불 경로에서만 제거"로 축소되고, 결함이 다른 함수에 남는다 |

**권장: 포함.** 근거 — (a) O4 확정 문구가 "참조 **완전** 제거"이므로 1곳을 남기면 확정과 어긋난다. (b) 같은 phantom을 두 번에 나눠 고치면 두 번째가 잊힐 위험이 크다(이 저장소에서 `600570`이 `0098`을 제외해 남긴 잔여가 곧 본 워크패킷이다). (c) 변경 내용이 **참조 삭제뿐**이라 새 로직이 없다.

> **범위 확대에 해당하므로 Human 확인이 필요하다.** 미포함으로 결정할 경우, Overview §4.2에 "`get_payment_status()`의 `fee_amount` 42703은 알려진 잔여"로 명시하고 후속 이월 항목으로 등록할 것.

**주의사항:**

- 마이그레이션 번호는 Stage 2 착수 시점의 **다음 빈 번호**로 확정한다. 본 Logic은 번호를 예약하지 않는다. `600820`(0154→0155) 사례처럼 번호 선점 후 충돌 시 **임의 대체 금지 — 중단하고 보고**한다.
- 정정 대상 함수는 `0098`/`0037` **원문을 수정하지 않는다.** 신규 migration이 `CREATE OR REPLACE`로 덮는다. 그 결과 원문–라이브 괴리가 남는 것은 이 저장소의 알려진 패턴이며, 신규 migration 헤더에 "이 함수의 정본은 본 파일"임을 명시한다.
- `000701 §41`에 따라, 정정하는 RPC에 `EXCEPTION` 핸들러가 있고 그 안에서 `append_audit_record()`를 호출한다면 **그 감사 리터럴도 §3 매핑 대상**이다. C1 덤프에서 함께 확인할 것.

---

## §8 Non-goals (재확인)

- 새 환불 비즈니스 로직·승인 절차·권한 모델·상태 전이 설계 금지.
- 부분환불 금액 계산 규칙 변경 금지.
- `payment_ledger`를 append-only/WORM/복식부기로 전환하는 설계 금지(FTR-F01/CRP-F03 소관).
- 601400의 다른 발견사항(caller-authorization, 노쇼 모델, 한정수량, 착석–테이블 연결, 웹훅 멱등성) 금지.
- `chk_audit_decision` 확장은 **권고하지 않음**(§3.2 Option A).
- `.sql` 파일 생성·수정 금지 (Stage 1.5).

---

## §9 Open Items

| # | 항목 | 성격 | 해소 |
|---|---|---|---|
| ~~O1~~ | ~~`chk_audit_decision` 확장 vs 매핑~~ | **✅ 종결 (2026-07-20, Human 승인).** **매핑 채택** — `REFUND_PENDING`→`SUSPENDED`, `REFUND_FAILED`→`FAILED`, 정확한 상태는 `p_decision_payload` 보존. 제약 미변경 | §3.4 |
| O2 | ~~정본 환불 엔진 지정~~ → **E1+E2 우선 정정 확정.** 남은 것은 E3 처분뿐 | ✅ C3 완료 → E3 처분만 Human 결정 (이월 가능) | §5.4 |
| O8 | `confirm_refund()` 실호출자 0건 — 환불 확정 주체 부재 | **본 워크패킷 범위 밖.** 후속 워크패킷 후보 | §5.5 |
| ~~O3~~ | ~~`original_ledger_id` 파생 vs 컬럼 추가~~ | **✅ 종결 (2026-07-20).** 파생 불가가 코드 레벨로 증명 → **컬럼 추가 확정**, §4.2 단일 예외로 Human 승인 | §4.3.1 / §4.4 |
| ~~O4~~ | ~~`fee_amount` 제거 vs 정산 조회~~ | **✅ 종결 (2026-07-20, Human 승인).** **참조 6곳 완전 제거**, 별도 대안 없음 | §4.3.2 |
| ~~O5~~ | ~~`provider_response` 사용처 판별~~ | **✅ 종결 (2026-07-20).** 전수 분류 완료 — 12행/13토큰(UUID 6 / JSON 7), 환불 범위 내 **3행 4토큰**(L1341/L1401/L1402). 잔여는 payload 키 표현 택일뿐(§4.2.1 → Stage 5) | §4.2 |
| ~~O7~~ | ~~`payment_events` 환불 기록 방식~~ | **✅ 종결 (2026-07-20).** 이벤트 계약 확정(§4.2.2) + `chk_payment_event_type` 확장 필요 발견(§4.2.3) | §4.2.2 |
| ~~O9~~ | ~~부분/전액 환불 판정~~ | **✅ 범위 확장 확정 (2026-07-20, Human 승인).** §1.1 명시적 예외로 설계 포함. 판정 기준 = **잔여(`net_amount`)** | §4.2.4 |
| **O10** | **금액 모델 상충** — `0037`(원거래 누적) vs `0098`(음수 자식 행). `0098` INSERT가 `chk_ledger_amounts`를 2가지로 위반(④⑤) | **Cursor 확인 후 확정.** (가) 원거래 누적 **권고** | §4.2.4.2 |
| **O11** | `p_is_partial` 파라미터 계산 vs 신뢰 | (A) 서버 계산 **권고**, 시그니처는 유지 | §4.2.4.5 |
| ~~O6~~ | ~~`010412` `REVERSAL_*`의 SQL 연결 여부~~ | **✅ 종결 — C4 PASS.** 연결 0건 → 범위 밖 확정, 문서 정합화는 별도 이월 | §6.1 |

---

## §10 검증 관점 (Stage 5 TestPlan 인계)

TestPlan은 최소한 다음을 포함해야 한다. **601400 검사는 읽기 전용이었으므로 실행 증거가 없다 — 정정 전 재현이 필수다.**

> **(2026-07-20 갱신)** C3로 실호출자 3건이 확인되면서 재현 경로가 **직접 호출뿐 아니라 실제 업무 경로로도** 가능해졌다. V1~V3는 두 경로 모두에서 수행할 것:
> - **경로 A (직접):** `catchmenu_payment.request_refund()` 직접 호출
> - **경로 B (실업무):** `catchmenu_integrations.cancel_okpos_order()` / `cancel_toss_payment()` / `cancel_toss_pos_order()` 경유
>
> **경로 B가 특히 중요하다.** Overview §1.2가 제기한 판별 — 23514가 **(a) 취소 실패로 표면화**되는지, **(b) 호출부 예외 핸들러에 삼켜져 잘못된 결과 코드로 보고**되는지 — 는 경로 B에서만 확인된다. (b)라면 정정 전까지 취소 실패가 **조용히 은폐**되고 있었다는 뜻이므로, 과거 취소 이력의 정합성 점검 필요 여부를 별도 판단해야 한다.

| # | 검증 항목 |
|---|---|
| V1 | **정정 전 재현**: `request_refund()` 호출 시 `ledger_status='REFUND_PENDING'` INSERT/UPDATE가 23514로 실패하는 것을 실제로 확인 |
| V2 | **정정 전 재현**: `p_decision='REFUND_PENDING'` 감사기록이 23514로 실패하는 것을 확인 |
| V3 | **정정 전 재현**: `confirm_refund()`의 `where ledger_status='REFUND_PENDING'` 조회가 0행을 반환해 `payment_not_found`로 떨어지는 도달불가 분기 확인 |
| V4 | 제약 확장 후 기존 8개 값 행이 모두 그대로 통과(회귀 없음) |
| V5 | 정정 후 요청→확정 전체 경로가 `APPROVED → REFUND_PENDING → REFUNDED` 로 완주 |
| V6 | 실패 경로가 `REFUND_PENDING → REFUND_FAILED`로 완주 |
| V7 | 감사기록이 `SUSPENDED`/`FAILED`로 남고, `p_decision_payload`에 정밀 `ledger_status`가 보존됨 |
| V8 | §4 매핑된 8개 식별자가 모두 해소되어 42703이 발생하지 않음 — **7개는 기존 컬럼/조인/계산으로, `original_ledger_id` 1개는 신규 컬럼으로** |
| **V11** | **컬럼 추가 검증**: `payment_ledger.original_ledger_id`가 `uuid` / nullable / `FK → payment_ledger(id)`로 생성됐고, 기존 28개 컬럼 구조와 기존 행에 영향이 없음 |
| **V12** | **자기참조 무결성**: 환불 행의 `original_ledger_id`가 실제 원 승인 행 id를 가리키고, 존재하지 않는 id INSERT 시 FK 위반(23503)으로 거부됨 |
| **V13** | **원거래 행은 `original_ledger_id`가 NULL**임을 확인(nullable 설계 의도) |
| **V14** | **적용 순서 검증**(§7): 컬럼 추가·CHECK 확장이 함수 교체보다 먼저 적용됐고, 역순 적용 시 첫 실행에서 실패함을 확인 |
| **V15** | **비유일성 시나리오 회귀**: 동일 `order_id`에 복수 `APPROVED` 행이 존재하는 상태를 만들고, 환불이 `original_ledger_id`로 **정확한** 원거래를 지목함을 확인 — O3 기각 근거(`ORDER BY … LIMIT 1`의 오지목 위험)가 실제로 해소됐는지 |
| V9 | 비정본 엔진 처분(REVOKE 등)이 정본 경로를 막지 않음 |
| V10 | `000701 §43`에 따라 위험도와 무관하게 **삼중검증 완주** — "실호출자 0건이므로 가볍게"로 검증자 수를 줄이지 않음 |
