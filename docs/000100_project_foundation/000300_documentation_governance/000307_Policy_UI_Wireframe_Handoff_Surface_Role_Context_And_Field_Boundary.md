# 000307_Policy_UI_Wireframe_Handoff_Surface_Role_Context_And_Field_Boundary.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


## 1. Purpose

This document defines the UI wireframe handoff, surface definition, role boundary, context boundary, field visibility, field masking, allowed action, prohibited action, evidence link, audit requirement, and implementation deferral policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined test extraction, verification case mapping, evidence packet mapping, failure severity, blocker linkage, and build gate linkage.

This document defines how documentation policies, backlog candidates, test candidates, and evidence requirements should be handed off to future UI/UX wireframe planning without allowing UI design to invent authority, expose sensitive data, skip runtime boundaries, or bypass evidence requirements.

This document does not create UI designs, wireframes, Figma files, frontend routes, Flutter screens, React components, Admin Console pages, or implementation tasks.

It defines UI wireframe handoff policy only.

---

## 2. Scope

This document covers:

- UI wireframe handoff meaning
- UI surface meaning
- role boundary
- context boundary
- field visibility
- field masking
- field editability
- action boundary
- empty state
- error state
- evidence link
- audit requirement
- wireframe readiness
- no-implementation boundary

This document does not cover:

- final UX design
- visual design system
- final user journey map
- final frontend architecture
- final component library
- final screen implementation
- final mobile app implementation
- final Admin Console build
- final Kiosk UI build
- final customer web build

---

## 3. Core Principle

UI must express authority, not create authority.

The project must follow this rule:

> A UI wireframe may display information, guide workflow, request action, collect confirmation, or show evidence, but it must not create runtime authority, expose masked fields, bypass approval, ignore context, or turn a prohibited action into a convenient button.

Good UI reduces confusion.

Bad UI silently breaks governance.

---

## 4. UI Wireframe Handoff Meaning

UI wireframe handoff means converting policy, backlog, test, evidence, role, and context requirements into structured instructions for future screen planning.

A UI handoff should define:

- who uses the surface
- what context they are in
- what records are visible
- what fields are visible
- what fields are masked
- what actions are allowed
- what actions are prohibited
- what workflow is required
- what evidence appears
- what audit is required
- what states must be shown
- what blockers remain

Wireframe handoff is not visual design.

---

## 5. UI Surface Meaning

A UI surface is a screen, page, panel, dashboard, modal, drawer, form, list, detail page, task queue, kiosk flow, customer page, staff page, or Admin Console view where a user sees or acts on information.

UI surfaces may include:

- Customer Web waiting page
- Customer Web order page
- Mini Kiosk order screen
- Mini Kiosk payment screen
- Staff App table/session screen
- Store Owner Dashboard
- Tenant HQ Console
- Admin Console dashboard
- Admin Console list page
- Admin Console detail page
- Support Console case page
- KDS screen
- Provider Operations screen
- Payment Review screen
- Billing Review screen
- Security Review screen
- Pilot Dashboard
- Training screen

Each surface must have a clear purpose.

---

## 6. UI Surface Categories

Recommended UI surface categories:

- `CUSTOMER_SURFACE`
- `MINI_KIOSK_SURFACE`
- `STAFF_SURFACE`
- `STORE_MANAGER_SURFACE`
- `STORE_OWNER_SURFACE`
- `TENANT_HQ_SURFACE`
- `ADMIN_CONSOLE_SURFACE`
- `SUPPORT_SURFACE`
- `KDS_SURFACE`
- `PAYMENT_REVIEW_SURFACE`
- `PROVIDER_OPERATIONS_SURFACE`
- `BILLING_SURFACE`
- `SECURITY_REVIEW_SURFACE`
- `PILOT_SURFACE`
- `TRAINING_SURFACE`

Surface category should guide role and masking.

---

## 7. UI Surface Status Values

Recommended UI surface status values:

- `SURFACE_NOT_STARTED`
- `SURFACE_POLICY_SOURCE_REQUIRED`
- `SURFACE_ROLE_REVIEW_REQUIRED`
- `SURFACE_CONTEXT_REVIEW_REQUIRED`
- `SURFACE_FIELD_REVIEW_REQUIRED`
- `SURFACE_MASKING_REVIEW_REQUIRED`
- `SURFACE_ACTION_REVIEW_REQUIRED`
- `SURFACE_EVIDENCE_REVIEW_REQUIRED`
- `SURFACE_TEST_MAPPING_REQUIRED`
- `SURFACE_READY_FOR_WIREFRAME`
- `SURFACE_READY_FOR_DESIGN`
- `SURFACE_DEFERRED`
- `SURFACE_BLOCKED`

Surface status must not imply implementation.

---

## 8. Source Traceability Rule

Each UI surface handoff must include:

- source document number
- source section
- linked backlog item
- linked test item if any
- linked evidence packet if any
- linked blocker if any
- linked open gap if any
- extracted policy statement
- surface purpose
- status

UI without source is risky.

---

## 9. Surface ID Format

Recommended format:

    SURFACE-[CATEGORY]-[YYYYMMDD]-[NUMBER]

Examples:

    SURFACE-ADMIN_CONSOLE_SURFACE-20260612-001
    SURFACE-MINI_KIOSK_SURFACE-20260612-001
    SURFACE-KDS_SURFACE-20260612-001

Final format may be normalized later.

---

## 10. UI Handoff Record Fields

Each UI handoff record should include:

- surface id
- surface title
- category
- source reference
- linked backlog id
- linked test id
- linked evidence packet id
- linked blocker id
- primary user role
- secondary user roles
- context scope
- visible records
- hidden records
- visible fields
- masked fields
- editable fields
- read-only fields
- allowed actions
- prohibited actions
- required workflow
- empty state
- error state
- stale state
- audit requirement
- status
- notes

UI handoff must be precise enough for wireframe.

---

## 11. Role Boundary Rule

Every UI surface must identify who may use it.

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
- system admin

Role must define visibility and action authority.

---

## 12. Role Status Values

Recommended role status values for UI handoff:

- `ROLE_CONFIRMED`
- `ROLE_REVIEW_REQUIRED`
- `ROLE_LIMITED`
- `ROLE_READ_ONLY`
- `ROLE_ACTION_ALLOWED`
- `ROLE_APPROVAL_REQUIRED`
- `ROLE_NOT_ALLOWED`
- `ROLE_DEFERRED`

Role status must be explicit.

---

## 13. Context Boundary Rule

Every UI surface must identify context.

Possible contexts:

- public customer context
- customer session context
- waiting context
- table session context
- store context
- tenant context
- support case context
- payment review context
- KDS review context
- provider incident context
- billing period context
- pilot context
- security review context
- high-risk operation context
- cross-store context
- cross-tenant context

Context must be visible to users where operationally relevant.

---

## 14. Context Switch Rule

When context changes:

- selected rows should clear
- bulk actions should reset
- filters should re-check permission
- cached detail should reload
- masked fields should remain masked
- task assignment should re-check ownership
- export state should reset
- warning should appear if context affects authority

Context switch must not leak prior data.

---

## 15. Field Visibility Rule

Every field should be classified.

Recommended field visibility categories:

- `FIELD_VISIBLE`
- `FIELD_MASKED`
- `FIELD_HIDDEN`
- `FIELD_VISIBLE_READ_ONLY`
- `FIELD_VISIBLE_EDITABLE`
- `FIELD_VISIBLE_APPROVAL_ONLY`
- `FIELD_VISIBLE_SUPPORT_ONLY`
- `FIELD_VISIBLE_SECURITY_ONLY`
- `FIELD_VISIBLE_LEGAL_ONLY`
- `FIELD_NOT_AVAILABLE`

Field visibility must be role and context dependent.

---

## 16. Field Masking Rule

Sensitive fields must be masked by default.

Sensitive fields may include:

- CI/DI
- identity verification result detail
- customer private data
- staff private data
- payment detail
- provider raw payload
- provider secret
- support break-glass detail
- legal review detail
- security incident detail
- high-risk operation evidence

Masked field should not be revealed by tooltip, export, search, filter, or notification.

---

