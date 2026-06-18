# 011230_Readme_Provider_Adapter_Runtime

Legacy path: $old.

1\. Purpose

This folder defines the Provider Adapter Runtime for CatchMenu / Wait Order Handoff.

CatchMenu must actively integrate with available provider APIs such as Toss POS, TossPayments, PAYCO, and future POS, PG, VAN, table-order, kiosk, reservation, and waiting providers.

However, CatchMenu must not hard-code itself into a single provider.

Provider-specific APIs should be wrapped behind controlled adapter contracts.

Core purpose:

Define provider adapter runtime governance.
Support Toss POS and TossPayments integration.
Support PAYCO payment and channel integration.
Prepare generic POS adapter interface.
Prepare generic payment provider adapter interface.
Prepare future POS, VAN, PG, table-order, kiosk, reservation, and waiting provider integration.
Normalize provider-specific menu, order, table, payment, callback, and failure states.
Preserve CatchMenu authority, evidence, replay, audit, and degraded operation boundaries.

Korean purpose:

Provider Adapter Runtime 거버넌스를 정의한다.
Toss POS 및 TossPayments 연동을 지원한다.
PAYCO 결제 및 채널 연동을 지원한다.
Generic POS Adapter Interface를 준비한다.
Generic Payment Provider Adapter Interface를 준비한다.
향후 POS, VAN, PG, 테이블오더, 키오스크, 예약, 대기 제공사 연동을 준비한다.
제공사별 메뉴, 주문, 테이블, 결제, 콜백, 실패 상태를 정규화한다.
CatchMenu의 권한, 증빙, 재처리, 감사, 축소 운영 경계를 보존한다.

2\. Scope

This folder covers:

provider adapter runtime
Toss POS adapter
TossPayments adapter
PAYCO adapter
generic POS adapter
generic payment provider adapter
generic table-order adapter
generic kiosk adapter
provider credential
channel key
secret rotation
menu mapping
table mapping
order handoff
payment state reference
webhook callback
idempotency
replay
provider failure
degraded operation
manual fallback
audit event
support signal
evidence packet

This folder does not define:

provider commercial alliance strategy
partner marketplace
legal partner contract
full POS product
full payment settlement engine
VAN certification process
card acquiring settlement
hardware manufacturing
provider internal architecture

Related folder:

docs/03300\_open\_api\_partner\_alliance/

3\. Relationship To Open API Partner Alliance

Open API Partner Alliance defines external strategy and partner governance.

Provider Adapter Runtime defines runtime implementation boundaries.

03300 Open API Partner Alliance
\= partnership, API openness, certification, alliance governance

03400 Provider Adapter Runtime
\= provider-specific runtime contracts, adapter interfaces, state normalization, callback handling, failure handling

Core rule:

Partner Alliance decides who and why.
Provider Adapter Runtime controls how integration behaves.

Korean rule:

Partner Alliance는 누구와 왜 연결할지를 정한다.
Provider Adapter Runtime은 실제 연동이 어떻게 동작할지를 통제한다.

4\. Core Principle

Provider integration must be active but not provider-dependent.

Core rule:

Toss and PAYCO may be first-class providers.
They must not become the only architecture.

Korean rule:

토스와 페이코는 1차 핵심 연동사가 될 수 있다.
하지만 유일한 아키텍처가 되어서는 안 된다.

Provider-specific logic must stay behind adapter boundaries.

5\. Provider Categories

Provider Adapter Runtime may support these provider categories:

POS\_PROVIDER
PAYMENT\_PROVIDER
PG\_PROVIDER
VAN\_PROVIDER
TABLE\_ORDER\_PROVIDER
KIOSK\_PROVIDER
RESERVATION\_PROVIDER
WAITING\_PROVIDER
DELIVERY\_CHANNEL\_PROVIDER
LOYALTY\_PROVIDER

Initial priority providers:

TOSS\_POS
TOSS\_PAYMENTS
PAYCO

Future providers:

other POS providers
other PG providers
other VAN-connected POS providers
other table-order providers
other reservation providers
other waiting providers
other kiosk providers

6\. First-Class Provider Strategy

Toss and PAYCO should be treated as first-class integration candidates.

This means:

provider-specific policy documents exist
credential handling is designed
adapter capability is mapped
sandbox or test mode is prepared
webhook/callback behavior is understood
failure and replay policy exists
manual fallback is defined

