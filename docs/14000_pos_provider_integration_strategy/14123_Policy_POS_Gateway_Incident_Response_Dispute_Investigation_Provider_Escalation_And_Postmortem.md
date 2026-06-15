# 14123_Policy_POS_Gateway_Incident_Response_Dispute_Investigation_Provider_Escalation_And_Postmortem

## 1. Purpose

This document defines the incident response, dispute investigation, provider escalation, and postmortem policy for the POS Gateway Implementation layer.

The POS Gateway is a transaction-critical boundary between customer order flow, store operations, POS records, payment references, cancellation/refund behavior, receipt identity, and settlement evidence.

Therefore, incident response must not be treated as ordinary application troubleshooting.  
A POS Gateway incident may become a customer dispute, store revenue mismatch, accounting variance, provider escalation, or regulatory evidence issue.

This policy exists to ensure that:

- POS Gateway incidents are classified by financial and customer impact;
- transaction evidence is preserved before corrective action;
- affected customers, orders, payments, cancellations, refunds, and receipts are identifiable;
- provider escalation is supported by safe and structured evidence;
- disputes can be investigated without guessing;
- postmortems produce corrective controls, not only narrative explanations;
- incident handling does not corrupt transaction history.

---

## 2. Scope

This policy applies to all POS Gateway incidents, including:

- POS order write failure;
- duplicate POS order;
- missing POS order;
- payment success without POS confirmation;
- POS confirmation without payment success;
- duplicate payment;
- cancellation failure;
- refund failure;
- duplicate cancellation;
- duplicate refund;
- receipt identity mismatch;
- KDS routing failure;
- duplicate kitchen ticket;
- settlement variance;
- reconciliation variance;
- credential failure;
- provider outage;
- adapter bug;
- migration/cutover incident;
- rollback incident;
- monitoring blind spot;
- customer dispute;
- store operator escalation.

This document governs incident investigation and response after an abnormal condition is detected.

---

## 3. Core Principle

The first responsibility during a POS Gateway incident is to preserve evidence and prevent additional harm.

The gateway must not rush to “fix” state by overwriting records.

Correct incident handling follows this order:

```text
1. Stop further unsafe action
2. Preserve transaction evidence
3. Classify customer and financial impact
4. Identify affected scope
5. Stabilize store operation
6. Protect customer rights
7. Reconcile source systems
8. Escalate to provider where needed
9. Apply controlled correction
10. Record postmortem and prevention action
```

A clean-looking database after manual editing is not a valid incident resolution.  
A fully traceable incident with controlled correction is valid.

---

## 4. Incident Classification

POS Gateway incidents must be classified by both technical cause and business impact.

### 4.1 Technical Classification

| Class | Description |
|---|---|
| `adapter_error` | POS provider adapter returned unexpected behavior |
| `provider_error` | External POS/payment/KDS provider failed or degraded |
| `credential_error` | Credential expired, invalid, revoked, or mis-scoped |
| `configuration_error` | Runtime flag, mapping, or environment configuration incorrect |
| `idempotency_error` | Duplicate prevention or idempotency store failed |
| `retry_error` | Retry behavior created or risked duplicate execution |
| `queue_error` | Queue delay, stuck job, or dead-letter condition occurred |
| `reconciliation_error` | Comparison across systems failed or was unavailable |
| `migration_error` | Backfill, import, activation, or cutover state caused issue |
| `monitoring_error` | Alerting, dashboard, or audit visibility failed |
| `operator_error` | Manual or staff action conflicted with gateway state |
| `unknown_error` | Cause not yet determined |

### 4.2 Business Impact Classification

| Class | Description |
|---|---|
| `no_business_impact` | Technical anomaly only |
| `store_workflow_impact` | Staff flow slowed or manual fallback needed |
| `customer_wait_impact` | Customer experienced delay or unclear status |
| `customer_payment_impact` | Customer may have been charged incorrectly |
| `refund_or_cancel_impact` | Cancellation/refund may be missing, duplicated, or delayed |
| `receipt_evidence_impact` | Receipt or proof of transaction is missing or inconsistent |
| `settlement_impact` | Settlement, closing, or accounting total may be wrong |
| `financial_integrity_impact` | Duplicate/missing financial action possible |
| `regulatory_evidence_impact` | Evidence required for audit or dispute may be incomplete |

---

## 5. Incident Severity

