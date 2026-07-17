# 601112_Logic_Store_Admin_Menu_Rpc_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`store_admin_menu_rpc_correction`

## §0 Human 결정 요약 — 옵션 C 채택 (2026-07-16, ChatGPT+제미나이 교차검증, 재논의 금지)

`601111_Overview.md` §6 (e)(`menu_options` 처리 방식)를 제미나이의 A/B 이분법을 ChatGPT가 통합한 **옵션 C**로 확정한다:
1. 외부 공개 RPC는 `upsert_menu()` 하나만 유지 — **시그니처 변경 없음**(파라미터 이름/개수/타입 그대로, `p_thumbnail_url`/`p_allergen_codes`/`p_menu_options` 이름도 유지).
2. 내부적으로는 `upsert_menu_core()`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()`로 책임 분리, 전부 같은 트랜잭션 안에서 순서대로 실행 — 하나라도 실패하면 전체 롤백.
3. Full replacement 계약 — `p_menu_options` 배열은 "이 메뉴 옵션의 최종 상태"로 간주. 배열에 없는 기존 그룹/아이템은 물리 DELETE가 아니라 `is_active=false`로 전환(주문 이력에서 이미 참조된 행 보존).
4. 동시성 방어(낙관적 락) 필요 여부는 이번 문서에서 조사하되 채택은 별도 판단(§4).

## §1 신규 조사 결과 — Overview Open Items 해소

### §1.1 unique 제약 확인 (Overview §6 (f) 해소)

라이브 재확인(`pg_constraint` 전수 조회) 결과 **두 unique 제약 모두 이미 존재한다**:
- `uq_option_group_menu_code` — `UNIQUE (menu_id, group_code)` on `catchmenu_pos.menu_option_groups`.
- `uq_option_item_group_code` — `UNIQUE (option_group_id, item_code)` on `catchmenu_pos.menu_option_items`.

`on conflict (menu_id, group_code)` / `on conflict (option_group_id, item_code)` 형태의 upsert가 그대로 성립한다 — 별도 제약 추가 불필요. 부가로 `menus`에도 `uq_menu_store_code UNIQUE (store_id, menu_code)`가 이미 있음을 확인했다 — `upsert_menu()`가 신규 메뉴 시 수행하는 수동 중복 검사(`menu_code_duplicate` 에러)는 이 제약의 친절한 사전 경고 역할이며 그대로 유지한다(제약 자체가 최종 방어선으로 남는다).

### §1.2 `0141` 실열람 — Overview의 "미사용 확장 필드" 판단 정정 (Overview §6 (d) 해소, **중요 정정**)

`0141_hyper_personalization_menu_customization.sql`(485줄) 전체를 열람했다. **Overview §3의 "`price_delta` 등은 미사용 확장 필드로 추정" 판단은 틀렸다** — 정반대로, 이 필드들은 **현재 실제로 소비되는 canonical 필드**다:

- `catchmenu_pos.get_menu_customization_options()`(`0141:124-203`)가 `price_delta`/`is_default_included`/`is_removable`/`max_extra_qty`/`allergen_delta`/`kitchen_note`/`group_type`를 전부 읽어 고객용 옵션 화면 데이터를 만든다.
- `catchmenu_pos.calculate_customization_price()`(`0141:208-310`)가 `price_delta`를 실제 주문 금액 계산에 쓰고(`v_option_delta += price_delta * qty`), `allergen_delta`로 최종 알레르겐을 합성하고, `group_type`으로 KDS 표시 문자열(`▲`/`▼`/`더`/`적게`)을 만든다.
- `0141:317-467`의 시드 데이터가 실제 메뉴(윤슬김밥, `KB-001`)에 이 필드들로 옵션 그룹/아이템을 채운다.

**즉 `price_delta`가 현재 실사용되는 가격 필드이고, `additional_price`(Overview가 §3에서 "실사용 필드"로 지목했던 것, `0044.get_menu_catalog()`/`0034` 시드가 씀) 쪽이 오히려 구버전에 가깝다.** `0141`이 `0044`/`0034`보다 나중 마이그레이션이고, 900xxx 정책 문서(`900178_Policy_Hyper_Personalization_Menu_Customization_And_Pricing.md`)를 근거로 도입된 더 최신·더 활발한 기능이다.

**신규 발견 — 두 개의 경쟁하는 "정답" 존재**: `get_menu_catalog()`(`0044`, 고객/키오스크용으로 추정)는 `additional_price`를 읽고, `get_menu_customization_options()`(`0141`, 마찬가지로 고객용으로 보이는 하이퍼퍼스널라이제이션 옵션 화면)는 `price_delta`를 읽는다 — **두 라이브 함수가 같은 두 테이블을 서로 다른 "진짜" 가격 필드로 읽고 있다.** `upsert_menu()`가 둘 중 하나만 쓰면 다른 쪽 읽기 경로는 계속 0원/구버전 값을 보게 된다. 이 문서는 `price_delta`를 canonical로 채택한다(§2.4) — 근거: 더 풍부한 기능(그룹 타입별 KDS 표시, 알레르겐 델타)을 실제로 소비하는 쪽이고, 정책 문서 근거가 있는 최신 설계다. `get_menu_catalog()`(`0044`)가 여전히 `additional_price`만 읽는 문제는 **이번 워크패킷 범위 밖**(§6 (a), 새 Open Item)로 이월한다 — `upsert_menu()`의 쓰기 경로만 고치는 것이 이번 워크패킷의 범위이지, 기존에 정상 작동하던 다른 읽기 RPC를 건드리는 것은 아니다.

### §1.3 `allergen_info`는 배열이 아니라 객체 — Overview가 놓친 형태 문제 (신규 발견)

라이브 CHECK 제약 재확인: `chk_menu_allergen_object` — `CHECK ((allergen_info IS NULL) OR (jsonb_typeof(allergen_info) = 'object'))`. **`allergen_info`는 JSONB 배열이 아니라 객체다**(예: `{"eggs": true, "dairy": true}`) — `0141`의 `allergen_delta` 컬럼과 동일한 관례(`COMMENT ON COLUMN ... allergen_delta IS '이 옵션 선택 시 알레르겐 변화 {"eggs": true} = 계란 추가'`).

Overview §2는 "`allergen_codes`→`allergen_info`로 이름만 바꾸면 된다"고 서술했으나 이는 **불완전하다** — `0110`의 다음 두 지점이 배열 전제 함수(`jsonb_array_length()`)를 객체에 그대로 적용하면, 컬럼명을 고쳐도 **다른 종류의 런타임 에러**(`cannot get array length of a non-array`)로 크래시가 계속된다:
- `get_menu_admin_list()`(`0110:658-662`): `'allergen_count', jsonb_array_length(coalesce(m.allergen_codes, '[]'::jsonb))`.
- `get_store_admin_dashboard()`(`0110:1482-1487`): `count(*) filter (where jsonb_array_length(coalesce(allergen_codes, '[]'::jsonb)) = 0 and menu_status = 'AVAILABLE')`.

이번 워크패킷은 단순 컬럼명 치환이 아니라 **배열→객체 의미 변환까지 함께 고친다**(§2.2/§3).

### §1.4 낙관적 락(`menu_version`) — 기존 관례 없음 확인

라이브 전체 스키마(`catchmenu%` 전 스키마)를 `version`/`row_version`/`lock_version`/`optimistic_lock_version` 계열 컬럼명으로 재검색한 결과 **0건** — 이 코드베이스 어디에도 낙관적 락 컬럼 패턴이 없다. 이번 워크패킷이 도입한다면 이 프로젝트 최초의 낙관적 락 패턴이 된다(§4에서 이 사실을 옵션 판단 근거로 사용).

## §2 `upsert_menu()` 3계층 재설계 (옵션 C)

**(2026-07-16 스키마 정정, Stage 4 Architecture Verification 발견 — Cursor+Codex+안티 삼중 검증)** 이 문서 전체에서 함수 정의/호출에 쓰던 `catchmenu_pos.upsert_menu()`/`upsert_menu_core()`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()`는 스키마가 틀렸다. 라이브 `0110_create_store_admin_rpc.sql`을 재확인한 결과 `upsert_menu()`/`get_menu_admin_list()`/`get_store_admin_dashboard()` 전부 `catchmenu_store.*`로 정의돼 있다(`0110:252,616,1415`) — `catchmenu_pos`는 이 함수들이 참조하는 **테이블**(`menus`/`menu_categories`/`menu_option_groups`/`menu_option_items`)의 스키마이지, 함수 자체의 스키마가 아니다. 아래 §2.1-§2.4는 함수 정의/호출부만 `catchmenu_store`로 정정했다 — 테이블 참조(`catchmenu_pos.menus` 등)와 `0141`/`0044`의 기존 함수 참조(`catchmenu_pos.get_menu_customization_options()` 등, §1.2)는 그대로 `catchmenu_pos`가 맞으므로 손대지 않았다. 이 문서의 다른 인용(§1.1의 `uq_option_group_menu_code`/`uq_option_item_group_code` 제약 소속 테이블 등)도 테이블 참조라 정정 대상이 아니다.

