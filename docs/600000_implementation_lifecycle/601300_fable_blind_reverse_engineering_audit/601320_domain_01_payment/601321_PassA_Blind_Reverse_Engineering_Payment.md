# Pass A: Blind Reverse-Engineering — 결제(600500)

**Date:** 2026-07-18
**Reviewer:** Claude Fable 5 (blind pass — no design docs shown)
**Input provided:** 02_payment_600500_input_package.md (87개 RPC 정의 포함, 15개 migration 원본 기반), 02_payment_600500_migrations_concat.sql

## 1. Reconstructed Domain Purpose

이 도메인은 POS 주문에 대한 **결제 확정·정산·대사(reconciliation) 금융 계층**이다. 세 개 스키마로 나뉜다:

- `catchmenu_payment` — 내부 진실원장(source of truth). `payment_intents`(결제 의도) → `payment_ledger`(승인/취소/환불 원장) → `payment_events`/`reconciliation_*`(정산 대사). 이 스키마의 RPC가 결제 상태머신의 중심.
- `catchmenu_gateway` — 외부 제공자 원시 이벤트 저장소(`provider_raw_events`, `gateway_sessions`). 모든 제공자 응답의 raw 기록점.
- `catchmenu_integrations` — 개별 제공자 어댑터. Toss Payments(PG), VAN(NICE/KIS/KICC), OKPOS·Toss POS(외부 POS 연동), 배달 플랫폼(배민/요기요/쿠팡이츠), 현금영수증(NTS) 연동을 각각 담당.

재구성한 핵심 기능:
- **결제 확정 파이프라인**: intent 생성 → 제공자 승인 수신 → `payment_ledger`에 APPROVAL 기록 → 주문/세션 상태 전이 → **KDS "Late Binding" 해제**(결제 확인 시에만 조리 시작 허용).
- **KDS-결제 커플링(도메인의 특징적 설계)**: 주석에 "특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용", "특허2: KDS Late Binding 해제"가 반복 등장. `kds_tickets`가 결제 전 `HOLD`, 결제 확인 후 `COMMITTED`로 전이하며, 이 게이트가 결제 도메인 안에 구현돼 있다.
- **3계층 대사**: `run_layer1/2/3_reconciliation`(내부 원장 ↔ PG/VAN 정산파일 대조), `reconciliation_cases`(불일치 케이스), `create_reconciliation_case`/`resolve_reconciliation_case`.
- **취소/환불/망취소**: `cancel_payment`, `partial_cancel_payment`, `request_refund`/`confirm_refund`, `request_van_net_cancel`(VAN 망취소).
- **불확실 결제 처리**: `mark_payment_uncertain`(PAYMENT_UNCERTAIN → KDS 절대 금지 + human 승인 예외 생성).
- **감사·증빙**: 모든 금융 액션이 `catchmenu_audit.append_audit_record(category='FINANCIAL')` + `catchmenu_ledger.events`로 이중 기록. `generate_audit_packet`(증빙 패킷).

## 2. Reconstructed State Machines

### 2.1 payment_intents.intent_status
- 허용값(`chk_intent_status`): CREATED/PENDING/PROCESSING/CONFIRMED/FAILED/CANCELLED/EXPIRED.
- `resolve_or_create_payment_intent`은 신규 생성 시 곧바로 `CONFIRMED`로 INSERT(중간상태 생략). `confirm_payment_from_provider`는 기존 intent를 (미상)→`CONFIRMED`. `mark_payment_uncertain`은 →`PROCESSING`.
- `intent_origin`(`chk_intent_origin`): PREAUTHORIZED/POS_SYNTHESIZED/MANUAL_ENTRY/VAN_SYNTHESIZED/IMPORTED — 결제 의도의 출처를 구분(사전승인 vs POS가 사후 합성 등).

