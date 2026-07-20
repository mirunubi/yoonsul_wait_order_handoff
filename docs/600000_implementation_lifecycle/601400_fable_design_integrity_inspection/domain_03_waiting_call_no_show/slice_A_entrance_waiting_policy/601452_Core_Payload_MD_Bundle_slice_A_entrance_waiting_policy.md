===== BEGIN docs/006000_customer_runtime_implementation_readiness/006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md =====
# 006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md

## 1. Purpose

This policy defines the runtime boundary between entrance waiting assistance, customer link flow, customer web app, future native app, and order runtime.

The purpose is to ensure that the customer does not become fragmented across entrance check-in, waiting queue, preorder, kiosk assistance, table matching, order confirmation, payment, and store staff handling.

Entrance waiting is not just a queue number.  
It is the first operational point where a customer session may become linked to store runtime, order intent, table context, staff assistance, and later support evidence.

This policy establishes the boundary that prevents entrance devices, waiting screens, customer links, and app flows from creating disconnected operational truth.

## 2. Scope

This policy covers:

- Entrance waiting assist device boundary
- Customer link creation and continuation
- Guest and known customer session handling
- Web app and future native app relationship
- Waiting-to-order transition
- Waiting-to-table transition
- Staff-assisted entrance correction
- Customer-facing waiting status
- Order runtime connection
- Evidence and audit requirements

This policy does not define full customer app UI, marketing membership policy, loyalty benefit logic, payment settlement, or final native app implementation.

## 3. Baseline Dependency

This policy depends on:

`014161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`006410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

`014162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control.md`

`014163_WorkPackage_Store_Runtime_Staff_Tablet_Manager_Console_Override_Manual_Control_And_Evidence_Boundary.md`

`005011_WorkPackage_Store_Runtime_Pilot_Readiness_Store_Rollout_Closeout_Expansion_Gate_And_Operational_Acceptance.md`

06500 closes the integrated Store Runtime WorkPackage lane.  
This policy opens the entrance-facing customer link and waiting assist boundary.

## 4. Core Principle

Entrance waiting must create a controlled customer runtime thread.

The system must distinguish:

1. A person physically approaching the store
2. A guest waiting session
3. A known customer account
4. A party waiting for seating
5. A customer link session opened through QR/NFC/SMS/app
6. A preorder or cart intent
7. A table or service context
8. A confirmed order
9. A payment attempt
10. A staff-assisted recovery flow

The entrance device may initiate or continue a customer thread, but it must not independently decide final order, payment, table, or service truth.

## 5. Entrance Assist Device Role

An Entrance Waiting Assist Device may support:

- QR/NFC customer link launch
- Waiting session creation
- Party information intake
- Customer phone or guest label intake, where allowed
- Language selection
- Waiting status display
- Preorder or menu browsing link
- Staff call request
- No-show recovery request
- Customer arrival confirmation
- Table assignment assistance
- Handoff into web app, native app, kiosk, or staff tablet flow

The device must be treated as a customer-facing input and guidance surface, not as the authoritative store runtime.

## 6. Customer Link Boundary

A customer link may be created through:

- QR code
- NFC tag
- SMS link
- Kakao or other message link, if later supported
- Receipt or waiting ticket code
- Staff-generated assist link
- Kiosk continuation link
- Native app deep link, if later supported

The link must carry only the minimum safe context needed to continue the flow.

A customer link must not expose:

- Internal order/payment IDs directly without scoped token
- Provider credentials
- Staff-only state
- Manager approval state
- Internal incident details
- Other customer or party data
- Unrestricted admin or store runtime authority

## 7. Customer Identity Boundary

The system must separate identity types.

| Identity Type | Meaning |
|---|---|
| Guest Session | Temporary customer interaction without full account |
| Customer Account | Known customer identity after login or matching |
| Party Identity | Group-level waiting or seating unit |
| Device Session | Browser, link, app, or entrance device session |
| Waiting Session | Queue and arrival state |
| Order Session | Cart, preorder, or accepted order thread |
| Table Session | Physical or operational seating context |
| Staff Assist Actor | Staff member assisting customer flow |

The entrance flow must not collapse all identities into a single customer field.

## 8. Web App And Native App Boundary

The customer web app is the primary lightweight runtime surface for early phases.

The future native app may later support:

- Persistent login
- Push notification
- Membership
- Saved preferences
- Repeat order
- Store discovery
- Loyalty wallet
- Reservation or waiting history
- Native payment integration, if approved

However, web app and native app must share the same Store Runtime truth.

The native app must not create a separate order state model, waiting model, or payment state model.

## 9. Waiting Session Creation

A waiting session may be created by:

