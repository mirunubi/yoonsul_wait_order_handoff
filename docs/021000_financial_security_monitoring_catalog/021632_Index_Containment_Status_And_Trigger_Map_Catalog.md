# 021632_Index_Containment_Status_And_Trigger_Map_Catalog

## 1. Purpose

This document defines the containment status and trigger map for the Financial-Grade Security Monitoring Foundation Package.

The previous artifact `21631` defined bulkheads, source-of-truth boundaries, trust levels, and prohibited propagation paths.

This document defines what happens when a bulkhead is compromised, uncertain, stale, duplicated, replayed, mismatched, or at risk of infecting another domain.

Containment is the defensive action that prevents bad state from spreading.

This document is catalog-only.

It does not authorize coding.

Coding remains deferred unless a specific package has `CODING_ALLOWED`, a completed handoff record, a narrow work order, required tests, and review approval.

---

## 2. Scope

This catalog applies to containment planning for:

1. External POS contamination
2. Provider callback failure
3. Payment uncertainty
4. Settlement ledger mismatch
5. Membership identity/value conflict
6. Coupon duplicate use
7. Wallet/prepaid duplicate value risk
8. Customer identity wrong-link risk
9. KDS duplicate/mismatch risk
10. Inventory and sold-out mismatch
11. Content/i18n customer-facing risk
12. External projection mismatch
13. Support/admin unauthorized action
14. AI authority overreach
15. pgvector restricted source or authority misuse
16. Tenant boundary risk
17. Store boundary risk
18. Archive/legal hold conflict
19. Provider capability evidence gap
20. Trigger-View-Agent monitoring failure

This catalog does not implement containment executors, token invalidators, provider blockers, queues, triggers, or runtime guards.

---

## 3. Core Principle

Containment is not resolution.

Containment means:

- stop dangerous propagation
- preserve current evidence
- prevent silent mutation
- alert responsible actors
- require review
- allow controlled recovery later

Containment must be defensive, scoped, reversible through authority, and auditable.

The system may contain harm automatically.

The system must not use containment as an excuse to silently correct, delete, overwrite, compensate, refund, relink, publish, or finalize.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `21632` |
| Package ID | `foundation.security_monitoring.financial_grade.v1` |
| Artifact Type | `CATALOG` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `CATALOG_ONLY` |
| Owner | `Architecture / Security Foundation` |
| Dependencies | `21631`, `21630`, `21620`, `21610`, `21570`, `21560` |
| Provider Evidence Status | `APPLIES_IF_PROVIDER_RELATED` |
| i18n Requirement | `APPLIES_IF_ALERT_VISIBLE` |
| Audit Requirement | `REQUIRED_FOR_CONTAINMENT_TRIGGER_AND_RELEASE` |
| Security Requirement | `FINANCIAL_GRADE_CONTAINMENT_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_AUDIT_REVIEW_REQUIRED` |
| Blocker Status | `CONTAINMENT_CATALOG_REVIEW_REQUIRED` |

---

## 5. Containment Record Schema

Each containment rule must include:

| Field | Required Meaning |
|---|---|
| Containment Rule ID | Stable containment control id |
| Bulkhead | Affected compartment |
| Trigger Event | Event family or condition |
| Trigger Severity | Severity threshold |
| Containment Action | What is blocked or held |
| Scope | Tenant, store, device, session, provider, customer, order, payment, etc. |
| Alert Family | Alert generated |
| Log Requirement | Structured log requirement |
| Evidence Requirement | Evidence packet requirement |
| Audit Requirement | Audit event requirement |
| Customer Impact | None, possible, confirmed, blocked pending review |
| AI/pgvector Role | Advisory only or blocked |
| Release Authority | Who may release containment |
| Release Requirement | Evidence/review/audit requirement |
| Reconciliation Requirement | Whether reconciliation is required |
| False Positive Path | How containment is reversed if incorrect |
| Readiness Blocker | Blocker if undefined |

A containment rule without scope is unsafe.

---

## 6. Containment Status Catalog