### 2.2 payment_ledger.ledger_status (금융 진실원장)
- 허용값(`chk_ledger_status`): APPROVED/CANCELLED/REFUNDED/PARTIAL_CANCELLED/PARTIAL_REFUNDED/UNCERTAIN/DISPUTED/UNDER_REVIEW.
- `ledger_entry_type`(`chk_ledger_entry_type`): APPROVAL/PARTIAL_CANCEL/FULL_CANCEL/REFUND/PARTIAL_REFUND/ADJUSTMENT/MANUAL_CORRECTION.
- 금액 무결성 제약(`chk_ledger_amounts`): `net_amount = approved - cancelled - refunded`, 모두 부호 강제.
- **주의**: `confirm_refund`/`request_refund` 코드는 `REFUND_PENDING`, `REFUND_FAILED` 상태값을 사용하는데 이는 `chk_ledger_status` 허용집합에 **없다**(§4-3).

### 2.3 reconciliation_status (payment_ledger 내)
- PENDING/MATCHED/MISMATCH/MANUAL_REVIEW/RESOLVED. 정상 승인은 `PENDING`으로 시작, layer 대사가 MATCHED/MISMATCH 판정. "주문 취소 후 결제 승인" 이상 케이스는 즉시 `MANUAL_REVIEW`.

### 2.4 KDS 방출 커플링 (payment ↔ kds_tickets) — 도메인 핵심
- `kds_tickets.kds_status`: `HOLD` → `COMMITTED`(조리 시작 승인). payment_ledger에 `kds_release_authorized`(boolean, 기본 false) + `kds_release_authorized_at`/`_by`.
- **두 개의 서로 다른 방출 경로가 공존**(§4-1):
  - 경로 A — `confirm_payment` → `release_kds_after_payment()`: `check_kds_capacity()`를 호출은 하지만 그 결과를 **게이트로 쓰지 않고**, `kds_status='HOLD'`인 티켓을 무조건 `COMMITTED`로 UPDATE. 용량 초과 여부와 무관하게 방출.
  - 경로 B — `confirm_payment_from_provider` → `request_kds_release_after_payment()` → `catchmenu_kds.bulk_commit_kds_tickets()`: 원장에 `kds_release_authorized=true` 세팅 후 실제 **용량 게이트**(committed/pending/skipped 카운트, capacity hold)에 위임. 결과코드 `PAYMENT_CONFIRMED_KDS_COMMITTED` / `_CAPACITY_HOLD` / `_PARTIAL_CAPACITY_HOLD` / `_NO_TICKETS_TO_PROCESS` / `_RELEASE_BLOCKED`로 분기.

### 2.5 주문/세션 상태 전이 (결제가 유발)
- `confirm_payment`: 주문 `PENDING` → (`order_type='TABLE'`이면 `COOKING`, 아니면 `CONFIRMED`). 동시성 가드로 `where ... and order_status='PENDING'` 후 `row_count=0`이면 `order_status_changed_concurrently` 반환.
- `confirm_payment_from_provider`: 세션 → `PAYMENT_PENDING`.
- `mark_payment_uncertain`: 세션 → `PAYMENT_UNCERTAIN`, 모든 미완료 kds_tickets를 `HOLD`(`hold_reason='PAYMENT_UNCERTAIN'`)로 강제, `requires_human_approval=true` 예외 생성.

### 2.6 pg_settlement_files.import_status
- IMPORTED/PROCESSING/RECONCILED/ERROR. 정산파일 업로드 후 layer3 대사에 연결(`layer3_result_id`).

## 3. Reconstructed Authorization/Boundary Model

