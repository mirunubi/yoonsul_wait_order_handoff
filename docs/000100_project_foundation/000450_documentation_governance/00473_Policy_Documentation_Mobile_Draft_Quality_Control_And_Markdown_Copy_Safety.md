# 00473_Policy_Documentation_Mobile_Draft_Quality_Control_And_Markdown_Copy_Safety

\#\# 1\. Purpose

This document defines the mobile draft quality control, Markdown copy safety, formatting stability, mobile-to-Google-Docs handling, and pre-import cleanup policy for the Yoonsul Wait/Order Handoff documentation corpus.

The project will generate many Markdown documents through mobile ChatGPT while away from the full PC development environment.

Mobile drafting is useful, but it can introduce formatting errors, broken copy blocks, duplicated sections, missing titles, nested code fence problems, Google Docs formatting artifacts, and unstable temporary titles.

Therefore, mobile drafts must follow a simple quality control standard before they are stored, imported, indexed, and used for implementation guidance.

\---

\#\# 2\. Scope

This policy applies to:

\- mobile ChatGPT-generated Markdown documents
\- mobile copy and paste workflow
\- Google Docs temporary storage
\- Markdown code block safety
\- document title consistency
\- document number consistency
\- section numbering consistency
\- mobile copy artifact detection
\- broken fence prevention
\- writing block avoidance
\- Google Docs formatting artifact cleanup
\- pre-PC-import review
\- later repository normalization
\- Cursor-assisted mobile artifact review

This document does not define final implementation content.

It defines how mobile-generated drafts should remain clean enough for later PC import and repository organization.

\---

\#\# 3\. Core Principle

Mobile drafting must optimize for safe copying and later normalization.

The project must follow this rule:

\> A mobile draft does not need perfect final placement, but it must preserve document number, title, structure, and copy integrity.

Mobile drafts may be temporary.

They must not be unreadable or structurally broken.

\---

\#\# 4\. Mobile Draft Format Rule

Each mobile-generated document should be created as one complete Markdown document.

Recommended structure:

\- H1 title with document number
\- Purpose
\- Scope
\- Core Principle
\- policy sections
\- checklist where applicable
\- non-goals
\- readiness check
\- conclusion

A mobile draft should not mix multiple documents in one response unless explicitly requested.

One response should usually equal one document.

\---

\#\# 5\. Single Copy Block Rule

For mobile copy safety, each generated document should be provided as one large Markdown block.

The document should avoid internal nested fences.

The goal is to allow the user to copy the entire document into Google Docs or another temporary storage location without losing sections.

One large block is preferred over many separated fragments.

\---

\#\# 6\. Nested Code Fence Prohibition

Nested triple backticks inside a large Markdown block are prohibited during mobile drafting.

Do not include:

\- fenced code examples
\- fenced SQL
\- fenced Bash
\- fenced JSON
\- fenced YAML
\- fenced text blocks
\- nested Markdown code fences

Nested fences may break the outer copy block on mobile apps.

If examples are needed, use indented text instead.

\---

\#\# 7\. Indented Example Rule

When examples are needed inside a mobile draft, use four-space indentation instead of code fences.

Example:

    GOOD:
        SUPABASE\_URL=https://example.supabase.co
        SUPABASE\_ANON\_KEY=replace\_with\_dummy\_key

    BAD:
        triple-backtick fenced examples inside a mobile copy block

Indented examples are safer for mobile copying.

\---

\#\# 8\. Writing Block Avoidance Rule

Writing block fences must not be used for this documentation workflow.

Avoid:

\- writing block wrapper
\- editable block wrapper
\- special UI-specific document fence
\- any format that may appear literally in mobile app output

The documentation workflow should use plain Markdown content.

The goal is stable copy/paste, not rich editing UI.

\---

\#\# 9\. Mobile Draft Title Rule

Every mobile draft must start with:

    \# {document\_number} {Document Title}

Example:

    \# 00474_Policy_Documentation_Mobile_Draft_Quality_Control_And_Markdown_Copy_Safety

The H1 title is the most important anchor for later PC import.

If the title is copied correctly, the file can later be renamed, sorted, and indexed.

\---

\#\# 10\. Document Number Preservation Rule

Document number must be preserved exactly.

A mobile draft must not:

\- omit the number
\- reuse an existing number accidentally
\- change number inside the body
\- refer to wrong number in conclusion
\- include temporary numbering that conflicts with final numbering

