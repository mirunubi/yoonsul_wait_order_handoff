# 012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md

## Purpose

This document defines the implementation mapping policy for tenant context, store context, RLS, access control, scoped authority, and cross-context denial in the Yoonsul Wait/Order Handoff project.

The project is SaaS-oriented.

Therefore, tenant and store isolation must be treated as a primary implementation constraint before any runtime, POS/KDS, payment, support, customer, staff, or analytics feature is implemented.

This document maps existing policy into future implementation constraints.

It does not implement database schema, RLS policies, RPC functions, or application code.

---

## 2. Scope

This mapping applies to:

- tenant context
- store context
- company context
- legal entity context
- operating group context
- owner access
- staff access
- HQ access
- support access
- customer access
- POS runtime access
- KDS runtime access
- bridge access
- local agent access
- export access
- AI dataset access
- audit visibility
- RLS mapping
- access control mapping
- cross-tenant denial
- cross-store denial
- context validation
- scoped session handling
- implementation blockers

This document does not define final SQL or code.

---

## 3. Core Principle

Tenant and store context must be enforced server-side.

The project must follow this rule:

> Tenant/store isolation is not a UI filter. It is a server-side security boundary.

Every sensitive request must be evaluated against tenant, store, actor, role, device, session, and runtime context.

---

## 4. Related Policy Documents

This mapping depends on:

- 04471_Policy_Financial_Grade_Security_Baseline_And_Secret_Coding
- 04521_Policy_Support_Access_Masking_Break_Glass_And_Scoped_Session
- 04531_Policy_Security_Audit_Event_Immutability_And_Tamper_Evidence
- 04541_Policy_Device_Trust_Session_Revocation_And_Store_Runtime_Access
- 04561_Policy_Tenant_Store_Boundary_Isolation_And_Cross_Context_Access
- 04571_Policy_Secure_Deployment_Environment_Separation_And_Release_Gate
- 04581_Policy_Log_Masking_Error_Disclosure_And_Diagnostic_Data
- 04601_Policy_Data_Export_Report_Benchmark_And_External_Sharing_Security
- 04611_Policy_AI_Analytics_Dataset_Minimization_And_Model_Output_Security
- 04621_Policy_Security_Incident_Response_Severity_Classification_And_Recovery_Governance
- 04631_Policy_Compliance_Readiness_Evidence_Control_And_Financial_Grade_Security_Review
- 04661_Policy_Security_Testing_Abuse_Case_Threat_Modeling_And_Verification
- 04831_Implementation_Mapping_Lane_Start_And_Policy_To_Code_Constraint_Handoff_Policy

Future implementation must not ignore these policy constraints.

---

## 5. Affected Runtime

This mapping affects:

- Customer Web Runtime
- Customer Mobile Runtime
- Staff Runtime
- Store Tablet Runtime
- POS Runtime
- KDS Runtime
- POS/KDS Bridge Runtime
- Local Agent Runtime
- Support Runtime
- HQ Admin Runtime
- Owner Runtime
- Audit Runtime
- Export Runtime
- AI Analytics Runtime
- Vendor Integration Runtime

Any runtime that reads, writes, displays, exports, synchronizes, or analyzes tenant/store-scoped data is affected.

---

## 6. Tenant Context Definition

Tenant represents the SaaS customer boundary.

Tenant may contain:

- one brand
- one franchise operator
- one business customer
- one operating organization
- one legal or business grouping depending on future model

Tenant is not the same as store.

Tenant is not the same as legal entity.

Tenant is the highest SaaS isolation boundary for operational data.

---

## 7. Store Context Definition

Store represents a physical or operational unit where orders, waiting, POS/KDS, staff, devices, payments, incidents, and local recovery happen.

Store context must be attached to:

- waiting sessions
- orders
- table sessions
- POS events
- KDS tickets
- payment handoff records
- staff activity
- support cases
- local agent records
- device sessions
- audit events
- exports
- evidence packets

Store context must not be inferred only from UI route.

---

## 8. Parallel Context Axes

The system may eventually use several context axes.

Possible axes:

- tenant
- store
- company
- legal entity
- operating group
- region
- franchise group
- support scope
- runtime scope
- device scope

These axes must not be collapsed incorrectly.

For example:

