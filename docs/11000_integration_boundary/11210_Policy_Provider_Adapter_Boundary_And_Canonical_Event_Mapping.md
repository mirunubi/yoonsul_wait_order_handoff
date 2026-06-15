# 11210_Policy_Provider_Adapter_Boundary_And_Canonical_Event_Mapping

Legacy path: $old.

\#\# 1\. Purpose

This document defines the provider adapter boundary and canonical event mapping policy for the Yoonsul Wait/Order Handoff project.

The project must support multiple provider architecture families over time:

\- Toss-style cloud Open API / webhook providers
\- OKPOS-style local daemon / OKDC providers
\- PAYCO-style payment / smart-order providers
\- Smartro-style local agent providers
\- KICC / NICE style VAN / payment API providers
\- Hyphen-style API hub providers
\- future minor POS and kiosk providers

These providers must not directly define Yoonsul internal runtime truth.

This document defines how provider-specific events should be mapped into Yoonsul canonical events while preserving provider differences, uncertainty, evidence, and recovery boundaries.

This document does not implement provider adapters, event schemas, databases, APIs, queues, webhook handlers, daemon clients, or KDS bridge logic.

It defines future adapter policy only.

\---

\#\# 2\. Scope

This document covers:

\- provider adapter boundary
\- canonical event family
\- provider-specific event mapping
\- Toss event mapping
\- OKPOS event mapping
\- PAYCO event mapping
\- local daemon event mapping
\- cloud webhook event mapping
\- payment event mapping
\- order event mapping
\- KDS handoff event mapping
\- uncertainty and quarantine mapping
\- evidence requirement
\- no-implementation boundary

This document does not cover:

\- final provider adapter code
\- final canonical event table
\- final event queue
\- final webhook receiver
\- final OKDC daemon client
\- final payment gateway code
\- final KDS implementation
\- final database schema
\- final deployment pipeline

\---

\#\# 3\. Core Principle

Provider events are not Yoonsul truth until mapped, validated, and evidenced.

The project must follow this rule:

\> Provider-specific events must enter Yoonsul through an adapter boundary and must be converted into canonical internal events only after tenant/store mapping, authority validation, idempotency, and evidence rules are applied.

A provider event is an input.

It is not automatically:

\- payment truth
\- order truth
\- KDS truth
\- refund truth
\- settlement truth
\- customer identity truth
\- support resolution truth

\---

\#\# 4\. Source Documents

This policy reuses:

\- 05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog
\- 05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog
\- 05081_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog
\- 05091_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog
\- 05096_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping
\- 05170 PAYCO POS Integration Implementation Approach And Official Verification Policy
\- 11160_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping
\- 11180_Policy_Toss_Base_Strategy_And_OKPOS_Compatibility_Interface
\- 11190_Policy_Table_Order_POS_Ecosystem_Phase_2_And_Phase_3_Expansion_Roadmap
\- 11200_Policy_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison

\---

\#\# 5\. Provider Adapter Definition

A provider adapter is a boundary layer that receives, validates, translates, and evidences provider-specific signals before passing them into Yoonsul internal runtime.

Provider adapter may:

\- receive webhook
\- call provider API
\- receive callback
\- communicate with local daemon
\- parse provider event
\- validate signature or credential
\- map merchant/store identifiers
\- apply idempotency
\- detect replay
\- classify event type
\- create evidence packet
\- quarantine ambiguous event
\- emit canonical event candidate

Provider adapter must not:

\- directly create KDS ticket
\- directly mark payment approved without validation
\- directly refund customer
\- directly merge customer identity
\- directly overwrite Yoonsul order state
\- directly mutate settlement final state
\- bypass audit
\- bypass release gate
\- hide provider-specific uncertainty
\- normalize away critical provider differences

\---

\#\# 6\. Canonical Event Concept

A canonical event is a Yoonsul internal event shape used after provider-specific input has passed adapter validation.

Canonical events are not provider raw payloads.

They are normalized, controlled, evidence-linked internal signals.

Recommended event families:

\- \`PROVIDER\_EVENT\_RECEIVED\`
\- \`PROVIDER\_EVENT\_VALIDATED\`
\- \`PROVIDER\_EVENT\_REJECTED\`
\- \`PROVIDER\_EVENT\_QUARANTINED\`
\- \`PROVIDER\_MERCHANT\_MAPPED\`
\- \`PROVIDER\_MERCHANT\_MAPPING\_FAILED\`
\- \`ORDER\_INTENT\_CREATED\`
\- \`ORDER\_PROVIDER\_ACCEPTED\`
\- \`ORDER\_PROVIDER\_REJECTED\`
\- \`ORDER\_PROVIDER\_UNCERTAIN\`
\- \`PAYMENT\_PROVIDER\_APPROVED\`
\- \`PAYMENT\_PROVIDER\_FAILED\`
\- \`PAYMENT\_PROVIDER\_CANCELLED\`
\- \`PAYMENT\_PROVIDER\_UNCERTAIN\`
\- \`REFUND\_PROVIDER\_REQUESTED\`
\- \`REFUND\_PROVIDER\_APPROVED\`
\- \`REFUND\_PROVIDER\_FAILED\`
\- \`HANDOFF\_CANDIDATE\_CREATED\`
\- \`HANDOFF\_CANDIDATE\_REJECTED\`
\- \`KDS\_HANDOFF\_READY\`
\- \`KDS\_HANDOFF\_BLOCKED\`
\- \`RECOVERY\_REVIEW\_REQUIRED\`
\- \`SUPPORT\_REVIEW\_REQUIRED\`
\- \`RECONCILIATION\_REQUIRED\`

These are conceptual names only.

Final implementation may use different names.

\---

\#\# 7\. Provider Event Ingestion Stages

Provider event ingestion must follow staged processing.

Recommended stages:

1\. Receive provider signal.
2\. Record raw receipt metadata.
3\. Validate transport authenticity.
4\. Validate timestamp/freshness where applicable.
5\. Validate idempotency key.
6\. Detect replay or duplicate.
7\. Map provider merchant/store to Yoonsul tenant/store.
8\. Classify event type.
9\. Validate authority boundary.
10\. Create evidence reference.
11\. Emit canonical event candidate.
12\. Route to payment/order/KDS/recovery runtime.
13\. Quarantine if ambiguous.

No provider event should skip directly from receive to runtime mutation.

\---

\#\# 8\. Provider Adapter Families

Provider adapters should be grouped by architecture family.

| Adapter Family | Provider Examples | Primary Risk |
| \-------------- | \----------------- | \------------ |
| Cloud Open API Adapter | Toss, I'M U | webhook replay, API key, rate limit |
| Local Daemon Adapter | OKPOS, Smartro | daemon failure, local timeout, duplicate local output |
| Payment Gateway Adapter | PAYCO, NICE, KICC | auth/approval separation, refund/cancel boundary |
| API Hub Adapter | Hyphen | hidden downstream provider behavior |
| Hardware Certified Adapter | CAT, scanner, terminal | device certification, local signal ambiguity |
| External Operational Channel Adapter | Smart Order programs | local program output not backend truth |

Each adapter family should preserve its own risk model.

\---

\#\# 9\. Canonical Mapping Rule

Canonical mapping must preserve these dimensions:

\- source provider
\- provider architecture family
\- tenant/store mapping
\- source event id
\- idempotency key
\- provider order reference
\- provider payment reference
\- provider customer reference where allowed
\- provider timestamp
\- received timestamp
\- validation result
\- authority classification
\- confidence level
\- evidence packet id
\- quarantine status
\- recovery requirement

Do not map provider payload directly into runtime state without these dimensions.

\---

\#\# 10\. Authority Classification

Every provider event must be classified by authority.

Recommended authority classes:

\- \`OBSERVATION\_ONLY\`
\- \`ORDER\_SIGNAL\`
\- \`PAYMENT\_SIGNAL\`
\- \`REFUND\_SIGNAL\`
\- \`SETTLEMENT\_SIGNAL\`
\- \`CUSTOMER\_IDENTITY\_SIGNAL\`
\- \`DEVICE\_SIGNAL\`
\- \`KITCHEN\_OUTPUT\_SIGNAL\`
\- \`SUPPORT\_SIGNAL\`
\- \`RECONCILIATION\_SIGNAL\`

Examples:

\- Toss payment approved webhook: \`PAYMENT\_SIGNAL\`
\- PAYCO auth callback: \`OBSERVATION\_ONLY\` or \`PAYMENT\_AUTH\_SIGNAL\`, not final approval
\- OKPOS order registered response: \`ORDER\_SIGNAL\`
\- OKPOS kitchen print indication: \`KITCHEN\_OUTPUT\_SIGNAL\`, not Yoonsul KDS truth
\- PAYCO login callback: \`CUSTOMER\_IDENTITY\_SIGNAL\`, not payment
\- Smartro 60-second timeout: \`RECONCILIATION\_SIGNAL\` or \`RECOVERY\_SIGNAL\`

Authority class determines what runtime may consume the event.

\---

\#\# 11\. Confidence Level

Provider events should carry confidence level.

Recommended values:

\- \`VERIFIED\`
\- \`PARTIALLY\_VERIFIED\`
\- \`UNVERIFIED\`
\- \`PROVISIONAL\`
\- \`CONFLICTING\`
\- \`STALE\`
\- \`DUPLICATE\`
\- \`REPLAY\_SUSPECTED\`
\- \`LOCAL\_ACCEPTANCE\_UNCERTAIN\`

Examples:

\- Toss webhook with valid signature and known merchant: \`VERIFIED\`
\- PAYCO returnUrl before final approval: \`PARTIALLY\_VERIFIED\`
\- OKPOS local timeout after send: \`LOCAL\_ACCEPTANCE\_UNCERTAIN\`
\- duplicate webhook: \`DUPLICATE\`
\- event after stale timestamp: \`STALE\`

Confidence level must be visible to recovery and support runtime.

\---

\#\# 12\. Toss Mapping Policy

Toss provider input may include:

\- Open API response
\- payment approved webhook
\- payment cancelled webhook
\- order lookup
\- payment lookup
\- rate limit response
\- merchant mapping response

Canonical mapping examples:

| Toss Event | Canonical Mapping |
| \---------- | \----------------- |
| Valid payment approved webhook | PAYMENT\_PROVIDER\_APPROVED |
| Valid payment cancelled webhook | PAYMENT\_PROVIDER\_CANCELLED |
| Duplicate webhook id | PROVIDER\_EVENT\_DUPLICATE\_IGNORED |
| Invalid signature | PROVIDER\_EVENT\_REJECTED |
| Unknown merchantId | PROVIDER\_MERCHANT\_MAPPING\_FAILED |
| API 429 | PROVIDER\_RATE\_LIMITED |
| Order lookup success | ORDER\_PROVIDER\_OBSERVED |
| Order cancel success | ORDER\_PROVIDER\_CANCELLED\_SIGNAL |

Toss rules:

\- webhook signature required
\- timestamp check required
\- idempotency check required
\- merchant/store mapping required
\- payment approved event may trigger handoff candidate only after policy validation
\- order cancel must not be treated as financial refund unless verified

\---

\#\# 13\. OKPOS Mapping Policy

OKPOS provider input may include:

\- OKDC daemon response
\- OKDC DLL/interface result
\- local POS order registration result
\- local POS table state
\- local POS payment result where applicable
\- local timeout
\- local daemon health
\- kitchen output signal

Canonical mapping examples:

| OKPOS Signal | Canonical Mapping |
| \------------ | \----------------- |
| OKDC order accepted | ORDER\_PROVIDER\_ACCEPTED |
| OKDC order rejected | ORDER\_PROVIDER\_REJECTED |
| OKDC timeout | ORDER\_PROVIDER\_UNCERTAIN |
| Daemon unavailable | PROVIDER\_LOCAL\_DAEMON\_UNAVAILABLE |
| Unknown OKPOS store | PROVIDER\_MERCHANT\_MAPPING\_FAILED |
| Duplicate send blocked | PROVIDER\_EVENT\_DUPLICATE\_BLOCKED |
| Kitchen print detected | EXTERNAL\_KITCHEN\_OUTPUT\_SIGNAL |
| POS closed | PROVIDER\_POS\_NOT\_READY |

OKPOS rules:

\- local timeout is not failure or success
\- local daemon success is not automatic KDS truth
\- kitchen print is not Yoonsul KDS ticket
\- retry requires idempotency
\- pilot evidence required before production
\- local store/device mapping required

\---

\#\# 14\. PAYCO Mapping Policy

PAYCO provider input may include:

\- payment reservation response
\- payment UI return
\- auth callback
\- final approval response
\- payment cancellation response
\- PAYCO login callback
\- smart order channel signal

Canonical mapping examples:

| PAYCO Signal | Canonical Mapping |
| \------------ | \----------------- |
| Reservation created | PAYMENT\_RESERVATION\_CREATED |
| Auth callback received | PAYMENT\_AUTH\_CALLBACK\_RECEIVED |
| Final approval success | PAYMENT\_PROVIDER\_APPROVED |
| Final approval failure | PAYMENT\_PROVIDER\_FAILED |
| Login success | CUSTOMER\_IDENTITY\_PROVIDER\_SIGNAL |
| Smart Order print/signal | EXTERNAL\_OPERATIONAL\_CHANNEL\_SIGNAL |
| Cancellation response | PAYMENT\_PROVIDER\_CANCELLED\_OR\_REFUND\_REVIEW |

PAYCO rules:

\- reservation is not approval
\- auth callback is not approval
\- final approval is payment signal
\- login is not payment
\- smart order print is not backend truth
\- WebView return must be verified by backend

\---

\#\# 15\. Smartro Mapping Policy

Smartro is Phase 2, but mapping principles should be reserved.

Smartro provider input may include:

\- order agent response
\- STORE\_ID / SERVICE\_ID scoped event
\- prepaid order registration
\- postpaid table occupancy response
\- 5-second polling result
\- 60-second timeout discard
\- VCAT payment result

Canonical mapping examples:

| Smartro Signal | Canonical Mapping |
| \--------------- | \----------------- |
| New prepaid order accepted | ORDER\_PROVIDER\_ACCEPTED |
| Postpaid table occupied | TABLE\_CONTEXT\_OCCUPIED |
| Additional order accepted | ORDER\_PROVIDER\_ACCEPTED |
| 60-second timeout | ORDER\_PROVIDER\_UNCERTAIN\_OR\_REJECTED\_BY\_PROVIDER |
| Agent unavailable | PROVIDER\_LOCAL\_AGENT\_UNAVAILABLE |
| VCAT payment approved | PAYMENT\_PROVIDER\_APPROVED |

Smartro remains Phase 2\.

No implementation in Phase 1\.

\---

\#\# 16\. KICC / NICE Mapping Policy

KICC and NICE are Phase 2 payment/VAN candidates.

Potential canonical mappings:

\- AUTH\_RESULT\_RECEIVED
\- PAYMENT\_APPROVAL\_REQUESTED
\- PAYMENT\_PROVIDER\_APPROVED
\- PAYMENT\_PROVIDER\_FAILED
\- NET\_CANCEL\_REQUIRED
\- NET\_CANCEL\_REQUESTED
\- NET\_CANCEL\_APPROVED
\- PAYMENT\_RECONCILIATION\_REQUIRED
\- VAN\_TIMEOUT
\- FIREWALL\_OR\_NETWORK\_BLOCKED

Rules:

\- auth is not approval
\- approval timeout may require cancel/reversal
\- VAN TID must map to tenant/store/payment context
\- payment finality must be evidenced
\- network/firewall configuration must be release-gated

\---

\#\# 17\. Hyphen Mapping Policy

Hyphen may become an API hub in Phase 2 or Phase 3\.

Hyphen provider input should be mapped with extra caution because it may hide downstream provider details.

Canonical mapping must include:

\- hub provider id
\- downstream provider id where available
\- hub request id
\- downstream event id where available
\- provider visibility level
\- data freshness
\- failure source
\- hub confidence level

Rules:

\- API hub success is not necessarily downstream POS success unless verified
\- hidden downstream provider failure must create reconciliation review
\- hub abstraction must not erase provider-specific risk
\- Hyphen should not become first-phase dependency

\---

\#\# 18\. Event Quarantine Policy

Provider events must be quarantined when:

\- merchant/store mapping fails
\- signature validation fails
\- idempotency conflict exists
\- duplicate event conflicts with prior result
\- timestamp is stale
\- provider event type is unknown
\- local daemon timeout creates uncertainty
\- payment state conflicts with order state
\- KDS state conflicts with provider state
\- refund/cancel semantics are unclear
\- provider evidence is incomplete
\- sandbox/production mismatch occurs

Quarantined event must not mutate final runtime state.

It may create:

\- evidence packet
\- blocker
\- support review
\- reconciliation case
\- incident where needed

\---

\#\# 19\. Idempotency Mapping

Each provider adapter must define idempotency source.

Examples:

| Provider | Idempotency Source |
| \-------- | \------------------ |
| Toss | x-toss-webhook-id, event id, payment id, order id |
| OKPOS | OKDC request id, order id, store id, local sequence |
| PAYCO | reserve order no, payment cert token, approval id |
| Smartro | order request id, STORE\_ID, SERVICE\_ID, table/order sequence |
| KICC/NICE | tid, auth transaction id, approval id |
| Hyphen | hub request id and downstream id |

If provider idempotency source is not known, implementation is blocked.

\---

\#\# 20\. Canonical Event Evidence

Every canonical event candidate must link evidence.

Evidence should include:

\- source provider
\- provider architecture family
\- raw receipt metadata
\- validation result
\- idempotency result
\- tenant/store mapping result
\- source event id
\- provider order/payment id
\- confidence level
\- authority class
\- quarantine status
\- runtime routing decision
\- reviewer where manual

Evidence must not include:

\- provider secret
\- webhook secret
\- raw CI/DI
\- raw card data
\- unrestricted provider payload
\- local POS database credential
\- WebView cookie
\- service role key

\---

\#\# 21\. Runtime Routing Rule

Canonical event candidates may route to:

\- payment runtime
\- order runtime
\- POS/KDS bridge
\- recovery runtime
\- support runtime
\- audit runtime
\- settlement runtime
\- identity runtime
\- device trust runtime
\- export/AI runtime only after minimization and approval

Routing must follow authority class.

Examples:

\- \`PAYMENT\_PROVIDER\_APPROVED\` routes to payment runtime.
\- \`ORDER\_PROVIDER\_ACCEPTED\` routes to order runtime and possibly handoff candidate logic.
\- \`EXTERNAL\_KITCHEN\_OUTPUT\_SIGNAL\` routes to KDS/recovery review, not direct KDS ticket.
\- \`CUSTOMER\_IDENTITY\_PROVIDER\_SIGNAL\` routes to identity runtime, not payment runtime.
\- \`PROVIDER\_EVENT\_QUARANTINED\` routes to recovery/support/audit.

\---

\#\# 22\. Canonical Event Anti-Patterns

The following are prohibited:

\- mapping provider login success to payment approved
\- mapping payment reservation to payment approved
\- mapping auth callback to payment approved
\- mapping local daemon timeout to failure without review
\- mapping local daemon timeout to success without review
\- mapping kitchen print to KDS ticket
\- mapping order cancel to refund
\- mapping API hub success to downstream POS success without evidence
\- discarding provider-specific uncertainty
\- hiding duplicate conflict behind generic success
\- allowing provider event to bypass tenant/store mapping
\- allowing provider event to bypass audit
\- allowing provider event to bypass idempotency

\---

\#\# 23\. Provider Adapter Testing

Required future adapter tests:

1\. Unknown provider event is quarantined.
2\. Unknown merchant/store mapping is quarantined.
3\. Invalid cloud webhook signature is rejected.
4\. Duplicate webhook is ignored or linked.
5\. Conflicting duplicate creates reconciliation.
6\. Local daemon timeout creates uncertain state.
7\. Local daemon retry requires idempotency.
8\. Payment reservation does not map to payment approval.
9\. Auth callback does not map to payment approval.
10\. Final approval maps to payment approved.
11\. Kitchen print does not map to KDS ticket.
12\. Provider login does not map to member identity without policy.
13\. Order cancel does not map to refund.
14\. API hub result preserves downstream provider identity.
15\. Evidence packet is created for every canonical event candidate.
16\. Sensitive data is masked.
17\. Sandbox event cannot mutate production runtime.
18\. Provider adapter can be disabled.
19\. Quarantined event cannot create KDS ticket.
20\. Support review can inspect masked event context.

\---

\#\# 24\. Adapter Disable And Rollback

Each provider adapter must support disable/rollback.

Disable may be required when:

\- provider credentials leak
\- webhook validation fails
\- local daemon version mismatch appears
\- duplicate order risk appears
\- payment mapping is incorrect
\- KDS duplication occurs
\- sandbox/production mismatch occurs
\- provider outage occurs
\- support cannot resolve incidents
\- release gate fails

Disable must stop new provider events from mutating runtime while preserving evidence.

\---

\#\# 25\. Provider Adapter Status Values

Recommended adapter status values:

\- \`DOCUMENTED\_ONLY\`
\- \`OFFICIAL\_VERIFICATION\_PENDING\`
\- \`EVIDENCE\_READY\`
\- \`DESIGN\_READY\`
\- \`CONTROLLED\_IMPLEMENTATION\_AUTHORIZED\`
\- \`SANDBOX\_ENABLED\`
\- \`PILOT\_ENABLED\`
\- \`PRODUCTION\_ENABLED\`
\- \`DISABLED\`
\- \`SUSPENDED\`
\- \`DEPRECATED\`
\- \`REMOVED\`

First phase providers should not jump directly to production enabled.

\---

\#\# 26\. Non-Goals

This document does not define:

\- final canonical event schema
\- final event bus
\- final database table
\- final provider adapter code
\- final Toss adapter
\- final OKPOS adapter
\- final PAYCO adapter
\- final Smartro adapter
\- final Hyphen adapter
\- final admin UI
\- final support console

Those belong to later controlled implementation.

\---

\#\# 27\. Readiness Check

This document is ready when the project can answer:

1\. What is a provider adapter?
2\. What can a provider adapter do?
3\. What must a provider adapter never do?
4\. What is a canonical event?
5\. What are canonical event families?
6\. What ingestion stages are required?
7\. What provider adapter families exist?
8\. What dimensions must canonical mapping preserve?
9\. What is authority classification?
10\. What is confidence level?
11\. How does Toss map?
12\. How does OKPOS map?
13\. How does PAYCO map?
14\. How will Smartro map later?
15\. How will KICC/NICE map later?
16\. How will Hyphen map later?
17\. When is event quarantine required?
18\. How is idempotency mapped?
19\. What evidence is required?
20\. How does runtime routing work?
21\. What anti-patterns are prohibited?
22\. What tests are required?
23\. How is adapter disable handled?

If these questions cannot be answered, provider adapter and canonical event mapping planning is incomplete.

\---

\#\# 28\. Conclusion

Yoonsul must not let provider-specific events directly define internal runtime truth.

The correct pattern is:

    Provider Signal
        \-\> Provider Adapter
            \-\> Validation
            \-\> Tenant/Store Mapping
            \-\> Idempotency
            \-\> Evidence
            \-\> Canonical Event Candidate
            \-\> Runtime Routing
            \-\> Recovery or Handoff

This protects the project from provider lock-in and from unsafe assumptions.

The project must preserve the following rules:

\- provider event is input, not truth
\- provider adapter must validate before mapping
\- canonical event must preserve confidence and authority
\- Toss, OKPOS, PAYCO, Smartro, KICC, NICE, and Hyphen must not be flattened too early
\- local daemon uncertainty must remain visible
\- cloud webhook duplicate risk must remain visible
\- payment reservation is not approval
\- auth callback is not approval
\- local kitchen print is not KDS ticket
\- provider login is not Yoonsul identity
\- order cancel is not refund
\- evidence is mandatory
\- quarantined events must not mutate final runtime

This document prepares the provider adapter layer for future Toss-first, OKPOS-compatible, and multi-provider expansion without premature universal abstraction.
