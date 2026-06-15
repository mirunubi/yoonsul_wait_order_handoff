# 14056_Policy_Phase_1_MVP_Runtime_State_Vocabulary

## 1. Purpose

This document defines the Phase 1 MVP runtime state vocabulary, canonical event naming, state transition naming, evidence event naming, UI state label boundary, provider event naming boundary, and implementation terminology control policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined Phase 1 implementation sequence and build order.

This document defines the shared vocabulary required before implementation begins.

This document does not implement enums, database tables, event schemas, API contracts, UI labels, or test cases.

It defines runtime naming policy only.

---

## 2. Scope

This document covers:

- runtime state vocabulary
- canonical event naming
- state transition naming
- provider event naming
- payment event naming
- order intent event naming
- KDS ticket event naming
- support recovery event naming
- audit evidence event naming
- UI state display naming
- naming stability rule
- no-implementation boundary

This document does not cover:

- final enum implementation
- final SQL schema
- final event table design
- final API response format
- final Flutter state model
- final provider adapter code
- final test implementation
- final production logging format

---

## 3. Core Principle

A system cannot be implemented safely if its runtime states are ambiguous.

The project must follow this rule:

> Runtime states and canonical events must be named before implementation, and UI, tests, audit, provider adapters, support recovery, KDS handoff, and payment logic must use the same vocabulary.

Different names for the same state create hidden bugs.

The same name for different meanings creates dangerous bugs.

---

## 4. Why Runtime Vocabulary Matters

Runtime vocabulary affects:

- database state fields
- API payloads
- UI labels
- audit events
- support console
- payment recovery
- KDS ticket generation
- provider event handling
- test cases
- pilot evidence packets
- rollback decisions
- implementation backlog items

If vocabulary is unstable, implementation becomes unstable.

---

## 5. Naming Layers

The project should distinguish these naming layers:

| Layer | Meaning |
| ----- | ------- |
| Runtime State | current system state |
| Canonical Event | normalized event emitted by Yoonsul runtime |
| Provider Event | raw or provider-specific signal |
| UI Label | human-facing display text |
| Audit Event | append-only evidence event |
| Test Case Name | verification name |
| Backlog Item Name | implementation work name |
| Document Title | policy or specification name |

These layers may be related, but they are not identical.

---

## 6. State Versus Event Rule

A state describes current condition.

An event describes something that happened.

Examples:

| Type | Example |
| ---- | ------- |
| State | `PAYMENT_APPROVED` |
| Event | `PAYMENT_APPROVAL_CONFIRMED` |
| State | `KDS_TICKET_PENDING` |
| Event | `KDS_TICKET_CANDIDATE_CREATED` |
| State | `SUPPORT_CASE_OPEN` |
| Event | `SUPPORT_CASE_CREATED` |

Do not name states as if they are events.

Do not name events as if they are states.

---

## 7. Canonical Naming Style

Recommended internal naming style:

- uppercase
- underscore-separated
- English
- stable
- descriptive
- no provider brand unless provider-specific
- no UI tone wording
- no ambiguous abbreviations
- no Korean in core runtime names
- no spaces

Examples:

    PAYMENT_UNCERTAIN
    ORDER_INTENT_CAPTURED
    KDS_TICKET_CANDIDATE_CREATED
    PROVIDER_EVENT_QUARANTINED
    SUPPORT_SESSION_STARTED

---

## 8. Runtime State Family Prefixes

Recommended prefixes:

| Prefix | Family |
| ------ | ------ |
| `SESSION_` | customer or device session |
| `ORDER_` | order intent or order handoff |
| `PAYMENT_` | payment status |
| `REFUND_` | refund state |
| `CANCEL_` | cancel state |
| `PROVIDER_` | provider event state |
| `KDS_` | kitchen display / kitchen ticket |
| `SUPPORT_` | support case or support session |
| `AUDIT_` | audit and evidence |
| `DEVICE_` | device trust and session |
| `EXPORT_` | export/report |
| `BILLING_` | SaaS billing lifecycle |
| `PILOT_` | pilot evidence status |
| `SECURITY_` | security incident or control state |

Prefixes reduce ambiguity.

---

## 9. Customer Session State Vocabulary

Recommended customer session states:

| State | Meaning |
| ----- | ------- |
| `SESSION_CREATED` | session exists |
| `SESSION_ACTIVE` | session is usable |
| `SESSION_WAITING_CONTEXT_ATTACHED` | waiting context is linked |
| `SESSION_TABLE_CONTEXT_ATTACHED` | table context is linked |
| `SESSION_MINI_KIOSK_ATTACHED` | Mini Kiosk context is linked |
| `SESSION_TIMEOUT_PENDING` | timeout warning state |
| `SESSION_EXPIRED` | session expired |
| `SESSION_ABANDONED` | user abandoned flow |
| `SESSION_RECOVERY_REQUIRED` | support or recovery required |
| `SESSION_CLOSED` | session closed normally |

Customer session state must not imply payment approval.

---

## 10. Order Intent State Vocabulary

Recommended order intent states:

| State | Meaning |
| ----- | ------- |
| `ORDER_INTENT_DRAFT` | customer is composing order |
| `ORDER_INTENT_CAPTURED` | order intent captured |
| `ORDER_INTENT_VALIDATING` | validation in progress |
| `ORDER_INTENT_VALIDATED` | order intent passed validation |
| `ORDER_INTENT_REJECTED` | intent rejected before acceptance |
| `ORDER_ACCEPTANCE_PENDING` | waiting for acceptance condition |
| `ORDER_ACCEPTED` | accepted by authorized runtime |
| `ORDER_HELD` | intentionally held |
| `ORDER_CANCEL_REQUESTED` | cancel requested |
| `ORDER_CANCELLED` | order cancelled |
| `ORDER_RECOVERY_REQUIRED` | manual/support recovery needed |

Order intent is not accepted order.

Order accepted state must require authority.

---

## 11. Payment State Vocabulary

Recommended payment states:

| State | Meaning |
| ----- | ------- |
| `PAYMENT_NOT_STARTED` | no payment attempt |
| `PAYMENT_INITIATED` | payment flow started |
| `PAYMENT_PENDING` | payment in progress |
| `PAYMENT_APPROVED` | payment approved by valid authority |
| `PAYMENT_FAILED` | payment failed |
| `PAYMENT_CANCELLED` | payment cancelled before approval |
| `PAYMENT_UNCERTAIN` | payment state cannot be trusted yet |
| `PAYMENT_DUPLICATE_SUSPECTED` | possible duplicate payment |
| `PAYMENT_RECONCILIATION_REQUIRED` | reconciliation needed |
| `PAYMENT_RECOVERY_REQUIRED` | support/recovery needed |

Payment state must be conservative.

Uncertainty must be visible.

---

## 12. Refund State Vocabulary

Recommended refund states:

| State | Meaning |
| ----- | ------- |
| `REFUND_NOT_REQUESTED` | no refund request |
| `REFUND_REQUESTED` | refund requested |
| `REFUND_REVIEW_REQUIRED` | review required |
| `REFUND_PENDING` | refund processing |
| `REFUND_APPROVED` | refund approved by authorized boundary |
| `REFUND_REJECTED` | refund rejected |
| `REFUND_COMPLETED` | refund completed |
| `REFUND_FAILED` | refund failed |
| `REFUND_UNCERTAIN` | refund state uncertain |
| `REFUND_RECONCILIATION_REQUIRED` | reconciliation required |

Refund must not be silently inferred from order cancel.

---

## 13. Cancel State Vocabulary

Recommended cancel states:

| State | Meaning |
| ----- | ------- |
| `CANCEL_NOT_REQUESTED` | no cancel request |
| `CANCEL_REQUESTED` | cancel requested |
| `CANCEL_REVIEW_REQUIRED` | review required |
| `CANCEL_ALLOWED` | cancel permitted |
| `CANCEL_BLOCKED` | cancel blocked |
| `CANCEL_COMPLETED` | cancel completed |
| `CANCEL_FAILED` | cancel failed |
| `CANCEL_KDS_IMPACT_REVIEW_REQUIRED` | kitchen impact requires review |
| `CANCEL_PAYMENT_IMPACT_REVIEW_REQUIRED` | payment impact requires review |

Cancel and refund must remain separate concepts.

---

## 14. Provider Event State Vocabulary

Recommended provider event states:

| State | Meaning |
| ----- | ------- |
| `PROVIDER_EVENT_RECEIVED` | external event received |
| `PROVIDER_EVENT_SIGNATURE_PENDING` | signature not yet verified |
| `PROVIDER_EVENT_SIGNATURE_VALID` | signature verified |
| `PROVIDER_EVENT_SIGNATURE_INVALID` | signature invalid |
| `PROVIDER_EVENT_IDEMPOTENT_DUPLICATE` | duplicate event detected |
| `PROVIDER_EVENT_REPLAY_SUSPECTED` | replay suspected |
| `PROVIDER_EVENT_MAPPING_PENDING` | mapping to tenant/store pending |
| `PROVIDER_EVENT_MAPPED` | tenant/store mapping complete |
| `PROVIDER_EVENT_QUARANTINED` | held for review |
| `PROVIDER_EVENT_ACCEPTED` | accepted as canonical candidate |
| `PROVIDER_EVENT_REJECTED` | rejected |
| `PROVIDER_EVENT_RECOVERY_REQUIRED` | recovery required |

Provider event accepted does not mean payment approved.

---

## 15. Local Daemon State Vocabulary

Recommended local daemon states:

| State | Meaning |
| ----- | ------- |
| `LOCAL_DAEMON_NOT_USED` | no local daemon path |
| `LOCAL_DAEMON_CONNECTED` | daemon connection active |
| `LOCAL_DAEMON_DISCONNECTED` | daemon unavailable |
| `LOCAL_DAEMON_TIMEOUT` | daemon timed out |
| `LOCAL_DAEMON_STALE` | stale daemon data |
| `LOCAL_DAEMON_EVENT_PENDING` | event pending validation |
| `LOCAL_DAEMON_EVENT_VALIDATED` | event validated |
| `LOCAL_DAEMON_EVENT_QUARANTINED` | event held for review |
| `LOCAL_DAEMON_RECOVERY_REQUIRED` | recovery required |

Local daemon signal is never central truth by itself.

---

## 16. KDS Ticket State Vocabulary

Recommended KDS ticket states:

| State | Meaning |
| ----- | ------- |
| `KDS_TICKET_NOT_CREATED` | no KDS ticket exists |
| `KDS_TICKET_CANDIDATE` | candidate exists but not accepted |
| `KDS_TICKET_PENDING` | pending handoff |
| `KDS_TICKET_ACCEPTED` | accepted by KDS boundary |
| `KDS_TICKET_IN_PROGRESS` | kitchen work started |
| `KDS_TICKET_HELD` | ticket intentionally held |
| `KDS_TICKET_COMPLETED` | kitchen completed |
| `KDS_TICKET_CANCEL_REQUESTED` | cancel requested |
| `KDS_TICKET_CANCELLED` | ticket cancelled |
| `KDS_TICKET_DUPLICATE_SUSPECTED` | possible duplicate |
| `KDS_TICKET_RECOVERY_REQUIRED` | recovery required |

KDS ticket state must not be confused with POS order state.

---

## 17. KDS Bridge State Vocabulary

Recommended KDS Bridge states:

| State | Meaning |
| ----- | ------- |
| `KDS_BRIDGE_READY` | bridge ready |
| `KDS_BRIDGE_DISABLED` | bridge disabled |
| `KDS_BRIDGE_EVENT_RECEIVED` | handoff event received |
| `KDS_BRIDGE_EVENT_VALIDATED` | handoff event validated |
| `KDS_BRIDGE_EVENT_REJECTED` | event rejected |
| `KDS_BRIDGE_RETRY_PENDING` | retry pending |
| `KDS_BRIDGE_STALE_EVENT_DETECTED` | stale event found |
| `KDS_BRIDGE_DEGRADED` | degraded routing active |
| `KDS_BRIDGE_RECOVERY_REQUIRED` | recovery required |

Bridge validates and routes.

Bridge does not own kitchen execution truth.

---

## 18. Support Case State Vocabulary

Recommended support case states:

| State | Meaning |
| ----- | ------- |
| `SUPPORT_CASE_NOT_OPENED` | no case |
| `SUPPORT_CASE_OPEN` | case open |
| `SUPPORT_CASE_ASSIGNED` | assigned to support |
| `SUPPORT_CASE_IN_REVIEW` | being reviewed |
| `SUPPORT_CASE_ESCALATED` | escalated |
| `SUPPORT_CASE_WAITING_EXTERNAL` | waiting provider/store/customer |
| `SUPPORT_CASE_RESOLUTION_PROPOSED` | resolution proposed |
| `SUPPORT_CASE_RESOLVED` | resolved |
| `SUPPORT_CASE_CLOSED` | closed |
| `SUPPORT_CASE_REOPENED` | reopened |

Dismissed is not resolved.

