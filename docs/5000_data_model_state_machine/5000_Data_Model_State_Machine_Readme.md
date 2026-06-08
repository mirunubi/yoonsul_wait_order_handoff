# 5000 Data Model State Machine Readme

## 1 Purpose

This folder defines conceptual data model and state machine design only.

## 2 In Scope

- Conceptual entities.
- State names and transitions.
- Data ownership boundaries.
- Draft table/entity naming at design level.

## 3 Document List

| document | description |
| --- | --- |
| `5010_Data_Model_Draft.md` | Defines the first conceptual entity set for tenant, store, session, handoff, menu snapshot, order intent, staff action, handoff event, and audit event. |
| `5020_Handoff_State_Machine.md` | Defines conceptual customer, waiting, handoff, Mini Kiosk, and store runtime visibility states with transition, recovery, and audit principles. |

## 4 Out Of Scope

- SQL, migrations, production schema, Supabase functions, RPC, and generated types.

## 5 Current Status

Status: initial conceptual data namespace. No SQL. No migration.