### §2.1 공개 RPC — `catchmenu_store.upsert_menu()` (시그니처 불변)

```sql
create or replace function
  catchmenu_store.upsert_menu(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid default null,
  p_category_code text default null,
  p_category_name_ko text default null,
  p_menu_code text default null,
  p_menu_name_ko text default null,
  p_menu_name_en text default null,
  p_menu_name_zh text default null,
  p_menu_name_ja text default null,
  p_price int default null,
  p_description_ko text default null,
  p_thumbnail_url text default null,
  p_is_kds_required boolean default true,
  p_kitchen_zone text default 'MAIN',
  p_display_order int default 0,
  p_allergen_codes jsonb default '[]'::jsonb,  -- (2026-07-17 정정, Stage 9 독립 검증 — Claude Code 발견) 이 문서는 한때 '[]'→'{}' 정정을 명시했으나, Stage 8 실제 구현은 원본 그대로 '[]'::jsonb를 유지했고 그 상태로 이미 Human 승인(§7)까지 받았다 — 크래시 위험은 upsert_menu_core()가 흡수한다(아래 §2.2, v_clean_allergen_info의 object-여부 검사 + '{}' 폴백). 이 문서를 라이브 기준으로 재정정한다. 파라미터명/타입/개수는 원본 그대로.
  p_menu_options jsonb default '[]'::jsonb,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, catchmenu_ledger
as $$
declare
  v_menu_result jsonb;
  v_menu_id uuid;
  v_is_new boolean;
  v_group_id_map jsonb;
  v_group jsonb;
begin
  -- 1단계: 메뉴 본체 (phantom 4개 중 3개 — image_url/allergen_info/display 필드 — 여기서 해소)
  v_menu_result := catchmenu_store.upsert_menu_core(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id, p_menu_id := p_menu_id,
    p_category_code := p_category_code, p_category_name_ko := p_category_name_ko,
    p_menu_code := p_menu_code,
    p_menu_name_ko := p_menu_name_ko, p_menu_name_en := p_menu_name_en,
    p_menu_name_zh := p_menu_name_zh, p_menu_name_ja := p_menu_name_ja,
    p_price := p_price, p_description_ko := p_description_ko,
    p_image_url := p_thumbnail_url,          -- 파라미터명은 유지, 내부에서 실제 컬럼명으로 매핑
    p_is_kds_required := p_is_kds_required, p_kitchen_zone := p_kitchen_zone,
    p_display_order := p_display_order,
    p_allergen_info := coalesce(p_allergen_codes, '{}'::jsonb),  -- 실제 컬럼명으로 매핑
    p_actor_id := p_actor_id, p_locale := p_locale
  );

  if not coalesce((v_menu_result->>'success')::boolean, false) then
    return v_menu_result;  -- upsert_menu_core()가 이미 build_error_response() 형태로 반환 — 그대로 전파
  end if;

  v_menu_id := (v_menu_result->'data'->>'menu_id')::uuid;
  v_is_new := (v_menu_result->'data'->>'is_new')::boolean;

  -- 2단계: 옵션 그룹 동기화 (menu_options의 4번째 phantom, 관계형 재구성)
  v_group_id_map := catchmenu_store.sync_menu_option_groups_core(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_menu_id := v_menu_id, p_option_groups := coalesce(p_menu_options, '[]'::jsonb)
  );

  -- 3단계: 그룹별 아이템 동기화
  for v_group in select * from jsonb_array_elements(coalesce(p_menu_options, '[]'::jsonb))
  loop
    perform catchmenu_store.sync_menu_option_items_core(
      p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_option_group_id := (v_group_id_map->>(v_group->>'group_code'))::uuid,
      p_items := coalesce(v_group->'items', '[]'::jsonb)
    );
  end loop;

  -- 원본 응답 형태 유지 + 옵션 동기화 결과 추가
  return v_menu_result || jsonb_build_object(
    'data', (v_menu_result->'data') || jsonb_build_object(
      'option_groups_synced', jsonb_array_length(coalesce(p_menu_options, '[]'::jsonb)),
      'option_group_ids', v_group_id_map
    )
  );
end;
$$;
```

