# 09810 Value Recovery Reconciliation And Partial Execution Closure Policy

## 1. Purpose

This document defines the Value Recovery Reconciliation and Partial Execution Closure Policy.

The previous artifact `09800` defined the Value Recovery Evidence Audit and Idempotency Review Packet Policy.

This document defines how value recovery actions must be reconciled and closed when a recovery action is approved, rejected, partially executed, duplicated, delayed, provider-pending, ledger-pending, customer-message-pending, or rollback-required.

The purpose is to prevent value recovery cases from being closed while payment, refund, coupon, point, wallet, membership benefit, replacement, remake, or customer notification status remains uncertain.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to reconciliation and closure planning for:

1. Refund reconciliation
2. Partial refund reconciliation
3. Payment cancel reconciliation
4. Duplicate payment recovery closure
5. Coupon issuance/reissue reconciliation
6. Point adjustment reconciliation
7. Wallet/prepaid credit reconciliation
8. Membership benefit correction reconciliation
9. Discount correction reconciliation
10. Remake/replacement closure
11. Missing item recovery closure
12. Provider-caused recovery reconciliation
13. Store-caused recovery reconciliation
14. System-caused recovery reconciliation
15. Goodwill compensation reconciliation
16. Customer notification consistency
17. Partial execution review
18. Rollback/reversal review
19. Archive/evidence closure
20. Franchise OS recovery policy inheritance

This document does not implement reconciliation jobs, refund APIs, provider callbacks, ledger logic, coupon engines, wallet ledgers, point systems, support workflows, or runtime closure logic.

---

## 3. Core Principle

Recovery is not closed until value, evidence, audit, reconciliation, and customer message state agree.

The correct rule is:

Approved does not mean executed.
Executed does not mean reconciled.
Provider success does not mean internal ledger success.
Internal success does not mean provider success.
Customer notified does not mean action completed.
Partial execution is not closure.
Closure requires evidence.

