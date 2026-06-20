# 001140_Policy_CatchMenu_Guest_Request_Lifecycle_And_State.md

Legacy path: $old.

1\. Purpose

This document defines the guest request lifecycle and state policy for CatchMenu.

CatchMenu must clearly distinguish guest intent, store confirmation, staff handling, POS/KDS handoff, completion, expiration, cancellation, and support review.

A guest request must not be treated as a confirmed order unless the selected stage and store action allow it.

Core purpose:

Track guest intent safely.
Separate request from order.
Separate visibility from authority.
Separate confirmation from payment.

Korean purpose:

손님의 의사를 안전하게 추적한다.
요청과 주문을 구분한다.
보이는 것과 권한을 구분한다.
확인과 결제를 구분한다.

2\. Core Principle

A CatchMenu guest request is not always an order.

The meaning of a guest request depends on the adoption stage.

Core rule:

Guest selection is intent.
Store confirmation is acknowledgment.
POS transaction is transaction authority.
KDS execution is kitchen authority.
Payment is settlement authority.

Korean rule:

손님 선택은 의사 표현이다.
매장 확인은 접수 확인이다.
POS 거래가 거래 권한이다.
KDS 처리가 주방 실행 권한이다.
결제가 정산 권한이다.

3\. Lifecycle Scope

This document covers:

guest menu selection
show-to-staff request
send-to-store request
store confirmation
guest edit lock
unconfirmed warning
forced cleanup
manual staff handling
manual POS handoff
POS adapter handoff
KDS adapter handoff
completion
auto-completion
expiration
cancellation
support review

This document does not define:

payment settlement
refund approval
POS transaction schema
KDS kitchen execution schema
membership benefit settlement
AI Customer Center case lifecycle

4\. Request Identity

Each request should have a stable request identity.

Suggested identifiers:

request\_id
tenant\_id
store\_id
guest\_session\_id
guest\_language
store\_language
stage
request\_version
created\_at
updated\_at

Optional identifiers:

waiting\_id
table\_id
staff\_id
pos\_reference\_id
kds\_reference\_id
payment\_reference\_id
benefit\_candidate\_id
support\_signal\_id
evidence\_packet\_id

Request identity must remain stable even when the request changes version.

5\. Request Versioning

Guest requests may change before store confirmation.

Each change should create a new request version.

Suggested version fields:

request\_id
request\_version
version\_created\_at
version\_created\_by
version\_reason
previous\_version
is\_current\_version

Core rule:

Request updates must be versioned.
Do not silently overwrite guest intent.

After store confirmation, guest self-edit should be locked unless the stage explicitly supports store-mediated changes.

6\. Stage 0A Lifecycle

Stage 0A does not send a request to the store system.

Lifecycle:

MENU\_VIEWED
→ ITEMS\_SELECTED
→ SHOW\_TO\_STAFF\_READY
→ SHOWN\_TO\_STAFF

Meaning:

MENU\_VIEWED \= guest viewed the menu
ITEMS\_SELECTED \= guest selected items locally
SHOW\_TO\_STAFF\_READY \= guest screen is ready to show staff
SHOWN\_TO\_STAFF \= guest may have shown screen to staff

Boundary:

No store request is created.
No order is confirmed.
No POS/KDS handoff is created.
No payment is completed.

Stage 0A is guest-device-local unless support logging is explicitly enabled.

7\. Stage 0B Lifecycle

Stage 0B sends a menu request to the owner web console.

Lifecycle:

MENU\_VIEWED
→ ITEMS\_SELECTED
→ REQUEST\_READY
→ REQUEST\_SENT
→ STORE\_VIEWED
→ STORE\_RECONFIRM\_REQUIRED
or
→ STORE\_HANDLED\_MANUALLY
or
→ REQUEST\_EXPIRED

Meaning:

REQUEST\_SENT \= request was sent to the store console
STORE\_VIEWED \= store saw the request
STORE\_RECONFIRM\_REQUIRED \= store needs guest reconfirmation
STORE\_HANDLED\_MANUALLY \= staff handled the request outside CatchMenu state
REQUEST\_EXPIRED \= request expired without confirmed handling

Boundary:

REQUEST\_SENT is not a confirmed order.
STORE\_VIEWED is not payment.
STORE\_HANDLED\_MANUALLY is not POS settlement.

8\. Stage 0C Lifecycle

Stage 0C provides POS-less request confirmation.

Lifecycle:

REQUESTED
→ STORE\_CONFIRMED
→ COMPLETED

Optional paths:

REQUESTED
→ UNCONFIRMED\_WARNING
→ STORE\_CONFIRMED
→ COMPLETED

