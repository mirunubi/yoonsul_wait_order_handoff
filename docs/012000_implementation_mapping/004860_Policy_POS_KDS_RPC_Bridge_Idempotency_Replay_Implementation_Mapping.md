# 004860_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping

\#\# 1\. Purpose

This document defines the implementation mapping policy for POS/KDS RPC communication, bridge authority, idempotency, retry, replay, stale event handling, mismatch detection, audit linkage, and tenant/store context validation in the Yoonsul Wait/Order Handoff project.

The project depends on safe handoff between customer ordering, POS transaction authority, KDS kitchen execution, bridge synchronization, local agent recovery, and degraded operation.

POS/KDS communication must not be treated as a simple internal message pipe.

It is a security, authority, chronology, and evidence boundary.

This document does not implement RPC functions, bridge services, database tables, queue workers, or retry code.

It defines the constraints that future implementation must obey.

\---

\#\# 2\. Scope

This mapping applies to:

\- POS accepted order handoff
\- POS order status event
\- POS payment status event visibility
\- KDS ticket creation
\- KDS kitchen status update
\- POS/KDS bridge validation
\- RPC request context
\- RPC authority boundary
\- idempotency key handling
\- retry queue behavior
\- replay behavior
\- stale event detection
\- duplicate event handling
\- mismatch detection
\- degraded POS/KDS operation
\- local agent relay
\- audit mapping
\- evidence packet linkage
\- testing requirements
\- implementation blockers

This document does not define final schema or code.

\---

\#\# 3\. Core Principle

POS/KDS RPC must preserve authority boundaries.

The project must follow this rule:

\> POS owns transaction truth. KDS owns kitchen execution truth. Bridge validates and relays. Agent recommends. Replay verifies or reconstructs but must not silently mutate truth.

RPC communication must never blur these authorities.

\---

\#\# 4\. Related Policy Documents

This mapping depends on:

\- 04471_Policy_Financial_Grade_Security_Baseline_And_Secret_Coding
\- 04481_Policy_POS_KDS_RPC_Security_And_Trust_Boundary
\- 04491_Policy_Degraded_Security_Recovery_And_Evidence_Boundary
\- 04531_Policy_Security_Audit_Event_Immutability_And_Tamper_Evidence
\- 04541_Policy_Device_Trust_Session_Revocation_And_Store_Runtime_Access
\- 04551_Policy_Payment_Boundary_Refund_Correction_And_Settlement_Security
\- 04561_Policy_Tenant_Store_Boundary_Isolation_And_Cross_Context_Access
\- 04581_Policy_Log_Masking_Error_Disclosure_And_Diagnostic_Data
\- 04591_Policy_Webhook_Signature_Idempotency_Replay_And_External_Integration_Security
\- 04621_Policy_Security_Incident_Response_Severity_Classification_And_Recovery_Governance
\- 04661_Policy_Security_Testing_Abuse_Case_Threat_Modeling_And_Verification
\- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
\- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
\- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy

Future POS/KDS implementation must inherit these constraints.

\---

\#\# 5\. Affected Runtime

This mapping affects:

\- Customer Web Runtime
\- Customer Mobile Runtime
\- POS Runtime
\- KDS Runtime
\- POS/KDS Bridge Runtime
\- Store Tablet Runtime
\- Staff Runtime
\- Local Agent Runtime
\- Payment Runtime
\- Audit Runtime
\- Support Runtime
\- Incident Runtime

The main authority boundary is between POS Runtime, KDS Runtime, Bridge Runtime, and Local Agent Runtime.

\---

\#\# 6\. POS Authority Mapping

POS authority includes:

\- accepted order confirmation
\- transaction total
\- payment request linkage
\- payment status received from payment boundary
\- cancellation initiation where allowed
\- refund initiation request where allowed
\- order acceptance timestamp
\- POS order reference
\- POS receipt reference
\- final transaction reference
\- transaction correction reference

POS authority does not include kitchen execution truth.

POS must not silently overwrite KDS kitchen state without reconciliation.

\---

\#\# 7\. KDS Authority Mapping

KDS authority includes:

\- kitchen ticket receipt
\- kitchen ticket visibility
\- cooking start
\- hold
\- delay
\- remake
\- kitchen note
\- ready
\- served
\- manual kitchen recovery note
\- kitchen execution status correction request

KDS authority does not include:

\- payment confirmation
\- refund approval
\- settlement truth
\- customer identity truth
\- POS transaction mutation
\- tenant/store authority override

KDS must not mutate payment state.

\---

\#\# 8\. Bridge Authority Mapping

Bridge authority includes:

\- receive POS event
\- receive KDS event
\- validate context
\- validate event shape
\- validate authority
\- translate event format
\- queue delivery
\- retry delivery
\- detect duplicate
\- detect stale event
\- detect mismatch
\- quarantine invalid event
\- create bridge audit event
\- create mismatch evidence
\- request recovery review

Bridge authority does not include:

\- payment truth mutation
\- refund approval
\- settlement mutation
\- silent POS state overwrite
\- silent KDS state overwrite
\- cross-store merge
\- audit deletion
\- final recovery approval

Bridge is a controlled relay and validator.

\---

\#\# 9\. Agent Authority Mapping

Agent may:

\- detect anomaly
\- recommend recovery
\- summarize mismatch
\- classify delay risk
\- predict ticket delay
\- suggest staff action
\- identify replay candidate
\- identify evidence gap

Agent must not:

\- execute payment mutation
\- confirm refund
\- change POS truth
\- change KDS truth without human/system authority
\- approve recovery
\- delete audit
\- bypass tenant/store context
\- silently merge degraded data

Agent output is advisory.

\---

\#\# 10\. Required RPC Context

Every high-risk POS/KDS RPC or bridge event should include:

\- tenant\_id
\- store\_id
\- source\_runtime\_type
\- source\_runtime\_id
\- target\_runtime\_type where applicable
\- target\_runtime\_id where applicable
\- device\_id or service\_identity
\- actor\_id where human action exists
\- actor\_role where human action exists
\- request\_id
\- correlation\_id
\- idempotency\_key
\- source\_event\_id
\- source\_event\_type
\- source\_event\_timestamp
\- received\_at
\- action\_type
\- resource\_type
\- resource\_id
\- current\_state where applicable
\- requested\_state where applicable
\- degraded\_mode flag where applicable
\- fallback\_originated flag where applicable
\- replay flag where applicable

Context must be validated server-side.

\---

\#\# 11\. Tenant Store Context Validation

Every POS/KDS event must validate tenant and store context.

Validation must confirm:

\- POS terminal belongs to tenant/store
\- KDS device belongs to tenant/store
\- bridge identity is authorized for tenant/store
\- order belongs to tenant/store
\- ticket belongs to tenant/store
\- table session belongs to tenant/store where applicable
\- payment reference belongs to tenant/store where applicable
\- local agent belongs to tenant/store where applicable
\- replay event lineage belongs to tenant/store

Payload tenant/store values must not be trusted blindly.

\---

\#\# 12\. RPC Authentication Mapping

POS/KDS RPC authentication may involve:

\- service identity
\- signed request
\- trusted internal service token
\- device-bound credential
\- bridge credential
\- local agent credential
\- environment-bound credential
\- short-lived credential where possible

RPC must not rely only on obscurity or internal network assumption.

Credentials must not be exposed to frontend customer runtime.

\---

\#\# 13\. RPC Authorization Mapping

RPC authorization must verify:

\- source runtime is allowed to perform action
\- source device or service is trusted
\- actor has required role where human action exists
\- tenant/store context matches
\- requested transition is allowed
\- target runtime is allowed to receive event
\- degraded mode limits are respected
\- replay flag is valid where applicable
\- payment-related action is not performed by KDS or bridge without payment authority

Authorization must be action-specific.

\---

\#\# 14\. POS Accepted Order To KDS Ticket Mapping

When POS accepts an order and a KDS ticket is created, mapping must define:

\- POS accepted order event source
\- order reference
\- ticket creation idempotency key
\- tenant\_id
\- store\_id
\- menu item snapshot
\- quantity
\- kitchen routing
\- ticket priority
\- customer-facing masking
\- kitchen note filtering
\- audit event
\- duplicate handling
\- failure handling

