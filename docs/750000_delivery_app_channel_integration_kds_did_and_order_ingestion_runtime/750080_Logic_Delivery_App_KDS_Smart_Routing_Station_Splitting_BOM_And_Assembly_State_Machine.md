# 750080_Logic_Delivery_App_KDS_Smart_Routing_Station_Splitting_BOM_And_Assembly_State_Machine.md

## 1. Purpose

This document defines the runtime logic for delivery-app-originated orders that must be routed into KDS station screens, assembly/packing workflow, and DID/customer-rider callout surfaces.

The goal is to prevent a delivery app order from becoming a single unstructured kitchen ticket. Instead, every order must be normalized, decomposed by menu/BOM/station rules, routed to the correct kitchen work areas, tracked through explicit state transitions, and emitted to DID only when the order is actually ready for pickup.

This document belongs to:

```text
docs/700000_runtime_flow_bundle/750000_delivery_app_channel_integration/
```

It is part of the 750000 Delivery App Channel Integration runtime flow bundle.

## 2. Runtime Scope

This logic applies to:

- delivery app order intake,
- channel adapter normalization,
- menu and option mapping,
- BOM decomposition,
- station routing,
- KDS card creation,
- station-level bump handling,
- assembly and packing readiness,
- DID callout trigger,
- rider/customer pickup visibility,
- audit and evidence event generation.

This logic does not implement provider-specific API calls directly. Provider-specific authentication, webhook verification, HMAC signing, polling, OAuth, whitelist, or partner gateway rules must remain in separate adapter documents and implementation modules.

## 3. Core Runtime Principle

A delivery-app order must not be treated as a printable receipt.

It must be treated as a structured runtime event:

```text
Delivery App Order
  -> Channel Event
  -> Normalized Order
  -> POS Projection
  -> KDS Order Card
  -> Station Work Items
  -> Assembly/Packing State
  -> DID Pickup Callout
  -> Audit/Evidence Trace
```

The KDS logic must preserve enough structure to answer:

- which channel produced the order,
- which store received it,
- which menu and option mapping was applied,
- which station work items were generated,
- which station completed each work item,
- when assembly became possible,
- when packing became complete,
- when DID callout was triggered,
- which audit/evidence records support the runtime result.

## 4. Input Event Model

### 4.1 Required Input Fields

Every normalized delivery-app order event should include:

| Field | Requirement | Notes |
|---|---|---|
| `channel_order_id` | Required | Original order identifier from delivery app or partner gateway. |
| `channel_code` | Required | BAEMIN / YOGIYO / COUPANG_EATS / partner-specific code. |
| `store_id` | Required | Internal store identifier. |
| `received_at` | Required | Server-side receipt timestamp. |
| `accepted_at` | Conditional | Required after store/POS acceptance. |
| `order_type` | Required | DELIVERY / TAKEOUT / PICKUP / CHANNEL_SPECIFIC. |
| `items[]` | Required | Menu lines after normalization. |
| `options[]` | Conditional | Option lines, modifiers, exclusions, add-ons. |
| `customer_note` | Conditional | Must be redacted from KDS/DID where not operationally required. |
| `pickup_eta` | Conditional | If provided by channel or calculated internally. |
| `rider_info` | Conditional | Must be minimized and masked. |
| `privacy_profile` | Required | Indicates masking/tokenization rules. |
| `change_id` | Required for implementation/test trace | Must map to audit/evidence packet during development and release. |

### 4.2 Prohibited Input Handling

The system must not:

- parse delivery-app orders from screenshots,
- scrape customer information from app UI,
- hook memory of partner applications,
- store raw customer addresses in KDS cards,
- pass raw phone numbers to DID,
- treat unknown provider state as accepted,
- route unmapped menu items silently,
- generate kitchen work items without audit trace.

## 5. Normalization Logic

### 5.1 Channel Event Normalization

Each provider-specific payload must be converted into a normalized internal order shape before KDS routing.

```text
Provider Payload
  -> signature/auth validation
  -> duplicate check
  -> store mapping
  -> menu mapping
  -> option mapping
  -> privacy masking profile
  -> normalized_order_event
```

Provider-specific payload fields must not leak into KDS logic unless explicitly mapped.

### 5.2 Menu Mapping

Each item must map to:

- internal menu code,
- display name for kitchen,
- preparation category,
- station routing group,
- BOM decomposition profile,
- option handling profile,
- make-time estimate profile,
- allergen or caution flags if applicable.

