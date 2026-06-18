# 014060_Policy_Phase_1_Runtime_Transition_Test_Evidence

## 1. Purpose

This document defines the Phase 1 runtime transition test case, evidence packet mapping, verification linkage, failure proof, audit evidence, support review evidence, provider evidence, payment evidence, KDS evidence, and pilot readiness verification policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined runtime state transitions and authority boundaries.

This document defines how those transitions must be tested and proven with evidence before Phase 1 MVP can be considered pilot-ready.

This document does not implement test code, create automated test suites, generate database fixtures, configure CI, or execute verification.

It defines test and evidence mapping policy only.

---

## 2. Scope

This document covers:

- transition-to-test mapping
- transition-to-evidence mapping
- payment transition tests
- provider transition tests
- KDS transition tests
- Mini Kiosk transition tests
- support transition tests
- device trust transition tests
- export transition tests
- pilot evidence tests
- failure and replay tests
- evidence packet structure
- no-implementation boundary

This document does not cover:

- final test runner
- final CI pipeline
- final automated test code
- final test database
- final provider sandbox setup
- final KDS hardware simulation
- final Flutter integration tests
- final production monitoring
- final release certification

---

## 3. Core Principle

A runtime transition is not ready until it is testable and evidence-producing.

The project must follow this rule:

> Every critical Phase 1 runtime transition must have at least one test case and at least one evidence output before it can be approved for pilot operation.

Untested transitions create hidden operational risk.

Transitions without evidence create unrecoverable incidents.

---

## 4. Why Transition Test Mapping Matters

Runtime transitions affect:

- payment truth
- order acceptance
- KDS ticket creation
- refund and cancel authority
- provider event validation
- support recovery
- device trust
- export approval
- Mini Kiosk session continuity
- pilot evidence

If transitions are not mapped to tests and evidence, the project cannot prove that the runtime is safe.

---

## 5. Test Mapping Record Format

Recommended test mapping record:

    Test Mapping ID:
    Source Document:
    Runtime Family:
    Transition ID:
    From State:
    Event:
    To State:
    Risk Covered:
    Test Case:
    Expected Result:
    Failure Result:
    Evidence Required:
    Priority:
    Phase:
    Status:
    Notes:

This record may later become a Markdown table, CSV, spreadsheet, or test management entry.

---

## 6. Test Mapping ID Format

Recommended format:

    TESTMAP-[RUNTIME]-[NUMBER]

Examples:

    TESTMAP-PAYMENT-001
    TESTMAP-PROVIDER-001
    TESTMAP-KDS-001
    TESTMAP-SUPPORT-001
    TESTMAP-SESSION-001
    TESTMAP-DEVICE-001

Alternative transition-based format:

    TESTMAP-TRANS-PAYMENT-001

Final format may be normalized later.

---

## 7. Evidence Packet Mapping Record Format

Recommended evidence mapping record:

    Evidence Mapping ID:
    Source Document:
    Runtime Family:
    Transition ID:
    Evidence Packet Type:
    Required Fields:
    Masking Required:
    Retention Expectation:
    Actor Context:
    Runtime Context:
    Provider Context:
    UI Context:
    Support Context:
    Test Link:
    Status:
    Notes:

This mapping ensures every important transition produces reviewable proof.

---

## 8. Evidence Mapping ID Format

Recommended format:

    EVIDMAP-[RUNTIME]-[NUMBER]

Examples:

    EVIDMAP-PAYMENT-001
    EVIDMAP-PROVIDER-001
    EVIDMAP-KDS-001
    EVIDMAP-SUPPORT-001
    EVIDMAP-PILOT-001

Final format may be normalized later.

---

## 9. Test Case Status Values

Recommended test case status values:

- `NOT_DEFINED`
- `DRAFT`
- `MAPPED`
- `READY_FOR_IMPLEMENTATION`
- `IMPLEMENTED`
- `RUN_PENDING`
- `PASSED`
- `FAILED`
- `BLOCKED`
- `WAIVED`
- `DEFERRED`
- `SUPERSEDED`

During documentation phase, most test cases should remain `DRAFT` or `MAPPED`.

---

## 10. Evidence Mapping Status Values

Recommended evidence mapping status values:

- `NOT_DEFINED`
- `DRAFT`
- `MAPPED`
- `REQUIRED_FOR_PHASE_1`
- `IMPLEMENTATION_PENDING`
- `COLLECTION_PENDING`
- `COLLECTED`
- `REVIEWED`
- `FAILED_REVIEW`
- `WAIVED`
- `DEFERRED`
- `SUPERSEDED`

Evidence mapping must be visible before pilot.

---

## 11. Critical Transition Test Requirement

Critical transitions requiring tests include:

- provider event signature validation
- provider event idempotent duplicate detection
- provider event replay detection
- provider event quarantine
- payment pending to approved
- payment pending to uncertain
- payment duplicate suspected
- refund requested to pending
- refund pending to completed
- cancel requested to KDS impact review
- order intent validated to accepted
- KDS ticket candidate to pending
- KDS ticket pending to accepted
- KDS duplicate suspected
- support session masked view enabled
- support break-glass requested and approved
- device trust revoked
- export request approved
- Mini Kiosk session timeout
- pilot blocker found