REQUESTED
→ UNCONFIRMED\_WARNING
→ FORCED\_CLEANUP\_REQUIRED
→ STORE\_CONFIRMED
→ COMPLETED

REQUESTED
→ UNCONFIRMED\_WARNING
→ UNCONFIRMED\_EXPIRED

STORE\_CONFIRMED
→ AUTO\_COMPLETED

STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

Critical rule:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

Korean rule:

매장이 확인한 요청만 자동 완료 후보가 될 수 있다.
미확인 요청은 완료 주문으로 자동 처리하면 안 된다.

9\. Stage 1 Lifecycle

Stage 1 adds waiting and manual POS handoff.

Lifecycle:

REQUESTED
→ STORE\_CONFIRMED
→ WAITING\_LINKED
→ ARRIVAL\_CONFIRMED
→ MANUAL\_POS\_HANDOFF\_READY
→ MANUAL\_POS\_HANDOFF\_DONE
→ COMPLETED

Optional issue paths:

WAITING\_LINKED
→ ARRIVAL\_MISMATCH

MANUAL\_POS\_HANDOFF\_READY
→ MANUAL\_POS\_HANDOFF\_DELAYED

MANUAL\_POS\_HANDOFF\_READY
→ MANUAL\_POS\_HANDOFF\_FAILED

MANUAL\_POS\_HANDOFF\_FAILED
→ STAFF\_MANUAL\_RECOVERY

Boundary:

Manual POS handoff means staff manually handles POS.
CatchMenu does not own POS transaction authority.

10\. Stage 2 Lifecycle

Stage 2 adds Mini KDS / Kitchen Assist.

Lifecycle:

REQUESTED
→ STORE\_CONFIRMED
→ KITCHEN\_ASSIST\_VISIBLE
→ PREPARATION\_STARTED
→ PREPARATION\_COMPLETED
→ COMPLETED

Boundary:

Kitchen Assist provides preparation visibility.
Kitchen Assist does not become official KDS authority.

If POS is not integrated, kitchen assist completion must not be interpreted as POS transaction completion.

11\. Stage 3 Lifecycle

Stage 3 adds POS Adapter.

Lifecycle:

REQUESTED
→ STORE\_CONFIRMED
→ POS\_HANDOFF\_READY
→ POS\_HANDOFF\_SENT
→ POS\_HANDOFF\_ACCEPTED
→ POS\_TRANSACTION\_REFERENCED
→ COMPLETED

Failure paths:

POS\_HANDOFF\_SENT
→ POS\_HANDOFF\_TIMEOUT

POS\_HANDOFF\_SENT
→ POS\_HANDOFF\_REJECTED

POS\_HANDOFF\_FAILED
→ MANUAL\_POS\_RECOVERY\_REQUIRED

Boundary:

POS owns transaction authority.
CatchMenu owns handoff context and evidence.

CatchMenu must not silently rewrite POS transaction state.

12\. Stage 4 Lifecycle

Stage 4 adds POS \+ KDS Adapter.

Lifecycle:

REQUESTED
→ STORE\_CONFIRMED
→ POS\_HANDOFF\_ACCEPTED
→ KDS\_HANDOFF\_READY
→ KDS\_HANDOFF\_ACCEPTED
→ KITCHEN\_EXECUTION\_REFERENCED
→ COMPLETED

Failure paths:

KDS\_HANDOFF\_READY
→ KDS\_HANDOFF\_TIMEOUT

KDS\_HANDOFF\_READY
→ KDS\_HANDOFF\_REJECTED

KDS\_HANDOFF\_FAILED
→ KITCHEN\_MANUAL\_RECOVERY\_REQUIRED

Boundary:

POS owns transaction state.
KDS owns kitchen execution state.
CatchMenu owns guest intent, handoff context, and integration trace.

13\. Stage 5 Lifecycle

Stage 5 adds SaaS, franchise, benefit routing, white-label, or external membership integration.

Lifecycle may include:

REQUESTED
→ STORE\_CONFIRMED
→ POS/KDS HANDOFF
→ BENEFIT\_CANDIDATE\_CREATED
→ BENEFIT\_ROUTING\_REQUESTED
→ BENEFIT\_ROUTING\_CONFIRMED
or
→ BENEFIT\_ROUTING\_REVIEW\_REQUIRED

Boundary:

Benefit candidate is not benefit granted.
External membership reference is not merged identity.
White-label link is not identity ownership transfer.

Benefit routing must be explicit, traceable, and reversible.

14\. Common Request States

Suggested common request states:

DRAFT
MENU\_VIEWED
ITEMS\_SELECTED
REQUEST\_READY
REQUESTED
REQUEST\_SENT
STORE\_VIEWED
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
STORE\_RECONFIRM\_REQUIRED
UNCONFIRMED\_WARNING
FORCED\_CLEANUP\_REQUIRED
UNCONFIRMED\_EXPIRED
WAITING\_LINKED
ARRIVAL\_CONFIRMED
ARRIVAL\_MISMATCH
MANUAL\_POS\_HANDOFF\_READY
MANUAL\_POS\_HANDOFF\_DONE
POS\_HANDOFF\_READY
POS\_HANDOFF\_SENT
POS\_HANDOFF\_ACCEPTED
POS\_HANDOFF\_FAILED
KDS\_HANDOFF\_READY
KDS\_HANDOFF\_ACCEPTED
KDS\_HANDOFF\_FAILED
KITCHEN\_ASSIST\_VISIBLE
PREPARATION\_STARTED
PREPARATION\_COMPLETED
COMPLETED
AUTO\_COMPLETED
CLOSE\_AUTO\_COMPLETED
CANCELLED\_BY\_GUEST
CANCELLED\_BY\_STORE
EXPIRED
SUPPORT\_REVIEW\_REQUIRED

Not every stage uses every state.

15\. State Authority

State authority must be clear.

Suggested authority mapping:

guest device
\= DRAFT, ITEMS\_SELECTED, REQUEST\_READY

CatchMenu runtime
\= REQUESTED, REQUEST\_SENT, UNCONFIRMED\_WARNING, FORCED\_CLEANUP\_REQUIRED

store owner / staff
\= STORE\_CONFIRMED, STORE\_RECONFIRM\_REQUIRED, COMPLETED

waiting runtime
\= WAITING\_LINKED, ARRIVAL\_CONFIRMED, ARRIVAL\_MISMATCH

POS adapter
\= POS\_HANDOFF\_SENT, POS\_HANDOFF\_ACCEPTED, POS\_HANDOFF\_FAILED

KDS adapter
\= KDS\_HANDOFF\_ACCEPTED, KDS\_HANDOFF\_FAILED

support system
\= SUPPORT\_REVIEW\_REQUIRED

scheduled runtime
\= AUTO\_COMPLETED, CLOSE\_AUTO\_COMPLETED, EXPIRED

Core rule:

A state must not be changed by an actor that does not own the authority for that state.

16\. Guest Edit Lock Policy

Guest self-edit should be allowed before store confirmation.

After store confirmation, guest self-edit should be locked.

Suggested flow:

REQUESTED
→ guest may edit

STORE\_CONFIRMED
→ GUEST\_EDIT\_LOCKED
→ guest must ask staff for changes

Guest-facing message:

매장에서 요청을 확인했습니다.
이제 직접 수정할 수 없습니다.
변경이 필요하면 직원에게 말씀해주세요.

English guest-facing message:

The store has confirmed your request.
You can no longer edit it directly.
Please ask staff if you need changes.

17\. Store Reconfirmation Policy

Store reconfirmation may be required when:

allergy request exists
low translation confidence
menu item sold out
option unavailable
quantity unavailable
pork/beef/seafood/nuts/alcohol caution exists
guest request is unclear
price or menu changed
staff needs verbal confirmation

Reconfirmation state:

STORE\_RECONFIRM\_REQUIRED

AI or translation should not bypass reconfirmation.

18\. Expiration Policy

Requests may expire when not handled within allowed time.

Expiration must distinguish:

unconfirmed expiration
confirmed auto-completion
general request expiration
waiting expiration
handoff expiration

Critical rule:

Expiration is not completion unless the request was confirmed and the stage policy allows auto-completion.

19\. Cancellation Policy

Cancellation may come from:

guest before store confirmation
store before handling
staff after guest communication
system expiration
support review

Cancellation must not delete history.

Suggested cancellation states:

CANCELLED\_BY\_GUEST
CANCELLED\_BY\_STORE
CANCELLED\_BY\_SYSTEM
CANCELLATION\_REVIEW\_REQUIRED

Cancellation should create an event with reason.

20\. Completion Policy

Completion means that CatchMenu's stage-specific handling has ended.

Completion does not always mean:

payment completed
POS transaction settled
food served
benefit granted
refund impossible
legal responsibility closed

Completion meaning depends on stage.

Examples:

Stage 0C COMPLETED \= store marked request as handled or confirmed auto-completion occurred.
Stage 1 COMPLETED \= manual handoff process ended.
Stage 3 COMPLETED \= POS handoff was accepted or support-safe final state reached.
Stage 5 COMPLETED \= request lifecycle completed, but benefit routing may still be pending.

