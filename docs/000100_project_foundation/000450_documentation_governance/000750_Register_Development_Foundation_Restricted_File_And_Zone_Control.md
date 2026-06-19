# 000750_Register_Development_Foundation_Restricted_File_And_Zone_Control.md

## 1. Document Control

| Field | Value |
|---|---|
| Project | yoonsul_wait_order_handoff / CatchMenu-Catch&Order |
| Band | 00100_project_foundation |
| Document Type | Register |
| Document Role | Restricted File And Zone Control Register |
| Related Policy | 000640_Policy_Development_Foundation_Overview_Logic_Module_Documentation_Model.md |
| Related Registry | 000650_Index_Development_Foundation_Overview_Logic_Module_Registry.md |
| Related Matrix | 000690_Matrix_Development_Foundation_Overview_Logic_Module_Traceability.md |
| Related Checklist | 000700_Checklist_Development_Foundation_Code_Handoff_Readiness.md |
| Related Role Guide | 000730_Guide_Development_Foundation_Claude_Cursor_Role_Separation.md |
| Related Prompt Pack | 000740_Template_Development_Foundation_AI_Handoff_Prompt_Pack.md |
| Related Runtime No-AI-Solo Governance | 64370_Governance_Flow_Bundle_Human_Approval_And_No_AI_Solo_Zone_Control.md |
| Related Owner Matrix | 64380_Register_Flow_Bundle_No_AI_Solo_Zone_Owner_And_Approval_Matrix.md |
| Status | Draft |
| Owner | Architecture / Engineering / Security / Compliance |
| AI Solo Change | Prohibited |

---

## 2. Purpose

This register defines the restricted files, modules, folders, runtime areas, and operational zones that AI tools must not modify without explicit human approval.

The register applies to:

- Claude Code
- Cursor
- ChatGPT-generated implementation prompts
- human developers using AI-assisted changes
- any automated code transformation tool

The register exists because CatchMenu / Catch&Order is connected to POS, PG/VAN, settlement, audit ledger, security, DB migration, secrets, and production release flows.

---

## 3. Core Rule

No AI-assisted implementation may modify restricted zones unless all conditions are met:

```text
1. Related Flow Bundle is identified.
2. Overview → Logic → Module → File → Test → Evidence chain is complete.
3. Restricted zone is explicitly listed in the handoff packet.
4. Human approval is recorded.
5. Required tests are identified.
6. Evidence packet target is defined.
7. Diff review confirms no unapproved restricted file was touched.
```

If any condition is missing, implementation is blocked.

---

## 4. Restricted Zone Categories

| Zone Code | Restricted Zone | Reason |
|---|---|---|
| RZ-PAY | Payment approval/cancel/refund/reversal | Money movement and customer impact |
| RZ-SETTLE | Settlement/reconciliation/dispute | Financial accuracy and evidence impact |
| RZ-AUDIT | Audit ledger/tamper-evidence/legal hold | Legal, compliance, and immutability impact |
| RZ-SEC | Security/auth/signature/webhook verification | Trust boundary impact |
| RZ-SECRET | Secret/token/credential/vault handling | Credential compromise risk |
| RZ-DB | DB schema/migration/backfill/data repair | Irreversible data risk |
| RZ-DEPLOY | CI/CD, production release, rollback, infra | Runtime availability risk |
| RZ-OPS | Incident recovery/manual override/admin approval | Operational and financial recovery risk |
| RZ-PII | PII/payment-related log masking/export | Privacy and compliance risk |
| RZ-CONTRACT | Provider contract/API schema | External integration and settlement risk |

---

## 5. Restricted File Register Template

Use this table to register actual files and folders after read-only inspection.

