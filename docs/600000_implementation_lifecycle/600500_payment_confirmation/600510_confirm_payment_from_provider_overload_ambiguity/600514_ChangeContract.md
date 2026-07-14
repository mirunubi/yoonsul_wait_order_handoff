# 600514_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`confirm_payment_from_provider_overload_ambiguity`

## §0 Authority

This ChangeContract is based on:

- `600511_Overview.md` (incl. §0.5 Human final decision, 2026-07-14)
- `600512_Logic.md`
- `600513_TestPlan.md`

The accepted design is not reopened here:

- `catchmenu_payment.confirm_payment_from_provider()` is reduced to a single canonical overload: the 8-parameter version originally defined in `0027_create_payment_intent_rpc.sql`.
- The 9-parameter overload (added in `0063_patch_core_rpc_i18n_diagnostics.sql`, `p_locale` extra) is removed via `DROP FUNCTION` in a new forward migration.
- `p_locale` and a hypothetical `p_options jsonb` extension field are **not** introduced (Human decision, YAGNI — `600511_Overview.md` §0.5).

## §1 Allowed Files

Exactly one new file may be created. No existing file may be modified.

| File | Allowed scope |
|---|---|
| `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql` (new) | `DROP FUNCTION IF EXISTS catchmenu_payment.confirm_payment_from_provider(uuid, uuid, uuid, text, text, int, uuid, text, text);` plus a file header comment explaining the drop (purpose, background, what remains). No other statement. |

**Numbering note**: The original task text suggested `0151` as a placeholder ("또는 다음 빈 번호" — or the next free number). `0151` and `0152` are both already taken (`0151_create_check_kds_capacity_function.sql`, `0152_add_orders_pickup_ready_timing_columns.sql`, both confirmed live via `catchmenu_meta.migration_history` this turn) — the actual next free number is **`0153`**.

Allowed content inside `0153`:

```sql
-- 0153_drop_confirm_payment_provider_legacy_overload.sql
-- Purpose: Remove the dormant 9-param overload of
--          catchmenu_payment.confirm_payment_from_provider()
--          (added in 0063, p_locale extra), leaving the 8-param
--          original (0027) as the single canonical function.
--
-- Background:
--   Two live overloads caused every real caller (0038 Toss webhook,
--   0056 VAN integration) to fail with "function ... is not unique"
--   since both use identical 8 named arguments that PostgreSQL could
--   not resolve between the two candidates. Direct reproduction
--   further showed the 9-param overload independently crashes on
--   its own first write statement (phantom/missing columns), so
--   there is no working functionality being removed.
--
-- Human decision (2026-07-14): single canonical 8-param function,
-- no p_locale, no JSONB extension field (YAGNI).
--
-- Depends on:
--   - 0152_add_orders_pickup_ready_timing_columns.sql

drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);
```

## §2 Forbidden Files And Operations

| Forbidden item | Reason |
|---|---|
| `sql/migrations/0027_create_payment_intent_rpc.sql` | Original 8-param definition — already confirmed correct (`600512_Logic.md` §4). No edit needed or approved. |
| `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` | Real caller 1 — already uses the exact 8 named arguments matching the canonical signature (`600511_Overview.md` §1.1). No edit needed. |
| `sql/migrations/0056_create_van_integration_rpc.sql` | Real caller 2 — same as above, structurally identical call. No edit needed. |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | **File itself must not be modified.** The `confirm_payment_from_provider` definition inside it is not physically removed or edited — it becomes dead/superseded text once `0153`'s `DROP FUNCTION` runs, exactly as `600710`'s `place_takeout_order()` history and other prior workpackets in this series have treated historical migration files (append-only philosophy — see `000701` §24-adjacent precedent). |
| `mark_payment_uncertain()` (`0027`/`0063`) | Separate function, separate workpacket candidate (§4). |
| `authorize_kds_release()` (`0028`/`0063`) | Separate function, separate workpacket candidate (§4), structurally different from a simple `p_locale` addition. |
| `mark_no_show()` (`0050`/`0115`) | Discovered this turn to share the same overload-sprawl pattern — not this workpacket's scope (§4). |
| `get_did_display_state()` (`0043`/`0117`) | Same as above (§4). |
| Any other `sql/migrations/*.sql` file | Out of scope. |
| Flutter/runtime code | Out of scope. |
| Tools scripts | Out of scope. |

Implementation must not:

- Add `p_locale` or any new parameter to the surviving 8-param function.
- Add a `p_options jsonb` (or similarly named) extension field.
- Touch `payment_ledger`, `payment_intents`, `orders`, or any other table schema.
- Re-add, rename, or recreate any overload of `confirm_payment_from_provider()`.
- Modify `0063`'s file content in any way (including comments).

## §3 Required Behavior Preservation

The implementation must preserve:

- The existing 8-param `confirm_payment_from_provider()` signature and its full function body, byte-for-byte, exactly as defined in `0027`.
- `0038`/`0056`'s existing call sites — zero changes required or permitted.
- All existing `payment_ledger`/`payment_intents`/`kds_tickets`/`order_sessions` side effects performed by the 8-param function, unchanged.
- Patent 1 design invariant: `kds_release_authorized` stays `false` from this function; `authorize_kds_release()` remains a fully separate, later step (confirmed not called from within `confirm_payment_from_provider()`, `600511_Overview.md` §1.3).

## §4 Required New Behavior

The implementation must add:

- Exactly one live overload of `confirm_payment_from_provider()` after the migration runs (down from two).
- `0038`/`0056`'s existing 8-named-argument calls resolve unambiguously (no `"is not unique"` error).

## §5 Verification Requirements

Implementation must be verified against `600513_TestPlan.md`. Required verification groups:

1. Test A — post-drop overload count `= 1`, correct identity arguments.
2. Test B — `0038`/`0056`'s exact calling convention no longer ambiguous.
3. Test C — first-ever full E2E success run (`success: true`, `payment_ledger` row created).
4. Test D — `payment_ledger`/`payment_intents` field-level correctness, including `kds_release_authorized = false`.
5. Static boundary — only `0153` is new; `0027`/`0038`/`0056`/`0063` show zero diff.

## §6 Open Items Not Approved In This Contract

### §6.1 `mark_payment_uncertain()` / `authorize_kds_release()` — Separate Workpacket Candidate

Both confirmed to have zero live callers (`600511_Overview.md` §2). Same overload-sprawl root cause as `confirm_payment_from_provider()`, but out of scope here. When addressed:

- `mark_payment_uncertain()` is expected to follow the same resolution (drop the `0063` `p_locale`-added overload, keep the `0027` original) — it shares the exact "same pattern" structure already confirmed.
- `authorize_kds_release()` cannot receive the same mechanical fix — its two overloads differ in their 3rd required parameter name and type (`p_ledger_id` vs `p_order_id`), suggesting a deeper redesign rather than a simple i18n patch. Which overload (if either) is canonical needs its own investigation before any `DROP FUNCTION` is proposed.

This ChangeContract does not approve touching either function.

### §6.2 `mark_no_show()` / `get_did_display_state()` — Overload Sprawl, Separate Investigation Needed

Discovered during `600620_customer_handoff_contract_reconciliation`'s Contract Inventory (Track 1): the same "later migration adds a new overload instead of replacing the original" pattern also exists for:

- `mark_no_show()` — `0050`(original, `p_actor_type`) vs `0115`(re-defined, `p_actor_id`+`p_locale`).
- `get_did_display_state()` — `0043`(original, `p_did_id`) vs `0117`(re-defined, `p_device_id`).

Whether either pair produces an actual `"is not unique"` ambiguity in practice (i.e., whether any real caller uses a named-argument shape that both overloads could satisfy) has not been tested. This ChangeContract does not approve investigating or touching either function — flagged here only so the pattern's full extent is visible alongside this workpacket's fix.

### §6.3 `0063` File Content

`0063_patch_core_rpc_i18n_diagnostics.sql` is never edited by this or any future workpacket following this precedent — historical migration files remain append-only; superseding happens via later `DROP`/`CREATE OR REPLACE` in new files, not retroactive edits.

## §7 Risk

Risk level: MEDIUM.

Reasons:

- `confirm_payment_from_provider()` is on the real payment-confirmation path for Toss webhooks and VAN integration — a `DROP FUNCTION` mistake here would affect live payment processing once deployed.
- This is the first time the 8-param function will actually execute end-to-end in this project (Test C/D) — there is a small chance an undiscovered defect surfaces only under real execution, despite thorough static verification (`600512_Logic.md` §4).
- `DROP FUNCTION` is inherently less reversible in spirit than `CREATE OR REPLACE` (though trivially reversible by re-running `0063`'s original `CREATE OR REPLACE` if ever needed — the text is preserved, unedited, in that file).

Risk controls:

- Single new file, single statement (`DROP FUNCTION`) plus header comment only.
- Four-part verification (overload count, ambiguity resolution, E2E success, field-level correctness) before any ACCEPT.
- No existing file touched — full rollback is simply not applying `0153`.
- `0027`'s correctness was independently re-verified against live schema/constraints twice already (`600510`'s investigation, `600512_Logic.md` §4) before this contract was written.

## §8 Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve creating exactly one new file: sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql.
☑ I approve the DROP FUNCTION statement targeting the 9-param overload exactly as specified in §1.
☑ I acknowledge that mark_payment_uncertain(), authorize_kds_release(), mark_no_show(), and get_did_display_state() remain out of scope for this workpacket (§6).

## §9 Stage 4 Instruction If Approved

If all three Human approval boxes in §8 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.