**3-4단계는 원자적이다 — 별도 트랜잭션 제어 코드가 필요 없다.** PL/pgSQL 함수 안에서 다른 함수를 호출하는 것은 자동으로 같은 트랜잭션에 속한다(autonomous transaction이 아닌 이상). `upsert_menu()`가 하나의 최상위 SQL 문(`SELECT catchmenu_store.upsert_menu(...)`)으로 호출되는 한, 내부의 `upsert_menu_core()`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()` 호출 전부가 같은 트랜잭션이고, 중간에 예외가 발생하면 전체가 자동 롤백된다 — 옵션 C의 "하나라도 실패하면 전체 롤백" 요구사항은 추가 구현 없이 함수 합성만으로 이미 충족된다.

### §2.2 내부 코어 1 — `catchmenu_store.upsert_menu_core()`

원본 `upsert_menu()`(`0110:251-515`)의 메뉴 본체 로직(카테고리 upsert, 신규/수정 판단, 메뉴 코드 중복 검사, INSERT/UPDATE, 가격 변경 이력, realtime 알림)을 그대로 옮기되 phantom 3개(`thumbnail_url`→`image_url`, `allergen_codes`→`allergen_info`, `menu_options` 참조 완전 제거)를 고친다:

```sql
create or replace function
  catchmenu_store.upsert_menu_core(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid default null,
  p_category_code text default null,
  p_category_name_ko text default null,
  p_menu_code text default null,
  p_menu_name_ko text default null,
  p_menu_name_en text default null,
  p_menu_name_zh text default null,
  p_menu_name_ja text default null,
  p_price int default null,
  p_description_ko text default null,
  p_image_url text default null,
  p_is_kds_required boolean default true,
  p_kitchen_zone text default 'MAIN',
  p_display_order int default 0,
  p_allergen_info jsonb default '{}'::jsonb,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, catchmenu_ledger
as $$
declare
  v_category_id uuid;
  v_menu_id uuid;
  v_is_new boolean;
  v_old_price int;
  v_business_day date;
  v_clean_allergen_info jsonb;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;
  -- (2026-07-17 정정, Stage 9 독립 검증 — Claude Code 발견) §2.1의 p_allergen_codes 기본값이
  -- '[]'::jsonb(배열, 실제 라이브 기준으로 재정정)이므로, 이 함수가 coalesce(p_allergen_info, '{}'::jsonb)만
  -- 쓰면 호출자가 이 파라미터를 생략했을 때 배열이 그대로 allergen_info 컬럼에 들어가
  -- chk_menu_allergen_object(객체 또는 NULL만 허용)를 위반한다. object 여부까지 방어하는
  -- v_clean_allergen_info로 감싼다 — Stage 8 실제 구현이 이미 이 패턴을 쓰고 있다.
  v_clean_allergen_info := case
    when jsonb_typeof(coalesce(p_allergen_info, '{}'::jsonb)) = 'object'
      then coalesce(p_allergen_info, '{}'::jsonb)
    else '{}'::jsonb
  end;

  if p_category_code is not null then
    insert into catchmenu_pos.menu_categories (
      tenant_id, store_id, category_code, category_name, display_order
    ) values (
      p_tenant_id, p_store_id, p_category_code,
      coalesce(p_category_name_ko, p_category_code), p_display_order
    )
    on conflict (store_id, category_code) do update set
      category_name = coalesce(excluded.category_name, catchmenu_pos.menu_categories.category_name),
      updated_at = now()
    returning id into v_category_id;
  end if;

  v_is_new := p_menu_id is null;

  if not v_is_new then
    select price into v_old_price
    from catchmenu_pos.menus
    where id = p_menu_id and store_id = p_store_id and tenant_id = p_tenant_id;

    if v_old_price is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_not_found', p_locale := p_locale,
        p_tenant_id := p_tenant_id, p_store_id := p_store_id, p_rpc_name := 'upsert_menu'
      );
    end if;
  end if;

  if v_is_new and p_menu_code is not null and exists (
    select 1 from catchmenu_pos.menus
    where store_id = p_store_id and tenant_id = p_tenant_id and menu_code = p_menu_code
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'menu_code_duplicate', p_locale := p_locale,
      p_tenant_id := p_tenant_id, p_store_id := p_store_id, p_rpc_name := 'upsert_menu'
    );
  end if;

  if v_is_new then
    declare
      v_auto_code text;
    begin
      v_auto_code := coalesce(
        p_menu_code,
        'MENU-' || lpad((
          select coalesce(count(*), 0) + 1 from catchmenu_pos.menus
          where store_id = p_store_id and tenant_id = p_tenant_id
        )::text, 4, '0')
      );

      insert into catchmenu_pos.menus (
        tenant_id, store_id, category_id, menu_code, menu_name,
        menu_name_en, menu_name_zh, menu_name_ja,
        price, description, image_url,
        is_kds_required, kitchen_zone, display_order,
        allergen_info, menu_status, is_active
      ) values (
        p_tenant_id, p_store_id, v_category_id, v_auto_code,
        coalesce(p_menu_name_ko, v_auto_code),
        p_menu_name_en, p_menu_name_zh, p_menu_name_ja,
        coalesce(p_price, 0), p_description_ko, p_image_url,
        coalesce(p_is_kds_required, true), coalesce(p_kitchen_zone, 'MAIN'),
        coalesce(p_display_order, 0),
        v_clean_allergen_info,
        'AVAILABLE', true
      )
      returning id into v_menu_id;
    end;
  else
    update catchmenu_pos.menus
    set
      category_id = coalesce(v_category_id, category_id),
      menu_name = coalesce(p_menu_name_ko, menu_name),
      menu_name_en = coalesce(p_menu_name_en, menu_name_en),
      menu_name_zh = coalesce(p_menu_name_zh, menu_name_zh),
      menu_name_ja = coalesce(p_menu_name_ja, menu_name_ja),
      price = coalesce(p_price, price),
      description = coalesce(p_description_ko, description),
      image_url = coalesce(p_image_url, image_url),
      is_kds_required = coalesce(p_is_kds_required, is_kds_required),
      kitchen_zone = coalesce(p_kitchen_zone, kitchen_zone),
      display_order = coalesce(p_display_order, display_order),
      allergen_info = v_clean_allergen_info,  -- (2026-07-17 정정, Stage 9 재검증 — Claude Code 발견, 신규 결함, Slice 3 범위 밖) 실라이브 그대로: coalesce(p_allergen_info, allergen_info) 형태의 "생략 시 기존값 보존" 패턴이 아니다. p_allergen_info(및 이를 감싸는 v_clean_allergen_info)는 상위 upsert_menu()에서 이미 non-null 기본값('[]'::jsonb, §2.1)을 갖고 있어 호출자가 이 파라미터를 생략해도 NULL이 아니라 그 기본값이 그대로 여기 도달한다 — 즉 알레르겐 외의 필드만 바꾸려는 부분 업데이트 호출은 매번 allergen_info를 조용히 {}로 초기화한다. 실측 확인(가격만 바꾸는 UPDATE 호출 후 allergen_info가 {"eggs":true,"milk":true}에서 {}로 리셋됨). 이 워크패킷 이전부터 있던 결함(0110 원본도 동일한 non-null 기본값 패턴)으로 추정되며, 이번 Slice 3 승인 경계 밖이라 이 문서는 수정하지 않고 §6 Open Item으로만 기록한다.
      updated_at = now()
    where id = p_menu_id and store_id = p_store_id and tenant_id = p_tenant_id;

    v_menu_id := p_menu_id;

    if p_price is not null and p_price <> v_old_price then
      insert into catchmenu_ledger.events (
        tenant_id, store_id, event_domain, event_type, event_version,
        subject_type, subject_id, from_state, to_state,
        caused_by_type, caused_by_id, event_payload,
        business_day, business_timezone, occurred_at
      ) values (
        p_tenant_id, p_store_id, 'menu', 'menu_price_changed', 1,
        'menu', v_menu_id, v_old_price::text, p_price::text,
        'STAFF', p_actor_id,
        jsonb_build_object('old_price', v_old_price, 'new_price', p_price, 'menu_name', p_menu_name_ko),
        v_business_day, 'Asia/Seoul', now()
      );
    end if;
  end if;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE', p_event_type := 'menu_updated',
    p_payload := jsonb_build_object('menu_id', v_menu_id, 'is_new', v_is_new, 'menu_name', p_menu_name_ko)
  );

  return catchmenu_common.build_success_response(
    p_message_key := case v_is_new when true then 'menu_created' else 'menu_updated' end,
    p_data := jsonb_build_object(
      'menu_id', v_menu_id, 'is_new', v_is_new, 'category_id', v_category_id,
      'menu_name', p_menu_name_ko, 'price', p_price,
      'price_changed', not v_is_new and p_price is not null and p_price <> coalesce(v_old_price, 0)
    ),
    p_locale := p_locale
  );
