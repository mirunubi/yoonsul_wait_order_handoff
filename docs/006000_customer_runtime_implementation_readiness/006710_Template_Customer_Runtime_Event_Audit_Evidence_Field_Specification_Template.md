# 006710_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md

## 1. Purpose

This template defines the Customer Runtime event, audit, and evidence field specification format.

The purpose is to convert Customer Runtime policy, state, authority, and evidence requirements into implementation-ready field definitions before database schema, API contract, event stream, audit log, or evidence packet implementation begins.

This template is used to specify:

- Event names
- Event source
- Actor authority
- State before and after
- Customer-facing status
- Runtime correlation references
- Evidence output
- Audit visibility
- Privacy sensitivity
- Closeout impact
- Support, finance, privacy, and rollout handoff behavior

This template prevents customer runtime events from being implemented as inconsistent free-form logs.

## 2. Scope

This template covers event, audit, and evidence field specification for:

- Entrance events
- Waiting events
- Table events
- Customer link/token events
- Web app events
- Native app continuity events
- Identity and merge events
- Membership and benefit events
- Support case events
- Privacy and consent events
- Evidence packet events
- Closeout and rollout events

This template does not define the final database schema, message broker implementation, API endpoint shape, analytics warehouse model, or audit retention duration.

## 3. Baseline Dependency

This template depends on:

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

It also supports downstream implementation of the Customer Runtime lane indexed in:

`06680_Index_Customer_Runtime_Lane_Document_Map_Readiness_Status_Handoff_And_Governance.md`

## 4. Core Principle

Every customer runtime event must be meaningful, attributable, correlated, and reviewable.

An event is valid only when it can answer:

1. What happened?
2. Who or what caused it?
3. Which customer/session/order/table/payment/support/benefit context was affected?
4. What state existed before?
5. What state exists after?
6. What did the customer see, if anything?
7. What evidence was produced?
8. Who may view the event?
9. Does it affect closeout, support, finance, privacy, or rollout?
10. Is the event safe to retain, expose, or anonymize?

## 5. Event Specification Header

Each event specification should begin with the following header.

| Field | Value |
|---|---|
| Event Name |  |
| Event Family |  |
| Event Version |  |
| Owning Document |  |
| Owning Domain | Customer Runtime |
| Runtime Surface | Entrance / Waiting / Table / Link / Web App / Native App / Identity / Membership / Support / Privacy / Evidence / Closeout |
| Source System |  |
| Created By |  |
| Last Reviewed |  |
| Status | Draft / Active / Deprecated / Replaced |
| Replacement Event |  |

## 6. Event Family Values

Allowed Customer Runtime event families include:

| Event Family | Meaning |
|---|---|
| Entrance | Customer entry through QR/NFC/link/device/staff assist |
| Waiting | Queue, call, arrival, no-show, recovery |
| Table | Table assignment, session, merge, split, close |
| Notification | Message creation, display, delivery, open, expiration |
| LinkToken | Link issue, validation, expiration, revocation, replay |
| WebApp | Web session, cart, preorder, recovery, duplicate prevention |
| NativeApp | Deep link, push, stale state, app/web continuity |
| Identity | Guest, account, merge, split, duplicate identity |
| Membership | Coupon, benefit, visit count, compensation |
| Support | Case creation, classification, owner, resolution |
| Privacy | Consent, display, access, restriction, incident |
| Evidence | Evidence packet, evidence gap, packet completion |
| Closeout | Daily closeout, pilot closeout, rollout decision |
| Incident | Customer runtime incident or escalation |
| FinanceHandoff | Payment, refund, cancel, benefit financial handoff |

## 7. Core Event Field Template

Every event must define these core fields.

| Field Name | Required | Type | Description | Example |
|---|---:|---|---|---|
| event_id | Yes | UUID / ULID | Unique event identifier |  |
| event_name | Yes | Text | Canonical event name | `waiting_customer_called` |
| event_family | Yes | Enum | Event family | Waiting |
| event_version | Yes | Text | Version of event schema | `v1` |
| occurred_at | Yes | Timestamp | Time event occurred |  |
| recorded_at | Yes | Timestamp | Time event was recorded |  |
| source_system | Yes | Text | System or surface that created the event | Web App |
| source_surface | Yes | Enum | Customer/runtime surface | Waiting |
| actor_type | Yes | Enum | Customer, Staff, Manager, System, Support, Finance, Privacy, Release |
| actor_id | Conditional | ID | Actor reference where available |  |
| actor_role | Conditional | Text | Role at time of action | Store Staff |
| store_id | Conditional | ID | Store context |  |
| business_date | Conditional | Date | Store business date |  |
| correlation_id | Yes | ID | Cross-flow correlation reference |  |
| idempotency_key | Conditional | Text | Duplicate prevention key, where applicable |  |
| previous_state | Conditional | Text | State before event | Waiting Active |
| new_state | Conditional | Text | State after event | Customer Called |
| reason_code | Conditional | Text | Reason or classification | CUSTOMER_CALLED |
| reason_note | Conditional | Text | Human note, where allowed |  |
| evidence_id | Conditional | ID | Evidence record generated or linked |  |
| support_case_id | Conditional | ID | Support case linkage |  |
| incident_id | Conditional | ID | Incident linkage |  |
| closeout_id | Conditional | ID | Daily or pilot closeout linkage |  |

