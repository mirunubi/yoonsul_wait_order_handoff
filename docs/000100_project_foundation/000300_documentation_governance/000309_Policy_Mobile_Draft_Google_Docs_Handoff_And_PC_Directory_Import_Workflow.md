# 000309_Policy_Mobile_Draft_Google_Docs_Handoff_And_PC_Directory_Import_Workflow.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


\#\# 1\. Purpose

This document defines the mobile drafting, Google Docs temporary storage, PC import, folder creation, filename normalization, directory sorting, and implementation-deferred workflow for the Yoonsul Wait/Order Handoff project.

The project will intentionally prioritize near-complete documentation before implementation.

During mobile or external work sessions, Markdown documents may be generated through mobile ChatGPT and stored temporarily in Google Docs.

When returning to PC environment, those documents will be converted into project Markdown files, assigned to proper folders, checked against numbering rules, verified against indexes, and sorted into the repository.

This workflow allows the project to continue producing documentation even when the full development environment is not available.

\---

\#\# 2\. Scope

This policy applies to:

\- mobile ChatGPT document generation
\- Google Docs temporary storage
\- copyable Markdown document format
\- document number assignment
\- temporary document title management
\- later filename normalization
\- folder creation
\- directory sorting
\- index update
\- directory map update
\- duplicate detection
\- cross-reference review
\- implementation-deferred planning
\- Cursor or AI-assisted verification
\- PC-side repository import
\- future implementation readiness preparation

This document does not authorize implementation.

It defines the documentation-first workflow before implementation begins.

\---

\#\# 3\. Core Principle

Documentation may be created anywhere, but implementation must wait until the document system is organized.

The project must follow this rule:

\> Mobile drafting is allowed, temporary storage is allowed, later folder sorting is allowed, but implementation must remain deferred until the documentation system is verified.

The goal is to build a near-complete design corpus before code generation.

\---

\#\# 4\. Documentation-First Direction

The project will follow a documentation-first direction.

The intended sequence is:

1\. Generate policies, SOPs, indexes, runtime boundaries, readiness checks, and implementation gates.
2\. Store mobile-generated Markdown drafts in Google Docs when away from PC.
3\. Later import the drafts into the project repository.
4\. Create or adjust folders.
5\. Normalize file names.
6\. Verify document numbering.
7\. Update index and directory map files.
8\. Detect overlap and missing documents.
9\. Prepare implementation mapping.
10\. Start implementation only after documentation is sufficiently complete and organized.

Implementation is intentionally delayed.

Design completeness is the priority.

\---

\#\# 5\. Mobile Drafting Policy

Mobile drafting is allowed for large document generation.

Mobile drafting should use:

\- one full Markdown document at a time
\- clear document number
\- clear document title
\- consistent section structure
\- no nested code blocks inside large copy block
\- no implementation code unless explicitly required by a later implementation phase
\- no secrets
\- no real CI / DI
\- no production credentials
\- no production customer data
\- no raw payment data

Mobile drafting should prioritize policies, SOPs, readiness checks, governance, and design boundaries.

\---

\#\# 6\. Copyable Markdown Format

Mobile-generated documents should be copyable.

Recommended format:

\- one large Markdown block
\- one document per response
\- document number in H1 title
\- no nested triple backticks inside the document
\- examples written as text or indented blocks
\- stable section numbering
\- Readiness Check section
\- Conclusion section

