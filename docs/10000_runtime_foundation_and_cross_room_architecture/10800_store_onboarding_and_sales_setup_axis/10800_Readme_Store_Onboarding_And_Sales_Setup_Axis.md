# 10800_Readme_Store_Onboarding_And_Sales_Setup_Axis

## 1 Purpose

This folder defines the `10800` Store Onboarding and Sales Setup Axis package for store sales intake, menu material intake, AI menu parsing review, category and combo review, allergen and ingredient detection handoff, service mode selection, and POS/KDS integration readiness intake.

## 2 In Scope

- Store onboarding and sales setup axis index.
- Store sales intake and tenant store profile setup.
- Menu material intake from photo, PDF, text, and POS export.
- AI menu parsing correction and owner review workflow.
- Menu category, option set, combo, and course review.
- Allergen, alcohol, raw food, and market price detection handoff.
- Ingredient master pool taxonomy and Korean namul seed registry (`10805_01` child of `10805`).
- Store service mode selection and feature readiness.
- POS, payment, and KDS integration readiness intake.

## 3 Relationship Notes

- `10800` owns the store onboarding and menu intake axis moved from `docs/` root.
- `10805_01` is a child extension of `10805`; `10806` and `10807` were not renumbered.
- `40000` owns menu taxonomy and AI classification seed registries.
- `10720` owns legal notice SOP and regulatory control surfaces referenced during onboarding.
- `05200` owns POS provider and mini-kiosk integration boundaries referenced at intake.

Detailed child documents retain their own five-digit numbers (`10800`~`10807`, plus `10805_01`).

## 4 Document List

| document | description |
| --- | --- |
| `10809_Index_Store_Onboarding_And_Sales_Setup_Axis.md` | Store onboarding and sales setup axis index. |
| `10801_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | Store sales intake and tenant store profile setup policy. |
| `10802_Policy_Menu_Material_Intake_Photo_PDF_Text_And_POS_Export.md` | Menu material intake from photo, PDF, text, and POS export policy. |
| `10803_Policy_AI_Menu_Parsing_Correction_And_Owner_Review_Workflow.md` | AI menu parsing correction and owner review workflow policy. |
| `10804_Policy_Menu_Category_Option_Set_Combo_Course_Review.md` | Menu category, option set, combo, and course review policy. |
| `10805_Policy_Allergen_Alcohol_Raw_Food_Market_Price_Detection_Handoff.md` | Allergen, alcohol, raw food, and market price detection handoff policy. |
| `10808_Policy_Ingredient_Master_Pool_Namul_Seed_Registry.md` | Ingredient master pool taxonomy and Korean namul seed registry (`10805A` mapped to `10805_01`). |
| `10806_Policy_Store_Service_Mode_Selection_And_Feature_Readiness.md` | Store service mode selection and feature readiness policy. |
| `10807_Policy_POS_Payment_KDS_Integration_Readiness_Intake.md` | POS, payment, and KDS integration readiness intake policy. |

## 5 Current Status

Status: Package consolidation wave complete. Governance only. Not implementation approval.
