# 001092_Policy_CatchMenu_Guest_And_Merchant_Positioning

Legacy path: $old.

1\. Purpose

This document defines the positioning of CatchMenu for two different audiences.

The project has two different customer layers:

SaaS Customer \= store owner / operator / franchise HQ / tenant
End User \= guest / diner / visitor / general customer

The service name and experience must be easy for guests.

The product value and performance explanation must be clear for store owners.

This document separates guest-facing positioning from merchant-facing positioning.

2\. Core Principle

CatchMenu must speak two different languages.

For guests, CatchMenu should feel simple:

scan QR
view menu
pick menu
show staff
send request
continue after arrival or seating

For merchants, CatchMenu should explain operational value:

reduce order delay
reduce staff explanation load
support foreign guests
prevent handoff loss
support manual POS input
support kitchen visibility
connect POS/KDS when possible
support benefit routing in SaaS mode

Core rule:

«Guest-facing language must be simple and action-oriented.
Merchant-facing language must show operational value and performance.»

3\. Naming Boundary

The temporary guest-facing working name is:

CatchMenu / 캐치메뉴

CatchMenu is currently used because it is easier than the previous internal nickname and follows the familiar mental model of CatchTable.

However, CatchMenu is not yet confirmed as:

final trademark
official patent title
official SaaS product name
final public brand

Formal technical name:

Wait Order Handoff Runtime

Korean formal technical description:

대기-주문 준비-입장 핸드오프 시스템

Repository/project name:

yoonsul\_wait\_order\_handoff

Previous internal nickname:

자리찜 / Jarijjim

Jarijjim is deprioritized for now.

4\. Why CatchMenu Works For Guests

CatchMenu is relatively easy for both Korean and foreign guests.

Reasons:

Catch \= familiar from CatchTable-like waiting/reservation context
Menu \= universally understood restaurant word
CatchMenu \= suggests catching/selecting menu before ordering

CatchMenu can cover:

QR menu
multilingual menu
menu pre-selection
show-to-staff
send request to store
mini-kiosk-like lightweight behavior

However, CatchMenu must not be explained to guests using technical words.

Avoid guest-facing terms:

handoff
runtime
adapter
POS integration
KDS integration
SaaS
tenant
Mini KDS
ledger

5\. Guest-Facing Positioning

Guest-facing CatchMenu should answer one question:

«What should I do now?»

Guests should immediately understand that they can:

scan QR
view menu
choose language
pick menu
show staff or send request
continue order at the store

Recommended guest-facing concepts:

메뉴 미리담기
대기 중 메뉴담기
입장 전 메뉴보기
직원에게 보여주기
매장에 보내기
앱 설치 없이 이용

English-friendly guest concepts:

Scan QR
View menu
Pick menu
Show staff
Send to store
No app required

6\. Guest-Facing Signage Principles

CatchMenu may often be represented by a small sign, sticker, QR stand, or simple table/entrance notice.

It must not depend on customers already knowing what the service is.

Therefore, signage must include both:

service name
action instruction

A name alone is not enough.

Bad signage:

CatchMenu

Better signage:

CatchMenu
QR로 메뉴를 보고 미리 담아두세요.
앱 설치 없이 이용 가능합니다.

Even better for foreign guests:

CatchMenu
Scan QR · Pick Menu · Show Staff
No app required

7\. Guest-Facing Message Examples

7.1 Basic Korean

캐치메뉴

기다리는 동안 메뉴를 미리 담아두세요.
입장하면 직원에게 바로 보여주시면 됩니다.
앱 설치 없이 QR로 이용 가능합니다.

7.2 Very Short Korean

캐치메뉴

QR로 메뉴 보고
미리 담고
직원에게 보여주세요.

7.3 Stage 0A Korean

캐치메뉴

외국어 메뉴를 보고 고른 뒤,
직원에게 한국어 화면을 보여주세요.

7.4 Stage 0B Korean

캐치메뉴

메뉴를 고른 뒤 매장에 보내주세요.
매장이 확인하면 안내가 표시됩니다.

7.5 Stage 0C Korean

캐치메뉴

메뉴 요청을 보내면 매장이 확인합니다.
결제는 매장에서 진행됩니다.

7.6 English

CatchMenu

Scan QR
Pick your menu
Show staff or send to store
No app required

7.7 Foreigner-Focused English

CatchMenu

