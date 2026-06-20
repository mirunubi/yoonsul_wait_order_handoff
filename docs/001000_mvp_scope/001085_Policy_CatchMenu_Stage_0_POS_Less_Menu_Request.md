# 001085_Policy_CatchMenu_Stage_0_POS_Less_Menu_Request.md

Legacy path: $old.

1\. Purpose

This document defines Stage 0 of CatchMenu.

Stage 0 is the POS-less and low-integration entry mode.

It supports stores that do not have POS, do not want POS integration, or only need a multilingual QR menu and lightweight menu request flow.

Stage 0 must be extremely easy for both guests and store owners.

The guest should be able to scan QR, view menu, select language, pre-select menu items, and either show the screen to staff or send a request to the store.

The store owner should be able to receive and confirm menu requests without installing POS, KDS, SMS, Kakao notification, or a required owner app.

2\. Core Principle

Stage 0 is not POS.

Stage 0 is not KDS.

Stage 0 is not payment.

Stage 0 is not a sales ledger.

Stage 0 is not a full order management system.

Stage 0 is a lightweight multilingual menu and menu request flow.

Core rule:

Guest request does not equal confirmed order.
Store confirmation does not equal POS order.
Store completion does not equal payment settlement.

Korean rule:

손님의 요청은 주문 확정이 아니다.
업주의 주문 확인은 POS 주문이 아니다.
완료 처리는 결제/정산 원장이 아니다.

3\. Stage 0 Substage Summary

Stage 0 is divided into three substages.

Stage 0A \= Multilingual QR Menu \+ Show-to-Staff View
Stage 0B \= Menu Request Sent to Store Owner Web Console
Stage 0C \= POS-less Simple Request Confirmation Board

Simple distinction:

0A \= 손님 휴대폰 안에서 직원에게 보여주기
0B \= 업주 웹 관리자 화면으로 요청 보내기
0C \= POS 없는 업주가 확인/완료 중심으로 요청 처리하기

4\. Stage 0A — Multilingual QR Menu \+ Show-to-Staff View

4.1 Definition

Stage 0A is the lightest CatchMenu mode.

The guest scans QR, selects a language, views the menu, selects items, and taps a button to show a Korean staff-view screen.

No request is sent to the store system.

No owner console is required.

No POS, KDS, payment, or waiting session is required.

4.2 Target Stores

Stage 0A is suitable for:

stores without POS
stores without waiting queue
stores with foreign guests
stores needing multilingual menu support
stores that only want QR menu board
stores that do not want digital order management
stores that want no installation burden

4.3 Guest Flow

1\. Guest scans QR.
2\. Guest selects language.
3\. Guest views menu in selected language.
4\. Guest selects menu items.
5\. Guest adds options, allergy notes, or requests if needed.
6\. Guest taps “Show Staff.”
7\. The webapp displays a Korean staff-read view.
8\. Staff reads the guest phone screen.
9\. Store handles the order manually.

4.4 Required Views

Stage 0A requires two views inside the guest webapp.

Guest Menu View
Staff Read View

Guest Menu View is shown in the guest-selected language.

Staff Read View is shown primarily in Korean.

4.5 Guest Menu View

Guest Menu View should include:

language selector
menu categories
menu item names in guest language
menu descriptions in guest language
ingredient/allergy information
price
quantity selector
option selector
request note input
selected menu cart
Show Staff button

Recommended button labels:

직원에게 보여주기
Show Staff
Mostrar al personal
スタッフに見せる
向员工出示

4.6 Staff Read View

Staff Read View is the key Stage 0A screen.

It allows the store owner or staff to read the guest’s selected menu in Korean.

Staff Read View should include:

guest language
selected menu items
quantity
option summary
allergy warning
special request
Korean translated summary
original guest-language text toggle
total estimated amount if available
not-confirmed-order notice

Required Korean notice:

이 화면은 주문 확정이 아닙니다.
직원이 확인 후 주문을 처리해주세요.

Required English notice:

This is not a confirmed order.
Staff must confirm before handling.

4.7 Stage 0A Modification Policy

Before the guest shows the Staff Read View, the guest may freely edit the selected menu.

After the guest shows the Staff Read View, modification is handled on the guest phone.

