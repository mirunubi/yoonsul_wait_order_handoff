# 04120_Policy_Limited_Quantity_Menu_And_Waiting_Preorder_Control

1\. Purpose

This document defines Limited Quantity Menu and Waiting Preorder Control policy for CatchMenu / Wait Order Handoff.

Limited quantity menus create high operational risk when connected to waiting, preorder, reservation, pickup, POS handoff, or KDS handoff.

A guest may select a limited item while waiting, but the item may be sold out before seating.

A guest may place a pickup preorder, but the remaining quantity may be consumed by dine-in customers before pickup time.

A store may accept a group order, but the available quantity may not support the promised preparation.

Therefore, CatchMenu must define limited quantity control before allowing limited items to become operational commitments.

Core purpose:

Define limited quantity menu policy.
Define remaining quantity reference.
Define reserved quantity.
Define preorder quantity hold.
Define waiting preorder quantity control.
Define reservation/pickup quantity control.
Define quantity exhaustion behavior.
Define manual quantity override.
Define POS/KDS quantity sync boundary.
Prevent over-promising limited items.

Korean purpose:

한정 수량 메뉴 정책을 정의한다.
남은 수량 reference를 정의한다.
예약 수량을 정의한다.
선주문 수량 hold를 정의한다.
대기 선주문 수량 제어를 정의한다.
예약/픽업 수량 제어를 정의한다.
수량 소진 동작을 정의한다.
수동 수량 override를 정의한다.
POS/KDS 수량 sync 경계를 정의한다.
한정 메뉴를 과도하게 약속하는 것을 방지한다.

2\. Scope

This document covers:

limited quantity menu
remaining quantity
reserved quantity
quantity hold
quantity release
waiting preorder quantity
pickup preorder quantity
reservation quantity
group order quantity
quantity exhaustion
manual quantity override
quantity conflict
POS quantity reference
KDS kitchen quantity signal
audit event
support signal

This document does not define:

full inventory accounting
ingredient-level stock
warehouse management
supplier ordering
recipe BOM
automatic stock deduction from every POS
financial inventory valuation
food safety certification

Related documents:

04100\_Menu\_Availability\_Soldout\_Runtime\_Readme.md
04110\_Menu\_Availability\_Soldout\_And\_Preorder\_Blocking\_Policy.md
04130\_POS\_KDS\_Inventory\_Availability\_Sync\_Policy.md
03100\_Reservation\_Preorder\_Governance\_Readme.md
03500\_External\_POS\_Integration\_Runtime\_Readme.md
04000\_KDS\_Integration\_And\_Kitchen\_Continuity\_Readme.md

3\. Core Principle

Limited quantity must not be promised without quantity control.

Core rule:

Limited item visibility is allowed.
Limited item commitment requires quantity control.

Korean rule:

한정 메뉴를 보여줄 수는 있다.
하지만 한정 메뉴를 약속하려면 수량 제어가 필요하다.

4\. Limited Quantity Boundary

Limited quantity controls commitment eligibility.

It does not own full inventory accounting.

Limited quantity may own or reference:

available quantity
remaining quantity
reserved quantity
hold quantity
sold-out threshold
reset rule
manual override
quantity conflict
preorder block
pickup block
KDS quantity warning

It does not own:

ingredient stock ledger
supplier delivery
recipe production truth
accounting valuation
final POS sales truth
refund finality

Core rule:

Limited quantity is operational promise control, not full inventory ledger.

5\. Limited Quantity States

Suggested states:

NOT\_LIMITED
LIMITED\_AVAILABLE
LIMITED\_LOW
LIMITED\_HOLD\_REQUIRED
LIMITED\_EXHAUSTED
LIMITED\_CONFLICT
LIMITED\_REVIEW\_REQUIRED
LIMITED\_MANUAL\_CONFIRMATION\_REQUIRED

Meaning:

NOT\_LIMITED
\= no quantity control applies

LIMITED\_AVAILABLE
\= limited item available

LIMITED\_LOW
\= remaining quantity below threshold