21\. Support Review Policy

A request should enter support review when:

state conflict exists
handoff failed
translation risk exists
unconfirmed request dispute exists
auto-completion dispute exists
POS/KDS mismatch exists
benefit claim uncertainty exists
guest complaint exists
merchant complaint exists
evidence is incomplete

Support review state:

SUPPORT\_REVIEW\_REQUIRED

Support review does not authorize mutation.

Support review should use:

pgvector policy retrieval
Evidence Packet
Secondary Support View
Primary read-only last resort

22\. Event Sourcing Principle

Request state changes should be event-backed.

Do not rely only on overwriting the current state.

Each state transition should create an event.

Suggested event fields:

event\_id
request\_id
request\_version
previous\_state
new\_state
event\_type
event\_reason
actor\_type
actor\_id
source\_system
stage
tenant\_id
store\_id
created\_at
trace\_id

Core rule:

Current state is a projection.
Events are the history.

23\. State Transition Guard

State transitions should be guarded.

Examples:

REQUESTED → STORE\_CONFIRMED
allowed by store owner/staff or authorized runtime

REQUESTED → AUTO\_COMPLETED
not allowed

STORE\_CONFIRMED → AUTO\_COMPLETED
allowed if Stage 0C policy time condition is met

UNCONFIRMED\_WARNING → UNCONFIRMED\_EXPIRED
allowed if no store confirmation occurred

POS\_HANDOFF\_FAILED → COMPLETED
not allowed without manual recovery or authorized resolution

Invalid transitions should produce a typed failure event.

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

24\. Guest-Facing State Language

Guest-facing language should be simple.

Allowed guest-facing status examples:

Menu selected
Request sent
Store confirmed
Please ask staff
Please pay at store
Request expired
Request needs confirmation

Do not show guest-facing technical states:

POS\_HANDOFF\_ACCEPTED
KDS\_HANDOFF\_FAILED
SUPPORT\_REVIEW\_REQUIRED
EVIDENCE\_PACKET\_CREATED
PRIMARY\_READ\_USED
GATEWAY\_SCOPE\_DENIED

25\. Merchant-Facing State Language

Merchant-facing language may be more operational.

Examples:

신규 요청
확인 필요
주문 확인됨
손님 수정 잠김
미확인 경고
강제 정리 필요
수동 POS 입력 필요
POS 전달 실패
주방 확인 필요
완료
미처리 만료

Merchant-facing language should still avoid unnecessary internal terms unless support mode is enabled.

26\. Support-Facing State Language

Support-facing state may include technical context.

Examples:

REQUESTED without STORE\_CONFIRMED for 30 minutes
UNCONFIRMED\_WARNING generated
FORCED\_CLEANUP\_REQUIRED threshold reached
STORE\_CONFIRMED followed by AUTO\_COMPLETED
POS\_HANDOFF\_SENT without POS\_HANDOFF\_ACCEPTED
KDS\_HANDOFF\_REJECTED with adapter reason
Evidence Packet incomplete

Support-facing state must preserve trace and evidence references.

27\. State Projection And Read Model

The system may maintain current-state projections for fast reading.

Examples:

current\_request\_state
current\_handoff\_state
current\_waiting\_state
current\_pos\_handoff\_state
current\_kds\_handoff\_state
current\_support\_review\_state

Projection must be rebuildable from events.

Projection failure must not erase event history.

28\. Lifecycle And Evidence Packet

Evidence Packet should be able to summarize the request lifecycle.

Evidence Packet may include:

request identity
request versions
state timeline
guest language
store language
translation confidence
store confirmation status
guest edit lock status
unconfirmed warning status
POS/KDS handoff status
support signal references
gateway access references
failure event references

Evidence Packet must not become mutation authority.

29\. Lifecycle And AI Customer Center

The AI Customer Center may ask about lifecycle facts through the Support Gateway.

The AI Customer Center must not directly mutate lifecycle state.

Allowed:

explain lifecycle policy
summarize state timeline
identify missing evidence
draft merchant response
draft guest response
recommend escalation

Prohibited:

confirm request
complete request
cancel request
clear forced cleanup
retry POS handoff
retry KDS handoff
approve refund
grant benefit
overwrite state

30\. Final Statement

CatchMenu request lifecycle must distinguish intent, confirmation, handoff, execution, completion, expiration, cancellation, and support review.

A request state must be clear enough for guests, merchants, support, and developers to understand what happened and what may happen next.

Final rule:

Request is not always order.
Confirmation is not payment.
Visibility is not authority.
Completion is not always settlement.
Events preserve truth.
State is only the current projection.