end;
$$;
```
바뀐 지점만 요약: INSERT/UPDATE 컬럼 목록에서 `thumbnail_url`→`image_url`, `allergen_codes`→`allergen_info`, `menu_options` 관련 컬럼/파라미터 전부 제거(관계형 코어로 이전). 나머지(카테고리 upsert, 코드 중복 검사, 가격 이력, realtime 알림)는 원본과 동일 — 이 부분은 phantom이 아니었으므로 그대로 보존한다.

### §2.3 내부 코어 2 — `catchmenu_store.sync_menu_option_groups_core()` (신규)

```sql
create or replace function
  catchmenu_store.sync_menu_option_groups_core(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid,
  p_option_groups jsonb  -- [{group_code, group_name, group_type, is_required, min_select, max_select, display_order, items}]
)
returns jsonb  -- {"<group_code>": "<group_id>", ...}
language plpgsql
volatile
security definer
set search_path = catchmenu_pos
as $$
declare
  v_group jsonb;
  v_group_id uuid;
  v_map jsonb := '{}'::jsonb;
  v_seen_codes text[] := array[]::text[];
begin
  for v_group in select * from jsonb_array_elements(p_option_groups)
  loop
    insert into catchmenu_pos.menu_option_groups (
      tenant_id, store_id, menu_id,
      group_code, group_name, group_type,
      is_required, min_select, max_select, display_order, is_active
    ) values (
      p_tenant_id, p_store_id, p_menu_id,
      v_group->>'group_code',
      coalesce(v_group->>'group_name', v_group->>'group_code'),
      coalesce(v_group->>'group_type', 'ADD'),  -- chk_group_type: ADD/REMOVE/EXTRA/SUBSTITUTE/LESS
      coalesce((v_group->>'is_required')::boolean, false),
      coalesce((v_group->>'min_select')::int, 0),
      coalesce((v_group->>'max_select')::int, 1),
      coalesce((v_group->>'display_order')::int, 0),
      true
    )
    on conflict (menu_id, group_code) do update set
      group_name = excluded.group_name,
      group_type = excluded.group_type,
      is_required = excluded.is_required,
      min_select = excluded.min_select,
      max_select = excluded.max_select,
      display_order = excluded.display_order,
      is_active = true,
      updated_at = now()
    returning id into v_group_id;

    v_map := v_map || jsonb_build_object(v_group->>'group_code', v_group_id::text);
    v_seen_codes := v_seen_codes || (v_group->>'group_code');
  end loop;

  -- full replacement: 이번 배열에 없는 기존 그룹은 물리 삭제 대신 비활성화
  update catchmenu_pos.menu_option_groups
  set is_active = false, updated_at = now()
  where menu_id = p_menu_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and is_active = true
    and not (group_code = any(v_seen_codes));

  return v_map;