KDS ticket creation must be idempotent.

Duplicate POS accepted order events must not create duplicate kitchen tickets.

\---

\#\# 15\. KDS Ticket Status Update Mapping

KDS ticket status update must define:

\- ticket id
\- tenant\_id
\- store\_id
\- actor or device
\- previous status
\- requested status
\- allowed transition
\- reason where needed
\- kitchen note where needed
\- idempotency key
\- audit event
\- POS notification where applicable
\- customer visibility where applicable
\- delay or remake evidence where applicable

KDS status update must not imply payment state change.

\---

\#\# 16\. POS Payment Visibility Mapping

POS/KDS bridge may observe payment-related status only where needed.

Allowed visibility:

\- payment pending
\- payment confirmed
\- payment failed
\- payment cancelled
\- payment uncertainty
\- payment review required

Not allowed:

\- card data
\- payment token
\- payment provider secret
\- raw provider payload
\- refund authority
\- settlement authority
\- payment mutation by KDS

KDS may use payment visibility only to support operational flow.

\---

\#\# 17\. Idempotency Definition

Idempotency means repeated delivery of the same logical action does not create duplicate or conflicting outcomes.

Idempotency is required for:

\- POS accepted order handoff
\- KDS ticket creation
\- KDS status update
\- POS event delivery
\- bridge retry
\- payment status visibility update
\- degraded local relay
\- replay request
\- evidence packet creation
\- manual recovery submission

Idempotency must be mapped before implementation.

\---

\#\# 18\. Idempotency Key Source

Idempotency key may be derived from:

\- source system event id
\- tenant\_id
\- store\_id
\- order id
\- ticket id
\- action type
\- requested state
\- source timestamp
\- retry attempt group
\- provider event id where applicable

Key design must avoid collision across tenants and stores.

A key valid in one store must not affect another store.

\---

\#\# 19\. Duplicate Event Handling

Duplicate event handling should:

\- detect duplicate idempotency key
\- return prior result where safe
\- avoid duplicate ticket creation
\- avoid duplicate status transition
\- avoid duplicate audit where inappropriate
\- create duplicate-detected audit where high-risk
\- preserve event receipt trace
\- avoid hiding suspicious repeated events

Duplicate does not always mean error.

But duplicate must not create duplicate business truth.

\---

\#\# 20\. Retry Mapping

Retry mapping should define:

\- retry trigger
\- retry queue
\- retry count
\- retry delay
\- retry expiration
\- retry idempotency key
\- retry audit
\- retry failure state
\- retry escalation
\- retry quarantine condition

Retry must not create new logical action.

Retry must reattempt the same logical action under same idempotency scope.

\---

\#\# 21\. Replay Definition

Replay means processing or re-evaluating a historical event or event sequence for verification, reconstruction, reconciliation, or recovery.

Replay may be needed for:

\- failed bridge delivery
\- degraded local capture
\- POS/KDS mismatch
\- webhook ordering issue
\- local agent sync conflict
\- audit reconstruction
\- evidence review
\- incident investigation

Replay must be explicit.

Replay must not be ordinary retry hidden under another name.

\---

\#\# 22\. Replay Mapping

Replay mapping should define:

\- replay request actor or service
\- replay source
\- replay event range
\- replay reason
\- replay target
\- replay mode
\- replay idempotency scope
\- replay audit
\- replay output
\- conflict detection
\- no-overwrite confirmation
\- review requirement where needed

Replay output may be:

\- verified no change
\- derived evidence
\- reconciliation candidate
\- recovery case
\- rejected replay
\- conflict requiring review

\---

\#\# 23\. Replay No Silent Mutation Rule

Replay must not silently mutate current truth.

Replay may:

\- reconstruct event sequence
\- compare expected state
\- create reconciliation candidate
\- create evidence packet
\- create recovery case
\- mark conflict
\- recommend correction

Replay must not:

\- overwrite POS truth
\- overwrite KDS truth
\- confirm payment
\- approve refund
\- delete audit
\- merge local data silently
\- change settlement result without approval