Resolved requires evidence.

---

## 19. Support Session State Vocabulary

Recommended support session states:

| State | Meaning |
| ----- | ------- |
| `SUPPORT_SESSION_NOT_STARTED` | no support session |
| `SUPPORT_SESSION_REQUESTED` | support session requested |
| `SUPPORT_SESSION_APPROVED` | support session approved |
| `SUPPORT_SESSION_ACTIVE` | support session active |
| `SUPPORT_SESSION_MASKED_VIEW` | masked view active |
| `SUPPORT_SESSION_BREAK_GLASS_REQUESTED` | break-glass requested |
| `SUPPORT_SESSION_BREAK_GLASS_APPROVED` | break-glass approved |
| `SUPPORT_SESSION_EXPIRED` | support session expired |
| `SUPPORT_SESSION_ENDED` | support session ended |

Support session must be time-bound and case-scoped.

---

## 20. Device Trust State Vocabulary

Recommended device trust states:

| State | Meaning |
| ----- | ------- |
| `DEVICE_UNREGISTERED` | device not registered |
| `DEVICE_REGISTERED` | registered device |
| `DEVICE_TRUST_PENDING` | trust verification pending |
| `DEVICE_TRUSTED` | trusted device |
| `DEVICE_UNTRUSTED` | untrusted device |
| `DEVICE_SUSPENDED` | device suspended |
| `DEVICE_REVOKED` | device revoked |
| `DEVICE_LOST_REPORTED` | loss reported |
| `DEVICE_RECOVERY_REQUIRED` | recovery required |

User authority and device trust are separate.

---

## 21. Export State Vocabulary

Recommended export states:

| State | Meaning |
| ----- | ------- |
| `EXPORT_NOT_REQUESTED` | no export request |
| `EXPORT_REQUESTED` | export requested |
| `EXPORT_REVIEW_REQUIRED` | review required |
| `EXPORT_APPROVED` | approved |
| `EXPORT_REJECTED` | rejected |
| `EXPORT_GENERATING` | export generation in progress |
| `EXPORT_COMPLETED` | export completed |
| `EXPORT_FAILED` | export failed |
| `EXPORT_REDACTION_REQUIRED` | redaction needed |
| `EXPORT_AUDIT_REQUIRED` | audit required |

View authority is not export authority.

---

## 22. SaaS Billing State Vocabulary

Recommended SaaS billing states:

| State | Meaning |
| ----- | ------- |
| `BILLING_NOT_STARTED` | no billing lifecycle |
| `BILLING_QUOTE_DRAFT` | quote draft |
| `BILLING_QUOTE_SENT` | quote sent |
| `BILLING_QUOTE_ACCEPTED` | quote accepted |
| `BILLING_PILOT_ACTIVE` | paid or free pilot active |
| `BILLING_SUBSCRIPTION_ACTIVE` | subscription active |
| `BILLING_CHANGE_REQUESTED` | change requested |
| `BILLING_DOWNGRADE_PENDING` | downgrade pending |
| `BILLING_CANCEL_REQUESTED` | cancel requested |
| `BILLING_ENDED` | lifecycle ended |

Billing state must not mutate operational runtime truth.

---

## 23. Pilot Evidence State Vocabulary

Recommended pilot evidence states:

| State | Meaning |
| ----- | ------- |
| `PILOT_NOT_STARTED` | pilot not started |
| `PILOT_SCOPE_DEFINED` | scope defined |
| `PILOT_ACTIVE` | pilot active |
| `PILOT_EVIDENCE_COLLECTING` | evidence being collected |
| `PILOT_INCIDENT_REVIEW_REQUIRED` | incident review needed |
| `PILOT_BLOCKER_FOUND` | blocker found |
| `PILOT_READY_FOR_CONVERSION_REVIEW` | conversion review possible |
| `PILOT_CONVERTED_TO_PAID` | converted to paid customer |
| `PILOT_EXITED` | pilot exited |
| `PILOT_ARCHIVED` | pilot archived |

Pilot evidence must not be confused with sales optimism.

---

## 24. Security Incident State Vocabulary

Recommended security incident states:

| State | Meaning |
| ----- | ------- |
| `SECURITY_INCIDENT_NOT_OPENED` | no incident |
| `SECURITY_INCIDENT_DETECTED` | incident detected |
| `SECURITY_INCIDENT_TRIAGE_REQUIRED` | triage required |
| `SECURITY_INCIDENT_CONTAINMENT_REQUIRED` | containment required |
| `SECURITY_INCIDENT_CONTAINED` | contained |
| `SECURITY_INCIDENT_RECOVERY_REQUIRED` | recovery required |
| `SECURITY_INCIDENT_RESOLVED` | resolved |
| `SECURITY_INCIDENT_POSTMORTEM_REQUIRED` | postmortem required |
| `SECURITY_INCIDENT_CLOSED` | closed |

Security incident handling must produce evidence.

---

## 25. Canonical Event Naming Rule

Canonical event names should use:

    [DOMAIN]_[ACTION]_[RESULT_OR_STAGE]

Examples:

    PAYMENT_APPROVAL_CONFIRMED
    PAYMENT_UNCERTAINTY_DETECTED
    ORDER_INTENT_CAPTURED
    KDS_TICKET_CANDIDATE_CREATED
    SUPPORT_CASE_CREATED
    PROVIDER_EVENT_QUARANTINED
    DEVICE_TRUST_REVOKED
    EXPORT_REQUEST_APPROVED

Event names should describe what happened.

---

## 26. Canonical Event Action Words

Recommended action words:

- `CREATED`
- `REQUESTED`
- `RECEIVED`
- `VALIDATED`
- `REJECTED`
- `APPROVED`
- `BLOCKED`
- `CONFIRMED`
- `DETECTED`
- `QUARANTINED`
- `RETRIED`
- `FAILED`
- `COMPLETED`
- `CANCELLED`
- `ESCALATED`
- `RESOLVED`
- `CLOSED`
- `REOPENED`
- `REVOKED`
- `EXPIRED`

Avoid vague action words like:

- `DONE`
- `OK`
- `FIXED`
- `UPDATED`
- `PROCESSED`
- `HANDLED`

unless context is precise.

---

## 27. Provider Event Naming Boundary

Raw provider event names should be stored separately from canonical event names.

Example:

    Provider raw event:
      toss.payment.approved

    Yoonsul canonical event:
      PAYMENT_APPROVAL_CONFIRMED

Rules:

- do not expose raw provider names as internal truth
- do not rename provider raw data destructively
- preserve raw event for evidence
- map to canonical event only after validation
- quarantine unmapped provider events

Provider event mapping must be auditable.

---

## 28. UI Label Boundary

UI labels may be friendlier than internal runtime names.

Example:

| Runtime State | UI Label |
| ------------- | -------- |
| `PAYMENT_UNCERTAIN` | Payment needs confirmation |
| `KDS_TICKET_PENDING` | Waiting for kitchen handoff |
| `PROVIDER_EVENT_QUARANTINED` | Provider event under review |
| `SUPPORT_CASE_IN_REVIEW` | Support is reviewing this case |

UI labels must not hide uncertainty.

UI labels must not imply completion when state is only pending.

---

## 29. Korean UI Label Boundary

Korean UI labels may be used for customer/store interfaces.

Example:

| Runtime State | Korean UI Label |
| ------------- | --------------- |
| `PAYMENT_PENDING` | 결제 확인 중 |
| `PAYMENT_UNCERTAIN` | 결제 확인이 필요합니다 |
| `KDS_TICKET_PENDING` | 주방 전달 대기 중 |
| `SUPPORT_CASE_IN_REVIEW` | 지원팀 확인 중 |
| `PROVIDER_EVENT_QUARANTINED` | 외부 연동 확인 중 |

Korean UI labels should be separate from internal runtime names.

---

## 30. Audit Event Naming Boundary

Audit event names should be stable and evidence-oriented.

Examples:

    AUDIT_PAYMENT_STATE_CHANGED
    AUDIT_PROVIDER_EVENT_RECEIVED
    AUDIT_SUPPORT_SESSION_STARTED
    AUDIT_EXPORT_REQUESTED
    AUDIT_DEVICE_TRUST_REVOKED
    AUDIT_KDS_TICKET_CREATED

Audit event name should not depend on UI text.

---

## 31. Test Naming Boundary

Test names should reference risk and expected behavior.

Examples:

    TEST_PAYMENT_REPLAY_REJECTED
    TEST_KDS_DUPLICATE_TICKET_BLOCKED
    TEST_SUPPORT_MASKED_VIEW_ENFORCED
    TEST_PROVIDER_SIGNATURE_INVALID_REJECTED
    TEST_EXPORT_WITHOUT_APPROVAL_BLOCKED
    TEST_MINI_KIOSK_SESSION_TIMEOUT_HANDLED