end;
$$;
```
`chk_select_range`(`min_select <= max_select`)와 `chk_group_type` 제약이 이미 라이브에 있으므로(§1.1), 잘못된 입력은 이 함수의 INSERT/UPDATE 시점에 DB가 자동으로 거부한다 — RPC 레벨 중복 검증을 추가하지 않는다.

### §2.4 내부 코어 3 — `catchmenu_store.sync_menu_option_items_core()` (신규)

```sql
create or replace function
  catchmenu_store.sync_menu_option_items_core(
  p_tenant_id uuid,
  p_store_id uuid,
  p_option_group_id uuid,
  p_items jsonb  -- [{item_code, item_name, price_delta, is_default_included, is_removable, max_extra_qty, allergen_delta, kitchen_note, display_order}]
)
returns void
language plpgsql
volatile
security definer
set search_path = catchmenu_pos
as $$
declare
  v_item jsonb;
  v_seen_codes text[] := array[]::text[];
begin
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    insert into catchmenu_pos.menu_option_items (
      tenant_id, store_id, option_group_id,
      item_code, item_name,
      price_delta, is_default_included, is_removable, max_extra_qty,
      allergen_delta, kitchen_note, display_order, is_active
    ) values (
      p_tenant_id, p_store_id, p_option_group_id,
      v_item->>'item_code',
      coalesce(v_item->>'item_name', v_item->>'item_code'),
      coalesce((v_item->>'price_delta')::int, 0),   -- §1.2: canonical 가격 필드, additional_price 아님
      coalesce((v_item->>'is_default_included')::boolean, false),
      coalesce((v_item->>'is_removable')::boolean, true),
      coalesce((v_item->>'max_extra_qty')::int, 1),
      coalesce(v_item->'allergen_delta', '{}'::jsonb),
      v_item->>'kitchen_note',
      coalesce((v_item->>'display_order')::int, 0),
      true
    )
    on conflict (option_group_id, item_code) do update set
      item_name = excluded.item_name,
      price_delta = excluded.price_delta,
      is_default_included = excluded.is_default_included,
      is_removable = excluded.is_removable,
      max_extra_qty = excluded.max_extra_qty,
      allergen_delta = excluded.allergen_delta,
      kitchen_note = excluded.kitchen_note,
      display_order = excluded.display_order,
      is_active = true,
      updated_at = now();

    v_seen_codes := v_seen_codes || (v_item->>'item_code');
  end loop;

  update catchmenu_pos.menu_option_items
  set is_active = false, updated_at = now()
  where option_group_id = p_option_group_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and is_active = true
    and not (item_code = any(v_seen_codes));
end;
$$;
```
`chk_option_item_price`(`additional_price >= 0`, 참고로 이 CHECK는 여전히 `additional_price` 컬럼을 대상으로 한다 — `price_delta`에는 이런 하한 제약이 없다, §6 (b) Open Item으로 별도 기록) 등 기존 제약은 그대로 유효.

**`p_menu_options` 입력 JSON 형태 예시**(`601111_Overview.md` §3.1의 `get_menu_catalog()` 대칭 설계를 `get_menu_customization_options()`/`calculate_customization_price()`가 실제로 소비하는 필드 집합에 맞춰 갱신):
```json
[
  {
    "group_code": "KB001_ADD",
    "group_name": "추가 재료",
    "group_type": "ADD",
    "is_required": false,
    "min_select": 0,
    "max_select": 5,
    "display_order": 2,
    "items": [
      {
        "item_code": "KB001_ADD_1",
        "item_name": "계란지단 추가",
        "price_delta": 500,
        "is_default_included": false,
        "is_removable": false,
        "max_extra_qty": 1,
        "allergen_delta": {"eggs": true},
        "kitchen_note": "계란지단 2장 추가",
        "display_order": 1
      }
    ]
  }
]
```

## §3 `get_store_admin_dashboard()` 수정 — `allergen_codes` 공유 크래시 지점

`0110:1482-1487`의 메뉴 요약 집계를 배열이 아니라 객체 형태(§1.3)에 맞게 고친다:

```sql
-- 변경 전 (0110:1482-1487)
'no_allergen', count(*) filter (
  where jsonb_array_length(
    coalesce(allergen_codes, '[]'::jsonb)
  ) = 0
  and menu_status = 'AVAILABLE'
),

-- 변경 후
'no_allergen', count(*) filter (
  where coalesce(allergen_info, '{}'::jsonb) = '{}'::jsonb
  and menu_status = 'AVAILABLE'
),
```
`get_menu_admin_list()`(`0110:615-754`, 이번 워크패킷의 §2 범위에는 포함되지 않지만 `get_store_admin_dashboard()`와 완전히 같은 성격의 크래시이므로 함께 고친다 — "같은 파일·같은 버그는 묶는다" 원칙, `601111_Overview.md` §2.1과 동일 근거)는 4개 phantom 전부(`thumbnail_url`/`allergen_codes`/`menu_options`/`pos_sync_at`)를 이 함수 하나 안에서 동시에 참조하고 있다 — 아래는 4개를 함께 고친 전체 `jsonb_build_object` 블록이다(**2026-07-16, Stage 4 Architecture Verification 발견 사항 반영: `thumbnail_url`/`menu_options` 교체 SQL을 실제로 작성 — 이전 판본은 `allergen_*`/`pos_sync_at`만 구체화돼 있었다**):

```sql
-- 변경 전 (0110:640-668, jsonb_build_object 내부)
jsonb_build_object(
  'menu_id', m.id,
  'menu_code', m.menu_code,
  'category_id', m.category_id,
  'category_code', mc.category_code,
  'category_name', mc.category_name,
  'menu_name', m.menu_name,
  'menu_name_en', m.menu_name_en,
  'menu_name_zh', m.menu_name_zh,
  'menu_name_ja', m.menu_name_ja,
  'price', m.price,
  'menu_status', m.menu_status,
  'is_active', m.is_active,
  'is_kds_required', m.is_kds_required,
  'kitchen_zone', m.kitchen_zone,
  'display_order', m.display_order,
  'thumbnail_url', m.thumbnail_url,
  'allergen_codes', m.allergen_codes,
  'allergen_count',
    jsonb_array_length(
      coalesce(m.allergen_codes, '[]'::jsonb)
    ),
  'menu_options', m.menu_options,
  'pos_sync_at', m.pos_sync_at,
  'is_pos_synced',
    m.menu_code like 'OKPOS_%'
    or m.menu_code like 'TPOS_%'
)

