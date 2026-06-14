# 10053 Catch Menu Mini Kiosk Foundation Static Specification Packet Policy

## 1. Purpose

This document defines the Catch Menu and Mini Kiosk Foundation Static Specification Packet Policy.

The previous artifact `10052` defined the Admin Surface Reuse Candidate and Franchise OS Future Handoff Policy.

This document narrows the first low-risk implementation candidate into a static specification packet.

The selected candidate is:

`CAND-10049-CATCH-MENU-MINI-KIOSK-FOUNDATION-001`

This document defines the static specification structure required before any controlled coding authorization may be considered.

This document does not authorize coding.

This document does not authorize runtime entry.

---

## 2. Candidate Reference

| Field | Value |
|---|---|
| Candidate ID | `CAND-10049-CATCH-MENU-MINI-KIOSK-FOUNDATION-001` |
| Candidate Name | `Catch Menu And Mini Kiosk Foundation` |
| Static Spec Package | `catch_menu_mini_kiosk_foundation_static_spec_v1` |
| Source Candidate Policy | `10051` |
| Related Admin Reuse Policy | `10052` |
| Spec Type | `STATIC_SPECIFICATION_PACKET` |
| Coding Status | `CODING_NOT_AUTHORIZED` |
| Runtime Status | `RUNTIME_ENTRY_NOT_AUTHORIZED` |
| Provider Runtime | `NOT_AUTHORIZED` |
| Payment Runtime | `NOT_AUTHORIZED` |
| POS Runtime | `NOT_AUTHORIZED` |
| KDS Runtime | `NOT_AUTHORIZED` |
| CMS Publication Runtime | `NOT_AUTHORIZED` |
| AI Runtime | `NOT_AUTHORIZED` |
| pgvector Runtime | `NOT_AUTHORIZED` |

---

## 3. Core Principle

The first static specification must describe reusable contracts, not runtime behavior.

The correct rule is:

Specify surface records.
Specify safe projection records.
Specify i18n key families.
Specify device placeholders.
Specify runtime config placeholders.
Specify staff assist placeholders.
Specify CMS notice slot placeholders.
Specify audit placeholders.
Specify fallback states.
Do not implement runtime.
Do not call providers.
Do not process payments.
Do not publish CMS.
Do not execute POS/KDS.

Static specification prepares future implementation review.

It is not implementation.

---

## 4. Static Specification Scope

This static specification may define:

1. Catch Menu surface record
2. Mini Kiosk surface record
3. Catch Menu safe projection contract
4. Mini Kiosk safe projection contract
5. menu item safe status model
6. customer-safe fallback state model
7. i18n key family outline
8. Device Profile placeholder model
9. Runtime Configuration placeholder model
10. staff assist route placeholder
11. CMS notice slot placeholder
12. audit event placeholder
13. capability reference mapping
14. upgrade reference to Full Kiosk
15. future Franchise OS reuse reference

This scope is static only.

---

## 5. Explicitly Excluded Scope

The static specification excludes:

- actual frontend implementation
- Android app implementation
- Windows installer implementation
- production database schema
- production API implementation
- payment provider integration
- POS provider integration
- KDS provider integration
- CMS publication runtime
- customer message sending runtime
- provider webhook handling
- provider credential handling
- refund/coupon/point/wallet execution
- support/admin mutation workflow
- AI runtime calls
- embedding generation
- pgvector ingestion
- pgvector retrieval
- Franchise OS runtime
- production deployment

Excluded scope must not be introduced through specification language.

---

## 6. Static Artifact Set

Recommended static artifact set:

| Artifact | Purpose |
|---|---|
| `surface_registry_static.md` | Human-readable surface registry |
| `surface_registry_static.json` | Structured surface records |
| `safe_projection_contracts_static.md` | Human-readable projection contract |
| `safe_projection_contracts_static.json` | Structured projection records |
| `i18n_key_family_static.md` | Message key family outline |
| `device_profile_placeholder_static.md` | Device Profile placeholder |
| `runtime_config_placeholder_static.md` | Runtime Config placeholder |
| `staff_assist_route_static.md` | Staff assist route placeholder |
| `cms_notice_slot_static.md` | CMS notice slot placeholder |
| `fallback_state_static.md` | Safe fallback state outline |
| `audit_event_placeholder_static.md` | Audit placeholder |
| `capability_reference_static.md` | Capability control references |

