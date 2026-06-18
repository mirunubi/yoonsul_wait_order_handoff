# 014107_Policy_SaaS_Admin_List_Table_Bulk_Action

## 1. Purpose

This document defines the SaaS Admin Console list table, filter, search, sort, pagination, row selection, bulk action, saved view, export request, and cross-context selection boundary policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined record detail pages, form fields, masking, edit mode, correction workflow, approval mode, and save boundaries.

This document defines how Admin Console list surfaces should behave before wireframe, backlog extraction, or implementation begins.

This document does not implement tables, search engines, filters, pagination, APIs, SQL queries, database indexes, permission guards, exports, or bulk actions.

It defines list table and selection boundary policy only.

---

## 2. Scope

This document covers:

- list table purpose
- row visibility
- column visibility
- filter boundary
- search boundary
- sort boundary
- pagination boundary
- row selection
- bulk action boundary
- saved views
- export request from list
- cross-context selection risk
- no-implementation boundary

This document does not cover:

- final table UI
- final search implementation
- final database query logic
- final index design
- final API pagination
- final bulk update implementation
- final export generation
- final report engine
- final analytics tool

---

## 3. Core Principle

A list view is a discovery surface, not unrestricted access.

The project must follow this rule:

> List tables, filters, search results, sort order, saved views, and bulk actions must respect tenant, store, role, context, masking, export, and action boundaries so that users cannot discover, select, export, or mutate records outside their authorized scope.

Search is not permission.

Filter is not permission.

Bulk selection is not authority.

---

## 4. List Table Meaning

A list table is an Admin Console surface that displays multiple records such as:

- tenants
- stores
- support cases
- incidents
- payment reviews
- KDS reviews
- provider incidents
- billing records
- billing disputes
- renewal forecasts
- expansion reviews
- evidence packets
- audit events
- devices
- roles
- permission records

List table should help users find and prioritize work.

It must not become a data leakage surface.

---

## 5. List Surface Types

Recommended list surface types:

- `TENANT_LIST`
- `STORE_LIST`
- `SUPPORT_CASE_LIST`
- `INCIDENT_LIST`
- `PAYMENT_REVIEW_LIST`
- `KDS_REVIEW_LIST`
- `PROVIDER_INCIDENT_LIST`
- `BILLING_RECORD_LIST`
- `BILLING_DISPUTE_LIST`
- `RENEWAL_FORECAST_LIST`
- `EXPANSION_REVIEW_LIST`
- `EVIDENCE_PACKET_LIST`
- `AUDIT_EVENT_LIST`
- `DEVICE_LIST`
- `ROLE_PERMISSION_LIST`
- `COMMERCIAL_RISK_LIST`

Each list type needs its own boundary.

---

## 6. List Surface Status Values

Recommended list surface status values:

- `LIST_NOT_DEFINED`
- `LIST_DRAFT`
- `LIST_REVIEW_REQUIRED`
- `LIST_COLUMN_MAPPING_REQUIRED`
- `LIST_FILTER_REVIEW_REQUIRED`
- `LIST_SECURITY_REVIEW_REQUIRED`
- `LIST_BULK_ACTION_REVIEW_REQUIRED`
- `LIST_READY_FOR_WIREFRAME`
- `LIST_READY_FOR_BACKLOG`
- `LIST_DEFERRED`
- `LIST_REJECTED`

List surface should not proceed to wireframe without search/filter and selection review.

---

## 7. Row Visibility Rule

Each row must be visible only when:

- user role allows record type
- tenant context allows record
- store context allows record
- support case scope allows record if applicable
- provider stack scope allows record if applicable
- billing/commercial scope allows record if applicable
- security review scope allows record if applicable
- device/session trust is sufficient
- record is not restricted beyond user scope

A hidden row must not be discoverable through search or pagination counts.

---

## 8. Column Visibility Rule

Columns must be controlled separately from row visibility.

Column categories may include:

- safe summary column
- masked sensitive column
- hidden sensitive column
- role-specific column
- internal-only column
- customer-facing column
- export-restricted column
- security-only column
- billing-only column
- support-only column

A user may see a row but not all columns.

---

## 9. Column Sensitivity Examples

Sensitive columns may include:

- raw CI/DI
- customer private identifiers
- payment identifiers
- provider secret indicators
- webhook identifiers
- device identifiers
- support-only notes
- security incident details
- billing dispute amount
- churn risk
- margin risk
- staff private data
- cross-store comparison data

Sensitive columns should be masked or hidden by default.

---

## 10. Default Column Rule

Default columns should be minimal.

Default list should show:

- safe record label
- status
- severity or priority if relevant
- tenant/store context if authorized
- owner
- last updated time
- next action
- evidence status if relevant

Default table must avoid sensitive data overload.

---

## 11. Column Customization Rule

Column customization may be allowed only within permission.

Rules:

- hidden sensitive columns cannot be added without permission
- masked columns remain masked
- export-restricted columns require export authority
- saved column views must not preserve revoked access
- shared column views must respect recipient permission

Column customization must not bypass role scope.

---

## 12. Filter Meaning

A filter narrows visible records by condition.

Filters may include:

- status
- severity
- owner
- tenant
- store
- provider
- module
- date range
- evidence status
- billing status
- support priority
- renewal risk
- expansion status
- security status

Filter may reduce authorized results.

Filter must not reveal unauthorized values.

---

## 13. Filter Boundary Rule

Filter options must be generated only from authorized scope.

Filter dropdowns must not expose:

- unauthorized tenant names
- unauthorized store names
- hidden provider mappings
- hidden security statuses
- hidden billing categories
- hidden support case labels
- restricted staff identifiers
- raw sensitive identifiers

Filter metadata can leak data.

---

## 14. Search Meaning

Search allows user to find records by keyword or identifier.

Search may apply to:

- safe record id
- safe display name
- store name if authorized
- support case title
- incident summary
- provider alias
- billing record id
- renewal forecast id
- expansion review id
- evidence packet id

Search must not query sensitive raw fields by default.

---

## 15. Search Boundary Rule

Search must respect:

- tenant context
- store context
- role permission
- support case scope
- masking rule
- security restriction
- live/test separation
- record type access
- export boundary

Search result must not reveal existence of unauthorized records.

---

## 16. Sensitive Search Prohibition

Search should not allow direct search by:

- raw CI/DI
- full payment identifier
- provider secret
- webhook secret
- token
- private staff identifier
- hidden customer identifier
- raw phone number unless explicitly governed
- security incident hidden detail
- cross-tenant internal identifier

Sensitive search requires separate security policy.

---

## 17. Sort Boundary Rule

Sort must not reveal hidden values.

Risks:

- sorting by hidden amount may reveal relative billing size
- sorting by hidden severity may reveal incident presence
- sorting by hidden churn risk may reveal customer risk
- sorting by hidden security status may reveal sensitive issue
- sorting by masked identifier may reveal pattern

Sort should be allowed only on visible or permitted fields.

---

## 18. Pagination Boundary Rule

Pagination must not reveal unauthorized record count.

Rules:

- total count should reflect authorized records only
- page count should reflect authorized records only
- empty page should not imply hidden records
- revoked records should disappear safely
- context switch should reset pagination
- saved pagination state must not cross context

Pagination metadata is also data.

---

## 19. Row Selection Rule

Row selection means selecting one or more list records for action.

Selection must be limited to:

- visible authorized rows
- current context
- current filter result
- current role permission
- action-compatible record types
- non-restricted records
- non-closed immutable records unless action allows review

Selection should clear when context changes.

---

## 20. Selection Status Values

Recommended row selection status values:

- `SELECTION_EMPTY`
- `SELECTION_SINGLE`
- `SELECTION_MULTI`
- `SELECTION_MIXED_CONTEXT_BLOCKED`
- `SELECTION_ACTION_NOT_ALLOWED`
- `SELECTION_REVIEW_REQUIRED`
- `SELECTION_STALE`
- `SELECTION_CLEARED`

Selection status should drive available actions.

---

## 21. Cross-Context Selection Rule

Bulk selection across context is high-risk.

Cross-context selection should be blocked or reviewed when records span:

- multiple tenants
- unrelated stores
- live and test environments
- different support case scopes
- different provider stacks
- different billing entities
- different security sensitivity levels
- different action owners

Bulk action should not accidentally cross boundaries.

---

## 22. Bulk Action Meaning

Bulk action means performing or requesting the same workflow for multiple selected records.

Bulk action may include:

- assign owner
- escalate
- request review
- create blocker
- mark admin reviewed
- request evidence
- acknowledge broadcast
- create billing clarification request
- create support follow-up
- create backlog items

Bulk action should usually create workflows, not final truth changes.

---

## 23. Bulk Action Prohibited Defaults

Bulk action must not directly:

- approve payments
- complete KDS tickets
- close critical incidents
- delete evidence
- unmask sensitive data
- export sensitive data
- change billing amounts
- approve discounts
- revoke many devices without review
- waive blockers
- approve expansion
- trust provider events

High-risk bulk actions require separate governance or must be prohibited.

