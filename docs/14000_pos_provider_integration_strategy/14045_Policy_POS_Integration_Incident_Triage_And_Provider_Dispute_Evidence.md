# 14045_Policy_POS_Integration_Incident_Triage_And_Provider_Dispute_Evidence

## 1. Purpose

This policy defines how POS Gateway incidents must be triaged, classified, escalated, investigated, and converted into provider dispute evidence when responsibility is unclear or contested.

The purpose is to ensure that production incidents involving POS providers, local agents, store hardware, payment systems, kitchen printers, store operators, delivery apps, network conditions, or Gateway logic can be separated by evidence instead of blame, assumption, or verbal claim.

A POS integration incident must be handled through structured triage and evidence preservation so that the platform can determine what failed, who owns recovery, what customer or financial impact occurred, and what evidence must be sent to the POS provider, PG/VAN provider, store, finance, support, or legal review.

## 2. Scope

This policy applies to:

* POS provider incident triage
* Provider outage classification
* Provider latency incident
* Provider API rejection incident
* Provider schema drift incident
* Local agent incident
* Store network incident
* Printer incident
* Payment and refund incident
* In-doubt transaction incident
* Waiting and table journey incident
* Inventory conflict incident
* Manual POS mutation incident
* Multi-endpoint routing incident
* Provider dispute evidence packet
* PG/VAN dispute evidence packet
* Store dispute evidence packet
* Finance and legal review evidence
* Incident closure and postmortem

This policy applies to all production and pilot POS-connected flows.

## 3. Core Principle

Incident triage must be evidence-led.

The platform must not accept or assign blame based only on:

* Provider verbal claim
* Store verbal claim
* Operator screenshot
* Customer complaint
* Partial log
* Single API response
* Missing POS receipt
* Missing printout
* Assumption that POS ACK equals success

Every production incident must preserve enough evidence to reconstruct the timeline across platform, Gateway, provider, local agent, payment, printer, store operation, and customer communication.

## 4. Incident Triage Boundary

Incident triage sits above runtime detection and below dispute resolution.

```
[Gateway Runtime Exception]
            |
            v
    [Incident Triage Layer]
            |
   --------------------------------
   |              |               |
   v              v               v
[Provider]     [Store Ops]     [Finance / Legal]
   |              |               |
   v              v               v
[Dispute]     [Recovery]       [Reconciliation]
```

The triage layer must classify the incident and preserve evidence before closure.

## 5. Non-Negotiable Rules

### 5.1 Evidence Before Attribution Rule

Incident ownership must not be assigned until available evidence is collected and reviewed.

If evidence is incomplete, the incident must be marked as evidence incomplete, not guessed.

### 5.2 Timeline Required Rule

Every significant POS integration incident must have a timeline.

The timeline must show events in order across platform, Gateway, POS provider, local agent, payment, kitchen, table, stock, and operator actions where applicable.

### 5.3 Raw Packet Preservation Rule

Provider dispute cases must preserve raw request, raw response, webhook, status query, and error payload references where available.

Redacted raw evidence is required for technical disputes.

### 5.4 Customer And Financial Impact Rule

Incident triage must classify customer impact and financial impact separately.

A technical provider error may have no customer impact.

A small technical timeout may create critical financial exposure if payment state is uncertain.

### 5.5 Closure Requires Evidence Rule

An incident cannot be closed merely because the visible symptom disappeared.

Closure must include evidence, recovery outcome, customer impact result, financial impact result, and owner classification.

### 5.6 Provider Dispute Packet Rule

If provider responsibility is suspected or contested, the system must generate a provider dispute evidence packet.

## 6. Incident Categories

Allowed incident categories include:

```
PROVIDER_API_OUTAGE
PROVIDER_LATENCY_SPIKE
PROVIDER_RATE_LIMIT
PROVIDER_5XX_ERROR
PROVIDER_4XX_UNEXPECTED_REJECTION
PROVIDER_SCHEMA_DRIFT
PROVIDER_WEBHOOK_DELAY
PROVIDER_WEBHOOK_DUPLICATE
PROVIDER_WEBHOOK_MISSING
PROVIDER_STATUS_CONTRADICTION
LOCAL_AGENT_OFFLINE
LOCAL_AGENT_REPLAY_FAILURE
POS_PC_UNREACHABLE
POS_APP_RESTARTED
STORE_NETWORK_FAILURE
PRINTER_FAILURE
PRINTER_PORT_CONTENTION
KITCHEN_PRINT_UNCERTAIN
PAYMENT_APPROVED_POS_MISSING
NETWORK_CANCEL_FAILED
REFUND_STATE_UNKNOWN
RECEIPT_NUMBER_COLLISION
TABLE_STATE_CONFLICT
WAITING_ENTRY_CONFLICT
STOCK_RACE_CONFLICT
MANUAL_POS_MUTATION
SUSPICIOUS_MANUAL_MUTATION
MULTI_ENDPOINT_ROUTING_CONFLICT
SETTLEMENT_RECONCILIATION_MISMATCH
UNKNOWN_POS_INTEGRATION_INCIDENT
```

