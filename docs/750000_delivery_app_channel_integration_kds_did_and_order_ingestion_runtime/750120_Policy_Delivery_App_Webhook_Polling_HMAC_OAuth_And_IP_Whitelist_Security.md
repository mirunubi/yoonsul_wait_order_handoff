# 750120_Policy_Delivery_App_Webhook_Polling_HMAC_OAuth_And_IP_Whitelist_Security.md

## 1. Purpose

This policy defines the security boundary for delivery app channel integration in `yoonsul_wait_order_handoff`.

The purpose is to ensure that delivery app order ingestion, KDS routing, DID callout, rider pickup status, and related kitchen runtime events are handled only through approved, authenticated, signed, and auditable integration paths.

This document belongs to:

```text
700000_runtime_flow_bundle/
  750000_delivery_app_channel_integration/
```

This policy is designed for use with the `51355` AI-assisted financial-grade development pipeline as a domain-specific security rule slice.

## 2. Scope

This policy applies to all delivery app channel integrations involving:

- Delivery app order ingestion.
- Webhook-based order push.
- Polling-based order fetch.
- OAuth or merchant-token authorization.
- HMAC or equivalent request signing.
- IP whitelist or network boundary control.
- POS projection.
- KDS card creation.
- Station KDS routing.
- DID customer or rider callout.
- Audit ledger and evidence packet generation.
- Privacy masking and redaction.

## 3. Core Rule

```text
No delivery app order event may enter the runtime unless its source, authorization, signature, replay window, idempotency key, privacy boundary, and evidence path are verified.
```

Delivery app integration must never rely on trust in payload text alone.

Every accepted event must be traceable to:

1. Approved channel provider.
2. Approved merchant/store mapping.
3. Approved credential set.
4. Verified authentication method.
5. Verified request integrity method.
6. Accepted replay window.
7. Idempotency or duplicate prevention key.
8. Audit event.
9. Evidence record.

## 4. Allowed Integration Methods

Allowed methods:

| Method | Allowed | Conditions |
|---|---:|---|
| Official platform API | Yes | Must use approved credentials and documented API contract. |
| Approved partner gateway | Yes | Must have contract, credential isolation, and evidence export. |
| Approved local bridge | Conditional | Must be documented, observable, and cannot scrape UI or memory. |
| Webhook push | Yes | Must validate signature, timestamp, source, and idempotency. |
| Polling fetch | Yes | Must enforce rate limit, cursor checkpoint, and duplicate prevention. |
| Legacy printer-port bridge | Temporary only | Must be approved as degraded/transition mode and cannot store raw PII long term. |

Forbidden methods:

| Method | Status | Reason |
|---|---:|---|
| Screen scraping | Forbidden | Fragile, non-contractual, privacy risk. |
| Memory hooking | Forbidden | Unsafe, non-contractual, privacy and security risk. |
| Undocumented private API | Forbidden | Contract drift and account risk. |
| Shared merchant credentials | Forbidden | No isolation or attribution. |
| Plaintext long-lived secret storage | Forbidden | Credential exposure risk. |
| Unsigned external callback acceptance | Forbidden | Forgery and replay risk. |
| DID display of sensitive customer data | Forbidden | Privacy breach risk. |

## 5. Authentication Policy

### 5.1 OAuth / Merchant Authorization

OAuth-like or merchant authorization flows must ensure:

- Store owner consent is recorded.
- Merchant identifier is mapped to an internal store ID.
- Access token is scoped to the minimum required permission.
- Refresh token storage is encrypted or delegated to a secret manager.
- Token rotation is supported.
- Token revocation is handled.
- Failed authorization does not create a partial active integration.

### 5.2 API Key / Secret Key Authorization

API key based integrations must ensure:

- Access key and secret key are never committed to source code.
- Secret material is not stored in Markdown docs.
- Secret material is not sent to AI tools.
- Secret material is not included in raw logs.
- Secret material is redacted in evidence packets.
- Key owner, store, provider, and environment are mapped.
- Production and sandbox credentials are separated.

