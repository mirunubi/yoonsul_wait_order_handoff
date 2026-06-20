# 004990_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_Test_Catalog.md

## 1. Purpose

This document defines the test catalog policy for local agent degraded operation, Primary and Secondary local agent roles, Promoted Primary behavior, Recovery Pending status, fallback-originated records, cache uncertainty, offline operation, sync attempts, sync conflicts, replay, reconciliation, central verification, manual recovery evidence, POS/KDS degraded behavior, payment uncertainty, audit, evidence, and deployment gate requirements in the Yoonsul Wait/Order Handoff project.

Local agent and degraded recovery are necessary for operational continuity.

However, degraded recovery is also high-risk because provisional local records can be mistaken for verified central truth, stale cache can overwrite newer data, Secondary agents can conflict with Primary, manual notes can be treated as final state, and payment uncertainty can be hidden.

Therefore, local agent and degraded recovery behavior must have explicit positive tests, negative tests, abuse-case tests, sync tests, replay tests, conflict tests, central verification tests, audit tests, evidence tests, and deployment gate tests before implementation is allowed.

This document does not implement local agent runtime, sync engine, offline cache, replay engine, conflict resolver, evidence packet schema, or automated test code.

It defines the test catalog that future local agent implementation must satisfy.

---

## 2. Scope

This test catalog applies to:

- degraded mode entry
- degraded mode exit
- local agent Primary role
- local agent Secondary role
- Promoted Primary role
- Recovery Pending state
- local cache behavior
- cache uncertainty marker
- fallback-originated marker
- offline operation
- local POS/KDS continuity
- local manual kitchen recovery note
- local staff action capture
- local sync attempt
- sync retry
- sync failure
- sync conflict
- stale local data
- replay behavior
- reconciliation candidate
- central verification
- payment uncertainty
- support degraded view
- owner degraded summary
- customer-safe degraded status
- audit
- evidence packet linkage
- deployment gate requirements
- implementation blockers

This document focuses on test catalog design, not local agent implementation.

---

## 3. Core Principle

Local continuity is provisional until centrally verified.

The project must follow this rule:

> Degraded mode may preserve operation, but it must not silently become final truth. Local records must be marked, sync must not silently merge, replay must not mutate truth, and central verification must decide final accepted state.

Tests must prove degraded continuity does not become hidden corruption.

---

## 4. Source Mapping Documents

This test catalog verifies constraints from:

- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping
- 04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping
- 04891_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session_Implementation_Mapping
- 04901_Policy_Device_Trust_Session_Revocation_Store_Runtime_And_Lost_Device_Implementation_Mapping
- 04911_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_And_Manual_Evidence_Implementation_Mapping
- 04951_Policy_Secure_Deployment_Environment_Separation_Release_Gate_And_Rollback_Implementation_Mapping
- 04971_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance
- 04981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog
- 04991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy
- 05001_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog
- 05011_Policy_Payment_Webhook_Refund_Settlement_Reconciliation_Test_Catalog
- 05031_Policy_Support_Access_Masking_Break_Glass_Scoped_Session_Test_Catalog
- 05041_Policy_Device_Trust_Session_Revocation_Lost_Device_Test_Catalog

---

## 5. Affected Runtime

This test catalog affects:

- Local Agent Runtime
- Store Tablet Runtime
- Staff Runtime
- POS Runtime
- KDS Runtime
- POS/KDS Bridge Runtime
- Payment Runtime
- Support Runtime
- Customer Runtime
- Owner Runtime
- HQ Admin Runtime
- Audit Runtime
- Incident Runtime
- Deployment Runtime

Local agent tests must cover both continuity and recovery.

---

## 6. Risk Categories

This catalog covers the following risk categories:

- degraded mode entered without marker
- degraded mode not exited correctly
- fallback-originated record missing marker
- cache uncertainty hidden
- Primary and Secondary conflict
- Secondary overwrites Primary
- Secondary self-promotes
- Promoted Primary lacks evidence
- revoked local agent syncs data
- lost device rejoins as trusted agent
- local cache accepted as verified central truth
- stale local data overwrites newer central data
- sync silently merges conflict
- replay silently mutates final truth
- reconciliation overwrites original history
- manual note treated as final truth
- degraded KDS confirms payment
- payment uncertainty hidden
- customer sees misleading final status
- support closes degraded recovery without verification
- audit missing
- evidence packet incomplete
- deployment weakens local agent controls

Critical failures in these categories block implementation.

---

## 7. Test Data Setup Requirement

Future tests should include at least:

- Tenant A
- Tenant B
- Store A1
- Store A2
- Local Agent A1 Primary
- Local Agent A1 Secondary
- Local Agent A1 Promoted Primary
- Local Agent A2 Primary
- Revoked Local Agent
- Lost Store Tablet
- Trusted Store Tablet
- POS Terminal A1
- KDS Device A1
- Payment A1 pending
- Payment A1 confirmed centrally
- Order A1 central state
- Order A1 local fallback state
- KDS Ticket A1 central state
- KDS Ticket A1 local state
- Manual Kitchen Recovery Note
- Fallback-Originated Record
- Cache Uncertain Record
- Sync Attempt Record
- Sync Conflict Record
- Replay Candidate
- Reconciliation Candidate
- Central Verification Candidate
- Support Degraded Case
- Customer Status Candidate
- Audit Event Candidate
- Evidence Packet Candidate

Test data must include normal degraded operation, conflicting local/central state, stale local data, replay, and manual recovery.

---

## 8. Test ID Naming Rule

Recommended test id format:

    TC-LOCALAGENT-[NUMBER]-[TYPE]

Examples:

    TC-LOCALAGENT-001-POSITIVE
    TC-LOCALAGENT-002-NEGATIVE
    TC-LOCALAGENT-003-DEGRADED
    TC-LOCALAGENT-004-SYNC
    TC-LOCALAGENT-005-CONFLICT
    TC-LOCALAGENT-006-REPLAY
    TC-LOCALAGENT-007-EVIDENCE
    TC-LOCALAGENT-008-AUDIT
    TC-LOCALAGENT-009-DEPLOY

Final test IDs may change later.

Traceability must remain stable.

---

## 9. Positive Tests

### TC-LOCALAGENT-001-POSITIVE: Degraded Mode Entry Is Recorded

Precondition:

- Store A1 central connectivity or required runtime path is unavailable.
- Degraded entry condition is met.

Action:

- Store enters degraded mode.

Expected result:

- Degraded mode state is recorded.
- Store, trigger, time, actor/device/service, and affected runtime are recorded.
- Audit event is created.
- Staff-visible degraded indicator is available.

Evidence:

- degraded state record
- audit event
- staff visibility sample

---

### TC-LOCALAGENT-002-POSITIVE: Primary Local Agent Captures Allowed Local Record

Precondition:

- Store A1 is in degraded mode.
- Local Agent Primary A1 is trusted.
- Staff action is allowed during degraded mode.

Action:

- Local record is captured.

Expected result:

- Local record is created.
- Record includes fallback_originated marker.
- Record includes cache uncertainty marker where applicable.
- Device/local agent identity is recorded.
- Audit event is created.

Evidence:

- local record
- fallback marker
- cache uncertainty marker
- audit event

---

### TC-LOCALAGENT-003-POSITIVE: Local KDS Continuity Preserves Kitchen Work

Precondition:

- Central KDS path is unavailable.
- Local Agent Primary A1 is active.
- KDS Device A1 is trusted.

Action:

- Kitchen ticket status is updated locally.

Expected result:

- Local kitchen state is captured.
- Record is provisional or recovery pending where applicable.
- Payment state is not confirmed locally.
- Audit event is created.

Evidence:

- local KDS record
- payment unchanged proof
- audit event

---

### TC-LOCALAGENT-004-POSITIVE: Sync Attempt Is Recorded After Recovery

Precondition:

- Degraded local records exist.
- Central connectivity returns.

Action:

- Local Agent attempts sync.

Expected result:

- Sync attempt record is created.
- Synced records retain fallback-originated marker.
- Central verification status is pending unless verified.
- Audit event is created.

Evidence:

- sync attempt record
- fallback marker preserved
- audit event

---

## 10. Negative Tests

### TC-LOCALAGENT-005-NEGATIVE: Degraded Mode Does Not Bypass Revoked Device

Precondition:

- Store is in degraded mode.
- Device or local agent is revoked.

Action:

- Revoked device attempts degraded operation.

Expected result:

- Access is denied.
- No local trusted record is accepted.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- denial response
- no accepted local record
- audit event

---

### TC-LOCALAGENT-006-NEGATIVE: Local Agent Cannot Sync Another Store Data

Precondition:

- Local Agent A1 belongs to Store A1.
- Store A2 exists.

Action:

- Local Agent A1 attempts sync for Store A2 record.

Expected result:

- Sync is denied or quarantined.
- Store A2 state is unchanged.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- sync denial
- no mutation proof
- audit event

---

### TC-LOCALAGENT-007-NEGATIVE: Local Agent Cannot Cross Tenant Boundary

Precondition:

- Local Agent A1 belongs to Tenant A.
- Tenant B exists.

Action:

- Local Agent A1 attempts to sync Tenant B record.

Expected result:

- Sync is denied or quarantined.
- Tenant B state is unchanged.
- Security audit is created.

Failure severity:

- CRITICAL

Evidence:

- sync denial
- no cross-tenant mutation proof
- audit event

---

### TC-LOCALAGENT-008-NEGATIVE: Local Agent Cannot Confirm Payment

Precondition:

- Store is degraded.
- Payment provider confirmation is unavailable.
- Local Agent is active.

Action:

- Local Agent attempts to mark payment confirmed.

Expected result:

- Payment confirmation is denied.
- Payment remains pending, uncertain, or reconciliation required.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- payment state unchanged
- denial audit

---

### TC-LOCALAGENT-009-NEGATIVE: Manual Note Cannot Become Final Transaction Truth

Precondition:

- Staff creates manual kitchen recovery note.

Action:

- Manual note is submitted.

Expected result:

- Evidence record is created.
- Note does not directly overwrite POS transaction truth, payment truth, or central verified state.
- Review is required where applicable.

Failure severity:

- HIGH

Evidence:

- manual note record
- no overwrite proof
- review status

---

## 11. Degraded Entry And Exit Tests

### TC-LOCALAGENT-010-DEGRADED: Degraded Entry Requires Trigger

Precondition:

- No degraded trigger exists.

Action:

- Actor or service attempts to force degraded mode.

Expected result:

- Degraded entry is denied or requires approval/reason according to policy.
- Audit event is created.

Failure severity:

- HIGH

Evidence:

- denial or approval-required record
- audit event

---

### TC-LOCALAGENT-011-DEGRADED: Degraded Entry Marks Affected Runtime

Precondition:

- Payment provider unavailable but KDS is available.

Action:

- Degraded or partial degraded state is entered.

Expected result:

- Affected runtime is recorded.
- Payment uncertainty is visible.
- KDS is not falsely marked unavailable if still available.

Evidence:

- degraded state record
- affected runtime fields

---

### TC-LOCALAGENT-012-DEGRADED: Degraded Exit Requires Recovery Check

Precondition:

- Store is in degraded mode.
- Connectivity returns.

Action:

- System attempts degraded exit.

Expected result:

- Recovery check runs.
- Unsynced or conflicted records remain Recovery Pending.
- Degraded exit does not silently finalize all records.

Failure severity:

- HIGH

Evidence:

- recovery check record
- pending record list

---

### TC-LOCALAGENT-013-DEGRADED: Degraded Exit Creates Audit

Precondition:

- Store exits degraded mode.

Action:

- Exit is recorded.

Expected result:

- Audit records exit time, recovered runtime, remaining pending conflicts, and verification status.

Failure severity:

- HIGH if missing for major outage

Evidence:

- degraded exit audit

---

## 12. Fallback-Originated And Cache Uncertainty Tests

### TC-LOCALAGENT-014-FALLBACK: Local Record Has Fallback-Originated Marker

Precondition:

- Store is degraded.
- Local record is created.

Action:

- Record is inspected.

Expected result:

- fallback_originated marker is present.
- Source local agent/device is present.

Failure severity:

- HIGH

Evidence:

- local record sample

---

### TC-LOCALAGENT-015-FALLBACK: Fallback Marker Is Preserved During Sync

Precondition:

- Fallback-originated local record exists.

Action:

- Record syncs to central.

Expected result:

- fallback_originated marker remains visible.
- Central does not rewrite record as ordinary online record.

Failure severity:

- HIGH

Evidence:

- central synced record

---

### TC-LOCALAGENT-016-CACHE: Cache Uncertainty Marker Is Present For Unverified Local Data

Precondition:

- Local record was created while central verification unavailable.

Action:

- Record is viewed after sync.

Expected result:

- cache_state_uncertain or equivalent marker is present until verified.
- Staff/support can identify uncertainty.

Failure severity:

- HIGH

Evidence:

- cache uncertainty marker

---

### TC-LOCALAGENT-017-CACHE: Cache Uncertainty Cannot Be Cleared Without Verification

Precondition:

- Record is cache uncertain.

Action:

- Unauthorized actor or local agent attempts to clear uncertainty.

Expected result:

- Action is denied.
- Central verification is required.

Failure severity:

- HIGH

Evidence:

- denial result
- uncertainty still present

---

## 13. Primary Secondary Role Tests

### TC-LOCALAGENT-018-ROLE: Primary Local Agent Is Trusted Source During Degraded Mode

Precondition:

- Primary Local Agent A1 is active and trusted.
- Secondary Local Agent exists.

Action:

- Primary and Secondary produce consistent local records.

Expected result:

- Primary records are accepted as provisional local source.
- Secondary records remain subordinate or duplicate-check input.
- Central verification still required.

Evidence:

- Primary record
- Secondary record handling
- verification status

---

### TC-LOCALAGENT-019-ROLE: Secondary Cannot Overwrite Primary

Precondition:

- Primary has local record.
- Secondary has conflicting record.

Action:

- Secondary attempts to overwrite Primary state.

Expected result:

- Overwrite is denied.
- Sync conflict is created.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- overwrite denial
- conflict record
- audit event

---

### TC-LOCALAGENT-020-ROLE: Secondary Cannot Self-Promote

Precondition:

- Secondary Local Agent exists.
- No promotion condition or approval exists.

Action:

- Secondary attempts to become Primary.

Expected result:

- Promotion is denied.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- promotion denial
- audit event

