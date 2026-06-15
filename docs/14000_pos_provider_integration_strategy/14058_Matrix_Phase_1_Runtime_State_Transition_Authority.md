# 14058_Matrix_Phase_1_Runtime_State_Transition_Authority

## 1. Purpose

This document defines the Phase 1 runtime state transition matrix, transition authority boundary, allowed event trigger, prohibited transition, cross-runtime transition control, evidence requirement, UI impact, support recovery condition, and implementation-readiness policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined runtime state vocabulary and canonical event naming.

This document defines how those states may safely transition.

This document does not implement enums, database constraints, triggers, API routes, frontend state machines, provider adapters, or test code.

It defines runtime state transition policy only.

---

## 2. Scope

This document covers:

- runtime state transition matrix
- transition authority owner
- allowed transition triggers
- prohibited transitions
- cross-runtime transition rule
- payment transition rule
- order transition rule
- provider transition rule
- KDS transition rule
- support transition rule
- Mini Kiosk transition rule
- device trust transition rule
- audit/evidence requirement
- UI state reflection rule
- no-implementation boundary

This document does not cover:

- final SQL check constraints
- final enum implementation
- final event sourcing implementation
- final workflow engine
- final API transition endpoint
- final Flutter state machine
- final provider SDK integration
- final KDS hardware state integration
- final test runner

---

## 3. Core Principle

A runtime state may change only through an authorized transition.

The project must follow this rule:

> State transition must be event-driven, authority-owned, evidence-producing, and testable. No runtime, UI, support tool, bridge, agent, or provider adapter may silently mutate another runtime’s state.

State change is not a visual update.

State change is operational truth movement.

---

## 4. State Transition Model

Each transition should eventually define:

- source state
- target state
- triggering event
- runtime owner
- allowed actor
- validation required
- evidence event
- UI impact
- failure transition
- support recovery condition
- test requirement

A transition without owner or evidence is not implementation-ready.

---

## 5. Transition Record Format

Recommended transition record format:

    Transition ID:
    Runtime Family:
    From State:
    Trigger Event:
    To State:
    Runtime Owner:
    Allowed Actor:
    Validation Required:
    Evidence Event:
    UI Impact:
    Failure State:
    Support Recovery:
    Test Requirement:
    Notes:

This may later become a Markdown table, spreadsheet, database table, or implementation constant.

---

## 6. Transition ID Format

Recommended transition ID format:

    TRANS-[RUNTIME]-[NUMBER]

Examples:

    TRANS-PAYMENT-001
    TRANS-ORDER-001
    TRANS-KDS-001
    TRANS-PROVIDER-001
    TRANS-SUPPORT-001
    TRANS-SESSION-001
    TRANS-DEVICE-001

Alternative flow-based format:

    TRANS-PAYMENT_APPROVAL_FLOW-001

Final format may be normalized later.

---

## 7. Transition Authority Rule

Every transition must have exactly one primary runtime authority.

Examples:

| Transition Area | Primary Runtime Authority |
| --------------- | ------------------------- |
| Payment approval | Payment Runtime |
| Order acceptance | POS / Order Runtime |
| KDS ticket acceptance | KDS Runtime |
| Provider event validation | Provider Gateway Runtime |
| Support case lifecycle | Support Runtime |
| Device trust revocation | Security / Device Runtime |
| Export approval | Export Runtime |
| SaaS quote acceptance | SaaS Billing Runtime |

A runtime may observe another runtime’s state, but observation is not transition authority.

---

## 8. Cross-Runtime Transition Rule

Cross-runtime transitions must use canonical events.

Example:

    Provider Gateway validates provider event
        -> emits PAYMENT_APPROVAL_CONFIRMED candidate
        -> Payment Runtime validates authority
        -> Payment Runtime transitions PAYMENT_PENDING to PAYMENT_APPROVED

Provider Gateway must not directly mutate Payment Runtime truth.

Bridge must not directly mutate KDS execution truth.

Support must not directly mutate payment approval truth.

---

## 9. Transition Evidence Rule

Every critical transition must produce evidence.

Critical transitions include:

- payment approval
- payment uncertainty
- refund approval
- cancel completion
- order acceptance
- KDS ticket acceptance
- KDS ticket cancellation
- support break-glass
- device trust revocation
- export approval
- provider event quarantine
- pilot blocker creation

Evidence must be append-only or append-only-equivalent.

---

## 10. UI Reflection Rule

UI may reflect runtime state.

UI must not invent runtime state.

UI may:

- display current state
- request allowed action
- show pending/uncertain status
- show support handoff
- show retry option where permitted

UI must not:

- mark payment approved without Payment Runtime
- mark KDS completed without KDS authority
- mark support case resolved without evidence
- hide uncertainty
- convert warning into success state
- bypass authority by button label

---

## 11. Support Recovery Rule

Support recovery may request, review, annotate, escalate, or propose.

Support recovery must not silently complete:

- payment approval
- refund approval
- order acceptance
- KDS completion
- provider validation
- export approval

Support can only transition support-owned states unless authorized workflow delegates a specific action.

---

## 12. Agent Recommendation Rule

Agent may recommend transition candidates.

Agent must not execute transition authority.

