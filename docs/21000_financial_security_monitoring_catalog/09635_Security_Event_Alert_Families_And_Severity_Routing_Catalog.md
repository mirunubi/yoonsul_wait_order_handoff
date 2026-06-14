# 09635 Security Event Alert Families And Severity Routing Catalog

## 1. Purpose

This document defines the Security Event and Alert Families catalog for the Financial-Grade Security Monitoring Foundation Package.

The previous artifact `09634` defined security control records and security classes.

This document defines the controlled event families and alert families that those controls must emit, route, audit, and review.

A security control without event and alert mapping cannot be monitored.

A containment or quarantine rule without event and alert mapping cannot be trusted.

This document is catalog-only.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This catalog applies to event and alert families for:

1. Security bulkheads
2. Containment
3. Quarantine
4. Provider verification
5. Payment and ledger security
6. Membership, coupon, wallet, and identity security
7. POS contamination
8. KDS mismatch
9. Inventory and projection mismatch
10. Content/i18n safety
11. Support/admin authority
12. AI boundary
13. pgvector boundary
14. Archive/retention governance
15. Tenant/store isolation
16. Trigger-View-Agent monitoring
17. Runtime entry blockers

This catalog does not implement event tables, alert queues, notification workers, dashboards, triggers, views, daemons, or runtime handlers.

---

## 3. Core Principle

Every abnormal condition must become a controlled event before it becomes a controlled alert.

An event records what happened.

An alert records what must be reviewed, routed, acknowledged, escalated, contained, quarantined, reconciled, or resolved.

The system must not rely on free-text logs or ad hoc warnings.

Every event and alert must be:

