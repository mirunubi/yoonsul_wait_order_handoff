# 601443 — Consolidated Owner Decision Registry: Cross-Domain

- Domains: `domain_01_customer_handoff`, `domain_02_payment_ledger_kds` (slices A/B/C/D1/D2/D3 — **6/6 COMPLETED**)
- Source reports: Domain 01 `601427`, `601429`, `601431`, `601434`, `601435`, `601437`; Domain 02 `601440`, `601442`, `601445`, `601449`, `601450`, `601451`
- Inherited registry: `601438_Consolidated_Owner_Decision_Registry_Domain_01.md` (preserved unchanged)
- Scope: 12개 완료 슬라이스의 Owner Decision Queue 및 Regular Workpacket Recommendation Queue 통합·중복 제거
- Status: Owner decision input — cross-domain expansion
- Rule: 새 Finding이나 새 처분을 만들지 않고 기존 12개 검사 결과와 Human 확정 기록만 재구성

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

### A6. 역방향 정본화 필요 항목

**통합 결정 1건:** 구현이 먼저 출하됐거나 검증됐지만 상위 정책·정본문서가 없거나 충돌하는 경우, SQL correction과 분리된 **문서 역방향 정본화 트랙**을 공식화할지 결정한다.

**관련 Finding:** `PKDS-F01`, `PKDS-F02`, `FTR-F01`, `FTR-F03`; 이미 Human 결정이 끝난 비교 사례 `WAIT-F03`.

| 유형 | 보고서에서 확인된 상태 | 필요한 Owner 결정 / 후속 |
|---|---|---|
| Payment→KDS release | 6월 004000 정책에는 7월 구현의 capacity gate와 실제 상태 vocabulary가 없음 | 004000을 현행 three-path + capacity-gated 모델로 갱신하거나 superseded planning으로 표시 [`PKDS-F01`] |
| Payment confirmation authority | 004000과 Financial Trust Room은 단일 provider authority를 전제하지만 구현은 `confirm_payment`와 `confirm_payment_from_provider` 이중 경로 | 단일 authority 또는 명시적 dual-pipeline contract 결정 [`PKDS-F02`, `FTR-F03`, `PAY-F02`] |
| Payment ledger model | 정책은 append-only/WORM/double-entry이고 구현은 mutable single-row `payment_ledger` | mutable MVP를 interim으로 ratify하고 WORM roadmap을 일정화하거나 canonical intent에서 퇴역 [`FTR-F01`] |
| No-show KDS fate | Human이 600632에서 `HOLD→NO_SHOW_GRACE→auto-CANCELLED`로 이미 결정 | 새 정책 결정 없음; 특허/상위 문서만 현행화 [`WAIT-F03`] |

**단일 거버넌스 Workpacket 제안:** `reverse_canonicalization_for_verified_runtime` — 구현 변경이 아니라, Owner 결정 상태에 따라 상위 정본문서를 현재 runtime contract에 맞춰 재작성·supersede하는 별도 트랙이다.

### A7. 거버넌스 연극 — never-opened coding-authorization gate

**반복 패턴 확정:** 코딩승인 trigger와 금지 범위는 정밀하게 문서화됐지만, gate가 한 번도 열리지 않은 상태에서 같은 날짜에 금지 범주의 실제 구현이 출하됐다.

**관련 Finding:** `FSC-F01`, `SCP-F01`.

- D1: 24개 문서의 authorization chain이 `CODING_NOT_AUTHORIZED` / `RUNTIME_ENTRY_NOT_AUTHORIZED`로 종료됐지만 SQL·payment·KDS·kiosk 구현이 2026-06-20/21 first committed됐다.
- D2: 35개 문서 중 34개 정책이 모두 `CODING_DEFERRED`이고 gate는 `CODING_NOT_AUTHORIZED`로 끝났지만 refund/RPC/DB trigger/POS/KDS 구현도 2026-06-20/21 first committed됐다.
- **합계 59개 문서에서 두 사례가 독립 확인됐다.** 문제는 승인 trigger의 모호성이 아니라 문서 gate가 실제 개발을 구속하지 못한 데 있다.

**방법론 자기정정 (`FSD-F03`):** git commit 날짜는 bulk-import 날짜이며 작성 날짜가 아니다. 따라서 기존 “같은 날짜에 authored/동시 작성” 표현은 철회하고 “같은 날짜에 first committed”로 한정한다. 이 수정은 never-opened gate와 금지 범주 구현의 불일치 자체를 변경하지 않는다.

