# 22013_Policy_Error_Message_Code_Namespace_I18n_And_Recovery_Traceability

## 1. Purpose

This document defines the error message code namespace, system-module-process-program-event hierarchy, severity classification, i18n readiness, user-facing copy boundary, staff-facing copy boundary, support-facing copy boundary, developer diagnostic boundary, recovery action, audit linkage, AI support linkage, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined critical blocker review, go/no-go decision, blocker categories, error message blocker rule, and error message standard reference rule.

This document expands the error message standard into a structured OS-level message code system so that operational errors can be traced across runtime, module, process, program, event, UI surface, support case, audit event, and multilingual user-facing copy.

This document does not implement error code registry, localization files, API error handlers, frontend message rendering, logging middleware, or production error monitoring.

It defines error message code namespace, i18n, and recovery traceability policy only.

---

## 2. Scope

This document covers:

- error message code hierarchy
- system namespace
- module namespace
- process namespace
- program namespace
- event namespace
- severity
- audience-specific message layers
- i18n baseline
- recovery guidance
- support traceability
- audit/log linkage
- AI customer support linkage
- security leakage boundary
- no-code boundary

This document does not cover:

- final error code implementation
- final localization files
- final translation workflow
- final monitoring platform
- final API response schema
- final frontend rendering
- final logging implementation
- final alerting implementation

---

## 3. Core Principle

Error message is an operating-system trace object.

The project must follow this rule:

> Every meaningful error must be traceable by system, module, process, program, event, severity, audience, locale, recovery action, support path, and audit/log correlation without exposing sensitive data or confusing users.

A message that cannot be traced cannot be operated.

A message that cannot be localized cannot scale.

A message that leaks internals is a security failure.

A message that gives no recovery path is a customer trust failure.

---

## 4. Error Code Hierarchy

The recommended hierarchy is:

    SYSTEM
      -> MODULE
        -> PROCESS
          -> PROGRAM
            -> EVENT
              -> SEVERITY
                -> LOCALE

This hierarchy is inspired by large operating systems and enterprise runtime logging.

The hierarchy should help answer:

- which system failed?
- which module failed?
- which process failed?
- which program or service failed?
- which event failed?
- how severe is it?
- who is the audience?
- what should the user or staff do?
- what should support search?
- what should logs correlate?

---

## 5. Error Code Format

Recommended error code format:

    YS-[SYSTEM]-[MODULE]-[PROCESS]-[PROGRAM]-[EVENT]-[SEVERITY]

Example:

    YS-PAY-KDS-HANDOFF-TICKET-DUPLICATE-E03

Another example:

    YS-AI-SUP-QUERY-RAG-SOURCE_STALE-W02

Final format may be normalized later.

---

## 6. Error Code Short Format

A shorter display-safe format may be used for user-facing copy.

Recommended short format:

    [SYSTEM]-[MODULE]-[EVENT]-[SEVERITY]

Example:

    PAY-KDS-DUPLICATE-E03

Short code should map to full code internally.

User-facing short code should not expose sensitive internals.

---

## 7. System Namespace

System namespace identifies the broad operating domain.

Recommended system codes:

- `CUS` = Customer Session System
- `TBL` = Table Session System
- `ORD` = Order System
- `PAY` = Payment System
- `REF` = Refund/Cancel System
- `KDS` = Kitchen Display System
- `POS` = POS System
- `PRV` = Provider Adapter System
- `MKO` = Mini Kiosk System
- `SUP` = Support System
- `AIS` = AI Customer Support System
- `AIG` = AI Support Gateway System
- `KNR` = Knowledge Retrieval System
- `SEC` = Security System
- `AUD` = Audit System
- `EVD` = Evidence System
- `ADM` = Admin Console System
- `COM` = Commercial System
- `BIL` = Billing System
- `PIL` = Pilot System
- `HIR` = High-Risk Operation System
- `DOC` = Documentation Governance System

System namespace must be stable.

---

## 8. Module Namespace

Module namespace identifies the subsystem inside a system.

Example modules:

- `SESSION`
- `WAITING`
- `TABLE`
- `ORDER`
- `PAYMENT`
- `REFUND`
- `CANCEL`
- `TICKET`
- `HANDOFF`
- `WEBHOOK`
- `CALLBACK`
- `MAPPING`
- `IDEMPOTENCY`
- `DUPLICATE`
- `STALE`
- `MASKING`
- `EXPORT`
- `UNMASK`
- `SUPPORT_CASE`
- `AI_QUERY`
- `RAG`
- `EVIDENCE`
- `AUDIT`
- `BILLING`
- `PILOT`
- `ALCOHOL`
- `VERIFICATION`

Module name should be concise and consistent.

---

## 9. Process Namespace

Process namespace identifies the running workflow or business process.

Example processes:

- `START`
- `JOIN`
- `CREATE`
- `VALIDATE`
- `AUTHORIZE`
- `CAPTURE`
- `RECONCILE`
- `RETRY`
- `CANCEL`
- `REFUND`
- `HOLD`
- `RELEASE`
- `ESCALATE`
- `EXPORT`
- `UNMASK`
- `QUERY`
- `RETRIEVE`
- `SUMMARIZE`
- `APPROVE`
- `REJECT`
- `SYNC`
- `IMPORT`
- `VERIFY`
- `ROLLBACK`

Process should represent operational action.

---

## 10. Program Namespace

Program namespace identifies the service, function, adapter, UI surface, or worker responsible for the event.

Examples:

- `CUSTOMER_WEB`
- `MINI_KIOSK`
- `STAFF_APP`
- `ADMIN_CONSOLE`
- `SUPPORT_CONSOLE`
- `KDS_SCREEN`
- `PAYMENT_ADAPTER`
- `POS_ADAPTER`
- `PROVIDER_ADAPTER`
- `WEBHOOK_HANDLER`
- `LOCAL_DAEMON`
- `AI_GATEWAY`
- `RAG_RETRIEVER`
- `EVIDENCE_WRITER`
- `AUDIT_WRITER`
- `EXPORT_WORKER`
- `UNMASK_REVIEWER`
- `BILLING_WORKER`

Program namespace helps locate the failing component later.

---

## 11. Event Namespace

Event namespace identifies what happened.

Example event names:

- `MISSING_CONTEXT`
- `INVALID_STATE`
- `DUPLICATE_EVENT`
- `STALE_EVENT`
- `UNMAPPED_EVENT`
- `UNAUTHORIZED_ACTION`
- `MASKING_REQUIRED`
- `EXPORT_BLOCKED`
- `UNMASK_BLOCKED`
- `PAYMENT_UNCERTAIN`
- `PAYMENT_DUPLICATE`
- `KDS_HOLD_REQUIRED`
- `KDS_RELEASE_BLOCKED`
- `PROVIDER_SIGNATURE_INVALID`
- `PROVIDER_TIMEOUT`
- `SUPPORT_SCOPE_DENIED`
- `AI_SOURCE_STALE`
- `AI_CONFIDENCE_LOW`
- `RAG_SOURCE_RESTRICTED`
- `EVIDENCE_REQUIRED`
- `ROLLBACK_REQUIRED`
- `LEGAL_REVIEW_REQUIRED`
- `SECURITY_REVIEW_REQUIRED`
- `HIGH_RISK_DISABLED`

Event namespace must avoid vague words like error, fail, issue, problem.

---

## 12. Severity Namespace

Recommended severity codes:

- `I00` = informational
- `W01` = warning, recoverable
- `W02` = warning, review needed
- `E01` = error, user can retry
- `E02` = error, staff action needed
- `E03` = error, support action needed
- `E04` = error, runtime owner action needed
- `C01` = critical, operation blocked
- `C02` = critical, security risk
- `C03` = critical, payment/KDS risk
- `C04` = critical, legal/high-risk operation
- `C05` = critical, pilot/production blocker

Severity should drive UI, support, alerting, and blocker behavior.

---

## 13. Audience Layers

Each error code may have multiple audience-specific messages.

Recommended audience layers:

- `customer_message`
- `staff_message`
- `store_manager_message`
- `support_message`
- `admin_message`
- `security_message`
- `developer_diagnostic`
- `ai_support_context`
- `audit_summary`

Each layer must respect permission and masking.

---

## 14. Customer Message Rule

Customer-facing message should be:

- simple
- respectful
- non-accusatory
- non-technical
- recovery-oriented
- localized
- short
- safe
- free of internal terms
- free of blame unless legally reviewed

Customer message should not expose:

- raw SQL
- stack trace
- provider payload
- provider secret
- CI/DI
- payment secret
- internal tenant/store id
- hidden record count
- internal permission rule

---

## 15. Staff Message Rule

Staff-facing message should be:

- operational
- action-oriented
- short enough for peak hours
- clear about next step
- clear about escalation
- safe for screen visibility
- free of unnecessary customer private data

Staff message may include:

- hold reason
- retry instruction
- call manager instruction
- check payment status instruction
- switch to manual fallback instruction
- support escalation code

Staff message should not expose raw identity data.

---

## 16. Support Message Rule

Support-facing message should include:

- full error code
- affected runtime
- support case scope
- safe diagnostic summary
- recommended recovery path
- evidence link if allowed
- escalation path
- masked customer/store context
- audit correlation id if allowed

Support message must remain case-scoped.

---

## 17. Admin Message Rule

Admin-facing message should include:

- affected tenant/store context if allowed
- affected runtime
- status
- blocker relation
- evidence relation
- review requirement
- allowed action
- prohibited action
- next workflow

Admin message must not become direct mutation authority.

---

## 18. Developer Diagnostic Rule

Developer diagnostic may include technical details only in restricted logs.

Developer diagnostic must not appear in:

- customer UI
- staff UI
- KDS screen
- public API response
- support message unless sanitized
- export without approval
- AI support answer

Developer diagnostic may include:

- internal trace id
- sanitized stack category
- function/service label
- runtime owner
- event correlation
- safe payload hash
- safe provider reference

Developer diagnostic must not contain secrets.

---

## 19. AI Support Context Rule

AI support may use error context only when:

- support case scope exists
- data is masked
- source reference is available
- freshness is known
- confidence is displayed
- human review applies
- no raw CI/DI is included
- no payment/provider secret is included
- no legal conclusion is generated

AI should explain recovery, not invent authority.

---

## 20. I18n Baseline Rule

All user-facing and staff-facing messages must be i18n-ready from the beginning.

The project should treat i18n as a baseline, not a later patch.

Minimum i18n fields:

- locale
- message key
- message template
- interpolation variables
- pluralization rule if needed
- fallback locale
- tone category
- audience
- recovery action
- forbidden terms
- review status

Default language may be Korean, but structure must allow multilingual expansion.

---

## 21. Locale Code Rule

Recommended locale format:

    [language]-[region]

Examples:

- `ko-KR`
- `en-US`
- `ja-JP`
- `zh-CN`
- `zh-TW`
- `vi-VN`
- `th-TH`
- `id-ID`
- `mn-MN`
- `uz-UZ`
- `ne-NP`
- `ru-RU`
- `fr-FR`
- `es-ES`

Final supported locales may be determined later.

---

## 22. Message Key Rule

Message key should not equal displayed message.

Recommended message key format:

    error.[system].[module].[process].[event].[audience]

Example:

    error.pay.payment.capture.payment_uncertain.customer
    error.kds.ticket.release.kds_release_blocked.staff
    error.ais.rag.retrieve.source_stale.support

Message key should remain stable even if copy changes.

---

## 23. Interpolation Variable Rule

Messages may use variables, but variables must be safe.

Allowed variables may include:

- short error code
- order short reference
- ticket short reference
- table display label
- estimated retry time
- support case short reference
- store display name
- recovery action label

Prohibited variables include:

- raw CI/DI
- full identity number
- payment secret
- provider secret
- raw provider payload
- raw SQL
- internal tenant id
- hidden record count
- sensitive evidence content

Variables must be whitelisted.

---

## 24. Tone Category Rule

Each message should have tone category.

Recommended tone categories:

- `NEUTRAL`
- `APOLOGETIC`
- `ACTION_REQUIRED`
- `STAFF_OPERATIONAL`
- `SUPPORT_DIAGNOSTIC`
- `SECURITY_RESTRICTED`
- `LEGAL_SENSITIVE`
- `HIGH_RISK_SAFETY`
- `PAYMENT_SENSITIVE`
- `KDS_OPERATIONAL`
- `AI_UNCERTAIN`

