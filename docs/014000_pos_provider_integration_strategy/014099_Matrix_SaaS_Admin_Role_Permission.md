# 014099_Matrix_SaaS_Admin_Role_Permission

## 1. Purpose

This document defines the SaaS Admin Console role permission matrix, view authority, action request authority, approval authority, export authority, override authority, support case authority, billing authority, provider review authority, and runtime boundary policy for the Yoonsul Wait/Order Handoff documentation project.

The previous document defined tenant/store directory, role scope, context switching, and context safety policy.

This document defines how Admin Console roles should be mapped to view, request, approve, execute, export, override, and close capabilities without confusing visibility with authority.

This document does not implement permission engine, database RLS, API authorization, frontend route guards, policy-as-code, identity provider roles, or audit tables.

It defines role permission matrix policy only.

---

## 2. Scope

This document covers:

- role permission matrix
- view authority
- action request authority
- approval authority
- execution authority
- export authority
- override authority
- close authority
- support case authority
- billing/commercial authority
- provider review authority
- runtime authority boundary
- no-implementation boundary

This document does not cover:

- final permission schema
- final RLS implementation
- final API authorization
- final UI component visibility
- final OAuth/OIDC integration
- final IAM implementation
- final audit implementation
- final break-glass implementation
- final production access management

---

## 3. Core Principle

A role may see a status without owning the action.

The project must follow this rule:

> Admin permissions must separate view, request, approve, execute, export, override, and close capabilities so that no role gains unsafe authority simply because a dashboard, support case, billing record, or incident is visible.

Permission must be explicit.

Authority must be scoped.

Sensitive actions must be audited.

---

## 4. Permission Dimensions

Recommended permission dimensions:

- `CAN_VIEW`
- `CAN_VIEW_MASKED`
- `CAN_REQUEST_REVIEW`
- `CAN_REQUEST_ACTION`
- `CAN_ASSIGN`
- `CAN_ESCALATE`
- `CAN_APPROVE`
- `CAN_EXECUTE`
- `CAN_EXPORT`
- `CAN_UNMASK`
- `CAN_OVERRIDE`
- `CAN_CLOSE`
- `CAN_CREATE_BLOCKER`
- `CAN_CREATE_BACKLOG`
- `CAN_CREATE_AMENDMENT`
- `CAN_CREATE_ADJUSTMENT_REQUEST`

Each dimension must be separately assigned.

---

## 5. Permission Scope Dimensions

Each permission should be scoped by:

- tenant
- store
- store group
- support case
- provider stack
- runtime domain
- billing entity
- commercial record
- security incident
- pilot scope
- expansion scope
- time window
- device trust status
- session assurance level

A permission without scope is unsafe.

---

## 6. Permission Status Values

Recommended permission status values:

- `PERMISSION_NOT_DEFINED`
- `PERMISSION_DENIED`
- `PERMISSION_VIEW_ONLY`
- `PERMISSION_MASKED_VIEW`
- `PERMISSION_REQUEST_ONLY`
- `PERMISSION_APPROVAL_REQUIRED`
- `PERMISSION_APPROVED`
- `PERMISSION_TEMPORARY`
- `PERMISSION_EXPIRED`
- `PERMISSION_REVOKED`
- `PERMISSION_SUSPENDED`
- `PERMISSION_REVIEW_REQUIRED`

Permission status should be visible to governance review.

---

## 7. Admin Role Families

Recommended admin role families:

- `YOONSUL_SYSTEM_ADMIN`
- `YOONSUL_OPERATIONS_ADMIN`
- `YOONSUL_SUPPORT_ADMIN`
- `YOONSUL_PROVIDER_ADMIN`
- `YOONSUL_PAYMENT_REVIEW_ADMIN`
- `YOONSUL_KDS_REVIEW_ADMIN`
- `YOONSUL_SECURITY_ADMIN`
- `YOONSUL_BILLING_ADMIN`
- `YOONSUL_CUSTOMER_SUCCESS_ADMIN`
- `YOONSUL_EXPANSION_ADMIN`
- `TENANT_HQ_ADMIN`
- `STORE_OWNER_ADMIN`
- `STORE_MANAGER_ADMIN`
- `READ_ONLY_AUDITOR`
- `LIMITED_SUPPORT_AGENT`

