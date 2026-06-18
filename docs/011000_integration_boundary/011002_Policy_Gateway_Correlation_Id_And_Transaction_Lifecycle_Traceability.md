# 011002_Policy_Gateway_Correlation_Id_And_Transaction_Lifecycle_Traceability

## 1. Purpose

This document defines the Gateway correlation id, transaction lifecycle traceability, cross-runtime timeline, external handoff linkage, support/Admin evidence lookup, retry attempt grouping, payment/KDS/POS/provider trace continuity, Redtable-type partner trace continuity, local daemon trace continuity, store network failure traceability, and no-code boundary policy for the Yoonsul Wait/Order Handoff operating system.

The previous document opened the 00300 Gateway Integrity, Audit, Correlation, Immutable Evidence, Idempotency, Black Box Provider Boundary, and External Handoff Responsibility Separation foundation band.

This document focuses on correlation id as the primary trace key that connects a customer action, order candidate, payment attempt, Gateway handoff, provider request, provider response, POS handoff, KDS handoff, retry attempt, timeout, support case, evidence packet, audit event, fallback action, and rollback action into one traceable lifecycle.

This document does not implement correlation id generation, logging, schema, API, Gateway, POS connector, provider adapter, payment connector, support console, Admin console, or observability system.

It defines correlation id and transaction lifecycle traceability policy only.

---

## 2. Scope

This document covers:

- correlation id foundation rule
- transaction lifecycle traceability
- trace timeline
- cross-runtime propagation
- external handoff propagation
- retry/timeout attempt grouping
- payment/KDS/POS/provider trace linkage
- support/Admin evidence lookup
- AI support trace boundary
- Redtable-type partner trace linkage
- local daemon/store network trace linkage
- trace search and dispute support
- no-code boundary

This document does not cover:

- actual UUID generation
- final ID format implementation
- database schema
- log storage implementation
- trace dashboard implementation
- distributed tracing implementation
- provider connector implementation
- production monitoring implementation

---

## 3. Core Principle

Every externally meaningful transaction must be traceable from origin to outcome.

The project must follow this rule:

> A customer-facing, staff-facing, payment-facing, KDS-facing, POS-facing, provider-facing, partner-facing, or support-facing transaction that crosses a Gateway boundary must carry a stable correlation id from its first internal creation point through every runtime event, Gateway handoff, external provider request, retry, timeout, response, evidence packet, audit event, fallback, rollback, and support case.

No correlation id means no defensible timeline.

No defensible timeline means no reliable dispute response.

---

## 4. Correlation ID Meaning

Correlation id means the lifecycle trace key used to group all records related to one operational transaction or transaction family.

Correlation id may link:

- customer session
- table session
- order candidate
- payment attempt
- refund/cancel request
- KDS ticket
- POS handoff
- provider request
- provider callback
- Mini Kiosk session
- delivery platform event
- Redtable-type partner event
- local daemon handoff
- evidence packet
- audit event
- support case
- Admin task
- pilot incident
- rollback record

Correlation id is not necessarily the primary key of each domain.

It is the trace spine.

---

## 5. Transaction Lifecycle Meaning

Transaction lifecycle means the full operational path from initial action to final accepted, rejected, completed, failed, uncertain, or recovered outcome.

Example lifecycle:

    customer action
        -> order candidate created
        -> payment attempt created
        -> Gateway payment request sent
        -> provider response received
        -> payment canonical event mapped
        -> POS handoff attempted
        -> KDS ticket created or held
        -> support case created if uncertain
        -> evidence packet completed
        -> audit timeline closed

Lifecycle may differ by runtime.

Correlation id must connect the lifecycle.

---

## 6. Correlation ID Status Values

Recommended status values:

- `CORRELATION_NOT_CREATED`
- `CORRELATION_CREATED`
- `CORRELATION_PROPAGATED`
- `CORRELATION_PARTIAL`
- `CORRELATION_EXTERNAL_MISSING`
- `CORRELATION_DUPLICATE`
- `CORRELATION_CONFLICT`
- `CORRELATION_RECONCILIATION_REQUIRED`
- `CORRELATION_CLOSED`
- `CORRELATION_BLOCKED`
- `CORRELATION_SUPERSEDED`

