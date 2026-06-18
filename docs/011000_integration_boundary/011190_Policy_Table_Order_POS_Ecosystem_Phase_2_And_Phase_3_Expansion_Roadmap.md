# 011190_Policy_Table_Order_POS_Ecosystem_Phase_2_And_Phase_3_Expansion_Roadmap

Legacy path: $old.

\#\# 1\. Purpose

This document defines the Phase 2 and Phase 3 POS ecosystem expansion roadmap for the Yoonsul Wait/Order Handoff project.

The project has reviewed the table order and POS integration ecosystem represented by t-order style multi-POS integration, including OKPOS, Smartro, KICC, I'M U, Toss Place, Hyphen, and many small POS/VAN dealer networks.

This document records that broad POS ecosystem coverage is important, but must not be pulled into first-phase development.

The first phase remains focused.

Phase 2 and Phase 3 will expand provider coverage in controlled layers.

This document does not implement POS integration, table order integration, kiosk integration, payment code, local daemon code, or provider adapters.

It defines development phasing and expansion governance only.

\---

\#\# 2\. Scope

This document covers:

\- first-phase provider boundary
\- Phase 2 POS provider expansion
\- Phase 3 table order / kiosk ecosystem expansion
\- t-order style multi-POS integration lessons
\- major POS API provider classification
\- local daemon provider category
\- cloud SaaS provider category
\- VAN/API payment provider category
\- API hub / marketplace provider category
\- minor POS and dealer network handling
\- Hyphen-style integration hub strategy
\- Mini Kiosk and Kiosk reuse
\- no-implementation boundary

This document does not cover:

\- final provider implementation
\- final POS adapter code
\- final OKDC implementation
\- final Smartro Agent implementation
\- final KICC integration
\- final NICE integration
\- final Hyphen integration
\- final t-order integration
\- final kiosk implementation
\- final payment implementation
\- final hardware certification

\---

\#\# 3\. Core Principle

The POS ecosystem is too fragmented to solve in first phase.

The project must follow this rule:

\> First phase proves the runtime architecture with Toss and OKPOS. Phase 2 expands to major API-capable POS/payment providers. Phase 3 addresses broad table order, kiosk, API hub, and minor POS ecosystem coverage.

Do not turn MVP into a 30-POS integration project.

Do not ignore the 30-POS ecosystem either.

Document it, classify it, and phase it.

\---

\#\# 4\. First-Phase Boundary

First phase focuses on:

| Provider | Role |
| \-------- | \---- |
| Toss Place | Primary base provider direction |
| OKPOS | Required compatibility interface |
| PAYCO | Secondary payment / smart-order channel candidate |

First phase does not include:

\- Smartro implementation
\- KICC implementation
\- NICE implementation
\- I'M U implementation
\- Hyphen implementation
\- t-order integration
\- direct hardware terminal integration
\- broad POS adapter marketplace
\- minor POS direct integration
\- VAN dealer network integration
\- universal POS abstraction

The first phase goal is not market-wide POS coverage.

The first phase goal is to prove the runtime architecture.

\---

\#\# 5\. Why First Phase Is Toss \+ OKPOS

Toss and OKPOS represent the two core architecture families.

| Architecture Family | Provider |
| \------------------- | \-------- |
| Cloud Open API / webhook / modern provider | Toss |
| Local POS daemon / incumbent POS compatibility | OKPOS |

Together, they teach the system:

\- cloud API integration
\- webhook verification
\- local daemon risk
\- partner certification
\- POS/KDS handoff
\- payment verification
\- duplicate prevention
\- recovery state
\- Mini Kiosk provider-neutral design

This is enough for first phase.

Adding more providers before these are understood would create technical debt.

\---

\#\# 6\. PAYCO First-Phase Position

PAYCO remains important but does not drive the POS source-of-truth architecture.

PAYCO first-phase position:

    SECONDARY\_PAYMENT\_SMART\_ORDER\_CHANNEL

PAYCO may inform:

\- payment reservation / approval separation
\- WebView and app bridge behavior
\- smart order external channel
\- login versus payment separation
\- customer payment option planning

PAYCO should not drive:

\- main POS ledger integration
\- first KDS bridge implementation
\- OKPOS compatibility path
\- universal provider abstraction

\---

\#\# 7\. Phase 2 Provider Expansion

Phase 2 should begin only after the Toss \+ OKPOS first-phase architecture is stable.

Phase 2 candidate providers:

| Provider | Category | Phase 2 Role |
| \-------- | \-------- | \------------ |
| Smartro / Smile POS | Local Agent / VAN-linked POS | Table order and 60-second timeout model review |
| KICC / EasyPOS | VAN / Android POS / payment API | VAN TID and net-cancel model review |
| NICE POS / NICE Payments | Payment / VAN / API provider | Payment API and VAN settlement review |
| I'M U / UP POS | Cloud SaaS POS | Cloud POS alternative review |
| PAYCO | Payment / smart-order | Payment channel implementation review |
| Hyphen | API hub / marketplace | Multi-provider proxy and data hub review |

Phase 2 goal:

    Expand major provider compatibility without losing provider-neutral core.

\---

\#\# 8\. Phase 2 Development Targets

Phase 2 should produce:

\- official verification documents for each selected provider
\- provider adapter candidate notes
\- provider risk matrix
\- timeout/recovery pattern comparison
\- payment/refund/cancel boundary comparison
\- KDS handoff suitability score
\- sandbox/partner access status
\- evidence packet templates
\- blocker register
\- provider selection recommendation

Phase 2 should not immediately produce production code for all providers.

Phase 2 is still controlled expansion.

\---

\#\# 9\. Phase 2 Provider Grouping

\#\#\# 9.1 Smartro Group

Smartro should be studied for:

\- local order Agent
\- STORE\_ID / SERVICE\_ID based authorization
\- prepaid and postpaid table order flows
\- 5-second polling model
\- 60-second timeout / discard model
\- VCAT payment module
\- local POS state dependency
\- duplicate prevention
\- customer retry messaging

Smartro is valuable because it teaches:

    local agent plus strict timeout behavior.

\#\#\# 9.2 KICC Group

KICC should be studied for:

\- VAN TID based payment linkage
\- authentication / approval separation
\- net-cancel requirement
\- timeout-based cancellation
\- Android POS linkage
\- kitchen order and staff call options
\- local setup dependency
\- VAN settlement implications

KICC is valuable because it teaches:

    payment timeout and mandatory reversal discipline.

\#\#\# 9.3 NICE Group

NICE should be studied for:

\- payment API gateway
\- APP Secret Key
\- HTTPS outbound allowlist
\- tid based approval
\- payment confirmation flow
\- VAN/payment settlement
\- firewall and network dependency

NICE is valuable because it teaches:

    payment gateway and VAN infrastructure discipline.

\#\#\# 9.4 I'M U / UP POS Group

I'M U should be studied for:

\- cloud SaaS POS
\- multi-platform POS
\- cloud API potential
\- inventory and franchise expansion
\- multilingual and AI-adjacent features
\- cloud-native store operations

I'M U is valuable because it teaches:

    cloud POS alternative model.

\#\#\# 9.5 Hyphen Group

Hyphen should be studied for:

\- API marketplace model
\- multi-POS abstraction
\- delivery agency API aggregation
\- sandbox/testbed
\- unified REST interface
\- indirect POS integration
\- data marketplace risk
\- provider visibility loss

Hyphen is valuable because it teaches:

    integration hub versus direct provider adapter tradeoff.

\---

\#\# 10\. Phase 3 Ecosystem Expansion

Phase 3 should address broad ecosystem coverage.

Phase 3 may include:

\- t-order style multi-POS integration strategy
\- 30-plus POS compatibility classification
\- minor POS support policy
\- VAN dealer network handling
\- kiosk vendor integration
\- table order vendor integration
\- DID vendor integration
\- hardware terminal certification lane
\- printer / scanner / serial port boundary
\- Hyphen-style API hub adoption or rejection
\- provider abstraction after multiple provider evidence
\- franchise-wide provider onboarding model

Phase 3 goal:

    Build ecosystem-level compatibility without sacrificing runtime truth.

\---

\#\# 11\. Phase 3 Candidate Groups

