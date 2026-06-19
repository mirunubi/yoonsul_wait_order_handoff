# 750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md

## 1. Purpose

This guide defines the compressed context summary for Delivery App API, KDS, DID, and omnichannel order ingestion integration inside `yoonsul_wait_order_handoff`.

It is designed to be used as a lightweight context snapshot for the `51355` AI-assisted financial-grade development pipeline when a module touches delivery app order channels, kitchen display routing, customer pickup display, rider pickup flow, or kitchen runtime continuity.

This document is not an implementation document.

It is a domain context summary for planning, impact analysis, module mapping, test coverage, and controlled handoff.

## 2. Scope

This guide covers:

- Delivery app order ingestion.
- Official API-based integration.
- No-scraping and no-screen-hooking boundary.
- POS / API gateway / KDS / DID responsibility split.
- Order normalization across channels.
- KDS station routing.
- Bump flow and completion flow.
- DID customer and rider callout.
- Personal information masking and retention.
- Webhook, polling, OAuth, HMAC, token, and IP whitelist concerns.
- Raw order event evidence.
- Runtime fallback when delivery channel or KDS/DID integration fails.

## 3. Non-Goals

This guide does not define:

- Final production API contracts for any specific delivery platform.
- Actual vendor credentials.
- Real endpoint URLs.
- Runtime implementation code.
- Database migrations.
- Flutter screen implementation.
- Direct scraping, memory hooking, or unofficial bridge behavior.
- Any claim that a specific platform integration is already approved.

## 4. Why This Context Exists

Delivery app orders create a high-risk runtime boundary because they combine:

- External platform order state.
- Store acceptance and rejection state.
- Customer request data.
- Rider pickup timing.
- Kitchen preparation state.
- DID callout state.
- Potentially sensitive customer information.
- Settlement, cancellation, refund, and dispute evidence.

For this reason, delivery app channel integration must be treated as a controlled external runtime flow, not as a simple order import feature.

## 5. Context Snapshot Summary For 51355 Pipeline

When a change touches delivery app channel integration, the minimum context packet should include:

```text
- 750000_Index_Delivery_App_Channel_Integration_KDS_DID_And_Order_Ingestion_Runtime.md
- 750010_Assessment_Delivery_App_Channel_API_KDS_DID_And_Omnichannel_Order_Ingestion_Architecture.md
- 750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md
- Relevant POS gateway / KDS / DID / order state documents
- Relevant privacy / masking / evidence / audit rules
```

Do not inject the entire 700000 runtime flow bundle unless the impact scope proves that broad context is required.

## 6. Domain Tags

Use these tags in `impact_scope.md`, `context_snapshot.md`, and `change_contract.md`.

```text
DOMAIN_TAGS:
- delivery_app_channel
- order_ingestion
- official_api_only
- no_scraping
- kds_routing
- did_callout
- kitchen_station_state
- rider_pickup
- customer_privacy_masking
- webhook_security
- hmac_signature
- oauth_token
- external_channel_evidence
```

## 7. Core Architecture Pattern

The preferred architecture is:

```text
Delivery App / External Channel
  -> Official API / Webhook / Polling Adapter
  -> Channel Authentication And Signature Verification
  -> Order Normalization Layer
  -> Internal Order Event Bus / Runtime API
  -> POS / Store Runtime State
  -> KDS Routing Engine
  -> Station KDS View
  -> Bump / Completion Event
  -> DID Callout / Rider Pickup / Customer Pickup
  -> Audit / Evidence / Masking / Retention
```

The system must preserve traceability from the external order event to the internal kitchen runtime state.

## 8. Integration Principles

### 8.1 Official API Only

Delivery app channel integration must use official, approved, auditable channels.

Forbidden:

- Screen scraping.
- Memory hooking.
- Unapproved local process interception.
- Unverified browser automation.
- Uncontrolled credential sharing.
- Capturing customer data outside approved API scope.

