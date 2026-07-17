# 601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md

Status: Draft (범위 확정 — 메뉴 관리 RPC 복구 전용, Human 결정 2026-07-16)
Lifecycle: Overview
Stage: 1.5
Domain: Store Admin Console
Last Updated: 2026-07-16

## Change ID

`store_admin_menu_rpc_correction`(범위 확정 후 정정 — 원래 `store_admin_sql_layer_reconciliation`이었으나, 메뉴/테이블 분리 확정에 따라 이 문서는 메뉴 전용으로 좁혔다. 파일명(`601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md`)은 변경하지 않았다 — 파일 이동/이름변경은 이번 지시에 포함되지 않았고, 이 문서 자체가 범위 축소 이력을 명시하면 충분하다고 판단했다.)

## §-1 범위 확정 이력 (2026-07-16, Human 결정, ChatGPT+제미나이 교차검증, 재논의 금지)

**메뉴 관리 RPC 복구(correction)와 테이블 관리 CRUD(creation)를 별도 워크패킷으로 분리한다 — 이번엔 메뉴만 먼저 진행한다.** 근거: 롤백 단위 분리(메뉴 수정이 실패해도 테이블 작업에 영향 없음, 반대도 마찬가지), 검증 컨텍스트 분리(TestPlan/ChangeContract가 서로 다른 함수 집합을 다루게 되어 각각 더 명확해짐), 추적성 확보(하나의 Audit이 하나의 명확한 변경 단위를 가리킴). 이전 버전 §6이 제시했던 "통합/분리" 옵션 중 **B(분리)로 확정**됐다 — 더 이상 열린 선택지가 아니다.

이 결정에 따라 이전 버전의 §4(`dining_tables` CRUD 최소 요구사항)/§5(기존 테이블 운영 RPC 4종 현황)는 이 문서에서 제거하고, 후속 워크패킷 `601120_dining_table_crud_creation`(가칭, 번호만 예약)의 Open Item으로 이월한다 — 그 조사 내용 자체(20개 컬럼, `table_code`+`capacity` 최소 요구사항, 기존 4개 RPC phantom 없음 확인)는 폐기되지 않고 아래 §5(신설, 이월 명세)에 요약 보존한다.

## §0 도메인/번호 확인 — 신규 도메인 `601100` 신설 제안

지시문의 가칭 `600700`은 **이미 다른 도메인이 점유** — `600700_takeout_pickup_order/`가 실존하는 활성 도메인이다(라이브 디렉터리 확인). 재사용 불가.

**기존 도메인 산하 배치 검토**: `000053` 매트릭스에서 `0110_create_store_admin_rpc.sql`을 미조사 항목으로 발견했으나, 도메인 소속을 판단할 기존 항목은 없었다. 후보로 검토한 기존 도메인:
- `600400_kds_did_implementation/` — 메뉴/테이블은 KDS 티켓 생명주기가 아니라 매장 마스터 데이터 관리이므로 부적합.
- `600600_waiting_order_session/` — 대기열/세션 도메인과 무관.
- `601000_cms_content_management/` — README(`601000_Readme...md`)를 직접 읽은 결과, CMS는 "메뉴 아이템/가격/사진 **등의 콘텐츠를 디바이스에 전달**"하는 영역으로 명시돼 있다("Kiosk-facing feeds sourced from CMS/store-settings"). 즉 메뉴 데이터를 **소비해서 화면에 뿌리는** 쪽이지, 메뉴 레코드 자체를 **생성/수정하는 관리자 CRUD**는 CMS의 명시적 Out of Scope에 해당하지 않지만 In Scope에도 없다 — 이 워크패킷이 다루는 "관리자가 메뉴/테이블을 등록·수정"하는 작업과는 계층이 다르다(source of truth 생성 vs. 콘텐츠 배포).

