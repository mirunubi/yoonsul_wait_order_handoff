# 000326_Policy_Documentation_AI_Prompt_Library_Review_Boundary_And_No_Implementation_Instruction.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Purpose

This document defines the AI prompt library, review boundary, no-implementation instruction, verification prompt standard, and controlled AI-assistance policy for the Yoonsul Wait/Order Handoff documentation-first phase.

The project will use AI tools such as ChatGPT, Cursor, Codex-style assistants, and future code assistants to generate, review, sort, rename, index, and verify documentation.

However, during the current phase, AI tools must not begin uncontrolled implementation.

Therefore, prompts must be designed to keep AI tools inside documentation, verification, review, and mapping boundaries until the implementation gate is explicitly opened.

---

## 2. Scope

This policy applies to:

- mobile ChatGPT document generation prompts
- Cursor review prompts
- repository verification prompts
- filename normalization prompts
- index synchronization prompts
- directory map review prompts
- duplicate detection prompts
- lane coverage review prompts
- batch import review prompts
- mobile artifact cleanup prompts
- implementation mapping draft prompts
- SOP draft prompts
- test catalog draft prompts
- evidence register draft prompts
- no-code review prompts
- no-implementation guard instructions

This document does not authorize implementation.

It defines safe prompt patterns for the documentation-first phase.

---

## 3. Core Principle

AI tools must be given narrow authority during the documentation phase.

The project must follow this rule:

> During documentation-first phase, AI may draft, review, classify, detect, map, and report, but it must not implement code unless the implementation gate is explicitly opened.

A powerful AI tool without a boundary can accidentally become an uncontrolled developer.

---

## 4. Prompt Authority Boundary

Every AI prompt should clarify what the AI is allowed to do.

Allowed during documentation phase:

- draft Markdown policy documents
- draft SOP documents
- draft readiness checks
- draft implementation mapping documents
- draft test catalogs
- review filenames
- review H1 titles
- review folder placement
- review indexes
- detect duplicates
- detect missing documents
- detect broken references
- detect mobile artifacts
- suggest safe next actions
- summarize open gaps
- produce review reports

Not allowed during documentation phase:

- implement code
- create database migrations
- create production RLS policies
- create RPC functions
- create API endpoints
- create Flutter screens
- create deployment scripts
- modify production configuration
- generate real secrets
- connect to real providers
- silently delete documents
- silently merge documents
- rewrite large document bodies without instruction

---

## 5. No Implementation Instruction

Documentation-phase prompts should include a no-implementation instruction.

Recommended phrase:

    Do not implement code.
    Do not create migrations.
    Do not create API/RPC functions.
    Do not modify runtime behavior.
    Do not touch secrets or production configuration.
    Return review findings or draft documentation only.

This instruction should appear in any prompt sent to Cursor or coding-capable AI tools during the documentation phase.

---

## 6. No Secret Instruction

Prompts must prohibit secret handling.

Recommended phrase:

    Do not include or request real secrets.
    Do not use service role keys.
    Do not use production `.env` values.
    Do not expose API keys, payment credentials, webhook secrets, CI / DI credentials, or database passwords.
    Use dummy values only.

AI tools must never be encouraged to inspect or print real secrets.

---

## 7. No Production Data Instruction

Prompts must prohibit production sensitive data use.

Recommended phrase:

    Do not use production customer data.
    Do not use raw CI / DI.
    Do not use raw payment tokens.
    Do not use real customer phone numbers or emails.
    Use synthetic or masked examples only.

This protects the documentation workflow from becoming a data leakage path.

---

## 8. Review-Only Prompt Pattern

A review-only prompt should include:

- task
- scope
- prohibited actions
- expected output
- no implementation instruction
- no deletion instruction
- no rewrite instruction unless requested

Recommended pattern:

    TASK:
    Review the Markdown documentation corpus for a specific issue.

    SCOPE:
    Check only filenames, H1 titles, document numbers, folder placement, index entries, and cross-references.

    DO NOT:
    - implement code
    - rewrite document bodies
    - delete files
    - merge files automatically
    - create database/API/runtime changes

    RETURN:
    - findings
    - risk level
    - recommended safe next actions

Review-only prompts keep AI in audit mode.

---

## 9. Draft-Only Prompt Pattern

A draft-only prompt should include:

- document number
- document title
- document type
- required format
- no implementation rule
- mobile copy safety rule

