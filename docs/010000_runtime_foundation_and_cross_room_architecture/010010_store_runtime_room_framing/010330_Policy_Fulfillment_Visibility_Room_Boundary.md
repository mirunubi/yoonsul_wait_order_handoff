# 010330_Policy_Fulfillment_Visibility_Room_Boundary

## 1. Purpose

This document defines the Fulfillment Visibility Room Boundary Policy.

The previous artifact `10320` defined the Operational Evidence Room Boundary Policy.

This document frames the thirteenth Side B room:

`Fulfillment Visibility Room`

The purpose is to define the boundary where order, kitchen, POS, KDS, device, fallback, degraded operation, incident, and recovery-related states may be safely projected to customers, staff, owner/admin, support/admin, and Franchise OS views without exposing raw evidence, financial truth, provider payloads, staff-only notes, cross-tenant data, or unauthorized operational authority.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Fulfillment Visibility Room governs what each audience may safely see about fulfillment progress.

It may later coordinate:

- customer-safe order status
- staff-visible operational status
- kitchen-visible task status
- owner/admin visibility
- support/admin visibility
- Franchise OS visibility
- degraded operation visibility
- fallback visibility
- incident visibility
- recovery review visibility
- evidence-linked visibility
- i18n message projection
- masking and scope enforcement

Visibility is not authority.

Projection is not source of truth.

---

## 3. Core Principle

Fulfillment visibility is safe projection, not truth ownership.

The correct rule is:

Visible status is not source of truth.  
Customer-facing status is not raw state.  
Staff-visible status is not mutation authority.  
Admin visibility is not unrestricted access.  
Support visibility is not ownership.  
Projection is not evidence mutation.  
KDS completed is not settlement.  
Kitchen ready is not payment confirmed.  
Incident visible is not incident resolved.  
Recovery visible is not compensation executed.  

Fulfillment visibility must be scoped, audience-safe, tenant/store isolated, i18n-controlled, and evidence-linked.

---

## 4. Scope

The Fulfillment Visibility Room may define planning boundaries for:

- customer order status
- waiting/seating status if applicable
- order validation visibility
- POS handoff visibility
- KDS ticket visibility
- kitchen execution visibility
- staff assist visibility
- device/peripheral visibility
- degraded mode visibility
- manual fallback visibility
- incident visibility
- recovery review visibility
- support/admin visibility
- Franchise OS aggregate visibility
- Safe Projection rules
- i18n message rules
- tenant/store isolation

This room does not implement visibility runtime.

---

## 5. Audience Catalog

Recommended audience catalog:

| Audience | Meaning |
|---|---|
| `CUSTOMER` | End customer/customer session |
| `STORE_STAFF` | Store staff member |
| `KITCHEN_STAFF` | Kitchen operator |
| `SHIFT_LEAD` | Shift lead or store lead |
| `STORE_MANAGER` | Store manager |
| `OWNER_ADMIN` | Owner/admin user |
| `SUPPORT_ADMIN` | Support operator |
| `FINANCE_ADMIN` | Financial review user |
| `HQ_ADMIN` | HQ authorized user |
| `FRANCHISE_OS_ADMIN` | Franchise OS governed admin |
| `SYSTEM_OBSERVER` | Internal system/read model observer |

Audience does not imply authority.

Each audience requires scope.

---

## 6. Visibility Scope Boundary

Every visibility projection must define:

| Scope Field | Meaning |
|---|---|
| `tenant_id` | Tenant scope |
| `store_id` | Store scope if applicable |
| `audience_type` | Target audience |
| `role_id` | Role context |
| `surface_id` | Surface context |
| `device_id` | Device context if applicable |
| `session_id` | Customer/session context if applicable |
| `projection_type` | Type of projected status |
| `masking_class` | Masking requirement |
| `i18n_key` | Message key if human-visible |
| `source_reference` | Evidence/source reference |
| `audit_reference` | Audit reference if required |

