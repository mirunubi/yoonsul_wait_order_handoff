# 04000_KDS_Integration_Kitchen_Continuity_Readme

1\. Purpose

This folder defines KDS Integration and Kitchen Continuity for CatchMenu / Wait Order Handoff.

KDS is not merely a kitchen display screen.

KDS is the kitchen execution continuity layer that connects guest intent, store confirmation, POS order reference, kitchen preparation, delay handling, remake/retry, ready state, and fulfillment evidence.

CatchMenu may start without KDS integration.

However, the long-term value of waiting-to-order handoff, preorder, group order, reservation pickup, and large-store operation depends on whether kitchen execution can receive the right signal at the right time.

Core purpose:

Define KDS Integration and Kitchen Continuity.
Define KDS as kitchen execution path, not only display.
Define KDS handoff candidate.
Define relationship between CatchMenu request, POS accepted order, and KDS ticket.
Define kitchen preparation status.
Define delay, retry, remake, ready, and fulfillment signals.
Define KDS authority boundary.
Define external KDS and future native KDS path.
Define degraded manual kitchen fallback.
Prevent fake KDS status.

Korean purpose:

KDS Integration과 Kitchen Continuity를 정의한다.
KDS를 단순 표시판이 아니라 주방 실행 경로로 정의한다.
KDS handoff candidate를 정의한다.
CatchMenu 요청, POS accepted order, KDS ticket의 관계를 정의한다.
주방 준비 상태를 정의한다.
지연, retry, remake, ready, fulfillment signal을 정의한다.
KDS authority boundary를 정의한다.
외부 KDS와 향후 자체 KDS 경로를 정의한다.
수동 kitchen fallback을 정의한다.
가짜 KDS status를 방지한다.

2\. Scope

This folder covers:

KDS integration
kitchen continuity
KDS handoff candidate
KDS ticket
kitchen preparation status
POS-to-KDS path
CatchMenu-to-KDS path
preorder-to-kitchen path
reservation/group order kitchen signal
delay signal
remake signal
retry signal
ready signal
fulfillment signal
manual kitchen fallback
external KDS provider integration
future native KDS path
KDS audit
KDS evidence
KDS support signal

This folder does not define:

full KDS UI implementation
kitchen hardware manufacturing
full POS replacement
payment execution
inventory ownership
staff payroll
recipe production system
legal food safety certification

Related folders:

docs/03500\_external\_pos\_integration\_runtime/
docs/03800\_native\_all\_in\_one\_service\_runtime/
docs/03900\_merchant\_success\_troubleshooting/
docs/04100\_menu\_availability\_soldout\_runtime/
docs/03100\_reservation\_preorder\_governance/
docs/03400\_provider\_adapter\_runtime/

3\. Core Principle

KDS is kitchen execution continuity.

Core rule:

KDS is not display.
KDS is kitchen execution continuity.

Korean rule:

KDS는 단순 표시판이 아니다.
KDS는 주방 실행 연속성이다.

4\. KDS Boundary

KDS owns or references kitchen execution state.

KDS may own:

kitchen ticket
prep queue
prep status
ready status
delay signal
remake/retry signal
kitchen completion reference

KDS must not own:

guest request truth
POS sales order truth
payment finality
billing entitlement
reservation cancellation decision
customer refund decision
menu master truth

Core rule:

KDS executes kitchen workflow.
It does not decide commercial finality.

5\. CatchMenu Request Versus KDS Ticket

CatchMenu request and KDS ticket are not the same.

CatchMenu request
\= guest or merchant-facing service intent

KDS ticket
\= kitchen-facing execution unit

A CatchMenu request may become:

manual staff handling
POS handoff candidate
POS accepted order
KDS handoff candidate
KDS ticket
manual kitchen note
support review case

Core rule:

CatchMenu request must not be treated as KDS ticket until kitchen authority accepts it.

6\. POS Accepted Order Versus KDS Ticket

POS accepted order and KDS ticket may be related but separate.

Possible relation:

CatchMenu request
→ POS handoff candidate
→ POS accepted order
→ KDS handoff candidate
→ KDS ticket

But not every store has this chain.

Possible variants:

CatchMenu request → manual POS entry → manual kitchen note
CatchMenu request → POS accepted order → external POS-owned KDS
CatchMenu preorder → store confirmation → future native KDS ticket

Core rule:

KDS path must declare whether it depends on POS acceptance or separate kitchen authority.

7\. KDS Handoff Candidate

KDS handoff candidate is an intermediate state before kitchen ticket finality.

It may include:

kds\_handoff\_candidate\_id
catchmenu\_request\_id
pos\_order\_reference optional
reservation/preorder reference optional
merchant\_store\_id
kitchen\_area
items
options
quantity
prep\_time\_target
critical warning
availability status
idempotency key
created\_at

Core rule:

KDS handoff candidate is not proof that kitchen accepted the ticket.

8\. KDS Ticket

KDS ticket represents accepted kitchen execution unit.

KDS ticket may include:

kds\_ticket\_id
kds\_handoff\_candidate\_id
provider\_ticket\_id optional
kitchen\_station
items
options
quantity
ticket\_status
created\_at
accepted\_at
started\_at
ready\_at
completed\_at