Actual file paths are not authorized by this document.

Target paths require a separate coding authorization packet.

---

## 7. Surface Registry Static Record

A surface registry record should include:

| Field | Meaning |
|---|---|
| `surface_id` | Stable surface id |
| `surface_name` | Human-readable name |
| `surface_type` | Customer web/device surface |
| `product_stage` | Catch Menu or Mini Kiosk |
| `primary_audience` | Customer |
| `allowed_capabilities` | Allowed capability references |
| `prohibited_capabilities` | Explicit prohibitions |
| `required_projection` | Safe projection reference |
| `required_i18n_family` | Message key family |
| `device_dependency` | Device dependency if any |
| `cms_dependency` | CMS slot dependency if any |
| `audit_dependency` | Audit placeholder |
| `upgrade_path` | Next surface |
| `fallback_path` | Safe fallback |
| `runtime_status` | Runtime status |

Default runtime status:

`RUNTIME_ENTRY_NOT_AUTHORIZED`

---

## 8. Catch Menu Surface Record Draft

Recommended Catch Menu surface record:

    surface_id:
      SURFACE-CATCH-MENU-001

    surface_name:
      Catch Menu Customer Surface

    surface_type:
      CUSTOMER_WEB_SURFACE

    product_stage:
      STAGE_CATCH_MENU

    primary_audience:
      CUSTOMER

    allowed_capabilities:
      - menu.view.visible_only
      - menu.price_display.visible_only_if_approved
      - menu.availability_display.visible_only_if_approved
      - menu.allergen_display.visible_only_if_approved
      - i18n.customer_message.visible_only
      - cms.notice_slot.visible_only_if_approved
      - staff_assist.request_only_if_enabled

    prohibited_capabilities:
      - payment.truth
      - pos.truth
      - kds.truth
      - compensation.execution
      - provider.capability_approval
      - ai.decision
      - pgvector.proof

    required_projection:
      CatchMenuSafeProjection

    required_i18n_family:
      catch_menu.*

    upgrade_path:
      Catch & Order / Mini Kiosk

    fallback_path:
      Catch Menu Safe Fallback

    runtime_status:
      RUNTIME_ENTRY_NOT_AUTHORIZED

This is a static draft only.

---

## 9. Mini Kiosk Surface Record Draft

Recommended Mini Kiosk surface record:

    surface_id:
      SURFACE-MINI-KIOSK-001

    surface_name:
      Mini Kiosk Customer Device Surface

    surface_type:
      CUSTOMER_DEVICE_SURFACE

    product_stage:
      STAGE_MINI_KIOSK

    primary_audience:
      CUSTOMER

    allowed_capabilities:
      - menu.view.visible_only
      - order.intent.request_only_if_enabled
      - staff_assist.request_only_if_enabled
      - device.profile.visible_only_safe
      - runtime_config.visible_only_safe
      - cms.notice_slot.visible_only_if_approved
      - i18n.customer_message.visible_only

    prohibited_capabilities:
      - payment.confirmation
      - payment.refund_execution
      - pos.direct_call
      - kds.direct_call
      - provider.credential_access
      - compensation.execution
      - ai.decision
      - pgvector.proof

    required_projection:
      MiniKioskSafeProjection

    required_i18n_family:
      mini_kiosk.*

    device_dependency:
      DeviceProfilePlaceholder

    upgrade_path:
      Full Kiosk

    fallback_path:
      Mini Kiosk Menu Display Mode

    runtime_status:
      RUNTIME_ENTRY_NOT_AUTHORIZED

This is a static draft only.

---

## 10. Safe Projection Contract Structure

A Safe Projection contract should define:

| Field | Meaning |
|---|---|
| `projection_id` | Stable projection id |
| `projection_name` | Human-readable name |
| `target_surface` | Surface using projection |
| `audience` | Customer/staff/admin |
| `safe_state` | Surface-safe state |
| `message_key` | i18n key |
| `fallback_message_key` | fallback i18n key |
| `allowed_actions` | Actions surface may request |
| `prohibited_actions` | Actions surface cannot request |
| `blocked_reason_category` | Safe blocked reason |
| `staff_assist_route` | Staff assist route if needed |
| `cms_slots` | Approved CMS slots if any |
| `device_status_safe` | Safe device status if any |
| `stale_status` | Stale/degraded indicator |
| `runtime_status` | Runtime status |

