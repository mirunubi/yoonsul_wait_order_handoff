# 600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 2 — §3 최종 확정(옵션 C+ 채택, ChatGPT+제미나이 교차검증, 2026-07-15). §1의 `intent_id` 관련 서술을 C+ 확정에 맞춰 갱신.

## Change ID

`confirm_payment_column_drift_and_intent_linkage_fix`

## §0 전제 — `600551_Overview.md` Revision 2 반영, legacy 자료 재사용 근거

이 문서는 `0098`(`confirm_payment`)/`0109`(`flush_offline_queue`의 `RECORD_MANUAL_PAYMENT`)/`0130`(`record_van_transaction`) 3개 파일을 `0027`(`confirm_payment_from_provider`) 기준으로 정합화하는 설계를 다룬다. `600551_Overview.md` §2/§2.1/§4.1이 확인한 사실(phantom 컬럼 4-5개, `intent_id`/`ledger_entry_type` 누락, `0130`만의 `tax_amount`)과 §5.1의 신규 발견(`0142`가 Toss Payments 경로의 intent 값을 이미 준비해뒀으나 `confirm_payment()`로 전달하지 않음)을 전제로 한다.

**Legacy 자료 재사용 근거**: `docs/990000_legacy_quarantine/604000_workpackets/604250.../604253_Logic_...md`(2026-07-01)가 이 문제를 사실상 동일한 범위(`0098` 단독이지만 `0109`/`0130`도 같은 패턴이라고 이미 기록, §2.1.3)로 분석해 옵션 A/B/C와 intent-binding 후보 A-F를 만들어뒀다. 이 문서(600552)는 그 분석의 사실 관계를 재검증한 뒤 재사용하고, `0142`(604253 작성 이후 배포됨)가 바꾼 부분만 갱신한다. 격리(`990000_legacy_quarantine`) 사유는 분석 내용의 오류가 아니라 거버넌스 세대교체다(`990000_legacy_quarantine/600000_Index_Implementation_Lifecycle.md`: 옛 `600179` 파이프라인 가이드가 현재의 `000701`로 대체되며 그 하위 전체가 격리됨, "Runtime implementation: Not granted" 상태로 애초에 실행 승인 자체가 없었다) — 즉 604253의 사실관계는 여전히 신뢰할 수 있는 참고 자료다.

## §1 `0027` 기준 세 파일 각각의 정확한 수정 설계

### §1.1 공통 컬럼 매핑 (phantom → `0014` DDL 실제 컬럼명)

| 현재 사용(3개 파일 공통) | `0014` 실제 컬럼 | 매핑 방식 |
|---|---|---|
| `payment_method`(INSERT 컬럼) | 없음(DDL에 대응 컬럼 자체가 없음) | §1.5에서 별도 처리(단순 치환 불가) |
| `provider_tx_id` | `provider_payment_key` | 컬럼명만 치환(값 의미는 동일 — provider 측 거래/결제 식별자) |
| `fee_amount` | 없음(DDL에 대응 컬럼 자체가 없음) | §1.5에서 별도 처리 |
| `provider_response`(jsonb) | `provider_response_id`(uuid FK) | 단순 치환 불가 — §2에서 별도 다룸 |
| (누락) | `intent_id`(NOT NULL FK) | **확정(§3, 옵션 C+)** — `intent_origin`/`origin_reference`로 모든 경로가 실제 `payment_intents` 행을 만들거나 재사용, §1.1.5 |
| (누락) | `ledger_entry_type`(NOT NULL) | 3개 파일 전부 `'APPROVAL'` 고정값으로 채우면 충분(0027과 동일 — 셋 다 정상 승인 기록이지 취소/환불이 아니므로) |
| `tax_amount`(`0130`만) | 없음(DDL에 대응 컬럼 자체가 없음) | §1.4에서 별도 처리 |

### §1.1.5 `payment_intents.intent_origin`/`origin_reference` — `intent_id` 충전 방법 확정 (Revision 2, 옵션 C+)

