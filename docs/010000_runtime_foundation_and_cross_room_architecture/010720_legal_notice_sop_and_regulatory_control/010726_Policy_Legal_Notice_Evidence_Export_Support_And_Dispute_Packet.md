# 010726_Policy_Legal_Notice_Evidence_Export_Support_And_Dispute_Packet

## 1. Purpose

This document defines the Legal Notice Evidence Export, Support Case Reference, Dispute Packet, Evidence Snapshot, Case-Scoped Visibility, Privacy Masking, Legal Hold, Export Authority, and Audit Governance Policy for Catch Menu.

The previous document `10725 Legal Notice Static Seed Review And Approval Workflow Policy` defined how the legal notice seed pool is reviewed, approved, promoted, deprecated, and prepared for controlled future runtime use.

This document focuses on how legal notice evidence is used after a dispute occurs.

It defines how support, HQ, legal/compliance, store owners, and auditors can retrieve and export legal notice evidence without mutating historical truth.

This document is planning-only.

It does not provide legal advice.

It does not authorize coding.

---

## 2. Core Position

Legal notice evidence is valuable only if it is preserved, scoped, and exportable.

The correct rule is:

A dispute packet must reconstruct what happened.  
Current notice text is not enough.  
The exact notice version shown must be preserved.  
The customer-facing language must be preserved.  
Acknowledgement evidence must be preserved.  
Store toggle state at the time must be preserved.  
Order, payment, KDS, POS, and support states must be linked.  
Support may view evidence only within case scope.  
Export requires authority, purpose, masking, audit, and retention control.  
Evidence export must not mutate original evidence.  

Legal notice evidence is a compliance record, not a customer-service memo.

---

## 3. Scope

This policy applies to:

- customer support cases
- refund disputes
- no-show disputes
- alcohol disputes
- privacy consent disputes
- allergen/food safety disputes
- raw food freshness disputes
- market price disputes
- coupon/event disputes
- review/content disputes
- device damage disputes
- payment error disputes
- reservation deposit disputes
- delivery/pickup disputes
- staff protection incidents
- force majeure disputes
- legal/compliance audit
- franchise HQ audit
- evidence export
- legal hold
- privacy masking
- retention handling

This document defines governance only.

---

## 4. Evidence Packet Principle

A dispute packet must answer:

1. What notice was shown?
2. Which version was shown?
3. In what language was it shown?
4. On which surface was it shown?
5. Why was it triggered?
6. Was acknowledgement required?
7. Did the customer acknowledge it?
8. What was the order/payment/KDS/POS state?
9. What was the store setting at that time?
10. Who changed or approved the setting?
11. What decision was made?
12. Who made the decision?
13. What evidence supports the decision?
14. Has anything been changed since then?
15. Is export allowed for this purpose?

If a packet cannot answer these, it is incomplete.

---

## 5. Dispute Packet Types

Recommended dispute packet types:

| Packet Type | Meaning |
|---|---|
| `REFUND_DISPUTE_PACKET` | Refund/cancellation dispute |
| `NO_SHOW_DISPUTE_PACKET` | Waiting/reservation/pickup no-show dispute |
| `ALCOHOL_DISPUTE_PACKET` | Alcohol age/ID/refusal dispute |
| `PRIVACY_CONSENT_PACKET` | Privacy/marketing consent dispute |
| `FOOD_SAFETY_PACKET` | Allergy/raw food/hygiene notice dispute |
| `PAYMENT_ERROR_PACKET` | Duplicate payment, provider error, mismatch |
| `COUPON_EVENT_PACKET` | Coupon, point, promotion abuse |
| `REVIEW_CONTENT_PACKET` | Review, copyright, malicious content |
| `DEVICE_DAMAGE_PACKET` | Tablet/kiosk/device damage |
| `STAFF_PROTECTION_PACKET` | Abuse, harassment, removal |
| `DISASTER_EXCEPTION_PACKET` | Force majeure, outage, emergency |
| `GENERAL_LEGAL_NOTICE_PACKET` | General legal notice evidence |

Packet type determines included evidence.

---

## 6. Packet Core Fields

Every dispute packet should include:

| Field | Meaning |
|---|---|
| `packet_id` | Unique packet ID |
| `packet_type` | Dispute packet type |
| `case_id` | Support/legal case |
| `tenant_id` | Tenant |
| `store_id` | Store |
| `customer_id` | Customer if known |
| `session_id` | Session |
| `order_id` | Order if applicable |
| `payment_id` | Payment if applicable |
| `reservation_id` | Reservation if applicable |
| `waiting_id` | Waiting if applicable |
| `device_id` | Device if applicable |
| `created_at` | Packet creation time |
| `created_by` | Actor/system |
| `purpose` | Support, legal, audit, court, regulator |
| `visibility_scope` | Support, store, HQ, legal, auditor |
| `masking_profile` | Masking level |
| `export_state` | Not exported, exported, blocked |
| `audit_ref` | Audit correlation |

Packet creation must be audited.

---

## 7. Legal Notice Evidence Section

The legal notice section should include:

| Field | Meaning |
|---|---|
| `notice_id` | Notice identity |
| `notice_code` | Stable code |
| `notice_family` | Family |
| `notice_version_id` | Exact version |
| `version_no` | Version number |
| `locale` | Language shown |
| `text_variant` | Popup, checkbox, receipt, etc. |
| `text_hash` | Hash of shown text |
| `rendered_text_snapshot` | Snapshot or approved reference |
| `controlling_text_ref` | Korean controlling text if applicable |
| `surface_id` | Where shown |
| `trigger_rule_id` | Why shown |
| `shown_at` | Display time |
| `ack_required` | Whether ack required |
| `acknowledged_at` | Ack time |
| `ack_method` | Checkbox, confirm, staff confirm |
| `fallback_used` | Whether fallback used |
| `store_setting_id` | Store setting active at time |
| `policy_version` | Policy version at time |

A dispute packet must not use current notice text as historical proof.

---

## 8. Order State Evidence Section

Order section may include:

| Field | Meaning |
|---|---|
| `order_id` | Order |
| `order_created_at` | Created time |
| `order_submitted_at` | Submitted time |
| `order_accepted_at` | Accepted time |
| `order_status_timeline` | Status events |
| `menu_items` | Items ordered |
| `option_snapshot` | Options selected |
| `price_snapshot` | Price at order time |
| `market_price_state` | If applicable |
| `customer_request_log` | Customer requests |
| `staff_action_log` | Staff actions |
| `kds_ticket_ref` | KDS reference |
| `pos_handoff_ref` | POS reference |
| `audit_ref` | Audit correlation |

Order state must be event-based.

---

## 9. Payment Evidence Section

Payment section may include:

| Field | Meaning |
|---|---|
| `payment_id` | Payment |
| `payment_provider` | PG/VAN/provider |
| `payment_intent_state` | Intent state |
| `authorization_state` | Authorization state |
| `capture_state` | Capture state |
| `refund_state` | Refund state |
| `provider_callback_refs` | Provider callback evidence |
| `amount_authorized` | Authorized amount |
| `amount_captured` | Captured amount |
| `amount_refunded` | Refunded amount |
| `coupon_point_adjustment` | Benefit reversal |
| `settlement_state` | Settlement if applicable |
| `receipt_ref` | Receipt evidence |
| `reconciliation_state` | Reconciliation status |

Payment evidence must rely on provider-backed state.

---

## 10. KDS And POS Evidence Section

KDS/POS section may include:

| Field | Meaning |
|---|---|
| `kds_ticket_id` | KDS ticket |
| `kds_state_timeline` | KDS states |
| `kitchen_accepted_at` | Kitchen accepted |
| `prep_started_at` | Prep started |
| `completed_at` | Completed |
| `cancel_attempt_at` | Cancel request time |
| `pos_handoff_id` | POS handoff |
| `pos_accept_state` | POS accepted/failed/unknown |
| `pos_payment_state` | POS payment link if any |
| `printer_log_ref` | Printer if relevant |
| `manual_fallback_ref` | Manual fallback if relevant |

Refund/cancel disputes must include KDS/POS state where applicable.

---

## 11. Alcohol Evidence Section

Alcohol packet should include:

| Field | Meaning |
|---|---|
| `alcohol_item_ids` | Alcohol items |
| `adult_confirmation_notice_id` | Notice |
| `adult_confirmation_version_id` | Version |
| `adult_confirmed_at` | Customer confirmation |
| `staff_id_check_required` | Whether required |
| `staff_id_check_result` | Pass/fail/refused |
| `staff_actor_id` | Staff checker |
| `id_type_checked` | ID type category |
| `failure_reason` | No ID, minor, fake, refused |
| `action_taken` | Serve, block, cancel, refund |
| `alcohol_delivery_blocked` | If delivery attempted |
| `policy_version` | Alcohol policy version |

