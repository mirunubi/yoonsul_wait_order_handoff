# 010670_Policy_Safe_Projection_I18n_Routing.md

## Purpose

This document defines the Safe Projection and i18n Routing Policy.

The previous artifact `10660 Idempotency Retry Replay Reconciliation Policy` defined how duplicate, delayed, retried, replayed, timed-out, provider-delayed, offline-synced, and batch-reprocessed events must be handled without corrupting source truth.

This document defines how source truth, uncertain state, containment state, financial state, operational state, security state, AI advisory state, sensor evidence, and reconciliation state may be safely rendered to customers, store staff, owners, franchise HQ, support, finance, security, auditors, and public-facing surfaces.

The purpose is to ensure that every human-visible message, dashboard, status, error, alert, banner, notification, receipt, no-show notice, payment status, refund status, KDS/fulfillment status, incident explanation, and AI-assisted support response is:

1. Audience-scoped.
2. Tenant-scoped.
3. Store-scoped where required.
4. Masked.
5. i18n-keyed.
6. Safe under uncertainty.
7. Not a source of authority.
8. Not misleading.
9. Not leaking sensitive internal details.
10. Not hardcoded in runtime logic.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Projection is visibility, not truth.

The correct rule is:

Projection is not source of truth.  
Human-visible text must use i18n keys.  
Hardcoded operational text is prohibited.  
Customer message must not expose internal security detail.  
Owner projection must not expose unrelated tenant data.  
Support projection must be case-scoped.  
AI draft is not official message until approved or policy-allowed.  
Uncertainty must be shown safely.  
Financial pending state must not be rendered as confirmed.  
Provider return page is not payment proof.  
Fallback state must be visible when relevant.  
Containment must be communicated without causing panic or leakage.  
Projection must preserve tenant, store, legal, actor, audience, masking, and policy scope.  

Projection helps humans act.

Projection must not mutate source truth.

---

## 3. Projection Scope

Safe projection applies to:

- customer web/app
- Catch Menu surface
- Mini Kiosk
- Full Kiosk
- table tablet
- staff tablet
- KDS display
- POS handoff dashboard
- owner dashboard
- franchise HQ dashboard
- support console
- finance console
- security console
- audit console
- CMS preview
- i18n translation console
- AI support draft
- notification
- email/SMS/push message
- receipt
- refund notice
- no-show notice
- external link warning
- degraded operation banner
- export preview
- evidence summary
- analytics dashboard
- supplier portal
- device management surface
- DR/recovery dashboard

Every projection must be audience-aware.

---

## 4. Projection Family Catalog

Recommended projection families:

| Projection Family | Purpose |
|---|---|
| `CUSTOMER_STATUS_PROJECTION` | Customer-safe order/payment/wait status |
| `STORE_STAFF_PROJECTION` | Store operation and staff action visibility |
| `KITCHEN_PROJECTION` | KDS/kitchen execution visibility |
| `OWNER_PROJECTION` | Owner/store financial and operational dashboard |
| `FRANCHISE_HQ_PROJECTION` | Franchise-scoped aggregate and compliance view |
| `SUPPORT_PROJECTION` | Case-scoped support view |
| `FINANCE_PROJECTION` | Financial trust, settlement, payout, reconciliation |
| `SECURITY_PROJECTION` | Security incidents, containment, risk |
| `AUDIT_PROJECTION` | Audit timeline and evidence trace |
| `CMS_PROJECTION` | Content preview and publication state |
| `I18N_PROJECTION` | Locale/message key status |
| `AI_ADVISORY_PROJECTION` | AI explanation or recommendation view |
| `VECTOR_CONTEXT_PROJECTION` | Retrieved context with source references |
| `ANALYTICS_PROJECTION` | Aggregates, benchmarks, read models |
| `EXPORT_PROJECTION` | Export preview and disclosure summary |
| `DEVICE_PROJECTION` | Device trust/health status |
| `SENSOR_PROJECTION` | Redacted sensor evidence summary |
| `SCM_SUPPLIER_PROJECTION` | Inventory, replenishment, supplier state |
| `DR_PROJECTION` | Disaster recovery and failover visibility |

Projection family determines masking and wording.

---

## 5. Projection Required Fields

Every projection should include:

| Field | Meaning |
|---|---|
| `projection_id` | Projection id |
| `projection_family` | Projection family |
| `projection_version` | Projection schema version |
| `source_room` | Source truth room |
| `source_object_refs` | Source object references |
| `source_event_refs` | Source event references |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope if applicable |
| `legal_entity_id` | Legal scope if applicable |
| `audience_class` | Customer, staff, owner, HQ, support, finance, security, auditor |
| `visibility_scope` | Visibility context |
| `masking_class` | Masking rule |
| `locale` | Locale |
| `message_key_refs` | i18n message keys used |
| `state_confidence` | Confidence/uncertainty marker |
| `freshness_marker` | Fresh/stale marker |
| `conflict_marker` | Conflict marker |
| `policy_version` | Policy version |
| `generated_at` | Generation time |
| `expires_at` | Expiry if applicable |
| `audit_ref` | Audit reference |

Projection without audience class is unsafe.

---

## 6. Projection State Skeleton

Recommended projection states:

| State | Meaning |
|---|---|
| `PROJECTION_NOT_READY` | Not ready |
| `PROJECTION_BUILDING` | Building |
| `PROJECTION_READY` | Ready |
| `PROJECTION_STALE` | Stale |
| `PROJECTION_CONFLICT` | Source conflict |
| `PROJECTION_UNCERTAIN` | Source uncertain |
| `PROJECTION_MASKED` | Masking applied |
| `PROJECTION_REDACTED` | Redaction applied |
| `PROJECTION_SUPPRESSED` | Suppressed for safety |
| `PROJECTION_REBUILD_REQUIRED` | Rebuild needed |
| `PROJECTION_REVIEW_REQUIRED` | Human review required |
| `PROJECTION_EXPIRED` | Expired |
| `PROJECTION_EXPORT_BLOCKED` | Export blocked |

Projection state must be visible to authorized operators.

---

## 7. i18n Routing Boundary

All human-visible text must route through i18n keys.

This includes:

- customer order status
- payment status
- refund status
- wait status
- table binding status
- no-show notice
- cancellation notice
- external link warning
- error message
- validation message
- degraded operation banner
- support response
- owner dashboard labels
- staff action labels
- KDS messages
- device warning
- settlement status
- export warning
- security warning
- AI-assisted message
- policy explanation
- CMS publication text

Hardcoded operational text is prohibited.

---

## 8. i18n Message Key Boundary

Message key should be structured.

Recommended key pattern:

    surface.audience.domain.state.variant

Examples:

- `customer.order.payment.verifying`
- `customer.refund.provider_pending`
- `customer.wait.position_uncertain`
- `staff.kds.ticket.retry_required`
- `owner.settlement.reconciliation_required`
- `support.case.no_show_review_pending`
- `finance.payout.hold_applied`
- `security.session.context_mismatch`
- `admin.redirect.target_denied`
- `cms.publication.review_required`
- `i18n.locale.missing_translation`
- `device.softpos.attestation_failed`

Message key is stable.

Rendered text may vary by locale, tenant policy, and audience.

---

## 9. Locale Resolution Boundary

Locale resolution must be deterministic.

Locale source priority may include:

1. Explicit user preference.
2. Session locale.
3. Tenant/store default.
4. Device/app locale.
5. Browser Accept-Language.
6. Country/region default.
7. Platform default.
8. Safe fallback locale.

Locale must not affect authority.

Locale only affects rendering.

---

## 10. Locale Fallback Boundary

Missing locale must not produce unsafe or misleading message.

Fallback rules:

- fallback to approved safe locale
- show generic safe message if financial/security wording missing
- route missing translation to i18n review
- block publication if legally required translation missing
- do not expose message key to customer unless safe
- do not show raw technical error
- do not show machine translation for high-risk legal/financial/security message unless approved

Fallback is controlled.

Fallback is not free-form generation.

---

## 11. Message Risk Class Catalog

Messages must be risk-classified.

| Risk Class | Examples |
|---|---|
| `LOW_RISK_UI_LABEL` | Button labels, menu labels |
| `OPERATIONAL_STATUS` | Order/KDS/wait status |
| `FINANCIAL_STATUS` | Payment, refund, settlement, payout |
| `LEGAL_POLICY_NOTICE` | No-show penalty, cancellation terms |
| `SECURITY_NOTICE` | Session, redirect, account risk |
| `PRIVACY_NOTICE` | Camera/audio/location/AI usage |
| `INCIDENT_NOTICE` | Degraded mode, outage, recovery |
| `SUPPORT_RESPONSE` | CS explanation |
| `EXPORT_DISCLOSURE` | Export/download warning |
| `AI_ASSISTED_TEXT` | AI-drafted message |
| `EMERGENCY_BANNER` | Safety or severe outage |

