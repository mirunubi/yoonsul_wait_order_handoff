# 750070_SOP_Delivery_App_Order_Intake_KDS_Routing_Bump_And_DID_Callout_Runtime.md

## 1. Purpose

This SOP defines the runtime operating procedure for delivery app order intake, KDS routing, station bump handling, assembly / packing completion, and DID callout for `yoonsul_wait_order_handoff`.

The purpose is to ensure that delivery app orders are handled through a controlled digital kitchen flow without paper-ticket dependency, unofficial scraping, hidden manual shortcuts, or uncontrolled customer data exposure.

This SOP applies to delivery app channel orders that enter the system through an approved delivery app API, approved partner gateway, or approved local bridge and then flow into POS projection, KDS, station-level kitchen screens, assembly / packing, DID display, customer / rider notification, audit ledger, and evidence packet.

## 2. Scope

In scope:

- Delivery app order intake.
- Channel adapter normalization.
- POS projection and order acceptance state.
- KDS card creation.
- Station routing.
- Bump action handling.
- Assembly and packing readiness.
- DID customer / rider callout.
- Privacy masking and tokenized identifiers.
- Audit ledger and evidence packet records.
- Failure, timeout, duplicate, and degraded-mode handling.

Out of scope:

- Direct payment authorization logic.
- Provider settlement and payout reconciliation.
- Delivery rider dispatch optimization beyond pickup readiness signal.
- AI vision, voice recognition, or IoT appliance automation unless separately approved.
- Runtime implementation code.

## 3. Operating Principle

The operating principle is:

```text
Delivery app order data must become a controlled kitchen runtime event.
Kitchen runtime events must be visible, traceable, privacy-limited, and reversible.
```

A delivery app order must never be treated as a loose text message, printer dump, screen scrape, or uncontrolled local notification.

## 4. Approved Runtime Flow

```text
[1] Delivery App / Partner Gateway
    ↓
[2] Delivery App Channel Adapter
    ↓
[3] API Gateway / Order Ingestion Boundary
    ↓
[4] POS Projection / Order Acceptance State
    ↓
[5] Main KDS Order Card
    ↓
[6] Station KDS Routing
    ↓
[7] Station Bump
    ↓
[8] Assembly / Packing Readiness
    ↓
[9] DID Customer / Rider Callout
    ↓
[10] Audit Ledger / Evidence Packet
```

No stage may skip audit/evidence recording when the state change is material.

## 5. Required Runtime States

The minimum runtime states are:

| State | Meaning | Owner |
|---|---|---|
| `received` | Order payload received from delivery channel | Channel Adapter |
| `normalized` | External payload mapped to internal order contract | Channel Adapter |
| `accepted` | Store/POS has accepted order | POS Projection |
| `kds_created` | KDS card created | KDS Runtime |
| `station_routed` | Order items routed to station screens | KDS Routing |
| `station_in_progress` | Station item preparation started | Station KDS |
| `station_bumped` | Station item completed | Station KDS |
| `assembly_ready` | All required station items completed | Assembly Runtime |
| `packing_ready` | Order can be packed or handed off | Packing Runtime |
| `did_called` | DID callout displayed/announced | DID Runtime |
| `handoff_complete` | Customer/rider pickup completed | Store Runtime |
| `exception_hold` | Order requires manual review | Store Runtime |

Unknown, duplicate, timeout, or unmapped channel statuses must not be coerced into success.

## 6. Step 1 — Delivery App Order Intake

### 6.1 Allowed Intake Sources

Allowed:

- Official delivery app API.
- Approved partner API gateway.
- Approved local bridge with documented behavior.
- Approved POS vendor integration with signed contract or official partner status.

Forbidden:

- Screen scraping.
- Memory hooking.
- Undocumented private endpoint calls.
- Manual copying of customer details into uncontrolled notes.
- Printer data interception unless explicitly approved as a legacy bridge and privacy controls are documented.

### 6.2 Intake Validation

The adapter must validate:

- Channel identity.
- Store identity.
- Order ID.
- Idempotency key or dedupe key.
- Timestamp.
- Signature or token where applicable.
- Payload schema version.
- Required menu item structure.
- Customer data minimization policy.

If validation fails, the order must enter `exception_hold` or be rejected at the boundary according to approved policy.

## 7. Step 2 — Payload Normalization

The adapter converts channel-specific payloads into the internal order contract.

Required normalized fields:

- Internal order ID.
- External channel order ID.
- Channel name.
- Store ID.
- Order type: delivery / pickup / other.
- Menu items.
- Options and modifiers.
- Quantity.
- Kitchen routing tags.
- Pickup readiness requirements.
- Customer-visible order number or token.
- Privacy-redacted customer metadata.
- Audit metadata.

