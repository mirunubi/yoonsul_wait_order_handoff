# 001290_Implementation_Stage_0_MVP_Cutline.md

1\. Purpose

This document defines the MVP implementation cutline for Stage 0 Entry Runtime.

Stage 0 is the lightweight adoption stage for CatchMenu.

It allows merchants to start without POS integration, KDS integration, payment integration, or table-level infrastructure.

Core purpose:

Define what Stage 0 MVP must implement.
Separate required MVP scope from later enhancements.
Keep Stage 0 lightweight and merchant-friendly.
Prevent Stage 0 from pretending to be POS, KDS, payment, or settlement.

Korean purpose:

Stage 0 MVP에서 반드시 구현할 범위를 정의한다.
필수 MVP와 후순위 확장 범위를 분리한다.
Stage 0을 가볍고 업주 친화적으로 유지한다.
Stage 0이 POS, KDS, 결제, 정산인 것처럼 보이지 않게 한다.

2\. Stage 0 Position

Stage 0 is before full handoff automation.

Stage 0 supports:

QR/NFC menu entry
multilingual menu viewing
menu selection
show-to-staff view
optional request sending to store
optional POS-less request confirmation board

Stage 0 does not support:

POS transaction authority
KDS order authority
payment completion
settlement
legal final order confirmation
automatic kitchen dispatch
full waiting handoff

Core rule:

Stage 0 is request and visibility support.
Stage 0 is not transaction authority.

3\. Stage 0 Sub-Stages

Stage 0 has three sub-stages.

Stage 0A
\= multilingual QR/NFC menu view \+ show-to-staff

Stage 0B
\= send selected request to store owner web console

Stage 0C
\= POS-less request confirmation board

MVP may implement these progressively.

Recommended first MVP order:

0A first
0B second
0C third

However, the document structure must support all three from the beginning.

4\. MVP Must-Have: Entry Media Resolution

Stage 0 MVP must use root-level Entry Media Inventory.

Required:

QR/NFC token scan
server-side Entry Media resolution
store-level context
menu\_context\_id
enabled\_stage
safe inactive fallback
basic scan log

Stage 0 must not own:

Entry Plate registration
Entry Plate recovery
Entry Media reallocation
mapping history ownership
lost/damaged/retired asset lifecycle

Core rule:

Entry Media Inventory resolves.
Stage 0 runs guest flow.

5\. MVP Must-Have: Store-Level Context

Stage 0 MVP must support store-level context.

Required context:

store\_id
menu\_context\_id
enabled\_stage
placement
entry\_media\_id
resolved\_at

Optional context:

table\_id
waiting\_session\_id
membership\_id
payment\_identity

Stage 0 MVP must not require table identity.

Core rule:

Stage 0 POS-less adoption works with table\_id \= null.

6\. MVP Must-Have: Guest Menu View

Stage 0 MVP must provide a guest menu view.

Required:

store name
menu categories
menu items
item name
item price if available
item description if available
basic option display
language selection
safe fallback if menu unavailable

Recommended:

item image placeholder
sold-out flag
spicy flag
allergy warning candidate
popular item marker

Deferred:

advanced personalization
real-time inventory-driven menu hiding
dynamic pricing
membership-only recommendation
AI personalized recommendation

7\. MVP Must-Have: Multilingual Support

Stage 0 MVP should support multilingual menu viewing.

Required:

guest language selection
store default language
translated menu name if available
translated description if available
fallback to store language
critical warning preservation

MVP may begin with limited languages.

Core rule:

Translation assists understanding.
Translation must not erase original menu meaning.

8\. MVP Must-Have: Show-To-Staff View

Stage 0A MVP must support Show-To-Staff View.

Required:

selected items
quantity
options
guest language
store language summary
special memo if allowed
estimated total if available
not-confirmed notice

Required warning:

This is not a confirmed order.
Please confirm with staff.

Korean:

이 화면은 확정 주문이 아닙니다.
직원과 확인해주세요.

Core rule:

Show-to-staff is communication support.
It is not order authority.

9\. MVP Must-Have: Selected Items / Cart-Like Review

Stage 0 MVP may use cart-like UI internally.

Guest-facing wording should avoid payment-commerce confusion.

Allowed wording:

Selected Menu
Your Selection
Review Request
Show Staff

Avoid unless payment exists:

Checkout
Pay Now
Order Completed
Payment Completed

Core rule:

Selection is intent.
Selection is not payment or final order.

10\. MVP Must-Have: Stage 0B Request Send

Stage 0B MVP should support request sending to store.

Required:

request\_id
request\_version
store\_id
menu\_context\_id
selected items
quantity
options
guest memo if allowed
guest language
store language summary
created\_at
request\_status

Request send means:

guest intent was sent to store

Request send does not mean:

store accepted
POS accepted
KDS accepted
payment completed
order finalized

Core rule:

Request sent is communication.
It is not transaction authority.

11\. MVP Must-Have: Owner Request View

Stage 0B MVP should provide a simple owner/store request view.

Required:

new requests list
request detail
selected items
quantity
options
guest memo
guest language
store language summary
critical warning
request time
request version

Owner view should be simple.

Avoid too many buttons in MVP.

Core rule:

Start with fewer actions.
Add operational complexity later.

12\. MVP Must-Have: Stage 0C Confirmation Board

Stage 0C MVP should support a POS-less confirmation board.

Required actions:

Confirm Request
Done

Korean labels:

주문 확인
완료

Meaning:

Confirm Request
\= store acknowledged the request

Done
\= CatchMenu Stage 0 handling is completed

Not meaning:

POS order completed
payment completed
KDS completed
settlement completed

Core rule:

Stage 0C confirmation is store acknowledgment.
It is not POS/payment/KDS authority.

13\. MVP Must-Have: Guest Edit Lock After Store Confirmation

Stage 0C MVP must lock guest edit after store confirmation.

Flow:

REQUESTED
→ STORE\_CONFIRMED
→ GUEST\_EDIT\_LOCKED

Guest-facing message:

The store has confirmed your request.
You can no longer edit it directly.
Please ask staff if you need changes.

Korean:

매장이 요청을 확인했습니다.
이제 직접 수정할 수 없습니다.
변경이 필요하면 직원에게 문의해주세요.

Core rule:

After store confirmation, guest cannot silently change the request.

14\. MVP Must-Have: Unconfirmed Warning

Stage 0C MVP should warn when requests remain unconfirmed.

Default example:

REQUESTED \+ 30 minutes without STORE\_CONFIRMED
→ UNCONFIRMED\_WARNING

Warning means:

store may not have seen this request

Warning does not mean:

order failed legally
customer fault
merchant fault
automatic cancellation with penalty

Core rule:

Unconfirmed warning is operational visibility.
It is not punishment.

15\. MVP Must-Have: Forced Cleanup Guard

Stage 0C MVP should prevent unconfirmed requests from accumulating indefinitely.

Default example:

10 or more unconfirmed requests
→ FORCED\_CLEANUP\_REQUIRED

Allowed cleanup actions:

review request
confirm request
mark unconfirmed expired
send to support review
ask staff to check manually

Prohibited:

bulk auto-complete unconfirmed requests
mark payment complete
mark POS complete
mark KDS complete
delete history

Core rule:

Unconfirmed requests must not be auto-completed as completed orders.

16\. MVP Must-Have: Confirmed Auto-Completion

Stage 0C MVP may allow auto-completion only for confirmed requests.

Allowed:

STORE\_CONFIRMED \+ configured time
→ AUTO\_COMPLETED

or business close:

STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

Prohibited:

REQUESTED without STORE\_CONFIRMED
→ AUTO\_COMPLETED

Core rule:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

17\. MVP Must-Have: Critical Request Handling

