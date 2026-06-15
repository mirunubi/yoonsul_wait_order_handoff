# 11150_Policy_MVP_Provider_Cutline_Revision_Toss_OKPOS_First_Phase_And_PAYCO_Payment_Channel

Legacy path: $old.

\#\# 1\. Purpose

This document revises the earlier MVP provider cutline based on additional POS market and provider integration analysis.

The previous cutline treated Toss and PAYCO as the active MVP provider candidates and deferred OKPOS to Phase 2\.

Based on further review, this cutline must be corrected.

For first-phase POS integration, the project should treat:

\- Toss Place as the cloud Open API / webhook-first integration candidate
\- OKPOS as the domestic market coverage / OKDC local-daemon integration candidate
\- PAYCO as a payment / smart-order / login channel candidate, not the primary POS source integration candidate

This document does not implement Toss, OKPOS, PAYCO, KDS, mini kiosk, payment API, daemon integration, or hardware integration.

It revises the provider priority and first-phase integration scope.

\---

\#\# 2\. Scope

This document covers:

\- MVP provider cutline revision
\- Toss first-phase role
\- OKPOS first-phase role
\- PAYCO revised role
\- mini kiosk and kiosk reuse implication
\- local daemon versus cloud Open API distinction
\- POS/KDS bridge impact
\- provider investigation boundary
\- implementation risk difference
\- official verification requirement
\- future Phase 2 expansion boundary

This document does not cover:

\- final Toss implementation
\- final OKPOS implementation
\- final PAYCO implementation
\- final OKDC DLL implementation
\- final local daemon communication code
\- final Toss webhook receiver
\- final PAYCO payment gateway
\- final KDS ticket creation
\- final kiosk UI
\- final database schema
\- final deployment pipeline

\---

\#\# 3\. Core Revision

The MVP provider cutline is revised as follows:

Previous interpretation:

    MVP active providers: Toss \+ PAYCO
    OKPOS: Phase 2 candidate

Revised interpretation:

    First-phase POS integration candidates: Toss \+ OKPOS
    PAYCO: payment / smart-order / login channel candidate
    Other POS providers: Phase 2 investigation candidates

Reason:

\- Toss provides a cloud Open API / webhook style integration model.
\- OKPOS provides strong domestic POS market relevance and OKDC integration path.
\- PAYCO is useful but appears better positioned as payment, smart order, and account/login integration rather than the first POS source-of-truth integration.
\- Mini Kiosk and Kiosk development will benefit more from Toss \+ OKPOS first because they represent the two major integration architectures:
  \- cloud Open API / webhook
  \- local daemon / POS-connected bridge

\---

\#\# 4\. Revised Provider Priority Matrix

| Provider | Revised Priority | First-Phase Role | Notes |
| \-------- | \---------------- | \---------------- | \----- |
| Toss Place | Priority 1A | Cloud Open API / webhook POS integration | Best fit for server-to-server POS/payment/order sync |
| OKPOS | Priority 1B | Domestic POS coverage / OKDC local-daemon integration | Best fit for Korean POS market coverage and kiosk/table-order path |
| PAYCO | Priority 2 | Payment / smart-order / login channel | Useful payment channel, not primary POS source candidate |
| Smartro | Phase 2 | Local agent / table order candidate | Requires official agent and timeout verification |
| KICC EasyPOS | Phase 2 | ASP/local Android POS candidate | Requires controlled partner/ASP setup verification |
| NICE POS / NICE Payments | Phase 2 | Payment/VAN/API candidate | More payment/VAN oriented unless POS data access verified |
| Other POS providers | Phase 2 | Investigation-only | Official verification required |

\---

\#\# 5\. Toss First-Phase Role

Toss should remain first-phase because it represents a modern cloud API integration model.

Toss first-phase scope may include:

\- Open API official verification
\- merchant/store mapping
\- order lookup
\- payment lookup
\- webhook signature verification
\- webhook idempotency
\- replay protection
\- rate limit handling
\- payment/order event quarantine
\- POS/KDS handoff candidate
\- provider evidence packet
\- deployment gate planning

Toss first-phase scope should not automatically include:

\- Apps in Toss miniapp
\- POS Plugin SDK embedded UI
\- Android miniapp runtime
\- production release
\- full settlement automation
\- direct hardware control

Toss is the cleanest reference model for:

    cloud-first provider integration.

\---

\#\# 6\. OKPOS First-Phase Role

OKPOS should be added to first-phase planning because it represents the dominant domestic POS ecosystem and the local daemon / partner integration architecture.

OKPOS first-phase scope may include:

\- OKDC official verification
\- partnership process review
\- OKDC daemon boundary analysis
\- OKDC DLL / interface verification
\- master data collection boundary
\- order registration boundary
\- payment processing boundary
\- table order / kiosk / mobile POS / DID integration review
\- local POS state dependency review
\- local network failure review
\- POS/KDS bridge mapping
\- mini kiosk / kiosk reuse analysis
\- pilot store requirement analysis
\- evidence packet planning

OKPOS first-phase scope should not automatically include:

\- actual OKDC code
\- DLL loading
\- daemon communication implementation
\- direct production partner integration
\- hardware terminal control
\- franchise-wide rollout
\- silent local POS mutation
\- unverified KDS handoff

OKPOS is the key reference model for:

    local POS-connected provider integration.

\---

\#\# 7\. PAYCO Revised Role

PAYCO remains important, but its role should be revised.

PAYCO should be treated as:

    payment / smart-order / login channel candidate

not:

    first primary POS source integration candidate

PAYCO revised scope may include:

\- payment API verification
\- payment reservation and final approval separation
\- callback / returnUrl handling
\- smart order external channel policy
\- PAYCO login identity boundary
\- Android WebView / app bridge review
\- credential handling
\- cancellation/refund verification
\- optional payment provider module

PAYCO should not drive the first POS/KDS integration model unless official PAYCO partner documents prove direct POS order/payment/store data access equivalent to Toss or OKPOS.

PAYCO is still useful for:

\- future customer payment option
\- smart order comparison
\- login/account linkage review
\- mini kiosk payment UI review
\- mobile order payment review

\---

\#\# 8\. Why Toss Plus OKPOS Is The Better First-Phase Pair

Toss and OKPOS together cover two very different but strategically important integration models.

| Integration Axis | Toss | OKPOS |
| \---------------- | \---- | \----- |
| Architecture | Cloud Open API / webhook | Local daemon / OKDC bridge |
| Market Role | Fast-growing modern POS platform | Major domestic POS incumbent |
| API Style | Server-to-server REST / webhook | Partner contract / daemon / DLL style |
| Kiosk Relevance | Backend-first event integration | Table order / kiosk / mobile POS integration path |
| Failure Mode | webhook replay, rate limit, cloud sync | local daemon, store network, POS state dependency |
| Security Focus | API key, webhook signature, idempotency | local daemon trust, partner contract, POS mutation boundary |
| MVP Learning Value | modern cloud integration pattern | Korean POS legacy/incumbent integration pattern |

This pair gives the project broader architectural coverage than Toss \+ PAYCO.

\---

\#\# 9\. Revised MVP / First-Phase Cutline

First-phase active provider candidates:

\- Toss Place
\- OKPOS

First-phase secondary payment channel candidate:

\- PAYCO

Investigation-only Phase 2 providers:

\- Smartro
\- KICC EasyPOS
\- NICE POS / NICE Payments
\- delivery platform POS adapters
\- other POS providers
\- VAN/CAT direct hardware integrations

This means:

\- Toss blockers may block first-phase POS Open API integration.
\- OKPOS blockers may block first-phase domestic POS integration.
\- PAYCO blockers block only PAYCO payment/smart-order scope.
\- Smartro/KICC/NICE blockers do not block first phase unless explicitly selected.

\---

\#\# 10\. OKPOS Integration Category

OKPOS should be classified as:

    FIRST\_PHASE\_LOCAL\_POS\_DAEMON\_PROVIDER

Openness rating:

    PARTNER\_API\_REQUIRED \+ LOCAL\_DAEMON\_BRIDGE \+ DOMESTIC\_MARKET\_PRIORITY

Meaning:

\- OKPOS is not as cloud-open as Toss.
\- OKPOS appears to require partner process and OKDC access.
\- OKPOS is still first-phase relevant due to market coverage and kiosk/table-order fit.
\- OKPOS integration must be handled with stricter official verification and partner evidence.

\---

\#\# 11\. Toss Integration Category

Toss should be classified as:

    FIRST\_PHASE\_CLOUD\_OPEN\_API\_PROVIDER

Openness rating:

    OPEN\_POS\_API \+ WEBHOOK\_FIRST \+ CLOUD\_RUNTIME

Meaning:

\- Toss is suitable for cloud-first server-to-server integration.
\- Toss can serve as the first clean backend provider model.
\- Toss should remain the first technical reference for webhook/idempotency/rate-limit patterns.

\---

\#\# 12\. PAYCO Integration Category

PAYCO should be classified as:

    SECONDARY\_PAYMENT\_SMART\_ORDER\_PROVIDER

Openness rating:

    OPEN\_PAYMENT\_API \+ SMART\_ORDER\_CHANNEL \+ DOCUMENTATION\_FRAGMENTED

Meaning:

\- PAYCO is useful but not primary POS integration in first phase.
\- PAYCO payment integration may be useful after payment runtime stabilizes.
\- PAYCO Smart Order should remain an external operational channel unless official integration proves deeper POS access.
\- PAYCO Android/WebView should remain kiosk payment UI candidate, not POS source candidate.

\---

\#\# 13\. Impact On Mini Kiosk / Kiosk Development

Mini Kiosk and Kiosk development should use Toss \+ OKPOS as the first architecture pair.

\#\#\# Toss teaches:

\- cloud POS API
\- webhook handling
\- payment/order lookup
\- idempotency
\- rate limit
\- backend verification

\#\#\# OKPOS teaches:

\- local daemon dependency
\- POS-installed integration
\- partner certification
\- table order/kiosk integration
\- local POS state dependency
\- store network failure handling
\- local-to-cloud sync risk

\#\#\# PAYCO teaches:

\- payment reservation/approval separation
\- WebView/app bridge
\- payment provider identity separation
\- smart order external channel
\- login versus payment separation

Therefore, kiosk module planning should not discard PAYCO, but first POS/KDS integration planning should prioritize Toss and OKPOS.

\---

\#\# 14\. OKPOS Required Official Verification Checklist

Before OKPOS implementation, verify:

1\. Current OKDC partnership process.
2\. Current OKDC pricing/contract model.
3\. Current OKDC public versus dedicated integration distinction.
4\. Supported service types.
5\. Whether table order, kiosk, mobile POS, and DID are supported in current OKDC contract.
6\. OKDC daemon installation and lifecycle.
7\. OKDC DLL loading requirement.
8\. Supported programming languages or runtime.
9\. Communication method.
10\. Master data collection scope.
11\. Order registration scope.
12\. Payment processing scope.
13\. Cancel/refund scope.
14\. POS business open/close state dependency.
15\. Local network timeout behavior.
16\. Duplicate order prevention model.
17\. Table lock or table occupancy behavior.
18\. KDS/kitchen order output behavior.
19\. Pilot store certification process.
20\. Required test scenario submission.
21\. Required quality artifacts.
22\. Production rollout approval process.
23\. Failure handling and support channel.
24\. Credential/key storage rule.
25\. Audit/evidence availability.

No OKPOS implementation should begin without official partner/API evidence.

\---

\#\# 15\. OKPOS First-Phase Risks

OKPOS risks are different from Toss risks.

| Risk | Description |
| \---- | \----------- |
| Partner Access Risk | OKDC may require contract and official technical document access |
| Local Daemon Risk | Integration depends on store POS PC and daemon availability |
| DLL Runtime Risk | Partner may need DLL loading and local runtime compatibility |
| Local Network Risk | Store LAN/Wi-Fi/POS state may affect order delivery |
| POS Mutation Risk | Local POS order/payment mutation must not be unsafe |
| KDS Duplication Risk | Duplicate order registration may duplicate kitchen output |
| Pilot Certification Risk | OKPOS technical department may require pilot validation |
| Cost Model Risk | Service may be charged per store or service |
| Support Ownership Risk | Failure boundary between OKPOS, store, and Yoonsul must be clear |

These risks must be reflected in blocker and evidence planning.

\---

\#\# 16\. Revised Provider Bundle Grouping

The provider bundle should now include future OKPOS documents.

Recommended folder grouping:

    docs/
      05000\_provider\_integration\_and\_kiosk\_reuse/
        README.md
        05095\_Toss\_POS\_Integration\_Implementation\_Approach\_And\_Test\_Mapping\_Policy.md
        05150\_Toss\_POS\_Official\_Verification\_Checklist\_And\_Integration\_Evidence\_Policy.md
        11080_Policy_PAYCO_POS_Integration_Implementation_Approach_And_Official_Verification.md
        11090_Policy_POS_Payment_Provider_Integration_Priority_Matrix_And_Openness_Assessment.md
        05190\_MVP\_Provider\_Cutline\_And\_Phase\_2\_POS\_Expansion\_Deferral\_Policy.md
        05200\_POS\_Payment\_Provider\_Document\_Folder\_Grouping\_And\_Kiosk\_Reuse\_Policy.md
        05240\_MVP\_Provider\_Cutline\_Revision\_Toss\_OKPOS\_First\_Phase\_And\_PAYCO\_Payment\_Channel\_Policy.md

Future OKPOS documents should be placed in the same bundle.

\---

\#\# 17\. Documents To Create Next

Because OKPOS has moved into first-phase scope, the following documents should be created next:

1\. \`11160_Policy_OKPOS_OKDC_Integration_Implementation_Approach_And_Test_Mapping\`
2\. \`05260 OKPOS Official Verification Checklist And Partner Evidence Policy\`
3\. \`05270 Local Daemon POS Integration Boundary And Failure Recovery Policy\`
4\. \`11200_Policy_Cloud_Open_API_Versus_Local_Daemon_Provider_Architecture_Comparison\`

These documents should still avoid implementation.

They should define approach, verification, blocker, evidence, and module boundaries.

\---

\#\# 18\. Update To 05190

Document 05190 should be treated as superseded by this document for provider cutline.

Supersession rule:

    05240 supersedes 05190 for MVP provider cutline.

05190 remains useful for:

\- Phase 2 provider deferral structure
\- provider investigation rule
\- universal adapter warning
\- provider evidence requirement

But its MVP provider list must be read as revised:

    Toss \+ OKPOS first-phase
    PAYCO secondary payment/smart-order channel
    Others Phase 2

\---

\#\# 19\. Updated First-Phase Provider Status

| Provider | Status |
| \-------- | \------ |
| Toss Place | FIRST\_PHASE\_ACTIVE |
| OKPOS | FIRST\_PHASE\_ACTIVE |
| PAYCO | SECONDARY\_PAYMENT\_CHANNEL |
| Smartro | PHASE2\_INVESTIGATION |
| KICC EasyPOS | PHASE2\_INVESTIGATION |
| NICE POS / NICE Payments | PHASE2\_INVESTIGATION |
| Other POS Providers | PHASE2\_INVESTIGATION |
| Direct Hardware Terminal | DEFERRED\_CERTIFIED\_LANE |

\---

\#\# 20\. First-Phase Implementation Recommendation

Recommended first-phase sequence:

\#\#\# Step 1: Internal Provider-Neutral Runtime

\- tenant/store context
\- audit/evidence
\- payment state model
\- order intent
\- POS/KDS bridge
\- KDS idempotency
\- recovery state
\- provider event quarantine

\#\#\# Step 2: Toss Cloud Provider Path

\- official verification
\- Open API mapping
\- webhook validation
\- payment/order lookup
\- rate limit
\- KDS handoff candidate

\#\#\# Step 3: OKPOS Local Daemon Provider Path

\- OKDC official verification
\- partner evidence
\- daemon boundary
\- DLL/interface boundary
\- local failure handling
\- POS/KDS handoff mapping
\- pilot certification planning

\#\#\# Step 4: PAYCO Payment Channel Review

\- payment API verification
\- reservation/approval boundary
\- payment UI/WebView option
\- smart order external channel

\#\#\# Step 5: Phase 2 Provider Register

\- Smartro
\- KICC
\- NICE
\- delivery platforms
\- kiosk provider APIs
\- VAN/CAT hardware

\---

\#\# 21\. First-Phase Anti-Patterns

The following are prohibited:

\- treating OKPOS as simple REST API without verifying OKDC details
\- treating OKDC daemon as trusted backend truth without validation
\- letting OKPOS local daemon create KDS ticket directly
\- treating local POS print output as Yoonsul truth
\- assuming OKPOS payment processing equals provider refund state
\- ignoring partner contract requirement
\- delaying Toss cloud integration because OKPOS is complex
\- dropping PAYCO entirely from payment strategy
\- building universal POS adapter before Toss and OKPOS are both understood
\- treating Smartro/KICC/NICE as first-phase without authorization

\---

\#\# 22\. Revised MVP / First-Phase Readiness Check

This document is ready when the project can answer:

1\. Why is 05190 revised?
2\. Why is Toss still first-phase?
3\. Why is OKPOS now first-phase?
4\. Why is PAYCO moved to payment/smart-order channel?
5\. What does Toss represent architecturally?
6\. What does OKPOS represent architecturally?
7\. What does PAYCO represent architecturally?
8\. What official OKPOS verification is required?
9\. What OKPOS risks are unique?
10\. How does this affect Mini Kiosk and Kiosk development?
11\. Which documents should be created next?
12\. How is 05190 superseded?
13\. Which providers are Phase 2 only?
14\. Why should universal adapter still be deferred?

If these questions cannot be answered, provider cutline revision is incomplete.

\---

\#\# 23\. Conclusion

The first-phase provider strategy must be revised.

The correct direction is:

\- Toss for cloud Open API / webhook POS integration
\- OKPOS for domestic POS market / OKDC local daemon integration
\- PAYCO for payment / smart-order / login channel
\- Smartro, KICC, NICE, and other POS providers for Phase 2 investigation

This revision is important for Mini Kiosk and Kiosk development because Toss and OKPOS together represent the two core provider architecture families:

\- cloud-first Open API
\- local POS-connected daemon

The project must not implement OKPOS yet.

It must first create OKPOS implementation approach, official verification, local daemon boundary, failure recovery, blocker, and evidence documents.

This document supersedes the earlier MVP provider cutline where it conflicts with the new strategy.
