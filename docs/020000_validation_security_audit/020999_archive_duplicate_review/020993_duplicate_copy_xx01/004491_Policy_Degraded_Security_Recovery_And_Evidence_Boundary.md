# 004491_Policy_Degraded_Security_Recovery_And_Evidence_Boundary

## 1. Purpose

This document defines the security, recovery, and evidence boundary policy for degraded operation in the Yoonsul Wait/Order Handoff project.

Degraded operation is not simply a technical fallback.

It affects order continuity, POS/KDS synchronization, kitchen execution, customer trust, staff accountability, recovery evidence, and audit integrity.

Therefore, degraded mode must be treated as a controlled security state.

---

## 2. Scope

This policy applies to:

- network failure
- POS/KDS bridge failure
- local agent failure
- central server connectivity failure
- store LAN partial failure
- KDS delayed synchronization
- POS delayed synchronization
- manual kitchen recovery
- manual order recovery
- fallback-originated records
- retry and replay conflict
- cache uncertainty
- recovery evidence packet
- degraded mode audit

This document does not implement degraded operation.

It defines the mandatory boundary rules that later degraded mode, recovery, bridge, agent, POS, KDS, and audit documents must follow.

---

## 3. Core Principle

Degraded mode may preserve operation.

Degraded mode must not weaken security.

The project must follow this rule:

> Continuity without evidence is not acceptable recovery.

A store may continue minimum operation during failure.

However, every fallback-originated state must remain traceable, provisional, and reviewable until verified.

---

## 4. Degraded Mode Is A Security State

Degraded mode must be represented as an explicit runtime state.

It must not be hidden as a normal operation state.

Examples of degraded security states:

- `DEGRADED_OPERATION_ACTIVE`
- `LOCAL_AGENT_ACTIVE`
- `CENTRAL_SYNC_UNAVAILABLE`
- `CACHE_STATE_UNCERTAIN`
- `FALLBACK_ORIGINATED`
- `MANUAL_RECOVERY_REQUIRED`
- `REPLAY_REQUIRED`
- `RECONCILIATION_REQUIRED`
- `RECOVERY_PENDING`
- `CHRONOLOGY_UNCERTAIN`

When any of these states are active, the system must preserve evidence and restrict unsafe mutation.

---

## 5. Degraded Mode Entry Conditions

The system may enter degraded mode when one or more of the following occurs:

- central server unreachable
- POS bridge unavailable
- KDS bridge unavailable
- POS accepted order cannot reach KDS
- KDS ticket status cannot return to POS
- local network partition occurs
- local agent takes over provisional relay
- device clock mismatch affects ordering
- retry queue exceeds safe delay threshold
- RPC signature validation cannot be completed due to connectivity state
- store operation must continue using manual evidence

Entry into degraded mode must create an audit event.

---

## 6. Degraded Mode Authority Rules

Degraded mode does not create new authority.

It only changes how already-authorized actions are captured, marked, and later verified.

### 6.1 Allowed During Degraded Mode

The following may be allowed under controlled conditions:

- local ticket visibility
- kitchen note capture
- manual kitchen progress update
- provisional order-to-ticket relay
- staff recovery note
- customer-facing delay notice
- evidence capture
- retry queue creation
- local agent provisional coordination
- recovery case creation

### 6.2 Not Allowed During Degraded Mode Without Verification

The following must not be finalized only from degraded state:

- final payment correction
- final refund execution
- final settlement correction
- final customer compensation approval
- final audit closure
- cross-tenant data merge
- silent state overwrite
- permanent deletion of mismatch record
- automatic legal confirmation
- automatic blame assignment

Degraded mode may preserve business continuity.

It must not create final truth without verification.

---

## 7. Fallback-Originated Data Policy

Any data created during fallback must be marked clearly.

Fallback-originated records must include:

- fallback flag
- degraded mode reason
- source runtime
- source device
- actor if human-initiated
- local timestamp
- server received timestamp when later synced
- evidence reference
- sync status
- verification status
- conflict status if applicable

