# 601438 — Consolidated Owner Decision Registry: Domain 01 Customer Handoff

- Domain: `domain_01_customer_handoff`
- Source reports: `601427`, `601429`, `601431`, `601434`, `601435`, `601437`
- Scope: 6개 슬라이스의 Owner Decision Queue 및 Regular Workpacket Recommendation Queue 통합·중복 제거
- Status: Owner decision input
- Rule: 새 Finding이나 새 처분을 만들지 않고 기존 6개 검사 결과만 재구성

## A. 교차 슬라이스 반복 패턴

### A1. Phantom 컬럼 전사 감사

**통합 결정 1건:** 슬라이스별로 반복 제안된 phantom-column 검사를 하나의 repo-wide audit으로 승인할지 결정한다.

**관련 Finding:** `CH-F01`, `WAIT-F01`, `WAIT-F05`, `PAY-F01`, `PAY-F06`, `KDS-F01`, `KDS-F06`, `APP-F02`.

#### 보고서에 기록된 영향 테이블·컬럼

| 테이블 / 계약 | 보고서에 기록된 phantom·drift | 실제 컬럼·허용값 또는 상태 | 상태 |
|---|---|---|---|
| `catchmenu_pos.order_items` | `unit_price`, `subtotal`, `item_options`, `display_order`, `is_kds_required`; `menu_code_snapshot` 누락 | `unit_price_snapshot`, `item_amount`, `selected_options`, `is_kds_required_snapshot`; `display_order` 대체 없음; `menu_code_snapshot NOT NULL` | Customer-app/Takeout/Toss-POS 경로에 잔존 |
| `catchmenu_pos.order_sessions` | `pre_order_amount`; 0116의 pre-0148 `customer_id` 사용 | 사전주문 판정은 `pre_order_created_at`; `customer_id`는 0148에서 추가되고 0149에서 waiting linkage 구현 | `pre_order_while_waiting`과 customer-app laggard에 기록 |
| `catchmenu_pos.orders` | `order_source`, `paid_at`, `request_memo`; `order_type='TABLE'` | `memo`; `chk_order_type`은 `DINE_IN/TAKEOUT/DELIVERY/KIOSK/STAFF_ORDER` | `order_source`/`TABLE`은 WAIT-F01; `paid_at` repo-wide 미감사 |
| `catchmenu_payment.payment_ledger` | `payment_method`, `provider_tx_id`, `fee_amount`, `provider_response`, `tax_amount`, `refunded_at`, `original_ledger_id`, `refund_reason`, `is_partial_refund`, `paid_at`, `updated_at` | purpose-specific provider/amount/timestamp 컬럼; `provider_response_id` 계열 | confirm 경로 일부는 0158로 해결; refund 경로는 OPEN |
| `catchmenu_store.did_devices` | `show_waiting_count`, `show_cms_content`, `supported_locales`, `default_locale` | live 23-column schema에 없음 | `bootstrap_did_app` Verification에서 실제 `42703` 재현 |
| `point_ledger` | `point_type`, `point_amount` | `transaction_type`, `points_change` | 600404 OPEN cluster |
| `coupons` | `discount_pct` | 보고서에 대체 컬럼 미확정 | 600404 OPEN cluster |
| `kds_tickets` | `is_late`, `priority_score` | inline 계산, 실제 `priority` | 600420에서 해결됨 |
| `store_settings` | `kds_capacity_threshold_per_station` | `kds_capacity_threshold_per_zone` | 교정됨 |
| `reconciliation_cases` | `case_severity`, `'INVESTIGATING'` | `severity`, `'UNDER_INVESTIGATION'` | 600910에서 해결됨 |

#### CRITICAL 실제 크래시 가능 지점

