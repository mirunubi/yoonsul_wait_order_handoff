# 001100_Policy_CatchMenu_I18n_Order_Request_Translation.md

Legacy path: $old.

1\. Purpose

This document defines the multilingual order request and translation policy for CatchMenu.

CatchMenu must allow guests to view menus, prepare menu requests, and communicate requests in their own language while allowing store owners and staff to receive a Korean operational summary.

This policy is especially important for Stage 0A, 0B, and 0C.

Core purpose:

guest language input
→ Korean staff-readable output
→ store confirmation or change request
→ guest-language response

2\. Core Principle

CatchMenu must separate guest language, store language, and system canonical data.

The guest may see and write in Spanish, English, Japanese, Chinese, Vietnamese, Thai, or another supported language.

The store owner or staff should receive the request in Korean.

The system must preserve both the original guest-language input and the Korean translated summary.

Core rule:

Original guest text must be preserved.
Korean operational translation must be generated.
Critical requests must be highlighted.
Store confirmation is required before handling.

3\. Language Roles

3.1 Guest Language

Guest Language is the language selected by the guest.

Examples:

es \= Spanish
en \= English
ja \= Japanese
zh \= Chinese
vi \= Vietnamese
th \= Thai
ko \= Korean

Guest Language is used for:

menu names
menu descriptions
option labels
allergy warnings
request input
store messages
change requests
status messages
reconfirmation messages

3.2 Store Language

Store Language is the language used by the store owner or staff.

For initial Korean stores, Store Language is:

ko \= Korean

Store Language is used for:

owner web console
staff read view
Korean menu summary
translated request summary
allergy/request warnings
order review buttons
change request templates

3.3 Canonical System Data

Canonical System Data is language-independent structured data.

Examples:

menu\_item\_id
option\_id
quantity
allergy\_code
request\_type
spicy\_level
dietary\_flag
pork\_flag
alcohol\_flag
sold\_out\_status

Canonical data must not depend on translation text.

4\. Translation Direction

CatchMenu must support bidirectional translation.

4.1 Guest To Store

Guest-facing input is converted into Korean staff-readable output.

Example:

Guest language: Spanish
Guest text: Sin cilantro, no picante.
Store Korean summary: 고수 제외, 맵지 않게 해주세요.

4.2 Store To Guest

Store messages are converted into the guest language.

Example:

Store Korean message: 이 메뉴는 현재 품절입니다. 다른 메뉴를 선택해주세요.
Guest Spanish message: Este menú no está disponible actualmente. Por favor, elija otro menú.

4.3 Canonical Data To Both Sides

Structured menu and option data should be displayed in each language using controlled translations.

Example:

menu\_item\_id \= tuna\_kimbap
ko \= 참치김밥
es \= Kimbap de atún
en \= Tuna Kimbap
ja \= ツナキンパ

5\. Stage 0A Translation Policy

Stage 0A is “show-to-staff” mode.

No request is transmitted to the store owner system.

The guest phone must provide two views:

Guest Menu View
Staff Read View

5.1 Guest Menu View

Guest Menu View should display:

menu in guest language
options in guest language
allergy information in guest language
ingredient explanation in guest language
request input in guest language

5.2 Staff Read View

Staff Read View must display Korean operational summary.

Required fields:

guest selected language
selected menu items in Korean
quantity
options in Korean
allergy flags
special request Korean translation
original guest text
not-confirmed-order notice

Required notice:

이 화면은 주문 확정이 아닙니다.
직원이 확인 후 주문을 처리해주세요.

5.3 Stage 0A Modification

Stage 0A does not support store-to-guest digital modification.

If the store cannot accept the request, staff must ask the guest to go back and edit the selection on the guest phone.

Normal flow:

Staff reviews Korean staff view
→ staff asks guest to edit if needed
→ guest goes back to menu
→ guest edits
→ guest shows updated staff view

6\. Stage 0B Translation Policy

Stage 0B sends the guest request to the owner web console.

The store owner receives the request in Korean.

The guest may receive store messages in the selected language.

6.1 Guest Request Payload

Stage 0B should preserve:

guest\_language
store\_language
menu\_item\_ids
option\_ids
quantities
guest\_request\_original\_text
guest\_request\_translated\_ko
allergy\_flags
dietary\_flags
translation\_confidence
request\_version