These cannot be treated as optional.

---

## 12. Provider Transition Test Mapping

Recommended provider tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `PROVIDER_EVENT_RECEIVED` to `PROVIDER_EVENT_SIGNATURE_PENDING` | `TEST_PROVIDER_EVENT_SIGNATURE_CHECK_STARTED` | provider event evidence |
| `PROVIDER_EVENT_SIGNATURE_PENDING` to `PROVIDER_EVENT_SIGNATURE_VALID` | `TEST_PROVIDER_SIGNATURE_VALID_ACCEPTED` | signature validation evidence |
| `PROVIDER_EVENT_SIGNATURE_PENDING` to `PROVIDER_EVENT_SIGNATURE_INVALID` | `TEST_PROVIDER_SIGNATURE_INVALID_REJECTED` | rejection evidence |
| `PROVIDER_EVENT_SIGNATURE_VALID` to `PROVIDER_EVENT_IDEMPOTENT_DUPLICATE` | `TEST_PROVIDER_DUPLICATE_EVENT_BLOCKED` | idempotency evidence |
| `PROVIDER_EVENT_SIGNATURE_VALID` to `PROVIDER_EVENT_REPLAY_SUSPECTED` | `TEST_PROVIDER_REPLAY_EVENT_BLOCKED` | replay evidence |
| `PROVIDER_EVENT_MAPPING_PENDING` to `PROVIDER_EVENT_QUARANTINED` | `TEST_PROVIDER_MAPPING_FAILURE_QUARANTINED` | quarantine evidence |
| `PROVIDER_EVENT_MAPPED` to `PROVIDER_EVENT_ACCEPTED` | `TEST_PROVIDER_EVENT_CANONICALIZED` | canonical mapping evidence |

Provider tests must prove that raw external signal is not trusted blindly.

---

## 13. Payment Transition Test Mapping

Recommended payment tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `PAYMENT_NOT_STARTED` to `PAYMENT_INITIATED` | `TEST_PAYMENT_FLOW_INITIATED` | payment flow evidence |
| `PAYMENT_INITIATED` to `PAYMENT_PENDING` | `TEST_PAYMENT_PROCESSING_STARTED` | payment state evidence |
| `PAYMENT_PENDING` to `PAYMENT_APPROVED` | `TEST_PAYMENT_APPROVAL_CONFIRMED` | payment approval evidence |
| `PAYMENT_PENDING` to `PAYMENT_FAILED` | `TEST_PAYMENT_FAILURE_CONFIRMED` | payment failure evidence |
| `PAYMENT_PENDING` to `PAYMENT_UNCERTAIN` | `TEST_PAYMENT_UNCERTAINTY_DETECTED` | uncertainty evidence |
| `PAYMENT_PENDING` to `PAYMENT_CANCELLED` | `TEST_PAYMENT_CANCEL_CONFIRMED` | cancel evidence |
| `PAYMENT_APPROVED` to `PAYMENT_DUPLICATE_SUSPECTED` | `TEST_PAYMENT_DUPLICATE_SUSPECTED` | duplicate payment evidence |
| `PAYMENT_UNCERTAIN` to `PAYMENT_RECONCILIATION_REQUIRED` | `TEST_PAYMENT_RECONCILIATION_REQUIRED` | reconciliation evidence |
| `PAYMENT_RECONCILIATION_REQUIRED` to `PAYMENT_APPROVED` | `TEST_PAYMENT_RECONCILED_TO_APPROVED` | reconciliation approval evidence |

Payment tests must be conservative.

Uncertainty must be tested as a first-class path.

---

## 14. Payment Negative Test Mapping

Recommended negative tests:

| Scenario | Expected Result |
| -------- | --------------- |
| duplicate provider approval callback | no duplicate payment approval |
| replayed approval callback | event rejected or quarantined |
| invalid signature approval | payment remains uncertain or rejected |
| provider timeout | payment becomes uncertain |
| approval without store mapping | event quarantined |
| UI button attempts approval | blocked |
| support note attempts approval | blocked |
| Mini Kiosk attempts final approval | blocked |
| failed payment attempts KDS handoff | KDS handoff blocked |
| uncertain payment attempts order acceptance | order acceptance held |

Negative tests prevent false success.

---

## 15. Refund Transition Test Mapping