| Register ID | Zone Code | File / Folder / Module | Restriction Level | AI Solo Allowed? | Human Approval Required? | Required Evidence | Owner | Status |
|---|---|---|---|---:|---:|---|---|---|
| RF-001 | RZ-PAY | TBD | Restricted | No | Yes | approval_record + test_report | Engineering | Draft |
| RF-002 | RZ-AUDIT | TBD | Restricted | No | Yes | audit_evidence_packet | Compliance / Engineering | Draft |
| RF-003 | RZ-SEC | TBD | Restricted | No | Yes | security_review_record | Security | Draft |

---

## 6. Restriction Levels

| Level | Meaning | AI Behavior |
|---|---|---|
| Informational | File is relevant but not dangerous by itself | AI may read and summarize |
| Guarded | AI may suggest changes, but human must review before application | AI may propose diff only |
| Restricted | AI may not modify unless explicit approval exists | AI must not edit by default |
| Locked | AI must not modify under any normal handoff | Human-only |
| Incident-Locked | File/area is frozen due to active incident | No change until incident owner releases |

---

## 7. Default Restricted Patterns

Until actual codebase inspection creates exact file paths, the following patterns must be treated as restricted by default.

| Pattern / Area | Zone Code | Default Level |
|---|---|---|
| payment approval services | RZ-PAY | Restricted |
| cancel/refund/reversal services | RZ-PAY | Restricted |
| provider payment adapters | RZ-PAY / RZ-CONTRACT | Restricted |
| POS/PG/VAN webhook handlers | RZ-SEC / RZ-CONTRACT | Restricted |
| signature verification code | RZ-SEC | Restricted |
| idempotency guards for payment mutation | RZ-PAY | Restricted |
| settlement batch jobs | RZ-SETTLE | Restricted |
| reconciliation workers | RZ-SETTLE | Restricted |
| audit ledger append services | RZ-AUDIT | Restricted |
| tamper-evidence/hash-chain code | RZ-AUDIT | Locked |
| evidence export / legal hold code | RZ-AUDIT | Restricted |
| secret loading / vault / token rotation | RZ-SECRET | Locked |
| env files and production config | RZ-SECRET / RZ-DEPLOY | Locked |
| DB migrations | RZ-DB | Restricted |
| production deployment scripts | RZ-DEPLOY | Locked |
| admin manual recovery / override actions | RZ-OPS | Restricted |
| log masking and PII export | RZ-PII | Restricted |

---

## 8. AI Allowed Actions By Restriction Level

| Action | Informational | Guarded | Restricted | Locked | Incident-Locked |
|---|---:|---:|---:|---:|---:|
| Read file | Yes | Yes | Yes | Conditional | Conditional |
| Summarize behavior | Yes | Yes | Yes | Conditional | Conditional |
| Suggest change in text | Yes | Yes | Conditional | No | No |
| Create patch | Yes | Conditional | No unless approved | No | No |
| Apply patch | Yes | Human review | No unless approved | No | No |
| Run tests | Yes | Conditional | Conditional | No unless approved | No |
| Commit | No by default | No by default | No | No | No |
| Deploy | No | No | No | No | No |

---

## 9. Required Human Approval Record

Any restricted change must include an approval record.

| Approval Field | Required |
|---|---:|
| Flow Bundle filename | Yes |
| Overview document filename | Yes |
| Logic document filename | Yes |
| Module document filename | Yes |
| Restricted file list | Yes |
| Reason for change | Yes |
| Expected risk | Yes |
| Required tests | Yes |
| Evidence packet target | Yes |
| Human approver | Yes |
| Approval date | Yes |

---

## 10. Restricted Change Request Template

Use this template when requesting permission to change a restricted file or zone.

```text
# Restricted Change Request

## Scope
- Flow Bundle:
- Overview:
- Logic:
- Module:
- Restricted zone:
- Restricted files:

## Reason
- Why the change is required:

## Risk
- Money movement impact:
- Settlement impact:
- Audit impact:
- Security impact:
- DB/migration impact:
- Release impact:

## Required Tests
- Unit:
- Integration:
- Contract:
- Fault injection:
- Security:
- Audit:
- Migration:
- Regression:

## Evidence
- Evidence packet:
- Review record:
- Release gate:

## Approval
- Approver:
- Date:
- Decision: Approved / Rejected / Deferred
```

