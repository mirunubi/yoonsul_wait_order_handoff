# 11004_Policy_Idempotency_Retry_Timeout_And_Duplicate_External_Handoff

## 1. Purpose

This document defines idempotency, retry, timeout, duplicate external handoff prevention, stale response handling, uncertainty classification, replay protection, provider callback deduplication, POS duplicate prevention, payment duplicate prevention, KDS duplicate prevention, local daemon retry boundary, Redtable-type partner retry boundary, and no-code boundary policy for the Yoonsul Wait/Order Handoff operating system.

The previous documents defined Gateway correlation id, transaction lifecycle traceability, immutable request/response payload evidence, masking, payload hashing, and provider return code preservation.

This document focuses on ensuring that external system instability does not create duplicate money movement, duplicate POS transaction, duplicate KDS ticket, duplicate provider mapping, duplicate customer recovery, or ambiguous runtime truth.

This document does not implement idempotency storage, retry queue, timeout engine, duplicate detector, provider adapter, POS connector, payment connector, KDS connector, local daemon, Redtable-type partner integration, or production monitoring.

It defines idempotency, retry, timeout, and duplicate external handoff policy only.

---

## 2. Scope

This document covers:

- idempotency key rule
- retry policy planning
- timeout classification
- duplicate handoff prevention
- duplicate callback prevention
- stale response handling
- replay protection
- external handoff uncertainty
- payment duplicate prevention
- POS duplicate prevention
- KDS duplicate prevention
- provider adapter duplicate prevention
- local daemon retry boundary
- Redtable-type partner retry boundary
- evidence/audit linkage
- support/Admin summary boundary
- no-code boundary

This document does not cover:

- final idempotency implementation
- retry queue implementation
- timeout engine implementation
- database schema
- provider connector implementation
- POS connector implementation
- payment integration
- KDS integration
- local daemon implementation
- production incident response execution

---

## 3. Core Principle

Retry is allowed only when idempotency protects truth.

The project must follow this rule:

> Any external handoff that can create or change payment, POS transaction, KDS ticket, provider mapping, refund/cancel, delivery platform state, Redtable-type partner payment, or customer recovery state must use an idempotency key before retry, timeout recovery, or callback acceptance is allowed.

Retry without idempotency can create duplicate money.

Timeout without uncertainty can create false truth.

Duplicate callback without detection can corrupt state.

---

## 4. Idempotency Meaning

Idempotency means the same logical operation can be safely attempted more than once without creating duplicate business effect.

Idempotency should protect:

- payment attempt
- refund request
- cancel request
- POS order submission
- KDS ticket creation
- provider callback handling
- delivery platform event mapping
- Redtable-type partner payment
- local daemon handoff
- external menu projection publish/unpublish
- support recovery action if externally visible

Idempotency does not mean every retry succeeds.

It means repeated attempts do not duplicate the effect.

---

## 5. Idempotency Key Meaning

Idempotency key is the stable key used to identify one logical operation across attempts.

Idempotency key may be derived from:

- order id
- payment attempt id
- refund request id
- cancel request id
- POS handoff id
- KDS ticket candidate id
- provider event id
- delivery event id
- partner payment attempt id
- external projection version id

The key must be stable for the logical operation.

It must not be regenerated on every retry.

---

## 6. Retry Meaning

Retry means repeating an attempted handoff after failure, timeout, temporary provider issue, local daemon issue, network issue, or uncertain response.

Retry must define:

- retry trigger
- maximum attempts
- retry interval
- backoff behavior
- idempotency key
- timeout policy
- stop condition
- uncertainty handling
- evidence output
- support/Admin visibility

Retry is controlled recovery, not blind repetition.

---

## 7. Timeout Meaning

Timeout means Yoonsul did not receive a response within the expected window.

Timeout is not automatically success.

Timeout is not automatically failure.

Timeout usually means uncertainty until reconciliation, callback, or external confirmation resolves it.

Timeout handling must preserve:

- request evidence
- timeout timestamp
- retry decision
- uncertainty status
- fallback path
- support message
- reconciliation requirement