\#\#\# 11.1 Minor POS Software Group

Examples:

\- Posmaster
\- BonIFPOS
\- SpharosPOS
\- AirPOS
\- NetPOS
\- NNP POS
\- TevalisPOS
\- FoodCafe
\- MagicPOS
\- FirstPOS
\- WavePOS
\- HyphenPOS
\- DaejinPOS
\- ASTEMS
\- PNC POS
\- BST
\- Shinheung
\- PharmCheck

Phase 3 handling:

\- classify only
\- verify market relevance
\- check official API or dealer path
\- avoid direct implementation unless customer demand exists
\- prefer hub or partner integration where available

\#\#\# 11.2 Hardware / Terminal Group

Examples:

\- POSBANK hardware
\- KOVAN
\- Bitel
\- Ingenico
\- Verifone
\- receipt printers
\- CAT terminals
\- barcode scanners
\- QR scanners
\- signature pads

Phase 3 handling:

\- treat as certified hardware lane
\- do not integrate directly without certification
\- separate hardware event from payment truth
\- separate print output from order truth

\#\#\# 11.3 VAN Dealer Network Group

The VAN dealer network is operationally important but technically fragmented.

Phase 3 handling:

\- treat as installation/support channel
\- do not treat dealer setup as API truth
\- record local setup dependency
\- require evidence for COM port, printer, terminal, and POS mapping
\- support rollout checklist later

\---

\#\# 12\. t-order Lesson

The t-order style ecosystem teaches that table order success depends on wide POS compatibility.

Key lessons:

\- customer ordering device alone is not enough
\- POS integration decides installation success
\- kitchen output path must be clear
\- payment and order must reconcile
\- local POS dealer support matters
\- each POS has different timeout and mutation behavior
\- minor POS support becomes technical debt
\- provider abstraction should be evidence-based
\- franchise rollout requires standardized onboarding

Yoonsul should learn from this but not copy it blindly.

\---

\#\# 13\. Yoonsul Strategic Difference

Yoonsul should not become only a table order hardware company.

Yoonsul should build:

\- provider-neutral backend runtime
\- POS/KDS bridge governance
\- payment verification
\- recovery/evidence
\- Mini Kiosk and Kiosk modularity
\- provider adapter layer
\- franchise/SaaS scalability

The goal is not to support 30 POS vendors immediately.

The goal is to create a system that can add them safely later.

\---

\#\# 14\. Provider Architecture Families

All providers should be classified into architecture families:

| Family | Examples | Handling |
| \------ | \-------- | \-------- |
| Cloud Open API | Toss, I'M U | backend-first integration |
| Local Daemon / Agent | OKPOS, Smartro | local failure and timeout recovery |
| VAN / Payment API | KICC, NICE | payment/refund/net-cancel discipline |
| Payment / Smart Order | PAYCO | payment channel and WebView boundary |
| API Hub / Marketplace | Hyphen | indirect provider abstraction |
| Minor POS / Dealer POS | many small POS | Phase 3 classification |
| Hardware Terminal | CAT, scanner, printer | certified lane only |

This classification should drive future development.

\---

\#\# 15\. Hyphen Strategy

Hyphen or similar API hub may become strategically important in Phase 3\.

Potential advantages:

\- reduces number of direct POS integrations
\- wraps many minor POS or delivery APIs
\- provides RESTful common interface
\- speeds market coverage
\- helps SaaS expansion

Potential risks:

\- loss of provider-specific detail
\- dependency on hub availability
\- unclear payment/order truth
\- limited KDS control
\- extra cost
\- weaker direct relationship with POS provider
\- difficult debugging when local POS fails

Policy:

    Hyphen should be studied in Phase 2 and considered for Phase 3 expansion, not used as first-phase core dependency.

\---

\#\# 16\. Universal Adapter Timing

Universal provider adapter should be deferred until:

1\. Toss evidence exists.
2\. OKPOS evidence exists.
3\. At least one Phase 2 provider is verified.
4\. Payment state model is stable.
5\. KDS handoff model is stable.
6\. Timeout/recovery model is stable.
7\. Provider differences are documented.
8\. Evidence packet structure is proven.

