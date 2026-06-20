# 001299_Index_Stage_0_And_Readiness_Check.md

Legacy path: $old.

1\. Purpose

This document closes the Stage 0 Entry Runtime document set.

Stage 0 is the lightweight CatchMenu adoption stage for merchants that do not yet need POS integration, KDS integration, payment integration, or table-level runtime.

Stage 0 allows guests to scan QR/NFC Entry Media, view menu, select items, show staff, optionally send requests to the store, and optionally use a POS-less request confirmation board.

Core purpose:

Summarize Stage 0 document set.
Confirm Stage 0 boundaries.
Define readiness checks before moving to Stage 1\.
Prevent Stage 0 from expanding into POS, KDS, payment, settlement, or waiting handoff.

Korean purpose:

Stage 0 문서 묶음을 정리한다.
Stage 0 경계를 확인한다.
Stage 1로 넘어가기 전 준비상태를 점검한다.
Stage 0이 POS, KDS, 결제, 정산, 대기 핸드오프까지 확장되는 것을 막는다.

2\. Stage 0 Definition

Stage 0 is the entry-level CatchMenu runtime.

It supports:

QR/NFC entry
multilingual menu view
menu selection
show-to-staff
send-to-store request
POS-less confirmation board
basic owner request view
unconfirmed request warning
forced cleanup guard
support signal
evidence baseline

Stage 0 does not support:

POS transaction authority
KDS ticket authority
payment completion
settlement
automatic kitchen dispatch
waiting queue handoff
legal final order confirmation
full membership wallet
coupon/benefit settlement

Core rule:

Stage 0 is communication and visibility support.
Stage 0 is not transaction authority.

3\. Stage 0 Sub-Stage Summary

Stage 0 is divided into three sub-stages.

Stage 0A
\= multilingual QR/NFC menu view \+ show-to-staff

Stage 0B
\= guest request sent to store owner web console

Stage 0C
\= POS-less request confirmation board

Stage 0A is the lightest.

Stage 0C is still POS-less.

Core rule:

Even Stage 0C is not POS, KDS, payment, or settlement.

4\. Document Index

This folder contains:

01100\_Stage\_0\_Readme.md
01110\_Stage\_0A\_QR\_Menu\_And\_Show\_To\_Staff\_Flow.md
01120\_Stage\_0B\_Send\_To\_Store\_Request\_Flow.md
01130\_Stage\_0C\_POS\_Less\_Request\_Confirmation\_Board.md
01140\_Stage\_0\_Guest\_Web\_Screen\_Policy.md
01150\_Stage\_0\_Owner\_Web\_Console\_Policy.md
01160\_Stage\_0\_Request\_State\_Transition\_Guard.md
01170\_Stage\_0\_Unconfirmed\_Request\_Warning\_And\_Forced\_Cleanup.md
01180\_Stage\_0\_Translation\_And\_Critical\_Request\_Handling.md
01190\_Stage\_0\_Support\_Signal\_And\_Evidence\_Packet.md
01200\_Stage\_0\_Entry\_Media\_Kit\_And\_Context\_Resolution\_Policy.md
01290\_Stage\_0\_MVP\_Implementation\_Cutline.md
01299\_Stage\_0\_Index\_And\_Readiness\_Check.md

5\. Related Root-Level Documents

Stage 0 depends on root-level Entry Media Inventory.

Related folder:

docs/00300\_entry\_media\_inventory/

Important documents:

00300\_Entry\_Media\_Inventory\_Readme.md
00310\_QR\_NFC\_Entry\_Plate\_Assignment\_Recovery\_And\_Reallocation\_Policy.md
00320\_Entry\_Media\_Mapping\_History\_And\_Deactivation\_Policy.md
00330\_Entry\_Media\_Status\_Lifecycle\_And\_Audit\_Policy.md
00340\_Entry\_Media\_Test\_Field\_Sample\_And\_Production\_Separation\_Policy.md
00350\_Entry\_Media\_Lost\_Damaged\_And\_Retired\_Asset\_Policy.md
00360\_Entry\_Media\_Identifier\_Encoding\_And\_Resolution\_Policy.md
00370\_Entry\_Media\_Scan\_Usage\_And\_Trial\_Observation\_Policy.md
00380\_Entry\_Media\_Admin\_Access\_Suspension\_And\_Service\_Termination\_Link\_Policy.md
00390\_Entry\_Media\_Production\_Batch\_Stock\_And\_Inventory\_Control\_Policy.md
00399\_Entry\_Media\_Inventory\_Index\_And\_MVP\_Cutline.md

