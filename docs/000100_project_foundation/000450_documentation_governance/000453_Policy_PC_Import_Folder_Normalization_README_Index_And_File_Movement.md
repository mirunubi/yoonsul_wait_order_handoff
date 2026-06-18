# 000453_Policy_PC_Import_Folder_Normalization_README_Index_And_File_Movement

## 1. Purpose

This document defines the PC import, folder normalization, file movement, filename cleanup, README placement, index synchronization, import verification, Git commit grouping, mobile draft cleanup, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined documentation range map, numbering reservation, lane boundary, closed range rule, future range separation, and numbering discipline.

This document defines how mobile-generated Markdown drafts should be imported into the PC repository safely without losing source traceability, mixing ranges, overwriting documents, introducing implementation code, or damaging existing project structure.

This document does not move files, create folders, write scripts, run Git commands, or implement project code.

It defines PC import and folder normalization policy only.

---

## 2. Scope

This document covers:

- PC import meaning
- import source handling
- folder normalization
- file naming
- README placement
- index synchronization
- file movement record
- duplicate detection
- missing file detection
- Git commit grouping
- mobile draft cleanup
- Google Docs fallback handling
- no-code boundary

This document does not cover:

- final repository tree
- final import automation
- final Git execution
- final file movement script
- final CI/CD
- final implementation code
- final SQL migration
- final Flutter build
- final API implementation

---

## 3. Core Principle

PC import must preserve traceability before improving folder beauty.

The project must follow this rule:

> When moving mobile-generated Markdown drafts into the PC repository, preserve document number, title, source lane, range, closure status, and source traceability before renaming, merging, archiving, or reorganizing files.

Pretty folder structure is useful.

Lost traceability is dangerous.

---

## 4. PC Import Meaning

PC import means transferring completed or draft Markdown documents from mobile drafting environment into the controlled repository environment.

PC import may include:

- copying Markdown content
- creating target folders
- normalizing filenames
- placing README files
- updating indexes
- recording imported documents
- detecting duplicates
- detecting missing documents
- preserving source order
- reviewing formatting
- staging Git changes
- committing documentation-only changes

PC import is not implementation.

---

## 5. Import Source Types

Possible import sources:

- mobile ChatGPT draft
- Obsidian Mobile note
- mobile Markdown file
- clipboard copy
- Google Docs fallback copy
- existing local draft
- previous repository file
- archived draft
- exported text file

Each source must be treated as draft until verified in Git.

---

## 6. Canonical Source Rule

After PC import is verified and committed:

    Git repository becomes the source of truth.

Before verification:

    mobile draft remains temporary source.

Google Docs, clipboard, or screenshots should not become canonical unless explicitly imported and committed.

---

## 7. Import Safety Rule

During PC import:

- do not change policy substance casually
- do not merge documents silently
- do not delete mobile source before verification
- do not renumber without mapping
- do not add implementation code
- do not add secrets
- do not touch unrelated folders
- do not run migrations
- do not execute provider integrations
- do not change runtime behavior

Import is documentation normalization only.

---

## 8. Target Folder Strategy

Recommended target folder strategy:

    docs/
      05000_phase1_saas_provider_pilot_admin/
      08000_high_risk_store_operation_foundation/
      09000_cross_range_handoff/

Each range folder should have:

- range README
- lane documents
- closure document
- optional index
- optional register placeholder later
- no implementation code

Folder names may be normalized later.

---

## 9. README Placement Rule

Each range folder should include a README or range start document.

Recommended README placement:

    docs/05000_phase1_saas_provider_pilot_admin/05000_README.md
    docs/08000_high_risk_store_operation_foundation/08000_High_Risk_Store_Operation_Foundation_README_And_Edge_Case_Constitution_Index.md
    docs/09000_cross_range_handoff/09000_Cross_Range_Foundation_Planning_Closure_README_And_PC_Import_Handoff_Index.md

README should be easy to find.

---

## 10. File Naming Rule

Recommended filename format:

    [NUMBER]_[Title_With_Underscores].md

Example:

    08010_Alcohol_Sales_Adult_Verification_And_Legal_Sale_Boundary_Policy.md

Rules:

- keep number at beginning
- use underscores for spaces
- avoid special characters
- avoid Korean filename if cross-platform friction expected
- preserve title meaning
- do not shorten until index is stable
- do not include version noise unless needed

Filename should be predictable.

---

## 11. Title Match Rule

Document H1 title should match filename title as closely as possible.

Example:

Filename:

    08010_Alcohol_Sales_Adult_Verification_And_Legal_Sale_Boundary_Policy.md

H1:

    # 08010_Policy_Alcohol_Sales_Adult_Verification_And_Legal_Sale_Boundary

Mismatch should be recorded and corrected during review.

---

## 12. Range Placement Rule

Documents must be placed according to range and lane.

Examples:

- `05800~05900` documents go under 05000 range folder unless later split
- `08000~08100` documents go under high-risk foundation folder
- `09000~09090` documents go under cross-range handoff folder
- future `09100~09190` documents go under backlog extraction folder
- future `09200~09290` documents go under build gate folder

Wrong placement must be corrected with movement record.

---

## 13. File Movement Record Rule

Every moved document should be recorded.

Movement record should include:

- source title
- source number
- original location
- target location
- movement reason
- date
- reviewer
- status
- notes

Movement record prevents lost documents.

---

## 14. File Movement Record Format

Recommended format:

    MOVE-[YYYYMMDD]-[NUMBER]

Example:

    MOVE-20260612-001

Final format may be normalized later.

---

## 15. Import Batch Rule

Import should be batched by range or lane.

Recommended batches:

- Batch 1: 05000 range documents
- Batch 2: 08000 range documents
- Batch 3: 09000 range documents
- Batch 4: README and index updates
- Batch 5: register placeholders if needed
- Batch 6: formatting corrections

Do not import everything as unreviewed mass change if avoidable.

---

## 16. Git Commit Grouping Rule

Recommended commit grouping:

    docs: import 05000 planning range
    docs: import 08000 high risk foundation range
    docs: import 09000 cross range handoff range
    docs: update range readmes and indexes
    docs: normalize documentation filenames
    docs: add cross range import registers

Commit should remain documentation-only.

---

## 17. Git Status Review Rule

Before commit, review:

- added files
- modified files
- deleted files
- renamed files
- unexpected code files
- temporary files
- generated files
- secrets
- wrong folder changes
- duplicate documents

Unexpected implementation files must be excluded.

---

## 18. Diff Review Rule

Diff review should check:

- H1 title
- document number
- range placement
- markdown formatting
- accidental truncation
- repeated section
- missing conclusion
- implementation instructions
- secret leakage
- raw identity/payment data
- wrong cross-reference

Diff review is required before commit.

---

## 19. Markdown Formatting Rule

Markdown should preserve:

- H1 document title
- numbered sections
- fenced code only when needed
- tables where helpful
- no broken headings
- no accidental UI artifacts
- no hidden copied metadata
- no unsupported control characters
- consistent newline at end of file

Formatting should support Obsidian, GitHub, and PC editing.

---

## 20. Duplicate Detection Rule

Duplicate detection should compare:

- document number
- H1 title
- filename
- section titles
- closure document references
- range README references
- topic overlap
- file hash if available
- content length if useful

Duplicate detection should happen before deleting anything.

---

## 21. Duplicate Resolution Rule

Duplicate resolution options:

- keep both with reason
- mark one as draft
- archive one
- rename one as addendum
- supersede older one
- merge only after review
- update index

Do not delete duplicate-looking file without verifying content.

---

## 22. Missing File Detection Rule

Missing file detection should check:

- expected number sequence
- range README list
- closure document list
- mobile draft list
- Git folder contents
- index files
- import batch log

Missing file may be reserved gap or import failure.

Classify before filling.

---

## 23. Missing File Status Values

Recommended status values:

- `MISSING_NOT_CHECKED`
- `MISSING_RESERVED`
- `MISSING_EXPECTED_LATER`
- `MISSING_IMPORT_FAILED`
- `MISSING_DUPLICATE_RENAMED`
- `MISSING_ARCHIVED`
- `MISSING_NOT_REQUIRED`
- `MISSING_REVIEW_REQUIRED`

Missing status prevents false panic.

---

## 24. Reserved Number Record Rule

Reserved numbers should be recorded.

Reserved number record should include:

- number
- range
- reason
- expected use
- owner
- status
- notes

