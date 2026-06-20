# 010043_Policy_Catch_Menu_Mini_Kiosk_Admin_Surface_Reuse_And_Franchise_OS_Upgrade_Path

## 1. Purpose

This document defines the Catch Menu, Mini Kiosk, Admin Surface Reuse, and Franchise OS Upgrade Path Policy.

The previous artifacts defined:

- modular SaaS core reuse
- Domain Object Core
- Use Case API
- Safe Projection
- Domain Capability Control Plane
- Windows installation model
- Android provisioning model

This document records the product evolution principle that Catch Menu, Mini Kiosk, Kiosk, Admin Pages, and Franchise OS must not be built as isolated products.

They must reuse the same core objects, use case APIs, safe projections, device profiles, runtime configuration, admin review surfaces, i18n registry, provider evidence, audit boundary, and capability control plane.

Catch Menu can evolve into Mini Kiosk.

Mini Kiosk can evolve into full Kiosk.

The Admin Pages created for these systems can later be reused inside Franchise OS.

Franchise OS can assemble these surfaces and capabilities by tenant, brand, store, provider, device, and policy.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

The correct product evolution rule is:

Catch Menu is the customer entry surface.
Mini Kiosk is the device-shaped extension of Catch Menu.
Full Kiosk is Mini Kiosk plus CMS, payment, POS/KDS, staff assist, and device provisioning.
Admin Surface is the operational review and configuration layer.
Franchise OS is the upper assembly and governance layer.

The same core must be reused across all of them.

No surface should become a separate product silo.

---

## 3. Product Evolution Chain

The intended evolution chain is:

    Catch Menu
      ↓
    Catch Menu + Order Intent
      ↓
    Mini Kiosk
      ↓
    Mini Kiosk + CMS
      ↓
    Full Kiosk
      ↓
    Full Store Runtime
      ↓
    Franchise OS Assembly

Each step adds capability.

Each step must preserve authority boundaries.

Each step must reuse the previous layer when possible.

---

## 4. Catch Menu Role

Catch Menu is the lightweight customer-facing menu access surface.

It may support:

- QR/NFC entry
- menu viewing
- locale-aware menu display
- customer-safe status
- item availability display
- allergen-safe notice display if approved
- CMS banner or notice if approved
- simple customer guidance
- order handoff entry if enabled
- staff assistance route if needed

Catch Menu must not become:

- payment truth
- POS truth
- KDS truth
- compensation authority
- provider capability authority
- unreviewed CMS publication surface
- AI decision surface

Catch Menu is an entry surface.

---

## 5. Mini Kiosk Role

Mini Kiosk is a device-based extension of Catch Menu.

Mini Kiosk may reuse:

- Catch Menu menu projection
- Catch Menu i18n message keys
- Catch Menu safe status mapping
- customer session object
- cart or order intent object
- staff assistance route
- CMS safe notice if enabled
- Android Device Profile
- Runtime Configuration
- Safe Projection API

Mini Kiosk may add:

- fixed device identity
- kiosk surface lock
- larger screen layout
- guided customer flow
- order intent capture
- staff-assisted payment route
- degraded operation notice
- local device status
- device revoke handling

Mini Kiosk is not a separate business logic stack.

---

## 6. Full Kiosk Role

Full Kiosk extends Mini Kiosk with additional capabilities.

Possible additions include:

- CMS screen composition
- payment mode
- payment verification if allowed
- POS handoff
- KDS visibility if allowed
- order status screen
- receipt or printer bridge if applicable
- staff call
- accessibility mode
- multilingual customer flow
- campaign content
- policy-based menu exposure
- provider-specific behavior
- offline/degraded safe mode
- device health monitoring

Full Kiosk must still use:

- Use Case API
- Safe Projection API
- Domain Capability Control Plane
- Device Profile
- Runtime Configuration
- Provider Evidence Registry
- i18n Message Key Registry
- Audit Event boundary

Full Kiosk is an upgraded surface.

It is not a new source of truth.

---

## 7. Admin Surface Reuse Principle

The Admin Pages created for Catch Menu, Mini Kiosk, Kiosk, CMS, provider configuration, device configuration, support review, and runtime feature control should be designed for later Franchise OS reuse.

