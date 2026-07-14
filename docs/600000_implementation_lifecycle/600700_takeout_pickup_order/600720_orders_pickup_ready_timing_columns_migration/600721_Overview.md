# 600721_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`orders_pickup_ready_timing_columns_migration`

## §0 Human 결정 (2026-07-13, Cursor+Codex 이중 조사 완료, 재논의 금지)

1. `requested_pickup_at` + `ready_at` 두 phantom 컬럼을 함께 고친다(같은 종류의 결함, `track_takeout_order()`가 둘 다 필요로 함).
2. 방식: forward migration으로 `catchmenu_pos.orders`에 실제 컬럼 추가(A안) — `0092` Flutter 가이드가 이미 `requested_pickup_at`을 API 설계로 확정했으므로, 이 값은 실제 저장돼야 하는 게 원래 의도였음이 확인됨.
3. 컬럼명: `requested_pickup_at`(RPC 파라미터/Flutter 가이드/코드 4곳과 일치, 정책문서의 `_time` 표현은 개념적 서술일 뿐 API 계약이 아님).

이번 산출물(Stage 1.5)은 문서만 — `.sql` 파일은 이번 턴에 생성/수정하지 않는다.

## §1 영향받는 전체 파일/함수 목록 (이번 턴 전수 재확인)

`requested_pickup_at`과 `catchmenu_pos.orders.ready_at`(주의: `catchmenu_kds.kds_tickets.ready_at`은 별개의, 이미 존재하는 컬럼 — 아래 §1.1 참고)을 저장소 전체에서 재검색한 결과, **3개 파일, 2개 함수(총 3개 코드 지점)** 가 실제 영향을 받는다:

| 파일 | 함수 | 컬럼 | 성격 | 위치 |
|---|---|---|---|---|
| `0081_create_customer_app_rpc.sql` | `catchmenu_store.place_takeout_order()` | `requested_pickup_at` | **INSERT — 컬럼 목록 원소**(`catchmenu_pos.orders` INSERT) | L845(컬럼명)/L854(값, `p_requested_pickup_at`) |
| `0081_create_customer_app_rpc.sql` | `catchmenu_store.track_takeout_order()` | `requested_pickup_at`, `ready_at` | **SELECT — 컬럼 목록 원소**(`catchmenu_pos.orders o` 조회) | L1056(`o.ready_at`)/L1058(`o.requested_pickup_at`), 응답 JSON 에코 L1184/L1187-1188 |
| `0079_create_did_advanced_rpc.sql` | `catchmenu_store.call_customer_pickup()` | `ready_at` | **UPDATE — SET절**(`catchmenu_pos.orders` UPDATE) | L727 — 원래 정의(아래 §1.2 참고) |
| `0094_fix_i18n_hardcoded_strings.sql` | `catchmenu_store.call_customer_pickup()` | `ready_at` | **UPDATE — SET절**(`catchmenu_pos.orders` UPDATE) | L792 — 같은 함수의 패치/최신 정의(아래 §1.2 참고) |

### §1.1 `kds_tickets.ready_at`는 이미 존재하는 별개 컬럼 — 혼동 주의

`ready_at`이라는 식별자가 `sql/migrations/*.sql` 전체에서 10개 파일에 등장하지만, 그중 `0016`/`0029`/`0043`/`0045`/`0051`/`0070`/`0106`의 7개는 전부 **`catchmenu_kds.kds_tickets.ready_at`**(`0016`에서 정의된 실제 존재 컬럼, `cooking_started_at`과 함께 KDS 조리 완료 시각을 기록)을 가리킨다 — 이번 결함과 무관하며, 각 파일에서 직접 확인한 `FROM`/`UPDATE` 대상 테이블(`catchmenu_kds.kds_tickets`)로 검증 완료. 이번 결함은 오직 `catchmenu_pos.orders.ready_at`(존재하지 않음)에 관한 것이며, 이를 참조하는 곳은 `0079`/`0094`/`0081`(track_takeout_order) 뿐이다.

### §1.2 `call_customer_pickup()` — 하나의 함수, 두 소스 파일(원본+패치)

`0079_create_did_advanced_rpc.sql`(L482 시작)과 `0094_fix_i18n_hardcoded_strings.sql`(L528 시작)은 **서로 다른 두 함수가 아니라, 같은 함수 `catchmenu_store.call_customer_pickup()`의 원본 정의(`0079`)와 이후 패치 정의(`0094`, `create or replace function`으로 덮어씀)**다.

**정정(이번 턴, 사실 확인)**: 이전 판단은 "마이그레이션 순서상 `0094`가 나중에 적용됐을 것"이라는 추론과 `ready_at` 라인 1곳의 텍스트 일치만으로 내려졌다. 이번 턴에 `pg_get_functiondef()`로 라이브 정의 전체를 가져와 두 소스 파일의 함수 본문 전체(각각 `begin`부터 `end;`/`$$;`까지)와 직접 diff 대조했다:

- **라이브 vs `0094`**: `begin` 이후 292줄 전체가 **완전히 일치**(유일한 차이는 `pg_get_functiondef()`가 항상 `$function$`로 렌더링하는 닫는 델리미터 표기뿐 — 원본 소스의 `$$;`와의 순수 표기 차이, 내용 차이 아님).
- **라이브 vs `0079`**: 라이브 정의에 `catchmenu_common.get_message(...)` 호출이 8회 등장하고 `did_call_pickup_title`/`did_call_pickup_body` 등 message_catalog 키가 존재하는 반면, `0079` 본문에는 `get_message` 호출이 0회이고 `'포장 준비 완료'` 등 하드코딩된 한글 문자열을 직접 쓴다 — 완전히 다른 텍스트. `0079`와 `0094`의 본문을 서로 diff하면 i18n 처리 방식 전체(제목/본문 메시지 생성 로직, 4개 언어 전부)가 실질적으로 재작성되어 있음을 확인했다(단순 포맷팅 차이가 아니라 `0094`가 `0079`의 하드코딩 문자열 전부를 `message_catalog` 참조로 교체한 실질적 재작성).

**결론(사실 확인 완료)**: 현재 라이브로 동작 중인 버전은 **`0094`이며, 소스 텍스트가 바이트 단위로 일치함이 확인됐다**. `0079`의 정의는 **완전히 대체(superseded)되어 현재 어떤 형태로도 라이브에 반영되어 있지 않다** — 추론이 아니라 직접 대조로 확정. 따라서 향후 `call_customer_pickup()`의 **함수 로직 자체**를 수정하는 ChangeContract가 작성될 경우 Allowed Files는 **`0094_fix_i18n_hardcoded_strings.sql` 단독**이어야 한다(`0079`는 Forbidden 또는 "역사적 원본, 라이브 무관"으로만 언급). 다만 이번 `600720` workpacket 자체는 `ALTER TABLE`만으로 완결되며 두 파일 중 어느 쪽도 실제로 수정하지 않는다(`600722_Logic.md` §1/Snapshot Decision 참고) — 이 결론은 참고용 확정 사실이며 이번 workpacket의 Allowed Files 자체를 바꾸지 않는다.

**함수 성격 확인**: `call_customer_pickup()`은 `p_queue_type default 'PICKUP_READY'`를 받아 DID(디지털 안내판) 픽업 알림 큐에 항목을 추가하고, `p_queue_type = 'PICKUP_READY'`이면서 주문이 아직 `COMPLETED`/`CANCELLED`가 아닐 때 `catchmenu_pos.orders`를 `order_status = 'READY'`로 전환하며 `ready_at`을 기록하는 KDS/DID 픽업-준비-완료 알림 함수임을 이번 턴에 직접 확인했다 — 사용자 배경 설명의 "KDS ready 알림 관련 함수"라는 추정이 정확했다.

### §1.3 `PICKED_UP` status drift — 재확인, 범위 밖으로 확정

`call_customer_pickup()`의 UPDATE `where` 절이 `order_status not in ('READY', 'PICKED_UP', 'COMPLETED', 'CANCELLED')`를 쓰지만, 라이브 `chk_order_status` 제약(`PENDING`/`CONFIRMED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED`)에는 `PICKED_UP`이 없음을 이번 턴 재확인했다. 이는 **하드 에러가 아니라** WHERE절의 배제 조건 하나가 절대 매치되지 않는 죽은 조건(no-op)일 뿐이다 — `order_status`가 애초에 `'PICKED_UP'`이 될 수 없으므로 이 배제 조건은 아무 행에도 영향을 주지 않는다. 별개의, 이번 range의 컬럼 부재(하드 에러) 결함과는 성격이 다르며, 이번 workpacket 범위 밖(Open Item으로만 기록).

## §2 `0013` 원본 DDL과의 정합성 — 기존 nullable 타임스탬프 컬럼 패턴 재확인

`sql/migrations/0013_create_pos_orders.sql`(orders 테이블 원본 정의)에서 이미 존재하는 생애주기 타임스탬프 컬럼 3개를 재확인:

```sql
ordered_at timestamptz not null default now(),
confirmed_at timestamptz,
cancelled_at timestamptz,
completed_at timestamptz,
```

`confirmed_at`/`cancelled_at`/`completed_at` 모두 **nullable, 기본값 없음** — Human 결정이 제안하는 `requested_pickup_at timestamptz null 허용, ready_at timestamptz null 허용` 설계가 이 기존 패턴과 정확히 일치함을 확인했다.

