# 750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md

## 1. Purpose

This boundary document defines the runtime responsibility split between POS, API Gateway, delivery app channel adapters, KDS, DID, kitchen station workflows, rider/customer pickup callout, audit, evidence, monitoring, and degraded-mode operation in `yoonsul_wait_order_handoff`.

The purpose is to prevent unclear ownership when an external delivery app order enters the store runtime and flows through:

```text
Delivery App / Aggregator
  -> Delivery Channel Adapter
  -> API Gateway / Order Ingestion
  -> POS Projection / Store Order Runtime
  -> KDS Main Board
  -> Kitchen Station KDS
  -> Assembly / Packing
  -> DID / Pickup Callout
  -> Rider / Customer Handoff
  -> Audit / Evidence / Analytics
```

This document exists because delivery app, POS, KDS, DID, and kitchen automation systems often overlap in the same operational moment, but each component must own only a narrow part of the flow.

No component may silently assume final authority over order state, customer-visible status, payment-adjacent status, privacy retention, or evidence completion.

## 2. Scope

This boundary applies to:

- delivery app order ingestion,
- delivery app official API integration,
- approved delivery manager plugins,
- order aggregation services,
- POS delivery order projection,
- KDS order board and station routing,
- DID order callout and pickup display,
- kitchen bump workflow,
- rider pickup readiness,
- customer pickup readiness,
- order status synchronization,
- privacy masking and retention,
- audit ledger events,
- evidence packet generation,
- degraded mode and manual fallback.

This document does not define provider-specific API request fields. Provider-specific details must be placed in channel-specific integration documents.

## 3. Core Boundary Rule

The core boundary rule is:

```text
Delivery channel adapters ingest.
API Gateway verifies and normalizes.
POS projects store order state.
KDS controls kitchen execution.
DID displays pickup-facing readiness.
Audit records material transitions.
Evidence preserves proof.
Human operators handle exceptions.
```

No single component may become an invisible all-powerful controller.

Every component must expose its responsibility, input, output, failure state, and audit event.

## 4. Responsibility Overview

| Component | Primary Responsibility | Must Not Own |
|---|---|---|
| Delivery App Platform | External order source and provider status | Internal kitchen station state |
| Delivery Channel Adapter | Provider-specific authentication, signature verification, and event translation | Final business state without gateway validation |
| API Gateway / Order Ingestion | Normalize, deduplicate, authorize, and route order events | Kitchen station execution details |
| POS Projection | Store-facing order and payment-adjacent projection | Provider credential handling |
| KDS Main Board | Kitchen order queue, routing, and bump coordination | Provider API authorization |
| Station KDS | Station-specific task execution | Whole-order financial or provider finality |
| Assembly / Packing Runtime | Merge station completion into pack-ready state | Customer privacy retention rules |
| DID Runtime | Display pickup/callout state | Payment, refund, provider settlement, or audit finality |
| Audit Ledger | Immutable material event log | Business decision making |
| Evidence Packet | Human/audit-readable proof bundle | Runtime orchestration |
| Monitoring / Alerting | Detect delay, mismatch, failure, and degraded mode | Silent auto-correction |
| Human Operator | Exception resolution and final manual override | Hidden system mutation without evidence |

## 5. Delivery Channel Adapter Boundary

### 5.1 Role

The delivery channel adapter is responsible for provider-specific integration mechanics.

It may handle:

- provider endpoint selection,
- OAuth-style authorization,
- API key and secret metadata lookup,
- HMAC signature verification,
- webhook signature validation,
- polling cursor management,
- WebSocket subscription management,
- provider order ID extraction,
- provider status mapping,
- raw payload redaction before evidence storage,
- provider error classification.

### 5.2 Forbidden Responsibilities

The delivery channel adapter must not:

- directly mutate kitchen station state,
- directly show customer-facing DID readiness,
- finalize internal order state without API Gateway validation,
- store plaintext customer personal data beyond the approved retention boundary,
- bypass idempotency checks,
- create POS-visible orders without normalized order identity,
- treat provider timeout as success,
- treat unknown provider status as final failure,
- write unmanaged local files with raw customer data,
- hide provider payload mismatches.

### 5.3 Required Outputs

The adapter must output a normalized event envelope.

```text
Normalized Delivery Event Envelope:
- provider_code
- provider_order_id
- store_id
- merchant_channel_id
- external_event_id
- event_type
- provider_status
- event_received_at
- provider_event_time if available
- signature_verified
- replay_checked
- idempotency_key
- privacy_class
- raw_payload_reference or redacted_payload_reference
- mapping_warnings
```

## 6. API Gateway / Order Ingestion Boundary

### 6.1 Role

The API Gateway is the controlled entry point for delivery channel events.

