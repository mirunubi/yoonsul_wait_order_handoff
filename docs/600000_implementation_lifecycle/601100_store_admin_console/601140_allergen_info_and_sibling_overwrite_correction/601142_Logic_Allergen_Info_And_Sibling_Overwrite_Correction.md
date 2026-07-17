# 601142_Logic_Allergen_Info_And_Sibling_Overwrite_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Store Admin Console
Last Updated: 2026-07-17

## Change ID

`allergen_info_and_sibling_overwrite_correction`

## §1 설계 방향

`601141_Overview.md` §1이 확인한 대로, 결함은 `upsert_menu_core()`의 UPDATE 절 코드 자체(`is_kds_required`/`kitchen_zone`/`display_order`는 이미 `coalesce(p_x, x)` 모양)가 아니라 **파라미터 기본값**에 있다. 따라서 수정의 핵심은:

1. `upsert_menu()`(공개 RPC)와 `upsert_menu_core()`(내부 헬퍼) 양쪽 시그니처에서 `p_is_kds_required`/`p_kitchen_zone`/`p_display_order`/`p_allergen_codes`(`p_allergen_info`)의 기본값을 `price`/`description_ko`와 동일하게 `default null`로 바꾼다.
2. `is_kds_required`/`kitchen_zone`/`display_order`의 UPDATE 절 코드는 **변경 불필요** — 이미 올바른 `coalesce(p_x, x)` 모양이고, NULL이 실제로 도착하기만 하면 그대로 정상 작동한다.
3. `allergen_info`만 별도 처리가 필요하다 — 현재의 `v_clean_allergen_info` 방어 로직(§1.3, 아래)이 NULL을 애초에 지워버리므로, "생략됨(NULL)"과 "빈 객체를 명시적으로 보냄(`{}`)"을 구분할 수 있도록 재설계한다.
4. INSERT 절(신규 메뉴 생성 경로)은 **변경 불필요** — `coalesce(p_is_kds_required, true)`/`coalesce(p_kitchen_zone, 'MAIN')`/`coalesce(p_display_order, 0)`는 이미 "생략 시 합리적인 생성 기본값" 패턴이다. `allergen_info`만 아래 §1.3에서 함께 조정한다.

### §1.1 `upsert_menu()` 시그니처 변경

```sql
-- 변경 전 (0110:266-269)
p_is_kds_required boolean default true,
p_kitchen_zone text default 'MAIN',
p_display_order int default 0,
p_allergen_codes jsonb default '[]'::jsonb,

-- 변경 후
p_is_kds_required boolean default null,
p_kitchen_zone text default null,
p_display_order int default null,
p_allergen_codes jsonb default null,
```

`upsert_menu()` 본문의 `upsert_menu_core()` 호출부(0110:302-305, `p_is_kds_required := p_is_kds_required` 등 직접 전달)는 **변경 불필요** — 이미 있는 그대로(이제는 NULL일 수도 있는 값을) 그대로 전달하면 된다.

### §1.2 `upsert_menu_core()` 시그니처 변경

```sql
-- 변경 전 (0110:354-357)
p_is_kds_required boolean default true,
p_kitchen_zone text default 'MAIN',
p_display_order int default 0,
p_allergen_info jsonb default '{}'::jsonb,

-- 변경 후
p_is_kds_required boolean default null,
p_kitchen_zone text default null,
p_display_order int default null,
p_allergen_info jsonb default null,
```

**(2026-07-17 갱신, Human 결정 — Codex+안티 검증 완료, 재논의 금지)** `601141_Overview.md` §1.3에서 확인한 대로, `upsert_menu()`를 거치는 모든 호출 경로에서는 이 함수 자체의 기본값이 실제로 쓰일 일이 없다(`upsert_menu()`가 항상 명시적으로 값을 전달하므로) — 즉 §1.1만으로 정상 호출 경로의 버그는 고쳐진다. **그러나 이 시그니처 변경은 더 이상 "방어적 일관성" 수준의 권장 사항이 아니라 필수다** — Codex 검증에서 `upsert_menu_core()`의 `pg_proc.proacl`이 **NULL**임이 확인됐다:

```
select p.proname, p.proacl, p.prosecdef
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='catchmenu_store' and p.proname in ('upsert_menu','upsert_menu_core','set_menu_status');

 proname          | proacl                                                        | prosecdef
-------------------+---------------------------------------------------------------+-----------
 set_menu_status   | {=X/postgres,postgres=X/postgres,authenticated=X/postgres}    | t
 upsert_menu       | {=X/postgres,postgres=X/postgres,authenticated=X/postgres}    | t
 upsert_menu_core  |                                                                | t
```

