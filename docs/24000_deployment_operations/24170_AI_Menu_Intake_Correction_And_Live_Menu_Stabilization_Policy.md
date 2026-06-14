03930 AI Menu Intake Correction And Live Menu Stabilization Policy

Legacy path: $old.

1\. Purpose

This document defines AI Menu Intake Correction and Live Menu Stabilization policy for CatchMenu / Wait Order Handoff.

AI Menu Intake is one of CatchMenu's strongest onboarding advantages.

It can reduce merchant setup burden by converting menu board photos, paper menus, PDF menus, online menu images, and price lists into structured menu drafts.

However, AI-generated menu drafts create operational risk if they are treated as immediately correct.

Wrong price, wrong option, wrong translation, missing allergy warning, broken set menu, or incorrect sold-out status can damage merchant trust during the first week.

Therefore, CatchMenu must define a strict correction and stabilization process before an AI-generated menu becomes a trusted live menu.

Core purpose:

Define AI menu correction policy.
Define AI draft versus live menu boundary.
Define merchant review requirement.
Define menu accuracy checks.
Define price correction.
Define option correction.
Define translation correction.
Define critical warning review.
Define live menu stabilization.
Define correction audit and history.
Prevent AI menu errors from damaging merchant trust.

Korean purpose:

AI 메뉴 보정 정책을 정의한다.
AI draft와 live menu의 경계를 정의한다.
업주/승인자 review requirement를 정의한다.
메뉴 정확도 점검을 정의한다.
가격 보정을 정의한다.
옵션 보정을 정의한다.
번역 보정을 정의한다.
중요 안내/알러지 warning review를 정의한다.
라이브 메뉴 안정화를 정의한다.
보정 감사와 이력을 정의한다.
AI 메뉴 오류가 매장 신뢰를 훼손하는 것을 방지한다.

2\. Scope

This document covers:

AI menu intake draft
menu correction
merchant review
menu approval
live menu publish
price correction
option correction
category correction
translation correction
critical warning review
allergy candidate review
set menu correction
sold-out/availability correction
menu version
correction history
live menu stabilization
support signal
audit event

This document does not define:

AI model implementation
OCR engine implementation
image processing pipeline
provider-specific POS menu sync
full inventory system
legal allergy certification
nutrition calculation engine
automatic menu copyright verification

Related documents:

03900\_Merchant\_Success\_Troubleshooting\_Readme.md
03910\_First\_7\_Days\_Activation\_Check\_Policy.md
03920\_First\_30\_Days\_Troubleshooting\_And\_Conversion\_Readiness\_Policy.md
03530\_POS\_Menu\_Table\_Order\_Mapping\_And\_Idempotency\_Policy.md
04110\_Menu\_Availability\_Soldout\_And\_Preorder\_Blocking\_Policy.md
02440\_AI\_Menu\_Intake\_And\_Menu\_Draft\_Generation\_Policy.md

3\. Core Principle

AI creates a draft.

Merchant or authorized reviewer approves the live menu.

Core rule:

AI menu draft is not live menu truth.
Live menu requires review, approval, versioning, and correction history.

Korean rule:

AI 메뉴 초안은 라이브 메뉴 진실이 아니다.
라이브 메뉴는 review, approval, versioning, correction history가 필요하다.

4\. AI Draft Boundary

AI draft may be generated from:

menu board photo
paper menu photo
PDF menu
online menu image
price list
delivery app menu screenshot
merchant text input

AI draft may include:

item name
category
price
option group
option
set composition
description
translation draft
spicy/vegetarian hint
allergy/critical warning candidate
availability hint

AI draft must not automatically become live without review.

Core rule:

AI output is proposal, not merchant-approved menu.

5\. Live Menu Boundary

Live menu is the merchant-facing and guest-facing menu used in CatchMenu runtime.

Live menu may be used for:

guest menu view
request flow
show-to-staff
preorder
reservation/prepaid pickup
promotion/CMS link
POS mapping
KDS handoff later
availability blocking

Core rule:

Live menu must be stable enough for guest and store operation.

6\. Menu Review Required

Menu review is required before live publish.

Review must cover:

item names
prices
categories
options
required options
set menus
descriptions
translation quality
critical warning candidates
sold-out or availability notes
merchant-specific notes

Core rule:

No review, no trusted live menu.

7\. Reviewer Types

Possible reviewers:

merchant owner
store manager
authorized menu editor
CatchMenu support operator
Merchant Ops operator
AI menu correction specialist

Reviewer authority must follow Identity Access policy.

Core rule:

Menu review authority must be explicit.

8\. Menu Approval Status

Suggested statuses:

DRAFT\_CREATED
AI\_EXTRACTION\_COMPLETE
REVIEW\_REQUIRED
IN\_REVIEW
CORRECTION\_REQUIRED
APPROVED\_FOR\_LIVE
LIVE\_PUBLISHED
LIVE\_CORRECTION\_REQUIRED
LIVE\_STABILIZED
ARCHIVED

Core rule:

Only APPROVED\_FOR\_LIVE can become LIVE\_PUBLISHED.

9\. Price Correction

Price errors are high-risk.

Price correction sources:

AI extraction error
old menu photo
unclear image
set price confusion
option price confusion
promotion price confusion
merchant price change
POS price mismatch

Price correction must record:

previous price
new price
source
reviewer
reason
effective time
menu version

Core rule:

Price correction must be auditable.

10\. Option Correction

Options often break order accuracy.

Option correction must check:

required option
optional option
multi-select
single-select
min/max selection
price delta
option availability
free text note
POS modifier compatibility later

Core rule:

Required option errors must be fixed before live request flow.

11\. Set Menu Correction

Set menus are especially risky.

Set menu correction must check:

main item
side item
drink choice
included options
upgrade options
price rule
substitution rule
missing required selection

Core rule:

Set menu must not be flattened incorrectly by AI draft.

12\. Category Correction

Category correction improves usability.

Category issues:

wrong category
duplicate category
missing category
too many categories
foreign-language category issue
merchant-specific display order

Core rule:

Category accuracy affects guest understanding and conversion.

13\. Translation Correction

Translation draft must be reviewed carefully.

Translation risks:

wrong ingredient
wrong cooking method
spicy level mistranslated
allergy implication changed
menu name over-translated
brand/menu identity lost
guest confusion

Translation correction should preserve:

meaning
menu identity
critical warning
option meaning
price clarity

Core rule:

Translation should help guests choose safely, not create new risk.

14\. Critical Warning Review

Critical warning candidates require human review.

Critical warning candidates may include:

allergy
shellfish
peanut
egg
milk
gluten
pork
beef
chicken
spicy
raw food
alcohol
caffeine
religious/dietary restriction
pregnancy-sensitive ingredient

CatchMenu should treat these as candidates unless verified.

Core rule:

AI may suggest critical warnings.
Authorized review decides what appears as warning.

15\. Allergy And Safety Boundary

CatchMenu should avoid false certainty.

Allowed wording:

allergy candidate
ingredient warning candidate
please confirm with store
store-reviewed warning

Not allowed without verified process:

guaranteed allergen-free
medically safe
certified allergy statement

Core rule:

Critical food safety language must be conservative and review-backed.

16\. Sold-Out And Availability Correction

AI may not know real availability.

Availability correction may include:

temporarily unavailable
sold out
seasonal item
limited quantity
preorder blocked
pickup only
dine-in only
hidden from guest
manual confirmation required

Core rule:

Availability should not be inferred from old menu image alone.

17\. Live Menu Stabilization

Live menu stabilization means the menu is accurate enough for real operation.

Stabilization criteria:

prices checked
options checked
categories usable
critical warnings reviewed
translations acceptable
merchant approval recorded
first-week corrections handled
support issues resolved or acceptable
request flow tested
manual POS fallback summary clear

