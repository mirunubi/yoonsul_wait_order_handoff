# 01230_Policy_CatchMenu_Stage_0C_POS_Less_Request_Confirmation_Board

1\. Purpose

This document defines the Stage 0C POS-less request confirmation board for CatchMenu.

Stage 0C allows the store to receive guest requests, confirm that the request was seen, lock guest self-edit after confirmation, manage unconfirmed requests, and mark requests as completed if the store chooses to do so.

Stage 0C is not POS.

Stage 0C is not payment.

Stage 0C is not settlement.

Stage 0C is not KDS.

Core purpose:

Let the store confirm guest requests without POS integration.
Prevent unconfirmed requests from becoming completed orders.
Keep the flow simple enough for low-IT merchants.

Korean purpose:

POS 연동 없이 매장이 손님 요청을 확인할 수 있게 한다.
미확인 요청이 완료 주문으로 바뀌지 않게 한다.
IT 부담이 낮은 업주도 사용할 수 있게 단순하게 유지한다.

2\. Stage 0C Definition

Stage 0C means:

Multilingual QR Menu
\+ Guest request sent to store
\+ Owner Web Console
\+ POS-less Request Confirmation Board
\+ Store confirmation
\+ Guest edit lock after confirmation
\+ Unconfirmed warning
\+ Forced cleanup
\+ Optional manual completion

Stage 0C does not include:

POS transaction authority
KDS execution authority
payment authority
settlement authority
refund authority
benefit grant authority
external membership merge

Core rule:

Stage 0C confirms request visibility and handling.
Stage 0C does not confirm POS, payment, settlement, or kitchen execution.

3\. User Flow

Recommended Stage 0C flow:

Guest scans QR
→ Guest views menu
→ Guest selects language
→ Guest selects items/options
→ Guest sends request to store
→ Request appears on confirmation board
→ Store confirms request
→ Guest self-edit is locked
→ Store handles request manually
→ Store may mark completed
or
→ Confirmed request may auto-complete after configured time

Unconfirmed path:

Guest sends request
→ Store does not confirm
→ Unconfirmed warning
→ Forced cleanup if threshold reached
→ Store confirms or expires request

4\. Core Stage 0C Rule

The most important Stage 0C rule is:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

Korean rule:

매장이 확인한 요청만 자동 완료 후보가 될 수 있다.
미확인 요청은 완료 주문으로 자동 처리하면 안 된다.

This rule protects:

guest trust
merchant clarity
support evidence
order accuracy
legal and dispute handling

5\. Request Confirmation Meaning

"STORE\_CONFIRMED" means:

the store has seen the guest request
the store acknowledges the request exists
the guest self-edit may be locked
the request may enter store handling flow

"STORE\_CONFIRMED" does not mean:

payment completed
POS transaction created
KDS ticket created
food served
settlement completed
benefit granted
refund impossible
legal responsibility closed

Core rule:

Store confirmation is acknowledgment.
It is not payment.
It is not POS.
It is not KDS.

6\. Request Board Purpose

The Stage 0C request board should help the store see and manage incoming guest requests.

The request board should show:

new requests
confirmed requests
unconfirmed warning requests
forced cleanup required requests
completed requests
expired requests
critical request warnings
translation confidence warnings

The board should be simple.

The board must not become a full POS.

7\. Minimum Board Actions

Stage 0C should start with minimal actions.

Required actions:

주문 확인
완료

Recommended English labels:

Confirm Request
Done

Meaning:

주문 확인 / Confirm Request
\= the store has seen and acknowledged the request

완료 / Done
\= the store marks CatchMenu Stage 0C handling as completed

The system should avoid too many buttons in the first version.

8\. Optional Board Actions

Optional actions may be added later.

Possible optional actions:

재확인 필요
품절/불가
손님에게 문의
수동 처리 완료
미처리 만료
숨기기

English examples:

Needs Reconfirmation
Unavailable
Ask Guest
Handled Manually
Expire Unhandled
Hide