### 3.1 proacl 분포 (87개 RPC)
| 패턴 | 수 | 의미 |
|---|---:|---|
| `postgres=X,authenticated=X` | 76 | `authenticated` 롤 실행 (PUBLIC 회수) |
| `=X,postgres=X,authenticated=X` | 8 | **PUBLIC(anon 포함) 실행 가능** — `generate_audit_packet`, `get_reconciliation_report`(구버전), `get_van_dashboard`, `reconcile_van_settlement`, `record_van_transaction`, `request_van_net_cancel`, `run_layer1/2_reconciliation`(구버전) |
| `postgres=X` (owner-only) | 2 | `confirm_toss_payment_legacy_604260`, `initiate_toss_payment_legacy_604260` — **client 롤 전부 차단**(사실상 비활성) |
| `NULL` | 1 | `bind_toss_payment_intent`(무인자 stub) |

### 3.2 실제 경계
- **모든 87개 함수가 SECURITY DEFINER.** 따라서 정의자(postgres) 권한으로 실행되어 테이블 RLS를 우회한다. 클라이언트의 실질 경계는 "이 함수를 호출할 수 있는가"(proacl) 하나로 수렴.
- **함수 내부에 역할 검증이 사실상 없다.** `is_manager_or_above()`/`is_service_role()` 호출이 이 도메인 87개 함수 어디에도 없다. `p_actor_type`/`p_actor_id`는 파라미터로 받아 감사 기록에만 쓰이고, 권한 게이트로 쓰이지 않는다 → **결제 확정·환불·망취소의 실행 주체가 자기신고**(§4-11).
- **테이블 직접 접근**: 0021/0022(공통 기반) 기준 `payment_ledger`는 authenticated에게 SELECT만(store 격리), 쓰기는 DEFINER RPC 경유. `catchmenu_gateway`는 `is_service_role()` 전용 + authenticated usage 회수. `toss_webhooks`도 service_role 전용. (단, RLS 정책 최신 텍스트는 이 자료로 확인 불가 — §5.)
- **웹훅 진입**: `confirm_payment_webhook`/`process_toss_webhook`이 authenticated로 노출. 서명 검증(`verify_toss_signature`)은 구조검사만 수행(§4-7).

## 4. Anomalies / Suspicious Patterns

**4-1. KDS 방출 경로 이원화(가장 두드러짐).**
`confirm_payment`(→`release_kds_after_payment`)는 KDS 용량을 확인만 하고 결과를 무시한 채 `HOLD→COMMITTED` 강제 방출한다(`release_kds_after_payment` 내 `v_capacity_check` 계산 후 게이트 미사용). 반면 `confirm_payment_from_provider`(→`request_kds_release_after_payment`→`bulk_commit_kds_tickets`)는 실제 용량 게이트를 거친다. 즉 **어느 결제 진입점으로 들어오느냐에 따라 "결제 승인 ≠ 조리 자동 시작"이라는 주석의 원칙이 지켜지기도 하고 무시되기도 한다.** 특히 dine-in(`order_type='TABLE'`)은 `confirm_payment`에서 주문을 곧장 `COOKING`으로 바꾸면서 용량 게이트를 건너뛴다.

**4-2. `confirm_payment`의 금액 불일치 미차단.**
`abs(p_approved_amount - final_amount) > 10`이면 `log_diagnostic(ERROR)`만 남기고 **그대로 진행**해 원장을 APPROVED로 기록한다(반환/중단 없음). 반면 `confirm_payment_from_provider`는 `requested_amount <> p_approved_amount`이면 `amount_mismatch`로 즉시 거부. 두 진입점의 금액 검증 강도가 정반대다(하나는 ±10 관용+무시, 하나는 정확일치 강제).

**4-3. 코드가 스키마에 없는 상태값·컬럼을 참조(런타임 실패 위험).**
`confirm_refund`/`request_refund`가 `ledger_status`에 `REFUND_PENDING`/`REFUND_FAILED`를 쓰는데 `chk_ledger_status`에 없다. 또 `confirm_refund`는 `payment_ledger`의 `provider_tx_id`, `provider_response`, `refunded_at`, `original_ledger_id`, `refund_reason` 컬럼을 읽고/쓰는데 §B 스키마 덤프의 `payment_ledger`에는 이들 컬럼이 없다(스키마엔 `provider_payment_key`가 있고 `provider_tx_id`는 없음). 이 자료 범위에선 해당 함수들이 현재 스키마 대상 실행 시 실패할 것으로 보인다 — 이 15개 패키지 밖의 후속 마이그레이션이 컬럼/제약을 추가했거나, 드리프트/사장(死藏) 코드일 가능성(§5).

