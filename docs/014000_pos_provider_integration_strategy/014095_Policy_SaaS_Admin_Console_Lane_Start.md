# 014095_Policy_SaaS_Admin_Console_Lane_Start

## 1. Purpose

This document starts the SaaS Admin Console governance lane for the Yoonsul Wait/Order Handoff documentation project.

It defines the role surface, runtime view boundary, action boundary, tenant/store visibility, support visibility, provider visibility, billing visibility, pilot visibility, and no-silent-mutation principle for future SaaS admin screens.

The previous lane defined multi-store commercial governance, billing, amendment, revenue evidence, dispute, pricing, and margin risk.

This document defines how those commercial and operational controls should later appear in SaaS admin surfaces without giving unsafe authority to UI screens.

This document does not implement admin UI, database views, APIs, permissions, dashboards, frontend routes, or backend services.

It defines SaaS Admin Console policy only.

---

## 2. Scope

This document covers:

- SaaS Admin Console purpose
- admin user role surfaces
- runtime view boundary
- action authority boundary
- tenant/store visibility
- support view boundary
- provider view boundary
- payment/KDS view boundary
- billing/commercial view boundary
- pilot/expansion view boundary
- dashboard-to-action separation
- no-implementation boundary

This document does not cover:

- final admin UI design
- final wireframes
- final Flutter/React implementation
- final API authorization
- final database schema
- final RLS policy
- final dashboard query
- final CRM integration
- final billing system integration

---

## 3. Core Principle

Admin Console is a visibility and governance surface, not unrestricted authority.

The project must follow this rule:

> Admin surfaces may display runtime, commercial, support, provider, pilot, and expansion status only within role scope, and may initiate controlled workflows only when authority, evidence, audit, and approval boundaries are satisfied.

A button is not authority.

A dashboard is not truth ownership.

A visible state is not permission to mutate it.

---

## 4. SaaS Admin Console Meaning

SaaS Admin Console means the future internal or customer-facing management surface used to view and govern:

- tenants
- stores
- users
- roles
- devices
- sessions
- orders
- payments
- KDS handoffs
- provider stacks
- support cases
- incidents
- pilot runs
- evidence packets
- billing scope
- renewal risk
- expansion readiness
- commercial risk

It is the control room for operations.

It must not become a shortcut around runtime authority.

---

## 5. Admin Console User Groups

Recommended user groups:

| User Group | Purpose |
| ---------- | ------- |
| Yoonsul Super Admin | system-level governance under strict control |
| Yoonsul Operations Admin | store/runtime health review |
| Yoonsul Support Admin | support cases and recovery within scope |
| Provider Integration Admin | provider stack, incidents, mapping evidence |
| Payment Review Admin | payment uncertainty and reconciliation review |
| KDS Review Admin | KDS handoff and kitchen incident review |
| Security Admin | access, device, masking, incident review |
| Billing Admin | billing scope, invoices, amendments, disputes |
| Customer Success Admin | renewal, churn, value, expansion |
| Tenant HQ Admin | customer HQ-level store visibility |
| Store Owner Admin | store-level operational and commercial view |
| Store Manager Admin | store operational view and limited actions |

User group must determine what is visible and what is actionable.

---

## 6. Admin Surface Families

Recommended admin surface families:

- tenant management
- store management
- role and access management
- device trust management
- runtime health dashboard
- payment review dashboard
- KDS handoff dashboard
- provider stack dashboard
- support case console
- incident console
- pilot evidence console
- billing and contract console
- renewal and churn console
- expansion readiness console
- audit and evidence console
- security and masking console

Each surface must have explicit purpose and authority boundary.

---

## 7. View Authority Versus Action Authority

View authority means a user may see a status or evidence summary.

Action authority means a user may initiate a controlled workflow.

The project must separate:

    can_view
    can_request_action
    can_approve_action
    can_execute_action
    can_export
    can_override
    can_close

A user who can view a payment incident does not automatically have authority to approve payment.

A user who can view KDS status does not automatically have authority to mark KDS completed.

