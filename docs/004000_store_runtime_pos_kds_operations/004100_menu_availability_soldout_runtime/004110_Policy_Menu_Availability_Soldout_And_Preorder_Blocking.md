# 004110_Policy_Menu_Availability_Soldout_And_Preorder_Blocking.md

1\. Purpose

This document defines Menu Availability, Sold-out, and Preorder Blocking policy for CatchMenu / Wait Order Handoff.

CatchMenu may allow guests to view menus, select items, send requests, create preorders, reserve pickup, or prepare waiting-to-order handoff.

However, not every visible menu item should be eligible for every operational flow.

A menu item can exist in the menu but be unavailable for preorder, sold out for the day, blocked for pickup, limited to dine-in, or require manual store confirmation.

Therefore, CatchMenu must check availability before turning guest intent into an operational commitment.

Core purpose:

Define menu availability.
Define sold-out behavior.
Define preorder blocking.
Define pickup/reservation blocking.
Define request-only mode.
Define manual confirmation required mode.
Define guest-facing availability label.
Define store-facing availability override.
Define availability conflict handling.
Prevent unavailable items from becoming preorder, POS handoff, or KDS handoff commitments.

Korean purpose:

메뉴 availability를 정의한다.
품절 동작을 정의한다.
선주문 차단을 정의한다.
픽업/예약 차단을 정의한다.
request-only mode를 정의한다.
manual confirmation required mode를 정의한다.
손님 화면 availability label을 정의한다.
매장 화면 availability override를 정의한다.
availability conflict 처리를 정의한다.
주문 불가능한 메뉴가 preorder, POS handoff, KDS handoff commitment가 되는 것을 방지한다.

2\. Scope

This document covers:

menu availability state
sold-out state
temporary unavailable state
preorder blocking
pickup blocking
reservation blocking
request-only mode
manual confirmation required mode
guest display label
store override
availability conflict
availability check before POS handoff
availability check before KDS handoff
availability audit
support signal
failure event

This document does not define:

full inventory quantity accounting
warehouse stock
supplier ordering
recipe BOM
HACCP traceability
POS provider sold-out sync implementation
KDS provider implementation
payment settlement
refund decision finality

Related documents:

04100\_Menu\_Availability\_Soldout\_Runtime\_Readme.md
04120\_Limited\_Quantity\_Menu\_And\_Waiting\_Preorder\_Control\_Policy.md
04130\_POS\_KDS\_Inventory\_Availability\_Sync\_Policy.md
03100\_Reservation\_Preorder\_Governance\_Readme.md
03500\_External\_POS\_Integration\_Runtime\_Readme.md
04000\_KDS\_Integration\_And\_Kitchen\_Continuity\_Readme.md
03930\_AI\_Menu\_Intake\_Correction\_And\_Live\_Menu\_Stabilization\_Policy.md

3\. Core Principle

Menu visibility does not equal operational availability.

Core rule:

A menu item may be visible.
That does not mean it may be preordered, reserved, sent to POS, or sent to KDS.

Korean rule:

메뉴가 보인다고 해서 선주문, 예약, POS 전송, KDS 전송이 가능한 것은 아니다.

4\. Availability State

Suggested availability states:

AVAILABLE
LIMITED
SOLD\_OUT
TEMPORARILY\_UNAVAILABLE
SEASONAL\_UNAVAILABLE
PREORDER\_BLOCKED
PICKUP\_BLOCKED
RESERVATION\_BLOCKED
REQUEST\_ONLY
MANUAL\_CONFIRMATION\_REQUIRED
HIDDEN
REVIEW\_REQUIRED
UNKNOWN

Core rule:

Availability state must be checked by flow type.

5\. Flow-Specific Availability

Availability should be evaluated per flow.

Flow types:

MENU\_VIEW
REQUEST
SHOW\_TO\_STAFF
PREORDER
WAITING\_PREORDER
RESERVATION
PREPAID\_PICKUP
POS\_HANDOFF
KDS\_HANDOFF

Example:

An item may be visible in MENU\_VIEW.
The same item may be blocked for PREORDER.
The same item may require manual confirmation for RESERVATION.
The same item may be blocked for KDS\_HANDOFF if kitchen capacity is unavailable.

