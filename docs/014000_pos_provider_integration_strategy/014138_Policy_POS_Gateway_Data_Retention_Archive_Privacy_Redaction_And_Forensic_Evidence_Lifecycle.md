# 014138_Policy_POS_Gateway_Data_Retention_Archive_Privacy_Redaction_And_Forensic_Evidence_Lifecycle

## 1. Purpose

This document defines the data retention, archive, privacy, redaction, and forensic evidence lifecycle policy for the POS Gateway.

The POS Gateway creates and receives transaction-critical evidence across orders, payments, POS writes, cancellations, refunds, receipts, KDS tickets, customer communications, provider responses, reconciliation cases, incidents, manual fallback actions, and audit events.

This evidence must be retained long enough to support:

- customer disputes;
- refund/cancellation verification;
- settlement review;
- accounting export;
- provider escalation;
- postmortem investigation;
- regulatory or audit review;
- fraud or abuse investigation;
- operational learning;
- migration and provider change history.

However, the gateway must also avoid retaining unnecessary sensitive data, raw secrets, payment data, or personal information beyond its purpose.

This policy exists to ensure that:

- transaction evidence is retained intentionally;
- privacy-sensitive data is minimized and redacted;
- forensic evidence remains searchable and trustworthy;
- archive does not destroy auditability;
- deletion and retention follow scoped rules;
- provider, customer, staff, tenant, store, and payment data are handled safely;
- future incident investigation can reconstruct what happened without exposing unnecessary data.

---

## 2. Scope

This policy applies to all POS Gateway data and evidence lifecycle areas, including:

- order records;
- POS write records;
- payment reference records;
- cancellation records;
- refund records;
- receipt/proof records;
- KDS ticket records;
- menu/price/calculation snapshots;
- table/session/object/device records;
- customer status messages;
- notification records;
- customer dispute records;
- manual fallback records;
- manager approval records;
- reconciliation cases;
- provider escalation packets;
- incident records;
- postmortems;
- audit events;
- logs and traces;
- dead-letter queue entries;
- migration/backfill records;
- cutover/rollback evidence;
- provider certification evidence;
- onboarding and rollout evidence;
- operational dashboard snapshots.

This document governs retention, archival, redaction, privacy boundary, forensic lifecycle, and safe evidence access.

---

## 3. Core Principle

The POS Gateway must retain enough evidence to prove transaction truth, but no more sensitive data than necessary.

The policy balance is:

```text
retain financial and operational evidence
minimize personal and secret data
redact sensitive payloads
preserve immutable audit chain
archive without losing searchability
delete or anonymize only under controlled rules
```

Evidence must remain useful, but sensitive data must not become operational debris.

---

## 4. Evidence Classification

All POS Gateway evidence must be classified.

Recommended evidence classes:

| Evidence Class | Description |
|---|---|
| `transaction_core` | Order, payment, cancel, refund, receipt, POS write evidence |
| `settlement_accounting` | Settlement, closing, accounting export, tax-related evidence |
| `customer_dispute` | Customer claim, communication, proof, resolution evidence |
| `incident_forensic` | Incident, timeline, logs, provider escalation, postmortem |
| `manual_operation` | Staff fallback, manual correction, approval, override |
| `configuration_history` | Runtime flags, provider routes, mapping, credential references |
| `migration_history` | Backfill, import, cutover, rollback, legacy transaction linkage |
| `provider_certification` | Capability, certification, restriction, test, escalation history |
| `operational_monitoring` | Metrics, alerts, dashboard snapshots, SLO/error budget |
| `security_privacy` | Access control, redaction, secret handling, suspicious activity |
| `temporary_runtime` | Queues, transient traces, retry work items, temporary payloads |

Each class must have retention and access rules.

---

## 5. Data Sensitivity Classification

Data must also be classified by sensitivity.

Recommended sensitivity levels:

| Sensitivity | Meaning |
|---|---|
| `public_operational` | Non-sensitive operational metadata |
| `internal_operational` | Internal store/provider/configuration data |
| `transaction_sensitive` | Order/payment/refund/receipt evidence |
| `customer_sensitive` | Customer identity, contact, dispute content |
| `staff_sensitive` | Staff actor, role, device, approval data |
| `provider_sensitive` | Provider account references and private operational evidence |
| `secret_sensitive` | Credentials, tokens, signatures, keys |
| `payment_sensitive` | Payment identifiers, approval references, masked card data |
| `regulated_sensitive` | Data subject to legal/accounting/consumer protection retention |
| `forensic_sensitive` | Incident/security investigation evidence |