Normal modification routine:

Guest taps back
→ edits menu
→ taps Show Staff again
→ updated Korean staff-view screen is shown

Stage 0A does not support digital store-to-guest modification request.

If the store cannot accept the request, staff must explain verbally or through translated menu/request guidance.

4.8 Stage 0A Boundary

Stage 0A does not create a formal wait\_order\_session.

Stage 0A may create a temporary menu view session, but it must not be treated as a confirmed order.

Stage 0A does not require:

Store Console
owner app
POS
KDS
payment
SMS
Kakao notification
waiting queue
order ledger

4.9 Stage 0A Definition Statement

«Stage 0A is a multilingual QR menu mode where guests can prepare menu selections in their own language and show a Korean staff-read view to the store.»

5\. Stage 0B — Menu Request Sent To Store Owner Web Console

5.1 Definition

Stage 0B allows the guest to send a menu request to the store owner web console.

The store owner receives a Korean operational summary.

This stage adds communication between guest webapp and owner web console, but it still does not become POS, KDS, payment, or sales ledger.

5.2 Target Stores

Stage 0B is suitable for:

stores without POS integration
stores without POS
stores with foreign guests
stores that want to receive translated menu requests
stores that want owner phone/tablet request notification
stores that do not want SMS/Kakao cost
stores that do not want required owner app installation

5.3 Guest Flow

1\. Guest scans QR.
2\. Guest selects language.
3\. Guest views menu.
4\. Guest selects menu items.
5\. Guest enters allergy or request notes if needed.
6\. Guest taps “Send to Store” or “Request Order.”
7\. Store owner web console receives the request.
8\. Guest sees “Waiting for store confirmation.”

Recommended guest button labels:

매장에 보내기
주문 요청하기
Send to Store
Request Order

Avoid overly final labels such as:

Order Complete
Payment Complete
Confirmed Order

5.4 Owner Web Console

The owner web console should be browser-based by default.

Required owner view fields:

request number
received time
guest language
menu items in Korean
quantity
options
allergy warning
special request
original guest-language text
translated Korean summary
request version
review status

Default notification methods:

visual alert
sound alert if browser allows
new request badge
top warning area
highlighted request card

SMS/Kakao notification must not be a default dependency because it creates ongoing cost.

Owner app installation must not be required by default.

5.5 Stage 0B Modification Problem

Stage 0B must support modification because:

guest may choose the wrong item
guest may enter incorrect quantity
store may be out of ingredients
store may judge the menu unsuitable for the guest
allergy, spicy level, pork, alcohol, or dietary restrictions may require reconfirmation
translation may be ambiguous

5.6 Stage 0B States

Suggested states:

DRAFT
REQUESTED
UPDATED\_BY\_GUEST
STORE\_REVIEWING
CHANGE\_REQUESTED\_BY\_STORE
GUEST\_RECONFIRM\_REQUIRED
ACCEPTED
REJECTED
EXPIRED

5.7 Guest-Initiated Modification

Before the store starts review, the guest may edit the request.

The system must preserve request versions.

Example:

request v1
→ guest updates
→ request v2

Owner console must show:

손님이 요청을 수정했습니다.
최신 버전을 확인해주세요.

The owner console must always emphasize the latest version.

5.8 Store-Initiated Change Request

If the store cannot accept the request as-is, the store should not silently edit the guest request.

Store may choose:

품절
대체 제안
수량 변경 제안
알러지 재확인 요청
맵기 재확인 요청
식단/종교/재료 주의 안내
요청 거절

The guest receives the message in the selected language.

Examples:

This menu is currently unavailable.
Please choose another menu.

This menu is very spicy.
Would you still like to order it?

This menu may contain pork.
Please confirm before ordering.

This item may contain nuts.
Please confirm allergy risk.

5.9 Stage 0B Boundary

Stage 0B is still a request communication flow.

It does not mean:

order confirmed
payment completed
POS order created
kitchen started
benefit claimed

Stage 0B does not require:

POS
KDS
payment
owner app
SMS
Kakao notification

5.10 Stage 0B Definition Statement

«Stage 0B is a multilingual menu request flow where guests send selected menu requests to the store owner web console, and the store receives a Korean operational summary with modification/reconfirmation support.»

