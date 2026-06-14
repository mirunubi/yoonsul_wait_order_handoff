01160 Stage 0 Request State Transition Guard

1\. Purpose

This document defines the Stage 0 request state transition guard for CatchMenu.

Stage 0 request state must not change freely.

Each state transition must be allowed only when the correct actor, condition, stage, and policy requirement are satisfied.

Core purpose:

Prevent invalid request state changes.
Prevent unconfirmed requests from becoming completed orders.
Preserve request history.
Make failure traceable.

Korean purpose:

잘못된 요청 상태 변경을 막는다.
미확인 요청이 완료 주문으로 바뀌는 것을 막는다.
요청 이력을 보존한다.
실패를 추적 가능하게 만든다.

2\. Scope

This document covers Stage 0A, Stage 0B, and Stage 0C request state transitions.

Covered states include:

MENU\_VIEWED
ITEMS\_SELECTED
SHOW\_TO\_STAFF\_READY
SHOWN\_TO\_STAFF
REQUEST\_READY
REQUESTED
REQUEST\_SENT
REQUEST\_UPDATED
STORE\_VIEWED
STORE\_RECONFIRM\_REQUIRED
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
UNCONFIRMED\_WARNING
FORCED\_CLEANUP\_REQUIRED
STORE\_HANDLED\_MANUALLY
COMPLETED
AUTO\_COMPLETED
CLOSE\_AUTO\_COMPLETED
UNCONFIRMED\_EXPIRED
REQUEST\_EXPIRED
SUPPORT\_REVIEW\_REQUIRED

This document does not define:

POS transaction state
KDS execution state
payment state
settlement state
benefit grant state
refund state
AI customer center case state

3\. Core Principle

State transition is authority-bound.

A request state may change only when the actor has authority for that state transition.

Core rule:

State is not just a label.
State is an operational claim.
Operational claims require authority.

Korean rule:

상태는 단순한 표시가 아니다.
상태는 운영상 주장이다.
운영상 주장은 권한이 필요하다.

4\. State Transition Guard Model

Every state transition should be checked by a guard.

A guard should verify:

current\_state
target\_state
stage
actor\_type
actor\_authority
request\_version
store\_id
tenant\_id
business\_date
time\_condition
critical\_request\_condition
support\_review\_condition
fallback\_condition

If the guard passes, the transition may occur.

If the guard fails, the transition must be rejected and recorded as a typed failure event.

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

5\. Transition Event Requirement

Every state transition must create an event.

Suggested event fields:

event\_id
request\_id
request\_version
previous\_state
new\_state
event\_type
event\_reason
actor\_type
actor\_id
source\_system
stage
tenant\_id
store\_id
business\_date
created\_at
trace\_id

Core rule:

Current state is projection.
Transition event is history.

Korean rule:

현재 상태는 조회용 projection이다.
상태 전이 이벤트가 진짜 이력이다.

6\. Stage 0A State Transitions

Stage 0A is local visibility flow.

Allowed transitions:

MENU\_VIEWED
→ ITEMS\_SELECTED

ITEMS\_SELECTED
→ SHOW\_TO\_STAFF\_READY

SHOW\_TO\_STAFF\_READY
→ SHOWN\_TO\_STAFF

Stage 0A must not transition to store-side states.

Prohibited transitions:

SHOW\_TO\_STAFF\_READY
→ REQUEST\_SENT

SHOWN\_TO\_STAFF
→ STORE\_CONFIRMED

SHOWN\_TO\_STAFF
→ POS\_HANDOFF\_READY

SHOWN\_TO\_STAFF
→ PAYMENT\_COMPLETED

Core rule:

Stage 0A shows guest intent.
Stage 0A does not create store-side request state.

7\. Stage 0B State Transitions

Stage 0B sends request to owner console.

Allowed transitions:

REQUEST\_READY
→ REQUEST\_SENT

REQUEST\_SENT
→ REQUEST\_UPDATED

REQUEST\_SENT
→ STORE\_VIEWED

REQUEST\_UPDATED
→ STORE\_VIEWED

STORE\_VIEWED
→ STORE\_RECONFIRM\_REQUIRED

STORE\_VIEWED
→ STORE\_HANDLED\_MANUALLY

REQUEST\_SENT
→ REQUEST\_EXPIRED

REQUEST\_UPDATED
→ REQUEST\_EXPIRED

STORE\_RECONFIRM\_REQUIRED
→ STORE\_HANDLED\_MANUALLY

STORE\_RECONFIRM\_REQUIRED
→ SUPPORT\_REVIEW\_REQUIRED

Stage 0B may show communication status.

