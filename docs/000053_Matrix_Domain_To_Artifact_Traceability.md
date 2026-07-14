# 000053_Matrix_Domain_To_Artifact_Traceability

Status: In_Progress
Lifecycle: Matrix
Owner: TBD
Last Updated: 2026-07-14

## §0 번호 확인 (이번 턴 최종 재확인)

`000053`은 사용 중인 번호가 아니다 — 이번 턴 3가지 방법으로 확인:

1. `docs/` 디렉토리 직접 조회: `000053_*` 파일 0건. `000052`(Matrix_Batch_6C...)와 `000055`(Matrix_Batch_5F_1...) 사이에 `000053`/`000054`가 빈 번호로 확인됨.
2. `docs/000005_Index_Document_Number.md`에서 `000053` 검색: 0건.
3. `docs/000007_Map_Full_Directory.md`에서 `000053` 검색: 0건.

Cursor의 전수 스캔 결과와 일치 — `000053`을 이 문서의 번호로 확정한다.

## §1 문서 목적 및 `000009`와의 관계

`000009_Report_Root_Governance_Rules_Correction_Readme_Index_And_Overview_Logic_Module_Model.md`는 `Readme`/`Index`/`Overview`/`Logic`/`Module`이라는 **문서 유형(DocumentType)의 정의와 권한 경계**를 확립한 거버넌스 문서다 — "이 폴더는 무엇을 소유하는가", "이 문서 유형은 무엇에 답하는가"를 규정한다.

`000053`은 그와 다른 축의 문서다 — 특정 폴더나 문서 유형이 아니라, **비즈니스 도메인(결제/대기·주문세션/KDS/DID/직원앱/재고/멤버십) 각각이 실제로 어떤 산출물(설계문서/SQL 마이그레이션/Flutter 코드/라이브 DB 상태)로 구현되어 있는지를 가로질러 추적**하는 매트릭스다. `000009`가 "이 문서가 어떤 종류인가"에 답한다면, `000053`은 "이 도메인이 실제로 어디까지 만들어져 있는가"에 답한다 — 이 세션 전체(`600410`~`600497`)에서 반복적으로 드러난 패턴(설계 문서와 실제 SQL/라이브 DB 상태 사이의 괴리, 예: `600480`의 오버로드 모호성, `600490`의 `order_sessions` 8건 phantom 컬럼, 이번 §G의 `015030`/`0108` 시간적 불일치)을 한 곳에서 조망하기 위해 신설한다.

`000009` 자체를 수정하거나 재해석하지 않는다 — `000053`은 `000009`가 정의한 `Matrix` 유형(다른 `00005x` 문서들, 예: `000052`/`000055`/`000058`이 이미 사용 중인 "체크리스트/승인 매니페스트" 성격)의 연장선에 있는 살아있는(living) 참조 문서다.

## §2 도메인 섹션

### A. Customer Handoff — Payment Confirmation

**상태**: 오버로드 모호성 해소 완료(`600480`), Payment Confirmation Boundary 후속 조사는 별도 필요.

| 산출물 | 위치 | 상태 |
|---|---|---|
| 설계 | `900100`-`900103`(`Overview`/`Logic`/`ChangeContract`/`TestPlan`, Customer Waiting Handoff And Late Binding Pipeline) | 존재, `결제 승인 ≠ KDS 릴리즈 자동 허용`(특허1) 원칙 정의 |
| SQL — 함수 | `catchmenu_payment.confirm_payment_from_provider()` (`0027` 원본, 8-param, canonical 확정) | **완료** — `0153`으로 9-param 오버로드(`0063`) DROP, 유일 오버로드로 정리. 실제 E2E 성공 실행 2회 독립 재현 확인(서로 다른 금액/PG사) |
| SQL — 테이블 | `catchmenu_payment.payment_ledger`(28개 컬럼), `payment_intents` | `0027`의 INSERT 컬럼 전수(19개) 라이브 스키마·CHECK 제약 대조 완료, 전부 정확 |
| SQL — 호출부 | `0038`(토스 웹훅), `0056`(VAN 연동) | 정상, 수정 불필요(이미 8-param 정확 사용) |
| 라이브 검증 | `kds_release_authorized = false` 불변식(특허1) | 2회 독립 재현 전부 확인 |
| Open Item | `mark_payment_uncertain()`/`authorize_kds_release()` — 같은 오버로드 확산 패턴, 호출자 0건, 별도 워크패킷 후보 (`authorize_kds_release()`는 두 오버로드가 3번째 파라미터 이름부터 달라 단순 해법 적용 불가) | 미착수 |
| 문서 | `600480_confirm_payment_from_provider_overload_ambiguity/` (`600481`-`600487`, 7개 파일 완비) | 완료 |

### B. Customer Handoff — Waiting / Order Session

