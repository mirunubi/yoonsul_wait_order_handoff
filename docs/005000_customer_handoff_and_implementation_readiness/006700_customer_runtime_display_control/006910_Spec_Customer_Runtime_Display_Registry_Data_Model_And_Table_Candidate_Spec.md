# 006910_Spec_Customer_Runtime_Display_Registry_Data_Model_And_Table_Candidate_Spec.md

## 1. Purpose

This specification defines the Customer Runtime display registry data model and table candidate structure.

The purpose is to convert display implementation specifications into registry-backed implementation candidates.

Customer-facing display behavior must not be controlled only by frontend constants, scattered enums, hard-coded messages, or undocumented conditionals.

The system should have controlled registry models for:

- Display status codes
- Customer action permissions
- Message templates
- Localization keys
- Translation versions
- Blocked wording
- Display surface bindings
- Error and fallback rules
- Emergency disable controls
- Evidence event configuration
- Release gate records

This specification proposes implementation-ready data model candidates without finalizing physical database DDL.

## 2. Scope

This specification covers:

- Registry model principles
- Candidate table groups
- Display status registry
- Customer action permission registry
- Message template registry
- Localization and translation registry
- Blocked wording registry
- Surface binding registry
- Evidence configuration registry
- Fallback rule registry
- Emergency disable control registry
- Release gate record registry
- Registry lifecycle and versioning fields
- Registry relationship model
- Seed and migration readiness
- QA and release validation

This specification does not define final SQL migration syntax, Supabase RLS implementation, production indexing, partitioning, performance optimization, or final admin UI screens.

## 3. Baseline Dependency

This specification depends on:

`006900_Index_Customer_Runtime_Display_Implementation_Spec_Release_Gate_Handoff_And_Closeout_Governance.md`

It implements registry candidates from:

`006830_Spec_Customer_Runtime_Display_Status_Code_Registry_And_UI_State_Binding_Spec.md`

`006840_Spec_Customer_Runtime_Action_Permission_Button_Guard_And_Idempotency_Spec.md`

`006850_Spec_Customer_Runtime_Message_Template_Localization_Key_And_Versioning_Spec.md`

`006860_Spec_Customer_Runtime_Display_Evidence_Event_And_Audit_Schema_Spec.md`

`006870_Spec_Customer_Runtime_Error_Recovery_Stale_State_And_Safe_Fallback_Display_Spec.md`

`006880_SOP_Customer_Runtime_Display_Incident_Response_And_Emergency_Message_Disable_Operation.md`

`006890_Checklist_Customer_Runtime_Display_Release_Gate_And_Production_Preflight_Check.md`

## 4. Core Principle

Display runtime behavior must be registry-controlled.

The registry must allow the system to answer:

1. Which status codes exist?
2. Which status code is active, restricted, deprecated, blocked, or retired?
3. Which runtime state can produce the status?
4. Which surfaces may show it?
5. Which messages may be shown?
6. Which actions may be shown or submitted?
7. Which translations are approved?
8. Which wording is blocked?
9. Which fallback is used when state is uncertain?
10. Which evidence events must be emitted?
11. Which emergency disable control can stop unsafe exposure?
12. Which release gate approved this behavior?

## 5. Candidate Schema Grouping

The display registry candidate model may be grouped into the following logical areas.

| Group | Purpose |
|---|---|
| Status Registry | Display status codes and runtime state bindings |
| Action Registry | Customer action permissions, guards, and idempotency |
| Message Registry | Message templates, variants, wording, and lifecycle |
| Localization Registry | Localization keys, translations, language versions |
| Surface Registry | Surface definitions and binding rules |
| Evidence Registry | Display/message/action evidence emission requirements |
| Fallback Registry | Error, recovery, stale-state, and safe fallback rules |
| Disable Registry | Emergency disable controls and active restrictions |
| Release Registry | Release gate, QA acceptance, waiver, and rollout scope |
| Audit Registry | Registry change audit and approval trail |

These groups may become separate physical tables, views, JSON-backed records, admin resources, or mixed implementation structures.

## 6. Naming Rule For Candidate Tables

Candidate tables should follow this pattern:

```text
customer_display_<registry_area>