- named
- scoped
- severity-mapped
- routed
- evidence-aware
- audit-aware
- i18n-ready if visible
- pgvector-safe if vectorized
- AI-bounded if summarized
- blocker-linked if missing

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09635` |
| Package ID | `foundation.security_monitoring.financial_grade.v1` |
| Artifact Type | `CATALOG` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATALOG_ONLY` |
| Owner | `Architecture / Security Foundation` |
| Dependencies | `09631`, `09632`, `09633`, `09634`, `09630`, `09620`, `09610`, `09570`, `09560` |
| Provider Evidence Status | `APPLIES_IF_PROVIDER_RELATED` |
| i18n Requirement | `REQUIRED_FOR_VISIBLE_ALERTS` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_ALERTS_AND_AUTHORITY_EVENTS` |
| Security Requirement | `FINANCIAL_GRADE_EVENT_ALERT_CATALOG_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_AUDIT_REVIEW_REQUIRED` |
| Blocker Status | `EVENT_ALERT_CATALOG_REVIEW_REQUIRED` |

---

## 5. Event Family Record Schema

Each event family must include:

| Field | Required Meaning |
|---|---|
| Event Family ID | Stable event family |
| Domain | Security, POS, provider, payment, etc. |
| Bulkhead | Affected bulkhead |
| Source Class | Human, system, provider, daemon, AI, pgvector, archive |
| Trigger Condition | What creates the event |
| Default Severity | Default severity |
| Alert Candidate | Whether it may create alert |
| Evidence Requirement | None, optional, required |
| Audit Requirement | None, conditional, required |
| pgvector Eligibility | Allowed, summary-only, blocked |
| AI Summary Eligibility | Allowed, internal only, blocked |
| Retention Class | Hot/warm/cold/legal |
| i18n Requirement | Required if visible |
| Blocker If Missing | Readiness blocker |

---

## 6. Alert Family Record Schema

Each alert family must include:

| Field | Required Meaning |
|---|---|
| Alert Family ID | Stable alert family |
| Related Event Family | Event that triggers alert |
| Domain | Security, POS, provider, etc. |
| Bulkhead | Affected bulkhead |
| Default Severity | Controlled severity |
| Primary Route | First review route |
| Secondary Route | Escalation route |
| Customer Visibility | Internal only, support-mediated, customer-visible |
| Acknowledgement Rule | Ack owner and requirement |
| Resolution Rule | Resolution owner and requirement |
| Escalation Rule | Time/severity trigger |
| Evidence Requirement | Evidence packet rule |
| Audit Requirement | Audit event rule |
| Containment Candidate | Yes/no |
| Quarantine Candidate | Yes/no |
| Reconciliation Candidate | Yes/no |
| i18n Key Family | Required key family |
| pgvector Eligibility | Summary-only or blocked |
| AI Boundary | Allowed summary only |
| Blocker If Missing | Readiness blocker |

---

## 7. Severity Catalog

| Severity | Meaning |
|---|---|
| `INFO` | Informational, no action needed |
| `NOTICE` | Low-risk abnormal condition |
| `WARNING` | Operational or integration risk |
| `HIGH_RISK` | Value, identity, provider, support, or security risk |
| `CRITICAL` | Security, financial, privacy, legal, tenant, or authority-critical risk |
| `REVIEW_REQUIRED` | Human/domain review required |
| `RECONCILIATION_REQUIRED` | Cross-system mismatch requires reconciliation |
| `PROVIDER_REVIEW_REQUIRED` | Provider evidence or contract review required |
| `CUSTOMER_RECOVERY_REQUIRED` | Customer impact suspected or confirmed |
| `LEGAL_COMPLIANCE_REVIEW_REQUIRED` | Legal/compliance review required |
| `SECURITY_REVIEW_REQUIRED` | Security review required |

Severity must not be free text.

---

## 8. Route Catalog

| Route | Meaning |
|---|---|
| `ROUTE_SECURITY` | Security review |
| `ROUTE_PLATFORM` | Platform/database/runtime review |
| `ROUTE_PROVIDER_OPS` | Provider integration review |
| `ROUTE_FINANCE` | Finance/payment/settlement review |
| `ROUTE_RECONCILIATION` | Reconciliation review |
| `ROUTE_SUPPORT` | Customer support review |
| `ROUTE_SUPPORT_LEAD` | Support lead review |
| `ROUTE_PRIVACY` | Customer identity/privacy review |
| `ROUTE_LEGAL_COMPLIANCE` | Legal/compliance review |
| `ROUTE_STORE_OPS` | Store operations review |
| `ROUTE_CONTENT` | Content registry review |
| `ROUTE_LOCALIZATION` | i18n/localization review |
| `ROUTE_AI_GOVERNANCE` | AI governance review |
| `ROUTE_DATA_GOVERNANCE` | Archive/retention/data lifecycle review |
| `ROUTE_HR` | Workforce/HR review |
| `ROUTE_SCM_WMS` | Supplier/SCM/WMS review |
| `ROUTE_FRANCHISE_OPS` | Franchise/HQ operations review |
| `ROUTE_HQ_ADMIN` | HQ administrative review |

---

## 9. Security Bulkhead Event Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `SECURITY_BULKHEAD_DECLARED` | Bulkhead declared for package/domain | `INFO` |
| `SECURITY_BULKHEAD_MISSING` | Runtime package lacks bulkhead | `REVIEW_REQUIRED` |
| `SECURITY_BULKHEAD_CONTAINMENT_CANDIDATE` | Bulkhead may require containment | `HIGH_RISK` |
| `SECURITY_BULKHEAD_CONTAINMENT_ACTIVATED` | Containment active | `HIGH_RISK` |
| `SECURITY_BULKHEAD_RELEASE_REQUESTED` | Containment release requested | `REVIEW_REQUIRED` |
| `SECURITY_BULKHEAD_RELEASED` | Containment released through authority | `INFO` |
| `SECURITY_CROSS_BULKHEAD_INFECTION_RISK` | Bad state may cross bulkhead | `CRITICAL` |
| `SECURITY_SOURCE_OF_TRUTH_CONFLICT` | Conflicting authority/source-of-truth | `HIGH_RISK` |
| `SECURITY_TRUST_BOUNDARY_VIOLATED` | Trust boundary violated | `CRITICAL` |

---

## 10. Security Bulkhead Alert Families

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_SECURITY_BULKHEAD_MISSING` | `SECURITY_BULKHEAD_MISSING` | `REVIEW_REQUIRED` | `ROUTE_SECURITY` |
| `ALERT_SECURITY_BULKHEAD_CONTAINMENT_ACTIVE` | `SECURITY_BULKHEAD_CONTAINMENT_ACTIVATED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_SECURITY_CROSS_BULKHEAD_INFECTION_RISK` | `SECURITY_CROSS_BULKHEAD_INFECTION_RISK` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_SECURITY_SOURCE_OF_TRUTH_CONFLICT` | `SECURITY_SOURCE_OF_TRUTH_CONFLICT` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_SECURITY_TRUST_BOUNDARY_VIOLATED` | `SECURITY_TRUST_BOUNDARY_VIOLATED` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_SECURITY_CONTAINMENT_RELEASE_REVIEW` | `SECURITY_BULKHEAD_RELEASE_REQUESTED` | `REVIEW_REQUIRED` | `ROUTE_SECURITY` |

---

## 11. Containment Event Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `CONTAINMENT_CANDIDATE_CREATED` | Containment candidate created | `HIGH_RISK` |
| `CONTAINMENT_ACTIVATED` | Containment activated | `HIGH_RISK` |
| `CONTAINMENT_MUTATION_BLOCKED` | Mutation blocked | `HIGH_RISK` |
| `CONTAINMENT_EXTERNAL_INPUT_BLOCKED` | External input blocked | `HIGH_RISK` |
| `CONTAINMENT_TOKEN_INVALIDATED` | Scoped token invalidated | `CRITICAL` |
| `CONTAINMENT_LEDGER_FINALIZATION_HELD` | Ledger finalization held | `HIGH_RISK` |
| `CONTAINMENT_PROJECTION_BLOCKED` | External projection blocked | `HIGH_RISK` |
| `CONTAINMENT_AI_OUTPUT_BLOCKED` | AI output blocked | `HIGH_RISK` |
| `CONTAINMENT_PGVECTOR_RETRIEVAL_BLOCKED` | Vector retrieval/source blocked | `HIGH_RISK` |
| `CONTAINMENT_RELEASE_REQUESTED` | Release requested | `REVIEW_REQUIRED` |
| `CONTAINMENT_RELEASED` | Released after review | `INFO` |
| `CONTAINMENT_FALSE_POSITIVE_REVIEW_OPENED` | False-positive review opened | `REVIEW_REQUIRED` |
| `CONTAINMENT_REOPENED` | Containment reopened | `HIGH_RISK` |

---

## 12. Containment Alert Families

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_CONTAINMENT_ACTIVE` | `CONTAINMENT_ACTIVATED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_CONTAINMENT_MUTATION_BLOCKED` | `CONTAINMENT_MUTATION_BLOCKED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_CONTAINMENT_TOKEN_INVALIDATED` | `CONTAINMENT_TOKEN_INVALIDATED` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_CONTAINMENT_LEDGER_HELD` | `CONTAINMENT_LEDGER_FINALIZATION_HELD` | `HIGH_RISK` | `ROUTE_FINANCE` |
| `ALERT_CONTAINMENT_PROJECTION_BLOCKED` | `CONTAINMENT_PROJECTION_BLOCKED` | `HIGH_RISK` | `ROUTE_CONTENT` |
| `ALERT_CONTAINMENT_AI_OUTPUT_BLOCKED` | `CONTAINMENT_AI_OUTPUT_BLOCKED` | `HIGH_RISK` | `ROUTE_AI_GOVERNANCE` |
| `ALERT_CONTAINMENT_PGVECTOR_BLOCKED` | `CONTAINMENT_PGVECTOR_RETRIEVAL_BLOCKED` | `HIGH_RISK` | `ROUTE_AI_GOVERNANCE` |
| `ALERT_CONTAINMENT_RELEASE_REVIEW_REQUIRED` | `CONTAINMENT_RELEASE_REQUESTED` | `REVIEW_REQUIRED` | `ROUTE_SECURITY` |
| `ALERT_CONTAINMENT_REOPENED` | `CONTAINMENT_REOPENED` | `HIGH_RISK` | `ROUTE_SECURITY` |

---

## 13. Quarantine Event Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `QUARANTINE_CANDIDATE_CREATED` | Quarantine candidate created | `WARNING` |
| `QUARANTINE_ACTIVATED` | Object/input quarantined | `HIGH_RISK` |
| `QUARANTINE_METADATA_CAPTURED` | Quarantine metadata captured | `INFO` |
| `QUARANTINE_EVIDENCE_REQUIRED` | Evidence required for decision | `REVIEW_REQUIRED` |
| `QUARANTINE_RELEASE_REQUESTED` | Release requested | `REVIEW_REQUIRED` |
| `QUARANTINE_RELEASED` | Released after review | `INFO` |
| `QUARANTINE_REJECTED` | Rejected after review | `INFO` |
| `QUARANTINE_ESCALATED` | Escalated due to delay/risk | `HIGH_RISK` |
| `QUARANTINE_REPLAY_REQUIRED` | Replay required after release | `RECONCILIATION_REQUIRED` |
| `QUARANTINE_REOPENED` | Quarantine reopened | `HIGH_RISK` |

---

## 14. Quarantine Alert Families

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_QUARANTINE_ACTIVE` | `QUARANTINE_ACTIVATED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_QUARANTINE_EVIDENCE_REQUIRED` | `QUARANTINE_EVIDENCE_REQUIRED` | `REVIEW_REQUIRED` | `ROUTE_SUPPORT` |
| `ALERT_QUARANTINE_RELEASE_REVIEW_REQUIRED` | `QUARANTINE_RELEASE_REQUESTED` | `REVIEW_REQUIRED` | `ROUTE_SECURITY` |
| `ALERT_QUARANTINE_REJECTED` | `QUARANTINE_REJECTED` | `NOTICE` | `ROUTE_SUPPORT` |
| `ALERT_QUARANTINE_ESCALATED` | `QUARANTINE_ESCALATED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_QUARANTINE_REPLAY_REQUIRED` | `QUARANTINE_REPLAY_REQUIRED` | `RECONCILIATION_REQUIRED` | `ROUTE_RECONCILIATION` |
| `ALERT_QUARANTINE_REOPENED` | `QUARANTINE_REOPENED` | `HIGH_RISK` | `ROUTE_SECURITY` |