**상태**: Contract Inventory 완료(`600490`), 2건 Correction 구현 완료, 나머지 다수 Open.

**함수 계약** (`0115_create_waiting_pipeline_rpc.sql`, 9개):

| 함수 | 상태 |
|---|---|
| `register_waiting()` | **정상** — `session_type := 'WAITING'` 정확 사용, `chk_session_type` 통과 |
| `call_waiting_customer()` | `order_sessions`의 phantom 컬럼(`table_number`/`called_at`/`call_count`/`pre_order_amount`) 참조 — 미해결 |
| `confirm_arrival()` | phantom 컬럼(`table_number`/`arrival_confirmed_at`) 참조 — 미해결 |
| `pre_order_while_waiting()` | **3중 결함 체인** — ① `orders` INSERT의 `order_source`(phantom)/`order_type := 'TABLE'`(chk_order_type에 없음), ② `order_items` INSERT의 `unit_price`/`subtotal`/`item_options` phantom + `menu_code_snapshot` 누락, ③ `kds_tickets` INSERT의 `menu_id`/`ticket_number` — **③만 이번에 수정 완료**(`600495`-`600497`), ①/②는 여전히 함수를 100% 막고 있어 이 수정으로도 E2E 진전 없음(직접 재현으로 재확인됨) |
| `seat_waiting_customer()` | phantom 컬럼(`table_number`) 참조 — 미해결 |
| `cancel_waiting()` | phantom 컬럼(`cancel_reason`) 참조 — 미해결 |
| `mark_no_show()` | phantom 컬럼(`no_show_at`) 참조; **오버로드 2개**(`0050` 원본 vs `0115` 재정의, `p_actor_type` vs `p_actor_id`+`p_locale`) — 모호성 실증 여부 미조사 |
| `get_waiting_status()` | phantom 컬럼(`called_at`/`arrival_confirmed_at`) 참조 — 미해결 |
| `get_waiting_admin_view()` | phantom 컬럼(`call_count`/`memo`) 참조 — 미해결 |

**`get_waiting_realtime_state()`** (`0099`): **수정 완료** — `max_waiting_count`→`max_wait_number` 정정, 신규 데이터로 진전 재확인(이전엔 `store_settings` 조회에서 즉시 실패 → 이제 통과, 다음 정지점 `arrival_confirmed_at`).

**`order_sessions` 8개 컬럼 drift** (전부 phantom, 실제 34개 컬럼 목록에 없음): `pre_order_amount`/`table_number`/`called_at`/`call_count`/`arrival_confirmed_at`/`cancel_reason`/`no_show_at`/`memo`. SoT 후보 분류(결정 아님): Correction 2건(`cancel_reason`/`no_show_at`), Alignment 1건(`arrival_confirmed_at`↔기존 `arrived_at`), Redesign 5건(나머지, `dining_tables`/`did_display_queue`와 개념 중복 우려).

**문서**: `600490_customer_handoff_contract_reconciliation/` (`600491`-`600497`, 7개 파일 완비).

### C. Customer Handoff — KDS Ticket

**상태**: 여러 워크패킷에 걸쳐 다수 결함 발견·수정, 일부 Open.

| 워크패킷 | 내용 | 상태 |
|---|---|---|
| `600410` | `catchmenu_kds.check_kds_capacity()` 신규 생성(존 인지 wrapper, `evaluate_kds_capacity()` 위) | ACCEPT, 완료 |
| `600420` | `0099`의 `is_late`/`priority`/`kds_capacity_threshold_per_zone` stale 컬럼 → 계산식/정정 컬럼명 | ACCEPT, 완료. 이번 `600490` 작업에서도 잔존 여부 재확인(0건, 보존 확인) |
| `600430` | `request_memo`/`case_severity`/`'INVESTIGATING'` 등 10개 파일 정정 | ACCEPT, 완료 |
| `600440` | `READY_TO_COMMIT`→`COMMITTED` 13개 파일/46건 통일(Human 결정, 900시리즈 패턴 근거) | ACCEPT(설계), **구현 자체는 일부만 커밋됨** — `0016`/`0029`/`0045`/`0051`/`0070`/`0081`/`0063`은 커밋 완료(`38d681f`/`8b0e45d`), `0024`/`0026`/`0028`/`0039`/`0044`/`0143`/`0151` 7개 파일은 이번 세션 끝까지 **미커밋 상태로 확인**(diff는 전부 정확, 그러나 git에 반영 안 됨) |
| `600490` | `pre_order_while_waiting()`(`0115`)의 `kds_tickets` INSERT — `menu_id`(phantom) 제거, `ticket_number`(NOT NULL 누락) 생성 로직 추가(`0026` 관례 재사용) | ACCEPT(scoped, final), 삼중검증(Claude Code+안티+Codex+Cursor) 완료. 단 `kds_tickets` 자체는 `pre_order_while_waiting()`의 앞선 2개 블로커(orders/order_items) 때문에 실제 도달 불가 상태 |

