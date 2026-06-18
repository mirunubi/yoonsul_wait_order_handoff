# 010051_Policy_First_Implementation_Candidate_Selection_Catch_Menu_And_Mini_Kiosk_Foundation

## 1. Purpose

This document defines the First Implementation Candidate Selection for the Catch Menu and Mini Kiosk Foundation.

The previous artifact `10050` closed the `10020~10050` product line planning sequence and deferred coding/runtime implementation.

This document identifies the first low-risk implementation candidate for future static specification and controlled authorization review.

The selected candidate is:

`CAND-10049-CATCH-MENU-MINI-KIOSK-FOUNDATION-001`

This document does not authorize coding.

This document does not authorize runtime entry.

It only narrows the first candidate scope for future static specification.

---

## 2. Candidate Identity

| Field | Value |
|---|---|
| Candidate ID | `CAND-10049-CATCH-MENU-MINI-KIOSK-FOUNDATION-001` |
| Candidate Name | `Catch Menu And Mini Kiosk Foundation` |
| Package Name | `catch_menu_mini_kiosk_foundation_static_and_safe_projection_candidate_v1` |
| Candidate Type | `FIRST_IMPLEMENTATION_CANDIDATE_SELECTION` |
| Planning Status | `CANDIDATE_SELECTED_FOR_STATIC_SPEC` |
| Coding Status | `CODING_NOT_AUTHORIZED` |
| Runtime Status | `RUNTIME_ENTRY_NOT_AUTHORIZED` |
| Risk Level | `LOW_TO_MEDIUM_IF_STATIC_ONLY` |
| Provider Runtime | `NOT_AUTHORIZED` |
| Payment Runtime | `NOT_AUTHORIZED` |
| POS Runtime | `NOT_AUTHORIZED` |
| KDS Runtime | `NOT_AUTHORIZED` |
| CMS Publication Runtime | `NOT_AUTHORIZED` |
| AI Runtime | `NOT_AUTHORIZED` |
| pgvector Runtime | `NOT_AUTHORIZED` |

---

## 3. Core Principle

The first candidate must validate reusable foundations without entering high-risk runtime.

The correct rule is:

Start with customer-safe menu projection.
Start with i18n message keys.
Start with surface registry.
Start with Safe Projection contracts.
Start with Device Profile placeholders.
Start with Runtime Configuration placeholders.
Start with staff assist route placeholders.
Start with audit placeholders.
Do not start with payment.
Do not start with provider execution.
Do not start with Full Kiosk.
Do not start with Franchise OS runtime.

The first implementation candidate is foundation-first.

---

## 4. Why Catch Menu First

Catch Menu is the safest first visible product surface because:

- it is primarily projection-oriented
- it can be implemented without payment
- it can be implemented without POS/KDS runtime
- it can validate i18n structure
- it can validate customer-safe status rules
- it can validate menu projection rules
- it can support QR/NFC entry later
- it can support Mini Kiosk reuse later
- it can support CMS notice slots later
- it can support order intent later
- it can support Franchise OS configuration later

Catch Menu creates visible value without requiring immediate financial/provider runtime.

---

## 5. Why Mini Kiosk Is Included As Foundation

Mini Kiosk is included as a foundation candidate because it reuses Catch Menu rather than replacing it.

Mini Kiosk should validate:

- device-shaped surface reuse
- Device Profile placeholder
- Runtime Configuration placeholder
- surface role concept
- kiosk-safe projection naming
- staff assist route
- fallback/degraded message boundary
- Android provisioning readiness
- future Full Kiosk compatibility

Mini Kiosk is included as a structural target, not as full runtime hardware implementation.

---

## 6. Candidate Scope

The candidate scope may include static or contract-level planning for:

1. Catch Menu surface registry record
2. Mini Kiosk surface registry record
3. Catch Menu safe projection contract
4. Mini Kiosk safe projection contract
5. customer-safe menu status contract
6. i18n message key family outline
7. Device Profile placeholder contract
8. Runtime Configuration placeholder contract
9. staff assistance route placeholder
10. CMS safe notice slot placeholder
11. fallback state placeholder
12. audit event placeholder
13. capability control references
14. upgrade path reference to Full Kiosk
15. Franchise OS reuse reference

This scope is static/contract planning only.

---

## 7. Explicitly Excluded Scope

The candidate explicitly excludes:

- actual payment flow
- payment verification
- refund execution
- coupon issuance
- point adjustment
- wallet/prepaid credit
- POS provider call
- KDS provider call
- provider webhook
- provider credential handling
- actual CMS publication
- customer message send
- AI runtime call
- embedding generation
- pgvector ingestion
- pgvector retrieval
- Android app implementation
- Windows installer implementation
- production database mutation
- production deployment
- Franchise OS runtime

Excluded scope must not be introduced indirectly.

---

## 8. Candidate Architecture Boundary

The candidate should follow:

    Static Surface Registry
      ↓
    Safe Projection Contract
      ↓
    i18n Message Key Family
      ↓
    Capability Control Reference
      ↓
    Device Profile Placeholder
      ↓
    Runtime Config Placeholder
      ↓
    Staff Assist Placeholder
      ↓
    Audit Placeholder
      ↓
    Future Runtime Authorization Gate

This candidate prepares the architecture.

It does not activate runtime.

---

## 9. Catch Menu Foundation Components

Catch Menu foundation may define:

| Component | Purpose |
|---|---|
| `CatchMenuSurfaceRecord` | Surface registry record |
| `CatchMenuMenuProjection` | Customer-safe menu projection |
| `CatchMenuItemStatusProjection` | Safe item status |
| `CatchMenuPriceProjection` | Approved price display |
| `CatchMenuAvailabilityProjection` | Availability display if allowed |
| `CatchMenuAllergenProjection` | Allergen notice if approved |
| `CatchMenuI18nKeyFamily` | Message keys |
| `CatchMenuFallbackState` | Safe fallback state |
| `CatchMenuStaffAssistRoute` | Staff assistance route placeholder |
| `CatchMenuCMSNoticeSlot` | Approved CMS notice placeholder |

These are planning contracts.

---

## 10. Mini Kiosk Foundation Components

Mini Kiosk foundation may define:

| Component | Purpose |
|---|---|
| `MiniKioskSurfaceRecord` | Surface registry record |
| `MiniKioskDeviceProfilePlaceholder` | Device identity/role placeholder |
| `MiniKioskRuntimeConfigPlaceholder` | Runtime config placeholder |
| `MiniKioskMenuProjection` | Reused menu projection |
| `MiniKioskOrderIntentPlaceholder` | Future order intent placeholder |
| `MiniKioskStaffAssistRoute` | Staff assist route |
| `MiniKioskDegradedProjection` | Safe degraded status |
| `MiniKioskCMSNoticeSlot` | Approved CMS notice placeholder |
| `MiniKioskDeviceStatusProjection` | Safe device status placeholder |
| `MiniKioskUpgradeReference` | Full Kiosk upgrade reference |

These components must reuse Catch Menu foundations where possible.

---

## 11. Safe Projection Requirements

Safe Projection requirements include:

- no raw internal state
- no raw provider error
- no payment truth
- no POS acceptance truth
- no KDS completion truth
- no compensation promise
- no provider fault confirmation
- no legal conclusion
- no AI reasoning
- no pgvector similarity output
- no security containment detail
- approved i18n keys only
- safe fallback state
- staff assistance route if uncertain
- stale/degraded indication if needed

Safe Projection protects the surface.

---

## 12. i18n Requirements

The candidate must prepare i18n key families for:

- menu loading
- menu unavailable
- item available
- item unavailable
- item temporarily hidden
- allergen information unavailable
- price unavailable
- staff assistance required
- order intent unavailable
- payment unavailable
- provider unavailable safe message
- degraded operation
- retry later
- device unavailable
- language selection
- CMS notice placeholder