---

## 15. POS Event And Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `POS_EVENT_MALFORMED` | POS event malformed | `WARNING` |
| `POS_EVENT_UNMAPPED` | POS event cannot map to context | `WARNING` |
| `POS_EVENT_CROSS_STORE_RISK` | POS event crosses store boundary | `HIGH_RISK` |
| `POS_EVENT_CROSS_TENANT_RISK` | POS event crosses tenant boundary | `CRITICAL` |
| `POS_EVENT_TOKEN_SCOPE_VIOLATION` | POS token scope violation | `CRITICAL` |
| `POS_EVENT_REPLAY_DETECTED` | POS replay detected | `HIGH_RISK` |
| `POS_EVENT_LOCAL_CACHE_AUTHORITY_RISK` | POS local cache treated as truth | `HIGH_RISK` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_POS_MALFORMED_EVENT` | `POS_EVENT_MALFORMED` | `WARNING` | `ROUTE_PLATFORM` |
| `ALERT_POS_UNMAPPED_EVENT` | `POS_EVENT_UNMAPPED` | `WARNING` | `ROUTE_PLATFORM` |
| `ALERT_POS_CROSS_STORE_EVENT_RISK` | `POS_EVENT_CROSS_STORE_RISK` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_POS_CROSS_TENANT_EVENT_RISK` | `POS_EVENT_CROSS_TENANT_RISK` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_POS_TOKEN_SCOPE_VIOLATION` | `POS_EVENT_TOKEN_SCOPE_VIOLATION` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_POS_REPLAY_DETECTED` | `POS_EVENT_REPLAY_DETECTED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_POS_LOCAL_CACHE_AUTHORITY_RISK` | `POS_EVENT_LOCAL_CACHE_AUTHORITY_RISK` | `HIGH_RISK` | `ROUTE_PLATFORM` |

---

