# 010049_Policy_Product_Line_Runtime_Entry_Candidate_And_Implementation_Priority

## 1. Purpose

This document defines the Product Line Runtime Entry Candidate and Implementation Priority Policy.

The previous artifact `10048` defined the SaaS Packaging, Pricing Boundary, and Feature Entitlement Policy.

This document identifies which product line components may become future implementation candidates first, while preserving the rule that runtime implementation is not authorized by this document.

The purpose is to prevent scattered implementation, premature Kiosk development, premature Franchise OS expansion, unverified provider integration, and uncontrolled admin page growth.

This document defines implementation priority candidates only.

It does not authorize coding.

---

## 2. Core Principle

Implementation must begin from the safest reusable foundation.

The correct rule is:

Build the reusable core before high-risk runtime.
Build safe projection before direct execution.
Build device profile before device authority.
Build admin reuse before Franchise OS duplication.
Build provider evidence before provider activation.
Build i18n registry before customer-visible messages.
Build audit before mutation.
Build fallback before high-risk rollout.

The first implementation candidate should not be the full Kiosk.

The first implementation candidate should be the reusable foundation that allows Catch Menu, Mini Kiosk, Kiosk, Admin Surface, and Franchise OS to share the same core later.

---

## 3. Scope

This policy evaluates runtime entry candidates for:

- Catch Menu
- Catch & Order
- Mini Kiosk
- Full Kiosk
- Admin Surface
- Device Profile
- Runtime Configuration
- Domain Capability Control Plane
- Safe Projection
- i18n Message Key Registry
- Provider Evidence Registry
- CMS Control
- Support/Admin Review
- Recovery/Compensation Review
- Franchise OS
- SaaS Packaging/Entitlement
- Windows Local Agent
- Android Device Provisioning
- AI Advisory
- pgvector Context

This policy defines priority and sequencing only.

It does not implement any candidate.

---

## 4. Candidate Selection Principle

A candidate may be prioritized when it satisfies:

1. It supports multiple future surfaces.
2. It reduces later rework.
3. It has low financial/legal risk.
4. It can be implemented without provider execution.
5. It can be implemented without payment execution.
6. It can be implemented without POS/KDS mutation.
7. It can be implemented with static or read-only records first.
8. It strengthens i18n, audit, or safe projection.
9. It improves future Kiosk and Franchise OS readiness.
10. It can be validated without production customer impact.

High-risk features must be delayed.

---

## 5. Priority Tier Catalog

Recommended priority tiers:

| Tier | Meaning |
|---|---|
| `TIER_0_FOUNDATION` | Required foundation before product runtime |
| `TIER_1_SAFE_SURFACE` | Low-risk surface or projection candidate |
| `TIER_2_DEVICE_AND_CONFIG` | Device profile/runtime configuration candidate |
| `TIER_3_CONTROLLED_ADMIN` | Admin/review surface candidate |
| `TIER_4_PROVIDER_CONNECTED` | Provider integration candidate after evidence |
| `TIER_5_FINANCIAL_RUNTIME` | Payment/refund/wallet/value runtime candidate |
| `TIER_6_FRANCHISE_OS` | Multi-store governance candidate |
| `TIER_DEFERRED_HIGH_RISK` | Must remain deferred |

Default:

`TIER_DEFERRED_HIGH_RISK`

---

## 6. Recommended First Implementation Candidate

The recommended first implementation candidate is:

`Catch Menu And Mini Kiosk Foundation`

This candidate should focus on:

- reusable customer-safe menu projection
- i18n message key usage
- safe status display
- basic CMS notice slot if approved
- customer session start boundary
- order intent placeholder if needed
- staff assistance route
- device profile placeholder
- runtime config placeholder
- no payment execution
- no POS/KDS execution
- no compensation execution
- no AI decision
- no pgvector proof

This candidate supports later Mini Kiosk and Full Kiosk without starting from high-risk payment or provider integration.

---

## 7. Recommended Implementation Priority Order

Recommended sequence:

| Priority | Candidate | Reason |
|---|---|---|
| 1 | Static Registry And Catalog Foundation | Needed before runtime |
| 2 | i18n Message Key Registry | Needed for all visible surfaces |
| 3 | Safe Projection Contract | Needed before frontend/Kiosk rendering |
| 4 | Catch Menu Foundation | Lowest-risk customer surface |
| 5 | Mini Kiosk Surface Foundation | Reuses Catch Menu |
| 6 | Device Profile And Runtime Config Static Contract | Needed for Android/Kiosk |
| 7 | Admin Surface Reuse Foundation | Needed before Franchise OS |
| 8 | CMS Controlled Content Foundation | Needed for Kiosk/CMS |
| 9 | Provider Evidence Registry Foundation | Needed before provider activation |
| 10 | Catch & Order Order Intent Foundation | Before POS handoff |
| 11 | POS/KDS Provider Adapter Candidate | Only after provider evidence |
| 12 | Payment Mode Candidate | Only after financial/security gate |
| 13 | Recovery/Support Review Candidate | Before compensation execution |
| 14 | Franchise OS Assembly Candidate | After admin and control plane exist |
| 15 | AI/pgvector Advisory Candidate | After source governance |

This priority order may be revised by explicit review.

---

## 8. Tier 0 Foundation Candidates

Tier 0 candidates include:

| Candidate | Purpose |
|---|---|
| `static_catalog_registry` | Foundation reference catalog |
| `i18n_message_key_registry` | Human-visible message control |
| `safe_projection_contracts` | Surface-safe output contracts |
| `domain_capability_registry` | Feature availability control |
| `provider_evidence_registry` | Provider capability evidence |
| `audit_event_contract` | Traceability foundation |
| `device_profile_contract` | Device identity and role control |
| `runtime_config_contract` | Runtime feature assembly |
| `surface_registry` | Product surface reuse mapping |
| `admin_reuse_registry` | Admin reuse foundation |

Tier 0 should be implemented before high-risk runtime.

---

## 9. Tier 1 Safe Surface Candidates

Tier 1 candidates include:

| Candidate | Purpose |
|---|---|
| `catch_menu_surface` | Lightweight customer menu surface |
| `catch_menu_safe_projection` | Customer-safe menu/status output |
| `mini_kiosk_surface_shell` | Device-shaped surface shell |
| `customer_safe_status_surface` | Safe state rendering |
| `staff_assist_entry` | Staff assistance request path |
| `approved_cms_notice_slot` | Safe CMS display placeholder |
| `locale_selection_surface` | i18n-controlled language selection |

Tier 1 must not include payment, POS/KDS mutation, compensation, or provider execution.

---

## 10. Tier 2 Device And Configuration Candidates

Tier 2 candidates include:

| Candidate | Purpose |
|---|---|
| `device_profile_static_contract` | Device identity and role |
| `android_provisioning_flow_design` | Registration and profile issuance |
| `runtime_config_static_contract` | Runtime feature configuration |
| `device_status_projection` | Safe device status output |
| `device_revoke_candidate` | Revocation planning |
| `config_versioning_candidate` | Versioned runtime config |
| `offline_cached_config_policy_candidate` | Safe offline config planning |

Tier 2 prepares Kiosk and device fleet without granting runtime authority.

---

## 11. Tier 3 Controlled Admin Candidates

Tier 3 candidates include:

| Candidate | Purpose |
|---|---|
| `admin_surface_reuse_registry` | Reusable admin page mapping |
| `device_admin_surface` | Device profile/config review |
| `feature_control_admin_surface` | Capability and feature control |
| `cms_admin_surface` | Controlled CMS review |
| `provider_evidence_admin_surface` | Provider evidence review |
| `support_review_admin_surface` | Support case review |
| `recovery_review_admin_surface` | Recovery review |
| `franchise_os_admin_reuse_map` | Future Franchise OS reuse |

Admin visibility must not imply authority.

---

## 12. Tier 4 Provider Connected Candidates

Tier 4 candidates include:

| Candidate | Purpose |
|---|---|
| `pos_provider_adapter_candidate` | POS handoff integration candidate |
| `payment_provider_verify_candidate` | Payment verification candidate |
| `kds_provider_visibility_candidate` | KDS visibility candidate |
| `cms_provider_publish_candidate` | CMS provider candidate |
| `messaging_provider_candidate` | Customer/staff message candidate |
| `delivery_provider_candidate` | External channel candidate |
| `workforce_provider_candidate` | Workforce interface candidate |

