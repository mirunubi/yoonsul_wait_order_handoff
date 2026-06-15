# 03910_Policy_First_7_Days_Activation_Check

1\. Purpose

This document defines the First 7 Days Activation Check policy for CatchMenu / Wait Order Handoff.

After a merchant trial is activated, the first 7 days must verify that the basic service is technically accessible, operationally visible, and understandable by merchant staff.

A trial is not successful merely because an Entry Plate was installed.

A trial becomes meaningful only when the merchant can actually use the service during real store operation.

Core purpose:

Define first 7 days activation check.
Verify Entry Plate scan.
Verify store and menu context resolution.
Verify AI menu draft/live menu accuracy.
Verify guest menu view.
Verify request flow.
Verify request board visibility.
Verify staff awareness.
Verify manual POS fallback readiness.
Verify support path awareness.
Detect activation blockers early.
Prevent silent trial failure.

Korean purpose:

초기 7일 활성화 점검을 정의한다.
Entry Plate 스캔을 확인한다.
매장 및 메뉴 context resolution을 확인한다.
AI 메뉴 초안/라이브 메뉴 정확성을 확인한다.
손님 메뉴 조회를 확인한다.
요청 흐름을 확인한다.
요청판 가시성을 확인한다.
직원 인지를 확인한다.
수동 POS fallback 준비 상태를 확인한다.
지원 경로 인지를 확인한다.
초기 활성화 장애를 조기에 감지한다.
조용히 실패하는 체험을 방지한다.

2\. Scope

This document covers:

first 7 days activation
Entry Plate scan check
QR check
NFC check
store context check
menu context check
menu accuracy check
guest webapp check
request flow check
request board check
staff awareness check
Owner Console access check
manual POS fallback check
support contact check
activation blocker
activation status
activation evidence

This document does not define:

full 30-day troubleshooting
paid conversion decision
billing plan change
commission payout
POS adapter implementation
KDS implementation
AI Menu Intake engine
Entry Media inventory source of truth

Related documents:

03900\_Merchant\_Success\_Troubleshooting\_Readme.md
03920\_First\_30\_Days\_Troubleshooting\_And\_Conversion\_Readiness\_Policy.md
03930\_AI\_Menu\_Intake\_Correction\_And\_Live\_Menu\_Stabilization\_Policy.md
03940\_Request\_Board\_Staff\_Adoption\_And\_Operation\_Check\_Policy.md
03950\_POS\_Manual\_Fallback\_Training\_And\_Store\_Usage\_Policy.md
00300\_Entry\_Media\_Inventory\_Readme.md
01100\_Stage\_0\_Readme.md
02400\_owner\_console/
03610\_Service\_Plan\_Trial\_And\_Paid\_Conversion\_Policy.md

3\. Core Principle

The first 7 days prove activation, not full business value.

Core rule:

First 7 days check confirms that CatchMenu can be used.
It does not yet prove long-term conversion value.

Korean rule:

초기 7일 점검은 CatchMenu가 사용 가능한지를 확인한다.
장기 유료 전환 가치를 확정하는 단계는 아니다.

4\. Activation Is Not Installation

Installation means an Entry Plate or trial asset was placed.

Activation means the service actually works.

Installation evidence may include:

Entry Plate assigned
Entry Plate placed
QR/NFC available
merchant informed

Activation evidence requires:

scan works
store context resolves
menu opens
menu is usable
request flow works
request board is visible
staff can respond
support path is known

Core rule:

Installed is not activated.
Activated means operationally usable.

5\. First 7 Days Timeline

Suggested timeline:

Day 0:
Activation day

Day 1:
Scan and menu access check

Day 2-3:
Menu accuracy and request board check

Day 4-5:
Staff usage and manual POS fallback check

Day 6-7:
Activation status review and blocker resolution

Core rule:

Activation blockers should be detected before the first week ends.

6\. Activation Status

Suggested activation statuses:

ACTIVATION\_PENDING
ACTIVATED
PARTIALLY\_ACTIVATED
BLOCKED
REVIEW\_REQUIRED
FAILED\_ACTIVATION

Meaning:

ACTIVATION\_PENDING
\= service setup not fully checked

