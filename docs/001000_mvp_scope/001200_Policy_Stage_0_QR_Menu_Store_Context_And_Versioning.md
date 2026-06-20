# 001200_Policy_Stage_0_QR_Menu_Store_Context_And_Versioning.md

1\. Purpose

This document defines the Stage 0 QR, menu, store context, and versioning policy for CatchMenu.

Stage 0 begins when a guest scans a QR code.

Therefore, the system must know which store, which menu, which language, which business context, and which menu version the guest is viewing.

Wrong QR mapping, wrong store context, stale menu data, or unclear versioning can create operational confusion.

Core purpose:

Map QR to the correct store.
Show the correct menu.
Preserve menu version context.
Prevent wrong-store and stale-menu confusion.

Korean purpose:

QR을 올바른 매장에 연결한다.
올바른 메뉴를 보여준다.
메뉴 버전 맥락을 보존한다.
잘못된 매장/오래된 메뉴 혼선을 막는다.

2\. Scope

This document covers:

QR code identity
store context
menu context
menu version
translation version
business date context
store operating status
language context
request context preservation
QR replacement
QR deactivation
wrong QR handling
stale menu handling
support evidence

This document does not define:

full menu management system
POS menu master synchronization
KDS item routing
payment item catalog
settlement item catalog
franchise-wide menu governance
delivery platform menu sync

3\. Core Principle

A QR scan must not be ambiguous.

Core rule:

Every QR scan must resolve to a specific store context and menu context.

Korean rule:

모든 QR 스캔은 특정 매장 컨텍스트와 메뉴 컨텍스트로 해석되어야 한다.

If the system cannot determine store context safely, the guest should not proceed as if the menu is reliable.

4\. QR Code Identity

Each QR code should have a stable QR identity.

Recommended fields:

qr\_id
qr\_code\_ref
tenant\_id
store\_id
menu\_context\_id
qr\_type
qr\_status
issued\_at
activated\_at
deactivated\_at
created\_by
last\_rotated\_at

Possible QR types:

STORE\_MAIN\_MENU
TABLE\_MENU
COUNTER\_MENU
WINDOW\_MENU
EVENT\_MENU
TEMPORARY\_MENU
TEST\_MENU

Stage 0 MVP may start with:

STORE\_MAIN\_MENU
TABLE\_MENU

5\. QR Status

QR status should be explicit.

Suggested statuses:

DRAFT
ACTIVE
PAUSED
DEACTIVATED
REPLACED
EXPIRED
TEST\_ONLY

Meaning:

DRAFT
\= QR prepared but not public

ACTIVE
\= QR may be used by guests

PAUSED
\= QR temporarily unavailable

DEACTIVATED
\= QR should no longer be used

REPLACED
\= QR has newer replacement

EXPIRED
\= temporary QR is no longer valid

TEST\_ONLY
\= internal test QR, not public guest use

6\. Store Context

A QR scan must resolve to a store context.

Store context may include:

tenant\_id
store\_id
store\_display\_name
store\_branch\_name
store\_location\_hint
business\_status
business\_date
timezone
enabled\_stage
enabled\_package
owner\_console\_enabled
request\_send\_enabled

Guest-facing screen should show enough store context to avoid confusion.

Example:

현재 보고 있는 매장:
윤슬 사당점

English:

You are viewing the menu for:
Yoonsul Sadang Store

7\. Wrong Store Prevention

Wrong store QR is a high-risk Stage 0 issue.

Possible causes:

QR printed for wrong branch
QR reused after store relocation
QR copied from another store
old QR sticker not removed
test QR accidentally printed
menu context assigned incorrectly

The system should reduce risk by showing:

store name
branch name
location hint
current menu status

If the guest or staff reports wrong store, support evidence should include QR identity and store context.

8\. Menu Context

A QR scan should resolve to a menu context.

Menu context may include:

menu\_context\_id
store\_id
menu\_version\_id
language\_set\_id
availability\_policy
price\_policy
stage\_enabled
created\_at
activated\_at