| Status | Meaning |
|---|---|
| `CONTAINMENT_NOT_REQUIRED` | No containment needed |
| `CONTAINMENT_CANDIDATE` | Condition may require containment |
| `CONTAINMENT_PENDING_REVIEW` | Containment candidate awaiting decision |
| `CONTAINMENT_ACTIVE` | Containment is active |
| `CONTAINMENT_MUTATION_BLOCKED` | Mutating action is blocked |
| `CONTAINMENT_READ_ONLY_MODE` | Affected domain is read-only |
| `CONTAINMENT_EXTERNAL_INPUT_BLOCKED` | External input blocked |
| `CONTAINMENT_PROVIDER_CALLBACK_BLOCKED` | Provider callback blocked from mutation |
| `CONTAINMENT_TOKEN_INVALIDATED` | Token/session invalidated or held |
| `CONTAINMENT_VALUE_CHANGE_BLOCKED` | Value-bearing mutation blocked |
| `CONTAINMENT_IDENTITY_LINK_BLOCKED` | Identity link/relink blocked |
| `CONTAINMENT_PROJECTION_BLOCKED` | External projection blocked |
| `CONTAINMENT_AI_OUTPUT_BLOCKED` | AI output blocked |
| `CONTAINMENT_PGVECTOR_RETRIEVAL_BLOCKED` | Vector retrieval blocked |
| `CONTAINMENT_SUPPORT_ACTION_BLOCKED` | Support/admin action blocked |
| `CONTAINMENT_LEDGER_FINALIZATION_HELD` | Ledger finalization held |
| `CONTAINMENT_SETTLEMENT_ALLOCATION_HELD` | Settlement allocation held |
| `CONTAINMENT_RECONCILIATION_REQUIRED` | Reconciliation required before release |
| `CONTAINMENT_EVIDENCE_REQUIRED` | Evidence required before release |
| `CONTAINMENT_SECURITY_REVIEW_REQUIRED` | Security review required |
| `CONTAINMENT_LEGAL_REVIEW_REQUIRED` | Legal/compliance review required |
| `CONTAINMENT_RELEASE_PENDING` | Release requested and pending |
| `CONTAINMENT_RELEASED` | Released after authorized review |
| `CONTAINMENT_ESCALATED` | Escalated due to unresolved risk |
| `CONTAINMENT_FALSE_POSITIVE_REVIEW` | False-positive review opened |
| `CONTAINMENT_REOPENED` | Reopened after new evidence |

Containment states must not be collapsed into `blocked` or `done`.

---

## 7. Containment Action Catalog

| Action | Meaning |
|---|---|
| `AUTO_BLOCK_EXTERNAL_INPUT` | Block external event/input from applying |
| `AUTO_BLOCK_PROVIDER_CALLBACK_MUTATION` | Prevent callback from mutating state |
| `AUTO_INVALIDATE_SCOPED_TOKEN` | Invalidate or hold scoped token/session |
| `AUTO_HOLD_PAYMENT_STATE` | Hold payment state pending review |
| `AUTO_HOLD_LEDGER_FINALIZATION` | Hold ledger finalization |
| `AUTO_HOLD_SETTLEMENT_ALLOCATION` | Hold settlement allocation |
| `AUTO_BLOCK_VALUE_MUTATION` | Block points/coupon/wallet value mutation |
| `AUTO_BLOCK_IDENTITY_LINK` | Block identity link/relink |
| `AUTO_BLOCK_KDS_DUPLICATE_TICKET` | Block duplicate ticket creation |
| `AUTO_BLOCK_INVENTORY_PROJECTION` | Block unsafe availability projection |
| `AUTO_BLOCK_EXTERNAL_PROJECTION` | Block external publication/projection |
| `AUTO_BLOCK_SUPPORT_MUTATION` | Block support/admin mutation |
| `AUTO_BLOCK_AI_OUTPUT` | Block AI output from customer/support use |
| `AUTO_BLOCK_PGVECTOR_SOURCE_OR_RETRIEVAL` | Block vector source/retrieval |
| `AUTO_BLOCK_ARCHIVE_DELETE` | Block deletion or prune |
| `AUTO_ENTER_READ_ONLY_MODE` | Limit domain to read-only until review |
| `AUTO_REQUIRE_MANUAL_REVIEW` | Require review before action proceeds |

These are planning actions.

They do not implement runtime behavior.

---

## 8. Severity Threshold Rule

Containment should normally activate for:

| Severity | Default Containment Behavior |
|---|---|
| `INFO` | No containment |
| `NOTICE` | No containment unless repeated |
| `WARNING` | Containment candidate if repeated or value/identity/provider related |
| `HIGH_RISK` | Containment candidate or active containment depending on rule |
| `CRITICAL` | Immediate containment unless exception policy exists |
| `RECONCILIATION_REQUIRED` | Hold finalization or mutation if value/authority affected |
| `LEGAL_COMPLIANCE_REVIEW_REQUIRED` | Block customer-facing or deletion-sensitive action |
| `PROVIDER_REVIEW_REQUIRED` | Block provider-derived authority until evidence |
| `CUSTOMER_RECOVERY_REQUIRED` | Hold risky action and route support review |

Severity escalation may activate containment even when the initial event severity was lower.

---

