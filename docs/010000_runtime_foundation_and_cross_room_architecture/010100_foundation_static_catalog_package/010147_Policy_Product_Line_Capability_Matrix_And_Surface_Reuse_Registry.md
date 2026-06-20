# 010147_Policy_Product_Line_Capability_Matrix_And_Surface_Reuse_Registry.md

## Purpose

This document defines the Product Line Capability Matrix and Surface Reuse Registry Policy.

The previous artifact `10046` defined the Surface Evolution Roadmap and Product Line Continuity Policy.

This document narrows how each product surface must declare its reusable capabilities, dependency boundaries, upgrade path, downgrade path, admin reuse eligibility, provider dependency, i18n dependency, audit requirement, and Franchise OS reuse eligibility.

The purpose is to prevent product surfaces from becoming disconnected silos.

Each surface must be registered as part of the shared SaaS product line.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Every product surface must have a capability matrix.

Every reusable surface must have a reuse registry record.

The correct rule is:

Surface is registered.
Capabilities are declared.
Dependencies are mapped.
Authority is bounded.
Safe Projections are required.
Admin reuse is marked.
Franchise OS reuse is planned.
Upgrade and rollback are defined.

No product surface should enter implementation without a capability matrix.

---

## 3. Scope

This policy applies to product surfaces including:

- Catch Menu
- Catch & Order
- Mini Kiosk
- Full Kiosk
- Store Runtime
- Staff Tablet
- Owner Admin
- HQ Admin
- Support/Admin
- CMS Admin
- Device Admin
- Franchise OS
- Provider Control
- Device Control
- CMS Control
- Recovery/Compensation Control
- AI Advisory Surface
- pgvector Context Surface
- future Workforce Surface
- future External Channel Surface

This policy does not implement the registry.

It defines the registry planning structure.

---

## 4. Product Surface Registry Definition

A Product Surface Registry is a controlled record set describing each surface.

Each registry record should define:

- surface id
- surface name
- surface type
- product line stage
- primary audience
- allowed capabilities
- prohibited capabilities
- required Safe Projections
- required Use Case APIs
- required Domain Objects
- provider dependencies
- i18n dependencies
- CMS dependencies
- audit dependencies
- policy dependencies
- device dependencies
- admin reuse eligibility
- Franchise OS reuse eligibility
- upgrade path
- downgrade path
- runtime status

A surface without a registry record should not proceed to runtime.

---

## 5. Surface ID Pattern

Recommended surface id pattern:

`SURFACE-<PRODUCT>-<NUMBER>`

Examples:

| Surface ID | Meaning |
|---|---|
| `SURFACE-CATCH-MENU-001` | Catch Menu customer surface |
| `SURFACE-CATCH-ORDER-001` | Catch & Order customer order surface |
| `SURFACE-MINI-KIOSK-001` | Mini Kiosk customer device surface |
| `SURFACE-FULL-KIOSK-001` | Full Kiosk device surface |
| `SURFACE-STAFF-TABLET-001` | Staff tablet surface |
| `SURFACE-SUPPORT-ADMIN-001` | Support/Admin surface |
| `SURFACE-CMS-ADMIN-001` | CMS admin surface |
| `SURFACE-DEVICE-ADMIN-001` | Device admin surface |
| `SURFACE-FRANCHISE-OS-001` | Franchise OS governance surface |

Surface ids must be stable once referenced.

---

## 6. Surface Capability Matrix Definition

A Surface Capability Matrix defines what a surface can do.

Required capability fields may include:

| Field | Meaning |
|---|---|
| `capability_key` | Feature/capability key |
| `domain` | Menu, order, payment, CMS, etc. |
| `visibility_allowed` | Whether surface may display it |
| `request_allowed` | Whether surface may request action |
| `execution_allowed` | Whether surface may execute directly |
| `authority_required` | Required authority |
| `provider_required` | Provider dependency |
| `policy_required` | Policy dependency |
| `safe_projection_required` | Projection dependency |
| `audit_required` | Audit dependency |
| `runtime_status` | Runtime use status |

Default execution status:

`EXECUTION_NOT_AUTHORIZED`

