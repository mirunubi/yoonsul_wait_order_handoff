# 10045 Franchise OS Capability Inheritance And Tenant Store Assembly Policy

## 1. Purpose

This document defines the Franchise OS Capability Inheritance and Tenant Store Assembly Policy.

The previous artifact `10044` defined the Mini Kiosk to Full Kiosk CMS, Payment, and Device Expansion Policy.

This document defines how Franchise OS must inherit, assemble, constrain, and govern capabilities across tenant, brand, operating group, legal entity, store, provider, device, surface, service type, policy, runtime mode, and admin authority.

Franchise OS must not be a separate duplicated product.

Franchise OS must be the upper governance and assembly layer that reuses the shared SaaS core, Domain Object Core, Use Case APIs, Safe Projections, Admin Surfaces, Device Profiles, Runtime Configuration, Provider Capability Matrix, i18n registry, audit/evidence model, and Domain Capability Control Plane.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Franchise OS is not a separate logic stack.

Franchise OS is the multi-store governance layer.

The correct rule is:

Shared core owns business meaning.
Domain Capability Control Plane decides availability.
Use Case APIs coordinate workflows.
Safe Projections expose role-safe views.
Admin Surfaces provide reusable review and configuration.
Franchise OS inherits and constrains capability by policy.

Franchise OS must assemble capabilities.

It must not duplicate them.

---

## 3. Franchise OS Role

Franchise OS may manage:

- tenant capability plans
- brand-level policies
- store-level configuration
- operating group visibility
- provider assignment
- POS/KDS/payment capability profiles
- Catch Menu availability
- Catch & Order availability
- Mini Kiosk availability
- Full Kiosk availability
- CMS templates
- admin surfaces
- device profiles
- runtime configuration
- support routes
- recovery routes
- compensation authority
- i18n locale requirements
- incident/degraded mode
- audit/evidence visibility
- franchise policy inheritance
- store upgrade path
- feature rollout/rollback

Franchise OS is a governance system.

It is not merely a dashboard.

---

## 4. Assembly Hierarchy

Franchise OS must support controlled capability assembly across multiple context axes.

Recommended context hierarchy:

    Tenant
      ↓
    Brand
      ↓
    Operating Group
      ↓
    Legal Entity / Company Context
      ↓
    Store
      ↓
    Device
      ↓
    Surface
      ↓
    Feature / Capability
      ↓
    Runtime Mode

This hierarchy must not be treated as a simple parent-child tree in all cases.

Legal entity and operating group may be parallel axes.

Policy resolution must explicitly define precedence.

---

## 5. Tenant-Level Capability

Tenant-level capability defines what the SaaS customer or franchise organization may use.

Examples:

| Capability | Meaning |
|---|---|
| `tenant.catch_menu.enabled` | Tenant may use Catch Menu |
| `tenant.catch_order.enabled` | Tenant may use Catch & Order |
| `tenant.kiosk.enabled` | Tenant may use Kiosk |
| `tenant.franchise_os.enabled` | Tenant may use Franchise OS |
| `tenant.cms.enabled` | Tenant may use CMS |
| `tenant.pos_integration.enabled` | Tenant may use POS integration |
| `tenant.kds_integration.enabled` | Tenant may use KDS integration |
| `tenant.payment_integration.enabled` | Tenant may use payment integration |
| `tenant.recovery.enabled` | Tenant may use recovery case workflow |
| `tenant.compensation.enabled` | Tenant may use compensation review workflow |
| `tenant.ai_support.enabled` | Tenant may use AI support assistance |
| `tenant.pgvector_context.enabled` | Tenant may use vector context retrieval |

Tenant capability does not automatically enable every store.

---

## 6. Brand-Level Policy

Brand-level policy defines how capabilities behave for a brand.

Examples:

- brand menu exposure rules
- brand CMS templates
- brand tone and i18n message family
- brand customer recovery tone
- brand coupon policy
- brand payment mode restrictions
- brand kiosk screen layout policy
- brand allergen notice rule
- brand staff assistance rule
- brand campaign approval rule
- brand degraded operation message policy
- brand support escalation policy
- brand provider preference
- brand audit visibility rule

