# 11011_Policy_Gateway_Integrity_Audit_Readiness_Check_And_Cross_Runtime_Handoff

## 1. Purpose

This document defines the readiness check, closure rule, cross-runtime handoff, build gate linkage, pilot linkage, implementation planning handoff, and future reference policy for the 00300 Gateway Integrity, Audit, Correlation, Immutable Evidence, Idempotency, Black Box Provider Boundary, and External Handoff Responsibility Separation foundation band.

The previous documents defined Gateway correlation id, transaction lifecycle traceability, immutable request/response payload evidence, masking, payload hashing, idempotency, retry, timeout, duplicate prevention, black-box responsibility separation, smoking gun evidence, Gateway handoff audit timeline, provider dispute response, external failure boundary classification, and Gateway evidence packet register policy.

This document closes the 00300 foundation band and confirms how these rules must be referenced by Payment, POS, KDS, Provider Adapter, Mini Kiosk, Delivery Platform, Redtable-type Partner, Support, Admin, Evidence, Audit, Security, AI Support Gateway, pgvector/RAG, Pilot, and Controlled Implementation Planning lanes.

This document does not implement Gateway, logging, audit storage, evidence storage, provider connector, POS connector, payment integration, local daemon, support console, Admin console, AI support gateway, or production monitoring.

It defines readiness check and cross-runtime handoff policy only.

---

## 2. Scope

This document covers:

- 00300 band closure
- Gateway integrity readiness check
- correlation readiness
- payload evidence readiness
- idempotency readiness
- retry/timeout readiness
- duplicate/stale/replay readiness
- responsibility separation readiness
- timeline readiness
- failure boundary readiness
- evidence packet readiness
- cross-runtime handoff
- build gate reference
- pilot reference
- implementation planning reference
- no-code boundary

This document does not cover:

- actual implementation
- actual schema
- actual logging pipeline
- actual provider connector
- actual POS connector
- actual payment gateway
- actual local daemon
- actual support console
- actual Admin console
- actual monitoring dashboard
- actual production incident response

---

## 3. Core Principle

Gateway integrity must be reusable across all external handoffs.

The project must follow this rule:

> Any runtime package that crosses a Yoonsul-controlled boundary into an external POS, PG, VAN, payment provider, provider adapter, delivery platform, Redtable-type partner, local daemon, store POS PC, store network, external menu projection target, or other black-box system must comply with the 00300 Gateway Integrity foundation band before implementation planning can proceed.

Gateway integrity is not a payment-only rule.

Gateway integrity is a cross-runtime defense layer.

---

## 4. 00300 Band Closure Meaning

00300 band closure means the project has defined:

- Gateway black-box principle
- correlation id lifecycle traceability
- immutable request/response payload evidence
- masking and payload hash rule
- idempotency, retry, timeout, duplicate prevention
- POS/provider responsibility separation
- smoking gun evidence
- handoff audit timeline
- provider dispute response
- external POS/PG/VAN/local daemon/store network failure boundary
- Gateway evidence packet register
- cross-runtime handoff requirements

Closure means the foundation rule exists.

Closure does not mean implementation is authorized.

---

## 5. Documents In This Band

This band includes:

| Document | Focus |
| -------- | ----- |
| `11001_Readme_Gateway_Integrity_Audit_And_Black_Box_Provider_Evidence` | band start and foundation index |
| `11002_Policy_Gateway_Correlation_Id_And_Transaction_Lifecycle_Traceability` | correlation id and lifecycle traceability |
| `11003_Policy_Immutable_Request_Response_Payload_Evidence_And_Masking` | immutable payload evidence, masking, hash, raw evidence boundary |
| `11004_Policy_Idempotency_Retry_Timeout_And_Duplicate_External_Handoff` | idempotency, retry, timeout, duplicate prevention |
| `00340 POS Provider Black Box Responsibility Separation And Smoking Gun Evidence Policy` | responsibility separation and smoking gun evidence |
| `11006_Policy_Gateway_Handoff_Audit_Timeline_And_Provider_Dispute_Response` | handoff timeline and provider dispute response |
| `11007_Policy_External_POS_PG_VAN_Local_Daemon_And_Store_Network_Failure_Boundary` | external failure boundary classification |
| `11008_Policy_Gateway_Evidence_Packet_Correlation_And_Audit_Register` | evidence packet, correlation, audit register |
| `11011_Policy_Gateway_Integrity_Audit_Readiness_Check_And_Cross_Runtime_Handoff` | readiness check and cross-runtime handoff |

