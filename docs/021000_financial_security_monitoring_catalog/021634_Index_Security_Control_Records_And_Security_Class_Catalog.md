# 021634_Index_Security_Control_Records_And_Security_Class_Catalog

## 1. Purpose

This document defines the Security Control Records catalog for the Financial-Grade Security Monitoring Foundation Package.

The previous artifacts defined:

- `21631`: bulkheads, source-of-truth, and trust boundaries
- `21632`: containment status and trigger map
- `21633`: quarantine status and trigger map

This document defines the control records that bind those concepts into reviewable security controls.

A security control is the cataloged rule that connects a risk trigger to a required protection behavior.

This document is catalog-only.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This catalog applies to security controls for:

1. Bulkhead isolation
2. Containment
3. Quarantine
4. Tokenization
5. Secret isolation
6. Provider verification
7. Idempotency
8. Reconciliation
9. Append-only records
10. Visibility and masking
11. Support/admin authority
12. AI boundary
13. pgvector boundary
14. Alert routing
15. Log integrity
16. Evidence linkage
17. Audit linkage
18. i18n message safety
19. Customer recovery
20. Retention and archive governance
21. Trigger-View-Agent monitoring
22. Legal/compliance hold
23. Runtime entry blocking

This document does not implement these controls.

It defines them as catalog records.

---

## 3. Core Principle

A control is valid only when it is:

- named
- scoped
- mapped to a bulkhead
- mapped to a trigger
- mapped to a required action
- mapped to evidence and audit when needed
- mapped to alerting when needed
- mapped to pgvector/AI boundaries
- mapped to a readiness blocker
- mapped to validation tests

Security that cannot be cataloged cannot be enforced.