## 9. External POS Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-POS-CROSS-STORE` | POS event maps to wrong store | `AUTO_BLOCK_EXTERNAL_INPUT` | Store/device/event |
| `CTRL-CONTAIN-POS-CROSS-TENANT` | POS event crosses tenant boundary | `AUTO_BLOCK_EXTERNAL_INPUT` | Tenant/store/event |
| `CTRL-CONTAIN-POS-TOKEN-SCOPE` | Token used outside scope | `AUTO_INVALIDATE_SCOPED_TOKEN` | Token/session/device |
| `CTRL-CONTAIN-POS-LOCAL-CACHE-TRUTH` | POS local cache treated as truth | `AUTO_REQUIRE_MANUAL_REVIEW` | Store/device |
| `CTRL-CONTAIN-POS-MALFORMED-BURST` | Repeated malformed POS events | `AUTO_BLOCK_EXTERNAL_INPUT` | Device/store |
| `CTRL-CONTAIN-POS-REPLAY` | POS event replay detected | `AUTO_BLOCK_EXTERNAL_INPUT` | Event/idempotency key |
| `CTRL-CONTAIN-POS-SANDBOX-ABNORMAL` | POS module abnormality | `AUTO_ENTER_READ_ONLY_MODE` | Device/store module |

POS containment must not directly mutate payment or ledger truth.

---

## 10. Provider Callback Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-PROVIDER-SIGNATURE-FAILED` | Callback signature failed | `AUTO_BLOCK_PROVIDER_CALLBACK_MUTATION` | Provider callback |
| `CTRL-CONTAIN-PROVIDER-REPLAY` | Callback replay detected | `AUTO_BLOCK_PROVIDER_CALLBACK_MUTATION` | Provider event id |
| `CTRL-CONTAIN-PROVIDER-UNMAPPED` | Callback cannot map internally | `AUTO_BLOCK_PROVIDER_CALLBACK_MUTATION` | Callback/payment |
| `CTRL-CONTAIN-PROVIDER-DUP-PAYLOAD` | Duplicate callback payload mismatch | `AUTO_BLOCK_PROVIDER_CALLBACK_MUTATION` | Idempotency key |
| `CTRL-CONTAIN-PROVIDER-CONTRACT-CHANGED` | Provider API contract changed | `AUTO_REQUIRE_MANUAL_REVIEW` | Provider/capability |
| `CTRL-CONTAIN-PROVIDER-CAPABILITY-UNVERIFIED` | Capability asserted without evidence | `AUTO_REQUIRE_MANUAL_REVIEW` | Provider/capability |
| `CTRL-CONTAIN-PROVIDER-SETTLEMENT-MISSING` | Settlement evidence missing | `AUTO_HOLD_SETTLEMENT_ALLOCATION` | Provider/period |

Provider containment preserves evidence-required state.

---

## 11. Payment Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-PAYMENT-STATE-UNCERTAIN` | Payment state uncertain | `AUTO_HOLD_PAYMENT_STATE` | Payment/order |
| `CTRL-CONTAIN-PAYMENT-DUP-CAPTURE` | Duplicate capture risk | `AUTO_HOLD_PAYMENT_STATE` | Payment/customer/order |
| `CTRL-CONTAIN-PAYMENT-REFUND-NO-AUTH` | Refund requested/executed without authority | `AUTO_BLOCK_SUPPORT_MUTATION` | Refund/payment |
| `CTRL-CONTAIN-PAYMENT-AMOUNT-MISMATCH` | Provider/internal amount mismatch | `AUTO_HOLD_PAYMENT_STATE` | Payment/order |
| `CTRL-CONTAIN-PAYMENT-CANCEL-CAPTURE` | POS cancelled but payment captured | `AUTO_REQUIRE_MANUAL_REVIEW` | Order/payment |
| `CTRL-CONTAIN-PAYMENT-CALLBACK-MISSING` | Internal payment exists but callback missing | `AUTO_REQUIRE_MANUAL_REVIEW` | Payment/provider |

Payment containment must route to finance/reconciliation.

---

## 12. Ledger And Settlement Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-LEDGER-IMBALANCE` | Double-entry imbalance | `AUTO_HOLD_LEDGER_FINALIZATION` | Ledger entry/batch |
| `CTRL-CONTAIN-LEDGER-EVIDENCE-MISSING` | Ledger entry lacks evidence | `AUTO_HOLD_LEDGER_FINALIZATION` | Ledger entry |
| `CTRL-CONTAIN-SETTLEMENT-MISMATCH` | Settlement mismatch | `AUTO_HOLD_SETTLEMENT_ALLOCATION` | Settlement period/provider |
| `CTRL-CONTAIN-FX-EVIDENCE-MISSING` | Exchange-rate evidence missing | `AUTO_HOLD_SETTLEMENT_ALLOCATION` | Overseas payment/period |
| `CTRL-CONTAIN-REFUND-ADJUSTMENT-MISSING` | Refund without ledger adjustment | `AUTO_HOLD_LEDGER_FINALIZATION` | Refund/ledger |
| `CTRL-CONTAIN-PARTNER-REPORT-MISSING` | Partner report missing | `AUTO_HOLD_SETTLEMENT_ALLOCATION` | Partner/period |