**`kds_tickets`** 라이브 스키마: 41개 컬럼, `ticket_number`(실존, NOT NULL) 확인, `menu_id` 없음(메뉴 연결은 `order_item_id` 경유). `chk_kds_status`: `HOLD`/`CAPACITY_CHECKING`/`COMMITTED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED`/`MANUAL_FALLBACK`.

**문서**: `600410`/`600420`/`600430`/`600440`/`600490` 각 워크패킷 폴더 + `600404_PlaceTakeoutOrder_Defect_Roadmap.md`(관련 place_takeout_order() 결함 로드맵).

### D. Customer Handoff — DID

**상태**: 오늘 계약 인벤토리(`600490`)에서 조사됨. **실제 화면 구현 미착수.**

| 함수 | Source | 상태 |
|---|---|---|
| `get_did_display_state()` | `0043`(원본, `p_did_id`) / `0117`(재정의, `p_device_id`) | **오버로드 2개** — `0117`이 원본을 DROP 없이 새 시그니처로 추가. 모호성 실증 여부 미조사 |
| `notify_customer_ready()` | `0043` | 계약만 추출, 함수 본문 심층 검증 안 함 |
| `update_did_display()` | `0043` | 계약만 추출, 함수 본문 심층 검증 안 함 |
| `call_customer_pickup()` | `0079`(원본) / `0094`(패치, 라이브 실제 소유자로 확인됨 — 본문 전체 diff로 검증) | `event_domain := 'store'`가 `chk_event_domain`에 없어 매 호출마다 실패(`600477_Audit.md`에서 발견) — `ready_at` UPDATE(`600470`에서 수정됨) 도달 전에 이미 막힘 |

**테이블**: `catchmenu_store.did_display_queue`(25개 컬럼), `catchmenu_store.did_devices`(22개 컬럼) — 둘 다 실존, RLS 확인. **단, `600490` 조사 범위였던 B/C 경계 15개 함수 중 어느 것도 이 두 테이블을 직접 참조하지 않음** — DID 관련 실제 로직은 `0043`/`0079`/`0094`/`0117`에 흩어져 있고, 이번 세션에서 이 함수들에 대한 화면/E2E 검증은 수행되지 않았다.

**Flutter**: 실제 DID 화면 코드 존재 여부 미확인 — 이번 세션 조사 범위 밖. **화면 구현 미착수로 명시.**

### E. Staff App

**상태**: 미착수. 골격만.

- 설계 문서: 미조사.
- SQL: 미조사(`0110_create_store_admin_rpc.sql` 등 존재 가능성 있으나 이번 세션에서 도메인 단위로 조사되지 않음).
- Flutter: 미조사.

### F. Inventory

**상태**: 미착수. 골격만.

- 설계 문서: 미조사.
- SQL: `0124_create_inventory_pipeline.sql` 등 파일명으로 존재 확인되나 내용 미조사.
- Flutter: 미조사.

### G. Membership

**상태**: 오늘 신규로 방대한 데이터 확보. 설계 문서와 실제 SQL 구현 사이에 시간적 불일치 발견(아래 "발견된 이슈" 참고).

#### G.1 설계 문서

| 문서 | 핵심 내용 |
|---|---|
| `000010_Guide_Wait_Order_Project.md` §10-11 | **Identity 분리 원칙**: CatchMenu App(자체 고객 정체성) / CatchMenu Webapp(QR 즉시입장) / White Label App(가맹점 소유 멤버십)은 반드시 분리 유지. "고객은 CatchMenu identity와 tenant membership identity를 동시에 가질 수 있으나, 강제 병합해서는 안 된다"(identity link ≠ account merge). Benefit Routing 원칙: "wait_order는 멤버십 원장이 아니다. Benefit candidate ≠ benefit claimed." |
| `900130`/`900131`(Overview/Logic, Channel 3 Whitelabel) | 화이트라벨 앱의 세션·멤버십 로직. `STANDALONE`/`FRANCHISE_LINK`/`HYBRID` 3개 모드 서술. `FRANCHISE_LINK`: `earn_points_after_order()`가 `point_ledger`에 `HOLD_INTERNAL` 기록 후 Edge Function으로 외부 이관, 실패 시 수동 처리 대기. |
| `900140`/`900141`(Overview/Logic, Channel 4 Yoonsul Embedded) | 윤슬김밥 임베디드 앱. **`YOONSUL_LINK` 모드**: 브랜드 전체 매장 포인트 공유(`brand_id` 기준 통합 원장), Phase 2(2차 개발) 예정 기능으로 명시. 캐치메뉴(운영 OS)와 윤슬OS(백오피스: 노무/재고/가맹계약)는 별개 시스템으로 직접 연결 안 됨. |
| `015000_Readme_Membership_Loyalty.md`/`015000_Index_...md` | 멤버십/로열티/쿠폰 확장 웨이브 1 폴더 진입점. |
| `015030_Boundary_Point_Ledger_And_Wallet_Non_Implementation.md` | **"MVP에서 금지"** 명시적 목록: no point ledger, no point earning, **no cross-store/cross-tenant point exchange**, **no Yoonsul group point integration**, no external membership point bridge. §7 Current Status: "active non-implementation boundary... No implementation approval." |
| `015040_Boundary_External_Membership_Bridge_Future.md` | 외부 멤버십 브리지(Yoonsul group point future bridge 포함) 전부 **"future-reserved"**로 명시. §7 Current Status: "future-reserved... No implementation approval." |

