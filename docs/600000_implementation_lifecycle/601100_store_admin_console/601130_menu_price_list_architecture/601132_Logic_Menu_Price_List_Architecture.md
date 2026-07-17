# 601132_Logic_Menu_Price_List_Architecture.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`menu_price_list_architecture`

## §0 분리 이력 및 설계 방향 (Human 결정, 2026-07-16, 재논의 금지)

이 문서는 `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §8-§12를 물리적으로 분리해 옮긴 것이다 — 분리 근거는 `601131_Overview_Menu_Price_List_Architecture.md` §0 참조. 짝 문서 `601131_Overview.md`(§2-§5)가 완료한 1단계 조사 결과를 전제로 이 Logic 문서가 2-5단계(스키마/리졸버/마이그레이션/통합) 설계를 다룬다.

**설계 방향(재확인)**: 메뉴 가격을 "메뉴 하나=가격 하나"(`menus.price` 단일 컬럼) 모델에서 가격표(price_list) 기반 모델로 전면 재설계한다. 홀/포장은 기본 같은 가격표 공유(분리 가능), 배달은 별도 가격표, 입점형 매장은 채널이 아니라 별도 가격표 배정 대상. 옵션 가격은 기본 공통, 필요시만 override. 주문 시점 가격은 `order_items`에 스냅샷 고정. 모든 우선순위 로직은 단일 canonical resolver(`resolve_menu_price()`)로 집중.

## §1 Price List 스키마 설계 (2단계)

```sql
create table catchmenu_pos.price_lists (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  name text not null,
  currency text not null default 'KRW',
  valid_from timestamptz,
  valid_to timestamptz,
  status text not null default 'ACTIVE',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_price_list_status check (status in ('ACTIVE', 'DRAFT', 'ARCHIVED')),
  constraint chk_price_list_valid_range check (
    valid_from is null or valid_to is null or valid_from <= valid_to
  )
);

create table catchmenu_pos.price_list_assignments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  price_list_id uuid not null references catchmenu_pos.price_lists(id),
  store_id uuid references catchmenu_hq.stores(id),      -- null = 브랜드 전체(모든 매장) 배정
  sales_channel text,                                     -- null = 채널 무관 기본가. 값 예: 'DINE_IN'/'TAKEOUT'/'DELIVERY'/'KIOSK'
  provider_id text,                                        -- null = 채널 내 공급자 무관. 값 예: 'DELIVERY_BAEMIN'(0057의 platform_type 값 재사용)
  priority int not null default 0,
  created_at timestamptz not null default now()
);

create table catchmenu_pos.menu_prices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  price_list_id uuid not null references catchmenu_pos.price_lists(id),
  menu_id uuid not null references catchmenu_pos.menus(id),
  amount int not null,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_menu_price_amount check (amount >= 0),
  constraint chk_menu_price_range check (effective_to is null or effective_from <= effective_to)
);

create table catchmenu_pos.option_item_prices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  price_list_id uuid not null references catchmenu_pos.price_lists(id),
  option_item_id uuid not null references catchmenu_pos.menu_option_items(id),
  price_delta int not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

**`menus.price`의 의미 재정의**: 컬럼을 삭제하지 않는다 — Human 결정대로 "브랜드 기준가격"으로 의미를 바꾸고, `resolve_menu_price()`의 최종 폴백 단계로만 쓴다(§2). `601131_Overview.md` §2의 9개 소비 지점 중 아직 `resolve_menu_price()`로 전환되지 않은 것은 계속 이 컬럼을 읽으므로, 전환 전까지는 사실상 지금과 동일하게 동작한다.

**미해결 설계 문제(구현 전 반드시 결정 필요, §5 (b) Open Item)**: `price_list_assignments`의 `store_id`/`sales_channel`/`provider_id`가 전부 nullable이라, "매장 A의 DINE_IN 기본가" 배정을 실수로 두 번 만들어도 Postgres 표준 UNIQUE 제약은 NULL을 서로 다른 값으로 취급해 막지 못한다(`NULL <> NULL`) — 부분 UNIQUE 인덱스(`coalesce(store_id, '<sentinel>')` 형태) 또는 별도 검증 트리거가 필요하다. 이 문서는 문제를 특정할 뿐 해결 SQL을 확정하지 않는다.