Menu context defines which menu is visible for that store and flow.

A store may have multiple menu contexts in the future.

Examples:

main dine-in menu
takeout menu
breakfast menu
lunch menu
evening menu
event menu
temporary sold-out limited menu

Stage 0 MVP may start with one active main menu per store.

9\. Menu Version

Menu version must be preserved.

Recommended fields:

menu\_version\_id
menu\_context\_id
version\_number
version\_label
effective\_from
effective\_to
published\_at
published\_by
status

Suggested statuses:

DRAFT
PUBLISHED
PAUSED
ARCHIVED
REPLACED

Core rule:

A request must remember the menu version used when the guest selected items.

Korean rule:

요청은 손님이 메뉴를 선택한 당시의 메뉴 버전을 기억해야 한다.

10\. Translation Version

Menu translation should also be versioned.

Recommended fields:

translation\_version\_id
menu\_version\_id
language\_code
translation\_source
review\_status
published\_at
updated\_at

Possible translation sources:

manual
AI\_assisted
machine\_generated
reviewed\_AI
imported

Review statuses:

DRAFT
AUTO\_GENERATED
REVIEW\_REQUIRED
REVIEWED
PUBLISHED
ARCHIVED

Translation version must be preserved in request evidence when a request is sent.

11\. Language Context

Stage 0 should preserve language context.

Recommended fields:

guest\_language
store\_language
fallback\_language
language\_selected\_at
language\_changed\_at
translation\_version\_id

Language switching should not silently reset selected items unless required.

If language change affects menu availability or translation version, the guest should be warned.

12\. Business Date Context

Stage 0 requests should preserve business date context.

Recommended fields:

business\_date
store\_timezone
opened\_at
closed\_at
request\_created\_at
request\_sent\_at

Business date matters for:

daily request cleanup
close auto-completion
unconfirmed expiration
support review
merchant reporting
evidence packet generation

Core rule:

Calendar timestamp and business date are both needed.

13\. Store Operating Status

Guest screens should reflect store operating status if available.

Possible statuses:

OPEN
CLOSED
PREPARING
BREAK\_TIME
LAST\_ORDER\_CLOSED
TEMPORARILY\_PAUSED
UNKNOWN

If status is unknown, do not overclaim that the store is accepting requests.

Guest-facing fallback:

Store status may need confirmation.
Please ask staff.

Korean:

매장 운영 상태는 확인이 필요할 수 있습니다.
직원에게 문의해주세요.

14\. Request Enablement By Stage

QR and menu view may be enabled even when request sending is disabled.

Stage behavior:

Stage 0A
\= menu view and show-to-staff only

Stage 0B
\= menu view, show-to-staff, send request

Stage 0C
\= menu view, send request, store confirmation board

The guest screen must adapt based on enabled stage.

If request sending is not enabled, do not show active send request button.

15\. Availability Context

Menu availability may be real-time, manual, or unknown.

Possible availability modes:

REAL\_TIME
MANUAL\_STORE\_UPDATE
STATIC\_MENU
UNKNOWN

If availability is not real-time, guest-facing screen should say:

Availability may change.
Please confirm with staff.

Korean:

재고 상황은 달라질 수 있습니다.
직원에게 확인해주세요.

Core rule:

Do not present static availability as real-time truth.

16\. Price Context

Menu price may depend on store, time, option, or manual store policy.

Price context should include:

menu\_price\_version
option\_price\_version
tax\_display\_policy
estimated\_total\_policy
final\_price\_notice

If Stage 0 does not have payment authority, the screen should state:

Estimated total.
Final amount may be confirmed by the store.

Korean:

예상 금액입니다.
최종 금액은 매장에서 확인될 수 있습니다.

17\. Stale Menu Handling

A stale menu issue occurs when the guest views or sends a request using an outdated menu version.

Possible causes:

menu updated after page load
translation updated after page load
QR linked to archived menu
store changed availability
browser cached old menu

Handling:

detect stale version if possible
show refresh prompt
preserve existing selection if safe
warn guest if item changed
prevent sending clearly invalid request
create support signal if needed

