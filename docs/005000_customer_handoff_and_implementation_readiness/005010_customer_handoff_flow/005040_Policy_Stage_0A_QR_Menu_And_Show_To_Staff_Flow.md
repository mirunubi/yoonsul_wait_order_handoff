# 005030_Policy_Stage_0A_QR_Menu_And_Show_To_Staff_Flow

Legacy path: $old.

1\. Purpose

This document defines the Stage 0A flow for CatchMenu.

Stage 0A is the lightest CatchMenu entry mode.

In Stage 0A, the guest scans a QR code, views the menu in a selected language, selects items, and shows the selected menu screen to store staff.

No request is sent to the store system.

Core purpose:

Help guests understand the menu.
Help staff understand guest intent.
Do not create operational authority.

Korean purpose:

손님이 메뉴를 이해하게 돕는다.
직원이 손님의 의사를 이해하게 돕는다.
운영 권한을 생성하지 않는다.

2\. Stage 0A Definition

Stage 0A means:

Multilingual QR Menu
\+ Local menu selection
\+ Show-to-Staff View

Stage 0A does not include:

send request to store
owner web console request receive
store confirmation
guest edit lock
POS handoff
KDS handoff
payment
settlement
benefit routing
support case creation

Core rule:

Stage 0A stays on the guest side unless staff visually reads the screen.

3\. User Flow

Recommended Stage 0A flow:

Guest scans QR
→ Store menu opens
→ Guest selects language
→ Guest views menu
→ Guest selects items/options
→ Guest opens Show-to-Staff View
→ Guest shows screen to staff
→ Staff confirms verbally or manually handles order

No CatchMenu store request is created.

No owner console event is required.

No POS/KDS event is required.

4\. Guest-Facing Flow

Guest-facing steps:

1\. Scan QR
2\. Choose language
3\. View menu
4\. Select menu items
5\. Check selected items
6\. Show screen to staff
7\. Pay or order according to store process

Guest-facing text examples:

Scan QR to view menu.
Choose your language.
Select menu items.
Show this screen to staff.
Please order and pay at the store.

Korean examples:

QR을 스캔해 메뉴를 확인하세요.
언어를 선택하세요.
메뉴를 선택하세요.
이 화면을 직원에게 보여주세요.
주문과 결제는 매장에서 진행해주세요.

5\. Staff-Facing Meaning

When staff sees the Stage 0A screen, it means:

the guest selected menu items on their device
the screen is a communication aid
the selected items are not yet confirmed order records
staff must confirm details if needed

Staff should treat the screen as:

menu translation support
order communication support
foreign guest assistance
manual order input aid

Staff must not treat the screen as:

paid order
POS order
KDS ticket
confirmed store order
benefit claim
settlement record

6\. Show-To-Staff View

The Show-to-Staff View should be optimized for staff readability.

It should include:

store name
guest language
store language summary
selected items
quantity
options
critical request warnings
allergy/dietary warnings
special memo
total estimated amount if available
not confirmed order notice

The view should prioritize:

large text
simple item list
Korean summary for Korean staff
original guest language if useful
critical warnings highlighted

7\. Korean Staff Summary

If the guest used a foreign language, the Show-to-Staff View should show a Korean staff summary.

Example:

손님 선택 메뉴:
\- 참치김밥 1개
\- 매운맛 제외 요청
\- 땅콩 알러지 주의

주의:
이 화면은 주문 확정이 아닙니다.
직원이 손님과 확인 후 주문을 처리해야 합니다.

The Korean summary must not hide critical guest memo.

If translation confidence is low, the view should show caution.

번역 신뢰도가 낮습니다.
직원이 손님과 직접 확인해주세요.

8\. Original Language Preservation

The guest's original language text should be preserved when relevant.

This is important for:

translation review
staff reconfirmation
support evidence if logging is enabled
critical dietary requests
ambiguous custom request

Staff may need to compare:

Korean translated summary
guest original text
structured menu item
structured option
critical warning tag

9\. Critical Request Handling

Critical requests must be visible in Stage 0A.

Critical categories include:

allergy
cannot-eat ingredient
spicy level
pork
beef
seafood
nuts
alcohol
raw food
religious dietary restriction
vegetarian or vegan request
child or elderly consideration
medical caution
custom cooking request

Critical request warning example:

중요 요청입니다.
자동 번역만 믿지 말고 손님과 확인해주세요.

Stage 0A must not silently convert critical requests into safe assumptions.

10\. Local Selection Boundary

In Stage 0A, menu selection may remain local to the guest device.

Local selection means:

the guest selected items in the browser/app session
the selected items are not sent to store runtime
the store does not have a server-side request record
staff sees the selection only if guest shows the screen

Core rule:

Local selection is guest intent display.
It is not a store-side request.

11\. Optional Minimal Logging

Stage 0A may optionally log minimal anonymous usage events.

Allowed minimal events:

QR\_OPENED
LANGUAGE\_SELECTED
MENU\_VIEWED
SHOW\_TO\_STAFF\_OPENED

Optional logging should be privacy-safe.

Do not log detailed guest identity by default.

Do not require account login.

Do not create a support case by default.

12\. Stage 0A Request State

Stage 0A may use lightweight local or analytics states.

Suggested states:

MENU\_VIEWED
ITEMS\_SELECTED
SHOW\_TO\_STAFF\_READY
SHOWN\_TO\_STAFF

