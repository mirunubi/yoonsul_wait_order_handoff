# 01180_Stage_0_Translation_And_Critical_Request_Handling

1\. Purpose

This document defines the Stage 0 translation and critical request handling policy for CatchMenu.

Stage 0 must help guests use the menu in their own language while helping Korean store staff understand the operational meaning of the request.

However, translation must not become unsafe certainty.

Critical guest requests must be visible, structured where possible, preserved in original language, and reconfirmed by staff when needed.

Core purpose:

Translate for understanding.
Preserve original meaning.
Highlight critical requests.
Require staff reconfirmation when safety is uncertain.

Korean purpose:

이해를 돕기 위해 번역한다.
원문의 의미를 보존한다.
중요 요청을 명확히 표시한다.
안전이 불확실하면 직원 재확인을 요구한다.

2\. Scope

This document covers Stage 0A, Stage 0B, and Stage 0C translation behavior.

Covered areas:

guest language selection
store language summary
original guest text preservation
structured menu item translation
structured option translation
free-text memo translation
critical request detection
critical request highlighting
translation confidence
staff reconfirmation
support evidence
failure handling

This document does not define:

full i18n product strategy
AI customer center response generation
legal translation certification
medical advice
allergy liability conclusion
POS menu master translation ownership
external delivery platform translation

3\. Core Principle

Translation supports communication.

Translation does not create final operational truth.

Core rule:

Translation is assistance.
Structured data is stronger.
Staff confirmation is required when critical meaning is uncertain.

Korean rule:

번역은 보조다.
구조화된 데이터가 더 강하다.
중요 의미가 불확실하면 직원 확인이 필요하다.

4\. Language Layers

Stage 0 should separate language layers.

Recommended layers:

guest\_language
store\_language
canonical\_menu\_data
structured\_option\_data
original\_guest\_text
translated\_store\_summary
support\_review\_text

Meaning:

guest\_language
\= language selected by guest

store\_language
\= language used by staff, usually Korean

canonical\_menu\_data
\= stable menu/item/option identifiers

original\_guest\_text
\= guest-entered memo or request in original language

translated\_store\_summary
\= staff-readable translation summary

support\_review\_text
\= support-safe text used for later review

5\. Canonical Data First

Menu item and option translation should rely on canonical IDs where possible.

Preferred mapping:

menu\_item\_id
→ localized\_menu\_name
→ store\_language\_name

option\_id
→ localized\_option\_name
→ store\_language\_option\_name

critical\_tag\_id
→ localized\_guest\_label
→ store\_warning\_label

Avoid relying only on free-text translation for:

menu item identity
option identity
allergy warning
pork/beef/seafood/nut/alcohol indicator
spicy level
vegetarian/vegan request

Core rule:

Translate labels.
Do not translate away identifiers.

6\. Original Text Preservation

Original guest text must be preserved when guest enters free-text memo or custom request.

Original text helps:

staff reconfirmation
support review
translation dispute
critical request handling
guest trust

The owner console may show:

Korean summary
original guest text
structured menu item
structured option
critical warning tag
translation confidence

Core rule:

Do not overwrite original guest text with translation.

Korean rule:

번역문으로 손님 원문을 덮어쓰지 않는다.

7\. Store Language Summary

For Korean stores, Stage 0 should generate or display a Korean staff summary.

Example:

손님 요청:
\- 참치김밥 1개
\- 매운 소스 제외
\- 땅콩 알러지 주의

주의:
자동 번역 요약입니다.
알러지/특이 요청은 손님과 확인해주세요.

The summary should be:

short
structured
staff-readable
critical-warning visible
not overconfident

8\. Critical Request Categories

Critical request categories include:

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

These categories require stronger visibility than normal preferences.

Normal preferences may include:

less sauce
more sauce
less salty
extra napkin
cut in half
separate packaging

Critical request must be visually distinguished from normal memo.

