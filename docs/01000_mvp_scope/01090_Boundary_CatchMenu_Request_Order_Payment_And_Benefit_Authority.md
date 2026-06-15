# 01090_Boundary_CatchMenu_Request_Order_Payment_And_Benefit_Authority

1\. Purpose

This document defines the authority boundary between guest request, store confirmation, POS order, payment, settlement, KDS execution, benefit routing, and support review in CatchMenu.

CatchMenu must not confuse request visibility with transaction authority.

CatchMenu may help a guest express intent, help a store receive the request, help staff hand off to POS/KDS, and help support understand what happened.

However, CatchMenu must not silently become POS, payment, settlement, KDS, refund, or benefit authority unless explicitly integrated and authorized.

Core purpose:

Separate request from order.
Separate order from payment.
Separate payment from settlement.
Separate settlement from benefit.
Separate visibility from authority.

Korean purpose:

요청과 주문을 구분한다.
주문과 결제를 구분한다.
결제와 정산을 구분한다.
정산과 혜택 확정을 구분한다.
보이는 것과 권한을 구분한다.

2\. Core Principle

CatchMenu may carry guest intent and handoff context.

CatchMenu does not automatically own downstream authority.

Core rule:

Guest request is not POS order.
Store confirmation is not payment.
POS handoff is not settlement.
KDS visibility is not kitchen authority unless integrated.
Benefit candidate is not benefit granted.
Support review is not mutation authority.

Korean rule:

손님 요청은 POS 주문이 아니다.
매장 확인은 결제가 아니다.
POS 전달은 정산이 아니다.
KDS 표시가 곧 주방 권한은 아니다.
혜택 후보는 혜택 확정이 아니다.
지원 검토는 상태 변경 권한이 아니다.

3\. Authority Domains

CatchMenu must separate authority domains.

Suggested domains:

guest\_intent\_authority
store\_acknowledgment\_authority
manual\_staff\_handling\_authority
pos\_transaction\_authority
kds\_execution\_authority
payment\_authority
settlement\_authority
benefit\_routing\_authority
support\_review\_authority
audit\_evidence\_authority

Each domain should define:

who can create
who can confirm
who can mutate
who can cancel
who can view
who can audit
what evidence is required

4\. Guest Intent Authority

Guest intent authority belongs to the guest before store confirmation.

Guest may:

view menu
select items
change selections before confirmation
choose language
add request memo
submit request if the stage supports it
show selected menu to staff

Guest may not:

confirm store order
complete payment unless payment module exists
force POS order creation
force KDS execution
grant benefits
approve refund
change request after store confirmation without staff process

Core rule:

Guest controls intent before store confirmation.
Guest does not control store execution.

5\. Store Acknowledgment Authority

Store acknowledgment authority belongs to authorized store owner/staff or an approved store-side runtime action.

Store may:

view request
confirm request
lock guest self-edit after confirmation
ask guest to reconfirm
mark request handled
mark request completed in POS-less stages
trigger manual POS handoff
trigger staff recovery

Store confirmation means:

the store has seen and acknowledged the request
guest self-edit may be locked
the request may become eligible for stage-specific handling

Store confirmation does not automatically mean:

payment completed
POS transaction created
food served
benefit granted
refund impossible
legal responsibility closed

6\. Manual Staff Handling Authority

In Stage 0A, 0B, 0C, and Stage 1, staff may handle requests manually.

Manual handling may include:

verbally confirming guest request
entering order into POS manually
telling kitchen manually
checking allergy or dietary request
asking guest for clarification
marking request handled in CatchMenu

Boundary:

Manual handling is operational action.
Manual handling is not automatic POS proof unless recorded by POS or authorized staff evidence.

7\. POS Transaction Authority

POS transaction authority belongs to the POS system or authorized POS operator.

CatchMenu may:

prepare handoff context
send handoff request if POS Adapter exists
store POS reference
record handoff success or failure
provide evidence for support

CatchMenu must not:

silently create POS transaction without approved adapter
rewrite POS transaction state
delete POS transaction history
decide payment settlement
override POS rejection
retry indefinitely without trace

Core rule:

POS owns transaction authority.
CatchMenu owns handoff context and trace.

8\. KDS Execution Authority

KDS execution authority belongs to KDS or authorized kitchen operation.

CatchMenu may:

show kitchen assist context
send KDS handoff if adapter exists
store KDS reference
record KDS handoff success or failure
help support understand kitchen handoff state

CatchMenu must not:

pretend kitchen assist is official KDS authority
silently rewrite kitchen execution state
complete kitchen execution without KDS/staff authority
erase KDS rejection
auto-resolve KDS mismatch

Core rule:

KDS owns kitchen execution state.
CatchMenu owns visibility, handoff context, and integration trace.

9\. Payment Authority

Payment authority belongs to the payment system, POS payment module, PG provider, or authorized payment operation.

CatchMenu may:

display pay-at-store guidance
reference payment status if integrated
store masked payment reference
support payment issue evidence

CatchMenu must not:

claim payment completed without payment authority
approve refund
change payment status directly
store raw payment credentials
expose raw payment payload
settle transaction

Core rule:

Payment authority must be explicit.
Payment visibility is not payment authority.

10\. Settlement Authority

Settlement authority belongs to settlement system, finance module, POS settlement, PG settlement, or authorized accounting process.

CatchMenu may:

provide request/order context
provide support evidence
provide benefit candidate context
reference settlement status if authorized

CatchMenu must not:

calculate final settlement without finance authority
override settlement result
reallocate money
grant compensation
close accounting dispute

Core rule:

Settlement is finance authority, not request authority.

11\. Benefit Routing Authority

Benefit routing may exist in Stage 5 or external membership integration.

CatchMenu may:

create benefit candidate
route benefit claim
link request to tenant/store benefit rule
record benefit routing attempt
record benefit review requirement

CatchMenu must not:

silently grant benefit
merge identities without explicit rule
grant cross-tenant benefit
overwrite external membership record
resolve benefit dispute without authority

Core rule:

Benefit candidate is not benefit granted.
Benefit routing must be explicit, traceable, and reversible.

12\. Support Review Authority

Support review may explain, summarize, classify, and recommend.

Support review may use:

pgvector policy retrieval
Evidence Packet
Secondary Support View
Primary read-only last resort
gateway access logs
failure events

Support review must not:

mutate request state directly
approve refund directly
grant benefit directly
rewrite POS/KDS history
delete evidence
erase failure events
decide legal fault

Core rule:

Support review is interpretation authority.
Support review is not runtime mutation authority.

AI response authority is governed by:

08300\_AI\_Response\_Boundary.md

13\. Audit And Evidence Authority

Audit and evidence authority belongs to append-only event and evidence systems.

Evidence may explain what happened.

Evidence must not become action authority.

Evidence Packet may include:

request timeline
state transition history
store confirmation
translation context
POS/KDS handoff reference
support signal
failure event
gateway access log

Evidence Packet must not:

change request state
approve compensation
grant refund
grant benefit
rewrite history

Core rule:

Evidence explains.
Evidence does not approve.

14\. Stage-Based Authority Summary

14.1 Stage 0A

Guest intent exists on guest device.
No store request authority.
No POS authority.
No KDS authority.
No payment authority.

14.2 Stage 0B

Guest may send request to store console.
Store may view request.
Request is not confirmed order.
No POS authority.
No payment authority.

14.3 Stage 0C

Store may confirm request.
Store confirmation may lock guest edit.
Confirmed request may become auto-completion candidate.
Unconfirmed request must not become completed order.
No POS authority.
No payment authority.

14.4 Stage 1

Waiting and manual POS handoff may exist.
Staff manually enters POS.
CatchMenu supports handoff context.
POS authority remains outside CatchMenu.

14.5 Stage 2

Kitchen assist may show preparation context.
Kitchen assist is not final KDS authority.
POS authority remains separate.

14.6 Stage 3

POS Adapter may send handoff.
POS owns transaction authority.
CatchMenu owns handoff trace and support evidence.

14.7 Stage 4

POS and KDS adapters may exist.
POS owns transaction state.
KDS owns kitchen execution state.
CatchMenu owns guest intent, handoff context, and integration trace.

14.8 Stage 5

Benefit routing and SaaS/franchise integration may exist.
Benefit candidate is not benefit granted.
External membership identity must not be silently merged.

15\. Authority Matrix

Suggested authority matrix:

Guest selection
\- authority: guest
\- evidence: request version
\- mutation: guest before confirmation

Store confirmation
\- authority: store owner/staff
\- evidence: confirmation event
\- mutation: store-side action

