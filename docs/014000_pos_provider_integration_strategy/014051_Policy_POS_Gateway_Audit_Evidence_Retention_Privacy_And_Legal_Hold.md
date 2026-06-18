# 014051_Policy_POS_Gateway_Audit_Evidence_Retention_Privacy_And_Legal_Hold

## 1. Purpose

This policy defines how POS Gateway audit evidence, raw packets, payment references, reconciliation records, operator actions, provider dispute packets, store dispute evidence, local agent logs, printer evidence, and legal hold records must be retained, protected, redacted, accessed, exported, and destroyed.

The purpose is to ensure that the platform can prove what happened during POS-connected order, payment, kitchen, waiting, table, inventory, settlement, and manual mutation incidents while also protecting customer privacy, payment data, store data, provider secrets, and internal system security.

Evidence must be strong enough for operational recovery, finance reconciliation, provider dispute, store dispute, audit review, and legal defense, but must not become an uncontrolled privacy or security liability.

## 2. Scope

This policy applies to:

* POS Gateway audit events
* Raw provider request and response packets
* Provider webhook payloads
* Local agent logs
* Printer evidence
* Kitchen ticket evidence
* Payment references
* PG/VAN reconciliation evidence
* POS receipt evidence
* In-doubt transaction records
* Refund and void evidence
* Operator recovery actions
* Manual POS mutation timeline
* Suspicious mutation evidence
* Provider dispute packets
* Store dispute packets
* Finance review evidence
* Legal hold records
* Evidence export
* Evidence redaction
* Evidence retention
* Evidence destruction
* Evidence access control

This policy applies to all POS Gateway production, pilot, sandbox, and incident investigation evidence.

## 3. Core Principle

Evidence must be immutable, minimal, protected, and usable.

The platform must preserve enough evidence to reconstruct critical facts, but it must not store unnecessary sensitive data indefinitely.

The system must answer:

* What happened?
* When did it happen?
* Which system produced the evidence?
* Has the evidence been changed?
* Who accessed it?
* Who exported it?
* Is it safe to share externally?
* Is it under legal hold?
* When may it be deleted?

## 4. Evidence Lifecycle Boundary

Evidence moves through a controlled lifecycle.

```
[Runtime Event / Raw Packet / Operator Action]
                     |
                     v
          [Evidence Capture Layer]
                     |
                     v
          [Retention And Protection Layer]
                     |
    ---------------------------------------
    |              |                      |
    v              v                      v
[Audit Use]   [Dispute Use]        [Legal Hold / Destruction]
```

Evidence must remain traceable across its lifecycle.

## 5. Non-Negotiable Rules

### 5.1 Immutable Evidence Rule

Critical POS Gateway evidence must not be overwritten, edited, or deleted by ordinary runtime processes.

Corrections must be appended as new evidence.

### 5.2 Minimal Sensitive Data Rule

The system must not retain full sensitive payloads when hashed, tokenized, redacted, or referenced evidence is sufficient.

### 5.3 Access-Controlled Evidence Rule

Raw packets, payment references, suspicious mutation evidence, customer identifiers, and legal evidence must be access-controlled.

Not every operator may view raw evidence.

### 5.4 Export Must Be Tracked Rule

Every evidence export must be logged with actor, purpose, scope, recipient, redaction level, and timestamp.

### 5.5 Legal Hold Overrides Destruction Rule

Evidence under legal hold must not be destroyed until the hold is released by authorized role.

### 5.6 Retention Must Be Policy-Based Rule

Evidence must not be retained forever by accident.

Retention class must be explicit.

## 6. Evidence Categories

Allowed evidence categories include:

```
ORDER_EVENT_EVIDENCE
PAYMENT_EVENT_EVIDENCE
POS_PROVIDER_PACKET_EVIDENCE
PROVIDER_WEBHOOK_EVIDENCE
LOCAL_AGENT_EVIDENCE
PRINTER_EVIDENCE
KITCHEN_TICKET_EVIDENCE
WAITING_JOURNEY_EVIDENCE
TABLE_STATE_EVIDENCE
INVENTORY_HOLD_EVIDENCE
STOCK_CONFLICT_EVIDENCE
RECONCILIATION_EVIDENCE
IN_DOUBT_TRANSACTION_EVIDENCE
REFUND_VOID_EVIDENCE
OPERATOR_ACTION_EVIDENCE
MANUAL_POS_MUTATION_EVIDENCE
SUSPICIOUS_MUTATION_EVIDENCE
PROVIDER_DISPUTE_EVIDENCE
STORE_DISPUTE_EVIDENCE
LEGAL_HOLD_EVIDENCE
SECURITY_REVIEW_EVIDENCE
TEST_EVIDENCE
```

