# 010620_Policy_Command_Query_Projection_Separation.md

## Purpose

This document defines the Command, Query, and Projection Separation Policy.

The previous artifact `10610 Cross-Room Event Bus And Evidence Packet Routing Policy` defined how cross-room events and evidence packets flow across Store Runtime, Financial Trust, Data Governance, Security, AI, pgvector, CMS, i18n, Device Runtime, Provider Adapter, Reconciliation, Sensor Runtime, Physical Automation, SCM, and Franchise OS.

This document defines how every interaction with that event/evidence structure must be separated into:

1. Commands
2. Queries
3. Projections
4. Events
5. Evidence packets
6. Audits
7. Reconciliation cases

The purpose is to prevent read models, dashboards, AI summaries, provider callbacks, sensor observations, customer UI states, and support screens from silently becoming mutation authority.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Every system action must be classified before it is allowed to move data.

The correct rule is:

Command requests mutation.  
Command is not authority by itself.  
Query reads source or derived state.  
Query must not mutate.  
Projection is safe visibility.  
Projection is not source truth.  
Event records something that happened or was observed.  
Event is not command.  
Evidence supports review.  
Evidence is not approval.  
Audit records trace.  
Audit is not execution.  
AI output is advisory.  
AI output is not command.  
Sensor observation is evidence candidate.  
Sensor observation is not financial mutation.  
Provider callback is external signal.  
Provider callback is not verified state until matched.  

The platform must never allow mixed read/write surfaces where visibility accidentally becomes authority.

---

## 3. Interaction Type Catalog

All cross-room interactions must be classified as one of the following:

| Type | Meaning |
|---|---|
| `COMMAND` | Request to change state |
| `QUERY` | Request to read source or derived state |
| `PROJECTION` | Audience-safe derived visibility |
| `EVENT` | Recorded fact, observation, or state transition |
| `EVIDENCE_PACKET` | Structured evidence bundle |
| `AUDIT_RECORD` | Trace of action, access, or processing |
| `RECONCILIATION_CASE` | Mismatch or uncertainty requiring resolution |
| `DLQ_RECORD` | Unsafe or unprocessable event/message |
| `POLICY_DECISION` | Rule evaluation result |
| `AI_ADVISORY_OUTPUT` | AI-generated recommendation or explanation |
| `SENSOR_OBSERVATION` | Physical/vision/audio/UWB/NFC/IoT context signal |
| `PROVIDER_SIGNAL` | External PG/VAN/card/bank/provider callback or report |

No runtime object may skip classification.

---

## 4. Command Boundary

Command is a request to change state.

Examples:

- create order
- accept order
- cancel order
- request payment authorization
- request capture
- request refund
- request auth release
- create KDS ticket
- retry POS handoff
- mark kitchen started
- mark kitchen completed
- apply coupon
- redeem points
- create settlement candidate
- approve compensation
- create manual adjustment
- activate policy version
- publish CMS content
- create supplier order request
- send IoT command candidate
- open circuit breaker
- approve fast payout
- submit split payout
- create export request

Command must pass authority gate.

Command must produce event, audit, and evidence where required.

Command must never be inferred merely from a query or projection.

---

## 5. Command Required Fields

Every command should carry:

- command id
- command type
- command version
- requester actor id
- requester role
- tenant id
- store id if applicable
- legal entity id if applicable
- target object id
- authority context
- policy version
- idempotency key
- causation id
- correlation id
- reason code if applicable
- evidence packet id if required
- requested at timestamp
- source surface id
- device id if applicable
- expected state/version if applicable
- audit reference

Missing authority context must fail closed.

---

## 6. Command State Skeleton

Recommended command states:

| State | Meaning |
|---|---|
| `COMMAND_RECEIVED` | Command received |
| `COMMAND_VALIDATING` | Schema and scope validating |
| `COMMAND_AUTHORITY_CHECKING` | Authority gate checking |
| `COMMAND_POLICY_CHECKING` | Policy rule checking |
| `COMMAND_IDEMPOTENCY_CHECKING` | Duplicate/retry checking |
| `COMMAND_ACCEPTED` | Accepted for execution |
| `COMMAND_REJECTED` | Rejected safely |
| `COMMAND_EXECUTING` | Execution in progress |
| `COMMAND_EXECUTED` | Execution completed |
| `COMMAND_DEFERRED` | Execution deferred |
| `COMMAND_REVIEW_REQUIRED` | Human review required |
| `COMMAND_RECONCILIATION_REQUIRED` | Reconciliation required |
| `COMMAND_DLQ_REQUIRED` | DLQ required |

