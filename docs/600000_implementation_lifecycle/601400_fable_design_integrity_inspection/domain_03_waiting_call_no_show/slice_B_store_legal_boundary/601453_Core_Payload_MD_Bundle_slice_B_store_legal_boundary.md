===== BEGIN docs/004000_store_runtime_pos_kds_operations/004100_menu_availability_soldout_runtime/004120_Policy_Limited_Quantity_Menu_And_Waiting_Preorder_Control.md =====
# 004120_Policy_Limited_Quantity_Menu_And_Waiting_Preorder_Control.md

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

docs/000080_Governance_CatchMenu_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy.md

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

===== BEGIN docs/010000_runtime_foundation_and_cross_room_architecture/010800_legal_notice_sop_and_regulatory_control/010802_Policy_Refund_Cancellation_No_Show_Notice_And_Dispute_Evidence_SOP.md =====
# 010802_Policy_Refund_Cancellation_No_Show_Notice_And_Dispute_Evidence_SOP.md

## Purpose

This document defines the Refund, Cancellation, No-Show, Deposit, Order Change, Sold-Out, Payment Error, Customer Mistake, Store Mistake, System Failure, Dispute Evidence, and Support Escalation SOP Policy for Catch Menu.

The previous document `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy` defined alcohol age-gate, adult confirmation, staff ID verification, alcohol blocking, alcohol evidence, and regulated alcohol order governance.

This document focuses on refund and cancellation risk because table order, app order, reservation deposit, pickup, delivery, fast track, and immediate-cooking food orders create frequent disputes.

This document defines how refund/cancellation notices must be shown, when acknowledgement is needed, how evidence must be captured, and how support must handle disputes.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Refund and cancellation policy must follow actual order state.

The correct rule is:

Order requested is not kitchen accepted.  
Kitchen accepted is not payment captured.  
Payment authorized is not payment settled.  
Customer mistake is not always refundable.  
Store mistake is not customer fault.  
Sold-out is not customer cancellation.  
No-show deposit is not ordinary payment.  
Refund notice must appear before the irreversible point.  
Refund evidence must record the exact policy version shown.  
Support must judge based on order state, payment state, KDS state, notice evidence, and store policy version.  

A refund policy is unsafe if it is only text and not connected to order/payment/KDS state.

---

## 3. Scope

This policy applies to:

- table order
- app order
- mini kiosk order
- full kiosk order
- pickup order
- delivery order
- waiting order
- reservation order
- fast track order
- prepaid order
- postpaid order
- split payment
- deposit payment
- market-price order
- alcohol order
- coupon/point order
- sold-out cancellation
- kitchen accepted order
- customer mistake order
- store mistake order
- system failure order
- refund support case
- dispute evidence packet

This policy defines SOP governance only.

It is not a runtime implementation.

---

## 4. Refund And Cancellation State Registry

Recommended refund/cancellation states:

| State | Meaning |
|---|---|
| `CANCEL_AVAILABLE` | Customer can cancel |
| `CANCEL_REVIEW_REQUIRED` | Staff review required |
| `CANCEL_LOCKED_KITCHEN_SENT` | Kitchen has received order |
| `CANCEL_LOCKED_PREP_STARTED` | Preparation started |
| `CANCEL_LOCKED_COMPLETED` | Food completed |
| `CANCELLED_BY_CUSTOMER` | Customer cancelled |
| `CANCELLED_BY_STORE` | Store cancelled |
| `CANCELLED_BY_SOLD_OUT` | Sold-out cancellation |
| `CANCELLED_BY_SYSTEM_FAILURE` | System failure cancellation |
| `CANCELLED_BY_NO_SHOW` | No-show cancellation |
| `CANCELLED_BY_POLICY` | Policy-based cancellation |
| `REFUND_PENDING` | Refund pending |
| `REFUND_APPROVED` | Refund approved |
| `REFUND_REJECTED` | Refund rejected |
| `PARTIAL_REFUND_PENDING` | Partial refund pending |
| `PARTIAL_REFUND_APPROVED` | Partial refund approved |
| `REFUND_PROVIDER_PENDING` | PG/provider processing |
| `REFUND_COMPLETED` | Refund complete |
| `DISPUTE_OPEN` | Dispute opened |
| `DISPUTE_ESCALATED` | Escalated |
| `RECONCILIATION_REQUIRED` | Payment/order mismatch |

