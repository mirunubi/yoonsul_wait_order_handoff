# 601141_Overview_Allergen_Info_And_Sibling_Overwrite_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Store Admin Console
Last Updated: 2026-07-17

## Change ID

`allergen_info_and_sibling_overwrite_correction`

## §0 배경 — 발견 경위

`601110_store_admin_sql_layer_reconciliation/`(메뉴 RPC phantom 컬럼 복구, Slice 1-3 완료)의 Stage 9 독립 재검증(3차) 중, `catchmenu_store.upsert_menu_core()`의 `allergen_info` UPDATE가 다른 필드들과 다른 패턴을 쓴다는 것이 Claude Code에 의해 발견됐고, `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §6 Open Item (h)로 기록됐다. 이후 Cursor+Antigravity의 후속 조사(삼중조사)로 이 결함이 `allergen_info` 하나만이 아니라 `is_kds_required`/`kitchen_zone`/`display_order`까지 포함하는 더 넓은 패턴임이 확인됐다.

**이 문서 작성 과정에서 Claude Code가 직접 재확인한 내용**(배경 조사 자체를 다시 하지는 않았으나, 설계에 반영하기 전 핵심 주장은 라이브 코드/실행으로 재검증):

- `price`/`description_ko`가 실제로 `coalesce(p_x, x)` 보존 패턴을 쓰는지 — 실제 라이브 소스에서 정확한 라인 재확인(§1.1).
- `is_kds_required`(그리고 `kitchen_zone`/`display_order`)도 `allergen_info`와 동일하게 부분 업데이트 시 조용히 리셋되는지 — 직접 실행으로 재현(§1.3): `is_kds_required=false`/`kitchen_zone='GRILL'`/`display_order=42`로 메뉴를 만든 뒤 가격만 바꾸는 `upsert_menu()` 호출 한 번으로 셋 다 각각 하드코딩된 기본값(`true`/`'MAIN'`/`0`)으로 리셋됨을 확인했다.

이번 워크패킷은 `601110`과 물리적으로 분리된 별도 워크패킷이다 — 근거: 대상 함수는 같지만(`upsert_menu()`/`upsert_menu_core()`), 다루는 결함의 성격이 다르다(phantom 컬럼명 vs. 파라미터 기본값 설계 결함), `601110`은 이미 Stage 7 승인·Stage 8 구현·Stage 9 검증이 끝난 상태라 여기서 범위를 넓히면 이미 닫힌 워크패킷의 승인 경계를 다시 여는 셈이 된다 — 오늘 이 세션이 반복 적용해 온 "같은 패턴이면 묶고 다른 패턴이면 쪼갠다" 원칙과 "이미 승인된 워크패킷은 재논의하지 않고 새 워크패킷으로 이월한다" 관례(`601112_Logic.md` §6 Open Item (h) 자체가 이미 "이번 Slice 3 승인 경계 밖... 별도 워크패킷 후보로 이월"이라고 명시했다) 그대로다.

## §1 근본 원인 — 라이브 소스 직접 확인

### §1.1 정상 작동 필드(`price`/`description_ko`)의 패턴 재확인

`sql/migrations/0110_create_store_admin_rpc.sql`, `catchmenu_store.upsert_menu_core()`:

- 파라미터 기본값: `p_price int default null`(L351), `p_description_ko text default null`(L352) — **둘 다 `default null`.**
- UPDATE 절: `price = coalesce(p_price, price)`(L511), `description = coalesce(p_description_ko, description)`(L512-514) — **생략 시(NULL) 기존 컬럼값 보존, 값이 오면 그 값으로 교체.**
- INSERT 절(신규 메뉴): `coalesce(p_price, 0)`(L481), `p_description_ko`(L482, NULL 그대로 저장 — description은 필수 아님) — **생략 시 합리적인 생성 시점 기본값.**

이 두 필드는 이미 올바르다 — 이번 수정 대상이 아니다.

### §1.2 결함 필드 4개의 기본값 (양쪽 함수 모두)

공개 RPC `catchmenu_store.upsert_menu()`(L251-336):

| 파라미터 | 기본값 (L번호) |
|---|---|
| `p_is_kds_required` | `default true` (L266) |
| `p_kitchen_zone` | `default 'MAIN'` (L267) |
| `p_display_order` | `default 0` (L268) |
| `p_allergen_codes` | `default '[]'::jsonb` (L269) |

내부 헬퍼 `catchmenu_store.upsert_menu_core()`(L339-596)도 동일한 패턴:

| 파라미터 | 기본값 (L번호) |
|---|---|
| `p_is_kds_required` | `default true` (L354) |
| `p_kitchen_zone` | `default 'MAIN'` (L355) |
| `p_display_order` | `default 0` (L356) |
| `p_allergen_info` | `default '{}'::jsonb` (L357) |

### §1.3 왜 크래시가 아니라 "조용한 리셋"으로 나타나는가 — 호출 경로 확인

`upsert_menu()`(공개 RPC)가 `upsert_menu_core()`(내부 헬퍼)를 호출하는 지점(L288-308)에서 네 필드 전부 **명시적으로 그대로 전달**한다:

```sql
p_is_kds_required := p_is_kds_required,   -- L302
p_kitchen_zone := p_kitchen_zone,          -- L303
p_display_order := p_display_order,        -- L304
p_allergen_info := p_allergen_codes,       -- L305
```

즉 외부 호출자가 `upsert_menu()`를 호출할 때 이 파라미터들을 생략하면, PostgreSQL이 **`upsert_menu()` 자신의 기본값**(`true`/`'MAIN'`/`0`/`'[]'::jsonb`)을 대입한 뒤, `upsert_menu_core()`에는 그 값이 **명시적 인자로** 전달된다 — `upsert_menu_core()`는 이 호출에서 자신의 기본값을 쓸 기회 자체가 없다(PL/pgSQL의 기본값은 인자가 통째로 생략됐을 때만 적용되며, 인자가 NULL이든 아니든 명시적으로 전달되면 기본값은 무시된다).

`upsert_menu_core()`의 UPDATE 절 코드 자체는 이미 올바른 모양이다:

```sql
is_kds_required = coalesce(p_is_kds_required, is_kds_required),  -- L518-519
kitchen_zone = coalesce(p_kitchen_zone, kitchen_zone),            -- L521-522
display_order = coalesce(p_display_order, display_order),        -- L524-525
allergen_info = v_clean_allergen_info,                            -- L527, coalesce 자체가 없음
```

`is_kds_required`/`kitchen_zone`/`display_order`는 `coalesce(p_x, x)` **모양은** `price`와 동일하다 — 문제는 이 `coalesce`가 절대 NULL을 볼 일이 없다는 것이다(§1.3 상단 설명대로 이미 `true`/`'MAIN'`/`0`으로 채워진 채 도착하므로). `allergen_info`는 그보다 더 나쁘다 — `v_clean_allergen_info`(L380-384)가 `p_allergen_info`를 애초에 `coalesce(p_allergen_info, '{}'::jsonb)`로 미리 NULL-제거해버린 뒤 그 결과를 UPDATE에 **조건 없이** 대입하므로, 설령 `p_allergen_info`가 NULL로 도착하는 경우가 있더라도 보존되지 않고 `{}`가 된다.

**결론**: 실제 결함의 위치는 `upsert_menu_core()`의 UPDATE 절 자체(is_kds_required/kitchen_zone/display_order는 이미 맞는 모양)가 아니라, **`upsert_menu()`(그리고 방어적으로 `upsert_menu_core()`도) 시그니처의 기본값**이다 — `price`/`description_ko`처럼 `default null`이었어야 할 네 자리가 `0110` 원본부터 non-null 기본값으로 선언돼 있었다.

## §2 `menu_options`는 명시적으로 제외

`p_menu_options`는 이 결함과 근본적으로 다르다 — `601112_Logic.md` §2.5 / `601114_ChangeContract.md` §2.5가 이미 확정한 **"full replacement" 계약**의 일부다: 배열에 없는 그룹/아이템은 의도적으로 `is_active=false`가 되는 것이 설계된 동작이지, "생략 시 보존" 시맨틱이 아니다. 여기에 `coalesce(p_x, 기존값)` 패턴을 적용하는 것은 수정이 아니라 **이미 승인된 다른 계약을 깨는 것**이다. 이번 워크패킷은 `menu_options`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()`를 전혀 다루지 않는다.