If a menu item cannot be mapped, the order must enter a controlled exception state.

```text
UNMAPPED_MENU_ITEM -> HOLD_FOR_OPERATOR_REVIEW
```

The system must not guess a menu mapping based on similar text.

### 5.3 Option Mapping

Options must be normalized into operational instructions.

Examples:

| Channel Option | Internal Meaning | KDS Impact |
|---|---|---|
| `양파 제외` | Remove onion | Assembly station instruction. |
| `얼음 적게` | Low ice | Beverage station instruction. |
| `맵게` | Spicy level modifier | Main station instruction. |
| `소스 추가` | Add sauce | Packing or assembly instruction depending on menu. |

Unmapped options must not be dropped silently.

Allowed handling:

```text
UNMAPPED_OPTION -> show as operator-visible caution + audit event
```

Forbidden handling:

```text
UNMAPPED_OPTION -> ignore
```

## 6. BOM Decomposition Logic

### 6.1 BOM Definition

A menu item may be decomposed into station-level work items.

Example:

```text
Cheeseburger Set
  -> Grill: beef patty x1
  -> Assembly: bun + cheese + vegetable + sauce
  -> Fryer: fries x1
  -> Beverage: cola x1
  -> Packing: set bag + receipt/order label
```

The BOM decomposition must be deterministic and versioned.

### 6.2 BOM Version Rule

Every decomposition must reference a BOM version:

```text
menu_code: CHEESEBURGER_SET
bom_version: 2026-06-19.v1
```

If the BOM changes, historical orders must remain traceable to the BOM version used at order time.

### 6.3 BOM Failure Handling

If BOM lookup fails:

```text
BOM_LOOKUP_FAILED -> KDS_ROUTING_HOLD
```

The order must not proceed to station routing until the missing mapping is resolved or manually overridden with evidence.

## 7. Station Routing Logic

### 7.1 Station Routing Rule

Each normalized work item must be assigned to one or more kitchen stations.

Common station types:

- intake/expeditor,
- grill,
- fryer,
- noodle/soup,
- cold station,
- beverage,
- assembly,
- packing,
- pickup handoff.

### 7.2 Routing Decision Inputs

Station assignment may depend on:

- menu code,
- BOM component,
- option profile,
- store layout,
- equipment availability,
- channel priority policy,
- pickup ETA,
- current station load,
- manual degradation mode.

### 7.3 Routing Output

Each station work item should include:

| Field | Description |
|---|---|
| `station_work_item_id` | Internal station-level item ID. |
| `parent_order_id` | Internal normalized order ID. |
| `station_code` | Target station. |
| `menu_code` | Internal menu code. |
| `bom_component_code` | BOM component if applicable. |
| `quantity` | Station-specific quantity. |
| `option_instruction` | Station-specific instruction only. |
| `priority` | Runtime queue priority. |
| `due_at` | Expected station completion time. |
| `status` | Station item state. |

## 8. State Machine

### 8.1 Order-Level State Machine

```text
RECEIVED
  -> VALIDATED
  -> ACCEPTED
  -> NORMALIZED
  -> ROUTED_TO_KDS
  -> IN_PROGRESS
  -> PARTIALLY_BUMPED
  -> READY_FOR_ASSEMBLY
  -> PACKING
  -> READY_FOR_PICKUP
  -> DID_CALLED
  -> PICKED_UP
  -> CLOSED
```

Exception states:

```text
REJECTED_BY_STORE
CHANNEL_CANCELLED
UNMAPPED_MENU_HOLD
KDS_ROUTING_HOLD
STATION_FAILURE_HOLD
ASSEMBLY_BLOCKED
DID_CALLOUT_FAILED
PRIVACY_REDACTION_FAILED
MANUAL_FALLBACK
CANCELLED_AFTER_ACCEPTANCE
UNKNOWN_CHANNEL_STATE
```

### 8.2 Station-Level State Machine

```text
PENDING
  -> VISIBLE_ON_STATION_KDS
  -> STARTED
  -> BUMPED
  -> CONFIRMED_FOR_ASSEMBLY
```

Exception states:

```text
STATION_REASSIGNED
STATION_SKIPPED_BY_RULE
STATION_BLOCKED
STATION_MANUAL_COMPLETE
STATION_CANCELLED
```

