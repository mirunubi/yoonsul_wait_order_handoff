# 010214_Policy_Compensation_Review_Authority_Matrix_And_Value_Recovery_Control.md

## Purpose

This document defines the Compensation Review Authority Matrix and Value Recovery Control Policy.

The previous artifact `09780` defined the Customer Recovery Message Catalog and Compensation Review Boundary Policy.

This document separates customer recovery language from actual value recovery authority.

The purpose is to prevent refund, coupon, point, wallet, membership benefit, remake, discount, apology credit, or compensation actions from being triggered by message text, support notes, AI drafts, pgvector similarity, provider claims, or customer-visible status alone.

Compensation may be part of customer recovery.

Compensation is not automatically granted by recovery.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to compensation and value recovery planning for:

1. Refund review
2. Partial refund review
3. Payment cancellation review
4. Duplicate payment recovery
5. Coupon issuance or reissue
6. Point adjustment
7. Wallet/prepaid balance adjustment
8. Membership benefit correction
9. Discount correction
10. Remake or replacement review
11. Missing item recovery
12. KDS delay recovery
13. Price mismatch recovery
14. Allergen/safety recovery
15. Provider-caused recovery
16. Store-caused recovery
17. System-caused recovery
18. Support goodwill recovery
19. Franchise OS customer recovery policy inheritance
20. Owner/HQ compensation approval boundary

This document does not implement refund APIs, coupon issuance, point mutation, wallet adjustment, support workflows, approval screens, ledger entries, POS actions, payment provider calls, or runtime compensation logic.

---

## 3. Core Principle

Compensation is value authority.

The correct rule is:

Message is not approval.
Support note is not approval.
AI suggestion is not approval.
pgvector similarity is not proof.
Provider claim is not proof.
Customer complaint is not proof by itself.
Evidence and authority are required before value changes.

Value recovery must be:

- evidence-linked
- authority-approved
- auditable
- reversible where possible
- idempotent
- finance-aware
- customer-safe
- legally reviewed where needed

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09790` |
| Package ID | `compensation.review_authority.value_recovery_control.v1` |
| Artifact Type | `COMPENSATION_AUTHORITY_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `VALUE_RECOVERY_PLANNING_ONLY` |
| Owner | `Support / Finance / Customer Recovery / Legal / Product` |
| Dependencies | `09560` to `09780` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_CAUSED_OR_PROVIDER_VALUE_RELATED` |
| i18n Requirement | `REQUIRED_FOR_CUSTOMER_VISIBLE_COMPENSATION_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_ALL_VALUE_RECOVERY_ACTIONS` |
| Security Requirement | `VALUE_RECOVERY_AUTHORITY_BOUNDARY_REQUIRED` |
| Review Requirement | `SUPPORT_FINANCE_LEGAL_SECURITY_REVIEW_REQUIRED` |
| Blocker Status | `COMPENSATION_AUTHORITY_REVIEW_REQUIRED` |

---

## 5. Compensation Definition

Compensation is any customer-facing or account-facing value adjustment, benefit, recovery, or replacement granted in response to a customer issue.

Compensation may include:

- refund
- partial refund
- payment cancel
- coupon
- point adjustment
- wallet balance adjustment
- prepaid credit
- membership benefit correction
- free item
- remake
- replacement
- discount correction
- service recovery credit
- apology benefit
- future-use benefit
- manual goodwill grant

Compensation does not include:

- message acknowledgement
- apology without value promise
- support review notice
- staff assistance
- evidence collection
- provider investigation
- internal escalation

---

## 6. Compensation Case Family Catalog

| Case Family | Meaning |
|---|---|
| `COMP_ORDER_FAILED` | Order failed or did not proceed |
| `COMP_DUPLICATE_ORDER` | Duplicate order risk |
| `COMP_PAYMENT_UNCERTAIN` | Payment state uncertain |
| `COMP_DUPLICATE_PAYMENT` | Duplicate payment risk |
| `COMP_REFUND_REQUEST` | Refund request |
| `COMP_PARTIAL_REFUND_REQUEST` | Partial refund request |
| `COMP_PRICE_MISMATCH` | Price mismatch |
| `COMP_COUPON_FAILURE` | Coupon failure |
| `COMP_POINT_FAILURE` | Point adjustment issue |
| `COMP_WALLET_FAILURE` | Wallet/prepaid issue |
| `COMP_MEMBERSHIP_BENEFIT_FAILURE` | Membership benefit issue |
| `COMP_MISSING_ITEM` | Missing item |
| `COMP_REMAKE_REVIEW` | Remake/replacement review |
| `COMP_KDS_DELAY` | Kitchen delay |
| `COMP_ALLERGEN_SAFETY` | Allergen/safety issue |
| `COMP_PROVIDER_FAILURE` | Provider-related failure |
| `COMP_SYSTEM_FAILURE` | System-related failure |
| `COMP_GOODWILL_REVIEW` | Goodwill review |

Each case family must define authority route and evidence requirement.

---

## 7. Compensation Type Catalog

| Compensation Type | Meaning |
|---|---|
| `COMP_TYPE_NONE` | No value compensation |
| `COMP_TYPE_MESSAGE_ONLY` | Message-only recovery |
| `COMP_TYPE_STAFF_ASSISTANCE` | Staff assistance only |
| `COMP_TYPE_REMAKE` | Remake or replacement |
| `COMP_TYPE_FREE_ITEM` | Free item or add-on |
| `COMP_TYPE_DISCOUNT_CORRECTION` | Discount correction |
| `COMP_TYPE_COUPON` | Coupon grant/reissue |
| `COMP_TYPE_POINTS` | Point adjustment |
| `COMP_TYPE_WALLET_CREDIT` | Wallet/prepaid credit |
| `COMP_TYPE_PARTIAL_REFUND` | Partial refund |
| `COMP_TYPE_FULL_REFUND` | Full refund |
| `COMP_TYPE_PAYMENT_CANCEL` | Payment cancel |
| `COMP_TYPE_MEMBERSHIP_BENEFIT` | Membership benefit correction |
| `COMP_TYPE_GOODWILL_CREDIT` | Goodwill credit |
| `COMP_TYPE_LEGAL_REVIEW_ONLY` | Legal review required before action |

Compensation type determines authority and audit requirements.

---

## 8. Authority Level Catalog

| Authority Level | Meaning |
|---|---|
| `AUTH_RECOVERY_MESSAGE_ONLY` | Can send message only |
| `AUTH_STORE_STAFF_ASSISTANCE` | Store staff may assist |
| `AUTH_STORE_MANAGER_REVIEW` | Store manager review required |
| `AUTH_SUPPORT_AGENT_REVIEW` | Support agent may prepare review |
| `AUTH_SUPPORT_LEAD_APPROVAL` | Support lead approval required |
| `AUTH_OWNER_APPROVAL` | Owner approval required |
| `AUTH_HQ_SUPPORT_APPROVAL` | HQ support approval required |
| `AUTH_FINANCE_APPROVAL` | Finance approval required |
| `AUTH_PAYMENT_AUTHORITY` | Payment/refund authority required |
| `AUTH_VALUE_LEDGER_AUTHORITY` | Coupon/wallet/point authority required |
| `AUTH_LEGAL_APPROVAL` | Legal approval required |
| `AUTH_SECURITY_REVIEW` | Security review required |
| `AUTH_BLOCKED` | Action blocked |

Default:

`AUTH_RECOVERY_MESSAGE_ONLY`

---

## 9. Compensation Request Record Schema

Each compensation request should include:

| Field | Required Meaning |
|---|---|
| `compensation_request_id` | Stable request id |
| `case_family` | Compensation case family |
| `compensation_type` | Requested compensation type |
| `customer_context_ref` | Masked customer/session/order reference |
| `tenant_id_scope` | Tenant scope |
| `store_id_scope` | Store scope |
| `source_event_family` | Source event |
| `source_error_code` | Source error |
| `source_status` | Source status |
| `evidence_ref` | Required evidence |
| `provider_evidence_status` | Provider evidence if relevant |
| `value_amount` | Amount or value if applicable |
| `currency_or_unit` | Currency, points, coupon, item |
| `idempotency_key` | Required for value action |
| `authority_required` | Required authority |
| `review_route` | Required review route |
| `approval_status` | Approval status |
| `customer_message_key` | Customer-visible key |
| `audit_required` | Audit requirement |
| `legal_review_required` | Legal review if needed |
| `status` | Request status |
| `blocker_id` | Blocker if incomplete |

A compensation request without evidence and authority route is incomplete.

---

## 10. Compensation Request Status Catalog

| Status | Meaning |
|---|---|
| `COMP_REQUEST_DRAFT` | Draft request |
| `COMP_REQUEST_EVIDENCE_REQUIRED` | Evidence required |
| `COMP_REQUEST_REVIEW_REQUIRED` | Review required |
| `COMP_REQUEST_SUPPORT_REVIEW` | Support review |
| `COMP_REQUEST_STORE_REVIEW` | Store review |
| `COMP_REQUEST_FINANCE_REVIEW` | Finance review |
| `COMP_REQUEST_PAYMENT_AUTHORITY_REQUIRED` | Payment authority required |
| `COMP_REQUEST_VALUE_AUTHORITY_REQUIRED` | Value authority required |
| `COMP_REQUEST_LEGAL_REVIEW` | Legal review |
| `COMP_REQUEST_SECURITY_REVIEW` | Security review |
| `COMP_REQUEST_APPROVED` | Approved by authority |
| `COMP_REQUEST_REJECTED` | Rejected |
| `COMP_REQUEST_DEFERRED` | Deferred |
| `COMP_REQUEST_BLOCKED` | Blocked |
| `COMP_REQUEST_EXECUTION_PENDING` | Execution pending later |
| `COMP_REQUEST_EXECUTED` | Executed later by authority package |
| `COMP_REQUEST_CUSTOMER_NOTIFIED` | Customer notified |
| `COMP_REQUEST_CLOSED` | Closed with evidence |

Default status:

`COMP_REQUEST_REVIEW_REQUIRED`

---

## 11. Approval Status Catalog

| Approval Status | Meaning |
|---|---|
| `APPROVAL_NOT_REQUESTED` | Approval not requested |
| `APPROVAL_PENDING` | Approval pending |
| `APPROVAL_EVIDENCE_MISSING` | Evidence missing |
| `APPROVAL_REVIEW_REQUIRED` | Review required |
| `APPROVAL_GRANTED` | Approval granted |
| `APPROVAL_GRANTED_WITH_LIMITS` | Approval granted with limits |
| `APPROVAL_REJECTED` | Rejected |
| `APPROVAL_EXPIRED` | Approval expired |
| `APPROVAL_REVOKED` | Approval revoked |
| `APPROVAL_BLOCKED` | Blocked |

Customer promise must not exceed approval status.

---

## 12. Evidence Requirement Catalog

| Evidence Requirement | Meaning |
|---|---|
| `EVIDENCE_ORDER_RECORD` | Order record required |
| `EVIDENCE_POS_HANDOFF` | POS handoff evidence required |
| `EVIDENCE_PAYMENT_PROVIDER` | Payment provider evidence required |
| `EVIDENCE_LEDGER_RECONCILIATION` | Ledger/reconciliation evidence required |
| `EVIDENCE_KDS_TICKET` | KDS ticket evidence required |
| `EVIDENCE_STORE_STAFF_NOTE` | Store staff note required |
| `EVIDENCE_CUSTOMER_REPORT` | Customer report required |
| `EVIDENCE_PROVIDER_PACKET` | Provider evidence packet required |
| `EVIDENCE_MENU_VERSION` | Menu/version evidence required |
| `EVIDENCE_PRICE_SOURCE` | Price source evidence required |
| `EVIDENCE_ALLERGEN_SOURCE` | Allergen source evidence required |
| `EVIDENCE_VALUE_LEDGER` | Coupon/wallet/point ledger evidence required |
| `EVIDENCE_ARCHIVE_PACKET` | Archive/evidence packet required |
| `EVIDENCE_LEGAL_REVIEW` | Legal review required |

Evidence requirement depends on compensation type.

---

## 13. Refund Authority Rule

Refund or partial refund requires:

- payment provider verification
- original payment reference
- amount verification
- idempotency key
- refund eligibility check
- finance review
- payment authority
- audit event
- customer-safe message
- provider result reconciliation

Support cannot directly approve or execute refund unless explicitly granted by a controlled authority function.

AI cannot approve refund.

pgvector cannot prove refund eligibility.

---

## 14. Payment Cancel Authority Rule

Payment cancel requires:

- provider cancel window verification
- original transaction reference
- provider capability evidence
- payment status confirmation
- idempotency key
- finance/security review
- audit event
- customer-safe message

Cancel request is not cancel confirmation.

Customer message must not say canceled until verified.

---

## 15. Coupon Compensation Rule

Coupon compensation requires:

- coupon authority
- coupon policy reference
- eligibility rule
- issuance limit
- expiration rule
- duplicate prevention
- idempotency key
- audit event
- customer-safe message
- support/owner/HQ approval depending on value

Support draft is not coupon issuance.

---

## 16. Point Compensation Rule

Point compensation requires:

- point ledger authority
- point amount
- reason code
- duplicate prevention
- customer account verification
- idempotency key
- audit event
- customer-safe message
- finance/value review if needed

Point adjustment must not be done through support note alone.

---

## 17. Wallet Or Prepaid Credit Rule

Wallet/prepaid compensation requires:

- wallet ledger authority
- customer identity verification
- amount and currency/unit
- duplicate prevention
- legal/finance review if needed
- idempotency key
- audit event
- customer-safe message
- reconciliation

Wallet credit is financial-value-bearing.

It must be treated with high security.

---

## 18. Remake Or Replacement Rule

Remake/replacement review requires:

- order reference
- KDS or store evidence
- staff/store review
- customer issue class
- duplicate remake prevention
- customer-safe message
- audit if high-risk or repeated
- compensation escalation if value-bearing

Remake does not automatically imply refund.

---

## 19. Price Mismatch Compensation Rule

Price mismatch compensation requires:

- displayed price evidence
- order price evidence
- price source/version evidence
- timing evidence
- customer report if applicable
- support review
- finance/product review if value correction
- customer-safe message

Price mismatch may trigger customer recovery but does not automatically trigger refund.

---

## 20. Allergen Or Safety Compensation Rule

Allergen/safety compensation requires stricter review.

Required:

- allergen source evidence
- menu version evidence
- customer report
- store report
- legal review
- support lead review
- product/quality review
- customer-safe legal-approved message
- audit
- possible incident escalation

Do not admit liability without legal approval.

---

## 21. Provider-Caused Compensation Rule

Provider-related compensation requires:

- provider evidence packet
- provider capability status
- callback/log evidence
- provider fault status if verified
- provider contract review if needed
- support/customer recovery review
- finance review if value involved
- customer-safe message

Provider fault must not be claimed without evidence.

---

## 22. Goodwill Compensation Rule

Goodwill compensation may be allowed only through controlled policy.

Required:

- goodwill reason code
- value limit
- approval role
- frequency limit
- abuse detection
- customer account/session check
- audit
- customer-safe message
- owner/HQ policy where applicable

Goodwill must not become uncontrolled discount leakage.

---

## 23. Compensation Limit Matrix

A future policy should define limits by role.

Planning candidate:

| Role | Message | Coupon | Points | Remake | Refund | Wallet |
|---|---|---|---|---|---|---|
| Store Staff | Prepare only | Not allowed | Not allowed | Request | Not allowed | Not allowed |
| Store Manager | Prepare/review | Limited if policy allows | Limited if policy allows | Approve if policy allows | Request | Not allowed |
| Support Agent | Prepare/review | Request | Request | Request | Request | Not allowed |
| Support Lead | Approve limited | Approve limited | Approve limited | Approve limited | Request/approve if policy allows | Not allowed |
| Owner | Approve tenant policy | Approve tenant policy | Approve tenant policy | Approve tenant policy | Request/approve if policy allows | Not allowed unless authorized |
| Finance | Review | Review | Review | Review | Approve/execute path | Review |
| HQ Admin | Policy approval | Policy approval | Policy approval | Policy approval | Policy approval | Policy approval |

This matrix is a planning candidate only.

Exact limits require future policy.

---

## 24. Customer Message Boundary

Compensation-related customer messages must distinguish:

| Message Meaning | Allowed Before Approval |
|---|---|
| “We are checking.” | Allowed |
| “Support is reviewing.” | Allowed |
| “Staff will assist.” | Allowed |
| “Refund is being reviewed.” | Allowed |
| “Coupon is being reviewed.” | Allowed |
| “Compensation is approved.” | Not allowed before approval |
| “Refund is confirmed.” | Not allowed before provider/finance confirmation |
| “Coupon has been issued.” | Not allowed before issuance |
| “Wallet credit has been added.” | Not allowed before ledger confirmation |

Customer message must not exceed confirmed authority state.

---

## 25. AI Compensation Boundary

AI may assist with:

- issue summarization
- evidence checklist
- recovery option suggestion
- customer reply draft
- similar policy retrieval
- tone adjustment

AI must not:

- approve compensation
- choose final value
- execute refund
- issue coupon
- adjust points
- credit wallet
- admit fault
- close case
- suppress review

AI output must be marked as draft.

---

## 26. pgvector Compensation Boundary

pgvector may provide:

- similar incident references
- similar recovery decision context
- SOP/policy retrieval
- evidence checklist examples
- pattern detection

pgvector must not:

- prove current customer entitlement
- approve compensation
- replace evidence
- identify customer
- decide refund/coupon/point/wallet action
- override authority matrix

Similarity is not proof.

---

## 27. Compensation Audit Requirement

All value-impacting compensation must generate audit/evidence references in later implementation.

Audit should capture:

- request id
- case family
- compensation type
- evidence ref
- approver
- authority level
- amount/value
- idempotency key
- customer message key
- before/after value where applicable
- provider response if applicable
- execution result
- rollback or reversal status if applicable

This document defines audit requirement only.

It does not create audit implementation.

---

## 28. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/compensation/case_families.*` | Compensation case family catalog |
| `catalogs/compensation/types.*` | Compensation type catalog |
| `catalogs/compensation/authority_levels.*` | Authority level catalog |
| `catalogs/compensation/evidence_requirements.*` | Evidence requirement catalog |
| `catalogs/compensation/limit_matrix.*` | Role/limit matrix candidate |
| `i18n/registry/compensation_message_keys.*` | Compensation message key registry |
| `docs/compensation/review_policy.md` | Review policy packet |