POS transaction
\- authority: POS
\- evidence: POS reference
\- mutation: POS or authorized POS adapter only

KDS execution
\- authority: KDS/kitchen
\- evidence: KDS reference
\- mutation: KDS or authorized kitchen action only

Payment
\- authority: payment/POS/PG
\- evidence: payment reference
\- mutation: payment authority only

Settlement
\- authority: finance/settlement system
\- evidence: settlement reference
\- mutation: finance authority only

Benefit
\- authority: benefit/membership system
\- evidence: benefit routing reference
\- mutation: benefit authority only

Support explanation
\- authority: support/AI/human support
\- evidence: Evidence Packet
\- mutation: none

16\. Prohibited Authority Confusion

CatchMenu must avoid these authority confusions:

request sent \= order confirmed
store confirmed \= payment completed
manual handoff \= POS accepted
kitchen assist visible \= KDS accepted
benefit candidate \= benefit granted
support review \= refund approval
Evidence Packet \= legal conclusion
AI answer \= runtime mutation

Each confusion should be treated as a design risk.

17\. Guest-Facing Language Boundary

Guest-facing language must not imply false authority.

Avoid:

Order completed
Payment completed
Benefit granted
Kitchen accepted
POS confirmed
Refund approved

unless the relevant authority confirms it.

Preferred language:

Request sent
Store confirmed
Please pay at store
Please ask staff
Request needs confirmation
Request expired

18\. Merchant-Facing Language Boundary

Merchant-facing language may be operational but must remain accurate.

Allowed:

신규 요청
주문 확인
손님 수정 잠김
수동 POS 입력 필요
POS 전달 실패
주방 확인 필요
완료 처리
미확인 만료

Caution:

"완료" must mean CatchMenu stage completion, not necessarily payment settlement.

If needed, merchant-facing UI should distinguish:

요청 완료
POS 완료
결제 완료
주방 완료
정산 완료
혜택 확정

19\. Support-Facing Authority Language

Support-facing views should show authority source.

Example:

request\_state \= STORE\_CONFIRMED
authority\_source \= store\_owner\_console
payment\_status \= unknown
pos\_reference \= none
kds\_reference \= none
benefit\_status \= not\_applicable

Support must be able to see what is known and what is not known.

20\. Authority Escalation

Some actions require authority escalation.

Examples:

refund request
benefit dispute
payment mismatch
POS transaction mismatch
KDS execution dispute
food safety complaint
legal complaint
privacy issue
cross-tenant identity issue

Escalation should route to the correct authority owner.

AI or support should not resolve outside its authority.

21\. Failure And Diagnostic Rule

Authority boundary failures must produce typed failure events.

Examples:

attempt to auto-complete unconfirmed request
attempt to mark payment complete without payment authority
attempt to grant benefit without benefit authority
attempt to mutate POS state without POS authority
attempt to bypass guest edit lock

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

22\. Evidence Preservation

Authority-related actions must preserve evidence.

Suggested evidence events:

GUEST\_REQUEST\_CREATED
REQUEST\_VERSION\_UPDATED
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
MANUAL\_POS\_HANDOFF\_DONE
POS\_HANDOFF\_ACCEPTED
KDS\_HANDOFF\_ACCEPTED
PAYMENT\_REFERENCED
BENEFIT\_CANDIDATE\_CREATED
BENEFIT\_ROUTING\_CONFIRMED
SUPPORT\_REVIEW\_REQUIRED
AUTHORITY\_DENIED

Evidence must be append-only.

23\. No Silent Authority Upgrade

The system must not silently upgrade authority.

Examples of prohibited silent upgrade:

Stage 0C request becomes POS order without POS integration
Kitchen Assist becomes official KDS authority
Benefit candidate becomes benefit granted
Support note becomes runtime state change
AI answer becomes refund approval

Core rule:

Authority upgrade must be explicit, configured, logged, and reversible where possible.

24\. Final Statement

CatchMenu must remain clear about what it owns and what it does not own.

It may carry guest intent, store confirmation, handoff context, support evidence, and integration trace.

It must not silently become POS, KDS, payment, settlement, benefit, refund, or legal authority.

Final rule:

Request is not order.
Confirmation is not payment.
Handoff is not settlement.
Visibility is not authority.
Evidence is not approval.
AI is not operator.
