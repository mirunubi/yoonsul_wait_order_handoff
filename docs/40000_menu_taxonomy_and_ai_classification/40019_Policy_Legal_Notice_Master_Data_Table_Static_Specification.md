# 40019_Policy_Legal_Notice_Master_Data_Table_Static_Specification

## 1. Purpose

This document defines the static table specification for storing the Catch Menu legal notice master pool in the database.

The previous document `40018 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy` defined how legal notice master data is retrieved, activated, displayed, acknowledged, versioned, and referenced by support/dispute workflows.

This document defines the static data model boundary:

- legal notice master identity
- legal notice versions
- i18n text
- trigger rules
- UI surface mapping
- store-level activation settings
- franchise/HQ locks
- acknowledgement evidence
- recommendation logs
- legal review workflow
- dispute references
- audit linkage

This document is planning-only.

It does not authorize SQL implementation.

---

## 2. Core Position

Legal notice data must be normalized, versioned, scoped, and auditable.

The correct rule is:

One legal notice identity may have many versions.  
One version may have many localized texts.  
One notice may have many trigger rules.  
One store may enable or disable only approved notices within its authority.  
One customer acknowledgement must reference the exact notice version shown.  
One dispute case must reference immutable evidence, not current notice text.  
Current legal wording must not rewrite historical evidence.  
AI recommendation must be logged separately from activation.  
Store toggle is configuration, not legal approval.  

Legal notice master data is compliance infrastructure.

---

## 3. Static Specification Scope

This document covers static table planning for:

- legal notice identity
- notice versioning
- localized notice text
- legal basis reference
- trigger rule mapping
- UI surface mapping
- store activation
- HQ/franchise lock
- customer acknowledgement evidence
- staff confirmation evidence
- AI/system recommendation log
- legal review state
- dispute reference
- audit linkage
- retention class
- deprecation and rollback

This document does not define final SQL.

---

## 4. Recommended Table List

Recommended table family:

| Table | Purpose |
|---|---|
| `legal_notice_master` | Stable legal notice identity |
| `legal_notice_version` | Versioned approved/draft notice text metadata |
| `legal_notice_i18n_text` | Localized text variants |
| `legal_notice_trigger_rule` | Context-based activation rules |
| `legal_notice_surface_map` | UI surfaces and display behavior |
| `store_legal_notice_setting` | Store-level activation and override settings |
| `franchise_legal_notice_policy` | Franchise/HQ notice locks and requirements |
| `legal_notice_ack_evidence` | Customer/staff acknowledgement evidence |
| `legal_notice_recommendation_log` | AI/system notice recommendations |
| `legal_notice_review_case` | Legal/HQ review workflow |
| `legal_notice_dispute_reference` | Support/dispute evidence link |
| `legal_notice_retention_policy` | Retention class definition |
| `legal_notice_audit_link` | Audit reference helper if needed |

Actual table names may be adjusted later.

---

## 5. Table: legal_notice_master

Purpose:

Defines stable identity of each legal notice.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `notice_code` | text | yes | Stable code such as `FOOD_ALLERGEN_001` |
| `notice_family` | text | yes | Food safety, alcohol, privacy, etc. |
| `notice_group` | text | no | Subgroup |
| `notice_title` | text | yes | Admin-facing title |
| `risk_class` | text | yes | Low, medium, high, legal, financial, safety |
| `default_enforcement_class` | text | yes | Mandatory, optional, legal review, etc. |
| `default_trigger_type` | text | yes | Static, popup, checkbox, footer, etc. |
| `default_required_ack` | boolean | yes | Whether acknowledgement is normally required |
| `default_enabled` | boolean | yes | Default toggle value |
| `legal_basis_ref` | text | no | Law/regulation/internal basis reference |
| `owner_domain` | text | yes | Legal, privacy, payment, food safety, etc. |
| `retention_class` | text | yes | Retention policy class |
| `is_platform_mandatory` | boolean | yes | Platform cannot disable |
| `is_store_configurable` | boolean | yes | Store may toggle |
| `is_deprecated` | boolean | yes | Deprecated master notice |
| `created_at` | timestamp | yes | Creation time |
| `created_by` | uuid/text | yes | Actor reference |
| `updated_at` | timestamp | yes | Last metadata update |
| `audit_ref` | text | yes | Audit correlation |

