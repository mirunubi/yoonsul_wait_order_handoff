# 09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy

## 1. Purpose

This document defines the Unix-style error code catalog for the Financial-Grade Security Monitoring Foundation Package.

The previous artifact `09635` defined security event and alert families.

This document defines the controlled error codes that may be emitted by triggers, monitoring views, daemon filters, provider adapters, POS adapters, support/admin workflows, AI governance checks, pgvector source controls, archive lifecycle jobs, and future runtime packages.

Error codes are not free-text logs.

Error codes are compact, stable, machine-readable fault signals that connect:

- source event
- affected domain
- severity
- containment rule
- quarantine rule
- alert family
- evidence requirement
- audit requirement
- pgvector eligibility
- AI boundary
- support/admin routing
- runtime blocker

This document is catalog-only.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This catalog applies to error code planning for:

1. Security and authentication
2. POS integration
3. Provider callbacks
4. Payment state
5. Settlement and ledger
6. Membership
7. Coupon and promotion
8. Wallet/prepaid value
9. Customer identity and consent
10. KDS/order mismatch
11. Inventory and sold-out
12. Content and i18n
13. External projection
14. Support/admin authority
15. AI governance
16. pgvector source and retrieval
17. Archive and retention
18. Trigger-View-Agent monitoring
19. Workforce/HR
20. Supplier/SCM/WMS
21. Franchise OS
22. Runtime entry governance

This catalog does not implement runtime error handlers, database constraints, trigger logic, alert workers, or dashboards.

---

## 3. Core Principle

Every critical abnormal condition must have a stable code.

A good error code must answer:

- which domain failed
- what family of failure occurred
- what detail caused risk
- whether the event is security-relevant
- whether containment or quarantine may be required
- whether evidence/audit is required
- whether customer-facing communication is allowed
- whether AI/pgvector may observe only a summary
- whether runtime implementation must be blocked

The project must not rely on ambiguous log text such as:

- `error`
- `failed`
- `something wrong`
- `unknown problem`
- `POS issue`
- `payment problem`
- `AI problem`

Those strings do not provide financial-grade monitoring value.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09636` |
| Package ID | `foundation.security_monitoring.financial_grade.v1` |
| Artifact Type | `CATALOG` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATALOG_ONLY` |
| Owner | `Architecture / Security Foundation` |
| Dependencies | `09631`, `09632`, `09633`, `09634`, `09635`, `09630`, `09620`, `09610` |
| Provider Evidence Status | `APPLIES_IF_PROVIDER_RELATED` |
| i18n Requirement | `APPLIES_IF_VISIBLE_ERROR_MESSAGE` |
| Audit Requirement | `REQUIRED_FOR_HIGH_RISK_ERROR_CODES` |
| Security Requirement | `FINANCIAL_GRADE_ERROR_CODE_CATALOG_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_AUDIT_REVIEW_REQUIRED` |
| Blocker Status | `ERROR_CODE_CATALOG_REVIEW_REQUIRED` |

---

## 5. Error Code Naming Rule

Recommended naming pattern:

`ERR_<DOMAIN>_<FAMILY>_<DETAIL>`

Where:

| Segment | Meaning |
|---|---|
| `ERR` | Error/fault prefix |
| `<DOMAIN>` | POS, SEC, PROVIDER, PAYMENT, LEDGER, etc. |
| `<FAMILY>` | AUTH, TOKEN, CALLBACK, DUP, MISMATCH, etc. |
| `<DETAIL>` | Specific detail or status |

Examples:

- `ERR_SEC_AUTH_FAIL_401`
- `ERR_POS_CROSS_STORE_EVENT`
- `ERR_PROVIDER_CALLBACK_SIGNATURE_FAILED`
- `ERR_PAYMENT_DUPLICATE_CAPTURE_RISK`
- `ERR_LEDGER_APPEND_ONLY_VIOLATION`
- `ERR_AI_AUTHORITY_OVERREACH`
- `ERR_PGVECTOR_SOURCE_NOT_APPROVED`
- `ERR_ARCHIVE_LEGAL_HOLD_CONFLICT`

Error codes must be uppercase snake case.

Error codes must not contain customer names, phone numbers, emails, secret values, provider keys, or raw identifiers.

---

## 6. Error Code Record Schema

Each error code must include:

| Field | Required Meaning |
|---|---|
| Error Code | Stable controlled code |
| Domain | Fault domain |
| Error Family | Auth, token, callback, mismatch, etc. |
| Detail | Specific fault condition |
| Default Severity | Controlled severity |
| Related Event Family | Event emitted |
| Related Alert Family | Alert candidate |
| Bulkhead | Affected security bulkhead |
| Containment Candidate | Yes/no |
| Quarantine Candidate | Yes/no |
| Reconciliation Candidate | Yes/no |
| Evidence Requirement | None, optional, required |
| Audit Requirement | None, conditional, required |
| Customer Visibility | Internal only, support-mediated, customer-safe |
| i18n Key Family | Required if visible |
| pgvector Eligibility | Blocked, summary-only, approved-source |
| AI Boundary | Internal summary only or blocked |
| Readiness Blocker | Blocker if undefined |

An error code without related event family is incomplete.

---

## 7. Error Family Catalog

| Error Family | Meaning |
|---|---|
| `AUTH` | Authentication/authorization fault |
| `TOKEN` | Token/session/scope fault |
| `SCOPE` | Tenant/store/domain scope fault |
| `CALLBACK` | Provider callback fault |
| `CAPABILITY` | Provider capability/evidence fault |
| `IDEMPOTENCY` | Duplicate prevention fault |
| `DUP` | Duplicate event/value risk |
| `MISMATCH` | Cross-system mismatch |
| `RECON` | Reconciliation fault |
| `LEDGER` | Ledger/settlement fault |
| `VALUE` | Value-bearing mutation fault |
| `IDENTITY` | Identity/consent fault |
| `PROJECTION` | External projection fault |
| `CONTENT` | Content source/approval fault |
| `I18N` | Locale/message key fault |
| `AI` | AI authority/source/output fault |
| `VECTOR` | pgvector source/retrieval fault |
| `ARCHIVE` | Archive/retention fault |
| `TRIGGER` | Trigger signal fault |
| `VIEW` | Monitoring view fault |
| `DAEMON` | Monitoring daemon fault |
| `SUPPORT` | Support/admin authority fault |
| `EXPORT` | Data export fault |
| `LEGAL` | Legal/compliance fault |
| `SECURITY` | Security boundary fault |
| `RUNTIME` | Runtime entry/scope fault |

---

## 8. Security Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_SEC_AUTH_FAIL_401` | Authentication failed | `WARNING` |
| `ERR_SEC_AUTH_REPEATED_FAIL` | Repeated authentication failure | `HIGH_RISK` |
| `ERR_SEC_AUTHZ_DENIED` | Authorization denied | `WARNING` |
| `ERR_SEC_AUTHZ_SCOPE_VIOLATION` | Actor attempted action outside scope | `CRITICAL` |
| `ERR_SEC_TOKEN_SCOPE_VIOLATION` | Token used outside allowed scope | `CRITICAL` |
| `ERR_SEC_TOKEN_REPLAY_DETECTED` | Token replay detected | `CRITICAL` |
| `ERR_SEC_SECRET_EXPOSURE_RISK` | Secret-like value detected | `CRITICAL` |
| `ERR_SEC_RESTRICTED_DATA_ACCESS` | Restricted data access attempted | `HIGH_RISK` |
| `ERR_SEC_TENANT_BOUNDARY_RISK` | Tenant boundary risk | `CRITICAL` |
| `ERR_SEC_STORE_BOUNDARY_RISK` | Store boundary risk | `HIGH_RISK` |
| `ERR_SEC_CROSS_BULKHEAD_INFECTION_RISK` | Cross-bulkhead propagation risk | `CRITICAL` |
| `ERR_SEC_SOURCE_OF_TRUTH_CONFLICT` | Source-of-truth conflict | `HIGH_RISK` |

Default route: `ROUTE_SECURITY`.

---

## 9. POS Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_POS_EVENT_MALFORMED` | POS event malformed | `WARNING` |
| `ERR_POS_EVENT_UNMAPPED` | POS event cannot map to order/store/session | `WARNING` |
| `ERR_POS_CROSS_STORE_EVENT` | POS event crosses store boundary | `HIGH_RISK` |
| `ERR_POS_CROSS_TENANT_EVENT` | POS event crosses tenant boundary | `CRITICAL` |
| `ERR_POS_TOKEN_SCOPE_VIOLATION` | POS token scope violation | `CRITICAL` |
| `ERR_POS_REPLAY_DETECTED` | POS event replay detected | `HIGH_RISK` |
| `ERR_POS_DUP_PAYLOAD_MISMATCH` | Duplicate POS key with different payload | `HIGH_RISK` |
| `ERR_POS_STALE_EVENT` | POS event stale beyond allowed window | `WARNING` |
| `ERR_POS_UNKNOWN_DEVICE` | POS device/session unknown | `HIGH_RISK` |
| `ERR_POS_LOCAL_CACHE_AUTHORITY_RISK` | POS local cache presented as authority | `HIGH_RISK` |
| `ERR_POS_SANDBOX_ABNORMAL` | POS sandbox abnormality detected | `HIGH_RISK` |