Core rule:

Stable menu is prerequisite for trustworthy request, POS, and KDS expansion.

18\. Stabilization Period

Suggested stabilization periods:

first 7 days:
detect obvious errors

first 30 days:
detect operational menu issues

after major menu change:
restart focused stabilization

after POS mapping:
review mapping-sensitive fields

after translation expansion:
review language-sensitive fields

Core rule:

Menu stabilization is continuous after major change.

19\. Menu Correction Sources

Correction may be triggered by:

merchant report
staff report
guest confusion
support case
sales partner field note
AI confidence low
POS mapping conflict
request board issue
translation issue
price mismatch
availability issue

Core rule:

Correction source must be recorded.

20\. Correction Workflow

Suggested workflow:

issue detected
correction request created
menu item marked review required
correction drafted
reviewer checks correction
approval recorded
live menu updated
menu version created
audit event recorded
support case updated if applicable

Core rule:

Fast correction must still be versioned and auditable.

21\. Urgent Correction

Urgent correction may be required for:

wrong price causing payment dispute
critical warning missing
dangerous translation
wrong item name
unavailable item being ordered
set menu broken
merchant complaint during service

Urgent action may include:

temporarily hide item
mark review required
disable request for item
show notice
manual fallback only
support escalation

Core rule:

Unsafe menu item should be hidden or blocked before perfect correction.

22\. Menu Versioning

Every live menu update should create version history.

Version should record:

menu\_version\_id
previous\_version\_id
changed\_items
changed\_prices
changed\_options
changed\_translations
changed\_warnings
changed\_availability
actor
reason
created\_at
published\_at

Core rule:

Menu history must explain what guests and staff saw at the time.

23\. Correction History

Correction history should include:

correction\_id
menu\_item\_id
issue\_type
source
previous\_value
new\_value
reviewer
approval\_status
reason
created\_at
resolved\_at

Core rule:

Correction history is evidence for merchant trust and dispute review.

24\. AI Confidence Handling

AI extraction may include confidence.

Low confidence items should be marked.

Suggested confidence handling:

HIGH
\= normal review

MEDIUM
\= review recommended

LOW
\= review required

UNKNOWN
\= review required

Core rule:

Low confidence AI output must not be silently published.

25\. Merchant Approval Evidence

Merchant approval may include:

approved\_by
approval\_time
menu\_version\_id
approval\_method
approval\_note
approved\_scope

Approval scope:

full menu
specific category
specific item
specific correction
translation only
price only
availability only

Core rule:

Approval scope must be clear.

26\. Support Signal

Support signals may include:

AI\_MENU\_REVIEW\_REQUIRED
AI\_MENU\_LOW\_CONFIDENCE\_ITEM
MENU\_PRICE\_CORRECTION\_REQUIRED
MENU\_OPTION\_CORRECTION\_REQUIRED
MENU\_TRANSLATION\_REVIEW\_REQUIRED
CRITICAL\_WARNING\_REVIEW\_REQUIRED
LIVE\_MENU\_UNSTABLE
URGENT\_MENU\_CORRECTION\_REQUIRED
MENU\_APPROVAL\_REQUIRED
MENU\_VERSION\_CONFLICT

Support Signal alerts.

It does not publish menu by itself.

27\. Audit Events

Recommended audit events:

AI\_MENU\_DRAFT\_CREATED
AI\_MENU\_REVIEW\_STARTED
AI\_MENU\_CORRECTION\_REQUESTED
AI\_MENU\_CORRECTION\_APPLIED
MENU\_PRICE\_CORRECTED
MENU\_OPTION\_CORRECTED
MENU\_TRANSLATION\_CORRECTED
CRITICAL\_WARNING\_REVIEWED
MENU\_APPROVED\_FOR\_LIVE
MENU\_LIVE\_PUBLISHED
LIVE\_MENU\_CORRECTION\_REQUIRED
LIVE\_MENU\_STABILIZED
MENU\_ITEM\_TEMPORARILY\_HIDDEN
MENU\_VERSION\_CREATED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
menu\_context\_id
menu\_version\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