#### G.2 SQL 구현 (`0108_create_membership_pipeline_rpc.sql` 중심)

**멤버십 모드** (라이브 `chk_membership_mode` 재확인): `STANDALONE`/`STAMP`/`FRANCHISE_LINK`/`YOONSUL_LINK`/`HYBRID` — 5개 전부 실존.

**테이블** (전부 라이브 확인, `tenant_id` 컬럼 + RLS 활성화 확인):

| 테이블 | tenant_id | RLS |
|---|---|---|
| `catchmenu_store.customers` | O | O |
| `catchmenu_store.point_ledger`(19개 컬럼: `transaction_type`/`points_change`/`points_before`/`points_after` 등) | O | O |
| `catchmenu_store.membership_configs` | O | O |
| `catchmenu_store.stamp_cards` | O | O |
| `catchmenu_store.point_transfer_log` | O | O |
| `catchmenu_store.membership_tiers_config` | O | O |

**함수** (`0108` 헤더 주석 기준, 라이브 존재 확인): `get_membership_config()`, `earn_points_after_order()`, `stamp_visit()`, **`transfer_points_to_franchise()`**, **`transfer_points_to_yoonsul()`**, `get_customer_membership()`, `get_membership_dashboard()`.

#### G.3 Flutter 소비

`0135_create_flutter_mvp_start_package.sql`(계획 문서, 실제 코드 아님) Phase 5(CUSTOMER_APP) §"멤버십" — `get_customer_membership()` RPC 연동 예정, **"우선순위: 보통 (오픈 후 개발)"**로 명시 — 아직 미개발.

**실제 Flutter 코드 확인**: `catchmenu_app/lib/` 전체에서 `membership` 관련 참조는 `app_constants.dart`의 상수 문자열 `pipelineMembership = 'MEMBERSHIP'` **단 1건뿐** — 실제 화면/로직 코드는 존재하지 않음. **README(계획 문서)만 있고 실제 코드는 없는 상태임을 명시.**

#### G.4 발견된 이슈 (판단·해결책 제시 없음, 사실만 기록)

**거버넌스 문서(`015030`/`015040`)가 명시적으로 "미승인"/"future-reserved"라고 선언한 기능이, SQL 레벨에서는 이미 완전히 구현되어 라이브 DB에 존재한다.**

- `015030` §2 "Forbidden in MVP": "no point ledger", "no point earning", "no cross-store point exchange", "no cross-tenant point exchange", "no Yoonsul group point integration" — 그러나 `catchmenu_store.point_ledger` 테이블은 실존하고, `earn_points_after_order()`(포인트 적립)와 `transfer_points_to_franchise()`(가맹점 간 이관)가 라이브 함수로 존재한다.
- `015040` §2 "Bridge Types" 표에 "Yoonsul group point future bridge"를 "future-reserved"로 명시 — 그러나 `transfer_points_to_yoonsul()` 함수가 라이브로 존재하고, `900140` 설계 문서는 `YOONSUL_LINK` 모드를 (Phase 2로 예정되어 있긴 하나) 상세히 기술하고 있다.
- `015030`/`015040` 둘 다 §7 "Current Status"에서 "No implementation approval"이라고 명시.
- 이 매트릭스는 이 시간적 불일치가 왜 발생했는지(예: `015030`/`015040`이 더 나중에 작성된 재검토 결정인지, `0108`이 이미 승인된 후 거버넌스 문서가 뒤늦게 작성된 것인지, 단순 소통 누락인지)를 판단하지 않는다 — **우선순위/승인 상태 재확인이 필요하다는 사실만 기록한다.**

## §3 남은 작업

- E/F(Staff App/Inventory) 섹션은 골격만 — 실제 조사 필요.
- D(DID) 섹션의 실제 화면 구현 여부는 이번 세션에서 확인되지 않음.
- G.4의 거버넌스/SQL 불일치는 Human 판단 필요 — 이 문서는 그 판단을 대신하지 않는다.

## Module Domain Tags

- DOCUMENTATION_ONLY
- CROSS_DOMAIN_MATRIX
