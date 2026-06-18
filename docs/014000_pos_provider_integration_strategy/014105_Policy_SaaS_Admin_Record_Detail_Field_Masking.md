# 014105_Policy_SaaS_Admin_Record_Detail_Field_Masking

## 1. Purpose

This document defines the SaaS Admin Console record detail page, form field visibility, masking, read-only mode, edit mode, save boundary, correction workflow, approval workflow, sensitive field handling, and no-silent-mutation policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined dashboard cards, KPI widgets, alert widgets, drilldown, and card action boundaries.

This document defines what happens after an admin user drills down from a dashboard, queue, alert, search result, or directory into a record detail page.

This document does not implement forms, frontend components, APIs, validation logic, database updates, permission guards, or audit tables.

It defines record detail page and form boundary policy only.

---

## 2. Scope

This document covers:

- record detail page purpose
- read-only mode
- edit mode
- masked field display
- sensitive field handling
- form field grouping
- save action boundary
- correction request workflow
- approval workflow
- field-level permission
- evidence-linked editing
- no-implementation boundary

This document does not cover:

- final UI layout
- final form component
- final database schema
- final API mutation logic
- final field validation implementation
- final audit implementation
- final permission engine
- final RLS policy
- final production admin workflow

---

## 3. Core Principle

A detail page may display a record without granting edit authority.

The project must follow this rule:

> Admin record detail pages must separate viewing, editing, requesting correction, approving change, saving admin notes, and mutating runtime or commercial state so that a visible field does not become an editable field by default.

A visible field is not editable.

An editable note is not runtime mutation.

A save button is not universal authority.

---

## 4. Record Detail Page Meaning

A record detail page is an Admin Console surface that shows a specific record such as:

- tenant
- store
- support case
- incident
- payment review
- KDS review
- provider incident
- billing record
- billing dispute
- commercial risk
- renewal forecast
- expansion review
- evidence packet
- audit event
- device trust record
- permission record

Detail page should show context, evidence, status, history, and allowed workflows.

---

## 5. Detail Page Modes

Recommended page modes:

- `DETAIL_READ_ONLY`
- `DETAIL_MASKED_READ_ONLY`
- `DETAIL_REVIEW_MODE`
- `DETAIL_EDIT_DRAFT_MODE`
- `DETAIL_CORRECTION_REQUEST_MODE`
- `DETAIL_APPROVAL_MODE`
- `DETAIL_ADMIN_NOTE_MODE`
- `DETAIL_EVIDENCE_REVIEW_MODE`
- `DETAIL_CLOSED_RECORD_MODE`
- `DETAIL_REVOKED_ACCESS_MODE`

Mode must be visible to the user.

---

## 6. Detail Page Status Values

Recommended detail page status values:

- `DETAIL_NOT_DEFINED`
- `DETAIL_DRAFT`
- `DETAIL_REVIEW_REQUIRED`
- `DETAIL_FIELD_MAPPING_REQUIRED`
- `DETAIL_PERMISSION_REVIEW_REQUIRED`
- `DETAIL_SECURITY_REVIEW_REQUIRED`
- `DETAIL_READY_FOR_WIREFRAME`
- `DETAIL_READY_FOR_BACKLOG`
- `DETAIL_DEFERRED`
- `DETAIL_REJECTED`

A detail page should not move to wireframe without field-level boundary review.

---

## 7. Record Header Rule

Every detail page should show a safe record header.

Header may include:

- record type
- safe record identifier
- tenant context
- store context if applicable
- status
- severity if applicable
- owner
- last updated timestamp
- mode
- masking status
- permission status

Header must not expose sensitive identifiers unnecessarily.

---

## 8. Context Panel Rule

Every detail page should show current context:

- tenant
- store or store group
- support case scope if active
- provider stack if applicable
- billing period if applicable
- pilot scope if applicable
- expansion target if applicable
- security review context if applicable

Context panel prevents acting on wrong record.

---

## 9. Field Grouping Rule

Fields should be grouped by purpose.

Recommended field groups:

- identity and context
- operational status
- commercial status
- provider status
- support status
- security status
- evidence
- audit history
- customer communication
- internal notes
- action history
- linked records

Field grouping should reduce mistakes.

---

## 10. Field Visibility Categories

Recommended field visibility categories:

- `FIELD_VISIBLE`
- `FIELD_MASKED`
- `FIELD_HIDDEN`
- `FIELD_SUMMARY_ONLY`
- `FIELD_CASE_SCOPED`
- `FIELD_SECURITY_ONLY`
- `FIELD_BILLING_ONLY`
- `FIELD_PROVIDER_ONLY`
- `FIELD_AUDIT_ONLY`
- `FIELD_EXPORT_ONLY_WITH_APPROVAL`

Visibility must follow role and context.

---

## 11. Field Editability Categories

Recommended field editability categories:

- `FIELD_READ_ONLY`
- `FIELD_EDITABLE_NOTE`
- `FIELD_EDITABLE_DRAFT`
- `FIELD_CORRECTION_REQUEST_ONLY`
- `FIELD_APPROVAL_ONLY`
- `FIELD_RUNTIME_OWNER_ONLY`
- `FIELD_COMMERCIAL_OWNER_ONLY`
- `FIELD_SECURITY_OWNER_ONLY`
- `FIELD_SYSTEM_CONTROLLED`
- `FIELD_APPEND_ONLY`

Editability must be separate from visibility.

---

## 12. Sensitive Field Categories

Sensitive fields may include:

- raw CI/DI
- customer private identity data
- payment identifiers
- provider secrets
- webhook secrets
- tokens
- device trust secret material
- staff private data
- support-only sensitive notes
- security incident details
- export contents
- cross-tenant identifiers

Sensitive fields should be masked or hidden by default.

---

## 13. Masked Field Rule

Masked fields should show only the minimum useful information.

Examples:

- partial identifier
- safe label
- last four characters if allowed
- status without raw value
- provider alias instead of credential
- customer-safe summary
- store-safe summary

Masked field must not be reversible from UI.

---

## 14. Unmask Request Rule

Unmasking requires:

- role authority
- purpose
- field scope
- time limit
- approval if needed
- audit
- reason code
- sensitive data minimization

Unmasking must not be available as casual hover or click.

---

## 15. Read-Only Mode Rule

Read-only mode may allow:

- viewing permitted fields
- viewing masked fields
- viewing linked records
- viewing evidence metadata
- viewing audit summary
- requesting review if allowed
- creating note if note permission exists

Read-only mode must not allow direct record mutation.

---

## 16. Edit Mode Rule

Edit mode may be allowed only for fields that:

- are not runtime truth owned by another system
- are within role scope
- are within tenant/store context
- have field-level editability
- have validation rules later
- have audit requirement
- have save boundary
- are not closed or immutable records

Edit mode must be explicit.

---

## 17. Admin Note Rule

Admin note may be editable when:

- note is clearly separate from truth fields
- note author is recorded
- timestamp is recorded
- note visibility is scoped
- sensitive content warning exists
- note does not overwrite evidence
- note does not change runtime state

Admin notes must not become hidden mutation log.

---

## 18. Correction Request Rule

Correction request is required when a user sees possible wrong data but lacks mutation authority.

Correction request should include:

- field or record affected
- current value or status
- proposed correction
- reason
- evidence
- urgency
- requester
- target owner
- status

Correction request does not change truth until approved and executed by owner.

---

## 19. Correction Request Status Values

Recommended values:

- `CORRECTION_REQUESTED`
- `CORRECTION_TRIAGE_REQUIRED`
- `EVIDENCE_REQUIRED`
- `OWNER_REVIEW_REQUIRED`
- `APPROVAL_REQUIRED`
- `APPROVED`
- `REJECTED`
- `EXECUTED`
- `CANCELLED`
- `SUPERSEDED`

Correction status must remain visible.

---

## 20. Save Button Boundary

A save button may save only the fields currently authorized for the current mode.

Save must not:

- mutate hidden fields
- mutate runtime truth
- mutate commercial truth without amendment
- mutate audit evidence
- mutate provider event truth
- unmask data
- export data
- close incident unless closure mode is active
- bypass approval
- apply stale context

Save is scoped, not global.

---

## 21. Draft Save Rule

Draft save may apply to:

- commercial amendment draft
- billing adjustment request draft
- support response draft
- incident review draft
- expansion review draft
- customer communication draft
- SOP action draft

Draft is not effective action.

Draft should be labeled clearly.

---