Ledger containment must not create corrections automatically.

---

## 13. Membership Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-MEMBERSHIP-IDENTITY-CONFLICT` | Identity conflict | `AUTO_BLOCK_VALUE_MUTATION` | Customer/account |
| `CTRL-CONTAIN-MEMBERSHIP-DUPLICATE` | Duplicate account candidate | `AUTO_REQUIRE_MANUAL_REVIEW` | Customer/account |
| `CTRL-CONTAIN-MEMBERSHIP-POINT-MISMATCH` | Point mismatch | `AUTO_BLOCK_VALUE_MUTATION` | Customer/store |
| `CTRL-CONTAIN-MEMBERSHIP-GRADE-MISMATCH` | Grade mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Customer |
| `CTRL-CONTAIN-MEMBERSHIP-BENEFIT-CONFLICT` | Benefit rule conflict | `AUTO_BLOCK_VALUE_MUTATION` | Benefit/customer |
| `CTRL-CONTAIN-MEMBERSHIP-CONSENT-MISSING` | Consent missing | `AUTO_BLOCK_IDENTITY_LINK` | Customer/link |

Membership containment must not silently adjust points or grade.

---

## 14. Coupon Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-COUPON-DUPLICATE-USE` | Duplicate coupon use risk | `AUTO_BLOCK_VALUE_MUTATION` | Coupon/customer/order |
| `CTRL-CONTAIN-COUPON-RULE-MISMATCH` | Coupon rule mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Campaign/coupon |
| `CTRL-CONTAIN-COUPON-PARTNER-STALE` | Partner coupon sync stale | `AUTO_REQUIRE_MANUAL_REVIEW` | Coupon/partner |
| `CTRL-CONTAIN-COUPON-CAMPAIGN-CONFLICT` | Campaign conflict | `AUTO_BLOCK_VALUE_MUTATION` | Campaign |

Coupon containment must preserve idempotency and evidence.

---

## 15. Wallet Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-WALLET-DUP-CHARGE` | Duplicate charge risk | `AUTO_BLOCK_VALUE_MUTATION` | Wallet/customer/payment |
| `CTRL-CONTAIN-WALLET-DUP-USE` | Duplicate use risk | `AUTO_BLOCK_VALUE_MUTATION` | Wallet/customer/order |
| `CTRL-CONTAIN-WALLET-BALANCE-MISMATCH` | Balance mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Wallet/customer |
| `CTRL-CONTAIN-WALLET-UNAUTH-ADJUSTMENT` | Unauthorized adjustment | `AUTO_BLOCK_VALUE_MUTATION` | Wallet/adjustment |
| `CTRL-CONTAIN-WALLET-REFUND-MISMATCH` | Refund mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Wallet/refund |

Wallet containment must not silently correct balances.

---

## 16. Identity Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-IDENTITY-WRONG-ACCOUNT` | Wrong account risk | `AUTO_BLOCK_IDENTITY_LINK` | Customer/account |
| `CTRL-CONTAIN-IDENTITY-CONSENT-MISSING` | Consent missing | `AUTO_BLOCK_IDENTITY_LINK` | Customer/link |
| `CTRL-CONTAIN-IDENTITY-DUP-CANDIDATE` | Duplicate identity candidate | `AUTO_REQUIRE_MANUAL_REVIEW` | Customer |
| `CTRL-CONTAIN-IDENTITY-PARTNER-MISMATCH` | Partner identity mismatch | `AUTO_BLOCK_IDENTITY_LINK` | Partner/customer |
| `CTRL-CONTAIN-IDENTITY-PRIVACY-RISK` | Privacy review required | `AUTO_REQUIRE_MANUAL_REVIEW` | Customer/context |

Identity containment requires privacy/support/legal review.

---

## 17. KDS Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-KDS-DUP-TICKET` | Duplicate KDS ticket risk | `AUTO_BLOCK_KDS_DUPLICATE_TICKET` | Order/ticket |
| `CTRL-CONTAIN-KDS-ORDER-PAYMENT-MISMATCH` | KDS/payment/order mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Order/payment/ticket |
| `CTRL-CONTAIN-KDS-UNAVAILABLE-ITEM` | KDS accepted unavailable item | `AUTO_REQUIRE_MANUAL_REVIEW` | Order/item |
| `CTRL-CONTAIN-KDS-MANUAL-NO-EVIDENCE` | Manual fallback without evidence | `AUTO_REQUIRE_MANUAL_REVIEW` | Ticket/store |
| `CTRL-CONTAIN-KDS-ROUTE-FAILED` | Station route failed repeatedly | `AUTO_REQUIRE_MANUAL_REVIEW` | Store/station |