9\. Allergy Handling

Allergy requests are high-risk.

If an allergy is detected, the system should show:

알러지 주의
직원 확인 필요
자동 번역만 믿지 말고 손님과 확인해주세요.

Guest-facing message may say:

Please tell staff directly if you have an allergy.

Korean guest-facing:

알러지가 있다면 직원에게 직접 말씀해주세요.

Core rule:

Allergy translation must never silently become safe assumption.

10\. Cannot-Eat Ingredient Handling

Cannot-eat ingredient requests may be dietary, religious, medical, preference, or allergy-related.

Examples:

no pork
no beef
no seafood
no nuts
no egg
no dairy
no alcohol
no raw food

The system should preserve both:

structured tag
original guest wording

If the reason is unclear, staff reconfirmation may be required.

11\. Pork / Beef / Seafood / Alcohol Handling

Certain ingredients may be critical for religious, cultural, health, or personal reasons.

Structured warnings should exist for:

pork included
beef included
seafood included
alcohol included
raw food included

The system should not assume guest acceptance.

If a guest says “no pork,” and an item may contain pork-derived ingredient, staff confirmation is required.

Core rule:

Ingredient exclusion must be treated as operational caution, not casual memo.

12\. Spicy Level Handling

Spicy level is often mistranslated or culturally relative.

Stage 0 should support structured spicy levels when possible.

Example levels:

not spicy
mild
medium
spicy
very spicy
no spicy sauce
spicy sauce separate

If guest says “not spicy,” staff summary should clearly show:

매운맛 제외 요청

If item is inherently spicy, the system should show reconfirmation warning.

13\. Vegetarian / Vegan Handling

Vegetarian and vegan requests require caution because ingredient definitions vary.

Structured tags may include:

vegetarian request
vegan request
no meat
no seafood
no egg
no dairy

Staff warning:

채식/비건 요청입니다.
재료와 조리 방식 확인이 필요할 수 있습니다.

Do not claim an item is vegan-safe unless menu metadata supports it.

14\. Child / Elderly / Medical Caution Handling

Requests involving children, elderly guests, or medical caution should be highlighted.

Examples:

for child
for elderly person
low salt
soft texture
no raw food
medical caution

The system should not provide medical advice.

It should help staff notice the request.

Core rule:

Medical or age-related caution is staff awareness support, not medical judgment.

15\. Custom Cooking Request Handling

Custom cooking requests may be ambiguous.

Examples:

cook longer
less oil
separate sauce
no onion
not too salty
warm it up
cut smaller

Custom requests should be shown clearly.

If operational feasibility is uncertain, the owner console should show:

직원 확인 필요

Do not automatically promise that custom requests can be fulfilled.

16\. Translation Confidence

The system should classify translation confidence.

Suggested values:

HIGH
MEDIUM
LOW
UNKNOWN

Meaning:

HIGH
\= structured item/option mapping is reliable and text is simple

MEDIUM
\= translation likely understandable but may require staff awareness

LOW
\= ambiguous, critical, or uncertain translation

UNKNOWN
\= system cannot evaluate reliability

LOW or UNKNOWN should trigger caution.

17\. Translation Confidence Display

Owner console should show translation caution when needed.

Korean warning:

번역 신뢰도가 낮습니다.
손님과 직접 확인해주세요.

Guest-facing warning:

Some translation may need staff confirmation.
Please show staff the original request if needed.

Internal support note:

translation\_confidence \= LOW
staff\_reconfirmation\_required \= true

18\. Staff Reconfirmation Required

Staff reconfirmation may be required when:

critical request exists
translation confidence is LOW or UNKNOWN
free-text memo contains uncertain request
item contains excluded ingredient
option conflict exists
menu item is sold out or unavailable
guest changed request after sending

Possible state:

STORE\_RECONFIRM\_REQUIRED

Core rule:

Critical uncertainty must block unsafe automation.

