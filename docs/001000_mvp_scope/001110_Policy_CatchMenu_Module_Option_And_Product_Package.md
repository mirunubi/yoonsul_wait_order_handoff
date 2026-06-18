# 001110_Policy_CatchMenu_Module_Option_And_Product_Package

Legacy path: $old.

1\. Purpose

This document defines the module, option, and product package policy for CatchMenu.

CatchMenu must support many store situations without forcing every store to adopt the same feature set.

The internal architecture should be modular.

The merchant-facing product should be explained as packages and options.

The store capability stage should determine which modules are available, required, optional, or disabled.

Core purpose:

internal structure \= modules
merchant explanation \= packages
store adoption \= stages
additional features \= options

2\. Core Principle

CatchMenu must not be sold or designed as one fixed product.

Different stores have different needs:

some stores only need multilingual QR menu
some stores need foreign guest request translation
some stores have no POS
some stores have POS but no integration
some stores need kitchen assist
some stores have POS API
some stores have POS and KDS
some tenants need SaaS, white label, and membership integration

Therefore, CatchMenu should be designed as a modular product system.

Core rule:

«The runtime remains one system, but store-facing activation must be modular by capability, package, and option.»

3\. Three-Layer Product Structure

CatchMenu product structure should be separated into three layers.

1\. Core Runtime
2\. Activated Modules
3\. Merchant Packages / Options

3.1 Core Runtime

Core Runtime is the shared foundation.

It includes:

store profile
menu data
language data
guest request context
staff/store confirmation context
event log
handoff boundary
stage/capability configuration

Core Runtime should remain stable across stages.

3.2 Activated Modules

Activated Modules are enabled or disabled by store capability and package.

Examples:

QR Menu Module
I18n Translation Module
Show-to-Staff Module
Send-to-Store Module
Owner Web Console Module
POS-less Request Confirmation Module
Waiting Module
Manual POS Handoff Module
Mini KDS / Kitchen Assist Module
POS Adapter Module
KDS Adapter Module
Benefit Routing Module
White Label Link Module
External Membership Connector Module

3.3 Merchant Packages / Options

Merchant Packages are how the system is explained to store owners.

A merchant should not need to understand every internal module.

Merchant packages should answer:

What problem does this solve?
What does the store need to prepare?
Does it need POS?
Does it need KDS?
Does it require app installation?
Does it require SMS/Kakao cost?
Can it grow later?

4\. Module List

4.1 QR Menu Module

Purpose:

show menu through QR/web

May include:

menu categories
menu images
menu descriptions
prices
ingredient information
allergy information
recommended menu

Used in:

Stage 0A+

4.2 I18n Translation Module

Purpose:

support guest-language menu and Korean store summary

May include:

menu localization
guest language selection
translated menu descriptions
translated request summaries
store-to-guest message templates
critical request highlighting
original text preservation

Used in:

Stage 0A+

4.3 Show-to-Staff Module

Purpose:

let guest show Korean summary to staff on guest phone

May include:

guest menu view
staff read view
Korean summary
original text toggle
not-confirmed-order notice

Used in:

Stage 0A+

4.4 Send-to-Store Module

Purpose:

send guest menu request to store owner web console

May include:

request submission
request number
request version
store receipt status
guest waiting-for-confirmation status

Used in:

Stage 0B+

4.5 Owner Web Console Module

Purpose:

allow store owner/staff to receive and review requests

May include:

new request list
Korean summary
original text view
visual alert
sound alert
top warning badge
request detail

Used in:

Stage 0B+

4.6 POS-less Request Confirmation Module

Purpose:

support POS-less owners with simple confirm/complete flow

May include:

주문 확인
완료
auto-completion
unconfirmed warning
forced cleanup
closing cleanup

Used in:

Stage 0C

4.7 Waiting Module

Purpose:

support waiting registration and queue context

May include:

waiting registration
party size
waiting number
called status
arrival status
no-show status
cancel status

Used in:

Stage 1+

4.8 Manual POS Handoff Module

Purpose:

support stores that have POS but cannot integrate

May include:

prepared order summary
manual POS input checklist
POS input started
POS input completed
staff confirmation log

Used in:

Stage 1+

4.9 Mini KDS / Kitchen Assist Module

Purpose:

provide lightweight kitchen visibility without full KDS integration

May include:

prepared order queue
kitchen grouping
allergy/request highlight
manual kitchen acknowledgment
manual ready check
pickup/channel grouping

Used in:

Stage 2
Stage 3/4 fallback

4.10 POS Adapter Module

Purpose:

send prepared order context to POS

May include:

POS payload
POS item mapping
POS option mapping
POS reference
handoff success/failure
retry
manual fallback
duplicate guard

Used in:

Stage 3+

4.11 KDS Adapter Module

Purpose:

send kitchen handoff context to KDS and receive status

May include:

KDS payload
KDS reference
visible status
accepted status
ready status
completed status
failure/recovery

Used in:

Stage 4+

4.12 Benefit Routing Module

Purpose:

route visit/order/menu-preparation benefits without becoming membership ledger

May include:

benefit candidate
claim token
duplicate guard
claim deferred
external claim result

Used in:

Stage 5
Optional Stage 3/4

4.13 White Label Link Module

Purpose:

connect CatchMenu flow with tenant or brand app

May include:

tenant identity
white label deep link
identity link
customer consent
brand policy

Used in:

Stage 5

4.14 External Membership Connector Module

Purpose:

connect to tenant-owned membership systems

May include:

external membership reference
coupon/point claim
claim status
claim failure
duplicate protection

Used in:

Stage 5

5\. Merchant-Facing Package Types

The following package names are merchant-facing working names.

They can be changed later.

5.1 Package A — QR Menu Basic

Corresponding stage:

Stage 0A

Merchant-friendly description:

외국어 QR 메뉴판 \+ 직원에게 보여주기

Best for:

small stores
tourist-heavy stores
stores without POS
stores that only need multilingual menu

Includes:

QR Menu Module
I18n Translation Module
Show-to-Staff Module

Does not include:

owner console
request transmission
POS
KDS
payment
waiting queue

5.2 Package B — Menu Request Receive

Corresponding stage:

Stage 0B

Merchant-friendly description:

손님 메뉴 요청을 업주 휴대폰 웹화면으로 받기

Best for:

stores that want translated guest requests
stores without POS
stores avoiding SMS/Kakao cost
stores wanting no app installation

Includes:

Package A modules
Send-to-Store Module
Owner Web Console Module

Does not include:

POS
KDS
payment
full order management

5.3 Package C — Simple Request Confirm

Corresponding stage:

Stage 0C

Merchant-friendly description:

POS 없이 주문 요청 확인/완료 관리

Best for:

POS-less stores
small restaurants
low-digital-skill owners
food stalls
tourist-heavy stores

Includes:

Package B modules
POS-less Request Confirmation Module
auto-completion
unconfirmed warning
forced cleanup

Does not include:

app payment
POS
KDS
sales ledger
tax/settlement ledger

5.4 Package D — Wait \+ Manual POS

Corresponding stage:

Stage 1

Merchant-friendly description:

대기 \+ 메뉴 미리담기 \+ 기존 POS 수동 입력 보조

Best for:

stores with POS but no API integration
waiting restaurants
stores wanting order preparation before entry

Includes:

Waiting Module
Manual POS Handoff Module
Owner/Store Console
Staff Handoff

Does not include:

automatic POS order creation
KDS integration
payment ownership

5.5 Package E — Kitchen Assist

Corresponding stage:

Stage 2

Merchant-friendly description:

기존 POS는 그대로 두고 주방 보조 화면 추가

Best for:

stores with manual POS
stores needing kitchen visibility
stores wanting Mini KDS without POS replacement

Includes:

Package D modules
Mini KDS / Kitchen Assist Module

Does not include:

automatic POS order creation
full KDS authority
inventory deduction

5.6 Package F — POS Connect

Corresponding stage:

Stage 3

Merchant-friendly description:

POS 연동형 주문 맥락 전달

Best for:

stores with POS API
stores wanting reduced manual input
stores wanting POS order reference

Includes:

POS Adapter Module
POS reference
retry/fallback
duplicate guard

KDS is:

absent
POS-owned
external
optional
indirect

5.7 Package G — POS \+ KDS Connect

Corresponding stage:

Stage 4

Merchant-friendly description:

POS와 KDS까지 이어지는 통합 Handoff

Best for:

QSR
fast casual
high-volume stores
stores with connected kitchen operation

Includes:

POS Adapter Module
KDS Adapter Module
POS/KDS references
ready status
handoff completion
manual recovery

Does not include:

KDS internal production ownership
POS transaction ownership
inventory ownership

5.8 Package H — Franchise / SaaS Connect

Corresponding stage:

Stage 5

Merchant-friendly description:

프랜차이즈/SaaS/멤버십 연동형

Best for:

franchise HQ
multi-store brands
white label tenants
brands with external membership

Includes:

tenant policy
store capability profile
identity link
claim token
duplicate guard
external membership connector
white label link
webhook/API
SaaS reporting

6\. Package Upgrade Path

Packages should allow gradual upgrade.

Recommended upgrade path:

QR Menu Basic
→ Menu Request Receive
→ Simple Request Confirm
→ Wait \+ Manual POS
→ Kitchen Assist
→ POS Connect
→ POS \+ KDS Connect
→ Franchise / SaaS Connect

But stores do not need to follow this exact order.

Examples:

a tourist-heavy store may stay at Package A or B
a POS-less small store may use Package C
a waiting restaurant with POS may start at Package D
a kitchen-heavy store may start at Package E
a POS-integrated store may start at Package F
a franchise may start at Package H

7\. Option Policy

Some features should be sold or activated as options.

7.1 Notification Options

Default:

web console visual alert
sound alert if browser allows
top warning badge

Optional:

SMS notification
Kakao notification
push notification
owner app notification

