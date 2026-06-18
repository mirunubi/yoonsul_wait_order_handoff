# 010510_Policy_CMS_Content_Publication_And_Targeting_Boundary

## 1. Purpose

This document defines the CMS Content Publication and Targeting Boundary Policy.

The previous artifact `10500` defined the Data Governance Room Framing and Intelligence Boundary Index.

This document frames the first Data Governance room:

`CMS Content Publication And Targeting Room`

The purpose is to define the boundary where content drafts, notices, campaigns, emergency messages, menu display content, kiosk display content, CMS display content, store announcements, surface-specific messages, approval, targeting, publication, rollback, expiration, and evidence are governed without becoming operational execution, coupon issuance, payment promise, refund promise, compensation approval, incident resolution, or tenant-crossing content leakage.

This document is planning-only.

It does not authorize coding.

---

## 2. Room Definition

The CMS Content Publication and Targeting Room governs managed content visibility.

It may later coordinate:

- CMS content draft
- content review
- content approval
- publication target
- tenant/brand/store target
- surface target
- device/display target
- locale target
- publication window
- emergency notice
- campaign display
- promotion visibility
- rollback
- expiration
- content evidence
- publication audit

CMS content is visibility.

CMS content is not operational execution.

---

## 3. Core Principle

CMS publication is not business authority.

The correct rule is:

CMS draft is not approved content.  
CMS approval is not publication.  
CMS publication is not order execution.  
CMS campaign is not coupon issuance.  
CMS notice is not refund approval.  
CMS banner is not compensation promise.  
CMS emergency message is not incident resolution.  
CMS content is not payment confirmation.  
CMS display is not source of truth.  
CMS targeting is not tenant authority expansion.  

CMS must be tenant-scoped, store-scoped, surface-scoped, locale-governed, approval-controlled, auditable, reversible, and safely projected.

---

## 4. Scope

This room may define planning boundaries for:

- content draft
- content approval
- content publication
- publication targeting
- tenant targeting
- brand targeting
- store targeting
- operating group targeting
- legal/entity-sensitive targeting if applicable
- surface/device targeting
- locale targeting
- campaign display
- promotion display
- emergency notice
- degraded operation notice
- rollback
- expiry
- content evidence
- CMS audit
- tenant/store isolation

This room does not implement CMS runtime.

---

## 5. CMS Content Type Catalog

Recommended CMS content type catalog:

| Content Type | Meaning |
|---|---|
| `STORE_NOTICE` | Store-specific notice |
| `BRAND_NOTICE` | Brand-level notice |
| `TENANT_NOTICE` | Tenant-level notice |
| `SURFACE_BANNER` | Surface-specific banner |
| `KIOSK_HOME_CONTENT` | Kiosk home/display content |
| `MENU_DISPLAY_CONTENT` | Menu display content |
| `CAMPAIGN_DISPLAY` | Campaign visibility content |
| `PROMOTION_DISPLAY` | Promotion visibility content |
| `EMERGENCY_NOTICE` | Emergency or degraded operation notice |
| `SERVICE_LIMIT_NOTICE` | Limited service notice |
| `INCIDENT_SAFE_NOTICE` | Incident-safe notice |
| `RECOVERY_SAFE_NOTICE` | Recovery-safe notice |
| `LEGAL_POLICY_NOTICE` | Legal/policy notice |
| `DISPLAY_MEDIA` | Display image/video/media if later authorized |

Content type determines approval, targeting, and projection rules.

---

## 6. CMS State Skeleton

Recommended CMS content states:

| State | Meaning |
|---|---|
| `CMS_DRAFT` | Draft content |
| `CMS_REVIEW_REQUIRED` | Review required |
| `CMS_IN_REVIEW` | Review in progress |
| `CMS_APPROVAL_REQUIRED` | Approval required |
| `CMS_APPROVED` | Approved but not published |
| `CMS_REJECTED` | Rejected |
| `CMS_PUBLICATION_READY` | Ready for publication |
| `CMS_PUBLISHED` | Published |
| `CMS_PUBLICATION_PAUSED` | Publication paused |
| `CMS_ROLLBACK_REQUIRED` | Rollback required |
| `CMS_ROLLED_BACK` | Rolled back |
| `CMS_EXPIRED` | Expired |
| `CMS_ARCHIVED` | Archived |
| `CMS_CONTAINMENT_REQUIRED` | Containment required |
| `CMS_UNKNOWN` | State uncertain |