KDS containment does not approve refunds or settlement changes.

---

## 18. Inventory Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-INVENTORY-STOCK-MISMATCH` | Stock mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Store/item |
| `CTRL-CONTAIN-INVENTORY-AVAILABILITY-MISMATCH` | Availability mismatch | `AUTO_BLOCK_INVENTORY_PROJECTION` | Store/item |
| `CTRL-CONTAIN-INVENTORY-SUPPLIER-QUALITY` | Supplier quality issue | `AUTO_REQUIRE_MANUAL_REVIEW` | Supplier/item/batch |
| `CTRL-CONTAIN-INVENTORY-WASTE-EVIDENCE-MISSING` | Waste evidence missing | `AUTO_REQUIRE_MANUAL_REVIEW` | Store/item |
| `CTRL-CONTAIN-INVENTORY-PROJECTION-RISK` | Projection would show unavailable item | `AUTO_BLOCK_INVENTORY_PROJECTION` | Store/item/projection |

Inventory containment may block projection but not silently adjust stock.

---

## 19. Content And i18n Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-I18N-MISSING-CUSTOMER-KEY` | Customer-visible key missing | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Locale/content |
| `CTRL-CONTAIN-I18N-HARDCODED-STRING` | Hardcoded operational string detected | `AUTO_REQUIRE_MANUAL_REVIEW` | Surface/code artifact |
| `CTRL-CONTAIN-CONTENT-TRACE-MISSING` | Source trace missing | `AUTO_REQUIRE_MANUAL_REVIEW` | Content key |
| `CTRL-CONTAIN-CONTENT-UNAPPROVED` | Unapproved content used | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Content/surface |
| `CTRL-CONTAIN-ALLERGEN-TEXT-MISMATCH` | Allergen text mismatch | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Menu item/locale |
| `CTRL-CONTAIN-TRANSLATION-UNAPPROVED` | Translation unapproved | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Locale/content |

Customer-facing content risks must block publication until review.

---

## 20. External Projection Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-PROJECTION-PRICE-MISMATCH` | Price mismatch | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Store/item/provider |
| `CTRL-CONTAIN-PROJECTION-ALLERGEN-MISMATCH` | Allergen mismatch | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Store/item/locale |
| `CTRL-CONTAIN-PROJECTION-AVAILABILITY-MISMATCH` | Availability mismatch | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Store/item |
| `CTRL-CONTAIN-PROJECTION-PAYMENT-UNVERIFIED` | Payment capability unverified | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Provider/capability |
| `CTRL-CONTAIN-PROJECTION-IDENTITY-RISK` | Customer identity sharing risk | `AUTO_BLOCK_EXTERNAL_PROJECTION` | Provider/customer |
| `CTRL-CONTAIN-PROJECTION-STALE` | Projection stale beyond threshold | `AUTO_REQUIRE_MANUAL_REVIEW` | Provider/store |

Projection containment prevents public/customer-facing wrong state.

---

## 21. Support/Admin Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-SUPPORT-UNAUTH-MUTATION` | Unauthorized mutation attempt | `AUTO_BLOCK_SUPPORT_MUTATION` | User/action |
| `CTRL-CONTAIN-SUPPORT-REFUND-NO-EVIDENCE` | Refund request without evidence | `AUTO_BLOCK_SUPPORT_MUTATION` | Case/refund |
| `CTRL-CONTAIN-SUPPORT-UNMASKING-NO-AUTH` | Unmasking without authority | `AUTO_BLOCK_SUPPORT_MUTATION` | User/case |
| `CTRL-CONTAIN-SUPPORT-EXPORT-RISK` | Restricted export risk | `AUTO_BLOCK_SUPPORT_MUTATION` | Export/request |
| `CTRL-CONTAIN-SUPPORT-AI-DRAFT-SENT` | AI draft sent without approval | `AUTO_BLOCK_AI_OUTPUT` | Case/message |
| `CTRL-CONTAIN-SUPPORT-CASE-CLOSE-MISSING-EVIDENCE` | Case closure missing evidence | `AUTO_BLOCK_SUPPORT_MUTATION` | Case |

Support containment must preserve audit and evidence.

---

