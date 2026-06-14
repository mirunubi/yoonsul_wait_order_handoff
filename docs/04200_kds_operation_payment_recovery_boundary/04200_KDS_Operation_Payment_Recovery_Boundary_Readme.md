# 04200_KDS_Operation_Payment_Recovery_Boundary_Readme

## 1 Purpose

This folder defines the KDS Operation, Payment Recovery, and Recovery Boundary package for CatchMenu / Wait Order Handoff.

It frames how kitchen operation, payment uncertainty, degraded operation, manual fallback, operational evidence, kitchen/payment mismatch handling, customer-safe recovery state, and post-failure closure are governed without turning this package into direct payment truth authority.

## 2 Scope

- KDS station routing and kitchen display staff operation.
- KDS bridge and vendor integration boundaries.
- Manual kitchen recovery and reconciliation.
- Manual kitchen recovery evidence packets.
- POS payment webhook and kitchen release boundaries.
- Payment failure, timeout, duplicate, and manual confirmation handling.
- Customer display dynamic QR and payment status UX.
- Store payment device and counter bottleneck reduction.

## 3 Relationship Notes

- This package depends on `docs/04000_kds_integration_kitchen_continuity/`.
- This package depends on `docs/04100_menu_availability_soldout_runtime/` when sold-out state or menu readiness affects recovery.
- This package inherits Foundation Security for audit/evidence, access control, data retention, and incident response.
- This package must not mutate payment truth directly unless the relevant payment authority policy allows it.

## 4 File List

| document | role |
| --- | --- |
| `04210_KDS_Station_Routing_Policy.md` | KDS station routing policy. |
| `04220_Kitchen_Display_Staff_Role_And_Training_SOP.md` | Kitchen display staff role and training SOP. |
| `04230_KDS_Bridge_Vendor_Integration_Boundary.md` | KDS bridge vendor integration boundary. |
| `04240_Manual_Kitchen_Recovery_And_Reconciliation_Policy.md` | Manual kitchen recovery and reconciliation policy. |
| `04250_Manual_Kitchen_Recovery_Evidence_Packet_Policy.md` | Manual kitchen recovery evidence packet policy. |
| `04260_POS_Payment_Webhook_And_Kitchen_Release_Boundary_Policy.md` | POS payment webhook and kitchen release boundary policy. |
| `04270_Payment_Failure_Timeout_Duplicate_And_Manual_Confirmation_Policy.md` | Payment failure, timeout, duplicate, and manual confirmation policy. |
| `04280_Customer_Display_Dynamic_QR_And_Payment_Status_UX_Policy.md` | Customer display dynamic QR and payment status UX policy. |
| `04290_Store_Payment_Device_And_Counter_Bottleneck_Reduction_Policy.md` | Store payment device and counter bottleneck reduction policy. |