Required marker:

- `FALLBACK_ORIGINATED`

Possible additional markers:

- `CACHE_STATE_UNCERTAIN`
- `RECOVERY_PENDING`
- `REVIEW_REQUIRED`
- `CHRONOLOGY_UNCERTAIN`
- `RECONCILIATION_REQUIRED`

Fallback-originated data must never be silently converted into verified central truth.

---

## 8. Local Agent Boundary

Local Agent may support continuity during degraded mode.

Local Agent may:

- hold provisional store state
- relay POS/KDS events locally
- queue retry events
- detect mismatch
- produce evidence packet
- preserve order of local observations
- support kitchen visibility
- report recovery need

Local Agent must not:

- become transaction authority
- become final kitchen authority after central recovery
- approve payment correction
- approve refund
- approve settlement adjustment
- silently overwrite central state
- erase local conflict
- finalize recovery without authorized review

Local Agent is a continuity assistant, not final authority.

---

## 9. Primary And Secondary Local Agent Rule

If multiple local agents exist, their authority must be separated.

### 9.1 Primary Local Agent

Primary Local Agent may coordinate provisional local continuity.

Primary may:

- receive local fallback events
- maintain provisional local queue
- provide provisional kitchen visibility
- prepare sync package
- create evidence summary
- detect divergence

Primary must mark all data as provisional until central verification.

### 9.2 Secondary Local Agent

Secondary Local Agent may support redundancy.

Secondary must not overwrite Primary.

Secondary may:

- pull from Primary
- hold backup cache
- detect divergence
- report mismatch
- assist recovery evidence

Secondary must not:

- promote itself silently
- overwrite Primary queue
- overwrite central state
- finalize recovery
- erase divergence

### 9.3 Promotion

Secondary may become Promoted Primary only under explicit promotion condition.

Promotion must create audit event.

Promotion must include:

- promotion reason
- time of promotion
- previous Primary status
- new Promoted Primary identity
- store context
- evidence reference

---

## 10. Cache State Uncertainty

Cache uncertainty must be explicitly marked.

Cache state becomes uncertain when:

- local state differs from central state
- Primary and Secondary local agents differ
- POS and KDS states differ
- timestamp ordering is unclear
- retry queue contains delayed events
- replay result conflicts with current state
- device clock is unreliable
- manual recovery note conflicts with system state

Required marker:

- `CACHE_STATE_UNCERTAIN`

Uncertain cache must not be used as final truth.

It may be used only for review, reconstruction, and recovery proposal.

---

## 11. Sync And Merge Policy

Sync is not merge.

Delayed sync may upload fallback-originated records.

However, delayed sync must not silently overwrite verified central state.

Sync result must be classified as one of the following:

- accepted as non-conflicting evidence
- accepted as provisional history
- rejected as duplicate
- quarantined as conflict
- marked for manual review
- marked for replay
- marked for reconciliation

If conflict exists, the system must create:

- `RECONCILIATION_REQUIRED`
- `RECOVERY_PENDING`
- `REVIEW_REQUIRED`

Silent merge is prohibited.

---

## 12. Replay During Degraded Recovery

Replay may help reconstruct degraded events.

Replay may be used to:

- compare local queue and central state
- reconstruct missing transition
- detect duplicate ticket
- detect delayed POS event
- detect delayed KDS event
- prepare recovery evidence
- identify chronology conflict

Replay must not:

- overwrite central state
- delete mismatch
- finalize payment correction
- finalize kitchen correction
- approve compensation
- close recovery case

Replay output must be marked as replay-derived.

If replay changes understanding of the incident, an append-only recovery note must be created.

---

## 13. Manual Recovery Evidence

Manual recovery must create evidence.

Manual evidence may include:

- staff note
- kitchen note
- POS screen photo reference
- KDS screen photo reference
- printed ticket reference
- customer receipt reference
- manager confirmation
- timestamped incident note
- local agent queue snapshot
- retry queue snapshot
- mismatch summary

Manual evidence must include:

- actor
- role
- store context
- device context if applicable
- order or ticket reference
- reason
- time observed
- time recorded
- affected state
- requested recovery action

Manual recovery without evidence must remain unresolved.

---

## 14. Recovery Approval Boundary

Recovery approval must be separated from recovery evidence.

Evidence may support approval.

Evidence is not approval.

The following actions require approval boundary:

- final order correction
- final payment correction
- refund confirmation
- customer compensation
- settlement adjustment
- audit closure
- incident closure
- staff accountability decision
- repeated failure classification

Approval must include:

- approver identity
- authority scope
- approval reason
- evidence reviewed
- before state
- after state
- timestamp
- audit reference

---

## 15. Audit Requirements

The following degraded security events must be audited:

- degraded mode entry
- degraded mode exit
- local agent activation
- Primary local agent failure
- Secondary local agent promotion
- fallback-originated event creation
- cache uncertainty detected
- retry queue created
- retry failed
- replay requested
- replay conflict detected
- sync conflict detected
- manual recovery note created
- evidence packet created
- recovery approval requested
- recovery approved
- recovery denied
- central verification completed

Audit must be append-only.

Audit must preserve both failure and recovery history.

---

## 16. Degraded Mode Exit Conditions

The system may exit degraded mode only when:

- central connectivity is restored
- queued events are uploaded or safely quarantined
- cache uncertainty is resolved or marked for review
- fallback-originated events are classified
- POS/KDS mismatch is resolved or escalated
- recovery evidence is attached where needed
- audit event is created
- local provisional state is no longer treated as current truth

Exit from degraded mode does not mean all recovery is complete.

Exit means normal communication has resumed.

Unresolved recovery cases may remain open.

---

## 17. Customer Communication During Degraded Mode

Customer-facing communication must be accurate and safe.

The system may show:

- temporary delay
- order being verified
- kitchen confirmation pending
- staff assistance required
- payment confirmation pending where applicable

The system must not show false certainty.

The system must not claim:

- payment completed when unverified
- order cancelled when unverified
- refund completed when unverified
- kitchen completed when unverified
- compensation approved when unverified

Customer trust requires honest state communication.

---

## 18. Staff Communication During Degraded Mode

Staff-facing communication must distinguish:

- confirmed state
- provisional state
- manual action required
- recovery pending
- sync pending
- conflict detected
- HQ review required

Staff must not be shown uncertain data as final truth.

Staff UI should make degraded mode visible.

---

## 19. Security Readiness Checklist

Before degraded mode implementation, confirm:

- Degraded mode is represented as explicit state.
- Fallback-originated data is marked.
- Local agent cannot become transaction authority.
- Secondary local agent cannot overwrite Primary.
- Cache uncertainty is marked.
- Sync does not silently merge conflicts.
- Replay cannot overwrite central state.
- Manual recovery requires evidence.
- Evidence is separated from approval.
- Recovery approval is audited.
- Degraded mode exit does not close unresolved incidents automatically.
- Customer communication avoids false certainty.
- Staff communication distinguishes provisional and verified state.
- Audit is append-only.
- Recovery preserves original failure history.

If any item fails, implementation must not proceed.

---

## 20. Non-Goals

This document does not define:

- final local agent implementation
- final offline database structure
- final queue technology
- final POS vendor recovery protocol
- final KDS vendor recovery protocol
- final customer UI design
- final staff UI design
- final incident response runbook
- final compensation policy
- final settlement correction policy

Those must be defined in later implementation or operation documents.

---

## 21. Conclusion

Degraded operation is a survival mechanism.

However, survival without traceability creates operational and security risk.

The Yoonsul Wait/Order Handoff system must preserve the following rules:

- degraded mode is explicit
- fallback-originated data is marked
- local state is provisional
- sync is not silent merge
- replay is not mutation
- evidence is not approval
- recovery is append-only
- customer communication must avoid false certainty
- audit must preserve both failure and recovery

The system must continue operation where possible, but it must not sacrifice trust, security, or evidence integrity.