# 600531_Overview_Refund_Pipeline_Ledger_Status_Reconciliation.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-20

## Change ID

`refund_pipeline_ledger_status_reconciliation`

---

## §0.1 Snapshot Decision — 우선순위 상향 (2026-07-20)

> **C3 조사 결과로 이 워크패킷의 성격이 바뀌었다. "잠재적 결함"이 아니라 "실제 운영 크래시 가능"이다.**

Cursor C3 조사에서 `request_refund()`에 **실제 라이브 호출자 3건**이 확인됐다(§1.2). 이는 본 Overview 최초 작성 시점의 전제("3함수 모두 실호출자 0건")를 뒤집는다.

| 항목 | 최초 작성 시점 (§1.2 구판) | C3 확정 후 (현행) |
|---|---|---|
| 결함 성격 | 운영 중 발생하지 않은 **잠재** 결함 | **실제 운영 크래시 가능** |
| 발현 조건 | 직접 PostgREST 호출 시에만 | **OKPOS/Toss 취소 처리가 일어날 때마다** |
| 시급성 | 긴급 핫픽스 아님 | **상향 — 결제 취소 경로가 상시 노출** |
| 배포 우선순위 | 통상 순번 | **결제 도메인 내 선순위 검토 대상** |

**상향 근거:** 취소는 예외 흐름이 아니라 **정상 운영 흐름**이다. OKPOS·Toss 연동 매장에서 주문 취소가 발생하면 `cancel_*` → `request_refund()` → `ledger_status='REFUND_PENDING'` 기록 시도 → `chk_ledger_status` 위반(23514)으로 실패한다. 즉 **취소 자체가 실패하거나, 호출부 예외 핸들러가 이를 삼켜 잘못된 결과 코드로 보고**된다(후자는 `601030`에서 이미 확인된 패턴 — 감사기록 제약 위반을 예외 핸들러가 삼켜 정상 상태를 "실패"로 오분류한 사례).

**다만 범위는 확대하지 않는다.** 시급성만 상향하며, §4.2의 금지 목록(새 환불 로직 설계 금지, 601400의 다른 발견사항 금지)은 그대로 유지한다.

---

## §0 선행 확인 — Cursor Stage 1 조사 (C1~C4 전 게이트 PASS, 2026-07-20)

이 Overview는 601400 검사 프로그램의 확정 진단(§1)을 근거로 작성됐다. 그러나 601400 검사는 **마이그레이션 원문(정적 문서·SQL)만** 대상으로 했고, 라이브 DB 상태와 실호출자를 실행 확인하지 않았다. 따라서 4건을 **Logic 확정 전 Cursor 조사로 실증**하도록 게이트를 걸었고, **전 게이트가 통과됐다.**

조사 결과가 실제로 문서를 바꾼 지점은 두 곳이다 — **C3**(실호출자 0건 전제가 뒤집혀 §0.1 우선순위 상향 + §1.2 전면 정정)와 **C4**(010412 범위 밖 확정). C1·C2는 기존 서술을 **확증**했다.

| # | 조사 항목 | 조사 방법 | 이 결과가 바꾸는 것 |
|---|---|---|---|
| 게이트 | 조사 항목 | 결과 | 판정 |
|---|---|---|---|
| **C1** | `0098`의 `request_refund()`/`confirm_refund()`, `0037`의 `refund_payment()`의 **라이브 함수 정의**가 마이그레이션 원문과 일치하는지 | **2건 raw 체크섬 일치** (`request_refund`/`confirm_refund`). **1건 raw 불일치** — `refund_payment`(0037): 라이브 **6,901자** vs 소스 **6,668자**. **단 주석·공백 제거 후 실행가능 토큰은 동일 → 의미상 drift 없음** | **✅ PASS** — 세 함수 모두 **의미 수준에서** 원문과 일치. 매핑표를 원문 기준으로 적용 가능 |
| **C2** | `catchmenu_payment.payment_ledger` **실제 컬럼 전수** + `ledger_entry_type` 유일성 | **28개 컬럼 확인.** `chk_ledger_status` **8개 값** 확인. §2 phantom 재분류 **전부 검증됨.** 유일성은 **비유일로 판정**(코드 레벨 증명) | **✅ PASS (완전)** — 유일성 항목 포함 종결. 결과가 O3를 닫았다 → §4.2 예외 승인 |
| ~~**C3**~~ | ~~3개 환불 엔진 각각의 **실호출자 0건** 재확인~~ | 결과는 "0건"이 **아니었다** — `request_refund()` 실호출자 3건 | **✅ 완료** → §1.2 / §0.1. 위험도·배포순서가 실제로 바뀌었다 |
| **C4** | `010412`(`REVERSAL_*` 어휘)가 **실제 SQL과 연결되는지** | **SQL/함수/제약 연결 0건** (Cursor grep 결과). `010412`는 **순수 설계문서** | **✅ PASS** — 본 워크패킷 **범위 밖 확정**. 문서 어휘 정합화는 별도 이월 (Logic §6) |

**C1~C4 전 게이트 통과 (2026-07-20).**

### §0.2 최종 게이트·결정 상태 (2026-07-20)

**조사 게이트 — 4/4 PASS**

| C1 | C2 | C3 | C4 |
|---|---|---|---|
| ✅ 체크섬 일치 | ✅ 28컬럼/8값/재분류/비유일 | ✅ 실호출자 3건 발견 | ✅ SQL 연결 0건 |

**설계 결정 — 3/3 확정 (전부 Human 승인, 2026-07-20)**

