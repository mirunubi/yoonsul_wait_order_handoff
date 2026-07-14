# 600602_NavigationMap_Waiting_Order_Session.md

Status: Active
Lifecycle: NavigationMap
Domain: Waiting / Order Session

## Workpacket Flow

| Workpacket | Scope | Local flow |
|---|---|---|
| `600610_takeout_session_type_fix/` | `ONLINE` → `TAKEOUT` session-type correction and `TAKEOUT` → `ORDERING` session-status mapping. | `600611_Overview.md` → `600612_Logic.md` → `600613_TestPlan.md` → `600614_ChangeContract.md` → `600615_Module.md` → `600616_Verification.md` → `600617_Audit.md` |
| `600620_customer_handoff_contract_reconciliation/` | Waiting/pre-order customer handoff contract reconciliation, including `kds_tickets` insert and waiting realtime state contract facts. | `600621_Overview.md` → `600622_Logic.md` → `600623_TestPlan.md` → `600624_ChangeContract.md` → `600625_Module.md` → `600626_Verification.md` → `600627_Audit.md` |

