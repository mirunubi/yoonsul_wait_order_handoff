# 014119_Policy_POS_Gateway_Migration_Backfill_Cutover_Existing_Transaction_Protection_And_Data_Integrity

## 1. Purpose

This document defines the migration, backfill, cutover, existing transaction protection, and data integrity policy for the POS Gateway Implementation layer.

The POS Gateway must not treat migration as a simple deployment event.
POS integration migration affects real sales, card payments, cancellations, refunds, settlement references, receipt identity, store operations, accounting evidence, and consumer protection obligations.

Therefore, any migration into, within, or out of the POS Gateway must protect already-existing transactions first, and only then enable new routing behavior.

This policy exists to ensure that:

* existing sales and payment records are never overwritten by migration logic;
* backfilled data is clearly distinguishable from live gateway-originated data;
* historical transaction identity remains stable;
* cutover does not create duplicate orders, duplicate payments, duplicate cancellations, or broken refund paths;
* settlement and audit evidence remain traceable before, during, and after migration;
* rollback can be executed without corrupting transaction history;
* POS provider migration, store onboarding, credential activation, and production switchover follow controlled gates.

---

## 2. Scope

This policy applies to all POS Gateway migration and cutover scenarios, including but not limited to:

* onboarding an existing store into the POS Gateway;
* migrating from manual POS entry to gateway-mediated POS integration;
* migrating from one POS provider adapter to another;
* enabling payment gateway integration after order-only integration;
* enabling KDS routing after POS order routing;
* importing historical POS sales data;
* backfilling historical order, payment, cancellation, refund, receipt, and settlement references;
* switching from sandbox credentials to production credentials;
* switching from shadow mode to active write mode;
* performing emergency rollback after production cutover;
* reconciling transactions created before the gateway became active;
* correcting previously imported records without destroying evidence.

This policy does not define the low-level adapter implementation itself.
It governs the migration safety boundary around the adapter, transaction tables, reconciliation jobs, cutover gates, and audit trail.

---

## 3. Core Principle

The POS Gateway must treat existing transactions as immutable financial evidence.

A migration may add mapping, linkage, metadata, reconciliation state, or gateway-side references.
A migration must not mutate the original business meaning of historical transactions.

The following rule is mandatory:

> Migration may attach interpretation to existing transaction data, but must never rewrite history to make the past appear gateway-native.

---

## 4. Migration Risk Model

POS Gateway migration is high-risk because the following records may already exist outside the gateway:

* POS order numbers;
* receipt numbers;
* card approval numbers;
* VAN approval identifiers;
* PG transaction identifiers;
* cancellation references;
* refund references;
* settlement batch identifiers;
* cash receipt identifiers;
* coupon or membership discount references;
* manual adjustment records;
* store closing reports;
* accounting exports;
* tax reporting evidence;
* customer complaint evidence;
* consumer dispute evidence.

If these records are imported incorrectly, the system may create:

* duplicate sales;
* missing sales;
* orphan payments;
* orphan cancellations;
* impossible refunds;
* broken settlement matching;
* mismatched receipt history;
* inaccurate store revenue;
* false accounting reports;
* consumer protection exposure;
* audit failure.

---

## 5. Migration Modes

The POS Gateway must distinguish the following migration modes.

### 5.1 Discovery Mode

Discovery Mode is used before any data import or production write.

Allowed actions:

* read POS provider capability;
* collect store configuration;
* inspect available export formats;
* identify transaction identifier patterns;
* confirm provider API limitations;
* map available historical data fields;
* detect duplicate candidate keys;
* generate migration risk report.

Prohibited actions:

* writing orders to POS;
* writing payments to POS;
* altering historical records;
* activating production credential usage;
* executing cancellation or refund requests.

### 5.2 Dry-Run Backfill Mode

Dry-Run Backfill Mode validates import logic without committing financial records as active gateway records.

Allowed actions:

* parse historical exports;
* generate candidate mappings;
* compare totals by date, store, payment method, and provider;
* detect missing fields;
* detect duplicate identifiers;
* produce import preview;
* produce exception report.

Required output:

* dry-run summary;
* rejected record list;
* duplicate candidate list;
* unmapped field report;
* reconciliation variance report;
* go/no-go recommendation.

### 5.3 Shadow Backfill Mode