Safe Projection must not expose raw internal state.

---

## 11. Catch Menu Safe Projection Draft

Recommended projection draft:

    projection_id:
      PROJ-CATCH-MENU-SAFE-001

    projection_name:
      Catch Menu Safe Projection

    target_surface:
      SURFACE-CATCH-MENU-001

    audience:
      CUSTOMER

    safe_states:
      - MENU_LOADING
      - MENU_AVAILABLE
      - MENU_TEMPORARILY_UNAVAILABLE
      - ITEM_AVAILABLE
      - ITEM_UNAVAILABLE
      - ITEM_DETAILS_UNAVAILABLE
      - STAFF_ASSISTANCE_REQUIRED
      - DEGRADED_MENU_VIEW
      - SERVICE_UNAVAILABLE

    allowed_actions:
      - view_menu
      - select_locale
      - request_staff_assist_if_enabled
      - start_order_intent_if_enabled

    prohibited_actions:
      - confirm_payment
      - confirm_pos_acceptance
      - confirm_kds_completion
      - execute_compensation
      - approve_provider_capability
      - send_unreviewed_message

    runtime_status:
      RUNTIME_ENTRY_NOT_AUTHORIZED

This is a static draft only.

---

## 12. Mini Kiosk Safe Projection Draft

Recommended projection draft:

    projection_id:
      PROJ-MINI-KIOSK-SAFE-001

    projection_name:
      Mini Kiosk Safe Projection

    target_surface:
      SURFACE-MINI-KIOSK-001

    audience:
      CUSTOMER

    safe_states:
      - KIOSK_READY
      - KIOSK_MENU_AVAILABLE
      - KIOSK_ORDER_INTENT_AVAILABLE
      - KIOSK_STAFF_ASSIST_REQUIRED
      - KIOSK_DEGRADED_MODE
      - KIOSK_DEVICE_UNAVAILABLE
      - KIOSK_CONFIG_STALE
      - KIOSK_SERVICE_UNAVAILABLE

    allowed_actions:
      - view_menu
      - select_locale
      - create_order_intent_if_enabled
      - request_staff_assist_if_enabled

    prohibited_actions:
      - payment_confirmation
      - direct_pos_call
      - direct_kds_call
      - refund_request_execution
      - compensation_execution
      - provider_fault_confirmation

    runtime_status:
      RUNTIME_ENTRY_NOT_AUTHORIZED

This is a static draft only.

---

## 13. i18n Key Family Structure

The i18n key family should be structured by surface and domain.

Recommended pattern:

`<surface>.<domain>.<case>.<message_type>`

Examples:

| Key Family | Meaning |
|---|---|
| `catch_menu.menu.loading.title` | Menu loading title |
| `catch_menu.menu.unavailable.body` | Menu unavailable body |
| `catch_menu.item.unavailable.label` | Item unavailable label |
| `catch_menu.allergen.unavailable.notice` | Allergen unavailable notice |
| `catch_menu.staff_assist.required.body` | Staff assist message |
| `mini_kiosk.device.unavailable.title` | Device unavailable title |
| `mini_kiosk.config.stale.body` | Config stale body |
| `mini_kiosk.degraded.mode.notice` | Degraded mode notice |
| `mini_kiosk.staff_assist.required.body` | Staff assist message |

Actual localized text is not defined here.

---

## 14. Device Profile Placeholder Structure

Device Profile placeholder should include:

| Field | Meaning |
|---|---|
| `device_id` | Device identity placeholder |
| `tenant_id` | Tenant placeholder |
| `store_id` | Store placeholder |
| `brand_id` | Brand placeholder if applicable |
| `device_role` | Mini Kiosk or future role |
| `surface_type` | Surface type |
| `allowed_modules` | Allowed module families |
| `locale_set` | Allowed locales |
| `config_version` | Runtime config version |
| `device_status` | Device status |
| `fallback_mode` | Fallback mode |
| `offline_mode_allowed` | Offline mode flag |
| `cms_profile` | CMS profile placeholder |
| `payment_mode` | Must default disabled |
| `provider_profile` | Provider profile placeholder |