Recommended pattern:

    TASK:
    Draft one Markdown policy document.

    DOCUMENT:
    {number} {title}

    FORMAT:
    - one complete Markdown document
    - H1 title
    - Purpose
    - Scope
    - Core Principle
    - policy sections
    - Non-Goals
    - Readiness Check
    - Conclusion

    DO NOT:
    - include implementation code
    - include real secrets
    - include raw CI / DI
    - include nested triple backticks

    OUTPUT:
    One mobile-copy-safe Markdown document.

Draft-only prompts prevent AI from mixing policy and implementation.

---

## 10. Filename Verification Prompt

Recommended prompt:

    TASK:
    Review Markdown files for filename, H1 title, document number, and folder path consistency.

    DO NOT:
    - implement code
    - rewrite document bodies
    - delete files
    - merge files automatically

    CHECK:
    1. filename matches document number
    2. filename matches H1 title
    3. H1 starts with document number
    4. duplicate document numbers
    5. duplicate or similar titles
    6. files likely in wrong folder
    7. files missing from index

    RETURN:
    - OK files
    - files needing rename
    - files needing move
    - duplicate candidates
    - missing index entries
    - safe next actions

This prompt is used after PC import.

---

## 11. Index Synchronization Prompt

Recommended prompt:

    TASK:
    Compare actual Markdown files against the document index and directory map.

    DO NOT:
    - implement code
    - rewrite documents
    - delete files
    - move files automatically unless explicitly requested

    CHECK:
    1. files missing from index
    2. index entries with missing files
    3. index title mismatch
    4. index path mismatch
    5. directory map mismatch
    6. obsolete documents still marked active
    7. active files in archive
    8. incoming drafts not reviewed

    RETURN:
    A synchronization report with recommended safe updates.

This prompt keeps index maintenance controlled.

---

## 12. Directory Map Review Prompt

Recommended prompt:

    TASK:
    Review the documentation directory map against the actual folder structure.

    DO NOT:
    - implement code
    - rewrite documents
    - delete folders
    - move files automatically

    CHECK:
    1. folders in repository missing from directory map
    2. folders in directory map missing from repository
    3. outdated folder purpose descriptions
    4. folder document ranges that no longer match
    5. archive or incoming folders used incorrectly
    6. folders that should be split or merged

    RETURN:
    - accurate folder list
    - mismatches
    - recommended directory map updates
    - unresolved questions

This prompt is used after folder restructuring.

---

## 13. Duplicate Detection Prompt

Recommended prompt:

    TASK:
    Review Markdown documents for duplicate, overlapping, obsolete, and merge-candidate documents.

    DO NOT:
    - implement code
    - delete files
    - merge files automatically
    - rewrite document bodies

    CHECK:
    1. duplicate document numbers
    2. similar or duplicate titles
    3. near-duplicate Purpose sections
    4. near-duplicate Scope sections
    5. policy/SOP overlap
    6. policy/implementation mapping overlap
    7. readiness checklist duplication
    8. obsolete or replaced candidates

    RETURN:
    - duplicate candidates
    - overlap type
    - recommended keep/merge/archive/rename decision
    - implementation risk if both remain active

This prompt supports cleanup without destructive action.

---

## 14. Lane Coverage Review Prompt

Recommended prompt:

    TASK:
    Build a documentation lane coverage matrix.

    DO NOT:
    - implement code
    - rewrite document bodies
    - invent missing documents as if they already exist

    LANES:
    - foundation
    - security
    - POS/KDS
    - payment
    - tenant/store
    - degraded recovery
    - support
    - audit
    - export/report
    - AI analytics
    - vendor
    - SOP
    - testing
    - implementation mapping
    - compliance
    - documentation governance

    CHECK EACH LANE FOR:
    - policy
    - boundary
    - SOP
    - implementation mapping
    - test catalog
    - evidence register
    - readiness check
    - index coverage
    - blockers

    RETURN:
    - coverage matrix
    - missing documents
    - duplicate or weak documents
    - implementation blockers
    - recommended next document numbers

This prompt helps decide what to draft next.

---

## 15. Batch Import Review Prompt

