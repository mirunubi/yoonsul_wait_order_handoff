# 004350_Policy_POS_Adapter_Test_Harness_And_Certification_Scenario

## **1\. Purpose**

This document defines the POS adapter test harness and certification scenario policy.

The purpose of this policy is to ensure that each POS provider adapter is tested, simulated, replayed, and certified before it is trusted in store operation.

Multi-POS integration must not rely only on successful happy-path testing.

Each adapter must be tested against order creation, payment status changes, cancellation, duplicate events, delayed events, mapping failures, provider outage, KDS release blocking, manual fallback, and reconciliation scenarios.

---

## **2\. Scope**

This policy applies to:

* POS adapter test harness
* Provider event simulation
* Payment webhook simulation
* KDS release simulation
* Customer display projection simulation
* Canonical order model validation
* Error code validation
* Idempotency testing
* Replay testing
* Conflict testing
* Capability level certification
* Store pilot readiness testing
* Vendor adapter certification scenario

This policy does not define commercial vendor certification terms, legal partnership approval, production SLA, refund approval, settlement allocation, or tax reporting.

---

## **3\. Core Principle**

An adapter is not ready because one order succeeded.

An adapter is ready only when its failure behavior is predictable.

The core principle is:

happy path proves possibility
failure path proves readiness
replay proves recoverability
audit proves trust

Every adapter must be tested not only for integration success but also for operational survival.

---

## **4\. Test Harness Definition**

A POS adapter test harness is a controlled environment that can simulate provider events and verify internal system behavior.

The harness should support:

provider payload input
webhook event input
polling response simulation
order lifecycle simulation
payment lifecycle simulation
KDS release simulation
customer display projection check
audit event verification
error code verification
replay verification
reconciliation verification

The test harness must be able to run without affecting production stores.

---

## **5\. Certification Levels**

Adapter certification may follow levels aligned with integration capability.

Allowed certification levels include:

CERT\_0\_MANUAL\_READY
CERT\_1\_READ\_ONLY\_READY
CERT\_2\_EVENT\_SYNC\_READY
CERT\_3\_AUTHORITY\_READY
CERT\_4\_DEEP\_INTEGRATION\_READY

Certification level must not exceed the adapter capability level.

Example:

LEVEL\_1\_READ\_ONLY\_INTAKE cannot receive CERT\_3\_AUTHORITY\_READY

---

## **6\. Test Environment Requirement**

Each adapter should have a test environment.

Possible test environment types include:

provider sandbox
provider test merchant
mock provider server
recorded payload replay
manual fixture input
store pilot shadow mode

If a provider has no sandbox, the adapter must be tested through mock and recorded payload replay before pilot use.

The absence of a sandbox must be recorded as a risk.

---

## **7\. Fixture Library**

The system should maintain a provider fixture library.

Fixture types may include:

normal order
order with modifiers
order with discount
order with tax
order with service charge
split table order
merged table order
canceled order
voided item
paid order
failed payment
partial payment
duplicate event
delayed event
malformed payload
unknown item
unknown table
provider outage response

Fixtures should be versioned by provider and payload version.

---

## **8\. Happy Path Scenario**

Each adapter must pass the happy path scenario.

Minimum happy path:

1\. Provider order event is received.
2\. Raw payload is preserved.
3\. Provider identity is captured.
4\. Event is normalized.
5\. Canonical order is created.
6\. Items are mapped.
7\. Amount is calculated.
8\. Payment state is mapped.
9\. KDS projection is created.
10\. Audit events are created.

Passing the happy path does not certify production readiness by itself.

---

## **9\. Payment-To-KDS Scenario**

Each payment-capable adapter must pass payment-to-KDS testing.

Scenario:

1\. Order is created.
2\. Payment request or payment status is received.
3\. Payment status is verified or mapped.
4\. Payment Runtime emits verified payment state.
5\. KDS release becomes eligible.
6\. KDS release event is created.
7\. Customer display shows payment complete.
8\. Audit trail links order, payment, and KDS release.

If payment is uncertain, KDS must not be released normally.

---

## **10\. Payment Failure Scenario**

Each payment-capable adapter must test payment failure.

Scenario:

1\. Order is created.
2\. Payment attempt fails.
3\. Payment state becomes PAYMENT\_FAILED.
4\. Customer display shows retry or staff help.
5\. KDS remains in WAITING\_PAYMENT or PAYMENT\_HOLD.
6\. Audit event is created.

The adapter must not release KDS on failed payment.

---

