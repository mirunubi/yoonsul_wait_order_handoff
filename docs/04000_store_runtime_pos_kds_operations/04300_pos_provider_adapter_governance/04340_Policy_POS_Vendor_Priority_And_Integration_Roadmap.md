# 04340_Policy_POS_Vendor_Priority_And_Integration_Roadmap

## **1\. Purpose**

This document defines the POS vendor priority and integration roadmap policy.

The purpose of this policy is to determine which POS, payment, order, table-order, kiosk, and external provider integrations should be pursued first, and how each integration should be staged.

The system must not attempt to integrate every POS provider at once.

The system should prioritize providers based on market reach, API availability, technical feasibility, store adoption impact, payment and KDS relevance, and strategic value.

---

## **2\. Scope**

This policy applies to:

* POS vendor integration priority
* Payment provider integration priority
* Table order provider integration priority
* Kiosk provider integration priority
* Delivery app intake priority
* Open API provider selection
* Large POS vendor strategy
* Legacy POS fallback strategy
* Adapter development roadmap
* Store pilot selection
* Vendor onboarding order
* Integration capability target by phase

This policy does not define commercial negotiation terms, revenue sharing terms, vendor contract pricing, legal partnership terms, or final engineering implementation details.

---

## **3\. Core Principle**

Integration priority must follow strategic leverage.

The system should not choose the next provider only because it is technically easy.

The system should choose providers by answering:

Does this provider unlock many stores?
Does this provider reduce counter bottlenecks?
Does this provider support payment automation?
Does this provider improve KDS release flow?
Does this provider have accessible API or partner path?
Does this provider help prove the SaaS model?
Does this provider reduce future integration risk?

The roadmap must balance quick wins and strategic anchors.

---

## **4\. Strategic Integration Layers**

Provider integration should be grouped into layers.

Recommended layers:

Layer 1: Open API payment and order providers
Layer 2: Major POS providers
Layer 3: Table order and kiosk providers
Layer 4: Delivery and external order channels
Layer 5: Legacy and manual fallback environments
Layer 6: Franchise and enterprise POS environments

Each layer requires a different adapter strategy.

---

## **5\. Layer 1: Open API Payment And Order Providers**

Layer 1 should be prioritized because open API providers allow faster MVP validation.

Candidate provider categories include:

Toss Payments
PAYCO
PortOne or equivalent payment orchestration
payment widget providers
payment link providers
virtual account callback providers
open banking or fintech callback providers

The initial goal is not full POS replacement.

The initial goal is:

dynamic payment request
payment webhook verification
payment status normalization
KDS release trigger
customer display update
audit and reconciliation

Layer 1 proves the payment-to-kitchen automation loop.

---

## **6\. Layer 2: Major POS Providers**

Layer 2 targets large POS providers used by many restaurants and small business stores.

Candidate categories include:

OKPOS
POSBANK-related environments
large restaurant POS providers
franchise POS providers
cloud POS providers
VAN-linked POS providers
tablet POS providers

The initial integration target should be Level 1 or Level 2\.

Recommended early target:

read-only order intake
order amount intake
payment status visibility
order cancellation visibility
basic item mapping
KDS projection handoff

Authority-level write integration should not be assumed until vendor contract and technical testing are completed.

---

## **7\. Layer 3: Table Order And Kiosk Providers**

Layer 3 targets table order and kiosk systems.

Candidate categories include:

table order vendors
tablet menu vendors
self-order kiosk providers
customer QR order providers
waiting-order providers
store ordering web apps

This layer is important because table order systems already sit close to customer ordering behavior.

Integration target:

order created
order modified
payment requested
payment completed
table reference
customer session
KDS release

The system should avoid being trapped as only a table-order competitor.

It should position itself as the order-payment-KDS federation layer.

---

## **8\. Layer 4: Delivery And External Order Channels**

Layer 4 targets delivery and partner order channels.

Candidate categories include:

delivery app order intake
pickup order partner
reservation order partner
external commerce order
corporate group order
preorder channel