**Human 결정(2026-07-15, ChatGPT+제미나이 교차검증, 재논의 금지)**: §3의 옵션 A(진짜 intent만 인정)/B(synthetic intent)/C(경로별 하이브리드) 비교에서, "진짜 intent vs 가짜 intent"라는 이분법 자체를 폐기하고 **옵션 C를 일반화한 C+**를 채택한다 — 모든 결제 경로가 `payment_intents`에 **동등한** intent 행을 갖되, 그 intent가 어떻게 생성됐는지를 명시적으로 구분하는 정식 분류 필드를 추가한다. "합성/가짜"라는 표현은 이 문서 전체에서 더 이상 쓰지 않고, 필요할 때는 **"Derived Intent"** 또는 **"Observed Intent"**(ChatGPT 제안 용어 — 결제가 이미 물리적으로 관찰/완결된 뒤 그 관찰 결과로부터 유도된 intent라는 뜻)로 지칭한다.

**신규 컬럼 2개** (`catchmenu_payment.payment_intents`, 다음 패치 마이그레이션 대상):

```sql
alter table catchmenu_payment.payment_intents
  add column intent_origin text not null default 'PREAUTHORIZED',
  add column origin_reference jsonb;

alter table catchmenu_payment.payment_intents
  add constraint chk_intent_origin check (
    intent_origin in (
      'PREAUTHORIZED',     -- 결제 전 정식 사전 승인 흐름(위젯/QR 리다이렉트 등)에서 생성된 intent
      'POS_SYNTHESIZED',   -- 매장 POS 단말이 결제를 이미 완결한 뒤, 그 사후 보고를 받는 순간 생성된 intent
      'MANUAL_ENTRY',      -- 외부 provider 없이 직원이 수기로 입력한 결제에 대해 생성된 intent
      'VAN_SYNTHESIZED',   -- VAN(부가통신사업자) 카드 단말 거래의 사후 보고를 받는 순간 생성된 intent
      'IMPORTED'           -- 예약값(이번 워크패킷 3개 파일 중 어디도 쓰지 않음) — 배치 이관/과거 데이터 백필 등 향후 용도
    )
  );

comment on column catchmenu_payment.payment_intents.intent_origin is
  'How this intent came to exist. PREAUTHORIZED intents are created before payment confirmation (widget/QR redirect flows). POS_SYNTHESIZED/MANUAL_ENTRY/VAN_SYNTHESIZED intents are Observed Intents — created at (or just before) confirmation time from a report of an already-completed payment. All intent_origin values are equally valid payment_intents rows; this column records provenance, not trust level.';

comment on column catchmenu_payment.payment_intents.origin_reference is
  'Free-form provenance detail for non-PREAUTHORIZED origins, e.g. {"okpos_tx_id": "..."} or {"van_transaction_id": "..."}. Nullable for PREAUTHORIZED (the intent''s own id/idempotency_key is already the reference).';
```

`origin_reference`는 `jsonb`로 결정한다(`text`가 아님) — 이 프로젝트의 다른 근거 필드(`event_payload`/`decision_payload`/`raw_payload` 등)와 동일하게 구조화된 다중 필드를 담을 수 있어야 하고, 배경이 예시로 든 `"OKPOS transaction_id: 123456789"` 같은 사람이 읽는 문자열도 `jsonb_build_object('okpos_tx_id', '123456789')` 형태로 표현 가능하다.

**경로별 적용(확정)**:

| 경로 | `intent_origin` | `origin_reference` 예시 |
|---|---|---|
| Toss Payments(`0103`/`0142`) | `'PREAUTHORIZED'` | `jsonb_build_object('toss_payment_request_id', tpr.id)` — 이미 `0142`가 검증해둔 진짜 사전 intent이므로 origin_reference는 참고용, `intent_id` 자체가 이미 신뢰 근거 |
| OKPOS(`0102`) | `'POS_SYNTHESIZED'` | `jsonb_build_object('okpos_tx_id', v_okpos_tx_id)` |
| Toss POS(`0104`) | `'POS_SYNTHESIZED'` | `jsonb_build_object('toss_pos_tx_id', v_toss_pos_tx_id)` |
| 수기결제(`0109`) | `'MANUAL_ENTRY'` | `jsonb_build_object('offline_queue_item_id', v_item.id, 'note', v_item.action_payload->>'note')` |
| VAN(`0130`) | `'VAN_SYNTHESIZED'`(§1.1.6에서 명명 근거) | `jsonb_build_object('van_transaction_id', v_tx_id, 'van_provider', p_van_provider)` |

