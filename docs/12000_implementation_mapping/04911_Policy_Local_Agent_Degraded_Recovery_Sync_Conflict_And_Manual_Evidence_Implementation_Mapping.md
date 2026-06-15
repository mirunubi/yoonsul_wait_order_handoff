# 04911_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_And_Manual_Evidence_Implementation_Mapping

## 1. Purpose

This document defines the implementation mapping policy for local agent operation, degraded recovery, offline or partial connectivity, sync conflict handling, fallback-originated records, manual evidence capture, replay, reconciliation, and central verification in the Yoonsul Wait/Order Handoff project.

The project must survive realistic store failures.

Network interruption, POS/KDS bridge delay, central service outage, device failure, local agent failover, and manual recovery may occur during live store operation.

Therefore, degraded operation must be mapped before implementation.

This document does not implement local agent runtime, sync engine, conflict resolver, offline cache, recovery workflow, evidence storage, or database schema.

It defines the constraints that future degraded recovery implementation must obey.

---

## 2. Scope

This mapping applies to:

- local agent runtime
- Primary local agent
- Secondary local agent
- Promoted Primary
- Recovery Pending state
- degraded mode entry
- degraded mode exit
- offline cache
- fallback-originated records
- cache uncertainty
- sync retry
- sync conflict
- replay
- reconciliation
- central verification
- manual recovery note
- manual kitchen evidence
- POS/KDS degraded relay
- payment uncertainty during degraded mode
- support visibility
- audit mapping
- evidence packet linkage
- testing requirements
- implementation blockers

This document does not define final local agent code or deployment architecture.

---

## 3. Core Principle

Degraded operation may preserve continuity, but it must not silently rewrite truth.

The project must follow this rule:

> Local continuity is provisional until centrally verified. Sync is not silent merge. Replay is not mutation. Evidence is not approval.

Local agent and manual recovery exist to keep the store operating while preserving evidence, uncertainty, and later verification.

---

## 4. Related Policy Documents

This mapping depends on:

- 04471_Policy_Financial_Grade_Security_Baseline_And_Secret_Coding
- 04481_Policy_POS_KDS_RPC_Security_And_Trust_Boundary
- 04491_Policy_Degraded_Security_Recovery_And_Evidence_Boundary
- 04531_Policy_Security_Audit_Event_Immutability_And_Tamper_Evidence
- 04541_Policy_Device_Trust_Session_Revocation_And_Store_Runtime_Access
- 04551_Policy_Payment_Boundary_Refund_Correction_And_Settlement_Security
- 04561_Policy_Tenant_Store_Boundary_Isolation_And_Cross_Context_Access
- 04581_Policy_Log_Masking_Error_Disclosure_And_Diagnostic_Data
- 04621_Policy_Security_Incident_Response_Severity_Classification_And_Recovery_Governance
- 04631_Policy_Compliance_Readiness_Evidence_Control_And_Financial_Grade_Security_Review
- 04661_Policy_Security_Testing_Abuse_Case_Threat_Modeling_And_Verification
- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping
- 04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping
- 04901_Policy_Device_Trust_Session_Revocation_Store_Runtime_And_Lost_Device_Implementation_Mapping

Future degraded recovery implementation must inherit these constraints.

---

## 5. Affected Runtime

This mapping affects:

- Store Tablet Runtime
- POS Runtime
- KDS Runtime
- POS/KDS Bridge Runtime
- Local Agent Runtime
- Staff Runtime
- Support Runtime
- Payment Runtime
- Audit Runtime
- Incident Runtime
- Owner Runtime
- HQ Admin Runtime
- Customer Runtime

Local Agent Runtime is the main degraded continuity layer.

It must not become hidden final authority.

---

## 6. Degraded Mode Definition

Degraded mode means the system cannot fully rely on normal central runtime, normal bridge path, normal network path, normal device trust path, or normal provider confirmation.

Degraded mode may occur when:

- central service is unreachable
- store network is unstable
- POS/KDS bridge is delayed
- local device is offline
- local agent cannot sync
- payment provider confirmation is delayed
- webhook processing is uncertain
- KDS delivery retry is failing
- POS event delivery is failing
- support visibility is delayed
- audit upload is delayed
- local cache is stale

Degraded mode must be explicit.

It must not be hidden as normal operation.

---

## 7. Degraded Mode State Mapping

Recommended degraded states:

- `NORMAL_OPERATION`
- `DEGRADED_OPERATION_ACTIVE`
- `CENTRAL_SYNC_UNAVAILABLE`
- `BRIDGE_DELIVERY_DELAYED`
- `LOCAL_AGENT_ACTIVE`
- `LOCAL_AGENT_PRIMARY_ACTIVE`
- `LOCAL_AGENT_SECONDARY_ACTIVE`
- `LOCAL_AGENT_PROMOTED_PRIMARY`
- `CACHE_STATE_UNCERTAIN`
- `FALLBACK_ORIGINATED`
- `MANUAL_RECOVERY_REQUIRED`
- `REPLAY_REQUIRED`
- `RECONCILIATION_REQUIRED`
- `RECOVERY_PENDING`
- `CENTRAL_VERIFICATION_REQUIRED`
- `RECOVERY_REJECTED`
- `RECOVERY_VERIFIED`
- `NORMAL_OPERATION_RESTORED`

State naming may change later.

The meaning must remain clear.

---

## 8. Local Agent Role Mapping

Local agent roles may include:

- `Primary`
- `Secondary`
- `Promoted Primary`
- `Recovery Pending`
- `Disabled`
- `Revoked`
- `Out Of Sync`
- `Verification Required`

Primary local agent is the preferred local coordination point.

Secondary local agent may assist but must not overwrite Primary-derived state.

Promoted Primary must be auditable and centrally reviewed.

---

## 9. Primary Local Agent Mapping

Primary local agent may:

- receive local operational events
- relay POS/KDS status where allowed
- cache limited store-scoped data
- mark fallback-originated records
- queue sync
- detect local conflicts
- create local evidence packet
- show degraded warning to staff
- support manual recovery capture
- upload recovery records when central sync returns

Primary local agent must not:

- finalize payment truth
- approve refund
- finalize settlement
- overwrite central verified state
- merge Secondary data silently
- bypass tenant/store context
- expose raw CI / DI
- delete audit or evidence

Primary is continuity helper, not central truth owner.

---

## 10. Secondary Local Agent Mapping

Secondary local agent may:

- receive Primary-issued local state where allowed
- provide backup visibility
- support local continuity if Primary is unavailable
- capture limited evidence
- report heartbeat
- request promotion when Primary fails

Secondary local agent must not:

- overwrite Primary-derived state
- claim final truth while Primary conflict exists
- merge divergent records silently
- finalize recovery
- approve reconciliation
- write across store boundary
- bypass central verification

Secondary is backup, not competing authority.

---

## 11. Promoted Primary Mapping

Secondary may become Promoted Primary only under controlled conditions.

Promotion should require:

- Primary unavailable
- promotion reason
- local evidence
- timestamp
- actor or system trigger
- tenant_id
- store_id
- device identity
- audit event
- recovery pending marker
- later central verification

Promotion must be visible.

Promotion must not erase prior Primary state.

---

## 12. Recovery Pending Mapping

Recovery Pending means local continuity occurred but central verification is not complete.

Recovery Pending may apply to:

- local agent promotion
- local POS/KDS relay
- manual recovery note
- fallback-originated order record
- offline KDS status
- sync conflict
- payment uncertainty
- stale event sequence
- manual evidence packet

Recovery Pending must not be treated as normal finalized truth.

---

## 13. Degraded Entry Mapping

Degraded entry should define:

- trigger
- detection source
- affected runtime
- tenant_id
- store_id
- affected device
- affected event flow
- start time
- initial severity
- staff-visible message
- support-visible message
- audit event
- evidence packet start
- allowed local actions
- prohibited local actions

