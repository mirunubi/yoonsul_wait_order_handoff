03940 Request Board Staff Adoption And Operation Check Policy

Legacy path: $old.

1\. Purpose

This document defines Request Board Staff Adoption and Operation Check policy for CatchMenu / Wait Order Handoff.

CatchMenu may successfully scan, display menu, receive guest requests, and create structured request data.

However, if store staff does not watch the request board or does not understand how to handle requests, the service fails operationally.

Request board adoption is not a technical installation task.

It is a store behavior formation task.

Core purpose:

Define request board staff adoption policy.
Define staff owner responsibility.
Define request board operation check.
Define request status handling.
Define unconfirmed request monitoring.
Define request board training.
Define request board placement and device use.
Define staff workload review.
Define support signal and audit.
Prevent guest requests from becoming invisible.

Korean purpose:

요청판 직원 사용 정착 정책을 정의한다.
요청판 담당자 책임을 정의한다.
요청판 운영 점검을 정의한다.
요청 상태 처리 방식을 정의한다.
미확인 요청 모니터링을 정의한다.
요청판 교육을 정의한다.
요청판 위치와 기기 사용을 정의한다.
직원 업무 부담 리뷰를 정의한다.
support signal과 audit을 정의한다.
손님 요청이 보이지 않는 요청으로 방치되는 것을 방지한다.

2\. Scope

This document covers:

request board adoption
staff owner
request board device
request board placement
request status handling
request confirmation
request completion
unconfirmed request warning
staff training
shift handoff
manual POS fallback relation
support signal
audit event
operation check

This document does not define:

POS adapter implementation
KDS execution
AI menu extraction
billing plan change
sales commission
full HR training system
employee payroll
legal labor policy

Related documents:

03900\_Merchant\_Success\_Troubleshooting\_Readme.md
03910\_First\_7\_Days\_Activation\_Check\_Policy.md
03920\_First\_30\_Days\_Troubleshooting\_And\_Conversion\_Readiness\_Policy.md
03930\_AI\_Menu\_Intake\_Correction\_And\_Live\_Menu\_Stabilization\_Policy.md
03950\_POS\_Manual\_Fallback\_Training\_And\_Store\_Usage\_Policy.md
01130\_Stage\_0C\_POS\_Less\_Request\_Confirmation\_Board.md
01160\_Stage\_0\_Request\_State\_Transition\_Guard.md
01170\_Stage\_0\_Unconfirmed\_Request\_Warning\_And\_Forced\_Cleanup.md

3\. Core Principle

A request board is valuable only when staff watches and acts on it.

Core rule:

A request board that staff does not check is not an operating system.
It is an ignored screen.

Korean rule:

직원이 확인하지 않는 요청판은 운영 시스템이 아니다.
그냥 방치된 화면이다.

4\. Request Board Boundary

Request Board owns:

request visibility
request list
request detail
request status display
confirmation action if enabled
handled/done action if enabled
unconfirmed request warning
staff operation visibility

Request Board does not own:

POS order finality
payment finality
KDS ticket execution
billing status
menu truth
staff employment authority

Core rule:

Request board makes guest intent visible to staff.
It does not replace POS/KDS authority.

5\. Staff Owner

Each store should identify at least one staff owner for request board operation.

Staff owner may be:

store owner
store manager
shift leader
counter staff
tablet operator
designated hall staff

Staff owner responsibility:

know where request board is
check request board during service
understand status meanings
handle or route request
mark status if enabled
report issue
train next shift if needed

Core rule:

No staff owner means no operational accountability.

6\. Request Board Device

Request board may be used on:

store tablet
counter PC
admin mobile
owner console device
shared staff device

Device requirement:

screen visible
login available
network stable
sound/vibration if enabled
charging/power available
safe placement
staff access controlled

Core rule:

Request board must be physically and operationally accessible during service.

7\. Request Board Placement

Placement should follow store workflow.

Good locations:

counter
order-taking area
kitchen pass area
manager tablet
near POS station

Bad locations:

back office only
owner's phone only
screen hidden from staff
device locked away
device without charger

Core rule:

Request board must be where staff actually works.

8\. Request Status Meaning

Request status must be simple.

Suggested statuses:

REQUEST\_SENT
STORE\_VIEWED
STORE\_CONFIRMED
STORE\_HANDLED\_MANUALLY
DONE
CANCELLED
UNCONFIRMED\_WARNING
REVIEW\_REQUIRED

Staff-facing meaning:

REQUEST\_SENT
\= guest request arrived

STORE\_VIEWED
\= staff opened it

STORE\_CONFIRMED
\= store acknowledged it

STORE\_HANDLED\_MANUALLY
\= staff handled outside automatic POS path