---

## 7. Surface Type Catalog

Recommended surface type catalog:

| Surface Type | Meaning |
|---|---|
| `CUSTOMER_WEB_SURFACE` | Customer mobile/web surface |
| `CUSTOMER_DEVICE_SURFACE` | Customer-facing physical device |
| `STAFF_OPERATION_SURFACE` | Staff operation surface |
| `OWNER_ADMIN_SURFACE` | Store owner/admin surface |
| `HQ_ADMIN_SURFACE` | HQ governance surface |
| `SUPPORT_ADMIN_SURFACE` | Support/recovery review surface |
| `CMS_ADMIN_SURFACE` | Controlled content admin surface |
| `DEVICE_ADMIN_SURFACE` | Device management surface |
| `FRANCHISE_GOVERNANCE_SURFACE` | Franchise OS surface |
| `PROVIDER_CONTROL_SURFACE` | Provider evidence/capability surface |
| `AI_ADVISORY_SURFACE` | AI advisory review surface |
| `VECTOR_CONTEXT_SURFACE` | pgvector reference surface |

Surface type must not imply authority by itself.

---

## 8. Product Line Stage Catalog

Recommended product line stages:

| Stage | Meaning |
|---|---|
| `STAGE_CATCH_MENU` | Lightweight menu entry |
| `STAGE_CATCH_ORDER` | Order handoff extension |
| `STAGE_MINI_KIOSK` | Device-based lightweight surface |
| `STAGE_FULL_KIOSK` | CMS/payment/POS/KDS capable surface |
| `STAGE_STORE_RUNTIME` | Store runtime integration |
| `STAGE_ADMIN_SURFACE` | Admin/review/configuration |
| `STAGE_FRANCHISE_OS` | Multi-store governance |
| `STAGE_SAAS_PLATFORM` | Multi-tenant platform assembly |

A surface may reference multiple stages if reused.

---

## 9. Capability Domain Catalog

Capability domains may include:

| Domain | Meaning |
|---|---|
| `MENU` | Menu projection and display |
| `ORDER` | Order intent and handoff |
| `PAYMENT` | Payment checking and verification |
| `POS` | POS handoff and evidence |
| `KDS` | Kitchen visibility |
| `CMS` | Controlled content |
| `I18N` | Locale/message key dependency |
| `DEVICE` | Device provisioning and profile |
| `PROVIDER` | Provider capability |
| `SUPPORT` | Support review |
| `RECOVERY` | Recovery case |
| `COMPENSATION` | Value review/execution boundary |
| `AUDIT` | Evidence and traceability |
| `POLICY` | Tenant/store/franchise policy |
| `AI` | Advisory AI |
| `VECTOR` | pgvector context |
| `FRANCHISE` | Franchise OS governance |
| `WORKFORCE` | Workforce interface |
| `EXTERNAL_CHANNEL` | External provider/channel interface |

Each capability must belong to a domain.

---

## 10. Capability Permission Levels

Recommended permission levels:

| Permission | Meaning |
|---|---|
| `NOT_AVAILABLE` | Surface does not support capability |
| `VISIBLE_ONLY` | Surface may display safe projection |
| `REQUEST_ONLY` | Surface may request action |
| `REVIEW_ONLY` | Surface may review but not execute |
| `CONFIG_REQUEST_ONLY` | Surface may request configuration |
| `CONFIG_ALLOWED_LOW_RISK` | Low-risk configuration allowed if authorized |
| `EXECUTION_ALLOWED_WITH_AUTHORITY` | Execution only with server authority |
| `PROHIBITED` | Explicitly prohibited |

Default:

`NOT_AVAILABLE`

High-risk capabilities should default to `PROHIBITED` or `REVIEW_ONLY`.

---

## 11. Catch Menu Capability Matrix