Allowed:

    AGENT_PAYMENT_REVIEW_RECOMMENDATION_CREATED
    AGENT_KDS_DELAY_RISK_DETECTED
    AGENT_SUPPORT_ESCALATION_RECOMMENDED

Prohibited:

    AGENT_PAYMENT_APPROVED
    AGENT_REFUND_COMPLETED
    AGENT_KDS_TICKET_CANCELLED
    AGENT_EXPORT_APPROVED

Recommendation is not execution.

---

## 13. Provider Event Transition Matrix

Recommended provider event transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `PROVIDER_EVENT_RECEIVED` | `PROVIDER_SIGNATURE_CHECK_STARTED` | `PROVIDER_EVENT_SIGNATURE_PENDING` | Provider Gateway |
| `PROVIDER_EVENT_SIGNATURE_PENDING` | `PROVIDER_SIGNATURE_VALIDATED` | `PROVIDER_EVENT_SIGNATURE_VALID` | Provider Gateway |
| `PROVIDER_EVENT_SIGNATURE_PENDING` | `PROVIDER_SIGNATURE_REJECTED` | `PROVIDER_EVENT_SIGNATURE_INVALID` | Provider Gateway |
| `PROVIDER_EVENT_SIGNATURE_VALID` | `PROVIDER_EVENT_DUPLICATE_DETECTED` | `PROVIDER_EVENT_IDEMPOTENT_DUPLICATE` | Provider Gateway |
| `PROVIDER_EVENT_SIGNATURE_VALID` | `PROVIDER_EVENT_REPLAY_DETECTED` | `PROVIDER_EVENT_REPLAY_SUSPECTED` | Provider Gateway |
| `PROVIDER_EVENT_SIGNATURE_VALID` | `PROVIDER_MAPPING_STARTED` | `PROVIDER_EVENT_MAPPING_PENDING` | Provider Gateway |
| `PROVIDER_EVENT_MAPPING_PENDING` | `PROVIDER_MAPPING_COMPLETED` | `PROVIDER_EVENT_MAPPED` | Provider Gateway |
| `PROVIDER_EVENT_MAPPING_PENDING` | `PROVIDER_MAPPING_FAILED` | `PROVIDER_EVENT_QUARANTINED` | Provider Gateway |
| `PROVIDER_EVENT_MAPPED` | `PROVIDER_EVENT_CANONICALIZED` | `PROVIDER_EVENT_ACCEPTED` | Provider Gateway |
| `PROVIDER_EVENT_QUARANTINED` | `PROVIDER_EVENT_REVIEW_REJECTED` | `PROVIDER_EVENT_REJECTED` | Provider Gateway |

Provider event accepted is not final payment/order truth.

---

## 14. Payment Transition Matrix

Recommended payment transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `PAYMENT_NOT_STARTED` | `PAYMENT_FLOW_INITIATED` | `PAYMENT_INITIATED` | Payment Runtime |
| `PAYMENT_INITIATED` | `PAYMENT_PROCESSING_STARTED` | `PAYMENT_PENDING` | Payment Runtime |
| `PAYMENT_PENDING` | `PAYMENT_APPROVAL_CONFIRMED` | `PAYMENT_APPROVED` | Payment Runtime |
| `PAYMENT_PENDING` | `PAYMENT_FAILURE_CONFIRMED` | `PAYMENT_FAILED` | Payment Runtime |
| `PAYMENT_PENDING` | `PAYMENT_UNCERTAINTY_DETECTED` | `PAYMENT_UNCERTAIN` | Payment Runtime |
| `PAYMENT_PENDING` | `PAYMENT_CANCEL_CONFIRMED` | `PAYMENT_CANCELLED` | Payment Runtime |
| `PAYMENT_APPROVED` | `PAYMENT_DUPLICATE_SUSPECTED` | `PAYMENT_DUPLICATE_SUSPECTED` | Payment Runtime |
| `PAYMENT_UNCERTAIN` | `PAYMENT_RECONCILIATION_REQUIRED` | `PAYMENT_RECONCILIATION_REQUIRED` | Payment Runtime |
| `PAYMENT_UNCERTAIN` | `PAYMENT_RECOVERY_REQUIRED` | `PAYMENT_RECOVERY_REQUIRED` | Payment Runtime |
| `PAYMENT_RECONCILIATION_REQUIRED` | `PAYMENT_APPROVAL_CONFIRMED` | `PAYMENT_APPROVED` | Payment Runtime |

Payment transitions require provider validation or authorized internal confirmation.

---

## 15. Payment Prohibited Transitions

Prohibited payment transitions:

| From State | Prohibited To State | Reason |
| ---------- | ------------------- | ------ |
| `PAYMENT_NOT_STARTED` | `PAYMENT_APPROVED` | missing payment flow |
| `PAYMENT_PENDING` | `ORDER_ACCEPTED` | different runtime |
| `PAYMENT_UNCERTAIN` | `PAYMENT_APPROVED` | requires reconciliation/validation |
| `PAYMENT_FAILED` | `PAYMENT_APPROVED` | requires new valid event |
| `PAYMENT_APPROVED` | `REFUND_COMPLETED` | refund runtime transition required |
| `PAYMENT_APPROVED` | `KDS_TICKET_ACCEPTED` | KDS owns ticket acceptance |

