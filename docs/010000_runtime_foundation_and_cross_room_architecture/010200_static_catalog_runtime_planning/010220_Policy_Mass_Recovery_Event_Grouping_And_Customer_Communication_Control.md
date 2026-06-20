# 010220_Policy_Mass_Recovery_Event_Grouping_And_Customer_Communication_Control.md

## Purpose

This document defines the Mass Recovery Event Grouping and Customer Communication Control Policy.

The previous artifact `09840` defined the High-Risk Compensation Escalation and Franchise Policy Inheritance Boundary Policy.

This document defines how customer recovery must be handled when an issue affects multiple customers, orders, stores, tenants, providers, menu projections, payment flows, KDS flows, coupons, wallets, points, or franchise policy layers.

The purpose is to prevent mass recovery events from being handled as isolated support cases without grouping, evidence, root-cause review, compensation consistency, customer message consistency, audit, and HQ-level coordination.

Mass recovery must be coordinated.

Mass recovery must not become uncontrolled apology, uncontrolled compensation, or inconsistent customer messaging.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to mass recovery planning for:

1. Provider outage recovery
2. POS handoff failure affecting multiple orders
3. Payment provider callback failure
4. Duplicate payment risk across customers
5. Coupon campaign error
6. Wallet/prepaid ledger issue
7. Point earning or redemption issue
8. Menu price projection mismatch
9. Allergen or safety text projection issue
10. Item availability or sold-out projection error
11. KDS delay or ticket duplication across orders
12. Catch Menu QR/NFC entry issue
13. Catch & Order order status issue
14. External projection or partner sync issue
15. Support message error affecting multiple customers
16. AI-generated message draft misuse
17. pgvector-assisted review pattern error
18. Store-level repeated failure
19. Franchise-wide policy recovery
20. Multi-tenant SaaS incident recovery

This document does not implement incident grouping, customer notification systems, compensation workflows, provider retry logic, support queues, audit tables, or runtime mass recovery logic.

---

## 3. Core Principle

Mass recovery is an incident-level recovery, not a pile of individual apologies.

The correct rule is:

Group first.
Classify impact.
Preserve evidence.
Stop the spread.
Control customer messages.
Escalate policy.
Review compensation consistently.
Reconcile value.
Close only after audit and evidence.

