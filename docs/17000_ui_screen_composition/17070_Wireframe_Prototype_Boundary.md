# 17070 Wireframe Prototype Boundary

## 1 Purpose

Wireframes and prototypes may be created later.

This document defines boundaries before asset creation.

No wireframe image assets are created in this wave.

This document is governance projection only.
It does not authorize implementation, API design, database schema, or production UI delivery.

## 2 Future Asset Types

| asset type | purpose | governance note |
| --- | --- | --- |
| rough wireframe | Low-fidelity layout exploration for screen groups. | Must follow 17010–17050 screen inventories. |
| screen flow diagram | Show navigation and handoff between screen groups. | Flow does not define routes or API. |
| clickable prototype | Interactive exploration for review and training. | prototype does not equal implementation. |
| component mock | Visual exploration of reusable UI blocks. | Mock does not define production components. |
| state transition screen map | Map visible states to screen groups. | Visual state does not equal runtime authority. |
| multilingual wording mock | Review translated copy per language. | Wording must follow 13070 and 17060. |
| recovery/error state mock | Review error, delay, and recovery presentation. | Must preserve operational truth. |

## 3 Storage Boundary

- no image assets in this task.
- future wireframe assets should use a dedicated folder only after 17000 governance is stable.
- future asset naming must use five-digit numbering if stored in docs.
- generated assets must not replace source markdown governance.

Markdown documents in `docs/17000_ui_screen_composition/` remain the source of truth for screen composition, wording, and authority boundaries.

## 4 Prototype Rules

- prototype does not equal implementation.
- clickable prototype does not define API.
- UI mock does not define database schema.
- visual state does not equal runtime authority.
- customer wording in mock must follow 13070/17060.

Additional rules:

- prototype navigation is illustrative only.
- prototype confirmation buttons must respect authority boundaries from 13060 and 13080.
- prototype must not introduce membership/point, platform payment, or POS success states not supported by governance.
- prototype review is not implementation approval.

## 5 Implementation Planning Cross-Reference

UI implementation readiness is governed by `docs/22000_implementation_planning/22040_Api_App_Implementation_Readiness_Checklist.md`.

QA/smoke/rollback planning is governed by `docs/22000_implementation_planning/22050_QA_Smoke_Test_And_Rollback_Planning_Boundary.md`.

Prototype does not equal implementation approval.

## 6 Cross-References

- `docs/17000_ui_screen_composition/17010_Customer_Webapp_UI_Composition.md`
- `docs/22000_implementation_planning/22040_Api_App_Implementation_Readiness_Checklist.md`
- `docs/22000_implementation_planning/22050_QA_Smoke_Test_And_Rollback_Planning_Boundary.md`
- `docs/17000_ui_screen_composition/17020_Mini_Kiosk_UI_Composition.md`
- `docs/17000_ui_screen_composition/17030_Store_Console_UI_Composition.md`
- `docs/17000_ui_screen_composition/17040_Admin_Console_UI_Composition.md`
- `docs/17000_ui_screen_composition/17050_Support_Console_UI_Composition.md`
- `docs/17000_ui_screen_composition/17060_UI_State_Wording_And_Empty_State_Guideline.md`
- `docs/00001_Md_Rules.md`

## 7 Open Decisions

- whether assets live under `docs/17000_ui_screen_composition/assets`.
- whether Figma exports are stored.
- whether image files are versioned.
- wireframe naming rule.
- prototype review workflow.

## 8 Current Status

Status: active wireframe and prototype boundary. No assets created in this wave.
