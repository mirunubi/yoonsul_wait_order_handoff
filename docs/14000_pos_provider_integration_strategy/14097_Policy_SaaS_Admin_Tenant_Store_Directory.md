# 14097_Policy_SaaS_Admin_Tenant_Store_Directory

## 1. Purpose

This document defines the SaaS Admin Console tenant directory, store directory, role scope, context switching, tenant/store selection, cross-store visibility, multi-store owner view, HQ admin view, support case scoped access, and context safety policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document started the SaaS Admin Console lane and defined role surfaces, runtime view boundaries, and action boundaries.

This document defines how Admin Console users may select and view tenant/store contexts safely before accessing dashboards, support cases, provider views, billing views, renewal views, or expansion views.

This document does not implement user interface, routing, database schema, RLS, API authorization, session logic, or admin components.

It defines tenant/store directory and context switching policy only.

---

## 2. Scope

This document covers:

- tenant directory
- store directory
- role scope
- context selection
- context switching
- multi-store view
- HQ view
- store owner view
- store manager view
- support case scoped context
- cross-store visibility boundary
- context safety warning
- no-implementation boundary

This document does not cover:

- final UI wireframe
- final route structure
- final database table
- final RLS implementation
- final API authorization
- final identity provider integration
- final user management implementation
- final audit event implementation
- final support session implementation

---

## 3. Core Principle

Every admin view must be anchored to a clear tenant and store context.

The project must follow this rule:

> Admin Console must never allow a user to view, compare, export, or act on tenant/store data unless the current tenant/store context, role scope, support scope, and action boundary are explicit and visible.

Context ambiguity creates data leakage.

Context switching without safety creates operational mistakes.

---

## 4. Tenant Directory Meaning

Tenant Directory means the admin surface that lists or allows access to customer organizations under authorized scope.

A tenant may represent:

- direct customer
- multi-store operator
- franchise headquarters
- franchisee group
- pilot customer
- early SaaS customer
- internal test tenant
- provider test tenant
- demo tenant if allowed

Tenant Directory is not a public customer list.

It is a controlled admin surface.

---

## 5. Store Directory Meaning

Store Directory means the admin surface that lists stores under an authorized tenant, customer, owner, or support scope.

Store Directory may show:

- store name
- store status
- package
- enabled modules
- provider stack summary
- store health
- support load
- payment safety
- KDS safety
- billing status
- renewal status
- expansion status
- last review date

Store Directory is the gateway to store-level operations.

---

## 6. Context Types

Recommended context types:

- `SYSTEM_CONTEXT`
- `TENANT_CONTEXT`
- `STORE_CONTEXT`
- `STORE_GROUP_CONTEXT`
- `SUPPORT_CASE_CONTEXT`
- `PROVIDER_STACK_CONTEXT`
- `BILLING_CONTEXT`
- `PILOT_CONTEXT`
- `EXPANSION_CONTEXT`
- `SECURITY_REVIEW_CONTEXT`

Context type must determine visible data and allowed actions.

---

## 7. Context Status Values

Recommended context status values:

- `CONTEXT_NOT_SELECTED`
- `CONTEXT_SELECTED`
- `CONTEXT_REVIEW_REQUIRED`
- `CONTEXT_RESTRICTED`
- `CONTEXT_SUPPORT_SCOPED`
- `CONTEXT_READ_ONLY`
- `CONTEXT_ACTION_LIMITED`
- `CONTEXT_EXPIRED`
- `CONTEXT_REVOKED`
- `CONTEXT_INVALID`

Admin Console must not operate in ambiguous context.

---

## 8. Role Scope Meaning

Role scope means the set of tenant, store, data, and action boundaries assigned to a user.

Role scope may include:

- tenant-level access
- store-level access
- store group access
- support case scoped access
- provider stack scoped access
- billing scoped access
- security review scoped access
- read-only access
- action request access
- approval access
- export access

Role scope must be explicit.

---

## 9. Role Scope Categories

Recommended role scope categories:

- `SYSTEM_ADMIN_SCOPE`
- `TENANT_HQ_SCOPE`
- `STORE_OWNER_SCOPE`
- `STORE_MANAGER_SCOPE`
- `SUPPORT_CASE_SCOPE`
- `PROVIDER_REVIEW_SCOPE`
- `PAYMENT_REVIEW_SCOPE`
- `KDS_REVIEW_SCOPE`
- `BILLING_REVIEW_SCOPE`
- `CUSTOMER_SUCCESS_SCOPE`
- `SECURITY_REVIEW_SCOPE`
- `AUDIT_REVIEW_SCOPE`
- `READ_ONLY_SCOPE`

Scope category should be mapped to surfaces.

---

## 10. Tenant Directory Visibility Rule

Tenant Directory visibility must follow least privilege.

Rules:

- system-level admin may see tenants only under authorized system role
- operations admin may see operational tenants assigned to them
- support admin may see tenant only through assigned support case or support role
- provider admin may see tenant/provider linkage only as needed
- billing admin may see commercial tenant data only as authorized
- tenant HQ admin may see only their own tenant
- store owner may not browse unrelated tenants
- store manager may not browse tenant directory unless explicitly needed

Tenant Directory must not become cross-customer exposure.

---

## 11. Store Directory Visibility Rule

Store Directory visibility must follow tenant and store scope.

Rules:

- tenant HQ admin may see stores under that tenant according to role
- multi-store owner may see owned/authorized stores
- store owner may see their store or store group
- store manager may see assigned store only
- support admin may see store only when assigned case or role allows
- provider admin may see store provider context only when needed
- billing admin may see store billing context according to commercial role
- security admin may see store security context under audited role

Store list is sensitive operational data.

---

## 12. Context Selection Rule

Before entering any store-level admin surface, user should select or inherit:

- tenant context
- store context
- role scope
- surface purpose
- allowed actions
- masking rule
- export boundary

If context is missing, admin surface should remain unavailable or read-only.

---

## 13. Context Switch Rule

Context switch means changing from one tenant/store/store group/support case to another.

Context switch must:

- display current context clearly
- confirm target context when risk exists
- clear stale filters
- clear stale selected records
- clear previous support case scope
- refresh permissions
- refresh masking rules
- refresh allowed actions
- create audit event for sensitive switch if required

Context switch must not carry authority from previous context.

---

## 14. Context Switch Risk Examples

Risk exists when switching:

- between tenants
- between unrelated stores
- from support case to general store view
- from billing view to payment view
- from provider incident to store operations
- from test tenant to live tenant
- from pilot store to paid store
- from read-only to action-capable surface
- from masked view to unmask request

High-risk switch should require confirmation or revalidation.

---

## 15. Current Context Display Rule

Admin Console should visibly show:

- tenant name or safe identifier
- store name or safe identifier
- store group if applicable
- role scope
- current surface
- read-only/action-limited status
- support case scope if active
- masking status
- export restriction status

User must always know where they are acting.

---

## 16. Context Banner Recommendation

A future context banner may include:

- current tenant
- current store
- current role
- current scope
- active support case
- action mode
- masking mode
- environment marker
- warning if live production

This document only recommends the concept.

It does not implement a banner.

---

## 17. System Context Rule

System context is high-risk.

System context may allow:

- tenant directory review
- global operational summary
- provider portfolio summary
- security incident overview
- support load overview
- commercial risk overview

System context must not allow casual runtime mutation across tenants.

System context should be mostly governance and review.

---

## 18. Tenant Context Rule

Tenant context may allow:

- tenant overview
- store list
- tenant-level billing scope
- tenant-level renewal status
- tenant-level support load
- tenant-level expansion status
- tenant-level evidence index
- tenant-level role summary

Tenant context must not expose unrelated tenant data.

---

## 19. Store Context Rule

Store context may allow:

- store health
- store modules
- store provider stack
- store payment safety
- store KDS safety
- store support cases
- store billing lines
- store renewal status
- store pilot evidence
- store expansion readiness

Store context is the main operational view.

---

## 20. Store Group Context Rule

Store group context may allow:

- multiple stores under one owner or tenant
- rollup health
- provider stack comparison
- support load comparison
- billing grouping
- renewal grouping
- expansion planning
- store-level drilldown

Store group context must not flatten store-specific risks.

Rollup view must preserve drilldown.

---

## 21. Support Case Context Rule

Support case context may allow temporary scoped visibility.

Rules:

- access must be linked to support case
- visibility should be limited to case-relevant data
- time or status expiration should exist
- sensitive data must remain masked unless approved
- action authority must follow support policy
- case closure should remove scoped access
- audit should record sensitive views/actions

Support case context must not become general tenant access.

---

## 22. Provider Stack Context Rule

Provider stack context may allow review of:

- provider name
- provider stack id
- affected stores
- provider status
- provider incidents
- provider mapping evidence
- webhook/local daemon status
- provider cost risk
- provider limitations

Provider stack context must avoid exposing unrelated customer details where possible.

---

## 23. Billing Context Rule

Billing context may allow review of:

- package
- enabled modules
- billing line items
- provider pass-through
- discounts
- credits
- amendments
- disputes
- revenue evidence
- renewal risk

Billing context must not allow runtime module mutation.

Billing visibility is commercial visibility, not runtime authority.

---

## 24. Pilot Context Rule

Pilot context may allow review of:

- pilot scope
- pilot status
- test stores
- pilot incidents
- daily reviews
- blockers
- customer feedback
- staff feedback
- paid conversion readiness

Pilot context must clearly show that pilot evidence is not production guarantee.

---

## 25. Expansion Context Rule

Expansion context may allow review of:

- source store
- target store
- provider stack comparison
- onboarding readiness
- support capacity
- staff training readiness
- payment/KDS readiness
- pricing assumption
- blocker status

Expansion context must not bypass readiness gates.

---

## 26. Security Review Context Rule

Security review context may allow controlled access to:

- access review
- device trust issue
- support masking issue
- export request
- incident evidence
- suspicious access
- tenant/store boundary issue
- provider secret exposure risk

Security review context must be audited and role-restricted.

---

## 27. Live Versus Test Context Rule

Admin Console must clearly separate:

- live production tenant
- pilot tenant
- internal test tenant
- demo tenant
- provider test tenant
- training tenant

Test context must not be confused with live context.

Live context actions require stricter controls.

---

## 28. Demo Tenant Rule

Demo tenant may be used only when:

- data is synthetic or approved
- no real CI/DI exists
- no real payment secrets exist
- no real customer private data exists
- no production provider credential exists
- demo limitations are clear
- export is controlled

Demo tenant must not contain copied sensitive production data.

---

## 29. Context Expiration Rule

Temporary context should expire when:

- support case closes
- review window ends
- role assignment expires
- device trust changes
- suspicious activity is detected
- user logs out
- session expires
- tenant/store access is revoked

Expired context must not remain usable through cached UI state.

---

## 30. Context Revocation Rule

Context access should be revoked when:

- user role is removed
- user leaves organization
- support case is reassigned
- device is lost or revoked
- security incident occurs
- customer contract ends
- store is removed
- tenant access is terminated
- misuse is detected

Revocation must affect active sessions where feasible.

---

## 31. Context Audit Rule

Context audit should record sensitive events such as:

- tenant context switch
- cross-store switch
- support case context entry
- unmask request
- export request
- high-risk action request
- security review context entry
- billing dispute context entry
- provider incident broadcast context
- expansion approval context

Audit detail should match risk.

---

## 32. Context Selection Record Fields

Each context selection event may record:

- context selection id
- user id
- role scope
- tenant id
- store id if applicable
- context type
- surface
- reason if required
- support case id if applicable
- timestamp
- device/session reference
- status
- notes

Final implementation may normalize these fields later.

---

## 33. Context Selection ID Format

Recommended format:

    CONTEXT-SELECTION-[YYYYMMDD]-[NUMBER]

Example:

    CONTEXT-SELECTION-20260612-001

Final format may be normalized later.

---

## 34. Context Safety Warnings

Context safety warning should appear when:

- user enters live tenant
- user switches tenant
- user switches store group
- user enters support case context
- user requests unmasking
- user requests export
- user views payment/KDS sensitive screen
- user enters security review context
- user enters billing dispute context
- user enters expansion approval context

Warnings should prevent accidental actions, not create alert fatigue.

---

## 35. Cross-Store Comparison Rule

Cross-store comparison may be allowed only when role permits.

Comparison should mask or summarize:

- customer identity details
- staff private details
- payment sensitive data
- support notes not needed for comparison
- security details
- unrelated incident details

