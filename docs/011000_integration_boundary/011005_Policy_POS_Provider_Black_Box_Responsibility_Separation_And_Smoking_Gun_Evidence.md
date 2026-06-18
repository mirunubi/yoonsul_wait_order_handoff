# 011005_Policy_POS_Provider_Black_Box_Responsibility_Separation_And_Smoking_Gun_Evidence

## 1. Purpose

This document defines POS/provider black-box responsibility separation, external system boundary, smoking gun evidence, fault-domain classification, provider dispute proof, store network dispute proof, POS vendor dispute proof, PG/VAN/payment provider dispute proof, Redtable-type partner dispute proof, delivery platform dispute proof, local daemon dispute proof, and no-code boundary policy for the Yoonsul Wait/Order Handoff operating system.

The previous documents defined Gateway correlation id, transaction lifecycle traceability, immutable request/response payload evidence, masking, payload hashing, idempotency, retry, timeout, duplicate prevention, stale callback handling, replay protection, uncertainty classification, and reconciliation.

This document focuses on using those controls to separate responsibility when an external black-box system, provider, POS device, store network, local daemon, or operator action causes failure or uncertainty.

This document does not implement dispute automation, provider connector, POS connector, payment connector, local daemon, evidence storage, support console, Admin console, or production incident workflow.

It defines black-box responsibility separation and smoking gun evidence policy only.

---

## 2. Scope

This document covers:

- external black-box responsibility boundary
- smoking gun evidence standard
- fault-domain classification
- POS responsibility separation
- PG/VAN/payment provider responsibility separation
- provider adapter responsibility separation
- Redtable-type partner responsibility separation
- delivery platform responsibility separation
- local daemon responsibility separation
- store network responsibility separation
- operator action boundary
- Yoonsul runtime responsibility boundary
- dispute evidence package
- provider response proof
- no-code boundary

This document does not cover:

- final legal dispute process
- final provider contract terms
- final POS vendor escalation process
- final PG/VAN settlement dispute process
- final Redtable contract
- final production incident response implementation
- final monitoring dashboard
- final support automation

---

## 3. Core Principle

External systems are not controlled by Yoonsul, but Yoonsul must prove its own boundary.

The project must follow this rule:

> External POS, PG, VAN, payment provider, delivery platform, Redtable-type partner, local daemon, store POS PC, store network, and operator-side actions must be treated as black-box fault domains. Yoonsul Gateway must preserve enough immutable, correlation-linked, idempotency-linked, masked evidence to prove whether Yoonsul accepted, rejected, sent, received, retried, timed out, quarantined, or remained uncertain at each boundary.

The goal is not arbitrary blame.

The goal is evidence-based responsibility separation.

---

## 4. Black Box Responsibility Meaning

Black box responsibility means a system boundary where Yoonsul cannot fully inspect or control the internal behavior of the external system.

Yoonsul can prove:

- what Yoonsul generated
- what Yoonsul sent
- when Yoonsul sent it
- what Yoonsul received
- when Yoonsul received it
- what Yoonsul validated
- what Yoonsul rejected
- what Yoonsul mapped
- what Yoonsul retried
- what Yoonsul blocked as duplicate
- what remained uncertain

Yoonsul cannot directly prove hidden internal behavior inside external systems unless external evidence is available.

---

## 5. Smoking Gun Evidence Meaning

Smoking gun evidence means sufficient proof to determine the most likely fault domain.

A smoking gun evidence packet should include:

- correlation id
- idempotency key
- transaction lifecycle timeline
- request payload evidence
- response payload evidence
- request payload hash
- response payload hash
- provider request id
- provider response id
- provider status code
- provider error code
- attempt number
- retry timeline
- timeout record
- duplicate/stale classification
- canonical event mapping result
- runtime acceptance/rejection/quarantine result
- audit event id
- evidence packet id
- support/Admin summary

Smoking gun evidence should allow responsibility analysis without guesswork.

---

## 6. Responsibility Classification Values

