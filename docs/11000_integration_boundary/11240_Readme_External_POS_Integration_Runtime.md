# 11240_Readme_External_POS_Integration_Runtime

Legacy path: $old.

1\. Purpose

This folder defines the External POS Integration Runtime for CatchMenu / Wait Order Handoff.

CatchMenu is designed as a native all-in-one restaurant service, but real restaurant operation is still strongly shaped by existing POS systems.

Most merchants already use a POS system for order entry, payment reference, sales tracking, receipt, table status, cash drawer, tax reference, and operational reporting.

Therefore, CatchMenu must not assume that merchants will replace their POS at the beginning.

CatchMenu must support POS-less or manual fallback operation during early adoption, while also building a dedicated POS Integration Module and provider adapter architecture to progressively connect with major POS providers over time.

Core purpose:

Define External POS Integration Runtime.
Define POS Integration Module strategy.
Define all-POS expansion direction.
Define provider-neutral POS contract.
Define provider-specific adapter boundary.
Define menu, table, order, payment reference, callback, replay, fallback, evidence, and audit rules.
Define how CatchMenu request becomes POS handoff candidate.
Define how external POS remains compatibility layer, not CatchMenu product identity.
Prepare for progressive POS provider expansion.
Prevent one-off hard-coded POS integration.

Korean purpose:

External POS Integration Runtime을 정의한다.
POS Integration Module 전략을 정의한다.
모든 주요 POS로 확장 가능한 방향을 정의한다.
제공사 중립 POS 계약을 정의한다.
제공사별 어댑터 경계를 정의한다.
메뉴, 테이블, 주문, 결제 참조, 콜백, 재처리, fallback, 증빙, 감사 규칙을 정의한다.
CatchMenu 요청이 POS 핸드오프 후보가 되는 방식을 정의한다.
외부 POS가 호환성 레이어이지 CatchMenu 제품 정체성이 아님을 정의한다.
POS 제공사 확장을 단계적으로 준비한다.
특정 POS에 맞춘 단발성 hard-coded 연동을 방지한다.

2\. Scope

This folder covers:

external POS integration
POS Integration Module
all-POS expansion strategy
provider-neutral POS contract
provider adapter
POS capability declaration
store-scoped POS binding
POS credential reference
menu mapping
option mapping
table mapping
order handoff candidate
POS order injection if supported
POS acceptance/rejection
POS payment reference sync if supported
POS status sync if supported
callback validation
idempotency
replay
manual POS fallback
degraded operation
evidence packet
audit event
support signal

This folder does not define:

full internal POS replacement
payment provider execution
VAN settlement
PG settlement
KDS ticket execution
inventory ownership
tax filing
accounting ledger
hardware device manufacturing
provider-specific secret values
legal partner contract

Related folders:

docs/01100\_stage\_0\_entry\_runtime/
docs/03100\_reservation\_preorder\_governance/
docs/03300\_open\_api\_partner\_alliance/
docs/03400\_provider\_adapter\_runtime/
docs/03600\_billing\_plan\_settlement/
docs/03800\_native\_all\_in\_one\_service\_runtime/
docs/03900\_merchant\_success\_troubleshooting/

3\. Core Principle

CatchMenu must be able to start without POS integration, but must be designed to integrate with external POS systems as a mandatory scaling path.

Core rule:

POS-less start is allowed.
Manual POS fallback is allowed.
External POS integration is mandatory scaling architecture.

Korean rule:

POS 없이 시작할 수 있다.
수동 POS fallback을 허용한다.
그러나 외부 POS 연동은 확장을 위한 필수 아키텍처다.

4\. Strategic Position

CatchMenu's external POS position:

Do not force POS replacement at first adoption.
Do not depend on one POS provider.
Do not build one-off custom POS shortcuts.
Build a POS Integration Module.
Add POS providers progressively through adapters.
Normalize provider differences into CatchMenu contracts.
Keep manual fallback available.
Keep event, audit, replay, and evidence from the beginning.

Korean position:

초기 도입 시 POS 교체를 강요하지 않는다.
특정 POS 제공사 하나에 종속되지 않는다.
단발성 POS 맞춤 개발로 처리하지 않는다.
POS Integration Module을 구축한다.
제공사별 adapter를 통해 순차적으로 POS 제공사를 추가한다.
제공사별 차이를 CatchMenu 공통 계약으로 정규화한다.
수동 fallback을 유지한다.
이벤트, 감사, 재처리, 증빙 구조를 처음부터 유지한다.

5\. POS Integration Module Strategy

POS integration must be modular.

