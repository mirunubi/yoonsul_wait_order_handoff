# 14101_Policy_SaaS_Admin_Surface_Map_Navigation

## 1. Purpose

This document defines the SaaS Admin Console surface map, navigation structure, information architecture, screen grouping, menu hierarchy, role-based navigation visibility, context-aware navigation, and no-implementation boundary for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined SaaS Admin role permission matrix, view/action/export/override boundaries, and separation of duties.

This document defines how Admin Console screens should be grouped before wireframe, backlog extraction, or implementation begins.

This document does not implement routes, frontend components, backend APIs, database views, permission guards, or navigation UI.

It defines information architecture and screen grouping policy only.

---

## 2. Scope

This document covers:

- Admin Console surface map
- navigation principles
- screen grouping
- menu hierarchy
- role-based navigation visibility
- context-aware navigation
- tenant/store navigation
- operational dashboard navigation
- support navigation
- provider navigation
- billing/commercial navigation
- security/audit navigation
- pilot/expansion navigation
- no-implementation boundary

This document does not cover:

- final UI design
- final wireframe
- final route names
- final component structure
- final frontend implementation
- final backend API
- final database schema
- final permission engine
- final analytics implementation

---

## 3. Core Principle

Navigation must reflect authority, context, and operational risk.

The project must follow this rule:

> Admin Console navigation must show only the surfaces appropriate to the user’s role, tenant/store context, permission scope, and operational purpose, while preventing users from confusing visibility with authority.

A menu item is not permission.

A dashboard link is not action authority.

A route is not runtime ownership.

---

## 4. Admin Surface Map Meaning

Admin Surface Map means the planned grouping of Admin Console screens by operational domain.

It defines:

- what surfaces exist
- why each surface exists
- which users may see the surface
- which context is required
- which sensitive data may appear
- which actions are allowed
- which actions are prohibited
- which surfaces link to each other
- which surfaces are deferred

Surface map is a planning artifact before wireframes.

---

## 5. Information Architecture Principles

Admin Console information architecture should follow:

- context first
- role first
- least privilege
- operational priority
- sensitive data minimization
- dashboard-to-workflow separation
- evidence visibility
- no hidden authority
- clear live/test distinction
- shallow enough for daily use
- deep enough for risk control

Information architecture should reduce mistakes, not only organize pages.

---

## 6. Top-Level Navigation Families

Recommended top-level navigation families:

- `Home`
- `Tenants`
- `Stores`
- `Operations`
- `Payments`
- `KDS`
- `Providers`
- `Support`
- `Incidents`
- `Pilot`
- `Expansion`
- `Billing`
- `Commercial`
- `Security`
- `Audit`
- `Settings`

Not every role should see every family.

---

## 7. Role-Based Navigation Rule

Navigation must be filtered by:

- role family
- tenant/store scope
- context type
- permission matrix
- surface readiness
- sensitive field access
- action authority
- export authority
- temporary permission status
- device trust status

Hidden navigation is not enough for security.

Backend and policy enforcement are still required later.

---

## 8. Context-Aware Navigation Rule

Navigation must adapt to current context.

Examples:

- no store selected: show tenant/store directory and global allowed summaries
- tenant selected: show tenant overview and store directory
- store selected: show store operations, payment, KDS, provider, support, billing if authorized
- support case selected: show case-scoped views only
- provider stack selected: show provider-scoped views
- billing context selected: show commercial/billing views only
- security review context selected: show security review surfaces

Context should determine what is useful and safe.

---

## 9. Navigation Depth Rule

Recommended depth:

- Level 1: domain family
- Level 2: surface group
- Level 3: record detail
- Level 4: evidence or review detail only when necessary

Avoid deeply nested admin paths that hide critical issues.

Avoid flat navigation that exposes too many unrelated surfaces.

---

## 10. Home Surface

Home surface may include:

- current context
- assigned stores
- assigned support cases
- critical alerts
- pending reviews
- recent incidents
- blocked expansions
- renewal risks
- billing disputes
- permission-limited quick links