**통합 Workpacket 제안:** `never_opened_authorization_gate_reconciliation` — D1+D2의 실제 승인경로를 기록하고 두 gate를 historical로 퇴역하거나 미래 작업에 맞게 재정의한다.

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

### B7. Payment–KDS Policy (`domain_02` slice_A)

1. **June policy disposition:** 004000 정책을 실제 three-path + capacity-gated release 및 `HOLD→CAPACITY_CHECKING→COMMITTED→COOKING` vocabulary로 현행화할지, superseded planning으로 표시할지 결정한다. [`PKDS-F01`]
2. **Payment-confirmation authority:** 단일 canonical confirmation entry를 둘지, `confirm_payment` / `confirm_payment_from_provider`의 명시적 two-pipeline contract를 승인할지 결정한다. [`PKDS-F02`]
3. **Alcohol handling scope:** 004013의 deferred 상태를 유지할지 확인하고, 향후 범위 포함 시 7개 paper state를 실제 `kds_tickets`와 어떻게 정합화할지 결정한다. [`PKDS-F04`]
4. **004010 navigation/lifecycle:** 004090/004099 number-mismap, stale path, Status/Owner 부재를 정리할지 결정한다. [`PKDS-F05`, `PKDS-F06`]

### B8. Financial Trust Room (`domain_02` slice_B)

1. **Canonical ledger architecture:** mutable MVP ledger를 승인된 interim으로 ratify하고 WORM/double-entry/hash-chain kernel을 일정화하거나 퇴역할지 결정한다. [`FTR-F01`]
2. **Canonical confirmation authority:** provider-only intent를 유지할지, direct POS/staff confirmation을 포함한 dual-pipeline contract를 새로 승인할지 결정한다. [`FTR-F03`]
3. **여전법 storage contract:** no PAN/CVV 및 PG-result-fields-only 원칙을 canonical payment-ledger 설계에 명시할지 결정한다. [`FTR-F02`]
4. **Imported numbering provenance — 해결됨:** `10141`은 5자리 내부 ID로 `010004`를 가리키며, 물리적 `010141`은 내부 ID `10041`인 별개 파일이다. CRP-F04/FTR-F04의 dead-link 의심은 FSC-F03으로 **거짓양성 해소**됐고, 실제 원인은 적용되지 않은 repo-wide rename/move 계획 `010105`다. [`FTR-F04`, `CRP-F04`, `FSC-F03`, `FSC-F04`]
5. **Future scope re-filing:** KYC/fast-payout/disaster/multi-tenant 및 Physical-AI 문서를 Financial Trust Room 밖으로 재분류할지 결정한다. [`FTR-F05`]

`FTR-F06`의 lifecycle metadata 부재는 B8-4 및 A2/A5의 구조·거버넌스 정리 범위에 함께 둔다.

### B9. Foundation Static Catalog (`domain_02` slice_D1)

1. **Authorization-chain disposition:** 실제 구현을 구속하지 못한 010110/010153–010157 게이트를 historical로 퇴역하거나 미래 작업에 맞게 재정의한다. [`FSC-F01`]
2. **Product-line re-baseline:** delivered system과 거의 무관한 010146/010147/010149/010151을 현행화하거나 superseded로 표시한다. [`FSC-F02`]
3. **Kiosk canonicalization:** 중복되고 호출자가 없는 `0052`/`0114` kiosk 구현 중 하나를 canonical로 지정하거나 둘 다 퇴역한다. [`FSC-F05`]
4. **Numbering remediation:** 5자리 내부 ID와 6자리 물리 파일명의 drift를 repo-wide로 정리하고 `010105`를 superseded로 표시한다. [`FSC-F03`, `FSC-F04`]
5. **Preserve before retire:** 폴더를 historical로 격하하기 전에 `010106` §12의 KDS-payment 불변조건과 `010140` §11의 capability-gating formula를 새 정본문서로 추출·보존한다. [D1 §9.7]

### B10. Static Catalog Runtime Planning (`domain_02` slice_D2)