- **PreOrder / `WAIT-F01`:** `pre_order_while_waiting()` — `orders.order_source`, 무효 `order_type='TABLE'`, `order_items.unit_price/subtotal/item_options`, `order_sessions.pre_order_amount`; 보고서상 호출 시 `42703`/`23514`.
- **Refund / `PAY-F01`:** `request_refund()`/`confirm_refund()` — `payment_ledger` phantom 컬럼과 무효 `REFUND_PENDING/REFUND_FAILED`; 별도 무효 `audit_decision` literal까지 포함.
- **Toss-POS / `PAY-F01`·`PAY-F06`:** 0104 order builder — `order_items.unit_price/subtotal/item_options/display_order`; 보고서상 `42703`.
- **DID / `KDS-F01`:** `bootstrap_did_app()` — `did_devices` 4개 phantom 컬럼; Verification에서 실제 `show_waiting_count` 크래시 기록.
- **CustomerApp / `CH-F01`·`WAIT-F05`·`APP-F02`:** 0081/0116 laggard 및 `place_takeout_order()`/`track_takeout_order()` — phantom `order_items`와 `menu_code_snapshot` 누락. App 보고서상 해당 takeout RPC의 Dart 호출자는 0이지만 `authenticated` direct RPC 표면은 열려 있다.

**단일 통합 Workpacket 제안:** `repo_wide_phantom_column_contract_audit` — 전체 inventory와 real-schema 대조를 한 번만 수행하고, 수정은 기존 보고서가 분리한 CRITICAL correction workpacket으로 이관한다. 우선순위: **CRITICAL**.

### A2. Index / NavigationMap drift 전사 정리

**통합 결정 1건:** 구현·승인·커밋 시 Readme/NavigationMap/ChangeHistory 동기화를 의무화하고, 현재 누락을 한 번에 backfill할지 결정한다.

**관련 Finding:** `WAIT-F02`, `WAIT-F10`, `PAY-F04`, `PAY-F09`, `KDS-F03`, `KDS-F09`, `APP-F05`, `RUN-F03`.

| 영향 폴더 | 기존 보고서의 누락·drift |
|---|---|
| `600400_kds_did_implementation` | 600520/601020이 Readme·NavigationMap에서 누락; 601020은 ChangeHistory에도 누락 |
| `600500_payment_confirmation` | Readme는 1/8, NavigationMap은 6/8만 수록; 600590/601030 누락 |
| `600600_waiting_order_session` | Readme에서 600630–600680 누락; NavigationMap에서 600670/600680 누락; 커밋된 600670도 미색인 |
| `600800_did_implementation` | 600810/600820 미색인; Readme의 600820 Stage 2 표기가 Stage 6 ACCEPT와 불일치 |
| `600200_flutter_waiting_feature_implementation` | 600220 하위 폴더·Audited 600210 결과를 parent Readme가 반영하지 않음 |

**단일 통합 Workpacket 제안:** `domain_navigation_index_backfill_and_sync_rule` — 위 5개 폴더를 한 번에 backfill하고 향후 lifecycle closeout rule을 문서화한다. `700000`/`700900` 경계는 B의 고유 정책 결정과 연결한다.

### A3. `CREATE OR REPLACE` 소스 잔존 정책

**통합 결정 1건:** 오래된 migration 본문을 그대로 둘 때 superseded 표시를 할지, 최신 migration만 canonical이라고 정책으로 선언할지 프로젝트 전체에서 한 번만 결정한다.

**관련 Finding:** `WAIT-F04`, `APP-F01`; payment/KDS 보고서가 같은 `0063`/`0043`/구 migration body 잔존을 WAIT-F04-class residue로 교차참조했다.

**확인된 사례:** `0050`, `0115`, `0116`, `0081`, `0043`, `0063`의 예전 함수 본문이 소스에 남고 후속 migration이 `CREATE OR REPLACE` 또는 overload drop으로 live contract를 바꾼다. APP-F01에서는 0116만 읽으면 guest bootstrap을 거짓 CRITICAL로 판정하지만 0149가 뒤에서 정상 body로 교체한다.

