# 010148_Policy_SaaS_Packaging_Pricing_Boundary_And_Feature_Entitlement.md

## Purpose

This document defines the SaaS Packaging, Pricing Boundary, and Feature Entitlement Policy.

The previous artifact `10047` defined the Product Line Capability Matrix and Surface Reuse Registry Policy.

This document defines how product surfaces, capabilities, modules, admin surfaces, provider integrations, device roles, CMS features, AI advisory functions, pgvector context, and Franchise OS governance features may be packaged into SaaS plans without creating accidental runtime authority.

The purpose is to separate commercial entitlement from technical capability, operational activation, policy permission, provider evidence, authority, and runtime execution.

A SaaS package may entitle a tenant to request or use a capability.

A SaaS package must not by itself authorize execution.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Pricing package is not runtime authority.

The correct rule is:

SaaS package defines commercial entitlement.
Provider Capability Matrix defines technical support.
Tenant Feature Plan defines contracted access.
Store Runtime Configuration defines operational activation.
Policy Gate defines legal, security, financial, and operational permission.
Runtime Feature Flag defines temporary live state.
Authority Boundary defines who may request, review, approve, or execute.
Use Case API makes the final decision.
Safe Projection controls what is shown.

A paid feature may still be blocked by policy, provider limitation, store configuration, missing evidence, or runtime incident.

---

## 3. Scope

This policy applies to SaaS packaging for:

- Catch Menu
- Catch & Order
- Mini Kiosk
- Full Kiosk
- Store Runtime
- POS integration
- KDS integration
- payment integration
- CMS
- support/admin
- recovery case workflow
- compensation review workflow
- coupon/point/wallet/prepaid features
- provider control
- device control
- i18n/locale expansion
- AI advisory
- pgvector context
- workforce interface
- external channel interface
- Franchise OS
- multi-store governance
- multi-brand governance
- admin surface reuse
- device fleet management

This policy does not define actual prices.

It defines pricing boundary and entitlement governance.

---

## 4. SaaS Package Definition

A SaaS Package is a commercial and operational grouping of capabilities.

A package may define:

- included product surfaces
- included admin surfaces
- included feature families
- provider integration eligibility
- device count limits
- store count limits
- locale count limits
- CMS feature scope
- support feature scope
- recovery feature scope
- AI advisory scope
- pgvector context scope
- Franchise OS scope
- rollout eligibility
- SLA/support tier if applicable
- review requirements
- restricted/high-risk feature exclusions

A SaaS Package is not a runtime switch.

---

## 5. Entitlement Versus Activation

Entitlement and activation must be separated.

| Concept | Meaning |
|---|---|
| `Entitlement` | Tenant is contractually allowed to use or request feature |
| `Activation` | Feature is enabled for tenant/store/device |
| `Capability` | Provider/system technically supports the feature |
| `Policy Permission` | Feature is allowed under policy |
| `Runtime Availability` | Feature is currently live |
| `Authority` | Actor may request/review/approve/execute |
| `Projection` | Surface may display safe state |
| `Execution` | Actual state-changing action |

Entitlement is necessary but not sufficient.

---

## 6. Recommended Package Families

Recommended SaaS package families may include:

| Package Family | Role |
|---|---|
| `Menu Starter` | Lightweight Catch Menu entry |
| `Order Starter` | Catch Menu plus Catch & Order |
| `Mini Kiosk Pack` | Device-based customer menu/order surface |
| `Kiosk Standard` | Mini Kiosk plus CMS/staff assist |
| `Kiosk Payment` | Full Kiosk with payment mode eligibility |
| `Store Runtime Pack` | POS/KDS/payment/recovery/support integration eligibility |
| `CMS Control Pack` | Controlled content management |
| `Device Control Pack` | Device profile/runtime config/fleet management |
| `Provider Control Pack` | Provider evidence and capability management |
| `Support Control Pack` | Support/admin review |
| `Recovery Control Pack` | Recovery case workflow |
| `Compensation Review Pack` | Value review workflow, not automatic execution |
| `Franchise Core` | Multi-store governance and admin reuse |
| `Franchise Advanced` | Policy inheritance, fleet, provider, CMS, support governance |
| `AI Assist Pack` | AI advisory only |
| `Vector Context Pack` | pgvector context retrieval only |
| `Workforce Interface Pack` | Workforce routing/interface eligibility |

