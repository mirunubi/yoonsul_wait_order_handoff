# 750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md

## 1. Purpose

This policy defines the official API integration and no-scraping boundary for delivery app channel integration in `yoonsul_wait_order_handoff`.

The purpose is to ensure that delivery app orders are ingested only through authorized, auditable, and privacy-safe integration paths before they are routed into POS, KDS, DID, kitchen station, rider pickup, customer callout, analytics, audit, and evidence flows.

This policy exists because delivery app order data can include:

- customer identifiers,
- phone numbers,
- delivery addresses,
- order items,
- special requests,
- pickup expectations,
- rider or courier status,
- platform-specific order identifiers,
- payment or settlement-adjacent metadata,
- operational timestamps.

Any unofficial extraction method can create security, privacy, legal, reconciliation, and operational continuity risks.

## 2. Scope

This policy applies to every delivery app channel integration including, but not limited to:

- Baedal Minjok / Baemin style delivery channels,
- Yogiyo style delivery channels,
- Coupang Eats style delivery channels,
- delivery agency bridge channels,
- order aggregation services,
- POS delivery manager plugins,
- KDS delivery order ingestion modules,
- DID pickup callout modules,
- store runtime dashboard projections,
- kitchen station routing modules,
- audit ledger and evidence packet generation.

This policy applies whether the integration is implemented by:

- direct cloud-to-cloud API,
- official partner gateway,
- approved POS vendor plugin,
- approved local bridge client,
- webhook,
- polling endpoint,
- WebSocket stream,
- HMAC-signed request,
- OAuth-based merchant authorization,
- token-based channel authorization.

## 3. Core Policy

Delivery app order data must be collected only through official, approved, and traceable integration paths.

```text
Official API first.
No scraping.
No memory hooking.
No unauthorized screen parsing.
No unmanaged credential sharing.
No silent customer data replication.
No long-term plaintext personal data storage.
```

Any delivery app integration that cannot prove an official authorization path must be treated as blocked until reviewed and approved.

## 4. Approved Integration Paths

Approved integration paths may include:

1. Official delivery platform API.
2. Official partner API gateway.
3. Delivery platform-approved POS vendor integration.
4. Delivery platform-approved order aggregation service.
5. Platform-issued merchant token authorization.
6. OAuth-style merchant authorization flow.
7. HMAC-signed server-to-server API.
8. Platform-approved webhook or WebSocket event stream.
9. Approved local bridge client that is documented, authorized, and monitored.
10. Official delivery manager plugin provided by a trusted POS or KDS vendor.

Each approved path must have:

- channel owner,
- authorization method,
- credential storage policy,
- token rotation rule,
- IP allowlist rule where applicable,
- webhook signature verification rule where applicable,
- event deduplication rule,
- order ID mapping rule,
- audit ledger rule,
- privacy masking rule,
- degraded mode rule,
- rollback or disconnect procedure.

## 5. Forbidden Integration Paths

The following are forbidden unless a separate legal, security, and provider-approved exception exists:

- screen scraping,
- browser DOM scraping,
- mobile app screen scraping,
- OCR of order screens,
- clipboard scraping,
- memory hooking,
- packet sniffing,
- reverse-engineered private API calls,
- credential sharing with unapproved third-party tools,
- storing platform account passwords in plain text,
- using personal store owner accounts as unattended service credentials,
- intercepting printer data without documented authorization,
- duplicating customer personal data into unmanaged local files,
- using automation bots to click delivery app order screens,
- bypassing official partner approval requirements,
- replaying captured platform requests,
- using platform cookies or session tokens outside approved clients.

If a legacy virtual printer or local bridge is used, it must be explicitly classified as:

```text
Legacy compatibility bridge, not primary integration architecture.
```

It must have a migration path toward official API or approved partner gateway integration.

## 6. Legacy Bridge Boundary

Some store environments may still depend on:

- PC order reception programs,
- local delivery manager plugins,
- virtual printer ports,
- serial printer emulation,
- ESC/POS parsing,
- local Windows bridge clients.

These paths may be temporarily allowed only when all of the following conditions are met:

1. The bridge is vendor-approved or platform-approved.
2. The bridge does not scrape unauthorized UI surfaces.
3. The bridge does not store sensitive customer data beyond approved retention windows.
4. The bridge has a documented failure mode.
5. The bridge has a migration path to official API integration.
6. The bridge output is normalized before entering KDS/DID state machines.
7. The bridge cannot directly finalize financial or customer-visible states without verification.
8. The bridge is identified in audit evidence as a legacy path.

Legacy bridge data must not be treated as equivalent to verified official API data unless the provider contract says so.

## 7. Security Requirements

Every official delivery app integration must define the following security controls.

### 7.1 Authentication

Allowed patterns include:

- OAuth authorization,
- vendor code plus one-time authorization code,
- API key plus secret key,
- HMAC signature,
- mTLS where available,
- provider-issued merchant token,
- approved POS or KDS vendor credential exchange.

Forbidden patterns include:

- hardcoded shared credentials,
- plaintext password storage,
- unattended personal account sessions,
- unrotated static secrets without owner,
- screenshots of credentials in support channels,
- storing secret keys in Markdown documents.

### 7.2 Signature Verification

Webhook, polling, and callback flows must verify:

- signature,
- timestamp,
- replay window,
- nonce or idempotency key where available,
- provider order identifier,
- merchant/store identifier,
- request source where applicable.

Unsigned delivery events may enter only a quarantine or manual review path.

### 7.3 IP Allowlist And Network Boundary

Where a provider supports IP allowlisting, the integration must document:

- source IP,
- destination endpoint,
- environment,
- owner,
- approval date,
- rotation plan,
- incident revocation procedure.

IP allowlist is not a replacement for request signing.

### 7.4 Secret Handling

Delivery app API credentials must be stored only in approved secret storage.

They must not be stored in:

- source code,
- Markdown docs,
- screenshots,
- spreadsheet cells,
- chat transcripts,
- test fixtures,
- local plain text config files,
- customer support notes.

## 8. Data Minimization And Privacy

Delivery app data must be minimized before it enters durable storage.

### 8.1 Personal Data Classes

Sensitive delivery app personal data may include:

- customer phone number,
- customer address,
- detailed delivery instruction,
- building access code,
- door password,
- customer name,
- platform account identifier,
- rider contact data,
- free-text special requests containing personal data.

### 8.2 Masking Rule

Customer personal data must be masked, tokenized, or deleted according to the approved retention rule.

At minimum, KDS and POS projections must not retain customer personal data longer than required for active order handling, dispute handling, or legal retention.

### 8.3 KDS/DID Projection Rule

KDS and DID screens must display only the minimum fields required for kitchen execution or pickup identification.

DID must never expose:

- customer phone number,
- full address,
- full customer name unless required and approved,
- delivery access code,
- payment-sensitive information,
- internal platform token,
- rider personal contact data beyond approved operational display.

## 9. Order Identity And Idempotency

Every delivery app order event must be normalized into an internal channel order identity.

Required identity fields:

- provider code,
- provider order ID,
- store ID,
- channel account ID if applicable,
- internal order ID,
- event type,
- provider event timestamp,
- received timestamp,
- idempotency key or derived duplicate key,
- CHANGE_ID when the integration change is under implementation evidence review.

Duplicate events must not create duplicate kitchen cards, duplicate DID callouts, duplicate pickup notifications, or duplicate audit ledger rows without deduplication metadata.

## 10. KDS And DID Boundary

Delivery app order ingestion must not directly mutate every downstream screen without a state transition layer.

Required routing sequence:

```text
Delivery App Event
  -> Ingestion Adapter
  -> Normalization
  -> Validation
  -> Idempotency Check
  -> Privacy Filter
  -> Order State Machine
  -> KDS Projection
  -> Station Routing
  -> Bump / Complete Event
  -> DID Projection
  -> Audit / Evidence
```

