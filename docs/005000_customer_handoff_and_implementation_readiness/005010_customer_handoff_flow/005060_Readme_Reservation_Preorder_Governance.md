# 005060_Readme_Reservation_Preorder_Governance.md

Legacy path: $old.

1\. Purpose

This folder defines reservation, preorder, prepaid pickup, deposit, cancellation, refund, no-show, and preparation-state governance for CatchMenu / Wait Order Handoff.

CatchMenu may start as a lightweight QR/NFC menu and request platform, but later stages may support pickup reservation, advance preorder, prepaid order, group order, reservation deposit, and cancellation handling.

These flows require clear customer notice, store preparation evidence, refund rules, no-show handling, and support escalation.

Core purpose:

Define reservation and preorder governance.
Separate request from reservation.
Separate reservation from payment.
Separate payment from preparation.
Define cancellation and refund rules by preparation state.
Define same-day prepaid pickup no-show handling.
Define advance reservation deposit handling.
Define group order preparation commitment.
Preserve customer notice, consent, and evidence.
Prevent silent forfeiture without policy and evidence.

Korean purpose:

예약 및 사전주문 거버넌스를 정의한다.
요청과 예약을 분리한다.
예약과 결제를 분리한다.
결제와 조리/준비 상태를 분리한다.
준비 상태별 취소/환불 규칙을 정의한다.
당일 포장 선결제 노쇼 처리를 정의한다.
사전 예약금 처리를 정의한다.
단체 주문 준비 확정 기준을 정의한다.
고객 고지, 동의, 증빙을 보존한다.
정책과 증빙 없는 일방적 예약금 몰수를 방지한다.

2\. Scope

This folder covers:

same-day pickup reservation
prepaid pickup order
advance preorder
reservation deposit
group order reservation
cancellation window
refund rule
no-show handling
preparation state
store preparation evidence
customer notice
customer consent
support escalation
refund exception
recovery compensation

This folder does not define:

full payment gateway integration
card settlement
tax invoice
delivery app settlement
POS/KDS adapter implementation
legal final dispute resolution
court or regulatory determination

Payment and settlement details belong to payment/settlement modules.

Legal wording must be reviewed separately before public use.

3\. Core Principle

Reservation policy must be tied to preparation state and customer notice.

Core rule:

No-show penalty requires prior notice.
Refund limitation requires preparation evidence.
Deposit forfeiture must be policy-backed, consent-backed, and evidence-backed.

Korean rule:

노쇼 위약은 사전 고지가 있어야 한다.
환불 제한은 준비 상태 증빙이 있어야 한다.
예약금 귀속은 정책, 동의, 증빙이 함께 있어야 한다.

4\. Reservation Types

CatchMenu may support these reservation types:

SAME\_DAY\_PICKUP\_RESERVATION
SAME\_DAY\_PREPAID\_PICKUP
ADVANCE\_PICKUP\_RESERVATION
ADVANCE\_PREPAID\_ORDER
DEPOSIT\_BASED\_RESERVATION
GROUP\_ORDER\_RESERVATION
SPECIAL\_PREPARATION\_ORDER
CATERING\_LIKE\_ORDER

Each reservation type may have different cancellation and refund rules.

5\. Same-Day Pickup Reservation

Same-day pickup reservation means the customer reserves or orders pickup for the same business day.

Possible variants:

pay at store
prepaid
partial deposit
request only
store confirmation required

Core rule:

Same-day pickup must clearly state whether it is request, reservation, confirmed order, or prepaid order.

6\. Same-Day Prepaid Pickup

Same-day prepaid pickup means the customer has paid before pickup.

Required customer-facing notice:

pickup time
cancellation deadline
refund rule
late pickup rule
no-show rule
food disposal or quality limit notice
store contact or support method

Core rule:

Prepaid does not remove the need for cancellation notice.
Food preparation state affects refund handling.

7\. Suggested Same-Day Cancellation Rule

A simple operational rule may be:

Customer may cancel for refund until a defined cutoff before pickup time,
unless the store has already started preparation under the disclosed policy.

Example policy candidate:

Pickup cancellation is allowed until 30 minutes before pickup time if preparation has not started.
After preparation starts, refund may be limited according to store policy and evidence.

Korean customer-facing draft:

픽업 예정시간 30분 전까지는 조리 시작 전인 경우 취소 및 환불이 가능합니다.
조리가 시작된 이후에는 상품 특성상 환불이 제한될 수 있습니다.

This must be reviewed before legal/public use.

8\. No-Show Definition

No-show means the customer does not pick up the reserved/prepaid item within the allowed pickup window and does not cancel within the allowed cancellation window.

Suggested states:

PICKUP\_WAITING
PICKUP\_WINDOW\_STARTED
PICKUP\_WINDOW\_EXPIRED
NO\_SHOW\_CANDIDATE
NO\_SHOW\_CONFIRMED
DISPOSAL\_REQUIRED
DISPOSED
SUPPORT\_REVIEW\_REQUIRED

Core rule:

No-show must be state-based, not emotion-based.

9\. Pickup Window

Pickup window should be explicit.

Example:

pickup\_time \= 14:00
pickup\_grace\_window \= 20 minutes
pickup\_window\_expires\_at \= 14:20

If store operation requires stricter timing, it must be shown before order confirmation.

Core rule:

Customer must know the pickup deadline before commitment.

10\. Food Quality And Disposal Rule

Prepared food may lose quality or become unsafe after a certain time.

Store may need to dispose of food after the pickup window.

Required evidence:

prepared\_at
pickup\_deadline
customer notice
customer no-show status
disposal\_time
disposal\_reason
operator\_id

Core rule:

Disposal is food safety and quality action.
Disposal must be recorded if refund is limited because of no-show.

11\. Advance Reservation

Advance reservation means the customer reserves at least one day before pickup or service.

Examples:

2 days before pickup
3 days before group order
weekly regular pickup
special menu reservation
large quantity order

Advance reservation may require deposit if store must prepare ingredients, labor, or production capacity.

12\. Deposit-Based Reservation

Deposit-based reservation means the customer pays a reservation deposit before final payment or pickup.

Deposit may be used for:

large order commitment
special ingredient procurement
reserved production slot
staffing preparation
group order preparation
limited seasonal menu

Deposit must be clearly described as:

refundable
partially refundable
non-refundable after cutoff
applied to final payment
forfeited only under defined conditions

Core rule:

Deposit purpose and refund rule must be shown before payment.

13\. Suggested Advance Deposit Rule

For orders requiring advance preparation, a candidate rule may be:

For advance reservations requiring special preparation, a deposit may be required.
Cancellation before the preparation cutoff may allow full or partial refund.
Cancellation after ingredient procurement or preparation commitment may limit refund.

Example Korean draft:

사전 준비가 필요한 예약은 예약금이 필요할 수 있습니다.
준비 마감 전 취소 시 예약금은 전액 또는 일부 환불될 수 있습니다.
재료 발주 또는 조리 준비가 시작된 이후에는 예약금 환불이 제한될 수 있습니다.

This must be reviewed before public use.

14\. Two-Day Advance Reservation

Two-day advance reservation may be used for:

group order
large quantity pickup
special menu
reserved ingredient preparation
scheduled catering-like order

Recommended policy fields:

reservation\_created\_at
pickup\_date
reservation\_cutoff\_at
deposit\_amount
deposit\_refund\_cutoff\_at
preparation\_commitment\_at
cancellation\_status
refund\_status

Core rule:

Two-day reservation should define when the store becomes committed to preparation.

15\. Group Order Reservation

Group order may require stronger rules.

Candidate threshold:

15 portions or more
or 150,000 KRW or more

Group order may require:

minimum 2 or 3 days advance notice
deposit
store confirmation
ingredient preparation
staffing preparation
cancellation cutoff
partial refund rule

Core rule:

Group order is not ordinary same-day request.
It requires preparation commitment governance.

16\. Preparation State

Refund and cancellation should depend on preparation state.

Suggested states:

REQUESTED
STORE\_REVIEWING
STORE\_CONFIRMED
PAYMENT\_PENDING
PAID
PREPARATION\_NOT\_STARTED
INGREDIENT\_PROCUREMENT\_STARTED
INGREDIENT\_PROCUREMENT\_COMPLETED
COOKING\_STARTED
PACKAGING\_STARTED
READY\_FOR\_PICKUP
PICKUP\_WINDOW\_ACTIVE
PICKUP\_WINDOW\_EXPIRED
NO\_SHOW\_CONFIRMED
DISPOSED
CANCELLED
REFUND\_PENDING
REFUNDED
REFUND\_DENIED
SUPPORT\_REVIEW\_REQUIRED

Core rule:

Refund decision must know preparation state.

17\. Cancellation Windows

Cancellation window should be defined by reservation type.

Examples:

same-day pickup
\= cancel until 30 minutes before pickup if preparation not started

advance reservation
\= cancel before preparation commitment cutoff

group order
\= cancel before ingredient procurement or staffing commitment cutoff

special menu
\= cancel before special ingredient procurement cutoff

Core rule:

Cancellation window must be visible before customer commitment.

18\. Refund Rules

Refund rule should consider:

customer cancellation time
store confirmation time
payment time
preparation state
ingredient procurement state
pickup window
no-show status
store fault
system fault
customer notice
consent record