Entering degraded mode must be auditable.

---

## 14. Degraded Exit Mapping

Degraded exit should define:

- central connectivity restored
- local queues uploaded
- replay completed where needed
- conflicts reviewed
- recovery cases resolved or still pending
- payment uncertainty reconciled
- manual evidence attached
- audit upload completed
- staff-visible status cleared
- support-visible status updated
- final exit audit event

Exit from degraded mode does not mean every recovery case is closed.

Some cases may remain reconciliation-required.

---

## 15. Fallback-Originated Record Mapping

Fallback-originated records are records created during degraded or manual fallback paths.

Fallback-originated records must include:

- fallback_originated flag
- tenant_id
- store_id
- local_agent_id where applicable
- device_id
- actor_id where applicable
- source runtime
- local timestamp
- received timestamp
- sync status
- central verification status
- evidence reference
- audit reference
- uncertainty marker where applicable

Fallback-originated records must remain identifiable after sync.

---

## 16. Cache State Uncertain Mapping

Cache state uncertain means local cache may not reflect central truth.

Cache uncertainty may occur when:

- sync is delayed
- local agent missed events
- Primary/Secondary divergence exists
- central state changed while offline
- event order is uncertain
- payment provider result is unknown
- POS/KDS event sequence is incomplete

Cache uncertainty must be visible to authorized staff/support.

It must not be hidden behind normal status.

---

## 17. Offline Cache Constraint

Offline cache must be minimized.

Offline cache may include:

- store-scoped menu snapshot
- current ticket snapshot
- limited waiting/order snapshot
- local recovery note
- device state
- retry queue metadata
- audit queue metadata
- evidence packet draft

Offline cache must not include:

- raw CI / DI
- payment secrets
- service role key
- webhook secret
- raw provider payload
- unrestricted customer history
- unrelated store data
- cross-tenant data

Offline cache must have scope, expiration, masking, and sync rules.

---

## 18. Sync Attempt Mapping

Sync attempt should define:

- sync_attempt_id
- tenant_id
- store_id
- local_agent_id
- source device
- target central service
- sync batch id
- event range
- started_at
- completed_at
- result
- failure reason
- retry count
- conflict count
- audit event
- evidence reference

Sync attempt is auditable.

Failed sync is not automatically operational failure, but it must be visible.

---

## 19. Sync Conflict Mapping

Sync conflict occurs when local and central states cannot be safely merged automatically.

Conflict may include:

- same order different state
- same ticket different state
- local event older than central final state
- Secondary event conflicts with Primary event
- payment state differs from provider-confirmed state
- manual note conflicts with POS record
- duplicate local order candidate
- stale KDS status
- missing POS accepted order for KDS ticket
- replay output differs from current central state

Conflict must create review path.

Conflict must not silently merge.

---

## 20. Sync Conflict Status Mapping

Recommended conflict statuses:

- `CONFLICT_DETECTED`
- `CONFLICT_QUARANTINED`
- `REVIEW_REQUIRED`
- `REPLAY_REQUIRED`
- `RECONCILIATION_REQUIRED`
- `EVIDENCE_REQUIRED`
- `APPROVAL_REQUIRED`
- `RESOLVED_BY_CENTRAL`
- `RESOLVED_BY_CORRECTION`
- `REJECTED_LOCAL_RECORD`
- `ESCALATED_TO_INCIDENT`
- `CLOSED`

Conflict resolution must be auditable.

---

## 21. Replay Mapping

Replay may be used to reconstruct local and central event sequence.

Replay must define:

- replay source
- event range
- local agent records
- central records
- POS records
- KDS records
- payment records where relevant
- audit records
- replay actor or service
- replay reason
- replay output
- conflict result
- no-overwrite confirmation

Replay may produce evidence or reconciliation candidate.

Replay must not silently mutate final truth.

---

## 22. Reconciliation Mapping

Reconciliation may resolve differences between local provisional state and central verified state.

