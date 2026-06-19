# 750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md

## 1. Purpose

This matrix defines the integration map between delivery app channels, POS projection, API gateway, KDS, DID, audit, evidence, and kitchen runtime components for `yoonsul_wait_order_handoff`.

The goal is to prevent delivery app integration from becoming an uncontrolled adapter layer.

This document must be used when designing or reviewing any runtime flow involving:

- Delivery app order ingestion.
- Official delivery platform API integration.
- POS projection or POS bridge synchronization.
- KDS card creation and station routing.
- DID customer or rider callout.
- Kitchen bump and assembly status transition.
- Customer privacy masking.
- Audit ledger and evidence packet generation.
- Manual fallback for degraded delivery channel conditions.

This matrix belongs to:

```text
docs/700000_runtime_flow_bundle/750000_delivery_app_channel_integration/
```

## 2. Scope

### 2.1 In Scope

- Baemin / Yogiyo / Coupang Eats style delivery app channel integration.
- Official API or approved partner gateway ingestion.
- Approved local bridge ingestion where unavoidable.
- Delivery order normalization.
- POS projection boundary.
- KDS routing and station splitting.
- DID pickup and rider notification boundary.
- Privacy masking and data retention boundary.
- Runtime evidence generation.
- Failure and fallback routing.

### 2.2 Out Of Scope

- Unapproved screen scraping.
- Memory hooking.
- Credential sharing outside approved token flow.
- Long-term storage of plaintext customer phone/address.
- Direct KDS modification of provider-owned order state.
- Direct DID mutation of financial or order acceptance state.
- Runtime implementation code.

## 3. Core Operating Rule

```text
Delivery app data must enter the system through an approved channel adapter.
The adapter normalizes the order.
The POS/API Gateway owns acceptance and financial projection.
The KDS owns kitchen execution visibility.
The DID owns external callout visibility.
Audit/Evidence owns traceability.
No layer may silently replace another layer's responsibility.
```

## 4. Channel Integration Map

| Channel Type | Allowed Ingestion Method | Forbidden Method | Authentication / Trust Boundary | Primary Runtime Owner |
|---|---|---|---|---|
| Delivery app official API | Official REST / webhook / polling API | Screen scraping, packet sniffing, memory hook | OAuth2, API key, HMAC, partner token, IP allowlist where required | Channel Adapter |
| Delivery app approved partner gateway | Contracted partner gateway or platform-approved bridge | Informal vendor proxy | Partner-issued merchant token and scoped access | Channel Adapter |
| Delivery app local bridge | Approved PC agent / approved local bridge only | Unverified local executable or hidden parser | Store-authorized credential exchange and device registration | Local Bridge Adapter |
| POS order projection | Internal normalized order projection | Direct mutation from KDS or DID | Internal service role / least privilege | POS Projection |
| KDS order card | Derived kitchen execution view | Provider order object as-is | Internal normalized order ID and station routing | KDS Runtime |
| DID callout | Derived pickup visibility | Direct provider callback from DID | Order display token / masked identifier | DID Runtime |
| Audit / evidence | Append-only event and packet trail | Manual free-text only | CHANGE_ID, order correlation ID, actor ID | Audit/Evidence Runtime |

## 5. Platform-Specific Reference Matrix

This matrix is a planning reference. Actual integration must be confirmed through current official platform documentation and partner agreements before implementation.

| Platform Family | Typical Integration Pattern | Security Pattern | KDS/DID Impact | Key Risk |
|---|---|---|---|---|
| Baemin-like channel | Official partner API, webhook, PC bridge in some environments | Merchant authorization, partner token, app/account authorization | New order push, acceptance status, prep/ready status reflection | Unauthorized local bridge or stale credential |
| Yogiyo-like channel | Official API, seller portal code exchange, legacy bridge compatibility | Store code, one-time authorization code, scoped integration | Order ingestion, kitchen card generation, possible legacy port compatibility | Treating legacy bridge output as authoritative source |
| Coupang Eats-like channel | Open API with signed request style | API key, access key, secret key, HMAC/signature, timestamp, IP allowlist where required | Structured order metadata and status update integration | Signature replay, secret leakage, wrong clock/timestamp handling |
| Delivery agency linked channel | Dispatch API or delivery agency gateway | Agency token, store mapping, rider status callback | Rider pickup timing and DID readiness coordination | Rider status mismatch with kitchen readiness |
| Multi-brand shared kitchen channel | Multiple store/channel accounts normalized into one runtime view | Per-store token isolation and account mapping | Unified KDS queue, brand badge, station aggregation | Cross-store data leakage or wrong brand routing |

## 6. Runtime Component Responsibility Matrix