1. **Refund pipeline repair:** `REFUND_PENDING`/`REFUND_FAILED`를 ledger/audit constraints와 정합화하고 세 refund engine 중 canonical 하나를 결정한다. [`SCP-F02`, `PAY-F01`]
2. **Governance disposition:** D1과 통합해 010200 never-opened gate를 historical로 퇴역하거나 실제 승인경로에 맞춰 재정의한다. [`SCP-F01`, `FSC-F01`]
3. **Catalog canonicalization:** shipped flat-key/enum vocabulary와 planned dotted/safe-state vocabulary 중 canonical을 결정한다. [`SCP-F03`]
4. **Citation foundation:** 존재하지 않는 `09560`–`09650` dependency references를 해소하거나 삭제한다. [`SCP-F04`]
5. **Preserve before retire:** `010226` §13을 D1의 `010106` §12와 함께 현행 정본문서로 승격한다. [D2 §9.6]

### B11. Four-Side Skeleton + Data Governance (`domain_02` slice_D3)

1. **Actor-identity ownership:** session/JWT→staff identity contract의 design owner를 지정하고 010554 audit mesh의 선행조건으로 둔다. [`FSD-F01`, `CRP-F02`, `601210`]
2. **Canonical refund vocabulary:** skeleton `REFUND_*`, room `REVERSAL_*`, shipped CHECK 중 canonical을 결정하고 0098을 정정한다. [`FSD-F02`, `SCP-F02`, `PAY-F01`]
3. **KDS late-binding design authority:** upper-skeleton ancestor가 없는 payment→KDS gate의 정본 authority를 문서화한다. [`FSD-F04`, `KDS-F07`]
4. **Skeleton roadmap:** 010350 §12의 잘못된 room 번호를 교정하거나 superseded로 표시한다. [`FSD-F03`]
5. **Placeholder/readme disposition:** 010520을 채우거나 퇴역하고 010300/010500 generated Readme를 재작성한다. [`FSD-F05`]

## C. CRITICAL 4건 — 최우선 개별 항목

| Finding | 한 줄 요약 | 영향받는 실제 함수 / 경로 | 현재 실호출자 유무 | 기존 보고서의 권장 조치 |
|---|---|---|---|---|
| `CH-F01` | Customer-app deferral gate와 real schema가 어긋나고 phantom RPC가 남음 | `place_takeout_order`, `track_takeout_order`, 0081/0116 customer-app RPC군 | App 보고서: phantom takeout RPC와 v1/home/history 계열 Dart 호출자 0. Wired `bootstrap_customer_app_v2`/`register_waiting`은 0149로 정상 | Customer-app phantom/deferral correction을 600680 sibling으로 개설; 0148/0149 linkage governance 확인 |
| `WAIT-F01` | `pre_order_while_waiting()`이 phantom 컬럼과 무효 `TABLE` 값으로 호출 시 실패 | `catchmenu_pos.pre_order_while_waiting` | Waiting 보고서: **no live callers observed**, 0-row evidence | 이미 설계·계약된 600680을 Human 승인 후 Stage-8로 진행 |
| `PAY-F01` | Refund pipeline, Toss-POS builder, invalid audit-decision literal이 real schema와 충돌 | `request_refund`, `confirm_refund`, 0104 Toss-POS order builder, 7개 audit write branch | Payment 보고서: live 함수이나 tables largely 0-row/pre-operation; application caller 수는 명시하지 않음 | Refund Pipeline Contract Redesign, Toss-POS phantom correction, audit-decision literal repair |
| `KDS-F01` | DID bootstrap이 존재하지 않는 `did_devices` 4개 컬럼을 조회 | `bootstrap_did_app`(0117) | 600820 Verification에서 실제 호출 크래시 재현; 보고서상 live DID hardware는 아직 없음 | `did_devices` column reconciliation 및 601010 dependency 결정 |

### C2. Domain 02 HIGH 10건 — 별도 최우선 항목

Domain 02에는 새 CRITICAL이 없으므로 위 CRITICAL 4건 표는 변경하지 않는다. 아래 HIGH 10건을 cross-domain 우선 검토 대상으로 둔다.