| 결정 | 확정 내용 | 근거 |
|---|---|---|
| **O1** | `chk_audit_decision` **매핑** 채택(확장 기각) — `REFUND_PENDING`→`SUSPENDED`, `REFUND_FAILED`→`FAILED`, 정확값은 `p_decision_payload` 보존 | Logic §3.4 |
| **O3** | `original_ledger_id` **컬럼 추가** 확정(파생 기각) — §4.2 단일 예외 | Logic §4.3.1 |
| **O4** | `fee_amount` **참조 완전 제거** 확정(대안 없음) | Logic §4.3.2 |

**확정된 변경 규모**

| 구분 | 내용 |
|---|---|
| **신규 컬럼** | **1개** — `payment_ledger.original_ledger_id` (§4.2 단일 예외) |
| **관련 DDL** | **3건** — ① 자기참조 FK(`original_ledger_id → payment_ledger.id`) ② `chk_ledger_status` 확장(8→10) ③ **`chk_payment_event_type` 확장(19→21)** (Logic §4.2.3) |
| 제약 **미변경** | `chk_audit_decision` (§3.4 매핑으로 해소) |
| 함수 정정 | 2건(`request_refund`/`confirm_refund`) + `get_payment_status`(§7.1 권장 포함) + E3 처분(이월 가능). **`confirm_payment`은 불포함** — `fee_amount` 3곳이 모두 로컬 변수라 정정 불요(Logic §7.1) |
| 식별자 정정 | 8건 (기존컬럼 3 / 조인 1 / 계산 1 / 이벤트 2 / 삭제 1 / 신규컬럼 1) |

> **표현 주의:** "스키마 변경 1건"이라는 요약은 부정확하다. 정확히는 **신규 컬럼 1개 + 그에 수반되는 DDL 3건**이다 — ① 자기참조 FK ② `chk_ledger_status` 확장 ③ `chk_payment_event_type` 확장.
> **§4.2 예외가 승인한 것은 `original_ledger_id` 컬럼 1개뿐**이다. FK는 그 컬럼의 무결성 제약이고, CHECK 확장 2건은 각각 §2(원장 상태 어휘)와 Logic §4.2.3(이벤트 타입 어휘)에 속하는 **별개 항목**이다 — 셋 다 "신규 컬럼"이 아니므로 예외 범위를 넓히지 않는다.

### §0.3 Stage 4 진입 판정 — **진입 가능**

남은 Open Item 4건(O2/O5/O7/O8)을 **진입 차단(blocker) / 검증 항목(verification item) / 범위 밖(out-of-scope)** 으로 분류했다.

| Open Item | 분류 | 판단 근거 |
|---|---|---|
| **O2** — E3(`refund_payment`) 처분 | **범위 밖 (이월 가능)** | 실호출자 0건 → 운영 위험 없음. Logic §5.4가 "급하지 않은 결정을 급한 배포에 묶지 않는다"로 이미 분리. 정정 순서 1·2(E1·E2)만으로 실제 크래시가 해소된다 |
| ~~**O5**~~ — `provider_response` 사용처 | **✅ 종결** | 전수 분류 완료 — 12행/13토큰(UUID 6 / JSON 7), 환불 범위 내 **3행 4토큰**. 잔여는 payload 키 표현 택일뿐(Logic §4.2.1 → Stage 5 고정) |
| ~~**O7**~~ — `payment_events` 환불 기록 방식 | **✅ 종결** | 이벤트 계약 확정(Logic §4.2.2). 부수적으로 **`chk_payment_event_type` 확장 필요를 발견**(§4.2.3) — DDL 1건 추가됨 |
| ~~**O9**~~ — 부분/전액 환불 판정 | **✅ 범위 확장 확정** | §1.1 명시적 예외로 Human 승인(2026-07-20). 판정 기준 = **잔여(`net_amount`)** — Logic §4.2.4 |
| **O10** — 금액 모델 상충 | **Cursor 확인 필요** (진입 차단 아님) | `0098` INSERT가 `chk_ledger_amounts`를 2가지로 추가 위반(음수 `approved_amount`, `net_amount` 항등식). (가) 원거래 누적 **권고** — Logic §4.2.4.2 |
| **O11** — `p_is_partial` 계산 vs 신뢰 | **Stage 5 고정** | (A) 서버 계산 **권고** — Logic §4.2.4.5 |
| **O8** — `confirm_refund()` 미호출 | **범위 밖 (후속 워크패킷)** | §8 Non-goals 명시. 제약 위반과 별개의 미완성이며 본 변경이 악화시키지 않는다 |

**결론: 진입 차단 사유 없음 → Stage 4(Architecture Verification) 진입 가능.**

> **단, Stage 4 검증자에게 3가지를 명시적으로 요구한다.**
> 1. **O5·O7의 규칙 적용 결과를 확인할 것.** 12개 사용처와 `refund_reason` 목적지가 실제로 §4.2/§4.1 규칙대로 배정됐는지 확인하고, **Stage 5 ChangeContract에서 확정값으로 고정**되도록 할 것. 미확정 상태로 Stage 2에 넘어가면 Codex가 검증 없이 임의 배정하게 된다.
> 2. **§46(000701) 근거 문서 목록의 완전성을 확인할 것** — Cursor가 놓친 관련 문서가 없는지.
> 3. **§4.2 예외의 경계를 확인할 것** — 추가 컬럼이 `original_ledger_id` **1건뿐**인지, 다른 식별자가 슬그머니 컬럼 추가로 해소되지 않았는지.