Shadow Backfill Mode writes imported historical data into isolated shadow tables or shadow namespaces.

Allowed actions:

* create gateway-side historical reference records;
* attach source metadata;
* run reconciliation against POS closing reports;
* run settlement comparison;
* run sample audit review.

Prohibited actions:

* exposing imported records as live payable or refundable records;
* treating shadow records as gateway-originated orders;
* allowing customer-visible refund actions based only on shadow state.

### 5.4 Controlled Historical Activation Mode

Controlled Historical Activation Mode allows selected imported records to become referenceable by gateway services.

Activation must be scoped by:

* tenant;
* store;
* POS provider;
* business date range;
* transaction type;
* import batch;
* validation result.

Activation must not convert historical transactions into normal live gateway-originated transactions.

### 5.5 Active Cutover Mode

Active Cutover Mode enables the gateway to become the active routing path for new transactions.

Allowed actions:

* create new gateway-originated order records;
* route eligible new orders to POS;
* attach payment and receipt references;
* reconcile live transactions;
* execute live cancellation and refund flows where authorized.

Required condition:

* all pre-cutover gates must pass;
* rollback route must exist;
* duplicate prevention controls must be active;
* production credentials must be approved;
* store operator must be informed of cutover state.

### 5.6 Rollback Mode

Rollback Mode disables or limits gateway write behavior after cutover.

Rollback must never delete already-created gateway records.
Rollback must preserve evidence and mark new routing state explicitly.

Allowed rollback actions:

* disable new POS write routing;
* return to manual confirmation mode;
* pause refund automation;
* pause cancellation automation;
* mark in-flight records as requiring reconciliation;
* preserve all gateway-originated transaction records.

Prohibited rollback actions:

* deleting gateway-originated transactions;
* rewriting transaction timestamps;
* reusing transaction identifiers;
* marking uncertain records as successful without evidence.

---

## 6. Historical Transaction Classification

All historical records imported into the POS Gateway must be classified.

Required classifications:

| Classification                | Meaning                                                       |
| ----------------------------- | ------------------------------------------------------------- |
| `legacy_pos_native`           | Transaction originally created in POS before gateway adoption |
| `legacy_manual_entry`         | Transaction manually entered by store staff                   |
| `legacy_payment_only`         | Payment exists but no structured order detail is available    |
| `legacy_order_only`           | Order exists but payment linkage is unavailable               |
| `legacy_cancelled`            | Transaction was cancelled before import                       |
| `legacy_refunded`             | Refund occurred before import                                 |
| `legacy_adjusted`             | Transaction includes manual adjustment or correction          |
| `legacy_unknown_integrity`    | Imported record cannot be fully validated                     |
| `gateway_shadow_import`       | Backfilled record imported into shadow state                  |
| `gateway_reference_activated` | Backfilled record activated as reference-only gateway history |
| `gateway_originated`          | Transaction created after active gateway cutover              |

The system must not mix `legacy_*` and `gateway_originated` records without explicit classification.

---

## 7. Immutable Transaction Identity Policy

The following identifiers must be preserved exactly as provided by source systems:

* POS order number;
* POS receipt number;
* POS bill number;
* approval number;
* VAN transaction identifier;
* PG transaction identifier;
* card issuer approval reference;
* cash receipt identifier;
* cancellation approval number;
* refund transaction identifier;
* settlement batch reference;
* original business date;
* original transaction timestamp where available.

Gateway-generated identifiers must be additive and must not replace source identifiers.

Required identity structure:

```text
gateway_transaction_id
source_system_type
source_provider_code
source_store_id
source_transaction_id
source_receipt_id
source_approval_id
source_cancel_id
source_refund_id
legacy_origin_type
import_batch_id
cutover_epoch_id
```

The gateway must support multiple source identifiers for one transaction when POS, VAN, PG, and settlement systems each provide different references.

---

## 8. Import Batch Policy

Every migration import must be grouped under an import batch.

Each import batch must include:

* import batch ID;
* tenant ID;
* store ID;
* POS provider code;
* source file/API/export reference;
* source extraction timestamp;
* import requested by;
* import executed by;
* import execution timestamp;
* dry-run flag;
* shadow import flag;
* activation flag;
* record count;
* accepted count;
* rejected count;
* duplicate count;
* unresolved count;
* checksum/hash of source file or payload when available;
* validation rule version;
* migration policy version;
* approval reference.

