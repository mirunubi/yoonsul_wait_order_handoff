# 601411 Register — Stage 1 File Inventory (Customer Handoff)

- Program: `601400_fable_design_integrity_inspection`
- Domain: `domain_01_customer_handoff`
- Scope: waiting → call → pre-order → payment → KDS → DID → handoff
- Method: Eyes Only — factual inventory per operational annex §6.1
- Created: 2026-07-19
- Full machine-readable inventory: [601411_Inventory_Customer_Handoff.ndjson](601411_Inventory_Customer_Handoff.ndjson) (495 records)

## Summary

- Total files: **495**
- Total bytes: **7,770,687** (~7.41 MiB)
- Markdown: 336 files
- SQL: 153 files
- JSON in scoped paths: 0 files

## Count by source area

| Area | Files |
|---|---:|
| `sql_migrations` | 147 |
| `700000_runtime_flow` | 81 |
| `600500_payment` | 50 |
| `600600_waiting` | 46 |
| `005000_customer_handoff` | 40 |
| `600400_kds` | 37 |
| `900000_patent` | 33 |
| `600200_flutter` | 19 |
| `other` | 16 |
| `sql_scratch_fable` | 11 |
| `600800_did` | 10 |
| `catchmenu_app` | 5 |

## Full inventory table (495 rows)

