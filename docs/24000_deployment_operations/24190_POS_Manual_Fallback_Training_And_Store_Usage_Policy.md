03950 POS Manual Fallback Training And Store Usage Policy

Legacy path: $old.

1\. Purpose

This document defines POS Manual Fallback Training and Store Usage policy for CatchMenu / Wait Order Handoff.

CatchMenu can start before full external POS integration is available.

In early trial, small stores, unsupported POS environments, provider outage, mapping conflict, or uncertain handoff result, store staff may need to manually enter CatchMenu request information into the existing POS.

This must not be treated as an accidental workaround.

Manual POS fallback is an official interim operation mode.

However, manual fallback must be trained, visible, recorded, reviewed for burden, and upgraded into POS integration readiness when it becomes repetitive or painful.

Core purpose:

Define manual POS fallback as official interim operation.
Define staff training for manual POS entry.
Define request-board-to-POS workflow.
Define duplicate order prevention.
Define critical warning handling.
Define fallback record.
Define burden review.
Define POS integration readiness signal.
Prevent hidden duplicate labor.
Prevent missed orders.
Prevent unsafe retry or duplicate POS order.

Korean purpose:

수동 POS fallback을 공식 중간 운영으로 정의한다.
직원 수동 POS 입력 교육을 정의한다.
요청판에서 POS로 옮기는 흐름을 정의한다.
중복 주문 방지를 정의한다.
중요 안내/critical warning 처리를 정의한다.
fallback 기록을 정의한다.
업무 부담 리뷰를 정의한다.
POS 연동 필요 신호를 정의한다.
숨은 중복 노동을 방지한다.
주문 누락을 방지한다.
unsafe retry 또는 중복 POS 주문을 방지한다.

2\. Scope

This document covers:

manual POS fallback
manual POS entry training
request board reading
item and option transfer
quantity transfer
note transfer
critical warning transfer
manual handled status
duplicate prevention
manual fallback record
fallback burden review
staff training
store usage check
POS integration readiness signal
support signal
audit event

This document does not define:

external POS adapter implementation
automatic POS order injection
provider callback processing
KDS ticket execution
payment provider execution
staff payroll training
legal labor training
full POS replacement product

Related documents:

03900\_Merchant\_Success\_Troubleshooting\_Readme.md
03910\_First\_7\_Days\_Activation\_Check\_Policy.md
03920\_First\_30\_Days\_Troubleshooting\_And\_Conversion\_Readiness\_Policy.md
03940\_Request\_Board\_Staff\_Adoption\_And\_Operation\_Check\_Policy.md
03500\_External\_POS\_Integration\_Runtime\_Readme.md
03530\_POS\_Menu\_Table\_Order\_Mapping\_And\_Idempotency\_Policy.md
03540\_POS\_Callback\_Replay\_Manual\_Fallback\_And\_Evidence\_Policy.md

3\. Core Principle

Manual POS fallback is allowed only when explicit, trained, and recorded.

Core rule:

Manual POS fallback is official interim operation.
Hidden duplicate labor is not acceptable.

Korean rule:

수동 POS fallback은 공식 중간 운영이다.
숨은 중복 노동은 허용하지 않는다.

4\. Manual POS Fallback Boundary

Manual POS fallback means store staff manually enters or handles CatchMenu request in the existing POS.

Manual fallback may happen when:

no POS integration exists
merchant is in trial stage
POS provider is unsupported
POS binding is not configured
menu mapping is incomplete
option mapping is incomplete
table mapping is incomplete
provider is degraded
handoff result is unknown
merchant prefers manual operation

Manual fallback does not mean:

POS integration is complete
payment is completed
KDS ticket is created
order finality is guaranteed
billing state is changed

Core rule:

Manual fallback transfers visible request into store operation.
It does not create automatic POS authority.

5\. Manual Fallback Operation Flow

Suggested flow:

guest sends request
request appears on request board
staff opens request detail
staff reads item, option, quantity, note, critical warning
staff enters order into POS manually
staff confirms or marks handled in CatchMenu
staff resolves guest/store communication if needed
manual fallback record is created