Each category must have retention and access policy.

## 7. Evidence Sensitivity Classes

Evidence must be classified by sensitivity.

Allowed sensitivity classes include:

```
PUBLIC_SAFE
INTERNAL_OPERATIONAL
INTERNAL_RESTRICTED
FINANCE_RESTRICTED
SECURITY_RESTRICTED
LEGAL_RESTRICTED
PAYMENT_SENSITIVE
CUSTOMER_PERSONAL_DATA
PROVIDER_CONFIDENTIAL
STORE_CONFIDENTIAL
HIGHLY_RESTRICTED
```

Sensitivity class determines access, redaction, export, and retention.

## 8. Evidence Retention Classes

Evidence must be assigned retention class.

Allowed retention classes include:

```
SHORT_OPERATIONAL
STANDARD_AUDIT
FINANCE_RECONCILIATION
PROVIDER_DISPUTE
STORE_DISPUTE
SECURITY_AUDIT
LEGAL_HOLD
TEST_EVIDENCE
TEMPORARY_DEBUG
DELETE_ON_RESOLUTION
```

Retention periods must be defined by legal, finance, security, and operational requirements.

## 9. Raw Packet Retention

Raw provider packets may contain sensitive data.

The system must preserve:

* Raw packet reference
* Hash
* Provider ID
* Endpoint
* Direction
* Timestamp
* Adapter version
* Schema version
* Validation result
* Redaction status
* Storage location
* Access class

The system should avoid storing unnecessary secrets, tokens, full card data, or unrelated personal data.

Raw packet evidence must be redacted before external sharing.

## 10. Payment Evidence Retention

Payment evidence must preserve facts without exposing prohibited payment data.

Payment evidence may include:

* Payment ID
* Payment group ID
* PG transaction reference
* VAN approval reference
* Approval amount
* Approval timestamp
* Refund reference
* Void reference
* Network cancel reference
* Payment state transitions
* In-doubt state
* Reconciliation result
* Masked payment method
* Customer notification state

The system must not store full card numbers, CVV, or prohibited payment authentication data.

## 11. Customer Data Minimization

Customer-related evidence must minimize personal data.

Where possible, evidence should use:

* Customer ID reference
* Session ID
* Masked phone number
* Masked name
* Tokenized identifier
* Hashed contact value
* Order-level reference

Customer personal data must not be included in provider dispute packet unless necessary and approved.

## 12. Provider And Store Confidentiality

Provider and store evidence may contain confidential commercial or technical data.

Evidence may include:

* Provider API behavior
* Error payload
* Rate limit behavior
* Contract version
* Store POS configuration
* Store business day behavior
* Store sales channel mapping
* Store manual mutation evidence
* Store settlement impact

Access must be limited to roles with need-to-know.

External sharing must be purpose-limited.

## 13. Evidence Integrity

Evidence integrity must be preserved.

Methods may include:

* Append-only event log
* Content hash
* Evidence bundle hash
* Versioned storage object
* Write-once policy, where available
* Immutable audit event
* Tamper-evident metadata
* Signed export manifest, where appropriate

The system must be able to show whether evidence has changed.

## 14. Evidence Chain Of Custody

For dispute or legal evidence, the chain of custody must track:

```
evidence_id
evidence_category
original_source
captured_at
captured_by_system
storage_location
hash
access_history
export_history
redaction_history
legal_hold_status
retention_class
destruction_status
```

Chain of custody is required for legal and high-risk finance disputes.

## 15. Evidence Access Roles

Access should be role-scoped.

Possible access roles include:

```
STORE_STAFF_VIEW_LIMITED
STORE_MANAGER_VIEW_LIMITED
HQ_SUPPORT_VIEW_OPERATIONAL
HQ_SUPPORT_LEAD_VIEW_RESTRICTED
FINANCE_VIEW_FINANCIAL
FINANCE_MANAGER_VIEW_FINANCIAL_RESTRICTED
TECHNICAL_SUPPORT_VIEW_TECHNICAL
SECURITY_AUDITOR_VIEW_SECURITY
LEGAL_REVIEW_VIEW_LEGAL
SYSTEM_ADMIN_INFRA_ONLY
READ_ONLY_AUDITOR
```

System administrators should not automatically have business evidence viewing authority unless explicitly approved.

## 16. Access Reason Codes

Restricted evidence access must require reason code.

Allowed reason codes include:

```
CUSTOMER_SUPPORT
STORE_SUPPORT
PROVIDER_INCIDENT
PAYMENT_RECONCILIATION
REFUND_REVIEW
IN_DOUBT_REVIEW
SUSPICIOUS_MUTATION_REVIEW
SECURITY_REVIEW
LEGAL_REVIEW
TAX_OR_FINANCE_REVIEW
PROVIDER_DISPUTE
STORE_DISPUTE
TEST_AUDIT
OTHER_WITH_NOTE_REQUIRED
```

Restricted access without reason is prohibited.

## 17. Evidence Redaction Levels

Evidence export must apply redaction level.

Allowed redaction levels include:

```
NO_REDACTION_INTERNAL_HIGH_AUTHORITY
OPERATIONAL_REDACTION
PAYMENT_REDACTION
CUSTOMER_REDACTION
PROVIDER_EXTERNAL_REDACTION
STORE_EXTERNAL_REDACTION
LEGAL_REDACTION
FULL_ANONYMIZED
HASH_ONLY
```

The default for external sharing must be redacted.

## 18. Evidence Export Policy

Evidence export must record:

```
export_id
evidence_ids
export_actor
export_role
export_reason
recipient_type
recipient_identifier
redaction_level
export_format
export_timestamp
expiration_policy
approval_reference
legal_hold_reference
hash_manifest
```

Exports must be discoverable in audit.

## 19. Dispute Packet Retention

Provider, PG/VAN, and store dispute packets must be retained with:

* Dispute packet ID
* Related incident ID
* Related evidence IDs
* Generated version
* Redaction level
* Recipient
* Sent timestamp
* Response status
* Outcome
* Closure reference
* Hash manifest

A dispute packet must not replace original internal evidence.

## 20. Legal Hold

Legal hold may be applied when:

* Litigation is expected
* Regulator inquiry occurs
* Payment dispute escalates
* Store dispute escalates
* Provider dispute escalates
* Suspicious mutation becomes legal risk
* Security incident overlaps POS evidence
* Tax or settlement dispute requires preservation

Legal hold must preserve evidence beyond normal retention.

## 21. Legal Hold Record

A legal hold record should include:

```
legal_hold_id
hold_reason
scope
evidence_categories
related_store_ids
related_provider_ids
related_order_ids
related_payment_ids
start_at
authorized_by
reviewed_by
release_criteria
released_at
released_by
notes
```

Legal hold changes must be audited.

## 22. Destruction Policy

Evidence may be destroyed only when:

* Retention period expired
* No legal hold applies
* No active dispute applies
* No unresolved reconciliation applies
* No security review applies
* Destruction job is authorized
* Destruction is audited

Destruction should preserve minimal destruction proof.

## 23. Destruction Record

A destruction record should include:

```
destruction_id
evidence_ids_or_scope
retention_class
destruction_reason
legal_hold_checked
dispute_checked
reconciliation_checked
destroyed_at
destroyed_by_system
approved_by, if required
destruction_proof_hash
```

Destruction must not expose deleted sensitive data.

## 24. Test Evidence Retention

Test evidence must be separated from production evidence.

Test evidence should use synthetic data wherever possible.

If production-like evidence is used in pilot or simulation, it must be labeled and protected.

Test evidence must not contain live customer payment data unless explicitly approved and legally permitted.

## 25. Debug Log Retention

Temporary debug logs are high risk.

Debug logs may contain:

* Raw payloads
* Tokens
* Internal IDs
* Stack traces
* Provider responses
* Customer references
* Store configuration

Temporary debug logs must have short retention, access limits, and automatic cleanup.

