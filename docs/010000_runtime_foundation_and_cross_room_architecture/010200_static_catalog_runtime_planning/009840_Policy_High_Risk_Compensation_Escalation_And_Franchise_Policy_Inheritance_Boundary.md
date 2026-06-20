# 009840_Policy_High_Risk_Compensation_Escalation_And_Franchise_Policy_Inheritance_Boundary

## 1. Purpose

This document defines the High-Risk Compensation Escalation and Franchise Policy Inheritance Boundary Policy.

The previous artifact `09830` defined the Non-Reversible Value Action and Preventive Control Escalation Policy.

This document defines how high-risk compensation cases must be escalated across store, owner, HQ, finance, legal, security, provider operations, and future Franchise OS policy layers.

The purpose is to prevent compensation decisions from being applied inconsistently across stores, tenants, franchisees, providers, customer segments, languages, and support channels.

High-risk compensation must not depend only on support discretion.

High-risk compensation must inherit from controlled policy.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to escalation and policy inheritance planning for:

1. High-value refund review
2. High-value coupon or goodwill grant
3. Wallet/prepaid credit correction
4. Point adjustment above threshold
5. Repeated customer recovery cases
6. Wrong-customer value recovery
7. Legal-sensitive compensation
8. Allergen/safety-related compensation
9. Privacy-related compensation
10. Chargeback/dispute-related recovery
11. Provider-caused mass issue recovery
12. Store-caused repeated failure recovery
13. Franchisee policy-bound compensation
14. Owner-approved store-level compensation
15. HQ-approved cross-store compensation
16. Multi-tenant SaaS compensation policy boundaries
17. External provider responsibility review
18. Customer correction notice escalation
19. Non-reversible value action escalation
20. Franchise OS customer recovery policy inheritance

This document does not implement escalation workflows, role permissions, approval screens, compensation engines, policy engines, runtime thresholds, or franchise policy modules.

---

## 3. Core Principle

High-risk compensation must follow policy, not mood.

The correct rule is:

Store may assist.
Support may review.
Owner may approve within policy.
HQ may define policy.
Finance controls financial-value authority.
Legal controls legal-sensitive response.
Security controls abuse and trust risk.
Provider ops verifies provider responsibility.
AI and pgvector provide context only.

