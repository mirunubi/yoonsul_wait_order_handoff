# 006830_Spec_Customer_Runtime_Display_Status_Code_Registry_And_UI_State_Binding_Spec

## 1. Purpose

This specification defines the Customer Runtime display status code registry and UI state binding rules.

The purpose is to ensure that every customer-facing UI state is bound to a controlled display status code, authoritative runtime state, approved message template, allowed action set, privacy class, evidence requirement, and rollout control rule.

Customer-facing screens must not infer their own truth.

A customer display status must be derived from runtime state and event evidence, not from local component state, browser cache, stale app data, kiosk session memory, staff assumption, or payment provider ambiguity.

## 2. Scope

This specification covers:

- Display status code registry
- Status family classification
- UI state binding
- Runtime state source binding
- Event trigger binding
- Surface binding
- Message template binding
- Customer action binding
- Privacy classification
- Evidence requirement
- Stale state handling
- Payment-sensitive display binding
- Support-sensitive display binding
- Membership/benefit display binding
- Error and recovery status binding
- Rollout blocker mapping

This specification does not define final UI design, layout, frontend component implementation, CSS, iconography, accessibility behavior, or copywriting style.

## 3. Baseline Dependency

This specification depends on:

`006820_Index_Customer_Runtime_Display_Control_Message_Status_Action_QA_Defect_And_Rollout_Governance.md`

It implements downstream structure from:

`006770_Template_Customer_Runtime_Display_Status_Code_Action_Permission_Message_Binding_And_Evidence_Template.md`

It must remain consistent with:

`006760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`

`006750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`

`006700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

## 4. Core Principle

A display status code is a public runtime claim.

Each code must be:

1. Stable
2. Versioned
3. Runtime-bound
4. Surface-scoped
5. Message-bound
6. Action-bound
7. Privacy-classified
8. Evidence-backed
9. Stale-safe
10. Rollout-controlled

No customer-facing UI component may create unregistered display status behavior.

## 5. Display Status Code Naming Rule

Display status codes must follow this structure:

```text
<DOMAIN>_<STATE_OR_MEANING>