Recommended responsibility classification values:

- `RESPONSIBILITY_YOONSUL_RUNTIME`
- `RESPONSIBILITY_GATEWAY_VALIDATION`
- `RESPONSIBILITY_PROVIDER_ADAPTER`
- `RESPONSIBILITY_EXTERNAL_POS`
- `RESPONSIBILITY_PAYMENT_PROVIDER`
- `RESPONSIBILITY_PG_VAN`
- `RESPONSIBILITY_CARD_NETWORK`
- `RESPONSIBILITY_DELIVERY_PLATFORM`
- `RESPONSIBILITY_REDTABLE_TYPE_PARTNER`
- `RESPONSIBILITY_LOCAL_DAEMON`
- `RESPONSIBILITY_STORE_NETWORK`
- `RESPONSIBILITY_STORE_POS_PC`
- `RESPONSIBILITY_OPERATOR_ACTION`
- `RESPONSIBILITY_CUSTOMER_ACTION`
- `RESPONSIBILITY_UNKNOWN`
- `RESPONSIBILITY_RECONCILIATION_REQUIRED`

Classification must be evidence-backed.

---

## 7. Fault Domain Values

Recommended fault-domain values:

- `FAULT_DOMAIN_INTERNAL_RUNTIME`
- `FAULT_DOMAIN_GATEWAY`
- `FAULT_DOMAIN_PROVIDER_ADAPTER`
- `FAULT_DOMAIN_EXTERNAL_API`
- `FAULT_DOMAIN_EXTERNAL_POS`
- `FAULT_DOMAIN_PAYMENT_PROVIDER`
- `FAULT_DOMAIN_PG_VAN`
- `FAULT_DOMAIN_CARD_NETWORK`
- `FAULT_DOMAIN_DELIVERY_PLATFORM`
- `FAULT_DOMAIN_PARTNER_MODULE`
- `FAULT_DOMAIN_LOCAL_DAEMON`
- `FAULT_DOMAIN_STORE_NETWORK`
- `FAULT_DOMAIN_STORE_DEVICE`
- `FAULT_DOMAIN_OPERATOR`
- `FAULT_DOMAIN_CUSTOMER`
- `FAULT_DOMAIN_UNKNOWN`

Fault domain should be distinct from final legal responsibility.

---

## 8. Evidence Confidence Values

Recommended evidence confidence values:

- `EVIDENCE_CONFIDENCE_HIGH`
- `EVIDENCE_CONFIDENCE_MEDIUM`
- `EVIDENCE_CONFIDENCE_LOW`
- `EVIDENCE_CONFIDENCE_INSUFFICIENT`
- `EVIDENCE_CONFIDENCE_REQUIRES_PROVIDER_LOG`
- `EVIDENCE_CONFIDENCE_REQUIRES_STORE_CHECK`
- `EVIDENCE_CONFIDENCE_REQUIRES_RECONCILIATION`

Confidence prevents overclaiming.

---

## 9. Responsibility Record Fields

Each responsibility record should include:

- responsibility record id
- correlation id
- idempotency key if applicable
- incident or dispute reference
- affected runtime
- affected external system
- fault-domain candidate
- responsibility classification
- evidence confidence
- request evidence reference
- response evidence reference
- timeout record reference
- retry record reference
- duplicate/stale record reference
- provider code
- local daemon status if applicable
- store network status if applicable
- support case reference
- Admin task reference
- final recommendation
- notes

Responsibility record must be traceable.

---

## 10. Responsibility Record ID Format

Recommended format:

    RESPONSIBILITY-[YYYYMMDD]-[NUMBER]

Example:

    RESPONSIBILITY-20260612-001

Final format may be normalized later.

---

## 11. Yoonsul Runtime Responsibility Rule

Yoonsul runtime may be responsible when evidence shows:

- internal validation incorrectly accepted invalid data
- internal state transition violated policy
- internal duplicate prevention failed
- internal idempotency was missing
- internal mapping was wrong
- internal fallback failed
- internal rollback failed
- internal i18n/error message misled user
- internal support/Admin action violated boundary