Choose your language.
Pick your menu.
Show the Korean summary to staff.
No app required.

8\. Guest-Facing Button Labels

Button labels must avoid implying confirmed order or completed payment unless that is true.

8.1 Safe Guest Buttons

메뉴 담기
직원에게 보여주기
매장에 보내기
주문 요청하기
수정하기
다시 선택하기
직원에게 문의하기

English:

Add Menu
Show Staff
Send to Store
Request Order
Edit
Choose Again
Ask Staff

8.2 Risky Guest Buttons

Avoid unless POS/payment confirmation is integrated:

주문 완료
결제 완료
주문 확정
조리 시작

English:

Order Complete
Payment Complete
Confirmed Order
Start Cooking

9\. Guest Status Messages

Guest status messages must be simple.

9.1 Before Sending

메뉴를 담아두었습니다.
직원에게 보여주거나 매장에 보낼 수 있습니다.

9.2 Sent To Store

매장에 요청을 보냈습니다.
매장 확인을 기다려주세요.

9.3 Store Confirmed

매장에서 주문 요청을 확인했습니다.
이제 직접 수정할 수 없습니다.
변경이 필요하면 직원에게 말씀해주세요.

9.4 Store Requested Change

매장에서 확인이 필요하다고 안내했습니다.
내용을 확인하고 다시 선택해주세요.

9.5 Sold Out

이 메뉴는 현재 준비할 수 없습니다.
다른 메뉴를 선택해주세요.

9.6 Offline Payment

결제는 매장에서 진행됩니다.

10\. Merchant-Facing Positioning

Merchant-facing CatchMenu should answer a different question:

«Why should I use this in my store?»

For merchants, CatchMenu should be positioned as:

waiting \+ menu pre-selection \+ staff handoff

or:

CatchTable-like waiting flow \+ Table Order-like menu flow \+ store handoff

Merchant-facing statement:

«CatchMenu helps guests prepare menu requests before ordering and helps stores receive that intent in Korean, reducing order delay, staff explanation burden, and handoff loss.»

11\. Merchant Value Proposition

CatchMenu offers different value depending on store capability.

11.1 For Stage 0 Stores

Value:

foreign guest menu support
QR multilingual menu
Korean staff-read screen
no app installation
no POS required
no KDS required
no SMS/Kakao cost by default

Merchant pitch:

POS 없이도 외국인 손님이 자기 언어로 메뉴를 보고,
업주는 한국어 요약으로 확인할 수 있습니다.

11.2 For Stage 1 Stores

Value:

waiting registration
menu pre-selection
manual POS input support
staff handoff screen
request/allergy visibility

Merchant pitch:

POS 연동 없이도 손님이 대기 중 메뉴를 미리 담고,
직원은 이를 보고 기존 POS에 수동 입력할 수 있습니다.

11.3 For Stage 2 Stores

Value:

Mini KDS
kitchen assist screen
reduced verbal handoff
allergy/request kitchen visibility
manual POS still preserved

Merchant pitch:

기존 POS는 그대로 두고,
주방에는 손님이 미리 고른 메뉴와 요청사항을 보여줄 수 있습니다.

11.4 For Stage 3 Stores

Value:

POS Adapter
order context transmission
POS reference
manual fallback
duplicate guard

Merchant pitch:

POS 연동이 가능한 매장은 손님의 준비 주문을 POS로 넘기고,
실패 시 수동 입력으로 전환할 수 있습니다.

11.5 For Stage 4 Stores

Value:

POS \+ KDS handoff
KDS reference
ready status
handoff completion
manual recovery

Merchant pitch:

대기 중 만들어진 주문 맥락을 POS와 KDS까지 이어주어,
입장·주문·주방 전달 흐름을 끊기지 않게 연결합니다.

11.6 For Stage 5 Tenants

Value:

SaaS tenant policy
white label integration
identity link
benefit routing
claim token
duplicate guard
external membership connector

Merchant pitch:

프랜차이즈나 다점포 브랜드는 매장별 연동 수준에 맞춰
대기·주문 준비·혜택·멤버십 흐름을 SaaS로 관리할 수 있습니다.

12\. Merchant Objection Handling

12.1 “Do I Need POS Integration?”

Answer:

아닙니다.
0단계와 1단계는 POS 연동 없이 시작할 수 있습니다.
POS가 있으면 직원이 수동으로 입력하고,
POS가 없으면 업주 웹화면에서 요청을 확인할 수 있습니다.

