# 05000_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Test_Catalog

\#\# 1\. Purpose

This document defines the test catalog policy for POS/KDS RPC communication, bridge authority, accepted order handoff, KDS ticket creation, idempotency, retry, replay, stale event detection, mismatch detection, quarantine, degraded POS/KDS behavior, audit, masking, and evidence requirements in the Yoonsul Wait/Order Handoff project.

POS/KDS handoff is one of the core runtime paths of this project.

If POS/KDS authority is unclear, orders may be duplicated, tickets may be lost, payments may be mutated by the wrong runtime, stale events may overwrite truth, and degraded recovery may silently corrupt store state.

Therefore, POS/KDS RPC and bridge behavior must have explicit positive tests, negative tests, abuse-case tests, idempotency tests, replay tests, stale event tests, degraded tests, audit tests, and evidence requirements before implementation is allowed.

This document does not implement RPC tests, bridge tests, queue workers, database tests, KDS UI tests, POS adapter tests, or automated test code.

It defines the test catalog that future implementation must satisfy.

\---

\#\# 2\. Scope

This test catalog applies to:

\- POS accepted order handoff
\- KDS ticket creation
\- KDS ticket status update
\- POS/KDS bridge validation
\- bridge authority boundary
\- POS authority boundary
\- KDS authority boundary
\- AI/Agent recommendation boundary
\- RPC context validation
\- tenant/store validation
\- device/service identity validation
\- idempotency key handling
\- duplicate event handling
\- retry queue behavior
\- replay behavior
\- stale event detection
\- out-of-order event handling
\- mismatch detection
\- quarantine
\- degraded POS/KDS behavior
\- local agent relay
\- manual kitchen recovery note
\- payment boundary protection
\- audit mapping
\- masking
\- evidence packet linkage
\- implementation blockers

This document focuses on test catalog design, not runtime implementation.

\---

\#\# 3\. Core Principle

POS/KDS tests must prove authority separation under normal, duplicate, stale, replayed, degraded, and malicious conditions.

The project must follow this rule:

\> POS owns transaction truth. KDS owns kitchen execution truth. Bridge validates and relays. Agent recommends. Retry must not duplicate. Replay must not silently mutate. KDS must never mutate payment.

Testing must prove these rules fail safely.

\---

\#\# 4\. Source Mapping Documents

This test catalog verifies constraints from:

\- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy
\- 04841_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping
\- 04851_Audit_Event_Taxonomy_Append_Only_And_Evidence_Implementation_Mapping_Policy
\- 04861_Policy_POS_KDS_RPC_Bridge_Idempotency_Replay_Implementation_Mapping
\- 04871_Policy_Payment_Webhook_Refund_Settlement_And_Reconciliation_Implementation_Mapping
\- 04901_Policy_Device_Trust_Session_Revocation_Store_Runtime_And_Lost_Device_Implementation_Mapping
\- 04911_Policy_Local_Agent_Degraded_Recovery_Sync_Conflict_And_Manual_Evidence_Implementation_Mapping
\- 04971_Policy_Security_And_Runtime_Test_Catalog_Lane_Start_And_Verification_Governance
\- 04981_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog
\- 04991_Audit_Append_Only_Evidence_And_Tamper_Resistance_Test_Catalog_Policy

\---

\#\# 5\. Affected Runtime

This test catalog affects:

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
\- Customer Runtime where order status is visible
\- Owner Runtime where operational summaries are visible
\- AI Analytics Runtime where recommendation is generated

POS/KDS behavior must be tested as runtime flow, not only as isolated table mutations.

\---

\#\# 6\. Risk Categories

This catalog covers the following risk categories:

\- duplicate KDS ticket creation
\- missing KDS ticket
\- wrong-store ticket creation
\- cross-tenant POS/KDS event
\- KDS payment mutation
\- bridge authority overreach
\- agent authority overreach
\- stale event overwrite
\- out-of-order event corruption
\- replay silent mutation
\- retry duplicate mutation
\- POS/KDS mismatch hidden
\- degraded event unmarked
\- fallback-originated record unmarked
\- local agent cross-store relay
\- manual recovery becoming final truth
\- audit missing
\- sensitive data leakage in ticket, log, or audit
\- unsafe customer status message

Critical failures in these categories block implementation.

\---

\#\# 7\. Test Data Setup Requirement

Future tests should include at least:

\- Tenant A
\- Tenant B
\- Store A1
\- Store A2
\- POS Terminal A1
\- POS Terminal A2
\- KDS Device A1
\- KDS Device A2
\- POS/KDS Bridge Service A1
\- Local Agent A1 Primary
\- Local Agent A1 Secondary
\- Customer Order A1
\- POS accepted order event A1
\- KDS ticket A1
\- duplicate POS accepted order event
\- stale KDS status event
\- out-of-order KDS event sequence
\- payment confirmed state
\- payment pending state
\- degraded mode active state
\- manual kitchen recovery note
\- mismatch evidence candidate
\- audit event candidate

Test data must include normal and abnormal event ordering.

\---

\#\# 8\. Test ID Naming Rule

Recommended test id format:

    TC-POSKDS-\[NUMBER\]-\[TYPE\]

