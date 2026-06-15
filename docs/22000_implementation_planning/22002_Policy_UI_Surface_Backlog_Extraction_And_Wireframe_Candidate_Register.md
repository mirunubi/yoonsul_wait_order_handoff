# 22002_Policy_UI_Surface_Backlog_Extraction_And_Wireframe_Candidate_Register

## 1. Purpose

This document defines the UI surface backlog extraction, wireframe candidate register, surface ownership mapping, role/context mapping, field visibility mapping, action boundary mapping, evidence display mapping, test linkage, blocker linkage, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined runtime owner mapping, backlog category register, AI customer support gateway boundary, pgvector/RAG foundation reference, runtime dependency, and category-to-review/test/evidence mapping.

This document focuses on extracting UI-related backlog candidates from the documentation corpus and preparing them for later wireframe planning without allowing UI design to create authority, expose sensitive fields, bypass runtime boundaries, or become premature implementation.

This document does not create final UI wireframes, Figma files, frontend routes, Flutter screens, Admin Console pages, Mini Kiosk screens, or customer-facing UI.

It defines UI surface backlog extraction and wireframe candidate register policy only.

---

## 2. Scope

This document covers:

- UI surface backlog extraction
- wireframe candidate meaning
- surface register
- role mapping
- context mapping
- field visibility mapping
- field masking mapping
- action boundary mapping
- state display mapping
- evidence display mapping
- audit display mapping
- test linkage
- blocker linkage
- no-code boundary

This document does not cover:

- final UX design
- final visual design
- final component system
- final frontend implementation
- final Admin Console build
- final Mini Kiosk build
- final KDS UI build
- final customer web build
- final mobile app build

---

## 3. Core Principle

UI backlog must express the authority model, not invent it.

The project must follow this rule:

> Every UI surface backlog candidate must be source-backed, role-scoped, context-scoped, field-mapped, action-mapped, masking-aware, evidence-linked, test-linked where critical, and blocked when runtime authority or security boundary is unclear.

UI is not decoration.

UI is operational authority made visible.

---

## 4. UI Surface Backlog Meaning

UI surface backlog means a future work candidate related to a screen, page, panel, dashboard, modal, form, list, detail view, task queue, support surface, KDS view, Mini Kiosk flow, Admin Console view, or customer-facing interaction.

A UI surface backlog candidate may represent:

- new surface
- new screen state
- field group
- masked field display
- role-specific view
- context switch
- list/filter/search behavior
- form workflow
- task queue
- warning state
- error state
- evidence link display
- audit timeline display
- review/approval action
- prohibited action prevention

UI backlog candidate is not UI implementation.

---

## 5. Wireframe Candidate Meaning

Wireframe candidate means a UI backlog item that is ready or nearly ready to become a future screen planning item.

Wireframe candidate must have:

- source policy
- target surface
- primary user role
- context
- visible records
- sensitive fields
- allowed actions
- prohibited actions
- state behavior
- evidence link
- audit requirement if needed
- blocker status

Wireframe candidate does not mean final design.

---

## 6. UI Surface Categories

Recommended UI surface categories:

- `CUSTOMER_WEB_SURFACE`
- `WAITING_CUSTOMER_SURFACE`
- `SEATED_CUSTOMER_SURFACE`
- `MINI_KIOSK_SURFACE`
- `STORE_STAFF_SURFACE`
- `STORE_MANAGER_SURFACE`
- `STORE_OWNER_SURFACE`
- `TENANT_HQ_SURFACE`
- `KDS_SURFACE`
- `SUPPORT_CONSOLE_SURFACE`
- `ADMIN_CONSOLE_SURFACE`
- `PAYMENT_REVIEW_SURFACE`
- `PROVIDER_OPERATIONS_SURFACE`
- `BILLING_SURFACE`
- `SECURITY_REVIEW_SURFACE`
- `PILOT_DASHBOARD_SURFACE`
- `TRAINING_SURFACE`
- `AI_SUPPORT_SURFACE`

Surface category should determine review path.

---

## 7. UI Backlog Status Values

Recommended UI backlog status values:

