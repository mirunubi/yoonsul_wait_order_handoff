# 10046 Surface Evolution Roadmap And Product Line Continuity Policy

## 1. Purpose

This document defines the Surface Evolution Roadmap and Product Line Continuity Policy.

The previous artifact `10045` defined the Franchise OS Capability Inheritance and Tenant Store Assembly Policy.

This document summarizes the long-term product evolution chain from Catch Menu to Catch & Order, Mini Kiosk, Full Kiosk, Store Runtime, Admin Surfaces, and Franchise OS.

The purpose is to ensure that each surface evolves from the same shared SaaS core instead of becoming a disconnected product line.

This document records the principle that product surfaces may change, expand, merge, or upgrade, but the authority model, object core, capability control plane, provider evidence, i18n, audit, recovery, compensation, AI, pgvector, and runtime-entry boundaries must remain consistent.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

The product line must evolve by reuse, not duplication.

The correct rule is:

Catch Menu begins the customer entry surface.
Catch & Order adds order handoff.
Mini Kiosk device-shapes the same customer surface.
Full Kiosk adds CMS, payment, POS/KDS, and device control.
Store Runtime connects operations.
Admin Surfaces manage review and configuration.
Franchise OS assembles and governs the entire system.

Each surface may add capability.

No surface may bypass the shared core.

---

## 3. Product Line Continuity Chain

The intended product continuity chain is:

    Catch Menu
      ↓
    Catch & Order
      ↓
    Mini Kiosk
      ↓
    Full Kiosk
      ↓
    Store Runtime
      ↓
    Admin Surface
      ↓
    Franchise OS
      ↓
    Multi-Brand / Multi-Store SaaS Platform

This is not a set of separate applications.

This is one evolving SaaS platform with multiple surfaces.

---

## 4. Surface Evolution Map

| Stage | Surface | Main Role |
|---|---|---|
| Stage 1 | `Catch Menu` | Lightweight menu entry |
| Stage 2 | `Catch & Order` | Menu plus order handoff |
| Stage 3 | `Mini Kiosk` | Device-based menu/order intent |
| Stage 4 | `Full Kiosk` | CMS/payment/POS/KDS capable device surface |
| Stage 5 | `Store Runtime` | POS/KDS/payment/recovery/support connected store operation |
| Stage 6 | `Admin Surface` | Review, configuration, evidence, device, provider, CMS, feature control |
| Stage 7 | `Franchise OS` | Multi-store capability assembly and governance |
| Stage 8 | `SaaS Platform` | Multi-tenant, multi-brand, provider-aware, policy-governed platform |

Each stage must preserve backward compatibility where possible.

---

## 5. Catch Menu Continuity Rule

Catch Menu must be designed as the lightweight base surface.

It should provide reusable foundations for:

- menu projection
- item availability display
- customer-safe status display
- price display
- allergen notice display if approved
- i18n message key usage
- CMS notice slot if approved
- QR/NFC entry
- customer session continuity
- staff assistance route
- order intent entry if enabled

Catch Menu must not be a disposable web page.

Catch Menu must be a reusable customer surface foundation.

---

## 6. Catch & Order Continuity Rule

Catch & Order extends Catch Menu by adding order handoff capability.

It may add:

- order intent
- cart
- order submission
- POS handoff request
- payment checking status if applicable
- KDS customer-safe visibility if applicable
- support route
- recovery route
- duplicate guard
- fallback state
- customer-safe order projection

Catch & Order must not become a separate order system.

It must use the same Domain Object Core, Use Case API, Safe Projection, and Capability Control Plane.

---

## 7. Mini Kiosk Continuity Rule

Mini Kiosk extends Catch Menu and Catch & Order into a physical or fixed device surface.

It may add:

- device identity
- Device Profile
- runtime configuration
- kiosk surface lock
- guided menu/order flow
- staff assist button
- degraded operation display
- safe CMS notice slot
- local device status
- device revoke handling

Mini Kiosk must not create separate business logic.

Mini Kiosk is Catch Menu and Catch & Order expressed through a controlled device.

---

## 8. Full Kiosk Continuity Rule

Full Kiosk extends Mini Kiosk.

It may add:

- CMS home screen
- CMS campaign panels
- kiosk payment mode
- POS handoff
- KDS visibility
- staff assist workflow
- receipt or printer route
- device health monitoring
- provider profile
- store profile
- franchise policy inheritance
- offline/degraded mode
- rollback and emergency disable

Full Kiosk must remain a surface.

It must not become payment truth, POS truth, KDS truth, settlement truth, or compensation authority.