---

### TC-LOCALAGENT-021-ROLE: Promoted Primary Requires Evidence

Precondition:

- Primary is unavailable.
- Promotion condition is met.

Action:

- Secondary is promoted.

Expected result:

- Promoted Primary state is recorded.
- Evidence packet includes reason, trigger, previous Primary state, promotion time, and approval or policy condition.
- Audit event is created.

Evidence:

- promotion record
- evidence packet
- audit event

---

### TC-LOCALAGENT-022-ROLE: Recovery Pending Is Set After Promotion

Precondition:

- Promoted Primary operated during degraded mode.

Action:

- Central connectivity returns.

Expected result:

- Records from promoted period are marked Recovery Pending until verified.
- No silent merge occurs.

Failure severity:

- HIGH

Evidence:

- Recovery Pending records
- verification queue

---

## 14. Sync Tests

### TC-LOCALAGENT-023-SYNC: Successful Sync Preserves Lineage

Precondition:

- Local fallback records exist.
- Central connectivity returns.
- No conflict exists.

Action:

- Sync runs.

Expected result:

- Records sync to central with local lineage.
- Original local created time and sync time are preserved.
- Audit event is created.

Evidence:

- synced record
- lineage fields
- audit event

---

### TC-LOCALAGENT-024-SYNC: Sync Retry Does Not Duplicate Records

Precondition:

- Sync attempt partially failed.
- Retry is scheduled.

Action:

- Sync retry runs.

Expected result:

- Duplicate central records are not created.
- Idempotency or logical record reference prevents duplication.
- Retry trace exists.

Failure severity:

- HIGH

Evidence:

- record count comparison
- retry trace

---

### TC-LOCALAGENT-025-SYNC: Sync Failure Becomes Visible

Precondition:

- Sync attempt fails.

Action:

- Failure is recorded.

Expected result:

- Sync failure is visible to authorized staff/support.
- Retry or review path is created.
- Failure is not hidden.

Failure severity:

- HIGH

Evidence:

- sync failure record
- support/staff visibility sample

---

### TC-LOCALAGENT-026-SYNC: Sync Retry Exhaustion Escalates

Precondition:

- Sync retries fail repeatedly.

Action:

- Retry threshold is exceeded.

Expected result:

- Incident or recovery review is created.
- Audit event is created.
- Records remain pending, not silently accepted.

Failure severity:

- HIGH

Evidence:

- retry exhaustion record
- incident/review link

---

## 15. Sync Conflict Tests

### TC-LOCALAGENT-027-CONFLICT: Central Newer State Blocks Stale Local Overwrite

Precondition:

- Central verified state is newer.
- Local stale record exists.

Action:

- Sync attempts to apply stale local record.

Expected result:

- Local record does not overwrite central state.
- Conflict is created.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- central state unchanged
- conflict record
- audit event

---

### TC-LOCALAGENT-028-CONFLICT: Local And Central Divergence Creates Review Candidate

Precondition:

- Local and central states differ materially.

Action:

- Sync runs.

Expected result:

- Divergence is detected.
- Review candidate is created.
- No silent merge occurs.

Failure severity:

- HIGH

Evidence:

- review candidate
- conflict details

---

### TC-LOCALAGENT-029-CONFLICT: Conflicting Payment State Is Not Resolved Locally

Precondition:

- Local record suggests paid.
- Provider/central payment is pending or failed.

Action:

- Sync conflict is evaluated.

Expected result:

- Payment remains provider/central-controlled.
- Reconciliation required is created.
- Local payment claim is evidence only.

Failure severity:

- CRITICAL

Evidence:

- payment state unchanged
- reconciliation record

---

### TC-LOCALAGENT-030-CONFLICT: Conflicting KDS State Creates Kitchen Review Not Silent Delete

Precondition:

- Local KDS ticket and central KDS ticket conflict.

Action:

- Sync runs.

Expected result:

- Kitchen review or reconciliation candidate is created.
- No ticket is silently deleted or overwritten.

Failure severity:

- HIGH

Evidence:

- KDS conflict record
- review status

---

## 16. Replay Tests

### TC-LOCALAGENT-031-REPLAY: Local Replay Does Not Mutate Final Truth

Precondition:

- Local degraded event sequence exists.
- Central state exists.

Action:

- Replay runs.

Expected result:

- Replay reconstructs timeline.
- Replay output creates evidence or reconciliation candidate.
- Final truth is not silently overwritten.

Failure severity:

- CRITICAL

Evidence:

- replay output
- no-overwrite proof
- audit event

---

### TC-LOCALAGENT-032-REPLAY: Replay Requires Authorized Actor Or Service

Precondition:

- Replay candidate exists.

Action:

- Unauthorized actor requests replay.

Expected result:

- Replay request is denied.
- Audit event is created where required.

Failure severity:

- HIGH

Evidence:

- denial response
- audit event

---