Compensation authority must be explicit, inherited, scoped, and auditable.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09840` |
| Package ID | `compensation.high_risk_escalation.franchise_policy_inheritance.v1` |
| Artifact Type | `HIGH_RISK_COMPENSATION_ESCALATION_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `ESCALATION_POLICY_PLANNING_ONLY` |
| Owner | `HQ / Support / Finance / Legal / Security / Franchise Ops` |
| Dependencies | `09560` to `09830` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_OR_PROVIDER_POLICY_RELATED` |
| i18n Requirement | `REQUIRED_FOR_CUSTOMER_VISIBLE_ESCALATION_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_ALL_HIGH_RISK_COMPENSATION_ESCALATION` |
| Security Requirement | `HIGH_RISK_COMPENSATION_AUTHORITY_SEPARATION_REQUIRED` |
| Review Requirement | `HQ_SUPPORT_FINANCE_LEGAL_SECURITY_FRANCHISE_REVIEW_REQUIRED` |
| Blocker Status | `HIGH_RISK_COMPENSATION_ESCALATION_REVIEW_REQUIRED` |

---

## 5. High-Risk Compensation Definition

High-risk compensation is any recovery action that may create material financial, legal, operational, customer trust, provider, franchise, or abuse risk.

High-risk compensation may include:

- high-value refund
- repeated refund request
- high-value coupon
- wallet/prepaid credit
- large point adjustment
- legal-sensitive recovery
- allergen/safety recovery
- privacy-sensitive recovery
- wrong-customer recovery
- cross-store recovery
- provider-caused mass recovery
- public customer correction
- non-reversible action
- franchisee policy exception
- owner/HQ override
- repeated goodwill grant

High-risk compensation requires escalation.

---

## 6. Escalation Trigger Catalog

| Trigger | Meaning |
|---|---|
| `ESC_VALUE_THRESHOLD_EXCEEDED` | Value exceeds threshold |
| `ESC_REPEAT_CUSTOMER_CASE` | Repeated customer recovery |
| `ESC_REPEAT_STORE_FAILURE` | Repeated store failure |
| `ESC_WRONG_CUSTOMER_RISK` | Wrong customer/account risk |
| `ESC_PAYMENT_DISPUTE_RISK` | Payment dispute/chargeback risk |
| `ESC_WALLET_PREPAID_RISK` | Wallet/prepaid financial risk |
| `ESC_LEGAL_SENSITIVE` | Legal-sensitive issue |
| `ESC_ALLERGEN_SAFETY` | Allergen/safety issue |
| `ESC_PRIVACY_SENSITIVE` | Privacy-sensitive issue |
| `ESC_PROVIDER_MASS_FAILURE` | Provider-caused mass failure |
| `ESC_PROVIDER_CAPABILITY_UNVERIFIED` | Provider capability unverified |
| `ESC_NON_REVERSIBLE_ACTION` | Non-reversible action |
| `ESC_CUSTOMER_MESSAGE_CORRECTION` | Customer message correction needed |
| `ESC_FRANCHISE_POLICY_EXCEPTION` | Franchise policy exception |
| `ESC_OWNER_HQ_POLICY_CONFLICT` | Owner/HQ policy conflict |
| `ESC_ABUSE_FRAUD_RISK` | Abuse/fraud risk |
| `ESC_SECURITY_CONTAINMENT_CONTEXT` | Security/containment context exists |

Any trigger may escalate review route.

---

## 7. Escalation Level Catalog

| Escalation Level | Meaning |
|---|---|
| `ESC_LEVEL_NONE` | No escalation required |
| `ESC_LEVEL_STORE_MANAGER` | Store manager review |
| `ESC_LEVEL_OWNER` | Owner review |
| `ESC_LEVEL_SUPPORT_LEAD` | Support lead review |
| `ESC_LEVEL_FINANCE` | Finance review |
| `ESC_LEVEL_PROVIDER_OPS` | Provider operations review |
| `ESC_LEVEL_SECURITY` | Security review |
| `ESC_LEVEL_LEGAL` | Legal/compliance review |
| `ESC_LEVEL_HQ_SUPPORT` | HQ support review |
| `ESC_LEVEL_HQ_POLICY` | HQ policy review |
| `ESC_LEVEL_FRANCHISE_OPS` | Franchise operations review |
| `ESC_LEVEL_EXECUTIVE_EXCEPTION` | Executive exception review |
| `ESC_LEVEL_BLOCKED` | Blocked pending policy |

Default for high-risk cases:

`ESC_LEVEL_SUPPORT_LEAD`

---

## 8. Franchise Policy Inheritance Definition

Franchise policy inheritance defines how compensation policy flows from HQ to tenant, franchise operator, owner, store, support team, and customer-facing message.

A future Franchise OS may define:

- global HQ policy
- brand policy
- tenant policy
- franchise operator policy
- store-level policy
- campaign/event policy
- provider-specific policy
- customer segment policy
- locale/legal jurisdiction policy
- emergency policy

Lower-level policy may be more restrictive.

Lower-level policy must not exceed HQ-defined authority unless explicitly allowed.

---

## 9. Policy Inheritance Layer Catalog

| Layer | Meaning |
|---|---|
| `POLICY_LAYER_HQ_GLOBAL` | HQ global compensation policy |
| `POLICY_LAYER_BRAND` | Brand-level policy |
| `POLICY_LAYER_TENANT` | Tenant/customer company policy |
| `POLICY_LAYER_FRANCHISE_OPERATOR` | Franchise operator policy |
| `POLICY_LAYER_OWNER` | Owner-level policy |
| `POLICY_LAYER_STORE` | Store-level policy |
| `POLICY_LAYER_PROVIDER` | Provider-specific policy |
| `POLICY_LAYER_CAMPAIGN` | Campaign/event policy |
| `POLICY_LAYER_CUSTOMER_SEGMENT` | Customer segment policy |
| `POLICY_LAYER_LOCALE_LEGAL` | Locale/legal jurisdiction policy |
| `POLICY_LAYER_EMERGENCY` | Emergency temporary policy |

Policy precedence must be explicit.

---

## 10. Policy Precedence Rule

When policies conflict, the safer and more restrictive rule should apply unless higher authority explicitly approves an exception.

Recommended precedence:

1. Legal/compliance restriction
2. Security/abuse restriction
3. Finance/value authority restriction
4. HQ global policy
5. Brand policy
6. Locale/legal jurisdiction policy
7. Tenant/franchise operator policy
8. Owner policy
9. Store policy
10. Campaign/customer segment policy
11. Support discretion

Support discretion must not override legal, security, finance, or HQ restrictions.

---

## 11. High-Risk Compensation Review Record Schema

Each high-risk compensation review should include:

| Field | Required Meaning |
|---|---|
| `high_risk_review_id` | Stable review id |
| `compensation_request_id` | Related compensation request |
| `evidence_packet_id` | Related evidence packet |
| `reconciliation_id` | Related reconciliation if any |
| `rollback_request_id` | Related rollback if any |
| `nonrev_review_id` | Related non-reversible review if any |
| `tenant_id_scope` | Tenant scope |
| `store_id_scope` | Store scope |
| `policy_layer_applied` | Policy layer applied |
| `policy_ref` | Policy reference |
| `escalation_triggers` | Trigger list |
| `escalation_level` | Required escalation level |
| `value_amount` | Value amount |
| `currency_or_unit` | Currency, point, coupon, wallet, item |
| `authority_required` | Required authority |
| `review_route` | Review route |
| `provider_evidence_status` | Provider evidence if relevant |
| `customer_message_key` | Customer message key |
| `approval_status` | Approval status |
| `audit_required` | Audit requirement |
| `blocker_id` | Blocker if incomplete |
| `status` | Review status |

A high-risk review without policy reference is incomplete.

---

## 12. High-Risk Review Status Catalog

| Status | Meaning |
|---|---|
| `HIGH_RISK_REVIEW_NOT_STARTED` | Review not started |
| `HIGH_RISK_REVIEW_REQUIRED` | Review required |
| `HIGH_RISK_POLICY_REF_REQUIRED` | Policy reference required |
| `HIGH_RISK_EVIDENCE_REQUIRED` | Evidence required |
| `HIGH_RISK_SUPPORT_LEAD_REVIEW` | Support lead review |
| `HIGH_RISK_FINANCE_REVIEW` | Finance review |
| `HIGH_RISK_LEGAL_REVIEW` | Legal review |
| `HIGH_RISK_SECURITY_REVIEW` | Security review |
| `HIGH_RISK_PROVIDER_REVIEW` | Provider review |
| `HIGH_RISK_OWNER_REVIEW` | Owner review |
| `HIGH_RISK_HQ_REVIEW` | HQ review |
| `HIGH_RISK_FRANCHISE_REVIEW` | Franchise ops review |
| `HIGH_RISK_APPROVED_WITH_LIMITS` | Approved with limits |
| `HIGH_RISK_REJECTED` | Rejected |
| `HIGH_RISK_BLOCKED` | Blocked |
| `HIGH_RISK_CLOSED_FOR_PLANNING` | Planning closure only |

Default:

`HIGH_RISK_REVIEW_REQUIRED`

---

## 13. Role Authority Separation Rule

High-risk compensation must separate:

| Role | Allowed By Default |
|---|---|
| Store Staff | Observe, assist, report |
| Store Manager | Review store facts, request recovery |
| Owner | Approve within owner policy limits |
| Support Agent | Prepare review, draft customer response |
| Support Lead | Approve limited recovery if policy allows |
| Finance | Approve/review financial value |
| Legal | Approve legal-sensitive wording/action |
| Security | Review abuse/fraud/security risk |
| Provider Ops | Verify provider responsibility/capability |
| HQ Support | Approve HQ-level recovery |
| HQ Policy | Define policy and exceptions |
| Franchise Ops | Review franchise policy conflicts |

No single role should own all high-risk authority.

---

## 14. Store-Level Escalation Rule

Store-level escalation applies when:

- staff reports issue
- KDS/remake issue occurs
- item missing or delayed
- local availability mismatch occurs
- local staff assistance is required
- customer is physically present
- store fact confirmation is needed

Store-level review may confirm facts.

Store-level review must not approve high-risk financial value unless policy allows.

---

## 15. Owner-Level Escalation Rule

Owner-level escalation applies when:

- store compensation policy allows owner approval
- compensation affects store margin
- goodwill grant is store-funded
- repeated store failure exists
- owner policy exception is requested
- franchise policy delegates limited authority

Owner approval must remain within policy limits.

Owner approval must not override legal, security, finance, or HQ restrictions.

---

## 16. Finance Escalation Rule

Finance escalation applies when:

- refund or payment cancel is involved
- wallet/prepaid credit is involved
- high-value coupon/point is involved
- duplicate payment risk exists
- settlement/reconciliation issue exists
- provider financial mismatch exists
- wrong amount was credited
- chargeback/dispute risk exists

Finance review controls financial accuracy.

Finance review does not replace legal/security review where needed.

---

## 17. Legal Escalation Rule

Legal escalation applies when:

- allergen/safety issue exists
- privacy issue exists
- injury/health claim exists
- legal demand is made
- regulatory complaint exists
- liability-sensitive wording is needed
- wrong-customer value issue creates privacy risk
- public/external correction notice is required
- high-value dispute exists

Legal review controls legal-sensitive messaging and response.

---

## 18. Security Escalation Rule

Security escalation applies when:

- abuse/fraud risk exists
- repeated compensation requests appear abnormal
- identity mismatch exists
- wrong account/customer risk exists
- provider callback trust issue exists
- containment/quarantine context exists
- payment/security anomaly exists
- support authority abuse risk exists

Security review does not approve compensation amount.

Security review blocks or conditions risky actions.

---

## 19. Provider Ops Escalation Rule

Provider ops escalation applies when:

- provider caused or may have caused failure
- provider capability is unverified
- provider callback is inconsistent
- provider replay/signature risk exists
- provider supports or does not support reversal
- provider SLA or contract may affect recovery
- provider financial responsibility may exist

Provider ops verifies provider context.

Provider ops does not replace internal authority.

---

## 20. HQ And Franchise Escalation Rule

HQ/franchise escalation applies when:

- policy exception is requested
- compensation is above owner/store threshold
- multi-store issue exists
- brand-level recovery standard is affected
- franchise consistency is needed
- tenant policy conflicts with HQ rule
- provider mass failure affects multiple stores
- public brand issue exists
- future SaaS customer contract terms apply

HQ policy defines the ceiling.

Franchise policy may define local operation within that ceiling.

---

## 21. Customer Message Escalation Rule

Customer-visible messages must escalate when they involve:

- high-value compensation
- refund confirmation
- wallet/prepaid correction
- wrong-customer correction
- legal-sensitive wording
- public/external notice
- provider responsibility
- apology with implied fault
- correction of prior incorrect message
- non-reversible recovery

Customer message must not exceed approved authority.

---

## 22. Policy Exception Rule

A policy exception must record:

| Field | Meaning |
|---|---|
| `exception_id` | Stable exception id |
| `policy_ref` | Policy being excepted |
| `requested_by` | Requester role |
| `reason` | Reason |
| `case_family` | Case family |
| `value_amount` | Value amount |
| `risk_class` | Risk class |
| `approval_route` | Required approval route |
| `legal_review` | Legal review if needed |
| `finance_review` | Finance review if needed |
| `security_review` | Security review if needed |
| `expiry` | Exception expiry |
| `audit_ref` | Audit reference |

Policy exception must not become permanent silent policy.

---

## 23. Policy Conflict Rule

If policies conflict:

- identify each applicable policy layer
- identify stricter rule
- identify authority ceiling
- block action if conflict affects legal/security/finance
- route to HQ/franchise policy review
- record decision
- update policy registry if needed

Policy conflict is not support discretion.

---

## 24. Mass Recovery Escalation Rule

Mass recovery applies when issue affects multiple customers or stores.

Examples:

- provider outage
- POS handoff bug
- menu price projection issue
- coupon campaign error
- wallet/point ledger error
- payment provider callback failure
- allergen text projection issue
- QR/NFC entry failure
- external projection error

Mass recovery requires HQ-level coordination, evidence grouping, customer message consistency, and audit.

---

## 25. Abuse And Frequency Control Rule

High-risk compensation must consider:

- repeated claims by same customer
- repeated claims at same store
- repeated claims with same provider
- repeated support agent approvals
- high ratio of goodwill grants
- suspicious timing or pattern
- mismatched identity/account context
- abnormal coupon/point/wallet activity

Abuse controls must not punish legitimate customers automatically.

They trigger review.

---

## 26. AI Escalation Boundary

AI may assist with:

- summarizing escalation reason
- suggesting review route
- listing applicable policy layers
- drafting customer-safe message candidate
- identifying missing evidence
- surfacing similar cases

AI must not:

- choose final escalation level
- approve exception
- override policy
- approve compensation
- send customer message
- decide legal/security/finance outcome

AI is advisory only.

---

## 27. pgvector Escalation Boundary

pgvector may assist with:

- similar escalation cases
- policy retrieval
- SOP retrieval
- previous issue pattern reference
- evidence checklist reference

pgvector must not:

- prove abuse
- prove entitlement
- approve escalation outcome
- override policy
- decide exception
- close review

Similarity is not authority.

---

## 28. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/compensation/escalation_triggers.*` | Escalation trigger catalog |
| `catalogs/compensation/escalation_levels.*` | Escalation level catalog |
| `catalogs/compensation/policy_layers.*` | Policy inheritance layers |
| `catalogs/compensation/policy_precedence.*` | Policy precedence rule |
| `catalogs/compensation/high_risk_review_statuses.*` | High-risk review statuses |
| `docs/compensation/high_risk_escalation_packet.md` | Review packet template |
| `docs/compensation/franchise_policy_inheritance.md` | Franchise policy inheritance packet |

