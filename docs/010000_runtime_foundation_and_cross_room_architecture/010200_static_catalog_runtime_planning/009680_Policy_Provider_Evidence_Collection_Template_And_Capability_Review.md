# 009680_Policy_Provider_Evidence_Collection_Template_And_Capability_Review

## 1. Purpose

This document defines the provider evidence collection template and capability review policy for Catch & Order, Catch Menu, and the Financial-Grade Security Monitoring Foundation.

The previous artifact `09670` defined Catch Menu as the customer-facing menu access surface and established customer-visible projection and i18n boundaries.

This document defines how external provider capabilities must be collected, verified, classified, reviewed, and carried into future integration packages before any provider-specific functionality is treated as available.

Provider capability is not assumed.

Provider documentation is evidence candidate.

Provider sandbox behavior is not production proof.

Provider marketing claims are not integration truth.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to external providers and partners related to:

1. POS vendors
2. KDS vendors
3. Payment providers
4. Global payment providers
5. QR/NFC entry providers
6. Table-order providers
7. Menu projection providers
8. Reservation/waiting providers
9. Delivery/order aggregation providers
10. Map/search providers
11. Messaging providers
12. Authentication providers
13. Identity verification providers
14. Archive/storage providers
15. AI providers
16. Embedding/vector providers
17. Monitoring/alert providers
18. Franchise OS partner systems
19. Workforce/job-board providers
20. SCM/WMS/supplier providers

This document does not verify any specific provider.

It defines the evidence template required before provider capability can be used in architecture or implementation.

---

## 3. Core Principle

External provider capability must be treated as:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

until verified.

The correct rule is:

Collect evidence.
Classify capability.
Verify behavior.
Test sandbox.
Confirm production difference.
Map security controls.
Map failure codes.
Map legal/contract restrictions.
Only then allow package-specific integration planning.

A provider is not trusted because it is popular.

A provider is trusted only inside a reviewed capability boundary.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09680` |
| Package ID | `provider.evidence_collection.capability_review.v1` |
| Artifact Type | `PROVIDER_EVIDENCE_COLLECTION_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `EVIDENCE_POLICY_ONLY` |
| Owner | `Architecture / Provider Ops / Security Foundation / Legal` |
| Dependencies | `09560` to `09670` |
| Provider Evidence Status | `REQUIRED` |
| i18n Requirement | `APPLIES_IF_PROVIDER_CAPABILITY_VISIBLE_TO_CUSTOMER` |
| Audit Requirement | `REQUIRED_FOR_PROVIDER_CAPABILITY_ACCEPTANCE` |
| Security Requirement | `PROVIDER_CAPABILITY_EVIDENCE_REQUIRED` |
| Review Requirement | `ARCHITECTURE_SECURITY_PROVIDER_LEGAL_REVIEW_REQUIRED` |
| Blocker Status | `PROVIDER_EVIDENCE_TEMPLATE_REVIEW_REQUIRED` |

---

## 5. Provider Evidence Status Catalog

| Status | Meaning |
|---|---|
| `CAPABILITY_UNKNOWN` | Capability not investigated |
| `CAPABILITY_CLAIMED_BY_VENDOR` | Vendor claims capability |
| `CAPABILITY_DOC_FOUND` | Documentation found |
| `CAPABILITY_DOC_REVIEW_PENDING` | Documentation review pending |
| `CAPABILITY_SANDBOX_TEST_PENDING` | Sandbox test pending |
| `CAPABILITY_SANDBOX_CONFIRMED` | Confirmed in sandbox only |
| `CAPABILITY_PRODUCTION_CONFIRMATION_PENDING` | Production confirmation pending |
| `CAPABILITY_PRODUCTION_CONFIRMED` | Confirmed in production |
| `CAPABILITY_CONTRACT_REVIEW_REQUIRED` | Contract/legal review required |
| `CAPABILITY_SECURITY_REVIEW_REQUIRED` | Security review required |
| `CAPABILITY_LIMITED_SUPPORT` | Supported with limitation |
| `CAPABILITY_UNSUPPORTED` | Not supported |
| `CAPABILITY_BLOCKED` | Blocked due to risk |
| `CAPABILITY_DEPRECATED` | No longer safe/current |
| `CAPABILITY_PROVIDER_EVIDENCE_REQUIRED` | Evidence required before use |