Core rule:

KDS ticket starts kitchen execution tracking.

9\. Kitchen Status

Suggested kitchen statuses:

NOT\_SENT
HANDOFF\_CANDIDATE
SENT\_TO\_KDS
KDS\_ACCEPTED
PREP\_PENDING
PREP\_STARTED
PREP\_DELAYED
READY
SERVED\_OR\_PICKED\_UP
REMAKE\_REQUIRED
RETRY\_REQUIRED
CANCELLED
UNKNOWN
MANUAL\_KITCHEN\_FALLBACK
REVIEW\_REQUIRED

Core rule:

Kitchen status must be visible but must not overstate certainty.

10\. Preorder Kitchen Continuity

Preorder becomes valuable only if kitchen receives timing signal.

Preorder kitchen flow may include:

preorder created
store confirms
availability checked
prep timing estimated
KDS handoff candidate created
kitchen accepts at proper time
prep starts
ready signal produced

Core rule:

Preorder without kitchen continuity may reduce guest wait but increase staff burden.

11\. Waiting-To-Order Kitchen Continuity

Waiting-to-order handoff depends on timing.

Possible flow:

guest joins waiting
guest preselects menu
store sees preorder
table readiness approaches
kitchen prep timing triggered
KDS ticket created
guest seated
food prepared faster

Core rule:

Waiting time becomes preparation time only when kitchen timing is controlled.

12\. Reservation And Group Order Kitchen Signal

Reservation and group order may require earlier kitchen signal.

Examples:

large group order
prepaid pickup
limited menu reservation
scheduled pickup
catering-like preparation

KDS/kitchen signal may include:

prep start time
prep quantity
kitchen station
ready deadline
special note
critical warning

Core rule:

Reservation commitment must connect to preparation state before pickup or seating time.

13\. Menu Availability Dependency

KDS path depends on availability.

Before creating KDS handoff candidate, system should check:

item available
sold-out state
limited quantity
preorder blocked
kitchen capacity warning
manual confirmation required

Core rule:

Do not send unavailable item to kitchen execution path.

14\. External KDS Provider Path

External KDS provider may be integrated through provider adapter.

External KDS path may include:

provider binding
provider capability declaration
ticket creation
ticket status callback
delay status
ready status
failure handling
manual kitchen fallback

Core rule:

External KDS provider fact must be validated before CatchMenu references it.

15\. Native KDS Future Path

CatchMenu may later build native KDS runtime.

Native KDS may include:

kitchen ticket board
station routing
prep queue
delay signal
remake/retry
ready signal
fulfillment evidence
kitchen analytics

Core rule:

Future native KDS should inherit the same authority, audit, and evidence rules.

16\. Manual Kitchen Fallback

Manual kitchen fallback may be required before KDS integration.

Manual fallback may include:

verbal kitchen note
POS printout
paper kitchen note
existing kitchen workflow
request board shown to kitchen

Manual fallback must be recorded when it substitutes for KDS path.

Core rule:

Manual kitchen fallback is acceptable only when visible and understood.

17\. KDS Idempotency

KDS ticket creation must avoid duplicates.

Duplicate risk occurs when:

POS callback delayed
KDS provider timeout
operator retries
manual kitchen fallback already occurred
preorder timing retriggers
provider callback duplicated

Core rule:

Same kitchen handoff candidate must not create duplicate KDS tickets.

18\. KDS Replay

KDS replay may be needed when ticket creation fails.

Replay must check:

idempotency key
current ticket status
manual fallback status
provider capability
availability state
kitchen duplicate risk

Core rule:

KDS replay must not duplicate kitchen work.

19\. Delay Signal

Delay signal may come from:

kitchen overload
KDS prep delayed
ingredient unavailable
POS/KDS handoff delay
manual kitchen fallback delay
staff report

Delay signal may affect:

guest expectation
owner console
support signal
preorder timing
merchant success review

Core rule:

Late kitchen insight has low value unless surfaced quickly.

20\. Remake And Retry

Remake/retry may be required when kitchen execution fails.

Examples:

wrong item
missing option
quality issue
lost ticket
delayed ticket
customer recovery

Core rule:

Remake/retry is kitchen recovery event, not silent ticket overwrite.

21\. Ready And Fulfillment Signal

Ready signal may mean:

food ready for pickup
food ready for serving
kitchen completed prep
order waiting at pass

Fulfillment may mean:

served to table
picked up by customer
handed to staff
cancelled before service

Core rule:

Ready is not always fulfilled.
Fulfillment must be recorded separately where needed.

22\. Kitchen Authority

Kitchen authority may belong to:

external KDS
POS-owned KDS
store staff
kitchen lead
future native CatchMenu KDS

Core rule:

KDS authority must be declared before state is trusted.

23\. KDS Visibility

Different users see different KDS visibility.

Guest may see:

request received
store confirmed
preparing if truly known
ready if truly known

Store may see:

ticket status
prep queue
delay
remake/retry
manual fallback

Support may see:

handoff evidence
provider callback
failure code
manual fallback note
audit trail

Core rule:

Do not expose kitchen status to guest unless status is reliable and intended.

24\. Billing Relation

KDS integration may be billable add-on.

Billing may reference:

KDS-connected store
KDS provider integration
KDS ticket volume
advanced kitchen status feature
custom KDS setup
support tier

Core rule:

KDS billing requires entitlement and actual enabled capability.

25\. Support Signals

Support signals may include:

KDS\_PATH\_REQUIRED
KDS\_HANDOFF\_CANDIDATE\_CREATED
KDS\_HANDOFF\_FAILED
KDS\_TICKET\_DUPLICATE\_RISK
KDS\_PROVIDER\_DEGRADED
KDS\_DELAY\_SIGNAL
KDS\_REMAKE\_REQUIRED
KDS\_RETRY\_REQUIRED
MANUAL\_KITCHEN\_FALLBACK\_REQUIRED
KDS\_STATUS\_UNKNOWN
KDS\_EVIDENCE\_PACKET\_REQUIRED

Support Signal alerts.

It does not mutate KDS state by itself.

26\. Audit Events

Recommended audit events:

KDS\_PATH\_ENABLED
KDS\_PATH\_DISABLED
KDS\_PROVIDER\_BOUND
KDS\_CAPABILITY\_DECLARED
KDS\_HANDOFF\_CANDIDATE\_CREATED
KDS\_HANDOFF\_ATTEMPTED
KDS\_HANDOFF\_ACCEPTED
KDS\_HANDOFF\_REJECTED
KDS\_TICKET\_CREATED
KDS\_STATUS\_UPDATED
KDS\_DELAY\_MARKED
KDS\_READY\_MARKED
KDS\_FULFILLMENT\_MARKED
KDS\_REMAKE\_REQUIRED
KDS\_RETRY\_REQUIRED
MANUAL\_KITCHEN\_FALLBACK\_MARKED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
kds\_provider\_id optional
kds\_ticket\_id optional
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

27\. Failure Events

Example failure codes:

WOH.KDS.PATH.NOT\_READY
WOH.KDS.AUTHORITY.UNDECLARED
WOH.KDS.HANDOFF.CANDIDATE\_REQUIRED
WOH.KDS.HANDOFF.REJECTED
WOH.KDS.TICKET.DUPLICATE\_RISK
WOH.KDS.STATUS.UNKNOWN
WOH.KDS.PROVIDER.DEGRADED
WOH.KDS.AVAILABILITY.REQUIRED
WOH.KDS.MANUAL\_FALLBACK.REQUIRED
WOH.KDS.EVIDENCE.PACKET\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

28\. Relationship To External POS Integration

External POS Integration may be upstream of KDS.

Core rule:

KDS handoff must not assume POS acceptance unless POS acceptance evidence exists.

29\. Relationship To Menu Availability

Menu availability/sold-out runtime should prevent impossible KDS tickets.

Core rule:

Availability must be checked before kitchen execution begins.

30\. Relationship To Merchant Success

Merchant Success identifies KDS readiness.

Signals:

kitchen misses requests
manual kitchen communication burden
preorder prep timing issue
group order complexity
delay visibility needed
large store operation

Core rule:

KDS integration should be driven by real kitchen friction.

31\. MVP Requirements

KDS Integration MVP should support at least:

KDS path declaration
KDS handoff candidate concept
manual kitchen fallback
KDS readiness signal
kitchen status placeholder
delay signal placeholder
KDS support signal
KDS audit event
KDS failure event
POS dependency statement
availability dependency statement

MVP may defer:

full native KDS UI
external KDS provider automation
kitchen station routing
real-time prep status
advanced remake workflow
advanced kitchen analytics
hardware kitchen display

32\. Suggested Conceptual Entities

Suggested entities:

kds\_providers
kds\_provider\_capabilities
kds\_store\_bindings
kds\_handoff\_candidates
kds\_tickets
kds\_status\_events
kds\_delay\_events
kds\_recovery\_events
manual\_kitchen\_fallback\_events
kds\_audit\_events
kds\_failure\_events
kds\_support\_signals

This document defines policy.

Actual schema may be designed later.

33\. Risk If Skipped

If KDS Integration and Kitchen Continuity is skipped, risks include:

waiting preorder does not reduce kitchen lead time
preorder creates staff burden
large stores reject CatchMenu as lightweight only
kitchen misses requests
manual kitchen notes become invisible
ready status is faked
KDS duplicate tickets occur later
POS-to-KDS authority is unclear
guest expectation is overpromised
support cannot diagnose kitchen delays

Therefore, KDS path must be declared before CatchMenu claims full waiting-to-order operational continuity.

34\. Final Rule

KDS is the kitchen execution continuity path.

Final rule:

Do not treat KDS as a screen only.
Define kitchen authority.
Create KDS handoff candidate.
Do not create KDS ticket without authority.
Respect POS acceptance boundary.
Check availability before kitchen execution.
Use manual kitchen fallback when needed.
Avoid duplicate KDS tickets.
Record delay, remake, retry, ready, and fulfillment separately.
Do not expose unreliable kitchen status to guests.
Preserve evidence.
Audit every KDS handoff.