12.2 “Do Guests Need To Install An App?”

Answer:

아닙니다.
기본은 QR 웹앱입니다.
손님은 앱 설치 없이 메뉴를 보고 요청하거나 직원에게 보여줄 수 있습니다.

12.3 “Do I Need To Install An Owner App?”

Answer:

기본은 업주 웹 관리자 화면입니다.
휴대폰, 태블릿, PC 브라우저에서 사용할 수 있습니다.
앱은 안정적인 알림이나 고정 운영이 필요할 때 선택할 수 있습니다.

12.4 “Do I Need Kakao Or SMS Notification?”

Answer:

기본은 카카오/문자 알림이 아닙니다.
비용이 발생하지 않도록 웹화면 알림, 소리, 배지, 상단 경고를 기본으로 합니다.
카카오/문자는 선택형 유료 알림 채널로 둘 수 있습니다.

12.5 “Is This A Kiosk?”

Answer:

하드웨어 키오스크가 아닙니다.
손님은 QR로 메뉴를 보고 미리 담거나 매장에 요청을 보냅니다.
필요한 경우 키오스크처럼 가볍게 작동하지만, 별도 기기를 강제하지 않습니다.

12.6 “Is This POS?”

Answer:

POS가 아닙니다.
POS가 있는 매장은 기존 POS를 그대로 사용합니다.
POS 연동이 가능한 경우에만 Adapter로 연결합니다.

13\. Guest vs Merchant Language

The same function should be described differently.

Function| Guest Language| Merchant Language
multilingual menu| 원하는 언어로 메뉴 보기| 외국인 응대 부담 감소
pre-selection| 메뉴 미리담기| 입장 후 주문 지연 감소
show-to-staff| 직원에게 보여주기| 번역된 주문 요약 제공
send request| 매장에 보내기| 업주 웹 관리자 요청 수신
store confirmation| 매장 확인 중| 주문 확인으로 요청 잠금
Mini KDS| not shown to guest| 주방 보조 화면
POS Adapter| not shown to guest| POS 연동 / 수동 fallback
Benefit Routing| 혜택 확인| claim token / duplicate guard

14\. Positioning By Physical Sign Type

14.1 Entrance Sign

캐치메뉴

대기 중 메뉴를 미리 담아두세요.
QR로 이용 가능합니다.

14.2 Table Sign

캐치메뉴

QR로 메뉴를 보고
직원에게 보여주세요.

14.3 Tourist-Friendly Sign

CatchMenu

Choose your language.
Pick your menu.
Show staff the Korean summary.

14.4 Waiting Area Sign

기다리는 동안 캐치메뉴

메뉴를 미리 보고 담아두시면
입장 후 주문이 더 빨라집니다.

14.5 POS-less Store Sign

캐치메뉴

QR로 메뉴 요청을 보내주세요.
매장이 확인 후 안내드립니다.
결제는 매장에서 진행됩니다.

15\. Tone Rules

Guest-facing tone:

short
friendly
action-based
no technical jargon
no pressure to install app
no implication of payment unless true

Merchant-facing tone:

operational
performance-oriented
stage-aware
integration-aware
honest about boundaries

Technical document tone:

precise
boundary-preserving
state-aware
ledger-aware
adapter-aware

BM/patent tone:

formal
system-oriented
broader than MVP
no casual nickname dependency

16\. Naming Candidate Policy

CatchMenu is the current temporary guest-facing working name.

However, the system should allow merchants to choose or customize the guest-facing label.

Possible labels:

캐치메뉴
메뉴 미리담기
대기 중 메뉴담기
입장 전 메뉴보기
Ready Menu
Ready Order
TableFlow

Store-specific signage may use:

CatchMenu powered by Yoonsul
메뉴 미리담기
QR Menu Request

The runtime remains the same even if the guest-facing label differs by store.

17\. Final Positioning Statement

CatchMenu is a guest-simple and merchant-useful menu request and wait-order handoff flow.

For guests, it should feel like:

Scan QR → View Menu → Pick Menu → Show Staff or Send to Store

For merchants, it should mean:

Less order delay
Less explanation burden
Better foreign guest support
Clearer staff handoff
Expandable POS/KDS/SaaS path

CatchMenu must remain easy to understand at the entrance, useful at the counter, and bounded in system ownership.