Default status:

`CAPABILITY_PROVIDER_EVIDENCE_REQUIRED`

---

## 6. Provider Record Schema

Every provider record must include:

| Field | Required Meaning |
|---|---|
| `provider_id` | Stable provider id |
| `provider_name` | Provider name |
| `provider_category` | POS, payment, KDS, map, etc. |
| `provider_region` | Korea, global, etc. |
| `provider_contact_status` | Contact/documentation status |
| `documentation_refs` | Documentation links/files |
| `contract_refs` | Contract/legal references if any |
| `sandbox_access_status` | Sandbox availability |
| `production_access_status` | Production access status |
| `capability_records` | Capability review records |
| `security_class` | Security classification |
| `data_class` | Data sensitivity class |
| `callback_support` | Callback/webhook support |
| `signature_support` | Signature verification support |
| `idempotency_support` | Idempotency behavior |
| `replay_protection_support` | Replay protection behavior |
| `rate_limit_policy` | Rate limit information |
| `error_code_policy` | Provider error code behavior |
| `settlement_report_support` | Settlement/reporting behavior |
| `refund_cancel_support` | Refund/cancel behavior |
| `data_retention_policy` | Provider-side retention |
| `privacy_policy_status` | Privacy review status |
| `review_owner` | Provider review owner |
| `evidence_status` | Overall evidence status |
| `blockers` | Open blockers |

Provider record without capability records is incomplete.

---

## 7. Capability Record Schema

Every provider capability must be recorded separately.

| Field | Required Meaning |
|---|---|
| `capability_id` | Stable capability id |
| `provider_id` | Provider reference |
| `capability_name` | Specific capability |
| `capability_category` | Payment, callback, POS event, KDS ticket, etc. |
| `claim_source` | Vendor doc, email, API test, contract, etc. |
| `claim_text_summary` | Summary of claim |
| `evidence_refs` | Evidence source references |
| `sandbox_test_status` | Sandbox test result |
| `production_test_status` | Production test result |
| `security_review_status` | Security review |
| `legal_review_status` | Legal/contract review |
| `data_scope` | Data touched by capability |
| `authority_scope` | What authority the capability may affect |
| `failure_modes` | Known failure modes |
| `error_codes` | Provider/internal error mapping |
| `reconciliation_requirement` | Reconciliation required or not |
| `customer_visibility` | Whether customer sees result |
| `i18n_requirement` | Whether visible text required |
| `approved_use` | Allowed use |
| `prohibited_use` | Prohibited use |
| `status` | Capability evidence status |
| `review_date` | Last review date |
| `review_owner` | Review owner |

Capability must be narrow.

Do not record “provider supports everything” as one capability.

---

## 8. Provider Category Catalog

| Provider Category | Meaning |
|---|---|
| `PROVIDER_POS` | POS vendor or POS integration provider |
| `PROVIDER_KDS` | Kitchen display/ticket provider |
| `PROVIDER_PAYMENT` | Domestic payment provider |
| `PROVIDER_GLOBAL_PAYMENT` | Global/international payment provider |
| `PROVIDER_MENU` | Menu projection provider |
| `PROVIDER_TABLE_ORDER` | Table order provider |
| `PROVIDER_WAITING_RESERVATION` | Waiting/reservation provider |
| `PROVIDER_DELIVERY` | Delivery/order aggregation provider |
| `PROVIDER_MAP_SEARCH` | Map/search/menu exposure provider |
| `PROVIDER_MESSAGING` | SMS/Kakao/Push/email provider |
| `PROVIDER_AUTH_IDENTITY` | Auth/identity verification provider |
| `PROVIDER_ARCHIVE_STORAGE` | Archive/storage provider |
| `PROVIDER_AI` | AI/LLM provider |
| `PROVIDER_EMBEDDING_VECTOR` | Embedding/vector provider |
| `PROVIDER_MONITORING_ALERT` | Monitoring/alert provider |
| `PROVIDER_WORKFORCE_JOB` | Job board/workforce provider |
| `PROVIDER_SCM_WMS` | Supplier/SCM/WMS provider |
| `PROVIDER_FRANCHISE_OS_PARTNER` | Franchise OS partner system |

