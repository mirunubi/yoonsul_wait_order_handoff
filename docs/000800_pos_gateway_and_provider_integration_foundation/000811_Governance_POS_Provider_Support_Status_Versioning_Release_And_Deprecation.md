# 000811_Governance_POS_Provider_Support_Status_Versioning_Release_And_Deprecation.md

## 1. Purpose

This document defines governance for POS provider support status, adapter versioning, release gates, provider change monitoring, and deprecation.

The purpose is to prevent POS providers from being treated as officially supported without evidence, release approval, operational readiness, and rollback planning.

This governance document controls how a POS provider moves from research to official support, limited support, deprecation, or unsupported status.

This document is a governance foundation document.

It is not implementation code.

## 2. Upstream Dependencies

This document depends on:

```text
000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md
000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md
000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md
000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md
000805_Policy_POS_Official_API_No_Scraping_And_Provider_Boundary.md
000806_Logic_POS_Idempotency_Retry_Timeout_Duplicate_Prevention_And_Unknown_State.md
000807_Runbook_POS_Reconciliation_Recovery_Manual_Operation_And_Degraded_Mode.md
000808_Template_POS_Transaction_Evidence_Event_Log_And_Diagnostic_Record.md
000809_Checklist_POS_Gateway_Internal_Readiness_Before_Outsourcing_Or_Implementation.md
000810_Guide_POS_Integration_Test_Sandbox_Mock_And_Field_Verification_Context.md
```

This document must not redefine upstream authority, adapter contract, state machine, provider capability, no-scraping policy, retry logic, recovery runbook, evidence template, readiness checklist, or test context differently.

## 3. Core Rule

```text
A POS provider support status is a governed release decision.
It is not a developer assumption, vendor claim, sales promise, or one-time successful test result.
```

Provider support must be based on evidence, tested capability, recovery readiness, reconciliation readiness, security approval, support readiness, and human approval.

## 4. Scope

This document covers:

* provider support status lifecycle
* provider readiness lifecycle
* official support criteria
* candidate support criteria
* limited support criteria
* unsupported provider rule
* adapter versioning
* release gate
* provider change monitoring
* provider API breaking change handling
* deprecation policy
* customer notice rule
* internal support notice rule
* evidence retention
* rollback and downgrade decision
* emergency support status change

## 5. Non-Scope

This document does not define:

* actual provider adapter code
* provider commercial pricing
* final provider contract terms
* customer marketing copy
* production deployment automation
* database schema
* Flutter UI
* Supabase RLS
* legal notice language

Those belong to implementation, commercial, legal, release, or support documents.

## 6. Provider Support Status Values

The following support status values are allowed.

| Status         | Meaning                                                        |
| -------------- | -------------------------------------------------------------- |
| `Official`     | Approved for official support under defined scope              |
| `Candidate`    | Technically and commercially plausible but not yet official    |
| `Limited`      | Supported only under explicitly documented limitations         |
| `Research`     | Under investigation; not available for production promise      |
| `Unsupported`  | Not supported under current policy                             |
| `Human Review` | Status requires human decision due to ambiguity or risk        |
| `Deprecated`   | Previously supported but being removed or replaced             |
| `Suspended`    | Temporarily disabled due to incident, risk, or provider change |

No other provider support status may be used without governance approval.

## 7. Provider Readiness Levels

The provider readiness levels are:

| Level                          | Meaning                                                  |
| ------------------------------ | -------------------------------------------------------- |
| `R0_Unreviewed`                | Provider has not been reviewed                           |
| `R1_Document_Collected`        | Basic provider information is collected                  |
| `R2_Official_Boundary_Checked` | Official API or approved integration boundary is checked |
| `R3_Sandbox_Verified`          | Sandbox or controlled provider test is verified          |
| `R4_Field_Tested`              | Field or near-real-store test evidence exists            |
| `R5_Release_Ready`             | Release checklist is satisfied, pending final approval   |
| `R6_Production_Supported`      | Provider is production supported under governance        |
| `RX_Rejected`                  | Provider is rejected or blocked                          |

Readiness level must not be upgraded without evidence.

## 8. Provider Lifecycle

The normal provider lifecycle is:

```text
Research
  -> Human Review
  -> Candidate
  -> Limited or Official
  -> Production Supported
```

Alternative lifecycle:

```text
Research
  -> Human Review
  -> Unsupported
```

Provider support status may move backward if risk appears.

Examples:

```text
Official -> Limited
Official -> Suspended
Limited -> Unsupported
Candidate -> Research
Official -> Deprecated
Deprecated -> Unsupported
```

## 9. Official Support Criteria

A provider may be marked `Official` only when all required criteria are satisfied.

Required criteria:

* official API or provider-approved integration boundary exists
* no scraping or unofficial bypass is used
* provider capability matrix is complete enough for support scope
* adapter contract can be satisfied
* state machine compatibility is confirmed
* payment/order separation is verified
* cancellation/refund behavior is verified or explicitly limited
* idempotency or duplicate prevention is verified
* timeout handling is verified
* unknown state handling is verified
* recovery runbook can be executed
* reconciliation path exists
* evidence template is satisfied
* sandbox test is passed where available
* field test is passed where required
* security and credential boundary is approved
* support team can handle known failure modes
* release owner approves
* human approver accepts remaining limitations

If any required criterion is missing, the provider must not be marked `Official`.

## 10. Candidate Support Criteria

A provider may be marked `Candidate` when:

* official integration path appears possible
* provider capability investigation has started
* provider documentation or contact exists
* adapter feasibility appears plausible
* key risks are known but not fully verified
* sandbox or field test is not yet complete
* support readiness is not yet complete
* release approval is not yet granted

Candidate providers must not be marketed as supported.

## 11. Limited Support Criteria

A provider may be marked `Limited` when:

* some capabilities are verified
* some capabilities are missing, manual, or restricted
* limitations are documented
* customer-facing promise can be safely limited
* recovery and reconciliation are possible under limited scope
* support team understands limitation
* human approval accepts the limitation

Examples of limited support:

```text
Order create supported, refund unsupported.
Cloud integration unavailable, local-only connector required.
Webhook unavailable, polling required.
Menu sync supported, sold-out sync unsupported.
Idempotency unsupported, gateway duplicate prevention required.
Payment is external and must be reconciled separately.
```

Limited support must always specify allowed and blocked operations.

## 12. Unsupported Provider Rule

A provider must be marked `Unsupported` when:

* no official or provider-approved integration boundary exists
* integration requires scraping
* integration requires reverse engineering
* integration requires undocumented bypass
* provider contract prohibits required use
* required evidence cannot be captured
* duplicate payment or duplicate order risk cannot be controlled
* recovery is not feasible
* reconciliation is not feasible
* credential boundary cannot be secured
* provider limitation breaks customer promise
* human review rejects support

Unsupported providers must not be presented as supported.

## 13. Suspended Provider Rule

A provider may be marked `Suspended` when support must be paused temporarily.

Suspension triggers may include:

* provider outage
* provider API breaking change
* repeated unknown state incidents
* repeated duplicate risk
* evidence capture failure
* security incident
* credential exposure
* provider contract issue
* field incident
* support team unable to safely operate
* unresolved settlement or refund risk

Suspended providers must have:

* reason
* affected stores or tenants
* blocked operations
* allowed operations if any
* customer-facing caution
* recovery condition
* review owner
* reactivation condition

## 14. Deprecated Provider Rule

A provider may be marked `Deprecated` when support will be removed or replaced.

Deprecation triggers may include:

* provider API retirement
* provider contract termination
* replacement adapter available
* support cost too high
* repeated instability
* security risk
* provider becomes commercially irrelevant
* better integration path exists
* manual support burden is unacceptable

Deprecation must include:

* deprecation date
* final support date
* migration path
* affected tenants and stores
* customer/support notice requirement
* data and evidence retention requirement
* rollback or extension condition

## 15. Adapter Versioning Rule

Each provider adapter must have a version.

Adapter version must change when:

* provider API mapping changes
* request/response schema changes
* error normalization changes
* timeout behavior changes
* retry behavior changes
* idempotency behavior changes
* evidence fields change
* reconciliation behavior changes
* recovery behavior changes
* supported capability changes
* security or credential flow changes

Adapter version must be recorded in evidence.

## 16. Recommended Adapter Version Format

Recommended format:

```text
provider_adapter_major.minor.patch
```

Example:

```text
okpos_adapter_1.2.0
toss_pos_adapter_0.4.1
```

Version semantics:

| Version Part | Meaning                                                            |
| ------------ | ------------------------------------------------------------------ |
| Major        | Breaking contract or provider behavior change                      |
| Minor        | New capability or non-breaking behavior expansion                  |
| Patch        | Bug fix, evidence correction, or minor provider mapping correction |