**단일 통합 Workpacket 제안:** `superseded_migration_body_canonicalization_policy`.

- 선택지 1: migration 불변성을 유지하되 구 body에 대응하는 별도 supersession registry/annotation을 둔다.
- 선택지 2: “migration concat은 끝까지 읽고 최신 `CREATE OR REPLACE`를 canonical로 판정”하는 공식 검사 원칙만 문서화한다.
- 선택지 3: 보고서가 제안한 source-of-truth annotation pass를 수행한다.

### A4. TTL 미문서화 정책

**통합 결정 1건:** 흩어진 수명주기 값을 개별 기능마다 다시 결정하지 않고 하나의 numeric TTL/retention policy로 확정한다.

**관련 Finding:** `CH-F09`, `APP-F03`, `APP-F04`.

**영향 개념:** link/token TTL, cart TTL, coupon reservation/hold TTL, guest session TTL, retention 기간, `customer_app_sessions` app-session TTL(현재 SQL 30일), client SharedPreferences guest identity/session(현재 expiry 없음), anonymous `customers` row retention/dedup/promotion cleanup.

**단일 통합 Workpacket 제안:** `customer_handoff_ttl_retention_policy` — 숫자, 시작시점, 갱신조건, 만료·삭제·promotion 처리 주체를 한 정책 결정으로 묶는다.

### A5. 검증 엄격도 표준화

**통합 결정 1건:** Claude-only/dual/triple verification, 승인 provenance, shared-live-DB fixture isolation을 하나의 거버넌스 표준으로 확정한다.

**관련 Finding:** `PAY-F05`, `PAY-F07`, `KDS-F08`, `WAIT-F06`, `CH-F12`, `APP-F05`.

**보고서 근거:** fabricated triple-verification claim과 near-verbatim duplicate verifier report가 실제로 적발됐고, shared live DB에서 test helper 충돌·잔존이 발생했으며, Draft/Approved/ACCEPT/Stage 표기가 여러 방식으로 drift했다.

**단일 통합 Workpacket 제안:** `independent_verification_and_provenance_standard` — 독립 실행증거, verifier identity, fixture namespace/isolation, approval-before-commit, Status/Stage 갱신 규칙을 한 번에 정한다.

## B. 슬라이스별 고유 비즈니스 정책 결정

반복 테마 A와 이미 구현 결정이 끝난 no-show grace 모델은 제외한다. 아래는 다른 슬라이스와 합칠 수 없는 미결 정책만 남긴 목록이다.

### B1. Customer Handoff Policy (`slice_04`)

1. **Order-confirmed-before-payment:** 005027 post-gate와 005060 pre-payment 중 어느 계약을 ratify할지 결정한다. SQL은 005060을 따른다. [`CH-F03`]
2. **Provider cutline:** Toss+OKPOS(005241)를 ratify하고 Toss+PAYCO(005191)를 superseded 처리할지 결정한다. [`CH-F04`]
3. **Canonical patent contract:** 900102/900103을 canonical로 선언하고 906000/906010의 unique scope를 이관·퇴역할지 결정한다. [`CH-F05`]
4. **Customer-session SoT:** `order_sessions`와 `customer_app_sessions`의 관계를 선언한다. 0148/0149가 waiting linkage를 구현했지만 app/auth session 개념은 별도다. [`CH-F06`, `CH-F07`]
5. **Guest identity operation:** claim/merge/upgrade가 같은 연산인지 별개인지와 preserve-list를 확정한다. [`CH-F10`]
6. **Delivery prepaid no-HOLD bypass:** 허용/금지 및 INV-001과의 관계를 결정한다. [`CH-F11`]

### B2. Waiting (`slice_01`)

1. **Customer wait-status client path:** `get_waiting_status`를 `waiting_status_screen.dart`에 연결할지 결정한다. [`WAIT-F09`]