---

## 24. Bulk Action Review Rule

Bulk action requires review when:

- selected records span multiple stores
- selected records include critical severity
- selected records include payment/KDS risk
- selected records include security risk
- selected records include billing dispute
- selected records include closed records
- selected records include different owners
- selected records include different evidence status
- action may notify customer or store

Review should show affected scope before confirmation.

---

## 25. Bulk Action Confirmation Rule

Bulk confirmation should show:

- number of selected records
- tenant/store scope
- action type
- affected record types
- excluded records
- reason code
- evidence requirement
- audit impact
- notification impact
- irreversible or sensitive consequence

Confirmation prevents accidental mass action.

---

## 26. Bulk Action Partial Success Rule

If bulk action partially succeeds later in implementation:

- successful records must be listed
- failed records must be listed
- skipped records must be listed
- reason must be shown
- retry must be controlled
- audit must preserve outcome
- user must not see generic success message

Partial success must be transparent.

---

## 27. Bulk Action Record Fields

Each bulk action should record:

- bulk action id
- user
- role
- context
- action type
- selected record count
- affected record ids or safe references
- skipped record count
- reason
- evidence
- approval if required
- status
- timestamp
- outcome summary
- notes

Bulk action must be auditable.

---

## 28. Bulk Action ID Format

Recommended format:

    BULK-ACTION-[YYYYMMDD]-[NUMBER]

Example:

    BULK-ACTION-20260612-001

Final format may be normalized later.

---

## 29. Bulk Action Status Values

Recommended status values:

- `BULK_ACTION_DRAFT`
- `BULK_ACTION_REVIEW_REQUIRED`
- `BULK_ACTION_APPROVAL_REQUIRED`
- `BULK_ACTION_APPROVED`
- `BULK_ACTION_REJECTED`
- `BULK_ACTION_EXECUTION_PENDING`
- `BULK_ACTION_PARTIAL_SUCCESS`
- `BULK_ACTION_SUCCESS`
- `BULK_ACTION_FAILED`
- `BULK_ACTION_CANCELLED`

Bulk action status must be visible.

---

## 30. Saved View Meaning

Saved view means a reusable set of:

- filters
- columns
- sort order
- grouping
- context assumption
- list type
- date range
- owner
- purpose

Saved view improves efficiency but creates permission risk.

---

## 31. Saved View Rule

Saved view must:

- store view definition, not unauthorized data
- re-check permission when opened
- refresh context
- remove unavailable columns
- remove unauthorized filters
- clear stale selections
- show if view is no longer valid
- distinguish private and shared saved views

Saved view must not preserve old access.

---

## 32. Shared Saved View Rule

Shared saved view may be allowed only when:

- recipient has permission
- view contains no hidden sensitive columns
- filters do not reveal unauthorized tenant/store names
- export is not embedded
- context is clear
- owner is recorded
- sharing scope is defined

Shared view is not shared data dump.

---

## 33. List Export Request Rule

Export from list requires separate export workflow.

Export request should include:

- list type
- filters
- columns
- date range
- tenant/store scope
- purpose
- recipient
- masking rule
- approval owner
- retention expectation
- audit

Viewing a list does not grant export.

---

## 34. List Export Prohibited Defaults

List export must not include by default:

- raw CI/DI
- payment secrets
- provider secrets
- webhook secrets
- tokens
- support-only notes
- security incident details
- staff private data
- hidden billing risk fields
- hidden churn/margin risk fields

Export should be stricter than screen view.

---

## 35. List Grouping Rule

List grouping may group by:

- status
- severity
- store
- provider
- owner
- date
- module
- support priority
- billing status
- renewal risk

Grouping must not reveal unauthorized categories or hidden values.

---

## 36. List Count Rule

Counts should be scoped.

Counts may show:

- authorized total
- filtered authorized total
- selected total
- critical authorized count
- overdue authorized count

Counts must not include hidden unauthorized records.

---

## 37. Row-Level Action Rule

Row-level actions may include:

- view detail
- request review
- assign
- escalate
- request evidence
- create support case
- create blocker
- open linked evidence

Row-level action must be filtered by row permission and record status.

---

## 38. Row-Level Prohibited Action Rule

Row-level actions must not directly:

- mutate payment truth
- mutate KDS truth
- trust provider event
- expose sensitive field
- export row data
- close critical record without evidence
- apply billing adjustment without workflow
- approve expansion without readiness review

Row-level buttons must not bypass workflow.

---

## 39. List Stale Data Rule

If list data is stale:

- show stale indicator
- show last updated if safe
- disable high-risk bulk action if needed
- allow refresh
- require re-check before action
- avoid green certainty