Incident category must be assigned and may be revised as evidence improves.

## 7. Incident Severity

Allowed severity levels include:

```
INFO
LOW
MEDIUM
HIGH
CRITICAL
FINANCIAL_CRITICAL
CUSTOMER_VISIBLE
STORE_BLOCKING
PROVIDER_WIDE
TENANT_WIDE
SECURITY_OR_LEGAL_RISK
```

Severity must consider:

* Number of affected stores
* Number of affected customers
* Payment exposure
* Refund exposure
* Kitchen execution risk
* Duplicate order risk
* Stock conflict
* Settlement mismatch
* Legal dispute risk
* Provider-wide recurrence
* Customer trust impact

## 8. Ownership Classification

Incident ownership may be classified as:

```
PLATFORM_GATEWAY_OWNED
PROVIDER_OWNED
STORE_LOCAL_INFRA_OWNED
STORE_OPERATOR_OWNED
PAYMENT_PROVIDER_OWNED
VAN_PROVIDER_OWNED
PRINTER_OR_DEVICE_OWNED
DELIVERY_APP_CONFLICT
NETWORK_PROVIDER_OWNED
CUSTOMER_ACTION_TRIGGERED
SHARED_RESPONSIBILITY
UNKNOWN_OWNER
UNDER_INVESTIGATION
```

Ownership classification must cite evidence.

Unknown owner must remain unknown until proven.

## 9. Incident Timeline Requirements

The incident timeline should include:

```
customer_action_time
platform_request_received_time
gateway_validation_time
payment_request_time
payment_approval_time
pos_submission_time
provider_response_time
provider_webhook_time
status_query_time
local_agent_event_time
printer_event_time
kitchen_event_time
operator_action_time
customer_notification_time
refund_or_void_time
reconciliation_time
incident_detection_time
incident_closure_time
```

Timeline must account for clock drift where relevant.

## 10. Evidence Sources

Incident evidence may come from:

* Platform order state
* Gateway normalized request
* Provider outbound request
* Provider raw response
* Provider webhook
* Provider status query
* Adapter logs
* Raw packet audit
* Local agent event
* Local queue record
* POS PC health event
* Printer status event
* Kitchen ticket event
* Payment approval record
* PG status query
* VAN approval record
* Refund or void record
* POS receipt record
* Business day record
* Table state record
* Waiting session record
* Stock hold record
* Operator action record
* Customer notification record
* Provider support response
* Store explanation
* Finance reconciliation result

Evidence must be linked, not copied loosely.

## 11. Initial Triage Checklist

The first triage pass must answer:

1. Is customer payment involved?
2. Is payment state known or in-doubt?
3. Is POS acceptance known?
4. Is kitchen execution known?
5. Is duplicate order risk present?
6. Is refund or void required?
7. Is a customer waiting for a response?
8. Is a store blocked from taking orders?
9. Is the issue isolated to one store or provider-wide?
10. Is local agent or store network involved?
11. Is printer or kitchen output involved?
12. Is provider schema drift suspected?
13. Is manual POS mutation involved?
14. Is finance or settlement affected?
15. Is legal or dispute evidence required?

If any answer is unknown, the incident remains unresolved.

## 12. Provider Incident Triage

Provider-owned or provider-suspected incidents require:

* Provider ID
* Endpoint affected
* Request ID
* Response code
* Error code
* Latency
* Retry result
* Circuit state
* Rate limit evidence
* Status query result
* Webhook evidence
* Provider documentation reference
* Adapter version
* Contract version
* Raw packet reference
* Affected stores
* Affected orders
* Customer impact
* Financial impact

Provider incident evidence must be suitable for escalation to provider support.

## 13. Local Store Infrastructure Triage

Local infrastructure incidents require:

* Store ID
* Agent ID
* Device ID, if available
* POS PC health
* POS app process state
* Local agent heartbeat
* Network reachability
* IP change event
* Printer reachability
* Port contention state
* Local queue depth
* Local retry state
* Store operator report
* Last successful operation
* First failed operation
* Recovery action

Local failure must not be misclassified as provider outage without evidence.

## 14. Payment And Financial Triage

Payment or financial incidents require:

* Payment ID
* Payment group ID
* PG transaction ID
* VAN approval reference, if applicable
* Payment amount
* Payment method
* Approval state
* Capture state
* Void state
* Refund state
* POS receipt state
* Network cancel state
* In-doubt state
* Reconciliation state
* Customer notification state
* Finance owner

Payment uncertainty must be escalated faster than ordinary provider errors.

## 15. Kitchen And Printer Triage

Kitchen and print incidents require:

* Kitchen ticket ID
* Print mode
* POS delegated print or direct print
* POS ACK state
* Printer status
* Print attempt count
* Reprint count
* Duplicate print risk
* Cancel ticket state
* Remake ticket state
* Local agent print evidence
* Store operator confirmation
* Kitchen confirmation
* Customer impact

Kitchen execution uncertainty must not be collapsed into generic order failure.

## 16. Waiting And Table Triage

Waiting and table incidents require:

* Waiting session ID
* Customer entry state
* No-show state
* Table ID
* POS table state
* Platform table state
* Table move or merge event
* Manual entry event
* Prepaid order state
* Kitchen state
* Refund state
* Store operator action
* Customer notification

Journey conflicts must preserve both customer journey evidence and POS table evidence.

## 17. Inventory And Stock Triage

Inventory incidents require:

* Menu item ID
* Option ID, if applicable
* Ingredient ID, if applicable
* Stock hold ID
* Stock state before order
* Stock state after order
* Hold expiration
* Sold-out sync event
* POS manual sale event
* Kitchen shortage event
* Refund or replacement action
* Customer notification

Last-item conflicts require priority review.

## 18. Manual Mutation Triage

Manual POS mutation incidents require:

* Original platform order
* Original payment state
* Original POS submission
* Original POS receipt
* Later POS mutation
* Mutation type
* Mutation actor, if available
* Mutation source
* Time gap
* Platform authorization status
* Settlement impact
* Store explanation
* Suspicion flag
* Finance review result

Suspicious mutation must preserve evidence without overwriting original truth.

## 19. Provider Dispute Evidence Packet

A provider dispute packet should include:

```
dispute_packet_id
provider_id
incident_id
provider_endpoint
provider_contract_version
adapter_version
platform_order_id
store_id
request_timestamp
response_timestamp
webhook_timestamp
raw_request_reference
raw_response_reference
webhook_reference
status_query_reference
error_code
latency
retry_count
idempotency_key
external_order_id
expected_behavior
actual_behavior
customer_impact
financial_impact
requested_provider_action
evidence_hash
generated_at
generated_by
```

The packet must be redacted before external sharing.

## 20. PG/VAN Dispute Evidence Packet

A PG or VAN dispute packet should include:

```
dispute_packet_id
payment_provider
payment_id
payment_group_id
pg_transaction_id
van_approval_reference
platform_order_id
store_id
approval_amount
approval_time
void_request_reference
refund_request_reference
network_cancel_reference
status_query_reference
pos_receipt_reference
in_doubt_id
expected_financial_state
actual_financial_state
customer_notification_state
requested_provider_action
evidence_hash
generated_at
generated_by
```

Financial dispute packets must be access-restricted.

## 21. Store Dispute Evidence Packet

A store dispute packet should include:

```
dispute_packet_id
store_id
tenant_id
legal_entity_id
platform_order_id
payment_id
pos_receipt_reference
kitchen_ticket_reference
original_order_timeline
platform_authorized_actions
pos_local_mutations
manual_mutation_category
settlement_impact
customer_impact
store_explanation
review_outcome
evidence_hash
generated_at
generated_by
```

Store dispute packets must be used carefully and must avoid unsupported accusations.

## 22. Evidence Redaction

External dispute packets must redact or minimize:

* Customer personal data
* Full payment data
* Access tokens
* Internal secrets
* Internal infrastructure topology
* Internal security controls
* Unrelated store data
* Unrelated tenant data
* Staff personal data beyond what is required
* Raw payload fields not relevant to the dispute

Redaction must not destroy internal original evidence.

## 23. Incident Communication

Incident communication must be separated by audience.

### 23.1 Customer Communication

Simple, non-technical, action-oriented.

### 23.2 Store Communication

Operationally useful, avoiding unsupported blame.

### 23.3 Provider Communication

Technical, evidence-based, with request IDs and raw packet references.

### 23.4 Finance Communication

Amount, payment state, refund state, settlement impact.

### 23.5 Legal Or Audit Communication

Immutable evidence, timeline, authority, dispute posture.

The same incident may require different summaries for each audience.

## 24. Closure Requirements

An incident may be closed only when:

* Category is assigned
* Severity is assigned
* Ownership is assigned or unknown is justified
* Customer impact is resolved or explicitly documented
* Financial impact is resolved or routed to finance
* Required recovery actions are complete
* Required evidence is attached
* Dispute packet is generated if needed
* Post-incident follow-up is created if needed
* Provider readiness downgrade is considered if applicable

Closure without evidence is prohibited.

## 25. Provider Readiness Downgrade

A provider readiness profile must be reviewed and possibly downgraded when:

* Incident repeats
* Provider contract behavior differs from documentation
* Provider fails to support required dispute investigation
* Schema drift occurs without notice
* Refund or receipt behavior is unreliable
* Timeout or rate limit behavior is worse than profile
* Webhook behavior is unreliable
* Local agent path repeatedly fails
* Financial reconciliation mismatch recurs

Incident triage must feed provider readiness.

## 26. Post-Incident Review

High-severity incidents require post-incident review.

Review should include:

* What happened
* What was detected
* What was missed
* Customer impact
* Financial impact
* Store impact
* Provider impact
* Recovery time
* Evidence completeness
* Operator action quality
* Policy gap
* Test fixture gap
* Provider readiness change
* Required remediation

Post-incident review must produce action items when needed.

## 27. Audit Requirements

Every incident triage and dispute transition must preserve:

* Incident ID
* Category
* Severity
* Ownership classification
* Store ID
* Provider ID
* Platform order ID, if applicable
* Payment ID, if applicable
* Waiting session ID, if applicable
* Table ID, if applicable
* Kitchen ticket ID, if applicable
* Stock hold ID, if applicable
* Queue job ID, if applicable
* Raw packet ID, if applicable
* Evidence references
* Timeline references
* Customer impact
* Financial impact
* Operator action
* Provider contact action
* Store contact action
* Finance review action
* Dispute packet ID, if applicable
* Closure outcome
* Trace ID
* Correlation ID
* Idempotency key, if applicable
* Gateway version
* Adapter version
* Policy version
* Timestamp

Audit evidence must be immutable and retention-managed.

## 28. Test Requirements

Incident triage and dispute handling must be tested for:

* Provider outage triage
* Provider latency triage
* Provider schema drift triage
* Local agent offline triage
* Store network failure triage
* Printer failure triage
* Payment approved POS missing triage
* Network cancel failed triage
* Waiting table conflict triage
* Stock race triage
* Manual POS mutation triage
* Suspicious mutation review
* Provider dispute packet generation
* PG/VAN dispute packet generation
* Store dispute packet generation
* Evidence redaction
* Incident closure with evidence
* Closure blocked without evidence
* Provider readiness downgrade after incident
* Post-incident review creation

The incident triage process cannot be production-ready without dispute evidence test coverage.

## 29. Anti-Patterns

The following are prohibited:

* Assigning blame without evidence
* Closing incident because symptoms disappeared
* Sending unredacted raw payload to provider
* Treating customer complaint as full evidence
* Treating store screenshot as full evidence
* Treating provider verbal denial as proof
* Treating POS ACK as kitchen success
* Treating PG approval as POS acceptance
* Treating missing POS receipt as proof that payment did not happen
* Ignoring clock drift in timeline
* Failing to update provider readiness after repeated incident
* Reusing dispute packet from another incident without verification
* Accusing store of malicious behavior without review and evidence

## 30. Relationship With Other Documents

This policy operationalizes and depends on:

```
05300 POS Gateway Resilience And Field Exception Catalog Readme
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
05440 POS VAN PG Tax Sales Channel And Unpaid Order Reconciliation Policy
05450 POS External API Isolation NonBlocking IO And Connection Pool Protection Policy
05460 POS Polling WebSocket MQTT And Agent Realtime Channel Cost Control Policy
05470 POS InDoubt Transaction Network Cancel Receipt Number And Financial Reconciliation Policy
05480 POS Multi Endpoint Routing Delivery App Port Contention And Malicious Manual Mutation Defense Policy
05490 POS Provider Capability Profile And Readiness Evidence Policy
05500 POS Provider Test Fixture And Simulation Scenario Policy
05510 POS Gateway Operator Recovery Console And Action Authority Policy
```

Incident triage is the evidence bridge between runtime failure, provider accountability, customer recovery, finance reconciliation, and legal defense.

## 31. Final Rule

The POS Gateway must always be able to prove what happened before it argues who is responsible.

If a provider, store, payment company, local device, delivery app, or platform component can deny responsibility and the Gateway cannot reconstruct the cross-system timeline with preserved evidence, the incident triage and provider dispute boundary has failed.