Do not include raw ID images unless separately approved.

---

## 12. Privacy Consent Evidence Section

Privacy packet should include:

| Field | Meaning |
|---|---|
| `consent_type` | Terms, privacy, marketing, location |
| `notice_version_id` | Exact version |
| `purpose` | Purpose of collection/use |
| `items_collected` | Data items |
| `recipient` | Third party if applicable |
| `retention_period` | Retention |
| `optional_required_flag` | Required/optional |
| `accepted` | Accepted/refused |
| `withdrawn_at` | Withdrawal time |
| `channel_scope` | Push/SMS/email if marketing |
| `locale` | Language shown |
| `text_hash` | Text hash |
| `audit_ref` | Audit |

Privacy consent export requires stronger masking and authority.

---

## 13. Food Safety Evidence Section

Food safety packet may include:

| Field | Meaning |
|---|---|
| `menu_item_id` | Item |
| `allergen_tags_at_time` | Tags at order time |
| `raw_food_flag` | Raw food |
| `spicy_level_flag` | Spicy |
| `cross_contamination_notice` | Notice reference |
| `customer_option_request` | Exclusion request |
| `staff_confirmation` | Staff handling if any |
| `pickup_or_delivery_time` | Handoff time |
| `freshness_notice_version` | Freshness warning |
| `storage_notice_version` | Takeout storage warning |
| `incident_report_ref` | If complaint |
| `evidence_photos_ref` | If available and permitted |

Food safety evidence should not claim facts not recorded.

---

## 14. No-Show Evidence Section

No-show packet may include:

| Field | Meaning |
|---|---|
| `reservation_id` | Reservation |
| `waiting_id` | Waiting |
| `pickup_order_id` | Pickup order |
| `notice_version_id` | No-show notice |
| `reservation_time` | Reserved time |
| `call_time` | Waiting call time |
| `grace_period` | Grace period |
| `arrival_time` | Arrival if any |
| `no_show_confirmed_at` | Confirmed time |
| `deposit_amount` | Deposit |
| `penalty_amount` | Penalty |
| `refund_state` | Refund/forfeit state |
| `notification_log` | SMS/push/call logs |
| `decision_actor` | Actor |
| `audit_ref` | Audit |

No-show penalty without timestamp evidence is weak.

---

## 15. Device Damage Evidence Section

Device packet may include:

| Field | Meaning |
|---|---|
| `device_id` | Tablet/kiosk |
| `table_id` | Table |
| `device_notice_version_id` | Device notice |
| `device_state_before` | Before state if known |
| `incident_time` | Incident time |
| `staff_report` | Staff report |
| `customer_session_id` | Session |
| `order_id` | Related order if any |
| `photo_evidence_ref` | Photo if permitted |
| `repair_cost_estimate` | Cost |
| `decision_actor` | Manager/support |
| `audit_ref` | Audit |

Device damage evidence must be scoped and fair.

---

## 16. Support Case Visibility

Support visibility should be case-scoped.

Support may see:

- related order/payment state
- notice evidence
- acknowledgement event
- customer contact masked as needed
- store policy state at time
- refund/no-show/alcohol decision history
- escalation status

Support may not:

- edit notice evidence
- edit consent history
- change store legal settings from case screen
- export bulk evidence without authority
- alter historical policy version

Support view is operational, not administrative.

---

## 17. Store Owner Visibility

Store owner may see:

- store-related dispute evidence
- notice setting at time
- order/payment state relevant to store
- customer-visible notice snapshot
- support decision state
- unresolved action items

Store owner should not see:

- unrelated tenant data
- full sensitive privacy data beyond need
- full payment provider secrets
- raw ID data
- other stores' legal evidence
- support internal legal notes if restricted

Store visibility must be tenant/store-scoped.

---

## 18. Franchise HQ Visibility

Franchise HQ may see:

- brand/store notice compliance status
- dispute trends
- missing notice warnings
- store toggle history
- legal notice version usage
- evidence packet summaries
- high-risk cases
- export-ready compliance reports

HQ access must be scoped to its tenant/brand/operating group.

HQ must not see unrelated tenant data.

---

## 19. Legal Auditor Visibility

Legal/compliance auditor may see:

- full notice version history
- approval records
- evidence packets
- export logs
- access logs
- missing notice cases
- legal hold state
- deprecation history
- emergency lock history
- high-risk decision records

Auditor access must be audited.

---

## 20. Export Authority Matrix

Recommended export authority:

| Export Type | Required Authority |
|---|---|
| Single support case packet | Support manager/HQ scoped |
| Privacy consent evidence | Privacy/legal authority |
| Alcohol verification packet | Legal/HQ authority |
| Payment/refund packet | Finance/support authority |
| Store compliance report | Store owner/HQ scoped |
| Franchise compliance report | Franchise HQ authority |
| Bulk evidence export | Platform legal/compliance |
| Regulator/litigation export | Platform legal authority |
| Customer data access request | Privacy authority |
| Internal audit export | Auditor/legal authority |

Export must require purpose and audit.

---

## 21. Masking Profiles

Recommended masking profiles:

| Profile | Meaning |
|---|---|
| `SUPPORT_MASKED` | Support case with minimal personal data |
| `STORE_OWNER_MASKED` | Store owner view |
| `HQ_SUMMARY_MASKED` | HQ trend/summary |
| `LEGAL_FULL` | Legal/compliance full evidence |
| `PRIVACY_REQUEST` | Data subject request format |
| `REGULATOR_EXPORT` | Regulatory export |
| `LITIGATION_HOLD_EXPORT` | Legal hold/court preparation |
| `PUBLIC_REDACTED` | Redacted external sharing |
| `INTERNAL_AUDIT` | Internal audit with controlled access |

Masking must be applied before export.

---

## 22. Export Packet Format

Export packet should include:

- packet metadata
- scope and purpose
- generated timestamp
- generated by
- masking profile
- evidence summary
- detailed evidence sections
- notice version references
- event timeline
- decision log
- missing evidence warnings
- hash/integrity metadata if available
- retention/legal hold marker
- export audit reference

Export should not expose unnecessary raw data.

---

## 23. Export Integrity

Export integrity may include:

| Integrity Item | Purpose |
|---|---|
| packet hash | Detect alteration |
| evidence hashes | Verify referenced evidence |
| generated_at | Timestamp |
| generated_by | Actor |
| source_system_version | System reference |
| audit_event_id | Export audit |
| page numbering | Document control |
| redaction log | What was masked |
| legal hold marker | Hold status |
| case reference | Case linkage |

Integrity metadata supports trustworthiness.

---

## 24. Legal Hold Boundary

Legal hold may be applied when:

- litigation is threatened
- regulator inquiry occurs
- privacy incident occurs
- alcohol compliance incident occurs
- serious food safety complaint occurs
- high-value refund dispute occurs
- staff protection incident occurs
- payment fraud investigation occurs
- franchise dispute occurs

Legal hold rules:

- suspend deletion/anonymization for relevant evidence
- record hold reason
- record hold authority
- record hold scope
- preserve versions and logs
- restrict export
- release hold only by authority

Legal hold is not ordinary retention.

---

## 25. Missing Evidence Handling

If expected evidence is missing:

| Missing Evidence | Handling |
|---|---|
| Notice not shown | Compliance gap |
| Notice shown but no version | Evidence weakness |
| Ack required but no ack | Dispute weakness |
| Trigger rule missing | Configuration issue |
| Store setting missing | Configuration issue |
| Payment state missing | Reconciliation required |
| KDS state missing | Operational evidence gap |
| i18n text missing | Translation evidence gap |
| Support action missing | Case audit gap |

Missing evidence must be visible, not hidden.

---

## 26. Evidence Timeline

Each packet should include a timeline.

Timeline example:

| Time | Event |
|---|---|
| 18:02 | Customer opened menu |
| 18:03 | Raw food notice shown |
| 18:04 | Item added to cart |
| 18:05 | Refund notice shown |
| 18:05 | Customer acknowledged |
| 18:06 | Payment authorized |
| 18:06 | KDS ticket accepted |
| 18:08 | Customer requested cancel |
| 18:08 | Cancel locked by KDS |
| 18:10 | Support case opened |
| 18:15 | Decision recorded |

Timeline must be generated from events, not free text.

---

## 27. Evidence Export Events

Recommended export audit events:

| Event Type | Meaning |
|---|---|
| `DISPUTE_PACKET_CREATED` | Packet created |
| `DISPUTE_PACKET_VIEWED` | Packet viewed |
| `DISPUTE_PACKET_EXPORTED` | Packet exported |
| `DISPUTE_PACKET_EXPORT_BLOCKED` | Export blocked |
| `DISPUTE_PACKET_MASKED` | Masking applied |
| `DISPUTE_PACKET_LEGAL_HOLD_APPLIED` | Legal hold applied |
| `DISPUTE_PACKET_LEGAL_HOLD_RELEASED` | Hold released |
| `DISPUTE_PACKET_EVIDENCE_MISSING` | Missing evidence detected |
| `DISPUTE_PACKET_HASH_GENERATED` | Integrity hash generated |
| `DISPUTE_PACKET_SUPPORT_LINKED` | Linked to support case |
| `DISPUTE_PACKET_REGULATOR_EXPORT` | Regulator export |
| `DISPUTE_PACKET_PRIVACY_REQUEST_EXPORT` | Data subject export |

