# 004100_Readme_Menu_Availability_Soldout_Runtime.md

1\. Purpose

This folder defines Menu Availability, Sold-out, Limited Quantity, Preorder Blocking, POS/KDS Availability Reference, and Guest-Facing Availability Governance for CatchMenu / Wait Order Handoff.

Waiting-to-order handoff, preorder, reservation pickup, group order, and KDS kitchen continuity all depend on whether a menu item is actually available.

If a guest preorders an item while waiting and the item is already sold out, CatchMenu creates disappointment, staff burden, refund/support friction, and merchant distrust.

Therefore, CatchMenu must define menu availability and sold-out runtime before scaling preorder, reservation, POS handoff, or KDS handoff.

Core purpose:

Define menu availability runtime.
Define sold-out state.
Define limited quantity state.
Define preorder blocking.
Define reservation/pickup availability check.
Define manual availability override.
Define POS availability reference.
Define KDS/kitchen availability signal.
Define guest-facing availability display.
Define support signal and audit.
Prevent unavailable items from entering preorder, POS, or KDS flow.

Korean purpose:

메뉴 availability runtime을 정의한다.
품절 상태를 정의한다.
한정 수량 상태를 정의한다.
선주문 차단을 정의한다.
예약/픽업 availability check를 정의한다.
수동 availability override를 정의한다.
POS availability reference를 정의한다.
KDS/주방 availability signal을 정의한다.
손님 화면 availability 표시를 정의한다.
support signal과 audit을 정의한다.
주문 불가능한 메뉴가 preorder, POS, KDS 흐름으로 들어가는 것을 방지한다.

2\. Scope

This folder covers:

menu availability
sold-out
limited quantity
temporary unavailable
seasonal unavailable
preorder blocking
reservation pickup blocking
manual availability override
POS sold-out reference
KDS kitchen availability signal
inventory reference
guest-facing availability display
store-facing availability control
availability audit
availability support signal

This folder does not define:

full inventory management
warehouse management
supplier ordering
recipe BOM costing
HACCP traceability
legal food safety certification
full POS inventory sync
full KDS implementation
accounting inventory valuation

Related folders:

docs/001000_mvp_scope/001100_Policy_CatchMenu_I18n_Order_Request_Translation.md/
docs/003000_saas_runtime/003100_Readme_Entry_Media_Inventory.md/
docs/03500\_external\_pos\_integration\_runtime/
docs/03800\_native\_all\_in\_one\_service\_runtime/
docs/03900\_merchant\_success\_troubleshooting/
docs/004000_store_runtime_pos_kds_operations/

3\. Core Principle

Unavailable items must not flow into operational commitment.

Core rule:

Do not accept preorder, POS handoff, or KDS handoff for unavailable items unless explicit manual override allows it.

Korean rule:

주문 불가능한 메뉴는 명시적 수동 override가 없는 한 preorder, POS handoff, KDS handoff로 보내지 않는다.

4\. Availability Boundary

Menu availability indicates whether an item can be shown, selected, requested, preordered, or sent to POS/KDS.

Availability does not own:

full inventory quantity truth
supplier stock truth
recipe production truth
payment finality
reservation refund decision
POS order finality
KDS ticket finality

Availability may own or reference:

item visible
item selectable
item sold out
item limited quantity
preorder allowed
pickup allowed
request allowed
manual confirmation required
POS sold-out reference
kitchen availability signal

Core rule:

Availability controls operational eligibility, not full inventory accounting.

5\. Availability States

Suggested availability states:

AVAILABLE
LIMITED
SOLD\_OUT
TEMPORARILY\_UNAVAILABLE
SEASONAL\_UNAVAILABLE
PREORDER\_BLOCKED
PICKUP\_BLOCKED
REQUEST\_ONLY
MANUAL\_CONFIRMATION\_REQUIRED
HIDDEN
REVIEW\_REQUIRED
UNKNOWN

Meaning:

AVAILABLE
\= guest may select under normal rules

LIMITED
\= available but quantity or time restriction applies

SOLD\_OUT
\= not available for selection/order

TEMPORARILY\_UNAVAILABLE
\= unavailable for short operational reason

SEASONAL\_UNAVAILABLE
\= unavailable due to season/menu cycle

PREORDER\_BLOCKED
\= visible but not allowed for preorder

PICKUP\_BLOCKED
\= visible but not allowed for pickup/reservation

REQUEST\_ONLY
\= guest may ask but store must confirm manually

MANUAL\_CONFIRMATION\_REQUIRED
\= store confirmation required before commitment

HIDDEN
\= not shown to guest

REVIEW\_REQUIRED
\= availability state needs human review

UNKNOWN
\= availability not verified

Core rule:

UNKNOWN must not be treated as fully available for high-commitment flows.

6\. Availability By Flow

Availability may differ by flow.

Examples:

dine-in available
takeout unavailable
preorder unavailable
same-day pickup available
reservation group order available only with notice
waiting preorder blocked
request-only allowed

Core rule:

Availability must be flow-specific when store operation differs by channel.

7\. Guest-Facing Display

Guest-facing availability display should be clear.

Possible labels:

Available
Limited quantity
Sold out
Temporarily unavailable
Available for dine-in only
Pickup not available
Preorder not available
Ask staff
Store confirmation required

Korean labels:

주문 가능
한정 수량
품절
일시 품절
매장 식사만 가능
픽업 불가
선주문 불가
직원 확인 필요
매장 확인 필요

Core rule:

Guest display must reduce false expectation.

8\. Store-Facing Control

Store-facing availability control should be fast.

Store may need to:

mark sold out
restore available
set limited quantity
block preorder
block pickup
hide item
mark manual confirmation required
set temporary unavailable
set availability note

Core rule:

Availability control must be fast enough for peak-time operation.

9\. Manual Availability Override

Manual override may be performed by authorized merchant/staff.

Override should record:

actor
previous state
new state
reason
effective time
expiry time if temporary
affected flow
note

Core rule:

Manual availability override must be auditable.

10\. Limited Quantity

Limited quantity may apply when only a fixed count is available.

Limited quantity fields:

limit\_quantity
remaining\_quantity
reserved\_quantity
sold\_quantity reference optional
reset\_time
source

MVP may not support exact inventory count.

MVP may support manual limited state.

Core rule:

Limited quantity must not promise exact stock unless source is reliable.

11\. Sold-Out

Sold-out means item should not be accepted for committed flows.

Sold-out may be triggered by:

manual staff action
POS sold-out reference
kitchen signal
inventory reference
support/operator action
scheduled availability rule

Core rule:

Sold-out should block preorder and automatic handoff by default.

12\. Temporary Unavailable

Temporary unavailable may occur due to:

kitchen delay
ingredient prep delay
equipment issue
peak-time pause
staff shortage
quality issue
temporary supplier issue

Core rule:

Temporary unavailable should have reason and review time.

13\. Preorder Blocking

Preorder should be blocked when:

item sold out
limited quantity exhausted
kitchen cannot prepare ahead
item quality degrades during wait
manual confirmation required
pickup/preorder channel disabled
availability unknown

Core rule:

Preorder blocking protects guest expectation and kitchen execution.

14\. Reservation And Pickup Blocking

Reservation/pickup should be blocked when:

item not available at pickup time
limited quantity cannot be reserved
advance preparation unavailable
group order notice too short
ingredient procurement not confirmed
store capacity exceeded

Core rule:

Reservation/pickup commitment requires availability at the promised time.

15\. Request-Only Mode

Some items may be request-only.

Request-only means:

guest may express interest
store must confirm manually
no automatic POS handoff
no automatic KDS handoff
no firm availability promise

Core rule:

Request-only mode is safer than false availability.

16\. Manual Confirmation Required

