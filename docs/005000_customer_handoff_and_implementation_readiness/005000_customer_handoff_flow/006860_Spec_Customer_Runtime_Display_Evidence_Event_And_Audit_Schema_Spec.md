# 006860_Spec_Customer_Runtime_Display_Evidence_Event_And_Audit_Schema_Spec

## 1. Purpose

This specification defines the Customer Runtime display evidence event and audit schema.

The purpose is to ensure that customer-facing displays, messages, buttons, notifications, recovery screens, support pages, payment/refund wording, privacy-sensitive screens, and action submissions are traceable after customer dispute, support case, audit review, pilot closeout, or rollout incident.

A customer-facing screen becomes evidence when the customer relies on it.

The system must be able to answer:

- What did the customer see?
- Which runtime state produced it?
- Which message template and version were used?
- Which language was shown?
- Which button or action was available?
- Which action did the customer take?
- Was the display stale, superseded, expired, or wrong?
- Who or what owned the runtime state?
- Was the display safe for privacy, payment, support, and rollout?

## 2. Scope

This specification covers:

- Display evidence event schema
- Message evidence schema
- Action evidence schema
- Notification evidence schema
- Error and recovery evidence schema
- Stale display evidence schema
- Payment/refund display evidence
- Support display evidence
- Privacy-sensitive display evidence
- Membership/benefit display evidence
- Kiosk and mini kiosk display evidence
- Native app push/deep link display evidence
- Audit visibility and redaction
- Retention and closeout review
- Evidence correlation and traceability

This specification does not define the final physical database table DDL, analytics warehouse design, observability stack, log storage vendor, or legal retention calendar.

## 3. Baseline Dependency

This specification depends on:

`006850_Spec_Customer_Runtime_Message_Template_Localization_Key_And_Versioning_Spec.md`

It must remain consistent with:

`006840_Spec_Customer_Runtime_Action_Permission_Button_Guard_And_Idempotency_Spec.md`

`006830_Spec_Customer_Runtime_Display_Status_Code_Registry_And_UI_State_Binding_Spec.md`

`006700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

`006620_Policy_Customer_Runtime_Evidence_Audit_Trail_Traceability_Closeout_Handoff.md`

## 4. Core Principle

Display evidence must prove runtime truth without overexposing customer data.

Every evidence record must balance:

1. Traceability
2. Privacy
3. Auditability
4. Dispute usefulness
5. Support usefulness
6. Financial reconciliation usefulness
7. Rollout readiness
8. Retention control
9. Redaction control
10. Tamper-resistant sequencing

Display evidence must be sufficient to prove what happened, but must not become a new privacy exposure surface.

## 5. Evidence Families

Customer Runtime display evidence is grouped into the following families.

| Evidence Family | Description |
|---|---|
| Display Evidence | Customer-facing surface rendered a status/message/action |
| Message Evidence | Message template was displayed, sent, opened, or superseded |
| Action Evidence | Customer-facing action was shown, submitted, blocked, or accepted |
| Notification Evidence | SMS, push, app message, web notification, or call message evidence |
| Error Evidence | Error page or blocked-action message displayed |
| Recovery Evidence | Session/link/action recovery display and result evidence |
| Stale State Evidence | Display or action was stale and refreshed, blocked, or recovered |
| Payment Display Evidence | Payment/refund/cancel status shown to customer |
| Support Display Evidence | Support case status or response shown to customer |
| Privacy Display Evidence | Privacy-sensitive review, restriction, or incident display evidence |
| Benefit Display Evidence | Coupon, visit count, loyalty, compensation benefit display evidence |
| Kiosk Display Evidence | Main kiosk or mini kiosk display/action evidence |
| Native Display Evidence | Deep link, push landing, stale native state display evidence |
| Closeout Evidence | Display QA or business day closeout display evidence summary |

## 6. Display Evidence Event Naming Rule

Display evidence event names must follow this structure:

```text
customer_display_<action_or_state>