Payment truth must remain conservative.

---

## 16. Refund Transition Matrix

Recommended refund transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `REFUND_NOT_REQUESTED` | `REFUND_REQUEST_CREATED` | `REFUND_REQUESTED` | Payment Runtime |
| `REFUND_REQUESTED` | `REFUND_REVIEW_REQUIRED_DETECTED` | `REFUND_REVIEW_REQUIRED` | Payment Runtime |
| `REFUND_REQUESTED` | `REFUND_PROCESSING_STARTED` | `REFUND_PENDING` | Payment Runtime |
| `REFUND_PENDING` | `REFUND_APPROVAL_CONFIRMED` | `REFUND_APPROVED` | Payment Runtime |
| `REFUND_APPROVED` | `REFUND_COMPLETION_CONFIRMED` | `REFUND_COMPLETED` | Payment Runtime |
| `REFUND_PENDING` | `REFUND_FAILURE_CONFIRMED` | `REFUND_FAILED` | Payment Runtime |
| `REFUND_PENDING` | `REFUND_UNCERTAINTY_DETECTED` | `REFUND_UNCERTAIN` | Payment Runtime |
| `REFUND_UNCERTAIN` | `REFUND_RECONCILIATION_REQUIRED` | `REFUND_RECONCILIATION_REQUIRED` | Payment Runtime |

Refund must not be inferred only from order cancel.

---

## 17. Cancel Transition Matrix

Recommended cancel transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `CANCEL_NOT_REQUESTED` | `CANCEL_REQUEST_CREATED` | `CANCEL_REQUESTED` | Order Runtime |
| `CANCEL_REQUESTED` | `CANCEL_REVIEW_REQUIRED_DETECTED` | `CANCEL_REVIEW_REQUIRED` | Order Runtime |
| `CANCEL_REQUESTED` | `CANCEL_ALLOWED_CONFIRMED` | `CANCEL_ALLOWED` | Order Runtime |
| `CANCEL_REQUESTED` | `CANCEL_BLOCKED_CONFIRMED` | `CANCEL_BLOCKED` | Order Runtime |
| `CANCEL_ALLOWED` | `CANCEL_COMPLETION_CONFIRMED` | `CANCEL_COMPLETED` | Order Runtime |
| `CANCEL_ALLOWED` | `CANCEL_FAILURE_CONFIRMED` | `CANCEL_FAILED` | Order Runtime |
| `CANCEL_REQUESTED` | `CANCEL_KDS_IMPACT_DETECTED` | `CANCEL_KDS_IMPACT_REVIEW_REQUIRED` | Order Runtime |
| `CANCEL_REQUESTED` | `CANCEL_PAYMENT_IMPACT_DETECTED` | `CANCEL_PAYMENT_IMPACT_REVIEW_REQUIRED` | Order Runtime |

Cancel may require Payment Runtime and KDS Runtime coordination.

---

## 18. Order Intent Transition Matrix

Recommended order transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `ORDER_INTENT_DRAFT` | `ORDER_INTENT_CAPTURED_EVENT` | `ORDER_INTENT_CAPTURED` | Order Runtime |
| `ORDER_INTENT_CAPTURED` | `ORDER_INTENT_VALIDATION_STARTED` | `ORDER_INTENT_VALIDATING` | Order Runtime |
| `ORDER_INTENT_VALIDATING` | `ORDER_INTENT_VALIDATION_PASSED` | `ORDER_INTENT_VALIDATED` | Order Runtime |
| `ORDER_INTENT_VALIDATING` | `ORDER_INTENT_VALIDATION_FAILED` | `ORDER_INTENT_REJECTED` | Order Runtime |
| `ORDER_INTENT_VALIDATED` | `ORDER_ACCEPTANCE_CONDITION_WAITING` | `ORDER_ACCEPTANCE_PENDING` | Order Runtime |
| `ORDER_ACCEPTANCE_PENDING` | `ORDER_ACCEPTANCE_CONFIRMED` | `ORDER_ACCEPTED` | Order Runtime |
| `ORDER_ACCEPTANCE_PENDING` | `ORDER_HOLD_REQUIRED` | `ORDER_HELD` | Order Runtime |
| `ORDER_ACCEPTED` | `ORDER_CANCEL_REQUEST_CREATED` | `ORDER_CANCEL_REQUESTED` | Order Runtime |
| `ORDER_CANCEL_REQUESTED` | `ORDER_CANCEL_CONFIRMED` | `ORDER_CANCELLED` | Order Runtime |
| `ORDER_HELD` | `ORDER_RECOVERY_REQUIRED_DETECTED` | `ORDER_RECOVERY_REQUIRED` | Order Runtime |

Order accepted requires valid authority and required upstream conditions.

---

## 19. Order Prohibited Transitions

Prohibited order transitions:

| From State | Prohibited To State | Reason |
| ---------- | ------------------- | ------ |
| `ORDER_INTENT_DRAFT` | `ORDER_ACCEPTED` | validation skipped |
| `ORDER_INTENT_CAPTURED` | `KDS_TICKET_ACCEPTED` | KDS runtime authority required |
| `ORDER_INTENT_VALIDATED` | `PAYMENT_APPROVED` | payment runtime authority required |
| `ORDER_ACCEPTANCE_PENDING` | `ORDER_ACCEPTED` | missing acceptance event |
| `ORDER_HELD` | `KDS_TICKET_ACCEPTED` | held order cannot enter kitchen |
| `ORDER_CANCELLED` | `KDS_TICKET_IN_PROGRESS` | cancelled order cannot start kitchen without recovery |

Order state cannot shortcut runtime validation.

---

## 20. Customer Session Transition Matrix

Recommended session transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `SESSION_CREATED` | `SESSION_ACTIVATED` | `SESSION_ACTIVE` | Session Runtime |
| `SESSION_ACTIVE` | `WAITING_CONTEXT_ATTACHED` | `SESSION_WAITING_CONTEXT_ATTACHED` | Session Runtime |
| `SESSION_ACTIVE` | `TABLE_CONTEXT_ATTACHED` | `SESSION_TABLE_CONTEXT_ATTACHED` | Session Runtime |
| `SESSION_ACTIVE` | `MINI_KIOSK_CONTEXT_ATTACHED` | `SESSION_MINI_KIOSK_ATTACHED` | Session Runtime |
| `SESSION_ACTIVE` | `SESSION_TIMEOUT_WARNING_CREATED` | `SESSION_TIMEOUT_PENDING` | Session Runtime |
| `SESSION_TIMEOUT_PENDING` | `SESSION_TIMEOUT_CONFIRMED` | `SESSION_EXPIRED` | Session Runtime |
| `SESSION_ACTIVE` | `SESSION_ABANDONED_DETECTED` | `SESSION_ABANDONED` | Session Runtime |
| `SESSION_ACTIVE` | `SESSION_RECOVERY_REQUIRED_DETECTED` | `SESSION_RECOVERY_REQUIRED` | Session Runtime |
| `SESSION_ACTIVE` | `SESSION_CLOSE_CONFIRMED` | `SESSION_CLOSED` | Session Runtime |

Session transition does not imply order acceptance or payment approval.

---

## 21. Mini Kiosk Transition Boundary

Mini Kiosk may trigger:

- session creation
- order intent capture
- payment handoff request
- timeout
- abandonment
- support handoff request

Mini Kiosk must not directly transition:

- `PAYMENT_APPROVED`
- `ORDER_ACCEPTED` without order runtime authority
- `KDS_TICKET_ACCEPTED`
- `REFUND_APPROVED`
- `SUPPORT_CASE_RESOLVED`

Mini Kiosk is an input and display surface, not final authority.

---

## 22. KDS Ticket Transition Matrix

Recommended KDS ticket transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `KDS_TICKET_NOT_CREATED` | `KDS_TICKET_CANDIDATE_CREATED` | `KDS_TICKET_CANDIDATE` | KDS Runtime |
| `KDS_TICKET_CANDIDATE` | `KDS_TICKET_HANDOFF_STARTED` | `KDS_TICKET_PENDING` | KDS Runtime |
| `KDS_TICKET_PENDING` | `KDS_TICKET_ACCEPTANCE_CONFIRMED` | `KDS_TICKET_ACCEPTED` | KDS Runtime |
| `KDS_TICKET_ACCEPTED` | `KDS_TICKET_WORK_STARTED` | `KDS_TICKET_IN_PROGRESS` | KDS Runtime |
| `KDS_TICKET_IN_PROGRESS` | `KDS_TICKET_COMPLETION_CONFIRMED` | `KDS_TICKET_COMPLETED` | KDS Runtime |
| `KDS_TICKET_PENDING` | `KDS_TICKET_HOLD_REQUIRED` | `KDS_TICKET_HELD` | KDS Runtime |
| `KDS_TICKET_ACCEPTED` | `KDS_TICKET_CANCEL_REQUEST_CREATED` | `KDS_TICKET_CANCEL_REQUESTED` | KDS Runtime |
| `KDS_TICKET_CANCEL_REQUESTED` | `KDS_TICKET_CANCEL_CONFIRMED` | `KDS_TICKET_CANCELLED` | KDS Runtime |
| `KDS_TICKET_PENDING` | `KDS_TICKET_DUPLICATE_DETECTED` | `KDS_TICKET_DUPLICATE_SUSPECTED` | KDS Runtime |
| `KDS_TICKET_DUPLICATE_SUSPECTED` | `KDS_TICKET_RECOVERY_REQUIRED_DETECTED` | `KDS_TICKET_RECOVERY_REQUIRED` | KDS Runtime |

KDS owns kitchen execution state.

---

## 23. KDS Prohibited Transitions

Prohibited KDS transitions:

| From State | Prohibited To State | Reason |
| ---------- | ------------------- | ------ |
| `KDS_TICKET_NOT_CREATED` | `KDS_TICKET_ACCEPTED` | candidate/handoff skipped |
| `KDS_TICKET_CANDIDATE` | `KDS_TICKET_IN_PROGRESS` | acceptance skipped |
| `KDS_TICKET_PENDING` | `PAYMENT_APPROVED` | payment runtime authority |
| `KDS_TICKET_ACCEPTED` | `ORDER_ACCEPTED` | order runtime authority |
| `KDS_TICKET_CANCELLED` | `KDS_TICKET_COMPLETED` | cancelled ticket cannot complete without recovery |
| `KDS_TICKET_DUPLICATE_SUSPECTED` | `KDS_TICKET_ACCEPTED` | duplicate risk unresolved |