- tenant is not always company
- company is not always operating group
- legal entity is not always store owner
- operating group is not always a legal boundary
- support scope is not normal business authority

Mapping must preserve these distinctions.

---

## 9. Required Context Fields

Future implementation should map sensitive access using fields such as:

- tenant_id
- store_id
- actor_id
- actor_type
- actor_role
- actor_affiliation_id
- company_id where applicable
- legal_entity_id where applicable
- operating_group_id where applicable
- device_id
- device_role
- session_id
- runtime_type
- runtime_id
- request_id
- correlation_id
- support_case_id where applicable
- approval_id where applicable
- incident_id where applicable

Required fields may vary by runtime.

However, tenant_id and store_id must be explicit for store-scoped operational data.

---

## 10. Actor Categories

Actor categories may include:

- customer
- store staff
- store manager
- owner
- HQ staff
- HQ team lead
- support agent
- security reviewer
- system service
- POS service identity
- KDS service identity
- bridge service identity
- local agent identity
- vendor service identity
- AI service identity

Actor category alone is not enough.

Authority must be evaluated by actor category, role, affiliation, scope, session, device, and requested action.

---

## 11. Role And Affiliation Mapping

Future implementation should distinguish:

- global role
- tenant role
- store role
- company role
- legal entity role
- operating group role
- support role
- temporary backup role
- break-glass role
- service identity role

A user may have authority in one store but not another.

A user may have authority under one tenant but not another.

A support role must not become broad tenant authority by default.

---

## 12. Access Control Decision Inputs

Access control should evaluate:

- who is acting
- which tenant is requested
- which store is requested
- what runtime is used
- which device is used
- what action is requested
- what data category is touched
- whether support case exists
- whether approval exists
- whether degraded mode is active
- whether break-glass is active
- whether session is fresh enough
- whether role is still valid
- whether device is trusted

Access decision must be explicit.

---

## 13. RLS Mapping Principle

RLS should follow deny-by-default.

Future RLS mapping should assume:

- no table is publicly readable by default
- no table is writable by default
- tenant-scoped rows require tenant match
- store-scoped rows require tenant and store match
- staff data requires role and affiliation
- support access requires case scope
- export access requires separate authority
- audit write should be controlled by trusted functions
- sensitive access may require privileged server-side functions

RLS must not rely on frontend filtering.

---

## 14. Table Classification Mapping

Future schema design should classify tables by access pattern.

Possible classes:

- public reference table
- tenant-scoped table
- store-scoped table
- actor-owned table
- staff-private table
- customer-private table
- payment-sensitive table
- CI / DI sensitive table
- support-case-scoped table
- audit append-only table
- export-controlled table
- AI-dataset-controlled table
- vendor-controlled integration table
- system-only table

Each table class should have an access policy.

---

## 15. Public Reference Table Constraint

Public reference tables may include non-sensitive lookup data.

Examples may include:

- app display constants
- public menu category metadata
- general public configuration
- public brand content where intended

Public reference table must not include:

- tenant secrets
- store secrets
- internal configuration
- customer identity
- CI / DI
- payment data
- staff private data
- support data
- audit data
- provider credentials

Public does not mean careless.

---

## 16. Tenant-Scoped Table Constraint

Tenant-scoped tables must include tenant_id.

Access requires tenant match.

Tenant-scoped tables may include:

- tenant settings
- tenant policy configuration
- tenant-level menu catalog
- tenant-level reporting aggregates
- tenant-level user role mapping
- tenant-level export records

Tenant-scoped does not automatically grant store-level mutation authority.

---

## 17. Store-Scoped Table Constraint

Store-scoped tables must include tenant_id and store_id.

Store-scoped tables may include:

- waiting sessions
- table sessions
- store orders
- POS handoff records
- KDS tickets
- store devices
- staff assignments
- incident records
- local agent records
- degraded recovery records
- store-level support cases
- store-level audit events

Access must validate both tenant and store context.

---

## 18. Actor-Owned Data Constraint

Actor-owned data is data primarily owned by a specific user or customer.

Examples may include:

- customer profile
- customer order history
- customer waiting history
- staff self-view records
- owner account settings

Actor-owned access must still respect tenant/store relationship when operational data is involved.

A customer viewing an order must not access another customer's order through store context alone.

---

## 19. Sensitive Identity Data Constraint

Sensitive identity data includes:

- CI
- DI
- identity provider reference
- verified identity linkage
- full phone number
- full email where sensitive
- account linkage key
- payment identity reference

Sensitive identity data must not be broadly readable.

Access requires explicit purpose, authority, masking, audit, and retention rule.

---

## 20. Payment-Sensitive Data Constraint

Payment-sensitive data includes:

- payment provider reference
- payment status
- refund status
- settlement reference
- reconciliation record
- payment failure reason
- payment audit linkage
- provider callback reference

Payment-sensitive data requires payment authority or approved visibility.

KDS, AI, and normal support view must not gain payment mutation authority.

---

## 21. Support-Scoped Access Constraint

Support access must be case-scoped.

Support access requires:

- support_case_id
- assigned or authorized support actor
- tenant scope
- store scope where applicable
- purpose
- time limit
- masking rule
- audit event
- escalation path for unmasking
- break-glass rule where applicable

Support access must not become permanent admin access.

---

## 22. HQ Access Constraint

HQ access may be broader than store access but must remain scoped.

HQ access should be constrained by:

- tenant
- role
- department
- responsibility
- approval
- action type
- data category
- audit requirement

HQ staff should not automatically access raw CI / DI, payment secrets, or unrestricted exports.

---

## 23. Owner Access Constraint

Owner access should be scoped to stores or business entities they are authorized to manage.

Owner access may include:

- store dashboard
- order summaries
- sales summaries
- staff operational visibility
- incident visibility
- settlement summary
- export request where allowed

Owner access must not automatically include:

- raw CI / DI
- full support notes
- unrestricted staff private data
- payment secrets
- cross-tenant data
- unrelated store data

---

## 24. Staff Access Constraint

Staff access should be limited to operational needs.

Staff may see:

- assigned store operational screen
- current waiting/order information
- KDS task information where role permits
- table status where needed
- masked customer information where needed
- task and incident instructions

Staff must not access:

- raw CI / DI
- payment provider secrets
- unrestricted customer history
- other stores without assignment
- owner-level reports
- support-only notes
- audit internals unless permitted

---

## 25. Customer Access Constraint

Customer access should be limited to their own session, account, orders, waiting, payment, membership, and related public store information.

Customer must not access:

- another customer session
- another table session unless explicitly joined
- store internal notes
- POS/KDS internal diagnostics
- staff data
- audit logs
- support internal notes
- tenant configuration
- payment provider details

Customer access must be validated server-side.

---

## 26. Service Identity Constraint

Service identities include POS, KDS, bridge, local agent, webhook handler, and background job identities.

Service identity access must be:

- narrowly scoped
- purpose-specific
- tenant/store-bound where applicable
- environment-bound
- auditable
- revocable
- separated from human authority

Service identity must not use broad administrator authority unless strictly required and server-contained.

---

## 27. Cross-Tenant Denial Rule

Any request attempting to access a different tenant without explicit authorized cross-tenant support or HQ scope must be denied.

Cross-tenant denial applies to:

- read
- create
- update
- delete
- export
- support view
- analytics query
- AI dataset inclusion
- POS/KDS event processing
- payment lookup
- audit lookup

Cross-tenant access is high-risk and must be audited if allowed under exceptional scope.

---

## 28. Cross-Store Denial Rule

Any request attempting to access a different store without valid role, assignment, ownership, support case, HQ scope, or approved service scope must be denied.

Cross-store denial applies to:

- waiting data
- order data
- POS event
- KDS ticket
- staff assignment
- device session
- support case
- local agent data
- payment record
- incident record
- export
- audit lookup

Store boundary must not depend on UI selection alone.

---

## 29. Context Mismatch Handling

If context mismatch is detected, system should:

- deny the action
- return safe error
- avoid revealing whether target tenant/store exists
- create audit event for high-risk attempts
- create security event when suspicious
- avoid returning partial data
- avoid fallback to broader query
- avoid auto-correction to another context

Context mismatch must not be silently repaired.

---

## 30. Safe Error Mapping

Safe error messages should avoid revealing sensitive structure.

Unsafe:

- "Store 123 exists but you do not belong to tenant 456."
- "Customer CI does not match."
- "Payment provider reference belongs to another tenant."

Safer:

- "Access denied."
- "Requested resource is unavailable."
- "Action cannot be completed in the current context."
- "Please refresh and try again."

