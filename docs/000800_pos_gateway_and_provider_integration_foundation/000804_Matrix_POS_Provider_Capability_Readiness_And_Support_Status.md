# 000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md

## 1. Purpose

This document defines the POS provider capability, readiness, and support status matrix.

The purpose is to prevent unsupported, partially supported, unofficial, or unverified POS integrations from being treated as production-ready.

This matrix is used to determine whether a POS provider can be supported through the POS Gateway and Provider Adapter foundation.

This document is a planning and control matrix.

It is not implementation code.

## 2. Upstream Dependencies

This document depends on:

```text
000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md
000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md
000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md
```

The authority boundary, adapter contract, and state machine must not be redefined by this matrix.

This matrix only records provider capability and readiness.

## 3. Core Rule

```text
Integration possibility does not equal official support.
Commercial support requires official boundary, capability evidence, test evidence, recovery readiness, reconciliation readiness, and human approval.
```

A provider may be technically connectable but still unsupported.

A provider may support order creation but not refund.

A provider may support POS order creation but not KDS confirmation.

A provider may expose data through a local connector but not through a stable official API.

Every capability must be verified separately.

## 4. Scope

This matrix covers:

* official API availability
* sandbox availability
* order capability
* payment capability
* cancellation capability
* refund capability
* receipt and transaction ID capability
* menu sync capability
* price sync capability
* option sync capability
* sold-out or availability sync capability
* webhook support
* polling support
* local integration requirement
* cloud integration support
* authentication method
* rate limit
* retry behavior
* idempotency support
* reconciliation support
* evidence availability
* known limitations
* provider support status
* readiness decision

## 5. Non-Scope

This matrix does not define:

* provider-specific implementation code
* adapter source code
* production credential configuration
* provider commercial contract
* provider pricing
* final release approval
* legal acceptance
* customer-facing marketing claims

Those must be handled by separate implementation, legal, commercial, release, or outsourcing documents.

## 6. Support Status Values

The following support status values are allowed.

| Status         | Meaning                                                                                                                 |
| -------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `Official`     | Provider is approved for official support with verified API boundary, tested capability, evidence, and release approval |
| `Candidate`    | Provider appears suitable but is not yet production-approved                                                            |
| `Limited`      | Provider can be used only for explicitly documented limited scenarios                                                   |
| `Research`     | Provider is under investigation and must not be treated as supported                                                    |
| `Unsupported`  | Provider is not supported or cannot be safely supported under current rules                                             |
| `Human Review` | Provider status cannot be determined without human review and evidence                                                  |

No other support status should be introduced without governance approval.

## 7. Readiness Levels

The following readiness levels may be used.

| Readiness Level                | Meaning                                                                |
| ------------------------------ | ---------------------------------------------------------------------- |
| `R0_Unreviewed`                | Provider has not been reviewed                                         |
| `R1_Document_Collected`        | Basic provider documents or commercial information have been collected |
| `R2_Official_Boundary_Checked` | Official API, contract, or integration boundary has been checked       |
| `R3_Sandbox_Verified`          | Sandbox or controlled test environment has been verified               |
| `R4_Field_Tested`              | Real or near-real store test evidence exists                           |
| `R5_Release_Ready`             | Provider is ready for controlled release after approval                |
| `R6_Production_Supported`      | Provider is production-supported under governance                      |
| `RX_Rejected`                  | Provider is rejected or blocked                                        |

Readiness level must not be upgraded without evidence.

## 8. Capability Field Definitions

| Field                          | Definition                                                                    |
| ------------------------------ | ----------------------------------------------------------------------------- |
| Provider Name                  | POS provider name                                                             |
| Official API Availability      | Whether an official documented API or approved integration route exists       |
| Sandbox Availability           | Whether a sandbox, test account, staging channel, or test connector exists    |
| Order Create                   | Whether the provider supports creating or transmitting orders                 |
| Order Update                   | Whether the provider supports modifying an existing order                     |
| Order Cancel                   | Whether the provider supports order cancellation                              |
| Payment Authorization          | Whether the provider or linked provider supports payment authorization        |
| Payment Cancel                 | Whether payment cancellation is supported                                     |
| Refund                         | Whether refund is supported                                                   |
| Receipt ID                     | Whether provider returns a stable receipt ID                                  |
| Menu Sync                      | Whether menu sync is supported                                                |
| Price Sync                     | Whether price sync is supported                                               |
| Option Sync                    | Whether option sync is supported                                              |
| Sold-Out Sync                  | Whether sold-out or availability sync is supported                            |
| Webhook                        | Whether provider can push events                                              |
| Polling                        | Whether provider status must be pulled periodically                           |
| Local Integration Requirement  | Whether local store machine, local agent, or local network access is required |
| Cloud Integration Availability | Whether integration can operate through cloud endpoint                        |
| Authentication Method          | API key, OAuth, certificate, local credential, vendor account, or unknown     |
| Rate Limit                     | Known rate limit or unknown                                                   |
| Retry Behavior                 | Whether retry is safe, unsafe, provider-supported, or unknown                 |
| Idempotency Support            | Whether provider supports native idempotency                                  |
| Reconciliation Support         | Whether provider exposes enough data for reconciliation                       |
| Evidence Availability          | Whether provider provides stable evidence fields                              |
| Known Limitation               | Known provider limitation                                                     |
| Support Status                 | Official, Candidate, Limited, Research, Unsupported, or Human Review          |
| Readiness Level                | R0 to R6 or RX                                                                |
| Evidence Reference             | Document, test, or audit evidence reference                                   |
| Owner                          | Internal owner responsible for follow-up                                      |
| Last Reviewed                  | Last review date or TBD                                                       |