Tone category helps i18n and review.

---

## 25. Recovery Action Rule

Every meaningful error should define recovery action.

Recovery action may include:

- retry
- wait
- call staff
- switch to manual fallback
- check payment status
- hold KDS ticket
- escalate to support
- create evidence packet
- open review task
- block action
- disable feature
- rollback
- contact manager

No recovery path means poor operations.

---

## 26. Recovery Action ID Rule

Recommended recovery action id format:

    RECOVERY-[SYSTEM]-[ACTION]

Examples:

    RECOVERY-PAY-CHECK_STATUS
    RECOVERY-KDS-HOLD_TICKET
    RECOVERY-PRV-RETRY_EVENT
    RECOVERY-SUP-ESCALATE_CASE
    RECOVERY-AIS-HUMAN_REVIEW
    RECOVERY-SEC-BLOCK_EXPORT

Recovery action should be reusable across locales.

---

## 27. Error Correlation ID Rule

Each operational error should have correlation id.

Correlation id should connect:

- UI event
- runtime event
- audit event
- evidence packet
- support case
- provider event if any
- payment event if any
- KDS ticket if any
- AI support query if any

Correlation id must not expose sensitive data.

---

## 28. Audit Linkage Rule

Error event should create audit linkage when it affects:

- payment
- refund/cancel
- KDS hold/release
- provider validation
- support access
- export/unmask
- security review
- AI support access
- high-risk operation
- commercial decision
- pilot decision

Audit linkage preserves accountability.

---

## 29. Evidence Linkage Rule

Error event should link to evidence when:

- dispute may occur
- refund may occur
- KDS execution affected
- provider event uncertain
- support case opened
- customer recovery needed
- high-risk operation involved
- security access denied
- pilot incident occurs

Evidence should be masked and purpose-scoped.

---

## 30. Support Case Linkage Rule

Error event should create or link support case when:

- customer cannot recover
- payment state uncertain
- order/KDS state unclear
- provider incident affects customer
- high-risk operation involved
- repeated error occurs
- AI support cannot answer confidently
- staff escalation required

Support case should use safe message context.

---

## 31. Error To Blocker Rule

Error pattern may become blocker when:

- repeated under normal operation
- affects payment/KDS/provider truth
- exposes sensitive data
- confuses customer recovery
- blocks staff peak-hour operation
- cannot be explained by support
- lacks evidence
- lacks fallback
- lacks rollback
- affects pilot readiness

Runtime error can become governance blocker.

---

## 32. Security Leakage Prohibition

Error messages must never expose:

- raw SQL
- stack trace
- provider secret
- webhook secret
- service role key
- access token
- raw provider payload
- raw CI/DI
- identity document
- payment secret
- internal security rule
- hidden record count
- restricted tenant/store data

Security leakage through error message is a security incident.

---

## 33. Customer Blame Prohibition

Customer-facing error messages must not blame the customer unless legally and operationally reviewed.

Avoid:

- suspicious behavior detected
- you failed verification
- you are not allowed
- invalid customer
- fraud suspected
- blocked due to your action
- drunk customer
- underage customer

Prefer neutral wording:

- We need staff assistance to continue.
- This order needs a quick check by staff.
- We could not confirm this step yet.
- Please ask staff for help.

Language affects trust.

---

## 34. Stale And Uncertain State Wording Rule

Stale or uncertain state must be clearly described.

Examples:

- Payment is still being confirmed.
- Kitchen status is being refreshed.
- Provider response is delayed.
- This information may not be current.
- Staff will confirm this order.

Do not say complete, failed, or approved when state is uncertain.

---

## 35. Retry Message Rule

Retry message should define:

- whether retry is safe
- who may retry
- how many retries allowed
- whether payment may duplicate
- whether KDS may duplicate
- when support should intervene
- when action should be blocked

Retry without safety rule can create duplicate events.

---

## 36. High-Risk Message Rule

High-risk messages must be conservative.

High-risk messages may involve:

- alcohol
- adult verification
- minor access prevention
- service refusal
- staff safety
- store closure
- night operation
- delivery conflict

High-risk customer message should be neutral and staff-directed.

