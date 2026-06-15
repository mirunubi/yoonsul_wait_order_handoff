# 11100_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral

Legacy path: $old.

\#\# 1\. Purpose

This document defines the MVP provider cutline, Phase 2 POS expansion deferral rule, provider investigation boundary, and future POS API onboarding policy for the Yoonsul Wait/Order Handoff project.

The project is currently reviewing other POS providers such as OKPOS and other POS company APIs.

However, MVP implementation must remain narrow.

For MVP, only Toss and PAYCO are considered active provider candidates.

Other POS providers must be treated as Phase 2 expansion candidates unless explicitly reauthorized.

This document does not implement Toss, PAYCO, OKPOS, or any other POS provider integration.

It defines the provider scope boundary for MVP and later expansion.

\---

\#\# 2\. Scope

This document covers:

\- MVP provider cutline
\- Toss MVP role
\- PAYCO MVP role
\- OKPOS and other POS deferral
\- Phase 2 POS expansion policy
\- provider investigation rule
\- provider evidence collection rule
\- provider comparison rule
\- implementation block rule
\- official verification requirement
\- future POS onboarding checklist

This document does not cover:

\- final Toss implementation
\- final PAYCO implementation
\- final OKPOS implementation
\- final POS provider API client
\- final webhook receiver
\- final KDS bridge code
\- final payment integration code
\- final database schema
\- final production release

\---

\#\# 3\. Core Principle

MVP must not become a multi-provider integration project.

The project must follow this rule:

\> MVP provider scope is intentionally narrow. Toss and PAYCO may be prepared for MVP. Other POS providers are investigated and documented only, then deferred to Phase 2\.

Provider expansion is valuable, but premature expansion will increase risk, delay MVP, and weaken security/test discipline.

\---

\#\# 4\. MVP Provider Cutline

MVP provider scope:

| Provider | MVP Status | Role |
| \-------- | \---------- | \---- |
| Toss Place | Active MVP candidate | POS Open API / webhook / payment-order signal candidate |
| PAYCO | Active MVP candidate | Payment / smart-order channel candidate |
| OKPOS | Phase 2 candidate | Investigate only |
| Other POS providers | Phase 2 candidate | Investigate only |
| VAN / CAT terminal direct integration | Deferred | Hardware-certified lane |
| Delivery platform POS adapters | Deferred | Later partner integration |
| Kiosk provider APIs | Deferred | Later order source / POS bridge candidate |

MVP must not add new active providers beyond Toss and PAYCO without separate authorization.

\---

\#\# 5\. Toss MVP Role

Toss is treated as:

    MVP Priority 1 Provider

Primary reason:

\- better fit for POS Open API style integration
\- clearer server-to-server integration direction
\- webhook/payment/order mapping candidate
\- stronger fit with Yoonsul POS/KDS bridge policy

MVP Toss scope may include:

\- official Toss verification
\- merchant/store mapping design
\- webhook verification design
\- idempotency/replay design
\- payment/order lookup design
\- rate limit handling design
\- KDS handoff candidate design
\- evidence packet design
\- controlled implementation entry preparation

MVP Toss scope does not automatically include:

\- Apps in Toss miniapp
\- Android POS Plugin SDK runtime
\- production release
\- full payment settlement automation
\- direct device control

\---

\#\# 6\. PAYCO MVP Role

PAYCO is treated as:

    MVP Priority 2 Provider

Primary reason:

\- useful payment/smart-order ecosystem
\- backend payment reservation/approval possible after verification
\- PAYCO Smart Order may exist as external operational channel
\- Android/WebView payment lane may be useful later

MVP PAYCO scope may include:

\- official PAYCO verification
\- payment API guide review
\- payment reservation/final approval boundary
\- callback/idempotency planning
\- merchant/store mapping planning
\- credential handling planning
\- Smart Order external channel policy
\- deferred scope tracking

MVP PAYCO scope does not automatically include:

\- direct Windows Smart Order ingestion
\- direct PAYCO POS program modification
\- KCP/CAT terminal direct control
\- Android WebView payment UI implementation
\- PAYCO login-to-customer merge
\- CHECKOUT shipping callback
\- production payment release

\---

