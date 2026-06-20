# 006510_Policy_Entrance_Waiting_Assist_Device_Customer_Link_Web_App_Native_App_And_Order_Runtime_Boundary

## 1. Purpose
This policy defines the runtime boundary between the entrance waiting assist device, customer message link, web app, native app, waiting session, preorder session, POS handoff, and KDS visibility.

The entrance waiting assist device may be a store-owned old tablet, old smartphone, spare tablet, or future recommended entrance device.

The device exists only to help customers start the waiting flow when they do not want to scan QR, open a web app manually, or install an app first.

The service remains software-first.

The device is not a dedicated kiosk product.

## 2. Core Principle
The entrance device starts the customer journey.

The customer's own phone continues the customer journey.

The entrance device must not become the main order device.

The entrance device must not become a POS terminal.

The entrance device must not expose raw KDS, POS, payment, or staff operation state.

Core rule:

```text
Entrance Device = first input bridge
Customer Web App = no-install waiting and preorder channel
Native App = repeat-use, push, membership, and deeper customer channel
POS/KDS = controlled internal handoff boundary
```

## 3. Runtime Flow
```text
Store entrance
  -> store-owned old tablet / phone on entrance stand
  -> customer enters phone number
  -> waiting session is created or resumed
  -> message link is sent to the customer phone
  -> customer opens link on own phone
  -> customer chooses web app or native app
  -> customer checks waiting number and waiting order
  -> customer may optionally place preorder
  -> store / POS / KDS / staff confirmation occurs depending on integration mode
  -> customer is called, seated, handed off, or pickup-confirmed
```

## 4. Channel Classification
The system uses three customer-facing channels.

| Channel | Role | Required? |
| --- | --- | --- |
| Entrance Assist Device | Phone-number input bridge | Optional |
| Web App | No-install waiting and preorder continuation | Required |
| Native App | Deep customer engagement and repeat-use channel | Optional |

The web app must be sufficient for the basic customer journey.

The native app must improve continuity, not block the basic journey.

## 5. Entrance Assist Device Boundary
The entrance assist device may allow:

- phone number input.
- party size input.
- minimal consent confirmation.
- waiting registration.
- waiting session resume.
- staff call request.
- message resend request if allowed.
- QR/NFC fallback display if enabled.

The entrance assist device must not be used for:

- full account registration.
- full menu browsing unless explicitly approved.
- long cart editing.
- payment.
- POS order confirmation.
- KDS ticket confirmation.
- staff admin operation.
- customer data lookup.
- previous customer history display.

The entrance device must hand off to the customer's own phone as early as possible.

## 6. Message Link Rule
After phone number input, the system sends a message link.

The first link should open the web app.

The second option may guide the customer to the native app.

Recommended message structure:

```text
[캐치오더]
대기 등록이 완료되었습니다.
대기번호: 12번
현재 예상 대기시간: 약 18분

앱 설치 없이 대기 확인:
{web_link}

편하게 주문/알림 받기:
{app_link}
```

The message must not force app installation.

The message must not imply that preorder is mandatory.

The message must not expose internal waiting session identifiers.

## 7. Web App Boundary
The web app should support the no-install customer journey.

The web app may provide:

- 대기번호 확인.
- 대기 순서 확인.
- 예상 대기시간 확인.
- 호출 알림 확인.
- 대기 취소.
- 직원 호출 요청 if enabled.
- 메뉴 보기.
- 장바구니.
- 미리 주문하기.
- 주문 제출.
- 기본 고객용 주문 상태 확인.

The web app must be enough for:

```text
대기 등록 -> 대기 확인 -> 미리 주문 -> 호출 확인
```

The web app should not require account creation for the basic waiting flow.

The web app should not require native app installation for preorder.

## 8. Native App Boundary
The native app may provide all web app functions and additional continuity functions.

The native app may support:

- stronger push notification.
- customer login.
- member profile.
- coupon linkage.
- loyalty and benefit linkage.
- point linkage.
- previous order history.
- repeat order.
- favorite menu.
- store follow.
- subscription or recurring order linkage.
- richer customer-facing order progress.
- long-term customer identity.
- franchise benefit integration.

The native app exists to increase repeat usage.

The native app must not become a barrier to first use.

## 9. Preorder Policy
Preorder should be available through the web app.