If numbering uncertainty exists, mark the document as \`NEEDS\_NUMBER\_REVIEW\` during PC import.

\---

\#\# 11\. Section Numbering Rule

Sections should use stable numeric headings.

Recommended:

\- \`\#\# 1\. Purpose\`
\- \`\#\# 2\. Scope\`
\- \`\#\# 3\. Core Principle\`
\- continuing sequentially

Section numbering helps detect copy loss.

If a pasted document jumps from section 9 to section 14, the missing portion can be detected quickly.

\---

\#\# 12\. Mobile Copy Loss Detection

After copying a mobile draft into Google Docs, check:

\- H1 title exists
\- first section exists
\- last conclusion section exists
\- section numbers are continuous
\- no section after a nested fence was lost
\- document did not split into normal text unexpectedly
\- no UI wrapper text was included
\- no repeated unrelated assistant sentence is inside document

Copy loss should be corrected before marking the draft as stored.

\---

\#\# 13\. Google Docs Paste Rule

When pasting into Google Docs, preserve plain text where possible.

If formatting becomes strange, the content should still preserve:

\- H1 title
\- section headings
\- bullet lists
\- numbered lists
\- indented examples
\- conclusion
\- document number

Perfect Markdown formatting is not required in Google Docs.

Text integrity is more important.

\---

\#\# 14\. Google Docs Draft Header Recommendation

At the top or title of a Google Docs draft, it may be useful to include temporary metadata.

Recommended metadata outside the final Markdown body:

\- document number
\- document title
\- draft date
\- import status
\- source conversation note
\- lane if known

Example:

    00474_Policy_Documentation_Mobile_Draft_Quality_Control_And_Markdown_Copy_Safety
    Status: MOBILE\_DRAFT
    Import: NOT\_IMPORTED

This helps later PC sorting.

\---

\#\# 15\. Mobile Draft Status Values

Recommended mobile draft statuses:

\- \`MOBILE\_DRAFT\`
\- \`COPIED\_TO\_GOOGLE\_DOCS\`
\- \`NEEDS\_COPY\_REVIEW\`
\- \`NEEDS\_NUMBER\_REVIEW\`
\- \`NEEDS\_TITLE\_REVIEW\`
\- \`NEEDS\_PC\_IMPORT\`
\- \`IMPORTED\_TO\_REPO\`
\- \`DUPLICATE\_CANDIDATE\`
\- \`OBSOLETE\`
\- \`MERGED\`

Status may be stored in Google Docs title, header note, or separate tracking note.

\---

\#\# 16\. Mobile Draft Quality Checklist

Before considering a mobile draft stored, confirm:

\- document number exists
\- H1 title exists
\- Purpose section exists
\- Scope section exists
\- Core Principle section exists
\- Readiness Check exists
\- Conclusion exists
\- no nested code fences exist
\- no writing block wrapper exists
\- no real secret exists
\- no raw CI / DI exists
\- no production credential exists
\- section order is reasonable
\- copy did not stop halfway
\- Google Docs copy is readable

If any item fails, mark as \`NEEDS\_COPY\_REVIEW\`.

\---

\#\# 17\. Prohibited Mobile Draft Content

Mobile drafts must never include:

\- real service role key
\- real API secret
\- real database password
\- real payment secret
\- real webhook signing secret
\- real production \`.env\`
\- real OAuth secret
\- raw CI
\- raw DI
\- real customer phone number
\- real customer email
\- real payment token
\- real production access token
\- vendor credential
\- private legal document content unless intended and controlled

Mobile drafting is not secure secret storage.

\---

\#\# 18\. Dummy Value Rule

When examples require values, use dummy values.

Allowed examples:

    example\_tenant\_id
    example\_store\_id
    replace\_with\_dummy\_secret
    masked\_customer\_ref
    payment\_ref\_masked
    test\_webhook\_secret
    dummy\_ci\_value
    dummy\_di\_value
    synthetic\_customer\_id

Dummy values must not resemble real credentials.

\---

\#\# 19\. No Implementation Code Rule During Mobile Drafting

Mobile drafting in the current phase should avoid implementation code.

Allowed:

\- policy
\- SOP
\- readiness check
\- implementation mapping description
\- test catalog description
\- evidence register structure
\- governance rule
\- controlled prompt for Cursor review

Not allowed unless explicitly entering implementation phase:

\- database migrations
\- SQL functions
\- RLS policies
\- API implementation
\- Flutter code
\- production deployment script
\- real provider configuration
\- executable payment code
\- executable identity integration code

Mobile drafts should remain design documents.

\---

\#\# 20\. Controlled Prompt Exception

Mobile drafts may include controlled prompts for later Cursor or AI verification.

Prompt examples are allowed when:

\- they do not contain secrets
\- they do not trigger implementation
\- they instruct AI not to code
\- they are written as indented plain text
\- they are clearly review or verification prompts

Controlled prompts support PC-side organization.

They must not become implementation instructions during documentation phase.

\---

\#\# 21\. Duplicate Prevention During Mobile Drafting

Before requesting the next document, it is useful to know:

\- last generated document number
\- last generated title
\- current lane
\- whether a closure or handoff document already exists
\- whether the next document should start a new lane

Duplicate prevention does not need to be perfect on mobile.

Duplicate correction can happen during PC import.

But obvious repeated titles should be avoided.

\---

\#\# 22\. Long Document Risk

Long mobile-generated documents may create copy risk.

Risks include:

\- partial copy
\- mobile app truncation
\- section loss
\- repeated section
\- broken Markdown
\- Google Docs paste lag
\- accidental selection failure

For very long documents, a safer approach is:

\- one document per response
\- no nested fences
\- stable headings
\- conclusion at end
\- copy immediately into Google Docs
\- check last section after paste

Long documents are acceptable if copied carefully.

\---

\#\# 23\. Mobile Review After Paste

After pasting into Google Docs, perform a quick mobile review:

1\. Check title.
2\. Check first section.
3\. Scroll near middle.
4\. Check no huge blank or broken section.
5\. Check final conclusion.
6\. Check document number.
7\. Mark status.

This review is lightweight but prevents major loss.

\---

\#\# 24\. PC Import Quality Review

During PC import, mobile drafts should be reviewed again.

PC review should check:

\- H1 and filename match
\- document number uniqueness
\- section sequence
\- no mobile artifacts
\- no Google Docs metadata inside body
\- no broken nested fence
\- no writing block markers
\- no secrets
\- no raw CI / DI
\- no duplicate document body
\- correct lane assignment
\- correct folder placement

PC import review is the final cleanup gate.

\---

\#\# 25\. Mobile Artifact Types

Common mobile artifacts include:

\- partial copy
\- duplicated title
\- missing closing section
\- copied assistant explanation outside document
\- UI-specific wrapper text
\- writing block markers
\- unintended metadata inside document
\- broken indentation
\- converted smart quotes
\- lost Markdown heading symbols
\- invisible formatting from Google Docs
\- repeated section due to regeneration

Artifacts must be corrected during PC import.

\---

\#\# 26\. Artifact Cleanup Rule

Artifact cleanup should be minimal.

Clean:

\- duplicate headings
\- accidental UI text
\- broken section numbering
\- pasted metadata inside body
\- repeated assistant preface
\- obvious formatting corruption

Do not rewrite policy meaning unnecessarily.

Mobile draft cleanup is normalization, not redesign.

\---

\#\# 27\. Mobile Draft Import Decision

During PC import, each mobile draft should receive one decision:

\- import as active
\- import as active after cleanup
\- import as duplicate candidate
\- merge into existing document
\- archive as obsolete
\- defer
\- reject because broken or unsafe

Decision must be reflected in index or import report.

\---

\#\# 28\. Markdown Fence Safety Scan

A fence safety scan should check for:

\- unmatched triple backticks
\- nested triple backticks
\- broken outer block artifacts
\- code fence language markers inside body
\- accidental continuation outside code block
\- copied fence wrapper in file body

During repository import, final \`.md\` files may contain code fences when appropriate in implementation documents.

However, mobile policy drafts should avoid nested fences to prevent copy breakage.

\---

\#\# 29\. Google Docs Formatting Caution

Google Docs may alter Markdown presentation.

Possible changes:

\- headings visually converted
\- indentation changed
\- lists reformatted
\- smart quotes inserted
\- long lines wrapped
\- hidden formatting inserted
\- links auto-created
\- copied code-like text changed

When importing to \`.md\`, plain text cleanup may be needed.

Google Docs is staging, not final Markdown authority.

\---

\#\# 30\. Mobile Draft Lane Tagging

If possible, mobile drafts may include lane tag in Google Docs note.

Example lane tags:

\- security\_foundation
\- documentation\_governance
\- pos\_kds
\- payment
\- tenant\_store
\- support
\- degraded\_recovery
\- ai\_analytics
\- vendor
\- sop
\- testing
\- implementation\_mapping
\- compliance

Lane tag helps PC sorting.

Lane tag is optional during mobile drafting.

\---

\#\# 31\. Mobile Draft Batch Grouping

Mobile drafts may be grouped by batch before PC import.

Batch grouping may use:

\- date
\- document number range
\- Google Docs folder
\- lane
\- project wave
\- source conversation

Batch grouping makes PC import easier.

Unbatched drafts are allowed but require more review.

\---

\#\# 32\. Copy Safety Checklist For Future Responses

When generating future mobile-friendly documents, follow:

\- one document per response
\- one Markdown block
\- no nested triple backticks
\- no writing block fence
\- no real secrets
\- no raw CI / DI
\- stable H1 title
\- stable section numbering
\- readiness check included
\- conclusion included
\- examples indented, not fenced

This is the preferred response format for the current documentation phase.

\---

\#\# 33\. Failure Handling

If a mobile draft copy fails:

1\. Do not trust partial paste.
2\. Mark draft as \`NEEDS\_COPY\_REVIEW\`.
3\. Request regeneration if needed.
4\. Prefer shorter or simpler formatting.
5\. Avoid nested examples.
6\. Copy again.
7\. Check final conclusion exists.
8\. Store corrected version.

Partial copied drafts should not be imported as active without review.

\---

\#\# 34\. Regeneration Rule

A document may be regenerated when:

\- copy failed
\- document was truncated
\- nested fence broke the copy
\- title was missing
\- section sequence broke
\- document duplicated badly
\- Google Docs corrupted formatting
\- mobile app output was unusable

Regeneration should preserve document number and title unless intentionally changed.

\---

\#\# 35\. Mobile Draft Completion Marker

A mobile draft may be considered complete when:

\- copied successfully
\- stored in Google Docs
\- H1 title present
\- conclusion present
\- no obvious copy loss
\- status marked
\- ready for PC import

Completion on mobile does not mean final repository readiness.

It means the draft was captured safely.

\---

\#\# 36\. Documentation Quality Versus Perfection

Mobile drafts do not need perfect final polish.

They must be:

\- structurally complete
\- readable
\- safely copied
\- number-traceable
\- title-traceable
\- free of secrets
\- suitable for later PC cleanup

Perfection comes through PC import, normalization, indexing, and review.

\---

\#\# 37\. Cursor Review Prompt For Mobile Artifacts

Recommended prompt:

    TASK:
    Review imported Markdown documents for mobile drafting artifacts.
    Do not implement code.
    Do not rewrite policy meaning.
    Detect:
    1\. missing H1 title
    2\. document number mismatch
    3\. broken section numbering
    4\. duplicated title or sections
    5\. writing block markers
    6\. broken code fences
    7\. Google Docs metadata inside document body
    8\. accidental assistant commentary
    9\. secrets or raw identity patterns
    10\. partial copy or missing conclusion
    Return a cleanup report with safe minimal edits.

This prompt keeps cleanup controlled.

\---

\#\# 38\. Non-Goals

This document does not define:

\- final Google Docs folder structure
\- final Markdown editor
\- final mobile app behavior
\- final automated copy checker
\- final Google Docs export tool
\- final repository import script
\- final documentation linter
\- final CI validation rule
\- final implementation policy

Those may be defined later if needed.

\---

\#\# 39\. Readiness Check

This policy is ready when the project can answer:

1\. What format should mobile drafts use?
2\. Why are nested code fences prohibited?
3\. How should examples be written?
4\. Why are writing block wrappers avoided?
5\. How is document number preserved?
6\. How is H1 title checked?
7\. How is copy loss detected?
8\. How is Google Docs used?
9\. What status values are used for mobile drafts?
10\. What quality checklist is applied before storage?
11\. What content is prohibited in mobile drafts?
12\. What dummy values are allowed?
13\. What implementation code is prohibited?
14\. How are duplicates prevented or later detected?
15\. How are long document risks handled?
16\. What artifacts are common?
17\. How are artifacts cleaned?
18\. What decision is made during PC import?
19\. How is fence safety scanned?
20\. What marks mobile draft completion?

If these questions cannot be answered, mobile draft quality control is incomplete.

\---

\#\# 40\. Conclusion

Mobile drafting is now an intentional part of the Yoonsul Wait/Order Handoff documentation workflow.

It allows the project to keep producing design documents even when the PC repository is not available.

The system must preserve the following rules:

\- one document per response
\- one safe Markdown block
\- no nested triple backticks
\- no writing block wrappers
\- document number must be preserved
\- H1 title must be clear
\- section numbering should be stable
\- Google Docs is temporary storage
\- mobile drafts must not contain secrets
\- mobile drafts must not contain raw CI / DI
\- mobile drafts should avoid implementation code
\- copy loss must be checked
\- mobile artifacts must be cleaned during PC import
\- repository Markdown remains final source of truth
\- Cursor may review artifacts but must not implement

Mobile drafting is useful only when the copied document remains structurally intact and safe for later normalization.
