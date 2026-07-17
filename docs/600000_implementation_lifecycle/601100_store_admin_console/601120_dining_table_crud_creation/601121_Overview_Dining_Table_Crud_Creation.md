# 601121_Overview_Dining_Table_Crud_Creation.md

Status: Draft
Lifecycle: Overview
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Store Admin Console
Last Updated: 2026-07-17

## Change ID

`dining_table_crud_creation`

## §0.1 요약표 (Actor / Aggregate / Includes / Excludes / Owns / Does not own)

| 구분 | 내용 |
|---|---|
| **Actor** | 매장 관리자(`OWNER`/`MANAGER`, `catchmenu_store.staff.staff_role`) — Store Admin Console 사용자 |
| **Aggregate** | `catchmenu_store.dining_tables`(단일 평면 테이블, 자식 테이블 없음, §1.1) |
| **Includes** | 테이블 마스터데이터 생성/수정/목록/활성-비활성 토글, 순수 자원 속성(`table_code`/`table_name`/`capacity`/`floor_zone`/`table_section`/`display_order`/`kds_device_id`/`did_device_id`) 전체 |
| **Excludes** | `table_status`(운영 상태, §2.8/§3), QR/NFC 할당(§2.5), 세션 바인딩/해제(§3), 물리 DELETE(§0.2) |
| **Owns** | `upsert_dining_table()`, `set_dining_table_active()`, `get_dining_table_admin_list()`(전부 신규, §2.1-§2.3/§2.7) |
| **Does not own** | `update_table_status()`, `register_table_qr()`, `release_table()`(전부 `0048`) / `bind_table_to_session()`(`0025`) / `estimate_wait_time()`(`0050`) — 전부 0 diff 경계 대상(§1.2) |

## §0.2 `table_id`(불변 식별자) vs `table_code`(표시용 라벨) — 역할 구분 (신규 확정, ChatGPT+제미나이 교차검증)

이 워크패킷 전체 설계의 전제 조건으로 명시한다: **`table_id`(uuid PK)만이 시스템 내부 참조에 쓰이는 불변 식별자다.** `order_sessions.table_id`/`orders.table_id`(§1.3의 FK 2곳)는 전부 `table_id`를 참조하지, `table_code`를 참조하지 않는다. 향후 좌석 배정/바인딩 기능(`bind_table_to_session()`, §1.7)도 `p_table_id`를 입력으로 받는다 — `table_code`가 아니다. `table_code`는 스태프가 물리적으로 인쇄/부착한 표시용 라벨일 뿐, 조인 키나 조회 키로 시스템 내부에서 쓰이지 않는다.

이 구분이 `601122_Logic.md` §1.4의 설계 판단(`table_code`를 UPDATE 절에서 편집 가능하게 허용)이 안전한 직접적 근거다 — `table_code`가 어딘가의 FK나 조인 키였다면 편집 허용은 참조 무결성 위험이었겠지만, 실제로는 순수 표시값이므로 안전하게 바꿀 수 있다. 이 전제가 깨지는 경우(예: 향후 어떤 기능이 `table_code`로 조회하기 시작하는 경우)를 대비해, 이 문서가 확립한 이 원칙을 향후 설계자가 반드시 먼저 확인해야 한다.

## §0 배경 — 발견 경위 및 조사 승계

이 워크패킷은 `601110_store_admin_sql_layer_reconciliation/`의 조사 과정에서 발견됐다가 2026-07-16 Human 결정으로 분리된 것으로, `601100_Readme_Store_Admin_Console.md` Subfolder Map에 번호만 예약된 채(`601120_dining_table_crud_creation/`, "Number reserved only — not started") 남아 있었다. 그 시점의 조사 내용(20개 컬럼 스키마, `table_code`+`capacity` 최소 생성 요구사항, 기존 운영 RPC 4종 phantom 없음 확인)은 폐기되지 않고 `601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md` §4/§5에 이관 명세로 보존됐다 — 이 문서는 그 조사를 **Master Anchor**로 승계하며, 같은 사실을 다시 조사하지 않는다(이 세션의 "동일 사실 재조사 금지" 원칙). 다만 §1 이하는 그 이관 내용에 없던 항목(FK 참조/RLS/Flutter 호출자/`bind_table_to_session`/`601113`의 forward-reference 주석 등)을 이번 턴에 직접 라이브 재확인한 결과다.

## §1 현황 — 라이브 재확인

### §1.1 스키마 — 20개 컬럼 (`sql/migrations/0010_create_store_dining_tables.sql`, 라이브 스키마와 전수 대조, 드리프트 없음 확인)

`catchmenu_store.dining_tables`:

| 컬럼 | 타입 | NOT NULL | 기본값 |
|---|---|---|---|
| `id` | uuid | Y | `gen_random_uuid()` |
| `tenant_id` | uuid | Y | (FK, RPC 컨텍스트로 항상 채워짐) |
| `store_id` | uuid | Y | (FK, 동일) |
| `table_code` | text | Y | 없음 — **관리자 입력 필수** |
| `table_name` | text | N | 없음 |
| `capacity` | int | Y | `4` |
| `floor_zone` | text | N | 없음 |
| `table_section` | text | N | 없음 |
| `display_order` | int | Y | `0` |
| `qr_code` | text | N | 없음 — `register_table_qr()` 전담 (§1.2/§2.5) |
| `nfc_tag_id` | text | N | 없음 — 동일 |
| `table_status` | text | Y | `'AVAILABLE'` — **운영 상태 projection, `update_table_status()` 전담** (§1.2/§3) |
| `current_session_id` | uuid | N | 없음 — 운영 중 채워짐, `bind_table_to_session()`/`release_table()` 전담 |
| `occupied_since` | timestamptz | N | 없음 — 동일 |
| `last_cleaned_at` | timestamptz | N | 없음 — 동일 |
| `kds_device_id` | uuid | N | 없음 — 순수 자원 속성, CRUD 파라미터 포함 (§2.4, 2026-07-17 갱신) |
| `did_device_id` | uuid | N | 없음 — 동일 |
| `is_active` | boolean | Y | `true` |
| `created_at`/`updated_at` | timestamptz | Y | `now()` |

