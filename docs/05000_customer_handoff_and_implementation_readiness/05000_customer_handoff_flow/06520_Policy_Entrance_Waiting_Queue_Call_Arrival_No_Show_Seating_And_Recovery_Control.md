# 06520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control

## 1. Purpose

This policy defines the waiting queue, customer call, arrival confirmation, no-show, seating, and recovery control boundary.

The purpose is to ensure that waiting operation is not handled as a simple queue number or informal staff judgment.

Waiting affects customer trust, table utilization, preorder continuity, staff workload, customer dispute risk, and store runtime evidence. A customer may enter waiting through entrance device, QR/NFC link, customer web app, mini kiosk, native app, or staff tablet. The system must preserve one operational truth across these paths.

This policy defines how waiting state must be created, advanced, corrected, expired, recovered, and evidenced.

## 2. Scope

This policy covers:

- Waiting queue creation and ordering
- Waiting party identity
- Customer call and notification
- Arrival confirmation
- No-show handling
- Seating and table transition
- Waiting session recovery
- Duplicate waiting detection
- Staff correction
- Manager approval for sensitive waiting actions
- Customer-facing waiting status
- Evidence requirements

This policy does not define full table optimization, reservation engine, customer loyalty priority policy, marketing notification policy, or complete native app implementation.

## 3. Baseline Dependency

This policy depends on:

`06511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

06510 defines the entrance waiting assist, customer link, web app, and native app boundary.  
This document defines the operational waiting queue and seating control rules inside that boundary.

## 4. Core Principle

Waiting state must be operationally truthful.

The system must distinguish:

1. Customer created a waiting intent
2. Customer is actively waiting
3. Store called the customer
4. Customer arrival is pending confirmation
5. Customer has arrived
6. Staff assigned a table
7. Customer is seated
8. Customer did not respond
9. Customer session expired
10. Customer requires recovery or dispute review

A waiting number alone is insufficient.

The system must know whether the waiting session is active, called, arrived, seated, no-show, cancelled, expired, merged, split, or under review.

## 5. Waiting Queue Identity

Waiting queue identity must preserve separate references.

Required or possible references include:

- Waiting session ID
- Store ID
- Business date
- Party identity
- Guest session ID
- Customer account ID, where available
- Device session ID
- Customer link reference
- Staff actor ID, if staff-created or corrected
- Table session ID, if assigned
- Preorder/cart/order reference, if attached
- Notification reference, where applicable
- Incident or dispute reference, where applicable

The waiting session ID must not replace customer account, order, payment, or table session IDs.

## 6. Waiting Session Creation

A waiting session may be created through:

- Entrance QR/NFC link
- Entrance assist device
- Customer web app
- Future native app
- Mini kiosk
- Staff tablet
- Manager console, where required
- Recovery or duplicate-merge flow

Waiting session creation must capture:

- Store context
- Business date
- Creation source
- Party label or guest reference
- Party size, where applicable
- Contact or notification method, where allowed
- Language preference, where applicable
- Service mode expectation, where applicable
- Timestamp
- Consent marker, where required
- Staff actor, if assisted

Waiting session creation must not automatically imply seating, order acceptance, or payment acceptance.

## 7. Waiting Queue Ordering

Waiting queue ordering must be governed by explicit rules.

Queue ordering may consider:

- Creation time
- Party size
- Table availability
- Service mode
- Staff adjustment
- Manager-approved priority
- Accessibility need, if policy allows
- Reservation or pre-booked context, if later supported
- Operational exception

If queue order is changed manually, the system must record:

- Actor
- Before order
- After order
- Reason
- Affected waiting sessions
- Whether manager approval was required

Queue reordering must be visible to staff and reviewable in dispute cases.

## 8. Waiting State Lifecycle

Waiting session states include:

| State | Meaning |
|---|---|
| Draft | Waiting intent exists but is not submitted |
| Waiting | Party is actively waiting |
| Call Pending | Store is preparing to call the party |
| Called | Party has been called or notified |
| Arrival Pending | Party must approach or confirm arrival |
| Arrived | Party arrival has been confirmed |
| Seating Pending | Staff is assigning or preparing table |
| Seated | Party has been seated or assigned service context |
| No-Show Pending | Party missed response window and staff must confirm |
| No-Show | Party did not respond within allowed window |
| Cancelled | Waiting was cancelled |
| Expired | Waiting session timed out |
| Merged | Waiting session was merged into another session |
| Split | Waiting session was split into multiple sessions |
| Manual Review Required | Staff or manager must resolve ambiguity |
| Dispute Linked | Customer dispute exists |

State transitions must be timestamped and actor-linked where applicable.

## 9. Customer Call Boundary

A customer call may occur through:

- App/web notification
- SMS or message channel, if approved
- Entrance display
- Staff verbal call
- Staff tablet action
- Kiosk/mini kiosk continuation prompt
- Native app push, if later supported

A call action must record:

- Call timestamp
- Call channel
- Waiting session
- Staff actor or system trigger
- Message type
- Response window
- Delivery result, where available
- Customer response, where available

A customer must not be marked no-show solely because a notification was attempted if delivery or response conditions are not clear.

## 10. Arrival Confirmation

Arrival confirmation may be performed by:

- Staff
- Customer through link
- Entrance device
- Mini kiosk
- Manager, in exception cases

Arrival confirmation must verify:

- Correct waiting session
- Party identity or label
- Party size, where needed
- Preorder/cart association, where applicable
- Table availability
- Staff readiness
- Any payment/order uncertainty before seating, where applicable

Arrival confirmation must not automatically finalize table assignment if table context is not ready.

## 11. No-Show Boundary

No-show is a sensitive customer-facing state.

No-show may be applied only when:

- Customer was called according to policy
- Response window elapsed
- Staff reviewed or confirmed condition where required
- No active arrival or recovery signal exists
- Attached preorder/payment/order state is reviewed
- Customer-facing message is consistent with policy

No-show must not delete waiting evidence.

No-show state must preserve:

- Call history
- Response window
- Staff confirmation, if any
- Customer response, if any
- Attached order/preorder/payment context
- Reversal eligibility
- Dispute linkage, if any

## 12. No-Show Reversal

No-show reversal may be required when:

- Customer arrived but staff missed confirmation
- Notification failed or was delayed
- Customer used another device/link
- Party was waiting nearby but not recognized
- Staff applied no-show incorrectly
- Customer had attached preorder or payment context
- Manager accepts service recovery

No-show reversal must usually require staff or manager action.

Reversal must record:

- Actor
- Original no-show timestamp
- Reversal timestamp
- Reason
- Customer/session reference
- Queue position effect
- Table/seating effect
- Whether compensation or dispute review is required

No-show reversal must not silently restore original queue position without policy.

## 13. Seating Boundary

Seating may occur only after controlled transition.

Seating requires:

- Waiting session is valid
- Party arrival is confirmed or staff-approved
- Table/service context exists
- Party size is compatible or exception-approved
- Preorder/cart/order context is reviewed
- Payment/order uncertainty is not blocking seating
- Staff actor is recorded
- Table session is created or linked

Seating must create or link a table session.

A seated party must not lose its waiting, preorder, order, payment, or customer link references.

## 14. Table Assignment Correction

Table assignment correction may be required when:

- Wrong table assigned
- Party size changed
- Customer moved table
- Preorder attached to wrong table
- Staff seated wrong party
- Table became unavailable
- Customer requested change
- Manager approved exception

Correction must preserve:

- Previous table
- New table
- Actor
- Reason
- Timestamp
- Affected orders
- Affected KDS/kitchen tickets
- Customer-facing impact

Table correction must not duplicate kitchen tickets or payment/order references.

## 15. Duplicate Waiting Detection

Duplicate waiting may occur when:

- Customer scans QR multiple times
- Party members create separate sessions
- Customer uses both web app and native app
- Staff creates manual session for existing party
- Mini kiosk creates assist session
- Customer returns after expired link
- No-show customer creates new session

Duplicate detection must support:

- Suggest merge
- Mark potential duplicate
- Staff review
- Manager review where impact is high
- Preserve original sessions
- Link attached orders/payments where applicable
- Prevent accidental double seating

Duplicate waiting must not be resolved by deleting one session without evidence.

## 16. Waiting Recovery

Waiting recovery may be required when:

- Link expired
- Customer lost browser session
- Customer missed call
- Staff created manual backup
- Customer claims they were skipped
- Table assignment failed
- Preorder/order did not follow seating
- Customer used multiple devices
- No-show reversal is requested
- Incident affected waiting flow

Recovery must prioritize:

1. Avoiding customer misinformation
2. Avoiding duplicate waiting
3. Avoiding duplicate order or payment
4. Preserving queue fairness
5. Preserving evidence for dispute review

## 17. Staff Correction Boundary

Staff may correct waiting state when necessary.

Correctable items may include:

- Party label
- Party size
- Contact or notification preference, where allowed
- Language preference
- Queue note
- Arrival status
- Table candidate
- Staff note
- Duplicate marker
- Recovery note

High-impact corrections require manager approval or review, including:

- Queue priority change
- No-show reversal
- Seating reversal
- Table reassignment after order/kitchen state
- Customer dispute-linked correction
- Waiting session merge involving payment/order references

## 18. Customer-Facing Waiting Status

Customer-facing waiting status must be safe and understandable.

| Internal State | Customer-Facing Boundary |
|---|---|
| Draft | Waiting request not submitted yet |
| Waiting | You are waiting |
| Call Pending | Please stay ready |
| Called | Please come to the entrance |
| Arrival Pending | Staff is checking your arrival |
| Arrived | Arrival confirmed |
| Seating Pending | Staff is preparing your seat |
| Seated | You have been seated |
| No-Show Pending | Staff is checking your waiting status |
| No-Show | Waiting was missed or ended |
| Cancelled | Waiting cancelled |
| Expired | Waiting session expired |
| Manual Review Required | Staff is checking your waiting request |

Customer-facing status must not expose internal blame, staff notes, or unrelated queue data.

## 19. Incident And Dispute Linkage

Waiting flow must create or link incident/dispute records when:

- Customer claims they were skipped
- No-show is disputed
- Notification failed
- Queue order changed unexpectedly
- Duplicate waiting caused service conflict
- Seated party lost preorder/order context
- Table assignment created customer conflict
- Staff correction materially changed customer position
- Customer-facing waiting status was incorrect
- Waiting flow affected payment/order/kitchen execution

Waiting disputes must link to customer dispute and support handoff where appropriate.

## 20. Daily Closeout Impact

Daily closeout must review waiting exceptions.

Closeout should include:

- Open waiting sessions
- Called but unresolved sessions
- No-show sessions
- No-show reversals
- Cancelled or expired sessions
- Merged/split waiting sessions
- Table reassignment cases
- Waiting-linked disputes
- Waiting-linked incidents
- Staff correction patterns
- Evidence gaps

Open waiting sessions must not remain invisible after daily closeout.

## 21. Evidence Requirements

The system must preserve evidence for:

- Waiting session creation
- Queue position assignment
- Queue reorder
- Customer call
- Notification attempt
- Customer response
- Arrival confirmation
- No-show pending
- No-show confirmation
- No-show reversal
- Seating
- Table assignment
- Table correction
- Duplicate detection
- Merge/split
- Recovery
- Staff correction
- Manager approval
- Customer-facing status display
- Incident/dispute linkage
- Daily closeout waiting summary

Evidence must include:

- Store ID
- Business date
- Waiting session ID
- Party reference
- Customer or guest reference, where available
- Device/link/session source
- Actor ID where applicable
- Timestamp
- Before state
- After state
- Reason
- Related table/order/payment/incident/dispute reference where applicable

## 22. Acceptance Criteria

This policy is accepted when:

- Waiting state is not treated as a simple queue number
- Waiting identity is separated from customer, order, payment, and table identity
- Queue ordering and manual reordering are auditable
- Customer call and notification rules are documented
- No-show requires controlled state transition
- No-show reversal is evidenced
- Seating creates or links table session
- Duplicate waiting detection preserves evidence
- Staff correction and manager approval boundaries are defined
- Customer-facing waiting status is conservative
- Daily closeout reviews waiting exceptions
- Evidence requirements are traceable

## 23. Out of Scope

This policy does not include:

- Full reservation engine
- Full table optimization algorithm
- Full membership priority policy
- Marketing notification automation
- Native app push implementation
- Final customer UI copy deck
- Full customer compensation policy
- Full table layout design

Those must be handled in reservation, table management, membership, marketing, native app, support, or store layout lanes.

## 24. Related Documents

Related document families include:

- Entrance waiting assist and customer link policy
- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- Staff Tablet and Manager Console WorkPackage
- Customer dispute and support handoff WorkPackage
- Store Runtime incident command WorkPackage
- Daily closeout WorkPackage
- Runtime evidence policy
- Waiting operation SOP
- Customer notification policy
- Table assignment policy

## 25. Final Rule

Waiting is the first promise the store makes to a customer.

That promise must be fair, recoverable, staff-correctable, customer-readable, and evidence-backed from queue creation through call, arrival, seating, no-show, recovery, and closeout.

This policy defines the waiting queue and seating control boundary before table management, preorder linking, and customer notification policies expand the flow.