Recommended constraints:

- `notice_code` must be unique.
- Deprecated notice must not be newly activated.
- Platform mandatory notice cannot be store-disabled.

---

## 6. Notice Family Enum Candidates

Candidate `notice_family` values:

| Value | Meaning |
|---|---|
| `FOOD_SAFETY_HYGIENE` | Food safety, hygiene, allergen, raw food |
| `YOUTH_ALCOHOL_PROTECTION` | Youth protection and alcohol |
| `STORE_USE_FACILITY_SAFETY` | Store rules and facility safety |
| `PRIVACY_TERMS_MEMBERSHIP` | Terms, privacy, membership |
| `PAYMENT_CANCEL_REFUND_ECOMMERCE` | Payment, cancel, refund |
| `REVIEW_CONTENT_IP` | Review, content, IP |
| `SYSTEM_POS_KIOSK_HARDWARE` | Hardware, POS, kiosk, system error |
| `FRANCHISE_EVENT_COUPON_ABUSE` | Coupon/event abuse |
| `TAX_SETTLEMENT_RECEIPT` | Tax, settlement, receipt |
| `BLACK_CONSUMER_STAFF_PROTECTION` | Staff protection and malicious consumer |
| `DISASTER_FORCE_MAJEURE_EXCEPTION` | Disaster and exception |
| `LEGAL_NOTICE_META` | Meta notice and precedence |

These values are planning candidates.

Final enum strategy is deferred.

---

## 7. Table: legal_notice_version

Purpose:

Stores version-level metadata for legal notice text.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `notice_id` | uuid | yes | References `legal_notice_master` |
| `version_no` | integer/text | yes | Version number |
| `version_state` | text | yes | Draft, review, approved, deprecated |
| `short_body_key` | text | no | i18n key for short popup |
| `full_body_key` | text | yes | i18n key for full text |
| `receipt_body_key` | text | no | i18n key for receipt |
| `admin_body_key` | text | no | i18n key for admin guidance |
| `effective_from` | timestamp | yes | Start date |
| `effective_to` | timestamp | no | End date |
| `legal_review_state` | text | yes | Review status |
| `legal_reviewed_by` | uuid/text | no | Reviewer |
| `approved_by` | uuid/text | no | Approver |
| `approved_at` | timestamp | no | Approval time |
| `change_reason` | text | yes | Why version changed |
| `supersedes_version_id` | uuid | no | Previous version |
| `rollback_allowed` | boolean | yes | Whether rollback is allowed |
| `created_at` | timestamp | yes | Creation time |
| `created_by` | uuid/text | yes | Actor |
| `audit_ref` | text | yes | Audit correlation |

Recommended constraints:

- Only `APPROVED` versions can be used in production.
- Effective date windows for approved versions should not overlap unless explicitly allowed.
- Customer evidence must reference version ID, not only notice ID.

---

## 8. Version State Candidates

Candidate `version_state` values:

| Value | Meaning |
|---|---|
| `DRAFT` | Being drafted |
| `LEGAL_REVIEW_PENDING` | Waiting for legal review |
| `HQ_REVIEW_PENDING` | Waiting for HQ review |
| `I18N_REVIEW_PENDING` | Waiting for translation review |
| `APPROVED` | Approved for use |
| `ACTIVE` | Currently active |
| `SUPERSEDED` | Replaced by later version |
| `DEPRECATED` | Not usable |
| `ROLLBACK_CANDIDATE` | Can be restored |
| `BLOCKED` | Must not be used |

Runtime finalization is deferred.

---

## 9. Table: legal_notice_i18n_text

Purpose:

Stores localized text variants for each notice version.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `notice_version_id` | uuid | yes | References version |
| `locale` | text | yes | `ko-KR`, `en-US`, etc. |
| `text_variant` | text | yes | Short, full, receipt, admin, accessibility |
| `text_body` | text | yes | Localized notice text |
| `is_controlling_language` | boolean | yes | Whether this is legal controlling text |
| `translation_state` | text | yes | Draft, machine, reviewed, approved |
| `reviewed_by` | uuid/text | no | Reviewer |
| `approved_at` | timestamp | no | Approval time |
| `effective_from` | timestamp | yes | Effective start |
| `effective_to` | timestamp | no | Effective end |
| `created_at` | timestamp | yes | Creation time |
| `audit_ref` | text | yes | Audit correlation |