LIMITED\_HOLD\_REQUIRED
\= quantity must be held before commitment

LIMITED\_EXHAUSTED
\= no quantity remains

LIMITED\_CONFLICT
\= quantity sources disagree

LIMITED\_REVIEW\_REQUIRED
\= human review required

LIMITED\_MANUAL\_CONFIRMATION\_REQUIRED
\= store confirmation required before commitment

Core rule:

LIMITED\_EXHAUSTED blocks committed flows by default.

6\. Quantity Types

Quantity control may use different quantity types.

Suggested types:

declared\_quantity
remaining\_quantity
reserved\_quantity
hold\_quantity
sold\_quantity\_reference
released\_quantity
adjusted\_quantity
unknown\_quantity

Meaning:

declared\_quantity
\= quantity initially declared by store or source

remaining\_quantity
\= quantity believed available

reserved\_quantity
\= quantity committed to future use

hold\_quantity
\= temporary hold before final commitment

sold\_quantity\_reference
\= POS or store sales reference if available

released\_quantity
\= hold or reservation released

adjusted\_quantity
\= manual correction

unknown\_quantity
\= quantity not reliable

Core rule:

Quantity meaning must be explicit before commitment.

7\. Quantity Source

Quantity may come from:

manual store input
POS sold count reference
POS remaining quantity if supported
KDS/kitchen prep count
inventory system later
support/operator correction
scheduled batch quantity
reservation/group order allocation

Core rule:

Quantity source must be recorded with timestamp.

8\. Quantity Reliability

Not all quantity sources are equally reliable.

Suggested reliability levels:

HIGH
MEDIUM
LOW
UNKNOWN

Examples:

manual count during service
\= MEDIUM unless confirmed

POS remaining quantity
\= depends on provider capability

inventory estimate
\= LOW if not real-time

kitchen declared batch
\= MEDIUM/HIGH depending on process

Core rule:

Low reliability quantity should not support high-commitment preorder without confirmation.

9\. Quantity Hold

Quantity hold reserves a limited item temporarily.

Hold may be used for:

waiting preorder
prepaid pickup
reservation
group order
store-confirmed request

Hold should include:

hold\_id
menu\_item\_id
quantity
flow\_type
guest/session reference
reservation/preorder reference
expires\_at
status
created\_at

Core rule:

Quantity hold must expire or convert to commitment.

10\. Hold Status

Suggested hold statuses:

HOLD\_REQUESTED
HELD
HOLD\_FAILED
HOLD\_EXPIRED
HOLD\_RELEASED
COMMITTED
CANCELLED
REVIEW\_REQUIRED

Core rule:

Held quantity must not remain locked forever.

11\. Waiting Preorder Quantity Control

Waiting preorder has quantity risk because seating may happen later.

Before accepting waiting preorder for limited item, check:

remaining quantity
expected seating delay
hold policy
kitchen capacity
store confirmation requirement
quantity reliability

Possible behavior:

allow with hold
allow with manual confirmation
request-only
block preorder
show limited warning

Core rule:

Waiting preorder for limited item requires hold or store confirmation.

12\. Pickup Preorder Quantity Control

Pickup preorder creates time-based commitment.

Before accepting pickup preorder, check:

remaining quantity at requested pickup time
hold duration
pickup window
quality holding time
store capacity
payment/deposit state if applicable

Core rule:

Pickup preorder should not consume uncertain limited quantity without hold policy.

13\. Reservation Quantity Control

Reservation and group order may need advance allocation.

Before confirming reservation quantity:

check declared quantity
check procurement/prep feasibility
hold or allocate quantity
record preparation commitment
record cancellation/release rule

Core rule:

Reservation quantity must be committed only when store can support it.

14\. Group Order Quantity Control

Group order quantity may exceed normal limited quantity rules.

Group order should require:

advance notice
store confirmation
quantity allocation
prep plan
deposit/payment rule if applicable
cancellation/release rule

Core rule:

Large quantity should not be accepted through ordinary limited item flow.