| Finding | 한 줄 요약 | 영향받는 실제 함수 / 경로 | 현재 실호출자·구현 상태 | 기존 보고서의 권장 조치 |
|---|---|---|---|---|
| `PKDS-F01` | 6월 Payment→KDS 정책에 7월 capacity gate와 실제 상태 모델이 없음 | `check_kds_capacity`, `bulk_commit`, 0143 no-payment path, staff force-commit path | 구현은 출하됨; 정책은 pre-implementation candidate vocabulary에 머묾 | 004000을 현행화하거나 superseded planning으로 표시 |
| `PKDS-F02` | 두 payment-confirmation pipeline이 단일-authority 정책의 승인을 받지 않음 | `confirm_payment`, `confirm_payment_from_provider` | 두 RPC 모두 구현됨; 정책은 하나의 Payment Runtime authority만 전제 | 단일 entry 또는 명시적 two-pipeline contract 결정 |
| `FTR-F01` | append-only/WORM/double-entry 정책과 mutable UPDATE ledger가 정면충돌 | `payment_ledger` amount/status update 경로, `kds_release_authorized` | mutable ledger가 실제 구현; WORM kernel은 deferred planning | mutable interim ratify + WORM roadmap 일정화 또는 퇴역 |
| `FTR-F03` | Financial Trust Room이 provider-only authority만 승인해 direct confirmation에 설계 home이 없음 | `confirm_payment` direct POS/staff path | 직접 경로 구현됨; 010411/010417은 manual/staff/POS를 financial truth로 인정하지 않음 | PKDS-F02/PAY-F02와 통합해 confirmation authority 결정 |
| `FSC-F01` | 정밀한 coding-authorization gate가 실제 구현을 전혀 구속하지 못함 | 0013/0014/0016/0052/0114 및 50+ SQL migrations | 금지된 구현이 게이트 문서와 같은 시기에 출하됨; authorization artifact는 0 | authorization chain을 historical로 퇴역하거나 실제 승인경로에 맞춰 재정의 |
| `FSC-F02` | 제품라인 계획과 delivered system의 교집합이 거의 없음 | 010146/010147/010149/010151 ↔ payment/POS-KDS/Flutter 구현 | 계획 우선순위 1–6은 미생성; 제외·후순위 범주가 먼저 출하됨 | product-line registry를 delivered reality에 맞춰 재기준화하거나 supersede |
| `SCP-F02` / `PAY-F01` | refund pipeline이 CHECK 제약과 네 가지 방식으로 충돌 | `request_refund`, `confirm_refund`, `chk_ledger_status`, `chk_audit_decision` | 구현은 caller 0인 latent 상태; `0098` 이후 재정의 없음 | **유형 A 최우선:** `REFUND_PENDING`/`REFUND_FAILED` constraint 확장 및 canonical refund engine 결정 |
| `SCP-F01` | D2의 coding gate도 실제 구현을 전혀 구속하지 못해 D1 패턴이 반복 확정됨 | 010224–010226 gate ↔ 0013/0014/0016/0037/0052/0062/0098/0114 | 34개 정책 모두 deferred; 금지된 구현은 같은 날짜 출하 | D1+D2 실제 승인경로 기록 및 never-opened gate 퇴역/재정의 |
| `FSD-F01` / `CRP-F02` / `601210` | caller authorization과 audit actor identity에 design owner 및 JWT→staff bridge가 없음 | `current_actor_id()`, staff-scoped RPCs, 010554 four-layer audit mesh | 추상 원칙·구현 bridge 부재·audit의 unverified actor 전제가 3개 슬라이스에서 독립 확인 | **최우선 아키텍처 WP:** caller identity/session→staff contract를 통합 정의 |
| `FSD-F02` / `SCP-F02` / `PAY-F01` | invalid refund literal의 skeleton→room→SQL 3단계 계보가 완성됨 | 010320 `REFUND_*` → 010412 `REVERSAL_*` → 0098/0014 CHECK | `REFUND_PENDING`은 설계 어디에도 없고 `REFUND_FAILED`는 non-schema skeleton에서 유입; caller 0 latent blocker | 유형 A refund correction에 최종 통합하고 canonical vocabulary를 결정 |

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

### D4. Domain 02 반영 후 재산정 — 두 처리 트랙

기존 D2의 1→10 순서는 2026-07-19 Human 확정 상태이므로 재배열하지 않는다. Domain 02가 추가한 항목은 SQL correction이 아니라 대부분 **정책 결정 후 문서를 역방향으로 정본화하는 작업**이므로 별도 트랙으로 그룹화한다.

#### Track 1 — 기존 Domain 01 correction / governance

- D2의 10개를 확정 순서 그대로 유지한다.
- 실제 착수는 domain_02~13 전체 검사 종료 후 최종 프로젝트 우선순위를 재조정한다는 Human 보류 조건을 유지한다.