Final names may be normalized later.

---

## 8. Role Permission Matrix Meaning

A role permission matrix defines:

- which role may access which surface
- which context the role may use
- which data the role may view
- which sensitive fields are masked
- which actions the role may request
- which actions the role may approve
- which actions the role may execute
- which exports the role may request or approve
- which overrides are prohibited
- which closures require evidence

Matrix is a governance artifact before implementation.

---

## 9. System Admin Boundary

System Admin may have broad governance visibility, but not unrestricted runtime mutation.

Allowed in principle:

- view system-level governance summary
- manage admin role assignment through controlled process
- review tenant/store directory under audit
- review security incidents
- approve high-risk governance workflow if authorized
- initiate emergency containment workflow

Prohibited by default:

- direct payment approval mutation
- direct KDS completion mutation
- raw provider event trust
- audit evidence deletion
- casual raw CI/DI access
- unrestricted export
- silent support break-glass
- cross-tenant browsing without reason

System Admin is not above evidence.

---

## 10. Operations Admin Boundary

Operations Admin may view and manage operational workflows.

Allowed in principle:

- view assigned tenant/store health
- view support load
- view operational blockers
- request payment/KDS/provider review
- create blocker
- assign operations owner
- pause or recommend pause where authorized
- review pilot and expansion readiness

Prohibited by default:

- approve payment truth
- mark KDS completed
- approve refund/cancel
- unmask sensitive identity data
- export sensitive records
- override provider validation

Operations Admin manages operations, not financial truth.

---

## 11. Support Admin Boundary

Support Admin may work within support case scope.

Allowed in principle:

- view assigned support case
- view masked customer/store context
- view evidence packet summary
- request additional evidence
- escalate support case
- request break-glass
- propose customer recovery
- close support case with evidence if authorized

Prohibited by default:

- browse unrelated tenant/store data
- view raw CI/DI
- approve payment
- complete KDS
- delete support evidence
- keep access after case closure
- export case data without approval

Support access must remain case-scoped.

---

## 12. Provider Admin Boundary

Provider Admin may review provider stack and integration evidence.

Allowed in principle:

- view provider stack
- view provider incident
- view provider mapping evidence
- view webhook/local daemon status
- create provider review
- request provider containment
- update provider limitation record with approval
- support broadcast preparation

Prohibited by default:

- trust provider event as runtime truth
- change payment/order/KDS state directly
- expose provider secrets
- export unrelated customer data
- hide provider limitation from commercial review

Provider Admin owns provider review, not business truth.

---

## 13. Payment Review Admin Boundary

Payment Review Admin may review payment uncertainty and evidence.

Allowed in principle:

- view payment status summary
- view payment uncertainty
- view provider payment event linkage
- view duplicate payment suspicion
- request reconciliation
- recommend customer recovery
- create payment blocker
- mark payment review outcome where authorized

Prohibited by default:

- approve payment without payment runtime authority
- ignore provider validation
- delete payment evidence
- expose payment secrets
- bypass refund/cancel review
- hide uncertainty from customer recovery

Payment review must be conservative.

---

## 14. KDS Review Admin Boundary

KDS Review Admin may review kitchen handoff safety.

Allowed in principle:

- view KDS ticket status
- view KDS handoff evidence
- view duplicate KDS suspicion
- view held/degraded tickets
- create KDS blocker
- escalate KDS issue
- request manual recovery review
- mark KDS review outcome where authorized

Prohibited by default:

- mark food prepared
- mark KDS completed without KDS runtime authority
- create KDS ticket from unsafe order
- delete kitchen evidence
- hide duplicate suspicion
- override payment uncertainty

KDS review protects kitchen truth.

---

## 15. Security Admin Boundary

Security Admin may review security-sensitive workflows.

Allowed in principle:

- view security incident
- view device trust risk
- view support masking status
- view export request
- view access review
- approve containment where authorized
- request revocation
- request investigation
- review break-glass evidence

Prohibited by default:

- bypass masking casually
- grant broad support access without case
- expose secrets unnecessarily
- delete audit events
- approve commercial scope without operational review
- mutate payment/KDS/order truth

Security Admin controls protection, not all operations.

---

## 16. Billing Admin Boundary

Billing Admin may review billing and commercial records.

Allowed in principle:

- view package and billing line items
- view provider pass-through
- view discount/credit records
- view amendments
- create billing review
- create dispute
- create adjustment request
- record billing review outcome
- request customer acknowledgement

Prohibited by default:

- enable runtime module directly
- disable runtime module directly
- alter invoice without audit trail
- delete dispute history
- hide provider fee
- approve payment refund truth
- mutate runtime state

Billing Admin owns commercial records, not runtime state.

---

## 17. Customer Success Admin Boundary

Customer Success Admin may review value, renewal, churn, and expansion signals.

Allowed in principle:

- view renewal forecast
- view churn risk
- view owner value status
- view support burden summary
- view commercial risk
- create retention intervention
- create upgrade/downgrade review
- create expansion review
- request billing clarification

Prohibited by default:

- promise unsupported scope
- hide operational blockers
- approve expansion without readiness
- change price without commercial approval
- bypass provider cost review
- mutate payment/KDS state

Customer success must follow evidence.

---

## 18. Expansion Admin Boundary

Expansion Admin may review and coordinate expansion readiness.

Allowed in principle:

- view source store readiness
- view target store profile
- view provider stack comparison
- view support capacity
- view onboarding readiness
- create expansion review
- recommend scope restriction
- request provider/support/security review
- mark expansion review outcome where authorized

Prohibited by default:

- approve expansion over critical blocker
- bypass provider review
- bypass support capacity review
- bypass training readiness
- make commercial promise without billing review
- treat sales interest as readiness

Expansion must be gated.

---

## 19. Tenant HQ Admin Boundary

Tenant HQ Admin may view tenant-level authorized stores.

Allowed in principle:

- view tenant overview
- view authorized store list
- view store health summary
- view package/billing scope if authorized
- view support case summary
- view renewal/expansion status
- request support
- request scope change

Prohibited by default:

- view unrelated tenant data
- view raw CI/DI
- approve internal Yoonsul review outcomes
- access provider secrets
- export sensitive data without approval
- mutate payment/KDS/order truth

Tenant HQ access is customer-scoped.

---

## 20. Store Owner Admin Boundary

Store Owner Admin may view their store or authorized store group.

Allowed in principle:

- view store operational summary
- view enabled modules
- view support cases for own store
- view billing lines for own store if authorized
- view provider limitation summary
- request support
- request billing clarification
- request module/scope change

Prohibited by default:

- view other owner’s stores
- view raw provider secrets
- view raw CI/DI
- close internal incidents
- approve payment/KDS truth
- access support-only notes outside role

Store owner access must be scoped.

---

## 21. Store Manager Admin Boundary

Store Manager Admin may view store operations needed for daily work.

Allowed in principle:

- view store status
- view limited support guidance
- view KDS/payment warning summary
- view staff-facing operational notices
- request support
- acknowledge provider incident broadcast
- view limited module status

Prohibited by default:

- view billing details unless authorized
- view tenant-wide reports
- view commercial risk
- view raw CI/DI
- export sensitive data
- approve financial or runtime truth
- access other stores

Store Manager should not carry HQ authority.

---

## 22. Read Only Auditor Boundary

Read Only Auditor may view approved evidence.