Recommended refund tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `REFUND_NOT_REQUESTED` to `REFUND_REQUESTED` | `TEST_REFUND_REQUEST_CREATED` | refund request evidence |
| `REFUND_REQUESTED` to `REFUND_REVIEW_REQUIRED` | `TEST_REFUND_REVIEW_REQUIRED` | refund review evidence |
| `REFUND_REQUESTED` to `REFUND_PENDING` | `TEST_REFUND_PROCESSING_STARTED` | refund processing evidence |
| `REFUND_PENDING` to `REFUND_APPROVED` | `TEST_REFUND_APPROVAL_CONFIRMED` | refund approval evidence |
| `REFUND_APPROVED` to `REFUND_COMPLETED` | `TEST_REFUND_COMPLETION_CONFIRMED` | refund completion evidence |
| `REFUND_PENDING` to `REFUND_FAILED` | `TEST_REFUND_FAILURE_CONFIRMED` | refund failure evidence |
| `REFUND_PENDING` to `REFUND_UNCERTAIN` | `TEST_REFUND_UNCERTAINTY_DETECTED` | refund uncertainty evidence |

Refund tests must prove refund is not silently inferred from cancel.

---

## 16. Cancel Transition Test Mapping

Recommended cancel tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `CANCEL_NOT_REQUESTED` to `CANCEL_REQUESTED` | `TEST_CANCEL_REQUEST_CREATED` | cancel request evidence |
| `CANCEL_REQUESTED` to `CANCEL_REVIEW_REQUIRED` | `TEST_CANCEL_REVIEW_REQUIRED` | cancel review evidence |
| `CANCEL_REQUESTED` to `CANCEL_ALLOWED` | `TEST_CANCEL_ALLOWED_CONFIRMED` | cancel decision evidence |
| `CANCEL_REQUESTED` to `CANCEL_BLOCKED` | `TEST_CANCEL_BLOCKED_CONFIRMED` | cancel block evidence |
| `CANCEL_ALLOWED` to `CANCEL_COMPLETED` | `TEST_CANCEL_COMPLETION_CONFIRMED` | cancel completion evidence |
| `CANCEL_REQUESTED` to `CANCEL_KDS_IMPACT_REVIEW_REQUIRED` | `TEST_CANCEL_KDS_IMPACT_REVIEW_REQUIRED` | KDS impact evidence |
| `CANCEL_REQUESTED` to `CANCEL_PAYMENT_IMPACT_REVIEW_REQUIRED` | `TEST_CANCEL_PAYMENT_IMPACT_REVIEW_REQUIRED` | payment impact evidence |

Cancel tests must cover kitchen and payment impact.

---

## 17. Order Intent Transition Test Mapping

Recommended order tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `ORDER_INTENT_DRAFT` to `ORDER_INTENT_CAPTURED` | `TEST_ORDER_INTENT_CAPTURED` | order intent evidence |
| `ORDER_INTENT_CAPTURED` to `ORDER_INTENT_VALIDATING` | `TEST_ORDER_INTENT_VALIDATION_STARTED` | validation evidence |
| `ORDER_INTENT_VALIDATING` to `ORDER_INTENT_VALIDATED` | `TEST_ORDER_INTENT_VALIDATED` | validation pass evidence |
| `ORDER_INTENT_VALIDATING` to `ORDER_INTENT_REJECTED` | `TEST_ORDER_INTENT_REJECTED` | rejection evidence |
| `ORDER_INTENT_VALIDATED` to `ORDER_ACCEPTANCE_PENDING` | `TEST_ORDER_ACCEPTANCE_PENDING` | acceptance pending evidence |
| `ORDER_ACCEPTANCE_PENDING` to `ORDER_ACCEPTED` | `TEST_ORDER_ACCEPTED_WITH_REQUIRED_CONDITIONS` | order acceptance evidence |
| `ORDER_ACCEPTED` to `ORDER_CANCEL_REQUESTED` | `TEST_ORDER_CANCEL_REQUEST_CREATED` | order cancel evidence |
| `ORDER_HELD` to `ORDER_RECOVERY_REQUIRED` | `TEST_ORDER_RECOVERY_REQUIRED` | order recovery evidence |

Order tests must prove intent is not accepted order.

---

## 18. Order Negative Test Mapping

Recommended order negative tests:

| Scenario | Expected Result |
| -------- | --------------- |
| draft order tries acceptance | blocked |
| captured but unvalidated order tries acceptance | blocked |
| validated order with uncertain payment tries acceptance | held |
| accepted order duplicates acceptance event | idempotent no duplicate effect |
| cancelled order tries KDS handoff | blocked or recovery-required |
| held order tries KDS ticket | blocked |
| Mini Kiosk directly marks accepted | blocked |

Order acceptance must be guarded.

---

## 19. Customer Session Test Mapping

