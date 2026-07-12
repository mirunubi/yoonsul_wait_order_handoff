# 004200_Readme_KDS_Operation_Payment_Recovery_Boundary.md

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

- This package depends on `docs/004000_store_runtime_pos_kds_operations/004000_Readme_Store_Runtime_POS_KDS_Operations.md/`.
- This package depends on `docs/004000_store_runtime_pos_kds_operations/004100_menu_availability_soldout_runtime/` when sold-out state or menu readiness affects recovery.
- This package inherits Foundation Security for audit/evidence, access control, data retention, and incident response.
- This package must not mutate payment truth directly unless the relevant payment authority policy allows it.

## 4 File List

| document | role |
| --- | --- |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004210_Policy_KDS_Station_Routing.md` | KDS station routing policy. |
| `04220_SOP_Kitchen_Display_Staff_Role_And_Training.md` (not yet implemented) | Kitchen display staff role and training SOP. |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004230_Boundary_KDS_Bridge_Vendor_Integration.md` | KDS bridge vendor integration boundary. |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004240_Policy_Manual_Kitchen_Recovery_And_Reconciliation.md` | Manual kitchen recovery and reconciliation policy. |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004250_Policy_Manual_Kitchen_Recovery_Evidence_Packet.md` | Manual kitchen recovery evidence packet policy. |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004260_Policy_POS_Payment_Webhook_And_Kitchen_Release_Boundary.md` | POS payment webhook and kitchen release boundary policy. |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004270_Policy_Payment_Failure_Timeout_Duplicate_And_Manual_Confirmation.md` | Payment failure, timeout, duplicate, and manual confirmation policy. |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004280_Policy_Customer_Display_Dynamic_QR_And_Payment_Status_UX.md` | Customer display dynamic QR and payment status UX policy. |
| `docs/004000_store_runtime_pos_kds_operations/004200_kds_operation_payment_recovery_boundary/004290_Policy_Store_Payment_Device_And_Counter_Bottleneck_Reduction.md` | Store payment device and counter bottleneck reduction policy. |