Home must not show cross-tenant sensitive data outside role scope.

Home is a work queue, not vanity dashboard.

---

## 11. Tenant Surface Group

Tenant surface group may include:

- tenant directory
- tenant overview
- tenant store list
- tenant role summary
- tenant billing summary
- tenant support summary
- tenant renewal summary
- tenant expansion summary
- tenant evidence index

Tenant surfaces require tenant context and role scope.

---

## 12. Store Surface Group

Store surface group may include:

- store directory
- store overview
- store health
- enabled modules
- provider stack summary
- payment safety summary
- KDS safety summary
- support cases
- billing lines
- renewal status
- expansion readiness
- evidence packets

Store surfaces require store context or authorized store group context.

---

## 13. Operations Surface Group

Operations surface group may include:

- multi-store operations dashboard
- store health dashboard
- support load dashboard
- operational blockers
- module status
- manual fallback status
- dry-run/pilot readiness
- daily/weekly review
- operational notes

Operations surfaces must not mutate payment/KDS truth directly.

---

## 14. Payment Surface Group

Payment surface group may include:

- payment safety dashboard
- payment uncertainty queue
- provider payment event review
- duplicate payment suspicion
- refund/cancel review summary
- payment evidence packets
- reconciliation required items
- customer recovery linkage

Payment surfaces require payment review permission.

Payment truth must remain conservative.

---

## 15. KDS Surface Group

KDS surface group may include:

- KDS safety dashboard
- KDS ticket review
- KDS duplicate suspicion
- KDS held/degraded ticket view
- kitchen fallback evidence
- KDS bridge status
- KDS incident linkage
- KDS evidence packets

KDS surfaces must protect kitchen execution truth.

---

## 16. Provider Surface Group

Provider surface group may include:

- provider stack directory
- provider stack detail
- provider incident dashboard
- provider mapping evidence
- webhook/callback review
- local daemon status
- cloud API status
- provider limitation records
- provider cost risk
- affected store list

Provider surfaces must not expose provider secrets by default.

---

## 17. Support Surface Group

Support surface group may include:

- support queue
- assigned cases
- case detail
- support escalation
- customer recovery review
- support evidence
- support capacity
- support trend review
- support-to-backlog items
- support-to-SOP items

Support surfaces should be case-scoped where possible.

---

## 18. Incident Surface Group

Incident surface group may include:

- incident register
- critical incident dashboard
- provider incidents
- payment incidents
- KDS incidents
- security incidents
- customer trust incidents
- incident containment
- postmortem records
- blocker conversion

Incident surfaces require evidence and closure control.

---

## 19. Pilot Surface Group

Pilot surface group may include:

- pilot store register
- pilot scope
- pilot run records
- daily pilot review
- weekly pilot consolidation
- pilot incidents
- pilot blockers
- pilot evidence packets
- pilot-to-paid readiness

Pilot surfaces must clearly distinguish pilot evidence from production proof.

---

## 20. Expansion Surface Group

Expansion surface group may include:

- expansion candidate list
- target store profile
- provider stack comparison
- support capacity review
- onboarding readiness
- staff training readiness
- payment/KDS readiness
- expansion blocker register
- expansion decision record

Expansion surfaces must not become sales-only pipeline.

---

## 21. Billing Surface Group

Billing surface group may include:

- billing dashboard
- billing record list
- billing line items
- provider pass-through items
- support fee allocation
- hardware/setup fee
- discounts and credits
- billing adjustments
- invoice dispute link
- revenue evidence packet

Billing surfaces must not directly enable runtime modules.

---

## 22. Commercial Surface Group

Commercial surface group may include:

- renewal forecast
- revenue risk register
- expansion pipeline
- commercial risk register
- package price register
- price exception register
- discount governance
- margin risk review
- commercial amendment records

Commercial surfaces must follow billing and operational evidence.

---

## 23. Security Surface Group

Security surface group may include:

- access review
- device trust dashboard
- support masking review
- export request review
- unmask request review
- security incident register
- provider secret exposure review
- suspicious access review
- permission conflict review

