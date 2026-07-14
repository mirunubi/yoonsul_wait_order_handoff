# 600491_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role) — Track 1 (Contract Inventory)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`customer_handoff_contract_reconciliation`

## §0 배경 (ChatGPT 2차 분석 채택, Human 승인)

`BOUNDED_PARTIAL_REDESIGN_REQUIRED`로 분류 확정. 3개 경계 중 **Payment Confirmation Boundary는 `600480_confirm_payment_from_provider_overload_ambiguity`에서 이미 상세 조사 완료**(payment_ledger 7건 전수 대조, `confirm_payment_from_provider()` 오버로드 모호성, `0027` 정확성 확인 등)했으므로 이번 workpacket에서 제외한다. 이번 워크패킷은 나머지 두 경계만 다룬다:

- **B. Waiting / Order Session Boundary**
- **C. KDS Ticket Boundary**

## Track 0 — 동결 확인

이 문서 작성 기간 중 다음을 수행하지 않았다: 신규 컬럼 추가, 동일이름 함수 오버로드 추가, 상태모델 변경, 범위 밖 리팩토링. 이번 턴에 수행한 작업은 조사(라이브 DB 직접 조회)와 문서 작성뿐이며, `.sql` 파일은 생성·수정하지 않았다.

## §1 Contract Inventory — 테이블 (라이브 DB 직접 추출)

### `catchmenu_pos.order_sessions`

**Columns** (34개, 전수):

| Column | Type | Nullable | Default |
|---|---|---|---|
| id | uuid | NO | gen_random_uuid() |
| tenant_id | uuid | NO | |
| store_id | uuid | NO | |
| session_type | text | NO | |
| session_status | text | NO | 'WAITING' |
| table_id | uuid | YES | |
| order_id | uuid | YES | |
| guest_count | integer | YES | |
| guest_locale | text | NO | 'ko' |
| customer_token | text | YES | |
| wait_number | integer | YES | |
| queue_position | integer | YES | |
| session_started_at | timestamptz | NO | now() |
| arrived_at | timestamptz | YES | |
| seated_at | timestamptz | YES | |
| ordering_started_at | timestamptz | YES | |
| order_confirmed_at | timestamptz | YES | |
| payment_started_at | timestamptz | YES | |
| payment_completed_at | timestamptz | YES | |
| completed_at | timestamptz | YES | |
| cancelled_at | timestamptz | YES | |
| expires_at | timestamptz | YES | |
| pre_order_created_at | timestamptz | YES | |
| pre_order_expires_at | timestamptz | YES | |
| arrival_reliability_score | integer | YES | |
| gateway_session_id | uuid | YES | |
| toss_order_id | text | YES | |
| correlation_id | text | YES | |
| idempotency_key | text | YES | |
| business_day | date | NO | |
| business_timezone | text | NO | 'Asia/Seoul' |
| created_at | timestamptz | NO | now() |
| updated_at | timestamptz | NO | now() |
| customer_id | uuid | YES | |
| phone_hash | text | YES | |

**Constraints**: PK `order_sessions_pkey(id)`. FK → `catchmenu_store.customers(id)` ON DELETE SET NULL, `catchmenu_gateway.gateway_sessions(id)`, `catchmenu_store.dining_tables(id)`, `catchmenu_hq.tenants(id)`, `catchmenu_hq.stores(id)`. UNIQUE `(toss_order_id)`. CHECK: `chk_session_type`(`WALK_IN`/`WAITING`/`PRE_ORDER`/`KIOSK`/`TAKEOUT`/`DELIVERY`), `chk_session_status`(`WAITING`/`ARRIVAL_PENDING`/`SEATED`/`ORDERING`/`ORDER_CONFIRMED`/`PAYMENT_PENDING`/`PAYMENT_UNCERTAIN`/`COMPLETED`/`CANCELLED`/`EXPIRED`/`NO_SHOW`), `chk_session_guest_count`, `chk_session_arrival_reliability`(0-100), `chk_session_seated_after_arrived`, `chk_session_order_after_seated`, `chk_session_payment_after_order`.

**Trigger**: `trg_order_sessions_updated_at` — `BEFORE UPDATE`, calls `catchmenu_common.set_updated_at()`.

