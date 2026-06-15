# 14120_Policy_POS_Gateway_Production_Cutover_Runbook_Incident_Command_And_Rollback_Execution

## 1. Purpose

This document defines the production cutover runbook, incident command structure, and rollback execution policy for the POS Gateway Implementation layer.

The POS Gateway is not a normal application deployment boundary.  
Once active, it may directly affect store sales, payment confirmation, receipt issuance, cancellation, refund, KDS routing, settlement evidence, and customer protection.

Therefore, production cutover must be treated as a controlled operational event, not merely a code release.

This policy exists to ensure that:

- production cutover is executed only through an approved runbook;
- each role knows its responsibility before, during, and after cutover;
- incidents during cutover are escalated through a clear command structure;
- rollback is executable without deleting transaction evidence;
- store operators can continue business during gateway instability;
- customer-impacting failures are handled before internal convenience;
- every production transition leaves an audit trail.

---

## 2. Scope

This policy applies to all POS Gateway production cutover events, including:

- first production activation for a store;
- provider adapter production activation;
- payment write-path activation;
- POS order write-path activation;
- cancellation/refund automation activation;
- KDS routing activation;
- store-by-store rollout;
- provider migration cutover;
- emergency re-cutover after rollback;
- production credential activation tied to routing change;
- major adapter version switch;
- runtime configuration change that affects financial transaction behavior.

This document governs the operational execution of cutover.  
Migration and backfill data protection is governed by the previous migration/backfill policy.

---

## 3. Core Principle

Production cutover must be reversible at the routing level but irreversible at the evidence level.

That means:

- routing may be disabled, paused, or rolled back;
- new writes may be frozen;
- provider integration may be reverted to manual mode;
- but transaction events, cutover records, errors, retries, and reconciliation evidence must never be erased.

The gateway must preserve what happened even when the cutover fails.

---

## 4. Cutover Types

The POS Gateway must classify each production cutover type.

| Cutover Type | Description | Risk Level |
|---|---|---|
| `read_only_cutover` | Gateway reads POS/provider data but does not write | Low |
| `shadow_cutover` | Gateway processes events in parallel without active store impact | Medium |
| `order_write_cutover` | Gateway writes orders into POS | High |
| `payment_reference_cutover` | Gateway attaches payment references | High |
| `payment_execution_cutover` | Gateway participates in live payment execution | Critical |
| `cancel_refund_cutover` | Gateway executes cancellation/refund flow | Critical |
| `kds_routing_cutover` | Gateway routes production kitchen tickets | High |
| `full_active_cutover` | Gateway becomes active order/payment/POS routing path | Critical |
| `provider_migration_cutover` | Store moves from one POS/provider path to another | Critical |
| `rollback_recovery_cutover` | Previously rolled-back route is re-enabled | Critical |

Critical cutovers require explicit approval, rollback owner assignment, and post-cutover reconciliation.

---

## 5. Cutover Command Structure

Every production cutover must define a command structure.

Required roles:

| Role | Responsibility |
|---|---|
| Cutover Commander | Owns final go/no-go and cutover execution |
| Technical Lead | Owns adapter, runtime, logs, deployment, and routing state |
| Store Operations Lead | Owns store staff coordination and manual fallback |
| Payment/Settlement Lead | Owns payment, cancellation, refund, and settlement monitoring |
| Reconciliation Lead | Owns post-cutover data comparison and variance handling |
| Incident Scribe | Records timeline, decisions, incidents, and evidence |
| Rollback Owner | Executes rollback when criteria are met |
| Approval Owner | Authorizes activation or emergency rollback where required |

For small early-stage operations, one person may hold multiple roles, but the role assignments must still be explicit.

---

## 6. Pre-Cutover Runbook Requirements

Before production cutover starts, the runbook must contain:

- target tenant;
- target store;
- POS provider;
- adapter version;
- cutover type;
- planned cutover window;
- expected business impact;
- current mode;
- target mode;
- production credential reference;
- affected routing paths;
- affected transaction types;
- go/no-go checklist;
- rollback trigger criteria;
- rollback steps;
- emergency manual operation steps;
- monitoring dashboard links or references;
- communication channel;
- responsible operators;
- approval record.

The runbook must be prepared before the cutover window.  
A cutover must not begin from memory or chat-only instructions.

---

## 7. Pre-Cutover Checklist

The following checklist must pass before cutover.

### 7.1 Business Readiness

Required:

- store manager or responsible operator is aware;
- staff knows whether gateway is active, shadow, or manual;
- manual POS entry fallback is available;
- manual payment/cancellation/refund escalation path is available;
- peak-hour risk reviewed;
- expected customer impact reviewed;
- cutover window approved.

