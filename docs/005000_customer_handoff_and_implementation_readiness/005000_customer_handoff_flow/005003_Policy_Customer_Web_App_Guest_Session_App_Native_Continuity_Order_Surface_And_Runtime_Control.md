# 005003_Policy_Customer_Web_App_Guest_Session_App_Native_Continuity_Order_Surface_And_Runtime_Control

## 1. Purpose

This policy defines the customer web app, guest session, future native app continuity, order surface, and runtime control boundary.

The purpose is to ensure that the customer-facing web app does not become an isolated ordering frontend disconnected from Store Runtime, waiting state, table state, kiosk flow, POS Gateway, KDS, payment state, customer notification, support, and evidence.

The customer web app is the lightweight public runtime surface for waiting, preorder, order continuation, table context, status display, and support recovery.

This policy defines how the web app must participate in Store Runtime without independently deciding operational, payment, kitchen, or support truth.

## 2. Scope

This policy covers:

- Customer web app runtime role
- Guest session handling
- Known customer account continuity
- Future native app continuity boundary
- Web app order surface
- Waiting and table context display
- Cart and preorder continuation
- Payment state display boundary
- Customer notification and status display
- Link and token validation dependency
- Web app recovery and fallback
- Evidence requirements

This policy does not define final UI design, full native app implementation, membership/loyalty policy, payment provider integration, or complete customer account security architecture.

## 3. Baseline Dependency

This policy depends on:

`006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

`006520_Policy_Entrance_Waiting_Queue_Call_Arrival_No_Show_Seating_And_Recovery_Control.md`

`006530_Policy_Entrance_Table_Matching_Table_Session_Preorder_Link_Service_Context_And_Seating_Control.md`

`006540_Policy_Entrance_Customer_Notification_Status_Display_Multilingual_Guidance.md`

`005002_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary.md`

06550 defines customer link and scoped token security.  
This document defines how the customer web app consumes those scoped links and participates in runtime flow.

## 4. Core Principle

The customer web app is a runtime participant, not the source of truth.

The web app may:

1. Display safe customer-facing state
2. Collect customer intent
3. Continue waiting, cart, preorder, table, or support flow
4. Request order submission
5. Request payment or payment status review
6. Request staff help
7. Receive notification and status updates
8. Support recovery after interruption

However, the web app must not independently decide:

- Final waiting priority
- Final table assignment
- Final order acceptance
- Final payment result
- Final refund or cancel result
- Final kitchen state
- Final dispute resolution
- Staff or manager authority

Authoritative state must come from Store Runtime.

## 5. Web App Runtime Roles

The customer web app may support multiple roles.

| Role | Meaning |
|---|---|
| Entrance Flow Surface | Starts or continues waiting from QR/NFC/link |
| Waiting Status Surface | Shows queue, call, arrival, no-show, or recovery state |
| Menu Browse Surface | Shows menu and availability-safe display |
| Cart Surface | Allows customer to build or edit draft cart |
| Preorder Surface | Allows customer to submit order intent under policy |
| Table Context Surface | Shows table-linked customer/service context |
| Order Status Surface | Shows safe order/kitchen status |
| Payment Status Surface | Shows conservative payment state or routes to payment flow |
| Support Surface | Allows dispute/support status continuation |
| Recovery Surface | Helps customer recover interrupted session |

The active role must be derived from validated link/session/runtime context.

## 6. Guest Session Boundary

Guest session flow must remain possible where business policy allows.

A guest session may support:

- Waiting
- Menu browsing
- Cart draft
- Preorder intent
- Table context
- Kiosk continuation
- Limited order status
- Staff help request
- Support request

Guest session must not expose:

- Other customer data
- Full payment references
- Staff-only notes
- Manager decisions
- Internal incident details
- Persistent account-level data

A guest session must be scoped, expiring, and recoverable through controlled rules.

## 7. Known Customer Account Boundary

A known customer account may support richer continuity.

Known customer flow may later include:

- Login
- Saved profile
- Membership
- Loyalty
- Order history
- Saved preferences
- Native app continuity
- Support history
- Repeat order

However, known customer identity must not override Store Runtime truth.

A logged-in customer may still have:

- Guest-like store session
- Party-level waiting session
- Table-specific service context
- Order-specific payment state
- Support case-specific access

Customer account identity must be linked, not collapsed into every operational identity.

## 8. Web App And Native App Continuity

The web app is the primary lightweight public flow in early phases.  
The native app may later extend the same runtime.

Native app continuity must follow these rules:

- Native app must consume the same Store Runtime state model
- Native app must not create separate waiting truth
- Native app must not create separate order truth
- Native app must not create separate payment truth
- Native app must not create separate support truth
- Native app deep links must follow scoped token policy
- Native app push messages must follow notification policy
- Native app customer account must not bypass store-session validation

The future native app is an additional surface, not a replacement truth layer.

## 9. Web App Session Model

A web app session must distinguish:

- Browser session
- Guest session
- Customer account session
- Waiting session
- Table session
- Cart session
- Order session
- Payment attempt
- Support case
- Recovery session

These must not be stored as a single undifferentiated session object.

The web app must be able to lose browser state without destroying Store Runtime evidence.

## 10. Menu And Availability Display

The web app may display menu items only according to Store Runtime availability rules.

Menu display must consider:

- Store enablement
- Business date
- Time window
- Channel availability
- Service mode
- Ingredient/prep state
- Kitchen capacity
- Sold-out state
- Staff-confirm required state
- Manager-confirm required state
- Language/translation availability
- Customer-facing display boundary

The web app must not allow order submission for clearly unavailable items.

## 11. Cart Draft Boundary

A web app cart draft is not an accepted order.

A cart draft may include:

- Menu items
- Options
- Quantity
- Customer memo, where allowed
- Service mode
- Waiting or table context
- Availability snapshot
- Price estimate
- Language context
- Device/browser context

A cart draft must be revalidated before preorder submission or POS Gateway handoff.

Cart persistence must be scoped and expiring.

## 12. Preorder Submission Boundary

Preorder submission from the web app must pass through Store Runtime.

Preorder submission requires validation of:

- Session validity
- Store context
- Business date
- Menu availability
- Service mode
- Waiting or table context, where applicable
- Customer action authority
- Payment requirement
- POS Gateway readiness
- Staff/manager review requirement
- Duplicate submission prevention

The web app must show “request received” or “checking” until authoritative acceptance is available.

## 13. Order Status Display Boundary

The web app may show order status only within customer-safe boundaries.

| Runtime State | Web App Display Boundary |
|---|---|
| Cart Draft | Your order is not submitted yet |
| Preorder Submitted | Your order request has been received |
| Store Review Required | Store is checking your order |
| POS Handoff Pending | Order confirmation is in progress |
| POS Accepted | Your order is confirmed |
| POS Rejected | Your order could not be confirmed |
| Kitchen Pending | Your order is being prepared soon |
| Preparing | Your order is being prepared |
| Ready | Your order is ready |
| Served Or Picked Up | Your order has been completed |
| Manual Review Required | Staff is checking your order |

The web app must not display final confirmation based only on local UI success.

## 14. Payment Status Display Boundary

Payment status display must follow conservative rules.

| Runtime State | Web App Display Boundary |
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
| Manual Review Required | Staff or support is checking payment status |

The web app must not infer payment success from browser redirect, button tap, or network response alone.

## 15. Waiting And Table Display Boundary

The web app may display waiting and table state.

Waiting display must follow waiting policy.  
Table display must follow table session policy.

The web app must not show:

- Other customers’ private queue data
- Internal table conflicts
- Staff notes
- Manager override notes
- Full table optimization logic
- Payment or support details unrelated to the current scoped session

If waiting or table state is ambiguous, the web app must route to staff review or recovery.

## 16. Customer Action Boundary

The web app may allow customer actions such as:

- Start waiting
- Confirm arrival
- Continue cart
- Submit preorder
- Request staff help
- Confirm substitution, where allowed
- Retry allowed payment flow
- View safe payment status
- Request support
- Continue recovery flow
- Cancel draft, where allowed

The web app must not allow:

- Manager override
- Staff correction
- Payment uncertainty resolution
- Refund approval
- Forced table assignment
- Forced order state transition
- KDS state override
- Incident closure
- Support case closure without policy

Customer actions must be scoped by token, session, and runtime state.

## 17. Duplicate Submission Prevention

The web app must prevent duplicate:

- Waiting session creation
- Cart submission
- Preorder submission
- Order handoff
- Payment attempt
- Cancel request
- Refund request
- Support case creation

Duplicate prevention must use:

- Scoped token validation
- Idempotency key
- Session correlation ID
- Button/loading state control
- Runtime command validation
- Replay-safe backend rules

The UI must not encourage repeated taps during uncertain processing.

## 18. Web App Recovery Rules

Recovery may be required when:

- Browser refresh occurs
- Customer opens link from another device
- Token expires
- Session is merged or split
- Payment redirect fails
- Customer sees failure but order/payment exists
- Kiosk continuation moves into web app
- Waiting or table state changes
- Staff created assist link
- Support follow-up link is opened

Recovery must route through Store Runtime validation.

Recovery must prioritize:

1. Avoid duplicate payment
2. Avoid duplicate order
3. Avoid customer misinformation
4. Preserve evidence
5. Escalate to staff/support where needed

## 19. Web App Error Boundary

Customer-facing errors must be safe and useful.

Allowed error boundaries include:

- This link has expired
- Staff can help continue your request
- Your order status is being checked
- Payment status requires confirmation
- This action is no longer available
- Please return to the store link
- Support will follow up if needed

The web app must not expose:

- Stack traces
- Internal IDs
- Provider errors
- Database errors
- Token validation details
- Other customer/session data
- Staff-only or audit-only state

## 20. Staff And Support Handoff

The web app must support handoff to staff or support when:

- Waiting/session state is ambiguous
- Order state is unclear
- Payment is uncertain
- Link expired during sensitive action
- Customer disputes status
- Kiosk continuation failed
- Refund/cancel status requires review
- Customer cannot proceed due to accessibility or language issue
- Support case requires follow-up

Handoff must include scoped runtime context and evidence link.

## 21. Privacy And Data Minimization

The web app must minimize displayed and collected data.

It should collect only data needed for:

- Waiting
- Notification
- Order continuation
- Payment status routing
- Support follow-up
- Legal or compliance requirement, where applicable

Guest flows should not require unnecessary account creation unless business policy changes.

Customer-visible data must be limited to the scoped session.

## 22. Evidence Requirements

The system must preserve evidence for:

- Web app session start
- Link/token validation
- Guest session creation
- Customer account attachment
- Waiting action
- Cart creation
- Cart modification
- Availability display
- Preorder submission
- Customer-facing order status display
- Payment status display
- Customer action
- Duplicate prevention
- Error display
- Recovery flow
- Staff/support handoff
- Session expiration
- Device/browser context where safe

Evidence must include:

- Store ID
- Business date
- Web app session reference
- Guest/customer reference, where available
- Link/token reference or hash
- Waiting/table/order/payment/support reference where applicable
- Action
- Runtime state source
- Timestamp
- Result
- Related incident/dispute/support reference where applicable

Sensitive token and payment details must not be stored or displayed unsafely.

## 23. Acceptance Criteria

This policy is accepted when:

- Web app is treated as a Store Runtime participant, not source of truth
- Guest session and customer account identity are separated
- Future native app continuity shares the same runtime model
- Cart draft is separated from accepted order
- Preorder submission passes through Store Runtime validation
- Payment status display is conservative
- Waiting and table display are scoped
- Customer actions cannot perform staff/manager authority
- Duplicate submission prevention is required
- Recovery and error boundaries are safe
- Staff/support handoff is defined
- Privacy and data minimization are documented
- Evidence requirements are traceable

## 24. Out of Scope

This policy does not include:

- Final customer web app UI design
- Full native app implementation
- Full customer account authentication
- Membership and loyalty rules
- Marketing automation
- Payment provider certification
- Full support CRM implementation
- Final localization copy deck
- Full analytics and personalization engine

Those must be handled in customer app, native app, authentication, loyalty, marketing, payment, support, localization, or analytics lanes.

## 25. Related Documents

Related document families include:

- Entrance waiting assist and customer link policy
- Waiting queue, call, arrival, no-show, seating policy
- Table matching and table session policy
- Customer notification and multilingual guidance policy
- Customer link token and QR/NFC security policy
- Store Runtime Customer Session WorkPackage
- Kiosk and Mini Kiosk runtime WorkPackage
- Customer dispute and support handoff WorkPackage
- Payment uncertainty policy
- Runtime evidence policy
- Privacy and data retention policy

## 26. Final Rule

The customer web app is the customer’s window into Store Runtime.

It may guide, display, collect, and continue customer intent, but it must not independently decide what the store, POS, payment provider, kitchen, manager, finance, or support system believes to be true.

This policy defines the customer web app runtime boundary before detailed UI, native app, membership, payment, and support policies expand the customer-facing layer.