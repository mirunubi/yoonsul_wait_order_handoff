# 022460_Policy_Foundation_Catalog_File_Layout_And_Naming_Convention

## 1. Purpose

This document defines the file layout and naming convention policy for foundation-first catalog packages.

The purpose is to ensure that foundation catalogs, readiness inventories, handoff records, status values, i18n key maps, content registry maps, provider capability maps, audit/evidence maps, and guardrail test artifacts are placed consistently before implementation begins.

The project must not create scattered catalog files with inconsistent naming, unclear ownership, or mixed runtime authority.

This document does not authorize coding.

Coding remains deferred unless a specific package has a `CODING_ALLOWED` decision, a completed handoff record, and a narrow work order.

---

## 2. Scope

This policy applies to foundation catalog and guardrail artifacts, including:

1. Locale and audience catalogs
2. Status value catalogs
3. Provider capability registries
4. i18n message key catalogs
5. Error message key catalogs
6. Content registry catalogs
7. SOP traceability catalogs
8. Contract catalogs
9. Event family catalogs
10. Audit event catalogs
11. Evidence packet catalogs
12. Security visibility and masking catalogs
13. Degraded state catalogs
14. AI source/output catalogs
15. External projection status catalogs
16. Readiness and blocker inventories
17. Package handoff records
18. Work order records
19. No-hardcoded-string guardrail artifacts
20. Boundary test catalog artifacts

This policy does not define runtime database schema, API code, UI code, provider adapters, or AI runtime implementation.

---

## 3. Core Principle

Foundation catalogs must be easy to find, easy to review, and hard to confuse with runtime code.

Catalog files should communicate:

- package family
- ownership
- status
- version
- whether the artifact is planning-only
- whether coding is allowed
- whether runtime authority exists
- what dependency order applies
- what blocker inventory applies

A file name should make unsafe implementation harder, not easier.

---

## 4. Planning-Only Marker Rule

All foundation catalog files created during this phase must clearly indicate that they are planning or catalog artifacts.

Recommended markers include:

- `catalog`
- `registry`
- `map`
- `template`
- `inventory`
- `policy`
- `readiness`
- `handoff`
- `workorder`
- `guardrail`
- `test_plan`

Avoid file names that imply runtime execution, such as:

- `service`
- `handler`
- `controller`
- `adapter`
- `client`
- `executor`
- `processor`
- `worker`
- `runtime`
- `webhook`
- `publisher`
- `mutator`

Those names should remain deferred until later runtime coding entry.

---

## 5. Recommended Top-Level Foundation Folders

If the project later creates foundation artifacts, the recommended folder structure is:

```text
docs/
  09000_controlled_implementation_planning/
  22400_foundation_readiness/
  21500_foundation_catalogs/
  21600_foundation_handoff/
  09700_foundation_guardrails/
  09800_foundation_tests/