It does not mean:

CatchMenu depends only on Toss
CatchMenu depends only on PAYCO
CatchMenu state model copies provider state directly
provider response overrides CatchMenu authority

Core rule:

First-class provider means prioritized adapter support, not architectural dependency.

7\. Generic Adapter Contract

Every provider adapter should implement or map to a generic CatchMenu adapter contract.

Generic contract areas:

provider identity
merchant/store binding
credential validation
capability declaration
menu mapping
table mapping
request/order handoff
payment reference
callback handling
idempotency key
replay support
failure normalization
audit event
support signal

Core rule:

Provider-specific APIs must normalize into CatchMenu contracts.

8\. Capability Declaration

Not every provider supports every capability.

Each provider adapter should declare capabilities.

Suggested capabilities:

MENU\_IMPORT
MENU\_SYNC
TABLE\_LAYOUT\_READ
TABLE\_MAPPING
ORDER\_HANDOFF\_CREATE
ORDER\_STATUS\_CALLBACK
PAYMENT\_AUTHORIZE
PAYMENT\_CANCEL
PAYMENT\_STATUS\_READ
SETTLEMENT\_REFERENCE\_READ
WEBHOOK\_CALLBACK
RESERVATION\_IMPORT
WAITING\_IMPORT
KIOSK\_ORDER\_REFERENCE
REPLAY\_SUPPORTED
SANDBOX\_SUPPORTED

Core rule:

Adapter capability must be explicit.
Do not assume provider ability.

9\. Provider State Normalization

Provider states may differ.

CatchMenu should normalize provider states into internal reference states.

Examples:

provider\_order\_created
provider\_order\_accepted
provider\_order\_rejected
provider\_payment\_authorized
provider\_payment\_cancelled
provider\_payment\_failed
provider\_callback\_received
provider\_callback\_invalid
provider\_settlement\_referenced

Provider state must not replace CatchMenu state.

Core rule:

Provider state is external evidence.
CatchMenu state remains governed internally.

10\. Request, Order, Payment, Settlement Separation

CatchMenu must keep these concepts separate:

CatchMenu request
POS order
provider order
payment authorization
payment capture
payment cancellation
settlement
food preparation
pickup completion

Prohibited assumptions:

CatchMenu request \= POS order
POS accepted \= payment completed
payment authorized \= food prepared
payment cancelled \= reservation cancelled
provider webhook \= final settlement

Core rule:

Do not collapse request, order, payment, settlement, and fulfillment.

11\. Toss POS Adapter

Toss POS Adapter should handle Toss POS-specific integration behavior.

Potential integration areas:

POS menu reference
POS order handoff
sales/order data synchronization
external service configuration
store binding
callback or polling if available
provider response normalization

Toss POS Adapter must map Toss-specific behavior into CatchMenu generic adapter contract.

Core rule:

Toss POS Adapter translates Toss POS behavior into CatchMenu provider contract.

Detailed policy belongs to:

03410\_Toss\_POS\_And\_TossPayments\_Adapter\_Policy.md

12\. TossPayments Adapter

TossPayments Adapter should handle TossPayments-specific payment behavior.

Potential integration areas:

payment authorization
payment confirmation
payment cancellation
payment status read
transaction reference
receipt/reference handling
webhook/callback if used
failure normalization

TossPayments Adapter must not decide store preparation or no-show policy.

Core rule:

Payment provider confirms payment state.
CatchMenu governs reservation, preparation, request, and refund workflow state.

13\. PAYCO Adapter

PAYCO Adapter should handle PAYCO-specific payment and channel behavior.

Potential integration areas:

PAYCO payment request
payment approval
payment cancellation
payment status read
channel key or merchant credential handling
mobile payment flow
receipt/reference handling
callback handling
failure normalization

PAYCO Adapter must map PAYCO-specific response into CatchMenu generic payment adapter contract.

Detailed policy belongs to:

03420\_PAYCO\_Payment\_And\_Channel\_Adapter\_Policy.md

14\. Generic POS Adapter

Generic POS Adapter defines the minimum POS-facing interface for future POS providers.

It should support:

provider\_store\_binding
menu\_mapping
table\_mapping optional
order\_handoff\_candidate
order\_acceptance\_response
order\_rejection\_response
order\_status\_reference
manual\_fallback
idempotency
replay
audit