### §1.1.6 `VAN_SYNTHESIZED`를 `POS_SYNTHESIZED`와 별도 값으로 결정한 근거

배경은 "POS_SYNTHESIZED 계열(또는 별도 'VAN_SYNTHESIZED') — 세부 명명은 Logic에서 결정"이라고 위임했다. **결정: 별도 값 `VAN_SYNTHESIZED`를 쓴다.** 근거:

1. 이 프로젝트는 이미 `okpos_transactions`(POS)와 `van_transactions`(VAN)를 별개 테이블로 관리한다 — 두 경로의 물리적 채널(매장 통합 POS 단말 vs 제3자 VAN사 카드 단말)이 데이터 모델 수준에서부터 구분되어 있으므로, `intent_origin`도 같은 구분을 유지하는 것이 기존 관례와 일관된다.
2. `601027_Audit.md`의 URGENT Open Item(이 워크패킷의 발단)이 지적했듯, PG/VAN 대사(reconciliation)는 카드/PG 3사 결제와 다른, 더 엄격한 감사 추적 요구사항을 갖는다(§41 원칙, `601021_Overview.md` Open Item (a)-1) — VAN 거래만 별도로 필터링해 감사·대사할 수 있어야 하므로, `POS_SYNTHESIZED`에 합치면 이 구분이 `origin_reference`(비구조화 조회) 없이는 불가능해진다. `intent_origin` 자체로 바로 필터링 가능하게 하는 것이 향후 VAN 대사 워크패킷에 더 유용하다.

### §1.2 `0098`(`confirm_payment`) 수정 설계

```sql
-- 변경 전 INSERT 컬럼(0098:306-317, 현재)
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
)

-- 변경 후 설계안(옵션 A 적용 시 — §3에서 옵션 확정 전까지는 초안)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, session_id,
  intent_id,                    -- 확정(§3 C+): p_intent_id가 있으면 검증 후 재사용(PREAUTHORIZED),
                                 -- 없으면 내부에서 POS_SYNTHESIZED intent 생성
  ledger_entry_type,             -- 신규: 'APPROVAL' 고정
  provider_type,
  provider_payment_key,          -- provider_tx_id → 컬럼명 치환
  provider_approval_number,
  approved_amount, net_amount,   -- fee_amount 제거(§1.5)
  ledger_status,
  approved_at,
  provider_response_id,          -- provider_response(jsonb) → uuid FK(§2)
  reconciliation_status,
  business_day, business_timezone
)
```

`WHERE`절(멱등성 사전검사, `0098:191-200`)도 같은 치환 필요 — `provider_tx_id = p_provider_tx_id` → `provider_payment_key = p_provider_tx_id`(파라미터 이름 자체는 하위호환을 위해 유지 가능, 컬럼 참조만 수정).

### §1.3 `0109`(`flush_offline_queue`의 `RECORD_MANUAL_PAYMENT`) 수정 설계

```sql
-- 변경 전(0109:916-927, 현재)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, provider_type,
  payment_method,
  provider_tx_id,
  approved_amount, fee_amount,
  net_amount, ledger_status,
  approved_at, business_day,
  business_timezone,
  provider_response
)

-- 변경 후 설계안
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id,
  intent_id,                    -- 확정(§3 C+): 내부에서 MANUAL_ENTRY intent 생성(§1.6)
  ledger_entry_type,             -- 'APPROVAL' 고정
  provider_type,
  provider_payment_key,          -- 'MANUAL-' || now()::text 값 그대로, 컬럼명만 치환
  approved_amount, net_amount,   -- fee_amount 제거
  ledger_status,
  approved_at, business_day,
  business_timezone,
  provider_response_id           -- §2
)
```

`0098`과 동일한 패턴이지만, 이 함수는 §1.6에서 다루는 "완전한 사후-보고형"(오프라인 큐에 쌓였다가 나중에 일괄 처리되는 수기 결제 — provider 자체가 없음, `'MANUAL'`)의 극단적 사례다. `payment_method`(현재 `action_payload->>'payment_method'`)는 §1.5와 동일하게 별도 처리.

### §1.4 `0130`(`record_van_transaction`) 수정 설계 — `tax_amount` 포함