This is a layout candidate only.

No files are authorized.

---

## 29. Database Layout Candidate

If future implementation chooses database-backed compensation review, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `compensation_case_families` | Case family catalog |
| `compensation_request_records` | Compensation request records |
| `compensation_authority_levels` | Authority level catalog |
| `compensation_approval_records` | Approval records |
| `compensation_evidence_refs` | Evidence references |
| `compensation_review_routes` | Review routing |
| `compensation_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 30. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-COMPENSATION-0001` | Compensation authority policy not reviewed |
| `BLOCKER-COMPENSATION-CASE-0001` | Compensation case family catalog missing |
| `BLOCKER-COMPENSATION-TYPE-0001` | Compensation type catalog missing |
| `BLOCKER-COMPENSATION-AUTHORITY-0001` | Authority level catalog missing |
| `BLOCKER-COMPENSATION-SCHEMA-0001` | Compensation request schema missing |
| `BLOCKER-COMPENSATION-EVIDENCE-0001` | Evidence requirement catalog missing |
| `BLOCKER-COMPENSATION-REFUND-0001` | Refund authority rule missing |
| `BLOCKER-COMPENSATION-VALUE-0001` | Value compensation rule missing |
| `BLOCKER-COMPENSATION-LEGAL-0001` | Legal-sensitive rule missing |
| `BLOCKER-COMPENSATION-AI-0001` | AI boundary missing |
| `BLOCKER-COMPENSATION-PGVECTOR-0001` | pgvector boundary missing |
| `BLOCKER-COMPENSATION-AUDIT-0001` | Audit requirement missing |
| `BLOCKER-COMPENSATION-CODING-0001` | Coding not authorized |