Security that cannot be tested cannot be trusted.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `21634` |
| Package ID | `foundation.security_monitoring.financial_grade.v1` |
| Artifact Type | `CATALOG` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATALOG_ONLY` |
| Owner | `Architecture / Security Foundation` |
| Dependencies | `21631`, `21632`, `21633`, `21630`, `21620`, `21610`, `21570`, `21560` |
| Provider Evidence Status | `APPLIES_IF_PROVIDER_RELATED` |
| i18n Requirement | `APPLIES_IF_VISIBLE_ALERT_OR_STATUS` |
| Audit Requirement | `REQUIRED_FOR_CONTROL_TRIGGER_AUTHORITY_OR_RELEASE` |
| Security Requirement | `FINANCIAL_GRADE_CONTROL_CATALOG_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_AUDIT_REVIEW_REQUIRED` |
| Blocker Status | `SECURITY_CONTROL_CATALOG_REVIEW_REQUIRED` |

---

## 5. Security Control Record Schema

Each security control must include:

| Field | Required Meaning |
|---|---|
| Control ID | Stable control identifier |
| Control Family | Control category |
| Security Class | Security class affected |
| Bulkhead | Protected compartment |
| Protected Asset | What the control protects |
| Trigger Event | Event, condition, or state that activates review |
| Trigger Severity | Default severity |
| Required Action | Block, quarantine, contain, alert, audit, evidence, reconcile |
| Allowed Outcome | What may happen after control is satisfied |
| Prohibited Outcome | What must never happen |
| Alert Family | Alert generated if triggered |
| Log Requirement | Structured log requirement |
| Evidence Requirement | Evidence requirement |
| Audit Requirement | Audit requirement |
| pgvector Eligibility | Allowed, summary-only, blocked |
| AI Boundary | Allowed assistance and prohibited authority |
| Release Authority | Who may release or approve |
| Readiness Blocker | Blocking condition if undefined |
| Validation Test | Required test/check |

A control without prohibited outcomes is incomplete.

---

## 6. Security Class Catalog

Every future runtime package must declare a security class.

| Security Class | Meaning | Default Gate |
|---|---|---|
| `SECURITY_CLASS_LOW_INTERNAL` | Low-risk internal catalog/helper | Basic review |
| `SECURITY_CLASS_VISIBLE_TEXT` | Human/customer-visible text | i18n/content review |
| `SECURITY_CLASS_EXTERNAL_INPUT` | Accepts external input | Quarantine and validation required |
| `SECURITY_CLASS_PROVIDER_INPUT` | Accepts provider callback/data | Provider verification required |
| `SECURITY_CLASS_VALUE_BEARING` | Affects money, points, coupon, wallet | Idempotency, audit, evidence required |
| `SECURITY_CLASS_IDENTITY_BEARING` | Affects identity/consent | Privacy audit/review required |
| `SECURITY_CLASS_SUPPORT_AUTHORITY` | Affects support/admin action | Authority and audit required |
| `SECURITY_CLASS_FINANCIAL_LEDGER` | Affects ledger/settlement | Append-only and reconciliation required |
| `SECURITY_CLASS_AI_VECTOR` | Uses AI or pgvector | Source and authority boundaries required |
| `SECURITY_CLASS_CROSS_TENANT` | May cross tenant boundary | Security/HQ review required |
| `SECURITY_CLASS_CRITICAL` | Critical financial/security/legal risk | Full security gate required |

A package may have multiple security classes.

Highest applicable class controls the gate.

---

## 7. Control Family Catalog

| Control Family | Meaning |
|---|---|
| `CONTROL_BULKHEAD` | Domain compartment isolation |
| `CONTROL_CONTAINMENT` | Automatic defensive blocking |
| `CONTROL_QUARANTINE` | Isolation of untrusted input |
| `CONTROL_TOKENIZATION` | Sensitive reference tokenization |
| `CONTROL_SECRET_ISOLATION` | Secret exposure prevention |
| `CONTROL_PROVIDER_VERIFICATION` | Provider callback/capability verification |
| `CONTROL_IDEMPOTENCY` | Duplicate-effect prevention |
| `CONTROL_RECONCILIATION` | Mismatch review and resolution |
| `CONTROL_APPEND_ONLY` | No silent mutation/delete |
| `CONTROL_VISIBILITY_MASKING` | Restricted data visibility |
| `CONTROL_SUPPORT_AUTHORITY` | Support/admin authority restriction |
| `CONTROL_AI_BOUNDARY` | AI assistance-only boundary |
| `CONTROL_PGVECTOR_BOUNDARY` | Vector similarity-only boundary |
| `CONTROL_ALERT_ROUTING` | Severity, route, ack, escalation |
| `CONTROL_LOG_INTEGRITY` | Structured/tamper-aware logging |
| `CONTROL_EVIDENCE_LINKAGE` | Evidence packet linkage |
| `CONTROL_AUDIT_LINKAGE` | Audit event linkage |
| `CONTROL_I18N_MESSAGE` | Message key and approved text boundary |
| `CONTROL_CUSTOMER_RECOVERY` | Customer impact handling |
| `CONTROL_RETENTION_ARCHIVE` | Lifecycle, archive, manifest, legal hold |
| `CONTROL_TRIGGER_VIEW_AGENT` | Trigger/view/daemon monitoring boundary |
| `CONTROL_RUNTIME_ENTRY_GATE` | Blocks coding until readiness |

---

## 8. Control Record: Bulkhead Declaration

| Field | Value |
|---|---|
| Control ID | `CTRL-BULKHEAD-DECLARED` |
| Control Family | `CONTROL_BULKHEAD` |
| Security Class | All classes except lowest internal-only cases |
| Bulkhead | All declared bulkheads |
| Protected Asset | Domain source of truth and boundary |
| Trigger Event | Package enters runtime planning |
| Trigger Severity | `REVIEW_REQUIRED` |
| Required Action | Declare bulkhead, source of truth, trust level, allowed/prohibited propagation |
| Allowed Outcome | Package may proceed to next planning gate |
| Prohibited Outcome | Runtime coding without bulkhead |
| Alert Family | `ALERT_SECURITY_BULKHEAD_MISSING` |
| Log Requirement | Planning review log |
| Evidence Requirement | Bulkhead catalog reference |
| Audit Requirement | Required for runtime entry decision |
| pgvector Eligibility | Not applicable |
| AI Boundary | AI may summarize, cannot assign authority |
| Release Authority | Architecture/security review |
| Readiness Blocker | `BLOCKER-BULKHEAD-CATALOG-0001` |
| Validation Test | Package has bulkhead and SOT mapping |

---

## 9. Control Record: External Input Quarantine

| Field | Value |
|---|---|
| Control ID | `CTRL-QUAR-EXTERNAL-INPUT-DEFAULT` |
| Control Family | `CONTROL_QUARANTINE` |
| Security Class | `SECURITY_CLASS_EXTERNAL_INPUT` |
| Bulkhead | POS, provider, projection, SCM, HR, franchise sync |
| Protected Asset | Runtime truth from untrusted input |
| Trigger Event | External input arrives without full verification |
| Trigger Severity | `WARNING` or higher |
| Required Action | Quarantine, validate, evidence-link, route review |
| Allowed Outcome | Release after validation/review |
| Prohibited Outcome | External input mutates truth by default |
| Alert Family | `ALERT_SECURITY_EXTERNAL_INPUT_REJECTED` or domain alert |
| Log Requirement | Structured input metadata log |
| Evidence Requirement | Redacted payload/hash/correlation id |
| Audit Requirement | Required for release/rejection of high-risk input |
| pgvector Eligibility | Summary-only after approval |
| AI Boundary | May summarize quarantine reason only |
| Release Authority | Domain/security review |
| Readiness Blocker | `BLOCKER-QUARANTINE-CATALOG-0001` |
| Validation Test | External input cannot bypass quarantine rule |

---

## 10. Control Record: Provider Callback Verification

| Field | Value |
|---|---|
| Control ID | `CTRL-PROVIDER-CALLBACK-VERIFY` |
| Control Family | `CONTROL_PROVIDER_VERIFICATION` |
| Security Class | `SECURITY_CLASS_PROVIDER_INPUT` |
| Bulkhead | `BULKHEAD_PROVIDER`, `BULKHEAD_PAYMENT`, `BULKHEAD_LEDGER` |
| Protected Asset | Payment/settlement truth |
| Trigger Event | Provider callback received |
| Trigger Severity | `HIGH_RISK` if verification fails |
| Required Action | Verify signature, replay, idempotency, mapping, scope |
| Allowed Outcome | Verified callback may enter payment contract |
| Prohibited Outcome | Unverified callback mutates payment/ledger |
| Alert Family | `ALERT_SECURITY_PROVIDER_CALLBACK_QUARANTINED` |
| Log Requirement | Callback metadata and verification result |
| Evidence Requirement | Provider event id, hash, verification result |
| Audit Requirement | Required for accepted/rejected high-risk callback |
| pgvector Eligibility | Provider error summary only |
| AI Boundary | May identify missing evidence, cannot verify provider truth |
| Release Authority | Provider/security/finance review |
| Readiness Blocker | `BLOCKER-PROVIDER-VERIFICATION-0001` |
| Validation Test | Unsigned/failed callback cannot mutate state |

---

## 11. Control Record: Value-Bearing Idempotency

| Field | Value |
|---|---|
| Control ID | `CTRL-IDEMPOTENCY-VALUE-BEARING` |
| Control Family | `CONTROL_IDEMPOTENCY` |
| Security Class | `SECURITY_CLASS_VALUE_BEARING` |
| Bulkhead | Payment, ledger, membership, coupon, wallet |
| Protected Asset | Money, points, coupons, wallet balance, benefits |
| Trigger Event | Value-bearing event received |
| Trigger Severity | `HIGH_RISK` if idempotency missing |
| Required Action | Require idempotency key and duplicate-effect prevention |
| Allowed Outcome | Idempotent event processing after validation |
| Prohibited Outcome | Duplicate charge/use/point/coupon/wallet mutation |
| Alert Family | `ALERT_INTEGRATION_IDEMPOTENCY_MISSING` |
| Log Requirement | Idempotency key, payload hash, correlation id |
| Evidence Requirement | Required for duplicate/mismatch review |
| Audit Requirement | Required for duplicate resolution |
| pgvector Eligibility | Duplicate pattern summary only |
| AI Boundary | May classify duplicate risk, cannot choose final mutation |
| Release Authority | Finance/domain owner |
| Readiness Blocker | `BLOCKER-IDEMPOTENCY-VALUE-0001` |
| Validation Test | Duplicate payload cannot create duplicate value |

---

## 12. Control Record: Ledger Append-Only

| Field | Value |
|---|---|
| Control ID | `CTRL-LEDGER-APPEND-ONLY` |
| Control Family | `CONTROL_APPEND_ONLY` |
| Security Class | `SECURITY_CLASS_FINANCIAL_LEDGER` |
| Bulkhead | `BULKHEAD_LEDGER` |
| Protected Asset | Ledger truth and settlement auditability |
| Trigger Event | Ledger correction, reversal, mutation attempt |
| Trigger Severity | `CRITICAL` for update/delete attempt |
| Required Action | Create correction/reversal as new entry, never silent overwrite |
| Allowed Outcome | Append-only correction with evidence/audit |
| Prohibited Outcome | Silent update/delete of ledger truth |
| Alert Family | `ALERT_LEDGER_MUTATION_ATTEMPT` |
| Log Requirement | Mutation attempt log |
| Evidence Requirement | Required for correction/reversal |
| Audit Requirement | Always required |
| pgvector Eligibility | Reconciliation summary only |
| AI Boundary | May summarize mismatch, cannot post correction |
| Release Authority | Finance/reconciliation authority |
| Readiness Blocker | `BLOCKER-LEDGER-APPEND-ONLY-0001` |
| Validation Test | Ledger update/delete path is blocked by policy |

---

## 13. Control Record: Token Scope And Invalidation

| Field | Value |
|---|---|
| Control ID | `CTRL-TOKEN-SCOPE-INVALIDATION` |
| Control Family | `CONTROL_TOKENIZATION` |
| Security Class | External input, provider input, payment, POS, support authority |
| Bulkhead | POS, payment, provider, support/admin, customer session |
| Protected Asset | Scoped session, payment reference, device authority |
| Trigger Event | Token used outside scope or abnormal session pattern |
| Trigger Severity | `CRITICAL` if scope violation |
| Required Action | Block token use, invalidate scoped token if pre-approved, alert security |
| Allowed Outcome | Scoped defensive invalidation and review |
| Prohibited Outcome | Token reuse across tenant/store/device/provider scope |
| Alert Family | `ALERT_SECURITY_TOKEN_SCOPE_VIOLATION` |
| Log Requirement | Token reference hash, scope, actor, event |
| Evidence Requirement | Required for incident review |
| Audit Requirement | Required for invalidation |
| pgvector Eligibility | Token incident summary only |
| AI Boundary | May summarize, cannot issue/reissue tokens |
| Release Authority | Security/platform review |
| Readiness Blocker | `BLOCKER-TOKEN-SCOPE-0001` |
| Validation Test | Cross-scope token cannot proceed |

---

## 14. Control Record: Secret Isolation

| Field | Value |
|---|---|
| Control ID | `CTRL-SECRET-ISOLATION` |
| Control Family | `CONTROL_SECRET_ISOLATION` |
| Security Class | Critical, provider input, AI/vector, archive |
| Bulkhead | Provider, AI, pgvector, archive, support/admin |
| Protected Asset | API keys, service role keys, provider secrets, credentials |
| Trigger Event | Secret-like value appears in log, prompt, archive, support note, vector source |
| Trigger Severity | `CRITICAL` |
| Required Action | Block/redact/quarantine and alert security |
| Allowed Outcome | Redacted storage or rejected source |
| Prohibited Outcome | Secret stored in logs, docs, archive, AI prompt, pgvector |
| Alert Family | `ALERT_SECURITY_SECRET_EXPOSURE_RISK` |
| Log Requirement | Redacted secret detection metadata |
| Evidence Requirement | Redacted evidence only |
| Audit Requirement | Required |
| pgvector Eligibility | Blocked |
| AI Boundary | AI must not receive secret |
| Release Authority | Security review |
| Readiness Blocker | `BLOCKER-SECRET-ISOLATION-0001` |
| Validation Test | Secret-like values blocked from logs/vector/AI |

---

## 15. Control Record: Visibility And Masking

| Field | Value |
|---|---|
| Control ID | `CTRL-VISIBILITY-MASKING` |
| Control Family | `CONTROL_VISIBILITY_MASKING` |
| Security Class | Identity, support authority, AI/vector, archive |
| Bulkhead | Identity, support/admin, AI, pgvector, archive, tenant/store |
| Protected Asset | Restricted customer/staff/provider data |
| Trigger Event | Restricted data requested or displayed |
| Trigger Severity | `HIGH_RISK` |
| Required Action | Apply masking, role visibility, audit where required |
| Allowed Outcome | Masked/authorized view |
| Prohibited Outcome | Raw restricted data exposure |
| Alert Family | `ALERT_SECURITY_RESTRICTED_DATA_ACCESS` |
| Log Requirement | Access metadata, masking class |
| Evidence Requirement | Required for unauthorized access |
| Audit Requirement | Required for unmask/export/restricted access |
| pgvector Eligibility | Redacted summaries only |
| AI Boundary | AI may only receive approved masked summaries |
| Release Authority | Security/privacy/legal review |
| Readiness Blocker | `BLOCKER-VISIBILITY-MASKING-0001` |
| Validation Test | Restricted data cannot be exposed without authority |

---

## 16. Control Record: Support/Admin Authority

| Field | Value |
|---|---|
| Control ID | `CTRL-SUPPORT-AUTHORITY-BOUNDARY` |
| Control Family | `CONTROL_SUPPORT_AUTHORITY` |
| Security Class | `SECURITY_CLASS_SUPPORT_AUTHORITY` |
| Bulkhead | `BULKHEAD_SUPPORT_ADMIN` |
| Protected Asset | Refunds, compensation, unmasking, case closure, overrides, exports |
| Trigger Event | Support/admin action requested |
| Trigger Severity | `HIGH_RISK` if restricted |
| Required Action | Check authority, evidence, audit, review route |
| Allowed Outcome | Authorized action request proceeds through domain contract |
| Prohibited Outcome | Support note mutates ledger/value/identity directly |
| Alert Family | `ALERT_SUPPORT_UNAUTHORIZED_MUTATION` |
| Log Requirement | Action request metadata |
| Evidence Requirement | Required for refund/compensation/case closure |
| Audit Requirement | Required for restricted actions |
| pgvector Eligibility | Approved support summaries only |
| AI Boundary | AI may draft, cannot send/resolve/approve |
| Release Authority | Support lead/security/legal review |
| Readiness Blocker | `BLOCKER-SUPPORT-AUTHORITY-0001` |
| Validation Test | Support cannot mutate authority domains directly |

---

## 17. Control Record: AI Assistance Boundary

| Field | Value |
|---|---|
| Control ID | `CTRL-AI-ASSISTANCE-ONLY` |
| Control Family | `CONTROL_AI_BOUNDARY` |
| Security Class | `SECURITY_CLASS_AI_VECTOR` |
| Bulkhead | `BULKHEAD_AI` |
| Protected Asset | Runtime authority, customer-facing output, evidence truth |
| Trigger Event | AI output used in support/security/financial/integration context |
| Trigger Severity | `HIGH_RISK` or `CRITICAL` if authority overreach |
| Required Action | Mark as draft/derived/advisory and require approval for use |
| Allowed Outcome | AI assists reviewer |
| Prohibited Outcome | AI resolves, mutates, publishes, confirms, releases, approves |
| Alert Family | `ALERT_AI_AUTHORITY_OVERREACH` |
| Log Requirement | AI input/output metadata and source trace |
| Evidence Requirement | AI summary marked derived |
| Audit Requirement | Required when AI influences high-risk review |
| pgvector Eligibility | Approved vector output only |
| AI Boundary | Self-boundary: assistance only |
| Release Authority | AI governance/security/content review |
| Readiness Blocker | `BLOCKER-AI-BOUNDARY-0001` |
| Validation Test | AI output cannot execute final authority |

---

## 18. Control Record: pgvector Similarity Boundary

| Field | Value |
|---|---|
| Control ID | `CTRL-PGVECTOR-SIMILARITY-ONLY` |
| Control Family | `CONTROL_PGVECTOR_BOUNDARY` |
| Security Class | `SECURITY_CLASS_AI_VECTOR` |
| Bulkhead | `BULKHEAD_PGVECTOR` |
| Protected Asset | Source traceability, tenant/store scope, authority boundary |
| Trigger Event | Vector source ingestion or retrieval result used |
| Trigger Severity | `HIGH_RISK` if restricted or cross-scope |
| Required Action | Verify approved source, traceability, scope, lifecycle |
| Allowed Outcome | Similarity assists review |
| Prohibited Outcome | Similarity result treated as proof or authority |
| Alert Family | `ALERT_PGVECTOR_OUTPUT_USED_AS_AUTHORITY` |
| Log Requirement | Source id, vector id, retrieval scope |
| Evidence Requirement | Source trace metadata |
| Audit Requirement | Required for high-risk review usage |
| pgvector Eligibility | Source-approved only |
| AI Boundary | AI may consume only approved vector results |
| Release Authority | AI/security/data governance review |
| Readiness Blocker | `BLOCKER-PGVECTOR-BOUNDARY-0001` |
| Validation Test | Vector result cannot resolve/mutate/publish |

---

## 19. Control Record: Alert Routing And Acknowledgement

| Field | Value |
|---|---|
| Control ID | `CTRL-ALERT-ROUTE-ACK-RESOLUTION` |
| Control Family | `CONTROL_ALERT_ROUTING` |
| Security Class | All alert-generating packages |
| Bulkhead | All domains |
| Protected Asset | Incident accountability and response chain |
| Trigger Event | Alert candidate created |
| Trigger Severity | Any severity |
| Required Action | Assign severity, route, ack owner, resolution owner, escalation |
| Allowed Outcome | Alert enters controlled lifecycle |
| Prohibited Outcome | Alert without owner, ack treated as resolution |
| Alert Family | Domain-specific |
| Log Requirement | Alert lifecycle log |
| Evidence Requirement | Required for high-risk alerts |
| Audit Requirement | Required for high-risk ack/resolution |
| pgvector Eligibility | Alert summary only |
| AI Boundary | May summarize, cannot acknowledge/resolve |
| Release Authority | Domain route owner |
| Readiness Blocker | `BLOCKER-ALERT-ROUTING-0001` |
| Validation Test | High-risk alert has route and ack/resolution separation |

---

## 20. Control Record: Log Integrity

| Field | Value |
|---|---|
| Control ID | `CTRL-LOG-INTEGRITY-APPEND-STRUCTURED` |
| Control Family | `CONTROL_LOG_INTEGRITY` |
| Security Class | External/provider/value/identity/AI/archive/security packages |
| Bulkhead | Audit/evidence, archive, monitoring |
| Protected Asset | Structured monitoring and audit trail |
| Trigger Event | Security-relevant event/log created |
| Trigger Severity | `REVIEW_REQUIRED` |
| Required Action | Structured append-only log with correlation and scope |
| Allowed Outcome | Logs support audit/evidence/review |
| Prohibited Outcome | Unstructured, mutable, secret-containing, unscoped logs |
| Alert Family | `ALERT_MONITORING_SIGNAL_MISSING` or domain alert |
| Log Requirement | Self-defining structured log |
| Evidence Requirement | Required for high-risk logs |
| Audit Requirement | Required for restricted/high-risk actions |
| pgvector Eligibility | Summary-only after approval |
| AI Boundary | AI may read approved summaries only |
| Release Authority | Security/audit review |
| Readiness Blocker | `BLOCKER-LOG-INTEGRITY-0001` |
| Validation Test | High-risk event has structured scoped log |

---

## 21. Control Record: Evidence Linkage

| Field | Value |
|---|---|
| Control ID | `CTRL-EVIDENCE-LINKAGE-REQUIRED` |
| Control Family | `CONTROL_EVIDENCE_LINKAGE` |
| Security Class | Value, identity, provider, support, archive, legal, security |
| Bulkhead | Audit/evidence |
| Protected Asset | Incident proof and review material |
| Trigger Event | High-risk event, containment, quarantine, reconciliation, release |
| Trigger Severity | `HIGH_RISK` or higher |
| Required Action | Link evidence packet or evidence metadata |
| Allowed Outcome | Reviewable decision path |
| Prohibited Outcome | High-risk decision without evidence |
| Alert Family | `ALERT_EVIDENCE_REQUIRED_MISSING` |
| Log Requirement | Evidence reference log |
| Evidence Requirement | Core requirement |
| Audit Requirement | Required for decisions based on evidence |
| pgvector Eligibility | Evidence summary only |
| AI Boundary | AI summary is derived only |
| Release Authority | Domain/audit owner |
| Readiness Blocker | `BLOCKER-EVIDENCE-LINKAGE-0001` |
| Validation Test | High-risk release/resolution has evidence link |

---

## 22. Control Record: Audit Linkage

| Field | Value |
|---|---|
| Control ID | `CTRL-AUDIT-LINKAGE-REQUIRED` |
| Control Family | `CONTROL_AUDIT_LINKAGE` |
| Security Class | Value, identity, support, archive, security, critical |
| Bulkhead | Audit/evidence |
| Protected Asset | Accountability trail |
| Trigger Event | Authority action or restricted review action |
| Trigger Severity | `HIGH_RISK` or higher |
| Required Action | Create audit event with actor/system actor, reason, scope, evidence |
| Allowed Outcome | Auditable action |
| Prohibited Outcome | Authority action without audit |
| Alert Family | `ALERT_AUDIT_REQUIRED_MISSING` |
| Log Requirement | Audit event |
| Evidence Requirement | Required if evidence-based |
| Audit Requirement | Core requirement |
| pgvector Eligibility | Audit summary only |
| AI Boundary | AI cannot create final authority audit by itself |
| Release Authority | Audit/security review |
| Readiness Blocker | `BLOCKER-AUDIT-LINKAGE-0001` |
| Validation Test | Restricted action cannot occur without audit |

---

## 23. Control Record: i18n Message Safety

| Field | Value |
|---|---|
| Control ID | `CTRL-I18N-MESSAGE-SAFETY` |
| Control Family | `CONTROL_I18N_MESSAGE` |
| Security Class | `SECURITY_CLASS_VISIBLE_TEXT` |
| Bulkhead | Content/i18n, projection, support/admin, AI |
| Protected Asset | Customer/staff/support-visible text |
| Trigger Event | Message displayed or projected |
| Trigger Severity | `WARNING` or higher for customer-facing |
| Required Action | Use approved message/content keys and source trace |
| Allowed Outcome | Approved localized message |
| Prohibited Outcome | Hardcoded or AI-generated final visible text |
| Alert Family | `ALERT_I18N_MESSAGE_KEY_MISSING` |
| Log Requirement | Surface/key/source metadata |
| Evidence Requirement | Required for allergen/legal/customer impact text |
| Audit Requirement | Required for publication/rollback high-risk content |
| pgvector Eligibility | Approved content/SOP only |
| AI Boundary | AI may draft, cannot approve final text |
| Release Authority | Content/localization/support review |
| Readiness Blocker | `BLOCKER-I18N-MESSAGE-0001` |
| Validation Test | Visible alert/status has approved key |

---

## 24. Control Record: Customer Recovery Boundary

| Field | Value |
|---|---|
| Control ID | `CTRL-CUSTOMER-RECOVERY-BOUNDARY` |
| Control Family | `CONTROL_CUSTOMER_RECOVERY` |
| Security Class | Value, support authority, visible text, identity |
| Bulkhead | Support/admin, payment, membership, wallet, coupon, identity |
| Protected Asset | Customer trust and controlled recovery |
| Trigger Event | Customer impact confirmed or suspected |
| Trigger Severity | `CUSTOMER_RECOVERY_REQUIRED` |
| Required Action | Route recovery through support/customer recovery workflow |
| Allowed Outcome | Reviewed recovery action candidate |
| Prohibited Outcome | Automatic compensation/refund without authority |
| Alert Family | `ALERT_CUSTOMER_RECOVERY_REQUIRED` |
| Log Requirement | Customer impact metadata |
| Evidence Requirement | Required for compensation/refund/dispute |
| Audit Requirement | Required for recovery decision |
| pgvector Eligibility | Redacted recovery summary only |
| AI Boundary | AI may draft message, cannot compensate/refund |
| Release Authority | Support/finance/legal as applicable |
| Readiness Blocker | `BLOCKER-CUSTOMER-RECOVERY-0001` |
| Validation Test | Recovery action cannot bypass authority |

---

## 25. Control Record: Retention Archive Governance

| Field | Value |
|---|---|
| Control ID | `CTRL-RETENTION-ARCHIVE-GOVERNANCE` |
| Control Family | `CONTROL_RETENTION_ARCHIVE` |
| Security Class | Archive, audit, security, value, identity |
| Bulkhead | Archive/retention |
| Protected Asset | Log lifecycle, archive integrity, legal hold |
| Trigger Event | Log exceeds hot retention or retrieval/delete requested |
| Trigger Severity | `REVIEW_REQUIRED` |
| Required Action | Apply tier, manifest, encryption, legal hold, audit retrieval |
| Allowed Outcome | Verified archive/prune/retrieval/deletion review |
| Prohibited Outcome | Delete without retention/legal review or archive without manifest |
| Alert Family | `ALERT_ARCHIVE_*` |
| Log Requirement | Archive migration/retrieval/deletion log |
| Evidence Requirement | Manifest/checksum/legal hold evidence |
| Audit Requirement | Required for migration/retrieval/deletion/legal hold |
| pgvector Eligibility | Lifecycle-linked summary only |
| AI Boundary | AI may summarize approved archive data, cannot restore/mutate |
| Release Authority | Data governance/security/legal review |
| Readiness Blocker | `BLOCKER-RETENTION-ARCHIVE-0001` |
| Validation Test | Archive has manifest and legal hold blocks deletion |

---

## 26. Control Record: Trigger-View-Agent Boundary

| Field | Value |
|---|---|
| Control ID | `CTRL-TRIGGER-VIEW-AGENT-BOUNDARY` |
| Control Family | `CONTROL_TRIGGER_VIEW_AGENT` |
| Security Class | AI/vector, external input, provider input, security monitoring |
| Bulkhead | Monitoring, AI, pgvector, audit/evidence |
| Protected Asset | Runtime performance and monitoring integrity |
| Trigger Event | Monitoring pipeline designed or executed |
| Trigger Severity | `REVIEW_REQUIRED` |
| Required Action | Keep triggers lightweight, views read-only, daemon bounded |
| Allowed Outcome | Monitoring pipeline supports review |
| Prohibited Outcome | Trigger calls AI/provider/pgvector or daemon scans raw sensitive hot tables |
| Alert Family | `ALERT_MONITORING_VIEW_STALE`, `ALERT_DAEMON_VIEW_ACCESS_FAILED` |
| Log Requirement | Monitoring signal metadata |
| Evidence Requirement | Required for high-risk monitoring incident |
| Audit Requirement | Required for containment/daemon action |
| pgvector Eligibility | Approved monitoring summaries only |
| AI Boundary | AI reads approved summaries only |
| Release Authority | Platform/security/architecture review |
| Readiness Blocker | `BLOCKER-TVA-0001` |
| Validation Test | Trigger/view/daemon boundaries are preserved |

---

## 27. Control Record: Runtime Entry Gate

| Field | Value |
|---|---|
| Control ID | `CTRL-RUNTIME-ENTRY-GATE` |
| Control Family | `CONTROL_RUNTIME_ENTRY_GATE` |
| Security Class | All implementation packages |
| Bulkhead | All applicable |
| Protected Asset | Project control and safety |
| Trigger Event | Package requests coding entry |
| Trigger Severity | `REVIEW_REQUIRED` |
| Required Action | Verify catalogs, blockers, tests, handoff, work order, review approval |
| Allowed Outcome | Narrow coding entry if approved |
| Prohibited Outcome | Runtime coding from planning docs alone |
| Alert Family | `ALERT_RUNTIME_ENTRY_BLOCKED` |
| Log Requirement | Entry decision record |
| Evidence Requirement | Handoff/work order references |
| Audit Requirement | Required for coding entry approval |
| pgvector Eligibility | Not applicable |
| AI Boundary | AI may summarize readiness, cannot approve coding |
| Release Authority | Architecture/project owner |
| Readiness Blocker | `BLOCKER-RUNTIME-ENTRY-0001` |
| Validation Test | Open blockers prevent coding-ready status |

---

## 28. Control-To-Blocker Map

| Control Family | Primary Blocker |
|---|---|
| `CONTROL_BULKHEAD` | `BLOCKER-BULKHEAD-CATALOG-0001` |
| `CONTROL_CONTAINMENT` | `BLOCKER-CONTAINMENT-CATALOG-0001` |
| `CONTROL_QUARANTINE` | `BLOCKER-QUARANTINE-CATALOG-0001` |
| `CONTROL_TOKENIZATION` | `BLOCKER-TOKEN-SCOPE-0001` |
| `CONTROL_SECRET_ISOLATION` | `BLOCKER-SECRET-ISOLATION-0001` |
| `CONTROL_PROVIDER_VERIFICATION` | `BLOCKER-PROVIDER-VERIFICATION-0001` |
| `CONTROL_IDEMPOTENCY` | `BLOCKER-IDEMPOTENCY-VALUE-0001` |
| `CONTROL_RECONCILIATION` | `BLOCKER-RECONCILIATION-0001` |
| `CONTROL_APPEND_ONLY` | `BLOCKER-LEDGER-APPEND-ONLY-0001` |
| `CONTROL_VISIBILITY_MASKING` | `BLOCKER-VISIBILITY-MASKING-0001` |
| `CONTROL_SUPPORT_AUTHORITY` | `BLOCKER-SUPPORT-AUTHORITY-0001` |
| `CONTROL_AI_BOUNDARY` | `BLOCKER-AI-BOUNDARY-0001` |
| `CONTROL_PGVECTOR_BOUNDARY` | `BLOCKER-PGVECTOR-BOUNDARY-0001` |
| `CONTROL_ALERT_ROUTING` | `BLOCKER-ALERT-ROUTING-0001` |
| `CONTROL_LOG_INTEGRITY` | `BLOCKER-LOG-INTEGRITY-0001` |
| `CONTROL_EVIDENCE_LINKAGE` | `BLOCKER-EVIDENCE-LINKAGE-0001` |
| `CONTROL_AUDIT_LINKAGE` | `BLOCKER-AUDIT-LINKAGE-0001` |
| `CONTROL_I18N_MESSAGE` | `BLOCKER-I18N-MESSAGE-0001` |
| `CONTROL_CUSTOMER_RECOVERY` | `BLOCKER-CUSTOMER-RECOVERY-0001` |
| `CONTROL_RETENTION_ARCHIVE` | `BLOCKER-RETENTION-ARCHIVE-0001` |
| `CONTROL_TRIGGER_VIEW_AGENT` | `BLOCKER-TVA-0001` |
| `CONTROL_RUNTIME_ENTRY_GATE` | `BLOCKER-RUNTIME-ENTRY-0001` |

---

## 29. Control-To-Test Map

| Control Family | Required Test/Check |
|---|---|
| `CONTROL_BULKHEAD` | Package has bulkhead and SOT |
| `CONTROL_CONTAINMENT` | Containment blocks propagation but not resolution |
| `CONTROL_QUARANTINE` | Quarantined input cannot mutate truth |
| `CONTROL_TOKENIZATION` | Token scope violation blocks use |
| `CONTROL_SECRET_ISOLATION` | Secrets blocked from logs/AI/vector/archive |
| `CONTROL_PROVIDER_VERIFICATION` | Unverified callback cannot mutate state |
| `CONTROL_IDEMPOTENCY` | Duplicate value event cannot create duplicate effect |
| `CONTROL_RECONCILIATION` | Mismatch opens reconciliation path |
| `CONTROL_APPEND_ONLY` | Ledger correction is append-only |
| `CONTROL_VISIBILITY_MASKING` | Restricted data masked unless authorized |
| `CONTROL_SUPPORT_AUTHORITY` | Support cannot mutate authority domains directly |
| `CONTROL_AI_BOUNDARY` | AI cannot resolve/mutate/publish/approve |
| `CONTROL_PGVECTOR_BOUNDARY` | Similarity cannot become truth |
| `CONTROL_ALERT_ROUTING` | High-risk alert has route, ack, resolution owner |
| `CONTROL_LOG_INTEGRITY` | High-risk event has structured scoped log |
| `CONTROL_EVIDENCE_LINKAGE` | High-risk release has evidence |
| `CONTROL_AUDIT_LINKAGE` | Authority action has audit |
| `CONTROL_I18N_MESSAGE` | Visible text uses approved key |
| `CONTROL_CUSTOMER_RECOVERY` | Recovery cannot bypass authority |
| `CONTROL_RETENTION_ARCHIVE` | Archive has manifest and legal hold protection |
| `CONTROL_TRIGGER_VIEW_AGENT` | Trigger/view/daemon boundaries preserved |
| `CONTROL_RUNTIME_ENTRY_GATE` | Open blockers prevent coding entry |

---

## 30. Security Control Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-SECURITY-CONTROL-CATALOG-0001` | Security control catalog not reviewed |
| `BLOCKER-SECURITY-CLASS-0001` | Security class catalog missing |
| `BLOCKER-CONTROL-SCHEMA-0001` | Control record schema incomplete |
| `BLOCKER-CONTROL-TEST-MAP-0001` | Control-to-test map missing |
| `BLOCKER-CONTROL-BLOCKER-MAP-0001` | Control-to-blocker map missing |
| `BLOCKER-CONTROL-AI-PGVECTOR-0001` | AI/pgvector boundaries missing |
| `BLOCKER-CONTROL-PROVIDER-0001` | Provider evidence-required control missing |
| `BLOCKER-CONTROL-VALUE-0001` | Value-bearing control missing |
| `BLOCKER-CONTROL-IDENTITY-0001` | Identity/privacy control missing |
| `BLOCKER-CONTROL-ARCHIVE-0001` | Archive/retention control missing |

