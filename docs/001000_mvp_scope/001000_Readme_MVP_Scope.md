# 001000_Readme_MVP_Scope.md

## 1 Purpose

This folder defines MVP scope, service scenario, and initial market-facing scope.

`01000` is the source of MVP/future/non-goal separation.

`22000` governs implementation readiness, but `01000` governs scope.

`15000`/`26000`/`28000` do not override MVP non-goals.

## 2 In Scope

- First MVP included features.
- Deferred features.
- Customer, staff, and store admin role boundaries.
- MVP status models.
- Store type, adoption depth, and product package strategy.
- Market, competitive positioning, and early wedge definition.
- Consolidated MVP active/optional/future/non-goal matrix.
- MVP package and feature flag boundary.
- MVP store-type adoption sequence.

## 3 Document List

| document | description |
| --- | --- |
| `001000_Readme_MVP_Scope.md` | Folder-level Readme for MVP scope ownership, local file roles, and non-implementation boundary. |
| `001010_Guide_MVP_Scope.md` | Core MVP scope baseline covering included MVP capabilities, exclusions, and early operating mode principles. |
| `001020_Store_Type_And_Product_Package_Strategy.md` | Store type and product package strategy for MVP adoption depth and packaged feature boundaries. |
| `001030_Competitive_Positioning_And_Market_Context.md` | Market and competitive positioning context for the MVP wedge and early differentiation. |
| `001040_Matrix_MVP_Active_Optional_Future_NonGoal.md` | Matrix separating active MVP scope, optional scope, future scope, and explicit non-goals. |
| `001050_Boundary_MVP_Package_And_Feature_Flag.md` | Boundary for MVP package composition and feature flag control. |
| `001060_MVP_Store_Type_Adoption_Sequence.md` | Adoption sequence for store types and progressive MVP rollout depth. |
| `001070_CatchMenu_Service_Concept.md` | CatchMenu service concept and customer-facing MVP service framing. |
| `001080_Policy_CatchMenu_Guest_Request_Lifecycle_And_State.md` | Policy for guest request lifecycle and state handling in CatchMenu MVP scope. |
| `001085_Policy_CatchMenu_Stage_0_POS_Less_Menu_Request.md` | Policy for Stage 0 POS-less menu request behavior and operating boundary. |
| `001090_Boundary_CatchMenu_Request_Order_Payment_And_Benefit_Authority.md` | Boundary separating request, order, payment, and benefit authority in CatchMenu MVP scope. |
| `001092_Policy_CatchMenu_Guest_And_Merchant_Positioning.md` | Policy for guest and merchant positioning within the CatchMenu MVP experience. |
| `001095_Policy_CatchMenu_Guest_Identity_Session_And_Context_Continuity.md` | Policy for guest identity, session continuity, and store context continuity. |
| `001100_Policy_CatchMenu_I18n_Order_Request_Translation.md` | Policy for internationalization and order request translation within MVP limits. |
| `001110_Policy_CatchMenu_Module_Option_And_Product_Package.md` | Policy for module options and product package definition in CatchMenu MVP scope. |
| `001120_Policy_CatchMenu_Adoption_And_Expansion_Path.md` | Policy for CatchMenu adoption path and later expansion sequence. |
| `001130_Policy_CatchMenu_Merchant_Onboarding_And_Readiness.md` | Policy for merchant onboarding and readiness before MVP use. |
| `001140_Policy_CatchMenu_Guest_Request_Lifecycle_And_State.md` | Supplemental policy for guest request lifecycle and state handling. |
| `001150_Boundary_CatchMenu_Request_Order_Payment_And_Benefit_Authority.md` | Supplemental boundary for request, order, payment, and benefit authority separation. |
| `001160_Policy_CatchMenu_Guest_Identity_Session_And_Context_Continuity.md` | Supplemental policy for guest identity, session continuity, and context continuity. |
| `001170_Stage_0_Unconfirmed_Request_Warning_And_Forced_Cleanup.md` | Stage 0 warning and forced cleanup rules for unconfirmed requests. |
| `001180_Stage_0_Translation_And_Critical_Request_Handling.md` | Stage 0 handling rules for translation and critical request cases. |
| `001190_Evidence_Stage_0_Support_Signal_And_Packet.md` | Evidence packet definition for Stage 0 support signals and support handoff. |
| `001200_Policy_Stage_0_QR_Menu_Store_Context_And_Versioning.md` | Policy for Stage 0 QR menu, store context, and versioning. |
| `001205_Readme_CatchMenu_POS_Less_Entry_Runtime_QR_Request_MVP.md` | Local Readme for CatchMenu POS-less entry runtime, QR request, and MVP flow documents. |
| `001210_CatchMenu_Stage_0A_QR_Menu_And_Show_To_Staff_Flow.md` | Stage 0A flow for QR menu access and show-to-staff request handling. |
| `001220_CatchMenu_Stage_0B_Send_To_Store_Request_Flow.md` | Stage 0B flow for sending guest requests to the store. |
| `001230_Policy_CatchMenu_Stage_0C_POS_Less_Request_Confirmation_Board.md` | Policy for Stage 0C POS-less request confirmation board behavior. |
| `001240_Policy_CatchMenu_POS_Less_Guest_Web_Screen.md` | Policy for the POS-less guest web screen in MVP scope. |
| `001250_Policy_CatchMenu_POS_Less_Owner_Web_Console.md` | Policy for the POS-less owner web console in MVP scope. |
| `001260_CatchMenu_POS_Less_Request_State_Transition_Guard.md` | State transition guard for POS-less CatchMenu requests. |
| `001290_Implementation_Stage_0_MVP_Cutline.md` | Pre-implementation cutline defining what Stage 0 MVP may and may not implement later. |
| `001299_Index_Stage_0_And_Readiness_Check.md` | Index and readiness check for Stage 0 MVP documents. |

## 4 Out Of Scope

- Full SaaS implementation, POS integration, payment, membership, KDS automation, and production app code.

## 5 Current Status

Status: MVP scope consolidation wave complete. Scope governance only. Not implementation approval.
