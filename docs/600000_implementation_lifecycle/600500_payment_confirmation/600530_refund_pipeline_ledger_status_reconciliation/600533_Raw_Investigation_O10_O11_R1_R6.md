# O10/O11 확정 조사 — R1–R6 Raw 결과

**Source:** `0098_create_payment_confirm_pipeline_rpc.sql`, `0037_create_payment_cancel_refund_rpc.sql`, `0014_create_payment_ledger.sql`, `0102`/`0103`/`0104`, live DB `supabase_db_yoonsul_wait_order_handoff`

---

## R1. `request_refund()` INSERT 금액 계산 전체 라인

**파일:** `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` L1183–1215

```sql
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, session_id,
  provider_type, payment_method,
  provider_tx_id,
  provider_approval_number,
  approved_amount,
  fee_amount, net_amount,
  ledger_status,
  refund_reason,
  is_partial_refund,
  original_ledger_id,
  business_day, business_timezone
)
select
  p_tenant_id, p_store_id,
  p_order_id, pl.session_id,
  pl.provider_type, pl.payment_method,
  pl.provider_tx_id || '_REFUND',
  null,
  -p_refund_amount,
  -(pl.fee_amount * p_refund_amount
    / pl.approved_amount)::int,
  -(pl.net_amount * p_refund_amount
    / pl.approved_amount)::int,
  'REFUND_PENDING',
  p_refund_reason,
  p_is_partial,
  v_payment.id,
  v_business_day, v_timezone
from catchmenu_payment.payment_ledger pl
where pl.id = v_payment.id
returning id into v_refund_ledger_id;
```

| 항목 | 값 |
|---|---|
| **음수 삽입 범위** | `approved_amount`, `fee_amount`, `net_amount` 3컬럼 모두 음수 |
| **비율 형태** | `-(pl.fee_amount * p_refund_amount / pl.approved_amount)::int`, `-(pl.net_amount * p_refund_amount / pl.approved_amount)::int` |
| **미설정** | `cancelled_amount`, `refunded_amount` → default 0 |
| **0014 CHECK 충돌** | `approved_amount > 0` 위반; `net_amount = approved_amount - cancelled_amount - refunded_amount` 위반 가능 (비례 `pl.net_amount` 사용 시) |

**예:** `approved=10000, net=9500, refund=5000` → insert `approved=-5000, net=-4750` but CHECK expects `net=-5000`.

**스키마 갭 (live):** INSERT가 참조하는 `fee_amount`, `provider_tx_id`, `payment_method`, `refund_reason`, `is_partial_refund`, `original_ledger_id` 및 NOT NULL `intent_id`, `ledger_entry_type` — live `\d payment_ledger`에 **없음** (0 columns matched).

---

## R2. `refund_payment()` — `refunded_amount` vs `cancelled_amount`

**파일:** `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` L520–607

**결론: 환불은 `refunded_amount` 사용. `cancelled_amount`에 환불 기록하지 않음.**

```sql
-- L551-554: refund accumulation
v_new_refunded_amount := v_ledger.refunded_amount + p_refund_amount;
v_new_net_amount := v_ledger.approved_amount
  - v_ledger.cancelled_amount
  - v_new_refunded_amount;

-- L604-605: UPDATE writes refunded_amount, not cancelled_amount
refunded_amount = v_new_refunded_amount,
net_amount = v_new_net_amount,
```

| 필드 | 환불 RPC 역할 |
|---|---|
| `refunded_amount` | **증가 (환불 누적)** |
| `cancelled_amount` | **읽기만** (선행 취소분 net 계산용) |
| `cancelled_amount` UPDATE | **없음** (별도 `cancel_payment` RPC L307–357에서만 증가) |

**별도 결함 아님** — 0037 모델은 in-place UPDATE, 동일 APPROVAL 행.

---

## R3. `ledger_entry_type='REFUND'/'PARTIAL_REFUND'` 실제 생성 이력

### Live DB

```sql
SELECT count(*) FROM catchmenu_payment.payment_ledger;
-- 0

SELECT ledger_entry_type, count(*) FROM catchmenu_payment.payment_ledger GROUP BY 1;
-- (0 rows)

SELECT count(*) FROM catchmenu_payment.payment_events WHERE event_type ILIKE '%refund%';
-- 0
```

### Migration grep

- `REFUND` / `PARTIAL_REFUND` as `ledger_entry_type`: **0014 CHECK 정의만** (L206–207)
- `payment_ledger` INSERT across migrations: `'APPROVAL'` only (`0098` confirm_payment L663), or `ledger_entry_type` **생략** (`request_refund` L1183)

### Audit (0037 in-place 모델 근거)

