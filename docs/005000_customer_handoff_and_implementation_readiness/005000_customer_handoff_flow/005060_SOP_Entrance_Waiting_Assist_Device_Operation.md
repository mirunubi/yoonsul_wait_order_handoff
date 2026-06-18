# 005060_SOP_Entrance_Waiting_Assist_Device_Operation

% root\docs\00001_Md_Rules.md %
% root\docs\00002_Naming_Rules.md %
% root\docs\00005_Document_Number_Index.md %

<< docs-only - entrance waiting assist device operation SOP >>

# 05060_SOP_Entrance_Waiting_Assist_Device_Operation

## 1. Purpose
This SOP defines the documentation-only operating procedure for an entrance waiting assist device used by store staff to help customers register waiting information and continue into menu browsing or preorder flow without requiring full kiosk, POS, payment, KDS, or hardware automation.

The goal is to reduce friction at the store entrance, especially for customers who are not comfortable scanning QR codes or typing long URLs, while preserving the MVP boundary of waiting registration, menu browsing, cart preparation, order candidate creation, seating/table match, and staff confirmation.

## 2. Scope
This SOP applies to a lightweight tablet or staff-facing assist device placed near the store entrance or host station.

In scope:

- Customer waiting registration support.
- Phone-number-based waiting lookup.
- Waiting order/status display.
- Optional transition to menu browsing and preorder preparation.
- Staff assistance request at the entrance.
- Operational guidance for stores using the flow as a mini kiosk substitute.

Out of scope:

- POS API integration.
- Payment settlement.
- KDS automation.
- Hardware procurement or device firmware.
- SMS/push implementation details.
- Membership, points, coupons, or CRM automation.
- AI recommendation or agent automation.

## 3. Operating Context
The entrance waiting assist device is not a standalone POS or kiosk. It is a guided access point for the existing wait-order handoff flow.

Typical deployment contexts:

- A host stand where staff can help first-time customers.
- A tablet placed near the waiting area.
- A store that wants menu browsing and preorder preparation but does not need a full waiting management installation.
- A store that wants customers to continue from ?? ?? to ?? ???? while waiting.

## 4. Device Role
The device acts as a shared entrance helper.

It may display:

- Store identity and language selection.
- ?? ?? start action.
- ???? input or lookup action.
- ?? ?? confirmation.
- ?? ???? entry point.
- ?? ?? action.
- QR handoff for customers who prefer to continue on their own phone.

The device must not be treated as a payment terminal, POS terminal, KDS screen, or automated store operation controller in the first MVP.

## 5. Customer Entry Flow
Recommended customer flow:

1. Customer arrives at the store entrance.
2. Customer sees the tablet or staff-guided assist screen.
3. Customer selects language if needed.
4. Customer starts ?? ??.
5. Customer enters ???? or asks staff for help.
6. System shows ?? ?? and waiting status.
7. Customer may continue to menu browsing.
8. Customer may create a cart and order candidate.
9. Staff seats customer and confirms the order candidate manually.

Sample Korean screen text:

```text
?????.
?? ??? ??????.

????? ?????
?? ??? ?? ??? ??? ? ????.

[?? ????]
[? ?? ??]
[?? ??]
```

## 6. Staff Assist Flow
Staff may use the device to help customers who cannot or do not want to scan QR/NFC/URL.

Staff guidance:

1. Confirm the customer wants to register waiting.
2. Ask for the minimum required information.
3. Help the customer enter ???? only when needed.
4. Confirm that ?? ?? completed successfully.
5. Show the ?? ?? screen to the customer.
6. Offer ?? ???? only as an optional continuation.
7. If the customer needs more help, use ?? ?? or direct staff support.

Staff must avoid entering unnecessary personal information or creating duplicate waiting records.

## 7. Phone Number Handling
???? is used only as a waiting lookup and contact key in the MVP boundary.

Operational rules:

- Use the minimum phone number information required for waiting registration.
- Do not expose full phone numbers on public-facing screens after registration.
- Mask displayed phone numbers where possible, for example `010-****-1234`.
- Do not use phone numbers for membership, marketing, CRM, or payment logic in this SOP.
- If a customer refuses phone number entry, staff may use the store's existing manual waiting method.

Example confirmation text:

```text
?? ??? ???????.
????: 12?
?? ????: ? 18?
????: 010-****-1234

[?? ????]
[??]
```

## 8. Waiting Status Display
The device may show a short waiting status screen after registration.

Recommended visible fields:

- Waiting number.
- Current ?? ??.
- Estimated waiting time if available.
- Store notice.
- Continue-to-menu action.
- Staff help action.