Missing scope means projection must fail closed.

---

## 7. Tenant And Store Isolation Boundary

Fulfillment visibility is a high-risk tenant isolation surface.

A Store A fulfillment status must never appear in Store B view.

A Tenant A fulfillment status must never appear in Tenant B view.

Visibility must fail closed when:

- tenant context is missing
- store context is missing where required
- audience is unresolved
- session is unresolved where required
- role is unauthorized
- masking class is unresolved
- projection source is cross-tenant
- evidence source is unscoped
- support/admin case scope is missing

Default:

`CROSS_TENANT_ACCESS_DENIED`

Fulfillment Visibility Room must follow `10141`.

---

## 8. Fulfillment Visibility State Skeleton

Recommended visibility states:

| State | Meaning |
|---|---|
| `VISIBILITY_NOT_AVAILABLE` | No status available |
| `VISIBILITY_PENDING` | Status pending |
| `VISIBILITY_SAFE_TO_SHOW` | Safe projection available |
| `VISIBILITY_MASKING_REQUIRED` | Masking required |
| `VISIBILITY_STAFF_ONLY` | Staff-only visibility |
| `VISIBILITY_ADMIN_ONLY` | Admin-only visibility |
| `VISIBILITY_SUPPORT_ONLY` | Support-only visibility |
| `VISIBILITY_BLOCKED_BY_SCOPE` | Scope blocks projection |
| `VISIBILITY_BLOCKED_BY_POLICY` | Policy blocks projection |
| `VISIBILITY_DEGRADED_MESSAGE_REQUIRED` | Degraded safe message required |
| `VISIBILITY_FALLBACK_MESSAGE_REQUIRED` | Fallback safe message required |
| `VISIBILITY_INCIDENT_MESSAGE_REQUIRED` | Incident safe message required |
| `VISIBILITY_RECOVERY_REVIEW_MESSAGE_REQUIRED` | Recovery review safe message required |
| `VISIBILITY_UNKNOWN` | Visibility state uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 9. Customer Visibility Boundary

Customer visibility may include:

- menu/order intake guidance
- order is being checked
- staff assistance required
- order could not proceed
- order is being prepared
- order is delayed
- order is ready if allowed
- payment status is being checked
- service is temporarily limited
- please ask staff
- recovery/support review in progress if allowed

Customer visibility must not include:

- raw POS state
- raw KDS state
- raw payment provider state
- internal station details
- staff-only kitchen note
- support/admin note
- financial uncertainty details beyond safe wording
- incident root cause
- provider blame
- compensation promise without authority
- cross-tenant/store data
- AI reasoning
- vector similarity

Customer visibility must use Safe Projection and i18n keys.

---

## 10. Staff Visibility Boundary

Store staff visibility may include:

- order status category
- validation issue category
- staff assist reason
- POS/KDS safe status category
- kitchen preparation state
- delay/remake/sold-out marker
- device/peripheral issue
- fallback marker
- incident marker
- recovery review marker
- customer-safe message suggestion

Staff visibility must not include:

- unrestricted financial data
- raw payment payload
- provider credentials
- cross-store data without authority
- unmasked sensitive customer data
- unrelated support/admin notes
- AI reasoning as fact

Staff visibility supports operation.

It does not grant authority.

---

## 11. Kitchen Visibility Boundary

Kitchen visibility may include:

- ticket/task details
- station routing
- item/options
- kitchen note
- allergen/safety caution
- delay/remake marker
- sold-out marker
- manual fallback marker
- preparation priority

Kitchen visibility must not include:

- payment payload
- refund/compensation detail
- settlement state
- unrelated customer personal data
- unrelated incident notes
- cross-store tickets
- provider credentials

Kitchen visibility is operational.

It is not financial authority.

---

## 12. Owner/Admin Visibility Boundary

Owner/Admin visibility may include:

- store-level order status summary
- operational queue status
- degraded operation status
- incident summary
- device/peripheral status
- fallback summary
- recovery review summary
- store performance read model if later authorized

Owner/Admin visibility must be store/tenant scoped.

Owner/Admin visibility must not become unrestricted cross-tenant access.

Visibility is not mutation permission.

---

## 13. Support/Admin Visibility Boundary

Support/Admin visibility may include:

- masked customer/order context
- safe provider status category
- incident timeline
- evidence packet reference
- degraded/fallback state
- reconciliation status
- recovery review status
- device/provider context if authorized

Support/Admin visibility must require:

- role authorization
- purpose/case context
- tenant/store scope
- masking
- audit

Support/Admin visibility is not ownership.

Support/Admin visibility is not automatic mutation authority.

---

## 14. Finance Admin Visibility Boundary

Finance Admin visibility may include financial review context only when authorized.

It may include:

- payment review status
- refund review status
- coupon/point/wallet reference
- settlement reference
- reconciliation marker
- incident/recovery reference

Finance Admin visibility must not expose unrelated operational data beyond need.

Finance Admin visibility does not belong to Store Runtime authority by default.

Financial action remains Side C.

---

## 15. Franchise OS Visibility Boundary

Franchise OS visibility must be governed by scope.

Possible scopes:

- single store
- store group
- brand
- operating group
- legal entity
- tenant
- anonymized platform aggregate

Franchise OS must not show another tenant/store’s fulfillment state unless explicitly authorized by governance.

Aggregate visibility must be masked, thresholded, and policy-reviewed.

---

## 16. POS Visibility Boundary

POS-related visibility may show:

- POS handoff pending
- POS handoff accepted if verified within POS boundary
- POS handoff failed
- POS status uncertain
- POS degraded
- staff assistance required
- reconciliation required

POS visibility must not show:

- raw POS provider payload
- provider credentials
- payment confirmation
- settlement confirmation
- provider blame
- cross-store POS state

POS accepted is not payment confirmed.

---

## 17. KDS Visibility Boundary

KDS-related visibility may show:

- ticket pending
- ticket accepted
- kitchen preparing
- delayed
- remake required
- ready if allowed
- KDS unavailable
- manual kitchen fallback active

KDS visibility must not show:

- raw KDS provider payload
- internal provider error
- payment confirmation
- settlement state
- unrestricted station detail to customer
- cross-store KDS ticket

KDS completed is not settlement.

---

## 18. Kitchen Visibility To Customer Boundary

Customer-facing kitchen visibility should be coarse and safe.

Allowed examples:

- preparing
- delayed
- checking
- ready
- unavailable
- staff assistance required

Avoid showing:

- station name
- staff name
- staff note
- internal delay reason
- blame
- allergen medical conclusion
- compensation promise
- raw incident detail

Customer-facing kitchen visibility must be calm and non-blaming.

---

## 19. Degraded Operation Visibility Boundary

When degraded operation is active, visibility may show:

- service temporarily limited
- staff assistance required
- order status being checked
- payment temporarily unavailable
- kitchen status being checked
- please ask staff

It must not show:

- raw provider outage detail
- security containment detail
- payment uncertainty details
- internal degraded rules
- cross-tenant impact
- AI reasoning
- vector similarity

Degraded visibility must not normalize degraded operation.

---

## 20. Manual Fallback Visibility Boundary

Manual fallback visibility may show:

- staff is handling the order manually
- order is being checked by staff
- kitchen is checking your order
- system status is temporarily unavailable
- please ask staff

Manual fallback visibility must not show:

- manual notes directly
- staff-only comments
- payment uncertainty details
- raw failure cause
- compensation promise
- legal conclusion
- cross-store data

Manual fallback must remain visible enough for safety but not expose raw records.

---

## 21. Incident Visibility Boundary

Incident visibility must be audience-specific.

Customer may see only safe service status.

Staff may see operational issue category.