**주의 — 이번 워크패킷의 핵심**: 이 34개 컬럼 목록에 `pre_order_amount`/`table_number`/`called_at`/`call_count`/`arrival_confirmed_at`/`cancel_reason`/`no_show_at`/`memo`는 **없다**. `600492_Logic.md`의 드리프트 표 참고.

### `catchmenu_pos.orders`

**Columns** (32개): `id`/`tenant_id`/`store_id`/`session_id`/`table_id`/`order_number`/`order_type`/`order_status`/`total_amount`/`discount_amount`/`final_amount`/`order_channel`/`pos_order_number`/`delivery_order_id`/`guest_count`/`guest_locale`/`memo`/`special_requests`/`kitchen_zone_summary`/`ordered_at`/`confirmed_at`/`cancelled_at`/`completed_at`/`gateway_session_id`/`idempotency_key`/`correlation_id`/`business_day`/`business_timezone`/`created_at`/`updated_at`/`requested_pickup_at`(`600470`에서 추가)/`ready_at`(`600470`에서 추가).

**Constraints**: PK `orders_pkey(id)`. FK → `catchmenu_store.dining_tables`, `catchmenu_gateway.gateway_sessions`, `catchmenu_pos.order_sessions`, `catchmenu_hq.tenants`, `catchmenu_hq.stores`. UNIQUE `(store_id, order_number)`. CHECK: `chk_order_amounts`, `chk_order_channel`, `chk_order_status`(`PENDING`/`CONFIRMED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED` — **`'PAID'` 없음**, `600480` 조사에서 이미 확인), `chk_order_type`(`DINE_IN`/`TAKEOUT`/`DELIVERY`/`KIOSK`/`STAFF_ORDER`).

**Trigger**: `trg_orders_updated_at`.

`order_source`/`paid_at`는 이 32개 컬럼에 **없다**. `paid_at`은 이번 턴 재검색 결과 `0098`/`0076`/`0082`/`0105`/`0109`/`0114`/`0116`/`0133` 등 전부 Payment/청구/키오스크 도메인 파일에서만 등장 — `600480`의 Payment Confirmation Boundary 소관으로 확인, 이번 B/C 범위에는 포함하지 않는다.

### `catchmenu_pos.order_items`

**Columns** (28개): `id`/`tenant_id`/`store_id`/`order_id`/`menu_id`/`menu_code_snapshot`/`menu_name_snapshot`/`unit_price_snapshot`/`quantity`/`item_amount`/`selected_options`/`options_amount`/`kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot`/`item_status`/`allergen_displayed`/`allergen_locale_displayed`/`allergen_version_displayed`/`allergen_confirmed_by_customer`/`memo`/`created_at`/`updated_at`/`base_price`/`option_price_delta`/`final_price`/`customization_log`/`customization_allergen_final`/`has_customization`.

**Constraints**: PK `order_items_pkey(id)`. FK → `catchmenu_hq.tenants`, `catchmenu_pos.menus`, `catchmenu_pos.orders`, `catchmenu_hq.stores`. CHECK: `chk_order_item_price`(`unit_price_snapshot >= 0`), `chk_order_item_quantity`(`quantity > 0`), `chk_order_item_amount`(`item_amount = unit_price_snapshot * quantity + options_amount`), `chk_order_item_status`, `chk_selected_options_array`.

**Trigger**: `trg_order_items_updated_at`.

`unit_price`/`subtotal`/`is_kds_required`/`display_order`는 이 28개 컬럼에 **없다** — `600470`/`600477_Audit.md`에서 이미 확인된 별개 결함(이번 B/C 범위와 무관, Payment도 아닌 세 번째 영역이나 이미 조사 완료).

### `catchmenu_kds.kds_tickets`