Stage 0B must not use Stage 0C confirmation state unless Stage 0C is enabled.

Prohibited transitions:

REQUEST\_SENT
→ STORE\_CONFIRMED

REQUEST\_SENT
→ GUEST\_EDIT\_LOCKED

REQUEST\_SENT
→ AUTO\_COMPLETED

REQUEST\_SENT
→ POS\_HANDOFF\_READY

REQUEST\_SENT
→ PAYMENT\_COMPLETED

Exception:

REQUEST\_SENT
→ STORE\_CONFIRMED

may be allowed only if the store is configured for Stage 0C.

8\. Stage 0C State Transitions

Stage 0C allows store confirmation.

Allowed normal transitions:

REQUESTED
→ STORE\_CONFIRMED

STORE\_CONFIRMED
→ GUEST\_EDIT\_LOCKED

GUEST\_EDIT\_LOCKED
→ COMPLETED

Allowed warning transitions:

REQUESTED
→ UNCONFIRMED\_WARNING

UNCONFIRMED\_WARNING
→ STORE\_CONFIRMED

UNCONFIRMED\_WARNING
→ FORCED\_CLEANUP\_REQUIRED

FORCED\_CLEANUP\_REQUIRED
→ STORE\_CONFIRMED

FORCED\_CLEANUP\_REQUIRED
→ UNCONFIRMED\_EXPIRED

Allowed auto-completion transitions:

STORE\_CONFIRMED
→ AUTO\_COMPLETED

GUEST\_EDIT\_LOCKED
→ AUTO\_COMPLETED

STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

GUEST\_EDIT\_LOCKED
→ CLOSE\_AUTO\_COMPLETED

Allowed expiration transition:

UNCONFIRMED\_WARNING
→ UNCONFIRMED\_EXPIRED

FORCED\_CLEANUP\_REQUIRED
→ UNCONFIRMED\_EXPIRED

Critical rule:

AUTO\_COMPLETED requires prior STORE\_CONFIRMED.
CLOSE\_AUTO\_COMPLETED requires prior STORE\_CONFIRMED.

9\. Prohibited Stage 0C Transitions

The following transitions must be blocked:

REQUESTED
→ AUTO\_COMPLETED

REQUESTED
→ CLOSE\_AUTO\_COMPLETED

UNCONFIRMED\_WARNING
→ AUTO\_COMPLETED

UNCONFIRMED\_WARNING
→ CLOSE\_AUTO\_COMPLETED

FORCED\_CLEANUP\_REQUIRED
→ AUTO\_COMPLETED

FORCED\_CLEANUP\_REQUIRED
→ CLOSE\_AUTO\_COMPLETED

UNCONFIRMED\_EXPIRED
→ COMPLETED

REQUESTED
→ PAYMENT\_COMPLETED

REQUESTED
→ POS\_HANDOFF\_ACCEPTED

REQUESTED
→ KDS\_HANDOFF\_ACCEPTED

Core rule:

Unconfirmed request must not become completed order.

Korean rule:

미확인 요청은 완료 주문으로 바뀌면 안 된다.

10\. Store Confirmation Guard

"STORE\_CONFIRMED" requires store-side authority.

Allowed actor types:

store\_owner
store\_manager
store\_staff
authorized\_store\_runtime

Required conditions:

request exists
request belongs to store
request is current version or latest version accepted
request is not expired
actor has store scope
stage supports confirmation

On success, the system may create:

STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
confirmation\_event

On failure, the system should create a typed failure event.

Example failure code:

WOH.STAGE0.REQUEST.CONFIRM.SCOPE\_DENIED
WOH.STAGE0.REQUEST.CONFIRM.INVALID\_STATE
WOH.STAGE0.REQUEST.CONFIRM.STALE\_VERSION

11\. Guest Edit Lock Guard

"GUEST\_EDIT\_LOCKED" requires prior store confirmation.

Allowed transition:

STORE\_CONFIRMED
→ GUEST\_EDIT\_LOCKED

Prohibited transition:

REQUESTED
→ GUEST\_EDIT\_LOCKED

unless store confirmation is created in the same atomic transition.

Core rule:

Guest edit lock must be caused by store confirmation.

Korean rule:

손님 수정 잠금은 매장 확인에 의해 발생해야 한다.

12\. Completion Guard

"COMPLETED" requires store-side action or approved Stage 0C policy.

Allowed actors:

store\_owner
store\_manager
store\_staff
authorized\_store\_runtime

Allowed conditions:

request was confirmed
or store explicitly performs manual completion
stage policy allows completion
no unresolved critical reconfirmation remains