## 22. Effective Change Rule

Effective change means a change that affects operational, commercial, support, security, or provider status.

Effective change requires:

- permission
- context
- evidence
- reason
- review if required
- approval if required
- audit
- status transition record
- notification if needed

Effective change must not happen through generic form save.

---

## 23. Immutable Field Rule

Immutable or append-only fields include:

- audit event history
- original provider event
- original payment evidence
- original KDS evidence
- original invoice record
- original dispute claim
- original incident creation time
- original support access grant
- original device trust event

These fields may be annotated but not overwritten.

---

## 24. Closed Record Rule

Closed record detail page should be mostly read-only.

Closed records may allow:

- view closure reason
- view evidence
- view linked records
- request reopen
- add permitted post-closure note
- create follow-up item

Closed record must not allow silent editing of closure evidence.

---

## 25. Reopen Request Rule

Reopen request may apply to:

- support case
- incident
- billing dispute
- provider incident
- blocker
- expansion review
- renewal intervention
- security review

Reopen request requires reason and evidence.

Reopen is not automatic.

---

## 26. Approval Mode Rule

Approval mode should show:

- request summary
- original value or status
- proposed value or status
- evidence
- requester
- affected context
- risk level
- conflicts
- approval decision
- reason code
- audit requirement

Approval mode must not hide what is being approved.

---

## 27. Approval Decision Values

Recommended values:

- `APPROVE`
- `APPROVE_WITH_LIMITATION`
- `REJECT`
- `REQUEST_MORE_EVIDENCE`
- `ESCALATE`
- `DEFER`
- `CANCEL_REQUEST`
- `SUPERSEDE_WITH_NEW_REQUEST`

Approval decision must be recorded.

---

## 28. Field-Level Audit Rule

Field-level audit is required for:

- sensitive field unmask
- commercial price change
- discount/credit change
- support scope change
- device trust change
- permission change
- security status change
- provider limitation change
- incident severity change
- closure status change

Field-level audit may be summarized later, but evidence must exist.

---

## 29. Linked Records Rule

Detail page may link to related records such as:

- support case
- incident
- evidence packet
- audit event
- billing record
- amendment
- provider incident
- payment review
- KDS review
- renewal forecast
- expansion review

Linked records must re-check permission and context on open.

---

## 30. Timeline Rule

Detail page may include a timeline.

Timeline may show:

- created
- status changed
- owner assigned
- evidence attached
- review requested
- approval granted
- escalation
- containment
- closure
- reopen request

Timeline must preserve original order and avoid editing history.

---

## 31. Detail Page Action Panel Rule

Action panel may show allowed workflows such as:

- request review
- assign owner
- escalate
- request correction
- request approval
- request export
- request unmask
- request reopen
- create blocker
- create backlog item
- create amendment
- create support case

Action panel must hide or disable prohibited actions.

Disabled action should explain safe reason where appropriate.

---

## 32. Dangerous Action Confirmation Rule

Dangerous actions require confirmation.

Dangerous actions include:

- request unmask
- request export
- revoke device
- pause scope
- close critical incident
- approve billing adjustment
- approve discount
- approve expansion
- approve blocker waiver
- approve support break-glass

Confirmation should show context and consequence.

---

## 33. Stale Record Rule

If record changed since page opened:

- show stale warning
- reload before save
- prevent overwrite
- preserve draft where safe
- compare changes if needed
- require user confirmation

Stale form must not overwrite newer evidence.

---

## 34. Partial Failure Rule

If save or request partially fails later in implementation:

- user must see safe status
- no hidden partial mutation
- retry must be controlled
- evidence must show outcome
- support path must exist
- sensitive error must be masked

Partial failure must not leave user believing action completed.

---

## 35. Detail Page Error State Rule

Error state must not expose:

- raw stack trace
- SQL error
- provider secret
- webhook payload
- raw CI/DI
- payment secret
- unauthorized tenant/store id
- hidden record existence
- internal tokens

Error should provide safe next action.

---

## 36. Field Definition Record Fields

Each field definition should include:

- field id
- record type
- field name
- purpose
- visibility category
- editability category
- sensitive category
- masking rule
- allowed roles
- required context
- validation placeholder
- audit requirement
- export rule
- owner
- status
- notes

Field definition becomes future implementation input.

---