Default route: `ROUTE_PLATFORM`, with security escalation for cross-store/cross-tenant/token/replay.

---

## 10. Provider Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_PROVIDER_CALLBACK_UNSIGNED` | Provider callback missing signature | `CRITICAL` |
| `ERR_PROVIDER_CALLBACK_SIGNATURE_FAILED` | Provider callback signature failed | `CRITICAL` |
| `ERR_PROVIDER_CALLBACK_REPLAY_DETECTED` | Callback replay detected | `CRITICAL` |
| `ERR_PROVIDER_CALLBACK_UNMAPPED` | Callback cannot map internally | `HIGH_RISK` |
| `ERR_PROVIDER_CALLBACK_DUP_PAYLOAD_MISMATCH` | Duplicate callback payload mismatch | `HIGH_RISK` |
| `ERR_PROVIDER_CALLBACK_STALE` | Callback stale beyond allowed window | `WARNING` |
| `ERR_PROVIDER_CAPABILITY_EVIDENCE_MISSING` | Provider capability evidence missing | `PROVIDER_REVIEW_REQUIRED` |
| `ERR_PROVIDER_CONTRACT_DRIFT` | Provider contract/API behavior drift | `HIGH_RISK` |
| `ERR_PROVIDER_SETTLEMENT_REPORT_MISSING` | Settlement report missing | `RECONCILIATION_REQUIRED` |
| `ERR_PROVIDER_RATE_LIMIT` | Provider rate limit or throttling | `WARNING` |
| `ERR_PROVIDER_TIMEOUT_BURST` | Repeated provider timeout | `WARNING` |
| `ERR_PROVIDER_GLOBAL_PAYMENT_UNVERIFIED` | Global payment capability unverified | `PROVIDER_REVIEW_REQUIRED` |

Default route: `ROUTE_PROVIDER_OPS`, with security/finance escalation depending on fault.

---

## 11. Payment Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_PAYMENT_STATE_UNCERTAIN` | Payment state uncertain | `HIGH_RISK` |
| `ERR_PAYMENT_DUPLICATE_CAPTURE_RISK` | Duplicate capture risk | `CRITICAL` |
| `ERR_PAYMENT_AMOUNT_MISMATCH` | Amount mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_PAYMENT_REFUND_WITHOUT_APPROVAL` | Refund without approval | `CRITICAL` |
| `ERR_PAYMENT_CALLBACK_MISSING` | Payment callback missing | `HIGH_RISK` |
| `ERR_PAYMENT_POS_CANCELLED_PROVIDER_CAPTURED` | POS canceled but provider captured | `HIGH_RISK` |
| `ERR_PAYMENT_PROVIDER_CANCEL_INTERNAL_CAPTURED` | Provider canceled but internal state captured | `HIGH_RISK` |
| `ERR_PAYMENT_IDEMPOTENCY_MISSING` | Payment idempotency missing | `HIGH_RISK` |
| `ERR_PAYMENT_DUP_PAYLOAD_MISMATCH` | Duplicate payment key with different payload | `HIGH_RISK` |
| `ERR_PAYMENT_REFUND_STATE_MISMATCH` | Refund state mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_PAYMENT_CUSTOMER_RECOVERY_REQUIRED` | Customer impact likely | `CUSTOMER_RECOVERY_REQUIRED` |

Default route: `ROUTE_FINANCE`.

---

## 12. Ledger And Settlement Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_LEDGER_IMBALANCE_DETECTED` | Ledger imbalance detected | `CRITICAL` |
| `ERR_LEDGER_APPEND_ONLY_VIOLATION` | Update/delete attempted against append-only ledger | `CRITICAL` |
| `ERR_LEDGER_EVIDENCE_MISSING` | Ledger entry lacks evidence | `HIGH_RISK` |
| `ERR_LEDGER_CORRECTION_AUTH_MISSING` | Correction lacks authority | `CRITICAL` |
| `ERR_LEDGER_RECON_MISMATCH` | Ledger reconciliation mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_SETTLEMENT_PROVIDER_MISMATCH` | Provider/internal settlement mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_SETTLEMENT_REPORT_MISSING` | Settlement report missing | `RECONCILIATION_REQUIRED` |
| `ERR_SETTLEMENT_FX_EVIDENCE_MISSING` | Exchange-rate evidence missing | `RECONCILIATION_REQUIRED` |
| `ERR_SETTLEMENT_ALLOCATION_HELD` | Settlement allocation held | `HIGH_RISK` |
| `ERR_SETTLEMENT_ROYALTY_CONFLICT` | Royalty/settlement conflict | `RECONCILIATION_REQUIRED` |

