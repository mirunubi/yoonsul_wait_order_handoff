# 006540_Policy_Entrance_Customer_Notification_Status_Display_Multilingual_Guidance

## 1. Purpose

This policy defines the customer notification, call message, status display, multilingual guidance, and evidence control boundary for entrance, waiting, table, preorder, kiosk, and store runtime flows.

The purpose is to ensure that customer-facing messages do not overpromise operational truth or create disputes by showing unclear, premature, mistranslated, or inconsistent status.

Customer notification is not only a convenience feature.  
It is a runtime promise that may affect waiting fairness, arrival timing, order confirmation, payment trust, table seating, kitchen expectation, staff workload, and customer dispute evidence.

This policy defines how customer-facing messages must be generated, scoped, translated, displayed, logged, and corrected.

## 2. Scope

This policy covers:

- Customer notification boundary
- Waiting call message
- Arrival and seating message
- Preorder and order status message
- Payment uncertainty message
- Kiosk and web app status display
- Multilingual guidance control
- Staff-assisted message boundary
- Notification failure and recovery
- Customer-facing incident wording
- Evidence requirements

This policy does not define full marketing notification automation, promotional campaigns, native push infrastructure, loyalty messaging, or final copywriting system.

## 3. Baseline Dependency

This policy depends on:

`006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

`006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md`

`006530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md`

06510 defines the entrance customer link boundary.  
06520 defines waiting queue, call, arrival, no-show, seating, and recovery.  
06530 defines table matching and table session control.  
This document defines customer-facing notification and status display across those flows.

## 4. Core Principle

Customer-facing messages must be conservative, state-aware, and evidence-backed.

The system must distinguish:

1. Message was created
2. Message was sent
3. Message was displayed
4. Message was delivered, where measurable
5. Customer opened or acknowledged it, where measurable
6. Customer action was requested
7. Customer action was received
8. Message expired
9. Message was corrected or superseded
10. Message created dispute, recovery, or support context

A message must not be treated as successful customer communication merely because the system attempted to send it.

## 5. Message Families

Customer messages must be grouped into families.

| Message Family | Meaning |
|---|---|
| Waiting Message | Queue creation, waiting status, queue update |
| Call Message | Customer is called to entrance or service point |
| Arrival Message | Customer must confirm or approach |
| Seating Message | Table/service context is being assigned |
| Preorder Message | Cart, preorder, review, or order-intent status |
| Order Message | POS accepted, preparing, ready, served/pickup status |
| Payment Message | Payment pending, approved, failed, uncertain, refund/cancel status |
| Kiosk Recovery Message | Device/session/order continuation guidance |
| Availability Message | Sold-out, delayed, unavailable, substitution guidance |
| Incident Message | Conservative customer-facing incident notice |
| Support Message | Dispute received, checking, resolved, or follow-up status |
| Expiration Message | Link/session/action expired or requires staff help |

Each message family must map to allowed runtime states.

## 6. Notification Channels

Customer messages may be delivered or displayed through:

- Customer web app
- Entrance waiting assist device
- QR/NFC customer link page
- Main kiosk
- Mini kiosk
- Staff tablet assisted view
- Table QR/NFC page
- SMS or message channel, if approved
- Future native app push
- Staff verbal communication supported by staff-facing script

Channel availability must be explicit.

A message shown on one channel must not create a contradictory state on another channel.

## 7. Message Authority Boundary

Messages must be generated from Store Runtime state.

The following systems may request or display messages:

- Waiting runtime
- Table runtime
- Customer web app
- Kiosk/Mini Kiosk runtime
- Staff tablet
- Manager console
- POS Gateway state adapter
- KDS/kitchen runtime
- Incident/dispute runtime
- Support handoff flow

However, customer-facing confirmation may only be shown when the authoritative Store Runtime state allows it.

## 8. Waiting And Call Message Rules

Waiting and call messages must distinguish:

| Runtime State | Customer-Facing Message Boundary |
|---|---|
| Waiting Created | Your waiting request has been received |
| Waiting Active | You are in the waiting queue |
| Queue Updated | Your waiting status has been updated |
| Call Pending | Please stay ready |
| Called | Please come to the entrance |
| Arrival Pending | Staff is checking your arrival |
| No-Show Pending | Staff is checking your waiting status |
| No-Show | Your waiting session has ended or was missed |
| Recovery Required | Staff will help check your waiting request |

A call message must not automatically prove customer receipt or arrival.

## 9. Arrival And Seating Message Rules

Arrival and seating messages must distinguish:

| Runtime State | Customer-Facing Message Boundary |
|---|---|
| Arrival Requested | Please confirm or approach the entrance |
| Arrival Confirmed | Your arrival has been confirmed |
| Table Preparing | Staff is preparing your seat |
| Table Assigned | Staff will guide you to your seat |
| Seated | You have been seated |
| Table Changed | Staff is checking or updating your table |
| Table Recovery Required | Staff is checking your table information |

Messages must not expose internal table conflicts, staff notes, or other customer information.

## 10. Preorder And Order Message Rules

Preorder and order messages must distinguish:

| Runtime State | Customer-Facing Message Boundary |
|---|---|
| Cart Draft | Your order is not submitted yet |
| Preorder Submitted | Your order request has been received |
| Store Review Required | Store is checking your order |
| POS Handoff Pending | Order confirmation is in progress |
| POS Accepted | Your order is confirmed |
| POS Rejected | Your order could not be confirmed |
| Kitchen Pending | Your order is being sent to the kitchen |
| Preparing | Your order is being prepared |
| Ready | Your order is ready |
| Served Or Picked Up | Your order has been completed |
| Manual Review Required | Staff is checking your order |

The word “confirmed” may only be used when the runtime state supports actual order confirmation.

## 11. Payment Message Rules

Payment messages must be especially conservative.

| Runtime State | Customer-Facing Message Boundary |
|---|---|
| Payment Not Started | Payment has not started |
| Payment Pending | Payment is being processed |
| Payment Approved | Payment is complete |
| Payment Failed | Payment could not be completed |
| Payment Uncertain | Staff will confirm payment status |
| Cancel Pending | Cancellation is being checked |
| Cancel Confirmed | Cancellation has been completed |
| Refund Pending | Refund status is being checked |
| Refund Approved | Refund has been approved |
| Settlement Review Required | Staff or support is checking payment status |

Payment uncertainty must never be displayed as payment success or failure without evidence.

## 12. Availability And Sold-Out Message Rules

Availability messages must distinguish:

| Runtime State | Customer-Facing Message Boundary |
|---|---|
| Available | Show normally |
| Limited | Limited quantity or limited availability |
| Delayed | Preparation may take longer |
| Staff Confirm Required | Staff assistance is required |
| Manager Confirm Required | Staff will assist |
| Sold Out | Sold out or currently unavailable |
| Temporarily Paused | Temporarily unavailable |
| Prep Pending | Available later only if reliable |
| Manual Review Required | Staff is checking availability |

Availability messages must not promise future availability unless the runtime can support that promise.

## 13. Incident And Recovery Message Rules

Incident and recovery messages must avoid internal blame.

Allowed message boundaries include:

- Staff is checking your order status
- Staff will help continue your order
- Payment status is being confirmed
- Preparation is taking longer than expected
- Staff is checking your request
- Your request has been received
- Support will follow up if needed

Customer-facing messages must not expose:

- Provider names unless policy allows
- Technical stack details
- Internal incident severity
- Staff blame
- Other customer data
- Audit-only notes
- Unverified payment conclusions

## 14. Multilingual Guidance Boundary

Multilingual guidance must preserve operational meaning.

The system must define:

- Supported languages
- Source language authority
- Translation review owner
- Fallback language
- Staff-call phrase set
- Payment phrase set
- Waiting phrase set
- Order confirmation phrase set
- Error/recovery phrase set
- Allergen or warning phrase set, where applicable
- Customer support phrase set

A translated message must not be more certain than the source runtime state.

For example, if the source state means “being checked,” translation must not imply “confirmed.”

## 15. Message Template Control

Customer-facing message templates must be controlled.

A template should define:

- Message family
- Runtime state mapping
- Channel eligibility
- Language versions
- Required placeholders
- Forbidden terms
- Expiration behavior
- Staff escalation condition
- Evidence capture requirement
- Owner
- Review status

Free-text customer messages should be limited where consistency and legal/financial risk matter.

## 16. Staff-Facing Script Boundary

Staff may need customer-facing scripts for:

- Waiting call
- No-show explanation
- Kiosk failure
- Payment uncertainty
- Kitchen delay
- Item unavailable
- Refund/cancel pending
- Duplicate charge claim
- Table reassignment
- Incident recovery
- Support handoff

Staff-facing scripts must align with runtime state and must not encourage staff to promise outcomes they cannot verify.

## 17. Notification Failure Handling

Notification failure may occur when:

- SMS/message delivery fails
- Customer web app session closes
- QR/NFC link expires
- Native push is unavailable
- Kiosk display freezes
- Customer does not see call message
- Staff verbal call is not heard
- Translation fails or missing language fallback occurs

Notification failure must not automatically become no-show or customer fault.

Failure must be recorded and may require staff review, recovery, or dispute handling.

## 18. Message Expiration And Supersession

Messages may expire or be superseded.

Examples:

- Waiting call expires
- Arrival confirmation window expires
- Payment pending message is superseded by payment uncertainty
- POS handoff pending is superseded by POS accepted or failed
- Sold-out message is superseded by restored availability
- Table assignment changes
- Support case status changes

Expired or superseded messages must remain as evidence.

The customer-facing interface should show the current safe state, not stale confirmation.

## 19. Customer Action Link Boundary

Some messages may ask the customer to act.

Customer actions may include:

- Confirm arrival
- Open waiting status
- Continue order
- Review cart
- Request staff help
- Confirm substitution
- Retry payment
- Contact support
- Acknowledge notice
- Recover expired session

Action links must be scoped, expiring, and limited to allowed actions.

A customer action link must not grant staff or manager authority.

## 20. Dispute And Support Linkage

Customer notification records must link to dispute/support when:

- Customer claims they were not called
- Customer claims message said confirmed but order was not accepted
- Customer claims payment succeeded but app showed failure
- Customer claims refund was promised
- Customer claims table assignment changed unfairly
- Customer relied on incorrect availability status
- Translation caused misunderstanding
- Notification failure affected service

Support must be able to review what the customer was shown or sent.

## 21. Daily Closeout Impact

Daily closeout must review notification-related exceptions when material.

Closeout should include:

- Failed waiting calls
- No-show cases with unclear notification
- Payment uncertainty messages
- Kiosk recovery messages
- Customer-facing incident messages
- Availability conflict messages
- Dispute-linked messages
- Missing message evidence
- Staff-scripted customer explanation where recorded

A customer-facing message can become evidence in later dispute, finance, or support review.

## 22. Evidence Requirements

The system must preserve evidence for:

- Message creation
- Message template/version
- Runtime state at message creation
- Channel
- Language
- Recipient/session reference
- Send attempt
- Delivery result, where available
- Display result, where available
- Customer open/acknowledgement, where available
- Customer action result
- Expiration
- Supersession
- Staff verbal/scripted communication note, where recorded
- Dispute/support linkage

Evidence must include:

- Store ID
- Business date
- Customer or guest reference, where available
- Waiting/session/order/payment/table reference, where applicable
- Message ID
- Template ID
- Channel
- Language
- Timestamp
- Runtime state source
- Related incident/dispute/support reference where applicable

## 23. Acceptance Criteria

This policy is accepted when:

- Customer messages are mapped to runtime states
- Confirmation wording is restricted to authoritative states
- Payment uncertainty wording is conservative
- Waiting call does not automatically prove receipt
- Multilingual guidance preserves source meaning
- Message templates are controlled
- Staff-facing scripts do not overpromise
- Notification failure and expiration are handled
- Customer action links are scoped and expiring
- Dispute/support can review customer-facing messages
- Daily closeout reviews material notification exceptions
- Evidence requirements are traceable

## 24. Out of Scope

This policy does not include:

- Full marketing campaign messaging
- Loyalty promotion notification
- Native push infrastructure implementation
- SMS vendor selection
- Full translation management platform
- Final legal copy approval
- Full customer support CRM implementation
- Full UX writing style guide

Those must be handled in marketing, loyalty, native app, vendor, localization, legal, support, or UX lanes.

## 25. Related Documents

Related document families include:

- Entrance waiting assist and customer link policy
- Waiting queue, call, arrival, no-show, seating policy
- Table matching and table session policy
- Store Runtime Customer Session WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- Staff Tablet and Manager Console WorkPackage
- Customer dispute and support handoff WorkPackage
- Store Runtime incident command WorkPackage
- Runtime evidence policy
- Customer notification SOP
- Localization and translation policy

## 26. Final Rule

A customer-facing message is a promise.

The system must know why it was shown, what state it represented, whether it was safe, which language it used, whether it failed, and how it affected later waiting, order, payment, table, dispute, support, and closeout flows.

This policy defines customer notification and multilingual guidance control before detailed app, kiosk, support, and localization policies expand the customer communication layer.