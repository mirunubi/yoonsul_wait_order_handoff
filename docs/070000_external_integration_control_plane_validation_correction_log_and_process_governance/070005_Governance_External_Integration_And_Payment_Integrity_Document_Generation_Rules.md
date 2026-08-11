# 070005_Governance_External_Integration_And_Payment_Integrity_Document_Generation_Rules.md

## Document Control

- Document Number: 70005
- Document Type: Governance
- Domain: External Integration Control Plane / Payment Integrity Architecture
- Status: Draft
- Root Index: [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](./070000_Readme_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md)
- Related Integrity Index: [75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md](./75000_Index_Payment_Integrity_Architecture_Self_Healing_Distributed_Transaction_And_Ledger_Governance.md)
- Previous: [70000_Index_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md](./070000_Readme_External_Integration_Control_Plane_Validation_Correction_Log_And_Process_Governance.md)
- Next: [70100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md](./070100_Index_POS_VAN_PG_And_External_Payment_Integration_Governance.md)

---

## 1. Purpose

This document defines mandatory rules for generating, expanding, reviewing, and maintaining Markdown documents in the 70000 External Integration Control Plane and 75000 Payment Integrity Architecture lanes.

The purpose is to prevent uncontrolled document generation from creating plausible but unsafe financial, operational, or legal rules.

The 70000 and 75000 lanes control external integration, money movement, payment state, settlement, reconciliation, evidence, dispute, and recovery. Therefore, document generation must be treated as a controlled governance process, not as free-form content creation.

---

## 2. Scope

### 2.1 In Scope

This governance applies to documents covering:

- POS, VAN, PG, simple payment, card acquirer, global payment, settlement file, webhook, delivery app, external order app, kiosk vendor, KDS vendor, external membership, coupon, voucher, point, tax, accounting, ERP, and bank integrations;
- external event validation, correction, logging, evidence, reconciliation, and recovery;
- payment idempotency, duplicate prevention, timeout unknown state, inquiry, net cancel, reversal, compensation, Saga, transactional outbox, CDC, double-entry ledger, and settlement audit;
- local payment agent, CAT terminal, serial port, COM port, secure boot, E2E encryption, masking, watchdog, and hardware evidence.

### 2.2 Out of Scope

This document does not itself define provider-specific financial rules. It defines how such documents must be generated and controlled.

---

## 3. Mandatory Filename Rule

Every file must follow the approved project naming format:

```text
NNNNN_DocumentType_Title.md
```

The H1 must exactly match the full filename, including `.md`.

Example:

```markdown
# 70150_Policy_External_Payment_Timeout_Unknown_State_Inquiry_And_Ambiguous_Result_Control.md
```

No document in the 70000 or 75000 lanes may be created without:

- a five-digit numeric prefix;
- approved DocumentType immediately after the numeric prefix;
- underscore-separated title tokens;
- `.md` extension;
- exact H1 match.

---

## 4. Approved Document Types

Only the following DocumentType values may be used unless a project owner explicitly approves a new type:

```text
Policy
SOP
Checklist
Readme
Index
Runbook
Evidence
Audit
Governance
Boundary
Matrix
Template
Register
Report
Assessment
WorkPackage
Implementation
Guide
Spec
ADR
```

For this lane, recommended usage is:

| DocumentType | Usage |
|---|---|
| Index | Opens or closes a numbered document bundle. |
| Governance | Defines authority, ownership, responsibility, and generation rules. |
| Policy | Defines mandatory operating rules. |
| Spec | Defines canonical fields, schemas, codes, or contracts. |
| Matrix | Defines state transitions, failure modes, or responsibility mapping. |
| Runbook | Defines incident, recovery, and operator action flow. |
| Audit | Defines evidence, hash, tamper check, retention, and reconciliation proof. |
| SOP | Defines repeated human operating procedure. |
| Checklist | Defines readiness, certification, or review gate items. |
| Register | Defines controlled list, gap list, risk list, or provider catalog. |
| Template | Defines reusable evidence packet, request form, or review form. |

---

## 5. Numbering Governance

### 5.1 70000 Lane

The 70000 lane is reserved for external integration control.

```text
70000~70999  External payment integration, POS/VAN/PG, response validation, webhook, provider event control
71000~71999  External order, delivery app, membership, coupon, kiosk, KDS, accounting, tax, ERP integration
72000~72999  External integration test, certification, monitoring, evidence, operator SOP, admin override, closeout
```

### 5.2 75000 Lane

The 75000 lane is reserved for payment integrity architecture.

```text
75000~75999  Payment integrity root, idempotency, duplicate prevention, unknown state, self-healing, recovery
76000~76999  Net cancel, reversal, compensation, Saga, distributed transaction recovery
77000~77999  Transactional outbox, CDC, event relay, dual-write prevention, eventual consistency
78000~78999  Double-entry ledger, settlement, reconciliation, deposit, fee, accounting integrity
79000~79999  Local payment hardware, CAT terminal, VAN agent, serial port, secure boot, masking, watchdog integrity
```

The exact ranges may be expanded, but a new range must be opened by an Index document and recorded in the root index.

---

## 6. Non-Invention Rule

Document generation tools, agents, or editors must not invent operational or financial rules.

The following are prohibited without source, approved architecture decision, or explicit project-owner instruction:

- redefining payment states;
- inventing provider response codes;
- inventing settlement cycles;
- inventing legal obligations;
- inventing cancellation/refund restrictions;
- inventing liability allocation;
- inventing hardware encryption requirements;
- inventing tax, fee, VAT, or accounting rules;
- assuming a provider supports inquiry, cancel inquiry, webhook, or settlement export;
- assuming timeout equals failure;
- assuming external success equals internal confirmation;
- assuming successful payment permits order completion without validation.

When uncertain, the document must use one of the following labels:

```text
TODO
GAP
PROVIDER_SPECIFIC
LEGAL_REVIEW_REQUIRED
VENDOR_CONFIRMATION_REQUIRED
IMPLEMENTATION_DECISION_REQUIRED
```

---

## 7. Required Section Structure

Every 70000/75000 document should include the following sections unless not applicable:

```text
1. Purpose
2. Scope
3. Control Principle
4. Authority / Ownership
5. Data or Event Boundary
6. Validation Rules
7. Failure Modes
8. Recovery / Compensation / Escalation
9. Evidence / Logging / Retention
10. Cross-Links
11. Open Gaps
12. Acceptance Criteria
```

Index documents should additionally include:

```text
- Document Set
- Numbering Map
- Handoff Targets
- Closeout Criteria
```

Runbook documents should additionally include:

```text
- Trigger Conditions
- Immediate Triage
- Prohibited Actions
- Manager Action
- Engineering Action
- Customer Communication Boundary
- Evidence Packet
- Closeout Condition
```

Audit documents should additionally include:

```text
- Evidence Source
- Raw Payload Retention
- Hash Rule
- Tamper Check
- Reconciliation Link
- Legal Hold Link
```

---

## 8. Mandatory Cross-Link Rule

Every document must include links to:

- root index or parent index;
- previous document;
- next document;
- related 70000 external integration document where applicable;
- related 75000 payment integrity document where applicable;
- related SOP or Runbook where human operation is required;
- related Audit or Evidence document where financial proof is required.

No document may stand alone if it affects payment, settlement, customer claim, or external provider integration.

---

## 9. Payment State Safety Rule

The following state vocabulary must be treated as controlled vocabulary until replaced by a formally approved state machine document:

```text
REQUESTED
SENT_TO_PROVIDER
RESPONSE_RECEIVED
VALIDATION_PENDING
CONFIRMED
DECLINED
TIMEOUT_UNKNOWN
AMBIGUOUS
MISMATCHED
INQUIRY_PENDING
REVERSAL_PENDING
CANCEL_PENDING
CANCELLED
REFUND_PENDING
REFUNDED
MANUAL_REVIEW
RECONCILIATION_EXCEPTION
RECONCILED
```

No generated document may create a new payment state without registering it in a state machine or matrix document.

---

## 10. External Provider Trust Rule

External providers may produce events, responses, files, callbacks, and settlement records. They do not own the internal final state.

Internal final state may be set only after:

- the original request ledger is located;
- the inbound response or event is stored;
- raw payload is preserved where applicable;
- canonical mapping succeeds;
- amount and order validation succeeds;
- duplicate and replay checks pass;
- timeout or ambiguous conditions are excluded or resolved;
- audit evidence is sufficient;
- reconciliation requirement is satisfied or explicitly deferred.

---

## 11. Generation Tool Instruction

When using Cursor, agent scripts, or other automated tools, the following instruction must be given before bulk generation:

```text
Do not invent financial rules.
Do not redefine payment states.
Do not remove existing documents.
Do not rename files unless explicitly instructed.
Generate Markdown files only from the provided document list and template.
Every file must follow the filename rule: NNNNN_DocumentType_Title.md.
The H1 must exactly match the full filename including .md.
Use cross-links to parent index, previous document, next document, and related governance documents.
Mark uncertain operational details as TODO, GAP, PROVIDER_SPECIFIC, LEGAL_REVIEW_REQUIRED, VENDOR_CONFIRMATION_REQUIRED, or IMPLEMENTATION_DECISION_REQUIRED.
Timeout must never be treated as payment failure unless a later inquiry or reconciliation confirms failure.
External response must never directly finalize internal order, payment, refund, settlement, inventory, point, or accounting state.
```

---

## 12. Review Requirements

Documents generated under this lane require review based on risk.

| Risk Level | Example | Required Review |
|---|---|---|
| Low | Index, non-binding map, glossary | Project owner review |
| Medium | Provider field registry, webhook envelope, operator runbook | Project owner + technical review |
| High | payment state transition, net cancel, compensation, reconciliation, ledger | Project owner + architecture review |
| Critical | legal liability, tax, settlement, accounting, customer claim, financial dispute | Project owner + architecture + legal/accounting review |

---

## 13. Acceptance Criteria

This governance document is accepted when:

- [ ] 70000 and 75000 lane split is reflected in root indexes;
- [ ] filename and H1 rules are enforced;
- [ ] non-invention rule is documented;
- [ ] controlled payment state vocabulary is documented;
- [ ] external provider trust rule is documented;
- [ ] generation tool instruction is available for Cursor or other bulk-generation tools;
- [ ] review requirements are defined by risk level;
- [ ] open gaps can be labeled without pretending the document is final.

---

## 14. Operating Rule

No bulk document generation for 70000 or 75000 may proceed unless this governance document is referenced in the prompt, task ticket, or generation instruction.

The purpose of automation is to accelerate controlled documentation. It must not replace financial architecture judgment.