### 5.3 Merchant Code / One-Time Verification Code

If a platform uses merchant code plus one-time verification:

- The one-time code must not be persisted after exchange.
- The final mapped credential must be linked to store/provider/environment.
- Reuse of one-time verification code must be rejected.
- Failed exchange attempts must be audit logged if material.

## 6. HMAC / Signature Policy

If provider supports HMAC or equivalent signing, it must be used.

### 6.1 Required Signature Inputs

Signature verification should include, where supported:

- HTTP method.
- Request path.
- Query string.
- Timestamp.
- Nonce or request ID.
- Raw request body hash.
- Provider identifier.
- Merchant/store identifier.

### 6.2 Signature Verification Rule

```text
Do not parse a delivery app event into business state until the signature has passed.
```

Processing order:

1. Receive raw request.
2. Capture request metadata.
3. Validate source network boundary if configured.
4. Validate timestamp window.
5. Validate nonce/request ID if available.
6. Validate HMAC or provider signature.
7. Only then parse payload.
8. Only then map provider status to internal state.
9. Only then create KDS/DID runtime events.

### 6.3 Signature Failure Handling

Signature failure must:

- Reject the request.
- Avoid writing business state.
- Avoid creating KDS card.
- Avoid DID callout.
- Record security event with redacted payload metadata.
- Preserve enough evidence for audit.
- Avoid logging secrets or full customer PII.

## 7. Timestamp, Nonce, And Replay Protection

External delivery app events must be protected against replay.

Required controls:

- Maximum accepted timestamp drift.
- Nonce or request ID tracking where available.
- Idempotency key or provider event ID tracking.
- Duplicate callback detection.
- Retry-safe state transition.
- Evidence record for duplicate/replay rejection.

Default rule:

```text
A duplicate external event must never create duplicate order, duplicate KDS card, duplicate DID callout, duplicate rider pickup notification, or duplicate audit finality.
```

## 8. Webhook Policy

Webhook ingestion must support:

- Provider source validation.
- Signature verification.
- Event type allowlist.
- Payload schema validation.
- Provider order ID uniqueness check.
- Store mapping validation.
- Status transition validation.
- Idempotency lock.
- Retry-safe response behavior.
- Raw event evidence with redaction.

### 8.1 Webhook Event Types

Webhook event types must be normalized into internal event categories:

| Provider Event Type | Internal Event Category | Notes |
|---|---|---|
| New order | `delivery_order_created` | Creates intake candidate, not final KDS state until accepted. |
| Order accepted | `delivery_order_accepted` | May create KDS card depending on provider flow. |
| Order canceled | `delivery_order_canceled` | Must check if cooking has started. |
| Rider assigned | `delivery_rider_assigned` | KDS/DID may show pickup timing only if privacy-safe. |
| Ready for pickup | `delivery_order_ready` | DID callout may be triggered. |
| Pickup completed | `delivery_pickup_completed` | Triggers masking/retention timer where applicable. |
| Delivery completed | `delivery_completed` | May trigger retention/masking. |
| Unknown/error | `delivery_status_unknown` | Must not be treated as success or failure without evidence. |

### 8.2 Webhook Retry Response Rule

Webhook handlers must return responses that are safe for provider retries.

- If event is valid and already processed, return success with duplicate-safe handling.
- If event is invalid due to signature failure, reject.
- If event is temporarily blocked due to internal lock, return retry-safe error where appropriate.
- If provider status is unknown, do not finalize KDS/DID state.

## 9. Polling Policy

Polling is allowed only when push/webhook is unavailable or insufficient.

Polling must include:

- Provider-approved polling interval.
- Rate limit control.
- Cursor or checkpoint persistence.
- Last successful fetch evidence.
- Duplicate prevention by provider order ID and event timestamp.
- Partial failure handling.
- Backoff and retry rule.
- Alert on prolonged polling failure.

### 9.1 Polling Cursor Rule

```text
Polling cursor movement must be atomic with event persistence or replay-safe by design.
```