Core separation:

00300 \= reusable QR/NFC/Entry Plate asset lifecycle
01100\~01299 \= Stage 0 guest/request runtime usage

6\. Stage 0 Constitution

Stage 0 follows these constitution-level rules:

Guest selection is intent.
Store confirmation is acknowledgment.
Manual handling is store operation.
POS transaction belongs to POS.
KDS execution belongs to KDS.
Payment belongs to payment authority.
Settlement belongs to finance authority.
Evidence explains but does not approve.
AI may assist but does not operate.

Korean summary:

손님의 선택은 의사 표현이다.
매장의 확인은 요청 확인이다.
수동 처리는 매장 운영이다.
POS 거래 권한은 POS에 있다.
KDS 실행 권한은 KDS에 있다.
결제 권한은 결제 시스템에 있다.
정산 권한은 정산 시스템에 있다.
Evidence는 설명할 뿐 승인하지 않는다.
AI는 보조할 뿐 운영 주체가 아니다.

7\. Stage 0A Readiness

Stage 0A is ready when the system supports:

QR/NFC entry
store-level context resolution
menu context resolution
language selection
menu list
menu detail
item selection
quantity selection
option display
show-to-staff view
store-language summary
not-confirmed notice
safe fallback
basic event log

Stage 0A must not require:

owner console
request sending
store confirmation
POS
KDS
payment
table identity

Readiness rule:

A guest can scan, view menu, select items, and show staff without creating a store-side order.

8\. Stage 0B Readiness

Stage 0B is ready when the system supports:

all Stage 0A readiness
request creation
request\_id
request\_version
send-to-store action
owner request list
owner request detail
guest language
store language summary
critical warning display
request status
request event log
request evidence baseline

Stage 0B must not claim:

store accepted
order confirmed
payment completed
POS accepted
KDS accepted

Readiness rule:

A guest can send intent to the store, and the store can see it as a request, not as a confirmed transaction.

9\. Stage 0C Readiness

Stage 0C is ready when the system supports:

all Stage 0B readiness
Confirm Request action
Done action
STORE\_CONFIRMED state
GUEST\_EDIT\_LOCKED state
unconfirmed warning
forced cleanup guard
confirmed auto-completion
close auto-completion
state transition guard
stale version warning
support review path

Stage 0C must not claim:

POS order completed
payment completed
KDS completed
settlement completed
legal finalization

Readiness rule:

The store can acknowledge a request and lock guest editing, while unconfirmed requests remain protected from false completion.

10\. Guest Screen Readiness

Guest screen is ready when it can show:

QR/NFC landing
language selection
menu list
menu detail
selected menu review
show-to-staff
send request
request sent status
store confirmed status
edit locked status
request expired or unavailable status
safe fallback

Guest screen must avoid internal terms:

runtime
adapter
gateway
tenant
Evidence Packet
support signal
mapping\_id
entry\_media\_id
trace\_id
POS handoff
KDS adapter
pgvector

Guest-facing wording should be simple:

View menu
Choose language
Select menu
Show staff
Send request
Store confirmed
Ask staff
Pay at store
Request expired

11\. Owner Console Readiness

Owner console is ready when it can show:

new request list
request detail
selected items
quantity
options
guest memo
guest language
store language summary
critical warning
request version
request status
Confirm Request
Done
unconfirmed warning
forced cleanup alert

Owner console must not overload early merchants.

Core rule:

Start with fewer buttons.
Add actions only when stores can understand and operate them.

12\. Entry Media Readiness

Stage 0 Entry Media is ready when:

Entry Plate exists
QR/NFC identity exists
Entry Media mapping is active
store-level context exists
menu context exists
enabled\_stage exists
safe fallback exists
scan log exists
resolution failure path exists

Stage 0 must not own:

Entry Plate production
Entry Plate recovery
Entry Plate reallocation
mapping history
lost/damaged/retired lifecycle

