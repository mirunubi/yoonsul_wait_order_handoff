# 005095_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping

\#\# 1\. Purpose

This document records the implementation approach for integrating the Yoonsul Wait/Order Handoff project with Toss POS / Toss Place based on the provided Toss POS integration notes and verified Toss Place Open API / Webhook behavior.

This document is inserted between the test catalog documents and the final test catalog lane index because Toss POS integration directly affects:

\- POS handoff
\- payment verification
\- webhook idempotency
\- order cancellation boundary
\- merchant mapping
\- Android / tablet runtime
\- Apps in Toss miniapp runtime
\- vendor credential handling
\- rate limiting
\- support evidence
\- deployment gates

This document does not implement Toss POS integration.

It defines how Toss POS integration should be mapped into future implementation and existing test catalog policies.

\---

\#\# 2\. Source Status

The following items are treated as verified from Toss Place official Open API / Webhook documentation:

\- Open API uses \`x-access-key\` and \`x-secret-key\` request headers.
\- Open API request and response bodies use JSON.
\- API error response includes structured failure information.
\- Open API rate limiting uses a Token Bucket model.
\- Rate limit headers include \`x-ratelimit-limit\`, \`x-ratelimit-remaining\`, and \`x-ratelimit-reset\`.
\- Rate limit is managed per merchant.
\- Webhook uses HTTP POST delivery.
\- Webhook delivery follows at-least-once behavior.
\- Duplicate webhook delivery must be handled by the receiver.
\- \`x-toss-webhook-id\` should be used as idempotency key.
\- Webhook signature uses HMAC-SHA256.
\- Webhook signature message format is \`\<x-toss-timestamp\>.\<rawRequestBody\>\`.
\- Webhook signature header is \`x-toss-signature\`.
\- Timestamp freshness should be checked.
\- Signature verification failure should return 401 or 400\.
\- Toss Place webhook sending IP is documented as \`15.165.6.198\`.

The following items are based on the user-provided source text and must be rechecked against official Toss Place / Apps in Toss / POS Plugin SDK documentation before implementation:

\- Apps in Toss micro frontend runtime behavior
\- Android / tablet miniapp sandbox behavior
\- mandatory runtime framework 2.x requirement
\- package versions such as \`@apps-in-toss/web-framework@2.4.1\`
\- package versions such as \`@apps-in-toss/framework@2.4.1\`
\- build command transition from \`granite build\` to \`ait build\`
\- React 19 / React Native 0.84 compatibility requirements
\- debug sandbox package installation flow
\- POS Plugin SDK device APIs such as \`posPluginSdk.device.getDeviceInfo()\`
\- Storage API usage for local client-side state
\- Toss POS specific miniapp review / release requirements

Until official confirmation is completed, those items must be treated as provisional integration assumptions.

\---

\#\# 3\. Core Principle

Toss POS integration must be split into two lanes:

1\. \*\*In-Device Miniapp Lane\*\*
   \- Apps in Toss / Android tablet / POS Plugin SDK / local storage / device metadata

2\. \*\*Cloud Integration Lane\*\*
   \- Open API / Webhook / payment lookup / order lookup / cancellation status / merchant mapping / backend sync

The project must not mix these two lanes into one authority boundary.

The rule is:

\> Toss POS may provide device runtime context, POS order context, payment lookup, webhook events, and merchant identity, but Yoonsul must still preserve its own tenant/store mapping, idempotency, audit, payment boundary, and degraded recovery rules.

\---

\#\# 4\. Integration Architecture Summary

Recommended architecture:

\- Toss POS / Toss Place
  \- merchant identity
  \- order identity
  \- payment identity
  \- webhook events
  \- POS-side cancellation state
  \- Apps in Toss runtime where available

\- Yoonsul Toss Integration Gateway
  \- receives Toss webhooks
  \- validates signature
  \- verifies timestamp freshness
  \- enforces idempotency
  \- maps merchantId to tenant/store
  \- maps Toss order/payment ids to Yoonsul handoff records
  \- queues or quarantines ambiguous events
  \- emits audit events
  \- does not directly trust client-side success or miniapp state

\- Yoonsul POS/KDS Bridge
  \- receives verified POS/order/payment signals
  \- creates handoff candidates
  \- routes to KDS only after policy validation
  \- preserves POS ownership of transaction truth
  \- preserves KDS ownership of kitchen execution truth

\- Yoonsul Payment Runtime
  \- treats Toss payment webhook and payment lookup as external verified payment signals
  \- applies payment idempotency
  \- separates refund/cancel/settlement authority

\- Yoonsul Support / Audit / Evidence Runtime
  \- records webhook headers, event ids, verification result, merchant mapping, and downstream decisions
  \- masks secrets and raw provider payloads
  \- links incidents and mismatches to evidence packets

\---

\#\# 5\. Toss Integration Runtime Components

Future implementation should separate these components:

| Component | Responsibility | Must Not Do |
| \--------- | \-------------- | \----------- |
| Toss Miniapp Front Runtime | Runs UI inside Toss POS / Android tablet where approved | Must not own payment truth |
| Toss POS Plugin Adapter | Reads allowed device/runtime metadata | Must not persist secrets broadly |
| Toss Storage Adapter | Stores minimal local UI/session state | Must not store long-lived secrets or final truth |
| Toss Open API Client | Calls Toss Place Open API with credential pair | Must not expose keys to client |
| Toss Webhook Receiver | Receives and verifies Toss webhook events | Must not process unsigned or replayed events |
| Toss Merchant Mapper | Maps Toss merchantId to Yoonsul tenant/store | Must not default to broad tenant/store |
| Toss Payment Mapper | Maps paymentId/orderId to Yoonsul payment/order context | Must not confirm mismatched payment |
| Toss Cancellation Mapper | Handles POS-side cancellation status | Must not assume financial refund |
| Toss Evidence Builder | Builds evidence packet for webhook/order/payment mismatch | Must not duplicate raw secrets |

\---

\#\# 6\. Apps in Toss / Android Miniapp Lane

Based on the user-provided text, the Android miniapp lane should be treated as a constrained runtime embedded inside Toss POS.

Implementation direction:

\- Build a Toss-compatible miniapp only after official Apps in Toss documentation is reverified.
\- Adopt required framework 2.x packages only after official version confirmation.
\- Treat the miniapp as a UI/runtime adapter, not the source of financial truth.
\- Use POS Plugin SDK device APIs only for device/runtime metadata needed for operational context.
\- Store only minimal local UI/session state in Toss-provided storage.
\- Never store Toss Open API \`x-secret-key\` in client-side miniapp storage.
\- Never store Webhook Secret Key in miniapp storage.
\- Never let miniapp directly approve refund, payment confirmation, settlement, export, account merge, or support unmasking.
\- Miniapp may request Yoonsul backend actions through controlled APIs.
\- Yoonsul backend must revalidate tenant/store/merchant context before accepting any miniapp-originated action.

The miniapp lane is an operational surface, not an authority surface.

\---

\#\# 7\. Open API Cloud Lane

The Open API lane should be backend-only.

Required behavior:

\- Store \`x-access-key\` and \`x-secret-key\` only in secure backend secret storage.
\- Never expose Open API credentials to Android app, Apps in Toss miniapp, Store Tablet, browser, KDS, or support UI.
\- Use merchant-scoped API calls.
\- Persist Toss request trace id where available.
\- Handle 401 as credential/config issue.
\- Handle 429 with rate limiting pacer.
\- Handle 500 or network failures with retry/backoff and evidence.
\- Maintain per-merchant request budget.
\- Never use Toss Open API result without mapping \`merchantId\` to Yoonsul tenant/store.
\- Never allow Toss API response to overwrite Yoonsul final state without policy validation.

Recommended internal service name:

    TossPlaceOpenApiClient

Recommended internal gateway name:

    TossPlaceIntegrationGateway

\---

\#\# 8\. Webhook Receiver Lane

The Toss webhook receiver must be designed as a financial-grade external ingress.

Required behavior:

\- Receive raw request body exactly as delivered.
\- Read \`x-toss-timestamp\`.
\- Read \`x-toss-signature\`.
\- Read \`x-toss-webhook-id\`.
\- Read \`x-toss-event-id\`.
\- Read \`x-toss-delivery-id\`.
\- Verify timestamp freshness.
\- Verify HMAC-SHA256 signature using Webhook Secret Key.
\- Use \`x-toss-webhook-id\` as idempotency key.
\- Record \`x-toss-delivery-id\` per retry attempt.
\- Reject or quarantine missing signature.
\- Reject or quarantine invalid signature.
\- Reject or quarantine stale timestamp.
\- Reject or quarantine merchantId mismatch.
\- Reject or quarantine unsupported event type.
\- Preserve raw body only in restricted evidence storage if absolutely required.
\- Store masked event summary for ordinary audit.

Webhook processing must be at-least-once safe.

\---

\#\# 9\. Toss Merchant Mapping Policy

Toss \`merchantId\` must be mapped to Yoonsul tenant/store context.

Required mapping fields:

\- toss\_merchant\_id
\- tenant\_id
\- store\_id
\- legal\_entity\_id where applicable
\- operating\_group\_id where applicable
\- toss\_app\_id or app package where applicable
\- active\_from
\- active\_until
\- status
\- environment
\- credential\_reference\_id
\- webhook\_secret\_reference\_id
\- last\_verified\_at

Mapping rules:

\- Unknown \`merchantId\` must be quarantined.
\- Inactive merchant mapping must be denied.
\- Cross-environment merchant mapping must be denied.
\- One Toss merchant may map to one Yoonsul store unless explicit multi-store mapping is approved.
\- No default fallback to tenant-wide access is allowed.
\- Merchant mapping changes must be audited.
\- Merchant mapping changes must require deployment/config review.

\---

\#\# 10\. Toss Payment Event Mapping

Toss payment events should map into Yoonsul payment runtime as external verified signals only after validation.

Supported event classes from the user-provided text:

\- payment approved
\- payment cancelled

Recommended Yoonsul mapping:

| Toss Event | Yoonsul Candidate State | Authority Rule |
| \---------- | \---------------------- | \-------------- |
| payment.payment.approved.v1 | PAYMENT\_PROVIDER\_CONFIRMED | Requires signature, merchant mapping, amount/reference validation |
| payment.payment.cancelled.v1 | PAYMENT\_PROVIDER\_CANCELLED | Requires signature, merchant mapping, payment reference validation |
| duplicate webhook | DUPLICATE\_IGNORED\_OR\_PRIOR\_RESULT | Must not duplicate mutation |
| mismatched merchant/payment/order | PAYMENT\_RECONCILIATION\_REQUIRED | Must not confirm or cancel |
| stale/replayed event | REPLAY\_DETECTED\_OR\_QUARANTINED | Must not mutate final state |

Payment mapping must preserve:

\- payment webhook idempotency
\- payment amount validation
\- orderId/paymentId linkage validation
\- tenant/store validation
\- audit lineage
\- settlement impact review

\---

\#\# 11\. Toss Order And Cancellation Mapping

The user-provided text states that the Toss order cancel API changes POS data to \`CANCELLED\` but does not trigger actual credit card financial cancellation.

Therefore, Yoonsul must separate:

\- POS order cancellation state
\- payment refund/cancellation state
\- customer-facing cancellation status
\- kitchen/KDS cancellation handling
\- settlement impact

Implementation rule:

\> Toss POS order cancellation is not automatically financial refund.

Required behavior:

\- Treat Toss POS order cancel as POS operational status change.
\- Do not mark payment refunded from POS cancel alone.
\- Do not trigger settlement reversal from POS cancel alone.
\- If payment was already confirmed, create refund review or reconciliation candidate.
\- If KDS is already cooking/ready/served, create POS/KDS mismatch or kitchen review candidate.
\- Customer message must not say “refunded” unless provider refund is verified.
\- Audit must link Toss order cancel call, payment state, KDS state, and review decision.

\---

\#\# 12\. Rate Limiting And Pacer Policy

Toss Open API rate limiting must be handled by Yoonsul backend.

Required behavior:

\- Track rate limit per Toss merchant.
\- Read \`x-ratelimit-limit\`.
\- Read \`x-ratelimit-remaining\`.
\- Read \`x-ratelimit-reset\`.
\- Implement merchant-scoped pacer.
\- Avoid burst polling.
\- On 429, do not retry immediately.
\- Queue retry after reset time or backoff window.
\- Mark affected sync as delayed, not failed immediately.
\- Create audit or operational trace for repeated 429\.
\- Create vendor incident candidate if rate limit blocks critical runtime repeatedly.

Rate limiting must not create duplicate POS/KDS tickets or duplicate payment states.

\---

\#\# 13\. Secret And Credential Handling

Toss credentials must be treated as high-risk vendor secrets.

Secrets include:

\- x-access-key
\- x-secret-key
\- Webhook Secret Key
\- Apps in Toss build/deploy credentials where applicable
\- POS Plugin credentials where applicable
\- Android debug signing credentials where applicable
\- production release credentials

Rules:

\- Open API secret key must never be stored in client runtime.
\- Webhook secret key must never be stored in client runtime.
\- Secret values must not appear in logs, audit payloads, export files, AI prompts, support notes, or evidence packets.
\- Secret rotation must be possible.
\- Lost secret requires credential revocation and reissue.
\- Environment-specific credentials must not cross environments.
\- Developer sandbox credentials must not be used in production.
\- Production credentials must not be used in local/staging.

\---

\#\# 14\. Device And Android Sandbox Policy

Based on the user-provided Android sandbox notes, future implementation should treat Android / Apps in Toss device testing as a separate non-production lane.

Rules:

\- Android debug sandbox must never use production Toss credentials.
\- ADB-installed debug packages must be limited to local/dev/staging.
\- Debug package installation commands must not be included in production runbooks without environment warnings.
\- Device metadata from POS Plugin SDK must be treated as contextual signal, not authentication by itself.
\- Device info may help bind runtime context but must not replace Toss merchant mapping or Yoonsul device trust.
\- Local client storage may store temporary UI state but not long-lived secrets.
\- Local storage state must not become final operational truth.

Recommended state:

\- DEVICE\_CONTEXT\_OBSERVED
\- DEVICE\_CONTEXT\_UNVERIFIED
\- DEVICE\_CONTEXT\_TRUSTED\_BY\_BACKEND
\- DEVICE\_CONTEXT\_REVOKED
\- DEVICE\_CONTEXT\_MISMATCH
\- DEVICE\_CONTEXT\_REVIEW\_REQUIRED

\---

\#\# 15\. Yoonsul Runtime Boundary Mapping

Toss integration must align with existing Yoonsul runtime rules.

| Yoonsul Rule | Toss Integration Interpretation |
| \------------ | \------------------------------- |
| POS owns transaction truth | Toss POS/order/payment events are external POS/payment signals |
| KDS owns kitchen execution truth | Toss POS event may create KDS handoff candidate, not direct kitchen truth |
| Bridge validates and relays | Toss Integration Gateway validates merchant/payment/order/webhook |
| Payment truth belongs to payment boundary | Toss payment webhook can confirm only after verification |
| Support note is not approval | Support cannot override Toss payment/refund truth |
| Replay is not mutation | Toss webhook replay must not mutate final state |
| Sync is not silent merge | Toss polling/webhook mismatch creates reconciliation |
| View authority is not export authority | Toss data view does not grant export/vendor sharing |
| Device trust is separate from user authority | Toss device metadata does not replace user/session validation |
| AI recommends only | AI cannot approve Toss refund/cancel/reconciliation |

\---

\#\# 16\. Recommended Implementation Phases

\#\#\# Phase 0: Documentation And Official Reverification

\- Recheck Apps in Toss framework 2.x requirement.
\- Recheck POS Plugin SDK APIs.
\- Recheck app review / deployment process.
\- Recheck Open API endpoints.
\- Recheck webhook event list.
\- Recheck payment cancellation and order cancellation distinction.
\- Recheck production credential issuance and rotation rules.
\- Record official references in vendor integration evidence packet.

No code implementation in this phase.

\---

\#\#\# Phase 1: Backend-Only Toss Open API / Webhook Skeleton

Implement later only after approval:

\- Toss merchant mapping model
\- Toss credential reference model
\- Toss webhook receiver
\- HMAC verification
\- timestamp freshness validation
\- idempotency using webhook id
\- merchant mapping validation
\- event quarantine
\- audit event creation
\- rate limit pacer
\- payment lookup adapter
\- order lookup adapter
\- by-order-id payment lookup adapter

No Apps in Toss UI dependency yet.

\---

\#\#\# Phase 2: Payment And Order Reconciliation

Implement later only after Phase 1 is stable:

\- Toss payment approved mapping
\- Toss payment cancelled mapping
\- payment by orderId lookup
\- Toss order cancel status mapping
\- Yoonsul payment reconciliation candidate
\- Yoonsul refund review candidate
\- POS/KDS mismatch candidate
\- customer-safe status
\- support evidence packet

\---

\#\#\# Phase 3: POS/KDS Handoff Integration

Implement later only after payment/order mapping is stable:

\- Toss order accepted signal to Yoonsul handoff candidate
\- KDS ticket creation through Yoonsul bridge
\- duplicate event prevention
\- stale event handling
\- POS cancel versus KDS cooking mismatch
\- retry/replay evidence
\- support operational review

\---

\#\#\# Phase 4: Apps in Toss Miniapp

Implement later only after official Apps in Toss requirements are reverified:

\- Toss miniapp shell
\- Android tablet runtime test
\- POS Plugin SDK device metadata read
\- storage of minimal client UI state
\- backend-mediated action requests
\- no client-side Toss secret
\- no client-side payment truth
\- no direct KDS mutation without backend validation

\---

\#\#\# Phase 5: Production Release Gate

Implement later only after full test evidence:

\- Toss webhook signature tests
\- idempotency tests
\- replay tests
\- merchant mapping tests
\- rate limit tests
\- secret handling tests
\- payment reconciliation tests
\- POS/KDS mismatch tests
\- support masking tests
\- deployment rollback tests

\---

\#\# 17\. Toss-Specific Test Mapping

This Toss integration requires coverage from the following existing test catalog documents:

\- 04981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog
\- 04991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy
\- 05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog
\- 05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog
\- 05031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog
\- 05041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog
\- 05061_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog
\- 05071_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog
\- 05081_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog
\- 05091_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog

Toss integration must not be implemented unless these mapped tests are either defined or explicitly deferred with scope reduction.

\---

\#\# 18\. Toss-Specific Required Tests

Required Toss integration tests:

1\. Valid Toss webhook signature accepted.
2\. Invalid Toss webhook signature rejected.
3\. Missing Toss signature rejected.
4\. Stale Toss timestamp rejected.
5\. Duplicate \`x-toss-webhook-id\` does not duplicate mutation.
6\. Same webhook id with conflicting payload is quarantined.
7\. Replayed webhook does not mutate final state.
8\. Unknown merchantId is quarantined.
9\. Inactive merchant mapping is denied.
10\. Cross-tenant merchant mapping is denied.
11\. Cross-store merchant mapping is denied.
12\. Payment approved event requires amount/reference validation.
13\. Payment cancelled event does not automatically imply refund unless provider semantics confirm.
14\. Toss order cancel does not trigger financial refund automatically.
15\. POS cancel while KDS cooking creates mismatch/review.
16\. Open API 429 triggers rate limit pacer.
17\. Open API credentials are never exposed to client.
18\. Webhook secret is never logged.
19\. Toss event ids are preserved in audit.
20\. Toss delivery ids are preserved for retry evidence.
21\. Toss raw payload is masked or restricted.
22\. Apps in Toss miniapp cannot store backend secrets.
23\. POS Plugin SDK device info is not treated as authority by itself.
24\. Debug Android sandbox cannot use production credentials.
25\. Toss integration release requires deployment gate approval.

\---

\#\# 19\. Data Model Candidates

Future implementation may need these tables or equivalent records:

\- toss\_merchants
\- toss\_merchant\_store\_mappings
\- toss\_api\_credentials
\- toss\_webhook\_secrets
\- toss\_webhook\_events
\- toss\_webhook\_deliveries
\- toss\_webhook\_idempotency\_keys
\- toss\_payment\_mappings
\- toss\_order\_mappings
\- toss\_order\_cancel\_events
\- toss\_api\_request\_logs
\- toss\_rate\_limit\_states
\- toss\_event\_quarantine
\- toss\_reconciliation\_cases
\- toss\_integration\_evidence\_packets

These are candidates only.

No schema is implemented by this document.

\---

\#\# 20\. Toss Event State Candidates

Recommended internal states:

\- TOSS\_WEBHOOK\_RECEIVED
\- TOSS\_WEBHOOK\_SIGNATURE\_VERIFIED
\- TOSS\_WEBHOOK\_SIGNATURE\_FAILED
\- TOSS\_WEBHOOK\_TIMESTAMP\_STALE
\- TOSS\_WEBHOOK\_DUPLICATE\_DETECTED
\- TOSS\_WEBHOOK\_REPLAY\_DETECTED
\- TOSS\_WEBHOOK\_CONFLICTING\_DUPLICATE
\- TOSS\_WEBHOOK\_MERCHANT\_UNKNOWN
\- TOSS\_WEBHOOK\_MERCHANT\_INACTIVE
\- TOSS\_WEBHOOK\_SCOPE\_MISMATCH
\- TOSS\_WEBHOOK\_QUARANTINED
\- TOSS\_PAYMENT\_APPROVED\_VERIFIED
\- TOSS\_PAYMENT\_CANCELLED\_VERIFIED
\- TOSS\_PAYMENT\_RECONCILIATION\_REQUIRED
\- TOSS\_ORDER\_CANCEL\_POS\_ONLY
\- TOSS\_ORDER\_KDS\_MISMATCH\_REVIEW\_REQUIRED
\- TOSS\_API\_RATE\_LIMITED
\- TOSS\_API\_RETRY\_SCHEDULED
\- TOSS\_API\_CREDENTIAL\_ERROR
\- TOSS\_INTEGRATION\_REVIEW\_REQUIRED

These names are conceptual and may be changed later.

\---

\#\# 21\. Evidence Requirements

Toss integration evidence must include:

\- Toss merchantId
\- Yoonsul tenant\_id
\- Yoonsul store\_id
\- Toss app/package reference where applicable
\- Toss webhook id
\- Toss event id
\- Toss delivery id
\- Toss timestamp
\- signature verification result
\- idempotency result
\- event type
\- paymentId where applicable
\- orderId where applicable
\- amount class where applicable
\- Toss API response trace id where applicable
\- rate limit headers where applicable
\- mapping decision
\- quarantine reason where applicable
\- downstream Yoonsul state decision
\- audit event reference
\- reconciliation case reference where applicable

Evidence must not include:

\- x-secret-key
\- Webhook Secret Key
\- raw CI / DI
\- payment token
\- card data
\- provider secret
\- auth header
\- unrestricted raw payload
\- service role key

\---

\#\# 22\. Security Requirements

Toss integration must satisfy:

\- backend-only Open API credentials
\- backend-only webhook secret
\- HMAC signature verification
\- timestamp freshness validation
\- idempotency enforcement
\- merchantId tenant/store mapping
\- event type allowlist
\- unknown event quarantine
\- retry-safe processing
\- rate limit pacer
\- secret masking
\- audit append-only
\- deployment gate approval
\- rollback readiness
\- support scoped visibility
\- AI prohibited input exclusion
\- export restriction

\---

\#\# 23\. Non-Goals

This document does not define:

\- final Toss SDK code
\- final Apps in Toss miniapp
\- final Android project setup
\- final package.json
\- final build script
\- final ADB command usage
\- final Toss Open API client implementation
\- final webhook handler implementation
\- final database schema
\- final KDS integration implementation
\- final payment reconciliation implementation
\- final production deployment

Those belong to later controlled implementation phase.

\---

\#\# 24\. Readiness Check

This Toss integration approach is ready when the project can answer:

1\. Which Toss facts are officially verified?
2\. Which Apps in Toss assumptions still require official confirmation?
3\. How is Toss merchantId mapped to Yoonsul tenant/store?
4\. Where are Toss Open API credentials stored?
5\. Where is Webhook Secret Key stored?
6\. How is Toss webhook signature verified?
7\. How is timestamp freshness checked?
8\. How is \`x-toss-webhook-id\` used for idempotency?
9\. How are \`x-toss-event-id\` and \`x-toss-delivery-id\` recorded?
10\. How is unknown merchantId quarantined?
11\. How is duplicate webhook handled?
12\. How is replayed webhook handled?
13\. How is conflicting duplicate webhook handled?
14\. How is Toss payment approved mapped?
15\. How is Toss payment cancelled mapped?
16\. How is Toss order cancel separated from financial refund?
17\. How is POS cancel versus KDS progress mismatch handled?
18\. How is rate limit pacing handled?
19\. How is 429 handled safely?
20\. How is Apps in Toss miniapp prevented from storing secrets?
21\. How is POS Plugin device info treated as context, not authority?
22\. How is debug sandbox separated from production?
23\. How are Toss events audited?
24\. How are Toss evidence packets built?
25\. Which existing test catalogs are mapped to Toss integration?
26\. What blocks Toss production release?

If these questions cannot be answered, Toss POS integration is not ready for implementation.

\---

\#\# 25\. Conclusion

Toss POS integration should be treated as a vendor-grade, payment-adjacent, POS-adjacent, device-adjacent runtime boundary.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

\- Toss Open API credentials stay backend-only
\- Toss Webhook Secret Key stays backend-only
\- Apps in Toss miniapp is UI/runtime adapter, not financial authority
\- POS Plugin device info is context, not authority
\- Toss merchantId must map to Yoonsul tenant/store
\- unknown merchantId is quarantined
\- webhook signature must be verified
\- webhook timestamp freshness must be checked
\- webhook idempotency must use Toss webhook id
\- duplicate webhook must not duplicate mutation
\- replayed webhook must not mutate final truth
\- Toss payment approved/cancelled events require validation
\- Toss order cancel is not automatically financial refund
\- POS/KDS mismatch creates review, not silent overwrite
\- Open API rate limiting requires merchant-scoped pacer
\- Toss secrets must never enter logs, support notes, export, audit payload, AI prompt, or client storage
\- Toss integration evidence must preserve trace ids without leaking secrets
\- production release requires official document recheck, test mapping, deployment gate, and rollback plan

This document does not implement Toss POS integration.

It records the Toss POS integration implementation approach and maps it to the existing Yoonsul test catalog and runtime boundary policies.