---

## 6. Gateway Integrity Readiness Meaning

Gateway integrity readiness means a future implementation package can prove the following before external handoff planning deepens:

- what transaction is being traced
- what correlation id exists
- what idempotency key protects retryable operation
- what request was sent
- what response was received or not received
- what payload evidence exists
- what provider status/error code exists
- what retry/timeout/duplicate/stale handling exists
- what canonical mapping occurred
- what runtime decision occurred
- what evidence packet exists
- what audit record exists if required
- what support/Admin summary exists
- what failure boundary applies

Gateway integrity readiness is a precondition for external integration planning.

---

## 7. Readiness Status Values

Recommended readiness status values:

- `GATEWAY_INTEGRITY_NOT_STARTED`
- `GATEWAY_INTEGRITY_SOURCE_REQUIRED`
- `GATEWAY_INTEGRITY_CORRELATION_REQUIRED`
- `GATEWAY_INTEGRITY_IDEMPOTENCY_REQUIRED`
- `GATEWAY_INTEGRITY_PAYLOAD_EVIDENCE_REQUIRED`
- `GATEWAY_INTEGRITY_MASKING_REQUIRED`
- `GATEWAY_INTEGRITY_RETRY_TIMEOUT_REQUIRED`
- `GATEWAY_INTEGRITY_DUPLICATE_STALE_REQUIRED`
- `GATEWAY_INTEGRITY_TIMELINE_REQUIRED`
- `GATEWAY_INTEGRITY_EVIDENCE_PACKET_REQUIRED`
- `GATEWAY_INTEGRITY_FAILURE_BOUNDARY_REQUIRED`
- `GATEWAY_INTEGRITY_AUDIT_REQUIRED`
- `GATEWAY_INTEGRITY_BLOCKED`
- `GATEWAY_INTEGRITY_READY_FOR_PLANNING`
- `GATEWAY_INTEGRITY_APPROVED_WITH_CONDITIONS`
- `GATEWAY_INTEGRITY_DEFERRED`
- `GATEWAY_INTEGRITY_REJECTED`

Readiness status must not imply coding approval.

---

## 8. Gateway Integrity Readiness Record Fields

Each readiness record should include:

- readiness id
- source document reference
- linked runtime package id
- linked implementation package id
- external system involved
- affected runtime
- handoff type
- correlation readiness
- idempotency readiness
- payload evidence readiness
- masking readiness
- retry/timeout readiness
- duplicate/stale/replay readiness
- timeline readiness
- evidence packet readiness
- failure boundary readiness
- support/Admin summary readiness
- audit readiness
- blockers
- conditions
- status
- notes

The record must be traceable.

---

## 9. Readiness ID Format

Recommended format:

    GATEWAY-INTEGRITY-READY-[YYYYMMDD]-[NUMBER]

Example:

    GATEWAY-INTEGRITY-READY-20260612-001

Final format may be normalized later.

---

## 10. Cross-Runtime Handoff Meaning

Cross-runtime handoff means applying Gateway integrity rules to runtime packages outside the Gateway band.

Affected runtimes include:

- Payment Runtime
- Refund/Cancel Runtime
- POS Runtime
- KDS Runtime
- Provider Adapter Runtime
- Delivery Platform Adapter Runtime
- Mini Kiosk Runtime
- External Menu Projection Runtime
- Redtable-Type Partner Runtime
- Support Runtime
- Admin Runtime
- Evidence Runtime
- Audit Runtime
- Security Runtime
- AI Support Gateway Runtime
- Knowledge Retrieval Runtime
- Pilot Runtime
- Documentation Governance Runtime

Gateway integrity becomes a reference rule for these runtimes.

---

## 11. Payment Runtime Handoff Rule

Payment Runtime must reference this band when planning:

- payment request
- payment response
- payment callback
- payment timeout
- duplicate payment prevention
- stale payment callback handling
- payment uncertainty
- refund linkage
- settlement reconciliation
- support escalation
- payment dispute

Payment without Gateway integrity is blocked.

---

## 12. Refund Cancel Runtime Handoff Rule

