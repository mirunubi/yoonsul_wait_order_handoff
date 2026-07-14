# 600824_ChangeContract_Did_Display_State_Overload.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude chat role)
Owner: Human
Last Updated: 2026-07-14

## Change ID

`did_display_state_overload_and_legacy_defect`

## 0. Authority

This ChangeContract is based on the finalized design in:

- `600821_Overview_Did_Display_State_Overload.md`
- `600822_Logic_Did_Display_State_Overload.md`
- `600823_TestPlan_Did_Display_State_Overload.md`

Final design:

- `catchmenu_store.get_did_display_state()` must have a single canonical live overload.
- The legacy 0043 3-param overload using `p_device_id` must be dropped.
- The 0117 4-param overload using `p_did_id` and `p_locale` remains canonical.

## 1. Allowed Files

Exactly one new forward migration is allowed:

- `sql/migrations/0154_drop_get_did_display_state_legacy_overload.sql`

If `0154` is already occupied at implementation time, implementation must stop and report the next-number conflict. Do not silently choose another number without explicit confirmation.

## 2. Required Migration Content

The new migration may contain:

1. Header comments documenting:
   - Purpose
   - Background
   - Human decision
   - Depends on
   - Creates/Changes
   - Explicit scope exclusions
2. Exactly one executable SQL statement:

```sql
drop function if exists catchmenu_store.get_did_display_state(
  uuid, uuid, uuid
);
```

No other executable SQL statement is approved.

## 3. Forbidden Files

The following files must not be edited:

- `sql/migrations/0043_create_did_display_rpc.sql`
- `sql/migrations/0117_create_did_pipeline_rpc.sql`
- Any existing migration file other than the new forward migration.
- Any Dart/Flutter file.
- Any runtime application code.
- Any 900-series document.
- Any unrelated 600400 workpacket document.

## 4. Forbidden Operations

Do not:

- Modify the 0043 source file in place.
- Modify the 0117 source file in place.
- Rewrite `bootstrap_did_app()`.
- Add `p_device_id` support to the 0117 function.
- Add a new replacement store-level operational summary function.
- Repair the 0043 nested aggregate bug.
- Create a compatibility wrapper with the same 3-param signature.
- Touch `mark_payment_uncertain()`.
- Touch `authorize_kds_release()`.
- Touch `mark_no_show()`.
- Touch DID display queue schema.
- Touch KDS schema.
- Touch payment schema.
- Stage or commit without explicit Human instruction.

## 5. Verification Requirements

Implementation must run the checks defined in `600823_TestPlan_Did_Display_State_Overload.md`:

1. Confirm pre-implementation overload state if not already captured.
2. Apply the forward migration through the project migration pipeline.
3. Confirm post-DROP overload count is exactly 1.
4. Confirm remaining signature is:

```text
p_tenant_id uuid, p_store_id uuid, p_did_id uuid, p_locale text
```

5. Confirm `bootstrap_did_app()`-style named call works without ambiguity.
6. Confirm positional 3-arg call no longer produces `"is not unique"` and no longer reaches the 0043 nested aggregate defect.
7. Confirm `0043` and `0117` have no source diff.
8. Confirm only the new migration file is changed under `sql/migrations` for this workpacket.

## 6. Open Items

These are explicitly out of scope and must remain separate workpacket candidates:

- `mark_payment_uncertain()` overload cleanup.
- `authorize_kds_release()` overload cleanup.
- `mark_no_show()` overload cleanup.
- Any future redesign of the old 0043 store-level operational summary concept.
- Any future replacement function for 0043 under a new, non-conflicting function name.

## 7. Human Boundary Approval

Implementation may proceed only after Human checks all three boxes:

- [ ] I approve the single-file forward migration boundary.
- [ ] I approve dropping only the legacy 3-param `get_did_display_state(uuid, uuid, uuid)` overload.
- [ ] I confirm that `0043`, `0117`, `bootstrap_did_app()`, and the other overload families are out of scope.

## 8. Expected Implementation Result

Expected result after approved implementation:

```text
IMPLEMENTATION_ALLOWED_FOR_0154_FORWARD_DROP_OF_GET_DID_DISPLAY_STATE_LEGACY_3_PARAM_OVERLOAD_ONLY
```