Package names may change later.

Boundary principles must remain.

---

## 7. Menu Starter Package Boundary

`Menu Starter` may include:

- Catch Menu surface
- menu projection
- customer-safe item status
- approved price display
- approved availability display
- approved allergen notice if available
- i18n message key usage
- basic CMS notice slot if included
- QR/NFC entry
- safe fallback messages

It must not include by default:

- order submission
- payment
- POS handoff
- KDS visibility
- compensation
- wallet/prepaid
- provider mutation
- AI decision
- pgvector proof

Menu Starter is visibility-first.

---

## 8. Order Starter Package Boundary

`Order Starter` may include:

- Catch Menu
- Catch & Order surface
- customer session continuity
- cart/order intent
- order submit request if enabled
- duplicate guard if included
- customer-safe order status
- staff assistance route
- order fallback state
- POS handoff eligibility if provider evidence exists

It must not include by default:

- payment confirmation
- settlement truth
- refund execution
- KDS completion truth
- automatic compensation
- provider fault confirmation

Order Starter is order-intent and handoff focused.

---

## 9. Mini Kiosk Pack Boundary

`Mini Kiosk Pack` may include:

- Android or approved device surface
- Device Profile
- Runtime Configuration
- Mini Kiosk surface
- menu projection
- order intent
- staff assist
- safe CMS notice slot if included
- kiosk surface lock if applicable
- device revoke handling
- safe degraded operation notice

It must not include by default:

- self-payment
- payment verification
- direct POS/KDS provider calls
- refund/coupon/point/wallet execution
- unrestricted CMS publishing
- raw provider error display

Mini Kiosk Pack is device-shaped customer surface.

---

## 10. Kiosk Standard Package Boundary

`Kiosk Standard` may include:

- Mini Kiosk Pack
- approved CMS home/notice surface
- guided order flow
- staff-assisted payment route
- device health visibility
- admin-managed configuration
- fallback/degraded mode
- locale selection
- accessibility options if included
- store-specific Kiosk profile

It must not include by default:

- kiosk self-payment
- payment verification
- refund execution
- POS/KDS runtime integration unless separately entitled and configured
- unrestricted campaign publishing

Kiosk Standard is operational kiosk without automatic financial authority.

---

## 11. Kiosk Payment Package Boundary

`Kiosk Payment` may include eligibility for:

- payment request surface
- payment checking status
- payment verification if provider capability exists
- payment provider profile
- idempotency requirement
- reconciliation requirement
- staff fallback route
- payment-safe customer messages
- payment audit events

It must not automatically include:

- refund execution
- wallet/prepaid
- settlement authority
- provider fault confirmation
- payment truth without verification
- offline payment confirmation

Payment package requires strict provider, policy, authority, and audit controls.

---

## 12. Store Runtime Pack Boundary

`Store Runtime Pack` may include eligibility for:

- POS handoff
- KDS visibility
- payment provider integration
- staff tablet integration
- support/admin review
- recovery case workflow
- device fleet visibility
- provider health visibility
- incident/degraded mode
- audit/evidence packet
- local agent if Windows
- Android provisioning if Kiosk/tablet

It must not automatically include:

- compensation execution
- refund execution
- wallet/prepaid mutation
- provider capability verification without evidence
- AI decision authority

Store Runtime Pack connects operations.

It must remain evidence-bound.

---

## 13. CMS Control Pack Boundary

`CMS Control Pack` may include:

- banner content
- notice content
- menu promotion
- campaign draft
- Kiosk content slot
- Catch Menu content slot
- emergency notice draft
- content approval workflow
- content rollback
- locale-aware content
- CMS audit event

It must not include by default:

- unreviewed customer publication
- legal-sensitive message auto-publication
- allergen notice without review
- payment/refund promise
- provider fault announcement without verification
- AI auto-publication

CMS is controlled content governance.

---

## 14. Device Control Pack Boundary

`Device Control Pack` may include:

- Device Profile management
- device role assignment
- runtime config management
- app version visibility
- device status
- device suspend/revoke
- kiosk mode status
- config versioning
- emergency disable
- device replacement workflow
- device fleet dashboard
- device health audit

It must not include by default:

- financial execution
- provider capability approval
- payment confirmation
- refund/compensation execution
- security containment release unless separately authorized

Device control is operational governance.

---

## 15. Provider Control Pack Boundary

`Provider Control Pack` may include:

- provider registry
- provider capability matrix
- evidence upload/reference
- capability review workflow
- known limitation record
- provider assignment candidate
- provider degraded mode reference
- provider support route
- provider audit event
- provider rollout status

It must not include by default:

- unverified capability activation
- provider fault confirmation without evidence
- payment/POS/KDS execution
- settlement truth
- customer-visible provider blame

Provider control is evidence governance.

---

## 16. Support Control Pack Boundary

`Support Control Pack` may include:

- support-safe order summary
- masked payment review
- provider evidence reference
- recovery case route
- customer reply draft
- support note
- staff/store escalation
- AI support summary if AI pack included
- vector context if vector pack included
- support audit event

It must not include by default:

- refund execution
- compensation execution
- customer message auto-send
- raw payment/provider payload access
- security containment release
- legal conclusion

Support visibility is not mutation authority.

---

## 17. Recovery And Compensation Package Boundary

`Recovery Control Pack` may include:

- recovery case open
- recovery review
- customer-safe message draft
- escalation route
- recurrence tagging
- incident relation
- evidence packet reference

`Compensation Review Pack` may include:

- compensation request
- compensation review
- value action candidate
- idempotency requirement
- reconciliation requirement
- finance approval route
- compensation audit event

It must not automatically include:

- refund execution
- coupon issuance
- point adjustment
- wallet credit
- automated compensation approval
- mass recovery execution

Recovery is not compensation.

Compensation review is not execution.

---

## 18. Franchise Core Package Boundary

`Franchise Core` may include:

- multi-store visibility
- store capability templates
- admin surface reuse
- device fleet visibility
- CMS inheritance view
- provider assignment view
- store upgrade stage view
- brand policy reference
- support route governance
- audit/evidence overview
- runtime feature visibility

It must not include by default:

- financial policy override
- refund execution
- cross-tenant access
- security containment release
- unrestricted provider activation
- unrestricted CMS publication

Franchise Core is governance visibility and controlled configuration.

---

## 19. Franchise Advanced Package Boundary

`Franchise Advanced` may include:

- policy inheritance
- brand policy governance
- operating group governance
- store template application
- device fleet management
- provider assignment workflow
- CMS multi-store governance
- i18n locale governance
- feature rollout/rollback
- incident/degraded mode governance
- support/recovery routing
- audit/evidence governance
- workforce interface eligibility
- external channel eligibility

It must still respect:

- security policy
- legal policy
- financial policy
- provider evidence
- authority boundary
- audit
- i18n
- Safe Projection
- runtime entry gates

Franchise Advanced does not bypass foundation controls.

---

## 20. AI Assist Pack Boundary

`AI Assist Pack` may include:

- support summary
- incident summary
- provider evidence summary
- CMS draft suggestion
- i18n draft suggestion
- missing evidence checklist
- policy summary
- training draft
- store comparison summary

It must not include:

- automatic customer send
- compensation decision
- refund approval
- provider fault confirmation
- payment truth decision
- security containment release
- legal conclusion
- autonomous mutation

AI Assist Pack is advisory only.