KDS transition must not bypass order/payment readiness.

---

## 24. KDS Bridge Transition Matrix

Recommended KDS Bridge transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `KDS_BRIDGE_READY` | `KDS_BRIDGE_EVENT_RECEIVED_EVENT` | `KDS_BRIDGE_EVENT_RECEIVED` | KDS Bridge |
| `KDS_BRIDGE_EVENT_RECEIVED` | `KDS_BRIDGE_EVENT_VALIDATED_EVENT` | `KDS_BRIDGE_EVENT_VALIDATED` | KDS Bridge |
| `KDS_BRIDGE_EVENT_RECEIVED` | `KDS_BRIDGE_EVENT_REJECTED_EVENT` | `KDS_BRIDGE_EVENT_REJECTED` | KDS Bridge |
| `KDS_BRIDGE_EVENT_VALIDATED` | `KDS_BRIDGE_RETRY_REQUIRED` | `KDS_BRIDGE_RETRY_PENDING` | KDS Bridge |
| `KDS_BRIDGE_EVENT_RECEIVED` | `KDS_BRIDGE_STALE_EVENT_DETECTED_EVENT` | `KDS_BRIDGE_STALE_EVENT_DETECTED` | KDS Bridge |
| `KDS_BRIDGE_READY` | `KDS_BRIDGE_DEGRADED_MODE_ENTERED` | `KDS_BRIDGE_DEGRADED` | KDS Bridge |
| `KDS_BRIDGE_DEGRADED` | `KDS_BRIDGE_RECOVERY_REQUIRED_DETECTED` | `KDS_BRIDGE_RECOVERY_REQUIRED` | KDS Bridge |
| `KDS_BRIDGE_READY` | `KDS_BRIDGE_DISABLED_EVENT` | `KDS_BRIDGE_DISABLED` | KDS Bridge |

Bridge state is not KDS kitchen execution state.

---

## 25. Support Case Transition Matrix

Recommended support case transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `SUPPORT_CASE_NOT_OPENED` | `SUPPORT_CASE_CREATED` | `SUPPORT_CASE_OPEN` | Support Runtime |
| `SUPPORT_CASE_OPEN` | `SUPPORT_CASE_ASSIGNED_EVENT` | `SUPPORT_CASE_ASSIGNED` | Support Runtime |
| `SUPPORT_CASE_ASSIGNED` | `SUPPORT_CASE_REVIEW_STARTED` | `SUPPORT_CASE_IN_REVIEW` | Support Runtime |
| `SUPPORT_CASE_IN_REVIEW` | `SUPPORT_CASE_ESCALATED_EVENT` | `SUPPORT_CASE_ESCALATED` | Support Runtime |
| `SUPPORT_CASE_IN_REVIEW` | `SUPPORT_CASE_WAITING_EXTERNAL_EVENT` | `SUPPORT_CASE_WAITING_EXTERNAL` | Support Runtime |
| `SUPPORT_CASE_IN_REVIEW` | `SUPPORT_CASE_RESOLUTION_PROPOSED_EVENT` | `SUPPORT_CASE_RESOLUTION_PROPOSED` | Support Runtime |
| `SUPPORT_CASE_RESOLUTION_PROPOSED` | `SUPPORT_CASE_RESOLUTION_CONFIRMED` | `SUPPORT_CASE_RESOLVED` | Support Runtime |
| `SUPPORT_CASE_RESOLVED` | `SUPPORT_CASE_CLOSED_EVENT` | `SUPPORT_CASE_CLOSED` | Support Runtime |
| `SUPPORT_CASE_CLOSED` | `SUPPORT_CASE_REOPENED_EVENT` | `SUPPORT_CASE_REOPENED` | Support Runtime |

Resolved requires evidence.

Closed is not the same as ignored.

---

## 26. Support Session Transition Matrix

Recommended support session transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `SUPPORT_SESSION_NOT_STARTED` | `SUPPORT_SESSION_REQUEST_CREATED` | `SUPPORT_SESSION_REQUESTED` | Support Runtime |
| `SUPPORT_SESSION_REQUESTED` | `SUPPORT_SESSION_APPROVAL_CONFIRMED` | `SUPPORT_SESSION_APPROVED` | Support Runtime |
| `SUPPORT_SESSION_APPROVED` | `SUPPORT_SESSION_STARTED` | `SUPPORT_SESSION_ACTIVE` | Support Runtime |
| `SUPPORT_SESSION_ACTIVE` | `SUPPORT_MASKED_VIEW_ENABLED` | `SUPPORT_SESSION_MASKED_VIEW` | Support Runtime |
| `SUPPORT_SESSION_ACTIVE` | `SUPPORT_BREAK_GLASS_REQUEST_CREATED` | `SUPPORT_SESSION_BREAK_GLASS_REQUESTED` | Support Runtime |
| `SUPPORT_SESSION_BREAK_GLASS_REQUESTED` | `SUPPORT_BREAK_GLASS_APPROVED_EVENT` | `SUPPORT_SESSION_BREAK_GLASS_APPROVED` | Support Runtime |
| `SUPPORT_SESSION_ACTIVE` | `SUPPORT_SESSION_EXPIRATION_CONFIRMED` | `SUPPORT_SESSION_EXPIRED` | Support Runtime |
| `SUPPORT_SESSION_ACTIVE` | `SUPPORT_SESSION_ENDED_EVENT` | `SUPPORT_SESSION_ENDED` | Support Runtime |