Retention and access must consider both evidence class and sensitivity.

---

## 6. Retention Category Model

Each record type must have a retention category.

Recommended retention categories:

| Category | Meaning |
|---|---|
| `short_lived_runtime` | Temporary runtime data that can expire quickly |
| `operational_recent` | Needed for active store operation and short-term support |
| `customer_support_window` | Needed for customer dispute and refund/cancel support |
| `settlement_window` | Needed until settlement and closing are verified |
| `accounting_retention` | Needed for accounting, tax, and audit evidence |
| `incident_retention` | Needed for incident/postmortem and provider escalation |
| `forensic_retention` | Needed for security or legal investigation |
| `configuration_history_retention` | Needed to prove what config was active |
| `archival_retention` | Needed long-term but rarely accessed |
| `delete_or_anonymize` | Eligible for deletion/anonymization after purpose expires |

Retention categories must be explicit, not implicit.

---

## 7. Minimum Retention Matrix

The following minimum retention matrix should be defined and refined by legal/accounting policy.

| Record Type | Minimum Retention Intent |
|---|---|
| Order/payment/cancel/refund core | Retain for customer dispute, settlement, accounting, audit |
| Receipt/proof records | Retain for dispute and accounting evidence |
| Calculation snapshots | Retain with transaction evidence |
| Reconciliation cases | Retain with settlement/accounting evidence |
| Manual fallback and approval records | Retain with affected transaction evidence |
| Incident and postmortem records | Retain for incident review and audit |
| Provider escalation packets | Retain with incident/reconciliation evidence |
| Cutover/rollback evidence | Retain with implementation and forensic evidence |
| Configuration and routing history | Retain long enough to reconstruct transaction behavior |
| Logs/traces | Retain based on forensic usefulness and sensitivity |
| Temporary queue payloads | Retain until resolved, then archive or redact according to risk |
| Raw provider payloads | Retain only if necessary and redacted where possible |
| Customer communications | Retain where tied to dispute, refund, cancellation, or proof |
| Staff device/session evidence | Retain where tied to sensitive actions |

Retention periods must be defined in the project’s legal, audit, and privacy policy layer.

---

## 8. Immutable Evidence Policy

The following evidence must be append-only or immutable after creation:

- transaction creation event;
- POS write attempt;
- provider response classification;
- payment approval reference;
- cancellation/refund request and response;
- receipt identity;
- calculation snapshot;
- routing decision;
- cutover epoch;
- rollback record;
- manual fallback action;
- manager approval;
- reconciliation closure;
- incident timeline;
- provider escalation packet;
- audit event.

Corrections must create linked correction or adjustment records.

Original evidence must not be overwritten to make later state look clean.

---

## 9. Archive Policy

Archiving must preserve searchability and evidence linkage.

Archive must preserve:

- primary identifiers;
- tenant/store scope;
- business date;
- transaction ID;
- provider code;
- receipt/payment references;
- incident/reconciliation links;
- audit event links;
- retention category;
- sensitivity classification;
- redaction status;
- archive timestamp.

Archived evidence must remain discoverable by authorized roles.

Archive must not become a data graveyard where evidence cannot be retrieved for dispute or audit.

---

## 10. Archive State Model

Recommended archive states:

```text
active
cold_ready
archival_pending
archived
archived_redacted
archived_anonymized
legal_hold
forensic_hold
deletion_pending
deleted_with_tombstone
```

Records under legal or forensic hold must not be deleted or anonymized until hold is released.

---

## 11. Legal Hold and Forensic Hold

Legal hold or forensic hold may be required when:

- customer dispute is active;
- incident investigation is active;
- provider escalation is active;
- refund/payment dispute is unresolved;
- settlement variance is unresolved;
- accounting audit is pending;
- security incident is suspected;
- regulator or legal request exists;
- litigation risk is identified.

Hold record must include:

```text
hold_id
hold_type
affected_scope
reason
requested_by
approved_by
created_at
review_at
released_at
status
```

Hold must override normal deletion or anonymization schedule.

---

## 12. Redaction Policy

Redaction must remove or mask sensitive details while preserving investigability.

Data that must be redacted or masked where possible:

- raw credentials;
- access tokens;
- webhook secrets;
- full card number;
- raw payment authentication payload;
- unnecessary customer contact details;
- provider private tokens;
- internal secret headers;
- raw signatures where not needed;
- unrelated customer/staff information.

Redaction must not remove essential transaction references required for dispute and reconciliation.

---

## 13. Redaction Levels

Recommended redaction levels:

| Level | Meaning |
|---|---|
| `none` | No redaction needed |
| `masked` | Sensitive parts masked but value remains recognizable |
| `tokenized` | Original value replaced by internal token |
| `hashed` | Value hashed for matching without exposing original |
| `removed` | Sensitive field removed |
| `summary_only` | Raw payload removed, safe summary retained |
| `sealed` | Raw evidence sealed and accessible only under approval |

Redaction level must be recorded.

---

## 14. Raw Payload Retention

Raw provider payloads must be handled carefully.

Raw payloads may be retained when necessary for:

- incident investigation;
- provider escalation;
- reconciliation variance;
- adapter debugging;
- legal/audit evidence;
- security investigation.

Raw payloads must not be retained indefinitely by default.

Raw payload handling must define:

```text
payload_id
source_system
transaction_id
sensitivity_level
redaction_level
retention_category
legal_hold_flag
created_at
expires_at
access_policy
```

Where possible, store a safe normalized summary instead of raw payload.

---

## 15. Secret Data Prohibition

The following must not be stored in normal POS Gateway evidence tables, logs, or alert payloads:

- raw production credentials;
- private keys;
- unredacted bearer tokens;
- webhook signing secrets;
- full card numbers;
- CVV/CVC;
- unencrypted sensitive payment authentication payloads;
- admin passwords;
- session cookies;
- provider dashboard passwords.

If such data is accidentally captured, a security incident and redaction purge workflow must be triggered.

---

## 16. Customer Data Minimization

Customer data must be minimized.

The gateway should store only what is needed for:

- transaction proof;
- customer support;
- dispute investigation;
- notification delivery;
- refund/cancellation handling;
- legal or accounting retention.

Customer identity references should be tokenized or scoped where possible.

Customer-sensitive data must not be exposed in operations dashboards unless needed for the role and purpose.

---

## 17. Staff Data Minimization

Staff data must be sufficient for accountability but not excessive.

Staff action evidence should retain:

- staff actor ID;
- role;
- store;
- action;
- approval reference;
- timestamp;
- device/session reference where relevant.

Staff personal details beyond operational accountability must be minimized.

Access to staff-sensitive action records must be role-restricted.

---

## 18. Provider Data Boundary

Provider-sensitive data must be protected.

Provider evidence may include:

- provider account reference;
- provider transaction reference;
- provider error codes;
- provider response summary;
- provider support ticket ID;
- provider limitation notes.

Provider credentials and private operational secrets must not be stored in evidence packets.

Provider escalation packets must be safe to share externally.

---

## 19. Audit Event Retention

Audit events must be retained with transaction-critical evidence.

Audit events must remain searchable by:

- tenant;
- store;
- actor;
- transaction ID;
- event type;
- business date;
- provider;
- incident ID;
- reconciliation case ID;
- cutover epoch ID.

Audit event deletion is prohibited unless required by a controlled retention/anonymization policy that preserves legal and financial requirements.

---

## 20. Log Retention Policy

Logs must support forensic reconstruction without becoming a privacy or secret leakage risk.

Log retention must define:

- hot log retention;
- cold log archive;
- redaction rules;
- trace correlation retention;
- sensitive field filtering;
- incident hold extension;
- deletion/anonymization schedule.

Logs tied to incidents, reconciliation, customer disputes, or provider escalation must be preserved with the related case.

---

## 21. Trace Correlation Retention

Trace correlation identifiers must be retained even when detailed logs expire.

Required trace identifiers:

```text
request_id
transaction_id
order_id
payment_reference_id
provider_code
idempotency_key_hash
cutover_epoch_id
routing_decision_id
reconciliation_case_id
incident_id
```

Trace correlation must allow later evidence stitching without exposing sensitive payloads.

---

## 22. Dead-Letter Evidence Retention

Dead-letter entries may contain important failure evidence.

Dead-letter retention must preserve:

- job type;
- transaction reference;
- safe error classification;
- attempt count;
- last attempt time;
- manual review requirement;
- reconciliation impact;
- incident link;
- redaction state.

Resolved dead-letter entries may be archived, but transaction-critical failure evidence must not be deleted prematurely.

---

## 23. Customer Communication Retention

Customer communication must be retained when related to:

- payment state;
- duplicate charge risk;
- refund/cancellation;
- receipt/proof;
- dispute;
- sold-out after payment;
- price mismatch;
- table/session error;
- incident.

Communication retention must preserve:

- template version;
- rendered message;
- channel;
- delivery status;
- timestamp;
- related transaction;
- privacy classification.

