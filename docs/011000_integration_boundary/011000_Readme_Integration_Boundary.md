# 011000_Readme_Integration_Boundary

## 1 Purpose

This folder defines the high-level boundary for POS, KDS, payment, printer, tablet order, and external systems.

This wave consolidates integration boundary governance after MVP scope, SaaS runtime, Admin Console, and Data/State consolidation waves.

## 2 In Scope

- Integration boundary principles.
- POS API integration truth boundary.
- Printer and Store Agent boundary.
- Payment and financial truth boundary.
- Manual POS input and reconciliation boundary.
- Integration failure, retry, and recovery boundary.
- Manual POS entry allowance.
- Future external system connection references.
- POS, payment, printer, Store Agent, and Full OS adoption boundaries.

## 3 Document List

| document | description |
| --- | --- |
| `04400_Policy_Toss_Payments_MVP_Integration_Boundary.md` | 04400 Toss Payments MVP Integration Boundary Policy. |
| `04410_Policy_PAYCO_Payment_And_Order_Provider_MVP_Boundary.md` | 04410 PAYCO Payment And Order Provider MVP Boundary Policy. |
| `04420_Policy_POS_Adapter_Runtime_Data_Object_And_Event_Family.md` | 04420 POS Adapter Runtime Data Object And Event Family Policy. |
| `04430_Policy_OKPOS_And_Major_POS_Integration_Candidate.md` | 04430 OKPOS And Major POS Integration Candidate Policy. |
| `11010_Boundary_POS_Payment_Printer_Integration.md` | 11010 POS Payment Printer Integration Boundary. |
| `11020_Boundary_POS_API_Integration_Truth.md` | 11020 POS API Integration Truth Boundary. |
| `11030_Boundary_Printer_And_Store_Agent.md` | 11030 Printer And Store Agent Boundary. |
| `11040_Boundary_Payment_And_Financial_Truth.md` | 11040 Payment And Financial Truth Boundary. |
| `11050_Boundary_Manual_POS_Input_And_Reconciliation.md` | 11050 Manual POS Input And Reconciliation Boundary. |
| `11060_Boundary_Integration_Failure_Retry_And_Recovery.md` | 11060 Integration Failure Retry And Recovery Boundary. |
| `11070_Policy_POS_Callback_Replay_Manual_Fallback_And_Evidence.md` | 03540 POS Callback Replay Manual Fallback And Evidence Policy. |
| `11080_Policy_PAYCO_POS_Integration_Implementation_Approach_And_Official_Verification.md` | 05170 PAYCO POS Integration Implementation Approach And Official Verification Policy. |
| `11090_Policy_POS_Payment_Provider_Integration_Priority_Matrix_And_Openness_Assessment.md` | 05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy. |
| `11100_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral.md` | 11100_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral. |
| `11110_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse.md` | 11110_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse. |
| `11120_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary.md` | 11120_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary. |
| `11130_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary.md` | 11130_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary. |
| `11140_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary.md` | 11140_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary. |
| `11150_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel.md` | 11150_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel. |
| `11160_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping.md` | 11160_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping. |
| `11170_Assessment_Store_POS_Adoption_Strategy_OKPOS_Ledger_And_Toss_Kiosk_Combination.md` | 11170_Assessment_Store_POS_Adoption_Strategy_OKPOS_Ledger_And_Toss_Kiosk_Combination. |
| `11180_Policy_Toss_Base_Strategy_And_OKPOS_Compatibility_Interface.md` | 11180_Policy_Toss_Base_Strategy_And_OKPOS_Compatibility_Interface. |
| `11190_Policy_Table_Order_POS_Ecosystem_Phase_2_And_Phase_3_Expansion_Roadmap.md` | 11190_Policy_Table_Order_POS_Ecosystem_Phase_2_And_Phase_3_Expansion_Roadmap. |
| `11200_Policy_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison.md` | 11200_Policy_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison. |
| `11210_Policy_Provider_Adapter_Boundary_And_Canonical_Event_Mapping.md` | 11210_Policy_Provider_Adapter_Boundary_And_Canonical_Event_Mapping. |
| `11220_Readme_Open_API_Partner_Alliance.md` | 03300 Open API Partner Alliance Readme. |
| `11230_Readme_Provider_Adapter_Runtime.md` | 03400 Provider Adapter Runtime Readme. |
| `11240_Readme_External_POS_Integration_Runtime.md` | 03500 External POS Integration Runtime Readme. |
| `11250_POS_Integration_Module_And_All_POS_Expansion_Strategy.md` | 03510 POS Integration Module And All-POS Expansion Strategy. |
| `11260_Policy_POS_Provider_Adapter_Contract_And_Capability_Declaration.md` | 03520 POS Provider Adapter Contract And Capability Declaration Policy. |
| `11270_Policy_POS_Menu_Table_Order_Mapping_And_Idempotency.md` | 03530 POS Menu Table Order Mapping And Idempotency Policy. |
## 4 Out Of Scope

- Full POS API integration, payment processing, KDS automation, printer protocol, and external SDK implementation.
- Retry jobs, reconciliation engines, alerting, and incident automation.

## 5 Current Status

Status: integration boundary consolidation wave complete. High-level and refined truth boundaries only. Not implementation approval.