**4-4. 수수료 계산의 제공자명 불일치 + 미사용.**
`confirm_payment`의 수수료 case-when이 `'NICE_VAN'`/`'KIS_VAN'`을 검사하는데, `chk_intent_provider` 및 나머지 코드의 표준값은 `'VAN_NICE'`/`'VAN_KIS'`다. 따라서 VAN 결제는 항상 else(1.5%)로 떨어진다. 게다가 `v_net_amount := p_approved_amount`로 **수수료가 net에서 차감되지 않으며**, 계산된 `v_fee_amount`는 응답 표시 외 어디에도 저장/사용되지 않는다.

**4-5. "취소된 주문에 결제 승인" 케이스의 이중 신호.**
`confirm_payment`은 주문이 이미 CANCELLED/REFUNDED이면 APPROVED 원장을 `reconciliation_status='MANUAL_REVIEW'`로 실제 기록하고 event까지 남긴 뒤, 호출자에게는 `build_error_response('payment_already_confirmed')`로 **실패를 반환**한다. 실제 금융 승인이 기록됐는데 API 응답은 에러 — 호출자가 이를 "실패"로 오해하면 이중 처리/미인지 위험.

**4-6. 타임존 처리 불일치.**
`confirm_payment`/`resolve_or_create_payment_intent` 등은 `stores.timezone`을 조회해 business_day를 계산하지만, `release_kds_after_payment`는 `'Asia/Seoul'`을 하드코딩한다. 동일 트랜잭션 내 business_day 산정 기준이 함수마다 다를 수 있다.

**4-7. 웹훅 서명 "검증"이 실제 검증이 아님.**
`verify_toss_signature`는 HMAC-SHA256을 계산하지 않고 헤더가 `t=%,v1=%` 형식이고 서명부 길이 ≥32인지만 확인한다(주석 스스로 "actual HMAC in app layer" 인정). 더구나 `confirm_payment_webhook`은 서명이 있으면 `security_audit_log`에 "webhook_received"만 기록할 뿐 `verify_toss_signature`를 **호출조차 하지 않는다**. DB 계층에서 결제 웹훅 위·변조 방어가 사실상 없다(엣지/앱 계층 의존).

**4-8. 오버로드(동명 2개 함수) 다수 — 진행 중 리팩터 흔적.**
`process_toss_webhook`, `reject_delivery_order`, `sync_delivery_order_status`, `update_delivery_status`, `run_layer2_reconciliation`, `get_reconciliation_report`가 각각 시그니처가 다른 **두 벌**로 존재한다. 구·신 구현이 병존(마이그레이션 미완)하는 것으로 보이며, 호출측이 어느 쪽을 부르는지에 따라 동작이 갈릴 수 있다. 특히 `run_layer2_reconciliation`/`get_reconciliation_report`는 구버전이 PUBLIC(`=X`), 신버전이 authenticated로 **권한 경계까지 다르다**.

**4-9. `WEBHOOK` actor_type이 감사에서 소실.**
`confirm_payment`의 actor_type 정규화 화이트리스트는 SYSTEM/AGENT/STAFF/.../PROVIDER/SCHEDULER와 `PG_WEBHOOK`류→PROVIDER 매핑만 있다. 그런데 `confirm_payment_webhook`은 `p_actor_type := 'WEBHOOK'`을 넘기고, `'WEBHOOK'`은 어느 목록에도 없어 최종 `'SYSTEM'`으로 기록된다. 웹훅발 결제가 감사원장에 `SYSTEM` 주체로 남아 출처 추적성이 약화된다.

