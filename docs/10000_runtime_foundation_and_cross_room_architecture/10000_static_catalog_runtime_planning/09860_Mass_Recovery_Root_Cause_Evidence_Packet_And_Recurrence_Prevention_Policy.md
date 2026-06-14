# 09860 Mass Recovery Root Cause Evidence Packet And Recurrence Prevention Policy

## 1. Purpose

This document defines the Mass Recovery Root Cause Evidence Packet and Recurrence Prevention Policy.

The previous artifact `09850` defined the Mass Recovery Event Grouping and Customer Communication Control Policy.

This document defines how mass recovery events must collect, preserve, classify, review, and close root cause evidence before recurrence prevention measures are accepted.

The purpose is to prevent mass recovery events from being closed with vague explanations, unsupported provider blame, unsupported store blame, unsupported AI conclusions, incomplete evidence, or customer communication that is not backed by root cause review.

Mass recovery closure requires more than customer response.

Mass recovery closure requires recurrence prevention.

This document is planning-only.

It does not authorize coding.

---

## 2. Scope

This policy applies to root cause evidence and recurrence prevention planning for:

1. Provider outage mass recovery
2. Payment callback mass recovery
3. POS handoff mass recovery
4. KDS delay or duplication mass recovery
5. Coupon campaign mass recovery
6. Wallet/prepaid mass recovery
7. Point ledger mass recovery
8. Menu price projection mass recovery
9. Menu availability mass recovery
10. Allergen/safety text mass recovery
11. External projection mass recovery
12. QR/NFC entry mass recovery
13. Catch Menu surface issue recovery
14. Catch & Order status issue recovery
15. Support template or customer message error
16. AI draft misuse recovery
17. pgvector pattern misuse recovery
18. Franchise policy conflict recovery
19. Multi-store or multi-tenant recovery
20. Legal/privacy-sensitive mass recovery

This document does not implement root cause analysis tools, dashboards, incident workflows, provider integrations, audit tables, recurrence prevention jobs, or runtime controls.

---

## 3. Core Principle

Root cause must be evidenced, not guessed.

The correct rule is:

Suspected cause is not confirmed cause.
Provider claim is not proof.
AI summary is not proof.
pgvector similarity is not proof.
Support opinion is not proof.
Customer complaint cluster is a signal, not proof.
Closure requires evidence and prevention.

A mass recovery event may be closed only when root cause status, evidence packet, customer communication, compensation strategy, recurrence prevention, and audit are aligned.

---

## 4. Catalog Header

| Field | Value |
|---|---|
| Document ID | `09860` |
| Package ID | `mass_recovery.root_cause_evidence.recurrence_prevention.v1` |
| Artifact Type | `MASS_RECOVERY_ROOT_CAUSE_POLICY` |
| Version | `v1` |
| Planning Status | `FOUNDATION_CANDIDATE` |
| Coding Status | `CODING_DEFERRED` |
| Runtime Authority | `ROOT_CAUSE_PREVENTION_PLANNING_ONLY` |
| Owner | `HQ / Support / Product / Security / Provider Ops / Franchise Ops` |
| Dependencies | `09560` to `09850` |
| Provider Evidence Status | `CARRY_FORWARD_IF_PROVIDER_RELATED` |
| i18n Requirement | `REQUIRED_IF_ROOT_CAUSE_SUMMARY_IS_CUSTOMER_VISIBLE` |
| Audit Requirement | `REQUIRED_FOR_ALL_MASS_RECOVERY_ROOT_CAUSE_DECISIONS` |
| Security Requirement | `ROOT_CAUSE_EVIDENCE_AND_PREVENTION_REQUIRED` |
| Review Requirement | `HQ_SUPPORT_PRODUCT_SECURITY_PROVIDER_FINANCE_LEGAL_REVIEW_AS_NEEDED` |
| Blocker Status | `ROOT_CAUSE_EVIDENCE_PREVENTION_REVIEW_REQUIRED` |

---