DONE
\= operationally completed

UNCONFIRMED\_WARNING
\= request is aging without response

Core rule:

Status names must help staff act quickly.

9\. Confirmation Rule

Store confirmation means staff has acknowledged the request.

It does not necessarily mean:

POS order accepted
payment completed
food preparation started
KDS ticket created
legal order finality

Core rule:

Store confirmation is operational acknowledgment, not POS/payment finality.

10\. Done Rule

Done means the store handled the request according to the current operating mode.

Done may mean:

shown to staff and handled
manually entered into POS
served or prepared
routed to kitchen manually
cancelled by store with explanation

Core rule:

Done must match store workflow and should not imply unsupported automation.

11\. Request Aging

Unconfirmed requests should be monitored.

Possible aging thresholds:

5 minutes
\= attention warning candidate

15 minutes
\= operational review candidate

30 minutes
\= unconfirmed warning

10 or more unconfirmed requests
\= forced cleanup or operation review candidate

Thresholds may differ by store type.

Core rule:

Old unconfirmed requests are adoption failure signals.

12\. Unconfirmed Request Handling

When unconfirmed request is detected:

show warning to authorized staff
emit support signal if repeated
review staff owner
review device placement
review request board visibility
review guest expectation
review whether request flow should be paused

Core rule:

Unconfirmed request is not only a guest issue.
It is an operation issue.

13\. Staff Training

Staff training should cover:

what CatchMenu is
where request board is
what request means
how to read item/option/quantity
how to identify critical warning
how to confirm request
how to handle manually
how to mark done
how to avoid duplicate POS entry
how to call support

Core rule:

Request board training must be practical and short.

14\. Shift Handoff

Request board responsibility may change by shift.

Shift handoff should include:

device location
login/access status
pending requests
unconfirmed warnings
manual POS fallback rule
support issue

Core rule:

Request board ownership must survive shift changes.

15\. Staff Workload Check

Request board should reduce or clarify work, not add hidden burden.

Workload review should ask:

Does staff check another screen too often?
Does request board reduce menu explanation?
Does request summary help manual POS entry?
Are notifications useful or noisy?
Are staff missing requests during peak?
Is the board easier on tablet, PC, or mobile?

Core rule:

Adoption fails when request board feels like extra work.

16\. Request Summary Quality

Request board must show clear summaries.

Summary should include:

item name
quantity
options
price if needed
guest note
critical warning
language context if needed
request time
status
manual POS instruction if applicable

Core rule:

Staff adoption improves when request summary is clear.

17\. Critical Warning Visibility

Critical warnings must be highly visible.

Examples:

allergy candidate
spicy intolerance
no pork
no meat
religious/dietary restriction
special note

Core rule:

Critical warning must not be hidden in small notes.

18\. Manual POS Fallback Relation

Request board is often the bridge to manual POS fallback.

Staff should know:

which request needs manual POS entry
what to enter
what not to duplicate
when to mark handled
what to do if POS entry fails

Core rule:

Request board and manual POS fallback must be trained together.

19\. POS Integration Relation

If POS integration is active, request board may still be needed.

Request board may show:

handoff candidate
handoff sent
POS accepted
POS rejected
manual fallback required
callback delayed
unknown result

Core rule:

POS integration reduces manual entry but does not remove operational visibility need.

20\. KDS Relation

If KDS path is added later, request board may show kitchen-related status.

Possible statuses:

KDS ticket created
prep started
prep delayed
ready
remake/retry

Core rule:

Request board should not fake KDS status before KDS path is real.

21\. Owner Console Relation

Owner Console should allow owner/manager to see request board health.

Health indicators:

request count
unconfirmed count
average confirmation time
manual fallback count
staff adoption risk
device/access issue
support signal

Core rule:

Owner should see whether the board is being used, not only whether it exists.

22\. Adoption Status

Suggested adoption statuses:

NOT\_TRAINED
TRAINING\_REQUIRED
TRAINED
WATCHING
PARTIALLY\_ADOPTED
ADOPTED
ADOPTION\_RISK
NOT\_USED

Core rule:

Request board adoption status must be separate from technical availability.

23\. Adoption Risk Factors

Risk factors:

no staff owner
device hidden
staff not trained
unconfirmed requests accumulating
manual POS fallback confusing
notifications ignored
owner not checking
peak-time missed requests
support issue unresolved

Core rule:

Adoption risk should trigger Merchant Success follow-up.

24\. Operation Check Checklist

Minimum checklist:

\[ \] Staff owner identified
\[ \] Request board device selected
\[ \] Request board location confirmed
\[ \] Staff can open request board
\[ \] Test request appears
\[ \] Staff understands item/option/quantity
\[ \] Staff understands critical warning
\[ \] Staff understands confirm/done
\[ \] Staff understands manual POS fallback
\[ \] Staff knows support path
\[ \] Unconfirmed warning explained
\[ \] Adoption status recorded

