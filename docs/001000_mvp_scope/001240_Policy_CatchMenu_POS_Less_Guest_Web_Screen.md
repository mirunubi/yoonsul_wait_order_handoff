# 001240_Policy_CatchMenu_POS_Less_Guest_Web_Screen

1\. Purpose

This document defines the guest-facing web screen policy for CatchMenu Stage 0\.

Stage 0 guest screens must support QR menu access, language selection, menu browsing, item selection, show-to-staff view, request sending, request status messaging, and safe fallback.

Guest screens must remain simple.

Guest screens must not expose internal runtime, gateway, POS, KDS, support, or evidence terminology.

Core purpose:

Make the guest flow simple.
Make the store context clear.
Make request status honest.
Do not expose internal system complexity.

Korean purpose:

손님 흐름은 단순하게 만든다.
매장 맥락은 명확하게 보여준다.
요청 상태는 과장 없이 정확하게 안내한다.
내부 시스템 복잡도는 손님에게 노출하지 않는다.

2\. Scope

This document covers Stage 0 guest-facing screens:

QR landing screen
language selection screen
menu list screen
menu detail screen
option selection screen
cart / selected items screen
show-to-staff screen
send request screen
request sent status screen
store confirmed status screen
guest edit locked screen
reconfirmation required screen
request expired screen
fallback screen

This document does not define:

owner web console
staff admin screen
POS screen
KDS screen
AI customer center screen
support operator screen
payment screen
membership app screen

3\. Core Principle

Stage 0 guest screens should explain what the guest can do now.

They should not explain the internal system.

Core rule:

Guest screen language must be action-oriented, not system-oriented.

Allowed guest-facing concepts:

view menu
choose language
select menu
show staff
send request
store confirmed
ask staff
pay at store
request expired

Avoid guest-facing concepts:

runtime
adapter
gateway
tenant
Evidence Packet
support signal
POS handoff
KDS adapter
Primary read
Secondary view
pgvector

4\. Store Context Display

Every guest-facing Stage 0 flow should make the store context visible.

The guest should be able to confirm:

store name
store branch or location hint if needed
business status if available
selected language
menu version or update hint if needed

Store context prevents:

wrong store QR confusion
wrong menu selection
wrong request destination
support dispute
merchant confusion

If store context is unclear, the screen should ask the guest to verify the store before proceeding.

Example:

You are viewing the menu for:
Yoonsul Haeundae Store

Korean:

현재 보고 있는 매장:
윤슬 해운대점

5\. QR Landing Screen

The QR landing screen should be minimal.

It should show:

store display name
language selection
no app required message
menu start button
basic store notice if needed

Recommended text:

No app required.
Choose your language to view the menu.

Korean:

앱 설치 없이 이용할 수 있습니다.
언어를 선택해 메뉴를 확인하세요.

The QR landing screen must not require account creation for Stage 0A / 0B / 0C basic use.

6\. Language Selection Screen

Language selection should be easy to find and change.

The screen should support:

default store language
guest selected language
language switch
critical translation caution if needed

Language switching should not erase selected items unless technically unavoidable.

If selected items may be reset, the guest must be warned.

Example:

Changing language may refresh menu text.
Your selected items will remain.

Korean:

언어를 변경하면 메뉴 문구가 새로 표시됩니다.
선택한 메뉴는 유지됩니다.

7\. Menu List Screen

The menu list screen should show:

menu categories
menu item name
short description
price
sold out or unavailable status
critical tags if needed
image optional

Menu list should avoid overcrowding.

The first goal is readability.

Recommended visible elements:

menu name
price
short description
key tags
add/select button

Optional elements:

image
calorie
spicy level
allergy icons
popular label
seasonal label

8\. Menu Detail Screen

The menu detail screen may include:

menu name
full description
price
option groups
quantity
allergy tags
spicy level
ingredient caution
language note
add to selected items button

Critical tags should be structured and visible.

Examples:

Contains pork
Contains seafood
Contains nuts
Spicy
Alcohol included

Korean:

돼지고기 포함
해산물 포함
견과류 포함
매운맛
알코올 포함

9\. Option Selection Screen

Option selection should be clear and limited.

Option groups may include:

quantity
spicy level
remove ingredient
add ingredient
size
temperature
sauce
side option

Critical options should not rely only on free text.

Structured options are preferred for:

allergy
pork
beef
seafood
nuts
alcohol
spicy level
vegetarian or vegan request

Core rule:

Critical requests should be structured before they are translated.

10\. Selected Items / Cart Screen

Stage 0 may use a selected items screen instead of calling it a cart.

Guest-facing labels may include:

Selected Menu
Your Selection
Review Request
Show Staff
Send Request

Avoid if payment is not enabled:

Checkout
Pay Now
Order Completed
Payment Completed

The selected items screen should show:

selected items
quantity
options
special memo
estimated total if available
store confirmation notice
pay-at-store notice

11\. Estimated Total Boundary

If Stage 0 shows an estimated total, it must not imply final payment.

Suggested wording:

Estimated total.
Final amount may be confirmed by the store.

Korean:

예상 금액입니다.
최종 금액은 매장에서 확인될 수 있습니다.

Core rule:

Displayed total is guidance.
Payment authority remains outside Stage 0\.

12\. Show-To-Staff Button

Stage 0A must provide a clear Show-to-Staff action.

Recommended labels:

Show Staff
Show this to staff
직원에게 보여주기

The button should be prominent.

The button should open a staff-readable summary screen.

The guest should understand that showing the screen does not mean payment or confirmed order.

13\. Show-To-Staff Screen

The Show-to-Staff screen should prioritize staff readability.

It should include:

store name
selected items
quantity
options
critical request warnings
special memo
Korean summary if staff language is Korean
original guest text if needed
not confirmed order notice

Notice example:

This screen is for staff confirmation.
This is not a paid order.

Korean:

직원 확인을 위한 화면입니다.
아직 결제 완료 주문이 아닙니다.

14\. Send Request Button

Stage 0B and Stage 0C may provide a Send Request button.

Recommended labels:

Send Request
Send to Store
매장에 요청 보내기

Before sending, the guest should see:

selected item summary
special request memo
critical warning confirmation if needed
pay-at-store notice

The button must not say:

Place Paid Order
Complete Payment
Send to POS
Send to Kitchen

unless those authorities exist in later stages.

15\. Request Sent Screen

After a request is sent, the guest screen should show a clear status.

Recommended message:

Your request has been sent to the store.
Please wait for staff confirmation.
Please pay at store.

Korean:

요청이 매장으로 전송되었습니다.
직원의 확인을 기다려주세요.
결제는 매장에서 진행해주세요.

The screen should not say:

Order confirmed
Payment completed
Kitchen started

16\. Store Confirmed Screen

In Stage 0C, the guest may see store confirmation.

Recommended message:

The store has confirmed your request.
You can no longer edit it directly.
Please ask staff if you need changes.

Korean:

매장에서 요청을 확인했습니다.
이제 직접 수정할 수 없습니다.
변경이 필요하면 직원에게 말씀해주세요.

Store confirmation must not imply payment completion.

17\. Guest Edit Locked Screen

When guest edit is locked, the screen should explain why.

Recommended message:

Your request was confirmed by the store.
Direct editing is no longer available.
Please ask staff for changes.

Korean:

매장에서 요청을 확인했습니다.
직접 수정은 더 이상 가능하지 않습니다.
변경이 필요하면 직원에게 말씀해주세요.

The screen should not create anxiety.

It should guide the guest to staff.

18\. Reconfirmation Required Screen

If reconfirmation is required, the guest screen should show a simple instruction.

Examples:

Staff needs to confirm part of your request.
Please ask staff.

Korean:

요청 내용 중 직원 확인이 필요한 부분이 있습니다.
직원에게 말씀해주세요.

Possible reasons:

allergy or dietary caution
low translation confidence
sold out item
unclear request
option unavailable

Guest screen should not expose internal severity labels unless needed.

19\. Request Expired Screen

If request expires, the message should be clear.

Recommended message:

This request is no longer active.
Please ask staff or send a new request.

Korean:

이 요청은 더 이상 활성 상태가 아닙니다.
직원에게 문의하거나 새로 요청해주세요.

For unconfirmed expiration, the screen must not imply the store completed the request.

20\. Fallback Screen

Fallback screens should be simple and action-oriented.

Examples:

Request could not be sent.
Please show this screen to staff.

Store request screen may not be available.
Please show this screen to staff.

Korean:

요청을 매장에 보내지 못했습니다.
이 화면을 직원에게 보여주세요.

매장 요청 화면 연결이 원활하지 않을 수 있습니다.
이 화면을 직원에게 보여주세요.

Fallback must not claim success.

21\. Critical Request Warning

Critical request warnings must be visible but not frightening.

Categories:

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

Guest-facing message:

This request may need staff confirmation.
Please tell staff if this is important.

Korean:

이 요청은 직원 확인이 필요할 수 있습니다.
중요한 내용이면 직원에게 꼭 말씀해주세요.

22\. Translation Confidence Warning

If translation confidence is low, the screen should not overclaim accuracy.

Guest-facing message:

Some translation may need staff confirmation.
Please show staff the original request if needed.

Korean:

일부 번역은 직원 확인이 필요할 수 있습니다.
필요하면 원문 요청을 직원에게 보여주세요.

