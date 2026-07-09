# 019000_Readme_Data_Model_State_Machine_And_Runtime_Event_Contract

## Purpose

This folder is the documentation domain for data models, runtime state machines, and runtime event contracts for CatchMenu / Catch & Order.

## Scope

- Data model documentation model and governance boundary (no runtime implementation)
- Runtime state machine control and event contract master control
- Order, queue/waiting, payment, and cancel/refund state models
- POS Gateway event model, KDS event projection model, kiosk event submission model
- Customer center event model and admin console event model
- External provider event contract and webhook event contract (field/signature mapping)
- Settlement reconciliation data model and audit trail field model
- Idempotency/duplicate-prevention keys, retention/archive/deletion model
- RLS ownership and tenant boundary model
- Test fixture / mock event model

## File List

- `019179_Index_Data_Model_State_Machine_And_Runtime_Event_Contract_Expansion_Wave_1.md` — full manifest of the 80-document Wave 1 batch (Batch 7I)
- `019100`-`019178` — governance, overview, boundary, checklist, matrix, report, and audit documents per the areas listed above

## Non-Scope

- Runtime implementation, SQL, Flutter/Dart, or Supabase changes