High-risk messages require review or approved templates.

---

## 12. Audience Masking Boundary

Different audiences must see different projections.

| Audience | Projection Principle |
|---|---|
| Customer | Simple, safe, non-internal, action-oriented |
| Store Staff | Operationally actionable, limited financial detail |
| Kitchen | Execution-focused, no unnecessary customer/payment detail |
| Owner | Store-scoped financial/operational summary |
| Franchise HQ | Contract-scoped aggregate and compliance visibility |
| Support | Case-scoped evidence with masking |
| Finance | Financial evidence and reconciliation detail |
| Security | Security evidence, risk, containment detail |
| Auditor | Immutable/audit-scoped evidence |
| Public | Minimal approved public message only |

Projection must not leak beyond audience need.

---

## 13. Customer-Safe Projection Boundary

Customer-facing projection must avoid:

- internal provider error codes
- raw security details
- staff identity unless approved
- other customer data
- internal ledger state
- raw KDS failure details
- internal device compromise
- exact anti-fraud reason
- tenant/store private operational data
- AI uncertainty details that confuse or mislead

Customer-facing projection should show:

- status
- next action
- safe expected timing
- support route
- verified uncertainty if needed
- approved policy wording
- friendly tone aligned with brand

Customer-safe message must not falsely imply finality.

---

## 14. Staff Projection Boundary

Staff projection may show operational details.

Staff may see:

- order queue
- KDS status
- retry required
- manual fallback required
- device/printer issue
- customer wait state
- payment status at operational level
- allergy/menu availability warnings
- degraded operation instruction
- fulfillment exception
- local/offline sync pending

Staff must not see unnecessary financial ledger, provider credentials, raw security evidence, or unrelated tenant/store data.

---

## 15. Owner Projection Boundary

Owner projection may show store-scoped business detail.

Owner may see:

- store sales summary
- payment pending/confirmed summary
- refund/cancel summary
- settlement/payout status
- reconciliation required cases
- no-show/cancellation metrics
- device health summary
- operational incident summary
- staff throughput summary
- inventory/supplier summary
- customer recovery summary

Owner must not see:

- unrelated tenant data
- platform internal margin unless contracted
- raw provider secret
- other store data without authority
- raw security logs beyond need
- raw customer sensitive data beyond policy

---

## 16. Franchise HQ Projection Boundary

Franchise HQ projection must be contract-scoped.

HQ may see:

- brand/store aggregate
- royalty basis
- compliance state
- operating benchmark
- incident trend
- training/SOP adherence
- approved settlement summary
- store readiness status
- policy compliance state

HQ must not see raw store-private details unless contract and authority allow.

Franchise visibility is not store mutation authority.

---

## 17. Support Projection Boundary

Support projection must be case-scoped.

Support may see:

- customer case timeline
- order/payment/refund status needed for support
- approved evidence summary
- masked customer data
- approved no-show/dispute evidence
- safe AI support draft
- prior support notes
- allowed escalation route

Support must not see:

- unrelated customer history
- unrelated tenant data
- raw security detail without escalation
- raw payment credentials
- raw sensor media unless approved
- unrestricted financial ledger

Support projection must be auditable.

---

## 18. Finance Projection Boundary

Finance projection may show financial trust detail.

Finance may see:

- payment state
- refund state
- settlement allocation
- payout hold
- split payout
- fast payout exposure
- provider reconciliation
- ledger/journal state
- chargeback/dispute state
- adjustment/amendment lineage
- tax/reporting evidence

Finance projection must preserve tenant/legal entity scope.

Finance view must not become mutation without command/authority gate.

---

## 19. Security Projection Boundary

Security projection may show risk and containment detail.

Security may see:

- session anomaly
- redirect attack
- token replay
- cross-tenant attempt
- device compromise
- provider spoof
- queue secret leakage
- WORM/hash mismatch
- AI prompt injection risk
- sensor tampering
- admin abuse
- quarantine/circuit state

Security projection must avoid unnecessary customer/business data unless needed.

