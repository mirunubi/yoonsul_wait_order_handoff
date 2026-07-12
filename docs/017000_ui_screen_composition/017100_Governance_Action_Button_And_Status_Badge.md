# 017100_Governance_Action_Button_And_Status_Badge

## 1 Purpose

UI controls can mislead users if they imply stronger authority than the runtime supports.

This document defines button/status governance only and does not create UI components.

This document is UI composition governance only.
It does not approve button components, CSS, or design tokens.

## 2 Button Families

| button family | authority note |
| --- | --- |
| create order candidate | Draft intent only; not confirmed order. |
| submit preorder request | Intent submission; not paid order. |
| staff review | Operational review within store scope. |
| staff confirm | Operational confirmation; not financial truth. |
| mark manual POS input needed | Staff workflow flag. |
| mark manual POS input completed | Staff assertion unless POS evidence exists. |
| retry printer output | New print attempt; not POS sales creation. |
| retry POS API attempt | New API attempt; not success claim. |
| emergency disable | Disable with audit; does not erase history. |
| rollback | Controlled rollback preserving audit. |
| approve change | Approval only; does not activate. |
| activate change | Requires prior approval context. |
| request support | Opens support request; not approval. |
| close recovery item | Requires documented reason. |
| request export | Export request; requires approval governance. |

## 3 Status Badge Families

| badge family | meaning |
| --- | --- |
| candidate | Draft order intent. |
| review pending | Awaiting staff review. |
| staff confirmed | Operational confirmation only. |
| POS API pending | POS API attempt in progress. |
| POS API success | POS authority confirmed creation. |
| printer sent | Print dispatched; not POS confirmed. |
| payment pending | Payment expected; not paid. |
| paid by store POS | Store POS payment authority confirmed. |
| manual recovery required | Recovery needed; linked to original event. |
| support scoped | Active scoped support session. |
| disabled | Integration or feature disabled with audit. |
| future placeholder | Future feature; not active runtime. |

## 4 Governance Rules

- confirm button must not imply payment.
- printer retry button must not imply POS sales creation.
- POS API retry button must not imply success.
- approve button does not activate by itself.
- activate button requires approval context.
- emergency disable button does not erase audit.
- support button does not approve action.
- export button requires export approval.
- disabled state should explain missing authority when safe.

## 5 Cross-References

- `docs/017000_ui_screen_composition/017080_UI_Surface_To_Authority_Composition_Model.md`
- `docs/07000_admin_console/007090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md`
- `docs/013000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md`

## 6 Open Decisions

- button naming convention.
- disabled tooltip wording.
- severity color mapping.
- status badge naming.
- mobile vs desktop action placement.
- confirmation modal depth.

## 7 Current Status

Status: active action button and status badge governance. Not implementation approval.
