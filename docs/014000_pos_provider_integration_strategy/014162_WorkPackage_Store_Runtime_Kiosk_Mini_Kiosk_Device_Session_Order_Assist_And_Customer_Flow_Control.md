# 014162_WorkPackage_Store_Runtime_Kiosk_Mini_Kiosk_Device_Session_Order_Assist_And_Customer_Flow_Control

## 1. Purpose

This WorkPackage defines the Kiosk and Mini Kiosk runtime boundary inside the Store Runtime lane.

The purpose is to ensure that kiosk-based ordering, mini kiosk assistance, foreign-customer guidance, guest ordering, staff-assisted correction, and POS Gateway handoff all operate under one controlled store runtime model.

Kiosk devices must not become isolated order islands. They must participate in the same customer session, order state, payment state, staff correction, and evidence model defined by the Store Runtime Control Tower.

## 2. Scope

This WorkPackage covers:

- Main kiosk runtime role
- Mini kiosk runtime role
- Device session handling
- Guest and foreign-customer assist flow
- Kiosk order draft and submission boundary
- Payment handoff boundary
- POS Gateway interaction
- Staff assist and correction route
- Device failure and recovery
- Customer-visible status control
- Runtime evidence requirements

This WorkPackage does not define full kiosk UI design, hardware procurement, payment terminal certification, or provider-specific POS adapter implementation.

## 3. Baseline Dependency

This WorkPackage depends on:

`014161_WorkPackage_Store_Runtime_Integration_Control_Tower_And_Operational_Command_Boundary.md`

`006410_WorkPackage_Store_Runtime_Customer_Session_Waiting_Preorder_Table_Matching_And_Order_State_Control.md`

06400 defines the store runtime command layer.  
06410 defines customer session and order-state control.  
This document applies those controls to kiosk and mini kiosk runtime behavior.

## 4. Core Principle

A kiosk is not the source of truth.

A kiosk is a customer-facing input and display device that must submit intent into Store Runtime.

The Store Runtime decides:

1. Whether the device session is valid
2. Whether the customer/session/order context is valid
3. Whether order submission is allowed
4. Whether payment is required
5. Whether POS Gateway handoff is safe
6. Whether the customer may see confirmation
7. Whether staff must intervene
8. Whether evidence must be preserved

No kiosk may independently mark an order as final, paid, cancelled, refunded, served, or failed without Store Runtime authority.

## 5. Device Types

The Store Runtime must distinguish between kiosk device types.

| Device Type | Runtime Role |
|---|---|
| Main Kiosk | In-store customer ordering and payment-capable device |
| Mini Kiosk | Lightweight order-assist device for waiting, foreign customer, or simplified flow |
| Staff-Assisted Kiosk | Kiosk session where staff helps customer complete flow |
| Recovery Kiosk Session | Kiosk session used to continue or recover a failed/abandoned order |
| Display-Only Device | Device that shows status but cannot submit authoritative command |

The same physical device may support multiple modes, but the active mode must be explicit.

## 6. Device Session Boundary

A kiosk device session must be separated from customer identity.

A device session includes:

- Device ID
- Store ID
- Business date
- Session start time
- Session expiry time
- Language setting
- Flow mode
- Customer or guest session reference
- Cart or order draft reference
- Payment attempt reference, if any
- Staff assist actor, if any
- Recovery status, if any

A kiosk device session must not be treated as the customer.

## 7. Main Kiosk Runtime Flow

The Main Kiosk may support the following flow:

1. Start device session
2. Select language or service mode
3. Create or attach guest/customer session
4. Build cart
5. Validate item availability
6. Confirm order summary
7. Request payment or staff-assisted payment path
8. Submit order/payment command to Store Runtime
9. Store Runtime routes eligible command to POS Gateway
10. POS Gateway returns authoritative result
11. Store Runtime updates order/payment state
12. Kiosk displays safe customer-facing result
13. Evidence is recorded

The kiosk must not display final confirmation before authoritative runtime state is available.

## 8. Mini Kiosk Runtime Flow

The Mini Kiosk may support a lighter flow:

1. Start simplified device session
2. Select language or assist category
3. Identify waiting party, guest, or customer context
4. Build small cart or preorder intent
5. Request staff review if required
6. Submit intent into Store Runtime
7. Continue flow through staff tablet, main kiosk, customer web app, or POS Gateway
8. Show limited safe status to customer

The Mini Kiosk may be used for:

- Foreign customer guidance
- Waiting-to-order conversion
- Menu browsing
- Simple preorder
- Staff-assisted order intake
- Queue acceleration
- Recovery of abandoned app/kiosk session

The Mini Kiosk must not bypass the Store Runtime authority boundary.

## 9. Language And Accessibility Boundary

Kiosk and Mini Kiosk flows may support multilingual and simplified customer guidance.

The system must define:

- Supported language list
- Default fallback language
- Translation source authority
- Menu item translation rule
- Allergen or warning translation rule
- Payment instruction translation rule
- Staff-call phrase set
- Error and recovery wording
- Customer confirmation wording

Translated text must not alter operational meaning.

A translated “confirmed” message may only be shown when the Korean/source operational state would also allow confirmation.

## 10. Order Draft Boundary

A kiosk order draft may include:

- Menu items
- Options
- Quantity
- Service mode
- Table or pickup context
- Waiting session reference
- Customer memo, if allowed
- Staff note, if assisted
- Availability validation result
- Price estimate
- Tax/service display, if required
- Payment requirement status

An order draft is not an accepted order.

The kiosk must preserve the distinction between:

- Cart draft
- Submitted order intent
- POS handoff pending
- POS accepted order
- Kitchen-eligible order
- Failed or recovery-required order

## 11. Payment Boundary