Tier 4 requires provider evidence review before runtime.

Provider name is not capability proof.

---

## 13. Tier 5 Financial Runtime Candidates

Tier 5 candidates include:

| Candidate | Purpose |
|---|---|
| `kiosk_payment_request_candidate` | Payment request surface |
| `payment_verification_candidate` | Payment verification |
| `refund_request_candidate` | Refund request |
| `refund_execution_candidate` | Refund execution |
| `coupon_issue_candidate` | Coupon issue |
| `point_adjust_candidate` | Point adjustment |
| `wallet_credit_candidate` | Wallet/prepaid credit |
| `compensation_execution_candidate` | Value execution |

Tier 5 must remain delayed until financial-grade review, idempotency, reconciliation, audit, authority, and rollback are ready.

---

## 14. Tier 6 Franchise OS Candidates

Tier 6 candidates include:

| Candidate | Purpose |
|---|---|
| `franchise_capability_assembly` | Multi-store capability assembly |
| `franchise_policy_inheritance` | Policy inheritance |
| `store_template_application` | Store capability templates |
| `device_fleet_governance` | Multi-store device management |
| `provider_assignment_governance` | Provider assignment |
| `cms_inheritance_governance` | CMS inheritance |
| `support_recovery_governance` | Support/recovery routing |
| `store_upgrade_workflow` | Store upgrade stages |
| `multi_brand_governance` | Brand-level policy |

Franchise OS must wait until reusable Admin Surfaces and Control Plane foundations exist.

---

## 15. Deferred High-Risk Candidates

The following must remain deferred by default:

- refund execution
- wallet/prepaid runtime
- AI customer auto-send
- AI compensation decision
- provider fault auto-confirmation
- security containment release automation
- legal conclusion automation
- payment confirmation without verification
- POS state overwrite
- KDS-driven compensation
- customer message auto-publication
- production provider integration without evidence
- cross-tenant Franchise OS visibility
- raw provider payload exposure
- unrestricted local offline operation

These require separate future policy and authorization.

---

## 16. Catch Menu First Candidate Rationale

Catch Menu is the safest first product surface because:

- it is primarily read/projection oriented
- it can validate i18n surface rules
- it can validate menu safe projection
- it can support future Mini Kiosk reuse
- it can introduce customer session without payment
- it can introduce CMS notice slot safely
- it can introduce fallback messages
- it can test device-independent rendering
- it can remain separated from POS/payment/KDS authority

Catch Menu foundation gives the platform a visible product without forcing high-risk integrations first.

---

## 17. Mini Kiosk Second Candidate Rationale

Mini Kiosk is the next logical candidate because:

- it reuses Catch Menu projection
- it introduces Device Profile
- it introduces Android provisioning logic
- it introduces device role/surface lock
- it introduces runtime config
- it can support staff assist
- it prepares Full Kiosk
- it can avoid payment execution initially
- it can avoid direct POS/KDS/provider calls initially

Mini Kiosk validates the device path without requiring full financial runtime.

---

## 18. Admin Surface Early Candidate Rationale

Admin Surface should be considered early because:

- it prevents later Franchise OS duplication
- it supports Device Profile management
- it supports Runtime Configuration review
- it supports feature/capability control
- it supports provider evidence review
- it supports CMS review
- it supports support/recovery workflows
- it supports audit visibility
- it becomes reusable by Franchise OS

Admin Surface should be reusable from the beginning.

It must not become hidden authority.

---

## 19. Device Profile And Runtime Config Candidate Rationale

Device Profile and Runtime Configuration should be prioritized because:

- Android requires provisioning after installation
- Kiosk role depends on device profile
- Mini Kiosk and Full Kiosk both need config
- emergency disable requires device/config control
- feature availability depends on runtime config
- Franchise OS later needs device fleet control
- offline/degraded mode depends on config versioning

Without Device Profile and Runtime Config, Kiosk expansion becomes fragile.

---

## 20. CMS Candidate Rationale

CMS should be added after safe projection and admin review are ready.

CMS is needed for:

- Kiosk home screen
- Mini Kiosk notice
- Catch Menu banner
- campaign content
- degraded operation notice
- allergen notice
- franchise policy notice
- emergency announcement