Recommended session tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `SESSION_CREATED` to `SESSION_ACTIVE` | `TEST_SESSION_ACTIVATED` | session evidence |
| `SESSION_ACTIVE` to `SESSION_WAITING_CONTEXT_ATTACHED` | `TEST_WAITING_CONTEXT_ATTACHED` | waiting context evidence |
| `SESSION_ACTIVE` to `SESSION_TABLE_CONTEXT_ATTACHED` | `TEST_TABLE_CONTEXT_ATTACHED` | table context evidence |
| `SESSION_ACTIVE` to `SESSION_MINI_KIOSK_ATTACHED` | `TEST_MINI_KIOSK_CONTEXT_ATTACHED` | Mini Kiosk session evidence |
| `SESSION_ACTIVE` to `SESSION_TIMEOUT_PENDING` | `TEST_SESSION_TIMEOUT_WARNING_CREATED` | timeout evidence |
| `SESSION_TIMEOUT_PENDING` to `SESSION_EXPIRED` | `TEST_SESSION_TIMEOUT_CONFIRMED` | expiration evidence |
| `SESSION_ACTIVE` to `SESSION_ABANDONED` | `TEST_SESSION_ABANDONED_DETECTED` | abandonment evidence |

Session tests must prove session continuity does not create payment or order authority.

---

## 20. Mini Kiosk Test Mapping

Recommended Mini Kiosk tests:

| Scenario | Expected Result | Evidence |
| -------- | --------------- | -------- |
| customer creates session | session created evidence |
| customer captures order intent | order intent evidence |
| session timeout occurs | timeout state and evidence |
| customer abandons order | abandonment evidence |
| Mini Kiosk requests payment handoff | payment handoff request evidence |
| provider unavailable | provider failure display evidence |
| payment uncertain | uncertainty displayed |
| Mini Kiosk attempts direct approval | blocked |
| Mini Kiosk attempts direct KDS ticket | blocked |
| support handoff requested | support request evidence |

Mini Kiosk tests must prove it is an input/display surface, not final authority.

---

## 21. KDS Ticket Test Mapping

Recommended KDS tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `KDS_TICKET_NOT_CREATED` to `KDS_TICKET_CANDIDATE` | `TEST_KDS_TICKET_CANDIDATE_CREATED` | KDS candidate evidence |
| `KDS_TICKET_CANDIDATE` to `KDS_TICKET_PENDING` | `TEST_KDS_TICKET_HANDOFF_STARTED` | handoff evidence |
| `KDS_TICKET_PENDING` to `KDS_TICKET_ACCEPTED` | `TEST_KDS_TICKET_ACCEPTED` | KDS acceptance evidence |
| `KDS_TICKET_ACCEPTED` to `KDS_TICKET_IN_PROGRESS` | `TEST_KDS_TICKET_WORK_STARTED` | kitchen work evidence |
| `KDS_TICKET_IN_PROGRESS` to `KDS_TICKET_COMPLETED` | `TEST_KDS_TICKET_COMPLETED` | completion evidence |
| `KDS_TICKET_PENDING` to `KDS_TICKET_HELD` | `TEST_KDS_TICKET_HELD` | hold evidence |
| `KDS_TICKET_PENDING` to `KDS_TICKET_DUPLICATE_SUSPECTED` | `TEST_KDS_DUPLICATE_TICKET_SUSPECTED` | duplicate evidence |
| `KDS_TICKET_DUPLICATE_SUSPECTED` to `KDS_TICKET_RECOVERY_REQUIRED` | `TEST_KDS_TICKET_RECOVERY_REQUIRED` | recovery evidence |

KDS tests must protect against duplicate kitchen execution.

---

## 22. KDS Negative Test Mapping

Recommended KDS negative tests:

| Scenario | Expected Result |
| -------- | --------------- |
| KDS ticket created without accepted order | blocked |
| KDS ticket created with uncertain payment | blocked or held |
| duplicate handoff event | no duplicate KDS ticket |
| KDS candidate directly becomes in-progress | blocked |
| cancelled order tries KDS start | blocked or recovery-required |
| bridge tries mark completed | blocked |
| provider retry creates duplicate ticket | blocked |
| stale handoff event arrives | rejected or quarantined |

KDS must be safe before fast.

---

## 23. KDS Bridge Test Mapping

Recommended KDS Bridge tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `KDS_BRIDGE_READY` to `KDS_BRIDGE_EVENT_RECEIVED` | `TEST_KDS_BRIDGE_EVENT_RECEIVED` | bridge event evidence |
| `KDS_BRIDGE_EVENT_RECEIVED` to `KDS_BRIDGE_EVENT_VALIDATED` | `TEST_KDS_BRIDGE_EVENT_VALIDATED` | validation evidence |
| `KDS_BRIDGE_EVENT_RECEIVED` to `KDS_BRIDGE_EVENT_REJECTED` | `TEST_KDS_BRIDGE_EVENT_REJECTED` | rejection evidence |
| `KDS_BRIDGE_EVENT_VALIDATED` to `KDS_BRIDGE_RETRY_PENDING` | `TEST_KDS_BRIDGE_RETRY_PENDING` | retry evidence |
| `KDS_BRIDGE_EVENT_RECEIVED` to `KDS_BRIDGE_STALE_EVENT_DETECTED` | `TEST_KDS_BRIDGE_STALE_EVENT_DETECTED` | stale event evidence |
| `KDS_BRIDGE_READY` to `KDS_BRIDGE_DEGRADED` | `TEST_KDS_BRIDGE_DEGRADED_MODE` | degraded evidence |
| `KDS_BRIDGE_DEGRADED` to `KDS_BRIDGE_RECOVERY_REQUIRED` | `TEST_KDS_BRIDGE_RECOVERY_REQUIRED` | recovery evidence |