### TC-LOCALAGENT-033-REPLAY: Replay Preserves Fallback And Cache Markers

Precondition:

- Fallback-originated cache uncertain records exist.

Action:

- Replay runs.

Expected result:

- Replay output preserves fallback-originated and uncertainty markers.
- Replay does not normalize degraded records as ordinary records.

Failure severity:

- HIGH

Evidence:

- replay output
- marker verification

---

### TC-LOCALAGENT-034-REPLAY: Replay Chronology Shows Local And Central Time Difference

Precondition:

- Local timestamps and central receipt timestamps differ.

Action:

- Replay timeline is generated.

Expected result:

- Timeline shows local occurred time, central received time, and uncertainty where applicable.

Evidence:

- replay timeline

---

## 17. Reconciliation And Central Verification Tests

### TC-LOCALAGENT-035-VERIFY: Central Verification Accepts Valid Local Record

Precondition:

- Local fallback record has no conflict.
- Required evidence is complete.

Action:

- Central verification runs.

Expected result:

- Record becomes centrally verified or accepted.
- Verification decision is audited.
- Original local lineage remains.

Evidence:

- verification decision
- audit event
- lineage record

---

### TC-LOCALAGENT-036-VERIFY: Central Verification Rejects Invalid Local Record

Precondition:

- Local record is invalid, stale, or inconsistent.

Action:

- Central verification runs.

Expected result:

- Record is rejected or remains review-required.
- Central verified state is unchanged.
- Audit event is created.

Failure severity:

- HIGH if invalid record accepted

Evidence:

- rejection record
- audit event

---

### TC-LOCALAGENT-037-VERIFY: Verification Decision Requires Evidence

Precondition:

- Local record lacks required evidence.

Action:

- Actor attempts to verify record.

Expected result:

- Verification is denied or marked incomplete.
- Missing evidence is listed.

Failure severity:

- HIGH

Evidence:

- incomplete verification result

---

### TC-LOCALAGENT-038-VERIFY: Reconciliation Correction Is Append-Only

Precondition:

- Central verification requires correction.

Action:

- Correction is applied.

Expected result:

- Original local and central records remain traceable.
- Correction record is appended.
- Audit lineage exists.

Failure severity:

- CRITICAL if history overwritten

Evidence:

- correction lineage
- audit event

---

## 18. Manual Recovery Evidence Tests

### TC-LOCALAGENT-039-MANUAL: Manual Kitchen Note Creates Evidence Packet Candidate

Precondition:

- Staff records manual recovery note during degraded mode.

Action:

- Manual note is submitted.

Expected result:

- Manual evidence record is created.
- It links actor, device, store, time, reason, and affected ticket/order.
- It does not mutate final state.

Evidence:

- manual evidence record
- no final state mutation proof

---

### TC-LOCALAGENT-040-MANUAL: Manual Evidence Requires Actor And Device

Precondition:

- Manual evidence is submitted without actor or device context.

Action:

- Submission is processed.

Expected result:

- Submission is rejected or marked incomplete.
- Evidence cannot be verified without context.

Failure severity:

- HIGH

Evidence:

- rejection or incomplete status

---

### TC-LOCALAGENT-041-MANUAL: Manual Evidence Cannot Approve Refund

Precondition:

- Manual note says customer should be refunded.

Action:

- Note is processed.

Expected result:

- Refund is not approved.
- Refund review may be created.
- Payment/refund authority remains separate.

Failure severity:

- CRITICAL if refund approved

Evidence:

- refund state unchanged
- review request where applicable

---

### TC-LOCALAGENT-042-MANUAL: Manual Evidence Cannot Close Incident Alone

Precondition:

- Degraded recovery incident exists.
- Manual note claims issue resolved.

Action:

- Incident closure is attempted based on note alone.

Expected result:

- Closure is denied or review-required.
- Central verification and evidence completeness remain required.

Failure severity:

- HIGH

Evidence:

- closure denial
- review status

---

## 19. Payment Uncertainty Tests

### TC-LOCALAGENT-043-PAYMENT: Local Paid Claim Does Not Confirm Payment

Precondition:

- Local degraded record claims customer paid.
- Provider confirmation is unavailable.

Action:

- Sync or recovery runs.

Expected result:

- Payment remains pending, uncertain, or reconciliation required.
- Local claim is evidence only.
- Audit event is created.

Failure severity:

- CRITICAL

Evidence:

- payment state unchanged
- reconciliation record

---

### TC-LOCALAGENT-044-PAYMENT: Payment Uncertainty Is Visible To Staff

Precondition:

- Payment is uncertain during degraded recovery.

Action:

- Staff views order or recovery screen.

Expected result:

- Staff sees verification pending or payment uncertain indicator.
- Staff cannot treat payment as confirmed without provider proof.

Evidence:

- staff view sample
- payment state proof

---

### TC-LOCALAGENT-045-PAYMENT: Payment Uncertainty Is Visible To Support

Precondition:

- Support case includes degraded payment uncertainty.

Action:

- Support views case.

Expected result:

- Support sees masked payment uncertainty summary.
- Raw provider payload and payment secrets remain hidden.

Evidence:

- support view sample
- masking verification

---

## 20. Customer And Owner Visibility Tests

### TC-LOCALAGENT-046-CUSTOMER: Customer Degraded Status Is Safe

Precondition:

- Order is affected by degraded mode.

Action:

- Customer views order status.

Expected result:

- Customer sees safe status such as status updating, preparing, or verification pending where appropriate.
- Customer does not see internal local agent errors or secrets.
- Customer is not falsely told payment/order is final if uncertain.

Failure severity:

- HIGH if misleading status causes financial/operational harm

Evidence:

- customer status sample

---

### TC-LOCALAGENT-047-OWNER: Owner Sees Degraded Impact Summary

Precondition:

- Store had degraded operation.

Action:

- Owner views operational summary.

Expected result:

- Owner sees affected period, unresolved records, recovery pending count, and safe impact class.
- Raw secrets, raw identity, and internal credentials are hidden.

Evidence:

- owner summary sample

---

### TC-LOCALAGENT-048-SUPPORT: Support Can View Case-Scoped Recovery Summary

Precondition:

- Support case is assigned.
- Case relates to degraded recovery.

Action:

- Support views recovery summary.

Expected result:

- Support sees case-scoped summary, pending records, evidence completeness, and next review step.
- Support cannot centrally verify or close recovery without authority.

Evidence:

- support view sample
- authority denial where applicable

---

## 21. Audit Tests

### TC-LOCALAGENT-049-AUDIT: Degraded Entry Creates Audit

Precondition:

- Degraded mode starts.

Action:

- Entry is recorded.

Expected result:

- Audit event records trigger, store, runtime, actor/device/service, and time.

Failure severity:

- HIGH

Evidence:

- audit event

---

### TC-LOCALAGENT-050-AUDIT: Local Record Creation Creates Audit

Precondition:

- Local fallback record is created.

Action:

- Record is captured.

Expected result:

- Audit event records local agent/device, actor where applicable, store, resource, fallback marker, and result.

Failure severity:

- HIGH

Evidence:

- audit event

---

### TC-LOCALAGENT-051-AUDIT: Sync Conflict Creates Audit

Precondition:

- Sync conflict occurs.

Action:

- Conflict is recorded.

Expected result:

- Audit event records conflict type, local reference, central reference, affected resource, and review status.

Failure severity:

- HIGH

Evidence:

- audit event

---

### TC-LOCALAGENT-052-AUDIT: Central Verification Creates Audit

Precondition:

- Central verification decision occurs.

Action:

- Record is accepted or rejected.

Expected result:

- Audit event records decision, reason, actor/service, evidence reference, and resulting status.

Failure severity:

- HIGH

Evidence:

- audit event

---

### TC-LOCALAGENT-053-AUDIT: Replay Creates Audit

Precondition:

- Replay is requested.

Action:

- Replay starts and completes.

Expected result:

- Audit records replay request, actor/service, input scope, output, and no-silent-mutation result.

Failure severity:

- HIGH

Evidence:

- replay audit sequence

---

## 22. Evidence Packet Tests

### TC-LOCALAGENT-054-EVIDENCE: Degraded Recovery Evidence Packet Contains Required References

Precondition:

- Degraded recovery case exists.

Action:

- Evidence packet is generated.

Expected result:

- Packet includes degraded entry, local records, fallback markers, cache uncertainty, sync attempts, conflicts, replay output, verification decisions, manual evidence, and audit references.

Evidence:

- degraded recovery evidence packet

---

### TC-LOCALAGENT-055-EVIDENCE: Incomplete Evidence Blocks Verification

Precondition:

- Local record lacks required evidence.

Action:

- Verification readiness is checked.

Expected result:

- Verification is blocked or marked incomplete.
- Missing evidence is listed.

Failure severity:

- HIGH

Evidence:

- evidence completeness result

---

### TC-LOCALAGENT-056-EVIDENCE: Conflict Evidence Shows Both Local And Central Records

Precondition:

- Sync conflict exists.

Action:

- Conflict evidence packet is created.

Expected result:

- Packet includes local record, central record, timestamps, source devices, fallback markers, and audit references.
- Sensitive fields are masked.

Evidence:

- conflict evidence packet

---

### TC-LOCALAGENT-057-EVIDENCE: Payment Uncertainty Evidence Links Provider Status

Precondition:

- Local payment claim conflicts with provider status.

Action:

- Evidence packet is created.

Expected result:

- Packet links local claim, provider status class, payment state, reconciliation status, and audit references.
- Payment secrets are excluded.

Evidence:

- payment uncertainty evidence packet

---

## 23. Deployment Gate Tests For Local Agent

### TC-LOCALAGENT-058-DEPLOY: Local Agent Release Requires Degraded Tests