Admin Surface should be reusable across:

- store owner admin
- HQ admin
- support/admin
- franchise operator admin
- brand admin
- provider operations admin
- device operations admin
- CMS admin
- recovery/admin review
- feature control admin
- tenant configuration admin

The same admin function may appear with different authority depending on role and context.

Admin UI reuse must not imply authority reuse.

---

## 8. Admin Surface Layering Rule

Admin Pages must be designed in layers.

Recommended layers:

| Layer | Role |
|---|---|
| `Admin Surface Component` | UI component or screen |
| `Admin Safe Projection` | Data allowed for that role/surface |
| `Admin Use Case API` | Review/configuration workflow |
| `Policy Context` | Tenant/store/franchise/role policy |
| `Authority Boundary` | Who can view/request/approve/execute |
| `Audit Event` | Traceable action record |
| `Runtime Configuration` | Feature state or device state if applicable |

An admin page is not authority by itself.

Authority is server-side.

---

## 9. Franchise OS Reuse Rule

Franchise OS should not rebuild separate admin pages from scratch if the earlier surfaces already define reusable components.

Franchise OS may reuse:

- device management admin
- provider evidence admin
- feature capability admin
- tenant/store configuration admin
- CMS approval admin
- menu projection admin
- i18n review admin
- support review admin
- recovery case admin
- compensation request admin
- Kiosk configuration admin
- Mini Kiosk configuration admin
- Catch Menu configuration admin
- POS/KDS provider profile admin
- audit/evidence review admin
- incident/degraded mode admin

Franchise OS adds hierarchy, policy inheritance, cross-store visibility, and governance.

It should not duplicate logic.

---

## 10. Admin Reuse Authority Rule

The same admin page may behave differently by context.

Example:

| Context | Same Page | Authority |
|---|---|---|
| Store Owner | Kiosk feature page | Request or toggle low-risk store config |
| HQ Admin | Kiosk feature page | Approve tenant/store policy |
| Support Admin | Kiosk feature page | View status and route issue |
| Franchise Operator | Kiosk feature page | Apply allowed policy template |
| Finance Admin | Compensation page | Review financial action |
| Legal Admin | Message page | Review legal-sensitive content |
| Device Ops | Device page | Suspend/revoke device |

Same UI component.

Different authority boundary.

Authority must never be inferred from page access alone.

---

## 11. Catch Menu To Mini Kiosk Upgrade Rule

Catch Menu should be designed so that Mini Kiosk can reuse its core projection.

Reusable parts include:

- menu projection
- item availability projection
- price display projection
- allergen notice projection
- customer-safe status projection
- i18n key references
- CMS notice references
- customer session rules
- staff assistance route
- order intent boundary
- safe fallback messages

Mini Kiosk adds device identity and controlled surface behavior.

Therefore, Catch Menu must not be implemented as a one-off web page.

It must be implemented as a reusable surface projection.

---

## 12. Mini Kiosk To Full Kiosk Upgrade Rule

Mini Kiosk should be designed so that Full Kiosk can add higher-risk capabilities without rewriting the base.

Full Kiosk may add:

- payment flow
- POS handoff
- KDS visibility
- CMS screen sequencing
- device health monitoring
- printer/peripheral support
- staff tablet handoff
- provider-specific mode
- offline/degraded operation mode
- security lock mode

These additions must be controlled through:

- Device Profile
- Runtime Configuration
- Domain Capability Control Plane
- Use Case API
- Safe Projection
- Policy Gate
- Authority Boundary
- Audit Event

Mini Kiosk should be a safe base, not a dead-end product.

---

## 13. Kiosk To Franchise OS Upgrade Rule

Kiosk management features should later plug into Franchise OS.

Franchise OS may manage:

- which stores use Kiosk
- which stores use Mini Kiosk only
- which stores use Catch Menu only
- which stores allow self-payment
- which stores require staff-assisted payment
- which providers are assigned
- which CMS templates apply
- which menu projection policies apply
- which locale sets apply
- which device roles are allowed
- which emergency disable policies apply
- which fallback modes are approved
- which support routes are used