### §1.1 `price_lists.valid_from`/`valid_to` 결정 (2026-07-16, Stage 4 Architecture Verification 발견 — 결정 완료)

**발견**: 위 스키마의 `valid_from`/`valid_to`는 `chk_price_list_valid_range` CHECK로 데이터 무결성만 보장될 뿐, §2의 리졸버 원안은 `pl.status = 'ACTIVE'`만 확인하고 이 두 컬럼을 실제로는 전혀 읽지 않았다 — 정의만 되고 안 쓰이는 죽은 컬럼이었다.

**결정: 제거하지 않고, 리졸버에 실제로 반영한다.** 근거:
1. `menu_prices`가 이미 `effective_from`/`effective_to`(개별 가격 항목 단위 유효기간)를 갖고 있고 리졸버가 이를 실제로 쓴다 — `price_lists`의 `valid_from`/`valid_to`(가격표 전체 단위 유효기간)도 같은 시간 모델을 공유하는 것이 두 계층(가격표 자체의 유효기간 vs. 가격표 안 개별 가격의 유효기간) 일관성상 자연스럽다.
2. `status` 필드만으로는 "미래 프로모션을 미리 등록해 두고 특정 시각에 자동 전환"이 불가능하다 — `status`를 `ACTIVE`로 미리 바꿔두면 즉시 적용되고, 배치/cron으로 상태를 전환하는 별도 인프라가 필요해진다. `valid_from`/`valid_to`를 리졸버가 직접 읽으면 이 문제가 스키마 차원에서 해결된다(예: "2026-08-01부터 여름 프로모션 가격표 자동 적용").
3. 컬럼을 만들어두고 안 쓰는 것 자체가 오늘 이 세션이 반복해서 지적해 온 phantom/죽은 컬럼 패턴이다 — 이번엔 구현 전에 미리 잡는다.

**반영 방법**: §2의 **Tier 1-5**(전부 `price_lists`를 조인하는 tier)에서 `pl.status = 'ACTIVE'` 조건 옆에 `(pl.valid_from is null or pl.valid_from <= p_at) and (pl.valid_to is null or pl.valid_to > p_at)`를 공통 조건으로 추가했다(§2 SQL 참고). `valid_from`/`valid_to`가 둘 다 NULL인 가격표는 무기한 유효(기존 동작과 동일)이므로 하위 호환이다. **(2026-07-16 정정, Stage 4 재검증(2차) — Cursor+Codex 공통 발견)** Tier 6(menu 기준가 폴백)은 `price_lists`를 거치지 않는 단순 `menus.price` 조회이므로 이 조건이 원래부터 해당 없다 — 이전 서술이 전체 tier 범위로 잘못 확대돼 있었다.

### §1.2 RLS 설계 (2026-07-16, Stage 4 Architecture Verification 발견 — 이전 판본은 RLS 자체가 없었음)

라이브 코드베이스의 기존 RLS 관례(`sql/migrations/0022_create_rls_policies.sql:310-337`, `catchmenu_pos.menus`/`menu_option_groups`/`menu_option_items`에 적용된 패턴)를 그대로 따른다: `enable row level security` + `force row level security`를 별도 `ALTER TABLE` 문으로 실행하고, `catchmenu_common.current_tenant_id()`/`catchmenu_common.current_store_id()`를 쓰는 `for all to authenticated` 정책 하나씩.

**`price_lists`/`price_list_assignments`는 기존 관례를 그대로 적용할 수 없다** — 기존 관례는 테이블에 `store_id`가 직접(비정규화) 존재하는 것을 전제하는데, `price_lists`는 애초에 매장 컬럼이 없고(브랜드 단위 개념), `menu_prices`/`option_item_prices`도 `store_id`가 없다(가격표를 통해 간접적으로만 매장에 연결됨). 아래는 이 구조적 차이를 반영한 정책 설계다:

```sql
alter table catchmenu_pos.price_lists enable row level security;
alter table catchmenu_pos.price_lists force row level security;

drop policy if exists price_lists_tenant_isolation on catchmenu_pos.price_lists;
create policy price_lists_tenant_isolation
  on catchmenu_pos.price_lists
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );
-- price_lists는 브랜드(테넌트) 단위 개념이라 store_id 자체가 없다 — 테넌트 격리만 적용.
-- 어느 매장에 보이는지는 price_list_assignments가 결정한다(아래).

alter table catchmenu_pos.price_list_assignments enable row level security;
alter table catchmenu_pos.price_list_assignments force row level security;

drop policy if exists price_list_assignments_store_isolation on catchmenu_pos.price_list_assignments;
create policy price_list_assignments_store_isolation
  on catchmenu_pos.price_list_assignments
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and (store_id = catchmenu_common.current_store_id() or store_id is null)
  );
-- store_id is null = 브랜드 전체 배정 행은 모든 매장 사용자에게 보여야 하므로 OR로 포함.

alter table catchmenu_pos.menu_prices enable row level security;
alter table catchmenu_pos.menu_prices force row level security;

drop policy if exists menu_prices_store_isolation on catchmenu_pos.menu_prices;
create policy menu_prices_store_isolation
  on catchmenu_pos.menu_prices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and exists (
      select 1 from catchmenu_pos.price_list_assignments pla
      where pla.price_list_id = menu_prices.price_list_id
        and pla.tenant_id = catchmenu_common.current_tenant_id()
        and (pla.store_id = catchmenu_common.current_store_id() or pla.store_id is null)
    )
  );

alter table catchmenu_pos.option_item_prices enable row level security;
alter table catchmenu_pos.option_item_prices force row level security;

drop policy if exists option_item_prices_store_isolation on catchmenu_pos.option_item_prices;
create policy option_item_prices_store_isolation
  on catchmenu_pos.option_item_prices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and exists (
      select 1 from catchmenu_pos.price_list_assignments pla
      where pla.price_list_id = option_item_prices.price_list_id
        and pla.tenant_id = catchmenu_common.current_tenant_id()
        and (pla.store_id = catchmenu_common.current_store_id() or pla.store_id is null)
    )
  );
```

**트레이드오프, 명시적으로 남김(§5 (h) 신규 Open Item)**: `menu_prices`/`option_item_prices`의 정책은 행마다 `EXISTS` 서브쿼리를 실행한다 — 기존 관례(비정규화된 `store_id` 컬럼 + 단순 등호 비교)보다 느리다. 대안은 `menu_prices`/`option_item_prices`에도 `store_id`(nullable)를 비정규화 컬럼으로 추가해 기존 관례와 동일한 단순 정책을 쓰는 것이지만, 이는 §1의 스키마 자체를 바꾸는 결정이라 이 문서가 임의로 채택하지 않는다 — Stage 4 이전에 Human이 "일관성(단순 정책) vs. 정규화(서브쿼리 비용)" 중 선택해야 한다. 라이브 데이터가 매장 1개·메뉴 9건(`601131_Overview.md` §5) 규모인 현재는 성능 차이가 무의미하므로, 이번 워크패킷은 정규화된 스키마(§1 그대로)를 유지하고 `EXISTS` 기반 정책으로 진행하는 쪽을 권고하되 최종 결정은 아래 §5 (h)에 open item으로 남긴다.

## §2 `resolve_menu_price()` 캐노니컬 리졸버 설계 (3단계)

우선순위(Human 결정): **store+provider 특정가 > store+channel가 > store 기본가 > brand+channel가 > brand 기본가 > menu 기준가**.