**4-10. 비활성/스텁 함수 잔존.**
`*_legacy_604260` 2개는 proacl이 owner-only(`postgres=X`)라 authenticated/anon이 호출 불가 — 명시적으로 client에서 차단된 구버전. `bind_toss_payment_intent`는 무인자·proacl NULL·SECURITY DEFINER인 껍데기로 보인다(용도 불명, §5).

**4-11. 금융 실행의 자기신고 주체.**
`confirm_payment`/`cancel_payment`/`refund_payment`/`request_van_net_cancel` 등 고위험 금융 RPC가 `p_actor_type`/`p_actor_id`를 검증 없이 신뢰한다. 함수 내부에 "이 호출자가 그 주체이며 그 권한이 있는가"를 확인하는 로직이 없다. authenticated면 누구나 임의 actor로 결제/환불을 확정할 수 있는 구조(값은 감사 라벨로만 소비).

**4-12. 라이브 데이터는 전부 테스트/레이스 하네스 산출물.**
유일하게 0이 아닌 `provider_raw_events`(14행)의 표본은 `provider_event_id`가 `tx-pc1-race`, `PAYCON001-TX-SAME-001`, correlation `corr-pc3-race` 등 명백한 동시성 테스트 흔적이다. `payment_intents`/`payment_ledger`/`payment_events`/모든 reconciliation·van·toss 테이블은 0행. **실제 프로덕션 결제가 한 건도 완결된 적 없다** — 이 도메인의 모든 상태전이는 "이론상 설계"이며 "작동 증거"가 아니다(§5). `pos_provider_registry`(10행)·`delivery_platform_rules`(3행)는 시드 설정.

## 5. Confidence Notes

- **4-3(스키마/코드 드리프트)**: `provider_tx_id`/`refunded_at`/`original_ledger_id` 등 없는 컬럼과 `REFUND_PENDING` 상태는, 이 패키지에 포함된 15개 파일 밖의 후속 마이그레이션(예: refund 확장)이 실제로는 추가했을 가능성이 있다. 따라서 "런타임 실패한다"가 아니라 "제공된 자료의 스키마 기준으론 정합하지 않는다"로 읽어야 한다. 라이브 `payment_ledger`가 0행이라 실제 실행으로 확인된 바 없다.
- **4-1(방출 이원화)**: 두 경로가 모두 존재함은 코드로 확정. 그러나 어느 쪽이 "현행 정본"이고 어느 쪽이 폐기 예정인지는 블라인드로 판단 불가 — 최근 리팩터 방향(경로 B 신설)인지, 채널별 의도적 분기인지 알 수 없다.
- **RLS 정책 텍스트**: `pg_policy.cmd` 추출 오류로 이 패키지엔 없다. §3의 테이블 경계는 공통기반(0021/0022) 원문에 근거하나, 결제 도메인 마이그레이션이 정책을 덮어썼을 가능성은 배제 불가.
- **민감 컬럼**(card_number_hash, customer_id_hash, webhook_secret 등) redacted — 존재/사용 방식만 판단. HMAC 미검증(4-7)은 함수 본문으로 확정된 사실이나, 엣지 함수(앱 계층) 검증 여부는 이 자료 밖.
- **4-4 수수료 미사용**: 표시 외 미사용으로 보이나, 정산 대사(layer2/3)나 이 패키지 밖 함수가 별도로 fee를 재계산·소비할 여지는 확인 불가.
- **`bind_toss_payment_intent`**: 무인자 stub의 실제 정의 본문을 §D.3에서 더 확인해야 용도를 알 수 있으나, 시그니처만으론 placeholder로 추정.
- **오버로드 함수(4-8)**: 어느 시그니처가 실제 호출되는지는 호출측(엣지/앱) 코드가 이 패키지에 없어 확정 불가.