Delivery orders may have different payment, settlement, cancellation, and fulfillment logic.

The adapter must not assume delivery app paid status equals immediate store settlement.

Integration target:

external order intake
fulfillment status
cancellation status
pickup status
payment visibility
settlement uncertainty flag

---

## **9\. Layer 5: Legacy And Manual Fallback Environments**

Layer 5 covers stores with no usable API or closed POS environments.

Supported paths may include:

manual order entry
receipt reference entry
CSV import
screen confirmation
customer mobile order overlay
counter dynamic QR overlay
manual kitchen evidence packet
hybrid POS fallback

Layer 5 is important because small stores often have old or closed systems.

The strategic message is:

You do not need to replace your POS first.
The system can begin as an overlay and improve integration later.

---

## **10\. Layer 6: Franchise And Enterprise POS Environments**

Layer 6 targets franchise and enterprise systems.

This layer may require:

formal vendor contract
security review
tenant-level isolation
store-level rollout plan
versioned adapter certification
audit and compliance review
pilot store validation
HQ dashboard integration
support escalation path

Enterprise POS integration should not be rushed.

The goal is repeatable certification, not one-off custom integration.

---

## **11\. Priority Scoring Model**

Each provider should be scored before integration work begins.

Suggested scoring categories:

market reach
target customer overlap
API availability
webhook support
payment status quality
order event quality
KDS relevance
table reference support
menu mapping quality
vendor cooperation likelihood
integration difficulty
security risk
support burden
strategic value
pilot availability

Each category may be scored:

0 \= unknown or not useful
1 \= weak
2 \= moderate
3 \= strong
4 \= high strategic value
5 \= critical priority

The score should guide priority but not replace strategic judgment.

---

## **12\. API Availability Rule**

Providers with usable API or webhook should be prioritized early.

API availability should be classified as:

PUBLIC\_API\_AVAILABLE
PARTNER\_API\_AVAILABLE
DOCUMENTED\_WEBHOOK\_AVAILABLE
POLLING\_ONLY
EXPORT\_ONLY
MANUAL\_ONLY
UNKNOWN

Public API does not automatically mean production readiness.

Partner API may require business development or contract negotiation.

---

## **13\. Payment Relevance Rule**

Payment-capable providers should be prioritized when they support the payment-to-KDS automation loop.

Payment relevance should consider:

payment request creation
payment status callback
virtual account callback
amount verification
refund visibility
settlement visibility
webhook reliability
idempotency support

Providers that can verify payment status are more valuable than providers that only show order data.

---

## **14\. KDS Relevance Rule**

Providers that can improve kitchen release flow should receive higher priority.

KDS relevance should consider:

order-to-kitchen handoff
kitchen status visibility
ticket release state
hold state
remake state
cancellation after preparation
station mapping
delay visibility

If a POS provider cannot support direct KDS integration, the system may still provide KDS projection through the canonical order model.

---

## **15\. Store Adoption Rule**

Integration priority should reflect store adoption impact.

A provider is high priority if it:

is widely used by target restaurants
is common among small business stores
reduces need for POS replacement
supports low-friction pilot
helps owners see labor savings
supports counter bottleneck reduction

The system should prioritize providers that make adoption easier for real stores.

---

## **16\. Technical Risk Rule**

Technical risk must be assessed before each integration.

Risk categories include:

API instability
poor documentation
missing webhook
weak idempotency
unclear payment state
incomplete item data
no table reference
rate limit risk
credential scope risk
vendor support risk
legacy terminal mismatch

High-risk providers may still be important, but they require a narrower pilot.

---

## **17\. Initial Roadmap Recommendation**

The recommended early roadmap is:

Phase 1: Toss Payments or equivalent payment provider
Phase 2: PAYCO or equivalent payment/order provider
Phase 3: internal web order and dynamic QR payment flow
Phase 4: one major POS provider read-only intake
Phase 5: one major POS provider event sync
Phase 6: one table order or kiosk provider
Phase 7: legacy/manual POS overlay
Phase 8: additional major POS providers
Phase 9: certified adapter program

