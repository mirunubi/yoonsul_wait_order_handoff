# 006850_Spec_Customer_Runtime_Message_Template_Localization_Key_And_Versioning_Spec.md

## 1. Purpose

This specification defines the Customer Runtime message template, localization key, translation, and versioning rules.

The purpose is to ensure that every customer-facing message is controlled as a runtime artifact rather than unmanaged UI copy.

Customer-facing messages may affect waiting fairness, table assignment, order confirmation, payment truth, refund/cancel expectation, coupon/benefit trust, support outcome, privacy review, and rollout safety.

Therefore, every customer-visible message must be:

- Template-controlled
- Versioned
- Localization-keyed
- Surface-scoped
- Runtime-state-bound
- Action-bound where applicable
- Risk-classified
- Translation-reviewed
- Evidence-backed where required
- Blocked from unsafe wording
- Rollout-controlled

## 2. Scope

This specification covers:

- Message template registry
- Localization key naming
- Template versioning
- Translation versioning
- Surface-specific message variants
- Notification message variants
- Button label keys
- Safe block message keys
- Error and recovery message keys
- Payment/refund/cancel wording
- Support wording
- Privacy-sensitive wording
- Membership/benefit wording
- Translation review rules
- Blocked wording controls
- Message evidence
- Implementation and QA requirements

This specification does not define final brand tone, marketing campaign copy, legal terms of service, privacy policy text, full i18n implementation library, or final accessibility copy.

## 3. Baseline Dependency

This specification depends on:

`006840_Spec_Customer_Runtime_Action_Permission_Button_Guard_And_Idempotency_Spec.md`

It implements message and translation control from:

`006750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`

It must remain consistent with:

`006830_Spec_Customer_Runtime_Display_Status_Code_Registry_And_UI_State_Binding_Spec.md`

`006770_Template_Customer_Runtime_Display_Status_Code_Action_Permission_Message_Binding_And_Evidence_Template.md`

`006760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`

## 4. Core Principle

A customer message is a controlled runtime statement.

A message must not be written directly into customer UI if it affects:

- Runtime status
- Waiting or seating expectation
- Order acceptance
- Payment result
- Refund/cancel result
- Coupon/benefit state
- Support case outcome
- Privacy review
- Error/recovery path
- Customer action permission
- Rollout or incident restriction

Customer-facing text must resolve from approved message template and localization key.

## 5. Message Template Naming Rule

Message template IDs must follow this structure:

```text
MSG_<DOMAIN>_<MEANING>_<VARIANT>_v<MAJOR>