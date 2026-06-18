# 011270_Policy_POS_Menu_Table_Order_Mapping_And_Idempotency

Legacy path: $old.

1\. Purpose

This document defines POS Menu Mapping, Option Mapping, Table Mapping, Order Handoff Mapping, and Idempotency policy for CatchMenu / Wait Order Handoff.

External POS integration fails most often when menu items, options, table references, order identifiers, or retry rules are not mapped correctly.

CatchMenu must not assume that a menu item displayed to the guest is automatically identical to a POS menu item.

CatchMenu must not assume that a table shown in CatchMenu is automatically identical to a POS table.

CatchMenu must not create duplicate POS orders when retrying failed handoff.

Core purpose:

Define POS menu mapping.
Define POS option/modifier mapping.
Define POS table mapping.
Define order handoff mapping.
Define mapping status.
Define mapping version.
Define idempotency.
Prevent duplicate POS orders.
Prevent unmapped item injection.
Prevent table mismatch.
Prevent silent mapping overwrite.
Support manual fallback when mapping is incomplete.

Korean purpose:

POS 메뉴 매핑을 정의한다.
POS 옵션/modifier 매핑을 정의한다.
POS 테이블 매핑을 정의한다.
주문 handoff 매핑을 정의한다.
매핑 상태를 정의한다.
매핑 버전을 정의한다.
idempotency를 정의한다.
중복 POS 주문을 방지한다.
매핑되지 않은 메뉴의 자동 주입을 방지한다.
테이블 불일치를 방지한다.
조용한 매핑 덮어쓰기를 방지한다.
매핑이 불완전할 때 수동 fallback을 지원한다.

2\. Scope

This document covers:

menu item mapping
category mapping
option group mapping
modifier mapping
required option mapping
free text note handling
table mapping
zone/floor mapping
order handoff payload mapping
idempotency key
duplicate order prevention
mapping status
mapping version
mapping audit
mapping review
mapping conflict
manual fallback when mapping incomplete

This document does not define:

provider-specific API code
provider credential storage
callback validation detail
replay execution detail
payment provider settlement
KDS ticket execution
full inventory ownership
AI menu extraction engine

Related documents:

03500\_External\_POS\_Integration\_Runtime\_Readme.md
03510\_POS\_Integration\_Module\_And\_All\_POS\_Expansion\_Strategy.md
011260_Policy_POS_Provider_Adapter_Contract_And_Capability_Declaration.md
011070_Policy_POS_Callback_Replay_Manual_Fallback_And_Evidence.md
03930\_AI\_Menu\_Intake\_Correction\_And\_Live\_Menu\_Stabilization\_Policy.md
03950\_POS\_Manual\_Fallback\_Training\_And\_Store\_Usage\_Policy.md

3\. Core Principle

No reliable mapping, no automatic POS injection.

Core rule:

Mapped item can be handed off.
Unmapped item requires review or manual fallback.
Duplicate handoff must be blocked by idempotency.

Korean rule:

매핑된 메뉴만 POS로 handoff할 수 있다.
매핑되지 않은 메뉴는 review 또는 manual fallback이 필요하다.
중복 handoff는 idempotency로 차단해야 한다.

4\. Mapping Boundary

Mapping connects CatchMenu service concepts to POS provider concepts.

CatchMenu owns:

guest-facing menu
AI menu draft
merchant-reviewed menu
request item
request option
guest note
CatchMenu table context
waiting/preorder context
handoff candidate

External POS owns:

POS menu item
POS category
POS option/modifier
POS table
POS order
POS receipt/reference
POS status

Mapping does not merge ownership.

Core rule:

Mapping connects systems.
Mapping does not erase source-of-truth boundaries.

5\. Menu Mapping

Menu mapping links a CatchMenu menu item to a POS menu item.

Minimum mapping fields:

mapping\_id
merchant\_store\_id
provider\_id
pos\_binding\_id
catchmenu\_menu\_item\_id
pos\_menu\_item\_id
catchmenu\_menu\_version
pos\_menu\_version optional
mapping\_status
mapping\_version
created\_at
updated\_at