#### Track 2 — Domain 02 reverse-canonicalization / policy-document work

| 순서 | 통합 Workpacket | 커버 범위 | 선행 Owner 결정 | 우선순위 |
|---:|---|---|---|---|
| R1 | Payment-confirmation authority canonicalization | `PKDS-F02`, `FTR-F03`, `PAY-F02`, `PAY-F03` | 단일 authority vs explicit dual pipeline | HIGH |
| R2 | Current Payment→KDS release canonical design | `PKDS-F01`; `kds_release_authorized` 문서 부재 | 004000 현행화 vs superseded stamp | HIGH |
| R3 | Payment-ledger architecture canonicalization | `FTR-F01` | mutable interim vs WORM/double-entry roadmap/retirement | HIGH |
| R4 | 여전법 storage-prohibition canonical contract | `FTR-F02` | canonical policy 위치와 wording | MEDIUM |
| R5 | Domain 02 numbering/navigation/lifecycle remediation | `PKDS-F05`, `PKDS-F06`, `FTR-F06`, `FSC-F03`, `FSC-F04`, `FSC-F06`; CRP-F04/FTR-F04 dead-link 의심은 해소됨 | 5↔6자리 번호 drift 및 `010105` 퇴역 방식 | MEDIUM |
| R6 | Future-scope re-filing and alcohol-deferred labeling | `FTR-F05`, `PKDS-F04` | 미래 범위와 canonical domain | MEDIUM / FUTURE |

**재산정 결과:** Slice D3의 Regular Workpacket 후보 5개를 추가해 현재 문서에 기록된 후보는 **31개**다 — 기존 D2의 correction/governance 10개 + Domain 02 역방향 정본화 트랙 6개 + Slice D1/D2/D3 후보 각 5개. 중복 후보는 아래 D8의 domain_02 통합 순서에서 하나로 압축한다.

### D5. Slice D1 Regular Workpacket 후보 추가 (Owner-gated)

| 순서 | Workpacket 후보 | 커버 범위 | 우선순위 |
|---:|---|---|---|
| FSC-WP1 | Never-operative authorization gate reconciliation | `FSC-F01` | HIGH |
| FSC-WP2 | Product-line registry re-baseline | `FSC-F02` | HIGH |
| FSC-WP3 | Duplicate caller-less kiosk canonicalization / retirement | `FSC-F05` | MEDIUM |
| FSC-WP4 | Repo-wide numbering remediation + `010105` retirement | `FSC-F03`, `FSC-F04`; resolved `CRP-F04`, `FTR-F04` provenance 포함 | MEDIUM |
| FSC-WP5 | Generated Readme replacement + 010154 title/body correction | `FSC-F06` | LOW |

### D6. Slice D2 Regular Workpacket 후보 추가 (Owner-gated)

| 순서 | Workpacket 후보 | 커버 범위 | 우선순위 |
|---:|---|---|---|
| SCP-WP1 | Refund pipeline constraint reconciliation + engine canonicalization + caller wiring | `SCP-F02`, `PAY-F01` | HIGH |
| SCP-WP2 | D1+D2 governance reconciliation / never-opened gate retirement | `SCP-F01`, `FSC-F01` | HIGH |
| SCP-WP3 | Shipped catalog/enums 기준 i18n/status canonicalization | `SCP-F03` | MEDIUM |
| SCP-WP4 | Repo-wide numbering/citation remediation | `SCP-F04`; `CRP-F04`, `FTR-F04`, `FSC-F03` 계보 포함 | MEDIUM |
| SCP-WP5 | Policy/handoff de-duplication + generated Readme replacement + dates | `SCP-F05`, `SCP-F06` | LOW |

### D7. Slice D3 Regular Workpacket 후보 추가 (Owner-gated)

| 순서 | Workpacket 후보 | 커버 범위 | 우선순위 |
|---:|---|---|---|
| FSD-WP1 | Caller identity/session→staff contract | `FSD-F01`, `CRP-F02`, `601210` | HIGH |
| FSD-WP2 | Refund vocabulary canonicalization + 0098 repair | `FSD-F02`, `SCP-F02`, `PAY-F01` | HIGH |
| FSD-WP3 | Payment→KDS late-binding design authority | `FSD-F04`, `KDS-F07` | MEDIUM |
| FSD-WP4 | Skeleton/room repo-wide numbering reconciliation | `FSD-F03`, `SCP-F04`, `FSC-F03`, `CRP-F04`, `FTR-F04` | MEDIUM |
| FSD-WP5 | 010520 fill/retire + generated Readme regeneration | `FSD-F05` | LOW |