- Customer through link
- Customer through entrance device
- Staff through staff tablet
- Kiosk or mini kiosk assisted flow
- Web app flow
- Native app flow, if later supported

Waiting session creation must capture:

- Store ID
- Business date
- Session source
- Party label or guest reference
- Party size, where applicable
- Contact or notification method, where allowed
- Language preference
- Created timestamp
- Device/link reference
- Consent marker, where required
- Staff actor, if assisted

Waiting session creation must not automatically create a confirmed order.

## 10. Waiting-To-Order Boundary

A waiting customer may create a cart or preorder intent before seating.

The system must distinguish:

- Waiting only
- Waiting with cart draft
- Waiting with preorder intent
- Waiting with store review required
- Waiting with POS handoff pending
- Waiting with POS accepted order
- Waiting with payment pending
- Waiting with payment uncertainty
- Waiting with staff action required

A preorder intent must not be treated as final order acceptance until Store Runtime and POS Gateway rules allow it.

## 11. Waiting-To-Table Boundary

A waiting session may become a table session only through controlled transition.

Table transition may require:

- Customer arrival confirmation
- Staff confirmation
- Table availability
- Party size match
- Preorder association check
- Payment/order state review
- Kiosk or app continuation check
- Manager review for exception cases

A table assignment must not silently detach existing preorder, payment, or customer session context.

## 12. Customer-Facing Status Boundary

Customer-facing waiting status must be conservative.

| Runtime State | Customer-Facing Boundary |
|---|---|
| Waiting Created | Waiting request received |
| Waiting Active | You are in the waiting queue |
| Called | Please come to the entrance |
| Arrival Pending | Staff is checking your arrival |
| Table Assigning | Staff is preparing your seat |
| Seated | You have been seated |
| Preorder Draft | Your order is not submitted yet |
| Preorder Submitted | Store is checking your order |
| POS Handoff Pending | Order confirmation is in progress |
| POS Accepted | Order confirmed |
| Payment Uncertain | Staff will confirm payment status |
| Manual Review Required | Staff is checking your request |

The customer must not see final confirmation when the runtime state is still uncertain.

## 13. Entrance Staff Assist Boundary

Staff may assist entrance and waiting flow when:

- Customer cannot use link
- Customer uses foreign language path
- Party size is unclear
- Duplicate waiting session appears
- Customer missed call
- No-show reversal is requested
- Preorder and table context do not match
- Customer claims order/payment exists
- Device or link failed
- Customer requires accessibility support

Staff assist must record:

- Staff actor
- Customer/session reference
- Device/link reference
- Before state
- After state
- Reason
- Whether manager approval was required

Staff assistance must not erase customer-created session history.

## 14. Duplicate Waiting Prevention

The system must prevent or detect duplicate waiting sessions.

Duplicate risk may occur when:

- Customer scans QR multiple times
- Customer uses both web app and entrance device
- Staff creates manual waiting for existing customer
- Party members create separate sessions
- Customer switches browser/device
- Native app and web app both create session
- Kiosk assist creates another session

Duplicate prevention must preserve original session references and support merge/review.

## 15. Session Merge And Recovery

Session merge may be required when duplicate or fragmented waiting/session records exist.

Merge must preserve:

- Original session IDs
- Original creation source
- Customer-visible status history
- Staff correction history
- Order/cart/preorder references
- Payment references, if any
- Notification history
- Evidence link

Recovery may be required when:

- Customer returns after no-show
- Link expired
- Browser session lost
- Staff created manual backup
- Table assignment changed
- Order/payment state became uncertain
- Customer app and store runtime disagree

Recovery must prioritize avoiding duplicate order, duplicate payment, and customer misinformation.

## 16. Link Expiration And Security

Customer links must expire or become limited when risk increases.

Expiration may apply to:

- Unused waiting link
- Called but unconfirmed link
- Abandoned cart link
- Payment attempt link
- Staff assist link
- Table assignment link
- Recovery link

Expired links must not delete evidence.

Expired links may allow safe recovery request, but not unrestricted access to prior session state.

## 17. Privacy And Data Minimization

Entrance and customer link flows must minimize personal data.

The system should avoid collecting unnecessary personal information.

Where contact data is collected, the system must define:

- Purpose
- Retention boundary
- Customer-visible explanation
- Consent requirement, where applicable
- Staff visibility limit
- Support handoff limit
- Deletion or anonymization policy, where applicable

Guest flow must remain possible where business policy allows.

## 18. Order Runtime Connection

Entrance waiting flow connects to order runtime only through Store Runtime authority.

Order runtime connection must check:

- Valid session
- Valid store context
- Valid business date
- Valid channel
- Valid service mode
- Menu availability
- Table or pickup context, where required
- Payment requirement
- POS Gateway readiness
- Staff/manager approval, where required

