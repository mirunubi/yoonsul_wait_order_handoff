# 10030_Domain_Object_Core_Use_Case_API_And_Safe_Projection_Architecture_Policy

## 1. Purpose

This document defines the Domain Object Core, Use Case API, and Safe Projection Architecture Policy.

The previous artifact `10020` defined the Modular SaaS Core and Future Kiosk Reuse Principle.

This document refines that principle into a safer implementation architecture.

The system must not expose every internal object as an external API.

The system must not allow Kiosk, CMS, Frontend, Catch Menu, Catch & Order, Support/Admin, or Franchise OS surfaces to assemble raw business objects directly.

Instead, the system must be structured as:

1. Domain Object Core
2. Use Case API
3. Safe Projection API

The purpose is to preserve modular SaaS flexibility without causing API fragmentation, frontend authority expansion, transaction boundary collapse, tenant policy drift, or customer-visible state contamination.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Principle

Domain objects are internal authority-bearing units.

External clients must not call raw object APIs directly.

Kiosk, CMS, Frontend, Catch Menu, Catch & Order, Support/Admin, Owner Admin, HQ Admin, and Franchise OS must access the core through approved Use Case APIs and Safe Projection APIs.

The correct rule is:

Object Core owns business meaning.
Use Case API owns workflow coordination.
Safe Projection API owns customer-safe and surface-safe output.
Frontend owns rendering only.
Kiosk owns device interaction only.
CMS owns controlled content preparation only.
Support/Admin owns review surface only.
Authority remains in the core.

---

## 3. Why Raw Object API Exposure Is Prohibited

Opening direct APIs for every internal object can create serious problems.

Examples of unsafe direct object APIs:

- `MenuItemObject API`
- `PriceObject API`
- `AvailabilityObject API`
- `AllergenObject API`
- `CartObject API`
- `OrderObject API`
- `PaymentIntentObject API`
- `KDSObject API`
- `CMSObject API`
- `MessageKeyObject API`

If frontend surfaces call these directly, the system may suffer from:

- excessive network calls
- inconsistent screen composition
- stale menu and price mismatch
- frontend-side business logic
- duplicated authorization checks
- broken transaction boundaries
- tenant policy leakage
- store policy drift
- provider trust confusion
- customer-visible unsafe states
- difficult rollback
- fragile Kiosk behavior

Therefore, raw object APIs must not be the primary external interface.

---

## 4. Architecture Model

The approved architecture model is:

    Surface
      - Kiosk
      - Catch Menu
      - Catch & Order
      - CMS
      - Staff Tablet
      - Support/Admin
      - Owner Admin
      - HQ Admin
      - Franchise OS

        ↓

    Use Case API
      - menu view
      - cart update
      - order submit
      - payment check
      - staff review
      - support review
      - CMS publication review
      - recovery review
      - compensation review

        ↓

    Domain Object Core
      - Menu
      - MenuItem
      - Price
      - Availability
      - Allergen
      - Cart
      - Order
      - POSHandoff
      - PaymentIntent
      - KDSExecution
      - CMSContent
      - MessageKey
      - RecoveryCase
      - CompensationRequest
      - ProviderCapability
      - PolicyContext
      - AuditEvent
      - AIAdvisory
      - VectorContext

        ↓

    Safe Projection
      - customer-safe view model
      - staff-safe review model
      - support-safe summary
      - owner-safe configuration model
      - HQ-safe policy model
      - kiosk-safe screen model

The frontend receives projections.

It must not assemble raw core truth.

---

## 5. Domain Object Core Definition

The Domain Object Core is the internal layer that owns business meaning and state boundaries.

Representative domain objects include:

| Domain Object | Role |
|---|---|
| `TenantObject` | SaaS tenant boundary |
| `StoreObject` | Store context and operating boundary |
| `DeviceObject` | Kiosk, tablet, mobile, QR/NFC surface identity |
| `CustomerSessionObject` | Customer session and continuity |
| `MenuObject` | Menu projection and menu version reference |
| `MenuItemObject` | Item availability, allergen, and price boundary |
| `CartObject` | Customer draft intent |
| `OrderObject` | Order lifecycle and handoff boundary |
| `POSHandoffObject` | POS acceptance boundary |
| `PaymentIntentObject` | Payment checking and verification boundary |
| `KDSExecutionObject` | Kitchen execution visibility |
| `ProviderObject` | External provider capability and trust boundary |
| `RecoveryCaseObject` | Customer recovery case |
| `CompensationRequestObject` | Value action review and authority |
| `MessageKeyObject` | i18n message identity |
| `CMSContentObject` | Controlled CMS content |
| `FrontendSurfaceObject` | Surface rendering boundary |
| `AuditEventObject` | Immutable evidence event |
| `AIAdvisoryObject` | AI draft and summary boundary |
| `VectorContextObject` | pgvector retrieval context |
| `PolicyContextObject` | HQ, tenant, store, franchise policy layer |

Domain objects are internal.

They may be composed by Use Case APIs.

They must not be exposed as raw public APIs by default.

---

## 6. Use Case API Definition

Use Case APIs coordinate workflows.

They are the approved external entry points for surfaces.

Representative Use Case APIs may include:

| Use Case API | Purpose |
|---|---|
| `KioskMenuViewAPI` | Build kiosk-safe menu screen |
| `KioskCartAPI` | Update cart intent safely |
| `KioskOrderSubmitAPI` | Submit order request safely |
| `KioskPaymentCheckAPI` | Check payment status safely |
| `CatchMenuViewAPI` | Build Catch Menu safe view |
| `CatchOrderStatusAPI` | Build customer-safe order status |
| `SupportReviewAPI` | Build support-safe review surface |
| `CMSPublicationReviewAPI` | Review CMS content before publication |
| `RecoveryReviewAPI` | Review customer recovery case |
| `CompensationReviewAPI` | Review value recovery request |
| `ProviderEvidenceReviewAPI` | Review provider evidence |
| `FranchisePolicyReviewAPI` | Review policy inheritance and overrides |

Use Case APIs coordinate objects.

They preserve transaction boundaries.

They enforce tenant and policy context.

They return safe projections.

---

## 7. Safe Projection API Definition

Safe Projection APIs return only what a surface is allowed to see.

A Safe Projection may contain:

- safe status
- safe message key
- fallback message key
- allowed customer action
- allowed staff action
- review-required flag
- blocked reason category
- display price if approved
- availability if safe
- allergen notice if approved
- payment checking status
- provider delay safe status
- degraded mode safe status
- support escalation route
- audit reference if internal
- i18n keys and locale status

A Safe Projection must not expose:

- raw provider error
- raw POS error
- raw KDS error
- raw payment callback
- internal security state
- containment/quarantine state
- legal hold detail
- AI reasoning
- pgvector similarity score
- compensation approval state unless authorized
- raw customer/payment/provider payloads
- internal root cause before review

Projection is not source of truth.

Projection is controlled output.

---

## 8. Frontend Responsibility Rule

Frontend must remain a rendering layer.

Frontend may:

- render safe projection
- collect customer input
- submit allowed commands
- display i18n message keys
- guide customer to staff assistance
- show safe fallback state

Frontend must not:

- decide payment truth
- decide order acceptance
- decide provider fault
- decide KDS completion truth
- decide compensation eligibility
- assemble raw Menu, Price, Availability, and Allergen objects independently
- call providers directly
- call payment/POS/KDS directly
- expose raw error states
- override tenant/store policy
- bypass i18n review
- infer authority from partial object state

Frontend is not authority.

---

## 9. Kiosk Responsibility Rule

Kiosk must be treated as a surface and device interaction layer.

Kiosk may:

- identify device/session
- render kiosk-safe projection
- collect order intent
- submit order request
- show payment checking status
- show staff assistance status
- show safe degraded mode
- render approved CMS content

Kiosk must not:

- own business logic
- become payment truth
- become order truth
- become provider truth
- become KDS truth
- publish unreviewed CMS text
- decide refund or compensation
- call POS/payment/KDS providers directly
- expose internal object state
- independently compose menu, price, allergen, and availability truth