---

## 8. Duplicate Meaning

Duplicate means the system receives or attempts the same logical operation more than once.

Duplicate may come from:

- customer double tap
- Mini Kiosk repeated submit
- network retry
- local daemon retry
- provider callback replay
- webhook resend
- POS retry
- payment provider retry
- delivery platform event resend
- Redtable-type partner callback replay
- staff manual re-entry
- support recovery action

Duplicate must be detected before business effect.

---

## 9. Idempotency Status Values

Recommended idempotency status values:

- `IDEMPOTENCY_NOT_REQUIRED`
- `IDEMPOTENCY_REQUIRED`
- `IDEMPOTENCY_KEY_CREATED`
- `IDEMPOTENCY_KEY_PROPAGATED`
- `IDEMPOTENCY_KEY_ACCEPTED`
- `IDEMPOTENCY_DUPLICATE_DETECTED`
- `IDEMPOTENCY_REPLAY_DETECTED`
- `IDEMPOTENCY_CONFLICT`
- `IDEMPOTENCY_EXPIRED`
- `IDEMPOTENCY_BLOCKED`
- `IDEMPOTENCY_RECONCILIATION_REQUIRED`

Status may be normalized later.

---

## 10. Retry Status Values

Recommended retry status values:

- `RETRY_NOT_REQUIRED`
- `RETRY_ELIGIBLE`
- `RETRY_SCHEDULED`
- `RETRY_ATTEMPTED`
- `RETRY_BACKOFF`
- `RETRY_STOPPED`
- `RETRY_EXHAUSTED`
- `RETRY_SUCCEEDED`
- `RETRY_FAILED`
- `RETRY_UNCERTAIN`
- `RETRY_BLOCKED`

Retry status must be linked to correlation id.

---

## 11. Timeout Status Values

Recommended timeout status values:

- `TIMEOUT_NOT_OCCURRED`
- `TIMEOUT_OCCURRED`
- `TIMEOUT_RETRY_ELIGIBLE`
- `TIMEOUT_RETRY_BLOCKED`
- `TIMEOUT_CALLBACK_PENDING`
- `TIMEOUT_RECONCILIATION_REQUIRED`
- `TIMEOUT_RESOLVED_SUCCESS`
- `TIMEOUT_RESOLVED_FAILURE`
- `TIMEOUT_REMAINS_UNCERTAIN`
- `TIMEOUT_ESCALATED`

Timeout must not be hidden.

---

## 12. Duplicate Status Values

Recommended duplicate status values:

- `DUPLICATE_NOT_DETECTED`
- `DUPLICATE_DETECTED`
- `DUPLICATE_BLOCKED`
- `DUPLICATE_ALLOWED_AS_NOOP`
- `DUPLICATE_CONFLICT`
- `DUPLICATE_RECONCILIATION_REQUIRED`
- `DUPLICATE_ESCALATED`
- `DUPLICATE_SUPERSEDED`

Duplicate status must explain effect.

---

## 13. Idempotency Record Fields

Each idempotency record should include:

- idempotency key
- correlation id
- logical operation
- runtime owner
- source runtime
- target system
- first attempt timestamp
- latest attempt timestamp
- attempt count
- current status
- associated request evidence
- associated response evidence
- duplicate records
- timeout records
- final outcome
- expiration placeholder
- notes

Idempotency record must be searchable.

---

## 14. Retry Record Fields

Each retry record should include:

- retry record id
- correlation id
- idempotency key
- logical operation
- target system
- attempt number
- retry trigger
- scheduled time
- actual attempt time
- request evidence reference
- response evidence reference
- timeout status
- provider code
- outcome
- next action
- notes

Retry record must be attempt-specific.

---

## 15. Timeout Record Fields

Each timeout record should include:

- timeout record id
- correlation id
- idempotency key
- target system
- logical operation
- request timestamp
- timeout threshold
- timeout timestamp
- attempt number
- request evidence reference
- retry decision
- uncertainty status
- reconciliation requirement
- support/Admin message
- notes

Timeout is evidence.

---

## 16. Duplicate Record Fields