Forbidden normalized fields:

- Full customer address unless required for delivery operations and retention is approved.
- Unmasked phone number in KDS/DID payload.
- Raw personal data in station KDS payload.
- Unredacted customer request text in logs unless approved and redacted downstream.

## 8. Step 3 — POS Projection And Acceptance

The POS projection must answer one core question:

```text
Can this store accept this order into the kitchen workflow now?
```

The POS projection checks:

- Store open state.
- Menu availability.
- Sold-out flags.
- Order channel status.
- Payment or platform acceptance state if applicable.
- Kitchen capacity hold rules if defined.
- Manual store rejection rule if allowed.

Acceptance must produce an auditable state transition.

## 9. Step 4 — Main KDS Card Creation

When the order is accepted, the main KDS creates a digital order card.

The KDS card must show:

- Internal kitchen order number.
- Channel badge.
- Order type badge.
- Menu items and options.
- Elapsed time.
- Station routing status.
- Exception flag if present.
- Privacy-safe customer/rider callout token.

The KDS card must not show:

- Full phone number.
- Full address.
- Payment instrument data.
- Provider secrets.
- Raw API token.
- Unredacted customer PII.

## 10. Step 5 — Station Routing

Station routing splits the order into station-level work items.

Example stations:

- Grill.
- Fryer.
- Beverage.
- Assembly.
- Packing.
- Pickup counter.

Routing must be based on menu taxonomy, BOM, option tags, station capacity rules, and approved kitchen layout.

### 10.1 Routing Rules

- A menu item may route to one or more stations.
- Station items must remain linked to the parent order ID.
- Station completion must not finalize the whole order until all required station items are complete.
- Optional components must be explicitly marked as optional.
- Missing routing tags must trigger exception or fallback routing.

## 11. Step 6 — Station Bump Handling

A bump action means a station worker declares a station work item complete.

Allowed bump inputs:

- Approved KDS touch interaction.
- Approved bump bar action.
- Approved keyboard or hardware controller.
- Approved future voice/IoT action only after separate implementation approval.

Bump action must record:

- Station ID.
- Work item ID.
- Parent order ID.
- Actor or device ID.
- Timestamp.
- Previous state.
- New state.
- CHANGE_ID when related to a controlled implementation run.

Duplicate bump actions must be idempotent.

## 12. Step 7 — Assembly And Packing Readiness

Assembly readiness is reached when all required routed station items are completed.

Packing readiness is reached when:

- All required station items are bumped.
- Required options and modifiers are confirmed.
- Packaging checklist is completed if applicable.
- Pickup token is available.
- No exception hold remains.

The system must not mark the order as ready if any required station route is unknown, pending, failed, or exception-held.

## 13. Step 8 — DID Callout

DID callout may occur only when the order is ready for customer or rider pickup.

DID may display:

- Order token.
- Pickup number.
- Channel badge.
- Pickup counter / shelf label.
- Simple status: preparing / ready / picked up if approved.

DID must not display:

- Customer full name unless approved and privacy-reviewed.
- Full phone number.
- Full address.
- Payment details.
- Internal exception details.
- Raw delivery app order ID if it exposes customer identity.

### 13.1 Callout Events

Required DID events:

| Event | Trigger | Required Evidence |
|---|---|---|
| `did_ready_callout_requested` | Packing readiness reached | KDS/Packing state snapshot |
| `did_ready_callout_displayed` | DID accepted callout | DID device response |
| `did_ready_callout_failed` | DID failed to display | Error log and fallback action |
| `pickup_completed` | Staff confirms handoff | Actor/device/timestamp |

## 14. Exception Handling

### 14.1 Duplicate Order

If a delivery app sends the same order twice:

- Use channel order ID and dedupe key.
- Do not create duplicate kitchen cards.
- Attach duplicate event to existing order evidence.
- Alert only if payload conflict exists.

### 14.2 Unknown Channel State

If channel state is unknown:

- Do not mark accepted.
- Do not mark rejected unless confirmed.
- Place into `exception_hold`.
- Preserve raw payload in redacted evidence.

### 14.3 KDS Routing Failure

If routing fails:

- Do not silently route to all stations.
- Use approved fallback station only if configured.
- Record missing routing tag.
- Create operator-facing exception.

### 14.4 DID Failure

If DID callout fails:

- Keep order in `packing_ready` or `ready_callout_pending`.
- Show fallback instruction to staff.
- Record DID device failure evidence.
- Do not lose pickup readiness state.