## 8. Correlation Field Template

Each event must include applicable correlation references.

| Field Name | Required Condition | Description |
|---|---|---|
| customer_account_id | When account is known | Persistent customer account reference |
| guest_id | When guest session exists | Guest identity reference |
| device_session_id | When device/browser/app session exists | Device/session reference |
| customer_link_id | When link/token involved | Link reference, not raw token |
| token_hash_ref | When token evidence is needed | Safe token hash/reference |
| waiting_session_id | When waiting involved | Waiting session reference |
| party_id | When party identity involved | Party or group reference |
| table_id | When physical table involved | Physical table reference |
| table_session_id | When table session involved | Table session reference |
| cart_id | When cart involved | Cart draft reference |
| preorder_id | When preorder involved | Preorder reference |
| order_id | When accepted or attempted order exists | Order reference |
| pos_gateway_reference | When POS handoff involved | POS Gateway reference |
| payment_attempt_id | When payment attempt involved | Payment attempt reference |
| refund_cancel_reference | When refund/cancel involved | Refund/cancel reference |
| kds_ticket_id | When kitchen ticket involved | KDS ticket reference |
| coupon_id | When coupon involved | Coupon reference |
| benefit_id | When benefit involved | Benefit reference |
| membership_profile_id | When membership involved | Membership profile reference |
| support_case_id | When support case involved | Support reference |
| privacy_incident_id | When privacy issue involved | Privacy incident reference |
| evidence_packet_id | When packet involved | Evidence packet reference |
| rollout_decision_id | When rollout involved | Rollout decision reference |

Correlation references should use stable IDs, not customer names, table labels, staff memory, or free-text descriptions.

## 9. Customer-Facing Field Template

When an event affects what the customer sees, these fields must be defined.

| Field Name | Required | Description |
|---|---:|---|
| customer_visible | Yes | Whether the event can affect customer-facing surface |
| customer_status_code | Conditional | Customer-facing status code |
| customer_status_text_key | Conditional | Localization key for status wording |
| customer_status_language | Conditional | Language shown |
| customer_message_id | Conditional | Message or notification reference |
| display_surface | Conditional | Web app, native app, kiosk, QR/NFC page, waiting display, support page |
| display_started_at | Conditional | When status became visible |
| display_ended_at | Conditional | When status was superseded |
| superseded_by_event_id | Conditional | Later event that replaced displayed state |
| customer_action_allowed | Conditional | Allowed customer action |
| customer_action_blocked_reason | Conditional | Reason customer action was blocked |

Customer-facing fields must not expose internal state names, raw IDs, raw token values, payment provider internals, or staff-only notes.

## 10. Authority Field Template

Each event must define authority fields.

| Field Name | Required | Description |
|---|---:|---|
| authority_required | Yes | Whether authority check is required |
| authority_source | Conditional | Role, system rule, provider state, manager approval, support approval |
| authority_result | Conditional | Approved, Denied, Not Required, Deferred |
| authority_checked_at | Conditional | Time authority was checked |
| approval_actor_id | Conditional | Actor approving the event |
| approval_role | Conditional | Role approving the event |
| approval_reference_id | Conditional | Approval or override reference |
| reauth_required | Conditional | Whether reauthentication was required |
| reauth_result | Conditional | Result of reauthentication |
| override_flag | Yes | Whether event is override/manual correction |
| override_reason_code | Conditional | Reason for override |
| override_evidence_id | Conditional | Evidence for override |

Sensitive events must not be allowed without authority evidence.

## 11. Evidence Field Template

Each event must define evidence behavior.