Routine non-critical notifications may have shorter retention if not tied to dispute or financial evidence.

---

## 24. Reconciliation and Accounting Retention

Reconciliation and accounting evidence must retain:

- source records;
- variance classification;
- matching result;
- adjustment records;
- closure decision;
- approver;
- export block/release decision;
- settlement reference;
- accounting export version.

Reconciliation evidence must not be destroyed while accounting, settlement, dispute, or incident matters remain open.

---

## 25. Incident and Postmortem Retention

Incident evidence must retain:

- incident case;
- timeline;
- affected transactions;
- containment actions;
- rollback decisions;
- provider escalation;
- customer impact review;
- manual corrections;
- reconciliation links;
- postmortem;
- corrective actions.

Incident evidence may require extended retention when financial or customer impact occurred.

---

## 26. Deletion and Anonymization Policy

Deletion or anonymization must be controlled.

Before deletion/anonymization, the system must check:

- legal hold;
- forensic hold;
- active incident;
- active dispute;
- unresolved reconciliation case;
- open refund/cancellation case;
- accounting retention requirement;
- provider escalation requirement;
- audit retention requirement.

Deletion should create a tombstone when needed.

Tombstone may retain:

```text
record_type
record_id_hash
tenant_id
store_id
deletion_reason
deleted_at
deleted_by
retention_policy_reference
```

---

## 27. Right-To-Delete Boundary

If privacy deletion requests apply, the gateway must distinguish customer personal data from financial transaction evidence.

Personal identifiers may be removed or anonymized where allowed, but legally required transaction evidence may need to remain.

The system must support:

- anonymizing customer reference;
- preserving transaction amount/date/store evidence;
- preserving payment/receipt references where legally required;
- preserving dispute/incident evidence under hold;
- recording deletion decision.

Deletion request handling must not destroy required financial or audit records.

---

## 28. Access Control

Evidence access must be role-based.

Access roles may include:

- store manager;
- tenant admin;
- support operator;
- reconciliation owner;
- payment owner;
- incident commander;
- technical operator;
- security owner;
- audit reviewer.

Access must be scoped by:

- tenant;
- store;
- role;
- case assignment;
- sensitivity level;
- purpose;
- time.

Sensitive evidence access must be logged.

---

## 29. Evidence Export Policy

Evidence export must be controlled.

Export may be needed for:

- provider escalation;
- customer dispute response;
- accounting audit;
- legal review;
- regulator response;
- internal postmortem.

Export must:

- minimize sensitive data;
- apply redaction;
- include provenance;
- include timestamp;
- include actor;
- include purpose;
- include approval where required.

Export must not include raw secrets or unrelated customer/staff data.

---

## 30. Evidence Integrity Verification

Archived and retained evidence must support integrity verification.

Recommended methods:

- checksum/hash for source files;
- immutable event ID;
- signed evidence packet where required;
- append-only audit log;
- archive manifest;
- retention policy reference;
- access log;
- redaction record.

Evidence integrity verification helps prove records were not altered after incident or dispute.

---

## 31. Retention Policy Versioning

Retention rules must be versioned.

Required fields:

```text
retention_policy_id
policy_version
record_type
evidence_class
sensitivity_level
retention_category
retention_period
archive_behavior
redaction_behavior
deletion_behavior
approved_by
effective_from
status
```

Records should store the retention policy version applied at creation or classification time.

---

## 32. Monitoring Requirements

Retention and archive health must be monitored.

Required metrics:

- records approaching retention expiry;
- records under legal/forensic hold;
- archive job success/failure;
- redaction job success/failure;
- deletion job success/failure;
- sensitive payload detection count;
- raw secret leakage detection count;
- evidence export count;
- unauthorized access attempt count;
- archived evidence retrieval failure count;
- retention policy mismatch count.

Critical failures must alert security, audit, or operations owners.

---

## 33. Dashboard Requirements

Operations/audit dashboard must show:

- retention policy status;
- archive status;
- legal/forensic holds;
- redaction status;
- deletion/anonymization queue;
- sensitive payload alerts;
- evidence export history;
- retention exceptions;
- archived evidence retrieval status;
- open evidence lifecycle incidents.

Dashboard must not expose sensitive data unnecessarily.

---

## 34. Incident Requirements

Evidence lifecycle incidents may include:

- raw credential captured in logs;
- full card data captured;
- customer data over-retained;
- required evidence deleted;
- archive retrieval failure;
- unauthorized evidence access;
- redaction failure;
- legal hold violation;
- deletion request mishandled;
- provider packet exported with excessive data.