---

## 9. Store Runtime Continuity Rule

Store Runtime connects the operational environment.

It may include:

- POS bridge
- KDS bridge
- payment provider integration
- CMS projection
- support/admin review
- recovery case workflow
- compensation request workflow
- device fleet state
- provider health
- incident/degraded mode
- audit/evidence collection
- local agent support if Windows
- Android provisioning if Kiosk/tablet
- staff tablet visibility

Store Runtime must remain governed by the same Control Plane.

Store Runtime must not bypass product surface boundaries.

---

## 10. Admin Surface Continuity Rule

Admin Surfaces must be designed as reusable governance surfaces.

Admin Surfaces may cover:

- Catch Menu configuration
- Catch & Order configuration
- Mini Kiosk configuration
- Full Kiosk configuration
- device management
- provider evidence review
- feature control
- tenant plan
- store runtime configuration
- CMS approval
- i18n review
- support review
- recovery case review
- compensation review
- incident/degraded mode
- audit/evidence review
- franchise policy configuration

Admin Surfaces created early must be reusable by Franchise OS later.

Admin UI is not authority.

Authority is server-side.

---

## 11. Franchise OS Continuity Rule

Franchise OS is the upper governance and assembly layer.

It must reuse:

- Domain Object Core
- Use Case APIs
- Safe Projections
- Admin Surfaces
- Device Profiles
- Runtime Configuration
- Provider Capability Matrix
- Tenant Feature Plan
- Store Runtime Configuration
- Policy Gate
- Runtime Feature Flags
- i18n Message Key Registry
- Audit/Evidence model
- Recovery/Compensation boundary
- AI/pgvector advisory boundary

Franchise OS must not duplicate product logic.

Franchise OS must add governance, not fragmentation.

---

## 12. Product Surface Versus Core Authority

Product surfaces may change.

Core authority must remain stable.

| Product Surface | Must Not Own |
|---|---|
| Catch Menu | Order/payment/provider truth |
| Catch & Order | Payment settlement truth |
| Mini Kiosk | Business authority |
| Full Kiosk | Payment/POS/KDS/compensation authority |
| Staff Tablet | Financial authority by visibility alone |
| Admin Surface | Mutation authority by page access alone |
| Franchise OS | Security/financial/legal bypass |
| CMS Surface | Legal/customer message approval by text existence |
| AI Surface | Decision authority |
| pgvector Surface | Proof authority |

Surface is not source of truth.

---

## 13. Product Upgrade Compatibility Rule

Every product upgrade must be compatible with the shared core.

Upgrade must check:

- tenant plan
- store profile
- provider capability
- Device Profile
- runtime configuration
- policy gate
- authority boundary
- i18n readiness
- CMS approval if needed
- Safe Projection availability
- audit event mapping
- rollback capability
- emergency disable capability
- support route
- degraded mode
- app version compatibility
- provider evidence status

Upgrade must not depend on hardcoded frontend behavior.

---

## 14. Product Downgrade And Fallback Rule

Every product surface must support downgrade or fallback where possible.

Examples:

| Normal Surface | Fallback |
|---|---|
| Full Kiosk payment | Staff-assisted payment |
| POS handoff | Staff confirmation |
| KDS visibility | Staff-managed status |
| CMS campaign | Approved fallback notice |
| Catch & Order | Catch Menu only |
| Mini Kiosk | Menu display mode |
| Store Runtime | Degraded operation |
| AI support | Manual support review |
| pgvector lookup | Manual policy lookup |
| Provider integration | Provider unavailable safe state |

Fallback must be safe, auditable, and customer-readable.

Fallback must not create authority.

---

## 15. Product Line Naming Rule

Recommended naming map:

| Name | Meaning |
|---|---|
| `Catch Menu` | Lightweight customer menu access |
| `Catch & Order` | SaaS menu/order/POS-KDS handoff service |
| `Mini Kiosk` | Device-based lightweight customer menu/order surface |
| `Full Kiosk` | CMS/payment/POS/KDS-capable kiosk surface |
| `Store Runtime` | Store operation integration layer |
| `Admin Surface` | Reusable review/configuration surface |
| `Franchise OS` | Multi-store SaaS governance and assembly layer |
| `Provider Control` | Provider evidence/capability governance |
| `Device Control` | Device provisioning/runtime configuration governance |
| `CMS Control` | Controlled content publication governance |

Names must clarify role.

Names must not imply authority.

---

## 16. SaaS Packaging Rule

Product surfaces may be packaged differently by SaaS plan.

Example packages:

| Package | Included Surfaces |
|---|---|
| `Menu Starter` | Catch Menu |
| `Order Starter` | Catch Menu + Catch & Order |
| `Mini Kiosk Pack` | Catch Menu + Mini Kiosk |
| `Kiosk Standard` | Mini Kiosk + CMS + staff assist |
| `Kiosk Payment` | Full Kiosk + payment mode if verified |
| `Store Runtime` | Full Kiosk + POS/KDS/payment/recovery/support |
| `Franchise Core` | Admin Surface + multi-store governance |
| `Franchise Advanced` | Franchise OS + provider/device/CMS/policy inheritance |
| `AI Assist Pack` | AI advisory only |
| `Vector Context Pack` | pgvector context retrieval only |

Package inclusion does not bypass policy.

Feature availability still requires the Control Plane.

---

## 17. Multi-Brand Continuity Rule

The product line must support future multi-brand operation.

A tenant or Franchise OS may support:

- 윤슬김밥
- 윤슬마루
- future bowl/noodle/salad brands
- white-label tenant brand
- partner brand
- regional brand variant
- campaign-specific brand surface

Brand variation must use:

- brand policy
- i18n message family
- CMS template
- menu projection policy
- store profile
- device profile
- provider profile
- tenant plan

Brand variation must not duplicate the core.

---

## 18. Multi-Provider Continuity Rule

The product line must support multiple providers.

Examples:

- POS provider
- payment provider
- KDS provider
- CMS provider
- messaging provider
- reservation/waiting provider
- delivery provider
- workforce provider
- AI provider
- vector/embedding provider

Provider variation must be controlled by Provider Capability Matrix and evidence.

Provider-specific behavior must not be hardcoded into each surface.

---

## 19. Multi-Device Continuity Rule

The product line must support multiple device families.

Examples:

- customer smartphone
- QR/NFC table
- Android Mini Kiosk
- Android Full Kiosk
- Windows Kiosk
- Windows local agent
- staff tablet
- owner tablet
- HQ admin web
- support/admin web
- kitchen display
- printer/peripheral controller
- future physical AI/robot interface

Device differences must be handled by Device Profile, Runtime Configuration, and Safe Projection.

Device does not define authority.

---

## 20. CMS Continuity Rule

CMS must evolve from simple content to governed multi-surface content.

CMS may support:

- Catch Menu notice
- Mini Kiosk notice
- Full Kiosk home screen
- menu promotion
- campaign banner
- outage notice
- degraded operation notice
- allergen notice
- payment guidance
- support guidance
- franchise policy notice
- emergency announcement
- training material
- staff/admin notice

CMS must preserve approval, i18n, audit, rollback, and policy boundaries.

---

## 21. i18n Continuity Rule

i18n must remain platform-level.

All surfaces should reuse the same i18n registry where possible:

- Catch Menu
- Catch & Order
- Mini Kiosk
- Full Kiosk
- Staff Tablet
- Admin Surface
- Support/Admin
- Franchise OS
- CMS
- recovery messages
- payment messages
- provider delay messages
- degraded operation messages
- AI draft labels

No customer-facing operational text should be hardcoded into one surface.

---

## 22. AI And pgvector Continuity Rule

AI and pgvector may support the product line as advisory infrastructure.

AI may support:

- customer support draft
- incident summary
- provider evidence summary
- CMS draft suggestion
- i18n draft suggestion
- admin review summary
- missing evidence checklist
- store comparison summary
- training material draft

pgvector may support:

- similar policy lookup
- similar incident lookup
- similar support case lookup
- similar provider limitation lookup
- prior recovery pattern lookup
- admin reference retrieval

AI and pgvector must not become authority.

AI is not authority.

pgvector is not proof.

---

## 23. Workforce Continuity Rule

Future workforce interfaces may attach to the same product line.

Possible integrations:

- staff tablet access
- staff assist routing
- staff role-based surface
- shift-based authority
- store incident acknowledgement
- training surface
- local workforce notice
- external workforce channel
- Franchise OS workforce coordination

Workforce interface must follow role, authority, audit, and policy rules.

Workforce visibility is not financial authority.

---

## 24. Provider Marketplace Continuity Rule

The product line may later support a provider marketplace or provider control layer.

Provider marketplace may include:

- POS provider profile
- payment provider profile
- KDS provider profile
- CMS provider profile
- delivery provider profile
- waiting/reservation provider profile
- workforce provider profile
- AI provider profile
- messaging provider profile

Provider marketplace must be evidence-based.

Provider onboarding must not mean automatic capability approval.

---