KDS/DID projection must be treated as a runtime view of verified state, not as the source of truth.

## 11. No-Scraping Review Checklist

Before approving any delivery app channel integration, the owner must confirm:

- [ ] The integration uses an official API, approved partner gateway, or documented approved bridge.
- [ ] The integration does not scrape screens or private UI surfaces.
- [ ] The integration does not use memory hooking.
- [ ] The integration does not reverse engineer private endpoints.
- [ ] Credentials are not shared or stored in plain text.
- [ ] Webhook or callback signatures are verified where applicable.
- [ ] Duplicate events are deduplicated.
- [ ] Personal data is minimized and masked.
- [ ] KDS/DID display fields are limited.
- [ ] Raw provider payload retention is bounded.
- [ ] Audit ledger records provider event identity.
- [ ] Evidence packet includes the approved integration path.
- [ ] Degraded mode and fallback are documented.
- [ ] Disconnect and rollback procedure is documented.

## 12. Evidence Requirements

Each delivery app integration must produce evidence containing:

- provider or partner authorization path,
- approved integration method,
- credential storage confirmation without exposing secrets,
- endpoint list,
- webhook signature verification result,
- idempotency and duplicate test result,
- privacy masking test result,
- KDS projection test result,
- DID projection test result,
- degraded mode test result,
- rollback or disconnect test result,
- raw log path,
- git diff summary,
- audit review result.

Evidence must be stored under the implementation evidence folder for the related `CHANGE_ID`.

## 13. Failure And Degraded Mode

If an official delivery app API fails, the system must degrade safely.

Allowed degraded modes:

- show channel disconnected warning,
- block new auto-ingestion from the affected channel,
- allow manual order entry with explicit source label,
- queue incoming signed but temporarily unprocessed events,
- continue KDS processing for already accepted orders,
- mark DID state as pending if kitchen completion is not verified,
- retain audit trail of outage and manual override.

Forbidden degraded modes:

- silently treating missing provider confirmation as success,
- fabricating provider state,
- duplicating orders from retry without idempotency,
- showing customer pickup complete without kitchen completion,
- exposing raw personal data during fallback,
- bypassing signature verification to restore service quickly,
- storing provider credentials locally for emergency use.

## 14. Relationship To 51355 Pipeline

This policy is a domain rule slice for the AI-assisted financial-grade development pipeline.

When a delivery app channel integration change is implemented through the 51355 pipeline, this document must be included in the Context Snapshot if any of the following are touched:

- delivery app order ingestion,
- webhook or polling adapter,
- HMAC or OAuth authorization,
- provider token storage,
- KDS order projection,
- DID callout projection,
- customer privacy masking,
- channel fallback or degraded mode,
- provider order ID mapping,
- audit ledger and evidence packet for delivery order events.

## 15. Related Documents

Expected related documents in this bundle:

- `750000_Index_Delivery_App_Channel_Integration_KDS_DID_And_Order_Ingestion_Runtime.md`
- `750010_Assessment_Delivery_App_Channel_API_KDS_DID_And_Omnichannel_Order_Ingestion_Architecture.md`
- `750020_Guide_Delivery_App_API_KDS_DID_Integration_Context_Summary.md`
- `750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md`
- `750050_Matrix_Delivery_Platform_POS_KDS_DID_Channel_Integration_Map.md`
- `750060_Policy_KDS_DID_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md`
- `750070_SOP_KDS_Order_Intake_Routing_Bump_And_DID_Callout_Runtime.md`

## 16. Final Rule

```text
Delivery app integration is allowed only through official, approved, and auditable paths.
Unofficial scraping, hooking, credential sharing, and unmanaged personal data replication are prohibited.
KDS and DID must receive normalized, deduplicated, privacy-filtered, and audit-ready order state.
```