CMS must not be implemented as free text publication.

CMS requires i18n, approval, rollback, audit, and policy gate.

---

## 21. Provider Integration Candidate Rationale

Provider integration should be delayed until provider evidence foundation is ready.

Provider integration requires:

- provider evidence record
- capability matrix
- known limitation
- callback behavior
- idempotency behavior
- retry behavior
- degraded behavior
- support route
- audit event
- reconciliation path if financial
- safe customer message

Provider integration without evidence creates operational risk.

---

## 22. Payment Candidate Rationale

Payment runtime must not be early unless absolutely required.

Payment requires:

- financial-grade security
- provider verification
- idempotency
- reconciliation
- audit
- rollback/failure handling
- staff fallback
- customer-safe payment status
- refund separation
- settlement separation
- fraud/abuse controls
- legal/financial review

Kiosk payment should come after Mini Kiosk and controlled payment mode design.

---

## 23. Franchise OS Candidate Rationale

Franchise OS should not be first.

Franchise OS requires:

- reusable admin surfaces
- store templates
- provider assignment
- device fleet management
- policy inheritance
- capability control
- tenant/store/brand context
- audit continuity
- CMS inheritance
- i18n inheritance
- support/recovery governance
- payment/value authority controls

Building Franchise OS too early risks duplicating unfinished product logic.

Franchise OS should assemble proven surfaces.

---

## 24. AI And pgvector Candidate Rationale

AI and pgvector should enter after source governance exists.

AI can assist:

- support summary
- CMS draft
- i18n draft
- missing evidence checklist
- provider evidence summary
- incident summary

pgvector can assist:

- similar case lookup
- policy lookup
- incident lookup
- provider limitation lookup

They must remain advisory.

AI is not authority.

pgvector is not proof.

---

## 25. First Implementation Candidate Boundary

The first implementation candidate should include only low-risk foundation items.

Recommended included scope:

- static registry records
- message key records
- safe projection contracts
- Catch Menu surface shell
- menu projection read model
- locale selection
- safe fallback state
- staff assistance route placeholder
- Mini Kiosk surface compatibility placeholder
- Device Profile static contract placeholder
- Runtime Config static contract placeholder
- audit event contract placeholder

Recommended excluded scope:

- payment execution
- POS provider calls
- KDS provider calls
- refund/coupon/point/wallet execution
- AI runtime call
- pgvector ingestion/retrieval
- CMS publication runtime
- support/admin mutation
- Franchise OS runtime
- production deployment

---

## 26. Implementation Readiness Score

Each candidate may be scored by:

| Score Area | Meaning |
|---|---|
| `reuse_value` | How much future product reuse it enables |
| `risk_level` | Financial/legal/security risk |
| `provider_dependency` | Provider dependency strength |
| `i18n_dependency` | Message readiness |
| `audit_dependency` | Evidence readiness |
| `policy_dependency` | Policy complexity |
| `device_dependency` | Device/profile/config need |
| `rollback_ready` | Rollback availability |
| `fallback_ready` | Fallback availability |
| `runtime_complexity` | Runtime complexity |
| `franchise_reuse` | Future Franchise OS reuse value |

Candidates with high reuse and low risk should go first.

---

## 27. Candidate Status Catalog

Recommended candidate statuses:

| Status | Meaning |
|---|---|
| `CANDIDATE_PLANNED` | Candidate identified |
| `CANDIDATE_REVIEW_REQUIRED` | Needs review |
| `CANDIDATE_READY_FOR_STATIC_SPEC` | Ready for static spec |
| `CANDIDATE_READY_FOR_CONTRACT` | Ready for contract design |
| `CANDIDATE_READY_FOR_AUTH_PACKET` | Ready for coding authorization packet |
| `CANDIDATE_BLOCKED_BY_PROVIDER` | Blocked by provider evidence |
| `CANDIDATE_BLOCKED_BY_POLICY` | Blocked by policy |
| `CANDIDATE_BLOCKED_BY_SECURITY` | Blocked by security |
| `CANDIDATE_BLOCKED_BY_FINANCE` | Blocked by finance |
| `CANDIDATE_DEFERRED` | Deferred |
| `CODING_NOT_AUTHORIZED` | Coding not authorized |