Security action still requires authority gate.

---

## 20. AI Advisory Projection Boundary

AI advisory projection must be labeled.

AI projection should show:

- AI-generated status
- confidence marker
- source references
- limitations
- human review requirement if high-risk
- suggested next action
- policy basis if applicable

AI projection must not appear as final authority for:

- refund approval
- penalty
- settlement
- payout
- account change
- supplier order
- IoT execution
- legal conclusion

AI wording must use approved message templates when customer-facing.

---

## 21. pgvector Context Projection Boundary

Vector context projection must show source references.

Vector projection must include:

- retrieved source id
- source type
- source scope
- similarity score if internal
- source freshness
- masking status
- tenant/store restriction
- usage purpose
- review requirement

Similarity is not proof.

Vector result must not be projected cross-tenant unless source is approved aggregate/public knowledge.

---

## 22. Sensor Evidence Projection Boundary

Sensor projection must be redacted and purpose-bound.

Sensor projection may show:

- sensor type
- event time
- confidence class
- redacted summary
- review state
- linked operational event
- privacy status
- retention state

Sensor projection must not expose raw video/audio by default.

Sensor projection must not accuse customer/staff without review.

Sensor signal is evidence, not authority.

---

## 23. Financial Uncertainty Projection Boundary

Financial uncertainty must be explicit.

Examples:

| Source State | Customer Projection | Owner/Finance Projection |
|---|---|---|
| Payment timeout | Payment is being verified | Payment timeout, reconciliation required |
| Provider callback delayed | Confirmation pending | Provider callback pending |
| Refund requested | Refund request received | Refund pending provider confirmation |
| Payout hold | Not customer-visible | Payout hold applied |
| Settlement mismatch | Not customer-visible | Settlement reconciliation required |
| Chargeback pending | Support message only | Chargeback/dispute state |

Never show payment confirmed unless Financial Trust confirms.

---

## 24. Operational Uncertainty Projection Boundary

Operational uncertainty must be explicit.

Examples:

- POS handoff pending
- KDS ticket pending
- printer retry required
- device offline
- local sync pending
- order accepted but kitchen confirmation pending
- table binding uncertain
- pickup confirmation pending
- degraded mode active

Projection must help staff act without corrupting truth.

---

## 25. Degraded Mode Message Boundary

Degraded mode messages must be safe.

Customer message:

- brief
- non-technical
- action-oriented
- no internal cause unless approved

Staff message:

- operational instruction
- fallback step
- evidence capture instruction
- escalation route

Owner/HQ message:

- affected scope
- business impact
- recovery state
- evidence/reconciliation status

Security-sensitive cause must not be exposed broadly.

---

## 26. Error Message Boundary

Error messages must not leak:

- stack trace
- SQL/RPC function name
- provider secret
- internal route
- tenant existence
- authorization rule internals
- security rule details
- raw redirect target
- object existence where unauthorized
- vector/source context
- raw sensor/media path

Use safe error code and i18n key.

Internal detail goes to audit/security logs.

---

## 27. Notification Routing Boundary

Notification must be audience-scoped.

Notification channels:

- in-app
- push
- SMS
- email
- KDS banner
- staff alert
- owner alert
- HQ alert
- support queue
- finance queue
- security alert
- supplier message

Notification must enforce:

- tenant scope
- recipient authority
- locale
- message key
- masking
- urgency
- retry/idempotency
- audit
- unsubscribe/legal rules where applicable

Notification is projection.

It must not mutate truth.

---

## 28. CMS Publication Projection Boundary

CMS projection must separate:

- draft
- preview
- approved
- scheduled
- published
- paused
- expired
- rollback candidate
- emergency override
- suppressed

CMS preview must not become publication.

CMS published content must not become financial/policy authority unless tied to approved policy.

---

## 29. Legal And Policy Wording Boundary

Legal/policy wording must be controlled.

Applies to:

- no-show penalty
- cancellation terms
- refund policy
- deposit terms
- privacy/camera/audio notice
- AI usage notice
- membership/points/wallet terms
- export/disclosure
- external link disclaimer
- KYC/account verification
- dynamic pricing/time-sale terms

Legal wording requires approved templates and locale coverage.

Machine translation alone is not enough for high-risk legal wording.

---

## 30. Brand Tone Boundary

Brand tone may be applied only after safety and legal correctness.