Incident severity must be assigned based on customer, store, and financial risk.

| Severity | Meaning | Required Response |
|---|---|---|
| `S0_observation` | No immediate impact; record for trend | Monitor |
| `S1_minor` | Store inconvenience or recoverable delay | Support and document |
| `S2_moderate` | Transaction uncertainty or staff intervention required | Create incident case |
| `S3_major` | Customer-facing or financial mismatch risk | Incident command required |
| `S4_critical` | Duplicate/missing payment, cancellation, refund, or settlement risk | Freeze affected route |
| `S5_emergency` | Systemic transaction harm or unsafe active routing | Execute rollback consideration immediately |

Severity must not be downgraded until evidence confirms that affected transactions are safe.

---

## 6. Incident Case Creation

Every S2 or higher incident must create an incident case.

Required incident case fields:

```text
incident_id
severity
technical_classification
business_impact_classification
tenant_id
store_id
pos_provider_code
adapter_version
environment
cutover_epoch_id
first_detected_at
detected_by
current_health_state
affected_transaction_count
affected_customer_count
affected_amount_estimate
route_status
rollback_status
incident_commander
reconciliation_case_id
provider_escalation_id
status
```

Incident cases must be append-only for material status history.  
Updates must be recorded as timeline entries or linked action records.

---

## 7. Immediate Containment

Incident response must first contain additional harm.

Possible containment actions:

- disable affected POS write route;
- pause unsafe retry worker;
- disable cancellation automation;
- disable refund automation;
- disable KDS routing;
- move store to manual confirmation;
- mark affected transactions as review-required;
- prevent duplicate resubmission;
- freeze configuration changes;
- block production expansion;
- alert store operator;
- initiate rollback consideration.

Containment must be scoped to the minimum safe boundary, but customer and financial protection overrides convenience.

---

## 8. Evidence Preservation

Before corrective action, the system must preserve evidence.

Evidence to preserve:

- gateway transaction record;
- order event log;
- payment reference log;
- cancellation/refund request log;
- provider request payload reference;
- provider response payload reference;
- idempotency key;
- retry history;
- queue history;
- dead-letter entry;
- POS order identifier;
- POS receipt identifier;
- payment approval identifier;
- settlement reference;
- audit event chain;
- staff manual action record;
- customer-facing state snapshot;
- dashboard health snapshot.

Evidence must be redacted where necessary, but redaction must not destroy investigability.

---

## 9. Affected Scope Identification

Incident investigation must identify affected scope.

Required scope dimensions:

- tenant;
- store;
- provider;
- adapter version;
- routing flag state;
- transaction type;
- payment method;
- terminal;
- table zone;
- business date;
- time window;
- queue batch;
- retry batch;
- cutover epoch;
- import batch where applicable.

The incident must not be closed until affected scope is either fully identified or explicitly marked unknown with containment.

---

## 10. Transaction Impact Review

Each affected transaction must be classified.

Required transaction impact states:

| State | Meaning |
|---|---|
| `safe_no_action` | Evidence confirms no correction required |
| `needs_staff_confirmation` | Store staff must confirm operational state |
| `needs_provider_lookup` | Provider/POS lookup required |
| `needs_payment_lookup` | Payment provider lookup required |
| `needs_reconciliation` | Cross-system comparison required |
| `needs_customer_contact` | Customer-facing follow-up required |
| `needs_manual_refund_review` | Refund safety must be reviewed manually |
| `needs_manual_pos_entry` | POS entry may need manual correction |
| `duplicate_risk` | Duplicate financial/order action possible |
| `missing_action_risk` | Expected financial/order action may be missing |
| `unresolved` | Not enough evidence yet |

Transaction impact classification must be visible to operations staff.

---

## 11. Customer Dispute Investigation

A customer dispute may involve:

- charged but order missing;
- order completed but receipt missing;
- duplicate charge;
- failed refund;
- duplicate refund;
- cancellation not reflected;
- wrong order state shown;
- waiting/order handoff mismatch;
- store claims one state while customer evidence shows another.

Customer dispute investigation must collect:

- customer-provided evidence;
- gateway transaction ID where available;
- payment approval reference;
- receipt number;
- order time;
- store;
- payment method;
- displayed customer status;
- staff action history;
- POS/provider lookup result;
- reconciliation result.

The system must not tell the customer to pay again until duplicate charge risk is cleared.

---

