# 011007_Policy_External_POS_PG_VAN_Local_Daemon_And_Store_Network_Failure_Boundary

## 1. Purpose

This document defines the failure boundary between Yoonsul-controlled runtime and external POS, PG, VAN, payment provider, local daemon, store POS PC, store network, store router, store Wi-Fi, delivery platform, Redtable-type partner, and other external black-box systems.

The previous documents defined Gateway correlation id, immutable payload evidence, idempotency, retry, timeout, duplicate prevention, black-box responsibility separation, smoking gun evidence, Gateway handoff audit timeline, and provider dispute response.

This document focuses on classifying where a failure occurred when an external handoff does not complete as expected.

This document does not implement monitoring, networking, local daemon, POS connector, payment connector, provider adapter, store network diagnostics, dashboard, support console, or Admin console.

It defines external failure boundary policy only.

---

## 2. Scope

This document covers:

- external POS failure boundary
- PG/VAN/payment provider failure boundary
- local daemon failure boundary
- store POS PC failure boundary
- store network failure boundary
- store router/Wi-Fi failure boundary
- delivery platform failure boundary
- Redtable-type partner failure boundary
- store operator action boundary
- timeout versus failure distinction
- uncertainty classification
- evidence requirement
- support/Admin boundary
- no-code boundary

This document does not cover:

- final network monitoring implementation
- final local daemon implementation
- final POS vendor contract
- final PG/VAN contract
- final Redtable contract
- final payment settlement process
- final support escalation implementation
- final production operations

---

## 3. Core Principle

External failure must be classified by boundary, not guessed.

The project must follow this rule:

> When an external handoff fails, times out, duplicates, replays, becomes stale, or remains uncertain, Yoonsul must classify the failure boundary using correlation id, idempotency key, request evidence, response evidence, retry/timeout timeline, local daemon evidence, store network evidence, provider return code, and reconciliation result before assigning responsibility or changing runtime truth.

Failure boundary is evidence.

Failure boundary is not opinion.

---

## 4. Failure Boundary Meaning

Failure boundary means the point in the handoff chain where the expected flow stopped, degraded, returned an error, duplicated, timed out, became stale, or became uncertain.

Boundary candidates include:

- Yoonsul runtime
- Yoonsul Gateway
- Provider Adapter
- external POS
- payment provider
- PG/VAN
- card network
- delivery platform
- Redtable-type partner
- local daemon
- store POS PC
- store network
- store router
- store Wi-Fi
- operator action
- customer action
- unknown

Boundary must be evidence-linked.

---

## 5. Failure Boundary Status Values

Recommended status values:

- `FAILURE_BOUNDARY_NOT_CLASSIFIED`
- `FAILURE_BOUNDARY_EVIDENCE_REQUIRED`
- `FAILURE_BOUNDARY_INTERNAL_RUNTIME`
- `FAILURE_BOUNDARY_GATEWAY`
- `FAILURE_BOUNDARY_PROVIDER_ADAPTER`
- `FAILURE_BOUNDARY_EXTERNAL_POS`
- `FAILURE_BOUNDARY_PAYMENT_PROVIDER`
- `FAILURE_BOUNDARY_PG_VAN`
- `FAILURE_BOUNDARY_CARD_NETWORK`
- `FAILURE_BOUNDARY_DELIVERY_PLATFORM`
- `FAILURE_BOUNDARY_PARTNER_MODULE`
- `FAILURE_BOUNDARY_LOCAL_DAEMON`
- `FAILURE_BOUNDARY_STORE_POS_PC`
- `FAILURE_BOUNDARY_STORE_NETWORK`
- `FAILURE_BOUNDARY_OPERATOR_ACTION`
- `FAILURE_BOUNDARY_CUSTOMER_ACTION`
- `FAILURE_BOUNDARY_UNKNOWN`
- `FAILURE_BOUNDARY_RECONCILIATION_REQUIRED`

Status may be normalized later.

---

## 6. Failure Severity Values

Recommended failure severity values:

- `FAILURE_SEVERITY_INFO`
- `FAILURE_SEVERITY_LOW`
- `FAILURE_SEVERITY_MEDIUM`
- `FAILURE_SEVERITY_HIGH`
- `FAILURE_SEVERITY_CRITICAL`
- `FAILURE_SEVERITY_PAYMENT_CRITICAL`
- `FAILURE_SEVERITY_KDS_CRITICAL`
- `FAILURE_SEVERITY_CUSTOMER_TRUST_CRITICAL`
- `FAILURE_SEVERITY_SECURITY_CRITICAL`