Each duplicate record should include:

- duplicate record id
- correlation id
- idempotency key
- duplicate source
- duplicate timestamp
- duplicate basis
- existing operation reference
- current runtime state
- blocked effect
- allowed noop effect if any
- evidence reference
- support/Admin summary
- notes

Duplicate record proves protection.

---

## 17. Idempotency Key Creation Rule

Idempotency key must be created before external write operation.

External write operations include:

- payment request
- refund request
- cancel request
- POS order submit
- KDS ticket create
- provider mapping accept
- local daemon command
- Redtable-type partner payment request
- delivery platform action if applicable
- external menu projection publish/unpublish

No idempotency key means no retryable external write.

---

## 18. Idempotency Key Propagation Rule

Where supported, idempotency key should be propagated to external system.

Recommended header candidate:

    X-Yoonsul-Idempotency-Key

If provider has its own idempotency mechanism, mapping must be recorded.

If provider does not support idempotency, Yoonsul Gateway must still enforce internal idempotency.

Provider limitation does not remove internal obligation.

---

## 19. Idempotency Scope Rule

Idempotency scope must match logical operation.

Examples:

- one payment attempt
- one refund request
- one POS handoff
- one KDS ticket creation
- one provider callback event
- one external menu projection version
- one Redtable-type partner payment attempt

Using too broad a key blocks legitimate operations.

Using too narrow a key allows duplicates.

---

## 20. Idempotency Conflict Rule

Idempotency conflict occurs when same key is used for incompatible payload or operation.

Conflict should be:

- blocked
- evidence-linked
- support/Admin-visible if operationally relevant
- investigated
- prevented from mutating runtime truth
- marked for reconciliation if needed

Same key with different meaning is high-risk.

---

## 21. Idempotency Expiration Placeholder Rule

Idempotency key may require expiration planning.

Expiration should consider:

- payment dispute window
- provider callback replay window
- POS retry window
- KDS operational window
- refund/cancel window
- delivery platform resend window
- partner callback resend window
- support case window

Final expiration policy may be defined later.

---

## 22. Retry Eligibility Rule

Retry may be eligible when:

- timeout occurred
- provider temporary error occurred
- local daemon temporary unavailable
- network failure occurred
- rate limit suggests retry
- provider callback pending
- KDS/POS handoff uncertain
- external projection publish failed temporarily

Retry eligibility requires idempotency.

---

## 23. Retry Prohibition Rule

Retry is prohibited when:

- idempotency key missing
- operation already completed
- duplicate effect cannot be prevented
- provider returned permanent rejection
- payload conflict detected
- security validation failed
- legal/high-risk gate blocked
- customer cancellation changed state
- KDS state makes retry unsafe
- support/Admin review required first

Retry must not override state.

---

## 24. Retry Backoff Rule

Retry planning should define backoff.

Backoff may include:

- immediate retry prohibited for payment if uncertainty exists
- short retry interval for network transient
- exponential backoff for provider outage
- provider retry-after header if available
- max retry count
- manual review after exhaustion
- support escalation after uncertainty persists

Backoff prevents overload and duplicate confusion.

---

## 25. Retry Exhaustion Rule

Retry exhaustion means retry limit is reached.

Retry exhaustion should trigger:

- uncertainty or failure classification
- support/Admin visibility
- reconciliation requirement if money/POS/KDS is affected
- customer-safe message
- fallback path
- evidence packet update
- audit event if critical

Exhaustion is not silent failure.

---

## 26. Timeout Classification Rule

Timeout should be classified by impact.

Recommended impact classes:

- `TIMEOUT_NO_STATE_EFFECT`
- `TIMEOUT_PAYMENT_UNCERTAIN`
- `TIMEOUT_POS_UNCERTAIN`
- `TIMEOUT_KDS_UNCERTAIN`
- `TIMEOUT_PROVIDER_UNCERTAIN`
- `TIMEOUT_LOCAL_DAEMON_UNCERTAIN`
- `TIMEOUT_EXTERNAL_PROJECTION_UNCERTAIN`
- `TIMEOUT_SUPPORT_REVIEW_REQUIRED`
- `TIMEOUT_RECONCILIATION_REQUIRED`