## 12. Payment Dispute Handling

Payment-related incidents require stricter handling.

Payment dispute categories:

| Category | Required Handling |
|---|---|
| `charged_order_missing` | Verify payment provider and POS state before correction |
| `order_success_payment_unknown` | Confirm payment state before marking complete |
| `duplicate_charge_suspected` | Freeze additional payment attempts and escalate |
| `refund_missing` | Verify original payment and refund provider state |
| `refund_duplicate_suspected` | Block further refund and escalate |
| `approval_reference_missing` | Locate provider evidence or mark unresolved |
| `settlement_mismatch` | Create reconciliation and settlement case |

Payment dispute resolution must be evidence-based.  
Manual adjustment without provider evidence must be marked as manual exception.

---

## 13. Cancellation and Refund Incident Handling

Cancellation and refund incidents are high-risk because duplicate action may directly affect customer funds.

Required controls:

- original transaction reference must be verified;
- duplicate cancellation/refund prevention must be checked;
- provider response must be preserved;
- uncertain result must become manual review state;
- customer-facing “completed” message must be blocked until evidence exists;
- additional retry must be blocked if duplicate risk exists;
- payment/settlement lead must review S3 or higher refund incidents.

Refund incident correction must never be executed blindly.

---

## 14. POS Order Incident Handling

POS order incidents may include:

- order not created in POS;
- order created twice;
- order created with wrong items;
- order created with wrong amount;
- order created under wrong table;
- order created but gateway did not receive confirmation;
- POS receipt not linked;
- staff manually entered duplicate order.

Required investigation data:

- gateway order ID;
- POS order ID;
- receipt ID;
- table/terminal mapping;
- item mapping;
- price mapping;
- option/modifier mapping;
- idempotency key;
- retry history;
- staff manual action record.

Duplicate cook and duplicate charge risks must both be considered.

---

## 15. KDS Incident Handling

KDS incidents may include:

- ticket missing;
- duplicate kitchen ticket;
- wrong lane;
- wrong modifiers;
- cancellation not reflected;
- remade order due to unclear state.

Required handling:

- confirm whether food was prepared;
- identify whether duplicate cook occurred;
- compare POS/KDS/gateway state;
- preserve kitchen ticket evidence;
- classify customer impact;
- classify inventory/waste impact where relevant;
- prevent retry from creating additional ticket.

KDS incidents must involve store operations owner when food preparation state is unclear.

---

## 16. Provider Escalation Policy

Provider escalation is required when internal evidence cannot resolve the incident or when provider behavior appears abnormal.

Provider escalation may be needed for:

- unknown POS write result;
- provider timeout after mutation request;
- provider returned inconsistent status;
- provider authentication failure;
- provider duplicate handling unclear;
- cancellation/refund state unknown;
- receipt identity missing;
- settlement record mismatch;
- provider outage;
- provider API contract violation.

Provider escalation must use safe, minimal evidence.

---

## 17. Provider Escalation Packet

Provider escalation packet must include:

```text
provider_escalation_id
incident_id
tenant_id
store_id
provider_code
provider_account_reference
safe_transaction_reference
provider_request_timestamp
provider_response_timestamp
provider_error_code
gateway_error_classification
affected_transaction_count
business_impact_summary
requested_provider_action
urgency
contact_channel
created_at
created_by
```

Provider escalation packet may include redacted request/response excerpts when necessary.

Provider escalation packet must not include:

- raw credentials;
- full card data;
- unnecessary personal information;
- unrelated transaction records;
- internal secret architecture details.

---

## 18. Reconciliation During Incident

Incident investigation must use reconciliation when financial state is uncertain.

Reconciliation dimensions:

- gateway order count;
- POS order count;
- gateway payment count;
- provider payment count;
- cancellation count;
- refund count;
- receipt count;
- gross sales;
- net sales;
- settlement reference;
- transaction-level matching;
- amount-level matching;
- business date matching.

If reconciliation cannot run, the incident severity must reflect monitoring/reconciliation blind spot.

---

## 19. Manual Correction Policy

Manual correction may be required but must be controlled.

Allowed manual corrections:

- mark transaction as review-required;
- attach missing provider reference with evidence;
- create adjustment record;
- create manual POS entry reference;
- create manual refund review record;
- create reconciliation annotation;
- classify incident outcome;
- close duplicate candidate with evidence.

Prohibited manual corrections:

- overwriting original source identifiers;
- deleting failed transaction attempts;
- changing original financial amount without adjustment record;
- marking refund complete without provider evidence;
- marking payment failed when provider state is unknown;
- hiding duplicate risk by merging records silently;
- removing audit events.

Manual correction must create an audit event.

---

## 20. Customer Protection Actions

Customer protection actions may include:

- staff confirmation before asking for repayment;
- receipt reissue after evidence confirmation;
- manual refund escalation;
- apology/ 안내 message;
- cancellation follow-up;
- duplicate charge investigation;
- order remake decision;
- store credit or goodwill handling where business policy permits;
- delayed status notification.

Customer protection action must be linked to incident case when related to gateway failure.

---

## 21. Incident Communication Policy

Incident communication must be clear and role-appropriate.

### 21.1 Internal Technical Communication

Must include:

- incident ID;
- severity;
- affected route;
- affected transaction type;
- current containment state;
- requested action;
- evidence location.

### 21.2 Store Communication

Must include:

- current operational status;
- staff action required;
- customer 안내 wording;
- manual fallback instruction;
- escalation contact.

### 21.3 Customer Communication

Must avoid internal jargon and avoid unverified claims.

Allowed customer messages:

```text
주문/결제 상태를 확인 중입니다.
중복 처리되지 않도록 확인 후 안내드리겠습니다.
직원이 직접 확인 후 처리해드리겠습니다.
환불 상태 확인 후 안내드리겠습니다.
```

Prohibited customer messages:

```text
다시 결제하시면 됩니다.
결제 실패입니다.
환불 완료입니다.
주문 완료입니다.
```

when those statements are not supported by evidence.

---

## 22. Postmortem Requirement

Every S3 or higher incident must produce a postmortem.

S2 incidents may require postmortem when:

- repeated;
- provider-related;
- customer-visible;
- financial variance occurred;
- rollback was considered;
- monitoring failed;
- manual correction was required.

Postmortem must focus on prevention and control improvement, not blame.

---

## 23. Postmortem Structure

Required postmortem sections:

```text
incident_summary
customer_impact
store_impact
financial_impact
timeline
detection_method
what_happened
why_it_happened
what_worked
what_failed
evidence_preserved
containment_actions
rollback_decision
reconciliation_result
provider_escalation_result
root_cause
contributing_factors
corrective_actions
preventive_actions
owner_assignments
due_dates
closure_criteria
```

The postmortem must link to incident case, affected transactions, audit events, and reconciliation records.

---

## 24. Corrective Action Policy

Corrective actions must be trackable.

Corrective action types:

- adapter fix;
- retry policy change;
- idempotency improvement;
- mapping validation improvement;
- monitoring rule addition;
- alert threshold change;
- runbook update;
- staff procedure update;
- provider contract clarification;
- smoke test addition;
- readiness gate addition;
- rollback control improvement;
- reconciliation rule improvement;
- documentation update.

Each corrective action must include:

```text
action_id
incident_id
owner
action_type
description
priority
due_date
verification_method
status
closed_at
```

An incident may not be closed as prevention-complete until corrective action status is reviewed.

---

## 25. Recurrence Prevention

If the same incident pattern repeats, escalation level must increase.

Repeated incident patterns must trigger:

- error budget review;
- feature freeze;
- adapter promotion block;
- provider escalation;
- readiness reassessment;
- SLO review;
- runbook revision;
- additional smoke test requirement;
- executive/operator review where necessary.

Recurring customer-impacting incidents must not be normalized as operational noise.

---

## 26. Incident Closure Criteria

An incident may be closed only when:

- affected scope is identified;
- affected transactions are classified;
- customer-impact actions are completed or assigned;
- financial impact is reconciled or formally unresolved with owner;
- provider escalation is complete or tracked;
- manual corrections are audited;
- rollback state is resolved;
- monitoring has returned to reliable state;
- postmortem is completed where required;
- corrective actions are created.

Incident closure does not require every long-term corrective action to be complete, but ownership and verification path must exist.

---

## 27. Incident Evidence Retention

Incident evidence must be retained according to financial audit and consumer protection requirements.

Evidence retention must include:

- incident case;
- timeline;
- transaction records;
- audit events;
- logs and traces;
- provider escalation packet;
- reconciliation result;
- manual correction records;
- customer protection action records;
- postmortem;
- corrective action list.

