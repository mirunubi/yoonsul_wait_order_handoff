# 005150_Policy_Toss_POS_Official_Verification_Checklist_And_Integration_Evidence.md

\#\# 1\. Purpose

This document defines the official verification checklist, evidence requirements, uncertainty handling, blocker linkage, and implementation entry policy for Toss POS / Toss Place / Apps in Toss / POS Plugin SDK integration in the Yoonsul Wait/Order Handoff project.

Toss POS integration touches multiple high-risk boundaries:

\- POS order flow  
\- payment lookup  
\- payment webhook  
\- order cancellation  
\- merchant mapping  
\- Android tablet runtime  
\- Apps in Toss miniapp runtime  
\- Open API credential handling  
\- webhook secret handling  
\- rate limiting  
\- vendor integration  
\- deployment release gate

Therefore, Toss POS integration must not begin from copied notes, assumptions, screenshots, summaries, or outdated SDK references.

It must begin from verified official documentation and recorded evidence.

This document does not implement Toss POS integration.

It defines what must be verified before Toss-related implementation may begin.

\---

\#\# 2\. Scope

This document covers:

\- Toss official documentation verification checklist  
\- Toss Open API verification  
\- Toss webhook verification  
\- Toss merchant mapping verification  
\- Toss payment lookup verification  
\- Toss order cancellation verification  
\- Toss rate limit verification  
\- Toss credential verification  
\- Apps in Toss verification  
\- POS Plugin SDK verification  
\- Android sandbox verification  
\- Toss production review verification  
\- Toss evidence packet structure  
\- Toss blocker handling  
\- Toss implementation entry rule

This document does not cover:

\- final Toss API client code  
\- final webhook handler  
\- final Android app  
\- final Apps in Toss miniapp  
\- final POS Plugin SDK implementation  
\- final database schema  
\- final production deployment  
\- final CI/CD workflow

\---

\#\# 3\. Core Principle

Toss integration must be verified before it is implemented.

The project must follow this rule:

\> If a Toss behavior affects payment, order, merchant identity, webhook security, device runtime, or production release, it must be verified from official Toss documentation or approved Toss partner evidence before implementation.

User-provided summaries may guide planning.

They are not enough for production implementation.

\---

\#\# 4\. Source Documents

This policy is based on:

\- 05096_Policy_Toss_POS_Integration_Implementation_Approach_And_Test_Mapping  
\- 05100_Policy_Test_Catalog_Lane_Index_Readiness_Check_And_Evidence_Handoff  
\- 05111_Implementation_Readiness_Backlog_And_Test_Execution_Planning_Policy  
\- 05121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix  
\- 05131_Evidence_Packet_Template_And_Test_Result_Recording_Policy  
\- 05141_Policy_Blocker_Register_Waiver_Deferred_Scope_And_Risk_Acceptance  
\- 05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog  
\- 05081_Policy_Vendor_Partner_Access_External_Integration_Test_Catalog  
\- 05091_Policy_Secure_Deployment_Release_Gate_Rollback_Test_Catalog

\---

\#\# 5\. Verification Status Model

Each Toss claim must be assigned one of these statuses:

\- \`NOT\_CHECKED\`  
\- \`OFFICIAL\_VERIFIED\`  
\- \`OFFICIAL\_CONFLICT\`  
\- \`PARTNER\_CONFIRMED\`  
\- \`SANDBOX\_VERIFIED\`  
\- \`PRODUCTION\_VERIFIED\`  
\- \`PROVISIONAL\`  
\- \`OUTDATED\`  
\- \`UNKNOWN\`  
\- \`BLOCKED\`

Meaning:

| Status | Meaning |  
| \------ | \------- |  
| NOT\_CHECKED | Claim has not been checked against official source |  
| OFFICIAL\_VERIFIED | Verified from official Toss documentation |  
| OFFICIAL\_CONFLICT | Official source conflicts with current assumption |  
| PARTNER\_CONFIRMED | Confirmed by Toss partner/developer channel |  
| SANDBOX\_VERIFIED | Verified in sandbox/dev environment |  
| PRODUCTION\_VERIFIED | Verified in production or approved production review |  
| PROVISIONAL | Used for planning only, not implementation |  
| OUTDATED | Source appears obsolete |  
| UNKNOWN | Source cannot confirm or deny |  
| BLOCKED | Implementation cannot proceed until resolved |

No critical Toss integration claim may remain \`PROVISIONAL\`, \`UNKNOWN\`, or \`NOT\_CHECKED\` before implementation.

\---

\#\# 6\. Official Source Categories

Toss verification may rely on:

\- Toss Place official developer center  
\- Toss Place official documentation  
\- Toss Payments official developer documentation where payment product differs  
\- Toss official GitHub repository where applicable  
\- Toss official Notion guide where explicitly linked by Toss  
\- Toss partner onboarding email or approval document  
\- Toss sandbox console evidence  
\- Toss production review result  
\- Toss support / B2B partner confirmation

Non-official blog posts, AI summaries, copied snippets, screenshots without source, and outdated package examples must not be treated as final implementation authority.

\---

\#\# 7\. Toss Open API Verification Checklist

The following claims must be verified before backend Open API implementation.

| Item | Verification Question | Required Status |  
| \---- | \--------------------- | \--------------- |  
| API base URL | What is the current official base URL? | OFFICIAL\_VERIFIED |  
| Authentication headers | Are \`x-access-key\` and \`x-secret-key\` correct? | OFFICIAL\_VERIFIED |  
| Secret display rule | Is secret key shown only once? | OFFICIAL\_VERIFIED or PARTNER\_CONFIRMED |  
| Merchant endpoint | Is merchant lookup endpoint current? | OFFICIAL\_VERIFIED |  
| Payment lookup endpoint | Is payment lookup by paymentId current? | OFFICIAL\_VERIFIED |  
| Payment by orderId endpoint | Is lookup by orderId supported? | OFFICIAL\_VERIFIED |  
| Order cancel endpoint | Is order cancel endpoint current? | OFFICIAL\_VERIFIED |  
| Cancel authority | Does order cancel affect POS order only or financial refund? | OFFICIAL\_VERIFIED |  
| Error format | What is the structured error format? | OFFICIAL\_VERIFIED |  
| Rate limit model | Is token bucket model current? | OFFICIAL\_VERIFIED |  
| Rate limit scope | Is rate limiting merchant-scoped? | OFFICIAL\_VERIFIED |  
| Rate limit headers | Are \`x-ratelimit-\*\` headers current? | OFFICIAL\_VERIFIED |  
| Retry guidance | What is official guidance for 429/5xx? | OFFICIAL\_VERIFIED or PARTNER\_CONFIRMED |

If any Open API item is not verified, Toss backend implementation must remain blocked.

\---

\#\# 8\. Toss Webhook Verification Checklist

The following claims must be verified before webhook receiver implementation.

| Item | Verification Question | Required Status |  
| \---- | \--------------------- | \--------------- |  
| Webhook event list | What event types are supported? | OFFICIAL\_VERIFIED |  
| Payment approved event | Is \`payment.payment.approved.v1\` current? | OFFICIAL\_VERIFIED |  
| Payment cancelled event | Is \`payment.payment.cancelled.v1\` current? | OFFICIAL\_VERIFIED |  
| Delivery method | Is POST delivery current? | OFFICIAL\_VERIFIED |  
| Retry behavior | Is delivery at-least-once? | OFFICIAL\_VERIFIED |  
| Idempotency header | Is \`x-toss-webhook-id\` current and stable? | OFFICIAL\_VERIFIED |  
| Event id header | Is \`x-toss-event-id\` current? | OFFICIAL\_VERIFIED |  
| Delivery id header | Is \`x-toss-delivery-id\` current? | OFFICIAL\_VERIFIED |  
| Timestamp header | Is \`x-toss-timestamp\` current? | OFFICIAL\_VERIFIED |  
| Signature header | Is \`x-toss-signature\` current? | OFFICIAL\_VERIFIED |  
| Signature algorithm | Is HMAC-SHA256 current? | OFFICIAL\_VERIFIED |  
| Signature message | Is message format \`timestamp.rawBody\` current? | OFFICIAL\_VERIFIED |  
| Timestamp tolerance | What freshness window is recommended? | OFFICIAL\_VERIFIED |  
| Failure response | What response code triggers retry or failure? | OFFICIAL\_VERIFIED |  
| Source IP | Is \`15.165.6.198\` current or changed? | OFFICIAL\_VERIFIED |  
| IP allowlist rule | Is IP allowlist required/recommended? | OFFICIAL\_VERIFIED or PARTNER\_CONFIRMED |

Webhook implementation must not proceed without official verification of signature, timestamp, idempotency, retry, and event type behavior.

\---

\#\# 9\. Toss Merchant Mapping Verification Checklist

Before implementation, the project must verify how Toss merchant identity maps to Yoonsul tenant/store.

Required questions:

1\. Is \`merchantId\` globally unique?  
2\. Can one Toss merchant represent one store only?  
3\. Can one Toss merchant represent multiple stores?  
4\. Can a store have multiple Toss merchant ids?  
5\. Does sandbox merchantId differ from production merchantId?  
6\. Can merchantId be changed after onboarding?  
7\. Does webhook payload always include merchantId?  
8\. Does Open API path merchantId always match response merchantId?  
9\. Can Toss app/miniapp runtime expose merchant context?  
10\. How should merchant onboarding and deactivation be tracked?

Required status:

    OFFICIAL\_VERIFIED or PARTNER\_CONFIRMED

for every production mapping assumption.

\---

\#\# 10\. Toss Payment Verification Checklist

Before payment mapping implementation, verify:

\- paymentId format and stability  
\- orderId format and stability  
\- whether orderId is unique per merchant  
\- whether paymentId is unique globally or per merchant  
\- approved payment event semantics  
\- cancelled payment event semantics  
\- partial cancellation support if any  
\- refund/cancel distinction  
\- settlement impact of cancelled event  
\- timing gap between order event and payment event  
\- payment lookup consistency after webhook delivery  
\- payment by orderId lookup behavior when multiple payments exist  
\- payment lookup response fields  
\- sensitive fields that must be masked  
\- customer-facing safe status mapping

Payment verification must prove that Yoonsul can separate:

\- POS order state  
\- payment provider state  
\- refund state  
\- settlement state  
\- customer-visible status  
\- support review state

\---

\#\# 11\. Toss Order Cancellation Verification Checklist

The user-provided source indicates that order cancel API changes POS order state to \`CANCELLED\` and does not trigger actual financial card cancellation.

This must be officially verified before implementation.

Required questions:

1\. Does the order cancel API cancel POS order only?  
2\. Does it ever trigger financial refund?  
3\. Is it restricted to approved partner solutions?  
4\. What happens if payment is already approved?  
5\. What happens if KDS has already started cooking?  
6\. What happens if order is completed or served?  
7\. Is repeated cancel idempotent?  
8\. What response indicates already cancelled?  
9\. What audit/event is available after cancel?  
10\. How should failure be retried?

Until verified, Yoonsul must treat Toss order cancellation as:

    POS\_ORDER\_CANCEL\_CANDIDATE

not financial refund.

\---

\#\# 12\. Apps in Toss Verification Checklist

The following items from user-provided text must be verified before Apps in Toss implementation.

| Item | Verification Question | Required Status |  
| \---- | \--------------------- | \--------------- |  
| Runtime framework | Is 2.x mandatory? | OFFICIAL\_VERIFIED |  
| Legacy 1.x cutoff | Is 1.x registration/deployment stopped? | OFFICIAL\_VERIFIED |  
| Required package | Is \`@apps-in-toss/web-framework@2.4.1\` current? | OFFICIAL\_VERIFIED |  
| Required package | Is \`@apps-in-toss/framework@2.4.1\` current? | OFFICIAL\_VERIFIED |  
| Build command | Is \`ait build\` required? | OFFICIAL\_VERIFIED |  
| Legacy build command | Is \`granite build\` obsolete? | OFFICIAL\_VERIFIED |  
| React version | Is React 19 required/supported? | OFFICIAL\_VERIFIED |  
| React Native version | Is React Native 0.84 required/supported? | OFFICIAL\_VERIFIED |  
| Strict Mode | What strict mode constraints exist? | OFFICIAL\_VERIFIED |  
| Review process | Is miniapp review required? | OFFICIAL\_VERIFIED |  
| Distribution | How is production miniapp deployed? | OFFICIAL\_VERIFIED |  
| Sandbox | How is local sandbox run? | OFFICIAL\_VERIFIED |

If these items cannot be verified, Apps in Toss miniapp must remain deferred.

\---

\#\# 13\. POS Plugin SDK Verification Checklist

Before POS Plugin SDK usage, verify:

\- official package name  
\- current latest supported version  
\- device information API availability  
\- exact method name for device info  
\- permission requirements  
\- async behavior  
\- Android tablet support  
\- emulator support  
\- sandbox support  
\- production support  
\- storage API availability  
\- storage API security boundary  
\- whether storage is encrypted  
\- whether storage survives app reinstall  
\- whether storage is cleared on logout  
\- whether storage may contain session identifiers  
\- prohibited storage contents  
\- review/security constraints

The user-provided method example:

    posPluginSdk.device.getDeviceInfo()

must remain provisional until official verification.

\---

\#\# 14\. Android Sandbox Verification Checklist

Before Android / tablet sandbox testing, verify:

\- required Android Studio version  
\- required Android SDK tools  
\- required platform-tools path  
\- ADB command syntax  
\- debug sandbox package name  
\- whether \`adb install \-r \-t\` is still valid  
\- emulator support  
\- real tablet support  
\- USB debugging requirement  
\- production credential prohibition  
\- local storage behavior  
\- logging behavior  
\- sandbox-to-production separation  
\- debug build expiration or review requirement

ADB and sandbox notes must not be copied into production runbooks without environment warnings.

\---

\#\# 15\. Credential And Secret Verification Checklist

Verify:

\- how \`x-access-key\` is issued  
\- how \`x-secret-key\` is issued  
\- whether secret is visible only once  
\- how to rotate credentials  
\- how to revoke credentials  
\- whether separate sandbox/production credentials exist  
\- whether webhook secret is separate from Open API secret  
\- how webhook secret is issued  
\- how webhook secret is rotated  
\- how vendor access is terminated  
\- whether credential usage can be audited  
\- whether credential scope is merchant-specific  
\- whether credential scope is app-specific  
\- whether credential scope is environment-specific

Yoonsul policy:

\- all Toss secrets remain backend-only  
\- no Toss secret enters Apps in Toss miniapp  
\- no Toss secret enters Android storage  
\- no Toss secret enters logs, AI prompts, export, support notes, or evidence packets

\---

\#\# 16\. Rate Limit Verification Checklist

Verify:

\- token bucket limit  
\- bucket depth  
\- refill rate  
\- merchant-level scope  
\- endpoint-level variation if any  
\- burst handling  
\- 429 response shape  
\- reset timestamp unit  
\- \`x-ratelimit-limit\` meaning  
\- \`x-ratelimit-remaining\` meaning  
\- \`x-ratelimit-reset\` meaning  
\- retry guidance  
\- whether webhook delivery is affected by API rate limit  
\- whether sandbox rate limit differs from production

Yoonsul implementation must design merchant-scoped rate limit pacer only after verification.

\---

\#\# 17\. Production Review Verification Checklist

Before production Toss release, verify:

\- Toss partner approval requirement  
\- Apps in Toss production review requirement  
\- Open API production credential issuance  
\- webhook endpoint registration process  
\- webhook endpoint verification process  
\- IP allowlist recommendation  
\- TLS requirement  
\- domain requirement  
\- privacy/security review requirement  
\- app display review  
\- miniapp runtime review  
\- monitoring requirement  
\- failure notification channel  
\- production rollback or disabling process  
\- production support contact

No production release may proceed without production review evidence.

\---

\#\# 18\. Toss Evidence Packet Structure

Each Toss verification item must create or link an evidence packet.

Recommended Toss evidence packet fields:

\- evidence packet id  
\- verified item  
\- source category  
\- official source title  
\- official source URL or internal reference  
\- accessed date  
\- verified claim  
\- current project assumption  
\- match / conflict / unknown  
\- affected runtime  
\- affected backlog items  
\- affected blockers  
\- implementation impact  
\- reviewer  
\- sensitive data review  
\- follow-up action

Recommended evidence id format:

    EP-TOSS-\[YYYYMMDD\]-\[NUMBER\]

Examples:

    EP-TOSS-20260612-001\_open-api-auth-headers.md  
    EP-TOSS-20260612-002\_webhook-signature-rule.md  
    EP-TOSS-20260612-003\_order-cancel-boundary.md  
    EP-TOSS-20260612-004\_apps-in-toss-runtime.md

\---

\#\# 19\. Toss Verification Result Handling

\#\#\# 19.1 If Official Source Matches Assumption

Set status:

    OFFICIAL\_VERIFIED

Then:

\- link evidence packet  
\- keep blocker open until implementation test exists where needed  
\- allow controlled design planning

\#\#\# 19.2 If Official Source Conflicts With Assumption

Set status:

    OFFICIAL\_CONFLICT

Then:

\- update mapping document  
\- create or reopen blocker  
\- block implementation  
\- review downstream documents  
\- record corrected behavior

\#\#\# 19.3 If Official Source Is Missing

Set status:

    UNKNOWN

Then:

\- keep assumption provisional  
\- contact Toss partner/support if needed  
\- block production-bound implementation

\#\#\# 19.4 If Claim Is Partner Confirmed Only

Set status:

    PARTNER\_CONFIRMED

Then:

\- record partner confirmation evidence  
\- mark whether official docs still needed  
\- restrict production use if confirmation is incomplete

\#\#\# 19.5 If Verified In Sandbox

Set status:

    SANDBOX\_VERIFIED

Then:

\- record sandbox evidence  
\- still verify production difference before production release

\---

\#\# 20\. Toss Blocker Linkage

The following blockers must remain linked to Toss verification evidence.

| Blocker | Required Evidence |  
| \------- | \----------------- |  
| BLOCK-TOSS-001 | Apps in Toss / POS Plugin SDK official verification |  
| BLOCK-TOSS-002 | merchantId to tenant/store mapping evidence |  
| BLOCK-TOSS-003 | webhook signature/idempotency verification evidence |  
| BLOCK-TOSS-004 | Open API credential storage and rotation evidence |  
| BLOCK-TOSS-005 | rate limit official verification evidence |  
| BLOCK-TOSS-006 | order cancel versus financial refund evidence |

A Toss blocker cannot be closed only by reasoning.

It requires evidence.

\---

\#\# 21\. Toss Controlled Implementation Entry Rule

Toss backend implementation may enter controlled design only when:

\- Open API auth is verified  
\- webhook signature is verified  
\- webhook idempotency is verified  
\- merchant mapping approach is defined  
\- credential storage rule is defined  
\- order cancel boundary is verified or safely disabled  
\- rate limit behavior is verified  
\- evidence packets exist  
\- blockers are updated  
\- runtime owners are assigned  
\- release gate impact is known

Apps in Toss miniapp implementation may enter controlled design only when:

\- Apps in Toss runtime version is verified  
\- build/deploy process is verified  
\- POS Plugin SDK API is verified  
\- Android sandbox process is verified  
\- local storage security is verified  
\- client authority boundary is documented  
\- backend secret exclusion is documented  
\- miniapp review process is known

\---

\#\# 22\. Toss MVP Cutline Recommendation

Recommended Toss MVP cutline:

\#\#\# Include In First Toss Backend Phase

\- Toss merchant mapping  
\- Open API credential storage  
\- webhook receiver  
\- webhook signature verification  
\- webhook timestamp freshness  
\- webhook idempotency  
\- payment approved event mapping  
\- payment cancelled event mapping  
\- payment by orderId lookup  
\- rate limit pacer  
\- event quarantine  
\- audit/evidence packet

\#\#\# Defer From First Toss Backend Phase

\- Apps in Toss miniapp  
\- POS Plugin SDK device metadata  
\- Android sandbox distribution  
\- customer-facing miniapp UI  
\- AI analysis of Toss payloads  
\- external benchmark/export of Toss data  
\- automated settlement finalization  
\- advanced local agent Toss sync

This cutline reduces risk.

Deferred items must remain visible.

\---

\#\# 23\. Toss Production Release Blockers

Toss production release must be blocked if:

\- official webhook signature behavior is not verified  
\- webhook idempotency key is not verified  
\- Toss merchant mapping is unclear  
\- Open API credentials are not backend-only  
\- webhook secret storage is undefined  
\- payment approved/cancelled semantics are unclear  
\- order cancel versus refund boundary is unclear  
\- rate limit handling is undefined  
\- invalid signature test is missing  
\- duplicate webhook test is missing  
\- replay test is missing  
\- cross-tenant merchant mapping test is missing  
\- audit evidence is missing  
\- rollback/disable path is missing  
\- production Toss review is incomplete

\---

\#\# 24\. Toss Evidence Anti-Patterns

The following are not acceptable:

\- “Toss works this way” without source  
\- AI-generated summary treated as official evidence  
\- copied documentation without accessed date  
\- screenshot without URL or source context  
\- SDK method assumed from memory  
\- package version copied from old sample  
\- Apps in Toss runtime implemented before official recheck  
\- webhook handler implemented without raw body signature rule  
\- payment cancel treated as refund without verification  
\- merchantId mapped by string convention only  
\- API secret stored in client-side miniapp  
\- debug sandbox using production credentials  
\- evidence packet containing Toss secret

These anti-patterns must create blockers.

\---

\#\# 25\. Non-Goals

This document does not define:

\- final Toss API code  
\- final Toss webhook code  
\- final Apps in Toss code  
\- final POS Plugin SDK usage  
\- final Android project  
\- final merchant mapping schema  
\- final evidence storage system  
\- final deployment process  
\- final production Toss approval process

Those belong to later implementation or integration design.

\---

\#\# 26\. Readiness Check

This document is ready when the project can answer:

1\. Which Toss claims require official verification?  
2\. Which Open API claims are verified?  
3\. Which webhook claims are verified?  
4\. Which merchant mapping claims are verified?  
5\. Which payment lookup claims are verified?  
6\. Which order cancel claims are verified?  
7\. Which Apps in Toss claims remain provisional?  
8\. Which POS Plugin SDK claims remain provisional?  
9\. Which Android sandbox claims remain provisional?  
10\. How are Toss credentials verified and stored?  
11\. How is rate limit behavior verified?  
12\. How is production review verified?  
13\. What must a Toss evidence packet include?  
14\. How are conflicts with official docs handled?  
15\. Which Toss blockers require evidence?  
16\. When may Toss backend implementation enter controlled design?  
17\. When may Apps in Toss implementation enter controlled design?  
18\. What is the recommended Toss MVP cutline?  
19\. What blocks Toss production release?  
20\. What Toss evidence anti-patterns are prohibited?

If these questions cannot be answered, Toss verification planning is incomplete.

\---

\#\# 27\. Conclusion

Toss POS integration must be evidence-driven.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

\- Toss official facts must be verified before implementation  
\- user-provided notes may guide planning but cannot authorize production implementation  
\- Open API behavior must be verified  
\- webhook behavior must be verified  
\- merchant mapping must be verified  
\- payment and order cancellation semantics must be verified  
\- Apps in Toss runtime assumptions must be verified before miniapp work  
\- POS Plugin SDK assumptions must be verified before device integration  
\- Toss credentials must stay backend-only  
\- webhook secrets must stay backend-only  
\- Toss evidence packets must link source, claim, impact, blocker, and reviewer  
\- Toss blockers cannot be closed without evidence  
\- Toss backend MVP should precede Apps in Toss miniapp work  
\- Toss production release must be blocked until signature, idempotency, merchant mapping, credential, payment, audit, and rollback evidence exist

This document does not implement Toss POS integration.

It defines the official verification checklist and integration evidence policy required before Toss POS implementation may begin.