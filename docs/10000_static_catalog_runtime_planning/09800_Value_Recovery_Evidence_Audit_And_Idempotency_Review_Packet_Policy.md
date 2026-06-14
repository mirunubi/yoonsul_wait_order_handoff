# 09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy

## 1. Purpose

This document defines the Value Recovery Evidence Audit and Idempotency Review Packet Policy.

The previous artifact `09790` defined the Compensation Review Authority Matrix and Value Recovery Control Policy.

This document defines the evidence, audit, idempotency, duplicate-prevention, reconciliation, rollback, and review packet requirements that must exist before any value recovery action can be implemented or executed.

The purpose is to prevent value recovery actions from causing duplicate refunds, duplicate coupons, duplicate point adjustments, wallet mis-credit, unauthorized compensation, unsupported customer promises, or unreconciled payment/provider conflicts.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to value recovery evidence and audit planning for:

1. Refund review
2. Partial refund review
3. Payment cancel review
4. Duplicate payment recovery
5. Coupon issuance or reissue
6. Point adjustment
7. Wallet/prepaid credit
8. Membership benefit correction
9. Discount correction
10. Remake or replacement review
11. Missing item recovery
12. Price mismatch recovery
13. Allergen/safety recovery
14. Provider-caused recovery
15. Store-caused recovery
16. System-caused recovery
17. Goodwill compensation
18. Support/admin recovery actions
19. Customer recovery notification
20. Franchise OS recovery policy inheritance

This document does not create audit tables, compensation tables, refund APIs, coupon issuance logic, point adjustment logic, wallet ledger entries, provider calls, support workflows, or runtime recovery actions.

---

## 3. Core Principle

Value recovery must be evidence-first and idempotent.

The correct rule is:

No evidence, no value action.
No authority, no value action.
No idempotency, no value action.
No audit, no value action.
No reconciliation path, no payment/value action.
No customer message beyond confirmed state.