It is responsible for:

- verifying adapter output,
- enforcing idempotency,
- detecting duplicate events,
- normalizing order structure,
- mapping provider channel IDs to internal store IDs,
- applying order intake rules,
- creating or updating internal order runtime events,
- writing material audit events,
- emitting downstream KDS/POS events,
- quarantining invalid or ambiguous events,
- preserving evidence references.

### 6.2 Must Enforce

The API Gateway must enforce:

- provider/store mapping validity,
- duplicate event prevention,
- replay window checks where applicable,
- schema validation,
- privacy classification,
- allowed status transition rules,
- unknown state handling,
- audit ledger write requirement,
- evidence reference requirement,
- degraded mode classification.

### 6.3 Must Not Do

The API Gateway must not:

- assume kitchen completion,
- bypass KDS state machine,
- directly call DID pickup readiness unless the KDS/assembly state permits it,
- persist raw customer personal data without retention and masking rules,
- auto-retry provider actions indefinitely,
- convert provider ambiguity into customer-visible finality,
- modify POS settlement or payout state,
- hide mapping failures.

## 7. POS Projection Boundary

### 7.1 Role

The POS projection represents the store-facing order and payment-adjacent view.

It may show:

- order channel,
- provider order number,
- internal order number,
- item list,
- menu options,
- order type,
- requested pickup time,
- rider/customer indicator,
- current internal order state,
- payment-adjacent status if supplied by approved upstream systems,
- cancellation or modification visibility.

### 7.2 POS Must Not Own

POS projection must not own:

- provider authentication,
- raw provider callback verification,
- KDS station routing logic,
- station completion logic,
- DID callout finality,
- customer data retention policy,
- audit ledger immutability,
- provider settlement or payout truth,
- unofficial scraping logic.

### 7.3 POS Conflict Handling

If POS projection and KDS state diverge, the system must not silently overwrite one side.

A conflict must create:

- conflict event,
- affected order ID,
- source states,
- timestamp,
- operator-visible warning,
- audit ledger entry,
- evidence reference,
- required resolution path.

## 8. KDS Main Board Boundary

### 8.1 Role

The KDS main board owns kitchen execution visibility.

It is responsible for:

- showing accepted kitchen orders,
- sequencing orders,
- splitting tasks by station where applicable,
- tracking cooking start,
- tracking station bump events,
- tracking assembly readiness,
- tracking packing readiness,
- controlling kitchen-visible warnings,
- producing kitchen execution timestamps,
- emitting DID readiness only after the required kitchen state is satisfied.

### 8.2 KDS State Ownership

The KDS may own internal kitchen states such as:

```text
KITCHEN_QUEUED
KITCHEN_ACCEPTED
STATION_ROUTED
STATION_IN_PROGRESS
STATION_BUMPED
ASSEMBLY_PENDING
ASSEMBLY_READY
PACKING_IN_PROGRESS
PACK_READY
HANDOFF_READY
```

KDS must not own external provider final states such as provider payment settlement, refund, platform cancellation truth, or payout truth.

### 8.3 KDS Must Not Do

KDS must not:

- accept unsigned provider events,
- create orders directly from unverified external payloads,
- expose personal data beyond kitchen need,
- override official cancellation rules without API Gateway event,
- mark customer-visible ready before assembly/packing rules pass,
- delete order evidence after bump,
- hide delayed station states from monitoring.

## 9. Station KDS Boundary

### 9.1 Role

Station KDS views are task-specific projections.

Examples:

- grill station,
- fryer station,
- beverage station,
- cold station,
- packaging station,
- assembly station,
- dessert station.

Each station receives only the task slice it needs.

### 9.2 Station Data Minimization

Station KDS must receive only:

- station task ID,
- internal order ID or masked display number,
- station-specific items,
- station-specific modifiers,
- priority/time indicator,
- allergen or safety notes if applicable,
- station due time,
- bump action state.

Station KDS should not receive:

- full delivery address,
- customer phone number,
- unnecessary customer identity,
- provider credentials,
- payment details,
- settlement metadata,
- raw platform payload.

### 9.3 Station Bump Rule

A station bump means:

```text
This station task is complete.
```

It does not mean:

```text
The whole order is ready.
The customer can be called.
The rider can pick up.
The provider state is final.
The payment is settled.
```

## 10. Assembly / Packing Boundary

### 10.1 Role

Assembly and packing combine station-level completion into order-level readiness.

This layer must validate:

- required station tasks are complete,
- required item count is satisfied,
- menu option constraints are checked,
- packaging type matches channel,
- rider/customer pickup label is correct,
- cancel/modify hold is not active,
- hold or exception state is clear.

### 10.2 Ready State Rule