Entrance link must not bypass order validation.

## 19. Incident And Dispute Linkage

Entrance flow must create or link incidents/disputes when:

- Customer claims they were skipped
- No-show was applied incorrectly
- Waiting and preorder state diverge
- Customer was seated but order context lost
- Link showed incorrect status
- Duplicate session caused operational conflict
- Customer claims payment/order exists but staff cannot find it
- Customer-facing message overpromised status

These cases must link to customer dispute, incident, or staff correction flows as appropriate.

## 20. Evidence Requirements

The system must preserve evidence for:

- Link creation
- Link use
- Device session start
- Waiting session creation
- Waiting state transition
- Customer notification
- Customer arrival confirmation
- Table assignment
- Preorder/cart attachment
- Staff assist
- Staff correction
- Duplicate detection
- Session merge
- Link expiration
- Recovery request
- Customer-facing status display
- Incident or dispute linkage

Evidence must include:

- Store ID
- Business date
- Session ID
- Link/session token reference
- Device/source reference
- Actor ID where applicable
- Timestamp
- Before state
- After state
- Reason where applicable
- Related order/payment/table/incident/dispute reference

## 21. Acceptance Criteria

This policy is accepted when:

- Entrance assist device role is clearly bounded
- Customer link flow does not become authoritative store truth
- Web app and future native app share Store Runtime state
- Guest, customer, party, device, waiting, order, and table identities are separated
- Waiting-to-order and waiting-to-table transitions are controlled
- Customer-facing status avoids overstatement
- Staff assist actions are auditable
- Duplicate waiting prevention and merge rules are defined
- Link expiration and recovery rules are defined
- Privacy and data minimization requirements are documented
- Evidence requirements are traceable

## 22. Out of Scope

This policy does not include:

- Full customer web app UI
- Full native app implementation
- Full membership/loyalty policy
- Marketing notification automation
- Payment settlement implementation
- Full customer support CRM
- Final table layout optimization
- Full queue algorithm optimization

Those must be handled in customer app, loyalty, marketing, finance, support, or store layout lanes.

## 23. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- Staff Tablet and Manager Console WorkPackage
- Customer dispute and support handoff WorkPackage
- Store Runtime incident command WorkPackage
- Waiting operation SOP
- Customer link security policy
- Runtime evidence policy
- Privacy and data retention policy

## 24. Final Rule

The entrance is where the customer runtime thread begins.

Every QR scan, NFC tap, waiting ticket, staff assist action, preorder link, table handoff, and recovery flow must preserve continuity without overpromising order, payment, or service truth.

This policy defines the entrance waiting and customer link boundary before detailed customer web app, native app, and waiting operation policies expand the flow.

===== BEGIN docs/006000_customer_runtime_implementation_readiness/006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md =====
# 006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md

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

`006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

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

===== BEGIN docs/006000_customer_runtime_implementation_readiness/006530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md =====
# 006530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md

## 1. Purpose

This policy defines the table matching, table session, preorder link, service context, and seating control boundary.

The purpose is to ensure that waiting, preorder, table assignment, dine-in service, staff correction, kitchen execution, and payment/order state remain connected after a customer is seated.

A table is not only a physical seat.  
It is a store runtime service context that may connect customer session, party identity, preorder, order, payment, staff action, KDS ticket, kitchen state, and customer dispute evidence.

This policy defines how table matching and table session control must preserve operational truth.

## 2. Scope

This policy covers:

- Table matching boundary
- Table session creation
- Waiting-to-table transition
- Preorder-to-table linkage
- Table reassignment
- Table merge and split
- Staff and manager correction
- Service context control
- Table-linked order and payment state
- Table-linked KDS and kitchen handoff
- Evidence requirements

This policy does not define full floor-plan optimization, reservation engine, physical table design, QR/NFC hardware placement, or final table-order UI implementation.

## 3. Baseline Dependency

This policy depends on:

`006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

`006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md`

06510 defines the entrance customer link boundary.  
06520 defines waiting queue, call, arrival, no-show, and seating control.  
This document defines the table matching and table service context after seating begins.

## 4. Core Principle

A table assignment must not break the customer runtime thread.

The system must preserve continuity across:

1. Waiting session
2. Customer or guest session
3. Party identity
4. Customer link
5. Preorder or cart
6. Table assignment
7. Order state
8. Payment state
9. KDS/kitchen ticket
10. Staff action
11. Daily closeout evidence

A table number alone is not enough.

The system must know which party, session, order, payment, and service context the table belongs to.

## 5. Table Identity Boundary

The system must distinguish between table-related identities.