Refund/Cancel Runtime must reference this band when planning:

- refund request
- refund response
- cancel request
- cancel response
- duplicate refund prevention
- refund timeout
- refund provider dispute
- payment/KDS dependency
- support case
- evidence packet

Refund/cancel requires traceable evidence.

---

## 13. POS Runtime Handoff Rule

POS Runtime must reference this band when planning:

- POS order submission
- POS response
- POS rejection
- POS timeout
- POS retry
- POS duplicate prevention
- POS reconciliation
- local daemon handoff
- POS vendor dispute
- store check

POS black-box integration requires smoking gun evidence.

---

## 14. KDS Runtime Handoff Rule

KDS Runtime must reference this band when planning:

- KDS ticket creation
- KDS ticket hold
- KDS release
- KDS retry
- duplicate ticket prevention
- KDS timeout
- payment dependency
- POS dependency
- manual fallback
- evidence packet

KDS must not duplicate kitchen work due to retry ambiguity.

---

## 15. Provider Adapter Runtime Handoff Rule

Provider Adapter Runtime must reference this band when planning:

- external event receipt
- webhook/callback validation
- provider signature/auth validation
- idempotency check
- duplicate/stale/replay detection
- payload evidence
- canonical event mapping
- quarantine
- provider incident
- provider dispute packet

Provider event is not truth without Gateway integrity.

---

## 16. Delivery Platform Adapter Handoff Rule

Delivery Platform Adapter must reference this band when planning:

- delivery order event
- cancellation event
- pickup/rider event
- duplicate platform event
- stale platform event
- provider mapping
- KDS impact
- customer/support recovery
- platform dispute

Delivery platform events may be resent and must be deduplicated.

---

## 17. Mini Kiosk Runtime Handoff Rule

Mini Kiosk Runtime must reference this band when planning:

- kiosk order candidate
- payment attempt
- duplicate submit
- timeout
- abandoned flow
- staff call
- POS handoff
- KDS handoff
- support case

Mini Kiosk must not create duplicate payment or duplicate order.

---

## 18. External Menu Projection Runtime Handoff Rule

External Menu Projection Runtime must reference this band when planning:

- public menu package publish
- public menu package unpublish
- Google Maps landing update
- QR/NFC menu projection
- partner menu projection
- stale content handling
- version hash
- rollback/unpublish
- external projection dispute

External public content must be versioned and evidence-linked.

---

## 19. Redtable-Type Partner Runtime Handoff Rule

Redtable-Type Partner Runtime must reference this band when planning:

- partner menu translation lookup
- partner menu dataset mapping
- partner external page projection
- global payment request
- global payment response
- partner callback
- partner settlement reference
- partner dispute
- partner capability evidence

Partner module remains external black box until verified.

---

## 20. Local Daemon Handoff Rule

Local daemon handoff must reference this band when planning:

- cloud-to-daemon request
- daemon receipt status
- daemon-to-POS request
- daemon-to-cloud response
- offline queue
- replay after reconnect
- heartbeat evidence
- store network boundary
- POS PC boundary
- local rollback

Local daemon must not blur cloud and store-side fault.

---

## 21. Support Runtime Handoff Rule

Support Runtime must reference this band when planning:

- support case lookup
- masked evidence view
- payment uncertainty support
- POS missing order support
- provider dispute support
- local daemon/store network check
- customer-safe message
- support escalation
- case closure

Support should recover from evidence, not guesswork.

---

## 22. Admin Runtime Handoff Rule

Admin Runtime must reference this band when planning:

- evidence dashboard
- provider incident review
- POS incident cluster
- store network issue cluster
- blocker register
- rollback/pause decision
- provider escalation task
- pilot incident review
- commercial impact review

Admin should coordinate from registered evidence.

---

## 23. Evidence Runtime Handoff Rule

Evidence Runtime must reference this band when planning:

- Gateway evidence packet
- payload evidence
- timeline evidence
- dispute packet
- failure boundary record
- responsibility classification
- correction/supersession
- retention placeholder

Evidence Runtime is the formal proof container.

---

## 24. Audit Runtime Handoff Rule

Audit Runtime must reference this band when planning:

- external handoff audit
- payment state audit
- KDS release audit
- support access audit
- Admin review audit
- export/unmask audit
- rollback/pause audit
- dispute closure audit