Core rule:

One item can have different availability by flow.

6\. Sold-Out Behavior

SOLD\_OUT means the item should not be accepted into committed flows.

Default SOLD\_OUT behavior:

visible or hidden depending on store setting
not selectable for preorder
not eligible for prepaid pickup
not eligible for automatic POS handoff
not eligible for KDS handoff
may show sold-out label
may allow request-only if store explicitly permits

Core rule:

Sold-out blocks commitment by default.

7\. Temporary Unavailable Behavior

TEMPORARILY\_UNAVAILABLE means the item is unavailable for a short operational reason.

Examples:

ingredient prep delay
kitchen overload
equipment issue
quality issue
peak-time pause
staff shortage
short-term stock uncertainty

Temporary unavailable should include:

reason
effective time
expected review time
affected flow
actor

Core rule:

Temporary unavailable must have review or expiry.

8\. Seasonal Unavailable Behavior

SEASONAL\_UNAVAILABLE means the item exists but is not available in current season/menu cycle.

Behavior:

may be hidden
may be shown as seasonal
not eligible for committed order flow
not eligible for POS/KDS handoff

Core rule:

Seasonal unavailable should not appear as currently orderable.

9\. Preorder Blocking

Preorder should be blocked when:

item is SOLD\_OUT
item is TEMPORARILY\_UNAVAILABLE
item is SEASONAL\_UNAVAILABLE
item is LIMITED and quantity exhausted
item quality degrades if prepared ahead
kitchen cannot accept advance prep
availability is UNKNOWN
manual confirmation is required
store disabled preorder for item

Core rule:

Preorder blocking prevents false preparation promises.

10\. Waiting Preorder Blocking

Waiting preorder has higher risk than simple request because it implies future preparation timing.

Block waiting preorder when:

availability cannot be guaranteed until seating
limited quantity may be exhausted before seating
kitchen timing is uncertain
item requires immediate cooking only
manual confirmation required
store capacity is constrained

Core rule:

Waiting preorder should not promise food that may disappear before seating.

11\. Pickup Blocking

Pickup should be blocked when:

item cannot be packed
item quality degrades before pickup
pickup time is outside availability window
item requires dine-in only
limited quantity cannot be reserved
store disabled pickup for item

Core rule:

Pickup availability must match pickup time and packaging reality.

12\. Reservation Blocking

Reservation or group order should be blocked when:

ingredient procurement not confirmed
large quantity unavailable
notice period too short
limited quantity cannot be guaranteed
kitchen capacity not confirmed
manual confirmation required

Core rule:

Reservation commitment requires availability at the promised preparation time.

13\. Request-Only Mode

REQUEST\_ONLY means the guest may express interest but store must confirm manually.

Allowed for:

daily special
limited item
market-price item
uncertain availability
large quantity request
custom preparation item

Request-only must not imply:

order accepted
item reserved
kitchen preparing
payment finality

Core rule:

Request-only is safer than false commitment.

14\. Manual Confirmation Required

MANUAL\_CONFIRMATION\_REQUIRED means store approval is required before commitment.

Use when:

availability uncertain
quantity uncertain
prep time uncertain
price uncertain
kitchen capacity uncertain
special request involved

Core rule:

Uncertain availability must go through store confirmation before commitment.

15\. UNKNOWN Availability

UNKNOWN means the system cannot verify availability.

UNKNOWN should default to conservative behavior for high-commitment flows.

Suggested behavior:

MENU\_VIEW allowed with caution if configured
REQUEST allowed if request-only mode
PREORDER blocked
PREPAID\_PICKUP blocked
POS\_HANDOFF blocked
KDS\_HANDOFF blocked
manual confirmation required

Core rule:

UNKNOWN is not AVAILABLE for committed flows.

16\. Guest-Facing Labels

Guest-facing labels should be clear.

Suggested labels:

Available
Limited quantity
Sold out
Temporarily unavailable
Seasonal item
Preorder not available
Pickup not available
Store confirmation required
Ask staff

