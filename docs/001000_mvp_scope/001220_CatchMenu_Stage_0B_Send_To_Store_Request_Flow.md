# 001220_CatchMenu_Stage_0B_Send_To_Store_Request_Flow.md

1\. Purpose

This document defines the Stage 0B send-to-store request flow for CatchMenu.

Stage 0B allows the guest to scan a QR code, view the menu in a selected language, select items, and send a menu request to the store owner web console.

Stage 0B is not POS integration.

Stage 0B is not payment.

Stage 0B is not confirmed order authority.

Core purpose:

Let the guest send intent to the store.
Let the store see the request.
Do not pretend the request is a paid or confirmed order.

Korean purpose:

손님의 의사를 매장에 전달한다.
매장이 요청을 볼 수 있게 한다.
요청을 결제 완료 주문이나 확정 주문으로 오해하지 않는다.

2\. Stage 0B Definition

Stage 0B means:

Multilingual QR Menu
\+ Guest menu selection
\+ Send request to store
\+ Owner Web Console request view

Stage 0B does not include:

POS transaction creation
KDS handoff
payment completion
settlement
benefit grant
store confirmation board
guest edit lock after confirmation
automatic completion

Stage 0B is a request receive mode.

It helps the store receive the guest's selected menu and request memo.

3\. User Flow

Recommended Stage 0B flow:

Guest scans QR
→ Store menu opens
→ Guest selects language
→ Guest views menu
→ Guest selects items/options
→ Guest reviews request
→ Guest taps Send Request
→ Request is sent to owner web console
→ Store views request
→ Staff handles manually

The request may be used by staff to:

confirm verbally with guest
enter order into POS manually
tell kitchen manually
ask for clarification
mark as handled outside CatchMenu if supported

4\. Guest-Facing Flow

Guest-facing steps:

1\. Scan QR
2\. Choose language
3\. Select menu items
4\. Review selected items
5\. Send request to store
6\. Wait for staff confirmation
7\. Pay or order according to store process

Guest-facing text examples:

Send request to store
Your request has been sent
Please wait for staff confirmation
Please pay at store

Korean examples:

매장에 요청 보내기
요청이 매장으로 전송되었습니다
직원의 확인을 기다려주세요
결제는 매장에서 진행해주세요

5\. Request Sent Meaning

"REQUEST\_SENT" means:

the guest submitted selected menu information to the store console
the store may view the request
the request may help staff process the order manually

"REQUEST\_SENT" does not mean:

order confirmed
payment completed
POS transaction created
KDS ticket created
food preparation started
benefit granted

Core rule:

Request sent is communication.
Request sent is not transaction authority.

6\. Store-Facing Meaning

When a Stage 0B request appears in the owner web console, it means:

a guest has sent selected menu information
the request should be reviewed by store staff
critical requests should be checked
staff may manually proceed using the store's normal process

The owner console should not imply that:

the request is paid
the request is final
the POS has received the order
the kitchen has received the order
the guest cannot change anything

7\. Owner Web Console Request View

The owner web console request view should include:

request\_id
request\_time
store name
guest language
store language summary
selected items
quantity
options
special memo
critical request warnings
translation confidence
request status
request version

The view should make clear:

This is a guest request.
This is not a confirmed POS order.
Please confirm with guest or process manually.

Korean staff notice:

손님 요청입니다.
아직 POS 주문이나 결제 완료 상태가 아닙니다.
필요 시 손님과 확인 후 매장 절차에 따라 처리하세요.

8\. Korean Staff Summary

If the guest uses a foreign language, the request should include a Korean staff summary.

Example:

손님 요청:
\- 참치김밥 1개
\- 치즈김밥 1개
\- 매운 소스 제외
\- 땅콩 알러지 주의

주의:
자동 번역 요약입니다.
알러지/특이 요청은 손님과 확인해주세요.

The Korean summary should be structured where possible.

Structured data is safer than free-text translation.

9\. Original Guest Text Preservation

The request should preserve original guest-language text when the guest enters a memo or custom request.

This helps with:

translation review
support review
staff reconfirmation
critical request handling
dispute prevention

The owner console may show:

Korean summary
original guest memo
structured menu item
structured option
critical warning tags

10\. Critical Request Handling

Stage 0B must handle critical requests carefully.

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

If a critical request is detected, the request view should show a warning.

Example:

중요 요청입니다.
자동 번역만 믿지 말고 손님과 확인해주세요.

Critical request detection must not silently mark the request as safe.

11\. Request Versioning

Before the store handles the request, the guest may edit and resend.

Each resend should create a new request version.

Suggested version fields:

request\_id
request\_version
previous\_version
version\_created\_at
version\_created\_by
change\_reason
is\_current\_version

Core rule:

Do not silently overwrite guest intent.
Preserve request versions.

The owner console should clearly indicate the latest version.

Older versions may remain available for support review.

12\. Guest Edit Policy

In Stage 0B, guest edit may be allowed until the store begins handling or the request expires.

Possible edit states:

REQUEST\_SENT
REQUEST\_UPDATED
STORE\_VIEWED
STORE\_HANDLED\_MANUALLY
REQUEST\_EXPIRED

If the store has viewed or started handling the request, the UI may show:

Your request may already be seen by staff.
Please ask staff if you need changes.

Korean:

매장에서 이미 요청을 확인했을 수 있습니다.
변경이 필요하면 직원에게 말씀해주세요.

Stage 0B does not have the stronger "GUEST\_EDIT\_LOCKED" policy of Stage 0C unless the store explicitly confirms handling through a configured action.

13\. Request Statuses

Suggested Stage 0B statuses:

REQUEST\_READY
REQUEST\_SENT
REQUEST\_UPDATED
STORE\_VIEWED
STORE\_RECONFIRM\_REQUIRED
STORE\_HANDLED\_MANUALLY
REQUEST\_EXPIRED
SUPPORT\_REVIEW\_REQUIRED

These statuses do not equal POS or payment states.

Status boundary:

Stage 0B request status is communication state.
It is not POS transaction state.
It is not payment state.

14\. Store Viewed State

"STORE\_VIEWED" means the store console displayed the request or an authorized store user opened it.

"STORE\_VIEWED" does not mean:

order confirmed
payment completed
food preparation started
guest edit locked
POS entered

The UI should avoid overclaiming.

Possible merchant-facing label:

요청 확인함

Possible guest-facing message:

The store may have seen your request.
Please wait for staff confirmation.

15\. Store Reconfirm Required

Store reconfirmation may be required when:

allergy request exists
low translation confidence
menu item sold out
option unavailable
quantity unavailable
request memo is unclear
price may vary
guest changed request after sending
staff needs verbal confirmation

Status:

STORE\_RECONFIRM\_REQUIRED

The request should not proceed as safe without reconfirmation.

16\. Manual Handling

In Stage 0B, store handling remains manual.

Manual handling may include:

staff confirms verbally with guest
staff enters POS manually
staff tells kitchen manually
staff marks request handled if UI supports it
staff asks guest to reorder or clarify

Boundary:

Manual handling may complete the store's real operation.
But CatchMenu Stage 0B does not automatically know POS/payment completion.

If the store marks "STORE\_HANDLED\_MANUALLY", that means only that staff handled the request according to store process.

It does not prove payment or settlement.

17\. Request Expiration

A Stage 0B request may expire if not handled within the configured time.

Expiration may depend on:

business hours
request age
store closing time
manual cleanup
support policy

"REQUEST\_EXPIRED" means:

the request is no longer active in CatchMenu Stage 0B flow

It does not mean:

the guest was served
the guest paid
the store rejected the guest

18\. Notification Policy

Stage 0B may support owner console notifications.

Notification options may include:

browser sound
top banner
owner console badge
SMS option
Kakao option
push option
email option

Notification is not the source of truth.

Core rule:

Notification failure must not erase the request.
Owner console request list remains the operational reference.

If notification fails, the system should create a support signal or failure event if configured.

19\. Owner Console Failure

If owner console is unavailable, the request may not be safely delivered to staff.

Possible handling:

show guest fallback message
queue request if safe
show store unavailable message
ask guest to show staff directly
create support signal

Guest-facing fallback:

The store request screen may not be available.
Please show this screen to staff.

Korean:

매장 요청 화면 연결이 원활하지 않을 수 있습니다.
이 화면을 직원에게 보여주세요.

20\. Request Delivery Failure

If sending the request fails, the system must not pretend the request was sent.

Failure message should be clear.

Guest-facing message:

Request could not be sent.
Please show this screen to staff.

Korean:

요청을 매장에 보내지 못했습니다.
이 화면을 직원에게 보여주세요.

Internal failure should create a typed failure event.

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

21\. Evidence Boundary

Stage 0B has more evidence than Stage 0A because a store-side request may be created.

Possible evidence:

request\_id
request\_version
request\_sent\_at
guest\_language
store\_language summary
selected items
critical request flags
translation confidence
store viewed event
notification attempt
delivery failure event
request expiration event

Evidence must not become mutation authority.

Core rule:

Evidence explains what happened.
Evidence does not approve what should happen.

22\. Support Signal Policy

Stage 0B may create support signals for:

REQUEST\_SEND\_FAILED
OWNER\_CONSOLE\_UNAVAILABLE
OWNER\_CONSOLE\_ALERT\_DELIVERY\_FAILED
LOW\_CONFIDENCE\_TRANSLATION
CRITICAL\_REQUEST\_DETECTED
REQUEST\_VERSION\_CONFLICT
STORE\_RECONFIRM\_REQUIRED
REQUEST\_EXPIRED\_WITHOUT\_VIEW

Support signal should include:

signal\_id
signal\_type
tenant\_id
store\_id
request\_id
request\_version
severity\_hint
created\_at
evidence\_packet\_ref if available

Raw sensitive data should not be pushed.

Detailed evidence should be pulled through the Support Gateway when needed.

23\. Privacy And Data Boundary

Stage 0B should collect only what is needed to process and support the request.

Avoid collecting:

unnecessary guest personal identity
raw payment data
unrelated device tracking
private contact information
external membership data

Allowed operational context:

guest session id
store id
request id
language
selected items
critical flags
request memo
request timestamps
device/browser hint for troubleshooting

24\. Relationship To Stage 0A

Stage 0B extends Stage 0A.

Stage 0A:

guest selects menu
guest shows staff
no store-side request

Stage 0B:

guest selects menu
guest sends request to store
owner console may display request
staff handles manually

Migration from Stage 0A to 0B requires:

owner console readiness
request delivery readiness
staff guidance
fallback message
support signal coverage

25\. Relationship To Stage 0C

Stage 0B does not provide full request confirmation board behavior.

Stage 0C adds:

store confirmation action
guest edit lock after confirmation
unconfirmed warning
forced cleanup
confirmed auto-completion candidate
unconfirmed auto-completion prohibition

Stage 0B may later migrate to Stage 0C when the store wants explicit request confirmation and board management.

26\. Guest-Facing Do And Do Not

Guest-facing screen may say:

Your request has been sent.
Please wait for staff confirmation.
Please pay at store.
Please ask staff if you need changes.

Guest-facing screen must not say:

Your order is confirmed.
Your payment is complete.
Kitchen has started.
Your benefit is granted.

unless the relevant authority exists.

27\. Merchant-Facing Do And Do Not

Merchant-facing screen may say:

신규 요청
요청 확인
손님 요청 요약
직원 확인 필요
수동 처리 필요
재확인 필요
요청 만료

Merchant-facing screen must not imply:

자동 POS 입력 완료
자동 결제 완료
자동 주방 전달 완료
자동 혜택 지급 완료

28\. Final Statement

Stage 0B lets the guest send menu intent to the store owner web console.

It improves communication but does not create POS, KDS, payment, settlement, or benefit authority.

Final rule:

Stage 0B sends request.
Stage 0B does not confirm order.
Stage 0B does not complete payment.
Stage 0B does not touch POS.
Stage 0B does not touch KDS.
Stage 0B leaves store handling manual.