## 17. Field Editability Rule

Visible field is not necessarily editable.

Fields may be:

- read-only
- editable draft
- editable with approval
- editable by correction request
- editable only before submission
- editable only by owner
- editable only by security/legal role
- never editable from UI

Editability must be separate from visibility.

---

## 18. Action Boundary Rule

Every UI action must be classified.

Recommended action categories:

- `VIEW`
- `FILTER`
- `SEARCH`
- `SORT`
- `REQUEST`
- `ASSIGN`
- `COMMENT`
- `UPLOAD_EVIDENCE`
- `REQUEST_APPROVAL`
- `APPROVE`
- `REJECT`
- `ESCALATE`
- `HOLD`
- `RELEASE`
- `CANCEL`
- `REFUND`
- `EXPORT`
- `UNMASK`
- `OVERRIDE`
- `CLOSE`

Each action must be tied to authority.

---

## 19. Allowed Action Rule

Allowed actions must be explicitly listed.

Example allowed actions:

- view masked record
- request review
- create support case
- upload evidence
- assign task
- escalate blocker
- request refund approval
- request unmask
- create incident
- mark task in progress
- add internal note
- view KDS hold status

Allowed action must be safe for the role and context.

---

## 20. Prohibited Action Rule

Prohibited actions must be explicitly listed.

Example prohibited actions:

- direct payment mutation from Admin Console
- direct KDS release without authority
- raw CI/DI display
- export without approval
- cross-tenant search
- bulk approval of high-risk action
- support access outside case
- unmask without approval
- provider event trust without validation
- high-risk alcohol activation by default

Prohibited action must inform wireframe button design.

---

## 21. Button Boundary Rule

A button is a governance object.

A button must not appear unless:

- user has role
- context is valid
- action is allowed
- prerequisites are met
- required evidence exists or will be requested
- audit requirement is known
- blocker does not prohibit action
- confirmation is defined if high-risk

Button availability must reflect authority.

---

## 22. Disabled Button Rule

Disabled button may be used to show unavailable action, but must be careful.

Disabled button should explain:

- missing permission
- missing evidence
- blocked status
- legal review required
- security review required
- provider evidence missing
- context mismatch
- action deferred

Disabled button must not leak hidden data.

---

## 23. Confirmation Rule

High-risk UI actions may require confirmation.

Confirmation may be needed for:

- refund request
- KDS release
- service refusal
- export
- unmask
- role change
- high-risk mode activation
- blocker waiver
- incident closure
- store closure/reopen
- delivery pause/resume

Confirmation text must be safe and specific.

---

## 24. Empty State Rule

Empty state should explain absence without leaking hidden records.

Examples:

- No records available in this context
- No tasks assigned to this role
- No evidence packet required yet
- No provider incident visible to your role
- No pilot blockers in selected store

Empty state must not imply hidden record count.

---

## 25. Error State Rule

Error state should be safe.

Error state should not expose:

- raw SQL
- stack trace
- provider secret
- raw webhook payload
- CI/DI
- payment secret
- internal permission rule
- hidden tenant/store data

Error should guide recovery without leaking internals.

---

## 26. Stale State Rule

UI should show stale or uncertain state when data freshness is unclear.

Stale state may apply to:

- provider status
- payment callback
- KDS ticket
- local agent sync
- Admin dashboard KPI
- support case update
- delivery platform status
- high-risk verification
- pilot dashboard

Stale data must not be presented as final truth.

---

## 27. Loading State Rule

Loading state must not show old sensitive data as if current.

When loading:

- preserve context label if safe
- avoid showing stale confidential data
- clear previous selection if context changed
- show loading status
- avoid misleading action buttons

Loading is part of trust.

---

## 28. Warning State Rule

Warning should be used when action may be risky.

Warnings may include:

- payment uncertainty
- KDS uncertainty
- provider event mismatch
- identity verification uncertainty
- high-risk operation disabled
- export requires approval
- support session expires soon
- context changed
- evidence incomplete
- blocker active

Warnings must be actionable and not alarmist.

---

## 29. Evidence Link Rule

UI should link to evidence packet when:

- payment decision is reviewed
- refund is requested
- KDS hold/release is reviewed
- provider event is validated
- support case is handled
- incident is closed
- blocker is resolved
- high-risk operation is reviewed
- pilot readiness is checked
- commercial decision is made

UI should link, not duplicate sensitive evidence.

---

## 30. Audit Display Rule

UI may show audit timeline where useful.

Audit display should distinguish:

- system event
- user action
- approval
- rejection
- comment
- evidence link
- status change
- escalation
- redaction
- export
- unmask

Audit display must not expose restricted details broadly.

---

## 31. Search UI Rule

Search UI must respect permission.

Search must not:

- reveal hidden record by autocomplete
- reveal cross-tenant result count
- search raw CI/DI
- search payment secrets
- search provider raw payload
- expose hidden filters
- search restricted legal/security notes

Search UI must be designed with masking.

---

## 32. Filter UI Rule

Filter UI must not leak hidden values.

Filter options should be scoped by:

- role
- context
- tenant/store
- visibility
- permission
- surface purpose

Filter count must be safe.

---

## 33. List UI Rule

List UI should define:

- default columns
- optional columns
- hidden columns
- masked columns
- row actions
- selection rule
- bulk action rule
- pagination rule
- stale indicator
- export boundary

List UI is a major data leakage surface.

---

## 34. Detail UI Rule

Detail UI should define:

- header
- status
- context
- field groups
- linked records
- evidence links
- task links
- audit timeline
- comments
- allowed actions
- prohibited actions
- masking
- edit mode

Detail UI must not become uncontrolled edit form.

---

## 35. Form UI Rule

Form UI should define:

- purpose
- draft state
- required fields
- validation placeholder
- evidence requirement
- approval requirement
- submit boundary
- cancel boundary
- correction path
- audit requirement

Form submission does not always mean effective change.

---

## 36. Task Queue UI Rule

Task queue UI should define:

- queue type
- task status
- assignee
- priority
- due date
- blocker
- evidence status
- allowed task actions
- prohibited task actions
- escalation path
- workload status

Task assignment does not grant permission.

---

## 37. Collaboration UI Rule

Collaboration UI should define:

- comment type
- note type
- visibility
- sensitivity
- mention rule
- edit rule
- redaction path
- evidence link
- notification preview
- export restriction

Comment is not approval.

---

## 38. Customer UI Boundary

Customer-facing UI should be:

- simple
- safe
- respectful
- non-accusatory
- low-friction
- clear on payment/order state
- clear on waiting/table/session state
- careful with alcohol/high-risk messages
- careful with errors
- free of internal terms

Customer UI should hide internal complexity.

---

## 39. Staff UI Boundary

Staff UI should support:

- quick recognition
- safe confirmation
- KDS/payment awareness
- manual fallback awareness
- high-risk warning
- customer recovery context
- escalation path
- minimal text burden
- no raw sensitive data

Staff UI must reduce mistake during peak operation.

---

## 40. Admin Console UI Boundary

Admin Console UI should support:

- dashboard
- list
- detail
- task queue
- approval queue
- evidence links
- masking
- export request
- unmask request
- audit timeline
- role/context switch

Admin Console must remain controlled operations surface.

---

## 41. Mini Kiosk UI Boundary

Mini Kiosk UI should support:

- customer session
- table/session context if applicable
- menu selection
- payment flow
- timeout handling
- confirmation
- error recovery
- staff call
- high-risk item restriction
- no raw identity exposure

Mini Kiosk must not bypass POS/payment/KDS authority.

---

## 42. KDS UI Boundary

KDS UI should support:

- ticket visibility
- hold status
- release status
- cancel/remake/retry status
- stale indicator
- provider mapping warning
- payment dependency if applicable
- high-risk alcohol hold
- no customer identity payload
- staff-safe display

KDS UI must serve kitchen execution, not customer identity display.

---

## 43. Support UI Boundary

Support UI should support:

- case-scoped access
- masked customer data
- safe notes
- evidence links
- escalation
- customer recovery
- payment/KDS/provider linkage
- support session expiry
- break-glass request if needed

Support UI must not become broad data browser.

---