Open blockers prevent compensation implementation.

---

## 31. Validation Checklist

Validation must confirm:

- compensation definition exists
- compensation case family catalog exists
- compensation type catalog exists
- authority level catalog exists
- request record schema exists
- request status catalog exists
- approval status catalog exists
- evidence requirement catalog exists
- refund authority rule exists
- payment cancel rule exists
- coupon compensation rule exists
- point compensation rule exists
- wallet/prepaid rule exists
- remake/replacement rule exists
- price mismatch rule exists
- allergen/safety rule exists
- provider-caused rule exists
- goodwill rule exists
- compensation limit matrix candidate exists
- customer message boundary exists
- AI boundary exists
- pgvector boundary exists
- audit requirement exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 32. Relationship To Previous Documents

This document follows:

- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09634 Security Control Records And Security Class Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09560` through `09780`

It prepares later planning for:

- compensation review authority matrix
- customer recovery value-control workflow
- refund/coupon/point/wallet authority handoff
- support/admin recovery approval surface
- future compensation implementation handoff

This document is compensation authority planning only.

It does not authorize coding.

---

## 33. Final Rule

Compensation is value authority.

Customer recovery messages may acknowledge, guide, apologize, and route review, but they must not create refund, coupon, point, wallet, membership, discount, remake, replacement, or goodwill value changes by themselves.

Compensation requires evidence, approval, idempotency, audit, authority route, and customer-safe messaging.

AI may draft or summarize.

pgvector may provide similar-case context.

Neither AI nor pgvector may approve compensation.

No compensation review or value recovery implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