Bridge tests must prove bridge is not execution owner.

---

## 24. Support Case Test Mapping

Recommended support case tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `SUPPORT_CASE_NOT_OPENED` to `SUPPORT_CASE_OPEN` | `TEST_SUPPORT_CASE_CREATED` | support case evidence |
| `SUPPORT_CASE_OPEN` to `SUPPORT_CASE_ASSIGNED` | `TEST_SUPPORT_CASE_ASSIGNED` | assignment evidence |
| `SUPPORT_CASE_ASSIGNED` to `SUPPORT_CASE_IN_REVIEW` | `TEST_SUPPORT_CASE_REVIEW_STARTED` | review evidence |
| `SUPPORT_CASE_IN_REVIEW` to `SUPPORT_CASE_ESCALATED` | `TEST_SUPPORT_CASE_ESCALATED` | escalation evidence |
| `SUPPORT_CASE_IN_REVIEW` to `SUPPORT_CASE_WAITING_EXTERNAL` | `TEST_SUPPORT_WAITING_EXTERNAL` | external wait evidence |
| `SUPPORT_CASE_IN_REVIEW` to `SUPPORT_CASE_RESOLUTION_PROPOSED` | `TEST_SUPPORT_RESOLUTION_PROPOSED` | proposed resolution evidence |
| `SUPPORT_CASE_RESOLUTION_PROPOSED` to `SUPPORT_CASE_RESOLVED` | `TEST_SUPPORT_CASE_RESOLVED_WITH_EVIDENCE` | resolution evidence |
| `SUPPORT_CASE_RESOLVED` to `SUPPORT_CASE_CLOSED` | `TEST_SUPPORT_CASE_CLOSED` | closure evidence |

Support tests must prove resolved is not merely dismissed.

---

## 25. Support Session Test Mapping

Recommended support session tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `SUPPORT_SESSION_NOT_STARTED` to `SUPPORT_SESSION_REQUESTED` | `TEST_SUPPORT_SESSION_REQUESTED` | session request evidence |
| `SUPPORT_SESSION_REQUESTED` to `SUPPORT_SESSION_APPROVED` | `TEST_SUPPORT_SESSION_APPROVED` | approval evidence |
| `SUPPORT_SESSION_APPROVED` to `SUPPORT_SESSION_ACTIVE` | `TEST_SUPPORT_SESSION_STARTED` | session start evidence |
| `SUPPORT_SESSION_ACTIVE` to `SUPPORT_SESSION_MASKED_VIEW` | `TEST_SUPPORT_MASKED_VIEW_ENABLED` | masking evidence |
| `SUPPORT_SESSION_ACTIVE` to `SUPPORT_SESSION_BREAK_GLASS_REQUESTED` | `TEST_SUPPORT_BREAK_GLASS_REQUESTED` | break-glass request evidence |
| `SUPPORT_SESSION_BREAK_GLASS_REQUESTED` to `SUPPORT_SESSION_BREAK_GLASS_APPROVED` | `TEST_SUPPORT_BREAK_GLASS_APPROVED` | break-glass approval evidence |
| `SUPPORT_SESSION_ACTIVE` to `SUPPORT_SESSION_EXPIRED` | `TEST_SUPPORT_SESSION_EXPIRED` | expiration evidence |
| `SUPPORT_SESSION_ACTIVE` to `SUPPORT_SESSION_ENDED` | `TEST_SUPPORT_SESSION_ENDED` | session end evidence |

Support session tests must prove time-bound and case-scoped access.

---

## 26. Support Negative Test Mapping

Recommended support negative tests:

| Scenario | Expected Result |
| -------- | --------------- |
| support views unmasked CI/DI without approval | blocked |
| support mutates payment approval | blocked |
| support mutates KDS completed | blocked |
| support resolves case without evidence | blocked or review-required |
| expired support session continues access | blocked |
| support opens case outside tenant/store scope | blocked |
| break-glass without reason | blocked |
| support export without authority | blocked |

Support power must be constrained.

---

## 27. Device Trust Test Mapping

Recommended device tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `DEVICE_UNREGISTERED` to `DEVICE_REGISTERED` | `TEST_DEVICE_REGISTERED` | device registration evidence |
| `DEVICE_REGISTERED` to `DEVICE_TRUST_PENDING` | `TEST_DEVICE_TRUST_REVIEW_STARTED` | trust review evidence |
| `DEVICE_TRUST_PENDING` to `DEVICE_TRUSTED` | `TEST_DEVICE_TRUST_CONFIRMED` | trust evidence |
| `DEVICE_TRUST_PENDING` to `DEVICE_UNTRUSTED` | `TEST_DEVICE_TRUST_REJECTED` | rejection evidence |
| `DEVICE_TRUSTED` to `DEVICE_SUSPENDED` | `TEST_DEVICE_SUSPENDED` | suspension evidence |
| `DEVICE_TRUSTED` to `DEVICE_REVOKED` | `TEST_DEVICE_TRUST_REVOKED` | revocation evidence |
| `DEVICE_TRUSTED` to `DEVICE_LOST_REPORTED` | `TEST_DEVICE_LOST_REPORTED` | lost device evidence |
| `DEVICE_LOST_REPORTED` to `DEVICE_RECOVERY_REQUIRED` | `TEST_DEVICE_RECOVERY_REQUIRED` | recovery evidence |

