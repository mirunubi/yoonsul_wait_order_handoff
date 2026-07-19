# 600684 ChangeContract — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Stage: 5 (변경 계약)
- Depends on: [600681_Overview](600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md), [600682_Logic](600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md), [600683_TestPlan](600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md)
- Created: 2026-07-19

## §0. 개요

`catchmenu_pos.pre_order_while_waiting()` 한 함수의 phantom 컬럼 제거 + 2개 필수 필드 추가 + PUBLIC 권한 회수. 0160/0163/0164/0167과 동일한 "순수 phantom 제거 + 권한 정정" 패턴. 새 기능·상태전이·조건 로직 없음.

## §1. 목적

현재 라이브 스키마 기준 실행 즉시 크래시(`42703`/`23514`)하는 MVP 대기-중-사전주문 정본 함수를, 실제 컬럼으로 정정해 호출 가능 상태로 복구한다. 동시에 형제 교정본(seat_waiting_customer/cancel_waiting)의 `has_pre_order`/HOLD-취소 분기가 작동하도록 세션 링크(order_id + pre_order_created_at)를 세우고, PUBLIC 노출을 authenticated로 잠근다.

## §2. Allowed (허용 변경)

1. `catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text)` **본문만** `CREATE OR REPLACE`로 재정의:
   - `menus` SELECT(2번째 루프)에 `menu_code`/`estimated_minutes` 추가(600682 §1).
   - `orders` INSERT: `order_source` 컬럼/값 제거, `order_type` `'TABLE'`→`'DINE_IN'`(600682 §2).
   - `order_items` INSERT: `unit_price`→`unit_price_snapshot`, `subtotal`→`item_amount`, `item_options`→`selected_options`, `menu_code_snapshot`/`options_amount(0)`/`kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot` 추가(600682 §3).
   - `order_sessions` UPDATE: `pre_order_amount = ...` 제거, `order_id = v_order_id` 추가(C1-a), `pre_order_created_at = now()` 추가(C1-b)(600682 §4).
2. `revoke all on function catchmenu_pos.pre_order_while_waiting(uuid,uuid,uuid,jsonb,text,text) from public;` + `grant execute ... to authenticated;`(600682 §5).

그 외 함수 본문 요소(제어흐름, 검증 로직, notify_channel 알림, ledger 이벤트, KDS 티켓 INSERT, 반환 payload, i18n)는 **변경하지 않는다**.

## §3. Forbidden (금지)

- `catchmenu_pos.create_pre_order()` 수정 금지.
- `catchmenu_pos.confirm_pre_order_arrival()` 수정 금지.
- `catchmenu_pos.bind_table_to_session()` 수정 금지.
- 카트 JSON 키 통일 금지 — `v_item->'options'` 그대로 유지(C2, Open Item e).
- `pre_order_expires_at` / `order_confirmed_at` / `session_status` 세팅 금지(예약형 B안 전용 개념).
- 함수 시그니처(인자 목록·타입·개수·기본값) 변경 금지 — 6-파라미터 불변.
- `order_status`(='CONFIRMED') / `order_channel`(기본 'KIOSK') / 주문번호 스킴('W###') 변경 금지(behavior change).
- 옵션 금액 계산 추가 금지(`options_amount=0` 유지).
- 0115/0160/0163/0164 원문 마이그레이션 파일 수정 금지(forward-only).
- 스키마 컬럼 추가/변경 금지(이번은 함수 정정만).

## §4. 정확한 변경 위치

- 파일: Stage 8에서 신규 forward 마이그레이션(현재 최신 `0167` 다음 최소 미사용 번호, 예: `0168_pre_order_while_waiting_phantom_correction.sql`).
- 단일 마이그레이션 = `CREATE OR REPLACE FUNCTION catchmenu_pos.pre_order_while_waiting(...)` 전체 + §2-2 REVOKE/GRANT.
- 새 message_catalog/error_codes 항목 불필요(기존 에러키 재사용).

## §5. Migration / Rollback

