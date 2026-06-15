# 11140_Policy_Mini_Kiosk_Session_Identity_Device_Trust_And_Customer_Context_Boundary

Legacy path: $old.

\#\# 1\. Purpose

This document defines the session, identity, device trust, customer context, table/waiting linkage, privacy boundary, and recovery policy for future Mini Kiosk and Kiosk development in the Yoonsul Wait/Order Handoff project.

The previous document defined payment flow state and recovery boundaries.

This document defines who or what the kiosk session represents.

A kiosk session may represent:

\- anonymous customer intent
\- waiting customer
\- seated table participant
\- pickup customer
\- member customer
\- PAYCO / Toss / provider payment user
\- staff-assisted customer
\- device-local session
\- temporary recovery session

These must not be collapsed into one unsafe identity.

This document does not implement authentication, customer account, session storage, device registration, QR login, table assignment, waiting queue, or kiosk UI.

It defines future boundaries only.

\---

\#\# 2\. Scope

This document covers:

\- kiosk session boundary
\- mini kiosk session boundary
\- customer context
\- anonymous session
\- member session
\- payment provider identity boundary
\- table context
\- waiting context
\- pickup context
\- device trust
\- shared kiosk privacy
\- session timeout
\- abandoned session
\- staff-assisted session
\- recovery session
\- identity evidence
\- no-implementation boundary

This document does not cover:

\- final customer authentication implementation
\- final member account system
\- final QR login implementation
\- final device registration code
\- final kiosk UI
\- final payment provider SDK
\- final table management implementation
\- final waiting queue implementation
\- final database schema

\---

\#\# 3\. Core Principle

A kiosk session is not automatically a customer identity.

The project must follow this rule:

\> Kiosk session, customer identity, payment provider identity, table context, waiting context, and device trust are separate concepts and must be linked only through controlled backend validation.

A device cannot become the customer.

A payment app user cannot automatically become a Yoonsul member.

A table number cannot automatically become a payment identity.

A waiting number cannot automatically become a KDS ticket.

\---

\#\# 4\. Source Documents

This policy reuses:

\- 05021_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog
\- 05031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog
\- 05041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog
\- 05061_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog
\- 05071_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog
\- 05096_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping
\- 05170 PAYCO POS Integration Implementation Approach And Official Verification Policy
\- 11120_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary
\- 11130_Policy_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary

\---

\#\# 5\. Session Types

Future Mini Kiosk and Kiosk modules should distinguish these session types:

| Session Type | Meaning |
| \------------ | \------- |
| Anonymous Kiosk Session | Customer is not logged in or identified |
| Waiting-Linked Session | Session linked to waiting queue entry |
| Table-Linked Session | Session linked to table context |
| Pickup-Linked Session | Session linked to pickup order context |
| Member Session | Session linked to Yoonsul member account |
| Provider Payment Session | Session linked to provider payment flow |
| Staff-Assisted Session | Staff helps customer complete or recover flow |
| Recovery Session | Session used to resolve interrupted/uncertain flow |
| Device Maintenance Session | Staff/admin device maintenance session |
| Test/Sandbox Session | Non-production test session |

Each session type has different authority.

\---

\#\# 6\. Anonymous Kiosk Session Boundary

Anonymous kiosk session may:

\- browse menu
\- select items
\- create cart
\- create order intent
\- start payment flow
\- receive temporary order number
\- request pickup or dine-in flow
\- abandon session

Anonymous kiosk session must not:

\- access member benefits without validation
\- view prior orders
\- view other customer table/order state
\- trigger refund
\- merge identity
\- store long-lived personal profile
\- access staff/admin functions
\- access support records
\- expose payment provider identity

Anonymous session should be default for kiosk MVP.

\---

\#\# 7\. Member Session Boundary

Member session may be enabled later.

Member session may:

\- apply member benefits
\- use points/coupons where allowed
\- access limited order history
\- use saved preferences
\- link to subscription/pickup benefits
\- receive member receipt