> **C2 유일성 항목 결과 — O3 종결로 이어짐 (2026-07-20).**
> `(order_id, ledger_entry_type)`은 **설계상 비유일**로 판정됐다. 판정 근거가 empirical(라이브 0행)이 아니라 **코드 레벨**이라는 점이 결정적이다 — `request_refund`의 `ORDER BY approved_at DESC LIMIT 1`이 동일 order에 복수 `APPROVED` 행을 전제하고, `confirm_payment`가 취소/환불된 주문에도 `APPROVAL` 행을 추가할 수 있다.
> 따라서 파생안(a) 기각 → **`original_ledger_id` 컬럼 추가로 확정**, §4.2의 단일 예외로 Human 승인(2026-07-20). 상세는 Logic §4.3.1 / §4.4.

---

## §1 배경 — 601400 검사 프로그램 확정 진단 (재확인 불필요, 인용)

601400 설계 무결성 검사에서 4개 슬라이스에 걸쳐 동일 결함이 추적됐고, 마지막 슬라이스에서 진단이 **정정**됐다.

| Finding | 슬라이스 | 당시 판단 |
|---|---|---|
| `PAY-F01` | domain_01 (payment) | 감사기록 리터럴이 `chk_audit_decision` 허용값 밖 |
| `SCP-F02` | domain_02 D2 | 환불 파이프라인이 4가지 방식으로 깨짐(23514 + 도달불가 분기) |
| `FSD-F02` | domain_02 D3 | "구현이 폐기된 skeleton 어휘를 가져다 쓰고 `REFUND_PENDING`을 창작했다" |
| **`SLB-F01`** | **domain_03 B** | **↑ FSD-F02는 오진. 최종 정정본** |

### §1.1 최종 진단 (SLB-F01)

`0098`의 `request_refund()`/`confirm_refund()`는 **저장소 전체 설계문서가 일관되게 쓰는 표준 어휘를 정확히 따랐다**:

- `REFUND_PENDING` — 설계문서 **10개 이상**에서 사용 (005410, 008070, 010451, 010452, 010602, 010802, 010814, 010907, 012051, 014035)
- `REFUND_FAILED` — 설계문서 **6개**에서 사용 (004015, 004016, 005221, 008070, 010320, 010452)

즉 **구현이 표류한 것이 아니다.** 실제 이상치는 다음 둘이다:

1. **`chk_ledger_status`(0014)** — 8개 값으로 작성된 이후 한 번도 넓혀지지 않았고, 설계문서 다수가 합의한 두 상태를 애초에 수용한 적이 없다.
2. **`010412`의 `REVERSAL_*`** — 같은 설계 코퍼스에서 혼자 어휘를 갈아탄 소수 이상치.

> **정정된 성격 규정:** 이 결함은 "구현이 설계에서 이탈" 이 아니라 **"스키마가 설계 코퍼스와 대조되지 않은 채 작성됐고, 이후 한 문서가 제3의 어휘로 다시 갈라졌다"** 이다. 따라서 본 워크패킷의 방향은 *구현을 스키마에 맞추는 것*이 아니라 **스키마를 다수 합의 어휘에 맞추는 것**이다.

### §1.2 현재 위험도 — C3 확정본 (2026-07-20 정정)

> **정정 이력:** 본 절의 최초 판본은 "3함수 모두 실호출자 0건 → 잠재 결함"이라고 기술했다. 그 근거였던 601400 검사는 **읽기 전용 정적 검사**였고 호출 그래프를 완전히 추적하지 않았다. Cursor C3 조사로 **오류가 확인되어 아래와 같이 정정한다.** 이 정정이 §0.1 우선순위 상향의 근거다.

| 함수 | 실호출자 | 상세 |
|---|---|---|
| **`catchmenu_payment.request_refund()`** | **3건 (실제 라이브)** | 아래 표 |
| `catchmenu_payment.confirm_refund()` | 0건 | 유지 |
| `catchmenu_payment.refund_payment()` (0037) | 0건 | 유지 |

**`request_refund()`의 실호출자 3건 — 전부 OKPOS/Toss 취소 처리 경로:**

| 호출 함수 | 정의 위치 | 호출 지점 | 실행권한 |
|---|---|---|---|
| `catchmenu_integrations.cancel_okpos_order()` | `0102_create_okpos_integration_pipeline_rpc.sql` | L1045 | `authenticated` |
| `catchmenu_integrations.cancel_toss_payment()` | `0103_create_toss_payments_pipeline_rpc.sql` | L834 | `authenticated` |
| `catchmenu_integrations.cancel_toss_pos_order()` | `0104_create_toss_pos_pipeline_rpc.sql` | L954 | `authenticated` |

세 호출부 모두 동일한 형태로 **표준 환불 파이프라인에 위임**한다:

```
v_refund_result := catchmenu_payment.request_refund( ... );
```

즉 반환값을 소비하는 **동기 위임**이며, 호출부가 이 결과로 후속 분기를 한다.

**위험도 재평가:**

- 이 세 경로는 **OKPOS·Toss 연동 매장의 정상 취소 흐름**이다. 예외 흐름이 아니다.
- 취소가 발생할 때마다 `request_refund()` 내부에서 `ledger_status='REFUND_PENDING'` 기록을 시도하고, `chk_ledger_status`(8개 값) 위반으로 **23514**가 발생한다.
- 결과는 둘 중 하나다 — **(a) 취소 자체가 실패**하거나, **(b) 호출부 예외 핸들러가 이를 삼켜 잘못된 결과 코드로 보고**한다. (b)는 `601030`에서 실증된 패턴이므로 **정정 전 재현(TestPlan V1~V3)에서 어느 쪽인지 반드시 판별**해야 한다.
- 따라서 본 결함은 **잠재적이 아니라 실제 운영 크래시 가능** 상태다(§0.1).