Unknown state must not be treated as refund approved.

---

## 5. Order State Inputs

Refund decision must consider:

| Input | Example |
|---|---|
| Order request state | Draft, submitted, accepted |
| KDS state | Not sent, sent, accepted, cooking, completed |
| Payment state | Not paid, authorized, captured, cancelled, refunded |
| POS state | Accepted, failed, unknown |
| Menu state | Available, sold out, market price |
| Customer action | Mistake, cancel request, no-show |
| Store action | Store cancellation, substitution |
| System action | Timeout, retry, duplicate |
| Delivery/pickup state | Not prepared, prepared, handed off |
| Reservation state | Before cutoff, after cutoff, no-show |
| Notice evidence | Refund notice shown/acknowledged |
| Policy version | Active policy at order time |

Refund rules must be state-based.

---

## 6. Cancellation Notice Timing

Cancellation notice must appear before irreversible action.

Recommended timing:

| Flow | Notice Surface |
|---|---|
| Immediate cooking table order | Cart / checkout before order send |
| Prepaid pickup | Checkout before payment |
| Reservation deposit | Reservation payment screen |
| Fast track order | Fast track confirmation |
| Alcohol order | Alcohol confirmation and checkout |
| Market-price order | Price confirmation screen |
| Delivery order | Checkout and delivery rule screen |
| Set/course order | Set confirmation |
| Coupon/point order | Cart before final apply |
| Split payment | Split payment confirmation |
| Postpaid table order | Order send confirmation |

Notice shown after the irreversible point is weak evidence.

---

## 7. Immediate Cooking Cancellation Boundary

Immediate cooking items require clear cancellation rule.

Recommended notice:

    Food preparation may begin immediately after order transmission. Once the kitchen accepts or starts preparation, cancellation due to simple change of mind may be restricted according to store policy.

System behavior must define:

| State | Recommended Handling |
|---|---|
| Before order submit | Customer can edit/cancel |
| Submitted but not KDS accepted | Cancel may be available |
| KDS accepted | Cancel locked or staff review |
| Prep started | Cancel locked except store mistake |
| Completed | Cancel locked |
| Store mistake | Refund/replacement review |
| Customer mistake | Store policy applies |
| System error | Support/reconciliation |

KDS state must be part of refund decision.

---

## 8. Customer Mistake Order Boundary

Customer mistake examples:

- wrong menu tapped
- wrong quantity selected
- wrong table selected
- wrong temperature selected
- wrong option selected
- duplicate item added
- coupon not applied before payment
- spicy level selected incorrectly
- alcohol item selected accidentally

Recommended handling:

| Situation | Handling |
|---|---|
| Before submit | Customer can edit |
| Immediately after submit before kitchen accept | Cancel/change may be allowed |
| After kitchen accept | Staff review |
| After prep start | Refund usually restricted |
| Store UI ambiguity | Support review |
| System duplicate caused by bug | System/store responsibility review |

Customer mistake must be judged with UI evidence and order state.

---

## 9. Store Mistake Boundary

Store mistake examples:

- wrong item served
- wrong option prepared
- missing item
- delayed beyond policy
- quality issue
- allergen exclusion ignored
- sold-out item accepted
- staff manual error
- menu price configured incorrectly by store
- customer request confirmed but not followed

Recommended handling:

| Situation | Handling |
|---|---|
| Wrong item before consumption | Replacement or refund review |
| Missing item | Fulfill or refund item |
| Allergen exclusion ignored | Escalate high-risk |
| Sold-out accepted | Refund/substitute with consent |
| Store delay | Compensation/recovery policy |
| Menu price error | Price correction policy and evidence |

Store mistake must not be hidden behind generic no-refund wording.

---

## 10. Sold-Out Cancellation Boundary

Sold-out cancellation is store/system cancellation.

Flow:

1. Customer orders item.
2. KDS/POS/store marks item sold out.
3. System checks payment state.
4. Customer receives sold-out notice.
5. Store may offer substitute.
6. If customer refuses or no substitute exists, refund is initiated.
7. Evidence records sold-out event and refund state.

Sold-out is not customer cancellation.

Refund should follow provider/payment state.

---

## 11. Substitution Boundary

Substitution requires customer consent.

Example:

    Salmon poke sold out. Store offers shrimp poke at same price.

Substitution evidence should capture:

| Field | Meaning |
|---|---|
| original_item | Sold-out item |
| substitute_item | Proposed item |
| price_difference | Difference |
| customer_choice | Accept/refuse |
| consent_time | Time |
| staff_actor | If staff-assisted |
| refund_if_refused | Refund action |
| audit_ref | Audit reference |

No silent substitution.

---

## 12. Reservation Deposit Boundary

Reservation deposit is not ordinary menu payment.

Deposit policy must define:

- reservation time
- cancellation cutoff
- refund tiers
- no-show condition
- grace period
- group size threshold
- deposit amount
- applied-to-bill behavior
- forfeiture reason
- store override authority
- customer notice version
- evidence retention

Deposit forfeiture requires stronger notice evidence.

---

## 13. No-Show Policy Boundary

No-show can occur in:

- waiting
- reservation
- pickup
- group booking
- fast track pickup
- deposit reservation
- table arrival after call
- delivery handoff failure

Recommended no-show states:

| State | Meaning |
|---|---|
| `NO_SHOW_WARNING_SENT` | Warning sent |
| `NO_SHOW_GRACE_RUNNING` | Grace period active |
| `NO_SHOW_CONFIRMED` | No-show confirmed |
| `NO_SHOW_CANCELLED_BY_STORE` | Store cancelled |
| `NO_SHOW_PENALTY_APPLIED` | Penalty applied |
| `NO_SHOW_DISPUTE_OPEN` | Customer disputes |
| `NO_SHOW_RECOVERY_GRANTED` | Store grants recovery |
| `NO_SHOW_REVERSED` | Penalty reversed |

No-show penalty requires timestamp evidence.

---

## 14. Waiting No-Show Flow

Waiting no-show flow:

1. Customer joins waitlist.
2. Waiting notice and call expiry rule are shown.
3. Customer is called.
4. Grace timer starts.
5. Customer fails to arrive within configured time.
6. Waiting entry is auto-cancelled.
7. Evidence records call time, notice, grace period, cancellation.
8. Customer may rejoin according to policy.

Waiting no-show usually should not involve payment unless deposit exists.

---

## 15. Pickup No-Show Flow

Pickup no-show flow:

1. Customer places pickup order.
2. Pickup time and freshness notice are shown.
3. Store prepares item.
4. Customer does not arrive.
5. Store may hold for configured time.
6. After hold time, food may be discarded.
7. Refund eligibility follows policy and food state.
8. Evidence records ready time, notification, hold period, disposal if any.

Fresh food pickup no-show is high dispute risk.

---

## 16. Group Reservation No-Show Flow

Group reservation flow:

1. Customer reserves group table.
2. Deposit/no-show policy is shown.
3. Customer pays deposit if required.
4. Cancellation cutoff applies.
5. Store prepares seats/materials/ingredients.
6. Customer arrives late or not at all.
7. Grace period runs.
8. No-show penalty or deposit forfeiture may apply.
9. Evidence packet records all timestamps.

Group reservation policy must be visible before deposit payment.

---

## 17. Market Price Refund Boundary

Market-price item requires price confirmation.

Flow:

1. Menu shows market price.
2. Customer requests item.
3. Store confirms current price.
4. Customer accepts confirmed price.
5. Payment/order proceeds.
6. Refund/cancel follows confirmed price evidence.

If price was not confirmed, dispute risk is high.

Market price must not be charged silently.

---

## 18. Price Typo Correction Boundary

Price typo example:

    20,000 item displayed as 2,000.

Correction flow:

1. Store/system detects price typo.
2. Order is paused if possible.
3. Customer receives correction notice.
4. Customer may accept corrected price or cancel.
5. If payment occurred, cancel/refund/recharge path is governed.
6. Evidence records original display, correction notice, customer response.

Price correction must not be silent.

---

## 19. Payment Error Refund Boundary

Payment error cases:

| Case | Handling |
|---|---|
| Duplicate payment | Verify provider records and refund duplicate |
| Authorized but order failed | Cancel authorization or refund |
| Order accepted but payment failed | Ask customer for payment or cancel |
| PG/VAN pending | Wait/reconcile before duplicate charge |
| Split payment mismatch | Lock final order until balanced |
| Refund provider delay | Show provider delay notice |
| Partial refund needed | Item-level refund review |
| Unknown provider state | Reconciliation required |

Payment state must be source-of-truth through provider evidence.

---

## 20. Split Payment Boundary

Split payment disputes may occur when:

- one participant fails to pay
- total split amount mismatch
- table leaves before payment complete
- partial refund needed
- coupon applied unevenly
- item ownership unclear

Required evidence:

- table order total
- participant payments
- unpaid balance
- split rule
- payment state
- refund allocation
- notice shown
- audit

Split payment must not mark order settled until fully reconciled.

---

## 21. Coupon Point Refund Boundary

Refund involving benefits must define:

| Benefit | Refund Handling |
|---|---|
| Coupon | Restore or expire according policy |
| Point used | Return points or not according policy |
| Point earned | Cancel earned points if refund |
| Gift item | Return/charge/recover rule |
| 1+1 promotion | Reverse both paid/free component if needed |
| Store event | Store-specific policy |
| Franchise coupon | Franchise/HQ policy |

Benefit reversal must be auditable.

---

## 22. Alcohol Refund Boundary

Alcohol refund must consider:

- adult verification failed
- ID check refused
- alcohol delivery blocked
- alcohol set cannot split
- alcohol component can be removed
- payment already captured
- staff mistake
- customer mistake
- legal policy

Alcohol refund should reference `10721`.

Alcohol item must not proceed if verification fails.

---

## 23. Refund Evidence Packet

Refund dispute evidence should include:

| Field | Meaning |
|---|---|
| `case_id` | Support/dispute case |
| `tenant_id` | Tenant |
| `store_id` | Store |
| `order_id` | Order |
| `payment_id` | Payment |
| `customer_id` | Customer if known |
| `session_id` | Session |
| `order_state` | State at dispute |
| `kds_state` | Kitchen state |
| `payment_state` | Payment/provider state |
| `refund_state` | Refund state |
| `notice_id` | Refund/no-show notice |
| `notice_version_id` | Exact notice version |
| `notice_shown_at` | When shown |
| `acknowledged_at` | When acknowledged |
| `customer_request_time` | Cancel/refund request time |
| `store_action_time` | Store action time |
| `reason_code` | Reason |
| `decision` | Approved/rejected/partial |
| `decision_actor` | Staff/support/HQ |
| `audit_ref` | Audit reference |

Evidence must reconstruct the decision.

---

## 24. Reason Code Registry

Recommended refund/cancel reason codes:

| Code | Meaning |
|---|---|
| `CUSTOMER_CHANGED_MIND` | Simple change of mind |
| `CUSTOMER_ORDER_MISTAKE` | Customer selected wrong item |
| `DUPLICATE_ORDER` | Duplicate order |
| `STORE_SOLD_OUT` | Store sold out |
| `STORE_WRONG_ITEM` | Wrong item prepared |
| `STORE_MISSING_ITEM` | Missing item |
| `STORE_QUALITY_ISSUE` | Quality issue |
| `ALLERGEN_REQUEST_FAILED` | Allergen/exclusion request failed |
| `PAYMENT_DUPLICATE` | Duplicate payment |
| `PAYMENT_PROVIDER_ERROR` | Provider error |
| `POS_ORDER_MISMATCH` | POS/order mismatch |
| `KDS_DELAY` | Kitchen delay |
| `NO_SHOW_WAITING` | Waiting no-show |
| `NO_SHOW_RESERVATION` | Reservation no-show |
| `NO_SHOW_PICKUP` | Pickup no-show |
| `ALCOHOL_ID_FAIL` | Alcohol ID failed |
| `DELIVERY_FAILURE` | Delivery failure |
| `FORCE_MAJEURE` | Disaster/force majeure |
| `PRICE_TYPO` | Price typo |
| `MARKET_PRICE_DISPUTE` | Market price dispute |
| `MANUAL_COMPENSATION` | Manual customer recovery |

Reason codes must be controlled.

---

## 25. Decision Authority Matrix

Refund decisions require authority.

| Decision | Authority |
|---|---|
| Customer cancel before submit | Customer |
| Cancel before KDS accept | System/store policy |
| Cancel after KDS accept | Staff/manager |
| Refund store mistake | Manager/store owner |
| Refund system failure | Support/HQ |
| Refund payment duplicate | Payment support |
| No-show deposit forfeiture | Store policy + evidence |
| Reverse no-show penalty | Manager/HQ |
| Alcohol ID failure refund | Staff/manager + policy |
| Manual compensation | Manager/HQ depending amount |
| Large refund | Owner/HQ |
| Legal dispute refund | Legal/HQ |

AI cannot approve refund.