Examples:

    TC-POSKDS-001-POSITIVE
    TC-POSKDS-002-NEGATIVE
    TC-POSKDS-003-IDEMPOTENCY
    TC-POSKDS-004-REPLAY
    TC-POSKDS-005-STALE
    TC-POSKDS-006-DEGRADED
    TC-POSKDS-007-AUDIT
    TC-POSKDS-008-MASKING

Final test IDs may change later.

Traceability must remain stable.

\---

\#\# 9\. Positive Tests

\#\#\# TC-POSKDS-001-POSITIVE: Valid POS Accepted Order Creates One KDS Ticket

Precondition:

\- POS Terminal A1 is trusted and store-bound.
\- POS accepted order event is valid.
\- KDS route is available.

Action:

\- POS accepted order event is processed through bridge.

Expected result:

\- One KDS ticket is created.
\- Ticket belongs to Tenant A and Store A1.
\- Ticket references POS order.
\- Idempotency key is stored.
\- Audit event is created.

Evidence:

\- POS event record
\- KDS ticket record
\- idempotency record
\- audit event

\---

\#\#\# TC-POSKDS-002-POSITIVE: KDS Can Update Allowed Kitchen Status

Precondition:

\- KDS ticket exists for Store A1.
\- KDS Device A1 is trusted and scoped.
\- Transition is valid.

Action:

\- KDS updates ticket from received to cooking.

Expected result:

\- KDS status changes.
\- Previous and new state are traceable.
\- Payment state is unchanged.
\- Audit event is created where required.

Evidence:

\- ticket status transition
\- payment state unchanged proof
\- KDS audit event

\---

\#\#\# TC-POSKDS-003-POSITIVE: Bridge Relays Valid KDS Status To POS Visibility

Precondition:

\- KDS ticket exists.
\- Ticket status changes to ready.
\- Bridge is authorized for Store A1.

Action:

\- Bridge relays KDS ready status to POS visibility layer.

Expected result:

\- POS can observe kitchen readiness.
\- POS transaction truth is not overwritten.
\- Audit or bridge event is created.

Evidence:

\- bridge event
\- POS visibility update
\- no transaction mutation proof

\---

\#\#\# TC-POSKDS-004-POSITIVE: Customer Receives Safe Order Status

Precondition:

\- Customer order is linked to POS/KDS state.
\- KDS status is preparing.

Action:

\- Customer requests order status.

Expected result:

\- Customer sees safe status such as preparing.
\- Internal bridge, device, retry, or audit details are not exposed.

Evidence:

\- customer status response
\- masking review

\---

\#\# 10\. Negative Tests

\#\#\# TC-POSKDS-005-NEGATIVE: KDS Cannot Mutate Payment State

Precondition:

\- KDS Device A1 is authenticated and trusted.
\- Payment record exists.

Action:

\- KDS attempts to set payment confirmed, failed, refunded, or cancelled.

Expected result:

\- Request is denied.
\- Payment state remains unchanged.
\- Authority violation audit is created.

Failure severity:

\- CRITICAL

Evidence:

\- denial response
\- before/after payment state
\- audit event

\---

\#\#\# TC-POSKDS-006-NEGATIVE: Bridge Cannot Approve Refund

Precondition:

\- Refund request exists.
\- Bridge service is authenticated.

Action:

\- Bridge attempts refund approval or refund submission.

Expected result:

\- Request is denied.
\- Refund state remains unchanged.
\- Audit event is created.

Failure severity:

\- CRITICAL

Evidence:

\- refund state unchanged
\- bridge denial audit

\---

\#\#\# TC-POSKDS-007-NEGATIVE: KDS Device Cannot Access Wrong Store Ticket

Precondition:

\- KDS Device A1 belongs to Store A1.
\- Ticket A2 belongs to Store A2.

Action:

\- KDS Device A1 attempts to view or update Ticket A2.

Expected result:

\- Access is denied.
\- Ticket A2 remains unchanged.

Failure severity:

\- HIGH

Evidence:

\- denial result
\- before/after ticket state

\---

\#\#\# TC-POSKDS-008-NEGATIVE: POS Terminal Cannot Create Ticket For Wrong Store

Precondition:

\- POS Terminal A1 belongs to Store A1.
\- Payload includes Store A2.

Action:

\- POS accepted order event is submitted.

Expected result:

\- Event is rejected or quarantined.
\- No Store A2 ticket is created.
\- Audit event is created.

Failure severity:

\- CRITICAL

Evidence:

\- rejection or quarantine record
\- no ticket confirmation
\- audit event

\---

\#\# 11\. Bridge Authority Tests

\#\#\# TC-POSKDS-009-AUTHORITY: Bridge Can Validate And Relay But Not Own Transaction Truth

Precondition:

\- Bridge receives valid POS accepted order event.

Action:

\- Bridge validates, translates, and relays event.

Expected result:

\- Bridge creates delivery or relay event.
\- POS remains transaction truth source.
\- Bridge does not create independent transaction truth.

Failure severity:

\- HIGH if authority becomes ambiguous

Evidence:

\- bridge event
\- POS authority reference
\- transaction ownership proof

\---