## 37. Field ID Format

Recommended format:

    ADMIN-FIELD-[RECORD-TYPE]-[FIELD-NAME]

Example:

    ADMIN-FIELD-SUPPORTCASE-SEVERITY
    ADMIN-FIELD-BILLINGRECORD-DISCOUNT
    ADMIN-FIELD-PROVIDERINCIDENT-SCOPE

Final format may be normalized later.

---

## 38. Detail Page Record Fields

Each detail page definition should include:

- detail page id
- record type
- surface family
- purpose
- required context
- allowed roles
- field groups
- sensitive fields
- editable fields
- read-only fields
- append-only fields
- allowed actions
- prohibited actions
- linked records
- timeline requirement
- evidence requirement
- audit requirement
- status
- owner
- notes

Detail page definition should precede wireframe.

---

## 39. Detail Page ID Format

Recommended format:

    ADMIN-DETAIL-[RECORD-TYPE]

Examples:

    ADMIN-DETAIL-SUPPORTCASE
    ADMIN-DETAIL-PROVIDERINCIDENT
    ADMIN-DETAIL-BILLINGDISPUTE
    ADMIN-DETAIL-EXPANSIONREVIEW

Final format may be normalized later.

---

## 40. Detail Page Register Recommendation

Recommended future files:

    docs/_index/
      Admin_Detail_Page_Register.md
      Admin_Field_Definition_Register.md
      Admin_Field_Masking_Register.md
      Admin_Edit_Mode_Register.md
      Admin_Correction_Request_Register.md
      Admin_Approval_Mode_Register.md
      Admin_Field_Level_Audit_Register.md
      Admin_Detail_Linked_Record_Register.md

This document only recommends these files.

It does not create them.

---

## 41. Anti-Patterns

The following are prohibited:

- making visible fields editable by default
- using one save button for all truth types
- editing runtime truth from commercial form
- editing audit evidence
- editing provider event raw data
- hiding masked field logic
- allowing unmask on hover
- saving stale form over newer record
- changing closed record without reopen workflow
- allowing admin notes to overwrite evidence
- using generic edit mode for sensitive records
- hiding context in detail page
- linking to records without permission re-check
- treating draft save as effective change

---

## 42. Non-Goals

This document does not define:

- final form UI
- final component library
- final API mutation endpoint
- final database schema
- final validation implementation
- final audit table
- final permission engine
- final workflow engine
- final RLS policy

Those belong to later UI/UX, security, and implementation planning.

---

## 43. Readiness Check

This document is ready when the project can answer:

1. What does record detail page mean?
2. What detail page modes exist?
3. What detail page status values exist?
4. What record header rule applies?
5. What context panel rule applies?
6. What field grouping rule applies?
7. What field visibility categories exist?
8. What field editability categories exist?
9. What sensitive field categories exist?
10. What masked field rule applies?
11. What unmask request rule applies?
12. What read-only mode rule applies?
13. What edit mode rule applies?
14. What admin note rule applies?
15. What correction request rule applies?
16. What correction request status values exist?
17. What save button boundary applies?
18. What draft save rule applies?
19. What effective change rule applies?
20. What immutable field rule applies?
21. What closed record rule applies?
22. What reopen request rule applies?
23. What approval mode rule applies?
24. What approval decision values exist?
25. What field-level audit rule applies?
26. What linked record rule applies?
27. What timeline rule applies?
28. What action panel rule applies?
29. What dangerous action confirmation rule applies?
30. What stale record rule applies?
31. What partial failure rule applies?
32. What error state rule applies?
33. What fields should field definition include?
34. What fields should detail page definition include?
35. What anti-patterns are prohibited?

If these questions cannot be answered, SaaS Admin record detail page, form field, masking, and edit mode planning is incomplete.

---

## 44. Conclusion

Record detail pages are where dashboard visibility becomes operational decision.

The safe detail page design flow is:

    drilldown
        -> context confirmation
        -> record header
        -> field grouping
        -> visibility rule
        -> masking rule
        -> editability rule
        -> correction or approval workflow
        -> evidence and audit
        -> linked record permission re-check

This document ensures that future Admin Console detail pages do not accidentally turn visible data into editable truth, expose sensitive fields, overwrite immutable evidence, or bypass runtime, commercial, support, security, and provider authority.