```sql
-- 변경 전(0130:393-402, 현재)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, provider_type,
  payment_method, provider_tx_id,
  approved_amount, fee_amount,
  net_amount, tax_amount,
  ledger_status, approved_at,
  business_day, business_timezone,
  provider_response
)

-- 변경 후 설계안
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id,
  intent_id,                    -- 확정(§3 C+): 내부에서 VAN_SYNTHESIZED intent 생성(§1.1.6)
  ledger_entry_type,             -- 'APPROVAL' 고정
  provider_type,
  provider_payment_key,          -- provider_tx_id → 치환
  approved_amount, net_amount,   -- fee_amount 제거
  ledger_status, approved_at,
  business_day, business_timezone,
  provider_response_id           -- §2
  -- tax_amount는 payment_ledger에 대응 컬럼이 없으므로 제거
)
```

**`tax_amount` 처리(신규 컬럼 5번째, 다른 4개와 다른 성격)**: `payment_method`/`provider_tx_id`/`fee_amount`/`provider_response`는 "다른 이름으로라도 개념이 존재"하지만, `tax_amount`(부가세)는 `payment_ledger`/`van_transactions` 어디에도 대응 컬럼이 없는 게 아니라 — **이미 `van_transactions.tax_amount`(`0130:85`)에 정확히 기록되고 있다.** 즉 `payment_ledger`에 다시 넣으려 한 것 자체가 중복 저장 시도였다 — `van_transactions`가 이미 `payment_ledger_id`로 원장과 연결되므로(`0130:427-429`), `payment_ledger` 쪽에 `tax_amount`를 넣지 않고 `van_transactions.tax_amount`만 남기는 것이 가장 단순한 해법이다(신규 컬럼 추가 불필요). 이 부분은 §1.5의 `fee_amount`(대응 테이블 자체가 없어 진짜 결정이 필요한 경우)와 성격이 다르다.

**주의(Codex 발견, 라이브 재확인)**: `van_transactions`는 `catchmenu_payment`/`catchmenu_integrations` 두 스키마에 각각 다른 구조로 존재한다 — `information_schema.tables` 조회 결과 두 행 모두 확인됨. 이 문서가 참조하는 것은 `0130`이 실제로 사용하는 **`catchmenu_payment.van_transactions`**(30개 컬럼, `tax_amount`/`payment_ledger_id` 보유, `record_van_transaction()`이 INSERT하는 바로 그 테이블)이며, **`catchmenu_integrations.van_transactions`**(36개 컬럼, 이름만 같은 완전히 별개의 테이블 — `tax_amount` 없음, 원장 연결 컬럼명도 `payment_ledger_id`가 아니라 `ledger_id`이고 `intent_id` 컬럼을 자체적으로 갖고 있음)와 혼동하지 말 것. 위 결론(`tax_amount`를 `payment_ledger` INSERT에서 제거해도 안전)은 전적으로 `catchmenu_payment.van_transactions` 기준이며, 이 정정은 결론 자체를 바꾸지 않는다.

### §1.5 `fee_amount`/`payment_method` — 단순 치환이 불가능한 항목

`604253` §8(fee_amount)의 기존 분석을 재확인·재사용:
- `fee_amount`: `payment_ledger`에 대응 컬럼 자체가 없다. `0098`은 실제로 요율 기반 계산값을 넣으려 하고, `0109`/`0130`은 `0`으로 하드코딩(계산 안 함) — 셋의 필요도가 다르다. 이 워크패킷의 좁은 목표(크래시 방지, 컬럼 정합)만 보면 "INSERT에서 `fee_amount` 제거"가 가장 간단하지만, `604251`(604250 legacy)이 이미 지적했듯 `0111`/`0100`/`0120`/`0084` 등 다운스트림이 `pl.fee_amount`가 존재한다고 가정하는 읽기 코드를 갖고 있을 수 있다 — **이 다운스트림 재확인은 이번 문서 범위 밖**(§4 Open Item), `fee_amount`를 INSERT에서 제거하는 것과 그 값을 아예 안 남기는 것이 다운스트림에 미치는 영향은 별도로 조사돼야 한다.
- `payment_method`: `payment_ledger`에는 대응 컬럼이 없지만 `payment_intents.payment_method`에는 있다(라이브 재확인 필요, `600551_Overview.md`에서 직접 확인하지 않음 — §4 Open Item으로 이월). `intent_id` 바인딩이 해결되면(§3) `payment_method`는 `payment_intents` 쪽에서 조회 가능해져 `payment_ledger` INSERT에서 완전히 제거해도 될 가능성이 있다.