Allowed in principle:

- view approved audit summary
- view evidence metadata
- view masked records
- view review status
- view policy compliance summary

Prohibited by default:

- mutate any runtime state
- request break-glass
- unmask sensitive data without approval
- export without approval
- close incidents
- approve corrections

Read-only must truly be read-only.

---

## 23. Limited Support Agent Boundary

Limited Support Agent may assist under narrow scope.

Allowed in principle:

- view assigned support case
- view scripted support guidance
- collect missing evidence
- escalate to Support Admin
- update case note if authorized

Prohibited by default:

- browse tenant/store directory broadly
- view sensitive data
- approve recovery
- close high-risk case
- export records
- access case after reassignment or closure

Limited support role should be tightly constrained.

---

## 24. View Permission Matrix Summary

Recommended view matrix pattern:

| Surface | Internal Admin | Tenant HQ | Store Owner | Store Manager | Support Case |
| ------- | -------------- | --------- | ----------- | ------------- | ------------ |
| Tenant Directory | scoped | own tenant | limited | no or limited | case-scoped |
| Store Directory | scoped | own stores | own stores | assigned store | case-scoped |
| Store Health | scoped | own stores | own stores | assigned store summary | case-scoped |
| Payment Review | runtime-scoped | summary only | summary only | warning only | case-scoped |
| KDS Review | runtime-scoped | summary only | summary only | warning only | case-scoped |
| Provider Stack | scoped | limitation summary | limitation summary | limited notice | case-scoped |
| Billing | billing-scoped | if authorized | if authorized | usually no | no unless needed |
| Support Case | scoped | own tenant cases | own store cases | assigned store cases | assigned case |
| Audit Evidence | scoped/masked | limited | limited | no or limited | case-scoped |

Final matrix may be expanded later.

---

## 25. Action Permission Matrix Summary

Recommended action matrix pattern:

| Action | Internal Admin | Tenant HQ | Store Owner | Store Manager | Support Agent |
| ------ | -------------- | --------- | ----------- | ------------- | ------------- |
| Request Support | yes | yes | yes | yes | no |
| Escalate Case | scoped | limited | limited | limited | to support admin |
| Request Scope Change | scoped | yes | yes if authorized | no or limited | no |
| Approve Scope Change | commercial authority only | maybe customer approval | no unless owner role | no | no |
| Request Export | scoped | if authorized | if authorized | no | no |
| Approve Export | security/commercial authority | no by default | no | no | no |
| Request Break-Glass | support/security scoped | no | no | no | no |
| Approve Break-Glass | security/support authority | no | no | no | no |
| Close Incident | owner role only | no | no | no | no |

Action permission must be separately reviewed.

---

## 26. Export Permission Rule

Export permission is high-risk.

Export requires:

- explicit export role
- purpose
- tenant/store scope
- data category
- masking/redaction rule
- approval
- evidence
- audit
- retention expectation

No role should receive export by default because it can view data.

---

## 27. Unmask Permission Rule

Unmask permission is exceptional.

Unmask requires:

- reason
- approval
- scope
- time limit
- audit
- support/security justification
- minimal field set
- no raw CI/DI unless explicitly governed

Unmask must not be used for convenience.

---

## 28. Override Permission Rule

Override permission is exceptional and must not bypass runtime truth.

Override may only mean:

- request override workflow
- approve limited administrative exception
- approve scoped support access
- approve scope pause
- approve blocker waiver where allowed
- approve temporary visibility extension

Override must not mean:

- force payment success
- force refund success
- force KDS completion
- force provider event trust
- delete audit evidence
- erase incident history

Override is governance, not truth mutation.

---

## 29. Close Permission Rule

Close permission must be evidence-bound.

Closures requiring strict evidence:

- support case closure
- incident closure
- blocker closure
- billing dispute closure
- provider incident closure
- pilot run closure
- renewal intervention closure
- expansion review closure
- security review closure