Recommended constraints:

- Korean reference text should exist for each approved version.
- Legally critical text should not use unreviewed machine translation as final.
- Evidence must record locale and version shown.

---

## 10. Text Variant Candidates

Candidate `text_variant` values:

| Value | Meaning |
|---|---|
| `SHORT_POPUP` | Short popup text |
| `FULL_POLICY` | Full notice text |
| `CHECKBOX_LABEL` | Consent checkbox label |
| `RECEIPT_NOTE` | Receipt text |
| `MENU_MODAL` | Menu detail text |
| `ADMIN_GUIDANCE` | Admin-only explanation |
| `STAFF_GUIDANCE` | Staff-only guidance |
| `ACCESSIBILITY` | Screen reader optimized |
| `SUPPORT_SUMMARY` | Support case summary |

---

## 11. Table: legal_notice_trigger_rule

Purpose:

Defines when a notice should be selected.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `notice_id` | uuid | yes | References master |
| `rule_code` | text | yes | Stable trigger rule code |
| `rule_state` | text | yes | Active, draft, disabled |
| `trigger_family` | text | yes | Menu, ingredient, payment, alcohol, etc. |
| `trigger_condition` | json/text | yes | Structured condition |
| `priority` | integer | yes | Selection priority |
| `enforcement_class` | text | yes | Mandatory, optional, etc. |
| `required_ack_override` | boolean | no | Override default ack |
| `surface_scope` | text/json | no | Allowed surfaces |
| `store_type_scope` | text/json | no | Pub, cafe, raw fish, etc. |
| `menu_category_scope` | text/json | no | Menu category |
| `feature_scope` | text/json | no | Review, coupon, reservation, etc. |
| `payment_scope` | text/json | no | Prepaid, deposit, refund |
| `time_window_scope` | text/json | no | Late-night, lunch, seasonal |
| `effective_from` | timestamp | yes | Start |
| `effective_to` | timestamp | no | End |
| `created_at` | timestamp | yes | Creation time |
| `audit_ref` | text | yes | Audit correlation |

Trigger rules should be deterministic and auditable.

---

## 12. Trigger Family Candidates

Candidate `trigger_family` values:

| Value | Meaning |
|---|---|
| `MENU_INGREDIENT` | Allergen/ingredient |
| `MENU_CATEGORY` | Raw food, alcohol, spicy, etc. |
| `STORE_TYPE` | Pub, cafe, no-kids, pet-friendly |
| `ORDER_STAGE` | Cart, checkout, payment |
| `PAYMENT_MODE` | Prepaid, postpaid, deposit |
| `RESERVATION` | Reservation and no-show |
| `WAITING` | Waiting and call expiry |
| `ALCOHOL_ORDER` | Alcohol order |
| `PRIVACY_FLOW` | Signup and privacy consent |
| `MARKETING_FLOW` | Marketing consent |
| `REVIEW_FLOW` | Review writing |
| `COUPON_EVENT` | Coupon and promotion |
| `HARDWARE_DEVICE` | Tablet/kiosk notice |
| `SYSTEM_INCIDENT` | Outage/fallback |
| `DISASTER_EXCEPTION` | Force majeure |
| `ADMIN_TOGGLE` | Store-enabled notice |

---

## 13. Table: legal_notice_surface_map

Purpose:

Defines where and how notices appear.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `notice_id` | uuid | yes | References master |
| `surface_id` | text | yes | Menu modal, checkout, popup, etc. |
| `display_mode` | text | yes | Inline, modal, checkbox, footer |
| `display_frequency` | text | yes | Every time, once per session, etc. |
| `blocking_behavior` | text | yes | Blocking, non-blocking |
| `ack_required` | boolean | yes | Ack on this surface |
| `text_variant` | text | yes | Which i18n text variant to use |
| `sort_order` | integer | yes | Display order |
| `max_display_length` | integer | no | Optional UI limit |
| `fallback_surface_id` | text | no | Fallback if unsupported |
| `is_active` | boolean | yes | Active surface mapping |
| `created_at` | timestamp | yes | Creation time |
| `audit_ref` | text | yes | Audit correlation |

Surface mapping keeps UI clean.

