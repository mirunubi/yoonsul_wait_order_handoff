# 14059_Policy_POS_Gateway_API_Command_Query_And_Internal_Service_Boundary

## 1. Purpose

This policy defines the API, command, query, internal service, external adapter, and domain boundary for POS Gateway implementation.

The purpose is to ensure that POS Gateway behavior is exposed through controlled contracts rather than direct table writes, provider-specific calls, hidden adapter shortcuts, or uncontrolled operational scripts.

The POS Gateway must provide stable internal APIs for core domains, operator consoles, finance reconciliation, monitoring, local agents, provider adapters, and incident tools while keeping provider-specific disorder behind the Gateway boundary.

## 2. Scope

This policy applies to:

* POS Gateway internal API
* Command contract
* Query contract
* Service boundary
* Provider adapter invocation
* Local agent API
* Operator console API
* Finance reconciliation API
* Monitoring API
* Incident and recovery API
* Configuration API
* Evidence retrieval API
* Customer-facing state API
* Store-facing state API
* Idempotency API behavior
* Authorization boundary
* API versioning
* API audit
* API failure response model

This policy applies to all POS-connected order, payment, kitchen, waiting, table, stock, reconciliation, provider readiness, monitoring, and operator recovery flows.

## 3. Core Principle

The POS Gateway must be accessed through explicit commands and queries.

No upstream or downstream component should directly mutate POS Gateway tables, call provider adapters, alter queues, or bypass state-machine validation.

Commands change state.

Queries read state.

Adapters translate provider-specific communication.

No layer should do another layer’s job.

## 4. API Boundary

The POS Gateway exposes controlled surfaces to different callers.

```
[Core Order / Payment / Journey Domain]
                  |
                  v
        [POS Gateway Command API]
                  |
                  v
      [Gateway Application Services]
                  |
    --------------------------------
    |              |               |
    v              v               v
[State Machine] [Event Ledger] [Provider Adapter]
```

Separate query APIs serve dashboards, support tools, finance, monitoring, and audit.

## 5. Non-Negotiable Rules

### 5.1 No Direct Table Mutation Rule

No external domain, operator tool, script, adapter, or support workflow may directly mutate POS Gateway state tables.

All state changes must pass through command handlers and state transition validation.

### 5.2 No Direct Provider Call Rule

Core order, payment, kitchen, waiting, table, inventory, finance, or operator systems must not call provider APIs directly.

Provider calls must go through the POS Gateway adapter boundary.

### 5.3 Command Must Be Idempotent Rule

Commands that may be retried, submitted by customers, replayed by queues, triggered by webhooks, or executed by operators must support idempotency where operation risk requires it.

### 5.4 Query Must Not Mutate Rule

Query endpoints must not cause business state mutation.

Health probes and diagnostics must not create orders, payments, refunds, receipts, prints, or state transitions unless explicitly defined as command actions.

### 5.5 Authorization Required Rule

Every API surface must enforce caller identity, context, role, scope, and action authority.

### 5.6 Versioned Contract Rule

All production API contracts that affect external systems, local agents, operator consoles, finance, or provider adapters must be versioned.

## 6. API Surface Groups

The POS Gateway should define separate API surface groups.

Allowed groups include:

```
CORE_COMMAND_API
CORE_QUERY_API
PROVIDER_ADAPTER_API
LOCAL_AGENT_API
OPERATOR_RECOVERY_API
FINANCE_RECONCILIATION_API
MONITORING_HEALTH_API
INCIDENT_TRIAGE_API
CONFIGURATION_API
EVIDENCE_AUDIT_API
PROVIDER_READINESS_API
TEST_FIXTURE_API
```

Each group must have ownership, authorization, versioning, and audit policy.

## 7. Core Command API

Core command API is used by core order, payment, waiting, table, kitchen, and inventory domains to request POS Gateway execution.

Allowed commands may include:

```
SubmitOrderToPOS
CancelOrderInPOS
ModifyOrderInPOS
ValidateOrderAgainstPOS
ValidatePriceAgainstPOS
ValidateSoldOutAgainstPOS
LinkPaymentToPOS
SyncVoidToPOS
SyncRefundToPOS
RequestNetworkCancel
DispatchKitchenPrint
DispatchKitchenCancelTicket
CreateStockHold
ReleaseStockHold
SyncWaitingEntry
SyncTableAssignment
QueryPOSReceiptWithCommandTracking
```

Each command must define input, output, idempotency, authorization, validation, and state transition behavior.

## 8. Core Query API

Core query API allows upstream domains to read normalized Gateway state.

Allowed queries may include:

```
GetPOSSubmissionState
GetPOSValidationState
GetPaymentPOSLinkState
GetKitchenPrintState
GetWaitingPOSSyncState
GetTablePOSSyncState
GetStockHoldState
GetInDoubtTransactionState
GetProviderAvailabilityForStore
GetStorePOSCapabilitySummary
```

Core query API must return normalized states, not provider raw payloads.

## 9. Provider Adapter API

Provider adapter API is internal to the Gateway.

Adapter methods may include:

```
providerSubmitOrder
providerCancelOrder
providerModifyOrder
providerQueryOrderStatus
providerQueryReceipt
providerValidateMenu
providerValidateSoldOut
providerSyncPayment
providerSyncRefund
providerSyncVoid
providerQueryBusinessDay
providerQueryTableState
providerDispatchPrint
providerParseWebhook
```

Adapters must not directly update core or Gateway state.

Adapters return provider-specific results to the Gateway normalization layer.

## 10. Local Agent API

Local agent API controls communication with store-side agents.

Allowed local agent APIs may include:

```
RegisterAgent
AuthenticateAgent
ReceiveHeartbeat
ReceiveLocalHealth
ReceiveLocalQueueReport
ReceivePrintResult
ReceivePOSAppStatus
ReceiveLocalExecutionResult
DispatchAgentCommand
DispatchPrintJob
DispatchPOSBridgeJob
UpdateAgentConfig
RotateAgentToken
```

Local agent API must enforce store binding and device identity.

## 11. Operator Recovery API

Operator recovery API powers the recovery console.

Allowed commands may include:

```
AcknowledgeRecoveryCase
RetryPOSSubmission
CancelQueueJob
ConfirmKitchenReceived
ConfirmKitchenNotReceived
TriggerCustomerNotification
RequestRefund
RetryNetworkCancel
LinkPOSReceipt
LinkPaymentReference
ConfirmManualRecovery
ResolveTableConflict
ResolveWaitingConflict
ResolveStockConflict
EscalateIncident
CloseCaseWithEvidence
```

Every operator command must enforce role, authority, reason code, evidence, and state-aware action matrix.

## 12. Finance Reconciliation API

Finance API must support controlled reconciliation, not arbitrary edits.

Allowed commands and queries may include:

```
ListInDoubtTransactions
GetPaymentPOSReconciliationCase
QueryPGStatus
QueryPOSReceipt
LinkVANApproval
ClassifySalesChannel
ClassifyUnpaidOrder
ClassifyServiceOrder
ApproveManualReconciliation
CloseFinanceCaseWithEvidence
ExportReconciliationEvidence
```

Finance actions must be auditable and access-restricted.

## 13. Monitoring Health API

Monitoring APIs expose operational health.

Allowed queries may include:

```
GetProviderHealth
GetStorePOSHealth
GetEndpointHealth
GetLocalAgentHealth
GetQueueHealth
GetCircuitState
GetPaymentRiskHealth
GetKitchenPrintHealth
GetReconciliationHealth
GetManualMutationRiskHealth
```

Monitoring API must not expose restricted raw evidence unless caller has authority.

## 14. Incident Triage API

Incident API must link runtime exceptions to triage and dispute workflows.

Allowed commands may include:

```
CreateIncidentFromAlert
ClassifyIncident
AssignIncidentOwner
AttachEvidenceToIncident
GenerateProviderDisputePacket
GeneratePGVANDisputePacket
GenerateStoreDisputePacket
EscalateIncident
CloseIncidentWithEvidence
DowngradeProviderReadiness
```

Incident API must preserve evidence and ownership classification.

## 15. Configuration API

Configuration API controls runtime behavior.

Allowed commands may include:

```
RequestConfigChange
ApproveConfigChange
ApplyConfigChange
RollbackConfigChange
EnableFeatureFlag
DisableFeatureFlag
ScheduleFeatureFlag
UpdateProviderTimeoutProfile
UpdateCircuitBreakerPolicy
UpdateQueuePolicy
UpdateMenuMappingVersion
UpdatePaymentMappingVersion
UpdatePrinterRoute
UpdateLocalAgentConfig
```

Configuration commands must enforce risk classification, approval, effective date, rollback, and audit.

## 16. Evidence Audit API

Evidence API allows controlled retrieval and export.

Allowed commands and queries may include:

```
GetEvidenceSummary
GetRawPacketWithRedaction
GetEventTimeline
GetDisputePacket
ExportEvidenceBundle
ApplyLegalHold
ReleaseLegalHold
RequestEvidenceAccess
RecordEvidenceAccessReason
DestroyEvidenceByPolicy
```