- `UI_CANDIDATE`
- `UI_SOURCE_REVIEW_REQUIRED`
- `UI_ROLE_REVIEW_REQUIRED`
- `UI_CONTEXT_REVIEW_REQUIRED`
- `UI_FIELD_MAPPING_REQUIRED`
- `UI_MASKING_REVIEW_REQUIRED`
- `UI_ACTION_REVIEW_REQUIRED`
- `UI_EVIDENCE_MAPPING_REQUIRED`
- `UI_TEST_MAPPING_REQUIRED`
- `UI_BLOCKED`
- `UI_DEFERRED`
- `UI_READY_FOR_WIREFRAME`
- `UI_READY_FOR_BUILD_GATE`
- `UI_REJECTED`
- `UI_SUPERSEDED`

Status must not imply implementation.

---

## 8. UI Surface Register Fields

Each UI surface register entry should include:

- surface id
- surface title
- surface category
- source reference
- linked backlog id
- linked runtime owner
- primary role
- secondary roles
- context scope
- visible records
- hidden records
- visible fields
- masked fields
- editable fields
- read-only fields
- allowed actions
- prohibited actions
- state displays
- evidence links
- audit displays
- test links
- blocker links
- status
- notes

Surface register must be concrete enough for wireframe planning.

---

## 9. Surface ID Format

Recommended format:

    UI-SURFACE-[CATEGORY]-[YYYYMMDD]-[NUMBER]

Examples:

    UI-SURFACE-ADMIN_CONSOLE_SURFACE-20260612-001
    UI-SURFACE-MINI_KIOSK_SURFACE-20260612-001
    UI-SURFACE-KDS_SURFACE-20260612-001

Final format may be normalized later.

---

## 10. Wireframe Candidate Register Fields

Each wireframe candidate should include:

- wireframe candidate id
- surface id
- source policy
- primary user story
- role
- context
- screen purpose
- entry point
- exit point
- key state
- visible data
- masked data
- user actions
- blocked actions
- warning states
- error states
- empty states
- evidence links
- audit notes
- unresolved gaps
- readiness status

Wireframe candidate should not include visual design details yet.

---

## 11. Wireframe Candidate ID Format

Recommended format:

    WIREFRAME-CANDIDATE-[YYYYMMDD]-[NUMBER]

Example:

    WIREFRAME-CANDIDATE-20260612-001

Final format may be normalized later.

---

## 12. Source Traceability Rule

Every UI surface candidate must include source reference.

Source may come from:

- Admin Console policy
- Mini Kiosk policy
- KDS policy
- Payment review policy
- Support access policy
- High-risk foundation policy
- Pilot policy
- Commercial policy
- AI support gateway policy
- Security foundation policy
- Documentation governance policy

UI surface without source must not proceed.

---

## 13. Role Mapping Rule

Every UI surface candidate must identify primary role.

Possible roles:

- customer
- waiting customer
- seated customer
- Mini Kiosk user
- store staff
- kitchen staff
- store manager
- store owner
- tenant HQ user
- support agent
- support manager
- payment reviewer
- KDS reviewer
- provider operator
- billing owner
- security reviewer
- legal reviewer
- pilot owner
- AI support supervisor
- system admin

Role determines what can be seen and done.

---

## 14. Role Scope Rule

Role scope should define:

- read-only access
- action access
- approval access
- export access
- unmask access
- comment access
- evidence access
- task assignment access
- context switching access
- high-risk action access

Role scope must be explicit before wireframe.

---

## 15. Context Mapping Rule

Every UI surface candidate must identify context.

Possible contexts:

- public session
- customer session
- waiting session
- table session
- store context
- tenant context
- support case context
- payment review context
- KDS review context
- provider incident context
- billing context
- security review context
- pilot context
- high-risk operation context
- AI support case context
- cross-store context
- cross-tenant context

Context determines visibility and action authority.

---

## 16. Context Reset Rule

If UI allows context switch:

- selected rows must reset
- previous detail view must reload
- bulk actions must clear
- filters must re-check permission
- search results must reset
- cached sensitive data must clear
- evidence links must re-check access
- task queue ownership must re-check

Context switch must not leak previous context data.

---

## 17. Record Visibility Rule

Every UI surface candidate should define visible records.

Visible record examples:

- waiting session
- table session
- order candidate
- payment review item
- KDS ticket
- provider event candidate
- support case
- incident
- evidence packet
- audit event summary
- blocker
- pilot readiness item
- billing dispute
- high-risk operation review
- AI support answer draft

Visible record does not mean editable record.

---

## 18. Hidden Record Rule

UI surface should define hidden records.

Hidden records may include:

- records outside tenant/store context
- records outside support case scope
- raw provider events
- raw identity evidence
- restricted security notes
- restricted legal notes
- payment secrets
- raw CI/DI
- unrelated customer sessions
- archived evidence not allowed for role