### §1.6 `0109`(수기결제)의 특수성 — "사후-보고형" 중에서도 provider가 아예 없는 경우 (§3 C+로 확정)

`0109`의 `'MANUAL'` provider_type은 `0027`/`0098`/`0130` 어느 쪽과도 다르다 — 카드사/PG/VAN 같은 외부 provider가 존재하지 않는, 직원이 수기로 입력하는 결제다. **확정(§1.1.5)**: OKPOS/Toss POS와 같은 취급(내부에서 intent 자동 생성)을 받되, `intent_origin`은 `'POS_SYNTHESIZED'`가 아니라 별도 값 `'MANUAL_ENTRY'`를 쓴다 — POS 단말이라는 물리적 채널 자체가 없다는 것이 명확히 구분돼야 하기 때문이다. `payment_intents.provider_type`은 `'MANUAL'`(기존 `0109`가 `payment_ledger.provider_type`에 이미 쓰던 값과 동일하게 유지)로 채운다.

## §2 `provider_response`(jsonb) → `provider_response_id`(uuid FK) — 선행 단계 필요성 확인

**질문**: 세 함수 각각에 새로운 선행 단계(먼저 `provider_raw_events`에 INSERT)를 요구하는가?

**답(라이브 재확인)**: 그렇다. `0027`은 `provider_raw_events`에 스스로 INSERT하지 않는다 — `p_provider_raw_event_id`를 **이미 만들어진 값으로 파라미터로 받는다**(`0027:209`). 실제 INSERT는 `0027`의 호출자인 `0038`(Toss 웹훅 핸들러)이 미리 수행한다(`0038:210` `insert into catchmenu_gateway.provider_raw_events (...)`, `0038:302`에서 그 id를 `p_provider_raw_event_id`로 전달). 즉 `0027`이 DDL에 맞는 이유는 "스스로 처리해서"가 아니라 "호출자가 이미 처리해서 값을 넘겨주기 때문"이다.

반면 `0098`/`0109`/`0130`과 이들의 실제 호출자(`0102`/`0103`/`0104`, 오프라인 큐, VAN 핸들러) 중 어디에도 `provider_raw_events`에 INSERT하는 코드가 없다(`grep -rln "provider_raw_events" sql/migrations/0098*.sql sql/migrations/0102*.sql sql/migrations/0103*.sql sql/migrations/0104*.sql sql/migrations/0109*.sql sql/migrations/0130*.sql` 결과 0건, 이번 문서에서 재확인). **따라서 세 함수 모두 새로운 선행 단계가 필요하다** — `0027`처럼 "호출자가 이미 준비해준 값을 받기만" 할 수 없다.

`catchmenu_gateway.provider_raw_events`의 NOT NULL 컬럼(기본값 없는 것만, 라이브 재확인): `tenant_id`, `provider_type`, `provider_code`, `raw_payload` 4개뿐 — 나머지는 nullable이거나 기본값이 있다. **정정(Codex 발견)**: `NOT NULL` 컬럼은 실제로 9개(`id`/`tenant_id`/`provider_type`/`provider_code`/`raw_payload`/`processing_status`/`processing_attempts`/`first_received_at`/`received_at`, 라이브 재확인)이나, 그중 `id`/`processing_status`/`processing_attempts`/`first_received_at`/`received_at` 5개는 전부 기본값(`gen_random_uuid()`/`'RECEIVED'`/`0`/`now()`/`now()`)이 있어 INSERT 시 값을 넘기지 않아도 된다 — 값을 반드시 채워야 하는 것은 위 4개(`tenant_id`/`provider_type`/`provider_code`/`raw_payload`)뿐이다. 결론(가벼운 INSERT 가능)은 동일하게 유효하다. 이는 비교적 가벼운 INSERT다: `0098`은 이미 `p_provider_response`(jsonb)와 `p_provider_type`을 갖고 있으므로 `raw_payload:=p_provider_response, provider_type:=p_provider_type, provider_code:=p_provider_type`(또는 별도 유도값) 정도로 즉시 구성 가능하다. `0109`/`0130`도 각각 자체 조립한 jsonb(`jsonb_build_object(...)`)/`p_van_response_raw`를 그대로 `raw_payload`로 쓸 수 있다.