## 22. AI Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-AI-RESTRICTED-SOURCE` | AI requests restricted source | `AUTO_BLOCK_AI_OUTPUT` | AI request |
| `CTRL-CONTAIN-AI-UNTRACEABLE` | AI output lacks traceability | `AUTO_BLOCK_AI_OUTPUT` | AI output |
| `CTRL-CONTAIN-AI-CUSTOMER-UNAPPROVED` | Customer-facing AI output unapproved | `AUTO_BLOCK_AI_OUTPUT` | Surface/customer |
| `CTRL-CONTAIN-AI-PROVIDER-INVENTION` | AI asserts provider capability | `AUTO_BLOCK_AI_OUTPUT` | Provider/capability |
| `CTRL-CONTAIN-AI-AUTHORITY-OVERREACH` | AI attempts authority action | `AUTO_BLOCK_AI_OUTPUT` | AI action |
| `CTRL-CONTAIN-AI-EVIDENCE-MISUSE` | AI summary treated as original evidence | `AUTO_REQUIRE_MANUAL_REVIEW` | Evidence/case |

AI containment protects every other bulkhead.

---

## 23. pgvector Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-PGVECTOR-UNAPPROVED-SOURCE` | Unapproved vector source | `AUTO_BLOCK_PGVECTOR_SOURCE_OR_RETRIEVAL` | Source item |
| `CTRL-CONTAIN-PGVECTOR-TRACE-MISSING` | Traceability missing | `AUTO_BLOCK_PGVECTOR_SOURCE_OR_RETRIEVAL` | Vector item |
| `CTRL-CONTAIN-PGVECTOR-RESTRICTED-DATA` | Restricted data vectorization risk | `AUTO_BLOCK_PGVECTOR_SOURCE_OR_RETRIEVAL` | Source/vector |
| `CTRL-CONTAIN-PGVECTOR-CROSS-TENANT` | Cross-tenant retrieval risk | `AUTO_BLOCK_PGVECTOR_SOURCE_OR_RETRIEVAL` | Query/result |
| `CTRL-CONTAIN-PGVECTOR-AUTHORITY-MISUSE` | Similarity used as truth | `AUTO_REQUIRE_MANUAL_REVIEW` | Review/action |
| `CTRL-CONTAIN-PGVECTOR-STALE` | Stale vector used | `AUTO_REQUIRE_MANUAL_REVIEW` | Vector/source |

pgvector containment prevents vector memory from becoming authority.

---

## 24. Tenant And Store Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-TENANT-CROSS-ACCESS` | Cross-tenant access risk | `AUTO_BLOCK_EXTERNAL_INPUT` | Tenant/user/request |
| `CTRL-CONTAIN-TENANT-VECTOR-LEAK` | Cross-tenant vector retrieval | `AUTO_BLOCK_PGVECTOR_SOURCE_OR_RETRIEVAL` | Tenant/vector query |
| `CTRL-CONTAIN-TENANT-ARCHIVE-LEAK` | Cross-tenant archive access | `AUTO_BLOCK_ARCHIVE_DELETE` or access block | Archive/request |
| `CTRL-CONTAIN-STORE-CROSS-EVENT` | Cross-store event risk | `AUTO_BLOCK_EXTERNAL_INPUT` | Store/event |
| `CTRL-CONTAIN-STORE-POS-MISMATCH` | POS mapped to wrong store | `AUTO_BLOCK_EXTERNAL_INPUT` | Store/device |

Tenant and store containment is critical and must escalate.

---

## 25. Archive And Retention Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-ARCHIVE-VERIFY-FAILED` | Archive verification failed | `AUTO_REQUIRE_MANUAL_REVIEW` | Archive object |
| `CTRL-CONTAIN-ARCHIVE-MANIFEST-MISSING` | Manifest missing | `AUTO_REQUIRE_MANUAL_REVIEW` | Archive object |
| `CTRL-CONTAIN-ARCHIVE-LEGAL-HOLD` | Deletion attempted during legal hold | `AUTO_BLOCK_ARCHIVE_DELETE` | Archive/legal hold |
| `CTRL-CONTAIN-ARCHIVE-CROSS-TENANT` | Cross-tenant retrieval risk | `AUTO_REQUIRE_MANUAL_REVIEW` | Archive request |
| `CTRL-CONTAIN-ARCHIVE-VECTOR-CONFLICT` | Vector depends on deleted/anonymized source | `AUTO_BLOCK_PGVECTOR_SOURCE_OR_RETRIEVAL` | Vector/source |
| `CTRL-CONTAIN-ARCHIVE-RESTORE-MUTATION` | Restore attempts runtime mutation | `AUTO_REQUIRE_MANUAL_REVIEW` | Restore job |

Archive containment prevents data governance failure.

---

