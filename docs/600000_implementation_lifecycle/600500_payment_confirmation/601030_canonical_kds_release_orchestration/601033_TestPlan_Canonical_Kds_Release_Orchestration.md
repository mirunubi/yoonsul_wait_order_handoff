# 601033_TestPlan_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## §0 Scope and numbering confirmation

This TestPlan verifies the final design fixed in `601031_Overview_Canonical_Kds_Release_Orchestration.md` and `601032_Logic_Canonical_Kds_Release_Orchestration.md` — both already carried a triple-verification round (Cursor+Codex Stage 4 Critical tier) and a subsequent correction round (0-ticket `result_code`, §3 contradiction, §2.1 hardcoding, idempotency priority, §6 sync). This TestPlan cites that design as final and does not re-litigate it.

**Migration number reconfirmed live (2026-07-18)**: `sql/migrations/` tops out at `0165_menu_price_list_architecture_phase0.sql`; `catchmenu_meta.migration_history` independently confirms `0165` as the latest applied entry. No `0166`/`0167` file exists on disk or in migration history. `0166` is the next available number — Stage 8 must re-run this exact check immediately before creating the migration file, in case another workpacket claims it in the interim (same discipline as `0163`/`0164`/`0165`).

**Live-reconfirmed at Stage 5 (2026-07-18, this session, via `docker exec ... psql`)**, all matching `601031_Overview.md` §1's assumptions with no drift:

```text
catchmenu_kds.bulk_commit_kds_tickets(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_force_conditions jsonb, p_correlation_id text)
catchmenu_kds.commit_kds_ticket(p_tenant_id uuid, p_store_id uuid, p_ticket_id uuid, p_conditions jsonb, p_correlation_id text)
catchmenu_kds.evaluate_kds_capacity(p_tenant_id uuid, p_store_id uuid, p_kitchen_zone text)
catchmenu_payment.confirm_payment_from_provider(p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_provider_payment_key text, p_provider_approval_number text, p_approved_amount integer, p_provider_raw_event_id uuid, p_correlation_id text)
```

`catchmenu_payment.request_kds_release_after_payment` — **0 rows found live** (confirmed does not exist yet; this is the intended pre-implementation state).