**Columns** (41개): `id`/`tenant_id`/`store_id`/`order_id`/`order_item_id`/`session_id`/`payment_ledger_id`/`ticket_number`/`kds_status`/`hold_reason`/`kitchen_zone`/`target_device_id`/`priority`/`menu_name_snapshot`/`quantity_snapshot`/`estimated_minutes_snapshot`/`prep_complexity_snapshot`/`conditions_met`/`kds_queue_length_at_check`/`kitchen_load_at_check`/`capacity_check_at`/`ticket_created_at`/`first_hold_at`/`capacity_checking_started_at`/`committed_at`/`cooking_started_at`/`ready_at`/`served_at`/`completed_at`/`cancelled_at`/`manual_fallback_activated`/`manual_fallback_reason`/`manual_fallback_at`/`manual_fallback_by`/`correlation_id`/`idempotency_key`/`business_day`/`business_timezone`/`created_at`/`updated_at`/`customization_display`/`has_customization`.

**주의**: `ticket_number`는 **실존 컬럼**(`text`, `NOT NULL`)이다 — `menu_id`는 없다(`order_items.menu_id`를 통해서만 메뉴와 연결됨, `kds_tickets`는 `order_item_id` FK로 간접 참조). 이 스키마 사실은 이번 재확인에서도 그대로 유지됨 — 정정된 것은 이 사실 자체가 아니라 "어느 함수가 이 두 컬럼을 어떻게 잘못 쓰는가"였다. 정확한 위치와 결함 유형(phantom-column vs NOT NULL 누락)은 `600492_Logic.md` §1.2 참고.

**Constraints**: PK. FK → `catchmenu_pos.order_items`, `catchmenu_pos.orders`, `catchmenu_payment.payment_ledger`, `catchmenu_store.device_registry`, `catchmenu_hq.tenants`, `catchmenu_pos.order_sessions`, `catchmenu_hq.stores`. UNIQUE `(store_id, ticket_number)`. CHECK: `chk_kds_status`(`HOLD`/`CAPACITY_CHECKING`/`COMMITTED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED`/`MANUAL_FALLBACK`), `chk_kds_priority`(1-10), `chk_kds_quantity`, `chk_kds_conditions_object`, `chk_kds_committed_after_created`, `chk_kds_cooking_after_committed`, `chk_kds_ready_after_cooking`.

**Trigger**: `trg_kds_tickets_updated_at`.

### `catchmenu_store.did_display_queue` (참고용 — 오늘 스윕에서 in-scope 함수가 사용하지 않는 것으로 확인됨)

**Columns** (25개): `id`/`tenant_id`/`store_id`/`did_device_id`/`did_zone`/`queue_type`/`priority`/`order_id`/`session_id`/`order_number`/`wait_number`/`display_number`/`display_message`/`display_locale`/`call_count`/`max_call_count`/`last_called_at`/`next_call_at`/`queue_status`/`displayed_at`/`dismissed_at`/`dismissed_by_type`/`auto_dismiss_at`/`business_day`/`created_at`/`updated_at`.

**Constraints**: PK. FK → `did_devices`, `stores`, `tenants`. CHECK: `chk_queue_status`, `chk_queue_type`(`WAITING_CALL`/`PICKUP_READY`/`TABLE_READY`/`DELIVERY_READY`/`CUSTOM_MESSAGE`). **Trigger**: `trg_did_queue_updated`.

**재확인**: `0043`/`0099`/`0115`의 15개 in-scope 함수 본문을 재검색한 결과 이 테이블을 직접 참조하는 곳이 없음을 확인(참고용으로만 포함, 이번 드리프트 조사 대상 아님).

### `catchmenu_store.did_devices` (참고용, 동일)

**Columns** (22개): `id`/`tenant_id`/`store_id`/`device_id`/`did_code`/`did_name`/`zone`/`location_description`/`display_mode`/`orientation`/`resolution`/`refresh_interval_seconds`/`call_sound_enabled`/`call_repeat_count`/`call_interval_seconds`/`call_display_seconds`/`is_online`/`last_ping_at`/`current_content_id`/`brightness`/`is_active`/`created_at`/`updated_at`.

**Constraints**: PK. FK → `device_registry`, `stores`, `tenants`. UNIQUE `(store_id, did_code)`. CHECK: `chk_display_mode`, `chk_orientation`, `chk_did_zone`. **Trigger**: `trg_did_devices_updated`.

### `catchmenu_ledger.events` (이미 컬럼 100% 일치 확인됨 — 재확인)

