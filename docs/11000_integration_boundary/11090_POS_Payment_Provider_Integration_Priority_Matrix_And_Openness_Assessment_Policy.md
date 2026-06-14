\# 05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy

Legacy path: $old.

\#\# 1\. Purpose

This document defines the provider integration priority matrix, openness assessment model, implementation cutline, vendor comparison rule, and provider selection policy for POS/payment/order integration in the Yoonsul Wait/Order Handoff project.

The previous documents covered:

\- Toss POS integration approach
\- PAYCO integration approach
\- official verification requirements
\- controlled implementation entry gate

This document compares POS/payment providers at a policy level so that future implementation does not treat every provider as equal.

Not every provider should be integrated with the same depth.

Some providers are suitable for first-class POS Open API integration.

Some providers are suitable only for payment integration.

Some providers are suitable only as external operational channels.

Some providers should remain deferred until official partner access is confirmed.

This document does not implement any provider integration.

It defines the selection and priority policy for future implementation.

\---

\#\# 2\. Scope

This document covers:

\- provider openness assessment
\- POS API readiness
\- payment API readiness
\- webhook/callback readiness
\- Android integration readiness
\- Windows POS readiness
\- smart order readiness
\- credential handling
\- merchant/store mapping
\- KDS handoff suitability
\- implementation priority
\- deferred scope rule
\- official verification requirement
\- Toss versus PAYCO positioning
\- provider onboarding decision rule

This document does not cover:

\- final API implementation
\- final SDK implementation
\- final Android app
\- final Windows POS integration
\- final payment gateway code
\- final webhook receiver
\- final database schema
\- final deployment pipeline

\---

\#\# 3\. Core Principle

Provider integration depth must follow openness, evidence, and runtime fit.

The project must follow this rule:

\> A provider that exposes clear server-to-server POS/payment APIs and signed webhook behavior may be treated as a first-class integration candidate. A provider that relies on installed programs, partner-only documents, WebView flows, or ambiguous callbacks must be integrated with narrower scope until verified.

Provider popularity is not enough.

Provider documentation, authority boundary, testability, and evidence are more important.

\---

\#\# 4\. Provider Integration Categories

Providers should be classified into one of the following categories.

\#\#\# 4.1 Category A: First-Class POS Open API Provider

A provider belongs here if it supports:

\- documented server-to-server Open API
\- merchant/store mapping
\- payment lookup
\- order lookup
\- signed webhook or verifiable callback
\- idempotency guidance
\- replay handling guidance
\- test merchant/sandbox flow
\- production credential process
\- clear rate limit guidance
\- external system integration posture

Recommended treatment:

\- candidate for early backend integration
\- candidate for POS/KDS handoff
\- candidate for payment state sync
\- candidate for controlled implementation after official verification

\#\#\# 4.2 Category B: Payment Gateway / Payment API Provider

A provider belongs here if it supports:

\- payment reservation
\- payment authentication
\- final approval
\- cancellation/refund API
\- callback/returnUrl
\- backend credential handling
\- settlement reporting

but does not clearly expose full POS order/store operational data.

Recommended treatment:

\- payment integration candidate
\- not a direct POS replacement
\- KDS handoff only after verified payment approval
\- smart order or POS-side program treated separately

\#\#\# 4.3 Category C: Operational Program / Smart Order Channel

A provider belongs here if it primarily uses:

\- Windows receiving program
\- owner portal
\- local printing
\- alarm/speaker notification
\- installed POS utility
\- store-side receiving application

Recommended treatment:

\- operational channel
\- not backend truth by default
\- direct ingestion deferred
\- official API or partner contract required before system integration

\#\#\# 4.4 Category D: Device / Hardware / VAN Specific Integration

A provider belongs here if integration depends on:

\- CAT terminal
\- barcode scanner
\- QR scanner
\- serial/USB communication
\- VAN terminal setup
\- model-specific certification
\- local hardware driver

Recommended treatment:

\- defer unless certified
\- isolate from SaaS backend
\- do not implement direct hardware control in early phase
\- require partner/vendor certification

\#\#\# 4.5 Category E: Deferred / Partner-Only Provider

A provider belongs here if:

\- official documents are unavailable
\- integration requires private partner approval
\- API behavior is unclear
\- cancellation/refund semantics are unclear
\- credentials cannot be safely scoped
\- sandbox is unavailable
\- tests cannot be written yet

Recommended treatment:

\- record as future candidate
\- do not implement
\- create official verification task

\---

\#\# 5\. Assessment Criteria

Each provider must be scored against these criteria.