Security surfaces require strict role and audit control.

---

## 24. Audit Surface Group

Audit surface group may include:

- audit event index
- evidence packet index
- tamper evidence review
- append-only correction lineage
- review status
- closure evidence
- export audit trail
- support access audit
- permission audit

Audit surfaces must be masked and role-scoped.

---

## 25. Settings Surface Group

Settings surface group may include:

- admin users
- role assignments
- permission matrix
- tenant/store settings
- provider configuration summary
- module enablement configuration
- notification preferences
- environment markers
- policy version reference

Settings must not become an unsafe mutation center.

High-risk settings require workflow and audit.

---

## 26. Screen Group Status Values

Recommended screen group status values:

- `SCREEN_GROUP_NOT_DEFINED`
- `SCREEN_GROUP_DRAFT`
- `SCREEN_GROUP_REVIEW_REQUIRED`
- `SCREEN_GROUP_ROLE_MAPPING_REQUIRED`
- `SCREEN_GROUP_SECURITY_REVIEW_REQUIRED`
- `SCREEN_GROUP_READY_FOR_WIREFRAME`
- `SCREEN_GROUP_READY_FOR_BACKLOG`
- `SCREEN_GROUP_DEFERRED`
- `SCREEN_GROUP_REJECTED`

Screen group should not proceed to wireframe without role and boundary review.

---

## 27. Surface Record Fields

Each surface record should include:

- surface id
- surface family
- surface name
- purpose
- required context
- allowed roles
- data shown
- sensitive fields
- masking rule
- allowed actions
- prohibited actions
- export rule
- linked surfaces
- evidence requirement
- audit requirement
- status
- owner
- notes

Surface record becomes future UI planning input.

---

## 28. Navigation Link Rule

Navigation links should be created only when:

- target surface exists
- role may access target surface
- context can be passed safely
- sensitive filters are cleared if needed
- stale record selection is cleared
- cross-tenant access is impossible
- audit is triggered if sensitive
- user can return to previous context safely

Navigation must not leak data through URL or stale state.

---

## 29. Deep Link Rule

Deep links to admin records are risky.

Deep link must:

- re-check permission
- re-check context
- re-check device/session trust
- avoid exposing sensitive identifiers
- fail safely if unauthorized
- avoid revealing whether hidden record exists
- clear stale permissions
- audit sensitive record access if needed

A copied link must not bypass role scope.

---

## 30. Search Navigation Rule

Search should return only authorized results.

Search result should respect:

- tenant context
- store context
- support case scope
- role permission
- masking rule
- sensitive field restriction
- live/test distinction
- export restriction

Search must not become global data discovery for unauthorized users.

---

## 31. Cross-Surface Linkage Rule

Cross-surface links may connect:

- payment issue to support case
- KDS issue to incident
- provider incident to affected stores
- billing dispute to revenue evidence
- renewal risk to support burden
- expansion candidate to source store evidence
- security incident to device trust
- audit event to evidence packet

Cross-surface linkage must preserve context and permission.

---

## 32. Breadcrumb Rule

Breadcrumbs should show:

- current family
- current tenant
- current store or group
- current record type
- current record label if safe
- current mode

Breadcrumb must not expose unauthorized tenant/store names.

---

## 33. Live/Test Environment Marker Rule

Admin Console should clearly mark:

- live production
- pilot
- internal test
- demo
- provider test
- training

Environment marker should appear on all relevant surfaces.

Live surfaces require stricter action controls.

---

## 34. Empty State Rule

Empty state should be safe and useful.

Examples:

- no store selected
- no support cases assigned
- no billing disputes
- no provider incidents
- no renewal risks
- no expansion candidates

Empty state must not reveal unauthorized data.

---

## 35. Error State Rule

Error state should avoid sensitive disclosure.

Error should not reveal:

- whether unauthorized tenant exists
- whether hidden store exists
- whether hidden customer exists
- sensitive provider detail
- raw exception
- secret
- stack trace
- raw CI/DI
- payment secret