## 16. Provider Event And Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `PROVIDER_CALLBACK_RECEIVED` | Provider callback received | `INFO` |
| `PROVIDER_CALLBACK_SIGNATURE_FAILED` | Signature failed | `CRITICAL` |
| `PROVIDER_CALLBACK_REPLAY_DETECTED` | Replay detected | `CRITICAL` |
| `PROVIDER_CALLBACK_UNMAPPED` | Callback cannot map internally | `HIGH_RISK` |
| `PROVIDER_CALLBACK_DUPLICATE_PAYLOAD_MISMATCH` | Duplicate callback payload mismatch | `HIGH_RISK` |
| `PROVIDER_CAPABILITY_EVIDENCE_MISSING` | Capability lacks evidence | `PROVIDER_REVIEW_REQUIRED` |
| `PROVIDER_CONTRACT_DRIFT_DETECTED` | API behavior changed | `HIGH_RISK` |
| `PROVIDER_SETTLEMENT_REPORT_MISSING` | Provider report missing | `RECONCILIATION_REQUIRED` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_PROVIDER_CALLBACK_SIGNATURE_FAILED` | `PROVIDER_CALLBACK_SIGNATURE_FAILED` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_PROVIDER_CALLBACK_REPLAY_DETECTED` | `PROVIDER_CALLBACK_REPLAY_DETECTED` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_PROVIDER_CALLBACK_UNMAPPED` | `PROVIDER_CALLBACK_UNMAPPED` | `HIGH_RISK` | `ROUTE_PROVIDER_OPS` |
| `ALERT_PROVIDER_CALLBACK_DUPLICATE_PAYLOAD_MISMATCH` | `PROVIDER_CALLBACK_DUPLICATE_PAYLOAD_MISMATCH` | `HIGH_RISK` | `ROUTE_PROVIDER_OPS` |
| `ALERT_PROVIDER_CAPABILITY_EVIDENCE_MISSING` | `PROVIDER_CAPABILITY_EVIDENCE_MISSING` | `PROVIDER_REVIEW_REQUIRED` | `ROUTE_PROVIDER_OPS` |
| `ALERT_PROVIDER_CONTRACT_DRIFT_DETECTED` | `PROVIDER_CONTRACT_DRIFT_DETECTED` | `HIGH_RISK` | `ROUTE_PROVIDER_OPS` |
| `ALERT_PROVIDER_SETTLEMENT_REPORT_MISSING` | `PROVIDER_SETTLEMENT_REPORT_MISSING` | `RECONCILIATION_REQUIRED` | `ROUTE_FINANCE` |

---

## 17. Payment Ledger Event And Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `PAYMENT_STATE_UNCERTAIN` | Payment state uncertain | `HIGH_RISK` |
| `PAYMENT_DUPLICATE_CAPTURE_RISK` | Duplicate capture risk | `CRITICAL` |
| `PAYMENT_AMOUNT_MISMATCH` | Amount mismatch | `RECONCILIATION_REQUIRED` |
| `PAYMENT_REFUND_WITHOUT_APPROVAL` | Refund lacks approval | `CRITICAL` |
| `LEDGER_IMBALANCE_DETECTED` | Ledger imbalance | `CRITICAL` |
| `LEDGER_MUTATION_ATTEMPT` | Ledger mutation/delete attempt | `CRITICAL` |
| `SETTLEMENT_MISMATCH_DETECTED` | Settlement mismatch | `RECONCILIATION_REQUIRED` |
| `SETTLEMENT_FX_EVIDENCE_MISSING` | FX evidence missing | `RECONCILIATION_REQUIRED` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_PAYMENT_STATE_UNCERTAIN` | `PAYMENT_STATE_UNCERTAIN` | `HIGH_RISK` | `ROUTE_FINANCE` |
| `ALERT_PAYMENT_DUPLICATE_CAPTURE_RISK` | `PAYMENT_DUPLICATE_CAPTURE_RISK` | `CRITICAL` | `ROUTE_FINANCE` |
| `ALERT_PAYMENT_AMOUNT_MISMATCH` | `PAYMENT_AMOUNT_MISMATCH` | `RECONCILIATION_REQUIRED` | `ROUTE_RECONCILIATION` |
| `ALERT_PAYMENT_REFUND_WITHOUT_APPROVAL` | `PAYMENT_REFUND_WITHOUT_APPROVAL` | `CRITICAL` | `ROUTE_FINANCE` |
| `ALERT_LEDGER_IMBALANCE_DETECTED` | `LEDGER_IMBALANCE_DETECTED` | `CRITICAL` | `ROUTE_FINANCE` |
| `ALERT_LEDGER_MUTATION_ATTEMPT` | `LEDGER_MUTATION_ATTEMPT` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_SETTLEMENT_MISMATCH_DETECTED` | `SETTLEMENT_MISMATCH_DETECTED` | `RECONCILIATION_REQUIRED` | `ROUTE_RECONCILIATION` |
| `ALERT_SETTLEMENT_FX_EVIDENCE_MISSING` | `SETTLEMENT_FX_EVIDENCE_MISSING` | `RECONCILIATION_REQUIRED` | `ROUTE_FINANCE` |

---

## 18. Membership Coupon Wallet Identity Event And Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `MEMBERSHIP_IDENTITY_CONFLICT` | Membership identity conflict | `HIGH_RISK` |
| `MEMBERSHIP_POINT_MISMATCH` | Point mismatch | `RECONCILIATION_REQUIRED` |
| `MEMBERSHIP_BENEFIT_CONFLICT` | Benefit rule conflict | `WARNING` |
| `COUPON_DUPLICATE_USE_RISK` | Duplicate coupon use risk | `HIGH_RISK` |
| `COUPON_RULE_MISMATCH` | Coupon rule mismatch | `WARNING` |
| `WALLET_DUPLICATE_CHARGE_RISK` | Duplicate wallet charge risk | `CRITICAL` |
| `WALLET_BALANCE_MISMATCH` | Wallet balance mismatch | `RECONCILIATION_REQUIRED` |
| `IDENTITY_WRONG_ACCOUNT_RISK` | Wrong account link risk | `CRITICAL` |
| `IDENTITY_CONSENT_MISSING` | Consent missing | `LEGAL_COMPLIANCE_REVIEW_REQUIRED` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_MEMBERSHIP_IDENTITY_CONFLICT` | `MEMBERSHIP_IDENTITY_CONFLICT` | `HIGH_RISK` | `ROUTE_PRIVACY` |
| `ALERT_MEMBERSHIP_POINT_MISMATCH` | `MEMBERSHIP_POINT_MISMATCH` | `RECONCILIATION_REQUIRED` | `ROUTE_SUPPORT` |
| `ALERT_MEMBERSHIP_BENEFIT_CONFLICT` | `MEMBERSHIP_BENEFIT_CONFLICT` | `WARNING` | `ROUTE_SUPPORT` |
| `ALERT_COUPON_DUPLICATE_USE_RISK` | `COUPON_DUPLICATE_USE_RISK` | `HIGH_RISK` | `ROUTE_SUPPORT` |
| `ALERT_COUPON_RULE_MISMATCH` | `COUPON_RULE_MISMATCH` | `WARNING` | `ROUTE_SUPPORT` |
| `ALERT_WALLET_DUPLICATE_CHARGE_RISK` | `WALLET_DUPLICATE_CHARGE_RISK` | `CRITICAL` | `ROUTE_FINANCE` |
| `ALERT_WALLET_BALANCE_MISMATCH` | `WALLET_BALANCE_MISMATCH` | `RECONCILIATION_REQUIRED` | `ROUTE_FINANCE` |
| `ALERT_IDENTITY_WRONG_ACCOUNT_RISK` | `IDENTITY_WRONG_ACCOUNT_RISK` | `CRITICAL` | `ROUTE_PRIVACY` |
| `ALERT_IDENTITY_CONSENT_MISSING` | `IDENTITY_CONSENT_MISSING` | `LEGAL_COMPLIANCE_REVIEW_REQUIRED` | `ROUTE_LEGAL_COMPLIANCE` |