15\. Quantity Exhaustion

Quantity exhaustion means limited item should be blocked for committed flows.

When exhausted:

mark LIMITED\_EXHAUSTED
block preorder
block pickup
block reservation unless manual override
block POS handoff
block KDS handoff
show sold-out or limited exhausted label
emit support signal if conflicts exist

Core rule:

Exhausted limited item must behave like sold-out for commitment.

16\. Low Quantity Warning

Low quantity may trigger warning before exhaustion.

Low quantity threshold may be:

fixed number
percentage of declared quantity
store-defined threshold
system default

Behavior:

show limited quantity label
require confirmation for larger quantities
block large preorder
notify store

Core rule:

Low quantity should reduce over-commitment before sold-out occurs.

17\. Quantity Release

Quantity release occurs when a hold or commitment is cancelled.

Release reasons:

guest cancels
store rejects
hold expires
payment fails
reservation cancelled
pickup no-show policy releases or disposes
manual operator release

Core rule:

Quantity release must be tied to cancellation or expiry reason.

18\. No-Show And Quantity

No-show may affect limited quantity.

If item was prepared:

quantity may not return to available
food may be disposed
refund/forfeit policy applies separately

If item was held but not prepared:

quantity may be released

Core rule:

No-show quantity handling depends on preparation state.

19\. Manual Quantity Override

Authorized users may override quantity.

Override actions:

set declared quantity
adjust remaining quantity
mark exhausted
restore quantity
release hold
force review

Override evidence:

actor
previous quantity
new quantity
reason
source
effective time
note

Core rule:

Manual quantity override must be auditable.

20\. Quantity Conflict

Quantity conflict occurs when sources disagree.

Examples:

store says 3 left, POS suggests 0
KDS says unavailable, inventory says available
hold count exceeds remaining quantity
manual override conflicts with reservation allocation

Actions:

mark LIMITED\_CONFLICT
block high-commitment flows
emit support signal
require review
preserve evidence

Core rule:

Quantity conflict should block risky commitment.

21\. Quantity And POS Handoff

Before POS handoff, check quantity state.

Block POS handoff when:

LIMITED\_EXHAUSTED
LIMITED\_CONFLICT
hold required but missing
manual confirmation required but absent
quantity unknown for committed flow

Core rule:

Do not send limited item to POS if quantity commitment is unsafe.

22\. Quantity And KDS Handoff

Before KDS handoff, check quantity state.

Block KDS handoff when:

item exhausted
quantity hold missing
kitchen quantity not confirmed
quantity conflict exists
manual confirmation required

Core rule:

Do not send limited item to kitchen if quantity is not secured.

23\. Quantity And Guest Display

Guest-facing display should be careful.

Allowed labels:

Limited quantity
Few left
Store confirmation required
Sold out
Temporarily unavailable

Avoid exact quantity unless reliable.

Not recommended when uncertain:

Only 3 left
Guaranteed reserved
Definitely available until seating

Core rule:

Exact remaining quantity should be shown only when reliable.

24\. Quantity And Staff Display

Staff-facing display may show more detail.

Staff may see:

declared quantity
remaining quantity
held quantity
reserved quantity
quantity source
last updated time
conflict warning
manual override action

Core rule:

Staff needs enough quantity detail to make safe decisions.

25\. Quantity Review Timing

Quantity should be reviewed:

before opening
before lunch peak
before dinner peak
after batch prep
after POS sync
after group order confirmation
after support issue
after manual override

Core rule:

Limited quantity must be reviewed around operational peaks.

26\. Audit Events

Recommended audit events:

LIMITED\_QUANTITY\_DECLARED
LIMITED\_QUANTITY\_ADJUSTED
LIMITED\_QUANTITY\_LOW\_MARKED
LIMITED\_QUANTITY\_EXHAUSTED
LIMITED\_QUANTITY\_RESTORED
QUANTITY\_HOLD\_REQUESTED
QUANTITY\_HELD
QUANTITY\_HOLD\_FAILED
QUANTITY\_HOLD\_EXPIRED
QUANTITY\_HOLD\_RELEASED
QUANTITY\_COMMITTED
QUANTITY\_CONFLICT\_DETECTED
QUANTITY\_MANUAL\_OVERRIDE\_APPLIED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
menu\_item\_id
actor\_type
actor\_id
action
previous\_quantity
new\_quantity
flow\_type
reason
created\_at
trace\_id