Recommended Catch Menu capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `MENU` | Menu view | `VISIBLE_ONLY` |
| `MENU` | Price display | `VISIBLE_ONLY` if approved |
| `MENU` | Availability display | `VISIBLE_ONLY` if approved |
| `MENU` | Allergen notice | `VISIBLE_ONLY` if approved |
| `I18N` | Customer message keys | `VISIBLE_ONLY` |
| `CMS` | Approved notice/banner | `VISIBLE_ONLY` |
| `ORDER` | Order intent | `REQUEST_ONLY` if enabled |
| `PAYMENT` | Payment truth | `PROHIBITED` |
| `POS` | POS truth | `PROHIBITED` |
| `KDS` | KDS truth | `PROHIBITED` |
| `COMPENSATION` | Compensation | `PROHIBITED` |
| `AI` | AI decision | `PROHIBITED` |

Catch Menu is a lightweight customer entry surface.

---

## 12. Catch & Order Capability Matrix

Recommended Catch & Order capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `MENU` | Menu projection | `VISIBLE_ONLY` |
| `ORDER` | Cart/order intent | `REQUEST_ONLY` |
| `ORDER` | Order submit | `REQUEST_ONLY` if enabled |
| `POS` | POS handoff request | `REQUEST_ONLY` through Use Case API |
| `PAYMENT` | Payment checking display | `VISIBLE_ONLY` if allowed |
| `KDS` | Customer-safe preparation status | `VISIBLE_ONLY` if allowed |
| `SUPPORT` | Staff/support route | `REQUEST_ONLY` |
| `RECOVERY` | Recovery case route | `REQUEST_ONLY` if allowed |
| `COMPENSATION` | Value execution | `PROHIBITED` |
| `PROVIDER` | Provider capability approval | `PROHIBITED` |

Catch & Order must not become payment or settlement truth.

---

## 13. Mini Kiosk Capability Matrix

Recommended Mini Kiosk capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `DEVICE` | Device identity | `VISIBLE_ONLY` internally |
| `MENU` | Menu projection | `VISIBLE_ONLY` |
| `ORDER` | Order intent | `REQUEST_ONLY` |
| `ORDER` | Order submit | `REQUEST_ONLY` if enabled |
| `CMS` | Approved notice slot | `VISIBLE_ONLY` |
| `I18N` | Locale messages | `VISIBLE_ONLY` |
| `SUPPORT` | Staff assist | `REQUEST_ONLY` |
| `DEVICE` | Runtime config status | `VISIBLE_ONLY` safe |
| `PAYMENT` | Staff-assisted route | `REQUEST_ONLY` if enabled |
| `PAYMENT` | Payment confirmation | `PROHIBITED` |
| `POS` | Direct POS call | `PROHIBITED` |
| `KDS` | Raw KDS status | `PROHIBITED` |

Mini Kiosk is a device surface, not an authority layer.

---

## 14. Full Kiosk Capability Matrix

Recommended Full Kiosk capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `MENU` | Menu projection | `VISIBLE_ONLY` |
| `ORDER` | Order submit | `REQUEST_ONLY` |
| `PAYMENT` | Payment request | `REQUEST_ONLY` if allowed |
| `PAYMENT` | Payment verification display | `VISIBLE_ONLY` safe |
| `POS` | POS handoff request | `REQUEST_ONLY` through Use Case API |
| `KDS` | Customer-safe KDS status | `VISIBLE_ONLY` if allowed |
| `CMS` | Approved CMS content | `VISIBLE_ONLY` |
| `DEVICE` | Kiosk mode/device health | `VISIBLE_ONLY` safe |
| `SUPPORT` | Staff assist | `REQUEST_ONLY` |
| `RECOVERY` | Recovery route | `REQUEST_ONLY` if allowed |
| `COMPENSATION` | Compensation execution | `PROHIBITED` |
| `AI` | AI decision | `PROHIBITED` |
| `VECTOR` | Vector proof | `PROHIBITED` |

Full Kiosk is a richer surface.

It is not source of truth.

---

## 15. Staff Tablet Capability Matrix