\#\# 7\. OKPOS And Other POS Provider Status

OKPOS and other POS company APIs are currently:

    INVESTIGATION\_ONLY

They are not MVP implementation scope.

Allowed activities:

\- collect official documentation
\- identify API availability
\- identify partner access requirement
\- identify webhook/callback availability
\- identify merchant/store mapping model
\- identify payment/order/refund scope
\- identify KDS handoff suitability
\- identify credential model
\- identify sandbox availability
\- identify production approval process
\- create Phase 2 candidate notes

Not allowed in MVP:

\- implementing OKPOS API client
\- implementing OKPOS webhook receiver
\- designing OKPOS database schema as active MVP schema
\- building provider-specific UI
\- adding production credentials
\- adding release gate for OKPOS production
\- treating OKPOS as equal MVP provider
\- expanding MVP POS/KDS bridge around OKPOS assumptions

\---

\#\# 8\. Phase 2 POS Expansion Rule

Phase 2 provider expansion may begin only after MVP foundation is stable.

Required before Phase 2 POS expansion:

1\. MVP Toss/PAYCO cutline completed or intentionally closed.
2\. POS/KDS bridge core boundary implemented or fully designed.
3\. Payment runtime boundary implemented or fully designed.
4\. Tenant/store mapping model stabilized.
5\. Vendor integration evidence pattern stabilized.
6\. Webhook/idempotency/replay pattern stabilized.
7\. Audit/evidence packet pattern stabilized.
8\. Deployment release gate pattern stabilized.
9\. Provider onboarding checklist stabilized.
10\. Phase 2 provider authorization created.

Phase 2 must not start by adding code directly.

It must start with provider verification and evidence.

\---

\#\# 9\. Provider Investigation Rule

Provider investigation is allowed during MVP.

Investigation may produce:

\- provider note
\- official source list
\- API availability summary
\- webhook/callback summary
\- credential summary
\- merchant/store mapping summary
\- sandbox/partner access summary
\- implementation risk note
\- Phase 2 priority score

Investigation must not produce:

\- implementation code
\- production credentials
\- runtime schema
\- active release gate
\- provider-specific hidden dependency
\- undocumented assumptions

Provider investigation must be stored separately from MVP implementation scope.

\---

\#\# 10\. Provider Investigation Template

Recommended template:

    Provider Name:
    Provider Category:
    Official Documentation:
    API Availability:
    Webhook / Callback:
    Payment Scope:
    Order Scope:
    Refund / Cancel Scope:
    Merchant / Store Mapping:
    Credential Model:
    Sandbox:
    Production Approval:
    POS/KDS Handoff Suitability:
    Hardware Dependency:
    Partner Access Required:
    Openness Rating:
    MVP Status:
    Phase 2 Status:
    Key Risks:
    Next Action:

Example status:

    MVP Status: DEFERRED
    Phase 2 Status: CANDIDATE

\---

\#\# 11\. Phase 2 Provider Categories

Other POS providers should be classified into one of the following:

\- \`PHASE2\_POS\_OPEN\_API\_CANDIDATE\`
\- \`PHASE2\_PAYMENT\_ONLY\_CANDIDATE\`
\- \`PHASE2\_SMART\_ORDER\_CHANNEL\`
\- \`PHASE2\_HARDWARE\_CERTIFIED\_ONLY\`
\- \`PHASE2\_PARTNER\_ACCESS\_REQUIRED\`
\- \`PHASE2\_DOCUMENTATION\_ONLY\`
\- \`PHASE2\_NOT\_RECOMMENDED\`

This classification must be evidence-based.

\---

\#\# 12\. Phase 2 Provider Priority Criteria

Phase 2 POS providers should be prioritized by:

1\. API openness
2\. webhook/callback clarity
3\. idempotency support
4\. merchant/store mapping clarity
5\. payment/order/refund boundary clarity
6\. sandbox availability
7\. partner approval difficulty
8\. hardware dependency
9\. KDS handoff suitability
10\. audit/evidence compatibility
11\. implementation effort
12\. market relevance
13\. franchise scalability
14\. fallback compatibility

A widely used provider is not automatically a high-priority provider.

Integration fit matters more than popularity.

\---

\#\# 13\. MVP Anti-Scope-Creep Rule

The following are scope creep during MVP:

\- adding OKPOS implementation because documentation was found
\- adding another POS provider before Toss/PAYCO decision
\- designing universal POS adapter before MVP proof
\- implementing provider abstraction too early
\- adding hardware terminal direct control
\- building many provider-specific payment flows at once
\- adding provider comparison into runtime code
\- adding settlement automation for multiple providers
\- making KDS bridge dependent on one provider-specific model

If these appear, implementation must pause and return to provider cutline.

\---

\#\# 14\. Universal Adapter Warning

A universal POS/payment adapter should not be built too early.

Reason:

\- provider semantics differ
\- cancellation/refund rules differ
\- webhook/callback behavior differs
\- payment/order identity differs
\- merchant/store mapping differs
\- sandbox/production behavior differs
\- hardware dependencies differ
\- partner access differs

Recommended approach:

1\. Build internal Yoonsul runtime boundaries first.
2\. Integrate one provider through controlled gateway.
3\. Extract common patterns only after evidence.
4\. Add second provider carefully.
5\. Create provider abstraction after at least two verified implementations.

Therefore, MVP should not overdesign a universal adapter.

\---

\#\# 15\. Yoonsul Internal Boundary First Rule

Provider integration must not define Yoonsul architecture.

Yoonsul must define:

\- tenant/store context
\- order handoff state
\- payment state
\- KDS ticket boundary
\- audit event model
\- evidence packet model
\- support review state
\- degraded recovery state
\- provider event quarantine state

Providers map into Yoonsul.

Yoonsul does not reshape itself around one provider.

\---

\#\# 16\. MVP Implementation Recommendation

Recommended MVP integration sequence:

\#\#\# Step 1: Internal Runtime Spine

\- tenant/store mapping
\- audit/evidence
\- POS/KDS bridge boundary
\- payment state model
\- support review
\- provider event quarantine

\#\#\# Step 2: Toss Backend Candidate

\- official Toss verification
\- merchant mapping
\- webhook validation
\- idempotency/replay
\- payment/order lookup
\- KDS handoff candidate

\#\#\# Step 3: PAYCO Backend Review

\- official PAYCO verification
\- reservation/approval boundary
\- callback handling
\- credential handling
\- Smart Order deferral

\#\#\# Step 4: Provider Comparison Freeze

\- Toss/PAYCO MVP decision
\- OKPOS/others Phase 2 register
\- no additional MVP provider

\#\#\# Step 5: Phase 2 Preparation

\- provider investigation notes
\- partner outreach
\- official documentation collection
\- API availability scoring

\---

\#\# 17\. Phase 2 POS Expansion Candidate Register

Recommended candidate register fields:

\- provider id
\- provider name
\- provider category
\- official source status
\- API status
\- webhook status
\- payment scope
\- order scope
\- refund/cancel scope
\- merchant mapping status
\- sandbox status
\- partner access status
\- hardware dependency
\- openness rating
\- priority score
\- target phase
\- owner
\- current status
\- notes

Status values:

\- \`NOT\_STARTED\`
\- \`UNDER\_REVIEW\`
\- \`OFFICIAL\_DOC\_FOUND\`
\- \`PARTNER\_CONTACT\_REQUIRED\`
\- \`API\_CONFIRMED\`
\- \`API\_NOT\_CONFIRMED\`
\- \`SANDBOX\_REQUIRED\`
\- \`DEFERRED\`
\- \`CANDIDATE\`
\- \`NOT\_RECOMMENDED\`

\---

\#\# 18\. Provider Evidence Requirement

Every Phase 2 provider candidate must have evidence before implementation.

Evidence must include:

\- official documentation link
\- accessed date
\- verified API claims
\- verified credential claims
\- verified webhook/callback claims
\- verified payment/order/refund claims
\- verified merchant/store mapping claims
\- sandbox or partner access note
\- reviewer
\- blocker list
\- implementation recommendation

No provider may enter implementation based only on sales material or hearsay.

\---

\#\# 19\. OKPOS Handling

OKPOS should be handled as:

    PHASE2\_POS\_PROVIDER\_CANDIDATE

Current MVP status:

    DEFERRED

Allowed now:

\- collect official OKPOS API documents
\- identify whether open API exists
\- identify partner access requirement
\- identify payment/order integration model
\- identify KDS or kitchen integration possibility
\- identify franchise scalability value
\- record candidate evidence

Not allowed now:

\- implement OKPOS adapter
\- implement OKPOS webhook/callback
\- design MVP around OKPOS
\- delay Toss/PAYCO MVP for OKPOS
\- assume OKPOS API behavior without official evidence

\---

\#\# 20\. Provider Expansion Blockers

Create blockers when:

\- provider API is not officially verified
\- provider webhook/callback is unclear
\- merchant/store mapping is unclear
\- cancellation/refund semantics are unclear
\- sandbox is unavailable
\- credentials cannot be scoped
\- provider requires hardware certification
\- provider requires private partner contract
\- provider documentation is outdated
\- provider data cannot be audited safely
\- provider cannot support idempotency/replay

These blockers do not block MVP unless the provider is selected for MVP.

\---

\#\# 21\. MVP Release Gate Impact

Toss and PAYCO may affect MVP release gate.

OKPOS and other POS providers should not affect MVP release gate if they are deferred.

Rule:

\> A deferred provider must not block MVP release unless the MVP accidentally depends on it.

Therefore:

\- Toss blockers may block MVP if Toss is selected.
\- PAYCO blockers may block MVP if PAYCO is selected.
\- OKPOS blockers do not block MVP while OKPOS is deferred.
\- Other POS provider blockers do not block MVP while deferred.
\- Deferred provider features must not be enabled in MVP.

\---

\#\# 22\. Future Document Triggers

Create additional documents only when triggered.

\#\#\# Trigger A: OKPOS Official API Verified

Create:

    OKPOS Official Verification Checklist And Integration Evidence Policy

\#\#\# Trigger B: OKPOS Selected For Phase 2

Create:

    OKPOS POS Integration Implementation Approach And Test Mapping Policy

\#\#\# Trigger C: Multiple POS Providers Selected

Create:

    Multi POS Provider Adapter Boundary And Normalization Policy

\#\#\# Trigger D: Provider Abstraction Needed

Create:

    Provider Event Canonicalization And Runtime Mapping Policy

\#\#\# Trigger E: Hardware Integration Needed

Create:

    Certified POS Hardware Terminal Integration Boundary Policy

No trigger, no extra provider-specific document.

\---

\#\# 23\. Non-Goals

This document does not define:

\- OKPOS implementation
\- other POS implementation
\- universal POS adapter
\- provider normalization schema
\- hardware terminal integration
\- partner contract process
\- production provider onboarding
\- final franchise provider strategy

Those belong to later phases.

\---

\#\# 24\. Readiness Check

This document is ready when the project can answer:

1\. Which providers are active in MVP?
2\. Which providers are deferred to Phase 2?
3\. Why are Toss and PAYCO the only MVP provider candidates?
4\. What is the role of OKPOS during MVP?
5\. What is allowed during provider investigation?
6\. What is prohibited during MVP scope?
7\. Why should universal adapter not be built too early?
8\. How are Phase 2 providers classified?
9\. What evidence is required for provider expansion?
10\. What blocks provider implementation?
11\. Do OKPOS blockers affect MVP release?
12\. When should OKPOS-specific documents be created?
13\. When should multi-provider abstraction documents be created?

If these questions cannot be answered, MVP provider cutline is incomplete.

\---

\#\# 25\. Conclusion

The MVP provider scope is intentionally narrow.

For MVP:

\- Toss remains the Priority 1 POS Open API candidate.
\- PAYCO remains the Priority 2 payment/smart-order candidate.
\- OKPOS and other POS providers remain Phase 2 candidates.
\- Provider investigation may continue.
\- Provider implementation must not expand beyond Toss/PAYCO during MVP.
\- Universal POS adapter must not be built prematurely.
\- Yoonsul internal runtime boundaries must come before provider abstraction.
\- Deferred providers must not block MVP release unless accidentally enabled.

This document protects MVP from provider scope creep while preserving a clear path for Phase 2 POS expansion.