제약: `uq_dining_table_store_code` UNIQUE(`store_id, table_code`), `chk_dining_table_capacity` CHECK(`capacity > 0`), `chk_dining_table_status` CHECK(5개 값), FK `store_id`→`catchmenu_hq.stores`/`tenant_id`→`catchmenu_hq.tenants`/`kds_device_id`·`did_device_id`→`catchmenu_store.device_registry`. **자식 테이블 없음** — `menus`의 `menu_option_groups`/`menu_option_items`와 달리 단일 평면 테이블이다.

### §1.2 기존 운영 RPC 5종 — phantom 없음, CRUD만 부재 (재확인)

`0048_create_table_management_rpc.sql`(`catchmenu_store.update_table_status()`/`get_table_floor_map()`/`register_table_qr()`/`release_table()`)과 `0050_create_waiting_queue_rpc.sql`의 `catchmenu_pos.estimate_wait_time()`(가용 테이블 수 계산에 `dining_tables`를 읽기 전용으로 참조) — 라이브 스키마와 전수 대조해 phantom 컬럼 0건 재확인. 다섯 함수 모두 **이미 존재하는 테이블 행**을 대상으로 동작한다 — 행 자체를 생성/목록/삭제하는 함수는 없다.

- `update_table_status()` — `table_status` 전이(가드: 세션 활성 시 `AVAILABLE` 전환 거부) + 렛저 이벤트. **운영 상태 전담, CRUD 대상 아님.**
- `get_table_floor_map()` — `is_active = true`인 테이블만 반환, 존 요약 포함. **관리자용 "비활성 포함 전체 목록"에는 쓸 수 없음** (§2.7 근거).
- `register_table_qr()` — QR/NFC 스토어 내 유니크 검사 + 렛저 이벤트 + SECURITY 감사 기록. **QR/NFC 전담, 건드리지 않음** (§2.5).
- `release_table()` — 세션 종료 후 상태 복귀(`CLEANING`/`AVAILABLE`) + 렛저 이벤트.
- `estimate_wait_time()` — 가용 테이블 수 집계용 읽기 전용 참조.

### §1.3 FK 참조 2곳 — 물리 삭제 불가, soft-delete 필수 (신규 확인)

```sql
-- sql/migrations/0012_create_pos_order_sessions.sql:26
table_id uuid references catchmenu_store.dining_tables(id),

-- sql/migrations/0013_create_pos_orders.sql:17
table_id uuid references catchmenu_store.dining_tables(id),
```

둘 다 `ON DELETE` 절이 없다 — PostgreSQL 기본값인 `NO ACTION`이 적용된다. 즉 `order_sessions`나 `orders`가 참조 중인 `dining_tables` 행을 물리적으로 `DELETE`하면 FK 위반으로 즉시 거부된다. `is_active` 컬럼이 이미 있으므로(§1.1), 논리적 비활성화(`is_active = false`)가 유일하게 안전한 "삭제" 경로다 — 메뉴(`menus.is_active`, `menu_categories.is_active`)와 동일한 기존 관례.

### §1.4 RLS — 이미 존재, 신규 정책 불필요 (재확인)

```sql
-- sql/migrations/0022_create_rls_policies.sql:163-171
create policy dining_tables_store_isolation
  on catchmenu_store.dining_tables
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );
```

`for all`이므로 `SELECT`/`INSERT`/`UPDATE`/`DELETE` 전부에 적용되고, `WITH CHECK`를 별도로 지정하지 않았으므로 PostgreSQL이 `USING` 절을 `WITH CHECK`에도 동일 적용한다 — 신규 CRUD 함수가 `SECURITY DEFINER`로 실행되긴 하지만(RLS를 우회), 이 정책 자체는 이미 완전하며 이번 워크패킷에서 손댈 필요가 없다.

### §1.5 `601113_TestPlan.md:548`의 "dining_tables' deactivate pattern" 주석 — 실제로는 미구현 (정정 필요 사실 기록)

```
-- 601113_TestPlan_Store_Admin_Menu_Rpc_Correction.md:547-549
-- Directly flip a second menu's is_active to false — no public RPC does this
-- for menus (unlike dining_tables' deactivate pattern); this test flips it
-- directly against the table for setup purposes only.
```

이번 턴 직접 확인: `sql/migrations/*.sql` 전체에서 `dining_tables`의 `is_active`를 `false`로 설정하는 함수는 **존재하지 않는다**(`grep`으로 전수 검색, 매치 0건). 즉 위 주석의 "unlike dining_tables' deactivate pattern"은 **현재 시점에 사실이 아니다** — 이 워크패킷(`601120`)이 만들 예정인 패턴을 마치 이미 존재하는 것처럼 앞당겨 서술한 forward-reference였다. `601113`는 이미 승인·구현·검증이 끝난 별개 워크패킷 문서이므로 이 문서를 소급 수정하지는 않지만(범위 밖), 이 사실을 여기 명확히 기록해 향후 이 주석을 읽는 사람이 오해하지 않도록 한다 — §2.6이 실제로 그 패턴을 만든다.

### §1.6 Flutter 호출자 0건 (신규 확인)

`catchmenu_app/lib/` 전체에서 `table_status`/`table_floor_map`/`register_table_qr`/`release_table`/`dining_table` 키워드 검색 — 매치 0건. `601111_Overview.md` §4가 이미 "실호출자 0건"이라 기록한 것과 일치, 이번 CRUD 신설도 동일하게 영향받는 실사용 클라이언트가 없다.

### §1.7 `bind_table_to_session()` — 별도 함수, 범위 밖 (신규 확인)

```sql
-- sql/migrations/0025_create_session_rpc.sql:327-334
create or replace function catchmenu_pos.bind_table_to_session(
  p_tenant_id uuid, p_store_id uuid,
  p_session_id uuid, p_table_id uuid, ...
)
```

`p_table_id`를 **입력**으로 받아 이미 존재하는 테이블 행을 세션에 바인딩하는 함수다 — "테이블 레코드 자체를 생성"하는 이번 CRUD 갭과는 근본적으로 다른 기능(Late Binding의 바인딩 단계이지 마스터데이터 등록 단계가 아님). 이번 워크패킷은 이 함수를 전혀 다루지 않는다.

## §2 설계 방향 — 7개 확인 항목

### §2.1 함수명/구조 컨벤션 — Store Admin Console 패턴(`upsert_X`/`get_X_admin_list`/`set_X_status`) 채택

