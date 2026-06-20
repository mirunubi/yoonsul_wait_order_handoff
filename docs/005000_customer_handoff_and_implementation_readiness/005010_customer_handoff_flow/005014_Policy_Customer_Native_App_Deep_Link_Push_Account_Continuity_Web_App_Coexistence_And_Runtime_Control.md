# 005004_Policy_Customer_Native_App_Deep_Link_Push_Account_Continuity_Web_App_Coexistence_And_Runtime_Control

## 1. Purpose

This policy defines the customer native app, deep link, push notification, account continuity, web app coexistence, and runtime control boundary.

The purpose is to ensure that a future native app does not create a second customer truth layer separate from the customer web app, waiting runtime, table runtime, order runtime, payment state, support state, Store Runtime, POS Gateway, and KDS.

The native app may provide stronger customer continuity, push notification, membership, saved preferences, repeat order, support history, and future loyalty flows.

However, the native app must remain a runtime surface that consumes and submits to Store Runtime. It must not independently decide waiting, table, order, payment, kitchen, refund, cancel, support, or incident truth.

## 2. Scope

This policy covers:

- Native app runtime role
- Native app and web app coexistence
- Deep link boundary
- Push notification boundary
- Customer account continuity
- Guest-to-account upgrade
- Store session attachment
- Waiting and table continuation
- Cart, preorder, and order continuation
- Payment status display boundary
- Support and dispute continuation
- Evidence requirements

This policy does not define final native app UI, full account authentication implementation, app store release process, loyalty engine, native payment certification, or full mobile security architecture.

## 3. Baseline Dependency

This policy depends on:

`006511_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary.md`

`006540_Policy_Entrance_Customer_Notification_Status_Display_Multilingual_Guidance.md`

`005002_Policy_Customer_Link_Token_QR_NFC_Session_Expiration_Abuse_Prevention_And_Security_Boundary.md`

`005003_Policy_Customer_Web_App_Guest_Session_App_Native_Continuity_Order_Surface_And_Runtime_Control.md`

06560 defines the customer web app runtime boundary.  
This document defines how the future native app coexists with that web app and Store Runtime.

## 4. Core Principle

The native app is a persistent customer surface, not a separate store authority.

The native app may remember the customer better than the web app, but it must not believe the store state more strongly than Store Runtime.

The native app may:

1. Maintain customer login
2. Receive push notifications
3. Open deep links
4. Continue waiting, order, table, or support flow
5. Display safe customer-facing status
6. Store preferences, where allowed
7. Connect membership or loyalty features, where later approved
8. Support repeat customer convenience

The native app must not independently decide:

- Waiting priority
- Table assignment
- POS order acceptance
- Payment approval
- Refund or cancel completion
- Kitchen preparation state
- Manager approval
- Customer dispute resolution
- Daily closeout state

Authoritative state must come from Store Runtime and related controlled services.

## 5. Native App Runtime Roles

The native app may support the following runtime roles.

| Role | Meaning |
|---|---|
| Account Surface | Persistent customer login and profile surface |
| Waiting Surface | Waiting creation, status, call, arrival, recovery |
| Table Surface | Table-linked service context continuation |
| Menu Surface | Menu browse with availability-safe state |
| Cart Surface | Cart draft and reorder convenience |
| Preorder Surface | Order intent submission through Store Runtime |
| Order Status Surface | Safe order and kitchen status display |
| Payment Status Surface | Conservative payment status display |
| Notification Surface | Push and in-app notification display |
| Support Surface | Dispute and support case continuation |
| Recovery Surface | Controlled recovery after failed or expired flow |

The native app role must be selected by runtime context, not only by screen navigation.

## 6. Web App Coexistence Rule

The web app and native app must coexist under one runtime model.

A customer may begin in:

- QR/NFC web link
- Entrance web flow
- Kiosk continuation link
- Table QR web flow
- Staff-generated assist link
- Native app deep link
- Native app push notification
- Support follow-up link

The system must preserve continuity when the customer moves between web app and native app.

The native app must not create duplicate waiting, cart, order, payment, or support state merely because it receives a link already opened in the web app.

## 7. Deep Link Boundary

Native app deep links may support:

- Store entrance
- Waiting status
- Arrival confirmation
- Table context
- Cart continuation
- Preorder review
- Order status
- Payment status
- Support case
- Recovery flow
- Membership or loyalty surface, where later approved

Deep links must follow scoped token policy.

A deep link must define:

- Link family
- Allowed action
- Expiration
- Store context
- Session or case reference
- Customer verification requirement
- Fallback to web app, if native app unavailable
- Evidence capture requirement

