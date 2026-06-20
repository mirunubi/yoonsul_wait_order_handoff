# 001250_Policy_CatchMenu_POS_Less_Owner_Web_Console.md

1\. Purpose

This document defines the Stage 0 owner web console policy for CatchMenu.

The owner web console allows store owners or authorized staff to view guest requests, understand multilingual request summaries, identify critical requests, confirm requests, manage unconfirmed requests, and complete Stage 0C request handling.

The owner web console must remain simple.

The owner web console must not pretend to be POS, KDS, payment, settlement, refund, or benefit authority.

Core purpose:

Help the store see guest intent.
Help the store confirm or handle requests.
Prevent missed requests.
Avoid false POS/payment authority.

Korean purpose:

매장이 손님 의사를 볼 수 있게 한다.
매장이 요청을 확인하거나 처리할 수 있게 한다.
누락 요청을 줄인다.
POS/결제 권한으로 오해되지 않게 한다.

2\. Scope

This document covers Stage 0 owner-facing screens:

owner web console landing
request list
request detail
new request alert
Stage 0B request receive view
Stage 0C confirmation board
unconfirmed warning view
forced cleanup view
critical request warning
translation confidence warning
manual completion action
request expiration view
support signal hint
fallback view

This document does not define:

guest web screen
POS screen
KDS screen
payment settlement screen
AI customer center screen
HQ support console
full merchant admin system

3\. Core Principle

The owner web console is an operational visibility and handling surface.

It is not the transaction authority.

Core rule:

Owner console shows and manages CatchMenu Stage 0 requests.
Owner console does not become POS, KDS, payment, or settlement.

Korean rule:

업주 콘솔은 Stage 0 요청을 보여주고 관리한다.
업주 콘솔은 POS, KDS, 결제, 정산이 아니다.

4\. Stage Coverage

The owner web console behaves differently by Stage 0 mode.

Stage 0A
\= normally no owner console request is created

Stage 0B
\= owner console receives and displays guest request

Stage 0C
\= owner console provides POS-less request confirmation board

Stage 0A may still have menu/admin setup screens, but it does not require live request receiving.

5\. Owner Console Entry

Owner console entry should be simple and secure.

Possible access modes:

store login
magic link
device-bound store access
owner/staff account
temporary store session

Access must be scoped to:

tenant\_id if applicable
store\_id
stage/package enabled
actor role
session validity

The console must not show cross-store requests unless the actor has explicit authority.

6\. Store Context Display

The owner console must clearly show store context.

Recommended visible context:

store name
business date
current stage/package
request count
unconfirmed count
critical request count
last refresh time

This prevents:

wrong store operation
wrong request handling
support confusion
cross-store data mistake

7\. Request List

The request list should show active requests clearly.

Recommended fields:

request time
elapsed time
request status
selected items summary
quantity
guest language
critical request flag
translation confidence flag
request version
confirmation status

The list should prioritize:

new requests
critical requests
unconfirmed warnings
forced cleanup required
recent confirmed requests

The list should not look like a full POS order list unless POS integration exists.

8\. Request Detail View

The request detail view should show enough information for store handling.

Recommended fields:

request\_id
request\_time
elapsed\_time
guest language
store language summary
original guest text
selected items
quantities
options
special memo
critical request warnings
translation confidence
request version history
status timeline
available actions

The detail view should include a clear notice:

This is a CatchMenu guest request.
It is not a POS order or payment record.

Korean:

CatchMenu 손님 요청입니다.
POS 주문 또는 결제 기록이 아닙니다.

9\. Stage 0B Owner Console Behavior

In Stage 0B, the owner console receives and displays guest requests.

Allowed actions may include:

view request
open detail
mark viewed if configured
mark handled manually if configured
ask guest for reconfirmation
expire request if configured

Stage 0B should not provide strong confirmation board behavior unless Stage 0C is enabled.

Stage 0B should not automatically lock guest edit unless configured by explicit store action.

10\. Stage 0C Confirmation Board Behavior

In Stage 0C, the owner console provides a request confirmation board.

Required actions:

주문 확인
완료

Recommended English labels:

Confirm Request
Done

Meaning:

Confirm Request
\= the store has seen and acknowledged the request

Done
\= the store marks Stage 0C handling as completed

The board must clearly distinguish:

new request
confirmed request
unconfirmed warning
forced cleanup required
completed
unconfirmed expired

11\. Confirm Request Action

The "Confirm Request" action creates store acknowledgment.

It may trigger:

STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
confirmation timestamp
store actor record
guest status update

It must not trigger:

payment completion
POS transaction creation
KDS ticket creation
benefit grant
settlement
refund decision

Core rule:

Confirm Request acknowledges the request.
It does not complete downstream authorities.

12\. Done Action

The "Done" action marks Stage 0C handling as completed.

It may create:

COMPLETED
completed\_at
completed\_by
manual completion event

It must not mean:

payment completed
POS completed
food served
settlement completed
benefit granted

Recommended merchant-facing clarification:

CatchMenu 요청 처리 완료

not:

결제 완료

13\. Button Simplicity Rule

The initial Stage 0C owner console should avoid too many actions.

Core rule:

Start with fewer buttons.
Add actions only when the store can understand and operate them.

Default required buttons:

주문 확인
완료

Optional buttons may be introduced later:

재확인 필요
품절/불가
손님에게 문의
미처리 만료
수동 처리 완료

Optional actions must have clear state meaning.

14\. Unconfirmed Warning Display

If a request remains unconfirmed past policy threshold, the console should show warning.

Example:

REQUESTED \+ 30 minutes without STORE\_CONFIRMED
→ UNCONFIRMED\_WARNING

The console should show:

warning badge
elapsed time
request summary
critical flag if any
action prompt

Merchant-facing label:

미확인 경고

The warning must not mark the request completed.

15\. Forced Cleanup Display

If unconfirmed requests exceed threshold, the console may enter forced cleanup mode.

Example:

10 or more unconfirmed requests
→ FORCED\_CLEANUP\_REQUIRED

Forced cleanup view should show:

unconfirmed request list
request age
selected items summary
critical warnings
available cleanup actions

Forced cleanup must not allow silent bulk completion.

Core rule:

Forced cleanup means forced awareness.
Forced cleanup does not mean forced completion.

16\. Critical Request Display

Critical requests must be highly visible.

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

Recommended warning:

중요 요청입니다.
자동 번역만 믿지 말고 손님과 확인해주세요.

Critical request display should not be dismissible without trace if the store has confirmed the request.

17\. Translation Confidence Display

The console should show translation confidence when relevant.

Suggested levels:

HIGH
MEDIUM
LOW
UNKNOWN

If confidence is LOW or UNKNOWN, show warning.

번역 신뢰도가 낮습니다.
손님과 직접 확인해주세요.

Translation confidence should be visible before store confirmation.

18\. Original Text And Translation View

The owner console should allow comparison between:

store language summary
original guest language text
structured menu item
structured option
critical tags

Original text preservation helps:

staff reconfirmation
support review
translation dispute
critical request handling

19\. Request Version Display

If guest updates a request, the owner console should show latest version clearly.

Recommended display:

current version
previous version available
updated time
change indicator

The console should avoid staff acting on stale request version.

If stale version is opened, show warning:

This request has been updated.
Please review the latest version.

Korean:

이 요청은 수정되었습니다.
최신 내용을 확인해주세요.

20\. Duplicate Request Warning

If duplicate request is suspected, the console should indicate it.

Possible duplicate signals:

same guest session
same menu items
same store
short time window
same language
same device hint

Duplicate warning should not automatically merge requests.

Core rule:

Duplicate suspicion is not merge authority.

21\. Request Timeline

The owner console may show a simple timeline.

Possible timeline events:

request created
request updated
request sent
store viewed
store confirmed
guest edit locked
unconfirmed warning
forced cleanup required
completed
expired
support review required

Timeline should be support-friendly but not overwhelming.

22\. Notification Behavior

Owner console may provide notifications.

Examples:

sound alert
banner
badge
desktop notification
mobile browser notification
SMS option
Kakao option
push option

Notification is not source of truth.

Core rule:

Notification may fail.
Request state must remain recoverable from the board.

23\. Refresh And Recovery