Recommended Staff Tablet capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `ORDER` | Staff-safe order view | `VISIBLE_ONLY` |
| `KDS` | Kitchen visibility | `VISIBLE_ONLY` or `REQUEST_ONLY` if allowed |
| `PAYMENT` | Payment assist | `REQUEST_ONLY` if allowed |
| `SUPPORT` | Staff assistance handling | `REQUEST_ONLY` |
| `RECOVERY` | Recovery route | `REQUEST_ONLY` |
| `CMS` | Store notice view | `VISIBLE_ONLY` |
| `DEVICE` | Device status | `VISIBLE_ONLY` safe |
| `COMPENSATION` | Compensation request | `REQUEST_ONLY` if allowed |
| `COMPENSATION` | Compensation execution | `PROHIBITED` by default |
| `PAYMENT` | Refund execution | `PROHIBITED` by default |

Staff visibility is not authority.

---

## 16. Owner Admin Capability Matrix

Recommended Owner Admin capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `STORE_CONFIG` | Low-risk store configuration | `CONFIG_ALLOWED_LOW_RISK` if authorized |
| `DEVICE` | Device status | `VISIBLE_ONLY` or `CONFIG_REQUEST_ONLY` |
| `MENU` | Menu projection review | `REVIEW_ONLY` |
| `CMS` | CMS draft/request | `CONFIG_REQUEST_ONLY` or `REVIEW_ONLY` |
| `ORDER` | Store order summary | `VISIBLE_ONLY` |
| `SUPPORT` | Store support summary | `VISIBLE_ONLY` |
| `RECOVERY` | Recovery visibility | `VISIBLE_ONLY` or `REVIEW_ONLY` |
| `COMPENSATION` | Compensation request | `REQUEST_ONLY` if allowed |
| `PAYMENT` | Refund execution | `PROHIBITED` unless separate authority |
| `FRANCHISE` | Policy override | `PROHIBITED` by default |

Owner Admin is configuration/review, not unrestricted authority.

---

## 17. Support/Admin Capability Matrix

Recommended Support/Admin capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `ORDER` | Support-safe order summary | `VISIBLE_ONLY` |
| `PAYMENT` | Masked payment review | `VISIBLE_ONLY` |
| `PROVIDER` | Provider evidence reference | `VISIBLE_ONLY` |
| `RECOVERY` | Recovery case update | `REVIEW_ONLY` or `REQUEST_ONLY` |
| `COMPENSATION` | Compensation request creation | `REQUEST_ONLY` |
| `COMPENSATION` | Compensation execution | `PROHIBITED` unless finance authority |
| `CMS` | Customer reply draft | `REVIEW_ONLY` |
| `AI` | AI draft/summary | `REVIEW_ONLY` |
| `VECTOR` | Similar case/policy lookup | `VISIBLE_ONLY` with warning |
| `AUDIT` | Evidence packet reference | `VISIBLE_ONLY` |

Support/Admin sees review context.

Support/Admin must not silently execute value action.

---

## 18. Franchise OS Capability Matrix

Recommended Franchise OS capabilities:

| Domain | Capability | Permission |
|---|---|---|
| `TENANT` | Tenant plan governance | `CONFIG_ALLOWED_LOW_RISK` or higher with authority |
| `BRAND` | Brand policy governance | `CONFIG_ALLOWED_LOW_RISK` or review |
| `STORE_CONFIG` | Store template application | `CONFIG_ALLOWED_LOW_RISK` with audit |
| `DEVICE` | Device fleet management | `CONFIG_ALLOWED_LOW_RISK` with authority |
| `PROVIDER` | Provider assignment | `CONFIG_REQUEST_ONLY` or review |
| `CMS` | CMS inheritance governance | `REVIEW_ONLY` or approved config |
| `I18N` | Locale policy governance | `REVIEW_ONLY` or approved config |
| `PAYMENT` | Payment mode policy | `REVIEW_ONLY` or finance-controlled config |
| `COMPENSATION` | Compensation policy | `REVIEW_ONLY` unless authority |
| `AI` | AI advisory configuration | `CONFIG_REQUEST_ONLY` with policy |
| `VECTOR` | Vector context configuration | `CONFIG_REQUEST_ONLY` with policy |

Franchise OS assembles and governs.

It must not bypass foundation controls.

---

## 19. Reuse Registry Record Template