---

## 14. Surface ID Candidates

Candidate `surface_id` values:

| Value | Meaning |
|---|---|
| `MENU_DETAIL_MODAL` | Menu detail |
| `CART_PAGE` | Cart |
| `CHECKOUT_PAGE` | Checkout |
| `PAYMENT_CONFIRM_MODAL` | Payment confirmation |
| `ALCOHOL_AGE_POPUP` | Alcohol popup |
| `RESERVATION_PAGE` | Reservation |
| `WAITING_PAGE` | Waiting |
| `PICKUP_PAGE` | Pickup |
| `DELIVERY_PAGE` | Delivery |
| `REVIEW_PAGE` | Review |
| `COUPON_PAGE` | Coupon/event |
| `LEGAL_NOTICE_CENTER` | Notice center |
| `FOOTER_POLICY_LINK` | Footer |
| `RECEIPT` | Receipt |
| `TABLE_IDLE_SCREEN` | Table tablet idle |
| `KIOSK_SCREEN` | Kiosk |
| `ADMIN_SETTING_PAGE` | Admin setting |
| `STAFF_CONFIRM_SCREEN` | Staff screen |
| `SUPPORT_CASE_SCREEN` | Support case |

---

## 15. Table: store_legal_notice_setting

Purpose:

Stores store-level activation settings.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `tenant_id` | uuid | yes | Tenant scope |
| `store_id` | uuid | yes | Store scope |
| `notice_id` | uuid | yes | Notice |
| `notice_version_id` | uuid | no | Specific version if pinned |
| `enabled` | boolean | yes | ON/OFF |
| `setting_state` | text | yes | Active, pending, disabled, locked |
| `source` | text | yes | Manual, AI recommendation, HQ mandate |
| `lock_state` | text | yes | Editable, HQ locked, platform locked |
| `enabled_by` | uuid/text | no | Actor |
| `enabled_at` | timestamp | no | Time |
| `disabled_by` | uuid/text | no | Actor |
| `disabled_at` | timestamp | no | Time |
| `effective_from` | timestamp | yes | Start |
| `effective_to` | timestamp | no | End |
| `reason` | text | no | Reason |
| `audit_ref` | text | yes | Audit correlation |

Recommended constraints:

- Store setting must include tenant and store.
- Mandatory locked notices cannot be disabled by store.
- Store setting cannot point to unapproved version.

---

## 16. Table: franchise_legal_notice_policy

Purpose:

Stores franchise/HQ notice requirements and locks.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `tenant_id` | uuid | yes | Tenant |
| `brand_id` | uuid/text | no | Franchise brand |
| `operating_group_id` | uuid/text | no | Operating group |
| `notice_id` | uuid | yes | Notice |
| `required_state` | text | yes | Required, recommended, prohibited |
| `lock_state` | text | yes | Locked on, locked text, review required |
| `applies_to_store_type` | text/json | no | Store type |
| `applies_to_menu_category` | text/json | no | Menu category |
| `effective_from` | timestamp | yes | Start |
| `effective_to` | timestamp | no | End |
| `approved_by` | uuid/text | yes | HQ approver |
| `created_at` | timestamp | yes | Creation time |
| `audit_ref` | text | yes | Audit correlation |

Franchise policy must not cross tenant boundary.

---

## 17. Table: legal_notice_ack_evidence

Purpose:

Stores evidence that a notice was shown and acknowledged.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `tenant_id` | uuid | yes | Tenant |
| `store_id` | uuid | no | Store if applicable |
| `notice_id` | uuid | yes | Notice |
| `notice_version_id` | uuid | yes | Exact version |
| `surface_id` | text | yes | Where shown |
| `trigger_rule_id` | uuid | no | Rule that triggered it |
| `customer_id` | uuid/text | no | Member if known |
| `session_id` | text | yes | Session |
| `order_id` | uuid/text | no | Order |
| `payment_id` | uuid/text | no | Payment |
| `reservation_id` | uuid/text | no | Reservation |
| `waiting_id` | uuid/text | no | Waiting |
| `device_id` | uuid/text | no | Device |
| `table_id` | uuid/text | no | Table |
| `locale` | text | yes | Locale shown |
| `shown_at` | timestamp | yes | Show time |
| `ack_required` | boolean | yes | Whether ack required |
| `acknowledged_at` | timestamp | no | Ack time |
| `ack_method` | text | no | Click, checkbox, staff confirm |
| `actor_type` | text | yes | Customer, staff, system |
| `staff_actor_id` | uuid/text | no | Staff if staff confirm |
| `evidence_hash` | text | no | Optional integrity hash |
| `retention_class` | text | yes | Retention class |
| `created_at` | timestamp | yes | Creation |
| `audit_ref` | text | yes | Audit correlation |