A value recovery case must close only through a reconciled and auditable state.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09810` |
| Package ID | `value_recovery.reconciliation.partial_execution_closure.v1` |
| Artifact Type | `VALUE_RECOVERY_RECONCILIATION_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `RECONCILIATION_CLOSURE_PLANNING_ONLY` |
| Owner | `Support / Finance / Audit / Security / Customer Recovery` |
| Dependencies | `09560` to `09800` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_VALUE_RELATED` |
| i18n Requirement | `REQUIRED_FOR_CUSTOMER_VISIBLE_CLOSURE_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_ALL_VALUE_RECOVERY_CLOSURE` |
| Security Requirement | `RECONCILED_CLOSURE_REQUIRED` |
| Review Requirement | `SUPPORT_FINANCE_AUDIT_SECURITY_REVIEW_REQUIRED` |
| Blocker Status | `VALUE_RECOVERY_RECONCILIATION_REVIEW_REQUIRED` |

---

## 5. Reconciliation Definition

Reconciliation is the controlled comparison of intended value recovery, approved authority, provider result, internal ledger result, customer-visible message, audit record, and evidence packet.

Reconciliation confirms whether:

- the intended action was approved
- the action was executed
- the action was executed once
- the provider result matches internal result
- the value amount matches approval
- the customer message matches confirmed state
- the audit record exists
- the evidence packet is complete
- rollback or reversal is needed
- case may be closed

Reconciliation is not a mutation by itself.

It is a closure gate.

---

## 6. Reconciliation Object Families

| Object Family | Meaning |
|---|---|
| `RECON_OBJECT_REFUND` | Refund reconciliation |
| `RECON_OBJECT_PAYMENT_CANCEL` | Payment cancel reconciliation |
| `RECON_OBJECT_COUPON` | Coupon issuance/reissue reconciliation |
| `RECON_OBJECT_POINT` | Point adjustment reconciliation |
| `RECON_OBJECT_WALLET` | Wallet/prepaid credit reconciliation |
| `RECON_OBJECT_MEMBERSHIP_BENEFIT` | Membership benefit correction reconciliation |
| `RECON_OBJECT_DISCOUNT` | Discount correction reconciliation |
| `RECON_OBJECT_REMAKE` | Remake/replacement closure |
| `RECON_OBJECT_GOODWILL` | Goodwill recovery reconciliation |
| `RECON_OBJECT_CUSTOMER_MESSAGE` | Customer notification reconciliation |
| `RECON_OBJECT_PROVIDER_RESULT` | Provider result reconciliation |
| `RECON_OBJECT_AUDIT_EVIDENCE` | Audit/evidence closure |

Each object family must define its own closure conditions.

---

## 7. Reconciliation Record Schema

Each reconciliation record should include:

| Field | Required Meaning |
|---|---|
| `reconciliation_id` | Stable reconciliation id |
| `compensation_request_id` | Compensation request reference |
| `evidence_packet_id` | Evidence packet reference |
| `idempotency_key` | Idempotency key |
| `recon_object_family` | Reconciliation object family |
| `tenant_id_scope` | Tenant scope |
| `store_id_scope` | Store scope |
| `customer_context_ref` | Masked customer/session reference |
| `approved_action_ref` | Approval reference |
| `provider_result_ref` | Provider result reference if applicable |
| `internal_result_ref` | Internal result reference |
| `value_amount_expected` | Expected value amount |
| `value_amount_actual` | Actual value amount |
| `currency_or_unit` | Currency, points, coupon, item |
| `customer_message_key` | Customer message key |
| `customer_message_status` | Customer message status |
| `audit_ref` | Audit reference |
| `archive_ref` | Archive reference |
| `reconciliation_status` | Reconciliation status |
| `partial_execution_status` | Partial execution status |
| `rollback_required` | Whether rollback/reversal is required |
| `review_route` | Review route |
| `blocker_id` | Blocker if incomplete |

A reconciliation record without idempotency key is incomplete for value-impacting cases.

---

## 8. Reconciliation Status Catalog

| Status | Meaning |
|---|---|
| `RECON_DRAFT` | Draft reconciliation |
| `RECON_REQUIRED` | Reconciliation required |
| `RECON_PENDING` | Pending reconciliation |
| `RECON_IN_PROGRESS` | Reconciliation in progress |
| `RECON_MATCHED` | Provider/internal/customer/audit state matched |
| `RECON_MISMATCH` | Mismatch detected |
| `RECON_PROVIDER_PENDING` | Provider result pending |
| `RECON_INTERNAL_PENDING` | Internal result pending |
| `RECON_LEDGER_PENDING` | Ledger result pending |
| `RECON_CUSTOMER_MESSAGE_PENDING` | Customer message pending |
| `RECON_AUDIT_PENDING` | Audit record pending |
| `RECON_EVIDENCE_PENDING` | Evidence packet incomplete |
| `RECON_PARTIAL_EXECUTION` | Partial execution detected |
| `RECON_ROLLBACK_REQUIRED` | Rollback or reversal required |
| `RECON_REVIEW_REQUIRED` | Manual review required |
| `RECON_BLOCKED` | Blocked |
| `RECON_CLOSED` | Reconciled and closed |

Default for value recovery:

`RECON_REQUIRED`

---

## 9. Closure Status Catalog

| Status | Meaning |
|---|---|
| `CLOSURE_NOT_READY` | Not ready to close |
| `CLOSURE_EVIDENCE_REQUIRED` | Evidence missing |
| `CLOSURE_AUDIT_REQUIRED` | Audit missing |
| `CLOSURE_RECONCILIATION_REQUIRED` | Reconciliation missing |
| `CLOSURE_PARTIAL_EXECUTION_REVIEW` | Partial execution review required |
| `CLOSURE_CUSTOMER_MESSAGE_REVIEW` | Customer message review required |
| `CLOSURE_FINANCE_REVIEW` | Finance review required |
| `CLOSURE_LEGAL_REVIEW` | Legal review required |
| `CLOSURE_SUPPORT_LEAD_REVIEW` | Support lead review required |
| `CLOSURE_ROLLBACK_REQUIRED` | Rollback/reversal required |
| `CLOSURE_APPROVED` | Closure approved |
| `CLOSURE_REJECTED` | Closure rejected |
| `CLOSURE_REOPENED` | Reopened |
| `CLOSURE_CLOSED` | Closed |

Default:

`CLOSURE_NOT_READY`

---

## 10. Partial Execution Review Rule

Partial execution occurs when the intended recovery action does not fully align across authority, provider, internal ledger, customer message, audit, and evidence.

Examples:

| Partial Execution Type | Meaning |
|---|---|
| `PROVIDER_SUCCESS_INTERNAL_PENDING` | Provider completed, internal ledger pending |
| `INTERNAL_SUCCESS_PROVIDER_PENDING` | Internal recorded, provider pending |
| `APPROVED_NOT_EXECUTED` | Approved but not executed |
| `EXECUTED_NOT_AUDITED` | Executed without audit reference |
| `MESSAGE_SENT_ACTION_PENDING` | Customer message sent before action complete |
| `ACTION_DONE_MESSAGE_PENDING` | Action complete, customer not notified |
| `DUPLICATE_BLOCKED_REVIEW_REQUIRED` | Duplicate blocked but review required |
| `VALUE_MISMATCH_REVIEW_REQUIRED` | Value amount mismatch |
| `ROLLBACK_STARTED_NOT_CONFIRMED` | Rollback started but not confirmed |

Partial execution must not close silently.

---

## 11. Refund Reconciliation Rule

Refund reconciliation requires:

- original payment reference
- refund request reference
- provider refund result
- internal ledger/refund record
- refund amount match
- currency match
- idempotency key match
- finance review
- audit event
- customer message alignment
- provider settlement/report follow-up if required

Customer message must not say refund confirmed before provider/internal reconciliation.

---

## 12. Payment Cancel Reconciliation Rule

Payment cancel reconciliation requires:

- original payment reference
- cancel request reference
- provider cancel result
- internal payment state
- cancel window evidence
- idempotency key
- audit event
- customer-safe message
- finance/security review if mismatch occurs

Cancel requested is not cancel confirmed.

---

## 13. Coupon Reconciliation Rule

Coupon reconciliation requires:

- coupon issue/reissue request
- coupon policy reference
- coupon id/reference
- customer account/session authority
- duplicate prevention
- expiration/usage rule
- audit event
- customer message alignment
- value ledger or coupon registry confirmation

Coupon message must not say issued before coupon exists.

---

## 14. Point Reconciliation Rule

Point reconciliation requires:

- point adjustment request
- point ledger record
- customer account authority
- point amount match
- reason code
- duplicate prevention
- audit event
- customer message alignment

Point adjustment must not close from support note alone.

---

## 15. Wallet Or Prepaid Reconciliation Rule

Wallet/prepaid reconciliation requires:

- wallet credit request
- wallet ledger record
- customer identity verification
- amount and currency match
- idempotency key
- finance/security review
- audit event
- customer message alignment
- rollback/reversal boundary

Wallet/prepaid is financial-value-bearing.

It requires stricter reconciliation.

---

## 16. Remake Or Replacement Closure Rule

Remake/replacement closure requires:

- order item reference
- KDS/store evidence
- remake/replacement approval if required
- duplicate prevention
- staff confirmation
- customer message alignment
- audit for high-risk or repeated cases
- escalation if missing/failed

Remake closure does not imply refund closure.

---

## 17. Price Mismatch Reconciliation Rule

Price mismatch reconciliation requires:

- displayed price evidence
- charged price evidence
- menu/version source
- timing evidence
- correction decision
- compensation decision if any
- customer message alignment
- audit record

Price correction may be message-only, coupon, partial refund, or other policy-bound action.

The action must match authority.

---

## 18. Allergen Or Safety Closure Rule

Allergen/safety recovery closure requires:

- allergen source evidence
- menu/version evidence
- store report
- customer report
- product/quality review
- legal review
- support lead review
- customer-safe legal-approved message
- audit
- possible incident escalation closure

Allergen/safety cases must not be closed as ordinary compensation without review.

---

## 19. Provider-Caused Recovery Reconciliation Rule

Provider-caused recovery reconciliation requires:

- provider evidence packet
- provider capability status
- provider callback/log evidence
- provider fault status if verified
- contract/liability review if needed
- internal impact record
- compensation decision if any
- customer message alignment
- audit
- provider follow-up status

Provider fault must not be asserted without evidence.

---

## 20. Customer Message Reconciliation Rule

Customer messages must align with actual recovery status.

Examples:

| Recovery Status | Allowed Message State |
|---|---|
| Evidence missing | Checking/review message only |
| Review pending | Review message only |
| Approved not executed | Processing message only if safe |
| Executed not reconciled | Checking final status |
| Reconciled matched | Confirmed message may be used |
| Rejected | Safe explanation after review |
| Blocked | Support-mediated explanation |
| Partial execution | Checking/review message only |

Customer message is part of reconciliation.

---

## 21. Rollback Or Reversal Review Rule

Rollback or reversal may be required when:

- duplicate value action executed
- wrong customer received value
- wrong amount credited
- provider/internal mismatch exists
- coupon issued incorrectly
- points adjusted incorrectly
- wallet credited incorrectly
- customer message promised incorrect outcome
- compensation approved in error

Rollback/reversal requires authority, audit, customer-safe messaging, and legal/finance review where needed.

Rollback is not always possible.

If rollback is impossible, prevention and approval must be stricter.

---

## 22. Reopen Rule

A closed recovery case must be reopened if:

- provider settlement later mismatches
- customer disputes closure
- audit evidence is incomplete
- duplicate action is detected
- legal hold is applied
- archive evidence contradicts closure
- payment provider reverses result
- coupon/wallet/point ledger mismatch appears
- AI/vector-derived review was later found misleading
- customer message was sent incorrectly

Closure is not immutable if evidence changes.

Reopen must be auditable.

---

## 23. Closure Decision Record Schema

Each closure decision should include:

| Field | Required Meaning |
|---|---|
| `closure_decision_id` | Stable closure decision id |
| `reconciliation_id` | Reconciliation record |
| `compensation_request_id` | Compensation request |
| `evidence_packet_id` | Evidence packet |
| `closure_status` | Closure status |
| `matched_objects` | What matched |
| `unmatched_objects` | What did not match |
| `customer_message_status` | Message state |
| `audit_status` | Audit state |
| `archive_status` | Archive state |
| `rollback_status` | Rollback state |
| `review_owner` | Reviewer |
| `decision_reason` | Reason |
| `reopen_conditions` | Reopen conditions |
| `closed_at` | Closure timestamp if applicable |

A closure decision without reopen conditions is incomplete.

---

## 24. AI Reconciliation Boundary

AI may assist with:

- summarizing reconciliation differences
- listing missing evidence
- identifying likely review route
- drafting internal closure note
- drafting customer message candidate

AI must not:

- mark reconciliation as matched
- approve closure
- close recovery case
- override provider/internal mismatch
- suppress reopen condition
- decide rollback
- send customer message

AI output is review context only.

---

## 25. pgvector Reconciliation Boundary

pgvector may assist with:

- similar reconciliation cases
- similar partial execution cases
- SOP lookup
- historical recovery pattern lookup

pgvector must not:

- prove reconciliation
- approve closure
- decide rollback
- decide customer entitlement
- override evidence
- close case

Similarity is not reconciliation.

---

## 26. Archive And Legal Hold Boundary

Closure must respect archive and legal hold rules.

Closure must not:

- delete evidence
- remove legal hold
- bypass retention
- treat archive restore as runtime mutation
- hide unresolved legal review
- close legal-sensitive cases without legal route

Archive/evidence packet must remain retrievable under retention policy.

---

## 27. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/value_recovery/reconciliation_statuses.*` | Reconciliation status catalog |
| `catalogs/value_recovery/closure_statuses.*` | Closure status catalog |
| `catalogs/value_recovery/partial_execution_types.*` | Partial execution types |
| `catalogs/value_recovery/reopen_conditions.*` | Reopen condition catalog |
| `docs/value_recovery/reconciliation_packet_template.md` | Reconciliation packet template |
| `docs/value_recovery/closure_decision_template.md` | Closure decision template |