**결론: 신규 도메인 `601100_store_admin_console` 신설을 제안한다.** 근거:
1. `0110_create_store_admin_rpc.sql`을 전체 열람한 결과, 이 파일 하나가 이미 메뉴/직원/영업시간·휴무일/매장설정/POS연동/통합대시보드까지 **10개 함수**를 아우르는 "소형 매장 관리자 페이지용 RPC" 전체를 담고 있다 — 지시문 배경이 언급한 메뉴 RPC 3개는 이 중 일부일 뿐이다(§1에서 상세).
2. 이 10개 함수 + 테이블 CRUD까지 합치면 "매장 관리자가 자기 매장의 마스터 데이터를 설정하는" 하나의 응집된 백오피스 성격 도메인이 된다 — 기존 어느 도메인에도 자연스럽게 속하지 않는다.
3. 번호 확인: `600100`~`601000`까지 전부 실존 도메인으로 점유됨(라이브 디렉터리 리스팅 확인), `601000`은 이미 `990000_legacy_quarantine/601000_olm_model/`에서 재사용된 전례가 있는 번호(`000002_Naming_Rules.md` "601000 band reuse" 확인)로 CMS가 점유. 다음 미사용 슬롯은 **`601100`** — 디렉터리 전체 재검색 + `990000_legacy_quarantine/` 전체 재검색 결과 어디에도 없음을 직접 확인.

이 결론(신규 도메인 신설 여부, `601100` 번호 자체)은 **Human 최종 확인 필요** — 이 문서는 강한 근거와 함께 제안할 뿐 확정하지 않는다(§6 (g)).

## §1 배경 재확인 — `0110`은 지시문이 언급한 것보다 훨씬 크다

지시문 배경은 "메뉴 RPC(`upsert_menu()`/`set_menu_status()`/`get_menu_admin_list()`)"만 언급했으나, `0110_create_store_admin_rpc.sql` 전체(1-1822행)를 열람한 결과 이 파일은 **10개 함수**를 생성한다:
1. `upsert_menu()` — 메뉴 등록/수정 (§2 대상)
2. `set_menu_status()` — 메뉴 상태 일괄 변경 (§2 대상)
3. `upsert_staff()` — 직원 등록/수정 (미조사, §6 (a) 이월)
4. `set_store_hours()` — 영업시간 설정 (미조사, §6 (b) 이월)
5. `set_holiday()` — 휴무일 설정 (미조사, §6 (b) 이월)
6. `get_store_admin_dashboard()` — 통합 대시보드 (메뉴 요약 부분의 `allergen_codes`만 §2.1로 이번 범위 포함, 나머지는 미조사·§6 (a)-(c) 의존)
7. `get_menu_admin_list()` — 메뉴 관리자 목록 (§2 대상)
8. `get_staff_admin_list()` — 직원 목록 (미조사, §6 (a) 이월)
9. `update_store_settings()` — 매장 설정 업데이트 (미조사, §6 (c) 이월)
10. `setup_pos_integration()` — POS 연동 설정 (미조사, §6 (c) 이월)

**이번 워크패킷 이 문서는 메뉴(1/2/6-일부/7) + `get_store_admin_dashboard()`의 메뉴 관련 크래시 지점만 조사한다** — 직원/영업시간/휴무일/매장설정/POS연동, 그리고 대시보드의 나머지 부분은 명시적으로 범위 밖(§6 (a)-(c)), 향후 별도 워크패킷 대상. 테이블 CRUD는 §4에서 별도로 이관 처리(§5).

Flutter 호출자: `catchmenu_app/`을 `upsert_menu`/`get_menu_admin_list`/`set_menu_status`/`register_table_qr`/`get_table_floor_map`/`update_table_status`/`release_table` 전체로 재검색한 결과 **0건** — 지시문 배경과 일치, 독립 재확인 완료.

## §2 메뉴 RPC phantom 컬럼 — 4개 전부 이번 워크패킷 범위 확정 (Human 결정, 2026-07-16, 재논의 금지)

**아래 4개 phantom 컬럼(`thumbnail_url`/`allergen_codes`/`menu_options`/`pos_sync_at`) 전부 이번 워크패킷에서 함께 고친다 — 일부만 고치고 나머지를 이월하지 않는다.** 지시문의 원래 배경이 언급한 3개에 이번 문서가 재확인 과정에서 발견한 1개(`pos_sync_at`)를 더해 4개 전부를 확정 범위로 포함한다.

라이브 `catchmenu_pos.menus`(재확인, 23개 컬럼) 대비 `upsert_menu()`(`0110:251-515`)/`get_menu_admin_list()`(`0110:615-754`)/`set_menu_status()`(`0110:518-612`)가 참조하는 전체 컬럼을 대조했다.

