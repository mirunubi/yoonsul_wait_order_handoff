# 006770_Template_Customer_Runtime_Display_Status_Code_Action_Permission_Message_Binding_And_Evidence_Template

## 1. Purpose

This template defines the Customer Runtime display status code, action permission, message binding, and evidence specification format.

The purpose is to convert customer-facing display rules into implementation-ready records.

This template ensures that every customer-visible status, button, message, error, recovery path, and support handoff is tied to runtime state, customer surface, authority, privacy class, evidence, and rollout risk.

A customer display status must not be implemented as informal UI text.  
It must be a controlled runtime artifact.

## 2. Scope

This template covers:

- Display status code definition
- Customer action permission definition
- Message template binding
- Surface-specific display rules
- Stale state handling
- Error and recovery binding
- Privacy-sensitive display control
- Payment-sensitive display control
- Evidence requirement
- Support, finance, privacy, and closeout handoff
- Rollout blocking condition

This template does not define final UI layout, visual design, frontend components, CSS, iconography, accessibility implementation, or final brand copy.

## 3. Baseline Dependency

This template depends on:

`006760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`

It also supports:

`006750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`

`006700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

`06690_Matrix_Customer_Runtime_State_Authority_Event_And_Evidence_Coverage_Matrix.md`

## 4. Core Principle

A display status is a controlled customer-facing claim.

Each display status must define:

1. Which runtime state allows it
2. Which customer surface may show it
3. Which message template is bound to it
4. Which action buttons are allowed
5. Which actions are blocked
6. Which evidence must be created
7. Which privacy class applies
8. Which stale-state behavior applies
9. Which support, finance, privacy, or incident handoff is required
10. Whether pilot or rollout is blocked when this status is unsafe

## 5. Display Status Specification Header

Each display status specification must begin with the following header.

| Field | Value |
|---|---|
| Display Status Code |  |
| Display Status Family |  |
| Status Version |  |
| Owning Document |  |
| Owning Domain | Customer Runtime |
| Runtime State Source |  |
| Allowed Surface |  |
| Risk Class | DSP-R1 / DSP-R2 / DSP-R3 / DSP-R4 |
| Privacy Class | Public / CustomerScoped / StaffScoped / Sensitive / Restricted |
| Status | Draft / Active / Restricted / Deprecated / Blocked / Retired |
| Created By |  |
| Last Reviewed |  |
| Replacement Status Code |  |

## 6. Display Status Family Values

Allowed display status families include:

| Family | Meaning |
|---|---|
| Entrance | QR/NFC entry, store context, entry recovery |
| Waiting | Waiting registration, queue, call, arrival, no-show, recovery |
| Table | Table assignment, service context, reassignment, close |
| Order | Cart, preorder, order checking, accepted, rejected, cancelled |
| Payment | Payment pending, approved, failed, uncertain, refund/cancel |
| Kitchen | Preparing, delayed, ready, served, remake, unavailable |
| LinkToken | Expired link, invalid link, replay blocked, recovery |
| WebApp | Web session, stale display, duplicate action, recovery |
| NativeApp | Deep link, push landing, stale state, app/web conflict |
| Kiosk | Kiosk session, cart, payment, recovery, staff assist |
| Membership | Coupon, benefit, visit count, compensation |
| Support | Case received, review, resolved, rejected, reopened |
| Privacy | Privacy review, restriction, consent, incident, resolution |
| ErrorRecovery | Safe error, retry, staff assist, support handoff |
| RolloutRestriction | Temporarily unavailable, pilot restriction, feature disabled |

## 7. Core Status Fields

Every display status record must define these fields.

| Field Name | Required | Type | Description |
|---|---:|---|---|
| display_status_id | Yes | ID | Unique internal ID |
| status_code | Yes | Text | Stable customer runtime status code |
| status_family | Yes | Enum | Display status family |
| status_version | Yes | Text | Version of status definition |
| runtime_state | Yes | Text | Authoritative runtime state that permits this display |
| event_trigger | Yes | Text | Event that creates or updates the display |
| surface_family | Yes | Enum | Customer surface family |
| customer_visible | Yes | Boolean | Whether shown to customer |
| risk_class | Yes | Enum | DSP-R1 to DSP-R4 |
| privacy_class | Yes | Enum | Privacy classification |
| message_template_id | Yes | ID | Bound message template |
| message_template_version | Yes | Text | Bound message version |
| localization_key | Conditional | Text | Localization key |
| default_language | Yes | Text | Default language |
| allowed_languages | Conditional | List | Approved languages |
| action_policy_id | Conditional | ID | Linked action permission policy |
| evidence_required | Yes | Boolean | Whether display evidence is required |
| stale_behavior | Yes | Text | Refresh, block, recover, expire, or support |
| closeout_review_required | Yes | Boolean | Whether daily closeout reviews this display |
| support_handoff_condition | Conditional | Text | When support handoff is required |
| finance_handoff_condition | Conditional | Text | When finance handoff is required |
| privacy_handoff_condition | Conditional | Text | When privacy handoff is required |
| incident_condition | Conditional | Text | When incident must be created |
| rollout_blocking_if_failed | Yes | Boolean | Whether unsafe status blocks rollout |

## 8. Display Surface Binding

Each status must define allowed surfaces.

| Surface | Allowed | Condition | Notes |
|---|---:|---|---|
| QR/NFC Entrance Page |  |  |  |
| Waiting Page |  |  |  |
| Table Page |  |  |  |
| Customer Web App |  |  |  |
| Native App |  |  |  |
| Main Kiosk |  |  |  |
| Mini Kiosk |  |  |  |
| Notification |  |  |  |
| Support Page |  |  |  |
| Membership Wallet |  |  |  |
| Recovery/Error Page |  |  |  |
| Staff Script View |  |  |  |

A status approved for one surface is not automatically approved for every surface.

## 9. Customer Action Permission Template

Each status must define allowed customer actions.

| Action Code | Action Label Key | Action Class | Allowed | Required Runtime Condition | Required Authority | Evidence Required | Block Reason If Not Allowed |
|---|---|---|---:|---|---|---:|---|
|  |  | View Only |  |  |  |  |  |
|  |  | Confirm |  |  |  |  |  |
|  |  | Submit |  |  |  |  |  |
|  |  | Modify |  |  |  |  |  |
|  |  | Cancel |  |  |  |  |  |
|  |  | Pay |  |  |  |  |  |
|  |  | Claim |  |  |  |  |  |
|  |  | Recover |  |  |  |  |  |
|  |  | Contact Support |  |  |  |  |  |

Sensitive actions must have idempotency, scope, and evidence rules.

## 10. Message Binding Template

Each status must bind to controlled message templates.

| Field | Value |
|---|---|
| Primary Message Template ID |  |
| Primary Message Version |  |
| Short Message Template ID |  |
| Notification Message Template ID |  |
| Error Message Template ID |  |
| Recovery Message Template ID |  |
| Staff Script Template ID |  |
| Support Explanation Template ID |  |
| Translation Review Required | Yes / No |
| Finance Review Required | Yes / No |
| Privacy Review Required | Yes / No |
| Support Review Required | Yes / No |
| Release Review Required | Yes / No |

Message binding must use the approved message register, not free-form UI strings.

## 11. Runtime State Binding Template

Each display status must define permitted runtime state transitions.

| Previous Runtime State | Event Trigger | Display Status Code | Allowed Surface | Customer Action | Evidence Required |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

Invalid state-to-display combinations must be blocked or routed to recovery.

## 12. Privacy And Data Exposure Template

Each display status must define privacy rules.

| Privacy Field | Value |
|---|---|
| Customer Data Displayed | Yes / No |
| Guest Data Displayed | Yes / No |
| Contact Data Displayed | Yes / No |
| Order Data Displayed | Yes / No |
| Payment Status Displayed | Yes / No |
| Support Case Data Displayed | Yes / No |
| Membership/Benefit Data Displayed | Yes / No |
| Staff Note Displayed | Must be No for customer-facing surfaces |
| Internal ID Displayed | Must be No unless explicitly safe |
| Token Value Displayed | Must be No |
| Other Customer Data Possible | Must be No |
| Redaction Required | Yes / No |
| Privacy Review Required | Yes / No |

Any status that could expose wrong customer/session data must be treated as rollout-sensitive.

## 13. Payment-Sensitive Display Template

For payment-related statuses, define:

| Field | Value |
|---|---|
| Payment State Source |  |
| Provider Reference Required | Yes / No |
| POS Gateway Reference Required | Yes / No |
| Payment Attempt ID Required | Yes / No |
| Payment Approved Display Allowed | Yes / No |
| Payment Failed Display Allowed | Yes / No |
| Payment Uncertainty Display Allowed | Yes / No |
| Retry Payment Allowed | Yes / No |
| Duplicate Payment Guard Required | Yes / No |
| Finance Handoff Required | Yes / No |
| Refund/Cancel Distinction Required | Yes / No |
| Customer Message Risk | DSP-R1 |
| Rollout Blocking If Evidence Missing | Yes |

Payment display must never be inferred from app state alone.

## 14. Refund And Cancel Display Template

For refund/cancel-related statuses, define:

| Field | Value |
|---|---|
| Cancel Requested Display |  |
| Cancel Approved Display |  |
| Cancel Completed Display |  |
| Refund Requested Display |  |
| Refund Approved Display |  |
| Refund Processing Display |  |
| Refund Completed Display |  |
| Refund Failed Display |  |
| Refund Evidence Required |  |
| Finance Owner Required |  |
| Customer Message Restriction |  |
| Support Handoff Condition |  |

Refund and cancel display must not be collapsed into one generic “resolved” status.

## 15. Support Display Template

For support-related statuses, define:

| Field | Value |
|---|---|
| Case Status Source |  |
| Customer Claim Visible | Yes / No |
| Internal Severity Visible | Must be No by default |
| Staff Note Visible | Must be No by default |
| Owner Name Visible | Yes / No / Role Only |
| Customer Response Allowed | Yes / No |
| Reopen Allowed | Yes / No |
| Compensation Mention Allowed | Yes / No |
| Finance Review Mention Allowed | Yes / No |
| Privacy Review Mention Allowed | Yes / No |
| Closure Reason Visible | Yes / No |
| Rejection Reason Visible | Yes / No |
| Evidence Required | Yes |

Support display must be transparent enough for customer trust, but not expose internal notes or unrelated records.

## 16. Membership And Benefit Display Template

For membership, coupon, visit count, and benefit display, define:

| Field | Value |
|---|---|
| Benefit Type | Coupon / Visit Count / Loyalty / Compensation / Store Benefit |
| Benefit State Source |  |
| Eligible Display Allowed |  |
| Reserved Display Allowed |  |
| Applied Display Allowed |  |
| Consumed Display Allowed |  |
| Released Display Allowed |  |
| Restored Display Allowed |  |
| Expired Display Allowed |  |
| Disputed Display Allowed |  |
| Refund/Cancel Impact Visible | Yes / No |
| Finance Impact Review Required | Yes / No |
| Support Handoff Condition |  |
| Abuse Review Hidden From Customer | Yes / No |
| Evidence Required | Yes |

Benefit display must not imply refund, payment success, or compensation unless separately confirmed.

## 17. Stale State Handling Template

Each display status must define stale handling.

| Stale Condition | Detection Source | Customer Display | Allowed Action | Evidence | Handoff |
|---|---|---|---|---|---|
| Runtime state changed |  | Checking latest status | Refresh / wait | Stale display evidence | Incident if repeated |
| Token expired |  | Link expired | Recover / ask staff | Expiration evidence | Support if disputed |
| Payment state uncertain |  | Payment result checking | Wait / support | Payment evidence | Finance |
| Table reassigned |  | Table info updated | Follow new guidance | Reassignment evidence | Support if disputed |
| Order state changed |  | Order status updated | View latest | Order evidence | Support if disputed |
| Coupon state changed |  | Benefit status updated | View latest | Benefit evidence | Support if disputed |
| Privacy restriction applied |  | Information unavailable | Contact support | Privacy evidence | Privacy owner |

Stale display must block sensitive action until current state is verified.

## 18. Error And Recovery Template

For each error or recovery display, define:

| Field | Value |
|---|---|
| Error Code |  |
| Error Family | Link / Session / Payment / Order / Table / Waiting / Support / Privacy |
| Customer Message Template |  |
| Internal Reason Hidden | Yes |
| Retry Allowed | Yes / No |
| Recovery Allowed | Yes / No |
| Staff Assist Required | Yes / No |
| Support Handoff Required | Yes / No |
| Incident Required | Yes / No |
| Privacy Review Required | Yes / No |
| Evidence Required | Yes |
| Rollout Blocking If Repeated | Yes / No |

Error displays must be safe, minimal, and recoverable.

## 19. Display Evidence Template

Every high-risk display must produce evidence.

| Field Name | Required | Description |
|---|---:|---|
| display_event_id | Yes | Unique display evidence record |
| display_status_code | Yes | Status displayed |
| display_status_version | Yes | Status version |
| surface_family | Yes | Surface shown |
| message_template_id | Yes | Message template used |
| message_template_version | Yes | Message version |
| language | Yes | Display language |
| customer_account_id | Conditional | Account reference |
| guest_id | Conditional | Guest reference |
| waiting_session_id | Conditional | Waiting reference |
| table_session_id | Conditional | Table reference |
| order_id | Conditional | Order reference |
| payment_attempt_id | Conditional | Payment reference |
| support_case_id | Conditional | Support reference |
| coupon_or_benefit_id | Conditional | Benefit reference |
| runtime_state | Yes | Runtime state at display |
| event_trigger | Yes | Event that triggered display |
| displayed_at | Yes | Timestamp |
| superseded_at | Conditional | When display was replaced |
| customer_action_taken | Conditional | Action selected by customer |
| evidence_visibility_class | Yes | Role visibility |
| closeout_review_required | Yes | Whether closeout reviews |

## 20. Status Specification Example

### 20.1 Status Code

`WAITING_CALLED`

### 20.2 Summary

Displayed when a waiting customer has been called through an approved call event.

### 20.3 Runtime Binding

| Field | Value |
|---|---|
| Runtime State | Customer Called |
| Event Trigger | `waiting_customer_called` |
| Required Evidence | Call evidence |
| Allowed Surface | Waiting Page / Notification / Staff Script View |
| Risk Class | DSP-R2 |
| Privacy Class | CustomerScoped |

### 20.4 Message Binding

| Field | Value |
|---|---|
| Primary Message Template | `MSG_WAITING_CALLED_v1` |
| Short Notification Template | `MSG_WAITING_CALLED_SHORT_v1` |
| Customer Action | Confirm Arrival |
| Blocked Action | Force Seating / Queue Reorder |
| Translation Review Required | Yes |

### 20.5 Evidence

| Field | Value |
|---|---|
| Evidence Required | Yes |
| Evidence Family | Waiting |
| Closeout Review Required | Yes |
| Support Handoff Condition | Customer disputes call or no-show |
| Rollout Blocking If Missing | Yes |

## 21. Status Registry Table

| Status Code | Family | Runtime State | Event Trigger | Surface | Risk | Message Template | Allowed Action | Evidence Required | Status |
|---|---|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |  |  |

## 22. Action Registry Table

| Action Code | Action Class | Allowed Status Codes | Required Authority | Idempotency Required | Evidence Required | Blocked Status Codes |
|---|---|---|---|---:|---:|---|
|  |  |  |  |  |  |  |

## 23. Error Registry Table

| Error Code | Error Family | Customer Message Template | Retry Allowed | Recovery Allowed | Support Required | Incident Required | Evidence Required |
|---|---|---|---:|---:|---:|---:|---:|
|  |  |  |  |  |  |  |  |

## 24. Review Checklist

| Review Area | Result | Reviewer | Notes |
|---|---|---|---|
| Runtime state binding reviewed |  |  |  |
| Message template binding reviewed |  |  |  |
| Customer action permissions reviewed |  |  |  |
| Privacy exposure reviewed |  |  |  |
| Payment/refund wording reviewed |  |  |  |
| Support handoff reviewed |  |  |  |
| Evidence requirement reviewed |  |  |  |
| Stale-state handling reviewed |  |  |  |
| Error/recovery behavior reviewed |  |  |  |
| Rollout blocking condition reviewed |  |  |  |

## 25. Blocking Conditions

A display status specification is not implementation-ready when:

- Runtime state source is undefined
- Event trigger is missing
- Surface binding is ambiguous
- Message template is not approved
- Customer action permission is undefined
- Sensitive action lacks idempotency
- Privacy class is missing
- Payment/refund display is inferred from non-authoritative state
- Stale-state handling is missing
- Error message exposes internal reason
- Display evidence requirement is missing
- Support, finance, privacy, or closeout handoff is undefined
- High-risk display has no rollout blocking rule

## 26. Acceptance Criteria

This template is accepted when:

- Display status header is defined
- Display family values are defined
- Core status fields are defined
- Surface binding format is defined
- Customer action permission format is defined
- Message binding format is defined
- Runtime state binding format is defined
- Privacy and data exposure format is defined
- Payment-sensitive display format is defined
- Refund/cancel display format is defined
- Support display format is defined
- Membership/benefit display format is defined
- Stale-state handling format is defined
- Error and recovery format is defined
- Display evidence format is defined
- Registry tables are included
- Review checklist is included
- Blocking conditions are documented

## 27. Related Documents

Related document families include:

- Customer display surface status action message evidence control matrix
- Customer message template translation status wording register
- Customer runtime event audit evidence field specification template
- Customer runtime state authority event evidence matrix
- Privacy consent and link security preflight checklist
- Customer Runtime risk waiver blocker register
- Customer web app runtime policy
- Customer native app runtime policy
- Customer link token QR/NFC security policy
- Payment uncertainty policy
- Refund and cancel policy
- Membership loyalty coupon benefit policy
- Customer support case policy

## 28. Final Rule

A UI label becomes operational truth the moment a customer sees it.

Every customer-visible status, button, message, recovery path, and error must be specified as a controlled runtime artifact with state binding, authority, evidence, privacy classification, and rollout risk.

This template is the implementation bridge from Customer Runtime display policy to frontend behavior.