If the system advances a cursor before safely recording fetched events, orders may be lost.

If the system records events before advancing a cursor, duplicates may occur.

Therefore the implementation must define one of:

- Atomic transaction boundary.
- Replay-safe idempotent persistence.
- Provider-supported cursor acknowledgement model.

## 10. IP Whitelist And Network Boundary Policy

Where supported by provider or partner gateway, IP whitelist must be used.

Allowed controls:

- Provider inbound source IP allowlist.
- Outbound egress IP registration.
- WAF rule for webhook endpoint.
- TLS enforcement.
- Separate sandbox and production endpoints.
- Provider-specific endpoint segregation.

Forbidden:

- Accepting production delivery events on debug endpoints.
- Sharing one webhook endpoint across providers without provider validation.
- Disabling TLS checks.
- Trusting IP whitelist without signature verification.

IP whitelist is defense-in-depth, not a substitute for cryptographic verification.

## 11. Store And Provider Mapping Policy

Every incoming delivery app event must be mapped through:

```text
provider_id
provider_store_id
internal_store_id
integration_environment
credential_set_id
channel_order_id
```

Mapping failure must block business processing.

Mapping failure may create diagnostic evidence but must not:

- Create KDS card.
- Notify DID.
- Mark order accepted.
- Trigger rider callout.
- Write final customer-facing status.

## 12. Payload Validation Policy

Required validation:

- Event type allowlist.
- Provider order ID presence.
- Store mapping presence.
- Menu item payload shape.
- Option/modifier payload shape.
- Quantity validation.
- Price/currency validation where present.
- Customer data redaction profile.
- Requested pickup/delivery time sanity.
- Status transition validity.

Payload validation failure must be recorded as blocked intake, not silently ignored.

## 13. Privacy And Redaction Boundary

Security logs and evidence packets must not leak sensitive customer data.

The following must be redacted unless explicitly required and approved:

- Customer phone number.
- Detailed address.
- Door password or access notes.
- Personal request text containing sensitive data.
- Payment token or provider credential.
- Secret key, access key, refresh token.
- Signature secret.

KDS and DID display must use the minimum operational fields only.

DID must not display customer address, phone, or private request text.

## 14. KDS/DID Runtime Security Rule

External delivery app events must not directly control KDS or DID.

Required flow:

```text
External Provider Event
  -> Security Verification
  -> Store Mapping
  -> Payload Validation
  -> Normalized Order Event
  -> POS / Runtime Projection
  -> KDS Card
  -> Station Routing
  -> Assembly / Packing State
  -> DID Callout
  -> Audit / Evidence
```

KDS/DID must consume internal normalized state, not raw provider payload.

## 15. Failure Mode Policy

### 15.1 Signature Failure

- Reject external event.
- Record redacted security evidence.
- Alert if repeated.
- Do not create business state.

### 15.2 Token Expired

- Block ingestion for affected store/provider.
- Raise integration health warning.
- Do not fall back to scraping.
- Require reauthorization or approved token refresh.

### 15.3 Provider Timeout

- Mark event fetch status as unknown or retry pending.
- Do not infer order acceptance.
- Do not create false finality on KDS/DID.

### 15.4 Duplicate Webhook

- Return idempotent success if already applied.
- Do not duplicate KDS card or DID callout.
- Record duplicate detection evidence.

### 15.5 Polling Gap

- Detect cursor gap.
- Stop final closeout until reconciled.
- Provide manual recovery path.
- Preserve provider fetch evidence.

### 15.6 Network Boundary Drift

- Block unrecognized source if policy requires whitelist.
- Record diagnostic event.
- Require provider/IP configuration review.

## 16. Audit Ledger Requirements

Material security and order lifecycle events must be audit logged.

Required events:

- Integration credential created.
- Credential rotated.
- Credential revoked.
- Webhook received.
- Signature validation failed.
- Signature validation passed.
- Duplicate event detected.
- Replay window rejected.
- Store mapping failed.
- Payload validation failed.
- Normalized order created.
- KDS card created.
- DID callout emitted.
- Polling cursor advanced.
- Polling gap detected.
- Privacy masking completed.