Support/Admin may see incident timeline and evidence references if authorized.

Incident visibility must not:

- reveal raw root cause before review
- blame provider/staff/customer without evidence
- expose security containment detail
- expose financial payload
- expose cross-tenant data
- promise recovery outcome

Incident visible is not incident resolved.

---

## 22. Recovery Visibility Boundary

Recovery visibility may show:

- recovery review required
- recovery review in progress
- support reviewing
- staff follow-up required
- financial review required if authorized
- recovery action completed if verified

Recovery visibility must not show:

- compensation promise before approval
- refund promise before execution
- wallet/point mutation before verified
- legal conclusion
- raw dispute note
- cross-tenant/store information

Recovery review is not compensation.

---

## 23. Evidence Visibility Boundary

Fulfillment Visibility may reference evidence but must not expose raw evidence by default.

Evidence projection must respect:

- tenant/store scope
- audience
- role
- masking class
- source classification
- incident/recovery relation
- export restrictions
- audit requirement

Projection does not mutate evidence.

Visibility is not evidence ownership.

---

## 24. i18n Boundary

All human-visible fulfillment messages must use i18n keys.

Hardcoded operational messages are prohibited.

Required i18n categories may include:

- order pending
- validation failed
- staff assist required
- POS pending/failed/uncertain
- KDS preparing/delayed
- kitchen ready/delayed
- payment checking/unavailable
- degraded operation
- manual fallback
- incident review
- recovery review
- ask staff
- try again later

Missing i18n key should trigger safe fallback or block projection.

---

## 25. Masking Boundary

Visibility may require masking for:

- customer identity
- phone/email/name
- payment reference
- provider reference
- staff note
- device id
- incident detail
- recovery note
- allergen/safety note
- security containment detail

Masking controls visibility.

Masking does not alter source truth.

---

## 26. Projection Source Boundary

Fulfillment projection may derive from:

- order intake state
- validation state
- POS handoff state
- KDS ticket state
- kitchen execution state
- device/peripheral state
- degraded operation state
- manual fallback state
- incident state
- evidence packet
- recovery route state
- financial trust reference if authorized

Projection must not invent state.

Projection must not merge conflicting states silently.

---

## 27. Conflict Visibility Boundary

When source states conflict, visibility must be conservative.

Examples:

- POS accepted but payment unknown
- KDS completed but kitchen says remake required
- device says printed but KDS unknown
- staff note says served but customer disputes
- manual fallback says completed but payment uncertain
- provider callback delayed after timeout

Conflict should project:

- status being checked
- staff assistance required
- reconciliation required
- support review if authorized

Conflict must not project false certainty.

---

## 28. Relationship To Operational Evidence Room

Operational Evidence Room preserves evidence.

Fulfillment Visibility Room projects safe status.

Evidence may inform projection.

Projection must not reveal raw evidence unless audience and policy allow.

Evidence is not approval.

Visibility is not evidence mutation.

---

## 29. Relationship To Store Recovery Route Room

Fulfillment Visibility may show recovery review status.

Recovery Route determines review process.

Visibility must not execute recovery.

Visibility must not promise compensation.

---

## 30. Relationship To Financial Trust

Fulfillment Visibility must defer financial truth to Side C.

Fulfillment Visibility must not:

- confirm payment without verified financial state
- confirm refund without verified execution
- show coupon/point/wallet mutation before verified
- confirm settlement
- approve compensation
- expose financial payload

Financial projection requires Financial Trust source.

---

## 31. Relationship To Data Governance

Fulfillment Visibility uses Side D for:

- i18n messages
- Safe Projection policy
- masking policy
- audience visibility policy
- support/admin visibility policy
- CMS message reference if applicable
- AI summary if later authorized
- pgvector related context if later authorized
- analytics/read model if later authorized

Data Governance controls visibility rules.

Fulfillment Visibility applies them.

---