**`confirm_refund()`의 0건이 갖는 별도 의미:** `request_refund()`는 호출되는데 `confirm_refund()`는 아무도 호출하지 않는다. 즉 현재 시스템에는 **환불 요청은 있으나 확정 단계가 없다.** 이는 본 워크패킷이 고치려는 제약 위반과는 **별개의 미완성**이며, §4.2(새 로직 설계 금지)에 따라 이번 범위에서 해결하지 않는다. Logic §5 및 Open Item으로만 기록한다.

---

## §2 정정 대상 정밀 분류 — 지시받은 "phantom 컬럼 8개"의 재분류

지시문은 8개를 일괄 "phantom 컬럼"으로 기술했으나, 이번 턴에 `0014` 원문을 직접 대조한 결과 **세 종류로 갈린다**. 이 구분이 Logic §4 매핑 설계를 좌우한다.

`0014`는 테이블을 **3개** 만든다: `payment_intents`(L14), `payment_ledger`(L154), `payment_events`(L302).

| 식별자 | 0098 사용 | 분류 | 근거 |
|---|---|---|---|
| `provider_tx_id` | 30회 | **진짜 phantom** | 어떤 실제 테이블에도 없음 |
| `provider_response` | 12회 | **진짜 phantom** | 없음. 단 `payment_ledger.provider_response_id`(uuid 참조)는 실재 |
| `refunded_at` | 3회 | **진짜 phantom** | 없음 |
| `original_ledger_id` | 3회 | **신규 추가 컬럼** (2026-07-20 재분류) | 기존엔 없었으나 **§4.2 단일 예외로 추가 확정.** O3 종결로 파생 불가가 코드 레벨 증명됨(Logic §4.3.1) → `0098`의 `original_ledger_id := v_payment.id` 로직이 **실제 스키마에 맞게 된다** |
| `refund_reason` | 8회 | **진짜 phantom** | 없음 |
| `fee_amount` | 6회 | **진짜 phantom → 삭제 대상 확정** (2026-07-20) | `payment_ledger`에 없음. `0084` 정산 테이블에만 존재. **O4 확정: 참조 6곳 완전 제거, 별도 대안 없음** |
| `is_partial_refund` | 2회 | **파생 가능 — 저장 대상 아님** | `refunded_amount < approved_amount`로 계산됨 |
| `payment_method` | 11회 | **오참조 (phantom 아님)** | **`payment_intents`(0014:23)의 실재 컬럼.** `payment_ledger`에 없을 뿐 |

**따라서 정확한 규모는 "phantom 8개"가 아니라 `진짜 phantom 5개 + 파생값 1개 + 잘못된 테이블 참조 1개 + 신규 추가 컬럼 1개`다.**

- `payment_method`는 `payment_ledger.intent_id` 조인으로 해소 → 컬럼 추가 불필요.
- `original_ledger_id`는 **유일하게 컬럼 추가로 해소**(§4.2 예외). O3 종결(2026-07-20)로 파생 불가가 코드 레벨로 증명됐기 때문이다.
- 나머지 5개(`provider_tx_id`/`provider_response`/`refunded_at`/`refund_reason`/`fee_amount`)는 기존 컬럼·이벤트 페이로드·삭제로 해소한다.

이 재분류는 지시문 내용을 부정하는 것이 아니라 **정밀화**이며, Logic §4의 매핑 정확도를 위해 필요하다. **Cursor C2/O3 결과로 최종 확정됨(2026-07-20).**

---

## §3 Change Summary

이번 워크패킷은 **어휘·스키마 정렬과 오참조 정정만** 수행한다. 세 갈래다.

1. **`chk_ledger_status` 확장** — 기존 8개 값에 `REFUND_PENDING`/`REFUND_FAILED` 2개를 추가(총 10개). 다수 설계문서 합의 어휘를 스키마가 수용하도록 맞춘다. `0140/0145/0146/0147/0150`이 이미 쓴 `DROP CONSTRAINT` → `ADD CONSTRAINT` 확장 패턴을 그대로 따른다.
2. **감사 경로 정정** — `p_decision := 'REFUND_PENDING'`이 `chk_audit_decision`(11개 값) 위반. **확장이 아니라 기존 유효값 매핑**을 권고한다(근거: `601030` 선례, Logic §3).
3. **오참조 식별자 8개 정정** — §2 분류대로 실제 컬럼/조인/계산식으로 매핑.

부수적으로:

4. **정본 환불 엔진 지정** — 3개 병렬 엔진 중 하나를 canonical로 지정하고 나머지의 처분(유지/폐기/차단)을 결정. **Cursor C3 결과가 판단 근거**이며, 이 Overview는 결론을 미리 정하지 않는다.

---

## §4 범위

### §4.1 In Scope

- `chk_ledger_status` 제약 확장 (0014 → 신규 forward migration)
- `chk_audit_decision` 관련 감사 리터럴 정정 (확장 또는 매핑 — Logic §3에서 선택지 제시)
- `0098`의 `request_refund()`/`confirm_refund()` 내 오참조 식별자 정정
- `0037`의 `refund_payment()` 동일 점검 (C1 결과에 따라)
- 3개 환불 엔진 중 정본 지정 및 비정본 처분 결정
- 위 변경에 대한 message_catalog/error_codes 정합성 점검

