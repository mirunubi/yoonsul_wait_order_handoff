# 601131_Overview_Menu_Price_List_Architecture.md

Status: Draft
Lifecycle: Overview
Stage: 1.5
Domain: Store Admin Console
Last Updated: 2026-07-16

## Change ID

`menu_price_list_architecture`

## §0 분리 이력 — 이 문서는 `601112_Logic.md`에서 물리적으로 분리됐다 (Human 결정, 2026-07-16, 재논의 금지)

`601112_Logic_Store_Admin_Menu_Rpc_Correction.md`(원래 "메뉴 관리 RPC phantom 컬럼 복구" 워크패킷)에 §7-§12로 추가됐던 Price List 아키텍처 내용을 **별도 워크패킷 `601130_menu_price_list_architecture`로 물리적으로 분리**한다 — Human 결정(§12 (g) 확정, 재논의 금지). 근거: 원래 §0-§6(phantom 4개 컬럼 국소 복구)과 이 확장(신규 테이블 4개+캐노니컬 리졸버+9개 소비자 전환을 아우르는 신규 서브시스템)은 작업 규모와 리스크가 근본적으로 다르다 — 오늘 이 세션이 확립한 "같은 패턴이면 묶고 다른 패턴이면 쪼갠다" 원칙을 그대로 적용한 결과다.

**내용은 손실 없이 그대로 이관됐다** — 원본 `601112_Logic.md` §7(배경+1단계 조사)이 이 Overview로, §8-§12(2-5단계 설계+Open Items)가 `601132_Logic_Menu_Price_List_Architecture.md`로 옮겨졌다. 문서 번호는 도메인 `601100_store_admin_console` 산하 다음 미사용 슬롯(`601110`=메뉴 RPC 복구, `601120`=`dining_table_crud_creation` 예약)을 확인해 `601130`으로 확정했다(라이브 디렉터리+`990000_legacy_quarantine/` 재검색, 둘 다 미사용 확인).

## §1 Human 결정 요약 — Price List 아키텍처 재설계 방향 (2026-07-16, ChatGPT+제미나이 교차검증, 재논의 금지)

메뉴 가격을 "메뉴 하나=가격 하나"(`menus.price` 단일 컬럼) 모델에서 **가격표(price_list) 기반 모델**로 전면 재설계한다. 홀/포장은 기본 같은 가격표 공유(분리 가능), 배달은 별도 가격표, 입점형 매장은 채널이 아니라 별도 가격표 배정 대상. 옵션 가격은 기본 공통, 필요시만 override. 주문 시점 가격은 `order_items`에 스냅샷 고정. 모든 우선순위 로직은 단일 canonical resolver(`resolve_menu_price()`)로 집중.

**설계 전 1단계(§2-§5)를 반드시 먼저 수행**한다는 Human 지시에 따라, 아래 조사를 스키마 설계보다 먼저 완료했다 — 스키마/리졸버/마이그레이션 설계(2-5단계)는 `601132_Logic_Menu_Price_List_Architecture.md`에 있다.

## §2 `menus.price` 참조처 전수 확인

라이브 소스 전수 검색(`from/join catchmenu_pos.menus` 32개 파일 중 실제로 `.price`를 읽거나 쓰는 지점을 좁혀 확인) 결과, 아래 9개 함수/파이프라인이 `menus.price`를 **직접, 무조건적으로** 참조한다 — 채널/공급자에 따른 분기는 **어디에도 없다**:

| 함수 | 파일:라인 | 용도 |
|---|---|---|
| `get_menu_catalog()` | `0044:409` | 고객/키오스크 메뉴 조회, `m.price` 그대로 노출 |
| `get_menu_customization_options()` | `0141:145` | 옵션 화면의 `base_price` |
| `calculate_customization_price()` | `0141:233-244` | 최종 주문 가격 계산의 `v_base_price` |
| `create_order()` | `0026:126-178` | **주문 생성 시 실제 청구 가격의 유일한 소스** — `v_menu.price`를 그대로 `order_items.unit_price_snapshot`/`item_amount`에 기록. `p_order_channel`을 주문 헤더(`orders.order_channel`)에 저장은 하지만(`0026:103,112`) **가격 계산에는 전혀 쓰지 않는다** — 채널 무관 단일가가 라이브의 실제 동작이다. |
| OKPOS 동기화(`0102:451-524`, 정확한 함수명은 파일 내 재확인 필요 — `sync_okpos_menu()` 또는 `sync_pos_menu_item()`으로 추정) | `0102:451-524` | POS 단말과 `menus.price` 양방향 동기화, drift 감지(`v_existing.price <> v_price`) |
| Toss POS 동기화 | `0104:446-465` | OKPOS와 동일 패턴 |
| `sync_delivery_menu()` | `0057:574-830` | CatchMenu 메뉴 카탈로그를 배민/요기요/쿠팡이츠에 **그대로 push** — 즉 **현재 배달 플랫폼에 나가는 가격이 홀 가격과 동일**하다(배달 수수료를 반영한 마크업이 전혀 없음 — 이 재설계가 메우려는 정확히 그 공백). |
| HQ 메뉴 배포(`0086:770-808`) | `0086:770-808` | **이 코드베이스에서 유일하게 발견된 "브랜드 vs 매장" 가격 계층 선례** — 본사 템플릿 가격을 매장에 배포하되 `v_template.max_price_override_pct`로 매장이 벗어날 수 있는 비율 상한을 둔다. 채널 개념은 없지만 "상위 계층 가격 + 하위 계층 제한적 override"라는 구조 자체는 이번 price-list 계층 설계와 정확히 같은 발상이다. |
| `upsert_menu()`(`601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §2) | `0110`/원 §2.2 | 관리자가 `menus.price`를 직접 설정하는 유일한 수동 입력 경로 |

**범위 한정 고지**: `menus` 테이블을 `JOIN`/참조하는 파일은 라이브 검색상 32개였으나, 이번 조사는 그중 "가격을 실제로 읽거나 쓰는" 지점만 좁혀 확인했다(위 9개) — 나머지(메뉴 상태 확인, i18n, 재고 연동 등 가격과 무관한 참조)는 전수 열람하지 않았다. Stage 4 착수 전 전체 32개 파일에 대한 한 번 더의 전수 재확인을 권고한다(§6 (a) Open Item).

## §3 `order_items` 가격 스냅샷 필드 — 이미 존재, **두 세대가 공존, 신세대는 아무도 안 씀**

라이브 재확인 결과 `order_items`(29개 컬럼)에 가격 관련 컬럼이 **이미 두 세대** 존재한다:

| 세대 | 컬럼 | 실제 쓰는 함수 |
|---|---|---|
| 1세대(원본, `0012`/`0013` 계열로 추정) | `unit_price_snapshot`, `item_amount`, `options_amount` | **`create_order()`(`0026`)가 유일하게 실제로 씀** — §2에서 확인한 실제 주문 생성 경로 |
| 2세대(`0141` 추가) | `base_price`, `option_price_delta`, `final_price`, `customization_log`, `customization_allergen_final`, `has_customization` | **전수 검색 결과 이 컬럼들에 INSERT/UPDATE를 수행하는 함수가 코드베이스 전체에 0건** — `0141` 자신의 `ALTER TABLE`/`COMMENT`에만 등장(`601112_Logic.md` §1.2에서 발견한 "`price_delta`는 옵션 가격의 canonical" 발견과 이어지는 지점이지만, 그 canonical 필드가 실제로는 `menu_option_items.price_delta`이지 `order_items.*` 쪽은 완전히 별개다 — 혼동 주의). 이 6개 컬럼은 `menu_option_items`의 `price_delta`/`allergen_delta`/`kitchen_note`(실사용 필드)를 실제 주문에 반영하려는 **의도로 추가됐으나 배선이 끝나지 않은 스키마**다 — 오늘 하루 종일 이 세션이 다뤄온 phantom 컬럼과 정확히 같은 성격의 결함이 `order_items`에도 있다는 신규 발견. |

**ChatGPT 제안 필드와의 대조**(`unit_base_price`/`option_price`/`discount_amount`/`final_unit_price`/`price_list_id`/`price_resolved_at`):

| ChatGPT 제안 | 기존 컬럼과의 관계 |
|---|---|
| `unit_base_price` | 1세대 `unit_price_snapshot`과 개념 동일 — **완전 신규 아님**, 이름만 다르다. |
| `option_price` | 1세대 `options_amount`와 개념 동일(또는 2세대 미사용 `option_price_delta`) — **완전 신규 아님**. |
| `discount_amount` | **대응 컬럼 없음** — 완전 신규. |
| `final_unit_price` | 1세대 `item_amount`(수량 반영 총액) 또는 2세대 미사용 `final_price`(단가 개념)와 유사하나 정확히 일치하는 기존 컬럼 없음 — **부분 신규**. |
| `price_list_id` | **대응 컬럼 없음** — 완전 신규, 이 재설계의 핵심 추적성 필드. |
| `price_resolved_at` | **대응 컬럼 없음** — 완전 신규. |

**결론(작업 규모 판단 근거)**: `order_items`를 다시 확장할 필요는 있으나(`601132_Logic.md` §3), 완전히 새로운 컬럼 6개를 추가하는 것이 아니라 **기존 1세대 컬럼을 재활용하고, 2세대의 이미 죽어있는 6개 컬럼을 이번에 실제로 배선하거나 정리하는 작업**에 가깝다 — 스키마 확장 자체는 예상보다 작을 수 있다.

## §4 900xxx 설계 의도 확인 — **오늘 반복된 "설계는 있는데 구현 안 됨" 패턴이 이번엔 아니다**

전담 조사(900xxx 32개 파일 전수 검색) 결과: **다중 채널/가격표 개념을 서술하는 900xxx 문서는 0건이다.** `900178_Policy_Hyper_Personalization_Menu_Customization_And_Pricing.md`(`601112_Logic.md` §1.2에서 이미 인용한 문서)조차 단일 채널 `final_price = base_price + Σ(option_price_delta)` 모델만 서술하며 채널 차원이 없다. 근접 사례 2건만 발견:
- `900161_Logic...md:338` — "가맹점이 본사 승인 필요한 것" 목록에 "메뉴 가격 변경"이 있음 — 승인 게이트 개념일 뿐, 퍼센트 상한이나 별도 필드 설계는 없음.
- `900174_Policy_Multi_Brand_Expansion_Roadmap...md:123` — "월 5회 이상 → VIP 가격"(로열티 등급 할인) — 채널이 아니라 고객 등급 차원, 이번 설계와 다른 축.

**즉 오늘 이 세션이 반복해서 확인해 온 "900xxx 설계 의도는 있는데 구현이 안 됐다"는 패턴이 이번엔 성립하지 않는다** — Price List 아키텍처는 900xxx의 못 다한 설계를 완성하는 것이 아니라, **900xxx에 없던 완전히 새로운 방향을 이번 Human 결정으로 처음 도입하는 것**이다. 유일하게 실질적으로 이어받을 수 있는 선례는 §2에서 찾은 `0086`의 "본사 템플릿가+매장 override 상한" 실제 코드다(문서가 아니라 코드 선례).

## §5 라이브 데이터 규모 — 마이그레이션은 스키마 작업이지 데이터 작업이 아니다

```
total_menus=9, priced_menus(price>0)=8, distinct_stores=1, min_price=0, max_price=6000, avg_price=2944
```
**매장 1개, 메뉴 9건뿐이다.** 이관해야 할 기존 데이터가 사실상 없다시피 하다 — `601132_Logic.md` §3(마이그레이션 설계)에서 "무중단"은 데이터 규모 때문에 어려운 게 아니라, **§2에서 확인한 9개 함수가 동시에 깨지지 않게 하는 순서 설계**가 핵심 난이도라는 뜻이다.

## §6 Open Items

(a) §2에서 확인하지 않은 나머지 `menus` 참조 파일(32개 중 9개 외 23개) — Stage 4 전 전수 재확인 권고.
(b) `0102`의 OKPOS 동기화 함수 정확한 이름(`sync_okpos_menu()` 추정, 미확정) — Stage 4 전 재확인 필요.
(c) 스키마/리졸버/마이그레이션/통합 설계 단계의 Open Items는 `601132_Logic_Menu_Price_List_Architecture.md` §5를 참조 — 이 Overview는 investigation 단계 Open Item만 다룬다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` — 이 문서가 분리되어 나온 원본, §0-§6(phantom 4개 컬럼 복구)은 계속 그 문서가 다룬다.
- `601132_Logic_Menu_Price_List_Architecture.md` — 이 Overview의 조사 결과를 이어받는 설계 문서(같은 워크패킷, 짝 문서).

### Full Rules Required

- `sql/migrations/0026_create_order_rpc.sql:126-190` — `create_order()`, "채널 무관 단일가"의 실제 증거이자 향후 소비자 전환의 최고 리스크 지점.
- `sql/migrations/0086_create_hq_menu_distribution_rpc.sql:770-808` — `max_price_override_pct` 기반 브랜드/매장 가격 계층의 유일한 기존 코드 선례.
- `sql/migrations/0057_create_delivery_platform_rpc.sql:574-830` — `sync_delivery_menu()`, 배달 플랫폼에 현재 홀 가격이 그대로 나가고 있음을 보여주는 지점.
- `sql/migrations/0141_hyper_personalization_menu_customization.sql` 전체 — `order_items` 2세대 컬럼의 출처.
- `docs/900000_patent_and_handoff_package/900178_Policy_Hyper_Personalization_Menu_Customization_And_Pricing.md` — 단일 채널 가격 모델만 서술, "설계 의도 자체가 없었다" 판단 근거.
- 라이브 `order_items` 29개 컬럼 전수, 라이브 `menus.price` 데이터 규모(재확인).

### Domain Indexes

- `601100_Readme_Store_Admin_Console.md`(이번 턴에 Subfolder Map 갱신).

### Excluded Rule Families

- phantom 4개 컬럼 복구(§0-§6) — `601112_Logic.md`가 계속 다룸, 이 워크패킷은 분리된 별개.
- `dining_tables`/테이블 CRUD — `601120`(가칭)으로 별도 이관, 완전히 별개.
- Price List 관리 RPC 자체(`set_menu_price_list_entry()` 류) — `601132_Logic.md` §5 (d) Open Item, 스키마/리졸버만 이번 워크패킷 대상.
- Flutter/클라이언트 코드 — SQL 레이어만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `601132_Logic.md`(설계 단계)로 이미 이어짐 — 내용 손실 없는 분리 완료.** `601112_Logic.md` §7의 배경 설명과 §7.1-§7.4(1단계 조사)를 그대로(문구 정정 없이, 문서 간 상호 참조만 갱신) 이 Overview로 옮겼다. §2에서 `menus.price`의 9개 실제 소비 지점을 확인하고 채널 분기가 어디에도 없음을 실증했다(`create_order()`가 `p_order_channel`을 저장만 하고 가격 계산에 안 쓰는 것이 결정적 증거). §3에서 `order_items`에 이미 두 세대의 가격 스냅샷 컬럼이 공존하며 `0141`이 추가한 2세대 6개 컬럼이 아무 함수에서도 쓰이지 않는다는, 오늘 이 세션이 반복 발견해 온 phantom-컬럼 패턴이 `order_items`에도 있다는 사실을 확인했다 — ChatGPT 제안 필드와 대조해 완전 신규는 `discount_amount`/`price_list_id`/`price_resolved_at` 3개뿐임을 확인했다(작업 규모 축소 근거). §4에서 900xxx 전수 검색 결과 이번엔 "설계는 있는데 구현 안 됨" 패턴이 아니라는 점을 명확히 했다. §5에서 라이브 데이터가 매장 1개·메뉴 9건뿐이라 마이그레이션의 난이도가 데이터 규모가 아니라 소비자 전환 순서에 있음을 확정했다. `.sql` 파일은 이번 분리 턴에도 생성·수정하지 않았다.
