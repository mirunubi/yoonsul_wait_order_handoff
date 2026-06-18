# 005281_Policy_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison

## 1. Purpose

This document defines the architectural comparison policy between cloud Open API providers and local daemon / agent based POS providers for the Yoonsul Wait/Order Handoff project.

The previous documents established that:

- Toss is the primary base provider direction.
- OKPOS is the required compatibility interface.
- PAYCO remains a secondary payment / smart-order channel.
- Smartro, KICC, NICE, I'M U, Hyphen, minor POS vendors, and dealer networks are Phase 2 or Phase 3 candidates.
- Mini Kiosk and Kiosk must remain provider-neutral.

This document compares the two most important provider architecture families:

1. Cloud Open API / webhook provider model
2. Local daemon / agent POS-connected provider model

This document does not implement provider integration.

It defines architectural implications, risk boundaries, recovery patterns, test needs, and module decisions.

---

## 2. Scope

This document covers:

- cloud Open API provider architecture
- local daemon / agent provider architecture
- Toss-style integration
- OKPOS-style integration
- Smartro-style integration
- KICC/NICE payment-adjacent implications
- Mini Kiosk and Kiosk impact
- POS/KDS handoff impact
- payment verification impact
- timeout and recovery impact
- evidence requirement
- adapter boundary
- phase planning

This document does not cover:

- actual Toss implementation
- actual OKPOS implementation
- actual Smartro implementation
- actual KICC implementation
- actual NICE implementation
- actual PAYCO implementation
- actual daemon code
- actual webhook receiver code
- actual database schema
- actual kiosk code
- actual payment code

---

## 3. Core Principle

Provider architecture determines failure mode.

The project must follow this rule:

> Cloud Open API providers fail mainly through API, webhook, rate limit, credential, and replay risks. Local daemon providers fail mainly through POS PC, daemon, local network, timeout, version, dealer setup, and local state risks.

The Yoonsul runtime must support both, but must not confuse them.

---

## 4. Architecture Family A: Cloud Open API Provider

Cloud Open API providers expose remote API endpoints and usually support backend server-to-server integration.

Examples:

- Toss Place
- I'M U / UP POS where cloud API is officially verified
- Hyphen as an API hub if adopted later
- some modern payment/POS platforms

Typical traits:

- REST API
- JSON payload
- backend authentication keys
- webhook or callback
- cloud merchant/store mapping
- API rate limiting
- sandbox or test environment
- less dependence on local POS PC
- easier SaaS integration
- clearer deployment automation

---

## 5. Architecture Family B: Local Daemon / Agent Provider

Local daemon / agent providers depend on software running near the store POS environment.

Examples:

- OKPOS OKDC
- Smartro Order Agent
- some table order POS integrations
- some VAN/dealer-installed POS bridges
- local Windows POS program integrations

Typical traits:

- local process or daemon
- DLL or SDK interface
- local socket or local network communication
- POS PC dependency
- store network dependency
- dealer installation
- version compatibility
- table/order local state dependency
- kitchen printer or local output interaction
- pilot/certification process
- complex support boundary

---

## 6. Comparison Summary

| Area | Cloud Open API | Local Daemon / Agent |
| ---- | -------------- | -------------------- |
| Main Example | Toss | OKPOS / Smartro |
| Location | Cloud / provider API | Store-local POS environment |
| Integration Style | Server-to-server | Local process / daemon / DLL / socket |
| Failure Mode | API failure, webhook replay, rate limit | POS PC down, daemon down, LAN issue, timeout |
| Credential Risk | API key / webhook secret | partner key, local config, daemon secret |
| Kiosk Fit | backend-first | compatibility with installed POS |
| Market Fit | new cloud-friendly stores | existing POS-installed stores |
| Deployment Risk | API version / endpoint / credentials | dealer setup / local installation / version |
| Evidence | API logs, webhook evidence | local daemon logs, pilot evidence |
| Recovery | lookup, replay, quarantine | timeout review, local lookup, staff/dealer support |
| Scaling | SaaS-friendly | support-heavy |
| Franchise Fit | good for new standardized rollout | good for existing store conversion |
| Complexity | lower local ops, higher API security | higher local ops, higher support burden |

---

## 7. Cloud Open API Strengths