A recovery action must be safe even if retried, delayed, partially executed, or reviewed later.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09800` |
| Package ID | `value_recovery.evidence_audit_idempotency_review_packet.v1` |
| Artifact Type | `VALUE_RECOVERY_EVIDENCE_AUDIT_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `REVIEW_PACKET_PLANNING_ONLY` |
| Owner | `Support / Finance / Audit / Security / Customer Recovery` |
| Dependencies | `09560` to `09790` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_VALUE_RELATED` |
| i18n Requirement | `REQUIRED_FOR_CUSTOMER_VISIBLE_VALUE_RECOVERY_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_ALL_VALUE_RECOVERY_ACTIONS` |
| Security Requirement | `IDEMPOTENT_VALUE_RECOVERY_REQUIRED` |
| Review Requirement | `SUPPORT_FINANCE_AUDIT_SECURITY_REVIEW_REQUIRED` |
| Blocker Status | `VALUE_RECOVERY_EVIDENCE_AUDIT_REVIEW_REQUIRED` |

---

## 5. Value Recovery Evidence Packet Definition

A Value Recovery Evidence Packet is a structured review packet that records why a value recovery action may be considered.

It may include:

- customer/session/order reference
- issue family
- source event
- source error
- provider evidence
- payment evidence
- KDS/store evidence
- menu/version evidence
- value ledger evidence
- support notes
- customer report
- archive reference
- audit reference
- authority route
- idempotency key
- reconciliation requirement
- customer message boundary
- approval decision
- execution decision if later implemented

Evidence packet does not execute recovery.

It prepares review.

---

## 6. Evidence Packet Record Schema

Each evidence packet should include:

| Field | Required Meaning |
|---|---|
| `evidence_packet_id` | Stable packet id |
| `compensation_request_id` | Related compensation request |
| `case_family` | Case family |
| `tenant_id_scope` | Tenant scope |
| `store_id_scope` | Store scope |
| `customer_context_ref` | Masked customer/session reference |
| `order_ref` | Order reference if applicable |
| `payment_ref` | Payment reference if applicable |
| `provider_ref` | Provider reference if applicable |
| `kds_ref` | KDS/ticket reference if applicable |
| `menu_version_ref` | Menu/version reference if applicable |
| `value_ledger_ref` | Coupon/wallet/point ledger reference if applicable |
| `source_event_family` | Source event |
| `source_error_code` | Source error |
| `evidence_items` | Evidence item list |
| `evidence_status` | Evidence status |
| `audit_ref` | Audit reference |
| `archive_ref` | Archive reference |
| `idempotency_key` | Idempotency key |
| `reconciliation_required` | Whether reconciliation required |
| `authority_required` | Required authority |
| `review_route` | Review route |
| `customer_message_key` | Customer message key |
| `blocker_id` | Blocker if incomplete |
| `status` | Packet status |

A packet without idempotency key is incomplete for value-impacting recovery.

---

## 7. Evidence Packet Status Catalog

| Status | Meaning |
|---|---|
| `EVIDENCE_PACKET_DRAFT` | Draft packet |
| `EVIDENCE_PACKET_EVIDENCE_REQUIRED` | Evidence required |
| `EVIDENCE_PACKET_PARTIAL` | Partial evidence |
| `EVIDENCE_PACKET_READY_FOR_REVIEW` | Ready for review |
| `EVIDENCE_PACKET_REVIEW_REQUIRED` | Review required |
| `EVIDENCE_PACKET_FINANCE_REVIEW` | Finance review |
| `EVIDENCE_PACKET_SECURITY_REVIEW` | Security review |
| `EVIDENCE_PACKET_LEGAL_REVIEW` | Legal review |
| `EVIDENCE_PACKET_PROVIDER_REVIEW` | Provider review |
| `EVIDENCE_PACKET_APPROVED_FOR_PLANNING` | Planning approval only |
| `EVIDENCE_PACKET_APPROVED_FOR_ACTION_REVIEW` | May move to action review later |
| `EVIDENCE_PACKET_REJECTED` | Rejected |
| `EVIDENCE_PACKET_BLOCKED` | Blocked |
| `EVIDENCE_PACKET_ARCHIVED` | Archived for evidence |
| `EVIDENCE_PACKET_REOPENED` | Reopened |

Default status:

`EVIDENCE_PACKET_EVIDENCE_REQUIRED`

---

## 8. Evidence Item Catalog

| Evidence Item | Meaning |
|---|---|
| `EV_ITEM_CUSTOMER_REPORT` | Customer report |
| `EV_ITEM_ORDER_RECORD` | Order record |
| `EV_ITEM_POS_HANDOFF_RECORD` | POS handoff record |
| `EV_ITEM_PAYMENT_PROVIDER_RECORD` | Payment provider evidence |
| `EV_ITEM_LEDGER_RECORD` | Internal ledger evidence |
| `EV_ITEM_RECONCILIATION_RECORD` | Reconciliation evidence |
| `EV_ITEM_KDS_TICKET_RECORD` | KDS ticket evidence |
| `EV_ITEM_STORE_STAFF_NOTE` | Store staff note |
| `EV_ITEM_SUPPORT_NOTE` | Support note |
| `EV_ITEM_PROVIDER_PACKET` | Provider evidence packet |
| `EV_ITEM_MENU_VERSION` | Menu/version evidence |
| `EV_ITEM_PRICE_SOURCE` | Price source |
| `EV_ITEM_ALLERGEN_SOURCE` | Allergen source |
| `EV_ITEM_VALUE_LEDGER` | Value ledger evidence |
| `EV_ITEM_ARCHIVE_REF` | Archive reference |
| `EV_ITEM_AUDIT_EVENT` | Audit event |
| `EV_ITEM_AI_DRAFT_REF` | AI draft reference |
| `EV_ITEM_VECTOR_CONTEXT_REF` | pgvector context reference |

AI and pgvector evidence items are context only.

They are not proof by themselves.

---

## 9. Evidence Strength Catalog

| Strength | Meaning |
|---|---|
| `EV_STRENGTH_NONE` | No evidence |
| `EV_STRENGTH_CUSTOMER_REPORT_ONLY` | Customer report only |
| `EV_STRENGTH_INTERNAL_RECORD` | Internal record |
| `EV_STRENGTH_PROVIDER_RECORD` | Provider record |
| `EV_STRENGTH_RECONCILED_RECORD` | Reconciled record |
| `EV_STRENGTH_ARCHIVED_RECORD` | Archived record |
| `EV_STRENGTH_AUDITED_RECORD` | Audited record |
| `EV_STRENGTH_LEGAL_REVIEWED` | Legal reviewed |
| `EV_STRENGTH_PROVIDER_CONFIRMED` | Provider confirmed |
| `EV_STRENGTH_AUTHORITY_CONFIRMED` | Authority confirmed |

Customer report alone may trigger review.

Customer report alone does not approve value action.

---

## 10. Idempotency Requirement

Every value-impacting recovery action must define an idempotency key.

The idempotency key should be derived from controlled references such as:

- tenant
- store
- customer context
- order reference
- payment reference
- compensation request
- compensation type
- value amount
- provider reference if applicable
- recovery case family

The idempotency key prevents:

- duplicate refund
- duplicate coupon
- duplicate point adjustment
- duplicate wallet credit
- duplicate remake/replacement
- duplicate goodwill grant
- duplicate customer notification if tied to action

No value action should proceed without idempotency.

---

## 11. Idempotency Record Schema

Each idempotency record should include:

| Field | Required Meaning |
|---|---|
| `idempotency_key` | Stable idempotency key |
| `scope` | Tenant/store/customer/order/payment scope |
| `action_type` | Refund, coupon, point, wallet, remake, etc. |
| `compensation_request_id` | Related request |
| `evidence_packet_id` | Related evidence packet |
| `value_amount` | Value amount if any |
| `currency_or_unit` | Currency, points, coupon, item |
| `provider_ref` | Provider ref if applicable |
| `first_seen_at` | First seen timestamp |
| `last_seen_at` | Last seen timestamp |
| `status` | Idempotency status |
| `duplicate_detected` | Whether duplicate detected |
| `result_ref` | Result reference if executed later |
| `audit_ref` | Audit reference |
| `blocker_id` | Blocker if unresolved |

This document defines schema planning only.

---

## 12. Idempotency Status Catalog

| Status | Meaning |
|---|---|
| `IDEMPOTENCY_NOT_CREATED` | Key not created |
| `IDEMPOTENCY_REQUIRED` | Key required |
| `IDEMPOTENCY_CREATED` | Key created |
| `IDEMPOTENCY_RESERVED` | Reserved before action |
| `IDEMPOTENCY_IN_PROGRESS` | Action in progress later |
| `IDEMPOTENCY_COMPLETED` | Completed |
| `IDEMPOTENCY_DUPLICATE_DETECTED` | Duplicate detected |
| `IDEMPOTENCY_CONFLICT` | Same key with conflicting details |
| `IDEMPOTENCY_EXPIRED` | Expired |
| `IDEMPOTENCY_REOPENED` | Reopened for review |
| `IDEMPOTENCY_BLOCKED` | Blocked |

Default for value action:

`IDEMPOTENCY_REQUIRED`

---

## 13. Audit Requirement

Every value recovery action must be auditable.

Audit should capture:

- actor
- role
- authority
- tenant/store scope
- compensation request
- evidence packet
- idempotency key
- action type
- value amount
- before/after value if applicable
- provider request/response reference if applicable
- customer message key
- approval decision
- execution result if later implemented
- rollback/reversal state if applicable
- timestamp

Audit is required even if action is rejected, blocked, or deferred.

---

## 14. Audit Event Family Candidates

Potential audit event families:

| Audit Event Family | Meaning |
|---|---|
| `AUDIT_RECOVERY_REQUEST_CREATED` | Recovery request created |
| `AUDIT_EVIDENCE_PACKET_CREATED` | Evidence packet created |
| `AUDIT_EVIDENCE_ATTACHED` | Evidence attached |
| `AUDIT_IDEMPOTENCY_KEY_CREATED` | Idempotency key created |
| `AUDIT_COMPENSATION_REVIEW_STARTED` | Review started |
| `AUDIT_COMPENSATION_APPROVED` | Approved |
| `AUDIT_COMPENSATION_REJECTED` | Rejected |
| `AUDIT_COMPENSATION_BLOCKED` | Blocked |
| `AUDIT_VALUE_ACTION_EXECUTION_REQUESTED` | Execution requested later |
| `AUDIT_VALUE_ACTION_EXECUTED` | Executed later |
| `AUDIT_VALUE_ACTION_DUPLICATE_BLOCKED` | Duplicate blocked |
| `AUDIT_CUSTOMER_MESSAGE_PREPARED` | Customer message prepared |
| `AUDIT_CUSTOMER_MESSAGE_SENT` | Customer message sent later |
| `AUDIT_RECOVERY_CASE_CLOSED` | Recovery case closed |

These are planning candidates only.

---

## 15. Reconciliation Requirement

Value recovery must define reconciliation requirement.

Reconciliation may be required for:

- payment refund
- payment cancel
- duplicate payment risk
- settlement adjustment
- coupon issuance
- point adjustment
- wallet/prepaid credit
- membership benefit correction
- provider-caused failure
- price mismatch
- high-value goodwill

Reconciliation should compare:

- internal request
- provider result
- internal ledger
- customer-visible message
- audit event
- archive/evidence packet

No reconciliation, no high-risk value action.

---

## 16. Reconciliation Status Catalog

| Status | Meaning |
|---|---|
| `RECON_NOT_REQUIRED` | Not required |
| `RECON_REQUIRED` | Reconciliation required |
| `RECON_PENDING` | Pending |
| `RECON_IN_PROGRESS` | In progress |
| `RECON_MATCHED` | Matched |
| `RECON_MISMATCH` | Mismatch |
| `RECON_PROVIDER_PENDING` | Provider pending |
| `RECON_LEDGER_PENDING` | Ledger pending |
| `RECON_CUSTOMER_MESSAGE_PENDING` | Customer message pending |
| `RECON_BLOCKED` | Blocked |
| `RECON_REVIEW_REQUIRED` | Review required |
| `RECON_CLOSED` | Closed |

Default for payment/value action:

`RECON_REQUIRED`

---

## 17. Duplicate Prevention Rule

Duplicate prevention must block:

- duplicate refund for same payment and reason
- duplicate coupon for same case
- duplicate point adjustment for same case
- duplicate wallet credit for same case
- duplicate remake for same order item unless approved
- duplicate goodwill grant for same incident
- duplicate customer message stating confirmed compensation
- duplicate provider retry without idempotency

Duplicate prevention requires idempotency and audit.

---

## 18. Partial Execution Rule

A value recovery action may partially execute due to:

- provider timeout
- provider success but internal ledger pending
- internal approval but provider call failed
- customer message sent before reconciliation
- coupon issued but message failed
- refund accepted but settlement pending
- wallet credit recorded but notification failed

Partial execution must enter review.

It must not be silently closed.

---

## 19. Partial Execution Status Catalog

| Status | Meaning |
|---|---|
| `PARTIAL_EXEC_NOT_APPLICABLE` | Not applicable |
| `PARTIAL_EXEC_CANDIDATE` | Partial execution possible |
| `PARTIAL_EXEC_DETECTED` | Partial execution detected |
| `PARTIAL_EXEC_PROVIDER_SUCCESS_INTERNAL_PENDING` | Provider succeeded, internal pending |
| `PARTIAL_EXEC_INTERNAL_SUCCESS_PROVIDER_PENDING` | Internal succeeded, provider pending |
| `PARTIAL_EXEC_MESSAGE_SENT_ACTION_PENDING` | Customer message sent, action pending |
| `PARTIAL_EXEC_ACTION_DONE_MESSAGE_PENDING` | Action done, message pending |
| `PARTIAL_EXEC_RECON_REQUIRED` | Reconciliation required |
| `PARTIAL_EXEC_BLOCKED` | Blocked |
| `PARTIAL_EXEC_CLOSED` | Closed after reconciliation |

Partial execution is high-risk for customer trust.

---

## 20. Rollback And Reversal Boundary

Rollback/reversal must be planned separately from execution.

Possible rollback/reversal cases:

- coupon void
- point reversal
- wallet adjustment reversal
- refund reversal if provider supports it
- compensation cancellation before execution
- customer message correction
- duplicate value correction
- manual finance correction

Rollback is not always possible.

If rollback is not possible, prevention and review must be stronger.

---

## 21. Customer Message Consistency Rule

Customer-facing recovery messages must match confirmed action state.

Examples:

| Actual State | Allowed Customer Message |
|---|---|
| Evidence missing | “We are checking.” |
| Review pending | “Support is reviewing.” |
| Approval pending | “This is being reviewed.” |
| Approved but not executed | “Approved action is being processed” only if safe |
| Executed and reconciled | “Confirmed” message may be allowed |
| Partial execution | “We are checking the final status.” |
| Rejected | Safe explanation after review |
| Blocked | Support-mediated explanation |

Customer message must not outrun authority or reconciliation.

---

## 22. Provider Result Boundary

Provider result may affect value action only if:

- provider identity verified
- response belongs to correct tenant/store/customer/order/payment scope
- signature/callback verified where applicable
- replay ruled out
- idempotency matched
- provider error mapped
- reconciliation path exists
- provider capability evidence exists

Provider result is evidence.

Provider result is not automatically internal truth without verification.

---

## 23. AI Evidence Boundary

AI may assist by:

- summarizing evidence
- identifying missing evidence
- suggesting review route
- drafting customer message
- comparing policy candidates

AI must not:

- create evidence
- approve evidence strength
- approve compensation
- create idempotency key as authority
- decide reconciliation
- close recovery case
- override duplicate prevention
- send customer message without review

AI output is review context only.

---

## 24. pgvector Evidence Boundary

pgvector may assist by:

- finding similar past cases
- finding SOP references
- finding previous review patterns
- surfacing evidence checklist examples

pgvector must not:

- prove current issue
- decide customer entitlement
- decide compensation amount
- replace provider/payment evidence
- replace audit
- override authority
- close review

Similarity is not evidence by itself.

---

## 25. Evidence Audit Review Packet Template

A future review packet may use this structure:

    Value Recovery Evidence Audit Packet:
    <packet_id>

    Compensation Request:
    <request_id>

    Case Family:
    <case_family>

    Requested Value Action:
    <compensation_type>

    Evidence Items:
    <evidence list>

    Evidence Strength:
    <strength>

    Idempotency:
    <idempotency key/status>

    Authority Required:
    <authority level>

    Reconciliation:
    <requirement/status>

    Customer Message:
    <message key and allowed promise>

    Review Decision:
    <approved/rejected/deferred/blocked>

    Runtime Status:
    Runtime not authorized.

    Coding Status:
    Coding not authorized.

This packet is planning-only unless a separate handoff grants coding.

---

## 26. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/value_recovery/evidence_items.*` | Evidence item catalog |
| `catalogs/value_recovery/idempotency_statuses.*` | Idempotency status catalog |
| `catalogs/value_recovery/reconciliation_statuses.*` | Reconciliation status catalog |
| `catalogs/value_recovery/partial_execution_statuses.*` | Partial execution status catalog |
| `catalogs/value_recovery/audit_event_families.*` | Audit event family candidates |
| `docs/value_recovery/evidence_audit_packet_template.md` | Review packet template |