**근거**: `601120`은 `601100`(Store Admin Console) 도메인 산하이고, 그 형제 워크패킷인 `601110`/`601140`이 이미 `upsert_menu()`/`get_menu_admin_list()`/`set_menu_status()` 패턴을 이 도메인의 표준으로 확립했다. 반면 `0048`의 `update_table_status()`/`register_table_qr()`/`release_table()`은 **이미 존재하는 테이블의 운영 상태를 조작**하는 함수들이지, 관리자가 테이블 마스터데이터를 등록/수정하는 함수가 아니다 — 기능 범주 자체가 다르므로 `0048`의 명명 관례를 CRUD 함수에 억지로 맞출 이유가 없다. 도메인 내부 일관성(같은 `601100` 산하 문서/함수를 다루는 사람이 하나의 명명 규칙만 학습하면 되는 것)이 `0048`과의 표면적 유사성보다 더 큰 가치가 있다고 판단한다.

같은 이유로 **에러 응답 형식**도 `0110`의 관례(`catchmenu_common.build_error_response(p_error_key, p_locale, ...)` + `message_catalog` i18n)를 따른다 — `0048`은 `jsonb_build_object('success', false, 'error_key', ...)`를 직접 쓰고 `p_locale` 파라미터조차 없다. `601100` 산하 신규 함수가 `0048` 스타일의 비-i18n 에러를 섞어 쓰면 관리자 화면에서 일관되지 않은 에러 메시지가 나올 위험이 있다.

### §2.2 신규 마이그레이션 파일로 분리 (0110에 편입하지 않음)

**근거**:

1. `0110`의 헤더 목적 서술("소형 매장 관리자 페이지용... 메뉴 등록/수정/품절 관리. 직원 등록/PIN 설정. 영업시간/휴무일 설정. POS/배달앱 연동 설정.")과 `Creates` 목록(10개 함수) 어디에도 `dining_tables`가 없다 — 원래 설계 범위에 없었다.
2. `0110`은 현재 **두 개의 활성 워크패킷**(`601110` — 이미 Stage 11 감사 완료, `601140` — 이번 세션에 Stage 9 검증까지 완료)이 각각 정밀한 Allowed/Forbidden 경계로 다루고 있는 파일이다. `601140_ChangeContract.md` §1.2는 `upsert_menu()`/`upsert_menu_core()` 외의 모든 `0110` 함수를 "no-regression preservation only, 0 diff"로 못박았다 — 세 번째 워크패킷이 같은 파일에 완전히 새로운 함수를 추가하면, 이 세션이 반복 확립해 온 "워크패킷마다 깨끗한 파일/함수 경계"라는 원칙과 충돌하고, 향후 `0110`의 `git diff` 경계 검증이 세 워크패킷 몫을 뒤섞어 해석해야 하는 부담을 만든다.
3. 코드베이스 자체의 기존 관례가 "테이블-도메인 하나당 전용 파일"이다 — `dining_tables` 운영 RPC 4종이 이미 `0110`이 아니라 전용 파일 `0048_create_table_management_rpc.sql`에 있다. 신규 CRUD도 같은 테이블 도메인이므로 이 관례를 따르는 것이 자연스럽다.

**결론**: 신규 파일. 현재 `sql/migrations/`의 최신 번호는 `0161`(확인, `0160_call_waiting_customer_contract_recovery.sql`/`0161_mark_no_show_overload_and_redesign.sql`)이므로, 다음 가용 번호는 `0162`다 — 단, 이 문서 작성 시점과 실제 Stage 8 구현 시점 사이에 다른 워크패킷이 `0162`를 선점할 수 있으므로, 파일명/번호는 Stage 5(ChangeContract)에서 구현 직전 재확인해 확정한다(잠정: `0162_create_dining_table_admin_rpc.sql`).

### §2.3 `upsert_dining_table()` 단일 함수 — `upsert_menu()`/`upsert_menu_core()` 같은 wrapper/core 분리 불필요

`upsert_menu()`가 `upsert_menu_core()` + `sync_menu_option_groups_core()` + `sync_menu_option_items_core()`로 3계층 분리된 이유는 **자식 테이블(옵션 그룹/아이템)을 같은 트랜잭션에서 동기화**해야 했기 때문이다(`601112_Logic.md` §2.2). `dining_tables`는 자식 테이블이 없는 단일 평면 테이블(§1.1)이므로 조율할 대상 자체가 없다 — `p_table_id default null`로 생성/수정을 분기하는 **단일 함수 하나**로 충분하다. `upsert_menu()`/`upsert_menu_core()`의 public-wrapper/internal-helper 분리는 애초에 3계층 오케스트레이션을 위한 구조였지, 그 자체가 보안 목적의 관례는 아니었다(참고: `601142_Logic.md` §1.2/§3(a)가 다룬 `proacl`/직접 호출 문제는 "내부 헬퍼가 별도로 존재할 때" 생기는 리스크이지, "함수가 하나뿐일 때"는 애초에 발생하지 않는 문제다) — 단일 함수로 설계하면 그 문제 자체가 원천적으로 없다.

### §2.4 파라미터 시그니처 — 오늘 이 세션의 핵심 교훈을 신규 함수 설계에 선제 적용

`601140_allergen_info_and_sibling_overwrite_correction`(오늘 이 세션이 조사·설계·구현·검증까지 마친 워크패킷)의 결론은 명확하다: **부분 업데이트에서 생략 가능해야 하는 필드는 처음부터 `default null` + `coalesce(p_x, x)`로 설계해야 한다** — non-null 하드코딩 기본값을 시그니처에 넣으면, 생략 시 조용히 리셋되는 결함 클래스가 생긴다. `601141_Overview.md` §3이 이미 "`601120` 착수 시 이 원칙을 반영해야 한다"고 교차 참조로 남겨 둔 바로 그 지점이다 — 이번이 그 착수 시점이다.

원칙: `p_table_id`(분기 셀렉터)를 제외한 모든 컬럼 대응 파라미터는 **생성(신규 행)과 수정(기존 행) 양쪽에서 다르게 처리**한다 — 생성 시 생략되면 스키마 기본값/합리적 기본값, 수정 시 생략되면 **기존 값 보존**(`coalesce(p_x, x)`). `price`/`description_ko`가 `upsert_menu_core()`에서 이미 이 패턴이었던 것과 동일하다(`601142_Logic.md` §1.1).

