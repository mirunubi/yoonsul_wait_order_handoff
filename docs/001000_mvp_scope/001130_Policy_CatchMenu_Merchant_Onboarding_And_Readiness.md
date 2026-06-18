# 001130_Policy_CatchMenu_Merchant_Onboarding_And_Readiness

Legacy path: $old.

1\. Purpose

This document defines the merchant onboarding and readiness policy for CatchMenu.

CatchMenu must not be activated for a store only because the technical feature is available.

A store should be ready operationally, visually, linguistically, and support-wise before each CatchMenu package or stage is enabled.

Core purpose:

Do not only install the system.
Prepare the store to use it safely.

Korean purpose:

시스템을 켜는 것만으로는 충분하지 않다.
매장이 실제로 안전하게 사용할 준비가 되어 있어야 한다.

2\. Core Principle

Merchant onboarding should check readiness before activation.

Core rule:

Activation requires readiness.
Readiness requires store context.
Store context requires menu, staff, device, language, support, and fallback preparation.

CatchMenu should not assume that every merchant understands:

QR menu flow
guest request flow
show-to-staff flow
owner console flow
store confirmation meaning
POS-less confirmation limit
manual POS handoff
translation caution
support signal
fallback behavior

3\. Onboarding Scope

Merchant onboarding may include:

store profile setup
menu setup
language setup
QR code setup
device readiness
owner console readiness
staff explanation
guest signage
request flow explanation
Stage 0A / 0B / 0C package selection
notification option setup
support contact setup
troubleshooting guide
fallback guide
go-live checklist

Onboarding should be lightweight for Stage 0A and more detailed for higher stages.

4\. Store Profile Readiness

Before activation, the store profile should include:

store\_id
tenant\_id if applicable
store\_name
store\_display\_name
store\_address
business\_hours
break\_time
last\_order\_time
closed\_days
store\_phone
store\_language
supported\_guest\_languages
merchant\_contact
support\_contact
package\_or\_stage

The store profile must be correct before QR codes are printed or distributed.

Wrong store mapping can cause:

wrong menu display
wrong request destination
wrong owner console routing
wrong support evidence
guest confusion
merchant dispute

5\. Menu Readiness

Menu data must be prepared before activation.

Required menu fields may include:

menu\_item\_id
menu\_name\_ko
menu\_name\_guest\_language
description\_ko
description\_guest\_language
price
category
option\_group
availability
sold\_out\_status
allergy\_tags
spicy\_level
pork\_included
beef\_included
seafood\_included
nuts\_included
alcohol\_included
vegetarian\_possible
image\_optional

Menu data should be treated as operational content, not only marketing content.

6\. Translation Readiness

If multilingual menu or request translation is enabled, translation readiness must be checked.

Required checks:

main menu names translated
core descriptions translated
option names translated
critical allergy/dietary tags mapped
store language summary tested
guest language display tested
low-confidence translation warning prepared

Translation must preserve caution for:

allergy
pork
beef
seafood
nuts
alcohol
raw food
spicy level
religious dietary restriction
vegetarian or vegan request
child or elderly consideration
medical caution

Translation policy is governed by:

01040\_CatchMenu\_I18n\_Order\_Request\_Translation\_Policy.md

7\. QR Code Readiness

Before QR code deployment, each QR code should be checked.

Required checks:

QR points to correct store
QR points to correct menu
QR works on iOS
QR works on Android
QR works on common browsers
QR works without app installation
store name is visible after scan
guest can identify the correct store

QR code errors are high-risk because they happen before staff intervention.

The system should avoid ambiguous QR destinations.

8\. Device Readiness

Device readiness depends on the selected package or stage.

Stage 0A requires:

guest smartphone
QR code access
staff can visually read guest screen

Stage 0B requires:

owner web console device
stable browser
store login or access method
notification method if enabled

Stage 0C requires:

owner web console device
request confirmation board
visible pending request count
unconfirmed warning visibility
forced cleanup visibility

Stage 1 or higher may require:

staff handoff device
waiting view
kitchen or counter device
POS/KDS integration device if applicable

9\. Owner Console Readiness

If Owner Web Console is enabled, the owner or manager must understand:

new request
request detail
store confirmation
guest edit lock after confirmation
completed
unconfirmed warning
forced cleanup
sold out / unavailable handling
translation caution
support signal

The owner console must not imply that CatchMenu is a full POS unless POS integration is actually enabled.

10\. Staff Readiness

Staff should understand the selected stage.

For Stage 0A, staff should know:

guest may show selected menu on phone
shown screen is not a confirmed order
staff must confirm verbally if needed
allergy or special request must be checked

For Stage 0B, staff should know:

guest request may appear in owner console
request is not automatically paid
request may need reconfirmation

For Stage 0C, staff should know:

store confirmation locks guest self-edit
confirmed request may auto-complete later
unconfirmed request must not be treated as completed order

For Stage 1 or higher, staff should know:

CatchMenu supports handoff
POS/KDS authority remains separate
manual confirmation may still be required
handoff failure must be visible

11\. Guest Signage Readiness