| 참조 컬럼 (0110) | 라이브 실존 여부 | 실제 컬럼명 | 위치 |
|---|---|---|---|
| `thumbnail_url` | ✗ phantom | `image_url` | `upsert_menu()` INSERT/UPDATE(`0110:382,395,429-431`), `get_menu_admin_list()` SELECT(`0110:656`) |
| `allergen_codes` | ✗ phantom | `allergen_info` | `upsert_menu()`(`0110:269,399,441-443`), `get_menu_admin_list()`(`0110:657,660-662`), `get_store_admin_dashboard()`(`0110:1482-1487`도 동일 phantom 참조) |
| `menu_options` | ✗ phantom, 단순 컬럼명 문제 아님 | `catchmenu_pos.menu_option_groups` + `menu_option_items` 관계형 2테이블(§3) | `upsert_menu()`(`0110:270,385,400,444-446`), `get_menu_admin_list()`(`0110:663`) |
| `pos_sync_at` | ✗ phantom, **지시문 배경에 없던 신규 발견** | 대응 컬럼 없음(라이브 `menus`에 `pos_sync_at` 자체가 존재하지 않음) | `get_menu_admin_list()` SELECT(`0110:664`) — `is_pos_synced` 판정은 `menu_code like 'OKPOS_%'`(`0110:665-667`)로 컬럼 없이도 가능하나 `pos_sync_at` 자체를 그대로 SELECT하는 부분이 크래시 지점 |

나머지 참조 컬럼(`category_id`/`menu_code`/`menu_name`/`menu_name_en/zh/ja`/`price`/`description`/`is_kds_required`/`kitchen_zone`/`display_order`/`menu_status`/`is_active`)은 라이브에 전부 실존 확인 — phantom 아님.

`menu_categories` 관련 참조(`category_code`/`category_name`/`display_order`)도 라이브 10개 컬럼과 대조해 전부 실존 확인.

**기존 정상 작동 선례 발견**: `catchmenu_pos.get_menu_catalog()`(`0044_create_menu_management_rpc.sql:341-475`, 고객/키오스크용 메뉴 조회 RPC로 추정)는 이미 `image_url`/`allergen_info`/`menu_option_groups`/`menu_option_items`를 **전부 정확한 컬럼명으로** 사용하는 완전히 작동하는 코드다. `0110`이 이 기존 정상 패턴을 따르지 않고 독자적으로 phantom 컬럼명을 새로 만들어 쓴 것으로 보인다 — `get_menu_admin_list()`를 고칠 때 `get_menu_catalog()`의 JSON 구조를 그대로 참고 모델로 삼을 수 있다(§3).

### §2.1 `get_store_admin_dashboard()`의 동일 phantom 크래시 지점도 이번 범위에 포함 (Human 결정, 2026-07-16)

`0110:1414-1707`의 `get_store_admin_dashboard()`가 메뉴 요약을 만드는 부분(`0110:1482-1487`)에서 `allergen_codes`를 그대로 참조한다 — §2에서 확정한 것과 **동일 파일(`0110`), 동일 phantom 컬럼**이다. 오늘 `600570` 워크패킷에서 확립한 "같은 파일·같은 버그는 묶는다" 원칙을 그대로 적용해, 이 크래시 지점도 이번 워크패킷 범위에 **포함 확정**한다 — 이전 버전 §7 (d)에서 "후속 워크패킷으로 이월 검토"라 남겼던 항목은 이제 열린 질문이 아니다.

`get_store_admin_dashboard()`의 나머지 부분(직원 요약/영업시간/휴무일/POS연동/멤버십)은 여전히 범위 밖이다 — 이 함수 전체를 이번 워크패킷이 떠맡는 것이 아니라, **§2가 고치는 4개 phantom 컬럼과 겹치는 딱 그 지점**(`0110:1482-1487`의 `allergen_codes` 참조)만 함께 고친다.

## §3 `menu_options` — 관계형 재설계 필요 (단순 치환 아님)

라이브 스키마 확인 결과 `menu_options`는 컬럼명 문제가 아니라 **애초에 정규화된 별도 2테이블 구조**로 존재한다:

- `catchmenu_pos.menu_option_groups`(14컬럼): `menu_id`(FK→menus), `group_code`, `group_name`, `group_type`, `is_required`, `min_select`, `max_select`, `display_order`, `is_active`.
- `catchmenu_pos.menu_option_items`(17컬럼): `option_group_id`(FK→menu_option_groups), `item_code`, `item_name`, `additional_price`, `price_delta`, `is_default_included`, `is_removable`, `max_extra_qty`, `allergen_delta`, `kitchen_note`, `display_order`, `is_active`.