| 파라미터 | 매핑 컬럼 | 필수 여부 | 생성 시 생략 | 수정 시 생략 |
|---|---|---|---|---|
| `p_table_code` | `table_code` | **생성 시 필수**(NOT NULL, 스키마 기본값 없음) | 에러(`table_code_required`) — 아래 근거 | 기존 값 보존 |
| `p_capacity` | `capacity` | 선택 | `4`(스키마 기본값) | 기존 값 보존 |
| `p_table_name` | `table_name` | 선택 | `NULL` 그대로 저장 | 기존 값 보존 |
| `p_floor_zone` | `floor_zone` | 선택 | `NULL` | 기존 값 보존 |
| `p_table_section` | `table_section` | 선택 | `NULL` | 기존 값 보존 |
| `p_display_order` | `display_order` | 선택 | `0`(스키마 기본값) | 기존 값 보존 |
| `p_kds_device_id` | `kds_device_id` | 선택 | `NULL` 그대로 저장 | 기존 값 보존 |
| `p_did_device_id` | `did_device_id` | 선택 | `NULL` 그대로 저장 | 기존 값 보존 |

**(2026-07-17 갱신, Human 결정 — ChatGPT+제미나이 교차검증, 재논의 금지)** `kds_device_id`/`did_device_id`는 이 문서의 이전 초안에서 "디바이스 연결은 QR/NFC처럼 별도 단계로 미루자"고 제안했으나(§3 참고, 이번 갱신으로 그 제안은 철회됨), 이번 교차검증에서 이 두 컬럼도 "순수 자원 속성"으로 재분류되어 CRUD 파라미터에 포함하기로 확정됐다. QR/NFC를 `register_table_qr()`에 남겨둔 이유(§2.5 — 스토어 내 유니크 검사라는 복잡한 검증 로직이 있어 중복 구현 위험)와 달리, `kds_device_id`/`did_device_id`는 `catchmenu_store.device_registry(id)`를 참조하는 단순 nullable FK일 뿐 유니크성이나 상태 검사 같은 부가 로직이 없다 — 단순 pass-through 값이므로 별도 함수로 분리할 복잡성 자체가 없다는 것이 재분류의 근거다. QR/NFC는 여전히 §2.5의 이유로 제외된다.

`p_table_code`를 생성 시 자동 생성(`upsert_menu_core()`의 `MENU-0001` 같은 `v_auto_code` 패턴)하지 않는 이유: 메뉴 코드는 내부 식별자 성격이 강해 자동 생성 후 관리자가 나중에 바꿔도 무방하지만, 테이블 코드(`table_code`)는 물리적으로 테이블에 인쇄/부착되는 식별자로 QR/NFC 및 현장 스태프 커뮤니케이션에 직접 쓰인다(`0010`의 테이블 코멘트 참고) — 자동 생성된 임의 코드를 관리자가 즉시 알아채지 못하고 방치할 위험이 자동 생성의 편의보다 크다고 판단한다. 대신 생성 시 생략되면 명확한 검증 에러(`table_code_required`)로 즉시 알린다.

`table_code` 중복 검사는 `menu_code_duplicate`와 동일한 성격의 사전 검증이 필요하다 — `uq_dining_table_store_code` UNIQUE 제약이 최종 방어선이지만, 사용자 친화적 에러 메시지(`table_code_duplicate`)를 위해 명시적 `exists(...)` 체크를 `menu_code_duplicate`(`601112_Logic.md` §2.2)와 동일한 패턴으로 둔다. **(중요, 오늘 이 세션의 또 다른 핵심 교훈 선제 적용)** `601114_ChangeContract.md` §2.10.1(Slice 3, 카테고리 행 누수 수정)이 증명했듯, 검증 체크는 **모든 DML보다 먼저** 실행되어야 한다 — Logic.md §1.4에서 이 순서를 명시적으로 설계한다.

`table_status`/`current_session_id`/`occupied_since`/`last_cleaned_at`/`qr_code`/`nfc_tag_id`는 이 함수의 파라미터에 **포함하지 않는다** — 근거는 §2.5/§2.6과 §3. (`kds_device_id`/`did_device_id`는 위 표와 바로 위 문단대로 **포함**한다 — 과거 초안에는 이 목록에 있었으나 2026-07-17 갱신으로 재분류됐다.)

### §2.5 QR/NFC — `register_table_qr()` 전담 유지, `upsert_dining_table()`은 건드리지 않음

**근거**:

1. `register_table_qr()`은 이미 스토어 내 유니크 검사(`is_active=true` 스코프) + 렛저 이벤트 + `SECURITY`급 감사 기록(`catchmenu_audit.append_audit_record`, `p_audit_category := 'SECURITY'`)까지 구현된, 완결된 함수다(§1.2). QR/NFC는 `0010`의 테이블 코멘트("특허1: 고객 단말 기반 대기→장바구니→테이블 Late Binding의 물리적 앵커")가 명시하듯 단순 메타데이터가 아니라 보안·특허 연관 기능이다.
2. `upsert_dining_table()`에도 QR/NFC 파라미터를 넣으면, 유니크 검사 로직이 두 함수에 중복 구현되고 시간이 지나며 서로 다르게 진화할 위험(오늘 세션이 반복 목격한 "같은 불변식을 지키는 두 개의 쓰기 경로" 문제와 같은 형태)이 생긴다.
3. 이미 이 코드베이스의 확립된 관례다 — `601111_Overview.md` §4가 이미 "QR/NFC도 생성과 분리된 `register_table_qr()`로 이미 분리돼 있음"을 "단계별 등록" 패턴의 근거로 지목했다.

**결론**: CRUD는 순수 메타데이터(§2.4 표의 8개 필드 — `table_code`/`table_name`/`capacity`/`floor_zone`/`table_section`/`display_order`/`kds_device_id`/`did_device_id`)만 다루고, QR/NFC 등록/해제는 계속 `register_table_qr()`을 통해서만 이뤄진다.

### §2.6 활성화/비활성화 — 별도 함수로 분리, 양방향(`set_dining_table_active`) 권장