Test names should be readable and tied to policy risk.

---

## 32. Backlog Naming Boundary

Backlog item names should include action and target.

Examples:

    Implement payment uncertainty state
    Add provider event quarantine flow
    Create KDS duplicate ticket guard
    Add support masked session audit event
    Build Mini Kiosk session timeout handling

Backlog names may be human-readable.

They should still map to canonical runtime names.

---

## 33. Naming Change Control

Runtime state and canonical event names should not change casually.

A naming change should record:

- old name
- new name
- affected documents
- affected tests
- affected UI labels
- affected backlog items
- reason for change
- migration impact
- decision date

Naming changes after implementation may create migration burden.

---

## 34. Deprecated Name Handling

If a name becomes obsolete:

- mark as deprecated
- identify replacement
- update index
- update related docs
- update test references later
- avoid reusing deprecated name for different meaning

Recommended marker:

    Deprecated Name:
    Replacement Name:
    Reason:
    Affected Documents:

Deprecated does not mean immediately deleted.

---

## 35. Ambiguous Name Prohibition

Avoid ambiguous names such as:

- `PENDING`
- `DONE`
- `ERROR`
- `FAILED`
- `WAITING`
- `READY`
- `ACTIVE`
- `CLOSED`
- `APPROVED`

unless prefixed by domain.

Better:

- `PAYMENT_PENDING`
- `KDS_TICKET_COMPLETED`
- `PROVIDER_EVENT_FAILED`
- `SUPPORT_CASE_CLOSED`
- `REFUND_APPROVED`

Domain prefix is required for clarity.

---

## 36. Provider Brand Naming Rule

Use provider brand names only when:

- document is provider-specific
- event is raw provider event
- evidence record stores source provider
- adapter name requires provider brand
- provider test requires specific name

Do not use provider brand names in canonical runtime truth unless unavoidable.

Example:

    Good:
      PROVIDER_EVENT_RECEIVED
      Provider: TOSS

    Avoid:
      TOSS_PAYMENT_APPROVED as core runtime truth

Canonical truth should be provider-neutral.

---

## 37. Authority Naming Rule

Names must not imply authority where none exists.

Avoid:

    AGENT_APPROVED_REFUND
    SUPPORT_FIXED_PAYMENT
    BRIDGE_COMPLETED_ORDER
    MINI_KIOSK_CONFIRMED_PAYMENT

Better:

    AGENT_REFUND_RECOMMENDATION_CREATED
    SUPPORT_PAYMENT_REVIEW_NOTE_ADDED
    BRIDGE_ORDER_EVENT_ROUTED
    MINI_KIOSK_PAYMENT_STATUS_DISPLAYED

Naming must respect authority boundary.

---

## 38. State Explosion Control

Avoid creating too many states.

Before adding new state, ask:

1. Is it operationally different?
2. Does UI need to display it differently?
3. Does support need different action?
4. Does audit need separate evidence?
5. Does test need separate behavior?
6. Does provider mapping require it?
7. Can existing state plus reason code handle it?

If not, use existing state with reason code.

---

## 39. Reason Code Boundary

Reason codes may explain why a state exists.

Example:

    State:
      PAYMENT_UNCERTAIN

    Reason codes:
      PROVIDER_TIMEOUT
      SIGNATURE_INVALID
      DUPLICATE_CALLBACK
      STORE_MAPPING_MISSING
      RECONCILIATION_PENDING

Reason codes prevent state explosion.

---

## 40. Suggested Reason Code Families

Recommended reason code families:

| Family | Example |
| ------ | ------- |
| Provider | `PROVIDER_TIMEOUT`, `SIGNATURE_INVALID` |
| Payment | `DUPLICATE_PAYMENT`, `APPROVAL_MISMATCH` |
| KDS | `DUPLICATE_TICKET_RISK`, `KDS_UNAVAILABLE` |
| Support | `MASKING_REQUIRED`, `ESCALATION_REQUIRED` |
| Device | `DEVICE_REVOKED`, `DEVICE_UNTRUSTED` |
| Export | `REDACTION_REQUIRED`, `APPROVAL_MISSING` |
| Session | `SESSION_TIMEOUT`, `SESSION_ABANDONED` |

Reason code must not replace state.

---

## 41. State Transition Record

A state transition record should eventually include:

- transition id
- from state
- to state
- triggering event
- runtime owner
- actor
- authority required
- validation required
- evidence event
- failure state
- UI impact
- test case

This document recommends the record.

It does not implement it.

---

## 42. Example Transition

Example:

    From State:
      PAYMENT_PENDING

    Event:
      PAYMENT_APPROVAL_CONFIRMED

    To State:
      PAYMENT_APPROVED

    Runtime Owner:
      PAYMENT_RUNTIME

    Evidence:
      AUDIT_PAYMENT_STATE_CHANGED

    UI Impact:
      show payment approved

    Test:
      TEST_PAYMENT_APPROVAL_CONFIRMED_UPDATES_STATE

This transition should be provider-validated before accepted.

---

## 43. Cross-Runtime State Rule

One runtime must not directly overwrite another runtime’s owned state.

Examples:

- Provider Gateway does not directly set KDS ticket completed.
- Mini Kiosk does not directly set payment approved.
- Support does not directly set order accepted without authorized workflow.
- Agent does not directly set refund approved.
- Bridge does not directly set kitchen execution completed.

Cross-runtime changes must occur through canonical event and authority boundary.

---

## 44. Canonical Event Register

A future canonical event register should include:

- event name
- domain
- description
- source runtime
- target runtime
- allowed actor
- validation rule
- evidence rule
- related state transition
- related tests
- deprecated names

Recommended file:

    docs/_index/Canonical_Event_Register.md

This document only recommends the register.

---

## 45. Runtime State Register

A future runtime state register should include:

- state name
- domain
- description
- owning runtime
- allowed transitions
- UI label
- Korean UI label where needed
- reason codes
- evidence requirements
- tests
- deprecated relation

Recommended file:

    docs/_index/Runtime_State_Register.md

This document only recommends the register.

---

## 46. Anti-Patterns

The following are prohibited:

- using same state name for multiple domains
- using vague state names without prefix
- treating provider raw event as canonical truth
- hiding uncertainty in UI label
- naming support review as final resolution
- naming agent recommendation as approval
- naming Mini Kiosk display as payment confirmation
- changing runtime names casually after implementation
- creating new state for every small reason
- storing Korean UI phrase as internal runtime name
- implementing state transitions before naming is reviewed
- using provider brand as core runtime truth unnecessarily

---

## 47. Non-Goals

This document does not define:

- final enum values
- final database columns
- final event table
- final API schema
- final frontend constants
- final localization files
- final test suite
- final audit table design
- final migration plan

Those belong to later authorized implementation planning.

---

## 48. Readiness Check

This document is ready when the project can answer:

1. Why does runtime vocabulary matter?
2. What naming layers exist?
3. What is state versus event?
4. What canonical naming style applies?
5. What runtime state family prefixes exist?
6. What customer session states exist?
7. What order intent states exist?
8. What payment states exist?
9. What refund states exist?
10. What cancel states exist?
11. What provider event states exist?
12. What local daemon states exist?
13. What KDS ticket states exist?
14. What KDS Bridge states exist?
15. What support case states exist?
16. What support session states exist?
17. What device trust states exist?
18. What export states exist?
19. What SaaS billing states exist?
20. What pilot evidence states exist?
21. What security incident states exist?
22. What canonical event naming rule applies?
23. How are provider raw events separated?
24. How are UI labels separated?
25. How are Korean UI labels separated?
26. How are audit event names separated?
27. How are test names separated?
28. How are backlog names separated?
29. How are naming changes controlled?
30. How are deprecated names handled?
31. What ambiguous names are prohibited?
32. What authority naming rule applies?
33. How is state explosion controlled?
34. What reason code boundary applies?
35. What is state transition record?
36. What is cross-runtime state rule?
37. What registers are recommended?

If these questions cannot be answered, Phase 1 runtime state vocabulary and canonical event naming are incomplete.

---

## 49. Conclusion

Phase 1 implementation requires stable runtime vocabulary before code begins.

The safe naming model is:

    Provider raw event
        -> validation
        -> canonical event
        -> runtime state transition
        -> audit evidence
        -> UI label
        -> test verification

Internal runtime names must be stable, provider-neutral, authority-aware, and explicit.

UI labels may be friendlier, but must not hide uncertainty.

Support, Agent, Bridge, Mini Kiosk, Provider, POS, Payment, and KDS names must respect ownership boundaries.

This document prepares the project for consistent implementation, testing, audit, UI development, provider integration, and pilot evidence collection.