This is a layout candidate only.

No files are authorized.

---

## 27. Database Layout Candidate

If future implementation chooses database-backed value recovery review, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `value_recovery_evidence_packets` | Evidence packet records |
| `value_recovery_evidence_items` | Evidence items |
| `value_recovery_idempotency_records` | Idempotency records |
| `value_recovery_reconciliation_records` | Reconciliation records |
| `value_recovery_audit_refs` | Audit references |
| `value_recovery_partial_execution_records` | Partial execution records |
| `value_recovery_review_decisions` | Review decisions |

This is a data-model candidate only.

No tables are authorized.

---

## 28. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-VALUE-RECOVERY-AUDIT-0001` | Value recovery audit policy not reviewed |
| `BLOCKER-VALUE-RECOVERY-PACKET-0001` | Evidence packet schema missing |
| `BLOCKER-VALUE-RECOVERY-EVIDENCE-0001` | Evidence item catalog missing |
| `BLOCKER-VALUE-RECOVERY-IDEMPOTENCY-0001` | Idempotency requirement missing |
| `BLOCKER-VALUE-RECOVERY-AUDIT-EVENT-0001` | Audit event candidates missing |
| `BLOCKER-VALUE-RECOVERY-RECON-0001` | Reconciliation requirement missing |
| `BLOCKER-VALUE-RECOVERY-DUPLICATE-0001` | Duplicate prevention rule missing |
| `BLOCKER-VALUE-RECOVERY-PARTIAL-0001` | Partial execution rule missing |
| `BLOCKER-VALUE-RECOVERY-ROLLBACK-0001` | Rollback/reversal boundary missing |
| `BLOCKER-VALUE-RECOVERY-CUSTOMER-MSG-0001` | Customer message consistency rule missing |
| `BLOCKER-VALUE-RECOVERY-AI-0001` | AI evidence boundary missing |
| `BLOCKER-VALUE-RECOVERY-PGVECTOR-0001` | pgvector evidence boundary missing |
| `BLOCKER-VALUE-RECOVERY-CODING-0001` | Coding not authorized |