Each category imports different Foundation controls.

---

## 9. Required Evidence Types

| Evidence Type | Meaning |
|---|---|
| `EVIDENCE_OFFICIAL_DOC` | Official API/product documentation |
| `EVIDENCE_CONTRACT` | Contract or service terms |
| `EVIDENCE_VENDOR_EMAIL` | Written vendor confirmation |
| `EVIDENCE_SANDBOX_TEST` | Sandbox test result |
| `EVIDENCE_PRODUCTION_TEST` | Production test result |
| `EVIDENCE_API_RESPONSE_SAMPLE` | API response sample |
| `EVIDENCE_CALLBACK_SAMPLE` | Callback/webhook sample |
| `EVIDENCE_ERROR_SAMPLE` | Error response sample |
| `EVIDENCE_SETTLEMENT_REPORT_SAMPLE` | Settlement/report sample |
| `EVIDENCE_SECURITY_DOC` | Security documentation |
| `EVIDENCE_PRIVACY_POLICY` | Privacy/data processing policy |
| `EVIDENCE_RATE_LIMIT_DOC` | Rate limit policy |
| `EVIDENCE_INCIDENT_HISTORY` | Known incident/history review |
| `EVIDENCE_INTERNAL_TEST_NOTE` | Internal test note |
| `EVIDENCE_LEGAL_REVIEW_NOTE` | Legal review note |

At least one official or directly verified evidence source is required for critical capabilities.

---

## 10. Provider Trust Level Catalog

| Trust Level | Meaning |
|---|---|
| `TRUST_PROVIDER_UNREVIEWED` | Provider not reviewed |
| `TRUST_PROVIDER_DOC_ONLY` | Documentation only |
| `TRUST_PROVIDER_SANDBOX_ONLY` | Sandbox confirmed only |
| `TRUST_PROVIDER_LIMITED_PRODUCTION` | Limited production confirmation |
| `TRUST_PROVIDER_PRODUCTION_VERIFIED` | Production verified |
| `TRUST_PROVIDER_CONTRACT_BOUND` | Contract reviewed |
| `TRUST_PROVIDER_SECURITY_REVIEWED` | Security reviewed |
| `TRUST_PROVIDER_FINANCIAL_REVIEWED` | Financial/reconciliation reviewed |
| `TRUST_PROVIDER_BLOCKED` | Provider blocked |
| `TRUST_PROVIDER_DEPRECATED` | Provider deprecated |

Provider trust is capability-specific.

One verified capability does not verify all capabilities.

---

## 11. POS Provider Evidence Requirements

For POS providers, collect evidence for:

- order create/accept behavior
- order cancel behavior
- order update behavior
- payment state exposure
- refund/cancel linkage
- device/session identity
- store mapping
- tenant/franchise mapping
- offline/local cache behavior
- duplicate order handling
- idempotency support
- callback/webhook support
- error codes
- rate limits
- sandbox behavior
- production behavior
- data export/report behavior
- contract restrictions

Critical rule:

POS accepted order is not payment confirmed order.

---

## 12. Payment Provider Evidence Requirements

For payment providers, collect evidence for:

- payment authorization
- capture
- cancel
- refund
- partial refund
- duplicate request behavior
- idempotency key support
- callback/webhook signature
- replay prevention
- settlement report
- fee report
- chargeback/dispute handling
- foreign/global payment support
- currency/FX handling
- sandbox/production difference
- PCI/security obligations
- data retention
- error code behavior
- rate limits
- legal/contract limits

Critical rule:

Payment state must be provider-verified and internally reconciled.

---

## 13. Global Payment Evidence Requirements

For global payment providers, collect additional evidence for:

- supported countries
- supported currencies
- Alipay/WeChat/UnionPay or other method support
- Korean merchant eligibility
- settlement currency
- FX rate source
- fee structure
- refund/cancel behavior across borders
- customer receipt language
- dispute process
- identity/KYC requirement
- prohibited business categories
- tax/reporting limitations
- legal restrictions
- production onboarding requirements

Do not claim global payment capability until evidence is reviewed.

---

## 14. KDS Provider Evidence Requirements

For KDS providers, collect evidence for:

- ticket create behavior
- ticket update behavior
- ticket cancel/void behavior
- remake behavior
- station routing
- item-level status
- order-level status
- duplicate ticket handling
- offline behavior
- manual fallback behavior
- POS mapping
- payment state visibility if any
- API or file integration
- device/session identity
- error codes
- sandbox availability

Critical rule:

KDS status is kitchen execution status, not financial authority.

---

## 15. Menu Projection Provider Evidence Requirements

For menu/search/map/external projection providers, collect evidence for:

- menu item sync
- price sync
- availability sync
- sold-out sync
- allergen text support
- multilingual content support
- image support
- promotion/coupon display
- external order link support
- stale content handling
- update latency
- provider review/moderation rules
- data ownership
- deletion/update behavior
- API limits
- error codes

Critical rule:

External projection is not source of truth.

---

## 16. Messaging Provider Evidence Requirements

For messaging providers, collect evidence for:

- SMS/Kakao/push/email support
- template approval requirement
- multilingual message support
- delivery status callback
- retry behavior
- rate limits
- opt-in/opt-out requirements
- privacy policy
- message log retention
- legal advertising requirements
- customer support implications
- failure/error codes

Critical rule:

Customer-visible messages require i18n/content approval and legal review where applicable.

---

## 17. AI Provider Evidence Requirements

For AI providers, collect evidence for:

- model/provider identity
- data retention policy
- training/data-use policy
- enterprise privacy option
- region/data residency
- logging controls
- prompt/output filtering
- API rate limits
- audit/log capability
- output traceability support
- tool call control
- prompt injection risk handling
- contract/security review
- cost and latency behavior
- incident response process

Critical rule:

AI output is assistance-only and derived.

---

## 18. Embedding Vector Provider Evidence Requirements

For embedding/vector providers, collect evidence for:

- embedding model identity
- data retention policy
- training/data-use policy
- vector storage location
- tenant isolation support
- deletion support
- refresh/update behavior
- metadata filtering
- access control
- encryption
- cross-tenant leakage prevention
- retrieval audit support
- lifecycle support
- cost/latency behavior

Critical rule:

Vector similarity is not proof and not source of truth.

---

## 19. Archive Storage Provider Evidence Requirements

For archive/storage providers, collect evidence for:

- immutability/WORM support
- object lock support
- retention policy support
- legal hold support
- encryption
- key management
- access logs
- retrieval logs
- checksum/integrity support
- deletion policy
- region/data residency
- backup/replication
- lifecycle policy
- cost behavior
- compliance documentation

Critical rule:

Archive restore is read-only evidence retrieval, not runtime mutation.

---

## 20. Workforce Job Provider Evidence Requirements

For workforce/job providers, collect evidence for:

- job posting API availability
- posting approval process
- applicant data export/import
- messaging support
- applicant consent handling
- privacy policy
- data retention
- duplicate applicant handling
- status callback
- rate limits
- contract restrictions
- employer identity verification
- regional availability

This supports future Franchise OS workforce interface planning.

---

## 21. Capability Authority Classification

Each provider capability must declare authority class.

| Authority Class | Meaning |
|---|---|
| `AUTHORITY_NONE` | No authority, informational only |
| `AUTHORITY_CONTEXT_ONLY` | Context signal only |
| `AUTHORITY_EVIDENCE_ONLY` | Evidence candidate only |
| `AUTHORITY_PROVIDER_VERIFIED_REQUIRED` | Requires verification |
| `AUTHORITY_INTERNAL_REVIEW_REQUIRED` | Requires internal review |
| `AUTHORITY_FINANCIAL_REVIEW_REQUIRED` | Requires finance review |
| `AUTHORITY_SECURITY_REVIEW_REQUIRED` | Requires security review |
| `AUTHORITY_LEGAL_REVIEW_REQUIRED` | Requires legal review |
| `AUTHORITY_CUSTOMER_VISIBLE` | Affects visible customer status |
| `AUTHORITY_BLOCKED` | Not allowed |

