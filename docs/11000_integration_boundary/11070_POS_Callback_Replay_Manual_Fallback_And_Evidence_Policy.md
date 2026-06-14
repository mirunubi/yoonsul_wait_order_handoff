03540 POS Callback Replay Manual Fallback And Evidence Policy

Legacy path: $old.

1. Purpose

This document defines POS Callback Validation, Replay, Manual Fallback, Degraded Operation, Evidence Packet, Support Signal, and Audit policy for CatchMenu / Wait Order Handoff.

External POS integration cannot assume that every handoff succeeds immediately.

Provider callbacks may be delayed, duplicated, invalid, missing, or contradictory.

Network timeout may occur after the POS provider actually accepted the order.

Manual fallback may be required when POS integration is not configured, unsupported, degraded, or unsafe.

Therefore, CatchMenu must define strict callback validation, idempotent replay, manual fallback, and evidence rules before automatic POS handoff becomes operationally trusted.

Core purpose:

Define POS callback validation.
Define webhook/callback trust boundary.
Define callback idempotency.
Define replay policy.
Define replay safety guard.
Define manual POS fallback.
Define degraded POS operation.
Define evidence packet.
Define support signal.
Define audit event.
Prevent duplicate order.
Prevent unsafe callback mutation.
Prevent silent POS handoff failure.
Preserve explainable history.

Korean purpose:

POS callback 검증을 정의한다.
webhook/callback 신뢰 경계를 정의한다.
callback idempotency를 정의한다.
replay 정책을 정의한다.
replay 안전 guard를 정의한다.
수동 POS fallback을 정의한다.
POS degraded operation을 정의한다.
evidence packet을 정의한다.
support signal을 정의한다.
audit event를 정의한다.
중복 주문을 방지한다.
검증되지 않은 callback에 의한 unsafe mutation을 방지한다.
POS handoff 실패가 조용히 사라지는 것을 방지한다.
설명 가능한 이력을 보존한다.

2. Scope

This document covers:

POS callback
POS webhook
callback validation
callback idempotency
callback duplicate handling
callback delay handling
provider response
timeout handling
unknown result handling
replay
manual replay
system replay
status recheck
manual POS fallback
degraded operation
evidence packet
support signal
audit event
failure event

This document does not define:

provider-specific API code
provider-specific secret values
menu mapping detail
table mapping detail
order payload mapping detail
payment provider settlement
KDS ticket execution
full accounting ledger

Related documents:

03500_External_POS_Integration_Runtime_Readme.md
03510_POS_Integration_Module_And_All_POS_Expansion_Strategy.md
03520_POS_Provider_Adapter_Contract_And_Capability_Declaration_Policy.md
03530_POS_Menu_Table_Order_Mapping_And_Idempotency_Policy.md
03950_POS_Manual_Fallback_Training_And_Store_Usage_Policy.md
03600_Billing_Plan_Settlement_Readme.md

3. Core Principle

External POS callback, replay, and manual fallback must be safe, idempotent, and evidence-backed.

Core rule:

Validate callback before trust.
Check duplicate risk before replay.
Use manual fallback when automation is unsafe.
Preserve evidence for every handoff outcome.

Korean rule:

callback은 검증 후 신뢰한다.
replay 전 중복 위험을 확인한다.
자동화가 위험하면 manual fallback을 사용한다.
모든 handoff 결과에는 증빙을 남긴다.

4. Callback Trust Boundary

A provider callback is external input.

It may inform CatchMenu.

It must not automatically become CatchMenu business truth unless validated and accepted under policy.

Callback may include:

provider event id
provider order id
provider store id
provider status
timestamp
signature
payload
retry count
error code
payment reference if available

Core rule:

Provider callback is provider fact, not universal truth.

5. Callback Validation

Callback validation should include:

provider identity
provider binding
merchant store scope
signature if available
timestamp window
event id
payload schema
idempotency key
known handoff candidate
status transition validity
duplicate event check
replay protection

If validation fails:

reject callback
record failure event
emit support signal if needed
do not mutate integration state
preserve raw payload under safe policy

Core rule:

Unvalidated callback must not mutate CatchMenu state.

6. Callback Idempotency

Callback processing must be idempotent.

Duplicate callbacks may occur due to provider retry.

Callback idempotency should use:

provider_id
provider_event_id
provider_order_id if available
handoff_candidate_id
callback_received_at
payload hash if needed

Core rule:

Same callback event must not produce multiple state changes.

7. Callback Status Transition Guard

Callback status must be checked against valid transition rules.

Examples:

SENT → ACCEPTED
SENT → REJECTED
TIMEOUT → ACCEPTED
UNKNOWN_RESULT → ACCEPTED
UNKNOWN_RESULT → REJECTED
ACCEPTED → CANCELLED if provider supports

Invalid or suspicious transitions:

REJECTED → ACCEPTED without replay/reference
ACCEPTED → SENT
MANUAL_FALLBACK_MARKED → ACCEPTED without reconciliation
UNKNOWN provider order id
order id for different store

Core rule:

Callback status transition must be valid before reference update.

8. Callback Delay Handling

Callbacks may arrive late.

Late callback may occur when:

provider retry delayed
network issue
provider queue delay
merchant manually processed order
request already completed manually
replay already occurred

Late callback handling should:

check current handoff state
check manual fallback state
check idempotency
record late callback
avoid duplicate order
require review if conflict exists

Core rule:

Late callback must be reconciled, not blindly applied.

9. Callback Conflict Handling

Callback conflict occurs when callback contradicts current known state.

Examples:

provider says accepted after manual fallback
provider says rejected after acceptance
callback belongs to wrong store
callback payload differs from original handoff
provider order id reused

Actions:

mark conflict
preserve payload
emit support signal
require review
block automatic mutation
attach evidence packet

Core rule:

Callback conflict requires review.

10. Timeout Handling

Timeout is not proof of failure.

Timeout may mean:

provider did not receive request
provider received but did not respond
provider accepted but response lost
network interrupted
callback may arrive later

After timeout:

mark TIMEOUT or UNKNOWN_RESULT
check provider status if possible
wait for callback if provider supports
avoid blind retry
prepare replay review
prepare manual fallback if operation requires

Core rule:

Timeout must be treated as unknown result until checked.

11. Unknown Result Handling

UNKNOWN_RESULT is high-risk.

Unknown result means CatchMenu cannot confirm whether POS accepted the order.

Actions:

block automatic retry
emit support signal
check provider status if available
check merchant request board
check manual fallback marker
allow operator review
record evidence

Core rule:

Unknown result cannot be retried blindly because duplicate POS order may occur.

12. Replay Definition

Replay means re-processing or re-sending an integration event under controlled conditions.

Replay may be used for:

failed provider call
timeout recovery
callback missing
mapping corrected after failure
provider temporary outage
manual operator recovery

Replay must not erase original attempt.

Core rule:

Replay is append-only recovery, not overwrite.

13. Replay Types

Suggested replay types:

STATUS_RECHECK
CALLBACK_REPROCESS
PAYLOAD_RETRY
MANUAL_REPLAY
SYSTEM_REPLAY
SUPPORT_ASSISTED_REPLAY

Meaning:

STATUS_RECHECK
= ask provider for current order status if supported

CALLBACK_REPROCESS
= reprocess already received callback after validation correction

PAYLOAD_RETRY
= resend payload if safe

MANUAL_REPLAY
= operator initiates replay

SYSTEM_REPLAY
= system performs controlled retry

SUPPORT_ASSISTED_REPLAY
= support team assists after evidence review

Core rule:

Replay type must be explicit.

14. Replay Eligibility

Replay is eligible only when:

handoff candidate exists
idempotency key exists
provider capability allows safe retry or status check
duplicate risk is assessed
current state allows replay
mapping version is known
original payload is available
audit trail exists

Core rule:

No idempotency and no duplicate risk review, no automatic replay.

15. Replay Ineligibility

Replay is not eligible when:

unknown result with high duplicate risk
provider lacks idempotency support
manual fallback already completed without reconciliation
mapping changed without review
critical note could be lost
store binding inactive
credential invalid
provider suspended

Possible actions:

manual fallback
support review
provider status check
mapping review
merchant notification

Core rule:

Unsafe replay must become review or fallback.

16. Replay Evidence

Replay must record:

original handoff candidate
original attempt id
original payload hash
provider id
store binding id
failure reason
replay type
actor
replay time
idempotency key
result
audit event
support signal if any

Core rule:

Replay must explain why it was safe.

17. Manual POS Fallback Definition

Manual POS fallback means staff or authorized operator manually enters or handles CatchMenu request in the POS when automated POS integration is unavailable, unsafe, incomplete, or failed.

Manual fallback may be used when:

NO_POS_INTEGRATION
MANUAL_POS_ENTRY mode
mapping incomplete
provider unavailable
provider timeout
handoff rejected
callback invalid
idempotency risk
critical note cannot be transferred safely
merchant chooses manual operation

Core rule:

Manual fallback is official interim operation when explicit and recorded.

18. Manual Fallback Record

Manual fallback should record:

manual_fallback_id
request_id
handoff_candidate_id optional
merchant_store_id
actor_type
actor_id
fallback_reason
handled_at
manual_pos_reference optional
items_summary
critical_note_present
status
note

Core rule:

Manual fallback without record becomes invisible operational risk.

19. Manual Fallback Status

Suggested statuses:

REQUIRED
IN_PROGRESS
HANDLED
FAILED
CANCELLED
REVIEW_REQUIRED
RECONCILIATION_REQUIRED

Core rule:

Manual fallback status must be visible to store and support users.

20. Manual Fallback And Duplicate Risk

Manual fallback can create duplicate risk if system retry later succeeds.

Controls:

mark manual fallback before retry
block automatic replay after manual handled
reconcile late provider callback
show duplicate risk warning
require support review for conflict

Core rule:

Manual fallback and replay must know about each other.

21. Degraded Operation

POS integration degraded operation means CatchMenu continues with reduced POS capability.

Degraded modes:

REQUEST_BOARD_ONLY
SHOW_TO_STAFF_ONLY
MANUAL_POS_ENTRY
POS_HANDOFF_PAUSED
ORDER_INJECTION_DISABLED
CALLBACK_REVIEW_REQUIRED
PROVIDER_SUSPENDED

Core rule:

POS failure should degrade POS handoff, not destroy CatchMenu service truth.

22. Provider Outage Handling

When provider outage occurs:

mark provider degraded
pause unsafe automatic handoff
show authorized warning
use manual fallback
queue safe replay candidates
emit support signal
audit status change

Core rule:

Provider outage must have operational fallback before merchant trust collapses.

23. Evidence Packet

Evidence packet explains POS integration event history.

Evidence packet may include:

CatchMenu request id
handoff candidate id
provider id
store binding id
integration mode
capability version
menu mapping version
table mapping version
idempotency key
payload hash
provider response
callback payload
validation result
handoff status
timeout record
replay record
manual fallback record
operator note
support signal
audit events
failure events

Core rule:

If POS handoff is disputed, evidence packet must explain the path.

24. Evidence Retention

Evidence should be retained according to data retention policy.

Evidence must not expose secrets.

Evidence may include credential reference but not secret value.

Core rule:

Evidence must be useful for diagnosis without leaking secrets.

25. Store And Merchant Visibility

Merchant-facing visibility should be clear but not overly technical.

Merchant may see:

POS integration status
handoff status
manual fallback required
provider degraded warning
support case link

Internal support may see:

payload reference
callback validation
idempotency key
mapping version
failure code
replay status
evidence packet

Core rule:

Visibility should match role and sensitivity.

26. Billing Impact Boundary

POS integration failure may affect billing only under Billing Plan Settlement policy.

Examples:

POS add-on unavailable
provider degraded for extended period
custom integration failed
manual fallback required during paid POS add-on

Billing may review credits, discounts, or add-on limitation only under policy.

Core rule:

POS failure does not automatically change billing without billing policy.

27. Support Signal

Support signals may include:

POS_CALLBACK_INVALID
POS_CALLBACK_DUPLICATE
POS_CALLBACK_DELAYED
POS_CALLBACK_CONFLICT
POS_HANDOFF_TIMEOUT
POS_UNKNOWN_RESULT_REVIEW_REQUIRED
POS_REPLAY_REQUIRED
POS_REPLAY_BLOCKED_DUPLICATE_RISK
MANUAL_POS_FALLBACK_REQUIRED
MANUAL_POS_FALLBACK_RECONCILIATION_REQUIRED
POS_PROVIDER_DEGRADED
POS_EVIDENCE_PACKET_REQUIRED

Support Signal alerts.

It does not mutate POS state by itself.

28. Audit Events

Recommended audit events:

POS_CALLBACK_RECEIVED
POS_CALLBACK_VALIDATED
POS_CALLBACK_REJECTED
POS_CALLBACK_DUPLICATE_IGNORED
POS_CALLBACK_CONFLICT_MARKED
POS_HANDOFF_TIMEOUT_MARKED
POS_UNKNOWN_RESULT_MARKED
POS_REPLAY_ELIGIBILITY_CHECKED
POS_REPLAY_REQUESTED
POS_REPLAY_ATTEMPTED
POS_REPLAY_COMPLETED
POS_REPLAY_BLOCKED
MANUAL_POS_FALLBACK_REQUIRED
MANUAL_POS_FALLBACK_STARTED
MANUAL_POS_FALLBACK_HANDLED
MANUAL_POS_FALLBACK_RECONCILIATION_REQUIRED
POS_PROVIDER_DEGRADED_MARKED
POS_PROVIDER_RECOVERED
POS_EVIDENCE_PACKET_CREATED

