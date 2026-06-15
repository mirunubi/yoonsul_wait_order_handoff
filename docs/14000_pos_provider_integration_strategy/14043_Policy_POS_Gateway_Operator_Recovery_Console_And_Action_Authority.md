# 14043_Policy_POS_Gateway_Operator_Recovery_Console_And_Action_Authority

## 1. Purpose

This policy defines the operator recovery console, action authority, escalation boundary, approval requirements, and audit evidence for POS Gateway incident handling.

The purpose is to ensure that POS Gateway exceptions are not only detected and logged, but also recoverable through controlled operator actions with clear authority, reason codes, evidence review, customer impact awareness, payment safety, and immutable audit history.

A field exception without an operator recovery path becomes a production incident.

## 2. Scope

This policy applies to:

* POS Gateway operator console
* Store operator console
* HQ support console
* Finance review console
* Technical support console
* Provider incident console
* Manual recovery action
* Operator authority level
* Manager approval
* Finance approval
* Security or audit approval
* Customer notification action
* Payment recovery action
* Kitchen recovery action
* Queue recovery action
* Provider dispute action
* Legal evidence preservation
* Audit evidence for all operator actions

This policy applies to all POS Gateway exception categories, including provider failure, local device failure, kitchen print uncertainty, duplicate risk, payment mismatch, in-doubt transaction, waiting journey conflict, inventory race, business day mismatch, table conflict, schema drift, multi-endpoint routing conflict, and suspicious manual mutation.

## 3. Core Principle

Operators must be able to recover incidents without corrupting core state.

The console must not provide uncontrolled buttons that bypass policy.

Every operator action must be:

* Role-scoped
* Context-scoped
* State-aware
* Risk-aware
* Reason-coded
* Audited
* Reversible where possible
* Escalated when required
* Visible to the appropriate owner

The system must distinguish operational recovery from financial adjustment, technical retry, customer compensation, and legal dispute handling.

## 4. Recovery Console Boundary

The operator console sits above Gateway state and below final authority policy.

```
[POS Gateway Exception State]
              |
              v
    [Operator Recovery Console]
              |
   ------------------------------
   |             |              |
   v             v              v
[Store Ops]   [HQ Support]   [Finance / Audit]
```

The console must show what happened, what is uncertain, what actions are allowed, who may act, and what evidence will be created.

## 5. Non-Negotiable Rules

### 5.1 No Uncontrolled Manual Override Rule

Operators must not be allowed to directly mutate core order, payment, settlement, kitchen, or audit state without controlled action type, authority, reason code, and evidence.

### 5.2 State-Aware Action Rule

The console must only show actions that are valid for the current state.

An action valid for payment-pending order may be unsafe for payment-approved order.

An action valid before kitchen print may be unsafe after kitchen print.

### 5.3 Payment Action Authority Rule

Payment void, refund, partial refund, manual compensation, and finance closure require stricter authority than ordinary operational confirmation.

### 5.4 Evidence Before Closure Rule

An incident must not be closed unless required evidence is attached, generated, or explicitly waived by authorized role.

### 5.5 Customer Impact Visibility Rule

Before an operator performs an action that affects customer order, payment, refund, table, waiting status, or cancellation, the console must show customer impact and allowed customer message.

### 5.6 Audit Always Rule

Every operator action must generate audit evidence.

Even failed or denied actions must be logged.

## 6. Operator Roles

The system may define multiple operator roles.

Allowed roles include:

```
STORE_STAFF
STORE_MANAGER
STORE_OWNER
HQ_SUPPORT_AGENT
HQ_SUPPORT_LEAD
TECHNICAL_SUPPORT
FINANCE_OPERATOR
FINANCE_MANAGER
SECURITY_AUDITOR
INCIDENT_MANAGER
PROVIDER_RELATIONS_MANAGER
SYSTEM_ADMIN
READ_ONLY_AUDITOR
```

Roles must map to permissions and approval authority.

## 7. Authority Levels

Actions must be assigned authority levels.

Allowed authority levels include:

```
VIEW_ONLY
ACKNOWLEDGE_ONLY
LOW_RISK_OPERATIONAL_ACTION
STORE_MANAGER_APPROVAL_REQUIRED
HQ_SUPPORT_APPROVAL_REQUIRED
FINANCE_APPROVAL_REQUIRED
TECHNICAL_APPROVAL_REQUIRED
SECURITY_AUDIT_APPROVAL_REQUIRED
DUAL_APPROVAL_REQUIRED
SYSTEM_ADMIN_ONLY
PROHIBITED_IN_PRODUCTION
```

Authority level must be enforced by the system.

## 8. Recovery Action Categories