Status may be normalized later.

---

## 7. Correlation Record Fields

A correlation record should include:

- correlation id
- source runtime
- originating action
- originating timestamp
- customer session reference if applicable
- table session reference if applicable
- order reference if applicable
- payment attempt reference if applicable
- KDS ticket reference if applicable
- POS handoff reference if applicable
- provider reference if applicable
- local daemon reference if applicable
- partner reference if applicable
- evidence packet references
- audit event references
- support case references
- Admin task references
- final lifecycle status
- notes

The record should be searchable.

---

## 8. Correlation ID Format Rule

Recommended format:

    CORR-[UUID]

Example:

    CORR-8f2d8c3e-6a3e-4bb9-9d2d-f0f2b0e6d100

Final implementation may use UUID, ULID, UUIDv7, or another sortable unique format after implementation review.

The policy requirement is uniqueness, traceability, and propagation.

---

## 9. Creation Rule

Correlation id should be created at the earliest meaningful operational point.

Creation candidates include:

- customer session start
- table session start
- order candidate creation
- Mini Kiosk session start
- payment attempt creation
- provider callback receipt if no prior correlation exists
- support case creation for orphaned external event
- pilot dry run scenario start

If an external event arrives without correlation id, the Gateway should create an orphan trace record and mark it for reconciliation.

---

## 10. Propagation Rule

Correlation id must be propagated across:

- internal runtime events
- command records
- query projections if needed
- Gateway request
- Gateway response
- provider adapter record
- payment attempt
- refund/cancel review
- POS handoff
- KDS handoff
- Mini Kiosk session
- support case
- Admin task
- evidence packet
- audit event
- fallback record
- rollback record

Correlation id must not be dropped during transformation.

---

## 11. Header Rule

Where protocol allows, Gateway should send correlation id as a request header or equivalent metadata.

Recommended header candidate:

    X-Yoonsul-Correlation-Id

If provider does not accept custom headers, correlation id may be stored in:

- internal Gateway record
- provider metadata field if supported
- request reference field if supported
- evidence packet
- local daemon envelope
- support-visible timeline

Provider limitation must not break internal traceability.

---

## 12. External Provider Propagation Rule

External providers may or may not preserve correlation id.

Gateway must record:

- whether correlation id was sent
- where it was sent
- whether provider echoed it
- provider request id
- provider response id
- provider trace id if available
- mapping between Yoonsul correlation id and provider references

Provider not echoing correlation id is not failure.

Losing internal mapping is failure.

---

## 13. Provider Reference Linkage Rule

Gateway must link correlation id with provider references.

Provider references may include:

- provider request id
- provider payment id
- provider transaction id
- provider order id
- provider callback id
- provider trace id
- provider settlement id
- provider error reference
- partner reference id

Provider references must not replace correlation id.

---

## 14. Runtime Reference Linkage Rule

Correlation id must link runtime references without making them identical.

Runtime references may include:

- customer session id
- table session id
- order id
- order item id
- payment attempt id
- refund request id
- KDS ticket id
- POS handoff id
- provider event id
- support case id
- evidence packet id
- audit event id

Correlation id groups them.

It does not replace domain identity.

---

## 15. Payment Lifecycle Trace Rule

Payment lifecycle trace should include:

- payment attempt created
- provider request prepared
- provider request sent
- provider response received
- provider callback received if applicable
- payment state mapped
- duplicate/stale callback classification
- uncertainty classification
- reconciliation requirement
- refund/cancel linkage if applicable
- support escalation if applicable
- evidence packet
- audit event

Payment trace is mandatory.

---

## 16. Refund Cancel Lifecycle Trace Rule

Refund/cancel lifecycle trace should include:

- refund/cancel request created
- requester role
- payment linkage
- KDS linkage
- review state
- approval/rejection
- provider refund request if applicable
- provider refund response
- customer message
- support case if needed
- evidence packet
- audit event

Refund/cancel must remain traceable.

---

## 17. KDS Lifecycle Trace Rule

KDS lifecycle trace should include:

- KDS ticket candidate
- ticket created
- ticket hold
- ticket release
- preparation start
- ready state
- served state
- cancel request
- remake/retry
- duplicate/stale handling
- payment dependency if applicable
- evidence packet
- audit event if needed

KDS trace must not expose customer identity unnecessarily.

---

## 18. POS Lifecycle Trace Rule

POS lifecycle trace should include:

- POS handoff candidate
- POS request prepared
- POS request sent
- POS response received
- POS accepted/rejected state
- POS timeout
- POS retry
- POS reconciliation requirement
- POS receipt or ledger reference if available
- evidence packet
- audit event

POS black-box boundary requires trace.

---

## 19. Provider Adapter Lifecycle Trace Rule

Provider adapter trace should include:

- external event received
- signature/auth validation
- idempotency check
- duplicate check
- stale check
- mapping candidate
- quarantine if needed
- canonical event candidate
- target runtime
- accepted/rejected result
- provider evidence packet
- audit event if needed

Provider event without trace must not mutate truth.

---

## 20. Mini Kiosk Lifecycle Trace Rule

Mini Kiosk trace should include:

- session start
- device context
- locale selection
- menu view
- cart candidate
- payment attempt link
- timeout
- abandoned flow
- staff call
- support case if needed
- evidence packet
- recovery action

Mini Kiosk trace protects self-service flow.

---

## 21. Delivery Platform Lifecycle Trace Rule

Delivery platform trace should include:

- platform event received
- platform order candidate
- payment boundary if applicable
- KDS handoff candidate
- cancellation event
- rider/pickup status if available
- provider mapping
- duplicate/stale classification
- support escalation
- evidence packet
- audit event if needed

Delivery events remain external candidates until validated.

---

## 22. Redtable-Type Partner Lifecycle Trace Rule

Redtable-type partner trace should include:

- partner entry source
- external menu projection reference
- translated menu content version
- customer locale
- global payment method candidate
- partner payment request if applicable
- partner payment response if applicable
- partner callback if applicable
- settlement reference if applicable
- support case if needed
- evidence packet
- provider capability evidence reference

Partner trace must separate public menu projection from payment truth.

---

## 23. Local Daemon Lifecycle Trace Rule

Local daemon trace should include:

- cloud handoff created
- local daemon delivery attempted
- local daemon received/not received
- local daemon sent to POS/not sent
- POS response received/not received
- local timeout
- device offline marker
- store network issue marker
- retry attempt
- evidence packet
- support/Admin status

Local daemon trace separates cloud failure from store-side failure.

---

## 24. Store Network Trace Rule

Store network trace should identify possible store-side failure points.

Trace candidates:

- store router unreachable
- POS PC offline
- local daemon offline
- Wi-Fi unstable
- internet disconnected
- device time skew
- operator closed POS
- operator restarted PC
- POS application not responding
- firewall/proxy issue

Store network trace must be evidence-backed, not guessed.

---

## 25. Retry Attempt Grouping Rule

All retry attempts must share the same correlation id.

Retry records should include:

- attempt number
- idempotency key
- request evidence reference
- response evidence reference
- error code
- timeout status
- retry reason
- delay
- final outcome
- uncertainty status

Retry grouping proves non-duplication.

---

## 26. Timeout Trace Rule

Timeout trace must show:

- request sent time
- timeout threshold
- timeout occurred time
- provider endpoint
- retry decision
- uncertainty classification
- support message
- fallback action
- reconciliation requirement

Timeout must not be hidden as generic failure.

---

## 27. Duplicate Trace Rule

Duplicate trace must show:

- duplicate detection basis
- idempotency key
- existing correlation id
- duplicate source
- duplicate timestamp
- current runtime state
- blocked duplicate effect
- evidence output
- support/Admin message if needed

Duplicate handling must be provable.

---

## 28. Stale Event Trace Rule

Stale event trace must show:

- external event timestamp
- received timestamp
- current runtime state
- stale threshold
- stale classification
- quarantine action
- rejected mutation
- evidence packet
- support/Admin status if needed

Stale event must not overwrite newer truth.

---

## 29. Evidence Packet Linkage Rule

Every meaningful trace should link to evidence packet.