**Columns** (28개, 이번 턴 재추출): `id`/`tenant_id`/`store_id`/`event_domain`/`event_type`/`event_version`/`subject_type`/`subject_id`/`from_state`/`to_state`/`caused_by_type`/`caused_by_id`/`caused_by_device_id`/`caused_by_agent_id`/`caused_by_task_id`/`event_payload`/`idempotency_key`/`is_replay`/`original_event_id`/`session_id`/`order_id`/`payment_id`/`kds_ticket_id`/`correlation_id`/`provider_event_id`/`business_day`/`business_timezone`/`occurred_at`/`recorded_at`.

**Constraints**: PK. FK → `stores`/`tenants`/`agent_registry`/`device_registry`/`tasks`/자기참조(`original_event_id`). CHECK: `chk_event_domain`(`session`/`order`/`payment`/`kds`/`delivery`/`inventory`/`staff`/`device`/`agent`/`recovery`/`knowledge`/`gateway`/`system`/`waiting` — `'store'` 없음, `600477_Audit.md`에서 이미 확인), `chk_event_payload_object`, `chk_event_replay_has_original`, `chk_event_type_not_blank`, `chk_event_caused_by_type`. **Trigger 없음**(append-only 설계 의도와 일치).

**재확인 결과**: 사용자님이 언급한 "이미 컬럼 100% 일치 확인됨"이 이번 턴 재추출로 그대로 재확인됨 — 새로운 불일치 없음.

## §2 Contract Inventory — 함수 (15개, 라이브 DB 직접 추출)