Audit must preserve append-only history.

---

## 25. Security Runtime Handoff Rule

Security Runtime must reference this band when planning:

- raw payload access
- masked evidence view
- export restriction
- provider secret masking
- token/header masking
- break-glass access
- support access policy
- AI evidence boundary
- legal/security hold

Gateway evidence must not become data leakage.

---

## 26. AI Support Gateway Handoff Rule

AI Support Gateway must reference this band when planning:

- masked evidence summary
- support case scope
- source/evidence citation
- confidence display
- no final blame
- no legal conclusion
- no raw payload access
- no runtime mutation
- human review

AI support may summarize evidence but cannot own responsibility.

---

## 27. Knowledge Retrieval Handoff Rule

Knowledge Retrieval Runtime must reference this band when planning:

- approved source lookup
- evidence summary retrieval
- SOP retrieval
- Gateway policy retrieval
- access-scoped retrieval
- citation
- freshness
- sensitive data exclusion

Knowledge retrieval does not replace audit evidence.

---

## 28. Pilot Runtime Handoff Rule

Pilot Runtime must reference this band when planning dry runs for:

- POS error
- payment timeout
- duplicate callback
- stale callback
- local daemon offline
- store network failure
- Redtable-type partner error
- delivery platform duplicate event
- external menu projection rollback
- support/Admin evidence lookup

Pilot must test Gateway integrity before exposure.

---

## 29. Documentation Governance Handoff Rule

Documentation Governance Runtime must reference this band when planning:

- source traceability
- open gap register
- blocker register
- package register
- evidence register
- readiness check
- correction/supersession
- controlled implementation entry

Documentation must preserve the foundation rule.

---

## 30. Build Gate Input Rule

Build Gate must receive Gateway integrity status for every external handoff package.

Build Gate input should include:

- correlation readiness
- idempotency readiness
- payload evidence readiness
- masking readiness
- retry/timeout readiness
- duplicate/stale/replay readiness
- canonical mapping readiness
- failure boundary readiness
- evidence packet readiness
- audit readiness
- support/Admin summary readiness
- AI evidence boundary if applicable
- rollback/fallback readiness
- blockers

Build Gate must block unsafe external handoff.

---

## 31. Controlled Implementation Planning Handoff Rule

Controlled implementation planning must include Gateway integrity requirements in package decomposition.

Package planning should identify:

- external system
- Gateway operation
- correlation id
- idempotency key
- evidence packet
- payload evidence
- provider return code
- retry/timeout policy
- duplicate/stale policy
- failure boundary
- support/Admin visibility
- audit requirement
- rollback/fallback

No package should hide Gateway risk.

---

## 32. Data Model Planning Handoff Rule

Data model planning must include candidate data for:

- correlation record
- idempotency record
- payload evidence record
- retry record
- timeout record
- duplicate/stale/replay record
- timeline record
- failure boundary record
- evidence packet record
- responsibility classification record
- dispute packet record

Data model planning must not create schema yet.

---

## 33. API RPC Event Planning Handoff Rule

API/RPC/Event planning must include contract fields such as:

- correlation id
- idempotency key
- provider request id
- provider response id
- request payload evidence reference
- response payload evidence reference
- payload hash
- provider status code
- provider error code
- attempt number
- timeout status
- retry status
- duplicate/stale/replay status
- evidence packet id
- audit event id

These are planning requirements, not implementation.

---

## 34. UI Planning Handoff Rule

UI planning must include evidence-aware surfaces for:

- Support case view
- Admin incident view
- payment uncertainty view
- POS reconciliation view
- provider incident view
- local daemon/store network issue view
- external menu projection status
- pilot incident view

UI must not expose raw restricted payload.

---

## 35. I18n Handoff Rule

I18n planning must include customer/staff/support/Admin messages for:

- payment uncertainty
- POS timeout
- KDS hold
- duplicate prevention
- provider issue
- store network check
- support escalation
- external menu stale content
- partner payment uncertainty
- retry exhausted
- reconciliation required

Gateway integrity must speak safely in every supported language.

---

## 36. Error Message Handoff Rule

Error message planning must include codes for:

- missing correlation
- missing idempotency
- payload evidence failure
- provider timeout
- duplicate callback
- stale callback
- replay detected
- POS handoff uncertain
- payment uncertain
- local daemon offline
- store network boundary uncertain
- partner callback uncertain
- evidence packet incomplete

