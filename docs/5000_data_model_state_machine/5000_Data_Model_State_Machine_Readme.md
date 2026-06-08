# 5000 Data Model State Machine Readme

## 1 Purpose

This folder defines conceptual data model and state machine design only.

## 2 In Scope

- Conceptual entities.
- State names and transitions.
- Data ownership boundaries.
- Draft table/entity naming at design level.
- Entity master consolidation.
- State/event ownership and truth boundaries.
- Audit/recovery event lineage.
- Implementation-deferred data model boundary.

## 3 Document List

| document | description |
| --- | --- |
| `5010_Data_Model_Draft.md` | Remains draft/candidate notes for conceptual entities and table naming ideas. |
| `5020_Handoff_State_Machine.md` | Remains the conceptual customer, waiting, handoff, Mini Kiosk, and store runtime visibility state machine. |
| `5030_Conceptual_Entity_Master.md` | Consolidates conceptual entity candidates across SaaS context, runtime configuration, customer/session runtime, menu/order intent, store operation, admin/governance, recovery/audit/compliance, and future intelligence. |
| `5040_State_And_Event_Ownership_Model.md` | Defines truth families, event authority types, state ownership, and forbidden ownership collapses. |
| `5050_Audit_Recovery_Event_Lineage_Model.md` | Defines append-only audit/recovery lineage, recovery item rules, evidence rules, and example lineages. |
| `5060_Implementation_Deferred_Data_Model_Boundary.md` | Defines what 5000 docs may contain and explicitly blocks premature SQL, schema, RPC, RLS, API, UI, POS, payment, printer, loyalty, Franchise OS, and AI/CRM/ad implementation. |

## 4 Consolidation Notes

`5010` remains draft/candidate notes.

`5020` remains the handoff state machine.

`5030~5060` consolidate entity, ownership, lineage, and implementation-deferred boundaries.

The `5000_data_model_state_machine` namespace stays flat with no subfolders for now.

Subfolders may be introduced later if the project expands.

## 5 Out Of Scope

- SQL, migrations, production schema, Supabase functions, RPC, and generated types.

## 6 Current Status

Status: initial conceptual data namespace. No SQL. No migration.