This is a layout candidate only.

No files are authorized.

---

## 28. Database Layout Candidate

If future implementation chooses database-backed reconciliation, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `value_recovery_reconciliation_records` | Reconciliation records |
| `value_recovery_reconciliation_objects` | Object comparisons |
| `value_recovery_partial_execution_reviews` | Partial execution review |
| `value_recovery_closure_decisions` | Closure decisions |
| `value_recovery_reopen_events` | Reopen events |
| `value_recovery_rollback_reviews` | Rollback/reversal review |
| `value_recovery_customer_message_recon` | Customer message reconciliation |

This is a data-model candidate only.

No tables are authorized.

---

## 29. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-RECOVERY-RECON-0001` | Reconciliation policy not reviewed |
| `BLOCKER-RECOVERY-RECON-SCHEMA-0001` | Reconciliation schema missing |
| `BLOCKER-RECOVERY-CLOSURE-STATUS-0001` | Closure status catalog missing |
| `BLOCKER-RECOVERY-PARTIAL-0001` | Partial execution review rule missing |
| `BLOCKER-RECOVERY-REFUND-RECON-0001` | Refund reconciliation rule missing |
| `BLOCKER-RECOVERY-COUPON-RECON-0001` | Coupon reconciliation rule missing |
| `BLOCKER-RECOVERY-WALLET-RECON-0001` | Wallet/prepaid reconciliation rule missing |
| `BLOCKER-RECOVERY-MESSAGE-RECON-0001` | Customer message reconciliation rule missing |
| `BLOCKER-RECOVERY-ROLLBACK-0001` | Rollback/reversal review rule missing |
| `BLOCKER-RECOVERY-REOPEN-0001` | Reopen rule missing |
| `BLOCKER-RECOVERY-CLOSURE-DECISION-0001` | Closure decision schema missing |
| `BLOCKER-RECOVERY-CODING-0001` | Coding not authorized |