## §3 API 계약 근거 — `0092` Flutter 가이드의 `requested_pickup_at` 확정 사용

`sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` L383 재확인:

```dart
'p_requested_pickup_at':
  requestedPickupAt?.toIso8601String(),
```

`placeTakeoutOrder()` 클라이언트 호출부가 `DateTime? requestedPickupAt` 파라미터를 명시적으로 RPC에 전달하도록 설계되어 있다 — Human 결정 근거("이 값은 실제 저장돼야 하는 게 원래 의도")를 뒷받침하는 구체적 증거로 재확인.

## §4 정책 문서의 `_time` 표현 — 개념적 서술 확인

`docs/000040_Runtime_Operation_Patterns_For_KDS_And_Mini.md` L190 재확인:

```
5.2 Core Boundary
wait_order core may hold interface-level fields.
Examples:
- handoff_channel
- handoff_location
- recipient_type
- requested_pickup_time
- arrival_status
```

이 목록은 "Examples:"로 명시된 **인터페이스 레벨 개념 예시**이며 구체 스키마 명세가 아니다 — `requested_pickup_time`이라는 표현이 등장하지만 실제 컬럼명을 지시하는 문서가 아님을 재확인했다. `docs/011000_integration_boundary/011140_...md`에서도 `expected pickup time`(L285) 등 유사하게 개념적 서술만 존재하며 구체 식별자는 없다. Human 결정 3항("정책문서의 `_time` 표현은 개념적 서술일 뿐 API 계약이 아님")이 이번 재확인으로 뒷받침됨 — 실제 코드/API 계약 4곳(`0081` 3곳 + `0092` 1곳)이 일관되게 `requested_pickup_at`을 쓰므로 이 이름을 유지한다.

## §5 근거 정책 문서 3곳 — Pickup 관련 서술 존재 확인 (개념 수준)

- `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010906_Policy_Store_Service_Mode_Selection_And_Feature_Readiness.md` §10 "Pickup Order Readiness" — pickup time setting/hold time 등 픽업 정책 요구사항 존재(개념 수준, 컬럼명 지시 없음).
- `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010907_Policy_POS_Payment_KDS_Integration_Readiness_Intake.md` — "Pickup time mapping | Required for pickup" 서술 존재(개념 수준).
- `docs/011000_integration_boundary/011140_...md` §11 "Pickup Context Boundary" — pickup 관련 이벤트/필드 개념 목록 존재.

세 문서 모두 "픽업 시각을 다뤄야 한다"는 정책적 요구를 확인시켜주지만, 구체 컬럼명/타입을 지시하지 않는다 — 실제 스키마 설계는 §2/§3의 코드 근거(기존 컬럼 패턴 + API 계약)를 따른다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`
- `000001_Md_Rules.md`

### Full Rules Required

- `sql/migrations/0013_create_pos_orders.sql` — `catchmenu_pos.orders` 원본 DDL, 기존 nullable 타임스탬프 컬럼 패턴의 유일한 근거(§2).
- `docs/000040_Runtime_Operation_Patterns_For_KDS_And_Mini.md` — `requested_pickup_time` 개념적 언급 근거(§4).
- `docs/011000_integration_boundary/011140_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary.md` — Pickup Context Boundary 정책 근거(§5).
- `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010906_Policy_Store_Service_Mode_Selection_And_Feature_Readiness.md` — Pickup Order Readiness 정책 근거(§5).
- `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010907_Policy_POS_Payment_KDS_Integration_Readiness_Intake.md` — Pickup time mapping 정책 근거(§5).
- `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` — `requested_pickup_at` API 계약 확정 근거(§3).

### Domain Indexes

- 해당 없음 — 본문에 도메인 Index/NavigationMap/Readme 인용은 없다.

### Excluded Rule Families

- `900xxx` 특허/설계 문서 전체 — 이번 턴 `grep -rli "pickup\|ready_at" docs/900*` 재확인 결과 **0건**, 직접 근거 없음이 확인됨.
- `900160`/`900161`(KDS/DID 자동 제어 특허 문서) — KDS 티켓 상태(`kds_status`) 도메인이며, 이번 결함은 `orders` 테이블의 별개 컬럼 문제이므로 무관.
- `600404_PlaceTakeoutOrder_Defect_Roadmap.md`의 `point_ledger`/`discount_pct` 항목 — 관련 있으나(같은 함수의 다른 결함) 이번 workpacket의 수정 범위와는 다른 코드 영역.
- `PICKED_UP`/`chk_order_status` drift(§1.3) — 별개의, 하드 에러가 아닌 발견 사항, 이번 workpacket 범위 밖(Open Item).

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600722_Logic.md` 작성 진행 가능.