Command accepted is not command executed.

---

## 7. Query Boundary

Query reads data.

Examples:

- fetch order status
- fetch payment status
- fetch KDS status
- fetch customer wait position
- fetch owner dashboard
- fetch settlement summary
- fetch refund review list
- fetch DLQ cases
- fetch audit timeline
- fetch policy version
- fetch device health
- fetch inventory snapshot
- fetch AI advisory output
- fetch vector retrieval result
- fetch safe projection

Query must not mutate state.

Query must not trigger payment, refund, capture, payout, KDS ticket, IoT command, supplier order, policy activation, or export delivery.

---

## 8. Query Required Fields

Every query should carry:

- query id
- query type
- requester actor id
- requester role
- tenant id
- store id if applicable
- legal entity id if applicable
- audience class
- visibility class
- data class requested
- masking class required
- purpose
- source surface id
- pagination/window if applicable
- requested at timestamp
- audit requirement
- export flag if applicable

Query must be scope-limited.

Unbounded cross-tenant query is prohibited by default.

---

## 9. Projection Boundary

Projection is a derived, audience-safe view.

Examples:

- customer order status
- customer wait estimate
- customer payment pending message
- store KDS board
- staff order queue
- owner settlement dashboard
- HQ franchise aggregate
- platform margin dashboard
- CS timeline
- audit review timeline
- no-show evidence summary
- batch close monitor
- provider route status
- AI explanation view
- sensor context summary

Projection is not source truth.

Projection must be rebuildable from source events and evidence.

Projection must be masked and audience-scoped.

---

## 10. Projection Required Fields

Every projection should carry:

- projection id
- projection type
- source event ids
- source object ids
- source room
- tenant id
- store id if applicable
- legal entity id if applicable
- audience class
- visibility class
- masking class
- generated at timestamp
- freshness marker
- stale marker
- conflict marker
- policy version
- i18n message keys if human-facing
- audit reference
- source hash if applicable

Projection must show uncertainty when source state is uncertain.

---

## 11. Projection State Skeleton

Recommended projection states:

| State | Meaning |
|---|---|
| `PROJECTION_NOT_READY` | Projection unavailable |
| `PROJECTION_BUILDING` | Projection building |
| `PROJECTION_READY` | Projection ready |
| `PROJECTION_STALE` | Projection stale |
| `PROJECTION_CONFLICT` | Source conflict |
| `PROJECTION_MASKED` | Masking applied |
| `PROJECTION_REDACTED` | Sensitive data redacted |
| `PROJECTION_REBUILD_REQUIRED` | Rebuild needed |
| `PROJECTION_SUPPRESSED` | Suppressed for safety/privacy |
| `PROJECTION_REVIEW_REQUIRED` | Human review needed |

Projection conflict must not be hidden.

---

## 12. Event Boundary

Event records a fact, observation, or state transition.

Examples:

- order submitted
- payment authorization approved
- provider callback received
- KDS ticket created
- kitchen completed
- refund requested
- refund confirmed
- settlement candidate generated
- device offline
- printer failed
- NFC tap detected
- UWB match candidate
- vision event candidate
- acoustic overload detected
- supplier order accepted
- policy activated
- DR failover started

Event is not command.

Events may trigger routing, projection, audit, or review, but command authority must still be checked where mutation is required.

---

## 13. Evidence Packet Boundary

Evidence packet bundles references that support review, reconciliation, dispute handling, audit, or due diligence.

Evidence packet may support:

- payment confirmation
- chargeback defense
- no-show penalty review
- manual adjustment
- fast payout approval
- settlement close
- DR recovery
- policy change
- supplier order review
- sensor-derived candidate
- IoT command execution
- KYC/account ownership
- split payout
- owner dashboard explanation

Evidence packet must not approve action by itself.

Human or policy authority must still exist.

---

## 14. Audit Boundary

Audit records access, processing, command, event handling, routing, projection, and review.

Audit may answer:

- who requested
- what was requested
- when it happened
- what policy applied
- what state changed
- what evidence supported it
- who approved
- which projection was viewed
- which export was generated
- which event was quarantined
- which command was rejected

Audit is not execution.

Audit must not be used to mutate source truth.

---

## 15. Reconciliation Case Boundary

Reconciliation case is created when state is uncertain or inconsistent.

Examples:

- provider callback mismatch
- amount mismatch
- hash mismatch
- ledger gap
- duplicate capture risk
- refund sequence conflict
- KDS completed but payment unknown
- local/offline sync conflict
- virtual close mismatch
- chargeback state conflict
- policy version conflict
- sensor event conflict
- supplier invoice mismatch
- DR sequence gap

Reconciliation case must preserve uncertainty.

Reconciliation must not silently overwrite source records.

---

## 16. DLQ Boundary

DLQ record isolates unsafe, malformed, conflicting, or unprocessable messages/events.

DLQ is used for:

- invalid schema
- missing tenant/store scope
- illegal state transition
- invalid signature
- replay detected
- cross-tenant mismatch
- provider unknown state
- idempotency conflict
- stale event version
- unsupported event family
- privacy violation
- sensor low confidence with high-impact intent
- policy mismatch

DLQ is not deletion.

DLQ requires review or controlled replay.

---

## 17. Command vs Event Boundary

Command asks for action.

Event records that something happened or was observed.

Examples:

| Command | Event |
|---|---|
| `RequestCapture` | `CaptureRequested`, `CaptureConfirmed` |
| `AcceptOrder` | `OrderAccepted` |
| `CreateKDSTicket` | `KDSTicketCreated` |
| `RequestRefund` | `RefundRequested`, `RefundConfirmed` |
| `ActivatePolicy` | `PolicyActivated` |
| `SendIoTCommand` | `DeviceCommandSent`, `DeviceCommandCompleted` |
| `SubmitSupplierOrder` | `SupplierOrderRequested`, `SupplierOrderAccepted` |

Event must not be treated as implicit command unless a policy explicitly defines a controlled reaction path.

---

## 18. Query vs Projection Boundary

Query is the act of reading.

Projection is what is read.

Example:

- Query: “Fetch owner settlement dashboard.”
- Projection: owner-safe settlement dashboard generated from financial source records.

Query must not mutate projection.

Projection must not mutate source.

Refreshing projection must be a controlled rebuild, not hidden source mutation.

---

## 19. Projection vs Source Truth Boundary

Source truth belongs to domain rooms.

Projection may show:

- simplified status
- masked data
- aggregated totals
- customer-safe wording
- owner-safe summary
- HQ aggregate
- support timeline
- AI explanation
- sensor summary

Projection must not be used as the input for irreversible financial mutation unless explicitly allowed as a derived input with source references validated.

---

## 20. AI Advisory Separation Boundary

AI may produce:

- explanation
- summary
- recommendation
- anomaly ranking
- likely cause
- wait estimate
- demand forecast
- abuse score candidate
- support draft
- translation draft
- policy simulation commentary

AI output must not directly become:

- refund approval
- penalty capture
- settlement finalization
- payout approval
- KDS execution
- IoT command
- supplier order
- account change
- policy activation
- customer restriction

AI output may create review candidate.

---

## 21. Sensor Observation Separation Boundary

Sensor observation may include:

- NFC tap
- QR scan
- UWB match
- vision detection
- acoustic overload
- IoT telemetry
- SoftPOS tap evidence
- local mesh event
- printer status
- device health

Sensor observation must not directly create final charge, penalty, settlement, or accusation.

Sensor observation must be matched, reviewed, or validated under policy before high-impact action.

---

## 22. Provider Signal Separation Boundary

Provider signal may include:

- authorization approved
- capture confirmed
- refund confirmed
- acquiring accepted
- chargeback notice
- payout completed
- account verification response
- settlement file record
- FDS risk signal

Provider signal must be verified:

- signature
- provider id
- merchant id
- transaction id
- amount
- currency
- tenant/store/legal mapping
- duplicate/replay status
- policy context
- state transition legality

Provider signal is external evidence.

It becomes internal truth only after matching and state transition.

---

## 23. CMS And i18n Separation Boundary

CMS content and i18n messages are visibility and communication layers.

CMS/i18n must not:

- approve refund
- issue coupon
- confirm settlement
- create no-show penalty
- change policy
- mutate payment state
- mutate order state
- override safety state

CMS may publish message.

i18n may render message.

Neither is business authority.

---

## 24. Analytics Separation Boundary

Analytics may show trends, aggregates, and benchmarks.

Analytics must not:

- finalize settlement
- enforce penalty
- approve payout
- determine legal liability
- punish store
- change pricing alone
- create supplier order alone
- override ledger truth

Analytics may inform policy review or operator decision.

Analytics aggregate must not replace source records.

---

## 25. pgvector Separation Boundary

pgvector retrieval may find similar cases, SOPs, prior incidents, and related context.

pgvector must not:

- prove current fact
- approve action
- decide dispute
- resolve DLQ
- finalize reconciliation
- execute command
- expose cross-tenant context

Similarity is not proof.

Retrieved context must be cited to source references.

---

## 26. Store Runtime Separation Boundary

Store Runtime may own operational execution state.

It must not own:

- final payment truth
- provider settlement truth
- payout truth
- legal/tax conclusion
- account ownership truth
- platform revenue truth

Store Runtime may command operational actions only within authority.

Financial Trust owns financial finality.

---

## 27. Financial Trust Separation Boundary

Financial Trust owns:

- payment state
- refund/cancel/void state
- value ledger
- settlement allocation
- payout state
- double-entry ledger
- fixed-point calculation
- chargeback financial impact
- fast payout exposure
- split payout state
- no-show penalty financial state

Financial Trust must not own:

- kitchen execution truth
- physical device safety truth
- customer identity beyond payment scope
- raw sensor truth
- CMS wording truth
- AI explanation truth

Financial Trust consumes evidence but does not own every source.

---

## 28. Data Governance Separation Boundary

Data Governance owns:

- masking
- projection
- i18n message key governance
- export
- retention
- privacy controls
- AI context eligibility
- vector source eligibility
- analytics read model visibility
- evidence access visibility

Data Governance must not directly execute store operations or financial movements.

It governs visibility and lifecycle.

---

## 29. Security Separation Boundary

Security Agent may detect, alert, contain, quarantine, or recommend.

Security Agent must not:

- silently reverse payment
- finalize refund
- finalize settlement
- accuse customer legally
- punish staff automatically
- approve policy change
- release containment without authority
- mutate ledger truth

Security provides risk control.

Business and financial authority remain separated.

---

## 30. Projection Audience Boundary

Projection must be audience-specific.

Audience classes may include:

- customer
- store staff
- kitchen
- owner
- franchise HQ
- platform support
- platform finance
- platform security
- auditor
- legal/compliance
- AI internal context
- public/export

Each audience sees different fields.

Same source truth may produce multiple projections.

Projection class must be explicit.

---

## 31. Mutation From Projection Boundary

Mutation from projection is prohibited unless converted into a new command.

Example:

- Owner dashboard shows “refund candidate.”
- Owner clicks “approve refund.”
- This creates `ApproveRefundCommand`.
- Command passes authority/policy/idempotency.
- Event records result.
- Projection refreshes.

Dashboard click is not direct mutation.

It must become command.

---

## 32. Command Authorization Gate Boundary

Every command must pass authority gate.

Authority gate checks:

- actor identity
- role
- tenant/store/legal scope
- device trust
- policy version
- feature entitlement
- state transition legality
- amount/threshold
- multi-party approval if needed
- evidence requirement
- risk state
- circuit breaker state
- audit requirement

Command without authority must be rejected.

---

## 33. Query Authorization Gate Boundary

Every query must pass visibility gate.

Visibility gate checks:

- actor identity
- role
- tenant/store/legal scope
- audience class
- data class
- masking class
- purpose
- support session scope
- export flag
- retention/legal hold
- privacy policy

Query without visibility must be denied.

---

## 34. Projection Build Gate Boundary

Projection build must check:

- source availability
- source consistency
- masking policy
- i18n policy
- audience policy
- freshness
- conflict state
- privacy/redaction
- legal hold/export limitations
- tenant isolation
- audit requirement

Projection must not hide uncertainty.

---

## 35. Event Reaction Boundary

Events may trigger reactions.

Reactions must be classified:

| Reaction Type | Meaning |
|---|---|
| `PROJECT_ONLY` | Update projection only |
| `AUDIT_ONLY` | Audit only |
| `REVIEW_CASE` | Create review case |
| `RECONCILIATION_CASE` | Create reconciliation case |
| `DLQ_ROUTE` | Send to DLQ |
| `COMMAND_CANDIDATE` | Create command candidate requiring authority |
| `AUTO_COMMAND_ALLOWED` | Auto command only if policy explicitly allows |
| `SECURITY_CONTAINMENT` | Containment under security policy |
| `NOTIFICATION` | Send customer/store/admin message |

Auto-command must be rare, policy-bound, idempotent, and audited.

---

## 36. Auto-Command Boundary

Some low-risk automated commands may be allowed later.

Examples may include:

- rebuild projection
- send reminder
- expire stale projection
- route to DLQ
- mark stale stream
- open low-risk circuit breaker
- throttle non-critical intake
- request reconciliation case

High-impact automated commands require separate authorization packet.