## §3 `601120`(dining_table_crud_creation) 교차 참조 — 손대지 않음

라이브 재확인 결과 `catchmenu_store.upsert_dining_table()`(또는 유사 이름의 함수)은 **아직 존재하지 않는다** — `601120_dining_table_crud_creation`(가칭)은 번호만 예약된 상태로 아직 착수되지 않았다(`601100_Readme_Store_Admin_Console.md` Subfolder Map 확인). 따라서 이 워크패킷 범위에서 "손댈 기존 결함"이 없다 — 대신, `601120`이 실제 착수될 때 반영해야 할 **설계 원칙**만 여기 기록해 둔다: 만약 `601120`이 설계할 "메뉴 등록 CRUD"에 이번과 유사한 부분 업데이트 패턴이 필요하다면(예: 테이블 좌석 수/구역 등을 일부만 갱신), 처음부터 `default null` + `coalesce(p_x, x)` 패턴을 쓰도록 설계해 이번과 같은 결함 클래스를 원천 차단해야 한다. 이 문서는 `601120`의 실제 함수를 조사하거나 설계하지 않는다 — `601120` 자체의 Open Item으로 교차 참조만 남긴다.

## §4 TestPlan 영향 확인

`601113_TestPlan_Store_Admin_Menu_Rpc_Correction.md` 전체에서 `upsert_menu()`의 UPDATE 경로(`p_menu_id`가 기존 UUID인 호출) 4곳(§3 Step 2, §7 Step 2, §9.1 Step 2, 그리고 §10.2 cascade 테스트의 Step 2)을 전부 확인했다:

- 넷 다 `p_is_kds_required`/`p_kitchen_zone`/`p_display_order`/`p_allergen_codes`를 생략한다(각 테스트의 관심사가 아니므로).
- 넷 다 이 네 필드의 값을 검증하는 assertion이 **없다** — `group_active`/`item_active`/`price_delta`/`price`/`event_domain`/`updated_count` 등만 확인한다.

**결론**: 기본값을 `null`로 바꿔도 기존 `601113_TestPlan.md`의 어떤 assertion도 깨지지 않는다 — 오히려 지금까지 "우연히 통과해 온" 이 네 테스트가, 수정 후에는 (검증하고 있지 않을 뿐) 실제로도 형제 필드를 올바르게 보존하게 된다. 신규 assertion을 이 문서(Overview/Logic)에서 추가하지는 않는다 — TestPlan 작업은 별도 Stage(§5 계약 작성 단계)의 몫이다.

## §5 영향 범위 요약

- **결함 클래스**: 부분 업데이트(`p_menu_id`가 기존 값, 나머지 파라미터 일부 생략) 시 `is_kds_required`/`kitchen_zone`/`display_order`/`allergen_info` 네 필드가 조용히 하드코딩된 기본값으로 리셋됨.
- **선행 조건**: 없음 — `upsert_menu()`를 부분 업데이트 목적으로 호출하는 모든 경로에 영향(현재 Flutter 호출자 0건이라는 것은 `601111_Overview.md` §1에서 이미 확인됐으나, 향후 관리자 앱이 이 RPC를 쓰게 되면 즉시 영향권에 든다).
- **심각도**: `allergen_info`는 `get_store_admin_dashboard()`의 식품위생법 경고 로직과 직결 — 관리자가 가격만 바꿔도 알레르겐 표시가 조용히 사라지는 것은 실제 법규 위반 리스크로 이어질 수 있다.
- **선행 여부**: `0110` 원본부터 있던 결함으로 추정(Logic §2.1이 이미 이 기본값을 그대로 옮겨왔을 뿐 `601110`이 새로 도입하지 않았다 — `601112_Logic.md` §6 Open Item (h) 참고).