### 7.2 Technical Readiness

Required:

- latest deployment version confirmed;
- adapter version confirmed;
- runtime configuration confirmed;
- feature flags confirmed;
- environment separation confirmed;
- production credential activation confirmed;
- sandbox credential leakage check passed;
- idempotency key path active;
- retry policy active;
- timeout policy active;
- dead-letter handling active;
- audit event emission active;
- reconciliation job active.

### 7.3 Data Readiness

Required:

- migration/backfill status reviewed;
- unresolved historical records reviewed;
- cutover epoch prepared;
- current business day boundary confirmed;
- POS closing state understood;
- duplicate prevention active;
- in-flight transaction policy active;
- store mapping confirmed;
- terminal mapping confirmed;
- payment method mapping confirmed.

### 7.4 Monitoring Readiness

Required:

- POS write success rate visible;
- POS write failure rate visible;
- payment/POS mismatch visible;
- cancellation/refund failure visible;
- queue backlog visible;
- retry count visible;
- dead-letter count visible;
- adapter latency visible;
- provider error rate visible;
- reconciliation variance visible;
- customer-impacting errors visible.

### 7.5 Rollback Readiness

Required:

- rollback owner assigned;
- rollback command tested or rehearsed;
- rollback target mode defined;
- rollback impact understood;
- manual fallback ready;
- rollback communication phrase prepared;
- post-rollback reconciliation owner assigned.

---

## 8. Go / No-Go Decision

The cutover commander must make an explicit go/no-go decision.

A `GO` decision requires:

- all mandatory gates passed;
- no unresolved critical variance;
- production credential confirmed;
- rollback path confirmed;
- store operation fallback confirmed;
- monitoring active;
- responsible roles available.

A `NO-GO` decision must be recorded when:

- credential state is uncertain;
- adapter health check fails;
- duplicate prevention is inactive;
- reconciliation tooling is unavailable;
- store staff is not informed;
- rollback owner is unavailable;
- payment provider instability is detected;
- POS provider maintenance is active;
- unresolved high-risk migration variance exists.

No-go is not failure.  
A no-go decision is a controlled protection action.

---

## 9. Cutover Execution Sequence

The recommended sequence is:

```text
1. Confirm store and provider target
2. Confirm current mode
3. Confirm production credential reference
4. Create or activate cutover epoch
5. Freeze risky configuration changes
6. Confirm monitoring visibility
7. Enable read or shadow mode if applicable
8. Enable limited write path
9. Execute test transaction or controlled production probe
10. Verify POS receipt/order evidence
11. Verify gateway event evidence
12. Verify payment/POS linkage
13. Expand routing scope if approved
14. Monitor first transaction window
15. Record cutover state
16. Start post-cutover reconciliation
```

For critical cutovers, the system should avoid enabling every capability at once.  
Order write, payment reference, cancellation, refund, and KDS routing should be activated in controlled phases where possible.

---

## 10. Controlled Production Probe

A controlled production probe is a small real-world validation step.

Examples:

- one low-value test order;
- one staff-controlled order;
- one manual confirmation transaction;
- one order-write-only transaction;
- one payment-reference-only transaction;
- one cancellation test where legally and operationally safe.

The probe must verify:

- gateway order ID;
- POS order ID;
- receipt number;
- approval reference if payment is involved;
- audit event;
- staff visibility;
- customer-visible state;
- reconciliation visibility.

Probe transactions must not be hidden.  
They must be treated as real evidence or clearly marked according to the store’s accounting and test transaction policy.

---

## 11. Cutover Expansion Policy

After the initial probe, cutover may expand by scope.

Possible expansion dimensions:

- from shadow to active;
- from order-only to payment-linked;
- from one terminal to all terminals;
- from one table zone to all table zones;
- from one payment method to all payment methods;
- from order write to cancellation support;
- from cancellation support to refund automation;
- from POS-only to KDS routing;
- from one store to multiple stores.

Expansion must stop when:

- error rate exceeds threshold;
- mismatch appears between POS and gateway;
- staff cannot operate the flow;
- customer-facing status becomes unclear;
- settlement evidence is not created;
- cancellation/refund path is uncertain;
- provider response becomes unstable.

---

## 12. Incident Command Policy

Any cutover incident must be assigned an incident command state.

Incident levels:

| Level | Meaning | Required Response |
|---|---|---|
| `L0_observation` | Minor anomaly, no customer or financial impact | Monitor and record |
| `L1_operational_issue` | Staff inconvenience or non-critical delay | Support store and continue if safe |
| `L2_transaction_risk` | Order/payment/POS mismatch possible | Pause expansion and reconcile |
| `L3_customer_impact` | Customer may be charged, blocked, or misinformed | Escalate immediately |
| `L4_financial_integrity_risk` | Duplicate/missing payment, refund, or settlement risk | Freeze affected route and prepare rollback |
| `L5_emergency_rollback` | Active cutover causes systemic financial or operational harm | Execute rollback |

Incident level may only be downgraded after evidence confirms risk reduction.

---

## 13. Incident Timeline Requirements

The incident scribe must record a timeline.

Required timeline entries:

- cutover start time;
- mode change time;
- first transaction time;
- first success time;
- first failure time;
- detection time;
- escalation time;
- decision time;
- rollback trigger time if applicable;
- rollback execution time;
- customer impact confirmation;
- reconciliation start time;
- reconciliation completion time;
- final incident closure time.

The timeline must preserve exact timestamps and timezone.

---

## 14. Rollback Trigger Criteria

Rollback must be executed or formally considered when any critical trigger occurs.

Critical triggers:

- duplicate payment detected;
- duplicate POS order detected;
- payment success without recoverable POS order evidence;
- POS order success without recoverable payment state;
- cancellation/refund failure affecting customers;
- receipt issuance failure for completed payment;
- high POS write failure rate;
- gateway adapter timeout spike;
- provider authentication failure;
- production credential failure;
- settlement evidence missing;
- store cannot operate normal flow;
- customer queue disruption caused by gateway;
- manual fallback cannot keep up;
- monitoring blind spot discovered after activation.

Rollback consideration must be documented even if rollback is not executed.

---

## 15. Rollback Execution Policy

Rollback must disable the risky route without destroying records.

Allowed rollback actions:

- disable active POS write flag;
- disable payment execution flag;
- disable automated cancellation/refund flag;
- disable KDS production routing flag;
- return to manual POS entry;
- route new orders to staff confirmation;
- mark in-flight transactions as reconciliation-required;
- pause retry workers if retries may duplicate writes;
- preserve dead-letter records;
- notify store operator;
- start post-rollback reconciliation.

Prohibited rollback actions:

- deleting transaction rows;
- deleting gateway events;
- deleting failed write records;
- changing original timestamps;
- reusing idempotency keys;
- marking uncertain records as successful without evidence;
- hiding customer-impacting failures;
- disabling audit logging.

Rollback must be treated as a controlled state transition, not a cleanup operation.

---

## 16. Rollback Sequence

The recommended rollback sequence is:

```text
1. Declare rollback consideration
2. Assign incident level
3. Freeze cutover expansion
4. Identify affected route
5. Disable affected write path
6. Pause unsafe retries
7. Preserve all in-flight records
8. Notify store operator
9. Switch staff to manual fallback
10. Mark uncertain transactions
11. Start reconciliation case
12. Confirm no new writes use failed route
13. Record rollback completion
14. Review customer impact
15. Prepare post-incident report
```

Rollback must be fast enough to protect the store but structured enough to preserve evidence.

---

## 17. Manual Fallback Policy

Every critical cutover must have a manual fallback path.

Manual fallback may include:

- staff manually entering orders into POS;
- staff manually confirming payment state;
- staff manually issuing receipt through POS;
- manager-level cancellation/refund handling;
- temporary suspension of automated ordering;
- temporary customer 안내 message;
- order queue freeze until staff confirmation;
- table service fallback;
- phone/manual confirmation fallback where applicable.

Manual fallback must be simple enough for store staff to execute under pressure.

---

## 18. In-Flight Transaction Handling During Rollback

Rollback must handle transactions already in progress.

Required in-flight classifications:

| State | Required Handling |
|---|---|
| `submitted_not_sent` | Keep in gateway, route manually or retry later |
| `sent_unknown_result` | Block duplicate write, require provider/POS lookup |
| `pos_success_payment_unknown` | Reconcile payment before customer completion |
| `payment_success_pos_unknown` | Confirm POS state or manually enter with evidence |
| `cancel_requested_unknown` | Escalate to manager/payment lead |
| `refund_requested_unknown` | Block duplicate refund and verify original payment |
| `receipt_unknown` | Reissue only after source confirmation |
| `kds_unknown` | Confirm kitchen ticket before remaking order |

In-flight handling must prioritize avoiding duplicate charge, duplicate cook, and false customer completion.

---

## 19. Customer Communication Boundary

During cutover incident or rollback, customer communication must be conservative.

Allowed messages:

- “확인 중입니다.”
- “결제/주문 상태를 확인한 뒤 안내드리겠습니다.”
- “중복 처리되지 않도록 확인하고 있습니다.”
- “직원이 직접 확인 후 처리해드리겠습니다.”

Prohibited messages:

- “결제 실패입니다” when payment state is unknown;
- “주문 완료입니다” when POS/KDS state is unknown;
- “환불 완료입니다” without refund evidence;
- “다시 결제해주세요” before duplicate charge risk is cleared;
- “시스템 오류라 처리할 수 없습니다” without escalation path.

Customer protection overrides internal speed.

---

## 20. Post-Cutover Stabilization Window

After cutover, the gateway enters a stabilization window.

Recommended stabilization checks:

- first 5 transactions;
- first 10 transactions;
- first cancellation;
- first refund if enabled;
- first payment method variation;
- first POS closing comparison;
- first settlement comparison;
- first business day close.

During stabilization:

- risky configuration changes should remain frozen;
- new feature activation should be avoided;
- monitoring must remain active;
- unresolved variance must not be ignored;
- incident command roles should remain reachable.

---

## 21. Post-Cutover Reconciliation

Post-cutover reconciliation must compare:

- gateway order count;
- POS order count;
- gateway payment count;
- payment provider payment count;
- cancellation count;
- refund count;
- gross sales;
- net sales;
- tax;
- discount;
- payment method totals;
- receipt count;
- settlement references;
- failed write count;
- dead-letter count;
- manual correction count.

If variance exists, the system must create a reconciliation case.

Cutover cannot be marked stable until reconciliation passes or variances are explicitly classified and approved.

---

## 22. Post-Rollback Reconciliation

Rollback requires separate reconciliation.

Post-rollback reconciliation must determine:

- which transactions were completed before rollback;
- which transactions were in-flight during rollback;
- which transactions require manual POS entry;
- which payments require manual verification;
- which cancellations/refunds require follow-up;
- whether any customer was charged incorrectly;
- whether any order was cooked twice or missed;
- whether settlement evidence remains intact.

Rollback is not complete merely because routing was disabled.  
Rollback is complete only when affected transactions are classified.

---

## 23. Incident Report Requirements

Any L2 or higher incident must produce an incident report.

Incident report must include:

- incident ID;
- cutover epoch ID;
- tenant/store/provider;
- incident level;
- timeline;
- trigger;
- affected transaction IDs;
- affected customers where applicable;
- affected staff workflow;
- rollback decision;
- rollback action;
- reconciliation result;
- customer protection action;
- root cause candidate;
- corrective action;
- prevention action;
- closure approval.

Incident report must link to gateway audit events and reconciliation cases.

---

## 24. Evidence Requirements

Production cutover must create an evidence packet.

Required evidence:

- approved runbook;
- go/no-go decision;
- role assignment;
- pre-cutover checklist result;
- production credential activation record;
- cutover epoch record;
- routing flag change record;
- controlled probe result;
- monitoring snapshot;
- incident timeline if applicable;
- rollback record if applicable;
- reconciliation report;
- final stability decision.

Evidence must be retained under the financial audit and regulatory readiness policy.

---

## 25. Production Flag Control

Production cutover should be controlled by explicit flags.

Recommended flags:

```text
pos_gateway_read_enabled
pos_gateway_shadow_enabled
pos_gateway_order_write_enabled
pos_gateway_payment_reference_enabled
pos_gateway_payment_execution_enabled
pos_gateway_cancel_enabled
pos_gateway_refund_enabled
pos_gateway_kds_routing_enabled
pos_gateway_retry_worker_enabled
pos_gateway_cutover_freeze_enabled
pos_gateway_rollback_mode_enabled
```

Flag changes must be:

- authorized;
- logged;
- scoped by tenant/store/provider;
- linked to cutover epoch;
- visible in operations console;
- reversible where technically possible.

---

## 26. Communication Channel Policy

Each cutover must have a defined communication channel.

The channel must include:

- cutover commander;
- technical lead;
- store operations lead;
- payment/settlement lead;
- rollback owner;
- incident scribe;
- store manager or operator contact.

The channel must record:

- start confirmation;
- go/no-go decision;
- mode changes;
- probe result;
- incidents;
- rollback decisions;
- stabilization status;
- final completion.

Production cutover must not rely on scattered private messages with no durable record.

---

## 27. Store Staff Handoff Policy

Before cutover, store staff must know:

- whether the gateway is active or not;
- what changes they will see in POS/KDS;
- what to do if an order is missing;
- what to do if payment appears uncertain;
- who to contact for cancellation/refund;
- when to stop using automated flow;
- when to use manual fallback;
- what message to give customers.