ACTIVATED
\= first 7 days baseline passed

PARTIALLY\_ACTIVATED
\= service works but some non-critical issue remains

BLOCKED
\= core usage is blocked

REVIEW\_REQUIRED
\= human review is required

FAILED\_ACTIVATION
\= activation did not succeed within acceptable window

7\. Entry Plate Scan Check

Entry Plate scan must be verified.

Check items:

QR scan works
NFC tap works if applicable
URL or token resolves
wrong store is not shown
expired/deactivated state is not shown incorrectly
guest web page opens
mobile browser compatibility is acceptable

Core rule:

If Entry Plate does not scan correctly, the trial has not started operationally.

8\. Store Context Resolution Check

Store context must resolve correctly.

Check items:

merchant\_store\_id correct
store name correct
store branch/location correct
service status correct
trial status correct
enabled stage correct
Entry Media mapping active

Failure examples:

wrong store opens
test store opens
inactive store opens
missing menu context
service disabled unexpectedly

Core rule:

Correct store context is required before guest use.

9\. Menu Context Check

Menu context must open correctly.

Check items:

menu\_context\_id correct
categories visible
items visible
prices visible
options visible if applicable
language toggle visible if enabled
sold-out/unavailable items handled if applicable

Core rule:

Menu must be readable and usable before request flow is promoted.

10\. AI Menu Accuracy Check

AI-generated or AI-assisted menu must be reviewed for obvious mistakes.

Check items:

item names correct
prices correct
categories reasonable
options correct
set menus not broken
spicy/vegetarian/critical labels reviewed
translation draft acceptable
allergy/critical warning candidates reviewed

Core rule:

AI menu draft speed is valuable only if first-week accuracy is verified.

11\. Guest WebApp Check

Guest WebApp must be accessible and clear.

Check items:

page loads quickly
store identity visible
menu visible
language behavior acceptable
request button behavior clear
critical notice visible if applicable
support or help path visible if applicable

Core rule:

Guest entry must be simple enough for first-time users.

12\. Request Flow Check

Request flow must be tested if enabled.

Check items:

item selection works
option selection works
quantity works
request summary correct
send request works
request status shown
store can view request
guest sees confirmation or next instruction

Core rule:

Request flow must be tested with real or controlled test request before trial is considered active.

13\. Show-To-Staff Check

If Show-To-Staff mode is used, it must be checked.

Check items:

selected item summary visible
language summary visible
options visible
quantity visible
critical warning visible
screen is easy to show to staff

Core rule:

Show-To-Staff must reduce confusion, not create a new explanation burden.

14\. Request Board Check

Request board must be visible to authorized store users.

Check items:

store user can log in
request board opens
test request appears
request detail opens
critical warning visible
confirm/done action works if enabled
old request warning works if applicable

Core rule:

Request board must be watched by store staff or Stage 0C has no operational value.

15\. Staff Awareness Check

At least one responsible store person must understand the flow.

Check items:

who checks request board
when request board is checked
what confirm means
what done means
how to handle guest show-to-staff
how to enter request into POS manually
how to contact support

Core rule:

A working system fails if no staff member owns the daily behavior.

16\. Manual POS Fallback Check

Before POS integration is available, manual POS fallback must be understood.

Check items:

staff can read request item
staff can read option
staff can read quantity
staff can identify critical warning
staff can manually enter into POS
staff knows how to avoid duplicate entry
staff knows when to mark handled

Core rule:

Manual POS fallback is official interim operation and must be trained.

17\. Owner Console Access Check

Owner or manager access should be checked.

Check items:

owner can log in
store profile visible
menu context visible
trial status visible
request board accessible if role allows
usage summary placeholder visible if available
support entry point visible

Core rule:

Owner Console access turns trial from installed asset into managed service.

18\. Support Path Check

Merchant must know how to get help.

Support path may include:

Owner Console support entry
phone or chat contact
AI customer center if available
sales partner contact
Merchant Ops contact
support case creation

Core rule:

First-week issues must have a known support path.

19\. First 7 Days Activation Blockers

Activation blockers include:

Entry Plate scan fails
wrong store opens
menu missing
menu has serious price errors
request cannot be sent
request board not accessible
staff does not know the flow
manual POS fallback impossible
owner cannot access console
support contact missing