If preorder is app-only, the entrance assist device fails to remove friction because the customer is forced into installation after already crossing the first waiting barrier.

Therefore:

```text
Waiting confirmation = web app required
Preorder = web app allowed
Native app = enhanced preorder and repeat-use experience
```

Preorder is optional.

Waiting registration must remain valid even when preorder is skipped.

## 10. Waiting And Preorder Separation
Waiting session and preorder session are separate but linkable.

Waiting registration does not mean order submission.

Order submission does not mean seating confirmation.

Preorder submission does not mean POS acceptance.

POS acceptance does not always mean KDS production.

Recommended state separation:

```text
WAITING_ENTRY_CREATED
WAITING_NOTIFICATION_SENT
CUSTOMER_LINK_OPENED
WAITING_ACTIVE
PREORDER_DRAFT_CREATED
PREORDER_SUBMITTED
STORE_REVIEW_REQUIRED
POS_HANDOFF_PENDING
ORDER_ACCEPTED
KDS_TICKET_PENDING
KDS_TICKET_CREATED
CUSTOMER_CALLED
CUSTOMER_SEATED
```

Each state must remain distinguishable.

## 11. Web App Preorder State
When the customer preorders through the web app, the system may create:

- cart session.
- preorder draft.
- submitted preorder.
- staff review request.
- POS handoff request.
- manual POS entry request.
- KDS pending request.

The exact downstream behavior depends on the integration mode.

Allowed integration modes:

```text
NO_POS_API_MANUAL_STAFF_ENTRY
POS_API_PENDING_HANDOFF
POS_SYNCED_ORDER
KDS_PENDING_TICKET
KDS_ACCEPTED_TICKET
PAYMENT_REQUIRED_BEFORE_CONFIRMATION
PAYMENT_AFTER_SEATING
```

This policy does not implement the integration.

It only defines the boundary.

## 12. KDS Visibility Boundary
The customer must not see raw KDS state.

KDS state must be translated into customer-safe service language.

Internal KDS/POS states may include:

```text
POS_HANDOFF_PENDING
ORDER_ACCEPTED
KDS_TICKET_CREATED
KITCHEN_ACCEPTED
COOKING
READY
DELAYED
REMAKE_REQUIRED
CANCELLED
```

Customer-facing states should be simplified:

```text
주문 확인 중
주문 접수 완료
조리 준비 중
조리 중
준비 완료
직원 확인 중
매장 문의 필요
```

The web app may show simplified status.

The native app may show richer customer-facing status.

Neither channel should expose raw KDS, POS, payment, retry, remake, or internal failure details.

## 13. Web App Versus Native App Difference
| Function | Web App | Native App |
| --- | --- | --- |
| 앱 설치 없이 이용 | Yes | No |
| 대기번호 확인 | Yes | Yes |
| 대기 순서 확인 | Yes | Yes |
| 호출 알림 확인 | Yes | Yes |
| 대기 취소 | Yes | Yes |
| 메뉴 보기 | Yes | Yes |
| 장바구니 | Yes | Yes |
| 미리 주문하기 | Yes | Yes |
| 주문 제출 | Yes | Yes |
| 기본 주문 상태 | Yes | Yes |
| 상세 푸시 알림 | Limited | Strong |
| 쿠폰/멤버십 | Limited | Strong |
| 이전 주문 | Limited | Strong |
| 반복 주문 | Limited | Strong |
| subscription linkage | Limited | Strong |
| point linkage | Limited | Strong |
| KDS 기반 진행 상태 | Simplified | Rich but customer-safe |
| 장기 고객 계정 | Limited | Strong |

The difference is not order availability.

The difference is continuity, identity, notification quality, membership, and depth of customer experience.

## 14. Customer Installation Policy
The system may recommend native app installation only after the customer has already received value.

Good timing:

- after waiting registration.
- after preorder submission.
- after first successful visit.
- after coupon offer.
- after repeat-visit benefit explanation.
- after customer chooses stronger push notification.

Bad timing:

- before waiting registration.
- before showing waiting number.
- before allowing preorder.
- before customer understands the value.
- when the customer is in a hurry at the entrance.

The entrance flow must not start with forced installation.

## 15. Message Failure Boundary
If the message fails, the waiting state and customer flow must remain recoverable.

Message failure does not automatically invalidate the waiting entry.

Possible recovery paths:

- re-enter phone number.
- resend message.
- staff manual confirmation.
- QR fallback.
- staff call.
- manual waiting list.
- temporary waiting number display.

Recommended state:

```text
WAITING_NOTIFICATION_FAILED
  -> STAFF_ASSIST_REQUIRED
  -> MESSAGE_RESEND_REQUESTED
  -> WAITING_NOTIFICATION_SENT
```

or:

```text
WAITING_NOTIFICATION_FAILED
  -> STAFF_MANUAL_WAITING_ENTRY_CONFIRMED
```

## 16. Duplicate Session Boundary
The same customer may enter through multiple paths.

Examples:

- entrance device phone number input.
- QR code scan.
- staff manual entry.
- app login.
- old message link.
- family member phone number.

The system must detect possible duplicates.

Duplicate detection may use:

- same store.
- same phone number.
- active waiting session.
- recent entry time.
- same party size.
- same customer link.
- same staff manual entry.

Duplicate handling should prefer session resume over new queue creation.

## 17. Privacy Boundary
The entrance assist device must not retain customer information on screen.

The web app and native app must respect separate consent types.

Separate consent categories:

- waiting notification consent.
- service message consent.
- preorder operation consent.
- payment consent if applicable.
- marketing consent.
- membership consent.
- app push consent.

Waiting notification consent must not be bundled with marketing consent.

Phone number display should be masked after submission.

Example:

```text
010-****-1234 번호로 대기 확인 링크를 보내드렸습니다.
```

## 18. Staff And System Responsibility Split
Staff is responsible for:

- helping customers use the entrance device.
- checking message failure.
- confirming manual fallback.
- handling confused customers.
- confirming seating or pickup reality.
- correcting wrong entries.
- preventing visible phone number exposure.

System is responsible for:

- creating waiting session.
- sending message link.
- validating phone format.
- preventing duplicate queue abuse.
- preserving waiting/order state separation.
- providing web app continuation.
- allowing optional app deep link.
- translating KDS/POS state into customer-safe language.
- logging relevant events.

## 19. Event And Audit Boundary
Recommended events:

```text
ENTRANCE_PHONE_INPUT_STARTED
ENTRANCE_PHONE_INPUT_SUBMITTED
WAITING_ENTRY_CREATED_FROM_ENTRANCE_DEVICE
WAITING_NOTIFICATION_REQUESTED
WAITING_NOTIFICATION_SENT
WAITING_NOTIFICATION_FAILED
CUSTOMER_WEB_LINK_OPENED
CUSTOMER_APP_LINK_OPENED
CUSTOMER_WAITING_STATUS_VIEWED
CUSTOMER_PREORDER_STARTED_FROM_WEB
CUSTOMER_PREORDER_STARTED_FROM_APP
CUSTOMER_PREORDER_SUBMITTED
POS_HANDOFF_PENDING
KDS_CUSTOMER_STATUS_TRANSLATED
DUPLICATE_WAITING_CANDIDATE_DETECTED
STAFF_MANUAL_RECOVERY_STARTED
STAFF_MANUAL_RECOVERY_COMPLETED
```

Audit must distinguish:

- customer action.
- staff action.
- system event.
- message delivery event.
- POS/KDS handoff event.
- customer-facing status translation.

## 20. Product Decision
The recommended product decision is:

```text
Web app can support preorder.
Native app enhances preorder and repeat use.
KDS/POS raw state is never exposed directly.
Customer-facing order progress is translated.
App installation remains optional.
```

This decision protects:

- customer conversion.
- low-friction waiting.
- app value proposition.
- KDS/POS safety.
- store operation control.
- future membership expansion.

## 21. Non-Implementation Boundary
This document does not implement:

- SMS vendor.
- Kakao vendor.
- push notification.
- app deep link logic.
- web app UI source.
- native app UI source.
- database schema.
- POS integration.
- KDS integration.
- payment flow.
- preorder logic.
- hardware manufacturing.
- final device procurement.
- legal retention policy.

This document only defines system runtime and channel boundary.

## 22. Final Rule
The entrance device removes the first barrier.

The web app removes the installation barrier.

The native app improves the repeat-use barrier.

Preorder should be possible in the web app.

Native app should provide richer continuity, push, membership, and history.

KDS and POS details must remain internal.

Customer-facing status must be translated into simple service language.

