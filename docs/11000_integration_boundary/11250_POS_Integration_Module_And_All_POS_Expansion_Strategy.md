03510 POS Integration Module And All-POS Expansion Strategy

Legacy path: $old.

1\. Purpose

This document defines the POS Integration Module and All-POS Expansion Strategy for CatchMenu / Wait Order Handoff.

CatchMenu must not treat external POS integration as a one-time custom connector for a single provider.

CatchMenu must define a reusable POS Integration Module that can support multiple POS providers over time through provider-specific adapters, provider-neutral contracts, store-scoped binding, capability declaration, menu/table/order mapping, callback validation, idempotency, replay, manual fallback, support signal, and audit.

The long-term goal is broad POS compatibility.

This does not mean every POS is already supported.

It means the architecture must be ready to add POS providers progressively without rewriting CatchMenu service logic.

Core purpose:

Define POS Integration Module strategy.
Define all-POS expansion direction.
Prevent one-off POS connector architecture.
Define progressive provider expansion.
Define priority provider onboarding.
Define provider-neutral internal contract.
Define provider-specific adapter boundary.
Define store-scoped POS binding.
Define capability-driven integration.
Define manual fallback as official interim operation.
Define field claim boundary for all-POS ambition.

Korean purpose:

POS Integration Module 전략을 정의한다.
모든 주요 POS로 확장 가능한 방향을 정의한다.
단발성 POS 커넥터 구조를 방지한다.
POS 제공사 확장 단계를 정의한다.
우선 연동 제공사 온보딩을 정의한다.
제공사 중립 내부 계약을 정의한다.
제공사별 adapter 경계를 정의한다.
매장 단위 POS binding을 정의한다.
기능 지원 여부 기반 연동을 정의한다.
수동 fallback을 공식 중간 운영으로 정의한다.
모든 POS 연동 목표에 대한 현장 설명 경계를 정의한다.

2\. Scope

This document covers:

POS Integration Module
all-POS expansion strategy
POS provider onboarding phases
provider-neutral POS contract
provider-specific adapter strategy
POS capability declaration
store-scoped binding
POS integration mode
POS integration roadmap
provider priority criteria
manual fallback strategy
field claim boundary
integration risk management

This document does not define:

provider-specific API implementation
secret key value
payment provider settlement
KDS implementation
full POS replacement product
tax/accounting ledger
legal partner contract
provider certification contract

Related documents:

03500\_External\_POS\_Integration\_Runtime\_Readme.md
03520\_POS\_Provider\_Adapter\_Contract\_And\_Capability\_Declaration\_Policy.md
03530\_POS\_Menu\_Table\_Order\_Mapping\_And\_Idempotency\_Policy.md
03540\_POS\_Callback\_Replay\_Manual\_Fallback\_And\_Evidence\_Policy.md
03400\_Provider\_Adapter\_Runtime\_Readme.md
03600\_Billing\_Plan\_Settlement\_Readme.md
03800\_Native\_All\_In\_One\_Service\_Runtime\_Readme.md
03950\_POS\_Manual\_Fallback\_Training\_And\_Store\_Usage\_Policy.md

3\. Core Principle

POS integration must be modular, provider-neutral internally, and provider-specific only at adapter boundary.

Core rule:

Build one POS Integration Module.
Add many POS providers through adapters.
Do not rewrite CatchMenu service logic for each POS.

Korean rule:

하나의 POS Integration Module을 만든다.
여러 POS 제공사는 adapter로 추가한다.
POS 제공사마다 CatchMenu 서비스 로직을 다시 만들지 않는다.

4\. Why POS Integration Module Is Required

Restaurant operation is POS-centered.

Without POS integration, CatchMenu may create:

staff duplicate entry
order omission risk
menu mismatch
table mismatch
payment reference confusion
support diagnosis difficulty
medium/large store adoption barrier
KDS handoff weakness

However, forcing POS replacement creates:

merchant resistance
high switching cost
long onboarding delay
device replacement cost
training burden
sales friction

Therefore, CatchMenu needs modular POS integration.