Timeout classification drives recovery.

---

## 27. Payment Timeout Rule

Payment timeout must not be treated as payment failure by default.

Payment timeout should result in:

- payment uncertain state
- retry decision review
- provider callback wait if applicable
- reconciliation requirement
- duplicate payment prevention
- customer-safe message
- support escalation if unresolved
- evidence packet update

Payment timeout is one of the highest-risk cases.

---

## 28. POS Timeout Rule

POS timeout should result in POS uncertainty.

POS timeout should trigger:

- POS handoff uncertain status
- retry eligibility review
- local daemon/network check if applicable
- POS reconciliation requirement
- duplicate POS transaction prevention
- support/Admin visibility
- evidence packet update

POS timeout must not create duplicate order.

---

## 29. KDS Timeout Rule

KDS handoff timeout should protect kitchen execution.

KDS timeout should trigger:

- KDS handoff uncertain status
- duplicate ticket prevention
- manual kitchen fallback if needed
- staff-visible message
- support/Admin evidence
- reconciliation when KDS returns
- rollback/pause if repeated

KDS timeout must not create duplicate kitchen work.

---

## 30. Provider Callback Duplicate Rule

Provider callbacks must be deduplicated.

Deduplication should use:

- provider event id
- provider payment id
- provider transaction id
- idempotency key
- correlation id
- timestamp window
- current runtime state
- payload hash if needed

Duplicate callback should become no-op or blocked, not duplicate effect.

---

## 31. Provider Callback Replay Rule

Provider callback replay must be detected.

Replay indicators may include:

- same event id
- same payload hash
- old timestamp
- same provider signature replay
- same provider payment id
- already accepted canonical event

Replay must not mutate truth twice.

---

## 32. Stale Callback Rule

Stale callback means callback is older than current runtime state or outside valid window.

Stale callback should be:

- recorded
- classified
- quarantined if needed
- prevented from overwriting current state
- linked to evidence
- support/Admin-visible if impact exists

Stale callback must not regress state.

---

## 33. Payment Duplicate Prevention Rule

Payment duplicate prevention must block:

- duplicate payment attempt
- duplicate capture
- duplicate callback mutation
- duplicate refund request
- duplicate customer double tap
- duplicate partner payment attempt

Payment duplicate prevention must be strict.

Money errors destroy trust.

---

## 34. POS Duplicate Prevention Rule

POS duplicate prevention must block:

- duplicate POS order submission
- duplicate POS transaction creation
- duplicate receipt generation if avoidable
- duplicate local daemon resend
- duplicate provider-to-POS mapping

POS duplicate prevention requires handoff evidence and reconciliation.

---

## 35. KDS Duplicate Prevention Rule

KDS duplicate prevention must block:

- duplicate ticket creation
- duplicate item preparation
- duplicate remake if not intended
- duplicate cancel/release effect
- duplicate local retry effect

Kitchen duplicate work creates cost and confusion.

---

## 36. Mini Kiosk Duplicate Prevention Rule

Mini Kiosk duplicate prevention must block:

- double submit
- duplicate tap
- duplicate cart confirmation
- duplicate payment attempt
- duplicate staff call if spam-like
- duplicate abandoned flow recovery

Self-service UI must be protected from repeated actions.

---

## 37. Delivery Platform Duplicate Prevention Rule

Delivery platform duplicate prevention must block:

- duplicate platform order intake
- duplicate cancellation event
- duplicate rider pickup status
- duplicate provider event mapping
- duplicate KDS handoff

Delivery platforms may resend events.

Gateway must be resilient.

---

## 38. Redtable-Type Partner Duplicate Prevention Rule

Redtable-type partner duplicate prevention must block:

- duplicate translated menu projection publish
- duplicate partner payment attempt
- duplicate partner callback
- duplicate settlement mapping
- duplicate foreign customer recovery action

Partner integration remains external and evidence-required.

---

## 39. Local Daemon Duplicate Prevention Rule