Events must route through `10610`.

---

## 28. Retention Boundary

Dispute packet retention must follow:

- notice family
- dispute type
- payment retention
- privacy retention
- legal hold
- tenant policy
- store policy
- regulatory requirement
- audit requirement

Packet retention must not exceed necessity without policy.

Deletion/anonymization must preserve legally required audit where applicable.

---

## 29. Security Boundary

Evidence export is high-risk.

Rules:

- export requires explicit purpose
- export requires authority
- export is audited
- masking applies by default
- full export requires legal/compliance authority
- sensitive fields are redacted unless needed
- tenant/store scope enforced
- bulk export requires reauthentication
- legal hold restricts deletion and may restrict export
- support cannot bulk export
- exported files must have retention and access control

Evidence export must be safer than evidence view.

---

## 30. Anti-Patterns

Avoid:

- exporting current notice text instead of historical version
- exporting unmasked personal data by default
- letting support edit evidence before export
- creating dispute packet from free-text notes only
- hiding missing evidence
- exporting across tenant boundary
- exporting bulk consent records without authority
- deleting evidence under active dispute
- using screenshots as sole evidence when system logs exist
- exporting raw ID images unnecessarily
- losing i18n fallback state
- ignoring store toggle state at order time
- ignoring KDS/POS/payment state
- allowing dispute packet without audit
- treating export as settlement approval

These anti-patterns must be blocked in future runtime design.

---

## 31. Runtime Deferral

This document defines legal notice evidence export, support packet, dispute evidence, masking, legal hold, retention, and audit governance only.

It does not authorize:

- evidence export implementation
- support console implementation
- dispute packet generation
- masking runtime
- legal hold runtime
- export file generation
- regulator export workflow
- privacy request export workflow
- database schema
- RLS/security rules
- production deployment

All runtime remains deferred.

---

## 32. Validation Checklist

Validation must confirm:

1. Evidence packet principle is defined.
2. Dispute packet types are defined.
3. Packet core fields are defined.
4. Legal notice evidence section is defined.
5. Order state evidence section is defined.
6. Payment evidence section is defined.
7. KDS/POS evidence section is defined.
8. Alcohol evidence section is defined.
9. Privacy consent evidence section is defined.
10. Food safety evidence section is defined.
11. No-show evidence section is defined.
12. Device damage evidence section is defined.
13. Support case visibility is defined.
14. Store owner visibility is defined.
15. Franchise HQ visibility is defined.
16. Legal auditor visibility is defined.
17. Export authority matrix is defined.
18. Masking profiles are defined.
19. Export packet format is defined.
20. Export integrity is defined.
21. Legal hold boundary is defined.
22. Missing evidence handling is defined.
23. Evidence timeline is defined.
24. Evidence export events are defined.
25. Retention boundary is defined.
26. Security boundary is defined.
27. Anti-patterns are listed.
28. Coding remains unauthorized.
29. Runtime remains deferred.

---

## 33. Relationship To Previous Documents

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

- `10727 Legal Notice Customer Display UX And Popup Fatigue Control Policy`
- `10728 Legal Notice Emergency Lock And Regulatory Change Response Policy`
- `10729 Legal Notice Static Registry Closure And Runtime Deferral Policy`
- `10730 Legal Notice Evidence Packet Static Field Map Policy`

This document is architecture boundary planning only.

It does not authorize coding.

---

## 34. Final Rule

Catch Menu legal notice evidence must be exportable only through controlled, scoped, masked, audited, and purpose-bound dispute packets.

A dispute packet must preserve the exact notice version, locale, surface, trigger, acknowledgement, store setting, order state, payment state, KDS/POS state, decision history, and audit reference.

Support may view case-scoped evidence but cannot mutate it.

Store owners and franchise HQ may view only scoped evidence.

Legal/compliance may export stronger evidence packets with appropriate authority.

Missing evidence must be surfaced as a compliance gap, not hidden.

Historical evidence must never be rewritten.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.