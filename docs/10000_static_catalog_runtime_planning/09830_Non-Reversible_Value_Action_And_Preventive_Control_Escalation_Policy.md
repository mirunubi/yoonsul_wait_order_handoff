# 09830 Non-Reversible Value Action And Preventive Control Escalation Policy

## 1. Purpose

This document defines the Non-Reversible Value Action and Preventive Control Escalation Policy.

The previous artifact `09820` defined the Value Recovery Rollback, Reversal, and Customer Correction Notice Policy.

This document defines how the system must treat value recovery actions that cannot be safely reversed after execution.

The purpose is to prevent irreversible or hard-to-reverse actions from being handled as ordinary compensation events.

Non-reversible value actions require stronger prevention, stronger approval, stronger evidence, stronger idempotency, stronger customer messaging control, and stricter audit.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to non-reversible or hard-to-reverse value actions such as:

1. Settled refund
2. Cross-provider refund
3. Redeemed coupon
4. Used wallet/prepaid credit
5. Used points
6. Consumed free item
7. Completed remake or replacement
8. Public or customer-read correction notice
9. Legal-sensitive recovery acknowledgement
10. Third-party provider action without reversal API
11. International/global payment recovery
12. Chargeback/dispute-related recovery
13. Franchise policy-based goodwill grant
14. High-value compensation
15. Wrong-customer recovery where value was consumed
16. Allergen/safety-related recovery communication
17. Privacy-sensitive customer correction
18. Archive/legal hold affected recovery
19. Provider contract-limited recovery
20. Multi-store or tenant-level policy compensation

This document does not implement prevention gates, payment APIs, refund logic, coupon engines, point systems, wallet ledgers, customer notification workflows, or rollback automation.

---

## 3. Core Principle

If reversal is difficult, prevention must be stronger.

The correct rule is:

Do not rely on rollback for irreversible actions.
Do not rely on support judgment alone.
Do not rely on AI suggestion.
Do not rely on pgvector similarity.
Do not rely on provider claim without evidence.
Do not send customer promise before authority confirmation.

