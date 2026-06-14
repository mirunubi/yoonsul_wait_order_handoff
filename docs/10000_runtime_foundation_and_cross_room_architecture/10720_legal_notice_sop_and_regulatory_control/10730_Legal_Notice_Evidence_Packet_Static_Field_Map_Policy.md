# 10730_Legal_Notice_Evidence_Packet_Static_Field_Map_Policy

## 1. Purpose

This document defines the static field map for Legal Notice Evidence Packets in Catch Menu.

The previous document `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy` closed the Legal Notice Static Registry planning sequence and confirmed runtime deferral.

This document continues as a supplemental static planning document focused on field-level evidence packet structure.

It defines what data should be captured when legal notices are shown, acknowledged, disputed, exported, or referenced by support.

This document is planning-only.

It does not authorize coding.

---

## 2. Core Position

Evidence packets must be structured before runtime is built.

The correct rule is:

Evidence must be field-based, not memo-based.  
Evidence must reference exact notice version.  
Evidence must record the surface where the notice was shown.  
Evidence must record locale and text hash.  
Evidence must record acknowledgement when required.  
Evidence must link to order, payment, KDS, POS, reservation, waiting, customer, session, device, and support case where applicable.  
Evidence must preserve historical truth.  
Evidence must be tenant-scoped.  
Evidence must be exportable with masking.  
Evidence must not be editable by support or store users.  

A legal notice without evidence is weak.

Evidence without field discipline is also weak.

---

## 3. Scope

This policy applies to static field planning for:

- legal notice shown evidence
- legal notice acknowledgement evidence
- privacy consent evidence
- alcohol age-gate evidence
- staff ID verification evidence
- refund/cancellation evidence
- no-show/deposit evidence
- food safety/allergen evidence
- market-price confirmation evidence
- coupon/event notice evidence
- review/content notice evidence
- hardware/device notice evidence
- disaster/force majeure notice evidence
- support dispute packets
- evidence export
- masking
- legal hold
- audit linkage

This document does not define SQL.

---

## 4. Evidence Packet Types

Recommended evidence packet types:

| Packet Type | Meaning |
|---|---|
| `LEGAL_NOTICE_SHOWN_PACKET` | Notice was displayed |
| `LEGAL_NOTICE_ACK_PACKET` | Notice was acknowledged |
| `PRIVACY_CONSENT_PACKET` | Privacy/terms/marketing consent |
| `ALCOHOL_CONFIRM_PACKET` | Adult confirmation |
| `ALCOHOL_STAFF_VERIFY_PACKET` | Staff ID verification |
| `REFUND_NOTICE_PACKET` | Refund/cancellation notice |
| `NO_SHOW_NOTICE_PACKET` | Waiting/reservation/pickup no-show |
| `FOOD_SAFETY_NOTICE_PACKET` | Allergen/raw food/storage |
| `MARKET_PRICE_CONFIRM_PACKET` | Market price confirmation |
| `COUPON_EVENT_NOTICE_PACKET` | Coupon/event terms |
| `REVIEW_NOTICE_PACKET` | Review/IP/content notice |
| `DEVICE_NOTICE_PACKET` | Tablet/kiosk/device handling |
| `DISASTER_NOTICE_PACKET` | Outage/force majeure |
| `SUPPORT_DISPUTE_PACKET` | Support case evidence bundle |
| `EXPORT_PACKET` | Exported evidence package |

Packet type determines required fields.

---

## 5. Universal Evidence Header

Every evidence packet should include:

| Field | Required | Meaning |
|---|---:|---|
| `packet_id` | yes | Unique packet identity |
| `packet_type` | yes | Evidence packet type |
| `tenant_id` | yes | Tenant scope |
| `store_id` | conditional | Store scope when store-related |
| `brand_id` | optional | Franchise brand if applicable |
| `operating_group_id` | optional | Operating group if applicable |
| `created_at` | yes | Packet creation time |
| `created_by_actor_type` | yes | System, customer, staff, support, admin |
| `created_by_actor_id` | conditional | Actor ID if known |
| `source_event_id` | conditional | Source event that generated packet |
| `audit_ref` | yes | Audit correlation reference |
| `schema_version` | yes | Evidence packet schema version |
| `policy_version` | conditional | Policy version at time |
| `retention_class` | yes | Retention class |
| `legal_hold_state` | yes | Legal hold status |
| `integrity_hash` | optional | Packet hash |