-- 변경 후
jsonb_build_object(
  'menu_id', m.id,
  'menu_code', m.menu_code,
  'category_id', m.category_id,
  'category_code', mc.category_code,
  'category_name', mc.category_name,
  'menu_name', m.menu_name,
  'menu_name_en', m.menu_name_en,
  'menu_name_zh', m.menu_name_zh,
  'menu_name_ja', m.menu_name_ja,
  'price', m.price,
  'menu_status', m.menu_status,
  'is_active', m.is_active,
  'is_kds_required', m.is_kds_required,
  'kitchen_zone', m.kitchen_zone,
  'display_order', m.display_order,
  'image_url', m.image_url,                                          -- (1) thumbnail_url → image_url
  'allergen_info', m.allergen_info,                                   -- (2) allergen_codes → allergen_info (§1.3: 객체 형태)
  'allergen_count',
    (select count(*) from jsonb_object_keys(coalesce(m.allergen_info, '{}'::jsonb))),
  'option_groups', (                                                  -- (3) menu_options → 관계형 2테이블 집계
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'group_id', mog.id,
        'group_code', mog.group_code,
        'group_name', mog.group_name,
        'group_type', mog.group_type,
        'is_required', mog.is_required,
        'min_select', mog.min_select,
        'max_select', mog.max_select,
        'display_order', mog.display_order,
        'items', (
          select coalesce(jsonb_agg(
            jsonb_build_object(
              'item_id', moi.id,
              'item_code', moi.item_code,
              'item_name', moi.item_name,
              'price_delta', moi.price_delta,                         -- §1.2: canonical 가격 필드
              'is_default_included', moi.is_default_included,
              'is_removable', moi.is_removable,
              'max_extra_qty', moi.max_extra_qty,
              'allergen_delta', moi.allergen_delta,
              'kitchen_note', moi.kitchen_note,
              'display_order', moi.display_order
            )
            order by moi.display_order asc
          ), '[]'::jsonb)
          from catchmenu_pos.menu_option_items moi
          where moi.option_group_id = mog.id
            and moi.is_active = true
        )
      )
      order by mog.display_order asc
    ), '[]'::jsonb)
    from catchmenu_pos.menu_option_groups mog
    where mog.menu_id = m.id
      and mog.is_active = true
  ),
  -- (4) pos_sync_at → 대응 컬럼 없음, 라인 자체를 제거. is_pos_synced는 컬럼 없이 계산 가능하므로 그대로 유지.
  'is_pos_synced',
    m.menu_code like 'OKPOS_%'
    or m.menu_code like 'TPOS_%'
)
```

`option_groups`/`items`는 각각 메뉴/그룹 단위 상관 서브쿼리(correlated subquery)로 집계했다 — `m`/`mog`는 바깥쪽 `select ... from catchmenu_pos.menus m`(`0110:677`)의 별칭을 그대로 참조한다. 이 형태는 §2.4 예시 JSON(`p_menu_options` 입력) 및 `0044.get_menu_catalog()`(§1.2에서 언급한 정상 작동 선례)의 중첩 `jsonb_agg` 패턴과 대칭이다 — 관리자 화면이 "읽은 걸 그대로 수정해서 다시 저장"하는 흐름을 자연스럽게 만든다(`601111_Overview.md` §3.1과 동일 근거). 성능 참고: 메뉴 수가 많아지면 메뉴당 2단계 상관 서브쿼리가 N+1 패턴이 될 수 있다 — 현재 라이브 데이터가 매장 1개·메뉴 9건뿐(`601131_Overview.md` §5)이라 이번 워크패킷 범위에서는 문제가 되지 않으나, TestPlan 단계에서 `EXPLAIN ANALYZE`로 실측 확인을 권고한다(신규 Open Item, §6 (g)).

## §4 동시성 방어(`menu_version`) — 옵션 제시, 판단은 Human

**필요성 시나리오**: 관리자 두 명이 동시에 같은 메뉴를 수정 화면에 띄워놓고 각자 다른 필드를 고쳐 저장하면, 나중에 저장한 쪽이 먼저 저장한 쪽의 변경을 덮어쓸 수 있다(lost update) — `upsert_menu()`가 항상 `coalesce(p_x, x)` 패턴(넘어오지 않은 필드는 유지)을 쓰므로 완전한 덮어쓰기는 아니지만, 두 관리자가 "같은 필드"를 동시에 고치면 여전히 나중 저장이 이긴다.

**기존 관례**: §1.4에서 확인한 대로 이 코드베이스 전체에 낙관적 락 컬럼이 단 한 곳도 없다 — 이번에 추가하면 이 프로젝트 최초 사례가 된다.

| 옵션 | 내용 |
|---|---|
| A. 이번 워크패킷에 포함 | `menus.menu_version int not null default 1`(또는 `updated_at` 기반 낙관적 락) 추가, `upsert_menu()`에 `p_expected_version` 파라미터 신설(단, 옵션 C의 "시그니처 변경 없음"은 기존 파라미터에 대한 것이었지 신규 파라미터 추가 자체를 막지는 않는다 — 신규 optional 파라미터 추가는 기존 호출자에게 breaking change가 아니다) 후 `where ... and menu_version = p_expected_version` 조건부 UPDATE로 구현. |
| B. 이번 워크패킷은 이월 | 소형 매장(1인 관리자 운영이 대부분일 것으로 추정, 실제 동시 편집 충돌 빈도 데이터 없음) 특성상 지금 당장 필요성이 낮고, 이 프로젝트에 전례 없는 새 패턴을 도입하는 것 자체가 phantom 컬럼 복구라는 이번 워크패킷의 좁은 범위를 벗어난다. 향후 실제 충돌 사례가 관측되면 별도 워크패킷으로. |

이 문서는 판단하지 않는다 — 다만 §1.1에서 이미 확인한 `on conflict ... do update` 기반 upsert 패턴은 낙관적 락 유무와 무관하게 그대로 유효하므로(락은 "누구 값으로 이길지"를 제어하는 것이지 upsert 자체의 정합성과는 별개 문제), 옵션 A를 채택하더라도 §2의 설계를 다시 갈아엎을 필요는 없다 — `p_expected_version` 체크를 `upsert_menu_core()`의 UPDATE 분기 WHERE 절에 추가하는 정도의 국소 변경이 된다.

## §5 Overview Open Items 해소 현황

- (d) `price_delta` 등 미사용 필드 여부 → **해소, 정정**(§1.2): 미사용이 아니라 canonical 필드. `0044.get_menu_catalog()`가 구버전 필드(`additional_price`)를 읽는 문제를 새 Open Item으로 이월(§6 (a)).
- (f) unique 제약 확인 → **해소**(§1.1): 둘 다 이미 존재.
- (e) 옵션 A/B(관계형 처리를 어디서 할지) → **해소**: Human이 옵션 C로 확정, §2가 그 설계.

## §6 남은 Open Items

(a) **[신규, §1.2에서 발견]** `catchmenu_pos.get_menu_catalog()`(`0044`)가 여전히 `additional_price`를 읽는다 — `price_delta`가 canonical로 확정된 지금, 이 함수도 고쳐야 고객이 실제로 보는 옵션 가격이 관리자가 저장한 값과 일치한다. 이번 워크패킷 범위 밖(쓰기 경로만 다룸), 별도 워크패킷 필요.
(b) **[신규, §2.4에서 발견]** `chk_option_item_price`(`additional_price >= 0`)는 여전히 `additional_price`를 대상으로 하고 `price_delta`에는 하한 제약이 없다 — `price_delta`는 원래 "가격 변동"(음수=할인 가능, `0141` 컬럼 코멘트 참고)이라 하한 제약이 없는 게 의도적일 수 있으나, 확정 짓지 않았다.
(c) `menu_code_duplicate` 수동 검사와 `uq_menu_store_code` DB 제약의 관계 — 현재는 수동 검사가 먼저 걸리므로 친절한 에러를 주지만, 동시 요청 경쟁 시 수동 검사를 통과한 두 요청이 모두 INSERT를 시도해 DB 제약 위반(비친절한 raw 에러)으로 떨어질 가능성이 있음 — 이번 문서는 원본 동작을 그대로 보존했을 뿐 이 경쟁 자체를 새로 해결하지 않았다.
(d) §4 낙관적 락 — Human 결정 필요.
(e) `601111_Overview.md` §6에 남아있던 기존 Open Items(직원/영업시간/휴무일/매장설정/POS연동 미조사, 신규 도메인 번호 확정, `601120` 착수)는 전부 그대로 유효 — 이 문서가 다루지 않는다.
(f) **[해소, 물리적 분리 완료, 2026-07-16 Human 결정]** 이 문서에 한때 §7-§12로 존재했던 **Price List 아키텍처(가격표 기반 다중 채널 가격 모델) 확장**은 별도 워크패킷 `601130_menu_price_list_architecture/`로 물리적으로 분리됐다 — `601131_Overview_Menu_Price_List_Architecture.md`(1단계 조사) + `601132_Logic_Menu_Price_List_Architecture.md`(2-5단계 설계)로 내용 손실 없이 이관 완료. 이 문서(`601112_Logic.md`)는 이제 다시 §0-§6(phantom 4개 컬럼 복구)만 다룬다.
(g) **[신규, 2026-07-16 Stage 4 Architecture Verification 발견]** §3에서 새로 작성한 `get_menu_admin_list()`의 `option_groups` 상관 서브쿼리(메뉴당 그룹×아이템 2단계)는 현재 라이브 데이터 규모(매장 1개·메뉴 9건)에서는 문제가 되지 않으나, 메뉴 수가 늘어나면 N+1 패턴이 될 수 있다 — TestPlan 단계에서 `EXPLAIN ANALYZE` 실측 확인 필요, 이번 문서는 설계만 제시하고 성능 확정은 하지 않는다.
(h) **[신규, 2026-07-17, Stage 9 재검증(3차) — Claude Code 발견, 매우 중요, 이번 워크패킷/Slice 1-3 범위 밖]** `upsert_menu_core()`의 `allergen_info` UPDATE가 `coalesce(p_allergen_info, allergen_info)`("생략 시 기존값 보존") 패턴이 아니라 `v_clean_allergen_info`(항상 non-null)를 무조건 대입하는 형태다 — 원인은 공개 `upsert_menu()`가 `p_allergen_codes`에 non-null 기본값(`'[]'::jsonb`, §2.1)을 쓰기 때문에, 호출자가 이 파라미터를 생략해도 실제로는 NULL이 아니라 그 기본값이 내려온다. **실측 확인**: 메뉴 생성 시 `{"eggs":true,"milk":true}`로 알레르겐을 설정한 뒤, 가격만 바꾸고 `p_allergen_codes`는 생략한 UPDATE 호출 한 번으로 `allergen_info`가 `{}`로 조용히 리셋됨을 직접 재현했다. `price`/`description_ko`/`image_url` 등 `default null`을 쓰는 다른 필드들은 전부 `coalesce(p_x, x)`로 정상 보존되므로, 이 결함은 **non-null 기본값을 쓰는 파라미터(`p_allergen_codes` — 그리고 코드 형태가 동일한 `p_is_kds_required`/`p_kitchen_zone`/`p_display_order`도 같은 패턴이라 의심되나 이번 조사에서 실측 확인은 `allergen_info`만 진행함)에 국한된 별도 결함**으로 보인다. `0110` 원본부터 있던 pre-existing 결함으로 추정된다(Logic §2.1이 원래도 이 non-null 기본값을 그대로 옮겨왔을 뿐, 이번 워크패킷이 새로 도입한 게 아님). 식품위생법 관련 경고 로직(`get_store_admin_dashboard()`의 "알레르겐 미등록 메뉴" 감지)과 직결되는 만큼 심각도가 낮지 않다 — 이번 Slice 3 승인 경계(§2.10) 밖이므로 이 문서는 수정하지 않고 별도 워크패킷 후보로 이월한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md` — 이 문서의 직접 전제, 특히 §2(phantom 4개)/§3.1(구 JSON 설계, 이번 문서가 갱신)/§6 (d)(f)(이번 문서가 해소).

