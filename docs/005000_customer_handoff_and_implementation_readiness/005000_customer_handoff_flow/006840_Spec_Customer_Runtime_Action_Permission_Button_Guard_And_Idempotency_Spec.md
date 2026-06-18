# 006840_Spec_Customer_Runtime_Action_Permission_Button_Guard_And_Idempotency_Spec

## 1. Purpose

This specification defines the Customer Runtime action permission, button guard, and idempotency rules.

The purpose is to ensure that every customer-facing button, link, tap action, confirmation, submission, payment attempt, recovery action, support request, coupon use, arrival confirmation, and account claim is permitted only when the current runtime state, customer scope, token scope, and evidence requirements allow it.

A customer action is not just a UI event.

It may create waiting state, confirm arrival, submit preorder, create order, start payment, retry payment, apply coupon, claim account ownership, open support case, request refund, reopen dispute, or recover a session.

Therefore, every customer action must be:

- Runtime-authorized
- Surface-authorized
- Customer-scoped
- Token-scoped where required
- Idempotency-protected
- Duplicate-safe
- Evidence-backed
- Privacy-safe
- Payment-safe
- Rollout-controlled

## 2. Scope

This specification covers:

- Customer action permission registry
- Button/action guard model
- Runtime state permission
- Surface permission
- Token and session scope permission
- Guest/account action permission
- Waiting action permission
- Table action permission
- Cart/order/preorder action permission
- Payment action permission
- Refund/cancel request action permission
- Coupon/benefit action permission
- Support action permission
- Privacy-sensitive action permission
- Recovery action permission
- Duplicate prevention and idempotency
- Action evidence
- Blocking and defect routing

This specification does not define final button design, component styling, frontend framework code, payment provider API logic, full IAM implementation, or final legal consent wording.

## 3. Baseline Dependency

This specification depends on:

`006830_Spec_Customer_Runtime_Display_Status_Code_Registry_And_UI_State_Binding_Spec.md`

It implements action and button behavior from:

`006770_Template_Customer_Runtime_Display_Status_Code_Action_Permission_Message_Binding_And_Evidence_Template.md`

It must remain consistent with:

`006760_Matrix_Customer_Runtime_Display_Surface_Status_Action_Message_And_Evidence_Control_Matrix.md`

`006750_Register_Customer_Runtime_Message_Template_Translation_Status_Wording_And_Customer_Display_Control.md`

`006700_Template_Customer_Runtime_Event_Audit_Evidence_Field_Specification_Template.md`

## 4. Core Principle

A visible button is an implied permission.

If the customer can see, press, scan, submit, confirm, retry, claim, pay, cancel, recover, or reopen something, the system must be able to prove that the action was allowed at that exact state and scope.

Every customer action must pass four checks:

1. **Display Check** — Is the action visible on this display status and surface?
2. **Permission Check** — Is the action allowed for this customer/session/account/token?
3. **State Check** — Is the current runtime state still valid at action time?
4. **Idempotency Check** — Can repeated submission be safely deduplicated or blocked?

The render-time check is not enough.  
The submission-time check is mandatory.

## 5. Action Code Naming Rule

Action codes must follow this structure:

```text
ACT_<DOMAIN>_<VERB_OR_MEANING>