High-risk staff/support message should be operational and evidence-aware.

---

## 37. Payment Message Rule

Payment messages must avoid false finality.

Payment message should distinguish:

- payment pending
- payment confirmed
- payment failed
- payment uncertain
- duplicate attempt risk
- refund requested
- refund processing
- refund completed
- support review required

Payment uncertainty must not become customer blame.

---

## 38. KDS Message Rule

KDS messages must avoid customer identity exposure.

KDS message may show:

- ticket hold
- ticket release blocked
- payment check needed
- provider mapping check needed
- remake needed
- retry needed
- manual note needed

KDS should not show raw customer identity or legal verification details.

---

## 39. Provider Message Rule

Provider messages must distinguish internal and external audiences.

Customer/staff should not see raw provider diagnostics.

Support/Admin may see sanitized provider status.

Developer logs may contain restricted diagnostic metadata without secrets.

Provider raw payload should not be displayed in UI.

---

## 40. AI Support Message Rule

AI support messages should include:

- source citation
- confidence
- freshness
- human review requirement if uncertain
- escalation path
- safe recovery suggestion

AI support message should not:

- claim certainty without source
- expose sensitive data
- make legal conclusion
- approve operational action
- hide uncertainty

AI message is advisory.

---

## 41. Message Registry Fields

Each message registry entry should include:

- full error code
- short error code
- system
- module
- process
- program
- event
- severity
- audience
- locale
- message key
- message template
- interpolation variables
- recovery action id
- support action
- audit linkage
- evidence linkage
- security sensitivity
- legal sensitivity
- i18n review status
- status
- notes

Message registry is required before scale.

---

## 42. Error Code Registry Fields

Each error code registry entry should include:

- full error code
- code owner
- runtime owner
- source policy reference
- first defined date
- affected surfaces
- affected runtimes
- severity
- blocker relation
- support relation
- audit relation
- evidence relation
- deprecated status
- superseded by
- notes

Error code registry supports long-term OS governance.

---

## 43. Message Lifecycle Status Values

Recommended message lifecycle status values:

- `MESSAGE_DRAFT`
- `MESSAGE_SOURCE_REQUIRED`
- `MESSAGE_I18N_REQUIRED`
- `MESSAGE_SECURITY_REVIEW_REQUIRED`
- `MESSAGE_LEGAL_REVIEW_REQUIRED`
- `MESSAGE_SUPPORT_REVIEW_REQUIRED`
- `MESSAGE_READY_FOR_UI`
- `MESSAGE_READY_FOR_SUPPORT`
- `MESSAGE_READY_FOR_BUILD_GATE`
- `MESSAGE_DEFERRED`
- `MESSAGE_BLOCKED`
- `MESSAGE_DEPRECATED`
- `MESSAGE_SUPERSEDED`

Message status should be tracked.

---

## 44. I18n Review Status Values

Recommended i18n review status values:

- `I18N_NOT_STARTED`
- `I18N_KEY_DEFINED`
- `I18N_KO_KR_DRAFT`
- `I18N_EN_US_DRAFT`
- `I18N_TRANSLATION_REQUIRED`
- `I18N_TONE_REVIEW_REQUIRED`
- `I18N_LEGAL_REVIEW_REQUIRED`
- `I18N_SECURITY_REVIEW_REQUIRED`
- `I18N_READY`
- `I18N_DEFERRED`
- `I18N_BLOCKED`

i18n readiness must not be left until the end.

---

## 45. Localization Fallback Rule

If locale message is missing, fallback should be controlled.

Recommended fallback order:

    requested locale
        -> configured fallback locale
        -> ko-KR default
        -> safe generic message with error code

Fallback message must remain safe.

Fallback must not expose developer diagnostics.

---

## 46. Safe Generic Message Rule

Safe generic message should exist for unknown errors.

Example customer-safe message:

    요청을 처리하지 못했습니다. 잠시 후 다시 시도하거나 직원에게 문의해주세요. 오류코드: {short_error_code}

Example English customer-safe message:

    We could not complete the request. Please try again or ask staff for help. Code: {short_error_code}

Safe generic message should still provide support traceability.

---

## 47. Error Message Test Rule

Each critical error message should be tested for:

- correct code format
- correct audience layer
- correct locale fallback
- no sensitive data
- correct recovery action
- correct support linkage
- correct audit linkage
- correct evidence linkage
- no customer blame
- no false finality
- no hidden record leakage

Error message test should be part of build gate.

---

## 48. Error Message Blocker Rule

Create blocker when:

- error code hierarchy missing
- user-facing message missing
- staff recovery missing
- support traceability missing
- i18n key missing
- sensitive data may leak
- customer blame risk exists
- payment/KDS state wording ambiguous
- AI support message lacks source/freshness
- high-risk wording not reviewed

Error message blocker must be treated seriously.

---

## 49. Registers Recommendation

Recommended future files:

    docs/_index/
      Error_Code_Registry.md
      Error_Message_Registry.md
      Error_Message_I18n_Register.md
      Error_Recovery_Action_Register.md
      Error_Correlation_Register.md
      Error_Message_Blocker_Register.md
      Error_Message_Test_Register.md
      Audience_Message_Layer_Register.md
      Safe_Generic_Message_Register.md
      Message_Deprecation_Supersession_Register.md

This document only recommends these files.

It does not create them.

---

## 50. Anti-Patterns

The following are prohibited:

- unstructured free-text error messages
- one message for all audiences
- no error code
- no recovery path
- no support traceability
- no i18n key
- exposing raw SQL
- exposing stack trace
- exposing provider payload
- exposing raw CI/DI
- exposing payment/provider secrets
- blaming customer without evidence
- saying payment failed when payment is uncertain
- saying kitchen accepted when KDS is held
- letting AI support answer without source/freshness
- treating i18n as later patch

---

## 51. No-Code Boundary

This document does not authorize:

- error code implementation
- localization file creation
- frontend message rendering
- API error handler implementation
- logging middleware implementation
- monitoring system setup
- AI support message implementation
- pgvector/RAG implementation
- production deployment

This document governs message code namespace, i18n, and recovery traceability only.

---

## 52. Readiness Check

This document is ready when the project can answer:

1. What is the error code hierarchy?
2. What is the full error code format?
3. What is the short error code format?
4. What system namespaces exist?
5. What module namespace rule applies?
6. What process namespace rule applies?
7. What program namespace rule applies?
8. What event namespace rule applies?
9. What severity namespace applies?
10. What audience layers exist?
11. What customer message rule applies?
12. What staff message rule applies?
13. What support message rule applies?
14. What Admin message rule applies?
15. What developer diagnostic rule applies?
16. What AI support context rule applies?
17. What i18n baseline rule applies?
18. What locale code rule applies?
19. What message key rule applies?
20. What interpolation variable rule applies?
21. What tone category rule applies?
22. What recovery action rule applies?
23. What correlation id rule applies?
24. What audit linkage rule applies?
25. What evidence linkage rule applies?
26. What support case linkage rule applies?
27. What error-to-blocker rule applies?
28. What security leakage prohibition applies?
29. What customer blame prohibition applies?
30. What stale and uncertain wording rule applies?
31. What retry message rule applies?
32. What high-risk message rule applies?
33. What payment message rule applies?
34. What KDS message rule applies?
35. What provider message rule applies?
36. What AI support message rule applies?
37. What fields should message registry include?
38. What fields should error code registry include?
39. What message lifecycle statuses exist?
40. What i18n review statuses exist?
41. What localization fallback rule applies?
42. What safe generic message rule applies?
43. What error message test rule applies?
44. What error message blocker rule applies?
45. What registers are recommended?
46. What anti-patterns are prohibited?
47. What no-code boundary applies?

If these questions cannot be answered, error message code namespace, i18n, and recovery traceability planning is incomplete.

---

## 53. Conclusion

A large operating platform cannot rely on casual error messages.

The safe message flow is:

    system
        -> module
        -> process
        -> program
        -> event
        -> severity
        -> audience-specific message
        -> locale
        -> recovery action
        -> support/audit/evidence correlation

This document ensures that customer, staff, support, Admin, developer, AI support, payment, KDS, provider, security, legal, high-risk, and commercial error messages are traceable, safe, localizable, recoverable, and suitable for a large-scale Yoonsul operating OS.