Recommended constraints:

- Acknowledgement evidence must reference version ID.
- Evidence must not be updated to change historical truth.
- Missing acknowledgement for required notice should create compliance incident.

---

## 18. Ack Method Candidates

Candidate `ack_method` values:

| Value | Meaning |
|---|---|
| `DISPLAY_ONLY` | Shown only |
| `SIMPLE_CONFIRM` | Confirm button |
| `CHECKBOX` | Checkbox |
| `MULTI_CHECKBOX` | Multiple checkboxes |
| `ADULT_CONFIRM` | Adult confirmation |
| `STAFF_ID_CONFIRM` | Staff ID confirmation |
| `PAYMENT_CONTINUE_CONFIRM` | Payment continuation |
| `SIGNATURE` | Signature |
| `SYSTEM_AUTO_SHOWN` | System shown without customer ack |

---

## 19. Table: legal_notice_recommendation_log

Purpose:

Stores AI/system recommendation events.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `tenant_id` | uuid | yes | Tenant |
| `store_id` | uuid | yes | Store |
| `notice_id` | uuid | yes | Recommended notice |
| `recommendation_source` | text | yes | AI, rule engine, HQ, support |
| `source_object_type` | text | yes | Menu, category, order, store profile |
| `source_object_id` | text/uuid | no | Source object |
| `reason_code` | text | yes | Why recommended |
| `confidence` | numeric/text | no | AI confidence if any |
| `recommendation_state` | text | yes | Recommended, accepted, rejected |
| `handled_by` | uuid/text | no | Actor |
| `handled_at` | timestamp | no | Time |
| `dismiss_reason` | text | no | If rejected |
| `created_at` | timestamp | yes | Creation |
| `audit_ref` | text | yes | Audit correlation |

AI recommendation must not equal activation.

---

## 20. Recommendation Reason Code Candidates

Candidate reason codes:

| Code | Meaning |
|---|---|
| `ALLERGEN_DETECTED` | Allergen candidate detected |
| `RAW_FOOD_DETECTED` | Raw food detected |
| `ALCOHOL_DETECTED` | Alcohol detected |
| `SPICY_LEVEL_DETECTED` | Spicy item detected |
| `CAFFEINE_DETECTED` | High caffeine candidate |
| `MARKET_PRICE_DETECTED` | Market price text detected |
| `NO_SHOW_POLICY_DETECTED` | Reservation/no-show context |
| `REFUND_RISK_DETECTED` | Refund/cancel risk |
| `COUPON_EVENT_DETECTED` | Coupon/event context |
| `REVIEW_EVENT_DETECTED` | Review event |
| `DEVICE_SURFACE_ACTIVE` | Table/kiosk hardware |
| `DELIVERY_TAKEOUT_DETECTED` | Delivery/takeout context |
| `LEGAL_REQUIRED_BY_STORE_TYPE` | Store type requires notice |
| `HQ_POLICY_RECOMMENDATION` | HQ recommended |

---

## 21. Table: legal_notice_review_case

Purpose:

Tracks legal/HQ/i18n review of notices.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `notice_id` | uuid | yes | Notice |
| `notice_version_id` | uuid | no | Version under review |
| `review_type` | text | yes | Legal, HQ, i18n, privacy, finance |
| `review_state` | text | yes | Open, approved, rejected, changes requested |
| `requested_by` | uuid/text | yes | Actor |
| `requested_at` | timestamp | yes | Time |
| `reviewed_by` | uuid/text | no | Reviewer |
| `reviewed_at` | timestamp | no | Time |
| `review_notes` | text | no | Notes |
| `risk_class` | text | yes | Risk |
| `approval_ref` | text | no | Approval document/reference |
| `created_at` | timestamp | yes | Creation |
| `audit_ref` | text | yes | Audit correlation |