| Identity Type | Meaning |
|---|---|
| Physical Table | Actual physical table or seat group in the store |
| Table Label | Customer/staff-visible table name or number |
| Table Session | Runtime service context for a party at a table |
| Waiting Session | Queue context before seating |
| Party Identity | Customer group being served |
| Customer Session | Guest or account-linked customer flow |
| Order Session | Cart, preorder, or accepted order linked to service |
| Payment Reference | Payment attempt or approval linked to order |
| KDS Ticket | Kitchen execution ticket linked to table/order |
| Staff Actor | Staff member assigning, correcting, or serving table |

The table session must not replace customer, order, payment, or waiting identity.

## 6. Table State Lifecycle

A physical table may move through operational states.

| State | Meaning |
|---|---|
| Available | Table may be assigned |
| Candidate | Table is suggested or being considered |
| Held | Table is temporarily held for a party |
| Assigned | Table assigned to waiting/customer session |
| Arrival Confirmed | Party is confirmed for seating |
| Occupied | Party is seated and service context is active |
| Ordering | Table has active order flow |
| Kitchen Active | Kitchen ticket exists for table-linked order |
| Ready Or Serving | Food/service handoff is in progress |
| Closing | Table session is being closed |
| Released | Table returned to available pool |
| Blocked | Table cannot be used |
| Manual Review Required | Staff/manager must resolve ambiguous state |

Table state must be separated from order state and payment state.

## 7. Table Session Lifecycle

A table session may move through:

| State | Meaning |
|---|---|
| Created | Table session created for party/service context |
| Linked To Waiting | Waiting session attached |
| Linked To Preorder | Preorder/cart attached |
| Seating Confirmed | Staff confirmed seating |
| Active Service | Customer is being served |
| Order Active | One or more orders exist |
| Payment Pending | Payment remains pending or uncertain |
| Kitchen Pending | Kitchen state remains open |
| Closeout Pending | Table service closeout is pending |
| Closed | Table session closed |
| Recovery Required | Table/session state is ambiguous |
| Dispute Linked | Customer dispute is linked |

A table session may remain open even after the physical table is released if payment, dispute, or evidence review remains pending.

## 8. Table Matching Rules

Table matching must consider:

- Party size
- Table capacity
- Store layout
- Accessibility needs, if policy allows
- Waiting order
- Service mode
- Preorder or order state
- Staff availability
- Kitchen load
- Table cleaning/readiness
- Manager exception
- Customer preference, where allowed

Table matching may be automatic, staff-assisted, or manager-approved depending on risk.

Automatic matching must not override staff-visible operational constraints.

## 9. Waiting-To-Table Transition

A waiting session may transition to table session only when:

- Waiting session is valid
- Arrival is confirmed or staff-approved
- Physical table is available or held
- Party size is compatible or exception-approved
- Preorder/cart state is reviewed
- Payment/order uncertainty does not block seating
- Staff actor or system trigger is recorded
- Table session is created or linked
- Customer-facing status is updated safely

The transition must preserve the waiting session reference.

## 10. Preorder-To-Table Linkage

A preorder or cart may be linked to a table session when:

- Customer/party identity matches or is staff-confirmed
- Waiting session matches or is staff-confirmed
- Table session is active
- Order has not expired
- Menu availability remains valid or is revalidated
- Payment state allows continuation
- Staff or manager review occurs where required

A preorder linked to the wrong table can create serious kitchen, payment, and customer dispute risk.

Preorder-to-table linkage must be auditable.

## 11. Table-Linked Order Control

Orders linked to table sessions must preserve:

- Table session ID
- Order ID
- Customer/guest reference
- Party reference
- Staff actor, if assisted
- POS Gateway state
- Payment state
- KDS ticket state
- Service mode
- Business date
- Correlation ID

Table-linked order state must not be inferred only from table number.

The same table may have multiple orders during a session.  
The same customer may have multiple order sessions.  
The same order may not be duplicated because table state refreshed or changed.

## 12. Table Reassignment

Table reassignment may be required when:

- Wrong table was assigned
- Party moved tables
- Table became unavailable
- Staff seated wrong party
- Preorder was linked to wrong table
- KDS ticket was routed with wrong table context
- Customer requested movement
- Manager approved exception
- Operational incident required reseating

Table reassignment must record:

- Previous table
- New table
- Table session
- Waiting/customer/order references
- Actor
- Reason
- Timestamp
- Affected KDS tickets
- Affected payment/order state
- Customer-facing impact

Table reassignment must not duplicate kitchen tickets or detach payment/order evidence.

## 13. Table Merge And Split

Table merge may be required when:

- Two parties sit together
- Duplicate table sessions were created
- Staff mistakenly assigned two tables to one party
- Multiple customer links belong to one party
- Preorders from party members must be grouped

Table split may be required when:

- One party separates
- Different customers require separate orders
- Separate payment handling is requested
- Service context splits across physical tables
- Dispute or recovery requires isolating an order/session

Merge and split must preserve original IDs and evidence.

Merge/split must not duplicate orders, payments, KDS tickets, or served state.

## 14. Table Service Context

A table service context may include:

- Party
- Table
- Staff owner or section
- Active orders
- Payment status
- Kitchen status
- Customer request
- Staff note
- Manager note
- Incident or dispute
- Closeout status

The service context must be visible to staff and manager roles.

Customer-facing views may show simplified status only.

## 15. Table-Linked KDS Boundary

KDS tickets linked to table service must include table context where relevant.

KDS table context may include:

- Table label
- Table session ID
- Service mode
- Order grouping
- Staff note
- Timing priority
- Remake or delay flag
- Table reassignment marker

If table assignment changes after KDS ticket creation, the system must decide whether to:

- Update the existing ticket context
- Add correction note
- Create staff/kitchen clarification
- Enter manual review
- Void and recreate only under controlled rule

KDS must not silently prepare for the wrong table.

## 16. Table-Linked Payment Boundary

Payment linked to table service may involve:

- Pay before order
- Pay after order
- Split payment
- Group payment
- Staff-assisted payment
- Kiosk payment
- POS terminal payment
- Payment uncertainty
- Refund/cancel after table service

This policy does not define full payment implementation.  
It requires table sessions to preserve payment references and uncertainty status.

A table must not be closed cleanly while payment uncertainty remains unresolved unless explicitly carried forward.

## 17. Staff Correction Boundary

Staff may correct table-related state when necessary.

Correctable table fields may include:

- Table label
- Party size
- Service mode
- Staff owner
- Table note
- Customer/table association before sensitive downstream impact
- Preorder/table association before POS or KDS impact

Manager approval may be required for:

- Reassignment after KDS ticket creation
- Reassignment after payment approval
- Table merge/split involving payment
- Table closeout with unresolved payment or kitchen state
- No-show reversal after seating conflict
- Customer dispute-linked table correction

All corrections must preserve before/after state.

## 18. Customer-Facing Table Status

Customer-facing table status must be conservative.

| Internal State | Customer-Facing Boundary |
|---|---|
| Candidate | Staff is preparing your seat |
| Held | Your seat is being prepared |
| Assigned | Staff will guide you to your seat |
| Occupied | You are seated |
| Ordering | Your order is being checked |
| Kitchen Active | Preparing your order |
| Ready Or Serving | Your order is ready or being served |
| Closing | Staff is checking your table |
| Released | Service completed, where appropriate |
| Recovery Required | Staff is checking your table/order |
| Dispute Linked | Staff is reviewing your request |

Customer-facing messages must not expose staff notes, internal table conflicts, or uncertain payment conclusions.

## 19. Incident And Dispute Linkage

Table flow must create or link incident/dispute records when:

- Wrong party seated
- Wrong table assigned
- Preorder attached to wrong table
- KDS ticket routed to wrong table
- Customer claims they were skipped or moved unfairly
- Payment/order state is attached to wrong table
- Table split/merge creates confusion
- Table was released while order/payment/kitchen state remained open
- Customer-facing status was incorrect

Table incidents must link to runtime evidence, staff correction, manager approval, and customer dispute where needed.

## 20. Daily Closeout Impact

Daily closeout must review table exceptions.

Closeout should include:

- Open table sessions
- Table sessions closed with exceptions
- Table reassignment cases
- Table merge/split cases
- Table-linked payment uncertainty
- Table-linked KDS exceptions
- Table-linked customer disputes
- Table-linked staff corrections
- Table-linked manager overrides
- Table sessions carried forward

A physical table may be available for next customer while a prior table session remains open for evidence, payment, or dispute review.

## 21. Evidence Requirements

The system must preserve evidence for:

- Table candidate selection
- Table hold
- Table assignment
- Table session creation
- Waiting-to-table transition
- Preorder-to-table linkage
- Table reassignment
- Table merge
- Table split
- Staff correction
- Manager approval
- KDS table context update
- Table-linked payment uncertainty
- Table closeout
- Table release
- Incident/dispute linkage
- Customer-facing status display
- Daily closeout table summary

Evidence must include:

- Store ID
- Business date
- Physical table ID
- Table session ID
- Waiting session ID, where applicable
- Customer or guest reference, where available
- Order ID, where applicable
- Payment reference, where applicable
- KDS ticket reference, where applicable
- Actor ID
- Timestamp
- Before state
- After state
- Reason
- Related incident/dispute/closeout reference