Korean labels:

주문 가능
한정 수량
품절
일시 품절
시즌 메뉴
선주문 불가
픽업 불가
매장 확인 필요
직원 확인 필요

Core rule:

Guest label must match actual flow restriction.

17\. Store-Facing Controls

Store-facing controls should support fast changes.

Controls:

mark sold out
restore available
mark temporary unavailable
set review time
block preorder
block pickup
block reservation
set request-only
set manual confirmation required
hide item
add availability note

Core rule:

Availability control must be usable during live service.

18\. Availability Override Authority

Availability override may be done by authorized users only.

Possible actors:

merchant owner
store manager
authorized menu editor
authorized store operator
CatchMenu support operator with scope
HQ operator with scope

Core rule:

Availability change is operational authority and must be scoped.

19\. Availability Override Evidence

Override evidence should include:

actor
previous state
new state
reason
affected flow
effective time
expiry/review time
note
source

Core rule:

Availability override must be explainable after service.

20\. Availability Conflict

Conflict examples:

store marks sold out but POS says available
POS says sold out but store marks available
kitchen says unavailable but menu says available
inventory says low but preorder allowed
availability unknown but POS handoff enabled

Conflict handling:

mark REVIEW\_REQUIRED
apply conservative block if guest commitment risk exists
emit support signal
record source disagreement
require authorized review

Core rule:

Availability conflict should protect guest expectation first.

21\. Availability Check Before Preorder

Before preorder is created, check:

item availability state
flow-specific preorder permission
limited quantity if applicable
manual confirmation requirement
kitchen capacity warning if available
pickup/reservation timing if relevant

Core rule:

Preorder must be blocked or marked request-only when availability is uncertain.

22\. Availability Check Before POS Handoff

Before POS handoff, check:

item not sold out
item not blocked for flow
required option available
availability source trusted
mapping still valid
manual confirmation completed if required

Core rule:

Do not send unavailable item to POS automation.

23\. Availability Check Before KDS Handoff

Before KDS handoff, check:

item available
kitchen not paused
prep capacity available or manually approved
limited quantity not exhausted
critical availability conflict absent

Core rule:

Do not send impossible work to kitchen execution.

24\. Availability Review Timing

Availability should be reviewed:

before lunch peak
before dinner peak
after menu change
after POS menu sync
after kitchen sold-out signal
after support issue
after temporary unavailable expiry

Core rule:

Availability must be refreshed around operational peaks.

25\. Availability Expiry

Temporary states should expire or require review.

Examples:

TEMPORARILY\_UNAVAILABLE until 14:00
PREORDER\_BLOCKED during lunch peak
MANUAL\_CONFIRMATION\_REQUIRED until manager review
LIMITED until remaining quantity reset

Core rule:

Temporary block must not become accidental permanent state.

26\. Availability And Customer Expectation

If guest already selected an item that becomes unavailable, system should handle carefully.

Possible actions:

warn before send
require store confirmation
allow substitution suggestion later
cancel item with explanation
support case if paid/prepaid

Core rule:

Availability change after selection must not create silent guest disappointment.

27\. Availability And Support

Support should see:

availability state at request time
availability source
override history
conflict status
preorder block reason
POS/KDS block reason
support notes

Core rule:

Availability support requires time-based evidence.

28\. Audit Events

Recommended audit events:

MENU\_AVAILABILITY\_CHANGED
MENU\_SOLD\_OUT\_MARKED
MENU\_AVAILABLE\_RESTORED
MENU\_TEMP\_UNAVAILABLE\_MARKED
MENU\_PREORDER\_BLOCKED
MENU\_PICKUP\_BLOCKED
MENU\_RESERVATION\_BLOCKED
MENU\_REQUEST\_ONLY\_MARKED
MENU\_MANUAL\_CONFIRMATION\_REQUIRED
MENU\_AVAILABILITY\_CONFLICT\_DETECTED
MENU\_AVAILABILITY\_REVIEW\_COMPLETED
MENU\_AVAILABILITY\_EXPIRED\_REVIEW\_REQUIRED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
menu\_item\_id
actor\_type
actor\_id
action
previous\_value
new\_value
affected\_flow
reason
effective\_at
expires\_at optional
created\_at
trace\_id