Guest-facing message:

The menu has been updated.
Please review your selection again.

Korean:

메뉴가 업데이트되었습니다.
선택 내용을 다시 확인해주세요.

18\. Menu Version Conflict

Menu version conflict may occur when a request was created under one version but store console uses another version.

Owner console should show:

request menu version
current menu version
changed item warning if relevant

Core rule:

Do not reinterpret old request under new menu version without trace.

Korean rule:

과거 요청을 새 메뉴 버전 기준으로 조용히 재해석하지 않는다.

19\. QR Replacement Policy

If a QR code is replaced, the old QR should have explicit status.

Recommended flow:

ACTIVE
→ REPLACED
→ DEACTIVATED if needed

Old QR scan may show:

This QR has been replaced.
Please scan the new QR at the store.

Korean:

이 QR은 교체되었습니다.
매장의 새 QR을 스캔해주세요.

If safe, old QR may redirect to the new QR context with a warning.

20\. QR Deactivation Policy

QR may be deactivated when:

store closes permanently
QR was printed incorrectly
menu context is unsafe
wrong store mapping detected
temporary event ended
security concern exists

Guest-facing message:

This QR is no longer available.
Please ask staff.

Korean:

이 QR은 더 이상 사용할 수 없습니다.
직원에게 문의해주세요.

Deactivation must be event-backed.

21\. Test QR Policy

Test QR must not be confused with live guest QR.

Test QR should show visible warning:

TEST MENU
Not for guest use

Korean:

테스트 메뉴
손님용이 아닙니다

Test QR must not create production guest requests unless explicitly configured for test environment.

22\. QR Security Boundary

QR itself is not authentication.

QR identifies a public menu context.

QR must not grant owner console authority.

Core rule:

QR opens guest menu.
QR does not authenticate store staff.
QR does not grant admin access.

Korean rule:

QR은 손님 메뉴를 연다.
QR은 직원 인증이 아니다.
QR은 관리자 권한을 주지 않는다.

23\. Guest Session Context

When a guest scans QR, the system may create a guest session.

Recommended lightweight fields:

guest\_session\_id
qr\_id
store\_id
menu\_version\_id
guest\_language
created\_at
last\_seen\_at
stage

Guest session is not permanent identity.

Core rule:

Guest session supports continuity.
Guest session is not permanent customer identity.

24\. Request Context Preservation

When a request is created or sent, preserve:

qr\_id
store\_id
menu\_context\_id
menu\_version\_id
translation\_version\_id
guest\_language
store\_language
business\_date
request\_stage
request\_version

This helps later support review.

Without context preservation, support cannot reliably explain what the guest saw.

25\. Wrong QR Support Signal

Wrong QR suspicion may generate support signal.

Possible signal types:

QR\_WRONG\_STORE\_SUSPECTED
QR\_DEACTIVATED\_SCAN
QR\_REPLACED\_SCAN
QR\_MENU\_CONTEXT\_MISMATCH
QR\_TEST\_USED\_IN\_PRODUCTION
QR\_STALE\_MENU\_CONTEXT

Signal payload may include:

signal\_id
qr\_id
store\_id
expected\_store\_id if known
menu\_context\_id
menu\_version\_id
scan\_time
guest\_session\_ref
trace\_id

26\. Menu Version Support Signal

Menu version issues may generate support signal.

Possible signal types:

MENU\_VERSION\_STALE
MENU\_VERSION\_CONFLICT
TRANSLATION\_VERSION\_STALE
MENU\_ITEM\_ARCHIVED\_SELECTED
MENU\_PRICE\_VERSION\_CHANGED
MENU\_AVAILABILITY\_UNKNOWN

These signals may later become known issue patterns.

27\. Evidence Packet Fields

Evidence Packet should include QR/menu/store context when relevant.

Recommended fields:

qr\_id
qr\_status
qr\_type
store\_id
store\_display\_name
menu\_context\_id
menu\_version\_id
translation\_version\_id
guest\_language
store\_language
business\_date
request\_id
request\_version
stale\_menu\_warning
wrong\_qr\_signal
menu\_version\_conflict\_signal

Core rule:

Evidence must preserve what the guest saw at the time.

Korean rule:

증거는 손님이 당시 본 내용을 보존해야 한다.

28\. Failure Event Policy

QR/menu/store context failures must be typed.

Example failure codes:

WOH.STAGE0.QR.RESOLVE.NOT\_FOUND
WOH.STAGE0.QR.RESOLVE.DEACTIVATED
WOH.STAGE0.QR.RESOLVE.WRONG\_STORE\_SUSPECTED
WOH.STAGE0.QR.MENU\_CONTEXT.MISSING
WOH.STAGE0.MENU.VERSION.STALE
WOH.STAGE0.MENU.VERSION.CONFLICT
WOH.STAGE0.TRANSLATION.VERSION.STALE
WOH.STAGE0.STORE.CONTEXT.MISSING
WOH.STAGE0.STORE.STATUS.UNKNOWN

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

29\. Guest-Facing Messages

Recommended guest-facing messages:

You are viewing the menu for this store.

The menu has been updated.
Please review your selection again.

This QR is no longer available.
Please ask staff.

Availability may change.
Please confirm with staff.

Korean:

현재 이 매장의 메뉴를 보고 있습니다.

메뉴가 업데이트되었습니다.
선택 내용을 다시 확인해주세요.

이 QR은 더 이상 사용할 수 없습니다.
직원에게 문의해주세요.

재고 상황은 달라질 수 있습니다.
직원에게 확인해주세요.

30\. Merchant-Facing Messages

Recommended merchant-facing messages:

이 요청은 이전 메뉴 버전에서 생성되었습니다.
최신 메뉴와 다를 수 있습니다.

QR 매장 연결을 확인해주세요.
잘못된 매장 QR일 수 있습니다.

이 QR은 교체되었거나 비활성화되었습니다.
새 QR 사용이 필요합니다.

메뉴 번역 버전이 변경되었습니다.
요청 당시 번역 기준을 확인해주세요.

31\. Support-Facing Messages

Support-facing view may show:

QR resolved to store\_id \= X
Menu version at request time \= V3
Current menu version \= V4
Translation version \= ko/en V2
Wrong QR suspicion signal generated
Menu version conflict detected

Support-facing view should include:

qr\_id
menu\_context\_id
menu\_version\_id
translation\_version\_id
request\_id
trace\_id
failure\_code if any
evidence\_packet\_ref

32\. Metrics And Monitoring

Recommended metrics:

qr\_scan\_count
qr\_resolve\_failure\_count
wrong\_qr\_suspected\_count
deactivated\_qr\_scan\_count
replaced\_qr\_scan\_count
menu\_version\_conflict\_count
stale\_menu\_warning\_count
translation\_version\_conflict\_count
store\_context\_missing\_count

Metrics should support reliability and merchant setup improvement.

They should not become punitive by default.

33\. Relationship To Guest Web Screen

Guest web display is governed by:

01140\_Stage\_0\_Guest\_Web\_Screen\_Policy.md

Guest screen must show store context and menu update messages clearly.

34\. Relationship To Owner Web Console

Owner console display is governed by:

01150\_Stage\_0\_Owner\_Web\_Console\_Policy.md

Owner console should show menu version conflict and wrong QR suspicion when relevant.

35\. Relationship To Support Signal And Evidence Packet

Support evidence is governed by:

01190\_Stage\_0\_Support\_Signal\_And\_Evidence\_Packet.md

QR, store, menu, and version context should be included in Evidence Packet when relevant.

36\. Final Statement

Stage 0 begins with QR scan, but QR scan is only safe when store context, menu context, and version context are clear.

Final rule:

QR must resolve clearly.
Store context must be visible.
Menu version must be preserved.
Translation version must be traceable.
Wrong QR must be detectable.
Stale menu must not be hidden.
Request evidence must remember what the guest saw.