---

## 8. Runtime Truth Ownership Rule

Runtime truth remains owned by runtime owners.

Admin Console must not directly own:

- payment approval truth
- refund completion truth
- order acceptance truth
- KDS execution truth
- provider event truth
- support break-glass truth
- device trust truth
- export approval truth
- audit evidence truth

Admin Console may display, request, review, approve, or route according to policy.

It must not silently mutate runtime truth.

---

## 9. Admin Action Categories

Recommended admin action categories:

- `VIEW_ONLY`
- `REQUEST_REVIEW`
- `REQUEST_CORRECTION`
- `REQUEST_EXPORT`
- `REQUEST_SUPPORT_SESSION`
- `REQUEST_BREAK_GLASS`
- `APPROVE_WITH_SCOPE`
- `REJECT_REQUEST`
- `ASSIGN_OWNER`
- `ESCALATE_CASE`
- `PAUSE_SCOPE`
- `RESUME_SCOPE`
- `CREATE_BLOCKER`
- `CREATE_BACKLOG_ITEM`
- `CREATE_AMENDMENT`
- `CREATE_BILLING_ADJUSTMENT`
- `MARK_ADMIN_REVIEWED`

Action category must not imply runtime truth mutation unless runtime authority approves.

---

## 10. Prohibited Admin Actions

The following must not be available as direct admin actions:

- directly mark payment approved
- directly mark refund completed
- directly mark order accepted without runtime authority
- directly mark KDS ticket completed
- directly trust provider event without validation
- directly bypass support masking
- directly expose raw CI/DI
- directly export sensitive data without approval
- directly change device trust without audit
- directly close incident without evidence
- directly alter audit evidence
- directly delete commercial dispute history
- directly silence critical blocker

Admin Console must not be a superuser panic panel.

---

## 11. Tenant Boundary Rule

Admin Console must enforce tenant boundary.

Rules:

- tenant data must not leak to another tenant
- tenant HQ admin sees only assigned tenant scope
- store owner sees only owned/authorized store scope
- support admin sees cross-tenant only through assigned case and role
- commercial admin sees billing scope only according to authority
- provider admin sees provider evidence without unrelated customer data where possible
- security admin views sensitive context under strict audit

Tenant boundary is foundational.

---

## 12. Store Boundary Rule

Store boundary must separate:

- store runtime state
- store staff view
- store owner view
- store support case
- store billing line
- store provider stack
- store incident
- store evidence packet
- store expansion readiness

Multi-store owner may see multiple stores only when ownership and role are defined.

Store access must not be inferred from email domain alone.

---

## 13. Role-Based Surface Access

Each admin surface should define:

- allowed roles
- default visibility
- sensitive fields hidden
- action buttons visible
- action buttons disabled
- required approval
- audit requirement
- export allowance
- support case requirement
- tenant/store scope

Surface access must be explicit.

---

## 14. Support Console Boundary

Support Console may allow:

- view assigned case
- view masked customer/store context
- view state summary
- view evidence packet summary
- request more evidence
- escalate case
- propose resolution
- request scoped support session
- request break-glass with reason
- close support case with evidence

Support Console must not allow:

- raw CI/DI view by default
- payment approval mutation
- KDS completion mutation
- refund completion mutation
- tenant-wide browsing without case
- unlimited session access
- evidence deletion

Support remains recovery layer.

---

## 15. Payment Review Surface Boundary

Payment Review Surface may allow:

- view payment status
- view payment uncertainty
- view provider event linkage
- view evidence packet
- view duplicate suspicion
- request reconciliation
- escalate to payment owner
- mark review outcome as admin review
- create support/customer recovery task

Payment Review Surface must not:

- approve payment without payment runtime authority
- ignore provider validation
- override payment uncertainty without evidence
- hide duplicate suspicion
- bypass refund/cancel policy

Payment truth remains conservative.

---

## 16. KDS Review Surface Boundary

KDS Review Surface may allow:

- view KDS ticket state
- view KDS handoff evidence
- view duplicate suspicion
- view held tickets
- view degraded kitchen note
- escalate to KDS owner
- create KDS blocker
- request manual recovery review
- record admin review outcome

KDS Review Surface must not:

- mark ticket completed without KDS authority
- create ticket from unsafe order
- ignore payment uncertainty
- silently merge duplicate tickets
- delete kitchen evidence

Kitchen execution truth belongs to KDS runtime.

---

## 17. Provider Stack Surface Boundary

Provider Stack Surface may allow:

- view provider stack per store
- view provider status
- view provider incidents
- view mapping evidence
- view webhook/local daemon status
- view provider cost risk
- create provider review
- broadcast provider incident guidance
- request provider containment
- update provider evidence status with approval

Provider Stack Surface must not:

- trust raw provider event as final truth
- change payment/order/KDS state directly
- expose provider secrets
- expose webhook secrets
- hide provider limitation from commercial review

Provider visibility is not runtime authority.

---

## 18. Device Trust Surface Boundary

Device Trust Surface may allow:

- view registered devices
- view trusted/suspended/revoked status
- report lost device
- request revocation
- approve revocation if authorized
- view device evidence
- view store device assignment
- create device incident

Device Trust Surface must not:

- silently trust device without review
- let user role override revoked device
- hide device loss
- expose unrelated device data
- skip audit on trust change

User authority and device trust remain separate.

---

## 19. Billing And Contract Surface Boundary

Billing/Contract Surface may allow:

- view package
- view enabled modules
- view billing line items
- view provider pass-through
- view discount/credit
- view amendment history
- create billing review
- create dispute
- create adjustment request
- create scope change request
- record customer acknowledgement

Billing/Contract Surface must not:

- change runtime module state directly
- bill unsafe module
- delete dispute history
- hide provider fee
- silently extend discount
- modify invoice without audit trail

Commercial truth must remain traceable.

---

## 20. Renewal And Churn Surface Boundary

Renewal/Churn Surface may allow:

- view renewal forecast
- view churn risk
- view downgrade risk
- view owner value status
- view support burden
- create retention intervention
- create renewal review
- create downgrade review
- create expansion review
- create commercial risk item

Renewal/Churn Surface must not:

- claim renewal health without operational evidence
- hide payment/KDS/provider risk
- override store health
- create commercial promise beyond approved scope

Customer success must follow evidence.

---

## 21. Expansion Readiness Surface Boundary

Expansion Readiness Surface may allow:

- view expansion candidates
- view target store profile
- view provider stack comparison
- view support capacity
- view onboarding readiness
- view payment/KDS readiness
- create expansion review
- recommend scope restriction
- pause expansion
- approve next review step where authorized

Expansion Surface must not:

- approve expansion while critical blocker remains
- skip provider review
- skip staff training review
- skip support capacity review
- treat sales interest as readiness

Expansion must follow operational proof.

---

## 22. Pilot Evidence Surface Boundary

Pilot Evidence Surface may allow:

- view pilot run
- view pilot incidents
- view daily/weekly reviews
- view staff feedback
- view customer feedback
- view blockers
- create learning item
- create scope decision
- create pilot-to-paid review

Pilot Evidence Surface must not:

- rewrite pilot evidence
- hide failed pilot incident
- convert pilot to paid without commercial review
- claim production readiness from limited pilot

Pilot evidence is learning asset.

---

## 23. Audit And Evidence Surface Boundary

Audit/Evidence Surface may allow:

- view evidence packet metadata
- view audit event summary
- view related runtime transition
- view masking status
- view reviewer status
- request evidence review
- flag evidence gap

Audit/Evidence Surface must not:

- delete audit evidence
- edit historical audit truth
- expose secrets
- export without authority
- mark evidence complete without reviewer

Audit evidence must be append-only or append-only-equivalent.

---

## 24. Security Admin Surface Boundary

Security Admin Surface may allow:

- view security incidents
- view device trust risk
- view support masking status
- view access review
- view export risk
- view provider secret exposure risk
- create security incident
- request containment
- approve limited security workflow if authorized