### D8. Domain 02 완료 후 통합 권장 순서

| 순서 | 통합 과제 | 통합 Finding / 근거 | 우선순위 |
|---:|---|---|---|
| D02-1 | Refund pipeline CHECK correction + canonical vocabulary/engine | `FSD-F02`, `SCP-F02`, `PAY-F01` | **HIGH — 유형 A 최우선 즉시실행** |
| D02-2 | Caller identity/session→staff authorization architecture | `FSD-F01`, `CRP-F02`, `601210` | **HIGH — 최우선 아키텍처** |
| D02-3 | Payment-confirmation authority canonicalization | `PKDS-F02`, `FTR-F03`, `PAY-F02` | HIGH |
| D02-4 | Current Payment→KDS gate 정본화 | `PKDS-F01`, `FSD-F04`, `KDS-F07` | HIGH |
| D02-5 | Payment-ledger amendment/history model | `FTR-F01`, `CRP-F03` | HIGH/MEDIUM |
| D02-6 | D1+D2 never-opened authorization gate disposition | `FSC-F01`, `SCP-F01` | HIGH / governance |
| D02-7 | Repo-wide numbering/citation/roadmap remediation | `FTR-F04`, `CRP-F04`, `FSC-F03/F04`, `SCP-F04`, `FSD-F03` | MEDIUM |
| D02-8 | Catalog/product-line reverse canonicalization | `FSC-F02`, `SCP-F03` | MEDIUM |
| D02-9 | 여전법·audit·preserve-before-retire document track | `FTR-F02`, `010106` §12, `010140` §11, `010226` §13 | MEDIUM |
| D02-10 | Future scope / placeholder / generated Readme cleanup | `PKDS-F04`, `FTR-F05/F06`, `FSC-F06`, `SCP-F05/F06`, `FSD-F05` | LOW/FUTURE |

**Domain 02 최종 압축:** 슬라이스별 후보를 **10개 통합 과제**로 재구성했다. 실제 착수는 전체 domain_02~13 검사 후 프로젝트 관점에서 재조정한다는 기존 Human 보류 원칙을 유지한다.

## E. 역방향 정본화 대상 목록

### E0. 유형 A — 진짜 버그, 설계 이미 완비

| Finding | 대상 | 설계 / 인프라 상태 | 구현 상태 | 처리 판단 |
|---|---|---|---|---|
| **`FSD-F02` / `SCP-F02` / `PAY-F01`** | Refund pipeline 3-layer lineage + CHECK constraint expansion | skeleton 010320의 non-schema `REFUND_*` → room 010412의 superseding `REVERSAL_*` → shipped 0098의 invalid `REFUND_PENDING`/`REFUND_FAILED`; 네 가지 실패 메커니즘 확정 | `request_refund`/`confirm_refund`는 구현됐으나 caller 0인 latent blocker; `0098` 이후 supersede 없음 | **최우선 즉시 실행 후보.** `chk_ledger_status` 확장, audit constraint 정합화, canonical refund vocabulary/engine 결정을 하나로 통합 |
| **`CRP-F01`** | Webhook/provider-callback idempotency | 010660 §28에 구체적 정책이 있고 010610에 `idempotency_key`/`payload_hash` envelope가 있으며 `catchmenu_common.idempotency_keys`(0004)도 존재 | Gateway·RLS·delivery에는 연결됐으나 payment-confirmation path에는 미연결 | **최우선 즉시 실행 후보.** 역방향 정본화가 아니라 기존 설계·인프라를 `confirm_payment_from_provider`에 연결하는 구현 작업 |

FSD-F02/SCP-F02/PAY-F01과 CRP-F01은 “구현은 있으나 정본문서가 없음” 유형이 아니다. 전자는 3단계 vocabulary 계보와 constraint/RPC 충돌이 확정됐고 후자는 정책·인프라 연결만 빠진 구현 결함 후보이므로 아래 역방향 정본화 목록과 분리한다.

### E0-2. 유형 B — Owner 결정 후 역방향 정본화

“구현은 검증됐으나 정본문서가 없거나 충돌·노후화된” 항목만 결정 상태별로 분리한다.