Stale list must not drive irreversible action.

---

## 40. List Empty State Rule

Empty state should distinguish:

- no records exist in authorized scope
- no records match filter
- no context selected
- no permission
- data not available
- surface deferred

Empty state must not reveal hidden records.

---

## 41. List Error State Rule

Error state must avoid:

- raw stack trace
- query text
- internal schema names if sensitive
- provider secrets
- payment secrets
- raw CI/DI
- unauthorized tenant/store identifiers
- hidden record counts

Error should provide safe recovery path.

---

## 42. List Definition Record Fields

Each list definition should include:

- list id
- list type
- surface family
- purpose
- required context
- allowed roles
- default columns
- optional columns
- hidden columns
- filters
- search fields
- sortable fields
- row actions
- bulk actions
- export rule
- masking rule
- pagination rule
- evidence requirement
- audit requirement
- status
- owner
- notes

List definition becomes future UI planning input.

---

## 43. List ID Format

Recommended format:

    ADMIN-LIST-[LIST-TYPE]

Examples:

    ADMIN-LIST-SUPPORTCASE
    ADMIN-LIST-PROVIDERINCIDENT
    ADMIN-LIST-BILLINGDISPUTE
    ADMIN-LIST-EXPANSIONREVIEW

Final format may be normalized later.

---

## 44. List Register Recommendation

Recommended future files:

    docs/_index/
      Admin_List_Surface_Register.md
      Admin_List_Column_Register.md
      Admin_Filter_Register.md
      Admin_Search_Field_Register.md
      Admin_Sort_Field_Register.md
      Admin_Row_Action_Register.md
      Admin_Bulk_Action_Register.md
      Admin_Saved_View_Register.md
      Admin_List_Export_Request_Register.md

This document only recommends these files.

It does not create them.

---

## 45. Anti-Patterns

The following are prohibited:

- treating list visibility as export permission
- exposing unauthorized tenant names in filter dropdown
- allowing global search across tenants by default
- sorting by hidden sensitive field
- showing unauthorized count in pagination
- carrying selected rows after context switch
- allowing bulk action across tenants casually
- bulk closing critical incidents
- bulk approving payments
- bulk completing KDS tickets
- saving view with revoked sensitive columns
- sharing saved view as data access
- exporting list without masking and approval
- showing raw error from list query

---

## 46. Non-Goals

This document does not define:

- final table component
- final filter UI
- final search engine
- final pagination API
- final database indexes
- final query optimization
- final bulk action implementation
- final export implementation
- final saved view storage

Those belong to later UI/UX, backend, data, and security implementation planning.

---

## 47. Readiness Check

This document is ready when the project can answer:

1. What does list table mean?
2. What list surface types exist?
3. What list surface status values exist?
4. What row visibility rule applies?
5. What column visibility rule applies?
6. What sensitive column examples exist?
7. What default column rule applies?
8. What column customization rule applies?
9. What does filter mean?
10. What filter boundary applies?
11. What does search mean?
12. What search boundary applies?
13. What sensitive search prohibition applies?
14. What sort boundary applies?
15. What pagination boundary applies?
16. What row selection rule applies?
17. What selection status values exist?
18. What cross-context selection rule applies?
19. What does bulk action mean?
20. What bulk actions are prohibited by default?
21. What bulk action review rule applies?
22. What bulk confirmation rule applies?
23. What partial success rule applies?
24. What fields should bulk action record include?
25. What bulk action status values exist?
26. What does saved view mean?
27. What saved view rule applies?
28. What shared saved view rule applies?
29. What list export request rule applies?
30. What list export prohibited defaults apply?
31. What grouping rule applies?
32. What count rule applies?
33. What row-level action rule applies?
34. What row-level prohibited action rule applies?
35. What stale data rule applies?
36. What empty state rule applies?
37. What error state rule applies?
38. What fields should list definition include?
39. What anti-patterns are prohibited?

If these questions cannot be answered, SaaS Admin list table, filter, search, sort, bulk action, and selection boundary planning is incomplete.

---

## 48. Conclusion

Admin list surfaces are powerful because they combine discovery, prioritization, selection, and workflow initiation.

The safe list design flow is:

    context
        -> authorized rows
        -> permitted columns
        -> safe filters
        -> scoped search
        -> safe sort and pagination
        -> row selection
        -> workflow-safe actions
        -> export request if needed
        -> audit and evidence

This document ensures that future Admin Console lists do not leak data through filters, search, counts, columns, saved views, stale selection, export, or bulk action shortcuts.