---

## 26. Support Dispute Flow

Support dispute flow:

1. Customer opens dispute.
2. Support retrieves order state.
3. Support retrieves KDS state.
4. Support retrieves payment state.
5. Support retrieves notice evidence.
6. Support retrieves store policy version.
7. Support identifies reason code.
8. Support checks authority matrix.
9. Support approves, rejects, partially refunds, or escalates.
10. Decision is audited.
11. Customer is notified.

Support decision must be evidence-based.

---

## 27. Store Manager Flow

Store manager flow:

1. Refund/cancel request arrives.
2. Manager views order state.
3. Manager views kitchen state.
4. Manager views payment state.
5. Manager chooses reason code.
6. Manager selects action:
   - approve cancel
   - reject cancel
   - partial refund
   - replacement
   - substitute
   - compensation
   - escalate
7. System records decision.
8. Customer receives notice.

Manager authority may be amount-limited.

---

## 28. Customer UX Requirements

Customer screen should clearly show:

- cancellation availability
- irreversible order point
- expected prep status
- refund eligibility
- deposit/no-show rule
- pickup hold time
- sold-out refund behavior
- payment refund processing delay
- coupon/point reversal rule
- support contact route
- dispute status

Customer should not need to guess refund status.

---

## 29. Admin Configuration Requirements

Admin refund settings should include:

| Setting | Meaning |
|---|---|
| Immediate cooking cancel policy | When cancel locks |
| KDS acceptance cancel rule | State-based behavior |
| Prep start cancel rule | State-based behavior |
| Pickup hold time | Hold before no-show |
| Waiting grace time | Grace before cancellation |
| Reservation cancellation tiers | Deposit refund tiers |
| Group reservation deposit | Required amount/rule |
| Sold-out substitution policy | Offer substitute or auto refund |
| Customer mistake policy | Store policy |
| Payment error support route | Support or store |
| Manual compensation limit | Manager authority |
| Coupon reversal policy | Benefit handling |
| Alcohol verification failure policy | Refund/remove/cancel |
| Force majeure policy | Refund/cancel behavior |

Admin settings must be versioned and auditable.

---

## 30. Notification Requirements

Refund/cancel notifications may include:

- cancel request received
- cancel approved
- cancel rejected
- partial refund approved
- sold-out cancellation
- substitution proposal
- refund provider pending
- refund completed
- no-show warning
- no-show confirmed
- deposit forfeited
- dispute opened
- dispute decision
- support escalation

Notifications must use i18n keys and policy version references where needed.

---

## 31. Reconciliation Boundary

Refund/cancel flow must reconcile:

- order ledger
- payment provider
- POS
- KDS
- coupon/points
- settlement
- receipt
- support case

If any state conflicts, mark:

    RECONCILIATION_REQUIRED

Do not silently mark refund complete without provider confirmation.

---

## 32. Receipt Boundary

Receipts should reflect:

- original order
- cancellation if any
- refund if any
- partial refund if any
- coupon/point reversal
- VAT/tax impact
- PG cancellation reference
- no-show deposit status
- final paid amount
- final settlement amount

Receipt must not lie about payment state.

---

## 33. Audit Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `REFUND_NOTICE_SHOWN` | Refund notice shown |
| `REFUND_NOTICE_ACKNOWLEDGED` | Refund notice confirmed |
| `ORDER_CANCEL_REQUESTED` | Cancel requested |
| `ORDER_CANCEL_APPROVED` | Cancel approved |
| `ORDER_CANCEL_REJECTED` | Cancel rejected |
| `ORDER_CANCEL_LOCKED_BY_KDS` | KDS state locked cancel |
| `ORDER_CANCELLED_BY_SOLD_OUT` | Sold-out cancellation |
| `SUBSTITUTE_OFFERED` | Substitute offered |
| `SUBSTITUTE_ACCEPTED` | Substitute accepted |
| `SUBSTITUTE_REJECTED` | Substitute rejected |
| `REFUND_REQUESTED` | Refund requested |
| `REFUND_APPROVED` | Refund approved |
| `REFUND_REJECTED` | Refund rejected |
| `PARTIAL_REFUND_APPROVED` | Partial refund approved |
| `REFUND_PROVIDER_PENDING` | Provider pending |
| `REFUND_COMPLETED` | Refund complete |
| `NO_SHOW_WARNING_SENT` | No-show warning sent |
| `NO_SHOW_CONFIRMED` | No-show confirmed |
| `NO_SHOW_PENALTY_APPLIED` | Penalty applied |
| `DEPOSIT_FORFEITED` | Deposit forfeited |
| `PAYMENT_RECONCILIATION_REQUIRED` | Reconciliation needed |
| `REFUND_DISPUTE_OPENED` | Dispute opened |
| `REFUND_DISPUTE_ESCALATED` | Dispute escalated |
| `REFUND_DECISION_RECORDED` | Decision recorded |