Internal diagnostics may record more detail with masking.

---

## 31. Audit Mapping

Access control decisions should create audit events for high-risk cases.

Audit may be required for:

- denied cross-tenant attempt
- denied cross-store attempt
- support case access
- unmasking
- export request
- payment-sensitive access
- CI / DI-sensitive access
- role change
- device trust change
- break-glass access
- service identity use
- suspicious repeated denial
- RLS bypass function use

Audit event must include tenant/store context where safe.

---

## 32. Masking Mapping

Masked views may be required for:

- customer phone
- customer email
- customer identity linkage
- payment reference
- refund reference
- support notes
- staff private information
- incident details
- audit fields
- export preview
- AI dataset preparation

Masking must be enforced server-side for sensitive contexts.

---

## 33. Export Access Mapping

Export authority must be separate from view authority.

A user who can view a dashboard may not automatically export:

- raw data
- customer list
- payment records
- support records
- audit logs
- CI / DI-linked data
- staff private data
- cross-store reports
- cross-tenant reports

Export must have purpose, scope, audit, masking, and retention mapping.

---

## 34. AI Dataset Access Mapping

AI dataset access must be scoped.

AI dataset preparation must validate:

- tenant scope
- store scope
- data minimization
- masking
- exclusion of secrets
- exclusion of raw CI / DI
- exclusion of payment secrets
- support note filtering
- approval where needed
- audit record

AI must not become a shortcut around RLS or export controls.

---

## 35. Local Agent Context Mapping

Local agent records must include tenant/store context.

Local agent access must distinguish:

- Primary local agent
- Secondary local agent
- Promoted Primary
- Recovery Pending
- central verified state
- local provisional state

Local agent must not write across store boundary.

Secondary agent must not overwrite Primary-derived state.

Central verification remains final for reconciliation.

---

## 36. POS/KDS Context Mapping

POS/KDS events must include tenant/store context.

POS/KDS mapping must validate:

- POS terminal belongs to store
- KDS device belongs to store
- bridge is authorized for tenant/store
- ticket belongs to same store as order
- payment reference belongs to same tenant/store context
- replay event belongs to same event lineage
- retry does not cross context

POS/KDS integration must never trust payload context without verification.

---

## 37. Payment Context Mapping

Payment records must include tenant/store/order context.

Payment mapping must validate:

- payment belongs to same tenant
- payment belongs to same store where applicable
- order belongs to same store
- refund belongs to original payment
- webhook provider event maps to expected tenant/store
- support actor has payment view authority
- KDS cannot mutate payment state

Payment context mismatch must trigger review or denial.

---

## 38. Session Context Mapping

Session must carry enough information to validate access.

Session may include:

- actor_id
- actor role
- tenant scope
- store scope
- device id
- runtime type
- authentication time
- reauthentication status
- support case scope
- break-glass status
- expiration

Sensitive actions may require fresh reauthentication.

---

## 39. Device Context Mapping

Device trust affects access.

Device context may include:

- device_id
- device_role
- tenant_id
- store_id
- trust_state
- last_seen_at
- registered_by
- approved_by
- revoked_at
- lost_or_compromised flag
- session binding

A trusted user on an untrusted device may still be restricted.

---

## 40. Degraded Mode Access Mapping

During degraded mode, access must remain scoped.

Degraded mode does not allow:

- cross-tenant access
- cross-store access
- broad support access
- payment truth mutation
- raw CI / DI exposure
- unrestricted export
- audit bypass
- silent merge

Fallback-originated records must preserve tenant/store context.

---

## 41. RLS Bypass Function Constraint

Some server-side functions may require elevated privileges.

Elevated function design must include:

- narrow purpose
- strict input validation
- tenant/store context validation
- actor authority validation
- audit event
- masking
- safe errors
- no broad arbitrary query
- no uncontrolled dynamic SQL
- no direct exposure to frontend if unsafe

RLS bypass must be exceptional and controlled.

---

## 42. Implementation Blockers

Implementation must be blocked if:

- tenant model is unclear
- store model is unclear
- tenant/store fields are missing from store-scoped tables
- role/affiliation mapping is unclear
- support scope is undefined
- RLS deny-by-default is not planned
- payment records cannot be context-validated
- POS/KDS events cannot be context-validated
- local agent records lack store context
- export authority is not separate
- AI dataset access bypasses masking
- audit mapping is missing for sensitive access
- cross-tenant denial cannot be tested
- cross-store denial cannot be tested