### §4.2 Out of Scope — 명시적 금지

- **새로운 환불 비즈니스 로직 설계 금지.** 새 환불 승인 절차, 새 권한 모델, 새 상태 전이, 부분환불 계산 규칙 변경, 정산 연동 신규 설계 모두 금지.
- **601400의 다른 발견사항 금지**: caller-authorization 공백(CRP-F02/601200), 노쇼 모델 4종 충돌(SLB-F05/EWP-F01), 한정수량 미구현(SLB-F03), 착석–테이블 연결 결함(SLB-F02), 웹훅 멱등성(CRP-F01).
- **`010412` 문서 정합화** — C4에서 실제 SQL 연결이 확인되지 않으면 본 워크패킷 범위 밖. 문서 어휘 통일은 별도 이월.
- **새 환불 비즈니스 로직 설계** — 원칙적으로 금지. **단 아래 §1.1 예외 1건을 둔다.**

> **§1.1 예외 (2026-07-20, Human 승인): 부분/전액 환불 판정.**
> `confirm_refund()`가 `REFUNDED`/`PARTIAL_REFUNDED`를 **분류하는 판정 로직**만 이번 범위에 포함한다(Logic §4.2.4).
> **여전히 금지:** 환불 승인·거부 워크플로우, 부분환불 한도, 다단계 승인, 환불 자격 심사 등 그 밖의 모든 새 업무 규칙.
> **근거:** `ledger_entry_type`(`REFUND`/`PARTIAL_REFUND`), `ledger_status`(`REFUNDED`/`PARTIAL_REFUNDED`), `refunded_amount`/`net_amount` 항등식, `event_type` 2종이 **모두 이미 스키마에 존재**한다 — 새 개념 도입이 아니라 기정의된 두 갈래 중 하나를 고르는 분기다.

- **`payment_ledger` 신규 컬럼 추가** — 원칙적으로 금지. **단 아래 단일 예외를 둔다.**

> **예외(2026-07-20, Human 승인):** `payment_ledger.original_ledger_id`(`uuid`, nullable, `FK → payment_ledger.id`) 컬럼 추가만 **유일하게** 허용한다.
> **근거:** O3 조사로 `(order_id, ledger_entry_type)` 조합이 원거래를 유일하게 특정할 수 없음이 **코드 레벨로 증명**됐다(Cursor raw 조사, 2026-07-20).
> **이 컬럼 외 다른 신규 컬럼은 여전히 금지한다.**

  이 예외는 §4.1 In Scope에 **신규 컬럼 1개**를 추가한다(Logic §4.3.1 / §7). 예외의 범위는 이 컬럼 하나로 한정되며, 다른 phantom 식별자(`provider_tx_id`/`refund_reason`/`fee_amount` 등)를 컬럼 추가로 해소하는 것은 **여전히 금지**다 — 그것들은 기존 컬럼·조인·계산·삭제로 해소된다(Logic §4.1).

  **CHECK 제약 확장 2건**(`chk_ledger_status` §2, `chk_payment_event_type` Logic §4.2.3)은 **이 예외와 무관한 별개 항목**이다. 신규 컬럼이 아니라 기존 제약의 허용값 확장이며, §1의 대원칙("스키마를 합의 어휘에 맞춘다")에 직접 해당한다.
- `.sql` 파일 생성·수정 — 본 Stage(1.5)의 산출물은 문서뿐이다.

---

## §5 Candidate Affected Files (이번 턴에 생성/수정하지 않음)

| 파일 | 역할 | 상태 |
|---|---|---|
| `sql/migrations/06xx_*.sql` (번호 미정) | `chk_ledger_status` 확장 + 감사 리터럴 정정 + 오참조 정정 forward migration | 신규 (Stage 2에서 번호 확정) |
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | 원문 — **수정하지 않음**. 신규 migration이 `CREATE OR REPLACE`로 덮음 | 참조만 |
| `sql/migrations/0014_create_payment_ledger.sql` | `chk_ledger_status` 원본 정의 — **수정하지 않음** | 참조만 |
| `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` | `refund_payment()` — 정본 지정 결과에 따라 대상 여부 결정 | C3 대기 |
| `docs/.../600530_.../600533_TestPlan_*.md` | Stage 5 | 미작성 |
| `docs/.../600530_.../600534_ChangeContract_*.md` | Stage 5 | 미작성 |

---

## §6 Direct Dependencies

| 의존 대상 | 관계 |
|---|---|
| `0014_create_payment_ledger.sql` | `chk_ledger_status` 원본 8개 값 + `payment_ledger`/`payment_intents`/`payment_events` 컬럼 정의 |
| `0008_create_ledger_audit.sql` | `chk_audit_decision` 11개 값 |
| `0098_create_payment_confirm_pipeline_rpc.sql` | 정정 대상 함수 2개 |
| `0037_create_payment_cancel_refund_rpc.sql` | 정정 대상 후보 함수 1개 |
| `601030` 워크패킷 | 감사 리터럴 **매핑 선례**(`PENDING`→`SUSPENDED`). Logic §3의 직접 근거 |
| `0150_widen_event_domain_constraint.sql` | 제약 확장 forward migration의 **형식 선례** |

---

## §6.5 Required Context Snapshot Candidates

> 000701 §42(2026-07-13 Human 결정)에 따른 필수 섹션.

### Master Anchor