### 8.3 Assembly/Packing State Machine

```text
WAITING_FOR_COMPONENTS
  -> COMPONENTS_READY
  -> ASSEMBLY_STARTED
  -> ASSEMBLY_COMPLETE
  -> PACKING_STARTED
  -> PACKING_COMPLETE
  -> READY_FOR_PICKUP
```

The order must not trigger DID callout before `READY_FOR_PICKUP`.

### 8.4 DID State Machine

```text
NOT_VISIBLE
  -> READY_TO_CALL
  -> DISPLAYED
  -> ANNOUNCED
  -> ACKNOWLEDGED_OR_EXPIRED
```

DID must show only permitted pickup identifiers.

Forbidden DID display:

- raw customer name where not required,
- phone number,
- full address,
- customer note,
- payment detail,
- internal exception detail.

Allowed DID display:

- pickup number,
- masked order identifier,
- channel-neutral pickup code,
- rider pickup code if permitted,
- store-defined callout label.

## 9. Bump Logic

### 9.1 Station Bump

A station bump means the station declares its assigned work item complete.

A station bump must record:

- station ID,
- station work item ID,
- parent order ID,
- actor/device ID,
- timestamp,
- previous state,
- next state,
- exception flag if manual,
- audit event ID.

### 9.2 Duplicate Bump Handling

Duplicate station bumps must be idempotent.

```text
same station_work_item_id + same next_state
  -> no duplicate transition
  -> record duplicate bump observation if needed
```

A duplicate bump must not cause:

- duplicate assembly readiness,
- duplicate DID callout,
- duplicate customer notification,
- duplicate audit finality event.

### 9.3 Early Bump Handling

If a station bumps before the work item was visible or started:

```text
EARLY_BUMP -> accept only if configured, otherwise STATION_EXCEPTION_HOLD
```

The decision must be explicit per store/station policy.

## 10. Assembly Readiness Logic

The order becomes `READY_FOR_ASSEMBLY` only when all required station work items reach a completion state.

```text
all(required_station_items.status in [BUMPED, CONFIRMED_FOR_ASSEMBLY])
  -> READY_FOR_ASSEMBLY
```

Optional or skipped components must be declared by rule. They cannot disappear from the readiness calculation silently.

## 11. Packing And DID Callout Logic

### 11.1 Ready For Pickup

The order becomes `READY_FOR_PICKUP` only after:

- assembly complete,
- packing complete,
- cancellation check passed,
- privacy-safe pickup identifier generated,
- DID payload generated,
- audit event prepared.

### 11.2 DID Callout Trigger

DID callout is triggered only once per ready order unless manually re-announced.

Idempotency key:

```text
did_callout_idempotency_key = store_id + internal_order_id + ready_for_pickup_event_id
```

### 11.3 DID Failure Handling

If DID callout fails:

```text
READY_FOR_PICKUP -> DID_CALLOUT_FAILED
```

The order may still be handed off manually, but the failure must be visible to the operator and logged as evidence.

## 12. Cancellation And Unknown State Handling

### 12.1 Cancellation Before Acceptance

```text
RECEIVED / VALIDATED -> CHANNEL_CANCELLED -> CLOSED
```

No KDS station work should be created if cancellation is confirmed before acceptance.

### 12.2 Cancellation After KDS Routing

```text
ROUTED_TO_KDS / IN_PROGRESS / PARTIALLY_BUMPED
  -> CANCELLED_AFTER_ACCEPTANCE
  -> station cancellation markers
  -> packing/DID disabled
```

Already-prepared food handling is an operational policy and must be logged separately.

### 12.3 Unknown Channel State

If delivery app state is unknown:

```text
UNKNOWN_CHANNEL_STATE -> HOLD_FOR_OPERATOR_REVIEW
```

The system must not infer:

- accepted,
- cancelled,
- completed,
- picked up.

Unknown state must never produce DID pickup finality.

## 13. Privacy And Display Logic

### 13.1 KDS Display

KDS may display operationally necessary information only.

Allowed examples:

- menu name,
- quantity,
- option instructions,
- channel badge,
- pickup ETA,
- masked pickup code,
- caution flag.

Restricted examples:

- full customer address,
- raw phone number,
- payment instrument detail,
- unnecessary customer identity,
- unrelated customer memo.

### 13.2 Station-Specific Redaction

Not every station needs every instruction.