`pg_get_functiondef()` on the live `confirm_payment_from_provider()` was diffed against `sql/migrations/0027_create_payment_intent_rpc.sql` — identical (declare block, intent validation, `payment_ledger` INSERT with `kds_release_authorized := false`, `kds_tickets`/`kds_events` updates, `payment_events`/`catchmenu_ledger.events` inserts, `append_audit_record()` call, and the final `return jsonb_build_object(...)` at lines 415-427 exactly as `601032_Logic.md` §2.1 assumes). No `EXCEPTION` handler present, confirmed (matches `601032_Logic.md` §2.2's premise).

## §1 Pre-flight checks

### §1.1 Target-object collision check

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "SELECT n.nspname, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'catchmenu_payment' AND p.proname = 'request_kds_release_after_payment';"
```

Expected: 0 rows, immediately before Stage 8 begins.

### §1.2 `append_audit_record()` contract check

```powershell
Select-String -Path "sql\migrations\0008_create_ledger_audit.sql" -Pattern "chk_audit_domain|chk_audit_category|chk_audit_decision" -Context 0,15
```

**(Stage 4 Critical tier 정정, Cursor+Codex 교차검증 — 이전 Stage 5 초안의 검증 공백)** 이전 초안은 여기서 "`decision` has no CHECK constraint (free text)"라고 잘못 기술했다 — 실제로는 `0008_create_ledger_audit.sql:105-119`에 `chk_audit_decision` 제약이 존재하며, 허용값은 정확히 다음 11개뿐이다:

```text
APPROVED, REJECTED, OVERRIDDEN, DELEGATED, ESCALATED,
CANCELLED, COMPLETED, FAILED, NOTED, SUSPENDED, REVOKED
```

**이 오기(誤記)가 실제 설계 결함을 놓치게 만든 원인이다**: `601032_Logic.md` §1.2의 원래 `p_decision` 매핑은 `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD` 두 분기 모두에 대해 `'PENDING'`을 매핑했는데, `'PENDING'`은 이 11개 허용값에 없다 — 즉 이 두 분기가 실행될 때마다 `append_audit_record()`의 `INSERT`가 `chk_audit_decision` 위반으로 크래시하고, `request_kds_release_after_payment()` 자신의 `EXCEPTION WHEN OTHERS` 핸들러가 이를 잡아 `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED`로 잘못 보고했을 것이다 — 결제는 정상이고 KDS도 정상적으로 대기 상태였을 뿐인데 "실패"로 오분류되는 심각한 결함이었다. `601032_Logic.md`/`601033_TestPlan.md`/`601034_ChangeContract.md`에서 `'SUSPENDED'`로 정정됐다(아래 §2.2/§2.3, `601032_Logic.md` §1.2, `601034_ChangeContract.md` §2.1/§8 참고).

Expected: `chk_audit_domain` includes `'payment'`; `chk_audit_category` includes `'OPERATIONAL'` and `'FINANCIAL'`; `chk_audit_decision` includes exactly the 11 values above — `'APPROVED'`/`'FAILED'`/`'NOTED'`/`'SUSPENDED'` (the corrected 4 decision branches used by `601032_Logic.md` §1.2) are all valid; `'PENDING'` is **not** valid and must never appear in a `p_decision` argument to `append_audit_record()`.

### §1.3 `payment_ledger` / `kds_tickets` schema reconfirmation

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "\d catchmenu_payment.payment_ledger"
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "\d catchmenu_kds.kds_tickets"
```

Expected: `payment_ledger.kds_release_authorized`/`kds_release_authorized_at`/`kds_release_authorized_by` present exactly as `601032_Logic.md` §1.2 Step 1 assumes; `kds_tickets.conditions_met jsonb not null default '{}'::jsonb`, `kds_status text not null default 'HOLD'`, `payment_ledger_id uuid` nullable, `ticket_number`/`menu_name_snapshot`/`business_day` `not null` (fixtures below must supply them).

Note (informational only, not a Stop Condition): `payment_ledger` carries a partial index `idx_payment_ledger_kds_auth ... WHERE kds_release_authorized = false AND ledger_status = 'APPROVED'`. Once Step 1 sets a row's `kds_release_authorized = true`, that row naturally falls out of this index's coverage — expected and harmless (the index exists to help a future retry/backlog scanner, `601031_Overview.md` §6 (a), find rows still needing authorization; this workpacket doesn't add such a scanner).

## §2 `request_kds_release_after_payment()` — all 5 `result_code` branches

Each scenario is isolated in its own `begin;...rollback;` block. Tests call the **live function** (created by Stage 8) directly — per `AGENTS.md` §3.8, this is only valid once `601034_ChangeContract.md` §10 reads `APPROVED`; until then these SQL blocks are the specification Stage 8/9 must execute, not something this Stage-5 draft itself runs.

Shared fixture constants: `p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid`, `p_store_id := '00000000-0000-0000-0000-000000000002'::uuid` (both reused from `601032_Logic.md` §3's already-validated fixtures).

### §2.1 Scenario 1 — full commit, `PAYMENT_CONFIRMED_KDS_COMMITTED`

Fixture: order `CV601033-S1-COMMIT`, one `payment_ledger` row (`kds_release_authorized = false`), two `kds_tickets` rows (`T-S1-A`, `T-S1-B`), both with `conditions_met = {"arrived":true,"table_confirmed":true,"payment_confirmed":true}`, `kds_status = 'HOLD'`.

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S1-COMMIT', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S1', 'idem-601033-s1',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S1-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S1-B', 'HOLD', 'CV601033 Test Menu B',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_b_id \gset

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s1'
) as result;

select ticket_number, kds_status from catchmenu_kds.kds_tickets where id in (:'ticket_a_id'::uuid, :'ticket_b_id'::uuid);
select kds_release_authorized from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED'`, `committed_count = 2`, `pending_count = 0`, `skipped_count = 0`. Before rollback, both tickets read `kds_status = 'COMMITTED'` and `payment_ledger.kds_release_authorized = true`.

### §2.2 Scenario 2 — mixed, `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD`

Fixture: order `CV601033-S2-PARTIAL`, two tickets: `T-S2-A` with `conditions_met = {"arrived":true,"table_confirmed":true,"payment_confirmed":true}` (commits), `T-S2-B` with `conditions_met = {"arrived":false,"table_confirmed":true,"payment_confirmed":true}` (missing `arrived` — stays `CAPACITY_CHECKING`, per `commit_kds_ticket()`'s 7-condition `AND`, `0028:155-177` live-reconfirmed).

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S2-PARTIAL', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S2', 'idem-601033-s2',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S2-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S2-B', 'HOLD', 'CV601033 Test Menu B',
  jsonb_build_object('arrived', false, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_b_id \gset

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s2'
) as result;

select ticket_number, kds_status from catchmenu_kds.kds_tickets where id in (:'ticket_a_id'::uuid, :'ticket_b_id'::uuid);

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD'`, `committed_count = 1`, `pending_count = 1`, `skipped_count = 0`. `T-S2-A` reads `COMMITTED`, `T-S2-B` reads `CAPACITY_CHECKING`. **(Stage 4 정정)** The associated `catchmenu_ledger.audit_records` row must have `decision = 'SUSPENDED'` (not `'PENDING'` — `chk_audit_decision` rejects `'PENDING'`; see §3).

### §2.3 Scenario 3 — none commit, `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD`

Fixture: order `CV601033-S3-HOLD`, two tickets, both with `conditions_met = {"arrived":false,"table_confirmed":true,"payment_confirmed":true}`.

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S3-HOLD', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S3', 'idem-601033-s3',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S3-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', false, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S3-B', 'HOLD', 'CV601033 Test Menu B',
  jsonb_build_object('arrived', false, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_b_id \gset

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s3'
) as result;

select ticket_number, kds_status from catchmenu_kds.kds_tickets where id in (:'ticket_a_id'::uuid, :'ticket_b_id'::uuid);

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'`, `committed_count = 0`, `pending_count = 2`, `skipped_count = 0`. Both tickets read `CAPACITY_CHECKING`. **(Stage 4 정정)** The associated `catchmenu_ledger.audit_records` row must have `decision = 'SUSPENDED'` (not `'PENDING'` — `chk_audit_decision` rejects `'PENDING'`; see §3).

### §2.4 Scenario 4 — zero tickets, `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`

Fixture: order `CV601033-S4-ZEROTKT`, one `payment_ledger` row, **no** `kds_tickets` row at all (simulates a webhook resend for an order whose tickets already left `HOLD`/`CAPACITY_CHECKING` in a prior call).

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S4-ZEROTKT', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S4', 'idem-601033-s4',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

-- deliberately no kds_tickets insert -- order has zero eligible tickets

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s4'
) as result;

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'`, `committed_count = 0`, `pending_count = 0`, `skipped_count = 0` — **must not** be `'PAYMENT_CONFIRMED_KDS_COMMITTED'` (this is the exact regression `601032_Logic.md` §1.2/§3.3 fixed; re-verify independently here, do not trust the Stage-5-session's own prior `pg_temp` run, `601032_Logic.md` §6 (g)).

### §2.5 Scenario 5 — gate rejection, `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED`

Fixture: order `CV601033-S5-BLOCKED`, a real `payment_ledger` row for the order (`kds_release_authorized = false`, left untouched), one `kds_tickets` row in `HOLD`. Call `request_kds_release_after_payment()` with **`p_ledger_id := '00000000-0000-0000-0000-0000000009ff'::uuid`** — a value that does not match any row for this `tenant_id`/`store_id`. Step 1's `UPDATE` therefore matches 0 rows; the real ledger row's `kds_release_authorized` stays `false`; `bulk_commit_kds_tickets()`'s own gate (`0039:38-53`, live-reconfirmed) then returns `success:false, error_key:'kds_release_not_authorized'` before even reaching the per-ticket loop.

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S5-BLOCKED', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S5', 'idem-601033-s5',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S5-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

-- deliberate mismatch: this ledger_id does not correspond to any real payment_ledger row
-- for this tenant/store, so Step 1's UPDATE affects 0 rows and the real ledger row above
-- (:'ledger_id') keeps kds_release_authorized = false.
select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := '00000000-0000-0000-0000-0000000009ff'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s5'
) as result;