Core rule:

Request board operation check must be completed before request volume grows.

25\. Support Signals

Support signals may include:

REQUEST\_BOARD\_STAFF\_OWNER\_MISSING
REQUEST\_BOARD\_DEVICE\_NOT\_READY
REQUEST\_BOARD\_NOT\_VISIBLE\_TO\_STAFF
REQUEST\_BOARD\_TRAINING\_REQUIRED
REQUEST\_BOARD\_NOT\_USED
UNCONFIRMED\_REQUESTS\_ACCUMULATING
REQUEST\_BOARD\_PEAK\_TIME\_MISSED
REQUEST\_BOARD\_MANUAL\_POS\_CONFUSION
REQUEST\_BOARD\_ADOPTION\_RISK

Support Signal alerts.

It does not mutate request status by itself.

26\. Audit Events

Recommended audit events:

REQUEST\_BOARD\_STAFF\_OWNER\_ASSIGNED
REQUEST\_BOARD\_DEVICE\_CONFIRMED
REQUEST\_BOARD\_LOCATION\_CONFIRMED
REQUEST\_BOARD\_TRAINING\_STARTED
REQUEST\_BOARD\_TRAINING\_COMPLETED
REQUEST\_BOARD\_TEST\_REQUEST\_SENT
REQUEST\_BOARD\_TEST\_REQUEST\_CONFIRMED
REQUEST\_BOARD\_ADOPTION\_STATUS\_MARKED
UNCONFIRMED\_REQUEST\_WARNING\_REVIEWED
REQUEST\_BOARD\_OPERATION\_CHECK\_COMPLETED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

27\. Failure Events

Example failure codes:

WOH.REQUEST\_BOARD.STAFF\_OWNER\_REQUIRED
WOH.REQUEST\_BOARD.DEVICE\_REQUIRED
WOH.REQUEST\_BOARD.ACCESS\_FAILED
WOH.REQUEST\_BOARD.TRAINING\_REQUIRED
WOH.REQUEST\_BOARD.TEST\_REQUEST\_FAILED
WOH.REQUEST\_BOARD.UNCONFIRMED\_ACCUMULATION
WOH.REQUEST\_BOARD.ADOPTION\_RISK
WOH.REQUEST\_BOARD.MANUAL\_POS\_CONFUSION

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

28\. Relationship To First 7 Days Activation

First 7 days activation must check whether request board is accessible and understood.

Core rule:

Activation cannot pass cleanly if request board cannot be used by staff.

29\. Relationship To First 30 Days Review

First 30 days review must evaluate whether request board became a habit.

Core rule:

First month proves request board adoption, not just access.

30\. Relationship To AI Menu Stabilization

Request board clarity depends on menu accuracy.

If menu options are wrong, staff cannot trust request summary.

Core rule:

Menu instability weakens request board adoption.

31\. Relationship To POS Manual Fallback

Request board is the primary bridge for manual POS fallback.

Core rule:

Manual POS fallback training must start from request board reading.

32\. MVP Requirements

MVP should support at least:

staff owner field
request board device/location note
request board access check
test request check
training completed flag
adoption status
unconfirmed request warning
manual POS fallback explained flag
support signal
audit event
failure event

MVP may defer:

advanced staff training module
automatic adoption scoring
device heartbeat monitoring
shift-based staff assignment
peak-time alert optimization
advanced notification preferences

33\. Suggested Conceptual Entities

Suggested entities:

request\_board\_adoption\_records
request\_board\_staff\_owners
request\_board\_operation\_checks
request\_board\_training\_events
request\_board\_adoption\_status\_events
request\_board\_support\_signals
request\_board\_audit\_events
request\_board\_failure\_events

This document defines policy.

Actual schema may be designed later.

34\. Risk If Skipped

If Request Board Staff Adoption and Operation Check policy is skipped, risks include:

guest requests are ignored
staff does not know board exists
owner thinks service is broken
manual POS fallback becomes confusing
unconfirmed requests pile up
trial usage appears low
conversion fails despite technical activation
support cannot diagnose adoption failure
CatchMenu is perceived as extra work

Therefore, request board adoption must be treated as a Merchant Success requirement.

35\. Final Rule

Request board must become a store habit.

Final rule:

Assign staff owner.
Place board where staff works.
Train staff briefly.
Test request board.
Explain request status.
Explain critical warnings.
Train manual POS fallback.
Monitor unconfirmed requests.
Record adoption status.
Follow up adoption risk.
Do not assume a visible screen is an adopted operation.