Mass recovery requires coordination across support, store operations, finance, legal, security, provider ops, product, and HQ/franchise policy where applicable.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09850` |
| Package ID | `mass_recovery.event_grouping.customer_communication_control.v1` |
| Artifact Type | `MASS_RECOVERY_CONTROL_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `MASS_RECOVERY_PLANNING_ONLY` |
| Owner | `HQ / Support / Finance / Legal / Security / Product / Franchise Ops` |
| Dependencies | `09560` to `09840` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_RELATED` |
| i18n Requirement | `REQUIRED_FOR_ALL_CUSTOMER_VISIBLE_MASS_RECOVERY_MESSAGES` |
| Audit Requirement | `REQUIRED_FOR_ALL_MASS_RECOVERY_EVENTS` |
| Security Requirement | `MASS_RECOVERY_BULKHEAD_AND_MESSAGE_CONTROL_REQUIRED` |
| Review Requirement | `HQ_SUPPORT_FINANCE_LEGAL_SECURITY_PROVIDER_FRANCHISE_REVIEW_REQUIRED` |
| Blocker Status | `MASS_RECOVERY_POLICY_REVIEW_REQUIRED` |

---

## 5. Mass Recovery Definition

A mass recovery event is a customer recovery situation where one root cause or related incident affects multiple customers, orders, stores, providers, sessions, accounts, benefits, messages, or operational surfaces.

A mass recovery event may be caused by:

- provider outage
- payment callback failure
- POS/KDS bridge issue
- menu projection error
- coupon campaign misconfiguration
- wallet/point ledger mismatch
- AI message misuse
- support template error
- external projection mismatch
- QR/NFC configuration issue
- store operational failure
- franchise policy conflict
- security containment or quarantine event
- legal/privacy issue affecting multiple customers

Mass recovery must be grouped and controlled.

---

## 6. Mass Recovery Event Family Catalog

| Event Family | Meaning |
|---|---|
| `MASS_RECOVERY_PROVIDER_OUTAGE` | Provider outage affects multiple customers |
| `MASS_RECOVERY_PAYMENT_CALLBACK` | Payment callback issue affects multiple payments |
| `MASS_RECOVERY_DUPLICATE_PAYMENT_RISK` | Duplicate payment risk across customers |
| `MASS_RECOVERY_POS_HANDOFF` | POS handoff failure across orders |
| `MASS_RECOVERY_KDS_DELAY` | KDS delay/ticket issue across orders |
| `MASS_RECOVERY_MENU_PRICE` | Menu price projection mismatch |
| `MASS_RECOVERY_MENU_AVAILABILITY` | Availability/sold-out mismatch |
| `MASS_RECOVERY_ALLERGEN_TEXT` | Allergen/safety text issue |
| `MASS_RECOVERY_COUPON_CAMPAIGN` | Coupon campaign issue |
| `MASS_RECOVERY_POINT_LEDGER` | Point ledger issue |
| `MASS_RECOVERY_WALLET_LEDGER` | Wallet/prepaid issue |
| `MASS_RECOVERY_EXTERNAL_PROJECTION` | External projection issue |
| `MASS_RECOVERY_QR_NFC_ENTRY` | QR/NFC entry issue |
| `MASS_RECOVERY_SUPPORT_TEMPLATE` | Support/customer message template issue |
| `MASS_RECOVERY_AI_DRAFT_MISUSE` | AI draft misuse or unsafe suggestion |
| `MASS_RECOVERY_SECURITY_CONTAINMENT` | Security containment affects operations |
| `MASS_RECOVERY_FRANCHISE_POLICY` | Franchise policy issue affects multiple stores |

Each event family must define grouping, evidence, message, compensation, and closure rules.

---

## 7. Mass Recovery Severity Catalog

| Severity | Meaning |
|---|---|
| `MASS_SEV_INFO` | Informational, low customer impact |
| `MASS_SEV_MINOR` | Minor inconvenience |
| `MASS_SEV_MODERATE` | Multiple customers affected, manageable |
| `MASS_SEV_MAJOR` | High customer trust or value impact |
| `MASS_SEV_CRITICAL` | Financial/legal/safety/privacy risk |
| `MASS_SEV_BLOCKED` | Action blocked pending authority |

Default for payment, wallet, allergen, privacy, and wrong-customer mass events:

`MASS_SEV_CRITICAL`

---

## 8. Mass Recovery Grouping Rule

Mass recovery grouping should consider:

- shared root cause
- shared provider
- shared store
- shared tenant
- shared menu version
- shared campaign
- shared time window
- shared payment provider
- shared POS/KDS bridge
- shared customer message key
- shared support template
- shared AI draft source
- shared external projection source
- shared security containment/quarantine context

Do not treat related cases as isolated if evidence indicates common cause.

---

## 9. Mass Recovery Event Record Schema

Each mass recovery event should include:

| Field | Required Meaning |
|---|---|
| `mass_recovery_event_id` | Stable event id |
| `event_family` | Mass recovery event family |
| `severity` | Severity |
| `tenant_scope` | Tenant scope |
| `store_scope` | Store or store group scope |
| `provider_scope` | Provider scope if applicable |
| `time_window_start` | Start time |
| `time_window_end` | End time |
| `affected_customer_count_estimate` | Estimated customer count |
| `affected_order_count_estimate` | Estimated order count |
| `affected_value_estimate` | Estimated value impact |
| `root_cause_status` | Root-cause status |
| `evidence_packet_ref` | Evidence packet reference |
| `provider_evidence_status` | Provider evidence status |
| `bulkhead_status` | Containment/bulkhead status |
| `customer_message_strategy` | Message strategy |
| `compensation_strategy` | Compensation strategy |
| `escalation_level` | Escalation level |
| `audit_required` | Audit requirement |
| `closure_status` | Closure status |
| `blocker_id` | Blocker if incomplete |

A mass recovery event without grouping evidence is incomplete.

---

## 10. Root Cause Status Catalog

| Status | Meaning |
|---|---|
| `ROOT_CAUSE_UNKNOWN` | Unknown |
| `ROOT_CAUSE_UNDER_REVIEW` | Under review |
| `ROOT_CAUSE_PROVIDER_CANDIDATE` | Provider candidate |
| `ROOT_CAUSE_STORE_CANDIDATE` | Store candidate |
| `ROOT_CAUSE_SYSTEM_CANDIDATE` | System candidate |
| `ROOT_CAUSE_POLICY_CANDIDATE` | Policy candidate |
| `ROOT_CAUSE_MESSAGE_TEMPLATE_CANDIDATE` | Message/template candidate |
| `ROOT_CAUSE_AI_DRAFT_CANDIDATE` | AI draft candidate |
| `ROOT_CAUSE_EXTERNAL_PROJECTION_CANDIDATE` | External projection candidate |
| `ROOT_CAUSE_CONFIRMED` | Confirmed |
| `ROOT_CAUSE_DISPUTED` | Disputed |
| `ROOT_CAUSE_UNRESOLVED` | Unresolved |
| `ROOT_CAUSE_CLOSED_WITH_EVIDENCE` | Closed with evidence |

Do not communicate root cause as confirmed before evidence supports it.

---

## 11. Customer Communication Strategy Catalog

| Strategy | Meaning |
|---|---|
| `COMM_HOLD` | Hold customer communication |
| `COMM_SAFE_STATUS_ONLY` | Safe status only |
| `COMM_SUPPORT_MEDIATED` | Support-mediated communication |
| `COMM_STORE_STAFF_ASSISTED` | Store staff assisted communication |
| `COMM_TARGETED_CUSTOMER_NOTICE` | Targeted notice to affected customers |
| `COMM_BROAD_NOTICE` | Broad notice |
| `COMM_CORRECTION_NOTICE` | Correction notice |
| `COMM_LEGAL_REVIEW_REQUIRED` | Legal review required |
| `COMM_PROVIDER_REVIEW_REQUIRED` | Provider review required |
| `COMM_HQ_APPROVED_NOTICE` | HQ-approved notice |
| `COMM_BLOCKED` | Communication blocked |

Default for uncertain high-risk events:

`COMM_SAFE_STATUS_ONLY`

---

## 12. Compensation Strategy Catalog

| Strategy | Meaning |
|---|---|
| `COMP_STRATEGY_NONE` | No compensation planned |
| `COMP_STRATEGY_REVIEW_ONLY` | Review only |
| `COMP_STRATEGY_CASE_BY_CASE` | Case-by-case review |
| `COMP_STRATEGY_STANDARDIZED_LOW_VALUE` | Standardized low-value recovery |
| `COMP_STRATEGY_STANDARDIZED_WITH_LIMITS` | Standardized with limits |
| `COMP_STRATEGY_FINANCE_APPROVAL_REQUIRED` | Finance approval required |
| `COMP_STRATEGY_LEGAL_APPROVAL_REQUIRED` | Legal approval required |
| `COMP_STRATEGY_PROVIDER_RESPONSIBILITY_REVIEW` | Provider responsibility review |
| `COMP_STRATEGY_HQ_POLICY_REQUIRED` | HQ policy required |
| `COMP_STRATEGY_BLOCKED` | Compensation blocked |

Compensation strategy must not exceed policy inheritance limits.

---

## 13. Provider Outage Mass Recovery Rule

Provider outage mass recovery requires:

- provider evidence packet
- provider outage window
- affected feature list
- affected store/tenant scope
- affected customer/order estimate
- customer message strategy
- compensation strategy
- provider responsibility review
- finance/legal review if value or liability exists
- audit
- closure after provider/internal reconciliation

Provider outage must not be blamed publicly without evidence and review.

---

## 14. Payment Callback Mass Recovery Rule

Payment callback mass recovery is critical.

Required:

- payment provider evidence
- callback verification status
- replay/duplicate risk review
- affected payment list
- internal ledger comparison
- idempotency review
- customer message hold or safe status
- finance/security review
- reconciliation plan
- audit

Customer messages must not say paid/refunded/canceled until verified.

---

## 15. Coupon Campaign Mass Recovery Rule

Coupon campaign mass recovery requires:

- campaign policy reference
- affected coupon list
- issue type
- duplicate issuance risk
- redemption status
- customer segment impact
- value exposure estimate
- owner/HQ policy review
- finance/value review if needed
- customer message strategy
- audit and reconciliation

Coupon campaign correction must preserve customer trust without uncontrolled value leakage.

---

## 16. Wallet Point Mass Recovery Rule

Wallet/point mass recovery requires:

- ledger impact estimate
- affected account list under privacy controls
- duplicate prevention
- value correction plan
- finance/security review
- customer message strategy
- reconciliation plan
- audit
- legal review if customer trust or privacy impact exists

Wallet/prepaid mass recovery is financial-value-bearing and must be treated as critical.

---

## 17. Menu Price Availability Mass Recovery Rule

Menu price or availability mass recovery requires:

- menu version evidence
- projection source evidence
- affected item list
- affected store list
- affected order/customer estimate
- price/value impact estimate
- customer message strategy
- compensation strategy if customer paid incorrect value
- product/support review
- legal review if allergen/safety involved
- audit

Menu projection error may affect both customer trust and value recovery.

---

## 18. Allergen Safety Mass Recovery Rule

Allergen/safety mass recovery is critical.

Required:

- affected menu version
- affected locale/translation
- affected item list
- affected customer/order estimate if known
- product/quality review
- legal review
- support lead review
- customer communication strategy
- external projection correction
- archive/evidence preservation
- audit
- incident escalation

Do not issue ordinary apology templates for allergen/safety mass recovery.

---

## 19. Support Template Or Message Error Rule

If an incorrect support/customer message template affected multiple customers:

- identify message key
- identify locale/version
- identify affected customers
- identify sent channel
- identify promise boundary violation
- prepare correction notice
- route legal/finance review if value/legal issue
- audit original and corrected message
- update i18n registry and test matrix
- prevent reuse until reviewed

Message error can be a mass recovery incident.

---

## 20. AI Draft Misuse Mass Recovery Rule

If AI-drafted text contributed to unsafe customer communication:

- identify AI draft source
- identify approval failure
- identify affected message keys
- identify affected customers
- block further reuse
- preserve evidence
- route AI governance review
- route legal/finance/security review if needed
- prepare customer-safe correction
- update AI boundary policy and test matrix

AI misuse must not be treated as ordinary support error.

---

## 21. pgvector Pattern Error Rule

If pgvector similarity context contributed to incorrect recovery:

- identify vector source
- identify retrieved context
- identify reviewer decision path
- verify whether similarity was treated as proof
- preserve evidence
- route data governance review
- block unsafe source if needed
- update approved source registry
- update support training and test matrix

Similarity misuse is a governance issue.

---

## 22. Mass Recovery Communication Control Rule

Mass recovery communication must define:

- who may communicate
- which audience receives message
- whether message is targeted or broad
- which i18n key is used
- whether legal review is required
- whether finance review is required
- whether provider is named
- whether compensation is mentioned
- whether correction notice is needed
- whether customer action is requested
- whether follow-up is promised

Mass communication must not be improvised.

---

## 23. Mass Recovery Compensation Consistency Rule

For the same mass event, compensation should be consistent unless policy supports differences.

Differences may be justified by:

- different customer impact
- different payment state
- different order value
- different evidence
- different store policy
- different legal jurisdiction
- different usage/redemption state
- different customer action required

Inconsistent compensation requires explanation and audit.

---

## 24. Mass Recovery Closure Rule

Mass recovery may close only when:

- affected scope is identified or reasonably bounded
- root cause status is documented
- customer message strategy is complete
- compensation strategy is complete or explicitly not applicable
- evidence packets are linked
- audit references exist
- provider/internal reconciliation is complete where needed
- high-risk cases are escalated
- correction notices are sent or deferred with reason
- recurrence prevention review is complete
- closure decision is recorded

Mass recovery closure must not hide unresolved individual cases.

---

## 25. Recurrence Prevention Rule

Mass recovery recurrence prevention should identify:

- provider capability gap
- bulkhead failure
- evidence gap
- idempotency gap
- reconciliation gap
- i18n/message key gap
- support template gap
- AI/pgvector misuse
- store training gap
- policy inheritance gap
- external projection gap
- test matrix gap

Prevention findings must feed future policy or implementation handoff.

---

## 26. AI Mass Recovery Boundary

AI may assist with:

- summarizing affected cases
- drafting internal incident summary
- identifying likely grouping
- listing missing evidence
- drafting customer message candidates
- suggesting review routes

AI must not:

- declare root cause confirmed
- decide affected scope finally
- approve mass compensation
- send customer messages
- determine provider fault
- close mass recovery
- suppress recurrence prevention

AI is advisory only.

---

## 27. pgvector Mass Recovery Boundary

pgvector may assist with:

- similar incident retrieval
- previous mass recovery references
- SOP and policy retrieval
- known provider pattern references
- evidence checklist retrieval

pgvector must not:

- prove root cause
- prove affected scope
- approve compensation
- decide customer communication
- determine provider liability
- close event

Similarity is not root cause proof.

---

## 28. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/mass_recovery/event_families.*` | Mass recovery event family catalog |
| `catalogs/mass_recovery/severity_levels.*` | Severity catalog |
| `catalogs/mass_recovery/root_cause_statuses.*` | Root-cause status catalog |
| `catalogs/mass_recovery/communication_strategies.*` | Communication strategy catalog |
| `catalogs/mass_recovery/compensation_strategies.*` | Compensation strategy catalog |
| `docs/mass_recovery/event_review_packet.md` | Mass recovery packet template |
| `docs/mass_recovery/customer_communication_review.md` | Communication review packet |