Universal header must not be omitted.

---

## 6. Notice Identity Section

Every notice-related packet should include:

| Field | Required | Meaning |
|---|---:|---|
| `notice_id` | yes | Legal notice master ID |
| `notice_code` | yes | Stable notice code |
| `notice_family` | yes | Notice family |
| `notice_version_id` | yes | Exact version shown |
| `notice_version_no` | yes | Version number |
| `notice_risk_class` | yes | Risk class at time |
| `notice_enforcement_class` | yes | Mandatory, optional, etc. |
| `notice_control_class` | conditional | Platform locked, HQ locked, store optional |
| `notice_effective_from` | conditional | Effective start of version |
| `notice_effective_to` | optional | Effective end of version |
| `superseded_notice_version_id` | optional | Previous version if relevant |

Evidence must not rely only on notice code.

Version ID is mandatory for historical proof.

---

## 7. Text Snapshot Section

Text snapshot section should include:

| Field | Required | Meaning |
|---|---:|---|
| `locale` | yes | Locale shown |
| `text_variant` | yes | Popup, checkbox, full policy, receipt |
| `text_hash` | yes for critical | Hash of rendered text |
| `rendered_text_snapshot_ref` | conditional | Reference to rendered text snapshot |
| `controlling_language` | conditional | Korean or other controlling language |
| `controlling_text_version_id` | conditional | Controlling version reference |
| `fallback_used` | yes | Whether fallback was used |
| `fallback_reason` | conditional | Missing translation, blocked translation, etc. |
| `translation_state_at_time` | conditional | Approved, fallback, suspended |
| `machine_translation_flag` | conditional | Whether machine draft was involved |
| `variable_values_snapshot` | conditional | Rendered variables |

For high-risk legal notices, text hash should be captured.

---

## 8. Surface And Trigger Section

Surface/trigger section should include:

| Field | Required | Meaning |
|---|---:|---|
| `surface_id` | yes | Where notice was shown |
| `surface_category` | conditional | Menu, checkout, alcohol, privacy, etc. |
| `display_mode` | yes | Inline, modal, checkbox, blocking |
| `display_level` | conditional | UX display level |
| `display_frequency_rule` | conditional | Once per order/session/etc. |
| `trigger_rule_id` | conditional | Trigger rule that selected notice |
| `trigger_category` | conditional | Menu, payment, alcohol, privacy, etc. |
| `trigger_reason_code` | conditional | Reason code |
| `trigger_source_object_type` | conditional | Menu item, order, payment, reservation |
| `trigger_source_object_id` | conditional | Source object ID |
| `trigger_priority` | conditional | Priority used |
| `dedupe_group_id` | optional | Deduplication group |
| `conflict_resolution_code` | optional | Conflict resolution result |

A notice shown without trigger context is weaker evidence.

---

## 9. Customer And Session Section

Customer/session section should include:

| Field | Required | Meaning |
|---|---:|---|
| `customer_id` | optional | Customer account if known |
| `anonymous_customer_ref` | optional | Anonymous customer reference |
| `session_id` | yes | Session identifier |
| `device_id` | conditional | Table tablet/kiosk/mobile device |
| `table_id` | conditional | Table |
| `seat_id` | optional | Seat if split table |
| `user_agent_hash` | optional | Browser/device hash |
| `ip_hash` | optional | Privacy-safe network evidence |
| `customer_locale_source` | optional | Selected/device/default |
| `member_state` | optional | Member/non-member |
| `customer_visible_name_hash` | optional | Masked identity reference |

Avoid storing unnecessary raw personal data.

---

## 10. Order Link Section

Order link section should include:

| Field | Required | Meaning |
|---|---:|---|
| `order_id` | conditional | Order reference |
| `cart_id` | conditional | Cart reference |
| `order_channel` | conditional | Table, kiosk, app, web |
| `order_stage_at_notice` | conditional | Menu, cart, checkout, payment, post-order |
| `order_state_at_notice` | conditional | Draft, submitted, accepted, etc. |
| `business_date` | conditional | Store business date |
| `order_created_at` | conditional | Order creation time |
| `order_submitted_at` | conditional | Submission time |
| `order_accepted_at` | optional | Acceptance time |
| `order_total_snapshot` | conditional | Amount at time |
| `currency` | conditional | Currency |
| `menu_item_snapshot_ref` | optional | Menu snapshot reference |
| `option_snapshot_ref` | optional | Option snapshot reference |