Manual confirmation required applies when the system cannot determine availability.

Examples:

limited menu
daily special
market-price item
seasonal item
large quantity request
special preparation item

Core rule:

When availability is uncertain, ask store before commitment.

17\. POS Availability Reference

POS provider may provide sold-out or menu availability reference if supported.

Possible POS references:

POS sold-out status
POS item active/inactive
POS stock count if available
POS menu version
POS item availability flag

POS reference is provider fact.

Core rule:

POS availability reference can inform CatchMenu but must be capability-verified.

18\. KDS Kitchen Availability Signal

KDS or kitchen may provide kitchen availability signal.

Examples:

kitchen paused item
prep capacity limited
station unavailable
ingredient unavailable
delay too high

Core rule:

Kitchen availability signal should prevent unrealistic kitchen commitment.

19\. Inventory Reference

Inventory reference may be added later.

Inventory may provide:

ingredient stock
recipe-level availability
limited quantity
expiry-based blocking
prep batch availability

MVP does not require full inventory.

Core rule:

Availability runtime may reference inventory later without owning full inventory accounting now.

20\. Availability Priority

When multiple sources disagree, priority must be defined.

Suggested priority:

1\. Manual safety block by authorized store/HQ
2\. Food safety or support block
3\. KDS/kitchen unavailable signal
4\. POS sold-out reference
5\. Inventory reference
6\. Scheduled availability rule
7\. Default menu availability

Core rule:

More safety-critical block should override ordinary availability.

21\. Availability Conflict

Availability conflict occurs when sources disagree.

Examples:

POS says available, store marks sold out
menu says available, kitchen says unavailable
inventory says low, guest preorder still allowed
availability unknown but preorder enabled

Actions:

mark REVIEW\_REQUIRED
apply safest block if risk is high
emit support signal
record evidence
require authorized review

Core rule:

Availability conflict must not silently allow risky commitment.

22\. Availability Expiry

Temporary availability states should expire or require review.

Examples:

sold out until tomorrow
temporarily unavailable for 2 hours
preorder blocked for lunch peak
manual confirmation required until reviewed

Core rule:

Temporary availability state should not become permanent by accident.

23\. Availability And Menu Version

Availability may be separate from menu version.

Menu version answers:

what item exists
what price/options exist

Availability answers:

can this item be selected or committed now

Core rule:

Menu existence does not equal operational availability.

24\. Availability And POS Handoff

Before POS handoff, availability should be checked.

Block handoff when:

item sold out
availability unknown for committed flow
manual confirmation required
limited quantity exhausted
availability conflict exists

Core rule:

Do not send unavailable item to POS automation.

25\. Availability And KDS Handoff

Before KDS handoff, kitchen availability should be checked.

Block KDS handoff when:

item unavailable
kitchen paused item
prep capacity blocked
critical availability conflict exists

Core rule:

Do not send impossible work to kitchen execution path.

26\. Availability And Billing

Availability state may affect paid feature value but does not directly change billing unless billing policy defines it.

Core rule:

Availability issue may create support/dispute evidence, not automatic billing adjustment.

27\. Availability Audit Events

Recommended audit events:

MENU\_AVAILABILITY\_MARKED\_AVAILABLE
MENU\_AVAILABILITY\_MARKED\_SOLD\_OUT
MENU\_AVAILABILITY\_MARKED\_LIMITED
MENU\_AVAILABILITY\_MARKED\_TEMP\_UNAVAILABLE
MENU\_AVAILABILITY\_PREORDER\_BLOCKED
MENU\_AVAILABILITY\_PICKUP\_BLOCKED
MENU\_AVAILABILITY\_MANUAL\_CONFIRMATION\_REQUIRED
MENU\_AVAILABILITY\_CONFLICT\_DETECTED
MENU\_AVAILABILITY\_REVIEW\_REQUIRED
MENU\_AVAILABILITY\_RESTORED
MENU\_AVAILABILITY\_OVERRIDE\_APPLIED

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
reason
effective\_at
expires\_at optional
created\_at
trace\_id

