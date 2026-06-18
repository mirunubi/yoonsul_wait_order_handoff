# 014050_Matrix_POS_Provider_Priority_Openness_Risk_And_MVP_Fit.md

## 1. Purpose

This matrix converts the domestic POS industry analysis into a provider prioritization framework for Catch & Order.

The goal is to decide which POS providers should be verified first, which should be deferred, and which should be handled through manual fallback or evidence-only integration during MVP.

This document does not approve implementation. It only provides a prioritization matrix.

## 2. Priority Principle

Catch & Order should not prioritize providers only by market share.

Provider priority must consider:

- market footprint
- official interface openness
- gateway integration feasibility
- payment and settlement risk
- store field complexity
- franchise relevance
- hardware/KDS dependency
- strategic value for future kiosk and franchise OS expansion

A large provider with closed integration may be lower priority than a smaller provider with stable official API access.

## 3. Provider Priority Classes

| Priority | Meaning | MVP Treatment |
|---|---|---|
| P0 | Mandatory field-awareness provider | Must be documented, but not necessarily integrated |
| P1 | First verification candidate | Official API/support must be verified first |
| P2 | Secondary candidate | Useful after first pilot evidence |
| P3 | Deferred or evidence-only candidate | Manual fallback or export-only during MVP |
| P4 | Archive/monitor only | Track market movement, no MVP integration |

## 4. Provider Matrix

| Provider / Brand | Likely Class | Market Relevance | Openness Risk | Field Risk | MVP Fit | Priority | Initial Strategy |
|---|---:|---:|---:|---:|---:|---:|---|
| OKPOS | A/B/F/G | Very high | High | Very high | Medium-low | P0 | Must understand; do not assume quick integration |
| KIS OKPOS | A/B/F/G | High | High | Very high | Medium-low | P0 | Treat as franchise/payment-linked custom environment |
| KICC EasyPos | A/B/F | High | High | High | Low-medium | P0 | Verify interface and legacy constraints |
| Toss Place | C/F | Very high growth | Medium | Medium | High if official path exists | P1 | Verify official API/plugin/webhook path |
| Payhere | C/D | Medium-high | Medium | Medium | High if official path exists | P1 | Verify API and multi-language/order linkage scope |
| PAYCO-related flow | F | High payment relevance | High | High | Medium | P1/P2 | Payment/provider openness verification first |
| POSBANK device environments | E | High hardware relevance | Medium-high | High | Low-medium | P2 | Treat as hardware boundary and device compatibility issue |
| IMU POS | A/E | Niche but important | Medium-high | High | P2/P3 | P2 | Evaluate hardware-integrated store cases |
| Local franchise POS vendor | G | Case-dependent | Unknown | Very high | P3 | P3 | Store-by-store manual fallback and evidence-only |
| Unknown small POS vendor | A/G | Low-medium | Unknown | Very high | Low | P3/P4 | No deep MVP integration without evidence |

## 5. Priority Explanation

### 5.1 OKPOS / KIS OKPOS / KICC EasyPos

These providers represent unavoidable field reality.

They should be classified as P0 because Catch & Order must understand them even if official integration is not immediately available.

Risk factors:

- Windows or hybrid local-client behavior
- strong VAN/payment network linkage
- local DB or terminal-side dependencies
- franchise-specific customization
- high market footprint
- field support dependency
- possible closed partner integration path

MVP strategy:

- Do not start by promising full integration.
- Start with evidence-only or manual fallback.
- Verify official API and provider approval route.
- Build reconciliation and fallback assumptions first.

### 5.2 Toss Place

Toss Place is a high-priority verification candidate because it represents the cloud-native smart POS direction and may support plugin/API-style integration.

Risk factors:

- policy dependency on official access
- SDK/plugin sandbox constraints
- fast-changing platform behavior
- payment and settlement boundary sensitivity

MVP strategy:

- Verify official integration docs and partner process.
- Treat as API-first only if official route is confirmed.
- Use adapter boundary and feature flags.
- Do not bind core Catch & Order state directly to Toss-specific objects.

### 5.3 Payhere

Payhere is a high-priority verification candidate because it aligns with mobile/tablet POS, owner dashboard, and multilingual commerce flows.