CatchMenu must not treat POS integration as an ad-hoc connector.

The POS Integration Module should provide a stable internal interface between CatchMenu service runtime and external POS providers.

Core strategy:

CatchMenu request
→ POS handoff candidate
→ POS Integration Module
→ provider adapter
→ external POS
→ callback/status/reference
→ CatchMenu evidence and state reference

The module should support:

provider registration
provider capability declaration
store-level POS binding
credential/channel key reference
menu mapping
table mapping
order handoff
callback validation
idempotency
replay
manual fallback
audit
support signal

Core rule:

POS integration is a module, not a provider-specific shortcut.

6\. All-POS Expansion Direction

CatchMenu should pursue broad POS compatibility over time.

This does not mean every POS is integrated immediately.

It means CatchMenu architecture must allow progressive POS provider expansion.

Suggested phases:

Phase 0:
POS-less operation and manual POS fallback

Phase 1:
priority POS provider integration where API and business access are available

Phase 2:
additional cloud/mobile POS adapters

Phase 3:
legacy or VAN-connected POS bridge where feasible

Phase 4:
table-order/POS bridge integration

Phase 5:
kiosk/POS bridge integration

Phase 6:
multi-POS and multi-store enterprise support

Core rule:

All-POS ambition is architecture direction, not a current-state sales claim.

7\. Provider-Neutral POS Contract

Every POS provider must map to a provider-neutral CatchMenu POS contract.

The contract should include:

provider\_id
provider\_type
store\_binding
credential\_reference
capability\_declaration
menu\_mapping
option\_mapping
table\_mapping
order\_handoff\_candidate
order\_handoff\_result
order\_acceptance
order\_rejection
payment\_reference if available
status\_reference if available
callback\_validation
idempotency\_key
replay\_reference
manual\_fallback\_reference
audit\_reference
support\_signal\_reference
evidence\_packet\_reference

Core rule:

Provider API differences must not leak into CatchMenu service logic.

8\. Provider Adapter Boundary

Provider adapter translates between CatchMenu contract and provider-specific API.

Provider adapter may handle:

provider endpoint
provider authentication method
channel key
store key
menu payload format
table payload format
order payload format
callback payload format
provider status code
provider error code
rate limit behavior
retry behavior

Provider adapter must not own:

CatchMenu request truth
merchant billing truth
reservation truth
KDS execution truth
support case truth
audit finality

Core rule:

Adapter translates.
Adapter does not own business truth.

9\. POS Capability Declaration

Not every POS provider supports every feature.

Each provider/store binding must declare capabilities.

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

Do only what the provider and store binding explicitly support.

10\. Integration Modes

CatchMenu should support multiple POS integration modes.

Suggested modes:

NO\_POS\_INTEGRATION
MANUAL\_POS\_ENTRY
POS\_MENU\_IMPORT\_ONLY
POS\_TABLE\_IMPORT\_ONLY
POS\_ORDER\_HANDOFF\_CANDIDATE
POS\_ORDER\_INJECTION
POS\_ORDER\_STATUS\_SYNC
POS\_PAYMENT\_REFERENCE\_SYNC
FULL\_POS\_BRIDGE

Meaning:

NO\_POS\_INTEGRATION
\= CatchMenu operates without POS connection

MANUAL\_POS\_ENTRY
\= staff manually enters CatchMenu request into POS

POS\_MENU\_IMPORT\_ONLY
\= POS menu data may be imported or referenced

POS\_TABLE\_IMPORT\_ONLY
\= POS table layout may be imported or referenced

POS\_ORDER\_HANDOFF\_CANDIDATE
\= CatchMenu creates handoff candidate but not automatic POS order

POS\_ORDER\_INJECTION
\= CatchMenu can submit order to POS if supported

POS\_ORDER\_STATUS\_SYNC
\= POS order status can be referenced

POS\_PAYMENT\_REFERENCE\_SYNC
\= POS payment reference can be synced if available

FULL\_POS\_BRIDGE
\= deeper two-way integration under strict guard

Core rule:

Integration mode must be explicit per store and provider.

11\. CatchMenu Request Versus POS Order

CatchMenu request and POS order are not the same.

CatchMenu request
\= guest or merchant-facing service intent

POS order
\= external POS operational/sales order record

A CatchMenu request may become:

manual POS entry
POS handoff candidate
POS order injection
rejected handoff
cancelled request
support review case

Core rule:

CatchMenu request must not be treated as POS order until POS acceptance is confirmed.

12\. POS Handoff Candidate

POS handoff candidate is a controlled intermediate state.

It may contain:

CatchMenu request id
merchant store id
provider binding id
menu mapping reference
table mapping reference
items
options
quantity
notes
critical warning
guest/session reference
idempotency key
created\_at

Core rule:

POS handoff candidate is not proof that POS accepted the order.

13\. POS Order Acceptance

POS order acceptance requires provider confirmation or explicit manual confirmation.

Acceptance evidence may include:

provider order id
provider accepted status
provider timestamp
operator confirmation
manual POS reference
receipt/order number
callback payload

Core rule:

No POS acceptance evidence, no POS order finality.

14\. POS Order Rejection

POS order rejection must be handled explicitly.

Rejection reasons may include:

menu mapping missing
option mapping missing
table mapping missing
provider unavailable
provider timeout
credential invalid
item sold out
order format invalid
provider capability missing
duplicate idempotency conflict

Possible actions:

manual fallback
retry
mapping correction
support signal
merchant notification
request state review

Core rule:

POS rejection must not silently disappear.

15\. Menu Mapping

Menu mapping connects CatchMenu menu items to POS menu items.

Mapping should include:

CatchMenu menu item id
POS item id
provider id
store id
name
price
option group mapping
modifier mapping
tax/category reference if available
mapping status
mapping version

Mapping status:

UNMAPPED
MAPPED
PARTIAL
CONFLICT
REVIEW\_REQUIRED
DEPRECATED

Core rule:

Order injection requires reliable menu mapping.

16\. Option And Modifier Mapping

Options and modifiers are often where POS integration fails.

Mapping should handle:

size option
temperature option
spice level
add-on
set option
required option
optional modifier
free text note
unmapped option

Core rule:

Unmapped required option blocks automatic POS injection.

17\. Table Mapping

Table mapping connects CatchMenu table/seat/waiting context to POS table reference.

Mapping may include:

CatchMenu table id
POS table id
zone
floor
seat count
table status
merge/split handling if supported

Core rule:

Table mapping must be explicit before table-based POS order injection.

18\. Waiting And Preorder Link

Waiting/preorder flow may create POS handoff need.

Possible flow:

waiting registered
menu preselected
preorder created
store reviews
table becomes ready
POS handoff candidate created
POS accepts or manual fallback occurs
KDS path later receives kitchen ticket

Core rule:

Waiting preorder becomes operationally valuable when POS/KDS handoff is controlled.

19\. Reservation And Prepaid Pickup Link

Reservation/prepaid pickup may connect to POS.

Possible POS references:

prepaid pickup order reference
deposit reference
group order reference
pickup time
manual POS entry reference
POS order id if accepted

Core rule:

Reservation/preorder business state remains separate from POS order state.

20\. Payment Reference Sync

POS may provide payment reference if supported.

Payment reference may include:

payment status
receipt number
transaction id
payment time
cancel/refund reference

CatchMenu must not assume provider payment sync exists for every POS.

Core rule:

POS payment reference is optional provider fact, not universal billing truth.

21\. Callback And Webhook Validation

Provider callbacks must be validated.

Validation should include:

provider identity
signature if available
timestamp
store binding
event id
idempotency key
payload schema
status transition validity
replay protection

Core rule:

Unvalidated callback must not mutate CatchMenu state.

22\. Idempotency

POS integration must be idempotent.

Idempotency should prevent:

duplicate POS order
duplicate handoff
duplicate callback processing
duplicate retry result
duplicate manual fallback marking

Core rule:

Retry must not create duplicate order.

23\. Replay

Replay may be required when provider communication fails.

Replay should record:

original request
original provider
original payload
failure reason
retry count
retry time
operator
result
audit event

Replay must not overwrite history.

Core rule:

Replay is append-only recovery, not silent mutation.

24\. Manual POS Fallback

Manual POS fallback is official interim operation.

Manual fallback may occur when:

no POS integration exists
provider unavailable
mapping missing
order injection unsupported
callback failed
merchant prefers manual entry
trial stage is early

Manual fallback should record:

who handled
when handled
POS manual reference if available
request id
items
confirmation
note

Core rule:

Manual fallback is not system failure if it is explicit, trained, and recorded.

25\. Degraded Operation

POS integration failure must not stop the whole CatchMenu service.

Degraded options:

show-to-staff mode
request board only
manual POS entry
owner console warning
support signal
retry queue
provider suspension
mapping review

Core rule:

External POS failure should degrade operation, not erase CatchMenu request truth.

26\. Evidence Packet

POS integration evidence packet may include:

CatchMenu request id
handoff candidate id
provider id
store binding id
menu mapping version
table mapping version
payload
provider response
callback payload
manual fallback note
retry/replay history
failure event
support signal
audit events