Stage 0 MVP must preserve critical request warnings.

Critical categories may include:

allergy
cannot-eat ingredient
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

MVP rule:

Critical warnings must be visible to staff.
Critical warnings must not be hidden by translation.

18\. MVP Must-Have: Translation Confidence

Stage 0 MVP should support basic translation confidence.

Suggested values:

HIGH
MEDIUM
LOW
UNKNOWN

LOW or UNKNOWN should trigger caution.

Core rule:

Low-confidence translation must not be presented as certain operational truth.

19\. MVP Must-Have: Request Versioning

Stage 0B / 0C MVP should support request versioning.

Required:

request\_id
request\_version
previous\_version
is\_current\_version
version\_created\_at
version\_created\_by
change\_reason

If store is viewing stale version, show warning.

Suggested message:

This request has been updated.
Please review the latest version.

Core rule:

Stale request versions must not be confirmed silently.

20\. MVP Must-Have: State Transition Guard

Stage 0 MVP must guard important state transitions.

Required checks:

current\_state
target\_state
stage
actor\_type
actor\_authority
request\_version
store\_id
business\_date
time\_condition
critical\_request\_condition

Prohibited transitions:

REQUESTED → AUTO\_COMPLETED
UNCONFIRMED\_WARNING → AUTO\_COMPLETED
FORCED\_CLEANUP\_REQUIRED → AUTO\_COMPLETED
REQUESTED → PAYMENT\_COMPLETED
REQUESTED → POS\_HANDOFF\_ACCEPTED
REQUESTED → KDS\_HANDOFF\_ACCEPTED

Core rule:

No transition without authority and event.

21\. MVP Must-Have: Event Logging

Stage 0 MVP must create events for important actions.

Suggested events:

MENU\_VIEWED
LANGUAGE\_SELECTED
ITEMS\_SELECTED
SHOW\_TO\_STAFF\_OPENED
REQUEST\_SENT
REQUEST\_UPDATED
STORE\_VIEWED
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
UNCONFIRMED\_WARNING\_CREATED
FORCED\_CLEANUP\_REQUIRED
REQUEST\_COMPLETED
REQUEST\_AUTO\_COMPLETED
REQUEST\_EXPIRED
SUPPORT\_REVIEW\_REQUIRED

Event fields:

event\_id
request\_id
request\_version
previous\_state
new\_state
actor\_type
actor\_id
source\_system
store\_id
created\_at
trace\_id

22\. MVP Must-Have: Support Signal

Stage 0 MVP should emit support signals for exceptional conditions.

Examples:

REQUEST\_SEND\_FAILED
OWNER\_CONSOLE\_UNAVAILABLE
LOW\_CONFIDENCE\_TRANSLATION
CRITICAL\_REQUEST\_DETECTED
STORE\_RECONFIRM\_REQUIRED
REQUEST\_VERSION\_CONFLICT
UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
AUTO\_COMPLETION\_DENIED\_UNCONFIRMED
REQUEST\_STATE\_TRANSITION\_DENIED

Support Signal is not mutation authority.

Core rule:

Support Signal alerts.
Authorized runtime functions act.

23\. MVP Must-Have: Evidence Packet Foundation

Stage 0 MVP should preserve enough evidence to explain a request.

Evidence may include:

entry resolution context
request version history
selected items
translation summary
critical warnings
state timeline
store confirmation event
unconfirmed warning event
auto-completion event
support signal refs
failure event refs

Core rule:

Evidence explains.
Evidence does not approve.

24\. MVP Guest Screen Cutline

MVP guest screens:

QR/NFC landing
language selection
menu list
menu detail
selected menu review
show-to-staff view
send request screen
request sent status
store confirmed status
edit locked screen
inactive/fallback screen

Deferred guest screens:

membership wallet
payment checkout
full order history
advanced personalization
table split payment
loyalty reward redemption

25\. MVP Owner Console Cutline

