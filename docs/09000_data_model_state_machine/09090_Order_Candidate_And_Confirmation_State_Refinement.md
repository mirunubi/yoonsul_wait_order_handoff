# 09090 Order Candidate And Confirmation State Refinement

## 1 Purpose

Customer-facing and store-facing states must not imply stronger confirmation than the system actually has.

This document refines the order handoff state model without creating implementation.

It extends `09020` and `09040` truth boundaries.
It does not define state machine code, enums, or integration runtime.

## 2 State Families

| state family | conceptual meaning |
| --- | --- |
| browsing | Customer explores menu without order intent. |
| cart / order candidate | Customer has draft order intent; not confirmed. |
| preorder request | Waiting or seated customer submits preorder intent. |
| staff review pending | Store staff has not yet reviewed or confirmed. |
| staff-confirmed operational order | Staff confirms operationally; not financial truth. |
| printer output pending | Print job queued or awaiting device readiness. |
| printer output sent | Print command dispatched; not POS sales creation. |
| POS API attempt pending | POS API call initiated; outcome unknown. |
| POS API success | POS API returned success per integration authority. |
| POS API failure | POS API returned failure or timeout. |
| POS-confirmed order | POS system confirms order per proper POS authority. |
| store POS payment pending | Payment expected at store POS; not paid. |
| platform payment future | Platform payment path; not default MVP. |
| manual POS input required | Staff must enter order manually in POS. |
| manual recovery required | Operational recovery needed; links to original event. |
| cancelled | Flow cancelled by customer or store policy. |
| expired | Session or intent expired without completion. |

## 3 Truth Rules

- order candidate is not confirmed order.
- preorder request is not paid order.
- staff confirmation is operational confirmation, not financial truth.
- printer output does not equal POS sales creation.
- POS API attempt does not equal POS success.
- POS-confirmed order requires proper POS authority.
- store POS payment pending does not equal paid.
- platform payment is not default MVP.
- manual recovery must link to original event.

## 4 UI / API / Admin Alignment

- Customer wording must follow `docs/13000_app_api_projection/13070_Customer_Surface_State_Wording_Matrix.md`.
- UI state wording must follow `docs/17000_ui_screen_composition/17060_UI_State_Wording_And_Empty_State_Guideline.md`.
- Operational monitoring and audit must follow `docs/07000_admin_console/07030_Admin_Operational_Monitoring_And_Recovery_Model.md` and `docs/07000_admin_console/07100_Admin_Audit_Review_And_Change_History_Model.md`.
- Integration truth separation must follow `docs/11000_integration_boundary/11010_POS_Payment_Printer_Integration_Boundary.md`.

## 4.1 Integration Boundary Cross-Reference

- POS API truth boundary is defined in `docs/11000_integration_boundary/11020_POS_API_Integration_Truth_Boundary.md`.
- Printer/Store Agent boundary is defined in `docs/11000_integration_boundary/11030_Printer_And_Store_Agent_Boundary.md`.
- Payment/financial truth boundary is defined in `docs/11000_integration_boundary/11040_Payment_And_Financial_Truth_Boundary.md`.
- Manual POS input/reconciliation boundary is defined in `docs/11000_integration_boundary/11050_Manual_POS_Input_And_Reconciliation_Boundary.md`.
- Failure/retry/recovery boundary is defined in `docs/11000_integration_boundary/11060_Integration_Failure_Retry_And_Recovery_Boundary.md`.

## 4.2 App/API Projection Cross-Reference

- App/API projection of order confirmation, integration status, recovery, and future states is further refined in `docs/13000_app_api_projection/13090_Surface_To_Authority_Projection_Model.md` through `docs/13000_app_api_projection/13130_Future_Surface_And_Api_Non_MVP_Boundary.md`.
- Projection does not approve implementation.

## 5 Non-Implementation Boundary

- no state machine code.
- no enum.
- no SQL.
- no trigger.
- no RPC.
- no payment implementation.
- no POS integration implementation.

## 6 Open Decisions

- whether staff-confirmed state is visible to customer.
- whether printer-sent state is customer-visible.
- whether manual POS input completed is staff-only.
- whether POS API success can be treated as confirmed order.
- whether payment status is separate state family.

## 7 Current Status

Status: active order candidate and confirmation state refinement. Not implementation approval.