These blockers must be added to the implementation blocker register.

---

## 43. Testing Requirements

Future tests must include:

- tenant A cannot read tenant B data
- tenant A cannot write tenant B data
- store A cannot read store B data without authority
- store staff cannot access unrelated store
- customer cannot access another customer order
- owner cannot access unrelated tenant
- support cannot access without case scope
- support access is audited
- export requires separate authority
- AI dataset excludes raw CI / DI
- KDS cannot access payment mutation
- POS/KDS event with wrong store is rejected
- local agent wrong-store sync is rejected
- revoked device loses access
- context mismatch returns safe error

Testing must include abuse cases, not only expected use.

---

## 44. Evidence Requirements

Evidence should prove:

- RLS deny-by-default exists
- tenant isolation tests passed
- store isolation tests passed
- support scope tests passed
- export authority tests passed
- AI dataset scope tests passed
- POS/KDS context tests passed
- payment context tests passed
- device trust tests passed
- audit events are created for high-risk access
- denied access does not leak sensitive context

Evidence must be stored without raw secrets or unnecessary raw identity.

---

## 45. Mapping Status

Recommended status for this mapping:

- `DRAFT`
- `POLICY_LINKED`
- `RUNTIME_DEFINED`
- `DATA_CLASSIFIED`
- `AUTHORITY_MAPPED`
- `CONTEXT_MAPPED`
- `AUDIT_MAPPED`
- `MASKING_MAPPED`
- `TEST_MAPPED`
- `BLOCKED`
- `READY_FOR_REVIEW`
- `READY_FOR_IMPLEMENTATION`

This document starts as `DRAFT`.

It becomes implementation-ready only after schema, RLS, API, and test catalogs are later mapped in more detail.

---

## 46. Non-Goals

This document does not define:

- final tenant table
- final store table
- final role table
- final affiliation table
- final SQL migration
- final RLS policy
- final RPC function
- final API endpoint
- final Flutter UI
- final Supabase implementation
- final production deployment
- final automated test code

Those belong to later implementation documents and controlled implementation phase.

---

## 47. Readiness Check

This mapping is ready when the project can answer:

1. What is tenant context?
2. What is store context?
3. What context axes exist besides tenant and store?
4. Which runtimes are affected?
5. Which data categories are tenant-scoped?
6. Which data categories are store-scoped?
7. Which data categories are sensitive?
8. What actor categories exist?
9. How are role and affiliation mapped?
10. What inputs determine access control?
11. What does deny-by-default mean for RLS?
12. Which tables require tenant_id?
13. Which tables require tenant_id and store_id?
14. How is support access scoped?
15. How is owner access scoped?
16. How is staff access scoped?
17. How is customer access scoped?
18. How are service identities scoped?
19. How are cross-tenant attempts denied?
20. How are cross-store attempts denied?
21. What safe errors are returned?
22. What audit events are required?
23. What masking applies?
24. How is export authority separated?
25. How is AI dataset access scoped?
26. How is local agent context validated?
27. How is POS/KDS context validated?
28. How is payment context validated?
29. How does device trust affect access?
30. What tests prove tenant/store isolation?

If these questions cannot be answered, tenant/store access control mapping is incomplete.

---

## 48. Conclusion

Tenant/store context is the foundation of SaaS security for the Yoonsul Wait/Order Handoff project.

The system must preserve the following rules:

- tenant/store isolation is server-side
- UI filtering is not security
- tenant and store are different contexts
- company, legal entity, and operating group are separate axes
- role and affiliation must be scoped
- service identities must be narrow
- support access must be case-scoped
- owner access must not become unrestricted access
- staff access must follow operational need
- customer access must be self-scoped
- cross-tenant access is denied by default
- cross-store access is denied by default
- context mismatch returns safe errors
- sensitive access is audited
- masking is enforced server-side
- export authority is separate
- AI dataset access is minimized
- POS/KDS/payment/local agent events must validate context
- degraded mode is not security bypass
- RLS bypass must be exceptional and controlled
- implementation is blocked until context mapping is testable

This mapping does not implement RLS or access control.

It defines the constraints that future RLS and access control implementation must obey.