6\. Stage 0C — POS-less Simple Request Confirmation Board

6.1 Definition

Stage 0C is for POS-less or low-digital-skill store owners who want a very simple request confirmation board.

Stage 0C is not app payment.

Stage 0C is not POS replacement.

Stage 0C is not full order management.

Stage 0C is a lightweight request confirmation and cleanup flow.

6.2 Target Stores

Stage 0C is suitable for:

stores without POS
stores using cash/card terminal/bank transfer manually
small restaurants
food stalls
small tourist-heavy stores
low-digital-skill store owners
stores that need translated order requests but not full POS
stores that want a phone/tablet request board

6.3 Core Owner Actions

Stage 0C must minimize owner actions.

Primary required action:

주문 확인

Optional action:

완료

Secondary or hidden actions:

불가/품절
수정 요청
대체 제안
취소
상세 보기
미처리 만료

The normal owner should be able to operate Stage 0C with only:

주문 확인
완료

6.4 Meaning Of “주문 확인”

“주문 확인” is the most important Stage 0C action.

It means:

the store has seen the guest request
the store accepts responsibility to handle or resolve it
the guest request is locked
the guest can no longer freely edit it

Guest-facing message after store confirmation:

매장에서 주문 요청을 확인했습니다.
이제 직접 수정할 수 없습니다.
변경이 필요하면 직원에게 말씀해주세요.

English example:

The store has confirmed your request.
You can no longer edit it directly.
Please ask staff if you need a change.

6.5 Normal Guest Flow

1\. Guest scans QR.
2\. Guest selects language.
3\. Guest selects menu items.
4\. Guest sends request.
5\. Guest waits for store confirmation.
6\. Store taps “주문 확인.”
7\. Guest sees store confirmed message.
8\. Guest pays or receives food through the store’s existing offline method.

6.6 Normal Owner Flow

1\. New request arrives.
2\. Owner reads Korean summary.
3\. Owner taps “주문 확인.”
4\. Guest edit is locked.
5\. Owner handles order manually.
6\. Owner may tap “완료.”
7\. If owner does not tap “완료,” confirmed request may auto-complete by policy.

6.7 Payment Boundary

Stage 0C does not process app payment by default.

Payment happens through existing store methods:

cash
card terminal
bank transfer
in-person payment
existing store method

CatchMenu does not become payment ledger.

CatchMenu does not become sales ledger.

6.8 Normal Status Flow

Normal flow:

DRAFT
→ REQUESTED
→ STORE\_CONFIRMED
→ MANUAL\_COMPLETED

If owner does not tap 완료:

DRAFT
→ REQUESTED
→ STORE\_CONFIRMED
→ AUTO\_COMPLETED

At store closing:

DRAFT
→ REQUESTED
→ STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

Only confirmed requests may be auto-completed.

Unconfirmed requests must not be auto-completed as completed orders.

6.9 Guest Modification Policy

Before store confirmation:

guest may freely edit request
system preserves version
owner console shows latest version

After store confirmation:

guest cannot freely edit request
change requires staff/store handling

If store sends change request:

guest may edit within reopened change flow

6.10 Owner-Initiated Change

Owner may initiate change when:

menu is sold out
ingredient is unavailable
quantity cannot be served
menu is risky for guest
spicy level should be reconfirmed
allergy risk exists
translation is unclear

Owner actions:

불가/품절
수정 요청
대체 제안
손님 재확인 요청
요청 거절

The message should be shown to the guest in the guest-selected language.

7\. Stage 0C Auto Completion Policy

7.1 Why Auto Completion Is Needed

In POS-less and low-digital-skill stores, owners may not press 완료 after handling the request.

The system should not require perfect digital behavior.

Therefore, confirmed requests may be auto-completed.

7.2 Confirmed Requests Only

Only requests with this status may be auto-completed:

STORE\_CONFIRMED

Unconfirmed requests must never be auto-completed as completed orders.

7.3 Timeout Auto Completion

Default candidate:

STORE\_CONFIRMED \+ 60 minutes
→ AUTO\_COMPLETED

This duration should be configurable by store.

7.4 Closing Auto Completion

At store closing:

STORE\_CONFIRMED
→ CLOSE\_AUTO\_COMPLETED