**결론(사실, 판단 아님)**: 이 선행 INSERT를 (a) `confirm_payment()`/`flush_offline_queue()`/`record_van_transaction()` **내부**에서 인라인으로 수행할지, (b) 각 함수의 **호출자**(`0102`/`0103`/`0104`, 오프라인 큐 소비자, VAN 핸들러)에게 `0038`처럼 미리 해두도록 요구할지는 옵션 선택 사항이다. 내부 인라인 방식은 호출자 시그니처를 바꾸지 않아도 되므로, §3의 "시그니처 변경 최소화" 방향과 함께 갈 때 자연스럽다.

## §3 함수 시그니처 변경 범위 — 확정: 옵션 C+ (Revision 2, Human 결정 2026-07-15, 재논의 금지)

`604253` §6.1의 후보 A-F, 그리고 이 문서 Revision 1이 만들었던 옵션 A/B/C 비교(아래 §3.3에 이력으로 보존)는 "진짜 intent(Toss Payments) vs 가짜/synthetic intent(나머지)"라는 이분법을 전제로 했다. **Human 결정으로 이 이분법 자체를 폐기하고, 옵션 C를 일반화한 C+로 확정한다**: 모든 경로가 `payment_intents`에 동등한 행을 갖되 `intent_origin`(§1.1.5)으로 생성 경위만 구분한다.

### §3.1 확정된 설계 — `p_intent_id`는 옵션(default null) 파라미터, breaking change 없음

`confirm_payment()`(`0098`)의 시그니처에 `p_intent_id uuid default null`을 **추가**한다(기존 파라미터는 무변경, 순서는 마지막 또는 `p_correlation_id` 앞 — Stage 2에서 확정). 함수 내부 동작:

```text
if p_intent_id is not null then
  -- PREAUTHORIZED 경로 (현재는 Toss Payments/0142만 해당)
  payment_intents에서 p_intent_id를 조회/검증
  (tenant/store/order/금액/provider_type/intent_status 일치 확인 —
   0142의 bind_toss_payment_intent() 검증 로직과 동일한 조건)
  검증 실패 시 에러 반환(현재 0142 wrapper의 payment_intent_binding_invalid와 동일한 정신)
else
  -- Observed Intent 경로 (POS_SYNTHESIZED / MANUAL_ENTRY / VAN_SYNTHESIZED)
  이 order_id에 대해 이미 CONFIRMED된 intent가 있는지 먼저 확인(멱등성, §3.2)
  없으면 catchmenu_payment.create_payment_intent()를 즉시 호출해 새 intent 생성,
  intent_origin/origin_reference를 p_provider_type 기반으로 채움
  (0102/0104 → POS_SYNTHESIZED, 0109 경로 → MANUAL_ENTRY 고정)
end if;
```

**결과적으로 breaking change가 사실상 사라진다**:
- `0102`(OKPOS)/`0104`(Toss POS): 무변경 — `p_intent_id`를 넘기지 않으면(기본값 `null`) 함수가 알아서 `POS_SYNTHESIZED` intent를 만든다.
- `0103`/`0142`: 작은 추가만 필요 — `confirm_toss_payment_legacy_604260` 내부에서 `confirm_payment()`를 호출하는 지점에 `p_intent_id := v_request.payment_intent_id`(`0142`가 이미 resolve/검증해둔 값, `600551_Overview.md` §5.1) 한 줄만 추가하면 된다.
- `0109`/`0130`: 각자 자기 함수 내부에서 위와 동일한 "Observed Intent 생성" 로직을 자체적으로 수행한다(이 둘은 `confirm_payment()`를 호출하지 않고 직접 `payment_ledger`에 INSERT하는 별도 함수이므로, 같은 패턴을 각자 복제하거나 §3.4의 공용 헬퍼를 호출한다).

### §3.2 멱등성 — `604253`이 지적한 "no-intent vs multiple-intent" 위험, `0142` 패턴 재사용