Core rule:

Manual fallback flow must be simple enough for peak-time use.

6\. Staff Training Scope

Staff training should cover:

where to open request board
how to read request summary
how to read item names
how to read quantity
how to read options
how to read required options
how to read guest note
how to identify critical warning
how to manually enter into POS
how to avoid duplicate entry
how to mark handled
how to call support

Core rule:

Manual fallback training starts from request board reading.

7\. Request Summary Requirements

Request summary must support manual POS entry.

It should show:

request id
request time
item name
quantity
option group
selected option
price if needed
guest note
critical warning
language context if needed
manual POS instruction
current status

Core rule:

Staff cannot enter accurately if request summary is unclear.

8\. Item Transfer

Item transfer means staff identifies the CatchMenu item and enters corresponding POS item.

If item names differ between CatchMenu and POS:

show POS mapping name if available
show merchant note
require manual judgment if unmapped
record mapping issue if repeated

Core rule:

Item name mismatch should become mapping improvement signal.

9\. Option Transfer

Options are high-risk in manual fallback.

Staff must check:

required option
selected option
add-on
removed ingredient
spice level
temperature
size
set selection
price delta if needed

Core rule:

Required option must not be skipped during manual POS entry.

10\. Quantity Transfer

Quantity must be clearly visible.

Quantity risks:

default quantity misunderstood
multiple items collapsed
set count confused
option count confused
duplicate manual entry

Core rule:

Quantity must be read before POS entry is marked handled.

11\. Note Transfer

Guest notes may affect operation.

Examples:

less spicy
no cucumber
sauce separately
takeout note
foreign language note
seat/table note

If POS does not support note field:

staff must communicate manually
request board should remain visible
manual fallback note should record handling

Core rule:

Guest note must not disappear silently.

12\. Critical Warning Transfer

Critical warnings require special attention.

Examples:

allergy candidate
no pork
no meat
religious/dietary restriction
spicy intolerance
pregnancy-sensitive item
severe ingredient concern

Critical warning handling:

display prominently
staff reads before POS entry
include in POS note if possible
communicate to kitchen if needed
mark handled only after awareness

Core rule:

Critical warning must be seen before manual fallback is completed.

13\. Duplicate Entry Prevention

Manual POS fallback can create duplicate entry risk.

Duplicate risk occurs when:

two staff members enter same request
staff enters manually after automatic handoff succeeds
system retries after manual entry
guest resends same request
request board remains unhandled
callback arrives late from POS

Controls:

mark request as being handled
assign handler if possible
show manual fallback status
block automatic retry after manual handled unless reviewed
show duplicate warning
use request id/reference

Core rule:

Manual fallback and automatic retry must not operate blindly at the same time.

14\. Manual Handled Status

Manual handled status should be explicit.

Suggested statuses:

MANUAL\_FALLBACK\_REQUIRED
MANUAL\_ENTRY\_IN\_PROGRESS
MANUAL\_ENTRY\_DONE
MANUAL\_ENTRY\_FAILED
MANUAL\_REVIEW\_REQUIRED
RECONCILIATION\_REQUIRED

Core rule:

Manual entry done must be distinct from POS automatic acceptance.

15\. Manual Fallback Record

Manual fallback record should include:

manual\_fallback\_id
request\_id
merchant\_store\_id
actor\_type
actor\_id
fallback\_reason
items\_summary
critical\_warning\_present
manual\_pos\_reference optional
handled\_at
status
note

Core rule:

Manual fallback without record cannot be reviewed or improved.

16\. Manual POS Reference

If possible, staff may record a POS reference.

Examples:

POS order number
receipt number
table number
manual note
kitchen note reference

Manual POS reference may be optional in MVP.

Core rule:

Manual POS reference improves traceability but should not slow peak operation excessively.

17\. Store Usage Check

Merchant Success should check whether staff can actually use manual fallback.

Check items:

staff knows where request board is
staff can read request summary
staff can enter item into POS
staff can enter option into POS
staff can handle notes
staff can see critical warning
staff can mark handled
staff can avoid duplicate entry
staff knows support path

