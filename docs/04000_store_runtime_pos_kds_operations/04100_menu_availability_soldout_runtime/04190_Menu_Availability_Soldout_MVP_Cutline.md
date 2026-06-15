# 04190_Menu_Availability_Soldout_MVP_Cutline

1\. Purpose

This document defines the MVP cutline for Menu Availability, Sold-out, Limited Quantity, Preorder Blocking, and Availability Sync in CatchMenu / Wait Order Handoff.

Menu availability is essential for preorder, pickup, POS handoff, and KDS handoff.

However, the MVP must not attempt full inventory management, full POS stock sync, full KDS station sync, or ingredient-level automation from the beginning.

The MVP should support simple, safe, manual, auditable availability control first.

Core purpose:

Define what must be included in MVP.
Define what must be deferred.
Define safe manual availability operation.
Define sold-out blocking.
Define preorder/pickup blocking.
Define manual confirmation required.
Define limited quantity placeholder.
Define availability audit and support signal.
Prevent overbuilding full inventory too early.

Korean purpose:

MVP에 반드시 포함할 항목을 정의한다.
MVP에서 뒤로 미룰 항목을 정의한다.
안전한 수동 availability operation을 정의한다.
품절 차단을 정의한다.
선주문/픽업 차단을 정의한다.
manual confirmation required를 정의한다.
한정 수량 placeholder를 정의한다.
availability audit과 support signal을 정의한다.
초기부터 full inventory를 과하게 구현하는 것을 방지한다.

2\. MVP Core Principle

MVP must control false commitment before it automates inventory.

Core rule:

MVP availability must prevent unsafe promises.
It does not need to become full inventory system.

Korean rule:

MVP availability는 잘못된 약속을 막아야 한다.
초기부터 full inventory system이 될 필요는 없다.

3\. MVP Must Include

MVP must include:

manual availability state
manual sold-out
manual restore available
temporary unavailable
preorder blocked
pickup blocked
reservation blocked
request-only mode
manual confirmation required
guest-facing availability label
store-facing availability control
availability audit event
availability failure event
availability support signal
availability snapshot placeholder
limited quantity placeholder
availability conflict flag

Core rule:

MVP must let store block unavailable items quickly.

4\. MVP Must Not Include Yet

MVP should not include yet:

full inventory ledger
ingredient-level stock deduction
warehouse management
supplier ordering
recipe BOM automation
real-time POS stock deduction
real-time KDS station sync
automatic limited quantity reservation engine
advanced quantity hold engine
automatic food safety blocking
inventory valuation
supplier shortage prediction

Core rule:

Do not build full inventory before availability safety exists.

5\. Required Availability States

MVP should support at least:

AVAILABLE
SOLD\_OUT
TEMPORARILY\_UNAVAILABLE
PREORDER\_BLOCKED
PICKUP\_BLOCKED
RESERVATION\_BLOCKED
REQUEST\_ONLY
MANUAL\_CONFIRMATION\_REQUIRED
HIDDEN
REVIEW\_REQUIRED
UNKNOWN

MVP may defer:

complex scheduled availability
multi-source priority engine
ingredient-derived availability
real-time limited quantity count

Core rule:

MVP states must be simple enough for store staff.

6\. Required Flow Blocking

MVP must allow availability to block:

guest preorder
waiting preorder
prepaid pickup
reservation/group order request
automatic POS handoff if enabled later
automatic KDS handoff if enabled later

Core rule:

Availability block must happen before operational commitment.

7\. Store-Facing MVP Controls

Store-facing MVP controls should include:

mark sold out
restore available
mark temporary unavailable
block preorder
block pickup
block reservation
set request-only
set manual confirmation required
hide item
add availability note

Core rule:

Store-facing control must be faster than calling support.

8\. Guest-Facing MVP Labels

MVP guest labels should include:

Available
Sold out
Temporarily unavailable
Preorder not available
Pickup not available
Store confirmation required
Ask staff

Korean labels:

주문 가능
품절
일시 품절
선주문 불가
픽업 불가
매장 확인 필요
직원 확인 필요

Core rule:

Guest-facing labels must not overpromise.

9\. Manual Sold-Out MVP