28\. Failure Events

Example failure codes:

WOH.AVAILABILITY.ITEM\_SOLD\_OUT
WOH.AVAILABILITY.LIMITED\_QUANTITY\_EXHAUSTED
WOH.AVAILABILITY.UNKNOWN\_BLOCKED
WOH.AVAILABILITY.CONFLICT\_REVIEW\_REQUIRED
WOH.AVAILABILITY.PREORDER\_BLOCKED
WOH.AVAILABILITY.PICKUP\_BLOCKED
WOH.AVAILABILITY.POS\_REFERENCE\_UNVERIFIED
WOH.AVAILABILITY.KITCHEN\_SIGNAL\_REQUIRED
WOH.AVAILABILITY.MANUAL\_CONFIRMATION\_REQUIRED

Failure/error naming is governed by:

docs/000080_Governance_CatchMenu_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy.md

29\. Support Signals

Support signals may include:

MENU\_AVAILABILITY\_REVIEW\_REQUIRED
SOLD\_OUT\_NOT\_REFLECTED
PREORDER\_BLOCKED\_BY\_AVAILABILITY
PICKUP\_BLOCKED\_BY\_AVAILABILITY
POS\_AVAILABILITY\_CONFLICT
KDS\_AVAILABILITY\_CONFLICT
LIMITED\_QUANTITY\_RISK
AVAILABILITY\_UNKNOWN\_FOR\_COMMITMENT
TEMP\_UNAVAILABLE\_EXPIRED\_REVIEW\_REQUIRED

Support Signal alerts.

It does not change availability by itself.

30\. Relationship To Reservation Preorder Governance

Reservation/preorder commitment depends on availability.

Core rule:

Reservation/preorder must check availability before commitment.

31\. Relationship To POS Integration

POS may provide availability reference.

Core rule:

POS sold-out reference may inform CatchMenu only when provider capability is verified.

32\. Relationship To KDS Integration

KDS/kitchen may provide prep availability.

Core rule:

Kitchen execution should not receive unavailable item.

33\. Relationship To AI Menu Stabilization

AI menu can create menu item, but cannot guarantee availability.

Core rule:

AI menu draft defines what exists, not what is currently available.

34\. MVP Requirements

MVP should support at least:

manual sold-out
manual restore available
manual temporary unavailable
manual preorder block
manual pickup block
manual confirmation required
guest-facing label
store-facing control
availability audit event
availability failure event
availability support signal

MVP may defer:

real-time inventory sync
POS sold-out sync
KDS availability sync
limited quantity exact count
automatic recipe stock deduction
advanced availability prediction

35\. Suggested Conceptual Entities

Suggested entities:

menu\_availability\_states
menu\_availability\_overrides
menu\_availability\_rules
limited\_quantity\_records
availability\_conflicts
availability\_audit\_events
availability\_failure\_events
availability\_support\_signals

This document defines policy.

Actual schema may be designed later.

36\. Risk If Skipped

If Menu Availability Soldout Runtime is skipped, risks include:

sold-out items are preordered
limited menu is over-promised
guest arrives expecting unavailable food
staff must apologize manually
refund/support friction increases
POS handoff sends unavailable item
KDS receives impossible ticket
merchant loses trust
waiting-to-order value collapses

Therefore, menu availability must be governed before preorder, POS automation, or KDS handoff scales.

37\. Final Rule

Availability controls whether menu intent can become operation commitment.

Final rule:

Menu existence is not availability.
Check availability before preorder.
Check availability before pickup commitment.
Check availability before POS handoff.
Check availability before KDS handoff.
Block sold-out items.
Treat unknown as risky for committed flows.
Allow request-only or manual confirmation when uncertain.
Record manual overrides.
Resolve conflicts safely.
Audit availability changes.
Do not let unavailable items become operational promises.