Error should provide safe next action.

---

## 36. Deferred Surface Rule

A deferred surface should be marked when:

- policy is not ready
- authority boundary is unclear
- sensitive data handling unresolved
- runtime owner unclear
- implementation phase later
- legal/finance review required
- provider dependency unresolved

Deferred means intentionally not built yet.

---

## 37. Surface Dependency Rule

Some surfaces depend on prior governance.

Examples:

- Billing surface depends on billing governance.
- Export surface depends on export security policy.
- Support surface depends on support access policy.
- Payment surface depends on payment runtime boundary.
- KDS surface depends on KDS runtime boundary.
- Provider surface depends on provider incident policy.
- Expansion surface depends on expansion readiness policy.
- Commercial surface depends on pricing governance.

Dependency must be listed before backlog extraction.

---

## 38. Admin Navigation Register Recommendation

Recommended future files:

    docs/_index/
      Admin_Surface_Map_Register.md
      Admin_Navigation_Family_Register.md
      Admin_Screen_Group_Register.md
      Admin_Surface_Dependency_Register.md
      Admin_Deep_Link_Risk_Register.md
      Admin_Search_Navigation_Register.md
      Admin_Cross_Surface_Link_Register.md
      Admin_Wireframe_Readiness_Register.md

This document only recommends these files.

It does not create them.

---

## 39. Anti-Patterns

The following are prohibited:

- designing menu from feature wish list only
- exposing all navigation to all admins
- using hidden menu as only security control
- allowing deep link to bypass context
- preserving stale store filter after tenant switch
- showing sensitive record in breadcrumb
- making search global by default
- putting runtime mutation inside dashboard card
- mixing live and test tenants visually
- building Billing screen before billing scope policy
- building Support screen before support masking policy
- building Provider screen before provider incident policy
- treating deferred surface as forgotten surface

---

## 40. Non-Goals

This document does not define:

- final UI design
- final wireframe
- final route paths
- final component tree
- final frontend framework
- final backend API
- final database view
- final permission implementation
- final search implementation

Those belong to later UI/UX and implementation planning.

---

## 41. Readiness Check

This document is ready when the project can answer:

1. What does Admin Surface Map mean?
2. What information architecture principles apply?
3. What top-level navigation families exist?
4. What role-based navigation rule applies?
5. What context-aware navigation rule applies?
6. What navigation depth rule applies?
7. What Home surface may include?
8. What Tenant surface group may include?
9. What Store surface group may include?
10. What Operations surface group may include?
11. What Payment surface group may include?
12. What KDS surface group may include?
13. What Provider surface group may include?
14. What Support surface group may include?
15. What Incident surface group may include?
16. What Pilot surface group may include?
17. What Expansion surface group may include?
18. What Billing surface group may include?
19. What Commercial surface group may include?
20. What Security surface group may include?
21. What Audit surface group may include?
22. What Settings surface group may include?
23. What screen group status values exist?
24. What fields should surface record include?
25. What navigation link rule applies?
26. What deep link rule applies?
27. What search navigation rule applies?
28. What cross-surface linkage rule applies?
29. What breadcrumb rule applies?
30. What live/test marker rule applies?
31. What empty state rule applies?
32. What error state rule applies?
33. What deferred surface rule applies?
34. What surface dependency rule applies?
35. What anti-patterns are prohibited?

If these questions cannot be answered, Admin Console surface map, navigation, and information architecture planning is incomplete.

---

## 42. Conclusion

Admin Console navigation is not only a UI decision.

It is a governance structure that determines how users discover tenants, stores, support cases, incidents, provider risks, billing records, renewal risks, expansion candidates, and evidence.

The safe navigation design flow is:

    role scope
        -> current context
        -> surface family
        -> screen group
        -> linked records
        -> action boundary
        -> masking and export boundary
        -> wireframe readiness

This document ensures that future Admin Console navigation remains context-aware, role-scoped, evidence-linked, and safe before wireframes or implementation backlog are created.