Default route: `ROUTE_FINANCE` or `ROUTE_RECONCILIATION`.

---

## 13. Membership Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_MEMBERSHIP_IDENTITY_CONFLICT` | Membership identity conflict | `HIGH_RISK` |
| `ERR_MEMBERSHIP_DUPLICATE_ACCOUNT` | Duplicate account candidate | `HIGH_RISK` |
| `ERR_MEMBERSHIP_POINT_MISMATCH` | Point mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_MEMBERSHIP_GRADE_MISMATCH` | Grade mismatch | `WARNING` |
| `ERR_MEMBERSHIP_BENEFIT_CONFLICT` | Benefit rule conflict | `WARNING` |
| `ERR_MEMBERSHIP_CONSENT_MISSING` | Consent missing | `LEGAL_COMPLIANCE_REVIEW_REQUIRED` |
| `ERR_MEMBERSHIP_PARTNER_SYNC_MISMATCH` | Partner sync mismatch | `WARNING` |
| `ERR_MEMBERSHIP_VALUE_MUTATION_BLOCKED` | Membership value mutation blocked | `HIGH_RISK` |
| `ERR_MEMBERSHIP_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery required | `CUSTOMER_RECOVERY_REQUIRED` |

Default route: `ROUTE_SUPPORT`, with privacy/legal escalation when identity/consent involved.

---

## 14. Coupon Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_COUPON_DUPLICATE_USE` | Duplicate coupon use risk | `HIGH_RISK` |
| `ERR_COUPON_RULE_MISMATCH` | Coupon rule mismatch | `WARNING` |
| `ERR_COUPON_CAMPAIGN_CONFLICT` | Campaign conflict | `WARNING` |
| `ERR_COUPON_PARTNER_STATE_STALE` | Partner coupon state stale | `WARNING` |
| `ERR_COUPON_IDEMPOTENCY_MISSING` | Coupon idempotency missing | `HIGH_RISK` |
| `ERR_COUPON_VALUE_MUTATION_BLOCKED` | Coupon value mutation blocked | `HIGH_RISK` |
| `ERR_COUPON_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery required | `CUSTOMER_RECOVERY_REQUIRED` |

Default route: `ROUTE_SUPPORT` or `ROUTE_HQ_ADMIN`.

---

## 15. Wallet Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_WALLET_DUPLICATE_CHARGE` | Duplicate wallet charge risk | `CRITICAL` |
| `ERR_WALLET_DUPLICATE_USE` | Duplicate wallet use risk | `CRITICAL` |
| `ERR_WALLET_BALANCE_MISMATCH` | Wallet balance mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_WALLET_REFUND_MISMATCH` | Wallet refund mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_WALLET_UNAUTHORIZED_ADJUSTMENT` | Unauthorized wallet adjustment | `CRITICAL` |
| `ERR_WALLET_IDEMPOTENCY_MISSING` | Wallet idempotency missing | `HIGH_RISK` |
| `ERR_WALLET_VALUE_MUTATION_BLOCKED` | Wallet value mutation blocked | `HIGH_RISK` |
| `ERR_WALLET_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery required | `CUSTOMER_RECOVERY_REQUIRED` |

Default route: `ROUTE_FINANCE`.

---

## 16. Identity Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_IDENTITY_WRONG_ACCOUNT_RISK` | Wrong account risk | `CRITICAL` |
| `ERR_IDENTITY_DUPLICATE_CANDIDATE` | Duplicate identity candidate | `HIGH_RISK` |
| `ERR_IDENTITY_CONSENT_MISSING` | Consent missing | `LEGAL_COMPLIANCE_REVIEW_REQUIRED` |
| `ERR_IDENTITY_PARTNER_MISMATCH` | Partner identity mismatch | `HIGH_RISK` |
| `ERR_IDENTITY_CROSS_CUSTOMER_MAPPING` | Cross-customer mapping risk | `CRITICAL` |
| `ERR_IDENTITY_LINK_BLOCKED` | Identity link blocked | `HIGH_RISK` |
| `ERR_IDENTITY_UNMASKING_AUTH_MISSING` | Identity unmasking lacks authority | `CRITICAL` |

Default route: `ROUTE_PRIVACY`, with legal/security escalation as needed.

---