Do not build universal adapter from assumptions.

Build it from verified provider patterns.

\---

\#\# 17\. Phase-Based Roadmap

\#\#\# Phase 1

Focus:

\- Toss base
\- OKPOS compatibility
\- PAYCO secondary payment channel
\- provider-neutral core
\- Mini Kiosk boundary
\- POS/KDS bridge
\- payment recovery
\- evidence packet

\#\#\# Phase 2

Focus:

\- Smartro
\- KICC
\- NICE
\- I'M U
\- PAYCO deeper review
\- Hyphen evaluation
\- official verification documents
\- provider risk comparison
\- second provider adapter candidate

\#\#\# Phase 3

Focus:

\- t-order style ecosystem coverage
\- minor POS classification
\- hardware/certification lanes
\- VAN dealer rollout model
\- multi-provider adapter
\- API hub adoption or rejection
\- franchise-ready provider onboarding

\---

\#\# 18\. Development Stage Boundary

\#\#\# Phase 1 Development

Allowed:

\- Toss adapter planning
\- OKPOS compatibility planning
\- PAYCO payment channel planning
\- provider gateway boundary
\- Mini Kiosk provider-neutral design
\- KDS handoff protection
\- payment recovery state

Not allowed:

\- Smartro implementation
\- KICC implementation
\- NICE implementation
\- Hyphen implementation
\- minor POS implementation
\- universal adapter implementation

\#\#\# Phase 2 Development

Allowed:

\- selected provider official verification
\- adapter design for one or two providers
\- timeout/recovery comparison
\- payment/refund/cancel comparison
\- Hyphen feasibility review

Not allowed by default:

\- 30 POS implementation
\- hardware terminal direct control
\- franchise-wide provider rollout

\#\#\# Phase 3 Development

Allowed:

\- broad provider onboarding
\- multi-provider abstraction
\- hub integration
\- hardware lane
\- dealer rollout playbook
\- franchise-ready provider compatibility

\---

\#\# 19\. Provider Evidence Rule By Phase

\#\#\# Phase 1 Evidence

Required for:

\- Toss
\- OKPOS
\- PAYCO payment channel if active

\#\#\# Phase 2 Evidence

Required for:

\- Smartro
\- KICC
\- NICE
\- I'M U
\- Hyphen
\- PAYCO deeper implementation

\#\#\# Phase 3 Evidence

Required for:

\- minor POS vendors
\- hardware vendors
\- VAN dealers
\- kiosk vendors
\- table order vendors
\- API hub coverage
\- franchise rollout compatibility

No provider moves phase without evidence.

\---

\#\# 20\. Mini Kiosk / Kiosk Impact

Mini Kiosk and Kiosk must be designed for Phase 1 but not limited to Phase 1\.

The architecture must allow:

\- Toss now
\- OKPOS compatibility now
\- PAYCO payment later
\- Smartro/KICC/NICE later
\- Hyphen/hub later
\- minor POS later
\- hardware terminal later

Therefore, Mini Kiosk and Kiosk must not hardcode:

\- Toss-only assumptions
\- OKPOS daemon assumptions
\- PAYCO WebView assumptions
\- Smartro timeout assumptions
\- KICC net-cancel assumptions
\- Hyphen hub assumptions

Provider differences must stay behind adapter boundary.

\---

\#\# 21\. Risk Of Pulling Phase 2 Into Phase 1

Pulling Phase 2 into Phase 1 creates:

\- delayed MVP
\- provider confusion
\- test explosion
\- unclear payment truth
\- unclear KDS boundary
\- local daemon complexity
\- hardware dependency
\- contract dependency
\- partner approval dependency
\- support burden
\- architecture overfitting

Therefore, Phase 2 research may continue, but Phase 2 implementation must not enter Phase 1 without authorization.

\---

\#\# 22\. Risk Of Ignoring Phase 2 And Phase 3

Ignoring later providers creates:

\- limited market coverage
\- weak franchise expansion
\- difficulty entering existing stores
\- dependence on Toss only
\- inability to support OKPOS-like competitors
\- weak table order ecosystem readiness
\- poor SaaS portability

Therefore, later providers must be recorded now.

