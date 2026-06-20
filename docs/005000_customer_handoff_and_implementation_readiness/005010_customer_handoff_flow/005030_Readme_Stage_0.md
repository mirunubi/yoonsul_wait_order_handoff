# 005030_Readme_Stage_0.md

Legacy path: $old.

1\. Purpose

This folder defines the Stage 0 entry runtime for CatchMenu.

Stage 0 is the lightweight adoption zone before POS integration, KDS integration, payment integration, settlement integration, and full SaaS/franchise operation.

Stage 0 allows merchants to start using CatchMenu with minimal operational burden.

Core purpose:

Start light.
Support multilingual menu use.
Receive or show guest intent safely.
Avoid pretending to be POS, KDS, payment, or settlement.

Korean purpose:

가볍게 시작한다.
다국어 메뉴 사용을 지원한다.
손님의 의사를 안전하게 보여주거나 전달한다.
POS, KDS, 결제, 정산인 척하지 않는다.

2\. Stage 0 Scope

Stage 0 includes:

Stage 0A \= Multilingual QR Menu \+ Show-to-Staff View
Stage 0B \= Menu Request Sent to Store Owner Web Console
Stage 0C \= POS-less Simple Request Confirmation Board

Stage 0 does not include:

POS direct integration
KDS direct integration
app payment
settlement
refund approval
benefit grant
external membership merge
white-label app operation
full AI customer center operation

3\. Stage 0 Core Principle

Stage 0 is request and visibility support, not transaction authority.

Core rule:

Guest intent may be shown or sent.
Store may confirm or handle.
POS remains separate.
KDS remains separate.
Payment remains separate.
Settlement remains separate.

Korean rule:

손님 의사는 보여주거나 보낼 수 있다.
매장은 확인하거나 처리할 수 있다.
POS는 분리된다.
KDS는 분리된다.
결제는 분리된다.
정산은 분리된다.

4\. Stage 0A Overview

Stage 0A is the lightest mode.

The guest scans a QR code, views the menu in a selected language, selects items, and shows the screen to staff.

No request is sent to the store system.

Stage 0A is suitable for:

stores wanting multilingual QR menu
stores with many foreign guests
stores without owner console readiness
stores that want no operational integration
stores testing CatchMenu adoption

Stage 0A boundary:

No store request.
No order confirmation.
No POS handoff.
No KDS handoff.
No payment.

5\. Stage 0B Overview

Stage 0B allows the guest to send a menu request to the store owner web console.

This helps staff receive the guest's selected menu and request memo.

Stage 0B is not POS integration.

Stage 0B is suitable for:

stores that want digital request receiving
stores that still use manual POS
stores with foreign guest communication issues
stores that want Korean summary for staff

Stage 0B boundary:

Request sent is not order confirmed.
Owner console view is not payment.
Store handling remains manual.

6\. Stage 0C Overview

Stage 0C provides a POS-less simple request confirmation board.

The store may confirm that it saw the guest request.

The store may optionally mark the request completed.

Stage 0C is not POS.

Stage 0C is not payment ledger.

Stage 0C is not sales settlement authority.

Stage 0C critical rule:

Confirmed requests may be auto-completed.
Unconfirmed requests must not be auto-completed as completed orders.

Korean rule:

매장이 확인한 요청만 자동 완료 후보가 될 수 있다.
미확인 요청은 완료 주문으로 자동 처리하면 안 된다.

7\. Stage 0 Documents

This folder may include:

01100\_Stage\_0\_Readme.md
01110\_Stage\_0A\_QR\_Menu\_And\_Show\_To\_Staff\_Flow.md
01120\_Stage\_0B\_Send\_To\_Store\_Request\_Flow.md
01130\_Stage\_0C\_POS\_Less\_Request\_Confirmation\_Board.md
01140\_Stage\_0\_Guest\_Web\_Screen\_Policy.md
01150\_Stage\_0\_Owner\_Web\_Console\_Policy.md
01160\_Stage\_0\_Request\_State\_Transition\_Guard.md
01170\_Stage\_0\_Unconfirmed\_Request\_Warning\_And\_Forced\_Cleanup.md
01180\_Stage\_0\_Translation\_And\_Critical\_Request\_Handling.md
01190\_Stage\_0\_Support\_Signal\_And\_Evidence\_Packet.md

Additional Stage 0 documents may be added under "01200\~01299".

8\. Relationship To Product Concept Documents

Stage 0 details depend on product concept documents.

Related product concept documents:

01010\_CatchMenu\_Service\_Concept.md
01020\_CatchMenu\_Stage\_0\_POS\_Less\_Menu\_Request\_Policy.md
01030\_CatchMenu\_Guest\_And\_Merchant\_Positioning.md
01040\_CatchMenu\_I18n\_Order\_Request\_Translation\_Policy.md
01050\_CatchMenu\_Module\_Option\_And\_Product\_Package\_Policy.md
01060\_CatchMenu\_Adoption\_And\_Expansion\_Path\_Policy.md
01070\_CatchMenu\_Merchant\_Onboarding\_And\_Readiness\_Policy.md
01080\_CatchMenu\_Guest\_Request\_Lifecycle\_And\_State\_Policy.md
01090\_CatchMenu\_Request\_Order\_Payment\_And\_Benefit\_Authority\_Boundary.md

Product concept documents define the common meaning.

Stage 0 documents define the operational detail.

9\. Stage 0 Guest-Facing Language

Guest-facing language must remain simple.

Allowed guest-facing terms:

Scan QR
View menu
Choose language
Select menu
Show staff
Send request
Store confirmed
Please ask staff
Please pay at store

Avoid guest-facing terms:

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

10\. Stage 0 Merchant-Facing Language

Merchant-facing language should be operational but not overly technical.

Allowed merchant-facing terms:

QR 메뉴
다국어 메뉴
손님 선택 화면
직원에게 보여주기
요청 받기
신규 요청
주문 확인
손님 수정 잠김
미확인 경고
강제 정리
완료
미확인 만료

Caution:

"완료" means CatchMenu Stage 0 handling completion.
It does not necessarily mean POS completion, payment completion, or settlement completion.

11\. Stage 0 Authority Boundary

Stage 0 must preserve authority boundary.

Core boundaries:

Guest selection is intent.
Store confirmation is acknowledgment.
Manual handling is store operation.
POS transaction belongs to POS.
Payment belongs to payment authority.
Settlement belongs to finance authority.
Evidence explains but does not approve.
AI may assist but does not operate.

Related authority boundary document:

01090\_CatchMenu\_Request\_Order\_Payment\_And\_Benefit\_Authority\_Boundary.md

12\. Stage 0 State Boundary

Stage 0 state must be clear.

Important states may include:

MENU\_VIEWED
ITEMS\_SELECTED
SHOW\_TO\_STAFF\_READY
REQUESTED
REQUEST\_SENT
STORE\_VIEWED
STORE\_CONFIRMED
GUEST\_EDIT\_LOCKED
UNCONFIRMED\_WARNING
FORCED\_CLEANUP\_REQUIRED
UNCONFIRMED\_EXPIRED
COMPLETED
AUTO\_COMPLETED
CLOSE\_AUTO\_COMPLETED
SUPPORT\_REVIEW\_REQUIRED

Not every Stage 0 substage uses every state.

State transition rules are defined in:

01160\_Stage\_0\_Request\_State\_Transition\_Guard.md

13\. Stage 0 Support Boundary

Stage 0 should produce support-safe signals and evidence.

Support may need to understand:

which store QR was scanned
which language was used
which menu items were selected
whether a request was sent
whether store confirmed
whether guest edit was locked
whether unconfirmed warning happened
whether forced cleanup was required
whether completion was manual or automatic

However, Stage 0 support evidence must not become mutation authority.

Core rule:

Support can explain.
Support cannot silently mutate.

14\. Stage 0 Failure Boundary

Stage 0 failures must remain modular.

Examples:

QR access failure must not affect POS.
Translation failure must not confirm order.
Owner console alert failure must not erase request.
Unconfirmed request failure must not create completed order.
Forced cleanup failure must not delete request history.

Failure/error naming and diagnostic hierarchy are governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

15\. Stage 0 Fallback Principle

Every Stage 0 flow must have a manual fallback.

Examples:

QR access fails
→ staff provides menu alternative

guest cannot understand translation
→ staff reconfirms

owner console unavailable
→ store uses manual ordering

notification fails
→ request list remains visible

unconfirmed requests accumulate
→ forced cleanup screen

translation confidence is low
→ staff reconfirmation required

Core rule:

Fallback must preserve evidence.
Fallback must not silently rewrite state.

16\. Stage 0 MVP Relevance

Stage 0 is the primary MVP candidate.

MVP may include:

Stage 0A QR menu
multilingual menu display
show-to-staff view
Stage 0B request sending
owner web console request receive
Stage 0C request confirmation board
store confirmation
guest edit lock
unconfirmed warning
forced cleanup
confirmed auto-completion candidate
unconfirmed auto-completion prohibition
basic support signal
basic Evidence Packet

MVP should exclude:

POS direct integration
KDS direct integration
payment
settlement
refund approval
benefit grant
external membership merge
full AI customer center
MongoDB migration

17\. Stage 0 Final Rule

Stage 0 exists to let CatchMenu begin safely.

It should reduce menu communication friction, support foreign guests, help stores receive or view guest intent, and preserve a safe path toward later expansion.

Final rule:

Stage 0 is lightweight.
Stage 0 is reversible.
Stage 0 is support-observable.
Stage 0 does not pretend to be POS.
Stage 0 does not pretend to be payment.
Stage 0 does not pretend to be settlement.