No customer-visible operational text should be hardcoded.

---

## 13. Device Profile Placeholder Requirements

Device Profile placeholder may include:

- device id
- tenant id
- store id
- brand id if applicable
- device role
- surface type
- allowed modules
- locale set
- config version
- device status
- fallback mode
- offline mode eligibility
- CMS profile placeholder
- payment mode placeholder
- provider profile placeholder

This placeholder does not implement provisioning.

It prepares the contract.

---

## 14. Runtime Configuration Placeholder Requirements

Runtime Configuration placeholder may include:

- surface enabled status
- menu projection enabled status
- order intent enabled status
- staff assist enabled status
- CMS slot enabled status
- payment disabled status
- POS disabled status
- KDS disabled status
- config version
- effective time
- expiry time if temporary
- emergency disable status
- fallback mode
- locale set
- safe projection mode

Runtime Configuration placeholder must default high-risk functions to disabled.

---

## 15. Staff Assist Placeholder Requirements

Staff assist placeholder may define:

- staff assist available flag
- staff assist message key
- assist reason category
- surface type
- store route
- support route if needed
- audit placeholder
- no compensation promise
- no provider fault claim
- no payment confirmation
- no refund promise

Staff assist is a route.

It is not resolution.

---

## 16. CMS Notice Slot Placeholder Requirements

CMS notice slot placeholder may define:

- slot id
- target surface
- audience
- locale key reference
- content status
- approval status
- publication status
- effective time
- expiry time
- fallback key
- audit reference placeholder

CMS slot must not render draft or unapproved content.

CMS publication runtime remains unauthorized.

---

## 17. Audit Placeholder Requirements

Audit placeholder may prepare event families such as:

- surface registry created
- projection contract created
- i18n key family created
- device profile placeholder created
- runtime config placeholder created
- staff assist placeholder created
- CMS notice slot placeholder created
- fallback state created
- candidate reviewed
- candidate blocked
- candidate approved for static spec

Audit placeholder does not implement audit runtime.

---

## 18. Capability Control References

The candidate must reference capability controls for:

- menu view
- price display
- availability display
- allergen display
- order intent
- staff assist
- CMS notice slot
- device profile
- runtime configuration
- fallback mode
- payment disabled state
- POS disabled state
- KDS disabled state

Capability control references must not create runtime flags.

---

## 19. Default Disabled High-Risk Features

The following must default to disabled:

| Feature | Default |
|---|---|
| `payment.kiosk.enabled` | `false` |
| `payment.verify.enabled` | `false` |
| `pos.handoff.enabled` | `false` |
| `kds.ticket_create.enabled` | `false` |
| `kds.status_callback.enabled` | `false` |
| `coupon.issue.enabled` | `false` |
| `point.adjust.enabled` | `false` |
| `wallet.credit.enabled` | `false` |
| `cms.publish.enabled` | `false` |
| `ai.runtime.enabled` | `false` |
| `pgvector.runtime.enabled` | `false` |

Disabled by default prevents accidental authority expansion.

---

## 20. Candidate Readiness Requirements

Before this candidate may move to a static specification packet, it must have:

1. surface registry scope
2. projection contract scope
3. i18n key family scope
4. Device Profile placeholder scope
5. Runtime Config placeholder scope
6. staff assist placeholder scope
7. CMS slot placeholder scope
8. fallback state scope
9. audit placeholder scope
10. excluded high-risk scope
11. validation checklist
12. reviewer route
13. blocker list
14. coding deferral statement
15. runtime deferral statement

This document provides candidate selection, not full static specification.

---

## 21. Candidate Reviewers

Recommended reviewers:

| Reviewer | Reason |
|---|---|
| Product | Product surface and roadmap |
| Engineering | Contract feasibility |
| Security | Runtime and device boundary |
| QA | Validation and fallback |
| i18n/Content | Message keys |
| Support | Staff assist and customer-safe messages |
| Operations | Store usability |
| Provider Ops | Provider boundary awareness |
| Franchise Ops | Future reuse path |
| Data Governance | Audit and projection boundaries |

Finance is required only if payment/value enters scope.

Payment/value is excluded here.

---

## 22. Candidate Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-10051-CODING-0001` | Coding not authorized |
| `BLOCKER-10051-RUNTIME-0001` | Runtime entry not authorized |
| `BLOCKER-10051-SPEC-0001` | Static spec not created |
| `BLOCKER-10051-PROJECTION-0001` | Safe Projection contract not finalized |
| `BLOCKER-10051-I18N-0001` | i18n key family not finalized |
| `BLOCKER-10051-DEVICE-0001` | Device Profile placeholder not finalized |
| `BLOCKER-10051-CONFIG-0001` | Runtime Config placeholder not finalized |
| `BLOCKER-10051-CMS-0001` | CMS slot placeholder not finalized |
| `BLOCKER-10051-AUDIT-0001` | Audit placeholder not finalized |
| `BLOCKER-10051-REVIEW-0001` | Review route not completed |

These blockers prevent coding.

---

## 23. Validation Checklist

Validation must confirm:

1. Candidate identity is defined.
2. Candidate scope is narrow.
3. Catch Menu rationale is defined.
4. Mini Kiosk rationale is defined.
5. Payment is excluded.
6. POS runtime is excluded.
7. KDS runtime is excluded.
8. CMS publication runtime is excluded.
9. AI runtime is excluded.
10. pgvector runtime is excluded.
11. Safe Projection requirements are defined.
12. i18n requirements are defined.
13. Device Profile placeholder is defined.
14. Runtime Configuration placeholder is defined.
15. Staff Assist placeholder is defined.
16. CMS Notice Slot placeholder is defined.
17. Audit placeholder is defined.
18. Capability references are non-runtime.
19. High-risk features default disabled.
20. Candidate readiness requirements are defined.
21. Reviewers are identified.
22. Blockers are listed.
23. Coding remains unauthorized.
24. Runtime remains deferred.

---

## 24. Relationship To Previous Documents

This document follows:

- `10050 Product Line Static Registry Closure And Coding Deferral Policy`

It references:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`
- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`
- `10046 Surface Evolution Roadmap And Product Line Continuity Policy`
- `10047 Product Line Capability Matrix And Surface Reuse Registry Policy`
- `10048 SaaS Packaging Pricing Boundary And Feature Entitlement Policy`
- `10049 Product Line Runtime Entry Candidate And Implementation Priority Policy`
- `10050 Product Line Static Registry Closure And Coding Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- `10052 Admin Surface Reuse Candidate And Franchise OS Future Handoff Policy`
- first candidate static specification packet
- Catch Menu surface registry static record
- Mini Kiosk surface registry static record
- Safe Projection contract static packet
- Device Profile placeholder static packet
- Runtime Configuration placeholder static packet
- future coding authorization packet

This document is candidate selection only.

It does not authorize coding.

---

## 25. Final Rule

The first implementation candidate is selected as:

`CAND-10049-CATCH-MENU-MINI-KIOSK-FOUNDATION-001`

This candidate should prepare the reusable low-risk foundation for Catch Menu and Mini Kiosk through surface registry records, Safe Projection contracts, i18n key families, Device Profile placeholders, Runtime Configuration placeholders, staff assist route placeholders, CMS notice slot placeholders, fallback state placeholders, and audit placeholders.

It must exclude payment, POS, KDS, refund, coupon, point, wallet, CMS publication runtime, AI runtime, pgvector runtime, provider runtime, Franchise OS runtime, and production deployment.

This document selects the candidate.

It does not authorize coding.

It does not authorize runtime.

The next safe step is a separate static specification packet and explicit narrow authorization review.