Brand policy can constrain tenant-level capability.

Brand policy must not bypass security or financial controls.

---

## 7. Operating Group Policy

Operating group policy may define operational differences by region, division, supervisor group, or store cluster.

Examples:

- region-specific campaign
- supervisor group visibility
- operating group support route
- operating group Kiosk rollout
- operating group CMS approval
- operating group incident handling
- operating group provider assignment
- operating group staff assist rule
- operating group degraded mode policy
- operating group store upgrade phase

Operating group policy must not override legal, financial, security, or HQ-required policy unless explicitly allowed.

---

## 8. Legal Entity And Company Context

Legal entity or company context may affect:

- settlement
- tax
- contract
- payment provider account
- invoice routing
- franchise agreement
- liability boundary
- payroll or workforce integration
- accounting export
- refund settlement responsibility
- revenue allocation
- legal hold
- dispute handling

Legal entity context must not be merged blindly with operating group context.

A store may belong to one legal entity and one operating group, but policy resolution must clearly separate operational grouping from legal/settlement authority.

---

## 9. Store-Level Assembly

Store-level assembly defines what a specific store actually uses.

Examples:

| Store Capability | Meaning |
|---|---|
| `store.catch_menu.enabled` | Store uses Catch Menu |
| `store.catch_order.enabled` | Store uses Catch & Order |
| `store.mini_kiosk.enabled` | Store uses Mini Kiosk |
| `store.full_kiosk.enabled` | Store uses Full Kiosk |
| `store.cms.enabled` | Store uses CMS surfaces |
| `store.kiosk_payment.mode` | Store Kiosk payment mode |
| `store.pos_handoff.mode` | Store POS handoff mode |
| `store.kds.mode` | Store KDS mode |
| `store.staff_assist.enabled` | Staff assist enabled |
| `store.degraded_mode.allowed` | Degraded mode allowed |
| `store.offline_mode.allowed` | Offline operation allowed within limits |

Store-level configuration must be constrained by tenant, brand, franchise, provider, and policy gates.

---

## 10. Device-Level Assembly

Device-level assembly defines what a specific device can do.

Device capabilities may include:

- device role
- surface type
- allowed modules
- payment mode
- KDS visibility
- CMS profile
- locale set
- offline mode eligibility
- fallback mode
- config version
- app version
- update channel
- device status
- device revoke status
- emergency disable status

Device assembly must be controlled through Device Profile and Runtime Configuration.

A physical device must not self-select authority.

---

## 11. Surface-Level Assembly

Surface-level assembly defines what a surface may render or request.

Surfaces may include:

- Catch Menu
- Catch & Order
- Mini Kiosk
- Full Kiosk
- Staff Tablet
- Owner Admin
- HQ Admin
- Support/Admin
- CMS Admin
- Device Admin
- Franchise OS Admin
- Kitchen visibility surface
- Payment assist surface

Surface access is not authority.

Surface must receive Safe Projection.

Use Case API must decide allowed commands.

---

## 12. Provider Capability Inheritance

Provider capability must be inherited through evidence, not assumption.

Franchise OS may assign provider profiles to tenants, brands, stores, or devices.

Examples:

- OKPOS profile for Store A
- Smartro payment profile for Store B
- KDS provider profile for Store C
- CMS provider profile for Brand X
- messaging provider profile for Tenant Y

Provider profile assignment must reference:

- evidence status
- verified capability
- known limitation
- failure mode
- callback support
- idempotency support
- retry support
- reconciliation requirement
- support contact route
- contract status if relevant

Provider name is not capability proof.

---

## 13. Policy Precedence Rule

Franchise OS must define policy precedence.

Recommended precedence order:

    Security / Legal / Financial Control
      ↓
    Platform Foundation Policy
      ↓
    Tenant Contract / Plan
      ↓
    HQ / Franchise Policy
      ↓
    Brand Policy
      ↓
    Operating Group Policy
      ↓
    Legal Entity / Settlement Policy
      ↓
    Store Configuration
      ↓
    Device Runtime Configuration
      ↓
    Runtime Feature Flag
      ↓
    Surface Projection

