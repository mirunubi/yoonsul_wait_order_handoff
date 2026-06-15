# Migration Final Docs Tree Validation Scan Report

Generated: 2026-06-15T17:58:39.270878+00:00

## Summary

- **Files scanned:** 1054
- **Canonical compliant (xxxxx_DocumentType_Title):** 970
- **Non-compliant filenames (total):** 84
  - Critical violations (spaces, missing prefix, etc.): 5
  - Missing/unapproved DocumentType: 64
  - Governance reserved non-canonical (00000~00099): 15
- **Root Markdown outside 00000~00099:** 43
- **Duplicate prefix groups:** 0
- **Heading mismatches (stem vs first heading):** 131
- **Paths >220:** 0
- **Paths >240:** 0
- **Folders with cross-band files:** 9
- **Exception files (focused):** 254
- **00005 index paths missing on disk:** 347
- **00005 on-disk paths missing from index:** 468
- **00007 dirmap paths in tree:** 926
- **00007 dirmap paths missing on disk:** 911
- **00007 on-disk paths missing from dirmap:** 1036

## Critical Filename Violations

- `docs\05170 PAYCO POS Integration Implementation Approach And Official Verification Policy.md` — contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy.md` — contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\08100 High Risk Store Operation Foundation Readiness Check And Cross Runtime Handoff.md` — contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\09090 Cross Range Closure Readiness Check And Next Documentation Phase Gate.md` — contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\Foundation I18n Content Registry SOP Parsing And Multilingual Runtime Policy.md` — contains_spaces, missing_or_invalid_five_digit_prefix

## Missing Or Unapproved DocumentType