---

## 11. Diff Review Requirements

After any AI-assisted work, review the diff against this register.

| Review Question | Required Result |
|---|---|
| Did the diff touch a registered restricted file? | Must be identified |
| Did the handoff packet include approval for that file? | Must be Yes |
| Did the diff touch an unregistered but restricted-looking file? | Must be escalated |
| Did the diff modify migrations, secrets, or deployment config? | Must have explicit approval |
| Did tests cover the restricted change? | Must be documented |
| Was an evidence packet updated? | Must be Yes before merge/release |

---

## 12. Relationship With Read-Only Inspection

The read-only inspection report must feed this register.

```text
00710 Read-Only Inspection Runbook
  ↓
00720 Read-Only Inspection Report
  ↓
00750 Restricted File And Zone Control Register
  ↓
00700 Code Handoff Readiness Checklist
  ↓
64300~64390 Flow Bundle Code Handoff / Review / Release Gates
```

If inspection discovers a new sensitive area, add it to this register before code handoff.

---

## 13. Example Initial Register Rows

These are placeholder examples. Replace with actual paths after codebase inspection.

| Register ID | Zone Code | File / Folder / Module | Restriction Level | AI Solo Allowed? | Human Approval Required? | Required Evidence | Owner | Status |
|---|---|---|---|---:|---:|---|---|---|
| RF-PAY-001 | RZ-PAY | `src/modules/payment/**` | Restricted | No | Yes | payment_test_report + approval_record | Engineering | Placeholder |
| RF-PAY-002 | RZ-PAY | `src/modules/pos_gateway/**` | Restricted | No | Yes | provider_contract_test + approval_record | Engineering | Placeholder |
| RF-SEC-001 | RZ-SEC | `src/modules/webhook/**` | Restricted | No | Yes | webhook_security_test | Security | Placeholder |
| RF-AUDIT-001 | RZ-AUDIT | `src/modules/audit/**` | Restricted | No | Yes | audit_evidence_packet | Compliance / Engineering | Placeholder |
| RF-DB-001 | RZ-DB | `migrations/**` | Restricted | No | Yes | migration_plan + rollback_record | Engineering | Placeholder |
| RF-SECRET-001 | RZ-SECRET | `.env*`, `secrets/**`, `vault/**` | Locked | No | Yes | security_approval_record | Security | Placeholder |
| RF-DEPLOY-001 | RZ-DEPLOY | `.github/workflows/**`, `deploy/**`, `infra/**` | Locked | No | Yes | release_approval_record | DevOps | Placeholder |

---

## 14. Stop Conditions

Stop AI-assisted implementation immediately if:

| Condition | Action |
|---|---|
| AI attempts to edit a restricted file without approval | Stop and revert/review |
| AI touches migration files unexpectedly | Stop and escalate |
| AI touches secrets or env files | Stop and open security review |
| AI modifies audit hash/tamper-evidence code | Stop and require compliance review |
| AI modifies settlement or reconciliation logic | Stop and require financial review |
| AI broadens scope beyond listed files | Stop and rewrite handoff prompt |
| AI cannot explain why a restricted file changed | Block merge |
| Evidence packet is missing | Block release |

---

## 15. Maintenance Rule

This register must be updated when:

- read-only inspection finds new sensitive files
- new Flow Bundle is added
- new provider integration is added
- DB migration pattern changes
- audit ledger architecture changes
- deployment pipeline changes
- secret handling changes
- incident exposes previously unregistered sensitive area

---

## 16. Summary

This register protects the project from uncontrolled AI-assisted code changes.

Claude Code may implement approved Flow Bundles only when restricted files are identified and approved.

Cursor may assist with file-level tasks only when restricted boundaries are clear.

The governing chain remains:

```text
Overview → Logic → Module → File → Test → Evidence
```

No restricted file or zone may be modified outside that chain.