Core rule:

Activation blocker must be resolved before conversion value can be evaluated.

20\. Activation Review Required Cases

Review is required when:

menu is partially correct but not trusted
translation issue may affect guest understanding
critical warning label is uncertain
staff is confused
owner is dissatisfied
request board is technically working but unused
manual POS fallback creates high burden
sales promise and actual feature differ

Core rule:

Review required is not failure.
It is early-risk containment.

21\. Activation Evidence

Activation evidence may include:

scan test timestamp
test request id
request board screenshot or event
menu review status
staff training confirmation
owner console access confirmation
support path confirmation
activation checklist
support notes
field note

Core rule:

Activation must be explainable through evidence, not memory.

22\. Activation Checklist

Minimum checklist:

\[ \] Entry Plate QR scan works
\[ \] NFC works if applicable
\[ \] Correct store opens
\[ \] Correct menu opens
\[ \] Menu prices checked
\[ \] Menu options checked
\[ \] Language/translation checked if enabled
\[ \] Request flow tested
\[ \] Request board tested
\[ \] Staff owner identified
\[ \] Manual POS fallback explained
\[ \] Owner Console access checked
\[ \] Support path explained
\[ \] Activation status recorded

Core rule:

Checklist must be completed or explicitly marked blocked.

23\. Activation Outcome

Possible outcomes:

PASS
PASS\_WITH\_MINOR\_ISSUE
PARTIAL\_PASS\_REVIEW\_REQUIRED
BLOCKED
FAIL

Meaning:

PASS
\= service usable

PASS\_WITH\_MINOR\_ISSUE
\= minor issue remains but trial can proceed

PARTIAL\_PASS\_REVIEW\_REQUIRED
\= service partly usable but follow-up required

BLOCKED
\= core usage blocked

FAIL
\= activation failed and trial should not be counted as healthy

24\. Trial Clock Impact

If activation is blocked, trial clock may need review.

Possible policies:

trial clock starts at installation
trial clock starts at activation
blocked days may be excluded
HQ approval required for adjustment
custom trial extension allowed

Core rule:

Trial period fairness requires knowing whether activation actually occurred.

25\. Sales Partner Responsibility

If sales partner initiated trial, sales partner may help first activation check.

Sales partner may:

verify Entry Plate placement
collect menu issue feedback
explain basic flow
report staff confusion
submit first-week field note

Sales partner must not:

hide activation blockers
promise unsupported POS/KDS integration
change billing terms
approve menu without authority
mark activation passed without evidence

Core rule:

Sales partner can support activation but cannot falsify success.

26\. Merchant Ops Responsibility

Merchant Ops owns activation stabilization.

Merchant Ops may:

review activation checklist
resolve setup blocker
coordinate AI menu correction
coordinate support case
mark activation status
trigger first 30 days review

Core rule:

Merchant Ops must convert early signals into operational follow-up.

27\. Support Signal

Support signals may include:

FIRST\_7\_DAYS\_CHECK\_REQUIRED
FIRST\_7\_DAYS\_CHECK\_OVERDUE
ENTRY\_PLATE\_SCAN\_FAILURE
WRONG\_STORE\_CONTEXT
MENU\_CONTEXT\_MISSING
AI\_MENU\_REVIEW\_REQUIRED
REQUEST\_FLOW\_TEST\_FAILED
REQUEST\_BOARD\_NOT\_ACCESSIBLE
STAFF\_OWNER\_MISSING
MANUAL\_POS\_FALLBACK\_NOT\_UNDERSTOOD
OWNER\_CONSOLE\_ACCESS\_FAILED

Support Signal alerts.

It does not change activation status by itself.

28\. Audit Events

Recommended audit events:

FIRST\_7\_DAYS\_CHECK\_CREATED
ENTRY\_PLATE\_SCAN\_CHECKED
STORE\_CONTEXT\_CHECKED
MENU\_CONTEXT\_CHECKED
AI\_MENU\_ACCURACY\_CHECKED
REQUEST\_FLOW\_TESTED
REQUEST\_BOARD\_TESTED
STAFF\_AWARENESS\_CONFIRMED
MANUAL\_POS\_FALLBACK\_EXPLAINED
OWNER\_CONSOLE\_ACCESS\_CHECKED
SUPPORT\_PATH\_EXPLAINED
ACTIVATION\_STATUS\_MARKED
ACTIVATION\_BLOCKER\_RECORDED
ACTIVATION\_BLOCKER\_RESOLVED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
entry\_media\_id
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