- `docs\00100_project_foundation\00110_Project_Identity_And_Overview.md` — token `Project`
- `docs\00100_project_foundation\00120_BM_Patent_Linkage.md` — token `BM`
- `docs\00100_project_foundation\00200_Organization_Core_MVP_Cutline.md` — token `Organization`
- `docs\01000_mvp_scope\01010_MVP_Scope.md` — token `MVP`
- `docs\01000_mvp_scope\01020_Store_Type_And_Product_Package_Strategy.md` — token `Store`
- `docs\01000_mvp_scope\01030_Competitive_Positioning_And_Market_Context.md` — token `Competitive`
- `docs\01000_mvp_scope\01060_MVP_Store_Type_Adoption_Sequence.md` — token `MVP`
- `docs\01000_mvp_scope\01070_CatchMenu_Service_Concept.md` — token `CatchMenu`
- `docs\01000_mvp_scope\01170_Stage_0_Unconfirmed_Request_Warning_And_Forced_Cleanup.md` — token `Stage`
- `docs\01000_mvp_scope\01180_Stage_0_Translation_And_Critical_Request_Handling.md` — token `Stage`
- `docs\01000_mvp_scope\01210_CatchMenu_Stage_0A_QR_Menu_And_Show_To_Staff_Flow.md` — token `CatchMenu`
- `docs\01000_mvp_scope\01220_CatchMenu_Stage_0B_Send_To_Store_Request_Flow.md` — token `CatchMenu`
- `docs\01000_mvp_scope\01260_CatchMenu_POS_Less_Request_State_Transition_Guard.md` — token `CatchMenu`
- `docs\03000_saas_runtime\03010_Tenant_Store_Runtime_And_Package_Model.md` — token `Tenant`
- `docs\03000_saas_runtime\03020_Tenant_Company_Legal_Operating_Group_Context_Model.md` — token `Tenant`
- `docs\03000_saas_runtime\03030_Store_Runtime_Profile_Model.md` — token `Store`
- `docs\04000_store_runtime_pos_kds_operations\04000_kds_integration_kitchen_continuity\04090_KDS_Integration_Kitchen_Continuity_MVP_Cutline.md` — token `KDS`
- `docs\04000_store_runtime_pos_kds_operations\04100_menu_availability_soldout_runtime\04190_Menu_Availability_Soldout_MVP_Cutline.md` — token `Menu`
- `docs\05000_customer_handoff_and_implementation_readiness\05100_implementation_readiness_and_provider_verification\05105_Plan_10807_Root_File_Rename_And_Move.md` — token `Plan`
- `docs\07000_admin_console\07010_Admin_Console_Context_And_Role_Model.md` — token `Admin`
- `docs\07000_admin_console\07020_Admin_Store_Runtime_Configuration_Model.md` — token `Admin`
- `docs\07000_admin_console\07030_Admin_Operational_Monitoring_And_Recovery_Model.md` — token `Admin`
- `docs\07000_admin_console\07040_Admin_Screen_Inventory_And_Navigation_Model.md` — token `Admin`
- `docs\07000_admin_console\07050_Admin_Approval_Workflow_Model.md` — token `Admin`
- `docs\07000_admin_console\07070_Admin_Context_Navigation_And_Scope_Model.md` — token `Admin`
- `docs\07000_admin_console\07090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md` — token `Admin`
- `docs\07000_admin_console\07100_Admin_Audit_Review_And_Change_History_Model.md` — token `Admin`
- `docs\08000_ai_customer_center\08001_AI_Customer_Center_Foundation.md` — token `AI`
- `docs\08000_ai_customer_center\08400_CatchMenu_Troubleshooting_Foundation.md` — token `CatchMenu`
- `docs\08000_ai_customer_center\08600_Support_Server_Strategy.md` — token `Support`
- `docs\08000_ai_customer_center\08700_Scale_Out_Strategy.md` — token `Scale`
- `docs\09000_data_model_state_machine\09010_Data_Model_Draft.md` — token `Data`
- `docs\09000_data_model_state_machine\09020_Handoff_State_Machine.md` — token `Handoff`
- `docs\09000_data_model_state_machine\09030_Conceptual_Entity_Master.md` — token `Conceptual`
- `docs\09000_data_model_state_machine\09040_State_And_Event_Ownership_Model.md` — token `State`
- `docs\09000_data_model_state_machine\09070_Context_Entity_Alignment_Model.md` — token `Context`
- `docs\09000_data_model_state_machine\09080_Runtime_Profile_And_Change_Request_Entity_Model.md` — token `Runtime`
- `docs\09000_data_model_state_machine\09090_Order_Candidate_And_Confirmation_State_Refinement.md` — token `Order`
- `docs\09000_data_model_state_machine\09100_Admin_Support_Audit_Entity_Lineage_Model.md` — token `Admin`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_foundation_static_catalog_package\10005_Plan_10712_Root_File_Rename_And_Move.md` — token `Plan`
- `docs\11000_integration_boundary\11250_POS_Integration_Module_And_All_POS_Expansion_Strategy.md` — token `POS`
- `docs\13000_app_api_projection\13010_App_Surface_And_Channel_Projection.md` — token `App`
- `docs\13000_app_api_projection\13020_Customer_Webapp_Projection.md` — token `Customer`
- `docs\13000_app_api_projection\13030_Store_Console_Projection.md` — token `Store`
- `docs\13000_app_api_projection\13040_Admin_Console_Projection.md` — token `Admin`
- `docs\13000_app_api_projection\13090_Surface_To_Authority_Projection_Model.md` — token `Surface`
- `docs\13000_app_api_projection\13110_Idempotency_Recovery_And_Audit_Envelope_Projection.md` — token `Idempotency`
- `docs\15000_membership_loyalty\15020_Lightweight_Coupon_And_Stamp_Future_Model.md` — token `Lightweight`
- `docs\15000_membership_loyalty\15050_Membership_Admin_And_UI_Reserved_Surface.md` — token `Membership`
- `docs\17000_ui_screen_composition\17010_Customer_Webapp_UI_Composition.md` — token `Customer`
- `docs\17000_ui_screen_composition\17020_Mini_Kiosk_UI_Composition.md` — token `Mini`
- `docs\17000_ui_screen_composition\17030_Store_Console_UI_Composition.md` — token `Store`
- `docs\17000_ui_screen_composition\17040_Admin_Console_UI_Composition.md` — token `Admin`
- `docs\17000_ui_screen_composition\17050_Support_Console_UI_Composition.md` — token `Support`
- `docs\17000_ui_screen_composition\17080_UI_Surface_To_Authority_Composition_Model.md` — token `UI`
- `docs\17000_ui_screen_composition\17090_Integration_Status_UI_Wording_Model.md` — token `Integration`
- `docs\17000_ui_screen_composition\17110_Customer_MiniKiosk_State_Wording_Consolidation.md` — token `Customer`
- `docs\17000_ui_screen_composition\17120_Admin_Support_UI_Authority_And_Recovery_Model.md` — token `Admin`
- `docs\21000_financial_security_monitoring_catalog\21630_Financial-Grade_Security_Monitoring_Foundation_Catalog_Execution_Plan_And_Artifact_Map.md` — token `Financial-Grade`
- `docs\21000_financial_security_monitoring_catalog\21644_Patent_Security_Monitoring_Architecture_Summary_And_Claim_Support_Feature_Map.md` — token `Patent`
- `docs\28000_future_expansion\28020_Membership_Loyalty_Point_Future_Model.md` — token `Membership`
- `docs\28000_future_expansion\28040_Data_Ad_CRM_AI_Future_Expansion_Model.md` — token `Data`
- `docs\28000_future_expansion\28060_Franchise_Intelligence_Feedback_Loop_Model.md` — token `Franchise`
- `docs\30000_future_saas_modules\30090_Dual_Track_External_Alliance_And_Native_Service_Strategy.md` — token `Dual`

## Root Markdown Outside Governance (00000~00099)

- `docs\05170 PAYCO POS Integration Implementation Approach And Official Verification Policy.md`
- `docs\05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy.md`
- `docs\06440_WorkPackage_Store_Runtime_KDS_Kitchen_Ticket_Preparation_Remake_Ready_Served_And_Manual_Kitchen_Continuity.md`
- `docs\06470_WorkPackage_Store_Runtime_Inventory_Soldout_Menu_Availability_Kitchen_Production_Signal_And_Exception_Control.md`
- `docs\06540_Policy_Entrance_Customer_Notification_Call_Message_Status_Display_Multilingual_Guidance_And_Evidence_Control.md`
- `docs\06620_Policy_Customer_Runtime_Evidence_Packet_Audit_Trail_Cross_Flow_Traceability_Closeout_Handoff_And_Governance.md`
- `docs\06700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`
- `docs\06710_SOP_Customer_Runtime_Waiting_Call_No_Show_Recovery_And_Staff_Correction_Operation.md`
- `docs\06720_SOP_Customer_Runtime_Table_Matching_Preorder_Link_And_Service_Context_Operation.md`
- `docs\06730_SOP_Customer_Runtime_Support_Dispute_Compensation_And_Privacy_Escalation_Operation.md`
- `docs\06740_Checklist_Customer_Runtime_Privacy_Consent_And_Link_Security_Preflight_Check.md`
- `docs\06750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`
- `docs\06760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`
- `docs\06770_Template_Customer_Runtime_Display_Status_Code_Action_Permission_Message_Binding_And_Evidence_Template.md`
- `docs\06780_Checklist_Customer_Runtime_Display_Surface_Status_Action_Message_Evidence_And_QA_Acceptance.md`
- `docs\06790_Runbook_Customer_Runtime_Display_QA_Execution_Defect_Retest_Acceptance_And_Rollout_Handoff.md`
- `docs\06800_Template_Customer_Runtime_Display_QA_Defect_Retest_Acceptance_Rollout_Handoff_And_Evidence_Record.md`
- `docs\06810_Register_Customer_Runtime_Display_QA_Defect_Retest_Waiver_Blocker_Rollout_And_Backlog_Control.md`
- `docs\06820_Index_Customer_Runtime_Display_Control_Message_Status_Action_QA_Defect_And_Rollout_Governance.md`
- `docs\06830_Spec_Customer_Runtime_Display_Status_Code_Registry_And_UI_State_Binding_Spec.md`
- `docs\06840_Spec_Customer_Runtime_Action_Permission_Button_Guard_And_Idempotency_Spec.md`
- `docs\06850_Spec_Customer_Runtime_Message_Template_Localization_Key_And_Versioning_Spec.md`
- `docs\06860_Spec_Customer_Runtime_Display_Evidence_Event_And_Audit_Schema_Spec.md`
- `docs\06870_Spec_Customer_Runtime_Error_Recovery_Stale_State_And_Safe_Fallback_Display_Spec.md`
- `docs\06880_SOP_Customer_Runtime_Display_Incident_Response_And_Emergency_Message_Disable_Operation.md`
- `docs\06890_Checklist_Customer_Runtime_Display_Release_Gate_And_Production_Preflight_Check.md`
- `docs\06900_Index_Customer_Runtime_Display_Implementation_Spec_Release_Gate_Handoff_And_Closeout_Governance.md`
- `docs\06910_Spec_Customer_Runtime_Display_Registry_Data_Model_And_Table_Candidate_Spec.md`
- `docs\06920_Spec_Customer_Runtime_Display_Event_Naming_Correlation_And_Evidence_Packet_Spec.md`
- `docs\06930_Spec_Customer_Runtime_Display_Feature_Flag_Emergency_Disable_And_Rollback_Control_Spec.md`
- `docs\06940_SOP_Customer_Runtime_Display_Registry_Change_Review_Approval_And_Version_Operation.md`
- `docs\08000_Index_High_Risk_Store_Operation_Foundation_README_And_Edge_Case_Constitution.md`
- `docs\08010_Policy_Alcohol_Sales_Adult_Verification_And_Legal_Sale_Boundary.md`
- `docs\08020_Policy_Alcohol_Order_Identity_Privacy_CI_DI_And_Verification_Evidence.md`
- `docs\08030_Policy_Table_Session_Alcohol_Add_On_Partial_Settlement_And_Mid_Meal_Payment.md`
- `docs\08040_Policy_Drunk_Customer_Mistouch_Misoperation_Confirmation_And_Staff_Intervention.md`
- `docs\08050_Policy_Night_Operation_Delivery_Platform_Concurrent_Order_Synchronization.md`
- `docs\08070_Policy_Alcohol_Payment_Refund_Dispute_Chargeback_And_Recovery_Evidence.md`
- `docs\08080_Policy_Minor_Access_Prevention_Verification_Failure_And_Incident_Response.md`
- `docs\08090_Policy_Night_Safety_Staff_Escalation_Abuse_Prevention_And_Store_Closure_Boundary.md`
- `docs\08100 High Risk Store Operation Foundation Readiness Check And Cross Runtime Handoff.md`
- `docs\09090 Cross Range Closure Readiness Check And Next Documentation Phase Gate.md`
- `docs\Foundation I18n Content Registry SOP Parsing And Multilingual Runtime Policy.md`

## Duplicate Prefix Groups

_None._

## Cross-Band Files By Folder

### `docs\04900_security_runtime_test_catalog` — 23 file(s)
- `docs\04900_security_runtime_test_catalog\05000_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog.md` (`05000` in `04900`)
- `docs\04900_security_runtime_test_catalog\05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog.md` (`05001` in `04900`)
- `docs\04900_security_runtime_test_catalog\05010_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog.md` (`05010` in `04900`)
- `docs\04900_security_runtime_test_catalog\05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog.md` (`05011` in `04900`)
- `docs\04900_security_runtime_test_catalog\05020_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog.md` (`05020` in `04900`)
- `docs\04900_security_runtime_test_catalog\05021_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog.md` (`05021` in `04900`)
- `docs\04900_security_runtime_test_catalog\05030_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog.md` (`05030` in `04900`)
- `docs\04900_security_runtime_test_catalog\05031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog.md` (`05031` in `04900`)
- `docs\04900_security_runtime_test_catalog\05040_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog.md` (`05040` in `04900`)
- `docs\04900_security_runtime_test_catalog\05041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog.md` (`05041` in `04900`)
- `docs\04900_security_runtime_test_catalog\05050_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md` (`05050` in `04900`)
- `docs\04900_security_runtime_test_catalog\05051_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md` (`05051` in `04900`)
- `docs\04900_security_runtime_test_catalog\05060_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog.md` (`05060` in `04900`)
- `docs\04900_security_runtime_test_catalog\05061_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog.md` (`05061` in `04900`)
- `docs\04900_security_runtime_test_catalog\05070_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog.md` (`05070` in `04900`)
_... and 8 more_

### `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review` — 5 file(s)
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05106_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff.md` (`05106` in `04999`)
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05111_Implementation_Readiness_Backlog_And_Test_Execution_Planning.md` (`05111` in `04999`)
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` (`05121` in `04999`)
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05131_Evidence_Packet_Template_And_Test_Result_Recording.md` (`05131` in `04999`)
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05141_Policy_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance.md` (`05141` in `04999`)