Completion must not imply:

payment completed
POS completed
KDS completed
settlement completed
benefit granted

Core rule:

Stage 0 completion means Stage 0 handling completion.
It is not payment or settlement completion.

13\. Auto-Completion Guard

"AUTO\_COMPLETED" is allowed only for confirmed requests.

Required conditions:

STORE\_CONFIRMED exists
configured time elapsed
guest edit was locked or confirmation implies lock
no unresolved critical reconfirmation
no active support review block
stage policy allows auto-completion

Example:

STORE\_CONFIRMED \+ 60 minutes
→ AUTO\_COMPLETED

Prohibited:

REQUESTED \+ 60 minutes
→ AUTO\_COMPLETED

Core rule:

Auto-completion is cleanup for confirmed requests only.

14\. Close Auto-Completion Guard

"CLOSE\_AUTO\_COMPLETED" is allowed only for confirmed requests at close.

Required conditions:

STORE\_CONFIRMED exists
business date close process runs
no unresolved support review block
stage policy allows close cleanup

Prohibited:

UNCONFIRMED\_WARNING
→ CLOSE\_AUTO\_COMPLETED

Core rule:

Closing cleanup must not convert unconfirmed requests into completed orders.

15\. Unconfirmed Warning Guard

"UNCONFIRMED\_WARNING" is created when a request remains unconfirmed past configured threshold.

Example:

REQUESTED \+ 30 minutes without STORE\_CONFIRMED
→ UNCONFIRMED\_WARNING

Required conditions:

request exists
request is not confirmed
request is not expired
threshold elapsed
stage supports warning

Warning must not change the request into completed state.

16\. Forced Cleanup Guard

"FORCED\_CLEANUP\_REQUIRED" may be created when unconfirmed requests accumulate.

Example:

10 or more unconfirmed requests
→ FORCED\_CLEANUP\_REQUIRED

Required conditions:

unconfirmed request count threshold reached
stage supports forced cleanup
store scope confirmed
request list is recoverable

Forced cleanup must allow classification, not silent completion.

Core rule:

Forced cleanup is awareness and classification.
Forced cleanup is not bulk completion.

17\. Unconfirmed Expiration Guard

"UNCONFIRMED\_EXPIRED" may be used when unconfirmed requests are no longer active.

Allowed transitions:

UNCONFIRMED\_WARNING
→ UNCONFIRMED\_EXPIRED

FORCED\_CLEANUP\_REQUIRED
→ UNCONFIRMED\_EXPIRED

Required conditions:

request was never store confirmed
expiration policy applies
history is preserved
support review may still access evidence

Core rule:

Unconfirmed expiration is not completion.

Korean rule:

미확인 만료는 완료가 아니다.

18\. Reconfirmation Guard

"STORE\_RECONFIRM\_REQUIRED" may be created when staff must verify details with the guest.

Conditions:

allergy or dietary caution exists
translation confidence is LOW or UNKNOWN
menu item sold out
option unavailable
quantity unavailable
request memo unclear
critical custom request exists

Reconfirmation may block:

AUTO\_COMPLETED
CLOSE\_AUTO\_COMPLETED
COMPLETED

until resolved by staff.

Core rule:

Critical uncertainty must not be auto-resolved.

19\. Support Review Guard

"SUPPORT\_REVIEW\_REQUIRED" may be created when the request state is unsafe or disputed.

Conditions:

state conflict
invalid transition attempt
duplicate request conflict
translation risk
unconfirmed request dispute
auto-completion dispute
Evidence Packet incomplete
owner console failure
support signal generated

Support review does not authorize mutation.

Core rule:

Support review explains and escalates.
Support review does not silently mutate.

20\. Request Version Guard

State transition should target the current request version.

If the actor operates on a stale version, the transition should be blocked or require explicit latest-version review.

Possible failure:

WOH.STAGE0.REQUEST.TRANSITION.STALE\_VERSION

Allowed behavior:

show latest version warning
require refresh
allow staff to review latest version
create support signal if conflict persists

Core rule:

Do not confirm stale guest intent.

21\. Duplicate Request Guard

Duplicate request suspicion must not merge requests automatically.

Duplicate signals may include:

same guest session
same menu items
same store
short time window
same device hint
same language

Allowed actions:

show duplicate warning
ask staff to review
link as possible duplicate
create support signal

Prohibited actions:

auto-merge requests
auto-delete duplicate
auto-complete duplicate
auto-charge duplicate

Core rule:

Duplicate suspicion is not merge authority.

22\. Critical Request Guard

Critical requests must block unsafe automation.

Critical categories:

allergy
cannot-eat ingredient
spicy level
pork
beef
seafood
nuts
alcohol
raw food
religious dietary restriction
vegetarian or vegan request
child or elderly consideration
medical caution
custom cooking request

Critical request may require:

staff reconfirmation
translation review
support review
manual handling

Core rule:

Critical request must be visible before confirmation and completion.

23\. Translation Confidence Guard

Low or unknown translation confidence should block unsafe assumptions.

Suggested confidence values:

HIGH
MEDIUM
LOW
UNKNOWN

If confidence is LOW or UNKNOWN:

show warning
preserve original text
require staff confirmation for critical fields
block automatic safe interpretation

Core rule:

Translation uncertainty must not become operational certainty.

24\. Idempotency Guard

Sending or confirming a request should be idempotency-safe.

Guard should prevent:

duplicate request creation from double tap
duplicate confirmation from repeated click
duplicate completion from retry
duplicate support signal from same event

Suggested controls:

idempotency\_key
request\_version
operation\_token
last\_transition\_check
same transition dedup window

Core rule:

Retry must not create duplicate operational truth.

25\. Actor Authority Guard

Each transition requires actor authority.

Suggested actor mapping:

guest
\= MENU\_VIEWED, ITEMS\_SELECTED, REQUEST\_READY, REQUEST\_SENT, REQUEST\_UPDATED before lock

store\_owner / store\_manager / store\_staff
\= STORE\_VIEWED, STORE\_CONFIRMED, STORE\_RECONFIRM\_REQUIRED, COMPLETED

authorized\_store\_runtime
\= UNCONFIRMED\_WARNING, FORCED\_CLEANUP\_REQUIRED, AUTO\_COMPLETED, CLOSE\_AUTO\_COMPLETED, UNCONFIRMED\_EXPIRED

support\_read\_only
\= view only, no mutation

support\_operator
\= may recommend or escalate, not mutate unless separately authorized

Core rule:

No actor may transition a state outside its authority.

26\. State Transition Failure Event

Invalid transition attempts must create typed failure events.

Suggested fields:

failure\_event\_id
failure\_code
request\_id
request\_version
current\_state
target\_state
actor\_type
actor\_id
stage
tenant\_id
store\_id
failure\_reason
trace\_id
created\_at

Example failure codes:

WOH.STAGE0.REQUEST.TRANSITION.INVALID\_STATE
WOH.STAGE0.REQUEST.TRANSITION.UNAUTHORIZED\_ACTOR
WOH.STAGE0.REQUEST.TRANSITION.STALE\_VERSION
WOH.STAGE0.REQUEST.TRANSITION.UNCONFIRMED\_AUTO\_COMPLETE\_DENIED
WOH.STAGE0.REQUEST.TRANSITION.CRITICAL\_RECONFIRM\_REQUIRED
WOH.STAGE0.REQUEST.TRANSITION.DUPLICATE\_SUSPECTED

27\. Projection Rebuild Rule

Current request state should be rebuildable from events.

If current state projection is corrupted or stale, it should be rebuilt from transition events.

Core rule:

Projection can be rebuilt.
Event history must be preserved.

Projection failure must not erase request timeline.

28\. Guest-Facing State Messages

Guest-facing status must be simple.

Examples:

Request sent
Store confirmed
Please ask staff
Request expired
Please show staff

Do not show guest-facing internal state names:

UNCONFIRMED\_WARNING
FORCED\_CLEANUP\_REQUIRED
AUTO\_COMPLETED
SUPPORT\_REVIEW\_REQUIRED
GATEWAY\_SCOPE\_DENIED

unless simplified.

29\. Merchant-Facing State Messages

Merchant-facing state may be more operational.

Examples:

신규 요청
확인 필요
주문 확인됨
손님 수정 잠김
미확인 경고
강제 정리 필요
완료
미확인 만료
재확인 필요

Merchant-facing labels must not imply payment completion.

30\. Support-Facing State Messages

Support-facing state may include technical information.

Examples:

REQUESTED without STORE\_CONFIRMED for 30 minutes
UNCONFIRMED\_WARNING generated
FORCED\_CLEANUP\_REQUIRED threshold reached
AUTO\_COMPLETED denied because request was unconfirmed
STORE\_CONFIRMED followed by GUEST\_EDIT\_LOCKED

Support-facing messages should include trace and evidence references.

31\. Final Statement

Stage 0 request state transitions must be guarded, event-backed, authority-bound, and support-observable.

Final rule:

No silent overwrite.
No unconfirmed auto-completion.
No stale-version confirmation.
No actor without authority.
No transition without event.
No fallback without trace.