select kds_release_authorized from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;
select kds_status from catchmenu_kds.kds_tickets where id = :'ticket_a_id'::uuid;

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED'`, and — **(Stage 4 Critical tier 정정, Codex 재현)** — `committed_count`/`pending_count`/`skipped_count` are all `null` (not `0`): `bulk_commit_kds_tickets()`'s own gate check (`0039:38-53`) returns `{success:false, error_key:'kds_release_not_authorized', ...}` before the per-ticket loop ever runs, so these keys are never populated in `v_bulk_result` and `v_bulk_result->'committed_count'` resolves to JSON `null` when re-embedded via `jsonb_build_object`. The real ledger row's `kds_release_authorized` stays `false` (Step 1 never matched it), and the fixture's real `kds_tickets` row is untouched (still `HOLD`) — confirms the gate rejection is clean and does not partially mutate ticket state.

## §3 Audit record verification — all 5 branches

Immediately after each §2 scenario's function call (before `rollback`), run:

```sql
select audit_type, decision, decision_payload->>'result_code' as result_code
from catchmenu_ledger.audit_records
where subject_type = 'payment_ledger' and subject_id = :'ledger_id'::uuid
order by recorded_at desc
limit 1;
```

Expected `decision` per scenario (`601032_Logic.md` §1.2's `p_decision := case ... end`):

| Scenario | `result_code` | `decision` |
|---|---|---|
| §2.1 | `PAYMENT_CONFIRMED_KDS_COMMITTED` | `APPROVED` |
| §2.2 | `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD` | `SUSPENDED` |
| §2.3 | `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD` | `SUSPENDED` |
| §2.4 | `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS` | `NOTED` |
| §2.5 | `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED` | `FAILED` |

**(Stage 4 Critical tier 정정 — `'PENDING'`은 `chk_audit_decision`의 허용값이 아니므로 §1.2에서 정정된 `'SUSPENDED'`로 교체됐다. §2.2/§2.3 실행 시 반드시 이 값으로 감사기록이 성공적으로 INSERT되는지 확인할 것 — 이전 값(`'PENDING'`)으로 실행했다면 이 INSERT 자체가 크래시해 `EXCEPTION` 핸들러로 빠지고 `result_code`가 `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED`로 잘못 보고됐을 것이다. §2.2/§2.3의 "Expected" 절 자체도 이 값으로 갱신됐다.)**

All rows must have `audit_domain = 'payment'`, `audit_type = 'kds_release_requested'` (§2.5's `RELEASE_BLOCKED` case is still the non-exception path — it goes through the same `case` block, not the `EXCEPTION` handler's separate `kds_release_requested_failed` audit_type; confirm this distinction explicitly, it is easy to conflate with §4 below).

## §4 EXCEPTION path — `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED`

Reproduces `601032_Logic.md` §3.2's technique as executable SQL against the live function (the Stage-5 session's own `pg_temp` run of this scenario must not be trusted as sufficient — re-run independently, `601032_Logic.md` §6 (g)).

