# 5010 Data Model Draft

## Domain Model

Core domains:

- Tenant
- Store
- Store Runtime
- Customer Session
- Store Access Context
- Waiting Session
- Handoff Session
- Mini Kiosk Session
- Menu
- Cart
- Menu Snapshot
- Order Intent
- Staff Handoff
- Staff Action
- Handoff Event
- Audit Event

## Conceptual Entity Layer

This section is conceptual only.
It does not define SQL, migrations, final schema, or implementation fields.

## SaaS Runtime Conceptual Entities

This section is conceptual only.
It does not define SQL or physical columns.

- `tenant`: SaaS customer boundary.
- `tenant_account`: tenant-level account or contract context.
- `tenant_user`: person or admin identity operating within a tenant.
- `store`: operational unit under a tenant or standalone MVP context.
- `store_runtime`: active operating mode for a store.
- `store_package_plan`: package selected for a store.
- `store_feature_flags`: explicit feature switches for store behavior.
- `store_integration_profile`: integration level for POS, staff screen, Store Agent, printer, or Full OS.
- `store_payment_profile`: payment authority mode for store POS, future platform payment, or Full OS payment control.
- `store_language_profile`: languages exposed to customer-facing surfaces.
- `store_menu_profile`: menu display and menu content readiness context.
- `store_agent_profile`: Store Agent or local support capability context.

## Admin Console Conceptual Entities

This section is conceptual only.
It does not define SQL or physical columns.

- `admin_user`: admin-side user identity for platform, tenant, company, legal, operating group, store, support, or audit context.
- `admin_role_assignment`: conceptual assignment of an admin role to a context.
- `admin_context_scope`: conceptual scope boundary such as tenant, company, legal entity, operating group, or store.
- `admin_change_request`: requested package, feature, integration, payment profile, or runtime configuration change.
- `admin_approval`: approval record for configuration or recovery actions requiring authority.
- `runtime_config_change`: conceptual record of store runtime setting change.
- `manual_recovery_item`: operational item requiring human recovery action.
- `support_action`: support operator action or assistance record.
- `audit_event`: audit-visible record for admin changes, recovery actions, support actions, and corrections.
- `admin_screen_access_policy`: conceptual policy controlling screen visibility by role and context.
- `admin_approval_workflow`: conceptual approval workflow for high-risk runtime changes.
- `admin_config_version`: conceptual version marker for runtime configuration traceability.
- `admin_audit_event`: audit-visible admin event for changes, approvals, exports, and recovery.
- `recovery_queue`: conceptual queue grouping operational recovery items.
- `recovery_queue_item`: individual recovery item requiring review or action.
- `recovery_action`: append-only recovery action record.
- `support_access_session`: scoped support access session for support_operator actions.
- `export_audit_event`: audit-visible export/report action record.

## Future Data Governance Conceptual Entities

This section is conceptual only.
It does not define SQL or physical columns.

- `data_capture_category`: conceptual category describing why and how a runtime signal is captured.
- `data_classification`: conceptual classification for operational, customer-identifiable, sensitive, aggregate, anonymized, or pseudonymized data.
- `data_export_event`: audit-visible event for report, export, support, or future intelligence data movement.
- `data_sharing_policy`: conceptual policy boundary for tenant, store, legal entity, support, third-party, and future Franchise OS sharing.
- `data_sanitization_job`: conceptual process that prepares aggregate, anonymized, or pseudonymized datasets.
- `analytics_dataset`: conceptual dataset prepared for approved analytics or reporting.
- `franchise_intelligence_export`: conceptual future export of permitted intelligence material to a Franchise OS context.
- `franchise_recommendation`: conceptual future recommendation created from approved intelligence material.
- `recommendation_review`: conceptual review and approval record for future recommendations.
- `recommendation_application_event`: audit-visible event for controlled application of an approved recommendation.

## Security And Audit Governance Conceptual Entities

This section is conceptual only.
It does not define SQL or physical columns.