Device tests must prove device trust is separate from user role.

---

## 28. Export Test Mapping

Recommended export tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `EXPORT_NOT_REQUESTED` to `EXPORT_REQUESTED` | `TEST_EXPORT_REQUEST_CREATED` | export request evidence |
| `EXPORT_REQUESTED` to `EXPORT_REVIEW_REQUIRED` | `TEST_EXPORT_REVIEW_REQUIRED` | export review evidence |
| `EXPORT_REVIEW_REQUIRED` to `EXPORT_APPROVED` | `TEST_EXPORT_APPROVED` | export approval evidence |
| `EXPORT_REVIEW_REQUIRED` to `EXPORT_REJECTED` | `TEST_EXPORT_REJECTED` | export rejection evidence |
| `EXPORT_APPROVED` to `EXPORT_GENERATING` | `TEST_EXPORT_GENERATION_STARTED` | generation evidence |
| `EXPORT_GENERATING` to `EXPORT_COMPLETED` | `TEST_EXPORT_COMPLETED` | completion evidence |
| `EXPORT_GENERATING` to `EXPORT_FAILED` | `TEST_EXPORT_FAILED` | failure evidence |
| `EXPORT_REQUESTED` to `EXPORT_REDACTION_REQUIRED` | `TEST_EXPORT_REDACTION_REQUIRED` | redaction evidence |

Export tests must prove view authority is not export authority.

---

## 29. SaaS Billing Test Mapping

Recommended SaaS billing tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `BILLING_NOT_STARTED` to `BILLING_QUOTE_DRAFT` | `TEST_BILLING_QUOTE_DRAFT_CREATED` | quote draft evidence |
| `BILLING_QUOTE_DRAFT` to `BILLING_QUOTE_SENT` | `TEST_BILLING_QUOTE_SENT` | quote sent evidence |
| `BILLING_QUOTE_SENT` to `BILLING_QUOTE_ACCEPTED` | `TEST_BILLING_QUOTE_ACCEPTED` | acceptance evidence |
| `BILLING_QUOTE_ACCEPTED` to `BILLING_PILOT_ACTIVE` | `TEST_BILLING_PILOT_STARTED` | pilot billing evidence |
| `BILLING_PILOT_ACTIVE` to `BILLING_SUBSCRIPTION_ACTIVE` | `TEST_BILLING_SUBSCRIPTION_STARTED` | subscription evidence |
| `BILLING_SUBSCRIPTION_ACTIVE` to `BILLING_DOWNGRADE_PENDING` | `TEST_BILLING_DOWNGRADE_REQUESTED` | downgrade evidence |
| `BILLING_SUBSCRIPTION_ACTIVE` to `BILLING_CANCEL_REQUESTED` | `TEST_BILLING_CANCEL_REQUESTED` | cancel evidence |
| `BILLING_CANCEL_REQUESTED` to `BILLING_ENDED` | `TEST_BILLING_ENDED` | end evidence |

Billing tests must prove billing lifecycle does not silently mutate operational runtime.

---

## 30. Pilot Evidence Test Mapping

Recommended pilot evidence tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `PILOT_NOT_STARTED` to `PILOT_SCOPE_DEFINED` | `TEST_PILOT_SCOPE_DEFINED` | pilot scope evidence |
| `PILOT_SCOPE_DEFINED` to `PILOT_ACTIVE` | `TEST_PILOT_STARTED` | pilot start evidence |
| `PILOT_ACTIVE` to `PILOT_EVIDENCE_COLLECTING` | `TEST_PILOT_EVIDENCE_COLLECTION_STARTED` | pilot evidence packet |
| `PILOT_EVIDENCE_COLLECTING` to `PILOT_INCIDENT_REVIEW_REQUIRED` | `TEST_PILOT_INCIDENT_REVIEW_REQUIRED` | incident evidence |
| `PILOT_EVIDENCE_COLLECTING` to `PILOT_BLOCKER_FOUND` | `TEST_PILOT_BLOCKER_FOUND` | blocker evidence |
| `PILOT_EVIDENCE_COLLECTING` to `PILOT_READY_FOR_CONVERSION_REVIEW` | `TEST_PILOT_CONVERSION_REVIEW_READY` | conversion readiness evidence |
| `PILOT_READY_FOR_CONVERSION_REVIEW` to `PILOT_CONVERTED_TO_PAID` | `TEST_PILOT_PAID_CONVERSION_CONFIRMED` | paid conversion evidence |
| `PILOT_ACTIVE` to `PILOT_EXITED` | `TEST_PILOT_EXIT_CONFIRMED` | exit evidence |