| Field Name | Required | Description |
|---|---:|---|
| evidence_required | Yes | Whether evidence must be created |
| evidence_family | Conditional | Waiting, Table, LinkToken, WebApp, Identity, Membership, Support, Privacy, Closeout |
| evidence_record_id | Conditional | Evidence reference |
| evidence_packet_id | Conditional | Packet reference |
| evidence_visibility_class | Yes | Staff, Manager, Support, Finance, Privacy, Audit, Release |
| evidence_retention_class | Yes | Active, Operational, Finance, Support, Audit, Privacy, Legal Hold |
| evidence_mutability | Yes | Append-only, Correctable, Restricted, Ephemeral |
| evidence_gap_if_missing | Yes | Whether missing evidence creates gap |
| evidence_gap_severity | Conditional | Risk severity if missing |
| evidence_gap_register_route | Conditional | Register route if missing |
| evidence_summary | Conditional | Human-readable evidence summary |

Evidence must be traceable even when customer-facing details are minimized.

## 12. Audit Field Template

Each event must define audit behavior.

| Field Name | Required | Description |
|---|---:|---|
| audit_required | Yes | Whether event enters audit log |
| audit_category | Conditional | Operational, Financial, Privacy, Security, Support, Rollout |
| audit_visibility | Conditional | Which roles may inspect |
| audit_redaction_required | Yes | Whether fields must be redacted in some views |
| audit_sensitive_fields | Conditional | Fields requiring redaction |
| audit_reason_required | Conditional | Whether reason note/code required |
| audit_actor_required | Conditional | Whether actor must be identifiable |
| audit_access_logged | Conditional | Whether viewing audit record must itself be logged |
| audit_export_allowed | Yes | Whether export is allowed |
| audit_export_restriction | Conditional | Export restriction rule |

Audit fields must be defined before implementation, not after incidents occur.

## 13. Privacy Field Template

Each event must define privacy behavior.

| Field Name | Required | Description |
|---|---:|---|
| privacy_class | Yes | Public, CustomerScoped, StaffScoped, Sensitive, Restricted, AuditOnly |
| contains_personal_data | Yes | Whether event includes customer personal data |
| contains_contact_data | Yes | Whether contact data exists |
| contains_payment_sensitive_data | Yes | Whether payment-sensitive data exists |
| contains_staff_note | Yes | Whether staff note exists |
| contains_support_claim | Yes | Whether support claim exists |
| data_minimization_reviewed | Yes | Whether fields are minimized |
| customer_access_allowed | Yes | Whether customer may view any part |
| staff_access_allowed | Yes | Whether staff may view |
| support_access_allowed | Yes | Whether support may view |
| finance_access_allowed | Yes | Whether finance may view |
| privacy_owner_review_required | Conditional | Whether privacy owner must review |
| anonymization_allowed | Conditional | Whether event may be anonymized |
| deletion_allowed | Conditional | Whether event may be deleted |
| legal_hold_eligible | Yes | Whether legal hold may apply |

Privacy classification must be conservative for customer-facing and payment-sensitive records.

## 14. Handoff Field Template

Each event must define handoff behavior.

| Field Name | Required | Description |
|---|---:|---|
| support_handoff_required | Yes | Whether unresolved event can/should create support case |
| support_handoff_condition | Conditional | Trigger condition |
| finance_handoff_required | Yes | Whether finance review is affected |
| finance_handoff_condition | Conditional | Trigger condition |
| privacy_handoff_required | Yes | Whether privacy/compliance review is affected |
| privacy_handoff_condition | Conditional | Trigger condition |
| incident_handoff_required | Yes | Whether incident record may be created |
| incident_handoff_condition | Conditional | Trigger condition |
| closeout_review_required | Yes | Whether daily closeout must review |
| rollout_review_required | Yes | Whether pilot/rollout review must consider |
| register_route_required | Yes | Whether risk register route is required for unresolved state |
| register_family | Conditional | Target register family |

## 15. Event State Transition Template

For each event, define allowed state transitions.

| Previous State | Event Name | New State | Allowed Source | Authority | Evidence Required | Customer Display |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

Invalid transitions must be rejected or routed to manual review.

## 16. Event Example Template

Use the following format for each event specification.

### 16.1 Event Name

`waiting_customer_called`

### 16.2 Event Summary

Records that a waiting party was called through an approved staff or system-controlled process.

### 16.3 Required Fields