Observed Intent를 자동 생성할 때도 `payment_intents.order_id`만으로 유일성을 가정해선 안 된다는 `604253` §6.2의 경고는 그대로 유효하다 — 재시도로 인한 복수 intent 이력이 있을 수 있다(`0014`의 `payment_intents` 코멘트, `604253` 인용). §3.1의 "이미 CONFIRMED된 intent가 있는지 먼저 확인" 단계는 `0142`의 `bind_toss_payment_intent()`(`600551_Overview.md` §5.1)가 이미 구현한 패턴(기존 활성 intent 재사용, 없으면 `create_payment_intent()` 신규 생성, 복수 후보면 명시적 에러 `TOSS_PAYMENT_INTENT_BINDING_CONFLICT`류)을 그대로 재사용한다 — Observed Intent 경로도 예외 없이 동일한 멱등성 기준을 적용한다(C+의 "모든 경로가 동등한 intent" 원칙과 일치).

### §3.3 공용 헬퍼 후보 — `resolve_or_create_payment_intent()`

`0098`/`0109`/`0130` 셋 다 §3.1의 "PREAUTHORIZED면 검증, 아니면 Observed Intent 생성" 로직이 필요하므로, 이를 `catchmenu_payment.resolve_or_create_payment_intent(p_tenant_id, p_store_id, p_order_id, p_approved_amount, p_provider_type, p_intent_origin, p_origin_reference, p_intent_id default null)` 같은 공용 함수로 뽑아 세 곳에서 재사용하는 것을 제안한다(`0142`의 `bind_toss_payment_intent()` 트리거 로직을 일반화한 버전). 이 함수 자체의 최종 시그니처/구현은 TestPlan/ChangeContract 단계에서 확정한다 — 이 문서는 "공용화가 가능하고 바람직하다"는 설계 방향만 기록한다.

### §3.4 이력 보존 — Revision 1의 옵션 A/B/C 비교표 (폐기됨, 참고용)

Revision 1은 아래 표로 옵션을 비교했으나, Human 결정(§3 상단)으로 **폐기**됐다 — "가짜 intent"라는 옵션 B의 전제 자체가 채택되지 않았기 때문이다. 이력 추적을 위해 원문을 보존한다.

| | 옵션 A(폐기) — 시그니처에 `p_intent_id` 추가, PREAUTHORIZED만 인정 | 옵션 B(폐기) — 내부에서 "synthetic" intent 자동 생성, 정식 분류 없음 | 옵션 C(→ C+로 흡수) — 경로별 하이브리드 |
|---|---|---|---|
| 핵심 차이(C+와) | C+는 이 옵션의 "시그니처 추가" 메커니즘은 채택했으나 "PREAUTHORIZED만 진짜"라는 전제는 폐기 | C+는 "내부 자동 생성" 메커니즘은 채택했으나 "정식 분류 없는 synthetic" 대신 `intent_origin`으로 정식 분류 | C+ 자체가 이 옵션을 일반화한 것 — 경로별 차등 처리는 유지하되 "차등"이 "진짜/가짜"가 아니라 "origin 값"으로 표현됨 |

## §4 Open Items