This is a layout candidate only.

No files are authorized.

---

## 29. Database Layout Candidate

If future implementation chooses database-backed mass recovery review, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `mass_recovery_events` | Mass recovery event records |
| `mass_recovery_event_cases` | Linked individual cases |
| `mass_recovery_affected_scope` | Affected scope records |
| `mass_recovery_communications` | Communication strategy records |
| `mass_recovery_compensation_strategy` | Compensation strategy records |
| `mass_recovery_evidence_refs` | Evidence references |
| `mass_recovery_closure_decisions` | Closure decisions |
| `mass_recovery_prevention_reviews` | Recurrence prevention reviews |

This is a data-model candidate only.

No tables are authorized.

---

## 30. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-MASS-RECOVERY-0001` | Mass recovery policy not reviewed |
| `BLOCKER-MASS-RECOVERY-FAMILY-0001` | Event family catalog missing |
| `BLOCKER-MASS-RECOVERY-SEVERITY-0001` | Severity catalog missing |
| `BLOCKER-MASS-RECOVERY-GROUPING-0001` | Grouping rule missing |
| `BLOCKER-MASS-RECOVERY-SCHEMA-0001` | Event record schema missing |
| `BLOCKER-MASS-RECOVERY-ROOT-CAUSE-0001` | Root-cause status catalog missing |
| `BLOCKER-MASS-RECOVERY-COMM-0001` | Communication strategy missing |
| `BLOCKER-MASS-RECOVERY-COMP-0001` | Compensation strategy missing |
| `BLOCKER-MASS-RECOVERY-PAYMENT-0001` | Payment mass recovery rule missing |
| `BLOCKER-MASS-RECOVERY-ALLERGEN-0001` | Allergen/safety mass recovery rule missing |
| `BLOCKER-MASS-RECOVERY-AI-0001` | AI misuse rule missing |
| `BLOCKER-MASS-RECOVERY-PGVECTOR-0001` | pgvector misuse rule missing |
| `BLOCKER-MASS-RECOVERY-CODING-0001` | Coding not authorized |

