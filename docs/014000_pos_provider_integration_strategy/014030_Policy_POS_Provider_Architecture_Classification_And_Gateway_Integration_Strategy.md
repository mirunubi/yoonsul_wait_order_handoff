# 014030_Policy_POS_Provider_Architecture_Classification_And_Gateway_Integration_Strategy.md

## 1. Purpose

This document defines how Catch & Order should classify domestic POS providers by architecture type and decide the proper gateway integration strategy for each provider category.

This is a strategy policy document, not an implementation specification.

The source material is the domestic POS industry ecosystem analysis covering market structure, Windows legacy POS, Android/cloud-native POS, hardware manufacturers, VAN/PG-linked providers, and chronic POS industry limitations.

## 2. Core Decision

Catch & Order must not assume that all POS providers can be integrated through the same path.

The domestic POS market is structurally split into multiple provider types:

1. Windows local-client POS providers
2. Windows/Web ASP hybrid POS providers
3. Android/cloud-native POS providers
4. Mobile/tablet POS providers
5. Hardware-first POS/kiosk manufacturers
6. VAN/PG-linked settlement infrastructure providers
7. Franchise-specific customized POS deployments

The POS Gateway must classify each provider before integration planning.

## 3. Provider Architecture Classes

| Class | Provider Pattern | Typical Stack | Integration Risk | Catch & Order Strategy |
|---|---|---|---|---|
| A | Windows local-client legacy POS | Windows, local DB, DLL, serial/USB device control | High | Manual fallback, local evidence, strict reconciliation |
| B | Windows/Web ASP hybrid POS | Windows client + central ASP server | Medium-high | Gateway adapter + batch reconciliation |
| C | Android/cloud-native POS | Android app, cloud API, MSA backend | Medium | API-first integration, webhook/idempotency guard |
| D | Mobile/tablet POS | Android/iOS/Web dashboard | Medium | Lightweight API integration, owner workflow guard |
| E | Hardware-first manufacturer | POS/kiosk hardware + embedded drivers | High | Device boundary isolation, hardware failure fallback |
| F | VAN/PG-linked provider | Payment network, settlement, terminal distribution | Very high | Financial audit, credential isolation, payment boundary |
| G | Franchise custom deployment | Provider-specific branch customization | Very high | Store-by-store readiness matrix and controlled rollout |

## 4. Windows Local-Client POS Strategy

Windows local-client POS systems are high-risk integration targets because they often depend on local database state, device drivers, serial ports, DLLs, and field-maintained configurations.

Catch & Order must treat these providers as physically fragile systems.

Required controls:

- Never assume real-time API availability.
- Keep manual order and payment fallback.
- Record local handoff evidence.
- Require store-level integration test evidence.
- Separate accepted order state from POS-synced state.
- Do not mark a payment/order as final merely because the POS client accepted input.
- Add reconciliation between Catch & Order ledger, POS local records, and settlement/payment evidence.

## 5. Windows/Web ASP Hybrid Strategy

Hybrid systems may provide server-side dashboards or ASP-style data sync, but the store-side terminal may still depend on local state.

Gateway policy:

- Treat the provider as semi-online.
- Support delayed sync and replay.
- Require idempotency key per order/payment handoff.
- Store outbound handoff attempts.
- Store provider response payloads.
- Detect mismatch between server acceptance and store terminal visibility.
- Maintain staff confirmation flow until pilot stability is proven.

## 6. Android And Cloud-Native POS Strategy

Cloud-native POS providers are easier to integrate from an API perspective, but they introduce other risks:

- API policy can change quickly.
- Plugin or SDK model can shift without notice.
- Store owner workflow may depend on provider app UI.
- Cloud outage may affect many stores simultaneously.
- Reconciliation must still handle duplicate, delayed, or partial events.

Gateway policy:

- Prefer official Open API or SDK.
- Keep all integration behind provider-specific adapters.
- Do not couple Catch & Order domain state directly to provider SDK objects.
- Require webhook signature verification.
- Require replay protection.
- Maintain provider version registry.
- Keep provider outage fallback.

## 7. Hardware-First Provider Strategy

Hardware-first POS and kiosk providers may be strong in field durability but weak in open software integration.

Gateway policy:

- Treat hardware control as outside Catch & Order core.
- Do not depend on direct device-driver access.
- Use provider-approved interface only.
- Preserve manual fallback for printer, cash drawer, tablet, kiosk, and payment device failures.
- Record device failure as operational event, not only technical incident.
- Do not make the first MVP depend on custom hardware integration.