Default for provider input:

`AUTHORITY_PROVIDER_VERIFIED_REQUIRED`

---

## 22. Failure Mode Collection

Each capability must collect failure modes.

Common failure modes:

- timeout
- rate limit
- signature failure
- replay
- duplicate request
- duplicate callback
- partial success
- stale state
- unmapped response
- wrong store mapping
- wrong tenant mapping
- amount mismatch
- settlement mismatch
- unavailable capability
- sandbox/production mismatch
- provider contract drift
- customer-visible delay
- irreversible provider action
- data deletion failure
- privacy request failure

Failure modes must map to error codes and alert families.

---

## 23. Provider Error Mapping Rule

Provider errors must map to internal error codes.

Mapping must include:

- provider error code
- provider error message class
- internal error code
- severity
- retryability
- idempotency impact
- containment candidate
- quarantine candidate
- reconciliation candidate
- customer visibility
- support route
- audit/evidence requirement

Raw provider errors must not be shown directly to customers.

---

## 24. Retryability Classification

| Retry Class | Meaning |
|---|---|
| `RETRY_NONE` | Do not retry |
| `RETRY_SAFE` | Safe retry allowed |
| `RETRY_IDEMPOTENT_ONLY` | Retry only with idempotency |
| `RETRY_PROVIDER_CONFIRMATION_REQUIRED` | Provider confirmation required |
| `RETRY_AFTER_RECONCILIATION` | Retry only after reconciliation |
| `RETRY_BLOCKED_BY_CONTAINMENT` | Retry blocked |
| `RETRY_BLOCKED_BY_QUARANTINE` | Retry blocked pending verification |
| `RETRY_MANUAL_REVIEW_REQUIRED` | Manual review required |

Payment, value, identity, and provider mutation calls should not retry blindly.

---

## 25. Customer Visibility Classification