### `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow` — 5 file(s)
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md` (`06410` in `05000`)
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md` (`06510` in `05000`)
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md` (`06511` in `05000`)
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md` (`06520` in `05000`)
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md` (`06530` in `05000`)

### `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning` — 34 file(s)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09660_Policy_Catch_And_Order_SaaS_Runtime_Boundary_And_Module_Naming.md` (`09660` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09670_Policy_Catch_Menu_Customer_Surface_Projection_And_I18n_Naming.md` (`09670` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09680_Policy_Provider_Evidence_Collection_Template_And_Capability_Review.md` (`09680` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09690_Policy_Security_Monitoring_Foundation_README_Insert_And_Index_Patch.md` (`09690` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09700_Policy_Controlled_Non_Runtime_Catalog_Schema_Planning.md` (`09700` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09710_Policy_Controlled_Catalog_Registry_Handoff_And_Static_Reference_Package.md` (`09710` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09720_Boundary_Test_Matrix_Artifact_Planning_And_Review_Packet.md` (`09720` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09730_Policy_Provider_Evidence_Review_Packet_And_Capability_Acceptance_Matrix.md` (`09730` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09740_Policy_I18n_Message_Key_Registry_And_Customer_Visible_Text_Review.md` (`09740` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09750_Policy_Catch_And_Order_Status_Message_Catalog_And_Customer_Safe_State_Mapping.md` (`09750` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09760_Policy_Catch_Menu_Status_Surface_And_Order_Handoff_Message_Mapping.md` (`09760` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09770_Policy_Support_Admin_Visible_Message_Boundary_And_Review_Surface_Mapping.md` (`09770` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09780_Policy_Customer_Recovery_Message_Catalog_And_Compensation_Review_Boundary.md` (`09780` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09790_Policy_Compensation_Review_Authority_Matrix_And_Value_Recovery_Control.md` (`09790` in `10000`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09800_Policy_Value_Recovery_Evidence_Audit_And_Idempotency_Review_Packet.md` (`09800` in `10000`)
_... and 19 more_

### `docs\11000_integration_boundary` — 4 file(s)
- `docs\11000_integration_boundary\04400_Policy_Toss_Payments_MVP_Integration_Boundary.md` (`04400` in `11000`)
- `docs\11000_integration_boundary\04410_Policy_PAYCO_Payment_And_Order_Provider_MVP_Boundary.md` (`04410` in `11000`)
- `docs\11000_integration_boundary\04420_Policy_POS_Adapter_Runtime_Data_Object_And_Event_Family.md` (`04420` in `11000`)
- `docs\11000_integration_boundary\04430_Policy_OKPOS_And_Major_POS_Integration_Candidate.md` (`04430` in `11000`)

### `docs\12000_implementation_mapping` — 28 file(s)
- `docs\12000_implementation_mapping\04830_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy.md` (`04830` in `12000`)
- `docs\12000_implementation_mapping\04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff.md` (`04831` in `12000`)
- `docs\12000_implementation_mapping\04840_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` (`04840` in `12000`)
- `docs\12000_implementation_mapping\04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` (`04841` in `12000`)
- `docs\12000_implementation_mapping\04850_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy.md` (`04850` in `12000`)
- `docs\12000_implementation_mapping\04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping.md` (`04851` in `12000`)
- `docs\12000_implementation_mapping\04860_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping.md` (`04860` in `12000`)
- `docs\12000_implementation_mapping\04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping.md` (`04861` in `12000`)
- `docs\12000_implementation_mapping\04870_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping.md` (`04870` in `12000`)
- `docs\12000_implementation_mapping\04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping.md` (`04871` in `12000`)
- `docs\12000_implementation_mapping\04880_Policy_CI_DI_Identity_Linkage_Callback_Masking_And_Leakage_Response_Implementation_Mapping.md` (`04880` in `12000`)
- `docs\12000_implementation_mapping\04881_Policy_CI_DI_Identity_Linkage_Callback_Masking_And_Leakage_Response_Implementation_Mapping.md` (`04881` in `12000`)
- `docs\12000_implementation_mapping\04890_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping.md` (`04890` in `12000`)
- `docs\12000_implementation_mapping\04891_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping.md` (`04891` in `12000`)
- `docs\12000_implementation_mapping\04900_Policy_Device_Trust_Session_Revocation_Store_Runtime_And_Lost_Device_Implementation_Mapping.md` (`04900` in `12000`)
_... and 13 more_

### `docs\14000_pos_provider_integration_strategy` — 22 file(s)
- `docs\14000_pos_provider_integration_strategy\05255_Assessment_Store_POS_Adoption_Strategy_OKPOS_Ledger_And_Toss_Kiosk_Combination.md` (`05255` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05256_Assessment_Store_POS_Adoption_Strategy_OKPOS_Ledger_And_Toss_Kiosk_Combination.md` (`05256` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05260_Policy_Toss_Base_Strategy_And_OKPOS_Compatibility_Interface.md` (`05260` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05261_Policy_Toss_Base_Strategy_And_OKPOS_Compatibility_Interface.md` (`05261` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05270_Policy_Table_Order_POS_Ecosystem_Phase_2_And_Phase_3_Expansion_Roadmap.md` (`05270` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05271_Policy_Table_Order_POS_Ecosystem_Phase_2_And_Phase_3_Expansion_Roadmap.md` (`05271` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05280_Policy_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison.md` (`05280` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05281_Policy_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison.md` (`05281` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05290_Policy_Provider_Adapter_Boundary_And_Canonical_Event_Mapping.md` (`05290` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05291_Policy_Provider_Adapter_Boundary_And_Canonical_Event_Mapping.md` (`05291` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05310_Policy_First_Store_POS_Equipment_Decision_And_Provider_Procurement_Checklist.md` (`05310` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05320_Policy_Store_Vendor_Quote_Comparison_And_Adoption_Decision_Record.md` (`05320` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05330_Policy_Small_Kiosk_Vendor_Evaluation_And_Integration_Transparency.md` (`05330` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05340_Policy_Franchise_OS_Linked_POS_SaaS_Expansion_And_Hardware_Partner_Strategy.md` (`05340` in `14000`)
- `docs\14000_pos_provider_integration_strategy\05350_Policy_SaaS_Revenue_Model_Payment_Margin_And_Provider_Partnership_Boundary.md` (`05350` in `14000`)
_... and 7 more_

### `docs\14000_pos_provider_integration_strategy\archive_duplicate_review` — 11 file(s)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05150_Policy_Toss_POS_Official_Verification_Checklist_And_Integration_Evidence.md` (`05150` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05160_Policy_Controlled_Implementation_Entry_Gate_And_Build_Authorization.md` (`05160` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05170_Policy_PAYCO_POS_Integration_Implementation_Approach_And_Official_Verification.md` (`05170` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05180_Policy_POS_Payment_Provider_Integration_Priority_Matrix_And_Openness_Assessment.md` (`05180` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05190_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral.md` (`05190` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05200_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse.md` (`05200` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05210_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary.md` (`05210` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05220_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary.md` (`05220` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05230_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary.md` (`05230` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05240_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel.md` (`05240` in `14000`)
- `docs\14000_pos_provider_integration_strategy\archive_duplicate_review\05250_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md` (`05250` in `14000`)

### `docs\20000_validation_security_audit` — 53 file(s)
- `docs\20000_validation_security_audit\04440_Policy_Customer_Identifier_CI_DI_And_Sensitive_Identity_Protection.md` (`04440` in `20000`)
- `docs\20000_validation_security_audit\04450_Policy_POS_RPC_Communication_Security_And_Provider_Trust_Boundary.md` (`04450` in `20000`)
- `docs\20000_validation_security_audit\04460_Policy_POS_Webhook_Signature_Secret_Rotation_And_Credential_Isolation.md` (`04460` in `20000`)
- `docs\20000_validation_security_audit\04470_Policy_Financial_Grade_Security_Baseline_And_Secret_Coding.md` (`04470` in `20000`)
- `docs\20000_validation_security_audit\04471_Policy_Financial_Grade_Security_Baseline_And_Secret_Coding.md` (`04471` in `20000`)
- `docs\20000_validation_security_audit\04480_Policy_POS_KDS_RPC_Security_And_Trust_Boundary.md` (`04480` in `20000`)
- `docs\20000_validation_security_audit\04481_Policy_POS_KDS_RPC_Security_And_Trust_Boundary.md` (`04481` in `20000`)
- `docs\20000_validation_security_audit\04490_Policy_Degraded_Security_Recovery_And_Evidence_Boundary.md` (`04490` in `20000`)
- `docs\20000_validation_security_audit\04491_Policy_Degraded_Security_Recovery_And_Evidence_Boundary.md` (`04491` in `20000`)
- `docs\20000_validation_security_audit\04500_Policy_Secret_Rotation_Exposure_Response_And_Secure_Configuration.md` (`04500` in `20000`)
- `docs\20000_validation_security_audit\04501_Policy_Secret_Rotation_Exposure_Response_And_Secure_Configuration.md` (`04501` in `20000`)
- `docs\20000_validation_security_audit\04510_Policy_CI_DI_Identity_Linkage_Data_Protection_And_Leakage_Response.md` (`04510` in `20000`)
- `docs\20000_validation_security_audit\04511_Policy_CI_DI_Identity_Linkage_Data_Protection_And_Leakage_Response.md` (`04511` in `20000`)
- `docs\20000_validation_security_audit\04520_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session.md` (`04520` in `20000`)
- `docs\20000_validation_security_audit\04521_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session.md` (`04521` in `20000`)
_... and 38 more_

## Exception Files Summary (focused)

- `docs\00100_project_foundation\00110_Project_Identity_And_Overview.md` — no approved DocumentType (`Project`)
- `docs\00100_project_foundation\00120_BM_Patent_Linkage.md` — no approved DocumentType (`BM`)
- `docs\00100_project_foundation\00200_Organization_Core_MVP_Cutline.md` — no approved DocumentType (`Organization`)
- `docs\01000_mvp_scope\01010_MVP_Scope.md` — no approved DocumentType (`MVP`)
- `docs\01000_mvp_scope\01020_Store_Type_And_Product_Package_Strategy.md` — no approved DocumentType (`Store`)
- `docs\01000_mvp_scope\01030_Competitive_Positioning_And_Market_Context.md` — no approved DocumentType (`Competitive`)
- `docs\01000_mvp_scope\01060_MVP_Store_Type_Adoption_Sequence.md` — no approved DocumentType (`MVP`)
- `docs\01000_mvp_scope\01070_CatchMenu_Service_Concept.md` — no approved DocumentType (`CatchMenu`)
- `docs\01000_mvp_scope\01170_Stage_0_Unconfirmed_Request_Warning_And_Forced_Cleanup.md` — no approved DocumentType (`Stage`)
- `docs\01000_mvp_scope\01180_Stage_0_Translation_And_Critical_Request_Handling.md` — no approved DocumentType (`Stage`)
- `docs\01000_mvp_scope\01210_CatchMenu_Stage_0A_QR_Menu_And_Show_To_Staff_Flow.md` — no approved DocumentType (`CatchMenu`)
- `docs\01000_mvp_scope\01220_CatchMenu_Stage_0B_Send_To_Store_Request_Flow.md` — no approved DocumentType (`CatchMenu`)
- `docs\01000_mvp_scope\01260_CatchMenu_POS_Less_Request_State_Transition_Guard.md` — no approved DocumentType (`CatchMenu`)
- `docs\03000_saas_runtime\03010_Tenant_Store_Runtime_And_Package_Model.md` — no approved DocumentType (`Tenant`)
- `docs\03000_saas_runtime\03020_Tenant_Company_Legal_Operating_Group_Context_Model.md` — no approved DocumentType (`Tenant`)
- `docs\03000_saas_runtime\03030_Store_Runtime_Profile_Model.md` — no approved DocumentType (`Store`)
- `docs\04000_store_runtime_pos_kds_operations\04000_kds_integration_kitchen_continuity\04090_KDS_Integration_Kitchen_Continuity_MVP_Cutline.md` — no approved DocumentType (`KDS`)
- `docs\04000_store_runtime_pos_kds_operations\04100_menu_availability_soldout_runtime\04190_Menu_Availability_Soldout_MVP_Cutline.md` — no approved DocumentType (`Menu`)
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05106_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff.md` — cross-band `05106` in `04999_archive_duplicate_review`
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05111_Implementation_Readiness_Backlog_And_Test_Execution_Planning.md` — cross-band `05111` in `04999_archive_duplicate_review`
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` — cross-band `05121` in `04999_archive_duplicate_review`
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05131_Evidence_Packet_Template_And_Test_Result_Recording.md` — cross-band `05131` in `04999_archive_duplicate_review`
- `docs\04900_security_runtime_test_catalog\04999_archive_duplicate_review\05141_Policy_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance.md` — cross-band `05141` in `04999_archive_duplicate_review`
- `docs\04900_security_runtime_test_catalog\05000_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog.md` — cross-band `05000` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog.md` — cross-band `05001` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05010_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog.md` — cross-band `05010` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog.md` — cross-band `05011` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05020_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog.md` — cross-band `05020` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05021_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog.md` — cross-band `05021` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05030_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog.md` — cross-band `05030` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog.md` — cross-band `05031` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05040_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog.md` — cross-band `05040` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog.md` — cross-band `05041` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05050_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md` — cross-band `05050` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05051_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md` — cross-band `05051` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05060_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog.md` — cross-band `05060` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05061_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog.md` — cross-band `05061` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05070_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog.md` — cross-band `05070` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05071_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog.md` — cross-band `05071` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05080_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog.md` — cross-band `05080` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05081_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog.md` — cross-band `05081` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05090_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog.md` — cross-band `05090` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05091_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog.md` — cross-band `05091` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05095_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping.md` — cross-band `05095` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05096_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping.md` — cross-band `05096` in `04900_security_runtime_test_catalog`
- `docs\04900_security_runtime_test_catalog\05100_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff.md` — cross-band `05100` in `04900_security_runtime_test_catalog`
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md` — cross-band `06410` in `05000_customer_handoff_flow`
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md` — cross-band `06510` in `05000_customer_handoff_flow`
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md` — cross-band `06511` in `05000_customer_handoff_flow`
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md` — cross-band `06520` in `05000_customer_handoff_flow`
- `docs\05000_customer_handoff_and_implementation_readiness\05000_customer_handoff_flow\06530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md` — cross-band `06530` in `05000_customer_handoff_flow`
- `docs\05000_customer_handoff_and_implementation_readiness\05100_implementation_readiness_and_provider_verification\05105_Plan_10807_Root_File_Rename_And_Move.md` — no approved DocumentType (`Plan`)
- `docs\05170 PAYCO POS Integration Implementation Approach And Official Verification Policy.md` — critical filename violation: contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy.md` — critical filename violation: contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\07000_admin_console\07010_Admin_Console_Context_And_Role_Model.md` — no approved DocumentType (`Admin`)
- `docs\07000_admin_console\07020_Admin_Store_Runtime_Configuration_Model.md` — no approved DocumentType (`Admin`)
- `docs\07000_admin_console\07030_Admin_Operational_Monitoring_And_Recovery_Model.md` — no approved DocumentType (`Admin`)
- `docs\07000_admin_console\07040_Admin_Screen_Inventory_And_Navigation_Model.md` — no approved DocumentType (`Admin`)
- `docs\07000_admin_console\07050_Admin_Approval_Workflow_Model.md` — no approved DocumentType (`Admin`)
- `docs\07000_admin_console\07070_Admin_Context_Navigation_And_Scope_Model.md` — no approved DocumentType (`Admin`)
- `docs\07000_admin_console\07090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md` — no approved DocumentType (`Admin`)
- `docs\07000_admin_console\07100_Admin_Audit_Review_And_Change_History_Model.md` — no approved DocumentType (`Admin`)
- `docs\08000_ai_customer_center\08001_AI_Customer_Center_Foundation.md` — no approved DocumentType (`AI`)
- `docs\08000_ai_customer_center\08400_CatchMenu_Troubleshooting_Foundation.md` — no approved DocumentType (`CatchMenu`)
- `docs\08000_ai_customer_center\08600_Support_Server_Strategy.md` — no approved DocumentType (`Support`)
- `docs\08000_ai_customer_center\08700_Scale_Out_Strategy.md` — no approved DocumentType (`Scale`)
- `docs\08100 High Risk Store Operation Foundation Readiness Check And Cross Runtime Handoff.md` — critical filename violation: contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\09000_data_model_state_machine\09010_Data_Model_Draft.md` — no approved DocumentType (`Data`)
- `docs\09000_data_model_state_machine\09020_Handoff_State_Machine.md` — no approved DocumentType (`Handoff`)
- `docs\09000_data_model_state_machine\09030_Conceptual_Entity_Master.md` — no approved DocumentType (`Conceptual`)
- `docs\09000_data_model_state_machine\09040_State_And_Event_Ownership_Model.md` — no approved DocumentType (`State`)
- `docs\09000_data_model_state_machine\09070_Context_Entity_Alignment_Model.md` — no approved DocumentType (`Context`)
- `docs\09000_data_model_state_machine\09080_Runtime_Profile_And_Change_Request_Entity_Model.md` — no approved DocumentType (`Runtime`)
- `docs\09000_data_model_state_machine\09090_Order_Candidate_And_Confirmation_State_Refinement.md` — no approved DocumentType (`Order`)
- `docs\09000_data_model_state_machine\09100_Admin_Support_Audit_Entity_Lineage_Model.md` — no approved DocumentType (`Admin`)
- `docs\09090 Cross Range Closure Readiness Check And Next Documentation Phase Gate.md` — critical filename violation: contains_spaces, missing_or_invalid_five_digit_prefix
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_foundation_static_catalog_package\10005_Plan_10712_Root_File_Rename_And_Move.md` — no approved DocumentType (`Plan`)
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09660_Policy_Catch_And_Order_SaaS_Runtime_Boundary_And_Module_Naming.md` — cross-band `09660` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09670_Policy_Catch_Menu_Customer_Surface_Projection_And_I18n_Naming.md` — cross-band `09670` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09680_Policy_Provider_Evidence_Collection_Template_And_Capability_Review.md` — cross-band `09680` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09690_Policy_Security_Monitoring_Foundation_README_Insert_And_Index_Patch.md` — cross-band `09690` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09700_Policy_Controlled_Non_Runtime_Catalog_Schema_Planning.md` — cross-band `09700` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09710_Policy_Controlled_Catalog_Registry_Handoff_And_Static_Reference_Package.md` — cross-band `09710` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09720_Boundary_Test_Matrix_Artifact_Planning_And_Review_Packet.md` — cross-band `09720` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09730_Policy_Provider_Evidence_Review_Packet_And_Capability_Acceptance_Matrix.md` — cross-band `09730` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09740_Policy_I18n_Message_Key_Registry_And_Customer_Visible_Text_Review.md` — cross-band `09740` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09750_Policy_Catch_And_Order_Status_Message_Catalog_And_Customer_Safe_State_Mapping.md` — cross-band `09750` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09760_Policy_Catch_Menu_Status_Surface_And_Order_Handoff_Message_Mapping.md` — cross-band `09760` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09770_Policy_Support_Admin_Visible_Message_Boundary_And_Review_Surface_Mapping.md` — cross-band `09770` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09780_Policy_Customer_Recovery_Message_Catalog_And_Compensation_Review_Boundary.md` — cross-band `09780` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09790_Policy_Compensation_Review_Authority_Matrix_And_Value_Recovery_Control.md` — cross-band `09790` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09800_Policy_Value_Recovery_Evidence_Audit_And_Idempotency_Review_Packet.md` — cross-band `09800` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09810_Policy_Value_Recovery_Reconciliation_And_Partial_Execution_Closure.md` — cross-band `09810` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09820_Policy_Value_Recovery_Rollback_Reversal_And_Customer_Correction_Notice.md` — cross-band `09820` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09830_Policy_Non_Reversible_Value_Action_And_Preventive_Control_Escalation.md` — cross-band `09830` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09840_Policy_High_Risk_Compensation_Escalation_And_Franchise_Policy_Inheritance_Boundary.md` — cross-band `09840` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09850_Policy_Mass_Recovery_Event_Grouping_And_Customer_Communication_Control.md` — cross-band `09850` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09860_Policy_Mass_Recovery_Root_Cause_Evidence_Packet_And_Recurrence_Prevention.md` — cross-band `09860` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09870_Policy_Mass_Recovery_Closure_Decision_And_Incident_Learning_Handoff.md` — cross-band `09870` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09880_Boundary_Incident_Learning_Test_Matrix_Update_And_Policy_Patch_Handoff.md` — cross-band `09880` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09890_Policy_Post_Incident_Coding_Readiness_Review_And_Controlled_Implementation_Gate.md` — cross-band `09890` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09900_Policy_Controlled_Implementation_Candidate_Template_And_First_Package_Selection.md` — cross-band `09900` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09910_Policy_Static_Security_Monitoring_Catalog_Registry_Handoff_And_Coding_Authorization_Draft.md` — cross-band `09910` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09920_Boundary_Test_Matrix_Static_Package_Handoff_And_Validation_Mapping.md` — cross-band `09920` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09930_Policy_Provider_Evidence_Registry_Static_Package_Handoff_And_Capability_Traceability.md` — cross-band `09930` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09940_Policy_I18n_Message_Key_Registry_Static_Package_Handoff_And_Locale_Review.md` — cross-band `09940` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09950_Policy_Catch_Menu_Status_Catalog_Static_Package_Handoff_And_Customer_Safe_Surface.md` — cross-band `09950` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09960_Policy_Catch_And_Order_Status_Catalog_Static_Package_Handoff_And_Order_Handoff_Safe_State.md` — cross-band `09960` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09970_Policy_Support_Admin_Boundary_Catalog_Static_Package_Handoff_And_Review_Surface.md` — cross-band `09970` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09980_Policy_Recovery_Compensation_Catalog_Static_Package_Handoff_And_Value_Authority_Mapping.md` — cross-band `09980` in `10000_static_catalog_runtime_planning`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_static_catalog_runtime_planning\09990_Policy_AI_pgvector_Governance_Catalog_Static_Package_Handoff_And_Non_Authority_Boundary.md` — cross-band `09990` in `10000_static_catalog_runtime_planning`
- `docs\11000_integration_boundary\04400_Policy_Toss_Payments_MVP_Integration_Boundary.md` — cross-band `04400` in `11000_integration_boundary`
- `docs\11000_integration_boundary\04410_Policy_PAYCO_Payment_And_Order_Provider_MVP_Boundary.md` — cross-band `04410` in `11000_integration_boundary`
- `docs\11000_integration_boundary\04420_Policy_POS_Adapter_Runtime_Data_Object_And_Event_Family.md` — cross-band `04420` in `11000_integration_boundary`
- `docs\11000_integration_boundary\04430_Policy_OKPOS_And_Major_POS_Integration_Candidate.md` — cross-band `04430` in `11000_integration_boundary`
- `docs\11000_integration_boundary\11250_POS_Integration_Module_And_All_POS_Expansion_Strategy.md` — no approved DocumentType (`POS`)
- `docs\12000_implementation_mapping\04830_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy.md` — cross-band `04830` in `12000_implementation_mapping`
- `docs\12000_implementation_mapping\04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff.md` — cross-band `04831` in `12000_implementation_mapping`
- `docs\12000_implementation_mapping\04840_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` — cross-band `04840` in `12000_implementation_mapping`
- `docs\12000_implementation_mapping\04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` — cross-band `04841` in `12000_implementation_mapping`
_... and 134 more_

## Heading Mismatches

Total: 131 (legacy human-readable headings predominate)

## Path Length

- Paths >220: 0
- Paths >240: 0

## 00005 / 00007 Governance Drift

### 00005 stale index paths (sample)

- `docs\04000_store_runtime_pos_kds_operations\04300_pos_provider_adapter_governance\04400_Policy_Toss_Payments_MVP_Integration_Boundary.md`
- `docs\04000_store_runtime_pos_kds_operations\04300_pos_provider_adapter_governance\04410_Policy_PAYCO_Payment_And_Order_Provider_MVP_Boundary.md`
- `docs\04000_store_runtime_pos_kds_operations\04300_pos_provider_adapter_governance\04420_Policy_POS_Adapter_Runtime_Data_Object_And_Event_Family.md`
- `docs\04000_store_runtime_pos_kds_operations\04300_pos_provider_adapter_governance\04430_Policy_OKPOS_And_Major_POS_Integration_Candidate.md`
- `docs\05000_customer_handoff_and_implementation_readiness\05100_implementation_readiness_and_provider_verification\11100_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral.md`
- `docs\05000_customer_handoff_and_implementation_readiness\05200_pos_payment_provider_and_kiosk_reuse\11110_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse.md`
- `docs\05000_customer_handoff_and_implementation_readiness\05200_pos_payment_provider_and_kiosk_reuse\11120_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary.md`
- `docs\05000_customer_handoff_and_implementation_readiness\05200_pos_payment_provider_and_kiosk_reuse\11130_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary.md`
- `docs\05000_customer_handoff_and_implementation_readiness\05200_pos_payment_provider_and_kiosk_reuse\11140_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary.md`
- `docs\05000_customer_handoff_and_implementation_readiness\05200_pos_payment_provider_and_kiosk_reuse\11150_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel.md`
- `docs\05000_customer_handoff_and_implementation_readiness\05200_pos_payment_provider_and_kiosk_reuse\11160_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10000_foundation_static_catalog_package\10005_Plan_40013_Root_File_Rename_And_Move.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\10700_security_trust_and_smart_order_control\40006_Index_Security_And_Trust_Foundation.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10721_Policy_Alcohol_Age_Gate_Legal_Notice_And_Staff_Verification_SOP.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10722_Policy_Refund_Cancellation_No_Show_Notice_And_Dispute_Evidence_SOP.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10723_Policy_Legal_Notice_I18n_Review_And_Controlled_Translation.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10724_Policy_Legal_Notice_Admin_Toggle_Permission_And_HQ_Lock.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10725_Policy_Legal_Notice_Static_Seed_Review_And_Approval_Workflow.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10726_Policy_Legal_Notice_Evidence_Export_Support_And_Dispute_Packet.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10727_Policy_Legal_Notice_Customer_Display_UX_And_Popup_Fatigue_Control.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10728_Policy_Legal_Notice_Emergency_Lock_And_Regulatory_Change_Response.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10729_Policy_Legal_Notice_Static_Registry_Closure_And_Runtime_Deferral.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10730_Policy_Legal_Notice_Evidence_Packet_Static_Field_Map.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10731_Policy_Customer_Notice_Center_UX_Static_Surface_Index.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10732_Policy_Regulatory_Change_Watchlist_And_Legal_Notice_Review_Queue.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10733_Policy_Legal_Notice_Admin_Checklist_And_Store_Onboarding_Review.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10734_Policy_Legal_Notice_Support_Playbook_And_Case_Reason_Code.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10735_Policy_Legal_Notice_Static_Registry_Readiness_Check.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\10736_Policy_Legal_Notice_Implementation_Authorization_Draft.md`
- `docs\10000_runtime_foundation_and_cross_room_architecture\40021_legal_notice_sop_and_regulatory_control\40021_Readme_Legal_Notice_SOP_And_Regulatory_Control.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review)50_Policy_Toss_POS_Official_Verification_Checklist_And_Integration_Evidence.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review)60_Policy_Controlled_Implementation_Entry_Gate_And_Build_Authorization.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review)70_Policy_PAYCO_POS_Integration_Implementation_Approach_And_Official_Verification.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review)80_Policy_POS_Payment_Provider_Integration_Priority_Matrix_And_Openness_Assessment.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review)90_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review*00_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review*10_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review*20_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review*30_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary.md`
- `docs`00_pos_provider_integration_strategyrchive_duplicate_review*40_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel.md`
_... and 307 more_

### 00007 stale dirmap paths (sample)

- `docs\00100_Readme_Project_Foundation.md`
- `docs\00110_Project_Identity_And_Overview.md`
- `docs\00120_BM_Patent_Linkage.md`
- `docs\00130_Boundary_Non_Implementation.md`
- `docs\00140_Readme_Organization_Core.md`
- `docs\00150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md`
- `docs\00160_Policy_Internal_Team_Role_And_Responsibility.md`
- `docs\00170_Policy_Merchant_Account_Company_And_Store_Context.md`
- `docs\00180_Policy_Operator_Assignment_And_Backup_Responsibility.md`
- `docs\00190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md`
- `docs\00200_Organization_Core_MVP_Cutline.md`
- `docs\00210_Index_Organization_Core_And_Readiness_Check.md`
- `docs\00450_Readme_Documentation_Governance.md`
- `docs\00459_Policy_Mobile_Draft_Google_Docs_Handoff_And_PC_Directory_Import_Workflow.md`
- `docs\00461_Policy_Documentation_Completion_Roadmap_And_Implementation_Deferral_Governance.md`
- `docs\00463_Policy_Documentation_Lane_Coverage_Matrix_And_Missing_Document_Detection.md`
- `docs\00465_Policy_Documentation_File_Naming_Folder_Path_And_Import_Normalization.md`
- `docs\00467_Policy_Documentation_Index_Directory_Map_And_Cross_Reference_Synchronization.md`
- `docs\00469_Policy_Documentation_Duplicate_Merge_Obsolete_Archive_And_Version_Lineage.md`
- `docs\00471_Policy_Documentation_Batch_Import_Review_Report_And_Commit_Discipline.md`
- `docs\00473_Policy_Documentation_Mobile_Draft_Quality_Control_And_Markdown_Copy_Safety.md`
- `docs\00475_Policy_Documentation_AI_Prompt_Library_Review_Boundary_And_No_Implementation_Instruction.md`
- `docs\00477_Policy_Documentation_Readiness_Dashboard_Status_Register_And_Progress_Tracking.md`
- `docs\00479_Checklist_Documentation_Governance_Final_Index_And_PC_Import_Preparation.md`
- `docs\01000_Readme_MVP_Scope.md`
- `docs\01010_MVP_Scope.md`
- `docs\01020_Store_Type_And_Product_Package_Strategy.md`
- `docs\01030_Competitive_Positioning_And_Market_Context.md`
- `docs\01040_Matrix_MVP_Active_Optional_Future_NonGoal.md`
- `docs\01050_Boundary_MVP_Package_And_Feature_Flag.md`
- `docs\01060_MVP_Store_Type_Adoption_Sequence.md`
- `docs\01070_CatchMenu_Service_Concept.md`
- `docs\01080_Policy_CatchMenu_Guest_Request_Lifecycle_And_State.md`
- `docs\01085_Policy_CatchMenu_Stage_0_POS_Less_Menu_Request.md`
- `docs\01090_Boundary_CatchMenu_Request_Order_Payment_And_Benefit_Authority.md`
- `docs\01092_Policy_CatchMenu_Guest_And_Merchant_Positioning.md`
- `docs\01095_Policy_CatchMenu_Guest_Identity_Session_And_Context_Continuity.md`
- `docs\01100_Policy_CatchMenu_I18n_Order_Request_Translation.md`
- `docs\01110_Policy_CatchMenu_Module_Option_And_Product_Package.md`
- `docs\01120_Policy_CatchMenu_Adoption_And_Expansion_Path.md`
_... and 871 more_

## UTF-8 And Korean

- UTF-8 failures: 0
- Files with Korean body text: 172
- Korean in filenames: 0

## Safety

- Read-only scan; no files renamed, moved, or edited (reports only)
- No code/SQL/Flutter/migrations touched
- Nothing staged or committed