Staff-facing guidance must be short and practical.

---

## 28. Cutover Completion Criteria

A cutover may be marked completed only when:

- target route is active as intended;
- first production probe or equivalent validation passed;
- no unresolved critical incident exists;
- monitoring remains healthy;
- no duplicate transaction risk is open;
- payment/POS linkage is confirmed;
- reconciliation has started;
- store operator confirms operational usability;
- cutover epoch status is updated;
- evidence packet is created.

Completion does not mean stable.  
Stable status requires post-cutover reconciliation.

---

## 29. Stable Status Criteria

A cutover may be marked stable only when:

- post-cutover reconciliation passes;
- first operating window completes without critical incident;
- in-flight transactions are resolved;
- open customer-impact cases are closed or controlled;
- settlement evidence is available or scheduled for verification;
- rollback is no longer immediately expected;
- incident report is completed if applicable;
- responsible owner approves stability.

Stable status must be explicitly recorded.

---

## 30. Prohibited Practices

The following practices are prohibited:

- enabling production POS writes without approved runbook;
- enabling payment execution and POS write simultaneously without controlled gate;
- cutting over during peak time without documented justification;
- relying on memory instead of checklist;
- enabling production credentials without audit record;
- performing rollback by deleting data;
- continuing cutover expansion during transaction mismatch;
- asking customers to repay before duplicate charge risk is cleared;
- hiding failed writes from store operators;
- marking cutover stable before reconciliation;
- leaving in-flight transactions unclassified;
- closing incident without evidence.

---

## 31. Minimum Acceptance Criteria

The POS Gateway production cutover process is acceptable only when:

- cutover type classification exists;
- command roles are assigned;
- runbook exists;
- pre-cutover checklist exists;
- go/no-go decision is recorded;
- cutover epoch is created;
- production flag changes are logged;
- rollback trigger criteria are defined;
- rollback sequence is executable;
- manual fallback exists;
- in-flight transaction handling exists;
- post-cutover reconciliation exists;
- incident report process exists;
- evidence packet is retained.

---

## 32. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_cutover_runbooks
pos_gateway_cutover_epochs
pos_gateway_cutover_role_assignments
pos_gateway_cutover_checklists
pos_gateway_cutover_flag_changes
pos_gateway_cutover_incidents
pos_gateway_cutover_timelines
pos_gateway_rollback_records
pos_gateway_inflight_transaction_reviews
pos_gateway_post_cutover_reconciliation_reports
pos_gateway_evidence_packets
```

Recommended services:

```text
CutoverRunbookService
CutoverGateService
CutoverEpochService
ProductionFlagService
IncidentCommandService
RollbackExecutionService
InFlightTransactionReviewService
ManualFallbackCoordinator
PostCutoverReconciliationService
CutoverEvidencePacketService
```

Recommended event types:

```text
pos_gateway.cutover.go_decision_recorded
pos_gateway.cutover.no_go_decision_recorded
pos_gateway.cutover.started
pos_gateway.cutover.flag_enabled
pos_gateway.cutover.flag_disabled
pos_gateway.cutover.probe_started
pos_gateway.cutover.probe_passed
pos_gateway.cutover.probe_failed
pos_gateway.cutover.incident_detected
pos_gateway.cutover.rollback_declared
pos_gateway.cutover.rollback_completed
pos_gateway.cutover.reconciliation_started
pos_gateway.cutover.reconciliation_failed
pos_gateway.cutover.reconciliation_passed
pos_gateway.cutover.stable_status_approved
```

---

## 33. Relationship To Adjacent Documents

This document is related to:

- POS Gateway migration, backfill, cutover, and existing transaction protection policy;
- POS Gateway runtime configuration and production credential activation policy;
- POS Gateway idempotency and retry policy;
- POS Gateway reconciliation policy;
- POS Gateway incident response policy;
- POS Gateway cancellation and refund policy;
- POS Gateway settlement and accounting policy;
- POS Gateway audit evidence policy;
- POS Gateway provider adapter policy;
- POS Gateway store onboarding policy.

Where conflict exists, this document governs operational execution of production cutover and rollback.

---

## 34. Summary

The POS Gateway production cutover is a financial operations event.

It must be executed through a runbook, role assignment, go/no-go decision, cutover epoch, monitoring, rollback plan, manual fallback, and reconciliation.

The correct goal is not simply to turn the gateway on.  
The correct goal is to turn it on in a way that protects the store, protects customers, preserves evidence, and allows safe rollback if reality differs from the plan.

A failed cutover with preserved evidence is recoverable.  
A cutover that hides what happened is not.