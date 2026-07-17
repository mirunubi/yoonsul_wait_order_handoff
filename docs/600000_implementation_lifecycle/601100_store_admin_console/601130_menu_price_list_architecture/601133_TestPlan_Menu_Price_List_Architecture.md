# 601133_TestPlan_Menu_Price_List_Architecture.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code contract drafting, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`menu_price_list_architecture`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 8 implementation of `601132_Logic_Menu_Price_List_Architecture.md` §1-§2 — **Phase 0 only** (§3 of that document): the 4 new tables (`price_lists`/`price_list_assignments`/`menu_prices`/`option_item_prices`), their RLS policies, and the canonical resolver `catchmenu_pos.resolve_menu_price()`, in a new migration file (tentatively `sql/migrations/0165_menu_price_list_architecture_phase0.sql`). Phase 1 (backfill), Phase 2 (parallel operation), Phase 3 (9-consumer cutover), and Phase 4 are explicitly out of scope — this workpacket creates pure new infrastructure that nothing yet calls.

Document number check:

- `601131_Overview_Menu_Price_List_Architecture.md` exists.
- `601132_Logic_Menu_Price_List_Architecture.md` exists.
- `601133_TestPlan_Menu_Price_List_Architecture.md` is the next TestPlan document number for this workpacket.
- `601134_ChangeContract_Menu_Price_List_Architecture.md` is the paired ChangeContract.