Import batches must be append-only after completion.
Corrections must be represented as a new correction batch linked to the original batch.

---

## 9. Backfill Data Integrity Requirements

Backfill must pass integrity validation before activation.

Minimum validation checks:

* required identifier presence;
* duplicate source transaction detection;
* duplicate receipt detection;
* duplicate approval detection;
* business date consistency;
* order total consistency;
* payment total consistency;
* cancellation amount consistency;
* refund amount consistency;
* tax amount consistency where available;
* discount amount consistency;
* payment method consistency;
* settlement date reasonableness;
* store ID mapping validity;
* provider code mapping validity;
* timezone normalization check;
* source timestamp parsing check;
* negative amount rule check;
* zero amount transaction handling;
* void/refund distinction check.

Backfill must fail closed when financial meaning is ambiguous.

---

## 10. Duplicate Protection Policy

The gateway must prevent duplicate transaction creation during migration and cutover.

Duplicate detection keys must include layered matching:

### 10.1 Strong Duplicate Keys

* same POS provider;
* same store;
* same POS transaction ID;
* same receipt ID;
* same approval ID;
* same business date.

### 10.2 Medium Duplicate Keys

* same store;
* same receipt number;
* same transaction timestamp window;
* same total amount;
* same payment method.

### 10.3 Weak Duplicate Signals

* same order items;
* same terminal number;
* same staff/operator number;
* same table number;
* same customer session reference;
* same approval time range.

Strong duplicate matches must block import or write.
Medium matches must require review or deterministic merge policy.
Weak matches must be logged as suspicious but must not automatically merge financial records.

---

## 11. Cutover Epoch Policy

Every production cutover must create a `cutover_epoch_id`.

A cutover epoch represents a specific routing state transition.

Required fields:

```text
cutover_epoch_id
tenant_id
store_id
pos_provider_code
gateway_adapter_version
cutover_mode
previous_mode
next_mode
planned_start_at
actual_start_at
actual_end_at
approved_by
executed_by
rollback_owner
rollback_deadline
production_credential_reference
health_check_result
pre_cutover_reconciliation_result
post_cutover_reconciliation_result
status
```

All gateway-originated transactions after cutover must reference the active `cutover_epoch_id`.

If rollback occurs, the rollback must create a new epoch or mark the existing epoch with explicit rollback state.
The system must not silently erase the cutover event.

---

## 12. Pre-Cutover Gate

Before enabling active POS Gateway writes, the following gate must pass.

### 12.1 Configuration Gate

Required:

* tenant configured;
* store configured;
* POS provider adapter configured;
* store operating timezone configured;
* business day boundary configured;
* terminal mapping configured where required;
* table mapping configured where required;
* menu/item mapping configured where required;
* tax/discount mapping configured where required;
* payment method mapping configured;
* cancellation/refund support verified;
* receipt identity behavior verified.

### 12.2 Credential Gate

Required:

* production credentials approved;
* credential scope verified;
* credential storage policy satisfied;
* credential rotation plan defined;
* sandbox credentials disabled for production routing;
* emergency credential revoke process documented.

### 12.3 Data Gate

Required:

* historical import decision recorded;
* backfill dry-run completed if applicable;
* unresolved historical records classified;
* duplicate detection report reviewed;
* closing report comparison completed for selected dates;
* settlement comparison completed where available.

### 12.4 Runtime Gate

Required:

* adapter health check passed;
* idempotency store active;
* retry policy configured;
* timeout policy configured;
* dead-letter queue active;
* reconciliation job active;
* alert channel active;
* rollback mode tested.

### 12.5 Store Operation Gate

Required:

* store operator notified;
* store staff knows whether gateway is active, shadow, or manual;
* manual fallback procedure available;
* cancellation/refund escalation path available;
* cutover window approved;
* peak-hour cutover avoided unless emergency or unavoidable.

---

## 13. Cutover Window Policy

Cutover should occur during a low-risk operating window.

Preferred cutover windows:

* non-peak hours;
* after daily closing reconciliation;
* before new business day start;
* when store manager or responsible operator is available;
* when technical rollback owner is available;
* when POS provider support contact is reachable where necessary.

Cutover should not occur:

* during lunch peak;
* during dinner peak;
* during high-volume promotion;
* during payment provider instability;
* during POS provider maintenance;
* during unresolved reconciliation variance;
* during credential uncertainty;
* without rollback owner availability.

---

## 14. In-Flight Transaction Protection

During cutover, some transactions may already be in progress.

The gateway must define in-flight states, including:

* cart/session opened before cutover;
* order submitted before cutover;
* POS write requested before cutover;
* POS write pending during cutover;
* payment authorized before cutover;
* payment capture pending during cutover;
* cancellation requested during cutover;
* refund requested during cutover;
* receipt issued before gateway confirmation.

In-flight transaction rules:

1. Pre-cutover transactions must complete under their original routing path unless explicitly migrated by deterministic rule.
2. Gateway must not resubmit uncertain in-flight orders without idempotency evidence.
3. Payment success without POS order success must become reconciliation-required state.
4. POS order success without payment success must become settlement/cashier review state.
5. Customer-visible status must avoid false success or false failure.
6. Staff console must surface in-flight uncertainty immediately.

---

## 15. Write Freeze Policy

A temporary write freeze may be required during cutover.

Write freeze may apply to:

* POS order writes;
* cancellation writes;
* refund writes;
* menu mapping updates;
* terminal mapping updates;
* provider credential changes;
* settlement mapping changes;
* manual correction entries.

Write freeze must be:

* scoped;
* time-bounded;
* announced to relevant operators;
* logged;
* reversible;
* linked to cutover epoch.

Write freeze must not block emergency consumer protection actions unless an alternative manual path exists.

---

## 16. Backfill Activation Policy

Backfilled records may be activated only when they pass activation criteria.

Activation criteria:

* source identity is stable;
* duplicate risk is resolved;
* amount consistency passes;
* cancellation/refund linkage is validated;
* settlement reference is either validated or explicitly unavailable;
* business date is normalized;
* store mapping is confirmed;
* provider mapping is confirmed;
* import batch is approved;
* activation scope is documented.

Activated backfilled records must remain marked as historical/reference records.
They must not be treated as live gateway-originated transactions.

---

## 17. Correction and Reprocessing Policy

Imported historical data may need correction.

Allowed correction methods:

* new correction import batch;
* reversal record;
* adjustment record;
* mapping correction record;
* reconciliation annotation;
* manual review disposition.

Prohibited correction methods:

* direct update of source transaction amount;
* deleting rejected records without trace;
* replacing original source identifiers;
* changing original timestamps to match gateway expectations;
* silently merging duplicate financial records;
* reclassifying uncertain records as clean without evidence.

All corrections must preserve:

* original imported value;
* corrected value;
* correction reason;
* correction actor;
* correction timestamp;
* approval reference where required.

---

## 18. Rollback Policy

Rollback must be planned before cutover.

Rollback may be triggered by:

* duplicate transaction detection;
* POS write failure rate above threshold;
* payment/POS mismatch above threshold;
* settlement variance;
* credential failure;
* adapter instability;
* provider outage;
* store operator escalation;
* consumer-impacting error;
* audit evidence failure.

Rollback actions may include:

* disable active POS write route;
* return to manual POS entry;
* pause automated cancellation/refund;
* keep payment confirmation separate from POS confirmation;
* mark new transactions as reconciliation-required;
* notify store operator;
* preserve all event/audit logs.

Rollback must not:

* delete live gateway records;
* erase cutover epoch;
* reuse identifiers;
* hide failed writes;
* automatically refund without policy-approved evidence;
* leave uncertain customer-facing states unresolved.

---

## 19. Reconciliation After Cutover

Post-cutover reconciliation is mandatory.

Minimum reconciliation dimensions:

* order count;
* payment count;
* cancellation count;
* refund count;
* gross sales;
* net sales;
* tax;
* discount;
* service charge where applicable;
* cash/card/simple payment split;
* POS closing total;
* payment provider total;
* settlement batch total;
* gateway total.

Reconciliation must be run:

* immediately after cutover sample window;
* at business day close;
* after first full operating day;
* after first settlement cycle;
* after any rollback;
* after any correction batch.

Unresolved variance must generate a reconciliation case.

---

## 20. Customer Protection Boundary

Migration and cutover must not degrade customer rights.

The gateway must ensure that:

* customers are not charged twice due to migration or cutover;
* customers can receive valid receipt or proof of transaction;
* cancellation/refund path is not lost;
* failed or uncertain transaction states are visible to staff;
* consumer dispute evidence is preserved;
* manual refund escalation is available when automated refund is unsafe;
* historical records are not falsely presented as newly created transactions.

If transaction state is uncertain, customer-facing messaging must avoid definitive claims until evidence is confirmed.

---

## 21. Settlement and Accounting Protection

Migration must preserve accounting evidence.

The gateway must maintain linkage between:

* order;
* payment;
* cancellation;
* refund;
* receipt;
* tax amount;
* discount amount;
* settlement batch;
* provider fee where available;
* store closing report;
* accounting export.

Backfilled data must not be used for official accounting export unless its activation scope permits it.

If imported data is incomplete, accounting output must clearly indicate:

* source limitation;
* missing field;
* confidence level;
* manual review requirement;
* exclusion from official export where necessary.

---

## 22. Audit Trail Requirements

Every migration and cutover event must be audited.

Required audit events:

* migration discovery started;
* dry-run backfill started/completed;
* shadow import started/completed;
* import batch approved/rejected;
* duplicate detection result generated;
* activation requested;
* activation approved;
* activation executed;
* pre-cutover gate passed/failed;
* production credential activated;
* cutover started;
* cutover completed;
* rollback started;
* rollback completed;
* reconciliation variance detected;
* correction batch created;
* manual override executed.

Audit event payload must include:

```text
event_id
event_type
tenant_id
store_id
pos_provider_code
actor_id
actor_role
request_id
import_batch_id
cutover_epoch_id
transaction_id
source_transaction_id
before_state
after_state
reason
created_at
```

---

## 23. Migration State Machine

The gateway must represent migration state explicitly.

Recommended state model:

```text
not_started
discovery_in_progress
discovery_completed
dry_run_backfill_in_progress
dry_run_backfill_failed
dry_run_backfill_passed
shadow_import_in_progress
shadow_import_failed
shadow_import_completed
activation_pending
activation_rejected
activation_completed
pre_cutover_gate_pending
pre_cutover_gate_failed
ready_for_cutover
active_cutover_in_progress
active_gateway_enabled
rollback_in_progress
rolled_back
post_cutover_reconciliation_pending
post_cutover_reconciliation_failed
post_cutover_stable
```

State transitions must be controlled.
Direct jump from `not_started` to `active_gateway_enabled` is prohibited.

---

## 24. Existing Transaction Protection Rules

The following rules are mandatory:

1. Existing transaction records must never be overwritten by gateway migration.
2. Historical POS-native transactions must remain distinguishable from gateway-originated transactions.
3. Imported records must retain source identifiers.
4. Backfill must run through batch-controlled validation.
5. Duplicate financial records must be blocked or isolated.
6. Activation must be scoped and approved.
7. Cutover must create a cutover epoch.
8. In-flight transactions must be protected.
9. Rollback must preserve all evidence.
10. Reconciliation must occur after cutover and after rollback.
11. Consumer refund and cancellation paths must remain available.
12. Accounting export must not rely on unvalidated imported records.

---

## 25. Failure Handling

If migration fails, the system must classify the failure.

Failure categories:

| Failure Category       | Description                      | Required Response             |
| ---------------------- | -------------------------------- | ----------------------------- |
| `source_unavailable`   | POS export/API unavailable       | Pause migration               |
| `schema_mismatch`      | Source format unexpected         | Stop import and review        |
| `duplicate_detected`   | Duplicate transaction risk       | Isolate and review            |
| `amount_variance`      | Amount mismatch                  | Block activation              |
| `identifier_missing`   | Key source identifiers absent    | Mark unresolved               |
| `timezone_error`       | Timestamp normalization failure  | Reprocess with corrected rule |
| `credential_error`     | Production credential invalid    | Block cutover                 |
| `write_failure`        | POS write failure during cutover | Trigger rollback review       |
| `payment_pos_mismatch` | Payment and POS state diverge    | Create reconciliation case    |
| `settlement_variance`  | Settlement totals mismatch       | Block stable status           |
| `consumer_impact`      | Customer-facing harm possible    | Escalate immediately          |

Failures must be logged with enough evidence to reproduce and review.

---

## 26. Operational Dashboard Requirements

The Admin or internal operations console must surface migration and cutover status.

Required dashboard fields:

* store migration status;
* current migration mode;
* current cutover epoch;
* POS provider;
* adapter version;
* credential mode;
* import batch status;
* duplicate count;
* unresolved record count;
* active write route status;
* rollback availability;
* reconciliation status;
* last successful POS write;
* last failed POS write;
* last settlement comparison;
* open reconciliation cases;
* open customer-impact cases.

The dashboard must avoid showing “normal” status when reconciliation is pending or unresolved.

---

## 27. Evidence Packet Requirements

Each production cutover must produce an evidence packet.

Evidence packet must include:

* migration plan;
* POS provider capability summary;
* credential approval reference;
* pre-cutover gate checklist;
* dry-run backfill report if applicable;
* shadow import report if applicable;
* duplicate detection report;
* unresolved record list;
* cutover epoch record;
* rollback plan;
* post-cutover reconciliation report;
* incident records if any;
* final stability approval.

Evidence packet must be retained according to the financial audit evidence retention policy.

---

## 28. Prohibited Practices

The following practices are prohibited:

* importing historical transactions directly into live gateway tables without classification;
* using imported records as if they were gateway-originated;
* overwriting POS receipt numbers;
* overwriting payment approval references;
* deleting failed import rows to make migration appear clean;
* merging duplicate transactions without audit evidence;
* activating production write mode without cutover epoch;
* performing peak-hour cutover without emergency justification;
* enabling automated refunds before refund identity is verified;
* using sandbox credentials in production routing;
* allowing rollback to delete evidence;
* hiding unresolved reconciliation variance from operators.

---

## 29. Minimum Acceptance Criteria

A POS Gateway migration and cutover is acceptable only when:

* historical transaction protection rules are implemented;
* import batch model exists;
* duplicate detection exists;
* dry-run or equivalent validation exists;
* cutover epoch model exists;
* rollback path exists;
* in-flight transaction policy exists;
* post-cutover reconciliation exists;
* audit events exist;
* unresolved records are visible;
* production credential activation is gated;
* customer protection path is defined;
* accounting and settlement linkage is preserved.

---

## 30. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_import_batches
pos_gateway_import_records
pos_gateway_import_errors
pos_gateway_cutover_epochs
pos_gateway_legacy_transaction_links
pos_gateway_duplicate_candidates
pos_gateway_reconciliation_cases
pos_gateway_migration_audit_events
pos_gateway_cutover_checklists
pos_gateway_rollback_actions
```

Recommended service boundaries:

```text
MigrationDiscoveryService
BackfillDryRunService
ShadowImportService
LegacyTransactionLinkService
DuplicateDetectionService
CutoverGateService
CutoverEpochService
InFlightTransactionGuard
RollbackCoordinator
PostCutoverReconciliationService
MigrationEvidencePacketService
```

Recommended runtime controls:

```text
idempotency_key
source_transaction_hash
import_batch_hash
cutover_epoch_lock
write_route_freeze_flag
rollback_mode_flag
reconciliation_required_flag
legacy_reference_only_flag
gateway_originated_flag
```

---

## 31. Relationship To Adjacent Documents

This document is related to:

* POS Gateway runtime configuration and production credential activation policy;
* POS Gateway adapter contract policy;
* POS Gateway idempotency and retry policy;
* POS Gateway reconciliation policy;
* POS Gateway audit and evidence policy;
* POS Gateway cancellation and refund policy;
* POS Gateway settlement and accounting policy;
* POS Gateway incident response policy;
* POS Gateway provider onboarding policy;
* POS Gateway consumer protection policy.

Where conflict exists, this document governs migration, backfill, cutover, and existing transaction protection behavior.

---

## 32. Summary

The POS Gateway must not treat migration as an implementation convenience.

Migration touches the financial memory of the store.
Historical POS transactions, payment approvals, cancellations, refunds, receipts, and settlement evidence must remain protected.

A safe POS Gateway migration requires:

* explicit migration modes;
* import batch evidence;
* immutable source identifiers;
* duplicate protection;
* controlled backfill activation;
* cutover epochs;
* in-flight transaction protection;
* rollback without evidence loss;
* post-cutover reconciliation;
* consumer protection continuity.

The correct outcome is not merely that the new gateway works.
The correct outcome is that the store can prove what happened before, during, and after gateway adoption without corrupting transaction history.