## 5. Root Cause Evidence Packet Definition

A Root Cause Evidence Packet is a structured packet that records the evidence used to classify, confirm, dispute, or leave unresolved the root cause of a mass recovery event.

It may include:

- event grouping evidence
- affected scope evidence
- provider evidence
- payment evidence
- POS/KDS evidence
- menu projection evidence
- i18n/message evidence
- support workflow evidence
- AI draft evidence
- pgvector context evidence
- archive/audit evidence
- customer impact evidence
- compensation impact evidence
- recurrence prevention findings
- closure decision

Root cause evidence packet does not execute remediation.

It supports review and closure.

---

## 6. Root Cause Evidence Packet Record Schema

Each root cause packet should include:

| Field | Required Meaning |
|---|---|
| `root_cause_packet_id` | Stable packet id |
| `mass_recovery_event_id` | Related mass recovery event |
| `event_family` | Event family |
| `severity` | Severity |
| `tenant_scope` | Tenant scope |
| `store_scope` | Store scope |
| `provider_scope` | Provider scope if applicable |
| `time_window_start` | Start time |
| `time_window_end` | End time |
| `suspected_root_causes` | Suspected causes |
| `confirmed_root_cause` | Confirmed cause if any |
| `root_cause_status` | Root cause status |
| `evidence_items` | Evidence list |
| `evidence_strength` | Evidence strength |
| `affected_scope_ref` | Affected scope reference |
| `customer_impact_summary` | Customer impact summary |
| `value_impact_summary` | Value impact summary |
| `communication_strategy_ref` | Communication strategy |
| `compensation_strategy_ref` | Compensation strategy |
| `prevention_actions` | Prevention actions |
| `review_route` | Review route |
| `audit_ref` | Audit reference |
| `closure_status` | Closure status |
| `blocker_id` | Blocker if incomplete |

A packet without evidence strength and prevention actions is incomplete.

---

## 7. Root Cause Status Catalog

| Status | Meaning |
|---|---|
| `ROOT_CAUSE_NOT_STARTED` | Root cause review not started |
| `ROOT_CAUSE_SIGNAL_DETECTED` | Signal detected |
| `ROOT_CAUSE_SUSPECTED` | Suspected |
| `ROOT_CAUSE_EVIDENCE_REQUIRED` | Evidence required |
| `ROOT_CAUSE_UNDER_REVIEW` | Under review |
| `ROOT_CAUSE_PROVIDER_CANDIDATE` | Provider candidate |
| `ROOT_CAUSE_STORE_CANDIDATE` | Store candidate |
| `ROOT_CAUSE_SYSTEM_CANDIDATE` | System candidate |
| `ROOT_CAUSE_POLICY_CANDIDATE` | Policy candidate |
| `ROOT_CAUSE_MESSAGE_CANDIDATE` | Message/template candidate |
| `ROOT_CAUSE_AI_CANDIDATE` | AI draft candidate |
| `ROOT_CAUSE_VECTOR_CANDIDATE` | pgvector misuse candidate |
| `ROOT_CAUSE_CONFIRMED` | Confirmed by evidence |
| `ROOT_CAUSE_DISPUTED` | Disputed |
| `ROOT_CAUSE_UNRESOLVED_WITH_PREVENTION` | Unresolved but prevention applied |
| `ROOT_CAUSE_CLOSED_WITH_EVIDENCE` | Closed with evidence |

Default:

`ROOT_CAUSE_EVIDENCE_REQUIRED`

---

## 8. Evidence Strength Catalog