### 8.2 External State Is Not Internal Truth

External channel state must not be blindly treated as internal truth.

Every inbound event must be normalized, validated, deduplicated, and mapped to an internal state transition.

### 8.3 KDS Is Runtime Control, Not Just Display

KDS is not merely a visual replacement for a kitchen printer.

It controls:

- Preparation queue.
- Station workload.
- Order sequencing.
- Menu component routing.
- Bump events.
- Assembly readiness.
- Pickup readiness.
- Delay and bottleneck evidence.

### 8.4 DID Is External Communication

DID output is a customer/rider-facing communication surface.

DID must not display:

- Full customer phone number.
- Full address.
- Sensitive request notes.
- Internal exception reason.
- Payment or refund state not confirmed for display.

## 9. Channel Adapter Context

Each delivery app channel adapter should define:

```markdown
## Channel Name

## Authentication Method

## Credential Owner

## Token Rotation Rule

## Signature Verification Rule

## IP Whitelist Rule

## Webhook / Polling Behavior

## Retry Behavior

## Duplicate Event Rule

## Order State Mapping

## Cancel / Reject / Refund Related Mapping

## Customer Data Fields

## Masking / Retention Rule

## Evidence Fields

## Failure / Degraded Mode
```

## 10. KDS Runtime Context

KDS-related changes must identify:

- Which order source enters KDS.
- Which menu items route to which station.
- Whether BOM or modifier splitting is required.
- Whether station views show full order or partial components.
- Whether bump event is per station, per item, per order, or per assembly group.
- Whether completion triggers DID callout.
- Whether completion triggers delivery/rider signal.
- Whether delayed preparation creates alert or evidence.

## 11. DID Runtime Context

DID-related changes must identify:

- Which event triggers display.
- Which identifier is displayed.
- Whether customer and rider views differ.
- Whether sound or voice callout is used.
- Whether pickup number is reused safely.
- Whether completed orders expire from display.
- Whether DID can operate when KDS is degraded.
- Whether DID output is logged as external communication evidence.

## 12. Privacy And Masking Context

Delivery app integration may carry sensitive customer data.

The design must define:

- What customer fields are received.
- What fields are shown to kitchen staff.
- What fields are shown to DID.
- What fields are stored.
- What fields are masked.
- When masking occurs.
- What fields are deleted or tokenized.
- Who can access unmasked data.
- Whether access is logged.

Minimum rule:

```text
Do not retain delivery customer personal data longer than required for store operation, dispute handling, legal obligation, or approved evidence retention.
```

## 13. Event Evidence Context

Every material delivery app order event should be traceable.

Evidence should include:

- `CHANGE_ID` when implementation change is being tested or released.
- External channel name.
- External order ID or tokenized order reference.
- Internal order ID.
- Received timestamp.
- Normalized event type.
- Signature verification result if applicable.
- Deduplication key.
- State transition before / after.
- KDS routing decision.
- DID callout decision.
- Masking status.
- Error code if failed.

## 14. High-Risk Scenarios

### 14.1 Duplicate Inbound Order Event

A repeated webhook or polling result must not create duplicate orders or duplicate kitchen tickets.

### 14.2 Delayed Cancel After Kitchen Start

If cancellation arrives after KDS preparation has started, the system must not silently remove the kitchen ticket without audit evidence and store-visible exception handling.

### 14.3 DID Premature Callout

DID must not show pickup-ready state before KDS completion or approved manual override.

### 14.4 Customer Data Overexposure

Kitchen station views and DID must not expose unnecessary personal data.

### 14.5 Channel Credential Misuse

API keys, OAuth tokens, HMAC secrets, and vendor identifiers must not be logged, exported, or included in evidence packets without redaction.

### 14.6 Station Routing Mismatch

Menu items must not be routed to the wrong station due to incomplete menu mapping, modifier mapping, or BOM mapping.

### 14.7 Rider Timing Mismatch