Only the assembly/packing layer may promote an order toward pickup readiness when all required preconditions are satisfied.

```text
Station complete is not handoff ready.
Assembly complete is not always handoff ready.
Packing complete plus no active hold may become handoff ready.
```

### 10.3 Exception Rule

If any station task is missing, duplicated, delayed, or conflicted, assembly must not auto-promote the order to DID callout.

It must create:

- assembly exception event,
- operator alert,
- audit ledger entry,
- evidence reference,
- manual resolution path.

## 11. DID Runtime Boundary

### 11.1 Role

DID is a customer/rider-facing display and callout projection.

It may display:

- masked order number,
- pickup number,
- channel badge,
- ready status,
- pickup counter information,
- rider pickup indication,
- customer pickup indication,
- delay notice if approved,
- generic queue information.

### 11.2 DID Must Not Display

DID must not display:

- full customer name unless explicitly approved and safe,
- phone number,
- detailed delivery address,
- raw delivery app order ID if it exposes personal data,
- payment status,
- refund status,
- settlement status,
- internal exception details,
- provider credentials,
- audit identifiers not meant for customers.

### 11.3 DID Finality Rule

DID callout must be treated as customer-visible finality.

Therefore, DID may show pickup readiness only after:

- API Gateway accepted the order,
- KDS/assembly/packing state allows readiness,
- no cancellation or modification hold is active,
- privacy masking rules are satisfied,
- audit event is written or queued under approved evidence fallback,
- monitoring has not flagged the order as blocked.

If the state is unknown, DID must not show final readiness.

## 12. Audit Ledger Boundary

### 12.1 Role

The audit ledger records material state transitions and security-relevant events.

It must record at minimum:

- external event received,
- signature verification result,
- duplicate event detection,
- order accepted into internal runtime,
- KDS routed,
- station bump where material,
- assembly ready,
- pack ready,
- DID callout,
- customer/rider handoff if tracked,
- cancellation or modification conflict,
- privacy masking completion,
- degraded mode activation,
- manual override,
- evidence packet creation.

### 12.2 Audit Must Include

Audit events must include:

- `CHANGE_ID` where the event is related to an implementation change,
- order identifier,
- channel identifier,
- actor or system component,
- event type,
- before state,
- after state,
- timestamp,
- correlation ID,
- evidence reference,
- privacy class,
- result.

### 12.3 Audit Must Not Do

Audit ledger must not become the source of runtime orchestration.

It records what happened. It must not silently decide what should happen next.

## 13. Evidence Packet Boundary

### 13.1 Role

Evidence packets preserve human-readable and audit-readable proof of implementation, verification, and runtime incident handling.

For delivery app / KDS / DID runtime changes, evidence packets should include:

- impact scope,
- context snapshot,
- implementation approval,
- provider contract or integration reference where allowed,
- sanitized sample payload,
- status mapping table,
- idempotency evidence,
- privacy masking evidence,
- KDS routing test result,
- DID callout test result,
- degraded mode test result,
- raw logs,
- git diff,
- audit review,
- human merge checklist.

### 13.2 Evidence Privacy Rule

Evidence packets must not store unredacted customer personal data unless there is an explicit legal and security approval path.

When real data is unavoidable for incident review, it must be:

- access controlled,
- redacted where possible,
- time limited,
- logged,
- linked to legal hold or incident ID,
- excluded from ordinary developer-facing Markdown.

## 14. Monitoring Boundary

### 14.1 Role

Monitoring detects abnormal states and latency.

It should detect:

- external event delay,
- provider callback failure,
- duplicate event spike,
- signature verification failure,
- provider/store mapping failure,
- KDS routing delay,
- station overdue state,
- assembly stuck state,
- DID callout mismatch,
- privacy masking overdue,
- raw log generation failure,
- audit ledger write failure,
- evidence packet missing.

### 14.2 Monitoring Must Not Do

Monitoring must not silently mutate business state.

Any auto-remediation must have:

- approved runbook,
- allowed operation,
- audit event,
- evidence reference,
- rollback path,
- human review threshold.

## 15. Degraded Mode Boundary

### 15.1 Degraded Mode Triggers

Degraded mode may be triggered by:

- delivery app API outage,
- webhook signature verification failure,
- WebSocket stream interruption,
- polling cursor corruption,
- POS projection failure,
- KDS board offline,
- station KDS offline,
- DID offline,
- network partition,
- database unavailable,
- audit ledger write failure,
- privacy masking job failure.

### 15.2 Degraded Mode Rules

In degraded mode:

- new external orders must be quarantined, queued, or manually handled according to runbook,
- unknown external states must not become final internal states,
- DID must not show readiness unless kitchen state is verified,
- KDS may operate in local fallback only if approved,
- manual printed tickets may be used only under logged fallback,
- all manual overrides must be recorded,
- reconciliation must be required before closeout.