Order state must be captured at notice time.

---

## 11. Payment Link Section

Payment link section should include:

| Field | Required | Meaning |
|---|---:|---|
| `payment_id` | conditional | Payment reference |
| `payment_intent_id` | conditional | Payment intent |
| `payment_provider` | conditional | PG/VAN/provider |
| `payment_stage_at_notice` | conditional | Before payment, authorized, captured |
| `payment_state_at_notice` | conditional | Payment state |
| `authorization_id` | optional | Authorization reference |
| `capture_id` | optional | Capture reference |
| `refund_id` | optional | Refund reference |
| `amount_authorized` | optional | Authorized amount |
| `amount_captured` | optional | Captured amount |
| `amount_refunded` | optional | Refunded amount |
| `settlement_ref` | optional | Settlement reference |
| `reconciliation_state` | optional | Reconciliation state |

Payment evidence must be provider-backed where possible.

---

## 12. POS And KDS Link Section

POS/KDS link section should include:

| Field | Required | Meaning |
|---|---:|---|
| `pos_handoff_id` | optional | POS handoff |
| `pos_state_at_notice` | optional | POS state |
| `pos_accepted_at` | optional | POS accepted time |
| `kds_ticket_id` | optional | KDS ticket |
| `kds_state_at_notice` | optional | KDS state |
| `kds_sent_at` | optional | KDS sent time |
| `kds_accepted_at` | optional | Kitchen accepted time |
| `prep_started_at` | optional | Prep start |
| `completed_at` | optional | Completion |
| `manual_fallback_ref` | optional | Fallback evidence |
| `printer_log_ref` | optional | Printer evidence |

Refund/cancel evidence needs KDS/POS linkage where applicable.

---

## 13. Acknowledgement Section

Acknowledgement section should include:

| Field | Required | Meaning |
|---|---:|---|
| `ack_required` | yes | Whether acknowledgement required |
| `ack_state` | yes | Not required, shown, accepted, refused, missing |
| `ack_method` | conditional | Checkbox, button, staff confirm, etc. |
| `acknowledged_at` | conditional | Ack time |
| `ack_actor_type` | conditional | Customer, staff, system |
| `ack_actor_id` | optional | Actor ID if known |
| `ack_button_label_key` | optional | Button label key |
| `ack_checkbox_label_key` | optional | Checkbox label key |
| `ack_failure_reason` | optional | Customer refused, timeout, missing log |
| `ack_reprompt_count` | optional | Number of prompts |
| `ack_surface_id` | conditional | Surface where ack occurred |

Acknowledgement without visible text snapshot is weak.

---

## 14. Privacy Consent Section

Privacy consent section should include:

| Field | Required | Meaning |
|---|---:|---|
| `consent_type` | yes | Terms, privacy, marketing, location |
| `consent_required_flag` | yes | Required/optional |
| `consent_purpose` | yes | Purpose |
| `data_items` | conditional | Data items |
| `third_party_recipient` | conditional | Recipient |
| `retention_period_text` | conditional | Retention summary |
| `channel_scope` | conditional | SMS, push, email |
| `accepted` | yes | Accepted/refused |
| `withdrawn_at` | optional | Withdrawal time |
| `withdrawal_method` | optional | How withdrawn |
| `reconsent_required` | optional | Whether reconsent required |
| `legacy_migration_ref` | optional | Legacy consent reference |

Optional consent must remain distinguishable from required consent.

---

## 15. Alcohol Verification Section

Alcohol verification section should include:

| Field | Required | Meaning |
|---|---:|---|
| `alcohol_order_flag` | yes | Alcohol involved |
| `alcohol_item_ids` | conditional | Alcohol items |
| `adult_confirmed` | conditional | Customer adult declaration |
| `adult_confirmed_at` | conditional | Time |
| `staff_id_check_required` | conditional | Staff check required |
| `staff_id_check_state` | conditional | Pending, passed, failed, refused |
| `staff_actor_id` | conditional | Staff checker |
| `id_type_checked` | optional | ID category, not raw ID number |
| `id_result_reason` | conditional | Pass/fail reason |
| `proxy_purchase_risk_flag` | optional | Proxy risk |
| `alcohol_delivery_blocked` | optional | Delivery block |
| `alcohol_action_taken` | conditional | Proceed, block, remove, refund |