Guest-facing signage should be simple.

Allowed guest-facing messages:

Scan QR to view menu
No app required
Choose your language
Show this screen to staff
Send request to store
Please pay at store
Store confirmed your request
Ask staff if you need changes

Avoid guest-facing technical terms:

runtime
adapter
gateway
tenant
Evidence Packet
POS handoff
KDS adapter
support signal

12\. Package Selection Readiness

The merchant should choose the starting package based on operational need.

Suggested mapping:

QR menu only
→ Stage 0A

foreign guest menu request receiving
→ Stage 0B

simple request confirmation without POS
→ Stage 0C

waiting guest pre-order support
→ Stage 1

kitchen preparation visibility
→ Stage 2

POS input reduction
→ Stage 3

POS \+ kitchen integration
→ Stage 4

franchise / SaaS / benefit routing
→ Stage 5

Package selection should not be based only on sales ambition.

It should be based on staff readiness and operational reality.

13\. Notification Readiness

If notifications are enabled, the store must understand that notifications are support aids, not the source of truth.

Notification options may include:

owner web console alert
browser sound
top banner warning
SMS option
Kakao option
push option
email option

Core rule:

Notification failure must not erase the request.
Notification is not the order ledger.

If notification fails, the request should remain visible in the owner console or support view.

14\. Support Readiness

Before activation, the support path should be defined.

Required support readiness:

merchant help contact
support issue category
known issue guide
basic troubleshooting guide
Evidence Packet availability
support signal availability
gateway access logging if applicable

Support readiness becomes more important as the stage increases.

Stage 0A support may be simple.

Stage 3 or higher support must include adapter failure and handoff troubleshooting.

15\. Fallback Readiness

Each activated stage must have a fallback path.

Examples:

QR access fails
→ staff provides paper/menu alternative

translation confidence low
→ staff reconfirms with guest

owner console unavailable
→ manual staff order process

notification fails
→ owner console request list remains source

Stage 0C unconfirmed requests accumulate
→ forced cleanup screen

POS adapter fails
→ manual POS handoff

KDS adapter fails
→ kitchen manual confirmation

Fallback must not erase evidence.

Fallback must not silently mutate order state.

Failure/error naming and diagnostics are governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

16\. Go-Live Checklist

A basic go-live checklist should include:

store profile verified
business hours verified
menu verified
prices verified
sold out handling verified
language display verified
critical tags verified
QR scan tested
owner console tested
staff briefed
guest signage ready
support contact ready
fallback path ready
package/stage confirmed

Higher stages require additional checks.

17\. Stage-Specific Readiness

17.1 Stage 0A Readiness

Required:

QR works
menu displays correctly
language selection works
show-to-staff screen is understandable
staff understands that this is not a confirmed order

17.2 Stage 0B Readiness

Required:

owner console receives request
store language summary is readable
special requests are visible
request sent message is clear
staff understands that payment is not completed

17.3 Stage 0C Readiness

Required:

store confirmation works
guest edit lock works
unconfirmed warning works
forced cleanup threshold works
confirmed auto-completion policy is understood
unconfirmed requests are not auto-completed as completed orders

17.4 Stage 1 Readiness

Required:

waiting identity works
manual POS handoff is understandable
staff knows who enters POS
handoff status is visible
fallback to manual process is available

17.5 Stage 2 Readiness

Required:

kitchen assist screen works
kitchen memo is visible
manual completion is understood
kitchen assist does not become POS authority

17.6 Stage 3 Readiness

Required:

POS adapter contract confirmed
POS handoff test completed
retry policy defined
adapter failure signal defined
manual POS fallback ready

17.7 Stage 4 Readiness

Required:

KDS adapter contract confirmed
POS/KDS state mapping tested
handoff reconciliation tested
kitchen fallback ready
adapter failure evidence available

17.8 Stage 5 Readiness

Required:

tenant boundary confirmed
store boundary confirmed
benefit routing policy confirmed
external membership connector tested
white-label link policy confirmed
HQ support visibility ready
audit visibility ready

18\. Activation Record

Each store activation should create an activation record.

Suggested fields:

tenant\_id
store\_id
activated\_stage
activated\_package
enabled\_modules
disabled\_modules
activation\_date
activated\_by
readiness\_checked\_by
readiness\_result
known\_risks
fallback\_plan
support\_contact
created\_at

Activation history should be append-only.

19\. Activation Must Be Reversible

Activation should not be irreversible.

If a store cannot operate the selected stage safely, the system should allow downgrade or rollback.

Examples:

Stage 0C → Stage 0B
Stage 1 → Stage 0C
Stage 3 → Stage 1
Stage 4 → Stage 3

Rollback must preserve:

request history
support signals
Evidence Packets
gateway logs
failure events
merchant communication history

20\. Final Statement

CatchMenu merchant onboarding must prepare the store, not only activate the software.

A merchant should be able to start lightly, understand the selected package, operate it safely, receive support, and expand later when ready.

Final rule:

Activate only what the store can operate.
Explain what changes.
Preserve fallback.
Preserve evidence.
Expand only when ready.