SMS/Kakao should be optional because they create ongoing cost.

7.2 Language Options

Basic language set may include:

Korean
English
Japanese
Chinese

Expanded language set may include:

Spanish
Vietnamese
Thai
Indonesian
French
Arabic

Language expansion may be a package or option depending on cost.

7.3 Menu Content Options

Optional:

menu photo upload
menu description writing
allergy tagging
ingredient tagging
recommended menu
foreign-language menu copywriting

7.4 Owner Device Options

Default:

smartphone browser
tablet browser
PC browser

Optional:

owner app
fixed tablet mode
kitchen tablet
pickup display
printer
DID display

7.5 Kitchen Options

Optional:

Mini KDS
kitchen ticket
pickup display
ready board
sound alert
category grouping

7.6 Integration Options

Optional:

POS Adapter
KDS Adapter
webhook
external membership connector
white label link
API

7.7 Benefit Options

Optional:

visit benefit
menu-preparation benefit
coupon claim
point claim
duplicate guard
external membership claim

8\. Required / Optional / Disabled Matrix

Module| Package A| Package B| Package C| Package D| Package E| Package F| Package G| Package H
QR Menu| Required| Required| Required| Required| Required| Required| Required| Required
I18n| Required| Required| Required| Optional| Optional| Optional| Optional| Optional
Show-to-Staff| Required| Required| Required| Optional| Optional| Optional| Optional| Optional
Send-to-Store| Disabled| Required| Required| Optional| Optional| Optional| Optional| Optional
Owner Web Console| Disabled| Required| Required| Required| Required| Required| Required| Required
POS-less Confirm| Disabled| Disabled| Required| Disabled| Disabled| Disabled| Disabled| Disabled
Waiting| Disabled| Disabled| Disabled| Required| Required| Required| Required| Store-dependent
Manual POS Handoff| Disabled| Disabled| Disabled| Required| Required| Fallback| Fallback| Store-dependent
Mini KDS| Disabled| Disabled| Optional| Optional| Required| Optional/Fallback| Fallback| Store-dependent
POS Adapter| Disabled| Disabled| Disabled| Disabled| Disabled| Required| Required| Store-dependent
KDS Adapter| Disabled| Disabled| Disabled| Disabled| Disabled| Optional| Required| Store-dependent
Benefit Routing| Disabled| Disabled| Disabled| Optional| Optional| Optional| Optional| Required
External Membership| Disabled| Disabled| Disabled| Disabled| Disabled| Disabled| Optional| Required
White Label Link| Disabled| Disabled| Disabled| Disabled| Disabled| Optional| Optional| Required

9\. Packaging Boundary

Packages are merchant-facing bundles.

Packages do not change the runtime boundary.

Even if a package includes POS Adapter, CatchMenu does not become POS.

Even if a package includes Mini KDS, CatchMenu does not become full KDS.

Even if a package includes Benefit Routing, CatchMenu does not become an external membership ledger.

Core boundaries remain:

CatchMenu is not POS
CatchMenu is not payment
CatchMenu is not full KDS
CatchMenu is not inventory
CatchMenu is not external membership ledger

10\. Merchant Explanation Rule

When explaining packages to merchants, avoid starting with technical architecture.

Start with the store problem.

Examples:

외국인 메뉴 응대가 어렵다 → QR Menu Basic / Menu Request Receive

POS는 없지만 손님 요청을 폰으로 받고 싶다 → Simple Request Confirm

POS는 있는데 연동은 안 된다 → Wait \+ Manual POS

주방 전달이 자꾸 누락된다 → Kitchen Assist

POS API가 있다 → POS Connect

KDS까지 연결하고 싶다 → POS \+ KDS Connect

프랜차이즈 멤버십까지 연결해야 한다 → Franchise / SaaS Connect

11\. Product Naming Policy

CatchMenu is the temporary guest-facing working name.

Package names may be merchant-facing and can be localized.

Guest-facing label can vary by store.

Examples:

캐치메뉴
메뉴 미리담기
QR 메뉴 요청
대기 중 메뉴담기
입장 전 메뉴보기

The runtime remains the same.

12\. Configuration Policy

Each store should eventually have package and module configuration.

Suggested configuration fields:

store\_id
tenant\_id
package\_code
capability\_stage
enabled\_modules
optional\_modules
notification\_options
language\_options
kitchen\_options
integration\_options
benefit\_options
deployment\_mode
fallback\_mode

13\. Upgrade And Downgrade Rule

Upgrades should preserve data and configuration where possible.

Downgrades should disable modules safely.

Examples:

Package E → Package D
Mini KDS disabled, manual POS handoff remains

Package F → Package D
POS Adapter disabled, manual POS fallback remains

Package H → Package B
benefit routing and external membership disabled, QR/request flow remains

Downgrade must not delete operational history.

14\. Final Statement

CatchMenu must be modular.

Stores should be able to start with the smallest useful package and add options as needed.

The architecture should support stage-based capability, package-based merchant explanation, and option-based expansion without breaking runtime boundaries.