Evidence packet should include:

- correlation id
- idempotency key if applicable
- runtime references
- request evidence
- response evidence
- provider references
- status/result
- mapping result
- audit references
- support/Admin summary

Evidence packet makes trace usable.

---

## 30. Audit Event Linkage Rule

Audit events should include correlation id when related to external handoff or critical runtime action.

Audit linkage applies to:

- payment state change
- refund/cancel decision
- KDS hold/release
- provider mapping
- support access
- Admin review
- export/unmask request
- high-risk operation
- rollback action
- pilot incident

Audit without correlation weakens timeline.

---

## 31. Support Case Linkage Rule

Support case should include correlation id when case is tied to transaction.

Support can then trace:

- customer claim
- order/payment/KDS status
- provider response
- POS handoff
- timeout/retry
- evidence packet
- recovery action
- escalation path

Support case without trace creates manual investigation burden.

---

## 32. Admin Task Linkage Rule

Admin task should include correlation id when it concerns:

- blocker review
- provider incident
- payment uncertainty
- KDS mismatch
- POS reconciliation
- external partner issue
- pilot incident
- rollback review

Admin task should not be detached from timeline.

---

## 33. AI Support Trace Boundary Rule

AI support may use correlation-linked trace only when:

- support case scope exists
- trace summary is masked
- raw sensitive payload is excluded
- source/evidence reference is available
- confidence is shown
- human review applies
- no final legal/payment conclusion is made

AI may summarize trace.

AI must not invent trace.

---

## 34. Search Rule

Operational systems should allow searching by:

- correlation id
- idempotency key
- order id
- payment attempt id
- provider request id
- provider response id
- POS handoff id
- KDS ticket id
- support case id
- evidence packet id
- audit event id

Correlation id should be the preferred starting point.

---

## 35. Dispute Response Rule

When a dispute occurs, correlation trace should answer:

- when the transaction began
- what Yoonsul accepted
- what Yoonsul rejected
- what Yoonsul sent externally
- what external system returned
- whether timeout occurred
- whether retry occurred
- whether duplicate was blocked
- whether stale event was quarantined
- which runtime owns final state
- what evidence supports the conclusion

Dispute response must rely on evidence, not memory.

---

## 36. Missing Correlation Rule

If a record is missing correlation id, it must be treated as trace defect.

Possible status:

- `CORRELATION_EXTERNAL_MISSING`
- `CORRELATION_INTERNAL_MISSING`
- `CORRELATION_RECONCILIATION_REQUIRED`
- `CORRELATION_ORPHAN_EVENT`
- `CORRELATION_BLOCKED`

Missing correlation should create blocker for critical flows.

---

## 37. Orphan Event Rule

Orphan external event means event arrived without known correlation or known mapping.

Orphan event should be:

- recorded
- quarantined
- assigned investigation reference
- linked to provider reference
- searched against recent transactions
- reconciled or rejected
- prevented from mutating runtime truth until resolved

Orphan event is not ignored.

---

## 38. Correlation Conflict Rule

Correlation conflict occurs when one external reference maps to multiple internal correlation ids or one correlation id maps to incompatible external references.

Conflict should be:

- blocked
- investigated
- evidence-linked
- support-visible if customer impact exists
- Admin-visible if operational impact exists
- prevented from mutating truth until resolved

Correlation conflict is high-risk.

---

## 39. Privacy Rule

Correlation id must not encode sensitive data.

Correlation id must not include:

- customer name
- phone number
- email
- CI/DI
- card number
- store secret
- provider secret
- menu secret
- internal staff identity in readable form

Correlation id should be opaque.

---

## 40. Retention Placeholder Rule

Correlation trace retention should consider:

- payment dispute period
- refund/cancel dispute period
- provider dispute period
- POS reconciliation period
- support case period
- audit retention
- pilot evidence period
- legal hold
- security incident review

Final retention policy may be defined later.

---

## 41. Build Gate Rule

Build gate must block external handoff if:

- correlation id not created
- correlation id not propagated
- provider references not linked
- retry attempts not grouped
- timeout not traceable
- duplicate handling not traceable
- stale handling not traceable
- evidence packet not linked
- audit event not linked when required
- support/Admin lookup not possible
- orphan/conflict handling undefined