Franchise OS is the assembly controller.

Kiosk remains a surface.

---

## 14. CMS Upgrade Path Rule

CMS can begin as simple notice/banner management for Catch Menu or Mini Kiosk.

Later, CMS may expand to:

- Kiosk home screen content
- menu promotion panels
- campaign banners
- outage notices
- degraded operation notices
- allergen notices
- franchise policy notices
- seasonal menu campaigns
- store-specific notices
- HQ-controlled brand messages
- emergency announcements

CMS must remain controlled content.

CMS must use i18n keys where human-visible text is involved.

CMS must require review for operational, legal, allergen, payment, compensation, provider, or security-sensitive content.

---

## 15. Feature Assembly Rule

Feature assembly must follow:

    Product Surface
      ↓
    Device Profile
      ↓
    Runtime Configuration
      ↓
    Domain Capability Control Plane
      ↓
    Use Case API
      ↓
    Domain Object Core
      ↓
    Safe Projection
      ↓
    Rendered Surface

This applies to:

- Catch Menu
- Mini Kiosk
- Full Kiosk
- Staff Tablet
- Owner Admin
- HQ Admin
- Support Admin
- Franchise OS

No product surface should bypass the assembly chain.

---

## 16. Upgrade Does Not Mean Authority Expansion

Moving from Catch Menu to Mini Kiosk or Kiosk must not automatically grant higher authority.

Examples:

| Upgrade | Must Not Automatically Grant |
|---|---|
| Catch Menu to Mini Kiosk | Payment authority |
| Mini Kiosk to Kiosk | Refund authority |
| Kiosk to POS integration | Payment confirmation truth |
| Kiosk to KDS visibility | Settlement truth |
| CMS addition | Customer message legal approval |
| Admin page addition | Mutation authority |
| Franchise OS addition | Cross-tenant access |
| AI support addition | Automated decision authority |
| pgvector context addition | Proof authority |

Every authority increase requires explicit policy and authorization.

---

## 17. Product Surface Catalog

Recommended product surface catalog:

| Surface | Role |
|---|---|
| `CATCH_MENU_SURFACE` | Lightweight customer menu access |
| `CATCH_ORDER_SURFACE` | Customer order handoff surface |
| `MINI_KIOSK_SURFACE` | Device-based menu/order intent surface |
| `FULL_KIOSK_SURFACE` | Device-based order/payment/CMS surface |
| `STAFF_TABLET_SURFACE` | Store staff operation surface |
| `OWNER_ADMIN_SURFACE` | Store owner review/configuration surface |
| `HQ_ADMIN_SURFACE` | HQ policy and governance surface |
| `SUPPORT_ADMIN_SURFACE` | Customer support and evidence review surface |
| `FRANCHISE_OS_SURFACE` | Multi-store assembly and governance surface |
| `CMS_ADMIN_SURFACE` | Controlled content management surface |
| `DEVICE_ADMIN_SURFACE` | Device management surface |

Each surface must map to allowed projections.

Each surface must not expose raw core objects directly.

---

## 18. Reusable Admin Domains

Recommended reusable admin domains:

| Admin Domain | Reusable In Franchise OS |
|---|---|
| Device Admin | Yes |
| Provider Capability Admin | Yes |
| Feature Control Admin | Yes |
| Tenant Plan Admin | Yes |
| Store Runtime Config Admin | Yes |
| CMS Admin | Yes |
| i18n Review Admin | Yes |
| Menu Projection Admin | Yes |
| Kiosk Config Admin | Yes |
| Catch Menu Config Admin | Yes |
| Support Review Admin | Yes |
| Recovery Case Admin | Yes |
| Compensation Review Admin | Yes |
| Audit/Evidence Admin | Yes |
| Incident/Degraded Mode Admin | Yes |
| Franchise Policy Admin | Native Franchise OS domain |

Earlier admin work should be designed for reuse.

---

## 19. Device Upgrade Path

A physical device may evolve by configuration.

Examples:

| Current Role | Future Role |
|---|---|
| Menu display tablet | Mini Kiosk |
| Mini Kiosk | Full Kiosk |
| Staff tablet | Staff payment assist |
| Kiosk | Kiosk plus CMS display |
| Kiosk | Kiosk plus POS handoff |
| Kiosk | Kiosk plus staff assistance |
| Kiosk | Kiosk plus degraded mode |
| Android CMS display | Full Kiosk candidate |
| Owner tablet | Franchise OS limited admin |

Device role changes must be controlled.

Device role change requires Device Profile update, Runtime Configuration update, audit, and authority review.

---

## 20. Store Upgrade Path

A store may evolve by capability assembly.

Example store upgrade stages:

| Stage | Store Capability |
|---|---|
| Stage 1 | Catch Menu only |
| Stage 2 | Catch Menu plus order intent |
| Stage 3 | Mini Kiosk |
| Stage 4 | Mini Kiosk plus staff-assisted payment |
| Stage 5 | Full Kiosk plus CMS |
| Stage 6 | Full Kiosk plus POS handoff |
| Stage 7 | POS/KDS/payment integrated store runtime |
| Stage 8 | Franchise OS governed store |

Store upgrade must not require rewriting core logic.

Store upgrade should be configuration and capability driven.

---

## 21. Franchise OS Assembly Rule

Franchise OS must assemble capabilities by:

- tenant
- brand
- store
- operating group
- legal entity if needed
- provider
- device
- surface
- plan
- policy
- runtime mode
- support route
- locale
- campaign
- incident state

Franchise OS must not assume all stores are identical.

Franchise OS must not assume all providers are equal.

Franchise OS must not assume all devices expose all capabilities.

Franchise OS must be a controlled assembly layer.

---

## 22. SaaS Product Line Rule

The SaaS product line may be organized as:

| Product Line | Meaning |
|---|---|
| Catch Menu | Lightweight customer entry and menu surface |
| Catch & Order | Menu plus order handoff service |
| Mini Kiosk | Device-based Catch Menu/order intent |
| Full Kiosk | Device-based order/payment/CMS/store runtime surface |
| Store Runtime | POS/KDS/payment/recovery/support integration |
| Franchise OS | Multi-store policy, configuration, and governance |
| Provider Control | Provider evidence and capability management |
| Support Control | Support/recovery/compensation review |
| CMS Control | Content governance and publication |
| Device Control | Device provisioning and runtime config |

These should share the same foundation.

---

## 23. Admin Page Productization Rule

Admin Pages should not be treated as internal-only throwaway screens.

Admin Pages should be productized as reusable governance surfaces.

Each Admin Page should declare:

- target admin domain
- usable roles
- tenant/store scope
- projection model
- allowed commands
- prohibited commands
- authority requirement
- audit requirement
- i18n requirement
- policy dependency
- Franchise OS reuse eligibility
- support/admin reuse eligibility

This allows earlier admin work to become Franchise OS assets.

---

## 24. Naming Rule

Recommended naming distinction:

| Name | Meaning |
|---|---|
| `Catch Menu` | Customer-facing menu access surface |
| `Catch & Order` | SaaS-facing menu/order/POS-KDS handoff service |
| `Mini Kiosk` | Device-based lightweight customer order surface |
| `Full Kiosk` | CMS/payment/POS/KDS-capable kiosk surface |
| `Admin Surface` | Review/configuration surface |
| `Franchise OS` | Multi-store SaaS governance and assembly layer |

Do not confuse surface name with authority.

Product naming must not imply source of truth.

---

## 25. AI And pgvector Reuse Rule

AI and pgvector may later support all product surfaces, but only as advisory layers.

They may support:

- support summary
- incident summary
- missing evidence suggestion
- CMS draft suggestion
- i18n draft suggestion
- similar policy lookup
- similar case lookup
- training content draft
- provider evidence summary
- admin review assistance

They must not:

- approve compensation
- execute refund
- publish CMS content
- send customer message automatically
- confirm provider fault
- decide payment truth
- decide POS/KDS truth
- release containment
- override Franchise OS policy

AI and pgvector are shared advisory assets.

They are not authority.

---

## 26. Evidence And Audit Reuse Rule

Evidence and audit must be shared across product evolution.

Catch Menu, Mini Kiosk, Kiosk, Admin Surface, and Franchise OS should all reference the same audit/evidence principle.