## **11\. Payment Timeout Scenario**

Each adapter must test payment timeout.

Scenario:

1\. Payment request is created.
2\. No payment confirmation arrives within timeout.
3\. Payment state becomes PAYMENT\_TIMEOUT or PAYMENT\_EXPIRED.
4\. QR or payment request is no longer valid.
5\. Customer display asks retry.
6\. KDS remains blocked.
7\. Audit event is created.

Expired payment requests must not be reused silently.

---

## **12\. Duplicate Webhook Scenario**

Each webhook-capable adapter must test duplicate webhook handling.

Scenario:

1\. Provider sends payment or order webhook.
2\. System processes it once.
3\. Provider sends identical webhook again.
4\. System identifies duplicate.
5\. Duplicate event is ignored or marked already processed.
6\. No duplicate order is created.
7\. No duplicate KDS release is created.
8\. Audit records duplicate handling.

Expected diagnostic code example:

POSADP-WEBHOOK-006 duplicate provider event ignored

---

## **13\. Duplicate Order Scenario**

Each order adapter must test duplicate order handling.

Scenario:

1\. Provider sends order event.
2\. Internal order is created.
3\. Provider sends same order again with same external\_order\_id.
4\. System maps it to existing internal\_order\_id.
5\. Duplicate internal order is not created.
6\. Audit event records duplicate handling.

Expected diagnostic code example:

POSADP-DUPLICATE-001 duplicate external order detected

---

## **14\. Amount Mismatch Scenario**

Each payment adapter must test amount mismatch.

Scenario:

1\. Order total is 18,000.
2\. Payment event reports 17,000 or 19,000.
3\. System marks PAYMENT\_AMOUNT\_MISMATCH.
4\. KDS release is blocked or held.
5\. Store display shows staff confirmation required.
6\. Reconciliation case is created.

Expected diagnostic code example:

POSADP-PAY-003 payment amount mismatch

---

## **15\. Unknown Item Mapping Scenario**

Each order adapter must test unknown item mapping.

Scenario:

1\. Provider order includes external item not mapped internally.
2\. System creates canonical order with item mapping warning.
3\. Item is marked UNKNOWN\_EXTERNAL\_ITEM or ITEM\_MAPPING\_REQUIRED.
4\. KDS behavior follows store policy.
5\. Audit event is created.

Expected diagnostic code example:

POSADP-MAP-001 unknown external item

---

## **16\. Modifier Mapping Scenario**

Each food-service POS adapter must test modifier mapping.

Scenario:

1\. Provider order includes base item and modifiers.
2\. Modifier is normalized separately from base item.
3\. Kitchen-impacting modifier appears in KDS projection.
4\. Price-impacting modifier appears in amount calculation.
5\. Unknown modifier is flagged.

Modifiers must not be silently dropped.

---

## **17\. Table Reference Scenario**

Each table-capable adapter must test table reference handling.

Scenario:

1\. Provider order includes table reference.
2\. Table maps to internal table or seating session.
3\. Customer display and KDS show correct table reference.
4\. Ambiguous table reference is flagged.
5\. Table move event does not corrupt payment or kitchen state.

Expected diagnostic code example:

POSADP-TABLE-002 table reference ambiguous

---

## **18\. Cancellation Before Kitchen Release Scenario**

Each adapter must test cancellation before KDS release.

Scenario:

1\. Order is created.
2\. Order is canceled before KDS release.
3\. KDS release is blocked.
4\. Customer display and staff display update.
5\. Audit event is created.

Cancellation must not be collapsed with refund approval.

---

## **19\. Cancellation After Kitchen Release Scenario**

Each adapter must test cancellation after kitchen release.

Scenario:

1\. Order is created and released to KDS.
2\. Kitchen starts preparation.
3\. POS cancellation event arrives.
4\. System marks kitchen cancellation review required.
5\. Waste, remake, customer recovery, or refund policies may be triggered separately.
6\. Original kitchen release remains auditable.

Expected diagnostic code example:

POSADP-ORDER-006 order cancellation received after kitchen release

---

## **20\. Out-Of-Order Event Scenario**

Each event-sync adapter must test out-of-order events.

Scenario:

1\. Provider sends order update before order created event.
2\. System detects chronology uncertainty.
3\. Raw events are preserved.
4\. System does not overwrite verified newer state.
5\. Reconciliation or replay may be required.

Expected diagnostic code example:

POSADP-TIME-003 event chronology uncertain

---

## **21\. Provider Outage Scenario**