This is a placeholder contract only.

---

## 15. Runtime Configuration Placeholder Structure

Runtime Configuration placeholder should include:

| Field | Meaning |
|---|---|
| `config_id` | Runtime config identity |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope |
| `device_id` | Device scope if applicable |
| `surface_enabled` | Surface enabled status |
| `menu_projection_enabled` | Menu projection enabled |
| `order_intent_enabled` | Order intent enabled |
| `staff_assist_enabled` | Staff assist enabled |
| `cms_notice_slot_enabled` | CMS notice slot enabled |
| `payment_enabled` | Must default false |
| `pos_handoff_enabled` | Must default false |
| `kds_enabled` | Must default false |
| `locale_set` | Locale set |
| `fallback_mode` | Fallback mode |
| `emergency_disabled` | Emergency disable |
| `config_version` | Config version |
| `effective_at` | Effective time |
| `expires_at` | Expiry if temporary |

This is a placeholder contract only.

---

## 16. Staff Assist Route Placeholder Structure

Staff Assist route placeholder should include:

| Field | Meaning |
|---|---|
| `assist_route_id` | Route id |
| `surface_id` | Target surface |
| `reason_category` | Safe reason category |
| `message_key` | Customer-safe message key |
| `store_route` | Store-level route |
| `support_route` | Support route if needed |
| `audit_placeholder` | Audit placeholder |
| `compensation_promise_allowed` | Must default false |
| `provider_fault_claim_allowed` | Must default false |
| `payment_confirmation_allowed` | Must default false |

Staff assist is a route, not resolution.

---

## 17. CMS Notice Slot Placeholder Structure

CMS Notice Slot placeholder should include:

| Field | Meaning |
|---|---|
| `slot_id` | CMS slot id |
| `target_surface` | Surface |
| `audience` | Customer/staff/admin |
| `content_status` | Draft/approved/published candidate |
| `approval_status` | Approval status |
| `publication_status` | Publication status |
| `locale_key_reference` | i18n key reference |
| `effective_at` | Effective time |
| `expires_at` | Expiry time |
| `fallback_key` | Fallback key |
| `audit_placeholder` | Audit placeholder |
| `runtime_status` | Runtime status |

Default runtime status:

`CMS_PUBLICATION_RUNTIME_NOT_AUTHORIZED`

---

## 18. Fallback State Structure

Fallback state should include:

| Field | Meaning |
|---|---|
| `fallback_id` | Fallback id |
| `target_surface` | Surface |
| `trigger_category` | Safe trigger category |
| `safe_state` | Safe fallback state |
| `message_key` | i18n key |
| `staff_assist_required` | Whether staff assist is required |
| `allowed_actions` | Allowed actions |
| `prohibited_actions` | Prohibited actions |
| `audit_placeholder` | Audit placeholder |
| `runtime_status` | Runtime status |

Fallback must be customer-safe and non-blaming.

---

## 19. Audit Event Placeholder Structure

Audit placeholder should include:

| Field | Meaning |
|---|---|
| `audit_event_family` | Event family |
| `surface_id` | Related surface |
| `event_type` | Event type |
| `actor_type` | Customer/device/system/admin |
| `context_scope` | Tenant/store/device |
| `evidence_required` | Evidence requirement |
| `retention_reference` | Retention reference |
| `privacy_class` | Privacy class |
| `runtime_status` | Runtime status |

Audit runtime is not implemented here.

---

## 20. Capability Reference Mapping

Capability references should include:

| Capability | Default Status |
|---|---|
| `menu.view.enabled` | Candidate |
| `menu.price_display.enabled` | Candidate if approved |
| `menu.availability_display.enabled` | Candidate if approved |
| `menu.allergen_display.enabled` | Candidate if approved |
| `order.intent.enabled` | Placeholder only |
| `staff_assist.enabled` | Placeholder only |
| `cms.notice_slot.enabled` | Placeholder only |
| `device.profile.enabled` | Placeholder only |
| `runtime_config.enabled` | Placeholder only |
| `payment.kiosk.enabled` | Disabled |
| `pos.handoff.enabled` | Disabled |
| `kds.enabled` | Disabled |
| `ai.runtime.enabled` | Disabled |
| `pgvector.runtime.enabled` | Disabled |