A reusable surface registry record should follow this template:

    Surface ID:
    <surface_id>

    Surface Name:
    <surface_name>

    Surface Type:
    <surface_type>

    Product Line Stage:
    <stage>

    Primary Audience:
    <customer/staff/owner/HQ/support/franchise>

    Reusable By:
    <surfaces or OS layers>

    Required Use Case APIs:
    <api list>

    Required Safe Projections:
    <projection list>

    Required Domain Objects:
    <object list>

    Provider Dependencies:
    <provider capability references>

    i18n Dependencies:
    <message key families>

    CMS Dependencies:
    <content objects if any>

    Audit Dependencies:
    <audit events>

    Allowed Capabilities:
    <capability list>

    Prohibited Capabilities:
    <capability list>

    Upgrade Path:
    <next surfaces>

    Downgrade/Fallback Path:
    <fallback surface or mode>

    Runtime Status:
    RUNTIME_ENTRY_NOT_AUTHORIZED

This template is planning-only.

---

## 20. Admin Surface Reuse Registry

Admin Surface reuse must be explicitly recorded.

Recommended fields:

- admin surface id
- admin domain
- reusable in Franchise OS
- reusable in Owner Admin
- reusable in HQ Admin
- reusable in Support/Admin
- required role boundary
- allowed commands
- prohibited commands
- audit event mapping
- policy dependency
- projection dependency
- runtime status

Admin page reuse must not imply authority reuse.

---

## 21. Upgrade Path Registry

Each surface must declare upgrade path.

Examples:

| Current Surface | Upgrade Surface |
|---|---|
| Catch Menu | Catch & Order |
| Catch Menu | Mini Kiosk |
| Catch & Order | Mini Kiosk |
| Mini Kiosk | Full Kiosk |
| Full Kiosk | Store Runtime |
| Store Runtime | Franchise OS governed store |
| Owner Admin | Franchise OS limited admin |
| CMS Admin | Franchise OS CMS governance |
| Device Admin | Franchise OS device fleet management |
| Support/Admin | Franchise OS support governance |

Upgrade path must include capability gates.

---

## 22. Downgrade And Fallback Registry

Each surface must declare fallback path.

Examples:

| Surface | Fallback |
|---|---|
| Full Kiosk | Mini Kiosk |
| Mini Kiosk | Catch Menu display |
| Catch & Order | Catch Menu only |
| Kiosk payment | Staff-assisted payment |
| POS handoff | Staff confirmation |
| KDS visibility | Staff-managed status |
| CMS campaign | Approved fallback notice |
| AI support | Manual support review |
| pgvector lookup | Manual policy lookup |
| Provider integration | Provider unavailable safe state |

Fallback must be safe and auditable.

---

## 23. Provider Dependency Registry

Each surface must declare provider dependencies.

Examples:

| Surface | Provider Dependency |
|---|---|
| Catch Menu | Optional CMS/message provider |
| Catch & Order | POS provider if handoff enabled |
| Mini Kiosk | Optional payment provider if payment assist |
| Full Kiosk | POS/payment/KDS/CMS provider profile |
| Staff Tablet | POS/KDS/payment visibility provider |
| Support/Admin | Provider evidence registry |
| Franchise OS | Provider assignment and capability matrix |

Provider dependency must reference evidence status.

Provider name alone is not enough.

---

## 24. i18n Dependency Registry

Each surface must declare i18n dependencies.

Examples:

| Surface | i18n Dependency |
|---|---|
| Catch Menu | Customer menu/status keys |
| Catch & Order | Order status/payment checking keys |
| Mini Kiosk | Kiosk guidance and fallback keys |
| Full Kiosk | CMS/payment/POS/KDS/customer flow keys |
| Staff Tablet | Staff operation keys |
| Support/Admin | Support review and customer reply keys |
| Franchise OS | Admin/governance/policy keys |
| CMS Admin | Content review and publication keys |

No surface should hardcode operational customer-visible text.

---

## 25. Audit Dependency Registry

Each surface must declare audit dependencies.

Examples:

| Surface | Audit Dependency |
|---|---|
| Catch Menu | Entry/session/menu projection event if needed |
| Catch & Order | Order intent/order submit event |
| Mini Kiosk | Device/session/order intent event |
| Full Kiosk | Payment/POS/KDS/CMS/device event |
| Staff Tablet | Staff assist/review event |
| Owner Admin | Store config request/change event |
| Support/Admin | Support review/recovery/compensation event |
| Franchise OS | Policy/template/device/provider/config event |
| CMS Admin | Content draft/approve/publish/rollback event |

Audit dependency must follow existing evidence principles.

---

## 26. Runtime Status Rule

Each registry record must declare runtime status.

Allowed statuses:

| Status | Meaning |
|---|---|
| `PLANNING_ONLY` | Planning only |
| `STATIC_REGISTRY_ONLY` | Static registry only |
| `IMPLEMENTATION_CANDIDATE` | Candidate for implementation |
| `CODING_NOT_AUTHORIZED` | Coding not authorized |
| `CODING_ALLOWED_NARROW_SCOPE` | Narrow coding allowed if separately approved |
| `RUNTIME_ENTRY_NOT_AUTHORIZED` | Runtime not authorized |
| `RUNTIME_PILOT_REQUIRED` | Pilot required before runtime |
| `RUNTIME_DISABLED` | Runtime disabled |
| `RUNTIME_REVOKED` | Runtime revoked |

Default:

`PLANNING_ONLY` and `RUNTIME_ENTRY_NOT_AUTHORIZED`

---

## 27. Product Line Capability Matrix Anti-Patterns

Avoid:

- product surface without registry record
- capability without domain
- surface capability implying execution
- admin reuse implying authority reuse
- provider dependency without evidence
- i18n dependency missing for visible text
- audit dependency missing for state transitions
- upgrade path without rollback
- fallback path exposing raw internal failure
- Franchise OS duplicating the same surface logic
- Mini Kiosk and Full Kiosk using separate core logic
- support/admin capability becoming compensation execution
- AI capability becoming decision authority
- pgvector capability becoming proof

These anti-patterns weaken product continuity.

---

## 28. Validation Checklist

Validation must confirm:

1. Product Surface Registry is defined.
2. Surface ID pattern exists.
3. Surface type catalog exists.
4. Product line stage catalog exists.
5. Capability domain catalog exists.
6. Permission levels are defined.
7. Catch Menu capability matrix exists.
8. Catch & Order capability matrix exists.
9. Mini Kiosk capability matrix exists.
10. Full Kiosk capability matrix exists.
11. Staff Tablet capability matrix exists.
12. Owner Admin capability matrix exists.
13. Support/Admin capability matrix exists.
14. Franchise OS capability matrix exists.
15. Reuse registry template exists.
16. Admin Surface reuse registry exists.
17. Upgrade path registry exists.
18. Downgrade/fallback registry exists.
19. Provider dependency registry exists.
20. i18n dependency registry exists.
21. Audit dependency registry exists.
22. Runtime status rule exists.
23. Runtime remains deferred.

---

## 29. Relationship To Previous Documents

This document follows:

- `10046 Surface Evolution Roadmap And Product Line Continuity Policy`

It references:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10041 Windows Installer Option Package And Local Runtime Configuration Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`
- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`
- `10045 Franchise OS Capability Inheritance And Tenant Store Assembly Policy`
- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- surface reuse static registry
- product capability registry
- admin surface reuse matrix
- product upgrade and fallback registry
- SaaS packaging and pricing boundary
- product line implementation candidate selection
- controlled runtime entry package review

This document is architecture planning only.

It does not authorize coding.

---

## 30. Final Rule

Every product surface in the Catch Menu, Catch & Order, Mini Kiosk, Full Kiosk, Store Runtime, Admin Surface, and Franchise OS product line must declare its capabilities, dependencies, authority boundaries, Safe Projections, Use Case APIs, provider evidence, i18n keys, audit requirements, upgrade path, fallback path, admin reuse eligibility, and runtime status.

Surfaces may evolve.

Capabilities may expand.

Admin pages may be reused.

Franchise OS may assemble.

But no surface may become an isolated source of truth.

No capability may execute merely because a surface can display it.

The shared SaaS core remains authoritative.

Runtime implementation remains deferred until separately authorized.