Each adapter must test provider outage behavior.

Scenario:

1\. Provider API or webhook becomes unavailable.
2\. System marks provider unavailable or delayed.
3\. Capability may be downgraded.
4\. Store fallback path becomes visible.
5\. KDS release and payment authority are protected.
6\. Audit event is created.

Expected diagnostic code example:

POSADP-PROVIDER-001 provider unavailable

---

## **22\. Capability Downgrade Scenario**

Each adapter must test capability downgrade.

Scenario:

1\. Adapter normally runs at Level 2\.
2\. Webhook verification fails.
3\. Adapter is downgraded to read-only, polling, or manual mode.
4\. Authority-sensitive actions are blocked.
5\. Store and support views show degraded capability.
6\. Audit event is created.

Expected diagnostic code example:

POSADP-CAP-004 integration capability downgraded

---

## **23\. Manual Fallback Scenario**

Each adapter must test manual fallback.

Scenario:

1\. Provider integration fails.
2\. Store uses manual order or payment confirmation.
3\. Manual fallback is marked FALLBACK\_ORIGINATED.
4\. Evidence packet is created.
5\. Reconciliation is required.
6\. Normal state is not silently restored without audit.

Expected diagnostic code example:

POSADP-FALLBACK-001 fallback mode activated

---

## **24\. Replay Scenario**

Each adapter must test replay.

Scenario:

1\. Raw provider events are replayed.
2\. Canonical order projection is rebuilt.
3\. Replay does not mutate original source events.
4\. Projection differences are detected.
5\. Audit records replay result.

Expected diagnostic code example:

POSADP-REPLAY-010 replay must not mutate source events

---

## **25\. Security Scenario**

Each adapter must test credential and webhook security.

Scenarios should include:

invalid webhook signature
missing webhook secret
expired credential
insufficient permission
wrong tenant credential
production credential used in test mode

The adapter must reject untrusted events and preserve safe audit context.

Expected diagnostic code example:

POSADP-SECURITY-004 webhook signature invalid

---

## **26\. Audit Completeness Scenario**

Each adapter must test audit completeness.

Scenario:

1\. Provider event is received.
2\. Normalization occurs.
3\. Payment or KDS state changes.
4\. Audit events are written for each authority-sensitive transition.
5\. Audit chain can link provider event to internal order and runtime state.

If an authority-sensitive action occurs without audit, certification must fail.

Expected diagnostic code example:

POSADP-AUDIT-006 authority action without audit event

---

## **27\. Certification Pass Criteria**

An adapter may pass certification only when:

happy path passes
payment failure is safe
timeout is safe
duplicate events are idempotent
amount mismatch blocks unsafe release
unknown item mapping is flagged
table ambiguity is flagged
out-of-order events are detected
provider outage triggers downgrade or fallback
manual fallback creates evidence
replay preserves source truth
audit chain is complete
error codes are emitted consistently

Certification must be level-specific.

A Level 1 adapter does not need to pass Level 3 write-back tests.

---

## **28\. Certification Failure Criteria**

Certification must fail if:

duplicate provider event creates duplicate order
duplicate payment creates duplicate KDS release
payment failure releases KDS normally
amount mismatch is treated as paid
unknown item is silently dropped
manual confirmation becomes verified payment without reconciliation
adapter writes to POS without contract
customer display shows payment complete before verification
audit event is missing for authority transition
replay rewrites source events

Failure should create a certification report.

---

## **29\. Test Result Record**

Each test run should create a test result record.

Required fields include:

test\_run\_id
adapter\_name
adapter\_version
provider\_name
provider\_payload\_version
capability\_level
certification\_level\_target
scenario\_id
scenario\_name
result
failed\_step
error\_code
evidence\_reference
executed\_at
executed\_by
notes

Test result records must be preserved for adapter history.

---

## **30\. Scenario ID Convention**

Certification scenarios should use stable scenario IDs.

Recommended format:

POSCERT-{DOMAIN}-{NUMBER}

Examples:

POSCERT-ORDER-001
POSCERT-PAY-001
POSCERT-KDS-001
POSCERT-WEBHOOK-001
POSCERT-MAP-001
POSCERT-TIME-001
POSCERT-FALLBACK-001
POSCERT-REPLAY-001

Scenario IDs must remain stable across adapter versions.

---

## **31\. Regression Testing Rule**

When an adapter changes, regression tests must run.

Regression triggers include:

adapter version change
provider payload version change
mapping rule change
canonical model change
payment status mapping change
KDS release policy change
error code policy change
capability level change
security credential change