Reserved number is not missing document.

---

## 25. Root Index Update Rule

Root documentation index should be updated only after imported files are verified.

Root index may include:

- range folder
- range title
- range status
- start document
- closure document
- number span
- handoff target
- notes

Root index should not list files not yet imported.

---

## 26. Range README Update Rule

Range README should include:

- range purpose
- document list
- status
- closure document
- dependencies
- open gaps
- next handoff
- implementation deferral note

Range README should become the first navigation point.

---

## 27. Cross-Reference Update Rule

Cross-reference update should add links or references when:

- 05000 depends on 08000
- 09000 references 05000 and 08000 closures
- Admin Console references high-risk constraints
- Provider strategy references payment/KDS boundaries
- Pilot references evidence/test readiness
- Backlog extraction references source documents

Cross-reference must not become implementation instruction.

---

## 28. Open Gap Register Update Rule

If import reveals gaps:

- create open gap entry
- link source document
- describe missing decision
- assign category
- mark blocker status
- avoid fixing immediately unless simple index issue
- preserve for extraction phase

Open gap register is better than ad-hoc memory.

---

## 29. Register Placeholder Rule

Register placeholders may be created only when useful.

Examples:

- range open gap register
- backlog extraction register
- test extraction register
- evidence extraction register
- UI handoff register
- provider handoff register
- legal/compliance handoff register

Placeholders should not pretend content is complete.

---

## 30. Temporary File Rule

Temporary files should be excluded or cleaned.

Temporary files may include:

- copy buffer files
- mobile paste scratch files
- old exports
- duplicated clipboard dumps
- directory snapshots
- import scratch notes
- platform temp files

Do not delete project-relevant temporary files without review.

---

## 31. Secret Scan Rule

Before commit, check documents for:

- API keys
- access keys
- secret keys
- Supabase service role key
- database password
- provider credential
- webhook secret
- JWT secret
- personal raw CI/DI
- raw payment data
- full ID document data

Secrets must not enter Git.

---

## 32. Implementation Leakage Check

Before commit, check for accidental implementation instructions such as:

- SQL migration code
- API endpoint implementation
- Flutter widget code
- provider adapter code
- deployment command
- secret setup
- production operation command
- migration execution instruction

Planning docs may mention future implementation conceptually but must not instruct build execution.

---

## 33. Google Docs Fallback Rule

Google Docs may be used only as:

- temporary archive
- review copy
- fallback copy
- external reading format

Google Docs must not become canonical after Git import.

Google Docs copy should be labeled:

    Archive copy - Git repository is source of truth after import.

---

## 34. Mobile Draft Cleanup Rule

After commit is verified:

- compare imported document count
- compare document numbers
- compare titles
- check closure documents
- check README
- check Git log
- mark mobile draft as imported
- archive mobile source if needed
- avoid immediate deletion if unsure

Mobile draft cleanup should be conservative.

---

## 35. Import Verification Checklist

Import verification should confirm:

1. all expected files exist
2. filenames start with correct numbers
3. H1 titles match filenames
4. files are in correct range folder
5. README exists for each range
6. closure document exists for each closed range
7. root index references imported ranges
8. no duplicate numbers unresolved
9. no missing expected documents unresolved
10. no secrets present
11. no implementation code present
12. Git status is documentation-only

If not, import is not complete.

---

## 36. Import Status Values

Recommended import status values:

- `IMPORT_NOT_STARTED`
- `IMPORT_IN_PROGRESS`
- `IMPORT_REVIEW_REQUIRED`
- `IMPORT_DUPLICATE_REVIEW_REQUIRED`
- `IMPORT_MISSING_REVIEW_REQUIRED`
- `IMPORT_INDEX_UPDATE_REQUIRED`
- `IMPORT_SECRET_REVIEW_REQUIRED`
- `IMPORT_READY_TO_COMMIT`
- `IMPORT_COMMITTED`
- `IMPORT_VERIFIED`
- `IMPORT_BLOCKED`

Import status should be visible in import register.

---

## 37. Import Register Fields

Each import register entry should include:

- import id
- batch id
- source range
- source document number
- source title
- target path
- import status
- duplicate status
- missing status
- formatting status
- secret scan status
- implementation leakage status
- commit hash if committed
- notes