Do not store raw ID data by default.

---

## 16. Refund Cancellation Section

Refund/cancel section should include:

| Field | Required | Meaning |
|---|---:|---|
| `refund_notice_type` | conditional | Cancel/refund/no-show/deposit |
| `cancel_available_state` | conditional | Available, locked, review |
| `cancel_request_at` | optional | Customer request time |
| `cancel_lock_reason` | optional | KDS accepted, prep started, etc. |
| `refund_reason_code` | optional | Reason code |
| `refund_decision_state` | optional | Approved/rejected/partial |
| `refund_decision_actor` | optional | Staff/support/HQ |
| `refund_decision_at` | optional | Decision time |
| `refund_provider_state` | optional | Provider state |
| `partial_refund_amount` | optional | Partial amount |
| `customer_notified_at` | optional | Notification time |

Refund evidence must connect to actual payment state.

---

## 17. No-Show Deposit Section

No-show/deposit section should include:

| Field | Required | Meaning |
|---|---:|---|
| `reservation_id` | conditional | Reservation |
| `waiting_id` | conditional | Waiting |
| `pickup_order_id` | conditional | Pickup order |
| `deposit_amount` | conditional | Deposit |
| `deposit_currency` | conditional | Currency |
| `reservation_time` | conditional | Reservation time |
| `call_time` | conditional | Waiting call time |
| `grace_period_minutes` | conditional | Grace |
| `no_show_confirmed_at` | conditional | Confirmation time |
| `penalty_amount` | optional | Penalty |
| `deposit_forfeited` | optional | Forfeiture flag |
| `customer_notification_refs` | optional | Notification evidence |
| `recovery_action` | optional | Recovery or reversal |

No-show evidence must be timestamp-heavy.

---

## 18. Food Safety Section

Food safety section should include:

| Field | Required | Meaning |
|---|---:|---|
| `menu_item_id` | conditional | Menu item |
| `ingredient_tags_snapshot` | conditional | Ingredient tags |
| `allergen_tags_snapshot` | conditional | Allergen tags |
| `raw_food_flag` | optional | Raw food |
| `spicy_level` | optional | Spicy level |
| `bone_shell_warning_flag` | optional | Bone/shell |
| `cross_contact_notice_flag` | optional | Cross-contact |
| `customer_exclusion_request` | optional | Exclusion request |
| `staff_confirmation_ref` | optional | Staff confirmation |
| `freshness_storage_notice` | optional | Takeout storage |
| `incident_report_ref` | optional | Complaint/incident |

Do not infer food safety facts after the event without evidence.

---

## 19. Market Price Section

Market price section should include:

| Field | Required | Meaning |
|---|---:|---|
| `market_price_flag` | yes | Market price involved |
| `price_confirmed` | conditional | Customer accepted confirmed price |
| `confirmed_price_amount` | conditional | Confirmed price |
| `confirmed_price_currency` | conditional | Currency |
| `confirmed_by_actor` | conditional | Staff/system |
| `confirmed_at` | conditional | Time |
| `price_display_snapshot` | conditional | Displayed price text |
| `price_change_reason` | optional | Reason |
| `customer_response` | conditional | Accepted/refused |
| `audit_ref` | yes | Audit |

Market price must not be represented as zero-price.

---

## 20. Coupon Event Section

Coupon/event section should include:

| Field | Required | Meaning |
|---|---:|---|
| `coupon_id` | conditional | Coupon |
| `event_id` | conditional | Event |
| `coupon_policy_version` | conditional | Policy version |
| `stacking_allowed` | conditional | Stacking |
| `expiry_at` | conditional | Expiry |
| `benefit_amount` | optional | Discount/benefit |
| `coupon_used_at` | optional | Use time |
| `coupon_reversal_state` | optional | Reversal |
| `abuse_flag` | optional | Abuse risk |
| `screenshot_invalid_notice` | optional | Notice reference |
| `gift_exchange_rule` | optional | Gift rule |