A user may comment on closure without having close authority.

---

## 30. Approval Permission Rule

Approval permission requires:

- role authority
- context scope
- evidence review
- conflict-of-interest check where needed
- reason code
- timestamp
- audit event
- optional reauthentication for high risk

Approval should not be hidden inside a normal save button.

---

## 31. Request Permission Rule

Request permission may be broader than approval.

Users may request:

- support
- review
- correction
- export
- scope change
- billing clarification
- expansion review
- provider review
- payment/KDS review

Request does not imply approval.

Request creates workflow.

---

## 32. Assign Permission Rule

Assignment permission should be limited to roles responsible for queue management.

Assignment may apply to:

- support case
- incident
- blocker
- provider review
- payment review
- KDS review
- billing dispute
- renewal intervention
- expansion review

Assignment must not change truth.

It changes responsibility.

---

## 33. Escalation Permission Rule

Escalation permission may be allowed for many roles but routed by policy.

Escalation should include:

- reason
- target level
- affected context
- urgency
- evidence
- expected decision

Escalation must not be used to bypass required review.

---

## 34. Permission Conflict Rule

Permission conflict exists when one user can:

- create and approve same high-risk request
- request and close same critical incident without review
- adjust billing and approve own adjustment
- open support break-glass and approve it
- create export and approve export
- waive blocker and mark readiness
- approve expansion and own revenue target

High-risk conflict should require separation of duties.

---

## 35. Separation Of Duties Rule

Separation of duties should apply to:

- export approval
- break-glass approval
- billing adjustment approval
- commercial discount approval
- critical incident closure
- blocker waiver
- expansion approval
- security incident resolution
- provider limitation override
- payment/KDS high-risk review

One person should not control the full sensitive path unless explicit emergency policy applies.

---

## 36. Temporary Permission Rule

Temporary permission may be granted only when:

- reason is recorded
- scope is defined
- start/end time exists
- approver is defined
- sensitive fields are masked by default
- audit is enabled
- revocation path exists
- renewal requires review

Temporary permission must expire.

---

## 37. Permission Revocation Rule

Permission must be revoked when:

- role changes
- user leaves organization
- store assignment ends
- support case closes
- device trust is revoked
- suspicious activity occurs
- contract ends
- tenant/store access ends
- temporary grant expires
- security incident requires containment

Revocation should affect active sessions where feasible.

---

## 38. Permission Review Cadence

Recommended cadence:

| Permission Type | Review Cadence |
| --------------- | -------------- |
| System admin | monthly or after incident |
| Support access | case closure and periodic |
| Export authority | monthly |
| Billing adjustment authority | monthly |
| Security admin | monthly |
| Tenant HQ admin | contract or role change |
| Store owner/manager | store assignment change |
| Temporary permission | expiration-based |
| Break-glass authority | after each use |

Cadence should match risk.

---

## 39. Permission Audit Event Examples

Permission-related audit events may include:

- role assigned
- role removed
- permission granted
- permission revoked
- temporary permission granted
- temporary permission expired
- export requested
- export approved
- unmask requested
- break-glass requested
- override requested
- high-risk action approved
- permission conflict detected
- role review completed

Audit must preserve who, what, when, why, and scope.

---

## 40. Permission Matrix Record Fields

Each permission matrix record should include:

- matrix id
- role
- surface
- context type
- tenant/store scope
- view permission
- masked view permission
- request permission
- approval permission
- execution permission
- export permission
- unmask permission
- override permission
- close permission
- evidence requirement
- audit requirement
- review cadence
- owner
- status
- notes

This record becomes future implementation input.

---

## 41. Permission Matrix ID Format

Recommended format:

    PERMISSION-MATRIX-[ROLE]-[SURFACE]

Example:

    PERMISSION-MATRIX-SUPPORTADMIN-SUPPORTCONSOLE

Final format may be normalized later.

---