Minimum audit fields:

event_id
merchant_account_id
merchant_store_id
provider_id
pos_binding_id
handoff_candidate_id
actor_type
actor_id
action
previous_value
new_value
reason
created_at
trace_id

29. Failure Events

Example failure codes:

WOH.POS.CALLBACK.INVALID_SIGNATURE
WOH.POS.CALLBACK.UNKNOWN_PROVIDER
WOH.POS.CALLBACK.UNKNOWN_STORE_BINDING
WOH.POS.CALLBACK.UNKNOWN_HANDOFF
WOH.POS.CALLBACK.DUPLICATE_EVENT
WOH.POS.CALLBACK.INVALID_TRANSITION
WOH.POS.CALLBACK.CONFLICT
WOH.POS.HANDOFF.TIMEOUT_UNKNOWN_RESULT
WOH.POS.REPLAY.IDEMPOTENCY_REQUIRED
WOH.POS.REPLAY.DUPLICATE_RISK
WOH.POS.REPLAY.NOT_ELIGIBLE
WOH.POS.MANUAL_FALLBACK.REQUIRED
WOH.POS.MANUAL_FALLBACK.RECONCILIATION_REQUIRED
WOH.POS.EVIDENCE.PACKET_REQUIRED

Failure/error naming is governed by:

docs/00000_foundation/00080_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy.md

30. Relationship To POS Mapping And Idempotency

Mapping and idempotency determine safe callback, replay, and fallback.

Examples:

mapping version missing
→ replay blocked

idempotency key missing
→ automatic retry blocked

manual fallback handled
→ late callback requires reconciliation

unknown result
→ duplicate risk review required

Core rule:

Replay and fallback must respect mapping and idempotency state.

31. Relationship To Merchant Success

Merchant Success may detect operational fallback burden.

Merchant Success should record:

manual fallback frequency
staff confusion
duplicate order concern
provider failure pattern
merchant trust issue
POS integration readiness

Core rule:

Repeated manual fallback burden should become POS improvement signal.

32. Relationship To Provider Adapter Runtime

Provider Adapter Runtime handles provider-specific callback and retry details.

External POS Integration Runtime defines POS business safety.

Core rule:

Adapter receives provider event.
POS Integration decides safe interpretation under policy.

33. Relationship To KDS Path

KDS handoff may depend on POS acceptance.

If POS status is unknown:

do not create automatic KDS ticket unless separate authority allows

Core rule:

KDS path must not trust unresolved POS handoff result.

34. MVP Requirements

MVP should support at least:

callback event record placeholder
callback validation status
callback duplicate detection placeholder
handoff timeout status
unknown result status
manual fallback required status
manual fallback handled status
replay required status
replay blocked status
evidence packet placeholder
support signal
audit event
failure event

MVP may defer:

full provider webhook automation
automatic replay engine
advanced provider health dashboard
full evidence export
automated duplicate risk scoring
advanced callback signature library

35. Suggested Conceptual Entities

Suggested entities:

pos_callback_events
pos_callback_validation_results
pos_unknown_result_events
pos_replay_events
pos_manual_fallback_events
pos_degraded_operation_events
pos_evidence_packets
pos_callback_audit_events
pos_replay_failure_events
pos_fallback_support_signals

This document defines policy.

Actual schema may be designed later.

36. Risk If Skipped

If callback, replay, manual fallback, and evidence policy is skipped, risks include:

duplicate POS orders
lost POS orders
late callback overwrites manual result
timeout retried unsafely
provider failure becomes invisible
merchant cannot trust integration
support cannot diagnose issue
billing disputes lack evidence
KDS receives wrong order signal
manual fallback becomes hidden labor

Therefore, POS integration must include callback validation, safe replay, manual fallback, and evidence from the beginning.

37. Final Rule

POS integration trust depends on safe recovery and evidence.

Final rule:

Validate callback.
Deduplicate callback.
Guard status transition.
Treat timeout as unknown.
Do not retry unknown result blindly.
Replay only when safe.
Keep replay append-only.
Use manual fallback when automation is unsafe.
Record manual fallback.
Reconcile late callback.
Mark provider degraded when needed.
Preserve evidence packet.
Audit every recovery path.
Do not let POS integration failure disappear silently.