This roadmap balances fast validation and long-term multi-POS expansion.

---

## **18\. Toss And PAYCO Priority Rationale**

Toss and PAYCO-like providers are useful early because they may support documented payment or order-related API paths.

Early integration value:

payment request
payment callback or webhook
payment state normalization
dynamic QR or payment link
customer display update
KDS release trigger
payment failure handling

They help validate the core automation loop before deeper POS integration.

The system must still treat provider documentation, contract, and production approval as separate readiness gates.

---

## **19\. OKPOS And Major POS Priority Rationale**

Major POS providers should be pursued because they unlock real store adoption.

Strategic value:

existing store base
restaurant operation relevance
order and payment authority position
owner reluctance to replace POS
KDS and kitchen integration opportunity
franchise expansion potential

Initial integration should avoid overpromising full authority.

The first target may be:

order intake
payment visibility
item mapping
KDS projection
conflict detection
audit trail

Authority write-back should follow only after capability and contract review.

---

## **20\. Overlay Strategy**

The system should support an overlay strategy for providers that are not ready for deep integration.

Overlay examples:

customer mobile order overlay
counter QR payment overlay
table QR order overlay
manual receipt reference
staff-confirmed POS order
KDS projection separate from POS
payment webhook separate from POS

Overlay strategy allows market entry before full POS integration.

Overlay-originated orders must remain clearly marked.

---

## **21\. Do Not Replace POS First Rule**

The system should not require stores to replace POS first.

The preferred adoption message is:

Keep your current POS.
Start by automating payment confirmation and kitchen release.
Upgrade integration depth over time.

This reduces adoption resistance.

It also allows the system to enter mixed POS environments.

---

## **22\. Provider Integration Decision States**

Each provider should have a roadmap status.

Allowed statuses include:

CANDIDATE
RESEARCHING
API\_REVIEW
BUSINESS\_CONTACT\_REQUIRED
TECHNICAL\_SPIKE
PILOT\_TARGET
INTEGRATION\_IN\_PROGRESS
MVP\_SUPPORTED
PILOT\_SUPPORTED
PRODUCTION\_SUPPORTED
CERTIFIED
DEFERRED
BLOCKED
RETIRED

Provider status must be versioned and auditable.

---

## **23\. Provider Readiness Checklist**

Before integration begins, the provider should be reviewed for:

API documentation
webhook documentation
test environment
credential issuance
rate limits
event types
order model
payment model
cancellation model
refund visibility
table support
menu support
KDS support
support contact
contract requirement
security requirement

If key areas are unknown, provider status should remain:

RESEARCHING

or:

BUSINESS\_CONTACT\_REQUIRED

---

## **24\. Pilot Store Selection Rule**

Provider integration should be tested in pilot stores where operational observation is possible.

Pilot selection should consider:

actual POS provider used
owner cooperation
staff training capacity
order volume
payment flow complexity
KDS use
table order use
takeout/dine-in mix
willingness to report issues

The goal of pilot is not only technical success.

The goal is to observe real operational friction.

---

## **25\. Vendor Contact And Partnership Rule**

Some integrations require vendor cooperation.

Vendor outreach should clarify:

integration purpose
read/write scope
test environment need
webhook support
credential scope
security boundary
store authorization
support path
commercial discussion if required

Vendor partnership must not be assumed until confirmed.

If vendor cooperation is unavailable, the provider may remain in overlay or read-only mode.

---

## **26\. Competitive Strategy Rule**

The system should not compete only by number of POS integrations.

The stronger competitive position is:

many POS integrations
plus
canonical order model
plus
diagnostic error code
plus
replay and reconciliation
plus
fallback evidence
plus
payment-to-KDS automation

Integration count is a sales signal.

Diagnostic reliability is the technical moat.

---

## **27\. Integration Expansion Rule**

A new provider should not be added if the existing adapter framework cannot absorb it cleanly.

