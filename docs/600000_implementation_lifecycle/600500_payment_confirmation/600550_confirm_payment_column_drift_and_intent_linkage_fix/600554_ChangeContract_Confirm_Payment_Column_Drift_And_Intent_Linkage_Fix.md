# 600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix

## 0. Purpose

This ChangeContract locks the Stage 4 boundary for the confirmed Revision 2 / Option C+ fix to `confirm_payment()` payment-intent linkage and `payment_ledger` column drift.

The implementation must follow:

- `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`
- `600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`

The core decision is Option C+:

- add intent provenance to `payment_intents`
- introduce a shared intent resolver/creator helper
- make `0098 confirm_payment()` ledger insertion match the actual `payment_ledger` schema
- patch the manual and VAN paths using the same intent-linkage pattern
- pass the preauthorized Toss Payments intent only from `0103`

## 1. Allowed Files And Operations

### 1.1 `payment_intents` Schema Change

Allowed operation:

```sql
alter table catchmenu_payment.payment_intents
  add column intent_origin text not null,
  add column origin_reference jsonb;
```

The `intent_origin` constraint must allow exactly:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`
- `IMPORTED`

Implementation may use `add column if not exists` only if Stage 4 confirms that this is consistent with the current migration convention and does not mask an incompatible existing column.

No additional `payment_intents` columns are approved in this workpacket.

### 1.2 New Helper Function

Allowed operation:

Create:

```sql
catchmenu_payment.resolve_or_create_payment_intent()
```

The helper must generalize the `0142` `bind_toss_payment_intent()` pattern for:

- explicit preauthorized intent validation
- existing candidate reuse
- new candidate creation
- multiple-candidate conflict handling

The helper must support the approved `intent_origin` values required by this workpacket:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`

`IMPORTED` is reserved as an approved enum value but does not require a new caller in this workpacket.

### 1.3 `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`

Allowed function:

- `catchmenu_payment.confirm_payment()` only

Allowed changes:

- Add `p_intent_id default null`.
- Call or inline-use the new `resolve_or_create_payment_intent()` helper before writing to `payment_ledger`.
- Insert a `provider_raw_events` row inside the function when provider raw payload must be captured.
- Rewrite the `payment_ledger` insert to:
  - remove phantom columns:
    - `payment_method`
    - `provider_tx_id`
    - `fee_amount`
    - `provider_response`
  - add or use real columns:
    - `intent_id`
    - `ledger_entry_type`
    - `provider_response_id`
- Preserve unrelated behavior of `confirm_payment()`.
- Preserve the existing `release_kds_after_payment()` call chain except where the new ledger row id/intent linkage requires direct wiring.

Forbidden within this file:

- Do not modify unrelated functions except as strictly required by the approved `confirm_payment()` body replacement.
- Do not change `release_kds_after_payment()` in this workpacket unless `600552_Logic` explicitly requires a signature-compatible call adjustment for the new ledger shape.

### 1.4 `sql/migrations/0109_create_network_handoff_fallback_rpc.sql`

Allowed function/branch:

- `flush_offline_queue()` only
- `RECORD_MANUAL_PAYMENT` branch only

Allowed changes:

- Resolve or create a payment intent with:
  - `intent_origin = 'MANUAL_ENTRY'`
- Insert a provider raw event inline when required.
- Rewrite the relevant ledger insert to use the same real-column contract as `0098`.

Forbidden:

- Do not rewrite unrelated offline queue item types.
- Do not alter network handoff behavior outside `RECORD_MANUAL_PAYMENT`.

### 1.5 `sql/migrations/0130_create_van_handler_extension.sql`

Allowed function:

- `catchmenu_payment.record_van_transaction()` only

Allowed changes:

- Resolve or create a payment intent with:
  - `intent_origin = 'VAN_SYNTHESIZED'`
- Insert a provider raw event inline when required.
- Rewrite the relevant ledger insert to use the same real-column contract as `0098`.
- Remove any attempt to insert `tax_amount` into `payment_ledger`.
- Preserve `tax_amount` on `catchmenu_payment.van_transactions`.

Forbidden:

- Do not remove or rename `catchmenu_payment.van_transactions.tax_amount`.
- Do not alter unrelated VAN transaction semantics.

### 1.6 `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql`

Allowed change:

Add exactly one argument to the existing `confirm_payment()` call:

```sql
p_intent_id := v_request.payment_intent_id
```

Purpose:

- Preserve the already-bound Toss Payments preauthorized intent.
- Ensure the ledger row links to the same `payment_intents.id`.

Forbidden:

- Do not otherwise rewrite the Toss Payments pipeline.
- Do not change the `0142` binding trigger.

## 2. Forbidden Files And Operations

The following files must remain unchanged:

- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`
- `sql/migrations/0056_create_van_integration_rpc.sql`
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`
- `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql`
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`

Forbidden operations:

- Do not modify the `0142` trigger logic itself.
- Do not alter `confirm_payment_from_provider()` in `0027`.
- Do not add `p_intent_id` to `0102` or `0104`.
- Do not modify downstream `fee_amount` / `payment_method` readers in this workpacket.
- Do not modify `0111`, `0100`, `0120`, or `0084` as part of this workpacket.
- Do not redesign PG/VAN settlement, cash payment, KDS release, membership, inventory, or DID behavior.
- Do not remove or rewrite `provider_raw_events` table structure.
- Do not introduce a new provider event ingestion framework beyond the inline insert required by this design.

## 3. Required Implementation Constraints

### 3.1 Provider Raw Event Insert

Each modified function that needs a raw provider response must insert into `catchmenu_integrations.provider_raw_events` inline.

Minimum required fields:

- `tenant_id`
- `provider_type`
- `provider_code`
- `raw_payload`

The design relies on existing defaults for the remaining `not null` fields.

### 3.2 Ledger Insert Contract

Every modified `payment_ledger` insert must use only real live columns.

Required additions:

- `intent_id`
- `ledger_entry_type`
- `provider_response_id`

Required removals from ledger insert:

- `payment_method`
- `provider_tx_id`
- `fee_amount`
- `provider_response`

### 3.3 Intent Origin Assignment

The implementation must use the following origin mapping:

| Path | Required `intent_origin` |
|---|---|
| Toss Payments with `v_request.payment_intent_id` | `PREAUTHORIZED` |
| OKPOS through `confirm_payment()` | `POS_SYNTHESIZED` |
| Toss POS through `confirm_payment()` | `POS_SYNTHESIZED` |
| `0109` `RECORD_MANUAL_PAYMENT` | `MANUAL_ENTRY` |
| `0130` `record_van_transaction()` | `VAN_SYNTHESIZED` |

### 3.4 Live Database Replacement Requirement

If Stage 4 edits already-applied migration source files in place, it must follow the §24 Lightweight Track:

1. Modify source files.
2. Recalculate checksums with CRLF-to-LF normalization.
3. Update `catchmenu_meta.migration_history`.
4. Directly re-execute the changed live function definitions.
5. Confirm with `pg_get_functiondef()` that the live function bodies changed.

Checksum update alone is not sufficient.

If Stage 4 uses a new forward migration to apply the schema/helper/function definitions, the same live verification requirement still applies after `tools/apply_migrations.py`.

## 4. Open Items Carried Forward

The following items are explicitly not resolved by this ChangeContract and must be carried forward from `600552_Logic.md` §4:

(a) `confirm_payment_from_provider()` (`0027`) and `confirm_payment()` (`0098`) remain parallel payment-confirmation pipelines. This workpacket aligns `0098` to the live `payment_ledger` column contract and intent-linkage model; it does not unify both pipelines into one canonical payment-confirmation RPC.

(b) Downstream `fee_amount` removal impact remains uncorrected here. Known downstream readers in `0111`, `0100`, `0120`, and `0084` must be separately reviewed before any further deletion or compatibility decision.

(c) `payment_method` ownership remains a follow-up concern. The live `payment_intents.payment_method` column exists, but this workpacket does not decide whether all `payment_method` reads should move from ledger-level assumptions to intent-level reads.

(d) Provider raw event ingestion is implemented inline for this workpacket only. A larger shared ingestion abstraction is not designed here.

(e) `0109` manual payment handling is included only for the `RECORD_MANUAL_PAYMENT` branch and only to the extent required to create or resolve a `MANUAL_ENTRY` intent and write a valid ledger row.

(f) Legacy `604250~604256` material may be used as historical reference only if it does not override the confirmed `600551/600552` design. No legacy workpacket resurrection is authorized here.

(g) The exact parameter list, return shape, and error keys of `resolve_or_create_payment_intent()` must be implemented consistently with `600552_Logic` and verified by `600553_TestPlan`; any ambiguity must stop Stage 4 for human clarification.

(h) Adding `intent_origin` and `origin_reference` must not break existing `payment_intents` readers, including the `0142` binding flow. Compatibility must be verified, but `0142` itself must remain unchanged.

(i) `confirm_payment()` currently calls `notify_channel()` inside the same payment transaction. If notification delivery fails, for example because the PostgreSQL NOTIFY payload or channel exceeds runtime limits, the whole payment transaction can roll back after the ledger path has otherwise succeeded. This is a low-probability but high-impact risk. The approved implementation must not hide this with `exception when others then null`, because that creates a silent failure mode where payment succeeds but KDS/staff notification is lost without visibility. A separate follow-up workpacket should evaluate a Transactional Outbox pattern: record the payment ledger and notification event atomically, then deliver the notification from a separate worker.

## 5. Boundary Verification Required After Implementation

Stage 4 must report:

- full diff for all touched files
- checksum updates if §24 in-place edits are used
- live function re-execution logs
- `pg_get_functiondef()` verification for:
  - `confirm_payment()`
  - `resolve_or_create_payment_intent()`
  - `flush_offline_queue()` if modified in place
  - `record_van_transaction()` if modified in place
- `600553_TestPlan` results
- explicit zero-diff confirmation for forbidden files

## 6. Human Boundary Approval

Stage 4 implementation must not begin until all approval boxes below are checked by the human owner.

☑ I approve the payment_intents schema additions and the new resolve_or_create_payment_intent() helper. (2026-07-15)
☑ I approve the 0098, 0109, 0130, and one-line 0103 implementation scope exactly as bounded above. (2026-07-15)
☑ I approve the forbidden-file boundary and the carry-forward Open Items, including no changes to 0027, 0038, 0056, 0102, 0104, 0142, 0111, 0100, 0120, or 0084 in this workpacket. (2026-07-15)