| 함수 | Schema | Identity Arguments | 주요 Default | Return | Source Migration |
|---|---|---|---|---|---|
| `register_waiting` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_guest_count, p_session_type, p_guest_locale, p_phone_hash, p_customer_id, p_memo, p_source, p_locale, p_correlation_id` | `p_session_type='WAITING'`, `p_source='STAFF'`, `p_locale='ko'` | jsonb | `0115` |
| `call_waiting_customer` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_table_number, p_actor_id, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `confirm_arrival` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_actor_id, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `pre_order_while_waiting` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_cart_items, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `seat_waiting_customer` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_table_number, p_actor_id, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `cancel_waiting` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_cancel_reason, p_actor_type, p_actor_id, p_locale, p_correlation_id` | `p_actor_type='CUSTOMER'`, `p_locale='ko'` | jsonb | `0115` |
| `mark_no_show` | `catchmenu_pos` | **2개 오버로드** — (a) `..., p_actor_type, p_actor_id, p_correlation_id` (b) `..., p_actor_id, p_locale, p_correlation_id` | (a) `p_actor_type='STAFF'` (b) `p_locale='ko'` | jsonb | (a) `0050` (b) `0115` — §2.1 참고 |
| `get_waiting_status` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_locale` | `p_locale='ko'` | jsonb | `0115` |
| `get_waiting_admin_view` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_locale` | `p_locale='ko'` | jsonb | `0115` |
| `get_did_display_state` | `catchmenu_store` | **2개 오버로드** — (a) `p_tenant_id, p_store_id, p_did_id, p_locale` (b) `p_tenant_id, p_store_id, p_device_id` | (a) `p_locale='ko'` (b) `p_device_id default null` | jsonb | (a) `0043` (b) `0117` — §2.1 참고 |
| `notify_customer_ready` | `catchmenu_store` | `p_tenant_id, p_store_id, p_order_id, p_notification_type, p_display_message, p_sound_alert, p_actor_type, p_actor_id, p_correlation_id` | `p_notification_type='ORDER_READY'`, `p_sound_alert=true`, `p_actor_type='SYSTEM'` | jsonb | `0043` |
| `update_did_display` | `catchmenu_store` | `p_tenant_id, p_store_id, p_device_id, p_display_mode, p_display_content, p_actor_type, p_actor_id, p_correlation_id` | `p_display_content='{}'`, `p_actor_type='STAFF'` | jsonb | `0043` |
| `get_kds_realtime_state` | `catchmenu_kds` | `p_tenant_id, p_store_id, p_locale` | `p_locale='ko'` | jsonb | `0099` |
| `get_staff_alert_feed` | `catchmenu_common` | `p_tenant_id, p_store_id, p_since, p_limit, p_locale` | `p_limit=20`, `p_locale='ko'` | jsonb | `0099` |
| `get_waiting_realtime_state` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_locale` | `p_locale='ko'` | jsonb | `0099` |

### §2.1 부수 발견 — `mark_no_show()`/`get_did_display_state()` 오버로드 존재, 이번 턴 발견

원래 사용자님이 열거한 15개 함수 목록에는 이 두 함수가 "오버로드가 있다"는 언급이 없었으나, 이번 턴 계약 추출 과정에서 **직접 발견**했다 — `600480`에서 다룬 `confirm_payment_from_provider()`/`mark_payment_uncertain()`/`authorize_kds_release()`와 **같은 계열의 패턴**(원본 함수를 나중 마이그레이션이 DROP 없이 새 시그니처로 추가)이 이 두 함수에도 존재한다:

- **`mark_no_show()`**: `0050_create_waiting_queue_rpc.sql`(원본, `p_actor_type`) vs `0115_create_waiting_pipeline_rpc.sql`(재정의, `p_actor_id`+`p_locale`) — `0063` 패치가 아니라 `0115` 자체가 새 오버로드를 추가한 것으로 확인. `0115` 내부에서 `mark_no_show(...)`를 호출하는 코드 2곳(L1329 인근, L1762 인근)이 있음 — 어느 오버로드를 겨냥하는지, 모호성이 실제로 발생하는지는 이번 Contract Inventory 범위를 넘는 별도 조사가 필요.
- **`get_did_display_state()`**: `0043_create_did_display_rpc.sql`(원본, `p_did_id`) vs `0117_create_did_pipeline_rpc.sql`(재정의, `p_device_id`) — `0117`이 자신의 새 오버로드를 3곳에서 호출.

**투명 공개**: 이 두 발견은 이번 Contract Inventory(Track 1) 작업 중 계약을 추출하다가 우연히 발견한 것이며, 사용자님의 원 배경 설명에는 없었다. 실제 호출 시 모호성이 발생하는지(named argument 겹침 여부)는 이번 문서에서 실증하지 않았다 — Contract Inventory 범위(무엇이 존재하는가)에 한정하고, `600480`과 동일한 심층 재현 조사는 별도 Open Item으로 남긴다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`
- `000001_Md_Rules.md`

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql` — B 경계(Waiting/Order Session) 9개 함수 중 8개의 소스.
- `sql/migrations/0050_create_waiting_queue_rpc.sql` — `mark_no_show()` 원본 오버로드 소스.
- `sql/migrations/0043_create_did_display_rpc.sql` — DID 관련 3개 함수 소스, `get_did_display_state()` 원본 오버로드.
- `sql/migrations/0117_create_did_pipeline_rpc.sql` — `get_did_display_state()` 재정의 오버로드 소스.
- `sql/migrations/0099_create_realtime_pipeline_rpc.sql` — C 경계(KDS Ticket) 관련 3개 함수 소스.
- `sql/migrations/0016_create_kds_tickets.sql` — `kds_tickets` 원본 DDL.
- `sql/migrations/0012_create_pos_order_sessions.sql` — `order_sessions` 원본 DDL.

### Domain Indexes

- 해당 없음.

### Excluded Rule Families

- Payment Confirmation Boundary 관련 전체(`payment_ledger`/`payment_intents`/`confirm_payment_from_provider` 등) — `600480`에서 이미 완료, 이번 문서는 명시적으로 제외.
- `600470`/`600477_Audit.md`의 `order_items`(`unit_price`/`subtotal`/`is_kds_required`/`display_order`) 결함 — 이미 별도 문서화 완료, 이번 B/C 조사 범위 밖(참고로만 인용).
- `did_display_queue`/`did_devices` — 참고용으로 계약만 추출, 이번 in-scope 15개 함수가 사용하지 않음을 확인했으므로 드리프트 분석 대상에서 제외.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600492_Logic.md`(드리프트 전수 목록 + Source of Truth 후보) 작성 진행 가능.