작업 지시문이 예시로 든 "`deactivate_dining_table()`"이라는 이름을 그대로 채택할지, 양방향 함수로 설계할지 검토가 필요했다. **먼저 정정할 점**: 작업 지시문은 이를 "`set_menu_status()`처럼 분리"라고 비유했으나, 라이브 확인 결과 이 비유는 정확하지 않다 — `set_menu_status()`는 메뉴의 **`menu_status`(AVAILABLE/SOLD_OUT/HIDDEN/DISCONTINUED) enum 컬럼**을 관리하는 함수이지, `menus.is_active` 불리언을 관리하는 함수가 아니다. `601113_TestPlan.md:547`의 주석이 정확히 지적하듯, 메뉴의 `is_active`를 토글하는 공개 RPC는 **메뉴 쪽에도 존재하지 않는다**(§1.5). 즉 이번에 설계할 함수는 `set_menu_status()`의 유사물이 아니라, 메뉴 쪽에도 아직 없는 "is_active 토글 RPC" 갭을 `dining_tables`에서 먼저 메우는 것이다 — `upsert_dining_table()`과는 분리하되(작업 지시문의 핵심 요구와 일치), 이름과 설계는 이 정정된 이해를 반영한다.

**권장**: `set_dining_table_active(p_table_id, p_is_active boolean, ...)` — 단방향 `deactivate_dining_table()`이 아니라 양방향으로 설계한다. 근거: `is_active=false`는 FK 보호(§1.3) 때문에 물리 삭제 대신 쓰는 논리적 삭제이지만, "잘못 비활성화한 테이블을 되살리는" 재활성화도 정당한 운영 시나리오다(예: 스태프 실수, 리모델링 후 재사용) — 단방향 함수만 두면 재활성화 경로가 아예 없어지는 새로운 갭을 만들게 된다. 함수 하나로 두 방향을 모두 좁게 커버하는 편이, `activate_dining_table()`/`deactivate_dining_table()` 두 함수로 쪼개는 것보다 API 표면을 작게 유지한다(§2.7이 이미 세 번째 신규 함수를 요구하므로, 불필요하게 네 번째까지 늘리지 않는다).

**최종 채택 여부**: Human 결정 대상으로 남긴다(§6 Open Item).

### §2.7 `get_dining_table_admin_list()` 신설 확정

`get_table_floor_map()`은 `is_active = true`인 행만 반환한다(§1.2, `0048:239-246`) — 관리자가 "비활성화한 테이블도 포함해 전체 목록을 보고, 필요하면 재활성화"하려면 이 필터가 없는 별도 함수가 필요하다. `get_menu_admin_list()`(활성/비활성 메뉴 모두 반환)와 대응되는 존재로, 이름도 그 관례를 따른다.

### §2.8 활성 세션 가드 — 확정 사항 (신규, ChatGPT+제미나이 교차검증, 재논의 금지)

`current_session_id`가 채워진(또는 `order_sessions`/`orders`가 실제로 참조 중인) 테이블에 대해 CRUD가 어떤 동작을 허용/금지할지 세 가지 규칙을 확정한다 — 전부 물리 삭제 금지(§0.2)와 같은 이유: 활성 세션이 걸린 테이블은 다른 어딘가에서 실시간으로 참조되고 있으므로, 관리자의 메타데이터 편집이 그 실시간 참조를 조용히 무너뜨리면 안 된다.

1. **비활성화 금지** — `set_dining_table_active(p_is_active := false)`는 활성 세션이 있는 테이블에 대해 거부한다(이미 이전 초안에도 있던 가드, 이번 확정으로 재확인).
2. **`capacity` 축소 제한(신규)** — 활성 세션이 있는 테이블의 `capacity`를 현재 값보다 **줄이는** `upsert_dining_table()` 호출은 거부한다. 늘리는 것은 막지 않는다. **(2026-07-17 정정, 검증 지적)** 판단 기준은 실제 착석 인원(`order_sessions.guest_count`)이 아니라 **테이블에 이미 저장된 `capacity` 값 자체**다 — `601122_Logic.md` §1.2의 SQL이 `p_capacity < v_existing.capacity`만 비교하고 `guest_count`는 참조하지 않는다. 즉 "착석 인원 실측과 무관하게, 활성 세션 중에는 어떤 용량 축소도 보수적으로 차단한다"는 정책이지, "착석 인원보다 작아지는 것만 막는다"는 정밀한 정책이 아니다. 후자(실측 `guest_count` 기준)로 정교화할지는 Open Item (g)로 남긴다(`601122_Logic.md` §8 (g)).
3. **이름 변경은 허용하되 감사기록 필수(신규)** — `table_name` 변경은 활성 세션 여부와 무관하게 항상 허용한다(라벨 교정처럼 위험이 낮은 편집). 다만 활성 세션이 걸린 상태에서의 변경은 성공하더라도 `catchmenu_audit.append_audit_record()`로 별도 감사 기록을 남긴다 — 실패 시에만 기록하는 §1.5/§2의 예외 핸들러 감사와는 다른, **성공 경로의 예방적 감사**다(`register_table_qr()`의 성공-경로 감사 호출과 같은 성격, §1.2).

`current_session_id` 프로젝션 컬럼 하나만 믿지 않고, `update_table_status()`(`0048:73-94`)가 이미 하는 것과 동일하게 `catchmenu_pos.order_sessions.session_status`를 비종료 상태(`COMPLETED`/`CANCELLED`/`EXPIRED`/`NO_SHOW` 아님)로 재확인하는 이중 검사를 세 가드 모두에 적용한다 — `0010`의 테이블 코멘트 자체가 "`table_status`/`current_session_id`는 projection convenience 컬럼, 불일치 감지 시 이벤트 재생으로 복구"라고 명시하므로, 이 프로젝션 컬럼만으로 중요한 결정(비활성화/정원축소 차단)을 내리는 것은 근거가 약하다고 판단한다. 정확한 SQL은 `601122_Logic.md` §1.4a/§2로 구체화한다.

## §3 범위 밖 확인

