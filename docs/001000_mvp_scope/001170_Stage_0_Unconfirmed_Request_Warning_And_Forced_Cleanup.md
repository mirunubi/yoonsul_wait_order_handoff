# 001170_Stage_0_Unconfirmed_Request_Warning_And_Forced_Cleanup.md

1\. Purpose

This document defines the Stage 0 unconfirmed request warning and forced cleanup policy for CatchMenu.

Stage 0C must prevent guest requests from being silently missed, silently hidden, or incorrectly completed.

The system must distinguish between:

confirmed request
unconfirmed request
unconfirmed warning
forced cleanup required
unconfirmed expired
confirmed auto-completed

Core purpose:

Make missed requests visible.
Prevent false completion.
Force awareness when unconfirmed requests accumulate.
Preserve evidence for support.

Korean purpose:

놓친 요청을 보이게 한다.
거짓 완료를 막는다.
미확인 요청이 쌓이면 업주가 인지하게 만든다.
지원 검토를 위한 증거를 보존한다.

2\. Core Principle

Unconfirmed requests must never become completed orders automatically.

Core rule:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

Korean rule:

매장이 확인한 요청만 자동 완료 후보가 될 수 있다.
미확인 요청은 완료 주문으로 자동 처리하면 안 된다.

This rule is one of the strongest Stage 0C safety rules.

3\. Scope

This document covers:

unconfirmed request detection
unconfirmed warning
top warning
badge count
forced cleanup threshold
forced cleanup screen
cleanup actions
unconfirmed expiration
confirmed auto-completion separation
close auto-completion separation
support signal generation
Evidence Packet support
failure event handling

This document does not define:

POS order completion
KDS completion
payment completion
settlement completion
refund workflow
benefit grant
AI customer center case lifecycle

4\. Definitions

4.1 Unconfirmed Request

An unconfirmed request is a request sent to the store but not yet acknowledged by store confirmation.

REQUESTED
without
STORE\_CONFIRMED

Meaning:

guest sent request
store has not confirmed it
request may require attention
request is not completed

4.2 Confirmed Request

A confirmed request is a request acknowledged by the store.

REQUESTED
→ STORE\_CONFIRMED

Meaning:

store saw and acknowledged request
guest self-edit may be locked
confirmed request may enter handling flow

4.3 Unconfirmed Warning

An unconfirmed warning is a visible warning that a request remains unconfirmed beyond policy threshold.

REQUESTED \+ threshold
→ UNCONFIRMED\_WARNING

4.4 Forced Cleanup

Forced cleanup is a stronger state requiring the store to review accumulated unconfirmed requests.

unconfirmed request count \>= threshold
→ FORCED\_CLEANUP\_REQUIRED

Forced cleanup is awareness and classification.

Forced cleanup is not completion.

5\. Unconfirmed Warning Trigger

A request may become "UNCONFIRMED\_WARNING" when it remains unconfirmed for too long.

Example rule:

REQUESTED \+ 30 minutes without STORE\_CONFIRMED
→ UNCONFIRMED\_WARNING

The exact time may be configured by:

store policy
tenant policy
package policy
business hours
request type
future merchant setting

Initial default may be:

30 minutes

6\. Unconfirmed Warning Meaning

"UNCONFIRMED\_WARNING" means:

a request exists
the store has not confirmed it
the request may have been missed
the store should review it

It does not mean:

request was completed
guest was served
payment was made
POS order was created
food was prepared

Core rule:

Warning means attention required.
Warning does not mean handled.

7\. Top Warning Policy

If any unconfirmed warning exists, the owner console should display a top warning.

Possible display:

top banner
warning badge
active count
highlighted request list
sound alert if enabled

Example Korean message:

확인되지 않은 요청이 있습니다.
요청 목록을 확인해주세요.

Example English message:

There are unconfirmed requests.
Please review the request list.

Top warning should be visible but should not block all operations unless forced cleanup threshold is reached.