**이미 작동하는 읽기 패턴 확인**: `get_menu_catalog()`(`0044:415-453`)가 `menu_id`로 `menu_option_groups`를 조인하고, 각 그룹마다 `option_group_id`로 `menu_option_items`를 다시 서브쿼리 조인해 중첩 `jsonb_agg`로 반환하는 완전한 정상 패턴을 이미 갖고 있다. 이 패턴은 `additional_price`를 사용하고(`0044:433-434`), `0034_seed_data.sql:476-480`의 시드 INSERT도 동일하게 `additional_price`를 사용한다 — **`additional_price`가 실제 사용 중인 필드**로 확인된다.

**부가 발견(마이너) — [2026-07-16, `601112_Logic.md` §1.2에서 정정됨, 아래는 원문 그대로 보존]**: `menu_option_items`에 `price_delta`라는 별도 컬럼도 존재하지만(`additional_price`와 의미가 겹치는 것으로 보임), 라이브 코드베이스 전체에서 이 컬럼을 실제로 읽거나 쓰는 함수를 찾지 못했다 — `0141_hyper_personalization_menu_customization.sql`(파일명으로 미루어 이 컬럼군을 나중에 추가한 마이그레이션으로 추정, 이번 조사에서 내용까지 열람하지 않음)이 도입했을 가능성. `price_delta`/`is_default_included`/`is_removable`/`max_extra_qty`/`allergen_delta`/`kitchen_note`/`group_type`가 향후 확장 필드인지 이번 워크패킷에서 채워야 할 필드인지는 Open Item(§6 (d)).

**정정 (2026-07-16, Logic 단계 실열람 결과)**: 위 판단은 틀렸다 — `601112_Logic.md` §1.2가 `0141_hyper_personalization_menu_customization.sql`(485줄) 전체를 실제로 열람한 결과, `price_delta`는 미사용이 아니라 **`get_menu_customization_options()`/`calculate_customization_price()`(둘 다 `0141`)가 실제로 소비하는 canonical 가격 필드**였다 — 오히려 이 문서가 §3/§3.1에서 실사용 필드로 지목한 `additional_price`(`get_menu_catalog()`/`0034` 시드가 씀) 쪽이 구버전에 가깝다. 이 문서 작성 시점에는 `0141`을 파일명만 보고 내용을 열람하지 않아 발생한 조사 공백이었다 — Overview 단계 조사가 항상 완전할 수는 없다는 점을 보여주는 실제 사례로 그대로 남긴다. 아래 §3.1의 예시 JSON과 판단도 이 정정에 맞춰 갱신했다.

**설계 방향(옵션, Human 결정 필요)**: `upsert_menu()`의 `p_menu_options jsonb` 파라미터를 어떻게 이 2테이블에 반영할지:
| 옵션 | 내용 |
|---|---|
| A. `upsert_menu()` 내부에서 함께 처리 | `p_menu_options`를 그룹/아이템 배열로 파싱해 `menu_id` 확정 후 루프 upsert. 한 번의 RPC 호출로 메뉴+옵션 전체 저장 가능(관리자 UX상 자연스러움). 삭제된 그룹/아이템 처리(옵션 배열에서 빠진 기존 행을 어떻게 할지 — 삭제 vs `is_active=false`)를 별도 설계해야 함. |
| B. 별도 RPC로 분리 | `upsert_menu()`는 메뉴 본체만 다루고, `upsert_menu_option_group()`/`upsert_menu_option_item()` 같은 별도 CRUD RPC를 신설. 책임이 명확히 분리되지만 관리자 화면에서 저장 시 여러 번 호출해야 함. |

이 문서는 옵션 A/B 중 하나를 채택하지 않는다(§6 (e), Logic 단계 결정 사항) — 다만 아래 §3.1에서 두 옵션 모두에 공통 적용되는 데이터 형태와, 옵션 A를 택할 경우의 구체적 흐름을 `0044.get_menu_catalog()` 패턴 기반으로 구체화한다.

### §3.1 `0044.get_menu_catalog()` 패턴 기반 구체화 (Human 지시, 2026-07-16)

**입력 JSON 형태를 `get_menu_catalog()`의 출력 형태와 대칭으로 맞춘다** — 읽기(`0044:415-453`)와 쓰기(`upsert_menu()`)가 같은 모양의 JSON을 주고받으면 Flutter 쪽 구현이 "읽은 걸 그대로 수정해서 다시 보낸다"는 자연스러운 흐름이 된다. `get_menu_catalog()`가 반환하는 `option_groups` 배열 형태를 그대로 `p_menu_options`의 기대 입력 형태로 채택할 것을 제안한다:

**정정 (2026-07-16, `601112_Logic.md` §1.2)**: 아래 예시는 이 문서 작성 당시 `additional_price` 기준으로 작성됐으나, Logic 단계에서 `0141`을 실열람한 결과 `price_delta`가 canonical 가격 필드로 확인되어 Logic §2.4가 실제로 채택한 필드 집합(`price_delta`/`is_default_included`/`is_removable`/`max_extra_qty`/`allergen_delta`/`kitchen_note`/`group_type` — `get_menu_catalog()`가 아니라 `get_menu_customization_options()`/`calculate_customization_price()`, 둘 다 `0141`, 이 실제로 소비하는 필드 집합)로 갱신했다. 매칭 키/소프트-삭제 전략 등 구조적 설계는 원안 그대로 유효하다.

```
p_menu_options 예시 (601112_Logic.md §2.4 최종 확정 형태 — get_menu_customization_options()/calculate_customization_price()가 실제로 소비하는 필드 집합):
[
  {
    "group_code": "SPICY",
    "group_name": "맵기 선택",
    "group_type": "ADD",
    "is_required": true,
    "min_select": 1,
    "max_select": 1,
    "display_order": 10,
    "items": [
      {"item_code": "MILD", "item_name": "순한맛", "price_delta": 0, "is_default_included": false, "is_removable": true, "max_extra_qty": 1, "allergen_delta": {}, "kitchen_note": null, "display_order": 10},
      {"item_code": "HOT", "item_name": "매운맛", "price_delta": 0, "is_default_included": false, "is_removable": true, "max_extra_qty": 1, "allergen_delta": {}, "kitchen_note": null, "display_order": 20}
    ]
  }
]
```
- 그룹 매칭 키: `menu_id` + `group_code`(`0034` 시드 데이터도 그룹마다 고유 `group_code`를 씀 — 기존 관례와 일치).
- 아이템 매칭 키: `option_group_id` + `item_code`.
- 가격 필드는 `price_delta`를 쓴다(정정 — 원문은 `additional_price`라고 서술했으나 §6 (d)에서 해소됐듯 `price_delta`가 canonical이다). `additional_price`는 이번 워크패킷에서 쓰거나 건드리지 않는다 — `get_menu_catalog()`(`0044`)가 여전히 이 필드를 읽으므로, 관리자가 옵션 가격을 바꿔도 고객이 보는 가격에는 반영되지 않는 불일치가 남는다(`601112_Logic.md` §6 (a) Open Item, 별도 워크패킷 필요).

**옵션 A 채택 시의 삭제/정리 흐름(설계 스케치, 최종 채택은 여전히 Human 결정)**:
1. `p_menu_options`에 포함된 `group_code`마다 `menu_option_groups`에 `on conflict (menu_id, group_code) do update`(unique 제약이 실제로 있는지는 미확인 — `601120`으로 이관한 `table_code` unique 질문(§4)과 같은 성격의 확인 필요 항목을 여기 `group_code`/`item_code`에도 새로 추가, §6 (f)) 형태로 upsert.
2. 각 그룹의 `items` 배열마다 동일하게 `menu_option_items`에 `option_group_id` + `item_code` 기준 upsert.
3. 삭제 처리는 물리적 DELETE 대신 `is_active=false`로 — 이 코드베이스의 기존 소프트-삭제 관례(메뉴의 `HIDDEN`/`DISCONTINUED`, `menu_categories.is_active`)와 일치시킨다: `p_menu_options`에 더 이상 등장하지 않는 기존 그룹/아이템(같은 `menu_id`/`option_group_id` 아래, DB에는 있으나 입력 배열에는 없는 `group_code`/`item_code`)을 찾아 `is_active=false`로 전환.

이 스케치는 Logic 단계에서 실제 SQL로 확정될 설계의 방향성만 제시한다 — 이 문서(Overview) 단계에서 `.sql` 파일은 생성하지 않았고, 위 코드 블록도 예시 JSON일 뿐 실행 가능한 SQL이 아니다.

## §4 [범위 밖으로 이월] `dining_tables` — `601120`으로 이관 (Human 결정, 2026-07-16)

**이 섹션은 더 이상 이 문서의 조사 대상이 아니다.** 아래는 이전 버전의 조사 내용을 폐기하지 않고 후속 워크패킷 `601120_dining_table_crud_creation`(가칭, 번호만 예약)의 출발점으로 승계하기 위한 요약이다.