---

## 19. KDS Inventory Projection Content i18n Event And Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `KDS_DUPLICATE_TICKET_RISK` | Duplicate KDS ticket risk | `HIGH_RISK` |
| `KDS_ORDER_PAYMENT_MISMATCH` | KDS/order/payment mismatch | `HIGH_RISK` |
| `INVENTORY_AVAILABILITY_MISMATCH` | Availability mismatch | `WARNING` |
| `INVENTORY_SUPPLIER_QUALITY_RISK` | Supplier/QC risk | `HIGH_RISK` |
| `PROJECTION_PRICE_MISMATCH` | Projected price mismatch | `HIGH_RISK` |
| `PROJECTION_ALLERGEN_MISMATCH` | Allergen mismatch | `CRITICAL` |
| `PROJECTION_PAYMENT_CAPABILITY_UNVERIFIED` | Payment capability unverified | `PROVIDER_REVIEW_REQUIRED` |
| `CONTENT_SOURCE_TRACE_MISSING` | Content source missing | `WARNING` |
| `I18N_MESSAGE_KEY_MISSING` | Message key missing | `WARNING` |
| `I18N_CUSTOMER_VISIBLE_UNTRANSLATED` | Customer-visible untranslated text | `HIGH_RISK` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_KDS_DUPLICATE_TICKET_RISK` | `KDS_DUPLICATE_TICKET_RISK` | `HIGH_RISK` | `ROUTE_STORE_OPS` |
| `ALERT_KDS_ORDER_PAYMENT_MISMATCH` | `KDS_ORDER_PAYMENT_MISMATCH` | `HIGH_RISK` | `ROUTE_SUPPORT` |
| `ALERT_INVENTORY_AVAILABILITY_MISMATCH` | `INVENTORY_AVAILABILITY_MISMATCH` | `WARNING` | `ROUTE_STORE_OPS` |
| `ALERT_INVENTORY_SUPPLIER_QUALITY_RISK` | `INVENTORY_SUPPLIER_QUALITY_RISK` | `HIGH_RISK` | `ROUTE_SCM_WMS` |
| `ALERT_PROJECTION_PRICE_MISMATCH` | `PROJECTION_PRICE_MISMATCH` | `HIGH_RISK` | `ROUTE_CONTENT` |
| `ALERT_PROJECTION_ALLERGEN_MISMATCH` | `PROJECTION_ALLERGEN_MISMATCH` | `CRITICAL` | `ROUTE_LEGAL_COMPLIANCE` |
| `ALERT_PROJECTION_PAYMENT_CAPABILITY_UNVERIFIED` | `PROJECTION_PAYMENT_CAPABILITY_UNVERIFIED` | `PROVIDER_REVIEW_REQUIRED` | `ROUTE_PROVIDER_OPS` |
| `ALERT_CONTENT_SOURCE_TRACE_MISSING` | `CONTENT_SOURCE_TRACE_MISSING` | `WARNING` | `ROUTE_CONTENT` |
| `ALERT_I18N_MESSAGE_KEY_MISSING` | `I18N_MESSAGE_KEY_MISSING` | `WARNING` | `ROUTE_LOCALIZATION` |
| `ALERT_I18N_CUSTOMER_VISIBLE_UNTRANSLATED` | `I18N_CUSTOMER_VISIBLE_UNTRANSLATED` | `HIGH_RISK` | `ROUTE_LOCALIZATION` |

---

## 20. Support Admin Event And Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `SUPPORT_UNAUTHORIZED_MUTATION_ATTEMPT` | Unauthorized support mutation attempt | `CRITICAL` |
| `SUPPORT_REFUND_EVIDENCE_MISSING` | Refund lacks evidence | `HIGH_RISK` |
| `SUPPORT_UNMASKING_AUTHORITY_MISSING` | Unmasking lacks authority | `CRITICAL` |
| `SUPPORT_EXPORT_RESTRICTED_REQUEST` | Restricted export request | `CRITICAL` |
| `SUPPORT_AI_DRAFT_UNAPPROVED_USE` | AI draft used without approval | `HIGH_RISK` |
| `SUPPORT_CASE_CLOSE_EVIDENCE_MISSING` | Case closure lacks evidence | `REVIEW_REQUIRED` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_SUPPORT_UNAUTHORIZED_MUTATION_ATTEMPT` | `SUPPORT_UNAUTHORIZED_MUTATION_ATTEMPT` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_SUPPORT_REFUND_EVIDENCE_MISSING` | `SUPPORT_REFUND_EVIDENCE_MISSING` | `HIGH_RISK` | `ROUTE_SUPPORT_LEAD` |
| `ALERT_SUPPORT_UNMASKING_AUTHORITY_MISSING` | `SUPPORT_UNMASKING_AUTHORITY_MISSING` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_SUPPORT_EXPORT_RESTRICTED_REQUEST` | `SUPPORT_EXPORT_RESTRICTED_REQUEST` | `CRITICAL` | `ROUTE_LEGAL_COMPLIANCE` |
| `ALERT_SUPPORT_AI_DRAFT_UNAPPROVED_USE` | `SUPPORT_AI_DRAFT_UNAPPROVED_USE` | `HIGH_RISK` | `ROUTE_SUPPORT_LEAD` |
| `ALERT_SUPPORT_CASE_CLOSE_EVIDENCE_MISSING` | `SUPPORT_CASE_CLOSE_EVIDENCE_MISSING` | `REVIEW_REQUIRED` | `ROUTE_SUPPORT_LEAD` |