| Strength | Meaning |
|---|---|
| `RC_EVIDENCE_NONE` | No evidence |
| `RC_EVIDENCE_SIGNAL_ONLY` | Signal only |
| `RC_EVIDENCE_CUSTOMER_REPORT_CLUSTER` | Customer reports clustered |
| `RC_EVIDENCE_INTERNAL_LOG_CLUSTER` | Internal logs clustered |
| `RC_EVIDENCE_PROVIDER_CLAIM` | Provider claim only |
| `RC_EVIDENCE_PROVIDER_DOCUMENTED` | Provider documented |
| `RC_EVIDENCE_PROVIDER_CONFIRMED` | Provider confirmed with evidence |
| `RC_EVIDENCE_RECONCILED` | Reconciled with internal evidence |
| `RC_EVIDENCE_AUDITED` | Audited |
| `RC_EVIDENCE_LEGAL_REVIEWED` | Legal reviewed |
| `RC_EVIDENCE_SECURITY_REVIEWED` | Security reviewed |
| `RC_EVIDENCE_CONFIRMED` | Confirmed enough for closure |

Customer report cluster may trigger investigation.

It does not confirm root cause by itself.

---

## 9. Root Cause Candidate Catalog

| Candidate | Meaning |
|---|---|
| `RC_PROVIDER_OUTAGE` | Provider outage |
| `RC_PROVIDER_CALLBACK_FAILURE` | Provider callback failure |
| `RC_PROVIDER_CAPABILITY_GAP` | Provider capability gap |
| `RC_PAYMENT_RECON_GAP` | Payment reconciliation gap |
| `RC_POS_HANDOFF_GAP` | POS handoff gap |
| `RC_KDS_ROUTING_GAP` | KDS routing gap |
| `RC_MENU_PROJECTION_GAP` | Menu projection gap |
| `RC_I18N_MESSAGE_GAP` | i18n or message key gap |
| `RC_SUPPORT_TEMPLATE_GAP` | Support template gap |
| `RC_AI_DRAFT_GOVERNANCE_GAP` | AI draft governance gap |
| `RC_VECTOR_CONTEXT_MISUSE` | pgvector similarity misuse |
| `RC_POLICY_INHERITANCE_GAP` | Franchise policy inheritance gap |
| `RC_STORE_TRAINING_GAP` | Store training gap |
| `RC_BULKHEAD_GAP` | Bulkhead/containment gap |
| `RC_IDEMPOTENCY_GAP` | Idempotency gap |
| `RC_RECONCILIATION_GAP` | Reconciliation gap |
| `RC_UNKNOWN` | Unknown |

Candidates must be tested against evidence.

---

## 10. Affected Scope Evidence Rule

Affected scope must be bounded by evidence.

Evidence may include:

- time window
- store list
- tenant list
- provider list
- menu version list
- message key list
- payment reference list
- order reference list
- coupon campaign list
- wallet/point ledger list
- KDS ticket group
- QR/NFC entry group
- external projection source
- support template version
- AI draft source
- pgvector source reference

Affected scope must not be guessed for final closure.

---

## 11. Provider Root Cause Evidence Rule

Provider root cause requires:

- provider evidence packet
- provider status or incident report if available
- callback/log evidence
- signature/replay verification where relevant
- affected time window
- affected feature/capability
- internal corroboration
- provider capability status
- contract/SLA review if needed
- customer impact mapping
- compensation strategy mapping

Provider claim alone is not sufficient for high-risk closure.

---

## 12. Payment Root Cause Evidence Rule

Payment root cause requires:

- payment provider evidence
- callback evidence
- internal payment state
- ledger comparison
- duplicate payment check
- idempotency evidence
- reconciliation status
- affected customer/payment list under privacy control
- finance/security review
- customer message strategy

Payment root cause cannot close without reconciliation path.

---

## 13. POS KDS Root Cause Evidence Rule

POS/KDS root cause requires:

- POS handoff logs or event evidence
- KDS ticket evidence
- store context
- duplicate order/ticket review
- timing evidence
- staff/store notes
- provider/bridge evidence if applicable
- affected order list
- customer impact summary
- recurrence prevention action

POS/KDS evidence must not be treated as payment truth.

---

## 14. Menu Projection Root Cause Evidence Rule

Menu projection root cause requires:

- menu version evidence
- projection source evidence
- affected store/item list
- affected locale if applicable
- price/availability/allergen fields affected
- external projection status if applicable
- customer/order impact estimate
- product/content/legal review where needed
- recurrence prevention action