Higher policy may constrain lower policy.

Lower policy must not expand higher-risk authority.

---

## 14. Capability Resolution Rule

Capability resolution must be explicit.

Recommended evaluation:

    CapabilityAllowed =
      PlatformPolicy
      AND TenantPlan
      AND FranchisePolicy
      AND BrandPolicy
      AND StoreConfig
      AND DeviceProfile
      AND ProviderCapability
      AND RuntimeFlag
      AND AuthorityBoundary
      AND EvidenceRequirement
      AND AuditRequirement

For customer-visible features:

    CustomerVisible =
      CapabilityAllowed
      AND SafeProjectionAvailable
      AND i18nKeyReady
      AND FallbackReady

For financial/value actions:

    ValueActionAllowed =
      CapabilityAllowed
      AND FinancialAuthority
      AND Idempotency
      AND Reconciliation
      AND Audit
      AND ReviewApproval

Feature visibility is not execution authority.

---

## 15. Franchise OS Admin Surface Reuse Rule

Franchise OS should reuse admin surfaces created for:

- Catch Menu configuration
- Mini Kiosk configuration
- Full Kiosk configuration
- Device Profile management
- Runtime Configuration management
- CMS approval
- i18n review
- provider evidence review
- feature capability control
- support review
- recovery case review
- compensation request review
- incident/degraded mode review
- audit/evidence review

Franchise OS adds multi-store and policy inheritance context.

It should not duplicate single-store admin logic.

---

## 16. Admin Authority Inheritance Rule

Admin authority must be inherited carefully.

Example roles:

| Role | Possible Authority |
|---|---|
| Store Owner | Store-level low-risk configuration request |
| Store Manager | Operational review and staff assist |
| Support Admin | Case review and customer response draft |
| Finance Admin | Refund/value review |
| HQ Admin | Tenant/brand/store policy governance |
| Franchise Operator | Multi-store policy application within bounds |
| Provider Ops | Provider evidence review |
| Device Ops | Device suspend/revoke/config review |
| Legal Admin | Legal-sensitive content/recovery review |
| Security Admin | Containment, revoke, and security review |

Same admin page may show different actions by role.

Role visibility is not action authority.

---

## 17. Store Upgrade Inheritance Rule

Franchise OS may manage store upgrade stages.

Example:

| Stage | Capability |
|---|---|
| `STORE_STAGE_CATCH_MENU` | Catch Menu only |
| `STORE_STAGE_ORDER_INTENT` | Catch Menu plus order intent |
| `STORE_STAGE_MINI_KIOSK` | Mini Kiosk |
| `STORE_STAGE_MINI_KIOSK_PAYMENT_ASSIST` | Mini Kiosk plus staff-assisted payment |
| `STORE_STAGE_FULL_KIOSK_CMS` | Full Kiosk plus CMS |
| `STORE_STAGE_FULL_KIOSK_POS` | Full Kiosk plus POS handoff |
| `STORE_STAGE_FULL_RUNTIME` | POS/KDS/payment/recovery/support integrated |
| `STORE_STAGE_FRANCHISE_GOVERNED` | Franchise OS governed store |

Store upgrade must be capability-driven.

Store upgrade must not create authority automatically.

---

## 18. Store Template Rule

Franchise OS may define store templates.

Examples:

- Catch Menu-only store template
- Mini Kiosk store template
- Kiosk with staff-assisted payment template
- Full Kiosk with CMS template
- Full Kiosk with POS handoff template
- Full Kiosk with payment verification template
- POS/KDS integrated template
- high-volume franchise store template
- pilot store template
- degraded/fallback store template

Templates must be policy-constrained.

Template application must be auditable.

Template is not runtime authority by itself.

---

## 19. Provider Assignment Rule

Franchise OS may assign providers by tenant, brand, store, or device.

Provider assignment must define:

- provider id
- provider type
- capability evidence
- store assignment
- device assignment if applicable
- supported feature set
- limitation
- degraded behavior
- fallback route
- support route
- effective time
- expiry or review date
- audit reference

Provider assignment must not imply all provider features are available.

---

## 20. CMS Inheritance Rule

Franchise OS may manage CMS inheritance.

CMS policy may inherit through:

- tenant default CMS policy
- brand CMS template
- operating group campaign
- store-specific notice
- emergency HQ announcement
- legal/security override
- locale-specific content
- device surface-specific projection

CMS inheritance must define override rules.

Emergency announcement may override local content, but must still be audited and customer-safe.

---

## 21. i18n Inheritance Rule

Franchise OS must support i18n inheritance.

Locale policies may define:

- tenant default locales
- brand required locales
- store available locales
- device available locales
- customer-selected locale
- fallback locale
- legal/allergen message requirements
- support/admin language requirement
- CMS locale publication status

All human-visible text must reference approved i18n keys or approved CMS projections.

Locale support is a platform capability, not per-surface duplication.

---

## 22. Payment And Value Authority Inheritance Rule

Payment and value actions must have strict inheritance controls.

Franchise OS may configure:

- payment mode
- self-payment eligibility
- staff-assisted payment
- refund request route
- refund review authority
- coupon issue authority
- point adjustment authority
- wallet/prepaid authority
- compensation escalation route
- reconciliation requirement
- finance approval rule

Franchise OS must not allow store templates or device settings to bypass financial authority.

Payment visibility is not payment truth.

Compensation request is not execution.

---

## 23. Recovery And Support Inheritance Rule

Franchise OS may configure recovery and support rules.

Examples:

- store-level recovery route
- brand recovery tone
- HQ escalation threshold
- support queue assignment
- compensation review path
- customer message approval requirement
- incident grouping rule
- mass recovery rule
- recurrence prevention handoff
- legal review trigger
- provider fault review trigger

Recovery must remain evidence-based.

Support visibility must not become mutation authority.

---

## 24. Incident And Degraded Mode Inheritance Rule

Franchise OS must support incident and degraded mode inheritance.

Examples:

- provider outage at all stores
- payment degraded at one store
- KDS degraded at one region
- CMS emergency notice at tenant level
- security containment at device level
- order handoff disabled by provider profile
- coupon issue disabled globally
- wallet disabled by finance policy
- AI support disabled by security policy

Degraded mode must be explicit, auditable, and reversible.

Containment is not resolution.

---

## 25. Device Fleet Management Rule

Franchise OS may manage device fleets.

Device fleet management may include:

- device registration
- device assignment
- device role
- device profile
- runtime config version
- app version
- update channel
- kiosk mode status
- revoke/suspend status
- offline eligibility
- health status
- last sync
- emergency disable
- replacement tracking

Device fleet management must not expose secrets.

Device revoke must be immediate where possible.

---

## 26. Workforce Interface Inheritance Rule

Future workforce interfaces may also inherit Franchise OS capability controls.

Examples:

- staff role visibility
- staff tablet access
- staff assist routing
- manager approval
- shift-based authority
- support escalation
- training surface
- device responsibility
- incident acknowledgement
- store operation notes

Workforce interface must follow the same role, authority, audit, and policy principles.

Staff role visibility is not financial authority.

---

## 27. External Channel Inheritance Rule

Future external channels may also be assembled through Franchise OS.

Examples:

- delivery app interface
- reservation/waiting app interface
- local workforce notice channel
- marketing campaign channel
- CRM messaging channel
- partner menu exposure
- external CMS publication
- external order aggregation
- provider marketplace integration

External channel capability must reference provider evidence, tenant plan, policy gate, i18n, audit, and Safe Projection.

External channel is not internal truth.

---

## 28. AI And pgvector Inheritance Rule

Franchise OS may expose AI and pgvector advisory functions to authorized admin surfaces.

AI may assist:

- store comparison summary
- incident summary
- provider limitation summary
- missing evidence checklist
- support case summary
- CMS draft suggestion
- i18n draft suggestion
- training material draft
- policy lookup summary

