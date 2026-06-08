# 11030 Printer And Store Agent Boundary

## 1 Purpose

Store Agent and printer output may help deliver order information to store/staff.

Printer output must not be confused with POS order creation or sales creation.

This document defines boundary only and does not create Store Agent/printer implementation.

This document is boundary governance only.
It does not approve printer drivers, local server code, or print template runtime.

## 2 Concepts

| concept | meaning |
| --- | --- |
| Store Agent | Local or edge agent that bridges store devices and handoff runtime. |
| Local Agent Server | On-premise or store-local service hosting agent capabilities. |
| printer gateway | Routing layer between handoff runtime and printer devices. |
| network printer | IP/network-connected printer candidate. |
| Bluetooth/USB printer | Direct-attached printer candidate. |
| print ticket candidate | Order ticket prepared for print dispatch. |
| print attempt | Print command initiated. |
| print success | Printer acknowledges successful output. |
| print failure | Printer unavailable, timeout, or error. |
| reprint/retry | Repeated print attempt preserving audit lineage. |
| duplicate print risk | Risk of multiple tickets for same order candidate. |

## 3 Truth Rules

- printer output does not equal POS sales creation.
- print success does not equal customer paid.
- print success does not equal POS-confirmed order.
- reprint does not equal duplicate confirmed order.
- Store Agent visibility does not equal POS authority.
- Store Agent failure does not erase original order candidate.
- printer retry must preserve audit lineage.
- staff review remains required unless proper authority exists.

## 4 Non-Implementation Boundary

- no printer driver.
- no Store Agent code.
- no local server implementation.
- no network discovery.
- no Bluetooth/USB integration.
- no print template runtime.
- no automatic POS update.

## 5 Cross-References

- `docs/11000_integration_boundary/11010_POS_Payment_Printer_Integration_Boundary.md`
- `docs/09000_data_model_state_machine/09090_Order_Candidate_And_Confirmation_State_Refinement.md`
- `docs/07000_admin_console/07030_Admin_Operational_Monitoring_And_Recovery_Model.md`

## 6 Open Decisions

- whether Store Agent is MVP.
- supported printer types.
- ticket format.
- duplicate print prevention.
- offline mode.
- retry owner.
- manual fallback process.

## 7 Current Status

Status: active printer and Store Agent boundary. Not implementation approval.