For non-reversible value actions, the approval path must be stricter before execution.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09830` |
| Package ID | `value_recovery.non_reversible_action.preventive_control_escalation.v1` |
| Artifact Type | `NON_REVERSIBLE_VALUE_ACTION_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `PREVENTIVE_CONTROL_PLANNING_ONLY` |
| Owner | `Support / Finance / Legal / Security / Customer Recovery` |
| Dependencies | `09560` to `09820` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_VALUE_RELATED` |
| i18n Requirement | `REQUIRED_FOR_CUSTOMER_VISIBLE_NON_REVERSIBLE_ACTION_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_ALL_NON_REVERSIBLE_VALUE_ACTIONS` |
| Security Requirement | `PREVENTIVE_CONTROL_REQUIRED_BEFORE_NON_REVERSIBLE_ACTION` |
| Review Requirement | `SUPPORT_FINANCE_LEGAL_SECURITY_HQ_REVIEW_REQUIRED` |
| Blocker Status | `NON_REVERSIBLE_VALUE_ACTION_REVIEW_REQUIRED` |

---

## 5. Non-Reversible Action Definition

A non-reversible value action is any recovery action that cannot be safely undone after execution, or whose reversal would create additional customer, legal, provider, finance, or trust risk.

A value action may be non-reversible because:

- provider does not support reversal
- customer already consumed the benefit
- financial settlement has completed
- customer message has already created expectation
- legal-sensitive wording has been sent
- wrong customer has already received value
- third-party provider cannot guarantee correction
- cross-border payment or FX rules complicate reversal
- compensation was granted under franchise or owner policy
- original evidence has entered legal hold

A non-reversible action is not prohibited by default.

It requires stricter prevention and approval.

---

## 6. Non-Reversibility Classification Catalog

| Class | Meaning |
|---|---|
| `NONREV_NONE` | Reversible or not value-bearing |
| `NONREV_LOW` | Reversible with low risk |
| `NONREV_MEDIUM` | Reversible with review |
| `NONREV_HIGH` | Hard to reverse or customer-visible |
| `NONREV_CRITICAL` | Financial/legal/customer trust risk if wrong |
| `NONREV_BLOCKED` | Action blocked unless exceptional approval |
| `NONREV_UNKNOWN` | Reversibility unknown |

Default for uncertain provider/value actions:

`NONREV_UNKNOWN`

Unknown reversibility must be treated as high risk until reviewed.

---

## 7. Non-Reversible Case Family Catalog

| Case Family | Meaning |
|---|---|
| `NONREV_SETTLED_REFUND` | Refund already settled or provider-final |
| `NONREV_CROSS_BORDER_PAYMENT` | International/global payment recovery |
| `NONREV_REDEEMED_COUPON` | Coupon already redeemed |
| `NONREV_USED_POINTS` | Points already consumed |
| `NONREV_USED_WALLET_CREDIT` | Wallet/prepaid credit already used |
| `NONREV_CONSUMED_REMAKE` | Remake/replacement already consumed |
| `NONREV_WRONG_CUSTOMER_VALUE_USED` | Wrong customer consumed value |
| `NONREV_LEGAL_MESSAGE_SENT` | Legal-sensitive message already sent |
| `NONREV_PUBLIC_NOTICE_SENT` | Public/customer-read notice sent |
| `NONREV_PROVIDER_NO_REVERSAL` | Provider lacks reversal path |
| `NONREV_CHARGEBACK_DISPUTE` | Chargeback/dispute state affected |
| `NONREV_FRANCHISE_POLICY_GRANT` | Franchise policy-based grant |
| `NONREV_ALLERGEN_SAFETY_RECOVERY` | Allergen/safety recovery |
| `NONREV_PRIVACY_RECOVERY` | Privacy-sensitive recovery |
| `NONREV_HIGH_VALUE_GOODWILL` | High-value goodwill grant |

Each case family must define preventive controls and escalation route.

---

## 8. Preventive Control Catalog

| Control | Meaning |
|---|---|
| `PREVENT_EVIDENCE_REQUIRED` | Evidence required before action |
| `PREVENT_IDEMPOTENCY_REQUIRED` | Idempotency required |
| `PREVENT_FINANCE_APPROVAL_REQUIRED` | Finance approval required |
| `PREVENT_LEGAL_APPROVAL_REQUIRED` | Legal approval required |
| `PREVENT_SUPPORT_LEAD_APPROVAL_REQUIRED` | Support lead approval required |
| `PREVENT_OWNER_OR_HQ_APPROVAL_REQUIRED` | Owner/HQ approval required |
| `PREVENT_PROVIDER_CONFIRMATION_REQUIRED` | Provider confirmation required |
| `PREVENT_CUSTOMER_MESSAGE_HOLD` | Hold customer confirmation message |
| `PREVENT_TWO_STEP_APPROVAL` | Two-step approval required |
| `PREVENT_VALUE_LIMIT_CHECK` | Check value threshold |
| `PREVENT_FREQUENCY_LIMIT_CHECK` | Check repeated grant risk |
| `PREVENT_WRONG_CUSTOMER_CHECK` | Check customer/account match |
| `PREVENT_LEGAL_HOLD_CHECK` | Check legal hold |
| `PREVENT_RECON_PLAN_REQUIRED` | Reconciliation plan required |
| `PREVENT_ROLLBACK_PLAN_OR_NONREV_NOTE` | Rollback plan or non-reversible note required |

Preventive controls must be selected before execution.

---

## 9. Non-Reversible Action Record Schema

Each non-reversible action review should include:

| Field | Required Meaning |
|---|---|
| `nonrev_review_id` | Stable review id |
| `compensation_request_id` | Related compensation request |
| `evidence_packet_id` | Related evidence packet |
| `case_family` | Non-reversible case family |
| `nonrev_class` | Non-reversibility classification |
| `compensation_type` | Refund, coupon, point, wallet, remake, etc. |
| `value_amount` | Value amount |
| `currency_or_unit` | Currency, points, coupon, item |
| `customer_context_ref` | Masked customer/session reference |
| `provider_ref` | Provider reference if applicable |
| `reversibility_assessment` | Reversibility summary |
| `preventive_controls` | Required preventive controls |
| `authority_required` | Required authority |
| `review_route` | Review route |
| `customer_message_hold` | Whether message must be held |
| `reconciliation_plan_ref` | Reconciliation plan |
| `fallback_plan_ref` | Fallback plan |
| `audit_required` | Audit requirement |
| `approval_status` | Approval status |
| `blocker_id` | Blocker if incomplete |
| `status` | Review status |

A non-reversible review without reversibility assessment is incomplete.

---

## 10. Non-Reversible Review Status Catalog

| Status | Meaning |
|---|---|
| `NONREV_REVIEW_NOT_STARTED` | Review not started |
| `NONREV_REVIEW_REQUIRED` | Review required |
| `NONREV_REVERSIBILITY_UNKNOWN` | Reversibility unknown |
| `NONREV_EVIDENCE_REQUIRED` | Evidence required |
| `NONREV_PREVENTIVE_CONTROL_REQUIRED` | Preventive controls required |
| `NONREV_AUTHORITY_REQUIRED` | Authority required |
| `NONREV_FINANCE_REVIEW` | Finance review |
| `NONREV_LEGAL_REVIEW` | Legal review |
| `NONREV_PROVIDER_REVIEW` | Provider review |
| `NONREV_SECURITY_REVIEW` | Security review |
| `NONREV_APPROVED_WITH_CONTROLS` | Approved with controls |
| `NONREV_REJECTED` | Rejected |
| `NONREV_BLOCKED` | Blocked |
| `NONREV_EXECUTION_HOLD` | Execution held |
| `NONREV_CUSTOMER_MESSAGE_HOLD` | Customer message held |
| `NONREV_CLOSED_FOR_PLANNING` | Planning closure only |

Default:

`NONREV_REVIEW_REQUIRED`

---

## 11. Two-Step Approval Rule

High or critical non-reversible actions should use two-step approval.

Step 1:

- evidence review
- reversibility assessment
- idempotency check
- customer/account check
- provider capability check
- legal hold check

Step 2:

- authority approval
- customer message approval
- reconciliation plan approval
- audit requirement confirmation
- final execution decision in later package

This document defines two-step planning only.

It does not implement approval workflow.

---

## 12. Value Threshold Escalation Rule

Value thresholds must be defined in a later policy.

Planning candidate escalation:

| Value Risk | Required Escalation |
|---|---|
| Low value | Support lead or store manager review may be enough |
| Medium value | Support lead and owner/HQ policy review |
| High value | Finance and HQ approval |
| Critical value | Finance, legal, security, and HQ approval |
| Unknown value | Treat as high until classified |

Exact numeric thresholds are deferred.

No value threshold may be hardcoded without business approval.

---

## 13. Wrong Customer Prevention Rule

Before non-reversible action, the system must verify:

- customer/session scope
- order reference
- payment reference if applicable
- membership/account reference if applicable
- coupon/wallet/point account if applicable
- store/tenant scope
- support case reference
- no cross-customer exposure
- no wrong-account risk marker

Wrong-customer compensation is critical.

If wrong-customer risk exists, execution must be blocked or escalated.

---

## 14. Customer Message Hold Rule

For non-reversible actions, customer confirmation messages must be held until:

- authority approval exists
- action result is confirmed
- customer identity/scope is verified
- reconciliation requirement is understood
- message key is approved
- legal review is completed where needed

Allowed before confirmation:

- checking message
- review message
- support follow-up message

Not allowed before confirmation:

- refund confirmed
- coupon issued
- points added
- wallet credited
- replacement guaranteed
- provider fault confirmed
- legal responsibility admitted

---

## 15. Provider No-Reversal Rule

If provider does not support reversal:

- action must be classified high or critical
- provider evidence packet must document limitation
- finance/security review is required if value-bearing
- customer message must not overpromise
- idempotency and prevention become stricter
- reconciliation plan is required
- fallback/offset policy must be considered

Provider limitation must be visible to approver before action.

---

## 16. Redeemed Coupon Rule

Redeemed coupon correction is non-reversible or hard-to-reverse.

Required:

- original coupon id
- redemption evidence
- customer/account scope
- redemption timestamp
- order/payment relation
- value impact
- support/finance/owner route
- legal review if wrong-customer or dispute-sensitive
- customer-safe correction message
- recurrence prevention note

Voiding an unredeemed coupon differs from correcting a redeemed coupon.

---

## 17. Used Points Rule

Used point correction requires:

- original point ledger record
- usage evidence
- account verification
- point amount
- value impact
- reversal or offset plan
- customer notice review
- finance/value authority review
- audit

Used points must not be reversed silently.

---

## 18. Used Wallet Or Prepaid Credit Rule

Used wallet/prepaid correction is critical.

Required:

- original wallet/prepaid ledger record
- usage evidence
- account verification
- amount/currency
- finance/security review
- legal review if customer dispute risk
- reversal/offset plan
- customer notice review
- audit
- reconciliation

Wallet/prepaid credit is financial-value-bearing.

Prevention is stronger than rollback.

---

## 19. Legal Sensitive Message Rule

A legal-sensitive message is hard to reverse once sent.

Examples:

- allergen/safety acknowledgement
- privacy issue acknowledgement
- liability-related wording
- discrimination/harassment response
- regulatory complaint response
- high-value dispute response

Required:

- legal review before send
- approved message key
- exact wording control
- audit
- customer context verification
- follow-up route
- correction plan if later needed

AI-generated legal-sensitive message must not be sent without legal review.

---

## 20. Public Or External Notice Rule

If recovery message is projected externally or broadly visible:

- customer privacy must be protected
- provider blame must be avoided unless legally reviewed
- brand/legal tone must be reviewed
- message key must be approved
- correction path must be planned
- audit must exist

External notice can create brand and legal exposure.

---

## 21. Non-Reversible Reconciliation Rule

Non-reversible action still requires reconciliation.

Reconciliation should confirm:

- approval existed before execution
- idempotency was used
- value amount matches approval
- customer/account scope was correct
- provider/internal result was captured
- customer message matched actual state
- audit and evidence exist
- non-reversibility note is attached
- recurrence prevention action exists if failure occurred

Non-reversible does not mean unreconciled.

---

## 22. Recurrence Prevention Rule

If non-reversible correction occurs, a prevention review should identify:

- missing evidence
- missing authority
- missing idempotency
- wrong customer risk
- provider capability gap
- message overpromise
- workflow gap
- training gap
- policy gap
- test matrix gap

Recurring mistakes must update policy, tests, or support training.

---

## 23. AI Non-Reversible Action Boundary

AI may assist with:

- summarizing risk
- listing missing evidence
- drafting internal review note
- suggesting review route
- drafting customer message candidate

AI must not:

- classify action as safe by itself
- approve non-reversible action
- decide customer entitlement
- send message
- waive legal/finance review
- decide rollback impossibility
- close case

AI is advisory only.

---

## 24. pgvector Non-Reversible Action Boundary

pgvector may assist with:

- similar non-reversible cases
- prior policy lookup
- SOP reference retrieval
- evidence checklist retrieval

pgvector must not:

- prove current case
- approve non-reversible action
- replace evidence
- decide legal/finance route
- determine compensation amount
- close review

Similarity is not authority.

---

## 25. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/value_recovery/non_reversible_classes.*` | Non-reversibility class catalog |
| `catalogs/value_recovery/non_reversible_case_families.*` | Non-reversible case families |
| `catalogs/value_recovery/preventive_controls.*` | Preventive controls |
| `catalogs/value_recovery/nonrev_review_statuses.*` | Review statuses |
| `docs/value_recovery/non_reversible_action_review.md` | Review packet template |
| `docs/value_recovery/prevention_escalation_matrix.md` | Escalation matrix |