Open control blockers prevent runtime implementation.

---

## 31. Validation Checklist

Validation must confirm:

- every control has a stable control id
- every control has a control family
- every control maps to security class
- every control maps to bulkhead
- every control has protected asset
- every control has trigger event
- every control has required action
- every control has allowed and prohibited outcomes
- every high-risk control has alert mapping
- every value/identity/security control has audit/evidence mapping
- every AI-related control blocks final authority
- every pgvector-related control blocks final authority
- every provider control preserves evidence-required default
- every visible-text control requires i18n/message key
- every archive control requires manifest and legal hold handling
- every runtime entry control blocks coding if blockers remain open
- every control maps to blocker and test/check

---

## 32. Relationship To Previous Documents

This document implements Artifact Group C from:

- `21630 Financial-Grade Security Monitoring Foundation Catalog Execution Plan And Artifact Map`

It follows:

- `21631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `21632 Containment Status And Trigger Map Catalog`
- `21633 Quarantine Status And Trigger Map Catalog`

It depends on:

- `21570 Financial-Grade Security Foundation Control Catalog And Bulkhead Readiness Policy`
- `21580 AI Daemon Security Monitoring Agent And Autonomous Containment Policy`
- `21590 Trigger View Agent Monitoring Pipeline And Audit Projection Policy`
- `21620 Financial-Grade Security Monitoring Catalog Work Order And Implementation Handoff Policy`

This document is Foundation-grade and catalog-only.

It does not authorize coding.

---

## 33. Final Rule

Security controls are the enforceable vocabulary of the Foundation security monitoring package.

Every runtime package must declare its security class and map to required controls before coding entry.

A control must define its protected asset, trigger, required action, allowed outcome, prohibited outcome, alert/log/evidence/audit linkage, AI/pgvector boundary, release authority, blocker, and validation test.

AI is assistance only.

pgvector is similarity only.

Providers are evidence-required by default.

External input is quarantined by default.

Value-bearing operations require idempotency, reconciliation, evidence, and audit.

Ledger truth is append-only.

Runtime coding remains deferred until this control catalog is reviewed, validated, and attached to package-specific entry gates.