AI is not authority.

---

## 21. Vector Context Pack Boundary

`Vector Context Pack` may include:

- similar policy lookup
- similar support case lookup
- similar incident lookup
- similar provider limitation lookup
- prior recovery pattern lookup
- admin reference retrieval
- evidence packet context retrieval if approved

It must not include:

- proof generation
- automatic decision
- customer-visible proof
- compensation approval
- provider capability confirmation
- root cause confirmation

pgvector context is reference only.

Similarity is not proof.

---

## 22. Workforce Interface Pack Boundary

`Workforce Interface Pack` may include eligibility for:

- staff role-based surface
- staff assist routing
- shift-based visibility
- manager approval route
- training surface
- store operation notices
- local workforce notice interface
- external workforce channel interface
- Franchise OS workforce coordination

It must not include by default:

- payroll mutation
- financial authority
- legal employment decision automation
- sensitive staff data exposure
- external posting without review

Workforce interface must follow role, authority, audit, and policy rules.

---

## 23. Package Dependency Rule

A package may depend on another package.

Examples:

| Package | Dependency |
|---|---|
| `Order Starter` | Menu Starter |
| `Mini Kiosk Pack` | Menu Starter or Order Starter |
| `Kiosk Standard` | Mini Kiosk Pack |
| `Kiosk Payment` | Kiosk Standard plus payment provider capability |
| `Store Runtime Pack` | Order Starter plus provider control |
| `Franchise Core` | Admin Surface and Store Runtime visibility |
| `Franchise Advanced` | Franchise Core |
| `AI Assist Pack` | Support/Admin or Admin Surface context |
| `Vector Context Pack` | approved vector source governance |

Dependency does not imply automatic activation.

---

## 24. Package Entitlement Record

A package entitlement record should define:

- entitlement id
- tenant id
- package id
- included surfaces
- included capability families
- excluded high-risk features
- store count limit
- device count limit
- provider integration eligibility
- CMS scope
- AI scope
- vector scope
- franchise scope
- start date
- end date if applicable
- billing status
- suspension status
- policy limitations
- activation status
- audit reference

Entitlement record is commercial control.

Runtime still requires capability resolution.

---

## 25. Store Activation Record

A store activation record should define:

- tenant id
- store id
- package id
- activated surfaces
- activated devices
- provider profile
- payment mode
- POS mode
- KDS mode
- CMS profile
- support route
- recovery route
- feature flags
- policy constraints
- activation status
- effective time
- expiry or review time
- audit reference

Store activation translates entitlement into operational configuration.

---

## 26. Package Suspension Rule

A package or entitlement may be suspended.

Suspension reasons may include:

- billing issue
- contract termination
- security risk
- provider evidence failure
- compliance issue
- legal hold
- incident containment
- tenant request
- store closure
- device compromise
- support escalation
- abuse or misuse

Suspension must not delete evidence.

Suspension must return safe projections.

Suspension is not incident resolution.

---

## 27. Pricing And Authority Separation Rule

Pricing must never determine authority.

Examples:

- Higher plan does not automatically allow refund execution.
- Kiosk Payment package does not automatically prove payment.
- Franchise Advanced does not bypass legal/security controls.
- AI Assist Pack does not allow AI auto-send.
- Vector Context Pack does not turn similarity into proof.
- Provider Control Pack does not verify provider capability by purchase.
- CMS Control Pack does not allow unreviewed publication.
- Device Control Pack does not allow payment state mutation.

Commercial entitlement is not governance authority.

---

## 28. Add-On Rule

Add-ons must follow the same rules as packages.

Add-ons may include:

- extra device
- extra store
- extra locale
- CMS campaign pack
- payment provider add-on
- POS provider add-on
- KDS provider add-on
- AI support add-on
- vector context add-on
- advanced audit export
- workforce channel add-on
- external channel add-on

Add-on purchase must not bypass provider evidence, policy gate, authority, audit, or runtime configuration.

---