This is a layout candidate only.

No files are authorized.

---

## 26. Database Layout Candidate

If future implementation chooses database-backed non-reversible review, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `value_recovery_nonrev_reviews` | Non-reversible action reviews |
| `value_recovery_nonrev_controls` | Preventive control mapping |
| `value_recovery_nonrev_approvals` | Approval records |
| `value_recovery_nonrev_reconciliation` | Reconciliation records |
| `value_recovery_nonrev_prevention_reviews` | Recurrence prevention reviews |
| `value_recovery_nonrev_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 27. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-NONREV-0001` | Non-reversible action policy not reviewed |
| `BLOCKER-NONREV-CLASS-0001` | Non-reversibility class catalog missing |
| `BLOCKER-NONREV-CASE-0001` | Case family catalog missing |
| `BLOCKER-NONREV-CONTROL-0001` | Preventive control catalog missing |
| `BLOCKER-NONREV-SCHEMA-0001` | Review schema missing |
| `BLOCKER-NONREV-TWO-STEP-0001` | Two-step approval rule missing |
| `BLOCKER-NONREV-VALUE-THRESHOLD-0001` | Value threshold escalation missing |
| `BLOCKER-NONREV-WRONG-CUSTOMER-0001` | Wrong customer prevention missing |
| `BLOCKER-NONREV-MESSAGE-HOLD-0001` | Customer message hold rule missing |
| `BLOCKER-NONREV-PROVIDER-0001` | Provider no-reversal rule missing |
| `BLOCKER-NONREV-LEGAL-MSG-0001` | Legal-sensitive message rule missing |
| `BLOCKER-NONREV-RECON-0001` | Reconciliation rule missing |
| `BLOCKER-NONREV-CODING-0001` | Coding not authorized |