## 9. Capability Value Rules

Use the following values where possible.

| Value                | Meaning                                       |
| -------------------- | --------------------------------------------- |
| `Yes`                | Verified as supported                         |
| `No`                 | Verified as not supported                     |
| `Partial`            | Supported only in limited cases               |
| `Unknown`            | Not yet verified                              |
| `Provider-Dependent` | Depends on provider configuration or contract |
| `Manual`             | Requires manual operation                     |
| `Local-Only`         | Requires local store-side integration         |
| `Cloud`              | Supported through cloud integration           |
| `N/A`                | Not applicable                                |
| `TBD`                | To be determined                              |

Do not write `Yes` unless evidence exists.

Use `Unknown`, `TBD`, or `Human Review` when evidence is missing.

## 10. Initial Provider Capability Matrix

This initial matrix is intentionally conservative.

The rows below are placeholders for controlled investigation and must not be interpreted as final commercial support.

| Provider Name                 | Official API Availability | Sandbox Availability | Order Create | Order Update | Order Cancel | Payment Authorization | Payment Cancel | Refund  | Receipt ID | Menu Sync | Price Sync | Option Sync | Sold-Out Sync | Webhook | Polling | Local Integration Requirement | Cloud Integration Availability | Authentication Method | Rate Limit | Retry Behavior | Idempotency Support | Reconciliation Support | Evidence Availability | Known Limitation               | Support Status | Readiness Level | Evidence Reference | Owner | Last Reviewed |
| ----------------------------- | ------------------------- | -------------------- | ------------ | ------------ | ------------ | --------------------- | -------------- | ------- | ---------- | --------- | ---------- | ----------- | ------------- | ------- | ------- | ----------------------------- | ------------------------------ | --------------------- | ---------- | -------------- | ------------------- | ---------------------- | --------------------- | ------------------------------ | -------------- | --------------- | ------------------ | ----- | ------------- |
| OKPOS                         | Unknown                   | Unknown              | Unknown      | Unknown      | Unknown      | Unknown               | Unknown        | Unknown | Unknown    | Unknown   | Unknown    | Unknown     | Unknown       | Unknown | Unknown | Unknown                       | Unknown                        | Unknown               | Unknown    | Unknown        | Unknown             | Unknown                | Unknown               | Official verification required | Human Review   | R0_Unreviewed   | TBD                | TBD   | TBD           |
| Toss POS                      | Unknown                   | Unknown              | Unknown      | Unknown      | Unknown      | Unknown               | Unknown        | Unknown | Unknown    | Unknown   | Unknown    | Unknown     | Unknown       | Unknown | Unknown | Unknown                       | Unknown                        | Unknown               | Unknown    | Unknown        | Unknown             | Unknown                | Unknown               | Official verification required | Human Review   | R0_Unreviewed   | TBD                | TBD   | TBD           |
| Other Major POS Providers TBD | Unknown                   | Unknown              | Unknown      | Unknown      | Unknown      | Unknown               | Unknown        | Unknown | Unknown    | Unknown   | Unknown    | Unknown     | Unknown       | Unknown | Unknown | Unknown                       | Unknown                        | Unknown               | Unknown    | Unknown        | Unknown             | Unknown                | Unknown               | Provider list not finalized    | Research       | R0_Unreviewed   | TBD                | TBD   | TBD           |

## 11. Minimum Official Support Criteria

A provider may be marked `Official` only when all required criteria are satisfied.

Required criteria:

* official API or official provider-approved integration boundary exists
* provider capability has been documented
* adapter contract can be satisfied
* order creation behavior is verified
* payment behavior is verified or explicitly separated
* cancellation behavior is verified
* refund behavior is verified or explicitly unsupported
* receipt or transaction ID behavior is verified
* idempotency or duplicate prevention plan exists
* timeout behavior is tested
* retry behavior is tested
* reconciliation path exists
* evidence fields are available
* manual recovery path exists
* sandbox or controlled test evidence exists
* field test evidence exists if required
* security and credential boundary is approved
* support limitation is documented
* release approval is granted

If any required criterion is missing, the provider must not be marked `Official`.

## 12. Candidate Provider Criteria

A provider may be marked `Candidate` when:

* official boundary appears possible
* provider documents or contacts are available
* adapter contract appears feasible
* key capabilities are not yet fully tested
* production support is not yet approved
* known limitations are still under review