### 15.3 Manual Fallback Rule

Manual fallback is allowed only as an explicit operational mode.

It must not become hidden normal operation.

Manual fallback must define:

- who may activate it,
- which channels are affected,
- how orders are labeled,
- how duplicate orders are avoided,
- how customer privacy is protected,
- how recovery reconciliation is performed,
- how evidence is preserved.

## 16. Responsibility RACI Matrix

| Runtime Event | Delivery Adapter | API Gateway | POS | KDS | DID | Audit | Human |
|---|---|---|---|---|---|---|---|
| External order received | R | A | I | I | I | C | I |
| Signature verified | R | A | I | I | I | C | I |
| Order normalized | C | A/R | I | I | I | C | I |
| Order projected to POS | I | C | A/R | I | I | C | I |
| Order routed to KDS | I | C | I | A/R | I | C | I |
| Station task bumped | I | I | I | A/R | I | C | I |
| Assembly ready | I | I | I | A/R | I | C | I |
| DID pickup callout | I | C | I | C | A/R | C | I |
| Provider cancellation conflict | R | A/R | C | C | I | C | C |
| Manual override | I | C | C | C | C | C | A/R |
| Privacy masking completed | C | A/R | I | I | I | C | I |
| Evidence packet completed | C | C | C | C | C | A/R | A |

Legend:

```text
A = Accountable
R = Responsible
C = Consulted
I = Informed
```

## 17. State Transition Guardrails

The following transitions are forbidden unless explicitly defined in a channel-specific logic document:

- unsigned external event -> accepted order,
- duplicate event -> duplicate KDS card,
- station bump -> DID ready,
- KDS complete -> provider final success,
- provider timeout -> internal final failure,
- provider unknown -> customer-visible final state,
- cancelled external order -> active KDS order without conflict marker,
- manual override -> no audit event,
- privacy masking overdue -> release closeout,
- DID offline -> silent customer callout success.

## 18. Context Snapshot Rules For 51355 Pipeline

When this boundary document is used inside the 51355 AI-assisted development pipeline, the context snapshot should include:

- this boundary document,
- `750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md`,
- `750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md`,
- provider-specific integration policy if the change is provider-specific,
- KDS/DID privacy masking policy if customer-visible or personal data is affected,
- test coverage map if implementation is allowed.

Do not include unrelated full documentation sets unless the Cursor impact scope proves they are required.

## 19. Implementation Contract Requirements

Any `change_contract.md` for this domain must define:

- allowed files,
- forbidden files,
- allowed operations,
- forbidden operations,
- affected component owner,
- state transition touched,
- event source,
- downstream target,
- audit event required,
- evidence required,
- privacy class,
- degraded mode behavior,
- rollback path,
- verification commands,
- raw log path.

Allowed operations must be narrower than allowed files.

Example:

```text
Allowed file:
- lib/kds/order_routing.dart

Allowed operation:
- Add provider_channel badge mapping inside existing routeDeliveryOrderToKdsCard() branch only.

Forbidden operations:
- Do not create new routing framework.
- Do not modify DID callout logic.
- Do not modify provider adapter authentication.
- Do not change database schema.
```

## 20. Verification Requirements

At minimum, implementation in this boundary must verify:

- provider event authentication,
- duplicate event handling,
- order normalization,
- POS projection consistency,
- KDS routing correctness,
- station task split correctness,
- assembly readiness guard,
- DID callout guard,
- cancellation/modification conflict behavior,
- privacy masking behavior,
- audit event creation,
- evidence packet creation,
- degraded mode behavior,
- unauthorized file change detection,
- raw log capture.

## 21. Block Criteria

A change must be blocked if:

- provider event authenticity cannot be proven,
- order identity cannot be mapped,
- duplicate prevention is missing,
- KDS can create orders from unverified payloads,
- station completion can directly trigger customer-visible DID readiness,
- DID can display personal data unnecessarily,
- unknown provider state becomes final,
- manual fallback has no evidence path,
- audit ledger event is missing,
- evidence packet is missing,
- privacy masking is not defined,
- allowed operation is broader than the change purpose,
- implementation touches unrelated POS/KDS/DID boundaries.

## 22. Final Operating Rule

For delivery app channel integration, POS, KDS, DID, and kitchen runtime responsibility must remain separated.

```text
No external order without verified source.
No verified source without normalized event.
No normalized event without idempotency.
No KDS routing without accepted order.
No DID callout without kitchen readiness.
No customer-visible finality on unknown state.
No personal data exposure without purpose.
No manual fallback without evidence.
No implementation without allowed operations.
```