Recommended prompt:

    TASK:
    Review the latest documentation import batch.

    DO NOT:
    - implement code
    - rewrite document bodies
    - delete files
    - merge files automatically

    CHECK:
    1. batch id exists
    2. source is recorded
    3. filenames match H1 titles
    4. document numbers are unique
    5. files are in correct folders
    6. index entries exist
    7. directory map is updated or pending
    8. duplicates are flagged
    9. mobile artifacts exist
    10. no secrets or raw CI / DI exist
    11. commit grouping is clean

    RETURN:
    A batch review report with safe next actions.

This prompt is used for PC-side import batches.

---

## 16. Mobile Artifact Cleanup Prompt

Recommended prompt:

    TASK:
    Review imported Markdown documents for mobile drafting and Google Docs artifacts.

    DO NOT:
    - implement code
    - rewrite policy meaning
    - delete files
    - merge files automatically

    DETECT:
    1. missing H1 title
    2. document number mismatch
    3. broken section numbering
    4. duplicated sections
    5. writing block markers
    6. broken code fences
    7. Google Docs metadata inside body
    8. accidental assistant commentary
    9. partial copy or missing conclusion
    10. possible secret or raw identity pattern

    RETURN:
    A cleanup report with minimal safe edit recommendations.

This prompt supports safe cleanup after mobile drafting.

---

## 17. SOP Draft Prompt

Recommended prompt:

    TASK:
    Draft one operational SOP document.

    DOCUMENT:
    {number} {title}

    FORMAT:
    - Purpose
    - Scope
    - Trigger
    - Roles
    - Allowed Actions
    - Prohibited Actions
    - Step-By-Step Procedure
    - Evidence Required
    - Escalation
    - Closure Condition
    - Readiness Check
    - Conclusion

    DO NOT:
    - implement code
    - include secrets
    - include raw CI / DI
    - include real customer data
    - include nested triple backticks

    OUTPUT:
    One mobile-copy-safe Markdown document.

SOP prompts must produce operator actions, not generic policy repetition.

---

## 18. Implementation Mapping Draft Prompt

Implementation mapping is allowed as design, not code.

Recommended prompt:

    TASK:
    Draft one implementation mapping document.

    DOCUMENT:
    {number} {title}

    PURPOSE:
    Map existing policy to future schema/API/RPC/UI/audit/testing constraints.
    Do not implement.

    FORMAT:
    - Purpose
    - Scope
    - Related Policy Documents
    - Runtime Boundary
    - Data Categories
    - Authority Boundary
    - Required Context
    - Audit Mapping
    - Masking Mapping
    - Error Handling
    - Testing Requirements
    - Implementation Blockers
    - Non-Goals
    - Readiness Check
    - Conclusion

    DO NOT:
    - write SQL migrations
    - write API code
    - write Flutter code
    - create production configuration
    - include secrets
    - include raw CI / DI

    OUTPUT:
    One mobile-copy-safe Markdown document.

Mapping is not implementation.

---

## 19. Test Catalog Draft Prompt

Recommended prompt:

    TASK:
    Draft one security or operational test catalog.

    DOCUMENT:
    {number} {title}

    FORMAT:
    - Purpose
    - Scope
    - Test Categories
    - Test Data Policy
    - Abuse Cases
    - Positive Tests
    - Negative Tests
    - Boundary Tests
    - Replay/Retry Tests where applicable
    - Expected Results
    - Evidence Required
    - Release Gate Impact
    - Readiness Check
    - Conclusion

    DO NOT:
    - write executable test code
    - use real secrets
    - use raw CI / DI
    - use production customer data
    - include nested triple backticks

    OUTPUT:
    One mobile-copy-safe Markdown document.

Test catalog defines verification intent, not test implementation code.

---

## 20. Evidence Register Draft Prompt

Recommended prompt:

    TASK:
    Draft one evidence register document.

    DOCUMENT:
    {number} {title}

    FORMAT:
    - Purpose
    - Scope
    - Evidence Categories
    - Required Fields
    - Evidence Owner
    - Retention Direction
    - Access Control
    - Masking
    - Export Control
    - Correction Rule
    - Review Cadence
    - Readiness Check
    - Conclusion

    DO NOT:
    - include real evidence
    - include secrets
    - include raw CI / DI
    - include real customer data
    - include production log excerpts

    OUTPUT:
    One mobile-copy-safe Markdown document.

Evidence register drafts define structure only.

---

## 21. Security Review Prompt