MVP owner console screens:

request list
request detail
confirm request
done
unconfirmed warning list
forced cleanup alert
basic request status

Deferred owner console screens:

advanced analytics
multi-store dashboard
staff assignment
payment reconciliation
POS adapter monitoring
KDS monitoring
deep audit explorer

26\. MVP Data Cutline

MVP conceptual data areas:

store context
menu context
entry resolution reference
guest session
selected items
request
request version
request event
translation warning
critical request flag
support signal
evidence reference

MVP should not require:

payment ledger
POS transaction table
KDS ticket table
settlement ledger
membership wallet
full CRM identity

27\. MVP AI Cutline

Stage 0 MVP may use AI only as assistance.

Allowed AI assistance:

menu translation draft
request summary draft
critical warning candidate detection
support summary draft

AI must not:

confirm order
approve allergy safety
change request state silently
mark payment complete
mark POS/KDS accepted
decide refund
decide legal responsibility

Core rule:

AI assists.
Human/store/runtime authority decides.

28\. AI Menu Intake Boundary

AI Menu Intake is important but not part of Stage 0 request runtime MVP.

AI Menu Intake belongs to owner/admin onboarding.

Possible future document:

docs/02400\_owner\_console/02440\_AI\_Menu\_Intake\_And\_Menu\_Draft\_Generation\_Policy.md

Stage 0 depends on menu data being available.

It does not own how menu data is created.

Core rule:

Stage 0 consumes menu context.
AI Menu Intake creates draft menu context.

29\. MVP Deferred Scope

Deferred from Stage 0 MVP:

POS adapter
KDS adapter
payment
settlement
table-level ordering
waiting queue handoff
full membership linkage
coupon/benefit calculation
advanced analytics
robot/agent kitchen execution
AI autonomous operation
full franchise reporting

These may belong to later stages.

30\. Stage 0 To Stage 1 Boundary

Stage 0 ends at lightweight request support.

Stage 1 begins when waiting/manual handoff becomes central.

Stage 1 may include:

waiting session
pre-order while waiting
staff review before seating or ordering
manual POS entry support
handoff evidence
guest arrival or readiness state

Stage 0 must not assume Stage 1 data structures are required.

Core rule:

Stage 0 is menu/request visibility.
Stage 1 is waiting-to-order handoff.

31\. MVP Launch Readiness Checklist

Before Stage 0 MVP launch, confirm:

Entry Media resolution works
store-level context works
menu context exists
Stage 0A guest menu works
show-to-staff works
Stage 0B request send works if enabled
owner request view works if enabled
Stage 0C confirmation board works if enabled
unconfirmed warning works if enabled
safe inactive fallback works
critical warning visible
translation fallback works
event log exists
support signal exists
evidence baseline exists

32\. Implementation Priority

Recommended implementation priority:

1\. Entry Media resolution integration
2\. Stage 0A menu view
3\. show-to-staff view
4\. Stage 0B request send
5\. owner request list/detail
6\. Stage 0C confirm/done board
7\. guest edit lock
8\. unconfirmed warning
9\. forced cleanup guard
10\. evidence/support signal baseline

Do not implement advanced scope before basic safety.

33\. MVP Success Definition

Stage 0 MVP is successful when:

a merchant can place one QR/NFC Entry Plate
a guest can scan it
the guest can view menu in a usable language
the guest can select items
the guest can show staff
the guest can send a request if enabled
the store can view and confirm if enabled
unconfirmed requests do not silently become completed
mapping/request history can be explained

34\. Final Rule

Stage 0 MVP must stay lightweight but honest.

Final rule:

Start with QR/NFC.
Resolve store/menu context safely.
Show menu clearly.
Let guest communicate intent.
Let store acknowledge if enabled.
Do not claim POS, KDS, payment, or settlement authority.
Preserve events and evidence.
Block unsafe state transitions.
Keep later stages out of Stage 0 MVP.