Security Admin Surface must not:

- expose secrets unnecessarily
- bypass tenant/store scope casually
- grant broad support access without case
- disable audit
- approve commercial scope without operational review

Security is cross-cutting but still governed.

---

## 25. Dashboard-To-Workflow Rule

Dashboard signal may create workflow.

Example:

    payment warning
        -> payment review request
        -> evidence review
        -> payment owner decision

Dashboard signal must not directly create final runtime outcome.

Example prohibited:

    payment warning
        -> admin clicks approve
        -> payment becomes approved

Dashboard-to-workflow separation protects truth.

---

## 26. Admin Action Evidence Rule

Every sensitive admin action must produce evidence.

Sensitive actions include:

- support session approval
- break-glass request
- device revocation
- export request
- scope pause
- billing adjustment request
- provider containment request
- incident closure
- blocker waiver
- commercial amendment
- renewal decision
- expansion decision

Evidence must identify actor, reason, scope, timestamp, and outcome.

---

## 27. Admin Action Reason Code Rule

Sensitive admin actions require reason code.

Recommended reason code families:

- `CUSTOMER_RECOVERY`
- `PAYMENT_REVIEW`
- `KDS_REVIEW`
- `PROVIDER_INCIDENT`
- `SUPPORT_ESCALATION`
- `SECURITY_CONTAINMENT`
- `DEVICE_LOST`
- `EXPORT_REQUEST`
- `BILLING_DISPUTE`
- `SCOPE_CHANGE`
- `RENEWAL_RISK`
- `EXPANSION_REVIEW`
- `PILOT_REVIEW`
- `EVIDENCE_GAP`

Reason code supports audit and trend review.

---

## 28. Admin Session Rule

Admin sessions should be:

- authenticated
- role-scoped
- tenant/store-scoped
- time-bound
- device-aware
- audited for sensitive actions
- reauthenticated for high-risk actions
- revoked when role/device risk changes

Admin login is not permanent authority.

---

## 29. Sensitive Field Masking Rule

Admin Console must mask or hide:

- raw CI/DI
- payment secrets
- provider secrets
- webhook secrets
- tokens
- customer private data beyond need
- staff private data beyond need
- cross-store data outside scope
- support-only notes outside role
- security incident detail outside role

Masking should be default.

Unmasking requires explicit policy.

---

## 30. Export Boundary Rule

Admin Console view does not equal export authority.

Export requires:

- export request
- purpose
- scope
- approval
- masking/redaction
- evidence
- audit
- retention expectation

No dashboard should include casual download of sensitive data by default.

---

## 31. Admin Console Status Values

Recommended Admin Console surface status values:

- `SURFACE_NOT_DEFINED`
- `SURFACE_DRAFT`
- `SURFACE_REVIEW_REQUIRED`
- `SURFACE_ROLE_MAPPING_REQUIRED`
- `SURFACE_SECURITY_REVIEW_REQUIRED`
- `SURFACE_ACTION_BOUNDARY_REQUIRED`
- `SURFACE_READY_FOR_WIREFRAME`
- `SURFACE_READY_FOR_BACKLOG_EXTRACTION`
- `SURFACE_DEFERRED`
- `SURFACE_REJECTED`

Admin surfaces should not move to UI design without action boundary.

---

## 32. Surface Definition Record Fields

Each admin surface should record:

- surface id
- surface name
- user groups
- purpose
- data shown
- sensitive fields
- masking rule
- allowed actions
- prohibited actions
- required approvals
- evidence requirement
- export rule
- audit requirement
- owner
- status
- notes

This record becomes future UI/backlog input.

---

## 33. Surface ID Format

Recommended format:

    ADMIN-SURFACE-[DOMAIN]-[NUMBER]

Examples:

    ADMIN-SURFACE-PAYMENT-001
    ADMIN-SURFACE-KDS-001
    ADMIN-SURFACE-SUPPORT-001
    ADMIN-SURFACE-BILLING-001
    ADMIN-SURFACE-EXPANSION-001