29\. Failure Events

Example failure codes:

WOH.AVAILABILITY.SOLD\_OUT\_BLOCKED
WOH.AVAILABILITY.PREORDER\_BLOCKED
WOH.AVAILABILITY.PICKUP\_BLOCKED
WOH.AVAILABILITY.RESERVATION\_BLOCKED
WOH.AVAILABILITY.UNKNOWN\_REQUIRES\_CONFIRMATION
WOH.AVAILABILITY.CONFLICT\_REVIEW\_REQUIRED
WOH.AVAILABILITY.MANUAL\_CONFIRMATION\_REQUIRED
WOH.AVAILABILITY.EXPIRED\_STATE\_REVIEW\_REQUIRED
WOH.AVAILABILITY.POS\_HANDOFF\_BLOCKED
WOH.AVAILABILITY.KDS\_HANDOFF\_BLOCKED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

30\. Support Signals

Support signals may include:

SOLD\_OUT\_ITEM\_SELECTED
PREORDER\_BLOCKED\_BY\_SOLD\_OUT
PICKUP\_BLOCKED\_BY\_AVAILABILITY
RESERVATION\_BLOCKED\_BY\_AVAILABILITY
AVAILABILITY\_UNKNOWN\_FOR\_PREORDER
AVAILABILITY\_CONFLICT\_REVIEW\_REQUIRED
MANUAL\_CONFIRMATION\_PENDING
TEMP\_AVAILABILITY\_REVIEW\_OVERDUE
POS\_HANDOFF\_BLOCKED\_BY\_AVAILABILITY
KDS\_HANDOFF\_BLOCKED\_BY\_AVAILABILITY

Support Signal alerts.

It does not change availability by itself.

31\. Relationship To Limited Quantity Policy

Limited quantity is a specialized availability case.

Core rule:

When quantity matters, availability must connect to limited quantity control.

32\. Relationship To POS/KDS Inventory Availability Sync

POS, KDS, or inventory may provide availability source.

Core rule:

External availability source must be trusted only when capability and timestamp are known.

33\. Relationship To Reservation Preorder Governance

Reservation/preorder commitment depends on availability.

Core rule:

Reservation/preorder policy cannot safely commit without availability check.

34\. Relationship To AI Menu Stabilization

AI menu may create item records, but availability must be operationally controlled.

Core rule:

AI-generated menu item is not automatically available.

35\. MVP Requirements

MVP should support at least:

manual sold-out
restore available
temporary unavailable
preorder blocked
pickup blocked
reservation blocked
request-only
manual confirmation required
guest-facing label
store-facing override
availability audit event
failure event
support signal

MVP may defer:

real-time POS sold-out sync
KDS availability sync
exact limited quantity deduction
automatic substitution recommendation
inventory-based blocking
advanced scheduled availability

36\. Suggested Conceptual Entities

Suggested entities:

menu\_availability\_states
menu\_flow\_availability\_rules
menu\_availability\_overrides
menu\_availability\_conflicts
menu\_availability\_audit\_events
menu\_availability\_failure\_events
menu\_availability\_support\_signals

This document defines policy.

Actual schema may be designed later.

37\. Risk If Skipped

If Menu Availability Sold-out and Preorder Blocking policy is skipped, risks include:

sold-out items are preordered
pickup promise fails
reservation/group order promise fails
POS receives unavailable item
KDS receives impossible ticket
staff must apologize manually
guest trust decreases
support/refund burden increases
merchant loses confidence in CatchMenu

Therefore, availability blocking must exist before preorder, pickup, POS automation, or KDS automation scales.

38\. Final Rule

Availability must be checked before commitment.

Final rule:

Menu visibility is not availability.
Check availability by flow.
Block sold-out items.
Block preorder when uncertain.
Block pickup when unavailable.
Require manual confirmation when needed.
Use request-only instead of false promise.
Check availability before POS handoff.
Check availability before KDS handoff.
Record overrides.
Resolve conflicts conservatively.
Protect guest expectation first.
