# 750100_Assessment_Delivery_App_KDS_DID_Vendor_Ecosystem_Smartcast_Foodtech_Toss_Mate_OKPOS_And_Loyverse.md

## 1. Purpose

This assessment defines how the `yoonsul_wait_order_handoff` project should evaluate external vendor ecosystems for delivery app channel integration, KDS, DID, order ingestion, rider handoff, and kitchen automation.

The goal is not to select a vendor immediately.

The goal is to create a controlled comparison frame so that any future Smartcast, Foodtech, Toss, Mate, OKPOS, Loyverse, or similar integration can be evaluated without exposing the project to uncontrolled API coupling, privacy leakage, missing audit evidence, or kitchen runtime failure.

This document belongs to:

```text
docs/700000_runtime_flow_bundle/750000_delivery_app_channel_integration/
```

It supports the 51355 AI-assisted financial-grade development pipeline by providing a domain-specific context slice for vendor review and implementation planning.

## 2. Scope

This assessment covers vendors and solution patterns that may participate in one or more of the following runtime functions:

- Delivery app order ingestion.
- POS channel projection.
- KDS order display.
- Station-level routing.
- Bump handling.
- Assembly and packing workflow.
- DID customer or rider callout.
- Rider dispatch integration.
- Kitchen runtime telemetry.
- Order status synchronization.
- Privacy masking and tokenization.
- Audit and evidence retention.

This document does not authorize production integration.

Any production integration must still pass:

- Impact scope search.
- Context snapshot slicing.
- Design pack.
- Human boundary approval.
- Allowed operation contract.
- Codex implementation.
- Raw log verification.
- Claude audit.
- Human merge and release approval.

## 3. Vendor Ecosystem Categories

### 3.1 Enterprise Franchise KDS / DID Vendors

These vendors typically provide:

- Multi-store KDS rollout support.
- DID integration.
- Kitchen station routing.
- Headquarters dashboard.
- Menu code synchronization.
- Operational KPI collection.
- Enterprise hardware procurement.
- Field installation support.

Examples from the current research context include:

- Smartcast / DeepKDS style architecture.
- Enterprise KDS and DID stacks used by large franchise brands.
- Hardware-integrated kitchen display deployments.

### 3.2 Delivery Order Integration Gateways

These vendors focus on collecting orders from multiple delivery channels and routing them to POS, KDS, delivery agencies, or store dashboards.

Typical capabilities:

- Delivery app API aggregation.
- Delivery agency API integration.
- Rider dispatch lifecycle tracking.
- Order status synchronization.
- Channel credential management.
- Store-level app account mapping.

Examples from the current research context include:

- Foodtech-style delivery order hub.
- Delivery agency integrated middleware.
- Official delivery app partner gateways.

### 3.3 POS-Native KDS Vendors

These vendors are POS-first and provide KDS as an extension of their POS ecosystem.

Typical capabilities:

- POS order projection.
- Delivery app connector modules.
- KDS screen synchronization.
- Store-friendly setup UI.
- Payment/POS status alignment.
- Channel sales reporting.

Examples from the current research context include:

- Toss POS / Toss Place style KDS support.
- OKPOS delivery manager style extension.
- POS-native KDS or tablet display modules.

### 3.4 Lightweight Tablet KDS Vendors

These vendors provide simple app-based KDS functionality with lower setup cost.

Typical capabilities:

- Tablet-based KDS app.
- Local network synchronization.
- Cloud account sync.
- Printer group style routing.
- Basic order card display.
- Small-store setup simplicity.

Examples from the current research context include:

- Loyverse-style lightweight KDS.
- Standalone tablet KDS applications.
- Low-cost pilot environments.

### 3.5 Custom Or Internal Gateway Pattern

The project may eventually build its own normalized delivery channel gateway.

This pattern requires:

- Official API contracts.
- Provider-specific authentication modules.
- Webhook verification.
- Polling fallback.
- Idempotency keys.
- Duplicate prevention.
- Privacy redaction.
- KDS state machine compatibility.
- Evidence packet generation.

This option gives maximum control but also carries maximum implementation, compliance, and maintenance burden.

## 4. Vendor Capability Matrix