```sql
begin;
-- fixture: order 'CV601033-S6-EXCEPTION', payment_ledger row, one kds_tickets row (HOLD,
-- conditions_met fully satisfied so commit_kds_ticket() would otherwise succeed).

alter table catchmenu_kds.kds_events
  add constraint tmp_601033_block_all_conditions_met check (event_type <> 'all_conditions_met');

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s6-exception'
) as result;

-- critical check: the payment_ledger row inserted BEFORE this call must survive untouched.
select ledger_status, approved_amount from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;

-- the ticket's own commit UPDATE must have rolled back to HOLD (commit_kds_ticket()'s own atomicity).
select kds_status from catchmenu_kds.kds_tickets where id = :'ticket_id'::uuid;

select audit_type, decision, decision_payload->>'sqlstate' as sqlstate
from catchmenu_ledger.audit_records
where subject_type = 'payment_ledger' and subject_id = :'ledger_id'::uuid
order by recorded_at desc limit 1;

alter table catchmenu_kds.kds_events drop constraint tmp_601033_block_all_conditions_met;
rollback;
```

Expected:

1. The function call itself does **not** raise — returns `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', error_detail:{sqlstate:'23514'}}`.
2. The pre-existing `payment_ledger` row is unchanged (`ledger_status='APPROVED'`).
3. The `kds_tickets` row remains `HOLD` (its own attempted transition rolled back).
4. A separate audit row exists with `audit_type = 'kds_release_requested_failed'`, `decision = 'FAILED'`, `decision_payload->>'sqlstate' = '23514'` — distinct from §3's `kds_release_requested` audit type.