Test fixtures use the `<test_tenant_id>`/`<test_store_id>` placeholders (live values `00000000-0000-0000-0000-000000000001`/`00000000-0000-0000-0000-000000000002` as of this document's writing) plus a second, freshly-created `<test_other_tenant_id>`/`<test_other_store_id>` pair for RLS cross-tenant tests (the live DB has only 1 tenant/store — `601131_Overview.md` §5 — so a second tenant/store must be created inline, inside the same `begin;...rollback;` block, for isolation testing). Every section is a self-contained `begin;...rollback;` block — **except §4-§6 (`resolve_menu_price()` tier tests, tie-breaker, and `valid_from`/`valid_to` boundary), which are deliberately one continuous transaction spanning all three sections** (§4.1's opening `begin;` is not matched by a `rollback;` until the end of §6 — see §4.1's precondition note for why: the later sections build on fixtures the earlier ones create, e.g. §5's tie-breaker reuses §4.5's `STORE_DEFAULT` row). Per `000701_Guide_Controlled_AI_Development_Pipeline.md`/AGENTS.md §3.8, since this workpacket's ChangeContract is not yet `APPROVED` at TestPlan-drafting time, all schema/function objects in this document must be created and torn down **inside a transaction that is always rolled back** — no permanent `CREATE TABLE`/`CREATE FUNCTION` outside a transaction until `601134_ChangeContract.md` §10 is explicitly `APPROVED`.

**GRANT note (discovered empirically at Stage 5, not previously documented in `601131`/`601132`)**: `catchmenu_pos.menus` itself has **zero** direct `GRANT`s to `authenticated` (confirmed live via `information_schema.role_table_grants`) — every table in this schema family is accessed exclusively through `SECURITY DEFINER` RPCs, never by direct client `SELECT`/`INSERT`. The 4 new Phase 0 tables follow the same pattern: **no `GRANT` to `authenticated` on any of them**, and `resolve_menu_price()` itself is also **not** granted to `authenticated` (internal-only, matching `0163`'s `_resolve_dining_table_by_number()` precedent — it is meant to be called by future consumer RPCs, not directly by clients). §3's RLS isolation tests below therefore require a **transaction-scoped test-only `GRANT SELECT`** to exercise the policies at all — this grant is explicitly not part of the Phase 0 design and must not appear in the actual migration file (see §3.0).

## §1 Pre-flight checks

Run before modifying or applying anything. If any Stop Condition in `601134_ChangeContract_Menu_Price_List_Architecture.md` is hit, stop and report.

### §1.1 Table/function name collisions — none expected

```sql
select table_schema, table_name from information_schema.tables
where table_name in ('price_lists', 'price_list_assignments', 'menu_prices', 'option_item_prices');

select proname from pg_proc where proname = 'resolve_menu_price';
```

Expected: both queries return 0 rows — none of the 4 table names or the resolver function name are already in use anywhere in the live schema.

### §1.2 RLS helper functions and FK targets exist

```sql
select proname from pg_proc where pronamespace = 'catchmenu_common'::regnamespace and proname in ('current_tenant_id', 'current_store_id');

select table_schema, table_name from information_schema.tables
where (table_schema, table_name) in (
  ('catchmenu_hq', 'tenants'), ('catchmenu_hq', 'stores'),
  ('catchmenu_pos', 'menus'), ('catchmenu_pos', 'menu_option_items')
);
```

Expected: `current_tenant_id`/`current_store_id` both exist (`catchmenu_common`); all 4 FK target tables exist.

### §1.3 `menus.price` still live, still read by the 9 confirmed consumers (boundary baseline)

```sql
select count(*) as priced_menu_count from catchmenu_pos.menus where price > 0;
select max(code) from catchmenu_common.error_codes where error_domain = 'MENU';
```

Record the live value — this workpacket does not touch `menus.price` or any of its 9 confirmed consumers (`601131_Overview.md` §2), so no meaningful drift is expected, but the count establishes a baseline for the boundary check (§7).

### §1.4 Next migration number

```bash
ls sql/migrations/ | sort | tail -3
```

Expected (as of this document's writing): `0165` is the next free number (`0164` is the last applied). Stage 8 must re-run this immediately before creating the file, per the same provisional-number discipline as `0163`/`0164`.

## §2 Table creation + schema/constraint verification

```sql
begin;

-- (Stage 8's actual CREATE TABLE x4 statements go here, verbatim from 601132_Logic.md §1 /
--  601134_ChangeContract.md §2.1 — omitted here for brevity, this TestPlan assumes they've
--  just been run in this same transaction.)

select table_name, column_name, data_type, is_nullable
from information_schema.columns
where table_schema = 'catchmenu_pos'
  and table_name in ('price_lists', 'price_list_assignments', 'menu_prices', 'option_item_prices')
order by table_name, ordinal_position;

select conname, contype, conrelid::regclass as table_name
from pg_constraint
where conrelid::regclass::text in (
  'catchmenu_pos.price_lists', 'catchmenu_pos.price_list_assignments',
  'catchmenu_pos.menu_prices', 'catchmenu_pos.option_item_prices'
)
order by table_name, contype;

rollback;
```

Expected: `price_lists` has `chk_price_list_status` (in `('ACTIVE','DRAFT','ARCHIVED')`) and `chk_price_list_valid_range`; `menu_prices` has `chk_menu_price_amount` (`amount >= 0`) and `chk_menu_price_range`; all 4 tables have the FK constraints to `catchmenu_hq.tenants`/`catchmenu_hq.stores`/`catchmenu_pos.price_lists`/`catchmenu_pos.menus`/`catchmenu_pos.menu_option_items` exactly as specified in `601132_Logic.md` §1. Constraint violation spot-checks (`insert ... status='INVALID'` etc.) recommended at Stage 8 but not spelled out row-by-row here — the constraint definitions themselves are the primary artifact to confirm.

## §3 RLS isolation

### §3.0 Test-only GRANT (not part of the design, see §0's GRANT note)

```sql
begin;
-- ... 4 tables created ...
grant select on catchmenu_pos.price_lists, catchmenu_pos.price_list_assignments,
  catchmenu_pos.menu_prices, catchmenu_pos.option_item_prices to authenticated;
```

### §3.1 Cross-tenant isolation — `price_lists`/`price_list_assignments`/`menu_prices`

```sql
-- (continuing the §3.0 transaction)

insert into catchmenu_hq.tenants (id, tenant_code, tenant_name)
values ('<test_other_tenant_id>'::uuid, 'STAGE5-TEST', 'Test Other Tenant');
insert into catchmenu_hq.stores (id, tenant_id, store_code, store_name)
values ('<test_other_store_id>'::uuid, '<test_other_tenant_id>'::uuid, 'STAGE5-STORE', 'Test Other Store');

select id as menu_id from catchmenu_pos.menus
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid and is_active = true
limit 1 \gset

insert into catchmenu_pos.price_lists (id, tenant_id, name, status)
values ('<pl_own>'::uuid, '<test_tenant_id>'::uuid, 'Own Tenant List', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, priority)
values ('<pla_own>'::uuid, '<test_tenant_id>'::uuid, '<pl_own>'::uuid, '<test_store_id>'::uuid, 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount)
values ('<test_tenant_id>'::uuid, '<pl_own>'::uuid, :'menu_id'::uuid, 5000);

insert into catchmenu_pos.price_lists (id, tenant_id, name, status)
values ('<pl_other>'::uuid, '<test_other_tenant_id>'::uuid, 'Other Tenant List', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, priority)
values ('<pla_other>'::uuid, '<test_other_tenant_id>'::uuid, '<pl_other>'::uuid, '<test_other_store_id>'::uuid, 0);

set local role authenticated;
set local request.jwt.claims to '{"app_metadata":{"tenant_id":"<test_other_tenant_id>","store_id":"<test_other_store_id>"}}';
select count(*) as sees_price_lists from catchmenu_pos.price_lists;
select count(*) as sees_price_list_assignments from catchmenu_pos.price_list_assignments;
select count(*) as sees_menu_prices from catchmenu_pos.menu_prices;
reset role;

set local role authenticated;
set local request.jwt.claims to '{"app_metadata":{"tenant_id":"<test_tenant_id>","store_id":"<test_store_id>"}}';
select count(*) as sees_price_lists from catchmenu_pos.price_lists;
select count(*) as sees_price_list_assignments from catchmenu_pos.price_list_assignments;
select count(*) as sees_menu_prices from catchmenu_pos.menu_prices;
reset role;

rollback;
```

Expected (live-verified at Stage 5 with this exact scenario shape): as the other tenant — `sees_price_lists=1` (only their own row), `sees_price_list_assignments=1` (only their own), `sees_menu_prices=0` (they inserted none, and critically **do not** see the own-tenant's `menu_prices` row that exists in the table). As the own tenant — `sees_price_lists=1`, `sees_price_list_assignments=1`, `sees_menu_prices=1` (their own row, via the `EXISTS` subquery against `price_list_assignments` correctly matching their own `store_id`).

### §3.2 `price_list_assignments` brand-wide row (`store_id is null`) visible to all stores in the tenant

```sql
-- within the same style of transaction as §3.1, insert a price_list_assignments row with
-- store_id = null for <test_tenant_id>, then re-run the "own tenant" role-switch block and
-- confirm sees_price_list_assignments increases by 1 (the store_id IS NULL OR store_id = current_store_id() clause).
```

Expected: a brand-wide assignment (`store_id is null`) is visible to a session whose JWT `store_id` claim is any store belonging to that tenant — confirms the `(store_id = current_store_id() or store_id is null)` clause's OR branch actually fires, not just the equality branch already exercised in §3.1.

### §3.3 `option_item_prices` — MUST be independently reproduced, not accepted on structural analogy alone

`option_item_prices`'s RLS policy (`601132_Logic.md` §1.2) is textually identical in structure to `menu_prices`'s (same `EXISTS` subquery shape against `price_list_assignments`, differing only in which column joins — `option_item_id` vs. `menu_id`, both foreign keys unrelated to the isolation logic itself). **Structural similarity is not proof of behavioral correctness** — Stage 8/9 must run its own live reproduction (a `menu_option_items` fixture + one `option_item_prices` row + the same tenant-isolation role-switch pattern as §3.1, with `option_item_prices` now included in §3.0's grant) before this table's RLS is considered confirmed, not merely inferred from `menu_prices`'s test.

**(Stage 6 검증에서 실제로 재현 완료, Cursor)**: Cursor가 이번 Critical tier 검증에서 `menu_option_items` fixture(임의의 옵션 아이템 1개)와 `option_item_prices` 행 1건을 만들어 §3.1과 동일한 role-switch 패턴으로 독립 재현했다 — 다른 테넌트는 0건, 본인 테넌트는 자신의 행만 정확히 노출되는 것을 확인했다. 이 결과는 위 "구조적 유추만으로는 불충분하다"는 요구가 실제로 충족됐다는 참고 근거이지만, **Stage 8(실제 구현) 이후에는 그 라이브 상태에 대해 다시 한번 독립 재현이 필요하다** — Cursor의 이번 재현은 Stage 5 설계(트랜잭션 내 임시 GRANT 포함)를 대상으로 한 것이지, Stage 8이 실제로 적용한 마이그레이션을 대상으로 한 것이 아니다.

## §4 `resolve_menu_price()` — all 6 tiers

**Note**: all 6 tier scenarios below, plus the tie-breaker (§5) and `valid_from`/`valid_to` boundary (§6) tests, were already live-reproduced once during this document's own drafting (Stage 5, `pg_temp`-free `begin;...rollback;` against the local Supabase instance) to confirm the `601132_Logic.md` §2 SQL is correct before writing these as TestPlan assertions. Stage 8/9 must reproduce them independently with their own fresh fixtures, not merely re-trust this note.

### §4.1 Tier 6 (`MENU_BASE`) — no price list at all, falls back to `menus.price`

**(Stage 6 검증에서 지적된 트랜잭션 범위 정정)** §4 전체(§4.1-§4.5)는 **하나의 연속된 `begin;...rollback;` 블록**이다 — §4.1이 자체적으로 `rollback;`하지 않고, §4가 필요로 하는 모든 fixture(아래 "다른 매장" 포함)를 §4 자신의 범위 안에서 새로 만든다. 이전 판본은 §4.1이 조기에 `rollback;`한 뒤 §4.2가 §3.1(별도의, 이미 롤백된 트랜잭션)의 `<test_other_store_id>`를 참조하는 트랜잭션 경계 버그가 있었다 — 이번 정정으로 해소.

**전제조건**: 이 섹션(§4, 그리고 이어지는 §5-§6)을 재현하려면 먼저 §2의 DDL(4개 테이블 `CREATE TABLE` + `resolve_menu_price()` 함수 `CREATE FUNCTION`)이 **같은 트랜잭션 안에서** 선행 실행되어 있어야 한다 — 이 문서의 §2/§4 SQL 블록은 서로 별개 섹션으로 지면상 나뉘어 있을 뿐, 실제 재현 시에는 하나의 이어진 `begin;` 블록 안에서 §2 → §3(RLS/GRANT 포함) → §4 → §5 → §6 순서로 실행된다는 뜻이다. **Stage 8 이후에는 이 전제조건이 해당 없다** — 4개 테이블과 함수가 이미 라이브에 영구 적용되어 있으므로, Stage 9 이후의 재현은 이 섹션의 SQL만 독립적으로 실행해도 된다(단, 이 경우 §4.1의 `begin;`은 진짜 새 트랜잭션을 여는 것이지, §2/§3의 연장이 아니다).

```sql
begin;
select id as menu_id, price as base_price from catchmenu_pos.menus
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid and is_active = true
limit 1 \gset

-- §4.2의 "다른 매장" 테스트를 위한 fixture — §3.1의 (이미 롤백된) other-tenant/other-store를
-- 재참조하지 않고, §4 자신의 트랜잭션 안에서 같은 테넌트 소속의 새 매장을 직접 생성한다.
insert into catchmenu_hq.stores (id, tenant_id, store_code, store_name)
values ('<test_wrong_store_id>'::uuid, '<test_tenant_id>'::uuid, 'WRONG-STORE', 'Wrong Store Fixture (§4.2 전용)');

select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid) as result;
```

Expected: `resolved_tier = 'MENU_BASE'`, `amount = <base_price>`, `price_list_id = null`.

### §4.2 Tier 6 `NOT_FOUND` — nonexistent menu, and wrong-store menu

```sql
select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, gen_random_uuid()) as result_nonexistent;
select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_wrong_store_id>'::uuid, :'menu_id'::uuid) as result_wrong_store;
```

Expected: both return `resolved_tier = 'NOT_FOUND'`, `amount = null` — confirms the Stage 4-added `store_id`/`is_active` filter and explicit `NOT FOUND` branch (`601132_Logic.md` §2, the "이전에는 조용히 null을 반환했다" correction) actually fires instead of silently returning a null amount for a `FOUND` tier.

### §4.3 Tier 5 (`BRAND_DEFAULT`) — `store_id is null`, `sales_channel is null`, `provider_id is null`

```sql
insert into catchmenu_pos.price_lists (id, tenant_id, name, status) values ('<pl5>'::uuid, '<test_tenant_id>'::uuid, 'Brand Default', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, sales_channel, provider_id, priority)
  values ('<pla5>'::uuid, '<test_tenant_id>'::uuid, '<pl5>'::uuid, null, null, null, 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount) values ('<test_tenant_id>'::uuid, '<pl5>'::uuid, :'menu_id'::uuid, 9999);

select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid) as result;
```

Expected: `resolved_tier = 'BRAND_DEFAULT'`, `amount = 9999`.

### §4.4 Tier 4 (`BRAND_CHANNEL`) + **the critical `provider_id is null` leak-prevention case**

```sql
insert into catchmenu_pos.price_lists (id, tenant_id, name, status) values ('<pl4>'::uuid, '<test_tenant_id>'::uuid, 'Brand Delivery', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, sales_channel, provider_id, priority)
  values ('<pla4>'::uuid, '<test_tenant_id>'::uuid, '<pl4>'::uuid, null, 'DELIVERY', null, 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount) values ('<test_tenant_id>'::uuid, '<pl4>'::uuid, :'menu_id'::uuid, 8888);

select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid, 'DELIVERY') as result_before_leak_row;

-- Now add a brand+DELIVERY+specific-provider row (a plausible future-expansion assignment) and
-- confirm it does NOT get picked up by Tier 4 (which requires provider_id IS NULL) —
-- this is the exact defect the Stage 4 Architecture Verification (Cursor+Codex+안티) found and fixed.
insert into catchmenu_pos.price_lists (id, tenant_id, name, status) values ('<pl4b>'::uuid, '<test_tenant_id>'::uuid, 'Brand Delivery Baemin-specific', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, sales_channel, provider_id, priority)
  values ('<pla4b>'::uuid, '<test_tenant_id>'::uuid, '<pl4b>'::uuid, null, 'DELIVERY', 'DELIVERY_BAEMIN', 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount) values ('<test_tenant_id>'::uuid, '<pl4b>'::uuid, :'menu_id'::uuid, 7777);

select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid, 'DELIVERY') as result_after_leak_row_still_8888;
```

Expected: both calls return `resolved_tier = 'BRAND_CHANNEL'`, `amount = 8888` — the brand+DELIVERY+`DELIVERY_BAEMIN`-specific row (`amount=7777`) must **not** leak into this result even though it also matches `sales_channel='DELIVERY'` — this is the exact scenario the `pla.provider_id is null` filter (`601132_Logic.md` §2 Tier 4 comment) exists to prevent, live-verified at Stage 5.

### §4.5 Tier 3/2/1 (`STORE_DEFAULT`/`STORE_CHANNEL`/`STORE_PROVIDER`) — increasing specificity, no leak between tiers

```sql
insert into catchmenu_pos.price_lists (id, tenant_id, name, status) values ('<pl3>'::uuid, '<test_tenant_id>'::uuid, 'Store Default', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, sales_channel, provider_id, priority)
  values ('<pla3>'::uuid, '<test_tenant_id>'::uuid, '<pl3>'::uuid, '<test_store_id>'::uuid, null, null, 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount) values ('<test_tenant_id>'::uuid, '<pl3>'::uuid, :'menu_id'::uuid, 6666);
select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid) as tier3_result;

insert into catchmenu_pos.price_lists (id, tenant_id, name, status) values ('<pl2>'::uuid, '<test_tenant_id>'::uuid, 'Store Delivery', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, sales_channel, provider_id, priority)
  values ('<pla2>'::uuid, '<test_tenant_id>'::uuid, '<pl2>'::uuid, '<test_store_id>'::uuid, 'DELIVERY', null, 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount) values ('<test_tenant_id>'::uuid, '<pl2>'::uuid, :'menu_id'::uuid, 5555);
select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid, 'DELIVERY') as tier2_result;

insert into catchmenu_pos.price_lists (id, tenant_id, name, status) values ('<pl1>'::uuid, '<test_tenant_id>'::uuid, 'Store Delivery Baemin', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, sales_channel, provider_id, priority)
  values ('<pla1>'::uuid, '<test_tenant_id>'::uuid, '<pl1>'::uuid, '<test_store_id>'::uuid, 'DELIVERY', 'DELIVERY_BAEMIN', 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount) values ('<test_tenant_id>'::uuid, '<pl1>'::uuid, :'menu_id'::uuid, 4444);
select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid, 'DELIVERY', 'DELIVERY_BAEMIN') as tier1_result;
-- re-query without provider_id to confirm tier1's row didn't leak into tier2's result
select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid, 'DELIVERY') as tier2_still_5555;
```

Expected: `tier3_result` → `STORE_DEFAULT`/`6666`; `tier2_result` → `STORE_CHANNEL`/`5555`; `tier1_result` → `STORE_PROVIDER`/`4444`; `tier2_still_5555` → still `STORE_CHANNEL`/`5555` (the more specific Tier 1 row must not leak backward into a less-specific query).

## §5 Tie-breaker — same `priority`, different `menu_prices.effective_from`

```sql
-- two STORE_DEFAULT price_list_assignments rows, both priority=0, targeting the same menu:
-- one with amount=6666 (menu_prices.effective_from = now(), i.e. the §4.5 tier3 fixture),
-- one with amount=3333 (menu_prices.effective_from = now() - interval '1 minute', older).
insert into catchmenu_pos.price_lists (id, tenant_id, name, status) values ('<pl_tb>'::uuid, '<test_tenant_id>'::uuid, 'Store Default Older', 'ACTIVE');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, priority)
  values ('<pla_tb>'::uuid, '<test_tenant_id>'::uuid, '<pl_tb>'::uuid, '<test_store_id>'::uuid, 0);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount, effective_from)
  values ('<test_tenant_id>'::uuid, '<pl_tb>'::uuid, :'menu_id'::uuid, 3333, now() - interval '1 minute');

select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid) as result;
```

Expected: `amount = 6666` (the more-recently-`effective_from` row wins the `priority` tie via the `mp.effective_from desc` tie-breaker) — live-verified at Stage 5 with this exact fixture shape.

## §6 `valid_from`/`valid_to` boundary — expired price list excluded despite highest `priority`

```sql
insert into catchmenu_pos.price_lists (id, tenant_id, name, status, valid_from, valid_to)
  values ('<pl_exp>'::uuid, '<test_tenant_id>'::uuid, 'Expired Promo', 'ACTIVE', now() - interval '10 days', now() - interval '1 day');
insert into catchmenu_pos.price_list_assignments (id, tenant_id, price_list_id, store_id, priority)
  values ('<pla_exp>'::uuid, '<test_tenant_id>'::uuid, '<pl_exp>'::uuid, '<test_store_id>'::uuid, 99);
insert into catchmenu_pos.menu_prices (tenant_id, price_list_id, menu_id, amount) values ('<test_tenant_id>'::uuid, '<pl_exp>'::uuid, :'menu_id'::uuid, 1111);

select catchmenu_pos.resolve_menu_price('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'menu_id'::uuid) as result;

rollback;
```

Expected: `amount = 6666` (still the §4.5/§5 `STORE_DEFAULT` result), **not** `1111` — `priority=99` is the highest of any `STORE_DEFAULT`-tier row inserted in this transaction, but `pl.valid_to` has already passed, so the `(pl.valid_to is null or pl.valid_to > p_at)` condition excludes it entirely regardless of priority. This is the direct test of `601132_Logic.md` §1.1's decision to make `valid_from`/`valid_to` load-bearing rather than dead columns.

## §7 Boundary — 0 diff, `menus.price` not deleted

**(Stage 6 검증에서 확장)** 아래 11개 파일은 `601134_ChangeContract.md` §4(Forbidden Operations)가 명시적으로 금지하는 파일 전체다 — 기존 6개(이 워크패킷과 직접 인접한 신규/최근 마이그레이션)뿐 아니라, `601131_Overview.md` §2가 확인한 9개 `menus.price` 소비 지점 중 실제 소스 파일이 특정된 5개 소비자 마이그레이션(`0026`/`0057`/`0086`/`0102`/`0104`)까지 전부 포함한다 — 이 워크패킷은 Phase 0(스키마+RLS+리졸버만)이라 이 소비자들을 전혀 건드리지 않지만, "건드리지 않았다"는 주장 자체를 boundary 확인 대상에서 빠뜨리면 안 된다.

```bash
git status --short sql/migrations/0044_create_menu_management_rpc.sql
git status --short sql/migrations/0141_hyper_personalization_menu_customization.sql
git status --short sql/migrations/0110_create_store_admin_rpc.sql
git status --short sql/migrations/0162_create_dining_table_admin_rpc.sql
git status --short sql/migrations/0163_seat_waiting_customer_facade_correction.sql
git status --short sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql
git status --short sql/migrations/0026_create_order_rpc.sql
git status --short sql/migrations/0057_create_delivery_platform_rpc.sql
git status --short sql/migrations/0086_create_hq_menu_distribution_rpc.sql
git status --short sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql
git status --short sql/migrations/0104_create_toss_pos_pipeline_rpc.sql
```

```sql
select column_name from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'menus' and column_name = 'price';
```

Expected: all 11 `git status` calls empty (none of the 9 confirmed `menus.price` consumers' source files are touched, nor any of the other 6 no-regression files this workpacket sits adjacent to — this workpacket creates pure new infrastructure); `menus.price` column still exists (confirms the "no deletion, permanent fallback tier" decision, `601132_Logic.md` §1, was actually honored in the implementation). Filenames for `0102`/`0104` confirmed live at this correction's drafting time (`0102_create_okpos_integration_pipeline_rpc.sql`/`0104_create_toss_pos_pipeline_rpc.sql`) — note `0102`'s OKPOS sync function *name inside the file* is still unconfirmed (`601134_ChangeContract.md` §8 (j)), only the filename itself was verified here.

## §8 Acceptance criteria

PASS only if all are true:

1. All 4 tables created with the exact columns/constraints/FKs specified in `601132_Logic.md` §1, no name collisions (§1.1, §2).
2. RLS cross-tenant isolation confirmed for `price_lists`/`price_list_assignments`/`menu_prices` via live role-switch reproduction (not just policy-definition inspection); `option_item_prices` reproduced independently by Stage 8/9, not assumed by structural analogy alone (§3).
3. All 6 resolver tiers return the correct `resolved_tier`/`amount`, with no leakage between adjacent tiers — especially Tier 4's `provider_id is null` filter (§4).
4. Tie-breaker resolves a `priority` tie via `effective_from desc` correctly (§5).
5. `valid_from`/`valid_to` correctly excludes an expired price list even at the highest `priority` (§6).
6. All 11 no-regression files (`0044`/`0141`/`0110`/`0162`/`0163`/`0164`/`0026`/`0057`/`0086`/`0102`/`0104`) show zero diff; `menus.price` column still exists (§7).
7. No `GRANT` to `authenticated` exists on any of the 4 new tables or on `resolve_menu_price()` in the actual (non-test) migration — matches the `menus` zero-grant precedent (§0).