| Finding | 대상 | 구현 / 문서 상태 | Owner 결정 상태 | 역방향 정본화 후속 |
|---|---|---|---|---|
| `FTR-F01` / `CRP-F03` | Payment ledger model | 실제는 mutable UPDATE; slice_B 상위 정책은 append-only/WORM/double-entry. Slice C는 요구사항을 “append-only amendment + before/after history”로 좁힘 | **미결정이나 선택지 축소됨** — 전체 WORM/복식부기 재설계와 mutable 원장 단순 인정 사이에 amendment/history table이라는 저비용 중간 해법 존재 | 재결정 시 amendment/history table을 우선 검토하고, 결정 후 canonical ledger 문서 및 `kds_release_authorized`를 현행화 |
| `FTR-F03` | Payment confirmation authority | 실제는 direct + provider 두 경로; 상위 정책은 provider-only | **미결정** — single authority vs explicit dual pipeline | 결정 후 010411/010417 및 Payment→KDS contract 현행화 |
| `WAIT-F03` | No-show KDS fate | `HOLD→NO_SHOW_GRACE→auto-CANCELLED` 구현·Human 결정 완료 | **이미 결정됨** — 600632에서 Human 확인 | 새 정책 결정 없이 특허/상위 문서만 업데이트 |

### E1. 상태 구분 원칙

- **미결정 항목 (`FTR-F01`, `FTR-F03`):** 문서를 먼저 임의 현행화하지 않는다. Owner가 canonical model을 결정한 뒤 역방향 정본화를 수행한다.
- **이미 결정된 항목 (`WAIT-F03`):** 구현이나 정책을 다시 결정하지 않는다. 기존 Human 결정을 상위 특허·정본문서에 반영하는 문서 작업만 남는다.

### E2. FTR-F01 선택지 축소 기록

당초 FTR-F01은 “WORM/복식부기 전체 재설계 vs mutable 원장 인정”이라는 큰 결정으로 보였다. 그러나 Slice C의 CRP-F03은 실제 cross-room 요구사항이 **append-only 이력/수정이력 테이블 추가**로 충족될 수 있음을 확인했다. WORM/hash-chain/double-entry 전체 도입 없이도 기존 mutable 원장을 유지하면서 before/after amendment history를 남기는 훨씬 저렴한 중간 해법이 존재한다. **FTR-F01 재결정 시 이 좁혀진 옵션을 우선 검토한다.**

### E3. 신규 유형 — 보존 후 폐기 대상

FSC-F01/FSC-F02가 지적한 무효 authorization gate와 실제 구현에 맞지 않는 제품라인 계획을 historical로 격하하기 전에, 그 안의 검증된 유효 내용을 새 정본문서로 먼저 추출한다.

| 원본 | 보존할 내용 | 원본 처분과의 관계 |
|---|---|---|
| `010106` §12 | `POS_ACCEPTED_NOT_PAYMENT_CONFIRMED`, `KDS_COMPLETED_NOT_SETTLED` 등을 포함한 12개 blocking invariant; KDS-payment 결합 불변조건의 원본 출처 | 불변조건을 새 canonical design doc에 보존한 뒤 FSC-F01/FSC-F02 대상 원본을 historical로 격하 |
| `010140` §11 | `FeatureAllowed = ProviderCapability AND TenantFeaturePlan AND StoreRuntimeConfiguration AND PolicyGate AND RuntimeFeatureFlag AND AuthorityBoundary AND EvidenceRequirement AND AuditRequirement` capability-gating formula와 flag registry | 공식을 새 canonical design doc에 보존한 뒤 낡은 제품라인 계획의 처분을 진행 |
| `010226` §13 | `POS_ACCEPTED_NOT_PAYMENT_CONFIRMED`, `KDS_COMPLETED_NOT_SETTLED`, `EVIDENCE_NOT_APPROVAL`, `PGVECTOR_NOT_PROOF`; `010106` §12와 동일 계열의 KDS-payment 결합 불변조건 | D1 원본과 함께 새 canonical design doc에 통합·보존한 뒤 SCP-F01 대상 planning corpus를 historical로 격하 |

**처리 원칙:** 값진 내용을 먼저 추출·정본화하고, 그 다음 무효 게이트·틀린 제품계획 원본을 historical/superseded로 격하한다. 보존 전 원본 폐기는 하지 않는다.