This is a layout candidate only.

No files are authorized.

---

## 29. Database Layout Candidate

If future implementation chooses database-backed escalation policy, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `compensation_escalation_triggers` | Trigger catalog |
| `compensation_escalation_levels` | Level catalog |
| `compensation_policy_layers` | Policy inheritance layers |
| `compensation_policy_refs` | Policy references |
| `compensation_high_risk_reviews` | High-risk review records |
| `compensation_policy_exceptions` | Policy exception records |
| `compensation_policy_conflicts` | Conflict records |
| `compensation_abuse_frequency_reviews` | Abuse/frequency review records |

This is a data-model candidate only.

No tables are authorized.

---

## 30. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-HIGH-RISK-COMP-0001` | High-risk escalation policy not reviewed |
| `BLOCKER-HIGH-RISK-TRIGGER-0001` | Escalation trigger catalog missing |
| `BLOCKER-HIGH-RISK-LEVEL-0001` | Escalation level catalog missing |
| `BLOCKER-HIGH-RISK-POLICY-LAYER-0001` | Policy inheritance layers missing |
| `BLOCKER-HIGH-RISK-PRECEDENCE-0001` | Policy precedence rule missing |
| `BLOCKER-HIGH-RISK-SCHEMA-0001` | Review record schema missing |
| `BLOCKER-HIGH-RISK-ROLE-0001` | Role authority separation missing |
| `BLOCKER-HIGH-RISK-FINANCE-0001` | Finance escalation rule missing |
| `BLOCKER-HIGH-RISK-LEGAL-0001` | Legal escalation rule missing |
| `BLOCKER-HIGH-RISK-SECURITY-0001` | Security escalation rule missing |
| `BLOCKER-HIGH-RISK-PROVIDER-0001` | Provider ops escalation rule missing |
| `BLOCKER-HIGH-RISK-FRANCHISE-0001` | Franchise escalation rule missing |
| `BLOCKER-HIGH-RISK-CODING-0001` | Coding not authorized |

