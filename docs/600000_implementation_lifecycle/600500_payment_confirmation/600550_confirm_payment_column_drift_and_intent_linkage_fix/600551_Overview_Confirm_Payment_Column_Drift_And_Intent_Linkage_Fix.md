# 600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 2 — 범위 확장(`0098`→`0098`+`0109`+`0130` 통합), Human 결정 반영.

## Change ID

`confirm_payment_column_drift_and_intent_linkage_fix`

## §0.5 Revision 2 — 범위 확장 사유

Human 결정(2026-07-15, 재논의 금지): 이 워크패킷을 `0098`(`confirm_payment`) 단독 정합화에서 `0098`/`0109`(`flush_offline_queue`의 `RECORD_MANUAL_PAYMENT` 분기)/`0130`(`record_van_transaction`) 3개 파일 통합 워크패킷으로 확장한다. `0027`(`confirm_payment_from_provider`)을 계속 canonical 참조 기준으로 삼는다. 아래 §2.1/§4.1/§5.1이 이번 확장분이며, 기존 §1-§7(Revision 1)은 무효화되지 않고 유지된다 — 단 §4의 `0103`(Toss Payments) 행 하나는 이번 재조사로 새로 발견된 사실(§5.1)에 따라 정정한다.

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510_confirm_payment_from_provider_overload_ambiguity/`, `600540_mark_payment_uncertain_overload_ambiguity/` 2개뿐이다(재확인, `ls`). 10단위 워크패킷 번호 관례상 `600540` 다음 빈 번호는 `600550` — 이 워크패킷에 배정한다. `600520`이라는 이름은 이 도메인이 아니라 `600400_kds_did_implementation/600520_domain_folder_reorganization`(별도 폴더-이동 보류 스레드)에 물리적으로 존재하며 이 도메인과 무관함을 재확인했다.

## §1 배경 재확인 — 삼중검증 클레임의 독립 재검증

지시문은 "Cursor+Codex+안티 삼중 검증 완료, 재확인 불필요"라고 명시했으나, 이번 세션의 §43/§44/§40.3 원칙(다수/기존 검증 완료 프레이밍을 그대로 신뢰하지 않고 직접 재확인)에 따라 이 문서는 핵심 주장 전부를 라이브 코드/DB로 독립 재확인했다. 아래 §2-§5는 전부 이번 재확인의 직접 결과이며, 배경이 제시한 결론과 대조해 일치/불일치를 명시한다.

## §2 `0027`(`confirm_payment_from_provider`) vs `0098`(`confirm_payment`) 나란히 대조

| | `confirm_payment_from_provider()`(`0027`, 2026-06-21) | `confirm_payment()`(`0098`, 2026-06-21, 같은 날) |
|---|---|---|
| `payment_intents` 연동 | `p_intent_id`를 받아 `select ... from catchmenu_payment.payment_intents where id = p_intent_id ... for update`로 조회, 결과를 `v_intent`에 저장 후 그 필드들(`order_id`, `session_id`, `provider_type`, `business_day` 등)을 사용 | **파라미터 목록에 `p_intent_id` 자체가 없음**(§3) — `payment_intents` 참조 0건 |
| `payment_ledger` INSERT 컬럼(재확인) | `tenant_id, store_id, order_id, session_id, intent_id, ledger_entry_type, ledger_status, approved_amount, net_amount, provider_type, provider_payment_key, provider_approval_number, provider_approved_at, provider_response_id, reconciliation_status, kds_release_authorized, business_day, business_timezone, approved_at` — **전부 라이브 `payment_ledger`(`0014`)에 실존하는 컬럼** | `tenant_id, store_id, order_id, session_id, provider_type, payment_method, provider_tx_id, provider_approval_number, approved_amount, fee_amount, net_amount, ledger_status, approved_at, provider_response, reconciliation_status, business_day, business_timezone` — `payment_method`/`provider_tx_id`/`fee_amount`/`provider_response` 4개는 라이브에 **존재하지 않음**(`601026_Verification.md`에서 이미 삼중 재확인된 사실, 이번 문서에서 재차 확인) |
| `intent_id`(NOT NULL, FK) | 세팅함(`v_intent.id`에 해당하는 `p_intent_id`) | **세팅 안 함** — 컬럼 목록 자체에 없음 |
| `ledger_entry_type`(NOT NULL) | `'APPROVAL'`로 세팅 | **세팅 안 함** |
| `provider_payment_key` vs `provider_tx_id` | `provider_payment_key`(실제 컬럼명) 사용 | `provider_tx_id`(존재하지 않는 이름) 사용 — 의미상 같은 값(제공자 거래 식별자)을 다른 컬럼명으로 지칭 |
| `provider_response_id`(uuid, FK) vs `provider_response`(jsonb) | `provider_response_id`(실제 컬럼, `catchmenu_gateway.provider_raw_events`로의 FK, uuid) 사용 | `provider_response`(존재하지 않는 컬럼명, jsonb 원본 응답을 그대로 넣으려 시도) — **컬럼명 불일치일 뿐 아니라 타입 자체가 다름**(jsonb 원본 vs uuid FK) |
| `kds_release_authorized`(컬럼) | 명시적으로 `false` 세팅(자체 소스 주석: "특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용") | 컬럼 목록에 없음 — 세팅 안 함(`0157` Slice 1 이전에는 영구 `false` 방치, 이후엔 `release_kds_after_payment()`가 별도로 세팅) |

이 대조표는 배경이 언급한 "이미 삼중검증 자료에 있음"과 부합하며, 이번 문서에서 라이브 소스(`0027`/`0098`/`0014`) 직접 재대조로 독립 확인했다.

## §2.1 `0109`/`0130` 상세 조사 — 함수명/목적/호출자/`payment_ledger` INSERT 전문 (Revision 2 신규)

### §2.1.1 `0109` — `catchmenu_common.flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT` 분기

- **파일 헤더 목적**(`sql/migrations/0109_create_network_handoff_fallback_rpc.sql:1-9`, 원문): "Network handoff and offline fallback pipeline. 인터넷 장애 시 자동 전환 로직. 오프라인 큐 관리. Flutter 로컬 fallback 가이드. 장애 복구 후 자동 동기화." — 결제 정합화가 아니라 **네트워크 장애 시 오프라인 큐 처리**가 이 파일의 주목적이며, `payment_ledger` INSERT는 그 큐 처리 로직(`flush_offline_queue()`) 안의 여러 액션 타입 중 하나(`RECORD_MANUAL_PAYMENT`, 수기 결제 기록)로 부수적으로 존재한다.
- **함수 시그니처**(`0109:788-795`): `catchmenu_common.flush_offline_queue(p_tenant_id uuid, p_store_id uuid, p_device_id uuid default null, p_max_batch int default 50, p_locale text default 'ko')`.
- **`payment_ledger` INSERT 전문**(`0109:916-953`, `case v_item.action_type when 'RECORD_MANUAL_PAYMENT'` 분기 내부):
  ```sql
  insert into
    catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, provider_type,
    payment_method,
    provider_tx_id,
    approved_amount, fee_amount,
    net_amount, ledger_status,
    approved_at, business_day,
    business_timezone,
    provider_response
  ) values (
    p_tenant_id, p_store_id,
    (v_item.action_payload->>'order_id')::uuid,
    'MANUAL',
    v_item.action_payload->>'payment_method',
    'MANUAL-' || now()::text,
    (v_item.action_payload->>'amount')::int,
    0,
    (v_item.action_payload->>'amount')::int,
    'APPROVED',
    (v_item.action_payload->>'paid_at')::timestamptz,
    (v_item.action_payload->>'business_day')::date,
    'Asia/Seoul',
    jsonb_build_object('offline', true, 'manual', true, 'note', v_item.action_payload->>'note')
  )
  returning id into v_ledger_id;
  ```
  컬럼 목록: `tenant_id, store_id, order_id, provider_type, payment_method, provider_tx_id, approved_amount, fee_amount, net_amount, ledger_status, approved_at, business_day, business_timezone, provider_response` — `payment_method`/`provider_tx_id`/`fee_amount`/`provider_response` 4개 phantom 컬럼 전부 포함, `intent_id`/`ledger_entry_type` 둘 다 누락. `fee_amount`는 계산 없이 하드코딩 `0`.
- **실제 호출자 재확인**: `grep -rn "flush_offline_queue(" sql/migrations/*.sql`(자기 자신 제외) 결과 — 실제 호출 0건. `0130`의 문서 문자열(사람이 읽는 절차 안내 텍스트, `0130:1053` `'7. 복구 후 flush_offline_queue()'`) 안에 이름만 언급될 뿐, 실제 함수 호출은 어디에도 없다. **즉 이 INSERT는 현재 어떤 라이브 경로로도 도달하지 않는 죽은 코드다** — `0098`(카드/PG 3사가 실제로 호출)과는 위험도가 다르다.

### §2.1.2 `0130` — `catchmenu_payment.record_van_transaction()`

- **파일 헤더 목적**(`sql/migrations/0130_create_van_handler_extension.sql:1-9`, 원문): "VAN handler extension. NICE VAN 완성. KIS VAN 완성. 망취소 파이프라인. VAN 오류 자동 복구. VAN 정산 대사 연동." — VAN(부가통신사업자) 카드 단말 연동 확장.
- **함수 시그니처**(`0130:278-299`): `catchmenu_payment.record_van_transaction(p_tenant_id uuid, p_store_id uuid, p_van_provider text, p_van_terminal_id text, p_transaction_type text, p_approved_amount int, p_order_id uuid default null, p_card_number_hash text default null, p_card_company text default null, p_card_type text default 'CREDIT', p_installment_months int default 0, p_approval_number text default null, p_approval_at timestamptz default null, p_van_reference_id text default null, p_van_response_raw jsonb default null, p_transaction_status text default 'APPROVED', p_is_net_cancel boolean default false, p_locale text default 'ko')`.
- **`payment_ledger` INSERT 전문**(`0130:393-424`, `p_transaction_type = 'APPROVAL' and p_transaction_status = 'APPROVED' and p_order_id is not null` 조건 안):
  ```sql
  insert into
    catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, provider_type,
    payment_method, provider_tx_id,
    approved_amount, fee_amount,
    net_amount, tax_amount,
    ledger_status, approved_at,
    business_day, business_timezone,
    provider_response
  ) values (
    p_tenant_id, p_store_id,
    p_order_id,
    p_van_provider || '_VAN',
    case p_card_type when 'CREDIT' then 'CREDIT_CARD' else 'DEBIT_CARD' end,
    coalesce(p_approval_number, v_tx_id::text),
    p_approved_amount,
    0,
    p_approved_amount - v_tax_amount,
    v_tax_amount,
    'APPROVED',
    coalesce(p_approval_at, now()),
    v_business_day, 'Asia/Seoul',
    p_van_response_raw
  )
  returning id into v_ledger_id;
  ```
  컬럼 목록: `tenant_id, store_id, order_id, provider_type, payment_method, provider_tx_id, approved_amount, fee_amount, net_amount, tax_amount, ledger_status, approved_at, business_day, business_timezone, provider_response` — 기존 4개 phantom 컬럼에 **`tax_amount`가 5번째로 추가**(§2.1.3에서 라이브 부재 재확인), `intent_id`/`ledger_entry_type` 역시 누락.
- **실제 호출자 재확인**: `grep -rn "record_van_transaction(" sql/migrations/*.sql`(자기 자신 제외) 결과 **0건**. 실제 라이브 VAN 웹훅 핸들러(`0056_create_van_integration_rpc.sql`)는 `record_van_transaction()`이 아니라 `confirm_payment_from_provider()`(`0027`, DDL 정합 패턴)를 호출한다(`0056:363`) — **`record_van_transaction()`은 라이브 VAN 파이프라인과 완전히 분리된, 호출자 0건의 별도 함수**다. `0098`처럼 실제 카드/PG 3사가 호출하는 활성 결함이 아니라, `0109`의 `flush_offline_queue()`와 마찬가지로 잠재적(작성됐으나 배선되지 않은) 결함이다.

### §2.1.3 `0130`의 `tax_amount` — 라이브 부재 재확인 (신규 발견)

`information_schema.columns` 재조회 결과(`table_schema='catchmenu_payment' and table_name='payment_ledger' and column_name='tax_amount'`): **0 rows**. `tax_amount`는 라이브 `payment_ledger`에 존재하지 않는다 — 배경의 "신규 발견"을 독립 확인했다. (참고: `0130:85`의 `tax_amount int not null default 0`은 `payment_ledger`가 아니라 `0130` 자신이 만드는 별도 테이블 `catchmenu_payment.van_transactions`의 컬럼이다 — `van_transactions`에는 실존하지만 `payment_ledger`에는 없다는 것이 정확한 표현이다.)

## §3 `confirm_payment()`의 현재 실제 파라미터 목록 — `p_intent_id` 존재 여부 재확인

라이브 소스 재확인(`sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql:144-159`):

```sql
create or replace function
  catchmenu_payment.confirm_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_provider_type text,
  p_provider_approval_number text,
  p_provider_tx_id text,
  p_approved_amount int,
  p_payment_method text,
  p_provider_response jsonb default null,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
```

**확인 결과**: 13개 파라미터 전부 나열했으며, `p_intent_id`는 **존재하지 않는다**. 대신 이 함수는 `p_order_id`(주문 식별자)와 provider(PG/POS)가 보고한 원시 값들(`p_provider_tx_id`, `p_provider_approval_number`, `p_provider_response` 등)만 받는다 — `payment_intents`를 거치지 않고 "주문 + provider 원시 결과"만으로 결제를 확정하는 구조다. 배경의 "핵심 문제 3"(p_intent_id 부재로 payment_intents와 연결할 구조적 방법이 없음)을 정확히 재확인했다.

## §4 실제 호출자 3개(`0102`/`0103`/`0104`) 재확인 — 무엇을 넘기는가, `payment_intents` 참조 여부

전체 3개 파일에서 `payment_intents`/`p_intent_id` 문자열 재검색 결과 **0건** — 세 호출자 모두 `payment_intents` 테이블을 전혀 참조하지 않는다.

| 호출자 | 래퍼 함수 시그니처(재확인) | `confirm_payment()`에 넘기는 값 | 자체 사전 추적 테이블 |
|---|---|---|---|
| `0102`(OKPOS) | `catchmenu_integrations.confirm_okpos_payment(p_tenant_id, p_store_id, p_order_id, p_okpos_tx_data jsonb, p_locale, p_correlation_id)`(`0102:902-910`) | `p_provider_type:='OKPOS'`, `p_provider_tx_id:=`OKPOS 응답의 `okpos_tx_id`, `p_provider_response:=p_okpos_tx_data`(원시 jsonb 그대로) 등(`0102:958-973`) | `catchmenu_integrations.okpos_transactions`(자체 테이블, `payment_intents`와 무관, `intent_id` 컬럼 없음) |
| `0103`(Toss Payments) | 시그니처는 상위 함수(체크섬 검증 등 포함) 안에서 호출(`0103:695-`) | `p_provider_type:='TOSS_PAYMENTS'`, `p_provider_tx_id:=p_payment_key`, `p_order_id:=v_request.order_id`(`toss_payment_requests`에서 조회) | `catchmenu_integrations.toss_payment_requests` — **정정(§5.1, Revision 1의 이 칸은 부정확했다)**: `intent_id` 컬럼이 없다고 썼으나 재조사 결과 `payment_intent_id`(nullable, `payment_intents` FK) 컬럼이 실제로 존재한다(`0142_patch_toss_mvp_payment_intent_binding.sql`이 추가). 다만 `confirm_payment()`를 실제로 호출하는 레거시 코드(`confirm_toss_payment_legacy_604260`으로 개명됨)는 이 컬럼을 참조하지 않는다 — §5.1에서 상세. |
| `0104`(Toss POS) | `catchmenu_integrations.confirm_toss_pos_payment(p_tenant_id, p_store_id, p_order_id, p_toss_pos_tx_data jsonb, p_locale, p_correlation_id)`(`0104:825-833`) | `p_provider_type:='TOSS_POS'`, `p_provider_tx_id:=`Toss POS 응답의 `tposOrderId`/`tranId`, 원시 jsonb 파싱(`0104:857-870`) | 없음(`toss_payment_requests`류 자체 추적 테이블 없이 바로 `p_toss_pos_tx_data` 파싱) |

**세 호출자 모두 `confirm_payment()` 호출 시점에는 `payment_intents`를 참조하지 않는다** — 다만 Toss Payments 경로는 `0142` 패치 이후 `payment_intent_id`가 이미 별도로 resolve/검증되어 있으나 `confirm_payment()`로 전달되지 않고 있다는 것이 이번 재조사의 핵심 신규 발견이다(§5.1).

## §4.1 세 파일(`0098`/`0109`/`0130`)의 공통 파라미터와 차이 비교 (Revision 2 신규)

| 항목 | `confirm_payment()`(`0098`) | `flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT`(`0109`) | `record_van_transaction()`(`0130`) |
|---|---|---|---|
| 호출 형태 | 직접 RPC(파라미터로 값 받음) | 큐에 쌓인 `action_payload`(jsonb) 파싱 | 직접 RPC(파라미터로 값 받음) |
| `p_tenant_id`/`p_store_id` | 있음 | 있음(함수 자체 파라미터) | 있음 |
| `p_order_id` | 있음(필수) | `action_payload->>'order_id'`(jsonb에서 추출) | `p_order_id`(선택, `default null` — VAN 거래인데 주문 연결이 없을 수 있음을 시사) |
| `p_provider_type`(또는 상응) | 파라미터로 받음(`'OKPOS'`/`'TOSS_PAYMENTS'`/`'TOSS_POS'`) | 하드코딩 `'MANUAL'` | `p_van_provider \|\| '_VAN'`(예: `'NICE_VAN'`) |
| 결제수단 컬럼(phantom `payment_method`) | `p_payment_method` 파라미터 | `action_payload->>'payment_method'` | `p_card_type` 기반 파생(`CREDIT_CARD`/`DEBIT_CARD`) |
| provider 거래 식별자(phantom `provider_tx_id`) | `p_provider_tx_id` 파라미터 | 자체 생성 `'MANUAL-' \|\| now()::text`(외부 provider 자체가 없으므로 타임스탬프로 대체) | `coalesce(p_approval_number, v_tx_id::text)` |
| `fee_amount` | 계산됨(`v_fee_amount`, provider별 요율) | 하드코딩 `0` | 하드코딩 `0`(수수료는 `van_transactions.tax_amount`만 계산, `payment_ledger.fee_amount`에는 안 들어감) |
| `tax_amount` | 없음(파라미터도 컬럼도 없음) | 없음 | **있음** — `v_tax_amount`(부가세, 승인액의 1/11) 계산해 INSERT(§2.1.3, 라이브 부재) |
| `provider_response`(phantom) | `p_provider_response`(jsonb, 선택) | 자체 조립 `jsonb_build_object('offline', true, 'manual', true, 'note', ...)` | `p_van_response_raw`(jsonb, 선택) |
| `intent_id`/`ledger_entry_type` | 둘 다 누락 | 둘 다 누락 | 둘 다 누락 |
| 실제 호출자 | 3개(`0102`/`0103`/`0104`), 전부 라이브 | **0개**(고립) | **0개**(고립, `0056`은 대신 `0027`을 호출) |

**요약**: 세 파일 모두 같은 phantom-컬럼 패턴을 공유하지만(배경의 핵심 문제 2와 일치), 실제 위험도는 다르다 — `0098`은 활성(라이브 3개 경로가 매번 크래시), `0109`/`0130`은 잠재적(호출자 0건이라 현재는 실행되지 않음, 그러나 향후 배선되는 순간 동일하게 크래시). `tax_amount`는 `0130`에만 있는 5번째 phantom 컬럼이다.

## §5 `payment_intents`와의 관계 — `confirm_payment()`가 intent 개념 없이 설계된 이유(단서)

`payment_intents` 테이블(`0014`와 별도 정의, 라이브 재확인) 자체는 `intent_status`(`CREATED`/`PENDING`/`PROCESSING`/`CONFIRMED`/...), `payment_token`/`token_issued_at`/`token_expires_at` 같은 컬럼을 갖는다 — 이는 "결제 위젯/QR로 리다이렉트했다가 콜백으로 돌아오는" 흐름(토큰을 발급하고, 그 토큰이 유효한 동안 대기하다가 확인)에 맞는 설계다. `confirm_payment_from_provider()`(`0027`, Toss 웹훅 `0038`/VAN `0056`이 호출)가 정확히 이 패턴이다 — 먼저 `payment_intents` 행을 만들고(다른 워크패킷/파일에서), 웹훅이 나중에 도착하면 그 intent를 조회해 확정한다.

반면 `confirm_payment()`의 세 실제 호출자(§4)는 전부 **"결제가 이미 그 자리에서 물리적으로 완결된 뒤, 그 결과만 사후 보고받는"** 패턴이다:
- OKPOS/Toss POS: 매장 카운터의 POS 단말이 카드를 직접 처리한 뒤 결과(`p_okpos_tx_data`/`p_toss_pos_tx_data`)를 백엔드로 보고 — 미리 만들어둘 "의도(intent)"라는 개념 자체가 성립하지 않는다(단말이 이미 승인까지 끝낸 사후 보고이므로).
- Toss Payments: `toss_payment_requests`라는 **자체 provider-전용 사전 추적 테이블**을 이미 갖고 있다(`request_status`, `payment_key`, `idempotency_key` 등 — 개념적으로 `payment_intents`와 유사한 역할을 하지만 별도 테이블로 구현됨). 즉 이 흐름은 "intent가 없는" 것이 아니라 "범용 `payment_intents` 대신 provider 전용 테이블을 intent로 쓰는" 설계로 보인다.

**단서 정리(판단 아님, 사실 나열)**: `confirm_payment()`가 `payment_intents`를 참조하지 않는 것은 우연한 누락이라기보다, 세 실제 호출자 중 최소 2개(OKPOS/Toss POS)가 애초에 "사전 intent" 개념이 필요 없는 사후-보고형 결제이기 때문일 가능성이 있다 — 이 부분은 배경의 "설계 오류"라는 단정과 다소 결이 다르다. 그러나 이 설계 의도가 맞다 하더라도, **`payment_ledger.intent_id`가 라이브 스키마상 `NOT NULL` FK로 강제되어 있다는 사실 자체는 바뀌지 않는다** — `confirm_payment()`는 "intent가 필요 없는 결제 흐름"을 위해 설계됐을 수 있지만, 그 결과를 기록할 테이블(`payment_ledger`)은 모든 행에 대해 `intent_id`를 요구한다. 즉 설계 의도상의 정당성과 무관하게, 현재 라이브 스키마 제약과 `confirm_payment()`의 실제 INSERT는 근본적으로 양립 불가능하다 — 이 모순을 어떻게 풀지(예: 사후-보고형 결제를 위한 "synthetic intent" 자동 생성, 또는 `intent_id`를 nullable로 바꾸는 스키마 변경, 또는 `confirm_payment()`에 `p_intent_id`를 추가해 호출자들이 각자 임시 intent를 만들어 넘기게 하는 것)는 Logic 단계에서 옵션으로 다룰 사안이다.

## §5.1 신규 발견 — `0142`가 이미 Toss Payments 경로의 intent-binding 절반을 풀어놓았다 (Revision 2 핵심 발견)

레거시 격리 문서 `604253_Logic_...md`(2026-07-01, `990000_legacy_quarantine`, §6.1)는 "`604260 Scope D 00A Toss MVP PaymentIntent Binding Precondition`이 `toss_payment_requests.payment_intent_id`를 통해 강한 바인딩을 만든다"고 서술했다 — 이번 재조사에서 `604260`이 실제로 구현됐는지 라이브로 재확인한 결과, **구현되어 있었다**(단, 부분적으로만 배선됨).

- `catchmenu_integrations.toss_payment_requests`의 라이브 전체 컬럼(32개) 재확인 결과, `payment_intent_id`(nullable uuid, `fk_toss_payment_requests_payment_intent` → `catchmenu_payment.payment_intents(id)`) 컬럼이 실제로 존재한다. (**이전 조사에서 이 컬럼을 놓쳤던 이유**: 컬럼이 32개 중 마지막 위치에 있었는데 `\d` 출력을 앞부분만 확인해 누락했다 — 이번 문서에서 전체 컬럼 목록 재조회로 직접 정정한다.)
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`이 이 컬럼과 FK를 추가하고, `before insert on toss_payment_requests` 트리거 `bind_toss_payment_intent()`(`0142:29-203`)를 만들어 **모든 신규 Toss 결제 요청 행에 대해 `payment_intent_id`를 자동으로 resolve/검증**한다(기존 `payment_intents` 재사용 또는 `create_payment_intent()` 신규 생성, no-intent/multiple-intent 케이스 모두 명시적으로 처리 — `604253` §6.2가 우려했던 "silently picking the most recent" 문제를 실제로 회피).
- `0142`는 추가로 `catchmenu_integrations.confirm_toss_payment(...)`(`0142:281-365`)라는 **새 wrapper**를 만들어, 원래의 `confirm_toss_payment`(`0103` 정의)를 `confirm_toss_payment_legacy_604260`으로 개명(`0142:216-218`)하고 그 자리를 대신 차지하게 했다. 이 새 wrapper는:
  1. `toss_payment_requests`에서 `payment_intent_id`를 조회.
  2. 그 intent가 여전히 유효한지(`intent_status not in ('FAILED','CANCELLED','EXPIRED')`, 금액/provider 일치) 검증.
  3. 검증 통과 시에만 `confirm_toss_payment_legacy_604260(...)`(옛 `0103` 로직 — 내부에서 `catchmenu_payment.confirm_payment()`를 호출)을 실행.
  4. 응답 JSON에 `payment_intent_id`를 노출.
- **그러나 결정적으로**: `confirm_toss_payment_legacy_604260`(옛 `0103` 바디, `0142`가 이름만 바꿨을 뿐 본문은 무변경)이 내부적으로 호출하는 `catchmenu_payment.confirm_payment()`에는 **여전히 `payment_intent_id`가 전달되지 않는다** — `0142` 자신의 코멘트가 이를 스스로 인정한다(`0142:404-408` 원문): `"604260 wrapper. Validates and exposes the bound payment_intent_id before using the preserved Toss confirmation path. **It does not patch confirm_payment.**"`

**의미(사실 정리, 판단 아님)**: Toss Payments 경로는 세 호출자 중 유일하게, `confirm_payment()` 호출 시점에 이미 검증된 `payment_intent_id` 값이 손닿는 곳(같은 트랜잭션의 `v_request.payment_intent_id`)에 준비되어 있다. `604253`(2026-07-01) 작성 시점에는 이 값 자체가 존재하지 않아 "MVP gap"으로 분류됐으나, 지금은 값은 있고 단지 `confirm_payment()`로 전달만 안 되고 있는 상태다 — Logic 단계에서 "옵션 A: `p_intent_id` 파라미터 추가" 채택 시, **Toss Payments(`0103`/`0142`) 쪽은 이미 갖고 있는 값을 넘기기만 하면 되는 가장 쉬운 케이스**가 된다(반면 OKPOS/Toss POS는 여전히 intent 자체가 없어 이 옵션이 어렵다 — §5의 기존 분석대로).

## §6 정리 — 세 호출자 파일도 함께 고쳐야 하는가, `confirm_payment()` 내부만 고치면 되는가

**판단 근거(사실 기반, 최종 결정은 Logic.md에서)**:

- Phantom 컬럼 4개(`payment_method`/`provider_tx_id`/`fee_amount`/`provider_response`) 수정과 `ledger_entry_type` NOT NULL 채우기는 `confirm_payment()`(`0098`) **내부 INSERT 문 재작성만으로 해결 가능** — 세 호출자는 이 값들을 이미 `confirm_payment()`의 기존 파라미터(`p_payment_method`, `p_provider_tx_id`, `p_provider_response`)로 넘기고 있으므로, 함수 시그니처를 바꿀 필요 없이 내부에서 올바른 컬럼명(`provider_payment_key`, `provider_response_id` 또는 대안)에 매핑하면 된다.
- 다만 `provider_response`(jsonb) → `provider_response_id`(uuid FK, `catchmenu_gateway.provider_raw_events` 참조)는 **단순 컬럼명 치환이 아니다** — 원본 jsonb 응답을 그대로 저장할 곳이 없어지므로, `confirm_payment()` 내부에서 `provider_raw_events`에 먼저 INSERT하고 그 id를 `provider_response_id`로 쓰는 추가 로직이 필요하다(`0027`이 이미 이 패턴을 쓰는지는 Logic 단계에서 `0027`의 `provider_response_id` 세팅 방식을 재확인해야 함 — 이번 문서는 컬럼 존재만 확인했다).
- `intent_id`(NOT NULL FK) 문제는 **`confirm_payment()` 내부만으로 해결 가능한지 여부가 옵션에 따라 갈린다**:
  - "synthetic intent를 `confirm_payment()` 내부에서 자동 생성" 옵션을 택하면 → 호출자 3개는 무변경.
  - "`confirm_payment()`에 `p_intent_id` 파라미터를 추가"하는 옵션을 택하면 → **세 호출자 전부 수정 필요**(`0102`/`0103`/`0104` 각자 intent를 만들거나 조회해서 넘겨야 함) — 특히 OKPOS/Toss POS는 애초에 intent 개념이 없는 흐름이므로 이 옵션은 그 두 경로에 부자연스러운 개념을 강제로 도입하는 셈이다.
- 따라서 이번 워크패킷의 핵심 갈림길은 **"intent_id 문제를 `confirm_payment()` 내부에서 흡수할 것인가, 호출자에게 전가할 것인가"**이며, 이는 Logic 단계의 옵션 비교 대상이다.

## §7 Open Questions

(a) `provider_response_id`(uuid FK)를 `confirm_payment()` 내부에서 채우려면 `catchmenu_gateway.provider_raw_events`에 먼저 행을 만들어야 하는지, 아니면 이 FK를 nullable로 두고 생략 가능한지 — `0014`/`provider_raw_events` 스키마 재확인 필요, 이번 문서는 다루지 않음.
(b) `0103`(Toss Payments)의 `toss_payment_requests`를 향후 `payment_intents`와 통합할 가치가 있는지(현재는 완전히 별개 테이블) — 범위 밖, 참고 기록.
(c) `confirm_payment()`가 2026-06-21 작성 당시 정말 `payment_ledger`(`0014`, 2026-06-20 정의) 스키마를 한 번도 참조하지 않고 작성됐는지, 아니면 그 사이 `payment_ledger`가 별도로 변경된 이력이 있는지 — `git log --follow`로 `0014`/`0098` 커밋 이력 재확인이 필요하나 이번 문서는 다루지 않음(배경의 "최초 설계 오류" 단정에 대한 완전한 검증은 아님).
(d) `mark_payment_uncertain()`(`600540` 워크패킷에서 이미 정리됨)이 이 워크패킷과 유사한 컬럼 drift를 겪었는지 — 참고용 패턴 비교 가치, 범위 밖.
(e) **신규(Revision 2)** — `604250`~`604256`(legacy quarantine)이 이 워크패킷과 사실상 동일한 문제를 2026-07-01에 이미 설계까지 마쳤다가(옵션 A/B/C, intent-binding 후보 A-F 전부 문서화) 왜 실행되지 않고 격리(`990000_legacy_quarantine`)됐는지 — 이 문서는 격리 사유 자체를 조사하지 않았다. Logic 단계에서 이 legacy 자료를 얼마나 재사용할지 판단하기 전에, 격리 사유(거버넌스 체계 교체 때문인지, 다른 이유인지)를 최소한 한 줄이라도 확인할 가치가 있다.
(f) **신규(Revision 2)** — `0109`/`0130`은 둘 다 호출자 0건이지만, `flush_offline_queue()`(`0109`) 자체는 다른 액션 타입(`CREATE_ORDER`/`UPDATE_KDS_STATUS`/`STAMP_VISIT` 등)까지 포함하는 범용 오프라인 동기화 함수다 — `RECORD_MANUAL_PAYMENT` 분기만 고치는 것이 이 함수 전체의 다른 분기들에 영향을 주지 않는지 Logic 단계에서 재확인 필요.
(g) **신규(Revision 2)** — `0142`의 `bind_toss_payment_intent()` 트리거·wrapper 패턴(intent를 별도 단계에서 resolve/검증 후 결제 확인 함수에 전달)이 OKPOS/Toss POS에도 이식 가능한 일반 패턴인지, 아니면 Toss Payments의 사전 요청(`toss_payment_requests`) 구조에 특화된 것이라 이식 불가능한지 — Logic 단계 옵션 비교에서 다룰 가치가 있으나 이 문서는 판단하지 않는다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601027_Audit.md`(`601020_authorize_kds_release_overload_and_redesign`) §URGENT Open Item — 이 워크패킷의 직접 발단.
- `601026_Verification.md` §5 — phantom 컬럼 4개 삼중검증 원본.
- `604253_Logic_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md`(`990000_legacy_quarantine`) — 옵션 A/B/C, intent-binding 후보 A-F를 이미 설계한 선행 분석. 이번 워크패킷의 Logic.md가 직접 재사용/갱신하는 근거 문서.

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`(L144-458) 전체.
- `sql/migrations/0027_create_payment_intent_rpc.sql` — `confirm_payment_from_provider()`, 참고 기준(L267-331 특히).
- `sql/migrations/0014_create_payment_ledger.sql` — `payment_ledger` 실제 스키마, `intent_id`/`ledger_entry_type` NOT NULL 제약.
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`/`0103_create_toss_payments_pipeline_rpc.sql`/`0104_create_toss_pos_pipeline_rpc.sql` — 실제 호출자 3개.
- `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` — `flush_offline_queue()`(§2.1.1).
- `sql/migrations/0130_create_van_handler_extension.sql` — `record_van_transaction()`(§2.1.2/§2.1.3).
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — Toss `payment_intent_id` 바인딩 트리거/wrapper 전체(§5.1).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.
- `601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md`/`601026_Verification.md`/`601027_Audit.md` — 발단이 된 선행 워크패킷.
- `docs/990000_legacy_quarantine/604000_workpackets/604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/` — 604250-604256 전체 세트, 선행 유사 분석.

### Excluded Rule Families

- `authorize_kds_release_overload_and_redesign`(`601020`)의 Slice 1/2/3 자체 — 이미 완료·ACCEPT됨, 재론하지 않음.
- `confirm_payment_from_provider()`(`0027`)의 자체 수정 — 이 워크패킷은 `0027`을 참고 기준으로만 쓰고 수정하지 않는다.
- `toss_payment_requests`/`payment_intents` 통합 여부(§7 (b)) — 범위 밖.
- `604250`의 격리 사유 자체 조사(§7 (e)) — 이 문서는 다루지 않음.
- `flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT` 외 다른 액션 타입 — 이 워크패킷은 결제 관련 분기만 다룬다.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정(Revision 2).** §0(번호: `600550`)/§2(0027 vs 0098 대조)/§3(`p_intent_id` 부재 확인)/§4(호출자 3개 `payment_intents` 0건 참조 확인)는 Revision 1에서 라이브 코드 직접 재대조로 독립 확정됐다. **Revision 2 신규**: §2.1에서 `0109`/`0130` 각각의 정확한 함수명·목적·`payment_ledger` INSERT 전문·실제 호출자(둘 다 0건, `0098`과 위험도가 다름)를 확인했고, §2.1.3에서 `tax_amount`(`0130`만의 5번째 phantom 컬럼)의 라이브 부재를 재확인했다. §4.1에서 세 파일의 파라미터 비교표를 작성했다. **§5.1이 이번 재작업의 가장 중요한 신규 발견이다** — Toss Payments 경로는 `0142` 패치로 이미 `payment_intent_id`가 resolve/검증되어 있으나 `confirm_payment()`로 전달되지 않고 있을 뿐이라는 사실을 확인했고, 이 과정에서 Revision 1 §4의 "toss_payment_requests에 intent_id 컬럼이 없다"는 서술이 부정확했음을 직접 정정했다(전체 컬럼 재조회 결과 `payment_intent_id`가 32개 컬럼 중 마지막에 존재). 이 발견은 Logic 단계의 옵션 비교(특히 Toss Payments 경로의 난이도)에 직접 영향을 준다. `600552_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.
