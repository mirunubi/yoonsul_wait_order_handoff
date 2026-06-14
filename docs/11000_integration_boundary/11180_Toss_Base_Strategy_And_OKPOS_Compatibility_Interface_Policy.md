\# 05260 Toss Base Strategy And OKPOS Compatibility Interface Policy

Legacy path: $old.

\#\# 1\. Purpose

This document defines the revised first-phase provider strategy for the Yoonsul Wait/Order Handoff project.

The project will use Toss as the primary base provider direction while maintaining OKPOS compatibility as a required interface path because many existing stores already use OKPOS.

This document reflects the strategic decision:

\- Toss is the primary first-phase base.
\- OKPOS is a required compatibility interface.
\- PAYCO remains a secondary payment / smart-order channel.
\- Other POS providers remain later-phase candidates.

This document does not implement Toss, OKPOS, PAYCO, Mini Kiosk, Kiosk, POS/KDS bridge, or payment code.

It defines provider strategy and architecture direction.

\---

\#\# 2\. Scope

This document covers:

\- Toss-base strategy
\- OKPOS compatibility requirement
\- provider positioning
\- first-store adoption logic
\- Mini Kiosk / Kiosk implication
\- POS/KDS bridge implication
\- provider adapter direction
\- market-entry strategy
\- first-phase versus later-phase boundary
\- implementation caution

This document does not cover:

\- final Toss implementation
\- final OKPOS implementation
\- final OKDC implementation
\- final PAYCO implementation
\- final vendor contract
\- final kiosk hardware selection
\- final store equipment purchase
\- final production release
\- final franchise rollout

\---

\#\# 3\. Core Strategic Decision

The project adopts the following direction:

    Toss Base
    OKPOS Compatibility
    PAYCO Payment Channel
    Other POS Phase 2

Meaning:

\- Toss is the primary runtime and provider integration direction.
\- Toss is preferred for flexibility, cloud API posture, webhook/event model, and growth alignment.
\- OKPOS is not the preferred base, but must be supported because of market penetration.
\- PAYCO is not the primary POS base, but remains relevant for payment and smart-order channels.
\- The Yoonsul system must remain provider-neutral internally.

\---

\#\# 4\. Why Toss Is The Base

Toss is preferred as the base because:

\- it is more flexible for modern API integration
\- it is more aligned with cloud-first provider design
\- it has clearer Open API and webhook direction
\- it is better suited for SaaS-style backend integration
\- it is more compatible with event-driven handoff
\- it may prefer partnerships that help expand beyond legacy POS incumbents
\- it can support a modern Mini Kiosk / Kiosk direction
\- it provides a cleaner first implementation reference

Toss is not selected because it is the largest.

Toss is selected because it is more structurally compatible with the Yoonsul SaaS/runtime strategy.

\---

\#\# 5\. Why OKPOS Still Must Be Supported

OKPOS must be supported because:

\- many existing stores already use OKPOS
\- OKPOS has strong domestic market penetration
\- POS dealers and store owners may already rely on OKPOS
\- stores may not want to replace their POS ledger
\- table order, kiosk, kitchen print, VAN, receipt, and sales reporting may already be tied to OKPOS
\- future franchise or SaaS customers may demand OKPOS compatibility
\- ignoring OKPOS would reduce market reach

Therefore, OKPOS is not the base, but OKPOS compatibility is mandatory.

\---

\#\# 6\. Market Interpretation

The market likely contains many stores where:

\- OKPOS is the underlying POS ledger
\- a separate kiosk vendor handles customer ordering
\- a separate payment terminal handles card/payment acceptance
\- a small kiosk company provides limited integration
\- full backend integration is weak or unavailable
\- order/payment/KDS state may be fragmented

This is an opportunity for Yoonsul.

Yoonsul can provide:

\- better handoff structure
\- better provider gateway
\- better Mini Kiosk module
\- better KDS boundary
\- better recovery state
\- better audit/evidence
\- better SaaS-style integration layer