## 17. KDS Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_KDS_DUPLICATE_TICKET_RISK` | Duplicate KDS ticket risk | `HIGH_RISK` |
| `ERR_KDS_ORDER_PAYMENT_MISMATCH` | KDS/order/payment mismatch | `HIGH_RISK` |
| `ERR_KDS_UNAVAILABLE_ITEM_ACCEPTED` | KDS accepted unavailable item | `WARNING` |
| `ERR_KDS_MANUAL_FALLBACK_EVIDENCE_MISSING` | Manual fallback lacks evidence | `REVIEW_REQUIRED` |
| `ERR_KDS_UNMAPPED_STATION` | Station route unmapped | `WARNING` |
| `ERR_KDS_ROUTE_FAILURE_BURST` | Repeated station routing failure | `WARNING` |
| `ERR_KDS_REMAKE_EVIDENCE_MISSING` | Remake lacks evidence | `REVIEW_REQUIRED` |
| `ERR_KDS_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery required | `CUSTOMER_RECOVERY_REQUIRED` |

Default route: `ROUTE_STORE_OPS`, with support escalation for customer impact.

---

## 18. Inventory SCM WMS Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_INVENTORY_STOCK_MISMATCH` | Stock mismatch | `WARNING` |
| `ERR_INVENTORY_AVAILABILITY_MISMATCH` | Availability mismatch | `WARNING` |
| `ERR_INVENTORY_PROJECTION_RISK` | Unsafe inventory projection | `HIGH_RISK` |
| `ERR_INVENTORY_WASTE_EVIDENCE_MISSING` | Waste/disposal evidence missing | `REVIEW_REQUIRED` |
| `ERR_SUPPLIER_DELIVERY_MISMATCH` | Supplier delivery mismatch | `WARNING` |
| `ERR_SUPPLIER_QUALITY_ISSUE` | Supplier/QC issue | `HIGH_RISK` |
| `ERR_WMS_STOCK_CONFLICT` | WMS stock conflict | `WARNING` |
| `ERR_QC_SAFETY_RISK` | QC/safety risk | `HIGH_RISK` |

Default route: `ROUTE_STORE_OPS` or `ROUTE_SCM_WMS`.

---

## 19. Content i18n Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_CONTENT_SOURCE_TRACE_MISSING` | Content source trace missing | `WARNING` |
| `ERR_CONTENT_UNAPPROVED_PUBLICATION` | Unapproved content used for visible surface | `HIGH_RISK` |
| `ERR_CONTENT_ALLERGEN_MISMATCH` | Allergen text mismatch | `CRITICAL` |
| `ERR_CONTENT_PRICE_TEXT_MISMATCH` | Price text mismatch | `HIGH_RISK` |
| `ERR_I18N_MESSAGE_KEY_MISSING` | Message key missing | `WARNING` |
| `ERR_I18N_WRONG_LOCALE` | Wrong locale output | `WARNING` |
| `ERR_I18N_CUSTOMER_VISIBLE_UNTRANSLATED` | Customer-visible untranslated text | `HIGH_RISK` |
| `ERR_I18N_HARDCODED_OPERATIONAL_STRING` | Hardcoded operational string detected | `WARNING` |
| `ERR_I18N_AI_TEXT_UNAPPROVED` | AI-generated visible text unapproved | `HIGH_RISK` |

Default route: `ROUTE_CONTENT` or `ROUTE_LOCALIZATION`.

---

## 20. External Projection Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_PROJECTION_PRICE_MISMATCH` | Projected price mismatch | `HIGH_RISK` |
| `ERR_PROJECTION_ALLERGEN_MISMATCH` | Projected allergen mismatch | `CRITICAL` |
| `ERR_PROJECTION_AVAILABILITY_MISMATCH` | Projected availability mismatch | `WARNING` |
| `ERR_PROJECTION_PAYMENT_CAPABILITY_UNVERIFIED` | Payment capability unverified | `PROVIDER_REVIEW_REQUIRED` |
| `ERR_PROJECTION_STALE` | Projection stale | `WARNING` |
| `ERR_PROJECTION_PARTNER_SYNC_MISMATCH` | Partner projection sync mismatch | `WARNING` |
| `ERR_PROJECTION_IDENTITY_SHARING_RISK` | Identity sharing risk | `CRITICAL` |
| `ERR_PROJECTION_PUBLICATION_BLOCKED` | Projection publication blocked | `HIGH_RISK` |

Default route: `ROUTE_CONTENT`, `ROUTE_PROVIDER_OPS`, or `ROUTE_LEGAL_COMPLIANCE`.

---