Core rule:

Future POS providers should plug into Generic POS Adapter before custom logic is added.

15\. Generic Payment Adapter

Generic Payment Adapter defines the minimum payment-facing interface for future payment providers.

It should support:

payment\_request
payment\_authorization
payment\_confirmation
payment\_cancellation
payment\_status\_read
refund\_request if applicable
transaction\_reference
callback\_validation
idempotency
failure\_normalization
audit

Core rule:

Payment provider adapter handles payment facts, not business finality.

16\. Generic Table-Order Adapter

Generic Table-Order Adapter may support future table-order device integration.

It may support:

table\_identity
device\_identity
menu\_mapping
order\_item\_mapping
table\_layout\_mapping
order\_input\_event
order\_status\_callback
POS handoff reference

Core rule:

Table-order adapter should not bypass POS or CatchMenu state guards.

17\. Provider Credential

Provider credentials may include:

API key
channel key
client id
client secret
merchant id
store id
webhook secret
OAuth credential
test credential
production credential

Credentials must be:

store-scoped where possible
environment-scoped
rotatable
revocable
audited
masked in UI
never exposed to guest

Core rule:

Provider credential is integration authority.
It must be protected and scoped.

18\. Channel Key Binding

Channel key binding connects a provider credential to a merchant/store/integration context.

Binding should include:

provider\_id
integration\_id
merchant\_account\_id
merchant\_store\_id
credential\_ref
environment
allowed\_capabilities
status
created\_by
created\_at

Binding must not be global by default.

Core rule:

Channel key must bind to specific integration scope.

19\. Secret Rotation

Provider secrets must support rotation.

Rotation events:

secret\_created
secret\_activated
secret\_rotated
secret\_deactivated
secret\_revoked
secret\_expired

Rotation must avoid uncontrolled downtime where possible.

Core rule:

Secrets must be replaceable without rewriting business logic.

20\. Environment Separation

Provider adapter must separate environments.

Suggested environments:

SANDBOX
STAGING
PILOT
PRODUCTION
DISABLED

Test credentials must not access production merchants.

Production credentials must not be used in local test.

Core rule:

Environment mismatch must fail closed.

21\. Menu Mapping Normalization

Provider menu mapping should normalize provider item IDs into CatchMenu menu context.

Mapping may include:

catchmenu\_menu\_item\_id
provider\_menu\_item\_id
provider\_option\_id
price\_mapping
category\_mapping
active\_period
mapping\_version
mapping\_status

Mapping must be versioned and auditable.

Core rule:

Menu mapping is operational authority.
It must not be guessed silently.

22\. Table Mapping Normalization

Provider table mapping should normalize provider table IDs or coordinates into CatchMenu table context when needed.

Mapping may include:

catchmenu\_table\_context\_id
provider\_table\_id
provider\_table\_label
layout\_coordinate
zone
active\_period
mapping\_version
mapping\_status

Core rule:

Table mapping must be explicit before table-specific handoff.

23\. Order Handoff Normalization

Provider order handoff should normalize request/order data.

Handoff record may include:

catchmenu\_request\_id
handoff\_id
provider\_id
provider\_order\_ref
merchant\_store\_id
menu\_mapping\_version
table\_mapping\_version
handoff\_status
attempt\_count
last\_attempt\_at
provider\_response

Core rule:

Order handoff must be idempotent, mapped, and auditable.

24\. Payment State Normalization

Provider payment states should normalize into CatchMenu payment references.

Suggested normalized states:

PAYMENT\_NOT\_REQUESTED
PAYMENT\_REQUESTED
PAYMENT\_AUTHORIZED
PAYMENT\_CONFIRMED
PAYMENT\_FAILED
PAYMENT\_CANCEL\_REQUESTED
PAYMENT\_CANCELLED
PAYMENT\_REFUND\_REQUESTED
PAYMENT\_REFUNDED
PAYMENT\_STATUS\_UNKNOWN
SUPPORT\_REVIEW\_REQUIRED

Core rule:

Payment state is provider-derived reference.
Business workflow must still evaluate reservation, order, and fulfillment state.

25\. Webhook And Callback

Provider callbacks must be validated.

Validation may include:

signature check
timestamp check
idempotency key
provider event id
store binding
environment check
duplicate detection
payload schema validation