Allergen/safety projection requires legal/product escalation.

---

## 15. Message And i18n Root Cause Evidence Rule

Message/i18n root cause requires:

- message key
- locale
- copy version
- approval status
- channel
- sent audience
- affected customer list if sent
- promise boundary violation if any
- translation review status
- correction notice requirement
- i18n registry update
- test matrix update

A message key issue may become a mass recovery event.

---

## 16. AI Draft Root Cause Evidence Rule

AI draft root cause requires:

- AI draft reference
- prompt/context category if available
- data source approval status
- review path that allowed output
- customer-visible exposure status
- affected message keys
- affected cases/customers
- governance gap
- corrective action
- AI boundary policy update
- support training update

AI draft cannot be blamed without evidence.

AI draft cannot be allowed to publish without human review.

---

## 17. pgvector Misuse Root Cause Evidence Rule

pgvector misuse root cause requires:

- vector source reference
- retrieval result reference
- similarity use context
- reviewer decision path
- evidence of similarity treated as proof if applicable
- affected cases
- approved source registry status
- data governance review
- corrective action
- test matrix update

pgvector is context.

Misusing similarity as proof is a governance failure.

---

## 18. Policy Inheritance Root Cause Evidence Rule

Franchise policy inheritance root cause requires:

- applicable HQ policy
- tenant/franchise policy
- owner/store policy
- campaign/customer segment policy if any
- conflict description
- precedence rule applied
- exception record if any
- affected stores/customers
- compensation impact
- HQ/franchise review
- policy registry update

Policy conflict is not support discretion.

---

## 19. Recurrence Prevention Action Catalog

| Action | Meaning |
|---|---|
| `PREVENT_PROVIDER_CAPABILITY_UPDATE` | Update provider capability evidence |
| `PREVENT_PROVIDER_RETRY_RULE_UPDATE` | Update provider retry/idempotency rule |
| `PREVENT_PAYMENT_RECON_UPDATE` | Update payment reconciliation rule |
| `PREVENT_POS_HANDOFF_TEST_UPDATE` | Update POS handoff boundary test |
| `PREVENT_KDS_ROUTING_TEST_UPDATE` | Update KDS routing test |
| `PREVENT_MENU_PROJECTION_TEST_UPDATE` | Update menu projection test |
| `PREVENT_I18N_KEY_REVIEW_UPDATE` | Update i18n key review |
| `PREVENT_SUPPORT_TEMPLATE_REVIEW` | Review support template |
| `PREVENT_AI_GOVERNANCE_UPDATE` | Update AI governance rule |
| `PREVENT_VECTOR_SOURCE_REVIEW` | Review vector source |
| `PREVENT_POLICY_REGISTRY_UPDATE` | Update policy registry |
| `PREVENT_STORE_TRAINING_UPDATE` | Update store training/SOP |
| `PREVENT_BULKHEAD_RULE_UPDATE` | Update bulkhead/containment rule |
| `PREVENT_RUNBOOK_UPDATE` | Update runbook |
| `PREVENT_TEST_MATRIX_UPDATE` | Update boundary test matrix |

Every root cause packet should include at least one prevention decision.

---

## 20. Recurrence Prevention Record Schema

Each prevention record should include:

| Field | Required Meaning |
|---|---|
| `prevention_id` | Stable prevention id |
| `root_cause_packet_id` | Root cause packet |
| `mass_recovery_event_id` | Mass recovery event |
| `root_cause_candidate` | Root cause candidate |
| `prevention_action` | Prevention action |
| `owner` | Owner |
| `required_review` | Required review |
| `policy_doc_ref` | Policy/doc reference |
| `test_matrix_ref` | Test matrix reference |
| `training_ref` | Training reference if any |
| `provider_packet_ref` | Provider packet if any |
| `status` | Prevention status |
| `due_status` | Due status if tracked later |
| `audit_ref` | Audit reference |
| `blocker_id` | Blocker if incomplete |