Owner console must tolerate refresh or reconnect.

The console should recover:

active request list
confirmed request list
unconfirmed warnings
forced cleanup state
critical request indicators
last known status

UI refresh must not erase state.

Core rule:

Browser refresh must not reset operational truth.

24\. Offline Or Unavailable Console

If the owner console becomes unavailable, fallback should be clear.

Possible fallback:

guest shows screen to staff
staff uses manual order process
request remains queued if safe
support signal generated if configured

The system must not claim the store received a request if delivery failed.

25\. Board Source Of Truth

In Stage 0C, the request board is the Stage 0C operational reference.

However, it is not POS or payment source of truth.

Core rule:

Board is Stage 0 request reference.
POS is transaction reference.
Payment system is payment reference.

The owner console should not mix these authorities.

26\. Role And Access Boundary

Owner console access should be scoped.

Possible roles:

store\_owner
store\_manager
store\_staff
hq\_support\_viewer
support\_read\_only

Role determines:

view ability
confirm ability
complete ability
expire ability
support review ability
configuration ability

Support read-only users must not mutate request state.

27\. Merchant-Facing Language

Recommended Korean labels:

신규 요청
요청 확인
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
중요 요청
번역 주의

Recommended caution:

완료는 CatchMenu 요청 처리 완료를 의미합니다.
결제 완료나 POS 완료를 의미하지 않을 수 있습니다.

28\. Avoided Merchant-Facing Terms

Avoid unless support mode or developer mode is enabled:

runtime
adapter
gateway
tenant
Evidence Packet
support signal
Primary read
Secondary view
pgvector
AI gateway

Merchant UI should not expose internal architecture by default.

29\. Support Mode

A support mode may show additional diagnostic information.

Support mode may include:

request\_id
request\_version
state timeline
support signal
evidence packet reference
failure event code
translation confidence
gateway trace id

Support mode must be role-restricted.

Support mode must not expose unrelated guest or tenant data.

30\. Evidence Packet Access

Owner console may show whether support evidence exists.

However, Evidence Packet should not become merchant action authority.

Core rule:

Evidence explains.
Evidence does not approve.

Evidence Packet detail may be restricted to support or HQ roles.

31\. Failure Message Policy

Merchant-facing failure messages should be clear and actionable.

Example:

요청 알림 전송이 지연되었습니다.
요청 목록을 새로고침해 확인해주세요.

Internal diagnostic should be typed and traceable.

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

32\. Fallback Policy

Owner console fallback should preserve evidence.

Examples:

notification fails
→ request remains visible in list

browser refresh fails
→ reload latest server state

forced cleanup UI fails
→ support review or admin recovery

translation warning fails
→ critical request flag remains in request detail

completion action fails
→ request remains active or support review required

Fallback must not silently rewrite state.

33\. Analytics And Monitoring

Owner console may track operational metrics.

Examples:

request\_count
unconfirmed\_count
confirmation\_delay
completion\_delay
forced\_cleanup\_count
critical\_request\_count
translation\_warning\_count
notification\_failure\_count
console\_refresh\_count

Metrics should support merchant improvement and system reliability.

They must not become punitive by default.

34\. Relationship To Guest Web Screen

Guest web screen and owner console must agree on request status.

Examples:

guest sees Request Sent
owner console has REQUESTED

guest sees Store Confirmed
owner console has STORE\_CONFIRMED

guest sees Please ask staff
owner console has GUEST\_EDIT\_LOCKED or RECONFIRMATION\_REQUIRED

Status mismatch should create support signal if persistent.

35\. Relationship To Stage 1

Stage 0 owner console must not show Stage 1 waiting/manual POS handoff controls unless Stage 1 is enabled.

Stage 1 may add:

waiting identity
arrival confirmation
manual POS handoff
staff handoff view

Stage 0 owner console must remain POS-less.

36\. Final Statement

The Stage 0 owner web console exists to help stores see, confirm, and manage guest requests without pretending to be POS, KDS, payment, settlement, or benefit authority.

Final rule:

Show requests clearly.
Confirm requests safely.
Warn about missed requests.
Preserve evidence.
Keep the board simple.
Do not become POS.
Do not become payment.