Manual sold-out must be available from the beginning.

Manual sold-out should:

block preorder by default
block pickup by default
block POS handoff if enabled
block KDS handoff if enabled
show sold-out label or hide item
record actor
record reason
record timestamp

Core rule:

Manual sold-out is the MVP safety brake.

10\. Temporary Unavailable MVP

Temporary unavailable should include:

reason
effective time
optional expiry/review time
affected flow
actor
note

MVP may allow simple manual review instead of automatic expiry engine.

Core rule:

Temporary unavailable must not become unexplained permanent block.

11\. Manual Confirmation Required MVP

Manual confirmation required should be used when availability is uncertain.

MVP behavior:

allow guest to request if configured
block firm preorder commitment
show store confirmation required
route to request board
require staff confirmation before commitment

Core rule:

When uncertain, confirm manually before promise.

12\. Request-Only MVP

Request-only mode should support soft intent without commitment.

MVP behavior:

guest may express interest
store must confirm
no automatic POS handoff
no automatic KDS handoff
no guarantee wording

Core rule:

Request-only protects uncertain items.

13\. Limited Quantity MVP

MVP should not require exact real-time limited quantity engine.

MVP should support:

limited quantity label
manual low quantity note
manual exhausted marker
manual quantity note
manual confirmation required
preorder block when exhausted
support signal for quantity risk

MVP may defer:

automatic hold
automatic release
real-time count deduction
POS stock count sync
KDS quantity sync

Core rule:

In MVP, limited quantity should be conservative and manually controlled.

14\. Availability Snapshot MVP

MVP should create a simple availability snapshot for committed flows.

Snapshot may include:

menu\_item\_id
availability\_state
flow\_type
source
actor optional
timestamp
decision
block\_reason optional

Core rule:

Commitment should know what availability state existed at that time.

15\. Availability Conflict MVP

MVP should support a simple conflict flag.

Conflict may be marked when:

store report conflicts with menu state
support report conflicts with store state
POS/KDS reference later conflicts with manual state
guest issue indicates wrong availability

MVP behavior:

mark REVIEW\_REQUIRED
block high-commitment flow
emit support signal
record audit event

Core rule:

Conflict should block risky commitment until reviewed.

16\. POS/KDS Sync MVP Boundary

MVP does not require real-time POS/KDS availability sync.

MVP should prepare placeholders:

availability source type
source timestamp
source reliability
source stale flag
external source reference optional

Core rule:

Prepare for POS/KDS sync without depending on it in MVP.

17\. Owner Console MVP

Owner Console should allow store/merchant users to manage availability.

MVP Owner Console should show:

current availability state
quick sold-out action
quick restore action
preorder/pickup block
manual confirmation toggle
availability note
last changed time
actor if allowed

Core rule:

Availability control must live where merchant already works.

18\. Request Board MVP

Request Board should reflect availability when relevant.

MVP Request Board may show:

item availability warning
manual confirmation required
sold-out after request
request-only state
support signal if availability conflict

Core rule:

Staff must see availability risk before confirming request.

19\. POS Handoff MVP Boundary

If POS handoff is enabled later, MVP availability must block unsafe handoff.

Minimum rule:

SOLD\_OUT
TEMPORARILY\_UNAVAILABLE
MANUAL\_CONFIRMATION\_REQUIRED without confirmation
REVIEW\_REQUIRED
UNKNOWN for committed flow
→ block automatic POS handoff

Core rule:

POS handoff must respect availability even in MVP.

20\. KDS Handoff MVP Boundary

If KDS path is enabled later, MVP availability must block unsafe kitchen handoff.

Minimum rule:

SOLD\_OUT
TEMPORARILY\_UNAVAILABLE
MANUAL\_CONFIRMATION\_REQUIRED without confirmation
REVIEW\_REQUIRED
UNKNOWN for committed flow
→ block automatic KDS handoff

Core rule:

KDS handoff must not receive unavailable items.

21\. Audit MVP

MVP must audit availability changes.

Minimum audit events:

MENU\_AVAILABILITY\_CHANGED
MENU\_SOLD\_OUT\_MARKED
MENU\_AVAILABLE\_RESTORED
MENU\_TEMP\_UNAVAILABLE\_MARKED
MENU\_PREORDER\_BLOCKED
MENU\_PICKUP\_BLOCKED
MENU\_MANUAL\_CONFIRMATION\_REQUIRED
MENU\_REQUEST\_ONLY\_MARKED
MENU\_AVAILABILITY\_REVIEW\_REQUIRED

Core rule:

Availability changes affect guest expectation and must be auditable.

22\. Failure Events MVP

MVP should support failure events:

WOH.AVAILABILITY.SOLD\_OUT\_BLOCKED
WOH.AVAILABILITY.PREORDER\_BLOCKED
WOH.AVAILABILITY.PICKUP\_BLOCKED
WOH.AVAILABILITY.UNKNOWN\_REQUIRES\_CONFIRMATION
WOH.AVAILABILITY.REVIEW\_REQUIRED
WOH.AVAILABILITY.POS\_HANDOFF\_BLOCKED
WOH.AVAILABILITY.KDS\_HANDOFF\_BLOCKED

Core rule:

Blocking must have explainable reason.

23\. Support Signal MVP

MVP should support support signals:

MENU\_AVAILABILITY\_REVIEW\_REQUIRED
SOLD\_OUT\_ITEM\_SELECTED
PREORDER\_BLOCKED\_BY\_AVAILABILITY
PICKUP\_BLOCKED\_BY\_AVAILABILITY
MANUAL\_CONFIRMATION\_PENDING
LIMITED\_QUANTITY\_RISK
AVAILABILITY\_CONFLICT\_REVIEW\_REQUIRED

Core rule:

Support should know when availability blocks conversion or operation.

24\. Merchant Success MVP

Merchant Success should check availability setup during first 7 and 30 days.

Check items:

can store mark sold-out
can store restore available
can store block preorder
can store set manual confirmation required
does staff understand sold-out label
does availability block prevent bad request
were availability complaints reported

Core rule:

Availability control is part of trial stabilization.

25\. MVP Implementation Order

Suggested implementation order:

1\. add availability state to menu item/context
2\. add store-facing sold-out/restore control
3\. add guest-facing labels
4\. add preorder/pickup block guard
5\. add manual confirmation required
6\. add request-only mode
7\. add audit events
8\. add support signals
9\. add availability snapshot placeholder
10\. add POS/KDS block guard placeholders

Core rule:

Build safety guard before advanced sync.

26\. Explicitly Deferred

Deferred features:

automatic POS sold-out sync
automatic KDS station sync
inventory ingredient sync
exact remaining count engine
automatic quantity hold/release
automatic substitution recommendation
recipe-derived availability
supplier shortage integration
predictive sold-out
advanced availability analytics

Core rule:

Deferred does not mean forgotten.
It means not required for first safe runtime.

27\. MVP Readiness Checklist

MVP is ready when:

\[ \] Store can mark item sold out
\[ \] Store can restore item
\[ \] Store can block preorder
\[ \] Store can block pickup
\[ \] Store can require manual confirmation
\[ \] Guest sees clear label
\[ \] Preorder is blocked for unavailable item
\[ \] Pickup is blocked for unavailable item
\[ \] Request board shows availability warning
\[ \] Audit event is recorded
\[ \] Support signal is created when needed
\[ \] POS/KDS guard placeholder exists

Core rule:

MVP readiness is operational safety, not feature abundance.

28\. Risk If MVP Cutline Is Ignored

If MVP is too small:

sold-out items may be preordered
pickup promise fails
POS/KDS receives impossible item
merchant loses trust

If MVP is too large:

inventory system delays launch
POS/KDS dependency blocks early trial
staff UI becomes complex
implementation scope explodes

Core rule:

MVP must be safe but not overbuilt.

29\. Final Rule

Menu Availability MVP should be manual-first, safe, and auditable.

Final rule:

Start with manual availability control.
Support sold-out.
Support restore.
Support temporary unavailable.
Block preorder.
Block pickup.
Require manual confirmation when uncertain.
Use request-only mode for soft intent.
Show clear guest labels.
Audit changes.
Create support signals.
Prepare POS/KDS guard placeholders.
Defer full inventory and real-time sync.
Do not overpromise unavailable menu.