- `data_retention_policy`: conceptual policy that maps data category and sensitivity to retention, archival, and deletion direction.
- `data_deletion_request`: conceptual request to delete, mask, or minimize eligible data while preserving required audit integrity.
- `tenant_offboarding_export`: conceptual export package and workflow for tenant offboarding.
- `support_access_session`: scoped, time-bounded support access context for support_operator actions.
- `access_review_event`: audit-visible event for reviewing admin, support, export, or sensitive data access.
- `data_export_request`: conceptual request to generate or deliver a report, export, dataset, or future intelligence package.
- `data_export_package`: conceptual package produced from an approved export request.
- `anonymization_rule`: conceptual rule for removing identifiers and reducing re-identification risk.
- `pseudonymization_rule`: conceptual rule for replacing identifiers while preserving controlled linkage.
- `audit_evidence_record`: conceptual evidence record for high-risk access, change, export, retention, deletion, recovery, and support actions.
- `compliance_review_record`: conceptual record for legal, policy, support, tenant dispute, or future Franchise OS handoff review.

## App And API Projection Conceptual Entities

This section is conceptual only.
It does not define SQL or physical columns.

- `app_surface`: conceptual customer, Mini Kiosk, store, admin, support, owner, or analytics surface.
- `channel_entry`: conceptual QR, NFC, tablet, shared link, waiting link, login, or support access entry route.
- `customer_webapp_session`: conceptual customer-facing webapp session for waiting, browsing, cart, order candidate, and handoff.
- `mini_kiosk_webapp_session`: conceptual customer-facing but store-assisted Mini Kiosk session.
- `store_console_session`: conceptual staff or store manager operational console session.
- `admin_console_session`: conceptual admin configuration, governance, approval, audit, and report session.
- `support_console_session`: conceptual scoped and audited support console session.
- `api_contract_group`: conceptual grouping of future API contracts by domain and authority boundary.
- `api_action_authority`: conceptual authority rule for who may call or request an API action under role/context scope.
- `api_audit_envelope`: conceptual audit wrapper for high-risk mutations, exports, support actions, and integration attempts.
- `api_idempotency_key`: conceptual idempotency marker for future duplicate prevention on high-risk actions.
- `surface_visibility_rule`: conceptual rule describing which surface may view a state family under context scope.
- `state_visibility_matrix`: conceptual mapping of surface, visible state, requestable action, approval, audit, and forbidden action.
- `customer_wording_rule`: conceptual rule for customer-facing wording by state and confirmation authority.
- `integration_wording_policy`: conceptual wording policy by integration level such as staff screen, Store Agent, printer, POS API, or Full OS.
- `action_authority_rule`: conceptual rule defining which roles can request, perform, approve, or only view an action.
- `action_escalation_rule`: conceptual escalation rule for unresolved recovery, printer, POS API, payment, export, or support cases.
- `authority_approval_requirement`: conceptual approval requirement attached to high-risk actions and authority changes.

### tenant

Represents the SaaS tenant boundary that may own one or more stores in a future SaaS model.

Conceptual attributes:

- tenant identity
- tenant display name
- tenant status
- tenant-level policy boundary

### store

Represents one store runtime location within a tenant or standalone MVP context.

Conceptual attributes:

- store identity
- store display name
- store access context
- supported service modes
- supported languages

### store_runtime

Represents current store operation visibility for customer and staff handoff.

Conceptual attributes:

- runtime visibility state
- staff availability signal
- waiting pressure signal
- delay or degraded operation signal
- manual recovery signal

### customer_session

Represents the customer-facing session created from QR, NFC, link, or Mini Kiosk entry.

Conceptual attributes:

- customer session identity
- selected language
- current mode
- linked waiting session
- linked handoff session
- expiration boundary

### waiting_session

Represents the customer's waiting lifecycle before handoff.

Conceptual attributes:

- waiting identity
- customer session relationship
- store relationship
- waiting status
- party or visit context
- called, arrived, no-show, cancellation, and handoff markers

### handoff_session

Represents the operational bridge between customer order intent and store confirmation.

Conceptual attributes:

- handoff identity
- customer session relationship
- waiting session relationship when available
- order intent relationship
- table or pickup context
- store review status
- confirmation or recovery status

### mini_kiosk_session

Represents a lightweight ordering session that does not require waiting management.

Conceptual attributes:

- Mini Kiosk session identity
- selected language
- menu browsing status
- order intent relationship
- staff help request status
- expiration boundary

### menu_snapshot

Represents the menu state shown to the customer when order intent is captured.

Conceptual attributes:

- menu snapshot identity
- store relationship
- language display version
- item availability view
- option availability view
- price display view

### order_intent

Represents the customer's pre-confirmation order candidate.

Conceptual attributes:

- order intent identity
- customer session relationship
- handoff session relationship
- menu snapshot relationship
- selected items and options
- estimated total
- customer note
- store review status