Severity should reflect operational impact.

---

## 7. Failure Boundary Record Fields

Each failure boundary record should include:

- failure boundary id
- correlation id
- idempotency key if applicable
- affected runtime
- affected external system
- failure boundary status
- severity
- first observed timestamp
- latest observed timestamp
- request evidence reference
- response evidence reference
- timeout record reference
- retry record reference
- local daemon evidence reference if applicable
- store network evidence reference if applicable
- provider code
- POS code if applicable
- payment provider code if applicable
- operator action reference if applicable
- customer action reference if applicable
- support case reference
- Admin task reference
- reconciliation requirement
- final classification
- notes

Failure boundary record must be searchable.

---

## 8. Failure Boundary ID Format

Recommended format:

    FAILURE-BOUNDARY-[YYYYMMDD]-[NUMBER]

Example:

    FAILURE-BOUNDARY-20260612-001

Final format may be normalized later.

---

## 9. Boundary Evidence Rule

Boundary classification requires evidence.

Evidence may include:

- request evidence
- response evidence
- timeout timeline
- retry timeline
- provider return code
- local daemon heartbeat
- local daemon queue state
- POS response
- POS rejection code
- store network status
- payment provider callback
- settlement report
- delivery platform response
- partner response
- operator audit event
- support note
- store check result

No evidence means unknown or reconciliation required.

---

## 10. Timeout Versus Failure Rule

Timeout is not automatically failure.

Timeout may mean:

- provider processed but response lost
- request never reached provider
- response delayed
- local daemon offline
- store network disconnected
- POS accepted but did not respond
- payment provider will callback later
- network path failed
- operation remains uncertain

Timeout should create uncertainty until resolved.

---

## 11. Unknown Boundary Rule

Unknown boundary applies when evidence is insufficient.

Unknown boundary should trigger:

- evidence review
- provider log request if applicable
- store check if applicable
- reconciliation if money/POS/KDS affected
- support-safe message
- Admin task
- blocker if repeated
- future instrumentation backlog

Unknown must not become false blame.

---

## 12. Yoonsul Runtime Failure Boundary Rule

Yoonsul runtime failure may be classified when evidence shows:

- invalid state transition
- runtime owner violation
- duplicate prevention failure
- payment/KDS/POS boundary violation
- message/i18n failure
- support/Admin permission error
- internal validation missed
- internal event emitted incorrectly
- internal fallback did not trigger

Internal failure must be owned and corrected.

---

## 13. Gateway Failure Boundary Rule

Gateway failure may be classified when evidence shows:

- correlation id missing
- idempotency key missing
- request malformed before external handoff
- payload masking/hash missing
- provider response lost inside Gateway
- timeout classified incorrectly
- duplicate/stale/replay accepted incorrectly
- external provider event mapped incorrectly
- audit/evidence not produced

Gateway failure is Yoonsul-controlled.

---

## 14. Provider Adapter Failure Boundary Rule

Provider Adapter failure may be classified when evidence shows:

- provider event received but not validated correctly
- provider code mapping wrong
- provider payload parsed incorrectly
- stale provider event accepted
- duplicate provider callback processed
- provider capability assumed incorrectly
- quarantine not applied
- canonical event emitted incorrectly

Provider Adapter must fail closed.

---

## 15. External POS Failure Boundary Rule

External POS failure may be classified when evidence shows:

- valid POS request sent
- POS returned error
- POS returned rejection
- POS did not respond
- POS accepted but later ledger missing
- POS transaction reference inconsistent
- POS app unavailable
- local daemon delivered request but POS failed
- POS vendor log required

External POS is black box.

Yoonsul proves request and response boundary.

---

## 16. PG VAN Failure Boundary Rule

PG/VAN failure may be classified when evidence shows:

- PG/VAN response code indicates failure
- payment provider reports downstream VAN issue
- card authorization failed at VAN/network
- settlement mismatch points to PG/VAN layer
- refund/cancel provider response indicates PG/VAN restriction
- payment provider requires PG/VAN log review

PG/VAN classification should rely on provider evidence.

---

## 17. Payment Provider Failure Boundary Rule

Payment provider failure may be classified when evidence shows:

- payment provider API returned error
- payment provider timed out
- callback duplicated
- callback stale
- callback contradicted response
- provider settlement report mismatched
- refund/cancel support failed
- provider status remained uncertain