Traceability is mandatory.

---

## 42. Pilot Rule

Pilot dry run must test correlation trace.

Required dry run scenarios:

- successful payment trace
- payment timeout trace
- provider error trace
- duplicate callback trace
- stale callback trace
- POS rejection trace
- local daemon offline trace
- KDS hold trace
- support case lookup trace
- rollback trace

Pilot must prove trace usability.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      Correlation_Id_Register.md
      Transaction_Lifecycle_Trace_Register.md
      Provider_Reference_Linkage_Register.md
      Retry_Attempt_Trace_Register.md
      Timeout_Trace_Register.md
      Duplicate_Trace_Register.md
      Stale_Event_Trace_Register.md
      Orphan_Event_Correlation_Register.md
      Correlation_Conflict_Register.md
      Support_Correlation_Lookup_Register.md
      Admin_Correlation_Task_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- transaction without correlation id
- retry attempt with new unrelated correlation id
- provider reference replacing correlation id
- support case without transaction trace
- Admin task without timeline reference
- timeout hidden as generic failure
- duplicate blocked without evidence
- stale event rejected without trace
- orphan event mutating runtime truth
- correlation id containing personal data
- AI summarizing trace without evidence
- POS dispute handled without correlation timeline

---

## 45. No-Code Boundary

This document does not authorize:

- correlation id implementation
- UUID generation code
- database schema
- logging implementation
- tracing system implementation
- API header implementation
- Gateway implementation
- provider adapter
- POS connector
- payment connector
- support console
- Admin console
- AI support gateway
- production monitoring

This document governs correlation id and transaction lifecycle traceability policy only.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. What is correlation id?
2. What is transaction lifecycle?
3. What status values exist?
4. What fields should correlation record include?
5. What ID format is recommended?
6. When is correlation created?
7. How is correlation propagated?
8. What header rule applies?
9. What external provider propagation rule applies?
10. What provider reference linkage rule applies?
11. What runtime reference linkage rule applies?
12. What payment lifecycle trace rule applies?
13. What refund/cancel lifecycle trace rule applies?
14. What KDS lifecycle trace rule applies?
15. What POS lifecycle trace rule applies?
16. What provider adapter lifecycle trace rule applies?
17. What Mini Kiosk lifecycle trace rule applies?
18. What delivery platform lifecycle trace rule applies?
19. What Redtable-type partner lifecycle trace rule applies?
20. What local daemon lifecycle trace rule applies?
21. What store network trace rule applies?
22. What retry attempt grouping rule applies?
23. What timeout trace rule applies?
24. What duplicate trace rule applies?
25. What stale event trace rule applies?
26. What evidence packet linkage rule applies?
27. What audit event linkage rule applies?
28. What support case linkage rule applies?
29. What Admin task linkage rule applies?
30. What AI support trace boundary rule applies?
31. What search rule applies?
32. What dispute response rule applies?
33. What missing correlation rule applies?
34. What orphan event rule applies?
35. What correlation conflict rule applies?
36. What privacy rule applies?
37. What retention placeholder rule applies?
38. What build gate rule applies?
39. What pilot rule applies?
40. What registers are recommended?
41. What anti-patterns are prohibited?
42. What no-code boundary applies?

If these questions cannot be answered, Gateway correlation and lifecycle traceability planning is incomplete.

---

## 47. Conclusion

Correlation id is the trace spine of Gateway integrity.

The safe trace flow is:

    first meaningful action
        -> correlation id created
        -> runtime records linked
        -> Gateway handoff linked
        -> provider references linked
        -> retry/timeout/duplicate/stale handling linked
        -> evidence packet linked
        -> audit event linked
        -> support/Admin/AI trace summary linked
        -> final lifecycle outcome recorded

This document ensures that Yoonsul can reconstruct the full transaction lifecycle when a customer, store, POS vendor, payment provider, Redtable-type partner, delivery platform, or support team asks what happened.

Without correlation, there is no timeline.

Without timeline, there is no proof.

Without proof, there is no operational defense.