`upsert_menu()`/`set_menu_status()`는 명시적 ACL(`authenticated`로 제한된 GRANT)이 설정돼 있는 반면, `upsert_menu_core()`는 `proacl`이 비어 있다 — PostgreSQL에서 함수의 `proacl`이 NULL이라는 것은 명시적 GRANT/REVOKE가 한 번도 적용되지 않고 **스키마 기본 권한 그대로**라는 뜻이며, 함수의 기본 권한은 PUBLIC에 EXECUTE가 부여된 상태다(`catchmenu_store`에 이를 재정의하는 `ALTER DEFAULT PRIVILEGES`도 라이브 마이그레이션 전수 검색 결과 없음을 확인). 즉 `upsert_menu_core()`는 "내부 헬퍼"로 의도됐지만 실제로는 `authenticated`(또는 그 이상) 권한을 가진 어떤 호출자든 `upsert_menu()`를 거치지 않고 **직접 호출**할 수 있는 상태다. `prosecdef = 't'`(security definer)이므로 그런 직접 호출도 정의자 권한으로 실행된다. 이런 직접 호출 경로에서는 `upsert_menu_core()` **자신의** 기본값이 실제로 적용되므로, §1.2를 §1.1과 함께 바꾸지 않으면 우회 경로로 동일한 결함이 재현된다. 이에 따라 §1.1/§1.2 둘 다 이번 워크패킷의 **확정 범위**이며, `601114_ChangeContract.md`의 Allowed Operations에 반드시 포함되어야 한다(§3 Open Item (a) 해소).

### §1.3 `allergen_info` — NULL과 명시적 빈 객체 구분

현재 방어 로직(0110:380-384)은 이미 라이브에 있는 것으로, `601112_Logic.md` §2.2에서도 동일하게 문서화됐다:

```sql
-- 현재 (0110:375, 380-384)
declare
  ...
  v_clean_allergen_info jsonb;
begin
  ...
  v_clean_allergen_info := case
    when jsonb_typeof(coalesce(p_allergen_info, '{}'::jsonb)) = 'object'
      then coalesce(p_allergen_info, '{}'::jsonb)
    else '{}'::jsonb
  end;
```

문제: `coalesce(p_allergen_info, '{}'::jsonb)`가 NULL을 **가장 먼저** 지워버려서, 이후 어떤 코드도 "원래 NULL이었는지"를 알 수 없다. 수정안은 NULL 여부를 별도로 판별해 유지한다:

```sql
-- 변경 후
declare
  ...
  v_clean_allergen_info jsonb;  -- NULL = 호출자가 생략함(보존/생성-기본값 처리는 사용처에서). 값이 있으면 object로 정제된 값.
begin
  ...
  v_clean_allergen_info := case
    when p_allergen_info is null then null
    when jsonb_typeof(p_allergen_info) = 'object' then p_allergen_info
    else '{}'::jsonb  -- 호출자가 뭔가 보냈는데 object가 아닌 경우(배열 등)만 방어적으로 무해화 — 생략(NULL)과는 다른 경우
  end;
```

사용처 변경:

```sql
-- INSERT 절 (0110:487) 변경 전
v_clean_allergen_info,

-- 변경 후 — 신규 생성 시 생략되면 빈 객체가 합리적 기본값(price의 coalesce(p_price, 0)와 동일한 성격)
coalesce(v_clean_allergen_info, '{}'::jsonb),
```

```sql
-- UPDATE 절 (0110:527) 변경 전
allergen_info = v_clean_allergen_info,

-- 변경 후 — 생략(NULL)이면 기존 값 보존, 값이 오면(정제된 값이든 방어적으로 무해화된 값이든) 그 값으로 교체
allergen_info = coalesce(v_clean_allergen_info, allergen_info),
```

이 재설계는 `chk_menu_allergen_object`(객체 또는 NULL만 허용) 제약을 여전히 만족한다 — `v_clean_allergen_info`가 NULL이든, 정제된 object든, 방어적 `{}`든 셋 다 제약을 통과한다. `allergen_delta`/`price_delta` 등 다른 워크패킷(`601110`)의 컬럼/로직은 전혀 건드리지 않는다.

## §2 `menu_options` 제외 확인 (설계 차원)