pgvector may assist:

- similar incident lookup
- similar support case lookup
- similar policy lookup
- provider limitation lookup
- historical recovery pattern lookup

AI and pgvector must not:

- approve policy override
- approve compensation
- execute refund
- publish CMS
- confirm provider fault
- decide payment truth
- release containment
- bypass human review

AI is not authority.

pgvector is not proof.

---

## 29. Audit And Evidence Inheritance Rule

Franchise OS must preserve audit continuity.

Auditable actions include:

- tenant plan change
- brand policy change
- store config change
- device profile change
- provider assignment
- feature flag change
- CMS approval
- i18n approval
- support/recovery routing
- compensation review
- payment mode change
- Kiosk mode change
- emergency disable
- store upgrade
- template application
- franchise policy override
- incident/degraded mode activation
- device revoke/replacement

Audit must survive product surface evolution.

---

## 30. Franchise OS Anti-Patterns

Avoid:

- Franchise OS as separate duplicated product
- rebuilding admin pages from scratch without reuse
- store template granting financial authority
- provider assignment treated as capability proof
- brand policy overriding security/finance controls
- device role granting payment/refund authority
- support visibility becoming mutation authority
- CMS inheritance publishing unreviewed content
- locale duplication per surface
- feature flag bypassing policy gate
- AI used as policy authority
- pgvector used as proof
- cross-store visibility without role boundary
- legal entity and operating group merged incorrectly
- emergency disable deleting evidence

These anti-patterns destroy SaaS governance.

---

## 31. Validation Checklist

Validation must confirm:

1. Franchise OS reuses shared SaaS core.
2. Franchise OS does not duplicate product logic.
3. Tenant, brand, operating group, legal entity, store, device, surface, and feature axes are separated.
4. Policy precedence is defined.
5. Capability resolution is explicit.
6. Store upgrades are capability-driven.
7. Admin surfaces are reusable.
8. Admin authority is role and policy controlled.
9. Provider capability is evidence-based.
10. CMS inheritance is controlled.
11. i18n inheritance is controlled.
12. Payment/value authority is strict.
13. Recovery/support inheritance is evidence-based.
14. Incident/degraded mode inheritance is auditable.
15. Device fleet management supports revoke/suspend.
16. Workforce and external channels can inherit the same control model.
17. AI remains advisory.
18. pgvector remains non-proof.
19. Audit continuity is preserved.
20. Runtime remains deferred.

---

## 32. Relationship To Previous Documents

This document follows:

- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`
- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`

It references:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09730 Provider Evidence Review Packet And Capability Acceptance Matrix Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `09990 AI pgvector Governance Catalog Static Package Handoff And Non Authority Boundary Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- `10046 Surface Evolution Roadmap And Product Line Continuity Policy`
- Franchise OS capability registry
- Franchise OS tenant/store assembly matrix
- Franchise OS admin reuse matrix
- Franchise OS policy precedence registry
- Franchise OS device fleet management schema
- Franchise OS store upgrade workflow
- Franchise OS rollout and rollback runbook

This document is architecture planning only.

It does not authorize coding.

---

## 33. Final Rule

Franchise OS must be the upper capability assembly and governance layer for Catch Menu, Catch & Order, Mini Kiosk, Full Kiosk, POS, KDS, CMS, Payment, Recovery, Compensation, Support/Admin, Device Fleet, Provider, i18n, AI, pgvector, Workforce, and external channel capabilities.

It must inherit from the shared SaaS core.

It must reuse existing Admin Surfaces.

It must assemble capabilities by tenant, brand, operating group, legal entity, store, device, provider, surface, feature, policy, runtime mode, and authority boundary.

Franchise OS must not duplicate product logic.

Franchise OS must not bypass financial, legal, security, provider evidence, i18n, audit, recovery, compensation, AI, pgvector, or runtime-entry controls.

The shared core remains authoritative.

The Control Plane resolves capability.

The Use Case API coordinates workflow.

The Safe Projection controls visibility.

Runtime implementation remains deferred until separately authorized.