Support session must be case-scoped, time-bound, and audited.

---

## 27. Device Trust Transition Matrix

Recommended device trust transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `DEVICE_UNREGISTERED` | `DEVICE_REGISTRATION_CREATED` | `DEVICE_REGISTERED` | Security Runtime |
| `DEVICE_REGISTERED` | `DEVICE_TRUST_REVIEW_STARTED` | `DEVICE_TRUST_PENDING` | Security Runtime |
| `DEVICE_TRUST_PENDING` | `DEVICE_TRUST_CONFIRMED` | `DEVICE_TRUSTED` | Security Runtime |
| `DEVICE_TRUST_PENDING` | `DEVICE_TRUST_REJECTED` | `DEVICE_UNTRUSTED` | Security Runtime |
| `DEVICE_TRUSTED` | `DEVICE_SUSPENSION_CREATED` | `DEVICE_SUSPENDED` | Security Runtime |
| `DEVICE_TRUSTED` | `DEVICE_TRUST_REVOKED_EVENT` | `DEVICE_REVOKED` | Security Runtime |
| `DEVICE_TRUSTED` | `DEVICE_LOST_REPORTED_EVENT` | `DEVICE_LOST_REPORTED` | Security Runtime |
| `DEVICE_LOST_REPORTED` | `DEVICE_RECOVERY_REQUIRED_DETECTED` | `DEVICE_RECOVERY_REQUIRED` | Security Runtime |

Device trust is separate from user role.

---

## 28. Export Transition Matrix

Recommended export transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `EXPORT_NOT_REQUESTED` | `EXPORT_REQUEST_CREATED` | `EXPORT_REQUESTED` | Export Runtime |
| `EXPORT_REQUESTED` | `EXPORT_REVIEW_REQUIRED_DETECTED` | `EXPORT_REVIEW_REQUIRED` | Export Runtime |
| `EXPORT_REVIEW_REQUIRED` | `EXPORT_APPROVAL_CONFIRMED` | `EXPORT_APPROVED` | Export Runtime |
| `EXPORT_REVIEW_REQUIRED` | `EXPORT_REJECTION_CONFIRMED` | `EXPORT_REJECTED` | Export Runtime |
| `EXPORT_APPROVED` | `EXPORT_GENERATION_STARTED` | `EXPORT_GENERATING` | Export Runtime |
| `EXPORT_GENERATING` | `EXPORT_COMPLETION_CONFIRMED` | `EXPORT_COMPLETED` | Export Runtime |
| `EXPORT_GENERATING` | `EXPORT_FAILURE_CONFIRMED` | `EXPORT_FAILED` | Export Runtime |
| `EXPORT_REQUESTED` | `EXPORT_REDACTION_REQUIRED_DETECTED` | `EXPORT_REDACTION_REQUIRED` | Export Runtime |
| `EXPORT_REQUESTED` | `EXPORT_AUDIT_REQUIRED_DETECTED` | `EXPORT_AUDIT_REQUIRED` | Export Runtime |

View authority is not export authority.

---

## 29. SaaS Billing Transition Matrix

Recommended SaaS billing transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `BILLING_NOT_STARTED` | `BILLING_QUOTE_DRAFT_CREATED` | `BILLING_QUOTE_DRAFT` | SaaS Billing Runtime |
| `BILLING_QUOTE_DRAFT` | `BILLING_QUOTE_SENT_EVENT` | `BILLING_QUOTE_SENT` | SaaS Billing Runtime |
| `BILLING_QUOTE_SENT` | `BILLING_QUOTE_ACCEPTANCE_CONFIRMED` | `BILLING_QUOTE_ACCEPTED` | SaaS Billing Runtime |
| `BILLING_QUOTE_ACCEPTED` | `BILLING_PILOT_STARTED` | `BILLING_PILOT_ACTIVE` | SaaS Billing Runtime |
| `BILLING_PILOT_ACTIVE` | `BILLING_SUBSCRIPTION_STARTED` | `BILLING_SUBSCRIPTION_ACTIVE` | SaaS Billing Runtime |
| `BILLING_SUBSCRIPTION_ACTIVE` | `BILLING_CHANGE_REQUEST_CREATED` | `BILLING_CHANGE_REQUESTED` | SaaS Billing Runtime |
| `BILLING_SUBSCRIPTION_ACTIVE` | `BILLING_DOWNGRADE_REQUEST_CREATED` | `BILLING_DOWNGRADE_PENDING` | SaaS Billing Runtime |
| `BILLING_SUBSCRIPTION_ACTIVE` | `BILLING_CANCEL_REQUEST_CREATED` | `BILLING_CANCEL_REQUESTED` | SaaS Billing Runtime |
| `BILLING_CANCEL_REQUESTED` | `BILLING_END_CONFIRMED` | `BILLING_ENDED` | SaaS Billing Runtime |