`p_menu_options`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()`에는 위 패턴을 적용하지 않는다 — `601112_Logic.md` §2.5의 full-replacement 계약(배열에 없는 항목은 의도적으로 `is_active=false`)과 "생략 시 보존" 시맨틱은 정반대이므로, 여기 coalesce-preserve를 적용하면 계약을 깨는 것이지 고치는 게 아니다(`601141_Overview.md` §2와 동일 결론, 여기서는 SQL 설계 관점에서 재확인).

## §3 Open Items

(a) **[해소, 2026-07-17, Codex+안티 검증 — Human 결정, 재논의 금지]** §1.2(`upsert_menu_core()` 자체의 기본값 변경)이 "필수"인지 "권장(방어적 일관성)"인지 — `upsert_menu_core()`의 `pg_proc.proacl`이 NULL이라는 라이브 확인(§1.2 인용 참조)에 따라, 명시적 REVOKE 없이는 `authenticated` 역할이 `upsert_menu()`를 우회해 `upsert_menu_core()`를 직접 호출할 가능성을 배제할 수 없음이 확인됐다. 이에 따라 **필수로 확정** — §1.1(공개 wrapper)뿐 아니라 §1.2(내부 헬퍼)도 이번 워크패킷의 확정 범위이며, `601114_ChangeContract.md`의 Allowed Operations에 반드시 포함한다.
(b) 기존에 이 네 필드를 "매번 전체 값을 다시 보내는" 방식으로 호출해 온 숨은 호출자가 있는지 — `601111_Overview.md` §1에서 이미 Flutter 호출자 0건을 확인했으나, 이번 워크패킷은 그 재확인을 다시 하지 않았다(같은 사실을 두 번 조사하지 않는다는 이 세션의 원칙) — 필요시 ChangeContract 단계에서 재확인.
(c) `additional_price`와 마찬가지로, `menu_option_items`의 다른 필드(`is_default_included`/`is_removable`/`max_extra_qty`/`kitchen_note` 등)도 `upsert_menu()` 파라미터 레벨이 아니라 `p_menu_options` JSON 내부 필드라서 이 결함 클래스와 무관하다 — 확인만 하고 범위에 포함하지 않는다.
(d) `601141_Overview.md` §6 (a)-(d)와 동일 항목 다수는 이 문서에서 이어받아 그대로 유효.
(e) **[신규, 2026-07-17, Human 결정 — Slice 2(§4) 발견에서 파생]** `p_display_order`가 메뉴(`catchmenu_pos.menus.display_order`)와 카테고리(`catchmenu_pos.menu_categories.display_order`) 두 개의 서로 다른 리소스에 파라미터 하나로 재사용(오버로딩)되고 있다는 근본 설계 문제는 §4의 Slice 2로 "당장의 NOT NULL 크래시"만 해소했을 뿐 해결되지 않았다. 근본 해결은 `p_menu_display_order`/`p_category_display_order`로 파라미터를 분리하는 것이나, 이는 `upsert_menu()`의 공개 시그니처를 바꾸는 일이라 별도 워크패킷 후보(가칭 "Menu/Category Display Order Parameter Contract Separation")로 남긴다. 착수 시 확인해야 할 파급효과: (1) `p_display_order`를 파라미터로 받는 0110 내 다른 함수 존재 여부, (2) 현재 `p_display_order`를 호출하는 모든 호출자 전수(Flutter 포함) 및 그 값이 "메뉴용"으로 의도됐는지 "카테고리용"으로 의도됐는지, (3) Flutter 클라이언트 payload가 이 파라미터를 어떻게 채우는지, (4) 함수 오버로드(동일 이름 다른 시그니처) 존재 여부. 지금은 조사하지 않고 후속 워크패킷 후보로만 기록한다.

## §3.5 Required Context Snapshot Candidates

### Master Anchor

- `601141_Overview_Allergen_Info_And_Sibling_Overwrite_Correction.md` — 이 Logic 문서의 직접 전제(근본 원인 조사 전체).

### Full Rules Required

- `sql/migrations/0110_create_store_admin_rpc.sql:251-336, 339-596` — `upsert_menu()`/`upsert_menu_core()`, 이번 수정의 정확한 대상.
- `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §2.2(`v_clean_allergen_info` 방어 로직의 최초 설계 근거) / §6 Open Item (h)(이 워크패킷의 발단).

### Domain Indexes

- `601100_Readme_Store_Admin_Console.md`.

### Excluded Rule Families