These states are skeleton states only.

They do not authorize runtime.

---

## 7. Tenant Brand Store Targeting Boundary

Every CMS target must be explicit.

Targeting may include:

- tenant id
- brand id if brand-scoped
- store id if store-scoped
- store group id if applicable
- operating group id if applicable
- legal entity constraint if applicable
- region if later authorized
- surface id
- device type
- locale
- publication window
- audience type

A Store A notice must not appear in Store B unless explicitly targeted.

A Tenant A campaign must not appear in Tenant B.

Default:

`CROSS_TENANT_ACCESS_DENIED`

CMS targeting must follow `10141`.

---

## 8. Surface Targeting Boundary

CMS content may target surfaces such as:

- customer mobile/web
- Mini Kiosk
- Full Kiosk
- CMS display
- customer display
- staff tablet
- kitchen display if allowed
- owner/admin dashboard
- support/admin dashboard
- Franchise OS dashboard

Surface targeting must define:

- allowed audience
- allowed message type
- masking class
- i18n key/content reference
- publication window
- fallback behavior
- emergency override policy if applicable

A content item approved for staff/admin must not appear on customer surfaces.

---

## 9. Device And Display Targeting Boundary

Device/display targeting may include:

- device type
- device id if specific
- display group
- store display zone
- kiosk mode
- customer display
- kitchen display
- CMS wall display
- degraded display mode

Device/display targeting must not bypass tenant/store binding.

A device from Store A must not receive Store B content.

Revoked or unknown device must not receive content.

---

## 10. Locale And i18n Boundary

CMS content must be locale-aware.

CMS content may use:

- i18n message key
- localized CMS body
- locale fallback
- approved fallback text
- media with locale metadata
- right-to-left/layout metadata if later needed

CMS must not publish customer-visible hardcoded operational text without i18n governance.

Missing locale must trigger safe fallback or block publication.

---

## 11. Content Approval Boundary

Content approval may depend on content type.

Approval may require:

- author
- reviewer
- approver
- tenant/store scope
- audience type
- legal/compliance review if needed
- financial review if value promise exists
- safety/allergen review if food safety statement exists
- emergency approval if urgent
- audit reference

Approval is not publication.

Publication must be a separate state or action.

---

## 12. Publication Boundary

Publication may occur only when:

- content is approved
- target scope is valid
- audience is valid
- locale is valid
- publication window is valid
- surface/device target is valid
- no containment block exists
- no cross-tenant mismatch exists
- rollback path exists
- audit route exists

Publication must fail closed when target scope is ambiguous.

CMS publication does not execute business action.

---

## 13. Campaign And Promotion Display Boundary

CMS may display campaign or promotion information.

CMS must not:

- issue coupon
- grant points
- mutate wallet
- create stored value
- approve compensation
- confirm payment
- promise refund without authority
- create settlement impact

Campaign visibility is not value issuance.

Promotion display must link to Financial Trust value rules if value is involved.

---

## 14. Emergency Notice Boundary

Emergency notice may be needed during:

- degraded operation
- payment outage
- POS/KDS outage
- store closure
- device outage
- safety concern
- inventory/sold-out issue
- service interruption
- security containment
- incident response

Emergency notice must be safe, scoped, time-limited, and auditable.

Emergency notice must not expose raw incident detail, security detail, provider blame, or compensation promise.

Emergency notice is not incident resolution.

---

## 15. Degraded Operation Notice Boundary

Degraded operation notice may show:

- service temporarily limited
- staff assistance required
- payment temporarily unavailable
- menu being refreshed
- order status being checked
- please ask staff
- try again later

It must not show:

- raw provider errors
- internal degraded rules
- payment uncertainty details
- security containment details
- staff-only notes
- compensation promises
- cross-tenant/store information

Degraded notice must be i18n-controlled.

---

## 16. Legal And Policy Notice Boundary

Legal/policy notice may include:

- store policy
- privacy notice
- allergen/safety notice
- payment policy notice
- refund policy notice
- service limitation notice
- membership/value instrument notice
- promotional conditions

Legal/policy notice may require legal/compliance review.

CMS must not create legal interpretation without approved source.

---

## 17. Menu Display Content Boundary

CMS may display menu-related content.

Menu display content must not:

- override menu source of truth
- override price source of truth
- override sold-out state
- promise availability without validation
- bypass allergen/safety notice
- silently conflict with Order Validation Room

Menu display is projection.

Menu availability and price validation remain separate.

---

## 18. Media Content Boundary

Media content may include images, videos, icons, banners, or display assets.

Media must define:

- owner/source
- approval status
- target surface
- locale/region if applicable
- expiration
- accessibility requirement if later defined
- content safety category
- audit reference

Media must not contain hidden sensitive data, unapproved claims, or wrong-store/tenant content.

---

## 19. Rollback Boundary

Rollback may be required when:

- wrong target published
- wrong store content displayed
- wrong locale published
- unapproved content published
- expired promotion shown
- unsafe message shown
- financial promise shown incorrectly
- emergency notice no longer valid
- cross-tenant risk detected

Rollback must preserve evidence.

Rollback is not deletion.

Rollback is not incident resolution.

---

## 20. Expiration Boundary

CMS content should define expiration where applicable.

Expiration may apply to:

- campaign
- promotion display
- emergency notice
- degraded notice
- store announcement
- seasonal menu display
- legal/policy notice version if superseded
- media asset

Expired content must not remain active unless policy allows extension.

Expiration should be auditable.

---

## 21. CMS Evidence Boundary

CMS evidence may include:

- tenant id
- brand id
- store id
- content id
- content type
- author
- reviewer
- approver
- target scope
- surface/device target
- locale
- publication window
- publication status
- rollback marker
- expiration marker
- customer-safe message key
- audit reference

CMS evidence supports review.

CMS evidence is not operational execution.

---

## 22. Customer-Safe CMS Projection Boundary

Customer-safe CMS projection may show:

- approved notice
- approved campaign
- approved promotion display
- service limitation message
- emergency/degraded notice
- safe policy notice
- safe menu display content

Customer-safe CMS projection must not show:

- draft content
- rejected content
- staff/admin-only notice
- raw incident detail
- provider blame
- payment uncertainty detail
- compensation promise without authority
- unverified coupon/value issuance
- cross-tenant/store content
- AI reasoning
- vector similarity

Customer-facing CMS content must be safe and scoped.

---

## 23. Staff/Admin CMS Visibility Boundary

Staff/Admin visibility may include:

- draft status
- review status
- approval status
- publication status
- target scope
- rollback status
- expiry status
- evidence reference
- audit reference

Staff/Admin visibility must be role-scoped.

Visibility is not approval authority.

---

## 24. CMS Audit Boundary

CMS audit should record:

- content creation
- content edit
- review action
- approval action
- rejection
- publication
- pause
- rollback
- expiration
- target change
- locale change
- emergency publish
- containment action

CMS audit must include tenant/store/surface scope.

Audit is not publication.

Audit is not approval.

---

## 25. Relationship To i18n Room

CMS uses i18n governance for human-visible content.

i18n Room owns message key and fallback rules.

CMS must not bypass missing-key handling.

Human-visible operational content must be key-governed or approved as localized CMS content under policy.

---

## 26. Relationship To Safe Projection Room

CMS projection must be audience-safe.

Safe Projection Room defines:

- customer-safe visibility
- staff-safe visibility
- admin-safe visibility
- masking
- audience rules
- projection restrictions

CMS must not expose raw internal state.

---

## 27. Relationship To AI Advisory Room

AI may help draft CMS content only if later authorized.

AI must not:

- publish CMS content
- approve CMS content
- create emergency notice as authority
- promise compensation
- create legal/policy interpretation
- bypass tenant/store targeting
- bypass i18n review

AI draft is draft.

Human approval remains required.

---

## 28. Relationship To pgvector Room

pgvector may later retrieve related CMS/SOP/policy examples.

Vector retrieval must not:

- retrieve cross-tenant restricted content
- use draft/rejected content as approved source
- expose internal incident text
- treat similar content as approval

Similarity is not publication authority.

---

## 29. Relationship To Financial Trust

CMS may display financial/value-related content only as approved visibility.

CMS must not:

- issue coupon
- redeem coupon
- grant points
- mutate wallet
- approve refund
- approve compensation
- confirm payment
- confirm settlement

Financial value actions belong to Financial Trust.

CMS may point to verified value projections only.

---

## 30. Relationship To Store Runtime

Store Runtime may consume CMS content for display.

Store Runtime must not:

- use CMS to override operational state
- use CMS to bypass degraded mode rules
- treat CMS campaign as order validation
- treat CMS notice as incident resolution
- treat CMS display as payment truth

CMS is display governance.

Store Runtime owns operational execution.

---

## 31. CMS Anti-Patterns

Avoid:

- CMS draft shown to customer
- CMS approval treated as publication
- CMS campaign treated as coupon issuance
- CMS banner treated as refund promise
- CMS notice treated as compensation approval
- CMS emergency notice treated as incident resolution
- CMS menu display overriding price/availability truth
- wrong-store content displayed
- wrong-locale unsafe content displayed
- expired promotion still active
- staff-only notice shown to customer
- AI-generated content published without approval
- pgvector similar content treated as approved content
- CMS content missing tenant/store target

These anti-patterns must be blocked in future runtime design.

---

## 32. Runtime Deferral

This document defines the CMS Content Publication and Targeting Room boundary only.

It does not authorize:

- CMS implementation
- content database schema
- content approval workflow
- publication engine
- targeting engine
- media upload runtime
- emergency notice runtime
- rollback engine
- i18n runtime
- AI drafting runtime
- pgvector retrieval
- production deployment

All runtime remains deferred.

---

## 33. Validation Checklist

Validation must confirm:

1. CMS Room definition is clear.
2. CMS publication is not business authority.
3. Content type catalog is defined.
4. CMS state skeleton is defined.
5. Tenant/brand/store targeting is defined.
6. Surface targeting is defined.
7. Device/display targeting is defined.
8. Locale/i18n boundary is defined.
9. Content approval boundary is defined.
10. Publication boundary is defined.
11. Campaign/promotion display boundary is defined.
12. Emergency notice boundary is defined.
13. Degraded operation notice boundary is defined.
14. Legal/policy notice boundary is defined.
15. Menu display boundary is defined.
16. Media content boundary is defined.
17. Rollback boundary is defined.
18. Expiration boundary is defined.
19. CMS evidence boundary is defined.
20. Customer-safe projection boundary is defined.
21. Staff/Admin visibility boundary is defined.
22. CMS audit boundary is defined.
23. Relationships to Data Governance rooms are defined.
24. Relationships to Financial Trust and Store Runtime are defined.
25. Anti-patterns are listed.
26. Coding remains unauthorized.
27. Runtime remains deferred.

---

## 34. Relationship To Previous Documents

This document follows:

- `10500 Data Governance Room Framing And Intelligence Boundary Index`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10350 Store Runtime Room Framing Closure And Next Axis Handoff Policy`
- `10480 Financial Trust Closure And Data Governance Handoff Policy`
- `10500 Data Governance Room Framing And Intelligence Boundary Index`

It prepares:

- `10520 i18n Message Key And Human Visible Text Boundary Policy`
- `10530 Safe Projection Masking And Audience Visibility Boundary Policy`
- `10540 AI Advisory Runtime And Non-Authority Boundary Policy`

This document is room boundary planning only.

It does not authorize coding.

---

## 35. Final Rule

The CMS Content Publication and Targeting Room governs managed content visibility.

CMS draft is not approved content.

CMS approval is not publication.

CMS publication is not operational execution.

CMS campaign is not coupon issuance.

CMS notice is not refund approval.

CMS banner is not compensation promise.

CMS emergency message is not incident resolution.

CMS display is not source of truth.

CMS targeting must preserve tenant/store/brand/surface/device/locale scope, approval, rollback, expiration, audit, i18n, Safe Projection, Financial Trust separation, Store Runtime separation, AI non-authority, pgvector non-proof, and runtime deferral.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.