Cloud Open API providers are strong because:

- integration can be centralized
- backend can validate payment/order events
- webhook and API logs are easier to audit
- rate limiting can be managed centrally
- tenant/store mapping can be controlled centrally
- release gate can be automated more easily
- Mini Kiosk can remain thin
- store device failure is less likely to corrupt provider data
- SaaS rollout is easier
- provider adapter can be deployed centrally

Cloud Open API is better aligned with Yoonsul SaaS architecture.

---

## 8. Cloud Open API Risks

Cloud Open API providers still have risks:

- API key leakage
- webhook secret leakage
- webhook replay
- duplicate webhook delivery
- rate limit errors
- stale event processing
- provider outage
- merchant mapping error
- callback spoofing
- production/sandbox confusion
- vendor API version change
- overdependence on one provider

Required controls:

- backend-only secrets
- signature verification
- idempotency
- replay protection
- rate limit pacer
- merchant/store mapping
- event quarantine
- audit/evidence
- rollback/disable path

---

## 9. Local Daemon Strengths

Local daemon / agent providers are strong because:

- they fit existing store POS infrastructure
- they can integrate with local kitchen printers
- they may support table state and local order context
- they can work with installed POS dealer ecosystems
- they may be accepted by stores that already use legacy POS
- they support practical existing-store conversion
- they may be required for OKPOS-installed stores

Local daemon integration is important for market coverage.

---

## 10. Local Daemon Risks

Local daemon / agent providers have heavier operational risks:

- daemon not running
- POS PC turned off
- POS business state closed
- local network failure
- firewall/security software blocking communication
- DLL version mismatch
- local socket failure
- order send timeout
- response lost
- duplicate order registration
- kitchen printer duplication
- dealer misconfiguration
- local database corruption risk
- unknown support ownership
- pilot certification delay
- store-specific setup variance

Required controls:

- daemon health check
- local timeout handling
- idempotency key
- retry guard
- local failure evidence
- staff review state
- provider/dealer escalation
- rollback/disable path
- pilot evidence
- version compatibility tracking

---

## 11. Mini Kiosk Impact

Mini Kiosk must hide provider differences from customer UI.

For cloud providers:

    Mini Kiosk -> Yoonsul Backend -> Cloud Provider Adapter

For local daemon providers:

    Mini Kiosk -> Yoonsul Backend -> Local Provider Gateway -> Local Daemon / POS

Mini Kiosk must not connect directly to local daemon.

Rules:

- customer UI must not know whether provider is cloud or local daemon
- payment state must come from backend
- local timeout must become customer-safe message
- provider failure must become recovery state
- duplicate tap must not duplicate provider request
- KDS ticket must not be created directly by Mini Kiosk

---

## 12. Full Kiosk Impact

Full Kiosk may run closer to store hardware, but boundaries still apply.

For cloud providers:

- kiosk can show provider UI
- backend verifies result
- provider adapter handles cloud API

For local daemon providers:

- kiosk may be physically near POS
- local network may be involved
- dealer setup may be required
- hardware/printer output may be involved

Rules:

- full kiosk must not become daemon owner unless explicitly designed
- local printer output is not backend truth
- local daemon success is not automatically KDS truth
- payment terminal result must be verified
- kiosk must support staff recovery

---

## 13. POS/KDS Handoff Impact

Cloud Open API handoff:

- provider event arrives
- backend validates event
- payment/order state is mapped
- handoff candidate is created
- KDS bridge performs idempotency
- KDS ticket is created

Local daemon handoff:

- order may be sent to local POS
- local POS may create kitchen output
- local response may be delayed
- KDS output path may be ambiguous
- Yoonsul must prevent double kitchen execution

Important distinction:

> Cloud event duplication risks duplicate handoff. Local daemon order registration risks duplicate POS/kitchen output.

Both need idempotency, but the failure surfaces differ.

---

## 14. Payment Boundary Impact

Cloud Open API providers:

- payment approval may arrive through webhook or lookup
- backend verifies signature/callback
- payment state can be centrally controlled

Local daemon providers:

- payment may be local POS/VAN mediated
- approval may depend on terminal/POS state
- refund/cancel may be local operation
- payment evidence may be fragmented

Rules:

- local POS payment success must be mapped to Yoonsul payment state
- local order success must not be treated as payment success unless verified
- refund and cancellation must remain separate
- payment uncertain state must exist for both architectures

---

## 15. Timeout Pattern Difference

Cloud Open API timeout:

- API request may timeout
- webhook may arrive later
- provider lookup may resolve uncertainty
- idempotent retry may be possible
- rate limit may require delayed retry

Local daemon timeout:

- daemon may have accepted request but response lost
- POS may have printed order but Yoonsul does not know
- POS may have rejected after timeout
- retry may duplicate local order
- staff/dealer review may be needed

Policy:

    Cloud timeout prefers provider lookup.
    Local daemon timeout prefers idempotency check, local lookup, and staff review.

---

## 16. Recovery Pattern Difference

Cloud recovery states:

- WEBHOOK_DELAYED
- WEBHOOK_DUPLICATE_IGNORED
- PROVIDER_LOOKUP_REQUIRED
- API_RATE_LIMITED
- PAYMENT_RECONCILIATION_REQUIRED
- EVENT_QUARANTINED

Local daemon recovery states:

- DAEMON_UNAVAILABLE
- LOCAL_POS_UNREACHABLE
- LOCAL_TIMEOUT
- LOCAL_ACCEPTANCE_UNCERTAIN
- LOCAL_ORDER_DUPLICATE_RISK
- LOCAL_KITCHEN_OUTPUT_CONFLICT
- DEALER_SUPPORT_REQUIRED

Both must map into common Yoonsul recovery states.

---

## 17. Evidence Difference

Cloud evidence should include:

- API request id
- webhook id
- provider event id
- signature verification result
- merchant/store mapping
- rate limit headers
- idempotency key
- provider lookup result
- audit event id

Local daemon evidence should include:

- daemon version
- POS terminal/store id
- local request id
- local response id
- timeout timestamp
- daemon health status
- POS business state
- local retry attempt
- duplicate prevention result
- pilot test reference
- dealer/support reference
- audit event id

Evidence schemas must support both.

---

## 18. Provider Adapter Design Implication

Provider adapter should not assume one architecture.

Recommended adapter families:

- `CloudOpenApiProviderAdapter`
- `LocalDaemonProviderAdapter`
- `PaymentGatewayProviderAdapter`
- `ApiHubProviderAdapter`
- `HardwareCertifiedProviderAdapter`

These names are conceptual only.

The actual implementation can be different later.

But the conceptual separation is important.

---

## 19. Toss Mapping

Toss belongs primarily to:

    Cloud Open API Provider

Toss adapter should emphasize:

- Open API authentication
- webhook signature
- webhook idempotency
- payment/order lookup
- rate limiting
- merchant mapping
- event quarantine
- backend handoff candidate

---

## 20. OKPOS Mapping

OKPOS belongs primarily to:

    Local Daemon / Agent Provider

OKPOS adapter should emphasize:

- OKDC partner verification
- OKDC daemon boundary
- DLL/interface verification
- local POS state
- order registration
- timeout uncertainty
- kitchen output conflict
- pilot evidence

---

## 21. Smartro Mapping

Smartro belongs primarily to:

    Local Agent / Timeout-Strict Provider

Smartro adapter should later emphasize:

- STORE_ID / SERVICE_ID
- prepaid / postpaid order mode
- 5-second polling
- 60-second timeout discard
- table occupancy
- VCAT payment flow
- local retry and failure messaging

Smartro is Phase 2.

---

## 22. KICC Mapping

KICC belongs primarily to:

    VAN / Payment API Provider

KICC adapter should later emphasize:

- offline VAN TID
- auth / approval separation
- net-cancel rule
- 30-second timeout discipline
- payment rollback
- Android POS options
- kitchen/staff call options where applicable

KICC is Phase 2.

---

## 23. Hyphen Mapping

Hyphen belongs primarily to:

    API Hub / Marketplace Provider

Hyphen adapter should later emphasize:

- unified API benefits
- hidden provider complexity
- provider visibility loss
- hub outage risk
- indirect debugging
- data ownership
- cost
- fallback path

Hyphen is Phase 2 study / Phase 3 candidate.

---

## 24. Testing Implications

Cloud providers require tests for:

- valid signature
- invalid signature
- duplicate webhook
- replay attack
- rate limit
- unknown merchant
- cross-tenant mapping
- delayed webhook
- provider lookup
- event quarantine

Local daemon providers require tests for:

- daemon unavailable
- POS PC unavailable
- local timeout
- response lost
- duplicate send
- version mismatch
- local order accepted but backend uncertain
- kitchen output duplicate
- POS business closed
- local retry blocked
- staff review

The two test families must not be merged too early.

---

## 25. Deployment Implications

Cloud provider deployment requires:

- API credential setup
- webhook endpoint registration
- secret rotation
- rate limit monitoring
- environment separation
- rollback/disable switch

Local daemon deployment requires:

- store installation
- daemon version tracking
- POS compatibility check
- dealer support
- local network check
- pilot validation
- support runbook
- rollback/disable switch

Deployment gate must know which provider family is being deployed.

---

## 26. Support Implications

Cloud provider support usually asks:

- did webhook arrive?
- was signature valid?
- did API lookup succeed?
- was rate limit exceeded?
- is merchant mapping correct?
- is provider outage occurring?

Local daemon support usually asks:

- is POS PC on?
- is daemon running?
- is POS open for business?
- is local network working?
- did printer output occur?
- did daemon timeout?
- did dealer configure correctly?
- is version compatible?

Support scripts must differ by provider family.

---

## 27. Strategic Implication

Yoonsul should be Toss-first because cloud Open API better matches SaaS.

Yoonsul must still be OKPOS-compatible because local daemon POS dominates many existing stores.

Therefore:

- first clean architecture reference should be Toss
- first compatibility architecture reference should be OKPOS
- provider-neutral runtime must support both
- universal adapter must wait until both are understood
- Mini Kiosk must not hardcode either architecture

---

## 28. Anti-Patterns

The following are prohibited:

- treating local daemon as if it were a cloud API
- treating cloud webhook as if it were local POS acceptance
- retrying local daemon requests like cloud API calls
- treating local printer output as backend truth
- treating API success as KDS ticket without bridge
- hiding provider family differences under premature abstraction
- using one timeout model for all providers
- using one support script for all providers
- making Mini Kiosk depend on OKDC directly
- making Mini Kiosk depend on Toss directly without backend verification

---

## 29. Non-Goals

This document does not define:

- final provider adapter interface
- final Toss gateway
- final OKPOS gateway
- final Smartro gateway
- final KICC gateway
- final Hyphen gateway
- final daemon deployment script
- final webhook handler
- final support console
- final evidence database

Those belong to later controlled implementation.

---

## 30. Readiness Check

This document is ready when the project can answer:

1. What is a cloud Open API provider?
2. What is a local daemon / agent provider?
3. Why do their failure modes differ?
4. Why is Toss cloud-first?
5. Why is OKPOS local-daemon-first?
6. How does this affect Mini Kiosk?
7. How does this affect full Kiosk?
8. How does this affect POS/KDS handoff?
9. How does this affect payment boundary?
10. How does timeout handling differ?
11. How does recovery differ?
12. How does evidence differ?
13. What adapter families are implied?
14. What tests are required for cloud providers?
15. What tests are required for local daemon providers?
16. How does deployment differ?
17. How does support differ?
18. What anti-patterns are prohibited?

If these questions cannot be answered, cloud versus local provider architecture comparison is incomplete.

---

## 31. Conclusion

Cloud Open API providers and local daemon providers must be treated as different architecture families.

Toss represents the cloud Open API / webhook family.

OKPOS represents the local daemon / incumbent POS compatibility family.

Smartro, KICC, NICE, PAYCO, I'M U, Hyphen, and minor POS providers should be classified by this model before integration.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

- Toss is the strategic base because cloud API fits SaaS
- OKPOS compatibility is mandatory because market coverage requires it
- local daemon failure is not the same as cloud API failure
- local timeout is not the same as webhook delay
- local print output is not backend truth
- API event is not KDS ticket until bridge accepts it
- provider adapter must preserve architecture differences
- Mini Kiosk must stay provider-neutral
- universal abstraction must wait until enough evidence exists

This document prepares the project for safe multi-architecture provider integration without collapsing provider-specific risks into a premature universal model.