라이브 재확인 결과 `dining_tables`는 **20개 컬럼**이다(지시문 배경의 "12개"는 부정확 — 재확인 과정에서 발견한 배경 자체의 오차, 독립 검증의 가치를 보여주는 지점).

`NOT NULL`이면서 실질적으로 관리자 입력이 필요한 컬럼은 단 2개뿐이다:
- `table_code`(`text NOT NULL`, 기본값 없음) — 필수 입력.
- `capacity`(`int NOT NULL`, 기본값 4) — 기본값이 있으나 실사용상 명시 입력이 자연스러움.

나머지는 전부 nullable이거나 안전한 기본값이 있다: `table_name`(nullable), `floor_zone`/`table_section`(nullable), `display_order`(기본 0), `qr_code`/`nfc_tag_id`(nullable, `0048.register_table_qr()`이 이미 별도 단계로 다룸), `table_status`(기본 `'AVAILABLE'`), `current_session_id`/`occupied_since`/`last_cleaned_at`(nullable, 운영 중 채워짐), `kds_device_id`/`did_device_id`(nullable), `is_active`(기본 `true`).

`0034_seed_data.sql:175-180`의 실제 시드 INSERT도 `table_code`/`table_name`/`capacity`/`floor_zone`/`table_section`/`display_order`/`table_status`/`is_active`만 채우고 QR/NFC/디바이스 연결/세션 관련 컬럼은 전부 비워둔다 — 기존 실사용 패턴과 일치.

**결론(근거 제시, 최종 확정은 Human)**: "생성" 시점 필수 입력은 `table_code`+`capacity` 정도로 충분해 보인다. `kds_device_id`/`did_device_id` 같은 디바이스 연결은 별도 단계(이미 존재하는 `register_table_qr()`처럼, 향후 `bind_table_kds_device()` 류로 분리)로 미루는 것이 기존 코드베이스의 "단계별 등록" 패턴(QR/NFC도 생성과 분리된 `register_table_qr()`로 이미 분리돼 있음)과 일치한다.

### §4.1 [`601120`으로 이관] 기존 테이블 운영 RPC 4종 — phantom 없음, CRUD만 부재

`0048_create_table_management_rpc.sql`(`update_table_status()`/`get_table_floor_map()`/`register_table_qr()`/`release_table()`) 전체를 열람하고 참조 컬럼을 라이브 스키마와 전수 대조했다 — **phantom 컬럼 0건**, 4개 함수 전부 실존 컬럼만 사용한다. 지시문 배경의 "스키마+운영RPC 존재" 서술과 일치, 독립 재확인 완료.

`bind_table_to_session`이라는 5번째 함수명이 지시문 배경에 언급됐으나 `0048`에는 없다 — 별도 파일(`0025_create_session_rpc.sql` 등 6개 파일에서 참조 발견, 이번 조사에서 본문까지 열람하지 않음)에 존재하는 것으로 추정된다. 이 함수는 "기존 테이블을 세션에 바인딩"하는 것으로, "테이블 레코드 자체를 생성"하는 이번 CRUD 갭과는 다른 기능이므로 이 문서 범위에 포함하지 않는다.

**CRUD 갭 확정**: 생성(`create_table`)/목록(비활성 포함 전체 목록 — `get_table_floor_map()`은 `is_active=true`만 반환, 관리자가 비활성 테이블도 봐야 한다면 별도 필요)/삭제 또는 비활성화(`deactivate_table`) RPC가 전부 부재. `is_active` 컬럼이 이미 있으므로 물리적 DELETE보다 논리적 비활성화가 이 코드베이스의 기존 관례(메뉴의 `HIDDEN`/`DISCONTINUED` 패턴, `menu_categories.is_active` 등)와 일치한다.

## §5 워크패킷 분리 확정 (구 §6, Human 결정, 2026-07-16, 재논의 금지)

메뉴 correction과 테이블 creation의 작업 성격 비교(이전 버전에서 이미 도출한 근거, 그대로 유지):