Member session must not:

\- be created solely from payment approval
\- be created solely from PAYCO/Toss login without identity policy
\- expose raw CI/DI
\- allow another customer to view private data on shared kiosk
\- remain logged in after timeout
\- keep sensitive information on public screen

Member session requires stronger privacy controls than anonymous session.

\---

\#\# 8\. Payment Provider Identity Boundary

Payment provider identity is not Yoonsul customer identity.

Examples:

\- PAYCO login account
\- PAYCO payment user
\- Toss payment account
\- card payment identity
\- barcode/QR payer
\- mobile wallet account

Rules:

\- provider payment success does not automatically create member account
\- provider login does not automatically merge with Yoonsul account
\- provider payer identity must not be displayed on shared kiosk beyond safe masked status
\- provider identity data must not enter KDS
\- provider identity data must not enter AI without explicit minimization
\- provider identity data must not enter export without approval
\- provider identity linkage must follow CI/DI and identity callback policy where applicable

Provider identity may support payment verification, not customer profile ownership by default.

\---

\#\# 9\. Table Context Boundary

Table context represents where an order will be served.

Table context may include:

\- table number
\- seat/group reference
\- NFC/QR table tag
\- late binding table assignment
\- shared table participant
\- split payment context

Rules:

\- table context is not customer identity
\- table context is not payment identity
\- table context must not expose other customer details
\- multiple customers may share one table
\- one customer may participate in multiple payment contexts
\- table assignment may occur after waiting/order preparation
\- table context must be validated before service handoff
\- table mismatch must create review state

Recommended states:

\- \`TABLE\_CONTEXT\_NOT\_SET\`
\- \`TABLE\_CONTEXT\_SCANNED\`
\- \`TABLE\_CONTEXT\_SELECTED\`
\- \`TABLE\_CONTEXT\_VALIDATED\`
\- \`TABLE\_CONTEXT\_CONFLICT\`
\- \`TABLE\_CONTEXT\_REVIEW\_REQUIRED\`

\---

\#\# 10\. Waiting Context Boundary

Waiting context represents place in queue or pre-entry flow.

Waiting context may include:

\- waiting number
\- party size
\- expected seating time
\- pre-order readiness
\- late table binding candidate
\- customer contact token where allowed

Rules:

\- waiting context is not payment identity
\- waiting context is not table assignment
\- waiting context does not automatically create KDS ticket
\- waiting pre-order must still pass payment/order policy
\- waiting context may become table-linked only after validation
\- waiting cancellation must not silently refund paid order
\- waiting no-show must follow customer recovery policy

Recommended states:

\- \`WAITING\_CONTEXT\_CREATED\`
\- \`WAITING\_CONTEXT\_PREORDER\_STARTED\`
\- \`WAITING\_CONTEXT\_PAYMENT\_PENDING\`
\- \`WAITING\_CONTEXT\_READY\_FOR\_SEATING\`
\- \`WAITING\_CONTEXT\_TABLE\_BINDING\_PENDING\`
\- \`WAITING\_CONTEXT\_BOUND\_TO\_TABLE\`
\- \`WAITING\_CONTEXT\_CANCELLED\`
\- \`WAITING\_CONTEXT\_NO\_SHOW\_REVIEW\`

\---

\#\# 11\. Pickup Context Boundary

Pickup context represents a takeout or pickup order.

Pickup context may include:

\- pickup name or alias
\- pickup number
\- expected pickup time
\- phone/contact token where allowed
\- paid order reference
\- preparation status

Rules:

\- pickup alias must be minimal
\- full customer identity should not be exposed on kiosk screen
\- pickup context must not expose payment details
\- pickup late/no-show must follow recovery/waste policy
\- pickup cancellation after preparation must require policy review
\- pickup context can link to KDS status but must not expose kitchen details unnecessarily

Recommended states:

\- \`PICKUP\_CONTEXT\_CREATED\`
\- \`PICKUP\_TIME\_SELECTED\`
\- \`PICKUP\_PAYMENT\_VERIFIED\`
\- \`PICKUP\_PREPARATION\_STARTED\`
\- \`PICKUP\_READY\`
\- \`PICKUP\_COMPLETED\`
\- \`PICKUP\_NOT\_COLLECTED\`
\- \`PICKUP\_REVIEW\_REQUIRED\`

\---

\#\# 12\. Device Trust Boundary

Kiosk device trust is separate from customer identity.

Device trust may include:

\- device id
\- installation location
\- store id
\- kiosk mode
\- OS/platform
\- app version
\- certificate/registration status
\- last heartbeat
\- lost/revoked status
\- maintenance status

Rules:

\- trusted device does not mean trusted customer
\- trusted device does not approve payment
\- trusted device does not bypass backend validation
\- revoked device must not accept new orders
\- maintenance mode must block customer orders
\- device relocation must trigger review
\- device trust changes must be audited
\- device compromise must invalidate active sessions where needed

Recommended device states:

\- \`DEVICE\_REGISTERED\`
\- \`DEVICE\_ACTIVE\`
\- \`DEVICE\_MAINTENANCE\`
\- \`DEVICE\_SUSPENDED\`
\- \`DEVICE\_REVOKED\`
\- \`DEVICE\_LOST\`
\- \`DEVICE\_COMPROMISED\`
\- \`DEVICE\_REPLACEMENT\_PENDING\`

\---

\#\# 13\. Shared Kiosk Privacy Rule

A public kiosk is a shared surface.

Rules:

\- do not show full name by default
\- do not show phone number by default
\- do not show raw member id
\- do not show provider account id
\- do not show payment details
\- do not show order history after session timeout
\- clear cart/session after timeout
\- mask member benefit display where possible
\- avoid showing staff/support notes
\- avoid showing previous customer receipt
\- require explicit confirmation before member data appears

Privacy must be stronger on public kiosk than on personal mobile app.

\---

\#\# 14\. Session Timeout Rule

Kiosk sessions must expire.

Timeout should clear or protect:

\- cart
\- order intent not locked
\- member display data
\- provider UI state
\- coupon/point display
\- pickup alias
\- table scan context
\- waiting context screen
\- payment pending screen where safe

Timeout must not delete:

\- payment evidence
\- order intent already submitted
\- payment reservation
\- approved payment
\- KDS ticket
\- audit record
\- recovery state

Timeout creates recovery state if payment/order state is uncertain.

\---

\#\# 15\. Abandoned Session Rule

An abandoned session occurs when:

\- customer walks away
\- kiosk times out
\- provider app switch not completed
\- WebView closes unexpectedly
\- customer scans QR but does not finish
\- cart remains inactive
\- payment reservation expires
\- device reboots

Abandoned session handling:

\- unpaid cart may be discarded after timeout
\- payment-pending session must be checked
\- approved payment must continue to order/KDS policy or review
\- uncertain payment must create recovery
\- member session must be cleared
\- evidence must preserve state transitions

Abandonment must not silently lose payment state.

\---

\#\# 16\. Staff-Assisted Session Boundary

Staff may assist kiosk session when:

\- payment is uncertain
\- customer cannot complete payment
\- accessibility issue occurs
\- duplicate charge suspected
\- table context conflict occurs
\- pickup context mismatch occurs
\- device error occurs
\- provider callback delayed
\- member benefit application fails

Staff-assisted session may:

\- inspect masked session state
\- trigger backend provider lookup
\- cancel unpaid order intent
\- mark review required
\- help customer restart safely

Staff-assisted session must not:

\- view raw provider secrets
\- view raw CI/DI
\- manually mark payment approved without evidence
\- manually create refund without policy
\- overwrite audit
\- access unrelated customer session
\- use kiosk customer surface as staff admin console

\---

\#\# 17\. Recovery Session Boundary

Recovery session exists to resolve interrupted flow.

Recovery session may link:

\- prior kiosk session id
\- order intent id
\- payment reservation id
\- provider reference
\- table/waiting/pickup context
\- staff review id
\- support case id

Rules:

\- recovery must be scoped
\- recovery must not expose full identity on public screen
\- recovery must not duplicate payment
\- recovery must not duplicate KDS ticket
\- recovery must record evidence
\- recovery must be visible to staff where needed
\- recovery must expire or close after resolution

Recommended states:

\- \`RECOVERY\_SESSION\_CREATED\`
\- \`RECOVERY\_CONTEXT\_MATCHED\`
\- \`RECOVERY\_PROVIDER\_LOOKUP\_PENDING\`
\- \`RECOVERY\_PAYMENT\_CONFIRMED\`
\- \`RECOVERY\_PAYMENT\_NOT\_FOUND\`
\- \`RECOVERY\_ORDER\_RESTORED\`
\- \`RECOVERY\_REFUND\_REVIEW\`
\- \`RECOVERY\_SUPPORT\_ESCALATED\`
\- \`RECOVERY\_CLOSED\`

\---

\#\# 18\. Customer Context Linkage Rule

Customer context linkage must be explicit.

Possible links:

| Link | Allowed After |
| \---- | \------------- |
| Kiosk session to order intent | order intent creation |
| Order intent to payment reservation | backend payment reservation |
| Payment reservation to provider payment | provider verification |
| Order/payment to table | table validation |
| Order/payment to waiting | waiting validation |
| Order/payment to pickup | pickup validation |
| Payment provider identity to member | identity policy and consent |
| Member to benefits | authenticated member session |
| Staff to recovery session | scoped staff review |
| Support to session | support case scope |

No implicit linkage is allowed for sensitive identity.

\---

\#\# 19\. Identity Data Minimization

Kiosk should minimize identity data.

Recommended minimal data:

\- session id
\- temporary order number
\- masked member display name where needed
\- masked phone suffix where needed
\- pickup alias
\- table number
\- waiting number
\- provider payment reference token
\- member benefit eligibility flag

Avoid:

\- full legal name
\- raw CI/DI
\- full phone number
\- full email
\- full provider account id
\- detailed payment instrument
\- birthdate
\- unnecessary address
\- unrelated order history

KDS should receive no personal identity unless operationally necessary.

\---

\#\# 20\. Table / Waiting / Payment Conflict Rule

Conflicts must create review.

Examples:

\- same table scanned by multiple unrelated sessions
\- waiting context bound to wrong table
\- paid order linked to cancelled waiting entry
\- pickup order claimed by wrong session
\- payment approved after session timeout
\- member benefit applied to anonymous session incorrectly
\- provider identity conflicts with selected member
\- staff recovery links wrong order

Conflict states:

\- \`CONTEXT\_CONFLICT\`
\- \`TABLE\_CONTEXT\_CONFLICT\`
\- \`WAITING\_CONTEXT\_CONFLICT\`
\- \`PAYMENT\_CONTEXT\_CONFLICT\`
\- \`IDENTITY\_CONTEXT\_CONFLICT\`
\- \`RECOVERY\_CONTEXT\_CONFLICT\`
\- \`STAFF\_REVIEW\_REQUIRED\`

Do not silently resolve conflicts.

\---

\#\# 21\. Toss Context Mapping

For Toss-related flows:

\- Toss merchant/store mapping must validate device/store context.
\- Toss payment identity does not automatically become Yoonsul customer identity.
\- Toss payment event may update payment state.
\- Toss Apps/device context, if used later, must not replace Yoonsul device trust.
\- Toss webhook or lookup must map to backend order/payment context before display on kiosk.
\- Toss callback/event must not expose payer details on public kiosk.

\---

\#\# 22\. PAYCO Context Mapping

For PAYCO-related flows:

\- PAYCO login is separate from PAYCO payment.
\- PAYCO payment reservation is separate from Yoonsul member identity.
\- PAYCO auth callback is separate from final payment approval.
\- PAYCO app bridge/WebView result is UI context only.
\- PAYCO Smart Order program context is external operational context.
\- PAYCO identity data must not be merged without Yoonsul identity policy.
\- PAYCO provider data must not enter KDS unless operationally required and minimized.

\---

\#\# 23\. Evidence Requirement

Session and identity evidence must include:

\- session id
\- device id
\- session type
\- order intent id where applicable
\- payment reference where applicable
\- table/waiting/pickup context where applicable
\- identity linkage status
\- provider identity linkage status
\- member session status
\- timeout/abandonment event
\- recovery session id where applicable
\- staff review id where applicable
\- sensitive data review
\- audit event reference

Evidence must not include:

\- raw CI/DI
\- provider secret
\- payment credential
\- full provider account id
\- WebView cookie
\- raw unrestricted identity payload
\- full phone number unless approved
\- support note containing secrets

\---

\#\# 24\. Required Tests

Required future tests:

1\. Anonymous kiosk session cannot view member data.
2\. PAYCO login does not automatically create payment success.
3\. Provider payment identity does not automatically create member account.
4\. Table scan does not create payment identity.
5\. Waiting entry does not create KDS ticket.
6\. Kiosk device trust does not bypass payment verification.
7\. Revoked device cannot create new order intent.
8\. Session timeout clears public display data.
9\. Timeout does not delete approved payment.
10\. Abandoned payment session creates recovery state.
11\. Staff-assisted session cannot view raw CI/DI.
12\. Staff-assisted session cannot mark payment approved without evidence.
13\. Recovery session cannot duplicate KDS ticket.
14\. Wrong table binding creates conflict.
15\. Wrong waiting linkage creates conflict.
16\. Pickup claim mismatch creates review.
17\. Member data is masked on shared kiosk.
18\. Provider account id is not shown on public screen.
19\. KDS ticket does not receive unnecessary identity data.
20\. Evidence packet masks identity and provider data.

\---

\#\# 25\. Non-Goals

This document does not define:

\- final kiosk session database
\- final customer account schema
\- final member login UI
\- final QR table implementation
\- final waiting queue implementation
\- final pickup screen
\- final device trust implementation
\- final staff support console
\- final identity linkage API
\- final provider identity mapping code

Those belong to later controlled implementation.

\---

\#\# 26\. Readiness Check

This document is ready when the project can answer:

1\. What session types exist?
2\. What can anonymous session do?
3\. What can member session do?
4\. Why is provider identity not Yoonsul identity?
5\. What is table context?
6\. What is waiting context?
7\. What is pickup context?
8\. Why is device trust separate from customer identity?
9\. How is privacy protected on shared kiosk?
10\. What happens on session timeout?
11\. What happens on abandoned session?
12\. What can staff-assisted session do?
13\. What can staff-assisted session not do?
14\. What is recovery session?
15\. How are customer contexts linked?
16\. What identity data should be minimized?
17\. What happens on table/waiting/payment conflicts?
18\. How does Toss map to context?
19\. How does PAYCO map to context?
20\. What evidence is required?
21\. What tests are required?

If these questions cannot be answered, kiosk session and identity boundary planning is incomplete.

\---

\#\# 27\. Conclusion

Mini Kiosk and Kiosk development must separate session, identity, device trust, customer context, provider identity, table context, waiting context, pickup context, payment state, and recovery state.

The project must preserve the following rules:

\- kiosk session is not customer identity
\- device trust is not customer authority
\- provider identity is not Yoonsul member identity
\- payment identity is not table identity
\- table context is not customer identity
\- waiting context is not KDS ticket
\- pickup context must be privacy-minimized
\- shared kiosk must not expose prior customer data
\- timeout must protect public display but preserve payment evidence
\- abandoned payment sessions require recovery
\- staff-assisted session cannot overwrite truth
\- recovery session must be scoped and evidenced
\- identity linkage must be explicit
\- KDS should receive minimal identity data
\- conflicts require review, not silent merge

This document prepares Mini Kiosk and Kiosk session/identity/device context for safe future implementation.