Open blockers prevent mass recovery implementation.

---

## 31. Validation Checklist

Validation must confirm:

- mass recovery definition exists
- event family catalog exists
- severity catalog exists
- grouping rule exists
- event record schema exists
- root-cause status catalog exists
- communication strategy catalog exists
- compensation strategy catalog exists
- provider outage rule exists
- payment callback rule exists
- coupon campaign rule exists
- wallet/point rule exists
- menu price/availability rule exists
- allergen/safety rule exists
- support template/message error rule exists
- AI draft misuse rule exists
- pgvector pattern error rule exists
- communication control rule exists
- compensation consistency rule exists
- closure rule exists
- recurrence prevention rule exists
- AI boundary exists
- pgvector boundary exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 32. Relationship To Previous Documents

This document follows:

- `09840 High-Risk Compensation Escalation And Franchise Policy Inheritance Boundary Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09810 Value Recovery Reconciliation And Partial Execution Closure Policy`
- `09820 Value Recovery Rollback Reversal And Customer Correction Notice Policy`
- `09830 Non-Reversible Value Action And Preventive Control Escalation Policy`
- `09840 High-Risk Compensation Escalation And Franchise Policy Inheritance Boundary Policy`
- `09560` through `09840`

It prepares later planning for:

- mass recovery event review packet
- mass customer communication review
- grouped compensation strategy
- provider outage recovery package
- AI/pgvector misuse recovery governance
- future mass recovery implementation handoff

This document is mass recovery event grouping and customer communication control planning only.

It does not authorize coding.

---

## 33. Final Rule

Mass recovery must be grouped, classified, evidenced, communicated, compensated, reconciled, and closed as an incident-level recovery.

Multiple related customer cases must not be handled as isolated cases when a common root cause exists.

Customer messages must be controlled, localized, reviewed, and consistent.

Compensation must follow policy inheritance and high-risk escalation.

AI and pgvector may assist with grouping and context, but cannot confirm root cause, approve mass compensation, determine customer communication, or close the event.

No mass recovery event grouping or customer communication implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
