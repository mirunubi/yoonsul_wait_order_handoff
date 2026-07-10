# 000810_Guide_POS_Integration_Test_Sandbox_Mock_And_Field_Verification_Context.md

## 1. Purpose

This document defines the test, sandbox, mock, simulation, and field verification context for POS Gateway and provider adapter integration.

The purpose is to prevent POS integration from being accepted only because one happy-path order appears to work.

POS integration must be tested against normal flow, timeout, retry, duplicate prevention, unknown state, recovery, reconciliation, manual operation, degraded mode, and evidence requirements.

This document is a test context guide.

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
```

This guide must not redefine upstream authority, state, provider boundary, retry, recovery, reconciliation, or evidence rules.

## 3. Core Rule

```text
A POS integration is not test-complete because a normal order succeeds once.
A POS integration is test-ready only when normal, failure, duplicate, timeout, unknown, recovery, reconciliation, degraded mode, and evidence scenarios are verified.
```

Testing must prove that the integration can fail safely.

## 4. Scope

This guide covers:

* sandbox testing
* mock provider testing
* local failure simulation
* network interruption simulation
* timeout simulation
* duplicate request simulation
* payment/POS split-brain testing
* POS/KDS split-brain testing
* refund unknown testing
* cancel failure testing
* menu sync testing
* sold-out sync testing
* provider unavailable testing
* degraded mode testing
* field verification
* evidence capture
* test approval
* production readiness separation

## 5. Non-Scope

This guide does not define:

* test automation source code
* provider-specific implementation code
* Flutter UI implementation
* SQL schema
* Supabase RLS
* production deployment
* real production payment approval
* final provider certification
* final commercial launch approval

Those require separate implementation, verification, release, and commercial approval documents.

## 6. Test Environment Types

The following environments must be distinguished.

| Environment          | Purpose                                                     |
| -------------------- | ----------------------------------------------------------- |
| `mock`               | Simulate provider behavior without real provider dependency |
| `sandbox`            | Use provider-approved test environment                      |
| `staging`            | Internal end-to-end test environment                        |
| `field_test`         | Controlled real-store or near-real-store verification       |
| `production_limited` | Restricted production verification after approval           |
| `production`         | Normal production operation after release approval          |

A test result from one environment must not be treated as proof for all environments.

## 7. Mock Provider Testing

Mock provider testing is used before real provider integration.

Mock tests must simulate:

* normal success
* validation failure
* provider timeout
* provider unavailable
* delayed response
* duplicate response
* conflicting response
* rate limit
* unsupported operation
* unknown result
* partial success
* malformed response
* missing receipt ID
* missing transaction ID

Mock provider must be used to test POS Gateway logic before provider-specific behavior is trusted.

## 8. Sandbox Testing

Sandbox testing is used when the POS provider offers an official or approved test environment.

Sandbox tests must verify:

* authentication
* order creation
* order update where supported
* order cancellation where supported
* payment authorization where supported
* payment cancellation where supported
* refund where supported
* receipt ID behavior
* provider transaction ID behavior
* menu sync where supported
* sold-out sync where supported
* webhook behavior where supported
* polling behavior where required
* timeout behavior where possible
* error response behavior
* rate limit behavior where possible

Sandbox success must not automatically mean production support.

## 9. Staging End-To-End Testing

Staging testing must verify cross-runtime behavior.

Required staging flows:

* customer order request
* store acceptance where applicable
* payment state
* POS Gateway event
* provider adapter result
* KDS display
* DID callout
* cancellation
* refund
* recovery
* reconciliation
* evidence packet generation
* customer-facing status safety

Staging must verify that state transitions match `000803`.

## 10. Field Verification

Field verification is controlled real-store or near-real-store testing.

Field verification must not begin until:

* internal readiness checklist is approved
* provider boundary is understood
* sandbox or mock tests are complete enough
* evidence capture is ready
* manual fallback is ready
* staff knows what to do when failure occurs
* payment risk controls are approved
* human reviewer is assigned
* rollback or channel pause condition is defined

Field verification must start with limited scope.

## 11. Production Readiness Separation

The following must be separated:

```text
Sandbox success
Field test success
Production readiness
Official support
Commercial launch
```

A provider may pass sandbox testing but still fail field verification.

A provider may pass field verification but still remain limited support.

A provider may be technically working but not commercially approved.

## 12. Normal Flow Test Cases

Normal flow tests must include:

| Test Case                 | Expected Evidence                          |
| ------------------------- | ------------------------------------------ |
| Order request created     | Order event evidence                       |
| Store accepted            | Store acceptance evidence where applicable |
| Payment authorized        | Payment evidence                           |
| POS order created         | POS provider evidence                      |
| KDS displayed             | KDS evidence                               |
| Preparing                 | Kitchen state evidence                     |
| Ready                     | Ready state evidence                       |
| DID callout done          | DID evidence                               |
| Completed                 | Final state evidence                       |
| Evidence packet generated | Complete evidence packet                   |

Normal flow is necessary but not sufficient.

## 13. Payment/POS Split-Brain Tests

Test cases must include:

| Scenario                                       | Expected Route                                    |
| ---------------------------------------------- | ------------------------------------------------- |
| Payment succeeds but POS order fails           | recovery_required and manual_review_required      |
| Payment succeeds but POS order unknown         | reconciliation_required                           |
| Payment fails but POS order created            | manual_review_required                            |
| Payment unknown after timeout                  | reconciliation_required or manual_review_required |
| Payment cancel succeeds but order cancel fails | manual_review_required                            |
| Refund unknown after timeout                   | reconciliation_required                           |

These tests must prove that payment success and order success are not collapsed.

## 14. POS/KDS/DID Split-Brain Tests

Test cases must include:

| Scenario                                   | Expected Route                      |
| ------------------------------------------ | ----------------------------------- |
| POS order confirmed but KDS display failed | recovery_required                   |
| KDS displayed but POS status unknown       | reconciliation_required             |
| KDS preparing but cancellation requested   | manual_review_required              |
| Order ready but DID callout failed         | recovery_required or manual callout |
| DID callout done but pickup not confirmed  | customer-facing caution             |

These tests must prove that POS, KDS, and DID states remain separate.

## 15. Timeout Tests

Timeout tests must include:

* pre-submit timeout
* submit-unknown timeout
* post-submit timeout
* provider processing timeout
* callback timeout
* status query timeout
* recovery timeout
* refund timeout
* payment timeout

Each timeout test must verify:

* timeout type is recorded
* result is not blindly marked failed
* unknown state is preserved where required
* retry eligibility is classified
* evidence is generated
* reconciliation or manual review is triggered when needed

## 16. Retry Tests

Retry tests must include:

* safe read-only retry
* idempotent order retry
* idempotent cancellation retry
* idempotent refund retry where supported
* unsafe retry blocked
* retry count increment
* retry window exhausted
* rate-limit-aware retry
* circuit breaker trigger
* retry storm prevention

Retry tests must prove that unsafe retry is blocked.

## 17. Duplicate Prevention Tests

Duplicate prevention tests must include:

* duplicate order request
* duplicate POS order creation
* duplicate payment authorization
* duplicate payment cancellation
* duplicate refund
* duplicate cancellation
* duplicate KDS display event
* duplicate DID callout
* duplicate menu sync mutation
* duplicate sold-out update
* duplicate recovery action

Each duplicate test must produce duplicate evidence.

## 18. Unknown State Tests

Unknown state tests must include:

* payment unknown
* POS order unknown
* cancel unknown
* refund unknown
* provider unknown
* webhook late arrival
* polling conflict
* response after manual recovery
* provider response missing key identifier

Unknown state tests must prove that unknown is not treated as success or failure without evidence.

## 19. Provider Unavailable Tests

Provider unavailable tests must include:

* provider API outage
* local connector unavailable
* authentication failure
* rate limit
* provider maintenance
* network failure
* adapter failure

Expected behavior:

* unsafe state-changing operations stop
* evidence is preserved
* degraded mode is evaluated
* manual operation path is available where approved
* reconciliation is required after recovery

## 20. Menu Sync Tests

Menu sync tests must include:

* menu item create/update
* price update
* option update
* category update
* provider unsupported field
* partial sync failure
* stale menu version
* POS/CMS/app/kiosk mismatch

Expected behavior:

* affected item list is recorded
* customer ordering risk is classified
* manual hide or correction path is available
* provider limitation updates capability matrix where needed

## 21. Sold-Out And Availability Tests

Sold-out and availability tests must include:

* item sold out
* item restored
* option sold out
* availability partial failure
* stale availability
* manual staff override
* provider does not support sold-out sync
* customer orders sold-out item

Expected behavior:

* availability evidence is recorded
* affected customer/order risk is classified
* manual correction path exists
* reconciliation is triggered where needed

## 22. Recovery Tests

Recovery tests must include:

* manual POS entry after POS failure
* KDS resend after KDS failure
* manual kitchen ticket
* manual DID callout
* refund review
* cancellation review
* payment/POS reconciliation
* duplicate correction
* manual order linkage to POS receipt

Recovery tests must verify:

* original failure evidence is preserved
* recovery evidence is created
* reconciliation follows recovery
* human approval is recorded where required

## 23. Degraded Mode Tests

Degraded mode tests must include:

| Level                  | Test                                       |
| ---------------------- | ------------------------------------------ |
| D1_Minor_Degraded      | DID failure with manual callout            |
| D2_Channel_Limited     | Kiosk or mobile ordering paused            |
| D3_Manual_Operation    | Manual POS entry and manual kitchen ticket |
| D4_Financial_Risk_Lock | Refund or payment action blocked           |
| D5_Safe_Closure        | Channel or store closure decision          |

Degraded mode tests must verify:

* level is recorded
* allowed operations are recorded
* blocked operations are recorded
* exit condition is recorded
* exit is not allowed without reconciliation

## 24. Evidence Capture Tests

Every test must verify evidence capture.

Evidence tests must verify:

* evidence ID
* correlation ID
* tenant ID
* store ID
* order ID
* payment ID where applicable
* POS provider ID
* adapter version
* idempotency key
* retry count
* timeout type
* duplicate risk
* state transition
* recovery result
* reconciliation result
* human review result where applicable
* masking status
* approval status

Evidence must follow `000808`.

## 25. Test Approval Rules

A test case is approved only when:

* expected state transition occurred
* required evidence was generated
* no unsupported shortcut was used
* no scraping or unofficial bypass was used
* no production credentials were used
* no unrelated files were modified
* failure behavior was safe
* recovery and reconciliation were possible
* reviewer approved the result

A test may pass with limitations only if limitations are documented.

## 26. Test Result Status Values

Allowed test result statuses:

| Status                    | Meaning                              |
| ------------------------- | ------------------------------------ |
| `Passed`                  | Test passed with required evidence   |
| `Passed_With_Limitations` | Test passed but limitation remains   |
| `Failed`                  | Test failed                          |
| `Blocked`                 | Test could not run due to dependency |
| `Not_Run`                 | Test has not been executed           |
| `Human_Review_Required`   | Result requires human decision       |
| `Rejected`                | Test result is unacceptable          |

Do not use informal statuses such as "seems okay".

## 27. Test Report Template

Use the following structure for each test report.

```yaml
test_case_id: TBD
test_name: TBD
test_environment: TBD
provider: TBD
adapter_version: TBD
store_id: TBD
tenant_id: TBD
scenario_type: TBD