Possible refund outcomes:

FULL\_REFUND
PARTIAL\_REFUND
DEPOSIT\_REFUND
DEPOSIT\_FORFEIT
NO\_REFUND
STORE\_CREDIT
COUPON\_RECOVERY
SUPPORT\_REVIEW\_REQUIRED

Core rule:

Refund outcome must be explainable.

19\. Store Fault Exception

If store is at fault, refund limitation should not be applied blindly.

Store fault examples:

store failed to prepare order
store closed unexpectedly
wrong menu prepared
serious delay caused by store
pickup unavailable due to store issue
wrong customer notice
system showed wrong pickup time due to store configuration

Possible outcomes:

full refund
partial refund
replacement
coupon recovery
support escalation

Core rule:

No-show policy protects store from customer no-show.
It must not hide store fault.

20\. System Fault Exception

If CatchMenu system fault caused the issue, support review is required.

System fault examples:

payment recorded but store did not receive order
pickup time displayed incorrectly
cancellation request failed
notification failed under system responsibility
request duplicated
wrong store routed

Core rule:

System fault requires support review before refund denial.

21\. Customer Notice

Before reservation/payment/deposit, customer should see:

pickup date/time
cancellation deadline
refund rule
no-show rule
deposit rule if applicable
food quality/disposal rule
store confirmation requirement if applicable
support contact method

Core rule:

No penalty without notice.

22\. Customer Consent

Customer consent should be recorded for policies that affect refund.

Consent records may include:

policy\_version
displayed\_at
confirmed\_at
customer\_session\_id
order\_id
reservation\_id
language
device\_context

Core rule:

Refund limitation must reference the policy version the customer accepted.

23\. Evidence Packet

Reservation dispute Evidence Packet should include:

reservation\_id
order\_id
customer session
merchant store
reservation type
pickup time
payment status
deposit amount
policy version
customer notice timestamp
customer consent timestamp
store confirmation timestamp
preparation state timeline
cancellation request timestamp
pickup window status
no-show status
disposal evidence if applicable
support notes
refund decision

Core rule:

Evidence explains the refund decision.
Evidence does not decide alone.

24\. Support Review Required Cases

Support review should be required when:

customer disputes no-show
customer claims cancellation was attempted
store claims preparation started
system notification failed
wrong pickup time shown
wrong store routed
deposit forfeiture disputed
food disposed before pickup window ended
group order cancellation dispute
critical customer complaint

Core rule:

High-conflict refund cases require support review.

25\. Reservation State Authority

Not every actor can change reservation state.

Examples:

customer may request cancellation
store may confirm preparation started
store may mark ready for pickup
store may mark not picked up
support may review dispute
HQ may approve exception
system job may detect no-show candidate

Core rule:

Actor authority must match reservation state transition.

26\. System Job Boundary

System job may detect:

pickup window expired
no-show candidate
cancellation deadline passed
deposit refund cutoff passed
preparation deadline reached
support review candidate

System job must not blindly:

forfeit deposit
deny refund
dispose food
terminate merchant

Core rule:

Automation may signal.
High-impact customer decision requires policy-backed workflow.

27\. Customer-Facing Language Principle

Customer-facing policy must be simple.

Use terms like:

픽업 예정시간
취소 가능 시간
조리 시작
예약금
환불 가능 여부
노쇼
준비 완료
고객센터 문의

Avoid internal terms:

Evidence Packet
Support Signal
state transition
runtime authority
settlement
adapter

Core rule:

Customer sees clear rules.
Internal system preserves detailed evidence.

28\. MVP Requirements

Reservation Preorder MVP should support at least:

reservation type
pickup time
prepaid status
deposit status optional
cancellation deadline
preparation state
customer notice
customer consent
cancellation request
refund status
no-show candidate
no-show confirmed
support review required
basic evidence packet
audit event
failure event

MVP may defer:

complex partial refund engine
automatic card refund integration
multi-party settlement
advanced catering workflow
legal document automation
delivery platform integration
dynamic refund calculation

29\. Suggested Conceptual Entities

Suggested entities:

reservations
reservation\_items
reservation\_payments
reservation\_deposits
reservation\_status\_events
reservation\_cancellation\_requests
reservation\_refund\_reviews
reservation\_policy\_acceptances
reservation\_evidence\_packets
reservation\_support\_signals

This document defines policy.

Actual schema may be designed later.

30\. Final Rule

Reservation and preorder governance must protect both customer trust and store preparation cost.

Final rule:

Define reservation type.
Show cancellation rule before commitment.
Record customer consent.
Track preparation state.
Detect no-show by state and time.
Limit refund only with policy and evidence.
Escalate disputed cases.
Do not silently forfeit deposit.
Do not erase history.