Core rule:

Manual fallback must be verified in store, not only explained.

18\. First 7 Days Relation

During first 7 days, manual fallback readiness should be checked.

Minimum check:

test request created
staff reads request
staff explains how to enter POS manually
staff marks handled
support path confirmed

Core rule:

Activation is incomplete if manual fallback is required but not understood.

19\. First 30 Days Burden Review

During first 30 days, manual fallback burden should be reviewed.

Review questions:

How many manual entries occurred?
Did staff find it easy?
Were options confusing?
Were notes lost?
Were duplicate entries avoided?
Did manual entry slow peak operation?
Did merchant ask for POS integration?

Core rule:

Manual fallback burden is evidence for POS integration priority.

20\. Burden Level

Suggested burden levels:

LOW
MEDIUM
HIGH
CRITICAL

Meaning:

LOW
\= staff handles easily

MEDIUM
\= manageable but creates some friction

HIGH
\= staff burden is significant and POS integration should be reviewed

CRITICAL
\= manual fallback blocks service value

Core rule:

High or critical burden should trigger POS integration readiness review.

21\. POS Integration Readiness Signal

Manual fallback may trigger POS integration readiness.

Signals:

manual fallback count high
manual entry time high
staff complains
duplicate risk occurs
merchant asks for automation
medium or large store
request volume increasing
preorder flow increasing
KDS path becoming relevant

Core rule:

Repeated manual fallback is not failure if it becomes integration evidence.

22\. Staff Resistance

Staff may resist manual fallback if it feels like extra work.

Resistance signals:

staff ignores request board
staff says this is double work
requests remain unconfirmed
manual handled status not used
owner reports staff dislike
peak-time use stops

Responses:

simplify request summary
move request board device
train again
reduce request scope
pause send-to-store mode if needed
review POS integration

Core rule:

Staff resistance should be treated as operation data, not attitude problem only.

23\. Manual Fallback And Guest Expectation

Guest-facing UI should not imply full automatic ordering when operation is manual.

Guest instructions should be clear.

Examples:

request sent to store
please wait for staff confirmation
show this screen to staff
store will confirm availability

Avoid misleading wording:

order completed
payment completed
kitchen already preparing

Core rule:

Guest wording must match manual fallback reality.

24\. Manual Fallback And Support

Support should be able to diagnose fallback issues.

Support should see:

request id
fallback status
handler if available
fallback reason
manual POS reference if available
critical warning presence
duplicate risk flag
support notes

Core rule:

Support cannot help if manual fallback is invisible.

25\. Manual Fallback And KDS

Before KDS integration, manual fallback may include kitchen communication.

Kitchen communication may be:

POS printout
verbal kitchen note
manual kitchen note
existing kitchen workflow

Core rule:

Manual POS fallback does not equal KDS ticket.

26\. Manual Fallback And Billing

Manual fallback may affect perceived value of paid POS integration add-on.

Billing should not charge POS integration add-on if only manual fallback exists, unless plan clearly defines it as non-integrated service.

Core rule:

Manual fallback is service operation, not proof of paid POS integration.

27\. Support Signals

Support signals may include:

MANUAL\_POS\_FALLBACK\_TRAINING\_REQUIRED
MANUAL\_POS\_FALLBACK\_NOT\_UNDERSTOOD
MANUAL\_ENTRY\_IN\_PROGRESS\_TOO\_LONG
MANUAL\_ENTRY\_DONE\_NOT\_MARKED
MANUAL\_POS\_DUPLICATE\_RISK
MANUAL\_POS\_CRITICAL\_WARNING\_REVIEW\_REQUIRED
MANUAL\_POS\_BURDEN\_HIGH
POS\_INTEGRATION\_READINESS\_FROM\_MANUAL\_BURDEN
STAFF\_RESISTANCE\_TO\_MANUAL\_FALLBACK

Support Signal alerts.

It does not mark manual handled by itself.

28\. Audit Events

Recommended audit events:

MANUAL\_POS\_FALLBACK\_TRAINING\_STARTED
MANUAL\_POS\_FALLBACK\_TRAINING\_COMPLETED
MANUAL\_POS\_FALLBACK\_REQUIRED
MANUAL\_POS\_ENTRY\_STARTED
MANUAL\_POS\_ENTRY\_DONE
MANUAL\_POS\_ENTRY\_FAILED
MANUAL\_POS\_REFERENCE\_RECORDED
MANUAL\_POS\_DUPLICATE\_RISK\_MARKED
MANUAL\_POS\_BURDEN\_REVIEWED
POS\_INTEGRATION\_READINESS\_MARKED\_FROM\_MANUAL\_BURDEN

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
request\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

29\. Failure Events

Example failure codes:

WOH.POS\_MANUAL\_FALLBACK.TRAINING\_REQUIRED
WOH.POS\_MANUAL\_FALLBACK.REQUEST\_SUMMARY\_INSUFFICIENT
WOH.POS\_MANUAL\_FALLBACK.REQUIRED\_OPTION\_MISSING
WOH.POS\_MANUAL\_FALLBACK.CRITICAL\_WARNING\_NOT\_ACKNOWLEDGED
WOH.POS\_MANUAL\_FALLBACK.DUPLICATE\_RISK
WOH.POS\_MANUAL\_FALLBACK.HANDLED\_STATUS\_REQUIRED
WOH.POS\_MANUAL\_FALLBACK.BURDEN\_HIGH
WOH.POS\_MANUAL\_FALLBACK.POS\_INTEGRATION\_REVIEW\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

30\. Relationship To Request Board Adoption

Manual fallback depends on request board adoption.

Core rule:

Staff cannot perform manual POS fallback if staff does not trust or watch the request board.

31\. Relationship To POS Mapping And Idempotency

Manual fallback must interact with idempotency and duplicate prevention.

Core rule:

Manual fallback status must be visible to automatic POS handoff and replay guards.

32\. Relationship To POS Callback And Replay

Late callback after manual fallback may create conflict.

Core rule:

Late POS callback after manual handling requires reconciliation review.

33\. Relationship To Merchant Success

Merchant Success uses manual fallback burden to judge conversion readiness and POS integration need.

Core rule:

Manual fallback burden is a Merchant Success health signal.

34\. MVP Requirements

MVP should support at least:

manual fallback required flag
manual entry in progress status
manual entry done status
manual fallback reason
manual POS reference optional field
critical warning visible flag
duplicate risk flag
manual fallback training completed flag
burden level
POS integration readiness signal
support signal
audit event
failure event

MVP may defer:

automatic stopwatch for manual entry duration
advanced staff assignment
POS reference validation
duplicate detection model
kitchen note workflow
advanced training module

35\. Suggested Conceptual Entities

Suggested entities:

manual\_pos\_fallback\_records
manual\_pos\_training\_events
manual\_pos\_burden\_reviews
manual\_pos\_duplicate\_risk\_events
manual\_pos\_support\_signals
manual\_pos\_audit\_events
manual\_pos\_failure\_events

This document defines policy.

Actual schema may be designed later.

36\. Risk If Skipped

If POS Manual Fallback Training and Store Usage policy is skipped, risks include:

staff sees CatchMenu as extra work
requests are not entered into POS
options or notes are lost
critical warnings are missed
duplicate POS orders occur
manual fallback burden remains hidden
merchant loses trust before POS integration
conversion fails despite useful guest flow
support cannot diagnose store operation issue

Therefore, manual POS fallback must be official, trained, recorded, and reviewed.

37\. Final Rule

Manual POS fallback is the bridge between lightweight trial and POS-connected operation.

Final rule:

Treat manual POS fallback as official interim operation.
Train staff.
Show clear request summary.
Transfer item, option, quantity, note, and critical warning.
Prevent duplicate entry.
Record fallback status.
Mark handled explicitly.
Review burden during first 30 days.
Use repeated burden as POS integration readiness signal.
Do not call manual fallback POS integration.
Do not hide duplicate labor.