Yoonsul should not deny internal fault when evidence proves it.

Integrity includes owning true internal mistakes.

---

## 12. Gateway Validation Responsibility Rule

Gateway validation may be responsible when evidence shows:

- invalid request sent outward
- required field missing
- signature/auth validation mishandled
- idempotency key not attached
- correlation id not propagated
- payload malformed by Gateway
- provider response parsed incorrectly
- timeout classification wrong
- duplicate/stale event accepted incorrectly

Gateway is the controlled boundary.

Gateway mistakes are Yoonsul responsibility.

---

## 13. Provider Adapter Responsibility Rule

Provider Adapter may be responsible when evidence shows:

- provider event incorrectly mapped
- provider code incorrectly interpreted
- stale event accepted
- duplicate event processed
- provider capability assumed without evidence
- raw payload lost before mapping
- canonical event emitted incorrectly
- quarantine skipped

Provider Adapter must be conservative.

---

## 14. External POS Responsibility Rule

External POS fault may be indicated when evidence shows:

- valid POS request sent
- POS returned rejection/error
- POS returned timeout/no response
- POS accepted then failed to reflect state
- POS response contradicts later POS state
- POS ledger mismatch appears
- local daemon shows handoff success but POS did not persist
- POS vendor logs required for final confirmation

Yoonsul should preserve request/response proof before assigning POS fault.

---

## 15. POS Vendor Dispute Evidence Rule

POS vendor dispute packet should include:

- correlation id
- POS handoff id
- POS request evidence
- POS response evidence
- POS return code
- POS timestamp
- local daemon evidence if applicable
- retry timeline
- idempotency key
- reconciliation status
- Yoonsul mapping result
- support/Admin summary

The packet should show exactly what Yoonsul sent to POS.

---

## 16. Payment Provider Responsibility Rule

Payment provider fault may be indicated when evidence shows:

- valid payment request sent
- provider returned error
- provider timed out
- provider callback replayed
- provider sent stale callback
- provider status conflicts with settlement report
- provider response contradicts callback
- provider delayed final status
- provider logs required for final confirmation

Payment responsibility requires high evidence confidence.

---

## 17. PG VAN Responsibility Rule

PG/VAN fault may be indicated when evidence shows:

- payment provider reported PG/VAN error code
- VAN response code indicates rejection
- card network response unavailable
- provider status differs from PG/VAN settlement
- timeout occurred downstream of provider
- authorization/capture reference mismatch
- refund/cancel response mismatch

PG/VAN classification may require provider documentation.

---

## 18. Card Network Responsibility Rule

Card network fault may be indicated only when evidence or provider response explicitly identifies card network issue.

Examples:

- issuer decline code
- network unavailable code
- authorization timeout
- capture mismatch
- chargeback/dispute response
- settlement mismatch

Yoonsul should not infer card network fault without provider evidence.

---

## 19. Delivery Platform Responsibility Rule

Delivery platform fault may be indicated when evidence shows:

- platform event duplicated
- platform cancellation arrived stale
- platform pickup status inconsistent
- platform API returned error
- platform order payload malformed
- platform status contradicted later update
- provider adapter quarantined platform event
- platform support log required

Delivery platform events remain external candidates until validated.

---

## 20. Redtable-Type Partner Responsibility Rule

Redtable-type partner fault may be indicated when evidence shows:

- partner menu mapping returned incorrect or stale content
- partner API returned error
- partner payment module timed out
- partner callback duplicated
- partner global payment status conflicted
- partner settlement report mismatched
- partner external page displayed stale content
- partner capability was not as documented

All Redtable-type responsibility classification requires provider evidence.

---

## 21. Local Daemon Responsibility Rule

Local daemon fault may be indicated when evidence shows:

- cloud request was created
- daemon failed to receive
- daemon received but failed to forward
- daemon forwarded but did not return POS response
- daemon retried unsafely
- daemon local queue replayed unexpectedly
- daemon heartbeat missing
- daemon version mismatch
- daemon logs required for final confirmation

Local daemon is a boundary component and must be evidence-linked.

---

## 22. Store Network Responsibility Rule

Store network fault may be indicated when evidence shows:

- store endpoint unreachable
- local daemon offline
- POS PC unreachable
- router/internet disconnected
- DNS/TLS/connectivity failure
- repeated network timeout
- store heartbeat missing
- other cloud services available but store path failed

Store network fault must be evidence-backed, not guessed.

---

## 23. Store POS PC Responsibility Rule

Store POS PC fault may be indicated when evidence shows:

- POS PC offline
- POS application not responding
- POS PC restarted
- local daemon running but POS app unavailable
- firewall blocked local POS access
- device clock skew affected validation
- operator closed POS app

Store POS PC fault may need store-side confirmation.

---

## 24. Operator Action Responsibility Rule

Operator action may be indicated when evidence shows:

- staff manually cancelled
- staff manually re-entered order
- staff restarted POS
- staff disabled local daemon
- staff changed network/device
- staff ignored support instruction
- staff manually forced duplicate
- staff selected wrong recovery path

Operator action classification must be based on audit/support evidence.

---

## 25. Customer Action Responsibility Rule

Customer action may be indicated when evidence shows:

- double tap
- repeated payment attempt
- abandoned Mini Kiosk flow
- closed browser during payment
- changed language/session unexpectedly
- multiple devices used
- duplicate QR/NFC entry
- support-confirmed customer action

Customer action evidence must be used carefully and respectfully.

Customer-facing message must not blame.

---

## 26. Unknown Responsibility Rule

Unknown responsibility applies when evidence is insufficient.

Unknown should trigger:

- reconciliation
- provider log request if needed
- store check if needed
- support review
- Admin task
- evidence improvement backlog
- no unsupported blame

Unknown is safer than false accusation.

---

## 27. Reconciliation Required Rule

Reconciliation is required when:

- payment provider status conflicts
- POS response conflicts with POS ledger
- KDS state conflicts with order/payment state
- partner settlement report mismatches
- provider callback conflicts with earlier response
- timeout leaves money/order state uncertain
- local daemon reconnects with queued events
- store-side evidence conflicts with cloud evidence

Reconciliation must preserve correlation and evidence.

---

## 28. Smoking Gun Evidence Packet Rule

Smoking gun evidence packet should be created for:

- payment dispute
- POS missing order dispute
- duplicate payment dispute
- duplicate POS order dispute
- KDS duplicate ticket dispute
- provider callback conflict
- Redtable-type partner payment dispute
- delivery platform event dispute
- local daemon/store network dispute
- high-risk operation dispute

Smoking gun packet must be masked and reviewable.

---

## 29. Evidence Packet Required Fields

Smoking gun packet should include:

- packet id
- correlation id
- idempotency key
- affected runtime
- affected external system
- lifecycle timeline
- request evidence
- response evidence
- payload hashes
- provider references
- status/error codes
- retry/timeout records
- duplicate/stale records
- canonical mapping result
- runtime decision
- audit references
- support/Admin summary
- responsibility classification
- evidence confidence
- unresolved questions

Packet must separate facts from interpretation.

---

## 30. Fact Versus Interpretation Rule

Responsibility record must distinguish:

Facts:

- request sent at timestamp
- provider returned code
- timeout occurred
- retry attempted
- duplicate detected
- payload hash recorded
- POS returned error
- daemon offline marker observed

Interpretation:

- likely provider fault
- likely store network fault
- likely operator action
- reconciliation required
- provider log needed

Facts must be evidence-backed.

Interpretation must show confidence.

---

## 31. Provider Log Request Rule

When Yoonsul evidence is insufficient, provider log request may be required.

Provider log request should include:

- correlation id
- provider reference
- timestamp window
- request evidence summary
- response evidence summary
- error code
- expected provider log type
- dispute reason
- support/Admin owner

