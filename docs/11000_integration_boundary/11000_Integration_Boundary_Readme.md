# 11000 Integration Boundary Readme

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
| `04400_Toss_Payments_MVP_Integration_Boundary_Policy.md` | 04400 Toss Payments MVP Integration Boundary Policy. |
| `04410_PAYCO_Payment_And_Order_Provider_MVP_Boundary_Policy.md` | 04410 PAYCO Payment And Order Provider MVP Boundary Policy. |
| `04420_POS_Adapter_Runtime_Data_Object_And_Event_Family_Policy.md` | 04420 POS Adapter Runtime Data Object And Event Family Policy. |
| `04430_OKPOS_And_Major_POS_Integration_Candidate_Policy.md` | 04430 OKPOS And Major POS Integration Candidate Policy. |
| `11010_POS_Payment_Printer_Integration_Boundary.md` | 11010 POS Payment Printer Integration Boundary. |
| `11020_POS_API_Integration_Truth_Boundary.md` | 11020 POS API Integration Truth Boundary. |
| `11030_Printer_And_Store_Agent_Boundary.md` | 11030 Printer And Store Agent Boundary. |
| `11040_Payment_And_Financial_Truth_Boundary.md` | 11040 Payment And Financial Truth Boundary. |
| `11050_Manual_POS_Input_And_Reconciliation_Boundary.md` | 11050 Manual POS Input And Reconciliation Boundary. |
| `11060_Integration_Failure_Retry_And_Recovery_Boundary.md` | 11060 Integration Failure Retry And Recovery Boundary. |
| `11070_POS_Callback_Replay_Manual_Fallback_And_Evidence_Policy.md` | 03540 POS Callback Replay Manual Fallback And Evidence Policy. |
| `11080_PAYCO_POS_Integration_Implementation_Approach_And_Official_Verification_Policy.md` | 05170 PAYCO POS Integration Implementation Approach And Official Verification Policy. |
| `11090_POS_Payment_Provider_Integration_Priority_Matrix_And_Openness_Assessment_Policy.md` | 05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy. |
| `11100_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral_Policy.md` | 05190 MVP Provider Cutline And Phase 2 POS Expansion Deferral Policy. |
| `11110_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse_Policy.md` | 05200 POS Payment Provider Document Folder Grouping And Kiosk Reuse Policy. |
| `11120_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary_Policy.md` | 05210 Mini Kiosk And Kiosk Provider Integration Module Boundary Policy. |
| `11130_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary_Policy.md` | 05220 Mini Kiosk Payment Flow State And Recovery Boundary Policy. |
| `11140_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary_Policy.md` | 05230 Mini Kiosk Session Identity Device Trust And Customer Context Boundary Policy. |
| `11150_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel_Policy.md` | 05240 MVP Provider Cutline Revision Toss OKPOS First Phase And PAYCO Payment Channel Policy. |
| `11160_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping_Policy.md` | 05250 OKPOS OKDC Integration Implementation Approach And Test Mapping Policy. |
| `11170_Store_POS_Adoption_Strategy_OKPOS_Ledger_And_Toss_Kiosk_Combination_Assessment.md` | 05255 Store POS Adoption Strategy OKPOS Ledger And Toss Kiosk Combination Assessment. |
| `11180_Toss_Base_Strategy_And_OKPOS_Compatibility_Interface_Policy.md` | 05260 Toss Base Strategy And OKPOS Compatibility Interface Policy. |
| `11190_Table_Order_POS_Ecosystem_Phase_2_And_Phase_3_Expansion_Roadmap_Policy.md` | 05270 Table Order POS Ecosystem Phase 2 And Phase 3 Expansion Roadmap Policy. |
| `11200_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison_Policy.md` | 05280 Cloud Open API Versus Local Daemon Provider Architecture Comparison Policy. |
| `11210_Provider_Adapter_Boundary_And_Canonical_Event_Mapping_Policy.md` | 05290 Provider Adapter Boundary And Canonical Event Mapping Policy. |
| `11220_Open_API_Partner_Alliance_Readme.md` | 03300 Open API Partner Alliance Readme. |
| `11230_Provider_Adapter_Runtime_Readme.md` | 03400 Provider Adapter Runtime Readme. |
| `11240_External_POS_Integration_Runtime_Readme.md` | 03500 External POS Integration Runtime Readme. |
| `11250_POS_Integration_Module_And_All_POS_Expansion_Strategy.md` | 03510 POS Integration Module And All-POS Expansion Strategy. |
| `11260_POS_Provider_Adapter_Contract_And_Capability_Declaration_Policy.md` | 03520 POS Provider Adapter Contract And Capability Declaration Policy. |
| `11270_POS_Menu_Table_Order_Mapping_And_Idempotency_Policy.md` | 03530 POS Menu Table Order Mapping And Idempotency Policy. |
## 4 Out Of Scope

- Full POS API integration, payment processing, KDS automation, printer protocol, and external SDK implementation.
- Retry jobs, reconciliation engines, alerting, and incident automation.

## 5 Current Status

Status: integration boundary consolidation wave complete. High-level and refined truth boundaries only. Not implementation approval.
