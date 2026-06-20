# 008000_Readme_AI_Customer_Center.md

## Purpose

This folder defines the AI Customer Center and support-intelligence boundary for CatchMenu.

It covers support signals, knowledge retrieval, customer-safe AI responses, evidence packets, escalation boundaries, high-risk store operation support, and future AI Customer Center integration planning.

This folder does not authorize runtime implementation, direct operational mutation, payment mutation, refund authority, KDS release authority, or direct AI access to primary runtime truth.

## Folder-Owned Number Range

- Folder: `docs/008000_ai_customer_center/`
- Owned range: `008000~008999`
- Next sibling folder: `docs/009000_data_model_state_machine/`
- Files in this folder should remain within `008000~008999` unless a future sibling folder changes the boundary.

## Scope

- AI customer support boundary.
- SOP and knowledge retrieval boundary.
- pgvector support knowledge gateway.
- Customer-safe AI response constraints.
- Support signal and support case handoff.
- Evidence packet foundation for support review.
- High-risk store operation support scenarios.
- Human escalation and authorized action boundaries.

## Out Of Scope

- Runtime implementation.
- Direct payment mutation.
- Direct refund or compensation authority.
- Direct KDS release authority.
- Direct AI mutation of operational truth.
- AI-owned production access to primary runtime tables without gateway authorization.

## Active File Roles

| File | Role |
| --- | --- |
| `008000_Readme_AI_Customer_Center.md` | Defines the AI Customer Center folder boundary, owned number range, and active document roles. |
| `008001_Overview_AI_Customer_Center_Foundation.md` | Defines the foundation and separation between CatchMenu operational runtime and the AI customer center support intelligence layer. |
| `008002_Index_High_Risk_Store_Operation_Foundation_README_And_Edge_Case_Constitution.md` | Indexes high-risk store operation edge cases and the governing constitution for support-safe handling. |
| `008010_Policy_Alcohol_Sales_Adult_Verification_And_Legal_Sale_Boundary.md` | Defines adult verification and legal sale boundaries for alcohol-related customer support scenarios. |
| `008020_Policy_Alcohol_Order_Identity_Privacy_CI_DI_And_Verification_Evidence.md` | Defines identity, privacy, CI/DI, and verification evidence requirements for alcohol order support. |
| `008030_Policy_Table_Session_Alcohol_Add_On_Partial_Settlement_And_Mid_Meal_Payment.md` | Defines table-session alcohol add-on, partial settlement, and mid-meal payment support boundaries. |
| `008040_Policy_Drunk_Customer_Mistouch_Misoperation_Confirmation_And_Staff_Intervention.md` | Defines customer mistake, misoperation, intoxication, confirmation, and staff intervention handling boundaries. |
| `008050_Policy_Night_Operation_Delivery_Platform_Concurrent_Order_Synchronization.md` | Defines night operation and delivery-platform concurrent order synchronization support boundaries. |
| `008070_Policy_Alcohol_Payment_Refund_Dispute_Chargeback_And_Recovery_Evidence.md` | Defines alcohol payment, refund, dispute, chargeback, and recovery evidence requirements. |
| `008080_Policy_Minor_Access_Prevention_Verification_Failure_And_Incident_Response.md` | Defines minor-access prevention, verification failure, and incident response support rules. |
| `008090_Policy_Night_Safety_Staff_Escalation_Abuse_Prevention_And_Store_Closure_Boundary.md` | Defines night safety, staff escalation, abuse prevention, and store closure support boundaries. |
| `008100_Policy_CatchMenu_Support_Signal_And_Case_Handoff.md` | Defines CatchMenu support signal generation and case handoff boundaries for AI-assisted support. |
| `008101_Policy_High_Risk_Store_Operation_Foundation_Readiness_Check_And_Cross_Runtime_Handoff.md` | Defines readiness and cross-runtime handoff checks for high-risk store operation support. |
| `008200_Policy_CatchMenu_Knowledge_Retrieval_pgvector_Gateway.md` | Defines pgvector knowledge retrieval and support gateway access boundaries for AI support. |
| `008300_Boundary_AI_Response.md` | Defines AI response boundaries, unsupported-answer limits, and customer-safe response constraints. |
| `008400_Guide_CatchMenu_Troubleshooting_Foundation.md` | Guides troubleshooting classification, source order, escalation, and evidence use for CatchMenu support. |
| `008500_Evidence_Packet_Foundation.md` | Defines evidence packet foundations for support review and AI-assisted case explanation. |
| `008600_Plan_Support_Server_Strategy.md` | Plans support server separation, gateway access, and database separation for future AI customer center operation. |
| `008700_Plan_Scale_Out_Strategy.md` | Plans scale-out layers for knowledge retrieval, support signals, evidence packets, support views, and limited runtime reads. |
| `008800_Policy_CatchMenu_AI_Gateway_Runtime_Query_And_Cross_Project_Access.md` | Defines AI gateway runtime query and cross-project access rules for support-safe integration. |

## Governance Notes

CatchMenu owns operational truth. The AI Customer Center may retrieve knowledge, review support-safe evidence, draft responses, and recommend escalation, but authorized runtime functions or human operators must execute authority-sensitive actions.