Examples:

- device provisioning event
- runtime config update
- CMS approval event
- order submit event
- POS handoff event
- payment check event
- staff assist event
- support review event
- recovery case event
- compensation request event
- provider evidence update
- emergency disable event
- device revoke event
- franchise policy override event

Audit continuity allows product evolution without losing traceability.

---

## 27. i18n Reuse Rule

All customer-visible, staff-visible, admin-visible, support-visible, and franchise-visible messages must use reusable i18n keys where appropriate.

Catch Menu i18n work should be reusable by:

- Mini Kiosk
- Full Kiosk
- Catch & Order
- Staff Tablet
- Support/Admin
- CMS
- Franchise OS

i18n must not be duplicated per product surface.

Locale support is a platform capability.

---

## 28. Provider Reuse Rule

Provider profiles must be reusable across surfaces.

Examples:

- OKPOS provider profile may affect Catch & Order, Mini Kiosk, Full Kiosk, POS bridge, support review, and Franchise OS.
- Smartro provider profile may affect Kiosk payment, staff tablet payment assist, payment review, support/admin, and Franchise OS.
- KDS provider profile may affect Kiosk status, staff tablet, kitchen tablet, support review, and Franchise OS.

Provider evidence must remain centralized.

Provider-specific behavior must not be hardcoded in each surface.

---

## 29. Upgrade Validation Checklist

Before declaring an upgrade path valid, verify:

1. Catch Menu projection can be reused by Mini Kiosk.
2. Mini Kiosk can add device identity without business logic duplication.
3. Full Kiosk can add CMS/payment/POS/KDS through capability control.
4. Admin Pages are reusable by Franchise OS.
5. Device Profile supports role evolution.
6. Runtime Configuration supports feature evolution.
7. Use Case API remains server-side.
8. Safe Projection remains surface-specific.
9. Provider capability is evidence-based.
10. Tenant/store policy is injected.
11. i18n keys are reusable.
12. Audit events are continuous.
13. CMS publication is controlled.
14. Payment authority is not granted by upgrade.
15. Compensation authority is not granted by upgrade.
16. AI remains advisory.
17. pgvector remains non-proof.
18. Runtime remains deferred.

---

## 30. Anti-Patterns

Avoid:

- Catch Menu as one-off web page
- Mini Kiosk as separate logic stack
- Kiosk as independent payment/order engine
- Admin Pages as throwaway internal screens
- Franchise OS rebuilding the same admin logic
- CMS text duplicated per device
- provider logic hardcoded per surface
- feature upgrade granting authority automatically
- device role change without audit
- store upgrade without policy gate
- frontend assembling raw business objects
- support/admin visibility becoming mutation authority
- AI added as execution authority
- pgvector added as proof authority

These anti-patterns destroy SaaS reuse.

---

## 31. Relationship To Previous Documents

This document follows:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`

It references:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `09990 AI pgvector Governance Catalog Static Package Handoff And Non Authority Boundary Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`
- `10045 Franchise OS Capability Inheritance And Tenant Store Assembly Policy`
- `10046 Surface Evolution Roadmap And Product Line Continuity Policy`
- reusable admin surface contract
- Franchise OS admin reuse matrix
- product line capability registry
- device role upgrade schema
- store capability upgrade workflow

This document is architecture planning only.

It does not authorize coding.

---

## 32. Final Rule

Catch Menu, Mini Kiosk, Full Kiosk, Admin Surface, and Franchise OS must be treated as an evolutionary product line built on the same shared SaaS core.

Catch Menu must be reusable as Mini Kiosk foundation.

Mini Kiosk must be reusable as Full Kiosk foundation.

Full Kiosk must be manageable through Admin Surfaces.

Admin Surfaces must be reusable inside Franchise OS.

Franchise OS must assemble tenant, brand, store, provider, device, surface, feature, policy, runtime, support, CMS, payment, POS, KDS, recovery, compensation, AI, pgvector, and audit capabilities without duplicating product logic.

The product surface may evolve.

The core must remain shared.

Authority must remain controlled.

Runtime implementation remains deferred until separately authorized.
