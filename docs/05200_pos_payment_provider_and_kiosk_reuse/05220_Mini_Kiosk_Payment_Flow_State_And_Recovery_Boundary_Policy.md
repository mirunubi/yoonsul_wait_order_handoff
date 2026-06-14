# 05220_Mini_Kiosk_Payment_Flow_State_And_Recovery_Boundary_Policy

\#\# 1\. Purpose

This document defines the payment flow state model, recovery boundary, duplicate prevention rule, timeout handling, cancellation handling, uncertain payment state, and KDS handoff protection policy for future Mini Kiosk and Kiosk development in the Yoonsul Wait/Order Handoff project.

The previous document defined module boundaries for Mini Kiosk, Kiosk, provider adapters, payment backend, and KDS bridge.

This document defines how payment flow state must be controlled so that kiosk UI events, provider redirects, callbacks, payment approval, and kitchen handoff do not collapse into one unsafe state.

This document does not implement payment code, kiosk UI, provider SDK, Android WebView, Windows kiosk program, database schema, or KDS bridge logic.

It defines future payment flow and recovery boundaries only.

\---

\#\# 2\. Scope

This document covers:

\- Mini Kiosk payment state model  
\- full Kiosk payment state model  
\- order intent state  
\- payment reservation state  
\- provider UI state  
\- callback state  
\- backend approval state  
\- payment uncertain state  
\- duplicate prevention  
\- timeout recovery  
\- customer cancellation  
\- staff review  
\- KDS handoff gating  
\- recovery evidence  
\- provider-specific state mapping  
\- Toss/PAYCO reuse  
\- no-implementation boundary

This document does not cover:

\- final payment API  
\- final Toss implementation  
\- final PAYCO implementation  
\- final Android WebView code  
\- final Windows kiosk code  
\- final KDS ticket code  
\- final database schema  
\- final refund automation  
\- final settlement automation  
\- final production release gate

\---

\#\# 3\. Core Principle

Payment flow must be state-based, not screen-based.

The project must follow this rule:

\> A kiosk screen transition, provider app return, WebView redirect, barcode scan, or local UI success message must never be treated as final payment approval without backend verification.

Payment state must be verified before KDS handoff.

Uncertain payment state must be visible and recoverable.

\---

\#\# 4\. Source Documents

This policy reuses:

\- 05000 POS KDS RPC Bridge Idempotency Replay Test Catalog Policy  
\- 05010 Payment Webhook Refund Settlement Reconciliation Test Catalog Policy  
\- 05095 Toss POS Integration Implementation Approach And Test Mapping Policy  
\- 05170 PAYCO POS Integration Implementation Approach And Official Verification Policy  
\- 05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy  
\- 05190 MVP Provider Cutline And Phase 2 POS Expansion Deferral Policy  
\- 05200 POS Payment Provider Document Folder Grouping And Kiosk Reuse Policy  
\- 05210 Mini Kiosk And Kiosk Provider Integration Module Boundary Policy

\---

\#\# 5\. State Families

Mini Kiosk and Kiosk payment flow should be split into five state families:

1\. Order Intent State  
2\. Payment UI State  
3\. Backend Payment Verification State  
4\. KDS Handoff State  
5\. Recovery State

Each family has a different owner.

| State Family | Owner |  
| \------------ | \----- |  
| Order Intent State | Kiosk / Order Runtime |  
| Payment UI State | Kiosk Payment UI Module |  
| Backend Payment Verification State | Payment Runtime |  
| KDS Handoff State | POS/KDS Bridge |  
| Recovery State | Recovery / Support Runtime |

No single screen or module should own all five.

\---

\#\# 6\. Order Intent State

Order intent state represents what the customer wants to order.

Recommended states:

\- \`CART\_EMPTY\`  
\- \`CART\_ACTIVE\`  
\- \`ORDER\_INTENT\_CREATED\`  
\- \`ORDER\_INTENT\_SUBMITTED\`  
\- \`ORDER\_INTENT\_LOCKED\_FOR\_PAYMENT\`  
\- \`ORDER\_INTENT\_EXPIRED\`  
\- \`ORDER\_INTENT\_CANCELLED\_BY\_CUSTOMER\`  
\- \`ORDER\_INTENT\_CANCELLED\_BY\_SYSTEM\`  
\- \`ORDER\_INTENT\_REVIEW\_REQUIRED\`

Rules:

\- Cart is editable before payment lock.  
\- Once locked for payment, price/menu availability should not silently change.  
\- Expired order intent must not proceed to payment approval.  
\- Cancelled order intent must not create KDS ticket.  
\- Order intent alone is not payment truth.  
\- Order intent alone is not KDS ticket.

\---

\#\# 7\. Payment UI State

Payment UI state represents what the kiosk or provider UI is showing.

Recommended states:

\- \`PAYMENT\_METHOD\_SELECTED\`  
\- \`PAYMENT\_PROVIDER\_UI\_REQUESTED\`  
\- \`PAYMENT\_PROVIDER\_UI\_OPENED\`  
\- \`PAYMENT\_APP\_BRIDGE\_LAUNCHED\`  
\- \`PAYMENT\_WEBVIEW\_OPENED\`  
\- \`PAYMENT\_BARCODE\_DISPLAYED\`  
\- \`PAYMENT\_QR\_DISPLAYED\`  
\- \`PAYMENT\_UI\_WAITING\_FOR\_CUSTOMER\`  
\- \`PAYMENT\_UI\_CUSTOMER\_CANCELLED\`  
\- \`PAYMENT\_UI\_TIMEOUT\`  
\- \`PAYMENT\_UI\_RETURNED\_FROM\_PROVIDER\`  
\- \`PAYMENT\_UI\_ERROR\`  
\- \`PAYMENT\_UI\_UNKNOWN\_RESULT\`

Rules:

\- UI opened is not payment success.  
\- App bridge launched is not payment success.  
\- WebView redirect is not payment success.  
\- Customer returned from provider is not payment success.  
\- Barcode or QR displayed is not payment success.  
\- UI timeout may still have pending backend state.  
\- UI error may still require provider lookup.

\---

\#\# 8\. Backend Payment Verification State

Backend payment verification state represents actual payment authority.

Recommended states:

\- \`PAYMENT\_RESERVATION\_REQUESTED\`  
\- \`PAYMENT\_RESERVATION\_CREATED\`  
\- \`PAYMENT\_RESERVATION\_FAILED\`  
\- \`PAYMENT\_AUTH\_CALLBACK\_RECEIVED\`  
\- \`PAYMENT\_AUTH\_CALLBACK\_VALIDATED\`  
\- \`PAYMENT\_AUTH\_CALLBACK\_REJECTED\`  
\- \`PAYMENT\_APPROVAL\_REQUESTED\`  
\- \`PAYMENT\_APPROVED\`  
\- \`PAYMENT\_APPROVAL\_FAILED\`  
\- \`PAYMENT\_CANCELLED\`  
\- \`PAYMENT\_REFUND\_REQUESTED\`  
\- \`PAYMENT\_REFUND\_APPROVED\`  
\- \`PAYMENT\_REFUND\_FAILED\`  
\- \`PAYMENT\_RECONCILIATION\_REQUIRED\`  
\- \`PAYMENT\_UNCERTAIN\`

Rules:

\- Payment reservation is not approval.  
\- Auth callback is not approval.  
\- Approval request is not approval.  
\- Approval response must be validated.  
\- Duplicate callbacks must not create duplicate approval.  
\- Failed approval must not create KDS ticket.  
\- Payment uncertain must not silently proceed.  
\- Refund is separate from cancellation.  
\- Settlement is separate from refund.

\---

\#\# 9\. KDS Handoff State

KDS handoff state represents whether a verified order may enter kitchen execution.

Recommended states:

\- \`HANDOFF\_NOT\_READY\`  
\- \`HANDOFF\_PAYMENT\_REQUIRED\`  
\- \`HANDOFF\_PAYMENT\_VERIFIED\`  
\- \`HANDOFF\_CANDIDATE\_CREATED\`  
\- \`HANDOFF\_IDEMPOTENCY\_CHECKED\`  
\- \`HANDOFF\_SENT\_TO\_KDS\`  
\- \`KDS\_TICKET\_CREATED\`  
\- \`KDS\_TICKET\_ACCEPTED\`  
\- \`KDS\_TICKET\_DUPLICATE\_BLOCKED\`  
\- \`KDS\_TICKET\_RETRY\_PENDING\`  
\- \`KDS\_TICKET\_FAILED\`  
\- \`KDS\_TICKET\_REVIEW\_REQUIRED\`

Rules:

\- KDS ticket must not be created from payment UI state.  
\- KDS ticket must not be created from payment reservation alone.  
\- KDS ticket must not be created from auth callback alone.  
\- KDS ticket may be created only after payment/order policy allows it.  
\- Duplicate payment callback must not duplicate KDS ticket.  
\- KDS retry must be idempotent.  
\- KDS failure must not mutate payment state.

\---

\#\# 10\. Recovery State

Recovery state represents customer/staff/system recovery after uncertain or failed flow.

Recommended states:

\- \`RECOVERY\_NOT\_REQUIRED\`  
\- \`RECOVERY\_PAYMENT\_TIMEOUT\`  
\- \`RECOVERY\_PROVIDER\_LOOKUP\_REQUIRED\`  
\- \`RECOVERY\_DUPLICATE\_ATTEMPT\_BLOCKED\`  
\- \`RECOVERY\_PAYMENT\_UNCERTAIN\`  
\- \`RECOVERY\_CUSTOMER\_CANCEL\_REQUESTED\`  
\- \`RECOVERY\_KDS\_ALREADY\_STARTED\`  
\- \`RECOVERY\_REFUND\_REVIEW\_REQUIRED\`  
\- \`RECOVERY\_STAFF\_REVIEW\_REQUIRED\`  
\- \`RECOVERY\_SUPPORT\_REVIEW\_REQUIRED\`  
\- \`RECOVERY\_RECONCILIATION\_REQUIRED\`  
\- \`RECOVERY\_COMPLETED\`  
\- \`RECOVERY\_ESCALATED\`

Rules:

\- Recovery must preserve uncertainty.  
\- Recovery must not hide payment ambiguity.  
\- Recovery must not silently refund.  
\- Recovery must not silently cancel kitchen work.  
\- Recovery must record evidence.  
\- Recovery must provide staff-safe status.

\---

\#\# 11\. Happy Path Flow

Recommended happy path:

1\. Customer creates cart.  
2\. Customer submits order intent.  
3\. Backend locks order intent for payment.  
4\. Backend creates payment reservation where provider requires it.  
5\. Kiosk opens provider payment UI.  
6\. Customer completes payment.  
7\. Provider callback or lookup reaches backend.  
8\. Backend validates provider response.  
9\. Backend records payment approved.  
10\. Backend creates handoff candidate.  
11\. POS/KDS bridge performs idempotency check.  
12\. KDS ticket is created.  
13\. Kiosk displays verified order number or pickup state.

Important:

    Kiosk display must follow backend state.

\---

\#\# 12\. Payment Timeout Flow

Timeout does not automatically mean failed payment.

Recommended timeout handling:

1\. Payment UI timeout occurs.  
2\. Kiosk marks UI as \`PAYMENT\_UI\_TIMEOUT\`.  
3\. Backend marks payment as \`PAYMENT\_UNCERTAIN\` or lookup required.  
4\. Provider lookup is attempted where available.  
5\. If provider confirms approval, continue to handoff.  
6\. If provider confirms no approval, mark failed.  
7\. If provider is unavailable, open staff/support review.  
8\. Customer-facing message must say pending or uncertain, not failed unless verified.

Forbidden:

\- automatically retrying approval with same intent without idempotency  
\- creating a second payment reservation without checking first  
\- creating KDS ticket while payment is uncertain  
\- telling customer payment failed when provider state is unknown

\---

\#\# 13\. Duplicate Tap / Duplicate Payment Attempt Flow

Duplicate taps are common in kiosk flows.

Rules:

\- Same order intent must have idempotency key.  
\- Duplicate payment reservation request must return same active reservation or be blocked.  
\- Duplicate callback must not duplicate payment state.  
\- Duplicate approval response must not duplicate KDS ticket.  
\- Duplicate KDS handoff must be blocked.  
\- Customer UI must show current state, not start a second payment blindly.

Recommended states:

\- \`RECOVERY\_DUPLICATE\_ATTEMPT\_BLOCKED\`  
\- \`KDS\_TICKET\_DUPLICATE\_BLOCKED\`  
\- \`PAYMENT\_RECONCILIATION\_REQUIRED\` if provider shows multiple charges

\---

\#\# 14\. Customer Cancellation Flow

Customer cancellation must be separated by timing.

\#\#\# 14.1 Before Payment Reservation

\- cart/order intent may be cancelled  
\- no payment action required  
\- no KDS action required

\#\#\# 14.2 After Payment Reservation Before Approval

\- payment reservation may expire or be cancelled if provider supports it  
\- order intent moves to cancelled or expired  
\- provider state should be checked  
\- no KDS ticket unless payment already approved

\#\#\# 14.3 After Payment Approval Before KDS Ticket

\- refund/cancel policy required  
\- customer cancellation becomes refund review or automatic cancel only if policy allows  
\- KDS not started yet

\#\#\# 14.4 After KDS Ticket Created

\- customer cancellation must not silently refund or cancel kitchen work  
\- staff/support review required  
\- refund decision follows policy  
\- kitchen state must be visible

Recommended states:

\- \`CUSTOMER\_CANCEL\_REQUESTED\`  
\- \`PAYMENT\_REFUND\_REQUESTED\`  
\- \`RECOVERY\_KDS\_ALREADY\_STARTED\`  
\- \`RECOVERY\_REFUND\_REVIEW\_REQUIRED\`  
\- \`RECOVERY\_STAFF\_REVIEW\_REQUIRED\`

\---

\#\# 15\. Provider Callback Delay Flow

Provider callback may arrive late.

Rules:

\- Late callback must be accepted only if idempotency and order intent validity allow it.  
\- Expired order intent with approved payment must create review, not silent discard.  
\- Cancelled order intent with approved payment must create refund/reconciliation review.  
\- Duplicate late callback must be ignored or linked to prior result.  
\- Callback after KDS ticket must not duplicate ticket.  
\- Callback after refund must create reconciliation review if conflicting.

Recommended states:

\- \`PAYMENT\_AUTH\_CALLBACK\_RECEIVED\`  
\- \`PAYMENT\_RECONCILIATION\_REQUIRED\`  
\- \`RECOVERY\_SUPPORT\_REVIEW\_REQUIRED\`

\---

\#\# 16\. Provider Lookup Rule

Provider lookup should be used when:

\- callback is delayed  
\- UI timed out  
\- customer claims payment completed  
\- provider UI returned unknown result  
\- duplicate payment attempt suspected  
\- approval response failed after customer authentication  
\- KDS handoff depends on payment status  
\- support review needs payment state

Provider lookup must be:

\- backend-only  
\- credential-protected  
\- rate-limited  
\- audited  
\- idempotent  
\- tenant/store mapped

Provider lookup result must not expose secrets to kiosk UI.

\---

\#\# 17\. Toss Mapping

For Toss-style integration:

\- webhook or payment lookup may update backend payment verification state  
\- webhook duplicate must be idempotent  
\- merchant mapping must be validated  
\- payment approved event may allow handoff candidate  
\- payment cancelled event may trigger review  
\- Apps in Toss / device UI must not own payment truth

Relevant states:

\- \`PAYMENT\_APPROVED\`  
\- \`PAYMENT\_CANCELLED\`  
\- \`PAYMENT\_RECONCILIATION\_REQUIRED\`  
\- \`HANDOFF\_CANDIDATE\_CREATED\`

\---

\#\# 18\. PAYCO Mapping

For PAYCO-style integration:

\- order reservation maps to \`PAYMENT\_RESERVATION\_CREATED\`  
\- provider UI/WebView maps to payment UI state only  
\- auth callback maps to \`PAYMENT\_AUTH\_CALLBACK\_RECEIVED\`  
\- final approval maps to \`PAYMENT\_APPROVED\`  
\- failed approval maps to \`PAYMENT\_APPROVAL\_FAILED\`  
\- Smart Order print is not payment truth  
\- PAYCO login is not payment truth

Relevant states:

\- \`PAYMENT\_RESERVATION\_CREATED\`  
\- \`PAYMENT\_AUTH\_CALLBACK\_VALIDATED\`  
\- \`PAYMENT\_APPROVAL\_REQUESTED\`  
\- \`PAYMENT\_APPROVED\`  
\- \`PAYMENT\_UNCERTAIN\`

\---

\#\# 19\. Staff Review Boundary

Staff review is required when:

\- payment is uncertain  
\- customer claims payment but backend cannot verify  
\- provider lookup is unavailable  
\- duplicate charge suspected  
\- payment approved after order cancellation  
\- KDS already started before cancellation request  
\- refund decision is needed  
\- receipt printed but backend state missing  
\- local kiosk rebooted mid-payment  
\- provider callback conflicts with internal state

Staff review may:

\- inspect masked payment status  
\- trigger provider lookup  
\- mark order pending review  
\- request support escalation  
\- explain pending state to customer

Staff review must not:

\- manually mark payment approved without provider evidence  
\- manually refund without payment policy  
\- delete payment records  
\- delete KDS ticket  
\- overwrite audit history

\---

\#\# 20\. Customer Message Policy

Customer-facing messages must reflect certainty.

Allowed examples:

\- Payment is being confirmed.  
\- Payment could not be confirmed yet. Please ask staff for help.  
\- Payment was approved. Your order has been received.  
\- Payment was not completed.  
\- Your cancellation request needs staff review because preparation may have started.

Forbidden examples unless verified:

\- Payment failed when provider state is unknown.  
\- Refund completed before provider refund confirmation.  
\- Order cancelled after kitchen started without staff review.  
\- Payment approved based only on UI return.  
\- Kitchen started based only on payment reservation.

\---

\#\# 21\. Evidence Requirement

Payment flow evidence must include:

\- order intent id  
\- provider reservation id where applicable  
\- provider payment id where applicable  
\- callback id where applicable  
\- idempotency key  
\- tenant/store mapping  
\- payment state transition  
\- KDS handoff state transition  
\- duplicate prevention result  
\- timeout result  
\- provider lookup result  
\- recovery state  
\- staff/support review reference  
\- sensitive data review  
\- audit event reference

Evidence must not include:

\- payment secret  
\- provider credential  
\- raw card data  
\- raw CI/DI  
\- raw unrestricted provider payload  
\- WebView cookie  
\- auth header  
\- service role key

\---

\#\# 22\. Required Tests

Required future tests:

1\. Payment UI opened does not approve payment.  
2\. WebView return does not approve payment.  
3\. PAYCO reservation does not approve payment.  
4\. PAYCO auth callback does not approve payment.  
5\. Toss webhook duplicate does not duplicate KDS ticket.  
6\. Provider lookup result maps correctly.  
7\. Timeout creates uncertain state.  
8\. Unknown provider result does not create KDS ticket.  
9\. Failed payment does not create KDS ticket.  
10\. Approved payment creates only one handoff candidate.  
11\. Duplicate tap is blocked.  
12\. Customer cancellation before payment cancels order intent.  
13\. Customer cancellation after approval creates refund review.  
14\. Customer cancellation after KDS start creates staff review.  
15\. Late callback does not duplicate ticket.  
16\. Late approval after cancellation creates reconciliation review.  
17\. Kiosk reboot mid-payment preserves recovery path.  
18\. Provider credential is not exposed to kiosk.  
19\. Evidence packet is created for uncertain state.  
20\. Staff cannot manually approve payment without provider evidence.

\---

\#\# 23\. Non-Goals

This document does not define:

\- final payment state table  
\- final kiosk UI implementation  
\- final API endpoint  
\- final provider SDK implementation  
\- final webhook receiver  
\- final KDS ticket creation logic  
\- final refund automation  
\- final settlement reconciliation logic  
\- final support tool

Those belong to later controlled implementation.

\---

\#\# 24\. Readiness Check

This document is ready when the project can answer:

1\. What are the payment flow state families?  
2\. What is order intent state?  
3\. What is payment UI state?  
4\. What is backend payment verification state?  
5\. What is KDS handoff state?  
6\. What is recovery state?  
7\. Why is UI return not payment approval?  
8\. Why is reservation not payment approval?  
9\. Why is auth callback not final approval?  
10\. When may KDS ticket be created?  
11\. How is timeout handled?  
12\. How are duplicate taps handled?  
13\. How is customer cancellation handled by timing?  
14\. How are delayed callbacks handled?  
15\. When is provider lookup required?  
16\. How does Toss map to these states?  
17\. How does PAYCO map to these states?  
18\. When is staff review required?  
19\. What customer messages are allowed?  
20\. What evidence is required?  
21\. What tests are required?

If these questions cannot be answered, kiosk payment flow and recovery boundary planning is incomplete.

\---

\#\# 25\. Conclusion

Mini Kiosk and Kiosk payment flow must be controlled by explicit backend-verified states.

The project must preserve the following rules:

\- kiosk UI state is not payment truth  
\- provider app return is not payment truth  
\- WebView redirect is not payment truth  
\- payment reservation is not payment approval  
\- auth callback is not final approval  
\- backend verification is required  
\- KDS ticket must not be created from uncertain payment state  
\- duplicate callbacks must not duplicate KDS tickets  
\- customer cancellation must be evaluated by timing  
\- refund is separate from cancellation  
\- timeout creates uncertainty, not automatic failure  
\- staff review must not overwrite payment truth  
\- recovery must be visible and evidenced

This document prepares Mini Kiosk and Kiosk payment flow for safe future implementation without violating provider, payment, POS/KDS, audit, and recovery boundaries.