Operator actions must be categorized.

Allowed categories include:

```
VIEW_EVIDENCE
ACKNOWLEDGE_INCIDENT
RETRY_OPERATION
CANCEL_OPERATION
MARK_MANUAL_RECOVERY
CONFIRM_STORE_STATE
CONFIRM_KITCHEN_STATE
CONFIRM_TABLE_STATE
CONFIRM_WAITING_STATE
CONFIRM_STOCK_STATE
TRIGGER_CUSTOMER_NOTIFICATION
TRIGGER_REFUND
TRIGGER_VOID
LINK_EXTERNAL_RECEIPT
LINK_PAYMENT_REFERENCE
LINK_POS_MUTATION
CLASSIFY_UNPAID_ORDER
CLASSIFY_SERVICE_ORDER
PAUSE_PROVIDER_PATH
RESUME_PROVIDER_PATH
OPEN_CIRCUIT
CLOSE_CIRCUIT
QUARANTINE_PACKET
RELEASE_QUARANTINE_WITH_APPROVAL
ESCALATE_INCIDENT
CLOSE_INCIDENT_WITH_EVIDENCE
```

Each category must have a policy-bound set of allowed states.

## 9. State-Aware Action Matrix

The console must maintain an action matrix.

The matrix should consider:

```
exception_category
current_order_state
current_payment_state
current_pos_state
current_kitchen_state
current_table_state
current_waiting_state
current_stock_state
current_queue_state
current_circuit_state
current_reconciliation_state
authority_level
allowed_actions
blocked_actions
required_reason_code
required_evidence
required_customer_message
```

The action matrix must be versioned.

## 10. Reason Codes

Operator actions must require reason codes when they alter state.

Allowed reason code groups include:

```
PROVIDER_TIMEOUT
PROVIDER_REJECTION
PROVIDER_RATE_LIMIT
LOCAL_AGENT_OFFLINE
POS_APP_RESTART
PRINTER_FAILURE
KITCHEN_CONFIRMED_RECEIVED
KITCHEN_CONFIRMED_NOT_RECEIVED
CUSTOMER_CANCELED
CUSTOMER_NO_SHOW
STORE_MANUAL_ENTRY
STOCK_SOLD_OUT
PRICE_MISMATCH
PAYMENT_MISMATCH
REFUND_REQUIRED
DUPLICATE_RISK
MANUAL_RECONCILIATION
PROVIDER_SCHEMA_DRIFT
FINANCE_REVIEW
STORE_OPERATOR_ERROR
SUSPECTED_MANUAL_MUTATION
LEGAL_EVIDENCE_PRESERVATION
OTHER_WITH_NOTE_REQUIRED
```

Free-text notes may be allowed, but structured reason code is required.

## 11. Evidence Requirements By Action

Each action must declare evidence requirements.

Examples:

### 11.1 Retry POS Submission

Required evidence:

* Idempotency key
* Current order state
* Current payment state
* Provider status query result
* Duplicate risk check
* Queue job state
* Operator authority

### 11.2 Trigger Refund

Required evidence:

* Payment approval reference
* Refund eligibility
* POS state
* Kitchen state
* Customer notification state
* Amount and component identity
* Finance or manager approval, if required

### 11.3 Confirm Kitchen Received

Required evidence:

* Kitchen ticket ID
* Print mode
* Operator identity
* Confirmation source
* Timestamp
* Related order state

### 11.4 Close In-Doubt Transaction

Required evidence:

* PG status query
* POS receipt query
* Refund or void result
* Customer notification state
* Finance review result
* Closure reason

### 11.5 Resolve Suspicious Manual Mutation

Required evidence:

* Original platform order
* Original POS ACK
* Payment reference
* Later POS mutation
* Store explanation, if required
* Finance review
* Settlement impact decision

## 12. Operational Recovery Actions

Operational actions may include:

```
RETRY_PRINT
REPRINT_WITH_LABEL
SEND_CANCEL_TICKET
CONFIRM_KITCHEN_STOP
CONFIRM_ENTRY
MARK_NO_SHOW
ASSIGN_TABLE
UPDATE_TABLE_CONTEXT
CONFIRM_MANUAL_ENTRY
RELEASE_STOCK_HOLD
CONFIRM_SOLD_OUT
PAUSE_QUEUE_JOB
RESUME_QUEUE_JOB
CANCEL_STALE_QUEUE_JOB
MARK_MANUAL_RECOVERY
```

Operational actions must not automatically perform payment actions unless explicitly linked to payment policy.

## 13. Financial Recovery Actions

Financial actions may include:

```
QUERY_PG_STATUS
QUERY_POS_RECEIPT
RETRY_NETWORK_CANCEL
REQUEST_VOID
REQUEST_REFUND
REQUEST_PARTIAL_REFUND
LINK_PG_PAYMENT
LINK_VAN_APPROVAL
LINK_POS_RECEIPT
CLASSIFY_PAYMENT_COLLECTOR
CLASSIFY_SALES_CHANNEL
CLASSIFY_UNPAID_ORDER
CLOSE_RECONCILIATION_CASE
ESCALATE_FINANCE_REVIEW
```

Financial actions require finance-aware authority and stricter evidence.

## 14. Technical Recovery Actions

Technical actions may include:

```
OPEN_PROVIDER_CIRCUIT
CLOSE_PROVIDER_CIRCUIT
FORCE_HALF_OPEN_PROBE
PAUSE_LOW_PRIORITY_SYNC
RESUME_LOW_PRIORITY_SYNC
REDUCE_PROVIDER_CONCURRENCY
SWITCH_AGENT_CHANNEL_MODE
UPDATE_AGENT_CONFIG
PAUSE_LOCAL_SUBMISSION
RESUME_LOCAL_SUBMISSION
MARK_LOCAL_AGENT_UNHEALTHY
MARK_PROVIDER_INCIDENT
QUARANTINE_PROVIDER_PACKET
MARK_ADAPTER_CONTRACT_STALE
```

Technical actions must not hide customer or payment impact.

## 15. Customer Notification Actions

Customer notification must be policy-bound.

Allowed notification categories include:

```
ORDER_CONFIRMATION_PENDING
ORDER_ACCEPTED
ORDER_REJECTED
PAYMENT_NOT_COMPLETED
PAYMENT_UNDER_REVIEW
REFUND_PROCESSING
REFUND_COMPLETED
ITEM_SOLD_OUT
TABLE_CONFIRMATION_PENDING
WAITING_CANCELED
STORE_TEMPORARILY_UNAVAILABLE
ORDER_CANCELED_BY_STORE
```

Operators must not freely type technical explanations to customers for high-risk incidents unless approved template and role allow it.

## 16. Dual Approval

Certain actions may require dual approval.

Dual approval may be required for:

* Manual refund above threshold
* Closing unresolved in-doubt transaction
* Overriding duplicate risk
* Releasing quarantined high-risk packet
* Accepting suspicious POS mutation
* Changing settlement classification
* Marking malicious mutation resolved
* Disabling provider path in production
* Re-enabling provider after severe incident
* Manual adjustment affecting tax or finance

Dual approval must record both actors and timestamps.

## 17. Segregation Of Duties

The same actor should not perform incompatible actions when financial risk is high.

Examples:

* Store staff who caused manual mutation should not close finance review alone
* Support agent who triggers refund should not approve suspicious mutation resolution alone
* Developer should not silently alter production reconciliation state
* Operator should not both create and approve manual settlement override

Segregation rules must be configurable by risk level.

## 18. Incident Escalation

The console must support escalation.

Escalation targets may include:

```
STORE_MANAGER
HQ_SUPPORT_LEAD
TECHNICAL_SUPPORT
FINANCE_MANAGER
SECURITY_AUDITOR
PROVIDER_RELATIONS
INCIDENT_MANAGER
LEGAL_REVIEW
```

Escalation must preserve:

* Escalation reason
* Current evidence
* Required next action
* SLA or deadline
* Customer impact
* Financial exposure
* Provider involvement

## 19. Operator Console Views

The console should provide separate views.

### 19.1 Store Operations View

Focus:

* Waiting
* Table
* Kitchen
* Printer
* Stock
* Manual recovery
* Customer-facing order status

### 19.2 HQ Support View

Focus:

* Provider incidents
* Queue backlog
* Duplicate risk
* Store recovery assistance
* Cross-store issue patterns

### 19.3 Finance View

Focus:

* Payment mismatch
* Refund pending
* In-doubt transaction
* PG/VAN/POS reconciliation
* Tax and sales channel classification
* Unpaid and service order classification

### 19.4 Technical View

Focus:

* Circuit breaker
* Connection pool
* Agent channel
* Schema drift
* Adapter health
* Local agent status

### 19.5 Audit View

Focus:

* Immutable event timeline
* Operator actions
* Evidence completeness
* Authority compliance
* Policy violations

## 20. Incident Status

Each recovery case must have status.

Allowed statuses include:

```
OPEN
ACKNOWLEDGED
WAITING_FOR_PROVIDER
WAITING_FOR_STORE
WAITING_FOR_CUSTOMER
WAITING_FOR_FINANCE
WAITING_FOR_TECHNICAL
WAITING_FOR_AUDIT
MANUAL_RECOVERY_IN_PROGRESS
RECOVERY_COMPLETED
RECONCILED
CLOSED_WITH_EVIDENCE
CLOSED_WITH_APPROVED_EXCEPTION
ESCALATED
BLOCKED
REOPENED
```