---

## 21. AI And pgvector Event Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `AI_RESTRICTED_SOURCE_REQUESTED` | AI requested restricted source | `CRITICAL` |
| `AI_UNTRACEABLE_OUTPUT` | AI output lacks traceability | `HIGH_RISK` |
| `AI_CUSTOMER_OUTPUT_UNAPPROVED` | AI customer-facing output unapproved | `HIGH_RISK` |
| `AI_PROVIDER_CAPABILITY_ASSERTION` | AI asserts provider capability | `PROVIDER_REVIEW_REQUIRED` |
| `AI_AUTHORITY_OVERREACH` | AI attempts authority action | `CRITICAL` |
| `PGVECTOR_SOURCE_NOT_APPROVED` | Source not approved for vectorization | `HIGH_RISK` |
| `PGVECTOR_TRACEABILITY_MISSING` | Vector lacks traceability | `HIGH_RISK` |
| `PGVECTOR_RESTRICTED_DATA_RISK` | Restricted data risk in vector | `CRITICAL` |
| `PGVECTOR_CROSS_TENANT_RISK` | Cross-tenant vector retrieval | `CRITICAL` |
| `PGVECTOR_OUTPUT_USED_AS_AUTHORITY` | Similarity used as truth | `CRITICAL` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_AI_RESTRICTED_SOURCE_REQUESTED` | `AI_RESTRICTED_SOURCE_REQUESTED` | `CRITICAL` | `ROUTE_AI_GOVERNANCE` |
| `ALERT_AI_UNTRACEABLE_OUTPUT` | `AI_UNTRACEABLE_OUTPUT` | `HIGH_RISK` | `ROUTE_AI_GOVERNANCE` |
| `ALERT_AI_CUSTOMER_OUTPUT_UNAPPROVED` | `AI_CUSTOMER_OUTPUT_UNAPPROVED` | `HIGH_RISK` | `ROUTE_SUPPORT_LEAD` |
| `ALERT_AI_PROVIDER_CAPABILITY_ASSERTION` | `AI_PROVIDER_CAPABILITY_ASSERTION` | `PROVIDER_REVIEW_REQUIRED` | `ROUTE_PROVIDER_OPS` |
| `ALERT_AI_AUTHORITY_OVERREACH` | `AI_AUTHORITY_OVERREACH` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_PGVECTOR_SOURCE_NOT_APPROVED` | `PGVECTOR_SOURCE_NOT_APPROVED` | `HIGH_RISK` | `ROUTE_AI_GOVERNANCE` |
| `ALERT_PGVECTOR_TRACEABILITY_MISSING` | `PGVECTOR_TRACEABILITY_MISSING` | `HIGH_RISK` | `ROUTE_AI_GOVERNANCE` |
| `ALERT_PGVECTOR_RESTRICTED_DATA_RISK` | `PGVECTOR_RESTRICTED_DATA_RISK` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_PGVECTOR_CROSS_TENANT_RISK` | `PGVECTOR_CROSS_TENANT_RISK` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_PGVECTOR_OUTPUT_USED_AS_AUTHORITY` | `PGVECTOR_OUTPUT_USED_AS_AUTHORITY` | `CRITICAL` | `ROUTE_SECURITY` |

---

