# 600564_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: Codex
Date: 2026-07-16

## 0. Purpose

This ChangeContract authorizes the minimal Stage 4 implementation required to close the `resolve_or_create_payment_intent()` race condition documented in `600561_Overview_Payment_Intent_Race_Condition_Fix.md` and resolved by option (a) in `600562_Logic_Payment_Intent_Race_Condition_Fix.md`.

The approved mechanism is:

1. Reconfirm the existing duplicate pair and FK safety.
2. Delete exactly the known loser row if and only if it is still unreferenced.
3. Add a UNIQUE constraint on `payment_intents.idempotency_key`.
4. Convert the resolver INSERT to `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`.

## 1. Allowed Files And Operations

### 1.1 New Migration File

Allowed: one new migration file using the next available migration number.

Expected filename pattern:

```text
sql/migrations/<next>_fix_payment_intent_idempotency_key_race.sql
```

The file may contain only the operations listed in this section.

### 1.2 Existing Duplicate Cleanup

Allowed: delete exactly one known loser row:

```sql
delete from catchmenu_payment.payment_intents
where id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';
```

This DELETE is allowed only after Stage 4 reruns the five FK reference checks in `600563_TestPlan.md` §1.2 and all five counts are still 0.

The winner row must remain:

```text
17f67f52-e80d-47e9-a5ec-7e351a4e6dcf
```

If the loser row has gained a reference since `600562_Logic.md`, STOP. Do not delete, rewire, or pick a different winner without Human approval.

### 1.3 UNIQUE Constraint

Allowed:

```sql
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

No other constraint may be added in this workpacket.

### 1.4 `resolve_or_create_payment_intent()` Function Body

Allowed: redefine only `catchmenu_payment.resolve_or_create_payment_intent(...)` so the observed-intent INSERT branch changes from plain INSERT to:

```sql
on conflict (idempotency_key) do update
set updated_at = now()
returning id into v_intent_id;
```

The rest of the function must preserve the `0158_confirm_payment_intent_linkage_fix.sql` source behavior:

- approved `intent_origin` validation;
- `PREAUTHORIZED` branch behavior;
- `v_origin_reference := coalesce(p_origin_reference, '{}'::jsonb)`;
- normalized `v_payment_method`, `v_payment_channel`, and `v_provider_type`;
- existing candidate conflict error for multiple active candidates;
- deterministic `idempotency_key` format:

```sql
'OBS-' || p_order_id::text || '-' || p_intent_origin || '-'
  || substr(md5(v_origin_reference::text), 1, 12)
```

No `pg_sleep`, race-window comment, or test-specific `OBS-RACE` logic may appear in the production function body.

## 2. Forbidden Files And Operations

The following are forbidden in this workpacket:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
- `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql`
- `sql/migrations/0109_create_network_handoff_fallback_rpc.sql`
- `sql/migrations/0130_create_van_handler_extension.sql`
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`
- `confirm_payment()` body changes
- `confirm_payment_from_provider()` changes
- Toss binding trigger changes
- payment ledger schema changes
- advisory lock redesign
- `orders FOR UPDATE` redesign
- changes to unrelated payment/KDS/DID/Flutter files

Do not modify `0142`; it is a reference and boundary verification target only.

## 3. Required Stage 4 Order

Stage 4 must execute in this exact order:

1. Reconfirm the duplicate pair and five FK counts from `600563_TestPlan.md` §1.
2. Run the pre-cleanup negative UNIQUE test from `600563_TestPlan.md` §2 and confirm it fails while the duplicate remains.
3. Delete loser row `283f3973-d547-4ea9-b4ad-b83b1c62b8cc`.
4. Confirm only winner row `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf` remains for the duplicate `idempotency_key`.
5. Add `uq_payment_intents_idempotency_key`.
6. Redefine `resolve_or_create_payment_intent()` with `ON CONFLICT ... DO UPDATE ... RETURNING id`.
7. Verify live function body through `pg_get_functiondef()`.
8. Run concurrency race verification.
9. Drop all `__test_` helpers and clean test rows.
10. Run boundary diff checks.

Skipping the negative UNIQUE test is not allowed; it proves the constraint catches the existing failure mode.

## 4. Test Isolation Contract

Any deliberate concurrency/race reproduction helper must follow all of these rules:

- Function name must start with `__test_`.
- Helper must be dropped at the end of the test.
- Helper must never replace production function bodies.
- Helper must never be named with ad hoc prefixes such as `__pay_con`.
- Test SQL must include cleanup verification showing no `__test_`, `slow`, `slow_resolve`, or `pay_con` helper remains.

This is mandatory because the prior investigation temporarily polluted live DB state with:

- `PERFORM pg_sleep(1.5)` inside live `resolve_or_create_payment_intent()`;
- `catchmenu_payment.__pay_con002_slow_resolve(...)`.

Both were removed before this ChangeContract, and this workpacket must not recreate that class of live pollution.

## 5. Open Items Carried Forward

(a) `600561_Overview.md` §7 (a): adding UNIQUE on `idempotency_key` should remain compatible with other intent creation paths, including `0027` and `0142`. Stage 4 must verify no existing non-test rows violate the constraint before final application.

(b) The old advisory-lock namespace question is moot for this workpacket because option (a) was chosen. It may become relevant only if a future workpacket adopts advisory locks elsewhere.

(c) The old option (b)/(c) lock-interaction tests are moot for this workpacket because option (a) was chosen.

(d) The known live duplicate pair must be handled carefully. Stage 4 may delete only the documented loser row and only after FK re-verification.

(e) If Stage 4 discovers any new duplicate `idempotency_key` groups beyond the documented pair, STOP and report. Do not bulk-delete or infer winners.

(f) If the UNIQUE constraint fails after deleting the documented loser, STOP and report the full duplicate inventory.

(g) FK reference state can change between Stage 2 and Stage 4. Therefore FK checks are not merely documentation; they are a hard precondition for deletion.

(h) Test isolation rules should be considered for promotion into a broader project rule after this workpacket, but this ChangeContract only enforces them for this workpacket.

## 6. Boundary Verification Required After Implementation

Stage 4 must report:

- duplicate pair pre-check result;
- five FK count results;
- negative UNIQUE test error before cleanup;
- loser DELETE result;
- final UNIQUE constraint definition;
- final `pg_get_functiondef()` excerpt showing `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`;
- two-session race test result showing the same `intent_id` returned to both sessions;
- normal distinct-event regression results;
- helper cleanup result `(0 rows)`;
- `git diff --check` result;
- forbidden-file diff result, especially `0142` unchanged.

## 7. Human Boundary Approval

☑ I approve deleting only the documented unreferenced loser row 283f3973-d547-4ea9-b4ad-b83b1c62b8cc after Stage 4 reruns the FK checks and confirms all five counts are still 0.
☑ I approve adding uq_payment_intents_idempotency_key UNIQUE (idempotency_key) to catchmenu_payment.payment_intents.
☑ I approve redefining only catchmenu_payment.resolve_or_create_payment_intent(...) so its observed-intent INSERT uses ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id.
☑ I approve the forbidden-file boundary and the mandatory __test_ helper isolation / cleanup requirements. (2026 - 07 - 16).