A prevention record without owner is incomplete.

---

## 21. Prevention Status Catalog

| Status | Meaning |
|---|---|
| `PREVENTION_NOT_STARTED` | Not started |
| `PREVENTION_REQUIRED` | Required |
| `PREVENTION_OWNER_ASSIGNED` | Owner assigned |
| `PREVENTION_REVIEW_REQUIRED` | Review required |
| `PREVENTION_PLANNED` | Planned |
| `PREVENTION_IMPLEMENTATION_DEFERRED` | Implementation deferred |
| `PREVENTION_VERIFICATION_REQUIRED` | Verification required |
| `PREVENTION_VERIFIED` | Verified |
| `PREVENTION_BLOCKED` | Blocked |
| `PREVENTION_NOT_APPLICABLE_WITH_REASON` | Not applicable with reason |
| `PREVENTION_CLOSED_FOR_PLANNING` | Planning closure |

Default:

`PREVENTION_REQUIRED`

---

## 22. Closure Requirement

A root cause packet may close only when:

- root cause status is documented
- evidence strength is recorded
- affected scope is bounded
- customer communication status is recorded
- compensation strategy status is recorded
- high-risk escalation status is recorded
- audit reference exists
- recurrence prevention decision exists
- unresolved items are explicitly recorded
- reopening conditions are defined

Closure without prevention is incomplete.

---

## 23. Reopen Conditions

A closed root cause packet must be reopened if:

- new evidence contradicts root cause
- provider later disputes or changes finding
- affected scope expands
- customer correction notice was wrong
- compensation inconsistency appears
- legal hold is applied
- security review changes classification
- AI/vector misuse is discovered
- policy conflict is discovered
- recurrence occurs within related scope

Reopen must be auditable.

---

## 24. AI Root Cause Boundary

AI may assist with:

- summarizing event evidence
- proposing candidate causes
- identifying missing evidence
- drafting internal root cause summary
- suggesting prevention actions
- finding related policy documents

AI must not:

- confirm root cause
- assign blame
- approve customer communication
- approve compensation
- close root cause packet
- suppress recurrence prevention
- override provider/finance/legal/security review

AI is advisory only.

---

## 25. pgvector Root Cause Boundary

pgvector may assist with:

- similar incident retrieval
- previous root cause packets
- SOP/policy lookup
- provider pattern reference
- prevention checklist retrieval

pgvector must not:

- prove root cause
- confirm affected scope
- decide compensation
- approve closure
- replace evidence
- assign blame

Similarity is not proof.

---

## 26. File Layout Candidate

If future implementation chooses files, candidate paths may be:

| Path Candidate | Purpose |
|---|---|
| `catalogs/mass_recovery/root_cause_statuses.*` | Root cause status catalog |
| `catalogs/mass_recovery/root_cause_candidates.*` | Root cause candidate catalog |
| `catalogs/mass_recovery/evidence_strengths.*` | Evidence strength catalog |
| `catalogs/mass_recovery/prevention_actions.*` | Prevention action catalog |
| `catalogs/mass_recovery/prevention_statuses.*` | Prevention status catalog |
| `docs/mass_recovery/root_cause_packet_template.md` | Root cause packet template |
| `docs/mass_recovery/recurrence_prevention_review.md` | Prevention review packet |

This is a layout candidate only.

No files are authorized.

---

## 27. Database Layout Candidate

If future implementation chooses database-backed root cause review, candidate table families may be:

| Table Family Candidate | Purpose |
|---|---|
| `mass_recovery_root_cause_packets` | Root cause evidence packets |
| `mass_recovery_root_cause_evidence` | Evidence items |
| `mass_recovery_root_cause_candidates` | Candidate records |
| `mass_recovery_prevention_records` | Prevention records |
| `mass_recovery_prevention_reviews` | Prevention reviews |
| `mass_recovery_root_cause_reopen_events` | Reopen events |
| `mass_recovery_root_cause_change_log` | Change history |