WOH.MERCHANT\_SUCCESS.FIRST\_7.ENTRY\_MEDIA\_SCAN\_FAILED
WOH.MERCHANT\_SUCCESS.FIRST\_7.WRONG\_STORE\_CONTEXT
WOH.MERCHANT\_SUCCESS.FIRST\_7.MENU\_CONTEXT\_MISSING
WOH.MERCHANT\_SUCCESS.FIRST\_7.REQUEST\_FLOW\_FAILED
WOH.MERCHANT\_SUCCESS.FIRST\_7.REQUEST\_BOARD\_INACCESSIBLE
WOH.MERCHANT\_SUCCESS.FIRST\_7.STAFF\_OWNER\_MISSING
WOH.MERCHANT\_SUCCESS.FIRST\_7.POS\_FALLBACK\_NOT\_READY
WOH.MERCHANT\_SUCCESS.FIRST\_7.OWNER\_CONSOLE\_ACCESS\_FAILED
WOH.MERCHANT\_SUCCESS.FIRST\_7.CHECK\_OVERDUE

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

30\. Relationship To First 30 Days Review

First 7 days check feeds First 30 Days Troubleshooting.

If first 7 days pass:

proceed to usage and adoption review

If first 7 days partially pass:

carry issue into first 30 days review

If first 7 days are blocked:

resolve blocker before evaluating trial value

Core rule:

First 30 days review should not hide unresolved first-week blockers.

31\. Relationship To AI Menu Stabilization

AI menu errors discovered in first 7 days should create menu stabilization task.

Examples:

wrong item
wrong price
wrong option
wrong translation
missing menu
incorrect critical warning

Core rule:

Menu issue found in first week must enter correction workflow.

32\. Relationship To Request Board Adoption

Request board issues discovered in first 7 days should trigger staff adoption follow-up.

Examples:

staff did not know board exists
board not opened during service
request not confirmed
staff confused by status

Core rule:

Request board adoption must be checked before request volume grows.

33\. Relationship To Billing And Trial

Billing Plan Settlement owns trial dates and paid conversion.

First 7 days check may influence:

trial fairness review
trial extension
activation date evidence
conversion readiness later
non-conversion reason

Core rule:

Activation evidence may affect trial interpretation but does not change billing by itself.

34\. MVP Requirements

First 7 Days Activation Check MVP should support at least:

activation checklist
activation status
Entry Plate scan result
store context check
menu context check
menu accuracy check
request flow test result
request board test result
staff owner field
manual POS fallback explained flag
Owner Console access checked flag
support path explained flag
activation blocker flag
support signal
audit event
failure event

MVP may defer:

automatic health score
AI-generated activation summary
advanced staff training module
video evidence
automated trial clock adjustment
advanced mobile field checklist

35\. Suggested Conceptual Entities

Suggested entities:

first\_7\_days\_activation\_checks
activation\_check\_items
activation\_blockers
activation\_status\_events
activation\_support\_signals
activation\_audit\_events
activation\_failure\_events

This document defines policy.

Actual schema may be designed later.

36\. Risk If Skipped

If First 7 Days Activation Check is skipped, risks include:

trial plate installed but not usable
wrong store opens for guests
menu errors stay live
staff never checks request board
manual POS fallback is not understood
merchant thinks service failed
sales partner claims success without evidence
trial expires without real activation
conversion discussion has no basis

Therefore, first 7 days activation check must be mandatory for trial-based growth.

37\. Final Rule

First 7 days are about proving that CatchMenu is usable in the store.

Final rule:

Do not count installation as success.
Check scan.
Check store context.
Check menu.
Check request flow.
Check request board.
Identify staff owner.
Explain manual POS fallback.
Confirm Owner Console access.
Confirm support path.
Record blockers.
Resolve blockers early.
Only then evaluate trial value.