## 44. UI Wireframe Entry Gate

Wireframe may begin when:

- source policy exists
- surface category defined
- user role defined
- context defined
- visible fields listed
- masked fields listed
- allowed actions listed
- prohibited actions listed
- evidence link known
- audit requirement known
- blockers recorded

Wireframe should not begin from blank imagination.

---

## 45. UI Build Gate Prohibition

UI handoff does not authorize UI build.

UI build requires:

- approved wireframe
- approved permission mapping
- approved data mapping
- approved masking
- approved test mapping
- approved evidence mapping
- approved security review if needed
- implementation build gate

UI idea is not implementation permission.

---

## 46. Registers Recommendation

Recommended future files:

    docs/_index/
      UI_Surface_Register.md
      UI_Wireframe_Handoff_Register.md
      UI_Role_Context_Register.md
      UI_Field_Visibility_Register.md
      UI_Field_Masking_Register.md
      UI_Action_Boundary_Register.md
      UI_Evidence_Link_Register.md
      UI_Error_Empty_State_Register.md
      UI_Surface_Blocker_Register.md
      UI_Build_Gate_Register.md

This document only recommends these files.

It does not create them.

---

## 47. Anti-Patterns

The following are prohibited:

- designing UI before role/context is known
- showing button because it feels useful
- exposing masked field in tooltip
- exposing hidden record through filter count
- making Admin Console a universal override panel
- allowing UI to mutate payment truth casually
- allowing UI to release KDS without authority
- using customer-facing accusatory labels
- showing raw CI/DI or provider payload
- treating disabled button as safe when it leaks reason
- wireframing high-risk alcohol action without legal/security constraints
- building UI from visual preference without source policy

---

## 48. Non-Goals

This document does not define:

- final Figma wireframe
- final UX copy
- final design system
- final Flutter screen
- final web route
- final Admin Console component
- final Mini Kiosk interface
- final KDS implementation
- final UI test automation

Those belong to later UI/UX and implementation planning.

---

## 49. Readiness Check

This document is ready when the project can answer:

1. What does UI wireframe handoff mean?
2. What is UI surface?
3. What UI surface categories exist?
4. What UI surface statuses exist?
5. What source traceability rule applies?
6. What surface ID format is recommended?
7. What fields should UI handoff record include?
8. What role boundary rule applies?
9. What role statuses exist?
10. What context boundary rule applies?
11. What context switch rule applies?
12. What field visibility rule applies?
13. What field masking rule applies?
14. What field editability rule applies?
15. What action boundary rule applies?
16. What allowed action rule applies?
17. What prohibited action rule applies?
18. What button boundary rule applies?
19. What disabled button rule applies?
20. What confirmation rule applies?
21. What empty state rule applies?
22. What error state rule applies?
23. What stale state rule applies?
24. What loading state rule applies?
25. What warning state rule applies?
26. What evidence link rule applies?
27. What audit display rule applies?
28. What search UI rule applies?
29. What filter UI rule applies?
30. What list UI rule applies?
31. What detail UI rule applies?
32. What form UI rule applies?
33. What task queue UI rule applies?
34. What collaboration UI rule applies?
35. What customer UI boundary applies?
36. What staff UI boundary applies?
37. What Admin Console UI boundary applies?
38. What Mini Kiosk UI boundary applies?
39. What KDS UI boundary applies?
40. What Support UI boundary applies?
41. What UI wireframe entry gate applies?
42. What UI build gate prohibition applies?
43. What registers are recommended?
44. What anti-patterns are prohibited?

If these questions cannot be answered, UI wireframe handoff, surface, role, context, and field boundary planning is incomplete.

---

## 50. Conclusion

UI/UX will become powerful only after the authority model is clear.

The safe UI handoff flow is:

    source policy
        -> backlog item
        -> surface definition
        -> role and context
        -> visible, masked, hidden, editable fields
        -> allowed and prohibited actions
        -> evidence and audit links
        -> wireframe entry gate
        -> build gate only after review

This document ensures that future UI wireframes express the system’s runtime, security, evidence, and authority model instead of accidentally creating shortcuts, data leaks, or unsafe operational buttons.
