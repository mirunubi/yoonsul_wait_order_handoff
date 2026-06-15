# 05210_Policy_Mini_Kiosk_And_Kiosk_Provider_Integration_Module_Boundary

\#\# 1\. Purpose

This document defines the module boundary policy for reusing POS/payment provider integration documents in future Mini Kiosk and Kiosk development within the Yoonsul Wait/Order Handoff project.

The previous document established that Toss, PAYCO, provider priority, MVP provider cutline, and Phase 2 POS expansion documents must be grouped together for future reuse.

This document defines how those provider documents should become module boundaries for:

\- Mini Kiosk
\- full Kiosk
\- payment provider integration
\- POS/KDS handoff
\- customer self-order flow
\- Android/WebView payment flow
\- Windows POS/receipt flow
\- certified hardware terminal flow
\- provider-specific SDK isolation
\- future multi-provider expansion

This document does not implement kiosk code, POS provider adapters, payment APIs, Android WebView, Windows programs, hardware drivers, or KDS bridge code.

It defines future module boundaries only.

\---

\#\# 2\. Scope

This document covers:

\- Mini Kiosk module boundary
\- full Kiosk module boundary
\- provider integration module boundary
\- payment UI versus payment truth
\- order creation versus KDS ticket boundary
\- provider-specific SDK isolation
\- Android/WebView boundary
\- Windows POS/program boundary
\- hardware terminal boundary
\- fallback/manual recovery boundary
\- provider abstraction timing
\- reusable module grouping

This document does not cover:

\- final kiosk UI
\- final mini kiosk UI
\- final Android project
\- final Windows kiosk application
\- final payment provider code
\- final SDK implementation
\- final hardware integration
\- final database schema
\- final production deployment

\---

\#\# 3\. Core Principle

Kiosk development must not collapse provider UI, payment truth, order truth, and kitchen execution into one module.

The project must follow this rule:

\> Mini Kiosk and Kiosk modules may collect customer intent, display provider payment UI, and send handoff requests, but final payment truth, POS/order truth, and KDS execution truth must remain in controlled backend/runtime boundaries.

A kiosk is an input surface.

It is not the owner of payment truth.

It is not the owner of KDS truth.

\---

\#\# 4\. Source Documents

This policy reuses:

\- 05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog
\- 05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog
\- 05061_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog
\- 05081_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog
\- 05091_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog
\- 05096_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping
\- 05170 PAYCO POS Integration Implementation Approach And Official Verification Policy
\- 05180 POS Payment Provider Integration Priority Matrix And Openness Assessment Policy
\- 05190_Policy_MVP_Provider_Cutline_And_Phase_2_POS_Expansion_Deferral
\- 05200_Policy_POS_Payment_Provider_Document_Folder_Grouping_And_Kiosk_Reuse

\---

\#\# 5\. Future Kiosk Module Families

Future kiosk development should be split into the following module families:

| Module Family | Purpose |
| \------------- | \------- |
| Kiosk Shell Module | Device shell, display, session, UI container |
| Menu Display Module | Menu projection, sold-out status, availability |
| Cart Module | Customer order intent and cart state |
| Payment UI Module | Provider payment UI or payment request surface |
| Payment Backend Module | Server-side reservation, approval, verification |
| Provider Adapter Module | Toss, PAYCO, OKPOS, or other provider-specific logic |
| Order Handoff Module | Converts verified order/payment state to handoff candidate |
| KDS Bridge Module | Creates kitchen ticket through controlled bridge |
| Recovery Module | Handles failed payment, timeout, cancellation, duplicate attempts |
| Device Trust Module | Device identity, revocation, kiosk session |
| Evidence Module | Audit, test evidence, support review references |
| Deployment Module | Release gate, rollback, feature flag, provider disable |

These modules should remain separate even if implemented in one application later.

\---

\#\# 6\. Mini Kiosk Boundary

Mini Kiosk should be treated as a lightweight ordering/payment input module.

Mini Kiosk may:

\- show menu
\- accept simple order intent
\- show cart
\- start payment flow
\- display payment pending state
\- display payment success after backend verification
\- display pickup/order number
\- allow cancellation before defined cutoff
\- send customer request to backend
\- recover from timeout or duplicate tap

Mini Kiosk must not:

\- approve payment by itself
\- mark refund complete
\- create KDS ticket directly
\- mutate payment state directly
\- store provider secrets
\- store long-lived customer identity secret
\- override sold-out state
\- override kitchen state
\- resolve provider mismatch
\- bypass backend merchant/store mapping
\- bypass audit/evidence logging

\---

\#\# 7\. Full Kiosk Boundary

Full Kiosk may include broader hardware and operational features.

Full Kiosk may:

\- run on Android tablet, Windows kiosk, or certified kiosk hardware
\- show expanded menu
\- accept complex order options
\- integrate payment UI or device
\- print receipt where certified
\- show order status
\- support staff intervention
\- support local recovery flow
\- support accessibility and multilingual UI

Full Kiosk must not:

\- treat local print as backend truth
\- treat card reader success as final without provider/backend verification
\- bypass payment reconciliation
\- bypass KDS bridge
\- directly control uncertified terminal hardware
\- store provider credentials locally
\- silently retry payment approval
\- silently duplicate KDS ticket
\- silently cancel paid order after kitchen start
\- merge customer identity
\- expose support/admin functions to customer surface

\---

\#\# 8\. Payment UI Versus Payment Truth

Kiosk payment UI is not payment truth.

Payment UI states:

\- payment method selected
\- provider page opened
\- QR/barcode shown
\- app bridge launched
\- WebView redirected
\- customer returned from provider
\- local UI shows pending
\- local UI shows user cancelled

These are UI states only.

Payment truth states must come from backend/provider verification:

\- payment reservation created
\- payment authentication callback received
\- payment approval requested
\- payment approved
\- payment failed
\- payment cancelled
\- refund requested
\- refund approved
\- settlement reconciled

Kiosk UI may display payment state only after backend state is known or clearly marked pending.

\---

\#\# 9\. Order Intent Versus KDS Ticket

Customer order intent is not KDS ticket.

Order state separation:

| Stage | Meaning |
| \----- | \------- |
| Cart | Customer selected items |
| Order Intent | Customer submitted intended order |
| Payment Pending | Payment flow started |
| Payment Verified | Backend verified payment according to policy |
| Handoff Candidate | Order is eligible for POS/KDS handoff |
| KDS Ticket Created | Kitchen execution begins |
| KDS Accepted | Kitchen acknowledged |
| Fulfilled | Kitchen/store completed |

Mini Kiosk and Kiosk may create cart/order intent.

Only the backend bridge may create KDS ticket.

\---

\#\# 10\. Provider Adapter Boundary

Each provider must be isolated behind a provider adapter boundary.

Provider adapter may:

\- format provider request
\- parse provider callback
\- map provider event ids
\- handle provider-specific error codes
\- map provider merchant/store identifiers
\- apply provider rate limit rule
\- create provider-specific evidence
\- request backend payment approval

Provider adapter must not:

\- define Yoonsul core payment state alone
\- create KDS ticket directly
\- bypass idempotency
\- bypass audit
\- expose provider secret to UI
\- assume provider cancel equals refund
\- assume provider login equals Yoonsul identity
\- normalize away important provider differences

Provider-specific differences must remain visible until proven safe.

\---

\#\# 11\. Toss Reuse In Kiosk

Toss-related documents should be reused for:

\- backend Open API/Webhook integration
\- merchant/store mapping
\- payment/order event verification
\- idempotency/replay handling
\- rate limit pacing
\- KDS handoff candidate
\- future Apps in Toss / device runtime review

Toss should not be used to justify:

\- client-side payment truth
\- direct KDS mutation
\- Apps in Toss miniapp implementation before official verification
\- universal provider abstraction before PAYCO or second provider is verified

Recommended Toss kiosk role:

    backend-first provider adapter, then optional embedded runtime later.

\---

\#\# 12\. PAYCO Reuse In Kiosk

PAYCO-related documents should be reused for:

\- backend payment reservation and approval boundary
\- Android WebView / PAYCO app bridge review
\- PAYCO login versus payment separation
\- Windows Smart Order as external channel
\- cancellation/refund boundary
\- CHECKOUT callback deferral
\- hardware terminal deferral

PAYCO should not be used to justify:

\- treating login as payment
\- treating reservation as payment
\- treating auth callback as final approval
\- treating Smart Order print as backend truth
\- direct Windows program ingestion without official contract
\- direct hardware terminal control without certification

Recommended PAYCO kiosk role:

    payment backend candidate, Android/WebView deferred until selected, Windows Smart Order external.

\---

\#\# 13\. OKPOS And Other POS Reuse In Kiosk

OKPOS and other POS providers remain Phase 2 investigation-only.

For kiosk planning, they may inform:

\- future provider candidate register
\- provider openness scoring
\- hardware/API availability comparison
\- franchise expansion path
\- multi-provider abstraction trigger

They must not influence MVP kiosk architecture unless officially selected.

No OKPOS-specific kiosk module should be implemented in MVP.

\---

\#\# 14\. Android/WebView Kiosk Boundary

Android/WebView payment flow may be useful for Mini Kiosk or full Kiosk.

Rules:

\- WebView must be isolated to trusted payment flow.
\- JavaScript enablement must be scoped.
\- mixed content allowance must be security-reviewed.
\- third-party cookie usage must be payment-scoped.
\- provider redirect must be verified by backend.
\- Android local storage must not contain payment secrets.
\- external app bridge result must not be final payment truth.
\- Android package visibility declarations must be provider-specific.
\- Android debug/sandbox credentials must not reach production.

Android/WebView module must have separate security review before implementation.

\---

\#\# 15\. Windows Kiosk / Windows POS Boundary

Windows kiosk or Windows POS flow may involve:

\- local receiving program
\- printer
\- speaker
\- receipt output
\- browser compatibility mode
\- serial/USB hardware
\- local user session

Rules:

\- Windows local program output is not backend truth.
\- Printer queue is not order API.
\- Receipt output is not payment approval.
\- Local UI scraping is prohibited.
\- Direct program integration requires official contract.
\- Hardware terminal control requires certification.
\- Windows kiosk must not store provider secrets in plain local files.
\- Local failure must create recoverable state.

Windows kiosk integration should remain deferred until official provider/hardware verification.

\---

\#\# 16\. Hardware Terminal Boundary

Hardware terminal integration is a separate certified lane.

Hardware examples:

\- card reader
\- QR scanner
\- barcode scanner
\- CAT terminal
\- signature pad
\- receipt printer
\- kiosk payment module

Rules:

\- Do not implement direct terminal control without certification.
\- Do not assume baud rate or protocol without device-specific documentation.
\- Do not treat device local success as payment truth without provider/backend verification.
\- Do not let hardware event create KDS ticket directly.
\- Hardware errors must create recoverable operational state.
\- Device logs must not expose payment or identity secrets.

Hardware terminal integration should be Phase 2 or later.

\---

\#\# 17\. Recovery Module Boundary

Kiosk recovery module must handle:

\- payment timeout
\- app switch failure
\- WebView failure
\- duplicate tap
\- callback delay
\- provider error
\- customer cancellation
\- order already paid
\- order payment uncertain
\- KDS ticket creation failure
\- printer failure
\- network interruption
\- device reboot
\- staff intervention

Recovery module must not silently:

\- approve payment
\- refund payment
\- cancel KDS ticket
\- duplicate KDS ticket
\- mark order fulfilled
\- hide uncertainty

Required recovery states:

\- PAYMENT\_PENDING
\- PAYMENT\_VERIFICATION\_REQUIRED
\- PAYMENT\_FAILED
\- PAYMENT\_UNCERTAIN
\- ORDER\_HANDOFF\_PENDING
\- KDS\_TICKET\_PENDING
\- KDS\_TICKET\_DUPLICATE\_BLOCKED
\- CUSTOMER\_CANCEL\_REQUESTED
\- STAFF\_REVIEW\_REQUIRED
\- SUPPORT\_REVIEW\_REQUIRED

\---

\#\# 18\. Provider Credential Boundary

Provider credentials must be backend-only unless official SDK explicitly requires a public client id.

Credential rules:

\- SellerKey stays backend-only.
\- x-secret-key stays backend-only.
\- webhook secret stays backend-only.
\- payment approval secret stays backend-only.
\- client\_secret stays backend-only unless officially public-safe, and even then must be reviewed.
\- public client id may be exposed only if provider documentation allows it.
\- production credentials never enter local kiosk storage.
\- sandbox credentials never enter production.
\- evidence must reference credential id, not value.