Optional fields:

catchmenu\_item\_name
pos\_item\_name
catchmenu\_price
pos\_price
category\_reference
tax\_reference
availability\_reference
note

Core rule:

Menu mapping must be store-scoped and provider-scoped.

6\. Menu Mapping Status

Suggested statuses:

UNMAPPED
MAPPED
PARTIAL
CONFLICT
REVIEW\_REQUIRED
DEPRECATED
DISABLED

Meaning:

UNMAPPED
\= no POS item is linked

MAPPED
\= CatchMenu item and POS item are linked and usable

PARTIAL
\= item is linked but some option/price/category detail needs review

CONFLICT
\= mapping conflicts with current POS/menu data

REVIEW\_REQUIRED
\= human review required before use

DEPRECATED
\= old mapping retained for history

DISABLED
\= mapping is intentionally disabled

Core rule:

Only MAPPED can be used for automatic POS injection unless policy explicitly allows limited partial use.

7\. Category Mapping

Category mapping may be needed when POS requires category reference.

Category mapping may include:

catchmenu\_category\_id
pos\_category\_id
category\_name
display\_order
mapping\_status

Core rule:

Category mismatch should not block order injection unless provider requires category in order payload.

8\. Price Mapping

Price mismatch must be handled carefully.

Possible price sources:

CatchMenu menu price
POS item price
promotion price
manual override
reservation/preorder price

Price mismatch statuses:

MATCHED
DIFFERENT\_REVIEW\_REQUIRED
POS\_PRICE\_AUTHORITATIVE
CATCHMENU\_PRICE\_AUTHORITATIVE\_FOR\_DISPLAY
PROMOTION\_APPLIED
BLOCKED

Core rule:

Price mismatch must be visible before POS handoff affects merchant trust.

9\. Option Group Mapping

Option group mapping links CatchMenu option groups to POS modifier groups.

Examples:

size
temperature
spice level
rice amount
extra topping
set selection
drink choice

Mapping fields:

catchmenu\_option\_group\_id
pos\_modifier\_group\_id
required\_flag
multi\_select\_flag
min\_select
max\_select
mapping\_status

Core rule:

Required option group must be fully mapped before automatic POS injection.

10\. Option And Modifier Mapping

Option mapping links individual options.

Examples:

small
large
hot
iced
mild
spicy
extra cheese
no onion
add egg

Mapping fields:

catchmenu\_option\_id
pos\_modifier\_id
price\_delta
mapping\_status

Core rule:

Unmapped required option blocks automatic POS injection.

11\. Free Text Note Handling

Free text notes are risky.

Examples:

less spicy
no cucumber
separate sauce
allergy note
custom request
foreign language note

Provider handling modes:

NOTE\_SUPPORTED
NOTE\_LIMITED
NOTE\_NOT\_SUPPORTED
MANUAL\_REVIEW\_REQUIRED
CRITICAL\_NOTE\_BLOCKS\_AUTO\_INJECTION

Core rule:

Critical free text note must not be lost during POS handoff.

12\. Critical Warning Mapping

Critical warnings include allergy, severe dietary restriction, or safety-related notes.

Examples:

allergy
pregnancy warning
spicy intolerance
no pork
no meat
religious/dietary restriction note

Critical warning handling:

show clearly in CatchMenu
include in POS note if supported
block automatic injection if provider cannot carry warning safely
require manual confirmation if needed

Core rule:

Operational safety note must not disappear in POS translation.

13\. Table Mapping

Table mapping links CatchMenu table context to POS table reference.

Fields:

catchmenu\_table\_id
pos\_table\_id
zone
floor
table\_name
seat\_count
mapping\_status
mapping\_version

Core rule:

Table-based POS handoff requires explicit table mapping.

14\. Table Status Mapping

Some POS providers may expose table status.

Possible statuses:

EMPTY
OCCUPIED
RESERVED
ORDERED
PAYMENT\_PENDING
CLEANING
UNKNOWN

CatchMenu must treat POS table status as provider fact.

Core rule:

POS table status can inform CatchMenu but must not silently override CatchMenu seating/waiting truth.

15\. Waiting/Seating Mapping

Waiting and seating context may link to POS table mapping.

Mapping may include:

waiting\_id
seating\_session\_id
catchmenu\_table\_id
pos\_table\_id
seated\_at
handoff\_context

Core rule:

Waiting-to-table transition must be explicit before POS table order handoff.

16\. Order Handoff Mapping

Order handoff mapping prepares CatchMenu request for POS.

Handoff payload should include:

handoff\_candidate\_id
request\_id
merchant\_store\_id
provider\_id
pos\_binding\_id
idempotency\_key
mapped\_items
mapped\_options
quantity
table\_reference
notes
critical\_warning
created\_at

Core rule:

Order handoff payload must be derived from reviewed mapping state.

17\. Handoff Eligibility

A request is eligible for automatic POS handoff only when:

POS binding is active
provider capability supports order handoff
integration mode allows handoff
all required menu items are mapped
all required options are mapped
table mapping exists if table required
critical warning can be preserved
idempotency key exists
billing entitlement allows POS integration if required

Core rule:

Handoff eligibility must be checked before provider call.

18\. Handoff Ineligibility

A request is not eligible for automatic POS handoff when:

menu item unmapped
required option unmapped
table required but unmapped
critical note cannot be transferred
provider capability missing
POS binding inactive
credential invalid
integration mode manual-only
idempotency missing

Possible actions:

manual POS fallback
mapping review
merchant notification
support signal
request hold

Core rule:

Ineligible handoff must become visible fallback or review, not silent loss.

19\. Idempotency Definition

Idempotency ensures repeated handoff attempts do not create duplicate POS orders.

Idempotency key should be stable for the same handoff candidate.

Potential key components:

merchant\_store\_id
provider\_id
request\_id
handoff\_candidate\_id
attempt\_scope
mapping\_version

Core rule:

Same handoff candidate must not create multiple POS orders through retry.

20\. Idempotency Scope

Idempotency scope should be clear.

Possible scopes:

REQUEST\_LEVEL
HANDOFF\_CANDIDATE\_LEVEL
PROVIDER\_ATTEMPT\_LEVEL
CALLBACK\_EVENT\_LEVEL
REPLAY\_LEVEL

Recommended:

Use HANDOFF\_CANDIDATE\_LEVEL for POS order creation.
Use CALLBACK\_EVENT\_LEVEL for callback processing.
Use REPLAY\_LEVEL for replay audit.

Core rule:

Idempotency scope must match the operation being protected.

21\. Duplicate Order Prevention

Duplicate risk occurs when:

provider timeout after order accepted
callback delayed
staff manually enters while system retries
operator clicks retry multiple times
network retry duplicates payload
provider lacks idempotency support
mapping version changes during retry

Prevention controls:

idempotency key
handoff lock
attempt status
provider response check
manual fallback marker
replay guard
operator warning
evidence packet

Core rule:

Timeout is not proof of failure.
Check before retry.

22\. Handoff Attempt Status

Suggested statuses:

NOT\_ATTEMPTED
ELIGIBLE
INELIGIBLE
ATTEMPTING
SENT
ACCEPTED
REJECTED
TIMEOUT
UNKNOWN\_RESULT
REPLAY\_REQUIRED
MANUAL\_FALLBACK\_REQUIRED
DUPLICATE\_RISK\_REVIEW

Core rule:

UNKNOWN\_RESULT must not be retried blindly.

23\. Mapping Version

Mapping version must be recorded with handoff.

Mapping version matters because menu/table mapping may change over time.

Record:

menu\_mapping\_version
option\_mapping\_version
table\_mapping\_version
provider\_capability\_version
integration\_mode\_version