## 25. Audit Continuity Rule

Audit must survive product evolution.

The same audit model should trace:

- Catch Menu entry
- order intent
- Mini Kiosk device action
- Full Kiosk payment request
- POS handoff
- KDS status event
- staff assist
- CMS publication
- admin configuration
- provider assignment
- device profile change
- runtime config change
- feature flag change
- support review
- recovery case
- compensation request
- franchise policy change
- emergency disable
- rollback
- incident closure

Audit continuity is the backbone of SaaS governance.

---

## 26. Product Roadmap Governance Rule

Roadmap decisions must separate:

- product surface
- core object
- Use Case API
- Safe Projection
- provider capability
- device capability
- tenant plan
- store configuration
- policy authority
- runtime feature flag
- admin authority
- audit evidence
- rollout stage
- rollback path

A product roadmap item must not be approved merely because the UI is easy.

Every roadmap item must declare authority and dependency.

---

## 27. Runtime Entry Deferral Rule

This roadmap does not authorize implementation.

The following remain deferred:

- Catch Menu runtime changes
- Catch & Order runtime changes
- Mini Kiosk runtime implementation
- Full Kiosk runtime implementation
- CMS runtime publication
- payment/POS/KDS provider integration
- Franchise OS runtime implementation
- Admin Surface implementation
- AI runtime
- pgvector ingestion/retrieval
- Device Profile implementation
- Runtime Configuration implementation
- database schema creation
- production deployment

Separate explicit authorization is required.

---

## 28. Surface Evolution Anti-Patterns

Avoid:

- building Catch Menu as disposable page
- building Mini Kiosk as isolated app
- building Full Kiosk as separate payment/order system
- building Admin Pages that cannot be reused by Franchise OS
- hardcoding provider logic per surface
- hardcoding store policy per device
- creating tenant-specific APKs by default
- treating feature package as authority
- ignoring rollback path
- ignoring degraded mode
- duplicating i18n per surface
- duplicating CMS per surface
- duplicating audit per product
- letting AI decide
- letting pgvector prove
- letting frontend assemble raw objects

These anti-patterns break product continuity.

---

## 29. Validation Checklist

Validation must confirm:

1. Catch Menu is reusable.
2. Catch & Order extends Catch Menu without duplicating core.
3. Mini Kiosk reuses Catch Menu and Catch & Order foundations.
4. Full Kiosk extends Mini Kiosk through capability control.
5. Store Runtime uses shared integration boundaries.
6. Admin Surfaces are reusable by Franchise OS.
7. Franchise OS assembles rather than duplicates.
8. Product surfaces do not own authority.
9. Product upgrades check Control Plane gates.
10. Product fallback and downgrade are defined.
11. Product naming does not imply authority.
12. SaaS packages do not bypass policy.
13. Multi-brand support avoids core duplication.
14. Multi-provider support is evidence-based.
15. Multi-device support uses Device Profile and Safe Projection.
16. CMS continuity is controlled.
17. i18n continuity is platform-level.
18. AI remains advisory.
19. pgvector remains non-proof.
20. Workforce and provider marketplace can attach later.
21. Audit continuity is preserved.
22. Runtime remains deferred.

---

## 30. Relationship To Previous Documents

This document follows:

- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`
- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`
- `10045 Franchise OS Capability Inheritance And Tenant Store Assembly Policy`

It references:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `09990 AI pgvector Governance Catalog Static Package Handoff And Non Authority Boundary Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- product line capability matrix
- surface reuse registry
- SaaS packaging and pricing boundary
- product upgrade/downgrade runbook
- product line release governance
- Franchise OS admin reuse plan
- future runtime implementation candidate selection

This document is architecture planning only.

It does not authorize coding.

---

## 31. Final Rule

The product line must evolve continuously from Catch Menu to Catch & Order, Mini Kiosk, Full Kiosk, Store Runtime, Admin Surface, and Franchise OS.

Each surface may add capability, device identity, CMS, payment, POS/KDS, support, recovery, admin, AI, pgvector, or franchise governance, but no surface may become an isolated source of truth.

The shared SaaS core remains authoritative.

The Domain Object Core owns meaning.

The Domain Capability Control Plane resolves availability.

The Use Case API coordinates workflow.

The Safe Projection controls visibility.

Admin Surfaces must be reusable.

Franchise OS must assemble capabilities.

Product evolution must preserve authority, evidence, i18n, audit, provider, policy, recovery, compensation, AI, pgvector, rollback, degraded mode, and runtime-entry boundaries.

Runtime implementation remains deferred until separately authorized.