Evidence must remain searchable by:

- incident ID;
- transaction ID;
- store;
- business date;
- provider;
- approval reference;
- receipt reference;
- cutover epoch.

---

## 28. Dashboard Requirements

The operations dashboard must show:

- open incidents;
- incident severity;
- affected store/provider;
- affected transaction count;
- affected amount estimate;
- containment state;
- rollback state;
- reconciliation state;
- customer-impact flag;
- provider escalation state;
- owner;
- next action;
- overdue corrective actions.

The dashboard must not allow critical incidents to disappear merely because alert noise stopped.

---

## 29. Prohibited Practices

The following practices are prohibited:

- deleting failed transaction evidence;
- silently editing transaction state to close incident;
- retrying uncertain payment/refund blindly;
- asking customer to pay again before duplicate charge risk is cleared;
- closing incident without affected transaction classification;
- suppressing incident because provider dashboard appears normal;
- blaming store staff without reviewing gateway evidence;
- escalating to provider with raw credentials or excessive customer data;
- marking refund/cancellation complete without provider evidence;
- treating repeated incidents as acceptable background failure.

---

## 30. Minimum Acceptance Criteria

The POS Gateway incident response process is acceptable only when:

- incident severity model exists;
- incident case model exists;
- containment actions are defined;
- evidence preservation is mandatory;
- affected transaction classification exists;
- customer dispute process exists;
- payment/cancellation/refund incident handling exists;
- provider escalation packet exists;
- manual correction is audited;
- postmortem structure exists;
- corrective action tracking exists;
- incident closure criteria exist;
- incident evidence retention exists;
- dashboard visibility exists.

---

## 31. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_incidents
pos_gateway_incident_timelines
pos_gateway_incident_affected_transactions
pos_gateway_incident_containment_actions
pos_gateway_customer_dispute_cases
pos_gateway_provider_escalations
pos_gateway_manual_corrections
pos_gateway_incident_reconciliation_links
pos_gateway_postmortems
pos_gateway_corrective_actions
pos_gateway_incident_evidence_packets
```

Recommended services:

```text
IncidentCaseService
IncidentSeverityClassifier
IncidentContainmentService
EvidencePreservationService
AffectedTransactionClassifier
CustomerDisputeInvestigationService
PaymentDisputeService
CancelRefundIncidentService
ProviderEscalationService
ManualCorrectionService
PostmortemService
CorrectiveActionTracker
IncidentClosureService
```

Recommended event types:

```text
pos_gateway.incident.detected
pos_gateway.incident.classified
pos_gateway.incident.severity_changed
pos_gateway.incident.containment_started
pos_gateway.incident.containment_completed
pos_gateway.incident.transaction_classified
pos_gateway.incident.customer_dispute_opened
pos_gateway.incident.provider_escalated
pos_gateway.incident.manual_correction_recorded
pos_gateway.incident.reconciliation_linked
pos_gateway.incident.postmortem_created
pos_gateway.incident.corrective_action_created
pos_gateway.incident.closed
```

---

## 32. Relationship To Adjacent Documents

This document is related to:

- POS Gateway operational monitoring, alerting, SLO, error budget, and runtime health policy;
- POS Gateway production cutover runbook, incident command, and rollback execution policy;
- POS Gateway production readiness checklist, smoke test, and operational acceptance policy;
- POS Gateway migration, backfill, cutover, existing transaction protection, and data integrity policy;
- POS Gateway idempotency and retry policy;
- POS Gateway reconciliation policy;
- POS Gateway cancellation and refund policy;
- POS Gateway settlement and accounting policy;
- POS Gateway audit evidence policy;
- POS Gateway runtime configuration and credential activation policy.

Where conflict exists, this document governs incident response, dispute investigation, provider escalation, and postmortem behavior.

---

## 33. Summary

A POS Gateway incident is not just a technical failure.

It can affect:

- customer trust;
- payment correctness;
- cancellation/refund rights;
- store workflow;
- receipt evidence;
- settlement totals;
- accounting reports;
- provider accountability;
- regulatory evidence.

The correct response is not to make the dashboard green as quickly as possible.  
The correct response is to preserve evidence, stop further harm, classify affected transactions, protect the customer, reconcile the truth, escalate with safe evidence, and prevent recurrence.

A visible, well-contained incident is recoverable.  
An incident hidden by manual edits is a future financial and legal risk.