## 22. Archive Retention Event Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `ARCHIVE_MIGRATION_STARTED` | Archive migration started | `INFO` |
| `ARCHIVE_MIGRATION_COMPLETED` | Archive migration completed | `INFO` |
| `ARCHIVE_MIGRATION_FAILED` | Archive migration failed | `HIGH_RISK` |
| `ARCHIVE_MANIFEST_CREATED` | Archive manifest created | `INFO` |
| `ARCHIVE_MANIFEST_MISSING` | Archive manifest missing | `HIGH_RISK` |
| `ARCHIVE_VERIFICATION_FAILED` | Archive verification failed | `HIGH_RISK` |
| `ARCHIVE_LEGAL_HOLD_APPLIED` | Legal hold applied | `NOTICE` |
| `ARCHIVE_LEGAL_HOLD_CONFLICT` | Delete/prune during legal hold | `CRITICAL` |
| `ARCHIVE_RETRIEVAL_RESTRICTED` | Restricted retrieval attempted | `CRITICAL` |
| `ARCHIVE_VECTOR_DEPENDENCY_CONFLICT` | Vector lifecycle conflict | `HIGH_RISK` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_ARCHIVE_MIGRATION_FAILED` | `ARCHIVE_MIGRATION_FAILED` | `HIGH_RISK` | `ROUTE_DATA_GOVERNANCE` |
| `ALERT_ARCHIVE_MANIFEST_MISSING` | `ARCHIVE_MANIFEST_MISSING` | `HIGH_RISK` | `ROUTE_DATA_GOVERNANCE` |
| `ALERT_ARCHIVE_VERIFICATION_FAILED` | `ARCHIVE_VERIFICATION_FAILED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_ARCHIVE_LEGAL_HOLD_CONFLICT` | `ARCHIVE_LEGAL_HOLD_CONFLICT` | `CRITICAL` | `ROUTE_LEGAL_COMPLIANCE` |
| `ALERT_ARCHIVE_RETRIEVAL_RESTRICTED` | `ARCHIVE_RETRIEVAL_RESTRICTED` | `CRITICAL` | `ROUTE_SECURITY` |
| `ALERT_ARCHIVE_VECTOR_DEPENDENCY_CONFLICT` | `ARCHIVE_VECTOR_DEPENDENCY_CONFLICT` | `HIGH_RISK` | `ROUTE_AI_GOVERNANCE` |

---

## 23. Trigger View Agent Monitoring Event Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `TVA_TRIGGER_SIGNAL_CREATED` | Trigger signal created | `INFO` |
| `TVA_TRIGGER_FAILURE` | Trigger failed | `HIGH_RISK` |
| `TVA_TRIGGER_HEAVY_LOGIC_DETECTED` | Trigger includes prohibited heavy logic | `HIGH_RISK` |
| `TVA_MONITORING_VIEW_STALE` | Monitoring view stale | `WARNING` |
| `TVA_MONITORING_VIEW_REFRESH_FAILED` | Monitoring view refresh failed | `HIGH_RISK` |
| `TVA_DAEMON_VIEW_ACCESS_FAILED` | Daemon cannot access view | `HIGH_RISK` |
| `TVA_DAEMON_RULE_MATCHED` | Daemon deterministic rule matched | `NOTICE` |
| `TVA_DAEMON_CONTAINMENT_TRIGGERED` | Daemon triggered pre-approved containment | `HIGH_RISK` |
| `TVA_DAEMON_DEGRADED_MODE` | AI/pgvector unavailable, degraded mode | `WARNING` |
| `TVA_DAEMON_RULE_TUNING_REQUESTED` | Rule tuning requested | `REVIEW_REQUIRED` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_TVA_TRIGGER_FAILURE` | `TVA_TRIGGER_FAILURE` | `HIGH_RISK` | `ROUTE_PLATFORM` |
| `ALERT_TVA_TRIGGER_HEAVY_LOGIC_DETECTED` | `TVA_TRIGGER_HEAVY_LOGIC_DETECTED` | `HIGH_RISK` | `ROUTE_PLATFORM` |
| `ALERT_TVA_MONITORING_VIEW_STALE` | `TVA_MONITORING_VIEW_STALE` | `WARNING` | `ROUTE_PLATFORM` |
| `ALERT_TVA_MONITORING_VIEW_REFRESH_FAILED` | `TVA_MONITORING_VIEW_REFRESH_FAILED` | `HIGH_RISK` | `ROUTE_PLATFORM` |
| `ALERT_TVA_DAEMON_VIEW_ACCESS_FAILED` | `TVA_DAEMON_VIEW_ACCESS_FAILED` | `HIGH_RISK` | `ROUTE_PLATFORM` |
| `ALERT_TVA_DAEMON_CONTAINMENT_TRIGGERED` | `TVA_DAEMON_CONTAINMENT_TRIGGERED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_TVA_DAEMON_DEGRADED_MODE` | `TVA_DAEMON_DEGRADED_MODE` | `WARNING` | `ROUTE_PLATFORM` |
| `ALERT_TVA_DAEMON_RULE_TUNING_REQUESTED` | `TVA_DAEMON_RULE_TUNING_REQUESTED` | `REVIEW_REQUIRED` | `ROUTE_SECURITY` |

---

## 24. Runtime Entry Event Alert Families

| Event Family | Meaning | Default Severity |
|---|---|---|
| `RUNTIME_ENTRY_REQUESTED` | Runtime coding entry requested | `REVIEW_REQUIRED` |
| `RUNTIME_ENTRY_BLOCKED` | Runtime entry blocked by open blocker | `REVIEW_REQUIRED` |
| `RUNTIME_ENTRY_APPROVED` | Runtime entry approved | `INFO` |
| `RUNTIME_SCOPE_DRIFT_DETECTED` | Work exceeded approved scope | `HIGH_RISK` |
| `RUNTIME_PROVIDER_EVIDENCE_MISSING` | Provider evidence missing | `PROVIDER_REVIEW_REQUIRED` |
| `RUNTIME_SECURITY_CATALOG_MISSING` | Security catalog missing | `REVIEW_REQUIRED` |

| Alert Family | Related Event | Severity | Primary Route |
|---|---|---|---|
| `ALERT_RUNTIME_ENTRY_BLOCKED` | `RUNTIME_ENTRY_BLOCKED` | `REVIEW_REQUIRED` | `ROUTE_HQ_ADMIN` |
| `ALERT_RUNTIME_SCOPE_DRIFT_DETECTED` | `RUNTIME_SCOPE_DRIFT_DETECTED` | `HIGH_RISK` | `ROUTE_SECURITY` |
| `ALERT_RUNTIME_PROVIDER_EVIDENCE_MISSING` | `RUNTIME_PROVIDER_EVIDENCE_MISSING` | `PROVIDER_REVIEW_REQUIRED` | `ROUTE_PROVIDER_OPS` |
| `ALERT_RUNTIME_SECURITY_CATALOG_MISSING` | `RUNTIME_SECURITY_CATALOG_MISSING` | `REVIEW_REQUIRED` | `ROUTE_SECURITY` |