\#\#\# TC-POSKDS-010-AUTHORITY: Bridge Cannot Silently Overwrite POS State

Precondition:

\- POS state exists.
\- Bridge receives conflicting KDS or local event.

Action:

\- Bridge attempts to overwrite POS state directly.

Expected result:

\- Direct overwrite is denied.
\- Mismatch or reconciliation candidate is created.

Failure severity:

\- CRITICAL

Evidence:

\- overwrite denial
\- mismatch evidence packet

\---

\#\#\# TC-POSKDS-011-AUTHORITY: Bridge Cannot Silently Overwrite KDS State

Precondition:

\- KDS ticket state exists.
\- Bridge receives conflicting POS or local event.

Action:

\- Bridge attempts direct KDS state overwrite without valid transition.

Expected result:

\- Overwrite is denied.
\- Review or reconciliation path is created.

Failure severity:

\- HIGH

Evidence:

\- denial result
\- conflict evidence

\---

\#\#\# TC-POSKDS-012-AUTHORITY: Agent Recommendation Cannot Execute POS/KDS Mutation

Precondition:

\- AI/Agent identifies likely mismatch.

Action:

\- Agent output attempts to mutate POS or KDS state directly.

Expected result:

\- Mutation is denied.
\- Agent output remains recommendation.
\- Audit event created where required.

Failure severity:

\- HIGH to CRITICAL depending mutation

Evidence:

\- denial result
\- recommendation record
\- audit event

\---

\#\# 12\. RPC Context Validation Tests

\#\#\# TC-POSKDS-013-CONTEXT: Missing Tenant Context Is Denied

Precondition:

\- POS/KDS RPC requires tenant context.

Action:

\- RPC request lacks tenant\_id or trusted derived tenant context.

Expected result:

\- Request is denied.
\- No event is processed.
\- Safe error is returned.

Failure severity:

\- CRITICAL

Evidence:

\- denied response
\- audit event where required

\---

\#\#\# TC-POSKDS-014-CONTEXT: Missing Store Context Is Denied

Precondition:

\- POS/KDS RPC requires store context.

Action:

\- RPC request lacks store\_id or trusted derived store context.

Expected result:

\- Request is denied.
\- No ticket or status mutation occurs.

Failure severity:

\- HIGH

Evidence:

\- denied response
\- no mutation confirmation

\---

\#\#\# TC-POSKDS-015-CONTEXT: Missing Idempotency Key Is Denied For Mutating Event

Precondition:

\- POS accepted order or KDS status update is mutating event.

Action:

\- Request lacks idempotency key.

Expected result:

\- Request is denied or marked invalid according to policy.
\- No mutation occurs.

Failure severity:

\- HIGH

Evidence:

\- denial result
\- audit event

\---

\#\#\# TC-POSKDS-016-CONTEXT: Invalid Device Or Service Identity Is Denied

Precondition:

\- RPC request is submitted from unknown or revoked device/service.

Action:

\- Request attempts POS/KDS mutation.

Expected result:

\- Request is denied.
\- No mutation occurs.
\- Device or service denial audit is created.

Failure severity:

\- CRITICAL

Evidence:

\- denial response
\- device/service audit

\---

\#\# 13\. Idempotency Tests

\#\#\# TC-POSKDS-017-IDEMPOTENCY: Duplicate POS Accepted Order Does Not Create Duplicate KDS Ticket

Precondition:

\- POS accepted order event was already processed.
\- KDS ticket exists.

Action:

\- Same POS accepted order event is delivered again with same idempotency key.

Expected result:

\- No duplicate KDS ticket is created.
\- Prior result is returned or duplicate is safely ignored.
\- Duplicate detection trace exists.

Failure severity:

\- CRITICAL if duplicate ticket is created

Evidence:

\- ticket count comparison
\- idempotency record
\- duplicate audit or trace

\---

\#\#\# TC-POSKDS-018-IDEMPOTENCY: Same Idempotency Key With Conflicting Payload Is Quarantined

Precondition:

\- Idempotency key was used for POS order event.
\- New request uses same key with different order payload.

Action:

\- Conflicting request is submitted.

Expected result:

\- Request is rejected or quarantined.
\- No new ticket or mutation occurs.
\- Audit event records conflict.

Failure severity:

\- CRITICAL

Evidence:

\- quarantine record
\- audit event
\- no mutation proof

\---

\#\#\# TC-POSKDS-019-IDEMPOTENCY: Duplicate KDS Status Update Does Not Duplicate State Mutation

Precondition:

\- KDS status update was processed.
\- Same update is delivered again.

Action:

\- Duplicate KDS update arrives.

Expected result:

\- State remains correct.
\- No duplicate business effect occurs.
\- Duplicate trace exists where required.

Failure severity:

\- HIGH

Evidence:

\- status history review
\- idempotency result

\---

\#\#\# TC-POSKDS-020-IDEMPOTENCY: Retry Uses Same Logical Action Scope

Precondition:

\- Bridge delivery failed and retry is scheduled.

Action:

\- Retry runs.

Expected result:

\- Retry reuses same logical action and idempotency scope.
\- Retry does not create duplicate ticket or duplicate status transition.

Failure severity:

\- HIGH

Evidence:

\- retry record
\- idempotency record
\- no duplicate mutation proof

\---

\#\# 14\. Retry Queue Tests

\#\#\# TC-POSKDS-021-RETRY: Failed Bridge Delivery Enters Retry Queue

Precondition:

\- KDS delivery path is temporarily unavailable.

Action:

\- POS accepted order event is processed.

Expected result:

\- Event enters retry queue.
\- Retry status is visible to authorized runtime.
\- No duplicate ticket is created before successful delivery.

Evidence:

\- retry queue record
\- audit or bridge event

\---

\#\#\# TC-POSKDS-022-RETRY: Retry Exhaustion Creates Review Or Incident Path

Precondition:

\- Bridge delivery fails repeatedly.

Action:

\- Retry threshold is exceeded.

Expected result:

\- Event is marked failed, review required, or incident candidate.
\- Failure is not hidden.
\- Audit event is created.

Failure severity:

\- HIGH

Evidence:

\- retry exhaustion record
\- audit event
\- review/incident reference

\---

\#\#\# TC-POSKDS-023-RETRY: Retry Does Not Bypass Tenant Store Validation

Precondition:

\- Retry event exists.

Action:

\- Retry attempts delivery with mismatched or corrupted store context.

Expected result:

\- Retry is denied or quarantined.
\- No wrong-store mutation occurs.

Failure severity:

\- CRITICAL

Evidence:

\- retry rejection
\- audit event

\---

\#\# 15\. Replay Tests

\#\#\# TC-POSKDS-024-REPLAY: Replay Reconstructs Event Sequence Without Silent Mutation

Precondition:

\- POS/KDS mismatch exists.
\- Replay is requested.

Action:

\- Replay runs over event sequence.

Expected result:

\- Replay reconstructs or verifies timeline.
\- Current truth is not silently overwritten.
\- Replay output creates evidence or reconciliation candidate.

Failure severity:

\- CRITICAL if silent mutation occurs

Evidence:

\- replay output
\- no-overwrite proof
\- audit event

\---

\#\#\# TC-POSKDS-025-REPLAY: Replay Requires Authorized Actor Or Service

Precondition:

\- Replay candidate exists.

Action:

\- Unauthorized actor requests replay.

Expected result:

\- Replay request is denied.
\- No replay output is generated.
\- Audit event created where required.

Failure severity:

\- HIGH

Evidence:

\- denied replay
\- audit event

\---

\#\#\# TC-POSKDS-026-REPLAY: Replay Of Old Event Cannot Override Newer Final State

Precondition:

\- Newer verified state exists.
\- Older event is replayed.

Action:

\- Replay processes older event.

Expected result:

\- Older event does not overwrite newer verified state.
\- Stale or conflict result is produced.

Failure severity:

\- CRITICAL

Evidence:

\- state comparison
\- replay conflict result
\- audit event

\---

\#\#\# TC-POSKDS-027-REPLAY: Replay Creates Audit

Precondition:

\- Replay is authorized.

Action:

\- Replay starts and completes.

Expected result:

\- Replay requested and replay completed audit events are created.
\- Replay reason and output are traceable.

Failure severity:

\- HIGH

Evidence:

\- replay audit sequence

\---

\#\# 16\. Stale And Out-Of-Order Event Tests

\#\#\# TC-POSKDS-028-STALE: Stale KDS Status Is Rejected Or Quarantined

Precondition:

\- KDS ticket is already ready.
\- Older cooking event arrives late.

Action:

\- Stale event is processed.

Expected result:

\- Stale event does not downgrade ticket.
\- Event is rejected, ignored safely, or quarantined.
\- Audit or trace is created.

Failure severity:

\- HIGH

Evidence:

\- ticket state remains ready
\- stale event record

\---

\#\#\# TC-POSKDS-029-STALE: Out-Of-Order Status Preserves Chronology Evidence

Precondition:

\- Events arrive in wrong order.

Action:

\- System processes event sequence.

Expected result:

\- Current state remains valid.
\- Chronology uncertainty or event ordering evidence is recorded.

Failure severity:

\- HIGH if state corrupts

Evidence:

\- event timeline
\- chronology marker

\---

\#\#\# TC-POSKDS-030-STALE: Stale POS Cancellation Does Not Silently Stop Kitchen Final State

Precondition:

\- KDS ticket is ready or served.
\- Delayed POS cancellation event arrives.

Action:

\- Stale cancellation is processed.

Expected result:

\- Event triggers review or reconciliation.
\- KDS final state is not silently reversed.

Failure severity:

\- HIGH

Evidence:

\- review candidate
\- no silent reversal proof

\---

\#\# 17\. Mismatch Detection Tests

\#\#\# TC-POSKDS-031-MISMATCH: POS Order Exists But KDS Ticket Missing

Precondition:

\- POS accepted order exists.
\- No KDS ticket exists after expected delivery window.

Action:

\- Mismatch detector runs.

Expected result:

\- Mismatch is detected.
\- Evidence packet is created.
\- Retry, replay, or review path is triggered.

Failure severity:

\- HIGH

Evidence:

\- mismatch evidence packet
\- retry/replay/review record