Payment provider boundary requires strong evidence.

---

## 18. Card Network Failure Boundary Rule

Card network failure may be classified only with explicit evidence.

Evidence may include:

- issuer decline code
- network unavailable code
- authorization timeout
- card brand network error
- chargeback/dispute response
- acquirer/provider confirmation

Do not infer card network fault without provider evidence.

---

## 19. Local Daemon Failure Boundary Rule

Local daemon failure may be classified when evidence shows:

- cloud request created
- daemon did not receive
- daemon heartbeat missing
- daemon received but did not forward
- daemon local queue failed
- daemon retried unsafely
- daemon version mismatch
- daemon failed to return POS response
- daemon logs show local error

Local daemon boundary separates cloud and store-side path.

---

## 20. Store POS PC Failure Boundary Rule

Store POS PC failure may be classified when evidence shows:

- POS PC offline
- POS application unavailable
- local daemon can reach network but not POS app
- POS app restarted
- POS PC clock skew
- firewall blocks local POS connection
- POS program hung
- operator closed POS app

Store POS PC classification may require store check.

---

## 21. Store Network Failure Boundary Rule

Store network failure may be classified when evidence shows:

- store internet unavailable
- router unreachable
- DNS failure
- TLS/connect failure
- repeated local timeout
- store heartbeat missing
- POS PC reachable only intermittently
- Wi-Fi unstable
- cloud services normal but store path down

Store network failure must be measured or confirmed.

---

## 22. Store Router Wi-Fi Failure Boundary Rule

Router/Wi-Fi failure may be classified when evidence shows:

- local device cannot reach Gateway
- daemon heartbeat intermittent
- packet loss suspected by repeated timeout
- router reboot reported
- Wi-Fi disconnected
- store LAN unreachable
- multiple store devices affected
- network issue resolved after router restart

Router/Wi-Fi classification should remain cautious unless confirmed.

---

## 23. Delivery Platform Failure Boundary Rule

Delivery platform failure may be classified when evidence shows:

- platform API error
- duplicate platform event
- stale cancellation
- platform status mismatch
- pickup/rider status missing or contradictory
- platform payload malformed
- platform support confirmation required

Delivery platform events must remain provider candidates until validated.

---

## 24. Redtable-Type Partner Failure Boundary Rule

Redtable-type partner failure may be classified when evidence shows:

- partner menu API error
- partner translated menu data stale
- partner payment module timeout
- partner payment callback duplicate
- partner settlement report mismatch
- partner external page displayed wrong version
- partner global payment status unclear
- partner capability evidence missing or contradicted

Partner boundary classification requires official evidence when possible.

---

## 25. External Menu Projection Failure Boundary Rule

External menu projection failure may be classified when evidence shows:

- public menu package publish failed
- partner received stale version
- Google Maps landing link outdated
- QR/NFC page showed wrong locale
- translated menu content version mismatch
- external unpublish failed
- content version not propagated

External projection failure is public trust risk.

---

## 26. Operator Action Failure Boundary Rule

Operator action failure may be classified when evidence shows:

- staff manually cancelled
- staff manually re-entered order
- staff bypassed prescribed fallback
- staff restarted POS/PC/router
- staff disabled daemon
- staff selected wrong recovery action
- staff ignored system warning
- support note confirms action

Operator action must be audited or confirmed.

---

## 27. Customer Action Failure Boundary Rule

Customer action failure may be classified when evidence shows:

- repeated submit
- double tap
- abandoned payment
- browser closed during payment
- multiple devices used
- duplicate QR/NFC session
- wrong language/session selected
- support-confirmed customer action

Customer-facing message must remain respectful.

---

## 28. Boundary Classification Priority Rule

Boundary classification should prioritize evidence in this order:

1. immutable request/response evidence
2. provider/POS/payment status code
3. correlation timeline
4. idempotency/retry/timeout records
5. local daemon evidence
6. store network evidence
7. support/Admin notes
8. provider/store log confirmation
9. interpretation with confidence marker

Do not skip directly to interpretation.

---

## 29. Boundary Confidence Rule

Each failure boundary classification should include confidence.

Recommended confidence values:

- `BOUNDARY_CONFIDENCE_HIGH`
- `BOUNDARY_CONFIDENCE_MEDIUM`
- `BOUNDARY_CONFIDENCE_LOW`
- `BOUNDARY_CONFIDENCE_INSUFFICIENT`
- `BOUNDARY_CONFIDENCE_REQUIRES_PROVIDER_LOG`
- `BOUNDARY_CONFIDENCE_REQUIRES_STORE_CHECK`
- `BOUNDARY_CONFIDENCE_REQUIRES_RECONCILIATION`