Brand tone can affect:

- greeting
- customer reassurance
- order status wording
- wait explanation
- support empathy
- degraded mode apology
- pickup guidance

Brand tone must not soften or obscure:

- payment uncertainty
- refund terms
- no-show penalty
- legal notice
- privacy notice
- security warning

Friendly wording must remain truthful.

---

## 31. Projection Freshness Boundary

Projection must show freshness where needed.

Freshness markers:

- real-time
- near real-time
- delayed
- stale
- pending sync
- provider pending
- local/offline
- batch updated
- under review
- reconciled

Freshness is critical for financial, operational, and security dashboards.

Stale projection must not appear final.

---

## 32. Projection Rebuild Boundary

Projection may be rebuilt from source events.

Projection rebuild must:

- preserve source truth
- preserve tenant scope
- preserve masking
- preserve i18n keys
- preserve uncertainty markers
- avoid mutation
- audit rebuild
- detect missing events
- preserve historical policy where required
- mark rebuild state if incomplete

Projection rebuild is not source repair.

---

## 33. Projection Export Boundary

Projection export is high-risk.

Export projection must check:

- audience
- scope
- approval
- masking
- legal hold
- retention
- data class
- destination
- token expiry
- audit

Exported projection must not include hidden fields.

Export preview must not be downloadable unless approved.

---

## 34. i18n Coverage Readiness Boundary

A surface is not ready if required message keys are missing.

Readiness must check:

- required locales
- fallback locale
- high-risk legal/financial messages
- error messages
- degraded mode messages
- support messages
- security messages
- no-show/cancellation terms
- payment/refund status
- external link warning
- privacy notice
- AI/sensor notice

Missing critical i18n key blocks release or feature activation.

---

## 35. Message Review Workflow Boundary

High-risk message changes require review.

Review required for:

- financial wording
- refund wording
- no-show penalty wording
- legal terms
- privacy notice
- security notice
- AI-generated customer response template
- camera/audio notice
- dynamic pricing terms
- export/disclosure wording
- emergency/degraded mode wording

Review must be audited.

Published message must reference approved version.

---

## 36. Safe Projection Event Catalog

Recommended events:

| Event Type | Meaning |
|---|---|
| `PROJECTION_BUILT` | Projection built |
| `PROJECTION_STALE_MARKED` | Projection marked stale |
| `PROJECTION_CONFLICT_MARKED` | Projection conflict marked |
| `PROJECTION_SUPPRESSED` | Projection suppressed |
| `PROJECTION_REBUILD_STARTED` | Projection rebuild started |
| `PROJECTION_REBUILD_COMPLETED` | Projection rebuild completed |
| `I18N_KEY_MISSING` | Required message key missing |
| `I18N_FALLBACK_USED` | Fallback locale used |
| `MESSAGE_REVIEW_REQUIRED` | Message requires review |
| `MESSAGE_APPROVED` | Message approved |
| `MESSAGE_PUBLISHED` | Message published |
| `MESSAGE_ROLLED_BACK` | Message rolled back |
| `CUSTOMER_NOTICE_SENT` | Customer notice sent |
| `SUPPORT_DRAFT_AI_GENERATED` | AI support draft generated |
| `SENSOR_EVIDENCE_REDACTED` | Sensor evidence redacted |
| `FINANCIAL_UNCERTAINTY_PROJECTED` | Financial uncertainty shown safely |
| `DEGRADED_MODE_BANNER_SHOWN` | Degraded mode banner shown |

These events must route through `10610`.

---

## 37. Relationship To Event Bus

Projection consumes events but does not own truth.

Event bus provides:

- source event reference
- scope envelope
- evidence packet id
- state markers
- uncertainty markers
- audit references
- policy version

Projection must not detach from event source.

---

## 38. Relationship To Command Query Projection Separation

This document extends `10620`.

Projection must remain separated from:

- command
- source event
- evidence packet
- audit
- reconciliation
- AI advisory
- sensor observation
- provider signal

Projection may trigger command candidate only through explicit command flow.

Projection must not mutate state directly.

---

## 39. Relationship To Authority Gate

Projection visibility requires authority/visibility gate.

Projection actions require command authority gate.

Example:

- Owner sees refund candidate.
- Owner clicks approve.
- Command is created.
- Authority gate evaluates.
- Financial Trust executes if allowed.
- Projection updates afterward.