## 22. Acceptance Criteria

This policy is accepted when:

- Table identity is separated from customer, waiting, order, payment, and KDS identity
- Table session lifecycle is documented
- Table matching rules are explicit
- Waiting-to-table transition preserves session continuity
- Preorder-to-table linkage is controlled
- Table reassignment is auditable
- Table merge and split preserve original references
- Table-linked KDS and payment boundaries are documented
- Staff correction and manager approval rules are defined
- Customer-facing table status is conservative
- Daily closeout reviews table exceptions
- Evidence requirements are traceable

## 23. Out of Scope

This policy does not include:

- Full floor-plan optimization
- Full reservation engine
- Physical furniture planning
- QR/NFC hardware procurement
- Final table-order UI
- Full split-payment implementation
- Full staff section assignment algorithm
- Full customer compensation policy

Those must be handled in layout, reservation, hardware, payment, staff operation, support, or UI lanes.

## 24. Related Documents

Related document families include:

- Entrance waiting assist and customer link policy
- Waiting queue, call, arrival, no-show, seating policy
- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- KDS kitchen execution WorkPackage
- Staff Tablet and Manager Console WorkPackage
- Customer dispute and support handoff WorkPackage
- Daily closeout WorkPackage
- Runtime evidence policy
- Table assignment SOP
- Manual fallback SOP

## 25. Final Rule

A table is not just a number on the floor.

It is a live service context that must preserve who is seated, what they ordered, what was paid, what the kitchen received, what staff changed, and what evidence remains after service.

This policy defines table matching and table session control before detailed table-order, split-payment, and service handoff policies expand the flow.

===== BEGIN docs/006000_customer_runtime_implementation_readiness/006410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md =====
# 006410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md

## 1. Purpose

This WorkPackage defines the customer session and order-state control boundary within the Store Runtime lane.

The purpose is to prevent waiting, preorder, table matching, kiosk order, staff-assisted order, and POS-confirmed order states from becoming disconnected or contradictory.

The store must be able to track a customer from the first waiting or preorder intent through table matching, order confirmation, POS handoff, kitchen execution, and final service state.

This WorkPackage establishes the state-control layer that connects customer-facing flows to store-facing operational truth.

## 2. Scope

This WorkPackage covers:

- Customer session lifecycle
- Waiting session state
- Preorder and cart state
- Table matching state
- Entry and seating transition
- Order submission eligibility
- Order state authority
- Staff correction boundary
- Customer-visible status boundary
- Session expiration, abandonment, and recovery
- Evidence requirements for customer/order state transition

This WorkPackage does not define full POS Gateway internals, payment settlement, KDS execution, or loyalty benefit logic. Those are governed by their own WorkPackages and policy lanes.

## 3. Baseline Dependency

This WorkPackage depends on:

`014161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

The Store Runtime Control Tower defines the overall command boundary. This document defines the customer-session and order-state segment inside that boundary.

## 4. Core Principle

A customer session is not just a login, waiting ticket, or cart.

It is the operational thread that connects:

1. Who the customer or party is
2. Why they are interacting with the store
3. Whether they are waiting, ordering, seated, picking up, or leaving
4. Whether the order has been accepted by the store
5. Whether payment is required, pending, approved, failed, or uncertain
6. Whether the kitchen must act
7. Whether staff must intervene
8. Whether the customer can safely be shown a confirmed state

No customer-facing state may advance beyond the operational truth layer.

## 5. Customer Session Families

Customer sessions must be grouped into clear families.

| Session Family | Meaning |
|---|---|
| Waiting Session | Customer or party is waiting for entry, seating, or service opportunity |
| Preorder Session | Customer has created an order intent before final store acceptance |
| Table Session | Customer or party has been matched to a table or in-store service context |
| Kiosk Session | Customer is using a kiosk or mini kiosk to create or complete order intent |
| Staff-Assisted Session | Staff is helping create, correct, or complete the customer flow |
| Recovery Session | Customer/order/payment state requires review, correction, or continuation |

A single customer may move across multiple session families. The system must preserve continuity.

## 6. Session Identity Boundary

The Store Runtime must distinguish between the following identity concepts:

| Identity Type | Description |
|---|---|
| Customer Account | Known customer identity, if logged in or matched |
| Guest Session | Temporary customer identity without full account |
| Party Identity | Group-level waiting or seating identity |
| Device Session | Browser, kiosk, tablet, or app session |
| Order Identity | Specific order intent or accepted order |
| Payment Identity | Specific payment attempt or approval reference |
| Table Identity | Physical or operational table assignment |
| Staff Actor Identity | Staff member assisting or modifying state |

These identities must not be collapsed into one field.

A customer may have multiple orders.  
A party may include multiple customers.  
A device may be used by multiple parties.  
A table may have more than one order during the same business period.  
A staff actor may operate on behalf of a customer but must not become the customer.

## 7. Waiting Session Lifecycle

A waiting session may move through the following states:

| State | Meaning |
|---|---|
| Draft | Waiting intent created but not yet submitted |
| Waiting | Customer/party is actively waiting |
| Called | Store has called or notified customer/party |
| Arrival Pending | Customer/party must confirm or approach |
| Seated | Customer/party has been assigned to table or service context |
| No-Show | Customer/party failed to respond within allowed window |
| Cancelled | Waiting session was cancelled |
| Expired | Session became invalid due to timeout |
| Merged | Session was merged with another party/session |
| Manual Review | Staff must resolve ambiguous state |

Waiting state must not automatically imply order acceptance.

## 8. Preorder Session Lifecycle

A preorder session may move through the following states:

| State | Meaning |
|---|---|
| Cart Draft | Customer is building an order |
| Preorder Draft | Order intent exists but is not ready for submission |
| Preorder Submitted | Customer submitted order intent |
| Store Review Required | Store must check availability, timing, or context |
| Eligible For POS Handoff | Runtime has validated minimum conditions |
| POS Handoff Pending | Order is being sent to POS Gateway |
| POS Accepted | POS/POS Gateway accepted the order |
| POS Rejected | POS/POS Gateway rejected the order |
| Customer Action Required | Customer must revise, confirm, or pay |
| Staff Action Required | Staff must correct or assist |
| Cancelled | Preorder was cancelled before final acceptance |
| Expired | Preorder became invalid due to timeout |
| Converted To Order | Preorder became an accepted store order |

Preorder state must remain separate from final order state until Store Runtime receives authoritative acceptance.

## 9. Table Matching Lifecycle

Table matching may move through the following states:

| State | Meaning |
|---|---|
| Unassigned | No table/service context assigned |
| Candidate Table Suggested | Runtime or staff suggests table |
| Table Reserved Pending Arrival | Table is temporarily held |
| Customer Arrived | Customer/party is physically present or confirmed |
| Table Assigned | Staff or runtime assigns table |
| Table Occupied | Service has begun |
| Table Released | Service context has ended |
| Reassignment Required | Table assignment must change |
| Manual Review | Staff must resolve conflict |

Table matching must not automatically finalize payment or kitchen execution.

## 10. Order State Control

Order state must be controlled separately from waiting, preorder, and table state.

| Order State | Meaning |
|---|---|
| Draft | Order is being composed |
| Submitted | Customer or staff submitted intent |
| Validation Pending | Runtime checks eligibility |
| POS Handoff Pending | Sent or queued for POS Gateway |
| POS Accepted | Authoritative POS acceptance received |
| POS Rejected | POS or provider rejected order |
| Kitchen Pending | Waiting for KDS/kitchen ticket creation |
| Kitchen Accepted | Kitchen accepted ticket |
| Preparing | Kitchen preparation started |
| Ready | Food/order is ready |
| Served or Picked Up | Customer received order |
| Cancel Requested | Cancellation intent exists |
| Cancel Confirmed | Cancellation is completed |
| Failed | Order failed and cannot proceed automatically |
| Manual Review Required | Staff/manager must resolve |

A customer-facing “confirmed” label may only be shown after the appropriate authoritative state is reached.

## 11. State Authority Matrix

The system must define which actor or system may advance each state.

| Transition | Default Authority |
|---|---|
| Draft to Waiting | Customer or staff |
| Waiting to Called | Store runtime or staff |
| Called to Seated | Staff or manager |
| Cart Draft to Preorder Submitted | Customer or staff |
| Preorder Submitted to Eligible For POS Handoff | Store Runtime |
| Eligible For POS Handoff to POS Handoff Pending | Store Runtime |
| POS Handoff Pending to POS Accepted | POS Gateway |
| POS Accepted to Kitchen Pending | Store Runtime |
| Kitchen Pending to Kitchen Accepted | KDS or kitchen staff |
| Preparing to Ready | Kitchen staff or KDS |
| Ready to Served | Staff |
| Any sensitive exception to Manual Review | Store Runtime, staff, or manager |
| Manual Review to Resolved State | Assigned owner, often manager |

Sensitive transitions must create audit events.

## 12. Customer-Visible Status Boundary

Customer-visible status must be simpler than internal state but must not be misleading.

| Internal State | Possible Customer Message |
|---|---|
| Waiting | Waiting in queue |
| Called | Please come to the entrance |
| Arrival Pending | Staff is checking your arrival |
| Preorder Submitted | Order request received |
| Store Review Required | Store is checking your order |
| POS Handoff Pending | Order is being confirmed |
| POS Accepted | Order confirmed |
| Kitchen Preparing | Preparing your order |
| Ready | Ready for pickup or service |
| Payment Uncertain | Staff will confirm payment status |
| Manual Review Required | Staff is checking your request |

The customer must not see “confirmed” when payment or POS state is uncertain.

## 13. Staff Correction Boundary

Staff may correct customer/session/order context when necessary.

Allowed correction types include:

- Customer name or party label correction
- Party size correction
- Waiting order correction
- Table assignment correction
- Cart/order item correction before final acceptance
- Pickup/dine-in correction
- Customer contact correction
- Session merge or split
- No-show reversal with manager approval
- Manual recovery of abandoned session

Corrections must record:

- Actor
- Timestamp
- Before state
- After state
- Reason
- Customer/order/session reference
- Whether manager approval was required

## 14. Session Merge And Split Rules

Session merge and split are high-risk operations.

### 14.1 Merge

A merge may be required when:

- Duplicate waiting sessions were created
- A customer used both app and kiosk
- Staff created a manual session for an existing customer
- A party was split across devices
- A guest session is later matched to a known account

Merge must preserve original session IDs as evidence.

### 14.2 Split

A split may be required when:

- One party separates into two tables
- One cart contains orders for different service contexts
- One customer wants separate payment/order handling
- Staff must isolate a problematic order from the main party

Split must not duplicate payment or kitchen tickets.

## 15. Session Expiration And Abandonment

The system must define expiration behavior for:

- Waiting sessions
- Called but unconfirmed sessions
- Cart drafts
- Preorder drafts
- Payment attempts
- Kiosk sessions
- Table hold sessions
- Recovery sessions

Expiration must not delete evidence.

Expired sessions must retain enough information to support:

- Customer dispute review
- Staff recovery
- Payment reconciliation
- Duplicate prevention
- Audit review

## 16. Recovery Rules

A customer session must enter recovery when:

- Customer returns after no-show
- App and kiosk state conflict
- Table assignment changed after preorder
- Payment status is uncertain
- POS accepted order but customer view failed
- Customer saw failure but POS accepted the order
- KDS ticket was not created after POS acceptance
- Staff manually entered an order for the same customer/session
- Session expired while payment/order processing was incomplete

Recovery must prioritize preventing duplicate charge, duplicate cooking, and customer-facing misinformation.

## 17. Evidence Requirements

The system must preserve evidence for:

- Session creation
- Customer identity or guest identity assignment
- Waiting submission
- Call/arrival/seating transition
- Cart creation and update
- Preorder submission
- Store review
- POS handoff eligibility decision
- POS handoff result
- Table assignment
- Staff correction
- Session merge/split
- Expiration
- Recovery
- Customer notification
- Final order conversion

Evidence must be linked through correlation IDs across session, order, payment, table, staff actor, and device.

## 18. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- Waiting lifecycle is defined
- Preorder lifecycle is defined
- Table matching lifecycle is defined
- Order state lifecycle is defined
- State authority matrix is approved
- Customer-visible status rules are defined
- Staff correction rules are defined
- Merge/split rules are defined
- Expiration rules are defined
- Recovery rules are defined
- Evidence fields are defined

## 19. Acceptance Criteria

This WorkPackage is accepted when:

- Customer session families are documented
- Identity boundaries are separated
- Waiting, preorder, table, and order states are documented
- Authoritative state transitions are defined
- Customer-visible status does not overstate internal certainty
- Staff correction and manager approval rules are defined
- Recovery and expiration rules are defined
- Evidence requirements are traceable
- Open risks are routed to backlog, waiver, or blocker register

## 20. Out of Scope

This WorkPackage does not include:

- Full customer app UI
- Full kiosk UI
- Full staff tablet UI
- Full POS Gateway implementation
- Payment settlement implementation
- Loyalty/membership benefit calculation
- Marketing notification rules
- Full table turnover analytics

Those must be handled in their own lanes.

## 21. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- POS Gateway readiness lane
- Entrance waiting policy
- Preorder and cart policy
- Table matching policy
- Kiosk runtime policy
- Staff tablet operation policy
- KDS handoff policy
- Manual fallback SOP
- Payment uncertainty policy
- Runtime evidence policy

## 22. Final Rule

A customer session is the operational thread of the store.

It must survive device changes, waiting changes, table changes, staff correction, POS handoff, kitchen handoff, and payment uncertainty without losing truth.

This WorkPackage defines that thread before deeper kiosk, KDS, and staff operation flows are expanded.