Core rule:

POS integration must be explainable after failure.

27\. Store-Scoped POS Binding

POS binding must be scoped by store.

Store-scoped binding may include:

merchant\_store\_id
provider\_id
provider\_store\_id
credential\_reference
integration\_mode
capability\_set
status
created\_at
updated\_at

Core rule:

POS authority must be store-scoped, not globally assumed.

28\. Credential And Channel Key Boundary

Credentials and channel keys must be protected.

Credential references may exist.

Secret values must not be exposed in general runtime screens.

Core rule:

Credential reference is allowed.
Secret exposure is prohibited.

29\. POS Integration Status

Suggested statuses:

NOT\_CONFIGURED
CONFIGURATION\_PENDING
CONFIGURED
ACTIVE
PARTIAL
DEGRADED
FAILED
SUSPENDED
DISCONNECTED
REVIEW\_REQUIRED

Core rule:

POS integration status must be visible to authorized merchant/admin users.

30\. POS Failure Categories

Failure categories:

AUTHENTICATION\_FAILURE
CREDENTIAL\_EXPIRED
PROVIDER\_UNAVAILABLE
RATE\_LIMITED
MENU\_MAPPING\_MISSING
OPTION\_MAPPING\_MISSING
TABLE\_MAPPING\_MISSING
ORDER\_REJECTED
CALLBACK\_INVALID
CALLBACK\_DELAYED
IDEMPOTENCY\_CONFLICT
REPLAY\_REQUIRED
MANUAL\_FALLBACK\_REQUIRED
UNKNOWN\_PROVIDER\_ERROR

Core rule:

Failure category must guide recovery path.

31\. Support Signals

Support signals may include:

POS\_INTEGRATION\_NOT\_CONFIGURED
POS\_PROVIDER\_CREDENTIAL\_REQUIRED
POS\_PROVIDER\_AUTH\_FAILED
POS\_MENU\_MAPPING\_REQUIRED
POS\_TABLE\_MAPPING\_REQUIRED
POS\_ORDER\_HANDOFF\_FAILED
POS\_CALLBACK\_INVALID
POS\_REPLAY\_REQUIRED
MANUAL\_POS\_FALLBACK\_REQUIRED
POS\_PROVIDER\_DEGRADED
POS\_INTEGRATION\_REVIEW\_REQUIRED

Support Signal alerts.

It does not mutate POS state by itself.

32\. Audit Events

Recommended audit events:

POS\_PROVIDER\_REGISTERED
POS\_PROVIDER\_UPDATED
POS\_BINDING\_CREATED
POS\_BINDING\_UPDATED
POS\_BINDING\_SUSPENDED
POS\_BINDING\_DISCONNECTED
POS\_CAPABILITY\_DECLARED
POS\_CREDENTIAL\_REFERENCE\_CREATED
POS\_MENU\_MAPPING\_CREATED
POS\_MENU\_MAPPING\_UPDATED
POS\_TABLE\_MAPPING\_CREATED
POS\_TABLE\_MAPPING\_UPDATED
POS\_HANDOFF\_CANDIDATE\_CREATED
POS\_HANDOFF\_ATTEMPTED
POS\_HANDOFF\_ACCEPTED
POS\_HANDOFF\_REJECTED
POS\_CALLBACK\_RECEIVED
POS\_CALLBACK\_VALIDATED
POS\_CALLBACK\_REJECTED
POS\_REPLAY\_REQUESTED
POS\_REPLAY\_COMPLETED
MANUAL\_POS\_FALLBACK\_MARKED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
provider\_id
pos\_binding\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

33\. Failure Events

Example failure codes:

WOH.POS.PROVIDER.NOT\_CONFIGURED
WOH.POS.PROVIDER.CAPABILITY\_MISSING
WOH.POS.CREDENTIAL.REQUIRED
WOH.POS.CREDENTIAL.INVALID
WOH.POS.MENU\_MAPPING.REQUIRED
WOH.POS.OPTION\_MAPPING.REQUIRED
WOH.POS.TABLE\_MAPPING.REQUIRED
WOH.POS.HANDOFF.REJECTED
WOH.POS.HANDOFF.TIMEOUT
WOH.POS.CALLBACK.INVALID
WOH.POS.CALLBACK.IDEMPOTENCY\_CONFLICT
WOH.POS.REPLAY.REQUIRED
WOH.POS.MANUAL\_FALLBACK.REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

34\. Field Claim Boundary

Field sales and support must describe POS integration accurately.

Allowed claim:

CatchMenu is designed with a modular POS integration architecture so that major POS providers can be added progressively.

Allowed Korean claim:

CatchMenu는 주요 POS 제공사를 순차적으로 연동할 수 있도록 모듈형 POS 연동 구조로 설계됩니다.

Not allowed:

Every POS is already connected.
All POS integrations are guaranteed immediately.
POS integration never needs setup.
POS integration never fails.
POS order and CatchMenu request are the same thing.

Core rule:

All-POS ambition must not become false current-state promise.

35\. Relationship To Provider Adapter Runtime

Provider Adapter Runtime defines provider-level adapter governance across POS, payment, PG, table-order, reservation, and other providers.

External POS Integration Runtime defines POS-specific integration governance.

Core rule:

Provider Adapter translates provider differences.
External POS Integration defines POS business handoff rules.

36\. Relationship To Billing Plan Settlement

POS integration may be billable.

Billing may reference:

POS integration add-on
POS-connected store count
provider-specific setup fee
custom POS integration fee
advanced POS sync feature
support burden

External POS Integration provides integration status and evidence.

Billing decides chargeability.

Core rule:

POS connected status may affect billing only through defined entitlement and plan rule.

37\. Relationship To Native All-In-One Runtime

Native All-In-One Runtime defines CatchMenu service journey.

External POS Integration connects that journey to installed merchant POS infrastructure.

Core rule:

External POS is compatibility layer.
Native service continuity remains product identity.

38\. Relationship To Merchant Success

Merchant Success identifies when manual POS fallback becomes burden and POS integration is needed.

Merchant Success may create:

POS\_INTEGRATION\_INTEREST
MANUAL\_POS\_BURDEN\_HIGH
POS\_PROVIDER\_UNKNOWN
POS\_MAPPING\_SUPPORT\_REQUIRED

Core rule:

Operational friction should guide POS integration priority.

39\. Relationship To KDS Integration Path

POS integration may become the bridge to KDS.

Possible future path:

CatchMenu request
→ POS handoff candidate
→ POS accepted order
→ KDS handoff candidate
→ kitchen ticket
→ preparation status
→ fulfillment status

Core rule:

KDS continuity requires clear POS/order acceptance boundary.

40\. MVP Requirements

External POS Integration MVP should support at least:

integration mode field
manual POS fallback
POS provider registry placeholder
store-scoped POS binding placeholder
provider capability declaration placeholder
menu mapping placeholder
table mapping placeholder
handoff candidate concept
handoff status
idempotency key
failure event
support signal
audit event
evidence packet
field claim boundary

MVP may defer:

full automatic POS order injection
full bidirectional POS sync
payment reference sync
multi-POS enterprise support
legacy VAN bridge
provider certification workflow
advanced replay automation
real-time table sync

41\. Suggested Conceptual Entities

Suggested entities:

pos\_providers
pos\_provider\_capabilities
pos\_store\_bindings
pos\_credentials\_references
pos\_menu\_mappings
pos\_option\_mappings
pos\_table\_mappings
pos\_handoff\_candidates
pos\_handoff\_attempts
pos\_handoff\_results
pos\_callback\_events
pos\_replay\_events
manual\_pos\_fallback\_events
pos\_audit\_events
pos\_failure\_events
pos\_support\_signals

This document defines runtime policy.

Actual schema may be designed later.

42\. Risk If Skipped

If External POS Integration Runtime governance is skipped, risks include:

CatchMenu remains thin QR/menu tool
manual POS burden blocks medium/large stores
provider-specific shortcuts create technical debt
POS integration claims become overpromised
duplicate orders occur
provider callbacks mutate state unsafely
failed handoff disappears
merchant cannot trust request-to-order flow
KDS path lacks reliable POS boundary
billing cannot price POS add-ons clearly
support cannot diagnose POS failures

Therefore, POS integration must be modularized before CatchMenu scales beyond lightweight trial.

43\. Final Rule

CatchMenu must start light but scale into POS-connected operation through modular integration.

Final rule:

Support POS-less start.
Support manual POS fallback.
Build POS integration as a dedicated module.
Do not hard-code one POS provider.
Prioritize available providers first.
Add POS providers through provider-specific adapters.
Normalize every provider into CatchMenu POS contracts.
Declare provider capability.
Bind POS by store.
Map menu explicitly.
Map options explicitly.
Map tables explicitly.
Create POS handoff candidate before POS order.
Validate callback.
Use idempotency.
Replay safely.
Record manual fallback.
Preserve evidence.
Audit every POS handoff.
Pursue broad POS compatibility progressively.
Do not claim unsupported POS integration as already available.