Recommended prompt:

    TASK:
    Review a proposed document or feature against the security foundation.

    DO NOT:
    - implement code
    - rewrite unless requested
    - invent missing approvals
    - weaken security rules

    CHECK AGAINST:
    - deny by default
    - least privilege
    - tenant/store isolation
    - CI / DI protection
    - payment authority
    - POS/KDS boundary
    - support masking
    - audit immutability
    - degraded evidence
    - export control
    - AI minimization
    - incident response
    - compliance evidence

    RETURN:
    - passed controls
    - failed controls
    - missing mappings
    - blocker list
    - recommended next documents

This prompt is used before implementation mapping or readiness review.

---

## 22. No-Delete Prompt Rule

Unless explicitly performing cleanup, prompts should say:

    Do not delete files.
    Do not mark files obsolete without review.
    Do not merge files automatically.
    Return candidates and recommended actions only.

Deletion and merge must be controlled decisions.

---

## 23. No-Rewrite Prompt Rule

During review, prompts should say:

    Do not rewrite document bodies.
    Return review findings only.

Rewrite should be requested separately after reviewing findings.

This prevents AI from accidentally changing policy meaning.

---

## 24. Minimal-Edit Prompt Rule

When cleanup is needed, prompts should request minimal edits.

Recommended phrase:

    Apply only minimal edits needed to fix formatting, title mismatch, broken section numbering, and obvious mobile artifacts.
    Do not change policy meaning.

Minimal edit preserves document intent.

---

## 25. Safe Next Actions Output

Review prompts should ask for safe next actions.

Safe next actions may include:

- rename file
- move file
- update index
- update directory map
- mark duplicate candidate
- create missing document
- add readiness check
- add cross-reference
- run duplicate review
- defer decision
- open blocker
- request human review

Unsafe next actions include uncontrolled implementation, deletion, or broad rewriting.

---

## 26. Prompt Header Standard

A controlled prompt should begin with:

    TASK:
    SCOPE:
    DO NOT:
    CHECK:
    RETURN:

This structure makes the request clear.

AI tools behave better when the boundaries are explicit.

---

## 27. Prompt Reuse Library

The project should maintain a reusable prompt library.

Prompt library may include:

- mobile document draft prompt
- policy draft prompt
- SOP draft prompt
- mapping draft prompt
- test catalog prompt
- evidence register prompt
- filename review prompt
- index sync prompt
- directory map prompt
- duplicate review prompt
- batch import review prompt
- mobile artifact cleanup prompt
- security review prompt
- readiness gate prompt
- implementation blocker prompt

Prompt library prevents repeated improvisation.

---

## 28. Prompt Library Storage

Prompt library may be stored in:

    docs/documentation_governance/prompt_library/

or another documentation governance folder.

Prompt library files should be Markdown.

Prompt library should be indexed.

Prompt library should not contain secrets or production data.

---

## 29. Prompt Versioning

Prompts may evolve.

Prompt changes should be reviewed when:

- AI behavior produces unwanted implementation
- AI rewrites too much
- AI misses duplicates
- AI suggests unsafe deletion
- AI exposes secret-like content
- AI confuses policy and mapping
- folder structure changes
- documentation workflow changes
- implementation phase begins

Prompt versioning can be lightweight.

---

## 30. Prompt Safety Checklist

Before using a prompt with Cursor or coding-capable AI, confirm:

- task is clear
- scope is clear
- no implementation instruction is included
- no secret is included
- no production data is included
- no raw CI / DI is included
- output format is clear
- deletion is prohibited unless intended
- rewrite is prohibited unless intended
- merge is prohibited unless intended
- safe next actions are requested
- implementation gate is respected

If the prompt fails this checklist, revise before use.

---

## 31. Implementation Phase Transition

When implementation phase later begins, prompt rules must change carefully.

Implementation prompts must include:

- exact source documents
- exact implementation mapping
- allowed files
- prohibited files
- test requirements
- rollback or containment rule
- no secret exposure
- no production data
- no broad architecture invention
- expected diff scope

This document does not define implementation prompts.

It only states that implementation prompts must be more constrained, not less.

---

## 32. Prompt Misuse Incident

Prompt misuse may become a security or documentation incident.

Examples:

- prompt includes real secret
- prompt includes raw CI / DI
- prompt includes production log
- prompt instructs AI to implement before gate
- prompt causes AI to delete documents
- prompt causes AI to rewrite policy silently
- prompt causes AI to expose sensitive data
- prompt causes AI to generate unsafe implementation plan