## §5 `kds_release_authorized_by` actor propagation

Using §2.1's Scenario 1 fixture (or a fresh minimal one-ticket variant), call with `p_actor_type := 'PROVIDER'` and confirm:

```sql
select kds_release_authorized_by from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;
```

Expected: `'PROVIDER'` (not `'SYSTEM'`) — confirms `601032_Logic.md` §1.4's design (the new function does not hardcode the actor, unlike `release_kds_after_payment()`'s `'SYSTEM'` hardcode).

## §6 `confirm_payment_from_provider()`(`0027`) modification verification

### §6.1 `payment_ledger` INSERT unchanged

```powershell
git diff -- sql/migrations/0027_create_payment_intent_rpc.sql
```

Expected (after Stage 8 implementation): the `insert into catchmenu_payment.payment_ledger (...)` block (source lines 263-289 pre-change) is byte-identical to before — only the code after the existing `audit_id` calculation and the final `return` block changes, per `601032_Logic.md` §2.1's exact insertion point. **(2026-07-18, Option C)** the inserted code is a narrow nested `begin...exception when others...end;` block wrapping only the `request_kds_release_after_payment()` call — nothing before that insertion point (intent validation, the `payment_ledger` INSERT, `kds_tickets`/`kds_events` updates, this function's own `append_audit_record()` call) is wrapped or otherwise modified.

### §6.2 End-to-end: committed case

Call the full `confirm_payment_from_provider()` webhook entry point (not the new function directly) against a fixture where the order's ticket(s) will fully commit:

```sql
begin;
-- fixture: payment_intents row (intent_status='CONFIRMED' precondition via create_payment_intent(),
-- or a direct fixture row matching 0027's SELECT), kds_tickets row(s) with conditions_met
-- pre-seeded {"arrived":true,"table_confirmed":true} (payment_confirmed is set by this call itself).
select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_id'::uuid,
  p_provider_payment_key := 'test-pk-601033-e2e-commit',
  p_provider_approval_number := 'test-appr-601033-e2e-commit',
  p_approved_amount := 15000,
  p_provider_raw_event_id := :'raw_event_id'::uuid,
  p_correlation_id := 'verify-601033-e2e-commit'
) as result;
rollback;
```