---

## 25. i18n Message Key Family Rule

Visible alert messages must use message keys.

Recommended pattern:

`alert.<domain>.<alert_family>.<surface>.<message_type>`

Examples:

| Alert Family | Key Family |
|---|---|
| `ALERT_POS_CROSS_TENANT_EVENT_RISK` | `alert.pos.cross_tenant_event_risk.*` |
| `ALERT_PROVIDER_CALLBACK_SIGNATURE_FAILED` | `alert.provider.callback_signature_failed.*` |
| `ALERT_PAYMENT_DUPLICATE_CAPTURE_RISK` | `alert.payment.duplicate_capture_risk.*` |
| `ALERT_IDENTITY_WRONG_ACCOUNT_RISK` | `alert.identity.wrong_account_risk.*` |
| `ALERT_AI_AUTHORITY_OVERREACH` | `alert.ai.authority_overreach.*` |
| `ALERT_PGVECTOR_RESTRICTED_DATA_RISK` | `alert.pgvector.restricted_data_risk.*` |
| `ALERT_ARCHIVE_LEGAL_HOLD_CONFLICT` | `alert.archive.legal_hold_conflict.*` |
| `ALERT_TVA_DAEMON_CONTAINMENT_TRIGGERED` | `alert.tva.daemon_containment_triggered.*` |

Hardcoded alert text is prohibited.

---

## 26. Evidence And Audit Mapping Rule

Evidence and audit are required when alert involves:

- money
- settlement
- ledger
- wallet/prepaid value
- coupon/benefit value
- membership point/grade
- customer identity
- consent
- provider callback
- provider capability
- tenant/store boundary
- restricted data
- support/admin authority
- AI customer-facing output
- pgvector restricted source
- archive/legal hold
- content allergen/safety
- customer recovery
- containment release
- quarantine release/rejection

---

## 27. pgvector And AI Eligibility Rule

Event and alert families may be vectorized only as approved summaries.

Blocked from vectorization:

- secrets
- raw payment data
- raw identity data
- raw provider payloads with secrets
- unrestricted support notes
- legal hold material without approval
- raw customer data
- unmasked HR data
- sensitive archive objects

AI may summarize allowed event/alert summaries but must not acknowledge, resolve, release, mutate, compensate, refund, publish, confirm provider capability, or decide final truth.

---

## 28. Event Alert Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-EVENT-ALERT-CATALOG-0001` | Event/alert catalog not reviewed |
| `BLOCKER-EVENT-FAMILY-0001` | Event family missing |
| `BLOCKER-ALERT-FAMILY-0001` | Alert family missing |
| `BLOCKER-SEVERITY-MAP-0001` | Severity mapping missing |
| `BLOCKER-ROUTE-MAP-0001` | Route mapping missing |
| `BLOCKER-I18N-ALERT-0001` | Visible alert key missing |
| `BLOCKER-EVIDENCE-AUDIT-MAP-0001` | Evidence/audit mapping missing |
| `BLOCKER-AI-PGVECTOR-EVENT-0001` | AI/pgvector eligibility missing |
| `BLOCKER-CONTAINMENT-ALERT-MAP-0001` | Containment alert mapping missing |
| `BLOCKER-QUARANTINE-ALERT-MAP-0001` | Quarantine alert mapping missing |

Open event/alert blockers prevent runtime monitoring implementation.

---

## 29. Validation Checklist

Validation must confirm:

- every event family has stable id
- every alert family has stable id
- every alert maps to event
- every event maps to domain and bulkhead
- every alert has severity
- every alert has primary route
- every high-risk alert has escalation route
- every visible alert has i18n key family
- every value/identity/provider/security alert has evidence/audit rule
- every containment event has alert mapping
- every quarantine event has alert mapping
- AI events preserve assistance-only boundary
- pgvector events preserve similarity-only boundary
- provider events preserve evidence-required default
- archive events preserve manifest/legal hold rules
- runtime entry alerts block coding when blockers remain open

---

## 30. Relationship To Previous Documents

This document implements Artifact Group D from:

- `09630 Financial-Grade Security Monitoring Foundation Catalog Execution Plan And Artifact Map`

It follows:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09632 Containment Status And Trigger Map Catalog`
- `09633 Quarantine Status And Trigger Map Catalog`
- `09634 Security Control Records And Security Class Catalog`

It depends on:

- `09550 Universal Alert Routing Severity Escalation And Acknowledgement Policy`
- `09570 Financial-Grade Security Foundation Control Catalog And Bulkhead Readiness Policy`
- `09580 AI Daemon Security Monitoring Agent And Autonomous Containment Policy`
- `09590 Trigger View Agent Monitoring Pipeline And Audit Projection Policy`
- `09620 Financial-Grade Security Monitoring Catalog Work Order And Implementation Handoff Policy`

This document is Foundation-grade and catalog-only.

It does not authorize coding.

---

## 31. Final Rule

Every financial-grade security monitoring condition must be represented as a controlled event and, where review is required, a controlled alert.

Events record what happened.

Alerts route what must be reviewed.

Every event and alert must have stable naming, domain, bulkhead, severity, route, i18n key family where visible, evidence/audit rule where high-risk, pgvector eligibility, AI boundary, and blocker linkage.

No runtime monitoring implementation may proceed while event, alert, severity, route, evidence, audit, i18n, containment, quarantine, AI, or pgvector mappings are missing.

Coding remains deferred until this event and alert catalog is reviewed, validated, and attached to package-specific entry gates.