Candidate providers must not be marketed as officially supported.

## 13. Limited Provider Criteria

A provider may be marked `Limited` when:

* some core capabilities are verified
* some capabilities are missing or manual
* support scope is explicitly restricted
* unsupported operations are documented
* customer-facing promise is limited
* recovery and reconciliation risks are understood
* human approval accepts the limited scope

Examples:

```text
Order create supported, but refund unsupported.
Menu sync supported, but sold-out sync unsupported.
Cloud integration unavailable, local-only integration required.
Webhook unavailable, polling required.
Idempotency unsupported, gateway duplicate prevention required.
```

## 14. Research Provider Criteria

A provider remains `Research` when:

* official API status is unknown
* commercial contact is not confirmed
* provider documents are missing
* sandbox is unavailable or not reviewed
* capability evidence is missing
* adapter feasibility is unknown
* support risks are not understood

Research providers must not be used in production.

## 15. Unsupported Provider Criteria

A provider must be marked `Unsupported` when:

* no official or approved integration boundary exists
* integration requires scraping
* integration requires reverse engineering
* integration requires undocumented bypass
* integration cannot preserve required evidence
* integration cannot prevent duplicate financial or order risk
* integration violates security boundary
* provider contract prohibits required use
* recovery or reconciliation is not feasible
* human review rejects support

Unsupported providers must not be represented as supported.

## 16. Human Review Criteria

Use `Human Review` when:

* evidence is incomplete
* official boundary is unclear
* provider claims conflict with test results
* capability differs by store contract
* local integration risk is unclear
* payment behavior is unclear
* refund behavior is unclear
* provider limitation affects customer promise
* support status change may affect release, sales, or operations

Human review must produce a recorded decision.

## 17. Evidence Requirements

Each provider status change must have evidence.

Evidence may include:

* official provider document reference
* provider email or contract reference
* sandbox credential confirmation
* sandbox test report
* adapter test report
* field test report
* transaction evidence packet
* reconciliation report
* recovery test report
* limitation review
* security review
* human approval record

A provider capability row without evidence must remain conservative.

## 18. Relationship To Adapter Contract

This matrix must be used by:

```text
000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md
```

If a provider lacks capability required by the adapter contract, the adapter must return:

```text
unsupported
```

or:

```text
manual_review_required
```

or:

```text
recovery_required
```

depending on the operation and risk.

The adapter must not hide unsupported capability behind fake success.

## 19. Relationship To State Machine

This matrix must be used by:

```text
000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md
```

If a provider cannot distinguish order success, payment success, POS success, KDS success, cancellation success, or refund success, the state machine must preserve uncertainty.

Provider capability limitation must not collapse state machine accuracy.

## 20. Relationship To Outsourcing Documents

The vendor-facing outsourcing package under:

```text
docs/000900_outsourcing_vendor_handoff_and_acceptance/
```

must use this matrix as the upstream capability standard.

Vendors may investigate provider capabilities.

Vendors may fill evidence.

Vendors may propose status changes.

Vendors must not independently declare official support.

Final support status requires internal human approval.

## 21. Provider Status Change Process

Provider status changes must follow this process.

```text
Research
  -> Human Review
  -> Candidate
  -> Limited or Official
```

or:

```text
Research
  -> Human Review
  -> Unsupported
```

A provider may move backward when:

* provider API changes
* contract changes
* support behavior changes
* test evidence fails
* recovery fails
* reconciliation fails
* security risk appears
* customer impact is unacceptable

## 22. Matrix Maintenance Rules

This matrix must be updated when:

* new provider is investigated
* provider API document is obtained
* sandbox access is granted
* provider test is completed
* field test is completed
* support status changes
* provider limitation is discovered
* official API changes
* provider deprecates a feature
* incident reveals capability mismatch
* vendor delivers provider capability evidence

Do not update capability values without evidence.

## 23. Anti-Patterns

The following are prohibited:

* marking a provider `Official` without evidence
* treating technical workaround as official API
* marking scraping as integration support
* ignoring refund limitation
* ignoring idempotency limitation
* ignoring reconciliation limitation
* hiding local-only integration risk
* presenting research provider as supported
* allowing vendor to decide support status alone
* treating payment support as order support
* treating POS order support as KDS support
* treating menu sync as sold-out sync
* treating sandbox success as production support without approval

## 24. Acceptance Criteria

This matrix is acceptable only if it confirms that:

* provider support is evidence-based
* official support is not assumed
* OKPOS and Toss POS are not automatically marked official without evidence
* unsupported or unknown capability remains visible
* status values are controlled
* readiness levels are defined
* capability fields are clear
* outsourcing vendors cannot independently declare support
* provider limitation feeds adapter, state machine, recovery, reconciliation, and evidence rules
* no implementation is authorized by this document

## 25. Final Rule

```text
A POS provider is not supported because it is famous, common, technically reachable, or requested by a store.
A POS provider is supported only when its official boundary, capability, evidence, recovery, reconciliation, security, and release readiness are approved.
```