Core rule:

Every POS handoff must be explainable by the mapping version used at that time.

24\. Mapping Change During Active Request

Mapping may change while requests exist.

If mapping changes:

new requests use new mapping
existing handoff candidates retain old mapping snapshot
replay uses original mapping unless explicitly remapped
manual review required for affected pending requests

Core rule:

Mapping update must not mutate existing handoff history silently.

25\. Mapping Conflict

Mapping conflict occurs when:

same CatchMenu item mapped to multiple POS items incorrectly
same POS item mapped to incompatible CatchMenu items
price mismatch unresolved
required modifier missing
table mismatch
provider menu changed

Conflict handling:

mark CONFLICT
block automatic handoff if risky
emit support signal
require mapping review
preserve previous mapping history

Core rule:

Mapping conflict must block unsafe automation.

26\. Mapping Review

Mapping review may be needed before activation or after change.

Review triggers:

AI menu correction
POS menu import
price change
option change
provider menu sync
merchant complaint
handoff rejection
duplicate risk
support case

Core rule:

Mapping review is operational safety, not administrative decoration.

27\. AI Menu Intake Relationship

AI Menu Intake may create CatchMenu menu draft.

However, AI draft does not automatically create trusted POS mapping.

Flow:

AI menu draft
→ merchant review
→ CatchMenu live menu
→ POS mapping review
→ handoff eligibility

Core rule:

AI menu accuracy and POS mapping accuracy are related but separate.

28\. Sold-Out And Availability Relationship

Sold-out and availability may affect handoff.

Availability sources may include:

CatchMenu manual sold-out
POS sold-out if provider supports
inventory availability if integrated later
merchant note
KDS/kitchen signal later

Core rule:

Unavailable item must be blocked or reviewed before POS handoff.

29\. Manual Fallback When Mapping Incomplete

When mapping is incomplete, manual fallback may be used.

Manual fallback must show:

item name
option name
quantity
price if applicable
critical note
mapping issue
manual entry instruction

Core rule:

Manual fallback must provide enough clarity to avoid staff confusion.

30\. Mapping Audit Events

Recommended audit events:

POS\_MENU\_MAPPING\_CREATED
POS\_MENU\_MAPPING\_UPDATED
POS\_MENU\_MAPPING\_DISABLED
POS\_OPTION\_MAPPING\_CREATED
POS\_OPTION\_MAPPING\_UPDATED
POS\_TABLE\_MAPPING\_CREATED
POS\_TABLE\_MAPPING\_UPDATED
POS\_MAPPING\_CONFLICT\_DETECTED
POS\_MAPPING\_REVIEW\_REQUIRED
POS\_MAPPING\_REVIEW\_COMPLETED
POS\_MAPPING\_VERSION\_CREATED

Minimum audit fields:

event\_id
merchant\_store\_id
provider\_id
pos\_binding\_id
mapping\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

31\. Handoff Audit Events

Recommended handoff audit events:

POS\_HANDOFF\_ELIGIBILITY\_CHECKED
POS\_HANDOFF\_CANDIDATE\_CREATED
POS\_HANDOFF\_ATTEMPTED
POS\_HANDOFF\_ACCEPTED
POS\_HANDOFF\_REJECTED
POS\_HANDOFF\_TIMEOUT
POS\_HANDOFF\_UNKNOWN\_RESULT
POS\_HANDOFF\_DUPLICATE\_RISK\_MARKED
POS\_HANDOFF\_MANUAL\_FALLBACK\_REQUIRED

Core rule:

Every POS handoff attempt must have audit history.

32\. Failure Events

Example failure codes:

WOH.POS.MAPPING.MENU\_ITEM\_UNMAPPED
WOH.POS.MAPPING.OPTION\_UNMAPPED
WOH.POS.MAPPING.REQUIRED\_OPTION\_UNMAPPED
WOH.POS.MAPPING.TABLE\_UNMAPPED
WOH.POS.MAPPING.PRICE\_CONFLICT
WOH.POS.MAPPING.VERSION\_REQUIRED
WOH.POS.HANDOFF.IDEMPOTENCY\_KEY\_REQUIRED
WOH.POS.HANDOFF.DUPLICATE\_RISK
WOH.POS.HANDOFF.UNKNOWN\_RESULT
WOH.POS.HANDOFF.INELIGIBLE
WOH.POS.HANDOFF.MANUAL\_FALLBACK\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

33\. Support Signals

Support signals may include:

POS\_MENU\_MAPPING\_REQUIRED
POS\_OPTION\_MAPPING\_REQUIRED
POS\_TABLE\_MAPPING\_REQUIRED
POS\_MAPPING\_CONFLICT
POS\_PRICE\_CONFLICT
POS\_HANDOFF\_INELIGIBLE
POS\_IDEMPOTENCY\_MISSING
POS\_DUPLICATE\_RISK
POS\_UNKNOWN\_RESULT\_REVIEW\_REQUIRED
MANUAL\_POS\_FALLBACK\_REQUIRED

Support Signal alerts.

It does not modify mapping by itself.

34\. Relationship To Callback Replay Manual Fallback

Mapping and idempotency directly affect callback, replay, and fallback.

Examples:

unknown handoff result
→ callback/status check before retry

mapping conflict
→ manual fallback or mapping review

idempotency missing
→ block automatic retry

provider timeout
→ replay only after duplicate risk review

Core rule:

Replay must respect original mapping and idempotency guard.

35\. Relationship To Merchant Success

Merchant Success may detect mapping issues through first 30 days operation.

Signals:

staff manual entry confusion
wrong item entered
option missing
price mismatch
duplicate order fear
merchant asks for POS integration

Core rule:

Merchant Success field friction should feed mapping review.

36\. Relationship To Billing

POS mapping and handoff features may be billable add-ons.

Billing should charge only when:

POS integration entitlement exists
store binding active
capability verified
feature enabled

Core rule:

Billing must not charge for unavailable or blocked POS handoff features.

37\. MVP Requirements

MVP should support at least:

menu mapping placeholder
option mapping placeholder
table mapping placeholder
mapping status
mapping version
handoff eligibility check
idempotency key field
handoff attempt status
manual fallback required status
mapping audit event
handoff audit event
failure event
support signal

MVP may defer:

automatic POS menu sync
automatic table sync
advanced modifier mapping UI
real-time price reconciliation
advanced duplicate detection model
provider-specific automated mapping suggestion

38\. Suggested Conceptual Entities

Suggested entities:

pos\_menu\_mappings
pos\_option\_group\_mappings
pos\_option\_mappings
pos\_table\_mappings
pos\_mapping\_versions
pos\_mapping\_conflicts
pos\_handoff\_candidates
pos\_handoff\_attempts
pos\_idempotency\_keys
pos\_handoff\_audit\_events
pos\_mapping\_failure\_events
pos\_mapping\_support\_signals

This document defines policy.

Actual schema may be designed later.

39\. Risk If Skipped

If POS Menu/Table/Order Mapping and Idempotency policy is skipped, risks include:

wrong item sent to POS
required option lost
critical note lost
wrong table receives order
duplicate POS order created
timeout retried unsafely
price mismatch damages trust
AI menu draft incorrectly assumed POS-ready
manual fallback causes staff confusion
support cannot diagnose handoff failure
medium/large store trust collapses

Therefore, mapping and idempotency must be defined before automatic POS handoff.

40\. Final Rule

POS handoff is safe only when mapping and idempotency are controlled.

Final rule:

Map menu explicitly.
Map required options explicitly.
Map tables explicitly.
Record mapping version.
Check handoff eligibility.
Create idempotency key.
Do not inject unmapped items.
Do not lose critical notes.
Do not retry unknown result blindly.
Block duplicate orders.
Use manual fallback when mapping is incomplete.
Audit mapping changes.
Preserve handoff evidence.