Hidden records must not leak through count, search, or filter.

---

## 19. Field Visibility Mapping Rule

Every visible record should map fields.

Field states may include:

- `VISIBLE`
- `MASKED`
- `HIDDEN`
- `READ_ONLY`
- `EDITABLE_DRAFT`
- `EDITABLE_WITH_APPROVAL`
- `REQUEST_ONLY`
- `SECURITY_ONLY`
- `LEGAL_ONLY`
- `SUPPORT_ONLY`
- `SYSTEM_ONLY`

Field mapping must be role and context aware.

---

## 20. Field Masking Mapping Rule

Masking is required for sensitive fields.

Sensitive fields include:

- CI/DI
- identity verification raw result
- payment detail
- provider raw payload
- provider secret
- customer private data
- staff private data
- support break-glass detail
- legal review detail
- security incident detail
- high-risk operation evidence

Masked fields must remain masked in export, search, filter, notification, and tooltip.

---

## 21. Field Editability Mapping Rule

Editable fields must be limited.

Editability states may include:

- never editable
- draft editable
- correction request only
- approval required
- owner only
- security role only
- legal role only
- support note only
- system generated
- append-only

Editable UI must not overwrite runtime truth.

---

## 22. Action Mapping Rule

Every UI candidate should map allowed and prohibited actions.

Action types may include:

- view
- search
- filter
- sort
- select
- bulk action
- request review
- assign task
- add note
- upload evidence
- request approval
- approve
- reject
- hold
- release
- refund request
- cancel request
- export request
- unmask request
- escalate
- close

Each action must be tied to authority.

---

## 23. Button Extraction Rule

A button may become UI backlog only when it has:

- source policy
- role permission
- context rule
- runtime authority
- precondition
- prohibited behavior
- audit requirement if needed
- evidence requirement if needed
- disabled state reason
- test candidate if critical

Button without authority is a risk.

---

## 24. Prohibited Button Rule

Prohibited button examples:

- one-click refund approval without payment authority
- one-click KDS release under uncertainty
- raw CI/DI unmask without approval
- export all records from list view
- trust provider event as canonical
- close incident without evidence
- activate alcohol mode by default
- bypass staff confirmation
- bulk approve high-risk task
- force cross-tenant context action

These should become prevention requirements.

---

## 25. State Display Mapping Rule

UI must display runtime states carefully.

State display may include:

- payment pending
- payment accepted
- payment uncertain
- KDS hold
- KDS released
- provider event pending validation
- support case open
- evidence incomplete
- blocker active
- export pending approval
- unmask pending approval
- high-risk mode disabled
- AI answer requires human review
- data stale

State labels must not misrepresent authority.

---

## 26. Empty State Mapping Rule

Empty states must be safe.

Empty state examples:

- no visible tasks in this context
- no evidence packets available to this role
- no provider incidents visible
- no payment reviews assigned
- no pilot blockers for selected store
- no AI support drafts pending review

Empty state must not imply hidden record count.

---

## 27. Error State Mapping Rule

Error states must avoid leakage.

Error state must not show:

- SQL error
- stack trace
- raw provider payload
- provider secret
- CI/DI
- payment secret
- hidden tenant id
- internal permission rule detail
- customer private data

Error should guide safe recovery.

---

## 28. Warning State Mapping Rule

Warning states should be extracted for risk.

Warning examples:

- provider event uncertain
- payment/KDS mismatch
- KDS release blocked
- evidence incomplete
- export requires approval
- unmask requires approval
- support session expires
- AI answer low confidence
- data may be stale
- high-risk operation disabled
- legal review required
- security review required

Warning must be actionable.

---

## 29. Evidence Display Mapping Rule

UI surface may display evidence links.

Evidence display should show:

- evidence exists
- evidence incomplete
- evidence review required
- evidence restricted
- evidence accepted
- evidence rejected
- evidence superseded

UI should link to evidence, not copy sensitive evidence content.

---

## 30. Audit Display Mapping Rule

UI may display audit summary.

Audit display should distinguish:

- user action
- system event
- approval
- rejection
- export
- unmask
- evidence link
- task assignment
- support access
- high-risk action
- security action

Audit display must respect masking and role.

---

## 31. Search Filter Extraction Rule

Search/filter backlog should be extracted separately when:

- sensitive fields exist
- cross-context records exist
- filter count may leak hidden data
- autocomplete may leak hidden values
- global search is requested
- Admin Console list is involved
- support case scope applies
- security/legal restricted records exist

Search/filter is a high-risk UI surface.

---

## 32. List Table Extraction Rule

List table backlog should define:

- default columns
- optional columns
- hidden columns
- masked columns
- row status
- row actions
- selection behavior
- bulk action behavior
- pagination
- sort
- export boundary
- context reset

List table must not become data exfiltration tool.

---

## 33. Detail Page Extraction Rule

Detail page backlog should define:

- header
- context panel
- status panel
- field groups
- masking
- evidence links
- audit timeline
- notes
- tasks
- allowed actions
- prohibited actions
- edit mode
- correction request mode

Detail page must not become uncontrolled mutation surface.

---

## 34. Form Workflow Extraction Rule

Form backlog should define:

- purpose
- draft state
- submit state
- approval state
- validation requirement
- evidence requirement
- cancellation path
- stale record handling
- audit requirement
- effective change boundary

Form submit does not always mean effective change.

---

## 35. Task Queue Extraction Rule

Task queue backlog should define:

- queue type
- task type
- task status
- assignee
- priority
- due state
- blocker
- evidence completeness
- allowed actions
- prohibited actions
- escalation
- workload indicator

Task assignment does not grant permission.

---

## 36. AI Support UI Extraction Rule

AI support UI backlog should define:

- AI answer draft surface
- source citation display
- confidence display
- freshness display
- human review requirement
- support case scope
- masked fields
- prohibited raw data display
- escalation action
- audit of AI access
- feedback capture

AI support UI must not present uncertain answer as final truth.

---

## 37. Customer UI Extraction Rule

Customer UI backlog should prioritize:

- clear waiting state
- clear order state
- clear payment state
- safe error messages
- staff call path
- simple recovery path
- no internal terminology
- no sensitive exposure
- non-accusatory high-risk wording
- low-friction flow

Customer UI should hide internal complexity.

---

## 38. Mini Kiosk UI Extraction Rule

Mini Kiosk UI backlog should define:

- session start
- menu selection
- cart confirmation
- payment attempt
- timeout
- duplicate tap prevention
- staff call
- order recovery
- high-risk item restriction
- no authority bypass

Mini Kiosk must remain bounded by POS/payment/KDS authority.

---

## 39. KDS UI Extraction Rule

KDS UI backlog should define:

- ticket status
- hold state
- release state
- cancel/remake/retry state
- delay indicator
- stale indicator
- provider mapping warning
- payment dependency warning
- no customer identity payload
- high-risk item hold

KDS UI should serve kitchen execution only.

---

## 40. Admin Console UI Extraction Rule

Admin Console UI backlog should define:

- dashboard
- tenant/store directory
- role/context switch
- permission-aware list
- detail page
- task queue
- approval queue
- evidence link
- audit timeline
- collaboration notes
- export/unmask request
- high-risk review surface

Admin Console must not become universal override.

---

## 41. Support Console UI Extraction Rule

Support Console UI backlog should define:

- support case list
- case detail
- masked customer data
- evidence links
- payment/KDS/provider timeline
- recovery note
- escalation
- break-glass request
- session expiry
- safe customer communication draft

Support Console must remain case-scoped.

---

## 42. Security Review UI Extraction Rule

Security Review UI backlog should define:

- unmask request queue
- export request queue
- support break-glass review
- security incident review
- sensitive comment redaction
- provider credential review
- audit integrity view
- masking test evidence
- tenant isolation evidence

Security review UI must be restricted.

---

## 43. Pilot Dashboard UI Extraction Rule

Pilot Dashboard backlog should define:

- pilot scope
- readiness checklist
- blocker list
- test status
- evidence status
- incident list
- learning log
- support load
- provider status
- go/no-go decision

Pilot dashboard must not imply production readiness.

---

## 44. Commercial UI Extraction Rule

Commercial UI backlog should define:

- package scope
- billing responsibility
- provider pass-through
- support tier
- contract amendment
- renewal risk
- churn reason
- discount/credit
- commercial blocker
- operational readiness dependency

Commercial UI must not promise unavailable operations.

---

## 45. Wireframe Entry Gate

A UI candidate may move to wireframe only when:

- source policy exists
- role defined
- context defined
- records defined
- field visibility defined
- masking defined
- actions defined
- prohibited actions defined
- state display defined
- evidence link defined if needed
- blocker status known
- test mapping exists if critical