But they must be implemented later.

\---

\#\# 23\. Provider Register Recommendation

Create a provider register later with fields:

\- provider name
\- architecture family
\- phase
\- official source status
\- API access status
\- partner access status
\- sandbox status
\- payment scope
\- order scope
\- KDS scope
\- timeout model
\- cancel/refund model
\- hardware dependency
\- market relevance
\- implementation priority
\- evidence status
\- blocker status
\- notes

This provider register should be maintained separately from implementation code.

\---

\#\# 24\. Phase 2 Document Candidates

When Phase 2 begins, create:

1\. Smartro Smile POS Order Agent Official Verification And Timeout Boundary Policy
2\. KICC EasyPOS VAN TID Net Cancel And Payment Approval Boundary Policy
3\. NICE POS NICE Payments API Firewall Approval And VAN Settlement Boundary Policy
4\. I'M U UP POS Cloud SaaS POS Open API Evaluation Policy
5\. Hyphen API Hub Multi POS Aggregation Feasibility And Risk Policy
6\. PAYCO Payment Channel Deep Verification And Kiosk UI Boundary Policy

Do not create these as implementation documents before Phase 2 is authorized.

\---

\#\# 25\. Phase 3 Document Candidates

When Phase 3 begins, create:

1\. Multi POS Provider Adapter Canonicalization Policy
2\. Table Order Ecosystem Compatibility And Franchise Rollout Policy
3\. Minor POS Vendor Classification And Integration Triage Policy
4\. VAN Dealer Network Installation Evidence And Support Boundary Policy
5\. Certified Hardware Terminal Integration And Local Device Boundary Policy
6\. Kiosk Vendor Interoperability And White Label Device Policy
7\. Hyphen Or API Hub Production Adoption Decision Policy

Do not create these before Phase 3 scope is active.

\---

\#\# 26\. Updated Development Position

Current position:

    Phase 1:
      Toss base
      OKPOS compatibility
      PAYCO secondary payment channel

    Phase 2:
      Smartro
      KICC
      NICE
      I'M U
      Hyphen
      PAYCO deeper channel
      selected provider evidence

    Phase 3:
      t-order style broad ecosystem
      minor POS
      dealer network
      hardware
      API hub
      multi-provider adapter
      franchise rollout

This position supersedes earlier broad provider expansion assumptions where necessary.

\---

\#\# 27\. Non-Goals

This document does not define:

\- Smartro implementation
\- KICC implementation
\- NICE implementation
\- I'M U implementation
\- Hyphen implementation
\- t-order implementation
\- minor POS implementation
\- hardware integration
\- universal adapter code
\- provider onboarding software

Those belong to later authorized phases.

\---

\#\# 28\. Readiness Check

This document is ready when the project can answer:

1\. What remains in Phase 1?
2\. What moves to Phase 2?
3\. What moves to Phase 3?
4\. Why is t-order style ecosystem coverage not Phase 1?
5\. Which providers are Phase 2 candidates?
6\. Which ecosystem elements are Phase 3 candidates?
7\. Why is Hyphen not a first-phase dependency?
8\. When should universal adapter be built?
9\. How does this affect Mini Kiosk and Kiosk?
10\. What are the risks of pulling Phase 2 into Phase 1?
11\. What are the risks of ignoring Phase 2 and Phase 3?
12\. What provider register should be created later?
13\. What documents should be created in Phase 2?
14\. What documents should be created in Phase 3?

If these questions cannot be answered, POS ecosystem phasing is incomplete.

\---

\#\# 29\. Conclusion

The t-order style POS ecosystem analysis is important, but it must be phased.

Yoonsul should not attempt broad POS coverage in first phase.

The correct roadmap is:

\- Phase 1: Toss base, OKPOS compatibility, PAYCO secondary payment channel
\- Phase 2: Smartro, KICC, NICE, I'M U, Hyphen, PAYCO deeper verification
\- Phase 3: broad table order ecosystem, minor POS, dealer network, hardware certification, API hub, multi-provider adapter

This keeps MVP focused while preserving a clear path to broad market compatibility.

The project must continue to document provider evidence, but implementation must follow phase discipline.
