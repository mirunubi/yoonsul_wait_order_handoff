# 750010_Assessment_Delivery_App_Channel_API_KDS_DID_And_Omnichannel_Order_Ingestion_Architecture.md

## 1. Document Purpose

This assessment defines the delivery-app channel API, KDS, DID, and omnichannel order ingestion architecture for `yoonsul_wait_order_handoff`.

This document belongs to the `750000_delivery_app_channel_integration` runtime flow bundle under:

```text
docs/700000_runtime_flow_bundle/750000_delivery_app_channel_integration/
```

The purpose is to convert the external delivery-app and kitchen automation research context into a controlled implementation planning asset.

This document does not authorize runtime implementation.

It defines:

- delivery-app channel ingestion architecture,
- official API boundary,
- no-scraping policy direction,
- KDS/DID runtime relationship,
- kitchen station routing concepts,
- order state synchronization risks,
- customer privacy and masking risks,
- integration evidence requirements,
- downstream Flow Bundle documents required before code handoff.

## 2. Source Context Summary

The delivery-app and kitchen automation domain has shifted from paper kitchen tickets and local terminal-based workflows toward official API-driven omnichannel order ingestion.

The uploaded research report describes a market transition from:

```text
Delivery app / POS / kiosk order
  -> kitchen printer / paper ticket
  -> manual kitchen handling
  -> manual customer or rider callout
```

to:

```text
Delivery app / POS / kiosk order
  -> official API / gateway ingestion
  -> normalized order event
  -> KDS station routing
  -> cook state / bump event
  -> DID customer or rider callout
  -> evidence / KPI / bottleneck logging
```

This transition matters because KDS/DID is not merely a display replacement for paper tickets.

It becomes a runtime control layer for:

- order intake,
- channel normalization,
- station-level routing,
- preparation timing,
- rider pickup readiness,
- customer waiting-state visibility,
- kitchen bottleneck analytics,
- privacy-retention enforcement,
- operational evidence generation.

## 3. Domain Scope

### 3.1 In Scope

This assessment covers:

- delivery-app order ingestion,
- delivery-app official API integration boundary,
- POS-to-KDS order handoff,
- kiosk-to-KDS order handoff,
- KDS-to-DID order callout,
- kitchen station routing,
- delivery rider pickup readiness signals,
- order status synchronization between external channel and internal runtime,
- customer privacy masking after fulfillment,
- external API credential and signature security,
- failure and degraded-mode risks,
- evidence and operational KPI capture.

### 3.2 Out Of Scope

This assessment does not define:

- concrete API implementation,
- database migration SQL,
- Flutter screen implementation,
- POS provider-specific runtime adapter code,
- vendor contract terms,
- production deployment steps,
- live credential handling,
- scraping or reverse-engineering procedure.

Any implementation must go through the controlled 51355 development pipeline before code changes.

## 4. Target Runtime Position

The delivery-app channel integration domain sits between external order channels and store runtime operations.

```text
External Delivery App Channels
  - Baemin
  - Yogiyo
  - Coupang Eats
  - future delivery channels

        ↓ official API / partner bridge / webhook / polling

Delivery Channel Ingestion Boundary
  - authentication
  - signature verification
  - channel normalization
  - duplicate prevention
  - idempotency
  - privacy minimization

        ↓ normalized order event

Store Runtime Order Core
  - order state machine
  - payment status projection
  - preparation state
  - pickup state

        ↓ station routing

KDS Runtime
  - station split
  - bump event
  - preparation timing
  - kitchen exception event

        ↓ completion event

DID Runtime
  - customer callout
  - rider pickup display
  - waiting-state projection
```

## 5. Key Architectural Finding

The core architectural finding is:

```text
Delivery-app integration must not be treated as a simple order import feature.
It is an external channel runtime boundary that directly affects kitchen execution, customer waiting state, rider pickup timing, privacy retention, and evidence logging.
```

Therefore, this domain must be handled as a Flow Bundle with explicit state, evidence, and fallback rules.

## 6. Official API Boundary

### 6.1 Required Direction

The system must prefer official API, partner gateway, documented bridge, or provider-approved integration paths.

The target direction is:

```text
Official API / approved partner bridge only.
No scraping.
No memory hooking.
No unsupported screen capture workflow.
No silent credential reuse.
```

### 6.2 Risk Of Scraping-Based Integration

Scraping or unofficial extraction creates unacceptable risk:

- platform UI change causes runtime outage,
- customer personal data may be over-collected,
- provider terms may be violated,
- security audit evidence becomes weak,
- order status may be misread,
- retry behavior becomes uncontrolled,
- customer or rider notification may become false.

### 6.3 API Security Patterns To Expect

Delivery-channel integration may require one or more of the following:

- OAuth-style authorization,
- merchant token mapping,
- vendor ID mapping,
- access key and secret key,
- HMAC request signing,
- timestamp validation,
- IP whitelist,
- webhook signature validation,
- polling with idempotency cursor,
- channel-specific order ID mapping,
- provider-specific error code translation.

No implementation may assume that one delivery app's integration model generalizes to another.

## 7. Omnichannel Ingestion Model

### 7.1 Channel Types

The runtime must distinguish at least:

- dine-in POS order,
- kiosk order,
- table order,
- QR order,
- takeout order,
- delivery-app order,
- delivery-agency-linked order,
- manual fallback order.

### 7.2 Normalized Order Event

Each external order must be normalized before entering internal runtime.

Minimum normalized fields:

```text
normalized_order_id
external_channel
external_store_id
external_order_id
merchant_id
store_id
order_type
order_received_at
requested_pickup_at
menu_items
option_items
customer_request_text
rider_request_text
payment_projection
privacy_payload_class
source_signature_status
idempotency_key
raw_payload_evidence_ref
```

### 7.3 Channel Payload Preservation

The system should preserve enough raw payload evidence for debugging and audit, but it must not preserve unnecessary customer personal information.

Raw payload handling must follow:

```text
Raw payload is evidence, not operational storage.
Operational runtime uses normalized and minimized fields.
Personal data retention must be bounded and masked.
```

## 8. KDS Runtime Assessment

### 8.1 KDS Is A State-Machine Surface

KDS is not only a screen.

It is a runtime state surface for:

- accepted,
- queued,
- cooking,
- station ready,
- assembly pending,
- completed,
- pickup ready,
- delayed,
- cancelled,
- failed handoff,
- manual override.

### 8.2 Station Routing

KDS routing may split one order into station-specific work cards.

Example:

```text
Burger set order
  -> grill station: patty
  -> fryer station: fries
  -> beverage station: drink
  -> assembly station: package set
```

This requires station-level state tracking.

### 8.3 Bump Event

A KDS bump event is a material runtime event.

It may trigger:

- station completion,
- assembly readiness,
- DID callout,
- rider pickup readiness,
- preparation time metric,
- exception closure,
- audit event,
- customer-facing state projection.

Therefore, bump events must be idempotent and traceable.

## 9. DID Runtime Assessment

### 9.1 DID Is A Customer And Rider Projection Surface

DID displays must be treated as projections of internal runtime state.

They must not become the source of truth.

```text
KDS / order state machine = source of truth.
DID = externalized projection.
```

### 9.2 DID Callout Risks

Incorrect DID callout may cause:

- customer confusion,
- wrong pickup,
- rider pickup before food is ready,
- counter congestion,
- customer complaint,
- refund or remake dispute,
- evidence gap.

### 9.3 DID Minimal Display Principle

DID should display only minimum necessary information.

Recommended display payload:

```text
order display number
pickup zone
status label
estimated readiness state
```

Avoid showing:

- full customer name,
- full phone number,
- full address,
- sensitive request text,
- payment details.

## 10. Privacy, Masking, And Retention Boundary

Delivery-app orders may include personal data such as phone number, address, request text, and delivery instructions.

The runtime must enforce:

- data minimization,
- purpose limitation,
- masking after fulfillment,
- retention window control,
- evidence redaction,
- access control,
- audit logging for privileged view.

### 10.1 Privacy Classes

Suggested classes:

| Class | Example | Runtime Handling |
|---|---|---|
| P0 | order display number | safe for DID projection |
| P1 | menu item / option | operational use allowed |
| P2 | customer request text | limited operational use |
| P3 | phone / address | masked, time-bounded, access-controlled |
| P4 | payment / identity data | never display on KDS/DID unless explicitly required and approved |

### 10.2 Masking Rule

After order completion or delivery completion, customer personal data must be masked or removed according to the approved privacy-retention policy.

No KDS/DID implementation may store full personal payload indefinitely.

## 11. Failure And Degraded Mode Assessment

Delivery-app channel integration must define fallback behavior for:

- delivery-app API outage,
- webhook delay,
- duplicate webhook,
- polling gap,
- provider token expiration,
- signature verification failure,
- network split between POS and KDS,
- KDS station offline,
- DID offline,
- delayed rider pickup signal,
- order cancel after kitchen start,
- order cancel after station completion,
- privacy masking job failure,
- raw payload evidence write failure.

### 11.1 Manual Fallback Principle

Manual fallback must be explicit.

```text
If digital ingestion fails, staff may operate manually.
But manual fallback must leave a recovery event or exception record.
```

### 11.2 No False Finality

The system must not tell the customer, rider, or delivery platform that an order is complete unless the internal state supports that conclusion.

Unknown state must remain unknown until reconciled.

## 12. Evidence Requirements

Each integration run or implementation module must preserve evidence for:

- external channel mapping,
- credential handling boundary,
- webhook signature verification,
- idempotency key behavior,
- duplicate event behavior,
- KDS station routing,
- DID projection,
- privacy masking,
- failure handling,
- manual fallback,
- operator override,
- raw log capture,
- test result.

Evidence artifacts should include:

```text
impact_scope.md
context_snapshot.md
overview.md
logic.md
test_plan.md
change_contract.md
implementation_approval.md
implementation_module.md
verification_result.md
raw_logs/
audit_review.md
human_merge_checklist.md
release_evidence.md
```

## 13. Integration With 51355 Pipeline

This domain must use the 51355 pipeline for any implementation.

Recommended context snapshot slice:

```text
Required:
- 750000 delivery app channel index
- this assessment
- delivery channel no-scraping policy
- webhook / HMAC / OAuth security summary
- KDS/DID state-machine summary
- privacy masking summary
- idempotency summary
- audit/evidence summary

Optional:
- vendor ecosystem assessment
- hardware readiness checklist
- operational KPI report

Excluded unless relevant:
- unrelated UI composition docs
- unrelated membership/loyalty docs
- unrelated admin console docs
- full root documentation dump
```

## 14. Required Follow-Up Documents

This assessment requires the following follow-up documents before implementation planning:

```text
750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md
750030_Policy_Delivery_Platform_Official_API_Integration_And_No_Scraping_Boundary.md
750040_Boundary_Delivery_App_POS_API_Gateway_KDS_DID_Responsibility.md
750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md
750060_Policy_Delivery_App_KDS_DID_Privacy_Masking_Tokenization_And_Data_Retention.md
750070_SOP_Delivery_App_KDS_Order_Intake_Routing_Bump_And_DID_Callout_Runtime.md
750080_Logic_KDS_Smart_Routing_Station_Splitting_BOM_And_Assembly_State_Machine.md
750090_Checklist_KDS_DID_Hardware_Environmental_Durability_And_Installation_Readiness.md
```

## 15. Non-Authorization Statement

This document is an assessment only.

It does not authorize:

- API connection,
- credential issuance,
- scraping,
- webhook listener implementation,
- database migration,
- KDS runtime implementation,
- DID runtime implementation,
- Flutter UI change,
- production test,
- vendor onboarding.

Any runtime change must follow the approved implementation lifecycle.

## 16. Final Assessment

Delivery-app channel integration should be treated as a high-risk runtime boundary because it touches:

- external platform API,
- customer personal data,
- store order execution,
- kitchen workflow,
- customer/rider visibility,
- evidence and audit trail,
- provider outage recovery.

The correct design direction is:

```text
Official API only.
Normalize before runtime use.
KDS is a state-machine surface.
DID is a projection surface.
Bump events are material runtime events.
Privacy masking is mandatory.
Unknown external state must not be forced into false completion.
Every implementation must leave evidence.
```