Precondition:

- Release changes local agent or degraded mode behavior.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless degraded entry, fallback marker, cache uncertainty, sync, and verification tests exist.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- test references

---

### TC-LOCALAGENT-059-DEPLOY: Local Agent Release Requires Conflict And Replay Tests

Precondition:

- Release changes sync conflict, replay, or reconciliation behavior.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless conflict and replay no-silent-mutation tests exist.

Failure severity:

- CRITICAL

Evidence:

- release gate result

---

### TC-LOCALAGENT-060-DEPLOY: Local Agent Release Requires Device Revocation Tests

Precondition:

- Release changes local agent device identity or offline cache behavior.

Action:

- Release gate evaluates device trust tests.

Expected result:

- Release is blocked unless revoked device, lost device, and local agent identity tests exist.

Failure severity:

- CRITICAL

Evidence:

- release gate result

---

### TC-LOCALAGENT-061-DEPLOY: Payment-Affected Degraded Release Requires Payment Uncertainty Tests

Precondition:

- Release affects payment visibility or local payment handling during degraded mode.

Action:

- Release gate evaluates deployment.

Expected result:

- Release is blocked unless degraded payment uncertainty tests exist.

Failure severity:

- CRITICAL

Evidence:

- release gate result
- payment uncertainty test reference

---

## 24. Regression Tests

Regression tests should be created for every local agent or degraded recovery failure.

Regression candidates:

- degraded entry missing marker
- fallback record missing marker
- cache uncertainty hidden
- Secondary overwrote Primary
- Secondary self-promoted
- revoked local agent synced records
- stale local data overwrote central state
- sync conflict silently merged
- replay mutated final truth
- manual note changed payment/refund state
- local record confirmed payment
- degraded customer status overpromised
- support closed recovery without verification
- evidence packet incomplete
- deployment skipped local agent conflict tests

Every degraded recovery incident should generate a regression test.

---

## 25. Coverage Matrix

Recommended coverage matrix:

| Area | Positive | Negative | Sync | Conflict | Replay | Audit | Evidence | Deploy |
| ---- | -------- | -------- | ---- | -------- | ------ | ----- | -------- | ------ |
| Degraded Entry/Exit | Required | Required | Conditional | Conditional | Conditional | Required | Required | Required |
| Fallback Marker | Required | Required | Required | Required | Required | Required | Required | Required |
| Cache Uncertainty | Required | Required | Required | Required | Required | Required | Required | Required |
| Primary/Secondary | Required | Required | Required | Required | Conditional | Required | Required | Required |
| Promoted Primary | Required | Required | Required | Required | Required | Required | Required | Required |
| Sync Retry | Required | Required | Required | Required | Conditional | Required | Required | Conditional |
| Conflict Handling | Required | Required | Required | Required | Required | Required | Required | Required |
| Central Verification | Required | Required | Required | Required | Required | Required | Required | Required |
| Manual Evidence | Required | Required | Conditional | Conditional | Conditional | Required | Required | Conditional |
| Payment Uncertainty | Required | Required | Required | Required | Required | Required | Required | Required |
| Customer/Owner/Support View | Required | Required | Conditional | Conditional | Conditional | Conditional | Required | Conditional |

Coverage gaps become blockers.

---

## 26. Evidence Requirements

Evidence must prove:

- degraded entry is recorded
- degraded exit requires recovery check
- affected runtime is visible
- fallback-originated marker exists
- fallback marker is preserved during sync
- cache uncertainty exists
- cache uncertainty cannot be cleared without verification
- Primary and Secondary boundaries are enforced
- Secondary cannot overwrite Primary
- Secondary cannot self-promote
- Promoted Primary requires evidence
- Recovery Pending state is used
- sync preserves lineage
- sync retry does not duplicate records
- sync failure is visible
- sync conflict does not silently merge
- stale local data does not overwrite central state
- replay does not silently mutate truth
- central verification accepts or rejects with evidence
- correction is append-only
- manual evidence does not become final truth
- local claim does not confirm payment
- customer status is safe
- owner and support views are scoped and masked
- degraded recovery actions are audited
- evidence packets include degraded, sync, conflict, replay, manual, verification, and audit references
- release gates block unsafe local agent changes

Evidence must not expose payment secrets, raw CI / DI, device credentials, local agent credentials, bridge credentials, service secrets, or unrelated tenant data.

---

## 27. Failure Severity

Critical failures include:

- degraded mode bypasses revoked device
- local agent crosses tenant/store boundary
- Secondary overwrites Primary
- Secondary self-promotes without authority
- revoked local agent syncs data
- stale local data overwrites verified central state
- replay silently mutates final truth
- local agent confirms payment
- manual note approves refund
- payment uncertainty is hidden as confirmed
- sync conflict silently merges
- local agent release skips conflict/replay tests

High failures include:

- degraded entry lacks audit
- fallback marker missing
- cache uncertainty missing
- degraded exit finalizes records without recovery check
- sync failure hidden
- central verification lacks evidence
- manual evidence lacks actor/device
- support closes recovery without verification
- customer status overpromises
- evidence packet incomplete

Medium failures include:

- owner summary lacks non-critical recovery detail
- safe degraded message unclear but non-misleading
- non-sensitive audit category mismatch

Critical and high failures block implementation.

---

## 28. Implementation Blockers

Implementation must be blocked if:

- degraded entry/exit tests are missing
- fallback-originated marker tests are missing
- cache uncertainty tests are missing
- Primary/Secondary role tests are missing
- Promoted Primary tests are missing
- Recovery Pending tests are missing
- revoked local agent tests are missing
- cross-tenant/store local agent tests are missing
- sync retry tests are missing
- sync failure tests are missing
- sync conflict tests are missing
- stale overwrite tests are missing
- replay no-silent-mutation tests are missing
- central verification tests are missing
- correction append-only tests are missing
- manual recovery evidence tests are missing
- degraded payment uncertainty tests are missing
- customer/owner/support visibility tests are missing
- audit tests are missing
- evidence packet tests are missing
- deployment gate tests are missing

These blockers must be added to the implementation blocker register.

---

## 29. Test Status Values

Recommended status values:

- `NOT_DEFINED`
- `DRAFT`
- `MAPPED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`
- `IMPLEMENTED`
- `PASS`
- `FAIL`
- `BLOCKED`
- `WAIVED_WITH_APPROVAL`
- `DEFERRED`
- `OBSOLETE`

Critical local agent tests should not be waived unless degraded operation is removed from implementation scope.

---

## 30. Non-Goals

This document does not define:

- final local agent architecture
- final offline cache implementation
- final sync algorithm
- final replay engine
- final conflict resolver
- final central verification service
- final evidence packet schema
- final Store Tablet degraded UI
- final POS/KDS degraded adapter
- final payment reconciliation job
- final support recovery UI
- final automated test code
- final deployment pipeline

Those belong to later controlled implementation phase.

---

## 31. Readiness Check

This test catalog is ready when the project can answer:

1. How is degraded mode entry tested?
2. How is degraded mode exit tested?
3. How is affected runtime recorded?
4. How is fallback-originated marker tested?
5. How is fallback marker preserved during sync?
6. How is cache uncertainty tested?
7. How is cache uncertainty cleared only by verification?
8. How is Primary local agent tested?
9. How is Secondary local agent boundary tested?
10. How is Secondary overwrite denied?
11. How is Secondary self-promotion denied?
12. How is Promoted Primary tested?
13. How is Recovery Pending used?
14. How is sync lineage preserved?
15. How is sync retry idempotent?
16. How is sync failure visible?
17. How is sync retry exhaustion escalated?
18. How is central newer state protected from stale local overwrite?
19. How is local/central divergence handled?
20. How is payment conflict handled?
21. How is KDS conflict handled?
22. How is replay no-silent-mutation tested?
23. How is replay authorization tested?
24. How does replay preserve degraded markers?
25. How is central verification tested?
26. How is invalid local record rejected?
27. How is correction append-only?
28. How is manual kitchen evidence tested?
29. How is manual evidence prevented from approving refund or closing incident?
30. How is payment uncertainty tested?
31. How is customer degraded status safe?
32. How are owner and support views scoped?
33. How are local agent audit events tested?
34. How are degraded recovery evidence packets tested?
35. How do release gates protect local agent changes?
36. What regression tests are required?
37. What evidence is required?
38. What failures are critical?
39. What blocks implementation?

If these questions cannot be answered, local agent degraded recovery sync conflict test catalog is incomplete.

---

## 32. Conclusion

Local agent degraded recovery is a continuity mechanism, not a shortcut around central truth.

The Yoonsul Wait/Order Handoff project must preserve the following rules:

- local continuity is provisional
- degraded entry and exit must be recorded
- fallback-originated records must be marked
- cache uncertainty must be visible
- Primary and Secondary local agent roles must be enforced
- Secondary must not overwrite Primary
- Secondary must not self-promote
- Promoted Primary requires evidence
- Recovery Pending state must exist
- sync must preserve lineage
- sync retry must not duplicate records
- sync failure must be visible
- sync conflict must not silently merge
- stale local data must not overwrite verified central state
- replay must not silently mutate final truth
- central verification must accept or reject records
- correction must be append-only
- manual evidence is evidence, not approval
- local claim must not confirm payment
- payment uncertainty must remain visible
- customer degraded status must be safe
- owner and support views must be scoped and masked
- degraded recovery actions must be audited
- evidence packets must link local, central, sync, conflict, replay, manual, verification, and audit records
- deployment gates must block unsafe local agent changes
- critical failures block implementation

This document does not implement local agent tests.

It defines the local agent degraded recovery sync conflict test catalog that future implementation must satisfy.