Example:

```text
Beverage station:
  show: drink item, ice option, sugar option
  hide: burger option, customer address, rider note

Grill station:
  show: patty type, doneness if applicable, quantity
  hide: beverage option, customer address, pickup phone
```

### 13.3 DID Redaction

DID is a public or semi-public surface. Its redaction level must be stricter than KDS.

## 14. Audit Ledger Rules

Every material transition must emit an audit event.

Required events:

- delivery order received,
- provider/auth validation result,
- duplicate intake detected,
- order accepted/rejected,
- normalized order created,
- menu/option mapping result,
- BOM decomposition result,
- KDS routing result,
- station bump,
- assembly readiness,
- packing complete,
- DID callout attempted,
- DID callout success/failure,
- manual override,
- cancellation,
- unknown state hold,
- privacy redaction failure.

Audit events must include:

- `change_id` when produced during a controlled implementation/test cycle,
- runtime order ID,
- channel order ID where permitted,
- store ID,
- previous state,
- next state,
- actor/device if applicable,
- timestamp,
- evidence packet reference.

## 15. Evidence Packet Rules

Each implementation or field test must preserve:

```text
docs/implementation_evidence/<change_id>/
  impact_scope.md
  context_snapshot.md
  logic.md
  test_plan.md
  implementation_module.md
  verification_result.md
  raw_logs/
  audit_review.md
```

For KDS/DID delivery-app runtime tests, evidence should include:

- normalized sample order payload with redaction,
- station routing result,
- KDS card rendering evidence if available,
- DID payload evidence,
- audit ledger sample,
- privacy masking sample,
- duplicate bump test result,
- cancellation/unknown-state test result.

## 16. Financial And Operational Accident Scenarios

The following scenarios must be tested before production-grade release:

| Scenario | Required Control |
|---|---|
| Duplicate delivery app webhook | Intake idempotency and no duplicate KDS cards. |
| Duplicate station bump | No duplicate assembly/DID finality. |
| Unknown provider state | Hold, no DID finality. |
| Cancellation after kitchen start | Station cancellation marker, DID disabled. |
| Unmapped menu | Hold, operator review, no guessed mapping. |
| Unmapped option | Caution/audit, no silent drop. |
| DID failure | Manual handoff allowed with evidence. |
| Privacy masking failure | Block public display. |
| Wrong station routing | Audit and manual correction evidence. |
| BOM version mismatch | Block or controlled override. |
| Change ID missing in evidence | Audit block during controlled implementation. |

## 17. Test Requirements

Required tests:

- order normalization test,
- menu mapping test,
- option mapping test,
- BOM decomposition test,
- station routing test,
- station bump idempotency test,
- assembly readiness test,
- DID callout idempotency test,
- cancellation before acceptance test,
- cancellation after KDS routing test,
- unknown channel state hold test,
- KDS redaction test,
- DID redaction test,
- audit event mapping test,
- evidence packet mapping test.

## 18. 51355 Pipeline Context Slice

When this document is used inside the 51355 AI-assisted development pipeline, the context snapshot should include only the following documents unless the impact scope requires more:

```text
750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md
750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md
750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md
750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md
750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md
750070_SOP_Delivery_App_Order_Intake_KDS_Routing_Bump_And_DID_Callout_Runtime.md
750080_Logic_Delivery_App_KDS_Smart_Routing_Station_Splitting_BOM_And_Assembly_State_Machine.md
```

Do not inject unrelated UI, loyalty, finance, or admin-console rules unless Cursor Stage 1 explicitly identifies them as impacted.

## 19. Implementation Boundary

Implementation must not begin from this logic document alone.

Before implementation:

1. Cursor must produce an impact scope.
2. Required context snapshot must be sliced.
3. Claude must produce overview, logic, test plan, and change contract.
4. Human must approve allowed files and allowed operations.
5. Codex must implement only inside the approved boundary.
6. Automated gate must capture raw logs and git diff.
7. Claude audit must review state logic, privacy, evidence, and accidents.

## 20. Final Rule

The final rule is:

```text
No delivery-app order becomes kitchen truth until it is normalized.
No normalized order becomes station work until it is mapped.
No station work becomes assembly-ready until all required bumps are complete.
No assembly-ready order becomes pickup-visible until packing is complete.
No pickup-visible order may expose customer private data.
No KDS/DID transition is final without audit and evidence.
```