Seeing is not acting.

---

## 40. Relationship To Tenant Scope Envelope

Every projection must carry scope.

Projection must enforce:

- tenant
- store
- legal entity
- brand/franchise
- actor/role
- surface
- audience
- visibility
- masking
- policy version

Cross-tenant projection is denied by default.

---

## 41. Relationship To Reconciliation

Projection must reflect reconciliation state.

Projection must show:

- pending
- matched
- mismatch
- under review
- hold applied
- amendment required
- resolved verified
- stale
- conflict

Projection must not hide reconciliation exceptions.

---

## 42. Anti-Patterns

Avoid:

- hardcoded customer-facing status text
- payment pending shown as paid
- provider return page shown as final confirmation
- AI support draft sent without approval when high-risk
- sensor evidence shown raw to customer
- owner dashboard exposing other tenant/store data
- support console showing unrelated customer data
- stale projection shown as real-time
- legal notice machine-translated without review
- CMS preview treated as publication
- i18n missing key showing raw internal key to customer
- projection table used as source truth
- export including hidden/raw projection fields
- brand tone hiding financial uncertainty
- error page exposing RPC method or SQL function

These anti-patterns must be blocked in future runtime design.

---

## 43. Runtime Deferral

This document defines safe projection and i18n routing boundaries only.

It does not authorize:

- projection table implementation
- read model implementation
- i18n library integration
- translation management system
- CMS implementation
- notification runtime
- message review workflow
- AI support drafting runtime
- sensor redaction runtime
- projection rebuild runtime
- export projection runtime
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 44. Validation Checklist

Validation must confirm:

1. Projection scope is defined.
2. Projection family catalog is defined.
3. Projection required fields are defined.
4. Projection state skeleton is defined.
5. i18n routing boundary is defined.
6. i18n message key boundary is defined.
7. Locale resolution boundary is defined.
8. Locale fallback boundary is defined.
9. Message risk class catalog is defined.
10. Audience masking boundary is defined.
11. Customer-safe projection boundary is defined.
12. Staff projection boundary is defined.
13. Owner projection boundary is defined.
14. Franchise HQ projection boundary is defined.
15. Support projection boundary is defined.
16. Finance projection boundary is defined.
17. Security projection boundary is defined.
18. AI advisory projection boundary is defined.
19. pgvector context projection boundary is defined.
20. Sensor evidence projection boundary is defined.
21. Financial uncertainty projection boundary is defined.
22. Operational uncertainty projection boundary is defined.
23. Degraded mode message boundary is defined.
24. Error message boundary is defined.
25. Notification routing boundary is defined.
26. CMS publication projection boundary is defined.
27. Legal/policy wording boundary is defined.
28. Brand tone boundary is defined.
29. Projection freshness boundary is defined.
30. Projection rebuild boundary is defined.
31. Projection export boundary is defined.
32. i18n coverage readiness boundary is defined.
33. Message review workflow boundary is defined.
34. Safe projection event catalog is defined.
35. Relationships to Event Bus, CQP Separation, Authority Gate, Tenant Scope Envelope, and Reconciliation are defined.
36. Anti-patterns are listed.
37. Coding remains unauthorized.
38. Runtime remains deferred.

---

## 45. Relationship To Previous Documents

This document follows:

- `10660 Idempotency Retry Replay Reconciliation Policy`

It prepares:

- `10680 Audit Correlation Nightly Batch Policy`
- `10690 Cross-Room Plumbing Closure Policy`

It references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- prior Data Governance, CMS, i18n, AI, pgvector, Store Runtime, Financial Trust, Security, Web RPC, Sensor, SaaS, and Franchise OS boundary documents where safe human-visible projection is required.

This document is architecture boundary planning only.

It does not authorize coding.

---

## 46. Final Rule

Projection is visibility, not truth.

Every projection must be tenant-scoped, audience-scoped, masked, traceable to source events, and rendered through approved i18n message keys.

Uncertainty must be shown safely.

Financial pending state must not be shown as confirmed.

Provider return page must not be shown as payment proof.

AI advisory must not appear as authority.

Sensor evidence must not become accusation or billing without review.

Hardcoded operational text is prohibited.

High-risk legal, financial, privacy, security, no-show, refund, payment, and degraded-mode messages require approved templates and locale coverage.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