## 29. Trial And Pilot Rule

Trial or pilot packages must be more restricted than production packages.

Trial/pilot should define:

- tenant
- store
- device
- feature scope
- provider scope
- data scope
- customer visibility scope
- support route
- expiration
- rollback
- success criteria
- known limitations
- audit requirement

Pilot feature must not silently become production runtime.

---

## 30. Package Upgrade And Downgrade Rule

Package upgrade/downgrade must be controlled.

Upgrade must check:

- tenant eligibility
- store readiness
- provider capability
- device readiness
- policy gate
- support readiness
- i18n readiness
- audit readiness
- rollback path

Downgrade must define:

- feature disable behavior
- customer-safe message
- device config change
- CMS fallback
- provider route change
- support route change
- data retention impact
- audit record

Upgrade and downgrade must not delete evidence.

---

## 31. Package Anti-Patterns

Avoid:

- paid package treated as runtime authority
- package name implying payment truth
- feature flag created directly from billing plan
- provider capability enabled by subscription alone
- AI decision authority sold as package
- vector proof sold as package
- refund execution enabled by high-tier plan alone
- CMS publication enabled without review
- franchise package bypassing policy inheritance
- device package bypassing device profile
- trial package becoming production silently
- downgrade deleting audit/evidence
- support package exposing raw sensitive data

These anti-patterns create legal, financial, and operational risk.

---

## 32. Validation Checklist

Validation must confirm:

1. SaaS Package is defined as entitlement, not authority.
2. Entitlement and activation are separated.
3. Recommended package families are defined.
4. Menu Starter boundary is defined.
5. Order Starter boundary is defined.
6. Mini Kiosk Pack boundary is defined.
7. Kiosk Standard boundary is defined.
8. Kiosk Payment boundary is defined.
9. Store Runtime Pack boundary is defined.
10. CMS Control boundary is defined.
11. Device Control boundary is defined.
12. Provider Control boundary is defined.
13. Support Control boundary is defined.
14. Recovery and Compensation boundaries are separated.
15. Franchise Core boundary is defined.
16. Franchise Advanced boundary is defined.
17. AI Assist is advisory only.
18. Vector Context is reference only.
19. Workforce Interface is controlled.
20. Package dependencies do not imply activation.
21. Entitlement record is separated from store activation.
22. Package suspension is safe and auditable.
23. Pricing and authority are separated.
24. Add-ons follow same controls.
25. Trial/pilot is restricted.
26. Upgrade/downgrade is controlled.
27. Runtime remains deferred.

---

## 33. Relationship To Previous Documents

This document follows:

- `10047 Product Line Capability Matrix And Surface Reuse Registry Policy`

It references:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`
- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`
- `10045 Franchise OS Capability Inheritance And Tenant Store Assembly Policy`
- `10046 Surface Evolution Roadmap And Product Line Continuity Policy`
- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09730 Provider Evidence Review Packet And Capability Acceptance Matrix Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09990 AI pgvector Governance Catalog Static Package Handoff And Non Authority Boundary Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- SaaS entitlement registry
- package-to-capability matrix
- package activation workflow
- billing-to-feature boundary
- trial/pilot package runbook
- package upgrade/downgrade workflow
- package suspension and safe projection policy
- future pricing model documentation

This document is architecture planning only.

It does not authorize coding.

---

## 34. Final Rule

SaaS packages may define commercial entitlement, but they must not define runtime authority.

A tenant may purchase or be assigned a package, but feature exposure and execution still require provider capability, tenant entitlement, store activation, policy gate, runtime feature flag, authority boundary, evidence requirement, audit requirement, Use Case API approval, and Safe Projection output.

Pricing must not bypass governance.

Entitlement must not bypass provider evidence.

Package upgrade must not bypass policy.

Package downgrade must not delete evidence.

AI remains advisory.

pgvector remains reference only.

Franchise OS remains governed by the shared SaaS core.

Runtime implementation remains deferred until separately authorized.