Kiosk payment must follow POS Gateway and Store Runtime payment rules.

Payment-related states include:

- Payment not required yet
- Payment method selected
- Payment attempt started
- Payment pending
- Payment approved
- Payment failed
- Payment uncertain
- Cancel pending
- Refund pending
- Manual review required

The kiosk may show customer-facing payment status, but it must not independently resolve payment uncertainty.

Payment uncertainty must route to staff or manager review.

## 12. Staff Assist Boundary

Staff assist may be required when:

- Customer requests help
- Foreign-language flow is insufficient
- Menu item is unavailable
- Order option is unclear
- Payment fails
- Payment is uncertain
- Kiosk device becomes unstable
- Customer claims they already paid
- Customer wants to modify submitted order
- Customer wants cancellation/refund
- Session must be merged or recovered

Staff assist must record:

- Staff actor
- Device session
- Customer/session/order reference
- Reason
- Action performed
- Before/after state
- Whether manager approval was required

Staff assistance must not erase customer action history.

## 13. Kiosk Failure And Recovery

The Store Runtime must support recovery from:

- Device freeze
- Browser refresh
- Network loss
- Payment terminal interruption
- Customer abandonment
- Duplicate tap or duplicate submission
- Kiosk session timeout
- POS Gateway timeout
- Customer sees failure but POS accepted order
- Payment approved but kiosk confirmation failed
- KDS ticket missing after accepted order

Recovery must prioritize:

1. Preventing duplicate payment
2. Preventing duplicate cooking
3. Preserving customer trust
4. Preserving evidence
5. Allowing staff to continue operation safely

## 14. Duplicate Prevention

Kiosk and Mini Kiosk flows must prevent duplicate creation of:

- Customer session
- Waiting session
- Cart submission
- Order handoff
- Payment attempt
- Kitchen ticket
- Cancel request
- Refund request

Duplicate prevention must use correlation IDs, idempotency keys, device session IDs, and order/payment references where applicable.

The kiosk UI must not encourage repeated submission during uncertain processing.

## 15. Customer-Visible Status Rules

Kiosk customer-facing status must be safe and conservative.

| Runtime State | Kiosk Message Boundary |
|---|---|
| Cart Draft | Show editable cart |
| Validation Pending | Show checking message |
| POS Handoff Pending | Show order confirmation in progress |
| POS Accepted | Show order confirmed |
| Payment Pending | Show payment processing |
| Payment Approved | Show payment complete only after authoritative result |
| Payment Failed | Show retry or staff assist option |
| Payment Uncertain | Show staff confirmation required |
| Kitchen Pending | Show order accepted, kitchen preparing soon |
| Recovery Required | Show staff will assist |
| Cancel Pending | Show cancellation being checked |
| Refund Pending | Show refund being checked |

The kiosk must not show “completed” when Store Runtime still requires review.

## 16. Device Security And Control

Kiosk devices must enforce basic runtime control:

- Store-bound device registration
- Device mode control
- Session timeout
- Staff assist authentication where required
- Manager approval for sensitive actions
- No unrestricted admin access from customer mode
- No credential exposure
- No direct provider credential storage in kiosk UI
- Audit logging for staff/manager actions
- Controlled recovery after crash or restart

Kiosk customer mode must be isolated from staff and manager authority.

## 17. Evidence Requirements

The system must preserve evidence for:

- Device session start
- Language selection
- Customer/guest session attachment
- Cart creation
- Cart modification
- Availability check
- Order submission
- Payment attempt
- POS Gateway handoff
- Payment result
- Customer-visible confirmation
- Staff assist
- Manager approval
- Session timeout
- Device failure
- Recovery flow
- Duplicate prevention
- Cancel/refund request

Evidence must be linked to store, device, session, order, payment, actor, and timestamp.

## 18. Integrated Pilot Requirements

This WorkPackage may enter integrated pilot only when:

- Main Kiosk role is defined
- Mini Kiosk role is defined
- Device session model is defined
- Customer/session attachment rule is defined
- Order draft and submission boundary is defined
- Payment boundary is defined
- Staff assist route is defined
- Failure and recovery route is defined
- Duplicate prevention is defined
- Customer-visible status wording is conservative
- Evidence fields are defined

## 19. Acceptance Criteria

This WorkPackage is accepted when:

- Kiosk and Mini Kiosk authority boundaries are documented
- Device session and customer session are separated
- Main Kiosk and Mini Kiosk runtime flows are documented
- Payment uncertainty routes to staff/manager review
- Staff assist actions are auditable
- Failure and recovery cases are documented
- Duplicate prevention requirements are defined
- Customer-visible status rules do not overstate certainty
- Evidence requirements are traceable
- Open risks are routed to backlog, waiver, or blocker register

## 20. Out of Scope

This WorkPackage does not include:

- Final kiosk UI design
- Final hardware selection
- Payment terminal certification
- Full multilingual copy deck
- Full menu image rendering policy
- Loyalty and coupon application logic
- Full POS provider adapter implementation
- Full KDS implementation

Those must be handled in their own lanes.

## 21. Related Documents

Related document families include:

- Store Runtime Control Tower WorkPackage
- Customer session and order-state control WorkPackage
- POS Gateway readiness lane
- Payment uncertainty policy
- Kiosk UI policy
- Mini Kiosk assist policy
- Staff tablet operation policy
- Manager override governance
- Manual fallback SOP
- Runtime evidence policy
- Incident register template

## 22. Final Rule

A kiosk is only safe when it behaves as a controlled runtime participant.

It may collect customer intent, guide the customer, and display safe status, but it must not independently decide operational truth.

This WorkPackage defines the kiosk and mini kiosk runtime boundary before deeper staff tablet, KDS, and store closeout flows are expanded.