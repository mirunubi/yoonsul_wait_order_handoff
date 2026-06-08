# 09000 Data Model State Machine Readme

## 1 Purpose

This folder defines conceptual data model and state machine design only.

This wave consolidates the conceptual model after MVP scope, SaaS runtime, and Admin Console consolidation waves.

## 2 In Scope

- Conceptual entities.
- State names and transitions.
- Data ownership boundaries.
- Draft table/entity naming at design level.
- Entity master consolidation.
- State/event ownership and truth boundaries.
- Audit/recovery event lineage.
- Context entity alignment with SaaS runtime.
- Runtime profile and change request entities.
- Order candidate and confirmation state refinement.
- Admin/support/audit entity lineage.
- Future profile and analytics state boundaries.
- Implementation-deferred data model boundary.

## 3 Document List

| document | description |
| --- | --- |
| `09010_Data_Model_Draft.md` | Remains draft/candidate notes for conceptual entities and table naming ideas. |
| `09020_Handoff_State_Machine.md` | Remains the conceptual customer, waiting, handoff, Mini Kiosk, and store runtime visibility state machine. |
| `09030_Conceptual_Entity_Master.md` | Consolidates conceptual entity candidates across SaaS context, runtime configuration, customer/session runtime, menu/order intent, store operation, admin/governance, recovery/audit/compliance, and future intelligence. |
| `09040_State_And_Event_Ownership_Model.md` | Defines truth families, event authority types, state ownership, and forbidden ownership collapses. |
| `09050_Audit_Recovery_Event_Lineage_Model.md` | Defines append-only audit/recovery lineage, recovery item rules, evidence rules, and example lineages. |
| `09060_Implementation_Deferred_Data_Model_Boundary.md` | Defines what 5000 docs may contain and explicitly blocks premature SQL, schema, RPC, RLS, API, UI, POS, payment, printer, loyalty, Franchise OS, and AI/CRM/ad implementation. |
| `09070_Context_Entity_Alignment_Model.md` | Aligns conceptual context entities with `03020`; parallel context axes without schema collapse. |
| `09080_Runtime_Profile_And_Change_Request_Entity_Model.md` | Conceptual entities for runtime profiles, change requests, approvals, activation, emergency disable, and rollback. |
| `09090_Order_Candidate_And_Confirmation_State_Refinement.md` | Refines order candidate through POS-confirmed and recovery states without overstating truth. |
| `09100_Admin_Support_Audit_Entity_Lineage_Model.md` | Conceptual event lineage for admin, support, runtime changes, audit review, recovery, and export. |
| `09110_Future_Profile_And_Analytics_State_Boundary.md` | Future membership, analytics, AI/CRM/ad, and Franchise OS state boundaries. |

`09010`~`09060` are existing conceptual data/state foundations.

`09070`~`09110` align the state/data model with `03000` SaaS runtime and `07000` Admin Console consolidation.

This domain remains conceptual and does not approve schema.

## 4 Consolidation Notes

`09010` remains draft/candidate notes.

`09020` remains the handoff state machine.

`09030`~`09060` consolidate entity, ownership, lineage, and implementation-deferred boundaries.

`09070`~`09110` align context, runtime profile, order confirmation, admin/support audit lineage, and future state boundaries.

The `09000_data_model_state_machine` namespace stays flat with no subfolders for now.

Subfolders may be introduced later if the project expands.

## 5 Out Of Scope

- SQL, migrations, production schema, Supabase functions, RPC, and generated types.
- Physical table definitions, columns, RLS, Edge Functions, and app code.

## 6 Current Status

Status: conceptual data model consolidation wave complete. No SQL. No migration. Not schema approval.