Default:

`CODING_NOT_AUTHORIZED`

---

## 28. Candidate Approval Requirements

Before a candidate moves to coding authorization, it must have:

- candidate id
- package scope
- target surfaces
- included capabilities
- excluded capabilities
- dependency list
- provider evidence requirement
- i18n requirement
- audit requirement
- security boundary
- fallback behavior
- rollback behavior
- validation checklist
- review route
- runtime status
- explicit authorization packet

No candidate may enter coding without explicit narrow authorization.

---

## 29. Recommended Next Candidate ID

Recommended next candidate id:

`CAND-10049-CATCH-MENU-MINI-KIOSK-FOUNDATION-001`

Recommended package name:

`catch_menu_mini_kiosk_foundation_static_and_safe_projection_candidate_v1`

Recommended status:

`CANDIDATE_READY_FOR_STATIC_SPEC`

Coding status:

`CODING_NOT_AUTHORIZED`

Runtime status:

`RUNTIME_ENTRY_NOT_AUTHORIZED`

This candidate may be detailed in a later document.

---

## 30. Anti-Patterns

Avoid:

- starting with full Kiosk payment
- starting with provider integration before evidence
- starting with Franchise OS before admin reuse
- starting with AI/pgvector before source governance
- building Mini Kiosk separately from Catch Menu
- building admin pages separately from Franchise OS future reuse
- implementing payment before idempotency/reconciliation
- implementing CMS as free text publication
- implementing device config without revoke/emergency disable
- implementing feature flags without policy gate
- treating package entitlement as runtime authority
- treating surface visibility as execution authority

These anti-patterns cause expensive rework and security risk.

---

## 31. Validation Checklist

Validation must confirm:

1. Candidate selection principle is defined.
2. Priority tier catalog exists.
3. First implementation candidate is identified.
4. Priority order is documented.
5. Tier 0 foundation candidates are defined.
6. Tier 1 safe surface candidates are defined.
7. Tier 2 device/config candidates are defined.
8. Tier 3 admin candidates are defined.
9. Tier 4 provider candidates are delayed until evidence.
10. Tier 5 financial candidates are delayed.
11. Tier 6 Franchise OS candidates are delayed until reusable foundations exist.
12. High-risk candidates are deferred.
13. Catch Menu first rationale is defined.
14. Mini Kiosk second rationale is defined.
15. Admin Surface early rationale is defined.
16. Device Profile/Runtime Config rationale is defined.
17. CMS candidate rationale is defined.
18. Provider integration rationale is defined.
19. Payment candidate rationale is defined.
20. Franchise OS candidate rationale is defined.
21. AI/pgvector rationale is advisory-only.
22. First implementation candidate boundary is narrow.
23. Readiness score exists.
24. Candidate status catalog exists.
25. Candidate approval requirements exist.
26. Recommended next candidate id exists.
27. Coding remains unauthorized.
28. Runtime remains deferred.

---

## 32. Relationship To Previous Documents

This document follows:

- `10048 SaaS Packaging Pricing Boundary And Feature Entitlement Policy`

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
- `10047 Product Line Capability Matrix And Surface Reuse Registry Policy`
- `10048 SaaS Packaging Pricing Boundary And Feature Entitlement Policy`
- `10000 Foundation Static Catalog Package Closure And Runtime Entry Deferral Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- `10050 Product Line Static Registry Closure And Coding Deferral Policy`
- `10051 First Implementation Candidate Selection Catch Menu And Mini Kiosk Foundation Policy`
- implementation candidate packet
- static spec packet
- safe projection contract packet
- future coding authorization packet

This document is architecture planning only.

It does not authorize coding.

---

## 33. Final Rule

The first runtime-entry candidate should not be Full Kiosk, payment, provider integration, compensation execution, AI runtime, pgvector runtime, or Franchise OS.

The first candidate should be the reusable low-risk foundation that supports Catch Menu, Mini Kiosk, Safe Projection, i18n, Device Profile, Runtime Configuration, Admin reuse, and later Franchise OS assembly.

Implementation priority must follow reuse value and risk control.

High-risk runtime remains deferred.

Coding remains unauthorized until a separate explicit narrow authorization packet is approved.
