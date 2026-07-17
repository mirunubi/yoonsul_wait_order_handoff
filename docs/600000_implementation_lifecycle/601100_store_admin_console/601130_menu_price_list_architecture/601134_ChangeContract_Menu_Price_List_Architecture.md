# 601134_ChangeContract_Menu_Price_List_Architecture.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`menu_price_list_architecture`

## §0 Contract summary

This ChangeContract authorizes only the Stage 8 implementation described in `601132_Logic_Menu_Price_List_Architecture.md` §1-§2 — **Phase 0 only** (`601132_Logic.md` §3's 5-phase migration path): creating 4 new tables (`catchmenu_pos.price_lists`/`price_list_assignments`/`menu_prices`/`option_item_prices`), enabling+forcing RLS with one policy each, and creating the canonical resolver `catchmenu_pos.resolve_menu_price()`, in a new migration file (tentatively `sql/migrations/0165_menu_price_list_architecture_phase0.sql`). Like `600654`/`600664`, this is a pure-addition workpacket at the file level — no existing migration file is edited. Unlike every prior workpacket in this session, **nothing calls the new objects yet** — Phase 0 is infrastructure with zero live consumers, by design (`601131_Overview.md` §0, §5).

The goal: replace the "one menu = one price" model (`menus.price` single column, silently identical across every sales channel — `601131_Overview.md` §2's 9-consumer audit found no channel/provider branching anywhere, including `create_order()`, the actual billing path) with a price-list-based model supporting store/channel/provider-specific pricing, while making **zero** behavioral change to any live system — `menus.price` is not deleted, is not modified, and every one of the 9 confirmed consumers keeps reading it exactly as before. This workpacket is infrastructure-only; wiring any consumer to `resolve_menu_price()` is Phase 3, a future, separate workpacket.

## §1 Allowed files and objects

### §1.1 Allowed SQL source file

- `sql/migrations/0165_menu_price_list_architecture_phase0.sql` (tentative number — `601132_Logic.md` §3 does not fix a number; Stage 8 must re-run `select max(...)`-equivalent directory listing against `sql/migrations/` immediately before creating the file and use the actual next-available number if `0165` has been claimed by another workpacket in the interim, same discipline as `0163`/`0164`)

No existing migration file may be modified by this contract.

### §1.2 Allowed objects

**New tables:**

- `catchmenu_pos.price_lists` (§2.1)
- `catchmenu_pos.price_list_assignments` (§2.1)
- `catchmenu_pos.menu_prices` (§2.1)
- `catchmenu_pos.option_item_prices` (§2.1)

**New function:**

- `catchmenu_pos.resolve_menu_price(p_tenant_id uuid, p_store_id uuid, p_menu_id uuid, p_sales_channel text default null, p_provider_id text default null, p_at timestamptz default now())` (§2.2)

**New RLS policies** (one per new table, §2.3): `price_lists_tenant_isolation`, `price_list_assignments_store_isolation`, `menu_prices_store_isolation`, `option_item_prices_store_isolation`.

**No-regression preservation only — modification NOT authorized:**

- `catchmenu_pos.menus` (`0044` and successors) — schema **read-only** dependency (FK target for `menu_prices.menu_id`, and Tier 6's `menus.price`/`is_active` read). The `price` column's *meaning* is reinterpreted in documentation only (`601132_Logic.md` §1: "브랜드 기준가") — no `ALTER TABLE`, no data change, no `DROP COLUMN`.
- `catchmenu_pos.menu_option_items` — schema read-only dependency (FK target for `option_item_prices.option_item_id`).
- All 9 confirmed `menus.price` consumers (`601131_Overview.md` §2): `get_menu_catalog()` (`0044`), `get_menu_customization_options()`/`calculate_customization_price()` (`0141`), `create_order()` (`0026`), OKPOS sync (`0102`), Toss POS sync (`0104`), `sync_delivery_menu()` (`0057`), HQ menu distribution (`0086`), `upsert_menu()`/`upsert_menu_core()` (`0110`, `601112_Logic.md` §2) — none read `resolve_menu_price()`, none are touched.
- `catchmenu_hq.tenants`, `catchmenu_hq.stores` — schema, FK targets only.

All of the above are diff-zero verification targets (`601133_TestPlan.md` §7) — Stage 8 must not edit any of their bodies or schemas.

## §2 Required implementation contract

### §2.1 4 tables — full DDL per `601132_Logic.md` §1

Exactly as specified: `price_lists` (`tenant_id`/`name`/`currency` default `'KRW'`/`valid_from`/`valid_to`/`status` default `'ACTIVE'` with `chk_price_list_status` in `('ACTIVE','DRAFT','ARCHIVED')` and `chk_price_list_valid_range`); `price_list_assignments` (`tenant_id`/`price_list_id`/`store_id` nullable — null means brand-wide/all-stores/`sales_channel` nullable — null means channel-agnostic/`provider_id` nullable — null means provider-agnostic-within-channel/`priority` int default `0`, no `created_at` default omission); `menu_prices` (`tenant_id`/`price_list_id`/`menu_id`/`amount` with `chk_menu_price_amount` (`>= 0`)/`effective_from` default `now()`/`effective_to`/`chk_menu_price_range`); `option_item_prices` (`tenant_id`/`price_list_id`/`option_item_id`/`price_delta`, no amount-sign constraint — unlike `menu_prices.amount`, a delta may legitimately be negative). **The `price_list_assignments` nullable-column UNIQUE-constraint gap is a known, explicitly unresolved design problem** (`601132_Logic.md` §1's "미해결 설계 문제" — Postgres standard UNIQUE treats NULL as distinct from NULL, so a duplicate "store A's default assignment" could be created twice with no constraint violation) — **this contract does not authorize a fix for it**; it is carried forward as Open Item (b).

### §2.2 `resolve_menu_price()` — full function per `601132_Logic.md` §2, live-verified at Stage 5

6-tier priority chain in strict order (`STORE_PROVIDER` → `STORE_CHANNEL` → `STORE_DEFAULT` → `BRAND_CHANNEL` → `BRAND_DEFAULT` → `MENU_BASE`/`NOT_FOUND`), each of Tier 1-5 sharing: `pl.status = 'ACTIVE'`, `(pl.valid_from is null or pl.valid_from <= p_at) and (pl.valid_to is null or pl.valid_to > p_at)`, `mp.effective_from <= p_at and (mp.effective_to is null or mp.effective_to > p_at)`, and the tie-breaker `order by pla.priority desc, mp.effective_from desc, pla.created_at desc, pla.id desc limit 1`. **Tier 4 (`BRAND_CHANNEL`) must include `pla.provider_id is null`** — its absence was the exact defect the Stage 4 Architecture Verification (Cursor+Codex+안티) found and `601133_TestPlan.md` §4.4 now live-reproduces as a leak-prevention test. **Tier 6 (`MENU_BASE`) is a separate `menus` query, not part of the Tier 1-5 shared-condition block** — it does not use `price_lists`/tie-breaker/`valid_from`/`valid_to` at all (per `601132_Logic.md`'s 2026-07-16 second-pass correction), and must filter by `store_id = p_store_id and is_active = true`, returning `resolved_tier: 'NOT_FOUND'` (not a silently-null `amount` under a `FOUND` tier) when no matching row exists. `language plpgsql stable security definer set search_path = catchmenu_pos`.

### §2.3 RLS — full policies per `601132_Logic.md` §1.2, live-verified at Stage 5

`price_lists`: `enable`+`force` RLS, single policy checking `tenant_id = catchmenu_common.current_tenant_id()` only (no `store_id` — brand-level concept, no such column). `price_list_assignments`: `enable`+`force`, policy checking `tenant_id = current_tenant_id() and (store_id = current_store_id() or store_id is null)`. `menu_prices`/`option_item_prices`: `enable`+`force`, policy checking `tenant_id = current_tenant_id() and exists (select 1 from price_list_assignments pla where pla.price_list_id = <table>.price_list_id and pla.tenant_id = current_tenant_id() and (pla.store_id = current_store_id() or pla.store_id is null))` — the `EXISTS`-subquery pattern, a deliberate deviation from the codebase's usual denormalized-`store_id` RLS convention (`0022_create_rls_policies.sql:305-337`) because neither table has a `store_id` column of its own. **The performance tradeoff of this `EXISTS` pattern vs. denormalizing `store_id` onto both tables is an explicitly unresolved design question** (`601132_Logic.md` §5 (h)) — **this contract does not authorize denormalization**; the `EXISTS`-based policies as designed are what Stage 8 implements.

### §2.4 No `GRANT` to `authenticated` on any of the 4 tables or on the resolver function

Live-confirmed at Stage 5 (`601133_TestPlan.md` §0): `catchmenu_pos.menus` itself has zero direct `GRANT`s to `authenticated` — this codebase's access-control model is exclusively "no direct table grants, all access through `SECURITY DEFINER` RPCs." The 4 new tables follow the identical pattern (no `GRANT` statement of any kind in the migration). `resolve_menu_price()` itself gets `revoke all on function ... from public;` and **no** `grant execute ... to authenticated` — it is internal-only, callable only by other `SECURITY DEFINER` functions (the future Phase 3 consumer RPCs), matching `0163`'s `_resolve_dining_table_by_number()` precedent exactly. Stage 8 must not add any `GRANT` beyond what §2.1-§2.3 specify (i.e., none at the table level, `REVOKE`-only at the function level).

### §2.5 Migration file header

Header identifying this file's purpose (Phase 0 only — schema+RLS+resolver, zero consumers wired) distinct from Phase 1-4's future scope; `Depends on: 0164_waiting_pipeline_sibling_functions_correction.sql` (the most recent prior migration, no functional dependency — purely the sequential-numbering convention).

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule, matching `600654_ChangeContract.md` §3 / `600664_ChangeContract.md` §3's format:

**New file `sql/migrations/0165_menu_price_list_architecture_phase0.sql`** (number to be reconfirmed, §1.1):

1. Create the file with the header described in §2.5.
2. `CREATE TABLE catchmenu_pos.price_lists` exactly as specified in §2.1/`601132_Logic.md` §1.
3. `CREATE TABLE catchmenu_pos.price_list_assignments` exactly as specified in §2.1/`601132_Logic.md` §1.
4. `CREATE TABLE catchmenu_pos.menu_prices` exactly as specified in §2.1/`601132_Logic.md` §1.
5. `CREATE TABLE catchmenu_pos.option_item_prices` exactly as specified in §2.1/`601132_Logic.md` §1.
6. `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` + `ALTER TABLE ... FORCE ROW LEVEL SECURITY` + `CREATE POLICY` for all 4 tables, exactly as specified in §2.3/`601132_Logic.md` §1.2.
7. `CREATE FUNCTION catchmenu_pos.resolve_menu_price(...)` exactly as specified in §2.2/`601132_Logic.md` §2.
8. `REVOKE ALL ON FUNCTION catchmenu_pos.resolve_menu_price(...) FROM PUBLIC` — per §2.4. **No `GRANT` statement of any kind is part of this step or any other step** (§2.4).

No operation is authorized on any other file. No CRUD RPC for managing price lists (`set_menu_price_list_entry()` or similar, `601132_Logic.md` §5 (d)) is authorized — schema and resolver only.

## §4 Forbidden Operations

- Any change to `sql/migrations/0044_create_menu_management_rpc.sql`, `0141_hyper_personalization_menu_customization.sql`, `0110_create_store_admin_rpc.sql`, `0162_create_dining_table_admin_rpc.sql`, `0163_seat_waiting_customer_facade_correction.sql`, `0164_waiting_pipeline_sibling_functions_correction.sql`, or `0026_create_order_rpc.sql`/`0057_create_delivery_platform_rpc.sql`/`0086_create_hq_menu_distribution_rpc.sql`/`0102_*.sql`/`0104_*.sql` (the remaining confirmed `menus.price` consumers not already listed).
- Modifying any of the 9 confirmed `menus.price` consumer functions to call `resolve_menu_price()` — that is Phase 3, explicitly out of scope (`601132_Logic.md` §3, item 4).
- Any Phase 1 backfill INSERT into `price_lists`/`price_list_assignments`/`menu_prices` seeding "brand standard 홀/포장" price lists from existing `menus.price` data — Phase 1 is a separate future workpacket.
- `DROP COLUMN`, rename, or any schema change to `catchmenu_pos.menus.price` — it remains exactly as-is, permanently the Tier 6 fallback (§2.1's dependency note, `601132_Logic.md` §1).
- Adding a `GRANT` (table-level or function-level, to any role) beyond §2.4's explicit `REVOKE`-only scope.
- Adding a UNIQUE constraint or validation trigger to solve `price_list_assignments`'s nullable-column duplicate-assignment gap (§2.1) — an explicitly unresolved design problem, not authorized for a fix under this contract (Open Item (b)).
- Denormalizing a `store_id` column onto `menu_prices`/`option_item_prices` to simplify their RLS policies (§2.3) — an explicitly unresolved design tradeoff, not authorized under this contract (Open Item (h)).
- Creating any migration file other than the one named in §1.1.
- Any Flutter/client code change.

## §5 Forbidden scope

- Phase 1 (backfill), Phase 2 (parallel operation / `upsert_menu()` price-sync-on-write decision, `601132_Logic.md` §4's Option A/B), Phase 3 (9-consumer cutover), Phase 4 (n/a — no cleanup phase exists, `menus.price` is permanent) — all cross-referenced only, none created or authorized here.
- `set_menu_price_list_entry()`-style CRUD RPC for managing price lists — `601132_Logic.md` §5 (d), out of scope.
- `order_items`'s 2nd-generation unused price-snapshot columns (`601131_Overview.md` §3) — a related but separate phantom-column-class finding, not this contract's concern.
- The remaining 23 of 32 `menus`-referencing files not yet audited for price reads (`601131_Overview.md` §6 (a)) — out of scope, flagged for a future re-audit.
- `601110`/`601140` (menu RPC phantom-column repair, sibling-overwrite correction) — different workpackets, already complete, not touched.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. Any of the 4 table names (`price_lists`/`price_list_assignments`/`menu_prices`/`option_item_prices`) or the function name `resolve_menu_price` already exists anywhere in the live schema immediately before Stage 8 runs (`601133_TestPlan.md` §1.1).
2. `catchmenu_common.current_tenant_id()`/`current_store_id()` do not exist, or their live behavior (reading `request.jwt.claims -> 'app_metadata' -> 'tenant_id'/'store_id'`) differs from what §2.3 assumes (`601133_TestPlan.md` §1.2).
3. Any of the 4 FK target tables (`catchmenu_hq.tenants`, `catchmenu_hq.stores`, `catchmenu_pos.menus`, `catchmenu_pos.menu_option_items`) no longer exist or their `id` column type is not `uuid`.
4. `catchmenu_pos.menus` no longer has a `price`/`is_active`/`store_id` column as Tier 6 assumes (`601133_TestPlan.md` §1.3/§7).
5. `catchmenu_pos.menus` is found to have a non-empty `GRANT` to `authenticated` at Stage 8 time (i.e., §2.4's "zero-grant precedent" baseline has changed since this contract was drafted) — would mean the "no GRANT" design decision needs re-examination before proceeding.
6. Completing this implementation would require modifying any file or function named in §1.2's no-regression list.
7. `601133_TestPlan.md` §4's 6-tier resolver reproduction, §5's tie-breaker, or §6's `valid_from`/`valid_to` boundary test produces a different result than this document's Stage-5 live-verified expectations — would indicate a live-environment discrepancy (e.g., a schema drift on `menus`) requiring a return to Stage 5, not a silent Stage 8 adjustment.
8. `sql/migrations/0165_...` (or whatever number is actually used, §1.1) is found to already exist with different content when Stage 8 begins.

## §7 Required verification

Stage 8 must run `601133_TestPlan_Menu_Price_List_Architecture.md` completely.

Required evidence:

1. Pre-flight collision/dependency/GRANT-precedent checks (§1).
2. All 4 tables created with exact schema/constraints/FKs (§2).
3. RLS cross-tenant isolation for `price_lists`/`price_list_assignments`/`menu_prices` reproduced live via role-switch (not policy-definition inspection alone); `option_item_prices` reproduced independently, not assumed by analogy (§3).
4. All 6 resolver tiers correct, including the Tier 4 `provider_id is null` leak-prevention case as its own explicit test (§4).
5. Tie-breaker and `valid_from`/`valid_to` boundary both reproduced (§5, §6).
6. Zero diff on all 11 no-regression files named in §4/`601133_TestPlan.md` §7 (the 6 adjacent-workpacket files plus all 5 confirmed `menus.price` consumer migrations); `menus.price` column confirmed still present (§7).
7. No `GRANT` present on any of the 4 tables or the resolver function in the final implementation (§2.4).

## §8 Open Items (carried from `601131_Overview.md` §6 and `601132_Logic.md` §5, in full)

(a) The remaining 23 of 32 `menus`-referencing files not yet confirmed to read/not-read price (`601131_Overview.md` §6 (a)/`601132_Logic.md` §5 (a)) — recommend a full re-audit before Phase 3 begins, not required for this Phase-0-only contract.

(b) `price_list_assignments`'s nullable-column UNIQUE-constraint gap (§2.1, `601132_Logic.md` §1/§5 (b)) — a duplicate "store A default assignment" can currently be created twice with no DB-level error. Needs a partial UNIQUE index (`coalesce(store_id, '<sentinel>')`-style) or a validation trigger — not designed or authorized by this contract.

(c) How many workpackets Phase 3's 9-consumer cutover should be split into (`601132_Logic.md` §5 (c)) — `create_order()` (actual billing) vs. the remaining 8 (read/sync-oriented) may warrant separate risk tiers. Human decision needed before Phase 3 planning begins.

(d) `set_menu_price_list_entry()`-style CRUD RPC design (`601132_Logic.md` §5 (d)) — entirely undesigned, needed before any human/admin can actually populate these tables through the application layer (Phase 0 only creates the schema; Stage 8's own TestPlan reproduction inserts rows directly as `postgres`, not through any RPC).

(e) `601132_Logic.md` §4's Option A/B — whether `upsert_menu_core()` should auto-sync the store's default `menu_prices` row when `menus.price` changes (Option A) or require a fully separate explicit RPC call (Option B) — a Phase 2 design question, Human decision needed, not resolved by this Phase-0 contract.

(f) `order_items`'s 2nd-generation unused price-snapshot columns — whether to wire them up as part of this redesign or add new ChatGPT-proposed columns (`price_list_id`/`price_resolved_at`/`discount_amount`) instead, or a mix (`601131_Overview.md` §3, `601132_Logic.md` §5 (f)) — undecided, relevant to Phase 3/`order_items` schema work, not this contract.

(g) **[Resolved, 2026-07-16 Human decision]** Whether to keep this expansion inside `601110`/`601112` or split it into its own workpacket — split, confirmed, resulted in this `601130` workpacket. No longer open.

(h) `menu_prices`/`option_item_prices`'s `EXISTS`-subquery RLS policy performance tradeoff vs. denormalizing `store_id` (§2.3, `601132_Logic.md` §1.2/§5 (h)) — recommended-but-not-mandated to keep the normalized/`EXISTS` design given current data scale (1 store); Human may override before Stage 8.

(i) **[Resolved, Stage 6 재검증(Cursor)]** `option_item_prices`'s RLS isolation — Stage 5 초안 시점에는 구조적 유추로만 남겼으나(§4의 정정 참고), Stage 6 Critical tier 검증에서 Cursor가 `menu_option_items` fixture + `option_item_prices` 행을 만들어 §3.1과 동일한 role-switch 패턴으로 독립 재현에 실제로 성공했다(다른 tenant는 0건, 자기 tenant는 자기 행만 노출) — 더 이상 미해소 Open Item이 아니다. `601133_TestPlan.md` §3.0/§3.3이 이 재현 결과를 참고 근거로 갱신됐다.

(j) **[신규, `601131_Overview.md` §6 (b) 이월]** `0102`의 OKPOS 동기화 함수 정확한 이름이 미확정이다(`sync_okpos_menu()` 추정, 라이브 재확인 필요) — `601131_Overview.md` §2의 9개 `menus.price` 소비 지점 표에 이 함수가 포함되어 있으나 정확한 함수명은 아직 확인되지 않았다. 이번 Phase 0 계약(스키마+RLS+리졸버만, 소비자 전환 없음)에는 영향이 없지만, Phase 3(소비자 전환) 착수 전에는 반드시 라이브로 정확한 함수명을 재확인해야 한다 — Stage 4 전 재확인 권고사항이었던 것을 여기 명시적으로 이월한다.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation:

☑ I approve creating the 4 new tables (`price_lists`/`price_list_assignments`/
  `menu_prices`/`option_item_prices`) exactly as specified in §2.1, including
  the known-unresolved nullable-column UNIQUE gap on `price_list_assignments`
  (Open Item (b)) being explicitly deferred, not fixed, in this contract.

☑ I approve the `resolve_menu_price()` 6-tier resolver exactly as specified
  in §2.2 — including the Tier 4 `provider_id is null` filter, the Tier 1-5
  tie-breaker, the `valid_from`/`valid_to` enforcement on Tier 1-5 only (not
  Tier 6), and Tier 6's `NOT_FOUND` contract change (any future Phase 3
  consumer must handle `resolved_tier = 'NOT_FOUND'` explicitly).

☑ I approve the RLS design in §2.3 as-is, including the `EXISTS`-subquery
  pattern for `menu_prices`/`option_item_prices` (a deliberate deviation from
  the codebase's usual denormalized-`store_id` convention) — with the
  performance-vs-normalization tradeoff (Open Item (h)) explicitly deferred,
  not resolved, in this contract.

☑ I approve that neither the 4 tables nor `resolve_menu_price()` receive any
  `GRANT` to `authenticated` under this contract (§2.4) — matching the
  `catchmenu_pos.menus` zero-grant precedent; the resolver becomes callable
  only once a future Phase 3 consumer RPC (itself `SECURITY DEFINER`) calls
  it internally.

☑ I approve that this contract makes **zero** behavioral change to any live
  system — `menus.price` is not deleted or modified, all 9 confirmed
  consumers keep reading it unchanged, and Phase 1-4 (backfill, parallel
  operation, consumer cutover, and the CRUD RPC needed to actually populate
  these tables in production) are entirely out of scope (§4/§5/§8). (2026-07-18)

## §10 Approval state

APPROVED (2026-07-18) — Human Approval §9 all 5 items checked.

## §11 Final Audit (Stage 11, Claude)

**Verdict: ACCEPT (2026-07-18)**

핵심 주장 재도출 확인 (Stage 9 산출물을 액면 그대로 신뢰하지 않고 직접 재검토):

- 4개 신규 테이블(price_lists/price_list_assignments/menu_prices/option_item_prices) + RLS(enable+force+정책) - Cursor+Claude Code+안티 3자 독립 재현 완전 일치, qual 표현식까지 라이브 대조 확인.
- resolve_menu_price() 6단계 우선순위 리졸버 - 오늘 하루 여러 Stage 4 라운드(Tier 4 provider_id 필터 누수 발견 및 수정, tie-breaker 추가, valid_from/valid_to 반영, Tier 6 store_id/is_active 필터+NOT_FOUND 처리)를 거쳐 확정된 설계가 최종 구현에서도 정확히 작동함을 3자 모두 실증.
- 크로스테넌트 RLS 격리 - 4개 테이블 전부 각자 독립 재현(다른 tenant 접근 시 0건), Claude Code는 추가로 브랜드 전체배정(store_id is null) OR절까지 검증.
- GRANT 부재 설계 - menus 테이블 자체가 authenticated에 직접 GRANT가 0건이라는 이 프로젝트의 기존 관례("직접 테이블 GRANT 없이 전부 SECURITY DEFINER RPC로만 접근")와 정확히 일치함을 Stage 5 작성 단계에서 처음 발견, Stage 9에서 3자 모두 재확인.
- Phase 0 범위 준수 - 11개 no-regression 파일 전부 0 diff, menus.price 무변경, 순수 신규 인프라만 생성되고 아직 아무것도 이를 사용하지 않는다는 설계 의도 그대로 구현됨.
- 검증 방법론(AGENTS.md §3.8): §10 APPROVED 확인 후 실제 라이브 함수 직접 호출(허용 범위) + 전 구간 begin/rollback, 트랜잭션 밖 영구 변경 없음 - 지난 라운드의 거버넌스 위반이 재발하지 않았음을 재확인.

**Open Items (다음 워크패킷 후보로 이월):**

1. price_list_assignments의 nullable 컬럼 UNIQUE 제약 미해결 갭 (Open Item b) - 여전히 미해결.
2. menu_prices/option_item_prices의 EXISTS 서브쿼리 방식 - 성능vs정규화 트레이드오프(Open Item h) 미해결.
3. Phase 1(백필)/Phase 2(병행운영)/Phase 3(9개 소비자 전환)/Phase 4(정리) - 전부 별도 후속 워크패킷 필요, 이번엔 순수 인프라만 생성.
4. 0102의 OKPOS 동기화 함수 정확한 이름 미확정(Open Item j) - Phase 3 착수 전 재확인 필요.
5. 가격표 CRUD RPC(관리자가 실제로 가격표를 만들고 배정하는 기능) - 아직 설계도 안 됨, resolve_menu_price()가 읽을 데이터를 넣을 방법이 없음.

## §12 Human Merge/Release

담당: Human (정영석님) — 승인 대기 중, Stage 8 착수 전 §9 전체 체크 필요.