- 601400 설계 무결성 검사 프로그램의 확정 발견 `SLB-F01`(최종 정정본) — 본 변경의 최상위 판단 근거.
- Human 결정: "다수 설계문서 합의 어휘(`REFUND_PENDING`/`REFUND_FAILED`)를 그대로 채택하고 스키마를 확장한다"(2026-07-20, 지시문 §확정된 방향 1).

### Full Rules Required

- `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` — §42(§6.5 의무), §46(근거 문서 목록 의무), §43(LOW risk 예외 금지 → 삼중검증 완주), §41(RPC EXCEPTION 감사기록 의무)
- `sql/migrations/0014_create_payment_ledger.sql` — 전체
- `sql/migrations/0008_create_ledger_audit.sql` — `chk_audit_decision` 부분
- `docs/.../601030_canonical_kds_release_orchestration/601032_Logic_*.md` — 감사 리터럴 매핑 선례 부분

### Domain Indexes

- `docs/600000_implementation_lifecycle/600500_payment_confirmation/` 하위 Readme/ChangeHistory/NavigationMap — 결제 도메인 워크패킷 위치·순서 파악용.
- **주의:** 601400 검사(KDS-F03)에서 이 도메인의 인덱스 누락이 보고된 바 있다. 인덱스를 단독 근거로 삼지 말 것.

### Excluded Rule Families

- **여전법/카드데이터 규정군**(900170 등) — 본 변경은 카드데이터를 다루지 않고 상태 리터럴과 컬럼 참조만 바꾼다.
- **KDS 릴리즈 게이트 규정군**(0157/0166/601030 본문) — `kds_release_authorized`를 읽지도 쓰지도 않는다. 601030은 *감사 매핑 선례*로만 인용한다.
- **노쇼/대기열 규정군**(006520/010802/0161) — SLB-F05 충돌은 본 워크패킷 범위 밖.
- **caller-authorization 규정군**(010641~010643/601200) — CRP-F02는 별도 워크패킷.

---

## §근거 문서 목록 (Cursor 조사 기반)

> 000701 §46(2026-07-20 추가)에 따른 필수 섹션.
>
> **확정 상태 (2026-07-20).** 아래 A~F는 Cursor Stage 1 조사가 이 워크패킷을 위해 **실제로 찾아낸 근거문서 전체 목록**이며, 원문 그대로 반영했다. 더 이상 잠정 목록이 아니다.
>
> **총 46건** — A 2 / B 13 / C 11 / D 9 / E 10 / F 1.
>
> **수치 이력:** 최초 반영 시점의 물리적 개수는 **35건**이었다(A 2 / B 9 / C 10 / D 9 / E 4 / F 1). 이후 Codex 지적으로 **11건 보완** — `601431`(1) + `600573`~`600576`(4) + 환불 어휘 근거 6건 = **46건**. 지시문의 "35개"는 **보완 이전 수치**이므로, 현행 헤더는 실제 물리적 개수인 **46건**으로 기재한다.
>
> Stage 4 검증자는 §46 마지막 문단에 따라 **이 목록의 완전성(Cursor가 놓친 관련 문서 유무)** 을 함께 확인할 것.

### A. 워크패킷 본체

| 문서 |
|---|
| `600531_Overview_Refund_Pipeline_Ledger_Status_Reconciliation.md` |
| `600532_Logic_Refund_Pipeline_Ledger_Status_Reconciliation.md` |

### B. 인접 워크패킷 (Human 지정)

| 문서 | 참조 이유 |
|---|---|
| `600591`/`600592` (`600590_confirm_payment_from_provider_kds_commit_correction`) | 인접 결제 정정 워크패킷 |
| `601031`/`601032`/`601033`/`601034` (`601030_canonical_kds_release_orchestration`) | **감사매핑 선례 `PENDING`→`SUSPENDED`** — Logic §3.3의 직접 근거 |
| `600571`/`600572`/**`600573`/`600574`/`600575`/`600576`**/`600577` (`600570_cancel_payment_phantom_column_fix`) | **`0037`의 `updated_at` phantom, `0098`은 당시 제외** — 본 워크패킷이 그 잔여 범위를 잇는다. **중간산출물 4건(TestPlan/ChangeContract/Module/Verification) 추가** — 동일 결함 유형의 검증·계약 서식 선례 |

### C. 601400 Fable 검사 슬라이스 보고서 (Human 지정)

| 보고서 | 도메인/슬라이스 |
|---|---|
| **`601431`** | **domain_01 slice_02 payment** — **`PAY-F01`의 출처. 정정 경로의 시작점** |
| `601429` | domain_01 slice_01 waiting |
| `601440` | domain_02 slice_A kitchen_release_gate |
| `601442` | domain_02 slice_B financial_trust_room |
| `601445` | domain_02 slice_C cross_room_plumbing |
| `601449` | domain_02 slice_D1 foundation_static_catalog |
| `601450` | domain_02 slice_D2 static_catalog_runtime_planning |
| `601451` | domain_02 slice_D3 four_side_skeleton_data_governance |
| `601454` | domain_03 slice_A entrance_waiting_policy |
| `601455` | domain_03 slice_B store_legal_boundary |
| `601443` | Cross-Domain Registry |