Billing state must not silently mutate operational runtime.

---

## 30. Pilot Evidence Transition Matrix

Recommended pilot transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `PILOT_NOT_STARTED` | `PILOT_SCOPE_DEFINED_EVENT` | `PILOT_SCOPE_DEFINED` | Pilot Evidence Runtime |
| `PILOT_SCOPE_DEFINED` | `PILOT_STARTED` | `PILOT_ACTIVE` | Pilot Evidence Runtime |
| `PILOT_ACTIVE` | `PILOT_EVIDENCE_COLLECTION_STARTED` | `PILOT_EVIDENCE_COLLECTING` | Pilot Evidence Runtime |
| `PILOT_EVIDENCE_COLLECTING` | `PILOT_INCIDENT_REVIEW_REQUIRED_DETECTED` | `PILOT_INCIDENT_REVIEW_REQUIRED` | Pilot Evidence Runtime |
| `PILOT_EVIDENCE_COLLECTING` | `PILOT_BLOCKER_FOUND_EVENT` | `PILOT_BLOCKER_FOUND` | Pilot Evidence Runtime |
| `PILOT_EVIDENCE_COLLECTING` | `PILOT_CONVERSION_REVIEW_READY` | `PILOT_READY_FOR_CONVERSION_REVIEW` | Pilot Evidence Runtime |
| `PILOT_READY_FOR_CONVERSION_REVIEW` | `PILOT_PAID_CONVERSION_CONFIRMED` | `PILOT_CONVERTED_TO_PAID` | Pilot Evidence Runtime |
| `PILOT_ACTIVE` | `PILOT_EXIT_CONFIRMED` | `PILOT_EXITED` | Pilot Evidence Runtime |
| `PILOT_EXITED` | `PILOT_ARCHIVE_CONFIRMED` | `PILOT_ARCHIVED` | Pilot Evidence Runtime |

Pilot state must be evidence-based.

---

## 31. Security Incident Transition Matrix

Recommended security incident transitions:

| From State | Event | To State | Owner |
| ---------- | ----- | -------- | ----- |
| `SECURITY_INCIDENT_NOT_OPENED` | `SECURITY_INCIDENT_DETECTED_EVENT` | `SECURITY_INCIDENT_DETECTED` | Security Runtime |
| `SECURITY_INCIDENT_DETECTED` | `SECURITY_TRIAGE_REQUIRED_DETECTED` | `SECURITY_INCIDENT_TRIAGE_REQUIRED` | Security Runtime |
| `SECURITY_INCIDENT_TRIAGE_REQUIRED` | `SECURITY_CONTAINMENT_REQUIRED_DETECTED` | `SECURITY_INCIDENT_CONTAINMENT_REQUIRED` | Security Runtime |
| `SECURITY_INCIDENT_CONTAINMENT_REQUIRED` | `SECURITY_CONTAINMENT_CONFIRMED` | `SECURITY_INCIDENT_CONTAINED` | Security Runtime |
| `SECURITY_INCIDENT_CONTAINED` | `SECURITY_RECOVERY_REQUIRED_DETECTED` | `SECURITY_INCIDENT_RECOVERY_REQUIRED` | Security Runtime |
| `SECURITY_INCIDENT_RECOVERY_REQUIRED` | `SECURITY_INCIDENT_RESOLUTION_CONFIRMED` | `SECURITY_INCIDENT_RESOLVED` | Security Runtime |
| `SECURITY_INCIDENT_RESOLVED` | `SECURITY_POSTMORTEM_REQUIRED_DETECTED` | `SECURITY_INCIDENT_POSTMORTEM_REQUIRED` | Security Runtime |
| `SECURITY_INCIDENT_POSTMORTEM_REQUIRED` | `SECURITY_INCIDENT_CLOSED_EVENT` | `SECURITY_INCIDENT_CLOSED` | Security Runtime |

Security incident closure requires postmortem or documented waiver.

---

## 32. Failure Transition Rule

Every critical transition should have a failure path.

Examples:

| Attempt | Failure State |
| ------- | ------------- |
| payment approval validation | `PAYMENT_UNCERTAIN` |
| provider mapping | `PROVIDER_EVENT_QUARANTINED` |
| KDS handoff | `KDS_TICKET_RECOVERY_REQUIRED` |
| support session approval | `SUPPORT_CASE_ESCALATED` |
| export generation | `EXPORT_FAILED` |
| billing change | `BILLING_CHANGE_REQUESTED` or review state |
| device trust review | `DEVICE_UNTRUSTED` or `DEVICE_RECOVERY_REQUIRED` |

Failure must not disappear.

---

## 33. Idempotent Transition Rule

Repeated events must not create duplicate state effects.

Examples:

- duplicate provider webhook must not create duplicate payment approval
- duplicate order intent must not create duplicate accepted order
- duplicate KDS handoff must not create duplicate kitchen ticket
- duplicate refund callback must not create duplicate refund
- duplicate support session request must not create uncontrolled access

Idempotency is mandatory for provider and payment flows.

---

## 34. Replay-Sensitive Transition Rule