Confidence prevents overstatement.

---

## 30. Support Response Rule

Support should respond based on failure boundary status.

Support may say:

- system is checking the order/payment status
- payment/order status is being verified
- staff will assist
- duplicate payment prevention is active
- refund/recovery review is in progress
- provider/store check is required internally

Support should not blame POS, provider, store, or customer unless communication policy allows and evidence is confirmed.

---

## 31. Admin Response Rule

Admin should use failure boundary records to:

- cluster repeated provider errors
- identify store network issues
- identify POS vendor reliability issues
- trigger provider escalation
- trigger store check
- trigger training
- trigger rollback/pause
- update blocker register
- update partner strategy

Admin response should be evidence-led.

---

## 32. Provider Escalation Rule

Provider escalation should occur when:

- provider error repeats
- provider timeout repeats
- provider callback duplicates/stales
- provider response conflicts with settlement
- POS/VAN/PG code requires vendor explanation
- partner capability contradicts documentation
- delivery platform event behavior causes operational risk

Escalation packet must include masked evidence.

---

## 33. Store Check Rule

Store check should occur when:

- local daemon offline
- store network unavailable
- POS PC unreachable
- POS app not responding
- repeated store-side timeout
- operator action suspected
- store device configuration changed
- local queue replay occurred

Store check should be non-accusatory.

---

## 34. Reconciliation Rule

Reconciliation is required when:

- payment state uncertain
- POS accepted state uncertain
- KDS handoff uncertain
- provider callback conflicts
- settlement mismatch exists
- local daemon replay creates ambiguity
- external menu projection version mismatch affects public display
- Redtable-type partner payment/settlement conflicts

Reconciliation must be correlation-linked.

---

## 35. Rollback Pause Rule

Rollback or pause may be required when:

- repeated payment provider timeout
- repeated POS handoff uncertainty
- repeated local daemon failure
- repeated store network failure
- repeated partner payment uncertainty
- repeated external menu projection mismatch
- support cannot recover safely
- customer trust risk increases
- evidence quality insufficient

Rollback/pause is safety action.

---

## 36. Evidence Improvement Rule

If boundary cannot be classified, create evidence improvement backlog.

Improvement candidates:

- add heartbeat evidence
- add provider request id mapping
- add local daemon status
- add POS response code preservation
- add network timeout category
- add store check template
- add support timeline view
- add Admin boundary dashboard
- add i18n customer uncertainty message

Unknown boundaries should improve instrumentation.

---

## 37. Customer Message Rule

Customer-facing message should be localized and safe.

Customer message should preserve:

- uncertainty if status is uncertain
- next recovery step
- staff/support assistance
- no internal blame
- no raw provider detail
- no technical jargon
- no false finality

Customer trust matters more than fault assignment.

---

## 38. AI Support Boundary Rule

AI support may summarize failure boundary only when:

- evidence summary exists
- support case scope exists
- data is masked
- confidence is shown
- facts and interpretation are separated
- human review remains
- no legal conclusion is made
- no provider/store/customer blame is made without evidence

AI must not infer beyond trace.

---

## 39. Data Capture Rule

Failure boundary data should capture safe metrics:

- boundary category
- severity
- affected runtime
- affected provider
- affected store
- timeout count
- retry count
- duplicate/stale count
- reconciliation count
- support recovery time
- rollback/pause trigger
- evidence completeness

Metrics help provider strategy and store reliability.

---

## 40. Build Gate Rule

Build gate must block external handoff when:

- failure boundary categories undefined
- timeout/failure distinction missing
- local daemon boundary missing when applicable
- store network boundary missing when applicable
- POS boundary missing
- payment provider boundary missing
- Redtable-type partner boundary missing when applicable
- customer-safe uncertainty message missing
- support/Admin boundary response missing
- reconciliation rule missing
- rollback/pause trigger missing
- evidence improvement path missing

External handoff must fail with evidence.

---

## 41. Pilot Rule

Pilot dry run must test boundary classification for:

- external POS error
- POS timeout
- payment provider timeout
- duplicate callback
- stale callback
- local daemon offline
- store POS PC unavailable
- store network disconnected
- Redtable-type partner API error if applicable
- external menu projection stale version
- operator manual re-entry
- support/Admin lookup
- rollback/pause trigger

