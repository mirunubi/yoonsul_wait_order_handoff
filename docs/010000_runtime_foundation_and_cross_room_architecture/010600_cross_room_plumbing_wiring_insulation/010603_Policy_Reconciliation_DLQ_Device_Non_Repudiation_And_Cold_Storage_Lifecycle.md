# 010603_Policy_Reconciliation_DLQ_Device_Non_Repudiation_And_Cold_Storage_Lifecycle.md

## Purpose

This document defines the Reconciliation DLQ, Device Non-Repudiation, and Cold Storage Lifecycle Policy.

The previous artifacts defined:

- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`

This document adds three final critical controls for real franchise-scale operation:

1. Long-tail reconciliation error isolation through Dead Letter Queue.
2. Device-key-based non-repudiation for kiosk, POS terminal, tablet, local agent, and OS logs.
3. Long-term audit/log retention through cold storage and lifecycle tiering.

The purpose is to ensure that unresolved edge-case records do not stop the entire nightly batch, device-generated evidence cannot be casually denied, and massive audit/log volume does not destroy performance or cost structure as the system scales.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Financial-grade reconciliation must handle the long tail.

The correct rule is:

Unmatched record must not crash the batch.  
Unmatched record must not be silently accepted.  
Unmatched record must be isolated for review.  
Device log must be signed or integrity-bound to the device.  
Store code is not enough for legal proof.  
OS log is weak unless device identity and integrity are preserved.  
Hot database must not become permanent log landfill.  
Cold storage is not deletion.  
Archive is not loss of auditability.  
Retention must survive scale, dispute, compliance, and security review.  

The system must isolate exceptions, prove device origin, and tier data safely.

---

## 3. Critical Control Catalog

The following controls must be added to the financial-grade reconciliation architecture:

| Control | Purpose |
|---|---|
| `RECONCILIATION_DLQ` | Isolate unresolved long-tail records without stopping batch |
| `MANUAL_REVIEW_INBOX` | Route unresolved records to finance/security/admin review |
| `DEVICE_KEY_NON_REPUDIATION` | Prove that a specific registered device produced a log/request |
| `DIGITAL_SIGNATURE_OR_HMAC` | Protect request/log origin and integrity |
| `DEVICE_CERTIFICATE_LIFECYCLE` | Manage device identity, issuance, rotation, revocation |
| `HOT_WARM_COLD_STORAGE_TIERING` | Prevent operational DB overload |
| `IMMUTABLE_ARCHIVE_RETENTION` | Preserve audit/legal evidence |
| `RETENTION_RETRIEVAL_INDEX` | Retrieve archived records for dispute/review |
| `COST_PERFORMANCE_GOVERNANCE` | Keep batch and dashboard performance stable |
| `COMPLIANCE_RETENTION_POLICY` | Preserve regulated/audit records for required period |

These controls must be considered before production-scale implementation.

---

## 4. Reconciliation Dead Letter Queue Boundary

A Reconciliation DLQ is a controlled isolation area for records that cannot be safely reconciled during batch.

DLQ may receive records such as:

- unmatched payment
- unmatched refund
- unmatched cancellation
- amount mismatch
- timestamp mismatch
- provider missing record
- internal missing record
- terminal/POS mismatch
- OS log uncertainty
- offline log signature failure
- duplicate payment risk
- value ledger mismatch
- settlement fee mismatch
- tenant/store scope mismatch
- batch source inconsistency
- report hash mismatch
- incomplete evidence packet

DLQ is not error deletion.

DLQ is not normal approval.

DLQ is unresolved evidence isolation.

---

## 5. DLQ Design Principle

The DLQ must allow normal records to continue.

The correct flow is:

1. Nightly batch processes all records.
2. Matched records continue to settlement candidate.
3. Unmatched records go to DLQ.
4. DLQ records block only affected transaction/settlement portion.
5. Normal records are not held hostage by a few long-tail exceptions.
6. DLQ records appear in review dashboard.
7. Reviewer resolves or escalates.
8. Resolution creates append-only amendment or verified exception closure.
9. Batch and settlement status reflect unresolved DLQ count.

DLQ prevents batch crash and prevents silent acceptance.

---

## 6. DLQ Record Catalog

Recommended DLQ record fields:

| Field | Meaning |
|---|---|
| `dlq_id` | DLQ record identifier |
| `exception_type` | Mismatch or failure class |
| `severity` | Risk level |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope |
| `legal_entity_id` | Legal/settlement scope |
| `business_date` | Closing date |
| `source_room` | Source room that produced record |
| `source_object_id` | Source object reference |
| `internal_ledger_ref` | Internal ledger reference |
| `provider_ledger_ref` | Provider ledger reference |
| `terminal_pos_ref` | Store terminal/POS reference |
| `os_log_ref` | OS/runtime log reference |
| `audit_ref` | Audit reference |
| `evidence_packet_ref` | Evidence packet reference |
| `time_confidence` | Timestamp confidence |
| `device_signature_status` | Signature/HMAC verification result |
| `reconciliation_status` | Current review state |
| `assigned_reviewer` | Reviewer if assigned |
| `resolution_ref` | Resolution/amendment reference |

DLQ record must be scoped and auditable.

---

## 7. DLQ State Skeleton

Recommended DLQ states:

| State | Meaning |
|---|---|
| `DLQ_CREATED` | Isolated for review |
| `DLQ_EVIDENCE_INCOMPLETE` | Evidence missing |
| `DLQ_SIGNATURE_REVIEW_REQUIRED` | Device signature issue |
| `DLQ_PROVIDER_REVIEW_REQUIRED` | Provider confirmation needed |
| `DLQ_TERMINAL_REVIEW_REQUIRED` | Store terminal/POS review needed |
| `DLQ_OS_LOG_REVIEW_REQUIRED` | OS/runtime log review needed |
| `DLQ_FINANCE_REVIEW_REQUIRED` | Finance review needed |
| `DLQ_SECURITY_REVIEW_REQUIRED` | Security review needed |
| `DLQ_STORE_REVIEW_REQUIRED` | Store/owner review needed |
| `DLQ_RESOLUTION_PENDING` | Resolution prepared |
| `DLQ_AMENDMENT_REQUIRED` | Append-only amendment required |
| `DLQ_RESOLVED_VERIFIED` | Verified resolved |
| `DLQ_CLOSED_FALSE_POSITIVE` | False positive closed |
| `DLQ_ESCALATED_LEGAL_COMPLIANCE` | Legal/compliance escalation |
| `DLQ_BLOCKED` | Cannot proceed |
| `DLQ_UNKNOWN` | Unknown state |

DLQ state is review state.

It is not financial settlement state.

---

## 8. Manual Review Inbox Boundary

DLQ records must route to a manual review inbox.

Review inbox may be separated by role:

| Inbox | Handles |
|---|---|
| `FINANCE_REVIEW_INBOX` | payment/refund/value/settlement mismatch |
| `SECURITY_REVIEW_INBOX` | tamper, signature, device, attack anomaly |
| `STORE_OPS_REVIEW_INBOX` | terminal/POS/local fallback record |
| `PROVIDER_REVIEW_INBOX` | PG/VAN/provider missing/conflicting records |
| `COMPLIANCE_REVIEW_INBOX` | legal hold, export, dispute, regulated evidence |
| `SUPPORT_REVIEW_INBOX` | customer complaint or recovery relation |
| `HQ_REVIEW_INBOX` | franchise-level dispute and final escalation |

Review inbox is not automatic approval.

Review requires evidence and audit.

---

## 9. DLQ Settlement Impact Boundary

DLQ affects settlement carefully.

Possible settlement impact:

| DLQ Case | Settlement Handling |
|---|---|
| Low-risk non-financial mismatch | Settlement may continue with warning |
| Payment unknown | Affected amount held |
| Refund unknown | Affected amount held or marked pending |
| Duplicate risk | Affected duplicate amount held |
| Provider missing | Affected transaction blocked from final settlement |
| Terminal/POS missing | Review required before final settlement |
| Signature failure | Security review required |
| Tenant/store scope mismatch | Settlement blocked for affected record |
| Batch integrity failure | Wider settlement hold may apply |

DLQ should not freeze all stores unless systemic risk exists.

DLQ must not hide affected amount.

---

## 10. Device Non-Repudiation Boundary

Device non-repudiation means the system can prove that a specific registered device produced a specific request or log.

Device non-repudiation may apply to:

- kiosk order request
- NFC table order request
- payment attempt
- local approval marker
- refund/cancel request
- POS handoff event
- local fallback record
- OS/runtime log
- offline log chain
- device sync request
- terminal closing summary
- security event
- app lifecycle event

Store code or login alone is insufficient.

Device-bound cryptographic proof is required for high-risk evidence.

---

## 11. Device Identity Catalog

Registered device identity may include:

| Field | Meaning |
|---|---|
| `device_id` | Internal device id |
| `tenant_id` | Tenant owner |
| `store_id` | Store owner |
| `device_type` | Kiosk/tablet/POS/local agent/etc. |
| `hardware_fingerprint_ref` | Hardware identity reference, if allowed |
| `certificate_id` | Device certificate reference |
| `public_key_ref` | Device public key reference |
| `key_version` | Active key version |
| `registered_at` | Registration time |
| `registered_by` | Registration actor |
| `provisioning_method` | Provisioning method |
| `status` | Active/quarantined/revoked/retired |
| `last_seen_at` | Last seen timestamp |
| `clock_confidence` | Time confidence |
| `integrity_status` | Device integrity status |

Device identity must be tenant/store scoped.

---

## 12. Device Key Issuance Boundary

Device key issuance must be controlled.

Issuance should require:

- authorized provisioning actor
- tenant/store scope
- device enrollment evidence
- device type
- hardware binding if available
- certificate or public key registration
- key version
- issuance timestamp
- revocation route
- audit event
- recovery process

Device key is not ordinary configuration.

It is financial/security evidence infrastructure.

---

## 13. Device Signature Boundary

High-risk device-originated records should be signed or HMAC-protected.

Signature/HMAC should cover:

- device id
- tenant id
- store id
- event type
- event payload hash
- timestamp
- sequence number
- offline session id if applicable
- idempotency key
- previous event hash if chained
- key version

Signature proves integrity and origin candidate.

Signature does not prove business truth by itself.

---

## 14. Non-Repudiation Evidence Boundary

For legal/business dispute, non-repudiation evidence may include:

- registered device identity
- device certificate/public key
- signed event payload
- signature verification result
- key version
- device provisioning audit
- device status at event time
- OS/runtime log reference
- terminal/POS record reference
- provider record reference
- internal ledger reference
- time synchronization evidence
- chain hash reference
- batch reconciliation report
- immutable archive reference

Non-repudiation evidence must be preserved.

It must be projected safely.

---

## 15. Device Key Rotation Boundary

Device keys must support rotation.

Rotation may be required when:

- scheduled rotation period arrives
- device compromise suspected
- key leakage suspected
- device ownership changes
- store closes/transfers
- app reinstall/provisioning reset
- certificate expiry
- algorithm/key policy changes
- incident response requires rotation

Key rotation must preserve ability to verify past records.

Old key must not be erased if needed for historical verification.

---

## 16. Device Key Revocation Boundary

Device key revocation may occur when:

- device stolen
- device lost
- device tampered
- malware suspected
- store contract terminated
- device decommissioned
- provisioning fraud suspected
- repeated signature failure
- clock manipulation detected
- unauthorized app build detected

Revoked device must not create new trusted records.

Past records remain verifiable with historical key metadata.

---

## 17. Device Dispute Boundary

If a store disputes transaction/log origin, the system should verify:

- device was registered to store at event time
- key was active at event time
- signature verifies
- event sequence is continuous
- device clock was acceptable or adjusted
- provider record matches
- internal ledger matches
- terminal/POS evidence matches
- OS/runtime evidence supports the event
- batch report includes the record
- no revocation/compromise existed at event time

Dispute result must be evidence-based.

No party should rely on verbal claim alone.

---

## 18. Hot Warm Cold Storage Boundary

Logs and evidence must be tiered.

Recommended storage tiers:

| Tier | Purpose |
|---|---|
| `HOT_STORAGE` | Recent operational reconciliation and dashboards |
| `WARM_STORAGE` | Recent audit/review/dispute access |
| `COLD_STORAGE` | Long-term compressed archive |
| `IMMUTABLE_ARCHIVE` | Tamper-evident legal/audit records |
| `DEEP_ARCHIVE` | Long-term low-frequency retrieval if later needed |

Tiering is not deletion.

Tiering preserves retrieval under policy.

---

## 19. Hot Storage Boundary

Hot storage should hold records needed for:

- same-day operation
- nightly batch
- active reconciliation
- active DLQ review
- recent owner/admin dashboard
- recent support case
- recent security containment
- recent export generation
- short-term analytics

Hot storage must not be overloaded by permanent logs.

Hot storage should prioritize operational performance.

---

## 20. Warm Storage Boundary

Warm storage may hold:

- recent closing reports
- recent reconciliation evidence
- recent OS/runtime logs
- recent export audit
- recent security evidence
- recent support disputes
- recent batch reports
- recent DLQ resolutions

Warm storage supports review without burdening hot database.

---

## 21. Cold Storage Boundary

Cold storage may hold:

- historical DB trigger logs
- historical OS/runtime logs
- historical view/projection audit
- historical batch reports
- historical provider import files
- historical POS/terminal logs
- historical reconciliation evidence
- historical DLQ records
- historical export records
- historical device signature evidence
- historical settlement evidence

Cold storage must preserve integrity, retrieval index, and retention class.

Cold storage is not data loss.

---

## 22. Immutable Archive Boundary

Immutable archive or WORM-style storage should be considered for high-risk records:

- daily closing report hash
- settlement candidate report
- reconciliation exception list
- batch execution report
- provider import hash
- device key issuance/revocation audit
- export delivery evidence
- security containment report
- financial amendment record
- legal/compliance hold record

Immutable archive protects against tampering.

It does not replace source records.

---

## 23. Retention Period Boundary

Retention period must be defined by data class and legal/compliance requirement.

Planning assumption:

- financial, settlement, payment, refund, value ledger, audit, and security evidence may require long-term retention.
- regulated or dispute-relevant records may require multi-year retention.
- exact legal period must be confirmed separately with legal/compliance counsel.
- retention policy must not be guessed inside implementation.

This document does not assert a final statutory retention period.

It requires a retention matrix before coding.

---

## 24. Archive Retrieval Boundary

Archived data must remain retrievable for authorized purposes.

Retrieval should require:

- requester role
- purpose
- tenant/store/legal scope
- date range
- data class
- retention class
- masking requirement
- approval requirement
- audit trail
- export control if delivered outside system

Archive retrieval is controlled access.

Archive retrieval is not general dashboard query.

---

## 25. Archive Index Boundary

Cold storage needs a lightweight index.

Archive index may include:

- archive object id
- tenant id
- store id
- legal entity id
- business date
- data class
- retention class
- source object family
- hash
- storage location reference
- encryption/key reference
- immutable marker
- retrieval status
- expiry/hold status

Index must not expose raw sensitive data.

Index enables lawful retrieval.

---

## 26. Data Tiering Batch Boundary

Daily or periodic data tiering may:

- move closed logs from hot to warm/cold storage
- preserve hash
- preserve retrieval index
- preserve retention class
- verify copy integrity
- mark source as archived
- keep minimal hot reference
- block deletion when hold exists
- create audit event
- create tiering report

Tiering must not run before reconciliation status is known.

Tiering must not move unresolved DLQ evidence out of accessible review storage prematurely.

---

## 27. Cost And Performance Boundary

At franchise scale, log volume can damage cost and performance.

Performance controls may include:

- partitioning by tenant/store/date
- event family partitioning
- hot/warm/cold tiering
- compressed archive
- batch read windows
- incremental reconciliation
- archive index
- DLQ isolation
- report materialization
- query limit
- role-based access
- avoiding raw OS log scan for dashboards

Cost control must not destroy auditability.

---

## 28. DLQ And Cold Storage Interaction Boundary

DLQ records must remain review-accessible.

Rules:

- unresolved DLQ stays in hot or warm review storage
- resolved DLQ may be archived after retention rules
- DLQ evidence packet must remain linked
- associated OS logs/provider records/terminal logs must not disappear
- settlement hold marker must remain visible
- archive index must preserve DLQ relationship

DLQ must not be buried before resolution.

---

## 29. Device Key And Cold Storage Interaction Boundary

Device signature verification depends on historical keys.

Cold archive must preserve:

- device key version
- certificate/public key reference
- revocation status at event time
- key rotation history
- provisioning audit
- signature verification metadata
- event hash chain
- storage hash

If old key metadata is lost, historical non-repudiation weakens.

---

## 30. Legal Dispute Evidence Package Boundary

For settlement/legal dispute, evidence package may include:

- internal ledger record
- provider ledger record
- terminal/POS record
- OS/runtime log
- device signature verification
- device key registration record
- time sync evidence
- DLQ history if any
- reconciliation batch report
- amendment history
- settlement report
- export/delivery audit
- archive hash/reference
- reviewer notes
- approval records

Evidence package must be complete, scoped, and tamper-evident.

---

## 31. Owner Franchise Projection Boundary

Owner/franchise projection may show:

- unresolved reconciliation count
- DLQ count
- affected amount pending review
- verified settlement candidate
- pending settlement hold
- archive availability
- report hash if appropriate
- review status

Owner projection must not expose:

- raw cryptographic material
- device private key
- raw OS logs
- security exploit detail
- other store data
- cross-tenant data
- internal batch code hash detail if restricted
- unverified accusation

Owner trust requires safe and honest status.

---

## 32. Patent Candidate Boundary

These controls strengthen the patent candidate.

Potential patent-relevant extensions:

- reconciliation DLQ that isolates unresolved financial edge cases without stopping franchise-wide closing
- device-key-signed kiosk/POS/OS logs for non-repudiation in restaurant fintech context
- HMAC-chained offline logs combined with four-source reconciliation
- hot/warm/cold tiering for financial audit logs while preserving retrieval and legal evidence
- immutable report hash archive linked to nightly reconciliation
- owner-safe settlement projection with unresolved DLQ transparency
- franchise-scale immune security plus financial reconciliation lifecycle

Patent attorney refinement is required.

This is architecture planning only.

---

## 33. Relationship To Financial Reconciliation

This document extends `10601` and `10602`.

It adds:

- DLQ for long-tail reconciliation exceptions
- manual review inbox
- device key non-repudiation
- digital signature/HMAC proof
- cold storage lifecycle
- archive retrieval/indexing
- cost/performance governance
- dispute evidence package

These are required for realistic franchise-scale financial-grade operation.

---

## 34. Relationship To Cross-Room Plumbing

Cross-room flows must carry:

- DLQ reference
- review inbox route
- device id
- key version
- signature verification status
- archive reference
- retention class
- storage tier
- settlement hold marker
- evidence package reference
- archive retrieval permission

These fields must be considered in later context envelope and event routing design.

---

## 35. Relationship To Security Agent

Security Agent may detect:

- invalid device signature
- repeated signature failure
- revoked device event
- suspicious device key use
- DLQ spike
- archive hash mismatch
- abnormal log volume
- tampered offline chain
- suspicious cold storage access
- batch report mismatch

Security Agent may alert or contain.

It must not finalize financial truth.

---

## 36. Relationship To Data Governance

Data Governance must control:

- DLQ dashboard projection
- owner/franchise settlement status
- archive retrieval
- export of evidence package
- masking of device/security details
- retention class
- legal hold
- compliance hold
- AI summaries of DLQ
- pgvector use of historical incidents
- analytics over DLQ volume

DLQ and archive data must remain Safe Projection controlled.

---

## 37. Relationship To Store Runtime

Store Runtime must provide:

- device identity
- local event sequence
- signed local logs
- terminal/POS references
- offline session id
- sync state
- local fallback evidence
- clock confidence
- device key status
- OS/runtime references

Store Runtime creates evidence.

Financial Trust reconciles it.

---

## 38. Relationship To Retention Export Compliance

Retention/Export/Compliance must govern:

- how long DLQ records remain
- how long device signature metadata remains
- when logs move to cold storage
- which reports require immutable archive
- how evidence packages are exported
- when legal/compliance hold blocks deletion
- how archive retrieval is audited

Cold storage is a retention state, not deletion.

---

## 39. Anti-Patterns

Avoid:

- one bad record crashing the entire nightly batch
- unmatched record silently marked normal
- DLQ hidden from finance/admin review
- DLQ blocking all stores when only one store is affected
- device logs accepted without registered key
- store code treated as legal proof
- device private key exposed to app/UI
- old device key deleted so historical signatures cannot be verified
- revoked device creating trusted records
- cold storage treated as deletion
- archived records impossible to retrieve
- archive index exposing sensitive raw data
- unresolved DLQ moved to deep archive
- hot DB used as permanent OS log warehouse
- batch performance destroyed by raw historical log scan
- owner shown final settlement while DLQ exists
- legal dispute evidence missing device signature proof

These anti-patterns must be blocked in future runtime design.

---

## 40. Runtime Deferral

This document defines DLQ, device non-repudiation, and storage lifecycle architecture only.

It does not authorize:

- DLQ table creation
- manual review dashboard
- device certificate issuance
- digital signature implementation
- HMAC implementation
- key rotation/revocation runtime
- archive storage implementation
- cold storage migration
- immutable storage integration
- retention job implementation
- evidence package export
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 41. Validation Checklist

Validation must confirm:

1. Reconciliation DLQ boundary is defined.
2. DLQ design principle is defined.
3. DLQ record catalog is defined.
4. DLQ state skeleton is defined.
5. Manual review inbox boundary is defined.
6. DLQ settlement impact boundary is defined.
7. Device non-repudiation boundary is defined.
8. Device identity catalog is defined.
9. Device key issuance boundary is defined.
10. Device signature boundary is defined.
11. Non-repudiation evidence boundary is defined.
12. Device key rotation boundary is defined.
13. Device key revocation boundary is defined.
14. Device dispute boundary is defined.
15. Hot/warm/cold storage boundary is defined.
16. Hot storage boundary is defined.
17. Warm storage boundary is defined.
18. Cold storage boundary is defined.
19. Immutable archive boundary is defined.
20. Retention period boundary is defined without unsupported legal assertion.
21. Archive retrieval boundary is defined.
22. Archive index boundary is defined.
23. Data tiering batch boundary is defined.
24. Cost/performance boundary is defined.
25. DLQ/cold storage interaction boundary is defined.
26. Device key/cold storage interaction boundary is defined.
27. Legal dispute evidence package boundary is defined.
28. Owner/franchise projection boundary is defined.
29. Patent candidate boundary is defined.
30. Relationships to financial reconciliation, Cross-Room Plumbing, Security Agent, Data Governance, Store Runtime, and Retention/Export are defined.
31. Anti-patterns are listed.
32. Coding remains unauthorized.
33. Runtime remains deferred.

---

## 42. Relationship To Previous Documents

This document supplements:

- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10400~10480 Financial Trust Room Framing Sequence`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10554 Four-Layer Audit Capture Trigger View OS Log And Nightly Batch Reconciliation Policy`
- `10570 Retention Export And Compliance Data Boundary Policy`
- `10580 Data Governance Closure And Cross-Room Handoff Policy`
- `10600 Cross-Room Plumbing Wiring Insulation Planning Index`
- `10601 Financial-Grade Ledger Reconciliation And Four-Source Closing Audit Policy`
- `10602 Financial Reconciliation Blind Spot Control Time State Offline Log And Auditor Security Policy`

It prepares:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- future DLQ registry
- future manual review inbox specification
- future device certificate/key lifecycle specification
- future archive tiering specification
- future legal dispute evidence packet specification
- future runtime authorization packet

This document is architecture boundary planning only.

It does not authorize coding.

---

## 43. Final Rule

Financial-grade reconciliation must survive long-tail exceptions, legal disputes, and franchise-scale log volume.

Unmatched records must enter DLQ, not crash the batch and not be silently accepted.

DLQ records must be routed to manual review, preserve affected settlement status, and remain auditable.

Device-originated logs and payment requests must be tied to registered device identity through digital signature or HMAC-style integrity protection.

Store code is not enough for legal proof.

Device key lifecycle must support issuance, rotation, revocation, historical verification, and dispute evidence.

Hot databases must not become permanent log warehouses.

Closed logs and reports must move through hot, warm, cold, and immutable archive tiers while preserving hash, index, retention, legal hold, retrieval, and auditability.

Cold storage is not deletion.

Archive is not loss of evidence.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