The market pain is not only ordering.

It is fragmented integration.

\---

\#\# 7\. Toss And OKPOS Strategic Relationship

Toss and OKPOS should be treated as different strategic roles.

| Role | Toss | OKPOS |
| \---- | \---- | \----- |
| Project Base | Yes | No |
| First-Phase Support | Yes | Yes |
| Architecture Model | Cloud Open API / webhook | Local POS daemon / OKDC |
| Market Value | Modern flexible entry | Existing store coverage |
| Integration Style | Backend-first | Compatibility-first |
| Kiosk Strategy | Future-friendly | Existing-store compatibility |
| Risk | Provider growth/coverage | Partner access/local daemon complexity |
| Yoonsul Position | Build on top of Toss where possible | Support where stores already use it |

This dual strategy lets Yoonsul move fast without abandoning real market coverage.

\---

\#\# 8\. Revised First-Phase Provider Status

| Provider | Status | Role |
| \-------- | \------ | \---- |
| Toss Place | PRIMARY\_BASE | First implementation direction |
| OKPOS | REQUIRED\_COMPATIBILITY | Existing-store compatibility path |
| PAYCO | SECONDARY\_PAYMENT\_CHANNEL | Payment/smart-order/login option |
| Smartro | PHASE2\_INVESTIGATION | Later POS compatibility |
| KICC EasyPOS | PHASE2\_INVESTIGATION | Later POS compatibility |
| NICE POS / NICE Payments | PHASE2\_INVESTIGATION | Later payment/POS candidate |
| Small kiosk vendors | PHASE2\_OR\_STORE\_SPECIFIC | Evaluate case by case |
| Direct hardware terminal | DEFERRED\_CERTIFIED\_LANE | Later certified integration |

\---

\#\# 9\. First Store Equipment Strategy

For the first physical store, the project should investigate:

1\. Toss POS / Toss device / Toss kiosk as base.
2\. OKPOS compatibility only if required by store setup or market/channel constraint.
3\. Whether Toss can cover needed store operations without OKPOS.
4\. Whether OKPOS ledger plus Toss payment/kiosk surface is commercially and technically viable.
5\. Whether dealer support creates lock-in or integration limitation.
6\. Whether Yoonsul Mini Kiosk can remain provider-neutral.

Preferred direction:

    Toss-first where feasible.

Fallback/compatibility direction:

    OKPOS-compatible where market requires.

Do not choose OKPOS solely because it is number one.

Do not ignore OKPOS solely because Toss is more flexible.

\---

\#\# 10\. Mini Kiosk Implication

Mini Kiosk must be designed as:

    Yoonsul Mini Kiosk
        \-\> Yoonsul Backend
            \-\> Provider Adapter
                \-\> Toss or OKPOS or PAYCO later

Mini Kiosk must not be designed as:

    Mini Kiosk \-\> Toss directly only

or:

    Mini Kiosk \-\> OKPOS OKDC directly

Reason:

\- Toss may be the base now, but future stores may use OKPOS.
\- OKPOS may be common, but local daemon dependency should not leak into kiosk UI.
\- PAYCO may become payment option later.
\- Other POS providers may be added in Phase 2\.

The Mini Kiosk must be provider-neutral above the adapter layer.

\---

\#\# 11\. Kiosk Vendor Interpretation

Small kiosk vendors often operate as device/UI providers, not full runtime owners.

Common issues:

\- weak POS integration
\- weak payment recovery
\- weak KDS handoff
\- limited audit
\- no proper duplicate prevention
\- vendor-specific setup
\- dependence on POS dealer configuration
\- unclear refund/cancel boundary
\- poor SaaS extensibility

Yoonsul should not copy this pattern.

Yoonsul should build:

\- provider-neutral kiosk layer
\- backend-first payment verification
\- POS/KDS handoff control
\- recovery and evidence
\- supportable provider adapter

\---

\#\# 12\. Provider Adapter Strategy

The provider adapter layer must support:

\- Toss adapter
\- OKPOS adapter
\- PAYCO adapter later
\- other POS adapter later

Provider adapter must isolate:

\- credential model
\- merchant/store mapping
\- order event mapping
\- payment event mapping
\- callback/webhook handling
\- timeout behavior
\- duplicate prevention
\- cancellation/refund semantics
\- KDS handoff eligibility
\- evidence creation
\- rollback/disable path

Core Yoonsul runtime must not depend on provider-specific assumptions.

\---

\#\# 13\. Toss Adapter Direction

Toss adapter should be the first clean reference implementation.

Toss adapter should focus on:

\- Open API verification
\- webhook verification
\- merchant mapping
\- order lookup
\- payment lookup
\- payment approved/cancelled event mapping
\- rate limit handling
\- idempotency
\- replay protection
\- KDS handoff candidate creation
\- evidence packet creation

Toss adapter should not directly define all future provider abstraction.

It should be the first provider-specific implementation, not the final universal model.

\---

\#\# 14\. OKPOS Adapter Direction

OKPOS adapter should be designed as a compatibility adapter.

OKPOS adapter should focus on:

\- OKDC official verification
\- partner process
\- local daemon boundary
\- store mapping
\- order registration
\- local timeout handling
\- duplicate prevention
\- kitchen output conflict
\- POS/KDS mapping
\- pilot evidence
\- rollback/disable path

OKPOS adapter should not be allowed to leak local daemon assumptions into core runtime.

\---

\#\# 15\. PAYCO Adapter Direction

PAYCO adapter remains payment/channel oriented.

PAYCO adapter should focus on:

\- payment reservation
\- auth callback
\- final approval
\- payment failure
\- payment cancellation/refund review
\- login identity separation
\- smart order external channel
\- Android/WebView boundary

PAYCO should not be used as the first POS source-of-truth adapter unless new official evidence proves that role.

\---

\#\# 16\. Strategic Partnership Interpretation

Toss may prefer partners that help reduce dependency on incumbent POS environments.

Yoonsul may benefit by:

\- building Toss-first integration
\- showing a strong store operations use case
\- preparing Mini Kiosk / Kiosk handoff
\- offering franchise/SaaS expansion potential
\- still providing OKPOS compatibility for stores that cannot migrate

This creates a practical message:

    Yoonsul is Toss-friendly but not Toss-locked.

That is stronger than:

    Yoonsul only works with Toss.

or:

    Yoonsul depends on OKPOS.

\---

\#\# 17\. Franchise Expansion Implication

For franchise or SaaS expansion:

\- new stores can be recommended toward Toss-first setup
\- existing OKPOS stores can be supported through compatibility path
\- PAYCO can be offered as payment option if needed
\- other POS providers can be added as Phase 2
\- core Yoonsul runtime remains consistent

This avoids forcing every store to replace POS immediately.

It also avoids building the entire system around legacy POS constraints.

\---

\#\# 18\. Updated First-Phase Cutline

First-phase scope:

\#\#\# Active Base

\- Toss

\#\#\# Required Compatibility

\- OKPOS

\#\#\# Secondary Channel

\- PAYCO

\#\#\# Investigation Only

\- Smartro
\- KICC
\- NICE
\- other POS vendors
\- small kiosk vendors
\- hardware terminal direct integrations

\---

\#\# 19\. Required First-Phase Documents

Required document set:

\- Toss implementation approach
\- Toss official verification checklist
\- OKPOS implementation approach
\- OKPOS official verification checklist
\- local daemon boundary policy
\- cloud API versus local daemon comparison
\- provider adapter boundary
\- Mini Kiosk provider-neutral module policy

PAYCO does not need more documents until payment implementation becomes active.

\---

\#\# 20\. Decision Rules

Use Toss as base when:

\- new store setup is flexible
\- cloud API integration is available
\- store operation can work without legacy POS dependency
\- Mini Kiosk / Kiosk integration benefits from Toss
\- provider contract is favorable
\- API evidence is strong