- 적용: 신규 forward 마이그레이션 1건.
- 롤백: 이론상 이전(phantom) 정의로 되돌리는 것이나, 이전 정의는 실행 불가 상태였으므로 실질 롤백 가치 없음. 문제 발생 시 추가 forward 마이그레이션으로 대응(forward-only 원칙).
- Draft Mutability(§14.5): 이 마이그레이션이 Stage 12 Human Merge 전·보호 브랜치 병합 전·공유 환경 적용 전·타 워크패킷 의존 전이면 Draft로 자유 재편집 가능; 그 중 하나라도 발생하면 이후 수정은 새 forward 마이그레이션으로만.

## §6. Stop Conditions (중단 조건)

- 라이브 `pre_order_while_waiting`의 실제 시그니처가 설계 가정(6-파라미터: uuid,uuid,uuid,jsonb,text,text)과 다를 경우 → 중단, 재확인.
- `order_items`/`orders`/`order_sessions`의 실제 컬럼이 600682 §1~§4 가정과 다를 경우(예: `menu_code_snapshot`/`pre_order_created_at`/`order_id` 부재) → 중단, 스키마 재확인.
- `menus`에 `menu_code`/`estimated_minutes` 컬럼이 없을 경우 → 중단(order_items 스냅샷 불가).
- boundary 함수(create_pre_order/confirm_pre_order_arrival/bind_table_to_session) 정의가 정정 과정에서 변경될 경우 → 중단, 롤백.
- TestPlan §3(C1) 또는 §5(Non-goals) 실패 시 → 병합 중단.

## §7. 검증 근거

[600683_TestPlan](600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md) §1~§8. 핵심: §2(크래시 없음), §3(C1 order_id/pre_order_created_at → seat/cancel 정상), §4(비교군 대조), §5(Non-goals), §6(ACL), §7(boundary 0 diff).

## §8. Risk

- 낮음. 실호출자 0건(라이브 흔적 없음)이라 회귀 대상 실사용 트래픽 없음. 변경은 단일 함수 본문 + 권한. boundary 3함수 0 diff로 격리.
- 유일한 신중 지점: `order_id`/`pre_order_created_at` 추가가 형제 함수 분기를 "활성화"하므로, seat/cancel의 사전주문 분기가 이제 실제로 실행된다 — TestPlan §3에서 그 분기의 정상 작동을 명시 검증.

## §9. Human Approval

- [ ] §2 Allowed 범위(pre_order_while_waiting 본문 + REVOKE/GRANT만) 확인
- [ ] §3 Forbidden(3개 boundary 함수 무수정, 카트 키 유지, 3개 컬럼 미세팅) 확인
- [ ] C1(order_id + pre_order_created_at 추가) 필요성 및 근거 동의
- [ ] C2(카트 키 `options` 유지 + Open Item e 이월) 동의
- [ ] PUBLIC → authenticated 권한 정정 동의
- [ ] Open Items(a~e) 후속 이월 확인

## §10. Approval Decision

- 상태: PENDING (Human 승인 대기)
- 승인자:
- 승인일:

## §11. Open Items (이월)

600682 §6/§8 및 600681 §6의 (a)~(e) 전부 이번 범위 밖으로 이월:
- (a) 공통 Pre-order Core + 2 facade 재설계.
- (b) create_pre_order→confirm_pre_order_arrival 상태게이트 모순(ORDER_CONFIRMED vs bind 게이트).
- (c) order_channel 값 정렬(KIOSK vs TABLE_QR).
- (d) conditions_met 형상 통일(A 6종 vs B 7-조건).
- (e) 카트 JSON 키 통일(A `options` vs B `selected_options`).

## §12. Snapshot Decision

- 2026-07-19: 600681/600682(Cursor+Codex 이중 독립검증 완료) 설계를 그대로 인용해 Stage 5 TestPlan/ChangeContract를 작성했다. 허용 변경은 `pre_order_while_waiting()` 본문 정정(phantom 3종 제거 + order_type→DINE_IN + order_id/pre_order_created_at 2필드 추가) + REVOKE/GRANT로 한정. 3개 boundary 함수 무수정·카트 키 유지·3개 예약형 컬럼 미세팅을 금지 항목으로 명문화. Open Items (a)~(e) 이월. Human 승인 대기(§9/§10).