Wireframe must not begin from visual imagination alone.

---

## 46. UI Build Gate Prohibition

UI candidate or wireframe candidate must not proceed to build unless:

- wireframe approved
- permission mapping approved
- data mapping approved
- masking reviewed
- runtime authority confirmed
- test mapping confirmed
- evidence mapping confirmed
- security/legal review done if needed
- build gate approves implementation

UI extraction is not build approval.

---

## 47. Registers Recommendation

Recommended future files:

    docs/_index/
      UI_Surface_Backlog_Register.md
      Wireframe_Candidate_Register.md
      UI_Role_Context_Mapping_Register.md
      UI_Field_Visibility_Mapping_Register.md
      UI_Action_Boundary_Register.md
      UI_State_Display_Register.md
      UI_Evidence_Display_Register.md
      UI_Search_Filter_Register.md
      UI_List_Detail_Form_Register.md
      AI_Support_UI_Register.md
      Admin_Console_UI_Backlog_Register.md
      Mini_Kiosk_UI_Backlog_Register.md
      KDS_UI_Backlog_Register.md
      Support_UI_Backlog_Register.md

This document only recommends these files.

It does not create them.

---

## 48. Anti-Patterns

The following are prohibited:

- wireframing without source policy
- designing UI before role/context is known
- creating button without authority
- exposing raw CI/DI in UI
- showing hidden record count through filters
- treating Admin Console as override center
- allowing UI to mutate payment truth
- allowing UI to release KDS without authority
- showing AI answer without source or confidence
- exposing provider raw payload in UI
- allowing customer UI to show internal blame
- treating commercial UI as sales promise without readiness
- moving UI candidate to build gate without masking review

---

## 49. Non-Goals

This document does not define:

- final Figma design
- final UX writing
- final design system
- final Flutter screen
- final web route
- final Admin Console implementation
- final Mini Kiosk implementation
- final KDS screen implementation
- final customer web implementation
- final UI test automation

Those belong to later UI/UX and build gate phases.

---

## 50. Readiness Check

This document is ready when the project can answer:

1. What is UI surface backlog?
2. What is wireframe candidate?
3. What UI surface categories exist?
4. What UI backlog status values exist?
5. What fields should UI surface register include?
6. What fields should wireframe candidate register include?
7. What source traceability rule applies?
8. What role mapping rule applies?
9. What role scope rule applies?
10. What context mapping rule applies?
11. What context reset rule applies?
12. What record visibility rule applies?
13. What hidden record rule applies?
14. What field visibility mapping rule applies?
15. What field masking mapping rule applies?
16. What field editability mapping rule applies?
17. What action mapping rule applies?
18. What button extraction rule applies?
19. What prohibited button rule applies?
20. What state display mapping rule applies?
21. What empty state mapping rule applies?
22. What error state mapping rule applies?
23. What warning state mapping rule applies?
24. What evidence display mapping rule applies?
25. What audit display mapping rule applies?
26. What search/filter extraction rule applies?
27. What list table extraction rule applies?
28. What detail page extraction rule applies?
29. What form workflow extraction rule applies?
30. What task queue extraction rule applies?
31. What AI support UI extraction rule applies?
32. What customer UI extraction rule applies?
33. What Mini Kiosk UI extraction rule applies?
34. What KDS UI extraction rule applies?
35. What Admin Console UI extraction rule applies?
36. What Support Console UI extraction rule applies?
37. What Security Review UI extraction rule applies?
38. What Pilot Dashboard UI extraction rule applies?
39. What Commercial UI extraction rule applies?
40. What wireframe entry gate applies?
41. What UI build gate prohibition applies?
42. What registers are recommended?
43. What anti-patterns are prohibited?

If these questions cannot be answered, UI surface backlog extraction and wireframe candidate register planning is incomplete.

---

## 51. Conclusion

UI extraction is the point where policy becomes visible workflow.

The safe UI extraction flow is:

    source policy
        -> UI backlog candidate
        -> surface category
        -> role and context
        -> visible, hidden, masked, and editable fields
        -> allowed and prohibited actions
        -> states, warnings, errors, evidence, and audit display
        -> wireframe candidate
        -> build gate only after authority and masking review

This document ensures that future UI/UX work reflects runtime truth, security boundaries, support scope, evidence requirements, AI support constraints, and high-risk operation safeguards rather than creating unsafe shortcuts through attractive screens.