Open blockers prevent high-risk compensation escalation implementation.

---

## 31. Validation Checklist

Validation must confirm:

- high-risk compensation definition exists
- escalation trigger catalog exists
- escalation level catalog exists
- franchise policy inheritance definition exists
- policy inheritance layer catalog exists
- policy precedence rule exists
- high-risk compensation review schema exists
- high-risk review status catalog exists
- role authority separation rule exists
- store-level escalation rule exists
- owner-level escalation rule exists
- finance escalation rule exists
- legal escalation rule exists
- security escalation rule exists
- provider ops escalation rule exists
- HQ/franchise escalation rule exists
- customer message escalation rule exists
- policy exception rule exists
- policy conflict rule exists
- mass recovery escalation rule exists
- abuse/frequency control rule exists
- AI boundary exists
- pgvector boundary exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 32. Relationship To Previous Documents

This document follows:

- `09830 Non-Reversible Value Action And Preventive Control Escalation Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09634 Security Control Records And Security Class Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09810 Value Recovery Reconciliation And Partial Execution Closure Policy`
- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`
- `09830 Non-Reversible Value Action And Preventive Control Escalation Policy`
- `09560` through `09830`

It prepares later planning for:

- high-risk compensation escalation packet
- franchise policy inheritance registry
- compensation policy exception workflow
- mass recovery policy
- abuse/frequency review
- future Franchise OS recovery policy module

This document is high-risk compensation escalation and franchise policy inheritance planning only.

It does not authorize coding.

---

## 33. Final Rule

High-risk compensation must be governed by explicit escalation and policy inheritance.

Store, owner, support, finance, legal, security, provider ops, HQ, and franchise ops roles must remain separated.

Support discretion cannot override legal, security, finance, provider evidence, or HQ policy boundaries.

Policy exceptions must be recorded, reviewed, time-scoped where applicable, and auditable.

AI and pgvector may assist with context and drafts, but cannot approve escalation outcome, override policy, grant exceptions, or close high-risk compensation cases.

No high-risk compensation escalation or franchise policy inheritance implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