No-show KDS fate는 구현에서 `HOLD→NO_SHOW_GRACE→auto-CANCELLED`로 이미 Human 결정됐다고 보고서가 확인했으므로 새 Owner 결정에서 제외한다. 남은 일은 문서 정합화다.

### B3. Payment (`slice_02`)

1. **Payment-confirmation canonical path:** `confirm_payment`(0098)와 `confirm_payment_from_provider`(0027)를 통합할지 shared core로 둘지, staff path도 capacity-gated일지 결정한다. [`PAY-F02`, `PAY-F03`]
2. **0143 no-payment exception:** pilot scope와 권한을 확정한다. [`PAY-F02`]
3. **0159 idempotency key:** 다른 intent creation path가 충돌 key를 만들 수 있는지 감사할지 결정한다. [`PAY-F08`]

### B4. KDS / DID (`slice_03`)

1. **No-payment vs fail-closed cooking:** 0143 COMMITTED/null-ledger ticket이 `start_cooking` ledger check를 우회할지 결정한다. [`KDS-F02`]
2. **DID event-reactive scope:** 600810 및 900160/900161을 MVP로 구현할지 future로 명시할지 결정한다. [`KDS-F05`]
3. **Migration-number re-approval:** 0154→0155 대체를 소급 ratify하고 number-conflict 시 재승인 규칙을 정한다. [`KDS-F04`]
4. **Patent authority:** 특허1/특허2 및 capacity late-binding을 900xxx authority에 문서화할지 결정한다. [`KDS-F07`]

### B5. Runtime Flow (`slice_05`)

1. **79 placeholder clone 처분:** 실제 내용을 채울지, 통합할지, scaffold-not-design marker를 붙이고 AI retrieval에서 제외할지 결정한다. [`RUN-F01`]
2. **Runtime-flow design authorship:** gateway ingress(0009)와 knowledge runtime(0019)의 실제 설계 문서를 작성할지 결정한다. [`RUN-F02`]
3. **700000 vs 700900:** 700900을 canonical runtime-flow governance home으로 확정할지 결정한다. [`RUN-F03`]

### B6. App Layer (`slice_06`)

1. **App session / push pipeline:** live path가 `customer_app_sessions`와 push token을 기록할지, v1 및 `register_customer_push_token`을 퇴역시킬지 결정한다. [`APP-F04`]
2. **Channel/platform identity:** Channel-1-web vs Channel-2-native, kiosk Flutter Web vs Android/Windows, same-binary vs flavor를 결정한다. [`APP-F06`]

## C. CRITICAL 4건 — 최우선 개별 항목

| Finding | 한 줄 요약 | 영향받는 실제 함수 / 경로 | 현재 실호출자 유무 | 기존 보고서의 권장 조치 |
|---|---|---|---|---|
| `CH-F01` | Customer-app deferral gate와 real schema가 어긋나고 phantom RPC가 남음 | `place_takeout_order`, `track_takeout_order`, 0081/0116 customer-app RPC군 | App 보고서: phantom takeout RPC와 v1/home/history 계열 Dart 호출자 0. Wired `bootstrap_customer_app_v2`/`register_waiting`은 0149로 정상 | Customer-app phantom/deferral correction을 600680 sibling으로 개설; 0148/0149 linkage governance 확인 |
| `WAIT-F01` | `pre_order_while_waiting()`이 phantom 컬럼과 무효 `TABLE` 값으로 호출 시 실패 | `catchmenu_pos.pre_order_while_waiting` | Waiting 보고서: **no live callers observed**, 0-row evidence | 이미 설계·계약된 600680을 Human 승인 후 Stage-8로 진행 |
| `PAY-F01` | Refund pipeline, Toss-POS builder, invalid audit-decision literal이 real schema와 충돌 | `request_refund`, `confirm_refund`, 0104 Toss-POS order builder, 7개 audit write branch | Payment 보고서: live 함수이나 tables largely 0-row/pre-operation; application caller 수는 명시하지 않음 | Refund Pipeline Contract Redesign, Toss-POS phantom correction, audit-decision literal repair |
| `KDS-F01` | DID bootstrap이 존재하지 않는 `did_devices` 4개 컬럼을 조회 | `bootstrap_did_app`(0117) | 600820 Verification에서 실제 호출 크래시 재현; 보고서상 live DID hardware는 아직 없음 | `did_devices` column reconciliation 및 601010 dependency 결정 |