Import register supports auditability.

---

## 38. Import ID Format

Recommended format:

    IMPORT-[YYYYMMDD]-[NUMBER]

Example:

    IMPORT-20260612-001

Final format may be normalized later.

---

## 39. Batch ID Format

Recommended format:

    IMPORT-BATCH-[RANGE]-[NUMBER]

Examples:

    IMPORT-BATCH-05000-001
    IMPORT-BATCH-08000-001
    IMPORT-BATCH-09000-001

Final format may be normalized later.

---

## 40. Commit Verification Rule

After commit:

- check Git log
- check file count
- check target folders
- check index links
- check no unexpected deletions
- check no implementation files included
- check remote sync if pushing
- record commit hash in import register

Commit verification protects against false completion.

---

## 41. Rollback And Recovery Rule

If import goes wrong:

- stop further import
- identify affected files
- compare with mobile source
- restore from Git if committed
- restore from mobile draft if not committed
- record issue
- avoid manual panic deletion
- create correction commit if needed

Rollback must preserve documents.

---

## 42. No-Code Boundary

This PC import policy does not authorize:

- SQL creation
- migration execution
- Flutter implementation
- API route creation
- provider integration
- payment gateway setup
- KDS integration
- Admin Console build
- CI/CD change
- production deployment

Only documentation movement and index normalization are allowed.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      PC_Import_Register.md
      PC_Import_Batch_Register.md
      File_Movement_Register.md
      Missing_File_Register.md
      Duplicate_File_Register.md
      Reserved_Number_Register.md
      Root_Index_Update_Register.md
      Range_README_Update_Register.md
      Import_Secret_Scan_Register.md
      Import_Commit_Verification_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- changing policy substance during import without note
- deleting mobile draft before Git verification
- importing code with documentation
- committing secrets in Markdown
- renumbering without mapping
- moving files without movement record
- treating Google Docs as canonical after Git import
- hiding missing files
- deleting duplicates without review
- updating index with files not imported
- importing everything in one unreviewed commit
- touching unrelated project folders
- running migrations during document import

---

## 45. Non-Goals

This document does not define:

- final folder tree
- final import script
- final Git command sequence
- final root index format
- final duplicate merge decision
- final backlog register
- final implementation plan
- final release plan

Those belong to later PC-side execution and review.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. What does PC import mean?
2. What import source types exist?
3. What canonical source rule applies?
4. What import safety rule applies?
5. What target folder strategy is recommended?
6. What README placement rule applies?
7. What file naming rule applies?
8. What title match rule applies?
9. What range placement rule applies?
10. What file movement record rule applies?
11. What import batch rule applies?
12. What Git commit grouping rule applies?
13. What Git status review rule applies?
14. What diff review rule applies?
15. What Markdown formatting rule applies?
16. What duplicate detection rule applies?
17. What duplicate resolution rule applies?
18. What missing file detection rule applies?
19. What missing file statuses exist?
20. What reserved number record rule applies?
21. What root index update rule applies?
22. What range README update rule applies?
23. What cross-reference update rule applies?
24. What open gap register update rule applies?
25. What register placeholder rule applies?
26. What temporary file rule applies?
27. What secret scan rule applies?
28. What implementation leakage check applies?
29. What Google Docs fallback rule applies?
30. What mobile draft cleanup rule applies?
31. What import verification checklist applies?
32. What import status values exist?
33. What fields should import register include?
34. What commit verification rule applies?
35. What rollback and recovery rule applies?
36. What no-code boundary applies?
37. What registers are recommended?
38. What anti-patterns are prohibited?

If these questions cannot be answered, PC import, folder normalization, README, index, and file movement planning is incomplete.

---

## 47. Conclusion

PC import is the bridge between high-velocity mobile drafting and controlled repository planning.

The safe PC import flow is:

    mobile draft
        -> source check
        -> target folder selection
        -> filename normalization
        -> README placement
        -> index synchronization
        -> duplicate and missing file review
        -> secret and implementation leakage check
        -> documentation-only Git commit
        -> commit verification
        -> mobile draft cleanup

This document ensures that the completed documentation ranges become reliable Git-backed planning assets without losing traceability, leaking secrets, mixing code, or damaging range boundaries.