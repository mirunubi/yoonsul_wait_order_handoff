# 600614_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`takeout_session_type_fix`

## 0. Authority

This ChangeContract is based on:

- `600611_Overview.md`
- `600612_Logic.md`
- `600613_TestPlan.md`

The accepted design is not reopened here.

Confirmed six corrections:

1. `0081` L826: `session_type` literal changes from `'ONLINE'` to `'TAKEOUT'`.
2. `0063` L46: validation array changes from allowing `'ONLINE'` to allowing `'TAKEOUT'`.
3. `0063` L143-148: add `when 'TAKEOUT' then 'ORDERING'`.
4. `0063` L173-178: add `when 'TAKEOUT' then 'ORDERING'`.
5. `0063` L202-206: add `when 'TAKEOUT' then 'ORDERING'`; do not add `DELIVERY`.
6. `0063` L244-249: add `when 'TAKEOUT' then 'ORDERING'`.

Reference value:

- `0025_create_session_rpc.sql` maps `TAKEOUT -> ORDERING`.
- `0025_create_session_rpc.sql` is the reference only and must not be modified.

## 1. Allowed Files

Exactly two migration source files may be modified:

| File | Allowed scope |
|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `catchmenu_store.place_takeout_order()` function body, L826 `order_sessions.session_type` literal only |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | `catchmenu_pos.create_order_session()` second overload body only, six specified TAKEOUT/ONLINE correction points |

## 2. Allowed Changes In `0081`

Allowed change:

```sql
-- Before
'ONLINE', 'ORDER_CONFIRMED',

-- After
'TAKEOUT', 'ORDER_CONFIRMED',
```

Rules:

- Change only the `session_type` literal in the `order_sessions` insert inside `place_takeout_order()`.
- Preserve `session_status = 'ORDER_CONFIRMED'`.
- Preserve the function signature.
- Preserve all customer, coupon, point, order, payment, KDS, ledger, notification, and response logic.

## 3. Allowed Changes In `0063`

Target function:

- `catchmenu_pos.create_order_session()` second overload from `0063_patch_core_rpc_i18n_diagnostics.sql`.
- This is the overload with parameters including `p_queue_position` and `p_pre_order_expires_at`.

### 3.1 Validation Array

Allowed change:

```sql
-- Before
'KIOSK', 'DELIVERY', 'ONLINE'

-- After
'KIOSK', 'DELIVERY', 'TAKEOUT'
```

Rules:

- Replace `ONLINE` with `TAKEOUT`.
- Preserve existing allowed values other than this one replacement.
- Do not add new session types.
- Do not remove `DELIVERY`.

### 3.2 Status/State Mapping Blocks

Allowed addition in each of the four approved blocks:

```sql
when 'TAKEOUT' then 'ORDERING'
```

Target blocks:

| Line range from design | Semantic target | Allowed change |
|---|---|---|
| L143-148 | `order_sessions.session_status` | Add `TAKEOUT -> ORDERING` |
| L173-178 | `session_events.to_status` | Add `TAKEOUT -> ORDERING` |
| L202-206 | `catchmenu_ledger.events.to_state` | Add `TAKEOUT -> ORDERING` only; do not add `DELIVERY` |
| L244-249 | RPC return `data.session_status` | Add `TAKEOUT -> ORDERING` |

Rules:

- Use the same mapping as `0025` L71: `TAKEOUT -> ORDERING`.
- Preserve `WALK_IN` mapping exactly as it currently exists in `0063`.
- Preserve `KIOSK` mapping exactly as it currently exists.
- Preserve `DELIVERY` mapping where it already exists.
- Do not add `DELIVERY` to L202-206 in this workpacket.
- Preserve `else 'WAITING'`.

## 4. Forbidden Files And Operations

The following are explicitly forbidden:

| Forbidden item | Reason |
|---|---|
| `sql/migrations/0025_create_session_rpc.sql` | Reference baseline only; do not modify |
| Any `0063` overload other than the second `create_order_session()` overload | Out of scope |
| Any `0063` function other than `create_order_session()` | Out of scope |
| Adding `DELIVERY -> ORDER_CONFIRMED` to `0063` L202-206 | Known separate defect, not approved here |
| Changing `WALK_IN -> ORDERING` in `0063` | Known separate mismatch against `0025`, not approved here |
| Any `point_ledger` fix | Separate downstream blocker candidate |
| Any coupon or `discount_pct` fix | Separate downstream blocker candidate |
| Any Flutter/runtime code | Out of scope |
| Any schema/table/constraint rewrite unrelated to this literal correction | Out of scope |
| Any tools script | Out of scope |
| Any docs outside the current workpacket lifecycle unless explicitly requested later | Out of scope |