Pilot evidence tests must prove pilot learning, not just sales optimism.

---

## 31. Security Incident Test Mapping

Recommended security incident tests:

| Transition | Test Case | Evidence |
| ---------- | --------- | -------- |
| `SECURITY_INCIDENT_NOT_OPENED` to `SECURITY_INCIDENT_DETECTED` | `TEST_SECURITY_INCIDENT_DETECTED` | incident detection evidence |
| `SECURITY_INCIDENT_DETECTED` to `SECURITY_INCIDENT_TRIAGE_REQUIRED` | `TEST_SECURITY_TRIAGE_REQUIRED` | triage evidence |
| `SECURITY_INCIDENT_TRIAGE_REQUIRED` to `SECURITY_INCIDENT_CONTAINMENT_REQUIRED` | `TEST_SECURITY_CONTAINMENT_REQUIRED` | containment evidence |
| `SECURITY_INCIDENT_CONTAINMENT_REQUIRED` to `SECURITY_INCIDENT_CONTAINED` | `TEST_SECURITY_CONTAINMENT_CONFIRMED` | containment confirmation evidence |
| `SECURITY_INCIDENT_CONTAINED` to `SECURITY_INCIDENT_RECOVERY_REQUIRED` | `TEST_SECURITY_RECOVERY_REQUIRED` | recovery evidence |
| `SECURITY_INCIDENT_RECOVERY_REQUIRED` to `SECURITY_INCIDENT_RESOLVED` | `TEST_SECURITY_INCIDENT_RESOLVED` | resolution evidence |
| `SECURITY_INCIDENT_RESOLVED` to `SECURITY_INCIDENT_POSTMORTEM_REQUIRED` | `TEST_SECURITY_POSTMORTEM_REQUIRED` | postmortem evidence |
| `SECURITY_INCIDENT_POSTMORTEM_REQUIRED` to `SECURITY_INCIDENT_CLOSED` | `TEST_SECURITY_INCIDENT_CLOSED` | closure evidence |

Security closure must be evidence-based.

---

## 32. Evidence Packet Types

Recommended evidence packet types:

- `PROVIDER_EVENT_EVIDENCE_PACKET`
- `PAYMENT_EVIDENCE_PACKET`
- `REFUND_CANCEL_EVIDENCE_PACKET`
- `ORDER_INTENT_EVIDENCE_PACKET`
- `KDS_TICKET_EVIDENCE_PACKET`
- `KDS_BRIDGE_EVIDENCE_PACKET`
- `MINI_KIOSK_SESSION_EVIDENCE_PACKET`
- `SUPPORT_CASE_EVIDENCE_PACKET`
- `SUPPORT_SESSION_EVIDENCE_PACKET`
- `DEVICE_TRUST_EVIDENCE_PACKET`
- `EXPORT_EVIDENCE_PACKET`
- `BILLING_LIFECYCLE_EVIDENCE_PACKET`
- `PILOT_EVIDENCE_PACKET`
- `SECURITY_INCIDENT_EVIDENCE_PACKET`

Each packet should have clear ownership and masking rules.

---

## 33. Evidence Packet Minimum Fields

Minimum evidence packet fields:

- packet id
- packet type
- source runtime
- target runtime
- tenant id reference
- store id reference
- actor reference
- device reference where applicable
- provider reference where applicable
- triggering event
- from state
- to state
- timestamp
- validation result
- failure result if any
- masking status
- related support case if any
- related test case if any
- notes

Sensitive raw data must be excluded or masked.

---

## 34. Evidence Masking Rule

Evidence packets must not expose:

- raw CI/DI
- raw card data
- provider secrets
- webhook secrets
- access tokens
- customer private data beyond need
- staff private data beyond need
- support internal secrets
- production credentials

Evidence must be useful without becoming leakage.

---

## 35. Test Priority Values

Recommended test priority values:

- `T0_CRITICAL_SECURITY`
- `T1_PAYMENT_OR_ORDER_BLOCKER`
- `T2_KDS_OPERATION_BLOCKER`
- `T3_PROVIDER_INTEGRATION_REQUIRED`
- `T4_SUPPORT_RECOVERY_REQUIRED`
- `T5_UI_AUTHORITY_REQUIRED`
- `T6_PILOT_EVIDENCE_REQUIRED`
- `T7_DEFERRED`

Priority should reflect operational risk.

---

## 36. Test Required For Phase 1

Phase 1 required tests include at least:

- provider signature invalid rejection
- provider duplicate event blocking
- provider replay event blocking
- payment approval confirmation
- payment uncertainty detection
- duplicate payment prevention
- refund/cancel boundary
- order acceptance with required conditions
- order acceptance blocked under uncertainty
- KDS duplicate ticket prevention
- KDS handoff blocked under unsafe conditions
- support masked view enforcement
- support break-glass evidence
- device revocation access block
- export without approval blocked
- Mini Kiosk timeout handling
- pilot evidence packet completeness