19\. Stage 0A Handling

In Stage 0A, translation is used for guest menu viewing and Show-to-Staff View.

Stage 0A has no store-side request by default.

Required behavior:

show guest language menu
show staff-readable summary
preserve original memo if entered
highlight critical warnings
tell guest to show staff

Stage 0A must not claim that the store received or confirmed the request.

20\. Stage 0B Handling

In Stage 0B, translated request may be sent to owner console.

Required behavior:

send structured item IDs
send structured option IDs
send guest language
send original memo
send store language summary
send critical flags
send translation confidence

Owner console should show staff caution before handling.

Stage 0B must not lock guest edit unless configured.

21\. Stage 0C Handling

In Stage 0C, translation and critical request warnings affect confirmation and completion safety.

Required behavior:

show critical warnings before store confirmation
show translation confidence before confirmation
preserve original guest memo
block unsafe auto-completion when unresolved critical reconfirmation exists
include translation events in evidence packet

Stage 0C must not auto-resolve critical uncertainty.

22\. Translation And Auto-Completion

Confirmed auto-completion must respect critical request status.

Auto-completion may be blocked when:

critical request unresolved
translation confidence is LOW or UNKNOWN
STORE\_RECONFIRM\_REQUIRED remains active
support review block exists

Core rule:

Auto-completion must not hide unresolved critical translation risk.

23\. Translation And Forced Cleanup

Forced cleanup screen should prioritize unconfirmed requests with critical translation risk.

Priority indicators:

critical request flag
LOW translation confidence
UNKNOWN translation confidence
allergy warning
dietary restriction warning
custom memo warning

Forced cleanup must not bulk-complete these requests.

24\. Translation Failure Handling

If translation fails, the system should not pretend translation succeeded.

Guest-facing fallback:

Translation may not be available.
Please show this screen to staff.

Korean:

번역을 사용할 수 없을 수 있습니다.
이 화면을 직원에게 보여주세요.

Owner-facing fallback:

번역 실패 또는 불확실한 요청입니다.
원문을 확인하고 손님과 직접 확인해주세요.

25\. Menu Translation Versioning

Menu translation should be version-aware.

Recommended fields:

menu\_version
translation\_version
language\_code
translated\_at
review\_status
source\_type

If menu translation version changes after a request is sent, the request should preserve the version used at request time.

Core rule:

Request evidence must preserve the translation context used at the time.

26\. Free-Text Memo Policy

Free-text memo should be allowed but treated carefully.

Guidance to guest:

Please write short and clear requests.

Korean:

요청 사항은 짧고 명확하게 작성해주세요.

Critical requests should be guided into structured options where possible.

Core rule:

Free-text memo is communication support.
Structured critical tag is safety support.

27\. Prohibited Translation Behavior

The system must not:

delete original guest text
replace original text with translated text
hide critical warnings
convert uncertain translation into safe status
auto-approve allergy handling
claim dietary safety without metadata
claim payment/order confirmation through translation wording
silently remove conflicting request fields

Core rule:

Do not translate away risk.

28\. Support Signal Policy

Translation-related support signals may include:

LOW\_CONFIDENCE\_TRANSLATION
UNKNOWN\_TRANSLATION\_CONFIDENCE
CRITICAL\_REQUEST\_DETECTED
ALLERGY\_REQUEST\_DETECTED
DIETARY\_RESTRICTION\_DETECTED
TRANSLATION\_FAILED
ORIGINAL\_TEXT\_MISSING
TRANSLATION\_VERSION\_CONFLICT
STAFF\_RECONFIRM\_REQUIRED

Support signal payload should include:

signal\_id
signal\_type
tenant\_id
store\_id
request\_id
request\_version
language\_code
translation\_confidence
critical\_flag\_summary
created\_at
evidence\_packet\_ref if available

Raw sensitive detail should be pulled through Support Gateway when needed.

29\. Evidence Packet Policy