| Path | Bytes | Doc# | H1 | Type | Workpacket | Status tag |
|---|---:|---|---|---|---|---|
| `catchmenu_app/lib/features/kds/README.md` | 753 | — | features/kds — KDS 화면 (Scope C) | md | — | current |
| `catchmenu_app/lib/features/payment/README.md` | 808 | — | features/payment — 결제 (Scope A: 고객 앱) | md | — | current |
| `catchmenu_app/lib/features/waiting/README.md` | 778 | — | features/waiting — 대기 관리 (Scope A: 고객 앱) | md | — | current |
| `catchmenu_app/lib/features/waiting/screens/waiting_register_screen.dart` | 7741 | — | — | dart | — | current |
| `catchmenu_app/lib/features/waiting/screens/waiting_status_screen.dart` | 2082 | — | — | dart | — | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005000_Readme_Customer_Handoff_And_Implementation_Readiness.md` | 1644 | 005000 | 005000_Readme_Customer_Handoff_And_Implementation_Readiness.md | Readme | 005000_customer_handoff_and_implementation_readiness | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005010_Readme_Customer_Handoff_Flow.md` | 4635 | 005010 | 005010_Readme_Customer_Handoff_Flow.md | Readme | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005011_WorkPackage_Store_Runtime_Pilot_Readiness_Store_Rollout_Closeout_Expansion_Gate_And_Operational_Acceptance.md` | 18154 | 005011 | 005011_WorkPackage_Store_Runtime_Pilot_Readiness_Store_Rollout_Closeout_Expansion_Gate_And_Operational_Acceptance.md | WorkPackage | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005012_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary.md` | 16450 | 005012 | 005012_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005013_Policy_Customer_Web_App_Guest_Session_App_Native_Continuity_Order_Surface_And_Runtime_Control.md` | 16168 | 005013 | 005013_Policy_Customer_Web_App_Guest_Session_App_Native_Continuity_Order_Surface_And_Runtime_Control.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005014_Policy_Customer_Native_App_Deep_Link_Push_Account_Continuity_Web_App_Coexistence_And_Runtime_Control.md` | 16645 | 005014 | 005014_Policy_Customer_Native_App_Deep_Link_Push_Account_Continuity_Web_App_Coexistence_And_Runtime_Control.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005015_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md` | 15344 | 005015 | 005015_Policy_Customer_Account_Guest_Merge_Identity_Continuity_Membership_Ready_And_Runtime_Authority_Boundary.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005016_Policy_Customer_Membership_Loyalty_Coupon_Visit_Count_Store_Benefit_And_Runtime_Control.md` | 17445 | 005016 | 005016_Policy_Customer_Membership_Loyalty_Coupon_Visit_Count_Store_Benefit_And_Runtime_Control.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005017_Policy_Customer_Support_Case_Dispute_Resolution_Compensation_Refund_Cancel_Handoff_And_Evidence_Control.md` | 17708 | 005017 | 005017_Policy_Customer_Support_Case_Dispute_Resolution_Compensation_Refund_Cancel_Handoff_And_Evidence_Control.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005018_Policy_Customer_Privacy_Consent_Data_Retention_Evidence_Access_Support_Visibility_And_Runtime_Governance.md` | 17636 | 005018 | 005018_Policy_Customer_Privacy_Consent_Data_Retention_Evidence_Access_Support_Visibility_And_Runtime_Governance.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005019_Policy_Customer_Runtime_Pilot_Readiness_Closeout_Rollout_Acceptance_And_Governance.md` | 21140 | 005019 | 005019_Policy_Customer_Runtime_Pilot_Readiness_Closeout_Rollout_Acceptance_And_Governance.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005020_Guide_User_Flow.md` | 8603 | 005020 | 005020_Guide_User_Flow.md | Guide | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005021_Checklist_Customer_Runtime_Pilot_Readiness_Entry_Closeout_Rollout_And_Evidence_Acceptance.md` | 22192 | 005021 | 005021_Checklist_Customer_Runtime_Pilot_Readiness_Entry_Closeout_Rollout_And_Evidence_Acceptance.md | Checklist | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005022_Runbook_Customer_Runtime_Pilot_Execution_Observation_Closeout_Incident_And_Rollout_Decision.md` | 18000 | 005022 | 005022_Runbook_Customer_Runtime_Pilot_Execution_Observation_Closeout_Incident_And_Rollout_Decision.md | Runbook | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005023_Template_Customer_Runtime_Pilot_Evidence_Packet_Closeout_Record_Rollout_Decision_And_Risk_Handoff.md` | 14630 | 005023 | 005023_Template_Customer_Runtime_Pilot_Evidence_Packet_Closeout_Record_Rollout_Decision_And_Risk_Handoff.md | Template | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005024_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md` | 15982 | 005024 | 005024_Register_Customer_Runtime_Risk_Waiver_Blocker_Backlog_Carry_Forward_And_Rollout_Control.md | Register | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005025_Index_Customer_Runtime_Lane_Document_Map_Readiness_Status_Handoff_And_Governance.md` | 12629 | 005025 | 005025_Index_Customer_Runtime_Lane_Document_Map_Readiness_Status_Handoff_And_Governance.md | Index | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005026_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md` | 28634 | 005026 | 005026_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md | Evidence | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005027_Policy_Order_Payment_Three_Path_Gate_Sequencing_And_Runtime_Control.md` | 3591 | 005027 | 005027_Policy_Order_Payment_Three_Path_Gate_Sequencing_And_Runtime_Control.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005030_Readme_Stage_0.md` | 9211 | 005030 | 005030_Readme_Stage_0.md | Readme | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005040_Policy_Stage_0A_QR_Menu_And_Show_To_Staff_Flow.md` | 11731 | 005040 | 005040_Policy_Stage_0A_QR_Menu_And_Show_To_Staff_Flow.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005050_Policy_Stage_0B_Send_To_Store_Request_Flow.md` | 13404 | 005050 | 005050_Policy_Stage_0B_Send_To_Store_Request_Flow.md | Policy | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005060_Readme_Reservation_Preorder_Governance.md` | 14789 | 005060 | 005060_Readme_Reservation_Preorder_Governance.md | Readme | 005010_customer_handoff_flow | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005100_Readme_Implementation_Readiness_And_Provider_Verification.md` | 2243 | 005100 | 005100_Readme_Implementation_Readiness_And_Provider_Verification.md | Readme | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005111_Policy_Implementation_Readiness_Backlog_And_Test_Execution_Planning.md` | 20681 | 005111 | 005111_Policy_Implementation_Readiness_Backlog_And_Test_Execution_Planning.md | Policy | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` | 19435 | 005121 | 005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md | Policy | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005131_Evidence_Packet_Template_And_Test_Result_Recording.md` | 22161 | 005131 | 005131_Evidence_Packet_Template_And_Test_Result_Recording.md | Template | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005141_Policy_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance.md` | 23585 | 005141 | 005141_Policy_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance.md | Policy | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005151_Policy_Toss_POS_Official_Verification_Checklist_And_Integration_Evidence.md` | 23382 | 005151 | 005151_Policy_Toss_POS_Official_Verification_Checklist_And_Integration_Evidence.md | Policy | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005161_Policy_Controlled_Implementation_Entry_Gate_And_Build_Authorization.md` | 22825 | 005161 | 005161_Policy_Controlled_Implementation_Entry_Gate_And_Build_Authorization.md | Policy | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005191_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral.md` | 16195 | 005191 | 005191_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral.md | Policy | 005100_implementation_readiness_and_provider_verification | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005200_Readme_POS_Payment_Provider_And_Kiosk_Reuse.md` | 1746 | 005200 | 005200_Readme_POS_Payment_Provider_And_Kiosk_Reuse.md | Readme | 005200_pos_payment_provider_and_kiosk_reuse | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005201_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse.md` | 13536 | 005201 | 005201_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse.md | Policy | 005200_pos_payment_provider_and_kiosk_reuse | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005211_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary.md` | 17792 | 005211 | 005211_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary.md | Module | 005200_pos_payment_provider_and_kiosk_reuse | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005221_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary.md` | 18468 | 005221 | 005221_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary.md | Policy | 005200_pos_payment_provider_and_kiosk_reuse | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005231_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary.md` | 20300 | 005231 | 005231_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary.md | Policy | 005200_pos_payment_provider_and_kiosk_reuse | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005241_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel.md` | 17972 | 005241 | 005241_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel.md | Policy | 005200_pos_payment_provider_and_kiosk_reuse | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005200_pos_payment_provider_and_kiosk_reuse/005251_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md` | 20430 | 005251 | 005251_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md | Policy | 005200_pos_payment_provider_and_kiosk_reuse | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005400_pos_waiting_entry_sync/005400_Readme_POS_Waiting_Entry_Sync.md` | 801 | 005400 | 005400_Readme_POS_Waiting_Entry_Sync.md | Readme | 005400_pos_waiting_entry_sync | current |
| `docs/005000_customer_handoff_and_implementation_readiness/005400_pos_waiting_entry_sync/005410_Policy_POS_Waiting_Entry_NoShow_And_Prepaid_Cancel_Sync.md` | 15607 | 005410 | 005410_Policy_POS_Waiting_Entry_NoShow_And_Prepaid_Cancel_Sync.md | Policy | 005400_pos_waiting_entry_sync | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600200_Readme_Flutter_Waiting_Feature_Implementation.md` | 3785 | 600200 | 600200_Readme_Flutter_Waiting_Feature_Implementation.md | Readme | 600200_flutter_waiting_feature_implementation | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600201_ChangeHistory.md` | 2333 | 600201 | 600201_ChangeHistory.md | md | 600200_flutter_waiting_feature_implementation | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600202_NavigationMap.md` | 1606 | 600202 | 600202_NavigationMap.md | md | 600200_flutter_waiting_feature_implementation | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600203_DecisionLog.md` | 1329 | 600203 | 600203_DecisionLog.md | md | 600200_flutter_waiting_feature_implementation | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/.gitkeep` | 0 | — | — | none | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600211_Overview.md` | 14886 | 600211 | 600211_Overview.md | md | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600212_Logic.md` | 16817 | 600212 | 600212_Logic.md | md | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600213_TestPlan.md` | 11081 | 600213 | 600213_TestPlan.md | md | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600214_ChangeContract.md` | 5649 | 600214 | 600214_ChangeContract.md | md | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600215_Module.md` | 5102 | 600215 | 600215_Module.md | md | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600216_Verification.md` | 4341 | 600216 | 600216_Verification.md | md | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600217_Audit.md` | 7399 | 600217 | 600217_Audit.md | md | 600210_waiting_feature_guest_customer_id_integration | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600221_Overview.md` | 5762 | 600221 | 600221_Overview.md | md | 600220_platform_deployment_strategy | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600222_Logic.md` | 6971 | 600222 | 600222_Logic.md | md | 600220_platform_deployment_strategy | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600223_TestPlan.md` | 11665 | 600223 | 600223_TestPlan.md | md | 600220_platform_deployment_strategy | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600224_ChangeContract.md` | 6596 | 600224 | 600224_ChangeContract.md | md | 600220_platform_deployment_strategy | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600225_Module.md` | 3393 | 600225 | 600225_Module.md | md | 600220_platform_deployment_strategy | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600226_Verification.md` | 4580 | 600226 | 600226_Verification.md | md | 600220_platform_deployment_strategy | current |
| `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600227_Audit.md` | 5355 | 600227 | 600227_Audit.md | md | 600220_platform_deployment_strategy | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600400_Readme_KDS_Implementation.md` | 3562 | 600400 | 600400_Readme_KDS_Implementation.md | Readme | 600400_kds_did_implementation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600401_ChangeHistory.md` | 18542 | 600401 | 600401_ChangeHistory.md | md | 600400_kds_did_implementation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600402_NavigationMap.md` | 2345 | 600402 | 600402_NavigationMap.md | md | 600400_kds_did_implementation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600403_DecisionLog.md` | 2180 | 600403 | 600403_DecisionLog.md | md | 600400_kds_did_implementation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600404_PlaceTakeoutOrder_Defect_Roadmap.md` | 8527 | 600404 | 600404_PlaceTakeoutOrder_Defect_Roadmap.md | PlaceTakeoutOrder | 600400_kds_did_implementation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600411_Overview.md` | 8354 | 600411 | 600411_Overview.md | md | 600410_kds_capacity_gate_and_status_reconciliation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600412_Logic.md` | 15332 | 600412 | 600412_Logic.md | md | 600410_kds_capacity_gate_and_status_reconciliation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600413_TestPlan.md` | 10953 | 600413 | 600413_TestPlan.md | md | 600410_kds_capacity_gate_and_status_reconciliation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600414_ChangeContract.md` | 4194 | 600414 | 600414_ChangeContract.md | md | 600410_kds_capacity_gate_and_status_reconciliation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600415_Module.md` | 3059 | 600415 | 600415_Module.md | md | 600410_kds_capacity_gate_and_status_reconciliation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600416_Verification.md` | 3889 | 600416 | 600416_Verification.md | md | 600410_kds_capacity_gate_and_status_reconciliation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/600417_Audit.md` | 5753 | 600417 | 600417_Audit.md | md | 600410_kds_capacity_gate_and_status_reconciliation | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600420_kds_status_naming_and_stale_columns/.gitkeep` | 0 | — | — | none | 600420_kds_status_naming_and_stale_columns | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600420_kds_status_naming_and_stale_columns/600421_Module.md` | 2534 | 600421 | 600421_Module.md | md | 600420_kds_status_naming_and_stale_columns | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600420_kds_status_naming_and_stale_columns/600422_Verification.md` | 4348 | 600422 | 600422_Verification.md | md | 600420_kds_status_naming_and_stale_columns | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600420_kds_status_naming_and_stale_columns/600423_Audit.md` | 7130 | 600423 | 600423_Audit.md | md | 600420_kds_status_naming_and_stale_columns | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600441_Overview.md` | 17634 | 600441 | 600441_Overview.md | md | 600440_kds_status_committed_unification | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600442_Logic.md` | 22257 | 600442 | 600442_Logic.md | md | 600440_kds_status_committed_unification | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600443_TestPlan.md` | 16781 | 600443 | 600443_TestPlan.md | md | 600440_kds_status_committed_unification | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600444_ChangeContract.md` | 6850 | 600444 | 600444_ChangeContract.md | md | 600440_kds_status_committed_unification | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600445_Module.md` | 5522 | 600445 | 600445_Module.md | md | 600440_kds_status_committed_unification | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600446_Verification.md` | 7134 | 600446 | 600446_Verification.md | md | 600440_kds_status_committed_unification | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600440_kds_status_committed_unification/600447_Audit.md` | 5940 | 600447 | 600447_Audit.md | md | 600440_kds_status_committed_unification | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600520_domain_folder_reorganization/600521_Overview_Domain_Folder_Reorganization.md` | 11247 | 600521 | 600521_Overview_Domain_Folder_Reorganization.md | Overview | 600520_domain_folder_reorganization | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600520_domain_folder_reorganization/600522_Logic_Domain_Folder_Reorganization.md` | 16465 | 600522 | 600522_Logic_Domain_Folder_Reorganization.md | Logic | 600520_domain_folder_reorganization | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600520_domain_folder_reorganization/600523_TestPlan_Domain_Folder_Reorganization.md` | 11283 | 600523 | 600523_TestPlan_Domain_Folder_Reorganization.md | TestPlan | 600520_domain_folder_reorganization | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600520_domain_folder_reorganization/600524_ChangeContract_Domain_Folder_Reorganization.md` | 10545 | 600524 | 600524_ChangeContract_Domain_Folder_Reorganization.md | ChangeContract | 600520_domain_folder_reorganization | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600520_domain_folder_reorganization/600525_Module.md` | 4529 | 600525 | 600525_Module.md | md | 600520_domain_folder_reorganization | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600520_domain_folder_reorganization/600526_Verification.md` | 7287 | 600526 | 600526_Verification.md | md | 600520_domain_folder_reorganization | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600520_domain_folder_reorganization/600527_Audit.md` | 6959 | 600527 | 600527_Audit.md | md | 600520_domain_folder_reorganization | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md` | 24851 | 601021 | 601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md | Overview | 601020_authorize_kds_release_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/601022_Logic_Authorize_Kds_Release_Overload_And_Redesign.md` | 19726 | 601022 | 601022_Logic_Authorize_Kds_Release_Overload_And_Redesign.md | Logic | 601020_authorize_kds_release_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/601023_TestPlan.md` | 12180 | 601023 | 601023_TestPlan.md | md | 601020_authorize_kds_release_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/601024_ChangeContract.md` | 9122 | 601024 | 601024_ChangeContract.md | md | 601020_authorize_kds_release_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/601025_Module.md` | 5176 | 601025 | 601025_Module.md | md | 601020_authorize_kds_release_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/601026_Verification.md` | 15495 | 601026 | 601026_Verification.md | md | 601020_authorize_kds_release_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/601027_Audit.md` | 8317 | 601027 | 601027_Audit.md | md | 601020_authorize_kds_release_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600500_Readme_Payment_Confirmation.md` | 913 | 600500 | 600500_Readme_Payment_Confirmation.md | Readme | 600500_payment_confirmation | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600502_NavigationMap_Payment_Confirmation.md` | 4364 | 600502 | 600502_NavigationMap_Payment_Confirmation.md | NavigationMap | 600500_payment_confirmation | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600511_Overview.md` | 12812 | 600511 | 600511_Overview.md | md | 600510_confirm_payment_from_provider_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600512_Logic.md` | 11275 | 600512 | 600512_Logic.md | md | 600510_confirm_payment_from_provider_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600513_TestPlan.md` | 10041 | 600513 | 600513_TestPlan.md | md | 600510_confirm_payment_from_provider_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600514_ChangeContract.md` | 10543 | 600514 | 600514_ChangeContract.md | md | 600510_confirm_payment_from_provider_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600515_Module.md` | 2752 | 600515 | 600515_Module.md | md | 600510_confirm_payment_from_provider_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600516_Verification.md` | 5510 | 600516 | 600516_Verification.md | md | 600510_confirm_payment_from_provider_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600517_Audit.md` | 6785 | 600517 | 600517_Audit.md | md | 600510_confirm_payment_from_provider_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600541_Overview_Mark_Payment_Uncertain_Overload.md` | 12415 | 600541 | 600541_Overview_Mark_Payment_Uncertain_Overload.md | Overview | 600540_mark_payment_uncertain_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600542_Logic_Mark_Payment_Uncertain_Overload.md` | 13167 | 600542 | 600542_Logic_Mark_Payment_Uncertain_Overload.md | Logic | 600540_mark_payment_uncertain_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600543_TestPlan_Mark_Payment_Uncertain_Overload.md` | 9584 | 600543 | 600543_TestPlan_Mark_Payment_Uncertain_Overload.md | TestPlan | 600540_mark_payment_uncertain_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600544_ChangeContract_Mark_Payment_Uncertain_Overload.md` | 6117 | 600544 | 600544_ChangeContract_Mark_Payment_Uncertain_Overload.md | ChangeContract | 600540_mark_payment_uncertain_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600545_Module.md` | 2724 | 600545 | 600545_Module.md | md | 600540_mark_payment_uncertain_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600546_Verification.md` | 8593 | 600546 | 600546_Verification.md | md | 600540_mark_payment_uncertain_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600547_Audit.md` | 6008 | 600547 | 600547_Audit.md | md | 600540_mark_payment_uncertain_overload_ambiguity | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` | 33198 | 600551 | 600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md | Overview | 600550_confirm_payment_column_drift_and_intent_linkage_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` | 29928 | 600552 | 600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md | Logic | 600550_confirm_payment_column_drift_and_intent_linkage_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` | 12446 | 600553 | 600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix | TestPlan | 600550_confirm_payment_column_drift_and_intent_linkage_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` | 11521 | 600554 | 600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix | ChangeContract | 600550_confirm_payment_column_drift_and_intent_linkage_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600555_Module.md` | 4452 | 600555 | 600555_Module.md | md | 600550_confirm_payment_column_drift_and_intent_linkage_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600556_Verification.md` | 7138 | 600556 | 600556_Verification.md | md | 600550_confirm_payment_column_drift_and_intent_linkage_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600557_Audit.md` | 6616 | 600557 | 600557_Audit.md | md | 600550_confirm_payment_column_drift_and_intent_linkage_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600561_Overview_Payment_Intent_Race_Condition_Fix.md` | 13006 | 600561 | 600561_Overview_Payment_Intent_Race_Condition_Fix.md | Overview | 600560_payment_intent_race_condition_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600562_Logic_Payment_Intent_Race_Condition_Fix.md` | 18652 | 600562 | 600562_Logic_Payment_Intent_Race_Condition_Fix.md | Logic | 600560_payment_intent_race_condition_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600563_TestPlan.md` | 11451 | 600563 | 600563_TestPlan.md | md | 600560_payment_intent_race_condition_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600564_ChangeContract.md` | 7880 | 600564 | 600564_ChangeContract.md | md | 600560_payment_intent_race_condition_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600565_Module.md` | 3276 | 600565 | 600565_Module.md | md | 600560_payment_intent_race_condition_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600566_Verification.md` | 5404 | 600566 | 600566_Verification.md | md | 600560_payment_intent_race_condition_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600567_Audit.md` | 4810 | 600567 | 600567_Audit.md | md | 600560_payment_intent_race_condition_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600571_Overview_Cancel_Payment_Phantom_Column_Fix.md` | 25386 | 600571 | 600571_Overview_Cancel_Payment_Phantom_Column_Fix.md | Overview | 600570_cancel_payment_phantom_column_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600572_Logic_Cancel_Payment_Phantom_Column_Fix.md` | 10440 | 600572 | 600572_Logic_Cancel_Payment_Phantom_Column_Fix.md | Logic | 600570_cancel_payment_phantom_column_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600573_TestPlan_Cancel_Payment_Phantom_Column_Fix.md` | 11287 | 600573 | 600573_TestPlan_Cancel_Payment_Phantom_Column_Fix | TestPlan | 600570_cancel_payment_phantom_column_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600574_ChangeContract_Cancel_Payment_Phantom_Column_Fix.md` | 6399 | 600574 | 600574_ChangeContract_Cancel_Payment_Phantom_Column_Fix | ChangeContract | 600570_cancel_payment_phantom_column_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600575_Module.md` | 3059 | 600575 | 600575_Module.md | md | 600570_cancel_payment_phantom_column_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600576_Verification.md` | 5895 | 600576 | 600576_Verification.md | md | 600570_cancel_payment_phantom_column_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600577_Audit.md` | 3766 | 600577 | 600577_Audit.md | md | 600570_cancel_payment_phantom_column_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md` | 14591 | 600581 | 600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md | Overview | 600580_payment_confirm_cancel_state_machine_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md` | 23060 | 600582 | 600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md | Logic | 600580_payment_confirm_cancel_state_machine_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix.md` | 13126 | 600583 | 600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix | TestPlan | 600580_payment_confirm_cancel_state_machine_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix.md` | 9731 | 600584 | 600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix | ChangeContract | 600580_payment_confirm_cancel_state_machine_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600585_Module.md` | 4577 | 600585 | 600585_Module.md | md | 600580_payment_confirm_cancel_state_machine_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600586_Verification.md` | 5778 | 600586 | 600586_Verification.md | md | 600580_payment_confirm_cancel_state_machine_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600587_Audit.md` | 4171 | 600587 | 600587_Audit.md | md | 600580_payment_confirm_cancel_state_machine_fix | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600590_confirm_payment_from_provider_kds_commit_correction/600591_Overview_Confirm_Payment_From_Provider_Kds_Commit_Correction.md` | 17416 | 600591 | 600591_Overview_Confirm_Payment_From_Provider_Kds_Commit_Correction.md | Overview | 600590_confirm_payment_from_provider_kds_commit_correction | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/600590_confirm_payment_from_provider_kds_commit_correction/600592_Logic_Confirm_Payment_From_Provider_Kds_Commit_Correction.md` | 12050 | 600592 | 600592_Logic_Confirm_Payment_From_Provider_Kds_Commit_Correction.md | Logic | 600590_confirm_payment_from_provider_kds_commit_correction | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601031_Overview_Canonical_Kds_Release_Orchestration.md` | 18170 | 601031 | 601031_Overview_Canonical_Kds_Release_Orchestration.md | Overview | 601030_canonical_kds_release_orchestration | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601032_Logic_Canonical_Kds_Release_Orchestration.md` | 45891 | 601032 | 601032_Logic_Canonical_Kds_Release_Orchestration.md | Logic | 601030_canonical_kds_release_orchestration | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601033_TestPlan_Canonical_Kds_Release_Orchestration.md` | 40696 | 601033 | 601033_TestPlan_Canonical_Kds_Release_Orchestration.md | TestPlan | 601030_canonical_kds_release_orchestration | current |
| `docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601034_ChangeContract_Canonical_Kds_Release_Orchestration.md` | 32933 | 601034 | 601034_ChangeContract_Canonical_Kds_Release_Orchestration.md | ChangeContract | 601030_canonical_kds_release_orchestration | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600600_Readme_Waiting_Order_Session.md` | 1136 | 600600 | 600600_Readme_Waiting_Order_Session.md | Readme | 600600_waiting_order_session | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600602_NavigationMap_Waiting_Order_Session.md` | 5588 | 600602 | 600602_NavigationMap_Waiting_Order_Session.md | NavigationMap | 600600_waiting_order_session | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600611_Overview.md` | 10426 | 600611 | 600611_Overview.md | md | 600610_takeout_session_type_fix | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600612_Logic.md` | 13475 | 600612 | 600612_Logic.md | md | 600610_takeout_session_type_fix | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600613_TestPlan.md` | 10434 | 600613 | 600613_TestPlan.md | md | 600610_takeout_session_type_fix | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600614_ChangeContract.md` | 8843 | 600614 | 600614_ChangeContract.md | md | 600610_takeout_session_type_fix | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600615_Module.md` | 3350 | 600615 | 600615_Module.md | md | 600610_takeout_session_type_fix | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600616_Verification.md` | 6873 | 600616 | 600616_Verification.md | md | 600610_takeout_session_type_fix | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600617_Audit.md` | 6963 | 600617 | 600617_Audit.md | md | 600610_takeout_session_type_fix | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600621_Overview.md` | 17882 | 600621 | 600621_Overview.md | md | 600620_customer_handoff_contract_reconciliation | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600622_Logic.md` | 14390 | 600622 | 600622_Logic.md | md | 600620_customer_handoff_contract_reconciliation | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600623_TestPlan.md` | 11826 | 600623 | 600623_TestPlan.md | md | 600620_customer_handoff_contract_reconciliation | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600624_ChangeContract.md` | 11013 | 600624 | 600624_ChangeContract.md | md | 600620_customer_handoff_contract_reconciliation | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600625_Module.md` | 3519 | 600625 | 600625_Module.md | md | 600620_customer_handoff_contract_reconciliation | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600626_Verification.md` | 7364 | 600626 | 600626_Verification.md | md | 600620_customer_handoff_contract_reconciliation | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600627_Audit.md` | 8233 | 600627 | 600627_Audit.md | md | 600620_customer_handoff_contract_reconciliation | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600631_Overview_Mark_No_Show_Overload_And_Redesign.md` | 19638 | 600631 | 600631_Overview_Mark_No_Show_Overload_And_Redesign.md | Overview | 600630_mark_no_show_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600632_Logic.md` | 70766 | 600632 | 600632_Logic_Mark_No_Show_Overload_And_Redesign.md | md | 600630_mark_no_show_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600633_TestPlan.md` | 18172 | 600633 | 600633_TestPlan.md | md | 600630_mark_no_show_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600634_ChangeContract.md` | 9313 | 600634 | 600634_ChangeContract.md | md | 600630_mark_no_show_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600635_Module.md` | 6027 | 600635 | 600635_Module.md | md | 600630_mark_no_show_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600636_Verification.md` | 7607 | 600636 | 600636_Verification.md | md | 600630_mark_no_show_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600637_Audit.md` | 4646 | 600637 | 600637_Audit.md | md | 600630_mark_no_show_overload_and_redesign | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` | 18426 | 600641 | 600641_Overview_Call_Waiting_Customer_Contract_Recovery.md | Overview | 600640_call_waiting_customer_contract_recovery | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` | 30685 | 600642 | 600642_Logic_Call_Waiting_Customer_Contract_Recovery.md | Logic | 600640_call_waiting_customer_contract_recovery | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600643_TestPlan.md` | 16435 | 600643 | 600643_TestPlan.md | md | 600640_call_waiting_customer_contract_recovery | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600644_ChangeContract.md` | 10080 | 600644 | 600644_ChangeContract.md | md | 600640_call_waiting_customer_contract_recovery | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600645_Module.md` | 4549 | 600645 | 600645_Module.md | md | 600640_call_waiting_customer_contract_recovery | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600646_Verification.md` | 6702 | 600646 | 600646_Verification.md | md | 600640_call_waiting_customer_contract_recovery | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600647_Audit.md` | 5587 | 600647 | 600647_Audit.md | md | 600640_call_waiting_customer_contract_recovery | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` | 21073 | 600651 | 600651_Overview_Seat_Waiting_Customer_Facade_Correction.md | Overview | 600650_seat_waiting_customer_facade_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` | 36582 | 600652 | 600652_Logic_Seat_Waiting_Customer_Facade_Correction.md | Logic | 600650_seat_waiting_customer_facade_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md` | 39772 | 600653 | 600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md | TestPlan | 600650_seat_waiting_customer_facade_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` | 25228 | 600654 | 600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md | ChangeContract | 600650_seat_waiting_customer_facade_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md` | 23312 | 600661 | 600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md | Overview | 600660_waiting_pipeline_sibling_functions_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` | 36630 | 600662 | 600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md | Logic | 600660_waiting_pipeline_sibling_functions_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md` | 37658 | 600663 | 600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md | TestPlan | 600660_waiting_pipeline_sibling_functions_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` | 26593 | 600664 | 600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md | ChangeContract | 600660_waiting_pipeline_sibling_functions_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600671_Overview_Record_Waiting_Call_Grant_Correction.md` | 22369 | 600671 | 600671_Overview_Record_Waiting_Call_Grant_Correction.md | Overview | 600670_record_waiting_call_grant_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600672_Logic_Record_Waiting_Call_Grant_Correction.md` | 12470 | 600672 | 600672_Logic_Record_Waiting_Call_Grant_Correction.md | Logic | 600670_record_waiting_call_grant_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600673_TestPlan_Record_Waiting_Call_Grant_Correction.md` | 16568 | 600673 | 600673_TestPlan_Record_Waiting_Call_Grant_Correction.md | TestPlan | 600670_record_waiting_call_grant_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600674_ChangeContract_Record_Waiting_Call_Grant_Correction.md` | 16336 | 600674 | 600674_ChangeContract_Record_Waiting_Call_Grant_Correction.md | ChangeContract | 600670_record_waiting_call_grant_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md` | 12418 | 600681 | 600681 Overview — Pre-Order While Waiting Phantom Correction | Overview | 600680_pre_order_while_waiting_phantom_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md` | 14403 | 600682 | 600682 Logic — Pre-Order While Waiting Phantom Correction | Logic | 600680_pre_order_while_waiting_phantom_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md` | 8316 | 600683 | 600683 TestPlan — Pre-Order While Waiting Phantom Correction | TestPlan | 600680_pre_order_while_waiting_phantom_correction | current |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600684_ChangeContract_Pre_Order_While_Waiting_Phantom_Correction.md` | 7144 | 600684 | 600684 ChangeContract — Pre-Order While Waiting Phantom Correction | ChangeContract | 600680_pre_order_while_waiting_phantom_correction | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600800_Readme_Did_Implementation.md` | 1029 | 600800 | 600800_Readme_Did_Implementation.md | Readme | 600800_did_implementation | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600802_NavigationMap_Did_Implementation.md` | 415 | 600802 | 600802_NavigationMap_Did_Implementation.md | NavigationMap | 600800_did_implementation | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600810_kds_did_event_reactive_implementation/.gitkeep` | 0 | — | — | none | 600810_kds_did_event_reactive_implementation | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/600821_Overview_Did_Display_State_Overload.md` | 8926 | 600821 | 600821_Overview_Did_Display_State_Overload.md | Overview | 600820_did_display_state_overload_and_legacy_defect | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/600822_Logic_Did_Display_State_Overload.md` | 6468 | 600822 | 600822_Logic_Did_Display_State_Overload.md | Logic | 600820_did_display_state_overload_and_legacy_defect | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/600823_TestPlan_Did_Display_State_Overload.md` | 6980 | 600823 | 600823_TestPlan_Did_Display_State_Overload.md | TestPlan | 600820_did_display_state_overload_and_legacy_defect | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/600824_ChangeContract_Did_Display_State_Overload.md` | 4209 | 600824 | 600824_ChangeContract_Did_Display_State_Overload.md | ChangeContract | 600820_did_display_state_overload_and_legacy_defect | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/600825_Module.md` | 2495 | 600825 | 600825_Module.md | md | 600820_did_display_state_overload_and_legacy_defect | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/600826_Verification.md` | 7109 | 600826 | 600826_Verification.md | md | 600820_did_display_state_overload_and_legacy_defect | current |
| `docs/600000_implementation_lifecycle/600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/600827_Audit.md` | 6261 | 600827 | 600827_Audit.md | md | 600820_did_display_state_overload_and_legacy_defect | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601321_PassA_Blind_Reverse_Engineering_Payment.md` | 15693 | 601321 | Pass A: Blind Reverse-Engineering — 결제(600500) | PassA | 601320_domain_01_payment | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601322_PassB_Intent_Comparison_Payment.md` | 326 | 601322 | 601322_PassB_Intent_Comparison_Payment.md | PassB | 601320_domain_01_payment | pending_placeholder |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601320_domain_01_payment/601323_PassC_Confirmed_Gaps_And_Disposition_Payment.md` | 339 | 601323 | 601323_PassC_Confirmed_Gaps_And_Disposition_Payment.md | PassC | 601320_domain_01_payment | pending_placeholder |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md` | 340 | 601331 | 601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md | PassA | 601330_domain_02_waiting_order | pending_placeholder |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md` | 15172 | 601331 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스05 (공통기반) | PassA | 601330_domain_02_waiting_order | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md` | 11611 | 601332 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스01 (대기열 등록/조회) | PassA | 601330_domain_02_waiting_order | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601332_PassB_Intent_Comparison_Waiting_Order.md` | 332 | 601332 | 601332_PassB_Intent_Comparison_Waiting_Order.md | PassB | 601330_domain_02_waiting_order | pending_placeholder |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md` | 11506 | 601333 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스02 (호출/도착확인) | PassA | 601330_domain_02_waiting_order | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md` | 345 | 601333 | 601333_PassC_Confirmed_Gaps_And_Disposition_Waiting_Order.md | PassC | 601330_domain_02_waiting_order | pending_placeholder |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md` | 11547 | 601334 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스03 (노쇼/유예) | PassA | 601330_domain_02_waiting_order | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601330_domain_02_waiting_order/601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md` | 12263 | 601335 | Pass A: Blind Reverse-Engineering — 대기열/주문 슬라이스04 (사전주문/착석/주문본체) | PassA | 601330_domain_02_waiting_order | current |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601351_PassA_Blind_Reverse_Engineering_Kds_Did.md` | 334 | 601351 | 601351_PassA_Blind_Reverse_Engineering_Kds_Did.md | PassA | 601350_domain_04_kds_did | pending_placeholder |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601352_PassB_Intent_Comparison_Kds_Did.md` | 326 | 601352 | 601352_PassB_Intent_Comparison_Kds_Did.md | PassB | 601350_domain_04_kds_did | pending_placeholder |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601350_domain_04_kds_did/601353_PassC_Confirmed_Gaps_And_Disposition_Kds_Did.md` | 339 | 601353 | 601353_PassC_Confirmed_Gaps_And_Disposition_Kds_Did.md | PassC | 601350_domain_04_kds_did | pending_placeholder |
| `docs/700000_runtime_flow_bundle/700000_Readme_Runtime_Flow_Bundle.md` | 2178 | 700000 | 700000_Readme_Runtime_Flow_Bundle | Readme | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700100_Governance_Runtime_Flow_Bundle_Master_Governance_Control.md` | 3377 | 700100 | 700100_Governance_Runtime_Flow_Bundle_Master_Governance_Control.md | Governance | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700101_Overview_Runtime_Flow_Bundle_Evidence_Readiness_Model.md` | 3350 | 700101 | 700101_Overview_Runtime_Flow_Bundle_Evidence_Readiness_Model.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700102_Boundary_Runtime_Flow_Bundle_No_Runtime_Implementation_Boundary.md` | 3359 | 700102 | 700102_Boundary_Runtime_Flow_Bundle_No_Runtime_Implementation_Boundary.md | Boundary | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700103_Register_Runtime_Flow_Bundle_Owner_And_Escalation_Register.md` | 3342 | 700103 | 700103_Register_Runtime_Flow_Bundle_Owner_And_Escalation_Register.md | Register | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700104_Checklist_Runtime_Flow_Bundle_Governance_Preflight_Check.md` | 3350 | 700104 | 700104_Checklist_Runtime_Flow_Bundle_Governance_Preflight_Check.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700105_Matrix_Runtime_Flow_Bundle_Document_Type_To_Evidence_Map.md` | 3344 | 700105 | 700105_Matrix_Runtime_Flow_Bundle_Document_Type_To_Evidence_Map.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700106_Report_Runtime_Flow_Bundle_Readiness_Status_Report.md` | 3319 | 700106 | 700106_Report_Runtime_Flow_Bundle_Readiness_Status_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700107_Template_Runtime_Flow_Bundle_Controlled_Evidence_Cover_Sheet.md` | 3345 | 700107 | 700107_Template_Runtime_Flow_Bundle_Controlled_Evidence_Cover_Sheet.md | Template | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700108_Audit_Runtime_Flow_Bundle_Governance_Compliance_Audit.md` | 3332 | 700108 | 700108_Audit_Runtime_Flow_Bundle_Governance_Compliance_Audit.md | Audit | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700109_Plan_Runtime_Flow_Bundle_Evidence_Expansion_Sequencing.md` | 3330 | 700109 | 700109_Plan_Runtime_Flow_Bundle_Evidence_Expansion_Sequencing.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700110_Boundary_External_Integration_Boundary_Master_Control.md` | 3361 | 700110 | 700110_Boundary_External_Integration_Boundary_Master_Control.md | Boundary | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700111_Matrix_External_Integration_System_To_Flow_Map.md` | 3322 | 700111 | 700111_Matrix_External_Integration_System_To_Flow_Map.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700112_Checklist_External_Integration_Boundary_Readiness_Check.md` | 3339 | 700112 | 700112_Checklist_External_Integration_Boundary_Readiness_Check.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700113_Register_External_Integration_Provider_Contact_And_Owner_Register.md` | 3354 | 700113 | 700113_Register_External_Integration_Provider_Contact_And_Owner_Register.md | Register | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700114_Evidence_External_Integration_Contract_And_Spec_Evidence_Packet.md` | 3350 | 700114 | 700114_Evidence_External_Integration_Contract_And_Spec_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700115_Audit_External_Integration_Boundary_Compliance_Audit.md` | 3323 | 700115 | 700115_Audit_External_Integration_Boundary_Compliance_Audit.md | Audit | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700116_Report_External_Integration_Open_Risk_Report.md` | 3313 | 700116 | 700116_Report_External_Integration_Open_Risk_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700117_Template_External_Integration_Evidence_Request_Template.md` | 3336 | 700117 | 700117_Template_External_Integration_Evidence_Request_Template.md | Template | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700118_Runbook_External_Integration_Evidence_Collection_Runbook.md` | 3350 | 700118 | 700118_Runbook_External_Integration_Evidence_Collection_Runbook.md | Runbook | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700119_Handoff_External_Integration_To_Runtime_Flow_Handoff.md` | 3340 | 700119 | 700119_Handoff_External_Integration_To_Runtime_Flow_Handoff.md | Handoff | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700120_Overview_POS_Provider_Runtime_Flow_Overview.md` | 3315 | 700120 | 700120_Overview_POS_Provider_Runtime_Flow_Overview.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700121_Matrix_POS_Provider_Request_Response_State_Matrix.md` | 3327 | 700121 | 700121_Matrix_POS_Provider_Request_Response_State_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700122_Checklist_POS_Provider_Runtime_Flow_Verification_Checklist.md` | 3325 | 700122 | 700122_Checklist_POS_Provider_Runtime_Flow_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700123_Evidence_POS_Provider_Approval_And_Cancel_Evidence_Packet.md` | 3323 | 700123 | 700123_Evidence_POS_Provider_Approval_And_Cancel_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700124_Report_POS_Provider_Runtime_Flow_Exception_Report.md` | 3321 | 700124 | 700124_Report_POS_Provider_Runtime_Flow_Exception_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700125_Overview_VAN_PG_Runtime_Evidence_Model.md` | 3300 | 700125 | 700125_Overview_VAN_PG_Runtime_Evidence_Model.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700126_Matrix_VAN_PG_Message_To_Audit_Field_Matrix.md` | 3315 | 700126 | 700126_Matrix_VAN_PG_Message_To_Audit_Field_Matrix.md | Audit | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700127_Checklist_VAN_PG_Runtime_Evidence_Checklist.md` | 3303 | 700127 | 700127_Checklist_VAN_PG_Runtime_Evidence_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700128_Evidence_VAN_PG_Provider_Response_Evidence_Packet.md` | 3321 | 700128 | 700128_Evidence_VAN_PG_Provider_Response_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700129_Audit_VAN_PG_Runtime_Evidence_Audit.md` | 3296 | 700129 | 700129_Audit_VAN_PG_Runtime_Evidence_Audit.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700130_Overview_Payment_Authorization_Capture_Cancel_Refund_Flow.md` | 3373 | 700130 | 700130_Overview_Payment_Authorization_Capture_Cancel_Refund_Flow.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700131_Matrix_Payment_State_Transition_To_Evidence_Matrix.md` | 3343 | 700131 | 700131_Matrix_Payment_State_Transition_To_Evidence_Matrix.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700132_Checklist_Payment_Flow_Verification_Checklist.md` | 3340 | 700132 | 700132_Checklist_Payment_Flow_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700133_Evidence_Payment_Cancel_Refund_Reversal_Evidence_Packet.md` | 3352 | 700133 | 700133_Evidence_Payment_Cancel_Refund_Reversal_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700134_Report_Payment_Flow_Exception_And_Reconciliation_Report.md` | 3353 | 700134 | 700134_Report_Payment_Flow_Exception_And_Reconciliation_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700135_Overview_KDS_Event_Projection_Flow_Overview.md` | 3318 | 700135 | 700135_Overview_KDS_Event_Projection_Flow_Overview.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700136_Matrix_KDS_Event_To_Kitchen_Ticket_Matrix.md` | 3299 | 700136 | 700136_Matrix_KDS_Event_To_Kitchen_Ticket_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700137_Checklist_KDS_Event_Projection_Verification_Checklist.md` | 3315 | 700137 | 700137_Checklist_KDS_Event_Projection_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700138_Overview_Kiosk_Order_Submission_Flow_Overview.md` | 3316 | 700138 | 700138_Overview_Kiosk_Order_Submission_Flow_Overview.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700139_Matrix_Kiosk_Order_To_POS_And_KDS_Map.md` | 3303 | 700139 | 700139_Matrix_Kiosk_Order_To_POS_And_KDS_Map.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700140_Checklist_Kiosk_Order_Submission_Verification_Checklist.md` | 3313 | 700140 | 700140_Checklist_Kiosk_Order_Submission_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700141_Overview_External_Order_App_Intake_Flow_Overview.md` | 3325 | 700141 | 700141_Overview_External_Order_App_Intake_Flow_Overview.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700142_Matrix_External_Order_App_To_Store_Runtime_Map.md` | 3320 | 700142 | 700142_Matrix_External_Order_App_To_Store_Runtime_Map.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700143_Checklist_External_Order_App_Intake_Verification_Checklist.md` | 3330 | 700143 | 700143_Checklist_External_Order_App_Intake_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700144_Overview_Webhook_Receive_Verify_Retry_Replay_Flow.md` | 3350 | 700144 | 700144_Overview_Webhook_Receive_Verify_Retry_Replay_Flow.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700145_Matrix_Webhook_Event_To_Idempotency_Key_Matrix.md` | 3334 | 700145 | 700145_Matrix_Webhook_Event_To_Idempotency_Key_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700146_Checklist_Webhook_Verification_And_Replay_Checklist.md` | 3340 | 700146 | 700146_Checklist_Webhook_Verification_And_Replay_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700147_Evidence_Webhook_Retry_Replay_Evidence_Packet.md` | 3342 | 700147 | 700147_Evidence_Webhook_Retry_Replay_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700148_Report_Webhook_Failure_And_Replay_Report.md` | 3325 | 700148 | 700148_Report_Webhook_Failure_And_Replay_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700149_Overview_Settlement_File_Intake_And_Reconciliation_Flow.md` | 3344 | 700149 | 700149_Overview_Settlement_File_Intake_And_Reconciliation_Flow.md | Overview | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700150_Matrix_Settlement_File_Field_To_Ledger_Map.md` | 3334 | 700150 | 700150_Matrix_Settlement_File_Field_To_Ledger_Map.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700151_Checklist_Settlement_Reconciliation_Verification_Checklist.md` | 3341 | 700151 | 700151_Checklist_Settlement_Reconciliation_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700152_Evidence_Settlement_File_Intake_Evidence_Packet.md` | 3319 | 700152 | 700152_Evidence_Settlement_File_Intake_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700153_Report_Settlement_Reconciliation_Exception_Report.md` | 3322 | 700153 | 700153_Report_Settlement_Reconciliation_Exception_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700154_Governance_Idempotency_Duplicate_Prevention_Control.md` | 3334 | 700154 | 700154_Governance_Idempotency_Duplicate_Prevention_Control.md | Governance | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700155_Matrix_Duplicate_Prevention_Key_And_State_Matrix.md` | 3318 | 700155 | 700155_Matrix_Duplicate_Prevention_Key_And_State_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700156_Checklist_Idempotency_Verification_Checklist.md` | 3327 | 700156 | 700156_Checklist_Idempotency_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700157_Runbook_Dead_Letter_Replay_Recovery_Runbook.md` | 3321 | 700157 | 700157_Runbook_Dead_Letter_Replay_Recovery_Runbook.md | Runbook | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700158_Matrix_Dead_Letter_To_Recovery_Action_Matrix.md` | 3306 | 700158 | 700158_Matrix_Dead_Letter_To_Recovery_Action_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700159_Evidence_Dead_Letter_Replay_Evidence_Packet.md` | 3310 | 700159 | 700159_Evidence_Dead_Letter_Replay_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700160_Runbook_Partial_Failure_Timeout_Provider_Outage_Runbook.md` | 3359 | 700160 | 700160_Runbook_Partial_Failure_Timeout_Provider_Outage_Runbook.md | Runbook | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700161_Matrix_Provider_Outage_To_Degraded_Mode_Matrix.md` | 3325 | 700161 | 700161_Matrix_Provider_Outage_To_Degraded_Mode_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700162_Report_Timeout_And_Provider_Outage_Exception_Report.md` | 3328 | 700162 | 700162_Report_Timeout_And_Provider_Outage_Exception_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700163_Evidence_Financial_Audit_Trail_Evidence_Packet.md` | 3306 | 700163 | 700163_Evidence_Financial_Audit_Trail_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700164_Matrix_Financial_Audit_Trail_Event_To_Ledger_Matrix.md` | 3305 | 700164 | 700164_Matrix_Financial_Audit_Trail_Event_To_Ledger_Matrix.md | Audit | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700165_Audit_Financial_Audit_Trail_Completeness_Audit.md` | 3308 | 700165 | 700165_Audit_Financial_Audit_Trail_Completeness_Audit.md | Audit | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700166_Evidence_Consumer_Protection_Evidence_Packet.md` | 3324 | 700166 | 700166_Evidence_Consumer_Protection_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700167_Checklist_Consumer_Protection_Verification_Checklist.md` | 3316 | 700167 | 700167_Checklist_Consumer_Protection_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700168_Boundary_Security_Signature_Verification_Boundary.md` | 3316 | 700168 | 700168_Boundary_Security_Signature_Verification_Boundary.md | Verification | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700169_Checklist_Security_Signature_Verification_Checklist.md` | 3308 | 700169 | 700169_Checklist_Security_Signature_Verification_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700170_Register_Runtime_Owner_And_Escalation_Matrix.md` | 3338 | 700170 | 700170_Register_Runtime_Owner_And_Escalation_Matrix.md | Register | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700171_Matrix_Runtime_Escalation_Severity_And_Action_Matrix.md` | 3325 | 700171 | 700171_Matrix_Runtime_Escalation_Severity_And_Action_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700172_Evidence_Test_Coverage_Evidence_Packet.md` | 3309 | 700172 | 700172_Evidence_Test_Coverage_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700173_Matrix_Test_Coverage_To_Runtime_Flow_Matrix.md` | 3288 | 700173 | 700173_Matrix_Test_Coverage_To_Runtime_Flow_Matrix.md | Matrix | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700174_Checklist_Release_Gate_And_Rollback_Gate_Checklist.md` | 3308 | 700174 | 700174_Checklist_Release_Gate_And_Rollback_Gate_Checklist.md | Checklist | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700175_Template_Release_Gate_Decision_Record_Template.md` | 3310 | 700175 | 700175_Template_Release_Gate_Decision_Record_Template.md | Template | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700176_Runbook_Rollback_Gate_Runtime_Flow_Runbook.md` | 3317 | 700176 | 700176_Runbook_Rollback_Gate_Runtime_Flow_Runbook.md | Runbook | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700177_Evidence_Post_Incident_Evidence_Packet.md` | 3302 | 700177 | 700177_Evidence_Post_Incident_Evidence_Packet.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700178_Report_Post_Incident_Runtime_Flow_Closeout_Report.md` | 3311 | 700178 | 700178_Report_Post_Incident_Runtime_Flow_Closeout_Report.md | Report | 700000_runtime_flow_bundle | current |
| `docs/700000_runtime_flow_bundle/700179_Governance_Runtime_Flow_Bundle_External_Integration_Evidence_Expansion_Wave_1.md` | 8601 | 700179 | 700179_Governance_Runtime_Flow_Bundle_External_Integration_Evidence_Expansion_Wave_1.md | Evidence | 700000_runtime_flow_bundle | current |
| `docs/900000_patent_and_handoff_package/900000_Readme_Patent_And_Handoff_Package.md` | 1840 | 900000 | 900000_Readme_Patent_And_Handoff_Package | Readme | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900100_Overview_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` | 9142 | 900100 | 900100_Overview_Customer_Waiting_Handoff_And_Late_Binding_Pipeline | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` | 16242 | 900101 | 900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | 12853 | 900102 | 900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release | ChangeContract | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | 14385 | 900103 | 900103_TestPlan_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release | TestPlan | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900110_Overview_Channel_1_Web_App_Customer_Handoff_And_Session.md` | 6642 | 900110 | 900110_Overview_Channel_1_Web_App_Customer_Handoff_And_Session | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900111_Logic_Channel_1_Web_App_Customer_Handoff_And_Session.md` | 10532 | 900111 | 900111_Logic_Channel_1_Web_App_Customer_Handoff_And_Session | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900120_Overview_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session.md` | 5626 | 900120 | 900120_Overview_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900121_Logic_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session.md` | 10663 | 900121 | 900121_Logic_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900130_Overview_Channel_3_Whitelabel_App_Customer_Handoff_And_Session.md` | 3556 | 900130 | 900130_Overview_Channel_3_Whitelabel_App_Customer_Handoff_And_Session | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900131_Logic_Channel_3_Whitelabel_App_Customer_Handoff_And_Session.md` | 8129 | 900131 | 900131_Logic_Channel_3_Whitelabel_App_Customer_Handoff_And_Session | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900140_Overview_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session.md` | 6469 | 900140 | 900140_Overview_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900141_Logic_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session.md` | 10013 | 900141 | 900141_Logic_Channel_4_Yoonsul_Embedded_App_Customer_Handoff_And_Session | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900150_Logic_Phase_Validation_Plan_Catch_Menu_To_Yoonsul_Embedded.md` | 12813 | 900150 | 900150_Logic_Phase_Validation_Plan_Catch_Menu_To_Yoonsul_Embedded | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` | 11981 | 900160 | 900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` | 16286 | 900161 | 900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900162_Logic_POS_Integration_Level_Based_Mode_Transition_System.md` | 11363 | 900162 | 900162_Logic_POS_Integration_Level_Based_Mode_Transition_System | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900163_Assessment_Prior_Patent_Risk_And_Avoidance_Strategy_Global_Late_Binding.md` | 11416 | 900163 | 900163_Assessment_Prior_Patent_Risk_And_Avoidance_Strategy_Global_Late_Binding | Assessment | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900164_Overview_POS_Dynamic_Multi_Service_Slot_Container_Agent_System_1.md` | 7111 | 900164 | 900164_Overview_POS_Dynamic_Multi_Service_Slot_Container_Agent_System | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900165_Logic_POS_Dynamic_Multi_Service_Slot_Container_Agent_System_1.md` | 12281 | 900165 | 900165_Logic_POS_Dynamic_Multi_Service_Slot_Container_Agent_System | Logic | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900170_Policy_Payment_Regulatory_Compliance_And_Table_Order_Design.md` | 7025 | 900170 | 900170_Policy_Payment_Regulatory_Compliance_And_Table_Order_Design | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900171_Policy_Slot_Container_Agent_Platform_Support_Android_And_Windows.md` | 8820 | 900171 | 900171_Policy_Slot_Container_Agent_Platform_Support_Android_And_Windows | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900172_Policy_Coupon_Business_Model_And_CMS_Integration.md` | 5589 | 900172 | 900172_Policy_Coupon_Business_Model_And_CMS_Integration | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900173_Policy_Yoonsul_OS_Multi_Brand_AI_FnB_OS_SaaS_Vision.md` | 6621 | 900173 | 900173_Policy_Yoonsul_OS_Multi_Brand_AI_FnB_OS_SaaS_Vision | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900174_Policy_Multi_Brand_Expansion_Roadmap_And_OS_Architecture.md` | 6587 | 900174 | 900174_Policy_Multi_Brand_Expansion_Roadmap_And_OS_Architecture | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900175_Policy_Workforce_Platform_And_Asia_FnB_Expansion_Vision.md` | 7971 | 900175 | 900175_Policy_Workforce_Platform_And_Asia_FnB_Expansion_Vision | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900176_Policy_CCP_Mini_HACCP_Food_Safety_Auto_Management.md` | 6576 | 900176 | 900176_Policy_CCP_Mini_HACCP_Food_Safety_Auto_Management | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900177_Policy_AI_Multi_Engine_Gateway_And_Inference_Audit_Log.md` | 11564 | 900177 | 900177_Policy_AI_Multi_Engine_Gateway_And_Inference_Audit_Log | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900178_Policy_Hyper_Personalization_Menu_Customization_And_Pricing.md` | 11608 | 900178 | 900178_Policy_Hyper_Personalization_Menu_Customization_And_Pricing | Policy | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900179_Assessment_Prior_Patent_Risk_And_Avoidance_Strategy_POS_Late_Binding.md` | 8530 | 900179 | 900179_Assessment_Prior_Patent_Risk_And_Avoidance_Strategy_POS_Late_Binding | Assessment | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/900180_Overview_CatchMenu_YoonsulOS_Asia_FnB_Platform.md` | 6459 | 900180 | 900180_Overview_CatchMenu_YoonsulOS_Asia_FnB_Platform | Overview | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/906000_TestPlan_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | 14047 | 906000 | 906000_TestPlan_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md | TestPlan | 900000_patent_and_handoff_package | current |
| `docs/900000_patent_and_handoff_package/906010_ChangeContract_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | 10758 | 906010 | 906010_ChangeContract_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md | ChangeContract | 900000_patent_and_handoff_package | current |
| `sql/migrations/0001_create_schemas.sql` | 3483 | — | — | sql | — | current |
| `sql/migrations/0002_create_hq_tenant_store.sql` | 3867 | — | — | sql | — | current |
| `sql/migrations/0003_create_store_device_agent_registry.sql` | 7374 | — | — | sql | — | current |
| `sql/migrations/0004_create_common_idempotency.sql` | 5165 | — | — | sql | — | current |
| `sql/migrations/0005_create_ledger_task.sql` | 5354 | — | — | sql | — | current |
| `sql/migrations/0006_create_ledger_event.sql` | 6343 | — | — | sql | — | current |
| `sql/migrations/0007_create_ledger_exception.sql` | 7688 | — | — | sql | — | current |
| `sql/migrations/0008_create_ledger_audit.sql` | 7859 | — | — | sql | — | current |
| `sql/migrations/0009_create_gateway_provider_events.sql` | 10202 | — | — | sql | — | current |
| `sql/migrations/0010_create_store_dining_tables.sql` | 4543 | — | — | sql | — | current |
| `sql/migrations/0011_create_pos_menu.sql` | 9137 | — | — | sql | — | current |
| `sql/migrations/0012_create_pos_order_sessions.sql` | 10350 | — | — | sql | — | current |
| `sql/migrations/0013_create_pos_orders.sql` | 11601 | — | — | sql | — | current |
| `sql/migrations/0014_create_payment_ledger.sql` | 13879 | — | — | sql | — | current |
| `sql/migrations/0016_create_kds_tickets.sql` | 11518 | — | — | sql | — | current |
| `sql/migrations/0017_create_evidence_and_fallback.sql` | 11717 | — | — | sql | — | current |
| `sql/migrations/0018_create_agent_actions_approvals.sql` | 12448 | — | — | sql | — | current |
| `sql/migrations/0019_create_knowledge_runtime.sql` | 15665 | — | — | sql | — | current |
| `sql/migrations/0020_create_integrations_and_local_ledger.sql` | 12449 | — | — | sql | — | current |
| `sql/migrations/0021_enable_rls.sql` | 6071 | — | — | sql | — | current |
| `sql/migrations/0022_create_rls_policies.sql` | 20527 | — | — | sql | — | current |
| `sql/migrations/0023_create_append_audit_rpc.sql` | 4521 | — | — | sql | — | current |
| `sql/migrations/0024_create_store_bootstrap_rpc.sql` | 8214 | — | — | sql | — | current |
| `sql/migrations/0025_create_session_rpc.sql` | 19795 | — | — | sql | — | current |
| `sql/migrations/0026_create_order_rpc.sql` | 21137 | — | — | sql | — | current |
| `sql/migrations/0027_create_payment_intent_rpc.sql` | 25609 | — | — | sql | — | current |
| `sql/migrations/0028_create_kds_capacity_commit_rpc.sql` | 18142 | — | — | sql | — | current |
| `sql/migrations/0029_create_kds_cooking_rpc.sql` | 20041 | — | — | sql | — | current |
| `sql/migrations/0030_create_manual_fallback_rpc.sql` | 14803 | — | — | sql | — | current |
| `sql/migrations/0032_create_agent_action_rpc.sql` | 18610 | — | — | sql | — | current |
| `sql/migrations/0034_seed_data.sql` | 16867 | — | — | sql | — | current |
| `sql/migrations/0035_verify_schema.sql` | 37300 | — | — | sql | — | current |
| `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` | 24001 | — | — | sql | — | current |
| `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` | 14177 | — | — | sql | — | current |
| `sql/migrations/0039_create_kds_bulk_commit_rpc.sql` | 14464 | — | — | sql | — | current |
| `sql/migrations/0040_create_local_ledger_replay_rpc.sql` | 20730 | — | — | sql | — | current |
| `sql/migrations/0042_create_delivery_order_intake_rpc.sql` | 24683 | — | — | sql | — | current |
| `sql/migrations/0043_create_did_display_rpc.sql` | 15793 | — | — | sql | — | current |
| `sql/migrations/0044_create_menu_management_rpc.sql` | 15705 | — | — | sql | — | current |
| `sql/migrations/0045_create_daily_summary_rpc.sql` | 19278 | — | — | sql | — | current |
| `sql/migrations/0046_create_context_builder_rpc.sql` | 17041 | — | — | sql | — | current |
| `sql/migrations/0047_create_device_registry_rpc.sql` | 21576 | — | — | sql | — | current |
| `sql/migrations/0048_create_table_management_rpc.sql` | 19867 | — | — | sql | — | current |
| `sql/migrations/0049_create_store_settings_rpc.sql` | 22119 | — | — | sql | — | current |
| `sql/migrations/0050_create_waiting_queue_rpc.sql` | 22496 | — | — | sql | — | current |
| `sql/migrations/0051_create_pre_order_rpc.sql` | 26047 | — | — | sql | — | current |
| `sql/migrations/0052_create_kiosk_session_rpc.sql` | 15154 | — | — | sql | — | current |
| `sql/migrations/0053_create_staff_management_rpc.sql` | 29987 | — | — | sql | — | current |
| `sql/migrations/0054_create_inventory_rpc.sql` | 28662 | — | — | sql | — | current |
| `sql/migrations/0056_create_van_integration_rpc.sql` | 27757 | — | — | sql | — | current |
| `sql/migrations/0057_create_delivery_platform_rpc.sql` | 24016 | — | — | sql | — | current |
| `sql/migrations/0061_create_ai_context_advanced_rpc.sql` | 29686 | — | — | sql | — | current |
| `sql/migrations/0062_create_i18n_error_diagnostics.sql` | 33171 | — | — | sql | — | current |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | 33457 | — | — | sql | — | current |
| `sql/migrations/0064_create_menu_i18n_allergen.sql` | 30680 | — | — | sql | — | current |
| `sql/migrations/0065_create_security_isolation_rpc.sql` | 40476 | — | — | sql | — | current |
| `sql/migrations/0066_create_ledger_integrity_rpc.sql` | 40550 | — | — | sql | — | current |
| `sql/migrations/0068_create_realtime_edge_rpc.sql` | 32456 | — | — | sql | — | current |
| `sql/migrations/0070_create_flutter_bootstrap_rpc.sql` | 31525 | — | — | sql | — | current |
| `sql/migrations/0071_create_edge_function_templates.sql` | 41254 | — | — | sql | — | current |
| `sql/migrations/0072_create_pg_cron_schedules.sql` | 27915 | — | — | sql | — | current |
| `sql/migrations/0073_final_verification.sql` | 37712 | — | — | sql | — | current |
| `sql/migrations/0074_create_pos_provider_registry.sql` | 56339 | — | — | sql | — | current |
| `sql/migrations/0075_create_pos_edge_function_handlers.sql` | 32406 | — | — | sql | — | current |
| `sql/migrations/0077_create_multistore_rpc.sql` | 42105 | — | — | sql | — | current |
| `sql/migrations/0078_create_delivery_sync_rpc.sql` | 40153 | — | — | sql | — | current |
| `sql/migrations/0079_create_did_advanced_rpc.sql` | 39928 | — | — | sql | — | current |
| `sql/migrations/0080_create_cms_content_rpc.sql` | 42599 | — | — | sql | — | current |
| `sql/migrations/0081_create_customer_app_rpc.sql` | 43193 | — | — | sql | — | current |
| `sql/migrations/0082_create_saas_billing_rpc.sql` | 40915 | — | — | sql | — | current |
| `sql/migrations/0083_create_push_notification_rpc.sql` | 33102 | — | — | sql | — | current |
| `sql/migrations/0085_create_franchise_os_foundation_rpc.sql` | 53184 | — | — | sql | — | current |
| `sql/migrations/0086_create_hq_menu_distribution_rpc.sql` | 36088 | — | — | sql | — | current |
| `sql/migrations/0087_create_multistore_policy_rpc.sql` | 52954 | — | — | sql | — | current |
| `sql/migrations/0088_create_ai_customer_center_rpc.sql` | 46754 | — | — | sql | — | current |
| `sql/migrations/0089_create_digital_sop_rag_rpc.sql` | 45652 | — | — | sql | — | current |
| `sql/migrations/0090_create_multitenant_isolation_rpc.sql` | 39421 | — | — | sql | — | current |
| `sql/migrations/0091_create_saas_readiness_final_rpc.sql` | 50223 | — | — | sql | — | current |
| `sql/migrations/0092_create_flutter_edge_function_guide_rpc.sql` | 33122 | — | — | sql | — | current |
| `sql/migrations/0093_create_message_catalog_complete.sql` | 46652 | — | — | sql | — | current |
| `sql/migrations/0094_fix_i18n_hardcoded_strings.sql` | 31366 | — | — | sql | — | current |
| `sql/migrations/0095_create_pgcron_monitoring_rpc.sql` | 45563 | — | — | sql | — | current |
| `sql/migrations/0096_schema_final_validation.sql` | 20849 | — | — | sql | — | current |
| `sql/migrations/0097_create_auth_login_pipeline_rpc.sql` | 52792 | — | — | sql | — | current |
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | 52253 | — | — | sql | — | current |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | 36034 | — | — | sql | — | current |
| `sql/migrations/0100_create_staff_app_bootstrap_rpc.sql` | 32622 | — | — | sql | — | current |
| `sql/migrations/0101_create_project_background_docs.sql` | 2813 | — | — | sql | — | current |
| `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql` | 40521 | — | — | sql | — | current |
| `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | 42103 | — | — | sql | — | current |
| `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql` | 37062 | — | — | sql | — | current |
| `sql/migrations/0105_create_cash_receipt_pipeline_rpc.sql` | 34248 | — | — | sql | — | current |
| `sql/migrations/0106_create_delivery_platform_pipeline_rpc.sql` | 42448 | — | — | sql | — | current |
| `sql/migrations/0107_create_mini_cms_pipeline_rpc.sql` | 43841 | — | — | sql | — | current |
| `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` | 43755 | — | — | sql | — | current |
| `sql/migrations/0110_create_store_admin_rpc.sql` | 57532 | — | — | sql | — | current |
| `sql/migrations/0111_create_franchise_admin_rpc.sql` | 33105 | — | — | sql | — | current |
| `sql/migrations/0113_create_api_spec_docs.sql` | 34259 | — | — | sql | — | current |
| `sql/migrations/0114_create_mini_kiosk_pipeline_rpc.sql` | 44968 | — | — | sql | — | current |
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | 53373 | — | — | sql | — | current |
| `sql/migrations/0116_create_customer_app_bootstrap_rpc.sql` | 30362 | — | — | sql | — | current |
| `sql/migrations/0117_create_did_pipeline_rpc.sql` | 15954 | — | — | sql | — | current |
| `sql/migrations/0118_create_schema_validation_update.sql` | 14990 | — | — | sql | — | current |
| `sql/migrations/0119_create_edge_function_integration.sql` | 14402 | — | — | sql | — | current |
| `sql/migrations/0121_create_security_pipeline.sql` | 44129 | — | — | sql | — | current |
| `sql/migrations/0122_create_coupon_pipeline_rpc.sql` | 18748 | — | — | sql | — | current |
| `sql/migrations/0123_create_ai_customer_center_v2.sql` | 18633 | — | — | sql | — | current |
| `sql/migrations/0125_create_franchise_os_extension.sql` | 36002 | — | — | sql | — | current |
| `sql/migrations/0126_create_staff_notification_pipeline.sql` | 26851 | — | — | sql | — | current |
| `sql/migrations/0129_create_launch_readiness_package.sql` | 26563 | — | — | sql | — | current |
| `sql/migrations/0131_create_advanced_staff_permission.sql` | 26419 | — | — | sql | — | current |
| `sql/migrations/0132_create_device_registry_enhanced.sql` | 20681 | — | — | sql | — | current |
| `sql/migrations/0133_create_final_validation_package.sql` | 23962 | — | — | sql | — | current |
| `sql/migrations/0134_create_technology_credit_package.sql` | 20478 | — | — | sql | — | current |
| `sql/migrations/0135_create_flutter_mvp_start_package.sql` | 13074 | — | — | sql | — | current |
| `sql/migrations/0136_create_dev_audit_log.sql` | 15209 | — | — | sql | — | current |
| `sql/migrations/0137_patch_missing_functions.sql` | 23528 | — | — | sql | — | current |
| `sql/migrations/0138_patch_integration_functions.sql` | 22437 | — | — | sql | — | current |
| `sql/migrations/0139_create_ai_inference_log.sql` | 15998 | — | — | sql | — | current |
| `sql/migrations/0140_widen_error_domain_constraint.sql` | 1740 | — | — | sql | — | current |
| `sql/migrations/0141_hyper_personalization_menu_customization.sql` | 14055 | — | — | sql | — | current |
| `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` | 12064 | — | — | sql | — | current |
| `sql/migrations/0143_add_no_payment_kds_release_policy.sql` | 9533 | — | — | sql | — | current |
| `sql/migrations/0145_widen_error_domain_constraint_membership_security_ai.sql` | 1874 | — | — | sql | — | current |
| `sql/migrations/0146_widen_document_type_and_domain_constraints.sql` | 2540 | — | — | sql | — | current |
| `sql/migrations/0148_add_order_sessions_customer_id_and_guest_flag.sql` | 3437 | — | — | sql | — | current |
| `sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql` | 19006 | — | — | sql | — | current |
| `sql/migrations/0150_widen_event_domain_constraint.sql` | 1507 | — | — | sql | — | current |
| `sql/migrations/0151_create_check_kds_capacity_function.sql` | 4213 | — | — | sql | — | current |
| `sql/migrations/0152_add_orders_pickup_ready_timing_columns.sql` | 1389 | — | — | sql | — | current |
| `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql` | 1098 | — | — | sql | — | current |
| `sql/migrations/0154_drop_mark_payment_uncertain_legacy_overload.sql` | 1600 | — | — | sql | — | current |
| `sql/migrations/0155_drop_get_did_display_state_legacy_overload.sql` | 1550 | — | — | sql | — | current |
| `sql/migrations/0156_add_did_device_edid_mapping.sql` | 5705 | — | — | sql | — | current |
| `sql/migrations/0157_authorize_kds_release_overload_and_redesign.sql` | 10652 | — | — | sql | — | current |
| `sql/migrations/0158_confirm_payment_intent_linkage_fix.sql` | 8156 | — | — | sql | — | current |
| `sql/migrations/0159_fix_payment_intent_idempotency_key_race.sql` | 7336 | — | — | sql | — | current |
| `sql/migrations/0160_call_waiting_customer_contract_recovery.sql` | 11786 | — | — | sql | — | current |
| `sql/migrations/0161_mark_no_show_overload_and_redesign.sql` | 19774 | — | — | sql | — | current |
| `sql/migrations/0162_create_dining_table_admin_rpc.sql` | 16086 | — | — | sql | — | current |
| `sql/migrations/0163_seat_waiting_customer_facade_correction.sql` | 13629 | — | — | sql | — | current |
| `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql` | 17451 | — | — | sql | — | current |
| `sql/migrations/0165_menu_price_list_architecture_phase0.sql` | 11319 | — | — | sql | — | current |
| `sql/migrations/0166_canonical_kds_release_orchestration.sql` | 14517 | — | — | sql | — | current |
| `sql/migrations/0167_record_waiting_call_grant_correction.sql` | 724 | — | — | sql | — | current |
| `sql/migrations/CHANGELOG.md` | 34047 | — | sql/migrations Changelog | md | — | current |
| `sql/migrations/seed_yoonsul_menu.sql` | 34871 | — | — | sql | — | current |
| `sql/scratch/cursor_blind_audit_call_waiting_customer_verify.sql` | 3390 | — | — | sql | — | scratch_noncanonical |
| `sql/scratch/cursor_blind_audit_call_waiting_customer_verify2.sql` | 4390 | — | — | sql | — | scratch_noncanonical |
| `sql/scratch/fable_pass_a/03_waiting_600600_input_package.md` | 202958 | — | Fable Pass A Input Package — 3순위: 600600 대기열/주문 (Waiting/Order) | md | — | scratch_noncanonical |
| `sql/scratch/fable_pass_a/03_waiting_600600_migrations_concat.sql` | 257307 | — | — | sql | — | scratch_noncanonical |
| `sql/scratch/fable_pass_a/05_kds_did_600400_input_package.md` | 135519 | — | Fable Pass A Input Package — 5순위: 600400 KDS/DID | md | — | scratch_noncanonical |
| `sql/scratch/fable_pass_a/05_kds_did_600400_migrations_concat.sql` | 186365 | — | — | sql | — | scratch_noncanonical |
| `sql/scratch/fable_pass_a/600600_slices/00_waiting_slices_manifest.md` | 1355 | — | Fable Pass A — 600600 Waiting Domain (5-Slice Split) | md | 600600_slices | scratch_noncanonical |
| `sql/scratch/fable_pass_a/600600_slices/slice_01_waiting_queue_input_package.md` | 28124 | — | Fable Pass A — 600600 slice_01 — Waiting Queue (register_waiting / queue_position) | md | 600600_slices | scratch_noncanonical |
| `sql/scratch/fable_pass_a/600600_slices/slice_01_waiting_queue_migrations_concat.sql` | 113794 | — | — | sql | 600600_slices | scratch_noncanonical |
| `sql/scratch/fable_pass_a/600600_slices/slice_04_pre_order_order_session_input_package.md` | 102358 | — | Fable Pass A — 600600 slice_04 — Pre-Order / Order Session body | md | 600600_slices | scratch_noncanonical |
| `sql/scratch/fable_pass_a/600600_slices/slice_04_pre_order_order_session_migrations_concat.sql` | 134541 | — | — | sql | 600600_slices | scratch_noncanonical |
| `sql/scratch/fable_pass_a/600600_slices/verify_pre_order_while_waiting_live.sql` | 8420 | — | — | sql | 600600_slices | scratch_noncanonical |
| `sql/scratch/fable_pass_a/build_waiting_slices.py` | 12621 | — | — | py | — | scratch_noncanonical |