| Runtime Component | Owns | Does Not Own | Required Evidence |
|---|---|---|---|
| Channel Adapter | Provider payload reception, verification, normalization, provider event correlation | Final financial state, KDS station execution, DID display policy | Raw provider event reference, signature verification result, normalized payload hash |
| API Gateway | Internal command validation, idempotency gate, routing to POS/KDS projection | Provider credential storage outside approved secret vault, direct UI display | Request ID, idempotency key, authorization decision |
| POS Projection | Store-facing order acceptance projection, sales/payment projection where applicable | Provider raw payload persistence beyond allowed scope, kitchen station timing | POS projection event, order status transition |
| KDS Runtime | Kitchen queue card, station routing, bump event, assembly state | Financial settlement, provider order acceptance, customer privacy retention | KDS card created, station route, bump timestamp |
| Station KDS | Grill/fryer/drink/packing station task visibility | Global order truth, customer notification | Station task event, station completion timestamp |
| Assembly / Packing | Merge of station completion into ready-for-pickup state | Provider payout/settlement | Assembly complete event, packaging complete event |
| DID Runtime | Customer/rider callout display and optional voice callout | Customer PII display, provider callback authority | Display token, callout timestamp, masked order number |
| Audit Ledger | Append-only trace of material state changes | Replacing source of truth | CHANGE_ID, actor/system ID, order correlation ID |
| Evidence Packet | Release/test/incident traceability | Runtime decision making | Manifest, raw logs, diff, test result, screenshots where applicable |

## 7. Event Flow Mapping

| Step | Source | Target | Event / Payload | Required Control |
|---:|---|---|---|---|
| 1 | Delivery App | Channel Adapter | New order / changed order / cancel event | Signature/token verification |
| 2 | Channel Adapter | Normalization Layer | Provider-specific payload | Provider mapping table and payload hash |
| 3 | Normalization Layer | API Gateway | Internal order command | Idempotency key and duplicate check |
| 4 | API Gateway | POS Projection | Accepted delivery order projection | Store/channel/account ownership check |
| 5 | POS Projection | KDS Runtime | Kitchen card creation event | No PII beyond required kitchen fields |
| 6 | KDS Runtime | Station KDS | Station-specific task events | BOM/menu routing rule |
| 7 | Station KDS | KDS Runtime | Bump / station complete event | Actor/device/time capture |
| 8 | KDS Runtime | Assembly/Packing | Ready-to-assemble / ready-to-pack event | Completion consistency check |
| 9 | Assembly/Packing | DID Runtime | Ready callout event | Masked display token only |
| 10 | DID Runtime | Customer/Rider Surface | Pickup number / rider order number | No phone/address exposure |
| 11 | All Runtime Layers | Audit/Evidence | Material transition events | CHANGE_ID and correlation ID required |

## 8. Data Field Mapping

| Data Class | Example Fields | May Flow To KDS | May Flow To DID | Retention Rule |
|---|---|---:|---:|---|
| Order identity | internal_order_id, provider_order_id, channel_code | Yes | Tokenized only | Retain per audit policy |
| Store identity | store_id, brand_id, kitchen_zone | Yes | No | Retain per operational policy |
| Menu data | menu_code, option_code, quantity, allergy flag if approved | Yes | No | Retain per order policy |
| Customer request | cooking note, delivery note | Limited | No | Mask or delete after allowed period |
| Customer phone | phone number | No unless explicitly required and masked | No | Mask/delete after delivery completion policy |
| Customer address | address, detailed address | No | No | Mask/delete after delivery completion policy |
| Rider info | rider pickup code, rider status | Limited | Limited token only | Retain only operational event |
| Payment data | amount, provider payment state | POS/API only | No | Financial audit policy |
| Kitchen timing | accepted_at, started_at, bumped_at, ready_at | Yes | Limited ready event | Retain for KPI and audit |
| Evidence metadata | CHANGE_ID, event_id, raw_event_hash | No UI display | No UI display | Retain per evidence policy |

## 9. Integration Risk Matrix

| Risk | Example Failure | Impact | Required Control |
|---|---|---|---|
| Duplicate order ingestion | Same webhook delivered twice | Duplicate KDS card, duplicate preparation | Idempotency key and provider event ID dedupe |
| Provider status mismatch | Provider pending treated as accepted | Wrong customer promise | Unknown state handling and conservative display |
| Unauthorized scraping | Unofficial app parser used | Privacy and legal exposure | Official API/no scraping boundary |
| PII leakage to kitchen | Phone/address shown on station KDS | Privacy breach | PII minimization and masking rule |
| DID overexposure | DID displays customer name/phone | Public privacy breach | Masked pickup token only |
| Wrong brand routing | Shared kitchen order sent to wrong station | Operational error and leakage | Store/channel/brand mapping validation |
| Signature replay | Old signed request reused | Fraudulent status/event injection | Timestamp window and nonce/replay check |
| Secret leakage | API secret stored in plain config | Channel compromise | Secret vault and rotation rule |
| Legacy bridge drift | PC bridge UI changes parser behavior | Missed or malformed orders | Approved bridge only and fallback monitoring |
| Missing evidence | Runtime event not linked to CHANGE_ID | Audit failure | CHANGE_ID required in evidence metadata |