> 본 워크패킷의 확정 진단(§1.1 `SLB-F01`)은 위 보고서군의 누적 결과다. 정정 경로는 **`PAY-F01`(`601431`, domain_01 slice_02 **payment**) → `SCP-F02`(`601450`) → `FSD-F02`(`601451`) → `SLB-F01`(`601455`)** 이다.
>
> **(2026-07-20 정정)** 최초 판본은 정정 경로의 시작점을 `601429`로 적었으나, `601429`는 domain_01 **slice_01 waiting** 보고서다. `PAY-F01`의 실제 출처는 **`601431`(slice_02 payment)** 이므로 바로잡는다. `601429`는 인접 근거로 유지한다.

### D. SQL (직접 근거)

| 파일 | 참조 이유 |
|---|---|
| `0014_create_payment_ledger.sql` | 스키마 + `chk_ledger_status` 8개 값. §2 재분류의 직접 근거(3개 테이블 컬럼 전수) |
| `0008_create_ledger_audit.sql` | `chk_audit_decision` 11개 값 |
| `0037_create_payment_cancel_refund_rpc.sql` | `refund_payment()` — 3번째 환불 엔진 |
| `0098_create_payment_confirm_pipeline_rpc.sql` | `request_refund()`/`confirm_refund()` — 정정 대상 |
| `0102_create_okpos_integration_pipeline_rpc.sql` | **`request_refund` caller** (`cancel_okpos_order`, L1045) |
| `0103_create_toss_payments_pipeline_rpc.sql` | **`request_refund` caller** (`cancel_toss_payment`, L834) |
| `0104_create_toss_pos_pipeline_rpc.sql` | **`request_refund` caller** (`cancel_toss_pos_order`, L954) |
| `0084_create_reconciliation_advanced_rpc.sql` | `fee_amount`의 유일한 실재 위치 |
| `0150_widen_event_domain_constraint.sql` | CHECK 확장 forward migration 형식 선례 |

### E. 설계 코퍼스 (어휘·경계)

| 문서 | 참조 이유 |
|---|---|
| `010412_Policy_Refund_Cancellation_And_Void_Boundary.md` | **C4 — `REVERSAL_*`, SQL 미연결** |
| `010452_Policy_Refund_WORM_Ledger.md` | `REFUND_PENDING`·`REFUND_FAILED` 양쪽 사용 |
| `010802_Policy_Refund_Cancellation_No_Show_Notice_And_Dispute_Evidence_SOP.md` | 환불상태 레지스트리 |
| `010320_Policy_Payment_Settlement_Refund_Wallet_Financial_Trust_Skeleton.md` | `REFUND_FAILED` 골격(상위 skeleton) |

**환불 어휘 근거 문서 6건 (§1.1 "10개 이상"의 실증 근거 — 2026-07-20 추가)**

§1.1은 `REFUND_PENDING`이 설계문서 10개 이상에서 쓰인다는 사실을 확정 진단의 핵심 근거로 삼는다. 그 주장의 **실증 목록**을 여기에 명시한다(위 4건과 합쳐 10건).

| 문서 | 사용 어휘 |
|---|---|
| `004015_Policy_Payment_KDS_Provider_Backlog_Extraction_And_Runtime_Boundary.md` | `REFUND_FAILED` |
| `004016_Policy_Payment_KDS_Provider_Implementation_Entry_Gate.md` | `REFUND_FAILED` (§12 Refund/Cancel State Review 후보 목록) |
| `010451_Policy_Financial_Risk_Boundary.md` | `REFUND_PENDING` |
| `010602_Policy_Reconciliation_Blind_Spot.md` | `REFUND_PENDING` |
| `010814_Policy_Legal_Notice_Support_Playbook_And_Case_Reason_Code.md` | `REFUND_PENDING` |
| `010907_Policy_POS_Payment_KDS_Integration_Readiness_Intake.md` | `REFUND_PENDING` |

**환불 어휘 근거 문서 — 나머지 5건 (2026-07-20 추가, 전수 완결)**

| 문서 | 경로 | 사용 어휘 |
|---|---|---|
| `005410_Policy_POS_Waiting_Entry_NoShow_And_Prepaid_Cancel_Sync.md` | **`docs/005000_customer_handoff_and_implementation_readiness/005400_pos_waiting_entry_sync/`** | `REFUND_PENDING` |
| `005221_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary.md` | `docs/005000_.../005200_pos_payment_provider_and_kiosk_reuse/` | `REFUND_FAILED` |
| `008070_Policy_Alcohol_Payment_Refund_Dispute_Chargeback_And_Recovery_Evidence.md` | `docs/008000_ai_customer_center/` | `REFUND_PENDING` · `REFUND_FAILED` |
| `012051_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping.md` | `docs/012000_implementation_mapping/` | `REFUND_PENDING` |
| `014035_Policy_POS_InDoubt_Transaction_Network_Cancel_Receipt_Number_And_Financial_Reconciliation.md` | `docs/014000_pos_provider_integration_strategy/` | `REFUND_PENDING` |

> **⚠️ `005410` 동명이인 주의.** `005410_*` 파일은 저장소에 **2곳**에 존재한다.
> - ✅ **인용 대상:** `docs/005000_.../005400_pos_waiting_entry_sync/005410_Policy_POS_Waiting_Entry_NoShow_And_Prepaid_Cancel_Sync.md`
> - ❌ **무관:** `docs/014000_.../archive_duplicate_review/005410_Policy_Pilot_Incident_Retrospective_Blocker_Conversion_And_Next_Store_Learning.md` (아카이브 중복, 주제 무관)