Reconciliation must define:

- reconciliation case id
- affected tenant/store
- affected resource
- original central state
- local provisional state
- verified source
- evidence reviewed
- decision
- correction required
- approver where needed
- audit event
- closure status

Reconciliation is controlled decision.

It is not automatic merge.

---

## 23. Central Verification Mapping

Central verification determines whether local fallback-originated records are accepted, rejected, corrected, or escalated.

Central verification must check:

- tenant/store match
- device trust
- local agent role
- actor authority
- event chronology
- idempotency
- POS/KDS consistency
- payment boundary
- audit presence
- evidence completeness
- duplicate risk
- conflict risk

Central verification is final for recovery acceptance.

---

## 24. Manual Recovery Definition

Manual recovery means a human captures operational evidence or action because normal digital path is degraded or unavailable.

Manual recovery may include:

- manual kitchen note
- manual order note
- manual ticket status note
- manual customer delay note
- manual POS/KDS mismatch note
- manual payment uncertainty note
- manual device failure note
- manual local agent failure note
- manual support escalation note

Manual recovery captures evidence.

It must not silently create final truth.

---

## 25. Manual Recovery Required Context

Manual recovery record should include:

- tenant_id
- store_id
- actor_id
- actor_role
- device_id
- local_agent_id where applicable
- affected order_id where known
- affected ticket_id where known
- affected payment_id where known
- recovery_type
- recovery_reason
- captured_at
- local timestamp
- customer impact
- staff action taken
- evidence attachment reference
- audit event
- review status

Manual recovery must be tied to context.

---

## 26. Manual Kitchen Evidence Mapping

Manual kitchen evidence may include:

- ticket visible on KDS but not POS
- POS order visible but KDS ticket missing
- cooking started manually
- remake performed
- delay communicated
- ready status manually recorded
- served status manually recorded
- ingredient shortage affecting order
- staff note during outage

Manual kitchen evidence should support later reconciliation.

It should not create payment truth.

---

## 27. Payment During Degraded Mode

Payment handling during degraded mode must be conservative.

Rules:

- do not guess confirmed payment
- do not finalize refund locally
- do not settle locally
- mark provider uncertainty
- mark payment reconciliation required where needed
- avoid KDS payment mutation
- show staff-safe uncertainty
- create audit and evidence
- central verification required for final correction

Payment uncertainty must not be hidden from authorized operators.

---

## 28. POS/KDS During Degraded Mode

POS/KDS degraded mapping must define:

- local ticket visibility
- provisional kitchen note
- POS accepted order delay
- KDS ticket creation delay
- bridge retry queue
- local relay marker
- stale event marker
- mismatch evidence
- replay requirement
- manual recovery path

KDS continuity may continue where safe.

But transaction and payment truth must remain controlled.

---

## 29. Customer Visibility During Degraded Mode

Customer messages must be safe.

Customer may see:

- order received where verified
- preparing where safe
- delay notice
- status updating
- staff assistance needed
- payment confirmation pending where appropriate
- refund under review where appropriate

Customer must not see:

- internal local agent state
- bridge error details
- audit detail
- staff-only notes
- raw payment uncertainty reason
- system topology

Customer trust requires honest but safe communication.

---

## 30. Staff Visibility During Degraded Mode

Staff should see actionable degraded status.

Staff may see:

- degraded mode active
- local agent active
- sync delayed
- manual recovery required
- replay required
- reconciliation required
- ticket mismatch
- payment review required
- cache state uncertain
- fallback-originated marker

Staff visibility must distinguish provisional from verified.

---

## 31. Support Visibility During Degraded Mode

Support may see degraded recovery data under case or incident scope.

Support may see:

- degraded state
- affected store
- affected order/ticket
- local agent role
- cache uncertainty
- fallback-originated records
- sync attempts
- conflict summary
- evidence packet
- customer impact summary

Support must not silently resolve recovery without authority.

---

## 32. Owner Visibility During Degraded Mode

Owner may see store-level degraded summary.