Review cases must preserve history.

---

## 22. Table: legal_notice_dispute_reference

Purpose:

Links notice evidence to customer support or dispute cases.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `tenant_id` | uuid | yes | Tenant |
| `store_id` | uuid | no | Store |
| `case_id` | uuid/text | yes | Support/dispute case |
| `notice_ack_evidence_id` | uuid | yes | Evidence reference |
| `notice_id` | uuid | yes | Notice |
| `notice_version_id` | uuid | yes | Version |
| `linked_reason` | text | yes | Refund, allergy, alcohol, etc. |
| `linked_by` | uuid/text | yes | Actor/system |
| `linked_at` | timestamp | yes | Time |
| `visibility_scope` | text | yes | Support, HQ, legal |
| `audit_ref` | text | yes | Audit correlation |

Support can reference but not mutate evidence.

---

## 23. Table: legal_notice_retention_policy

Purpose:

Defines retention class metadata.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `retention_class` | text | yes | Retention class |
| `description` | text | yes | Meaning |
| `default_retention_period` | interval/text | yes | Planned retention |
| `legal_hold_allowed` | boolean | yes | Can be held |
| `delete_behavior` | text | yes | Delete, anonymize, archive |
| `applies_to_family` | text/json | no | Families |
| `review_state` | text | yes | Review state |
| `created_at` | timestamp | yes | Creation |
| `audit_ref` | text | yes | Audit correlation |

Retention must be legally reviewed before implementation.

---

## 24. Retention Class Candidates

Candidate retention classes:

| Value | Meaning |
|---|---|
| `SHORT_SESSION` | Low-risk temporary notice |
| `ORDER_LIFECYCLE` | Order-related notice |
| `PAYMENT_RETENTION` | Payment/refund evidence |
| `PRIVACY_RETENTION` | Privacy consent evidence |
| `ALCOHOL_RETENTION` | Alcohol age/ID evidence |
| `DISPUTE_RETENTION` | Dispute evidence |
| `LEGAL_HOLD` | Litigation/investigation hold |
| `ADMIN_CONFIG_HISTORY` | Store/admin configuration history |

---

## 25. Table: legal_notice_audit_link

Purpose:

Optional helper table to link notice objects to central audit events.

Recommended columns:

| Column | Type Concept | Required | Notes |
|---|---|---:|---|
| `id` | uuid | yes | Primary key |
| `object_type` | text | yes | Notice, version, setting, evidence |
| `object_id` | uuid/text | yes | Object |
| `audit_event_id` | uuid/text | yes | Audit event |
| `event_type` | text | yes | Audit event type |
| `created_at` | timestamp | yes | Creation |

This table is optional if the central audit system already supports object references.

---

## 26. Tenant Scope Requirements

Every operational table must carry tenant/store scope where applicable.

Mandatory scope:

| Table | Scope Requirement |
|---|---|
| `legal_notice_master` | Platform/global; may not need store |
| `legal_notice_version` | Platform/global; may support tenant override later |
| `legal_notice_i18n_text` | Version scope |
| `legal_notice_trigger_rule` | Platform/tenant/store scope depending rule |
| `legal_notice_surface_map` | Platform/tenant scope |
| `store_legal_notice_setting` | Tenant and store required |
| `franchise_legal_notice_policy` | Tenant required, brand/group optional |
| `legal_notice_ack_evidence` | Tenant required, store when applicable |
| `legal_notice_recommendation_log` | Tenant and store required |
| `legal_notice_review_case` | Scope depends on case |
| `legal_notice_dispute_reference` | Tenant required |

Cross-tenant leakage is prohibited.

---

## 27. Authority Requirements

Authority must be separated by action.

| Action | Required Authority |
|---|---|
| Create master notice | Platform legal/admin |
| Create version | Legal/HQ/admin draft authority |
| Approve version | Legal/HQ approver |
| Translate notice | i18n reviewer |
| Activate store notice | Store owner/manager if allowed |
| Disable store notice | Store owner/manager if allowed |
| Lock notice for franchise | Franchise HQ authority |
| View acknowledgement evidence | Case-scoped support/HQ/legal |
| Export evidence | Legal/compliance authority |
| Delete/deprecate notice | Platform legal/admin |
| Change retention | Legal/privacy authority |

