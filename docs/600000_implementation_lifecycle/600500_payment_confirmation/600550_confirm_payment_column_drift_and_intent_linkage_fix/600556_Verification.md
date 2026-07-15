# 600556_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Cursor + Codex + Antigravity
Date: 2026-07-15

## Verification Result

Final result: **PASS with carried-forward Open Items.**

The implemented scope matches `600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`: `0158` is applied, the live schema contains the new intent provenance columns, `confirm_payment()` has the new `p_intent_id` parameter, and the live function body contains the resolver / provider raw event / live ledger-column changes.

## 1. Local Migration State

```text
filename                                  | success | checksum
------------------------------------------+---------+------------------------------------------------------------------
0158_confirm_payment_intent_linkage_fix.sql | t       | 25de8e5a11717fc19db05ef3c0758ce8c9839f319a6ce7e95c17413282bacf34
```

## 2. Schema Verification

`catchmenu_payment.payment_intents` contains the two approved columns:

```text
column_name      | data_type | is_nullable | column_default
-----------------+-----------+-------------+-----------------------
intent_origin    | text      | NO          | 'PREAUTHORIZED'::text
origin_reference | jsonb     | YES         |
```

The approved values are enforced by `chk_intent_origin` in `0158`:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`
- `IMPORTED`

## 3. Live Function Signature Verification

Live `pg_proc` confirms the expected signatures:

```text
confirm_payment:
p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_provider_type text,
p_provider_approval_number text, p_provider_tx_id text,
p_approved_amount integer, p_payment_method text,
p_provider_response jsonb, p_actor_type text, p_actor_id uuid,
p_locale text, p_correlation_id text, p_intent_id uuid

resolve_or_create_payment_intent:
p_tenant_id uuid, p_store_id uuid, p_order_id uuid,
p_requested_amount integer, p_payment_method text,
p_payment_channel text, p_provider_type text, p_intent_origin text,
p_origin_reference jsonb, p_intent_id uuid, p_session_id uuid,
p_locale text
```

## 4. Live Function Body Verification

`pg_get_functiondef()` for `catchmenu_payment.confirm_payment()` confirms:

| Check | Result |
|---|---|
| Calls `resolve_or_create_payment_intent()` | PASS |
| Inserts into `provider_raw_events` | PASS |
| Uses `provider_response_id` | PASS |
| Uses `ledger_entry_type` | PASS |
| Does not contain `exception when others then null` around `notify_channel()` | PASS |

The final `notify_channel()` state was independently rechecked after the Human decision to revert the best-effort wrapper:

```text
has_bare_notify | has_exception_when_others
t               | f
```

## 5. Filename Correction Verification

During Stage 2/3 review, four migration filenames in the draft TestPlan / ChangeContract were found to be stale or imprecise and were corrected before implementation:

| Draft / stale name | Correct file used in final documents |
|---|---|
| `0038_create_pos_payment_rpc.sql` | `0038_create_toss_webhook_processor_rpc.sql` |
| `0056_create_toss_payments_rpc.sql` | `0056_create_van_integration_rpc.sql` |
| `0102_create_okpos_pipeline_rpc.sql` | `0102_create_okpos_integration_pipeline_rpc.sql` |
| `0142_create_toss_payment_intent_binding_rpc.sql` | `0142_patch_toss_mvp_payment_intent_binding.sql` |

This correction affected documentation and boundary verification only; it did not authorize edits to those four files.

## 6. Triple Verification Consolidation

| Verifier | Coverage | Result |
|---|---|---|
| Cursor | Large-scope source/diff review, filename correction, boundary drift scan, and follow-up issue discovery. | PASS with notes; flagged the filename errors and the need to classify side changes rather than silently accepting them. |
| Codex | Implementation plus live database checks: migration history, schema columns, function signatures, `pg_get_functiondef()`, checksum update, and final `notify_channel()` wrapper reversal. | PASS; `0158` applied and live functions reflect intended changes. |
| Antigravity | Independent review of column-contract drift and side-effect classification, including `orders.paid_at` and notification behavior. | PASS with Open Items; no blocking boundary breach after wrapper reversal. |

The three reviews converge on the same final state: implementation accepted, but residual risks must be carried forward.

## 7. Side-Change Review: Seven Items Classified

The implementation was reviewed for changes adjacent to the main `payment_ledger` INSERT fix. The final classification is:

| # | Item | Classification | Result |
|---|---|---|---|
| 1 | `provider_raw_events` inline insert in `0098` | Necessary / approved | Required because `0098` had no caller-side raw-event insert comparable to `0038` -> `0027`. |
| 2 | `provider_raw_events` inline insert in `0109` | Necessary / approved | Required for the `RECORD_MANUAL_PAYMENT` branch to populate `provider_response_id`. |
| 3 | `provider_raw_events` inline insert in `0130` | Necessary / approved | Required because `record_van_transaction()` directly creates the ledger row and previously had no provider raw event id. |
| 4 | `p_intent_id` added only to the `0103` Toss Payments call | Necessary / approved | `0142` already binds `payment_intent_id`; `0103` needed to pass it through. `0102` and `0104` remain unchanged. |
| 5 | `orders.paid_at` replaced with `orders.confirmed_at` inside `confirm_payment()` | Not damage, but newly exposed broader defect | The replacement was required for `confirm_payment()` because `orders.paid_at` is a phantom column. Whether other functions still reference `orders.paid_at` is unverified and carried forward as a new Open Item. |
| 6 | `notify_channel()` best-effort wrapper (`exception when others then null`) | Unnecessary / reverted | Reverted by Human decision. Final live body uses bare `perform catchmenu_common.notify_channel(...)`; no silent notification failure mode remains in this workpacket. |
| 7 | Remaining downstream `fee_amount` / `payment_method` readers | Unrelated / deferred | Not fixed here by design. `0111`, `0100`, `0120`, and `0084` remain separate follow-up candidates. |

## 8. Boundary Verification

No edits are authorized or recorded for the forbidden reference files:

- `0027_create_payment_intent_rpc.sql`
- `0038_create_toss_webhook_processor_rpc.sql`
- `0056_create_van_integration_rpc.sql`
- `0102_create_okpos_integration_pipeline_rpc.sql`
- `0104_create_toss_pos_pipeline_rpc.sql`
- `0142_patch_toss_mvp_payment_intent_binding.sql`

`0142` remains a reference pattern only; its trigger logic was not modified.

## 9. `git diff --check`

Final whitespace check after the `notify_channel()` wrapper reversal:

```text
git diff --check
exit 0
```

Git reported existing LF/CRLF warnings for unrelated working-tree files, but no whitespace errors.

## Conclusion

The implemented workpacket satisfies the approved Stage 4 boundary and the live database reflects the intended schema/function changes. Verification passes, with Open Items explicitly carried forward to `600557_Audit.md`.