The status screen must avoid sensitive personal information and must not imply that seating is guaranteed until staff confirms seating.

## 9. Preorder Continuation
?? ???? is an optional continuation from waiting status into menu browsing and cart preparation.

Rules:

- The customer may browse ????-style menu content while waiting.
- The customer may prepare an order candidate through ????-style flow.
- The order candidate is not a paid order.
- The order candidate is not automatically sent to POS or KDS.
- Staff must review and confirm after seating or table assignment.
- POS input may remain manual.

Recommended wording:

```text
???? ?? ??? ?? ? ? ???.
?? ??? ?? ?? ? ?????.

[?? ????]
```

## 10. Staff Call Handling
?? ?? is a customer assistance action, not an automated dispatch system.

Recommended use cases:

- Customer cannot complete ?? ??.
- Customer wants to change phone number.
- Customer has accessibility or language support needs.
- Customer wants to cancel or confirm waiting status.
- Customer has a question before using ?? ????.

The MVP documentation should treat ?? ?? as a visible staff support cue only. It must not define push routing, staff assignment automation, or workforce management logic.

## 11. Language And Accessibility
The device should support simple multilingual entry where the store already provides menu/photo/option/multilingual UI.

Accessibility guidance:

- Use large readable buttons.
- Keep the first screen short.
- Avoid long paragraphs on the device screen.
- Provide clear back/cancel actions.
- Keep Korean text readable and uncorrupted.
- Do not require app installation.

Required customer-facing principle:

```text
? ?? ?? ?? ?? ???? ??? ? ? ????.
```

## 12. Store Setup Checklist
Before using the entrance assist device, store staff should confirm:

- The tablet is charged or connected to power.
- The correct store context is open.
- The screen shows the current store name.
- Language options display correctly.
- ?? ?? starts correctly.
- ???? input works in the expected format.
- ?? ?? confirmation is readable.
- ?? ???? opens the correct menu flow.
- ?? ?? or staff help guidance is visible.
- No payment, POS, or KDS automation is implied.

## 13. Daily Operation Checklist
Opening checklist:

- Confirm device network connectivity.
- Confirm brightness and screen lock settings.
- Confirm store context and menu availability.
- Confirm staff knows how to help customers from the entrance screen.

During operation:

- Keep the device in staff-visible range.
- Check for duplicate waiting registration issues.
- Help customers who hesitate at phone number entry.
- Remind customers that preorder is confirmed by staff.

Closing checklist:

- Return the device to charging location.
- Clear any visible customer information.
- Confirm no unresolved customer assistance screen remains open.

## 14. Error And Exception Handling
If registration fails:

- Staff should use the store's manual waiting method.
- Staff should not attempt to force repeated submissions.
- Staff should avoid collecting extra customer information.
- Staff may ask the customer to try QR/URL on their own phone.

If menu browsing fails:

- Waiting registration can still remain valid.
- Staff may guide the customer to paper menu or normal ordering.
- Order candidate creation should be skipped until the customer can browse reliably.

If the device is unavailable:

- The store can continue with normal waiting and manual ordering.
- The device is an assist surface, not a required operational dependency.

## 15. Evidence And Review
The SOP may be reviewed using operational evidence such as:

- Whether customers completed waiting registration faster.
- Whether fewer customers required staff to explain QR/URL entry.
- Whether more waiting customers entered menu browsing before seating.
- Whether order candidate review remained staff-controlled.
- Whether staff could recover cleanly when the device was unavailable.

This evidence is for operational review only and does not imply analytics, advertising, CRM, or AI recommendation implementation.

## 16. Non-Goals
This SOP explicitly excludes:

- Full kiosk implementation.
- POS settlement.
- Payment processing.
- KDS ticket creation.
- Inventory deduction.
- Membership points.
- Coupon issuance.
- Marketing consent flow.
- SMS/push infrastructure implementation.
- Hardware procurement or firmware specification.
- AI recommendation engine.
- Agent server automation.
- Complex multi-tenant SaaS architecture.

## 17. Related Documents
Related documentation:

- `005010_Guide_User_Flow.md`
- `005020_Readme_Stage_0.md`
- `005030_Policy_Stage_0A_QR_Menu_And_Show_To_Staff_Flow.md`
- `005040_Policy_Stage_0B_Send_To_Store_Request_Flow.md`
- `005050_Readme_Reservation_Preorder_Governance.md`

## 18. Governance Notes
This document is a docs-only SOP. It records operational policy for the entrance waiting assist device concept and does not authorize implementation work.

Any future implementation must be separately scoped, reviewed, and linked to the MVP boundary before code, database, messaging, payment, POS, KDS, or hardware work begins.