\---

\#\#\# TC-POSKDS-032-MISMATCH: KDS Ticket Exists But POS Order Missing

Precondition:

\- KDS ticket exists.
\- POS order reference is missing or invalid.

Action:

\- Mismatch detector runs.

Expected result:

\- Mismatch is detected.
\- Ticket is marked review-required or quarantined according to policy.
\- Evidence packet is created.

Failure severity:

\- HIGH

Evidence:

\- mismatch evidence
\- review status

\---

\#\#\# TC-POSKDS-033-MISMATCH: POS Cancelled But KDS Still Cooking

Precondition:

\- POS order is cancelled.
\- KDS ticket remains cooking.

Action:

\- Mismatch detector runs.

Expected result:

\- Mismatch is detected.
\- Staff/support review path is created.
\- Payment/refund authority remains separate.

Failure severity:

\- HIGH

Evidence:

\- mismatch record
\- review path
\- payment state unchanged proof

\---

\#\#\# TC-POSKDS-034-MISMATCH: Duplicate KDS Ticket Detected

Precondition:

\- Two KDS tickets reference same POS order.

Action:

\- Mismatch detector runs.

Expected result:

\- Duplicate ticket is detected.
\- Review or correction candidate is created.
\- No ticket is silently deleted.

Failure severity:

\- HIGH

Evidence:

\- duplicate detection record
\- evidence packet

\---

\#\# 18\. Quarantine Tests

\#\#\# TC-POSKDS-035-QUARANTINE: Invalid Signature Or Service Identity Is Quarantined

Precondition:

\- RPC or bridge event has invalid signature or unknown service identity.

Action:

\- Event is received.

Expected result:

\- Event is rejected or quarantined.
\- No mutation occurs.
\- Audit event is created.

Failure severity:

\- CRITICAL

Evidence:

\- quarantine record
\- no mutation proof
\- audit event

\---

\#\#\# TC-POSKDS-036-QUARANTINE: Cross-Tenant POS/KDS Event Is Quarantined

Precondition:

\- Event source belongs to Tenant A.
\- Payload references Tenant B.

Action:

\- Event is processed.

Expected result:

\- Event is quarantined or denied.
\- No Tenant B mutation occurs.

Failure severity:

\- CRITICAL

Evidence:

\- quarantine record
\- audit event

\---

\#\#\# TC-POSKDS-037-QUARANTINE: Duplicate Key Conflict Is Quarantined

Precondition:

\- Same idempotency key appears with conflicting payload.

Action:

\- Conflicting event is processed.

Expected result:

\- Event is quarantined.
\- No mutation occurs.
\- Review is required.

Failure severity:

\- CRITICAL

Evidence:

\- quarantine record
\- review status

\---

\#\# 19\. Degraded POS/KDS Tests

\#\#\# TC-POSKDS-038-DEGRADED: Degraded Mode Marks POS/KDS Event As Fallback-Originated

Precondition:

\- Store enters degraded mode.
\- POS/KDS event is captured locally.

Action:

\- Local event is recorded.

Expected result:

\- Event has fallback\_originated marker.
\- Cache uncertainty is visible where applicable.
\- Audit event is created.

Failure severity:

\- HIGH

Evidence:

\- local event record
\- marker verification
\- audit event

\---

\#\#\# TC-POSKDS-039-DEGRADED: Local KDS Continuity Does Not Finalize Payment

Precondition:

\- Degraded mode active.
\- KDS ticket progresses locally.
\- Payment confirmation is unavailable.

Action:

\- KDS marks ticket ready.

Expected result:

\- KDS state may be provisional.
\- Payment remains pending or uncertain.
\- No local payment confirmation occurs.

Failure severity:

\- CRITICAL if payment confirmed locally

Evidence:

\- ticket state
\- payment state unchanged
\- degraded audit

\---

\#\#\# TC-POSKDS-040-DEGRADED: Secondary Local Agent Cannot Overwrite Primary POS/KDS State

Precondition:

\- Primary local agent has local POS/KDS state.
\- Secondary local agent has conflicting state.

Action:

\- Secondary attempts sync or overwrite.

Expected result:

\- Overwrite is denied or conflict is created.
\- Primary-derived state is not silently replaced.
\- Central verification required.

Failure severity:

\- CRITICAL

Evidence:

\- conflict record
\- no overwrite proof
\- audit event

\---

\#\#\# TC-POSKDS-041-DEGRADED: Manual Kitchen Recovery Note Creates Evidence Not Final Truth

Precondition:

\- POS/KDS sync failure occurs.
\- Staff creates manual kitchen recovery note.

Action:

\- Manual note is submitted.

Expected result:

\- Evidence record is created.
\- Review or reconciliation status is set where needed.
\- Manual note does not silently mutate payment or transaction truth.

Failure severity:

\- HIGH

Evidence:

\- manual evidence record
\- no transaction mutation proof

\---

\#\# 20\. Payment Boundary Tests

\#\#\# TC-POSKDS-042-PAYMENT: KDS Payment Visibility Does Not Grant Mutation Authority

Precondition:

\- KDS may see payment pending or confirmed signal.

Action:

\- KDS attempts to use signal to update payment state.