## 21. Support Admin Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_SUPPORT_UNAUTHORIZED_MUTATION` | Unauthorized support/admin mutation | `CRITICAL` |
| `ERR_SUPPORT_REFUND_EVIDENCE_MISSING` | Refund lacks evidence | `HIGH_RISK` |
| `ERR_SUPPORT_UNMASKING_AUTH_MISSING` | Unmasking lacks authority | `CRITICAL` |
| `ERR_SUPPORT_EXPORT_RESTRICTED` | Restricted export requested | `CRITICAL` |
| `ERR_SUPPORT_CASE_CLOSE_EVIDENCE_MISSING` | Case closure lacks evidence | `REVIEW_REQUIRED` |
| `ERR_SUPPORT_AI_DRAFT_UNAPPROVED_USE` | AI draft used without approval | `HIGH_RISK` |
| `ERR_SUPPORT_OVERRIDE_AUTH_MISSING` | Override lacks authority | `CRITICAL` |
| `ERR_SUPPORT_CUSTOMER_RECOVERY_REQUIRED` | Customer recovery required | `CUSTOMER_RECOVERY_REQUIRED` |

Default route: `ROUTE_SUPPORT_LEAD`, with security/legal escalation.

---

## 22. AI Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_AI_RESTRICTED_SOURCE_REQUESTED` | AI requested restricted source | `CRITICAL` |
| `ERR_AI_UNTRACEABLE_OUTPUT` | AI output lacks traceability | `HIGH_RISK` |
| `ERR_AI_CUSTOMER_OUTPUT_UNAPPROVED` | Customer-facing AI output unapproved | `HIGH_RISK` |
| `ERR_AI_PROVIDER_CAPABILITY_ASSERTION` | AI asserts provider capability | `PROVIDER_REVIEW_REQUIRED` |
| `ERR_AI_AUTHORITY_OVERREACH` | AI attempts prohibited authority action | `CRITICAL` |
| `ERR_AI_EVIDENCE_SUMMARY_MISUSED` | AI summary treated as original evidence | `HIGH_RISK` |
| `ERR_AI_WRONG_LOCALE_OUTPUT` | AI output wrong locale | `WARNING` |
| `ERR_AI_PROMPT_SECRET_RISK` | Secret-like content in AI prompt | `CRITICAL` |
| `ERR_AI_OUTPUT_RELEASE_BLOCKED` | AI output blocked from release | `HIGH_RISK` |

Default route: `ROUTE_AI_GOVERNANCE`.

---

## 23. pgvector Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_PGVECTOR_SOURCE_NOT_APPROVED` | Source not approved for vectorization | `HIGH_RISK` |
| `ERR_PGVECTOR_TRACEABILITY_MISSING` | Vector lacks source traceability | `HIGH_RISK` |
| `ERR_PGVECTOR_RESTRICTED_DATA_RISK` | Restricted data in vector source | `CRITICAL` |
| `ERR_PGVECTOR_CROSS_TENANT_RISK` | Cross-tenant vector retrieval | `CRITICAL` |
| `ERR_PGVECTOR_CROSS_STORE_RISK` | Cross-store vector retrieval | `HIGH_RISK` |
| `ERR_PGVECTOR_WRONG_LOCALE_RISK` | Wrong-locale vector retrieval | `WARNING` |
| `ERR_PGVECTOR_STALE_VECTOR` | Vector stale against source | `WARNING` |
| `ERR_PGVECTOR_OUTPUT_USED_AS_AUTHORITY` | Similarity used as final authority | `CRITICAL` |
| `ERR_PGVECTOR_DELETE_REQUIRED` | Vector deletion/refresh required | `REVIEW_REQUIRED` |

Default route: `ROUTE_AI_GOVERNANCE`, with security escalation.

---

## 24. Archive Retention Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_ARCHIVE_MIGRATION_FAILED` | Archive migration failed | `HIGH_RISK` |
| `ERR_ARCHIVE_MANIFEST_MISSING` | Archive manifest missing | `HIGH_RISK` |
| `ERR_ARCHIVE_CHECKSUM_FAILED` | Archive checksum/hash failed | `HIGH_RISK` |
| `ERR_ARCHIVE_VERIFICATION_FAILED` | Archive verification failed | `HIGH_RISK` |
| `ERR_ARCHIVE_HOT_PRUNE_BLOCKED` | Hot prune blocked | `WARNING` |
| `ERR_ARCHIVE_LEGAL_HOLD_CONFLICT` | Delete/prune during legal hold | `CRITICAL` |
| `ERR_ARCHIVE_RETRIEVAL_RESTRICTED` | Restricted archive retrieval | `CRITICAL` |
| `ERR_ARCHIVE_CROSS_TENANT_ACCESS_RISK` | Cross-tenant archive access risk | `CRITICAL` |
| `ERR_ARCHIVE_VECTOR_DEPENDENCY_CONFLICT` | Vector dependency conflict | `HIGH_RISK` |
| `ERR_ARCHIVE_RESTORE_MUTATION_RISK` | Archive restore would mutate runtime truth | `CRITICAL` |
| `ERR_ARCHIVE_RETENTION_EVIDENCE_REQUIRED` | Retention period/legal basis unverified | `LEGAL_COMPLIANCE_REVIEW_REQUIRED` |