## 10. Context Snapshot Slice For 51355 Pipeline

When this matrix is used as part of the `51355` development pipeline, do not inject every KDS/DID document.

Use this slice:

```text
Required:
- 750000_Index_Delivery_App_Channel_Integration_KDS_DID_And_Order_Ingestion_Runtime.md
- 750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md
- 750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md
- 750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md
- 750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md

Conditional:
- privacy masking policy if customer PII is touched
- HMAC/OAuth/webhook security policy if provider API auth is touched
- KDS smart routing logic if station routing is touched
- DID callout SOP if customer/rider display is touched
```

## 11. Cursor Stage 1 Search Additions

When Cursor prepares `impact_scope.md` for a delivery app / KDS / DID change, it must search for:

```text
- delivery channel adapter files
- provider payload mapping files
- webhook or polling handlers
- API signature verification code
- idempotency and duplicate event storage
- POS order projection files
- KDS card creation files
- KDS station routing files
- DID display/callout files
- privacy masking and retention code
- audit ledger event writers
- evidence packet manifest logic
- fallback/manual recovery runbooks
- related 750000 documents
```

Cursor must not modify any file during this search.

## 12. Claude Stage 2 Design Additions

Claude must explicitly answer:

```text
- Which delivery app channel is affected?
- Is the integration official API, approved partner gateway, or approved bridge?
- Is any customer PII touched?
- Is KDS station routing changed?
- Is DID display changed?
- Is provider status synchronized back to the app?
- Does the change affect order acceptance, prep, ready, pickup, cancel, or failure state?
- What is the idempotency key?
- What is the duplicate event rule?
- What is the unknown provider state rule?
- What audit ledger event is required?
- What evidence packet entry is required?
```

## 13. Codex Implementation Boundary Additions

Codex must not:

```text
- add a new delivery channel integration without approved platform documentation
- parse delivery app UI
- scrape delivery app screens
- hook memory or local network traffic
- store provider secrets in source code
- expose customer phone/address to KDS/DID
- mutate provider state from DID
- create broad adapter abstraction across providers unless explicitly approved
- change POS payment or settlement logic while implementing KDS visibility
```

Codex must:

```text
- keep provider-specific mapping explicit
- keep idempotency and duplicate prevention visible
- preserve provider raw event reference or hash
- write audit/evidence events with CHANGE_ID
- add tests for duplicate webhook/polling event
- add tests for unknown status
- add tests for privacy masking if PII is touched
```

## 14. Automated Gate Requirements

At minimum, the gate must verify:

```text
- unauthorized file changes: none
- git diff --check: pass
- lint/typecheck: pass
- delivery adapter tests: pass
- webhook duplicate test: pass where applicable
- signature/HMAC/OAuth validation test: pass where applicable
- KDS routing test: pass where applicable
- DID masking/display test: pass where applicable
- audit/evidence CHANGE_ID test: pass
```

Raw logs must be stored under:

```text
docs/implementation_evidence/<change_id>/raw_logs/
```

## 15. Acceptance Criteria

This matrix is satisfied only when:

- All delivery app ingestion is official or explicitly approved.
- All provider events are normalized before entering internal runtime.
- POS projection, KDS, DID, audit, and evidence ownership are separated.
- Customer PII is minimized and masked.
- Duplicate provider events cannot create duplicate KDS cards.
- DID never displays forbidden customer data.
- KDS routing can be traced to menu/BOM/station rules.
- Runtime events can be traced by CHANGE_ID and order correlation ID.
- Raw verification logs are preserved for high-risk changes.

## 16. Non-Negotiable Rules

```text
No scraping.
No memory hooking.
No unofficial provider API.
No plaintext long-term customer PII.
No DID exposure of phone/address.
No direct DID provider mutation.
No KDS authority over financial truth.
No implementation without approved context slice.
No merge without raw verification logs for high-risk delivery/KDS/DID changes.
```

## 17. Recommended Next Documents

```text
750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md
750070_SOP_KDS_Order_Intake_Routing_Bump_And_DID_Callout_Runtime.md
750080_Logic_KDS_Smart_Routing_Station_Splitting_BOM_And_Assembly_State_Machine.md
750090_Checklist_KDS_DID_Hardware_Environmental_Durability_And_Installation_Readiness.md
```

## 18. Closeout Statement

This matrix locks the delivery app channel integration responsibility boundary for the `750000_delivery_app_channel_integration` package.

It prevents the delivery app adapter, POS projection, KDS, DID, audit, and evidence layers from collapsing into one uncontrolled runtime module.

Any implementation derived from this matrix must pass through the `51355` financial-grade AI-assisted development pipeline with a sliced context snapshot.