23\. Guest Memo Policy

Guest memo should be supported carefully.

The UI should guide guests to write short, clear requests.

Examples:

No spicy sauce
No pork
Peanut allergy
Less salt
Separate sauce

For critical requests, structured option selection is preferred over free memo.

Core rule:

Free-text memo supports communication.
Structured critical tags support safety.

24\. No Account Required Message

Stage 0 basic use should not require account creation.

The guest screen may say:

No app required.
No sign-up required for menu viewing.

Korean:

앱 설치 없이 이용할 수 있습니다.
메뉴 확인에는 회원가입이 필요하지 않습니다.

If optional membership or benefit flow exists later, it must be clearly separated from the basic Stage 0 request flow.

25\. Browser And Device Support

Stage 0 guest web should support common mobile browsers.

Minimum expectations:

iOS Safari
Android Chrome
Samsung Internet
common QR scanner browser
basic responsive layout

The flow should tolerate:

page refresh
language switch
temporary network issue
screen lock
browser back navigation

State recovery depends on stage.

Stage 0A may be local.

Stage 0B/0C request status may require server-side recovery.

26\. Loading And Retry Messages

Loading messages should be clear.

Examples:

Loading menu...
Sending request...
Checking request status...

Korean:

메뉴를 불러오는 중입니다...
요청을 보내는 중입니다...
요청 상태를 확인하는 중입니다...

Retry messages should not duplicate requests silently.

Core rule:

Retry must not create duplicate request without version or idempotency protection.

27\. Duplicate Request Prevention

Guest screens should prevent accidental duplicate request sending.

Possible controls:

disable button while sending
idempotency key
request version
confirmation message
duplicate warning

If duplicate request is suspected, the guest should see:

This request may have already been sent.
Please check with staff before sending again.

Korean:

이 요청은 이미 전송되었을 수 있습니다.
다시 보내기 전에 직원에게 확인해주세요.

28\. Guest Privacy Boundary

Stage 0 guest screens should collect minimal data.

Do not require:

full name
phone number
email
address
payment credential
membership login

for basic Stage 0 menu viewing and request flow.

Allowed lightweight context:

guest session
language
selected items
request memo
device/browser hint for reliability

29\. Support Boundary

Guest screen may provide simple help.

Allowed help text:

If the request is unclear, ask staff.
If the screen does not work, show staff.
If you have allergies, tell staff directly.

Korean:

요청이 불명확하면 직원에게 말씀해주세요.
화면이 작동하지 않으면 직원에게 보여주세요.
알러지가 있다면 직원에게 직접 말씀해주세요.

Guest screen should not expose support case IDs by default unless needed.

30\. Analytics And Logging Boundary

Guest screen interactions may be logged for reliability and support.

Allowed events:

QR\_OPENED
LANGUAGE\_SELECTED
MENU\_VIEWED
ITEM\_SELECTED
SHOW\_TO\_STAFF\_OPENED
REQUEST\_SEND\_ATTEMPTED
REQUEST\_SENT
REQUEST\_SEND\_FAILED
REQUEST\_STATUS\_VIEWED

Logging must be privacy-safe.

Raw personal data should not be logged unless required by explicit feature and policy.

31\. Failure Message Policy

Guest-facing failure messages should be simple.

Internal diagnostic messages should be detailed.

Failure/error naming and diagnostic hierarchy are governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

Guest-facing example:

Request could not be sent.
Please show this screen to staff.

Internal diagnostic should preserve module, operation, request scope, and trace.

32\. Accessibility

Guest web screens should consider accessibility.

Recommended principles:

large buttons
readable font size
clear contrast
simple language
minimal steps
visible back navigation
critical warning clarity
screen reader-friendly labels where possible

33\. Guest Screen Do And Do Not

Guest screen may say:

View menu
Choose language
Select menu
Show staff
Send request
Store confirmed
Please ask staff
Please pay at store

Guest screen must not say without authority:

Order confirmed
Payment completed
POS accepted
KDS accepted
Food preparation started
Benefit granted
Refund approved

34\. Relationship To Stage 0A / 0B / 0C

Stage 0A guest screen:

menu view
selection
show-to-staff
no request sent

Stage 0B guest screen:

menu view
selection
send request
request sent status

Stage 0C guest screen:

menu view
selection
send request
store confirmed status
guest edit lock
request expiration or completion messaging

The screen must adapt to the store's enabled stage.

35\. Final Statement

Stage 0 guest web screens must make CatchMenu easy for guests without misrepresenting what the system has authority to do.

Final rule:

Simple for guests.
Accurate about status.
Clear about store context.
No false order confirmation.
No false payment claim.
No internal system leakage.