| | 메뉴 RPC 정정 | 테이블 CRUD 신설 |
|---|---|---|
| 작업 유형 | 이미 존재하는 함수의 내부 컬럼 참조를 고치는 **phantom 컬럼 복구**(오늘 이 세션이 반복해 온 패턴: `600550`/`600560`/`600570`/`600580`/`600640` 등과 동일 유형) | 존재하지 않는 함수를 **처음부터 신설**하는 신규 CRUD 빌드(패턴 자체가 다름) |
| 시그니처 영향 | 없음 — `upsert_menu()`/`get_menu_admin_list()`/`set_menu_status()` 시그니처 유지, 본문만 수정 | 새 함수명/시그니처를 새로 설계해야 함 |
| 의존 관계 | `menu_options` 관계형 재설계(§3)가 있어 완전히 사소하지는 않음 | `dining_tables`만 대상, 다른 테이블과의 관계형 설계 불필요(단순 CRUD) |
| 실호출자 | 0건 (둘 다 동일) | 0건 (둘 다 동일) |

**확정: 옵션 B(분리)로 결정됐다.** 근거(§-1): 롤백 단위 분리, 검증 컨텍스트 분리, 추적성 확보. 오늘 이 세션이 확립한 "같은 패턴이면 묶고 다른 패턴이면 쪼갠다" 원칙과도 일치한다 — 위 표가 보여주듯 두 작업은 애초에 다른 패턴이었다.

이 워크패킷(`601110`)은 메뉴 전용으로 확정하고, `601120_dining_table_crud_creation`(가칭)을 후속 워크패킷으로 공식 등록한다 — **번호만 예약, 이번 턴에는 착수하지 않는다.** `601100_Readme_Store_Admin_Console.md`의 Subfolder Map에도 이 번호를 등록해 도메인 인덱스와 일관성을 맞춘다(같은 턴에 반영).

## §6 Open Items

(a) 직원 관리(`upsert_staff()`/`get_staff_admin_list()`) — 이번 워크패킷 조사 범위 밖, phantom 컬럼 여부 미확인, 별도 조사 필요.
(b) 영업시간/휴무일(`set_store_hours()`/`set_holiday()`) — 범위 밖, 미조사.
(c) 매장설정/POS연동(`update_store_settings()`/`setup_pos_integration()`) — 범위 밖, 미조사.
(d) **[해소, 정정, 2026-07-16 — `601112_Logic.md` §1.2]** `menu_option_items`의 `price_delta`/`is_default_included`/`is_removable`/`max_extra_qty`/`allergen_delta`/`kitchen_note`/`group_type` — 이 문서는 미사용 확장 필드로 추정했으나, `0141_hyper_personalization_menu_customization.sql` 전체 열람 결과 미사용이 아니라 `get_menu_customization_options()`/`calculate_customization_price()`(둘 다 `0141`)가 실제로 소비하는 canonical 필드였다(오히려 이 문서가 §3에서 실사용으로 지목한 `additional_price`가 구버전에 가까움). Logic §2.4가 `price_delta`를 채택해 §3.1 예시도 그에 맞춰 갱신했다.
(e) §3/§3.1 옵션 A/B(관계형 처리를 `upsert_menu()`에 통합할지 별도 RPC로 뺄지) — 구체화는 됐으나 최종 채택은 여전히 Human 결정.
(f) §3.1에서 upsert 설계에 필요하다고 새로 짚은 `menu_option_groups`/`menu_option_items`의 unique 제약(`menu_id`+`group_code`, `option_group_id`+`item_code`) 존재 여부 — 이번 조사에서 미확인, `on conflict` 절 확정에 필요.
(g) §0 신규 도메인(`601100`) 신설 자체와 번호 — Human 최종 확인 필요(강한 근거로 제안했으나 확정 아님).
(h) `601120_dining_table_crud_creation`(가칭) — 번호만 예약된 상태, §4에 이관된 내용을 출발점으로 실제 Overview 작성이 별도로 필요(이번 워크패킷 범위 아님).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `docs/000053_Matrix_Domain_To_Artifact_Traceability.md:102` — `0110`을 미조사 항목으로 등재한 기존 추적 기록, 이 워크패킷의 직접 출발점.
- `601000_Readme_Cms_Content_Management.md` — 신규 도메인 제안(§0)이 CMS와의 경계를 구분하는 근거.

### Full Rules Required

