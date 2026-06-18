# 011080_Policy_PAYCO_POS_Integration_Implementation_Approach_And_Official_Verification

Legacy path: $old.

\#\# 1\. Purpose

This document records the implementation approach, official verification checklist, runtime boundary, platform separation, evidence requirement, blocker linkage, and MVP cutline for PAYCO POS / PAYCO payment / PAYCO Smart Order / PAYCO Android SDK / PAYCO Windows POS integration in the Yoonsul Wait/Order Handoff project.

PAYCO integration affects several independent lanes:

\- Windows POS smart order receiving program
\- offline POS payment device integration
\- Android WebView / PAYCO app bridge
\- PAYCO login SDK
\- PAYCO payment order reservation
\- PAYCO payment approval
\- PAYCO checkout additional shipping fee callback
\- smart order owner portal
\- partner / developer guide verification
\- backend server-to-server credential handling
\- POS/KDS handoff
\- payment/refund/settlement boundary
\- vendor integration
\- deployment gate

This document does not implement PAYCO integration.

It defines how PAYCO integration should be mapped into future implementation and test evidence planning.

\---

\#\# 2\. Source Status

The following items are treated as officially confirmed from PAYCO official or NHN public technical sources:

\- PAYCO Developers provides PAYCO login API / SDK guidance.
\- PAYCO DevCenter provides online/offline payment, order, membership, test/design guide and FAQ style integration resources.
\- PAYCO Android login guide states Android 5.1 API Level 22 or higher support.
\- PAYCO Android login guide shows Gradle dependency \`com.payco.android:payco-login:1.5.14\`.
\- PAYCO Android guide requires app registration before login usage.
\- PAYCO Android guide requires \`INTERNET\` permission and \`ACCESS\_NETWORK\_STATE\` permission for login SDK.
\- PAYCO Android guide states API 30 or higher target apps should declare \`\<queries\>\` with package \`com.nhnent.payapp\`.
\- PAYCO Android guide includes activity \`com.toast.android.paycologin.auth.PaycoLoginAuthWebViewActivity\`.
\- NHN PAYCO Android payment demo repository exists for PAYCO app payment WebView integration.
\- The Android payment demo describes \`android:usesCleartextTraffic="true"\` for HTTP pages.
\- The Android payment demo describes JavaScript enabled WebView setting.
\- The Android payment demo describes mixed content mode for http to https flow.
\- The Android payment demo describes third-party cookie acceptance for WebView payment flow.
\- PAYCO Smart Order installation guide describes \`PayCoOrderSetup.exe\` installation.
\- PAYCO Smart Order installation guide requires Windows POS or Windows notebook, speaker, printer, internet connection, and partner.payco.kr owner account.
\- PAYCO Smart Order installation guide states the POS should be turned on at store opening and the Smart Order program updates automatically.

The following items are based on user-provided source text and must be rechecked against official PAYCO / NHN / partner documentation before implementation:

\- Windows local POS module name \`PaycoPos\`
\- registry and printer driver internal control details
\- business registration number and TID binding details
\- automatic update technical behavior details beyond official smart order guide
\- ASP screen setting path such as \`마스터관리 \> POS화면구성 \> 주문화면메뉴\`
\- KCP terminal models and serial communication details
\- baud rate \`115200bps\`
\- IE mode requirement for specific legacy terminal systems
\- SellerKey / reserveOrderNo / paymentCertToken exact field names in current payment API
\- EASYPAY order reservation and approval exact request/response contract
\- CHECKOUT additional shipping callback exact current contract
\- test credential \`payco / payco1234\` applicability and environment
\- offline PAYCO POS hardware certification requirements
\- smart order receiving program production review process
\- PAYCO POS cancellation/refund semantics in offline POS scenario

Until official confirmation is completed, those items must be treated as provisional integration assumptions.

\---

\#\# 3\. Core Principle

PAYCO integration must be separated into platform and authority lanes.

The project must follow this rule:

\> PAYCO may provide payment UI, login, smart order receiving, POS-side order flow, and payment approval infrastructure, but Yoonsul must preserve its own tenant/store mapping, POS/KDS bridge boundary, payment verification, refund separation, audit evidence, and deployment gate rules.

PAYCO integration is not a single adapter.

It is a composite vendor/payment/order/device integration.

\---

\#\# 4\. PAYCO Integration Lanes

PAYCO integration should be divided into the following lanes:

1\. \*\*PAYCO Windows Smart Order Lane\*\*
   \- PayCoOrderSetup.exe
   \- Windows POS / notebook
   \- speaker
   \- printer
   \- smart order owner login
   \- local order receiving program
   \- independent operation from Yoonsul backend in early stage

2\. \*\*PAYCO Offline POS Device Lane\*\*
   \- POS payment button
   \- VAN / terminal / TID mapping
   \- barcode / QR / card reader
   \- KCP or other terminal hardware
   \- serial / USB device control
   \- requires official hardware/partner verification

3\. \*\*PAYCO Android WebView Lane\*\*
   \- Android WebView
   \- PAYCO app bridge
   \- \`com.nhnent.payapp\` package visibility
   \- JavaScript / mixed content / third-party cookie handling
   \- Android payment demo review

4\. \*\*PAYCO Login SDK Lane\*\*
   \- PAYCO login SDK
   \- OAuth-like login flow
   \- clientId / clientSecret for login
   \- login identity boundary
   \- must not be confused with payment approval

5\. \*\*PAYCO Payment Backend Lane\*\*
   \- order reservation
   \- payment authentication callback
   \- final payment approval
   \- checkout additional shipping callback
   \- server-to-server credential handling
   \- SellerKey / client\_secret handling
   \- payment audit and reconciliation

6\. \*\*Yoonsul Bridge Lane\*\*
   \- maps PAYCO order/payment signal to Yoonsul wait/order handoff
   \- creates KDS handoff candidate only after validation
   \- does not treat PAYCO client UI result as final truth

\---

\#\# 5\. Recommended Architecture

Recommended high-level architecture:

\- PAYCO Platform
  \- PAYCO app
  \- PAYCO payment gateway
  \- PAYCO smart order infrastructure
  \- PAYCO owner/partner portal
  \- PAYCO SDK / demo resources

\- PAYCO Windows Smart Order Program
  \- receives orders independently where installed
  \- prints order slips and receipts where configured
  \- may be used as operational fallback or parallel lane

\- PAYCO Android / WebView Runtime
  \- opens PAYCO payment/auth UI
  \- bridges to PAYCO app where needed
  \- must not store backend payment secrets

\- Yoonsul PAYCO Integration Gateway
  \- handles PAYCO backend API calls
  \- performs order reservation where applicable
  \- receives returnUrl/callback where applicable
  \- performs final approval where applicable
  \- validates PAYCO result
  \- maps merchant/store/order/payment references
  \- records audit/evidence
  \- quarantines ambiguous state

\- Yoonsul POS/KDS Bridge
  \- receives validated handoff candidate
  \- creates kitchen ticket only through Yoonsul authority
  \- preserves idempotency and replay safety

\- Yoonsul Payment Runtime
  \- treats PAYCO approval result as payment signal
  \- separates payment approved, payment failed, payment cancelled, refund requested, refund approved, settlement reconciled

\---

\#\# 6\. Windows Smart Order Integration Approach

The PAYCO Smart Order Windows program should be treated as an external local receiving program, not as an internal Yoonsul runtime.

Implementation direction:

\- Do not embed or modify PayCoOrderSetup.exe.
\- Do not rely on undocumented registry or printer-driver internals.
\- Treat PAYCO Smart Order program as a parallel operational input or receiving surface.
\- If Yoonsul needs to ingest PAYCO smart order data, use official API/partner interface only.
\- Do not scrape Windows program UI.
\- Do not rely on local print output as authoritative order truth.
\- Use official smart order account/portal flow where required.
\- Keep PAYCO Smart Order receiving program isolated from Yoonsul local agent unless official integration contract exists.
\- Treat Windows POS auto-update as external vendor behavior.
\- Do not assume update timing or binary behavior without evidence.

Operational interpretation:

\> PAYCO Smart Order program may help the store receive PAYCO orders, but Yoonsul must not treat local Windows print or alarm behavior as backend-verified payment/order truth.

\---

\#\# 7\. Offline POS Device / Hardware Integration Approach

The user-provided text includes VAN/TID, KCP terminal, serial/USB, barcode/QR/card reader, and baud rate assumptions.

These must remain provisional until officially verified.

Implementation direction:

\- Do not implement direct hardware control in MVP.
\- Do not assume terminal model compatibility without official partner confirmation.
\- Do not assume 115200bps setting without device-specific guide.
\- Do not assume IE mode requirement as general PAYCO requirement.
\- Treat VAN/TID registration as external POS/payment provider setup.
\- Treat card reader / QR / barcode device as certified hardware lane.
\- Prefer official PAYCO/KCP/VAN partner integration contract.
\- Avoid direct serial control unless certified and isolated.
\- Do not connect device control directly to Yoonsul payment truth without backend verification.

MVP recommendation:

    Defer direct PAYCO offline hardware control.

Use backend payment/order verification first.

\---

\#\# 8\. Android WebView / PAYCO App Bridge Approach

Official NHN PAYCO Android demo and login documentation confirm several Android integration requirements.

Future implementation must verify exact current payment flow before coding.

Implementation direction:

\- Android WebView may be used to load merchant payment page or PAYCO payment flow.
\- JavaScript must be enabled only for trusted payment flow pages.
\- Mixed content must be carefully reviewed because allowing mixed content increases security risk.
\- Third-party cookies may be required for payment continuity but must be scoped to payment WebView.
\- Android package visibility for \`com.nhnent.payapp\` must be declared when target SDK requires it.
\- PAYCO app bridge must be treated as user authentication/payment UI transition, not backend approval.
\- WebView result must not directly mark payment final.
\- Backend must verify final payment approval.
\- Client app must not store SellerKey, client\_secret, payment approval secrets, or server-side credentials.
\- Any WebView redirect/callback must be treated as untrusted until backend verification.

Security interpretation:

\> Android WebView may assist PAYCO payment flow, but final approval must remain server-side.

\---

\#\# 9\. PAYCO Login SDK Boundary

PAYCO login SDK must be separated from PAYCO payment.

Login provides identity/authentication context.

Payment provides financial transaction context.

Rules:

\- PAYCO login success does not mean payment success.
\- PAYCO login identity must not be treated as CI/DI replacement without explicit identity verification policy.
\- PAYCO login clientId/clientSecret handling must follow SDK guidance and security review.
\- PAYCO login data must be mapped to Yoonsul customer identity only through controlled identity linkage.
\- Login callback must be validated.
\- Account merge must require Yoonsul identity policy.
\- PAYCO login tokens must not enter export, AI prompt, support notes, or audit payload without masking.

Required tests:

\- login callback validation
\- login failure handling
\- package mismatch handling
\- client secret exposure review
\- account merge denial by default
\- logout/session expiration handling

\---

\#\# 10\. PAYCO Payment Backend Lane

PAYCO payment backend flow should be handled as server-to-server authority.

Recommended conceptual flow:

1\. Customer selects PAYCO payment in Yoonsul order flow.
2\. Yoonsul frontend sends order intent to Yoonsul backend.
3\. Yoonsul backend creates payment reservation with PAYCO.
4\. PAYCO returns reservation/order reference and payment URL or payment UI data.
5\. Customer completes PAYCO authentication/payment UI.
6\. PAYCO returns result to Yoonsul returnUrl/callback.
7\. Yoonsul backend validates callback result.
8\. Yoonsul backend performs final payment approval call where applicable.
9\. Yoonsul payment runtime records verified result.
10\. Yoonsul POS/KDS bridge creates or updates handoff candidate only after payment/order policy validation.

Boundary rule:

\> Client callback is not final payment truth. Server-side PAYCO approval and verification are required before final payment state.

\---

\#\# 11\. PAYCO EASYPAY Separation Rule

The user-provided text describes an authentication and approval separated mode.

Yoonsul must preserve this separation.

Recommended states:

\- PAYCO\_ORDER\_RESERVATION\_REQUESTED
\- PAYCO\_ORDER\_RESERVATION\_CREATED
\- PAYCO\_PAYMENT\_UI\_OPENED
\- PAYCO\_AUTH\_CALLBACK\_RECEIVED
\- PAYCO\_AUTH\_CALLBACK\_VALIDATED
\- PAYCO\_APPROVAL\_REQUESTED
\- PAYCO\_PAYMENT\_APPROVED
\- PAYCO\_PAYMENT\_FAILED
\- PAYCO\_PAYMENT\_CANCELLED
\- PAYCO\_PAYMENT\_RECONCILIATION\_REQUIRED

Rules:

\- Reservation is not payment.
\- Payment UI open is not payment.
\- Auth callback is not payment approval.
\- Final approval response is payment signal.
\- Payment signal still requires Yoonsul idempotency and audit.
\- KDS ticket should not be created from reservation alone unless project explicitly allows unpaid kitchen preparation.
\- If unpaid preparation is allowed later, it must be a separate risk-controlled policy.

\---

\#\# 12\. PAYCO CHECKOUT Additional Shipping Callback

The user-provided text describes additional shipping fee lookup in CHECKOUT mode.

For Yoonsul store pickup / dine-in / wait-order handoff, this is likely out of MVP scope.

Rules:

\- CHECKOUT additional shipping callback should be deferred unless Yoonsul delivery commerce is enabled.
\- If enabled later, callback must be treated as external vendor callback.
\- Callback input such as zipCode and address must be minimized and protected.
\- Address data must not enter KDS.
\- Address data must not enter AI or export without policy.
\- Shipping fee calculation must be idempotent and auditable.
\- Fee response must not mutate payment final state alone.

Deferred scope candidate:

    DEFER-PAYCO-003 CHECKOUT additional shipping fee callback

\---

\#\# 13\. PAYCO Merchant / Store Mapping Policy

PAYCO integration requires a mapping between PAYCO merchant/payment identifiers and Yoonsul tenant/store context.

Candidate mapping fields:

\- payco\_seller\_key\_reference
\- payco\_merchant\_id where applicable
\- payco\_partner\_id where applicable
\- payco\_order\_channel
\- payco\_store\_identifier
\- tenant\_id
\- store\_id
\- legal\_entity\_id where applicable
\- operating\_group\_id where applicable
\- environment
\- credential\_reference\_id
\- status
\- active\_from
\- active\_until
\- last\_verified\_at

Rules:

\- Unknown PAYCO merchant/store reference must be quarantined.
\- Sandbox and production identifiers must be separated.
\- One PAYCO account must not default to tenant-wide access.
\- Merchant/store mapping changes must be audited.
\- Mapping must be verified before payment or order event is accepted.
\- Windows Smart Order account mapping must not be assumed equal to backend payment mapping unless verified.

\---

\#\# 14\. Credential And Secret Handling

PAYCO-related secrets may include:

\- SellerKey
\- client\_secret
\- client\_id where sensitive
\- payment approval credentials
\- login SDK credentials
\- partner API credentials
\- sandbox credentials
\- production credentials
\- TID / terminal credential where sensitive
\- VAN configuration secret where applicable

Rules:

\- Server-side payment credentials must be backend-only.
\- SellerKey or equivalent signing/approval key must not be stored in Android app, WebView, Windows local script, support notes, export, AI prompt, or logs.
\- client\_secret must be reviewed before client use.
\- Sandbox credentials must not be used in production.
\- Production credentials must not be used in local/sandbox.
\- Credential rotation and revocation process must be verified.
\- Credential use must be auditable.
\- Evidence packets must reference credential id, not secret value.

\---

\#\# 15\. PAYCO Order / Payment / KDS Boundary

PAYCO payment integration must be mapped carefully into Yoonsul POS/KDS flow.

Rules:

\- PAYCO order reservation is not KDS ticket by default.
\- PAYCO payment auth callback is not KDS ticket by default.
\- PAYCO approval success may create handoff candidate.
\- Yoonsul bridge decides whether KDS ticket is created.
\- KDS owns kitchen execution truth.
\- PAYCO payment failure must not create KDS ticket.
\- PAYCO payment cancellation must create review if KDS already started.
\- PAYCO refund must be separated from POS/KDS cancellation.
\- PAYCO smart order print does not prove Yoonsul KDS accepted ticket.
\- Duplicate approval/callback must not duplicate KDS ticket.

\---

\#\# 16\. PAYCO Cancellation And Refund Boundary

PAYCO cancellation and refund semantics must be officially verified before implementation.

Rules:

\- Payment cancellation is not the same as order cancellation.
\- POS order cancellation is not automatically refund unless official payment API confirms it.
\- KDS cancellation is not financial refund.
\- Customer-facing refund message must be based on verified payment/refund state.
\- Repeated cancellation must be idempotent.
\- Cancel after kitchen start must create support/operations review.
\- Settlement impact must be reconciled by finance/payment runtime.

Candidate states:

\- PAYCO\_CANCEL\_REQUESTED
\- PAYCO\_CANCEL\_CALLBACK\_RECEIVED
\- PAYCO\_CANCEL\_APPROVED
\- PAYCO\_CANCEL\_FAILED
\- PAYCO\_REFUND\_REVIEW\_REQUIRED
\- PAYCO\_KDS\_CANCEL\_MISMATCH
\- PAYCO\_SETTLEMENT\_RECONCILIATION\_REQUIRED

\---

\#\# 17\. PAYCO Windows Smart Order MVP Recommendation

Recommended MVP handling:

\- Do not integrate PayCoOrderSetup.exe directly into Yoonsul runtime.
\- Treat PAYCO Smart Order receiving program as external store operation tool.
\- Use it as a fallback/parallel operational channel if a store already uses PAYCO Smart Order.
\- Do not read local files, registry, printer queue, or UI from PAYCO program.
\- Do not treat printed order sheet as payment truth.
\- If API integration is needed, request official PAYCO partner integration details.
\- Keep Yoonsul POS/KDS bridge independent.

MVP status:

    DEFER-PAYCO-001 Windows Smart Order direct ingestion

\---

\#\# 18\. PAYCO Android MVP Recommendation

Recommended MVP handling:

\- Defer custom Android PAYCO payment WebView unless Yoonsul customer app requires PAYCO payment in MVP.
\- If Android payment is needed, implement backend-first order reservation and approval.
\- Use Android WebView only as payment UI bridge.
\- Do not store payment credentials in Android.
\- Do not treat WebView redirect as final payment.
\- Verify PAYCO app package bridge behavior.
\- Verify third-party cookie and mixed content risk.
\- Keep Android payment UI isolated from staff/KDS device trust.

MVP status:

    DEFER-PAYCO-002 Android PAYCO WebView until backend payment flow is verified

\---

\#\# 19\. PAYCO Backend MVP Recommendation

Recommended backend MVP if PAYCO payment is selected:

Include:

\- official PAYCO API verification
\- merchant/store mapping
\- credential storage
\- order reservation
\- returnUrl/callback handling
\- final approval call
\- idempotency
\- duplicate callback handling
\- payment state mapping
\- audit/evidence
\- support review state
\- KDS handoff candidate after approval

Exclude:

\- direct Windows program integration
\- direct hardware terminal control
\- CHECKOUT shipping callback
\- AI analysis of PAYCO payload
\- export/benchmark of PAYCO data
\- automated settlement finalization
\- Apps in Toss style embedded platform assumptions
\- local agent PAYCO sync

\---

\#\# 20\. PAYCO Required Official Verification Checklist

Before PAYCO implementation, verify:

1\. Current PAYCO payment API guide version.
2\. Current order reservation endpoint.
3\. Current final approval endpoint.
4\. Current cancellation/refund endpoint.
5\. Required parameters and signatures.
6\. SellerKey handling.
7\. client\_id/client\_secret handling.
8\. returnUrl/callback contract.
9\. paymentCertToken or equivalent current field.
10\. reserveOrderNo or equivalent current field.
11\. idempotency guidance.
12\. duplicate callback behavior.
13\. error code structure.
14\. sandbox endpoint and credentials.
15\. production credential issuance.
16\. smart order API availability.
17\. Windows smart order program integration boundary.
18\. Android payment demo currency.
19\. PAYCO app package bridge behavior.
20\. WebView security requirements.
21\. CHECKOUT shipping callback applicability.
22\. settlement/refund reporting.
23\. production review requirements.
24\. support escalation channel.

No PAYCO production-bound implementation should begin until these are verified or explicitly deferred.

\---

\#\# 21\. PAYCO-Specific Test Mapping

PAYCO integration requires coverage from existing catalogs:

\- 04981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog
\- 04991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy
\- 05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog
\- 05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog
\- 05021_Policy_CI_DI_Identity_Callback_Masking_Leakage_Test_Catalog
\- 05031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog
\- 05041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog
\- 05061_Policy_Export_Report_Benchmark_External_Sharing_Test_Catalog
\- 05071_Policy_AI_Analytics_Dataset_Minimization_Recommendation_Boundary_Test_Catalog
\- 05081_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog
\- 05091_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog
\- 05131_Evidence_Packet_Template_And_Test_Result_Recording_Policy
\- 05141_Policy_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance
\- 05161_Policy_Controlled_Implementation_Entry_Gate_And_Build_Authorization

PAYCO must not bypass any of these runtime boundaries.

\---

\#\# 22\. PAYCO-Specific Required Tests

Required tests:

1\. PAYCO order reservation does not mark payment approved.
2\. PAYCO payment UI opened does not mark payment approved.
3\. PAYCO auth callback does not mark payment approved without final approval.
4\. PAYCO final approval success maps to payment approved.
5\. Duplicate callback does not duplicate payment state.
6\. Duplicate approval response does not duplicate KDS ticket.
7\. Failed approval does not create KDS ticket.
8\. Unknown merchant/store mapping is quarantined.
9\. Cross-tenant mapping is denied.
10\. Sandbox credential is denied in production.
11\. Production credential is denied in sandbox/local.
12\. SellerKey or secret does not appear in logs.
13\. SellerKey or secret does not enter Android app.
14\. WebView redirect is treated as untrusted until backend validation.
15\. PAYCO login success does not mean payment success.
16\. PAYCO order cancellation does not automatically mean refund unless verified.
17\. Cancel after KDS start creates review.
18\. CHECKOUT shipping callback is disabled if not in scope.
19\. Windows Smart Order direct ingestion is disabled if not officially integrated.
20\. PAYCO evidence packet links official verification.
21\. PAYCO release gate blocks missing official verification.

\---

\#\# 23\. PAYCO Evidence Requirements

PAYCO evidence packets must include:

\- official document reference
\- accessed date
\- verified claim
\- affected runtime
\- affected backlog item
\- affected blocker
\- merchant/store mapping decision
\- credential storage decision
\- order reservation behavior
\- callback behavior
\- final approval behavior
\- cancellation/refund behavior
\- Android/WebView behavior where applicable
\- Windows Smart Order behavior where applicable
\- sandbox/production separation
\- reviewer
\- follow-up action

PAYCO evidence must not include:

\- SellerKey
\- client\_secret
\- production credential
\- sandbox credential value
\- payment token
\- raw customer personal data
\- raw provider payload
\- full card data
\- TID secret or VAN secret where sensitive
\- support note containing secrets
\- AI prompt containing payment data

\---

\#\# 24\. PAYCO Blockers

Initial PAYCO blockers:

| Blocker ID | Severity | Description |
| \---------- | \-------- | \----------- |
| BLOCK-PAYCO-001 | High | PAYCO official payment API version must be verified |
| BLOCK-PAYCO-002 | Critical | PAYCO order reservation and final approval boundary must be verified |
| BLOCK-PAYCO-003 | Critical | PAYCO credential storage and secret handling must be defined |
| BLOCK-PAYCO-004 | Critical | PAYCO merchant/store mapping must be defined |
| BLOCK-PAYCO-005 | High | PAYCO cancellation/refund semantics must be verified |
| BLOCK-PAYCO-006 | High | PAYCO Android WebView / app bridge behavior must be verified before Android implementation |
| BLOCK-PAYCO-007 | High | PAYCO Windows Smart Order direct integration must be deferred or officially verified |
| BLOCK-PAYCO-008 | Medium | CHECKOUT additional shipping callback must be deferred unless delivery commerce is in scope |
| BLOCK-PAYCO-009 | Critical | PAYCO payment/KDS idempotency tests must be defined before KDS handoff |
| BLOCK-PAYCO-010 | Critical | PAYCO production release gate must require evidence |

\---

\#\# 25\. PAYCO Deferred Scope Candidates

Recommended deferred scope:

| Deferred ID | Runtime | Deferred Scope |
| \----------- | \------- | \-------------- |
| DEFER-PAYCO-001 | Windows Smart Order | Direct ingestion from PayCoOrderSetup.exe |
| DEFER-PAYCO-002 | Android | Custom Android PAYCO WebView payment UI |
| DEFER-PAYCO-003 | CHECKOUT | Additional shipping fee callback |
| DEFER-PAYCO-004 | Hardware | Direct CAT / barcode / QR terminal control |
| DEFER-PAYCO-005 | AI | AI analysis of PAYCO payment/order payload |
| DEFER-PAYCO-006 | Export | External export/benchmark of PAYCO data |
| DEFER-PAYCO-007 | Settlement | Automated PAYCO settlement finalization |

Deferred items must remain visible.

\---

\#\# 26\. PAYCO Controlled Implementation Entry Rule

PAYCO backend payment implementation may enter controlled design only when:

\- current official PAYCO payment API guide is verified
\- order reservation behavior is verified
\- final approval behavior is verified
\- callback behavior is verified
\- credential storage rule is defined
\- merchant/store mapping rule is defined
\- duplicate callback handling is defined
\- cancellation/refund semantics are verified or disabled
\- KDS handoff boundary is defined
\- evidence packet exists
\- blockers are reviewed
\- runtime owners are assigned
\- release gate impact is known

PAYCO Android implementation may enter controlled design only when:

\- Android guide is verified
\- PAYCO app bridge behavior is verified
\- WebView security settings are reviewed
\- client-side secret prohibition is documented
\- backend approval boundary is documented
\- payment UI is separated from final payment truth

PAYCO Windows Smart Order implementation may enter controlled design only when:

\- official Smart Order integration contract is verified
\- program behavior is officially documented
\- ingestion method is official
\- local program scraping is prohibited
\- printer/alarm behavior is not treated as payment truth

\---

\#\# 27\. PAYCO Production Release Blockers

PAYCO production release must be blocked if:

\- payment API guide is not verified
\- order reservation/final approval boundary is unclear
\- credential storage is undefined
\- merchant/store mapping is undefined
\- callback duplicate handling is undefined
\- cancellation/refund boundary is unclear
\- Android WebView stores or exposes secrets
\- Windows Smart Order direct ingestion is attempted without official contract
\- KDS ticket can be duplicated by callback/replay
\- payment failure can create KDS ticket
\- PAYCO login identity is merged without identity policy
\- evidence packet is missing
\- release gate does not include rollback/disable strategy

\---

\#\# 28\. PAYCO Implementation Anti-Patterns

The following are prohibited:

\- treating PAYCO login as payment success
\- treating PAYCO order reservation as payment success
\- treating PAYCO auth callback as final approval
\- creating KDS ticket before payment policy allows it
\- storing SellerKey in Android app
\- storing client\_secret in WebView or local storage without review
\- logging PAYCO credential
\- using sandbox credential in production
\- using production credential in sandbox
\- scraping PAYCO Windows program UI
\- reading PAYCO local printer queue as order API
\- treating printed smart order slip as backend order truth
\- treating POS order cancel as refund without verification
\- enabling CHECKOUT shipping callback unintentionally
\- sending PAYCO payload to AI without minimization
\- exporting PAYCO payment data without masking
\- bypassing release gate because PAYCO is a known provider

\---

\#\# 29\. Comparison With Toss POS Integration

PAYCO and Toss integration should share common governance but differ in platform details.

| Area | Toss POS | PAYCO |
| \---- | \-------- | \----- |
| Backend API | Toss Place Open API | PAYCO payment / order APIs |
| Webhook | Toss signed webhook | PAYCO callback/returnUrl or API result, exact webhook model must be verified |
| Merchant Mapping | Toss merchantId | PAYCO SellerKey / merchant/store/channel identifiers |
| Android Runtime | Apps in Toss / POS Plugin SDK | PAYCO app bridge / Android WebView / login SDK |
| Windows Runtime | Not primary in current Toss doc | Smart Order receiving program |
| Payment Boundary | webhook/payment lookup | reservation/auth callback/final approval |
| Cancellation Boundary | POS order cancel vs financial refund | order/payment/refund semantics must be verified |
| MVP Risk | webhook/merchant mapping | reservation/approval separation and Windows/Android lane confusion |

Shared rules:

\- backend secrets only
\- tenant/store mapping required
\- idempotency required
\- audit required
\- evidence required
\- release gate required
\- client UI is not final payment truth

\---

\#\# 30\. Non-Goals

This document does not define:

\- final PAYCO API client
\- final PAYCO payment schema
\- final Android WebView code
\- final PAYCO login implementation
\- final Windows Smart Order integration
\- final KCP terminal integration
\- final VAN/TID setup
\- final checkout shipping callback
\- final settlement automation
\- final deployment pipeline

Those belong to later controlled implementation.

\---

\#\# 31\. Readiness Check

This document is ready when the project can answer:

1\. Which PAYCO facts are officially verified?
2\. Which PAYCO facts remain provisional?
3\. How is PAYCO split into Windows, Android, login, payment, and backend lanes?
4\. How is PAYCO Smart Order treated in MVP?
5\. How is direct hardware control treated?
6\. How is Android WebView treated?
7\. How is PAYCO login separated from payment?
8\. How is order reservation separated from final payment approval?
9\. How is callback treated before backend validation?
10\. How is PAYCO merchant/store mapping handled?
11\. Where are PAYCO credentials stored?
12\. How is PAYCO payment mapped to Yoonsul payment runtime?
13\. How is KDS handoff protected from premature payment states?
14\. How is cancellation/refund boundary handled?
15\. Which PAYCO tests are required?
16\. What evidence must be collected?
17\. Which PAYCO blockers are created?
18\. Which PAYCO features are deferred?
19\. When may PAYCO backend implementation enter controlled design?
20\. What blocks PAYCO production release?
21\. What PAYCO anti-patterns are prohibited?
22\. How does PAYCO differ from Toss POS integration?

If these questions cannot be answered, PAYCO integration planning is incomplete.

\---

\#\# 32\. Conclusion

PAYCO integration must be handled as a composite platform integration.

It is not only a payment button.

It includes:

\- Windows smart order receiving
\- Android PAYCO app bridge
\- PAYCO login SDK
\- backend payment reservation
\- final payment approval
\- callback validation
\- cancellation/refund separation
\- merchant/store mapping
\- credential protection
\- POS/KDS handoff boundary
\- audit/evidence
\- release gate

The Yoonsul Wait/Order Handoff project must preserve the following rules:

\- PAYCO login is not payment success
\- PAYCO reservation is not payment success
\- PAYCO auth callback is not final approval
\- backend final approval is required for payment truth
\- client WebView is not payment authority
\- Windows smart order print is not backend truth
\- direct hardware control is deferred unless officially certified
\- SellerKey and client\_secret must not leak
\- sandbox and production credentials must be separated
\- merchant/store mapping is mandatory
\- duplicate callback must not duplicate KDS ticket
\- cancellation/refund semantics must be officially verified
\- PAYCO evidence must be recorded
\- PAYCO blockers must be tracked
\- production release must be blocked without official verification and test evidence

This document does not implement PAYCO integration.

It records the PAYCO POS/payment integration implementation approach and maps it to the existing Yoonsul runtime boundary, test catalog, blocker, evidence, and controlled implementation entry policies.