- **`bind_table_to_session()`** — §1.7, 세션 바인딩은 완전히 다른 기능, 손대지 않음.
- **`table_status`(운영 상태) — 확정 사항, ChatGPT+제미나이 교차검증, 재논의 금지**: CRUD 함수(`upsert_dining_table()`/`set_dining_table_active()`/`get_dining_table_admin_list()`)는 `table_status`(`AVAILABLE`/`OCCUPIED`/`RESERVED`/`CLEANING`/`BLOCKED`)를 **절대 직접 쓰지 않는다** — 이 컬럼은 `update_table_status()`(세션-활성 가드 + 렛저 이벤트까지 갖춘 전담 함수, §1.2)의 배타적 소유다. `upsert_dining_table()`은 생성 시 스키마 기본값(`'AVAILABLE'`)만 쓰고(컬럼 자체를 INSERT 목록에서 생략, `601122_Logic.md` §1.3), 파라미터로 노출하지 않는다. §2.8의 세 가드(비활성화 금지/정원축소 제한/이름변경 감사)는 `table_status`를 **쓰지** 않고 **읽기만** 한다는 점에서 이 원칙과 충돌하지 않는다 — 활성 세션 여부를 판단하는 데만 참조한다.
- **`current_session_id`/`occupied_since`/`last_cleaned_at`** — `update_table_status()`/`release_table()`/`bind_table_to_session()`이 전담하는 순수 운영 런타임 컬럼, CRUD 파라미터에 포함하지 않는다. (§2.8의 가드는 이 컬럼들을 읽기만 하며 쓰지 않는다 — 위와 동일한 구분.)
- **`0048`의 4개 함수 자체** — phantom 없음 확인됨(§1.2), 이번 워크패킷은 이들의 본문을 전혀 수정하지 않는다.
- **물리 `DELETE`** — 어떤 신규 함수도 `dining_tables` 행을 물리적으로 삭제하는 경로를 제공하지 않는다(§1.3의 FK 보호, §0.2에서 재확인). `is_active = false`가 유일한 논리적 삭제 경로다.

## §4 영향 범위 요약

- **결함 클래스**: 없음 — 이 워크패킷은 버그 수정이 아니라 완전히 부재했던 CRUD 계층의 신설이다.
- **실호출자**: 0건(§1.6) — 신규 함수이므로 기존 호출자에 대한 회귀 위험 자체가 없다.
- **의존 관계**: `dining_tables`는 단일 평면 테이블(§1.1)이라 관계형 동기화 설계가 불필요 — `601112_Logic.md`의 `menu_options` 3계층 설계보다 훨씬 단순하다.
- **위험**: FK 보호(§1.3)를 무시하고 물리 DELETE를 허용하는 실수, `table_status`/QR/NFC처럼 이미 전담 함수(`update_table_status()`/`register_table_qr()`)가 있는 컬럼을 새 함수가 중복 소유하려는 설계 — 둘 다 §2.5/§3에서 명시적으로 차단했다. (`kds_device_id`/`did_device_id`는 이런 전담 함수가 애초에 없었으므로 이 위험에 해당하지 않는다 — §2.4가 CRUD로 포함시킨 근거이기도 하다.)

## §5 TestPlan 영향 예고 (상세 설계는 TestPlan 단계 몫)

- 신규 함수이므로 `601113_TestPlan.md`처럼 "기존 테스트 회귀 없음"을 검증할 대상 자체가 없다 — 새 TestPlan 문서(`601123`)가 전부 신규 테스트로 구성된다.
- `0048`의 4개 함수 + `estimate_wait_time()`은 `0 diff` 경계 검증 대상(§1.2, 이번 워크패킷이 전혀 건드리지 않음).
- 최소 커버리지 후보(TestPlan 단계에서 확정): 신규 생성(`table_code` 필수/중복 검증 포함), 부분 수정 시 생략 필드 보존(§2.4 표 전체), `set_dining_table_active()`(또는 최종 채택된 이름)의 양방향 동작, `get_dining_table_admin_list()`의 비활성 포함 여부, FK 보호로 인한 물리 DELETE 시도 시 실패 확인(참고용, 이 워크패킷은 DELETE 경로 자체를 제공하지 않으므로 직접 삭제 SQL로만 확인 가능).

## §6 Open Items

(a) §2.6 — `set_dining_table_active()`(양방향, 권장) vs `deactivate_dining_table()`(단방향, 작업 지시문 원안) 최종 채택은 Human 결정.
(b) §2.2 — 실제 마이그레이션 파일 번호(잠정 `0162`)는 Stage 5(ChangeContract) 착수 시점에 재확인 필요 — 그 사이 다른 워크패킷이 선점할 수 있음.
(c) `get_dining_table_admin_list()`의 정확한 반환 JSON 구조(어떤 필드를 포함할지, `get_table_floor_map()`과 얼마나 필드를 공유할지)는 Logic 단계에서 구체화.
(d) `0044_create_menu_management_rpc.sql`류의 고객/키오스크 대면 읽기 경로가 `dining_tables`를 참조하는지는 이번 조사에서 확인하지 않았다 — 필요시 Logic/TestPlan 단계에서 확인.
(e) `capacity`가 스키마 기본값(4)이 있음에도 `601111_Overview.md` §4가 "실사용상 명시 입력이 자연스럽다"고 판단한 것은 UX 권고이지 강제 조건이 아니다 — §2.4는 이를 존중해 생략 가능하되 기본값 4로 생성되도록 설계했다. 이 판단이 실제 관리자 화면 UX와 맞는지는 이 워크패킷 범위 밖(Flutter 클라이언트 미착수).
(f) **[정정, 2026-07-17, 3개 검증자(Cursor/ChatGPT/제미나이) 지적 — 이전 버전의 "seat_waiting_customer() 미존재" 주장은 오류였다, 아래로 정정]** 이전 버전은 코드베이스 전체 `sql/migrations/*.sql`에 대해 `create or replace function\s+catchmenu_\w+\.seat_waiting_customer`(단일 라인 매칭) 패턴으로만 검색해 "실제 함수로는 존재하지 않는다"고 결론 냈다 — 이 검색 방법 자체가 결함이었다: 이 코드베이스는 `create or replace function`과 실제 함수명을 **두 줄로 나눠 쓰는 관례**(`0110`/`0048`/`0025` 등 전반에서 이미 확인된 패턴)를 쓰는데, 단일 라인 정규식은 이 형태를 놓친다. 이번 턴 정정 검색(오프셋 지정 직접 읽기)으로 **`catchmenu_pos.seat_waiting_customer()`가 `sql/migrations/0115_create_waiting_pipeline_rpc.sql:988-1006`에 실제로 존재함을 확인했다**:

```sql
-- 0115:988-997
create or replace function
  catchmenu_pos.seat_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
```

**더 심각한 확정 사실(같은 턴에 라이브 스키마와 함수 본문을 직접 대조해 발견)**: `catchmenu_pos.order_sessions`의 실제 컬럼은 `table_id`(uuid) 하나뿐이고 `table_number` 컬럼은 **존재하지 않는다**(`information_schema.columns` 라이브 조회로 확인). 그런데 `seat_waiting_customer()`의 본문(0115:1049-1057)은:

```sql
update catchmenu_pos.order_sessions
set
  session_status = 'SEATED',
  table_number = coalesce(
    p_table_number, table_number
  ),
  ...
```

**존재하지 않는 `table_number` 컬럼에 직접 쓰기를 시도한다** — 이 함수는 "스키마 drift 가능성"이 아니라 **호출될 때마다 `column "table_number" does not exist` 런타임 에러로 100% 실패하는, 현재 완전히 깨진 함수**임이 확정됐다(이번 턴에는 이 사실을 기록만 하며 수정하지 않는다 — 대상 파일 `0115`가 `601120`의 Allowed 범위 밖이고 `.sql` 수정 자체가 이번 턴 금지 사항이다). 또한 `0115_create_waiting_pipeline_rpc.sql` 전체에서 `table_id`/`dining_tables` 키워드가 단 한 번도 등장하지 않는다 — 즉 이 함수는 (컬럼명이 고쳐지더라도) `p_table_number`(텍스트, 아마 `dining_tables.table_code`를 가리키려는 의도로 추정)를 실제 `dining_tables.id`(= `order_sessions.table_id`가 참조하는 진짜 FK 대상)로 변환하는 조회 로직 자체가 없다 — 컬럼명 정정만으로는 고쳐지지 않는 더 깊은 설계 공백이다.

**Open Item 재정의**: "Staff Seating And Table Assignment Orchestration Contract"(가칭) 후속 워크패킷은 이제 다음을 포함해야 한다 — (1) `seat_waiting_customer()`(`0115`, 방금 확인한 `table_number` phantom-column 크래시 + `table_id` 변환 로직 부재)/`bind_table_to_session()`(`0025`, §1.7, `p_table_id` 정상 사용)/`call_waiting_customer()`(`0160`, 라이브 확인 존재)/`get_table_floor_map()`(`0048`, §1.2) 네 함수의 책임 분담과 호출 순서 확정, (2) `seat_waiting_customer()`의 `p_table_number` 파라미터를 `p_table_id`로 교체하거나 `dining_tables.table_code`→`id` 조회 단계를 추가하는 실제 수정. `catchmenu_app/lib/features/staff/README.md:15`("착석/테이블 배정"을 허용 동작으로 명시)가 이 넷 중 어느 경로를 가리키는지도 이 후속 워크패킷에서 확정해야 한다. `601120`은 테이블 **마스터데이터** CRUD만 다루므로 이 오케스트레이션 계약/크래시 수정 미착수가 이 워크패킷의 착수를 막지 않는다 — 신규 함수 3개(§0.1 Owns) 어디도 세션 바인딩/착석 로직을 갖지 않기 때문이다. 다만 `upsert_dining_table()`/`set_dining_table_active()`가 만드는 `table_id`가 그 후속 워크패킷의 앵커이자 `seat_waiting_customer()`가 궁극적으로 참조해야 할 값이므로(§0.2), 후속 워크패킷 착수 시 이 문서를 Master Anchor로 참조해야 한다. 이 발견은 실제로 크래시하는 라이브 결함이므로, `601120`보다 우선순위가 높은 후속 워크패킷 후보로 판단한다(권고, 최종 우선순위는 Human 결정).