```sql
SELECT audit_type, decision, subject_type, decided_at,
       decision_payload, before_state, after_state
FROM catchmenu_ledger.audit_records
WHERE audit_type ILIKE '%refund%';
```

| audit_type | decision | payload 핵심 | before → after |
|---|---|---|---|
| `payment_refunded` | `COMPLETED` | `refund_amount:10000, new_refunded_amount:10000, new_net_amount:0` | `{ledger_status:APPROVED, net_amount:10000}` → `{ledger_status:REFUNDED, net_amount:0}` |

**판단:** 운영 증거는 **0037 in-place** (동일 행 status/refunded_amount/net 변경). **0098 append-row** (`REFUND_PENDING`, 음수 amount) 및 **`REFUND`/`PARTIAL_REFUND` entry_type 행** — 생성 이력 **0**.

---

## R4. `original_ledger_id` 원거래 조회 — 자기참조 1회 조인

### 설계상 쿼리 (1-hop JOIN 충분)

```sql
SELECT
  orig.approved_amount,
  orig.net_amount,
  orig.refunded_amount,
  orig.cancelled_amount
FROM catchmenu_payment.payment_ledger r
JOIN catchmenu_payment.payment_ledger orig
  ON orig.id = r.original_ledger_id
WHERE r.id = :refund_ledger_id;
```

### `confirm_refund` 실제 사용 (L1370–1418)

- SELECT: `original_ledger_id` 읽음
- UPDATE original: `where id = v_refund.original_ledger_id` — **status/refunded_at만**, amount 미조회

### Live schema

```sql
SELECT column_name FROM information_schema.columns
WHERE table_schema='catchmenu_payment' AND table_name='payment_ledger'
  AND column_name = 'original_ledger_id';
-- (0 rows)
```

**결론:** 조인 패턴 자체는 1회로 충분. **live에는 컬럼 없음** → 현재 DB에서 실행 불가. O10/O11 구현 시 column add 선행 필요.

---

## R5. 호출자 3개 — `p_is_partial` / `p_refund_amount`

| Caller | File:L | `p_refund_amount` | `p_is_partial` |
|---|---|---|---|
| `cancel_okpos_order` | `0102` L1045–1051 | **`0` (hardcoded)** | **`false` (hardcoded)** |
| `cancel_toss_pos_order` | `0104` L954–960 | **`0` (hardcoded)** | **`false` (hardcoded)** |
| `cancel_toss_payment` | `0103` L792–795, L834–842 | `v_refund_amount := coalesce(p_cancel_amount, v_request.approved_amount)` | **`p_cancel_amount is not null AND p_cancel_amount < v_request.approved_amount`** (computed) |

**0103 partial 판정:**

```sql
p_is_partial := p_cancel_amount is not null
  and p_cancel_amount < v_request.approved_amount
```

**0102/0104:** amount=0 → R6 검증에서 **4016** 즉시 반환 (INSERT 미도달).

---

## R6. `refund_amount_invalid` (4016) 기존 검증

### 등록 (0098 L104–107, L127–128)

```sql
(4016, 'refund_amount_invalid', 'PAYMENT', 'INVALID_INPUT', 400, 'WARNING', null)
-- ko: '환불 금액이 올바르지 않습니다'
```

### `request_refund` 유일 검증 (L1157–1170)

```sql
if p_refund_amount <= 0
  or p_refund_amount > v_payment.approved_amount
then
  return catchmenu_common.build_error_response(
    p_error_key := 'refund_amount_invalid',
    p_params := jsonb_build_object('max_refund', v_payment.approved_amount),
    ...
  );
end if;
```

| 검사 | 존재 |
|---|---|
| `<= 0` | **있음** |
| `> v_payment.approved_amount` (latest APPROVED row) | **있음** |
| 누적 환불 초과 (`refunded_amount` 합산) | **없음** |
| `net_amount` / `(approved - cancelled - refunded)` 초과 | **없음** |
| partial cancel 후 잔액 대비 | **없음** |

**0037 대비:** `refund_payment` L556–562 `refund_exceeds_net_amount` — **0098 `request_refund`에는 없음**.

---

## O10/O11 시사점 (요약)

1. **두 모델 공존:** 0037 in-place (audit 증거) vs 0098 append-row (미검증/스키마 불일치).
2. **0102/0104** `p_refund_amount := 0` → **4016** — OKPOS/Toss-POS cancel 경로는 `request_refund` INSERT까지 **도달 불가**.
3. **R1 INSERT**는 live schema/CHECK와 **실행 불가** (phantom columns + negative amount + missing NOT NULL).
4. **R4** self-join 패턴 OK, **`original_ledger_id` column add** 선행 필요.