Expected response: `success:true`, `ledger_status:'APPROVED'`, `result_code:'PAYMENT_CONFIRMED_KDS_COMMITTED'`, **`kds_release_authorized:true`** (derived from `result_code`, per `601032_Logic.md` §2.1's corrected hardcoding fix), `message_code:'payment_approved_kds_released'`.

### §6.3 End-to-end: non-committed case (the corrected-hardcoding regression test)

Repeat §6.2 with a fixture ticket missing `arrived` (so it lands in `CAPACITY_CHECKING`, `result_code = 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'`).

Expected response: `success:true` still (payment itself succeeded — §2 principle), `ledger_status:'APPROVED'` still, `result_code:'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'`, **`kds_release_authorized:false`** — this is the exact case the Stage 4 hardcoding fix targets. Before the fix this field would have incorrectly read `true`. `message_code:'payment_approved_kds_pending'`.

### §6.4 Option C narrow wrapper — simulated call-site exception (2026-07-18 addition, ChatGPT-designed redesign)

Reproduces the scenario `601032_Logic.md` §2.2 designed for but which cannot occur under normal operation (`request_kds_release_after_payment()` already swallows all its own internal exceptions) — this test instead forces an exception to occur **at the call site itself**, before the callee's own body ever runs, by temporarily breaking the call target inside a transaction that gets rolled back afterward (the rename is transactional in Postgres, so it is fully undone by `rollback;` — no permanent schema change).

```sql
begin;
-- fixture: same shape as §6.2 (payment_intents row, kds_tickets row(s) with
-- conditions_met pre-seeded so the ticket would otherwise commit normally).

alter function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) rename to request_kds_release_after_payment_tmp_renamed_601033;

select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_id'::uuid,
  p_provider_payment_key := 'test-pk-601033-optionc',
  p_provider_approval_number := 'test-appr-601033-optionc',
  p_approved_amount := 15000,
  p_provider_raw_event_id := :'raw_event_id'::uuid,
  p_correlation_id := 'verify-601033-optionc'
) as result;

-- critical check: the payment_ledger row (INSERTed by confirm_payment_from_provider()
-- BEFORE the narrow wrapped call) must have survived, even though the call inside
-- the narrow block failed with "function does not exist".
select ledger_status, approved_amount, kds_release_authorized
from catchmenu_payment.payment_ledger
where intent_id = :'intent_id'::uuid;

select audit_type, decision, decision_payload->>'sqlstate' as sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'kds_release_call_unexpected_exception'
order by recorded_at desc limit 1;

alter function catchmenu_payment.request_kds_release_after_payment_tmp_renamed_601033(
  uuid, uuid, uuid, uuid, text, text
) rename to request_kds_release_after_payment;

rollback;
```

Expected:

1. The call to `confirm_payment_from_provider()` does **not** raise — the deliberately-broken call target is caught by the §2.1 narrow inner block, not allowed to propagate out of the whole function.
2. The response is `success:true`, `ledger_status:'APPROVED'`, `result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED'`, `kds_release_authorized:false` — reported identically to the shape the new function itself would return from its own internal `EXCEPTION` handler (`601033_TestPlan.md` §4), so the caller cannot distinguish "caught inside the new function" from "the call to the new function itself failed."
3. The `payment_ledger` row created earlier in the same function invocation is present and unaffected (`ledger_status='APPROVED'`) — confirms the narrow block's implicit savepoint starts after payment-core work, not before it (`601032_Logic.md` §2.1/§2.2's live `pg_temp` finding, re-verified here against the actual live function chain rather than a `pg_temp` stand-in).
4. A `catchmenu_ledger.audit_records` row exists with `audit_type = 'kds_release_call_unexpected_exception'`, `decision = 'FAILED'`, `decision_payload->>'sqlstate' = '42883'` (`undefined_function`).
5. The final `alter function ... rename` (undoing the temporary break) is redundant with `rollback;` but included for clarity/defense-in-depth — either one alone is sufficient since `ALTER FUNCTION ... RENAME` is transactional in Postgres.

## §7 Boundary — 0 diff

### §7.1 User-specified boundary set

```powershell
git diff -- `
  sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql `
  sql/migrations/0028_create_kds_capacity_commit_rpc.sql `
  sql/migrations/0039_create_kds_bulk_commit_rpc.sql `
  sql/migrations/0110_create_store_admin_rpc.sql `
  sql/migrations/0141_hyper_personalization_menu_customization.sql `
  sql/migrations/0162_create_dining_table_admin_rpc.sql `
  sql/migrations/0163_seat_waiting_customer_facade_correction.sql `
  sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql `
  sql/migrations/0165_menu_price_list_architecture_phase0.sql
```

Expected: no diff on any of these 9 files. In particular `confirm_payment()` inside `0098` — this workpacket does not touch the POS payment path (`601031_Overview.md` §0.2 (3), Open Item (b)).

### §7.2 Additional established-scope boundary (already forbidden per `601031_Overview.md` §5, reconfirmed here)

```powershell
git diff -- `
  sql/migrations/0038_create_toss_webhook_processor_rpc.sql `
  sql/migrations/0056_create_van_integration_rpc.sql `
  sql/migrations/0143_add_no_payment_kds_release_policy.sql
```