### Full Rules Required

- `sql/migrations/0110_create_store_admin_rpc.sql:251-515` — 원본 `upsert_menu()`, §2.2 재작성 기준선.
- `sql/migrations/0110_create_store_admin_rpc.sql:1414-1707` — `get_store_admin_dashboard()`, §3 수정 대상.
- `sql/migrations/0141_hyper_personalization_menu_customization.sql` 전체 — `price_delta`/`allergen_delta`/`group_type` 등이 canonical임을 증명하는 실사용 근거(§1.2), `get_menu_customization_options()`/`calculate_customization_price()`.
- `sql/migrations/0044_create_menu_management_rpc.sql:341-475` — `get_menu_catalog()`, §6 (a)에서 이월한 구버전 필드 참조 지점.
- 라이브 제약: `uq_option_group_menu_code`/`uq_option_item_group_code`/`uq_menu_store_code`/`chk_group_type`/`chk_select_range`/`chk_menu_allergen_object`/`chk_option_item_price`(전수 재확인, §1.1/§1.3).

### Domain Indexes

- `601100_Readme_Store_Admin_Console.md`.
- `601130_menu_price_list_architecture/` — 이 문서 §6 (f)에서 분리해 낸 짝 워크패킷, 별도 Overview/Logic 문서 세트.