28\. Failure Events

Example failure codes:

WOH.AI\_MENU.REVIEW\_REQUIRED
WOH.AI\_MENU.LOW\_CONFIDENCE\_BLOCKED
WOH.AI\_MENU.PRICE\_UNVERIFIED
WOH.AI\_MENU.REQUIRED\_OPTION\_UNVERIFIED
WOH.AI\_MENU.TRANSLATION\_REVIEW\_REQUIRED
WOH.AI\_MENU.CRITICAL\_WARNING\_REVIEW\_REQUIRED
WOH.AI\_MENU.APPROVAL\_REQUIRED
WOH.AI\_MENU.VERSION\_CONFLICT
WOH.AI\_MENU.LIVE\_MENU\_UNSTABLE
WOH.AI\_MENU.URGENT\_CORRECTION\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

29\. Relationship To First 7 Days Activation

First 7 days check should catch obvious AI menu errors.

If found:

mark correction required
block risky item if needed
record support signal
update activation status if severe

Core rule:

Activation cannot pass cleanly if menu errors block basic use.

30\. Relationship To First 30 Days Review

First 30 days review should evaluate whether menu trust is stable.

Core rule:

Menu trust is conversion readiness condition.

31\. Relationship To POS Mapping

AI menu and POS mapping are separate.

POS mapping requires:

merchant-approved live menu
POS item mapping
option mapping
mapping version
handoff eligibility

Core rule:

AI menu approved for live does not automatically mean POS-ready.

32\. Relationship To Inventory/Sold-Out Runtime

Menu availability may later depend on inventory/sold-out runtime.

Core rule:

Menu correctness and menu availability must be connected but not confused.

33\. Relationship To Request Board Adoption

Request board usability depends on clear menu and option summaries.

Core rule:

Staff adoption suffers when menu request summary is unclear.

34\. MVP Requirements

MVP should support at least:

AI draft status
review required status
menu correction request
price correction
option correction
translation review flag
critical warning review flag
merchant approval marker
live publish marker
menu version
correction history
support signal
audit event
failure event
urgent item hide/block marker

MVP may defer:

advanced AI confidence scoring
automatic allergen detection
multi-reviewer approval workflow
full translation QA engine
nutritional analysis
full inventory sync
automatic POS mapping suggestion

35\. Suggested Conceptual Entities

Suggested entities:

ai\_menu\_drafts
ai\_menu\_review\_tasks
menu\_correction\_requests
menu\_versions
menu\_correction\_history
menu\_approval\_events
menu\_stabilization\_reviews
menu\_translation\_review\_events
menu\_critical\_warning\_reviews
menu\_support\_signals
menu\_audit\_events
menu\_failure\_events

This document defines policy.

Actual schema may be designed later.

36\. Risk If Skipped

If AI Menu Intake Correction and Live Menu Stabilization policy is skipped, risks include:

wrong prices go live
wrong options create bad orders
set menus break
critical warnings disappear
translations mislead guests
merchant loses trust in first week
staff distrusts request board
POS mapping becomes unsafe
KDS path receives bad order data
trial conversion fails
AI becomes liability instead of onboarding advantage

Therefore, AI Menu Intake must be paired with review, correction, stabilization, and audit.

37\. Final Rule

AI Menu Intake is a speed advantage only when correction governance exists.

Final rule:

Use AI to draft.
Do not treat AI draft as truth.
Require review.
Correct prices.
Correct options.
Review translations.
Review critical warnings.
Record merchant approval.
Version live menu.
Track corrections.
Hide unsafe items quickly.
Stabilize menu during first 7 and 30 days.
Do not connect unstable menu to POS/KDS automation.