## 32. Fulfillment Visibility Anti-Patterns

Avoid:

- visible status treated as source of truth
- customer status showing raw provider state
- KDS completed shown as payment/settlement
- kitchen ready shown while payment unknown without policy
- staff-only note shown to customer
- support/admin view showing all tenants by default
- incident visible treated as resolved
- recovery review shown as compensation approved
- conflicting states merged into false certainty
- missing i18n key replaced with unsafe hardcoded message
- projection leaking cross-store data
- AI summary shown as fact
- pgvector similarity shown as proof

These anti-patterns must be blocked in future runtime design.

---

## 33. Runtime Deferral

This document defines the Fulfillment Visibility Room boundary only.

It does not authorize:

- visibility API
- customer status runtime
- staff status runtime
- admin/support dashboard
- Franchise OS visibility runtime
- projection engine
- masking engine
- i18n runtime
- database schema
- AI runtime
- pgvector runtime
- production deployment

All runtime remains deferred.

---

## 34. Validation Checklist

Validation must confirm:

1. Fulfillment Visibility Room definition is clear.
2. Visibility is safe projection, not truth ownership.
3. Audience catalog is defined.
4. Visibility scope boundary is defined.
5. Tenant/store isolation is defined.
6. Visibility state skeleton is defined.
7. Customer visibility boundary is defined.
8. Staff visibility boundary is defined.
9. Kitchen visibility boundary is defined.
10. Owner/Admin visibility boundary is defined.
11. Support/Admin visibility boundary is defined.
12. Finance Admin visibility boundary is defined.
13. Franchise OS visibility boundary is defined.
14. POS visibility boundary is defined.
15. KDS visibility boundary is defined.
16. Kitchen-to-customer visibility boundary is defined.
17. Degraded operation visibility boundary is defined.
18. Manual fallback visibility boundary is defined.
19. Incident visibility boundary is defined.
20. Recovery visibility boundary is defined.
21. Evidence visibility boundary is defined.
22. i18n boundary is defined.
23. Masking boundary is defined.
24. Projection source boundary is defined.
25. Conflict visibility boundary is defined.
26. Relationships to related rooms are defined.
27. Financial Trust separation is defined.
28. Data Governance relationship is defined.
29. Anti-patterns are listed.
30. Coding remains unauthorized.
31. Runtime remains deferred.

---

## 35. Relationship To Previous Documents

This document follows:

- `10320 Operational Evidence Room Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10200 Store Room Framing And Runtime Domain Boundary Index`
- `10110 Store Runtime POS KDS Kitchen Execution Skeleton Policy`
- `10120 Payment Settlement Refund Wallet Financial Trust Skeleton Policy`
- `10130 CMS i18n AI pgvector Data Governance Skeleton Policy`
- `10140 Cross-Axis Authority Evidence Audit And Fallback Beam Policy`
- `10150 Four-Side Skeleton Closure And Runtime Deferral Policy`
- `10310 Store Incident Room Boundary Policy`
- `10320 Operational Evidence Room Boundary Policy`

It prepares:

- `10340 Store Recovery Route Room Boundary Policy`
- future fulfillment visibility static specification packet
- future customer-safe projection catalog
- future staff/admin visibility matrix

This document is room boundary planning only.

It does not authorize coding.

---

## 36. Final Rule

The Fulfillment Visibility Room governs audience-safe projection of fulfillment state.

Visible status is not source of truth.

Customer-facing status is not raw state.

Staff-visible status is not mutation authority.

Admin visibility is not unrestricted access.

Projection is not evidence mutation.

KDS completed is not settlement.

Kitchen ready is not payment confirmed.

Incident visible is not incident resolved.

Recovery visible is not compensation executed.

Fulfillment Visibility must preserve tenant/store isolation, audience scope, masking, i18n, Safe Projection, evidence linkage, conflict caution, incident separation, recovery separation, and financial/provider boundary separation.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