Use OKPOS compatibility when:

\- store already uses OKPOS
\- dealer infrastructure depends on OKPOS
\- kitchen/receipt/table order is tied to OKPOS
\- migration cost is too high
\- store/customer cannot change POS
\- SaaS expansion needs compatibility

Use PAYCO when:

\- payment option is needed
\- smart order channel is useful
\- PAYCO member/payment flow is desired
\- backend payment approval flow is verified

\---

\#\# 21\. Risks

\#\#\# Toss-Base Risk

\- Toss market coverage may not match OKPOS.
\- Some stores may resist POS migration.
\- Toss-specific APIs may create dependency.
\- Toss device/kiosk roadmap may change.

\#\#\# OKPOS Compatibility Risk

\- OKDC partner access may be difficult.
\- Local daemon failure modes are complex.
\- Pilot/certification may take time.
\- Interface may require fees.
\- Local POS mutation boundary is risky.

\#\#\# Dual Strategy Risk

\- Two provider paths increase documentation and testing burden.
\- Provider adapter layer must be disciplined.
\- Core runtime must remain provider-neutral.
\- Universal abstraction must not be built too early.

\---

\#\# 22\. Anti-Patterns

The following are prohibited:

\- making Toss assumptions core runtime assumptions
\- making OKPOS local daemon assumptions core runtime assumptions
\- connecting Mini Kiosk directly to OKDC
\- connecting Mini Kiosk directly to Toss without backend control
\- treating small kiosk vendor behavior as reliable architecture
\- treating OKPOS market share as reason to abandon Toss
\- treating Toss flexibility as reason to ignore OKPOS
\- treating PAYCO as POS base without evidence
\- building universal adapter before Toss and OKPOS are both understood
\- letting provider choice collapse payment/order/KDS boundaries

\---

\#\# 23\. Updated Architecture Rule

The correct architecture is:

    Yoonsul Core Runtime
        \-\> Provider Gateway
            \-\> Toss Adapter
            \-\> OKPOS Adapter
            \-\> PAYCO Adapter Later
            \-\> Other POS Adapter Later

Not:

    Toss decides Yoonsul architecture

and not:

    OKPOS decides Yoonsul architecture

and not:

    kiosk vendor decides Yoonsul architecture

Yoonsul owns the runtime model.

Providers are adapters.

\---

\#\# 24\. Readiness Check

This document is ready when the project can answer:

1\. Why is Toss the base?
2\. Why must OKPOS still be supported?
3\. What role does PAYCO have?
4\. Why does Toss \+ OKPOS strategy make sense?
5\. How does this affect Mini Kiosk?
6\. How does this affect full Kiosk?
7\. What is the provider adapter direction?
8\. What should Toss adapter do first?
9\. What should OKPOS adapter do first?
10\. What should PAYCO adapter do later?
11\. How does this support franchise expansion?
12\. When should Toss be used?
13\. When should OKPOS compatibility be used?
14\. What risks exist?
15\. What anti-patterns are prohibited?
16\. What is the updated architecture rule?

If these questions cannot be answered, provider base strategy is incomplete.

\---

\#\# 25\. Conclusion

The Yoonsul Wait/Order Handoff project will use Toss as the strategic base provider direction.

This is because Toss is more flexible, more cloud/API-friendly, and more aligned with the future SaaS and Mini Kiosk architecture.

However, OKPOS compatibility is mandatory because OKPOS is widely installed in the domestic market and many future stores may already depend on it.

PAYCO remains a useful payment and smart-order channel but is not the primary POS base.

The correct strategy is:

\- Toss-first
\- OKPOS-compatible
\- PAYCO-secondary
\- provider-neutral core
\- Mini Kiosk through Yoonsul Backend
\- no direct vendor lock-in
\- no premature universal adapter
\- no collapse of payment, order, POS, and KDS truth

Yoonsul should grow by aligning with Toss where possible, while preserving the ability to serve OKPOS-installed stores through a controlled compatibility interface.