preconditions:
  provider_status: TBD
  sandbox_available: TBD
  mock_enabled: TBD
  payment_mode: TBD
  KDS_available: TBD
  DID_available: TBD

execution:
  started_at: TBD
  completed_at: TBD
  actor: TBD
  steps: TBD

expected_result:
  expected_state: TBD
  expected_evidence: TBD
  expected_recovery: TBD
  expected_reconciliation: TBD

actual_result:
  actual_state: TBD
  actual_evidence_id: TBD
  actual_recovery: TBD
  actual_reconciliation: TBD
  unexpected_behavior: TBD

decision:
  test_status: TBD
  limitation: TBD
  reviewer: TBD
  approval_status: TBD
  follow_up_required: TBD
```

## 28. Relationship To 000900 Outsourcing Package

The outsourcing package under:

```text
docs/000900_outsourcing_vendor_handoff_and_acceptance/
```

must require vendors to produce test results compatible with this guide.

Vendor deliverables must include:

* sandbox test report where sandbox exists
* mock test report where provider behavior must be simulated
* failure scenario test evidence
* duplicate prevention test evidence
* timeout test evidence
* retry test evidence
* recovery test evidence
* reconciliation test evidence
* known limitations
* final handoff readiness statement

A vendor cannot satisfy POS integration acceptance with only happy-path screenshots.

## 29. Blocking Conditions

Testing or field verification must be blocked when:

* official provider boundary is unknown
* scraping or unofficial bypass is proposed
* credential boundary is unclear
* production credentials are requested too early
* idempotency is missing
* duplicate payment prevention is missing
* timeout behavior is undefined
* evidence template is not ready
* recovery runbook is not ready
* reconciliation path is not ready
* manual fallback is not ready
* human reviewer is not assigned
* rollback or pause condition is not defined

## 30. Anti-Patterns

The following are prohibited:

* accepting one successful order as integration readiness
* skipping failure tests
* skipping duplicate payment tests
* skipping refund unknown tests
* skipping timeout tests
* skipping KDS failure tests
* skipping evidence review
* testing with production credentials without approval
* field testing without manual fallback
* claiming production readiness from sandbox only
* allowing vendor to define test success criteria alone
* hiding known provider limitation
* accepting screenshots without structured evidence

## 31. Acceptance Criteria

This guide is acceptable only if it confirms that:

* sandbox, mock, staging, field, and production readiness are separated
* normal flow testing is not enough
* split-brain tests are required
* timeout tests are required
* retry tests are required
* duplicate prevention tests are required
* unknown state tests are required
* provider unavailable tests are required
* menu and sold-out tests are required
* recovery and degraded mode tests are required
* evidence capture is required for every critical test
* vendor test reports must follow this standard
* no implementation is authorized by this document

## 32. Final Rule

```text
A POS integration test is not successful because the provider returned success once.
A POS integration test is successful only when the system can prove correct behavior, safe failure, recoverability, reconciliation, evidence capture, and approved limitations.
```
