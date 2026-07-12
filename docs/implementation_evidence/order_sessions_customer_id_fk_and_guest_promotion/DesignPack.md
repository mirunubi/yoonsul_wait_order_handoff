# DesignPack — order_sessions.customer_id Forward Migration + Guest Promotion

CHANGE_ID: `order_sessions_customer_id_fk_and_guest_promotion` (newly assigned this turn — none was pre-assigned in the task)
Tier: Medium (§31) — new feature/schema addition, not itself payment/RLS/settlement/cross-tenant logic (the columns it touches are consumed by payment-adjacent code, but this change only adds an FK column + is_guest flag; it does not alter payment, RLS policy, or settlement logic)
Status: DRAFT — Stage 1.5, no Human approval yet, no migration file created
Author: Claude Code (Stage 1.5 role)
Date: 2026-07-11

Per §31, Medium tier consolidates ImpactScope + Overview + Logic into this one file. TestPlan + ChangeContract are in the companion `TestAndContract.md`.

---

## Part 1 — ImpactScope

### 1.1 Step 0 mandatory pre-check (executed, raw result below)

Command run (via Grep tool, equivalent to the specified `Select-String -Pattern "create table.*customers \(" -Context 0,40`):

```
sql\migrations\0058_create_membership_rpc.sql:21:create table if not exists catchmenu_store.customers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid,
  customer_code text not null,
  display_name text,
  phone_masked text,
  phone_hash text,
  email_masked text,
  email_hash text,
  preferred_locale text not null default 'ko',
  membership_tier text not null default 'STANDARD',
  membership_status text not null default 'ACTIVE',
  point_balance int not null default 0,
  lifetime_spend int not null default 0,
  visit_count int not null default 0,
  last_visit_at timestamptz,
  first_visit_at timestamptz,
  allergen_profile jsonb default '{}'::jsonb,
  preferred_options jsonb default '{}'::jsonb,
  acquisition_channel text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uq_customer_code unique (tenant_id, customer_code),
  constraint uq_customer_phone unique (tenant_id, phone_hash),
  constraint chk_membership_tier check (membership_tier in ('STANDARD','SILVER','GOLD','VIP','BLACKLIST')),
  constraint chk_membership_status check (membership_status in ('ACTIVE','SUSPENDED','WITHDRAWN')),
  constraint chk_point_balance check (point_balance >= 0)
);
```

**No `is_guest` column on `catchmenu_store.customers`.** Confirmed also via a full-repo grep of `is_guest` across `sql/migrations/*.sql`: the only existing `is_guest` is on `catchmenu_store.customer_app_sessions` (0081, a different table), not on `customers`. Task's premise confirmed correct — the migration must add `is_guest` to `customers`.

Additional check: `uq_customer_phone unique (tenant_id, phone_hash)` — note for Logic §2.3 below, this constraint already exists and is directly relevant to the guest-promotion upsert logic.

### 1.2 Affected files (line numbers independently re-verified this turn, not trusted from prior chat citations)

| File | Role | Exact lines touching the gap |
|---|---|---|
| `sql/migrations/0012_create_pos_order_sessions.sql` | Original `order_sessions` table — confirmed no `customer_id`, only `customer_token text` (line 32) | — |
| `sql/migrations/0021_enable_rls.sql` | Only RLS enable/force statements on `order_sessions`, confirmed no column added (lines 100-102) | — |
| `sql/migrations/0058_create_membership_rpc.sql` | Original `customers` table — no `is_guest` (see 1.1) | line 21-74 |
| `sql/migrations/0081_create_customer_app_rpc.sql` | Correctly DEFERRED the `order_sessions.customer_id` dependency; own `customer_app_sessions.customer_id` FK is valid and unaffected | header + lines 138-201, 311-335, 763-790, 1233-1298 |
| `sql/migrations/0097_create_auth_login_pipeline_rpc.sql` | Phone+OTP login, creates/finds `customers` row, `auth_sessions` — unaffected by this change, remains canonical auth mechanism | not modified by this change |
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | `register_waiting()` INSERTs `customer_id` into `order_sessions` — column doesn't exist, would fail live | lines 289-309 (INSERT), also 195, 342, 452, 547, 1019 |
| `sql/migrations/0116_create_customer_app_bootstrap_rpc.sql` | 5 functions read `order_sessions.customer_id` / `p_customer_id` | lines 102, 185, 191, 201, 231, 271, 282, 416, 444, 665, 692, 735, 752, 772, 793, 805, 833, 860, 879, 900, 923 |
| `docs/.../005015_Policy_Customer_Account_Guest_Merge...md` | Guest→account merge policy — see Logic §3 for conflict analysis | §5, §7, §8, §10 |
| `sql/migrations/CHANGELOG.md` | 2026-07-11 entry already documents the root-cause investigation this DesignPack builds on | lines 56-98 |