6.2 Owner Console View

Owner console should display:

request number
guest language
Korean menu summary
Korean translated request
original guest-language text
allergy warning
dietary warning
translation confidence if needed
request version

6.3 Store-Initiated Messages

Store may send messages such as:

품절입니다.
대체 메뉴를 선택해주세요.
이 메뉴는 매우 맵습니다. 괜찮으신가요?
이 메뉴에는 돼지고기가 포함되어 있습니다. 괜찮으신가요?
알러지 위험이 있습니다. 확인해주세요.
요청 내용을 다시 확인해주세요.

These messages must be shown to the guest in Guest Language.

7\. Stage 0C Translation Policy

Stage 0C is POS-less simple request confirmation.

The owner interface remains Korean-first.

The guest interface remains guest-language-first.

Translation must support low-digital-skill owners.

7.1 Owner Must Not Need To Translate

The owner should not need to understand the guest’s foreign language.

Owner console must show:

Korean menu name
Korean option name
Korean allergy warning
Korean request summary
original text toggle
simple action buttons

7.2 Guest Must Understand Store Status

Guest status must be shown in Guest Language.

Examples:

Waiting for store confirmation.
The store has confirmed your request.
You can no longer edit directly.
This menu is sold out.
Please choose another menu.
Payment is handled at the store.

7.3 Critical Store Messages

Critical messages should use controlled templates rather than free translation when possible.

Examples:

sold out
substitution required
allergy reconfirm required
spicy level reconfirm required
pork included
alcohol included
cannot fulfill request
ask staff

Controlled templates reduce translation risk.

8\. Critical Request Categories

The following request categories must be highlighted to staff.

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
vegetarian/vegan request
child/elderly consideration
medical caution
custom cooking request

For these categories, automatic translation must not be treated as final truth.

Staff must be warned to confirm if necessary.

Korean staff warning:

중요 요청입니다.
자동 번역만 믿지 말고 필요 시 손님과 확인해주세요.

English guest notice:

Important requests may need staff confirmation.

9\. Translation Confidence

The system may track translation confidence.

Suggested values:

HIGH
MEDIUM
LOW
UNKNOWN

Low confidence should trigger staff warning.

Example:

번역 신뢰도가 낮습니다.
원문을 함께 확인하거나 손님에게 다시 확인해주세요.

Translation confidence is informational.

It must not override staff judgment.

10\. Original Text Preservation

The system must preserve original guest text.

Reason:

translation may be imperfect
staff may need to compare original text
dispute or misunderstanding may occur
future translation improvement may be needed
audit/review may require original wording

Required data:

guest\_request\_original\_text
guest\_language
translated\_store\_text
translation\_source
translation\_confidence
translated\_at

11\. Structured Translation Preferred

For menu items, options, allergy labels, and standard warnings, structured translation should be preferred over free translation.

Good:

menu\_item\_id → localized menu name
option\_id → localized option name
allergy\_code → localized warning

Riskier:

free-text translation of entire order only

Structured translation reduces ambiguity.

Free-text translation should mainly apply to guest notes and custom requests.

12\. Store Message Templates

Store-to-guest messages should use controlled templates.

Suggested templates:

SOLD\_OUT
SUBSTITUTION\_REQUIRED
QUANTITY\_UNAVAILABLE
ALLERGY\_RECONFIRM\_REQUIRED
SPICY\_RECONFIRM\_REQUIRED
PORK\_INCLUDED\_CONFIRM
ALCOHOL\_INCLUDED\_CONFIRM
REQUEST\_UNCLEAR
PLEASE\_ASK\_STAFF
STORE\_CONFIRMED
ORDER\_LOCKED
PAY\_AT\_STORE

Each template should have localized text.

Example:

SOLD\_OUT

ko: 이 메뉴는 현재 준비할 수 없습니다. 다른 메뉴를 선택해주세요.
en: This menu is currently unavailable. Please choose another menu.
es: Este menú no está disponible actualmente. Por favor, elija otro menú.
ja: このメニューは現在ご用意できません。他のメニューをお選びください。

13\. Free Text Request Policy

Guests may enter custom notes.

Examples:

덜 맵게 해주세요
no cilantro
sin picante
no pork
for child
not too salty