Core rule:

Do not force POS replacement.
Do not ignore POS dependency.
Integrate progressively.

5\. POS Integration Module Definition

POS Integration Module is the internal CatchMenu runtime layer that connects CatchMenu service events to external POS providers.

It should sit between:

CatchMenu native service runtime
and
provider-specific POS adapters

Conceptual flow:

CatchMenu request
→ POS handoff candidate
→ POS Integration Module
→ provider-specific adapter
→ external POS
→ provider response/callback
→ POS Integration Module
→ CatchMenu evidence/state reference

Core rule:

POS Integration Module owns integration orchestration.
Provider adapter owns provider translation.

6\. All-POS Expansion Strategy

All-POS expansion means architecture supports progressive addition of major POS providers.

It does not mean all POS providers are already integrated.

All-POS strategy includes:

provider registry
provider capability model
provider adapter contract
store-scoped binding
mapping framework
idempotent handoff
callback validation
replay
manual fallback
support signal
billing add-on reference
certification/readiness process

Core rule:

All-POS ambition is a roadmap and architecture strategy, not an immediate availability claim.

7\. Expansion Phases

Suggested expansion phases:

Phase 0:
No POS integration.
Manual POS fallback.

Phase 1:
Priority POS provider integration.
Example: provider with accessible API, merchant demand, and technical feasibility.

Phase 2:
Additional cloud/mobile POS adapters.

Phase 3:
Regional or legacy POS integration through bridge where feasible.

Phase 4:
Table-order/POS bridge integration.

Phase 5:
Kiosk/POS bridge integration.

Phase 6:
Multi-store and multi-POS enterprise support.

Phase 7:
Deeper POS/KDS/inventory availability sync where provider capabilities allow.

Core rule:

Expand by capability and demand, not by sales promise alone.

8\. Priority Provider Selection

POS provider priority should be based on objective criteria.

Criteria:

API availability
merchant demand
market presence
technical documentation quality
sandbox availability
callback/webhook support
idempotency support
menu/table/order capability
commercial feasibility
support burden
provider partnership openness
security requirements
certification complexity

Core rule:

Provider priority must be decided by demand, feasibility, and operational impact.

9\. Priority Provider Candidate Handling

When a provider is selected as priority, CatchMenu should create provider onboarding record.

Provider onboarding should include:

provider name
provider type
available API scope
supported capabilities
required credentials
sandbox status
documentation status
commercial contact
technical contact
security review
mapping requirements
callback requirements
billing implications
support implications

Core rule:

No provider should be treated as integrated before onboarding evidence exists.

10\. Provider-Neutral Internal Contract

CatchMenu internal service logic should talk to a provider-neutral POS contract.

Contract concepts:

provider
store binding
capability
menu mapping
table mapping
handoff candidate
handoff attempt
handoff result
callback event
replay event
manual fallback event
evidence packet

Core rule:

CatchMenu service logic must depend on internal contract, not external POS API shape.

11\. Provider-Specific Adapter

Provider-specific adapter should handle provider details.

Adapter concerns:

authentication format
endpoint URL
payload shape
menu format
table format
order format
status codes
error codes
callback signature
rate limit
retry guidance
provider-specific constraints

Adapter must not own:

CatchMenu request lifecycle
billing entitlement
reservation/preorder policy
support case finality
KDS execution truth

Core rule:

Provider adapter translates differences but does not own CatchMenu business state.

12\. Store-Scoped Binding

Every POS integration must be bound at store scope.

Binding should include:

merchant\_account\_id
merchant\_store\_id
provider\_id
provider\_store\_id
integration\_mode
capability\_set
credential\_reference
status
created\_at
updated\_at

Core rule:

A provider being supported does not mean every store is connected.

13\. Capability-Driven Integration

Integration must be capability-driven.

Possible capabilities:

MENU\_IMPORT
MENU\_SYNC
TABLE\_IMPORT
TABLE\_SYNC
ORDER\_INJECTION
ORDER\_STATUS\_SYNC
PAYMENT\_REFERENCE\_SYNC
CANCEL\_SYNC
REFUND\_REFERENCE\_SYNC
CALLBACK\_SUPPORTED
WEBHOOK\_SUPPORTED
IDEMPOTENCY\_SUPPORTED
REPLAY\_SUPPORTED
MANUAL\_FALLBACK\_REQUIRED

Core rule:

Enable only the features supported by the provider and store binding.

14\. Integration Mode Strategy

Every store/provider connection must declare integration mode.

Modes:

NO\_POS\_INTEGRATION
MANUAL\_POS\_ENTRY
POS\_MENU\_IMPORT\_ONLY
POS\_TABLE\_IMPORT\_ONLY
POS\_ORDER\_HANDOFF\_CANDIDATE
POS\_ORDER\_INJECTION
POS\_ORDER\_STATUS\_SYNC
POS\_PAYMENT\_REFERENCE\_SYNC
FULL\_POS\_BRIDGE

Core rule:

Integration mode must be explicit before merchant operation depends on it.

15\. POS-Less Start Strategy

POS-less start remains valid.

Suitable cases:

small store
trial stage
menu-only use
show-to-staff use
low request volume
manual POS entry acceptable
no provider integration available
merchant wants low-friction test

Core rule:

POS-less start is market entry strategy, not final architecture.

16\. Manual Fallback Strategy

Manual POS fallback is official interim operation.

Manual fallback must be:

trained
visible
recorded
auditable
reviewed for burden
upgradeable to POS integration signal

Core rule:

Manual fallback is acceptable when explicit.
Hidden duplicate labor is not acceptable.

17\. POS Integration Readiness Signal

CatchMenu should identify when a store needs POS integration.

Readiness signals:

request volume increases
manual POS burden high
staff complains about duplicate entry
order omission risk appears
merchant asks for POS integration
medium/large store
table-level operation needed
preorder flow grows
KDS path becomes relevant

Core rule:

POS integration should follow real operational friction and business value.

18\. KDS Dependency Consideration

POS integration is often upstream of KDS integration.

Possible future path:

CatchMenu request
→ POS handoff candidate
→ POS accepted order
→ KDS handoff candidate
→ kitchen ticket
→ prep/fulfillment status

Core rule:

All-POS expansion must preserve future KDS continuity.

19\. Billing Consideration

POS integration may affect billing.

Billing models may include:

POS integration add-on
per POS-connected store
provider setup fee
custom integration fee
advanced sync fee
support tier
usage-based handoff fee later

Core rule:

POS integration must be entitlement-controlled before it becomes billable.

20\. Provider Certification And Readiness

Some providers may require certification or approval.

Readiness steps may include:

documentation review
sandbox test
security review
callback validation test
menu mapping test
table mapping test
order injection test
failure/retry test
manual fallback test
support runbook
billing impact review
pilot merchant test

Core rule:

Provider readiness must be proven before broad merchant rollout.

21\. Pilot Strategy

Every new POS provider should start with pilot.

Pilot should define:

pilot merchant
provider scope
enabled capabilities
rollback plan
support owner
known limitations
success criteria
failure criteria
pilot duration
expansion decision

Core rule:

No new POS provider should move from first integration directly to broad rollout.

22\. Rollback Strategy

POS integration must support rollback.

Rollback cases:

provider unstable
mapping errors
duplicate order risk
callback invalid
merchant complaints
support burden too high
security issue
commercial issue

Rollback options:

disable order injection
switch to handoff candidate only
switch to manual POS fallback
suspend provider binding
pause new provider rollout
retain evidence

Core rule:

Rollback must protect merchant operation and CatchMenu evidence.

23\. Overclaim Prevention

All-POS expansion is attractive but risky.

Field/sales/support must not claim:

all POS already integrated
integration always free
integration always immediate
no setup required
no mapping required
no failure possible
POS and CatchMenu state are always identical

Allowed claim:

CatchMenu is designed with a POS Integration Module so major POS providers can be added progressively through provider adapters.

Korean allowed claim:

CatchMenu는 주요 POS 제공사를 순차적으로 추가할 수 있도록 POS Integration Module과 provider adapter 구조로 설계되어 있습니다.

Core rule:

Architecture direction must not be sold as current availability.

24\. Competitive Positioning

Competitors may emphasize current POS integrations.

CatchMenu position:

Existing leaders may have more current POS connections.
CatchMenu's response is to build a provider-neutral POS Integration Module and expand systematically.
CatchMenu should not pretend to have the same coverage before it does.
CatchMenu should enter through POS-less/lightweight trial and upgrade where POS integration creates value.

Korean positioning:

기존 선두 업체는 현재 POS 연동 수가 더 많을 수 있다.
CatchMenu의 대응은 provider-neutral POS Integration Module을 만들고 체계적으로 확장하는 것이다.
동일한 연동 범위를 이미 갖춘 것처럼 말해서는 안 된다.
CatchMenu는 POS-less/lightweight trial로 진입하고, POS 연동 가치가 확인되는 매장부터 확장한다.

25\. Data And Event Advantage

A modular POS strategy should feed unified CatchMenu event model.

Events may include:

pos\_provider\_registered
pos\_binding\_created
pos\_capability\_declared
pos\_mapping\_created
pos\_handoff\_candidate\_created
pos\_handoff\_attempted
pos\_handoff\_accepted
pos\_handoff\_rejected
pos\_callback\_received
pos\_replay\_requested
manual\_pos\_fallback\_marked

Core rule:

POS integration events become long-term operating intelligence.

26\. Audit Requirements

All sensitive POS integration actions must be audited.

Audit required for:

provider registration
capability update
credential reference creation
store binding creation
binding status change
mapping creation
mapping update
handoff attempt
handoff result
callback validation
replay
manual fallback
rollback

Core rule:

POS integration without audit cannot be trusted in merchant disputes.

27\. Support Requirements

POS integration must have support path.

Support cases may include:

provider credential issue
mapping issue
handoff failure
callback delay
duplicate order concern
manual fallback burden
provider outage
merchant misunderstanding

Core rule:

Every POS integration path must include support and fallback path.

28\. MVP Requirements

POS Integration Module MVP should support at least:

provider registry placeholder
provider capability model
store-scoped binding placeholder
integration mode
manual POS fallback
handoff candidate concept
idempotency key
mapping placeholder
failure event
support signal
audit event
field claim boundary
pilot provider readiness checklist

MVP may defer:

full automatic order injection
full status sync
payment reference sync
multi-provider certification automation
legacy POS bridge
advanced replay engine
multi-POS enterprise orchestration

29\. Suggested Conceptual Entities

Suggested entities:

pos\_integration\_modules
pos\_providers
pos\_provider\_onboarding\_records
pos\_provider\_capability\_sets
pos\_store\_bindings
pos\_integration\_modes
pos\_provider\_adapters
pos\_pilot\_records
pos\_rollout\_records
pos\_integration\_audit\_events
pos\_integration\_support\_signals

This document defines strategy.

Actual schema may be designed later.

30\. Risk If Skipped

If POS Integration Module strategy is skipped, risks include:

one-off POS integrations create technical debt
provider API differences leak into core logic
all-POS expansion becomes impossible
sales overpromises POS support
manual fallback burden remains hidden
KDS path becomes weak
billing cannot price POS add-ons clearly
support cannot diagnose provider failures
medium/large stores reject CatchMenu

Therefore, POS integration must be designed as modular expansion architecture before broad field sales.

31\. Final Rule

CatchMenu must treat POS integration as a progressive, modular, provider-neutral expansion path.

Final rule:

Build POS Integration Module.
Do not build one-off POS shortcuts.
Start POS-less when needed.
Use manual fallback explicitly.
Prioritize providers by demand and feasibility.
Add providers through adapters.
Use provider-neutral internal contract.
Declare capabilities.
Bind by store.
Pilot before rollout.
Support rollback.
Control field claims.
Preserve audit and evidence.
Use POS integration to scale from lightweight trial to serious restaurant operation.