Core rule:

Entry Media Inventory resolves.
Stage 0 consumes resolved context.

13\. Menu Data Readiness

Stage 0 requires menu data to be usable.

Minimum menu data:

menu category
item name
price if used
description if available
option group if used
sold-out flag if available
language fields if available
critical warning candidates if available

Stage 0 does not own how menu data is created.

AI Menu Intake should be handled separately in owner/admin onboarding.

Possible future document:

docs/02400\_owner\_console/02440\_AI\_Menu\_Intake\_And\_Menu\_Draft\_Generation\_Policy.md

Core rule:

Stage 0 consumes menu context.
AI Menu Intake creates draft menu context.

14\. Translation Readiness

Translation is ready when the system supports:

guest language selection
store language fallback
translated item name if available
translated description if available
original text preservation
critical warning preservation
translation confidence
LOW or UNKNOWN caution

Translation must not:

erase original guest text
hide critical warnings
claim allergy safety without confirmation
convert uncertain text into certain operational truth

Core rule:

Translate for understanding.
Never translate away safety.

15\. Critical Request Readiness

Critical request handling is ready when the system can flag:

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

Staff-facing screen must show critical warning clearly.

Core rule:

Critical warnings must remain visible until properly reviewed.

16\. State Guard Readiness

State transition guard is ready when the system checks:

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
fallback\_condition

Prohibited transitions must be blocked:

REQUESTED → AUTO\_COMPLETED
UNCONFIRMED\_WARNING → AUTO\_COMPLETED
FORCED\_CLEANUP\_REQUIRED → AUTO\_COMPLETED
REQUESTED → PAYMENT\_COMPLETED
REQUESTED → POS\_HANDOFF\_ACCEPTED
REQUESTED → KDS\_HANDOFF\_ACCEPTED

Core rule:

No transition without authority and event.

17\. Unconfirmed Request Readiness

Unconfirmed request policy is ready when the system supports:

REQUESTED state
STORE\_CONFIRMED state
UNCONFIRMED\_WARNING
FORCED\_CLEANUP\_REQUIRED
UNCONFIRMED\_EXPIRED
SUPPORT\_REVIEW\_REQUIRED

Default example:

REQUESTED \+ 30 minutes without STORE\_CONFIRMED
→ UNCONFIRMED\_WARNING

Forced cleanup example:

10 or more unconfirmed requests
→ FORCED\_CLEANUP\_REQUIRED

Core rule:

Unconfirmed requests must not be auto-completed as completed orders.

18\. Auto-Completion Readiness

Auto-completion is ready only when confirmed request protection exists.

Allowed:

STORE\_CONFIRMED \+ configured time
→ AUTO\_COMPLETED

Allowed:

STORE\_CONFIRMED \+ business close
→ CLOSE\_AUTO\_COMPLETED

Prohibited:

REQUESTED without STORE\_CONFIRMED
→ AUTO\_COMPLETED

Core rule:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed.

19\. Support Signal Readiness

Support Signal is ready when the system can emit:

REQUEST\_SEND\_FAILED
OWNER\_CONSOLE\_UNAVAILABLE
LOW\_CONFIDENCE\_TRANSLATION
UNKNOWN\_TRANSLATION\_CONFIDENCE
CRITICAL\_REQUEST\_DETECTED
STORE\_RECONFIRM\_REQUIRED
REQUEST\_VERSION\_CONFLICT
DUPLICATE\_REQUEST\_SUSPECTED
UNCONFIRMED\_REQUEST\_WARNING
UNCONFIRMED\_REQUEST\_FORCED\_CLEANUP
AUTO\_COMPLETION\_DENIED\_UNCONFIRMED
REQUEST\_STATE\_TRANSITION\_DENIED
ENTRY\_MEDIA\_RESOLUTION\_FAILED

Support Signal must not mutate request state.

Core rule:

Support Signal alerts.
Authorized runtime functions act.

20\. Evidence Packet Readiness

Evidence baseline is ready when the system can explain:

how guest entered
which Entry Media was used
which menu context was shown
which request version was sent
what the guest selected
what translation was shown
what critical warnings existed
when store viewed or confirmed
why edit was locked
why warning or cleanup occurred
which support signals were emitted
which failure events occurred