Provider log request must not expose unnecessary sensitive data.

---

## 32. Store Check Request Rule

When store-side fault is possible, store check may be required.

Store check should ask for:

- POS PC status
- POS application status
- network/router status
- local daemon status
- last restart time if known
- manual action performed
- screenshot or vendor log if safe
- staff note

Store check should be operational, not accusatory.

---

## 33. Support Dispute Handling Rule

Support should use responsibility evidence to:

- explain status safely
- avoid premature blame
- escalate to provider/store/Admin
- request logs if needed
- inform customer of recovery step
- create case notes
- link evidence packet
- close only when resolved or deferred

Support should not expose raw payload.

---

## 34. Admin Dispute Handling Rule

Admin should use responsibility evidence to:

- review incident clusters
- identify repeated provider fault
- identify repeated store network issue
- prioritize integration fixes
- update blocker register
- trigger provider escalation
- trigger store training
- trigger rollback/pause if needed

Admin coordinates evidence-based decisions.

---

## 35. AI Support Responsibility Boundary Rule

AI support may summarize responsibility evidence only when:

- evidence packet exists
- support case scope exists
- evidence is masked
- facts and interpretation are separated
- confidence is shown
- human review remains
- no legal conclusion is made
- no provider blame is stated as final without evidence

AI must not create unsupported fault claims.

---

## 36. Customer Message Rule

Customer-facing message must be safe and non-accusatory.

Customer message should say:

- issue is being checked
- order/payment status is being verified
- staff/support will assist
- duplicate payment prevention is active if relevant
- refund/recovery review is in progress if relevant

Customer message should not say:

- POS vendor failed
- payment provider failed
- store network failed
- staff made mistake
- customer caused the error

Internal responsibility is not customer blame.

---

## 37. Provider Message Rule

Provider-facing dispute message should be factual.

Provider message may include:

- request timestamp
- response timestamp
- provider request id
- provider response id
- status/error code
- payload hash
- masked payload excerpt if allowed
- correlation id
- idempotency key
- observed issue
- requested investigation

Provider message should not include unnecessary customer data.

---

## 38. Store Message Rule

Store-facing message should be operational.

Store message may include:

- issue summary
- affected order/payment
- required check
- POS/network/daemon status request
- recovery instruction
- support contact
- evidence reference

Store message should not blame without confirmation.

---

## 39. Commercial Impact Rule

Responsibility classification may affect:

- SaaS support burden
- provider contract negotiation
- store training requirement
- SLA conversation
- pilot go/no-go
- partner continuation
- commercial claim adjustment
- customer compensation review

Commercial action must follow evidence.

---

## 40. Data Capture Rule

Responsibility separation should capture safe metrics:

- fault-domain frequency
- provider error frequency
- POS timeout frequency
- store network issue frequency
- local daemon offline frequency
- duplicate/stale event count
- reconciliation count
- support recovery time
- evidence confidence distribution
- repeated vendor issue

Metrics should improve product and partner strategy.

---

## 41. Build Gate Rule

Build gate must block external handoff when:

- responsibility classification unavailable
- smoking gun evidence packet undefined
- fact/interpretation separation missing
- provider dispute evidence missing
- store network boundary missing
- local daemon boundary missing if applicable
- payment responsibility boundary unclear
- POS responsibility boundary unclear
- support/Admin dispute handling missing
- customer-safe message missing
- evidence confidence missing

No responsibility separation, no external handoff.

---

## 42. Pilot Rule

Pilot dry run must test responsibility separation for:

- POS rejection
- payment timeout
- provider duplicate callback
- stale callback
- local daemon offline
- store network disconnect
- Redtable-type partner error if applicable
- delivery platform duplicate event if applicable
- support dispute lookup
- Admin provider incident review
- customer-safe message