\---

\#\# 19\. Kiosk Evidence Requirement

Kiosk provider module must produce evidence for:

\- provider official verification
\- merchant/store mapping
\- payment reservation
\- callback verification
\- final approval verification
\- duplicate callback handling
\- KDS duplicate prevention
\- cancellation/refund boundary
\- WebView/client boundary
\- credential masking
\- device trust
\- recovery flow
\- release gate
\- rollback/disable strategy

Evidence must be reusable across Mini Kiosk and full Kiosk where possible.

\---

\#\# 20\. Module Interface Recommendation

Future module interface should separate these conceptual calls:

\- createOrderIntent
\- createPaymentReservation
\- openPaymentUi
\- receiveProviderCallback
\- verifyPayment
\- createHandoffCandidate
\- createKdsTicket
\- requestCancellation
\- requestRefundReview
\- markPaymentUncertain
\- openStaffReview
\- createEvidencePacket

These are conceptual names only.

No implementation is defined here.

\---

\#\# 21\. Provider Abstraction Timing

Provider abstraction should not be built too early.

Build provider abstraction only after:

\- Toss backend behavior is verified
\- PAYCO backend behavior is verified
\- at least two provider event/payment flows are mapped
\- common internal payment states are stable
\- KDS handoff candidate model is stable
\- idempotency model is stable
\- provider-specific differences are documented

Before that, use explicit provider-specific adapters.

\---

\#\# 22\. Kiosk MVP Recommendation

Recommended Mini Kiosk / Kiosk MVP approach:

1\. Build internal order intent and KDS handoff boundary first.
2\. Use one backend provider candidate first.
3\. Keep client payment UI isolated.
4\. Keep payment verification backend-only.
5\. Create KDS ticket only after policy validation.
6\. Keep provider-specific code isolated.
7\. Defer direct hardware control.
8\. Defer universal provider abstraction.
9\. Defer Windows program ingestion.
10\. Prepare recovery flow early.

\---

\#\# 23\. Non-Goals

This document does not define:

\- final Mini Kiosk UI
\- final Kiosk UI
\- final provider SDK code
\- final Android WebView implementation
\- final Windows kiosk implementation
\- final hardware terminal code
\- final provider abstraction interface
\- final database schema
\- final API route
\- final KDS ticket implementation
\- final payment implementation

Those belong to later controlled implementation.

\---

\#\# 24\. Readiness Check

This document is ready when the project can answer:

1\. What is Mini Kiosk allowed to do?
2\. What is Mini Kiosk forbidden to do?
3\. What is full Kiosk allowed to do?
4\. What is full Kiosk forbidden to do?
5\. How is payment UI separated from payment truth?
6\. How is order intent separated from KDS ticket?
7\. How are provider adapters isolated?
8\. How is Toss reused in kiosk planning?
9\. How is PAYCO reused in kiosk planning?
10\. How are OKPOS and other providers deferred?
11\. How is Android/WebView boundary handled?
12\. How is Windows kiosk boundary handled?
13\. How is hardware terminal boundary handled?
14\. What recovery states are required?
15\. What credential rules apply?
16\. What kiosk evidence is required?
17\. When should provider abstraction be built?
18\. What is the recommended kiosk MVP approach?

If these questions cannot be answered, Mini Kiosk and Kiosk provider module boundary planning is incomplete.

\---

\#\# 25\. Conclusion

Mini Kiosk and Kiosk development must reuse the provider integration bundle, but must not collapse runtime boundaries.

The project must preserve the following rules:

\- kiosk is an input surface, not payment truth
\- payment UI is not payment approval
\- order intent is not KDS ticket
\- backend verification is required
\- provider adapter must be isolated
\- KDS ticket must be created through controlled bridge
\- Toss should be backend-first
\- PAYCO should be payment/backend-first with WebView and Windows lanes deferred
\- OKPOS and other POS providers remain Phase 2 candidates
\- Android/WebView requires security review
\- Windows program ingestion is prohibited without official contract
\- hardware terminal control is deferred unless certified
\- recovery flow must be explicit
\- provider credentials must remain backend-only
\- provider abstraction must not be premature

This document prepares the provider integration bundle for later Mini Kiosk and full Kiosk module development.
