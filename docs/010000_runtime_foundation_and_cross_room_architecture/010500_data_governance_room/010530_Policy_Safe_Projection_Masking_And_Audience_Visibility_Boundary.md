# 010530_Policy_Safe_Projection_Masking_And_Audience_Visibility_Boundary.md

## Purpose

This document defines the Safe Projection, Masking, and Audience Visibility Boundary Policy.

The previous artifact `10520` defined the i18n Message Key and Human Visible Text Boundary Policy.

This document frames the third Data Governance room:

`Safe Projection Masking And Audience Visibility Room`

The purpose is to define the boundary where source data, operational state, financial state, provider evidence, incident data, recovery data, CMS content, i18n text, AI outputs, pgvector retrievals, analytics, and admin/support views are transformed into audience-safe projections without exposing raw source truth, cross-tenant data, sensitive financial data, security detail, staff-only notes, provider payloads, or unauthorized authority.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The Safe Projection, Masking, and Audience Visibility Room governs what each audience may see.

It may later coordinate:

- source data classification
- audience classification
- projection type
- masking class
- redaction rule
- tenant/store/legal scope
- customer/account scope
- staff/admin role scope
- financial visibility scope
- incident/recovery visibility
- provider evidence masking
- AI output visibility
- pgvector source visibility
- analytics/read model visibility
- export preview visibility
- access audit

Projection is not source truth.

Visibility is not authority.

---

## 3. Core Principle

A view is not authority.

The correct rule is:

Projection is not source of truth.  
Visibility is not mutation authority.  
Masked data is not source mutation.  
Admin view is not approval authority.  
Support view is not ownership.  
Customer-safe message is not full case detail.  
Staff-safe status is not financial truth.  
Analytics view is not operational truth.  
AI summary is not decision authority.  
pgvector retrieved context is not proof.  

Every projection must be audience-scoped, tenant-scoped, store-scoped, masked, i18n-controlled, auditable where needed, and fail-closed.

---

## 4. Scope

This room may define planning boundaries for:

- customer-safe projection
- kiosk-safe projection
- staff-safe projection
- kitchen-safe projection
- manager-safe projection
- owner/admin projection
- support/admin projection
- finance/admin projection
- HQ admin projection
- Franchise OS projection
- legal/compliance projection
- security-restricted projection
- masking and redaction
- source classification
- projection evidence
- access audit
- tenant/store/legal isolation

This room does not implement projection runtime.

---

## 5. Projection Type Catalog

Recommended projection type catalog:

| Projection Type | Meaning |
|---|---|
| `CUSTOMER_SAFE_PROJECTION` | Customer-facing view |
| `KIOSK_SAFE_PROJECTION` | Kiosk customer-facing view |
| `STAFF_SAFE_PROJECTION` | Store staff operational view |
| `KITCHEN_SAFE_PROJECTION` | KDS/kitchen-safe view |
| `MANAGER_REVIEW_PROJECTION` | Manager review view |
| `OWNER_ADMIN_SUMMARY_PROJECTION` | Store owner/admin summary |
| `SUPPORT_ADMIN_MASKED_PROJECTION` | Support-safe masked view |
| `FINANCE_ADMIN_DETAIL_PROJECTION` | Finance detail view |
| `HQ_ADMIN_GOVERNANCE_PROJECTION` | HQ governance view |
| `FRANCHISE_OS_AGGREGATE_PROJECTION` | Franchise OS aggregate view |
| `LEGAL_COMPLIANCE_PROJECTION` | Legal/compliance review view |
| `SECURITY_RESTRICTED_PROJECTION` | Security-restricted view |
| `EXPORT_PREVIEW_PROJECTION` | Export review preview |
| `AI_REVIEW_PROJECTION` | AI-assisted review view |
| `ANALYTICS_READ_MODEL_PROJECTION` | Analytics/read model view |

Projection type determines visibility, masking, and audit.

---

## 6. Projection State Skeleton

Recommended projection states:

| State | Meaning |
|---|---|
| `PROJECTION_NOT_CREATED` | No projection exists |
| `PROJECTION_CANDIDATE` | Projection candidate prepared |
| `PROJECTION_SCOPE_REVIEW_REQUIRED` | Scope review required |
| `PROJECTION_MASKING_REQUIRED` | Masking required |
| `PROJECTION_ALLOWED` | Projection allowed |
| `PROJECTION_BLOCKED` | Projection blocked |
| `PROJECTION_STALE` | Projection stale |
| `PROJECTION_REQUIRES_REFRESH` | Refresh required |
| `PROJECTION_CONFLICT_DETECTED` | Source conflict detected |
| `PROJECTION_CONTAINMENT_REQUIRED` | Containment required |
| `PROJECTION_EXPORTED` | Exported under approved flow |
| `PROJECTION_REVOKED` | Projection revoked |
| `PROJECTION_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 7. Audience Class Boundary

Audience class must be explicit.

Recommended audience classes:

| Audience | Visibility Boundary |
|---|---|
| `CUSTOMER` | Only customer-safe status and own account context |
| `KIOSK_CUSTOMER` | Customer-safe kiosk context |
| `STORE_STAFF` | Operationally necessary store-scoped data |
| `KITCHEN_STAFF` | Kitchen execution data only |
| `MANAGER` | Store review data within authority |
| `OWNER_ADMIN` | Store/tenant admin summary within scope |
| `SUPPORT_ADMIN` | Masked support view within purpose |
| `FINANCE_ADMIN` | Financial detail within finance scope |
| `HQ_ADMIN` | HQ governance view within role scope |
| `FRANCHISE_ADMIN` | Franchise OS aggregate/scoped view |
| `LEGAL_COMPLIANCE` | Legal/compliance review view |
| `SECURITY_ADMIN` | Security-restricted review view |
| `AI_ASSISTED_REVIEWER` | AI output with source and uncertainty |
| `EXPORT_REVIEWER` | Export preview and approval view |

Audience class must not be inferred from login alone.

Role, scope, purpose, and data class must be checked.

---

## 8. Source Data Classification Boundary

Projection requires source classification.

Recommended source classes:

| Source Class | Meaning |
|---|---|
| `OPERATIONAL_PUBLIC_SAFE` | Safe operational display data |
| `CUSTOMER_ACCOUNT_DATA` | Customer account scoped data |
| `ORDER_OPERATIONAL_DATA` | Order operational data |
| `KITCHEN_EXECUTION_DATA` | KDS/kitchen data |
| `STAFF_OPERATIONAL_DATA` | Staff operational data |
| `INCIDENT_DATA` | Incident/recovery data |
| `FINANCIAL_DATA` | Financial trust data |
| `SETTLEMENT_DATA` | Settlement/payout data |
| `PROVIDER_EVIDENCE_DATA` | Provider payload/evidence |
| `SECURITY_DATA` | Security/containment data |
| `LEGAL_COMPLIANCE_DATA` | Legal/compliance data |
| `CMS_CONTENT_DATA` | CMS publication data |
| `I18N_MESSAGE_DATA` | i18n message data |
| `AI_OUTPUT_DATA` | AI output data |
| `VECTOR_SOURCE_DATA` | pgvector source data |
| `ANALYTICS_DATA` | Analytics/read model data |

Unclassified source data must fail closed.

---

## 9. Masking Class Boundary

Recommended masking classes:

| Masking Class | Meaning |
|---|---|
| `NO_MASKING_REQUIRED` | Safe for intended audience |
| `CUSTOMER_ID_MASKED` | Customer identity masked |
| `STAFF_ID_MASKED` | Staff identity masked |
| `PAYMENT_REFERENCE_MASKED` | Payment reference masked |
| `PROVIDER_PAYLOAD_REDACTED` | Provider payload redacted |
| `FINANCIAL_AMOUNT_SUMMARIZED` | Financial amount summarized |
| `SETTLEMENT_DETAIL_RESTRICTED` | Settlement detail hidden |
| `INCIDENT_DETAIL_SUMMARIZED` | Incident details summarized |
| `SECURITY_DETAIL_REDACTED` | Security details redacted |
| `LEGAL_DETAIL_RESTRICTED` | Legal/compliance detail hidden |
| `AI_OUTPUT_REVIEW_ONLY` | AI output review-only |
| `VECTOR_SOURCE_REDACTED` | Vector source redacted |
| `EXPORT_MASKED` | Export-safe masked form |
| `BLOCKED` | Projection not allowed |

Masking class must be enforced before display.

---

## 10. Tenant Store Legal Entity Scope Boundary

Projection must preserve scope.

Projection may require:

- tenant id
- store id
- brand id
- operating group id
- legal entity id
- customer/account id
- staff id
- device id
- surface id
- provider id
- source object id
- role id
- authority context
- audience class
- masking class
- audit reference

A Store A projection must never include Store B data unless explicitly authorized and aggregated under policy.

A Tenant A projection must never include Tenant B data.

Default:

`CROSS_TENANT_ACCESS_DENIED`

Projection must follow `10141`.

---

## 11. Customer-Safe Projection Boundary

Customer-safe projection may show:

- own order status
- own waiting/seating status
- own payment-safe status
- own refund-safe status
- own coupon/point/wallet-safe status
- store notice
- approved CMS content
- safe degraded operation message
- safe recovery status
- safe support message

Customer-safe projection must not show:

- raw operational internals
- KDS internal notes
- staff-only notes
- payment provider payload
- settlement detail
- refund internal review detail
- compensation internal limit
- security containment detail
- fraud/abuse signal
- other customers
- other stores
- AI reasoning
- vector similarity

Customer-safe projection must be i18n-controlled.

---

## 12. Kiosk-Safe Projection Boundary

Kiosk-safe projection may show:

- menu display
- order candidate status
- customer action prompt
- payment-safe prompt
- safe service limitation
- staff assistance prompt
- approved CMS banner
- locale selection
- safe fallback message

Kiosk-safe projection must not show:

- admin data
- staff note
- raw exception
- raw device error
- payment uncertainty detail
- provider error
- financial internal detail
- cross-store content
- unresolved incident detail

Kiosk is public-adjacent.

Kiosk projection must be more restrictive than staff projection.

---

## 13. Staff-Safe Projection Boundary

Staff-safe projection may show:

- order operational state
- safe customer request
- staff action needed
- manual fallback marker
- degraded operation marker
- incident candidate
- recovery route candidate
- safe payment status category
- safe refund review marker
- evidence required marker

Staff-safe projection must not show:

- raw payment payload
- settlement detail
- wallet ledger detail
- unrelated customer data
- unrestricted incident/legal detail
- security containment detail
- finance admin detail
- cross-tenant/store data

Staff visibility is operational, not financial authority.

---

## 14. Kitchen-Safe Projection Boundary

Kitchen-safe projection may show:

- ticket item
- preparation status
- hold/remake/delay marker
- safe allergy/allergen label if approved
- safe substitution marker
- kitchen note if safe
- priority/routing marker
- fulfillment-safe signal

Kitchen-safe projection must not show:

- payment status unless minimal and policy-approved
- refund status
- coupon/point/wallet status
- customer private data beyond necessary safe label
- compensation detail
- settlement detail
- provider payload
- security detail
- support/admin notes

Kitchen projection supports execution only.

---

## 15. Owner/Admin Summary Projection Boundary

Owner/admin summary may show:

- store sales summary if authorized
- order summary
- refund summary
- value instrument summary
- incident/recovery summary
- staff operational summary
- device status summary
- CMS publication summary
- analytics/read model summary

Owner/admin summary must not expose:

- unrelated store data
- tenant-level data beyond authority
- raw financial evidence
- raw provider payload
- unrestricted customer personal data
- security-restricted detail
- legal/compliance detail without authority

Owner/admin visibility is not mutation authority.

---

## 16. Support/Admin Masked Projection Boundary

Support/admin projection may show:

- masked customer context
- support case context
- order status
- payment-safe status
- refund-safe status
- recovery status
- evidence availability
- safe incident category
- escalation status

Support/admin projection must not show:

- unmasked financial data without authority
- raw provider payload
- wallet ledger detail without authority
- cross-tenant/store data
- unrelated customer data
- security containment internals
- legal conclusion

Support view must be purpose-scoped.

---

## 17. Finance/Admin Projection Boundary

Finance/admin projection may show:

- payment confirmation detail
- refund detail
- value ledger detail
- settlement detail
- payout detail
- reconciliation case
- amendment record
- financial export status

Finance/admin projection must be:

- role-scoped
- tenant/store/legal entity scoped
- access-audited
- masked where needed
- export-controlled

Finance visibility does not authorize mutation unless separate authority exists.

---

## 18. HQ And Franchise OS Projection Boundary

HQ/Franchise OS projection may show:

- tenant-level summary
- store group summary
- brand summary
- operating group summary
- franchise performance aggregate
- incident trend
- support trend
- financial summary if authorized
- compliance status
- CMS publication status
- analytics benchmark if governed

HQ/Franchise projection must not leak tenant/customer/store detail beyond role and scope.

Aggregated projection must follow aggregation thresholds and masking.

---

## 19. Legal Compliance Projection Boundary

Legal/compliance projection may show sensitive review material only when authorized.

It may include:

- evidence packet
- financial evidence
- customer dispute record
- policy notice version
- export record
- legal hold marker
- incident review
- compliance classification

Legal/compliance projection must be access-audited.

Legal review is not operational execution.

---

## 20. Security-Restricted Projection Boundary

Security-restricted projection may show:

- containment state
- suspicious cross-tenant attempt
- provider trust anomaly
- device compromise marker
- secret exposure marker
- access anomaly
- export incident
- audit anomaly

Security details must not be exposed to customer, staff, or general admin views.

Containment visibility is not containment release authority.

---

## 21. AI Output Projection Boundary

AI output projection must show:

- advisory label
- source references
- uncertainty marker
- data scope
- masking status
- review requirement
- prohibited action reminder where needed

AI output must not be projected as final decision.

AI must not create hidden authority through confident wording.

AI summary is not approval.

---

## 22. pgvector Retrieval Projection Boundary

pgvector retrieval projection must show:

- related source title/reference
- source classification
- scope status
- masking status
- similarity marker if needed
- review required marker
- not-proof disclaimer where needed

Vector retrieval must not expose restricted source data.

Similarity is not proof.

Retrieved context is not current-case evidence until reviewed and linked.

---

## 23. Analytics Read Model Projection Boundary

Analytics projection may show:

- metric value
- metric definition
- source period
- refresh time
- stale marker
- aggregation level
- masking/threshold marker
- benchmark eligibility
- export restriction

Analytics projection must not hide unresolved source conflict.

Analytics is not source truth.

Benchmark is not punitive authority by default.

---

## 24. Export Preview Projection Boundary

Export preview must show only what the requester is authorized to preview.

Export preview must include:

- scope
- data class
- masking class
- row/category count if appropriate
- date range
- requester
- approval status
- warning if sensitive
- audit reference

Export preview is not export approval.

Export preview must not include hidden cross-tenant rows.

---

## 25. Projection Evidence Boundary

Projection evidence may include:

- source object reference
- projection type
- audience class
- masking class
- tenant/store/legal scope
- i18n key reference
- CMS content reference if applicable
- AI output reference if applicable
- vector source reference if applicable
- analytics read model reference if applicable
- generated time
- stale marker
- access audit reference

Projection evidence supports traceability.

It does not replace source evidence.

---

## 26. Access Audit Boundary

Access audit may be required for:

- financial projection
- settlement projection
- support/admin projection
- legal/compliance projection
- security projection
- export preview
- AI output involving restricted sources
- vector retrieval involving sensitive sources
- customer account detail
- incident/recovery detail

Access audit should record who saw what, when, why, and under which scope.

Access is not mutation.

---

## 27. Staleness Boundary

Projection may become stale.

Staleness must be shown or blocked when:

- source changed
- payment state uncertain
- refund state pending
- inventory/sold-out changed
- CMS content expired
- provider callback delayed
- reconciliation unresolved
- incident reopened
- AI source changed
- analytics refresh is old

Stale projection must not be presented as current truth.

---

## 28. Conflict Boundary

Projection conflict may occur when:

- source states disagree
- provider evidence conflicts with internal state
- Store Runtime state conflicts with Financial Trust state
- CMS content conflicts with menu validation
- i18n key missing
- AI summary conflicts with source
- analytics conflicts with live data
- vector source is outdated
- tenant/store scope mismatch exists

Conflict must trigger block, warning, review, or containment depending on severity.

Conflict must not be silently hidden.

---

## 29. Relationship To CMS Room

CMS Room provides approved content and publication targets.

Safe Projection Room controls whether the content may be displayed to an audience.

CMS publication is not sufficient if projection safety fails.

Wrong target or wrong audience must block display.

---

## 30. Relationship To i18n Room

i18n Room provides approved message keys, locale, and fallback behavior.

Safe Projection Room chooses correct audience-safe message.

Projection must not display raw source state as text.

Missing key must trigger safe fallback or block.

---

## 31. Relationship To AI Advisory Room

AI Room may produce advisory output if authorized.

Safe Projection Room controls audience visibility of AI output.

AI output must not be shown as authority.

AI output must not expose masked or restricted data.

---

## 32. Relationship To pgvector Room

pgvector Room retrieves related context if authorized.

Safe Projection Room controls how retrieval results are shown.

Vector source must be scoped and masked.

Similarity must not be shown as proof.

---

## 33. Relationship To Financial Trust

Financial Trust owns payment, refund, value, settlement, and compensation truth.

Safe Projection Room can project verified financial states only.

Safe Projection must not convert pending or unknown financial state into completed status.

Financial raw evidence remains restricted.

---

## 34. Relationship To Store Runtime

Store Runtime owns operational execution.

Safe Projection Room can project operational status to audiences.

Projection must not convert visibility into execution authority.

Store Runtime must not bypass projection rules by exposing raw state.

---

## 35. Projection Anti-Patterns

Avoid:

- raw database row exposed directly
- raw provider payload shown to customer
- staff note shown to customer
- customer-safe view exposing admin detail
- support view exposing unrelated tenant data
- kitchen view showing refund/settlement detail
- owner view showing other store data without scope
- finance view treated as approval authority
- AI output shown as decision
- vector similarity shown as proof
- analytics shown as source truth
- stale projection shown as current
- conflict silently hidden
- export preview treated as export approval
- projection missing tenant/store scope

These anti-patterns must be blocked in future runtime design.

---

## 36. Runtime Deferral

This document defines the Safe Projection, Masking, and Audience Visibility Room boundary only.

It does not authorize:

- projection engine
- masking engine
- access control implementation
- dashboard runtime
- support/admin runtime
- finance/admin runtime
- export preview runtime
- AI output runtime
- pgvector retrieval runtime
- analytics runtime
- database schema
- RLS policy
- production deployment

All runtime remains deferred.

---

## 37. Validation Checklist

Validation must confirm:

1. Safe Projection Room definition is clear.
2. Projection is separated from source truth.
3. Visibility is separated from authority.
4. Projection type catalog is defined.
5. Projection state skeleton is defined.
6. Audience class boundary is defined.
7. Source data classification boundary is defined.
8. Masking class boundary is defined.
9. Tenant/store/legal entity scope boundary is defined.
10. Customer-safe projection boundary is defined.
11. Kiosk-safe projection boundary is defined.
12. Staff-safe projection boundary is defined.
13. Kitchen-safe projection boundary is defined.
14. Owner/admin projection boundary is defined.
15. Support/admin projection boundary is defined.
16. Finance/admin projection boundary is defined.
17. HQ/Franchise OS projection boundary is defined.
18. Legal/compliance projection boundary is defined.
19. Security-restricted projection boundary is defined.
20. AI output projection boundary is defined.
21. pgvector retrieval projection boundary is defined.
22. Analytics projection boundary is defined.
23. Export preview boundary is defined.
24. Projection evidence boundary is defined.
25. Access audit boundary is defined.
26. Staleness/conflict boundaries are defined.
27. Relationships to Data Governance rooms are defined.
28. Relationships to Store Runtime and Financial Trust are defined.
29. Anti-patterns are listed.
30. Coding remains unauthorized.
31. Runtime remains deferred.

---

## 38. Relationship To Previous Documents

This document follows:

- `10520 i18n Message Key And Human Visible Text Boundary Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10480 Financial Trust Closure And Data Governance Handoff Policy`
- `10500 Data Governance Room Framing And Intelligence Boundary Index`
- `10510 CMS Content Publication And Targeting Boundary Policy`
- `10520 i18n Message Key And Human Visible Text Boundary Policy`

It prepares:

- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`
- `10550 pgvector Context Retrieval And Similarity Boundary Policy`
- `10560 Analytics Read Model And Benchmark Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 39. Final Rule

The Safe Projection, Masking, and Audience Visibility Room governs how source data becomes visible.

Projection is not source truth.

Visibility is not mutation authority.

Masked data is not source mutation.

Admin view is not approval authority.

Support view is not ownership.

Customer-safe message is not full case detail.

Staff-safe status is not financial truth.

Analytics view is not operational truth.

AI summary is not decision authority.

pgvector retrieved context is not proof.

All projections must preserve tenant/store/legal/customer scope, audience class, source classification, masking class, i18n keys, CMS targeting, financial restrictions, Store Runtime separation, staleness markers, conflict handling, access audit, export restrictions, AI non-authority, pgvector non-proof, and runtime deferral.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