## §6 Open Items

(a) 파라미터 기본값을 `null`로 바꾸는 것이 `upsert_menu()`(공개 RPC) 시그니처 변경인지 여부 — 이름/개수/타입은 그대로이고 기본값만 바뀌므로 하위 호환(기존 호출자가 이 파라미터들을 항상 명시적으로 전달했다면 영향 없음, 생략해 왔다면 동작이 "조용한 리셋"에서 "보존"으로 개선됨)이라고 판단되나, Logic 단계에서 이 판단을 다시 짚는다(`601142_Logic.md` §3).
(b) `601113_TestPlan.md`에 이 결함을 직접 검증하는 신규 테스트를 추가할지 — 이번 문서는 기존 테스트가 깨지지 않음만 확인했다(§4), 신규 테스트 추가 여부/내용은 TestPlan 작성 Stage의 판단.
(c) `601120` 착수 시 이 설계 원칙을 실제로 반영할지 — `601120`의 Open Item으로 이관(§3).
(d) `get_menu_catalog()`(`0044`)나 다른 읽기 경로가 이 네 필드를 소비하는 방식에 이 결함이 간접 영향을 주는지는 조사하지 않았다 — 이번 워크패킷은 쓰기 경로(`upsert_menu`/`upsert_menu_core`)만 다룬다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §6 Open Item (h) — 이 워크패킷의 직접 출발점(최초 발견 기록).

### Full Rules Required

- `sql/migrations/0110_create_store_admin_rpc.sql:251-336`(`upsert_menu()`) / `:339-596`(`upsert_menu_core()`) — 이번 수정의 정확한 대상, §1에서 라인 단위로 인용.

### Domain Indexes

- `601100_Readme_Store_Admin_Console.md`(이번 턴 이후 Subfolder Map 갱신 필요 — 이번 문서 자체는 그 갱신을 포함하지 않음, §0 참고).
- `601102_NavigationMap_Store_Admin_Console.md`(동일).

### Excluded Rule Families

- `menu_options`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()` — §2에서 명시적으로 제외.
- `601120_dining_table_crud_creation`(가칭) — §3에서 교차 참조만, 실제 조사/설계 대상 아님.
- `601130_menu_price_list_architecture` — 가격표 아키텍처는 완전히 별개 워크패킷, 이 결함과 무관.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Logic 단계(`601142_Logic.md`)로 진행 가능.** §1에서 근본 원인을 라인 단위로 재확인했다(정상 필드의 `coalesce(p_x, x)` 패턴, 결함 필드 4개의 non-null 기본값, 그리고 왜 `upsert_menu_core()`의 UPDATE 절 자체는 이미 올바른 모양인데도 결함이 발생하는지의 호출 경로 설명). `is_kds_required`/`kitchen_zone`/`display_order`도 `allergen_info`와 같은 결함을 겪는다는 것을 직접 실행으로 재현해 확인했다(§0). `menu_options`는 다른 계약(full replacement)이므로 명시적으로 제외했다(§2). `601120`은 아직 대상 함수 자체가 존재하지 않아 교차 참조만 남겼다(§3). `601113_TestPlan.md`의 기존 UPDATE 경로 4곳을 전수 확인해 기본값 변경이 기존 테스트를 깨지 않음을 확인했다(§4). `.sql` 파일은 생성·수정하지 않았다.