Without these, pilot readiness is weak.

---

## 37. Waiver Rule

A Phase 1 test may be waived only if:

- reason is documented
- risk is accepted explicitly
- affected runtime is known
- affected pilot scope is known
- compensating control exists
- revisit trigger is defined
- waiver is time-bound or phase-bound

Waiver is not deletion.

Waiver must be visible.

---

## 38. Failed Test Rule

If a required test fails:

1. mark transition as not ready
2. record failure evidence
3. identify affected runtime
4. identify affected data flow
5. identify affected UI
6. identify affected provider if any
7. create blocker
8. prevent pilot approval if critical
9. retest after correction

Failed tests must not be hidden.

---

## 39. Evidence Review Rule

Evidence packet must be reviewable by the correct authority.

Examples:

| Evidence Packet | Reviewer |
| --------------- | -------- |
| payment evidence | payment/runtime owner |
| KDS evidence | kitchen/KDS owner |
| support evidence | support governance owner |
| export evidence | export/security owner |
| provider evidence | provider integration owner |
| security evidence | security owner |
| pilot evidence | pilot review owner |

Evidence without reviewer is incomplete.

---

## 40. Pilot Readiness Evidence Gate

Pilot readiness requires:

- critical tests mapped
- critical tests passed or waived
- evidence packets defined
- evidence packets collected in test environment
- support recovery evidence reviewed
- provider failure evidence reviewed
- payment uncertainty evidence reviewed
- KDS duplicate prevention evidence reviewed
- export/masking evidence reviewed
- pilot evidence packet template ready

Pilot readiness must be evidence-driven.

---

## 41. Future Test Register Recommendation

Recommended future files:

    docs/_index/
      Runtime_Transition_Test_Mapping_Register.md
      Evidence_Packet_Mapping_Register.md
      Phase_1_Required_Test_Register.md
      Test_Waiver_Register.md
      Failed_Test_Blocker_Register.md
      Pilot_Readiness_Evidence_Register.md

This document only recommends the register files.

It does not create them.

---

## 42. Anti-Patterns

The following are prohibited:

- approving transition without test mapping
- approving transition without evidence mapping
- treating happy path as sufficient
- ignoring negative tests
- ignoring provider replay
- ignoring payment uncertainty
- ignoring duplicate KDS ticket risk
- ignoring support masking test
- ignoring export approval test
- collecting evidence with raw secrets
- treating waiver as deletion
- hiding failed tests
- claiming pilot readiness without evidence packet
- relying on UI screenshots as sole evidence
- testing only in production

---

## 43. Non-Goals

This document does not define:

- final automated tests
- final test database fixtures
- final CI jobs
- final provider sandbox wiring
- final KDS hardware test rig
- final Flutter integration tests
- final production monitoring
- final release approval process

Those belong to later authorized implementation planning.

---

## 44. Readiness Check

This document is ready when the project can answer:

1. Why is transition test mapping required?
2. What fields should test mapping record include?
3. What test mapping ID format is recommended?
4. What fields should evidence mapping record include?
5. What evidence mapping ID format is recommended?
6. What test case status values exist?
7. What evidence mapping status values exist?
8. What critical transitions require tests?
9. What provider transition tests exist?
10. What payment transition tests exist?
11. What payment negative tests exist?
12. What refund transition tests exist?
13. What cancel transition tests exist?
14. What order transition tests exist?
15. What order negative tests exist?
16. What session tests exist?
17. What Mini Kiosk tests exist?
18. What KDS tests exist?
19. What KDS negative tests exist?
20. What bridge tests exist?
21. What support tests exist?
22. What support negative tests exist?
23. What device tests exist?
24. What export tests exist?
25. What SaaS billing tests exist?
26. What pilot evidence tests exist?
27. What security incident tests exist?
28. What evidence packet types exist?
29. What evidence packet minimum fields exist?
30. What masking rule applies?
31. What Phase 1 tests are required?
32. What waiver rule applies?
33. What failed test rule applies?
34. What evidence review rule applies?
35. What pilot readiness evidence gate applies?
36. What anti-patterns are prohibited?

If these questions cannot be answered, Phase 1 runtime transition test and evidence mapping is incomplete.

---

## 45. Conclusion

Phase 1 runtime transitions must be tested and evidenced before pilot readiness.

The safe verification flow is:

    transition defined
        -> test mapped
        -> evidence packet mapped
        -> negative path covered
        -> failure path covered
        -> masking confirmed
        -> reviewer assigned
        -> pilot gate evaluated

This document ensures that provider signals, payment truth, order acceptance, KDS handoff, Mini Kiosk input, support recovery, device trust, export approval, billing lifecycle, pilot evidence, and security incidents can be verified before they are trusted.

The project should not treat a runtime transition as ready until its tests and evidence are mapped.