Implementation must not:

- Convert this into a broader session-state reconciliation.
- Normalize all `create_order_session()` overloads.
- Change `session_status = 'ORDER_CONFIRMED'` in `0081`.
- Change KDS/payment behavior.
- Change payload keys.
- Add compatibility aliases for `ONLINE`.

## 5. Required Behavior Preservation

The implementation must preserve:

- Existing function signatures for `place_takeout_order()` and `create_order_session()`.
- Existing return payload structure.
- Existing `ORDER_CONFIRMED` status for the `place_takeout_order()` session insert.
- Existing `0063` behavior for `WALK_IN`, `WAITING`, `PRE_ORDER`, `KIOSK`, and `DELIVERY`, except where `TAKEOUT` is explicitly added.
- Existing validation error behavior for unsupported session types.
- Existing downstream point/coupon/payment/KDS behavior.

## 6. Required New Behavior

After implementation:

- `place_takeout_order()` must insert `session_type = 'TAKEOUT'` instead of `ONLINE`.
- The second `0063` `create_order_session()` overload must allow `p_session_type = 'TAKEOUT'`.
- That overload must map `TAKEOUT` to `ORDERING` consistently in:
  - `order_sessions.session_status`
  - `session_events.to_status`
  - `catchmenu_ledger.events.to_state`
  - RPC response `data.session_status`
- That overload must reject `p_session_type = 'ONLINE'` through its own validation logic.

## 7. Verification Requirements

Implementation must be verified against `600613_TestPlan.md`.

Required verification groups:

1. `place_takeout_order()` reaches past the former `chk_session_type` failure.
2. `create_order_session()` second overload accepts `TAKEOUT`.
3. `TAKEOUT` maps to `ORDERING` in all four approved outputs.
4. `ONLINE` is rejected by function-level validation.
5. Out-of-scope `DELIVERY` and `WALK_IN` issues remain untouched.
6. Static diff boundary confirms only the approved six correction points changed.
7. `git diff --check` passes.

## 8. Open Items Not Approved In This Contract

### 8.1 `0063` L202-206 Missing `DELIVERY` Branch

The ledger-event `to_state` mapping block at `0063` L202-206 does not include `DELIVERY -> ORDER_CONFIRMED`, unlike other `0063` status mapping blocks.

This is a separate follow-up workpacket candidate.

This ChangeContract does not approve:

- adding `DELIVERY` to L202-206,
- changing delivery behavior,
- broadening the status mapping fix beyond TAKEOUT.

### 8.2 `WALK_IN` Mapping Mismatch Between `0025` And `0063`

`0025_create_session_rpc.sql` maps `WALK_IN -> SEATED`, while `0063_patch_core_rpc_i18n_diagnostics.sql` maps `WALK_IN -> ORDERING`.

This is a separate overload-alignment candidate.

This ChangeContract does not approve:

- changing `0063` `WALK_IN` mapping,
- changing `0025`,
- redefining seated/order lifecycle semantics.

### 8.3 Downstream Point/Coupon Defects

Known downstream point ledger and `discount_pct`/coupon findings remain outside this contract.

This ChangeContract does not approve:

- point ledger fixes,
- coupon schema changes,
- `discount_pct` changes,
- coupon discount policy rewrites.

## 9. Risk

Risk level: HIGH.

Reasons:

- `place_takeout_order()` is a customer-facing order RPC.
- `create_order_session()` affects POS session creation and audit/event evidence.
- The target files are already-applied migration files, so later implementation will likely require checksum and live replay discipline.
- Several adjacent defects are known but intentionally excluded, increasing the risk of accidental scope creep.

Risk controls:

- Six explicit correction points only.
- Two-file boundary.
- No signature changes.
- No schema changes.
- Explicit out-of-scope list for `DELIVERY`, `WALK_IN`, point ledger, and coupon defects.
- Rollback-wrapped verification.

## 10. Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve modifying sql/migrations/0081_create_customer_app_rpc.sql only within catchmenu_store.place_takeout_order() L826.
☑ I approve modifying sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql only within the second catchmenu_pos.create_order_session() overload at the six specified correction points.
☑ I acknowledge that DELIVERY, WALK_IN, point ledger, and discount_pct findings remain out of scope for this workpacket.

## 11. Stage 4 Instruction If Approved

If all three Human approval boxes in §10 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.