8\. Badge Count Policy

The owner console may show counts.

Suggested counts:

new\_request\_count
unconfirmed\_warning\_count
forced\_cleanup\_count
critical\_unconfirmed\_count

Badge count should help the store prioritize.

Badge count must not hide old unconfirmed requests.

9\. Critical Unconfirmed Request Priority

Unconfirmed requests with critical flags should be prioritized.

Critical categories include:

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

Critical unconfirmed request should show stronger warning.

Example:

중요 요청이 포함된 미확인 요청입니다.
직원이 반드시 확인해야 합니다.

10\. Forced Cleanup Trigger

Forced cleanup may be required when unconfirmed requests accumulate.

Example default threshold:

10 or more unconfirmed requests
→ FORCED\_CLEANUP\_REQUIRED

Other possible triggers:

critical unconfirmed request older than threshold
business closing with unconfirmed requests
repeated notification failure
owner console inactive for long period
support risk detected

Forced cleanup threshold should be configurable in the future.

Initial rule may remain simple:

unconfirmed request count \>= 10

11\. Forced Cleanup Meaning

"FORCED\_CLEANUP\_REQUIRED" means:

too many unconfirmed requests exist
normal request handling may be unsafe
store must review unconfirmed requests
system must prevent silent pile-up

It does not mean:

requests are completed
requests are cancelled
requests are deleted
requests are paid
requests are rejected

Core rule:

Forced cleanup means forced awareness.
Forced cleanup does not mean forced completion.

12\. Forced Cleanup Screen

The forced cleanup screen should show:

unconfirmed request list
request age
request time
selected items summary
guest language
critical warning flags
translation confidence flags
latest request version
available cleanup actions

The screen should help staff quickly classify each request.

It should not overwhelm staff with internal technical details.

13\. Forced Cleanup Actions

Allowed forced cleanup actions may include:

confirm request
open request detail
mark unconfirmed expired
send to support review
ask staff to check manually

Optional later actions:

mark duplicate suspected
mark guest not found
mark handled outside CatchMenu
mark reconfirmation required

Each action must create an event.

Each action must preserve history.

14\. Prohibited Forced Cleanup Actions

Forced cleanup must not allow unsafe shortcuts.

Prohibited actions:

bulk auto-complete unconfirmed requests as completed orders
delete request history
hide without trace
mark payment complete
mark POS complete
mark KDS complete
grant benefit
approve refund
silently merge duplicate requests

Core rule:

Cleanup classifies.
Cleanup does not erase.
Cleanup does not create false completion.

15\. Confirm From Forced Cleanup

A store may confirm an unconfirmed request from forced cleanup.

Allowed transition:

FORCED\_CLEANUP\_REQUIRED
→ STORE\_CONFIRMED
→ GUEST\_EDIT\_LOCKED

Required conditions:

request still exists
request belongs to current store
actor has store authority
latest request version is reviewed
critical warnings are visible

Confirmation must create an event.

16\. Expire From Forced Cleanup

A store or authorized runtime may expire an unconfirmed request from forced cleanup.

Allowed transition:

FORCED\_CLEANUP\_REQUIRED
→ UNCONFIRMED\_EXPIRED

Meaning:

request was never confirmed
request is no longer active
history is preserved
support review may still inspect it

It does not mean:

request was completed
guest was served
payment occurred

17\. Unconfirmed Expiration Policy

Unconfirmed requests may expire when:

warning threshold passed
business day closed
forced cleanup classification completed
request is too old to remain active
support policy allows expiration

Expiration must preserve:

request\_id
request\_version
request timeline
created\_at
warning\_at
expired\_at
actor or runtime source
reason

Core rule:

Unconfirmed expiration is not completion.

Korean rule:

미확인 만료는 완료가 아니다.

18\. Confirmed Auto-Completion Separation

Confirmed auto-completion is separate from unconfirmed expiration.

Allowed:

STORE\_CONFIRMED \+ configured time
→ AUTO\_COMPLETED