## 26. Workforce HR Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-HR-ROLE-MISMATCH` | Role/permission mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Employee/role |
| `CTRL-CONTAIN-HR-ELIGIBILITY-RISK` | Eligibility review required | `AUTO_REQUIRE_MANUAL_REVIEW` | Employee |
| `CTRL-CONTAIN-HR-ATTENDANCE-DUP` | Duplicate attendance event | `AUTO_REQUIRE_MANUAL_REVIEW` | Employee/shift |
| `CTRL-CONTAIN-HR-UNMAPPED-ATTENDANCE` | Attendance event unmapped | `AUTO_REQUIRE_MANUAL_REVIEW` | Employee/store |
| `CTRL-CONTAIN-HR-PAYROLL-ADJACENT` | Payroll-adjacent mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Employee/payroll-adjacent |

HR containment must not make legal/employment conclusions automatically.

---

## 27. Supplier SCM WMS Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-SCM-QUALITY-ISSUE` | Supplier quality issue | `AUTO_REQUIRE_MANUAL_REVIEW` | Supplier/item/batch |
| `CTRL-CONTAIN-SCM-DELIVERY-MISMATCH` | Delivery mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Delivery/order |
| `CTRL-CONTAIN-WMS-STOCK-MISMATCH` | WMS stock mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Item/location |
| `CTRL-CONTAIN-SCM-SUPPLIER-CLAIM` | Supplier claim lacks receiving evidence | `AUTO_REQUIRE_MANUAL_REVIEW` | Supplier/order |
| `CTRL-CONTAIN-QC-SAFETY-RISK` | QC/safety risk | `AUTO_REQUIRE_MANUAL_REVIEW` | Item/batch/store |

SCM containment must preserve receiving/QC evidence.

---

## 28. Franchise OS Containment Rules

| Rule ID | Trigger | Containment Action | Scope |
|---|---|---|---|
| `CTRL-CONTAIN-FRANCHISE-POLICY-MISMATCH` | Policy version mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Tenant/store/policy |
| `CTRL-CONTAIN-FRANCHISE-ROYALTY-CONFLICT` | Royalty rule conflict | `AUTO_HOLD_SETTLEMENT_ALLOCATION` | Franchise/period |
| `CTRL-CONTAIN-FRANCHISE-LEGAL-ENTITY-MISMATCH` | Legal entity mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Store/legal entity |
| `CTRL-CONTAIN-FRANCHISE-MENU-POLICY` | Menu policy mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Store/menu |
| `CTRL-CONTAIN-FRANCHISE-SYNC-MISMATCH` | Store sync mismatch | `AUTO_REQUIRE_MANUAL_REVIEW` | Store/tenant |

Franchise containment must preserve HQ/legal/finance review.

---

## 29. Containment Alert Mapping

Each containment must map to one or more alert families.

| Containment Category | Alert Family |
|---|---|
| POS containment | `ALERT_SECURITY_BULKHEAD_CONTAINMENT_ACTIVE`, `ALERT_POS_*` |
| Provider containment | `ALERT_PROVIDER_*`, `ALERT_SECURITY_PROVIDER_CALLBACK_QUARANTINED` |
| Payment containment | `ALERT_PAYMENT_*` |
| Ledger containment | `ALERT_SETTLEMENT_*`, `ALERT_LEDGER_*` |
| Membership containment | `ALERT_MEMBERSHIP_*` |
| Coupon containment | `ALERT_COUPON_*` |
| Wallet containment | `ALERT_WALLET_*` |
| Identity containment | `ALERT_IDENTITY_*` |
| KDS containment | `ALERT_KDS_*` |
| Inventory containment | `ALERT_INVENTORY_*` |
| Content/i18n containment | `ALERT_CONTENT_*`, `ALERT_I18N_*` |
| Projection containment | `ALERT_PROJECTION_*` |
| Support/admin containment | `ALERT_SUPPORT_*` |
| AI containment | `ALERT_AI_*` |
| pgvector containment | `ALERT_PGVECTOR_*` |
| Tenant/store containment | `ALERT_SECURITY_TENANT_BOUNDARY_RISK`, `ALERT_SECURITY_STORE_BOUNDARY_RISK` |
| Archive containment | `ALERT_ARCHIVE_*` |

Alert details must use i18n/message keys.

---

## 30. Release Authority Catalog

| Containment Domain | Release Authority |
|---|---|
| POS | Security/platform review |
| Provider | Provider/security review |
| Payment | Finance/provider/security review |
| Ledger | Finance/reconciliation review |
| Membership | Membership/support/privacy review |
| Coupon | CRM/support review |
| Wallet | Finance/support review |
| Identity | Privacy/support/legal review |
| KDS | Store ops/support review |
| Inventory | Store/inventory/QC review |
| Content/i18n | Content/localization/support review |
| Projection | Projection/content/legal review |
| Support/admin | Support lead/security/legal review |
| AI | AI governance/security review |
| pgvector | AI/security/data governance review |
| Tenant/store | Security/HQ review |
| Archive/retention | Data governance/security/legal review |
| Workforce/HR | HR/security/legal review |
| SCM/WMS | SCM/QC/store review |
| Franchise OS | Franchise/HQ/finance/legal review |