Core rule:

Provider callback must be verified before state reference is accepted.

26\. Idempotency

Provider adapter operations must use idempotency where possible.

Idempotency is required for:

payment request
payment cancellation
order handoff
reservation handoff
replay
callback processing

Core rule:

Retry must not create duplicate order or duplicate payment.

27\. Replay

Replay may be used after provider failure.

Replay must preserve:

original request
provider
adapter version
mapping version
attempt history
failure reason
idempotency key
operator action if manual
final outcome

Replay must not bypass authority or create duplicate provider-side actions.

Core rule:

Replay must be traceable and idempotent.

28\. Provider Failure

Provider failure may include:

credential invalid
channel key expired
environment mismatch
menu mapping missing
table mapping missing
provider timeout
provider rejected order
payment failed
callback invalid
duplicate event
rate limit exceeded
provider unavailable

Provider failure must create failure event.

Core rule:

Provider failure must not silently erase guest or store intent.

29\. Degraded Operation

When provider adapter fails, CatchMenu should degrade safely.

Possible degraded modes:

manual POS entry
show-to-staff view
owner console warning
request board fallback
payment status unknown warning
support signal
evidence packet
replay queue
temporary provider handoff suspension

Core rule:

Adapter failure should fall back to visible manual operation.

30\. Manual Fallback

Manual fallback may be required when provider integration fails.

Fallback should preserve:

original request
failed provider action
operator who handled manually
manual POS entry note if applicable
payment status note if applicable
customer communication note
final outcome

Core rule:

Manual fallback must be recorded, not invisible.

31\. Evidence Packet

Provider Adapter Evidence Packet should include:

provider\_id
adapter\_type
integration\_id
credential reference masked
merchant\_store\_id
mapping version
request/order/payment reference
provider response
callback event
failure event
replay history
manual fallback note
audit event

Core rule:

Provider evidence explains what the external provider did and what CatchMenu accepted.

32\. Audit Events

Recommended audit events:

PROVIDER\_ADAPTER\_CREATED
PROVIDER\_ADAPTER\_ENABLED
PROVIDER\_ADAPTER\_DISABLED
PROVIDER\_CREDENTIAL\_CREATED
PROVIDER\_CREDENTIAL\_ROTATED
PROVIDER\_CREDENTIAL\_REVOKED
PROVIDER\_CHANNEL\_BOUND\_TO\_STORE
PROVIDER\_CAPABILITY\_ENABLED
PROVIDER\_CAPABILITY\_DISABLED
PROVIDER\_MENU\_MAPPING\_CREATED
PROVIDER\_TABLE\_MAPPING\_CREATED
PROVIDER\_HANDOFF\_ATTEMPTED
PROVIDER\_HANDOFF\_ACCEPTED
PROVIDER\_HANDOFF\_REJECTED
PROVIDER\_PAYMENT\_STATE\_RECEIVED
PROVIDER\_CALLBACK\_RECEIVED
PROVIDER\_CALLBACK\_REJECTED
PROVIDER\_REPLAY\_ATTEMPTED
PROVIDER\_REPLAY\_SUCCEEDED
PROVIDER\_REPLAY\_FAILED
PROVIDER\_MANUAL\_FALLBACK\_USED

Minimum audit fields:

event\_id
provider\_id
adapter\_id
merchant\_account\_id
merchant\_store\_id
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

WOH.PROVIDER.AUTH.CREDENTIAL\_INVALID
WOH.PROVIDER.AUTH.CHANNEL\_KEY\_EXPIRED
WOH.PROVIDER.ENV.MISMATCH\_DENIED
WOH.PROVIDER.MAPPING.MENU\_MISSING
WOH.PROVIDER.MAPPING.TABLE\_MISSING
WOH.PROVIDER.HANDOFF.REJECTED
WOH.PROVIDER.HANDOFF.DUPLICATE\_DENIED
WOH.PROVIDER.PAYMENT.FAILED
WOH.PROVIDER.CALLBACK.SIGNATURE\_INVALID
WOH.PROVIDER.CALLBACK.DUPLICATE\_IGNORED
WOH.PROVIDER.REPLAY.IDEMPOTENCY\_REQUIRED
WOH.PROVIDER.DEGRADED.MANUAL\_FALLBACK\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