Default route: `ROUTE_DATA_GOVERNANCE` or `ROUTE_LEGAL_COMPLIANCE`.

---

## 25. Trigger View Agent Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_TVA_TRIGGER_FAILURE` | Trigger failed | `HIGH_RISK` |
| `ERR_TVA_TRIGGER_HEAVY_LOGIC_DETECTED` | Prohibited heavy trigger logic detected | `HIGH_RISK` |
| `ERR_TVA_TRIGGER_SECRET_LOG_RISK` | Trigger may log secret | `CRITICAL` |
| `ERR_TVA_AUDIT_SIGNAL_MISSING` | Expected audit signal missing | `HIGH_RISK` |
| `ERR_TVA_MONITORING_VIEW_STALE` | Monitoring view stale | `WARNING` |
| `ERR_TVA_MONITORING_VIEW_REFRESH_FAILED` | Monitoring view refresh failed | `HIGH_RISK` |
| `ERR_TVA_DAEMON_VIEW_ACCESS_FAILED` | Daemon cannot access monitoring view | `HIGH_RISK` |
| `ERR_TVA_DAEMON_DEGRADED_MODE` | Daemon entered degraded mode | `WARNING` |
| `ERR_TVA_DAEMON_RULE_TUNING_REQUIRED` | Rule threshold tuning required | `REVIEW_REQUIRED` |
| `ERR_TVA_DAEMON_CONTAINMENT_TRIGGERED` | Daemon triggered containment | `HIGH_RISK` |

Default route: `ROUTE_PLATFORM`, with security escalation for containment or secret risk.

---

## 26. Workforce HR Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_HR_ROLE_MISMATCH` | HR role/permission mismatch | `HIGH_RISK` |
| `ERR_HR_ATTENDANCE_DUPLICATE` | Duplicate attendance event | `WARNING` |
| `ERR_HR_ATTENDANCE_UNMAPPED` | Attendance event cannot map | `WARNING` |
| `ERR_HR_ELIGIBILITY_EVIDENCE_MISSING` | Eligibility evidence missing | `LEGAL_COMPLIANCE_REVIEW_REQUIRED` |
| `ERR_HR_PAYROLL_ADJACENT_MISMATCH` | Payroll-adjacent mismatch | `RECONCILIATION_REQUIRED` |
| `ERR_HR_RESTRICTED_DATA_ACCESS` | HR restricted data access | `HIGH_RISK` |
| `ERR_HR_AI_SUMMARY_RESTRICTED` | AI summary of restricted HR data risk | `HIGH_RISK` |

Default route: `ROUTE_HR`, with security/legal escalation.

---

## 27. Franchise OS Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_FRANCHISE_POLICY_VERSION_MISMATCH` | Policy version mismatch | `WARNING` |
| `ERR_FRANCHISE_ROYALTY_CONFLICT` | Royalty rule conflict | `RECONCILIATION_REQUIRED` |
| `ERR_FRANCHISE_LEGAL_ENTITY_MISMATCH` | Legal entity mismatch | `LEGAL_COMPLIANCE_REVIEW_REQUIRED` |
| `ERR_FRANCHISE_STORE_SYNC_MISMATCH` | Store sync mismatch | `WARNING` |
| `ERR_FRANCHISE_MENU_POLICY_MISMATCH` | Menu policy mismatch | `WARNING` |
| `ERR_FRANCHISE_CROSS_TENANT_POLICY_RISK` | Cross-tenant franchise policy risk | `CRITICAL` |
| `ERR_FRANCHISE_PROVIDER_CAPABILITY_UNVERIFIED` | Provider capability unverified for franchise rollout | `PROVIDER_REVIEW_REQUIRED` |

Default route: `ROUTE_FRANCHISE_OPS`.

---

## 28. Runtime Entry Error Codes

| Error Code | Meaning | Severity |
|---|---|---|
| `ERR_RUNTIME_ENTRY_BLOCKED` | Runtime entry blocked by open blocker | `REVIEW_REQUIRED` |
| `ERR_RUNTIME_SCOPE_DRIFT` | Work exceeded approved scope | `HIGH_RISK` |
| `ERR_RUNTIME_PROVIDER_EVIDENCE_MISSING` | Provider evidence missing before runtime | `PROVIDER_REVIEW_REQUIRED` |
| `ERR_RUNTIME_SECURITY_CATALOG_MISSING` | Security catalog missing | `REVIEW_REQUIRED` |
| `ERR_RUNTIME_TEST_GATE_MISSING` | Boundary test gate missing | `REVIEW_REQUIRED` |
| `ERR_RUNTIME_CODING_WITHOUT_HANDOFF` | Coding attempted without handoff | `HIGH_RISK` |
| `ERR_RUNTIME_PROHIBITED_FILE_TOUCHED` | Prohibited runtime file touched | `HIGH_RISK` |
| `ERR_RUNTIME_SECRET_IN_DOC_OR_TEST` | Secret-like value in doc/test | `CRITICAL` |