| Field | Required | Notes |
|---|---:|---|
| event_id | Yes |  |
| event_name | Yes | `waiting_customer_called` |
| occurred_at | Yes |  |
| actor_type | Yes | Staff or System |
| actor_id | Conditional | Required when staff-triggered |
| store_id | Yes |  |
| business_date | Yes |  |
| waiting_session_id | Yes |  |
| customer_message_id | Conditional | Required when message sent |
| previous_state | Yes | Waiting Active |
| new_state | Yes | Customer Called |
| evidence_record_id | Yes | Call evidence |
| customer_status_code | Yes | `CALLED` |
| closeout_review_required | Yes |  |

### 16.4 Authority

| Authority Field | Value |
|---|---|
| authority_required | Yes |
| allowed_actor_type | Staff / System |
| manager_approval_required | No, unless queue exception |
| override_flag | No by default |

### 16.5 Evidence

| Evidence Field | Value |
|---|---|
| evidence_required | Yes |
| evidence_family | Waiting |
| evidence_visibility_class | Staff / Manager / Support / Audit |
| evidence_gap_if_missing | Yes |
| evidence_gap_severity | High |

### 16.6 Handoff

| Handoff | Rule |
|---|---|
| Support | Required if customer disputes call or no-show |
| Finance | Not required |
| Privacy | Required if wrong recipient/contact exposed |
| Closeout | Required |
| Register | Required if call evidence missing |

## 17. Naming Rules

Event names must follow this convention:

`<domain>_<object>_<action>`

Examples:

- `waiting_customer_called`
- `waiting_no_show_confirmed`
- `table_session_reassigned`
- `customer_token_replay_blocked`
- `customer_web_duplicate_submission_blocked`
- `guest_account_merge_completed`
- `coupon_reserved`
- `support_case_owner_assigned`
- `privacy_incident_created`
- `customer_evidence_gap_found`
- `customer_rollout_decision_recorded`

Event names must be stable, lowercase, snake_case, and action-oriented.

## 18. Event Versioning Rules

Event versions must be managed.

| Rule | Requirement |
|---|---|
| Additive change | May keep same major version if consumers are safe |
| Breaking field change | Requires new version |
| Meaning change | Requires new event or version |
| Deprecated event | Must specify replacement |
| Removed event | Must be retained in historical decoder |
| Customer-facing wording change | Must link message template version |
| Privacy classification change | Must be reviewed before release |
| Evidence requirement change | Must update matrix and template |

Events must not change meaning silently.

## 19. Required Event Specification Table

| Event Name | Family | Version | Owner | Status | Matrix Reference | Spec Completed |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

## 20. Required Field Review Table

| Review Area | Result | Reviewer | Notes |
|---|---|---|---|
| Event naming reviewed |  |  |  |
| Authority reviewed |  |  |  |
| Correlation reviewed |  |  |  |
| Customer display reviewed |  |  |  |
| Evidence reviewed |  |  |  |
| Audit reviewed |  |  |  |
| Privacy reviewed |  |  |  |
| Support handoff reviewed |  |  |  |
| Finance handoff reviewed |  |  |  |
| Closeout reviewed |  |  |  |
| Rollout risk reviewed |  |  |  |

## 21. Blocking Conditions

An event specification is not implementation-ready when:

- Event name is ambiguous
- Actor/source is missing
- Authority is undefined
- State transition is undefined
- Correlation references are missing
- Customer-facing status is undefined for visible state
- Evidence requirement is missing
- Privacy class is missing
- Audit visibility is undefined
- Handoff conditions are missing
- Closeout impact is unknown
- Missing evidence does not route to register
- Versioning rule is not defined

## 22. Acceptance Criteria

This template is accepted when:

- Event family values are defined
- Core event fields are defined
- Correlation fields are defined
- Customer-facing fields are defined
- Authority fields are defined
- Evidence fields are defined
- Audit fields are defined
- Privacy fields are defined
- Handoff fields are defined
- State transition format is defined
- Event example format is provided
- Naming and versioning rules are defined
- Review table is available
- Blocking conditions are documented

## 23. Related Documents

Related document families include:

- Customer Runtime state authority event and evidence coverage matrix
- Customer Runtime lane index
- Customer runtime evidence packet policy
- Customer privacy consent data retention policy
- Customer support case policy
- Customer account and guest merge policy
- Customer link token and QR/NFC security policy
- Customer web app runtime policy
- Customer notification and multilingual guidance policy
- Runtime evidence policy
- Event audit schema
- Role authority matrix
- Privacy access log specification

## 24. Final Rule

A customer runtime event is not just a log line.

It is the smallest durable proof unit that connects customer action, runtime state, authority, evidence, audit, privacy, support, finance, closeout, and rollout governance.

This template defines how those event units must be specified before implementation begins.