Debug logging in production must be controlled by approval and scope.

## 26. Monitoring Data Retention

Monitoring metrics must be retained according to operational usefulness and sensitivity.

Aggregated metrics may be retained longer than raw events.

Examples:

* Provider latency aggregate
* Store health trend
* Queue depth trend
* In-doubt count trend
* Reconciliation count trend
* Alert history

Metric retention must not expose customer-level sensitive data unnecessarily.

## 27. Audit Of Evidence Access

Every restricted evidence access must preserve:

* Actor
* Role
* Evidence ID
* Evidence category
* Sensitivity class
* Access reason
* Access time
* Access method
* Export flag
* Redaction level, if applicable
* Approval reference, if applicable
* Result

Unauthorized access attempts must be logged and escalated.

## 28. Breach And Misuse Handling

If evidence is accessed or exported improperly, the system must support:

* Access review
* Export revocation, where possible
* Security incident creation
* Legal review
* User access suspension
* Evidence scope analysis
* Affected customer or store assessment
* Corrective action

Evidence systems must not become a hidden data leak source.

## 29. Evidence Search And Retrieval

Evidence search must be controlled.

Searchable dimensions may include:

* Order ID
* Payment ID
* Store ID
* Provider ID
* Incident ID
* Recovery case ID
* In-doubt ID
* Dispute packet ID
* Raw packet ID
* Time range
* Evidence category
* Sensitivity class
* Retention class

Broad search over restricted evidence should require higher authority.

## 30. Audit Requirements

Evidence lifecycle audit must preserve:

* Evidence ID
* Evidence category
* Sensitivity class
* Retention class
* Capture source
* Capture timestamp
* Hash
* Storage location
* Access events
* Export events
* Redaction events
* Legal hold events
* Destruction events
* Actor
* Role
* Reason code
* Approval reference
* Policy version
* Timestamp

Evidence lifecycle events must themselves be protected audit records.

## 31. Test Requirements

Evidence retention and legal hold must be tested for:

* Evidence capture
* Raw packet redaction
* Payment evidence minimization
* Customer data masking
* Provider dispute export
* Store dispute export
* Legal hold application
* Legal hold release
* Destruction blocked by legal hold
* Destruction blocked by unresolved reconciliation
* Evidence access reason code
* Unauthorized access blocked
* Export audit created
* Redaction level applied
* Hash integrity check
* Chain of custody retrieval
* Temporary debug log expiration
* Test evidence separation
* Role-scoped evidence search

Evidence retention is not production-ready without access, export, hold, and destruction test evidence.

## 32. Anti-Patterns

The following are prohibited:

* Keeping all raw packets forever without classification
* Storing full sensitive payment data in logs
* Exporting raw provider packets without redaction
* Allowing all support staff to view all evidence
* Letting system administrators view business evidence by default
* Deleting evidence under active dispute
* Destroying evidence without checking legal hold
* Using production customer data in test fixtures unnecessarily
* Capturing debug logs broadly in production without expiration
* Allowing incident closure after evidence has been lost
* Treating screenshots as replacement for immutable evidence
* Sharing suspicious mutation evidence without review

## 33. Relationship With Other Documents

This policy supports:

```
04900 Security Runtime Test Catalog
05300 POS Gateway Resilience And Field Exception Catalog Readme
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
05440 POS VAN PG Tax Sales Channel And Unpaid Order Reconciliation Policy
05470 POS InDoubt Transaction Network Cancel Receipt Number And Financial Reconciliation Policy
05480 POS Multi Endpoint Routing Delivery App Port Contention And Malicious Manual Mutation Defense Policy
05510 POS Gateway Operator Recovery Console And Action Authority Policy
05520 POS Integration Incident Triage And Provider Dispute Evidence Policy
05540 POS Gateway SLO Monitoring Alert And Operational Health Dashboard Policy
```

Evidence retention is the long-term proof and risk-control layer of the POS Gateway.

## 34. Final Rule

The POS Gateway must preserve enough evidence to prove critical operational, financial, provider, store, and legal facts while minimizing sensitive data exposure.

If the platform cannot prove what happened because evidence expired too early, or if it creates privacy and security risk by keeping unrestricted raw evidence forever, the audit evidence retention boundary has failed.