Deep links must not grant staff, manager, payment, or support authority beyond the scoped customer action.

## 8. Push Notification Boundary

Push notifications may support:

- Waiting call
- Arrival reminder
- Table readiness
- Preorder status
- Order confirmation
- Kitchen ready
- Payment status notice
- Refund/cancel status notice
- Support follow-up
- Incident/recovery notice
- Loyalty or marketing notice, where later governed

Push notifications must be conservative.

A push notification must not say “confirmed,” “paid,” “refunded,” “cancelled,” or “ready” unless the authoritative runtime state supports that wording.

Push delivery failure must not automatically make the customer at fault.

## 9. Account Continuity Boundary

Native app account continuity may include:

- Customer profile
- Contact method
- Preferred language
- Store history
- Waiting history
- Order history
- Support history
- Membership state
- Loyalty state
- Consent settings

Account continuity must not collapse operational identities.

A customer account may have:

- Multiple guest sessions
- Multiple waiting sessions
- Multiple party contexts
- Multiple table sessions
- Multiple order sessions
- Multiple payment attempts
- Multiple support cases

The app must preserve these as linked but distinct records.

## 10. Guest-To-Account Upgrade

A guest session may later be attached to a customer account.

Guest-to-account upgrade may occur when:

- Guest logs in during waiting
- Guest logs in during cart or preorder
- Guest logs in after table assignment
- Guest logs in after support case creation
- Staff helps identify customer
- Customer uses native app after web guest flow

Upgrade must preserve:

- Original guest session ID
- Original link/token source
- Waiting session
- Cart/order reference
- Payment reference, if any
- Table reference, if any
- Support/dispute reference, if any
- Before/after identity linkage evidence

Guest-to-account upgrade must not duplicate order, payment, or waiting state.

## 11. Store Session Attachment

A native app account session must attach to a store session before acting on live store runtime.

Store session attachment may require:

- Store ID
- Business date
- Link or QR/NFC context
- Waiting session reference
- Table session reference
- Kiosk continuation reference
- Staff assist link
- Customer confirmation
- Token validation
- Additional verification for sensitive action

A logged-in app user must not be allowed to act on a store session they do not control.

## 12. Waiting And Arrival Continuity

The native app may create or continue waiting flow.

Waiting and arrival actions must follow waiting policy:

- Create waiting
- View waiting status
- Receive call
- Confirm arrival
- Request staff help
- Request recovery
- Handle no-show or reversal workflow where allowed

The app must not infer arrival solely from app open, location, push open, or device proximity unless a controlled policy later allows it.

## 13. Table Context Continuity

The native app may continue table context when:

- Customer scans table QR/NFC
- Staff links table session
- Waiting session becomes seated
- Deep link opens table context
- Customer account matches allowed session
- Runtime validates table session

The app must not expose table information from other parties.

A table context must be scoped and must expire or downgrade when the table session is closed.

## 14. Cart And Preorder Continuity

The native app may improve cart and preorder continuity.

However:

- Cart draft remains separate from accepted order
- Preorder remains order intent until accepted
- Menu availability must be revalidated
- Duplicate submission prevention is required
- POS Gateway handoff must be controlled by Store Runtime
- Customer-visible confirmation must follow authoritative state

Saved carts or repeat orders must be revalidated against current store, time, service mode, menu availability, and kitchen capacity.

## 15. Payment Status Boundary

The native app may show payment-related status only conservatively.

Payment status must follow the same rule as web app:

| Runtime State | Native App Display Boundary |
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

The app must not infer payment result from app callback, push notification receipt, or local state alone.

## 16. Support And Dispute Continuity

The native app may support:

- Dispute intake
- Support case status
- Refund/cancel follow-up
- Payment uncertainty follow-up
- Compensation status, where later governed
- Customer message history
- Evidence upload or statement, if later approved
- Reopen or follow-up request

Support continuity must remain linked to Store Runtime, finance, and evidence.

The native app must not close support cases or approve compensation unless controlled support policy allows it.

## 17. Notification Preference And Consent

The native app may manage notification preferences.

Preference categories may include:

- Waiting and call
- Arrival and table
- Order status
- Payment/refund/cancel status
- Support follow-up
- Loyalty/membership
- Marketing

Operational notifications may be necessary for service.  
Marketing notifications must be separately governed and consent-aware.

Notification preferences must not prevent the system from preserving operational evidence.

## 18. Offline And App Failure Boundary

The native app may fail, close, lose network, or become outdated.

Failure cases include:

- App closed during payment
- Push not received
- Deep link failed
- Offline app state stale
- Cached order status outdated
- App version incompatible
- Login expired
- Token expired
- Store runtime changed while app was offline

The app must revalidate runtime state before displaying or acting on sensitive state.

Cached state must be clearly treated as non-authoritative when stale.

## 19. Duplicate Prevention

The native app must prevent duplicate:

- Waiting creation
- Arrival confirmation
- Cart submission
- Preorder submission
- Payment attempt
- Cancel/refund request
- Support case creation
- Deep link action execution

Duplicate prevention must use:

- Scoped token
- Idempotency key
- Runtime correlation ID
- App session ID
- Customer account linkage
- Backend command validation
- Safe loading/retry UX

The app must not rely only on local button disabling.

## 20. Privacy Boundary

The native app may have more persistent customer data than the web app, so privacy control must be stronger.

The app must avoid exposing:

- Other party data
- Other table sessions
- Staff-only notes
- Internal incident details
- Full payment provider references
- Internal audit records
- Support case details not belonging to the account/session
- Sensitive tokens or credentials

Persistent account surfaces must respect data minimization and consent boundaries.

## 21. Incident And Dispute Linkage

Native app incidents/disputes may occur when:

- Push message was misleading
- Deep link opened wrong context
- Guest-to-account upgrade duplicated session
- App showed stale status
- App showed payment success/failure incorrectly
- App created duplicate order/payment attempt
- App did not receive call notification
- App and web app showed inconsistent state
- Support case context was wrong

These must link to incident, support, and evidence flows.

## 22. Daily Closeout Impact

Daily closeout may need to review native-app-related exceptions when material.

Examples include:

- Waiting call push failure
- Deep link failure affecting seating
- Native app duplicate submission
- Payment callback uncertainty
- Support case opened from app
- Stale app status causing dispute
- Guest-to-account upgrade conflict
- App/web state divergence

Native app issues that affect store operation must be visible to Store Runtime closeout.

## 23. Evidence Requirements

The system must preserve evidence for:

- Native app session start
- Account login or session validation
- Deep link open
- Token validation
- Push notification creation
- Push delivery/open event, where available
- Guest-to-account upgrade
- Store session attachment
- Waiting action
- Arrival confirmation
- Table context open
- Cart/preorder action
- Payment status display
- Support/dispute action
- Duplicate prevention
- Recovery flow
- Error display
- App/web handoff
- Incident/dispute linkage

Evidence must include:

- Store ID, where applicable
- Business date, where applicable
- Customer account reference, where available
- Guest/session reference
- App session reference
- Device/app version reference, where safe
- Link/token reference or hash
- Action
- Runtime state source
- Timestamp
- Result
- Related waiting/table/order/payment/support/incident/dispute reference where applicable

Sensitive token, credential, and payment details must not be stored or displayed unsafely.

## 24. Acceptance Criteria

This policy is accepted when:

- Native app is treated as persistent customer surface, not separate truth layer
- Web app and native app coexist under one Store Runtime model
- Deep links follow scoped token policy
- Push wording follows conservative notification policy
- Customer account continuity does not collapse operational identities
- Guest-to-account upgrade preserves evidence
- Store session attachment is required for live runtime action
- Cart, preorder, payment, and support actions remain Store Runtime controlled
- Offline/stale app state is not treated as authoritative
- Duplicate prevention is required
- Privacy boundaries are documented
- Daily closeout can see material native app exceptions
- Evidence requirements are traceable

## 25. Out of Scope

This policy does not include:

- Final native app UI
- App store deployment
- Full mobile authentication implementation
- Full loyalty engine
- Full marketing automation
- Native payment certification
- Device-level mobile security implementation
- Full push vendor selection
- Full customer analytics and personalization

Those must be handled in native app, authentication, loyalty, marketing, payment, mobile security, vendor, or analytics lanes.

## 26. Related Documents

Related document families include:

- Customer web app runtime policy
- Customer link token and QR/NFC security policy
- Customer notification and multilingual guidance policy
- Waiting queue, call, arrival, no-show, seating policy
- Table matching and table session policy
- Customer dispute and support handoff WorkPackage
- Store Runtime incident command WorkPackage
- Runtime evidence policy
- Privacy and data retention policy
- Authentication and account policy
- Push notification policy

## 27. Final Rule

The native app may remember the customer, but it must not invent the store’s truth.

Every deep link, push, login, guest upgrade, cart, preorder, payment display, support case, and recovery flow must remain scoped to Store Runtime and backed by evidence.

This policy defines the native app runtime boundary before detailed mobile UI, authentication, loyalty, payment, and push implementation policies expand the customer app layer.