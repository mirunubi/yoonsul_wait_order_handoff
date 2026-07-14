# 600544_ChangeContract_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: ChangeContract
Stage: 3 (Human Approval Gate)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## Authority

- `600541_Overview_Mark_Payment_Uncertain_Overload.md`
- `600542_Logic_Mark_Payment_Uncertain_Overload.md`
- `600543_TestPlan_Mark_Payment_Uncertain_Overload.md`

## Final Decision To Approve

Drop the dormant `0063` 6-param overload of:

```text
catchmenu_payment.mark_payment_uncertain(uuid, uuid, uuid, text, text, text)
```

Keep the `0027` 5-param overload as the single canonical function:

```text
catchmenu_payment.mark_payment_uncertain(uuid, uuid, uuid, text, text)
```

This mirrors the already-accepted `600510_confirm_payment_from_provider_overload_ambiguity` structure:

- remove the later `p_locale` overload;
- keep the original canonical function;
- do not retrofit i18n/JSONB/options into the payment confirmation boundary in this workpacket.

## §1 Allowed Files

Implementation is allowed to create exactly one new forward migration file:

```text
sql/migrations/<next_free_number>_drop_mark_payment_uncertain_legacy_overload.sql
```

The exact migration number must be determined immediately before implementation by checking `sql/migrations/`.

Allowed SQL body:

```sql
drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);
```

Header comments may be added to the new migration file to state:

- Purpose: drop legacy 0063 `p_locale` overload.
- Background: 0063 6-param overload causes overload ambiguity and independently fails against live constraints.
- Depends on: current latest migration at implementation time.
- Creates/Changes: removes one function overload only.
- Non-goals: no change to 0027 body, no i18n retrofit, no dashboard fix.

## §2 Forbidden Files / Operations

Do not edit:

- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
- `sql/migrations/0070_create_flutter_bootstrap_rpc.sql`
- `sql/migrations/0073_final_verification.sql`
- `sql/migrations/0035_verify_schema.sql`
- `catchmenu_app/**`
- runtime code
- Flutter files
- existing payment provider functions other than the forward migration DROP target

Do not:

- change `chk_intent_status`;
- add `UNCERTAIN` to `payment_intents.intent_status`;
- modify `catchmenu_ledger.exceptions`;
- add or change `exception_code` logic in `0027`;
- add `p_locale` or `p_options jsonb`;
- modify any caller;
- modify `authorize_kds_release()`;
- modify `confirm_payment_from_provider()`;
- modify `mark_no_show()`;
- modify `get_did_display_state()`;
- stage or commit unless a later Human instruction explicitly authorizes it.

## §3 Required Implementation Procedure

1. Reconfirm this ChangeContract has Human Approval checked.
2. Reconfirm next available migration number.
3. Create one new migration file only.
4. Apply via:

```powershell
python tools/apply_migrations.py
```

5. Run `600543_TestPlan_Mark_Payment_Uncertain_Overload.md` §0–§6.
6. Do not edit `0027`, `0063`, or `0070` to make tests pass.
7. If the surviving 0027 function fails for a defect outside the allowed DROP scope, stop and report; do not expand scope.

## §4 Verification Requirements

Stage 5 must prove:

1. Overload count is exactly `1`.
2. Surviving signature is the 0027 5-param function.
3. Named-argument ambiguity error is gone.
4. A real dummy E2E execution of the surviving 0027 function succeeds under `BEGIN ... ROLLBACK`.
5. `0027` does not share the `0063` `exceptions.exception_code` NOT NULL omission.
6. Forbidden files are unchanged.
7. `git diff --check` passes.

## §5 Risk / Rollback Boundary

This migration removes a dormant overload that currently has:

- zero confirmed real callers;
- overload ambiguity impact on canonical calls;
- independent hard-fail behavior in the 0063 body:
  - `intent_status = 'UNCERTAIN'` violates `chk_intent_status`;
  - `exceptions.exception_code` is omitted despite NOT NULL.

Rollback, if ever required, would need a new forward migration that recreates the 6-param function. Do not restore it by editing old migrations in place.

## §6 Open Items Carried Forward

These are explicitly out of scope and must not be solved in this workpacket:

### §6(a) 0027 `PROCESSING` dashboard invisibility

The surviving 0027 function sets:

```text
payment_intents.intent_status = PROCESSING
```

`0070` dashboard logic searches for:

```text
intent_status = UNCERTAIN
```

This means the dashboard may not detect active payment uncertainty. This is a known carried-forward defect, not part of the overload cleanup.

### §6(b) 0027 i18n / diagnostic-log gap

The surviving 0027 function uses raw `jsonb_build_object()` response construction and does not call `catchmenu_common.log_diagnostic()` with CRITICAL recovery guidance.

This is carried forward because there is no confirmed real caller or screen exposure path today.

### §6(c) Real call chain not implemented

No actual app/runtime SQL caller currently triggers `mark_payment_uncertain()`. The trigger source could later be provider timeout handling, provider webhook uncertainty, or staff manual action, but that call chain is not implemented in this workpacket.

### §6(d) `authorize_kds_release()` separate workpacket

`authorize_kds_release()` has its own overload issue and is structurally different from this case. It must remain separate.

## §7 Human Approval

Human must check all boxes before Stage 4 implementation:

☑ I approve dropping only the 0063 6-param mark_payment_uncertain() overload by forward migration.
☑ I approve keeping the 0027 5-param mark_payment_uncertain() function as the single canonical function for this workpacket.
☑ I acknowledge that 0027 dashboard invisibility, i18n/diagnostic-log gaps, real call-chain absence, and authorize_kds_release() remain out of scope and are carried forward.

## Snapshot Decision

Awaiting Human Approval. No SQL, migration, runtime, or Flutter file is modified by this ChangeContract itself.