Replay protects truth.

It does not bypass authority.

\---

\#\# 24\. Stale Event Detection

A stale event is an event that arrives too late or out of expected order.

Stale event detection should consider:

\- source timestamp
\- received timestamp
\- last accepted event
\- current state
\- state transition rules
\- event sequence number where available
\- degraded mode
\- clock drift
\- replay flag
\- duplicate idempotency key

Stale events should be rejected, quarantined, or converted into review candidates depending on risk.

\---

\#\# 25\. Chronology Uncertainty Mapping

When event order is uncertain, mapping should allow:

\- chronology\_uncertain flag
\- cache\_state\_uncertain flag
\- replay\_required state
\- reconciliation\_required state
\- manual\_review\_required state
\- evidence packet creation
\- audit event

Chronology uncertainty must not be hidden.

\---

\#\# 26\. State Transition Validation

State transition validation must define allowed transitions.

Examples:

\- POS accepted order may create KDS ticket
\- KDS ticket may move from received to cooking
\- KDS ticket may move from cooking to ready
\- KDS ticket may move from ready to served
\- KDS ticket may move to hold or delay with reason
\- KDS ticket may be remade with reason
\- cancelled POS order may require KDS stop or review
\- payment failed may require operational visibility but not KDS payment mutation

Invalid transitions should be denied or reviewed.

\---

\#\# 27\. POS/KDS Mismatch Mapping

Mismatch may include:

\- POS order exists but KDS ticket missing
\- KDS ticket exists but POS order missing
\- POS order cancelled but KDS still cooking
\- KDS ticket ready but POS state unresolved
\- payment confirmed but ticket not created
\- ticket created for wrong store
\- duplicate ticket created
\- stale KDS status update
\- local agent record conflicts with central record

Mismatch must create evidence, not silent overwrite.

\---

\#\# 28\. Mismatch Evidence Packet

Mismatch evidence packet should include:

\- mismatch\_id
\- tenant\_id
\- store\_id
\- order\_id
\- ticket\_id where applicable
\- POS event references
\- KDS event references
\- bridge event references
\- local agent references where applicable
\- audit event references
\- detected\_at
\- detected\_by
\- mismatch\_type
\- severity
\- current POS state
\- current KDS state
\- chronology summary
\- recommended action
\- review status

Evidence packet must not expose secrets or raw unnecessary identity.

\---

\#\# 29\. Quarantine Mapping

Invalid or suspicious events may be quarantined.

Quarantine triggers include:

\- signature invalid
\- source not trusted
\- tenant/store mismatch
\- invalid state transition
\- stale event with mutation risk
\- duplicate with conflicting payload
\- replay without authorization
\- payment mutation attempted by KDS
\- cross-store bridge event
\- malformed payload
\- suspicious retry storm

Quarantine must be auditable.

\---

\#\# 30\. Degraded POS/KDS Mapping

During degraded mode, POS/KDS mapping must define:

\- what can be captured locally
\- what can be shown to kitchen
\- what is provisional
\- what is fallback-originated
\- what requires central verification
\- what cannot be finalized locally
\- what must be replayed
\- what must be reconciled
\- what requires manual review

Degraded mode must not bypass tenant/store, audit, or payment boundaries.

\---

\#\# 31\. Local Agent Relay Mapping

Local agent may relay or cache POS/KDS events under strict scope.

Mapping must define:

\- local agent identity
\- tenant/store binding
\- Primary role
\- Secondary role
\- promoted Primary role
\- recovery pending state
\- cache uncertainty
\- event receipt
\- event delivery
\- sync attempt
\- conflict handling
\- central verification

Local agent must not become hidden transaction authority.

\---

\#\# 32\. Manual Recovery Mapping

Manual recovery may be required when POS/KDS synchronization fails.

Manual recovery mapping should define:

\- who may create recovery note
\- what evidence is required
\- what state is provisional
\- what requires approval
\- what is visible to kitchen
\- what is visible to customer
\- what is visible to support
\- what audit is created
\- what replay or reconciliation follows

Manual recovery is evidence capture, not silent truth rewrite.

\---