Error messages must be traceable.

---

## 37. Support Training Handoff Rule

Support training must teach:

- correlation lookup
- evidence packet interpretation
- timeout versus failure
- duplicate/stale/replay meaning
- provider dispute packet use
- customer-safe messaging
- store check request
- Admin escalation
- no raw payload exposure
- no unsupported blame

Support must use evidence correctly.

---

## 38. Store Training Handoff Rule

Store training should explain:

- what happens when POS/network fails
- why manual re-entry may cause duplicate risk
- when staff should call support
- what store check may ask
- why local daemon/PC/router status matters
- how to avoid operator-caused ambiguity
- why customer blame is prohibited

Store training reduces dispute noise.

---

## 39. Provider Partner Handoff Rule

Provider/partner integration review must include:

- evidence requirements
- provider request id availability
- provider response id availability
- callback id availability
- error code documentation
- retry policy compatibility
- idempotency compatibility
- log request process
- dispute contact process
- settlement/reconciliation evidence if payment-related

Provider selection should consider evidence quality.

---

## 40. Commercial Handoff Rule

Commercial planning should consider Gateway integrity for:

- support burden
- provider reliability
- SLA conversation
- partner negotiation
- store onboarding
- premium support tier
- pilot pricing
- foreign payment claim
- translated menu projection claim

Commercial promises must respect evidence readiness.

---

## 41. Readiness Checklist

Gateway integrity readiness checklist:

- correlation id rule defined
- idempotency key rule defined
- payload evidence rule defined
- masking rule defined
- payload hash rule defined
- provider return code preservation defined
- timeout evidence rule defined
- retry timeline rule defined
- duplicate/stale/replay rule defined
- canonical mapping rule defined
- responsibility separation rule defined
- failure boundary rule defined
- evidence packet rule defined
- support/Admin summary rule defined
- AI evidence boundary defined
- correction/supersession defined
- build gate blocker defined
- pilot dry run defined
- no-code boundary defined

All must be satisfied before external handoff implementation planning.

---

## 42. Blocker Rule

Create blocker when:

- external handoff lacks correlation id
- retryable operation lacks idempotency key
- request/response evidence undefined
- masking undefined
- provider code not preserved
- timeout not first-class result
- duplicate/stale handling missing
- failure boundary unclear
- evidence packet missing
- support/Admin view missing
- AI evidence boundary missing if AI is involved
- customer-safe message missing
- provider evidence missing
- local daemon/store network boundary missing when applicable

Gateway blocker must stop affected package.

---

## 43. Conditional Approval Rule

Conditional approval may be allowed when:

- unresolved external handoff is excluded
- feature is disabled
- manual fallback exists
- evidence gap is documented
- no live pilot uses blocked path
- provider capability remains evidence-required
- support/Admin can identify limitation
- next review trigger exists

Conditional approval must not hide Gateway evidence gap.

---

## 44. Rejection Rule

Reject external handoff package when:

- no evidence can be produced
- no correlation can be maintained
- no idempotency is possible for retryable write
- provider response cannot be preserved
- sensitive data cannot be masked
- duplicate effect cannot be prevented
- failure boundary cannot be classified
- rollback/fallback impossible
- customer trust risk unacceptable
- provider refuses minimum evidence requirements

Rejection protects system integrity.

---

## 45. Cross-Reference Recommendation

This policy should be referenced by future or existing documents in:

- Foundation
- Security
- Audit
- Evidence
- Payment
- Refund/Cancel
- POS
- KDS
- Provider Adapter
- Delivery Platform
- Mini Kiosk
- External Menu Projection
- Redtable-type Partner Module
- Support
- Admin
- AI Support Gateway
- pgvector/RAG
- Pilot
- Controlled Implementation Planning
- Build Gate
- Commercial SaaS Planning

Gateway integrity is a shared dependency.

---

## 46. Registers Recommendation

Recommended future files:

    docs/_index/
      Gateway_Integrity_Readiness_Register.md
      Gateway_Cross_Runtime_Handoff_Register.md
      Gateway_Build_Gate_Blocker_Register.md
      External_Handoff_Package_Readiness_Register.md
      Gateway_I18n_Error_Message_Handoff_Register.md
      Gateway_Support_Training_Handoff_Register.md
      Gateway_Provider_Partner_Evidence_Register.md
      Gateway_Commercial_Risk_Handoff_Register.md