- `menu_options`/관계형 옵션 동기화 — §2에서 제외.
- `601120_dining_table_crud_creation` — `601141_Overview.md` §3, 교차 참조만.
- `601130_menu_price_list_architecture` — 무관.

## §4 Slice 2 — 카테고리 upsert의 `display_order` 안전 처리 (신규 2026-07-17, Human 결정 — ChatGPT+제미나이 교차검증, 재논의 금지)

### §4.0 배경 — Slice 1이 만든 새로운 크래시

§1.2(`upsert_menu_core()`의 `p_display_order default null` 전환)이 카테고리 upsert 블록(0110:424-446)에 예상치 못한 부작용을 낳는다는 것이 확인됐다: 이 블록은 **메뉴의** `p_display_order` 파라미터를 **카테고리의** `display_order` 컬럼에도 그대로 재사용한다 — 서로 다른 두 리소스(메뉴/카테고리)가 파라미터 하나를 공유하는 오버로딩이다. 라이브 스키마 재확인 결과 `catchmenu_pos.menu_categories.display_order`는 `NOT NULL DEFAULT 0`이지만, INSERT 문이 이 컬럼을 명시적으로 컬럼 목록에 포함하고 그 값으로 (이제 NULL일 수 있는) `p_display_order`를 직접 대입하므로, 스키마 기본값(0)은 적용되지 않는다 — PostgreSQL은 컬럼이 INSERT 문에서 아예 생략됐을 때만 DEFAULT를 적용하고, 명시적으로 NULL이 전달되면 그대로 NULL을 넣으려 시도한다.

이번 턴 라이브 재현(임시 트랜잭션, 롤백 처리): 기존 카테고리 행이 있는 상태에서 동일한 `INSERT ... ON CONFLICT ... DO UPDATE` 구조를 `p_display_order := NULL`로 재현했더니, **ON CONFLICT로 기존 행에 매칭되는 경우에도** `null value in column "display_order" of relation "menu_categories" violates not-null constraint` 에러가 발생함을 확인했다:

```
ERROR:  null value in column "display_order" of relation "menu_categories" violates not-null constraint
DETAIL:  Failing row contains (..., null, __slice2_repro_cat, __slice2_repro_cat, null, t, ...).
```

PostgreSQL은 INSERT 후보 행을 구성하는 시점에 NOT NULL 제약을 검사하며, 이는 충돌(conflict) 여부가 결정되기 **전**이다 — 따라서 신규 카테고리 생성 경로뿐 아니라 기존 카테고리를 참조하는 모든 호출(예: 메뉴 생성 시 기존 카테고리 코드를 재사용하면서 `p_display_order`를 생략하는 매우 흔한 패턴)에서도 동일하게 크래시한다.

### §4.1 왜 단순 `COALESCE(p_display_order, 0)`만으로는 부족한가

INSERT VALUES 절에만 `coalesce(p_display_order, 0)`를 적용하면 크래시는 사라지지만, 그 결과는 **오늘 이 워크패킷 전체가 고치려던 것과 동일한 클래스의 "조용한 덮어쓰기" 버그**를 카테고리 리소스에 새로 만든다: `ON CONFLICT ... DO UPDATE`가 `excluded.display_order`(이미 0으로 coalesce된 값)를 참조하게 만들면, 기존 카테고리를 다른 목적(예: 카테고리 이름만 갱신)으로 다시 참조하면서 `p_display_order`를 생략한 호출이 있을 때 그 카테고리의 `display_order`가 조용히 0으로 리셋된다 — `excluded.display_order`는 VALUES 절에서 이미 0으로 coalesce된 값이므로 "생략됐었다"는 정보 자체가 이 시점엔 이미 사라져 있다.

### §4.2 설계 — INSERT와 UPDATE에서 서로 다른 coalesce 대상을 쓴다

핵심은 DO UPDATE SET 절에서 `excluded.display_order`가 아니라 **함수 파라미터 `p_display_order` 원본**을 직접 참조하는 것이다 — PL/pgSQL 함수 파라미터는 SQL 문 내부에서 스코프 안에 있으므로 `excluded.*`를 거치지 않고 그대로 참조할 수 있고, 이렇게 하면 "생략됨(NULL)"이라는 정보가 VALUES 절의 coalesce와 무관하게 DO UPDATE SET 절까지 그대로 보존된다.