**(2026-07-16 정정, Stage 4 Architecture Verification — Cursor+Codex+안티 삼중 검증에서 발견된 4가지 필수 수정 반영: (1) Tier 4에 `pla.provider_id is null` 필터 추가 — 없으면 브랜드 단위 store+provider 특정가 행이 Tier 4에서도 잘못 매칭될 수 있었다. (2) Tier 1-5(`price_lists`를 조인하는 tier 전부)의 `order by priority desc` 뒤에 명시적 tie-breaker 추가 — 동일 priority일 때 결과가 비결정적이었다. (3) Tier 6(menu 기준가 폴백)에 `store_id`/`is_active` 필터와 명시적 NOT FOUND 분기 추가 — 원래는 메뉴가 없거나 다른 매장 소속이어도 조용히 `amount: null`을 반환했다. (4) `price_lists.valid_from`/`valid_to`를 Tier 1-5의 공통 조건에 실제로 반영 — §1 참고, 스키마에서 제거하지 않고 실사용 컬럼으로 확정했다(§8 결정). (2026-07-16 추가 정정, Stage 4 재검증(2차): (2)/(4)는 "Tier 1-5"가 정확한 범위다 — Tier 6은 `price_lists`를 거치지 않는 단순 `menus.price` 폴백이라 애초에 tie-breaker/유효기간 조건이 해당 없다.)**

```sql
create or replace function catchmenu_pos.resolve_menu_price(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid,
  p_sales_channel text default null,
  p_provider_id text default null,
  p_at timestamptz default now()
)
returns jsonb  -- {amount, price_list_id, resolved_tier, resolved_at}
language plpgsql
stable
security definer
set search_path = catchmenu_pos
as $$
declare
  v_amount int;
  v_price_list_id uuid;
  v_tier text;
begin
  -- 공통 조건: 가격표가 ACTIVE 상태이고, p_at이 가격표의 valid_from/valid_to 안에 있고,
  -- p_at이 menu_prices의 유효기간(effective_from/effective_to) 안에 있어야 함.
  -- 아래 Tier 1-5는 이 조건을 전부 공유하며, tier마다 price_list_assignments의 매칭 조건만 달라진다.
  -- (Tier 6은 price_lists를 거치지 않는 별도 menus.price 폴백이라 이 공통 조건과 무관 — 아래 참고.)
  -- 동일 priority가 여러 건 매칭되는 경우를 대비해 Tier 1-5에 명시적 tie-breaker
  -- (pla.created_at desc, pla.id desc, 그리고 menu_prices 쪽 overlap 대비 mp.effective_from desc)를 둔다.

  -- 1) store+provider 특정가
  select mp.amount, mp.price_list_id into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp
    on mp.price_list_id = pla.price_list_id and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl on pl.id = mp.price_list_id and pl.status = 'ACTIVE'
    and (pl.valid_from is null or pl.valid_from <= p_at)
    and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id and pla.store_id = p_store_id
    and pla.sales_channel is not distinct from p_sales_channel
    and pla.provider_id = p_provider_id and p_provider_id is not null
    and mp.effective_from <= p_at and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;
  if found then
    return jsonb_build_object('amount', v_amount, 'price_list_id', v_price_list_id, 'resolved_tier', 'STORE_PROVIDER', 'resolved_at', p_at);
  end if;

  -- 2) store+channel가 (provider 무관)
  select mp.amount, mp.price_list_id into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp on mp.price_list_id = pla.price_list_id and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl on pl.id = mp.price_list_id and pl.status = 'ACTIVE'
    and (pl.valid_from is null or pl.valid_from <= p_at)
    and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id and pla.store_id = p_store_id
    and pla.sales_channel is not distinct from p_sales_channel and p_sales_channel is not null
    and pla.provider_id is null
    and mp.effective_from <= p_at and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;
  if found then
    return jsonb_build_object('amount', v_amount, 'price_list_id', v_price_list_id, 'resolved_tier', 'STORE_CHANNEL', 'resolved_at', p_at);
  end if;

  -- 3) store 기본가 (채널/공급자 무관)
  select mp.amount, mp.price_list_id into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp on mp.price_list_id = pla.price_list_id and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl on pl.id = mp.price_list_id and pl.status = 'ACTIVE'
    and (pl.valid_from is null or pl.valid_from <= p_at)
    and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id and pla.store_id = p_store_id
    and pla.sales_channel is null and pla.provider_id is null
    and mp.effective_from <= p_at and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;
  if found then
    return jsonb_build_object('amount', v_amount, 'price_list_id', v_price_list_id, 'resolved_tier', 'STORE_DEFAULT', 'resolved_at', p_at);
  end if;

  -- 4) brand+channel가 (store_id is null = 브랜드 전체 배정)
  -- 2026-07-16 정정: pla.provider_id is null 추가 — 없으면 브랜드+provider 특정가(향후 확장 시)가
  -- 여기서도 잘못 매칭되어 store+provider(Tier 1)만큼 특정적이지 않은데도 이 tier에서 소비될 수 있었다.
  select mp.amount, mp.price_list_id into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp on mp.price_list_id = pla.price_list_id and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl on pl.id = mp.price_list_id and pl.status = 'ACTIVE'
    and (pl.valid_from is null or pl.valid_from <= p_at)
    and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id and pla.store_id is null
    and pla.sales_channel is not distinct from p_sales_channel and p_sales_channel is not null
    and pla.provider_id is null
    and mp.effective_from <= p_at and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;
  if found then
    return jsonb_build_object('amount', v_amount, 'price_list_id', v_price_list_id, 'resolved_tier', 'BRAND_CHANNEL', 'resolved_at', p_at);
  end if;

  -- 5) brand 기본가
  select mp.amount, mp.price_list_id into v_amount, v_price_list_id
  from catchmenu_pos.price_list_assignments pla
  join catchmenu_pos.menu_prices mp on mp.price_list_id = pla.price_list_id and mp.menu_id = p_menu_id
  join catchmenu_pos.price_lists pl on pl.id = mp.price_list_id and pl.status = 'ACTIVE'
    and (pl.valid_from is null or pl.valid_from <= p_at)
    and (pl.valid_to is null or pl.valid_to > p_at)
  where pla.tenant_id = p_tenant_id and pla.store_id is null
    and pla.sales_channel is null and pla.provider_id is null
    and mp.effective_from <= p_at and (mp.effective_to is null or mp.effective_to > p_at)
  order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc
  limit 1;
  if found then
    return jsonb_build_object('amount', v_amount, 'price_list_id', v_price_list_id, 'resolved_tier', 'BRAND_DEFAULT', 'resolved_at', p_at);
  end if;

  -- 6) menu 기준가 (menus.price 폴백, §1의 재정의)
  -- 2026-07-16 정정: store_id 필터와 is_active 필터, 명시적 NOT FOUND 분기 추가 — 이전에는
  -- p_menu_id가 다른 매장 소속이거나 존재하지 않아도 amount: null을 조용히 반환했다.
  select price into v_amount
  from catchmenu_pos.menus
  where id = p_menu_id and tenant_id = p_tenant_id and store_id = p_store_id and is_active = true;
  if not found then
    return jsonb_build_object('amount', null, 'price_list_id', null, 'resolved_tier', 'NOT_FOUND', 'resolved_at', p_at);
  end if;
  return jsonb_build_object('amount', v_amount, 'price_list_id', null, 'resolved_tier', 'MENU_BASE', 'resolved_at', p_at);
end;
$$;
```
**(2026-07-16 정정, Stage 4 재검증(2차))** Tier 1-5 모두 `IS NOT DISTINCT FROM`(NULL-안전 비교)을 채널 매칭에 쓴다 — `p_sales_channel`이 NULL로 넘어오는 호출(예: 아직 채널을 특정하지 않는 관리자 화면 미리보기)도 안전하게 처리하기 위함. Tier 6은 `price_lists`를 거치지 않는 단순 `menus.price` 폴백이라 채널 매칭 자체가 없다 — 이전 서술은 이 지점에서 전체 tier 범위로 잘못 확대돼 있었다. 실제 채택 시 Tier 1-5와 Tier 6 폴백 전체를 하나의 `UNION ALL` + `ORDER BY tier_rank LIMIT 1` 형태로 합쳐 더 짧게 쓸 수도 있으나, 이 문서는 우선순위 각 단계를 명시적으로 보여주는 순차 분기 형태로 제시했다 — 최종 구현 형태는 Stage 4 결정.

**호출자 계약 변경 주의(2026-07-16)**: Tier 6에 NOT FOUND 분기가 추가되면서 `resolved_tier`가 `'NOT_FOUND'`일 수 있게 됐다 — §3 Phase 3에서 이 리졸버를 호출로 전환할 9개 소비자는 전부 `resolved_tier = 'NOT_FOUND'` 케이스를 명시적으로 처리해야 한다(예: `create_order()`는 주문 생성 자체를 거부해야 함). 이전 판본(`amount: null`을 조용히 반환)에 맞춰 설계된 소비자 쪽 코드가 있다면 이 계약 변경을 반영해 갱신해야 한다.

## §3 마이그레이션 경로 설계 (4단계)

`menus.price`가 완전 삭제 대상이 아니므로(§1) 이 마이그레이션은 **파괴적 단계가 전혀 없다** — 전부 추가적(additive)이다:

1. **Phase 0(스키마 준비)**: §1의 4개 테이블 생성. 기존 함수 0건 변경 — 순수 추가라 무엇도 깨지지 않는다.
2. **Phase 1(백필)**: 매장별로 "브랜드 표준 홀/포장 가격표" 1건을 `price_lists`에 생성(Human 결정: 홀/포장은 기본 같은 가격표 공유), `price_list_assignments`에 `store_id=<해당 매장>, sales_channel=null(홀+포장 공유), provider_id=null`로 배정, 기존 `menus.price > 0`인 8건(`601131_Overview.md` §5)을 `menu_prices`로 그대로 복사(`amount = menus.price`, `effective_from = now()`). 데이터 규모가 8건뿐이라 이 단계는 사실상 즉시 끝난다.
3. **Phase 2(병행 기간)**: `upsert_menu()`(`601112_Logic.md` §2, §4에서 재확인하듯 변경 불필요)는 계속 `menus.price`를 직접 쓴다 — 이 시점부터 관리자가 가격을 바꾸면 `menus.price`(브랜드 기준가)만 갱신되고 `menu_prices`(매장 가격표)는 Phase 1의 스냅샷에 머문다는 **불일치 위험**이 생긴다. 이 불일치를 어떻게 관리할지(예: `upsert_menu()`가 가격 변경 시 매장 기본 가격표의 `menu_prices`도 함께 갱신할지)는 §4에서 다시 다룬다.
4. **Phase 3(소비자 전환)**: `601131_Overview.md` §2의 9개 소비 지점을 하나씩 `resolve_menu_price()` 호출로 바꾼다. 전부 "직접 컬럼 읽기 → 리졸버 호출"이라는 **같은 패턴**이므로, 오늘 확립한 "같은 패턴이면 묶는다" 원칙에 따르면 9개를 한 워크패킷에서 순차 처리하는 것이 자연스럽다(§5 (c)에서 옵션으로 남김). 각 전환은 독립적으로 검증 가능 — 하나를 바꿔도 나머지 8개는 여전히 `menus.price`를 읽으므로 부분 전환 중에도 시스템 전체가 계속 동작한다.
5. **Phase 4(정리)**: 별도 삭제 단계 없음 — `menus.price`는 영구적으로 폴백 계층(tier 6)으로 남는다.

## §4 `upsert_menu()`와의 통합 (5단계)

**결론부터: `601112_Logic.md` §2의 `upsert_menu()`/`upsert_menu_core()` 설계는 변경할 필요가 없다.** `menus.price`가 "브랜드 기준가"로 의미가 바뀌었을 뿐 컬럼 자체와 그 컬럼을 다루는 `601112_Logic.md` §2의 로직은 그대로 유효하다 — `upsert_menu()`는 여전히 "메뉴 레코드(+브랜드 기준가+옵션)"만 관리하고, 매장/채널/공급자별 가격 오버라이드는 **완전히 별도의 새 RPC 표면**(예: `set_menu_price_list_entry()`, 이번 문서에서 설계하지 않음, §5 (d) Open Item)이 `price_lists`/`menu_prices`/`price_list_assignments`를 직접 다룬다.

유일하게 검토가 필요한 지점은 §3 Phase 2의 불일치 위험이다 — 두 가지 옵션(Human 결정 필요, §5 (e)):

| 옵션 | 내용 |
|---|---|
| A. `upsert_menu_core()`가 매장 기본 가격표도 함께 갱신 | 가격이 바뀌면 `menus.price` UPDATE에 더해 `menu_prices`의 "해당 매장 기본 가격표" 행도 같은 트랜잭션에서 upsert. 관리자 입장에서 직관적(가격 하나만 바꾸면 끝)이지만 `upsert_menu()`가 다시 가격표 테이블까지 알아야 해 옵션 C의 "책임 분리" 취지와 다소 어긋난다. |
| B. `upsert_menu()`는 브랜드 기준가만, 매장가는 별도 RPC로 명시적으로만 갱신 | 책임이 명확히 분리되지만, 관리자가 "메뉴 정보 수정" 화면에서 가격을 바꿔도 실제 판매가(매장 가격표)는 안 바뀌는 반직관적 상황이 생길 수 있다 — Flutter 쪽에서 "이 매장에서 판매 중인 가격을 바꾸려면 별도 화면/RPC를 쓰세요"라는 안내가 필요해진다. |

이 문서는 채택하지 않는다.

## §5 Open Items

(a) `601131_Overview.md` §2에서 확인하지 않은 나머지 `menus` 참조 파일(32개 중 9개 외 23개) — Stage 4 전 전수 재확인 권고(Overview §6 (a)와 동일 항목, 설계 단계에도 영향을 주므로 여기 다시 기록).
(b) §1의 `price_list_assignments` nullable-컬럼 UNIQUE 제약 문제 — 부분 인덱스/트리거 설계 필요.
(c) §3 Phase 3(9개 소비자 전환)을 몇 개 워크패킷으로 나눌지 — 오늘 원칙상 "같은 패턴"이라 하나로 묶는 게 자연스러워 보이나, `create_order()`(실제 결제·주문 금액에 직결)와 나머지(조회/동기화 위주)의 리스크 수준이 달라 보여 분리 여지도 있음 — Human 결정 필요.
(d) `set_menu_price_list_entry()` 류의 신규 가격표 관리 RPC — 이번 문서는 스키마/리졸버만 설계했고 이 CRUD RPC 자체는 설계하지 않았다.
(e) §4의 옵션 A/B(가격 변경 시 매장 가격표 동시 갱신 여부) — Human 결정 필요.
(f) `order_items` 2세대 미사용 컬럼 6개(`601131_Overview.md` §3)를 이번 재설계에 맞춰 배선할지, 아니면 ChatGPT 제안 필드(특히 `price_list_id`/`price_resolved_at`)로 새로 추가할지, 혼합할지 — 이번 문서는 비교표만 제시했고 최종 스키마를 확정하지 않았다.
(g) **[해소됨, 2026-07-16 Human 결정]** 원래 "이 확장을 `601110`/`601112`에 남길지 별도 워크패킷으로 분리할지"였던 항목 — **분리로 확정**됐고, 그 결과가 이 문서 쌍(`601131`/`601132`)이다. 더 이상 열린 질문이 아니다.
(h) **[신규, 2026-07-16 Stage 4 Architecture Verification 발견, §1.2]** `menu_prices`/`option_item_prices`의 RLS 정책이 `EXISTS` 서브쿼리로 `price_list_assignments`를 조인한다 — 기존 코드베이스 관례(비정규화 `store_id` 컬럼 + 단순 등호)보다 느리다. 대안은 두 테이블에 `store_id`(nullable)를 비정규화 컬럼으로 추가하는 것이나, 이는 §1 스키마 자체를 바꾸는 결정이라 이 문서가 임의 채택하지 않았다 — "단순 정책(비정규화) vs. 정규화 유지(서브쿼리 비용)" 중 Human 결정 필요. 현재 데이터 규모(매장 1개)에서는 무의미한 차이이므로 이번 워크패킷은 정규화 유지를 권고안으로 제시한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601131_Overview_Menu_Price_List_Architecture.md` — 이 Logic 문서의 직접 전제(1단계 조사 결과 전체).
- `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §2 — `upsert_menu()`의 실제 설계(§4에서 "변경 불필요"로 결론짓는 대상 문서).

### Full Rules Required

- `sql/migrations/0026_create_order_rpc.sql:126-190` — `create_order()`, §3 Phase 3 전환의 최고 리스크 지점.
- `sql/migrations/0086_create_hq_menu_distribution_rpc.sql:770-808` — `max_price_override_pct` 기반 브랜드/매장 가격 계층의 유일한 기존 코드 선례, §1 스키마 설계의 직접 참고.
- `sql/migrations/0141_hyper_personalization_menu_customization.sql` — `order_items` 2세대 컬럼(§5 (f))의 출처.
- `sql/migrations/0022_create_rls_policies.sql:305-337` — `catchmenu_pos.menus`/`menu_option_groups`/`menu_option_items`에 적용된 기존 RLS 관례, §1.2 신규 RLS 정책 설계의 직접 템플릿.

### Domain Indexes

- `601100_Readme_Store_Admin_Console.md`(이번 턴에 Subfolder Map 갱신).

### Excluded Rule Families

- phantom 4개 컬럼 복구 — `601112_Logic.md`가 계속 다룸, 이 워크패킷은 분리된 별개.
- `dining_tables`/테이블 CRUD — `601120`(가칭)으로 별도 이관.
- `set_menu_price_list_entry()` 류 CRUD RPC — §5 (d) Open Item, 이번 문서 범위 밖.
- Flutter/클라이언트 코드 — SQL 레이어만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, 내용 손실 없는 분리 완료 — TestPlan/ChangeContract 단계 진행 전 Human 결정 다수 필요.** `601112_Logic.md` §8-§12를 그대로(문구 정정 없이, 문서 간 상호 참조만 갱신) 이 문서로 옮겼다. §1에서 4개 테이블 전체 SQL과 `price_list_assignments`의 nullable-UNIQUE 한계를 미해결로 명시했다. §2에서 Tier 1-5 + Tier 6 폴백으로 구성된 우선순위 `resolve_menu_price()` 전체 SQL을 작성했다. §3에서 파괴적 단계가 없는 4단계 무중단 마이그레이션 경로를 설계했다. §4에서 `upsert_menu()` 설계 자체는 변경 불필요하다고 결론짓고, 유일한 통합 지점(가격 변경 시 매장 가격표 동시 갱신 여부)을 옵션으로 남겼다. §5 (g)에서 원래 "분리할지" Open Item이 이 분리 자체로 해소됐음을 기록했다.

**(2026-07-16 추가 수정, Stage 4 Architecture Verification — Cursor+Codex+안티 삼중 검증에서 발견된 5가지 필수 수정 반영)**: (1) §2 Tier 4에 `pla.provider_id is null` 필터를 추가해 브랜드+provider 특정가가 브랜드+채널 tier에서 잘못 매칭되는 경로를 막았다. (2) §2 Tier 1-5의 `order by priority desc` 뒤에 `mp.effective_from desc, pla.created_at desc, pla.id desc` tie-breaker를 추가해 동일 priority 매칭 시의 비결정성을 없앴다. (3) §2 Tier 6(menu 기준가 폴백)에 `store_id`/`is_active` 필터와 명시적 `NOT_FOUND` 분기를 추가했다 — 이 계약 변경은 §3 Phase 3에서 전환할 9개 소비자 전부에 영향을 주므로 그 사실을 §2 말미에 명시했다. (4) §1.2를 신설해 4개 신규 테이블 전부에 라이브 관례(`0022_create_rls_policies.sql`)를 따른 RLS(`enable`+`force`+정책)를 설계했다 — `price_lists`/`price_list_assignments`는 기존 관례를 그대로 적용했고, `store_id`가 없는 `menu_prices`/`option_item_prices`는 `EXISTS` 서브쿼리 기반으로 설계하되 성능 트레이드오프를 §5 (h)에 Open Item으로 남겼다. (5) §1.1을 신설해 `valid_from`/`valid_to`를 스키마에서 제거하지 않고 리졸버의 Tier 1-5에 실제로 반영하기로 결정했다(§2의 Tier 1-5 공통 조건에 유효기간 조건 추가).

**(2026-07-16 문구 정정, Stage 4 재검증(2차) — Cursor+Codex 공통 발견)**: 위 (2)/(5) 및 §1.1/§2(리졸버 본문 주석과 서술 전체)에서 tier 적용 범위를 전체 tier로 과다 서술했던 부분을 전부 "Tier 1-5"로 정정했다 — Tier 6은 `price_lists`를 거치지 않는 단순 `menus.price` 폴백이라 tie-breaker(우선순위 동률 처리)도 `valid_from`/`valid_to`(가격표 유효기간)도 원래 해당 없다. 설계 자체(SQL)는 처음부터 정확했고, 이번 정정은 그 SQL을 설명하는 산문 서술의 범위 표현만 바로잡은 것이다.

`.sql` 파일은 이번 정정 턴에도 생성·수정하지 않았다.
