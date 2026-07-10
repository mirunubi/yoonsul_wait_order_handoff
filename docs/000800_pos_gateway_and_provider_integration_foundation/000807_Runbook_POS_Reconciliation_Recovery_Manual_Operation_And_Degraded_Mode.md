# 000807_Runbook_POS_Reconciliation_Recovery_Manual_Operation_And_Degraded_Mode.md

## 1. Purpose

This document defines the operational runbook for POS reconciliation, recovery, manual operation, and degraded mode.

The purpose is to provide controlled operational actions when POS Gateway, provider adapter, payment runtime, KDS, DID, menu sync, or network conditions are degraded, failed, duplicated, or unknown.

This document turns the logic defined in the POS Gateway foundation into practical operational response steps.

This is a runbook document.

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
```

This runbook must not override the authority boundary, adapter contract, state machine, provider capability matrix, official API policy, or retry/idempotency logic.

## 3. Core Rule

```text
Continue if safe.
Limit if necessary.
Close safely if unsafe.
```

A failed POS integration must not automatically stop store operation.

However, store operation must not continue in a way that creates uncontrolled money risk, duplicate order risk, kitchen confusion, customer deception, or unrecoverable audit gaps.

## 4. Scope

This runbook covers:

* payment success but POS order failure
* POS order success but KDS display failure
* kiosk order duplication
* payment duplication
* POS timeout
* provider unavailable
* refund unknown
* cancel failed
* menu sync mismatch
* sold-out sync mismatch
* internet failure
* local fallback
* manual order recovery
* reconciliation after recovery
* degraded mode activation
* escalation to human review
* evidence required for recovery

## 5. Non-Scope

This runbook does not define:

* actual adapter code
* payment provider SDK behavior
* provider-specific API payloads
* Flutter UI implementation
* SQL implementation
* Supabase RLS implementation
* legal refund policy
* final customer compensation policy
* production deployment authorization

Those belong to implementation, legal, support, and release documents.

## 6. Operational Roles

The following roles may participate in recovery.

| Role                  | Responsibility                                                                    |
| --------------------- | --------------------------------------------------------------------------------- |
| Store Staff           | Immediate store-side confirmation, kitchen communication, manual callout          |
| Store Manager         | Manual recovery approval, degraded mode decision, customer-facing correction      |
| Franchisee Owner      | Store-level operational responsibility and incident confirmation                  |
| Headquarters Operator | Multi-store support, policy interpretation, provider escalation coordination      |
| Technical Support     | System diagnostics, provider adapter evidence review, incident logging            |
| Payment Support       | Payment, cancellation, refund, and settlement verification                        |
| Platform Admin        | Production access control, provider support status, release or rollback decision  |
| Human Reviewer        | Final approval for high-risk recovery, refund, cancellation, or closure decisions |

The system may recommend.

Humans approve high-risk or irreversible actions.

## 7. Evidence Required Before Action

Before any recovery or manual correction, the operator must preserve or confirm available evidence.

Minimum evidence:

* order ID
* payment ID where applicable
* POS provider name
* POS adapter version where applicable
* POS order ID where available
* POS transaction ID where available
* receipt ID where available
* idempotency key
* correlation ID
* current internal state
* provider response or timeout classification
* retry count
* customer-facing status
* kitchen state
* KDS state
* DID state
* operator action
* timestamp
* recovery reason

No high-risk recovery may proceed without evidence.

## 8. General Triage Flow

Use the following general triage sequence.

```text
1. Identify the affected order, payment, provider, store, and runtime layer.
2. Freeze unsafe automatic retries if duplicate risk exists.
3. Preserve evidence.
4. Classify the issue.
5. Check payment state.
6. Check POS state.
7. Check KDS and kitchen state.
8. Check customer-facing status.
9. Decide whether operation can continue normally, continue in degraded mode, pause, or close safely.
10. Perform recovery or manual operation only when authority allows.
11. Reconcile after recovery.
12. Record final decision and unresolved limitation.
```

## 9. Degraded Mode Levels

Degraded mode must be explicit.

| Level                    | Meaning                                  | Example                                               |
| ------------------------ | ---------------------------------------- | ----------------------------------------------------- |
| `D0_Normal`              | Normal operation                         | POS Gateway, payment, KDS, DID operating normally     |
| `D1_Minor_Degraded`      | Non-critical function degraded           | DID callout unavailable, manual callout used          |
| `D2_Channel_Limited`     | One order channel limited                | Kiosk paused, counter ordering continues              |
| `D3_Manual_Operation`    | Staff handles affected flow manually     | Staff manually enters order into POS                  |
| `D4_Financial_Risk_Lock` | Money movement risk requires restriction | Refunds paused pending review                         |
| `D5_Safe_Closure`        | Store or channel must close safely       | Mobile ordering disabled due to unrecoverable failure |

The degraded mode level must be recorded in evidence.

## 10. Scenario: Payment Success But POS Order Failed

### Symptom

Payment is authorized or captured, but POS order creation failed.

### Likely Cause

* POS provider rejected order
* provider adapter failed after payment
* provider unavailable
* invalid menu item or option
* price mismatch
* local connector failure
* network interruption after payment

### Immediate Action

* do not mark order as completed
* do not retry POS order blindly
* confirm payment status
* preserve payment evidence
* preserve POS failure evidence
* mark order as `recovery_required` and `manual_review_required`

### Manual Operation Path

* manager reviews order details
* staff manually enters order into POS only if duplicate POS risk is controlled
* kitchen is notified through KDS fallback or manual ticket
* customer-facing status is updated cautiously

### Recovery Step

* verify payment authorization
* verify no POS order was created
* create manual POS entry if approved
* link manual POS receipt to internal order evidence
* mark recovery action as completed only after verification

### Reconciliation Step

* reconcile payment ID with POS receipt
* reconcile internal order with manual POS entry
* reconcile KDS/kitchen state
* flag unresolved mismatch if receipt is missing

### Evidence Required

* payment authorization evidence
* POS failure evidence
* idempotency key
* manual entry receipt
* manager approval
* recovery timestamp
* reconciliation result

### Escalation Condition

Escalate when:

* payment is confirmed but order cannot be fulfilled
* duplicate POS order risk exists
* refund may be required
* customer has already been promised completion
* evidence is incomplete

## 11. Scenario: POS Order Success But KDS Display Failed

### Symptom

POS confirms order, but kitchen display does not show it.

### Likely Cause

* KDS network issue
* station routing error
* KDS device offline
* KDS adapter failure
* order item station mapping missing
* local store network interruption

### Immediate Action

* do not assume kitchen received the order
* preserve POS confirmation
* mark KDS state as `kds_display_failed`
* notify store staff

### Manual Operation Path

* print fallback kitchen ticket if available
* staff manually writes or enters kitchen ticket
* manager verifies order items and timing
* kitchen starts preparation only after confirmation

### Recovery Step

* attempt KDS resend only if duplicate kitchen ticket risk is controlled
* route to alternate KDS station if configured
* mark manual kitchen recovery if staff enters manually

### Reconciliation Step

* reconcile POS order with KDS or manual ticket
* reconcile kitchen preparation status
* reconcile ready/pickup status later

### Evidence Required

* POS order confirmation
* KDS failure log
* manual kitchen ticket or staff confirmation
* recovery action record
* reconciliation result

### Escalation Condition

Escalate when:

* kitchen has no reliable order record
* multiple KDS stations disagree
* customer pickup time is affected
* repeated KDS failure occurs

## 12. Scenario: Kiosk Order Duplicated

### Symptom

Same kiosk order appears more than once in internal order, POS, KDS, or payment flow.

### Likely Cause

* kiosk double submission
* retry without stable idempotency key
* network timeout followed by resubmission
* user tapped multiple times
* adapter duplicate prevention failure
* local queue replayed same request

### Immediate Action

* stop additional retries
* identify all related order IDs
* compare idempotency keys
* compare payment references
* compare POS receipts
* mark as `manual_review_required`

### Manual Operation Path

* manager identifies real order
* cancel or void duplicate order if safe
* kitchen is instructed to prepare only the valid order
* customer is informed cautiously if needed

### Recovery Step

* preserve duplicate order evidence
* block duplicate kitchen preparation
* cancel duplicate POS order if allowed
* refund duplicate payment only after payment verification

### Reconciliation Step

* reconcile internal order list
* reconcile POS receipts
* reconcile payment transactions
* reconcile KDS tickets

### Evidence Required

* all duplicate order IDs
* idempotency keys
* payment IDs
* POS receipt IDs
* KDS ticket references
* manager decision

### Escalation Condition

Escalate when:

* duplicate payment exists
* duplicate kitchen preparation started
* POS cancellation is unavailable
* refund is required
* customer has already received duplicate confirmation

## 13. Scenario: Payment Duplicated

### Symptom

A customer appears to have been charged more than once for one logical order.

### Likely Cause

* payment retry after timeout
* missing idempotency
* provider delayed response
* duplicate customer submission
* payment provider callback duplicated
* POS/payment split-brain

### Immediate Action

* stop all payment retries
* identify all payment IDs and transaction IDs
* preserve payment evidence
* do not issue refund until duplicate is verified
* mark as `manual_review_required`

### Manual Operation Path

* payment support reviews payment provider records
* manager avoids promising refund completion until verified
* customer-facing status should say payment is being checked

### Recovery Step

* verify whether duplicate capture occurred
* verify whether one payment is only authorization hold
* request refund or void only after verification and approval
* link refund evidence to original duplicated payment

### Reconciliation Step

* reconcile payment provider records
* reconcile POS receipt
* reconcile internal order
* reconcile refund or void status

### Evidence Required

* payment transaction IDs
* authorization/capture status
* amount and currency
* order ID
* idempotency key
* provider response references
* reviewer decision
* refund or void evidence if performed

### Escalation Condition

Escalate when:

* duplicate capture is confirmed
* provider status is unknown
* customer dispute risk exists
* refund fails or remains unknown
* settlement mismatch exists

## 14. Scenario: POS Timeout

### Symptom

POS provider does not respond within expected time.

### Likely Cause

* provider outage
* local connector delay
* network interruption
* provider processing delay
* rate limit
* adapter timeout

### Immediate Action

* classify timeout type
* do not mark as failure unless failure is proven
* do not retry blindly if request may have reached provider
* preserve timeout evidence
* route to status query, reconciliation, or manual review

### Manual Operation Path

* if customer is waiting, staff explains that order status is being checked
* manager decides whether to pause affected channel
* manual order entry requires proof that POS order was not created or human approval

### Recovery Step

* query provider status if safe
* poll provider if supported
* wait for webhook if expected
* use manual recovery only after evidence review

### Reconciliation Step

* compare internal order state with provider status
* check whether provider created receipt after timeout
* reconcile payment state

### Evidence Required

* timeout classification
* request timestamp
* provider request reference
* retry count
* idempotency key
* status query result
* reconciliation result

### Escalation Condition

Escalate when:

* timeout affects payment, refund, or cancellation
* provider status cannot be queried
* duplicate order/payment risk exists
* repeated timeouts trigger degraded mode

## 15. Scenario: Provider Unavailable

### Symptom

POS provider, cloud API, local connector, or provider authentication path is unavailable.

### Likely Cause

* provider outage
* store internet failure
* local connector stopped
* credential expired
* provider maintenance
* rate limit
* adapter failure

### Immediate Action

* classify provider unavailable reason
* stop unsafe state-changing requests
* allow read-only checks only if safe
* activate degraded mode if store operation is affected
* preserve provider availability evidence

### Manual Operation Path

* counter ordering may continue if POS terminal itself works
* mobile or kiosk ordering may be paused
* staff may manually enter orders
* payment-at-counter may be required
* customer-facing notices must avoid false finality

### Recovery Step

* restore connector or provider access
* validate healthCheck
* replay only safe queued events
* require reconciliation before replaying state-changing events

### Reconciliation Step

* reconcile all orders created during outage
* reconcile payment records
* reconcile manual POS entries
* reconcile KDS/manual kitchen tickets

### Evidence Required

* provider healthCheck result
* outage timestamp
* affected stores
* affected orders
* degraded mode level
* manual operation record
* recovery confirmation

### Escalation Condition

Escalate when:

* provider outage persists
* money movement is affected
* multiple stores are affected
* manual operation volume exceeds safe capacity
* safe closure may be required

## 16. Scenario: Refund Unknown

### Symptom

Refund was requested but final refund result cannot be determined.

### Likely Cause

* refund timeout
* provider delayed response
* payment provider unavailable
* ambiguous provider response
* missing refund transaction ID
* partial refund conflict

### Immediate Action

* do not retry refund blindly
* preserve refund request evidence
* mark as `refund_unknown`
* trigger reconciliation or manual review

### Manual Operation Path

* support informs customer that refund is being checked
* manager must not promise refund completion without evidence
* payment support checks provider records

### Recovery Step

* query refund status
* verify settlement or transaction record
* retry only after provider confirms no refund was processed or human approval allows

### Reconciliation Step

* reconcile refund request with provider refund status
* reconcile payment transaction
* reconcile internal order cancellation state
* reconcile customer-facing case

### Evidence Required

* refund request ID
* original payment ID
* refund amount
* provider response
* timeout classification
* status query result
* reviewer decision

### Escalation Condition

Escalate when:

* refund amount is high
* duplicate refund risk exists
* customer complaint or dispute exists
* refund remains unknown beyond allowed window

## 17. Scenario: Cancel Failed

### Symptom

Order cancellation request failed.

### Likely Cause

* order already in preparation
* POS provider does not allow cancellation
* provider unavailable
* payment state conflict
* KDS already displayed
* cancellation timeout

### Immediate Action

* do not mark cancellation as confirmed
* preserve cancellation failure evidence
* check payment state
* check kitchen state
* check POS state
* mark as `manual_review_required`

### Manual Operation Path

* manager decides whether kitchen can stop preparation
* staff communicates with customer according to approved policy
* refund is handled separately from cancellation

### Recovery Step

* retry cancellation only if safe
* cancel POS order manually if approved and possible
* block automatic refund until payment/refund authority confirms

### Reconciliation Step

* reconcile POS order status
* reconcile payment state
* reconcile KDS/kitchen state
* reconcile customer-facing status

### Evidence Required

* cancellation request
* POS response
* kitchen state
* payment state
* manager decision
* recovery action

### Escalation Condition

Escalate when:

* cancellation conflicts with payment or refund
* kitchen already started
* customer-facing promise is affected
* provider cancellation status remains unknown

## 18. Scenario: Menu Sync Mismatch

### Symptom

Menu shown to customer differs from POS or store menu.

### Likely Cause

* POS menu sync failed
* price sync failed
* option sync failed
* CMS update not propagated
* provider limitation
* manual store change outside system
* stale cache

### Immediate Action

* stop affected item ordering if customer risk exists
* preserve menu version evidence
* identify mismatched items
* mark sync as `reconciliation_required`

### Manual Operation Path

* staff confirms actual available menu
* manager may temporarily hide affected items
* customer orders may be corrected manually

### Recovery Step

* resync menu if safe
* correct CMS or POS mapping
* update item availability
* mark unsupported provider fields if limitation exists

### Reconciliation Step

* compare POS menu, CMS menu, app menu, kiosk menu
* compare price, option, availability
* record final source used for correction

### Evidence Required

* menu version
* POS menu snapshot reference
* CMS menu snapshot reference
* affected item list
* correction record
* reviewer decision

### Escalation Condition

Escalate when:

* price mismatch affects charged amount
* unavailable item was sold
* repeated sync mismatch occurs
* provider limitation blocks correction

## 19. Scenario: Sold-Out Sync Mismatch

### Symptom

Customer can order an item that is sold out, or sold-out item remains unavailable after restock.

### Likely Cause

* POS sold-out sync failed
* CMS availability not propagated
* manual staff update not captured
* provider does not support sold-out sync
* cache delay
* local connector failure

### Immediate Action

* stop affected item ordering if risk exists
* confirm actual stock or availability with staff
* preserve availability evidence
* mark as `reconciliation_required`

### Manual Operation Path

* staff manually confirms item availability
* manager manually hides or restores item
* customer is contacted if unavailable item was ordered

### Recovery Step

* resync availability
* manually override availability if approved
* update provider capability limitation if sold-out sync unsupported

### Reconciliation Step

* compare POS sold-out state
* compare CMS state
* compare app/kiosk displayed state
* compare actual store availability

### Evidence Required

* item ID
* availability state before/after
* POS/CMS/app/kiosk snapshots
* staff confirmation
* correction record

### Escalation Condition

Escalate when:

* unavailable item was paid for
* multiple customers are affected
* sold-out sync is repeatedly unreliable
* provider does not support needed capability

## 20. Scenario: Internet Failure

### Symptom

Store internet failure affects POS Gateway, cloud provider, kiosk, KDS, DID, or payment flow.

### Likely Cause

* ISP outage
* router failure
* local network failure
* Wi-Fi instability
* local connector unreachable
* payment terminal network issue

### Immediate Action

* identify affected systems
* stop unsafe online ordering if status cannot be confirmed
* switch to manual or local operation if safe
* preserve outage start time and affected orders

### Manual Operation Path

* counter ordering may continue if POS terminal works locally
* payment-at-counter may be required
* mobile/kiosk ordering may be paused
* kitchen ticket may be manual
* DID callout may be manual

### Recovery Step

* restore network
* verify POS Gateway health
* verify provider health
* verify KDS/DID connectivity
* do not replay queued state-changing requests without reconciliation

### Reconciliation Step

* reconcile orders during outage
* reconcile payments during outage
* reconcile manual tickets
* reconcile customer-facing status

### Evidence Required

* outage timestamp
* affected systems
* affected orders
* manual operation records
* recovery timestamp
* reconciliation result

### Escalation Condition

Escalate when:

* payment or refund states are unknown
* many orders accumulated
* store cannot operate safely
* outage persists beyond safe window

## 21. Scenario: Local Fallback

### Symptom

Cloud or integration layer is unavailable, but local store operation may continue.

### Likely Cause

* cloud provider unavailable
* POS Gateway unavailable
* external provider unavailable
* internet degraded
* local POS still operational

### Immediate Action

* classify fallback level
* define allowed channels
* pause unsafe channels
* record degraded mode decision

### Manual Operation Path

* use local POS terminal
* use printed or handwritten kitchen ticket
* accept counter payment if approved
* disable mobile/kiosk order intake if necessary
* manually call customer number or pickup number

### Recovery Step

* restore cloud or gateway connection
* upload or record manual orders if policy allows
* reconcile all manually handled orders

### Reconciliation Step

* compare local POS records with internal system
* compare payments
* compare kitchen completion
* compare customer pickup records

### Evidence Required

* degraded mode level
* manager approval
* manual order list
* local POS receipt references
* recovery and reconciliation result

### Escalation Condition

Escalate when:

* manual volume exceeds safe capacity
* payment records cannot be reconciled
* customer disputes arise
* local fallback becomes prolonged

## 22. Scenario: Manual Order Recovery

### Symptom

An order must be recovered manually because automated integration failed or is unsafe.

### Likely Cause

* provider failure
* POS timeout
* KDS failure
* payment/POS mismatch
* duplicate prevention block
* unknown state
* unsupported provider operation

### Immediate Action

* preserve original failure evidence
* identify whether money moved
* identify whether kitchen started
* identify whether customer was notified
* require manager or human reviewer approval

### Manual Operation Path

* staff manually enters order into POS if safe
* staff manually creates kitchen ticket
* support updates customer-facing status cautiously
* payment/refund action is handled separately

### Recovery Step

* link manual POS receipt to internal order
* link manual kitchen ticket to internal order
* mark recovery action and responsible actor

### Reconciliation Step

* reconcile internal order, payment, POS, KDS/manual ticket, and customer handoff
* mark unresolved mismatch if any

### Evidence Required

* original failure
* manual operation record
* approval record
* POS receipt
* kitchen ticket
* reconciliation result

### Escalation Condition

Escalate when:

* manual recovery may duplicate payment or order
* customer has already canceled
* refund may be required
* receipt cannot be linked

## 23. Reconciliation After Recovery

Every recovery action must be followed by reconciliation.

Reconciliation must answer:

* Did money move?
* Did POS receive the order?
* Did kitchen receive the order?
* Did customer receive the correct status?
* Did cancellation or refund occur?
* Was there any duplicate?
* Is any state still unknown?
* Is manual review still required?
* Is evidence complete?

A recovery without reconciliation is incomplete.

## 24. Degraded Mode Activation Criteria

Degraded mode may be activated when:

* provider unavailable
* repeated POS timeout
* duplicate risk prevents safe automation
* KDS unavailable
* DID unavailable
* menu sync unreliable
* sold-out sync unreliable
* payment provider issue exists
* local connector failure exists
* internet failure exists
* support team cannot verify state quickly enough

Degraded mode requires:

* level classification
* affected channel list
* affected store list
* allowed operation list
* blocked operation list
* customer-facing caution
* evidence record
* review owner
* exit condition

## 25. Degraded Mode Exit Criteria

Degraded mode may end only when:

* provider health is restored
* adapter health is restored
* pending unknown states are reconciled
* duplicate risk is cleared
* manual orders are reconciled
* payment and refund states are checked
* menu and availability states are checked if affected
* support owner approves exit
* evidence is complete

Do not end degraded mode merely because one health check succeeds.

## 26. Safe Closure Criteria

Safe closure may be required when continued operation would create unacceptable risk.

Safe closure may be required when:

* payment state cannot be trusted
* POS order state cannot be trusted
* kitchen operation cannot receive orders reliably
* duplicate order risk is uncontrolled
* duplicate payment risk is uncontrolled
* staff cannot safely manage manual volume
* customer-facing status cannot be kept reliable
* provider outage is widespread
* evidence capture is unavailable

Safe closure requires human authority.

## 27. Customer-Facing Communication Rule

Customer-facing communication must be accurate and cautious.

Do not say:

* order completed when KDS/kitchen state is unresolved
* refund completed when refund is unknown
* cancellation completed when cancellation is unknown
* payment failed when timeout occurred but result is unknown
* provider issue details unless approved by support policy

Use safer wording such as:

* order is being checked
* payment status is being verified
* staff is confirming your order
* refund is being reviewed
* pickup status is being confirmed
* support assistance is required

## 28. Evidence Checklist For Every Scenario

Each scenario must record:

* scenario name
* order ID
* payment ID where applicable
* POS provider
* adapter version
* store ID
* affected channel
* symptom
* likely cause
* immediate action
* manual operation path if used
* recovery step
* reconciliation step
* degraded mode level if used
* operator
* reviewer
* approval status
* unresolved risk
* final state

## 29. Escalation Matrix

| Condition                         | Escalate To                                            |
| --------------------------------- | ------------------------------------------------------ |
| Duplicate payment risk            | Payment Support and Human Reviewer                     |
| Refund unknown                    | Payment Support and Human Reviewer                     |
| POS provider outage               | Technical Support and Headquarters Operator            |
| KDS failure affecting kitchen     | Store Manager and Technical Support                    |
| DID failure affecting pickup      | Store Manager                                          |
| Menu price mismatch               | Headquarters Operator and Store Manager                |
| Sold-out mismatch with paid order | Store Manager and Support                              |
| Manual operation overload         | Store Manager and Franchisee Owner                     |
| Safe closure consideration        | Store Manager, Franchisee Owner, Headquarters Operator |
| Provider support status issue     | Platform Admin                                         |

## 30. Anti-Patterns

The following are prohibited:

* retrying payment after timeout without status verification
* retrying refund after timeout without evidence
* manually entering POS order without checking duplicate risk
* treating POS success as KDS success
* treating KDS success as customer handoff success
* hiding unknown state from audit
* ending degraded mode without reconciliation
* issuing refund based only on customer claim without payment verification
* deleting failed events after recovery
* allowing vendor to perform production recovery without authority
* continuing mobile/kiosk ordering when store cannot safely fulfill
* promising final customer outcome before evidence exists

## 31. Relationship To 000808 Evidence Template

All recovery, reconciliation, manual operation, and degraded mode actions must be recorded using the evidence structure defined in:

```text
000808_Template_POS_Transaction_Evidence_Event_Log_And_Diagnostic_Record.md
```

The evidence template must include enough fields to reconstruct what happened, who acted, why they acted, and whether the final state was approved.

## 32. Relationship To 000900 Outsourcing Package

The outsourcing package under:

```text
docs/000900_outsourcing_vendor_handoff_and_acceptance/
```

must require vendors to demonstrate that their adapters can support this runbook.

Vendor deliverables must include:

* failure scenario evidence
* timeout handling evidence
* retry safety explanation
* reconciliation support
* manual recovery notes
* known limitations
* unsupported capability list

A vendor adapter is incomplete if this runbook cannot be executed against its failure modes.

## 33. Acceptance Criteria

This runbook is acceptable only if it confirms that:

* failed or unknown POS integration can be handled operationally
* payment success but POS failure has a controlled path
* POS success but KDS failure has a controlled path
* duplicate order and duplicate payment cases are controlled
* refund unknown and cancellation failure are handled safely
* menu and sold-out mismatch are recoverable
* internet failure and local fallback are addressed
* degraded mode has levels and exit criteria
* safe closure is allowed when operation is unsafe
* recovery requires evidence
* reconciliation follows recovery
* no implementation is authorized by this document

## 34. Final Rule

```text
Recovery is not complete when the immediate symptom disappears.
Recovery is complete only when operation is safe, money is reconciled, kitchen state is correct, customer-facing status is not misleading, evidence is preserved, and human authority has approved unresolved risk.
```