| Criterion | Question |
| \--------- | \-------- |
| API Openness | Is server-to-server API publicly documented? |
| POS Data Access | Can order/payment/store data be accessed directly? |
| Webhook / Callback | Is real-time event delivery documented? |
| Signature / Security | Is webhook/callback verification documented? |
| Idempotency | Is duplicate/replay handling documented? |
| Merchant Mapping | Can provider merchant/store identity be mapped clearly? |
| Credential Model | Are credentials backend-safe and rotatable? |
| Sandbox | Is test merchant or sandbox available? |
| Android Support | Is Android flow documented? |
| Windows POS Support | Is Windows POS flow documented? |
| Hardware Dependency | Does it depend on certified local hardware? |
| Payment Boundary | Is reservation/auth/approval/refund clearly separated? |
| KDS Suitability | Can it safely trigger kitchen handoff after validation? |
| Auditability | Can events be recorded without secret exposure? |
| Release Gate Fit | Can automated tests and rollback gates be defined? |

\---

\#\# 6\. Openness Rating

Recommended provider openness rating:

\- \`OPEN\_POS\_API\`
\- \`OPEN\_PAYMENT\_API\`
\- \`PARTNER\_API\_REQUIRED\`
\- \`PROGRAM\_BASED\`
\- \`HARDWARE\_CERTIFICATION\_REQUIRED\`
\- \`DOCUMENTATION\_FRAGMENTED\`
\- \`UNKNOWN\`
\- \`DEFERRED\`

Meaning:

| Rating | Meaning |
| \------ | \------- |
| OPEN\_POS\_API | Suitable for first-class POS integration |
| OPEN\_PAYMENT\_API | Suitable for payment integration, not necessarily POS data |
| PARTNER\_API\_REQUIRED | Integration may be possible but requires partner access |
| PROGRAM\_BASED | Installed program is primary integration surface |
| HARDWARE\_CERTIFICATION\_REQUIRED | Requires terminal/device certification |
| DOCUMENTATION\_FRAGMENTED | Documents exist but are split or ambiguous |
| UNKNOWN | Not enough evidence |
| DEFERRED | Not selected for current phase |

\---

\#\# 7\. Current Provider Positioning

\#\#\# 7.1 Toss Place

Current positioning:

    Category A: First-Class POS Open API Provider

Provisional openness rating:

    OPEN\_POS\_API

Reason:

\- Open API posture is clearer.
\- Webhook behavior is more explicitly documented.
\- Merchant/app/test flow is more suitable for backend integration.
\- POS/payment event mapping appears more compatible with Yoonsul bridge design.

Implementation implication:

\- Toss should be treated as the first POS Open API integration candidate.
\- Backend-first Toss integration can be planned after official verification.
\- Apps in Toss / Android miniapp can remain later phase.

\---

\#\#\# 7.2 PAYCO

Current positioning:

    Category B \+ Category C

Provisional openness rating:

    OPEN\_PAYMENT\_API \+ PROGRAM\_BASED \+ DOCUMENTATION\_FRAGMENTED

Reason:

\- PAYCO payment and login integration resources exist.
\- Android SDK / WebView / PAYCO app bridge resources exist.
\- Smart Order Windows program exists as an operational receiving channel.
\- Direct POS data Open API equivalence to Toss is not yet proven.
\- Windows smart order and hardware lanes require extra partner verification.

Implementation implication:

\- PAYCO should be treated as payment/smart-order channel candidate.
\- PAYCO should not be treated as Toss-equivalent POS Open API until official partner evidence proves it.
\- Backend payment reservation/final approval lane may be considered.
\- Windows Smart Order direct ingestion should remain deferred.
\- Android PAYCO WebView should remain deferred unless customer payment UI is required.

\---

\#\# 8\. Provider Priority Matrix

Recommended initial matrix:

| Provider | Primary Use | Openness Rating | Initial Priority | MVP Scope |
| \-------- | \----------- | \--------------- | \---------------- | \--------- |
| Toss Place | POS Open API / payment event / webhook | OPEN\_POS\_API | Priority 1 | Backend integration candidate |
| PAYCO | Payment / smart order / login / Windows receiving channel | OPEN\_PAYMENT\_API \+ PROGRAM\_BASED | Priority 2 | Payment backend only, smart order external |
| Generic VAN / CAT terminal | Local payment device | HARDWARE\_CERTIFICATION\_REQUIRED | Deferred | No direct control |
| Delivery app providers | External order source | PARTNER\_API\_REQUIRED | Later | Order ingestion only after contract |
| Kiosk provider | Self-order channel | PARTNER\_API\_REQUIRED | Later | POS/KDS bridge candidate |
| Manual POS fallback | Human/manual input | INTERNAL\_CONTROLLED | MVP fallback | Evidence-based manual recovery |

This matrix may be revised after official verification.

\---

\#\# 9\. Integration Depth Levels

Provider integration should use depth levels.

\#\#\# Level 0: Documentation Only

\- Provider recorded.
\- No implementation.
\- Official verification pending.

\#\#\# Level 1: External Operational Channel

\- Provider used outside Yoonsul.
\- Store may operate provider program separately.
\- Yoonsul does not ingest data automatically.
\- Manual evidence may be recorded.

\#\#\# Level 2: Backend Payment Verification

\- Yoonsul backend calls payment API.
\- Payment approval is verified server-side.
\- KDS handoff may be triggered only after policy validation.

\#\#\# Level 3: Backend Order / Payment Sync

\- Provider sends or exposes order/payment data.
\- Yoonsul maps merchant/store/order/payment.
\- Idempotency and replay tests required.

\#\#\# Level 4: POS/KDS Handoff Integration

\- Provider event creates Yoonsul handoff candidate.
\- KDS ticket generated through bridge only.
\- Full audit/evidence required.

\#\#\# Level 5: Embedded Runtime / Miniapp / Device Integration

\- Provider UI or SDK runs inside app/tablet/POS.
\- Client authority boundary must be strict.
\- Backend remains source of payment truth.
\- Security and release gates required.

\#\#\# Level 6: Certified Hardware Integration

\- Direct device control.
\- VAN/CAT/certified terminal involvement.
\- Deferred until certified.

\---

\#\# 10\. Recommended Current Depth

| Provider | Current Recommended Depth |
| \-------- | \------------------------- |
| Toss Place | Level 3 first, Level 4 later |
| PAYCO | Level 2 first, Level 1 for Smart Order, Level 5 deferred |
| Windows Smart Order PAYCO | Level 1 only |
| PAYCO Android WebView | Level 5 deferred |
| PAYCO Hardware / KCP / CAT | Level 6 deferred |
| Manual fallback | Internal controlled fallback |
| Future delivery providers | Level 1 or Level 3 after partner contract |

\---

\#\# 11\. Provider Selection Rule

A provider may enter controlled implementation only if:

1\. Official documents are verified.
2\. API or callback behavior is clear.
3\. Credential handling is defined.
4\. Merchant/store mapping is defined.
5\. Payment/order/refund authority boundary is defined.
6\. Idempotency and replay handling are defined.
7\. Audit and evidence requirements are defined.
8\. Release gate impact is known.
9\. Rollback or disable path is defined.
10\. Runtime owner is assigned.

If any item is missing, provider implementation remains blocked or deferred.

\---

\#\# 12\. Toss Strategy

Toss strategy:

\- use as first POS Open API integration candidate
\- verify official Open API and webhook behavior
\- implement backend gateway before UI
\- validate merchant/store mapping
\- enforce webhook signature/idempotency/replay
\- handle rate limiting
\- map payment/order events to Yoonsul runtime
\- create KDS handoff candidate only after validation
\- defer Apps in Toss miniapp until backend is stable

Toss must still pass:

\- security tests
\- payment tests
\- POS/KDS tests
\- vendor tests
\- deployment tests

\---

\#\# 13\. PAYCO Strategy

PAYCO strategy:

\- use as second payment/smart-order candidate
\- do not assume Toss-equivalent POS data openness
\- verify payment API guide
\- implement backend payment reservation/final approval only if selected
\- keep Smart Order Windows program as external operational channel
\- defer direct Smart Order ingestion
\- defer Android WebView until payment UI is needed
\- defer direct hardware terminal control
\- separate login from payment
\- separate reservation/auth callback/final approval
\- separate cancellation from refund

PAYCO must pass:

\- payment boundary tests
\- callback/idempotency tests
\- credential handling tests
\- Android WebView safety tests where applicable
\- Windows Smart Order deferral evidence
\- deployment gate tests

\---

\#\# 14\. Do We Need More PAYCO Documents Now?

At this stage, no additional PAYCO implementation document is required.

05170 already captures:

\- PAYCO platform lanes
\- Windows Smart Order boundary
\- Android WebView boundary
\- PAYCO login boundary
\- backend payment flow
\- merchant/store mapping
\- credential handling
\- payment/KDS boundary
\- cancellation/refund boundary
\- deferred scope
\- blockers
\- required tests
\- production release blockers

Additional PAYCO documents should be created only after one of the following occurs:

\- official PAYCO payment API guide is reverified
\- PAYCO partner API access is granted
\- PAYCO backend payment implementation is selected
\- PAYCO Android payment UI becomes MVP scope
\- PAYCO Smart Order ingestion becomes required
\- PAYCO hardware terminal integration becomes required
\- PAYCO settlement automation becomes required

Until then, more PAYCO detail would be premature.

\---

\#\# 15\. Future PAYCO Document Candidates

If needed later, create these documents:

1\. PAYCO Official Payment API Verification Evidence Packet
2\. PAYCO Backend Payment Reservation Approval Design Policy
3\. PAYCO Android WebView Payment Boundary Policy
4\. PAYCO Smart Order Windows Operational Channel Policy
5\. PAYCO Cancellation Refund Settlement Reconciliation Policy
6\. PAYCO Merchant Store Mapping And Credential Storage Policy

These should not be written until official verification or implementation selection occurs.

\---

\#\# 16\. Risk Of Over-Documenting Providers

Provider documentation can become harmful if it assumes too much before official verification.

Risks:

\- treating unofficial notes as API truth
\- designing around obsolete SDK versions
\- overfitting to one provider
\- confusing login with payment
\- confusing smart order with POS data API
\- confusing order cancellation with refund
\- creating implementation pressure before partner approval
\- bloating documentation without executable value

Therefore, provider docs should stop at:

\- approach
\- verification checklist
\- blockers
\- cutline
\- integration depth
\- future document trigger

until official evidence exists.

\---

\#\# 17\. Recommended Provider Roadmap

Recommended roadmap:

\#\#\# Phase A: Provider Evaluation

\- Toss official verification
\- PAYCO official verification
\- openness matrix
\- priority decision

\#\#\# Phase B: Toss Backend Pilot

\- Toss merchant mapping
\- Toss webhook verification
\- Toss payment/order lookup
\- Toss POS/KDS handoff candidate

\#\#\# Phase C: PAYCO Backend Payment Review

\- PAYCO payment API verification
\- PAYCO reservation/approval boundary
\- PAYCO callback handling
\- PAYCO payment-only MVP decision

\#\#\# Phase D: Secondary Provider Expansion

\- delivery apps
\- kiosk provider
\- VAN/POS partner
\- PAYCO Smart Order if officially supported

\#\#\# Phase E: Embedded / Device Runtime

\- Apps in Toss
\- PAYCO Android WebView
\- local device metadata
\- certified terminal control

\---

\#\# 18\. Provider Acceptance Checklist

Before accepting any provider into implementation:

1\. Provider category assigned.
2\. Openness rating assigned.
3\. Official documents verified.
4\. Integration depth selected.
5\. MVP scope selected.
6\. Deferred scope recorded.
7\. Runtime owners assigned.
8\. Credential handling defined.
9\. Merchant/store mapping defined.
10\. Payment/refund boundary defined.
11\. Callback/webhook/idempotency defined.
12\. POS/KDS handoff rule defined.
13\. Evidence requirements defined.
14\. Blockers created.
15\. Release gate impact assigned.
16\. Rollback/disable path defined.
17\. Controlled implementation authorization prepared.

\---

\#\# 19\. Non-Goals

This document does not define:

\- final Toss implementation
\- final PAYCO implementation
\- final payment provider code
\- final SDK usage
\- final Windows POS integration
\- final Android WebView implementation
\- final merchant mapping schema
\- final KDS bridge code
\- final provider selection contract
\- final production release process

Those belong to later controlled implementation.

\---

\#\# 20\. Readiness Check

This document is ready when the project can answer:

1\. How are providers categorized?
2\. How is provider openness rated?
3\. Why is Toss currently Priority 1?
4\. Why is PAYCO currently Priority 2?
5\. Why is PAYCO not treated as Toss-equivalent POS Open API yet?
6\. What integration depth is recommended for Toss?
7\. What integration depth is recommended for PAYCO?
8\. When should PAYCO get more documents?
9\. Why is over-documenting provider details risky?
10\. What is the provider roadmap?
11\. What checklist must be completed before implementation?

If these questions cannot be answered, provider integration priority planning is incomplete.

\---

\#\# 21\. Conclusion

The project should not integrate providers equally.

Toss currently appears more suitable for first POS Open API integration.

PAYCO is valuable, but should be treated as a payment/smart-order channel until official partner evidence proves deeper POS data access.

Therefore:

\- Toss is Priority 1 for POS Open API style integration.
\- PAYCO is Priority 2 for payment/smart-order style integration.
\- PAYCO does not need more implementation documents now.
\- PAYCO needs official verification before deeper documents.
\- Provider integration depth must follow evidence, not assumptions.
\- No provider may bypass Yoonsul tenant/store, payment, audit, POS/KDS, vendor, AI, export, and deployment gates.

This document closes the first provider comparison step and prepares the project for later controlled provider selection.