7.5 Completion Reason

Completion should record reason:

manual\_completed
auto\_completed\_by\_timeout
auto\_completed\_by\_store\_closing

8\. Stage 0C Unconfirmed Request Policy

8.1 Core Rule

If the owner does not tap “주문 확인,” the system cannot know whether the request was handled.

Therefore unconfirmed requests must not be completed automatically.

They must be warned, escalated, or expired as unconfirmed.

8.2 30-Minute Warning

Rule:

REQUESTED \+ 30 minutes
→ UNCONFIRMED\_WARNING

Owner message:

30분 동안 확인하지 않은 주문 요청이 있습니다.
처리 여부를 확인해주세요.

Guest message should remain neutral:

매장 확인 대기 중입니다.

8.3 Top Warning

If there are unconfirmed requests, owner console must show a persistent top warning.

Example:

미확인 주문 요청 3건

When a new request arrives while older unconfirmed requests exist, the top warning should blink or visually emphasize the issue.

8.4 New Request Attention Rule

If unconfirmed requests exist and a new request arrives:

1 to 9 unconfirmed requests
→ warning only

Message:

이전 미확인 주문 요청이 있습니다.
먼저 확인하거나 정리해주세요.

This does not fully block operation when count is low.

8.5 Forced Cleanup Threshold

If unconfirmed requests reach or exceed 10:

unconfirmed\_request\_count \>= 10
→ forced cleanup screen before normal request handling

The owner must clean up or confirm old requests before continuing normal new request handling.

8.6 Forced Cleanup Screen

The forced cleanup screen should be simple.

Recommended actions:

선택 주문 확인
선택 완료 처리
선택 미처리 만료
상세 보기

Meaning:

선택 주문 확인 \= mark selected requests as STORE\_CONFIRMED
선택 완료 처리 \= owner confirms selected requests were handled offline
선택 미처리 만료 \= selected requests were not handled or are no longer valid

8.7 Closing Rule For Unconfirmed Requests

At store closing:

REQUESTED / UNCONFIRMED\_WARNING
→ UNCONFIRMED\_EXPIRED

Unconfirmed requests must not become completed unless owner explicitly marks them completed.

9\. Stage 0C Owner Console UX Rule

Stage 0C owner console must be designed for low-digital-skill owners.

Normal screen should not show too many buttons.

Normal new request card:

menu summary
allergy/request warning
주문 확인
불가/품절

Confirmed request card:

주문 확인됨
완료

Advanced actions should be hidden or secondary:

수정 요청
대체 제안
취소
상세 보기

Exception states may expose cleanup buttons.

10\. Notification Policy

Stage 0 should avoid ongoing-cost notification channels by default.

Default notification:

owner web console visual alert
sound alert if browser allows
highlighted request card
top warning badge

Optional paid or advanced notification:

SMS
Kakao
push notification
owner app notification

Default owner access:

smartphone browser
tablet browser
PC browser

Owner app is optional.

11\. Difference Between Stage 0A, 0B, And 0C

Substage| Core Meaning| Owner Screen| Request Sent| Processing Status| Payment
0A| guest shows Korean staff-view screen| No| No| No| Offline only
0B| guest sends request to owner web console| Yes| Yes| Review only| Offline only
0C| POS-less owner confirms and manages request simply| Yes| Yes| Confirm / complete / auto cleanup| Offline only

Simple summary:

0A \= 보여주기
0B \= 보내기
0C \= 확인하고 정리하기

12\. Relationship With Stage 1

Stage 0C and Stage 1 must not be confused.

Stage 0C \= POS 없는 업주용 요청 확인판
Stage 1 \= POS 있는 매장의 수동 POS Handoff

Stage 0C does not assume POS exists.

Stage 1 assumes POS exists but cannot integrate.

13\. Final Statement

CatchMenu Stage 0 is the lowest-friction adoption path.

It allows stores to start from a multilingual QR menu and grow into request transmission and POS-less request confirmation without requiring POS, KDS, payment, app installation, SMS, or Kakao notification.

Stage 0 must remain simple for guests and tolerant of low-digital-skill store owners.

Core rule:

0A \= show to staff
0B \= send to owner
0C \= owner confirms and simple-completes without POS