Risk factors:

- API openness must be confirmed
- store dashboard workflow may differ from provider backend capability
- migration or backend architecture transition risk
- payment and order data boundary must be verified

MVP strategy:

- Verify product/menu/order API availability.
- Verify multilingual data structure relevance.
- Start with order handoff or dashboard evidence before payment-aware integration.

### 5.4 PAYCO-Related Provider Flows

PAYCO-related flows should be treated as payment/provider boundary candidates rather than simple POS providers.

Risk factors:

- payment authority and settlement ambiguity
- provider contract limitations
- callback/replay/cancel/refund complexity
- consumer protection and financial audit implications

MVP strategy:

- Verify official access.
- Do not treat payment observation as payment execution.
- Require audit and reconciliation before Tier 3+.

### 5.5 Hardware-First Providers

POSBANK, IMU POS, and similar hardware-centered environments are important for field compatibility and future kiosk expansion, but they should not dominate MVP software integration.

Risk factors:

- device driver dependency
- printer/KDS/cash drawer issues
- firmware and OS compatibility
- local installation variance

MVP strategy:

- Treat hardware as external boundary.
- Do not depend on custom driver integration in early MVP.
- Capture device inventory and failure events.

## 6. MVP Provider Verification Order

Recommended initial order:

1. Toss Place
2. Payhere
3. PAYCO-related payment/provider flow
4. OKPOS / KIS OKPOS official path check
5. KICC EasyPos official path check
6. POSBANK/IMU hardware compatibility review
7. Local franchise POS vendor case-by-case

This is a verification order, not implementation order.

## 7. Integration Tier Recommendation By Provider Type

| Provider Type | Initial Tier | Maximum MVP Tier Without Official Contract |
|---|---:|---:|
| Windows legacy local POS | Tier 0-1 | Tier 2 with strict evidence only |
| Windows/Web hybrid POS | Tier 1 | Tier 2 |
| Cloud-native POS with official API | Tier 2 | Tier 4 if certified |
| Payment provider / VAN / PG linked | Tier 1 | Tier 3 only after audit validation |
| Hardware-first POS/kiosk | Tier 0-1 | Tier 2 only if provider-supported |
| Franchise custom POS | Tier 0 | Tier 1 until store evidence exists |

## 8. Provider Openness Verification Checklist

Before a provider can move from P0/P1 to implementation candidate, verify:

| Item | Required |
|---|---|
| Official API documentation | Yes |
| API access conditions | Yes |
| Partner approval path | Yes |
| Test account or sandbox | Yes |
| Webhook/callback security | Yes if callbacks exist |
| Rate limit / timeout policy | Required |
| Payment/refund/cancel scope | Required if payment-aware |
| Support escalation channel | Required |
| Store-level configuration requirement | Required |
| Contractual limitation | Required |

## 9. MVP Cutline

A provider should be excluded from deep MVP integration if any of the following are true:

- No official API or partner process is confirmed.
- Provider requires direct local DB manipulation.
- Payment status cannot be reconciled.
- Webhook/callback lacks signature or replay protection.
- Store manual fallback is not accepted.
- Provider certification timeline is unknown.
- Integration requires custom hardware driver work.
- Provider-specific customization would delay general gateway architecture.

## 10. Strategic Takeaway

Catch & Order's near-term advantage is not to integrate every POS provider.

The advantage is to:

- classify providers quickly
- avoid unsafe deep coupling
- preserve manual fallback
- capture evidence
- build provider adapters gradually
- separate order, payment, settlement, and staff confirmation states
- use verified provider access as the gate for deeper integration

This allows the system to support field reality without becoming trapped inside any single POS vendor's architecture.

## 11. Related Documents

- 14020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md
- 14030_Policy_POS_Provider_Architecture_Classification_And_Gateway_Integration_Strategy.md
- 14040_Checklist_POS_Gateway_Risk_Failure_Mode_And_Field_Readiness.md
- 14000_Readme_POS_Provider_Integration_Strategy.md
- 05000_Customer_Handoff_And_Implementation_Readiness
- 11000_Integration_Boundary
- 20000_Validation_Security_Audit