Expected result:

\- Mutation is denied.
\- Visibility does not imply authority.

Failure severity:

\- CRITICAL

Evidence:

\- denial result
\- payment state unchanged

\---

\#\#\# TC-POSKDS-043-PAYMENT: POS/KDS Mismatch Does Not Auto-Refund

Precondition:

\- POS/KDS mismatch affects customer order.
\- Refund may be considered.

Action:

\- Mismatch workflow runs.

Expected result:

\- Refund is not automatically approved.
\- Refund request or support review may be created according to policy.
\- Payment authority remains separate.

Failure severity:

\- CRITICAL if refund is approved automatically

Evidence:

\- refund state unchanged or request-only record
\- mismatch evidence

\---

\#\# 21\. Masking Tests

\#\#\# TC-POSKDS-044-MASKING: KDS Ticket Excludes Raw CI / DI

Precondition:

\- Customer has verified identity data.
\- POS accepted order creates KDS ticket.

Action:

\- KDS ticket payload is inspected.

Expected result:

\- Raw CI / DI is excluded.
\- Only operationally necessary data is present.

Failure severity:

\- CRITICAL

Evidence:

\- ticket payload sample
\- masking verification

\---

\#\#\# TC-POSKDS-045-MASKING: KDS Ticket Excludes Payment Secrets

Precondition:

\- Order has payment reference.

Action:

\- KDS ticket payload is inspected.

Expected result:

\- Payment token, card data, provider secret, and webhook secret are absent.
\- Payment signal is limited if present.

Failure severity:

\- CRITICAL

Evidence:

\- ticket payload sample

\---

\#\#\# TC-POSKDS-046-MASKING: Bridge Logs Do Not Expose Secrets

Precondition:

\- Bridge processes POS/KDS event.

Action:

\- Bridge logs are inspected.

Expected result:

\- Logs do not contain service role key, raw auth header, payment token, CI / DI, or provider payload.
\- Masked references are used.

Failure severity:

\- CRITICAL if secrets exposed

Evidence:

\- log sample inspection

\---

\#\# 22\. Audit Tests

\#\#\# TC-POSKDS-047-AUDIT: POS Accepted Order Handoff Creates Audit

Precondition:

\- POS accepted order is processed.

Action:

\- Bridge creates or relays KDS ticket.

Expected result:

\- Audit event records POS/KDS handoff.
\- Tenant/store, resource, idempotency, and result are included.

Failure severity:

\- HIGH

Evidence:

\- audit event

\---

\#\#\# TC-POSKDS-048-AUDIT: Authority Violation Creates Audit

Precondition:

\- KDS attempts payment mutation or Bridge attempts refund approval.

Action:

\- Request is denied.

Expected result:

\- Authority violation audit is created.
\- Attempt is traceable.

Failure severity:

\- HIGH

Evidence:

\- authority violation audit

\---

\#\#\# TC-POSKDS-049-AUDIT: Mismatch Detection Creates Audit

Precondition:

\- POS/KDS mismatch is detected.

Action:

\- Mismatch evidence is created.

Expected result:

\- Audit event records mismatch detection.
\- Evidence packet reference is linked.

Failure severity:

\- HIGH

Evidence:

\- mismatch audit
\- evidence packet reference

\---

\#\# 23\. Evidence Packet Tests

\#\#\# TC-POSKDS-050-EVIDENCE: Mismatch Evidence Packet Contains Required References

Precondition:

\- POS/KDS mismatch exists.

Action:

\- Evidence packet is created.

Expected result:

\- Evidence packet includes POS event, KDS event, bridge event, audit event, tenant/store, mismatch type, and review status.
\- Sensitive fields are masked.

Evidence:

\- evidence packet sample

\---

\#\#\# TC-POSKDS-051-EVIDENCE: Replay Evidence Shows No Silent Mutation

Precondition:

\- Replay runs for POS/KDS event sequence.

Action:

\- Replay completes.

Expected result:

\- Evidence shows replay input, output, decision, and no-overwrite confirmation.

Failure severity:

\- HIGH if evidence missing

Evidence:

\- replay evidence packet

\---

\#\#\# TC-POSKDS-052-EVIDENCE: Degraded POS/KDS Evidence Links Local Agent Records

Precondition:

\- POS/KDS degraded recovery occurs.

Action:

\- Evidence packet is generated.

Expected result:

\- Evidence links local agent records, fallback marker, cache uncertainty, sync attempt, and central verification status.

Evidence:

\- degraded evidence packet

\---

\#\# 24\. Customer And Staff Visibility Tests

\#\#\# TC-POSKDS-053-VISIBILITY: Customer Does Not See Internal Bridge Failure Detail

Precondition:

\- Bridge delivery is delayed.

Action:

\- Customer views order status.

Expected result:

\- Customer sees safe status such as status updating or preparing.
\- Internal bridge errors are hidden.

Failure severity:

\- MEDIUM to HIGH depending exposure

Evidence:

\- customer response sample

\---

\#\#\# TC-POSKDS-054-VISIBILITY: Staff Sees Actionable Mismatch Indicator

Precondition:

\- POS/KDS mismatch exists.

Action:

\- Staff views operational screen.

Expected result:

\- Staff sees review-required or manual recovery required indicator.
\- Staff does not see secrets or raw diagnostics.

Evidence:

\- staff view sample

\---

\#\#\# TC-POSKDS-055-VISIBILITY: Support Sees Case-Scoped POS/KDS Summary

Precondition:

\- Support case is assigned.
\- POS/KDS mismatch relates to case.

Action:

\- Support views case summary.

Expected result:

\- Support sees masked POS/KDS mismatch summary.
\- Support cannot mutate POS/KDS truth without authority.

Evidence:

\- support case view
\- authority denial where tested

\---

\#\# 25\. Deployment Gate Tests For POS/KDS

\#\#\# TC-POSKDS-056-DEPLOY: POS/KDS Release Requires Idempotency Tests

Precondition:

\- Release changes POS/KDS bridge, ticket creation, or status update behavior.

Action:

\- Release gate evaluates deployment.

Expected result:

\- Release is blocked unless idempotency tests are mapped and passing or approved.
\- Gate result is audited.

Failure severity:

\- HIGH

Evidence:

\- release gate record
\- test evidence reference

\---

\#\#\# TC-POSKDS-057-DEPLOY: POS/KDS Release Requires Replay Tests

Precondition:

\- Release changes replay, retry, or mismatch behavior.

Action:

\- Release gate evaluates deployment.

Expected result:

\- Release is blocked unless replay/no-silent-mutation tests exist.

Failure severity:

\- HIGH

Evidence:

\- release gate result

\---

\#\#\# TC-POSKDS-058-DEPLOY: POS/KDS Release Blocks KDS Payment Mutation Risk

Precondition:

\- Release may affect KDS status or payment visibility.

Action:

\- Release gate evaluates payment boundary tests.

Expected result:

\- Release is blocked if KDS can mutate payment or tests are missing.

Failure severity:

\- CRITICAL

Evidence:

\- release gate denial or approval
\- payment boundary test reference

\---

\#\# 26\. Regression Tests

Regression tests should be created for every POS/KDS failure.

Regression candidates:

\- duplicate KDS ticket
\- missing KDS ticket
\- wrong-store ticket
\- KDS payment mutation
\- bridge overreach
\- stale event overwrite
\- replay silent mutation
\- retry duplicate mutation
\- mismatch not detected
\- local agent silent overwrite
\- manual note treated as final truth
\- raw identity in KDS ticket
\- payment secret in KDS payload
\- bridge log secret exposure

Every POS/KDS incident should generate a regression test.

\---

\#\# 27\. Coverage Matrix

Recommended coverage matrix:

| Area | Positive | Negative | Idempotency | Replay | Stale | Degraded | Audit | Masking |
| \---- | \-------- | \-------- | \----------- | \------ | \----- | \-------- | \----- | \------- |
| POS Accepted Order | Required | Required | Required | Conditional | Conditional | Required | Required | Required |
| KDS Ticket Creation | Required | Required | Required | Conditional | Conditional | Required | Required | Required |
| KDS Status Update | Required | Required | Required | Required | Required | Required | Required | Required |
| Bridge Relay | Required | Required | Required | Required | Required | Required | Required | Required |
| Payment Boundary | N/A | Required | Conditional | Conditional | Conditional | Required | Required | Required |
| Local Agent Relay | Required | Required | Required | Required | Required | Required | Required | Required |
| Mismatch Detection | Required | Required | Conditional | Required | Required | Required | Required | Required |
| Customer Visibility | Required | Required | N/A | N/A | Conditional | Required | Conditional | Required |
| Support Visibility | Required | Required | N/A | N/A | Conditional | Required | Required | Required |
| Deployment Gate | N/A | Required | Required | Required | Required | Required | Required | Conditional |

Coverage gaps become blockers.

\---

\#\# 28\. Evidence Requirements

Evidence must prove:

\- valid POS accepted order creates one KDS ticket
\- duplicate POS event does not create duplicate ticket
\- KDS can update kitchen status only within authority
\- KDS cannot mutate payment
\- Bridge cannot approve refund
\- Bridge cannot silently overwrite POS/KDS truth
\- Agent cannot execute mutation
\- RPC context validation works
\- tenant/store validation works
\- device/service identity validation works
\- idempotency works
\- retry does not duplicate mutation
\- replay does not silently mutate truth
\- stale events do not corrupt current state
\- mismatch detection creates evidence
\- quarantine works
\- degraded records are marked fallback-originated
\- Secondary local agent cannot overwrite Primary
\- manual recovery note creates evidence, not final truth
\- KDS ticket excludes raw CI / DI and payment secrets
\- POS/KDS audit events exist
\- release gates block unsafe POS/KDS changes

Evidence must not expose secrets, raw CI / DI, payment tokens, provider secrets, or unrelated tenant data.

\---

\#\# 29\. Failure Severity

Critical failures include:

\- duplicate KDS ticket from duplicate POS event
\- KDS mutates payment
\- Bridge approves refund
\- cross-tenant POS/KDS event accepted
\- wrong-store ticket created
\- replay silently mutates final truth
\- retry creates duplicate mutation
\- stale event overwrites verified state
\- Secondary local agent overwrites Primary state
\- raw CI / DI in KDS payload
\- payment secret in KDS payload or logs