(a) `confirm_payment_from_provider()`(`0027`)와 `confirm_payment()`(`0098`) 두 파이프라인이 왜 병렬로 존재하는지 — `601021_Overview.md` §10/Open Question에서 이미 제기됐고 이번 워크패킷에서도 미해결로 유지한다. 이 워크패킷은 `0098`을 `0027`의 컬럼 계약에 맞추는 것이지, 두 파이프라인을 하나로 합치는 것이 아니다.
(b) `fee_amount` 제거가 다운스트림 읽기 코드(`604251`이 지목한 `0111`/`0100`/`0120`/`0084`)에 미치는 영향 — 이번 문서에서 확인하지 않음, TestPlan 단계에서 라이브 재확인 필요.
(c) `payment_intents.payment_method` 컬럼 존재 여부 및 `payment_ledger`의 `payment_method` 완전 제거 타당성(§1.5) — 라이브 재확인 필요.
(d) `provider_raw_events` 선행 INSERT를 함수 내부 인라인으로 할지 호출자에게 위임할지(§2) — 옵션 A/B/C 확정과 함께 결정.
(e) `0109`(수기결제)의 intent 취급 방식(§1.6) — synthetic intent 생성 시 `'MANUAL'` provider의 특수성을 어떻게 반영할지 별도 결정 필요.
(f) `604250`~`604256`의 나머지 미독 부분(`604251` ImpactScope 전문, `604254` TestPlan, `604255` ChangeContract, `604256` Approval)을 이 워크패킷의 TestPlan/ChangeContract 단계에서 얼마나 더 재사용할지 — 이번 Logic.md는 `604253`만 집중 재사용했다.
(g) **신규(Revision 2)** — `catchmenu_payment.resolve_or_create_payment_intent()`(§3.3 공용 헬퍼 후보)의 최종 파라미터·리턴 타입·에러 키 체계 — 이 문서는 "만들 가치가 있다"는 방향만 제시했고 구체 설계는 TestPlan/ChangeContract 단계로 이월.
(h) **신규(Revision 2)** — `intent_origin`/`origin_reference` 추가가 `payment_intents`를 읽는 기존 코드(예: `0142`의 `bind_toss_payment_intent()` 자체, 그 외 `payment_intents`를 조회하는 다른 함수들)에 회귀를 일으키지 않는지 — `intent_origin`이 `default 'PREAUTHORIZED'`이므로 기존 행은 자동으로 이 값을 갖게 되어 스키마 자체는 하위호환이나, 그 외 회귀 여부는 TestPlan 단계에서 재확인 필요.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`(Revision 2, 이 문서의 직접 전제)
- `604253_Logic_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md`(`990000_legacy_quarantine`) — 옵션 A/B/C, intent-binding 후보 A-F 원본.

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`/`0109_create_network_handoff_fallback_rpc.sql`/`0130_create_van_handler_extension.sql` — 3개 수정 대상.
- `sql/migrations/0027_create_payment_intent_rpc.sql`/`0038_create_toss_webhook_processor_rpc.sql` — DDL 정합 참조 패턴 + `provider_raw_events` 선행 INSERT 실사례.
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — `bind_toss_payment_intent()` 트리거, §3.1/§3.3 Observed Intent 로직의 재사용 템플릿.
- `sql/migrations/0014_create_payment_ledger.sql` — DDL 제약 전체.
- `catchmenu_payment.payment_intents` 라이브 스키마(24개 컬럼, 이번 턴 재확인) — §1.1.5 신규 컬럼(`intent_origin`/`origin_reference`) 추가 대상.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- 다운스트림 `fee_amount` 읽기 코드(`0111`/`0100`/`0120`/`0084`) 영향 분석(§4 (b)) — TestPlan 단계로 이월.
- `604250`의 격리 사유 심층 조사 — `990000_legacy_quarantine/600000_Index_Implementation_Lifecycle.md` 확인으로 충분, 추가 조사 안 함.
- `0027`/`0038` 자체 수정 — 계속 참고 전용, 수정 대상 아님.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정(Revision 2) — §3 최종 결정 완료.** §1에서 3개 파일 각각의 컬럼 매핑과 INSERT 변경 초안을 설계했다(`tax_amount`는 `van_transactions`에 이미 있으므로 `payment_ledger`에서 제거, `fee_amount`/`payment_method`는 단순 치환 불가로 별도 결정 필요 표시). **§1.1.5/§1.1.6(신규)에서 `payment_intents.intent_origin`/`origin_reference` 스키마를 확정**해 `intent_id`를 채우는 방법 자체를 결정했다 — `PREAUTHORIZED`/`POS_SYNTHESIZED`/`MANUAL_ENTRY`/`VAN_SYNTHESIZED`/`IMPORTED`(예약) 5개 값, "가짜/합성" 대신 "Derived/Observed Intent" 용어로 통일. §2는 Revision 1과 동일(변경 없음). **§3에서 Human 결정(옵션 C+)을 반영해 최종 확정했다** — `p_intent_id`를 `default null` 옵션 파라미터로 추가해 breaking change를 사실상 제거했고(OKPOS/Toss POS는 무변경, Toss Payments는 한 줄 추가), 멱등성은 `0142`의 기존 패턴을 재사용하며, 공용 헬퍼 함수 방향을 제시했다. Revision 1의 옵션 A/B/C 비교표는 §3.4에 이력으로 보존했다(폐기됨). `600553_TestPlan.md`/`600554_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
