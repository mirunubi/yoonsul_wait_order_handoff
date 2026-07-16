# 600602_NavigationMap_Waiting_Order_Session.md

Status: Active
Lifecycle: NavigationMap
Domain: Waiting / Order Session

## Workpacket Flow

| Workpacket | Scope | Local flow |
|---|---|---|
| `600610_takeout_session_type_fix/` | `ONLINE` → `TAKEOUT` session-type correction and `TAKEOUT` → `ORDERING` session-status mapping. | `600611_Overview.md` → `600612_Logic.md` → `600613_TestPlan.md` → `600614_ChangeContract.md` → `600615_Module.md` → `600616_Verification.md` → `600617_Audit.md` |
| `600620_customer_handoff_contract_reconciliation/` | Waiting/pre-order customer handoff contract reconciliation, including `kds_tickets` insert and waiting realtime state contract facts. | `600621_Overview.md` → `600622_Logic.md` → `600623_TestPlan.md` → `600624_ChangeContract.md` → `600625_Module.md` → `600626_Verification.md` → `600627_Audit.md` |
| `600630_mark_no_show_overload_and_redesign/` | Implements `0161_mark_no_show_overload_and_redesign.sql`: registers no-show error keys, adds `kds_tickets.hold_expires_at`, creates the shared `apply_no_show_transition()` core plus manual/automatic/KDS grace functions, drops the legacy `0050` `mark_no_show()` overload, and rewrites `0118` `WAITING_SESSION_EXPIRE` to call store-scoped batch functions instead of phantom-column inline updates. Stage 6 ACCEPT after Cursor + 안티 + Claude Code triple independent verification. | `600631_Overview_Mark_No_Show_Overload_And_Redesign.md` → `600632_Logic.md` → `600633_TestPlan.md` → `600634_ChangeContract.md` → `600635_Module.md` → `600636_Verification.md` → `600637_Audit.md` |
| `600640_call_waiting_customer_contract_recovery/` | Fix `catchmenu_pos.call_waiting_customer()`(`0115:419-599`) by replacing phantom `order_sessions` concepts (`called_at`/`table_number`/`call_count`/`pre_order_amount`) with `session_events`, request/response payload, and linked `orders.final_amount`. Implemented `0160_call_waiting_customer_contract_recovery.sql`: internal `_record_waiting_call()`, corrected `call_waiting_customer()`, new `call_next_waiting_customer()` with `SKIP LOCKED`, legacy `call_next_waiting()` DROP, and COMMENT-only deprecation of `no_show_auto_expire_minutes`. Stage 6 ACCEPT; note that `0115` source body remains stale and is carried as a source-sync Open Item. | `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` → `600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` → `600643_TestPlan.md` → `600644_ChangeContract.md` → `600645_Module.md` → `600646_Verification.md` → `600647_Audit.md` |