27\. Failure Events

Example failure codes:

WOH.QUANTITY.LIMITED\_EXHAUSTED
WOH.QUANTITY.HOLD\_REQUIRED
WOH.QUANTITY.HOLD\_FAILED
WOH.QUANTITY.HOLD\_EXPIRED
WOH.QUANTITY.CONFLICT\_REVIEW\_REQUIRED
WOH.QUANTITY.UNKNOWN\_BLOCKED
WOH.QUANTITY.POS\_HANDOFF\_BLOCKED
WOH.QUANTITY.KDS\_HANDOFF\_BLOCKED
WOH.QUANTITY.MANUAL\_CONFIRMATION\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

28\. Support Signals

Support signals may include:

LIMITED\_QUANTITY\_LOW
LIMITED\_QUANTITY\_EXHAUSTED
QUANTITY\_HOLD\_FAILED
QUANTITY\_HOLD\_EXPIRING
QUANTITY\_CONFLICT\_REVIEW\_REQUIRED
WAITING\_PREORDER\_QUANTITY\_RISK
PICKUP\_QUANTITY\_RISK
GROUP\_ORDER\_QUANTITY\_REVIEW\_REQUIRED
POS\_HANDOFF\_BLOCKED\_BY\_QUANTITY
KDS\_HANDOFF\_BLOCKED\_BY\_QUANTITY

Support Signal alerts.

It does not change quantity by itself.

29\. Relationship To Availability Policy

Limited quantity is a stricter availability condition.

Core rule:

Availability says whether item may be selected.
Limited quantity says whether enough commitment capacity remains.

30\. Relationship To Reservation Preorder Governance

Reservation and preorder may reserve or commit quantity.

Core rule:

Reservation/preorder commitment must respect limited quantity hold or allocation.

31\. Relationship To POS/KDS Availability Sync

POS/KDS/inventory may provide quantity reference later.

Core rule:

External quantity source must include capability, timestamp, and reliability before commitment.

32\. MVP Requirements

MVP should support at least:

manual limited quantity state
manual remaining quantity note
limited low warning
limited exhausted state
manual hold marker
manual release marker
preorder block when exhausted
pickup block when exhausted
quantity conflict flag
quantity audit event
failure event
support signal

MVP may defer:

real-time POS stock deduction
exact inventory sync
automatic hold expiration engine
advanced quantity reservation engine
KDS quantity integration
inventory-based prediction

33\. Suggested Conceptual Entities

Suggested entities:

limited\_quantity\_records
limited\_quantity\_holds
limited\_quantity\_events
quantity\_conflicts
quantity\_audit\_events
quantity\_failure\_events
quantity\_support\_signals

This document defines policy.

Actual schema may be designed later.

34\. Risk If Skipped

If Limited Quantity Menu and Waiting Preorder Control policy is skipped, risks include:

limited menu is over-promised
waiting preorder disappoints guests
pickup item is unavailable at pickup time
group order exceeds capacity
POS receives impossible item
KDS receives impossible prep ticket
staff must manually apologize
refund/support burden increases
merchant loses trust in preorder

Therefore, limited quantity control must exist before waiting preorder or pickup preorder scales.

35\. Final Rule

Limited quantity requires commitment control.

Final rule:

Show limited items carefully.
Do not promise limited quantity without control.
Use hold when needed.
Expire holds.
Release quantity with reason.
Block exhausted items.
Treat unknown quantity as risky.
Require manual confirmation when uncertain.
Block POS handoff when quantity is unsafe.
Block KDS handoff when quantity is unsafe.
Audit every quantity change.
Protect guest expectation and kitchen reality.