Default route: `ROUTE_HQ_ADMIN` or `ROUTE_SECURITY`.

---

## 29. Customer Visibility Rule

Most error codes are internal.

Error codes must not be shown directly to customers unless mapped to a safe message key.

Customer-facing rule:

| Error Code Class | Customer Visibility |
|---|---|
| Security/internal/provider | Internal only |
| Payment uncertainty | Support-mediated |
| Customer recovery required | Safe customer status possible |
| Identity/privacy | Support/legal mediated |
| Content/i18n visible issue | Safe fallback message possible |
| Projection unavailable | Safe customer status possible |
| Archive/daemon/runtime | Internal only |

Customer-visible messages must use i18n/content keys.

---

## 30. Error Code To Event Alert Mapping Rule

Every error code must map to:

1. event family
2. alert family if review/action required
3. severity
4. route
5. bulkhead
6. containment candidate if applicable
7. quarantine candidate if applicable
8. evidence/audit requirement
9. i18n key family if visible
10. pgvector eligibility
11. AI boundary
12. blocker if required mapping is missing

An unmapped error code blocks runtime implementation.

---

## 31. pgvector And AI Rule

Error codes may be used as metadata in pgvector summaries.

Allowed:

- error code
- domain
- event family
- alert family
- severity
- route
- redacted summary
- source trace
- review outcome

Blocked:

- raw payload
- secrets
- raw payment data
- raw identity data
- raw provider credentials
- unmasked restricted records

AI may summarize error-code patterns.

AI must not treat error code frequency as final truth without evidence.

---

## 32. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-ERROR-CODE-CATALOG-0001` | Error code catalog not reviewed |
| `BLOCKER-ERROR-CODE-SCHEMA-0001` | Error code record schema incomplete |
| `BLOCKER-ERROR-CODE-DOMAIN-0001` | Domain missing for error code |
| `BLOCKER-ERROR-CODE-SEVERITY-0001` | Severity missing |
| `BLOCKER-ERROR-CODE-EVENT-MAP-0001` | Event family mapping missing |
| `BLOCKER-ERROR-CODE-ALERT-MAP-0001` | Alert family mapping missing |
| `BLOCKER-ERROR-CODE-ROUTE-0001` | Route mapping missing |
| `BLOCKER-ERROR-CODE-I18N-0001` | Visible error key missing |
| `BLOCKER-ERROR-CODE-PGVECTOR-AI-0001` | AI/pgvector rule missing |
| `BLOCKER-ERROR-CODE-CUSTOMER-VISIBILITY-0001` | Customer visibility rule missing |

Open error-code blockers prevent runtime monitoring implementation.

---

## 33. Validation Checklist

Validation must confirm:

- every error code is uppercase snake case
- every error code starts with `ERR_`
- every error code has domain
- every error code has family
- every error code has detail
- every error code has severity
- every error code maps to event family
- every alertable error maps to alert family
- every high-risk error maps to route
- every security/provider/value/identity error has evidence/audit rule
- customer-visible error has i18n key family
- secrets/personal data are not included in codes
- AI can only summarize approved metadata
- pgvector can only use approved summaries
- unmapped error codes block runtime entry

---

## 34. Relationship To Previous Documents

This document implements Artifact Group D from:

- `09630 Financial-Grade Security Monitoring Foundation Catalog Execution Plan And Artifact Map`

It follows:

- `09635 Security Event Alert Families And Severity Routing Catalog`

It also depends on:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09632 Containment Status And Trigger Map Catalog`
- `09633 Quarantine Status And Trigger Map Catalog`
- `09634 Security Control Records And Security Class Catalog`

This document is Foundation-grade and catalog-only.

It does not authorize coding.

---

## 35. Final Rule

Unix-style error codes are the compact machine-readable fault vocabulary of the Financial-Grade Security Monitoring Foundation Package.

Every critical abnormal condition must map to a controlled error code, event family, alert family, severity, route, bulkhead, containment/quarantine candidate, evidence/audit rule, customer visibility rule, pgvector eligibility, AI boundary, and readiness blocker.

Error codes must never contain secrets, raw identifiers, customer personal data, provider keys, or unstable free text.

No runtime monitoring implementation may proceed while error code mappings are incomplete.

Coding remains deferred until this error code catalog is reviewed, validated, and attached to package-specific entry gates.