Coupon notice must match coupon engine behavior.

---

## 21. Review Content Section

Review/content section should include:

| Field | Required | Meaning |
|---|---:|---|
| `review_id` | conditional | Review |
| `review_notice_version_id` | conditional | Notice version |
| `photo_upload_flag` | optional | Photo uploaded |
| `copyright_notice_shown` | optional | Copyright notice |
| `portrait_notice_shown` | optional | Portrait notice |
| `profanity_warning_shown` | optional | Profanity warning |
| `review_event_id` | optional | Review event |
| `moderation_state` | optional | Moderation status |
| `rights_report_ref` | optional | Rights report |
| `delete_notice_ack` | optional | Delete/non-restoration ack |

Review evidence must not suppress legitimate criticism.

---

## 22. Device Hardware Section

Device/hardware section should include:

| Field | Required | Meaning |
|---|---:|---|
| `device_id` | conditional | Device |
| `device_type` | conditional | Tablet, kiosk, printer |
| `table_id` | optional | Table |
| `device_notice_version_id` | conditional | Notice |
| `device_state_before` | optional | Before state |
| `device_state_after` | optional | After state |
| `incident_time` | optional | Incident |
| `staff_report_ref` | optional | Report |
| `photo_evidence_ref` | optional | Photo if allowed |
| `repair_estimate_amount` | optional | Repair estimate |
| `customer_session_ref` | optional | Session |
| `decision_ref` | optional | Support/manager decision |

Device evidence must remain fair and scoped.

---

## 23. Disaster Exception Section

Disaster/exception section should include:

| Field | Required | Meaning |
|---|---:|---|
| `incident_id` | conditional | Incident |
| `incident_type` | conditional | Power, water, server, weather, fire |
| `force_majeure_notice_id` | conditional | Notice |
| `incident_started_at` | conditional | Start |
| `incident_detected_at` | conditional | Detection |
| `customer_notified_at` | conditional | Notice time |
| `affected_order_ids` | optional | Orders |
| `action_taken` | conditional | Cancel, delay, refund, evacuate |
| `recovery_state` | optional | Recovery |
| `support_guidance_ref` | optional | Guidance |
| `postmortem_ref` | optional | Postmortem |

Disaster notice must connect to actual incident record.

---

## 24. Store Setting Snapshot Section

Store setting snapshot should include:

| Field | Required | Meaning |
|---|---:|---|
| `store_notice_setting_id` | conditional | Store setting |
| `setting_state_at_time` | conditional | ON/OFF/locked |
| `enabled_by` | optional | Actor |
| `enabled_at` | optional | Time |
| `lock_state_at_time` | conditional | Platform/HQ/store |
| `variable_values_at_time` | optional | Store variables |
| `effective_from` | conditional | Effective start |
| `effective_to` | optional | Effective end |
| `hq_policy_ref` | optional | HQ lock |
| `platform_lock_ref` | optional | Platform lock |

Evidence must know what store policy was active at the time.

---

## 25. Support Case Section

Support case section should include:

| Field | Required | Meaning |
|---|---:|---|
| `case_id` | conditional | Support case |
| `case_type` | conditional | Refund, allergy, alcohol, etc. |
| `case_opened_at` | conditional | Open time |
| `case_opened_by` | conditional | Customer/staff/support |
| `support_actor_id` | optional | Support |
| `case_state` | conditional | Open, escalated, resolved |
| `decision_code` | optional | Decision |
| `decision_reason` | optional | Reason |
| `decision_at` | optional | Decision time |
| `escalation_ref` | optional | HQ/legal escalation |
| `export_packet_ref` | optional | Export packet |

Support case evidence must separate facts from decisions.

---

## 26. Export And Masking Section

Export/masking section should include:

| Field | Required | Meaning |
|---|---:|---|
| `export_state` | yes | Not exported, exported, blocked |
| `export_id` | optional | Export reference |
| `exported_at` | optional | Export time |
| `exported_by` | optional | Actor |
| `export_purpose` | optional | Support, legal, audit, regulator |
| `masking_profile` | conditional | Support, store, legal, etc. |
| `redaction_log_ref` | optional | Redaction details |
| `export_hash` | optional | Export integrity |
| `legal_hold_state` | yes | Hold status |
| `export_audit_ref` | optional | Export audit |

