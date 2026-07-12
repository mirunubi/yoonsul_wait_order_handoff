# TestAndContract — order_sessions.customer_id Forward Migration + Guest Promotion

CHANGE_ID: `order_sessions_customer_id_fk_and_guest_promotion`
Tier: Medium (§31) — TestPlan + ChangeContract sections combined per Medium-tier consolidation.
Status: DRAFT — requires Stage 3 Human approval before the ChangeContract section becomes binding and before any migration file is created.

---

## Part 1 — TestPlan

Per §28, prose intent alone is insufficient — every step below is a literal command to run, not a description.

### 1. Local apply

```powershell
cd D:\workspace\yoonsul_wait_order_handoff
python tools/apply_migrations.py
```
Expected: new migration file (number assigned at Stage 3) reports `APPLY ... OK`, and all prior 147 files still report `OK (already applied, checksum matches)` — a checksum mismatch on any prior file means something else changed it and must be investigated before proceeding, not silently accepted.

### 2. Direct column verification (local)

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_schema='catchmenu_pos' AND table_name='order_sessions' AND column_name='customer_id';"
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_schema='catchmenu_store' AND table_name='customers' AND column_name='is_guest';"
```
Expected: both return exactly one row (`customer_id`, `is_guest`).

### 3. RPC execution test — `register_waiting()` (0115)

Call `catchmenu_pos.register_waiting(...)` with a fresh `p_phone_hash` that does not already exist in `customers` for the test tenant/store. Expected: succeeds (previously would fail with "column customer_id does not exist"); returned `order_sessions.id` row, when queried directly, has a non-null `customer_id` pointing at a newly created `customers` row with `is_guest = true`.

```sql
select id, customer_id from catchmenu_pos.order_sessions where id = '<returned session_id>';
select id, is_guest, phone_hash from catchmenu_store.customers where id = '<customer_id from above>';
```

### 4. RPC execution test — `bootstrap_customer_app_v2()` (0116)

Call with the SAME guest `customer_id` from step 3 explicitly passed as `p_customer_id` (not omitted). Expected: the `if p_customer_id is not null` block (0116 line 185) executes, and the response's `active_waiting` field reflects the session created in step 3 — this specifically verifies the caller-contract finding in `DesignPack.md` §3.3: passing the guest's own `customer_id` is required for them to see their own data.

As a negative control, call again with `p_customer_id` omitted (simulating an un-updated caller) for the same guest. Expected (documenting the known risk, not a pass/fail bug): `active_waiting` is empty/null even though a real waiting session exists — confirms the caller-contract dependency is real and must be tracked outside this SQL change.

### 5. Guest → member conversion scenario (Human decision #3, end to end)

```sql
-- step a: confirm guest state after step 3
select id, is_guest, display_name, phone_hash from catchmenu_store.customers where id = '<customer_id>';
-- expect: is_guest = true

-- step b: simulate registration (same phone_hash, real profile fills in)
update catchmenu_store.customers
set is_guest = false, display_name = 'Test Member', updated_at = now()
where id = '<same customer_id>';

-- step c: confirm order_sessions.customer_id is UNCHANGED (same FK, no rewrite)
select customer_id from catchmenu_pos.order_sessions where id = '<session_id from step 3>';
-- expect: identical customer_id to step 3 -- proves no merge/rewrite occurred
```

### 6. Cloud pause check (must be re-run live at actual deploy time, not assumed from this document)

```powershell
supabase projects list
```
Look for `"ref":"upzthfwhtvazfftxnyfu"` and confirm `"status":"ACTIVE_HEALTHY"` (not `"INACTIVE"`/paused). Checked once already this turn (confirmed healthy) — re-check is mandatory immediately before Stage 7 cloud deploy since status can change between now and then.

### 7. Cloud apply + drift re-confirmation

```powershell
supabase db push --linked
supabase db diff --linked
```
Expected final line: `No schema changes found` — proves local and cloud are back in sync after the new migration, same verification method the CHANGELOG's 2026-07-11 entry already used.

---

## Part 2 — ChangeContract (requires Stage 3 Human approval before binding)

### 2.1 Allowed files (this change may create/modify)

| File | Action |
|---|---|
| `sql/migrations/0148_<name>.sql` (exact number/name assigned at Stage 3) | CREATE — the DDL from `DesignPack.md` §3.1 |
| `sql/migrations/CHANGELOG.md` | APPEND-ONLY — new entry recording this migration's application, per the file's own append-only convention |
| `docs/implementation_evidence/order_sessions_customer_id_fk_and_guest_promotion/06_ImplementationAndVerification.md` | CREATE — Stage 4/5 artifact, not this turn |
| `docs/000700_ai_agent_prelearning_and_project_context/000701_...md`'s `NavigationMap.md`/`ChangeHistory.md` equivalents (if they exist for this domain) | UPDATE — new row per §32 |

### 2.2 Forbidden files (explicitly out of scope, per Human decision boundary)

- `sql/migrations/0081_create_customer_app_rpc.sql` — do NOT re-enable the `customer_order_history` view or its dependent commented-out blocks. Separate future WorkPackage.
- Any customer-deletion/withdrawal/retention logic or migration — separate future WorkPackage (Human decision #2).
- Any `.dart`/Flutter client code or webapp gateway code — the `0116` caller-contract issue (`DesignPack.md` §3.3) is flagged as a cross-repo risk, not fixed here; no client-side files are touched by this change.
- `005015_Policy_Customer_Account_Guest_Merge...md` — the conflict flagged in `DesignPack.md` §3.4 is an Open Question for Stage 2 design lock, not something this ChangeContract authorizes editing yet.
- Any other `sql/migrations/*.sql` file not listed in §2.1 above.

### 2.3 Human Boundary Approval (pending — Stage 3, not yet granted)

☐ Approved — proceed to assign migration file number and create it
☐ Approved with modifications — see notes
☐ Not approved — blocked pending: _______________

**Per `000701` §4 Core Rule ("No implementation without a recorded human approval")**: no migration file exists in `sql/migrations/` for this change as of this document. None will be created until this section is signed off.