Expected: no diff. `0038`/`0056` call `confirm_payment_from_provider()` but their own caller-side code is not part of this contract.

### §7.3 `resolve_payment_uncertain()` boundary (same file as the edited function, different function)

```powershell
git diff -- sql/migrations/0027_create_payment_intent_rpc.sql
```

Manual review requirement (a single-file diff can't isolate this automatically): confirm the diff touches only `confirm_payment_from_provider()`'s body — `create_payment_intent()`, `mark_payment_uncertain()`, and `resolve_payment_uncertain()` (the other 3 functions in the same file) show 0 changes.

### §7.4 Runtime boundary

```powershell
git diff -- catchmenu_app
```

Expected: no diff.

## §8 Acceptance criteria

The workpacket passes Stage 9 verification only if all of the following are true:

1. `request_kds_release_after_payment()` correctly produces all 5 `result_code` values under the fixtures in §2 — **(Stage 4 Critical tier 정정, Codex 재현 결과 반영)** distinguished by count-field behavior, not treated as one uniform group:
   - `PAYMENT_CONFIRMED_KDS_COMMITTED` (§2.1), `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD` (§2.2), `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD` (§2.3), `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS` (§2.4): `committed_count`/`pending_count`/`skipped_count` are all present with matching integer values (0 for the fields that don't apply).
   - `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED` (§2.5): `committed_count`/`pending_count`/`skipped_count` must be `null` — `bulk_commit_kds_tickets()`'s own gate rejection (`0039:46-53`) returns before the per-ticket loop runs at all, so no aggregation ever occurs; `v_bulk_result->'committed_count'` etc. resolve to JSON `null` via `jsonb_build_object`, not `0` and not an absent key. A Stage 9 check asserting `= 0` for this branch is itself a bug, not a passing test.
2. §2.4's zero-ticket case never returns `PAYMENT_CONFIRMED_KDS_COMMITTED` (regression guard for the Stage 4 fix).
3. Every §2 scenario produces exactly one `catchmenu_ledger.audit_records` row with `audit_domain='payment'`, `audit_type='kds_release_requested'`, and the `decision` value from §3's table.
4. The forced-exception scenario (§4) does not raise out of `request_kds_release_after_payment()`, leaves the pre-existing `payment_ledger` row untouched, rolls back the ticket's own attempted transition, and writes a separate `kds_release_requested_failed` audit row.
5. `kds_release_authorized_by` reflects the caller's `p_actor_type` (§5), not a hardcoded value.
6. `confirm_payment_from_provider()`'s `payment_ledger` INSERT block is unchanged (§6.1); its response's `kds_release_authorized` field is `true` only when `result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED'` (§6.2/§6.3) — not hardcoded.
7. **(2026-07-18, Option C)** A simulated call-site exception at `request_kds_release_after_payment()` (§6.4) is caught by the narrow inner block only — it does not propagate out of `confirm_payment_from_provider()`, and the `payment_ledger` row created earlier in the same invocation survives untouched. `confirm_payment_from_provider()` has no exception handler wrapping its own payment-core logic (intent validation through the `payment_ledger` INSERT) — a genuine failure in that region must still propagate naturally as a real payment failure, not be caught by anything added in this workpacket.
8. All 9 user-specified boundary files (§7.1) plus `0038`/`0056`/`0143` (§7.2) plus `resolve_payment_uncertain()`/`create_payment_intent()`/`mark_payment_uncertain()` within `0027` itself (§7.3) show 0 diff. `catchmenu_app` shows 0 diff (§7.4).
9. `catchmenu_kds.bulk_commit_kds_tickets()`, `catchmenu_kds.commit_kds_ticket()`, `catchmenu_kds.evaluate_kds_capacity()` are not modified — no migration in this workpacket contains `create or replace function catchmenu_kds.(bulk_commit_kds_tickets|commit_kds_ticket|evaluate_kds_capacity)`.