> 이 11건(6+5)은 **설계 입력이 아니라 어휘 합의의 증거**로 인용한다. 본 변경은 이 문서들의 내용을 구현하지 않으며, "다수 문서가 같은 어휘를 쓴다"는 사실만 근거로 삼는다. **§1.1의 `REFUND_PENDING` 10건+ / `REFUND_FAILED` 6건 집계는 이 11건 + `010452`/`010802`/`010320`/`010412`로 완결된다.**

### F. 파이프라인 거버넌스

| 문서 | 참조 이유 |
|---|---|
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §42(§6.5 의무) / §46(근거 문서 목록 의무) / §43(LOW risk 예외 금지 → 삼중검증 완주) |

### 확인했으나 의도적으로 배제한 문서

| 경로 | 배제 근거 (한 줄) |
|---|---|
| `sql/migrations/0157_*.sql`, `0166_*.sql` | KDS 릴리즈 게이트 — 본 변경은 `kds_release_authorized`를 건드리지 않음 |
| `docs/.../006520_*.md`, `010802 §13/§14` 노쇼 부분 | 노쇼 모델 충돌(SLB-F05)은 명시적 범위 밖 |
| `docs/.../010641~010643`, `601200_*` | caller-authorization(CRP-F02)은 별도 워크패킷 |
| `docs/.../004120_*.md` | 한정수량(SLB-F03)은 별도 워크패킷 |
| `docs/.../010601~010603` 조정 3부작 | 조정(reconciliation) 설계는 본 변경의 상태 어휘와 무관 |
| `900170` 여전법 계약 문서군 | 카드데이터 미취급 |
| `docs/.../010452 §5 버전시퀀스`, `010454 복식부기` | append-only/WORM 원장 전환은 FTR-F01/CRP-F03 소관, 본 변경은 기존 mutable 모델을 유지 |

---

## §7 Open Questions

> **전 항목 종결 (2026-07-20).** Q1~Q5 모두 Cursor 조사 또는 Human 승인으로 해소됐다. 이력 추적을 위해 표를 보존한다.

| # | 질문 | 종결 결과 |
|---|---|---|
| ~~Q1~~ | ~~`chk_audit_decision` 확장 vs 매핑~~ | **✅ 매핑 채택** (확장 기각). `REFUND_PENDING`→`SUSPENDED`, `REFUND_FAILED`→`FAILED`, 정확값은 `p_decision_payload` 보존 — Logic §3.4 |
| ~~Q2~~ | ~~3개 환불 엔진 중 정본은? 비정본 처분은?~~ | **✅ 순서 문제로 재정의.** E1(+E2) 우선 정정 확정(실호출자 3건). **E3 처분은 이월 가능** — Logic §5.4 |
| ~~Q3~~ | ~~`original_ledger_id` 파생 vs 컬럼 추가~~ | **✅ 컬럼 추가 확정** (파생 불가 코드 레벨 증명). §4.2 단일 예외 Human 승인 — Logic §4.3.1 |
| ~~Q4~~ | ~~`fee_amount` 제거 vs 정산 조회~~ | **✅ 참조 완전 제거 확정**, 별도 대안 없음 — Logic §4.3.2 |
| ~~Q5~~ | ~~`010412` `REVERSAL_*` 처분~~ | **✅ 범위 밖 확정** (SQL 연결 0건). 문서 어휘 정합화는 별도 이월 — Logic §6.1 |

---

## §8 Known Gaps / Uncertainties

- ~~본 Overview의 컬럼·리터럴 수치는 마이그레이션 원문 기준이며 라이브 일치는 C1/C2로만 확정된다.~~ → **해소 (2026-07-20).** C1이 라이브 정의–원문 **체크섬 일치**를, C2가 **28개 컬럼 / 8개 값 CHECK / §2 phantom 재분류**를 확증했다. 원문 기준 서술을 그대로 신뢰할 수 있다.
- ~~미해소 1건: `ledger_entry_type` 유일성~~ → **해소 (2026-07-20).** 비유일 판정 → O3 종결 → `original_ledger_id` 컬럼 추가 확정(§4.2 단일 예외).
- **범위 변경 기록 (2026-07-20 최종):** 최초 작성 시점의 범위("제약 확장 1건 + 함수 정정만")에서 두 항목이 늘었다.
  1. **신규 컬럼 1개** (`original_ledger_id`) — §4.2 단일 예외, **Human 승인 완료**
  2. **CHECK 확장 1건 추가** (`chk_payment_event_type` 19→21) — Logic §4.2.3. 이벤트 계약 확정 과정에서 **기존 제약과의 충돌을 발견**해 불가피하게 포함. `chk_ledger_status` 확장과 동일 성격이므로 예외 승인 대상이 아니다.

  그 외 §4.2 금지 목록은 변동 없다. **`confirm_payment()`은 REPLACE 범위에 넣지 않는다** — `fee_amount` 3곳이 모두 로컬 변수여서 정정할 것이 없다(Logic §7.1).
- 601400 검사는 읽기 전용이었으므로 **실행 증거(실제 23514 재현)가 없다.** TestPlan(Stage 5)에서 정정 전 재현 → 정정 후 통과를 반드시 포함해야 한다.
- `payment_events` 테이블이 환불 이벤트를 이미 어떻게 기록하는지는 이번 턴에 확인하지 않았다. `refund_reason`/`provider_response` 페이로드의 목적지 후보이므로 Logic §4에서 Open Item으로 남긴다.
- 000701 §43에 따라 본 변경도 위험도와 무관하게 **삼중검증 완주** 대상이다. "실호출자 0건이므로 가볍게"라는 판단으로 검증자 수를 줄이지 않는다.