Capability references do not activate runtime.

---

## 21. Static Spec Validation Requirements

Static spec validation should confirm:

1. Surface records exist.
2. Safe Projection records exist.
3. i18n key family outline exists.
4. Device Profile placeholder exists.
5. Runtime Config placeholder exists.
6. Staff Assist placeholder exists.
7. CMS Notice Slot placeholder exists.
8. Fallback state outline exists.
9. Audit placeholder exists.
10. Capability references exist.
11. High-risk capabilities default disabled.
12. Runtime status remains not authorized.
13. Coding status remains not authorized.
14. Provider runtime is excluded.
15. Payment/POS/KDS runtime is excluded.
16. AI/pgvector runtime is excluded.
17. Franchise OS runtime is excluded.

---

## 22. Static Spec Blockers

| Blocker ID | Meaning |
|---|---|
| `BLOCKER-10053-CODING-0001` | Coding not authorized |
| `BLOCKER-10053-RUNTIME-0001` | Runtime entry not authorized |
| `BLOCKER-10053-PATH-0001` | Target paths not authorized |
| `BLOCKER-10053-FORMAT-0001` | Final file format not authorized |
| `BLOCKER-10053-VALIDATION-0001` | Validation method not finalized |
| `BLOCKER-10053-I18N-0001` | i18n key family not finalized |
| `BLOCKER-10053-PROJECTION-0001` | Projection contract not finalized |
| `BLOCKER-10053-DEVICE-0001` | Device placeholder not finalized |
| `BLOCKER-10053-CONFIG-0001` | Runtime config placeholder not finalized |
| `BLOCKER-10053-REVIEW-0001` | Review route not completed |

These blockers prevent coding.

---

## 23. Relationship To Previous Documents

This document follows:

- `10051 First Implementation Candidate Selection Catch Menu And Mini Kiosk Foundation Policy`
- `10052 Admin Surface Reuse Candidate And Franchise OS Future Handoff Policy`

It references:

- `10020 Modular SaaS Core And Future Kiosk Reuse Principle Policy`
- `10030 Domain Object Core Use Case API And Safe Projection Architecture Policy`
- `10040 Domain Capability Control Plane And Runtime Feature Assembly Policy`
- `10042 Android Device Provisioning Runtime Configuration And Kiosk Mode Policy`
- `10043 Catch Menu Mini Kiosk Admin Surface Reuse And Franchise OS Upgrade Path Policy`
- `10044 Mini Kiosk To Full Kiosk CMS Payment And Device Expansion Policy`
- `10046 Surface Evolution Roadmap And Product Line Continuity Policy`
- `10047 Product Line Capability Matrix And Surface Reuse Registry Policy`
- `10049 Product Line Runtime Entry Candidate And Implementation Priority Policy`
- `10050 Product Line Static Registry Closure And Coding Deferral Policy`
- `10051 First Implementation Candidate Selection Catch Menu And Mini Kiosk Foundation Policy`
- `10052 Admin Surface Reuse Candidate And Franchise OS Future Handoff Policy`
- `10010 Explicit Static Catalog Coding Authorization Packet Template And Approval Boundary Policy`

It prepares later planning for:

- static artifact target file map
- coding authorization packet
- surface registry static file
- safe projection static file
- i18n key family static file
- device profile placeholder static file
- runtime config placeholder static file
- future low-risk coding package

This document is a static specification packet policy only.

It does not authorize coding.

---

## 24. Final Rule

The Catch Menu and Mini Kiosk Foundation static specification may define surface records, Safe Projection contracts, i18n key family outlines, Device Profile placeholders, Runtime Configuration placeholders, staff assist route placeholders, CMS notice slot placeholders, fallback states, audit placeholders, and capability references.

It must not implement runtime behavior.

It must not call providers.

It must not process payment.

It must not execute POS/KDS.

It must not publish CMS content.

It must not execute support/admin mutation.

It must not run AI or pgvector.

It must not deploy production code.

Coding remains unauthorized.

Runtime entry remains deferred.

A separate explicit narrow coding authorization packet is required before any files are created or modified.