(g) **[신규, 경미, 검증 지적 — 기록만, 이번 정정에서 수정하지 않음]** §0.2의 "`table_code`는 시스템 내부 조인/조회 키로 쓰이지 않는다"는 표현이 절대적으로 과장됐을 수 있다 — 이번 조사는 `order_sessions.table_id`/`orders.table_id`(§1.3)와 `bind_table_to_session()`의 시그니처(§1.7)만 직접 확인했을 뿐, 저장소 전체에서 `table_code`로 `dining_tables`를 조회/필터링하는 다른 함수나 클라이언트 코드가 없는지 전수 검색하지는 않았다. 향후 이 전제를 근거로 중요한 결정(예: `table_code` 편집 허용 최종 확정, §8 (b))을 내리기 전에 전수 재검색이 필요하다.
(h) **[신규, 경미, 검증 지적 — 기록만]** 세 신규 함수의 응답 JSON 필드명이 일관되지 않는다 — `upsert_dining_table()`/`set_dining_table_active()`는 `'table_id'`를 쓰는 반면(`601122_Logic.md` §1.5/§2), `get_dining_table_admin_list()`의 개별 테이블 객체는 `get_table_floor_map()`의 기존 관례를 따라 `'id'`를 쓴다(`601122_Logic.md` §3). 의도적 절충(쓰기 함수와 목록 함수의 관례를 각각 따름)이었으나, 명시적으로 논의된 적은 없다 — TestPlan/ChangeContract 단계에서 통일 여부를 결정해야 한다.
(i) **[신규, 경미, 검증 지적 — 기록만]** §2.8 항목 3(활성 세션 중 필드 변경 시 예방적 감사)이 `table_name` 변경에만 적용되고(`601122_Logic.md` §1.4), 마찬가지로 편집 가능하게 설계한 `table_code`(§1.4/§8 (b)) 변경에는 적용되지 않는다 — 오히려 `table_code`는 스태프/고객이 물리적으로 참조하는 라벨이라 활성 세션 중 바뀌면 `table_name`보다 혼란 위험이 더 클 수 있다. 이번 정정에서는 반영하지 않고 기록만 한다.
(j) **[신규, 경미, 검증 지적 — 기록만]** §2.8의 활성 세션 가드(비활성화 금지/`capacity` 축소 제한)는 `current_session_id`+`order_sessions.session_status` 조합만 확인한다(`601122_Logic.md` §1.2/§2) — §1.3이 확인한 두 번째 FK인 `orders.table_id`(주문이 `current_session_id` 없이 테이블을 직접 참조하는 경우가 있는지)는 이 가드의 판단 근거에 전혀 포함되지 않는다. 그런 케이스가 실제로 존재하는지, 존재한다면 가드가 놓치는 시나리오인지는 조사하지 않았다.
(k) **[신규, 경미, 검증 지적 — 기록만]** `kds_device_id`/`did_device_id`(§2.4)를 `upsert_dining_table()`에 포함시켰지만, `601122_Logic.md`의 설계는 이 값이 실제로 `catchmenu_store.device_registry`에 존재하는 행을 가리키는지 사전에 사용자 친화적으로 검증하지 않는다 — `table_code_duplicate`류의 명시적 `exists(...)` 사전 확인 없이, 스키마 FK 제약 위반 시의 원본(비친화적) Postgres 에러에 그대로 의존한다(§1.5의 `EXCEPTION` 핸들러가 잡아 감사 기록은 남기지만, 사용자에게 친절한 에러 키를 반환하지는 않는다).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md` §4/§5 — 이 워크패킷의 직접 출발점(최초 이관 조사).

### Full Rules Required

- `sql/migrations/0010_create_store_dining_tables.sql` — 스키마 전체(20개 컬럼, 제약, 인덱스, 코멘트).
- `sql/migrations/0048_create_table_management_rpc.sql` — 기존 운영 RPC 4종 전체(§1.2 근거).
- `sql/migrations/0012_create_pos_order_sessions.sql:26`, `sql/migrations/0013_create_pos_orders.sql:17` — FK 참조(§1.3 근거).
- `sql/migrations/0022_create_rls_policies.sql:163-171` — RLS 정책(§1.4 근거).
- `601142_Logic_Allergen_Info_And_Sibling_Overwrite_Correction.md` §1 — `default null` + `coalesce(p_x, x)` 설계 패턴의 직접 템플릿(§2.4가 그대로 계승).
- `601114_ChangeContract_Store_Admin_Menu_Rpc_Correction.md` §2.10.1 — 검증-선행 순서 설계의 직접 템플릿(§2.4 말미가 그대로 계승).

### Domain Indexes

- `601100_Readme_Store_Admin_Console.md`(이 워크패킷의 번호 등록처 — Subfolder Map/Status 갱신 필요, 이번 문서 자체는 포함하지 않음).
- `601102_NavigationMap_Store_Admin_Console.md`(동일).

### Excluded Rule Families

- QR/NFC(`register_table_qr()`) — §2.5에서 명시적으로 제외.
- 운영 상태(`update_table_status()`/`release_table()`/`bind_table_to_session()`) — §3에서 명시적으로 제외.
- `601110`/`601140`의 메뉴 관련 변경 — 완전히 다른 테이블, 교차 참조(패턴 템플릿)만.
- "Staff Seating And Table Assignment Orchestration Contract"(가칭) — §6 (f)에서 후속 워크패킷 후보로 이관, 이번 워크패킷은 조사/설계하지 않음.

### 추가 참조 (§6 (f) 근거)

- `sql/migrations/0160_call_waiting_customer_contract_recovery.sql` — `call_waiting_customer()` 실존 확인.
- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:988-1006` — `seat_waiting_customer()` 실존 확인, `p_table_number` phantom-column 크래시(1049-1057) 직접 확인.
- `catchmenu_app/lib/features/waiting/README.md:14` — `seat_waiting_customer`를 "관련 RPC"로 언급(실존, 단 크래시 상태).
- `catchmenu_app/lib/features/staff/README.md:15` — "착석/테이블 배정"을 허용 동작으로 명시(구체 함수 미지정).

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Logic 단계(`601122_Logic.md`)로 진행 가능.** §1에서 스키마/기존 RPC/FK/RLS/Flutter 호출자/`bind_table_to_session`을 전부 라이브 재확인했고, `601113_TestPlan.md`의 "deactivate 패턴" 주석이 실제로는 미구현 forward-reference였음을 확인했다(§1.5). §2에서 7개 설계 질문 전부에 근거를 제시하며 답했다 — Store Admin Console 명명 관례 채택(§2.1), 신규 마이그레이션 파일 분리(§2.2), 단일 함수 설계로 충분함(§2.3), 오늘 세션의 sibling-overwrite/검증-선행 교훈을 신규 함수에 선제 적용(§2.4, `kds_device_id`/`did_device_id`도 순수 자원 속성으로 재분류해 포함, 8개 필드), QR/NFC·운영상태를 명시적으로 제외(§2.5/§3), 활성화 토글의 양방향 설계 권장과 그 이유(§2.6, `set_menu_status()` 비유가 부정확했다는 정정 포함), `get_dining_table_admin_list()` 신설 확정(§2.7), 활성 세션 3가지 가드 확정(§2.8, `capacity` 축소 제한은 실측 `guest_count`가 아니라 저장된 `capacity` 값 기준의 보수적 정책). §0.1 요약표, `table_id`/`table_code` 역할 구분(§0.2)을 포함한다.

**(2026-07-17 정정, 3개 검증자 지적 반영)** Open Item (f)를 전면 재작성했다 — 이전 버전의 "`seat_waiting_customer()` 미존재" 주장은 단일 라인 정규식 검색의 한계로 인한 오판이었다: 이 함수는 `0115_create_waiting_pipeline_rpc.sql:988-1006`에 실제로 존재하며, 더 나아가 존재하지 않는 `order_sessions.table_number` 컬럼에 쓰기를 시도해 호출 시마다 크래시하는 것으로 확인됐다(§6 (f)). `kds_device_id`/`did_device_id` 관련 stale 문구(구 초안의 "포함하지 않는다"/"6개 필드") 전체를 grep으로 재확인해 통일했다. `capacity` 축소 가드의 판단 기준 설명을 실제 SQL(저장값 비교, `guest_count` 무관)과 일치하도록 정정했다(§2.8). 검증자들이 경미하다고 분류한 5건(§6 (g)-(k) — `table_code` 비참조 절대표현 과장, 응답 필드명 `id`/`table_id` 불일치, `table_code` 변경 시 감사 누락, `orders.table_id` 직접참조 케이스 가드 범위 밖, 디바이스 FK 사전검증 없음)은 이번 정정에서 고치지 않고 Open Item으로만 기록했다. `.sql` 파일은 생성·수정하지 않았다.