Local daemon duplicate prevention must block:

- duplicate cloud-to-daemon command
- duplicate daemon-to-POS request
- duplicate daemon replay after reconnect
- duplicate local queue flush
- duplicate offline replay

Offline/local retry is high-risk without idempotency.

---

## 40. External Menu Projection Idempotency Rule

External menu projection should be idempotent.

Projection idempotency should use:

- store key
- menu version
- locale
- projection target
- publish/unpublish operation
- content hash

Repeated publish should not create conflicting public menus.

---

## 41. Uncertainty Rule

When retry/timeout/duplicate/stale handling cannot prove final outcome, state must be marked uncertain.

Uncertain state should trigger:

- support/Admin visibility
- customer-safe message if customer-facing
- reconciliation requirement
- fallback path
- evidence packet update
- no silent mutation

Uncertainty is safer than false finality.

---

## 42. Reconciliation Rule

Reconciliation is required when:

- timeout affects payment
- POS response unknown
- KDS handoff unknown
- provider callback conflicts
- duplicate event conflicts
- stale event cannot be ignored safely
- local daemon reconnects after offline state
- partner payment status unclear
- settlement report mismatches

Reconciliation must be evidence-linked.

---

## 43. Support View Rule

Support should see:

- correlation id
- idempotency key summary
- retry count
- timeout status
- duplicate/stale classification
- uncertainty state
- provider code summary
- customer-safe recovery guidance
- escalation path
- evidence availability

Support should not see raw secrets or unrestricted payload.

---

## 44. Admin View Rule

Admin should see:

- retry/timeout dashboard
- duplicate/stale event count
- provider incident clusters
- POS/KDS/payment uncertainty
- reconciliation task
- blocker status
- rollback/pause trigger
- evidence packet status
- audit linkage

Admin coordinates recovery.

Admin does not force truth.

---

## 45. AI Support Boundary Rule

AI support may summarize retry/timeout/duplicate state only from masked evidence.

AI support must not:

- decide final payment state
- approve refund
- release KDS
- blame provider without evidence
- expose idempotency internals to customer unnecessarily
- expose raw payload
- mutate runtime state

AI support may provide safe explanation and escalation guidance.

---

## 46. Evidence Rule

Every retry, timeout, duplicate, stale, replay, conflict, and uncertainty event should create or update evidence.

Evidence should include:

- correlation id
- idempotency key
- attempt number
- timestamp
- request evidence
- response evidence
- provider code
- classification
- blocked effect
- final outcome
- support/Admin summary

Evidence proves the defense.

---

## 47. Audit Rule

Audit is required when retry/timeout/duplicate handling affects:

- payment state
- refund/cancel decision
- KDS release
- POS accepted state
- provider mapping
- support escalation
- Admin review
- rollback/pause
- high-risk operation
- external partner payment

Audit must be append-only.

---

## 48. Build Gate Rule

Build gate must block external handoff when:

- idempotency key missing
- retry rule missing
- timeout classification missing
- duplicate handling missing
- stale handling missing
- replay handling missing
- uncertainty state missing
- reconciliation rule missing
- support/Admin visibility missing
- evidence rule missing
- audit rule missing when required
- customer-safe timeout/payment message missing
- i18n message missing for customer-facing flow

No idempotency, no retry.

---

## 49. Pilot Rule

Pilot dry run must test:

- duplicate customer submit
- payment timeout
- payment duplicate callback
- POS timeout
- POS retry
- KDS duplicate ticket prevention
- provider stale callback
- local daemon offline replay
- Redtable-type partner duplicate callback if applicable
- external menu projection repeated publish
- support lookup
- Admin reconciliation task

Pilot must prove duplicate prevention.

---

## 50. Registers Recommendation

Recommended future files:

    docs/_index/
      Idempotency_Key_Register.md
      Retry_Policy_Register.md
      Timeout_Record_Register.md
      Duplicate_Handoff_Register.md
      Duplicate_Callback_Register.md
      Stale_Callback_Register.md
      Replay_Protection_Register.md
      Uncertainty_State_Register.md
      Reconciliation_Trigger_Register.md
      Payment_Duplicate_Prevention_Register.md
      POS_Duplicate_Prevention_Register.md
      KDS_Duplicate_Prevention_Register.md
      Local_Daemon_Retry_Register.md
      Partner_Duplicate_Prevention_Register.md