\#\# 33\. Audit Mapping

POS/KDS RPC audit events should include:

\- event received
\- event validated
\- event rejected
\- event quarantined
\- idempotency duplicate detected
\- retry scheduled
\- retry failed
\- replay requested
\- replay completed
\- stale event detected
\- mismatch detected
\- KDS ticket created
\- KDS status changed
\- POS cancellation relayed
\- bridge authority violation denied
\- payment mutation attempt denied

Audit must link tenant/store context.

\---

\#\# 34\. Masking Mapping

POS/KDS payload and logs should avoid unnecessary sensitive data.

Do not include:

\- raw CI / DI
\- full customer identity
\- payment tokens
\- card data
\- service secrets
\- raw provider payload
\- support-only notes
\- unnecessary phone/email
\- authentication headers

Kitchen view should receive only operationally necessary customer/order data.

\---

\#\# 35\. Error Handling Mapping

POS/KDS errors should be safe by audience.

Customer-facing error may say:

\- "Order status is being updated."
\- "Kitchen status is temporarily delayed."
\- "Please ask staff for assistance."

Staff-facing error may say:

\- "Ticket sync requires review."
\- "POS/KDS mismatch detected."
\- "Manual recovery note required."

Internal diagnostic may include masked event references.

Errors must not reveal secrets, raw identity, or cross-tenant data.

\---

\#\# 36\. Support Visibility Mapping

Support may view POS/KDS mismatch only under case scope.

Support visibility should include:

\- masked order reference
\- ticket state
\- event timeline summary
\- mismatch type
\- recovery status
\- customer-facing status
\- evidence packet reference

Support must not receive payment mutation authority or raw secrets.

\---

\#\# 37\. Customer Visibility Mapping

Customer visibility should be limited to appropriate order progress.

Customer may see:

\- order received
\- preparing
\- delayed
\- ready
\- served or completed where applicable
\- issue under review where appropriate

Customer should not see:

\- internal POS/KDS diagnostics
\- staff notes not intended for customer
\- bridge errors
\- raw device information
\- internal replay or quarantine details
\- other customer data

\---

\#\# 38\. Staff Visibility Mapping

Staff may see operationally necessary POS/KDS status.

Staff may see:

\- ticket state
\- delay flag
\- hold flag
\- remake flag
\- manual recovery required
\- mismatch requires manager review
\- kitchen note where role permits

Staff should not see:

\- payment secret
\- raw identity linkage
\- cross-store data
\- internal security diagnostics
\- unrestricted audit logs

\---

\#\# 39\. Testing Requirements

Future tests must include:

\- POS accepted order creates one KDS ticket
\- duplicate POS event does not create duplicate ticket
\- wrong tenant POS event is rejected
\- wrong store POS event is rejected
\- KDS cannot mutate payment state
\- bridge cannot approve refund
\- stale KDS event is rejected or quarantined
\- retry does not create duplicate mutation
\- replay does not silently overwrite current state
\- mismatch creates evidence packet
\- degraded local event is marked fallback-originated
\- Secondary local agent cannot overwrite Primary state
\- invalid bridge credential is rejected
\- malformed RPC payload is rejected safely
\- audit event is created for high-risk events
\- logs do not expose secrets or raw CI / DI

Testing must include abuse cases.

\---

\#\# 40\. Evidence Requirements

Evidence should prove:

\- POS/KDS authority boundary exists
\- RPC context validation exists
\- tenant/store validation exists
\- idempotency works
\- retry does not duplicate mutation
\- replay does not silently mutate truth
\- stale events are detected
\- mismatch evidence packet is created
\- KDS cannot mutate payment
\- bridge cannot exceed relay authority
\- degraded mode preserves markers
\- local agent role boundary exists
\- audit events exist
\- sensitive fields are masked

Evidence must be usable during incident review.

\---

\#\# 41\. Implementation Blockers

Implementation must be blocked if:

\- POS authority is unclear
\- KDS authority is unclear
\- bridge authority is unclear
\- agent authority is unclear
\- required RPC context is undefined
\- tenant/store validation is missing
\- idempotency key design is missing
\- retry behavior is undefined
\- replay behavior is undefined
\- stale event handling is undefined
\- mismatch evidence packet is undefined
\- degraded POS/KDS behavior is undefined
\- local agent relay boundary is undefined
\- audit mapping is missing
\- KDS can mutate payment state
\- bridge can silently overwrite state
\- replay can silently mutate truth
\- tests are missing

These blockers must be added to the implementation blocker register.

\---

\#\# 42\. Mapping Status

Recommended status for this mapping:

\- \`DRAFT\`
\- \`POLICY\_LINKED\`
\- \`RUNTIME\_DEFINED\`
\- \`AUTHORITY\_MAPPED\`
\- \`CONTEXT\_MAPPED\`
\- \`IDEMPOTENCY\_MAPPED\`
\- \`RETRY\_MAPPED\`
\- \`REPLAY\_MAPPED\`
\- \`STALE\_EVENT\_MAPPED\`
\- \`MISMATCH\_EVIDENCE\_MAPPED\`
\- \`DEGRADED\_MAPPED\`
\- \`AUDIT\_MAPPED\`
\- \`TEST\_MAPPED\`
\- \`BLOCKED\`
\- \`READY\_FOR\_REVIEW\`
\- \`READY\_FOR\_IMPLEMENTATION\`

This document starts as \`DRAFT\`.

It becomes implementation-ready only after detailed schema, RPC, queue, audit, and test catalogs are later mapped.

\---

\#\# 43\. Non-Goals

This document does not define:

\- final RPC function
\- final bridge service code
\- final queue implementation
\- final retry worker
\- final database schema
\- final KDS UI
\- final POS adapter
\- final local agent implementation
\- final payment integration
\- final audit table
\- final test automation code
\- final production deployment

Those belong to later controlled implementation phase.

\---

\#\# 44\. Readiness Check

This mapping is ready when the project can answer:

1\. What does POS own?
2\. What does KDS own?
3\. What does Bridge own?
4\. What can Agent do?
5\. What must Agent not do?
6\. What RPC context fields are required?
7\. How is tenant/store context validated?
8\. How is RPC authenticated?
9\. How is RPC authorized?
10\. How does POS accepted order create KDS ticket?
11\. How is KDS status updated?
12\. What payment visibility may KDS have?
13\. What is idempotency?
14\. How is idempotency key derived?
15\. How are duplicate events handled?
16\. How does retry work?
17\. What is replay?
18\. Why must replay not silently mutate truth?
19\. How are stale events detected?
20\. How is chronology uncertainty marked?
21\. What transitions are allowed?
22\. What is POS/KDS mismatch?
23\. What evidence packet is created?
24\. What events are quarantined?
25\. What changes during degraded mode?
26\. What can local agent relay?
27\. What is manual recovery?
28\. What audit events are required?
29\. What fields must be masked?
30\. What tests prove safe POS/KDS RPC?

If these questions cannot be answered, POS/KDS RPC bridge mapping is incomplete.

\---

\#\# 45\. Conclusion

POS/KDS RPC and bridge communication are central to the Yoonsul Wait/Order Handoff system.

The system must preserve the following rules:

\- POS owns transaction truth
\- KDS owns kitchen execution truth
\- Bridge validates, translates, queues, retries, detects, and reports
\- Agent recommends but does not execute authority
\- RPC context must include tenant/store and event identity
\- tenant/store validation is server-side
\- idempotency prevents duplicate mutation
\- retry reattempts the same logical action
\- replay verifies or reconstructs but does not silently mutate truth
\- stale events must be detected
\- chronology uncertainty must be visible
\- mismatch creates evidence
\- invalid events may be quarantined
\- degraded mode must preserve authority and evidence
\- local agent must stay tenant/store-scoped
\- manual recovery captures evidence
\- KDS must not mutate payment
\- Bridge must not approve refund or settlement
\- audit must capture high-risk actions
\- sensitive data must be masked
\- support and customer visibility must be scoped
\- implementation is blocked until idempotency, replay, and mismatch handling are testable

This mapping does not implement POS/KDS RPC.

It defines the constraints that future POS/KDS bridge implementation must obey.