Optional actions must not confuse the merchant.

Optional actions should be enabled only if the store is ready.

9\. Guest Edit Lock Policy

Before store confirmation, the guest may edit the request if the session allows it.

After store confirmation, guest self-edit should be locked.

Flow:

REQUESTED
→ guest may edit

STORE\_CONFIRMED
→ GUEST\_EDIT\_LOCKED
→ guest must ask staff for changes

Guest-facing message:

매장에서 요청을 확인했습니다.
이제 직접 수정할 수 없습니다.
변경이 필요하면 직원에게 말씀해주세요.

English:

The store has confirmed your request.
You can no longer edit it directly.
Please ask staff if you need changes.

Core rule:

Store confirmation locks guest self-edit.
Changes after confirmation require staff-mediated handling.

10\. Stage 0C Main States

Suggested Stage 0C states:

REQUESTED
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
UNCONFIRMED\_WARNING
FORCED\_CLEANUP\_REQUIRED
COMPLETED
AUTO\_COMPLETED
CLOSE\_AUTO\_COMPLETED
UNCONFIRMED\_EXPIRED
SUPPORT\_REVIEW\_REQUIRED

Not every UI needs to show internal state names.

Merchant-facing labels may be simpler.

11\. Normal Confirmed Flow

Normal confirmed flow:

REQUESTED
→ STORE\_CONFIRMED
→ GUEST\_EDIT\_LOCKED
→ COMPLETED

If the store does not press "완료", configured automation may complete confirmed requests.

Auto-completion flow:

STORE\_CONFIRMED
→ AUTO\_COMPLETED

Close auto-completion flow:

STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

Auto-completion must only apply to confirmed requests.

12\. Manual Completion Policy

The store may press "완료" after handling the request.

"COMPLETED" means:

Stage 0C request handling ended in CatchMenu
the store marked the request as handled

"COMPLETED" does not necessarily mean:

payment completed
POS completed
food served
settlement completed
benefit granted

Merchant-facing UI should clarify if necessary:

CatchMenu 요청 처리 완료

not:

결제 완료

unless payment authority exists.

13\. Confirmed Auto-Completion Policy

Confirmed requests may be auto-completed after a configured time.

Example policy:

STORE\_CONFIRMED \+ 60 minutes
→ AUTO\_COMPLETED

The exact time may be configured by merchant package, store policy, or future tenant policy.

Auto-completion is allowed only when:

request was STORE\_CONFIRMED
guest edit was locked
no unresolved support review exists
no critical reconfirmation remains unresolved
store closing policy allows it

Core rule:

Auto-completion is cleanup for confirmed requests.
Auto-completion is not proof of payment or settlement.

14\. Close Auto-Completion Policy

At store closing or business date close, confirmed requests may be closed automatically.

Flow:

STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

Close auto-completion must not apply to unconfirmed requests.

It is used to clean up board state at the end of operations.

It must preserve request history.

15\. Unconfirmed Request Warning

If the store does not confirm a request within configured time, the request may enter warning state.

Example policy:

REQUESTED \+ 30 minutes without STORE\_CONFIRMED
→ UNCONFIRMED\_WARNING

"UNCONFIRMED\_WARNING" means:

a request exists
the store has not confirmed it
the request may require attention

It does not mean:

the request was handled
the request was completed
the guest was served

Merchant-facing label:

미확인 경고

16\. Top Warning Policy

If unconfirmed requests exist, the owner console should show visible warning.

Possible UI behavior:

top banner
badge count
highlighted request list
sound if enabled
warning color

The warning should not block all operations unless forced cleanup threshold is reached.

Purpose:

make missed requests visible
prevent silent loss
help merchant recover

17\. Forced Cleanup Threshold

If unconfirmed requests accumulate beyond threshold, the system may require cleanup before normal use continues.

Example threshold:

10 or more unconfirmed requests
→ FORCED\_CLEANUP\_REQUIRED

Forced cleanup screen should show:

unconfirmed request list
request time
elapsed time
selected items summary
critical warnings
available cleanup actions

Purpose:

prevent silent pile-up
force merchant awareness
preserve support evidence
avoid false completion

18\. Forced Cleanup Actions

Forced cleanup may allow:

confirm request
mark unhandled expired
open detail
ask staff to review
support review

Forced cleanup must not allow:

bulk auto-complete unconfirmed requests as completed orders
delete request history
hide without trace
mark payment complete
mark POS complete

Core rule:

Forced cleanup is awareness and classification.
Forced cleanup is not silent completion.

19\. Unconfirmed Expiration

Unconfirmed requests may expire if not confirmed within policy window or during cleanup.

Flow:

REQUESTED
→ UNCONFIRMED\_WARNING
→ UNCONFIRMED\_EXPIRED

"UNCONFIRMED\_EXPIRED" means:

the request was not confirmed by the store
the request is no longer active in Stage 0C board
history is preserved
support may review if needed

"UNCONFIRMED\_EXPIRED" does not mean:

the store served the guest
payment completed
order completed

20\. Critical Request Handling

Critical requests require special visibility.

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

If critical request exists, board should show:

중요 요청
직원 확인 필요
번역 주의
손님 재확인 필요

Critical request must not be auto-resolved silently.

21\. Store Reconfirmation Policy

Store reconfirmation may be required when:

allergy or dietary caution exists
translation confidence is low
menu item is sold out
option unavailable
quantity unavailable
request memo is unclear
guest changed request shortly before confirmation
staff needs verbal confirmation

Possible state:

STORE\_RECONFIRM\_REQUIRED

If this state is added, auto-completion should wait until reconfirmation is resolved.

22\. Owner Console Display Requirements

The Stage 0C board should show enough information for fast handling.

Recommended fields:

request\_id
request\_time
elapsed\_time
request\_status
guest\_language
selected\_items\_summary
quantity
options
critical\_flags
translation\_confidence
request\_version
store\_confirmation\_status
completion\_status

The UI should prioritize:

newest active requests
unconfirmed warnings
critical requests
forced cleanup candidates

23\. Merchant-Facing Labels

Recommended Korean labels:

신규 요청
주문 확인
확인됨
손님 수정 잠김
미확인 경고
강제 정리 필요
완료
자동 완료
마감 자동 완료
미확인 만료
재확인 필요

Recommended English labels:

New Request
Confirm Request
Confirmed
Guest Edit Locked
Unconfirmed Warning
Cleanup Required
Done
Auto Completed
Close Auto Completed
Unconfirmed Expired
Reconfirmation Required

Merchant-facing labels must not imply payment completion.

24\. Guest-Facing Labels

Guest-facing labels should be simple.

Allowed guest messages:

Request sent
Store confirmed your request
You can no longer edit directly
Please ask staff if you need changes
Request needs staff confirmation
Request expired
Please show staff
Please pay at store

Avoid:

POS accepted
KDS accepted
Payment completed
Settlement completed
Benefit granted
Evidence Packet created
Support signal generated

25\. Notification Policy

Stage 0C may use notifications to alert store users.

Notification methods may include:

browser sound
top banner
badge
SMS option
Kakao option
push option
email option

Notification is not the source of truth.

Core rule:

Notification failure must not erase the request.
Request board remains the operational reference.

Notification failure should create a typed failure event if configured.

26\. Board Refresh And Visibility

The request board should remain clear even if browser refreshes.

The system should preserve:

active request list
confirmed request list
unconfirmed warning list
forced cleanup state
critical request indicator

If refresh loses temporary UI state, runtime state must still be recoverable.

Core rule:

UI refresh must not erase request state.

27\. Support Signal Policy

Stage 0C may generate support signals for:

UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
REQUEST\_CONFIRMATION\_DELAY
CRITICAL\_REQUEST\_DETECTED
LOW\_CONFIDENCE\_TRANSLATION
OWNER\_CONSOLE\_ALERT\_DELIVERY\_FAILED
REQUEST\_VERSION\_CONFLICT
AUTO\_COMPLETION\_DISPUTE
UNCONFIRMED\_EXPIRED\_DISPUTE

Support signal should include:

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

28\. Evidence Packet Policy

Stage 0C should support Evidence Packet generation.

Evidence Packet may include:

request\_id
request\_version
request timeline
selected items
critical request flags
guest language
store language summary
translation confidence
store confirmation event
guest edit lock event
unconfirmed warning event
forced cleanup event
completion event
auto-completion event
expiration event
notification attempts
failure events
gateway access references

Evidence Packet explains what happened.

Evidence Packet must not mutate request state.

29\. Event History Policy

Stage 0C state changes should be event-backed.

Important events:

REQUEST\_CREATED
REQUEST\_VERSION\_UPDATED
REQUEST\_SENT\_TO\_STORE
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
UNCONFIRMED\_WARNING\_CREATED
FORCED\_CLEANUP\_REQUIRED
REQUEST\_COMPLETED\_BY\_STORE
REQUEST\_AUTO\_COMPLETED
REQUEST\_CLOSE\_AUTO\_COMPLETED
REQUEST\_UNCONFIRMED\_EXPIRED
SUPPORT\_REVIEW\_REQUIRED

Core rule:

Current state is a projection.
Events are the history.

30\. Invalid Transition Guard

Invalid transitions must be blocked.

Examples:

REQUESTED → AUTO\_COMPLETED
not allowed

UNCONFIRMED\_WARNING → AUTO\_COMPLETED
not allowed

REQUESTED → COMPLETED
allowed only if store explicitly performs completion and policy permits

STORE\_CONFIRMED → AUTO\_COMPLETED
allowed if time and policy conditions are met

UNCONFIRMED\_WARNING → UNCONFIRMED\_EXPIRED
allowed if no store confirmation occurred

Invalid transition should create typed failure event.

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

31\. Fallback Policy

If Stage 0C board fails, fallback should be manual.

Examples:

owner console unavailable
→ staff uses manual order process

notification fails
→ request list remains visible

translation confidence low
→ staff reconfirms with guest

forced cleanup UI fails
→ support review or manual admin cleanup

auto-completion job fails
→ request remains visible or support review required

Fallback must preserve evidence.

Fallback must not silently rewrite state.

32\. Relationship To Stage 0B

Stage 0C extends Stage 0B.

Stage 0B:

guest sends request
store may view request
manual handling
no strong confirmation board

Stage 0C:

guest sends request
store confirms request
guest edit locks
unconfirmed warning exists
forced cleanup exists
confirmed auto-completion may exist

Migration from 0B to 0C requires staff understanding of:

주문 확인
손님 수정 잠김
미확인 경고
강제 정리
완료

33\. Relationship To Stage 1

Stage 0C may later migrate to Stage 1\.

Stage 1 adds:

waiting identity
arrival confirmation
manual POS handoff
staff handoff view
manual POS recovery

Stage 0C should not pretend to have Stage 1 waiting/handoff features unless they are enabled.

34\. Privacy And Data Boundary

Stage 0C should collect only the data needed for request handling and support.

Allowed operational context:

guest\_session\_id
request\_id
store\_id
tenant\_id
guest language
selected items
critical request flags
request memo
request timestamps
confirmation events
completion events
failure events

Avoid collecting:

unnecessary personal identity
raw payment data
external membership data
unrelated device tracking
private contact information

35\. Final Statement

Stage 0C is a POS-less request confirmation board.

It helps the store acknowledge and manage guest requests without pretending to be POS, KDS, payment, settlement, or benefit authority.

Final rule:

Stage 0C confirms request visibility.
Stage 0C may lock guest edits.
Stage 0C may complete confirmed request handling.
Stage 0C must not auto-complete unconfirmed requests.
Stage 0C must preserve evidence.
Stage 0C must remain POS-less.