High failures include:

\- missing KDS ticket not detected
\- mismatch evidence not created
\- replay audit missing
\- stale event not marked
\- support can mutate POS/KDS truth without authority
\- degraded record lacks fallback marker
\- manual recovery note treated as final truth
\- release gate missing idempotency/replay tests

Medium failures include:

\- customer status wording exposes minor internal detail
\- lower-risk audit category mismatch
\- non-sensitive bridge diagnostic inconsistency

Critical and high failures block implementation.

\---

\#\# 30\. Implementation Blockers

Implementation must be blocked if:

\- POS accepted order test is missing
\- KDS ticket creation idempotency test is missing
\- KDS status update authority test is missing
\- KDS payment mutation denial test is missing
\- bridge authority tests are missing
\- agent recommendation boundary test is missing
\- RPC context tests are missing
\- tenant/store validation tests are missing
\- device/service identity tests are missing
\- retry tests are missing
\- replay no-silent-mutation tests are missing
\- stale event tests are missing
\- mismatch evidence tests are missing
\- quarantine tests are missing
\- degraded POS/KDS tests are missing
\- local agent overwrite tests are missing
\- manual recovery evidence tests are missing
\- masking tests are missing
\- audit tests are missing
\- deployment gate tests are missing

These blockers must be added to the implementation blocker register.

\---

\#\# 31\. Test Status Values

Recommended status values:

\- \`NOT\_DEFINED\`
\- \`DRAFT\`
\- \`MAPPED\`
\- \`READY\_FOR\_REVIEW\`
\- \`READY\_FOR\_IMPLEMENTATION\`
\- \`IMPLEMENTED\`
\- \`PASS\`
\- \`FAIL\`
\- \`BLOCKED\`
\- \`WAIVED\_WITH\_APPROVAL\`
\- \`DEFERRED\`
\- \`OBSOLETE\`

Critical POS/KDS tests should not be waived unless a safer compensating control exists and implementation scope is reduced.

\---

\#\# 32\. Non-Goals

This document does not define:

\- final RPC function
\- final POS adapter
\- final KDS adapter
\- final bridge service
\- final retry queue
\- final replay engine
\- final mismatch detector
\- final database schema
\- final automated test code
\- final KDS UI test
\- final POS simulator
\- final deployment pipeline
\- final production monitoring

Those belong to later controlled implementation phase.

\---

\#\# 33\. Readiness Check

This test catalog is ready when the project can answer:

1\. How is valid POS accepted order tested?
2\. How is one-ticket-only creation tested?
3\. How is KDS kitchen status update tested?
4\. How is KDS payment mutation denial tested?
5\. How is bridge authority tested?
6\. How is agent recommendation boundary tested?
7\. How is RPC context validated?
8\. How is tenant/store validation tested?
9\. How is device/service identity tested?
10\. How is missing idempotency key handled?
11\. How are duplicate events tested?
12\. How is conflicting idempotency key tested?
13\. How is retry tested?
14\. How is retry exhaustion tested?
15\. How is replay no-silent-mutation tested?
16\. How is replay authorization tested?
17\. How are stale events tested?
18\. How are out-of-order events tested?
19\. How is mismatch detection tested?
20\. How is quarantine tested?
21\. How is degraded POS/KDS behavior tested?
22\. How is local agent boundary tested?
23\. How is manual kitchen evidence tested?
24\. How is payment boundary tested?
25\. How is KDS masking tested?
26\. How are bridge logs inspected?
27\. How is audit tested?
28\. How is evidence packet tested?
29\. How is customer visibility tested?
30\. How is staff/support visibility tested?
31\. How does deployment gate protect POS/KDS release?
32\. What regression tests are required?
33\. What evidence is required?
34\. What failures are critical?
35\. What blocks implementation?

If these questions cannot be answered, POS/KDS RPC bridge test catalog is incomplete.

\---

\#\# 34\. Conclusion

POS/KDS RPC bridge behavior is the runtime center of the Yoonsul Wait/Order Handoff system.

The system must preserve the following rules:

\- POS owns transaction truth
\- KDS owns kitchen execution truth
\- Bridge validates and relays
\- Agent recommends only
\- valid POS accepted order creates one KDS ticket
\- duplicate POS event must not create duplicate ticket
\- KDS must not mutate payment
\- Bridge must not approve refund
\- tenant/store context must be validated
\- device/service identity must be validated
\- idempotency must be tested
\- retry must not duplicate mutation
\- replay must not silently mutate truth
\- stale events must not overwrite verified state
\- mismatches must create evidence
\- invalid events must be denied or quarantined
\- degraded events must be marked
\- Secondary local agent must not overwrite Primary
\- manual recovery captures evidence, not final truth
\- KDS payload must exclude raw identity and payment secrets
\- POS/KDS actions must be audited
\- release gates must require idempotency, replay, payment boundary, and degraded tests
\- critical failures block implementation

This document does not implement POS/KDS tests.

It defines the POS/KDS RPC bridge test catalog that future implementation must satisfy.