Free text must be:

stored in original language
translated into Korean for staff
marked with confidence if possible
highlighted if it includes critical keywords

If the system detects unclear or risky free text, it should mark:

STAFF\_CONFIRM\_REQUIRED

14\. Staff Confirmation Policy

For critical categories, the owner/staff may need to confirm with the guest.

Examples:

allergy
religious restriction
pork/alcohol warning
spicy level
raw food
ingredient substitution

Staff confirmation actions:

confirm request
ask guest again
send reconfirmation message
reject request
suggest alternative

Staff confirmation should create an event.

15\. Modification And Reconfirmation Flow

When the store cannot accept the request as-is, the store may send a change or reconfirmation request.

Flow:

Guest sends request
→ store reviews Korean summary
→ store sends change request
→ guest receives message in guest language
→ guest edits or confirms
→ updated request version is created
→ store reviews latest version

The system must preserve request versions.

Example:

request v1
→ store change request
→ guest edits
→ request v2

The owner console must clearly show the latest version.

16\. Order Lock Translation

When the store taps “주문 확인,” the guest request is locked.

Guest message must be shown in Guest Language.

Korean:

매장에서 주문 요청을 확인했습니다.
이제 직접 수정할 수 없습니다.
변경이 필요하면 직원에게 말씀해주세요.

English:

The store has confirmed your request.
You can no longer edit it directly.
Please ask staff if you need a change.

Spanish:

La tienda ha confirmado su solicitud.
Ya no puede editarla directamente.
Si necesita cambiar algo, por favor pregunte al personal.

17\. Payment Boundary Translation

If payment is not handled by CatchMenu, the guest must be clearly informed.

Korean:

결제는 매장에서 진행됩니다.

English:

Payment is handled at the store.

Spanish:

El pago se realiza en la tienda.

This message is especially important in Stage 0C.

18\. Not-Confirmed Order Notice

CatchMenu must avoid implying that a request is a confirmed POS order.

Guest-facing wording should distinguish:

request sent
waiting for store confirmation
store confirmed request
pay at store

Avoid wording:

order complete
payment complete
confirmed order
kitchen started

unless the responsible system confirms it.

19\. Owner Interface Language

The owner interface for Korean stores should be Korean-first.

Suggested owner labels:

새 요청
주문 확인
완료
불가/품절
수정 요청
대체 제안
손님 재확인 요청
원문 보기
번역 보기
알러지 주의
자동 번역 주의

Owner UI must remain simple for Stage 0C.

20\. Guest Interface Language

Guest interface should use the selected language consistently.

Guest-facing screens:

menu browsing
cart
request sent
store confirmation
change request
sold out
pay at store
show staff
edit request

If translation is unavailable for a language, the system should fall back gracefully.

Suggested fallback:

Guest selected language → English → Korean

21\. Data Fields

Suggested data fields:

guest\_language
store\_language
menu\_localization\_version
request\_original\_text
request\_translated\_text\_ko
translation\_source
translation\_confidence
translation\_status
critical\_request\_flags
staff\_confirmation\_required
store\_message\_template\_id
store\_message\_original\_ko
store\_message\_translated\_guest\_language
request\_version
latest\_version\_flag

22\. Event Examples

Suggested events:

language\_selected
menu\_viewed\_in\_guest\_language
request\_text\_entered
request\_translated\_to\_store\_language
staff\_read\_view\_opened
request\_sent\_to\_store
store\_message\_translated\_to\_guest\_language
translation\_low\_confidence\_flagged
critical\_request\_detected
guest\_reconfirmation\_requested
guest\_request\_updated
store\_confirmed\_request
order\_locked\_for\_guest

23\. Boundary Rules

CatchMenu translation does not guarantee legal, medical, religious, or allergy correctness.

CatchMenu must not silently convert critical requests into confirmed safe orders.

Staff confirmation may still be required.

Translation helps communication.

Translation does not replace store responsibility.

24\. Final Statement

CatchMenu i18n policy exists to let guests communicate in their own language while allowing Korean store owners and staff to understand and respond operationally.

The system must preserve original text, provide Korean summaries, return store messages in the guest language, and highlight critical requests.

Core rule:

guest language in
Korean staff summary out
Korean store decision in
guest language response out
