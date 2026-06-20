# 001070_CatchMenu_Service_Concept.md

Legacy path: $old.

1\. Purpose

This document defines the service concept of CatchMenu within the yoonsul\_wait\_order\_handoff project.

CatchMenu is the temporary guest-facing working name for the waiting and menu-preparation experience.

The formal technical runtime remains:

Wait Order Handoff Runtime

The repository/project remains:

yoonsul\_wait\_order\_handoff

CatchMenu is not yet confirmed as the final trademark, patent title, or official SaaS product name.

2\. Core Service Idea

CatchMenu combines a waiting/entry flow with a menu-order preparation flow.

From the guest perspective, CatchMenu should feel like:

waiting or entering the store
\+ scanning QR
\+ viewing the menu
\+ pre-selecting menu
\+ showing staff
\+ continuing order after arrival or seating

From the store owner perspective, CatchMenu is:

CatchTable-like waiting flow
\+ Table Order-like menu selection flow
\+ staff handoff
\+ optional POS/KDS integration
\+ SaaS benefit routing

Core statement:

«CatchMenu is not just a QR menu.
CatchMenu is not a full POS order system.
CatchMenu is a waiting-to-order-preparation flow that carries guest intent to store staff, POS, or KDS.»

3\. Why CatchMenu

The previous internal nickname was:

자리찜 / Jarijjim

However, Jarijjim feels limited to seat holding or waiting.

The actual product scope is broader:

waiting
menu viewing
menu pre-selection
arrival
seating
staff handoff
POS handoff
KDS handoff
benefit routing

CatchMenu is easier to understand because it follows the familiar market mental model of “CatchTable” while extending the flow to menu selection and order preparation.

CatchMenu also works reasonably well for foreign guests because:

Catch \= easy to recognize
Menu \= universally understood restaurant word
CatchMenu \= menu capture / menu selection / menu handling 느낌

4\. Guest-Facing Positioning

CatchMenu must be simple for general guests.

Guests should not need to understand:

handoff
runtime
POS
KDS
SaaS
adapter
tenant
Mini KDS
integration

Guest-facing language should focus on simple actions.

Recommended guest-facing phrases:

QR로 메뉴 보기
기다리는 동안 메뉴 미리담기
입장하면 직원에게 보여주기
앉으면 바로 이어 주문
앱 설치 없이 사용

English-friendly phrases:

Scan QR
View menu
Pick menu
Show staff
No app required

5\. Merchant-Facing Positioning

The SaaS customer is the store owner, operator, franchise HQ, or tenant.

For merchants, CatchMenu should be explained in operational value terms.

Merchant-facing value:

입장 후 주문 지연 감소
직원 메뉴 설명 부담 감소
외국인 응대 보조
대기 중 메뉴 선택 유도
POS 수동 입력 보조
주방 전달 누락 감소
테이블 회전 개선
대기 고객 이탈 감소
혜택/멤버십 연결 가능

Merchant-facing statement:

«CatchMenu connects waiting guests to order preparation before they are seated, reducing order friction and preserving guest intent during staff, POS, and KDS handoff.»

6\. CatchMenu Is Not A Hardware Kiosk

CatchMenu must not be positioned as a hardware kiosk.

Guests should not feel that they must install, learn, or operate a complicated kiosk system.

CatchMenu may perform some mini-kiosk-like roles through QR/web access, but the guest-facing positioning must remain lightweight.

Correct positioning:

QR menu
web menu
menu pre-selection
show-to-staff
continue order after arrival

Avoid guest-facing positioning:

Mini Kiosk
hardware kiosk
self-service machine
POS terminal
app installation required

7\. CatchMenu And Mini Runtime

Internally, CatchMenu may overlap with lightweight mini-runtime behavior.

However, the naming must remain separated.

Guest-facing:

CatchMenu
QR menu
menu pre-selection
show-to-staff

Internal/store-facing:

Customer QR Webapp
Order Preparation Flow
Store Wait Board
Staff Handoff
Mini KDS
Kitchen Assist
POS Adapter
KDS Adapter

Mini KDS remains store/kitchen-facing.

Mini Kiosk terminology should not be used as the primary guest-facing concept.

8\. Basic Guest Flow

The basic CatchMenu guest flow is:

1\. Guest sees CatchMenu sign or QR.
2\. Guest scans QR.
3\. Guest views the menu.
4\. Guest selects language if needed.
5\. Guest pre-selects menu items.
6\. Guest enters allergy or request notes if needed.
7\. Guest waits or enters the store.
8\. Guest shows the prepared menu to staff.
9\. Staff confirms the order context.
10\. Store continues through manual POS, POS Adapter, Mini KDS, or KDS Handoff depending on store capability.

9\. Basic Store Flow

The basic store flow is:

1\. Guest creates menu-preparation context.
2\. Store Wait Board receives the prepared context.
3\. Staff sees waiting/arrival/menu status.
4\. Staff confirms the guest and order context.
5\. Stage 1 store manually enters POS.
6\. Stage 2 store also uses Mini KDS or kitchen assist.
7\. Stage 3 store sends context to POS Adapter.
8\. Stage 4 store sends context to POS and KDS.
9\. Stage 5 tenant may route benefits or external membership claims.

10\. Relationship With Store Capability Stage

CatchMenu can appear differently depending on store capability.

Stage 0 \= CatchMenu as QR multilingual menu board
Stage 1 \= CatchMenu as waiting \+ menu pre-selection \+ manual POS handoff
Stage 2 \= CatchMenu \+ Mini KDS / kitchen assist
Stage 3 \= CatchMenu \+ POS Adapter
Stage 4 \= CatchMenu \+ POS/KDS integrated handoff
Stage 5 \= CatchMenu \+ SaaS / white label / benefit routing

CatchMenu should remain simple for guests even when the store-side runtime is complex.

11\. Stage 0 CatchMenu

At Stage 0, CatchMenu is only a QR menu and multilingual menu support flow.

It may include:

menu browsing
language selection
allergy/ingredient information
recommended menu
show-to-staff screen

It does not include:

waiting registration
wait\_order\_session
POS handoff
KDS handoff
benefit routing

12\. Stage 1 CatchMenu

At Stage 1, CatchMenu supports waiting and manual staff handoff.

It may include:

waiting registration
menu pre-selection
request/allergy input
show-to-staff screen
Store Wait Board
Staff Handoff
manual POS input summary

POS remains manual.

Staff enters the order into the existing POS.

13\. Stage 2 CatchMenu

At Stage 2, CatchMenu adds kitchen assistance through Mini KDS or a similar store-side preparation screen.

It may include:

prepared order queue
kitchen assist screen
simple grouping
allergy/request highlight
manual ready check
pickup/display support

The existing POS remains unchanged.

This is the first stage where our system enters the store-side kitchen/preparation flow.

14\. Stage 3 CatchMenu

At Stage 3, CatchMenu sends prepared order context to POS through a POS Adapter.

It may include:

POS handoff payload
POS reference
handoff success/failure
retry
manual fallback

KDS may be absent, POS-owned, external, or indirectly observed.

15\. Stage 4 CatchMenu

At Stage 4, CatchMenu connects both POS and KDS handoff.

It may include:

POS Adapter
KDS Adapter
external POS reference
external KDS reference
KDS visible status
ready status
handoff completion status
recovery handling

POS remains the transaction authority.

KDS remains the kitchen execution authority.

16\. Stage 5 CatchMenu

At Stage 5, CatchMenu becomes part of SaaS, white label, and benefit routing flows.

It may include:

tenant configuration
store capability profile
identity link
claim token
duplicate guard
external membership connector
webhook/API
white label app connection

CatchMenu remains the guest-facing experience, but SaaS customers and tenants configure the deeper runtime behavior.

17\. Naming Boundary

CatchMenu is a temporary guest-facing working name.

Do not treat it as final until trademark, service positioning, and patent naming are separately reviewed.

Naming distinction:

CatchMenu / 캐치메뉴
\= temporary guest-facing working name

yoonsul\_wait\_order\_handoff
\= repository / project name

Wait Order Handoff Runtime
\= formal technical name

대기-주문 준비-입장 핸드오프 시스템
\= Korean formal technical description

자리찜 / Jarijjim
\= previous internal nickname, currently deprioritized

18\. Guest Signage Examples

Example 1:

캐치메뉴

기다리는 동안 메뉴를 미리 담아두세요.
입장하면 직원에게 바로 보여주시면 됩니다.
앱 설치 없이 QR로 이용 가능합니다.

Example 2:

CatchMenu

Scan QR
Pick your menu
Show staff when seated
No app required

Example 3:

대기 중 메뉴 미리담기

QR로 메뉴 보고 담아두세요.
입장 후 바로 이어 주문할 수 있습니다.

19\. Merchant Explanation Example

For store owners:

캐치메뉴는 캐치테이블형 대기 흐름과 테이블오더형 메뉴 선택 흐름을 연결합니다.

손님은 대기 중 QR로 메뉴를 보고 미리 담아둘 수 있고,
직원은 Store Wait Board에서 준비 주문을 확인한 뒤 POS/KDS 흐름으로 이어받습니다.

POS 연동이 없는 매장은 수동 Handoff로 시작할 수 있고,
필요하면 Mini KDS, POS Adapter, KDS Adapter, 멤버십/혜택 연동까지 단계적으로 확장할 수 있습니다.

20\. Final Service Concept Statement

CatchMenu is a lightweight guest-facing waiting and menu-preparation experience.

It helps guests view and pre-select menu items before ordering.

It helps stores preserve guest intent and reduce order friction during arrival, seating, staff confirmation, POS handoff, and KDS handoff.

CatchMenu should feel simple to guests and operationally valuable to store owners.