This is a data-model candidate only.

No tables are authorized.

---

## 28. Readiness Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-ROOT-CAUSE-0001` | Root cause policy not reviewed |
| `BLOCKER-ROOT-CAUSE-PACKET-0001` | Packet schema missing |
| `BLOCKER-ROOT-CAUSE-STATUS-0001` | Root cause status catalog missing |
| `BLOCKER-ROOT-CAUSE-STRENGTH-0001` | Evidence strength catalog missing |
| `BLOCKER-ROOT-CAUSE-CANDIDATE-0001` | Root cause candidate catalog missing |
| `BLOCKER-ROOT-CAUSE-SCOPE-0001` | Affected scope evidence rule missing |
| `BLOCKER-ROOT-CAUSE-PROVIDER-0001` | Provider root cause evidence rule missing |
| `BLOCKER-ROOT-CAUSE-PAYMENT-0001` | Payment root cause evidence rule missing |
| `BLOCKER-ROOT-CAUSE-I18N-0001` | Message/i18n evidence rule missing |
| `BLOCKER-ROOT-CAUSE-AI-0001` | AI root cause rule missing |
| `BLOCKER-ROOT-CAUSE-PGVECTOR-0001` | pgvector root cause rule missing |
| `BLOCKER-ROOT-CAUSE-PREVENTION-0001` | Prevention action catalog missing |
| `BLOCKER-ROOT-CAUSE-CODING-0001` | Coding not authorized |

Open blockers prevent root cause and recurrence prevention implementation.

---

## 29. Validation Checklist

Validation must confirm:

- root cause evidence packet definition exists
- packet record schema exists
- root cause status catalog exists
- evidence strength catalog exists
- root cause candidate catalog exists
- affected scope evidence rule exists
- provider root cause evidence rule exists
- payment root cause evidence rule exists
- POS/KDS evidence rule exists
- menu projection evidence rule exists
- message/i18n evidence rule exists
- AI draft evidence rule exists
- pgvector misuse evidence rule exists
- policy inheritance evidence rule exists
- recurrence prevention action catalog exists
- prevention record schema exists
- prevention status catalog exists
- closure requirement exists
- reopen conditions exist
- AI boundary exists
- pgvector boundary exists
- layout candidates are non-authorizing
- coding remains deferred

---

## 30. Relationship To Previous Documents

This document follows:

- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`

It references:

- `09631 Bulkhead Domain Map Source Of Truth And Trust Boundary Catalog`
- `09635 Security Event Alert Families And Severity Routing Catalog`
- `09636 Unix-Style Error Code Catalog And Domain Fault Mapping Policy`
- `09640 pgvector Approved Source Traceability Lifecycle And Authority Boundary Catalog`
- `09680 Provider Evidence Collection Template And Capability Review Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09780 Customer Recovery Message Catalog And Compensation Review Boundary Policy`
- `09840 High-Risk Compensation Escalation And Franchise Policy Inheritance Boundary Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09560` through `09850`

It prepares later planning for:

- root cause evidence packet
- recurrence prevention review packet
- mass recovery closure package
- provider incident review
- AI/pgvector governance update
- boundary test matrix update
- future mass recovery implementation handoff

This document is mass recovery root cause evidence and recurrence prevention planning only.

It does not authorize coding.

---

## 31. Final Rule

Mass recovery root cause must be evidenced, not guessed.

A root cause packet must record candidate causes, evidence strength, affected scope, customer impact, value impact, communication strategy, compensation strategy, prevention actions, audit references, closure status, and reopen conditions.

AI and pgvector may assist with summaries, similar cases, and prevention suggestions, but cannot confirm root cause, assign blame, approve compensation, approve customer communication, or close the packet.

No mass recovery root cause evidence or recurrence prevention implementation may proceed until a separate narrow handoff grants `CODING_ALLOWED`, declares target files or data structures, maps boundary tests, resolves blockers, and defines rollback.