Such incidents must be classified under security, privacy, audit, or operational impact depending on scope.

---

## 35. Prohibited Practices

The following practices are prohibited:

- storing raw production credentials in evidence records;
- logging full card data;
- deleting transaction evidence to satisfy convenience cleanup;
- anonymizing records under active legal or forensic hold;
- exporting provider escalation packet with raw secrets;
- retaining customer personal data without purpose;
- allowing unrestricted dashboard access to sensitive evidence;
- archiving evidence without searchable identifiers;
- modifying immutable audit events;
- deleting incident evidence before postmortem and reconciliation closure;
- treating redaction as deletion of financial truth.

---

## 36. Minimum Acceptance Criteria

Data retention, archive, privacy, redaction, and forensic evidence lifecycle is acceptable only when:

- evidence classification exists;
- sensitivity classification exists;
- retention categories exist;
- immutable evidence rules exist;
- archive states exist;
- legal/forensic hold policy exists;
- redaction levels exist;
- raw payload retention is controlled;
- secret data prohibition exists;
- customer/staff/provider data minimization exists;
- audit/log/dead-letter/communication retention rules exist;
- deletion/anonymization checks exist;
- access control exists;
- evidence export is controlled;
- evidence integrity verification exists;
- retention policy versioning exists;
- monitoring and incident handling exist.

---

## 37. Implementation Notes

Recommended implementation artifacts:

```text
pos_gateway_retention_policies
pos_gateway_evidence_classifications
pos_gateway_sensitivity_classifications
pos_gateway_archive_records
pos_gateway_archive_manifests
pos_gateway_legal_holds
pos_gateway_forensic_holds
pos_gateway_redaction_records
pos_gateway_raw_payload_records
pos_gateway_deletion_requests
pos_gateway_deletion_tombstones
pos_gateway_evidence_access_logs
pos_gateway_evidence_exports
pos_gateway_evidence_integrity_checks
pos_gateway_evidence_lifecycle_incidents
```

Recommended services:

```text
EvidenceClassificationService
SensitivityClassificationService
RetentionPolicyService
ArchiveLifecycleService
LegalHoldService
ForensicHoldService
RedactionService
RawPayloadRetentionService
SecretLeakDetectionService
CustomerDataMinimizationService
StaffDataMinimizationService
EvidenceAccessControlService
EvidenceExportService
EvidenceIntegrityVerificationService
DeletionAnonymizationService
RetentionMonitoringService
EvidenceLifecycleIncidentService
```

Recommended event types:

```text
pos_gateway.evidence.classified
pos_gateway.evidence.archived
pos_gateway.evidence.redacted
pos_gateway.evidence.legal_hold_applied
pos_gateway.evidence.forensic_hold_applied
pos_gateway.evidence.hold_released
pos_gateway.evidence.export_requested
pos_gateway.evidence.export_completed
pos_gateway.evidence.accessed
pos_gateway.evidence.deletion_requested
pos_gateway.evidence.anonymized
pos_gateway.evidence.deleted_with_tombstone
pos_gateway.evidence.secret_leak_detected
pos_gateway.evidence.lifecycle_incident_detected
```

---

## 38. Relationship To Adjacent Documents

This document is related to:

- 06120 POS Gateway reconciliation case workflow, variance resolution, manual adjustment, and audit closure policy;
- 06110 POS Gateway customer status message, receipt proof, notification, and dispute communication policy;
- 06100 POS Gateway staff operation, manual fallback, override authority, and manager approval policy;
- POS Gateway audit event, evidence retention, and forensic traceability implementation policy;
- POS Gateway incident response, dispute investigation, provider escalation, and postmortem policy;
- POS Gateway settlement, reconciliation, closing report, and accounting linkage policy;
- POS Gateway security, secret rotation, access control, and production operation hardening policy;
- tenant/store SaaS onboarding and operational enablement policy.

Where conflict exists, this document governs POS Gateway data retention, archive, privacy, redaction, and forensic evidence lifecycle behavior.

---

## 39. Summary

The POS Gateway must remember enough to prove what happened, but not so much that sensitive data becomes a liability.

The correct standard is:

- retain transaction truth;
- minimize personal data;
- redact secrets;
- preserve immutable evidence;
- archive with searchable links;
- hold evidence during disputes and incidents;
- delete or anonymize only through controlled rules;
- export evidence safely.

Evidence that cannot be found is useless.  
Evidence that exposes secrets is dangerous.  
Evidence that was edited to look clean is worse than no evidence at all.