| Vendor / Pattern | Primary Strength | Primary Risk | Best Fit | Must Verify |
|---|---|---|---|---|
| Smartcast-style enterprise KDS | Franchise KDS/DID rollout and kitchen KPI visibility | Vendor lock-in, deep operational coupling | Multi-store franchise kitchen automation | API ownership, evidence export, status model, privacy handling |
| Foodtech-style delivery hub | Multi-channel delivery order aggregation and agency integration | Channel dependency concentration | Delivery-heavy stores and shared kitchens | Official API basis, credential custody, retry logic, audit export |
| Toss-style POS/KDS | Store-friendly POS-native operation | Platform boundary may be closed | Small and mid-size stores wanting fast deployment | Data export, API openness, KDS state visibility |
| Mate-style multi-channel KDS | Delivery, QR, waiting, KDS/DID bundle | Runtime model may differ from internal state machine | Multi-brand or shop-in-shop kitchens | Menu mapping, same-menu aggregation rules, DID sync |
| OKPOS-style POS extension | Broad POS compatibility and field footprint | Legacy compatibility assumptions | Existing OKPOS store base | API vs printer emulation boundary, encoding, failure recovery |
| Loyverse-style tablet KDS | Low-cost and simple KDS setup | Limited enterprise audit depth | Pilot, small store, low-risk dry run | Local network reliability, export, privacy, offline behavior |
| Internal gateway | Full control and long-term architecture ownership | Highest build/maintenance risk | Strategic core runtime | Provider contracts, security, idempotency, monitoring, legal review |

## 5. Evaluation Criteria

### 5.1 Official Integration Basis

A vendor must clearly identify whether each delivery app connection uses:

- Official API.
- Approved partner API.
- Approved local bridge.
- Legacy printer emulation.
- Screen scraping.
- Memory hooking.
- Manual upload or polling workaround.

Allowed:

```text
Official API / approved partner API / approved local bridge with explicit evidence.
```

Forbidden:

```text
Screen scraping, memory hooking, unauthorized API, hidden credential sharing, uncontrolled local data capture.
```

### 5.2 Authentication And Security

Each vendor must disclose or document:

- Credential custody model.
- Token issuance flow.
- Merchant consent flow.
- HMAC or signature verification if applicable.
- IP whitelist requirement if applicable.
- Webhook replay protection.
- Timestamp validation.
- Secret rotation process.
- Incident revocation process.

Any vendor that cannot explain credential and secret custody is not production-ready for this project.

### 5.3 Order State Model Compatibility

The vendor state model must map to the project runtime model.

Minimum required states:

```text
RECEIVED
NORMALIZED
ACCEPTED_BY_STORE
ROUTED_TO_KDS
IN_PREPARATION
STATION_PARTIAL_DONE
ASSEMBLY_READY
PACKING_READY
READY_FOR_PICKUP
CALLED_ON_DID
HANDOFF_COMPLETED
CANCELLED
FAILED
UNKNOWN
```

The vendor must not collapse unknown, timeout, rejected, delayed, and cancelled states into one ambiguous status.

### 5.4 KDS Station Routing

The vendor must support or expose enough data to implement:

- Menu code mapping.
- Option mapping.
- BOM mapping.
- Station assignment.
- Same-menu aggregation where appropriate.
- Assembly dependency tracking.
- Partial bump handling.
- Reopen or correction handling.
- Station-level timestamp capture.

A KDS vendor that only displays flat order text is insufficient for advanced kitchen runtime analytics.

### 5.5 DID Callout Integration

The vendor must support or allow:

- Pickup number display.
- Rider order number display.
- Completion event trigger.
- Callout retry.
- Callout cancellation.
- Audio or visual alert if used.
- No unnecessary customer personal data on public screen.

DID must never expose phone number, full address, full customer name, or sensitive request text.

### 5.6 Privacy And Data Retention

Vendor evaluation must verify:

- Customer phone masking.
- Address masking.
- Special request redaction policy.
- Delivery completion masking deadline.
- Local device storage behavior.
- Backup retention behavior.
- Export redaction behavior.
- Support account access logging.
- Legal hold behavior if applicable.

The vendor must be compatible with project privacy rules defined in:

```text
750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md
```

### 5.7 Evidence Export

Vendor systems should expose or preserve:

- Order received timestamp.
- Store accepted timestamp.
- KDS routed timestamp.
- Station bump timestamp.
- Assembly complete timestamp.
- Packing complete timestamp.
- DID callout timestamp.
- Rider pickup timestamp if available.
- API request ID.
- Provider order ID.
- Internal change ID if integration work is project-owned.
- Error and retry logs.

Without evidence export, the vendor can be used only as a limited operational component, not as a trusted audit source.

## 6. Vendor Review Questions

Before vendor adoption, the owner must ask:

1. Which delivery app channels are connected through official API?
2. Are any channels connected through scraping, printer emulation, or local hook?
3. Who holds the merchant credentials?
4. Can secrets be rotated without downtime?
5. Are webhooks signed and replay-protected?
6. How are duplicate orders detected?
7. What happens when the delivery app API times out?
8. What happens when order status is unknown?
9. Can the vendor export raw event logs?
10. Can the vendor export KDS station timestamps?
11. Can the vendor map provider order ID to internal order ID?
12. Can DID display be controlled without exposing private data?
13. Does the vendor mask personal data after delivery completion?
14. Is data stored locally on KDS/DID tablets?
15. Is offline mode supported?
16. How are late callbacks handled?
17. How are cancelled orders removed or marked on KDS?
18. Can the project test in sandbox or pilot mode?
19. Can the vendor provide field installation evidence?
20. Can the vendor support multi-store rollout without manual drift?