Evidence Packet for translation and critical request issues may include:

request\_id
request\_version
guest\_language
store\_language
menu\_version
translation\_version
original\_guest\_text
translated\_store\_summary
structured item IDs
structured option IDs
critical flags
translation confidence
staff reconfirmation state
translation failure event
support signal reference
state timeline

Evidence Packet must distinguish:

original text
translated text
structured data
system interpretation
staff action

Core rule:

Evidence must preserve translation context.

30\. Failure Event Policy

Translation failures must be typed and traceable.

Example failure codes:

WOH.STAGE0.TRANSLATION.REQUEST\_SUMMARY.FAILED
WOH.STAGE0.TRANSLATION.REQUEST\_SUMMARY.LOW\_CONFIDENCE
WOH.STAGE0.TRANSLATION.ORIGINAL\_TEXT.MISSING
WOH.STAGE0.TRANSLATION.CRITICAL\_FLAG.DETECTION\_FAILED
WOH.STAGE0.TRANSLATION.VERSION.CONFLICT
WOH.STAGE0.CRITICAL\_REQUEST.RECONFIRM\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

31\. Merchant-Facing Messages

Recommended Korean messages:

중요 요청입니다.
자동 번역만 믿지 말고 손님과 확인해주세요.

번역 신뢰도가 낮습니다.
원문을 확인하고 손님에게 직접 확인해주세요.

알러지 또는 식단 관련 요청일 수 있습니다.
조리 전 확인이 필요합니다.

이 요청은 자동 완료 전에 직원 재확인이 필요합니다.

32\. Guest-Facing Messages

Recommended guest-facing messages:

Please tell staff directly if this is important.

Some translation may need staff confirmation.

Please show staff the original request if needed.

Korean:

중요한 내용이면 직원에게 직접 말씀해주세요.

일부 번역은 직원 확인이 필요할 수 있습니다.

필요하면 원문 요청을 직원에게 보여주세요.

33\. Support-Facing Messages

Support-facing view may show:

translation\_confidence \= LOW
critical\_request\_detected \= true
original\_guest\_text preserved
STORE\_RECONFIRM\_REQUIRED generated
AUTO\_COMPLETION\_BLOCKED due to unresolved critical request

Support-facing messages should include:

request\_id
request\_version
language\_code
translation\_version
critical\_flag\_summary
trace\_id
evidence\_packet\_ref

34\. Metrics And Monitoring

Recommended metrics:

translation\_failure\_count
low\_confidence\_translation\_count
critical\_request\_count
allergy\_request\_count
staff\_reconfirmation\_required\_count
translation\_version\_conflict\_count
original\_text\_missing\_count
auto\_completion\_blocked\_by\_translation\_risk\_count

Metrics should support quality improvement.

They should not become punitive by default.

35\. Relationship To Stage 0 Request State Guard

This document depends on:

01160\_Stage\_0\_Request\_State\_Transition\_Guard.md

Translation risk may block unsafe transitions such as:

AUTO\_COMPLETED
CLOSE\_AUTO\_COMPLETED
COMPLETED

when critical reconfirmation remains unresolved.

36\. Relationship To Guest Web Screen

Guest-facing display is governed by:

01140\_Stage\_0\_Guest\_Web\_Screen\_Policy.md

Guest screens must show translation caution simply and actionably.

37\. Relationship To Owner Web Console

Owner-facing display is governed by:

01150\_Stage\_0\_Owner\_Web\_Console\_Policy.md

Owner console must show original text, translated summary, critical flags, and translation confidence when relevant.

38\. Final Statement

Stage 0 translation exists to reduce communication friction, not to erase uncertainty.

Critical requests must remain visible, traceable, and reconfirmable.

Final rule:

Translate for understanding.
Preserve the original.
Structure critical meaning.
Highlight uncertainty.
Require staff confirmation when risk exists.
Never translate away safety.
