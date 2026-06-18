# 001510_Guide_POS_Gateway_Runtime_Flow_Bundle_Cursor_Handoff_Read_Only_Instruction_Package.md

## 1. Document Purpose

This guide defines the read-only Cursor handoff instruction package for the POS Gateway Runtime Flow Bundle.

The purpose of this document is to allow Cursor, implementation agents, or developer-side automation to inspect the approved runtime flow bundle context without beginning runtime implementation, schema mutation, adapter coding, payment execution, POS/KDS integration, or production behavior changes.

This document belongs after:

- `001470_Checklist_POS_Gateway_Runtime_Flow_Bundle_Master_Code_Handoff_Readiness.md`
- `001480_Gate_POS_Gateway_Runtime_Flow_Bundle_Code_Handoff_Approval_Evidence_And_No_Implementation_Guard.md`
- `001490_Report_POS_Gateway_Runtime_Flow_Bundle_Final_Code_Handoff_Readiness_Closeout.md`
- `001500_Index_POS_Gateway_Runtime_Flow_Bundle_WorkPackage_Code_Handoff_Transition.md`

This guide does not authorize code implementation.

---

## 2. Handoff Status

| Item | Status |
|---|---:|
| Runtime implementation | Not authorized |
| POS adapter coding | Not authorized |
| Payment execution logic | Not authorized |
| Production credential use | Not authorized |
| Database mutation | Not authorized |
| Read-only hydration | Allowed |
| Source-test-owner mapping | Allowed |
| Evidence packet preparation | Allowed |
| Approval gap detection | Allowed |
| Cursor instruction drafting | Allowed |

---

## 3. Cursor Instruction Boundary

Cursor may be asked to perform only the following activities:

1. Read approved Markdown documentation.
2. Build a document-to-source mapping inventory.
3. Identify missing source references.
4. Identify missing tests required before implementation.
5. Identify owner gaps.
6. Identify approval gates that have not been satisfied.
7. Prepare a non-mutating implementation readiness report.
8. Generate proposed file paths without creating runtime files.
9. Generate proposed test names without writing executable tests.
10. Generate proposed migration names without writing migrations.

Cursor must not:

1. Create runtime gateway code.
2. Modify source code.
3. Modify database schemas.
4. Add migrations.
5. Add secrets, credentials, tokens, or environment variables.
6. Implement POS/KDS adapters.
7. Implement PG/VAN payment calls.
8. Implement settlement, refund, cancellation, or reconciliation logic.
9. Create production queues, workers, cron jobs, or webhooks.
10. Treat documentation approval as implementation approval.

---

## 4. Allowed Read-Only Hydration Inputs

The handoff agent may hydrate context from the following source types only:

| Source Type | Allowed | Notes |
|---|---:|---|
| Approved Markdown policy documents | Yes | Read-only |
| Approved SOP documents | Yes | Read-only |
| Approved bundle reports | Yes | Read-only |
| Existing source tree inventory | Yes | Names and paths only |
| Existing test tree inventory | Yes | Names and paths only |
| Existing owner registry | Yes | Read-only |
| Existing evidence packet index | Yes | Read-only |
| Runtime secrets | No | Never read or request |
| Production logs with PII/payment data | No | Not allowed in this stage |
| POS vendor credentials | No | Not allowed |
| PG/VAN live integration data | No | Not allowed |

---

## 5. Required Mapping Output

Cursor or the developer-side assistant must produce a mapping table in the following structure before any implementation ticket can be opened.

| Bundle Area | Policy Source | Expected Source Path | Expected Test Path | Runtime Owner | Approval Owner | Evidence Required | Status |
|---|---|---|---|---|---|---|---|
| Runtime flow entry | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |
| POS event intake | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |
| KDS handoff boundary | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |
| Idempotency boundary | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |
| Retry and replay boundary | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |
| Dead-letter boundary | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |
| Reconciliation evidence | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |
| Incident and rollback boundary | TBD | Proposed only | Proposed only | TBD | TBD | TBD | Blocked |

All rows must remain `Blocked` until source, test, owner, approval, and evidence fields are explicitly filled.

---

## 6. Evidence Gate Requirements

Before implementation approval may be requested, the following evidence packets must exist:

1. Read-only hydration report.
2. Source inventory report.
3. Test inventory report.
4. Owner registry mapping.
5. Policy approval record.
6. Risk acceptance record for any deferred gap.
7. No-secret/no-production-data verification record.
8. Implementation prohibition acknowledgement.
9. Code handoff readiness checklist result.
10. Final approval gate result.

If any evidence packet is missing, Cursor output must state:

`Implementation remains blocked because required evidence is incomplete.`

---

## 7. Recommended Cursor Prompt

Use the following prompt when handing this bundle to Cursor or a developer-side coding assistant:

```text
You are working on the yoonsul_wait_order_handoff POS Gateway Runtime Flow Bundle.

Runtime implementation is not authorized.
Do not write code.
Do not modify files.
Do not create migrations.
Do not create adapters.
Do not add secrets.
Do not connect to POS, KDS, PG, VAN, production logs, or live credentials.

Your task is read-only readiness mapping only.

Read the approved POS Gateway Runtime Flow Bundle documents and produce:
1. source-test-owner-restricted mapping,
2. missing source path inventory,
3. missing test path inventory,
4. missing owner registry entries,
5. missing evidence packets,
6. missing approval gates,
7. blocked implementation checklist.

All proposed source paths and test paths must be marked as Proposed only.
All runtime implementation status must remain Blocked until explicit policy approval and evidence gate completion.
```

---

## 8. Prohibited Cursor Prompt Patterns

The following prompt patterns are prohibited:

```text
Implement the POS Gateway runtime flow.
```

```text
Create the adapter code now.
```

```text
Generate migrations for the runtime tables.
```

```text
Connect to the payment provider sandbox.
```

```text
Use the existing production secrets.
```

```text
Create workers, queues, and webhooks based on the policy documents.
```

```text
Assume approval is complete and begin implementation.
```

---

## 9. Readiness Decision Rule

The bundle may move from read-only handoff to implementation planning only when all of the following are true:

| Gate | Required Result |
|---|---|
| Source mapping | Complete |
| Test mapping | Complete |
| Owner mapping | Complete |
| Policy approval | Complete |
| Evidence packet | Complete |
| Security review | Complete |
| Secret boundary review | Complete |
| Runtime implementation approval | Explicitly granted |

Until then, the only valid readiness result is:

`Read-only handoff prepared. Runtime implementation remains blocked.`

---

## 10. Closeout Statement

This document authorizes a read-only Cursor handoff instruction package for the POS Gateway Runtime Flow Bundle.

It does not authorize runtime implementation, source code mutation, database migration, adapter construction, payment execution, production credential use, or POS/KDS/PG/VAN live integration.

The next document should continue the handoff lane by defining a concrete evidence packet template or a blocked implementation ticket template.