Owner may see:

- degraded mode active
- affected time range
- order count affected
- payment uncertainty count
- recovery pending count
- customer impact summary
- settlement hold indicator where applicable
- support or HQ review status

Owner should not see raw internal diagnostics, secrets, or unrelated tenant data.

---

## 33. Audit Mapping

Degraded recovery audit events should include:

- degraded mode entered
- degraded mode exited
- local agent activated
- Primary active
- Secondary active
- Secondary promoted
- recovery pending started
- fallback-originated record created
- cache state uncertain marked
- sync attempt started
- sync attempt failed
- sync completed
- sync conflict detected
- replay requested
- replay completed
- reconciliation required
- central verification accepted
- central verification rejected
- manual recovery note created
- evidence packet created
- unresolved recovery escalated

Audit must preserve chronology and context.

---

## 34. Evidence Packet Mapping

Degraded recovery evidence packet should include:

- evidence_packet_id
- tenant_id
- store_id
- degraded incident id
- local_agent_id
- device_id
- affected runtime
- affected order/ticket/payment references
- local event references
- central event references
- audit event references
- manual notes
- sync attempts
- conflict summary
- replay output
- reconciliation decision
- central verification result
- closure status

Evidence packet supports later review.

It is not itself approval.

---

## 35. Incident Escalation Mapping

Degraded recovery may escalate to incident when:

- payment uncertainty affects many orders
- POS/KDS mismatch affects many tickets
- local agent conflict cannot be resolved
- Primary/Secondary divergence persists
- support misuse suspected
- device compromise suspected
- cross-store event detected
- data leakage suspected
- audit upload missing
- customer harm likely
- settlement impact exists

Escalation must create incident audit and evidence linkage.

---

## 36. Error Handling Mapping

Errors must be safe by audience.

Staff-facing examples:

- "Local recovery is active."
- "Sync is delayed."
- "Manual recovery evidence is required."
- "Payment verification is pending."
- "Central verification is required."

Customer-facing examples:

- "Order status is being updated."
- "Payment confirmation is being verified."
- "Please ask staff for assistance."

Internal diagnostics may include masked event references.

---

## 37. Log Masking Mapping

Degraded recovery logs must not expose:

- service role key
- local agent credential
- bridge credential
- payment secret
- webhook secret
- raw CI / DI
- raw provider payload
- authorization header
- full customer identity
- unrestricted support notes

Logs should use masked event and evidence references.

---

## 38. Testing Requirements

Future tests must include:

- degraded mode entry creates audit
- degraded mode exit creates audit
- fallback-originated records are marked
- cache uncertainty is visible
- Primary local agent can capture allowed local event
- Secondary cannot overwrite Primary state
- promotion to Primary is audited
- sync retry does not duplicate mutation
- sync conflict does not silently merge
- replay does not silently mutate truth
- central verification can accept or reject local record
- manual recovery note creates evidence
- payment uncertainty does not become confirmed payment
- KDS cannot mutate payment during degraded mode
- support cannot close recovery without authority
- revoked device cannot act as local agent
- logs do not expose secrets or raw CI / DI

Testing must include abuse cases and outage scenarios.

---

## 39. Evidence Requirements

Evidence must prove:

- degraded mode state exists
- local agent roles are enforced
- fallback-originated marker exists
- cache uncertainty marker exists
- sync attempts are tracked
- sync conflicts are reviewed
- replay is controlled
- reconciliation is append-only
- central verification exists
- manual recovery evidence is captured
- payment uncertainty is represented
- support visibility is scoped
- audit events are created
- logs are masked
- tests cover outage and conflict cases

Evidence must be usable for incident and compliance review.

---

## 40. Implementation Blockers

Implementation must be blocked if:

- degraded mode states are undefined
- local agent roles are undefined
- Primary/Secondary boundary is undefined
- promotion rule is undefined
- fallback-originated marker is missing
- cache uncertainty marker is missing
- sync attempt tracking is missing
- sync conflict handling is undefined
- replay can silently mutate truth
- reconciliation can overwrite history
- central verification is undefined
- manual recovery evidence is undefined
- payment uncertainty is not represented
- support can resolve recovery without authority
- audit mapping is missing
- tests are missing

These blockers must be added to the implementation blocker register.

---

## 41. Mapping Status

Recommended status for this mapping:

- `DRAFT`
- `POLICY_LINKED`
- `RUNTIME_DEFINED`
- `DEGRADED_STATE_MAPPED`
- `LOCAL_AGENT_ROLE_MAPPED`
- `FALLBACK_MARKER_MAPPED`
- `CACHE_UNCERTAINTY_MAPPED`
- `SYNC_MAPPED`
- `CONFLICT_MAPPED`
- `REPLAY_MAPPED`
- `RECONCILIATION_MAPPED`
- `CENTRAL_VERIFICATION_MAPPED`
- `MANUAL_EVIDENCE_MAPPED`
- `AUDIT_MAPPED`
- `TEST_MAPPED`
- `BLOCKED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`

This document starts as `DRAFT`.

It becomes implementation-ready only after local agent role design, degraded state machine, sync mapping, conflict mapping, evidence packet mapping, audit mapping, and test catalogs are completed.

---

## 42. Non-Goals

This document does not define:

- final local agent implementation
- final offline cache schema
- final sync engine
- final conflict resolver
- final replay engine
- final reconciliation UI
- final recovery approval service
- final evidence storage implementation
- final KDS degraded UI
- final POS degraded adapter
- final support recovery dashboard
- final automated test code
- final production deployment

Those belong to later controlled implementation phase.

---

## 43. Readiness Check

This mapping is ready when the project can answer:

1. What is degraded mode?
2. What degraded states exist?
3. What local agent roles exist?
4. What can Primary local agent do?
5. What must Primary local agent not do?
6. What can Secondary local agent do?
7. What must Secondary local agent not do?
8. When can Secondary be promoted?
9. What is Recovery Pending?
10. How is degraded mode entered?
11. How is degraded mode exited?
12. What is fallback-originated record?
13. What is cache state uncertain?
14. What may offline cache contain?
15. What must offline cache not contain?
16. How is sync attempt tracked?
17. What is sync conflict?
18. What conflict statuses exist?
19. How is replay controlled?
20. How is reconciliation controlled?
21. What is central verification?
22. What is manual recovery?
23. What context is required for manual recovery?
24. What is manual kitchen evidence?
25. How is payment handled during degraded mode?
26. How is POS/KDS handled during degraded mode?
27. What can customer see?
28. What can staff see?
29. What can support see?
30. What can owner see?
31. What audit events are required?
32. What evidence packet is created?
33. When does degraded recovery escalate to incident?
34. What logs must be masked?
35. What tests prove degraded recovery safety?
36. What evidence proves recovery controls?
37. What blocks implementation?

If these questions cannot be answered, local agent degraded recovery implementation mapping is incomplete.

---

## 44. Conclusion

Local Agent and degraded recovery are core survivability components of the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

- degraded mode must be explicit
- local continuity is provisional
- Primary and Secondary local agents have different authority
- Secondary must not overwrite Primary
- promotion must be audited
- fallback-originated records must remain marked
- cache uncertainty must be visible
- sync is not silent merge
- conflict requires review
- replay is not mutation
- reconciliation is append-only
- central verification is final for recovery acceptance
- manual recovery captures evidence, not final truth
- payment uncertainty must not become payment confirmation
- POS/KDS continuity must preserve authority boundaries
- customer messages must be safe
- staff must see actionable degraded status
- support visibility must be scoped
- audit and evidence must preserve chronology
- logs must not expose secrets or raw identity
- implementation is blocked until local agent roles, degraded states, sync conflict, replay, reconciliation, central verification, manual evidence, audit, and tests are mapped

This mapping does not implement local agent runtime.

It defines the constraints that future degraded recovery implementation must obey.