Not allowed:

REQUESTED \+ configured time
→ AUTO\_COMPLETED

Not allowed:

UNCONFIRMED\_WARNING
→ AUTO\_COMPLETED

Confirmed auto-completion is board cleanup for confirmed requests.

It is not payment proof.

It is not POS proof.

19\. Close Auto-Completion Separation

At business day close, confirmed requests may be auto-completed.

Allowed:

STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

Not allowed:

UNCONFIRMED\_WARNING
→ CLOSE\_AUTO\_COMPLETED

Unconfirmed requests at close should become:

UNCONFIRMED\_EXPIRED

or:

SUPPORT\_REVIEW\_REQUIRED

depending on policy.

20\. Business Date Close Handling

At business date close, the system should classify active Stage 0C requests.

Possible close handling:

confirmed active request
→ CLOSE\_AUTO\_COMPLETED

unconfirmed warning request
→ UNCONFIRMED\_EXPIRED

critical unconfirmed request
→ SUPPORT\_REVIEW\_REQUIRED or UNCONFIRMED\_EXPIRED with critical flag

forced cleanup unresolved
→ SUPPORT\_REVIEW\_REQUIRED

Close process must preserve event history.

Close process must not silently delete requests.

21\. Owner Console Inactivity

If owner console appears inactive, the system may increase warning visibility.

Possible signals:

console not opened
console disconnected
notification failed
request list not refreshed
store has active requests but no interaction

Possible handling:

top warning
sound alert if enabled
notification retry
support signal
forced cleanup if threshold reached

Owner console inactivity must not auto-complete requests.

22\. Notification Failure Interaction

Notification failure may increase missed request risk.

If notification fails:

request remains in board
warning may still trigger
support signal may be created
failure event may be recorded

Core rule:

Notification failure must not erase request.
Notification failure must not become completion.

23\. Request Version Conflict

If a guest updates a request while it is still unconfirmed, the latest version should be visible.

If forced cleanup opens stale version, show warning:

This request has been updated.
Please review the latest version.

Korean:

이 요청은 수정되었습니다.
최신 내용을 확인해주세요.

Do not confirm stale version silently.

24\. Duplicate Request Suspicion

Duplicate request suspicion may appear during warning or forced cleanup.

Signals may include:

same guest session
same items
same store
short time window
same device hint
same language

Allowed:

show duplicate warning
link as possible duplicate
support review
staff manual decision

Prohibited:

auto-merge
auto-delete
auto-complete
auto-charge

Core rule:

Duplicate suspicion is not merge authority.

25\. Support Signal Policy

The system may generate support signals for:

UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
UNCONFIRMED\_REQUEST\_EXPIRED
CRITICAL\_UNCONFIRMED\_REQUEST
OWNER\_CONSOLE\_INACTIVE\_WITH\_REQUESTS
OWNER\_CONSOLE\_ALERT\_DELIVERY\_FAILED
REQUEST\_VERSION\_CONFLICT
DUPLICATE\_REQUEST\_SUSPECTED
AUTO\_COMPLETION\_DENIED\_UNCONFIRMED

Support signal payload should include:

signal\_id
signal\_type
tenant\_id
store\_id
request\_id
request\_version
severity\_hint
created\_at
evidence\_packet\_ref if available

Raw sensitive data should not be pushed.

Detailed evidence should be pulled through Support Gateway.

26\. Evidence Packet Policy

Evidence Packet for unconfirmed request issues may include:

request\_id
request\_version
request\_created\_at
request\_updated\_at
current\_state
warning\_created\_at
forced\_cleanup\_created\_at
expired\_at
selected item summary
critical flags
guest language
translation confidence
notification attempts
owner console activity hint
failure events
support signals
state timeline

Evidence Packet should distinguish:

confirmed
unconfirmed
warning
forced cleanup
expired
completed
auto-completed

Evidence Packet must not mutate request state.