Export must not mutate original evidence.

---

## 27. Integrity And Chain Section

Integrity section may include:

| Field | Required | Meaning |
|---|---:|---|
| `packet_hash` | optional | Packet hash |
| `previous_packet_hash` | optional | Hash chain |
| `event_sequence_no` | optional | Sequence |
| `created_by_system_version` | optional | System version |
| `source_log_ref` | optional | Source log |
| `immutability_class` | conditional | Append-only, WORM candidate |
| `tamper_check_state` | optional | Verified, failed, unknown |
| `reconciliation_state` | optional | Reconciled, mismatch, pending |
| `nightly_batch_ref` | optional | Batch verification |
| `audit_ref` | yes | Audit |

Integrity fields are planning candidates.

---

## 28. Required Field Matrix By Packet Type

Recommended minimum field requirements:

| Packet Type | Must Include |
|---|---|
| `LEGAL_NOTICE_SHOWN_PACKET` | Header, notice, text, surface, customer/session |
| `LEGAL_NOTICE_ACK_PACKET` | Header, notice, text, surface, customer/session, ack |
| `PRIVACY_CONSENT_PACKET` | Header, notice, text, ack, privacy consent |
| `ALCOHOL_CONFIRM_PACKET` | Header, notice, text, ack, alcohol |
| `ALCOHOL_STAFF_VERIFY_PACKET` | Header, alcohol, staff actor, action |
| `REFUND_NOTICE_PACKET` | Header, notice, text, order, payment, refund |
| `NO_SHOW_NOTICE_PACKET` | Header, notice, text, reservation/waiting, no-show |
| `FOOD_SAFETY_NOTICE_PACKET` | Header, notice, text, menu, food safety |
| `MARKET_PRICE_CONFIRM_PACKET` | Header, notice, text, market price, order |
| `COUPON_EVENT_NOTICE_PACKET` | Header, notice, text, coupon/event |
| `REVIEW_NOTICE_PACKET` | Header, notice, text, review/content |
| `DEVICE_NOTICE_PACKET` | Header, notice, device |
| `DISASTER_NOTICE_PACKET` | Header, notice, incident |
| `SUPPORT_DISPUTE_PACKET` | Header, relevant sections, support case |
| `EXPORT_PACKET` | Header, relevant sections, export/masking |

Implementation-specific required fields remain deferred.

---

## 29. Missing Field Handling

If a required field is missing:

| Missing Field | Handling |
|---|---|
| `notice_version_id` | Evidence invalid or weak |
| `locale` | Translation evidence gap |
| `surface_id` | UX evidence gap |
| `shown_at` | Display evidence gap |
| `acknowledged_at` when required | Consent gap |
| `order_id` for order dispute | Order linkage gap |
| `payment_id` for payment dispute | Payment linkage gap |
| `kds_state` for cancel dispute | Operational evidence gap |
| `store_setting_id` | Policy setting gap |
| `tenant_id` | Security breach / invalid evidence |
| `audit_ref` | Audit gap |

Missing critical fields must be surfaced.

---

## 30. Data Minimization Boundary

Evidence packets must avoid unnecessary personal data.

Rules:

- use hashes where raw value is unnecessary
- do not store raw ID images by default
- do not store full resident registration numbers
- do not store excessive location history
- do not store full payment card data
- do not expose raw IP unless legally required
- mask customer information in support/store views
- separate legal full export from normal support view

Evidence must be useful without becoming excessive surveillance.

---

## 31. Tenant Isolation Boundary

Evidence packet tenant isolation rules:

1. `tenant_id` is mandatory.
2. Store evidence must include `store_id`.
3. Cross-tenant packet access is denied by default.
4. Support access must be case-scoped.
5. HQ access must be tenant/franchise-scoped.
6. Store owner access must be store-scoped.
7. Export must preserve scope.
8. Audit must record scope.
9. Missing tenant scope invalidates evidence usage.
10. Aggregated analytics must be masked or anonymized.

Tenant isolation is non-negotiable.

---

## 32. Anti-Patterns

Avoid:

- evidence packets built from free-text notes only
- missing notice version
- missing locale
- missing surface
- missing acknowledgement timestamp for required consent
- using current notice text as past proof
- storing raw ID images unnecessarily
- storing full payment secrets
- support editing evidence fields
- store owner editing packet history
- packet export without masking
- cross-tenant evidence lookup
- hidden missing-field failures
- backfilling false evidence
- treating packet creation as dispute decision
- treating evidence as automatic refund denial

These anti-patterns must be blocked in future runtime design.

---

## 33. Runtime Deferral

This document defines legal notice evidence packet static field map planning only.

It does not authorize:

- database table creation
- evidence packet table implementation
- JSON schema implementation
- SQL migration
- RLS implementation
- RPC implementation
- evidence capture runtime
- export runtime
- masking runtime
- support console implementation
- production deployment

All runtime remains deferred.

---

## 34. Validation Checklist

Validation must confirm:

1. Evidence packet types are defined.
2. Universal evidence header is defined.
3. Notice identity section is defined.
4. Text snapshot section is defined.
5. Surface and trigger section is defined.
6. Customer/session section is defined.
7. Order link section is defined.
8. Payment link section is defined.
9. POS/KDS link section is defined.
10. Acknowledgement section is defined.
11. Privacy consent section is defined.
12. Alcohol verification section is defined.
13. Refund/cancellation section is defined.
14. No-show/deposit section is defined.
15. Food safety section is defined.
16. Market price section is defined.
17. Coupon/event section is defined.
18. Review/content section is defined.
19. Device/hardware section is defined.
20. Disaster/exception section is defined.
21. Store setting snapshot section is defined.
22. Support case section is defined.
23. Export/masking section is defined.
24. Integrity and chain section is defined.
25. Required field matrix by packet type is defined.
26. Missing field handling is defined.
27. Data minimization boundary is defined.
28. Tenant isolation boundary is defined.
29. Anti-patterns are listed.
30. Coding remains unauthorized.
31. Runtime remains deferred.

---

## 35. Relationship To Previous Documents

This document supplements:

- `10716 Legal Notice Master Toggle Disclosure Consent And Compliance Governance Policy`
- `10717 Legal Notice Master Data Usage Flow And Runtime Retrieval Governance Policy`
- `10718 Legal Notice Master Data Table Static Specification Policy`
- `10719 Legal Notice Trigger Matrix And UI Surface Mapping Policy`
- `10720 Privacy Consent Evidence Packet And Retention Policy`
- `10721 Alcohol Age Gate Legal Notice And Staff Verification SOP Policy`
- `10722 Refund Cancellation No-Show Notice And Dispute Evidence SOP Policy`
- `10723 Legal Notice i18n Review And Controlled Translation Policy`
- `10724 Legal Notice Admin Toggle Permission And HQ Lock Policy`
- `10725 Legal Notice Static Seed Review And Approval Workflow Policy`
- `10726 Legal Notice Evidence Export Support And Dispute Packet Policy`
- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`
- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`
- `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy`

It also references:

- `10410 Payment Intent And Authorization Boundary Policy`
- `10420 Payment Confirmation And Provider Callback Boundary Policy`
- `10430 Refund Cancellation And Void Boundary Policy`
- `10450 Settlement Allocation And Reconciliation Boundary Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
- `10640 Tenant Scope Envelope Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`

It prepares possible future documents:

- `10731 Customer Notice Center UX Static Surface Index Policy`
- `10732 Regulatory Change Watchlist And Legal Notice Review Queue Policy`
- `10733 Legal Notice Admin Checklist And Store Onboarding Review Policy`
- `10734 Legal Notice Support Playbook And Case Reason Code Policy`
- `10735 Legal Notice Static Registry Readiness Check Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 36. Final Rule

Catch Menu legal notice evidence packets must be field-structured, version-linked, locale-aware, surface-aware, trigger-aware, tenant-scoped, privacy-minimized, export-controlled, and audit-linked.

Every high-risk notice evidence packet must preserve the exact notice version, rendered text identity, locale, surface, acknowledgement state, order/payment/KDS/POS linkage where applicable, store setting snapshot, and audit reference.

Missing critical fields must be surfaced as evidence gaps.

Support may use evidence packets to understand disputes.

Support must not mutate evidence.

AI may help classify evidence gaps and recommend review.

AI cannot fabricate evidence, approve disputes, deny refunds, or rewrite historical packets.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.