### 1.3 Reality-verification already on record (§25) — re-confirmed this turn, not re-derived

`CHANGELOG.md`'s 2026-07-11 entry (read in full this turn) documents 5 independent checks: original `0012` column list, full-repo ALTER-statement grep, local `information_schema` query (127.0.0.1:54322), cloud `information_schema` query (project `upzthfwhtvazfftxnyfu`), and `supabase db diff --linked` → "No schema changes found". This turn independently re-confirmed: the cloud project (`upzthfwhtvazfftxnyfu`, name `yoonsul_catchmenu`) is currently linked and `ACTIVE_HEALTHY` (not paused), via `supabase projects list`. No new drift found since the CHANGELOG entry was written.

---

## Part 2 — Overview

### 2.1 Problem

`catchmenu_pos.order_sessions` has no `customer_id` column. `0081` correctly avoided writing to a nonexistent column (commented out the dependent view/blocks). `0115`/`0116` were written without knowing this and reference `order_sessions.customer_id` directly — live execution of `register_waiting()` (0115) would fail with "column does not exist."

### 2.2 Goal

Add `order_sessions.customer_id` as a real FK to `customers(id)`, and give every guest order/wait a real `customers` row (`is_guest = true`) from the start, so `order_sessions.customer_id` is always populated — never null for an active session — and guest→member "conversion" is an in-place `UPDATE` of the same row (`is_guest: true → false` + real profile fields), not a merge of two different records.

### 2.3 Scope boundary (per Human decision, out of scope)

- Customer deletion/withdrawal retention handling — separate future WorkPackage. This migration only sets `ON DELETE SET NULL` on the new FK (the `order_sessions` row survives; only `customer_id` nulls out).
- `0081`'s `customer_order_history` view re-enablement — separate future WorkPackage (its dependent SELECT logic needs its own design pass, not bundled here).
- No backfill — the column has always been empty (never existed), so there is no historical data to backfill.

---

## Part 3 — Logic

### 3.1 DDL

```sql
-- new migration file, number TBD at Stage 3 approval time
-- (next free sequence number must be re-checked at approval time,
--  since new files may land between now and then)

alter table catchmenu_store.customers
  add column if not exists is_guest boolean not null default false;

alter table catchmenu_pos.order_sessions
  add column if not exists customer_id uuid
    references catchmenu_store.customers(id)
    on delete set null;

create index if not exists idx_order_sessions_customer
  on catchmenu_pos.order_sessions(customer_id)
  where customer_id is not null;
```

No backfill statement — confirmed no prior data exists for this column (§2.3).

### 3.2 Guest-promotion upsert logic (Human decision #3, concretized)

The existing `uq_customer_phone unique (tenant_id, phone_hash)` constraint on `customers` (confirmed in §1.1) is the natural upsert key for phone-identified guests: `bootstrap_customer_app`/`customer_login`-style lookup-by-`phone_hash`-or-create already exists in `0081` and `0097`. Guest promotion under this design is:

```sql
-- guest order/wait creation (illustrative, not the final migration):
-- 1. look up customers by (tenant_id, phone_hash) if phone_hash provided
-- 2. if not found, insert with is_guest = true
-- 3. use that customers.id as order_sessions.customer_id

-- later, member registration on the SAME phone_hash:
update catchmenu_store.customers
set is_guest = false,
    display_name = <real value>,
    -- other real profile fields
    updated_at = now()
where id = <same customer_id>;
-- no merge, no second row, no order_sessions rewrite needed --
-- existing order_sessions.customer_id already points at the right row
```