These states do not mean:

REQUEST\_SENT
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
POS\_HANDOFF\_READY
COMPLETED

State boundary:

Stage 0A states are visibility states, not transaction states.

13\. QR Code Requirements

Stage 0A depends on correct QR mapping.

QR code should resolve to:

correct store
correct menu
correct language selection screen
correct business status if available

QR scan landing page should show:

store display name
store location hint if needed
language selection
menu categories
no app required message

Wrong store QR is a high-risk issue.

If wrong store is suspected, the system should show a clear warning or require reconfirmation.

14\. Menu Display Requirements

Stage 0A menu should support:

category
menu name
menu description
price
image optional
option selection
quantity
allergy tags
spicy level
sold out status if available
language display

Menu content should avoid misleading translation.

For critical tags, structured metadata is preferred over free-text translation.

15\. Sold Out And Availability Boundary

Stage 0A may show sold out or unavailable status if the store maintains it.

If availability is not real-time, the guest-facing screen should avoid overclaiming.

Possible wording:

Availability may change.
Please confirm with staff.

Korean:

재고 상황은 매장에 따라 달라질 수 있습니다.
직원에게 확인해주세요.

16\. Price Boundary

Stage 0A may show menu price.

If price may vary by store, time, option, or manual handling, the screen should state that final price is confirmed at store.

Core rule:

Displayed price is menu guidance.
Final payment belongs to store/POS/payment authority.

17\. No App Required Principle

Stage 0A should work without app installation.

Guest should be able to:

scan QR
open web menu
choose language
select items
show staff

No account should be required for basic Stage 0A use.

No app install should be required for basic Stage 0A use.

18\. Accessibility And Readability

Stage 0A should be readable in real store conditions.

Consider:

large item text
clear quantity display
high contrast
short menu descriptions
easy language switching
large Show Staff button
staff-readable summary
critical warning visibility

The Show Staff button should be prominent.

Suggested button labels:

Show Staff
직원에게 보여주기

19\. Guest Edit Policy

Before showing staff, guest may freely edit local selection.

After showing staff, there is no system-level lock in Stage 0A.

The store must verbally confirm any final order.

Core rule:

Stage 0A has no store-side edit lock.
Any final change is handled manually between guest and staff.

20\. Staff Confirmation Policy

Staff should confirm important details manually.

Manual confirmation is especially required when:

critical allergy/dietary request exists
translation confidence is low
option is unclear
guest memo is ambiguous
price may vary
item availability is uncertain

Staff confirmation may be verbal, visual, or assisted by translation.

21\. Fallback Policy

If Stage 0A fails, fallback should be simple.

Examples:

QR scan fails
→ staff provides paper or wall menu

language selection fails
→ staff uses default menu or translation aid

menu display fails
→ staff handles order manually

Show-to-Staff View fails
→ guest shows selected items from normal menu screen

translation confidence low
→ staff reconfirms with guest

Fallback must not create false order completion.

22\. Support Policy

Stage 0A support issues may include:

QR access failure
wrong store QR
language selection failure
menu translation issue
menu item mismatch
price confusion
allergy warning issue
browser/device issue
guest confusion
staff misunderstanding

Support may use:

menu version
QR code reference
store context
language context
device context
support-safe screenshot if available

Support must not assume that a Stage 0A local selection became a store request.

23\. Evidence Boundary

Stage 0A usually has limited evidence because no store request is sent.

Possible support evidence:

QR code reference
store landing page
menu version
language selected
show-to-staff view opened event if logged
guest-provided screenshot
staff note

Evidence boundary:

No server-side request evidence exists unless Stage 0A logging is enabled.

24\. Failure Boundary

Stage 0A failures must remain modular.

Examples:

QR access failure must not affect owner console.
Menu translation failure must not create request.
Show-to-Staff failure must not trigger POS handoff.
Price display issue must not become payment authority issue.

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

25\. Migration From Stage 0A To Stage 0B

A store may move from Stage 0A to Stage 0B when it wants to receive guest requests digitally.

Required readiness:

owner web console
request receiving flow
request sent message
store language summary
staff process for request handling
support signal for failed request send

Migration must not reinterpret past Stage 0A local selections as store requests.

26\. Guest-Facing Do And Do Not

Guest-facing screen may say:

View menu in your language.
Select menu items.
Show this screen to staff.
Please order and pay at store.

Guest-facing screen must not say:

Your order is confirmed.
Your payment is completed.
Kitchen has accepted your order.
Your benefit has been granted.

unless the relevant authority exists in a later stage.

27\. Merchant-Facing Do And Do Not

Merchant/staff guidance may say:

손님이 선택한 메뉴를 확인하세요.
이 화면은 주문 확정이 아닙니다.
알러지/특이 요청은 반드시 확인하세요.
POS 입력은 직원이 직접 처리해야 합니다.

Merchant/staff guidance must not say:

자동 주문 완료
자동 POS 입력 완료
자동 결제 완료
자동 주방 전달 완료

28\. Final Statement

Stage 0A is the safest and lightest CatchMenu entry mode.

It supports multilingual menu understanding and guest-to-staff communication without creating store-side operational authority.

Final rule:

Stage 0A shows intent.
Stage 0A does not send request.
Stage 0A does not confirm order.
Stage 0A does not touch POS.
Stage 0A does not touch KDS.
Stage 0A does not touch payment.