| Visibility | Meaning |
|---|---|
| `CUSTOMER_VIS_NONE` | Not customer visible |
| `CUSTOMER_VIS_SAFE_STATUS` | Safe status message only |
| `CUSTOMER_VIS_SUPPORT_MEDIATED` | Support-mediated explanation |
| `CUSTOMER_VIS_RECOVERY_REQUIRED` | Customer recovery needed |
| `CUSTOMER_VIS_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `CUSTOMER_VIS_BLOCKED` | Must not be shown |

Provider raw errors are internal by default.

---

## 26. Provider Evidence Review Workflow

Recommended workflow:

1. Create provider record.
2. Create capability records.
3. Attach documentation evidence.
4. Review security class.
5. Review data class.
6. Review legal/contract constraints.
7. Test sandbox if available.
8. Test production only under approved conditions.
9. Map error/failure modes.
10. Map retryability.
11. Map customer visibility.
12. Map audit/evidence requirements.
13. Map boundary tests.
14. Decide capability status.
15. Carry status into implementation handoff.

No provider-specific implementation before step 14.

---

## 27. Provider Capability Acceptance Criteria

A capability may be accepted for planning if:

- official documentation or direct evidence exists
- security review completed where required
- legal/contract review completed where required
- sandbox behavior is understood
- production behavior is either verified or explicitly pending
- failure modes are mapped
- retryability is classified
- error codes are mapped
- customer visibility is classified
- data scope is known
- authority scope is bounded
- boundary tests are mapped
- blockers are listed

Accepted for planning does not mean coding allowed.

---

## 28. Provider Capability Rejection Criteria

A capability should be rejected or blocked if:

- evidence is missing
- security behavior is unclear
- provider requires unsafe credentials handling
- provider cannot support required verification
- provider cannot support idempotency for value-bearing operations
- provider cannot provide needed audit/reporting
- legal/contract terms prohibit intended use
- customer-visible state would be misleading
- sandbox differs materially and production cannot be verified
- error handling is too ambiguous
- provider does not support safe deletion/privacy handling where required
- cross-tenant/store isolation cannot be preserved

---

## 29. Provider Evidence Package Template

Each provider evidence package should contain:

| Section | Content |
|---|---|
| Provider Overview | Name, category, region, contact, status |
| Capability List | Each capability and status |
| Documentation Evidence | Official docs and references |
| Contract/Legal Evidence | Terms, restrictions, legal notes |
| Security Evidence | Auth, signature, encryption, audit, privacy |
| Sandbox Test Evidence | Test cases and results |
| Production Test Evidence | Controlled production verification |
| Error Mapping | Provider error to internal error mapping |
| Failure Mode Matrix | Failure handling |
| Retry Policy | Retryability classification |
| Reconciliation Policy | Reconciliation requirements |
| Customer Visibility Policy | Customer-facing status boundary |
| i18n Policy | Visible message key requirements |
| Boundary Test Map | Tests from Foundation |
| Open Blockers | Unresolved issues |
| Review Decision | Accepted, limited, rejected, deferred |

---

## 30. Provider Evidence Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-PROVIDER-EVIDENCE-0001` | Provider evidence template not reviewed |
| `BLOCKER-PROVIDER-RECORD-0001` | Provider record missing |
| `BLOCKER-PROVIDER-CAPABILITY-0001` | Capability record missing |
| `BLOCKER-PROVIDER-DOC-0001` | Official documentation missing |
| `BLOCKER-PROVIDER-SECURITY-0001` | Security review missing |
| `BLOCKER-PROVIDER-LEGAL-0001` | Legal/contract review missing |
| `BLOCKER-PROVIDER-SANDBOX-0001` | Sandbox behavior untested |
| `BLOCKER-PROVIDER-PRODUCTION-0001` | Production behavior unverified |
| `BLOCKER-PROVIDER-IDEMPOTENCY-0001` | Idempotency support unclear |
| `BLOCKER-PROVIDER-CALLBACK-0001` | Callback verification unclear |
| `BLOCKER-PROVIDER-ERROR-MAP-0001` | Error mapping missing |
| `BLOCKER-PROVIDER-CUSTOMER-VIS-0001` | Customer visibility classification missing |
| `BLOCKER-PROVIDER-BOUNDARY-TEST-0001` | Boundary tests not mapped |

Open provider blockers prevent provider-specific runtime implementation.

---

## 31. Validation Checklist

Validation must confirm:

- provider evidence status catalog exists
- provider record schema exists
- capability record schema exists
- provider categories are defined
- required evidence types are defined
- POS evidence requirements exist
- payment evidence requirements exist
- global payment evidence requirements exist
- KDS evidence requirements exist
- menu projection evidence requirements exist
- messaging evidence requirements exist
- AI provider evidence requirements exist
- embedding/vector evidence requirements exist
- archive provider evidence requirements exist
- workforce/job provider evidence requirements exist
- authority classification exists
- failure mode collection exists
- error mapping rule exists
- retryability classification exists
- customer visibility classification exists
- evidence workflow exists
- acceptance/rejection criteria exist
- coding remains deferred

---

## 32. Relationship To Previous Documents

This document follows:

- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`

It imports the security Foundation reference spine:

- `09560` through `09646`

It supports future work for:

- POS provider evidence
- payment provider evidence
- KDS provider evidence
- Catch & Order provider boundary
- Catch Menu external projection boundary
- workforce/job board interface planning
- AI/pgvector provider governance
- archive/storage provider governance
- controlled implementation handoff

This document is provider evidence collection policy only.

It does not authorize coding.

---

## 33. Final Rule

Provider capability is not assumed.

Every provider capability must be collected as evidence, classified by authority, reviewed for security and legal constraints, tested where possible, mapped to failure modes, mapped to error/alert codes, classified for customer visibility, and attached to boundary tests before implementation may be considered.

Sandbox confirmation is not full production confirmation.

Marketing claims are not integration truth.

Provider input remains evidence-required until verified.

No provider-specific runtime implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, imports Foundation controls, maps boundary tests, resolves provider blockers, and declares target files and data scope.