Open blockers prevent value recovery evidence/audit implementation.

---

## 29. Validation Checklist

Validation must confirm:

- evidence packet definition exists
- evidence packet record schema exists
- evidence packet status catalog exists
- evidence item catalog exists
- evidence strength catalog exists
- idempotency requirement exists
- idempotency record schema exists
- idempotency status catalog exists
- audit requirement exists
- audit event family candidates exist
- reconciliation requirement exists
- reconciliation status catalog exists
- duplicate prevention rule exists
- partial execution rule exists
- partial execution status catalog exists
- rollback/reversal boundary exists
- customer message consistency rule exists
- provider result boundary exists
- AI evidence boundary exists
- pgvector evidence boundary exists
- review packet template exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 30. Relationship To Previous Documents

This document follows:

- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`
- `09641 Retention Tier Archive Naming Manifest And Lifecycle Catalog`
- `09642 Legal Hold Deletion Anonymization And Retention Review Catalog`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09560` through `09790`

It prepares later planning for:

- value recovery audit packet
- idempotency registry
- compensation reconciliation planning
- refund/coupon/point/wallet recovery implementation handoff
- support/admin recovery review surface
- customer recovery notification control

This document is value recovery evidence/audit/idempotency planning only.

It does not authorize coding.

---

## 31. Final Rule

Value recovery must be evidence-linked, authority-approved, idempotent, auditable, and reconcilable.

No refund, cancel, coupon, point, wallet, membership benefit, discount, remake, replacement, or goodwill action may proceed from message text, support note, AI draft, pgvector similarity, provider claim, or customer complaint alone.

Duplicate prevention is mandatory.

Partial execution must enter review.

Customer messages must not outrun confirmed authority or reconciliation.

No value recovery evidence/audit/idempotency implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
