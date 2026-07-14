# 600602_NavigationMap_Waiting_Order_Session.md

Status: Active
Lifecycle: NavigationMap
Domain: Waiting / Order Session

## Workpacket Flow

| Workpacket | Scope | Local flow |
|---|---|---|
| `600460_takeout_session_type_fix/` | `ONLINE` → `TAKEOUT` session-type correction and `TAKEOUT` → `ORDERING` session-status mapping. | `600461_Overview.md` → `600462_Logic.md` → `600463_TestPlan.md` → `600464_ChangeContract.md` → `600465_Module.md` → `600466_Verification.md` → `600467_Audit.md` |
| `600490_customer_handoff_contract_reconciliation/` | Waiting/pre-order customer handoff contract reconciliation, including `kds_tickets` insert and waiting realtime state contract facts. | `600491_Overview.md` → `600492_Logic.md` → `600493_TestPlan.md` → `600494_ChangeContract.md` → `600495_Module.md` → `600496_Verification.md` → `600497_Audit.md` |