Final format may be normalized later.

---

## 34. Admin Console Readiness Gate

An admin surface is ready for wireframe only when:

1. user groups are defined
2. tenant/store scope is defined
3. data shown is defined
4. sensitive fields are identified
5. masking rule is defined
6. allowed actions are defined
7. prohibited actions are defined
8. evidence requirement is defined
9. audit requirement is defined
10. export boundary is defined
11. runtime truth owner is identified
12. action owner is identified

Wireframe before authority review creates unsafe UI.

---

## 35. Admin Console Backlog Extraction Rule

Admin Console backlog item may be extracted only when:

- surface definition exists
- role/scope boundary exists
- action boundary exists
- security review is marked required or complete
- evidence requirement exists
- prohibited actions are listed
- implementation phase is identified
- no-scope-creep boundary is clear

Do not create admin UI backlog from vague dashboard idea.

---

## 36. Admin Console Lane Register Recommendation

Recommended future files:

    docs/_index/
      SaaS_Admin_Surface_Register.md
      Admin_Role_Surface_Matrix.md
      Admin_Action_Boundary_Register.md
      Admin_Sensitive_Field_Masking_Register.md
      Admin_Export_Boundary_Register.md
      Admin_Surface_Backlog_Extraction_Register.md

This document only recommends these files.

It does not create them.

---

## 37. Anti-Patterns

The following are prohibited:

- building admin dashboard before authority boundary
- giving super admin unrestricted runtime mutation
- allowing support admin to approve payment
- allowing billing admin to enable runtime module directly
- allowing provider admin to trust raw provider event
- exposing raw CI/DI in admin table
- providing export button without export approval
- hiding failed incident from dashboard
- closing support case without evidence
- treating visibility as authority
- treating dashboard health as operational proof without evidence
- creating UI action before runtime owner is defined

---

## 38. Non-Goals

This document does not define:

- final admin UI
- final wireframe
- final route structure
- final component library
- final API design
- final database view
- final RLS implementation
- final audit implementation
- final permission engine

Those belong to later UI/UX, implementation, and security planning.

---

## 39. Readiness Check

This document is ready when the project can answer:

1. What does SaaS Admin Console mean?
2. What user groups exist?
3. What surface families exist?
4. How are view authority and action authority separated?
5. What runtime truth ownership rule applies?
6. What admin action categories exist?
7. What admin actions are prohibited?
8. What tenant boundary applies?
9. What store boundary applies?
10. How is role-based surface access defined?
11. What support console boundary applies?
12. What payment review surface boundary applies?
13. What KDS review surface boundary applies?
14. What provider stack surface boundary applies?
15. What device trust surface boundary applies?
16. What billing surface boundary applies?
17. What renewal/churn surface boundary applies?
18. What expansion surface boundary applies?
19. What pilot evidence surface boundary applies?
20. What audit/evidence surface boundary applies?
21. What security surface boundary applies?
22. What dashboard-to-workflow rule applies?
23. What admin action evidence rule applies?
24. What reason code rule applies?
25. What admin session rule applies?
26. What sensitive field masking rule applies?
27. What export boundary applies?
28. What surface status values exist?
29. What fields should surface definition record include?
30. What readiness gate applies before wireframe?
31. What backlog extraction rule applies?
32. What anti-patterns are prohibited?

If these questions cannot be answered, SaaS Admin Console lane start and action boundary planning is incomplete.

---

## 40. Conclusion

The SaaS Admin Console must make operations visible without becoming an unsafe override panel.

The safe admin design flow is:

    admin user group
        -> surface purpose
        -> tenant/store scope
        -> data visibility
        -> sensitive field masking
        -> allowed actions
        -> prohibited actions
        -> evidence requirement
        -> audit boundary
        -> wireframe readiness
        -> backlog extraction

This document starts the Admin Console lane by ensuring that future dashboards, review panels, support tools, billing screens, provider views, and expansion consoles remain aligned with runtime authority, security, evidence, and commercial governance.