### staff_action

Represents a staff action that changes waiting, handoff, confirmation, cancellation, or recovery state.

Conceptual attributes:

- staff action identity
- staff actor context
- action type
- target session
- reason or note
- visible result

### handoff_event

Represents a customer or staff event that changes the handoff timeline.

Conceptual attributes:

- event identity
- event type
- event source
- related customer session
- related waiting or handoff session
- event time

### audit_event

Represents an audit-visible record for important state changes and recovery decisions.

Conceptual attributes:

- audit identity
- actor context
- action summary
- before and after state reference
- reason
- audit time

## Entity Draft

### Store

Represents one store location.

Fields:

- `id`
- `name`
- `slug`
- `default_language`
- `supported_languages`
- `timezone`
- `created_at`
- `updated_at`

### StoreAccessCode

Represents QR, NFC, or URL entry into the store context.

Fields:

- `id`
- `store_id`
- `code`
- `entry_type`
- `target_mode`
- `is_active`
- `created_at`

`entry_type` examples: `qr`, `nfc`, `url`

`target_mode` examples: `waiting`, `mini_kiosk`

### WaitingSession

Represents a customer or party waiting to be seated.

Fields:

- `id`
- `store_id`
- `session_code`
- `customer_display_name`
- `party_size`
- `status`
- `created_at`
- `called_at`
- `seated_at`
- `cancelled_at`

Statuses:

- `created`
- `waiting`
- `called`
- `seated`
- `cancelled`

### TableAssignment

Represents table assignment at seating.

Fields:

- `id`
- `store_id`
- `waiting_session_id`
- `table_number`
- `assigned_by_staff_id`
- `assigned_at`

### MenuCategory

Represents a group of menu items.

Fields:

- `id`
- `store_id`
- `sort_order`
- `name_i18n`
- `description_i18n`
- `is_active`

### MenuItem

Represents an orderable menu item.

Fields:

- `id`
- `store_id`
- `category_id`
- `name_i18n`
- `description_i18n`
- `photo_url`
- `base_price`
- `is_available`
- `sort_order`

### OptionGroup

Represents a selectable option group for a menu item.

Fields:

- `id`
- `store_id`
- `menu_item_id`
- `name_i18n`
- `min_select`
- `max_select`
- `is_required`
- `sort_order`

### OptionItem

Represents one selectable option.

Fields:

- `id`
- `store_id`
- `option_group_id`
- `name_i18n`
- `price_delta`
- `is_available`
- `sort_order`

### Cart

Represents a customer-editable cart before submission.

Fields:

- `id`
- `store_id`
- `waiting_session_id`
- `status`
- `currency`
- `created_at`
- `updated_at`

Statuses:

- `active`
- `submitted`
- `abandoned`

### CartItem

Represents one configured item in a cart.

Fields:

- `id`
- `cart_id`
- `menu_item_id`
- `quantity`
- `base_price_snapshot`
- `item_name_snapshot_i18n`
- `note`

### CartItemOption

Represents selected options for a cart item.

Fields:

- `id`
- `cart_item_id`
- `option_group_id`
- `option_item_id`
- `option_name_snapshot_i18n`
- `price_delta_snapshot`

### OrderCandidate

Represents the submitted cart for staff review.

Fields:

- `id`
- `store_id`
- `waiting_session_id`
- `cart_id`
- `status`
- `estimated_total`
- `currency`
- `submitted_at`
- `reviewed_by_staff_id`
- `confirmed_at`
- `cancelled_at`

Statuses:

- `draft`
- `submitted`
- `under_review`
- `confirmed`
- `cancelled`

### StaffUser

Represents a store staff account for MVP access.

Fields:

- `id`
- `store_id`
- `display_name`
- `role`
- `is_active`

Roles:

- `staff`
- `manager`

## Minimal Table List

- `stores`
- `store_access_codes`
- `waiting_sessions`
- `table_assignments`
- `menu_categories`
- `menu_items`
- `option_groups`
- `option_items`
- `carts`
- `cart_items`
- `cart_item_options`
- `order_candidates`
- `staff_users`

## Design Notes

- Price and translated names are snapshotted into cart and order candidate records where staff confirmation needs stable review.
- The first MVP can store `*_i18n` fields as JSON objects keyed by language code.
- The first MVP should prefer simple store scoping over complex tenant architecture.
- Manual POS entry is supported by the confirmed order candidate summary.