### Excluded Rule Families

- `dining_tables`/테이블 CRUD — `601120`(가칭)으로 이관, 완전히 별개.
- 직원/영업시간/휴무일/매장설정/POS연동 — 범위 밖(Overview §6 (a)-(c) 그대로).
- Flutter/클라이언트 코드 — SQL 레이어만.
- **Price List 아키텍처 전체**(다중 채널 가격표, `resolve_menu_price()`, `order_items` 2세대 컬럼 정리 등) — §6 (f)에서 `601130_menu_price_list_architecture/`로 물리적 분리 완료, 이 문서 범위 밖.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, TestPlan/ChangeContract 단계로 진행 가능 — Price List 확장은 별도 워크패킷으로 분리 완료.** §0에서 Human이 확정한 옵션 C(공개 RPC 1개 + 내부 코어 3개, 같은 트랜잭션, full-replacement 계약)를 그대로 반영했다. §1에서 Overview의 두 Open Item을 실제로 조사해 해소했다 — unique 제약은 이미 존재(§1.1), `price_delta` 등은 미사용이 아니라 오히려 canonical이라는 정정을 `0141` 실열람으로 확인했다(§1.2, Overview의 오판을 바로잡음). §1.3에서 `allergen_info`는 배열이 아니라 객체이므로 단순 컬럼명 치환만으로는 크래시가 형태만 바뀔 뿐 해소되지 않는다는 것을 `chk_menu_allergen_object` 제약으로 실증했다. §2에서 `upsert_menu()`/`upsert_menu_core()`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()` 전체 SQL을 작성하고, 트랜잭션 원자성이 함수 합성만으로 자동 충족됨을 근거와 함께 명시했다. §3에서 `get_store_admin_dashboard()`와 `get_menu_admin_list()`의 4개 phantom 컬럼(`thumbnail_url`/`allergen_codes`/`menu_options`/`pos_sync_at`)을 전부 함께 고친 전체 `jsonb_build_object` 블록을 작성했다. §4에서 낙관적 락 옵션을 근거와 함께 제시했으나 채택은 Human 결정으로 남겼다.

**(2026-07-16 추가 정정, Stage 4 Architecture Verification — Cursor+Codex+안티 삼중 검증에서 발견된 3가지 필수 수정 반영)**: (1) §2 전체의 함수 정의/호출 스키마를 `catchmenu_pos`→`catchmenu_store`로 정정했다 — 라이브 `0110` 재확인 결과 `upsert_menu()`/`get_menu_admin_list()`/`get_store_admin_dashboard()`는 전부 `catchmenu_store` 스키마에 있고, `catchmenu_pos`는 이 함수들이 참조하는 테이블의 스키마일 뿐이었다(테이블 참조와 `0141`/`0044` 기존 함수 참조는 원래부터 `catchmenu_pos`가 맞으므로 그대로 유지). (2) `601111_Overview.md`/`601114_ChangeContract.md`가 여전히 `additional_price`를 canonical로 서술하던 상태를 이 문서 §1.2의 `price_delta` 정정에 맞춰 갱신했다(문서 간 상호 참조 정합화, 두 문서 각각의 diff 참고). (3) §3의 `get_menu_admin_list()` 수정을 `thumbnail_url`/`menu_options`까지 포함한 전체 SQL로 확장 작성했다(이전 판본은 `allergen_*`/`pos_sync_at`만 구체화돼 있었음) — 신규 상관 서브쿼리의 성능 특성을 §6 (g) Open Item으로 기록했다.

**이 문서가 한때 §7-§12로 품고 있던 Price List 아키텍처(다중 채널 가격표 모델, `resolve_menu_price()`, 마이그레이션 경로)는 Human 결정(§12 (g) 확정)에 따라 별도 워크패킷 `601130_menu_price_list_architecture/`로 물리적으로 분리됐다** — `601131_Overview_Menu_Price_List_Architecture.md`(1단계 조사) + `601132_Logic_Menu_Price_List_Architecture.md`(2-5단계 설계)로 내용 손실 없이 이관 완료(§6 (f)). 이 문서는 이제 원래 목적(메뉴 RPC phantom 4개 컬럼 복구)만 다룬다.

`.sql` 파일은 이번 분리 턴에도 생성·수정하지 않았다.