Open blockers prevent non-reversible action implementation.

---

## 28. Validation Checklist

Validation must confirm:

- non-reversible action definition exists
- non-reversibility classification exists
- case family catalog exists
- preventive control catalog exists
- record schema exists
- review status catalog exists
- two-step approval rule exists
- value threshold escalation rule exists
- wrong customer prevention rule exists
- customer message hold rule exists
- provider no-reversal rule exists
- redeemed coupon rule exists
- used points rule exists
- used wallet/prepaid rule exists
- legal-sensitive message rule exists
- public/external notice rule exists
- reconciliation rule exists
- recurrence prevention rule exists
- AI boundary exists
- pgvector boundary exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 29. Relationship To Previous Documents

This document follows:

- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09810 Value Recovery Reconciliation And Partial Execution Closure Policy`
- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`
- `09560` through `09820`

It prepares later planning for:

- non-reversible value action review packet
- preventive control matrix
- high-risk compensation escalation policy
- customer correction notice review
- future value recovery runtime handoff

This document is non-reversible value action and preventive control planning only.

It does not authorize coding.

---

## 30. Final Rule

Non-reversible value actions require stronger prevention than reversible actions.

If a refund, coupon, point, wallet, prepaid credit, replacement, customer message, provider action, legal-sensitive acknowledgement, or goodwill grant cannot be safely reversed, the system must require evidence, idempotency, customer/account verification, authority approval, message hold, audit, reconciliation, and recurrence prevention before execution.

AI and pgvector may assist with context and drafts, but cannot approve non-reversible action, decide reversibility, waive review, or close the case.

No non-reversible value action or preventive control implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