```sql
-- 변경 전 (0110:424-446)
if p_category_code is not null then
    insert into catchmenu_pos.menu_categories (
      tenant_id, store_id,
      category_code, category_name,
      display_order
    ) values (
      p_tenant_id, p_store_id,
      p_category_code,
      coalesce(
        p_category_name_ko, p_category_code
      ),
      p_display_order
    )
    on conflict (store_id, category_code)
    do update set
      category_name = coalesce(
        excluded.category_name,
        catchmenu_pos.menu_categories
          .category_name
      ),
      updated_at = now()
    returning id into v_category_id;
  end if;

-- 변경 후
if p_category_code is not null then
    insert into catchmenu_pos.menu_categories (
      tenant_id, store_id,
      category_code, category_name,
      display_order
    ) values (
      p_tenant_id, p_store_id,
      p_category_code,
      coalesce(
        p_category_name_ko, p_category_code
      ),
      coalesce(p_display_order, 0)
    )
    on conflict (store_id, category_code)
    do update set
      category_name = coalesce(
        excluded.category_name,
        catchmenu_pos.menu_categories
          .category_name
      ),
      display_order = coalesce(
        p_display_order,
        catchmenu_pos.menu_categories.display_order
      ),
      updated_at = now()
    returning id into v_category_id;
  end if;
```

의미:

- **INSERT 경로(신규 카테고리, ON CONFLICT 미발생)**: `p_display_order`가 생략되면 `0`(스키마 기본값과 동일한 의미의 생성 시점 기본값) — `price`의 `coalesce(p_price, 0)`과 동일한 성격.
- **UPDATE 경로(ON CONFLICT DO UPDATE, 기존 카테고리)**: `p_display_order`가 생략되면(NULL) 기존 `display_order` 값을 보존, 명시적으로 값이 오면 그 값으로 교체 — 메뉴 쪽 `is_kds_required`/`kitchen_zone`/`display_order`와 동일한 `coalesce(p_x, x)` 패턴.
- `excluded.display_order`를 참조하지 않고 `p_display_order` 원본을 직접 참조하는 것이 핵심이다 — `excluded.display_order`를 썼다면 VALUES 절에서 이미 `coalesce(..., 0)`된 값이라 "생략됐었다"는 정보가 소실되어, §4.1이 지적한 것과 같은 조용한 리셋 버그가 그대로 재발했을 것이다.

**참고**: 이 카테고리 `display_order`는 메뉴의 `display_order`와 물리적으로 다른 컬럼(`catchmenu_pos.menu_categories.display_order` vs `catchmenu_pos.menus.display_order`)이다 — 이번 수정은 메뉴 쪽 `coalesce(p_display_order, display_order)`(0110:518-525, §1 point 2, 변경 불필요로 이미 확정됨)와 전혀 다른 코드 블록이며 서로 간섭하지 않는다.

### §4.3 다른 제약/로직과 무관 확인

이 Slice는 `display_order`(정수, NOT NULL) 하나만 다룬다 — `allergen_info`/JSONB 관련 제약(`chk_menu_allergen_object`)이나 §1.3의 `v_clean_allergen_info` 재설계에는 어떤 영향도 주지 않는다. `menu_not_found`/`menu_code_duplicate` 검증 순서(Slice 3, `601114_ChangeContract_Store_Admin_Menu_Rpc_Correction.md` §2.10.1)나 카테고리 upsert의 매칭 키(`on conflict (store_id, category_code)`)도 변경하지 않는다 — 오직 `display_order` 값의 계산 방식만 바뀐다.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, TestPlan/ChangeContract 단계로 진행 가능.** §1에서 네 필드 전부의 시그니처 변경(§1.1/§1.2)과 `allergen_info`의 NULL-구분 재설계(§1.3)를 라인 단위 before/after로 제시했다 — `is_kds_required`/`kitchen_zone`/`display_order`의 UPDATE 절 코드 자체는 이미 올바른 모양이라 변경이 불필요하다는 것과, `allergen_info`만 별도의 NULL-구분 재설계가 필요한 이유를 근거와 함께 명시했다. §2에서 `menu_options`가 다른 계약이라 제외됨을 SQL 설계 관점에서도 재확인했다. **§4(Slice 2, 신규)에서 §1.2의 부작용으로 카테고리 upsert에 새로 발생한 NOT NULL 크래시를 라이브 재현으로 확인하고, INSERT/UPDATE 경로별로 서로 다른 coalesce 대상(`excluded.display_order`가 아닌 `p_display_order` 원본)을 쓰는 설계로 크래시와 조용한 덮어쓰기 재발 둘 다 방지했다.** `.sql` 파일은 생성·수정하지 않았다.