Open blockers prevent reconciliation implementation.

---

## 30. Validation Checklist

Validation must confirm:

- reconciliation definition exists
- reconciliation object families exist
- reconciliation record schema exists
- reconciliation status catalog exists
- closure status catalog exists
- partial execution review rule exists
- refund reconciliation rule exists
- payment cancel reconciliation rule exists
- coupon reconciliation rule exists
- point reconciliation rule exists
- wallet/prepaid reconciliation rule exists
- remake/replacement closure rule exists
- price mismatch reconciliation rule exists
- allergen/safety closure rule exists
- provider-caused recovery reconciliation rule exists
- customer message reconciliation rule exists
- rollback/reversal review rule exists
- reopen rule exists
- closure decision schema exists
- AI reconciliation boundary exists
- pgvector reconciliation boundary exists
- archive/legal hold boundary exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 31. Relationship To Previous Documents

This document follows:

- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`
- `09641 Retention Tier Archive Naming Manifest And Lifecycle Catalog`
- `09642 Legal Hold Deletion Anonymization And Retention Review Catalog`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09560` through `09800`

It prepares later planning for:

- value recovery reconciliation packet
- partial execution review packet
- closure decision packet
- rollback/reversal review packet
- customer message reconciliation
- future value recovery runtime handoff

This document is value recovery reconciliation and closure planning only.

It does not authorize coding.

---

## 32. Final Rule

Value recovery is not closed until approved action, provider result, internal record, value amount, idempotency key, customer message, audit, archive/evidence, and reconciliation status align.

Partial execution is not closure.

Provider success alone is not closure.

Internal ledger success alone is not closure.

Customer notification alone is not closure.

AI and pgvector may assist review, but cannot reconcile, approve closure, or decide rollback.

No value recovery reconciliation or closure implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
