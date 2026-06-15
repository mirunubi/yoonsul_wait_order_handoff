# 11220_Readme_Open_API_Partner_Alliance

Legacy path: $old.

1\. Purpose

This folder defines the Open API, Partner Gateway, external integration, and alliance governance for CatchMenu / Wait Order Handoff.

CatchMenu must not be designed as a closed single-vendor app.

The food service technology market includes reservation platforms, waiting systems, table-order devices, counter POS systems, payment providers, VAN agencies, kiosk vendors, delivery channels, and customer acquisition channels.

These systems are increasingly connected through API keys, external service settings, channel integration, table layout mapping, menu mapping, and POS/order handoff.

CatchMenu should be able to operate both independently and through controlled partner integration.

Core purpose:

Define Open API and Partner Gateway strategy.
Support external POS, table-order, reservation, waiting, kiosk, and payment-adjacent integrations.
Prevent vendor lock-in.
Support channel key and partner authentication.
Support store-scoped integration.
Support menu, table, request, reservation, and order handoff mapping.
Preserve data ownership, consent, audit, failure recovery, and replay.
Build partner alliance without losing CatchMenu authority boundaries.

Korean purpose:

Open API와 Partner Gateway 전략을 정의한다.
외부 POS, 테이블오더, 예약, 대기, 키오스크, 결제 인접 연동을 지원한다.
특정 벤더 종속을 방지한다.
채널 키와 파트너 인증을 지원한다.
매장 단위 연동 범위를 지원한다.
메뉴, 테이블, 요청, 예약, 주문 핸드오프 매핑을 지원한다.
데이터 소유권, 동의, 감사, 장애 복구, 재처리를 보존한다.
CatchMenu의 권한 경계를 잃지 않으면서 제휴 동맹을 구축한다.

2\. Scope

This folder covers:

Open API
Partner Gateway
external POS integration
table-order integration
reservation platform integration
waiting system integration
kiosk integration
channel API key
partner authentication
store-scoped credential
menu mapping
table layout mapping
request/order handoff
reservation/waiting federation
integration sandbox
partner certification
integration failure
degraded operation
replay
data ownership
consent
audit
partner commercial model
alliance governance

This folder does not define:

full POS implementation
full KDS implementation
payment settlement engine
VAN certification
card acquiring settlement
hardware manufacturing
external vendor internal architecture
legal final contract text

Those belong to separate POS, KDS, payment, legal, and partner contract modules.

3\. Core Principle

CatchMenu should be open enough to integrate and strict enough to remain safe.

Core rule:

Open API creates interoperability.
Partner Gateway controls authority.
Integration does not erase ownership, consent, audit, or failure boundaries.

Korean rule:

Open API는 상호 연동성을 만든다.
Partner Gateway는 권한을 통제한다.
연동은 소유권, 동의, 감사, 장애 경계를 지우지 않는다.

4\. Market Context

Existing restaurant technology stacks may include:

reservation platform
waiting platform
table-order hardware
counter POS
VAN-installed POS
kiosk
simple order tablet
delivery app channel
Naver reservation or external reservation channel
payment provider

These systems are often fragmented physically and operationally.

However, market direction increasingly moves toward:

API gateway
channel API key
external service setting inside POS
table layout mapping
menu synchronization
order injection
reservation import
waiting integration
POS-centered control
one-stop merchant console

CatchMenu should recognize this direction without depending on any single vendor.

5\. CatchMenu Strategic Position

CatchMenu should not compete only by becoming another closed POS or hardware table-order vendor.

CatchMenu should position itself as:

QR/NFC guest entry layer
waiting-to-order handoff layer
multilingual request layer
POS-light adoption layer
Partner Gateway integration layer
external reservation/waiting/order bridge
merchant-friendly SaaS console

Core strategic rule:

CatchMenu should start lightweight and integrate outward.

6\. Open API Strategy

CatchMenu Open API may expose controlled interfaces for:

merchant store lookup
menu context read
menu draft submission
request creation
request status update
reservation handoff
waiting handoff
order handoff candidate
table context mapping
support signal
evidence packet reference
usage summary

Open API must not expose unrestricted internal data.

Core rule:

API endpoint must be scoped, authenticated, audited, and purpose-limited.

7\. Partner Gateway

Partner Gateway is the controlled boundary for partner integrations.

Partner Gateway responsibilities:

authenticate partner
validate channel key
validate store scope
validate allowed API action
map external IDs
enforce rate limits
record audit events
generate failure events
support replay
handle degraded operation
preserve evidence

Core rule:

Partner Gateway is the guardrail between CatchMenu and external vendors.

8\. Channel API Key

Channel API Key may represent a partner integration credential.

Channel key should be:

partner-scoped
merchant-scoped
store-scoped
environment-scoped
permission-scoped
rotatable
revocable
audited

Channel key must not be:

global unrestricted authority
merchant ownership proof
payment settlement authority
support evidence unmasking authority
cross-business identity authority

Core rule:

Channel key identifies an integration channel.
Channel key is not unlimited authority.

9\. Partner Authentication

Partner authentication may include:

API key
channel key
OAuth client credential
signed webhook
mTLS later
partner certificate
sandbox credential
production credential

Partner authentication must define:

partner\_id
integration\_id
merchant\_account\_id
merchant\_store\_id
allowed\_actions
environment
expires\_at
revocation\_status

Core rule:

Partner identity must be bound to allowed merchant/store scope.

10\. Store-Scoped Credential

Credential must be scoped to store when possible.

Example:

partner \= table\_order\_vendor\_A
merchant\_store \= store\_001
allowed\_action \= order\_handoff.create

It must not automatically access:

store\_002
other merchant accounts
support evidence
HQ admin API
billing data
Franchise OS data

Core rule:

External integration credential must be store-scoped unless explicitly approved.

11\. External POS Integration

CatchMenu may integrate with external POS systems.

Integration types:

menu import
menu sync
order handoff candidate
order injection request
table layout mapping
payment status reference
receipt reference
order status callback

CatchMenu must distinguish:

request
order candidate
POS accepted order
payment completed
settlement completed

Core rule:

POS integration must not pretend that request equals paid order.

12\. Table-Order Integration

CatchMenu may integrate with table-order vendors.

Integration may include:

table identity
table layout
menu mapping
order item mapping
order status callback
device status
seat/table context

Table-order integration must be mapped to store context.

Core rule:

Table-order device input must be mapped before it becomes POS handoff.

13\. Reservation Platform Integration

CatchMenu may integrate with reservation platforms.

Integration may include:

reservation import
reservation status update
customer arrival signal
waiting list handoff
preorder relation
pickup reservation relation
no-show signal

Reservation integration must not automatically own CatchMenu customer identity.

Core rule:

Reservation import is channel data.
Customer identity ownership must be explicit.

14\. Waiting System Integration

CatchMenu may integrate with waiting systems.

Integration may include:

waiting session
queue number
estimated seating time
guest readiness
preorder while waiting
arrival signal
seating signal
handoff to staff

Core rule:

Waiting signal may guide order preparation.
Waiting signal is not payment authority.

15\. Kiosk Integration

CatchMenu may integrate with kiosk systems later.

Integration may include:

menu sync
order draft
payment reference
pickup number
language preference
guest identity token

Kiosk integration should remain separate from Stage 0 lightweight QR/NFC flow.

Core rule:

Kiosk is one channel.
CatchMenu must not become dependent on kiosk hardware.

16\. Menu Mapping

External systems may have different menu IDs.

Mapping may include:

CatchMenu menu\_item\_id
external\_pos\_menu\_item\_id
external\_table\_order\_item\_id
external\_reservation\_package\_id
option\_mapping
price\_mapping
tax/category mapping if needed
active\_period
mapping\_status

Menu mapping must be versioned.

Core rule:

Menu mapping must be explicit, versioned, and auditable.

17\. Table Layout Mapping

External POS or table-order system may use table layout coordinates or table IDs.

Mapping may include:

CatchMenu table\_context\_id
external\_pos\_table\_id
external\_table\_order\_device\_id
table\_label
layout\_coordinate
zone
active\_period
mapping\_status

Mapping must not be guessed silently.

Core rule:

Table mapping must be explicit before order handoff.

18\. Request And Order Handoff

CatchMenu must distinguish stages:

guest request
store confirmed request
order handoff candidate
external POS accepted order
external POS rejected order
payment completed
settlement completed

Core rule:

Handoff is a controlled transfer.
Handoff is not automatic final authority.

19\. Integration State

Suggested integration states:

NOT\_CONNECTED
CONFIG\_PENDING
CHANNEL\_KEY\_BOUND
MAPPING\_PENDING
SANDBOX\_TESTING
CERTIFICATION\_PENDING
ACTIVE
DEGRADED
SUSPENDED
REVOKED
ERROR\_REVIEW\_REQUIRED

Core rule:

Integration state must be visible and auditable.

20\. Integration Failure

Integration failure may include:

authentication failed
channel key expired
mapping missing
menu item unmapped
table unmapped
partner timeout
POS rejected handoff
duplicate handoff
callback missing
webhook signature invalid
rate limit exceeded

Failures must be recorded.

Core rule:

Integration failure must not silently lose guest/store intent.

21\. Degraded Operation

When integration fails, CatchMenu should degrade safely.

Degraded options:

show request to staff
manual POS entry
owner console warning
support signal
evidence packet
retry candidate
replay queue
disable partner handoff temporarily

Core rule:

Integration failure should degrade to visible manual operation.

22\. Replay

Replay may be used for failed integration handoff.

Replay must preserve:

original request
mapping version
attempt timestamp
partner response
failure reason
retry count
operator action
final outcome

Replay must not duplicate orders.

Core rule:

Replay must be idempotent and traceable.

23\. Partner Sandbox

Partner integrations should pass sandbox testing before production.

Sandbox should verify:

authentication
store scope
menu mapping
table mapping
request handoff
order handoff candidate
failure response
webhook callback
replay safety
audit event

Core rule:

Production integration requires tested partner behavior.

24\. Partner Certification

Partner certification may define readiness levels:

UNTESTED
SANDBOX\_PASSED
LIMITED\_PILOT
PRODUCTION\_APPROVED
SUSPENDED
REVOKED

Certification should be partner and integration-type specific.

Core rule:

Partner approval must be scoped to integration capability.

25\. Data Ownership

Integration must define data ownership.

Questions:

Who owns menu source?
Who owns guest request?
Who owns reservation record?
Who owns POS order?
Who owns payment status?
Who owns support evidence?
Who can export data?
Who can delete or redact data?

Core rule:

Every integrated data flow needs ownership boundary.

26\. Customer Consent

Some integrations may require customer consent.

Examples:

reservation import
customer profile linking
phone number sharing
marketing use
loyalty benefit matching
external channel history

Core rule:

Integration must not expand customer data use without consent or lawful basis.

27\. Merchant Consent

Merchant must approve partner integration for its store.

Merchant consent may include:

partner name
integration type
store scope
data shared
actions allowed
revocation method
start date

Core rule:

Store-scoped partner integration requires merchant approval or authorized HQ setup.

28\. Audit Events

Recommended audit events:

PARTNER\_CREATED
PARTNER\_INTEGRATION\_REQUESTED
CHANNEL\_KEY\_CREATED
CHANNEL\_KEY\_BOUND\_TO\_STORE
CHANNEL\_KEY\_ROTATED
CHANNEL\_KEY\_REVOKED
INTEGRATION\_ACTIVATED
INTEGRATION\_SUSPENDED
MENU\_MAPPING\_CREATED
TABLE\_MAPPING\_CREATED
ORDER\_HANDOFF\_ATTEMPTED
ORDER\_HANDOFF\_ACCEPTED
ORDER\_HANDOFF\_REJECTED
INTEGRATION\_FAILURE\_RECORDED
REPLAY\_ATTEMPTED
REPLAY\_SUCCEEDED
REPLAY\_FAILED
PARTNER\_CERTIFIED
PARTNER\_CERTIFICATION\_REVOKED

Audit fields:

event\_id
partner\_id
integration\_id
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

29\. Failure Events

Example failure codes:

WOH.PARTNER.AUTH.CHANNEL\_KEY\_INVALID
WOH.PARTNER.AUTH.CHANNEL\_KEY\_EXPIRED
WOH.PARTNER.SCOPE.STORE\_SCOPE\_DENIED
WOH.PARTNER.MAPPING.MENU\_ITEM\_MISSING
WOH.PARTNER.MAPPING.TABLE\_MISSING
WOH.PARTNER.HANDOFF.POS\_REJECTED
WOH.PARTNER.HANDOFF.DUPLICATE\_DENIED
WOH.PARTNER.WEBHOOK.SIGNATURE\_INVALID
WOH.PARTNER.REPLAY.IDEMPOTENCY\_REQUIRED
WOH.PARTNER.CERTIFICATION.REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

30\. Support Signals

Support signals may include:

PARTNER\_INTEGRATION\_DOWN
CHANNEL\_KEY\_EXPIRED
MENU\_MAPPING\_MISSING
TABLE\_MAPPING\_MISSING
POS\_HANDOFF\_REJECTED
PARTNER\_TIMEOUT\_SPIKE
REPLAY\_QUEUE\_GROWING
CERTIFICATION\_EXPIRED
MERCHANT\_CONSENT\_MISSING
DATA\_OWNERSHIP\_CONFLICT

Support Signal alerts.

It does not grant partner authority by itself.

31\. Commercial Model

Partner alliance may support:

referral partnership
integration fee
revenue share
merchant-paid add-on
partner-paid channel fee
certified partner marketplace
co-selling agreement

Commercial terms must not override data safety and authority rules.

Core rule:

Commercial alliance does not bypass integration governance.

32\. MVP Requirements

Open API Partner Alliance MVP should support at least:

partner record
integration record
store-scoped channel key
integration status
menu mapping placeholder
table mapping placeholder
order/request handoff candidate event
integration failure event
manual fallback
support signal
audit event
partner sandbox flag
merchant consent record

MVP may defer:

public developer portal
self-service partner onboarding
real-time bidirectional POS sync
advanced payment settlement integration
full certification automation
partner marketplace
complex revenue share settlement
deep customer identity federation

33\. Suggested Conceptual Entities

Suggested entities:

partners
partner\_integrations
partner\_channel\_keys
partner\_store\_scopes
partner\_menu\_mappings
partner\_table\_mappings
partner\_handoff\_events
partner\_webhook\_events
partner\_replay\_queue
partner\_certifications
partner\_consent\_records
partner\_audit\_events
partner\_support\_signals

This document defines policy.

Actual schema may be designed later.

34\. Relationship To Identity Access

Partner integration must use Identity Access for:

partner admin access
HQ approval
merchant consent
channel key creation
credential rotation
sensitive integration action
audit

API key does not replace identity and authority governance.

35\. Relationship To Organization Core

Partner integration references:

merchant\_account
merchant\_store
CatchMenu company
operator responsibility
cross-business boundary

Organization Core owns merchant/store structure.

Partner Gateway consumes it.

36\. Relationship To Stage Runtime

Stage runtime may generate:

request
store confirmation
order handoff candidate
reservation handoff
waiting handoff

Partner Gateway may transfer approved handoff to external systems.

Runtime does not directly trust partner state without mapping and audit.

37\. Relationship To Evidence Packet

Integration evidence should include:

partner\_id
integration\_id
channel key reference
store scope
mapping version
handoff attempt
partner response
failure reason
replay history
operator action

Evidence Packet helps explain integration incidents.

38\. Risk If Skipped

If Open API Partner Alliance governance is skipped, risks include:

CatchMenu becomes isolated from POS/table-order/reservation ecosystem
vendor lock-in increases
partner API key becomes uncontrolled authority
wrong store receives orders
menu or table mapping causes order errors
partner failure loses guest request
duplicate handoff creates duplicate orders
data ownership becomes unclear
merchant consent is missing
future alliance becomes hard

Therefore, Open API and Partner Gateway governance must be designed before deep external integrations.

39\. Final Rule

CatchMenu should integrate outward without losing control.

Final rule:

Open the API carefully.
Authenticate partners.
Scope channel keys by store.
Map menus explicitly.
Map tables explicitly.
Treat handoff as controlled transfer.
Record failures.
Support degraded manual operation.
Replay safely.
Audit every integration authority change.
Do not let partner integration become unlimited authority.
