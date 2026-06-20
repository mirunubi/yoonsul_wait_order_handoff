# 005020_Guide_User_Flow.md

## 1 Purpose

This document defines the customer-facing handoff flow for `yoonsul_wait_order_handoff`.

The core purpose is to reduce the delay between waiting, seating, order intent capture, store review, and store-side preparation.

## 2 In Scope

- Store discovery through QR, NFC, shared link, or direct URL.
- Waiting registration and waiting session creation.
- Preorder recommendation or customer-led menu browsing.
- Optional preorder intent before arrival or seating.
- Arrival, near-store, called, seated, pickup, confirmation, notification, completion, cancellation, no-show, and recovery flows.
- Flow distinctions for waiting handoff, Mini Kiosk, non-face-to-face order, multilingual visitor, and store staff assisted modes.

## 3 Out Of Scope

- App implementation.
- UI component design.
- API contract.
- SQL or database schema.
- Payment processing.
- POS deep integration.
- KDS automation.
- Printer or device protocol.

## 4 Main Actors

- Customer: enters store context, registers or joins waiting, browses menu, creates order intent, receives notifications.
- Store staff: confirms waiting, calls customer, assigns table or pickup path, reviews handoff order intent, confirms or recovers.
- Store manager: handles exceptions, manual recovery, and policy decisions.
- Store runtime: exposes visible operational state such as normal, busy, delayed, degraded, or manual recovery required.

## 5 Flow Modes

### 5.1 Waiting Handoff Mode

Waiting handoff mode is the primary MVP flow.

```text
QR / NFC / link entry
  -> store context loaded
  -> waiting registration
  -> waiting session creation
  -> preorder recommendation or menu browsing
  -> optional preorder intent
  -> called / arrived
  -> seat or table assignment
  -> order handoff confirmation
  -> preparation visibility
  -> customer notification
  -> completed / cancelled / no-show / recovery
```

### 5.2 Mini Kiosk Mode

Mini Kiosk mode is used when the store needs lightweight menu browsing and order intent capture without waiting management.

```text
store menu link opened
  -> language selected if needed
  -> menu browsing
  -> order intent captured
  -> staff review or confirmation
  -> customer notification
  -> completed / cancelled / expired
```

### 5.3 Non-Face-To-Face Order Mode

Non-face-to-face order mode keeps customer ordering and staff confirmation separated from in-person conversation.

The customer may be outside the store, near the store, seated, or in pickup mode.
Store confirmation is still required before the order becomes store-executable in the MVP.

### 5.4 Multilingual Visitor Mode

Multilingual visitor mode lets the customer browse menu names, descriptions, option labels, and guidance in a selected language.

The MVP treats multilingual content as store-provided display data.
It does not require AI translation.

### 5.5 Store Staff Assisted Mode

Store staff assisted mode lets staff help a customer create or repair a handoff session when the customer cannot complete the flow alone.

Staff assistance must preserve audit visibility.

### 5.6 Mode Separation By Adoption Depth

The detailed state machine is defined in `docs/09000_data_model_state_machine/009020_Handoff_State_Machine.md`.

Customer-facing wording differs by integration level:

- order candidate.
- preorder request.
- staff-confirmed order.
- POS-confirmed order.

Mode separation:

- Waiting handoff mode: waiting, menu browsing, order candidate, seating/table or pickup handoff, and staff confirmation.
- Mini Kiosk only mode: menu browsing, language support, order candidate, and staff confirmation without waiting.
- Staff/admin confirmation mode: staff reviews the order candidate and manually enters POS when needed.
- Store Agent/printer option: optional order ticket or local handoff support, without guaranteed POS sales creation.
- POS API integrated option: POS order creation may occur only when the store POS supports reliable external order API.
- Full OS option: available only where POS, KDS, membership, CMS, Agent, and Audit can be controlled or deeply coordinated.

## 6 Flow Stages

### 6.1 Store Discovery / QR / Link Entry

The customer enters the store context through QR, NFC, direct link, shared waiting link, or Mini Kiosk URL.

Expected result:

- store context is loaded.
- supported modes are visible.
- language selection can be offered.

### 6.2 Waiting Registration

The customer enters basic waiting information such as party size, display name, or store-defined lightweight contact method.

Entrance waiting assist device SOP may reduce web/app friction for phone-number-based waiting registration and optional preorder continuation; see `005060_SOP_Entrance_Waiting_Assist_Device_Operation.md`.

Expected result:

- customer session becomes active.
- waiting registration can be submitted.

### 6.3 Waiting Session Creation

The store runtime creates or confirms a waiting session.

Expected result:

- waiting session is linked to customer session.
- waiting status is visible to customer and staff.

### 6.4 Preorder Recommendation Or Customer Menu Browsing

The customer may browse menu categories, photos, descriptions, options, and prices while waiting.

The store may recommend preorder preparation, but the customer remains free to browse manually.

### 6.5 Optional Preorder Intent

The customer may create an order intent before being seated or before pickup confirmation.

Expected result:

- order intent is linked to customer session.
- order intent is linked to waiting session when waiting mode is active.
- store review remains required before execution.

### 6.6 Arrival / Near-Store / Called State

The customer may be marked near-store, called, arrived, or no-show candidate depending on store operation.

Expected result:

- staff can identify whether the customer is ready for handoff.
- customer can receive guidance.

### 6.7 Seat / Table Assignment Or Pickup Mode

Staff assigns a table number for dine-in flow or confirms pickup mode for non-seated flow.

Expected result:

- handoff session becomes ready for store confirmation.
- staff can review order intent with seat, table, or pickup context.

### 6.8 Order Handoff Confirmation

Staff reviews order intent and confirms, asks for adjustment, cancels, or sends to recovery.

Expected result:

- confirmed order handoff is ready for manual POS entry or store-side preparation handling.
- MVP does not require automated POS submission.

### 6.9 Kitchen / Store-Side Preparation Visibility

The customer may see high-level visibility such as accepted, preparing, delayed, ready, or staff assistance required.

This is visibility only.
It is not KDS automation.

### 6.10 Customer Notification

The customer receives status notification for called, table assigned, confirmation required, confirmed, delayed, ready, cancelled, expired, or recovery required.

### 6.11 Completion / Cancellation / No-Show / Recovery

The flow ends through completion, customer cancellation, store cancellation, no-show handling, expiration, or recovery.

Recovery keeps the staff path visible rather than silently failing.

## 7 Failure And Recovery Cases

- Store context cannot load: show retry, staff assistance, or direct store contact path.
- Waiting registration is incomplete: return customer to required fields.
- Waiting session duplicate is suspected: staff can merge or choose the active session later.
- Menu item becomes unavailable: order intent requires customer adjustment or staff recovery.
- Customer is called but does not arrive: mark no-show candidate before final no-show handling.
- Table assignment changes: handoff session must update visible table context.
- Staff rejects order intent: customer is notified and may edit or cancel.
- Customer language content is missing: fallback to store default language.
- Store runtime is delayed or degraded: customer notification should avoid over-promising.
- Manual recovery required: staff action and audit event should be preserved conceptually.

## 8 Open Decisions

- Whether near-store detection is customer-declared, staff-declared, or location-assisted.
- Whether waiting registration requires phone, nickname, party size only, or store-configurable fields.
- Whether Mini Kiosk mode creates a separate session or reuses customer session.
- How much preparation visibility is shown before KDS integration exists.
- Whether multilingual content is entered by store staff, imported, or translated by later tooling.
- Which customer notifications are in-app only versus SMS, messenger, or display-board linked.