Evidence API must enforce retention, access, redaction, legal hold, and export audit policy.

## 17. Provider Readiness API

Provider readiness API manages capability profile and evidence.

Allowed commands and queries may include:

```
CreateProviderProfile
UpdateProviderCapability
AttachProviderEvidence
MarkCapabilityUnsupported
DeclareDegradedMode
ApproveProviderGate
DowngradeProviderReadiness
GetProviderReadinessSummary
GetProviderCapabilityMatrix
```

Readiness API must be versioned and evidence-backed.

## 18. Test Fixture API

Test fixture API is used for controlled test environments.

Allowed commands may include:

```
CreateTestScenario
ExecuteProviderFixture
SimulateProviderTimeout
SimulateProviderSchemaDrift
SimulateInDoubtTransaction
SimulatePrinterFailure
SimulateStockRace
SimulateManualMutation
RecordTestEvidence
UpdateProviderTestCoverage
```

Test fixture API must be isolated from production customer flows.

## 19. Command Contract Requirements

Every command contract must define:

```
command_name
command_version
caller_type
required_scope
required_authority
idempotency_required
idempotency_key_source
validation_rules
allowed_current_states
expected_state_transition
async_allowed
timeout_budget
retry_policy
audit_event_types
customer_impact
financial_impact
failure_response_model
```

Command contracts must be documented before implementation.

## 20. Query Contract Requirements

Every query contract must define:

```
query_name
query_version
caller_type
required_scope
data_sensitivity
allowed_filters
pagination_policy
freshness_policy
redaction_policy
cache_policy
audit_required
stale_data_behavior
```

Queries used by finance, audit, legal, and incident tools require stronger access control.

## 21. Command Response Model

Command responses should use normalized outcome states.

Allowed response categories include:

```
ACCEPTED
ACCEPTED_ASYNC
VALIDATED
REJECTED_BY_VALIDATION
BLOCKED_BY_POLICY
BLOCKED_BY_AUTHORITY
BLOCKED_BY_PROVIDER_STATE
BLOCKED_BY_PAYMENT_STATE
BLOCKED_BY_STOCK_STATE
QUEUED
OUTCOME_UNKNOWN
MANUAL_RECOVERY_REQUIRED
RECONCILIATION_REQUIRED
FAILED_RETRYABLE
FAILED_NON_RETRYABLE
```

Responses must not hide uncertainty.

## 22. Error Model

API errors must be normalized.

Error categories may include:

```
AUTHORIZATION_ERROR
VALIDATION_ERROR
STATE_TRANSITION_ERROR
IDEMPOTENCY_CONFLICT
PROVIDER_UNAVAILABLE
PROVIDER_REJECTED
PROVIDER_TIMEOUT
LOCAL_AGENT_UNAVAILABLE
PRINTER_UNAVAILABLE
PAYMENT_STATE_UNSAFE
STOCK_STATE_UNSAFE
CONFIGURATION_BLOCKED
SCHEMA_VALIDATION_FAILED
RATE_LIMITED
RECOVERY_REQUIRED
INTERNAL_ERROR
```

Provider raw errors must be mapped before leaving the Gateway boundary.

## 23. Asynchronous Command Behavior

Some commands may return before provider execution is complete.

Async commands must provide:

* Operation ID
* Initial state
* Queue job ID, if applicable
* Customer-facing pending state
* Operator-visible status
* Poll or subscription endpoint
* Expiration
* Recovery path
* Audit event

Async acceptance must not imply final success.

## 24. Idempotency Contract

Idempotent commands must define:

* Idempotency key source
* Request fingerprint
* Result replay behavior
* Conflict behavior
* Expiration
* Retry safety
* Provider idempotency relationship
* Payment idempotency relationship
* Queue replay relationship

If the same idempotency key is reused with a different intent, the command must reject or classify conflict.

## 25. Authorization And Context

Every API call must evaluate context.

Context may include:

* User identity
* Service identity
* Tenant
* Store
* Legal entity
* Operating group
* POS endpoint
* Provider
* Role
* Authority
* Device identity
* Agent identity
* Request source
* Network trust level
* Session risk

Context must be preserved in audit events.

## 26. Customer-Facing State API

Customer-facing state must be derived from safe normalized state.

Allowed customer-visible states may include:

```
ORDER_CONFIRMING
ORDER_ACCEPTED
ORDER_REJECTED
PAYMENT_CHECKING
PAYMENT_NOT_COMPLETED
REFUND_PROCESSING
REFUND_COMPLETED
STORE_UNAVAILABLE
ITEM_SOLD_OUT
TABLE_CONFIRMING
WAITING_UPDATED
ORDER_CANCELED
```

