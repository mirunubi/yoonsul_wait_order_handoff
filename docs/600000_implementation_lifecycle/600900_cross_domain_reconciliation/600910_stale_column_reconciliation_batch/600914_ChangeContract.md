# 600914_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-13
CHANGE_ID: `stale_column_reconciliation_batch`

## 1. Authority

This ChangeContract is a boundary contract for the already-confirmed design in:

- `600911_Overview.md`
- `600912_Logic.md`
- `600913_TestPlan.md`

No new design decision is introduced here.

## 2. Allowed Files

Only the following 10 files may be edited.

| File | Allowed correction |
|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `request_memo` -> `memo` in the confirmed `place_takeout_order()` / `track_takeout_order()` SQL column references (L796, L1007, L1142). Per Human decision (2026-07-11, Gemini input incorporated): rename the `place_takeout_order()` RPC parameter `p_request_memo` -> `p_memo` at L508 (declaration) and L805 (VALUES passthrough). Per A안 (Human decision 2026-07-11, fully applied 2026-07-13): also rename the `track_takeout_order()` response JSON output key at L1142 from `'request_memo'` to `'memo'`. |
| `sql/migrations/0084_create_reconciliation_advanced_rpc.sql` | `case_severity` -> `severity`; `'INVESTIGATING'` -> `'UNDER_INVESTIGATION'`; only the confirmed occurrences in `600912_Logic.md` §2.2/§2.3. |
| `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` | `case_severity` -> `severity` and `'INVESTIGATING'` -> `'UNDER_INVESTIGATION'` inside executable `catchmenu_common.health_check()` SQL. Additionally, per Human decision (2026-07-11): at L380, sync the Dart example's RPC parameter key `'p_request_memo'` -> `'p_memo'` to match `0081`'s renamed parameter. Do not change the Dart local variable name `requestMemo`. |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | `request_memo` -> `memo`; `case_severity` -> `severity`; `'INVESTIGATING'` -> `'UNDER_INVESTIGATION'` in the confirmed `get_kds_realtime_state()` / `get_staff_alert_feed()` contexts. Per A안 (Human decision 2026-07-11, fully applied 2026-07-13), rename the `get_kds_realtime_state()` response JSON output key at L448 from `'request_memo'` to `'memo'`. Preserve prior `600420` repairs and perform checksum refresh plus live direct re-execution. |
| `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql` | `request_memo` -> `memo` in `send_order_to_okpos()` SQL column references. |
| `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql` | `request_memo` -> `memo` in `send_order_to_toss_pos()` SQL column references. |
| `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` | `request_memo` -> `memo` only for the confirmed INSERT column at L860. Do not change L878 `->>'request_memo'` offline payload extraction in this batch. |
| `sql/migrations/0111_create_franchise_admin_rpc.sql` | `case_severity` -> `severity` in `get_franchise_settlement_report()` JSON/ORDER BY contexts. Do not touch `gap_amount`. |
| `sql/migrations/0120_create_reconciliation_pipeline.sql` | `case_severity` -> `severity` in the 5-parameter `get_reconciliation_report(...)` JSON/ORDER BY contexts. Do not touch `gap_amount`. |
| `sql/migrations/0133_create_final_validation_package.sql` | Source-text-only correction: `case_severity` -> `severity`; `'INVESTIGATING'` -> `'UNDER_INVESTIGATION'` in the phantom/no-op DDL block. Do not make the block executable. Do not drop/recreate any table. |

## 3. Explicitly Forbidden Files

The following files are out of scope and must not be edited:

- `sql/migrations/0015_create_payment_reconciliation.sql`
- `sql/migrations/0121_create_security_pipeline.sql`
- any SQL migration file not listed in §2
- any Flutter/runtime application code
- any documentation file outside this workpacket unless a later instruction explicitly authorizes it

## 4. Explicitly Forbidden Corrections / Topics

The following discovered stale or suspicious references are out of scope for this batch:

- `gap_amount`
- `layer_number`
- `amount_difference`
- `case_description`

Reason:

- `gap_amount` appears in `0111` / `0120`, but `600912_Logic.md` §5 classifies it as a separate follow-up issue.
- `layer_number`, `amount_difference`, and `case_description` appear in `0084`, but `600912_Logic.md` §5 classifies them as outside this batch.
- `0121_create_security_pipeline.sql` uses `security_threats.threat_status = 'INVESTIGATING'` in a separate table/domain and must not be treated as part of the `reconciliation_cases.case_status` correction.

## 5. Required Implementation Constraints