Pilot must prove boundary classification.

---

## 42. Registers Recommendation

Recommended future files:

    docs/_index/
      External_Failure_Boundary_Register.md
      POS_Failure_Boundary_Register.md
      Payment_Provider_Failure_Boundary_Register.md
      PG_VAN_Failure_Boundary_Register.md
      Local_Daemon_Failure_Boundary_Register.md
      Store_Network_Failure_Boundary_Register.md
      Store_POS_PC_Failure_Boundary_Register.md
      Delivery_Platform_Failure_Boundary_Register.md
      Redtable_Partner_Failure_Boundary_Register.md
      External_Menu_Projection_Failure_Boundary_Register.md
      Operator_Action_Boundary_Register.md
      Boundary_Confidence_Register.md
      Failure_Boundary_Improvement_Backlog.md

This document only recommends these files.

It does not create them.

---

## 43. Anti-Patterns

The following are prohibited:

- assuming timeout equals provider failure
- assuming no response equals Yoonsul failure
- blaming store network without evidence
- blaming customer in customer-facing message
- classifying card network failure without provider evidence
- ignoring local daemon boundary
- ignoring store POS PC boundary
- mixing POS failure and payment failure
- mixing provider fault and mapping fault
- hiding unknown boundary
- skipping reconciliation when money state uncertain
- letting AI assign blame without evidence
- failing to improve instrumentation after unknown boundary

---

## 44. No-Code Boundary

This document does not authorize:

- monitoring implementation
- local daemon implementation
- POS connector
- payment connector
- provider adapter
- network diagnostics
- support console
- Admin console
- AI support gateway
- dashboard
- production incident workflow

This document governs external failure boundary planning only.

---

## 45. Readiness Check

This document is ready when the project can answer:

1. What is failure boundary?
2. What failure boundary status values exist?
3. What failure severity values exist?
4. What fields should failure boundary record include?
5. What boundary evidence rule applies?
6. What timeout versus failure rule applies?
7. What unknown boundary rule applies?
8. What Yoonsul runtime failure boundary rule applies?
9. What Gateway failure boundary rule applies?
10. What Provider Adapter failure boundary rule applies?
11. What External POS failure boundary rule applies?
12. What PG/VAN failure boundary rule applies?
13. What Payment Provider failure boundary rule applies?
14. What Card Network failure boundary rule applies?
15. What Local Daemon failure boundary rule applies?
16. What Store POS PC failure boundary rule applies?
17. What Store Network failure boundary rule applies?
18. What Store Router/Wi-Fi failure boundary rule applies?
19. What Delivery Platform failure boundary rule applies?
20. What Redtable-type partner failure boundary rule applies?
21. What External Menu Projection failure boundary rule applies?
22. What Operator Action failure boundary rule applies?
23. What Customer Action failure boundary rule applies?
24. What boundary classification priority rule applies?
25. What boundary confidence rule applies?
26. What Support response rule applies?
27. What Admin response rule applies?
28. What provider escalation rule applies?
29. What store check rule applies?
30. What reconciliation rule applies?
31. What rollback/pause rule applies?
32. What evidence improvement rule applies?
33. What customer message rule applies?
34. What AI Support boundary rule applies?
35. What data capture rule applies?
36. What build gate rule applies?
37. What pilot rule applies?
38. What registers are recommended?
39. What anti-patterns are prohibited?
40. What no-code boundary applies?

If these questions cannot be answered, external POS, PG, VAN, local daemon, and store network failure boundary planning is incomplete.

---

## 46. Conclusion

External handoff failure must be classified by evidence, not assumption.

The safe failure boundary flow is:

    handoff issue
        -> correlation trace
        -> request/response evidence
        -> timeout/retry/duplicate/stale review
        -> provider/POS/payment/local daemon/store network evidence review
        -> boundary classification
        -> confidence marker
        -> reconciliation, provider escalation, store check, fallback, or rollback
        -> support/Admin/AI-safe summary
        -> evidence improvement if boundary remains unknown

This document ensures that Yoonsul can distinguish internal runtime failure, Gateway failure, Provider Adapter failure, external POS failure, PG/VAN/payment provider failure, local daemon failure, store POS PC failure, store network failure, Redtable-type partner failure, delivery platform failure, operator action, customer action, and unknown uncertainty without unsupported blame.

Failure without boundary is chaos.

Boundary with evidence is control.