This document only recommends these files.

It does not create them.

---

## 51. Anti-Patterns

The following are prohibited:

- retry without idempotency
- generating new idempotency key on retry
- treating timeout as success
- treating timeout as final failure without reconciliation
- duplicate callback mutating payment twice
- duplicate POS submit
- duplicate KDS ticket creation
- provider replay accepted as new event
- stale callback overwriting current truth
- local daemon replay without duplicate protection
- Mini Kiosk double tap creating duplicate payment
- customer-safe message missing during uncertainty
- Admin forcing state without evidence
- AI declaring provider fault without evidence

---

## 52. No-Code Boundary

This document does not authorize:

- idempotency implementation
- retry queue implementation
- timeout engine
- duplicate detector
- database schema
- API implementation
- provider adapter
- payment connector
- POS connector
- KDS connector
- Mini Kiosk implementation
- local daemon implementation
- Redtable integration
- support console
- Admin console
- production pilot

This document governs idempotency, retry, timeout, and duplicate external handoff policy only.

---

## 53. Readiness Check

This document is ready when the project can answer:

1. What is idempotency?
2. What is idempotency key?
3. What is retry?
4. What is timeout?
5. What is duplicate?
6. What idempotency status values exist?
7. What retry status values exist?
8. What timeout status values exist?
9. What duplicate status values exist?
10. What fields should idempotency record include?
11. What fields should retry record include?
12. What fields should timeout record include?
13. What fields should duplicate record include?
14. What idempotency key creation rule applies?
15. What idempotency key propagation rule applies?
16. What idempotency scope rule applies?
17. What idempotency conflict rule applies?
18. What expiration placeholder rule applies?
19. What retry eligibility rule applies?
20. What retry prohibition rule applies?
21. What retry backoff rule applies?
22. What retry exhaustion rule applies?
23. What timeout classification rule applies?
24. What payment timeout rule applies?
25. What POS timeout rule applies?
26. What KDS timeout rule applies?
27. What provider callback duplicate rule applies?
28. What provider callback replay rule applies?
29. What stale callback rule applies?
30. What payment duplicate prevention rule applies?
31. What POS duplicate prevention rule applies?
32. What KDS duplicate prevention rule applies?
33. What Mini Kiosk duplicate prevention rule applies?
34. What delivery platform duplicate prevention rule applies?
35. What Redtable-type partner duplicate prevention rule applies?
36. What local daemon duplicate prevention rule applies?
37. What external menu projection idempotency rule applies?
38. What uncertainty rule applies?
39. What reconciliation rule applies?
40. What Support view rule applies?
41. What Admin view rule applies?
42. What AI Support boundary rule applies?
43. What evidence rule applies?
44. What audit rule applies?
45. What build gate rule applies?
46. What pilot rule applies?
47. What registers are recommended?
48. What anti-patterns are prohibited?
49. What no-code boundary applies?

If these questions cannot be answered, idempotency, retry, timeout, and duplicate external handoff planning is incomplete.

---

## 54. Conclusion

Idempotency is the integrity shield against unstable external systems.

The safe external retry flow is:

    logical operation
        -> correlation id
        -> idempotency key
        -> request evidence
        -> external handoff
        -> response, timeout, duplicate, stale, or replay classification
        -> retry only if safe
        -> duplicate effect blocked
        -> uncertainty marked when final outcome is unknown
        -> reconciliation triggered when needed
        -> evidence and audit updated
        -> support/Admin/AI-safe summary created

This document ensures that POS, PG, VAN, payment provider, KDS, delivery platform, Redtable-type partner, local daemon, Mini Kiosk, and external projection instability cannot create duplicate payment, duplicate order, duplicate KDS ticket, duplicate settlement, or false runtime truth.

Retry is useful only when idempotency makes it safe.