27\. Failure Event Policy

Invalid unconfirmed request transitions must create typed failure events.

Examples:

attempted auto-completion without STORE\_CONFIRMED
attempted close auto-completion without STORE\_CONFIRMED
attempted bulk completion during forced cleanup
attempted deletion without trace
attempted stale-version confirmation

Example failure codes:

WOH.STAGE0.UNCONFIRMED.AUTO\_COMPLETE\_DENIED
WOH.STAGE0.UNCONFIRMED.CLOSE\_AUTO\_COMPLETE\_DENIED
WOH.STAGE0.FORCED\_CLEANUP.BULK\_COMPLETE\_DENIED
WOH.STAGE0.REQUEST.DELETE\_WITHOUT\_TRACE\_DENIED
WOH.STAGE0.REQUEST.CONFIRM.STALE\_VERSION

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

28\. Merchant-Facing Messages

Recommended Korean messages:

확인되지 않은 요청이 있습니다.
요청 목록을 확인해주세요.

미확인 요청이 많이 쌓였습니다.
계속 진행하기 전에 요청을 정리해주세요.

이 요청은 아직 매장에서 확인하지 않았습니다.
완료 처리할 수 없습니다.

이 요청은 미확인 상태로 만료되었습니다.
완료 주문으로 처리되지 않았습니다.

Recommended English messages:

There are unconfirmed requests.
Please review the request list.

Many unconfirmed requests have accumulated.
Please review them before continuing.

This request has not been confirmed by the store.
It cannot be completed automatically.

This request expired while unconfirmed.
It was not treated as a completed order.

29\. Guest-Facing Messages

Guest-facing messages should remain simple.

Possible messages:

Your request was sent.
Please wait for staff confirmation.

Your request may need staff confirmation.
Please ask staff.

This request is no longer active.
Please ask staff or send a new request.

Avoid guest-facing messages like:

forced cleanup
support signal
Evidence Packet
auto-completion denied

unless simplified.

30\. Support-Facing Messages

Support-facing view may show:

REQUESTED without STORE\_CONFIRMED for 30 minutes
UNCONFIRMED\_WARNING generated
FORCED\_CLEANUP\_REQUIRED threshold reached
AUTO\_COMPLETION\_DENIED because request was unconfirmed
UNCONFIRMED\_EXPIRED at business close

Support-facing messages should include:

request\_id
request\_version
store\_id
business\_date
trace\_id
failure\_event\_id if any
evidence\_packet\_ref if any

31\. Metrics And Monitoring

Recommended metrics:

unconfirmed\_request\_count
unconfirmed\_warning\_count
forced\_cleanup\_count
critical\_unconfirmed\_count
average\_confirmation\_delay
auto\_completion\_denied\_count
unconfirmed\_expired\_count
owner\_console\_inactive\_count
notification\_failure\_count

These metrics should improve operations.

They should not become punitive by default.

32\. Relationship To State Transition Guard

This document depends on:

01160\_Stage\_0\_Request\_State\_Transition\_Guard.md

State guard defines allowed transitions.

This document defines the operational policy around unconfirmed warning and forced cleanup.

33\. Relationship To Owner Console

Owner console display is governed by:

01150\_Stage\_0\_Owner\_Web\_Console\_Policy.md

Owner console must show unconfirmed warning and forced cleanup clearly.

34\. Relationship To MVP

Unconfirmed warning and forced cleanup are important MVP safety features.

MVP should include at least:

unconfirmed request count
warning after threshold
forced cleanup threshold
no unconfirmed auto-completion
unconfirmed expiration
basic support signal
basic evidence timeline

35\. Final Statement

Stage 0C must protect against silent missed requests.

Unconfirmed requests must remain visible, classifiable, and traceable.

They must never become completed orders automatically.

Final rule:

Warn when missed.
Force review when accumulated.
Expire unconfirmed safely.
Auto-complete only confirmed.
Preserve evidence.
Never fake completion.