This document only recommends these files.

It does not create them.

---

## 47. Anti-Patterns

The following are prohibited:

- treating Gateway integrity as optional logging
- applying correlation only to payment
- applying idempotency only to PG callback
- storing evidence without masking
- building POS connector without failure boundary
- building provider adapter without payload evidence
- building local daemon without replay protection
- building Redtable-type partner module without provider evidence
- exposing raw payload in Support/Admin UI
- allowing AI support to assign blame
- skipping pilot dry run for timeout/duplicate/stale
- allowing commercial promise before evidence readiness
- moving to implementation planning with unresolved Gateway blocker

---

## 48. No-Code Boundary

This document does not authorize:

- Gateway implementation
- logging implementation
- evidence packet implementation
- database schema
- API/RPC contract implementation
- provider adapter
- POS connector
- payment connector
- KDS connector
- local daemon
- Redtable integration
- support console
- Admin console
- AI support gateway
- pgvector/RAG
- pilot launch
- production monitoring

This document closes Gateway integrity foundation planning only.

---

## 49. Final Readiness Check

This 00300 band is ready to close when the project can answer:

1. What documents belong to the 00300 band?
2. What is Gateway integrity readiness?
3. What readiness status values exist?
4. What fields should readiness record include?
5. What is cross-runtime handoff?
6. What Payment Runtime handoff rule applies?
7. What Refund/Cancel Runtime handoff rule applies?
8. What POS Runtime handoff rule applies?
9. What KDS Runtime handoff rule applies?
10. What Provider Adapter Runtime handoff rule applies?
11. What Delivery Platform Adapter handoff rule applies?
12. What Mini Kiosk Runtime handoff rule applies?
13. What External Menu Projection Runtime handoff rule applies?
14. What Redtable-Type Partner Runtime handoff rule applies?
15. What Local Daemon handoff rule applies?
16. What Support Runtime handoff rule applies?
17. What Admin Runtime handoff rule applies?
18. What Evidence Runtime handoff rule applies?
19. What Audit Runtime handoff rule applies?
20. What Security Runtime handoff rule applies?
21. What AI Support Gateway handoff rule applies?
22. What Knowledge Retrieval handoff rule applies?
23. What Pilot Runtime handoff rule applies?
24. What Documentation Governance handoff rule applies?
25. What Build Gate input rule applies?
26. What Controlled Implementation Planning handoff rule applies?
27. What Data Model Planning handoff rule applies?
28. What API/RPC/Event Planning handoff rule applies?
29. What UI Planning handoff rule applies?
30. What I18n handoff rule applies?
31. What Error Message handoff rule applies?
32. What Support Training handoff rule applies?
33. What Store Training handoff rule applies?
34. What Provider/Partner handoff rule applies?
35. What Commercial handoff rule applies?
36. What readiness checklist applies?
37. What blocker rule applies?
38. What conditional approval rule applies?
39. What rejection rule applies?
40. What cross-reference recommendation applies?
41. What registers are recommended?
42. What anti-patterns are prohibited?
43. What no-code boundary applies?

If these questions cannot be answered, Gateway integrity audit readiness and cross-runtime handoff planning is incomplete.

---

## 50. Conclusion

The 00300 Gateway Integrity band defines the operating shield for every external handoff.

The safe cross-runtime handoff flow is:

    external handoff package
        -> Gateway integrity readiness check
        -> correlation id
        -> idempotency key
        -> immutable masked payload evidence
        -> retry/timeout/duplicate/stale/replay handling
        -> canonical event mapping
        -> failure boundary classification
        -> evidence packet
        -> audit linkage
        -> support/Admin/AI-safe summaries
        -> build gate decision
        -> pilot dry run
        -> controlled implementation planning only if approved

This document closes the 00300 foundation band and confirms that any future POS, PG, VAN, payment provider, KDS, provider adapter, Mini Kiosk, delivery platform, Redtable-type partner, local daemon, store network, external menu projection, AI support, or pilot work must comply with Gateway integrity before implementation planning deepens.

A Gateway that only forwards messages is fragile.

A Gateway that preserves evidence, idempotency, timeline, failure boundary, and audit becomes the system's shield.