The Kiosk is a surface.

The core owns controlled behavior.

---

## 10. CMS Responsibility Rule

CMS must also be treated as a controlled object and projection layer.

CMS may manage:

- banner content
- notice content
- menu promotion content
- outage notice content
- degraded operation notice content
- campaign content
- kiosk screen content
- Catch Menu content
- franchise policy notice content

CMS content must declare:

- audience
- surface
- locale
- message key
- approval status
- publication status
- rollback status
- legal review status if needed
- security review status if needed
- i18n dependency
- audit reference

CMS must not become free-form customer text publication.

CMS publication is operational behavior.

---

## 11. Tenant Policy Context Rule

All Use Case APIs must receive or resolve tenant and policy context before composing objects.

Required context may include:

- tenant id
- store id
- brand id if applicable
- operating group if applicable
- legal entity if applicable
- device id
- surface type
- locale
- provider configuration
- store policy
- tenant policy
- HQ policy
- franchise policy
- campaign policy
- customer segment if applicable
- time-based policy if applicable

PolicyContext must be injected before object composition.

Objects must not independently guess tenant policy.

---

## 12. Transaction Boundary Rule

Use Case APIs must protect transaction boundaries.

Examples:

- cart to order transition
- order to POS handoff
- POS handoff to payment verification
- payment verification to KDS routing
- recovery case to compensation request
- compensation request to value action
- CMS draft to publication candidate
- provider callback to verified internal state

These transitions must not be split across frontend judgment.

The server-side Use Case API must coordinate transaction boundary and authority.

---

## 13. Query And Command Separation Rule

APIs must separate query and command.

Query APIs may retrieve safe projections.

Command APIs may request state changes.

Command APIs require:

- authority check
- tenant context
- policy context
- idempotency if needed
- evidence if needed
- audit event
- rollback/fallback plan
- safe response projection

A query must not mutate.

A command must not return raw internal state.

This follows the same practical intent as CQRS without forcing unnecessary architectural ceremony.

---

## 14. Object Boundary Examples

Each object must declare what it is not.

Examples:

| Object | Boundary |
|---|---|
| `MenuObject` | Not inventory truth |
| `MenuItemObject` | Not allergen truth unless approved |
| `CartObject` | Not order confirmation |
| `OrderObject` | Not payment truth |
| `POSHandoffObject` | Not settlement truth |
| `PaymentIntentObject` | Not refund authority |
| `KDSExecutionObject` | Not compensation authority |
| `RecoveryCaseObject` | Not value approval |
| `CompensationRequestObject` | Not value execution |
| `CMSContentObject` | Not legal approval by itself |
| `AIAdvisoryObject` | Not decision authority |
| `VectorContextObject` | Not proof |
| `FrontendSurfaceObject` | Not business authority |

This prevents object confusion.

---

## 15. Kiosk Menu View Example

Unsafe pattern:

    Kiosk calls MenuObject.
    Kiosk calls MenuItemObject.
    Kiosk calls PriceObject.
    Kiosk calls AvailabilityObject.
    Kiosk calls AllergenObject.
    Kiosk calls CMSContentObject.
    Kiosk assembles screen.

This is prohibited as the default pattern.

Safe pattern:

    Kiosk calls KioskMenuViewAPI.
    Server resolves TenantPolicyContext.
    Server composes MenuObject, MenuItemObject, Price, Availability, Allergen, CMSContent, MessageKey.
    Server returns KioskSafeMenuProjection.
    Kiosk renders projection.

The Kiosk must receive a safe view model, not raw object fragments.

---

## 16. Kiosk Order Submit Example

Unsafe pattern:

    Kiosk creates OrderObject.
    Kiosk calls POS provider.
    Kiosk checks payment callback.
    Kiosk sends KDS ticket.
    Kiosk decides customer status.

This is prohibited.