**Open Question (flagged, not resolved by this DesignPack):** what happens when a guest never provides a `phone_hash` at all (fully anonymous QR/table order, no phone entered)? `uq_customer_phone` can't dedupe on a null `phone_hash` (Postgres allows multiple NULLs under a UNIQUE constraint), so every such guest would get a brand-new `customers` row per order/wait session. This is not necessarily wrong (matches Human decision #3's "생성" language literally), but it means fully-anonymous guests get an unbounded stream of orphaned `is_guest=true` rows over time with no natural key to ever consolidate them — worth a Human decision at Stage 3 on whether that's accepted as-is or needs a device-fingerprint-based dedupe key.

### 3.3 `0116`'s `p_customer_id`-null caller-contract issue (checked per instruction)

Read `bootstrap_customer_app_v2()` (0116, lines 98-290) in full. Confirmed exact mechanism: lines 185-282 gate the ENTIRE customer/membership/active-waiting/active-order lookup block behind `if p_customer_id is not null then`. Under the current ("guest = no customer_id") convention, callers omit `p_customer_id` for guests, so this block is skipped — expected, since guests have no membership/history to show.

**Under the new design this becomes a real risk, not a non-issue**: guests now DO have a `customer_id` (their `is_guest=true` row) and DO have an active `order_sessions` row referencing it. If the calling client/gateway code is not updated to pass the guest's own `customer_id` into `bootstrap_customer_app_v2()`, this function will silently skip the `if p_customer_id is not null` block and the guest will never see their own active waiting session or order through this RPC — even though the underlying data now correctly links them. This is not a SQL bug (the conditional itself is fine); it is a **caller-contract change** that must be communicated to whatever consumes this RPC (Flutter app / webapp gateway layer, outside this repo's SQL). The other 4 functions in `0116` (starting lines 410, 513, 661, 801) don't use an explicit `if`-gate — they rely on implicit SQL null-comparison (`x = null` → never true), which has the same practical effect and the same caller-contract risk.

**Action for Stage 2/3**: this migration's `ChangeContract.md` (companion file) should NOT include any `.dart`/client-code files (out of scope, per Human decision boundary), but this finding must be explicitly carried into `NavigationMap.md`/`ChangeHistory.md` as a cross-repo dependency risk, since fixing the SQL alone does not fix the caller contract.

### 3.4 `005015` conflict check (read in full again this turn, not assumed from memory)

**Conflict found — flagged as Open Question, not "no conflict."** `005015`'s entire mental model assumes guest identity and customer account are two originally-*separate* records that later get *merged*:

- §5 "Identity Families" lists `Guest Identity` ("Temporary customer reference without login") and `Customer Account` ("Persistent known customer profile") as **distinct rows/concepts**.
- §8 "Guest-To-Account Merge" describes preserving "**Before/after identity linkage**" and a "**Merge actor**," "**Merge timestamp**" — language that only makes sense if there are two distinct identifiers being reconciled.

Under this migration's design (Human decision #3), there is no merge event at all — the guest's `customers` row **is** the account row from the moment it's created; promotion is a single in-place `UPDATE is_guest = false` on the same UUID. There is no "before identity" and "after identity" to link, because there was only ever one identity.

This doesn't make `005015` wrong — it describes a more general merge mechanism that may still be needed for cases this migration doesn't cover (e.g., a guest who used the app anonymously with no phone, then logs in with a *different* phone-verified account that already existed — a genuine two-record merge, per §10 "Duplicate Customer Detection"). But `005015` §8's specific list of merge triggers ("Guest logs in after waiting creation," "Guest logs in after cart creation," etc.) describes exactly the scenario this migration handles differently (in-place update, not merge) for the phone-hash-matched case. **Open Question for Stage 2 design lock**: does `005015` need a new subsection distinguishing "in-place promotion" (same row, phone_hash already matched) from "true merge" (two separate rows, reconciled), or does the existing merge language get reinterpreted to cover both? Recommend this be resolved explicitly before Stage 3 approval, since it affects how `005015` itself should be amended (or not) alongside this migration.
