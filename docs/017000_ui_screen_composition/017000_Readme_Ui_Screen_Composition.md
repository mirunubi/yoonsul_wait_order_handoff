# 017000_Readme_Ui_Screen_Composition

## 1 Purpose

This folder holds UI screen composition, wording, wireframe boundary, and design documentation under the `17000~19999` band.

This wave consolidates UI composition after the App/API Projection consolidation wave.

This is not implementation.

## 2 In Scope

- Customer webapp, Mini Kiosk, store console, admin console, and support console screen composition.
- UI surface-to-authority composition model.
- Integration status UI wording.
- Action button and status badge governance.
- Customer/Mini Kiosk state wording consolidation.
- Admin/support UI authority and recovery model.
- Future/non-MVP UI surface boundaries.
- Shared UI state wording, empty state, error state, and recovery state guidance.
- Wireframe and prototype boundary before asset creation.

## 3 Document List

| document | description |
| --- | --- |
| `17010_Customer_Webapp_UI_Composition.md` | Conceptual customer webapp screen groups, composition notes, and customer wording rules aligned with 13070. |
| `17020_Mini_Kiosk_UI_Composition.md` | Conceptual Mini Kiosk screen groups for store-assisted or visitor ordering without waiting flow assumption. |
| `17030_Store_Console_UI_Composition.md` | Conceptual store console screens, staff controls, and forbidden UI implications; store console is not POS. |
| `17040_Admin_Console_UI_Composition.md` | Conceptual admin console screen groups and authority UI rules from 07000 and 13040 governance. |
| `17050_Support_Console_UI_Composition.md` | Conceptual scoped support console screens; support action does not equal approval. |
| `17060_Guide_UI_State_Wording_And_Empty_State_Guideline.md` | Shared loading, empty, error, delay, and recovery wording across all surfaces. |
| `17070_Boundary_Wireframe_Prototype.md` | Boundary for future wireframes and prototypes; no image assets in this wave. |
| `17080_UI_Surface_To_Authority_Composition_Model.md` | Maps UI controls to visibility, request, mutation, approval, and audit authority types. |
| `17090_Integration_Status_UI_Wording_Model.md` | Integration status wording per surface without overstating truth. |
| `17100_Governance_Action_Button_And_Status_Badge.md` | Button and status badge governance; visibility does not equal authority. |
| `17110_Customer_MiniKiosk_State_Wording_Consolidation.md` | Customer and Mini Kiosk state wording consolidated from 17010, 17020, 13070, 09090, 11000. |
| `17120_Admin_Support_UI_Authority_And_Recovery_Model.md` | Admin/support authority, recovery, audit, and support scope UI rules. |
| `17130_Boundary_Future_UI_Surface_Non_MVP.md` | Future membership, analytics, payment, Franchise OS, and benchmark UI boundaries. |

`17010`~`17070` are existing UI composition foundations.

`17080`~`17130` consolidate authority, integration wording, button/status governance, customer/Mini Kiosk wording, admin/support recovery UI, and future non-MVP UI surfaces.

This domain remains UI composition only and does not create UI implementation.

## 4 Out Of Scope

- Flutter implementation, final UI code, and production design assets.
- Wireframe image assets, Figma exports, route definitions, and API endpoints.
- SQL, migrations, Supabase functions, and package implementation.

## 5 Current Status

Status: UI composition consolidation wave complete. Documentation projection only. Not implementation approval.