- `sql/migrations/0110_create_store_admin_rpc.sql` — 전체 10개 함수, 특히 `upsert_menu()`(L251-515)/`set_menu_status()`(L518-612)/`get_menu_admin_list()`(L615-754)/`get_store_admin_dashboard()`(L1414-1707, §2.1에서 `allergen_codes` 공유 크래시 지점으로 이번 범위에 포함).
- `sql/migrations/0044_create_menu_management_rpc.sql:341-475` — `get_menu_catalog()`, 정상 작동하는 `image_url`/`allergen_info`/`menu_option_groups`/`menu_option_items` 참조 선례, §3.1 설계의 직접 템플릿.
- `sql/migrations/0034_seed_data.sql:447-491`(`menu_option_groups`/`menu_option_items`) — 실사용 컬럼 세트(`additional_price` 등)의 실증 근거.
- 라이브 스키마: `catchmenu_pos.menus`(23컬럼)/`menu_categories`(10컬럼)/`menu_option_groups`(14컬럼)/`menu_option_items`(17컬럼) — 이번 문서에서 전수 재확인.

### Domain Indexes

- `601100_Readme_Store_Admin_Console.md`(신규, 이전 턴에 생성, 이번 턴에 Subfolder Map 갱신).

### Excluded Rule Families

- CMS 콘텐츠 배포(`601000`) — 메뉴 데이터를 디바이스에 전달하는 쪽, 이 워크패킷은 소스 오브 트루스 생성/수정만.
- 직원/영업시간/휴무일/매장설정/POS연동(§6 (a)-(c)) — 범위 밖.
- `dining_tables`/테이블 운영 RPC 4종/`bind_table_to_session` — `601120_dining_table_crud_creation`(가칭)으로 이관, §4 참조(제외가 아니라 이관 — 조사 내용은 보존됨).
- Flutter/클라이언트 코드 — SQL 레이어만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**범위 확정 완료 — 메뉴 관리 RPC 복구 전용, Logic 단계(`601112_Logic.md`)로 진행 가능.** §0의 신규 도메인 `601100_store_admin_console` 제안은 유지되나 최종 확정은 여전히 Human 몫(§6 (g)). §-1에서 Human 결정(ChatGPT+제미나이 교차검증)에 따라 메뉴 correction과 테이블 creation을 별도 워크패킷으로 분리하고, 이 문서를 메뉴 전용으로 확정했다 — Change ID를 `store_admin_menu_rpc_correction`으로 정정했다. §2에서 메뉴 phantom 컬럼 4개(`thumbnail_url`/`allergen_codes`/`menu_options`/`pos_sync_at`, 지시문 3개+독립 발견 1개) 전부를 이번 범위로 확정했고, §2.1에서 `get_store_admin_dashboard()`의 동일 phantom(`allergen_codes`) 공유 크래시 지점도 "같은 파일·같은 버그는 묶는다"(`600570`) 원칙에 따라 포함시켰다. §3.1에서 `menu_options` 관계형 재구성 설계를 `get_menu_catalog()`(`0044`) 패턴 기반으로 구체화했다 — 입력 JSON 형태를 읽기 출력과 대칭으로 맞추고, 매칭 키(`group_code`/`item_code`)와 소프트-삭제 전략(`is_active=false`)까지 스케치했다(옵션 A/B 최종 채택은 여전히 §6 (e) Open Item). 이전 버전 §4/§5(`dining_tables` 전체 조사)는 폐기하지 않고 새 §4로 요약 보존하며 `601120_dining_table_crud_creation`(가칭, 번호만 예약)에 명시적으로 이관했다. §5에서 워크패킷 분리를 확정으로 갱신하고 `601120`을 공식 등록했다. `601100_Readme_Store_Admin_Console.md`의 Subfolder Map도 `601120` 등록을 반영해 함께 갱신했다(아래 diff).

**(2026-07-16 추가 정정, Stage 4 Architecture Verification — Cursor+Codex+안티 삼중 검증에서 발견)**: `601112_Logic.md` §1.2가 `0141`을 실열람해 `price_delta`가 canonical 가격 필드임을 밝히면서 이 문서의 §3(부가 발견) / §3.1(예시 JSON, "가격 필드는 additional_price만 쓴다") / §6 (d) Open Item이 전부 `additional_price`를 잘못 실사용 필드로 지목하고 있던 상태였다 — 세 곳 모두 정정 주석과 함께 `price_delta` 기준으로 갱신했다(원문 서술 자체는 삭제하지 않고 "정정" 주석으로 보존, §44 "완전한 흔적 기록" 원칙과 일치). 이로써 `601111`/`601112`/`601114` 세 문서가 서로 다른 필드를 canonical로 서술하던 불일치가 해소됐다.

`.sql` 파일은 이번 정정 턴에도 생성·수정하지 않았다.