## D. 권장 처리 순서

### D1. A + C 교차관계

- **A1 Phantom 컬럼 감사는 CRITICAL 4건의 schema-drift 부분을 모두 포괄한다.** 다만 보고서들은 audit과 correction을 별개로 제안하므로, 한 audit이 네 결함을 자동 수정하는 것으로 간주하지 않는다.
- `CH-F01`과 `APP-F02`는 같은 CustomerApp/Takeout `order_items` cluster로 한 correction scope에서 다룰 수 있다.
- `PAY-F01`은 Refund/audit-decision과 Toss-POS를 보고서에서 별도 WP-1/WP-2로 나눴다.
- `WAIT-F01`은 이미 600680이라는 독립 workpacket이 설계 완료·Human 승인 대기 상태다.
- `KDS-F01`은 DID schema reconciliation이라는 독립 workpacket이다.
- A2–A5는 네 CRITICAL의 직접 correction이 아니라 재발 방지·정합성 거버넌스 workpacket이다.

### D2. A + C를 실제 Workpacket으로 열 때의 압축 결과

**최종 권장 개수: 10개.** 기존 슬라이스별 반복 제안을 다음처럼 압축한다.

| 순서 | 통합 Workpacket | 커버 범위 | 우선순위 |
|---:|---|---|---|
| 1 | Repo-wide phantom-column contract audit | A1 전체; CRITICAL 4건과 모든 OPEN cluster의 공통 inventory | CRITICAL |
| 2 | 600680 `pre_order_while_waiting` correction 진행 | `WAIT-F01` | CRITICAL — 설계 완료, Human 승인 대기 |
| 3 | Refund Pipeline Contract Redesign + audit-decision repair | `PAY-F01` refund/audit branch | CRITICAL |
| 4 | Toss-POS `order_items` correction | `PAY-F01`, `PAY-F06` | CRITICAL / HIGH |
| 5 | DID `did_devices` reconciliation | `KDS-F01` | CRITICAL |
| 6 | CustomerApp/Takeout phantom + deferral-gate correction | `CH-F01`, `WAIT-F05`, `APP-F02` | CRITICAL |
| 7 | Domain navigation/index backfill + sync rule | A2 | HIGH |
| 8 | Superseded migration body canonicalization policy | A3 | MEDIUM |
| 9 | Customer-handoff TTL/retention policy | A4 | MEDIUM |
| 10 | Independent verification/provenance standard | A5 | MEDIUM |

**순서 확정 (2026-07-19, Human 확인):** D2의 1→10 순서를 그대로 채택. 다만 이는 순서 확인만이고, 실제 워크패킷 착수는 보류 - domain_02~13(나머지 12개 도메인) 전체 검사를 먼저 마친 뒤, 전체 프로젝트 관점에서 최종 우선순위를 재조정한다. 이유: '문서상에서 파이프라인이 전체적으로 맞아야 한다'는 원칙 - 개별 도메인 단위로 급하게 고치기 시작하면 다른 도메인 검사에서 발견될 내용과 충돌하거나 중복 작업이 생길 수 있음.

### D3. 비즈니스 정책 결정의 처리

B의 항목은 위 10개에 억지로 합치지 않는다. 먼저 Owner가 정책을 결정한 뒤, 구현 또는 문서 정정이 필요한 항목만 기존 정규 개발 절차에 따라 별도 Workpacket으로 연다. 특히 이미 결정된 no-show grace 모델과 이미 해결된 0158/0152 항목은 새로운 결정이나 Workpacket으로 중복 생성하지 않는다.