1. Do not redesign the correction list.
2. Do not add new columns.
3. Do not alter `0015_create_payment_reconciliation.sql`.
4. Do not alter `0121_create_security_pipeline.sql`.
5. Do not broaden the change from the three approved replacement families:
   - `request_memo` -> `memo`
   - `case_severity` -> `severity`
   - `'INVESTIGATING'` -> `'UNDER_INVESTIGATION'`
6. Preserve API/JSON output keys where `600912_Logic.md` says the output contract should remain stable, such as retained `case_severity` JSON keys. A안 exceptions: `0081`'s `track_takeout_order(...)` L1142 output key and `0099`'s `get_kds_realtime_state(...)` L448 output key are NOT preserved; both change `request_memo` -> `memo` (constraints 11 and 12 below).
7. Preserve the `0109` L878 offline payload extraction `->>'request_memo'` pending separate client/offline payload confirmation.
8. Preserve prior `0099` repairs from the `600420` track.
9. Treat `0133` as source-only phantom DDL correction; do not attempt runtime schema surgery.
10. For `0092` L380, keep the Dart example's RPC parameter key in sync with `0081`'s renamed `p_memo` parameter (`'p_request_memo'` -> `'p_memo'`); only the string key changes, not the Dart local variable name `requestMemo`.
11. For `0081` L1142 (`track_takeout_order(...)`), change the response JSON output key `'request_memo'` -> `'memo'` (A안, Human decision 2026-07-11, fully applied 2026-07-13).
12. For `0099` L448 (`get_kds_realtime_state(...)`), change the response JSON output key `'request_memo'` -> `'memo'` (A안, Human decision 2026-07-11, fully applied 2026-07-13). Keep prior `600420` repairs (`is_late`, `priority`, `kds_capacity_threshold_per_zone`) intact.

## 6. Required Verification Boundary

Verification must follow `600913_TestPlan.md`.

Special requirements:

- `0099_create_realtime_pipeline_rpc.sql` requires checksum recalculation and direct live function re-execution; checksum update alone is not sufficient.
- the remaining 8 executable SQL files follow the normal `tools/apply_migrations.py` flow.
- `0133_create_final_validation_package.sql` skips runtime execution validation because the corrected DDL is phantom/no-op after `0015`.

## 7. Open Items Copied From `600912_Logic.md` §5

1. `0133` phantom DDL handling is resolved by Human decision: include source correction in this batch, but do not attempt runtime execution validation.
2. `0109` L878 offline action payload extraction `->>'request_memo'` depends on the client/offline payload contract and remains unchanged pending separate confirmation.
3. `0084` L1285 was directly confirmed as `case_severity, layer_number,`; only `case_severity` is part of this batch.
4. `gap_amount`, `layer_number`, `amount_difference`, and `case_description` stale references are confirmed out of scope and deferred to a separate follow-up.
5. `0121_create_security_pipeline.sql` / `security_threats.threat_status = 'INVESTIGATING'` is a separate table/domain and is not part of this correction batch.
6. `0081`'s `place_takeout_order(...)` RPC parameter name (`p_request_memo`) is resolved by Human decision (2026-07-11, Gemini input incorporated): rename to `p_memo` at L508/L805, in addition to the `request_memo` -> `memo` column change already in scope (§2). `0092` L380's Dart example is synchronized accordingly. This does not add new occurrences beyond the already-counted 5 for `0081`; it corrects an earlier scope statement that only described the column-name change.
7. A안 fully applied (2026-07-13): `0081` `track_takeout_order(...)` L1142 response JSON output key `request_memo` -> `memo`, and `0099` `get_kds_realtime_state(...)` L448 response JSON output key `request_memo` -> `memo` (Human decision, 2026-07-11; §5 constraints 11 and 12). A repo-wide search (`catchmenu_app/lib`, `sql/`, `supabase/`) previously found no consumer of the `0081` response key; `0099` is now aligned by the same A안 system-wide terminology unification.

## 8. Human Boundary Approval

☑ Approved — proceed to Stage 4 (Codex implementation within the file boundary above) (승인일자: 2026-07-11)
- [ ] Approved with modifications — see notes: ______________________________
- [ ] Not approved — blocked pending: ______________________________

Until one of the approval checkboxes is explicitly checked by a Human, no SQL file may be edited under this ChangeContract.

**범위 정합화 기록(2026-07-13)**: A안 Human 결정(2026-07-11)을 완전 적용하여 `0081` `track_takeout_order()` L1142와 `0099` `get_kds_realtime_state()` L448의 응답 JSON 출력 키를 모두 `request_memo`에서 `memo`로 통일한다. 이에 따라 과거의 "출력 키 유지" 문구 및 "0099는 request_memo 유지" 문구는 폐기된다.