Regression failure must block production promotion when authority-sensitive behavior is affected.

---

## **32\. Store Pilot Readiness**

Before store pilot, the adapter must satisfy pilot readiness.

Minimum pilot readiness:

capability level assigned
integration contract recorded
happy path passed
payment failure passed
duplicate event passed
manual fallback path passed
audit chain passed
store-facing messages reviewed
rollback plan exists
support contact defined

A pilot is not a replacement for certification.

Pilot tests real-world behavior after controlled scenarios pass.

---

## **33\. Shadow Mode Rule**

Adapters may run in shadow mode before active use.

Shadow mode means:

provider events are received
canonical projections are created
errors are logged
audit records are created
but no authority-sensitive action is executed

Shadow mode is useful for comparing internal projection with real POS/KDS behavior.

Shadow mode must be clearly marked.

---

## **34\. Production Promotion Rule**

An adapter may move to production only when:

required certification scenarios pass
security review passes
capability level is assigned
store-level configuration is complete
fallback policy is defined
audit path is verified
monitoring is enabled
rollback plan is available

Production promotion must be auditable.

---

## **35\. Rollback Rule**

Every adapter deployment must have rollback criteria.

Rollback triggers include:

duplicate order creation
duplicate KDS release
payment status conflict rate above threshold
mapping failure spike
provider credential failure
webhook verification failure
unresolved authority error
store operation disruption

Rollback must preserve audit and raw payload history.

Rollback must not delete evidence of failed deployment.

---

## **36\. Monitoring Link**

Certification scenarios should map to production monitoring.

Example:

duplicate webhook test
        ↓
production duplicate webhook metric

amount mismatch test
        ↓
production payment mismatch metric

provider outage test
        ↓
production provider health alert

A test scenario that cannot be monitored in production may be incomplete.

---

## **37\. MVP Cutline**

For MVP, the test harness should support:

mock provider payload input
canonical order validation
basic payment status validation
duplicate event test
amount mismatch test
unknown item mapping test
webhook delay test
provider outage test
manual fallback test
audit completeness test
basic replay test
test result record

Excluded from MVP:

full vendor certification portal
automatic provider sandbox provisioning
AI-generated test cases
large-scale load testing
multi-store chaos testing
formal third-party certification
automatic adapter code generation
advanced compliance evidence pack

---

## **38\. Relationship To 04300, 04310, 04320, 04330, And 04340**

Document 04300 defines the POS Provider Abstraction and Multi-POS Adapter boundary.

Document 04310 defines the Canonical Order Model and POS Event Normalization policy.

Document 04320 defines POS Adapter Capability Level and Integration Contract policy.

Document 04330 defines POS Adapter Error Code and Diagnostic Message policy.

Document 04340 defines POS Vendor Priority and Integration Roadmap policy.

This document defines how adapters are tested and certified before they are trusted.

The relationship is:

04300 \= adapter architecture
04310 \= canonical model
04320 \= capability and contract
04330 \= diagnostic language
04340 \= vendor priority roadmap
04350 \= test harness and certification scenarios

---

## **39\. Patent And SaaS Relevance**

This policy supports SaaS scalability because each new POS integration can be tested through a repeatable certification framework.

The strategic structure is:

new POS provider
        ↓
adapter implementation
        ↓
canonical model validation
        ↓
failure scenario testing
        ↓
error code verification
        ↓
audit and replay certification
        ↓
pilot readiness

This prevents the platform from becoming a collection of fragile one-off integrations.

The value is not only connecting to many POS providers.

The value is proving that each connection behaves safely under failure.

---

## **40\. Readiness Check**

This policy is ready when:

adapter test harness exists
provider fixtures are versioned
happy path scenario is defined
payment failure scenario is defined
timeout scenario is defined
duplicate webhook scenario is defined
amount mismatch scenario is defined
unknown item scenario is defined
table ambiguity scenario is defined
provider outage scenario is defined
manual fallback scenario is defined
replay scenario is defined
audit completeness scenario is defined
certification pass and fail criteria are explicit
pilot readiness criteria are explicit

---

## **41\. Summary**

A POS adapter is not safe because it works once.

A POS adapter is safe when it fails predictably.

The system must test:

normal order
failed payment
delayed webhook
duplicate event
amount mismatch
unknown item
table ambiguity
provider outage
manual fallback
replay
audit

before trusting an adapter in store operation.

This test harness and certification policy is what allows the platform to scale from one POS integration to many without losing operational control.