Events must route through `10610`.

---

## 34. Security Boundary

Refund and no-show evidence is financial/compliance-sensitive.

Rules:

- support access must be case-scoped
- refund approval requires authority
- large refunds require reauthentication
- manual compensation requires audit
- payment provider IDs must be protected
- customer personal data must be masked where possible
- refund decision cannot be overwritten silently
- old policy versions must remain readable
- tenant/store scope mandatory
- export requires authority and audit

Refund evidence must be protected like financial records.

---

## 35. Anti-Patterns

Avoid:

- using one generic no-refund text for every state
- showing cancellation restriction only after payment
- ignoring KDS state in refund decision
- refunding without payment provider confirmation
- treating sold-out as customer cancellation
- silently substituting menu without consent
- treating market price as zero-price
- forfeiting deposit without notice evidence
- applying no-show penalty without timestamp evidence
- letting AI approve refund
- allowing support to edit refund evidence
- hiding refund state from customer
- failing to reverse coupon/points during refund
- marking refund complete while provider state is pending
- changing historical refund policy text

These anti-patterns must be blocked in future runtime design.

---

## 36. Runtime Deferral

This document defines refund, cancellation, no-show, deposit, payment error, substitution, dispute evidence, and support SOP governance only.

It does not authorize:

- refund runtime implementation
- cancellation engine implementation
- no-show automation
- deposit payment implementation
- payment provider refund integration
- coupon reversal implementation
- support console implementation
- KDS/POS state integration
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 37. Validation Checklist

Validation must confirm:

1. Refund and cancellation state registry is defined.
2. Order state inputs are defined.
3. Cancellation notice timing is defined.
4. Immediate cooking cancellation boundary is defined.
5. Customer mistake order boundary is defined.
6. Store mistake boundary is defined.
7. Sold-out cancellation boundary is defined.
8. Substitution boundary is defined.
9. Reservation deposit boundary is defined.
10. No-show policy boundary is defined.
11. Waiting no-show flow is defined.
12. Pickup no-show flow is defined.
13. Group reservation no-show flow is defined.
14. Market price refund boundary is defined.
15. Price typo correction boundary is defined.
16. Payment error refund boundary is defined.
17. Split payment boundary is defined.
18. Coupon/point refund boundary is defined.
19. Alcohol refund boundary is defined.
20. Refund evidence packet is defined.
21. Reason code registry is defined.
22. Decision authority matrix is defined.
23. Support dispute flow is defined.
24. Store manager flow is defined.
25. Customer UX requirements are defined.
26. Admin configuration requirements are defined.
27. Notification requirements are defined.
28. Reconciliation boundary is defined.
29. Receipt boundary is defined.
30. Audit event catalog is defined.
31. Security boundary is defined.
32. Anti-patterns are listed.
33. Coding remains unauthorized.
34. Runtime remains deferred.

---

## 38. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10720 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`

It also references:

- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10440 Coupon Point Wallet And Stored Value Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10701 Five-Minute Smart Order Fast Track KDS Throttling No-Show Penalty And Abuse Control Boundary Policy`
- `10715 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Refund Payment Provider Reconciliation And Evidence Packet Policy`
- `10726 No-Show Deposit Penalty And Customer Recovery SOP Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 39. Final Rule

Catch Menu refund, cancellation, and no-show policy must be state-based, evidence-backed, and aligned with POS, KDS, payment provider, coupon, point, reservation, and support workflows.

Refund notices must be shown before irreversible order or payment points.

No-show penalties and deposit forfeiture require clear notice, timing evidence, and policy version evidence.

Sold-out, store mistake, customer mistake, payment error, market price dispute, alcohol verification failure, and force majeure must be handled as separate reason-coded flows.

AI may classify risk and recommend policy routes.

AI cannot approve refunds, deny refunds, apply penalties, or mutate evidence.

Historical notice and refund evidence must never be rewritten.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.