Customer API must not expose internal provider errors, queue details, circuit state, in-doubt internals, or suspicious mutation details.

## 27. Store-Facing State API

Store-facing state may include more operational detail than customer-facing state, but still must be controlled.

Allowed store-visible states may include:

```
POS_CONFIRMATION_PENDING
KITCHEN_PRINT_UNCERTAIN
MANUAL_ENTRY_REQUIRED
PRINTER_CHECK_REQUIRED
LOCAL_AGENT_OFFLINE
TABLE_CONFLICT
WAITING_CONFIRMATION_REQUIRED
STOCK_CONFIRMATION_REQUIRED
REFUND_REVIEW_REQUIRED
PROVIDER_PATH_DEGRADED
```

Store-facing API must not expose restricted finance or legal evidence unless authorized.

## 28. API Versioning

APIs must support versioning.

Versioning applies to:

* Command payloads
* Query payloads
* Event payloads
* Adapter contracts
* Local agent messages
* Operator console actions
* Provider readiness data
* Evidence export format

Breaking changes must follow controlled rollout and compatibility policy.

## 29. Backward Compatibility

Backward compatibility must be considered for:

* Older local agents
* Older operator console clients
* Existing provider adapters
* Existing queued jobs
* Existing webhook payloads
* Existing evidence exports
* Existing test fixtures

A new API version must not make old in-flight operations unrecoverable.

## 30. API Rate Limits

API surfaces must have rate limits.

Rate limits should be scoped by:

* Caller type
* Provider
* Store
* Tenant
* Agent
* Operation risk
* Endpoint
* Payment risk
* Incident mode

Agent and provider traffic must not starve customer-facing or payment-critical APIs.

## 31. API Audit Requirements

Every command call must preserve:

* Command name
* Command version
* Caller identity
* Caller type
* Tenant
* Store
* Provider
* POS endpoint
* Input reference
* Idempotency key, if applicable
* Authorization result
* Validation result
* State transition result
* Operation ID
* Trace ID
* Correlation ID
* Response category
* Error category, if applicable
* Policy version
* Config version
* Timestamp

Restricted query access must also be audited.

## 32. API Test Requirements

API boundary must be tested for:

* Command success
* Command validation rejection
* Command invalid state rejection
* Command authorization rejection
* Command idempotent replay
* Command idempotency conflict
* Async command acceptance
* Async command recovery path
* Query read without mutation
* Restricted query access denied
* Customer-facing state redaction
* Store-facing state scoping
* Provider raw error normalization
* API version compatibility
* Older local agent compatibility
* Rate limit enforcement
* Audit preservation for commands and restricted queries

API boundary is not production-ready without command/query contract tests.

## 33. Anti-Patterns

The following are prohibited:

* Calling provider APIs directly from core order code
* Letting operator tools update tables directly
* Mixing command and query behavior in one uncontrolled endpoint
* Returning provider raw payloads to customer-facing APIs
* Exposing internal in-doubt details to customers
* Treating async accepted as final success
* Omitting idempotency on retryable mutation commands
* Implementing adapter methods that mutate Gateway state directly
* Allowing local agent to act outside its store binding
* Breaking queued jobs with API version changes
* Creating support scripts that bypass command handlers
* Using database admin scripts as routine recovery workflow

## 34. Relationship With Other Documents

This policy implements the service boundary for:

```
05580 POS Gateway Data Model Event Ledger And State Machine Implementation Boundary Policy
05570 POS Gateway Configuration Change Feature Flag And Provider Version Governance Policy
05510 POS Gateway Operator Recovery Console And Action Authority Policy
05490 POS Provider Capability Profile And Readiness Evidence Policy
05500 POS Provider Test Fixture And Simulation Scenario Policy
05450 POS External API Isolation NonBlocking IO And Connection Pool Protection Policy
05460 POS Polling WebSocket MQTT And Agent Realtime Channel Cost Control Policy
05470 POS InDoubt Transaction Network Cancel Receipt Number And Financial Reconciliation Policy
05480 POS Multi Endpoint Routing Delivery App Port Contention And Malicious Manual Mutation Defense Policy
```

The API command and query boundary is the controlled access layer of POS Gateway implementation.

## 35. Final Rule

The POS Gateway must expose controlled commands and queries, not uncontrolled table access, provider shortcuts, or operational scripts.

If any caller can bypass command validation, state-machine rules, idempotency, authorization, provider abstraction, audit, or configuration versioning, the POS Gateway API and service boundary has failed.