## 7. Red Flags

A vendor must be blocked or held for further review if:

- It uses screen scraping without explicit approval.
- It uses memory hooking or unauthorized app automation.
- It stores customer personal data indefinitely.
- It cannot describe credential custody.
- It cannot export event evidence.
- It treats timeout as cancellation without proof.
- It treats unknown provider status as success without proof.
- It cannot separate delivery, takeout, dine-in, and pickup views.
- It exposes full customer information on DID.
- It requires broad admin credentials for routine operation.
- It cannot support per-store configuration audit.
- It forces unreviewed production hotfixes.
- It cannot document failure and recovery behavior.

## 8. Fit-For-Use Classification

### 8.1 Class A — Strategic Integration Candidate

A vendor may be classified as Class A if it provides:

- Official delivery app API integration.
- Clear credential custody.
- KDS station routing.
- DID integration.
- Privacy masking.
- Event evidence export.
- Multi-store configuration governance.
- Sandbox or pilot environment.
- Clear failure recovery process.

### 8.2 Class B — Operational Pilot Candidate

A vendor may be used for pilot if it provides:

- Stable KDS/DID operation.
- Basic delivery order ingestion.
- Acceptable privacy handling.
- Manual evidence collection.
- Limited store scope.

Class B may not become production standard until missing evidence and audit capabilities are closed.

### 8.3 Class C — Local Convenience Tool

A vendor may be used only as a local convenience tool if it lacks:

- Reliable API evidence.
- Audit export.
- Privacy proof.
- Station-level telemetry.
- Formal failure handling.

Class C must not be treated as system-of-record.

### 8.4 Blocked

A vendor is blocked if it depends on:

- Unauthorized scraping.
- Unauthorized credential capture.
- Unmasked long-term personal data storage.
- Ambiguous financial or operational status mapping.
- No failure evidence.

## 9. Implementation Handoff Requirements

If a vendor is selected for integration, the implementation packet must include:

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
audit_review.md
human_merge_checklist.md
release_evidence.md
```

The `context_snapshot.md` must include only the relevant vendor rule summaries, not all delivery app and KDS documentation.

Required references:

```text
750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md
750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md
750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md
750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md
750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md
750070_SOP_Delivery_App_Order_Intake_KDS_Routing_Bump_And_DID_Callout_Runtime.md
750080_Logic_Delivery_App_KDS_Smart_Routing_Station_Splitting_BOM_And_Assembly_State_Machine.md
750090_Checklist_Delivery_App_KDS_DID_Hardware_Environmental_Durability_And_Installation_Readiness.md
```

## 10. Required Test Categories

Vendor integration must be tested for:

- Duplicate order ingestion.
- Duplicate webhook.
- Late webhook.
- Missing webhook.
- Polling fallback if applicable.
- Timeout at provider API.
- Unknown order state.
- Store cancellation.
- Delivery app cancellation.
- KDS route failure.
- Station bump failure.
- DID callout failure.
- DID duplicate callout.
- Privacy masking after completion.
- Redacted evidence export.
- Credential revocation.
- Secret rotation.
- Network outage.
- Tablet/KDS offline state.
- Recovery after reconnect.
- Cross-store credential isolation.

## 11. Vendor Adoption Decision Record Template

```markdown
# vendor_adoption_decision.md

## Vendor Name

## Reviewed Product / Module

## Target Stores / Pilot Scope

## Delivery Channels Supported

## API Integration Basis

## Credential Custody Model

## KDS Capability

## DID Capability

## Privacy / Masking Capability

## Evidence Export Capability

## Failure Recovery Capability

## Security Review Result

## Operational Fit Class

Class A / Class B / Class C / Blocked

## Required Conditions Before Production

## Owner Decision

APPROVE_PILOT / APPROVE_PRODUCTION / HOLD / BLOCK

## Review Timestamp
```

## 12. Relationship To 750000 Bundle

This document is the vendor ecosystem assessment layer of the 750000 bundle.

It does not replace channel integration policy, privacy policy, KDS routing logic, hardware checklist, or runtime SOP.

It provides the vendor selection and adoption frame that must be used before the project depends on any external KDS/DID/delivery app integration vendor.

## 13. Relationship To 51355 Pipeline

When a vendor integration becomes an implementation task, 51355 controls the development process.

This file supplies the domain-specific vendor assessment slice.

The AI implementation pipeline must not ingest every KDS/DID/vendor document blindly.

Instead, Cursor Stage 1 must identify this file only when vendor selection, vendor comparison, KDS/DID procurement, or third-party delivery channel integration is part of the change.

## 14. Final Rule

```text
No vendor adoption without official integration proof.
No KDS/DID dependency without privacy review.
No delivery channel gateway without credential custody review.
No kitchen automation vendor without failure recovery evidence.
No external order source becomes trusted until audit evidence is exportable.
```