Safe pattern:

    Kiosk calls KioskOrderSubmitAPI.
    Server validates session, cart, policy, item availability, price, allergen, provider readiness, and idempotency.
    Server creates or updates OrderObject.
    Server requests POSHandoffObject transition.
    Server coordinates PaymentIntentObject if applicable.
    Server emits AuditEventObject.
    Server returns customer-safe order projection.

The server coordinates authority.

The Kiosk renders result.

---

## 17. CMS Publication Example

Unsafe pattern:

    CMS writes text.
    Frontend immediately publishes text.
    Kiosk displays text.

This is prohibited for operational or customer-impacting content.

Safe pattern:

    CMS creates CMSContentObject.
    MessageKeyObject validates i18n dependency.
    PolicyContextObject checks tenant/store/franchise policy.
    Legal or security review is routed if needed.
    AuditEventObject records approval.
    FrontendSurfaceObject receives approved safe projection.
    Kiosk renders approved content.

CMS content must pass through policy and projection boundaries.

---

## 18. Support Review Example

Unsafe pattern:

    Support screen calls PaymentObject directly.
    Support sees raw provider payload.
    Support clicks refund.
    Customer receives AI-drafted reply automatically.

This is prohibited.

Safe pattern:

    Support screen calls SupportReviewAPI.
    Server returns masked support-safe projection.
    Support may add note or request evidence.
    CompensationRequestObject may be created as request only.
    AIAdvisoryObject may draft text with label.
    VectorContextObject may provide similar policy with non-proof warning.
    Value action requires separate authority and reconciliation.

Support visibility is not mutation authority.

---

## 19. API Granularity Rule

APIs should not be too fine-grained or too broad.

Too fine-grained:

- object-per-field API
- object-per-screen-fragment API
- frontend-composed business logic

Too broad:

- one giant app API
- one all-purpose Kiosk API
- one admin API with hidden mutation
- one provider gateway without domain boundaries

Recommended granularity:

- one API per use case
- one projection per surface need
- one command per controlled state transition
- one review API per authority boundary
- one provider adapter per verified integration boundary

This balances modularity and operational safety.

---

## 20. API Layer Naming Rule

Recommended naming pattern:

| Layer | Naming Example |
|---|---|
| Domain Object | `OrderObject`, `PaymentIntentObject` |
| Use Case API | `KioskOrderSubmitAPI`, `SupportReviewAPI` |
| Safe Projection | `KioskOrderStatusProjection`, `SupportPaymentReviewProjection` |
| Command | `SubmitOrderCommand`, `RequestPaymentCheckCommand` |
| Event | `OrderSubmittedEvent`, `PaymentVerifiedEvent` |
| Policy Context | `TenantPolicyContext`, `StorePolicyContext` |
| Audit | `OrderAuditEvent`, `PaymentAuditEvent` |

Names must clarify authority.

Names must not imply false execution.

---

## 21. Object Contract Minimum Fields

Every domain object contract should define:

- object name
- purpose
- owner
- state model
- query boundary
- command boundary
- event boundary
- projection boundary
- authority boundary
- provider dependency
- i18n dependency
- audit dependency
- fallback behavior
- security class
- runtime status
- test references
- rollback behavior

No object should enter runtime without a contract.

---

## 22. Safe Projection Minimum Fields

Every Safe Projection should define:

- projection name
- target surface
- audience
- tenant context
- store context
- locale
- safe state
- message key
- fallback message key
- allowed actions
- prohibited actions
- review-required flags
- staff/support route if needed
- provider dependency if any
- payment/POS/KDS boundary if any
- audit reference if internal
- cache/staleness status if applicable

Projection must be explicit about what the surface may do next.

---

## 23. Authority And Audit Rule

Any command that may affect business state must define:

- actor
- tenant
- store
- authority
- policy context
- idempotency key if needed
- evidence reference if needed
- audit event
- failure behavior
- rollback/fallback path

Without authority and audit, command execution is blocked.

---

## 24. AI And pgvector Rule

AI and pgvector may assist object composition only as advisory inputs.

AI may:

- draft
- summarize
- classify candidate
- suggest missing evidence
- suggest review route

pgvector may:

- retrieve similar policy
- retrieve similar case
- retrieve prior incident reference
- retrieve support template

AI and pgvector must not:

- approve
- mutate
- send
- close
- confirm root cause
- confirm provider capability
- decide compensation
- become customer-visible proof

AI is not authority.

pgvector is not proof.

---

## 25. Runtime Deferral Rule

This architecture does not authorize runtime implementation.

The following remain deferred:

- object runtime creation
- Use Case API implementation
- Safe Projection API implementation
- Kiosk frontend implementation
- CMS publication runtime
- payment/POS/KDS provider integration
- support/admin workflow
- recovery/compensation workflow
- AI runtime
- pgvector ingestion or retrieval
- database triggers/functions
- production deployment

A separate narrow authorization is required.

---

## 26. Validation Checklist

Validation must confirm:

1. Domain Object Core is internal.
2. Raw object APIs are not exposed by default.
3. Use Case API is the external workflow boundary.
4. Safe Projection API is the surface output boundary.
5. Frontend does not own business authority.
6. Kiosk does not own payment/order/provider/KDS truth.
7. CMS does not publish operational text without review.
8. Tenant/Policy Context is injected before object composition.
9. Query and command responsibilities are separated.
10. Transaction boundaries are server-side.
11. Support/Admin visibility is not mutation authority.
12. AI remains advisory.
13. pgvector remains non-proof.
14. i18n message keys are required for visible text.
15. Provider evidence is required for provider-dependent objects.
16. Audit is required for authority-bearing transitions.
17. Runtime remains deferred.

---

## 27. Relationship To Previous Documents

This document follows:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`

It references:

- `09660 Catch & Order SaaS Runtime Boundary And Module Naming Policy`
- `09670 Catch Menu Customer Surface Projection And i18n Naming Policy`
- `09740 i18n Message Key Registry And Customer Visible Text Review Policy`
- `09750 Catch & Order Status Message Catalog And Customer Safe State Mapping Policy`
- `09760 Catch Menu Status Surface And Order Handoff Message Mapping Policy`
- `09770 Support Admin Visible Message Boundary And Review Surface Mapping Policy`
- `09790 Compensation Review Authority Matrix And Value Recovery Control Policy`
- `09800 Value Recovery Evidence Audit And Idempotency Review Packet Policy`
- `09850 Mass Recovery Event Grouping And Customer Communication Control Policy`
- `09920 Boundary Test Matrix Static Package Handoff And Validation Mapping Policy`
- `09930 Provider Evidence Registry Static Package Handoff And Capability Traceability Policy`
- `09940 i18n Message Key Registry Static Package Handoff And Locale Review Policy`
- `09950 Catch Menu Status Catalog Static Package Handoff And Customer Safe Surface Policy`
- `09960 Catch And Order Status Catalog Static Package Handoff And Order Handoff Safe State Policy`
- `09970 Support Admin Boundary Catalog Static Package Handoff And Review Surface Policy`
- `09990 AI pgvector Governance Catalog Static Package Handoff And Non Authority Boundary Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- domain object contract templates
- use case API contract templates
- safe projection contract templates
- kiosk object assembly plan
- CMS object publication boundary
- frontend safe rendering policy
- future runtime implementation gates

This document is architecture planning only.

It does not authorize coding.

---

## 28. Final Rule

The system must use Domain Object Core internally, but external surfaces must access it through Use Case APIs and Safe Projection APIs.

Raw object APIs must not become the default external integration pattern.

Kiosk, CMS, Frontend, Catch Menu, Catch & Order, Support/Admin, Owner Admin, HQ Admin, and Franchise OS must not assemble raw business truth directly.

They must receive safe projections produced by server-side use case orchestration under tenant, store, policy, provider, i18n, audit, and security boundaries.

The core owns authority.

The Use Case API owns workflow coordination.

The Safe Projection API owns safe output.

The frontend renders.

The Kiosk is a surface.

The CMS is a controlled content object layer.

The SaaS platform remains modular at the block level and objectized inside the core, while externally exposing safe use-case contracts.