## 42. Permission Matrix Status Values

Recommended status values:

- `MATRIX_NOT_DEFINED`
- `MATRIX_DRAFT`
- `MATRIX_REVIEW_REQUIRED`
- `MATRIX_SECURITY_REVIEW_REQUIRED`
- `MATRIX_APPROVED_FOR_WIREFRAME`
- `MATRIX_APPROVED_FOR_BACKLOG`
- `MATRIX_DEFERRED`
- `MATRIX_REJECTED`
- `MATRIX_SUPERSEDED`

Matrix should be approved before UI backlog extraction.

---

## 43. Registers Recommendation

Recommended future files:

    docs/_index/
      Admin_Role_Permission_Matrix.md
      Admin_View_Authority_Register.md
      Admin_Action_Authority_Register.md
      Admin_Export_Authority_Register.md
      Admin_Unmask_Authority_Register.md
      Admin_Override_Authority_Register.md
      Admin_Close_Authority_Register.md
      Admin_Separation_Of_Duties_Register.md
      Admin_Temporary_Permission_Register.md
      Admin_Permission_Review_Register.md

This document only recommends these files.

It does not create them.

---

## 44. Anti-Patterns

The following are prohibited:

- giving action authority because view authority exists
- giving export authority by default
- giving unmask permission for convenience
- allowing support to approve payment
- allowing billing to mutate runtime module state
- allowing provider admin to trust provider event
- allowing one user to request and approve high-risk export
- allowing temporary permission without expiration
- allowing closed support case access to remain active
- hiding permission conflict
- treating System Admin as evidence-free superuser
- closing incident without close authority
- building UI before permission matrix review

---

## 45. Non-Goals

This document does not define:

- final permission engine
- final RLS implementation
- final IAM integration
- final API policy enforcement
- final frontend route guard
- final audit table
- final admin user management UI
- final emergency access implementation

Those belong to later security and implementation planning.

---

## 46. Readiness Check

This document is ready when the project can answer:

1. What permission dimensions exist?
2. What permission scope dimensions exist?
3. What permission status values exist?
4. What admin role families exist?
5. What does role permission matrix mean?
6. What System Admin boundary applies?
7. What Operations Admin boundary applies?
8. What Support Admin boundary applies?
9. What Provider Admin boundary applies?
10. What Payment Review Admin boundary applies?
11. What KDS Review Admin boundary applies?
12. What Security Admin boundary applies?
13. What Billing Admin boundary applies?
14. What Customer Success Admin boundary applies?
15. What Expansion Admin boundary applies?
16. What Tenant HQ Admin boundary applies?
17. What Store Owner Admin boundary applies?
18. What Store Manager Admin boundary applies?
19. What Read Only Auditor boundary applies?
20. What Limited Support Agent boundary applies?
21. What view matrix pattern applies?
22. What action matrix pattern applies?
23. What export permission rule applies?
24. What unmask permission rule applies?
25. What override permission rule applies?
26. What close permission rule applies?
27. What approval permission rule applies?
28. What request permission rule applies?
29. What assign permission rule applies?
30. What escalation permission rule applies?
31. What permission conflict rule applies?
32. What separation of duties rule applies?
33. What temporary permission rule applies?
34. What revocation rule applies?
35. What review cadence applies?
36. What fields should permission matrix record include?
37. What anti-patterns are prohibited?

If these questions cannot be answered, SaaS Admin role permission matrix and authority boundary planning is incomplete.

---

## 47. Conclusion

SaaS Admin Console permissions must be designed before screens are built.

The safe permission flow is:

    role
        -> context
        -> surface
        -> view authority
        -> request authority
        -> approval authority
        -> execution boundary
        -> export/unmask/override limits
        -> evidence and audit
        -> review and revocation

This document ensures that admin roles remain scoped, sensitive actions remain controlled, and future UI buttons do not accidentally become unauthorized runtime, commercial, export, support, or security authority.