## 8. VAN/PG-Linked Provider Strategy

Providers tied to VAN, PG, settlement, and payment terminals carry financial-grade risk.

Catch & Order must apply stricter controls:

- Payment state must be separated from order state.
- Settlement state must be separated from customer-facing order completion.
- Provider credentials must be isolated.
- Webhook secrets must be rotated and scoped.
- All payment-related callbacks must be replay-protected.
- Refund, cancellation, correction, and settlement evidence must be retained.
- Manual correction must require audit trail.

## 9. Provider Classification Checklist

Before integration planning, classify each provider with this checklist:

| Check | Required Answer |
|---|---|
| Provider name | OKPOS, Toss Place, Payhere, KICC/EasyPos, KIS OKPOS, IMU POS, POSBANK, etc. |
| Provider class | A/B/C/D/E/F/G |
| Official API exists | Yes / No / Unknown |
| Webhook exists | Yes / No / Unknown |
| SDK/plugin exists | Yes / No / Unknown |
| POS local DB dependency | High / Medium / Low / Unknown |
| Payment terminal dependency | High / Medium / Low |
| KDS/printer dependency | High / Medium / Low |
| Store-side manual fallback needed | Yes / No |
| Provider certification required | Yes / No / Unknown |
| Pilot readiness | Blocked / Candidate / Approved |

## 10. Catch & Order Integration Tier

| Tier | Meaning | Allowed Scope |
|---|---|---|
| Tier 0 | No POS integration | Manual staff entry only |
| Tier 1 | Evidence-only integration | Export, print, dashboard reference |
| Tier 2 | Order handoff integration | Order candidate sent to POS/staff/POS bridge |
| Tier 3 | Payment-aware integration | Payment status observed, not necessarily executed |
| Tier 4 | Provider-certified API integration | Official API/webhook with reconciliation |
| Tier 5 | Deep franchise integration | Store/franchise contract, settlement, reporting, KDS, inventory hooks |

The MVP should not jump directly to Tier 5.

## 11. Gateway Adapter Boundary

Each provider must be integrated through an adapter boundary.

The adapter must own:

- provider credential
- provider endpoint
- request/response mapping
- retry policy
- timeout policy
- idempotency key mapping
- webhook verification
- provider error normalization
- provider version metadata
- provider-specific evidence capture

The core Catch & Order domain must not import provider-specific assumptions directly.

## 12. State Boundary

Catch & Order order/payment state must not collapse into provider state.

Required separation:

| Catch & Order State | Provider State | Rule |
|---|---|---|
| Order candidate created | Not sent | Customer/staff intent only |
| Handoff requested | Pending | Gateway has attempted transmission |
| Provider accepted | Accepted | Not final until business rule confirms |
| Staff confirmed | Confirmed | Store operational confirmation |
| POS synced | Synced | Provider-side evidence exists |
| Payment observed | Payment event received | Requires payment boundary |
| Reconciled | Matched | Ledger and provider evidence align |

## 13. Failure Modes To Assume

The POS Gateway must assume the following failures:

- provider API unavailable
- provider API exists but is not open to new partners
- provider documentation incomplete
- provider callback replay
- duplicated accepted order
- delayed cancellation
- refund mismatch
- POS terminal local DB corruption
- printer/KDS device offline
- store network unstable
- staff manually enters different order
- payment approved but order not visible
- order visible but payment not approved
- franchise-custom POS flow differs from provider default

## 14. Strategic Implication

The domestic POS industry is moving from fixed Windows POS toward cloud/mobile/softPOS models, but the transition is incomplete. Catch & Order should therefore be designed as an integration gateway and operational safety layer rather than a direct POS replacement.

The strategic advantage is not to support one provider deeply on day one.

The strategic advantage is to define a stable provider classification model, gateway boundary, evidence ledger, and fallback policy that allows integration depth to increase store by store and provider by provider.

## 15. Related Documents

- 14020_Report_Domestic_POS_Industry_Ecosystem_Market_Architecture_And_Limitations.md
- 14000_Readme_POS_Provider_Integration_Strategy.md
- 04000_Store_Runtime_POS_KDS_Operations
- 05000_Customer_Handoff_And_Implementation_Readiness
- 11000_Integration_Boundary
- 20000_Validation_Security_Audit

## 16. Non-Implementation Boundary

This document does not define:

- final provider contract terms
- final POS API schema
- final payment execution implementation
- final KDS implementation
- final certified integration package
- final provider priority ranking
- final store rollout schedule
- final settlement accounting logic

This document only defines classification, gateway strategy, and integration boundaries.