Prompt misuse must be reviewed and corrected.

---

## 33. Prompt Output Review

AI output must be reviewed before acceptance.

Review should check:

- did AI obey no-implementation rule
- did AI avoid secrets
- did AI avoid raw identity
- did AI stay within scope
- did AI produce safe next actions
- did AI invent documents that do not exist
- did AI weaken security rule
- did AI confuse policy and SOP
- did AI create false readiness
- did AI suggest deletion without review

AI output is not automatically truth.

---

## 34. False Readiness Warning

AI may produce optimistic readiness claims.

Prompts should avoid asking:

    Is everything ready?

Better prompt:

    Identify missing documents, blockers, unresolved decisions, and evidence gaps.

The project should prefer gap-finding over reassurance.

---

## 35. No Hallucinated File Rule

AI must not invent file existence.

Prompt should say:

    Do not claim a file exists unless it is present in the reviewed file list or repository context.
    If uncertain, mark as unknown.

This prevents fake index confidence.

---

## 36. Readiness Gate Prompt

Recommended prompt:

    TASK:
    Review whether the documentation corpus is ready for the next phase.

    DO NOT:
    - implement code
    - claim readiness without evidence
    - invent missing files
    - ignore blockers

    CHECK:
    1. foundation coverage
    2. security coverage
    3. runtime boundary coverage
    4. SOP coverage
    5. implementation mapping coverage
    6. test catalog coverage
    7. evidence coverage
    8. index synchronization
    9. directory map synchronization
    10. open blockers

    RETURN:
    - ready areas
    - not ready areas
    - blockers
    - missing documents
    - next required actions

Readiness gate prompt must find blockers, not just approve.

---

## 37. Implementation Blocker Prompt

Recommended prompt:

    TASK:
    Identify implementation blockers from the documentation corpus.

    DO NOT:
    - implement code
    - resolve blockers automatically
    - invent missing controls

    CHECK FOR BLOCKERS IN:
    - tenant isolation
    - store isolation
    - payment authority
    - CI / DI handling
    - POS/KDS authority
    - degraded recovery
    - support access
    - audit
    - deployment
    - export
    - AI
    - vendor integration
    - testing

    RETURN:
    - blocker id
    - affected lane
    - related document
    - missing control
    - risk level
    - required next document or decision

This prompt turns uncertainty into visible work.

---

## 38. Non-Goals

This document does not define:

- final Cursor rules file
- final Codex instruction file
- final implementation prompt library
- final prompt automation tool
- final AI evaluation framework
- final prompt security scanner
- final coding assistant configuration
- final CI prompt validation
- final production AI tool policy

Those may be defined later when implementation begins.

---

## 39. Readiness Check

This policy is ready when the project can answer:

1. What can AI tools do during documentation phase?
2. What must AI tools not do?
3. What is the no-implementation instruction?
4. What is the no-secret instruction?
5. What is the no-production-data instruction?
6. What does review-only prompt include?
7. What does draft-only prompt include?
8. What prompt checks filenames?
9. What prompt checks index synchronization?
10. What prompt checks duplicates?
11. What prompt checks lane coverage?
12. What prompt checks mobile artifacts?
13. What prompt drafts SOPs?
14. What prompt drafts implementation mapping without code?
15. What prompt drafts test catalogs without code?
16. What prompt drafts evidence registers?
17. What is the no-delete prompt rule?
18. What is the no-rewrite prompt rule?
19. How is false readiness avoided?
20. How are implementation blockers identified?

If these questions cannot be answered, AI prompt governance is incomplete.

---

## 40. Conclusion

AI tools are central to the Yoonsul Wait/Order Handoff documentation-first workflow.

But AI tools must remain inside controlled boundaries.

The system must preserve the following rules:

- AI may draft documents
- AI may review documents
- AI may detect gaps
- AI may suggest safe next actions
- AI must not implement during documentation phase
- AI must not handle secrets
- AI must not use production data
- AI must not use raw CI / DI
- AI must not delete or merge without instruction
- AI must not rewrite policy meaning during review
- prompts must state task, scope, prohibition, checks, and output
- prompt library must be reusable
- AI output must be reviewed
- readiness prompts must find blockers, not provide comfort
- implementation prompts must wait for the gate

A documentation-first project can use AI heavily without losing control, but only when every prompt tells the AI exactly where the boundary is.