Examples requiring caution:

- capture payment
- refund payment
- impose no-show penalty
- create supplier order
- send IoT cooking command
- activate pricing policy
- approve payout
- release settlement hold

Auto-command is not allowed by this document.

---

## 37. Evidence-First High-Impact Action Boundary

High-impact actions require evidence before command acceptance.

High-impact actions include:

- payment capture
- refund approval
- penalty capture
- settlement finalization
- payout execution
- split payout
- fast payout
- manual adjustment
- policy activation
- KYC/account change
- supplier order
- IoT command
- sensor-derived billing
- DR failover promotion
- WORM period close

Missing evidence must block or route to review.

---

## 38. Human Review Boundary

Human review is required when:

- AI confidence is low but impact is high
- sensor event impacts billing or penalty
- provider state unknown
- financial mismatch exists
- manual adjustment requested
- policy activation high-risk
- KYC mismatch exists
- no-show penalty disputed
- chargeback response required
- supplier order exceeds threshold
- IoT command safety conflict exists
- DR recovery gap exists

Human review must produce event, audit, and evidence.

---

## 39. Anti-Patterns

Avoid:

- dashboard button mutating DB directly
- query endpoint with hidden side effect
- projection table used as source of settlement truth
- AI summary approving refund
- sensor event creating charge directly
- provider callback mutating payment without matching
- CMS message treated as coupon issuance
- analytics metric used as punishment authority
- pgvector result treated as proof
- event bus treated as source truth
- audit log used to execute business action
- command without authority context
- query without audience/masking context
- projection hiding stale/conflict state
- auto-command without explicit policy

These anti-patterns must be blocked in future runtime design.

---

## 40. Runtime Deferral

This document defines command, query, projection, event, evidence, audit, reconciliation, DLQ, AI, sensor, provider, CMS, analytics, pgvector, security, and authority separation boundaries only.

It does not authorize:

- command handler implementation
- query API implementation
- projection table implementation
- event reaction runtime
- CQRS infrastructure
- dashboard actions
- AI routing runtime
- sensor routing runtime
- authority gate implementation
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 41. Validation Checklist

Validation must confirm:

1. Interaction type catalog is defined.
2. Command boundary is defined.
3. Command required fields are defined.
4. Command state skeleton is defined.
5. Query boundary is defined.
6. Query required fields are defined.
7. Projection boundary is defined.
8. Projection required fields are defined.
9. Projection state skeleton is defined.
10. Event boundary is defined.
11. Evidence packet boundary is defined.
12. Audit boundary is defined.
13. Reconciliation case boundary is defined.
14. DLQ boundary is defined.
15. Command vs Event boundary is defined.
16. Query vs Projection boundary is defined.
17. Projection vs Source Truth boundary is defined.
18. AI advisory separation boundary is defined.
19. Sensor observation separation boundary is defined.
20. Provider signal separation boundary is defined.
21. CMS/i18n separation boundary is defined.
22. Analytics separation boundary is defined.
23. pgvector separation boundary is defined.
24. Store Runtime separation boundary is defined.
25. Financial Trust separation boundary is defined.
26. Data Governance separation boundary is defined.
27. Security separation boundary is defined.
28. Projection audience boundary is defined.
29. Mutation from projection boundary is defined.
30. Command authorization gate boundary is defined.
31. Query authorization gate boundary is defined.
32. Projection build gate boundary is defined.
33. Event reaction boundary is defined.
34. Auto-command boundary is defined.
35. Evidence-first high-impact action boundary is defined.
36. Human review boundary is defined.
37. Anti-patterns are listed.
38. Coding remains unauthorized.
39. Runtime remains deferred.

---

## 42. Relationship To Previous Documents

This document follows:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`

It prepares:

- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10690 Cross-Room Plumbing Closure Policy`

It references all prior room-boundary documents where command/query/projection separation is required.

This document is architecture boundary planning only.

It does not authorize coding.

---

## 43. Final Rule

Every system interaction must be separated before it is allowed to act.

Command requests mutation, but command is not authority by itself.

Query reads, but query must not mutate.

Projection shows safe visibility, but projection is not source truth.

Event records something that happened or was observed, but event is not command.

Evidence supports review, but evidence is not approval.

Audit records trace, but audit is not execution.

AI, pgvector, analytics, CMS, i18n, provider callback, and sensor signals may support context, evidence, or projection, but they must not silently become mutation authority.

Any mutation must be expressed as an explicit command, pass authority and policy gates, produce events and audit, and preserve evidence.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