Before adding a provider, confirm:

canonical model supports required fields
error codes cover likely failures
capability level is known
source confidence can be assigned
raw payload can be preserved
idempotency can be implemented
audit event can link provider and internal order
fallback path exists

If not, improve the framework before adding the provider.

---

## **28\. Roadmap Phases**

The multi-year roadmap may be structured as:

### **Year 1: Core Loop And Open API Providers**

Toss/PAYCO-like payment integration
dynamic QR payment
payment webhook verification
KDS release
customer display
audit and reconciliation
one adapter skeleton

### **Year 2: Major POS And Table Order Expansion**

major POS read-only intake
major POS event sync
table order provider integration
kiosk intake
menu mapping
diagnostic code stabilization
pilot store observation

### **Year 3: Multi-POS Scaling**

additional major POS providers
legacy overlay
adapter certification scenarios
vendor onboarding checklist
monitoring and replay
support tooling

### **Year 4: Certified Federation Platform**

certified adapter program
deeper authority integration
enterprise/franchise rollout
multi-provider monitoring
advanced reconciliation
integration partner ecosystem

This timeline is directional and must be adjusted based on provider access and pilot results.

---

## **29\. Integration Risk Control**

The roadmap must avoid the following mistakes:

trying to support every POS at once
building provider-specific logic into KDS
building provider-specific logic into Payment Runtime
treating read-only integration as authority integration
promising zero error integration
ignoring legacy POS fallback
ignoring vendor contract limits
ignoring store-level POS version differences

The adapter layer exists to prevent these risks.

---

## **30\. MVP Cutline**

For MVP, the roadmap should support:

provider priority list
provider status tracking
API availability classification
capability target
payment relevance score
KDS relevance score
integration difficulty score
pilot candidate flag
overlay fallback path
roadmap phase assignment

Excluded from MVP:

full vendor partnership portal
automated provider scoring engine
multi-vendor certification marketplace
enterprise contract management
automatic adapter generation
AI provider documentation parser

---

## **31\. Relationship To 04300, 04310, 04320, And 04330**

Document 04300 defines the POS Provider Abstraction and Multi-POS Adapter boundary.

Document 04310 defines the Canonical Order Model and POS Event Normalization policy.

Document 04320 defines POS Adapter Capability Level and Integration Contract policy.

Document 04330 defines POS Adapter Error Code and Diagnostic Message policy.

This document defines which providers should be pursued first and how the roadmap should be staged.

The relationship is:

04300 \= adapter architecture
04310 \= canonical model
04320 \= capability and contract
04330 \= error diagnosis
04340 \= vendor priority and roadmap

---

## **32\. Patent And SaaS Relevance**

This policy supports SaaS expansion because the system can enter heterogeneous store environments without forcing POS replacement.

The strategic structure is:

open API providers first
major POS providers next
table order and kiosk providers after
legacy overlay always available
        ↓
adapter normalization
        ↓
diagnosable POS federation

The competitive value is not merely integrating with many POS systems.

The competitive value is turning POS diversity into a controlled, staged, diagnosable integration strategy.

---

## **33\. Readiness Check**

This policy is ready when:

provider priority is explicit
Toss/PAYCO-like providers are classified as early API targets
major POS providers are classified as strategic targets
legacy POS overlay is preserved
integration level target is defined per provider
API availability is tracked
payment relevance is scored
KDS relevance is scored
pilot store path is identified
vendor partnership uncertainty is visible
roadmap phases are staged
competitive strategy is based on diagnosis, not only integration count

---

## **34\. Summary**

The system should not try to integrate every POS at once.

It should build the core payment-to-KDS automation loop first, then expand through a disciplined provider roadmap.

The winning path is:

start with API-accessible payment providers
connect major POS providers
support table order and kiosk channels
cover legacy POS with overlay fallback
standardize errors and diagnostics
scale into a POS federation platform

The goal is to make many different store systems behave like one diagnosable operational runtime.