The daemon may not release containment.

AI may not release containment.

pgvector may not release containment.

---

## 31. Containment Evidence Requirements

Containment requires evidence when it affects:

- value
- identity
- payment
- settlement
- customer-facing projection
- support/admin authority
- legal/compliance
- provider capability
- security boundary
- tenant/store boundary
- AI/pgvector misuse
- archive/legal hold
- workforce/legal eligibility
- QC/safety

Evidence may include:

- event log
- audit signal
- provider callback metadata
- settlement report
- support case record
- consent record
- archive manifest
- vector source metadata
- daemon incident report draft
- manual review note
- customer recovery record

AI summaries are derived evidence only.

---

## 32. Containment Audit Requirements

Audit is required for:

- containment activation
- containment escalation
- containment release request
- containment release approval
- false-positive release
- manual override
- value-bearing block
- identity block
- payment/ledger hold
- provider callback block
- support/admin block
- archive deletion block
- AI output block
- pgvector retrieval/source block
- tenant/store boundary block

Containment audit must include actor/system actor, trigger, scope, reason, evidence, and release authority.

---

## 33. False Positive Handling

False positives are expected.

False-positive handling must define:

- containment id
- affected scope
- trigger event
- evidence reviewed
- reviewer
- release decision
- reason code
- customer/store impact
- rule tuning recommendation
- audit event
- alert closure or reopen rule

False-positive handling must not train the system to ignore critical risks without review.

---

## 34. Containment Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-CONTAINMENT-CATALOG-0001` | Containment catalog not reviewed |
| `BLOCKER-CONTAINMENT-STATUS-0001` | Containment status catalog incomplete |
| `BLOCKER-CONTAINMENT-ACTION-0001` | Containment action catalog incomplete |
| `BLOCKER-CONTAINMENT-SCOPE-0001` | Containment scope missing |
| `BLOCKER-CONTAINMENT-ALERT-0001` | Containment alert mapping missing |
| `BLOCKER-CONTAINMENT-EVIDENCE-0001` | Containment evidence rule missing |
| `BLOCKER-CONTAINMENT-AUDIT-0001` | Containment audit rule missing |
| `BLOCKER-CONTAINMENT-RELEASE-0001` | Release authority missing |
| `BLOCKER-CONTAINMENT-FALSE-POSITIVE-0001` | False-positive handling missing |
| `BLOCKER-CONTAINMENT-AI-PGVECTOR-0001` | AI/pgvector release prohibition missing |

Open containment blockers prevent runtime containment implementation.

---

## 35. Validation Checklist

Validation must confirm:

- every containment rule has a rule id
- every containment rule maps to a bulkhead
- every containment rule has a trigger
- every containment rule has scope
- every containment rule has action
- every containment rule has alert mapping
- every containment rule has audit/evidence requirement
- every containment rule has release authority
- every value-bearing containment blocks mutation, not silently corrects
- every identity containment blocks linking, not silently merges
- every provider containment preserves evidence-required status
- every AI containment blocks output, not decides truth
- every pgvector containment blocks source/retrieval, not decides truth
- containment does not equal resolution
- daemon cannot release containment
- AI cannot release containment
- pgvector cannot release containment

---

## 36. Relationship To Previous Documents

This document implements Artifact Group B from:

- `21630 Financial-Grade Security Monitoring Foundation Catalog Execution Plan And Artifact Map`

It follows:

- `21631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`

It depends on:

- `21570 Financial-Grade Security Foundation Control Catalog And Bulkhead Readiness Policy`
- `21580 AI Daemon Security Monitoring Agent And Autonomous Containment Policy`
- `21590 Trigger View Agent Monitoring Pipeline And Audit Projection Policy`
- `21620 Financial-Grade Security Monitoring Catalog Work Order And Implementation Handoff Policy`

This document is Foundation-grade and catalog-only.

It does not authorize coding.

---

## 37. Final Rule

Containment is the automatic defensive wall that prevents one compromised, uncertain, duplicated, stale, or mismatched domain from infecting another domain.

Containment may block, hold, invalidate, quarantine-adjacent, or force review.

Containment must never silently correct, delete, compensate, refund, relink, publish, finalize, or resolve.

Every containment action must be scoped, logged, alertable, evidenced where required, audited where required, releasable only through authority, and protected from AI/pgvector autonomous release.

Coding remains deferred until this containment catalog is reviewed, validated, and attached to package-specific entry gates.