Do not change adapter behavior without updating version when behavior affects evidence, state, recovery, or support.

## 17. Provider Capability Versioning

Provider capability matrix entries must be versioned or reviewed when:

* provider API changes
* provider adds capability
* provider removes capability
* provider changes authentication
* provider changes rate limit
* provider changes idempotency behavior
* provider changes webhook or polling behavior
* provider changes receipt or transaction ID behavior
* provider changes refund or cancellation behavior
* field test reveals limitation
* support incident reveals mismatch

Capability updates must include evidence reference.

## 18. Release Gate

A provider adapter release must pass a release gate.

Release gate requirements:

* provider support status reviewed
* readiness level reviewed
* adapter version assigned
* upstream documents checked
* provider capability matrix updated
* official API/no-scraping policy satisfied
* sandbox test completed where applicable
* field test completed where required
* failure tests completed
* duplicate prevention tests completed
* timeout tests completed
* recovery runbook verified
* reconciliation verified
* evidence template satisfied
* security review completed
* rollback plan defined
* support notice prepared
* human approval completed

Release gate must block release if financial, operational, or evidence risk is unresolved.

## 19. Release Decision Values

Allowed release decision values:

| Decision                     | Meaning                                               |
| ---------------------------- | ----------------------------------------------------- |
| `Approved`                   | Release may proceed                                   |
| `Approved_With_Limitations`  | Release may proceed only under documented limitations |
| `Rejected`                   | Release must not proceed                              |
| `Hold_For_Evidence`          | Evidence is incomplete                                |
| `Hold_For_Test`              | Test coverage is incomplete                           |
| `Hold_For_Security`          | Security review is incomplete                         |
| `Hold_For_Provider_Approval` | Provider boundary is not confirmed                    |
| `Human_Review_Required`      | Human decision is required                            |

Do not use informal release decisions.

## 20. Rollback Rule

Every provider adapter release must have rollback conditions.

Rollback may be required when:

* duplicate order risk appears
* duplicate payment risk appears
* refund unknown incidents increase
* POS/KDS split-brain appears repeatedly
* provider API behavior changes
* timeout rate increases beyond threshold
* evidence capture fails
* reconciliation cannot close incidents
* security boundary is violated
* field incident affects customer trust
* support team cannot operate safely

Rollback must preserve evidence.

Rollback must not delete transaction history.

## 21. Provider Change Monitoring

Provider behavior must be monitored over time.

Monitor:

* API deprecation notices
* provider maintenance notices
* authentication changes
* rate limit changes
* webhook behavior changes
* polling behavior changes
* refund/cancellation behavior changes
* receipt ID behavior changes
* local connector update requirements
* provider dashboard changes
* support channel changes
* incident frequency
* unknown state frequency
* duplicate risk frequency
* reconciliation mismatch frequency

Provider support is not a one-time approval.

## 22. Breaking Change Handling

When a provider breaking change is detected:

1. preserve evidence
2. identify affected adapter versions
3. identify affected stores and tenants
4. classify affected capabilities
5. decide whether to suspend provider support
6. update provider capability matrix
7. update known limitation record
8. run mock or sandbox regression tests
9. run field verification if needed
10. update support notice
11. approve new adapter version or rollback
12. retain change evidence

A breaking change must not be handled silently.

## 23. Customer Notice Rule

Customer-facing notice may be required when provider support status affects customer experience.

Notice may be required when:

* mobile ordering is paused
* kiosk ordering is paused
* refund processing is delayed
* cancellation processing is delayed
* menu availability is limited
* pickup display is unavailable
* manual operation may delay order
* provider outage affects fulfillment

Customer notice must be cautious and must not expose unnecessary provider details unless approved.

## 24. Internal Support Notice Rule

Internal support notice is required when:

* provider status changes
* adapter version changes
* provider limitation is discovered
* outage occurs
* degraded mode is activated
* manual operation path is required
* refund or cancellation handling changes
* evidence requirement changes
* provider support becomes limited, suspended, deprecated, or unsupported

Internal support notice must include:

* provider name
* affected scope
* support status
* allowed operations
* blocked operations
* known limitations
* recovery path
* escalation path
* evidence requirement
* expected duration if known

## 25. Evidence Retention Rule

Provider support decisions must retain evidence.

Evidence must include:

* provider document reference
* capability matrix update
* adapter version record
* test reports
* field verification reports
* release approval
* limitation records
* incident records
* recovery and reconciliation evidence
* support notices
* deprecation notices
* rollback decisions
* human approval records

Evidence retention must support audit, vendor acceptance, customer dispute handling, and future provider review.

## 26. Emergency Status Change

Emergency status change may be required when immediate risk appears.

Possible emergency changes:

```text
Official -> Suspended
Limited -> Suspended
Candidate -> Unsupported
Research -> Blocked
```

Emergency status change may be triggered by:

* security incident
* credential exposure
* duplicate payment incident
* repeated POS order duplication
* provider outage
* provider API break
* refund incident
* unrecoverable reconciliation mismatch
* legal or contract risk
* provider request to stop integration

Emergency status change requires evidence and post-incident review.

## 27. Governance Ownership

The following ownership model applies.

| Area                    | Owner                                 |
| ----------------------- | ------------------------------------- |
| Provider support status | Platform Admin / Human Reviewer       |
| Capability matrix       | Technical Support / Platform Admin    |
| Adapter version         | Engineering Owner                     |
| Release approval        | Human Reviewer / Platform Admin       |
| Security approval       | Security Owner                        |
| Field test approval     | Store Manager / Headquarters Operator |
| Support notice          | Support Owner                         |
| Customer-facing notice  | Support Owner / Human Reviewer        |
| Deprecation decision    | Platform Admin / Business Owner       |
| Emergency suspension    | Platform Admin / Human Reviewer       |

A vendor may provide evidence.

A vendor must not own final support status.

## 28. Relationship To 000900 Outsourcing Package

The outsourcing package under:

```text
docs/000900_outsourcing_vendor_handoff_and_acceptance/
```

must follow this governance.

Vendor deliverables must include:

* provider capability evidence
* adapter version information
* release limitation statement
* known provider limitation list
* test evidence
* recovery and reconciliation evidence
* final handoff documentation

A vendor cannot declare a provider officially supported.

Final support status is an internal governance decision.

## 29. Governance Review Form

Use the following form for provider support status review.

```yaml
provider_support_review_id: TBD
review_date: TBD
reviewer: TBD
provider:
  provider_name: TBD
  provider_id: TBD
  current_support_status: TBD
  requested_support_status: TBD
  current_readiness_level: TBD
  requested_readiness_level: TBD

adapter:
  adapter_id: TBD
  adapter_version: TBD
  previous_adapter_version: TBD
  version_change_reason: TBD

evidence:
  provider_document_reference: TBD
  capability_matrix_reference: TBD
  sandbox_test_reference: TBD
  field_test_reference: TBD
  failure_test_reference: TBD
  recovery_evidence_reference: TBD
  reconciliation_evidence_reference: TBD
  security_review_reference: TBD
  support_notice_reference: TBD

risk:
  payment_risk: TBD
  order_risk: TBD
  refund_risk: TBD
  cancellation_risk: TBD
  kitchen_risk: TBD
  customer_promise_risk: TBD
  evidence_risk: TBD
  security_risk: TBD

decision:
  release_decision: TBD
  approved_support_status: TBD
  approved_readiness_level: TBD
  limitations: TBD
  rollback_condition: TBD
  deprecation_condition: TBD
  next_review_date: TBD
  approval_reference: TBD
```

## 30. Anti-Patterns

The following are prohibited:

* marking provider official because one test order worked
* vendor declaring official support
* sales team promising unsupported provider support
* support team treating candidate provider as official
* release without adapter version
* release without rollback condition
* release without evidence
* release without recovery runbook
* release without reconciliation path
* continuing support after provider breaking change without review
* hiding provider limitations from support
* deprecating provider without notice and migration path
* suspending provider without evidence record
* changing adapter behavior without version update

## 31. Acceptance Criteria

This governance document is acceptable only if it confirms that:

* provider support status is governed
* official support requires evidence and approval
* candidate and limited support are clearly separated
* unsupported providers are controlled
* suspended and deprecated statuses are defined
* adapter versioning is required
* release gate is defined
* rollback conditions are defined
* provider change monitoring is required
* breaking changes require review
* customer and internal support notice rules exist
* vendor cannot declare official support
* evidence retention is required
* no implementation is authorized by this document

## 32. Final Rule

```text
Provider support is not a claim.
Provider support is a governed operational commitment backed by official boundary, tested capability, adapter version, evidence, recovery, reconciliation, support readiness, and human approval.
```