Status changes must be audited.

## 21. Recovery Case Record

A recovery case should include:

```
recovery_case_id
exception_category
severity
store_id
provider_id
platform_order_id
payment_id
waiting_session_id
table_id
kitchen_ticket_id
stock_hold_id
queue_job_id
raw_packet_id
current_status
current_owner_role
current_owner_user
required_action
required_authority
required_evidence
customer_impact
financial_impact
deadline_at
created_at
updated_at
closed_at
```

The recovery case links operational work to audit evidence.

## 22. Severity Classification

Recovery cases must be severity-classified.

Allowed severities include:

```
INFO
LOW
MEDIUM
HIGH
CRITICAL
FINANCIAL_CRITICAL
CUSTOMER_IMPACTING
STORE_BLOCKING
PROVIDER_WIDE
SECURITY_OR_LEGAL_RISK
```

Severity must influence alerting, authority, SLA, and escalation.

## 23. SLA And Deadline

Recovery cases should have deadlines based on severity.

Examples:

* Customer-visible payment uncertainty requires urgent review
* In-doubt transaction requires immediate and scheduled reconciliation
* Printer issue may require store-level recovery
* Schema drift may require provider-wide circuit action
* Finance mismatch may require day-end or next-day review

Missed deadline must escalate.

## 24. Audit Requirements

Every operator recovery action must preserve:

* Recovery case ID
* Actor user ID
* Actor role
* Authority level
* Store ID
* Provider ID
* Related order ID, if applicable
* Related payment ID, if applicable
* Related waiting session ID, if applicable
* Related table ID, if applicable
* Related kitchen ticket ID, if applicable
* Related stock hold ID, if applicable
* Related queue job ID, if applicable
* Action type
* Previous state
* New state
* Reason code
* Evidence reviewed
* Evidence generated
* Customer message sent, if any
* Financial impact, if any
* Approval actor, if any
* Dual approval reference, if applicable
* Trace ID
* Correlation ID
* Idempotency key, if applicable
* Gateway version
* Policy version
* Timestamp

Audit records must be immutable and access-controlled.

## 25. Test Requirements

The operator recovery console must be tested for:

* Role-based action visibility
* State-aware action blocking
* Reason code requirement
* Evidence requirement enforcement
* Refund authority enforcement
* Dual approval
* Segregation of duties
* Queue job recovery
* Kitchen print recovery
* Waiting no-show recovery
* Stock hold recovery
* In-doubt transaction recovery
* Suspicious mutation review
* Schema drift quarantine review
* Customer notification template selection
* Incident escalation
* Case closure with evidence
* Attempted unauthorized action logging
* Audit preservation for all operator actions

The console cannot be production-ready without recovery action and authority test evidence.

## 26. Anti-Patterns

The following are prohibited:

* Providing a generic “fix order” button
* Allowing operators to directly edit core state without controlled action
* Allowing refund without payment evidence
* Allowing incident closure without evidence
* Showing actions that are unsafe for current state
* Letting store staff resolve finance-critical cases alone
* Allowing free-text customer explanations for technical incidents
* Hiding operator actions from audit
* Allowing the same actor to create and approve high-risk manual adjustment
* Closing in-doubt transaction before PG/POS reconciliation
* Resolving suspicious POS mutation by overwriting original evidence

## 27. Relationship With Other Documents

This policy operationalizes:

```
05300 POS Gateway Resilience And Field Exception Catalog Readme
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05410 POS Waiting Entry NoShow And Prepaid Cancel Sync Policy
05430 POS Inventory Race Condition And Stock Hold Buffer Policy
05440 POS VAN PG Tax Sales Channel And Unpaid Order Reconciliation Policy
05470 POS InDoubt Transaction Network Cancel Receipt Number And Financial Reconciliation Policy
05480 POS Multi Endpoint Routing Delivery App Port Contention And Malicious Manual Mutation Defense Policy
05490 POS Provider Capability Profile And Readiness Evidence Policy
05500 POS Provider Test Fixture And Simulation Scenario Policy
```

Operator recovery is the human-controlled execution layer for POS Gateway resilience.

## 28. Final Rule

The POS Gateway must not only detect exceptions. It must provide safe, role-scoped, state-aware, evidence-backed ways to recover from them.

If operators can change order, payment, kitchen, stock, waiting, table, settlement, or provider incident state without authority, reason, evidence, and immutable audit trail, the operator recovery boundary has failed.