AI has no authority.

---

## 28. Review State Requirements

Notice objects must use review states.

Candidate states:

| State | Meaning |
|---|---|
| `DRAFT` | Draft |
| `REVIEW_PENDING` | Under review |
| `LEGAL_REVIEW_PENDING` | Legal review pending |
| `I18N_REVIEW_PENDING` | Translation review pending |
| `APPROVED` | Approved |
| `ACTIVE` | Active |
| `REJECTED` | Rejected |
| `CHANGES_REQUESTED` | Needs edits |
| `DEPRECATED` | Not usable |
| `BLOCKED` | Blocked |
| `ARCHIVED` | Historical only |

Only approved/active objects may be used in customer-facing flows.

---

## 29. Data Integrity Requirements

Data integrity rules:

1. Evidence must reference exact notice version.
2. Store setting must reference approved notice.
3. Trigger rule must reference existing notice.
4. Surface map must reference existing notice.
5. i18n text must reference existing version.
6. Legal review case must not overwrite version history.
7. Dispute reference must not mutate evidence.
8. Deprecated notice must not be newly activated.
9. Required notice must not be disabled by store.
10. Tenant/store scope must be present for store-specific settings.
11. Locale fallback must be explicit.
12. Historical notice evidence must remain readable.

---

## 30. Static Seed Strategy

The 200 legal notice pool should be seeded as static master data.

Seed strategy:

| Step | Action |
|---|---|
| 1 | Create notice family taxonomy |
| 2 | Create `legal_notice_master` rows |
| 3 | Create initial `legal_notice_version` rows |
| 4 | Create Korean reference i18n text |
| 5 | Create default surface mappings |
| 6 | Create default trigger rules |
| 7 | Create default retention classes |
| 8 | Mark legal review state |
| 9 | Mark mandatory/optional defaults |
| 10 | Lock high-risk notices pending approval |

Initial seed does not mean production approval.

---

## 31. Initial Notice Code Pattern

Recommended code pattern:

    <FAMILY_SHORT>_<GROUP>_<SEQUENCE>

Examples:

| Code | Meaning |
|---|---|
| `FOOD_ALLERGEN_001` | Allergen notice |
| `FOOD_RAW_006` | Raw food freshness |
| `ALCOHOL_ID_011` | ID required |
| `STORE_CCTV_021` | CCTV notice |
| `PRIVACY_REQUIRED_027` | Privacy collection consent |
| `PAYMENT_CANCEL_036` | Immediate cooking no cancel |
| `REVIEW_ABUSE_046` | Malicious review |
| `DEVICE_DAMAGE_142` | Tablet damage |
| `COUPON_SCREENSHOT_152` | Coupon screenshot invalid |
| `TAX_RECEIPT_162` | Tax invoice duplicate |
| `STAFF_PROTECT_171` | Staff abuse recording |
| `DISASTER_SERVER_189` | Platform server overload |

Notice code must remain stable.

---

## 32. Static Seed Review Boundary

Before seed data can be used in production:

- legal wording must be reviewed
- privacy wording must be reviewed
- alcohol notices must be reviewed
- refund/cancel notices must match POS/payment behavior
- i18n translations must be reviewed
- store-toggle defaults must be reviewed
- mandatory locks must be reviewed
- retention classes must be reviewed
- support evidence access must be reviewed
- tenant isolation must be reviewed

Seeded does not equal approved.

---

## 33. Query Usage Boundary

Future runtime queries should retrieve notices by:

- tenant
- store
- surface
- locale
- menu item
- menu category
- ingredient/allergen tag
- order stage
- payment mode
- alcohol flag
- reservation/no-show flag
- feature flag
- device context
- policy version
- effective date

Query must not fetch unrelated tenant/store notices.

---

## 34. Customer Evidence Snapshot Boundary

When a notice is shown, evidence must snapshot enough data to reconstruct the event.

Evidence should preserve:

- notice ID
- notice version ID
- locale
- text hash
- surface
- trigger rule
- order/session
- shown timestamp
- acknowledgement timestamp
- actor/session
- store/tenant
- policy version

Do not rely on current notice text to explain past customer acknowledgement.

---

## 35. Support Retrieval Boundary

Support case view should retrieve:

- acknowledgement evidence
- notice version text
- trigger reason
- store setting at time
- order/payment state
- customer/session reference
- related audit events
- missing notice warnings
- dispute category

Support can view.

Support cannot rewrite.

---

## 36. Export Boundary

Legal notice data export is sensitive.

Export should be limited by:

- purpose
- authority
- tenant/store scope
- date range
- case scope
- privacy masking
- audit event
- retention policy

Bulk export of acknowledgement evidence requires stronger authority.

---

## 37. Anti-Patterns

Avoid:

- storing legal notice only as plain text with no version
- hardcoding notices into frontend
- storing acknowledgement without version ID
- storing store toggle without tenant/store scope
- allowing store owner to edit master notice text directly
- using deprecated notices in new flows
- deleting old notice versions
- using current text to explain old acknowledgement
- treating AI recommendation as activation
- treating seed data as legal approval
- failing to map notices to surfaces
- failing to map notices to trigger rules
- allowing cross-tenant notice settings
- exporting evidence without audit
- storing unreviewed machine translation as approved legal text

These anti-patterns must be blocked in future runtime design.

---

## 38. Runtime Deferral

This document defines static table specification planning only.

It does not authorize:

- SQL migration
- seed file creation
- database table creation
- RLS policy creation
- trigger implementation
- RPC implementation
- admin UI implementation
- legal notice retrieval runtime
- customer acknowledgement runtime
- evidence storage runtime
- export runtime
- production deployment

All runtime remains deferred.

---

## 39. Validation Checklist

Validation must confirm:

1. Recommended table list is defined.
2. `legal_notice_master` purpose and columns are defined.
3. Notice family candidates are defined.
4. `legal_notice_version` purpose and columns are defined.
5. Version state candidates are defined.
6. `legal_notice_i18n_text` purpose and columns are defined.
7. Text variant candidates are defined.
8. `legal_notice_trigger_rule` purpose and columns are defined.
9. Trigger family candidates are defined.
10. `legal_notice_surface_map` purpose and columns are defined.
11. Surface ID candidates are defined.
12. `store_legal_notice_setting` purpose and columns are defined.
13. `franchise_legal_notice_policy` purpose and columns are defined.
14. `legal_notice_ack_evidence` purpose and columns are defined.
15. Ack method candidates are defined.
16. `legal_notice_recommendation_log` purpose and columns are defined.
17. Recommendation reason code candidates are defined.
18. `legal_notice_review_case` purpose and columns are defined.
19. `legal_notice_dispute_reference` purpose and columns are defined.
20. `legal_notice_retention_policy` purpose and columns are defined.
21. Retention class candidates are defined.
22. Optional audit link table is defined.
23. Tenant scope requirements are defined.
24. Authority requirements are defined.
25. Review state requirements are defined.
26. Data integrity requirements are defined.
27. Static seed strategy is defined.
28. Initial notice code pattern is defined.
29. Static seed review boundary is defined.
30. Query usage boundary is defined.
31. Customer evidence snapshot boundary is defined.
32. Support retrieval boundary is defined.
33. Export boundary is defined.
34. Anti-patterns are listed.
35. Coding remains unauthorized.
36. Runtime remains deferred.

---

## 40. Relationship To Previous Documents

This document supplements:

- `40017 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `40018 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`

It also references:

- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `40003 AI Menu Intake Parsing Interactive Editor Fast Track Attribute And Live Deployment Boundary Policy`
- `40004 AI Menu Category Context Two-Level Taxonomy And Classification Policy`
- `40016 AI Menu Review Option Builder Set Combo Course And Special Sales Pattern Governance Policy`

It prepares possible future documents:

- `40020 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `40021 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 41. Final Rule

Catch Menu legal notices must be stored as normalized, versioned, localized, scoped, and auditable master data.

The database model must separate:

1. notice identity
2. notice version
3. localized text
4. trigger rules
5. surface mapping
6. store activation settings
7. franchise/HQ locks
8. acknowledgement evidence
9. AI/system recommendations
10. review workflow
11. dispute references
12. retention policy

Historical acknowledgement must always reference the exact notice version shown.

Store settings must never mutate master text.

AI recommendations must never become legal activation without confirmation and required review.

Static seed data remains planning data until legal review, policy review, tenant-scope review, and explicit implementation authorization are completed.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.