34\. Support Signals

Support signals may include:

PROVIDER\_ADAPTER\_DOWN
PROVIDER\_CREDENTIAL\_EXPIRED
PROVIDER\_MENU\_MAPPING\_MISSING
PROVIDER\_TABLE\_MAPPING\_MISSING
PROVIDER\_HANDOFF\_REJECTED
PROVIDER\_PAYMENT\_STATUS\_UNKNOWN
PROVIDER\_CALLBACK\_INVALID
PROVIDER\_REPLAY\_QUEUE\_GROWING
PROVIDER\_FAILURE\_SPIKE
PROVIDER\_MANUAL\_FALLBACK\_USED

Support Signal alerts.

It does not mutate provider state by itself.

35\. Relationship To Identity Access

Provider adapter actions require proper authority.

Identity Access controls:

who can create provider credential
who can bind channel key
who can enable provider capability
who can rotate secret
who can replay failed handoff
who can view provider evidence
who can disable provider integration

Core rule:

Provider credential management is sensitive admin authority.

36\. Relationship To Organization Core

Provider Adapter Runtime references:

CatchMenu company
merchant\_account
merchant\_store
operator responsibility
cross-business link if needed

Organization Core owns merchant/store structure.

Provider Adapter consumes it.

37\. Relationship To Stage Runtime

Stage Runtime may create:

guest request
store confirmed request
order handoff candidate
reservation relation
waiting relation

Provider Adapter may transmit or receive provider-side results.

Core rule:

Stage Runtime owns CatchMenu flow.
Provider Adapter owns external provider translation.

38\. Relationship To Reservation Preorder Governance

Reservation and preorder flows may use payment provider adapters.

Examples:

prepaid pickup payment
reservation deposit
refund request
payment cancellation
no-show dispute reference

Provider payment state must not alone decide refund or no-show.

Core rule:

Payment adapter provides payment fact.
Reservation governance decides business outcome.

39\. Relationship To Open API Partner Alliance

Open API Partner Alliance governs:

partner eligibility
certification
sandbox
commercial model
merchant consent
alliance policy

Provider Adapter Runtime governs:

runtime contract
provider state normalization
callback handling
credential handling
replay
failure
degraded operation

40\. MVP Requirements

Provider Adapter Runtime MVP should support at least:

provider registry
adapter type
Toss POS adapter placeholder
TossPayments adapter placeholder
PAYCO adapter placeholder
generic POS adapter contract
generic payment adapter contract
provider credential reference
store-scoped binding
capability declaration
menu mapping placeholder
order handoff event
payment state reference
callback event placeholder
idempotency key
failure event
support signal
manual fallback
audit event

MVP may defer:

full automated POS sync
deep payment settlement
multi-provider routing
advanced reconciliation engine
external developer portal
self-service provider onboarding
full certification automation
real-time table-order hardware integration

41\. Suggested Conceptual Entities

Suggested entities:

providers
provider\_adapters
provider\_capabilities
provider\_credentials
provider\_store\_bindings
provider\_menu\_mappings
provider\_table\_mappings
provider\_handoff\_events
provider\_payment\_events
provider\_callback\_events
provider\_replay\_queue
provider\_failure\_events
provider\_support\_signals
provider\_audit\_events

This document defines policy.

Actual schema may be designed later.

42\. Risk If Skipped

If Provider Adapter Runtime is skipped, risks include:

Toss integration becomes hard-coded
PAYCO integration becomes separate one-off logic
future POS integration requires rewrite
provider failure loses customer request
duplicate payment or duplicate order occurs
menu mapping causes wrong order
table mapping routes order to wrong table
provider callback changes state without validation
manual fallback is not recorded
audit cannot explain external integration behavior

Therefore, Provider Adapter Runtime is required before deep Toss, PAYCO, POS, or payment integration.

43\. Final Rule

CatchMenu should integrate with Toss, PAYCO, and future providers through controlled adapters.

Final rule:

Prioritize Toss and PAYCO.
Do not hard-code only Toss and PAYCO.
Define generic adapter contracts.
Bind credentials by store.
Declare provider capabilities.
Normalize provider states.
Separate request, order, payment, settlement, and fulfillment.
Validate callbacks.
Use idempotency.
Replay safely.
Degrade to manual operation.
Audit every sensitive provider action.
