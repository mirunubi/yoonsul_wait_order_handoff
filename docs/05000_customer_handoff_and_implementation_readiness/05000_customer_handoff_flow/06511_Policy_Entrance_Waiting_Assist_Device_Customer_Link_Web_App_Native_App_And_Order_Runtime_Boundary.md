# 06511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary

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

`14161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`06410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

`14162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control.md`

`14163_WorkPackage_Store_Runtime_Staff_Tablet_Manager_Console_Override_Manual_Control_And_Evidence_Boundary.md`

`05001_WorkPackage_Store_Runtime_Pilot_Readiness_Store_Rollout_Closeout_Expansion_Gate_And_Operational_Acceptance.md`

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