Cross-store comparison should support operations without exposing unnecessary data.

---

## 36. Search And Filter Boundary

Admin search/filter must respect context.

Search should not return:

- other tenant data
- unauthorized store data
- closed support case data outside role
- raw CI/DI
- provider secrets
- payment secrets
- staff private data beyond scope
- hidden security incident details

Search must not become data exfiltration path.

---

## 37. Recent Context Shortcut Rule

Recent tenant/store shortcuts may be convenient but risky.

Rules:

- show only authorized recent contexts
- refresh permission before entry
- mark live/test clearly
- clear expired support contexts
- avoid exposing sensitive names where not needed
- require confirmation for high-risk context

Shortcut must not bypass authorization.

---

## 38. Favorite Store Rule

Favorite or pinned stores may be allowed for authorized users.

Rules:

- pinning does not create access
- access must refresh on entry
- removed store must disappear
- revoked role must remove favorite access
- store group pins must preserve boundaries

Convenience must not become entitlement.

---

## 39. Context Error Handling Rule

If context is invalid, Admin Console should show:

- safe error message
- no sensitive data
- reason category if appropriate
- next allowed action
- support contact path if needed
- audit event for repeated invalid access

Do not show whether unauthorized tenant/store exists in a revealing way.

---

## 40. Context Register Recommendation

Recommended future files:

    docs/_index/
      Admin_Context_Type_Register.md
      Admin_Role_Scope_Register.md
      Tenant_Directory_Surface_Register.md
      Store_Directory_Surface_Register.md
      Context_Switch_Audit_Register.md
      Support_Case_Context_Register.md
      Cross_Store_View_Register.md
      Demo_Tenant_Safety_Register.md

This document only recommends these files.

It does not create them.

---

## 41. Anti-Patterns

The following are prohibited:

- entering admin surface without tenant/store context
- carrying previous store filter into new tenant context
- showing all tenants to support user by default
- allowing support case access after case closure
- confusing demo tenant with live tenant
- allowing search to cross tenant boundary
- exposing raw CI/DI in directory
- assuming email domain grants store access
- using recent shortcut without permission refresh
- allowing cross-store comparison without role scope
- treating store group rollup as permission for all details
- hiding current context from admin user

---

## 42. Non-Goals

This document does not define:

- final UI layout
- final route paths
- final database schema
- final RLS policy
- final API endpoints
- final session implementation
- final authentication provider
- final audit table
- final component implementation

Those belong to later UI/UX, security, and implementation planning.

---

## 43. Readiness Check

This document is ready when the project can answer:

1. What does Tenant Directory mean?
2. What does Store Directory mean?
3. What context types exist?
4. What context status values exist?
5. What does role scope mean?
6. What role scope categories exist?
7. What tenant directory visibility rule applies?
8. What store directory visibility rule applies?
9. What context selection rule applies?
10. What context switch rule applies?
11. What context switch risks exist?
12. What should current context display show?
13. What system context rule applies?
14. What tenant context rule applies?
15. What store context rule applies?
16. What store group context rule applies?
17. What support case context rule applies?
18. What provider stack context rule applies?
19. What billing context rule applies?
20. What pilot context rule applies?
21. What expansion context rule applies?
22. What security review context rule applies?
23. What live versus test context rule applies?
24. What demo tenant rule applies?
25. What context expiration rule applies?
26. What context revocation rule applies?
27. What context audit rule applies?
28. What fields should context selection record include?
29. What context safety warnings are needed?
30. What cross-store comparison rule applies?
31. What search and filter boundary applies?
32. What recent context shortcut rule applies?
33. What favorite store rule applies?
34. What context error handling rule applies?
35. What anti-patterns are prohibited?

If these questions cannot be answered, tenant/store directory, role scope, and context switching planning is incomplete.

---

## 44. Conclusion

SaaS Admin Console safety begins with context.

The safe context flow is:

    user login
        -> role scope
        -> tenant context
        -> store or store group context
        -> surface access
        -> masking rule
        -> allowed actions
        -> audit if sensitive
        -> context expiration or revocation

This document ensures that future admin screens do not leak tenant data, confuse store boundaries, carry stale authority across contexts, expose support-scoped data too broadly, or allow commercial and runtime actions under ambiguous context.