Each audit event must include:

- `CHANGE_ID` where implementation/change context exists.
- Provider ID.
- Internal store ID.
- Provider event ID or order ID.
- Internal normalized event ID.
- Redacted metadata.
- Actor/system source.
- Timestamp.

## 17. Evidence Packet Requirements

Evidence packet must include:

```text
docs/implementation_evidence/<change_id>/
  raw_logs/
  webhook_sample_redacted.md
  signature_verification_result.md
  polling_cursor_result.md
  duplicate_event_test_result.md
  replay_window_test_result.md
  store_mapping_test_result.md
  privacy_redaction_result.md
  kds_did_runtime_result.md
  audit_ledger_result.md
```

For production vendor onboarding, evidence must also include:

- Provider credential setup checklist.
- Sandbox test result.
- Production dry-run or staged rollout result.
- IP whitelist confirmation if used.
- Secret redaction confirmation.
- Data retention and masking confirmation.

## 18. Testing Requirements

Required tests:

| Test | Required |
|---|---:|
| Valid webhook signature accepted | Yes |
| Invalid webhook signature rejected | Yes |
| Old timestamp rejected | Yes |
| Duplicate event ignored/idempotent | Yes |
| Replay event rejected | Yes |
| Token expired blocks ingestion | Yes |
| Provider store mapping missing blocks processing | Yes |
| Payload schema invalid blocks processing | Yes |
| Polling cursor replay safe | Yes |
| Polling gap detected | Yes |
| KDS card not created before security verification | Yes |
| DID callout not emitted for invalid event | Yes |
| Secret redaction in raw logs | Yes |
| Customer PII masking in evidence | Yes |
| CHANGE_ID mapped in audit/evidence | Yes |

## 19. 51355 Pipeline Injection Rule

When implementing or modifying delivery app webhook, polling, HMAC, OAuth, or IP whitelist logic, the `51355` pipeline must receive this policy as part of the context snapshot.

Recommended context slot:

```text
Context Slot: delivery_app_security
Required File:
- 750120_Policy_Delivery_App_Webhook_Polling_HMAC_OAuth_And_IP_Whitelist_Security.md
Related Files:
- 750030_Policy_Delivery_App_Official_API_Integration_And_No_Scraping_Boundary.md
- 750040_Boundary_POS_API_Gateway_KDS_DID_And_Kitchen_Runtime_Responsibility.md
- 750050_Matrix_Delivery_App_POS_KDS_DID_Channel_Integration_Map.md
- 750060_Policy_Delivery_App_Customer_Privacy_Masking_Tokenization_And_Data_Retention.md
```

## 20. Prohibited Implementation Shortcuts

The following shortcuts are prohibited:

- Accepting webhook payload before verifying signature.
- Treating provider timeout as acceptance.
- Treating unknown provider state as cancellation.
- Creating KDS card before store mapping.
- Triggering DID callout from raw provider payload.
- Logging full payload containing PII.
- Logging secrets in raw logs.
- Sharing one credential across stores.
- Advancing polling cursor without replay-safe persistence.
- Falling back to scraping when token expires.
- Marking duplicate webhook as new order.
- Allowing Codex to broaden integration scope without new approval.

## 21. Human Approval Gate

Human approval is required before:

- Adding a new delivery app provider.
- Adding a new credential type.
- Changing webhook verification logic.
- Changing HMAC/signature code.
- Changing polling cursor logic.
- Changing provider status mapping.
- Changing DID callout trigger rules.
- Changing customer privacy redaction rules.
- Expanding data retention duration.
- Touching production credentials or IP whitelist configuration.

## 22. Final Rule

```text
Official API is not enough.
Signed event is not enough.
Whitelisted IP is not enough.

Delivery app runtime is acceptable only when authentication, signature, replay protection, store mapping, payload validation, privacy redaction, idempotency, audit, and evidence all pass together.
```