Rider pickup signal must not be sent too early when kitchen load or KDS state indicates preparation is delayed.

## 15. Context Slicing Rule

Use only the context needed for the target module.

| Target Change | Required Context | Exclude Unless Needed |
|---|---|---|
| Delivery API adapter | API auth, webhook/polling, signature, order mapping, evidence | KDS hardware, DID UI styling |
| KDS routing | menu/BOM mapping, station state, bump flow, order queue | OAuth implementation details, vendor market assessment |
| DID callout | completion trigger, pickup display, masking, sound/voice, expiry | full kitchen station routing internals |
| Privacy masking | customer fields, retention, access control, evidence redaction | station layout, hardware installation |
| Hardware installation | IP rating, bump bar, mount, kitchen environment | API signature, token rotation |
| Vendor assessment | capability matrix, supported channels, deployment risk | code handoff prompts |

## 16. Cursor Stage 1 Search Add-On

For delivery app / KDS / DID changes, Cursor Stage 1 must search for:

```text
- delivery app adapter files
- webhook handlers
- polling jobs
- signature / OAuth / token logic
- order normalization logic
- POS order intake routes
- KDS routing files
- station mapping files
- DID display / callout files
- customer data masking logic
- evidence packet logic
- audit ledger logic
- tests for duplicate events
- tests for cancellation after preparation start
- tests for DID premature display
- related 750000 context documents
```

Cursor must not modify any file during this search.

## 17. Claude Stage 2 Design Add-On

Claude must not design delivery app / KDS / DID integration from generic assumptions.

Claude must receive:

- `impact_scope.md`.
- This context summary.
- The specific channel or module target.
- Relevant rule summaries only.
- Current approved internal state model.

Claude must explicitly define:

- External event mapping.
- Internal order state mapping.
- KDS routing effect.
- DID communication effect.
- Privacy masking effect.
- Evidence and audit effect.
- Degraded mode.
- Rollback effect.

## 18. Codex Stage 3 Implementation Add-On

Codex must not:

- Add a new delivery channel without approval.
- Introduce scraping or unofficial bridge behavior.
- Log secrets.
- Display full customer data.
- Treat webhook retry as a new order.
- Treat KDS completion as payment completion.
- Treat DID callout as proof of customer receipt.
- Change station routing broadly without explicit operation approval.

## 19. Verification Gate Add-On

Required verification checks may include:

```bash
# examples only; commands are project-specific
npm run test -- delivery-channel
npm run test -- kds-routing
npm run test -- did-callout
npm run test -- privacy-masking
npm run test -- duplicate-webhook
npm run test -- cancel-after-kitchen-start
npm run test -- evidence-redaction
```

Verification must preserve raw logs under the relevant implementation evidence folder when the change is high risk.

## 20. Audit Add-On

Claude audit must ask:

- Can this change create duplicate kitchen tickets?
- Can this change display ready status too early?
- Can this change leak customer information?
- Can this change lose external order traceability?
- Can this change misroute menu items to the wrong station?
- Can this change break degraded manual fallback?
- Can this change create false finality for rider or customer?
- Can this change hide provider/channel failure?

## 21. Required Follow-Up Documents

This guide should be followed by:

```text
750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md
750040_Boundary_POS_API_Gateway_Delivery_App_KDS_DID_Runtime_Responsibility.md
750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md
750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md
750070_SOP_Delivery_App_Order_Intake_KDS_Routing_Bump_And_DID_Callout_Runtime.md
```

## 22. Final Rule

Delivery app channel integration is not a simple connector feature.

It is an external runtime channel that can affect kitchen execution, customer communication, rider timing, privacy exposure, operational evidence, and future settlement/dispute traceability.

Therefore:

```text
No delivery app integration without official API boundary.
No KDS routing without station state mapping.
No DID callout without masking and completion rule.
No external event ingestion without deduplication.
No customer data handling without retention and redaction rule.
No implementation without evidence.
```