Replay-sensitive transitions require replay protection.

Replay-sensitive transitions include:

- payment approval
- refund confirmation
- provider event acceptance
- KDS ticket handoff
- support break-glass approval
- export approval
- device trust revocation

Replay protection must be tested before pilot.

---

## 35. Transition Lock Rule

Some transitions may require lock or guard.

Examples:

- payment approval confirmation
- order acceptance
- KDS ticket creation
- refund completion
- support break-glass approval
- device revocation
- export generation

Locking strategy is implementation detail.

This policy only requires that duplicate/conflicting transition is prevented.

---

## 36. Manual Override Transition Rule

Manual override transition must be:

- role-scoped
- reason-required
- evidence-producing
- auditable
- reversible only through append-only correction
- prohibited from silent overwrite
- tied to support case or incident where appropriate

Manual override must not become normal path.

---

## 37. Degraded Mode Transition Rule

Degraded mode transitions are provisional.

Rules:

- degraded state must be marked
- local-originated event must be marked
- central verification is required
- silent merge is prohibited
- overwrite is prohibited
- conflict must produce evidence
- recovery path must be explicit

Degraded mode is not security bypass.

---

## 38. Transition Test Requirement

Each critical transition should map to test.

Examples:

| Transition | Test |
| ---------- | ---- |
| `PAYMENT_PENDING` to `PAYMENT_APPROVED` | payment approval validation test |
| `PROVIDER_EVENT_SIGNATURE_PENDING` to invalid | webhook signature rejection test |
| `KDS_TICKET_PENDING` to accepted | KDS handoff test |
| duplicate KDS candidate | duplicate ticket prevention test |
| support break-glass approval | scoped session audit test |
| export approval | export authorization test |
| device revocation | revoked device access test |

A transition without test is not implementation-ready.

---

## 39. Transition Register Recommendation

A future transition register should include:

- transition id
- runtime family
- from state
- event
- to state
- owner
- actor
- validation
- evidence
- test
- UI impact
- failure path
- status

Recommended file:

    docs/_index/Runtime_State_Transition_Register.md

This document only recommends the register.

---

## 40. Transition Status Values

Recommended transition status values:

- `PROPOSED`
- `REVIEW_REQUIRED`
- `APPROVED_FOR_PHASE_1`
- `APPROVED_FOR_PHASE_2`
- `DEFERRED`
- `REJECTED`
- `IMPLEMENTATION_PENDING`
- `IMPLEMENTED`
- `TESTED`
- `SUPERSEDED`

Most transitions remain proposed until implementation review.

---

## 41. Anti-Patterns

The following are prohibited:

- changing state without event
- changing state without runtime owner
- changing state without evidence
- UI directly mutating runtime truth
- provider event directly mutating payment truth
- support silently approving payment/refund/KDS
- agent executing state transition
- bridge owning kitchen execution state
- payment uncertainty transitioning to approved without validation
- KDS ticket created before order/payment readiness
- duplicate webhook creating duplicate effect
- replay event creating state change
- degraded mode silently merging into verified state
- manual override without reason/evidence

---

## 42. Non-Goals

This document does not define:

- final state machine implementation
- final database constraint design
- final SQL trigger design
- final event bus
- final API transaction handling
- final frontend state management
- final provider adapter code
- final test automation

Those belong to later authorized implementation planning.

---

## 43. Readiness Check

This document is ready when the project can answer:

1. What is the core state transition principle?
2. What fields should a transition record include?
3. What transition ID format is recommended?
4. What is transition authority rule?
5. What is cross-runtime transition rule?
6. What evidence rule applies?
7. What UI reflection rule applies?
8. What support recovery rule applies?
9. What agent recommendation rule applies?
10. What provider event transitions exist?
11. What payment transitions exist?
12. What payment transitions are prohibited?
13. What refund transitions exist?
14. What cancel transitions exist?
15. What order transitions exist?
16. What order transitions are prohibited?
17. What customer session transitions exist?
18. What Mini Kiosk transition boundary applies?
19. What KDS ticket transitions exist?
20. What KDS transitions are prohibited?
21. What KDS Bridge transitions exist?
22. What support case transitions exist?
23. What support session transitions exist?
24. What device trust transitions exist?
25. What export transitions exist?
26. What SaaS billing transitions exist?
27. What pilot transitions exist?
28. What security incident transitions exist?
29. What failure transition rule applies?
30. What idempotent transition rule applies?
31. What replay-sensitive transition rule applies?
32. What manual override rule applies?
33. What degraded mode rule applies?
34. What transition test requirement applies?
35. What anti-patterns are prohibited?

If these questions cannot be answered, Phase 1 runtime transition planning is incomplete.

---

## 44. Conclusion

Runtime states are safe only when transitions are controlled.

The safe model is:

    State
        -> authorized canonical event
        -> validation
        -> runtime owner approval
        -> state transition
        -> audit evidence
        -> UI reflection
        -> test verification

No provider, bridge, agent, support tool, Mini Kiosk, or UI should silently mutate runtime truth outside its authority.

This document prepares Phase 1 implementation for safe state transitions, payment certainty, KDS handoff safety, provider validation, support recovery, evidence collection, and pilot readiness.