Pilot must prove the smoking gun evidence works.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      Black_Box_Responsibility_Register.md
      Smoking_Gun_Evidence_Packet_Register.md
      Fault_Domain_Classification_Register.md
      Evidence_Confidence_Register.md
      POS_Dispute_Evidence_Register.md
      Payment_Provider_Dispute_Evidence_Register.md
      Redtable_Partner_Dispute_Evidence_Register.md
      Delivery_Platform_Dispute_Evidence_Register.md
      Local_Daemon_Dispute_Evidence_Register.md
      Store_Network_Dispute_Evidence_Register.md
      Provider_Log_Request_Register.md
      Store_Check_Request_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- blaming provider without evidence
- blaming store network without evidence
- blaming customer in customer-facing message
- treating timeout as external fault without proof
- ignoring Yoonsul internal fault when evidence proves it
- merging facts and interpretation
- missing provider return code
- missing payload evidence
- missing correlation id
- missing idempotency key for retry dispute
- using AI to assign responsibility without evidence
- letting Support expose raw payload
- letting Admin force runtime truth from dispute packet

---

## 45. No-Code Boundary

This document does not authorize:

- dispute automation implementation
- fault classifier implementation
- evidence packet implementation
- provider log request automation
- store check workflow implementation
- support console implementation
- Admin console implementation
- Gateway implementation
- POS connector
- payment connector
- provider adapter
- local daemon
- Redtable integration
- production monitoring

This document governs black-box responsibility separation and smoking gun evidence policy only.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. What is black-box responsibility?
2. What is smoking gun evidence?
3. What responsibility classification values exist?
4. What fault-domain values exist?
5. What evidence confidence values exist?
6. What fields should responsibility record include?
7. What Yoonsul runtime responsibility rule applies?
8. What Gateway validation responsibility rule applies?
9. What Provider Adapter responsibility rule applies?
10. What External POS responsibility rule applies?
11. What POS vendor dispute evidence rule applies?
12. What Payment Provider responsibility rule applies?
13. What PG/VAN responsibility rule applies?
14. What Card Network responsibility rule applies?
15. What Delivery Platform responsibility rule applies?
16. What Redtable-type partner responsibility rule applies?
17. What Local Daemon responsibility rule applies?
18. What Store Network responsibility rule applies?
19. What Store POS PC responsibility rule applies?
20. What Operator Action responsibility rule applies?
21. What Customer Action responsibility rule applies?
22. What Unknown responsibility rule applies?
23. What reconciliation required rule applies?
24. What smoking gun evidence packet rule applies?
25. What fields should evidence packet include?
26. What fact versus interpretation rule applies?
27. What provider log request rule applies?
28. What store check request rule applies?
29. What support dispute handling rule applies?
30. What Admin dispute handling rule applies?
31. What AI support responsibility boundary applies?
32. What customer message rule applies?
33. What provider message rule applies?
34. What store message rule applies?
35. What commercial impact rule applies?
36. What data capture rule applies?
37. What build gate rule applies?
38. What pilot rule applies?
39. What registers are recommended?
40. What anti-patterns are prohibited?
41. What no-code boundary applies?

If these questions cannot be answered, POS/provider black-box responsibility separation and smoking gun evidence planning is incomplete.

---

## 47. Conclusion

Black-box responsibility separation turns Gateway integrity into operational defense.

The safe responsibility flow is:

    incident or dispute
        -> correlation trace
        -> idempotency record
        -> immutable request/response evidence
        -> timeout/retry/duplicate/stale evidence
        -> canonical event mapping result
        -> runtime decision
        -> fault-domain candidate
        -> evidence confidence
        -> smoking gun evidence packet
        -> support/Admin/provider/store response

This document ensures that when a POS vendor, payment provider, PG/VAN, Redtable-type partner, delivery platform, local daemon, store network, store POS PC, operator action, customer action, or Yoonsul runtime issue occurs, the system can separate facts from interpretation and defend the correct boundary with evidence.

A Gateway without responsibility evidence is only a pipe.

A Gateway with smoking gun evidence is an operational shield.