### 14.5 Privacy Masking Failure

If privacy masking fails:

- Block KDS/DID display where PII exposure is possible.
- Record security exception.
- Use token-only display mode.
- Escalate according to security incident procedure if exposure occurred.

## 15. Privacy And Retention Rules

Delivery app data must follow minimum exposure rules:

- KDS station screens receive only kitchen-needed data.
- DID receives only pickup token data.
- Logs receive redacted payloads.
- Evidence packets receive redacted or encrypted data.
- Raw payload access is restricted.
- Customer PII must be masked or deleted according to approved retention policy.

Any delivery-channel-specific retention rule must be documented in the relevant policy and evidence packet.

## 16. Audit Ledger Requirements

Every material runtime transition must produce an audit event.

Required audit events:

- `delivery_order_received`
- `delivery_order_normalized`
- `delivery_order_accepted`
- `kds_card_created`
- `station_route_created`
- `station_item_bumped`
- `assembly_ready`
- `packing_ready`
- `did_callout_requested`
- `did_callout_displayed`
- `handoff_completed`
- `delivery_order_exception_hold`

Each audit event must include:

- Internal order ID.
- External channel order ID or redacted reference.
- Store ID.
- Channel.
- Actor or device ID where applicable.
- Timestamp.
- Previous state.
- New state.
- Idempotency / dedupe reference.
- CHANGE_ID if related to controlled implementation.

## 17. Evidence Packet Requirements

For implementation and field verification, evidence must include:

- Sample redacted payload.
- Normalized order contract snapshot.
- KDS card snapshot or structured event record.
- Station routing record.
- Bump event record.
- DID callout event record.
- Privacy masking confirmation.
- Duplicate order test result.
- DID failure fallback test result.
- Audit ledger event list.
- Raw logs if running through the 51355 pipeline.

## 18. Local Store Fallback Rules

If network, API gateway, KDS, or DID is degraded:

- Store staff may use approved manual fallback.
- Manual fallback must not bypass privacy policy.
- Manual fallback must preserve order ID / pickup token.
- Manual completion must be reconciled later.
- Manual paper notes must not contain full customer PII unless unavoidable and approved by emergency rule.

## 19. Prohibited Behavior

The following are prohibited:

- Accepting orders from unofficial scraping.
- Creating KDS cards from unvalidated payloads.
- Displaying full customer PII on station KDS.
- Displaying customer address on DID.
- Treating DID display success as handoff completion.
- Treating station bump as full order completion.
- Recreating duplicate order cards for duplicate callbacks.
- Dropping failed DID callout without evidence.
- Clearing exception holds without audit.
- Updating delivery app status without verified kitchen state.

## 20. Verification Checklist

Before this SOP is used for implementation:

- [ ] Official intake source is identified.
- [ ] Channel adapter contract exists.
- [ ] POS projection boundary is documented.
- [ ] KDS card schema is documented.
- [ ] Station routing rules are documented.
- [ ] DID payload schema is documented.
- [ ] Privacy masking rules are documented.
- [ ] Retention rules are documented.
- [ ] Duplicate order handling is documented.
- [ ] Unknown state handling is documented.
- [ ] DID failure fallback is documented.
- [ ] Audit ledger event list is approved.
- [ ] Evidence packet template is approved.
- [ ] 51355 pipeline context snapshot references this 750000 bundle.

## 21. Relationship To 750000 Bundle

This SOP belongs to:

```text
docs/700000_runtime_flow_bundle/750000_delivery_app_channel_integration/
```

Related documents:

- `750000_Index_Delivery_App_Channel_Integration_KDS_DID_And_Order_Ingestion_Runtime.md`
- `750010_Assessment_Delivery_App_Channel_API_KDS_DID_And_Omnichannel_Order_Ingestion_Architecture.md`
- `750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md`
- `750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md`
- `750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md`
- `750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md`
- `750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md`

## 22. Relationship To 51355 Pipeline

When this SOP is used for implementation, the 51355 pipeline must receive this document as part of the sliced context snapshot only when the implementation touches:

- Delivery app order intake.
- KDS card creation.
- Station routing.
- Bump action.
- DID callout.
- Privacy masking.
- Delivery app status update.
- Kitchen runtime audit/evidence.

This SOP must not be injected into unrelated modules such as general admin UI, unrelated membership logic, or non-delivery payment modules.

## 23. Final Operating Rule

```text
No delivery app order enters KDS without official intake validation.
No KDS route is complete without station evidence.
No DID callout happens without packing readiness.
No customer data appears where a kitchen token is enough.
No runtime state changes without audit and evidence.
```