This format reduces mobile copy failure and supports later conversion to \`.md\` files.

\---

\#\# 7\. Google Docs Temporary Storage Policy

Google Docs may be used as temporary storage.

Google Docs storage is allowed for:

\- mobile-generated Markdown drafts
\- document blocks not yet imported into repository
\- temporary copy/paste staging
\- review before PC import
\- grouping by sequence or topic

Google Docs should not be treated as the final source of truth.

The repository Markdown files become the final project source after import and verification.

\---

\#\# 8\. Google Docs Organization Recommendation

Temporary Google Docs organization may use simple grouping.

Recommended grouping:

\- Security Foundation Drafts
\- POS/KDS Runtime Drafts
\- Degraded Recovery Drafts
\- Payment Boundary Drafts
\- Support Access Drafts
\- Tenant Store Boundary Drafts
\- AI Analytics Drafts
\- Vendor And Integration Drafts
\- SOP Drafts
\- Index And Readiness Drafts
\- Unsorted Drafts

Perfect folder structure is not required during mobile drafting.

Sorting can happen later on PC.

\---

\#\# 9\. Temporary Title Policy

Temporary titles may differ from final file names.

During mobile drafting, a document title may be:

\- document number plus title
\- short topic label
\- Google Docs temporary title
\- sequence marker
\- unsorted draft label

Final filename may change after folder names and directory rules are finalized.

Temporary title mismatch is acceptable until PC import.

\---

\#\# 10\. PC Import Policy

When returning to PC, mobile drafts should be imported into the project repository.

PC import should include:

1\. Open Google Docs draft.
2\. Copy Markdown content.
3\. Create \`.md\` file in temporary import folder.
4\. Verify document number.
5\. Verify title.
6\. Normalize file name.
7\. Move to proper directory.
8\. Update index.
9\. Update directory map.
10\. Run duplicate and cross-reference review.
11\. Commit only after review.

Import should not trigger implementation.

\---

\#\# 11\. Temporary Import Folder

A temporary import folder may be used before final sorting.

Recommended temporary folder:

\- \`docs/\_incoming\_mobile\_drafts/\`

Temporary import folder may contain unsorted drafts until verified.

Documents should not remain there permanently.

Each draft should eventually be moved to its proper directory or marked as duplicate, obsolete, or deferred.

\---

\#\# 12\. Folder Creation Policy

Folders may be created after enough documents reveal stable categories.

Folder creation should follow actual document clusters.

Possible folder categories:

\- foundation
\- security
\- pos\_kds
\- degraded\_recovery
\- payment
\- tenant\_store
\- support
\- audit
\- deployment
\- external\_integrations
\- ai\_analytics
\- vendor
\- sop
\- readiness
\- implementation\_mapping
\- testing
\- compliance

Folder names may evolve.

If folder names change, filenames and index references may also change.

Folder changes must be reflected in directory map documents.

\---

\#\# 13\. Filename Normalization Policy

Final filenames should be normalized after folder placement.

Filename should generally include:

\- document number
\- document title
\- \`.md\` extension

Recommended style:

\- \`04720\_Mobile\_Draft\_Google\_Docs\_Handoff\_And\_PC\_Directory\_Import\_Workflow\_Policy.md\`

Filename may change if:

\- folder naming convention changes
\- title is shortened
\- document is moved to another lane
\- duplicate is merged
\- index structure changes
\- prefix strategy changes

Filename changes must preserve document number and title traceability.

\---

\#\# 14\. Document Number Policy

Document number must be preserved.

Each document must have:

\- unique number
\- matching H1 title
\- matching index entry
\- matching filename where possible
\- correct directory placement

Number conflicts must be resolved before final import.

A document number must not be reused for unrelated content.

\---

\#\# 15\. Index Update Policy

After import, index files must be updated.

Index update should include:

\- document number
\- title
\- directory path
\- status
\- related cluster
\- cross-reference where needed
\- readiness state

Index update must not be skipped because documents were generated on mobile.

Mobile origin does not reduce documentation governance.

\---

\#\# 16\. Directory Map Update Policy

Directory map must reflect final folder structure.

Directory map should show:

\- root documentation folders
\- subfolders
\- document number ranges
\- document cluster purpose
\- imported mobile drafts now sorted
\- deprecated or merged folders where applicable

Directory map should be updated after batch import and sorting.

\---

\#\# 17\. Duplicate Detection Policy

Mobile drafting may create overlapping documents.

Duplicate review should detect:

\- same document number
\- same title with different number
\- same policy repeated in another cluster
\- security policy duplicated in SOP
\- implementation mapping duplicated as foundation policy
\- readiness checklist duplicated across documents
\- obsolete draft replaced by newer version

Duplicates should be merged, renamed, or marked obsolete.

No duplicate should silently remain as active policy.

\---

\#\# 18\. Cross-Reference Review Policy

Imported documents should be reviewed for cross-reference consistency.

Review should check:

\- referenced document numbers exist
\- document title matches referenced number
\- security foundation references are valid
\- POS/KDS references are valid
\- payment references are valid
\- support references are valid
\- implementation mapping references are valid
\- readiness index references are valid

Broken cross-references should be fixed before implementation.

\---

\#\# 19\. Cursor Verification Policy

Cursor or similar tools may be used for verification and organization.

Cursor should be instructed to:

\- verify filenames
\- verify document numbers
\- verify titles
\- verify folder placement
\- detect duplicates
\- detect missing index entries
\- detect broken cross-references
\- detect implementation leakage
\- suggest moves
\- suggest renames
\- suggest index updates

Cursor should not be allowed to implement code during documentation verification.

\---

\#\# 20\. AI-Assisted Sorting Boundary

AI tools may assist sorting, but must not invent final architecture without instruction.

Allowed AI tasks:

\- classify documents by topic
\- suggest folder placement
\- detect numbering gaps
\- detect duplicate themes
\- detect missing readiness checks
\- detect inconsistent titles
\- propose index updates
\- propose directory map updates

Prohibited AI tasks during this phase:

\- generating implementation code
\- creating database migrations
\- creating RPC functions
\- changing runtime architecture without approval
\- deleting documents without review
\- rewriting large policy blocks without instruction
\- silently merging documents
\- creating secrets or credentials
\- modifying production configuration

AI is a documentation assistant during this phase.

\---

\#\# 21\. Implementation Deferred Rule

Implementation remains deferred.

No implementation should begin until:

\- document corpus is near-complete
\- security foundation is mapped
\- POS/KDS boundary is mapped
\- payment boundary is mapped
\- tenant/store boundary is mapped
\- database and RLS design are mapped
\- support access is mapped
\- audit event taxonomy is mapped
\- degraded recovery is mapped
\- testing catalog exists
\- implementation gates exist
\- indexes and directory maps are stable enough

Implementation before design stabilization creates rework and risk.

\---

\#\# 22\. Near-Complete Documentation Target

The project target is near-complete documentation before implementation.

Near-complete means:

\- major policies exist
\- major SOPs exist
\- major runtime boundaries exist
\- major readiness checks exist
\- security foundation exists
\- continuation register exists
\- implementation mapping documents exist
\- folder structure is usable
\- index files are updated
\- document duplicates are controlled
\- open gaps are tracked
\- implementation blockers are visible

Near-complete does not mean every sentence is perfect.

It means implementation has enough controlled design to proceed safely.

\---

\#\# 23\. Three-Month Documentation Window

The project may use an extended documentation window before implementation.

During this period:

\- generate large policy sets
\- generate SOP sets
\- generate mapping sets
\- generate test catalogs
\- generate readiness indexes
\- refine folder structure
\- move mobile drafts to repository
\- verify document structure
\- reduce ambiguity
\- prepare implementation gates

This window is intended to reduce implementation chaos later.

\---

\#\# 24\. Cost And Tooling Strategy

The documentation-first phase can use lightweight tooling.

During documentation phase:

\- mobile ChatGPT can generate drafts
\- Google Docs can store drafts
\- PC can later organize files
\- Cursor can verify and sort documents
\- repository can remain documentation-heavy
\- implementation tools can remain secondary

During later implementation phase, stronger tooling may be justified.

Tooling cost should match current phase.

Design phase does not require full implementation tooling spend.

\---

\#\# 25\. Document Quality Standard

Mobile-generated documents must still meet baseline quality.

Each policy document should include:

\- Purpose
\- Scope
\- Core Principle
\- policy sections
\- checklist where applicable
\- non-goals
\- readiness check
\- conclusion

Each SOP document should include:

\- purpose
\- trigger
\- roles
\- allowed actions
\- prohibited actions
\- evidence
\- escalation
\- closure condition
\- readiness check

Each implementation mapping should include:

\- affected policy documents
\- runtime boundary
\- data category
\- authority boundary
\- audit
\- masking
\- testing
\- incident path

\---

\#\# 26\. Mobile Draft Limitation Awareness

Mobile drafting has limitations.

Possible issues:

\- copy block may break
\- title may be inconsistent
\- folder path may be unknown
\- duplicate may be created
\- cross-reference may be incomplete
\- document may be too broad
\- some documents may belong to another lane
\- temporary Google Docs formatting may alter Markdown

These issues are acceptable during drafting.

They must be corrected during PC import.

\---

\#\# 27\. No Secret Rule During Mobile Drafting

Mobile drafting must never include real secrets.

Do not paste:

\- Supabase service role key
\- API key
\- database password
\- payment secret
\- webhook signing secret
\- production \`.env\`
\- OAuth secret
\- CI / DI credential
\- production token
\- real customer identity
\- raw payment token

Mobile notes and Google Docs are not secret stores.

\---

\#\# 28\. Repository Source Of Truth Rule

The repository becomes the source of truth after import.

Google Docs remains:

\- temporary draft storage
\- mobile capture area
\- unsorted staging area

Repository Markdown files become:

\- final document record
\- index source
\- directory map source
\- implementation reference
\- AI coding constraint source
\- future audit reference

A document is not final until it is imported, named, placed, indexed, and reviewed.

\---

\#\# 29\. Batch Import Workflow

Recommended batch import workflow:

1\. Select one Google Docs group.
2\. Copy each document into temporary \`.md\` file.
3\. Preserve document number and title.
4\. Run filename normalization.
5\. Sort by number.
6\. Detect duplicates.
7\. Move to target folder.
8\. Update local index.
9\. Update directory map.
10\. Review cross-references.
11\. Mark imported Google Docs entry.
12\. Commit batch.

Small batches are safer than one massive import.

\---

\#\# 30\. Batch Review Checklist

Before committing imported documents, confirm:

\- each file has one H1 title
\- H1 begins with document number
\- filename matches document number
\- file extension is \`.md\`
\- document number is unique
\- folder path is reasonable
\- no nested broken code fence remains
\- no secret exists
\- no raw CI / DI exists
\- no implementation code leaked into policy-only document
\- index entry exists
\- directory map is updated or update is queued
\- duplicate candidates are reviewed
\- cross-references are not obviously broken

If any item fails, fix before final commit.

\---

\#\# 31\. Google Docs Imported Marker

After PC import, Google Docs drafts should be marked.

Possible marker:

\- \`IMPORTED\`
\- \`MOVED\_TO\_REPO\`
\- \`DUPLICATE\_REVIEW\`
\- \`OBSOLETE\`
\- \`NEEDS\_PC\_REVIEW\`
\- \`MERGED\`
\- \`DEFERRED\`

This prevents repeatedly importing the same draft.

\---

\#\# 32\. Implementation Start Gate

Implementation may begin only after a controlled start gate.

Recommended implementation start conditions:

\- documentation corpus is near-complete
\- folder structure is stable enough
\- security foundation is complete
\- indexes are updated
\- directory map is usable
\- core implementation mappings exist
\- major SOPs exist
\- test catalogs exist
\- open blockers are known
\- secrets and environments are prepared
\- implementation tools are selected
\- first implementation wave is defined

Implementation must start as controlled wave, not broad free coding.

\---

\#\# 33\. First Implementation Wave Preview

The first implementation wave should be defined later.

Possible first wave may include:

\- repository cleanup
\- directory validation
\- base schema skeleton
\- tenant/store context foundation
\- audit event skeleton
\- RLS deny-by-default skeleton
\- safe environment setup
\- no payment mutation yet
\- no CI / DI production integration yet
\- no POS/KDS production integration yet

This document does not authorize that wave.

It only notes that first implementation must be narrow and controlled.

\---

\#\# 34\. Benefits Of This Workflow

This workflow provides:

\- continuous progress while mobile
\- reduced PC-only bottleneck
\- large documentation coverage
\- lower implementation ambiguity
\- stronger AI coding constraints later
\- easier Cursor verification
\- safer security foundation
\- better patent and SOP alignment
\- reduced rework
\- controlled implementation start
\- lower tooling cost during design phase

The workflow fits a large project that must be designed before coding.

\---

\#\# 35\. Risks Of This Workflow

This workflow also creates risks.

Risks include:

\- too many documents without index
\- duplicated content
\- inconsistent titles
\- folder drift
\- over-documentation
\- delayed implementation feedback
\- policy overlap
\- mobile copy errors
\- Google Docs formatting issues
\- eventual import workload overload

These risks must be managed by batch import, index discipline, and continuation register.

\---

\#\# 36\. Risk Controls

Risk controls include:

\- one document per response
\- document number preserved
\- mobile-friendly Markdown format
\- temporary Google Docs grouping
\- PC-side batch import
\- incoming draft folder
\- filename normalization
\- duplicate detection
\- index update
\- directory map update
\- continuation register
\- no implementation during design phase
\- Cursor used for verification, not uncontrolled generation

The workflow is safe only if the PC review phase is actually performed.

\---

\#\# 37\. Non-Goals

This document does not define:

\- final folder names
\- final document numbering system
\- final index file format
\- final directory map format
\- final Cursor prompt library
\- final implementation roadmap
\- final code architecture
\- final database schema
\- final deployment pipeline
\- final tool subscription plan

Those must be defined or refined in later documentation management, project governance, or implementation planning documents.

\---

\#\# 38\. Readiness Check

This workflow is ready when the project can answer:

1\. How are mobile-generated documents stored?
2\. Where are Google Docs drafts grouped?
3\. What format should mobile Markdown use?
4\. How are drafts imported into PC?
5\. Where do unsorted imported drafts go?
6\. How are filenames normalized?
7\. How are folders created or changed?
8\. How is document number uniqueness checked?
9\. How is index updated?
10\. How is directory map updated?
11\. How are duplicates detected?
12\. How are cross-references reviewed?
13\. How is Cursor allowed to assist?
14\. What must Cursor not do during documentation phase?
15\. What marks a Google Docs draft as imported?
16\. What blocks implementation?
17\. What defines near-complete documentation?
18\. When can implementation start?
19\. What are the risks of mobile-first drafting?
20\. How are those risks controlled?

If these questions cannot be answered, the mobile-to-PC documentation workflow is incomplete.

\---

\#\# 39\. Conclusion

The Yoonsul Wait/Order Handoff project will intentionally use a documentation-first workflow.

Mobile ChatGPT drafting and Google Docs temporary storage allow the project to keep moving even outside the full PC development environment.

PC-side import, folder creation, filename normalization, index update, and Cursor-assisted verification will later convert those drafts into controlled repository documents.

The system must preserve the following rules:

\- mobile drafting is allowed
\- Google Docs is temporary storage
\- repository Markdown is final source of truth
\- filenames may change after folder structure stabilizes
\- document numbers must remain traceable
\- PC import must verify structure
\- Cursor may verify and sort
\- Cursor must not implement during documentation phase
\- duplicates must be detected
\- indexes and directory maps must be updated
\- secrets must never be placed in mobile drafts
\- implementation remains deferred
\- near-complete documentation comes before coding

This workflow turns scattered mobile drafting into a controlled design pipeline.

It allows the project to build almost the full documentation spine before implementation begins.