Core rule:

Evidence explains.
Evidence does not approve.

21\. Event Logging Readiness

Stage 0 event logging is ready when the system can record:

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

Minimum event fields:

event\_id
request\_id
request\_version
previous\_state
new\_state
actor\_type
actor\_id
store\_id
created\_at
trace\_id

22\. Security Readiness

Stage 0 security is ready when:

QR/NFC does not grant admin access
owner console requires authentication
guest flow is separate from owner/admin flow
public scan token does not expose service keys
admin actions require authorized actor
support mode is role-restricted
state transitions are guarded

Core rule:

Entry Media opens guest flow.
Owner/admin access requires authentication.

23\. Privacy Readiness

Stage 0 privacy is ready when simple menu viewing does not require:

guest name
phone number
email
payment identity
membership identity
precise personal profile

Allowed lightweight context:

anonymous session
language choice
selected menu
guest memo if entered
scan source
request context

Core rule:

Stage 0 should be low-friction and privacy-light.

24\. Analytics Readiness

Stage 0 analytics may count:

QR scans
NFC taps
menu opens
language selections
show-to-staff opens
requests sent
store confirmations
unconfirmed warnings
failure events

Stage 0 analytics should not become invasive guest tracking.

Core rule:

Measure adoption.
Do not over-track guests.

25\. AI Boundary Readiness

Stage 0 AI usage is ready only if AI remains assistive.

Allowed:

menu translation draft
request summary draft
critical warning candidate detection
support summary draft

Prohibited:

confirm order
approve allergy safety
change state silently
mark POS/KDS accepted
mark payment complete
decide refund
decide legal responsibility

Core rule:

AI assists.
Runtime authority acts.

26\. Deferred Scope Confirmation

Before leaving Stage 0, confirm the following are deferred:

POS adapter
KDS adapter
payment
settlement
table-level ordering
waiting queue handoff
full membership wallet
coupon/benefit settlement
advanced analytics
robot/agent execution
AI autonomous operation
full franchise reporting

Deferred does not mean forgotten.

Deferred means not Stage 0\.

27\. Stage 0 Completion Criteria

Stage 0 document set is complete when it defines:

0A flow
0B flow
0C flow
guest screen policy
owner console policy
state transition guard
unconfirmed warning
forced cleanup
translation and critical handling
support signal
evidence packet
Entry Media context resolution
MVP implementation cutline
readiness checklist

This document set now provides that structure.

28\. Stage 1 Entry Criteria

Stage 1 may begin when Stage 0 boundaries are clear.

Stage 1 should focus on:

waiting session
pre-order while waiting
guest readiness
staff review
manual POS entry support
handoff evidence
arrival or seating relationship
request-to-order handoff

Stage 1 should not reopen Stage 0 as if Stage 0 owns POS/KDS/payment.

Core rule:

Stage 0 is menu/request visibility.
Stage 1 is waiting-to-order manual handoff.

29\. Stage 0 Risk If Skipped

If Stage 0 readiness is skipped, risks include:

guest thinks request is paid order
store thinks request is POS order
unconfirmed requests are falsely completed
critical allergy warning is hidden
stale request version is confirmed
QR/NFC mapping cannot be explained
support cannot reconstruct request timeline
Stage 1 inherits unclear request states

Therefore, Stage 0 must be closed clearly before Stage 1\.

30\. Final Readiness Statement

Stage 0 is ready to hand off to Stage 1 when:

Entry Media entry is resolved safely.
Menu view is clear.
Guest selection is treated as intent.
Show-to-staff is clearly not order confirmation.
Send-to-store is clearly a request.
Store confirmation is acknowledgment only.
Unconfirmed requests are protected.
Critical warnings remain visible.
Events and evidence exist.
Support signals alert without mutation.
POS, KDS, payment, and settlement remain outside Stage 0\.

31\. Final Rule

Stage 0 must remain lightweight, honest, and safe.

Final rule:

Let guests enter easily.
Let menus be understood.
Let intent be communicated.
Let stores acknowledge requests.
Do not fake POS.
Do not fake KDS.
Do not fake payment.
Do not fake settlement.
Preserve events.
Preserve evidence.
Close Stage 0 before entering Stage 1\.
